

// 2 x 7-segment LED driver (hex word)
// It was used to debug the receipter on FPGA

module seg7(
  input [7:0] din,
  output reg [6:0] d1, // [6:0] = abcdefg
  output reg [6:0] d2  // [6:0] = abcdefg
);

always @*
  case (din[3:0])
    4'h0: d1 = 7'b0000001;
    4'h1: d1 = 7'b1001111;
    4'h2: d1 = 7'b0010010;
    4'h3: d1 = 7'b0000110;
    4'h4: d1 = 7'b1001100;
    4'h5: d1 = 7'b0100100;
    4'h6: d1 = 7'b0100000;
    4'h7: d1 = 7'b0001111;
    4'h8: d1 = 7'b0000000;
    4'h9: d1 = 7'b0000100;
    4'ha: d1 = 7'b0001000;
    4'hb: d1 = 7'b1100000;
    4'hc: d1 = 7'b0110001;
    4'hd: d1 = 7'b1000010;
    4'he: d1 = 7'b0110000;
    4'hf: d1 = 7'b0111000;
  endcase

always @*
  case (din[7:4])
    4'h0: d2 = 7'b0000001;
    4'h1: d2 = 7'b1001111;
    4'h2: d2 = 7'b0010010;
    4'h3: d2 = 7'b0000110;
    4'h4: d2 = 7'b1001100;
    4'h5: d2 = 7'b0100100;
    4'h6: d2 = 7'b0100000;
    4'h7: d2 = 7'b0001111;
    4'h8: d2 = 7'b0000000;
    4'h9: d2 = 7'b0000100;
    4'ha: d2 = 7'b0001000;
    4'hb: d2 = 7'b1100000;
    4'hc: d2 = 7'b0110001;
    4'hd: d2 = 7'b1000010;
    4'he: d2 = 7'b0110000;
    4'hf: d2 = 7'b0111000;
  endcase

endmodule