`timescale 1ns/1ps

module fullTB7;

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

  // {2'b00, sign[41], mantissa[40:7], exp[6:0]}
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

  initial clock = 1'b0;
  always #5 clock = ~clock;

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

  initial begin
    b        = '0;
    del      = 1'b0;
    ptrLeft  = 1'b0;
    ptrRight = 1'b0;
    eval     = 1'b0;

    // =========================================================================
    // PHASE 1:  pow( e + 1/0.97 , 20.9 - log(2.064, 1.039) )
    //           31 tokens - fits in depth 32
    //
    //   1/0.97              ≈ 1.03093
    //   e + 1.03093         ≈ 3.74921   <- base
    //   ln(2.064)/ln(1.039) ≈ 0.72416/0.03825 ≈ 18.9322
    //   20.9 - 18.9322      ≈ 1.9678    <- exponent
    //   3.74921^1.9678      ≈ 13.648
    // =========================================================================
    do_reset();

    // pow( e + 1/0.97 , 20.9 - log(2.064, 1.039) )
    press_b_button(22);  // pow
    press_b_button(14);  // (

      press_b_button(18);  // e
      press_b_button(10);  // +
      press_b_button(1);   // 1
      press_b_button(13);  // /
      press_b_button(0);   // 0
      press_b_button(16);  // .
      press_b_button(9);   // 9
      press_b_button(7);   // 7

      press_b_button(17);  // ,

      press_b_button(2);   // 2
      press_b_button(0);   // 0
      press_b_button(16);  // .
      press_b_button(9);   // 9
      press_b_button(11);  // -
      press_b_button(23);  // log
      press_b_button(14);  // (
        press_b_button(2);   // 2
        press_b_button(16);  // .
        press_b_button(0);   // 0
        press_b_button(6);   // 6
        press_b_button(4);   // 4
        press_b_button(17);  // ,
        press_b_button(1);   // 1
        press_b_button(16);  // .
        press_b_button(0);   // 0
        press_b_button(3);   // 3
        press_b_button(9);   // 9
      press_b_button(15);  // ) closes log
    press_b_button(15);  // ) closes pow

    press_eval();
    @(posedge done3);
    repeat (4) @(posedge clock);

    $display("PHASE 1: pow(e+1/0.97, 20.9-log(2.064,1.039))");
    $display("  Expected: ~13.648");
    $display("  sign=%0b  mant=%0d  exp=%0d", signRes, mantRes, $signed(expRes));

    // =========================================================================
    // PHASE 2:  pow( e + 1/0.97 , 2.9 - log(2.064, 3.039) )
    //           30 tokens - fits in depth 32
    //
    //   e + 1/0.97          ≈ 3.74921   <- same base as phase 1
    //   ln(2.064)/ln(3.039) ≈ 0.72416/1.11154 ≈ 0.65147
    //   2.9 - 0.65147       ≈ 2.24853   <- exponent
    //   3.74921^2.24853     ≈ 17.853
    // =========================================================================
    do_reset();

    // pow( e + 1/0.97 , 2.9 - log(2.064, 3.039) )
    press_b_button(22);  // pow
    press_b_button(14);  // (

      press_b_button(18);  // e
      press_b_button(10);  // +
      press_b_button(1);   // 1
      press_b_button(13);  // /
      press_b_button(0);   // 0
      press_b_button(16);  // .
      press_b_button(9);   // 9
      press_b_button(7);   // 7

      press_b_button(17);  // ,

      press_b_button(2);   // 2
      press_b_button(16);  // .
      press_b_button(9);   // 9
      press_b_button(11);  // -
      press_b_button(23);  // log
      press_b_button(14);  // (
        press_b_button(2);   // 2
        press_b_button(16);  // .
        press_b_button(0);   // 0
        press_b_button(6);   // 6
        press_b_button(4);   // 4
        press_b_button(17);  // ,
        press_b_button(3);   // 3
        press_b_button(16);  // .
        press_b_button(0);   // 0
        press_b_button(3);   // 3
        press_b_button(9);   // 9
      press_b_button(15);  // ) closes log
    press_b_button(15);  // ) closes pow

    press_eval();
    @(posedge done3);
    repeat (4) @(posedge clock);

    $display("PHASE 2: pow(e+1/0.97, 2.9-log(2.064,3.039))");
    $display("  Expected: ~17.853");
    $display("  sign=%0b  mant=%0d  exp=%0d", signRes, mantRes, $signed(expRes));

    $finish;
  end

endmodule