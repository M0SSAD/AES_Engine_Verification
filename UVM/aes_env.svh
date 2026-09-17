`ifndef AES_ENV_SVH
`define AES_ENV_SVH

class aes_env extends uvm_env;

    `uvm_component_utils(aes_env)

    aes_env_config env_cfg;
    aes_agent env_agent;

    // TODO: Scoreboard & Subscriper handles

    function new(string name = "aes_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(aes_env_config)::get(this, "", "env_cfg", env_cfg)) begin
            `uvm_fatal("NOCFG", $sformatf("No CONFIG Object was placed in the DB for the %0s", get_full_name()))
        end

        env_agent = aes_agent::type_id::create("env_agent", this);
        uvm_config_db#(aes_agent_config)::set(this, "env_agent", "ag_cfg", env_cfg.ag_cfg);

        if(env_cfg.has_scoreboard) begin
            // TODO Create the scoreboard
        end

        if(env_cfg.has_subscriber) begin
            // TODO Create the subscriber
        end
    endfunction
    
    function void connect_phase(uvm_phase phase);
        if(env_cfg.has_scoreboard) begin
            // TODO Connect the scoreboard to the agent ap.
        end

        if(env_cfg.has_subscriber) begin
            // TODO Connect the subscriber to the agent ap.
        end
    endfunction
endclass


`endif