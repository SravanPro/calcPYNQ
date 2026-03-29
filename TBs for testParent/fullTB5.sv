`timescale 1ns/1ps

module fullTB5;

  localparam int BUTTONS  = 27;
  localparam int DEPTH    = 50;
  localparam int WIDTH    = 8;
  localparam int NEWWIDTH = 44;

  reg clock;
  reg reset;

  reg [BUTTONS-1:0] b;
  reg del;
  reg ptrLeft;
  reg ptrRight;
  reg eval;

  wire [NEWWIDTH-1:0] answer;
  wire done3;

  // Split answer into readable parts
  // answer = {2'b00, sign[41], mantissa[40:7], exp[6:0]}
  wire        signRes = answer[41];
  wire [33:0] mantRes = answer[40:7];
  wire [6:0]  expRes  = answer[6:0];

  // DUT
  parent #(
    .buttons(BUTTONS),
    .depth(DEPTH),
    .width(WIDTH),
    .newWidth(NEWWIDTH)
  ) uut (
    .clock(clock),
    .reset(reset),
    .b(b),
    .del(del),
    .ptrLeft(ptrLeft),
    .ptrRight(ptrRight),
    .eval(eval),
    .answer(answer),
    .done(done3)
  );

  // clock: 10ns period
  initial clock = 1'b0;
  always #5 clock = ~clock;

  // --- helpers ---
  task automatic press_b_button(input int idx);
    begin
      b = '0;
      b[idx] = 1'b1;
      repeat (2) @(posedge clock);
      b = '0;
      repeat (2) @(posedge clock);
    end
  endtask

  task automatic press_eval;
    begin
      eval = 1'b1;
      repeat (2) @(posedge clock);
      eval = 1'b0;
      repeat (2) @(posedge clock);
    end
  endtask

  task automatic do_reset;
    begin
      reset = 1'b1;
      repeat (4) @(posedge clock);
      reset = 1'b0;
      repeat (2) @(posedge clock);
    end
  endtask

  // --- stimulus ---
  initial begin
    b        = '0;
    del      = 1'b0;
    ptrLeft  = 1'b0;
    ptrRight = 1'b0;
    eval     = 1'b0;

    // =========================================================================
    // PHASE 1:  exp( 0.019004 * ln(31.0614) )
    //
    // Expected: e^(0.019004 * ln(31.0614))
    //         = e^(0.019004 * 3.43609...)
    //         = e^(0.065295...)
    //         ≈ 1.06747...
    //
    // Button map:
    //   exp = 20,  ln = 21
    //   (   = 14,  )  = 15
    //   *   = 12,  .  = 16
    // =========================================================================
    do_reset();

    // exp(
    press_b_button(20);  // exp
    press_b_button(14);  // (

      // 0.019004
      press_b_button(0);   // 0
      press_b_button(16);  // .
      press_b_button(0);   // 0
      press_b_button(1);   // 1
      press_b_button(9);   // 9
      press_b_button(0);   // 0
      press_b_button(0);   // 0
      press_b_button(4);   // 4

      // *
      press_b_button(12);  // *

      // ln(31.0614)
      press_b_button(21);  // ln
      press_b_button(14);  // (
        press_b_button(3);   // 3
        press_b_button(1);   // 1
        press_b_button(16);  // .
        press_b_button(0);   // 0
        press_b_button(6);   // 6
        press_b_button(1);   // 1
        press_b_button(4);   // 4
      press_b_button(15);  // )

    // )
    press_b_button(15);  // )

    press_eval();
    @(posedge done3);
    repeat (4) @(posedge clock);

    $display("PHASE 1: exp(0.019004 * ln(31.0614))");
    $display("  Expected: ~1.06747");
    $display("  sign=%0b  mant=%0d  exp=%0d", signRes, mantRes, $signed(expRes));

    // =========================================================================
    // PHASE 2:  ln(73.194) / ln(8.149)
    //
    // This is log base 8.149 of 73.194.
    // Expected: ln(73.194) / ln(8.149)
    //         = 4.29296... / 2.09789...
    //         ≈ 2.04630...
    //
    // Button map:
    //   /  = 13
    // =========================================================================
    do_reset();

    // ln(73.194)
    press_b_button(21);  // ln
    press_b_button(14);  // (
      press_b_button(7);   // 7
      press_b_button(3);   // 3
      press_b_button(16);  // .
      press_b_button(1);   // 1
      press_b_button(9);   // 9
      press_b_button(4);   // 4
    press_b_button(15);  // )

    // /
    press_b_button(13);  // /

    // ln(8.149)
    press_b_button(21);  // ln
    press_b_button(14);  // (
      press_b_button(8);   // 8
      press_b_button(16);  // .
      press_b_button(1);   // 1
      press_b_button(4);   // 4
      press_b_button(9);   // 9
    press_b_button(15);  // )

    press_eval();
    @(posedge done3);
    repeat (4) @(posedge clock);

    $display("PHASE 2: ln(73.194) / ln(8.149)");
    $display("  Expected: ~2.04630");
    $display("  sign=%0b  mant=%0d  exp=%0d", signRes, mantRes, $signed(expRes));

    $finish;
  end

endmodule