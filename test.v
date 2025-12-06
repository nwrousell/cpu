module bit_add(output sum, carry, input a, b);
  xor (sum, a, b);
  and (carry, a, b);
endmodule
