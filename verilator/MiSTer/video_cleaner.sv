//
//
// Copyright (c) 2018 Sorgelig
//
// This program is GPL Licensed. See COPYING for the full license.
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////

//`timescale 1ns / 1ps

module video_cleaner
(
	input            clk_vid,
	input            ce_pix,

	input      [7:0] R,
	input      [7:0] G,
	input      [7:0] B,

	input            HSync,
	input            VSync,
	input            HBlank,
	input            VBlank,

	//optional de
	input            DE_in,

	// video output signals
	output     [7:0] VGA_R,
	output     [7:0] VGA_G,
	output     [7:0] VGA_B,
	output           VGA_VS,
	output           VGA_HS,
	output           VGA_DE,
	
	// optional aligned blank
	output reg       HBlank_out,
	output reg       VBlank_out,
	
	// optional aligned de
	output reg       DE_out
);

assign VGA_VS = ~VSync;
assign VGA_HS = ~HSync;
assign VGA_R = R;
assign VGA_G = G;
assign VGA_B = B;

endmodule
