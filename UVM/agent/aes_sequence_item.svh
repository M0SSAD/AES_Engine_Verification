`ifndef AES_SEQUENCE_ITEM_SVH
`define AES_SEQUENCE_ITEM_SVH

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

    // Implement do_copy to duplicate member variables from a source object
    virtual function void do_copy(uvm_object rhs);
        aes_sequence_item rhs_item;
        if (!$cast(rhs_item, rhs)) begin
            `uvm_fatal("DO_COPY", "Cast failed inside do_copy()")
            return;
        end
        super.do_copy(rhs);
        this.op                = rhs_item.op;
        this.data              = rhs_item.data;
        this.key               = rhs_item.key;
        this.response_required = rhs_item.response_required;
        this.valid_out         = rhs_item.valid_out;
        this.data_out          = rhs_item.data_out;
    endfunction

    // Implement do_clone to allocate a new instance and copy state
    virtual function uvm_object do_clone();
        aes_sequence_item cloned_item;
        // Allocate using factory mechanism
        cloned_item = aes_sequence_item::type_id::create(get_name());
        cloned_item.copy(this);
        return cloned_item;
    endfunction
endclass


`endif 