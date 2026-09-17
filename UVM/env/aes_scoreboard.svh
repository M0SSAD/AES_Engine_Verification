`ifndef AES_SCOREBOARD_SVH
`define AES_SCOREBOARD_SVH

class aes_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(aes_scoreboard)

    // Status Counters
    int match_count    = 0;
    int mismatch_count = 0;

    // I need two ports, one to receive requests, and one to receive responses.
    uvm_analysis_imp#(aes_sequence_item, aes_scoreboard) scb_req_ap;
    uvm_tlm_analysis_fifo #(aes_sequence_item) scb_rsp_fifo;

    // I need a queue to store the expected response for each request, as the requests come in order.
    logic[127:0] expected_results[$];
    logic[127:0] expected_result;
    aes_sequence_item rsp;

    // Golden Model Variables
    int file_handle;
    string py_cmd;
    logic[127:0] result;

    function new(string name = "aes_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        scb_req_ap = new("scb_req_ap", this);
        scb_rsp_fifo = new("scb_rsp_fifo", this);
    endfunction

    extern function void write(aes_sequence_item tx);

    extern task run_phase(uvm_phase phase);

    extern function void report_phase(uvm_phase phase);
endclass

function void aes_scoreboard::write(aes_sequence_item tx);
    // Handle to point to the tx itself.
    aes_sequence_item req;
    // I need to get a request, process it using the golden model, store its value in the expected results queue.
    if(!$cast(req, tx.clone())) begin
        `uvm_fatal("CLONEFAIL", $sformatf("Cast failed for cloned sequence item at ", get_full_name()))
    end

    // I need to open a file, store the tx, and run the python golden model on it using $system.
    file_handle = $fopen("inputs.txt", "w"); // Create a file called inputs.txt with write previliege 
    if(!file_handle) begin
        `uvm_fatal("FILEFAIL", $sformatf("Creating an inputs.txt file failed."))
    end

    $fwrite(file_handle, "%32h\n%32h", req.data, req.key);
    $fclose(file_handle);

    // run the python golden model
    if(req.op == ENCRYPT) begin
        py_cmd = "python ./UVM/golden_model/aes_encrypt.py";
    end else if (req.op == DECRYPT) begin
        py_cmd = "python ./UVM/golden_model/aes_decrypt.py";
    end

    $system(py_cmd);

    // read the output.txt
    file_handle = $fopen("output.txt", "r");
    if(!file_handle) begin
        `uvm_fatal("FILEFAIL", $sformatf("Couldn't open output.txt"))
    end

    if(!$fscanf(file_handle, "%32h", result)) begin 
        `uvm_fatal("FILEFAIL", $sformatf("Couldn't read from output.txt!!"))
    end
    $fclose(file_handle);

    expected_results.push_back(result);
endfunction

task aes_scoreboard::run_phase(uvm_phase phase);
    forever begin
        scb_rsp_fifo.get(rsp);
        wait (expected_results.size() > 0);
        expected_result = expected_results.pop_front();

        if (!rsp.valid_out || rsp.data_out != expected_result) begin
            `uvm_error("SCB_MISMATCH", $sformatf("Data Mismatch! Expected: 0x%032h, Got: 0x%032h (valid_out=%0b)", expected_result, rsp.data_out, rsp.valid_out))
            mismatch_count++;
        end else begin
            `uvm_info("SCB_MATCH", $sformatf("MATCH! Result: 0x%032h", rsp.data_out), UVM_HIGH)
            match_count++;
        end
    end
endtask

function void aes_scoreboard::report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info("SCB_REPORT", "--------------------------------------------------", UVM_LOW)
    `uvm_info("SCB_REPORT", "            AES SCOREBOARD FINAL REPORT           ", UVM_LOW)
    `uvm_info("SCB_REPORT", "--------------------------------------------------", UVM_LOW)
    `uvm_info("SCB_REPORT", $sformatf("  Total Matches    : %0d", match_count), UVM_LOW)
    `uvm_info("SCB_REPORT", $sformatf("  Total Mismatches : %0d", mismatch_count), UVM_LOW)

    // Check for dangling unprocessed transactions
    if (expected_results.size() != 0) begin
        `uvm_error("SCB_REPORT", $sformatf("Queue Not Empty! %0d expected transactions were never completed by DUT.", expected_results.size()))
    end

    if (mismatch_count == 0 && expected_results.size() == 0 && match_count > 0) begin
        `uvm_info("SCB_REPORT", "  STATUS: TEST PASSED SUCCESSFULLY!", UVM_LOW)
    end else begin
        `uvm_error("SCB_REPORT", "  STATUS: TEST FAILED!")
    end
    `uvm_info("SCB_REPORT", "--------------------------------------------------", UVM_LOW)
endfunction
`endif