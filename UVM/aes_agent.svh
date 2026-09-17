`ifndef AES_AGENT_SVH
`define AES_AGENT_SVH

class aes_agent extends uvm_agent;

    `uvm_component_utils(aes_agent)

    aes_agent_config ag_cfg;
    uvm_analysis_port#(aes_sequence_item) req_ap;
    uvm_analysis_port#(aes_sequence_item) rsp_ap;


    aes_sequencer ag_seq;
    aes_drv ag_drv;
    aes_mon ag_mon;

    function new(string name = "aes_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(aes_agent_config)::get(this, "", "ag_cfg", ag_cfg)) begin
            `uvm_fatal("NOCFG", $sformatf("No CONFIG Object was placed in the DB for the %0s", get_full_name()))
        end
        ag_mon = aes_mon::type_id::create("ag_mon", this);

        if(ag_cfg.is_active) begin
            ag_seq = aes_sequencer::type_id::create("ag_seq", this);
            ag_drv = aes_drv::type_id::create("ag_drv", this);
        end
    endfunction
    
    function void connect_phase(uvm_phase phase);
        ag_mon.mon_bfm = ag_cfg.mon_bfm; // Connect the bfm handle in the monitor to the virtual interface.
        // expose the ap in them monitor side through teh agent.
        req_ap = ag_mon.req_ap;
        rsp_ap = ag_mon.rsp_ap;
        
        if(ag_cfg.is_active) begin
            ag_drv.drv_bfm = ag_cfg.drv_bfm;
            ag_drv.seq_item_port.connect(ag_seq.seq_item_export);
        end
    endfunction
endclass


`endif