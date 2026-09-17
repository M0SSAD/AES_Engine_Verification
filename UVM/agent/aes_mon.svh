`ifndef AES_MON_SVH
`define AES_MON_SVH

class aes_mon extends uvm_monitor;
    `uvm_component_utils(aes_mon)

    virtual aes_mon_bfm mon_bfm;
    uvm_analysis_port#(aes_sequence_item) req_ap;
    uvm_analysis_port#(aes_sequence_item) rsp_ap;

    function new(string name = "aes_mon", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        req_ap = new("req_ap", this);
        rsp_ap = new("rsp_ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        aes_sequence_item aes_req;
        aes_sequence_item aes_rsp;
        mon_bfm.wait_for_reset();
        `uvm_info(get_type_name(), "Reset released. Monitor starting sampling loops.", UVM_MEDIUM)
        // Spawn two threads, one to observe valid requests, sample them and write them on the ap, and the other to observe the responses and pass them through the dedicated ap.
        fork
            begin
                forever begin
                    aes_req = aes_sequence_item::type_id::create("aes_req");
                    mon_bfm.sample_request(aes_req.op, aes_req.data, aes_req.key);
                    `uvm_info(get_type_name(), $sformatf("REQ_DATA: %32h, REQ_KEY: %32h", aes_req.data, aes_req.key), UVM_LOW)
                    `uvm_info(get_type_name(), $sformatf("Monitored REQ: op=%s, data=0x%032h, key=0x%032h", aes_req.op.name(), aes_req.data, aes_req.key), UVM_HIGH)
                    req_ap.write(aes_req);
                end
            end
            begin
                forever begin
                    aes_rsp = aes_sequence_item::type_id::create("aes_rsp");
                    mon_bfm.sample_response(aes_rsp.valid_out, aes_rsp.data_out);
                    `uvm_info(get_type_name(), $sformatf("Monitored RSP: valid_out=%0b, data_out=0x%032h", aes_rsp.valid_out, aes_rsp.data_out), UVM_HIGH)
                    rsp_ap.write(aes_rsp);
                end
            end
        join
    endtask
endclass

`endif 