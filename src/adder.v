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

module adder_tb;
  // 4-bit adder test signals
  reg [3:0] a_4bit, b_4bit;
  reg carry_in_4bit;
  wire [3:0] sum_4bit;
  wire carry_out_4bit;


  // 4-bit ripple adder instance
  ripple_adder_4bit dut_4bit (sum_4bit, carry_out_4bit, a_4bit, b_4bit, carry_in_4bit);

  initial begin    
    $display("\n=== Testing 4-bit Ripple Adder ===");
    a_4bit = 4'b0000; b_4bit = 4'b0000; carry_in_4bit = 0;
    #10 a_4bit = 4'b0001; b_4bit = 4'b0001; carry_in_4bit = 0;
    #10 a_4bit = 4'b0011; b_4bit = 4'b0011; carry_in_4bit = 0;
    #10 a_4bit = 4'b1111; b_4bit = 4'b0001; carry_in_4bit = 0;
    #10 a_4bit = 4'b1111; b_4bit = 4'b1111; carry_in_4bit = 0;
    #10 a_4bit = 4'b0101; b_4bit = 4'b1010; carry_in_4bit = 0;
    #10 a_4bit = 4'b1111; b_4bit = 4'b0001; carry_in_4bit = 1;
    #10 a_4bit = 4'b0000; b_4bit = 4'b0000; carry_in_4bit = 1;
    #10 a_4bit = 4'b0110; b_4bit = 4'b0111; carry_in_4bit = 0;
    #10 $finish;
  end
  initial begin
    $monitor("t=%0d | 4bit: a=%d b=%d ci=%b | sum=%d carry=%b", 
             $time, a_4bit, b_4bit, carry_in_4bit, sum_4bit, carry_out_4bit);
  end
endmodule