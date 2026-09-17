`ifndef AES_AGENT_CONFIG_SVH
`define AES_AGENT_CONFIG_SVH

class aes_agent_config extends uvm_object;

    `uvm_object_utils(aes_agent_config)

    function new(string name = "aes_agent_config");
        super.new(name);
    endfunction

    uvm_active_passive_enum is_active = UVM_ACTIVE;

    virtual aes_mon_bfm mon_bfm;
    virtual aes_drv_bfm drv_bfm;

    bit has_functional_coverage = 0;
    bit has_scoreboard = 0;
endclass


`endif