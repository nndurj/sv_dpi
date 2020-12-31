module tb_top (
    `ifdef SIM_VERILATOR
        input v_clk
    `endif
);

    `ifndef SIM_VERILATOR
        logic v_clk = '0;
        always #5 v_clk = !v_clk;
    `endif

    logic [31:0] in_data;
    logic [31:0] out_data;

    import "DPI-C" function void monitor(input int data);
    import "DPI-C" function void dpic_init();
    import "DPI-C" context function int drive();
    export "DPI-C" function driver;

    function void driver(input int i_data);
        in_data = i_data;
    endfunction

    assign out_data = in_data + 1'b1;

    initial begin
        dpic_init();
    end

    always@(posedge v_clk) begin
        if (drive() == '0) begin
            $display("*-* All Finished *-*");
            $finish;
        end
        monitor(out_data);
    end

endmodule
