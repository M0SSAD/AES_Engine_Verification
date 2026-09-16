`ifndef AES_SEQUENCE_ITEM
`define AES_SEQUENCE_ITEM

class aes_sequence_item extends uvm_sequence_item;
    rand aes_op_e op;
    rand logic [127:0] data;
    rand logic [127:0] key;

    bit response_required = 0;

    logic valid_out;
    logic [127:0] data_out;

    `uvm_object_utils(aes_sequence_item)

    function new(string name = "aes_sequence_item");
        super.new(name);
    endfunction

    // Constraints
    // No Need for global constraints
endclass


`endif 