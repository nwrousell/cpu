// instruction state machine
`define FETCH0 2'd0
`define FETCH1 2'd1
`define INSTR0 2'd2
`define INSTR1 2'd3

// bus select
`define A_OUT 3'd0
`define B_OUT 3'd1
`define UNUSED2 3'd2
`define MEM_OUT 3'd3
`define INSTR_OUT 3'd4
`define ADDR_OUT 3'd5
`define PC_OUT 3'd6
`define UNUSED1 3'd7

// ALU ops
`define ALU_ADD 3'd0
`define ALU_SUB 3'd1
`define ALU_PASSTHROUGH 3'd2

// instructions
`define INSTR_LDA 8'd0
`define INSTR_LDB 8'd1
`define INSTR_ADD_IMD 8'd2
`define INSTR_ADD_B 8'd3
`define INSTR_SUB_IMD 8'd4
`define INSTR_SUB_B 8'd5

module cpu(
    input wire clk
);
    // registers
    reg signed [7:0] a, b;
    reg [7:0] pc, instr, addr;

    // wires
    wire [7:0] bus, alu_out, mem_data;

    // control state
    reg [1:0] instr_state; // intra-instruction step counter

    // control signals
    reg [2:0] bus_slct;
    reg [2:0] alu_op;
    reg ld_a, ld_b, ld_addr, ld_instr, incr_pc, reset_instr_state;

    // components
    alu alu_inst(
        .result(alu_out),
        .a(a),
        .b(bus),
        .op(alu_op)
    );

    memory_mock mem_inst(
        .addr(addr),
        .data_out(mem_data)
    );

    // controls writing to bus
    mux_8way bus_mux(
        .out(bus),
        .a(a),
        .b(b),
        .c(8'd0),
        .d(mem_data),
        .e(instr),
        .f(addr),
        .g(pc),
        .h(8'd0),
        .slct(bus_slct)
    );

    initial begin
        a = 8'd0;
        b = 8'd0;
        pc = 8'd1;
        addr = 8'd0;
        instr = 8'd0;
        instr_state = `FETCH0;
        bus_slct = `A_OUT;
        alu_op = `ALU_ADD;
        ld_a = 0;
        ld_b = 0;
        ld_addr = 0;
        ld_instr = 0;
        incr_pc = 0;
        reset_instr_state = 0;
    end

    // compute control signals based on instr reg/instr_state (even though they're regs, will synthesize to just wires)
    always @(*) begin 
        // set defaults
        ld_a = 0;
        ld_b = 0;
        ld_addr = 0;
        ld_instr = 0;
        incr_pc = 0;
        bus_slct = `A_OUT;
        alu_op = `ALU_PASSTHROUGH;
        reset_instr_state = 0;

        case (instr_state)
            `FETCH0: begin
                // pc -> addr
                bus_slct = `PC_OUT;
                ld_addr = 1;
            end

            `FETCH1: begin
                // mem -> instr, pc++
                bus_slct = `MEM_OUT;
                ld_instr = 1;

                incr_pc = 1;
            end

            `INSTR0: begin
                case (instr)
                    `INSTR_ADD_IMD,
                    `INSTR_SUB_IMD,
                    `INSTR_LDB,
                    `INSTR_LDA: begin
                        // pc -> addr (mem_data becomes first operand)
                        bus_slct = `PC_OUT;
                        ld_addr = 1;
                    end

                    `INSTR_ADD_B: begin
                        // a + b -> a
                        bus_slct = `B_OUT;
                        ld_a = 1;
                        alu_op = `ALU_ADD;
                        reset_instr_state = 1;
                    end

                    `INSTR_SUB_B: begin
                        // a - b -> a
                        bus_slct = `B_OUT;
                        ld_a = 1;
                        alu_op = `ALU_SUB;
                        reset_instr_state = 1;
                    end
                endcase
            end

            `INSTR1: begin
                case (instr)
                    `INSTR_LDA: begin
                        // mem -> a
                        bus_slct = `MEM_OUT;
                        ld_a = 1;
                        incr_pc = 1;
                    end

                    `INSTR_LDB: begin
                        // mem -> b
                        bus_slct = `MEM_OUT;
                        ld_b = 1;
                        incr_pc = 1;
                    end

                    `INSTR_ADD_IMD: begin
                        // a + mem -> a
                        bus_slct = `MEM_OUT;
                        alu_op = `ALU_ADD;
                        ld_a = 1;
                        incr_pc = 1;
                    end

                    `INSTR_SUB_IMD: begin
                        // a - mem -> a
                        bus_slct = `MEM_OUT;
                        alu_op = `ALU_SUB;
                        ld_a = 1;
                        incr_pc = 1;
                    end
                endcase
            end
        endcase
    end

    // latch registers on rising edge
    always @(posedge clk) begin
        instr_state <= reset_instr_state ? 0 : instr_state + 1;
            
        // update registers
        if (ld_a)
            a <= alu_out;

        if (ld_b)
            b <= bus;
        if (ld_addr)
            addr <= bus;
        if (ld_instr)
            instr <= bus;
        
        if (incr_pc)
            pc <= pc + 1;

        $display("t=%0d | instr_state=%d | bus_slct=%d | bus=%d | ld_addr=%d | ld_instr=%d | ld_a=%d | a=%d | b=%d | pc=%d | addr=%d | instr=%d | mem=%d", $time, instr_state, bus_slct, bus, ld_addr, ld_instr, ld_a, a, b, pc, addr, instr, mem_data);
        if ((instr_state[0] & instr_state[1]) | reset_instr_state)
            $display("\n");
    end

endmodule;

module memory_mock (
    input wire [7:0] addr,
    output reg [7:0] data_out
);

    reg [7:0] mem [0:255];

    always @(*) begin
        data_out = mem[addr];
    end

    initial begin
        // leave null byte empty
        mem[0] = 8'd0;

        // LDA 7
        mem[1] = `INSTR_LDA;
        mem[2] = 8'd4;

        // LDB 100
        mem[3] = `INSTR_LDB;
        mem[4] = 8'd100;

        // ADDB
        mem[5] = `INSTR_ADD_B;

        // SUB 20
        mem[6] = `INSTR_SUB_IMD;
        mem[7] = 8'd20;

    end

endmodule

module cpu_tb;
    reg clk;

    cpu my_cpu(clk);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        #200;
        $finish;
    end
endmodule