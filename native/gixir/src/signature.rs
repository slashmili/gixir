use rustler::{Env, Term};

use git2::{Error, Time};
use git2::Signature as GitSignature;

mod atoms {
    rustler_atoms! {
        atom email;
        atom name;
        atom timestamp;
        atom offset;
    }
}

#[derive(Debug)]
pub struct Signature {
    name: String,
    email: String,
    timestamp: i64,
    offset: i32,
}

pub fn from_term<'a>(env: Env<'a>, term: Term<'a>) -> Signature {
    let email_atom = atoms::email().to_term(env);
    let email: String = match term.map_get(email_atom) {
        Ok(email_term) => match email_term.decode() {
            Ok(email) => email,
            _ => "".to_string(),
        },
        Err(_) => "".to_string(),
    };
    let name_atom = atoms::name().to_term(env);
    let name: String = match term.map_get(name_atom) {
        Ok(name_term) => match name_term.decode() {
            Ok(name) => name,
            _ => "".to_string(),
        },
        Err(_) => "".to_string(),
    };

    let timestamp_atom = atoms::timestamp().to_term(env);
    let timestamp: i64 = match term.map_get(timestamp_atom) {
        Ok(timestamp_term) => match timestamp_term.decode() {
            Ok(timestamp) => timestamp,
            _ => 0,
        },
        Err(_) => 0,
    };

    let offset_atom = atoms::offset().to_term(env);
    let offset: i32 = match term.map_get(offset_atom) {
        Ok(offset_term) => match offset_term.decode() {
            Ok(offset) => offset,
            _ => 0,
        },
        Err(_) => 0,
    };
    Signature {
        name: name,
        email: email,
        timestamp: timestamp,
        offset: offset,
    }
}

impl Signature {
    pub fn to_git(self: &Signature) -> Result<GitSignature<'static>, Error> {
        let time = Time::new(self.timestamp, self.offset);
        GitSignature::new(&self.name, &self.email, &time)
    }
}
