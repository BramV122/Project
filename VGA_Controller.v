module VGA_Controller(clock, reset, display_col, display_row, visible, refresh, hsync, vsync);

//72 Hz 800 x 600 VGA - 50MHz clock 
//  parameter HOR_FIELD    =  799; 
//  parameter HOR_STR_SYNC =  855; 
//  parameter HOR_STP_SYNC =  978; 
//  parameter HOR_TOTAL    = 1042; 
//  parameter VER_FIELD    =  599; 
//  parameter VER_STR_SYNC =  636; 
//  parameter VER_STP_SYNC =  642; 
//  parameter VER_TOTAL    =  665;

	// Horizontal timing
	parameter HOR_Visible_Area = 800;
	parameter HOR_Front_porch = 40;
	parameter HOR_Sync_pulse = 128;
	parameter HOR_Back_porch = 88;
	parameter HOR_TOTAL = 1056;

	// Vertical timing
	parameter VER_Visible_Area = 600;
	parameter VER_Front_porch = 40;
	parameter VER_Sync_pulse = 4;
	parameter VER_Back_porch = 23;
	parameter VER_TOTAL = 628;
  
  input clock; 
  input reset;                   // reset signal 
  input refresh;						// reset display_col en display_row
  output reg [11:0] display_col; // horizontal counter 
  output reg [10:0] display_row; // vertical counter 
  output visible;           	   // signal visible on display 
  //output reg hsync, vsync;
  input hsync, vsync;

  assign visible = !(display_row > (VER_TOTAL - VER_Back_porch - VER_Sync_pulse) || display_col > (HOR_TOTAL - HOR_Back_porch - HOR_Sync_pulse) || display_row < VER_Front_porch || display_col < HOR_Front_porch);
  
  reg previous_hsync;
  reg previous_vsync;

  
  always @(posedge clock or posedge reset /*or posedge refresh*/) begin
		if (reset /*|| refresh*/) begin
			display_row = 0;
			display_col = 0;
		end else begin
			if (display_col < HOR_TOTAL) begin
				display_col = display_col + 1;
			end else begin
				display_col = 0;
				if (display_row < VER_TOTAL) begin
					display_row = display_row + 1;
				end else begin
					display_row = 0;
				end
			end
			/*if (previous_hsync != hsync && hsync == 1) begin
				display_col = 0;
				previous_hsync = hsync;
			end else begin
				previous_hsync = hsync;
			end
			if (previous_vsync != vsync && vsync == 1) begin
				display_row = 0;
				previous_vsync = vsync;
			end else begin
				previous_vsync = vsync;
			end*/
		end
  end
  
  /*always @(posedge clock) begin
		hsync = 1;
		if (display_col >= HOR_STR_SYNC && display_col <= HOR_STP_SYNC) begin hsync = 0; end
  end
  
  always @(posedge clock) begin
		vsync = 1;
		if (display_row >= VER_STR_SYNC && display_row <= VER_STP_SYNC) begin vsync = 0;  end
	end*/

endmodule 