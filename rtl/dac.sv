/*
dac.sv

Copyright 2020
Alan Steremberg - alanswx

digital emualtion of the trs-80 DAC

no analogue is created or destroyed here

*/


module dac (
input clk,
  input [15:0] joya1,
  input [15:0] joya2,
  input [5:0] dac,
  input snden,
  input snd,
  output reg hilo,
  output reg [5:0] sound,
  input selb,
  input sela
  );
  
/*

Sel B Sel A  joystick input sound Input
  0    0       Joy 0           DAC
  0    1       Joy 1        Cassette
  1    0       Joy 2        Cartridge
  1    1       Joy 3        No Sound

  
*/

always @(posedge clk) begin
  if (snden && !selb && !sela) begin
    sound<=dac;
	 end
  else begin
    sound<=6'b0;
  end
  
end
always @(posedge clk) begin
  case ({selb,sela})
  2'b00:
		if (joya2[15:10] > dac)
			hilo<=1;
		else
			hilo<=0;
  2'b01:
  		if (joya2[7:2] > dac)
			hilo<=1;
		else
			hilo<=0;
2'b10:
		if (joya1[15:10] > dac)
			hilo<=1;
		else
			hilo<=0;
  2'b11:
  		if (joya1[7:2] > dac)
			hilo<=1;
		else
			hilo<=0;
	endcase
end
endmodule