#[macro_use] extern crate rustler;
#[macro_use] extern crate rustler_codegen;
#[macro_use] extern crate lazy_static;

extern crate git2;

use rustler::{NifEnv, NifTerm, NifResult, NifEncoder};
use rustler::types::atom::NifAtom;
use git2::{Repository, Branch, Branches, BranchType};
use rustler::resource::ResourceArc;
use std::sync::{RwLock,Arc};
use std::ops::Deref;
use std::io;

mod atoms {
    rustler_atoms! {
        atom ok;
        atom error;
        atom pong;
        atom local;
        atom remote;
        //atom __true__ = "true";
        //atom __false__ = "false";
    }
}

rustler_export_nifs! {
    "Elixir.Gixir.Nif",
    [("add", 2, add),
    ("repo_init_at", 2, repo_init_at),
    ("repo_open", 1, repo_open),
    ("repo_list_branches", 1, repo_list_branches),
    ("repo_workdir", 1, repo_workdir),
    ("ping", 0, ping)],
    Some(on_load)
}


pub struct RepoWrapper(Repository);

unsafe impl Sync for RepoWrapper { }


pub struct MyRepo {
    pub repo: Arc<RwLock<RepoWrapper>>,
}


fn on_load<'a>(env: NifEnv<'a>, _load_info: NifTerm<'a>) -> bool {
    resource_struct_init!(MyRepo, env);
    true
}

#[allow(unused_variables)]
fn ping<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    Ok((atoms::ok(), atoms::pong()).encode(env))
}

fn repo_init_at<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let path: String = try!(args[0].decode());
    let bare: bool = try!(args[1].decode());

    let repo = if bare {
        match Repository::init_bare(path) {
            Ok(repo) => repo,
            Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
        }
    }else {
        match Repository::init(path) {
            Ok(repo) => repo,
            Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
        }
    };

    let resource = ResourceArc::new(MyRepo{
            repo: Arc::new(RwLock::new(RepoWrapper(repo))),
        });

    Ok((atoms::ok(), resource).encode(env))
}

fn repo_open<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let path: String = try!(args[0].decode());

    let repo = match Repository::open(path) {
            Ok(repo) => repo,
            Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };

    let resource = ResourceArc::new(MyRepo{
            repo: Arc::new(RwLock::new(RepoWrapper(repo))),
        });

    Ok((atoms::ok(), resource).encode(env))
}


fn repo_list_branches<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let repo_arc: ResourceArc<MyRepo> = args[0].decode()?;
    let repo_handle = repo_arc.deref();
    let repo_wrapper = repo_handle.repo.read().unwrap();
    let RepoWrapper(ref repo) = *repo_wrapper;

    let branches = match repo.branches(Some(BranchType::Local)) {
            Ok(branches) => branches,
            Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };
    let mut v: Vec<(String, NifAtom)> = Vec::new();
    for (i, elem) in branches.enumerate() {
        let b = match elem {
            Ok(b) => b,
            Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
        };
        let (branch, btype) = b;
        let branch_name = match branch.name() {
            Ok(b_name) => b_name,
            Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
        };
        let branch_name = match branch_name {
            Some(v) => v,
            None => return Ok((atoms::error(), 2).encode(env)),
        };
        if btype == BranchType::Local {
            v.push((String::from(branch_name), atoms::local()));
        } else {
            v.push((String::from(branch_name), atoms::remote()));
        }
    }

    Ok((atoms::ok(), v).encode(env))
}

fn repo_workdir<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let repo_arc: ResourceArc<MyRepo> = args[0].decode()?;
    let repo_handle = repo_arc.deref();
    let repo_wrapper = repo_handle.repo.read().unwrap();
    let RepoWrapper(ref repo) = *repo_wrapper;

    let path = repo.workdir().unwrap().to_path_buf().into_os_string().into_string().unwrap();
    Ok((atoms::ok(), path).encode(env))
}

fn add<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let num1: i64 = try!(args[0].decode());
    let num2: i64 = try!(args[1].decode());

    Ok((atoms::ok(), num1 + num2).encode(env))
}
