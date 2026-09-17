`ifndef AES_HVL_TOP_SV
`define AES_HVL_TOP_SV
module aes_hvl_top ();

    import uvm_pkg::*;
    import aes_test_pkg::*;
    initial begin
        run_test();
    end
endmodule

`endif