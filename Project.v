module Project(CLOCK_50, KEY, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_CLK, VGA_SYNC_N, VGA_BLANK_N, GPIO, LEDR, LEDG, SW);

input CLOCK_50;
input [3:0] KEY;
input [35:0] GPIO;
input [17:0] SW;

output [7:0] VGA_R;
output [7:0] VGA_B;
output [7:0] VGA_G;
output VGA_HS;
output VGA_VS;
output VGA_CLK;
output VGA_SYNC_N;
output VGA_BLANK_N;
output [17:0] LEDR;
output [8:0] LEDG;

assign LEDG[0] = GPIO[0];
assign LEDG[1] = GPIO[4];
assign LEDG[2] = GPIO[14];

assign LEDR[14:0] = pixel;

reg [7:0] red;
reg [7:0] green;
reg [7:0] blue;

assign reset = ~KEY[0];

assign VGA_R = red;
assign VGA_B = blue;
assign VGA_G = green;
assign VGA_HS = input_hsync;
assign VGA_VS = input_vsync;
assign VGA_CLK = clock;
assign VGA_SYNC_N = 1'b0;
assign VGA_BLANK_N = input_hsync & input_vsync;

wire [11:0] display_col;
wire [10:0] display_row;
wire [15:0] address;
wire visible;

reg [14:0] pixel;
assign input_hsync = SW[17] ? ~GPIO[1] : GPIO[1];
assign input_vsync = SW[16] ? ~GPIO[3] : GPIO[3];

reg refresh;
wire clock;

PLL pll (.inclk0(CLOCK_50), .c0(clock));

VGA_Controller controller (.clock(clock), .reset(reset), .display_col(display_col), .display_row(display_row), .visible(visible), .hsync(input_hsync), .vsync(input_vsync));

//BlockRam blockram (.address(address), .clock(clock), .data(1'b0), .wren(1'b0), .q(pixel));

reg [2:0] out;
reg [15:0] write_address;
reg [2:0] comparator;
reg wren;

Display_Ram display_ram (.clock(clock), .data(pixel2), .rdaddress(address), .wraddress(address), .wren(1'b1), .q(pixel));

//display_ram ram (.rdclock(clock), .wrclock(clock), .data(comparator), .rdaddress(address), .wraddress(write_address), .wren(wren), .q(out));

assign address = {display_row[8:0], display_col[9:0]};

/*always @(posedge clock) begin
	if (display_col < 256 && display_row < 256) begin
		wren = 1;
		write_address = address + 1;
		comparator = {GPIO[14], GPIO[4], GPIO[0]};
	end else begin
		wren = 0;
	end
end*/

always @(posedge clock) begin
	comparator = {GPIO[14], GPIO[4], GPIO[0]};
	out = comparator;
end

reg [14:0] pixel2;

always @(posedge clock) begin
	if (visible) begin
		if (out[0]) begin
			if (pixel[14:10] < 5'b11111) pixel2[14:10] = pixel[14:10] + 1;
		end else begin
			if (pixel[14:10] > 5'b00000) pixel2[14:10] = pixel[14:10] - 1;
		end
		if (out[1]) begin
			if (pixel[9:5] < 5'b11111) pixel2[9:5] = pixel[9:5] + 1;
		end else begin
			if (pixel[9:5] > 5'b00000) pixel2[9:5] = pixel[9:5] - 1;
		end
		if (out[2]) begin
			if (pixel[4:0] < 5'b11111) pixel2[4:0] = pixel[4:0] + 1;
		end else begin
			if (pixel[4:0] > 5'b00000) pixel2[4:0] = pixel[4:0] - 1;
		end
	end
end

always @(posedge clock) begin
	if (visible) begin
		if (SW[2] == 0) begin red = {pixel[14:10], 3'b000}; end else begin red = 0; end
		if (SW[1] == 0) begin green = {pixel[9:5], 3'b000}; end else begin green = 0; end
		if (SW[0] == 0) begin blue = {pixel[4:0], 3'b000}; end else begin blue = 0; end
	end else begin
		red = 0;
		green = 0;
		blue = 0;
	end
end

endmodule 