`timescale 1ns / 1ps
import def_pkg::*;

module aes_tb ();

  logic clock;
  logic reset;
  logic i_en;
  block in_val;
  block key;

  logic o_en;
  block enc_val;

  aes_128 u_aes (
      .clock  (clock),
      .reset  (reset),
      .i_en   (i_en),
      .in_val (in_val),
      .key    (key),
      .o_en   (o_en),
      .enc_val(enc_val)
  );

  always #10 clock = ~clock;

  initial begin
    clock = 1;
    reset = 1;
    i_en  = 0;
    #10 reset = 0;
    #10 i_en = 1;
    #10 i_en = 0;
  end

  assign key    = 128'h2B7E151628AED2A6ABF7158809CF4F3C;
  assign in_val = 128'hAE2D8A571E03AC9C9EB76FAC45AF8E51;
  block expct_val = 128'hF5D3D58503B9699DE785895A96FDBAAF;

  int   COUNTER;
  int   LATENCY_START;

  always_ff @(posedge clock) begin
    if (reset) begin
      COUNTER <= 0;
    end else begin
      COUNTER <= COUNTER + 1;

      if (i_en) LATENCY_START <= COUNTER;

      if (o_en) begin
        $display("Output value    = %h", enc_val);
        $display("Expected value  = %h", expct_val);
        $display("Clock pulses    = %0d", COUNTER);
        $display("Round latency   = %0d cycles", COUNTER - LATENCY_START);

        if (enc_val !== expct_val) $fatal(1, "FAIL! Encrypted output doesn't match expected value");
        else if ((COUNTER - LATENCY_START) != 11)
          $display(
              "WARNING: Expected 11-cycle latency (1 load + 10 rounds), got %0d",
              COUNTER - LATENCY_START
          );
        else $display("SUCCESS! Value and latency match!");

        $finish;
      end
    end
  end

  initial begin
    #1000;
    $fatal(1, "TIMEOUT: o_en never asserted");
  end

endmodule
