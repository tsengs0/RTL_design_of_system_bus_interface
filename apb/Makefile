.PHONY: all

XILINX_DIR=/home/tsengs0/Xilinx/Vivado/2019.2/settings64.sh
UVM_LIB=/home/tsengs0/ASIC/projects/UVM/library/1800.2-2020-1.1
UVM_OPT=+UVM_VERBOSITY=UVM_HIGH

RTL_FILELIST=./apb_io_rw_filelist.f
RTL_SRC=`cat $(RTL_FILELIST)`
TOP_MODULE=tb_apb_io_rw

all:
	$(shell ./simEnv_setup.sh)
	#source $(XILINX_DIR)
	#xvlog -sv $(RTL_SRC) -L uvm --include ./testbench/uvm_model
	#iverilog -g 2012 -o tb testbench/tb_accessRqstGen_2gp.sv source/access_rqst_gen.v
	xvlog -sv $(RTL_SRC) -L uvm
	
	# Adding option "-v 2" will print more detail of log file during elaboration
	#xelab -v 2 $(TOP_MODULE) -timescale 1ns/1ps -L uvm

	xelab $(TOP_MODULE) -timescale 1ns/1ps -L uvm

apb_io_rw:
#	$(shell source /home/tsengs0/Xilinx/Vivado/2019.2/settings64.sh)
	xvlog -sv $(RTL_SRC) -L uvm
	
	# Adding option "-v 2" will print more detail of log file during elaboration
	#xelab -v 2 $(TOP_MODULE) -timescale 1ns/1ps -L uvm
	xelab $(TOP_MODULE) -timescale 1ns/1ps -L uvm

run:
	xsim $(TOP_MODULE) -R #--testplusarg "UVM_TESTNAME=test"

clean:
	rm -rf xsim.dir .Xil
	rm *.jou *.log *.pb
	rm *.vcd
