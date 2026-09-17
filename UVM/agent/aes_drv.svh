`ifndef AES_DRV_SVH
`define AES_DRV_SVH

class aes_drv extends uvm_driver #(aes_sequence_item);

    `uvm_component_utils(aes_drv)

    virtual aes_drv_bfm drv_bfm;

    function new(string name = "aes_drv", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        drv_bfm.wait_for_reset();
        `uvm_info(get_type_name(), "Reset released. Driver starting transaction loop.", UVM_MEDIUM)
        forever begin
            aes_sequence_item tx;
            aes_sequence_item rsp;
            seq_item_port.get_next_item(tx); // wait for the sequencer to put the next item.
            `uvm_info(get_type_name(), $sformatf("Driving TX: op=%s, data=0x%032h, key=0x%032h", tx.op.name(), tx.data, tx.key), UVM_HIGH)
            drv_bfm.drive_request(tx.op, tx.data, tx.key); // drive the request to the pins using the BFM
            if(tx.response_required) begin
                rsp = aes_sequence_item::type_id::create("rsp"); // Create the response object
                // call bfm to fill the response values.
                drv_bfm.get_response(rsp.valid_out, rsp.data_out);
                `uvm_info(get_type_name(), $sformatf("Received RSP from BFM: data_out=0x%032h", rsp.data_out), UVM_HIGH)
                rsp.set_id_info(tx); // couples the response with its associated tx.
                seq_item_port.item_done(rsp); // Complete the handshake returning the response
            end else begin
                seq_item_port.item_done(); // Complete the handshake
            end
        end
    endtask

endclass

`endif