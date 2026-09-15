`ifndef AES_ENCRYPT_DECRYPT_SEQUENCE_SV
`define AES_ENCRYPT_DECRYPT_SEQUENCE_SV

class aes_encrypt_decrypt_sequence extends aes_base_sequence;

`uvm_object_utils(aes_encrypt_decrypt_sequence)

function new (string name = "aes_encrypt_decrypt_sequence");
    super.new(name);
endfunction

extern task body();

endclass

task aes_encrypt_decrypt_sequence::body();
    aes_sequence_item encrypt_tx;
    aes_sequence_item encrypt_rsp;
    aes_sequence_item decrypt_tx;
    aes_sequence_item decrypt_rsp;

    for(int i = 0; i < num_of_txs; i++) begin
        `uvm_info(get_type_name(), $sformatf("Generating transactio %0d", i) ,UVM_LOW)
        // Encryption Request
        encrypt_tx = aes_sequence_item::type_id::create("encrypt_tx");
        start_item(encrypt_tx);
        assert(encrypt_tx.randomize() with {flag == 1;})
            else `uvm_error("RAND_FAIL", {"Randomization failed in ", get_full_name(),"::body"});

        encrypt_tx.response_required = 1;
        finish_item(encrypt_tx);

        // Encryption Response
        get_response(encrypt_rsp);
        `uvm_info(get_type_name(), $sformatf("Ciphertext = %032h", encrypt_rsp.cipher_text_128), UVM_LOW)

        // Decryption Request
        decrypt_tx = aes_sequence_item::type_id::create("decrypt_tx");
        start_item(decrypt_tx);
        assert(decrypt_tx.randomize() with {flag == 0; input_text_128 == encrypt_rsp.cipher_text_128; cipher_key_128 == encrypt_tx.cipher_key_128;})
            else `uvm_error("RAND_FAIL", {"Randomization failed in ", get_full_name(),"::body"});
        decrypt_tx.response_required = 1;
        finish_item(decrypt_tx);

        // Decryption response
        get_response(decrypt_rsp);
        `uvm_info(get_type_name(), $sformatf("Decrypted = %032h", decrypt_rsp.plain_text_128), UVM_LOW)
    end
endtask

`endif