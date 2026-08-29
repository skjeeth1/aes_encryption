`timescale 1ns / 1ps
import def_pkg::*;

module key_expansion_tb ();

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

  block calc_key;
  int errors;

  initial begin
    errors = 0;

    for (int round = 1; round <= 10; round++) begin
      calc_key = key_expansion(expected_keys[round-1], round);

      if (calc_key !== expected_keys[round]) begin
        $display("FAIL: Round %0d. Expected: %h, Got: %h", round, expected_keys[round], calc_key);
        errors++;
      end else begin
        $display("SUCCESS: Round Key %0d verified.", round);
      end
    end

    if (errors == 0) $display("SUCCESS! All round keys match!");
    else $fatal(1, "FAIL! %0d round key(s) mismatched", errors);

    $finish;
  end

endmodule
