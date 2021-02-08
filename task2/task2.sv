
module task2(input logic CLOCK_50, 
             input logic [3:0] KEY,
             input logic [9:0] SW, 
             output logic [9:0] LEDR,
             output logic [6:0] HEX0, 
             output logic [6:0] HEX1, 
             output logic [6:0] HEX2,
             output logic [6:0] HEX3, 
             output logic [6:0] HEX4, 
             output logic [6:0] HEX5,
             output logic [7:0] VGA_R, 
             output logic [7:0] VGA_G, 
             output logic [7:0] VGA_B,
             output logic VGA_HS, 
             output logic VGA_VS, 
             output logic VGA_CLK,
             output logic [7:0] VGA_X, 
             output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, 
             output logic VGA_PLOT);

    // instantiate and connect the VGA adapter and your module
    reg fillscreen_done;
    logic start;
    assign start = KEY[3] ? 1 : 0;

    fillscreen instantiate_fillscreen(.clk(CLOCK_50), 
                                      .rst_n(KEY[3]), 
                                      .colour(SW[2:0]), 
                                      .start(start),
                                      .done(fillscreen_done), 
                                      .vga_x(VGA_X), 
                                      .vga_y(VGA_Y), 
                                      .vga_colour(VGA_COLOUR), 
                                      .vga_plot(VGA_PLOT)
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
endmodule: task2
