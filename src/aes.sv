import def_pkg::*;

module aes #(
    parameter int NUM_ROUNDS = 11
) (
    input logic clock,
    input logic reset,
    input logic i_en,
    input block in_val,
    input block key,

    output logic o_en,
    output block enc_val
);

  logic i_tx_en[NUM_ROUNDS];
  block i_state[NUM_ROUNDS];
  block i_round_key[NUM_ROUNDS];

  logic o_tx_en[NUM_ROUNDS];
  block o_state[NUM_ROUNDS];
  block o_round_key[NUM_ROUNDS];

  assign i_tx_en[0] = i_en;
  assign i_state[0] = in_val;
  assign i_round_key[0] = key;

  assign o_en = o_tx_en[NUM_ROUNDS-1];
  assign enc_val = o_state[NUM_ROUNDS-1];

  // For Round 0
  add_round_key u_add_round_key_top (
      .clock(clock),
      .reset(reset),

      .i_tx_en(i_tx_en[0]),
      .i_state(i_state[0]),
      .i_round_key(i_round_key[0]),

      .o_tx_en(o_tx_en[0]),
      .o_state(o_state[0]),
      .o_round_key(o_round_key[0])
  );

  genvar i;
  generate
    for (i = 1; i < NUM_ROUNDS; i = i + 1) begin : gen_pipeline
      cipher #(
          .ROUND(i)
      ) u_cipher (
          .clock(clock),
          .reset(reset),

          .i_tx_en(i_tx_en[i]),
          .i_state(i_state[i]),
          .i_round_key(i_round_key[i]),

          .o_tx_en(o_tx_en[i]),
          .o_state(o_state[i]),
          .o_round_key(o_round_key[i])
      );

      assign i_tx_en[i] = o_tx_en[i-1];
      assign i_state[i] = o_state[i-1];
      assign i_round_key[i] = o_round_key[i-1];
    end
  endgenerate

endmodule



