#include "gixir_handlers.h"
#include "gixir_repository_handlers.h"
#include "gixir_blob_handlers.h"
#include "gixir_branch_handlers.h"


static void handle_ping(const char *req, int *req_index) {
    char resp[256];
    int resp_index = sizeof(uint16_t); // Space for payload size
    resp[resp_index++] = response_id;
    ei_encode_version(resp, &resp_index);
    ei_encode_tuple_header(resp, &resp_index, 2);
    ei_encode_atom(resp, &resp_index, "ok");
    ei_encode_atom(resp, &resp_index, "pong");
    erlcmd_send(resp, resp_index);
}

static struct request_handler request_handlers[] = {
    { "ping", handle_ping },
    { "repository_init_at", handle_repository_init_at },
    { "repository_open", handle_repository_open },
    { "repository_list_branches", handle_repository_list_branches },
    { "repository_lookup_branch", handle_repository_lookup_branch },
    { "repository_workdir", handle_repository_workdir },
    { "blob_from_workdir", handle_blob_from_workdir },
    { "branch_target", handle_branch_target },
    { NULL, NULL }
};

void handle_elixir_request(const char *req, void *cookie)
{
    (void) cookie;

    // Commands are of the form {Command, Arguments}:
    // { atom(), term() }
    int req_index = sizeof(uint16_t);
    if (ei_decode_version(req, &req_index, NULL) < 0)
        errx(EXIT_FAILURE, "Message version issue?");

    int arity;
    if (ei_decode_tuple_header(req, &req_index, &arity) < 0 ||
            arity != 2)
        errx(EXIT_FAILURE, "expecting {cmd, args} tuple");

    char cmd[MAXATOMLEN];
    if (ei_decode_atom(req, &req_index, cmd) < 0)
        errx(EXIT_FAILURE, "expecting command atom");

    for (struct request_handler *rh = request_handlers; rh->name != NULL; rh++) {
        if (strcmp(cmd, rh->name) == 0) {
            rh->handler(req, &req_index);
            return;
        }
    }
    errx(EXIT_FAILURE, "unknown command: %s", cmd);
}

/**
 * @brief Send :error back to Elixir
 */
void send_error_response(const char *reason)
{
    char resp[256];
    int resp_index = sizeof(uint16_t); // Space for payload size
    resp[resp_index++] = response_id;
    ei_encode_version(resp, &resp_index);
    ei_encode_tuple_header(resp, &resp_index, 2);
    ei_encode_atom(resp, &resp_index, "error");
    ei_encode_atom(resp, &resp_index, reason);
    erlcmd_send(resp, resp_index);
}

void send_error_response_with_message(const char *reason, const char *reason_message)
{
    char resp[256];
    int resp_index = sizeof(uint16_t); // Space for payload size
    resp[resp_index++] = response_id;
    ei_encode_version(resp, &resp_index);
    ei_encode_tuple_header(resp, &resp_index, 2);
    ei_encode_atom(resp, &resp_index, "error");
    ei_encode_tuple_header(resp, &resp_index, 2);
    ei_encode_atom(resp, &resp_index, reason);
    ei_encode_binary(resp, &resp_index, reason_message, strlen(reason_message));
    erlcmd_send(resp, resp_index);
}
