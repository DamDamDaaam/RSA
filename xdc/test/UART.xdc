################################
##   electrical constraints   ##
################################

## voltage configurations
set_property CFGBVS VCCO        [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

#######################################
##   on-board 100 MHz clock signal   ##
#######################################

set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name clk -waveform {0.000 5.000} -add [get_ports clk]
set_input_delay  -clock clk 5 [get_ports rx]
set_output_delay -clock clk -max 1600 [get_ports tx]

############################
##   USB-UART Interface   ##
############################

set_property -dict { PACKAGE_PIN D10 IOSTANDARD LVCMOS33 } [get_ports tx]  ; #IO_L19N_T3_VREF_16 Sch=uart_rxd_out
set_property -dict { PACKAGE_PIN A9  IOSTANDARD LVCMOS33 } [get_ports rx]   ; #IO_L14N_T2_SRCC_16 Sch=uart_txd_in
