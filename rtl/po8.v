

// todo: find a better name
module po8(
  input clk, // 57.272 mhz
  input reset, // todo: reset doesn't work!
/*  output [4:0] red,
  output [5:0] green,
  output [4:0] blue,
  */
  output [7:0] red,
  output [7:0] green,
  output [7:0] blue,
  output hblank,
  output vblank,
  output hsync,
  output vsync,
  output vclk,
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
  input ioctl_wr,
  input artifact_phase,
  input [15:0] joy1,
  input [15:0] joy2,
  input [15:0] joya1,
  input [15:0] joya2,
  output [5:0] sound,
  output sndout,
  output [8:0] v_count,
  output [8:0] vga_h_count,
output [159:0] DLine1,
output [159:0] DLine2

  //reg [159:0] DLine1,DLine2;



);

wire nmi = 1'b1;
wire halt = 1'b1;

wire E, Q;
wire VClk;
  
reg clk_14M318_ena ;
reg [1:0] count;
always @(posedge clk)
begin
	if (~reset)
		count<=0;
	else
	begin
		clk_14M318_ena <= 0;
		if (count == 'd3) 
		begin
		  clk_14M318_ena <= 1;
        count <= 0;
		end
		else
		begin
			count<=count+1;
		end
	end
end
/*
reg clk_14M318_ena;
always @(posedge clk) begin
        reg [1:0] div;

        div <= div + 1'd1;
	clk_14M318_ena <= div == 0;
end
*/
  
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
wire [7:0]vdg_data;
wire [7:0] ram_dout;
reg [7:0] ram_dout_b;
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

dpram #(.addr_width_g(16), .data_width_g(8)) ram1(
  .clock_a(clk),
  .address_a(cpu_addr),
  .data_a(cpu_dout),
  .q_a(/*ram_dout*/),
  .wren_a(we),
  .enable_a(ram_cs),
  .enable_b(1'b1),  
/*  .wren_a(~sam_we_n),
  .enable_a(sam_we_n),
  .enable_b(sam_we_n),
*/
  //.clock_b(clk),
  //.address_b(vmem),
  //.q_b(ram_dout_b)
  .clock_b(clk),
  .address_b(sam_a),
  .q_b(vdg_data)
);

// 8k extended basic rom
// Do we need an option to enable/disable extended basic rom?
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

// there must be another solution
reg cart_loaded;
always @(posedge clk)
  if (ioctl_download & ~ioctl_wr)
    cart_loaded <= ioctl_addr > 15'h100;

dpram #(.addr_width_g(14), .data_width_g(8)) romC(
  .clock_a(clk),
  .address_a(cpu_addr[13:0]),
  .q_a(romC_dout),
  .enable_a(romC_cs),

  .clock_b(clk),
  .address_b(ioctl_addr[13:0]),
  .data_b(ioctl_data),
  .wren_b(ioctl_wr)
);

wire [2:0] S;
wire [2:0] SS;
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

/*
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
*/

sam sam(
  .clk(clk),
  .Ai(cpu_addr),
  .Zo(sam_addr),
  .Q(),
  .E(),
  .VClk(),
  .S(S),
  .iRW(~we),
  .disp_offset(disp_offset)
);


wire da0;
wire [7:0] ma;
wire ras_n, cas_n,sam_we_n;
reg [15:0] sam_a;
reg ras_n_r;
reg cas_n_r;
reg q_r,e_r;
always @(posedge clk)
begin
	if (~reset) 
	begin
		ras_n_r<=0;
		cas_n_r<=0;
		q_r<=0;
		e_r<=0;
	end
	else if  (clk_14M318_ena == 1) 
	begin
	     if (ras_n == 1 && ras_n_r == 0 &&  E ==1)
		  begin
		    //  ram_datao <= sram_i.d(ram_datao'range);
			// ram_dout<=vdg_data;
        end
        if (ras_n == 0 && ras_n_r == 1)
          sam_a[7:0]<= ma;
        else if (cas_n == 0 && cas_n_r == 1)
          sam_a[15:8] <= ma;
			 
		  if (Q == 1 && q_r == 0)
		  begin
		   ram_dout_b<=vdg_data;// <= sram_i.d(ram_datao'range);
        end
        e_r <= E;
        q_r <= Q;

			 
        ras_n_r <= ras_n;
        cas_n_r <= cas_n;		
	end
end
			assign ram_dout=vdg_data;


mc6883 sam2(
			.clk(clk),//				=> clk_57M272,
			.clk_ena(clk_14M318_ena),
			.reset(~reset),//			=> platform_rst,

			//-- input
			.a(cpu_addr),//					=> cpu_a,
			.rw_n(cpu_rw),//		=> cpu_r_wn,

			//-- vdg signals
			.da0(da0),
			.hs_n(hs_n),
			.vclk(),
			
			//-- peripheral address selects		
			.s(SS),
			
			//-- clock generation
			.e(E),
			.q(Q),

			//-- dynamic addresses
			.z(ma),

			//-- ram
			.ras0_n(ras_n),
			.cas_n(cas_n),
			.we_n(sam_we_n),
			
			.dbg()//sam_dbg
);



wire [7:0] cs74138;
wire [7:0] cs74138a;
assign {
  io_cs, pia1_cs, pia_cs,
  romC_cs, romA_cs, rom8_cs,
  ram_cs
} = cs74138;
/*
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
*/

ttl_74ls138_p u11(
.a(S[0]),
.b(S[1]),
.c(S[2]),
.g1(1),//comes from CART_SLENB#
.g2a(1),//come from E NOR cs_sel(2)
.g2b(1),
//.g2a( ~(cpu_rw | S[2])),
//.g2b(~(E| S[2])),//come from E NOR cs_sel(2)
.y(cs74138)
);

//
// Not sure why the SS from the new SAM doesn't work correctly
//
ttl_74ls138_p u11a(
.a(SS[0]),
.b(SS[1]),
.c(SS[2]),
.g1(1),//comes from CART_SLENB#
.g2a( ~(cpu_rw | SS[2])),
.g2b(~(E| SS[2])),//come from E NOR cs_sel(2)
.y(cs74138a)
);



wire fs_n;
wire hs_n;
/*
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
  .ca1_in(hs_n),
  .ca2_in(),
  .cb1_in(fs_n),  // vsync? ajs instead of ca2 in?
  .cb2_in(),
  .ca2_out(sela), // used for joy & snd
  .cb2_out(selb), // used for joy & snd
  .clk(clk_14M318_ena),
  .reset(~reset)
);
*/
assign irq = irqa | irqb;
wire irqa,irqb;

pia6821 pia(
	.clk(clk_14M318_ena),
	.rst(~reset),
	.cs(pia_cs),
	.rw(~we),
	.addr(cpu_addr[1:0]),
	.data_in(cpu_dout),
	.data_out(pia_dout),
	.irqa(irqa),
	.irqb(irqb),
	.pa_i(kb_rows),
	.pa_o(),
	.pa_oe(),
	.ca1(hs_n),
	.ca2_i(),
	.ca2_o(sela),
	.ca2_oe(),
	.pb_i(),
	.pb_o(kb_cols),
	.pb_oe(),
	.cb1(fs_n),
	.cb2_i(),
	.cb2_o(selb),
	.cb2_oe()
);

wire casdin0;
wire rsout1;
wire [5:0] dac_data;
wire sela,selb;
wire snden;
// 1 bit sound
assign sndout = pia1_portb_out[1];
/*
pia6520 pia1(
  .data_out(pia1_dout),
  .data_in(cpu_dout),
  .addr(cpu_addr[1:0]),
  .strobe(pia1_cs),
  .we(we),
  .irq(firq),
  .porta_in(),
  .porta_out({dac_data,casdin0,rsout1}),
  .portb_in(),
  .portb_out(pia1_portb_out),
  .ca1_in(),
  .ca2_in(),
  .cb1_in(cart_loaded & reset & Q), // cartridge inserted
  .cb2_in(),
  .ca2_out(),
  .cb2_out(snden),
  .clk(clk_14M318_ena),
  .reset(~reset)
);
*/
assign firq = irq1a | irq1b;
wire irq1a,irq1b;
pia6821 pia1(
	.clk(clk_14M318_ena),
	.rst(~reset),
	.cs(pia1_cs),
	.rw(~we),
	.addr(cpu_addr[1:0]),
	.data_in(cpu_dout),
	.data_out(pia1_dout),
	.irqa(irq1a),
	.irqb(irq1b),
	.pa_i(),
	.pa_o({dac_data,casdin0,rsout1}),
	.pa_oe(),
	.ca1(hs_n),
	.ca2_i(),
	.ca2_o(cassmot),
	.ca2_oe(),
	.pb_i(),
	.pb_o(pia1_portb_out),
	.pb_oe(),
	.cb1(cart_loaded & reset & Q),
	.cb2_i(),
	.cb2_o(snden),
	.cb2_oe()
);



/*
wire [3:0] r4, g4, b4;
assign red = { r4,r4 };
assign green = { g4, g4};
assign blue = { b4, b4};
*/

//reg [159:0] DLine1,DLine2;


assign DLine1 = {

5'b10000,
5'b11111,
1'b0,pia1_portb_out[7:4],
5'b10000,

5'b10101,
1'b0,pia1_portb_out[3:0],
5'b10000,

5'b11010,
3'b0,ram_dout_b[7:6],
5'b10000,

110'b0};

mc6847v vdg(
  .clk(clk),
  .clk_ena(clk_14M318_ena),
  .reset(~reset),
  .da0(da0),
  .videoaddr(vdg_addr),
  .dd(ram_dout_b),
  .hs_n(hs_n),
  .fs_n(fs_n),
  .an_g(pia1_portb_out[7]), // PIA1 port B
  .an_s(ram_dout_b[7]),
  .intn_ext(pia1_portb_out[4]),
  .gm(pia1_portb_out[6:4]), // [2:0] pin 6 (gm2),5 (gm1) & 4 (gm0) PIA1 port B
  .css(pia1_portb_out[3]),
  .inv(ram_dout_b[6]),
  .red(red),
  .green(green),
  .blue(blue),
  .hsync(hsync),
  .vsync(vsync),
  .hblank(hblank),
  .vblank(vblank),
  .artifact_en(1'b1),
  .artifact_set(1'b0),
  .artifact_phase(artifact_phase),
  .cvbs(),
  .black_backgnd(1'b1),
  .char_a(vdg_char_addr), // => char rom address
  .char_d_o(char_data), // <= char rom data
  .v_count(v_count),
  .vga_h_count(vga_h_count),
  .pixel_clock(vclk)


);
/*

mc6847pace vdg(
  .clk(clk),
  .clk_ena(clk_14M318_ena),//VClk
  .reset(~reset),
  .da0(da0),
  .dd(ram_dout_b),
  .hs_n(hs_n),
  .fs_n(fs_n),
  .an_g(pia1_portb_out[7]), // PIA1 port B
  .an_s(ram_dout_b[7]),
  .intn_ext(pia1_portb_out[4]),
  .gm(pia1_portb_out[6:4]), // [2:0] pin 6 (gm2),5 (gm1) & 4 (gm0) PIA1 port B
  .css(pia1_portb_out[3]),
  .inv(ram_dout_b[6]),
  .red(red),
  .green(green),
  .blue(blue),
  .hsync(hsync),
  .vsync(vsync),
  .hblank(hblank),
  .vblank(vblank),
  .artifact_en(1'b1),
  .artifact_set(1'b0),
  .artifact_phase(artifact_phase),
  .pixel_clock(vclk),
  .cvbs()
);
*/


rom_chrrom chrrom(
  .clk(clk),
  .addr(char_rom_addr),
  .dout(chr_dout)
);
wire hilo;
keyboard kb(
.clk_sys(clk),
.reset(~reset),
.ps2_key(ps2_key),
.addr(kb_cols),
.kb_rows(kb_rows),
.kblayout(1'b1),
.Fn(),
.modif(),
.joystick_1_button(joy1[4]),
.joystick_2_button(joy2[4]),
.joystick_hilo(hilo)

);

dac dac(
.clk(clk),
.joya1(joya1),
.joya2(joya2),
.dac(dac_data),
.snden(snden),
.snd(),
.hilo(hilo),
.selb(selb),
.sela(sela),
.sound(sound)

);


assign debug_led = kb_rows != 8'hff;

endmodule
