`timescale 1ns/1ps
// ============================================================
//  n e w T B _ a l l . v
//
//  Hardware-supported testbench for the full parent calculator.
//  Uses the 5-bit encoded raw input and sniffs uut.answer.
// ============================================================
module newTB_trig;

    localparam int BUTTONS  = 27;
    localparam int DEPTH    = 50;
    localparam int WIDTH    = 8;
    localparam int NEWWIDTH = 44;

    reg clockIn, reset;
    reg [4:0] tc;
    initial tc = 0;

    // 5-bit Active-Low input for the new hardware parent
    reg [4:0] encodedRawInput;

    // Internal wires probed from the UUT
    wire [NEWWIDTH-1:0] answer = uut.answer; 
    wire done3;
    
    // SPI/Hardware ports (Left unconnected in TB as we just need to verify logic)
    wire sclk, mosi, cs;
    wire [3:0] testBits;

    wire        signRes = answer[41];
    wire [33:0] mantRes = answer[40:7];
    wire [6:0]  expRes  = answer[6:0];

    // Instantiate hardware parent
    parent #(
        .buttons(BUTTONS),
        .depth(DEPTH),
        .width(WIDTH),
        .newWidth(NEWWIDTH),
        // Overriding parameters to drastically speed up simulation!
        // Instead of waiting 10ms at 50MHz, we simulate a fast debounce.
        .freq(100_000),       
        .debounceTime(1)      
    ) uut (
        .clockIn(clockIn), 
        .reset(reset),
        .encodedRawInput(encodedRawInput),
        .done(done3),
        .sclk(sclk),
        .mosi(mosi),
        .cs(cs),
        .testBits(testBits)
    );

    initial clockIn = 1'b0;
    always #5 clockIn = ~clockIn;

    // ----------------------------------------------------------
    //  Helper tasks for encoded inputs
    // ----------------------------------------------------------
    
    // Sends the bitwise NOT of the decoder index to the raw input
    task automatic press_raw(input int N);
        begin
            encodedRawInput = ~N[4:0];      // Apply active-low 5-bit encoded input
            repeat(150) @(posedge clockIn); // Hold long enough for fast TB debouncer
            encodedRawInput = 5'b11111;     // Release (N=0 is unassigned)
            repeat(150) @(posedge clockIn); // Wait between presses
        end
    endtask

    // Maps the old direct 'b' index to the new decoded hardware index
    task automatic press_b_button(input int idx);
        int N;
        begin
            case(idx)
                // Straight 1-9
                1,2,3,4,5,6,7,8,9: N = idx;
                
                // Specials & Mapped keys based on parent.v logic
                0:  N = 10;
                19: N = 11;
                18: N = 12;
                16: N = 13;
                10: N = 14;
                11: N = 15;
                17: N = 16;
                12: N = 17;
                13: N = 18;
                14: N = 19;
                15: N = 20;
                23: N = 21;
                
                // Extra functions mapped starting at 24
                22: N = 24;
                24: N = 25;
                25: N = 26;
                26: N = 27;
                
                default: N = 0; // Unmapped fallback
            endcase
            press_raw(N);
        end
    endtask

    task automatic press_eval;
        begin
            press_raw(30); // Evaluator is decodedOutput[30]
        end
    endtask

    task automatic do_reset;
        begin
            reset = 1'b1;
            repeat(10) @(posedge clockIn);
            reset = 1'b0;
            repeat(10) @(posedge clockIn);
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
            repeat(4) @(posedge clockIn);
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
        encodedRawInput = 5'b11111; // Unpressed state (~0)
        reset = 1'b0;

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
        $display("All %0d hardware tests complete.", tc);
        $finish;
    end

endmodule