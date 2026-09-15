`ifndef AES_DRV_BFM_SV
`define AES_DRV_BFM_SV

interface aes_drv_bfm (
    aes_128_inf intf
);
    task wait_for_reset();
        // wait for reset to be inasserted, so we don't lose transactions
        // to be called before the forever loop in the proxy
        wait(intf.rst_n);
    endtask

    task drive_request(
        logic flag,
        logic [127:0] input_text_128,
        logic [127:0] cipher_key_128
    );
        // drive the pin signals @posedge of the clock using NBA, to queue the TX for the next cycle in the DUT.
        @(posedge intf.clk); // at CLOCK N, schedule these inputs for CLOCK N+1
        intf.flag <= flag;
        intf.input_text_128 <= input_text_128;
        intf.cipher_key_128 <= cipher_key_128;
        intf.valid_in <= 1;
    endtask

    task drive_idle();
        @(posedge intf.clk);
        intf.valid_in <= 1'b0;
    endtask

    task get_response(
        output logic valid_out,
        output logic [127:0] cipher_text_128,
        output logic [127:0] plain_text_128
    );
        wait(intf.valid_out);
        valid_out = intf.valid_out;
        cipher_text_128 = intf.cipher_text_128;
        plain_text_128 = intf.plain_text_128;
    endtask
endinterface

`endif