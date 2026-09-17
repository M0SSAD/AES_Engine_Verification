`ifndef AES_TEST_PKG_SV
`define AES_TEST_PKG_SV

package aes_test_pkg;
    import uvm_pkg::*;
    import aes_pkg::*;
    import aes_agent_pkg::*;
    import aes_env_pkg::*;
    import aes_seq_pkg::*;
    `include "uvm_macros.svh"

    `include "./aes_base_test.svh"
    `include "./aes_encrypt_test.svh"
    `include "./aes_decrypt_test.svh"
    `include "./aes_encrypt_decrypt_test.svh"
endpackage

`endif 