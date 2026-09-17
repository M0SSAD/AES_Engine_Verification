`ifndef AES_BASE_TEST_SVH
`define AES_BASE_TEST_SVH

virtual class aes_base_test extends uvm_test;

    `uvm_component_utils(aes_base_test)

    aes_agent_config ag_cfg;
    aes_env_config env_cfg;

    aes_env m_env;

    function new(string name = "aes_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Create the configuration object of the env and the agent, configure them and store them in the db. 
        env_cfg = aes_env_config::type_id::create("env_cfg", this);
        ag_cfg = aes_agent_config::type_id::create("ag_cfg", this);
        // THE DEFAULT CONFIGURATIONS ARE JUST FINEEEEE

        // get the virtual interface from the DB and put them in agent configuration object
        if (!uvm_config_db#(virtual aes_drv_bfm)::get(this, "", "drv_bfm", ag_cfg.drv_bfm))
            `uvm_fatal("VIF_GET", $sformatf("Cannot get drv_bfm from config_db at %0s", get_full_name()))
        if (!uvm_config_db#(virtual aes_mon_bfm)::get(this, "", "mon_bfm", ag_cfg.mon_bfm))
            `uvm_fatal("VIF_GET", $sformatf("Cannot get mon_bfm from config_db at %0s", get_full_name()))

        // put the ag_cfg object into the env_cfg object dedicated handle.
        env_cfg.ag_cfg = ag_cfg;

        // set the configuration object for the environemnt in the DB
        uvm_config_db#(aes_env_config)::set(this, "m_env", "env_cfg", env_cfg);

        // build the env
        m_env = aes_env::type_id::create("m_env", this);
        `uvm_info(get_type_name(), "aes_base_test: build_phase completed successfully.", UVM_MEDIUM)
    endfunction

    pure virtual task run_phase(uvm_phase phase);

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction
endclass

`endif