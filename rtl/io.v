
module io (
  input clk,
  input [5:0] addr,
  input [7:0] din,
  input we,
  output reg [7:0] dout,
  input cs
);

reg [7:0] memory[63:0];
initial begin
  memory[6'h38] = 8'h01;
  memory[6'h39] = 8'h0c;
  memory[6'h3e] = 8'ha0;
  memory[6'h3f] = 8'h27;
end

always @(posedge clk) begin
  if (~we && ~cs) memory[addr] <= din;
  dout <= memory[addr];
end

endmodule
