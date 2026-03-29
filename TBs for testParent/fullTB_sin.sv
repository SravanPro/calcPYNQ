`timescale 1ns/1ps
// ============================================================
//  f u l l T B _ a l l . v
//
//  Combined testbench for the full parent calculator design.
//  Every test resets between runs.
//
//  Tests included:
//  --- SIN ---
//  TC01  sin(pi)              ~ 0
//  TC02  sin(pi/2)            ~ 1
//  TC03  sin(pi/4)            ~ 0.70711
//  TC04  sin(2*pi)            ~ 0
//  TC05  sin(e)               ~ 0.41078
//  TC06  sin(e/2)             ~ 0.97803
//  TC07  sin(0.001)           ~ 0.001000
//  TC08  sin(1.5)             ~ 0.99749
//  TC09  sin(10.5)            ~ -0.87969
//  TC10  sin(2.5*pi)          ~ 1
//  TC11  sin(e*pi)            ~ 0.07960
//  TC12  sin(e+pi)            ~ -0.41078
//  --- TRIG COMBO ---
//  TC13  sin(5pi/4)-cos(3pi/4)+tan(7pi/9)  ~ -0.83910
//  --- PYTHAGOREAN IDENTITY ---
//  TC14  pow(1-pow(sin(pi/6),2), 0.5)      ~ 0.86603  (= cos(pi/6))
//  TC15  cos(pi/6)                          ~ 0.86603
//  --- ALL-CORES IDENTITY ---
//  TC16  pow(tan(pi/4), ln(pow(sin(pi/6)+cos(pi/3),2)))  ~ 1.0
//  --- POW + LOG ---
//  TC17  pow(e+1/0.97, 20.9-log(2.064,1.039))  ~ 13.321
//  TC18  pow(e+1/0.97,  2.9-log(2.064,3.039))  ~ 19.510
// ============================================================
module fullTB8_trig;

    localparam int BUTTONS  = 27;
    localparam int DEPTH    = 50;
    localparam int WIDTH    = 8;
    localparam int NEWWIDTH = 44;

    reg clock, reset;
    reg [4:0] tc;
    initial tc = 0;

    reg [BUTTONS-1:0] b;
    reg del, ptrLeft, ptrRight, eval;

    wire [NEWWIDTH-1:0] answer;
    wire done3;

    wire        signRes = answer[41];
    wire [33:0] mantRes = answer[40:7];
    wire [6:0]  expRes  = answer[6:0];

    parent #(
        .buttons(BUTTONS),
        .depth(DEPTH),
        .width(WIDTH),
        .newWidth(NEWWIDTH)
    ) uut (
        .clock(clock), .reset(reset),
        .b(b), .del(del),
        .ptrLeft(ptrLeft), .ptrRight(ptrRight),
        .eval(eval),
        .answer(answer), .done(done3)
    );

    initial clock = 1'b0;
    always #5 clock = ~clock;

    // ----------------------------------------------------------
    //  Shared tasks
    // ----------------------------------------------------------
    task automatic press_b_button(input int idx);
        begin
            b = '0; b[idx] = 1'b1;
            repeat(2) @(posedge clock);
            b = '0;
            repeat(2) @(posedge clock);
        end
    endtask

    task automatic press_eval;
        begin
            eval = 1'b1;
            repeat(2) @(posedge clock);
            eval = 1'b0;
            repeat(2) @(posedge clock);
        end
    endtask

    task automatic do_reset;
        begin
            reset = 1'b1;
            repeat(4) @(posedge clock);
            reset = 1'b0;
            repeat(2) @(posedge clock);
        end
    endtask

    task automatic wait_result(input int timeout_ms);
        begin
            fork
                begin : w_done
                    @(posedge done3);
                    disable w_timeout;
                end
                begin : w_timeout
                    #(timeout_ms * 1000000);
                    $display("[TC%02d] TIMEOUT after %0dms", tc, timeout_ms);
                    disable w_done;
                end
            join
            repeat(4) @(posedge clock);
        end
    endtask

    task automatic show(input string expr, input string expected);
        begin
            $display("[TC%02d] %-46s expected=%-20s got: sign=%0b mant=%0d exp=%0d",
                     tc, expr, expected, signRes, mantRes, $signed(expRes));
        end
    endtask

    // ----------------------------------------------------------
    //  Main test sequence
    // ----------------------------------------------------------
    initial begin
        b        = '0;
        del      = 1'b0;
        ptrLeft  = 1'b0;
        ptrRight = 1'b0;
        eval     = 1'b0;

        // ======================================================
        // TC01  sin(pi)  ~ 0
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(24); press_b_button(14); // sin(
          press_b_button(19);                   // pi
        press_b_button(15);                     // )
        press_eval(); wait_result(20);
        show("sin(pi)", "~0");

        // ======================================================
        // TC02  sin(pi/2)  ~ 1
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(24); press_b_button(14); // sin(
          press_b_button(19); press_b_button(13); press_b_button(2); // pi/2
        press_b_button(15);
        press_eval(); wait_result(20);
        show("sin(pi/2)", "~1.0");

        // ======================================================
        // TC03  sin(pi/4)  ~ 0.70711
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(24); press_b_button(14); // sin(
          press_b_button(19); press_b_button(13); press_b_button(4); // pi/4
        press_b_button(15);
        press_eval(); wait_result(20);
        show("sin(pi/4)", "~0.70711");

        // ======================================================
        // TC04  sin(2*pi)  ~ 0
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(24); press_b_button(14); // sin(
          press_b_button(2); press_b_button(12); press_b_button(19); // 2*pi
        press_b_button(15);
        press_eval(); wait_result(20);
        show("sin(2*pi)", "~0");

        // ======================================================
        // TC05  sin(e)  ~ 0.41078
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(24); press_b_button(14); // sin(
          press_b_button(18);                   // e
        press_b_button(15);
        press_eval(); wait_result(20);
        show("sin(e)", "~0.41078");

        // ======================================================
        // TC06  sin(e/2)  ~ 0.97803
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(24); press_b_button(14); // sin(
          press_b_button(18); press_b_button(13); press_b_button(2); // e/2
        press_b_button(15);
        press_eval(); wait_result(20);
        show("sin(e/2)", "~0.97803");

        // ======================================================
        // TC07  sin(0.001)  ~ 0.001000
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(24); press_b_button(14); // sin(
          press_b_button(0); press_b_button(16); // 0.
          press_b_button(0); press_b_button(0); press_b_button(1); // 001
        press_b_button(15);
        press_eval(); wait_result(20);
        show("sin(0.001)", "~0.001000");

        // ======================================================
        // TC08  sin(1.5)  ~ 0.99749
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(24); press_b_button(14); // sin(
          press_b_button(1); press_b_button(16); press_b_button(5); // 1.5
        press_b_button(15);
        press_eval(); wait_result(20);
        show("sin(1.5)", "~0.99749");

        // ======================================================
        // TC09  sin(10.5)  ~ -0.87969
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(24); press_b_button(14); // sin(
          press_b_button(1); press_b_button(0); // 10
          press_b_button(16); press_b_button(5); // .5
        press_b_button(15);
        press_eval(); wait_result(20);
        show("sin(10.5)", "~-0.87969");

        // ======================================================
        // TC10  sin(2.5*pi)  ~ 1
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(24); press_b_button(14); // sin(
          press_b_button(2); press_b_button(16); press_b_button(5); // 2.5
          press_b_button(12); press_b_button(19);                   // *pi
        press_b_button(15);
        press_eval(); wait_result(20);
        show("sin(2.5*pi)", "~1.0");

        // ======================================================
        // TC11  sin(e*pi)  ~ 0.07960
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(24); press_b_button(14); // sin(
          press_b_button(18); press_b_button(12); press_b_button(19); // e*pi
        press_b_button(15);
        press_eval(); wait_result(20);
        show("sin(e*pi)", "~0.07960");

        // ======================================================
        // TC12  sin(e+pi)  ~ -0.41078
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(24); press_b_button(14); // sin(
          press_b_button(18); press_b_button(10); press_b_button(19); // e+pi
        press_b_button(15);
        press_eval(); wait_result(20);
        show("sin(e+pi)", "~-0.41078");

        // ======================================================
        // TC13  sin(5*pi/4) - cos(3*pi/4) + tan(7*pi/9)
        //       ~ -0.83910
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(24); press_b_button(14); // sin(
          press_b_button(5); press_b_button(12); // 5*
          press_b_button(19); press_b_button(13); press_b_button(4); // pi/4
        press_b_button(15); // )
        press_b_button(11); // -
        press_b_button(25); press_b_button(14); // cos(
          press_b_button(3); press_b_button(12); // 3*
          press_b_button(19); press_b_button(13); press_b_button(4); // pi/4
        press_b_button(15); // )
        press_b_button(10); // +
        press_b_button(26); press_b_button(14); // tan(
          press_b_button(7); press_b_button(12); // 7*
          press_b_button(19); press_b_button(13); press_b_button(9); // pi/9
        press_b_button(15); // )
        press_eval(); wait_result(40);
        show("sin(5pi/4)-cos(3pi/4)+tan(7pi/9)", "~-0.83910");

        // ======================================================
        // TC14  pow(1 - pow(sin(pi/6), 2), 0.5)
        //       Pythagorean identity phase 1 ~ 0.86603
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(22); press_b_button(14); // pow(
          press_b_button(1);                    // 1
          press_b_button(11);                   // -
          press_b_button(22); press_b_button(14); // pow(
            press_b_button(24); press_b_button(14); // sin(
              press_b_button(19); press_b_button(13); press_b_button(6); // pi/6
            press_b_button(15);                 // )
            press_b_button(17); press_b_button(2); // ,2
          press_b_button(15);                   // )
          press_b_button(17);                   // ,
          press_b_button(0); press_b_button(16); press_b_button(5); // 0.5
        press_b_button(15);                     // )
        press_eval(); wait_result(60);
        show("pow(1-pow(sin(pi/6),2), 0.5)", "~0.86603");

        // ======================================================
        // TC15  cos(pi/6)
        //       Pythagorean identity phase 2 ~ 0.86603
        //       (should match TC14 exactly)
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(25); press_b_button(14); // cos(
          press_b_button(19); press_b_button(13); press_b_button(6); // pi/6
        press_b_button(15);
        press_eval(); wait_result(20);
        show("cos(pi/6)", "~0.86603  [must match TC14]");

        // ======================================================
        // TC16  pow(tan(pi/4), ln(pow(sin(pi/6)+cos(pi/3), 2)))
        //       All-cores identity ~ 1.0
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(22); press_b_button(14); // pow(
          press_b_button(26); press_b_button(14); // tan(
            press_b_button(19); press_b_button(13); press_b_button(4); // pi/4
          press_b_button(15);                   // )
          press_b_button(17);                   // ,
          press_b_button(21); press_b_button(14); // ln(
            press_b_button(22); press_b_button(14); // pow(
              press_b_button(24); press_b_button(14); // sin(
                press_b_button(19); press_b_button(13); press_b_button(6); // pi/6
              press_b_button(15);               // )
              press_b_button(10);               // +
              press_b_button(25); press_b_button(14); // cos(
                press_b_button(19); press_b_button(13); press_b_button(3); // pi/3
              press_b_button(15);               // )
              press_b_button(17); press_b_button(2); // ,2
            press_b_button(15);                 // )  closes inner pow
          press_b_button(15);                   // )  closes ln
        press_b_button(15);                     // )  closes outer pow
        press_eval(); wait_result(80);
        show("pow(tan(pi/4),ln(pow(sin(pi/6)+cos(pi/3),2)))", "~1.0");

        // ======================================================
        // TC17  pow(e + 1/0.97, 20.9 - log(2.064, 1.039))
        //       ~ 13.321
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(22); press_b_button(14); // pow(
          press_b_button(18);                   // e
          press_b_button(10);                   // +
          press_b_button(1); press_b_button(13); // 1/
          press_b_button(0); press_b_button(16); // 0.
          press_b_button(9); press_b_button(7); // 97
          press_b_button(17);                   // ,
          press_b_button(2); press_b_button(0); // 20
          press_b_button(16); press_b_button(9); // .9
          press_b_button(11);                   // -
          press_b_button(23); press_b_button(14); // log(
            press_b_button(2); press_b_button(16); // 2.
            press_b_button(0); press_b_button(6); press_b_button(4); // 064
            press_b_button(17);                 // ,
            press_b_button(1); press_b_button(16); // 1.
            press_b_button(0); press_b_button(3); press_b_button(9); // 039
          press_b_button(15);                   // )  closes log
        press_b_button(15);                     // )  closes pow
        press_eval(); wait_result(80);
        show("pow(e+1/0.97, 20.9-log(2.064,1.039))", "~13.321");

        // ======================================================
        // TC18  pow(e + 1/0.97, 2.9 - log(2.064, 3.039))
        //       ~ 19.510
        // ======================================================
        tc = tc + 1; do_reset();
        press_b_button(22); press_b_button(14); // pow(
          press_b_button(18);                   // e
          press_b_button(10);                   // +
          press_b_button(1); press_b_button(13); // 1/
          press_b_button(0); press_b_button(16); // 0.
          press_b_button(9); press_b_button(7); // 97
          press_b_button(17);                   // ,
          press_b_button(2); press_b_button(16); press_b_button(9); // 2.9
          press_b_button(11);                   // -
          press_b_button(23); press_b_button(14); // log(
            press_b_button(2); press_b_button(16); // 2.
            press_b_button(0); press_b_button(6); press_b_button(4); // 064
            press_b_button(17);                 // ,
            press_b_button(3); press_b_button(16); // 3.
            press_b_button(0); press_b_button(3); press_b_button(9); // 039
          press_b_button(15);                   // )  closes log
        press_b_button(15);                     // )  closes pow
        press_eval(); wait_result(80);
        show("pow(e+1/0.97, 2.9-log(2.064,3.039))", "~19.510");

        $display("----------------------------------------------------------");
        $display("All %0d tests complete.", tc);
        $finish;
    end

endmodule