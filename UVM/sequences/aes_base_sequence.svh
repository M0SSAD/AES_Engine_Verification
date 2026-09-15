`ifndef AES_BASE_SEQUENCE_SV
`define AES_BASE_SEQUENCE_SV

virtual class aes_base_sequence extends uvm_sequence #(aes_sequence_item);
rand int num_of_txs = 20;
`uvm_object_utils(aes_base_sequence)

function new (string name = "aes_base_sequence");
    super.new(name);
endfunction

pure virtual task body();

endclass

`endif