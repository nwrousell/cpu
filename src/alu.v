`define ALU_PASSTHROUGH 3'd0
`define ALU_ADD 3'd1
`define ALU_SUB 3'd2

module alu(
    output [7:0] result,
    output zero_out,
    output carry_out,
    input [7:0] a,
    input [7:0] b,
    input [2:0] op // 0 - addition, 1 - subtraction, 2 - passthrough
);

    wire [7:0] sum;
    wire [7:0] difference;
    wire add_carry, sub_carry;

    ripple_adder_8bit adder(
        .sum(sum),
        .carry_out(add_carry),
        .a(a),
        .b(b),
        .carry_in(1'b0)
    );

    sub_8bit subber(
        .difference(difference),
        .carry_out(sub_carry),
        .a(a),
        .b(b)
    );

    mux_8way m(
        .out(result), 
        .a(b), 
        .b(sum),
        .c(difference),
        .d(8'd0),
        .e(8'd0),
        .f(8'd0),
        .g(8'd0),
        .h(8'd0),
        .slct(op)
    );

  assign carry_out = (op == `ALU_ADD) ? add_carry : sub_carry;
  assign zero_out = result == 8'd0;

endmodule



module alu_tb;
  reg signed [7:0] a, b;
  reg [2:0] op;
  wire signed [7:0] result;
  wire zero_out, carry_out;

  alu dut(
    .result(result),
    .zero_out(zero_out),
    .carry_out(carry_out),
    .a(a),
    .b(b),
    .op(op)
  );

  initial begin    
    $display("\n=== ALU ===");
    a = 8'd0;   b = 8'd0;   op = `ALU_ADD;
    #10 a = 8'd1;   b = 8'd2;   op = `ALU_ADD;
    #10 op = `ALU_SUB;
    #10 a = 8'd15;  b = 8'd8;   op = `ALU_ADD;
    #10 op = `ALU_SUB;
    #10 a = 8'd255; b = 8'd1;   op = `ALU_ADD;  // overflow case
    #10 op = `ALU_SUB;
    #10 a = 8'd170; b = 8'd85;  op = `ALU_ADD;
    #10 op = `ALU_SUB;
    #10 a = 8'd100; b = 8'd100; op = `ALU_ADD;
    #10 op = `ALU_SUB;  // zero case
    #10 a = 8'd0;   b = 8'd255; op = `ALU_ADD;
    #10 op = `ALU_SUB;
    #10 a = 8'd120; b = 8'd11;  op = `ALU_ADD;
    #10 op = `ALU_SUB;
    #10 a = 8'd7;   b = 8'd128; op = `ALU_ADD;
    #10 op = `ALU_SUB;
    #10 a = 8'd42;  b = 8'd101; op = `ALU_ADD;
    #10 op = `ALU_SUB;
    #10 a = 8'd0;   b = 8'd0;   op = `ALU_ADD;  // zero case
    #10 op = `ALU_SUB;
    #10 $finish;
  end

  always @(a or b or op) begin
    $strobe("t=%0d | a=%d b=%d op=%d | result=%d | zero=%b carry=%b", 
            $time, a, b, op, result, zero_out, carry_out);
  end
endmodule