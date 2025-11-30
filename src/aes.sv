import def_pkg::*;

module aes #(
) (
    input logic clock,
    input logic reset,
    input logic i_en,
    input block in_val,
    input block key,

    output logic o_en,
    output block enc_val
);

  genvar i;
  generate
    for (i = 0; i <= 10; i = i + 1) begin : gen_pipeline
    end
  endgenerate

endmodule



