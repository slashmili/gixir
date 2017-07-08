#include <stddef.h>
#include <stdint.h>
#include <ei.h>
#include <string.h>

#include "util.h"
#include "erlcmd.h"
#include "erlcmd_helper.h"
#include <pthread.h>


struct request_handler {
        const char *name;
            void (*handler)(const char *req, int *req_index);
};

void handle_elixir_request(const char *req, void *cookie);
void send_error_response(const char *reason);
void send_error_response_with_message(const char *reason, const char *reason_message);
