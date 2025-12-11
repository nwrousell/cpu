// two's complement subtraction is a + ~b + 1
module sub_8bit(
    output [7:0] difference,
    output carry_out,
    input [7:0] a,
    input [7:0] b
);
    ripple_adder_8bit adder(
        .sum(difference),
        .carry_out(carry_out),
        .a(a),
        .b(~b),
        .carry_in(1'b1)
    );
endmodule


module sub_tb;
  reg [7:0] a_8bit, b_8bit;
  wire [7:0] difference;
  wire carry_out_8bit;

  sub_8bit dut_8bit (difference, carry_out_8bit, a_8bit, b_8bit);

  initial begin    
    $display("\n=== Subtraction ===");
    a_8bit = 8'b00000000; b_8bit = 8'b00000000;
    #10 a_8bit = 8'b00000001; b_8bit = 8'b00000001;
    #10 a_8bit = 8'b00000011; b_8bit = 8'b00000011;
    #10 a_8bit = 8'b11111111; b_8bit = 8'b00000001;
    #10 a_8bit = 8'b11111111; b_8bit = 8'b11111111;
    #10 a_8bit = 8'b01010101; b_8bit = 8'b10101010;
    #10 a_8bit = 8'b00000100; b_8bit = 8'b00000010;
    #10 a_8bit = 8'b00000000; b_8bit = 8'b00000001;
    #10 a_8bit = 8'b01100110; b_8bit = 8'b01110111;
    #10 a_8bit = 8'b10000000; b_8bit = 8'b10000000;
    #10 a_8bit = 8'b11110000; b_8bit = 8'b00001111;
    #10 $finish;
  end
  always @(a_8bit or b_8bit) begin
    $strobe("t=%0d | SUB: a=%d b=%d | difference=%d carry=%b", 
            $time, a_8bit, b_8bit, difference, carry_out_8bit);
  end
endmodule