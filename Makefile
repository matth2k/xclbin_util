
all:
	+$(MAKE) -C load_xclbin
	+$(MAKE) -C xclbin_profiler
