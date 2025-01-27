## Clock signal
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk_0]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_0]

#switch 0
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports reset_0]

#bouton central
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports start_0]