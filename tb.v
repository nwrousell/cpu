module tb;
  reg a, b;
  wire sum, carry;

  bit_add dut (sum, carry, a, b);

  initial begin
    a = 0; b = 0;
    #10 a = 0; b= 1;
    #10 a = 1; b = 0;
    #10 a = 1; b = 1;
    #10 $finish;
  end

  initial begin
    $monitor("t=%0t  a=%b b=%b sum=%b carry=%b", $time, a, b, sum, carry);
  end
endmodule
