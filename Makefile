all: dualportram_tb

.PHONY: vvp waveform clean

dualportram_tb: src/dualportram.sv tb/dualportram_tb.sv
	iverilog -g2012 -o dualportram_tb src/dualportram.sv tb/dualportram_tb.sv

dualportram_tb.vcd: dualportram_tb
	vvp dualportram_tb

vvp: dualportram_tb.vcd

waveform: dualportram_tb.vcd
	GDK_BACKEND=x11 gtkwave dualportram_tb.vcd & disown

clean:
	rm -f dualportram_tb dualportram_tb.vcd

