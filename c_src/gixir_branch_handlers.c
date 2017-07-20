#include "gixir_handlers.h"
#include "git2_headers.h"
#include "gixir_vars.h"

void handle_branch_head(const char *req, int *req_index) {
    int term_size;
    if (ei_decode_tuple_header(req, req_index, &term_size) < 0 ||
            term_size != 1) {
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

    git_reference * ref;

    if(git_reference_dwim(&ref, global_repo, branch_name) < 0) {
        const git_error *e = giterr_last();
        send_error_response_with_message("branch_head", e->message);
        return;
    }

    if (git_reference_type(ref) != GIT_REF_OID) {
        send_error_response("branch_not_found");
    }

    git_commit *commit;
    if(git_commit_lookup(&commit, global_repo, git_reference_target(ref)) < 0){
        const git_error *e = giterr_last();
        send_error_response_with_message("branch_head", e->message);
        return;
    }


    const git_signature *author;
    const git_signature *committer;
    const char * message_encoding;
    const char * message;
    message_encoding = git_commit_message_encoding(commit);
    message = git_commit_message(commit);
    author = git_commit_author(commit);
    committer = git_commit_committer(commit);

    const git_oid *commit_oid;
    commit_oid =  git_commit_id(commit);
    char commit_id[40];
    char tree_id[40];

    git_oid_fmt(tree_id, git_commit_tree_id(commit));
    git_oid_fmt(commit_id, git_reference_target(ref));

    git_commit_free(commit);
    char resp[1000];
    int resp_index = sizeof(uint16_t);
    resp[resp_index++] = response_id;
    ei_encode_version(resp, &resp_index);
    ei_encode_tuple_header(resp, &resp_index, 2);
    ei_encode_atom(resp, &resp_index, "ok");
    ei_encode_tuple_header(resp, &resp_index, 6);
    ei_encode_binary(resp, &resp_index, commit_id, 40);
    ei_encode_atom(resp, &resp_index, "parents");
    ei_encode_binary(resp, &resp_index, tree_id, 40);

    ei_encode_tuple_header(resp, &resp_index, 2);
    ei_encode_binary(resp, &resp_index, message, strlen(message));
    if(message_encoding == NULL) {
        ei_encode_binary(resp, &resp_index, "UTF-8", 5);
    } else {
        ei_encode_binary(resp, &resp_index, message_encoding, strlen(message_encoding));
    }

    ei_encode_tuple_header(resp, &resp_index, 4);
    ei_encode_binary(resp, &resp_index, author->name, strlen(author->name));
    ei_encode_binary(resp, &resp_index, author->email, strlen(author->email));
    ei_encode_long(resp, &resp_index, author->when.time);
    ei_encode_long(resp, &resp_index, author->when.offset);

    ei_encode_tuple_header(resp, &resp_index, 4);
    ei_encode_binary(resp, &resp_index, committer->name, strlen(committer->name));
    ei_encode_binary(resp, &resp_index, committer->email, strlen(committer->email));
    ei_encode_long(resp, &resp_index, committer->when.time);
    ei_encode_long(resp, &resp_index, committer->when.offset);

    erlcmd_send(resp, resp_index);
}
