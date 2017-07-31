#include "gixir_handlers.h"
#include "git2_headers.h"
#include "gixir_vars.h"

void handle_commit_create(const char *req, int *req_index) {
    git_signature *author, *cmtter = NULL;
    char * update_ref = NULL;
    char * message = NULL;
    char * tree_oid_str = NULL;
    git_oid tree_oid;
    int parent_count = 0;
    char * resp;
    int resp_index = sizeof(uint16_t);
    git_oid commit_oid;
    git_tree * tree;
    long binary_len;
    const git_commit **parents = NULL;
    char commit_oid_str[40];
    int i = 0;

    if(erl_decode_validate_number_args(req, req_index, 7) <0 ) {
        send_error_response("wrong_number_of_args");
        return;
    }

    if(erl_validate_and_decode_string(req, req_index, &update_ref, &binary_len) <0) {
        send_error_response("cannot_read_update_ref");
        return;
    }

    if(erl_validate_and_decode_signature(req, req_index, &author) < 0 ) {
        send_error_response("cannot_read_author");
        return;
    }

    if(erl_validate_and_decode_signature(req, req_index, &cmtter) < 0 ) {
        send_error_response("cannot_read_committer");
        return;
    }

    if(erl_validate_and_decode_string(req, req_index, &message, &binary_len) <0) {
        send_error_response("cannot_read_message");
        return;
    }

    if(erl_validate_and_decode_string(req, req_index, &tree_oid_str, &binary_len) <0) {
        send_error_response("cannot_read_tree");
        return;
    }

    if(erl_validate_and_decode_int(req, req_index, &parent_count) <0) {
        send_error_response("cannot_read_parent_count");
        return;
    }

    parents = calloc(parent_count, sizeof(void *));
    if(parent_count > 0) {
        int term_size;
        if(erl_decode_validate_list(req, req_index, &term_size) < 0) {
            send_error_response("cannot_read_parent_list");
            return;
        }
        int arity;
        ei_decode_list_header(req, req_index, &arity);
        if(arity != parent_count) {
            send_error_response("cannot_read_enough_parent_id");
            return;
        }
        for(i = 0; i< arity; i++) {
            char * parent_id = NULL;
            git_oid oid;
            git_commit *parent = NULL;
            erl_validate_and_decode_string(req, req_index, &parent_id, &binary_len);
            if (git_oid_fromstr(&oid, parent_id) < GIT_OK) {
                send_git_error_response_with_message("git_oid_fromstr");
                return;
            }
            if(git_commit_lookup(&parent, global_repo, &oid) < GIT_OK) {
                send_git_error_response_with_message("git_commit_lookup");
                return;
            }
            parents[i] = parent;
            free(parent_id);
        }
    }

    if(git_oid_fromstr(&tree_oid, tree_oid_str) <0 ) {
        send_git_error_response_with_message("git_oid_fromstr");
        return;
    }


    if(git_tree_lookup(&tree, global_repo, &tree_oid) < 0) {
        send_git_error_response_with_message("git_tree_lookup");
        return;
    }

    int error = git_commit_create(
            &commit_oid,
            global_repo,
            update_ref,
            author,
            cmtter,
            NULL,
            message,
            tree,
            parent_count,
            parents
    );
    if(error < 0) {
        send_git_error_response_with_message("git_commit_create");
        return;
    }

    git_oid_fmt(commit_oid_str, &commit_oid);
    git_commit *commit = NULL;
    git_commit_lookup(&commit, global_repo, &commit_oid);
    char new_tree_oid_str[40];
    const git_oid * new_tree_oid = git_commit_tree_id(commit);
    git_oid_fmt(new_tree_oid_str, new_tree_oid);

    resp = malloc(1000);
    resp[resp_index++] = response_id;
    ei_encode_version(resp, &resp_index);
    ei_encode_tuple_header(resp, &resp_index, 3);
    ei_encode_atom(resp, &resp_index, "ok");
    ei_encode_binary(resp, &resp_index, commit_oid_str, 40);
    ei_encode_binary(resp, &resp_index, new_tree_oid_str, 40);

    erlcmd_send(resp, resp_index);

    free(resp);
    free(update_ref);
    free(message);
    free(tree_oid_str);
    git_tree_free(tree);
    git_signature_free(author);
    git_signature_free(cmtter);
    git_commit_free(commit);

    for (i = 0; i < parent_count; ++i) {
        git_object_free((git_object *) parents[i]);
    }
}
