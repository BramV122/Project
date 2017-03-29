module Project(CLOCK_50, KEY, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_CLK, VGA_SYNC_N, VGA_BLANK_N);

input CLOCK_50;
input [3:0] KEY;
output [7:0] VGA_R;
output [7:0] VGA_B;
output [7:0] VGA_G;
output VGA_HS;
output VGA_VS;
output VGA_CLK;
output VGA_SYNC_N;
output VGA_BLANK_N;

reg [7:0] red;
reg [7:0] green;
reg [7:0] blue;

assign clock = CLOCK_50;
assign reset = ~KEY[0];

assign VGA_R = red;
assign VGA_B = blue;
assign VGA_G = green;
assign VGA_HS = hsync;
assign VGA_VS = vsync;
assign VGA_CLK = clock;
assign VGA_SYNC_N = 1'b0;
assign VGA_BLANK_N = hsync & vsync;

wire [11:0] display_col;
wire [10:0] display_row;
wire [15:0] address;
wire [14:0] pixel;
wire visible;

VGA_Controller controller (.clock(clock), .reset(reset), .display_col(display_col), .display_row(display_row), .visible(visible), .hsync(hsync), .vsync(vsync));

BlockRam blockram (.address(address), .clock(clock), .data(1'b0), .wren(1'b0), .q(pixel));

assign address = {display_col[7:0], display_row[7:0]};

always @(posedge clock) begin
	if (visible) begin
		red = {pixel[14:10], 3'b000};
		green = {pixel[9:5], 3'b000};
		blue = {pixel[4:0], 3'b000};
	end else begin
		red = 0;
		green = 0;
		blue = 0;
	end
end

endmodule 