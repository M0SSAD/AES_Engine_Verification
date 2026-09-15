module AES_128(
    input clk, rst_n, valid_in, flag,
    input [127:0] input_text_128,
    input [127:0] cipher_key_128,
    output reg valid_out,
    output reg [127:0] cipher_text_128,
    output reg [127:0] plain_text_128
    );

    wire [127:0] enc_output;
    wire [127:0] dec_output;

    AES_Encrypt enc(.in(input_text_128), .key(cipher_key_128), .out(enc_output));
    AES_Decrypt dec(.in(input_text_128), .key(cipher_key_128), .out(dec_output));

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            valid_out <= 0;
            cipher_text_128 <= 0;
            plain_text_128 <= 0;
        end else if (flag && valid_in) begin
            valid_out <= 1'b1;
            cipher_text_128 <= enc_output;
        end else if (!flag && valid_in) begin
            valid_out <= 1'b1;
            plain_text_128 <= dec_output;
        end else begin
            valid_out <= 1'b0;
        end
    end
    
endmodule