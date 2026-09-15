`ifndef AES_SEQUENCE_ITEM
`define AES_SEQUENCE_ITEM

class aes_sequence_item extends uvm_sequence_item;
    rand logic flag;
    rand logic [127:0] input_text_128;
    rand logic [127:0] cipher_key_128;

    bit response_required = 0;

    logic valid_out;
    logic [127:0] cipher_text_128;
    logic [127:0] plain_text_128;

    `uvm_object_utils(aes_sequence_item)

    function new(string name = "aes_sequence_item");
        super.new(name);
    endfunction

    // Constraints
    // No Need for global constraints
endclass


`endif 