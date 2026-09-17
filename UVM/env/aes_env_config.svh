`ifndef AES_ENV_CONFIG_SVH
`define AES_ENV_CONFIG_SVH

class aes_env_config extends uvm_object;
    `uvm_object_utils(aes_env_config)

    function new(string name = "aes_env_config");
        super.new(name);
    endfunction 

    aes_agent_config ag_cfg;

    bit has_subscriber = 1;
    bit has_scoreboard = 1;
endclass


`endif