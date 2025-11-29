`timescale 1ns / 1ps
import def_pkg::*;

module key_expansion_tb ();

  logic clock;
  logic reset;
  logic i_tx_en;
  block i_key;

  logic o_tx_en;
  block o_round_key;

  localparam int ROUND = 1;

  key_expansion #(
      .ROUND(ROUND)
  ) u_key_expansion (
      .clock      (clock),
      .reset      (reset),
      .i_tx_en    (i_tx_en),
      .i_key      (i_key),
      .o_tx_en    (o_tx_en),
      .o_round_key(o_round_key)
  );

  initial clock = 0;
  always #5 clock = ~clock;

  initial begin
    reset   = 1;
    // i_key   = 128'h2b7e151628aed2a6abf7158809cf4f3c;
    i_key   = 128'h5468617473206D79204B756E67204675;
    i_tx_en = 1;

    #10 reset = 0;
    #50 i_tx_en = 0;
  end

endmodule
