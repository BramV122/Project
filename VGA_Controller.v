module VGA_Controller(clock, reset, display_col, display_row, visible, hsync, vsync);

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
	parameter HOR_Front_porch = 40; //40
	parameter HOR_Sync_pulse = 128; //128
	parameter HOR_Back_porch = 88; //88
	parameter HOR_TOTAL = 1056;

	// Vertical timing
	parameter VER_Visible_Area = 600;
	parameter VER_Front_porch = 1; // 1
	parameter VER_Sync_pulse = 4; // 4
	parameter VER_Back_porch = 23;
	parameter VER_TOTAL = 628;
  
  input clock; 
  input reset;                   // reset signal 
  output reg [11:0] display_col; // horizontal counter 
  output reg [10:0] display_row; // vertical counter 
  output reg visible;           	   // signal visible on display 
  input hsync, vsync;
  
  reg previous_hsync;
  reg previous_vsync;


  always @(display_col or display_row) begin
		if(display_col > HOR_Front_porch && display_col < (HOR_Visible_Area + HOR_Front_porch) && 
		   display_row > VER_Front_porch && display_row < (VER_Visible_Area + VER_Front_porch)) begin
			visible = 1;
		end else begin
			visible = 0;
		end
  end


  /*
  always @(posedge clock or posedge reset) begin
		if (reset) begin
			display_row = 0;
			display_col = 0;
		end else begin //else if vsync = 1 en vsync != previous -> reset
			if (previous_hsync != hsync && hsync == 1) begin
				display_col = 1;
				//display_row = display_row < VER_TOTAL ? (display_row + 1) : 0;
				display_row = display_row + 1;
			end else if(previous_vsync != vsync && vsync == 1) begin
				display_row = 1;
			end else if((previous_vsync != vsync && vsync == 1) && (previous_hsync != hsync && hsync == 1)) begin
				display_row = 1;
				display_col = 1;
			end else begin
				display_col = display_col + 1;
			end
			/*if (previous_hsync != hsync && hsync == 1) begin
				display_col = 0;
			end*/
			/*if (previous_vsync != vsync && vsync == 1) begin
				display_row = display_row < VER_TOTAL ? (display_row + 1) : 0;
			end
			previous_hsync = hsync;
			previous_vsync = vsync;
		end
  end*/

integer vsynccounter, hsynccounter;

always @(posedge clock) begin
	if(vsync == 0) begin
		vsynccounter = vsynccounter + 1;
	end else if (vsync == 1) begin
		vsynccounter = 0;
	end
	
	if(hsync == 0) begin
		hsynccounter = hsynccounter + 1;
	end else if (hsync == 1) begin
		hsynccounter = 0;
	end
	
	if(vsynccounter > 1) begin
		display_row = 0;
		display_col = 0;
	end else if(hsynccounter > 1) begin
		display_col = 0;
		if(hsynccounter == 2) begin
			display_row = display_row + 1;
		end
	end else begin
		display_col = display_col + 1;
	end
	previous_hsync = hsync;
	previous_vsync = vsync;
end


  
endmodule 