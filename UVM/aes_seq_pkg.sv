`ifndef AES_SEQ_PKG_SV
`define AES_SEQ_PKG_SV

package aes_seq_pkg;
    import uvm_pkg::*;
    import aes_pkg::*;
    import aes_agent_pkg::*;
    `include "uvm_macros.svh"

    `include "./sequences/aes_base_sequence.svh"
    `include "./sequences/aes_decrypt_sequence.svh"
    `include "./sequences/aes_encrypt_sequence.svh"
    `include "./sequences/aes_encrypt_decrypt_sequence.svh"
endpackage

`endif