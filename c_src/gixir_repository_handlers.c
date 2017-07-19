#include "gixir_handlers.h"
#include "git2_headers.h"
#include "gixir_vars.h"

/*
 * {repo_path, bool}
 */
void handle_repository_init_at(const char *req, int *req_index) {

    int term_size;
    if (ei_decode_tuple_header(req, req_index, &term_size) < 0 ||
            term_size != 2) {
        //debug("Failed to parse connect params");
        send_error_response("wrong_number_of_args");
        return;
    }

    int term_type;
    if (ei_get_type(req, req_index, &term_type, &term_size) < 0 ||
            term_type != ERL_BINARY_EXT) {
        send_error_response("cannot_parse_path");
        return;
    }
    char *repo_path = malloc(term_size);
    int error = 0;


    long binary_len = 0;
    if (ei_decode_binary(req, req_index, repo_path, &binary_len) < 0) {
        send_error_response("cannot_read_path");
        return;
    }
    repo_path[term_size] = '\0';

    global_repo_path = malloc(term_size);
    memcpy(global_repo_path, repo_path, term_size);
    int bare = 0;
    if(ei_decode_boolean(req, req_index, &bare) <0) {
        send_error_response("cannot_read_bare");
    }
    error = git_repository_init(&global_repo, repo_path, bare);
    if (error < 0) {
        const git_error *e = giterr_last();
        send_error_response_with_message("repository_init_at", e->message);
        return;
    }

    char resp[256];
    int resp_index = sizeof(uint16_t);
    resp[resp_index++] = response_id;
    ei_encode_version(resp, &resp_index);
    ei_encode_atom(resp, &resp_index, "ok");
    erlcmd_send(resp, resp_index);

    free(repo_path);
}

void handle_repository_open(const char *req, int *req_index) {

    int term_size;
    if (ei_decode_tuple_header(req, req_index, &term_size) < 0 ||
            term_size != 1) {
        //debug("Failed to parse connect params");
        send_error_response("wrong_number_of_args");
        return;
    }

    int term_type;
    if (ei_get_type(req, req_index, &term_type, &term_size) < 0 ||
            term_type != ERL_BINARY_EXT) {
        send_error_response("cannot_parse_path");
        return;
    }
    char *repo_path = malloc(term_size);
    int error = 0;


    long binary_len = 0;
    if (ei_decode_binary(req, req_index, repo_path, &binary_len) < 0) {
        send_error_response("cannot_read_path");
        return;
    }

    global_repo_path = malloc(term_size);
    memcpy(global_repo_path, repo_path, term_size);

    error = git_repository_open(&global_repo, repo_path);
    if (error < 0) {
        const git_error *e = giterr_last();
        send_error_response_with_message("repository_open", e->message);
        return;
    }

    char resp[256];
    int resp_index = sizeof(uint16_t);
    resp[resp_index++] = response_id;
    ei_encode_version(resp, &resp_index);
    ei_encode_atom(resp, &resp_index, "ok");
    erlcmd_send(resp, resp_index);

    free(repo_path);
}

void handle_repository_list_branches(const char *req, int *req_index) {

    int term_size;
    if (ei_decode_tuple_header(req, req_index, &term_size) < 0 ||
            term_size != 0) {
        send_error_response("wrong_number_of_args");
        return;
    }

    int error = 0;
    git_branch_iterator *iter;
    int exception = 0;
    //TODO: pass barnch type filter from elixir
    git_branch_t filter = (GIT_BRANCH_LOCAL | GIT_BRANCH_REMOTE), branch_type;
    if (git_branch_iterator_new(&iter, global_repo, filter) < 0) {
        const git_error *e = giterr_last();
        send_error_response_with_message("branch_iterator", e->message);
        return;
    }
    git_reference *branch;
    int branches_size = 0;


    while (!exception && (error = git_branch_next(&branch, &branch_type, iter)) == GIT_OK) {
        git_reference_free(branch);
        branches_size ++;
    }

    git_branch_iterator_free(iter);
    if (git_branch_iterator_new(&iter, global_repo, filter) < 0) {
        const git_error *e = giterr_last();
        send_error_response_with_message("branch_iterator", e->message);
        return;
    }


    //TODO: return list of branch names
    char resp[10000];
    int resp_index = sizeof(uint16_t);
    resp[resp_index++] = response_id;

    ei_encode_version(resp, &resp_index);

    ei_encode_tuple_header(resp, &resp_index, 2);
    ei_encode_atom(resp, &resp_index, "ok");

    ei_encode_list_header(resp, &resp_index, branches_size);
    while (!exception && (error = git_branch_next(&branch, &branch_type, iter)) == GIT_OK) {
        const char * branch_name  = git_reference_shorthand(branch);
        ei_encode_tuple_header(resp, &resp_index, 2);
        ei_encode_binary(resp, &resp_index, branch_name, strlen(branch_name));
        if (branch_type == GIT_BRANCH_LOCAL) {
            ei_encode_atom(resp, &resp_index, "local");
        }else if (branch_type == GIT_BRANCH_REMOTE) {
            ei_encode_atom(resp, &resp_index, "remote");
        }
        git_reference_free(branch);
    }
    ei_encode_empty_list(resp, &resp_index);
    erlcmd_send(resp, resp_index);

    git_branch_iterator_free(iter);
}

void handle_repository_lookup_branch(const char *req, int *req_index) {

    int term_size;
    if (ei_decode_tuple_header(req, req_index, &term_size) < 0 ||
            term_size != 2) {
        send_error_response("wrong_number_of_args");
        return;
    }

    int term_type;
    if (ei_get_type(req, req_index, &term_type, &term_size) < 0 ||
            term_type != ERL_BINARY_EXT) {
        send_error_response("cannot_parse_path");
        return;
    }

    //read branch name
    if (ei_get_type(req, req_index, &term_type, &term_size) < 0 ||
            term_type != ERL_BINARY_EXT) {
        send_error_response("cannot_parse_name");
        return;
    }
    char *branch_name = malloc(term_size);


    long binary_len;
    if (ei_decode_binary(req, req_index, branch_name, &binary_len) < 0) {
        send_error_response("cannot_read_name");
        return;
    }
    branch_name[term_size] = '\0';

    git_reference *branch = NULL;
    if(git_branch_lookup(&branch, global_repo, branch_name, GIT_BRANCH_LOCAL) < 0) {
        const git_error *e = giterr_last();
        send_error_response_with_message("lookup_branch", e->message);
        return;
    }

    //TODO: return list of branch names
    char resp[256];
    int resp_index = sizeof(uint16_t);
    resp[resp_index++] = response_id;

    ei_encode_version(resp, &resp_index);

    ei_encode_atom(resp, &resp_index, "ok");

    erlcmd_send(resp, resp_index);
}

void handle_repository_workdir(const char *req, int *req_index) {

    int term_size;
    if (ei_decode_tuple_header(req, req_index, &term_size) < 0 ||
            term_size != 0) {
        send_error_response("wrong_number_of_args");
        return;
    }

    if(git_repository_is_bare(global_repo)) {
        send_error_response("repo_is_bare");
        return;
    }
    char resp[256];
    int resp_index = sizeof(uint16_t);
    resp[resp_index++] = response_id;

    ei_encode_version(resp, &resp_index);

    ei_encode_tuple_header(resp, &resp_index, 2);
    ei_encode_atom(resp, &resp_index, "ok");

    ei_encode_binary(resp, &resp_index, global_repo_path, strlen(global_repo_path));

    erlcmd_send(resp, resp_index);
}
