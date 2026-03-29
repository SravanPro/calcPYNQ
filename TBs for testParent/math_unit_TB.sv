`timescale 1ns / 1ps
// ============================================================
//  m a t h _ u n i t _ T B . v
//
//  Alternating testbench for math_unit.
//  Each round: run exp first, wait for done, then run log,
//  wait for done, then move to next pair.
//
//  Test values taken directly from expTB2.v and logTB.v.
//  8 exp/log pairs = 16 total operations.
// ============================================================
module math_unit_TB ();

    reg clock, reset;

    // exp inputs / outputs
    reg        exp_eval, exp_signA;
    reg [33:0] exp_mantA;
    reg signed [6:0] exp_expA;
    wire        exp_done, exp_signRes;
    wire [33:0] exp_mantRes;
    wire signed [6:0] exp_expRes;

    // log inputs / outputs
    reg        log_eval, log_signA;
    reg [33:0] log_mantA;
    reg signed [6:0] log_expA;
    wire        log_done, log_signRes;
    wire [33:0] log_mantRes;
    wire signed [6:0] log_expRes;

    math_unit uut (
        .clock      (clock),
        .reset      (reset),
        .exp_eval   (exp_eval),   .exp_signA (exp_signA),
        .exp_mantA  (exp_mantA),  .exp_expA  (exp_expA),
        .exp_done   (exp_done),   .exp_signRes(exp_signRes),
        .exp_mantRes(exp_mantRes),.exp_expRes (exp_expRes),
        .log_eval   (log_eval),   .log_signA (log_signA),
        .log_mantA  (log_mantA),  .log_expA  (log_expA),
        .log_done   (log_done),   .log_signRes(log_signRes),
        .log_mantRes(log_mantRes),.log_expRes (log_expRes)
    );

    initial clock = 0;
    always #5 clock = ~clock;

    integer pass_count, fail_count;

    // ----------------------------------------------------------
    //  Task: run one exp computation and check result
    // ----------------------------------------------------------
    task run_exp;
        input        i_sign;
        input [33:0] i_mant;
        input signed [6:0] i_exp;
        input [255:0]      label;
        input [63:0]       exp_mant;   // 0 = display only
        input signed [31:0] exp_exp;
        input [7:0]        tol_pct;
    begin : exp_task
        real got_v, exp_v, err;
        exp_signA = i_sign;
        exp_mantA = i_mant;
        exp_expA  = i_exp;
        #11;
        exp_eval = 1; #11; exp_eval = 0;
        wait(exp_done); #11;

        $display("--- EXP %s ---", label);
        $display("  in  : %s%0d * 10^(%0d)", i_sign?"-":"+", i_mant, $signed(i_exp));
        $display("  out : %s%0d * 10^(%0d)",
                 exp_signRes?"-":"+", exp_mantRes, $signed(exp_expRes));

        if (exp_mant != 0 && tol_pct != 0) begin
            got_v = $itor(exp_mantRes);
            exp_v = $itor(exp_mant);
            err   = ((got_v - exp_v) / exp_v) * 100.0;
            if (err < 0.0) err = -err;
            if ($signed(exp_expRes) == exp_exp && err <= $itor(tol_pct)) begin
                $display("  CHK : PASS (err=%.2f%%)", err);
                pass_count = pass_count + 1;
            end else begin
                $display("  CHK : FAIL (want %0d*10^%0d, err=%.2f%%)",
                         exp_mant, exp_exp, err);
                fail_count = fail_count + 1;
            end
        end else begin
            $display("  CHK : display-only");
        end
        $display("");
    end
    endtask

    // ----------------------------------------------------------
    //  Task: run one log computation and check result
    // ----------------------------------------------------------
    task run_log;
        input        i_sign;
        input [33:0] i_mant;
        input signed [6:0] i_exp;
        input [255:0]      label;
        input [63:0]       exp_mant;
        input signed [31:0] exp_exp;
        input [7:0]        tol_pct;
    begin : log_task
        real got_v, exp_v, err;
        log_signA = i_sign;
        log_mantA = i_mant;
        log_expA  = i_exp;
        #11;
        log_eval = 1; #11; log_eval = 0;
        wait(log_done); #11;

        $display("--- LOG %s ---", label);
        $display("  in  : %s%0d * 10^(%0d)", i_sign?"-":"+", i_mant, $signed(i_exp));
        $display("  out : %s%0d * 10^(%0d)",
                 log_signRes?"-":"+", log_mantRes, $signed(log_expRes));

        if (exp_mant != 0 && tol_pct != 0) begin
            got_v = $itor(log_mantRes);
            exp_v = $itor(exp_mant);
            err   = ((got_v - exp_v) / exp_v) * 100.0;
            if (err < 0.0) err = -err;
            if ($signed(log_expRes) == exp_exp && err <= $itor(tol_pct)) begin
                $display("  CHK : PASS (err=%.2f%%)", err);
                pass_count = pass_count + 1;
            end else begin
                $display("  CHK : FAIL (want %0d*10^%0d, err=%.2f%%)",
                         exp_mant, exp_exp, err);
                fail_count = fail_count + 1;
            end
        end else begin
            $display("  CHK : display-only");
        end
        $display("");
    end
    endtask

    // ----------------------------------------------------------
    //  Main sequence
    // ----------------------------------------------------------
    initial begin
        pass_count = 0; fail_count = 0;
        exp_eval = 0; exp_signA = 0; exp_mantA = 0; exp_expA = 0;
        log_eval = 0; log_signA = 0; log_mantA = 0; log_expA = 0;
        reset = 1; #51; reset = 0; #51;

        $display("========================================");
        $display("  math_unit alternating exp/log test");
        $display("  exp runs first each pair");
        $display("========================================");
        $display("");

        // ---- PAIR 1 ----------------------------------------
        // exp: e^1 ≈ 2.71828182
        run_exp(0, 34'd1, 7'sd0,
                "e^1",
                64'd27182818, -7, 2);
        // log: ln(e) = 1  (e ≈ 2.71828182 * 10^0 = 271828182 * 10^-8)
        run_log(0, 34'd271828182, -7'sd8,
                "ln(e)=1",
                64'd10000000000, -10, 2);

        // ---- PAIR 2 ----------------------------------------
        // exp: e^2 ≈ 7.38905610
        run_exp(0, 34'd2, 7'sd0,
                "e^2",
                64'd73890561, -8, 2);
        // log: ln(2) ≈ 0.6931471806
        run_log(0, 34'd2, 7'sd0,
                "ln(2)",
                64'd6931471806, -10, 2);

        // ---- PAIR 3 ----------------------------------------
        // exp: e^10 ≈ 22026.466
        run_exp(0, 34'd10, 7'sd0,
                "e^10",
                64'd22026466, -3, 2);
        // log: ln(10) ≈ 2.302585093
        run_log(0, 34'd1, 7'sd1,
                "ln(10)",
                64'd2302585093, -9, 2);

        // ---- PAIR 4 ----------------------------------------
        // exp: e^-1 ≈ 0.36787944
        run_exp(1, 34'd1, 7'sd0,
                "e^-1",
                64'd36787944, -8, 2);
        // log: ln(0.5) = -ln(2) ≈ -0.6931471806
        run_log(0, 34'd5, -7'sd1,
                "ln(0.5)=-ln2",
                64'd6931471806, -10, 2);

        // ---- PAIR 5 ----------------------------------------
        // exp: e^0.5 ≈ 1.6487213
        run_exp(0, 34'd5, -7'sd1,
                "e^0.5",
                64'd16487213, -7, 2);
        // log: ln(100) = 2*ln(10) ≈ 4.60517019
        run_log(0, 34'd1, 7'sd2,
                "ln(100)",
                64'd4605170186, -9, 2);

        // ---- PAIR 6 ----------------------------------------
        // exp: e^-10 ≈ 4.53999e-5
        run_exp(1, 34'd10, 7'sd0,
                "e^-10",
                64'd45399929, -12, 2);
        // log: ln(1e-6) = -6*ln(10) ≈ -13.815510558
        run_log(0, 34'd1, -7'sd6,
                "ln(1e-6)",
                64'd13815510558, -9, 2);

        // ---- PAIR 7 ----------------------------------------
        // exp: e^100 ≈ 2.6881e43
        run_exp(0, 34'd100, 7'sd0,
                "e^100",
                64'd26881172, -36, 3);
        // log: ln(1e6) = 6*ln(10) ≈ 13.815510558
        run_log(0, 34'd1, 7'sd6,
                "ln(1e6)",
                64'd13815510558, -9, 2);

        // ---- PAIR 8 ----------------------------------------
        // exp: e^-100 ≈ 3.720e-44
        run_exp(1, 34'd100, 7'sd0,
                "e^-100",
                64'd37200760, -51, 3);
        // log: ln(1.5) ≈ 0.405465108
        run_log(0, 34'd15, -7'sd1,
                "ln(1.5)",
                64'd4054651081, -10, 2);

        // ---- PAIR 9 (bonus stress) -------------------------
        // exp: e^0.693147 ≈ 2.000 (e^ln2)
        run_exp(0, 34'd693147, -7'sd6,
                "e^ln2 ≈ 2.000",
                64'd20000000, -7, 2);
        // log: ln(0.001) = -3*ln(10) ≈ -6.907755279
        run_log(0, 34'd1, -7'sd3,
                "ln(0.001)",
                64'd6907755279, -9, 2);

        // ---- PAIR 10 (stress: large + asymmetric) ----------
        // exp: e^-0.5 ≈ 0.60653066
        run_exp(1, 34'd5, -7'sd1,
                "e^-0.5",
                64'd60653066, -8, 2);
        // log: ln(100.009754) ≈ 4.605267721
        run_log(0, 34'd100009754, -7'sd6,
                "ln(100.009754)",
                64'd4605267721, -9, 2);

        #200;
        $display("========================================");
        $display("  RESULTS: %0d PASS  %0d FAIL", pass_count, fail_count);
        $display("  (display-only cases not counted)");
        $display("========================================");
        $finish;
    end

endmodule