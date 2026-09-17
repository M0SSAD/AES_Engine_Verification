`ifndef AES_HDL_TOP_SV
`define AES_HDL_TOP_SV
// TOP Module for static components.
module aes_hdl_top ();
    import uvm_pkg::*; 
    
    logic clk;
    logic rst_n;
    parameter CLOCK_PERIOD = 10;

    aes_128_inf intf(clk, rst_n);
    AES_128 aes_128(
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(intf.valid_in),
        .flag(intf.flag),
        .input_text_128(intf.input_text_128),
        .cipher_key_128(intf.cipher_key_128),
        .valid_out(intf.valid_out),
        .cipher_text_128(intf.cipher_text_128),
        .plain_text_128(intf.plain_text_128)
    );

    aes_drv_bfm drv_bfm(
        .intf(intf)
    );

    aes_mon_bfm mon_bfm(
        .intf(intf)
    );

    initial begin
        uvm_config_db#(virtual aes_drv_bfm)::set(null, "uvm_test_top", "drv_bfm", drv_bfm);
        uvm_config_db#(virtual aes_mon_bfm)::set(null, "uvm_test_top", "mon_bfm", mon_bfm);

    end

    // start the clock
    initial begin
        clk = 0;
        forever #(CLOCK_PERIOD/2) clk = ~clk;
    end

    // initial reset
    initial begin
        rst_n = 0;
        repeat(4) @(posedge clk);
        rst_n = 1;
    end
endmodule

`endif