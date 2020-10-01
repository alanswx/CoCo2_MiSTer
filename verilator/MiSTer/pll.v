
module pll(
    input refclk,
    input rst,

    output outclk_0,
    output reg outclk_1
);

assign outclk_0 = refclk; // 50

always @(posedge refclk)
  outclk_1 = ~outclk_1;

endmodule