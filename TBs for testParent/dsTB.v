`timescale 1ns / 1ps

module dsTB;

    localparam DEPTH = 5;
    localparam WIDTH = 8;

    reg clock;
    reg reset;
    reg [WIDTH-1:0] dataIn;
    reg insert, del;
    reg ptrLeft, ptrRight;

    // observe memory
    wire [7:0] b0, b1, b2, b3, b4;
    assign b0 = dut.mem[0];
    assign b1 = dut.mem[1];
    assign b2 = dut.mem[2];
    assign b3 = dut.mem[3];
    assign b4 = dut.mem[4];
    
    //observe size and ptr
    wire [2:0] size, ptr;
    assign size = dut.size;
    assign ptr = dut.ptr;

    // DUT
    ds #(
        .depth(DEPTH),
        .width(WIDTH)
    ) dut (
        .clock(clock),
        .reset(reset),
        .dataIn(dataIn),
        .insert(insert),
        .del(del),
        .ptrLeft(ptrLeft),
        .ptrRight(ptrRight)
    );

    // clock
    always #5 clock = ~clock;

    initial begin
        // init
        clock = 0;
        reset = 1;
        insert = 0;
        del = 0;
        ptrLeft = 0;
        ptrRight = 0;
        dataIn = 0;

        // release reset
        #12;
        reset = 0;


        // -------------------------
        // insert again
        // -------------------------
        dataIn = 8'h10;
        #10 insert = 1;
        #10 insert = 0;

        dataIn = 8'h20;
        #10 insert = 1;
        #10 insert = 0;

        dataIn = 8'h30;
        #10 insert = 1;
        #10 insert = 0;
        
         dataIn = 8'h40;
        #10 insert = 1;
        #10 insert = 0;
        
        
        dataIn = 8'h50;
        #10 insert = 1;
        #10 insert = 0;
        

        // move ptr left
        #10 ptrLeft = 1;
        #10 ptrLeft = 0;
        
        #10 ptrLeft = 1;
        #10 ptrLeft = 0;        

        // insert in middle (should fail)
        dataIn = 8'hFF;
        #10 insert = 1;
        #10 insert = 0;

        // delete 
        #10 del = 1;
        #10 del = 0;
        
        //insert in middle
        dataIn = 8'hAA;
        #10 insert = 1;
        #10 insert = 0;
        
        #10 ptrLeft = 1;
        #10 ptrLeft = 0;   
        
        #10 ptrLeft = 1;
        #10 ptrLeft = 0;   
        
        #10 ptrLeft = 1;
        #10 ptrLeft = 0;   
        
        #10 ptrLeft = 1;
        #10 ptrLeft = 0;   
        
        #10 ptrLeft = 1;
        #10 ptrLeft = 0;    

        #10 ptrRight = 1;
        #10 ptrRight = 0;       
        
        
        //deleting 1st element
        #10 del = 1;
        #10 del = 0;        
        
        //inserting element at pos 0
        dataIn = 8'hAA;
        #10 insert = 1;
        #10 insert = 0;                
                                                    

        #50;
        $finish;
    end

endmodule
