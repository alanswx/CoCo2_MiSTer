
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
  // interrupt vectors
  memory[6'h30] = 8'ha6; // fff0 - RSV
  memory[6'h31] = 8'h81; // fff1
  memory[6'h32] = 8'h01; // fff2 - SW3
  memory[6'h33] = 8'h00; // fff3
  memory[6'h34] = 8'h01; // fff4 - SW2
  memory[6'h35] = 8'h03; // fff5
  memory[6'h36] = 8'h01; // fff6 - FRQ
  memory[6'h37] = 8'h0f; // fff7
  memory[6'h38] = 8'h01; // fff8 - IRQ
  memory[6'h39] = 8'h0c; // fff9
  memory[6'h3a] = 8'h01; // fffa - SWI
  memory[6'h3b] = 8'h06; // fffb
  memory[6'h3c] = 8'h01; // fffc - NMI
  memory[6'h3d] = 8'h09; // fffd
  memory[6'h3e] = 8'ha0; // fffe - RES
  memory[6'h3f] = 8'h27; // ffff
end

always @(posedge clk) begin
  if (~we && ~cs) memory[addr] <= din;
  dout <= memory[addr];
end

endmodule
