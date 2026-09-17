# AES-128 UVM Verification Environment

A SystemVerilog/UVM verification environment for an AES-128 encryption/decryption RTL implementation strictly following the Siemens UVM Cookbook guidelines.

## DUT

The design under verification is an AES-128 engine supporting both encryption and decryption.

The top-level module is:

```text
AES_128
```

### Interface

| Signal            | Description                                  |
| ----------------- | -------------------------------------------- |
| `clk`             | Clock                                        |
| `rst_n`           | Active-low asynchronous reset                |
| `valid_in`        | Indicates a valid input transaction          |
| `flag`            | Selects encryption (`1`) or decryption (`0`) |
| `input_text_128`  | 128-bit input plaintext/ciphertext           |
| `cipher_key_128`  | 128-bit AES key                              |
| `valid_out`       | Indicates a valid output                     |
| `cipher_text_128` | Encryption result                            |
| `plain_text_128`  | Decryption result                            |

The DUT registers its outputs on the rising edge of `clk` with a 1-cycle latency. When `valid_out` is asserted, the unused output bus is driven to zero.

## Current UVM Architecture

The environment is structured as an emulation-ready, dual-top architecture:

```text
                             HVL TOP (aes_hvl_top)
                                      |
                                  run_test()
                                      |
                                   UVM TEST (aes_base_test / aes_encrypt_test)
                                      |
                                   UVM ENV (aes_env)
                                      |
                                  UVM AGENT (aes_agent)
                         +------------+------------+
                         |                         |
                     SEQUENCER                  MONITOR (aes_mon)
                         |                         |
                      DRIVER (aes_drv)      virtual BFM handle
                         |                         |
                 virtual BFM handle           MONITOR BFM (aes_mon_bfm)
                         |                         |
                    DRIVER BFM (aes_drv_bfm)       |
                         |                         |
                         +------------+------------+
                                      |
                                AES Interface (aes_128_inf)
                                      |
                             HDL TOP / DUT (AES_128)
```

The project strictly separates HDL and HVL domains:

```text
aes_hdl_top (HDL Domain)
    ├── Clock generator
    ├── Reset generator
    ├── Pin bundle interface (aes_128_inf)
    ├── DUT instance (AES_128)
    ├── Driver BFM (aes_drv_bfm)
    ├── Monitor BFM (aes_mon_bfm)
    └── uvm_config_db registration of virtual BFM handles

aes_hvl_top (HVL Domain)
    └── run_test()
```

- HDL-side modules and interfaces house synthesizable RTL, structural wires, and pin-level BFMs.
- HVL-side contains testbench classes (proxy transactors, configurations, sequences, and tests).
- Follows the split-transactor approach for emulator portability and simulator performance.

## Transaction

The core transaction object is `aes_sequence_item`.

It contains:

### Request fields

```systemverilog
rand aes_op_e      op;              // ENCRYPT (1'b1) or DECRYPT (1'b0)
rand logic [127:0] data;
rand logic [127:0] key;
```

### Response fields

```systemverilog
logic              valid_out;
logic [127:0]      data_out;
```

### Metadata

```systemverilog
bit                response_required;
```

Used when a sequence explicitly requests the driver to return the monitored DUT response via `item_done(rsp)`.

`valid_in` is intentionally **not** part of the transaction item; it is a pin-level protocol control managed by the BFM.

## Sequences

The sequence package (`aes_seq_pkg`) includes:

- `aes_base_sequence`: Abstract base sequence parameterized to `aes_sequence_item`.
- `aes_encrypt_sequence`: Generates randomized transactions constrained to `op == ENCRYPT`.
- `aes_decrypt_sequence`: Generates randomized transactions constrained to `op == DECRYPT`.
- `aes_encrypt_decrypt_sequence`: Generates a coupled sequence:

```text
Generate encryption transaction (response_required = 1)
        |
        v
Receive encryption response (get_response(rsp))
        |
        v
Use ciphertext as decryption input (data == encrypt_rsp.data_out)
        |
        v
Generate decryption transaction
```

## Driver & Driver BFM

### Driver Proxy (`aes_drv`)

- Extends `uvm_driver #(aes_sequence_item)`.
- Obtains its BFM handle directly from `aes_agent_config` (assigned by the agent).
- In `run_phase`:
  1. Blocks on `drv_bfm.wait_for_reset()`.
  2. Fetches items via `seq_item_port.get_next_item(tx)`.
  3. Hands off transaction parameters to `drv_bfm.drive_request(tx.op, tx.data, tx.key)`.
  4. Returns response if `tx.response_required == 1`, else completes with `seq_item_port.item_done()`.

### Driver BFM (`aes_drv_bfm`)

Translates transaction-level calls into pin-level signal toggles:

```systemverilog
task wait_for_reset();
task drive_request(input aes_op_e op, input logic [127:0] data, input logic [127:0] key);
task get_response(output logic valid_out, output logic [127:0] data_out);
```

- Drives inputs before `posedge clk` using non-blocking assignments (`<=`), ensuring stable setup timing for the DUT.

## Monitor & Monitor BFM

### Monitor Proxy (`aes_mon`)

- Extends `uvm_monitor`.
- Exposes two independent analysis ports:
  - `uvm_analysis_port #(aes_sequence_item) req_ap;`
  - `uvm_analysis_port #(aes_sequence_item) rsp_ap;`
- In `run_phase`:
  - Waits for reset deassertion.
  - Spawns two parallel threads via `fork ... join`:
    - Thread 1: Continuously samples requests and broadcasts via `req_ap`.
    - Thread 2: Continuously samples responses and broadcasts via `rsp_ap`.

### Monitor BFM (`aes_mon_bfm`)

Passively monitors interface activity without influencing the bus:

```systemverilog
task wait_for_reset();
task sample_request(output aes_op_e op, output logic [127:0] data, output logic [127:0] key);
task sample_response(output logic valid_out, output logic [127:0] data_out);
```

- Samples strictly on `posedge clk`.
- Employs static casting `op = aes_op_e'(intf.flag)` for strict type safety.
- Captures output data via bitwise OR (`intf.cipher_text_128 | intf.plain_text_128`) without creating a dependency on input flags.

## Agent & Agent Configuration

### Agent Configuration (`aes_agent_config`)

- Encapsulates virtual interface handles (`drv_bfm`, `mon_bfm`).
- Defines operating mode: `uvm_active_passive_enum is_active = UVM_ACTIVE;`.
- Controls sub-component coverage and scoreboard knobs.

### Agent (`aes_agent`)

- Extends `uvm_agent`.
- Retrieves `aes_agent_config` from `uvm_config_db`.
- Unconditionally builds `aes_mon`.
- Conditionally builds `aes_drv` and `aes_sequencer` when `is_active == UVM_ACTIVE`.
- Assigns BFM handles directly to child components.
- Exposes monitor analysis ports hierarchically (`req_ap = ag_mon.req_ap;`, `rsp_ap = ag_mon.rsp_ap;`).

## Environment & Environment Configuration

### Environment Configuration (`aes_env_config`)

- Contains child `aes_agent_config` instance.
- Flags: `has_scoreboard`, `has_subscriber`.

### Environment (`aes_env`)

- Extends `uvm_env`.
- Retrieves `aes_env_config` from `uvm_config_db`.
- Unpacks `ag_cfg` and publishes it via `uvm_config_db#(aes_agent_config)::set(this, "env_agent", "ag_cfg", env_cfg.ag_cfg)`.
- Instantiates `env_agent`.
- Prepares connection hooks for upcoming Scoreboard and Functional Coverage subscriber.

## Tests

The test layer (`aes_test_pkg`) includes:

- `aes_base_test`:
  - Retrieves `drv_bfm` and `mon_bfm` handles from `uvm_config_db`.
  - Creates and populates `env_cfg` and `ag_cfg`.
  - Configures `uvm_config_db` for `m_env`.
  - Builds `m_env`.
  - Calls `uvm_top.print_topology()` in `end_of_elaboration_phase`.
- `aes_encrypt_test`: Extends `aes_base_test`, executes `aes_encrypt_sequence`.
- `aes_decrypt_test`: Extends `aes_base_test`, executes `aes_decrypt_sequence`.
- `aes_encrypt_decrypt_test`: Extends `aes_base_test`, executes `aes_encrypt_decrypt_sequence`.

## Compilation & Simulation

The testbench is compiled modularly with QuestaSim via [`run.do`](./run.do):

```tcl
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
vsim -c aes_hdl_top aes_hvl_top +UVM_TESTNAME=aes_encrypt_test -do "run -all; quit -f"
```

To run a different test, pass `+UVM_TESTNAME=<test_name>`:

```tcl
vsim -c aes_hdl_top aes_hvl_top +UVM_TESTNAME=aes_decrypt_test -do "run -all; quit -f"
vsim -c aes_hdl_top aes_hvl_top +UVM_TESTNAME=aes_encrypt_decrypt_test -do "run -all; quit -f"
```

## Directory Structure

```text
AES/
├── RTL/
│   ├── AES.v
│   ├── AES_128.v
│   ├── AES_Decrypt.v
│   ├── AES_Encrypt.v
│   ├── addRoundKey.v
│   ├── decryptRound.v
│   ├── encryptRound.v
│   ├── inverseMixColumns.v
│   ├── inverseSbox.v
│   ├── inverseShiftRows.v
│   ├── inverseSubBytes.v
│   ├── keyExpansion.v
│   ├── mixColumns.v
│   ├── sbox.v
│   ├── shiftRows.v
│   └── subBytes.v
│
├── UVM/
│   ├── common/
│   │   └── aes_pkg.sv
│   │
│   ├── tb/
│   │   ├── aes_128_inf.sv
│   │   ├── aes_hdl_top.sv
│   │   └── aes_hvl_top.sv
│   │
│   ├── agent/
│   │   ├── aes_agent_pkg.sv
│   │   ├── aes_sequence_item.svh
│   │   ├── aes_agent_config.svh
│   │   ├── aes_drv.svh
│   │   ├── aes_drv_bfm.sv
│   │   ├── aes_mon.svh
│   │   ├── aes_mon_bfm.sv
│   │   └── aes_agent.svh
│   │
│   ├── env/
│   │   ├── aes_env_pkg.sv
│   │   ├── aes_env_config.svh
│   │   └── aes_env.svh
│   │
│   ├── sequences/
│   │   ├── aes_seq_pkg.sv
│   │   ├── aes_base_sequence.svh
│   │   ├── aes_encrypt_sequence.svh
│   │   ├── aes_decrypt_sequence.svh
│   │   └── aes_encrypt_decrypt_sequence.svh
│   │
│   ├── tests/
│   │   ├── aes_test_pkg.sv
│   │   ├── aes_base_test.svh
│   │   ├── aes_encrypt_test.svh
│   │   ├── aes_decrypt_test.svh
│   │   └── aes_encrypt_decrypt_test.svh
│   │
│   └── golden_model/
│       ├── aes_encrypt.py
│       └── aes_decrypt.py
│
├── run.do
└── README.md
```
