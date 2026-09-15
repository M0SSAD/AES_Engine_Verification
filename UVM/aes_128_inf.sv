interface aes_128_inf (input clk, rst_n);
logic valid_in;
logic flag;
logic [127:0] input_text_128;
logic [127:0] cipher_key_128;

logic valid_out;
logic [127:0] cipher_text_128;
logic [127:0] plain_text_128;
endinterface