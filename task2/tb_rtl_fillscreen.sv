
module tb_rtl_fillscreen();

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
    
    $display ("Testing if asserting rst_in to start will go to proper state: `STATE_0");
    #1
    rst_n = 1'b0; // click
    #1 
    rst_n = 1'b1; // unclick 
    
    #1
    assert (DUT.present_state == 3'b000) $display ("RST_N ASSERTED : PRESENT_STATE = `STATE_0 CORRECT");
    else $display("RST_N ASSERTED : PRESENT_STATE != STATE_0 INCORRECT");


    $display ("Testing if asserting and deasserting start will go to the proper state while screen is filling");
    #1
    start = 1'b1; // hold 
    #100
    start = 1'b0; // unhold

    #10
    assert (DUT.present_state == 3'b000) $display ("START UNHELD : PRESENT_STATE = `STATE_0 CORRECT");
    else $display("START UNHELD : PRESENT_STATE != STATE_0 INCORRECT");
    


    $display ("Now testing if done will be high in clkspeed * 19210 ");
    #1
    rst_n = 1'b0; // click
    start = 1'b1;
    #1
    rst_n = 1'b1; // unclick 

    #38420
    assert (DUT.done == 1'b1) $display("AFTER 38420 STALL : DONE == HIGH ");
    else $display ("AFTER 38420 STALL : DONE != HIGH : ERROR");



    #100
    $stop;
end

endmodule: tb_rtl_fillscreen
