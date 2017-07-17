#include "gixir_handlers.h"

#include "git2_headers.h"

/*
 * {repo_path, file_path}
 */
void handle_blob_from_workdir(const char *req, int *req_index) {

    git_repository *repo;
    int error = 0;

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


    long binary_len = 0;
    if (ei_decode_binary(req, req_index, repo_path, &binary_len) < 0) {
        send_error_response("cannot_read_path");
        return;
    }
    repo_path[binary_len] = '\0';

    if (ei_get_type(req, req_index, &term_type, &term_size) < 0 ||
            term_type != ERL_BINARY_EXT) {
        send_error_response("cannot_parse_file_path");
        return;
    }
    uint8_t *file_path = malloc(term_size);

    if (ei_decode_binary(req, req_index, file_path, &binary_len) < 0) {
        send_error_response("cannot_read_file_path");
        return;
    }
    file_path[binary_len] = '\0';


    error = git_repository_open(&repo, repo_path);
    if (error < 0) {
        const git_error *e = giterr_last();
        send_error_response_with_message("blob_from_workdir", e->message);
        return;
    }


    git_oid oid;
    error = git_blob_create_fromworkdir(&oid, repo, file_path);
    if (error < 0) {
        const git_error *e = giterr_last();
        send_error_response_with_message("blob_from_workdir", e->message);
        return;
    }

    char out[40];
    git_oid_fmt(out, oid.id);

    git_repository_free(repo);
    //git_tree_free(oid);
    char resp[256];
    int resp_index = sizeof(uint16_t);
    resp[resp_index++] = response_id;
    ei_encode_version(resp, &resp_index);
    ei_encode_tuple_header(resp, &resp_index, 2);
    ei_encode_atom(resp, &resp_index, "ok");
    ei_encode_binary(resp, &resp_index, out, 40);
    erlcmd_send(resp, resp_index);

    free(repo_path);
}
