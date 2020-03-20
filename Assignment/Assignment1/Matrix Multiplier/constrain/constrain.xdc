create_clock -name clk -period 5 [get_ports clk]
#set_property PACKAGE_PIN Y9 [get_ports clk]
set_property IOSTANDARD LVCMOS25 [get_ports clk]