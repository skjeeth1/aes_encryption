`include "def.sv"

module key_expansion #(
) (
    input  logic clk,
    input  logic rst,
    input  block key,
    input  word  g_func_out,
    output block round_key
);

  word round_words[4];

  always_comb begin
    round_words[0] = key[127:96] ^ g_func_out;
    round_words[1] = key[95:64] ^ round_words[0];
    round_words[2] = key[63:32] ^ round_words[1];
    round_words[3] = key[31:0] ^ round_words[2];
  end

  always_ff @(posedge clk) begin
    round_key[127:96] <= round_words[0];
    round_key[95:64]  <= round_words[1];
    round_key[63:32]  <= round_words[2];
    round_key[31:0]   <= round_words[3];
  end

endmodule


module g_function #(
    parameter int ROUND = 1
) (
    input  logic clk,
    input  logic rst,
    input  word  key_word,
    output word  g_func_out
);
  logic [7:0] g_func_word[4];

  always_comb begin
    g_func_word[0] = aes_sbox(key_word[23:16]) ^ round_const(ROUND);
    g_func_word[1] = aes_sbox(key_word[15:8]);
    g_func_word[2] = aes_sbox(key_word[7:0]);
    g_func_word[3] = aes_sbox(key_word[31:24]);
  end

  always_ff @(posedge clk) begin
    g_func_out <= {g_func_word[0], g_func_word[1], g_func_word[2], g_func_word[3]};
  end
endmodule


function automatic logic [7:0] round_const(input int round_num);
  case (round_num)
    1: round_const = 8'h01;
    2: round_const = 8'h02;
    3: round_const = 8'h04;
    4: round_const = 8'h08;
    5: round_const = 8'h10;
    6: round_const = 8'h20;
    7: round_const = 8'h40;
    8: round_const = 8'h80;
    9: round_const = 8'h1B;
    10: round_const = 8'h36;
    default: round_const = 8'h00;
  endcase
endfunction

