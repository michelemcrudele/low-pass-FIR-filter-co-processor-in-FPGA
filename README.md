# Low_Pass_FIR_Filter_co-Processor_in_FPGA
We design a low-pass FIR filter that accepts, excluding hardware limits, an integer power of 2 number of coefficients. The VHDL code to be loaded into FPGA, the testbenches code and the simulations are generated by a Python function which accepts as argument a list of coefficients. The results obtained from the testebench in VHDL, from the simulation in python and from the output of the FPGA are all consistent between each other, both for a FIR filter with 4 and 8 coefficients.
