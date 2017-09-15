#[macro_use] extern crate rustler;
#[macro_use] extern crate rustler_codegen;
#[macro_use] extern crate lazy_static;

extern crate git2;

use rustler::{NifEnv, NifTerm, NifResult, NifEncoder};
use git2::Repository;
use rustler::resource::ResourceArc;
use std::sync::{RwLock,Arc};

mod atoms {
    rustler_atoms! {
        atom ok;
        atom error;
        atom pong;
        //atom __true__ = "true";
        //atom __false__ = "false";
    }
}

rustler_export_nifs! {
    "Elixir.Gixir.Nif",
    [("add", 2, add),
    ("repo_init_at", 2, repo_init_at),
    ("repo_open", 1, repo_open),
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

fn add<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let num1: i64 = try!(args[0].decode());
    let num2: i64 = try!(args[1].decode());

    Ok((atoms::ok(), num1 + num2).encode(env))
}
