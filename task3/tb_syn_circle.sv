`timescale 1 ps / 1 ps
module tb_syn_circle();



// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
logic clock, reset, start, done, plot;
logic [2:0] colour, vga_colour;
logic [7:0] vga_x, centre_x, radius;
logic [6:0] vga_y, centre_y;
logic [7:0] VGA_R; 
logic [7:0] VGA_G; 
logic [7:0] VGA_B;
logic VGA_HS; 
logic VGA_VS; 
logic VGA_CLK;


circle DUT(clock, reset, colour, centre_x, centre_y, radius, start, done, vga_x, vga_y, vga_colour, plot);


                                               

initial begin
    clock = 0;
    forever #5 clock = ~clock;
end

initial begin
    reset = 0;
    #5;
    reset = 1;
    start = 1;
    colour = 3'b011;
    centre_x = 80;
    centre_y = 60;
    radius = 40;

    repeat (2500) begin
        $display ("x: %d y: %d", vga_x, vga_y);
        #10;
    end

    reset = 0;
    #5;
    reset = 1;
    start = 1;
    colour = 3'b011;
    centre_x = 80;
    centre_y = 60;
    radius = 40;

    repeat (2500) begin
        $display ("x: %d y: %d", vga_x, vga_y);
        #10;
    end

    #10

    reset = 0;
    #5;
    reset = 1;
    start = 1;
    colour = 3'b011;
    centre_x = 40;
    centre_y = 50;
    radius = 60;

    repeat (2500) begin
        $display ("x: %d y: %d", vga_x, vga_y);
        #10;
    end

    #10

    // out of boudns centre
    reset = 0;
    #5;
    reset = 1;
    start = 1;
    colour = 3'b011;
    centre_x = 200;
    centre_y = 200;
    radius = 100;

    repeat (2500) begin
        $display ("x: %d y: %d", vga_x, vga_y);
        #10;
    end

    #10

    // half in half out 
    reset = 0;
    #5;
    reset = 1;
    start = 1;
    colour = 3'b011;
    centre_x = 159;
    centre_y = 60;
    radius = 40;

    repeat (2500) begin
        $display ("x: %d y: %d", vga_x, vga_y);
        #10;
    end

    #10

    // half iun half out for y this time
    reset = 0;
    #5;
    reset = 1;
    start = 1;
    colour = 3'b011;
    centre_x = 100;
    centre_y = 119;
    radius = 40;

    repeat (2500) begin
        $display ("x: %d y: %d", vga_x, vga_y);
        #10;
    end

    // radius really big 

    reset = 0;
    #5;
    reset = 1;
    start = 1;
    colour = 3'b011;
    centre_x = 80;
    centre_y = 60;
    radius = 200;

    repeat (2500) begin
        $display ("x: %d y: %d", vga_x, vga_y);
        #10;
    end

    // radius really small

    reset = 0;
    #5;
    reset = 1;
    start = 1;
    colour = 3'b011;
    centre_x = 180;
    centre_y = 60;
    radius = 1;

    repeat (2500) begin
        $display ("x: %d y: %d", vga_x, vga_y);
        #10;
    end


    #10
    $stop;

end

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

endmodule: tb_syn_circle
