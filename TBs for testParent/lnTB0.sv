`timescale 1ns / 1ps

module lnTB0();

    // Inputs to UUT
    reg clock;
    reg reset;
    reg eval;
    reg signA;
    reg [33:0] mantA;
    reg signed [6:0] expA;

    // Outputs from UUT
    wire done;
    wire signRes;
    wire [33:0] mantRes;
    wire signed [6:0] expRes;

    // Instantiate the Unit Under Test (UUT)
    logarithm uut (
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

    // 100MHz Clock Generation
    initial clock = 0;
    always #5 clock = ~clock;

    // --- Test Task ---
    task run_test(
        input [33:0] i_mant, 
        input signed [6:0] i_exp,
        input [1023:0] test_name
    );
    begin
        $display("Starting Test: %s", test_name);
        // 1. Reset the module
        reset = 1;
        eval = 0;
        #20;
        reset = 0;
        #20;

        // 2. Set Inputs
        mantA = i_mant;
        expA  = i_exp;
        signA = 0; // ln is only defined for x > 0
        
        // 3. Trigger Evaluation
        #10 eval = 1;
        #10 eval = 0;

        // 4. Wait for completion
        wait(done);
        #10;

        // 5. Display Results
        $display("Input x  : %d * 10^(%0d)", i_mant, i_exp);
        $display("Result ln: %s%d * 10^(%0d)", (signRes ? "-" : ""), mantRes, expRes);
        $display("--------------------------------------------------");
    end
    endtask

    initial begin
        // Global Wait
        #100;

        // --- CASE 1: Your Target Value 1 ---
        // x = 100.009754
        // Expected ln(x) ≈ 4.605267
        run_test(34'd100009754, -7'sd6, "Target: 100.009754");

        // --- CASE 2: Your Target Value 2 ---
        // x = 0.0000012309
        // Expected ln(x) ≈ -13.60858
        run_test(34'd12309, -7'sd10, "Target: 0.0000012309");

        // --- CASE 3: Unity (The Precision Test) ---
        // x = 1.0 (mant=1, exp=0)
        // Expected ln(1) = 0
        run_test(34'd1, 7'sd0, "Unity: ln(1.0)");

        // --- CASE 4: Euler's Number (e) ---
        // x ≈ 2.718281828
        // Expected ln(e) ≈ 1.0
        run_test(34'd2718281828, -7'sd9, "Euler: ln(e)");

        // --- CASE 5: High Magnitude Power ---
        // x = 5.0 * 10^30
        // Expected ln(x) ≈ 70.68
        run_test(34'd5, 7'sd30, "Stress: Massive X");

        // --- CASE 6: Extremely Small X ---
        // x = 1.0 * 10^-40
        // Expected ln(x) ≈ -92.10
        run_test(34'd1, -7'sd40, "Stress: Tiny X");

        $display("All tests completed successfully.");
        $finish;
    end

endmodule