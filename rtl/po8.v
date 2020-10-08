

// todo: find a better name
module po8(
  input clk, // 50 mhz
  input reset, // todo: reset doesn't work!
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
  input [10:0] ps2_key,
  input [7:0] ioctl_data,
  input [15:0] ioctl_addr,
  input ioctl_download,
  input ioctl_wr
);

wire nmi = 1'b1;
wire halt = 1'b1;

wire E, Q;
wire VClk;

reg clk25;
always @(posedge clk)
  clk25 <= ~clk25;

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

// this should be managed by SAM
wire [14:0] vmem = { disp_offset, 9'd0 } + vdg_addr;

wire [7:0] ram_dout;
wire [7:0] ram_dout_b;
wire [7:0] rom8_dout;
wire [7:0] romA_dout;
wire [7:0] romC_dout;
wire [7:0] pia_dout;
wire [7:0] pia1_dout;
wire [7:0] io_out;

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
  .address_a(mem_addr[14:0]),
  .data_a(cpu_dout),
  .q_a(ram_dout),
  .wren_a(we),
  .enable_a(ram_cs),
  .enable_b(1'b1),

  .clock_b(clk),
  .address_b(vmem),
  .q_b(ram_dout_b)
);

// 8k extended basic rom
// Do we need an option to enable/disable extended basic rom?
rom_ext rom8(
  .clk(clk),
  .addr(mem_addr[12:0]),
  .dout(rom8_dout),
  .cs(~rom8_cs)
);

// 8k color basic rom
rom_bas romA(
  .clk(clk),
  .addr(mem_addr[12:0]),
  .dout(romA_dout),
  .cs(~romA_cs)
);

// there must be another solution
reg cart_loaded;
always @(posedge clk)
  if (ioctl_download & ioctl_wr)
    cart_loaded <= ioctl_addr > 15'h100;

dpram #(.addr_width_g(13), .data_width_g(8)) romC(
  .clock_a(clk),
  .address_a(mem_addr[12:0]),
  .q_a(romC_dout),
  .enable_a(romC_cs),

  .clock_b(clk),
  .address_b(ioctl_addr[12:0]),
  .data_b(ioctl_data),
  .wren_b(ioctl_wr)
);

wire [2:0] S;
wire [15:0] sam_addr;
reg [15:0] mem_addr;
wire [6:0] disp_offset;

// to keep it stable for CPU
always @(posedge Q)
  mem_addr <= sam_addr;

// Simplified version of SAM:
// - Z is 16bit
// - no VDG address generation
// - and a lot of missing signals
sam sam(
  .clk(clk),
  .Ai(cpu_addr),
  .Zo(sam_addr),
  .Q(Q),
  .E(E),
  .VClk(VClk),
  .S(S),
  .iRW(~we),
  .disp_offset(disp_offset)
);

io io1(
  .clk(clk),
  .addr(cpu_addr[5:0]),
  .din(cpu_dout),
  .dout(io_out),
  .we(~we),
  .cs(~io_cs)
);

wire [7:0] cs74138;
assign {
  io_cs, pia1_cs, pia_cs,
  romC_cs, romA_cs, rom8_cs,
  ram_cs
} = ~cs74138;

x74138 x74138(
  .En(3'b100),
  .I(S),
  .O(cs74138)
);

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
  .cb1_in(cart_loaded & reset & Q), // cartridge inserted
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
  .clk_ena(VClk),
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
  .artifact_en(1'b1),
  .artifact_set(1'b0),
  .artifact_phase(1'b1),
  .cvbs(),
  .black_backgnd(1'b1),
  .char_a(vdg_char_addr), // => char rom address
  .char_d_o(char_data) // <= char rom data
);

rom_chrrom chrrom(
  .clk(clk),
  .addr(char_rom_addr),
  .dout(chr_dout)
);

keyboard kb(
.clk_sys(clk),
.reset(~reset),
.ps2_key(ps2_key),
.addr(kb_cols),
.kb_rows(kb_rows),
.kblayout(1'b1),
.Fn(),
.modif()
);



assign debug_led = kb_rows != 8'hff;

endmodule
