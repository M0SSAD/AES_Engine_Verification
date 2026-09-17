`ifndef AES_MON_BFM_SV
`define AES_MON_BFM_SV

import aes_pkg::*;
interface aes_mon_bfm (
    aes_128_inf intf
);
    task wait_for_reset();
        // wait for reset to be inasserted, so we don't lose transactions
        // to be called before the forever loop in the proxy
        wait(intf.rst_n);
    endtask

    // wait for clock rising edge, sampling the input pins on it in the active region results in reading the values of the current Tx.
    task sample_request(
        output aes_op_e op,
        output logic [127:0] data,
        output logic [127:0] key
    );
        do begin
            @(posedge intf.clk);
        end while (!intf.valid_in);

        op = aes_op_e'(intf.flag);
        data = intf.input_text_128;
        key = intf.cipher_key_128;
    endtask

    // wait for clock rising edge, sampling the output pins on it in the active region results in reading the values of the previous Tx.
    task sample_response(
        output logic valid_out,
        output logic [127:0] data_out
    );
        do begin
            @(posedge intf.clk);
        end while (!intf.valid_out);
        valid_out = intf.valid_out;
        data_out = intf.cipher_text_128 | intf.plain_text_128;
    endtask

endinterface

`endif