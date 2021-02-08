
`define state_0 3'b000 // reset state and first state
`define state_1 3'b001 // state to fill screen
`define state_2 3'b010 // finished filling screen 

module fillscreen(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic done,
                  output logic [7:0] vga_x, output logic [6:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);
     // fill the screen

     /*
          Inputs:
               clk: 50Mhz clock
               rst_n: Active-low asynchronous reset
               colour: fill colour (ignored for task 2)
               start: assert to start filling the screen
          
          Outputs:
               done: goes high once the entire screen is filled
               vga_x / vga_y / vga_colour / vga_plot : outputs to the VGA adapter core

     */

     /*
          Pseudocode we want to implement:
               for x = 0 to 159:
                    for y = 0 to 119:
                         turn on pixel (x,y) with colour (x mod 8);
     */

     /*
          Fillscreen module interface:
               - assert START and hold it high until module asserts DONE
               - ignore COLOUR for task2
     */

     /*
          module vDFF_async (enable_signal, reset, in, reset_in, out);
               parameter n = 1;
               input enable_signal, reset;
               input [n-1:0] in, reset_in;
               output reg [n-1:0] out;

               always@(posedge enable_signal or negedge reset)
               begin
                    if (reset == 1'b0)
                         out = reset_in;
                    else
                         out = in;
               end
          endmodule

          note: vDFF_async is clock driven while next_state is start driven in the FSM
     */
     wire [2:0] present_state;
     logic [2:0] next_state;
     vDFF_async #3 STATE(clk, rst_n, next_state, `state_0, present_state);
     

     logic is_done;
     assign is_done = done == 1'b1 ? 1'b1 : 1'b0; // done = 1 is_done = 1, done = 0 is_done = 0;

     // ------------------------------------------------- STATE MACHINE -------------------------------------------------------------//
     // state machine idea:
     /*
          state 0: reset the coordinates, once start is asserted we immediately transition to state 1
          state 1: filling the screen, if start is high we always will stay here, as soon as its 0 we go back to state 0
                    and if high and is_done is both high then we are done filling the screen 
          state 2: end state to show fillscreen is done 

     */
     always@(*)
     begin
          case (present_state) 
               `state_0: begin
                              if (start == 1'b1)
                                   next_state = `state_1;
                              else
                                   next_state = `state_0;
                         end 

               `state_1: begin
                              if (start != 1'b1) // if start is not held go back to reset
                                   next_state = `state_0;

                              else if (start == 1'b1 && is_done != 1'b1) // if start is held but not done yet, stay until done
                                   next_state = `state_1;

                              else if (start == 1'b1 && is_done == 1'b1) // if start is held and it is done, the end fillscreen
                                   next_state = `state_2;
                              
                              else
                                   next_state = 3'bxxx;
                         end

               `state_2: begin
                              next_state = 3'bxxx;
                         end
               
               default: next_state = 3'bxxx;
          endcase
     end
     // -----------------------------------------------------------------------------------------------------------------------------//


     // ------------------------------------------------- COUNTER REGISTERS -------------------------------------------------------- //
     /*
          Looping behaviour: need to introduce registers that are clock dependant
          note: removed asynchronous reset from registers, since asynchronous reset will reset
               the state machine in which the first state enables jLoad and iLoad so that the next clock
               cycle when it starts counting it's starting already at 0
     */

     logic iCount;
     logic iLoad;
     logic [7:0] current_i;

     always@(posedge clk)
     begin
          if (iLoad == 1'b1) // load is high so we load current_i back to 0
               current_i = 0;

          else if (iCount == 1'b1) // iCount is high then count up
               current_i = current_i + 1;

          else 
               current_i = current_i;

     end

     logic jCount;
     logic jLoad;
     logic [6:0] current_j;

     always@(posedge clk)
     begin
          if (jLoad == 1'b1) // reload to 0 
               current_j = 0;

          else if (jCount == 1'b1) // jCount is high then count up
               current_j = current_j + 1;

          else 
               current_j = current_j;

     end
     // ------------------------------------------------------------------------------------------------------------------------- //

     
     // ------------------------------------------------- STATE MACHINE OUTPUTS ------------------------------------------------- //
     always@(*)
     begin
          case (present_state)

               `state_0: begin
                              vga_colour = 3'b000;
                              vga_plot = 1'b0;
                              vga_x = 8'b0;
                              vga_y = 7'b0;
                              done = 1'b0;

                              /* note: Load enable signals asserted such that next clock cycle the counters will have the starting value
                                        On the next clock cyle, it will remain at 0 unless we're in `state_1 to then we start counting
                              */
                              jLoad = 1'b1;
                              iLoad = 1'b1;
                         end

               `state_1: begin
                         /*
                         Pseudocode we want to implement:
                              for x = 0 to 159:
                                   for y = 0 to 119:
                                        turn on pixel (x,y) with colour (x mod 8);
                         */

                         /*
                              Order goes as follows:
                                   1. Check if i (outer loop) is within the bounds
                                        - if it's still in the loop we:
                                             - vga_x is the current_i
                                             - vga_y is the current_j
                                             - vga_plot is asserted
                                             - vga_colour is current_i mod 8
                                        - if it's NOT in the loop we:
                                             - reset vga_x, vga_y, vga_plot, vga_colour
                                             - assert DONE signal
                                        Note: will always print every x : y from 0 to 119 
                                   
                                   2. Check if j (inner loop) is within the bounds 
                                        - if it's still in the loop we:
                                             - dont assert increment signal for i
                                             - dont assert reload signal for i 
                                             - dont assert reload signal for j 
                                             - keep asserting counting signal for j
                                        - if it's not in the loop we:
                                             - assert ubcrenebt signal for i 
                                             - dont assert count for j so it stops
                                             - assert reload signal for j 

                                   note: all enable signals take affect the NEXT clock cycle *****
                                             meaning the logic for the conditional checks are different 
                                             such as:
                                             
                                             EX: current_i == 8'b10011111 & current_j = 1110111
                                                  - WE WILL PRINT (X,Y) = (159, 119)
                                                  - current_j will fail the current loop control check 
                                                  - enable signals are asserted and deasserted for the NEXT clock cycle 
                                        
                                        All control checks are to determine what will happen next clock cycle                    
                         */

                         // ---------------------------------- PRINT TO VGA CONTROLS ------------------------------------//
                         if (current_i > 8'b10011111) // we must be past the boundaries
                              begin
                                   iLoad = 1'b0; // no reload
                                   iCount = 1'b0; // no count
                                   jLoad = 1'b0; // no reload 
                                   jCount = 1'b0; // no count
                                   done = 1'b1; // done signal set high so next clock cycle we're able to leave this loop
                              end
                         
                         else // if we are still within the outer loop of i
                              begin 
                                   vga_x = current_i; 
                                   vga_y = current_j;
                                   vga_plot = 1'b1;
                                   vga_colour = (vga_x % 8);
                              end
                         // ---------------------------------------------------------------------------------------------//

                         // ---------------------------------- LOOP COUNTER CONTROLS ------------------------------------//
                         /*
                              Implementation note:
                                   While (current_j < 119):
                                        - We don't increment i while j is in its inner loop
                                        - We don't reload i
                                        - We don't reload j
                                        - We keep j counting
                                   What about J == 119?
                                        - The IF statement fails
                                        - Next clock cycle we reload J 
                                        - We disable count for J
                                        - We enable count for i
                                   BUT: at the current iteration, due to the VGA controls implementation, j @ 119 still gets printed 
                         */
                         if (current_j < 7'b1110111) 
                              begin
                                   iCount = 1'b0; // don't want to increment i while j is still in its loop
                                   iLoad = 1'b0; // dont want to reload i either
                                   jCount = 1'b1; // keep j counting 
                                   jLoad = 1'b0; // dont load j 
                              end

                         else // meaning j is not in its loop anymore
                              begin
                                   iCount = 1'b1; // increment i
                                   jCount = 1'b0; // deassert count for j so it stops
                                   jLoad = 1'b1; // reload j back to 0
                              end
                         // ---------------------------------------------------------------------------------------------//
                         end

               `state_2: begin
                              vga_colour = 3'b000;
                              vga_plot = 1'b0;
                              vga_x = 8'b0;
                              vga_y = 7'b0;
                              done = 1'b1;

                              jLoad = 1'b0;
                              iLoad = 1'b0;
                              jCount = 1'b0;
                              iCount = 1'b0;
                         end
          endcase
     end
     // ------------------------------------------------------------------------------------------------------------------------ //


endmodule


// inputs are (clk, rst_n, next_state, `state_0, present_state);
module vDFF_async (clk, reset, in, reset_in, out);
     parameter n = 1;
     input clk, reset;
     input [n-1:0] in, reset_in;
     output reg [n-1:0] out;

     always@(posedge clk or negedge reset)
     begin
          if (reset == 1'b0)
               out = reset_in;
          else
               out = in;
     end
endmodule
