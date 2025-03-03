#include <crc32c/crc32c.h>
#include <stdint.h>

#include "erl_nif.h"

static int on_load(ErlNifEnv *env, void **priv_data, ERL_NIF_TERM loadinfo) {
  return 0;
}

static ERL_NIF_TERM crc32c_nif(ErlNifEnv *env, int argc,
                               const ERL_NIF_TERM argv[]) {
  ErlNifBinary bin;
  if (!(enif_inspect_binary(env, argv[0], &bin) ||
        enif_inspect_iolist_as_binary(env, argv[0], &bin))) {
    return enif_make_badarg(env);
  }

  uint32_t result = crc32c_value(bin.data, bin.size);

  return enif_make_uint(env, result);
}

static ERL_NIF_TERM crc32c_extend_nif(ErlNifEnv *env, int argc,
                                      const ERL_NIF_TERM argv[]) {
  ErlNifBinary bin;
  uint32_t crc;

  if (!enif_get_uint(env, argv[0], &crc)) {
    return enif_make_badarg(env);
  }

  if (!(enif_inspect_binary(env, argv[1], &bin) ||
        enif_inspect_iolist_as_binary(env, argv[1], &bin))) {
    return enif_make_badarg(env);
  }

  uint32_t result = crc32c_extend(crc, bin.data, bin.size);

  return enif_make_uint(env, result);
}

static ErlNifFunc nif_funcs[] = {
    {"crc32c", 1, crc32c_nif, 0},
    {"crc32c", 2, crc32c_extend_nif, 0},
};

ERL_NIF_INIT(crc32c4beam, nif_funcs, &on_load, NULL, NULL, NULL);
