#include <stdint.h>

void handle_repository_init_at(const char *req, int *req_index);
void handle_repository_open(const char *req, int *req_index);
void handle_repository_list_branches(const char *req, int *req_index);
void handle_repository_branches(const char *req, int *req_index);
void handle_repository_lookup_branch(const char *req, int *req_index);
