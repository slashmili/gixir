#include "gixir_handlers.h"
#include "git2_headers.h"
#include "gixir_vars.h"


void erl_send_tree_entery(char * resp, int * resp_index, const git_tree_entry *entry);

void handle_tree_lookup(const char *req, int *req_index) {

    char *tree_oid_str = NULL;
    long binary_len;

    if(erl_decode_validate_number_args(req, req_index, 1) <0 ) {
        send_error_response("wrong_number_of_args");
        return;
    }

    if (erl_validate_and_decode_string(req, req_index, &tree_oid_str, &binary_len) < 0) {
        send_error_response("cannot_read_file_path");
        return;
    }

    git_tree *tree;
    git_oid tree_oid;
    if(git_oid_fromstr(&tree_oid, tree_oid_str) <0 ) {
        send_git_error_response_with_message("git_oid_fromstr");
        return;
    }

    if(git_tree_lookup(&tree, global_repo, &tree_oid) <0) {
        send_git_error_response_with_message("git_tree_lookup");
        return;
    }

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
        erl_send_tree_entery(resp, &resp_index, entry);
    }
    git_tree_free(tree);
    ei_encode_empty_list(resp, &resp_index);
    erlcmd_send(resp, resp_index);
    free(resp);
    //free(tree_oid_str);
}

void handle_tree_lookup_bypath(const char *req, int *req_index) {
    long binary_len;
    char *tree_oid_str = NULL;
    char *tree_path_str = NULL;

    if(erl_decode_validate_number_args(req, req_index, 2) <0 ) {
        send_error_response("wrong_number_of_args");
        return;
    }

    if (erl_validate_and_decode_string(req, req_index, &tree_oid_str, &binary_len) < 0) {
        send_error_response("cannot_read_tree_oid");
        return;
    }

    if (erl_validate_and_decode_string(req, req_index, &tree_path_str, &binary_len) < 0) {
        send_error_response("cannot_read_tree_path");
        return;
    }

    git_tree_entry * path_entry;


    git_tree *tree;
    git_oid tree_oid;

    if(git_oid_fromstr(&tree_oid, tree_oid_str) <0) {
        send_git_error_response_with_message("git_oid_fromstr");
        return;
    }
    if(git_tree_lookup(&tree, global_repo, &tree_oid) < 0) {
        send_git_error_response_with_message("git_tree_lookup");
        return;
    }
    if(git_tree_entry_bypath(&path_entry, tree, tree_path_str) < 0) {
        send_git_error_response_with_message("git_tree_entry_bypath");
        return;
    }

    git_tree_free(tree);
    int resp_index = sizeof(uint16_t);
    char * resp;
    if(git_tree_entry_type(path_entry) == GIT_OBJ_BLOB) {
        resp = malloc(1000);
        resp[resp_index++] = response_id;
        ei_encode_version(resp, &resp_index);
        ei_encode_tuple_header(resp, &resp_index, 2);
        ei_encode_atom(resp, &resp_index, "ok");
        erl_send_tree_entery(resp, &resp_index, path_entry);
    } else {
        const git_oid * path_entry_oid = git_tree_entry_id(path_entry);
        git_tree_lookup(&tree, global_repo, path_entry_oid);
        int tree_count = git_tree_entrycount(tree);
        resp = malloc(2000 * tree_count);
        resp[resp_index++] = response_id;
        ei_encode_version(resp, &resp_index);
        ei_encode_tuple_header(resp, &resp_index, 3);
        ei_encode_atom(resp, &resp_index, "ok");

        char entry_id_str[40];
        git_oid_fmt(entry_id_str, path_entry_oid);
        ei_encode_binary(resp, &resp_index, entry_id_str, 40);

        ei_encode_list_header(resp, &resp_index, tree_count);
        int i = 0;
        for (i = 0; i < tree_count; ++i) {
            const git_tree_entry *entry = git_tree_entry_byindex(tree, i);
            erl_send_tree_entery(resp, &resp_index, entry);
        }
        git_tree_free(tree);
        ei_encode_empty_list(resp, &resp_index);
    }
    erlcmd_send(resp, resp_index);
    free(resp);
    free(tree_path_str);
    //free(tree_oid_str);
    git_tree_entry_free(path_entry);
}

void erl_send_tree_entery(char * resp, int * resp_index, const git_tree_entry *entry) {
    const char * entry_name = git_tree_entry_name(entry);
    const git_oid * entry_oid = git_tree_entry_id(entry);
    const git_otype entry_type = git_tree_entry_type(entry);
    const git_filemode_t filemode = git_tree_entry_filemode(entry);
    char entry_id_str[40];
    ei_encode_tuple_header(resp, resp_index, 4);
    ei_encode_binary(resp, resp_index, entry_name, strlen(entry_name));
    git_oid_fmt(entry_id_str, entry_oid);
    ei_encode_binary(resp, resp_index, entry_id_str, 40);
    ei_encode_long(resp, resp_index, filemode);
    if (entry_type == GIT_OBJ_TREE) {
        ei_encode_atom(resp, resp_index, "tree");
    } else if(entry_type == GIT_OBJ_BLOB) {
        ei_encode_atom(resp, resp_index, "blob");
    } else {
        ei_encode_atom(resp, resp_index, "unknown");
    }
}
