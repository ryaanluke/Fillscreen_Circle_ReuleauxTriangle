
module task4(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    // instantiate and connect the VGA adapter and your module

    logic [7:0] fillscreen_xout, circle_xout;
    logic [6:0] fillscreen_yout, circle_yout;
    logic fillscreen_plot, circle_plot;
    logic [2:0] fillscreen_colour_out, circle_colour_out;
    reg fillscreen_done;

    
    assign VGA_PLOT = fillscreen_done == 1'b1 ? circle_plot : fillscreen_plot;
    assign VGA_X = fillscreen_done == 1'b1 ? circle_xout : fillscreen_xout ;
    assign VGA_Y = fillscreen_done == 1'b1 ? circle_yout : fillscreen_yout ;
    assign VGA_COLOUR = fillscreen_done == 1'b1 ? circle_colour_out : fillscreen_colour_out;

    logic start_fillscreen;
    assign start_fillscreen = KEY[3] ? 1 : 0;

    reg [2:0] black_screen;
    assign black_screen = 3'b000;

    fillscreen_circle instantiate_fillscreen(.clk(CLOCK_50), 
                                      .rst_n(KEY[3]), 
                                      .colour(black_screen), 
                                      .start(start_fillscreen),
                                      .done(fillscreen_done), 
                                      .vga_x(fillscreen_xout), 
                                      .vga_y(fillscreen_yout), 
                                      .vga_colour(fillscreen_colour_out), 
                                      .vga_plot(fillscreen_plot)
                                     );
    reg circle_start;
    reg circle_done;
    assign circle_start = fillscreen_done == 1'b1 ? 1: 0;

    logic [7:0] centrex;
    logic [6:0] centrey;
    logic [7:0] dam;
    logic [2:0] circle_colour;


    assign centrex = 8'd80;
    assign centrey = 7'd60;
    assign  dam = 8'd80;
    assign circle_colour = 3'b010; // green 

    reuleaux instantiate_reuleaux(.clk(CLOCK_50),
                              .rst_n(KEY[3]), 
                              .colour(circle_colour),
                              .centre_x(centrex),
                              .centre_y(centrey),
                              .diameter(dam),
                              .start(circle_start),
                              .done(circle_done),
                              .vga_x(circle_xout), 
                              .vga_y(circle_yout), 
                              .vga_colour(circle_colour_out), 
                              .vga_plot(circle_plot)
                              );

    vga_adapter#(.RESOLUTION("160x120")) vga_u0(.resetn(KEY[3]), 
                                                .clock(CLOCK_50), 
                                                .colour(VGA_COLOUR),
                                                .x(VGA_X), 
                                                .y(VGA_Y), 
                                                .plot(VGA_PLOT),
                                                .VGA_R(VGA_R), 
                                                .VGA_G(VGA_G), 
                                                .VGA_B(VGA_B),
                                                .VGA_HS(VGA_HS), 
                                                .VGA_VS(VGA_VS), 
                                                .VGA_BLANK(VGA_BLANK),
                                                .VGA_SYNC(VGA_SYNC), 
                                                .VGA_CLK(VGA_CLK)
                                               );





endmodule: task4
