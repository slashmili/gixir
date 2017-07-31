int erl_decode_validate_number_args(const char *req, int *req_index, int arg_size);
int erl_decode_validate_binary(const char *req, int *req_index, int * term_size);
int erl_decode_validate_binary(const char *req, int *req_index, int * term_size);
int erl_decode_binary(const char *req, int *req_index, void *p, long * binary_len);
int erl_validate_and_decode_string(const char *req, int *req_index, char **p, long * binary_len);
int erl_validate_and_decode_int(const char *req, int *req_index, int * out);
int erl_validate_and_decode_signature(const char *req, int *req_index, git_signature **signature);
int erl_decode_validate_list(const char *req, int *req_index, int * term_size);
