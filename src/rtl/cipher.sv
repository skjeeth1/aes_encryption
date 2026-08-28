import def_pkg::*;


module sub_bytes (
    input  block i_state,
    output block o_state
);
  genvar i;
  generate
    for (i = 16; i > 0; i = i - 1) begin : gen_sub_block
      assign o_state[(i*8)-1-:8] = aes_sbox(i_state[(i*8)-1-:8]);
    end
  endgenerate
endmodule


module shift_rows (
    input  block i_state,
    output block o_state
);
  logic [7:0] s_state[16];
  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_shift_rows
      assign s_state[i] = i_state[127-i*8-:8];
    end
  endgenerate

  assign o_state = {
    s_state[0],
    s_state[5],
    s_state[10],
    s_state[15],
    s_state[4],
    s_state[9],
    s_state[14],
    s_state[3],
    s_state[8],
    s_state[13],
    s_state[2],
    s_state[7],
    s_state[12],
    s_state[1],
    s_state[6],
    s_state[11]
  };
endmodule


module mix_word #(
) (
    input  word i_word,
    output word o_word
);
  function automatic logic [7:0] gf_mul(input logic [7:0] val, input logic [1:0] op);
    begin
      gf_mul = ((op & 2) ? (((val & 'h80) ? 'h1b : 0) ^ (val << 1)) : 0) ^ ((op & 1) ? val : 0);
    end
  endfunction

  word mul_word[3];
  genvar i;
  generate
    for (i = 4; i > 0; i = i - 1) begin : gen_o_array_mul
      assign mul_word[0][(i*8)-1-:8] = gf_mul(i_word[(i*8)-1-:8], 1);
      assign mul_word[1][(i*8)-1-:8] = gf_mul(i_word[(i*8)-1-:8], 2);
      assign mul_word[2][(i*8)-1-:8] = gf_mul(i_word[(i*8)-1-:8], 3);
    end
  endgenerate

  assign o_word[(8*4)-1-:8] = mul_word[1][(8*4)-1-:8] ^ mul_word[2][(8*3)-1-:8] ^ mul_word[0][(8*2)-1-:8] ^ mul_word[0][(8*1)-1-:8];
  assign o_word[(8*3)-1-:8] = mul_word[0][(8*4)-1-:8] ^ mul_word[1][(8*3)-1-:8] ^ mul_word[2][(8*2)-1-:8] ^ mul_word[0][(8*1)-1-:8];
  assign o_word[(8*2)-1-:8] = mul_word[0][(8*4)-1-:8] ^ mul_word[0][(8*3)-1-:8] ^ mul_word[1][(8*2)-1-:8] ^ mul_word[2][(8*1)-1-:8];
  assign o_word[(8*1)-1-:8] = mul_word[2][(8*4)-1-:8] ^ mul_word[0][(8*3)-1-:8] ^ mul_word[0][(8*2)-1-:8] ^ mul_word[1][(8*1)-1-:8];
endmodule


module mix_columns (
    input  block i_state,
    output block o_state
);
  genvar i;
  generate
    for (i = 4; i > 0; i = i - 1) begin : gen_mix_columns
      mix_word u_mix_single_column (
          .i_word(i_state[(i*32)-1-:32]),
          .o_word(o_state[(i*32)-1-:32])
      );
    end
  endgenerate
endmodule


module add_round_key (
    input  block i_state,
    input  block i_round_key,
    output block o_state
);
  assign o_state = i_state ^ i_round_key;
endmodule


module aes_round (
    input  block i_state,
    input  block i_round_key,
    input  logic i_final_round,
    output block o_state
);
  block s_sub, s_shift, s_mix, s_mix_sel;

  sub_bytes u_sub (
      .i_state(i_state),
      .o_state(s_sub)
  );
  shift_rows u_shift (
      .i_state(s_sub),
      .o_state(s_shift)
  );
  mix_columns u_mix (
      .i_state(s_shift),
      .o_state(s_mix)
  );

  assign s_mix_sel = i_final_round ? s_shift : s_mix;

  add_round_key u_addkey (
      .i_state(s_mix_sel),
      .i_round_key(i_round_key),
      .o_state(o_state)
  );
endmodule
