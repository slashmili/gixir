use git2::Commit;

use repository::RepositoryResource;

use rustler::{Encoder, Env, Error, NifResult, Term};
use rustler::types::list::ListIterator;
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
    let parents_list_iter: ListIterator = try!(args[5].decode());
    let update_ref: Option<&str> = match args[6].decode() {
        Ok(update_ref) => update_ref,
        Err(_) => None,
    };

    let tree = match repo.find_tree(oid_arc.oid) {
        Ok(tree) => tree,
        Err(e) => return Ok((atoms::error(), (e.raw_code(), e.message().to_string())).encode(env)),
    };

    let git_author = match author.to_git() {
        Ok(sig) => sig,
        Err(_) => return Ok((atoms::error(), 1).encode(env)),
    };

    let git_commiter = match commiter.to_git() {
        Ok(sig) => sig,
        Err(e) => return Ok((atoms::error(), (e.raw_code(), e.message().to_string())).encode(env)),
    };

    let parents_result: Result<Vec<ResourceArc<OidResource>>, Error> = parents_list_iter
        .map(|x| x.decode::<ResourceArc<OidResource>>())
        .collect();

    let parents = match parents_result {
        Ok(parents) => parents,
        Err(e) => return Err(e),
    };

    let mut parent_commits: Vec<Commit> = vec![];
    for p in parents {
        let commit = match repo.find_commit(p.oid) {
            Ok(commit) => commit,
            Err(e) => {
                return Ok((atoms::error(), (e.raw_code(), e.message().to_string())).encode(env))
            }
        };
        parent_commits.push(commit);
    }

    let parents = parent_commits.iter().map(|x| x).collect::<Vec<_>>();
    let parents = parents.as_slice();
    let commit_id = match repo.commit(
        update_ref,
        &git_author,
        &git_commiter,
        &message,
        &tree,
        parents,
    ) {
        Ok(commit) => commit,
        Err(e) => return Ok((atoms::error(), (e.raw_code(), e.message().to_string())).encode(env)),
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
