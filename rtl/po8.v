


module po8(
  input clk, // 50 mhz
  input reset,
  output [4:0] red,
  output [5:0] green,
  output [4:0] blue,
  output hblank,
  output vblank,
  output hsync,
  output vsync,
  // input ps2_clk,
  // input ps2_dat,
  input uart_din,
  output debug_led,
  output reg [6:0] segments,
  output reg [5:0] digits,
  input [10:0] ps2_key
);

wire nmi = 1'b1;
wire halt = 1'b1;

reg E = 0;
reg Q = 0;

reg [4:0] clk_div = 0;
always @(posedge clk) begin
  //clk_div <= clk_div + 6'd1;
  clk_div <= clk_div + 5'd1;
  if (clk_div == 5'b10000) E <= ~E;
  if (clk_div == 5'b00000) Q <= ~Q;
end

reg clk25;
always @(posedge clk)
  clk25 <= ~clk25;

reg clk12;
always @(posedge clk25)
  clk12 <= ~clk12;

reg [9:0] clk_div2 = 0;
reg slow_clk;
always @(posedge clk) begin
  clk_div2 <= clk_div2 + 10'b1;
  if (clk_div2 == 0) slow_clk <= ~slow_clk;
end

wire [7:0] cpu_dout;
wire [15:0] cpu_addr;
wire cpu_rw;
wire cpu_bs;
wire cpu_ba;
wire cpu_adv_valid_addr;
wire cpu_busy;
wire cpu_last_inst_cycle;
wire irq;
wire firq;

wire [12:0] vdg_addr;
wire [10:0] vdg_char_addr;
wire [7:0] chr_dout;

wire [10:0] vmem = { 2'b10, vdg_addr[8:0] };

wire [7:0] ram_dout;
wire [7:0] ram_dout_b;
wire [7:0] rom8_dout;
wire [7:0] romA_dout;
wire [7:0] romC_dout;
wire [7:0] pia_dout;
wire [7:0] pia1_dout;
wire [7:0] io_out;

wire ram_cs  = cpu_addr[15] == 0;
wire rom8_cs = cpu_addr[15:13] == 3'b100;
wire romA_cs = cpu_addr[15:13] == 3'b101;
wire romC_cs = cpu_addr[15:13] == 3'b110;
wire pia_cs  = cpu_addr[15:5]  == 11'b1111_1111_000;
wire pia1_cs = cpu_addr[15:5]  == 11'b1111_1111_001;
wire io_cs   = cpu_addr[15:6]  == 10'b1111_1111_11;

wire we = ~cpu_rw & E;

wire [8:0] char_rom_addr;
assign char_rom_addr[8:3] = vdg_char_addr[9:4];
assign char_rom_addr[2:0] = temp_vdg_char_addr[2:0];
wire [3:0] temp_vdg_char_addr = vdg_char_addr[3:0] - 2'b11;
wire [7:0] char_data = (vdg_char_addr[3:0] < 3 || vdg_char_addr[3:0] > 10) ? 8'h00 : chr_dout;

wire [7:0] keyboard_data;
wire [7:0] kb_cols, kb_rows;

wire [7:0] pia1_portb_out;

// data mux
wire [7:0] cpu_din =
  ram_cs  ? ram_dout  :
  rom8_cs ? rom8_dout :
  romA_cs ? romA_dout :
  romC_cs ? romC_dout :
  pia_cs  ? pia_dout  :
  pia1_cs ? pia1_dout :
  io_cs   ? io_out : 8'hff;

mc6809e cpu(
  .D(cpu_din),
  .DOut(cpu_dout),
  .ADDR(cpu_addr),
  .RnW(cpu_rw),
  .E(E),
  .Q(Q),
  .BS(cpu_bs),
  .BA(cpu_ba),
  .nIRQ(~irq),
  .nFIRQ(~firq),
  .nNMI(nmi),
  .AVMA(cpu_adv_valid_addr),
  .BUSY(cpu_busy),
  .LIC(cpu_last_inst_cycle),
  .nHALT(halt),
  .nRESET(reset)
);

dpram #(.addr_width_g(15), .data_width_g(8)) ram1(
	.clock_a(clk),
	.address_a(cpu_addr[14:0]),
	.data_a(cpu_dout),
	.q_a(ram_dout),
	.wren_a(we),
	.enable_a(ram_cs),

	.clock_b(clk),
	.address_b(vmem),
	.q_b(ram_dout_b)
        );
// 32k dual port ram
 /*
ram ram1(
  .clk(clk),
  .addr(cpu_addr[14:0]),
  .din(cpu_dout),
  .dout(ram_dout),
  .addr_b(vmem),
  .dout_b(ram_dout_b),
  .we(~we),
  .cs(~ram_cs)
);
*/

// 8k extended basic rom
rom_ext rom8(
  .clk(clk),
  .addr(cpu_addr[12:0]),
  .dout(rom8_dout),
  .cs(~rom8_cs)
);

// 8k color basic rom
rom_bas romA(
  .clk(clk),
  .addr(cpu_addr[12:0]),
  .dout(romA_dout),
  .cs(~romA_cs)
);

// 8k disk basic rom
rom_dsk romC(
  .clk(clk),
  .addr(cpu_addr[12:0]),
  .dout(romC_dout),
  .cs(~romC_cs)
);
/*
// 8k extended basic rom
rom #(
  .ROMFILE ("ext"),
  .SIZE(8191)
) rom8(
  .clk(clk),
  .addr(cpu_addr[12:0]),
  .dout(rom8_dout),
  .cs(~rom8_cs)
);

// 8k color basic rom
rom #(
  .ROMFILE ("bas"),
  .SIZE(8191)
) romA(
  .clk(clk),
  .addr(cpu_addr[12:0]),
  .dout(romA_dout),
  .cs(~romA_cs)
);

// 8k disk basic rom
rom #(
  .ROMFILE ("dsk"),
  .SIZE(8191)
) romC(
  .clk(clk),
  .addr(cpu_addr[12:0]),
  .dout(romC_dout),
  .cs(~romC_cs)
);
*/
pia6520 pia(
  .data_out(pia_dout),
  .data_in(cpu_dout),
  .addr(cpu_addr[1:0]),
  .strobe(pia_cs),
  .we(we),
  .irq(irq),
  .porta_in(kb_rows),
  .porta_out(),
  .portb_in(),
  .portb_out(kb_cols),
  .ca1_in(hsync),
  .ca2_in(vsync),
  .cb1_in(),
  .cb2_in(),
  .ca2_out(), // used for joy & snd
  .cb2_out(), // used for joy & snd
  .clk(clk),
  .reset(~reset)
);

pia6520 pia1(
  .data_out(pia1_dout),
  .data_in(cpu_dout),
  .addr(cpu_addr[1:0]),
  .strobe(pia1_cs),
  .we(we),
  .irq(firq),
  .porta_in(),
  .porta_out(),
  .portb_in(),
  .portb_out(pia1_portb_out),
  .ca1_in(),
  .ca2_in(),
  .cb1_in(),
  .cb2_in(),
  .ca2_out(),
  .cb2_out(),
  .clk(clk),
  .reset(~reset)
);

wire [3:0] r4, g4, b4;
assign red = { r4, 1'b0 };
assign green = { g4, 2'b0 };
assign blue = { b4, 1'b0 };

mc6847 vdg(
  .clk(clk25),
  .clk_ena(clk12),
  .reset(~reset),
  .da0(),
  .videoaddr(vdg_addr),
  .dd(ram_dout_b),
  .hs_n(),
  .fs_n(),
  .an_g(pia1_portb_out[7]), // PIA1 port B
  .an_s(ram_dout_b[7]),
  .intn_ext(pia1_portb_out[4]),
  .gm(pia1_portb_out[6:4]), // [2:0] pin 6 (gm2),5 (gm1) & 4 (gm0) PIA1 port B
  .css(pia1_portb_out[3]),
  .inv(ram_dout_b[6]),
  .red(r4),
  .green(g4),
  .blue(b4),
  .hsync(hsync),
  .vsync(vsync),
  .hblank(hblank),
  .vblank(vblank),
  .artifact_en(1'b0),
  .artifact_set(1'b0),
  .artifact_phase(1'b1),
  .cvbs(),
  .black_backgnd(1'b1),
  .char_a(vdg_char_addr), // => char rom address
  .char_d_o(char_data) // <= char rom data
);

/*
chrrom #(
  .ROMFILE ("chrrom")
) chr(
  .clk(clk),
  .addr(char_rom_addr),
  .dout(chr_dout)
);
*/
rom_chrrom chrrom(
  .clk(clk),
  .addr(char_rom_addr),
  .dout(chr_dout)
);

io io1(
  .clk(clk),
  .addr(cpu_addr[5:0]),
  .din(cpu_dout),
  .dout(io_out),
  .we(~we),
  .cs(~io_cs)
);

// I haven't reveived my PS/2 keyboard so I can't test
// ps2 ps2_keyboard(
//   .ps2_clk(ps2_clk),
//   .ps2_dat(ps2_dat),
//   .data(keyboard_data)
// );

// meanwhile, use UART to send keyboard codes

wire uart_done;

uart_rx uart_kb (
  .clk(clk),
  .rx(uart_din),
  .dout(keyboard_data),
  .done(uart_done)
);

keyboard kb(
  .clk(clk),
  .ps2_key(ps2_key),
  .keyboard_data(keyboard_data),
  .kb_rows(kb_rows),
  .kb_cols(kb_cols),
  .done(uart_done)
);

// the following is for debugging **
// use 7 segs to display char codes

wire [6:0] seg_d1, seg_d2, seg_d3, seg_d4;

always @(posedge slow_clk)
  if (digits == 6'd0 || digits == 6'b011111)
    digits <= 6'b111110;
  else
    digits <= { digits[4:0], 1'b1 };

always @*
	case (digits)
		6'b111110: segments = seg_d1;
		6'b111101: segments = seg_d2;
		6'b111011: segments = seg_d3;
		6'b110111: segments = seg_d4;
		default: segments = 7'b1111110;
	endcase

seg7 dbg_rows(
  .din(kb_rows),
  .d1(seg_d1),
  .d2(seg_d2)
);

seg7 dbg_kbdat(
  .din(keyboard_data),
  .d1(seg_d3),
  .d2(seg_d4)
);

assign debug_led = kb_rows != 8'hff;

endmodule
