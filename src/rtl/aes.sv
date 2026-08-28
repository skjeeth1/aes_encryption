import def_pkg::*;


module aes_128 #(
    parameter int NUM_ROUNDS = 10
) (
    input logic clock,
    input logic reset,
    input logic i_en,
    input block in_val,
    input block key,

    output logic o_en,
    output block enc_val
);

  logic busy;
  logic [3:0] round_cnt;
  block state_reg, round_key_reg;
  block next_state_comb, next_key_comb;
  logic final_round;

  assign final_round   = (round_cnt == NUM_ROUNDS);
  assign next_key_comb = key_expansion(round_key_reg, round_cnt + 1);

  aes_round u_round (
      .i_state(state_reg),
      .i_round_key(round_key_reg),
      .i_final_round(final_round),
      .o_state(next_state_comb)
  );

  always_ff @(posedge clock) begin
    if (reset) begin
      busy      <= 1'b0;
      round_cnt <= '0;
      o_en      <= 1'b0;
    end else begin
      o_en <= 1'b0;

      if (i_en && !busy) begin
        state_reg     <= in_val ^ key;
        round_key_reg <= key_expansion(key, 1);
        round_cnt     <= 4'd1;
        busy          <= 1'b1;
      end else if (busy) begin
        state_reg     <= next_state_comb;
        round_key_reg <= next_key_comb;
        if (final_round) begin
          busy    <= 1'b0;
          o_en    <= 1'b1;
          enc_val <= next_state_comb;
        end else begin
          round_cnt <= round_cnt + 1'b1;
        end
      end
    end
  end

endmodule
