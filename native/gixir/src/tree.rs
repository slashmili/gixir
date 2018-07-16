use git2::ObjectType;

use repository::RepositoryResource;
use std::borrow::Borrow;

use rustler::{Encoder, Env, NifResult, Term};
use rustler::types::atom::Atom;
use rustler::resource::ResourceArc;
use index::OidResource;

mod atoms {
    rustler_atoms! {
        atom ok;
        atom error;
        atom any;
        atom tree;
        atom blob;
    }
}

pub fn get_by_oid<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let repo_arc: ResourceArc<RepositoryResource> = args[0].decode()?;
    let repo_resource = repo_arc.borrow();
    let repo = &repo_resource.repo;
    let oid_arc: ResourceArc<OidResource> = try!(args[1].decode());

    let mut v: Vec<(String, String, i32, Atom)> = Vec::new();

    let tree = match repo.find_tree(oid_arc.oid) {
        Ok(tree) => tree,
        Err(e) => return Ok((atoms::error(), (e.raw_code(), e.message().to_string())).encode(env)),
    };

    for item in tree.iter() {
        let name = match item.name() {
            Some(name) => String::from(name),
            None => String::from(""),
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
        v.push((name, oid_hex, item.filemode(), atom_kind));
    }

    Ok((atoms::ok(), v).encode(env))
}
