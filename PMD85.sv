//============================================================================
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//============================================================================

module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [48:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	//if VIDEO_ARX[12] or VIDEO_ARY[12] is set then [11:0] contains scaled size instead of aspect ratio.
	output [12:0] VIDEO_ARX,
	output [12:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output [1:0]  VGA_SL,
	output        VGA_SCALER, // Force VGA scaler
	output        VGA_DISABLE, // analog out is off

	input  [11:0] HDMI_WIDTH,
	input  [11:0] HDMI_HEIGHT,
	output        HDMI_FREEZE,
	output        HDMI_BLACKOUT,
	output        HDMI_BOB_DEINT,

`ifdef MISTER_FB
	// Use framebuffer in DDRAM
	// FB_FORMAT:
	//    [2:0] : 011=8bpp(palette) 100=16bpp 101=24bpp 110=32bpp
	//    [3]   : 0=16bits 565 1=16bits 1555
	//    [4]   : 0=RGB  1=BGR (for 16/24/32 modes)
	//
	// FB_STRIDE either 0 (rounded to 256 bytes) or multiple of pixel size (in bytes)
	output        FB_EN,
	output  [4:0] FB_FORMAT,
	output [11:0] FB_WIDTH,
	output [11:0] FB_HEIGHT,
	output [31:0] FB_BASE,
	output [13:0] FB_STRIDE,
	input         FB_VBL,
	input         FB_LL,
	output        FB_FORCE_BLANK,

`ifdef MISTER_FB_PALETTE
	// Palette control for 8bit modes.
	// Ignored for other video modes.
	output        FB_PAL_CLK,
	output  [7:0] FB_PAL_ADDR,
	output [23:0] FB_PAL_DOUT,
	input  [23:0] FB_PAL_DIN,
	output        FB_PAL_WR,
`endif
`endif

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	// I/O board button press simulation (active high)
	// b[1]: user button
	// b[0]: osd button
	output  [1:0] BUTTONS,

	input         CLK_AUDIO, // 24.576 MHz
	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

	//ADC
	inout   [3:0] ADC_BUS,

	//SD-SPI
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,
	input         SD_CD,

	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	//SDRAM interface with lower latency
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,

`ifdef MISTER_DUAL_SDRAM
	//Secondary SDRAM
	//Set all output SDRAM_* signals to Z ASAP if SDRAM2_EN is 0
	input         SDRAM2_EN,
	output        SDRAM2_CLK,
	output [12:0] SDRAM2_A,
	output  [1:0] SDRAM2_BA,
	inout  [15:0] SDRAM2_DQ,
	output        SDRAM2_nCS,
	output        SDRAM2_nCAS,
	output        SDRAM2_nRAS,
	output        SDRAM2_nWE,
`endif

	input         UART_CTS,
	output        UART_RTS,
	input         UART_RXD,
	output        UART_TXD,
	output        UART_DTR,
	input         UART_DSR,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..6 - USR2..USR6
	// Set USER_OUT to 1 to read from USER_IN.
	input   [6:0] USER_IN,
	output  [6:0] USER_OUT,

	input         OSD_STATUS
);

///////// Default values for ports not used in this core /////////

//assign ADC_BUS  = 'Z;
//assign USER_OUT = '1;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
//assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;
assign {DDRAM_CLK, DDRAM_BURSTCNT, DDRAM_ADDR, DDRAM_DIN, DDRAM_BE, DDRAM_RD, DDRAM_WE} = '0;  

assign VGA_SL = 0;
assign VGA_F1 = 0;
assign VGA_SCALER  = 0;
assign VGA_DISABLE = 0;
assign HDMI_FREEZE = 0;
assign HDMI_BLACKOUT = 0;
assign HDMI_BOB_DEINT = 0;

assign AUDIO_S = 1;
assign AUDIO_MIX = 0;

wire LED_YELLOW;
wire LED_RED;

assign LED_POWER = 2'b00;	
assign LED_USER = LED_RED;
assign LED_DISK = { 1'b1, LED_YELLOW };	
assign BUTTONS = 0;

//////////////////////////////////////////////////////////////////

// PMD85 videoresolution is 288 columns x 256 rows
// PMD85 videoresolution is 288 columns x 256 visible (312,5) rows 
assign VIDEO_ARX = 8'd4;
assign VIDEO_ARY = 8'd3; 

`include "build_id.v" 
localparam CONF_STR = {
	"PMD85;;",
	"-;",	
	"F1,rmmmrm,Load to ROM Pack;",
	"R7,Eject ROM Pack;",
	"-;",
   "O8,PMD85 version,2A,3;",
	"O12,Video,Green,TV,RGB,ColorACE;",
	"D6O9,Sound,Beeper,Beeper + MIF85 (K2);",
	"O45,Joystick,None,K3,K4;",
	"D9O6,Mouse,None,K2;",		
	"-;",	
	"R0,Reset PMD;",
	"J,Fire;",
	"V,v",`BUILD_DATE 
};

wire  [1:0] buttons;
wire [31:0] status;
wire [10:0] ps2_key;
wire [24:0] ps2_mouse;

wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_data;
wire        ioctl_download;
wire  [7:0] ioctl_index;
wire        ioctl_wait;

wire [15:0] joy;

hps_io #(.CONF_STR(CONF_STR), .STRLEN($size(CONF_STR)>>3)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),
   .EXT_BUS(),
	.gamma_bus(),

	.buttons(buttons),
	.status(status),
	.status_menumask(status),
	
	.ps2_key(ps2_key),
	.ps2_mouse(ps2_mouse),
	.joystick_0(joy),
	
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_data),
	.ioctl_download(ioctl_download),
	.ioctl_index(ioctl_index),
	.ioctl_wait(ioctl_wait)
);


///////////////////////   CLOCKS   ///////////////////////////////

wire pll_locked;
wire clk_sys;   // PMD85 system clock (for 8224) is 18.432MHz
wire clk_SDRAM; // 16MHz -2.7ns phase shift SDRAM

pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_sys),
	.locked(pll_locked),
	.outclk_1(clk_SDRAM)
);

wire reset = RESET | status[0] | buttons[1];

////////////////////////   SDRAM   ///////////////////////////////

wire  [7:0] sdram_in;
wire  [7:0] sdram_out;
wire [24:0] sdram_a;
wire        sdram_we;
wire        sdram_rd;
wire        sdram_ready;

sdram ram
(
	 .*,	 
	 .init(~pll_locked),
	 .clk(clk_SDRAM),
	 .dout(sdram_out),
	 .din (sdram_in),
	 .addr(sdram_a),
	 .we(sdram_we),
	 .rd(sdram_rd),
	 .ready(sdram_ready)
);


//-------------------------------------------------------------------------------
//  Cassette audio in 
//
  
wire lineIn;
ltc2308_tape ltc2308_tape
(
	.clk(CLK_50M),
	.ADC_BUS(ADC_BUS),
	.dout(lineIn)
);  



//////////////////////////////////////////////////////////////////

wire       clk_video;
wire       SR_n;
wire       SD_n;
wire       ZAT_n;
wire       pixel;
wire       beeper;
wire [7:0] MIF85_left;
wire [7:0] MIF85_right;
wire [2:0] musica_out;
wire [1:0] pixelFunction;
wire [4:0] joystick  = { (joy[7:4] == 4'b0000), ~joy[1], ~joy[0], ~joy[3], ~joy[2] };

wire   RxD;
wire   TxD;
assign USER_OUT = {4'b1111, TxD, 1'b1};
assign RxD      = USER_IN[0];


PMD85_core PMD85_core
(
   .clk_50M(clk_sys),
   
	.clk_sys(clk_sys),
	.reset_main(reset),
	.ps2_key(ps2_key),
	.ps2_mouse(ps2_mouse),
	.joystick(joystick),
	
	.clk_video(clk_video),
	.SR_n(SR_n),
	.SD_n(SD_n),
//	.ZAT_n(ZAT_n), 
	.ZAT_n_XXX(ZAT_n), 
	
	.pixel(pixel),
	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B),	
	
	.lineIn(lineIn),
	.RxD(RxD),
	.TxD(TxD),

   .PMD_version(status[8]),
	.mouseEnabled(status[6]),
	.joystickPort(status[5:4]),
	.audioMode(status[9]),
	
	
	.ColorMode(status[2:1]),
   .RomPackType(1), // always SDRAM
	.ROMPackEject(status[7]),
	.beeper(beeper),
	.MIF85_left_out(MIF85_left),
	.MIF85_right_out(MIF85_right),
	.led_yellow(LED_YELLOW),
	.led_red(LED_RED),
	
   .sdram_in(sdram_in),
   .sdram_out(sdram_out),
   .sdram_a(sdram_a),
   .sdram_we(sdram_we),
	.sdram_rd(sdram_rd),
	.sdram_ready(sdram_ready),
	

	.ioctl_wr(ioctl_wr),	
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_data),
	.ioctl_download(ioctl_download),
	.ioctl_index(ioctl_index),
	.ioctl_wait(ioctl_wait)
);


wire   audioMode = status[9];
assign AUDIO_L   = (beeper ? 16'h0FFF : 16'h00) | ((audioMode) ? { 2'h0, MIF85_left,  6'h0 } : 16'h00);
assign AUDIO_R   = (beeper ? 16'h0FFF : 16'h00) | ((audioMode) ? { 2'h0, MIF85_right, 6'h0 } : 16'h00);



reg clk_video_last;
reg clk_video_fixed;
reg ZAT_n_fixed;

always @(posedge clk_sys)
begin
	clk_video_last <= clk_video;
	ZAT_n_fixed    <= ZAT_n;
	
	if (~clk_video_last & clk_video)
		clk_video_fixed <= 1'b1;
	else
		clk_video_fixed <= 1'b0;
end
	
assign CLK_VIDEO = clk_sys;
assign CE_PIXEL  = clk_video & ~clk_video_last;
assign VGA_HS = SR_n;
assign VGA_VS = SD_n;
assign VGA_DE = ZAT_n;


endmodule
