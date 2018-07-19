use git2::{BranchType, Repository};

use index::IndexResource;

use rustler::{Encoder, Env, NifResult, Term};
use rustler::resource::ResourceArc;
use rustler::types::atom::Atom;

use std::sync::RwLock;
mod atoms {
    rustler_atoms! {
        atom ok;
        atom error;
        atom remote;
        atom local;
    }
}

pub struct RepositoryResource {
    pub repo: Repository,
}

unsafe impl Send for RepositoryResource {}
unsafe impl Sync for RepositoryResource {}

pub fn init_at<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let path: String = try!(args[0].decode());
    let bare: bool = try!(args[1].decode());

    let repo = if bare {
        match Repository::init_bare(path) {
            Ok(repo) => repo,
            Err(e) => {
                return Ok((atoms::error(), (e.raw_code(), e.message().to_string())).encode(env))
            }
        }
    } else {
        match Repository::init(path) {
            Ok(repo) => repo,
            Err(e) => {
                return Ok((atoms::error(), (e.raw_code(), e.message().to_string())).encode(env))
            }
        }
    };

    let repo = ResourceArc::new(RepositoryResource { repo: repo });
    Ok((atoms::ok(), repo).encode(env))
}

pub fn open<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let path: String = try!(args[0].decode());
    let repo = match Repository::open(path) {
        Ok(repo) => repo,
        Err(e) => return Ok((atoms::error(), (e.raw_code(), e.message().to_string())).encode(env)),
    };

    let repo = ResourceArc::new(RepositoryResource { repo: repo });
    Ok((atoms::ok(), repo).encode(env))
}

pub fn index<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let repo_arc: ResourceArc<RepositoryResource> = try!(args[0].decode());
    let repo = &repo_arc.repo;
    let index = match repo.index() {
        Ok(index) => index,
        Err(e) => return Ok((atoms::error(), (e.raw_code(), e.message().to_string())).encode(env)),
    };
    let index = ResourceArc::new(IndexResource {
        index: RwLock::new(index),
    });
    Ok((atoms::ok(), index).encode(env))
}

pub fn branches<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let repo_arc: ResourceArc<RepositoryResource> = try!(args[0].decode());
    let repo = &repo_arc.repo;
    let branches = match repo.branches(None) {
        Ok(branches) => branches,
        Err(e) => return Ok((atoms::error(), (e.raw_code(), e.message().to_string())).encode(env)),
    };

    let mut branch_vec: Vec<(String, Atom)> = Vec::new();
    for (_i, elem) in branches.enumerate() {
        let b = match elem {
            Ok(b) => b,
            Err(e) => {
                return Ok((atoms::error(), (e.raw_code(), e.message().to_string())).encode(env))
            }
        };
        let (branch, btype) = b;
        let branch_name = match branch.name() {
            Ok(b_name) => b_name,
            Err(e) => {
                return Ok((atoms::error(), (e.raw_code(), e.message().to_string())).encode(env))
            }
        };
        let branch_name = match branch_name {
            Some(v) => v,
            None => {
                return Ok((atoms::error(), (-100, "cant find branch name".to_string())).encode(env))
            }
        };

        if btype == BranchType::Local {
            branch_vec.push((String::from(branch_name), atoms::local()));
        } else {
            branch_vec.push((String::from(branch_name), atoms::remote()));
        }
    }

    Ok((atoms::ok(), branch_vec).encode(env))
}
