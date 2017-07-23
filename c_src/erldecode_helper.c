#include "gixir_handlers.h"

int erl_decode_validate_number_args(const char *req, int *req_index, int arg_size) {
    int term_size;
    if (ei_decode_tuple_header(req, req_index, &term_size) < 0 ||
            term_size != arg_size) {
        return -1;
    }
    return 0;
}

int erl_decode_validate_binary(const char *req, int *req_index, int * term_size) {
    int term_type;
    if (ei_get_type(req, req_index, &term_type, term_size) < 0 ||
            term_type != ERL_BINARY_EXT) {
        return -1;
    }
    return 0;
}

int erl_decode_validate_int(const char *req, int *req_index, int * term_size) {
    int term_type;
    if (ei_get_type(req, req_index, &term_type, term_size) < 0 ||
            term_type != ERL_INTEGER_EXT) {
        return -1;
    }
    return 0;
}


int erl_decode_binary(const char *req, int *req_index, void *p, long * binary_len) {
    if (ei_decode_binary(req, req_index, p, binary_len) < 0) {
        return -1;
    }
    return 0;
}

int erl_validate_and_decode_string(const char *req, int *req_index, char **out, long * binary_len) {
    int term_size;
    char *str;
    if(erl_decode_validate_binary(req, req_index, &term_size) < 0) {
        return -1;
    }
    str = (char*) malloc(term_size);
    if (ei_decode_binary(req, req_index, str, binary_len) < 0) {
        return -1;
    }
    str[term_size] = '\0';
    *out = str;
    return 0;
}

int erl_validate_and_decode_int(const char *req, int *req_index, int * out) {
    long long_out;
    int term_size;
    if(erl_decode_validate_int(req, req_index, &term_size) < 0) {
        return -1;
    }

    if (ei_decode_long(req, req_index, &long_out) < 0) {
        return -1;
    }
    *out = long_out;
    return 0;
}
