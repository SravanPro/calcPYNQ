`timescale 1ns / 1ps
module lnTB2();

    reg clock, reset, eval;
    reg signA;
    reg [33:0] mantA;
    reg signed [6:0] expA;

    wire done, signRes;
    wire [33:0] mantRes;
    wire signed [6:0] expRes;

    logarithm uut (
        .clock(clock), .reset(reset), .eval(eval), .done(done),
        .signA(signA), .mantA(mantA), .expA(expA),
        .signRes(signRes), .mantRes(mantRes), .expRes(expRes)
    );

    initial clock = 0;
    always #5 clock = ~clock;

    integer pass_count, fail_count;

    task run_test;
        input        i_sign;
        input [33:0] i_mant;
        input signed [6:0] i_exp;
        input [1023:0] test_name;
        input [63:0]   expected_mant;
        input signed [31:0] expected_exp;
        input [7:0]    tolerance_pct;
    begin : tb
        real got_val, exp_val, err_pct;

        reset = 1; eval = 0; #21;
        reset = 0; #21;
        signA = i_sign; mantA = i_mant; expA = i_exp;
        #11;
        eval = 1; #11; eval = 0;
        wait(done);
        #11;

        $display("=== %s ===", test_name);
        $display("  Input  : %s%0d * 10^(%0d)",
                 i_sign ? "-" : "+", i_mant, $signed(i_exp));
        $display("  Result : %s%0d * 10^(%0d)",
                 signRes ? "-" : "+", mantRes, $signed(expRes));

        if (expected_mant != 0 && tolerance_pct != 0) begin
            got_val = $itor(mantRes);
            exp_val = $itor(expected_mant);
            err_pct = (exp_val != 0.0) ?
                      ((got_val - exp_val) / exp_val) * 100.0 : 0.0;
            if (err_pct < 0.0) err_pct = -err_pct;

            if ($signed(expRes) == expected_exp && err_pct <= $itor(tolerance_pct)) begin
                $display("  CHECK  : PASS  (err=%.2f%%)", err_pct);
                pass_count = pass_count + 1;
            end else begin
                $display("  CHECK  : FAIL  (expected %s%0d*10^%0d, err=%.2f%%)",
                         "", expected_mant, expected_exp, err_pct);
                fail_count = fail_count + 1;
            end
        end else begin
            $display("  CHECK  : display-only");
        end
        $display("");
    end
    endtask

    initial begin
        pass_count = 0; fail_count = 0;
        #105;

        // ---- Fundamental identities ----
        // ln(1) = 0
        run_test(0, 34'd1, 0, "ln(1) = 0", 0, 0, 0);

        // ln(e) = 1  (e ≈ 2.718281828 * 10^0 = 271828182 * 10^-8)
        run_test(0, 34'd271828182, -7'sd8, "ln(e) = 1",
                 34'd10000000000, -10, 2);

        // ln(2) ≈ 0.6931471806  → 6931471806 * 10^-10
        run_test(0, 34'd2, 0, "ln(2) ≈ 0.693",
                 34'd6931471806, -10, 2);

        // ln(10) ≈ 2.302585093  → 2302585093 * 10^-9
        run_test(0, 34'd1, 7'sd1, "ln(10) ≈ 2.303",
                 34'd2302585093, -9, 2);

        // ---- Negative results (0 < x < 1) ----
        // ln(0.5) = -ln(2) ≈ -0.6931471806
        run_test(0, 34'd5, -7'sd1, "ln(0.5) = -ln2",
                 34'd6931471806, -10, 2);

        // ln(0.1) = -ln(10) ≈ -2.302585093
        run_test(0, 34'd1, -7'sd1, "ln(0.1) = -ln10",
                 34'd2302585093, -9, 2);

        // ln(1e-6) = -6*ln(10) ≈ -13.81551056
        run_test(0, 34'd1, -7'sd6, "ln(1e-6) = -6*ln10",
                 34'd13815510558, -9, 2);

        // ---- Larger values ----
        // ln(100) = 2*ln(10) ≈ 4.605170186
        run_test(0, 34'd1, 7'sd2, "ln(100) = 2*ln10",
                 34'd4605170186, -9, 2);

        // ln(1000000) = 6*ln(10) ≈ 13.81551056
        run_test(0, 34'd1, 7'sd6, "ln(1e6) = 6*ln10",
                 34'd13815510558, -9, 2);

        // ln(100.009754) ≈ 4.60527
        run_test(0, 34'd100009754, -7'sd6, "ln(100.009754)",
                 34'd4605267721, -9, 2);

        // ---- Small fractional values ----
        // ln(1.5) ≈ 0.405465108
        run_test(0, 34'd15, -7'sd1, "ln(1.5) ≈ 0.4055",
                 34'd4054651081, -10, 2);

        // ln(0.001) = -3*ln(10) ≈ -6.907755279
        run_test(0, 34'd1, -7'sd3, "ln(0.001) = -3*ln10",
                 34'd6907755279, -9, 2);

        // ---- Stress: large exponent ----
        // ln(1e30) = 30*ln(10) ≈ 69.07755279  display only
        run_test(0, 34'd1, 7'sd30, "ln(1e30) = 30*ln10  (display)", 0, 0, 0);

        // ln(1e-30) = -30*ln(10) display only
        run_test(0, 34'd1, -7'sd30, "ln(1e-30) = -30*ln10  (display)", 0, 0, 0);

        #100;
        $display("================================================");
        $display("  RESULTS: %0d passed,  %0d failed", pass_count, fail_count);
        $display("================================================");
        $finish;
    end
endmodule


