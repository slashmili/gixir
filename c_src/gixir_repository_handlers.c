#include "gixir_handlers.h"

#include <git2/sys/repository.h>
#include <git2/sys/odb_backend.h>
#include <git2/sys/refdb_backend.h>
#include <git2/errors.h>
#include <git2/refs.h>

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
    uint8_t *repo_path = malloc(term_size);
    git_repository *repo;
    int error = 0;


    long binary_len = 0;
    if (ei_decode_binary(req, req_index, repo_path, &binary_len) < 0) {
        send_error_response("cannot_read_path");
        return;
    }

    int bare = 0;
    if(ei_decode_boolean(req, req_index, &bare) <0) {
        send_error_response("cannot_read_bare");
    }

    error = git_repository_init(&repo, repo_path, bare);
    if (error < 0) {
        const git_error *e = giterr_last();
        send_error_response_with_message("repository_init_at", e->message);
        return;
    }

    git_repository_free(repo);
    char resp[256];
    int resp_index = sizeof(uint16_t);
    resp[resp_index++] = response_id;
    ei_encode_version(resp, &resp_index);
    ei_encode_tuple_header(resp, &resp_index, 2);
    ei_encode_atom(resp, &resp_index, "ok");
    ei_encode_atom(resp, &resp_index, "pong");
    erlcmd_send(resp, resp_index);

    free(repo_path);
}
