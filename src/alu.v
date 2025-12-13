module alu(
    output [7:0] result,
    input [7:0] a,
    input [7:0] b,
    input [2:0] op // 0 - addition, 1 - subtraction, 2 - passthrough
);

    wire [7:0] sum;
    wire [7:0] difference;

    ripple_adder_8bit adder(
        .sum(sum),
        .carry_out(),
        .a(a),
        .b(b),
        .carry_in(1'b0)
    );

    sub_8bit subber(
        .difference(difference),
        .carry_out(),
        .a(a),
        .b(b)
    );

    mux_8way m(
        .out(result), 
        .a(sum), 
        .b(difference),
        .c(b),
        .d(8'd0),
        .e(8'd0),
        .f(8'd0),
        .g(8'd0),
        .h(8'd0),
        .slct(op)
    );
endmodule



module alu_tb;
  reg signed [7:0] a, b;
  reg op;
  wire signed [7:0] result;

  alu dut(result, a, b, op);

  initial begin    
    $display("\n=== ALU ===");
    a = 8'd0;   b = 8'd0;   op = 1'b0;
    #10 a = 8'd1;   b = 8'd2;   op = 1'b0;
    #10 op = 1'b1;
    #10 a = 8'd15;  b = 8'd8;   op = 1'b0;
    #10 op = 1'b1;
    #10 a = 8'd255; b = 8'd1;   op = 1'b0;
    #10 op = 1'b1;
    #10 a = 8'd170; b = 8'd85;  op = 1'b0;
    #10 op = 1'b1;
    #10 a = 8'd100; b = 8'd100; op = 1'b0;
    #10 op = 1'b1;
    #10 a = 8'd0;   b = 8'd255; op = 1'b0;
    #10 op = 1'b1;
    #10 a = 8'd120; b = 8'd11;  op = 1'b0;
    #10 op = 1'b1;
    #10 a = 8'd7;   b = 8'd128; op = 1'b0;
    #10 op = 1'b1;
    #10 a = 8'd42;  b = 8'd101; op = 1'b0;
    #10 op = 1'b1;
    #10 a = 8'd0;   b = 8'd0;   op = 1'b0;
    #10 op = 1'b1;
    #10 $finish;
  end
  always @(a or b or op) begin
    $strobe("t=%0d | ALU: a=%d b=%d op=%d | result=%d", 
            $time, a, b, op, result);
  end
endmodule