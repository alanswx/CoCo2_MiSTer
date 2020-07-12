
module keyboard(
  input clk,
  input [9:0] ps2_key,
  input [7:0] keyboard_data,
  input [7:0] kb_cols,
  output reg [7:0] kb_rows,
  input done //
);


reg [23:0] hold;
always @(posedge clk, posedge done)
	if (done)
		hold <= 24'hFFFFFF;
	else if (hold > 0)
		hold <= hold - 24'h1;


//    0   1   2   3   4   5   6   7
// 0  @   A   B   C   D   E   F   G
// 1  H   I   J   K   L   M   N   O
// 2  P   Q   R   S   T   U   V   W
// 3  X   Y   Z   up  dw  lt  rt  sp
// 4  0   1!  2"  3#  4$  5%  6&  7'
// 5  8(  9)  :*  ;+  ,<  _=  .>  /?
// 6  en  cl  bk                  ls
// 7                              rs

reg shift;

always @(posedge clk) begin

	kb_rows <= 8'hff;
	shift <= 1'b0;

	if (hold > 0 && hold < 24'hFFFF00) begin
	
   case (ps2_key[7:0])
     8'h0e: if (kb_cols[0] == 1'b0) kb_rows[0] <= 1'b0; // @
     8'h1c: if (kb_cols[1] == 1'b0) kb_rows[0] <= 1'b0; // A
     8'h32: if (kb_cols[2] == 1'b0) kb_rows[0] <= 1'b0; // B
     8'h21: if (kb_cols[3] == 1'b0) kb_rows[0] <= 1'b0; // C
     8'h23: if (kb_cols[4] == 1'b0) kb_rows[0] <= 1'b0; // D
     8'h24: if (kb_cols[5] == 1'b0) kb_rows[0] <= 1'b0; // E
     8'h2b: if (kb_cols[6] == 1'b0) kb_rows[0] <= 1'b0; // F
     8'h34: if (kb_cols[7] == 1'b0) kb_rows[0] <= 1'b0; // G
     8'h33: if (kb_cols[0] == 1'b0) kb_rows[1] <= 1'b0; // H
     8'h43: if (kb_cols[1] == 1'b0) kb_rows[1] <= 1'b0; // I
     8'h3b: if (kb_cols[2] == 1'b0) kb_rows[1] <= 1'b0; // J
     8'h42: if (kb_cols[3] == 1'b0) kb_rows[1] <= 1'b0; // K
     8'h4b: if (kb_cols[4] == 1'b0) kb_rows[1] <= 1'b0; // L
     8'h3a: if (kb_cols[5] == 1'b0) kb_rows[1] <= 1'b0; // M
     8'h31: if (kb_cols[6] == 1'b0) kb_rows[1] <= 1'b0; // N
     8'h44: if (kb_cols[7] == 1'b0) kb_rows[1] <= 1'b0; // O
     8'h4d: if (kb_cols[0] == 1'b0) kb_rows[2] <= 1'b0; // P
     8'h15: if (kb_cols[1] == 1'b0) kb_rows[2] <= 1'b0; // Q
     8'h2d: if (kb_cols[2] == 1'b0) kb_rows[2] <= 1'b0; // R
     8'h1b: if (kb_cols[3] == 1'b0) kb_rows[2] <= 1'b0; // S
     8'h2c: if (kb_cols[4] == 1'b0) kb_rows[2] <= 1'b0; // T
     8'h3c: if (kb_cols[5] == 1'b0) kb_rows[2] <= 1'b0; // U
     8'h2a: if (kb_cols[6] == 1'b0) kb_rows[2] <= 1 'b0; // V
     8'h1d: if (kb_cols[7] == 1'b0) kb_rows[2] <= 1'b0; // W
     8'h22: if (kb_cols[0] == 1'b0) kb_rows[3] <= 1'b0; // X
     8'h35: if (kb_cols[1] == 1'b0) kb_rows[3] <= 1'b0; // Y
     8'h1a: if (kb_cols[2] == 1'b0) kb_rows[3] <= 1'b0; // Z
     8'h75: if (kb_cols[3] == 1'b0) kb_rows[3] <= 1'b0; // up
     8'h72: if (kb_cols[4] == 1'b0) kb_rows[3] <= 1'b0; // down
     8'h6b: if (kb_cols[5] == 1'b0) kb_rows[3] <= 1'b0; // left
     8'h74: if (kb_cols[6] == 1'b0) kb_rows[3] <= 1'b0; // right
     8'h29: if (kb_cols[7] == 1'b0) kb_rows[3] <= 1'b0; // space
     8'h45: if (kb_cols[0] == 1'b0) kb_rows[4] <= 1'b0; // 0
     8'h16: if (kb_cols[1] == 1'b0) kb_rows[4] <= 1'b0; // 1
     8'h1e: if (kb_cols[2] == 1'b0) kb_rows[4] <= 1'b0; // 2
     8'h26: if (kb_cols[3] == 1'b0) kb_rows[4] <= 1'b0; // 3
     8'h25: if (kb_cols[4] == 1'b0) kb_rows[4] <= 1'b0; // 4
     8'h2e: if (kb_cols[5] == 1'b0) kb_rows[4] <= 1'b0; // 5
     8'h36: if (kb_cols[6] == 1'b0) kb_rows[4] <= 1'b0; // 6
     8'h3d: if (kb_cols[7] == 1'b0) kb_rows[4] <= 1'b0; // 7
     8'h3e: if (kb_cols[0] == 1'b0) kb_rows[5] <= 1'b0; // 8
     8'h46: if (kb_cols[1] == 1'b0) kb_rows[5] <= 1'b0; // 9
     8'h54: if (kb_cols[2] == 1'b0) kb_rows[5] <= 1'b0; // :
     8'h4c: if (kb_cols[3] == 1'b0) kb_rows[5] <= 1'b0; // ;
     8'h41: if (kb_cols[4] == 1'b0) kb_rows[5] <= 1'b0; // ,
     8'h4e: if (kb_cols[5] == 1'b0) kb_rows[5] <= 1'b0; // _
     8'h49: if (kb_cols[6] == 1'b0) kb_rows[5] <= 1'b0; // .
     8'h4a: if (kb_cols[7] == 1'b0) kb_rows[5] <= 1'b0; // /
     8'h5a: if (kb_cols[0] == 1'b0) kb_rows[6] <= 1'b0; // enter
     8'h71: if (kb_cols[1] == 1'b0) kb_rows[6] <= 1'b0; // clear
     8'h7e: if (kb_cols[2] == 1'b0) kb_rows[6] <= 1'b0; // break
     8'h12: if (kb_cols[7] == 1'b0) kb_rows[6] <= 1'b0; // shift left
     8'h59: if (kb_cols[7] == 1'b0) kb_rows[7] <= 1'b0; // shift right
     8'hf0: kb_rows <= 8'hff;
   endcase
	/*
		case (keyboard_data)
			8'h40: if (kb_cols[0] == 1'b0) kb_rows[0] <= 1'b0; // @
			8'h61: if (kb_cols[1] == 1'b0) kb_rows[0] <= 1'b0; // A
			8'h62: if (kb_cols[2] == 1'b0) kb_rows[0] <= 1'b0; // B
			8'h63: if (kb_cols[3] == 1'b0) kb_rows[0] <= 1'b0; // C
			8'h64: if (kb_cols[4] == 1'b0) kb_rows[0] <= 1'b0; // D
			8'h65: if (kb_cols[5] == 1'b0) kb_rows[0] <= 1'b0; // E
			8'h66: if (kb_cols[6] == 1'b0) kb_rows[0] <= 1'b0; // F
			8'h67: if (kb_cols[7] == 1'b0) kb_rows[0] <= 1'b0; // G
			8'h68: if (kb_cols[0] == 1'b0) kb_rows[1] <= 1'b0; // H
			8'h69: if (kb_cols[1] == 1'b0) kb_rows[1] <= 1'b0; // I
			8'h6a: if (kb_cols[2] == 1'b0) kb_rows[1] <= 1'b0; // J
			8'h6b: if (kb_cols[3] == 1'b0) kb_rows[1] <= 1'b0; // K
			8'h6c: if (kb_cols[4] == 1'b0) kb_rows[1] <= 1'b0; // L
			8'h6d: if (kb_cols[5] == 1'b0) kb_rows[1] <= 1'b0; // M
			8'h6e: if (kb_cols[6] == 1'b0) kb_rows[1] <= 1'b0; // N
			8'h6f: if (kb_cols[7] == 1'b0) kb_rows[1] <= 1'b0; // O
			8'h70: if (kb_cols[0] == 1'b0) kb_rows[2] <= 1'b0; // P
			8'h71: if (kb_cols[1] == 1'b0) kb_rows[2] <= 1'b0; // Q
			8'h72: if (kb_cols[2] == 1'b0) kb_rows[2] <= 1'b0; // R
			8'h73: if (kb_cols[3] == 1'b0) kb_rows[2] <= 1'b0; // S
			8'h74: if (kb_cols[4] == 1'b0) kb_rows[2] <= 1'b0; // T
			8'h75: if (kb_cols[5] == 1'b0) kb_rows[2] <= 1'b0; // U
			8'h76: if (kb_cols[6] == 1'b0) kb_rows[2] <= 1'b0; // V
			8'h77: if (kb_cols[7] == 1'b0) kb_rows[2] <= 1'b0; // W
			8'h78: if (kb_cols[0] == 1'b0) kb_rows[3] <= 1'b0; // X
			8'h79: if (kb_cols[1] == 1'b0) kb_rows[3] <= 1'b0; // Y
			8'h7a: if (kb_cols[2] == 1'b0) kb_rows[3] <= 1'b0; // Z
			8'h41: if (kb_cols[3] == 1'b0) kb_rows[3] <= 1'b0; // up
			8'h42: if (kb_cols[4] == 1'b0) kb_rows[3] <= 1'b0; // down
			8'h44: if (kb_cols[5] == 1'b0) kb_rows[3] <= 1'b0; // left
			8'h43: if (kb_cols[6] == 1'b0) kb_rows[3] <= 1'b0; // right
			8'h20: if (kb_cols[7] == 1'b0) kb_rows[3] <= 1'b0; // space
			8'h30: if (kb_cols[0] == 1'b0) kb_rows[4] <= 1'b0; // 0
			8'h31: if (kb_cols[1] == 1'b0) kb_rows[4] <= 1'b0; // 1
			8'h32: if (kb_cols[2] == 1'b0) kb_rows[4] <= 1'b0; // 2
			8'h33: if (kb_cols[3] == 1'b0) kb_rows[4] <= 1'b0; // 3
			8'h34: if (kb_cols[4] == 1'b0) kb_rows[4] <= 1'b0; // 4
			8'h35: if (kb_cols[5] == 1'b0) kb_rows[4] <= 1'b0; // 5
			8'h36: if (kb_cols[6] == 1'b0) kb_rows[4] <= 1'b0; // 6
			8'h37: if (kb_cols[7] == 1'b0) kb_rows[4] <= 1'b0; // 7
			8'h38: if (kb_cols[0] == 1'b0) kb_rows[5] <= 1'b0; // 8
			8'h39: if (kb_cols[1] == 1'b0) kb_rows[5] <= 1'b0; // 9
			8'h3a: if (kb_cols[2] == 1'b0) kb_rows[5] <= 1'b0; // :
			8'h3b: if (kb_cols[3] == 1'b0) kb_rows[5] <= 1'b0; // ;
			8'h2c: if (kb_cols[4] == 1'b0) kb_rows[5] <= 1'b0; // ,
			8'h5f: if (kb_cols[5] == 1'b0) kb_rows[5] <= 1'b0; // _
			8'h2e: if (kb_cols[6] == 1'b0) kb_rows[5] <= 1'b0; // .
			8'h2f: if (kb_cols[7] == 1'b0) kb_rows[5] <= 1'b0; // /
			8'h0d: if (kb_cols[0] == 1'b0) kb_rows[6] <= 1'b0; // enter
			8'h7f: if (kb_cols[1] == 1'b0) kb_rows[6] <= 1'b0; // clear
			8'h08: if (kb_cols[2] == 1'b0) kb_rows[6] <= 1'b0; // break

			8'h21: if (kb_cols[1] == 1'b0) begin kb_rows[4] <= 1'b0; shift <= 1'b1; end // !
			8'h22: if (kb_cols[2] == 1'b0) begin kb_rows[4] <= 1'b0; shift <= 1'b1; end // "
			8'h23: if (kb_cols[3] == 1'b0) begin kb_rows[4] <= 1'b0; shift <= 1'b1; end // #
			8'h24: if (kb_cols[4] == 1'b0) begin kb_rows[4] <= 1'b0; shift <= 1'b1; end // $
			8'h25: if (kb_cols[5] == 1'b0) begin kb_rows[4] <= 1'b0; shift <= 1'b1; end // %
			8'h26: if (kb_cols[6] == 1'b0) begin kb_rows[4] <= 1'b0; shift <= 1'b1; end // &
			8'h27: if (kb_cols[7] == 1'b0) begin kb_rows[4] <= 1'b0; shift <= 1'b1; end // '
			8'h28: if (kb_cols[0] == 1'b0) begin kb_rows[5] <= 1'b0; shift <= 1'b1; end // (
			8'h29: if (kb_cols[1] == 1'b0) begin kb_rows[5] <= 1'b0; shift <= 1'b1; end // )
			8'h2a: if (kb_cols[2] == 1'b0) begin kb_rows[5] <= 1'b0; shift <= 1'b1; end // *
			8'h2b: if (kb_cols[3] == 1'b0) begin kb_rows[5] <= 1'b0; shift <= 1'b1; end // +
			8'h3c: if (kb_cols[4] == 1'b0) begin kb_rows[5] <= 1'b0; shift <= 1'b1; end // <
			8'h3d: if (kb_cols[5] == 1'b0) begin kb_rows[5] <= 1'b0; shift <= 1'b1; end // =
			8'h3e: if (kb_cols[6] == 1'b0) begin kb_rows[5] <= 1'b0; shift <= 1'b1; end // >
			8'h3f: if (kb_cols[7] == 1'b0) begin kb_rows[5] <= 1'b0; shift <= 1'b1; end // ?


			8'h00: kb_rows <= 8'hff;
		endcase
*/
		// shift left
		if (shift && kb_cols[7] == 1'b0) begin
			kb_rows[6] <= 1'b0;
		end

	end
end


// PS/2:
/*
 always @*
   case (ps2_key[7:0])
     8'h0e: if (kb_cols[0] == 1'b0) kb_rows[0] = 1'b0; // @
     8'h1c: if (kb_cols[1] == 1'b0) kb_rows[0] = 1'b0; // A
     8'h32: if (kb_cols[2] == 1'b0) kb_rows[0] = 1'b0; // B
     8'h21: if (kb_cols[3] == 1'b0) kb_rows[0] = 1'b0; // C
     8'h23: if (kb_cols[4] == 1'b0) kb_rows[0] = 1'b0; // D
     8'h24: if (kb_cols[5] == 1'b0) kb_rows[0] = 1'b0; // E
     8'h2b: if (kb_cols[6] == 1'b0) kb_rows[0] = 1'b0; // F
     8'h34: if (kb_cols[7] == 1'b0) kb_rows[0] = 1'b0; // G
     8'h33: if (kb_cols[0] == 1'b0) kb_rows[1] = 1'b0; // H
     8'h43: if (kb_cols[1] == 1'b0) kb_rows[1] = 1'b0; // I
     8'h3b: if (kb_cols[2] == 1'b0) kb_rows[1] = 1'b0; // J
     8'h42: if (kb_cols[3] == 1'b0) kb_rows[1] = 1'b0; // K
     8'h4b: if (kb_cols[4] == 1'b0) kb_rows[1] = 1'b0; // L
     8'h3a: if (kb_cols[5] == 1'b0) kb_rows[1] = 1'b0; // M
     8'h31: if (kb_cols[6] == 1'b0) kb_rows[1] = 1'b0; // N
     8'h44: if (kb_cols[7] == 1'b0) kb_rows[1] = 1'b0; // O
     8'h4d: if (kb_cols[0] == 1'b0) kb_rows[2] = 1'b0; // P
     8'h15: if (kb_cols[1] == 1'b0) kb_rows[2] = 1'b0; // Q
     8'h2d: if (kb_cols[2] == 1'b0) kb_rows[2] = 1'b0; // R
     8'h1b: if (kb_cols[3] == 1'b0) kb_rows[2] = 1'b0; // S
     8'h2c: if (kb_cols[4] == 1'b0) kb_rows[2] = 1'b0; // T
     8'h3c: if (kb_cols[5] == 1'b0) kb_rows[2] = 1'b0; // U
     8'h2a: if (kb_cols[6] == 1'b0) kb_rows[2] = 1 'b0; // V
     8'h1d: if (kb_cols[7] == 1'b0) kb_rows[2] = 1'b0; // W
     8'h22: if (kb_cols[0] == 1'b0) kb_rows[3] = 1'b0; // X
     8'h35: if (kb_cols[1] == 1'b0) kb_rows[3] = 1'b0; // Y
     8'h1a: if (kb_cols[2] == 1'b0) kb_rows[3] = 1'b0; // Z
     8'h75: if (kb_cols[3] == 1'b0) kb_rows[3] = 1'b0; // up
     8'h72: if (kb_cols[4] == 1'b0) kb_rows[3] = 1'b0; // down
     8'h6b: if (kb_cols[5] == 1'b0) kb_rows[3] = 1'b0; // left
     8'h74: if (kb_cols[6] == 1'b0) kb_rows[3] = 1'b0; // right
     8'h29: if (kb_cols[7] == 1'b0) kb_rows[3] = 1'b0; // space
     8'h45: if (kb_cols[0] == 1'b0) kb_rows[4] = 1'b0; // 0
     8'h16: if (kb_cols[1] == 1'b0) kb_rows[4] = 1'b0; // 1
     8'h1e: if (kb_cols[2] == 1'b0) kb_rows[4] = 1'b0; // 2
     8'h26: if (kb_cols[3] == 1'b0) kb_rows[4] = 1'b0; // 3
     8'h25: if (kb_cols[4] == 1'b0) kb_rows[4] = 1'b0; // 4
     8'h2e: if (kb_cols[5] == 1'b0) kb_rows[4] = 1'b0; // 5
     8'h36: if (kb_cols[6] == 1'b0) kb_rows[4] = 1'b0; // 6
     8'h3d: if (kb_cols[7] == 1'b0) kb_rows[4] = 1'b0; // 7
     8'h3e: if (kb_cols[0] == 1'b0) kb_rows[5] = 1'b0; // 8
     8'h46: if (kb_cols[1] == 1'b0) kb_rows[5] = 1'b0; // 9
     8'h54: if (kb_cols[2] == 1'b0) kb_rows[5] = 1'b0; // :
     8'h4c: if (kb_cols[3] == 1'b0) kb_rows[5] = 1'b0; // ;
     8'h41: if (kb_cols[4] == 1'b0) kb_rows[5] = 1'b0; // ,
     8'h4e: if (kb_cols[5] == 1'b0) kb_rows[5] = 1'b0; // _
     8'h49: if (kb_cols[6] == 1'b0) kb_rows[5] = 1'b0; // .
     8'h4a: if (kb_cols[7] == 1'b0) kb_rows[5] = 1'b0; // /
     8'h5a: if (kb_cols[0] == 1'b0) kb_rows[6] = 1'b0; // enter
     8'h71: if (kb_cols[1] == 1'b0) kb_rows[6] = 1'b0; // clear
     8'h7e: if (kb_cols[2] == 1'b0) kb_rows[6] = 1'b0; // break
     8'h12: if (kb_cols[7] == 1'b0) kb_rows[6] = 1'b0; // shift left
     8'h59: if (kb_cols[7] == 1'b0) kb_rows[7] = 1'b0; // shift right
     8'hf0: kb_rows = 8'hff;
   endcase
*/
endmodule