`ifndef AES_DRV_BFM_SV
`define AES_DRV_BFM_SV

import aes_pkg::*;
interface aes_drv_bfm (
    aes_128_inf intf
);  
    task wait_for_reset();
        // wait for reset to be inasserted, so we don't lose transactions
        // to be called before the forever loop in the proxy
        wait(intf.rst_n);
    endtask

    task drive_request(
        input aes_op_e op,
        input logic [127:0] data,
        input logic [127:0] key
    );
        intf.flag <= op;
        intf.input_text_128 <= data;
        intf.cipher_key_128 <= key;
        intf.valid_in <= 1;
        @(posedge intf.clk); // At CLOCK N, these inputs are stable on the bus.
        intf.valid_in <= 1'b0; // schedule valid_in to 0, will be overriden to 1, if there is a back to back transactions.
    endtask

    task drive_idle();
        intf.valid_in <= 1'b0;
        @(posedge intf.clk);
    endtask

    task get_response(
        input aes_op_e op,
        output logic valid_out,
        output logic [127:0] data_out
    );
        @(posedge intf.clk); // Wait for CLOCK N+1 To sample the output
        if (!intf.valid_out) begin
            wait(intf.valid_out);
        end
        valid_out = intf.valid_out;
        if(op == ENCRYPT) begin
            data_out = intf.cipher_text_128;
        end else begin
            data_out = intf.plain_text_128;
        end
    endtask
endinterface

`endif