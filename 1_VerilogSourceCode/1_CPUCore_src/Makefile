cpu_src = $(wildcard *.v ./BRAMModule/*.v)
CC = iverilog
TARGET = a.out
DATA_TEST = testAll.data
INST_TEST = testAll.inst
DATA_RAM = DataRamContent.txt
INST_RAM = InstRamContent.txt
WAVE = wave.vcd
all:
	$(CC) ../2_Simulation/testbench.v $(cpu_src)
run1:
	cp testfiles/1$(DATA_TEST) ./$(DATA_TEST)
	cp testfiles/1$(INST_TEST) ./$(INST_TEST)
	./$(TARGET)
	mv $(DATA_RAM) 1_$(DATA_RAM)
	mv $(INST_RAM) 1_$(INST_RAM)
	mv $(WAVE) 1_$(WAVE)
run2:
	cp testfiles/2$(DATA_TEST) ./$(DATA_TEST)
	cp testfiles/2$(INST_TEST) ./$(INST_TEST)
	./$(TARGET)
	mv $(DATA_RAM) 2_$(DATA_RAM)
	mv $(INST_RAM) 2_$(INST_RAM)
	mv $(WAVE) 2_$(WAVE)

run3:
	cp testfiles/3$(DATA_TEST) ./$(DATA_TEST)
	cp testfiles/3$(INST_TEST) ./$(INST_TEST)
	./$(TARGET)
	mv $(DATA_RAM) 3_$(DATA_RAM)
	mv $(INST_RAM) 3_$(INST_RAM)
	mv $(WAVE) 3_$(WAVE)

clean:
	rm -rf $(TARGET)
	rm -rf *.txt
	rm -rf *.vcd
