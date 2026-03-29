`timescale 1ns / 1ps
module tb_decToDec;

    reg        clock, reset, start;
    wire       done;
    reg        sign;
    reg [33:0] mantIn;
    reg signed [6:0] expIn;

    wire              signOut;
    wire [33:0]       mantOut;
    wire signed [6:0] expOut;

    decToDec dut (
        .clock(clock), .reset(reset), .start(start), .done(done),
        .sign(sign), .mantIn(mantIn), .expIn(expIn),
        .signOut(signOut), .mantOut(mantOut), .expOut(expOut)
    );

    initial clock = 0;
    always #5 clock = ~clock;

    integer pass_cnt, fail_cnt, test_idx;

    // -------------------------------------------------------
    //  run_test: drive inputs, wait for done, check roundtrip
    // -------------------------------------------------------
    task run_test;
        input [33:0]      t_mant;
        input signed [6:0] t_exp;
        input              t_sign;
        input [255:0]      label;
        reg [63:0] vi, vo;
        integer    ed, i;
        reg        ok;
        reg [63:0] diff, bigger;
        begin
            mantIn = t_mant; expIn = t_exp; sign = t_sign;

            @(posedge clock); #1; start = 1;
            @(posedge clock); #1; start = 0;

            // wait done with timeout
            begin : wloop
                integer wt;
                wt = 0;
                while (done !== 1 && wt < 200000) begin
                    @(posedge clock); #1;
                    wt = wt + 1;
                end
                if (wt >= 200000) begin
                    $display("TIMEOUT [%0d] %0s", test_idx, label);
                    fail_cnt = fail_cnt + 1;
                    test_idx = test_idx + 1;
                    disable run_test;
                end
            end
            @(posedge clock); #1;

            // --- compare values ---
            ok = 1;
            if (t_mant == 0) begin
                ok = (mantOut == 0);
            end else begin
                vi = {30'd0, t_mant};
                vo = {30'd0, mantOut};
                // ed = expOut - t_exp
                // if ed > 0: output exponent larger -> scale vo up (vo * 10^ed compares to vi)
                // if ed < 0: output exponent smaller -> scale vi up (vi * 10^|ed| compares to vo)
                ed = $signed(expOut) - $signed(t_exp);
                if (ed > 0 && ed <= 15) begin
                    for (i=0; i<ed; i=i+1) vo = vo * 10;
                end else if (ed < 0 && ed >= -15) begin
                    for (i=0; i < -ed; i=i+1) vi = vi * 10;
                end else if (ed != 0)
                    ok = 0;

                if (ok) begin
                    diff   = vi > vo ? vi-vo : vo-vi;
                    bigger = vi > vo ? vi : vo;
                    // allow 0.5% tolerance
                    ok = (diff * 200 <= bigger);
                end
            end
            if (signOut !== t_sign) ok = 0;

            if (ok) begin
                $display("PASS [%0d] %0s  => %0d*10^%0d", test_idx, label, mantOut, expOut);
                pass_cnt = pass_cnt + 1;
            end else begin
                $display("FAIL [%0d] %0s", test_idx, label);
                $display("     IN:  %0d * 10^%0d  sign=%0b", t_mant, t_exp, t_sign);
                $display("     OUT: %0d * 10^%0d  sign=%0b", mantOut, expOut, signOut);
                fail_cnt = fail_cnt + 1;
            end
            test_idx = test_idx + 1;
        end
    endtask

    initial begin
        clock=0; reset=1; start=0; sign=0; mantIn=0; expIn=0;
        pass_cnt=0; fail_cnt=0; test_idx=0;
        repeat(6) @(posedge clock);
        reset = 0;
        repeat(2) @(posedge clock);

        $display("\n========= decToDec Roundtrip Test =========\n");


//        run_test(34'd717193,  7'sd30,  0, "sqrt2");
//        run_test(34'd717193,  7'sd31,  0, "sqrt2");
//        run_test(34'd717193,  7'sd32,  0, "sqrt2");
//        run_test(34'd717193,  7'sd33,  0, "sqrt2");
//        run_test(34'd717193,  7'sd34,  0, "sqrt2");
//        run_test(34'd717193,  7'sd35,  0, "sqrt2");
        

        run_test(34'd717193,  -7'sd10,  0, "sqrt2");
        run_test(34'd717193,  -7'sd11,  0, "sqrt2");
        run_test(34'd717193,  -7'sd12,  0, "sqrt2");
        run_test(34'd717193,  -7'sd13,  0, "sqrt2");
        run_test(34'd717193,  -7'sd14,  0, "sqrt2");
        run_test(34'd717193,  -7'sd15,  0, "sqrt2");
        run_test(34'd717193,  -7'sd16,  0, "sqrt2");
        run_test(34'd717193,  -7'sd17,  0, "sqrt2");
        run_test(34'd717193,  -7'sd18,  0, "sqrt2");
        run_test(34'd717193,  -7'sd19,  0, "sqrt2");
        run_test(34'd717193,  -7'sd20,  0, "sqrt2");
        run_test(34'd717193,  -7'sd21,  0, "sqrt2");
        run_test(34'd717193,  -7'sd22,  0, "sqrt2");
        run_test(34'd717193,  -7'sd23,  0, "sqrt2");
        run_test(34'd717193,  -7'sd24,  0, "sqrt2");
        run_test(34'd717193,  -7'sd25,  0, "sqrt2");
        run_test(34'd717193,  -7'sd26,  0, "sqrt2");
        run_test(34'd717193,  -7'sd27,  0, "sqrt2");
        run_test(34'd717193,  -7'sd28,  0, "sqrt2");
        run_test(34'd717193,  -7'sd29,  0, "sqrt2");
        run_test(34'd717193,  -7'sd30,  0, "sqrt2");
        
        $display("\n========= RESULTS =========");
        $display("PASSED: %0d / %0d", pass_cnt, test_idx);
        $display("FAILED: %0d / %0d", fail_cnt, test_idx);
        $display("===========================\n");
        $finish;
    end

    initial begin
        #100_000_000;
        $display("GLOBAL TIMEOUT"); $finish;
    end

endmodule