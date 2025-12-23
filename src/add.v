module bit_add_half(output sum, carry_out, input a, b);
  xor (sum, a, b);
  and (carry_out, a, b);
endmodule

module bit_add_full(output sum, carry_out, input a, b, carry_in);
  wire a_xor_b, a_and_b, carry_and_one;

  xor(a_xor_b, a, b);
  and(a_and_b, a, b);
  and(carry_and_one, carry_in, a_xor_b);

  xor(sum, a_xor_b,  carry_in);
  or(carry_out, a_and_b, carry_and_one);
endmodule

module ripple_adder_4bit(
  output [3:0] sum,
  output carry_out,
  input [3:0] a,
  input [3:0] b,
  input carry_in
);

  wire carry1;
  wire carry2;
  wire carry3;

  bit_add_full add1 (
    .sum(sum[0]),
    .carry_out(carry1),
    .a(a[0]),
    .b(b[0]),
    .carry_in(carry_in)
  );

  bit_add_full add2 (
    .sum(sum[1]),
    .carry_out(carry2),
    .a(a[1]),
    .b(b[1]),
    .carry_in(carry1)
  );

  bit_add_full add3 (
    .sum(sum[2]),
    .carry_out(carry3),
    .a(a[2]),
    .b(b[2]),
    .carry_in(carry2)
  );

  bit_add_full add4 (
    .sum(sum[3]),
    .carry_out(carry_out),
    .a(a[3]),
    .b(b[3]),
    .carry_in(carry3)
  );
  
endmodule

module ripple_adder_8bit(
  output [7:0] sum,
  output carry_out,
  input [7:0] a,
  input [7:0] b,
  input carry_in
);
  wire carry;

  ripple_adder_4bit add1(
    .sum(sum[3:0]),
    .carry_out(carry),
    .a(a[3:0]),
    .b(b[3:0]),
    .carry_in(carry_in)
  );

  ripple_adder_4bit add2(
    .sum(sum[7:4]),
    .carry_out(carry_out),
    .a(a[7:4]),
    .b(b[7:4]),
    .carry_in(carry)
  );
endmodule

`ifndef SYNTHESIS
module add_tb;
  reg [7:0] a_8bit, b_8bit;
  reg carry_in_8bit;
  wire [7:0] sum_8bit;
  wire carry_out_8bit;

  ripple_adder_8bit dut_8bit (sum_8bit, carry_out_8bit, a_8bit, b_8bit, carry_in_8bit);

  initial begin    
    $display("\n=== Testing 8-bit Ripple Adder ===");
    a_8bit = 8'b00000000; b_8bit = 8'b00000000; carry_in_8bit = 0;
    #10 a_8bit = 8'b00000001; b_8bit = 8'b00000001; carry_in_8bit = 0;
    #10 a_8bit = 8'b00000011; b_8bit = 8'b00000011; carry_in_8bit = 0;
    #10 a_8bit = 8'b11111111; b_8bit = 8'b00000001; carry_in_8bit = 0;
    #10 a_8bit = 8'b11111111; b_8bit = 8'b11111111; carry_in_8bit = 0;
    #10 a_8bit = 8'b01010101; b_8bit = 8'b10101010; carry_in_8bit = 0;
    #10 a_8bit = 8'b11111111; b_8bit = 8'b00000001; carry_in_8bit = 1;
    #10 a_8bit = 8'b00000000; b_8bit = 8'b00000000; carry_in_8bit = 1;
    #10 a_8bit = 8'b01100110; b_8bit = 8'b01110111; carry_in_8bit = 0;
    #10 a_8bit = 8'b10000000; b_8bit = 8'b10000000; carry_in_8bit = 0;
    #10 a_8bit = 8'b11110000; b_8bit = 8'b00001111; carry_in_8bit = 0;
    #10 $finish;
  end
  always @(a_8bit or b_8bit or carry_in_8bit) begin
    $strobe("t=%0d | ADD: a=%d b=%d ci=%b | sum=%d carry=%b", 
            $time, a_8bit, b_8bit, carry_in_8bit, sum_8bit, carry_out_8bit);
  end
endmodule
`endif