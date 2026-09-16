`ifndef AES_PKG_SV
`define AES_PKG_SV

package aes_pkg;
    typedef enum logic {DECRYPT = 1'b0, ENCRYPT = 1'b1} aes_op_e;
endpackage

`endif