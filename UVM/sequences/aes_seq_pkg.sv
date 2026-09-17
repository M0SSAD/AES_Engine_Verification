`ifndef AES_SEQ_PKG_SV
`define AES_SEQ_PKG_SV

package aes_seq_pkg;
    import uvm_pkg::*;
    import aes_pkg::*;
    import aes_agent_pkg::*;
    `include "uvm_macros.svh"

    `include "./aes_base_sequence.svh"
    `include "./aes_decrypt_sequence.svh"
    `include "./aes_encrypt_sequence.svh"
    `include "./aes_encrypt_decrypt_sequence.svh"
endpackage

`endif