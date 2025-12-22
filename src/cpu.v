// instruction state machine
`define FETCH0 2'd0
`define FETCH1 2'd1
`define INSTR0 2'd2
`define INSTR1 2'd3

// bus select
`define A_OUT 3'd0
`define X_OUT 3'd1
`define Y_OUT 3'd2
`define MEM_OUT 3'd3
`define INSTR_OUT 3'd4
`define ADDR_OUT 3'd5
`define PC_OUT 3'd6
`define UNUSED1 3'd7

// instructions
`define INSTR_LDA 8'd0
`define INSTR_LDX 8'd1
`define INSTR_ADD_IMD 8'd2
`define INSTR_ADD_X 8'd3
`define INSTR_SUB_IMD 8'd4
`define INSTR_SUB_X 8'd5
`define INSTR_JMP 8'd6
`define INSTR_JMP_EQ 8'd7
`define INSTR_JMP_NEQ 8'd8
`define INSTR_JMP_GT 8'd9
`define INSTR_JMP_LT 8'd10
`define INSTR_JMP_GTE 8'd11
`define INSTR_JMP_LTE 8'd12
`define INSTR_CMP_IMD 8'd13
`define INSTR_CMP_X 8'd14
`define INSTR_TAX 8'd15
`define INSTR_TXA 8'd16
`define INSTR_TAY 8'd17
`define INSTR_TYA 8'd18

module cpu(
    input wire clk
);
    // registers
    reg signed [7:0] a, x, y;
    reg [7:0] pc, instr, addr;
    reg zero_flag;
    reg carry_flag;
    reg sign_flag;
    reg overflow_flag;

    // wires
    wire signed [7:0] bus, alu_out, mem_data;
    wire zero, carry, sign, overflow;

    // control state
    reg [1:0] instr_state; // intra-instruction step counter

    // control signals
    reg [2:0] bus_slct;
    reg [2:0] alu_op;
    reg ld_a, ld_x, ld_y, ld_addr, ld_instr, ld_pc, incr_pc, reset_instr_state;

    // components
    alu alu_inst(
        .result(alu_out),
        .zero(zero),
        .carry(carry),
        .overflow(overflow),
        .sign(sign),
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
        .b(x),
        .c(y),
        .d(mem_data),
        .e(instr),
        .f(addr),
        .g(pc),
        .h(8'd0),
        .slct(bus_slct)
    );

    initial begin
        a = 8'd0;
        x = 8'd0;
        y = 8'd0;
        pc = 8'd0;
        addr = 8'd0;
        instr = 8'd0;
        zero_flag = 0;
        carry_flag = 0;
        sign_flag = 0;
        overflow_flag = 0;
        instr_state = `FETCH0;
        bus_slct = `A_OUT;
        alu_op = `ALU_ADD;
        ld_a = 0;
        ld_x = 0;
        ld_y = 0;
        ld_addr = 0;
        ld_instr = 0;
        ld_pc = 0;
        incr_pc = 0;
        reset_instr_state = 0;
    end

    // compute control signals based on instr reg/instr_state (even though they're regs, will synthesize to just wires)
    always @(*) begin 
        // set defaults
        ld_a = 0;
        ld_x = 0;
        ld_y = 0;
        ld_addr = 0;
        ld_instr = 0;
        ld_pc = 0;
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
                    `INSTR_CMP_IMD,
                    `INSTR_JMP_GT,
                    `INSTR_JMP_GTE,
                    `INSTR_JMP_LT,
                    `INSTR_JMP_LTE,
                    `INSTR_JMP_EQ,
                    `INSTR_JMP_NEQ,
                    `INSTR_JMP,
                    `INSTR_ADD_IMD,
                    `INSTR_SUB_IMD,
                    `INSTR_LDX,
                    `INSTR_LDA: begin
                        // pc -> addr (mem_data becomes first operand)
                        bus_slct = `PC_OUT;
                        ld_addr = 1;
                    end

                    `INSTR_TAX: begin
                        // a -> x
                        bus_slct = `A_OUT;
                        ld_x = 1;
                        reset_instr_state = 1;
                    end

                    `INSTR_TXA: begin
                        // x -> a
                        bus_slct = `X_OUT;
                        ld_a = 1;
                        reset_instr_state = 1;
                    end

                    `INSTR_TAY: begin
                        // a -> y
                        bus_slct = `A_OUT;
                        ld_y = 1;
                        reset_instr_state = 1;
                    end

                    `INSTR_TYA: begin
                        // y -> a
                        bus_slct = `Y_OUT;
                        ld_a = 1;
                        reset_instr_state = 1;
                    end

                    `INSTR_ADD_X: begin
                        // a + x -> a
                        bus_slct = `X_OUT;
                        ld_a = 1;
                        alu_op = `ALU_ADD;
                        reset_instr_state = 1;
                    end

                    `INSTR_SUB_X: begin
                        // a - x -> a
                        bus_slct = `X_OUT;
                        ld_a = 1;
                        alu_op = `ALU_SUB;
                        reset_instr_state = 1;
                    end

                    `INSTR_CMP_X: begin
                        // a - x, only set flags
                        bus_slct = `X_OUT;
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

                    `INSTR_LDX: begin
                        // mem -> x
                        bus_slct = `MEM_OUT;
                        ld_x = 1;
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

                    `INSTR_CMP_IMD: begin
                        // a - mem, only set flags
                        bus_slct = `MEM_OUT;
                        alu_op = `ALU_SUB;
                        incr_pc = 1;
                    end

                    `INSTR_JMP: begin
                        // mem -> pc
                        bus_slct = `MEM_OUT;
                        ld_pc = 1;
                    end

                    `INSTR_JMP_EQ: begin
                        // Z ? mem -> pc : pc++
                        if (zero_flag) begin
                            bus_slct = `MEM_OUT;
                            ld_pc = 1;
                        end else begin
                            incr_pc = 1;
                        end
                    end

                    `INSTR_JMP_NEQ: begin
                        // Z ? pc++ : mem -> pc
                        if (zero_flag) begin
                            incr_pc = 1;
                        end else begin
                            bus_slct = `MEM_OUT;
                            ld_pc = 1;
                        end
                    end

                    `INSTR_JMP_LT: begin
                        // S ^ O ? mem -> pc : pc++
                        if (sign_flag ^ overflow_flag) begin
                            bus_slct = `MEM_OUT;
                            ld_pc = 1;
                        end else begin
                            incr_pc = 1;
                        end
                    end

                    `INSTR_JMP_LTE: begin
                        // (S ^ O) | Z ? mem -> pc : pc++
                        if ((sign_flag ^ overflow_flag) | zero_flag) begin
                            bus_slct = `MEM_OUT;
                            ld_pc = 1;
                        end else begin
                            incr_pc = 1;
                        end
                    end

                    `INSTR_JMP_GT: begin
                        // ~(S ^ O) & ~Z ? mem -> pc : pc++
                        if (!(sign_flag ^ overflow_flag) & !zero_flag) begin
                            bus_slct = `MEM_OUT;
                            ld_pc = 1;
                        end else begin
                            incr_pc = 1;
                        end
                    end

                    `INSTR_JMP_GTE: begin
                        // ~(S ^ O) ? mem -> pc : pc++
                        if (!(sign_flag ^ overflow_flag)) begin
                            bus_slct = `MEM_OUT;
                            ld_pc = 1;
                        end else begin
                            incr_pc = 1;
                        end
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

        if (ld_x)
            x <= bus;
        if (ld_y)
            y <= bus;
        if (ld_addr)
            addr <= bus;
        if (ld_instr)
            instr <= bus;
        if (ld_pc)
            pc <= bus;
        
        if (incr_pc)
            pc <= pc + 1;

        if (alu_op) begin
            zero_flag <= zero;
            carry_flag <= carry;
            sign_flag <= sign;
            overflow_flag <= overflow;
        end

        $display("t=%0d | instr_state=%d | bus_slct=%d | bus=%d | ld_addr=%d | ld_instr=%d | ld_pc=%d | ld_a=%d | a=%0d | x=%0d | y=%0d | pc=%0d | addr=%0d | instr=%0d | mem=%0d | Z=%d C=%d S=%d O=%d | alu_op=%d",
                  $time, instr_state, bus_slct, bus, ld_addr, ld_instr, ld_pc, ld_a, a, x, y, pc, addr, instr, mem_data, zero_flag, carry_flag, sign_flag, overflow_flag, alu_op);
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
        $readmemh("prog.mem", mem);
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
        #600;
        $finish;
    end
endmodule