use git2::Index;

pub struct IndexResource {
    pub index: Index,
}

unsafe impl Send for IndexResource {}
unsafe impl Sync for IndexResource {}
