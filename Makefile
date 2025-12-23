TB ?= add_tb


run: 
	iverilog -s $(TB) -c cmd.txt -o sim
	vvp sim

clean:
	rm -f sim
