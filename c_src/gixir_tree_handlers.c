#include "gixir_handlers.h"
#include "git2_headers.h"
#include "gixir_vars.h"

void handle_tree_lookup(const char *req, int *req_index) {
    int term_size;
    if (ei_decode_tuple_header(req, req_index, &term_size) < 0 ||
            term_size != 1) {
        send_error_response("wrong_number_of_args");
        return;
    }

    int term_type;
    if (ei_get_type(req, req_index, &term_type, &term_size) < 0 ||
            term_type != ERL_BINARY_EXT) {
        send_error_response("cannot_tree_oid");
        return;
    }

    //read branch name
    if (ei_get_type(req, req_index, &term_type, &term_size) < 0 ||
            term_type != ERL_BINARY_EXT) {
        send_error_response("cannot_tree_oid");
        return;
    }
    char *tree_oid_str = malloc(term_size);


    long binary_len;
    if (ei_decode_binary(req, req_index, tree_oid_str, &binary_len) < 0) {
        send_error_response("cannot_read_name");
        return;
    }
    tree_oid_str[term_size] = '\0';

    git_tree *tree;
    git_oid tree_oid;
    git_oid_fromstr(&tree_oid, tree_oid_str);

    git_tree_lookup(&tree, global_repo, &tree_oid);

    int tree_count = git_tree_entrycount(tree);
    char * resp = malloc(1000 * tree_count);
    int resp_index = sizeof(uint16_t);
    resp[resp_index++] = response_id;
    ei_encode_version(resp, &resp_index);
    ei_encode_tuple_header(resp, &resp_index, 2);
    ei_encode_atom(resp, &resp_index, "ok");

    ei_encode_list_header(resp, &resp_index, tree_count);
    int i = 0;
    for (i = 0; i < tree_count; ++i) {
        const git_tree_entry *entry = git_tree_entry_byindex(tree, i);
        const char * entry_name = git_tree_entry_name(entry);
        const git_oid * entry_oid = git_tree_entry_id(entry);
        char entry_id_str[40];
        ei_encode_tuple_header(resp, &resp_index, 4);
        ei_encode_binary(resp, &resp_index, entry_name, strlen(entry_name));
        git_oid_fmt(entry_id_str, entry_oid);
        ei_encode_binary(resp, &resp_index, entry_id_str, 40);
        ei_encode_long(resp, &resp_index, 33188);
        ei_encode_atom(resp, &resp_index, "blob");
    }
    ei_encode_empty_list(resp, &resp_index);
    erlcmd_send(resp, resp_index);
    free(resp);
    free(tree_oid_str);
}
