if ![file exists work] {
    vlib work
    vlog ./RTL/*.v
}

vlog ./UVM/aes_pkg.sv

vlog ./UVM/aes_128_inf.sv 
vlog ./UVM/aes_drv_bfm.sv
vlog ./UVM/aes_mon_bfm.sv

vlog ./UVM/aes_agent_pkg.sv
vlog ./UVM/aes_seq_pkg.sv
vlog ./UVM/aes_env_pkg.sv

vlog ./UVM/aes_hdl_top.sv ./UVM/aes_hvl_top.sv
vsim -c aes_hdl_top aes_hvl_top -do "quit -f"