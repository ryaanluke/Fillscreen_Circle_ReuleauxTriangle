
`timescale 1 ps / 1 ps

module tb_syn_fillscreen();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

logic clk, rst_n, start, done, vga_plot;
logic [2:0] colour, vga_colour;
logic [7:0] vga_xout;
logic [6:0] vga_yout;

fillscreen DUT(clk, rst_n, colour, start, done, vga_xout, vga_yout, vga_colour, vga_plot);

initial begin
    clk = 0;
    forever #1 clk = ~clk;
end

initial begin
    
    $display ("Now testing if done will be high in clkspeed * 19210 ");
    #1
    rst_n = 1'b0; // click
    start = 1'b1;
    #1
    rst_n = 1'b1; // unclick 

    #38420
    assert (vga_plot == 1'b0) $display("AFTER 38420 STALL : PLOT == LOW CORRECT");
    else $display ("AFTER 38420 STALL : PLOT != LOW : ERROR");



    #1
    $stop;
end

endmodule: tb_syn_fillscreen
