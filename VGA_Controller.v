module VGA_Controller(clock, reset, display_col, display_row, visible, hsync, vsync);

//72 Hz 800 x 600 VGA - 50MHz clock 
  parameter HOR_FIELD    =  799; 
  parameter HOR_STR_SYNC =  855; 
  parameter HOR_STP_SYNC =  978; 
  parameter HOR_TOTAL    = 1042; 
  parameter VER_FIELD    =  599; 
  parameter VER_STR_SYNC =  636; 
  parameter VER_STP_SYNC =  642; 
  parameter VER_TOTAL    =  665;
  
  input clock; 
  input reset;                   // reset signal 
  output reg [11:0] display_col; // horizontal counter 
  output reg [10:0] display_row; // vertical counter 
  output visible;                // signal visible on display 
  output reg hsync, vsync;

  assign visible = !(display_row > VER_FIELD || display_col > HOR_FIELD);
  
  always @(posedge clock) begin
		if (reset) begin
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
		end
  end
  
  always @(posedge clock) begin
		hsync = 1;
		if (display_col >= HOR_STR_SYNC && display_col <= HOR_STP_SYNC) begin hsync = 0; end
  end
  
  always @(posedge clock) begin
		vsync = 1;
		if (display_row >= VER_STR_SYNC && display_row <= VER_STP_SYNC) begin vsync = 0;  end
	end

endmodule 