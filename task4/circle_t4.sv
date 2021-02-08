`define SW 4
`define RESET 4'b0000
`define START 4'b0001
`define LOOP_START 4'b0010
`define OCTANT_1 4'b0011
`define OCTANT_2 4'b0100
`define OCTANT_3 4'b0101
`define OCTANT_4 4'b0110
`define OCTANT_5 4'b0111
`define OCTANT_6 4'b1000
`define OCTANT_7 4'b1001
`define OCTANT_8 4'b1010
`define INCREMENT_OFFSET_Y 4'b1011
`define INCREMENT_CRIT_1 4'b1100
`define INCREMENT_CRIT_2 4'b1101
`define INCREMENT_OFFSET_X  4'b1110
`define c_DONE 4'b1111

module circle_t4(input logic clk, 
                 input logic rst_n, 
                 input logic [2:0] colour, 
                 input logic [9:0] x_bound_low,
                 input logic [9:0] x_bound_up, 
                 input logic [9:0] y_bound_low, 
                 input logic [9:0] y_bound_up,
                 input logic [9:0] centre_x, 
                 input logic [9:0] centre_y, 
                 input logic [7:0] radius,
                 input logic start, output logic done,
                 output logic [7:0] vga_x, 
                 output logic [6:0] vga_y,
                 output logic vga_plot);
     // draw the circle

     logic octant1, octant2, octant3, octant4, octant5, octant6, octant7, octant8; // Statemachine outputs
     logic increment_y, increment_x, increment_crit_1, increment_crit_2; // Statemachine outputs

     logic crit_condition, loop_condition; // Statemachine inputs 
     logic [9:0] offset_x, next_vga_x;
     logic [9:0] offset_y; 
     logic [9:0] next_vga_y;
     logic [9:0] crit;
     logic internal_start, inner_plot;

     assign crit_condition = ($signed(crit) <= 0) ? 1 : 0;
     assign loop_condition = ($signed(offset_y) <= $signed(offset_x)) ? 1 : 0; 

     assign vga_colour = colour;


    /*

        Using always_ff so they can retain value if conditions aren't met, only changes on enable signals

    */

    // Control VGA outputs
     always_ff @(posedge clk)
          if (octant1 == 1) begin
               next_vga_x = centre_x + offset_x;
               next_vga_y = centre_y + offset_y;
          end
          else if (octant2 == 1) begin
               next_vga_x = centre_x + offset_y;
               next_vga_y = centre_y + offset_x;
          end
          else if (octant3 == 1) begin
               next_vga_x = centre_x - offset_x;
               next_vga_y = centre_y + offset_y;
          end
          else if (octant4 == 1) begin
               next_vga_x = centre_x - offset_y;
               next_vga_y = centre_y + offset_x;
          end
          else if (octant5 == 1) begin
               next_vga_x = centre_x - offset_x;
               next_vga_y = centre_y - offset_y;
          end
          else if (octant6 == 1) begin
               next_vga_x = centre_x - offset_y;
               next_vga_y = centre_y - offset_x;
          end
          else if (octant7 == 1) begin
               next_vga_x = centre_x + offset_x;
               next_vga_y = centre_y - offset_y;
          end
          else if (octant8 == 1) begin
               next_vga_x = centre_x + offset_y;
               next_vga_y = centre_y - offset_x;
          end
          else begin
               next_vga_x <= next_vga_x;
               next_vga_y <= next_vga_y;
          end
     
     // Control offset-y increment 
     always_ff @(posedge clk)
          if (internal_start == 1)
               offset_y <= 0;
          else if (increment_y == 1)
               offset_y <= offset_y + 1;
          else 
               offset_y <= offset_y;

    // Control offset_x decriment
     always_ff @(posedge clk)
          if (internal_start == 1)
               offset_x <= radius;
          else if (increment_x == 1)
               offset_x <= offset_x - 1;
          else
               offset_x <= offset_x;
    
    // Control crit conditions for curv
     always_ff @(posedge clk)
          if (internal_start == 1)
               crit <= 1 - radius;
          else if (increment_crit_1 == 1)
               crit <= crit + (2 * offset_y) + 1;
          else if (increment_crit_2 == 1)
               crit <= crit + (2 * (offset_y - offset_x)) + 1;
          else 
               crit <= crit;
     
     assign vga_x = next_vga_x[7:0];
     assign vga_y = next_vga_y[6:0];

    // Controlling VGA_plot signal depending on bounds
     always_comb
          if (inner_plot == 1 && $signed(next_vga_x) >= $signed(x_bound_low) // To check if we are within both sub bounds and VGA bounds
               && $signed(next_vga_x) <= $signed(x_bound_up) 
               && $signed(next_vga_y) >= $signed(y_bound_low) 
               && $signed(next_vga_y) <= $signed(y_bound_up) 
               && $signed(next_vga_x) >= 0 
               && $signed(next_vga_x) <= $signed(10'd159) 
               && $signed(next_vga_y) >= 0 
               && $signed(next_vga_y) <= $signed(10'd119))
               vga_plot = 1;
          else
               vga_plot = 0;
     
     statemachine sm(.clk(clk), 
                     .crit_condition(crit_condition), 
                     .loop_condition(loop_condition), 
                     .rst_n(rst_n), 
                     .start(start),
                     .octant1(octant1), 
                     .octant2(octant2), 
                     .octant3(octant3), 
                     .octant4(octant4),
                     .octant5(octant5), 
                     .octant6(octant6), 
                     .octant7(octant7), 
                     .octant8(octant8), 
                     .internal_start(internal_start), 
                     .increment_crit_1(increment_crit_1), 
                     .increment_crit_2(increment_crit_2), 
                     .increment_x(increment_x), 
                     .increment_y(increment_y),
                     .plot(inner_plot), 
                     .done(done));

endmodule

module statemachine(input logic clk, 
                    input logic crit_condition, 
                    input logic loop_condition, 
                    input logic rst_n, 
                    input logic start,
                    output logic octant1, 
                    output logic octant2, 
                    output logic octant3, 
                    output logic octant4, 
                    output logic octant5, 
                    output logic octant6, 
                    output logic octant7, 
                    output logic octant8,
                    output logic internal_start, 
                    output logic increment_crit_1, 
                    output logic increment_crit_2, 
                    output logic increment_x, 
                    output logic increment_y, 
                    output logic plot, 
                    output logic done);

     logic [`SW - 1:0] present_state, next_state; 
     logic [18:0] next;

     always_ff @(posedge clk, negedge rst_n)
          if (rst_n == 0)
               present_state <= `RESET;
          else 
               present_state <= next_state;
     
     always_comb 
          case (present_state)
               `RESET : 
                    begin
                            if (start == 1)
                                next = {`START, 15'd0};
                            else
                                next = {`RESET, 15'd0};
                    end

               `START : next = {`LOOP_START, 15'b10000_00000_00000};

               `LOOP_START : 
                    begin
                            if (loop_condition == 1)
                                next = {`OCTANT_1, 15'd0};
                            else
                                next = {`c_DONE, 15'd0};
                    end

               `OCTANT_1 : next = {`OCTANT_2, 10'b01000_00001, 5'd0};

               `OCTANT_2 : next = {`OCTANT_3, 10'b00100_00001, 5'd0};

               `OCTANT_3 : next = {`OCTANT_4, 10'b00010_00001, 5'd0};

               `OCTANT_4 : next = {`OCTANT_5, 10'b00001_00001, 5'd0};

               `OCTANT_5 : next = {`OCTANT_6, 10'b00000_10001, 5'd0};

               `OCTANT_6 : next = {`OCTANT_7, 10'b00000_01001, 5'd0};

               `OCTANT_7 : next = {`OCTANT_8, 10'b00000_00101, 5'd0};

               `OCTANT_8 : next = {`INCREMENT_OFFSET_Y, 10'b00000_00011, 5'd0};

               `INCREMENT_OFFSET_Y : next = {`INCREMENT_CRIT_1, 10'b00000_00011, 5'b01000};

               `INCREMENT_CRIT_1 : 
                    begin
                            if (crit_condition == 1)
                                next = {`LOOP_START, 10'd0, 5'b00100};
                            else 
                                next = {`INCREMENT_CRIT_2, 10'd0, 5'b10000};
                    end

               `INCREMENT_CRIT_2 : next = {`LOOP_START, 10'd0, 5'b00010};

               `c_DONE : next = {`c_DONE, 15'd1};
					default : next = {`RESET, 15'd0};
          endcase
    // concatinating signals to reduce redundancy 
     assign {next_state, internal_start, octant1, octant2, octant3, octant4, octant5, octant6, octant7, octant8, plot, increment_x, increment_y, increment_crit_1, increment_crit_2, done} = next;

endmodule

