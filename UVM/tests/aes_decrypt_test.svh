`ifndef AES_DECRYPT_TEST_SVH
`define AES_DECRYPT_TEST_SVH

class aes_decrypt_test extends aes_base_test;
    `uvm_component_utils(aes_decrypt_test)

    function new(string name = "aes_decrypt_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        aes_decrypt_sequence seq;
        seq = aes_decrypt_sequence::type_id::create("seq");

        phase.raise_objection(this);
        `uvm_info(get_type_name(), "Starting aes_decrypt_sequence...", UVM_LOW)
        seq.start(m_env.env_agent.ag_seq);
        `uvm_info(get_type_name(), "Completed aes_decrypt_sequence.", UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass

`endif
