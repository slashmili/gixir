#include "git2_headers.h"
git_repository *global_repo;
char *global_repo_path;

void gixir_set_repository(git_repository *repo) {
    global_repo = repo;
}
