import def_pkg::*;

function automatic block key_expansion_comb(input block i_round_key, input int round_num);
  word w0, w1, w2, w3;
  word g;
  begin
    g = g_func_comb(i_round_key[31:0], round_num);
    w0 = i_round_key[127:96] ^ g;
    w1 = i_round_key[95:64] ^ w0;
    w2 = i_round_key[63:32] ^ w1;
    w3 = i_round_key[31:0] ^ w2;
    key_expansion_comb = {w0, w1, w2, w3};
  end
endfunction


function automatic word g_func_comb(input word key_col, input int round_num);
  logic [7:0] b0, b1, b2, b3;
  begin
    b0 = key_col[31:24];
    b1 = key_col[23:16];
    b2 = key_col[15:8];
    b3 = key_col[7:0];

    g_func_comb = {aes_sbox(b1) ^ round_const(round_num), aes_sbox(b2), aes_sbox(b3), aes_sbox(b0)};
  end
endfunction


function automatic logic [7:0] round_const(input int round_num);
  case (round_num)
    1: round_const = 8'h01;
    2: round_const = 8'h02;
    3: round_const = 8'h04;
    4: round_const = 8'h08;
    5: round_const = 8'h10;
    6: round_const = 8'h20;
    7: round_const = 8'h40;
    8: round_const = 8'h80;
    9: round_const = 8'h1B;
    10: round_const = 8'h36;
    default: round_const = 8'h00;
  endcase
endfunction

