#[macro_use]
extern crate lazy_static;
#[macro_use]
extern crate rustler;

extern crate git2;

use rustler::{Encoder, Env, NifResult, Term};

mod repository;
mod index;
mod commit;
mod signature;
mod tree;

mod atoms {
    rustler_atoms! {
        atom ok;
        //atom error;
        //atom __true__ = "true";
        //atom __false__ = "false";
    }
}

rustler_export_nifs! {
    "Elixir.Gixir.Nif",
    [
        ("add", 2, add),
        ("repository_init_at", 2, repository::init_at),
        ("repository_open", 1, repository::open),
        ("repository_index", 1, repository::index),
        ("index_add_bypath", 2, index::add_bypath),
        ("index_write_tree", 1, index::write_tree),
        ("index_write", 1, index::write),
        ("commit_create", 7, commit::create),
        ("commit_tree", 2, commit::tree),
    ],
    Some(on_load)
}

fn on_load<'a>(env: Env<'a>, _load_info: Term<'a>) -> bool {
    resource_struct_init!(repository::RepositoryResource, env);
    resource_struct_init!(index::IndexResource, env);
    resource_struct_init!(index::OidResource, env);
    true
}

fn add<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let num1: i64 = try!(args[0].decode());
    let num2: i64 = try!(args[1].decode());

    Ok((atoms::ok(), num1 + num2).encode(env))
}
