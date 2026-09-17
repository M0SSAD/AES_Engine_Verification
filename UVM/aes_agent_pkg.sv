`ifndef AES_AGENT_PKG_SV
`define AES_AGENT_PKG_SV

package aes_agent_pkg;
    import uvm_pkg::*;
    import aes_pkg::*;
    `include "uvm_macros.svh"

    `include "./aes_sequence_item.svh"
    `include "./aes_drv.svh"
    typedef uvm_sequencer#(aes_sequence_item) aes_sequencer;
    `include "./aes_mon.svh"
    `include "./aes_agent_config.svh"
    `include "./aes_agent.svh"

endpackage

`endif 