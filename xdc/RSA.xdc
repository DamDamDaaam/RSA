################################
##   electrical constraints   ##
################################

## voltage configurations
set_property CFGBVS VCCO        [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]


#######################################
##   on-board 100 MHz clock signal   ##
#######################################

set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk_100] ; #IO_L12P_T1_MRCC_35 Sch=gclk[100]


############################
##   timing constraints   ##
############################

#### CLOCK COMMENTATI PERCHÈ AUTOGENERATI DAL PLL IP CORE
#create_clock -period 10.000 -name clk_100 -waveform {0.000 5.000} -add [get_ports clk_100]
#create_clock -period 10.000 -name clk -waveform {0.000 5.000} -add [get_ports clk]

set_input_delay 5 [get_ports mode_select*]
set_input_delay 5 [get_ports var_sel]
set_input_delay 5 [get_ports del_but]
set_input_delay 5 [get_ports start_but]
set_input_delay 5 [get_ports select_but]
set_input_delay 5 [get_ports add_but]
set_input_delay 5 [get_ports rx_stream]

set_output_delay 5 [get_ports display*]
set_output_delay 5 [get_ports anode*]
set_output_delay 5 [get_ports tx_stream]

set_false_path -from [get_ports mode_select*]
set_false_path -from [get_ports var_sel]
set_false_path -from [get_ports del_but]
set_false_path -from [get_ports start_but]
set_false_path -from [get_ports select_but]
set_false_path -from [get_ports add_but]
set_false_path -from [get_ports rx_stream]

set_false_path -to [get_ports display*]
set_false_path -to [get_ports anode*]
set_false_path -to [get_ports tx_stream]


########################
##   slide switches   ##
########################

set_property -dict { PACKAGE_PIN A8   IOSTANDARD LVCMOS33 } [get_ports { var_sel }]   ; #IO_L12N_T1_MRCC_16 Sch=sw[0]

######### SLIDE SWITCH COMMENTATO
#set_property -dict { PACKAGE_PIN C11  IOSTANDARD LVCMOS33 } [get_ports { out_en }]   ; #IO_L13P_T2_MRCC_16 Sch=sw[1]

set_property -dict { PACKAGE_PIN C10  IOSTANDARD LVCMOS33 } [get_ports { mode_select[0] }]   ; #IO_L13N_T2_MRCC_16 Sch=sw[2]
set_property -dict { PACKAGE_PIN A10  IOSTANDARD LVCMOS33 } [get_ports { mode_select[1] }]   ; #IO_L14P_T2_SRCC_16 Sch=sw[3]



##################
##   RGB LEDs   ## #### POTENZIALMENTE USARE PER DEBUG
##################

#set_property -dict { PACKAGE_PIN E1  IOSTANDARD LVCMOS33 } [get_ports { led0_b }]   ; #IO_L18N_T2_35 Sch=led0_b
#set_property -dict { PACKAGE_PIN F6  IOSTANDARD LVCMOS33 } [get_ports { led0_g }]   ; #IO_L19N_T3_VREF_35 Sch=led0_g
#set_property -dict { PACKAGE_PIN G6  IOSTANDARD LVCMOS33 } [get_ports { led0_r }]   ; #IO_L19P_T3_35 Sch=led0_r
#set_property -dict { PACKAGE_PIN G4  IOSTANDARD LVCMOS33 } [get_ports { led1_b }]   ; #IO_L20P_T3_35 Sch=led1_b
#set_property -dict { PACKAGE_PIN J4  IOSTANDARD LVCMOS33 } [get_ports { led1_g }]   ; #IO_L21P_T3_DQS_35 Sch=led1_g
#set_property -dict { PACKAGE_PIN G3  IOSTANDARD LVCMOS33 } [get_ports { led1_r }]   ; #IO_L20N_T3_35 Sch=led1_r
#set_property -dict { PACKAGE_PIN H4  IOSTANDARD LVCMOS33 } [get_ports { led2_b }]   ; #IO_L21N_T3_DQS_35 Sch=led2_b
#set_property -dict { PACKAGE_PIN J2  IOSTANDARD LVCMOS33 } [get_ports { led2_g }]   ; #IO_L22N_T3_35 Sch=led2_g
#set_property -dict { PACKAGE_PIN J3  IOSTANDARD LVCMOS33 } [get_ports { led2_r }]   ; #IO_L22P_T3_35 Sch=led2_r
#set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports { led3_b }]   ; #IO_L23P_T3_35 Sch=led3_b
#set_property -dict { PACKAGE_PIN H6  IOSTANDARD LVCMOS33 } [get_ports { led3_g }]   ; #IO_L24P_T3_35 Sch=led3_g
#set_property -dict { PACKAGE_PIN K1  IOSTANDARD LVCMOS33 } [get_ports { led3_r }]   ; #IO_L23N_T3_35 Sch=led3_r



#######################
##   standard LEDs   ## #### POTENZIAMENTE USARE PER DEBUG
#######################

#set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33 } [get_ports { led[0] }]   ; #IO_L24N_T3_35 Sch=led[4]
#set_property -dict { PACKAGE_PIN J5  IOSTANDARD LVCMOS33 } [get_ports { led[1] }]   ; #IO_25_35 Sch=led[5]
#set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports { led[2] }]   ; #IO_L24P_T3_A01_D17_14 Sch=led[6]
#set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { led[3] }]   ; #IO_L24N_T3_A00_D16_14 Sch=led[7]


######################
##   push-buttons   ##
######################

set_property -dict { PACKAGE_PIN D9  IOSTANDARD LVCMOS33 } [get_ports {    add_but }]   ; #IO_L6N_T0_VREF_16 Sch=btn[0]
set_property -dict { PACKAGE_PIN C9  IOSTANDARD LVCMOS33 } [get_ports { select_but }]   ; #IO_L11P_T1_SRCC_16 Sch=btn[1]
set_property -dict { PACKAGE_PIN B9  IOSTANDARD LVCMOS33 } [get_ports {    del_but }]   ; #IO_L11N_T1_SRCC_16 Sch=btn[2]
set_property -dict { PACKAGE_PIN B8  IOSTANDARD LVCMOS33 } [get_ports {  start_but }]   ; #IO_L12P_T1_MRCC_16 Sch=btn[3]


########################
##   Pmod header JA   ##
########################

set_property -dict { PACKAGE_PIN G13  IOSTANDARD LVCMOS33 } [get_ports { display[7] }]   ; #IO_0_15 Sch=ja[1]
set_property -dict { PACKAGE_PIN B11  IOSTANDARD LVCMOS33 } [get_ports { display[6] }]   ; #IO_L4P_T0_15 Sch=ja[2]
set_property -dict { PACKAGE_PIN A11  IOSTANDARD LVCMOS33 } [get_ports { display[5] }]   ; #IO_L4N_T0_15 Sch=ja[3]
set_property -dict { PACKAGE_PIN D12  IOSTANDARD LVCMOS33 } [get_ports { display[4] }]   ; #IO_L6P_T0_15 Sch=ja[4]
set_property -dict { PACKAGE_PIN D13  IOSTANDARD LVCMOS33 } [get_ports { display[3] }]   ; #IO_L6N_T0_VREF_15 Sch=ja[7]
set_property -dict { PACKAGE_PIN B18  IOSTANDARD LVCMOS33 } [get_ports { display[2] }]   ; #IO_L10P_T1_AD11P_15 Sch=ja[8]
set_property -dict { PACKAGE_PIN A18  IOSTANDARD LVCMOS33 } [get_ports { display[1] }]   ; #IO_L10N_T1_AD11N_15 Sch=ja[9]
set_property -dict { PACKAGE_PIN K16  IOSTANDARD LVCMOS33 } [get_ports { display[0] }]   ; #IO_25_15 Sch=ja[10]


########################
##   Pmod Header JB   ##
########################

set_property -dict { PACKAGE_PIN E15   IOSTANDARD LVCMOS33 } [get_ports { anode[0] }]   ; #IO_L11P_T1_SRCC_15 Sch=jb_p[1]
set_property -dict { PACKAGE_PIN E16   IOSTANDARD LVCMOS33 } [get_ports { anode[1] }]   ; #IO_L11N_T1_SRCC_15 Sch=jb_n[1]
set_property -dict { PACKAGE_PIN D15   IOSTANDARD LVCMOS33 } [get_ports { anode[2] }]   ; #IO_L12P_T1_MRCC_15 Sch=jb_p[2]
set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports { anode[3] }]   ; #IO_L12N_T1_MRCC_15 Sch=jb_n[2]
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { anode[4] }]   ; #IO_L23P_T3_FOE_B_15 Sch=jb_p[3]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { anode[5] }]   ; #IO_L23N_T3_FWE_B_15 Sch=jb_n[3]
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { anode[6] }]   ; #IO_L24P_T3_RS1_15 Sch=jb_p[4]
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { anode[7] }]   ; #IO_L24N_T3_RS0_15 Sch=jb_n[4]


########################
##   Pmod Header JC   ##
########################

set_property -dict { PACKAGE_PIN U12  IOSTANDARD LVCMOS33 } [get_ports { anode[8] }]   ; #IO_L20P_T3_A08_D24_14 Sch=jc_p[1]
set_property -dict { PACKAGE_PIN V12  IOSTANDARD LVCMOS33 } [get_ports { anode[9] }]   ; #IO_L20N_T3_A07_D23_14 Sch=jc_n[1]
set_property -dict { PACKAGE_PIN V10  IOSTANDARD LVCMOS33 } [get_ports { anode[10] }]   ; #IO_L21P_T3_DQS_14 Sch=jc_p[2]
set_property -dict { PACKAGE_PIN V11  IOSTANDARD LVCMOS33 } [get_ports { anode[11] }]   ; #IO_L21N_T3_DQS_A06_D22_14 Sch=jc_n[2]
#set_property -dict { PACKAGE_PIN U14  IOSTANDARD LVCMOS33 } [get_ports { jc[4] }]   ; #IO_L22P_T3_A05_D21_14 Sch=jc_p[3]
#set_property -dict { PACKAGE_PIN V14  IOSTANDARD LVCMOS33 } [get_ports { jc[5] }]   ; #IO_L22N_T3_A04_D20_14 Sch=jc_n[3]
#set_property -dict { PACKAGE_PIN T13  IOSTANDARD LVCMOS33 } [get_ports { jc[6] }]   ; #IO_L23P_T3_A03_D19_14 Sch=jc_p[4]
#set_property -dict { PACKAGE_PIN U13  IOSTANDARD LVCMOS33 } [get_ports { jc[7] }]   ; #IO_L23N_T3_A02_D18_14 Sch=jc_n[4]


########################
##   Pmod Header JD   ## #### COMMENTATO, INUTILIZZATO
########################

#set_property -dict { PACKAGE_PIN D4  IOSTANDARD LVCMOS33 } [get_ports { jd[0] }]   ; #IO_L11N_T1_SRCC_35 Sch=jd[1]
#set_property -dict { PACKAGE_PIN D3  IOSTANDARD LVCMOS33 } [get_ports { jd[1] }]   ; #IO_L12N_T1_MRCC_35 Sch=jd[2]
#set_property -dict { PACKAGE_PIN F4  IOSTANDARD LVCMOS33 } [get_ports { jd[2] }]   ; #IO_L13P_T2_MRCC_35 Sch=jd[3]
#set_property -dict { PACKAGE_PIN F3  IOSTANDARD LVCMOS33 } [get_ports { jd[3] }]   ; #IO_L13N_T2_MRCC_35 Sch=jd[4]
#set_property -dict { PACKAGE_PIN E2  IOSTANDARD LVCMOS33 } [get_ports { jd[4] }]   ; #IO_L14P_T2_SRCC_35 Sch=jd[7]
#set_property -dict { PACKAGE_PIN D2  IOSTANDARD LVCMOS33 } [get_ports { jd[5] }]   ; #IO_L14N_T2_SRCC_35 Sch=jd[8]
#set_property -dict { PACKAGE_PIN H2  IOSTANDARD LVCMOS33 } [get_ports { jd[6] }]   ; #IO_L15P_T2_DQS_35 Sch=jd[9]
#set_property -dict { PACKAGE_PIN G2  IOSTANDARD LVCMOS33 } [get_ports { jd[7] }]   ; #IO_L15N_T2_DQS_35 Sch=jd[10]


############################
##   USB-UART Interface   ##
############################

set_property -dict { PACKAGE_PIN D10 IOSTANDARD LVCMOS33 } [get_ports { tx_stream }]  ; #IO_L19N_T3_VREF_16 Sch=uart_rxd_out
set_property -dict { PACKAGE_PIN A9  IOSTANDARD LVCMOS33 } [get_ports { rx_stream }]   ; #IO_L14N_T2_SRCC_16 Sch=uart_txd_in


################################
##   additional constraints   ##
################################

##
## additional XDC statements to optimize the memory configuration file (.bin)
## to program the external 128 Mb Quad Serial Peripheral Interface (SPI) flash
## memory in order to automatically load the FPGA configuration at power-up
##

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4  [current_design]
set_property CONFIG_MODE SPIx4  [current_design]


