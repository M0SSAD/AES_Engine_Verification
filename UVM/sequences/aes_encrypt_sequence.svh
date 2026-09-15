`ifndef AES_ENCRYPT_SEQUENCE_SV
`define AES_ENCRYPT_SEQUENCE_SV

class aes_encrypt_sequence extends aes_base_sequence;

`uvm_object_utils(aes_encrypt_sequence)

function new (string name = "aes_encrypt_sequence");
    super.new(name);
endfunction

extern task body();

endclass

task aes_encrypt_sequence::body();
    aes_sequence_item tx;
    for(int i = 0; i < num_of_txs; i++) begin
        `uvm_info(get_type_name(), $sformatf("Generating transaction %0d", i) ,UVM_LOW)
        tx = aes_sequence_item::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {flag == 1;})
            else `uvm_error("RAND_FAIL", {"Randomization failed in ", get_full_name(),"::body"});
        finish_item(tx);
    end


endtask

`endif