use git2::{Index, Oid};

use rustler::{Encoder, Env, NifResult, Term};
use rustler::resource::ResourceArc;
use std::path::Path;
use std::sync::RwLock;

mod atoms {
    rustler_atoms! {
        atom ok;
        atom error;
    }
}

pub struct IndexResource {
    pub index: RwLock<Index>,
}

pub struct OidResource {
    pub oid: Oid,
}

unsafe impl Send for IndexResource {}
unsafe impl Sync for IndexResource {}

pub fn add_bypath<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let index_arc: ResourceArc<IndexResource> = try!(args[0].decode());
    let file_path: String = try!(args[1].decode());
    let mut index = index_arc.index.write().unwrap();
    let result = match index.add_path(Path::new(&file_path)) {
        Err(e) => return Ok((atoms::error(), (e.raw_code(), e.message().to_string())).encode(env)),
        _ => atoms::ok(),
    };
    Ok((result).encode(env))
}

pub fn write_tree<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let index_arc: ResourceArc<IndexResource> = try!(args[0].decode());
    let mut index = index_arc.index.write().unwrap();

    let oid = match index.write_tree() {
        Ok(oid) => oid,
        Err(e) => return Ok((atoms::error(), (e.raw_code(), e.message().to_string())).encode(env)),
    };

    let oid = ResourceArc::new(OidResource { oid: oid });
    Ok((atoms::ok(), oid).encode(env))
}
