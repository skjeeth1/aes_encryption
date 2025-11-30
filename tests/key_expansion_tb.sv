`timescale 1ns / 1ps
import def_pkg::*;

module key_expansion_tb ();

  logic clock;
  logic reset;
  logic i_tx_en;
  block i_key;

  logic o_tx_en;
  block o_round_key;

  initial begin
    clock   = 0;
    reset   = 1;
    i_tx_en = 1;

    #10 reset = 0;
  end

  always #10 clock = ~clock;

  block expected_keys[11] = {
    128'h5468617473206D79204B756E67204675,
    128'hE232FCF191129188B159E4E6D679A293,
    128'h56082007C71AB18F76435569A03AF7FA,
    128'hD2600DE7157ABC686339E901C3031EFB,
    128'hA11202C9B468BEA1D75157A01452495B,
    128'hB1293B3305418592D210D232C6429B69,
    128'hBD3DC2B7B87C47156A6C9527AC2E0E4E,
    128'hCC96ED1674EAAA031E863F24B2A8316A,
    128'h8E51EF21FABB4522E43D7A0656954B6C,
    128'hBFE2BF904559FAB2A16480B4F7F1CBD8,
    128'h28FDDEF86DA4244ACCC0A4FE3B316F26
  };

  localparam int ROUND = 6;

  assign i_key = expected_keys[ROUND-1];

  key_expansion #(
      .ROUND(ROUND)
  ) u_key_expansion (
      .clock      (clock),
      .reset      (reset),
      .i_tx_en    (i_tx_en),
      .i_round_key(i_key),
      .o_tx_en    (o_tx_en),
      .o_round_key(o_round_key)
  );

  always_ff @(posedge clock) begin
    if (o_tx_en) begin
      if (o_round_key != expected_keys[ROUND]) begin
        $fatal(1, "Key Mismatch! Calculated round:%0d. Expected: %h, Got: %h", ROUND,
               expected_keys[ROUND], o_round_key);
      end else begin
        $display("SUCCESS: Round Key %0d verified.", ROUND);
      end
      i_tx_en <= 0;
    end
  end

  // Failed rounds: 6,7,
endmodule
