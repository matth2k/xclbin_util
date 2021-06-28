SYSROOT = /home/matth2k/u96_huffman/linux_files/sysroots/aarch64-xilinx-linux

HOST_CXX ?= aarch64-linux-gnu-g++
RM = rm -f
RMDIR = rm -rf

VITIS_PLATFORM ?= ultra96v2_design

CXXFLAGS += -march=armv8-a+simd -mtune=cortex-a53 -std=c++11 -DVITIS_PLATFORM=$(VITIS_PLATFORM) -D__USE_XOPEN2K8 -I$(XILINX_VIVADO)/include/ -I$(SYSROOT)/usr/include/xrt/ -O3 -g -Wall -c -fmessage-length=0 --sysroot=$(SYSROOT)
LDFLAGS += -lxilinxopencl -lpthread -lrt -ldl -lcrypt -lstdc++ -L$(SYSROOT)/usr/lib/ --sysroot=$(SYSROOT)

HOST_SOURCES = load_xclbin.cpp
HOST_OBJECTS=$(HOST_SOURCES:.cpp=.o)
HOST_EXE = load_xclbin

.PHONY: host

all: host

host: $(HOST_EXE)

$(HOST_EXE): $(HOST_OBJECTS)
	$(HOST_CXX) -o "$@" $(+) $(LDFLAGS)
		
.cpp.o:
	$(HOST_CXX) $(CXXFLAGS) -o "$@" "$<"

clean:
	-$(RM) $(HOST_EXE) $(HOST_OBJECTS) 

