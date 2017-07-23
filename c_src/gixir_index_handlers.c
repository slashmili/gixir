#include "gixir_handlers.h"
#include "git2_headers.h"
#include "gixir_vars.h"

static git_index * local_index;

void handle_index_new(const char *req, int *req_index) {
    char * resp;
    int resp_index = sizeof(uint16_t);
    if(erl_decode_validate_number_args(req, req_index, 0) <0 ) {
        send_error_response("wrong_number_of_args");
        return;
    }

    git_index_new(&local_index);

    resp = malloc(1000);
    resp[resp_index++] = response_id;
    ei_encode_version(resp, &resp_index);
    ei_encode_tuple_header(resp, &resp_index, 2);
    ei_encode_atom(resp, &resp_index, "ok");
    ei_encode_long(resp, &resp_index, 1);

    erlcmd_send(resp, resp_index);
    free(resp);
}

/*
 * {file_path}
*/
void handle_index_add_bypath(const char *req, int *req_index) {
    char * resp;
    char * file_path = NULL;
    int resp_index = sizeof(uint16_t);
    long binary_len;

    if(erl_decode_validate_number_args(req, req_index, 2) <0 ) {
        send_error_response("wrong_number_of_args");
        return;
    }

    if (erl_validate_and_decode_string(req, req_index, &file_path, &binary_len) < 0) {
        send_error_response("cannot_read_file_path");
        return;
    }

    if(git_repository_index(&local_index, global_repo) < 0) {
        send_git_error_response_with_message("git_repository_index");
        return;
    }

    if(git_index_add_bypath(local_index, file_path) < 0) {
        send_git_error_response_with_message("git_index_add_bypath");
        return;
    }

    resp = malloc(1000);
    resp[resp_index++] = response_id;
    ei_encode_version(resp, &resp_index);
    ei_encode_atom(resp, &resp_index, "ok");

    erlcmd_send(resp, resp_index);
    free(resp);
}


void handle_index_write_tree(const char *req, int *req_index) {
    char * resp;
    int resp_index = sizeof(uint16_t);
    char tree_id_str[40];

    if(erl_decode_validate_number_args(req, req_index, 1) <0 ) {
        send_error_response("wrong_number_of_args");
        return;
    }

    git_oid tree_id;
    git_index_write_tree(&tree_id, local_index);

    git_oid_fmt(tree_id_str, &tree_id);

    resp = malloc(1000);
    resp[resp_index++] = response_id;
    ei_encode_version(resp, &resp_index);
    ei_encode_tuple_header(resp, &resp_index, 2);
    ei_encode_atom(resp, &resp_index, "ok");
    ei_encode_binary(resp, &resp_index, tree_id_str, 40);

    erlcmd_send(resp, resp_index);
    free(resp);
}

void handle_index_write(const char *req, int *req_index) {
    char * resp;
    int resp_index = sizeof(uint16_t);

    if(erl_decode_validate_number_args(req, req_index, 1) <0 ) {
        send_error_response("wrong_number_of_args");
        return;
    }

    git_index_write(local_index);


    resp = malloc(1000);
    resp[resp_index++] = response_id;
    ei_encode_version(resp, &resp_index);
    ei_encode_atom(resp, &resp_index, "ok");

    erlcmd_send(resp, resp_index);
    free(resp);
}
