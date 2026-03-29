`timescale 1ns / 1ps

module expTB0();

    // Inputs
    reg clock;
    reg reset;
    reg eval;
    reg signA;
    reg [33:0] mantA;
    reg signed [6:0] expA;

    // Outputs
    wire done;
    wire signRes;
    wire [33:0] mantRes;
    wire signed [6:0] expRes;

    // Instantiate the Unit Under Test (UUT)
    exponent uut (
        .clock(clock), 
        .reset(reset), 
        .eval(eval), 
        .done(done), 
        .signA(signA), 
        .mantA(mantA), 
        .expA(expA), 
        .signRes(signRes), 
        .mantRes(mantRes), 
        .expRes(expRes)
    );

    // Clock generation
    initial clock = 0;
    always #5 clock = ~clock; // 100MHz clock

    initial begin
        // Initialize Inputs
        reset = 1;
        eval = 0;
        signA = 0;
        mantA = 0;
        expA = 0;

        // Wait 100 ns for global reset to finish
        #100;
        reset = 0;
        #20;

        // --- Test Case: e^29.4847 ---
        // Input: 294847 * 10^-4
        signA = 1'b1;
        mantA = 34'd64975;
        expA  = -7'sd6;
        
        #10 eval = 1;
        #10 eval = 0;

        // Wait for Done signal
        wait(done);
        
        $display("--- Test Results ---");
        $display("Input: %d * 10^(%0d)", mantA, expA);
        $display("Result Mantissa: %d", mantRes);
        $display("Result Exponent: %0d", expRes);
        $display("Result Sign: %b", signRes);
        
        // Expected Value Calculation:
        // e^29.4847 ≈ 6,369,040,113,446.8
        // In your format, this should look like:
        // Mantissa: 6369040113 (truncated/rounded to fit M_MAX)
        // Exponent: 3 (since 6.36 * 10^12 = 6369040113 * 10^3)

        #100;
        $finish;
    end
      
endmodule
