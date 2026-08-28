import def_pkg::*;

module sub_bytes #(
) (
    input logic clock,
    input logic reset,
    input logic i_tx_en,
    input block i_state,

    output logic o_tx_en,
    output block o_state
);

  block s_state;

  genvar i;
  generate
    for (i = 16; i > 0; i = i - 1) begin : gen_sub_block
      assign s_state[(i*8)-1-:8] = aes_sbox(i_state[(i*8)-1-:8]);
    end
  endgenerate

  always_ff @(posedge clock) begin
    if (reset) begin
      o_tx_en <= 0;
      o_state <= 0;
    end else begin
      o_state <= (i_tx_en) ? s_state : 0;
      o_tx_en <= i_tx_en;
    end
  end
endmodule


module shift_rows #(
) (
    input logic clock,
    input logic reset,
    input logic i_tx_en,
    input block i_state,

    output logic o_tx_en,
    output block o_state
);

  logic [7:0] s_state[16];
  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) assign s_state[i] = i_state[127-i*8-:8];
  endgenerate

  always_ff @(posedge clock) begin

    if (reset) begin
      o_tx_en <= 0;
      o_state <= 0;
    end else begin
      if (i_tx_en) begin
        o_state <= {
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
      end else begin
        o_state <= 0;
      end
      o_tx_en <= i_tx_en;
    end
  end
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

  assign o_word[(8*4)-1-:8] = mul_word[1][(8*4)-1-:8] ^
      mul_word[2][(8*3)-1-:8] ^
      mul_word[0][(8*2)-1-:8] ^
      mul_word[0][(8*1)-1-:8];

  assign o_word[(8*3)-1-:8] = mul_word[0][(8*4)-1-:8] ^
      mul_word[1][(8*3)-1-:8] ^
      mul_word[2][(8*2)-1-:8] ^
      mul_word[0][(8*1)-1-:8];

  assign o_word[(8*2)-1-:8] = mul_word[0][(8*4)-1-:8] ^
      mul_word[0][(8*3)-1-:8] ^
      mul_word[1][(8*2)-1-:8] ^
      mul_word[2][(8*1)-1-:8];

  assign o_word[(8*1)-1-:8] = mul_word[2][(8*4)-1-:8] ^
      mul_word[0][(8*3)-1-:8] ^
      mul_word[0][(8*2)-1-:8] ^
      mul_word[1][(8*1)-1-:8];
endmodule


module mix_columns #(
    parameter int ROUND
) (
    input logic clock,
    input logic reset,
    input logic i_tx_en,
    input block i_state,

    output logic o_tx_en,
    output block o_state
);

  block s_state;
  genvar i;
  generate
    for (i = 4; i > 0; i = i - 1) begin : gen_mix_columns
      mix_word u_mix_single_column (
          .i_word(i_state[(i*32)-1-:32]),
          .o_word(s_state[(i*32)-1-:32])
      );
    end
  endgenerate

  always_ff @(posedge clock) begin
    if (reset) begin
      o_tx_en <= 0;
      o_state <= 0;
    end else begin
      o_state <= (i_tx_en) ? ((ROUND == 10) ? i_state : s_state) : 0;
      o_tx_en <= i_tx_en;
    end
  end
endmodule


module add_round_key #(
) (
    input logic clock,
    input logic reset,
    input logic i_tx_en,
    input block i_state,
    input block i_round_key,

    output logic o_tx_en,
    output block o_round_key,
    output block o_state
);

  always_ff @(posedge clock) begin
    if (reset) begin
      o_tx_en <= 0;
      o_state <= 0;
      o_round_key <= 0;
    end else begin
      o_state <= (i_tx_en) ? i_state ^ i_round_key : 0;
      o_round_key <= (i_tx_en) ? i_round_key : 0;
      o_tx_en <= i_tx_en;
    end
  end
endmodule

module cipher #(
    parameter int ROUND
) (
    input logic clock,
    input logic reset,
    input logic i_tx_en,
    input block i_state,
    input block i_round_key,

    output logic o_tx_en,
    output block o_state,
    output block o_round_key
);

  logic i_tx_en_sub_bytes;
  logic i_tx_en_shift_rows;
  logic i_tx_en_mix_columns;
  logic i_tx_en_add_round_key;
  logic i_tx_en_key_expansion;

  logic o_tx_en_sub_bytes;
  logic o_tx_en_shift_rows;
  logic o_tx_en_mix_columns;
  logic o_tx_en_add_round_key;
  logic o_tx_en_key_expansion;

  block i_state_sub_bytes;
  block i_state_shift_rows;
  block i_state_mix_columns;
  block i_state_add_round_key;

  block o_state_sub_bytes;
  block o_state_shift_rows;
  block o_state_mix_columns;
  block o_state_add_round_key;

  block i_key_key_expansion;
  block o_key_key_expansion;
  block i_key_add_round_key;
  block o_key_add_round_key;

  assign i_tx_en_key_expansion = i_tx_en;
  assign i_tx_en_sub_bytes = i_tx_en;
  assign i_tx_en_shift_rows = o_tx_en_sub_bytes;
  assign i_tx_en_mix_columns = o_tx_en_shift_rows;
  assign i_tx_en_add_round_key = o_tx_en_mix_columns;

  assign i_state_sub_bytes = i_state;
  assign i_state_shift_rows = o_state_sub_bytes;
  assign i_state_mix_columns = o_state_shift_rows;
  assign i_state_add_round_key = o_state_mix_columns;

  logic i_delay_tx_en;
  logic o_delay_tx_en;
  block i_delay_key;
  block o_delay_key;

  assign i_key_key_expansion = i_round_key;
  assign i_delay_key = o_key_key_expansion;
  assign i_delay_tx_en = o_tx_en_key_expansion;
  assign i_key_add_round_key = o_delay_key;

  assign o_tx_en = o_tx_en_add_round_key;
  assign o_state = o_state_add_round_key;
  assign o_round_key = o_key_add_round_key;

  key_expansion #(
      .ROUND(ROUND)
  ) u_key_expansion (
      .clock(clock),
      .reset(reset),

      .i_tx_en    (i_tx_en_key_expansion),
      .i_round_key(i_key_key_expansion),

      .o_tx_en    (o_tx_en_key_expansion),
      .o_round_key(o_key_key_expansion)
  );

  sub_bytes u_sub_bytes (
      .clock(clock),
      .reset(reset),

      .i_tx_en(i_tx_en_sub_bytes),
      .i_state(i_state_sub_bytes),

      .o_tx_en(o_tx_en_sub_bytes),
      .o_state(o_state_sub_bytes)
  );

  shift_rows u_shift_rows (
      .clock(clock),
      .reset(reset),

      .i_tx_en(i_tx_en_shift_rows),
      .i_state(i_state_shift_rows),

      .o_tx_en(o_tx_en_shift_rows),
      .o_state(o_state_shift_rows)
  );

  mix_columns #(
      .ROUND(ROUND)
  ) u_mix_columns (
      .clock(clock),
      .reset(reset),

      .i_tx_en(i_tx_en_mix_columns),
      .i_state(i_state_mix_columns),

      .o_tx_en(o_tx_en_mix_columns),
      .o_state(o_state_mix_columns)
  );

  add_round_key u_add_round_key (
      .clock(clock),
      .reset(reset),

      .i_tx_en(i_tx_en_add_round_key),
      .i_state(i_state_add_round_key),
      .i_round_key(i_key_add_round_key),

      .o_tx_en(o_tx_en_add_round_key),
      .o_state(o_state_add_round_key),
      .o_round_key(o_key_add_round_key)
  );

  // Add one delay to key expansion output
  always_ff @(posedge clock) begin
    if (reset) begin
      o_delay_tx_en <= 0;
      o_delay_key   <= 0;
    end else begin
      o_delay_key   <= i_delay_key;
      o_delay_tx_en <= i_delay_tx_en;
    end
  end

endmodule
