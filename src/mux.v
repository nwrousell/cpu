module mux_2way(
    output [7:0] result,
    input [7:0] a,
    input [7:0] b,
    input select
);
    assign result = (a & ~{8{select}}) | (b & {8{select}});
endmodule;

module mux_8way(
    output [7:0] out,
    input [7:0] a, b, c, d, e, f, g, h,
    input [2:0] slct
);
    wire [2:0] slct_bar;
    assign slct_bar = ~slct;

    wire [7:0] pass_a, pass_b, pass_c, pass_d, pass_e, pass_f, pass_g, pass_h;
    assign pass_a = a & {8{slct_bar[0] & slct_bar[1] & slct_bar[2]}};
    assign pass_b = b & {8{slct[0] & slct_bar[1] & slct_bar[2]}};
    assign pass_c = c & {8{slct_bar[0] & slct[1] & slct_bar[2]}};
    assign pass_d = d & {8{slct[0] & slct[1] & slct_bar[2]}};

    assign pass_e = e & {8{slct_bar[0] & slct_bar[1] & slct[2]}};
    assign pass_f = f & {8{slct[0] & slct_bar[1] & slct[2]}};
    assign pass_g = g & {8{slct_bar[0] & slct[1] & slct[2]}};
    assign pass_h = h & {8{slct[0] & slct[1] & slct[2]}};

    assign out = pass_a | pass_b | pass_c | pass_d | pass_e | pass_f | pass_g | pass_h;
endmodule;

module mux_tb;
    reg [7:0] a, b, c, d, e, f, g, h;
    reg [2:0] slct;
    wire [7:0] result;
    reg [7:0] expected;

    mux_8way dut(result, a, b, c, d, e, f, g, h, slct);

    initial begin
        $display("\n=== 8-way MUX ===");
        a = 8'd10; b = 8'd20; c = 8'd30; d = 8'd40;
        e = 8'd50; f = 8'd60; g = 8'd70; h = 8'd80;

        slct = 3'd0; #10;
        slct = 3'd1; #10;
        slct = 3'd2; #10;
        slct = 3'd3; #10;
        slct = 3'd4; #10;
        slct = 3'd5; #10;
        slct = 3'd6; #10;
        slct = 3'd7; #10;
        $finish;
    end

    always @(slct) begin
        expected = 10 + slct * 10;
        $strobe("t=%0d | slct=%d | result=%d (expected=%d)", 
                $time, slct, result, expected);
    end
endmodule
