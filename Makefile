all: sim

sim: 
	iverilog -c cmd.txt -o sim

run: sim
	vvp sim

clean:
	rm -f sim

