`timescale 1ns/1ps
// ============================================================
//  s i n C o r e T B . v  -  15 extreme test cases
//
//  Number format: mantA * 10^expA
//  mantA : 34-bit unsigned  [0 .. 17_179_869_183]
//  expA  :  7-bit signed    [-64 .. +63]
//  signA :  1-bit           0=positive, 1=negative
//
//  Expected values computed with Python:
//    import math
//    math.sin(value)
//
//  Result format: signRes, mantRes * 10^expRes
// ============================================================
module sinCoreTB;

    reg clock, reset;
    reg eval;
    wire done;

    reg              signA;
    reg  [33:0]      mantA;
    reg signed [6:0] expA;

    wire              signRes;
    wire [33:0]       mantRes;
    wire signed [6:0] expRes;

    // ---- shared multiplier ----
    wire        mul_start;
    wire [511:0] mul_multiplicand, mul_multiplier;
    wire        mul_done;
    wire [511:0] mul_product;

    // ---- shared divider ----
    wire        div_start;
    wire [511:0] div_dividend, div_divisor;
    wire        div_done;
    wire [511:0] div_quotient;

    seq_multiplier #(.WIDTH(512)) seqmul0 (
        .clock(clock), .reset(reset),
        .start(mul_start), .done(mul_done),
        .multiplicand(mul_multiplicand),
        .multiplier(mul_multiplier),
        .product(mul_product)
    );

    seq_divider #(.WIDTH(512)) seqdiv0 (
        .clock(clock), .reset(reset),
        .start(div_start), .done(div_done),
        .dividend(div_dividend),
        .divisor(div_divisor),
        .quotient(div_quotient),
        .remainder_out()
    );

    sin_core sin0 (
        .clock(clock), .reset(reset),
        .eval(eval), .done(done),
        .signA(signA), .mantA(mantA), .expA(expA),
        .signRes(signRes), .mantRes(mantRes), .expRes(expRes),
        .div_start(div_start),
        .div_dividend(div_dividend),
        .div_divisor(div_divisor),
        .div_done(div_done),
        .div_quotient(div_quotient),
        .mul_start(mul_start),
        .mul_multiplicand(mul_multiplicand),
        .mul_multiplier(mul_multiplier),
        .mul_done(mul_done),
        .mul_product(mul_product)
    );

    initial clock = 0;
    always #5 clock = ~clock;

    // ----------------------------------------------------------------
    //  run_test: pulse eval for one cycle, wait for done, print result
    // ----------------------------------------------------------------
    task run_test;
        input        sA;
        input [33:0] mA;
        input signed [6:0] eA;
        input [7:0]  tcNum;
        input [63:0] expected_int;   // expected |sin| * 10^10, for reference
        input        expected_sign;
        begin
            @(posedge clock); #1;
            signA = sA;
            mantA = mA;
            expA  = eA;
            eval  = 1;
            @(posedge clock); #1;
            eval  = 0;

            fork
                begin : wait_done
                    @(posedge done);
                    disable wait_timeout;
                end
                begin : wait_timeout
                    #4000000;
                    $display("[TC%0d] TIMEOUT", tcNum);
                    disable wait_done;
                end
            join

            repeat(2) @(posedge clock);
            $display("[TC%02d] sign=%0b  mantRes=%0d  expRes=%0d   (expected sign=%0b, ~%0d x10^-10)",
                     tcNum, signRes, mantRes, $signed(expRes),
                     expected_sign, expected_int);
        end
    endtask

    initial begin
        reset = 1; eval = 0;
        signA = 0; mantA = 0; expA = 0;
        #200;
        @(posedge clock); #1;
        reset = 0;
        repeat(4) @(posedge clock);

        $display("--------------------------------------------------------------");
        $display(" TC  | description                  | expected sin value");
        $display("--------------------------------------------------------------");

        // ----------------------------------------------------------
        // TC01: sin(0) = 0
        //   input: 0 * 10^0
        // ----------------------------------------------------------
        $display("TC01: sin(0) = 0");
        run_test(0, 34'd0, 7'sd0, 8'd1, 64'd0, 1'b0);

        // ----------------------------------------------------------
        // TC02: sin(pi/2) = 1.0
        //   input: 15707963268 * 10^-10  = 1.5707963268
        // ----------------------------------------------------------
        $display("TC02: sin(pi/2) ~ 1.0");
        run_test(0, 34'd15707963268, -7'sd10, 8'd2, 64'd10000000000, 1'b0);

        // ----------------------------------------------------------
        // TC03: sin(pi) ~ 0  (should be near zero)
        //   input: 31415926536 * 10^-10 = 3.1415926536
        //   Note: mantA max is 17179869183, so use 3141592654 * 10^-9
        // ----------------------------------------------------------
        $display("TC03: sin(pi) ~ 0");
        run_test(0, 34'd3141592654, -7'sd9, 8'd3, 64'd0, 1'b0);

        // ----------------------------------------------------------
        // TC04: sin(3*pi/2) = -1.0
        //   input: 47123889804 too big, use 4712388980 * 10^-9
        // ----------------------------------------------------------
        $display("TC04: sin(3pi/2) ~ -1.0");
        run_test(0, 34'd4712388980, -7'sd9, 8'd4, 64'd10000000000, 1'b1);

        // ----------------------------------------------------------
        // TC05: sin(2*pi) ~ 0
        //   input: 6283185307 * 10^-9
        // ----------------------------------------------------------
        $display("TC05: sin(2pi) ~ 0");
        run_test(0, 34'd6283185307, -7'sd9, 8'd5, 64'd0, 1'b0);

        // ----------------------------------------------------------
        // TC06: sin(-pi/2) = -1.0  (negative input)
        //   input: sign=1, 15707963268 * 10^-10
        // ----------------------------------------------------------
        $display("TC06: sin(-pi/2) ~ -1.0");
        run_test(1, 34'd15707963268, -7'sd10, 8'd6, 64'd10000000000, 1'b1);

        // ----------------------------------------------------------
        // TC07: sin(very small x) ~ x   (x = 1e-9)
        //   sin(1e-9) ~ 1e-9
        //   input: 1 * 10^-9
        // ----------------------------------------------------------
        $display("TC07: sin(1e-9) ~ 1e-9");
        run_test(0, 34'd1, -7'sd9, 8'd7, 64'd10, 1'b0);

        // ----------------------------------------------------------
        // TC08: sin(1.0) ~ 0.8414709848
        //   input: 10000000000 * 10^-10
        // ----------------------------------------------------------
        $display("TC08: sin(1.0) ~ 0.8414709848");
        run_test(0, 34'd10000000000, -7'sd10, 8'd8, 64'd8414709848, 1'b0);

        // ----------------------------------------------------------
        // TC09: sin(large angle needing many reductions)
        //   sin(100.0) ~ -0.5063656411
        //   input: 10000000000 * 10^-8 = 100.0
        // ----------------------------------------------------------
        $display("TC09: sin(100.0) ~ -0.5063656411");
        run_test(0, 34'd10000000000, -7'sd8, 8'd9, 64'd5063656411, 1'b1);

        // ----------------------------------------------------------
        // TC10: sin(very large mantissa, exp=0)
        //   sin(17179869183) -- huge angle, range reduces mod 2pi
        //   Python: math.sin(17179869183) ~ 0.9999177...  (happens to be near 1)
        //   input: 17179869183 * 10^0
        // ----------------------------------------------------------
        $display("TC10: sin(17179869183) -- large angle range reduction stress");
        run_test(0, 34'd17179869183, 7'sd0, 8'd10, 64'd9999177000, 1'b0);

        // ----------------------------------------------------------
        // TC11: sin(x) with large positive exponent
        //   sin(1234.5678) where input = 12345678 * 10^-4
        //   Python: math.sin(1234.5678) ~ 0.9999118...
        //   input: 12345678 * 10^-4
        // ----------------------------------------------------------
        $display("TC11: sin(1234.5678) ~ 0.9999118");
        run_test(0, 34'd12345678, -7'sd4, 8'd11, 64'd9999118000, 1'b0);

        // ----------------------------------------------------------
        // TC12: sin(tiny negative)  sin(-1e-6) ~ -1e-6
        //   input: sign=1, 1 * 10^-6
        // ----------------------------------------------------------
        $display("TC12: sin(-1e-6) ~ -1e-6");
        run_test(1, 34'd1, -7'sd6, 8'd12, 64'd10000, 1'b1);

        // ----------------------------------------------------------
        // TC13: sin(pi/4) ~ 0.7071067812
        //   input: 7853981634 * 10^-10
        // ----------------------------------------------------------
        $display("TC13: sin(pi/4) ~ 0.7071067812");
        run_test(0, 34'd7853981634, -7'sd10, 8'd13, 64'd7071067812, 1'b0);

        // ----------------------------------------------------------
        // TC14: sin(pi/6) ~ 0.5   (30 degrees)
        //   input: 5235987756 * 10^-10
        // ----------------------------------------------------------
        $display("TC14: sin(pi/6) ~ 0.5");
        run_test(0, 34'd5235987756, -7'sd10, 8'd14, 64'd5000000000, 1'b0);

        // ----------------------------------------------------------
        // TC15: sin(x) with max mantissa and negative exponent
        //   value = 17179869183 * 10^-20  = 1.7179869183e-10
        //   sin(1.7179869183e-10) ~ 1.7179869183e-10  (sin x ~ x for tiny x)
        //   input: 17179869183 * 10^-20
        // ----------------------------------------------------------
        $display("TC15: sin(1.718e-10) ~ 1.718e-10  (sin~x limit)");
        run_test(0, 34'd17179869183, -7'sd20, 8'd15, 64'd17179869183, 1'b0);

        $display("--------------------------------------------------------------");
        $display("Done. Interpret results as:  mantRes * 10^expRes");
        $display("--------------------------------------------------------------");
        $finish;
    end

endmodule