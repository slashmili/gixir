use git2::Repository;

use index::IndexResource;

use rustler::{Encoder, Env, NifResult, Term};
use rustler::resource::ResourceArc;

use std::sync::RwLock;
mod atoms {
    rustler_atoms! {
        atom ok;
        atom error;
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
