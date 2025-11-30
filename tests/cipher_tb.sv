`timescale 1ns / 1ps
import def_pkg::*;

module cipher_tb ();

  logic clock;
  logic reset;
  logic i_tx_en;
  block i_state;
  block i_round_key;

  logic o_tx_en;
  block o_state;
  block o_round_key;

  localparam int ROUND = 0;

  always #10 clock = ~clock;

  initial begin
    clock   = 1;
    reset   = 1;
    i_tx_en = 0;
    #10 reset = 0;
    #10 i_tx_en = 1;
    #10 i_tx_en = 0;
  end

  cipher #(
      .ROUND(ROUND)
  ) u_cipher (
      .clock(clock),
      .reset(reset),
      .i_tx_en(i_tx_en),
      .i_state(i_state),
      .i_round_key(i_round_key),
      .o_tx_en(o_tx_en),
      .o_state(o_state),
      .o_round_key(o_round_key)
  );

  // assign i_state     = 128'h193de3bea0f4e22b9ac68d2ae9f84808;
  // assign i_round_key = 128'h2b7e151628aed2a6abf7158809cf4f3c;

  assign i_state     = 128'h3243f6a8885a308d313198a2e0370734;
  assign i_round_key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
endmodule
