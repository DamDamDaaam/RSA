########################
##   slide switches   ##
########################

set_property -dict { PACKAGE_PIN A8   IOSTANDARD LVCMOS33 } [get_ports en ]   ; #IO_L12N_T1_MRCC_16 Sch=sw[0]

########################
##   Pmod header JA   ##
########################

set_property -dict { PACKAGE_PIN G13  IOSTANDARD LVCMOS33 } [get_ports { rng_out[7] }]   ; #IO_0_15 Sch=ja[1]
set_property -dict { PACKAGE_PIN B11  IOSTANDARD LVCMOS33 } [get_ports { rng_out[6] }]   ; #IO_L4P_T0_15 Sch=ja[2]
set_property -dict { PACKAGE_PIN A11  IOSTANDARD LVCMOS33 } [get_ports { rng_out[5] }]   ; #IO_L4N_T0_15 Sch=ja[3]
set_property -dict { PACKAGE_PIN D12  IOSTANDARD LVCMOS33 } [get_ports { rng_out[4] }]   ; #IO_L6P_T0_15 Sch=ja[4]
set_property -dict { PACKAGE_PIN D13  IOSTANDARD LVCMOS33 } [get_ports { rng_out[3] }]   ; #IO_L6N_T0_VREF_15 Sch=ja[7]
set_property -dict { PACKAGE_PIN B18  IOSTANDARD LVCMOS33 } [get_ports { rng_out[2] }]   ; #IO_L10P_T1_AD11P_15 Sch=ja[8]
set_property -dict { PACKAGE_PIN A18  IOSTANDARD LVCMOS33 } [get_ports { rng_out[1] }]   ; #IO_L10N_T1_AD11N_15 Sch=ja[9]
set_property -dict { PACKAGE_PIN K16  IOSTANDARD LVCMOS33 } [get_ports { rng_out[0] }]   ; #IO_25_15 Sch=ja[10]


########################
##   Pmod Header JB   ##
########################

set_property -dict { PACKAGE_PIN E15   IOSTANDARD LVCMOS33 } [get_ports { rng_out[15] }]   ; #IO_L11P_T1_SRCC_15 Sch=jb_p[1]
set_property -dict { PACKAGE_PIN E16   IOSTANDARD LVCMOS33 } [get_ports { rng_out[14] }]   ; #IO_L11N_T1_SRCC_15 Sch=jb_n[1]
set_property -dict { PACKAGE_PIN D15   IOSTANDARD LVCMOS33 } [get_ports { rng_out[13] }]   ; #IO_L12P_T1_MRCC_15 Sch=jb_p[2]
set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports { rng_out[12] }]   ; #IO_L12N_T1_MRCC_15 Sch=jb_n[2]
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { rng_out[11] }]   ; #IO_L23P_T3_FOE_B_15 Sch=jb_p[3]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { rng_out[10] }]   ; #IO_L23N_T3_FWE_B_15 Sch=jb_n[3]
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { rng_out[9] }]   ; #IO_L24P_T3_RS1_15 Sch=jb_p[4]
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { rng_out[8] }]   ; #IO_L24N_T3_RS0_15 Sch=jb_n[4]


########################
##   Pmod Header JC   ##
########################

set_property -dict { PACKAGE_PIN U12  IOSTANDARD LVCMOS33 } [get_ports { rng_out[23] }]   ; #IO_L20P_T3_A08_D24_14 Sch=jc_p[1]
set_property -dict { PACKAGE_PIN V12  IOSTANDARD LVCMOS33 } [get_ports { rng_out[22] }]   ; #IO_L20N_T3_A07_D23_14 Sch=jc_n[1]
set_property -dict { PACKAGE_PIN V10  IOSTANDARD LVCMOS33 } [get_ports { rng_out[21] }]   ; #IO_L21P_T3_DQS_14 Sch=jc_p[2]
set_property -dict { PACKAGE_PIN V11  IOSTANDARD LVCMOS33 } [get_ports { rng_out[20] }]   ; #IO_L21N_T3_DQS_A06_D22_14 Sch=jc_n[2]
set_property -dict { PACKAGE_PIN U14  IOSTANDARD LVCMOS33 } [get_ports { rng_out[19] }]   ; #IO_L22P_T3_A05_D21_14 Sch=jc_p[3]
set_property -dict { PACKAGE_PIN V14  IOSTANDARD LVCMOS33 } [get_ports { rng_out[18] }]   ; #IO_L22N_T3_A04_D20_14 Sch=jc_n[3]
set_property -dict { PACKAGE_PIN T13  IOSTANDARD LVCMOS33 } [get_ports { rng_out[17] }]   ; #IO_L23P_T3_A03_D19_14 Sch=jc_p[4]
set_property -dict { PACKAGE_PIN U13  IOSTANDARD LVCMOS33 } [get_ports { rng_out[16] }]   ; #IO_L23N_T3_A02_D18_14 Sch=jc_n[4]


########################
##   Pmod Header JD   ##
########################

set_property -dict { PACKAGE_PIN D4  IOSTANDARD LVCMOS33 } [get_ports { rng_out[31] }]   ; #IO_L11N_T1_SRCC_35 Sch=jd[1]
set_property -dict { PACKAGE_PIN D3  IOSTANDARD LVCMOS33 } [get_ports { rng_out[30] }]   ; #IO_L12N_T1_MRCC_35 Sch=jd[2]
set_property -dict { PACKAGE_PIN F4  IOSTANDARD LVCMOS33 } [get_ports { rng_out[29] }]   ; #IO_L13P_T2_MRCC_35 Sch=jd[3]
set_property -dict { PACKAGE_PIN F3  IOSTANDARD LVCMOS33 } [get_ports { rng_out[28] }]   ; #IO_L13N_T2_MRCC_35 Sch=jd[4]
set_property -dict { PACKAGE_PIN E2  IOSTANDARD LVCMOS33 } [get_ports { rng_out[27] }]   ; #IO_L14P_T2_SRCC_35 Sch=jd[7]
set_property -dict { PACKAGE_PIN D2  IOSTANDARD LVCMOS33 } [get_ports { rng_out[26] }]   ; #IO_L14N_T2_SRCC_35 Sch=jd[8]
set_property -dict { PACKAGE_PIN H2  IOSTANDARD LVCMOS33 } [get_ports { rng_out[25] }]   ; #IO_L15P_T2_DQS_35 Sch=jd[9]
set_property -dict { PACKAGE_PIN G2  IOSTANDARD LVCMOS33 } [get_ports { rng_out[24] }]   ; #IO_L15N_T2_DQS_35 Sch=jd[10]
