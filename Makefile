.PHONY: default
default: nif erl

build_dir := c_build

patch:
	cd google/crc32c && patch -p1 < ../../arm_small_batch.patch || echo "apply patch failed"

nif: patch
	@echo "Compiling NIF in $(build_dir)"
	@mkdir -p $(build_dir)
	@cmake -DCRC32C_USE_GLOG=0 -DCRC32C_BUILD_TESTS=0 -DCRC32C_BUILD_BENCHMARKS=0 . -B $(build_dir)
	@cmake --build $(build_dir)

erl:
	@echo "Compiling Erlang..."
	rebar3 compile

.PHONY: fmt
fmt:
	@clang-format-14 -style file:google/crc32c/.clang-format -i c_src/*
	@rebar3 fmt

.PHONY: clean
clean:
	@rebar3 unlock --all
	@rm -rf _build $(build_dir) _release

.PHONY: test
test:
	@rebar3 eunit
