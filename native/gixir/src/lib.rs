#[macro_use] extern crate rustler;
#[macro_use] extern crate rustler_codegen;
#[macro_use] extern crate lazy_static;

extern crate git2;

use rustler::{NifEnv, NifTerm, NifResult, NifEncoder, NifError};
use rustler::types::list::NifListIterator;
use rustler::types::atom::NifAtom;
use git2::{Repository, Branch, Branches, BranchType, Index, Reference, Oid, Tree, ObjectType, Signature, Time, Commit};
use rustler::resource::ResourceArc;
use std::sync::{RwLock,Arc};
use std::ops::Deref;
use std::io;
use std::path::Path;

mod atoms {
    rustler_atoms! {
        atom ok;
        atom error;
        atom pong;
        atom local;
        atom remote;
        atom branch;
        atom tag;
        atom note;
        atom unknown;
        atom blob;
        atom any;
        atom tree;
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
    ("repo_lookup_branch", 3, repo_lookup_branch),
    ("repo_head", 1, repo_head),
    ("index_new", 1, index_new),
    ("index_add_bypath", 2, index_add_bypath),
    ("index_write_tree", 1, index_write_tree),
    ("index_write", 1, index_write),
    ("commit_create", 2, commit_create),
    ("commit_lookup", 2, commit_lookup),
    ("commit_get_message", 2, commit_get_message),
    ("commit_get_tree_oid", 2, commit_get_tree_oid),
    ("tree_lookup", 2, tree_lookup),
    ("tree_lookup_bypath", 3, tree_lookup_bypath),
    ("ping", 0, ping)],
    Some(on_load)
}


pub struct RepoWrapper(Repository);
pub struct IndexWrapper(Index);

unsafe impl Sync for RepoWrapper { }
unsafe impl Sync for IndexWrapper { }
unsafe impl Send for IndexWrapper { }


pub struct MyRepo {
    pub repo: Arc<RwLock<RepoWrapper>>,
}

pub struct GixirIndex {
    pub index: Arc<RwLock<IndexWrapper>>,
}

fn on_load<'a>(env: NifEnv<'a>, _load_info: NifTerm<'a>) -> bool {
    resource_struct_init!(MyRepo, env);
    resource_struct_init!(GixirIndex, env);
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
    let mut v: Vec<(String, NifAtom, String)> = Vec::new();
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

        let reference = branch.get();

        let target = match reference.target() {
            Some(v) => format!("{}", v),
            None => return Ok((atoms::error(), 3).encode(env)),
        };

        if btype == BranchType::Local {
            v.push((String::from(branch_name), atoms::local(), target));
        } else {
            v.push((String::from(branch_name), atoms::remote(), target));
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

fn repo_lookup_branch<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let repo_arc: ResourceArc<MyRepo> = args[0].decode()?;
    let repo_handle = repo_arc.deref();
    let repo_wrapper = repo_handle.repo.read().unwrap();
    let RepoWrapper(ref repo) = *repo_wrapper;


    let branch_name: String = try!(args[1].decode());
    let branch_type: NifAtom = try!(args[2].decode());

    let btype = if branch_type == atoms::local() {
        BranchType::Local
    } else {
        BranchType::Remote
    };

    let branch = match repo.find_branch(&branch_name, btype) {
        Ok(branch) => branch,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };

    let branch_name = match branch.name().unwrap() {
        Some(v) => v,
        None => return Ok((atoms::error(), 2).encode(env)),
    };

    let reference = branch.get();

    let target = match reference.target() {
        Some(v) => format!("{}", v),
        None => return Ok((atoms::error(), 3).encode(env)),
    };

    Ok((atoms::ok(), target).encode(env))
}


fn repo_head<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let repo_arc: ResourceArc<MyRepo> = args[0].decode()?;
    let repo_handle = repo_arc.deref();
    let repo_wrapper = repo_handle.repo.read().unwrap();
    let RepoWrapper(ref repo) = *repo_wrapper;

    let reference = match repo.head() {
        Ok(reference) => reference,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };

    let ref_name = match reference.name() {
        Some(v) => String::from(v),
        None => String::from(""),
    };

    let ref_shorthand = match reference.shorthand() {
        Some(v) => String::from(v),
        None => String::from(""),
    };

    let target = match reference.target() {
        Some(v) => format!("{}", v),
        None => return Ok((atoms::error(), 3).encode(env)),
    };

    let ref_type = if reference.is_branch() {
        atoms::branch()
    } else if reference.is_remote() {
        atoms::remote()
    } else if reference.is_note() {
        atoms::note()
    } else if reference.is_tag() {
        atoms::tag()
    } else {
        atoms::unknown()
    };

    Ok((atoms::ok(), (ref_name, ref_shorthand), target, ref_type).encode(env))
}

fn index_new<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let repo_arc: ResourceArc<MyRepo> = args[0].decode()?;
    let repo_handle = repo_arc.deref();
    let repo_wrapper = repo_handle.repo.read().unwrap();
    let RepoWrapper(ref repo) = *repo_wrapper;
    let index = match repo.index() {
        Ok(index) => index,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };

    let resource = ResourceArc::new(GixirIndex{
        index: Arc::new(RwLock::new(IndexWrapper(index))),
    });

    Ok((atoms::ok(), resource).encode(env))
}


fn index_add_bypath<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let index_arc: ResourceArc<GixirIndex> = args[0].decode()?;
    let file_path : String = try!(args[1].decode());
    let index_handle = index_arc.deref();
    let mut index_wrapper = index_handle.index.write().unwrap();
    let IndexWrapper(ref mut index) = *index_wrapper;

    index.add_path(Path::new(&file_path));
    Ok(atoms::ok().encode(env))
}

fn index_write_tree<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let index_arc: ResourceArc<GixirIndex> = args[0].decode()?;
    let index_handle = index_arc.deref();
    let mut index_wrapper = index_handle.index.write().unwrap();
    let IndexWrapper(ref mut index) = *index_wrapper;

    let oid = match index.write_tree() {
        Ok(oid) => oid,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };
    let oid_hex = format!("{}", oid);
    Ok((atoms::ok(), oid_hex).encode(env))
}

fn index_write<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let index_arc: ResourceArc<GixirIndex> = args[0].decode()?;
    let index_handle = index_arc.deref();
    let mut index_wrapper = index_handle.index.write().unwrap();
    let IndexWrapper(ref mut index) = *index_wrapper;

    let oid = match index.write() {
        Ok(oid) => oid,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };
    Ok(atoms::ok().encode(env))
}

fn commit_create<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let repo_arc: ResourceArc<MyRepo> = args[0].decode()?;
    let repo_handle = repo_arc.deref();
    let repo_wrapper = repo_handle.repo.read().unwrap();
    let RepoWrapper(ref repo) = *repo_wrapper;
    let (update_ref, message, author_tuple, committer, oid_str, parents_iter) : (String, String, (String, String, i64, i32), (String, String, i64, i32), String, NifListIterator) = args[1].decode()?;

    let parents_result: Result<Vec<String>, NifError> = parents_iter
        .map(|x| x.decode::<String>())
        .collect();

    let parents = match parents_result {
        Ok(parents) => parents,
        Err(e) => return Ok((atoms::error(), -1).encode(env)),
    };

    let mut parent_commits: Vec<::Commit> = Vec::new();
    for p in parents {
        let oid  = match Oid::from_str(&p) {
            Ok(oid) => oid,
            Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),

        };

        let commit = match repo.find_commit(oid) {
            Ok(commit) => commit,
            Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
        };
        parent_commits.push(commit);
    }

    let (author_name, author_email, time, offset) : (String, String, i64, i32) = author_tuple;
    let author_time = git2::Time::new(time, offset);
    let author = match Signature::new(&author_name, &author_email, &author_time) {
        Ok(author) => author,
        Err(e) => return Ok((atoms::error(), -2).encode(env)),
    };

    let oid  = match Oid::from_str(&oid_str) {
        Ok(oid) => oid,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };

    let tree = match repo.find_tree(oid) {
        Ok(tree) => tree,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };

    let parent_slice = [];
    let commit_id = match repo.commit(Some(&update_ref), &author, &author, &message, &tree, &parent_slice) {
        Ok(commit) => commit,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };

    let commit = match repo.find_commit(commit_id) {
        Ok(commit) => commit,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };

    let commit_id = format!("{}", commit_id);
    let tree_id = format!("{}", commit.tree_id());
    Ok((atoms::ok(), commit_id, tree_id).encode(env))
}
fn commit_lookup<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let repo_arc: ResourceArc<MyRepo> = args[0].decode()?;
    let repo_handle = repo_arc.deref();
    let repo_wrapper = repo_handle.repo.read().unwrap();
    let RepoWrapper(ref repo) = *repo_wrapper;
    let oid_str = try!(args[1].decode());
    let oid  = match Oid::from_str(oid_str) {
        Ok(oid) => oid,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),

    };

    let commit = match repo.find_commit(oid) {
        Ok(commit) => commit,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };

    Ok(atoms::ok().encode(env))
}


fn commit_get_message<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let repo_arc: ResourceArc<MyRepo> = args[0].decode()?;
    let repo_handle = repo_arc.deref();
    let repo_wrapper = repo_handle.repo.read().unwrap();
    let RepoWrapper(ref repo) = *repo_wrapper;
    let oid_str = try!(args[1].decode());
    let oid  = match Oid::from_str(oid_str) {
        Ok(oid) => oid,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),

    };

    let commit = match repo.find_commit(oid) {
        Ok(commit) => commit,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };

    let message = match commit.message() {
        Some(msg) => String::from(msg),
        None => String::from(""),
    };

    Ok((atoms::ok(), message).encode(env))
}

fn commit_get_tree_oid<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let repo_arc: ResourceArc<MyRepo> = args[0].decode()?;
    let repo_handle = repo_arc.deref();
    let repo_wrapper = repo_handle.repo.read().unwrap();
    let RepoWrapper(ref repo) = *repo_wrapper;
    let oid_str = try!(args[1].decode());
    let oid  = match Oid::from_str(oid_str) {
        Ok(oid) => oid,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),

    };

    let commit = match repo.find_commit(oid) {
        Ok(commit) => commit,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };

    let tree_oid = format!("{}", commit.tree_id());

    Ok((atoms::ok(), tree_oid).encode(env))
}

fn tree_lookup<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let repo_arc: ResourceArc<MyRepo> = args[0].decode()?;
    let repo_handle = repo_arc.deref();
    let repo_wrapper = repo_handle.repo.read().unwrap();
    let RepoWrapper(ref repo) = *repo_wrapper;
    let oid_str = try!(args[1].decode());
    let oid  = match Oid::from_str(oid_str) {
        Ok(oid) => oid,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),

    };

    let tree = match repo.find_tree(oid) {
        Ok(tree) => tree,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };

	let mut v: Vec<(String, String, i32, NifAtom)> = Vec::new();
	let filemode = 33188;
	for item in tree.iter() {
		let name = match item.name() {
			Some(name) => String::from(name),
			None => String::from("")
		};
		let oid_hex = format!("{}", item.id());
		let kind = match item.kind() {
			Some(kind) => kind,
			None => ObjectType::Any,
		};
		let atom_kind = if kind == ObjectType::Blob {
			atoms::blob()
		} else if kind == ObjectType::Tree {
			atoms::tree()
		} else {
			atoms::any()
		};
		v.push((name, oid_hex, filemode, atom_kind));
	}

    Ok((atoms::ok(), v).encode(env))
}

fn tree_lookup_bypath<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let repo_arc: ResourceArc<MyRepo> = args[0].decode()?;
    let repo_handle = repo_arc.deref();
    let repo_wrapper = repo_handle.repo.read().unwrap();
    let RepoWrapper(ref repo) = *repo_wrapper;

    let oid_str = try!(args[1].decode());
    let path: String = try!(args[2].decode());

    let oid  = match Oid::from_str(oid_str) {
        Ok(oid) => oid,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),

    };

    let tree = match repo.find_tree(oid) {
        Ok(tree) => tree,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };

    let tree_entry = match tree.get_path(Path::new(&path)) {
        Ok(tree_entry) => tree_entry,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };
    let filemode = 33188;
    if tree_entry.kind() == Some(ObjectType::Blob) {
        let name = match tree_entry.name() {
            Some(name) => String::from(name),
            None => String::from("")
        };

		let oid_hex = format!("{}", tree_entry.id());
        return Ok((atoms::ok(), (name, oid_hex, filemode, atoms::blob())).encode(env))
    } else if tree_entry.kind() == Some(ObjectType::Tree) {


        let tree = match repo.find_tree(tree_entry.id()) {
            Ok(tree) => tree,
            Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
        };

		let tree_oid_hex = format!("{}", tree.id());

        let mut v: Vec<(String, String, i32, NifAtom)> = Vec::new();
        for item in tree.iter() {
            let name = match item.name() {
                Some(name) => String::from(name),
                None => String::from("")
            };
            let oid_hex = format!("{}", item.id());
            let kind = match item.kind() {
                Some(kind) => kind,
                None => ObjectType::Any,
            };
            let atom_kind = if kind == ObjectType::Blob {
                atoms::blob()
            } else if kind == ObjectType::Tree {
                atoms::tree()
            } else {
                atoms::any()
            };
            v.push((name, oid_hex, filemode, atom_kind));
        }

        return Ok((atoms::ok(), tree_oid_hex, v).encode(env))
    }

    Ok(atoms::error().encode(env))
}

fn add<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let num1: i64 = try!(args[0].decode());
    let num2: i64 = try!(args[1].decode());

    Ok((atoms::ok(), num1 + num2).encode(env))
}
