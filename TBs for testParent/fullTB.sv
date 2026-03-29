`timescale 1ns/1ps

module fullTB;

  localparam int BUTTONS  = 27;
  localparam int DEPTH    = 60;     // changed to 60
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
    wire done;
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
    .done(done)
  );

  // clock
  initial clock = 1'b0;
  always #5 clock = ~clock;

  // press helpers (press 2 clocks, release 2 clocks)
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

  // stimulus
  initial begin
    b = '0;
    del = 1'b0;
    ptrLeft = 1'b0;
    ptrRight = 1'b0;
    eval = 1'b0;

    reset = 1'b1;
    repeat (4) @(posedge clock);
    reset = 1'b0;
    repeat (2) @(posedge clock);
    // Expression: 0.978437481 - 2.34978437 + 0.00597883

    // 1. Type "0.978437481"
    press_b_button(0);  // 0
    press_b_button(16); // .
    press_b_button(9);  // 9
    press_b_button(7);  // 7
    press_b_button(8);  // 8
    press_b_button(4);  // 4
    press_b_button(3);  // 3
    press_b_button(7);  // 7
    press_b_button(4);  // 4
    press_b_button(8);  // 8
    press_b_button(1);  // 1

    // 2. Type "- 2.34978437"
    press_b_button(11); // -
    
    press_b_button(2);  // 2
    press_b_button(16); // .
    press_b_button(3);  // 3
    press_b_button(4);  // 4
    press_b_button(9);  // 9
    press_b_button(7);  // 7
    press_b_button(8);  // 8
    press_b_button(4);  // 4
    press_b_button(3);  // 3
    press_b_button(7);  // 7

    // 3. Type "+ 0.00597883"
    press_b_button(10); // +

    press_b_button(0);  // 0
    press_b_button(16); // .
    press_b_button(0);  // 0
    press_b_button(0);  // 0
    press_b_button(5);  // 5
    press_b_button(9);  // 9
    press_b_button(7);  // 7
    press_b_button(8);  // 8
    press_b_button(8);  // 8
    press_b_button(3);  // 3

    // Execute
    press_eval();



    #1000;
    $finish;
  end

endmodule
