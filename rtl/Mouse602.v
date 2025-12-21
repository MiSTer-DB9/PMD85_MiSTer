
module Mouse602 #(parameter [26:0] CLK_FREQ = 27'd18_432_000)
(
   input wire          clk,
   input wire [24:0] ps2_mouse,

   output wire Left_Button,
   output wire Middle_Button,
   output wire Right_Button,

   output reg Ax,
   output reg Bx,
   
   output reg Ay,
   output reg By    
 );

reg  [8:0] mouseFreq;
reg        MouseEventLast;
      
wire       MouseEvent         = ps2_mouse[24];
assign     Left_Button        = ps2_mouse[0];      // left mouse button
assign     Right_Button       = ps2_mouse[1];      // right mouse button
assign     Middle_Button      = ps2_mouse[2];      // middle mouse button
wire       MouseXMovementSign = ps2_mouse[4]; // 1 = left
wire       MouseYMovementSign = ps2_mouse[5]; // 1 = down
wire [7:0] MouseXMovement     = (MouseXMovementSign) ? ~ps2_mouse[15:8]  : ps2_mouse[15:8];
wire [7:0] MouseYMovement     = (MouseYMovementSign) ? ~ps2_mouse[23:16] : ps2_mouse[23:16];
  
  
reg clk_4kHz; // 4kHz clock   
reg [25:0] cnt_4kHz; // 4kHz counter   
reg [25:0] cntMouseStop;
reg MouseStop = 0;


always @(posedge clk) 
begin
   MouseEventLast <= MouseEvent;
   
   if (MouseEventLast == ~MouseEvent)
   begin
      cntMouseStop <= 800_000;
      MouseStop <= 1'b0;
   end
   else if (!cntMouseStop)
      MouseStop <= 1'b1;
   else
      cntMouseStop <= cntMouseStop - 1'b1;
   

   if (!cnt_4kHz) 
   begin
      clk_4kHz <= ~clk_4kHz;
      cnt_4kHz <= 4_500;
      mouseFreq <= mouseFreq + 1'b1;
   end else
      cnt_4kHz <= cnt_4kHz - 26'd1;      
end   

wire MouseXclk = (MouseStop)         ? 1'b0 :
                 (MouseXMovement[7]) ? mouseFreq[0] :
                 (MouseXMovement[6]) ? mouseFreq[1] :
                 (MouseXMovement[5]) ? mouseFreq[2] :
                 (MouseXMovement[4]) ? mouseFreq[3] :
                 (MouseXMovement[3]) ? mouseFreq[4] :
                 (MouseXMovement[2]) ? mouseFreq[5] :
                 (MouseXMovement[1]) ? mouseFreq[6] :
                 (MouseXMovement[0]) ? mouseFreq[7] :
                 1'b0;

always @(posedge MouseXclk)
begin
   Ax <= Bx ^ (~MouseXMovementSign);
   Bx <= Ax ^   MouseXMovementSign;
end

wire MouseYclk = (MouseStop)         ? 1'b0 :
                 (MouseYMovement[7]) ? mouseFreq[0] :
                 (MouseYMovement[6]) ? mouseFreq[1] :
                 (MouseYMovement[5]) ? mouseFreq[2] :
                 (MouseYMovement[4]) ? mouseFreq[3] :
                 (MouseYMovement[3]) ? mouseFreq[4] :
                 (MouseYMovement[2]) ? mouseFreq[5] :
                 (MouseYMovement[1]) ? mouseFreq[6] :
                 (MouseYMovement[0]) ? mouseFreq[7] :
                 1'b0;

always @(posedge MouseYclk)
begin
   Ay <= By ^ (~MouseYMovementSign);
   By <= Ay ^ MouseYMovementSign;
end

endmodule 