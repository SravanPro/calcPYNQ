`timescale 1ns / 1ps
module expTB2();
    reg clock, reset, eval;
    reg signA;
    reg [33:0] mantA;
    reg signed [6:0] expA;

    wire done, signRes;
    wire [33:0] mantRes;
    wire signed [6:0] expRes;

    exponent uut (
        .clock(clock), .reset(reset), .eval(eval), .done(done),
        .signA(signA), .mantA(mantA), .expA(expA),
        .signRes(signRes), .mantRes(mantRes), .expRes(expRes)
    );

    initial clock = 0;
    always #5 clock = ~clock;

    integer pass_count, fail_count;

    // ----------------------------------------------------------------
    //  run_test
    //  expected_mant / expected_exp: the mantissa and exponent you
    //  expect.  tolerance_pct: acceptable % error (0 = exact check
    //  skipped, just display).  Use 0 for cases where the exact value
    //  is hard to nail down and you only want to see the output.
    // ----------------------------------------------------------------
    task run_test;
        input        i_sign;
        input [33:0] i_mant;
        input signed [6:0] i_exp;
        input [1023:0] test_name;
        input [63:0]   expected_mant;   // 0 = no check
        input signed [31:0] expected_exp;
        input [7:0]    tolerance_pct;   // 0 = display only
    begin : task_body
        real got_val, exp_val, err_pct;

        // 1. Reset
        reset = 1; eval = 0;
        #21; reset = 0; #21;

        // 2. Inputs
        signA = i_sign;
        mantA = i_mant;
        expA  = i_exp;
        #11;

        // 3. Trigger
        eval = 1; #11; eval = 0;

        // 4. Wait for done
        wait(done);
        #11;

        // 5. Display raw output
        $display("=== %s ===", test_name);
        $display("  Input  : %s%0d * 10^(%0d)",
                 i_sign ? "-" : "+", i_mant, $signed(i_exp));
        $display("  Result : %0d * 10^(%0d)  sign=%b",
                 mantRes, $signed(expRes), signRes);

        // 6. Optional numeric check
        if (expected_mant != 0 && tolerance_pct != 0) begin
            got_val = $itor(mantRes);
            exp_val = $itor(expected_mant);
            if (exp_val != 0.0)
                err_pct = ((got_val - exp_val) / exp_val) * 100.0;
            else
                err_pct = 0.0;
            if (err_pct < 0.0) err_pct = -err_pct;

            if ($signed(expRes) == expected_exp &&
                err_pct <= $itor(tolerance_pct)) begin
                $display("  CHECK  : PASS  (err=%.2f%%)", err_pct);
                pass_count = pass_count + 1;
            end else begin
                $display("  CHECK  : FAIL  (expected %0d*10^%0d, err=%.2f%%)",
                         expected_mant, expected_exp, err_pct);
                fail_count = fail_count + 1;
            end
        end else begin
            $display("  CHECK  : display-only");
        end
        $display("");
    end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;
        #105;

        // ============================================================
        //  GROUP A - Zero and near-zero inputs
        //  e^0 = 1  (the fundamental identity)
        // ============================================================

        // A1: e^0  exact zero mantissa
        run_test(0, 34'd0, 7'sd0,
                 "A1: e^0 exact zero mantissa",
                 64'd10000000000, -10, 2);

        // A2: e^0  via mantissa=1, expA=-63 (extremely tiny ~1e-63, rounds to e^0=1)
        run_test(0, 34'd1, -7'sd63,
                 "A2: e^(1e-63) rounds to 1",
                 64'd10000000000, -10, 2);

        // A3: e^-0  negative sign but zero mantissa (sign irrelevant, still e^0=1)
        run_test(1, 34'd0, 7'sd0,
                 "A3: e^(-0) negative sign zero",
                 64'd10000000000, -10, 2);

        // A4: near-zero positive: e^(0.000001) ≈ 1.000001
        run_test(0, 34'd1, -7'sd6,
                 "A4: e^(1e-6) ≈ 1.000001",
                 64'd10000010, -7, 2);

        // A5: near-zero negative: e^(-0.000001) ≈ 0.999999
        run_test(1, 34'd1, -7'sd6,
                 "A5: e^(-1e-6) ≈ 0.999999",
                 64'd9999990, -7, 2);

        // ============================================================
        //  GROUP B - Small positive integers
        // ============================================================

        // B1: e^1 ≈ 2.718281828
        run_test(0, 34'd1, 7'sd0,
                 "B1: e^1 ≈ 2.718",
                 64'd27182818, -7, 2);

        // B2: e^2 ≈ 7.389056099
        run_test(0, 34'd2, 7'sd0,
                 "B2: e^2 ≈ 7.389",
                 64'd73890561, -8, 2);

        // B3: e^10 ≈ 22026.4658
        run_test(0, 34'd10, 7'sd0,
                 "B3: e^10 ≈ 22026",
                 64'd22026466, -3, 2);

        // B4: e^20 ≈ 4.854e8
        run_test(0, 34'd20, 7'sd0,
                 "B4: e^20 ≈ 4.854e8",
                 64'd48516520, -1, 2);

        // B5: e^50 ≈ 5.1847e21
        run_test(0, 34'd50, 7'sd0,
                 "B5: e^50 ≈ 5.185e21",
                 64'd51847055, -29, 3);  // mantRes ≈ 5.18e7, expRes = -29+21 handled by normalise

        // ============================================================
        //  GROUP C - Large positive (stress the 2^k shift path)
        // ============================================================

        // C1: e^100 ≈ 2.6881e43
        run_test(0, 34'd100, 7'sd0,
                 "C1: e^100 ≈ 2.688e43",
                 64'd26881172, -36, 3);

        // C2: e^100.009754 (original test 1)
        run_test(0, 34'd100009754, -7'sd6,
                 "C2: e^100.009754 ≈ 2.716e43",
                 64'd27160, -39, 3);

        // C3: e^200 ≈ 7.225e86  (k≈288, really stresses the shift loop)
        run_test(0, 34'd200, 7'sd0,
                 "C3: e^200 ≈ 7.225e86  (display only)",
                 64'd0, 0, 0);

        // C4: expA positive scaling: e^(50 * 10^1) = e^500 (display only)
        run_test(0, 34'd50, 7'sd1,
                 "C4: e^500  huge positive (display only)",
                 64'd0, 0, 0);

        // ============================================================
        //  GROUP D - Negative inputs (exercises S_INVERT path)
        // ============================================================

        // D1: e^-1 ≈ 0.36787944
        run_test(1, 34'd1, 7'sd0,
                 "D1: e^-1 ≈ 0.36788",
                 64'd36787944, -8, 2);

        // D2: e^-2 ≈ 0.13533528
        run_test(1, 34'd2, 7'sd0,
                 "D2: e^-2 ≈ 0.13534",
                 64'd13533528, -8, 2);

        // D3: e^-10 ≈ 4.53999e-5
        run_test(1, 34'd10, 7'sd0,
                 "D3: e^-10 ≈ 4.540e-5",
                 64'd45399929, -12, 2);

        // D4: e^-15 (original test 4)
        run_test(1, 34'd15, 7'sd0,
                 "D4: e^-15 ≈ 3.059e-7",
                 64'd30590232, -14, 2);

        // D5: e^-100 ≈ 3.720e-44
        run_test(1, 34'd100, 7'sd0,
                 "D5: e^-100 ≈ 3.720e-44",
                 64'd37200760, -51, 3);

        // D6: e^-0.0000012309 (original test 2)
        run_test(1, 34'd12309, -7'sd10,
                 "D6: e^-1.2309e-6 ≈ 0.9999988",
                 64'd99999877, -8, 2);

        // ============================================================
        //  GROUP E - Fractional / non-integer exponents
        // ============================================================

        // E1: e^0.5 ≈ 1.6487213
        run_test(0, 34'd5, -7'sd1,
                 "E1: e^0.5 ≈ 1.6487",
                 64'd16487213, -7, 2);

        // E2: e^0.693147 ≈ 2.0 (ln2)
        run_test(0, 34'd693147, -7'sd6,
                 "E2: e^ln2 ≈ 2.000",
                 64'd20000000, -7, 2);

        // E3: e^1.5 ≈ 4.4816890
        run_test(0, 34'd15, -7'sd1,
                 "E3: e^1.5 ≈ 4.482",
                 64'd44816890, -8, 2);

        // E4: e^12.34567 (original test 5)
        run_test(0, 34'd1234567, -7'sd5,
                 "E4: e^12.34567 ≈ 229961",
                 64'd22996149, -2, 3);

        // E5: e^-0.5 ≈ 0.60653066
        run_test(1, 34'd5, -7'sd1,
                 "E5: e^-0.5 ≈ 0.60653",
                 64'd60653066, -8, 2);

        // ============================================================
        //  GROUP F - expA boundary values
        //  (exercises the S_CONVERT multiply/divide loop)
        // ============================================================

        // F1: mantA=1, expA=+6  → x = 1,000,000  → e^1000000 (display only)
        run_test(0, 34'd1, 7'sd6,
                 "F1: e^1000000  expA=+6 extreme (display only)",
                 64'd0, 0, 0);

        // F2: mantA=1, expA=-6  → x = 1e-6 → e^(1e-6) ≈ 1.000001
        run_test(0, 34'd1, -7'sd6,
                 "F2: e^(1e-6)  expA=-6",
                 64'd10000010, -7, 2);

        // F3: mantA=1, expA=-20 → x = 1e-20 → e^(1e-20) ≈ 1.0
        run_test(0, 34'd1, -7'sd20,
                 "F3: e^(1e-20) rounds to 1",
                 64'd10000000, -7, 2);

        // F4: mantA=MAX (2^34-1=17179869183), expA=0 → e^17179869183 (display only)
        run_test(0, 34'h3FFFFFFFF, 7'sd0,
                 "F4: e^(2^34-1)  mantA=MAX (display only)",
                 64'd0, 0, 0);

        // F5: mantA=1, expA=-63 (minimum negative expA): x ≈ 0 → e^0 = 1
        run_test(0, 34'd1, -7'sd63,
                 "F5: e^(1e-63)  expA=-63 minimum",
                 64'd10000000, -7, 2);

        // ============================================================
        //  GROUP G - Sign boundary / symmetry checks
        //  e^x * e^-x should equal 1 (verified by display, cross-check manually)
        // ============================================================

        // G1: e^5
        run_test(0, 34'd5, 7'sd0,
                 "G1: e^5 ≈ 148.413",
                 64'd14841316, -5, 2);

        // G2: e^-5 (should be 1/G1 result)
        run_test(1, 34'd5, 7'sd0,
                 "G2: e^-5 ≈ 0.006738",
                 64'd67379470, -11, 2);

        // G3: e^0.1
        run_test(0, 34'd1, -7'sd1,
                 "G3: e^0.1 ≈ 1.10517",
                 64'd11051709, -7, 2);

        // G4: e^-0.1 (should be 1/G3)
        run_test(1, 34'd1, -7'sd1,
                 "G4: e^-0.1 ≈ 0.904837",
                 64'd90483742, -8, 2);

        // ============================================================
        //  DONE
        // ============================================================
        #100;
        $display("================================================");
        $display("  RESULTS: %0d passed,  %0d failed  (display-only cases not counted)",
                 pass_count, fail_count);
        $display("================================================");
        $finish;
    end
endmodule