`timescale 1ns/1ps

module simple_expr_tb;

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

  // DUT (OLD parent interface)
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

  // clock
  initial clock = 1'b0;
  always #5 clock = ~clock;

  // ---------- helpers ----------
  task automatic clear_inputs;
    begin
      b = '0;
      del = 1'b0;
      ptrLeft = 1'b0;
      ptrRight = 1'b0;
      eval = 1'b0;
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

  task automatic eval_wait_done;
    begin
      press_eval();
      wait (done3 == 1'b1);   // wait until done goes high [web:271]
      @(posedge clock);
      wait (done3 == 1'b0);   // wait for pulse to drop (clean sequencing)
      @(posedge clock);
      $display("[%0t] DONE. answer=%h", $time, answer);
    end
  endtask

  // ---------- shortcuts for keys (keyboard indices) ----------
  // digits: 0..9 => b[0]..b[9]
  task automatic press_digit(input int d);
    begin
      press_b_button(d);
    end
  endtask

  // constants
  task automatic press_e;  begin press_b_button(18); end endtask
  task automatic press_pi; begin press_b_button(19); end endtask

  // operators / symbols
  task automatic press_plus;   begin press_b_button(10); end endtask
  task automatic press_div;    begin press_b_button(13); end endtask
  task automatic press_dot;    begin press_b_button(16); end endtask

  // ---------- stimulus ----------
  initial begin
    clear_inputs();
    reset = 1'b0;

    do_reset();

    // ==========================
    // 1) e + pi
    // ==========================
    press_e();
    press_plus();
    press_pi();
    eval_wait_done();
    do_reset();

    // ==========================
    // 2) 1.1 + 2.2
    // ==========================
    press_digit(1);
    press_dot();
    press_digit(1);
    press_plus();
    press_digit(2);
    press_dot();
    press_digit(2);
    eval_wait_done();
    do_reset();

    // ==========================
    // 3) 4/8
    // ==========================
    press_digit(4);
    press_div();
    press_digit(8);
    eval_wait_done();
    do_reset();

    $finish;
  end

endmodule
