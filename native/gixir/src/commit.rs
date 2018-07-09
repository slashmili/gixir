//use git2::{Index, Oid};

use repository::RepositoryResource;

use rustler::{Encoder, Env, NifResult, Term};
use rustler::resource::ResourceArc;
use index::OidResource;

use signature;
mod atoms {
    rustler_atoms! {
        atom ok;
        atom error;
    }
}

pub fn create<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let repo_arc: ResourceArc<RepositoryResource> = try!(args[0].decode());
    let repo = &repo_arc.repo;
    let author = signature::from_term(env, try!(args[1].decode()));
    let commiter = signature::from_term(env, try!(args[2].decode()));
    let message: String = try!(args[3].decode());
    let oid_arc: ResourceArc<OidResource> = try!(args[4].decode());

    let tree = match repo.find_tree(oid_arc.oid) {
        Ok(tree) => tree,
        Err(e) => return Ok((atoms::ok(), e.raw_code()).encode(env)),
    };

    let git_author = match author.to_git() {
        Ok(sig) => sig,
        Err(_) => return Ok((atoms::error(), 1).encode(env)),
    };

    let git_commiter = match commiter.to_git() {
        Ok(sig) => sig,
        Err(_) => return Ok((atoms::error(), 1).encode(env)),
    };

    let parent_slice = [];
    let commit_id = match repo.commit(
        Some("HEAD"),
        &git_author,
        &git_commiter,
        &message,
        &tree,
        &parent_slice,
    ) {
        Ok(commit) => commit,
        Err(e) => return Ok((atoms::error(), e.raw_code()).encode(env)),
    };

    let oid = ResourceArc::new(OidResource { oid: commit_id });
    Ok((atoms::ok(), oid).encode(env))
}

pub fn tree<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let repo_arc: ResourceArc<RepositoryResource> = try!(args[0].decode());
    let repo = repo_arc;
    let repo = &repo.repo;
    let oid_arc: ResourceArc<OidResource> = try!(args[1].decode());

    let commit = match repo.find_commit(oid_arc.oid) {
        Ok(commit) => commit,
        Err(e) => return Ok((atoms::error(), (e.raw_code(), e.message().to_string())).encode(env)),
    };

    let oid = ResourceArc::new(OidResource {
        oid: commit.tree_id(),
    });

    Ok((atoms::ok(), oid).encode(env))
}
