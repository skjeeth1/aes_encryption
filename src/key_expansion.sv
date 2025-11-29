import def_pkg::*;

module key_expansion #(
    parameter int ROUND
) (
    input logic clock,
    input logic reset,
    input logic i_tx_en,
    input block i_key,

    output logic o_tx_en,
    output block o_round_key
);

  word  round_words  [4];

  logic i_en_g_func;
  logic o_en_g_func;
  block o_key_g_func;
  block i_key_g_func;
  word  o_g_func;

  assign i_en_g_func  = i_tx_en;
  assign i_key_g_func = i_key;

  g_func #(
      .ROUND(ROUND)
  ) u_g_func (
      .clock(clock),
      .reset(reset),
      .i_tx_en(i_en_g_func),
      .i_key(i_key_g_func),
      .o_tx_en(o_en_g_func),
      .o_g_func(o_g_func),
      .o_key(o_key_g_func)
  );

  always_comb begin
    round_words[0] = o_key_g_func[127:96] ^ o_g_func;
    round_words[1] = o_key_g_func[95:64] ^ round_words[0];
    round_words[2] = o_key_g_func[63:32] ^ round_words[1];
    round_words[3] = o_key_g_func[31:0] ^ round_words[2];
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      o_tx_en <= 0;
      o_round_key <= 0;
    end else begin
      if (o_en_g_func) begin
        o_round_key[127:96] <= round_words[0];
        o_round_key[95:64]  <= round_words[1];
        o_round_key[63:32]  <= round_words[2];
        o_round_key[31:0]   <= round_words[3];
      end else begin
        o_round_key <= 0;
      end
      o_tx_en <= o_en_g_func;
    end
  end

endmodule


module g_func #(
    parameter int ROUND
) (
    input logic clock,
    input logic reset,
    input logic i_tx_en,
    input block i_key,

    output logic o_tx_en,
    output word  o_g_func,
    output block o_key
);

  logic [7:0] g_func_word[4];

  word i_key_col;
  assign i_key_col = i_key[31:0];

  always_comb begin
    g_func_word[0] = aes_sbox(i_key_col[23:16]) ^ round_const(ROUND);
    g_func_word[1] = aes_sbox(i_key_col[15:8]);
    g_func_word[2] = aes_sbox(i_key_col[7:0]);
    g_func_word[3] = aes_sbox(i_key_col[31:24]);
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      o_key <= 0;
      o_tx_en <= 0;
      o_g_func <= 0;
    end else begin
      if (i_tx_en) begin
        o_g_func <= (ROUND != 0) ?
        {g_func_word[0], g_func_word[1], g_func_word[2], g_func_word[3]} :
        i_key_col;

        o_key <= i_key;
      end else begin
        o_g_func <= 0;
        o_key <= 0;
      end
      o_tx_en <= i_tx_en;
    end
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

