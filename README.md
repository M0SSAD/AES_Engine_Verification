# AES-128 UVM Verification Environment

A SystemVerilog/UVM verification environment for an AES-128 encryption/decryption RTL implementation.

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

The DUT registers its outputs on the rising edge of `clk`.

## Current UVM Architecture

The current environment contains:

```text
                         HVL TOP
                            |
                         run_test()
                            |
                         UVM TEST
                            |
                        SEQUENCER
                            |
                         DRIVER
                            |
                    virtual BFM handle
                            |
                        DRIVER BFM
                            |
                       AES interface
                            |
                           DUT
```

The project uses a **dual-top architecture**:

```text
aes_hdl_top
    ├── clock
    ├── reset
    ├── interface
    ├── DUT
    ├── driver BFM
    └── UVM config_db setup

aes_hvl_top
    └── run_test()
```

- This separates the HDL-side components from the HVL/UVM side.
- Abstracts low-level signal and bus-cycle details from the UVM environment.
- Makes the testbench more reusable and portable across simulation and hardware-assisted verification/emulation.

## Transaction

The current transaction is `aes_sequence_item`.

It contains:

### Request fields

```systemverilog
rand logic flag;
rand logic [127:0] input_text_128;
rand logic [127:0] cipher_key_128;
```

### Response fields

```systemverilog
logic valid_out;
logic [127:0] cipher_text_128;
logic [127:0] plain_text_128;
```

It also contains:

```systemverilog
bit response_required;
```

This is metadata used by the driver to determine whether the sequence explicitly requires the DUT response to be returned through the UVM sequence-driver response mechanism.

`valid_in` is intentionally **not** part of the transaction. It is a pin-level protocol signal controlled by the driver BFM.

## Sequences

The current sequence structure includes:

- `aes_base_sequence`
- `aes_encrypt_sequence`
- `aes_decrypt_sequence`
- `aes_encrypt_decrypt_sequence`

The base sequence is an abstract sequence that provides the common configuration for derived sequences.

### Encrypt / Decrypt sequences

The encryption and decryption sequences generate randomized AES transactions while constraining:

```text
op = 1 → encryption
op = 0 → decryption
```

### Encrypt → Decrypt sequence

The combined sequence demonstrates a sequence-level dependency:

```text
Generate encryption transaction
        |
        v
Receive encryption response
        |
        v
Use ciphertext as decryption input
        |
        v
Generate decryption transaction
```

This is the current use case for the transaction response mechanism.

## Driver

The driver uses:

```systemverilog
seq_item_port.try_next_item(tx)
```

rather than `get_next_item()`.

This allows the driver to operate cycle-by-cycle allowing to deassert valid_in if there is no transactions:

```text
Transaction available
        |
        +---- YES ---> drive transaction
        |
        +---- NO ----> drive idle cycle
```

### Request driving

The BFM drives request signals using NBA assignments at a clock edge.

Conceptually:

```text

BFM schedules request using NBA
   |
   v
@(Clock N Active Region) Pins contain request
   |
   v
DUT consumes request
```

### Idle cycles

When the sequencer has no transaction available:

```systemverilog
drv_bfm.drive_idle();
```

drives:

```systemverilog
valid_in <= 1'b0;
```

### Responses

For ordinary transactions, the driver completes the sequence item with:

```systemverilog
seq_item_port.item_done();
```

For transactions with:

```systemverilog
response_required = 1;
```

the driver waits a cycle, captures the response, associates it with the original transaction using:

```systemverilog
rsp.set_id_info(tx);
```

and completes the item with:

```systemverilog
seq_item_port.item_done(rsp);
```

## Driver BFM

The driver BFM currently provides four operations:

```systemverilog
wait_for_reset()
drive_request(...)
drive_idle()
get_response(...)
```

The BFM is responsible for translating transaction-level driver operations into pin-level activity.

It contains no UVM classes or UVM-specific logic.

## Compilation

The current environment can be compiled incrementally with QuestaSim.

Example:

```tcl
vlib work

vlog ./RTL/*.v

vlog ./UVM/aes_128_inf.sv
vlog ./UVM/aes_drv_bfm.sv

vlog ./UVM/aes_agent_pkg.sv
vlog ./UVM/aes_seq_pkg.sv

vlog ./UVM/aes_hdl_top.sv
vlog ./UVM/aes_hvl_top.sv
```

The current dual-top structure can be elaborated with:

```tcl
vsim -c aes_hdl_top aes_hvl_top -do "quit -f"
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
│   ├── golden_model/
│   ├── sequences/
│   │   ├── aes_base_sequence.svh
│   │   ├── aes_decrypt_sequence.svh
│   │   ├── aes_encrypt_sequence.svh
│   │   └── aes_encrypt_decrypt_sequence.svh
│   │
│   ├── aes_128_inf.sv
│   ├── aes_agent_pkg.sv
│   ├── aes_drv.svh
│   ├── aes_drv_bfm.sv
│   ├── aes_hdl_top.sv
│   ├── aes_hvl_top.sv
│   ├── aes_sequence_item.svh
│   └── aes_seq_pkg.sv
│
└── README.md
```
