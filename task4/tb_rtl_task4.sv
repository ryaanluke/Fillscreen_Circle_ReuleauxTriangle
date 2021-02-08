`timescale 1 ps / 1 ps
module tb_rtl_task4();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

logic clock50, vga_hs, vga_vs, vga_clk, vga_plot;
logic [3:0] keys;
logic [9:0] switches, leds;
logic [6:0] hex0, hex1, hex2, hex3, hex4, hex5;
logic [7:0] vgar, vgag, vgab;
logic [7:0] vga_x;
logic [6:0] vga_y;
logic [2:0] vga_colour;

task4 DUT(.CLOCK_50(clock50),
          .KEY(keys),
          .SW(switches),
          .LEDR(leds),
          .HEX0(hex0),
          .HEX1(hex1),
          .HEX2(hex2),
          .HEX3(hex3),
          .HEX4(hex4),
          .HEX5(hex5),
          .VGA_R(vgar),
          .VGA_G(vgag),
          .VGA_B(vgab),
          .VGA_HS(vga_hs),
          .VGA_VS(vga_vs),
          .VGA_CLK(vga_clk),
          .VGA_X(vga_x),
          .VGA_Y(vga_y),
          .VGA_COLOUR(vga_colour),
          .VGA_PLOT(vga_plot)
         );

vga_adapter#(.RESOLUTION("160x120")) vga_u0(.resetn(keys[3]), 
                                                .clock(clock50), 
                                                .colour(vga_colour),
                                                .x(vga_x), 
                                                .y(vga_y), 
                                                .plot(vga_plot),
                                                .VGA_R(vgar), 
                                                .VGA_G(vgag), 
                                                .VGA_B(vgab),
                                                .VGA_HS(vga_hs), 
                                                .VGA_VS(vga_vs), 
                                                .VGA_BLANK(VGA_BLANK),
                                                .VGA_SYNC(VGA_SYNC), 
                                                .VGA_CLK(VGA_CLK)
                                               ); 

initial begin
    clock50 = 0;
    forever #1 clock50 = ~clock50;
end

initial begin
    $display ("Now testing if done will be high in clkspeed * 19210 ");
    #1
    keys = 4'b0000; // click
    #1
    keys = 4'b1000; // unclick 

    #48420
    assert (vga_plot == 1'b1) $display("AFTER 38420 STALL : DONE == HIGH ");
    else $display ("AFTER 38420 STALL : DONE != HIGH : ERROR");



    #100
    $stop;
    
end


endmodule: tb_rtl_task4
