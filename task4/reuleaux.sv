
`define state_size 3
`define reset_state 3'b000
`define draw_circle_1 3'b001
`define draw_circle_2 3'b010
`define draw_circle_3 3'b011
`define end_state 3'b100


module reuleaux(input logic clk, input logic rst_n, input logic [2:0] colour,
                input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] diameter,
                input logic start, output logic done,
                output logic [7:0] vga_x, output logic [6:0] vga_y,
                output logic [2:0] vga_colour, output logic vga_plot);
     // draw the Reuleaux triangle

     logic [9:0] circle_1_x_bound_up, circle_2_x_bound_up, circle_3_x_bound_up;
     logic [9:0] circle_1_x_bound_low, circle_2_x_bound_low, circle_3_x_bound_low;
     logic [9:0] circle_1_y_bound_up, circle_2_y_bound_up, circle_3_y_bound_up;
     logic [9:0] circle_1_y_bound_low, circle_2_y_bound_low, circle_3_y_bound_low;
     logic [9:0] circle1_centre_x, circle1_centre_y;
     logic [9:0] circle2_centre_x, circle2_centre_y;
     logic [9:0] circle3_centre_x, circle3_centre_y;
     
     logic circle_1_done, circle_2_done, circle_3_done;
     logic draw_circle_1, draw_circle_2, draw_circle_3;

     logic [7:0] circ1_vga_x, circ2_vga_x, circ3_vga_x;
     logic [6:0] circ1_vga_y, circ2_vga_y, circ3_vga_y;
     logic circ1_vga_plot, circ2_vga_plot, circ3_vga_plot;

     always_comb
          begin
               if (draw_circle_1 == 1) begin
                    vga_x = circ1_vga_x;
                    vga_y = circ1_vga_y;
                    vga_plot = circ1_vga_plot;
               end
               else if (draw_circle_2 == 1) begin
                    vga_x = circ2_vga_x;
                    vga_y = circ2_vga_y;
                    vga_plot = circ2_vga_plot;
               end
               else if (draw_circle_3 == 1) begin
                    vga_x = circ3_vga_x;
                    vga_y = circ3_vga_y;
                    vga_plot = circ3_vga_plot;
               end
               else begin
                    vga_x = 0;
                    vga_y = 0;
                    vga_plot = 0;
               end
          end
     
     assign circle1_centre_x = centre_x - (diameter / 2);
     assign circle1_centre_y = centre_y + (((diameter * 17320) / 10000) / 6);
     assign circle_1_x_bound_up = centre_x + (diameter / 2);
     assign circle_1_x_bound_low = centre_x - 1;
     assign circle_1_y_bound_up = centre_y + (((diameter * 17320) / 10000) / 6);
     assign circle_1_y_bound_low = centre_y - ( (((diameter * 17320) / 10000) / 2) - (((diameter * 17320) / 10000) / 6) ) ;

     assign circle2_centre_x = centre_x + (diameter / 2);
     assign circle2_centre_y = centre_y + (((diameter * 17320) / 10000) / 6);
     assign circle_2_x_bound_up = centre_x + 1;
     assign circle_2_x_bound_low = centre_x - (diameter / 2);
     assign circle_2_y_bound_up = centre_y + (((diameter * 17320) / 10000) / 6);
     assign circle_2_y_bound_low = centre_y - ( (((diameter * 17320) / 10000) / 2) - (((diameter * 17320) / 10000) / 6) );

     assign circle3_centre_x = centre_x;
     assign circle3_centre_y = centre_y - ( (((diameter * 17320) / 10000) / 2) - (((diameter * 17320) / 10000) / 6) );
     assign circle_3_x_bound_up = centre_x + (diameter / 2);
     assign circle_3_x_bound_low = centre_x - (diameter / 2);
     assign circle_3_y_bound_up = 8'd120;
     assign circle_3_y_bound_low = centre_y + (((diameter * 17320) / 10000) / 6);


     circle_t4 circle_1(.clk(clk), 
                        .rst_n(rst_n), 
                        .colour(colour), 
                        .x_bound_low(circle_1_x_bound_low),
                        .x_bound_up(circle_1_x_bound_up), 
                        .y_bound_low(circle_1_y_bound_low), 
                        .y_bound_up(circle_1_y_bound_up),
                        .centre_x(circle1_centre_x), 
                        .centre_y(circle1_centre_y), 
                        .radius(diameter),
                        .start(draw_circle_1), 
                        .done(circle_1_done), 
                        .vga_x(circ1_vga_x), 
                        .vga_y(circ1_vga_y),
                        .vga_plot(circ1_vga_plot));

     circle_t4 circle_2(.clk(clk), 
                        .rst_n(rst_n), 
                        .colour(colour), 
                        .x_bound_low(circle_2_x_bound_low),
                        .x_bound_up(circle_2_x_bound_up), 
                        .y_bound_low(circle_2_y_bound_low), 
                        .y_bound_up(circle_2_y_bound_up),
                        .centre_x(circle2_centre_x), 
                        .centre_y(circle2_centre_y), 
                        .radius(diameter),
                        .start(draw_circle_2), 
                        .done(circle_2_done), 
                        .vga_x(circ2_vga_x), 
                        .vga_y(circ2_vga_y),
                        .vga_plot(circ2_vga_plot));

     circle_t4 circle_3(.clk(clk), 
                        .rst_n(rst_n), 
                        .colour(colour), 
                        .x_bound_low(circle_3_x_bound_low),
                        .x_bound_up(circle_3_x_bound_up), 
                        .y_bound_low(circle_3_y_bound_low), 
                        .y_bound_up(circle_3_y_bound_up),
                        .centre_x(circle3_centre_x), 
                        .centre_y(circle3_centre_y), 
                        .radius(diameter),
                        .start(draw_circle_3), 
                        .done(circle_3_done), 
                        .vga_x(circ3_vga_x), 
                        .vga_y(circ3_vga_y),
                        .vga_plot(circ3_vga_plot));

     statemachine_reuleaux sm(.clk(clk), 
                              .rst_n(rst_n), 
                              .start(start), 
                              .circle_1_done(circle_1_done), 
                              .circle_2_done(circle_2_done), 
                              .circle_3_done(circle_3_done),
                              .draw_circle_1(draw_circle_1), 
                              .draw_circle_2(draw_circle_2), 
                              .draw_circle_3(draw_circle_3), 
                              .done(done));

     assign vga_colour = colour;

endmodule

module statemachine_reuleaux(input logic clk, 
                             input logic rst_n, 
                             input logic start, 
                             input logic circle_1_done, 
                             input logic circle_2_done, 
                             input logic circle_3_done, 
                             output logic draw_circle_1, 
                             output logic draw_circle_2, 
                             output logic draw_circle_3, 
                             output logic done);

     logic [`state_size - 1:0] present_state, next_state; 
     logic [6:0] next;

     always_ff @(posedge clk, negedge rst_n)
          begin
               if (rst_n == 0)
                    present_state <= `reset_state;
               else 
                    present_state <= next_state;
          end
     
     always_comb
          begin
               case(present_state)
               
                    `reset_state : 
                    begin
                         if (start == 1)
                              next = {`draw_circle_1, 4'b0000};
                         else 

                              next = {`reset_state, 4'b0000};
                    end

                    `draw_circle_1 : 
                    begin
                         if (circle_1_done == 1)
                              next = {`draw_circle_2, 4'b0000};

                         else 
                              next = {`draw_circle_1, 4'b1000};
                    end

                    `draw_circle_2 : 
                    begin
                         if (circle_2_done == 1)
                              next = {`draw_circle_3, 4'b0000};

                         else 
                              next = {`draw_circle_2, 4'b0100};
                    end

                    `draw_circle_3 : 
                    begin
                         if (circle_3_done == 1)
                              next = {`end_state, 4'b0000};

                         else 
                              next = {`draw_circle_3, 4'b0010};
                    end

                    `end_state : next = {`end_state, 4'b0001};

                    default : next = {`reset_state, 4'b0000};
               
               endcase
          end

     
     assign {next_state, draw_circle_1, draw_circle_2, draw_circle_3, done} = next;


endmodule

