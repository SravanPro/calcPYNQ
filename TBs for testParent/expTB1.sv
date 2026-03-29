`timescale 1ns / 1ps

module expTB1();

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

    // Instantiate UUT
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

    // Clock: 100MHz
    initial clock = 0;
    always #5 clock = ~clock;

    // Helper Task for a single test run
    task run_test(
        input i_sign, 
        input [33:0] i_mant, 
        input signed [6:0] i_exp,
        input [1023:0] test_name
    );
    begin
        // 1. Reset
        reset = 1;
        eval = 0;
        #21;
        reset = 0;
        #21;

        // 2. Set Inputs
        signA = i_sign;
        mantA = i_mant;
        expA  = i_exp;
        #11;
        
        // 3. Trigger
        eval = 1;
        #11;
        eval = 0;

        // 4. Wait
        wait(done);
        #11;

        // 5. Display
        $display("--- Test: %s ---", test_name);
        $display("Input: %s%d * 10^(%0d)", i_sign ? "-" : "", i_mant, i_exp);
        $display("Result: %d * 10^(%0d) (Sign: %b)", mantRes, expRes, signRes);
        $display("--------------------------------\n");
    end
    endtask

    initial begin
        #105;

        // --- CASE 1: e^100.009754 ---
        // Expected: ~2.716 * 10^43
        run_test(0, 34'd100009754, -7'sd6, "Large Positive Power");

        // --- CASE 2: e^-0.0000012309 ---
        // Expected: ~0.999998769
        run_test(1, 34'd12309, -7'sd10, "Tiny Negative Power");

        // --- STRESS CASE 3: e^0 (The Baseline) ---
        // Expected: 1.0 * 10^0
        run_test(0, 34'd0, 0, "Zero Power");

        // --- STRESS CASE 4: e^-15.0 ---
        // Expected: ~3.059 * 10^-7
        run_test(1, 34'd15, 0, "Deep Negative Power");

        // --- STRESS CASE 5: e^12.34567 ---
        // Expected: ~229961.5
        run_test(0, 34'd1234567, -7'sd5, "Mid-range Fractional");

        #100;
        $display("All tests completed.");
        $finish;
    end

endmodule