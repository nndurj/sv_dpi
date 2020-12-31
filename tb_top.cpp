#include "verilated.h"
#include "verilated_vcd_c.h"

#include "Vtb_top.h"
#include "Vtb_top__Dpi.h"
#include <ctime>

#if VM_TRACE
#include "verilated_vcd_c.h"
#endif

vluint64_t main_time = 0; 

double sc_time_stamp() {
    return main_time; 
}

int main(int argc, char **argv, char **env){

    Vtb_top* top = new Vtb_top;
    
#if VM_TRACE
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);  // Trace 99 levels of hierarchy
    tfp->open("dump.vcd");
#endif

    // Simulation loop
    while (!Verilated::gotFinish()){
        top->v_clk = !top->v_clk;
        top->eval();
        main_time++;
    #if VM_TRACE
        if (tfp) tfp->dump(main_time);
    #endif
    }

    top->final();

#if VM_TRACE
     if (tfp) tfp->close();
#endif

    exit(0);
}

