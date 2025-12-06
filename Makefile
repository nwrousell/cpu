all: sim

sim: test.v tb.v
	iverilog -o sim test.v tb.v

run: sim
	vvp sim

clean:
	rm -f sim

