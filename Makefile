SHELL:=/bin/bash 
SIM?=verilator

# Options for GCC compiler
COMPILE_OPT=-cc -no-decoration -O3 -CFLAGS -Wno-attributes -CFLAGS -O2

# Options for C++ model analysis
#ANALYSIS_OPT=-stats -Wwarn-IMPERFECTSCH

# Comment this line to disable VCD generation
# TRACE_OPT=-trace -no-trace-params

# Clock signals
# CLOCK_OPT=-clk v_clk

VERILOG_SRC= tb_top.sv

VERILOG_PARAMS?=
SIM_ARGS=
COMPILE_ARGS=

BUILD_DIR?=build

ifeq ($(SIM),verilator)
	VERILOG_DEFINES=+define+SIM_VERILATOR
else
	VERILOG_DEFINES=
	COMPILE_ARGS+= 
	ifndef GUI
		SIM_ARGS+=-batch -do "run -all"
		COMPILE_ARGS+=-vopt
	else
		SIM_ARGS+=-gui
		COMPILE_ARGS+=+acc -timescale 10ns/1ns
	endif
endif

# Verilog top module
TOP_FILE=tb_top

# C++ support files
DPI_C_FILES = dpi.cpp

CPP_FILES=tb_top.cpp $(DPI_C_FILES)


.phony: sim
sim: sim_$(SIM)

clean:
	rm -rf $(BUILD_DIR) *.vcd  *.wlf transcript *.jou *.pb obj_dir xsim.dir Vtb_top__Dpi.h

# Simulation on verilator ---------------------------------------------------------------

sim_verilator: $(BUILD_DIR)/V$(TOP_FILE)
	./$(BUILD_DIR)/V$(TOP_FILE)


$(BUILD_DIR)/V$(TOP_FILE): $(BUILD_DIR)/$(TOP_FILE).mk 
	@cd ./$(BUILD_DIR) && \
	make -j -f V$(TOP_FILE).mk V$(TOP_FILE) && \
	cd -

$(BUILD_DIR)/$(TOP_FILE).mk: $(CPP_FILES) $(VERILOG_SRC) $(DPI_C_FILES)
	@verilator -Mdir $(BUILD_DIR) $(VERILOG_SRC) $(ANALYSIS_OPT) $(COMPILE_OPT) $(CLOCK_OPT) \
	$(TRACE_OPT) $(VERILOG_DEFINES) $(VERILOG_PARAMS) -top-module $(TOP_FILE) -exe $(CPP_FILES)


# Simulation on questasim ----------------------------------------------------------------

$(BUILD_DIR)/_vmake $(BUILD_DIR)/_lib.qdb: $(VERILOG_SRC) $(DPI_C_FILES)
	@vlog -work $(BUILD_DIR) $(COMPILE_ARGS)  $(VERILOG_SRC) $(VERILOG_DEFINES) $(DPI_C_FILES) -dpiheader Vtb_top__Dpi.h

sim_questa: $(BUILD_DIR)/_vmake $(BUILD_DIR)/_lib.qdb
	@vsim $(BUILD_DIR).$(TOP_FILE) $(VERILOG_PARAMS) $(SIM_ARGS)


