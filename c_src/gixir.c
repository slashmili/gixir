#include <stdio.h>
#include "util.h"
#include "gixir_handlers.h"
#include "erlcmd.h"
#include <git2/global.h>

#include <poll.h>
#include <unistd.h>

void main_loop() {

    git_libgit2_init();
    struct erlcmd *handler = malloc(sizeof(struct erlcmd));
    erlcmd_init(handler, handle_elixir_request, NULL);
    for (;;) {
        struct pollfd fdset[3];

        fdset[0].fd = STDIN_ALTER_FILENO;
        fdset[0].events = POLLIN;
        fdset[0].revents = 0;

        int timeout = -1;

        int rc = poll(fdset, 2, timeout);
        if (rc < 0) {
            if (errno == EINTR)
                continue;
            err(EXIT_FAILURE, "poll");
        }
        if (fdset[0].revents & (POLLIN | POLLHUP)) {
            if (erlcmd_process(handler))
                break;
        }
    }
}

int main()
{
    main_loop();
    return 0;
}
