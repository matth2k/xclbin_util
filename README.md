# xclbin_util

* examples/axi_bram_linux_driver: shows how interacting with AXI peripherals can be brute forced with linux system calls in the userspace (on edge devices at least). Proof of concept that writing your own drivers is maybe possible.
* load_xclbin: C code demonstrating how to use XRT/OpenCL calls to implicity do partial bitstream programming. ``cl::Program`` constructor is what calls the bitstream load routine (call 'stack' is roughly XRT -> OpenCL -> Custom Xilinx Hypervisor Call -> xilfpga lib)
* xclbin_profiler: bash scripts that help automate manipulating the metadata of xclbins. You can spoof partial bitstreams onto the FPGA by giving it the meta-data of a valid kernel, then use the load_xclbin code.
