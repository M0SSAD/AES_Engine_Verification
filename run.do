if ![file exists work] {
    vlib work
    vlog ./RTL/*.v
}

vlog ./UVM/common/aes_pkg.sv

vlog ./UVM/tb/aes_128_inf.sv 
vlog ./UVM/agent/aes_drv_bfm.sv
vlog ./UVM/agent/aes_mon_bfm.sv

vlog ./UVM/agent/aes_agent_pkg.sv
vlog ./UVM/sequences/aes_seq_pkg.sv
vlog ./UVM/env/aes_env_pkg.sv
vlog ./UVM/tests/aes_test_pkg.sv

vlog ./UVM/tb/aes_hdl_top.sv ./UVM/tb/aes_hvl_top.sv
vsim -c aes_hdl_top aes_hvl_top +UVM_TESTNAME=aes_encrypt_decrypt_test +UVM_VERBOSITY=UVM_HIGH -do "run -all; quit -f"
