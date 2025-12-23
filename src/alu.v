`define ALU_PASSTHROUGH 3'd0
`define ALU_ADD 3'd1
`define ALU_SUB 3'd2

module alu(
    output [7:0] result,
    output zero,
    output carry,
    output overflow,
    output sign,
    input [7:0] a,
    input [7:0] b,
    input [2:0] op // 0 - addition, 1 - subtraction, 2 - passthrough
);

    wire [7:0] sum;
    wire [7:0] difference;
    wire add_carry, sub_carry, effective_b_msb;

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

  // flag signals
  assign carry = (op == `ALU_ADD) ? add_carry : sub_carry;
  assign zero = result == 8'd0;
  assign sign = result[7];
  
  assign effective_b_msb = (op == `ALU_SUB) ? !b[7] : b[7];
  assign overflow = !(a[7] ^ effective_b_msb) & (a[7] == !result[7]);

endmodule

`ifndef SYNTHESIS
module alu_tb;
  reg signed [7:0] a, b;
  reg [2:0] op;
  wire signed [7:0] result;
  wire zero, carry, sign, overflow;

  alu dut(
    .result(result),
    .zero(zero),
    .carry(carry),
    .sign(sign),
    .overflow(overflow),
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
    #10 a = 8'd129; b = 8'd200; op = `ALU_ADD; // negative overflow
    #10 $finish;
  end

  always @(a or b or op) begin
    $strobe("t=%0d | a=%d b=%d op=%d | result=%d | zero=%b carry=%b sign=%b overflow=%b", 
            $time, a, b, op, result, zero, carry, sign, overflow);
  end
endmodule
`endif