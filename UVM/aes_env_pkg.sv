`ifndef AES_ENV_PKG_SV
`define AES_ENV_PKG_SV

package aes_env_pkg;
    import uvm_pkg::*;
    import aes_pkg::*;
    import aes_agent_pkg::*;
    `include "uvm_macros.svh"

    `include "./aes_env_config.svh"
    `include "./aes_env.svh"

endpackage

`endif 