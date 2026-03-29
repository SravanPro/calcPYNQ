vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xilinx_vip
vlib questa_lib/msim/xpm
vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/axi_infrastructure_v1_1_0
vlib questa_lib/msim/axi_vip_v1_1_21
vlib questa_lib/msim/processing_system7_vip_v1_0_23
vlib questa_lib/msim/xlconstant_v1_1_10
vlib questa_lib/msim/proc_sys_reset_v5_0_17
vlib questa_lib/msim/smartconnect_v1_0
vlib questa_lib/msim/axi_register_slice_v2_1_35
vlib questa_lib/msim/axi_lite_ipif_v3_0_4
vlib questa_lib/msim/interrupt_control_v3_1_5
vlib questa_lib/msim/axi_iic_v2_1_11

vmap xilinx_vip questa_lib/msim/xilinx_vip
vmap xpm questa_lib/msim/xpm
vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap axi_infrastructure_v1_1_0 questa_lib/msim/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_21 questa_lib/msim/axi_vip_v1_1_21
vmap processing_system7_vip_v1_0_23 questa_lib/msim/processing_system7_vip_v1_0_23
vmap xlconstant_v1_1_10 questa_lib/msim/xlconstant_v1_1_10
vmap proc_sys_reset_v5_0_17 questa_lib/msim/proc_sys_reset_v5_0_17
vmap smartconnect_v1_0 questa_lib/msim/smartconnect_v1_0
vmap axi_register_slice_v2_1_35 questa_lib/msim/axi_register_slice_v2_1_35
vmap axi_lite_ipif_v3_0_4 questa_lib/msim/axi_lite_ipif_v3_0_4
vmap interrupt_control_v3_1_5 questa_lib/msim/interrupt_control_v3_1_5
vmap axi_iic_v2_1_11 questa_lib/msim/axi_iic_v2_1_11

vlog -work xilinx_vip  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi_vip_if.sv" \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/clk_vip_if.sv" \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"C:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"C:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93  \
"C:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/design_1/ipshared/877e/hdl/dataBridgeIP_slave_lite_v1_0_S00_AXI.v" \
"../../../bd/design_1/ipshared/877e/hdl/dataBridgeIP.v" \
"../../../bd/design_1/ip/design_1_dataBridgeIP_0_0/sim/design_1_dataBridgeIP_0_0.v" \

vlog -work axi_infrastructure_v1_1_0  -incr -mfcu  "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_21  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f16f/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_23  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_processing_system7_0_0/sim/design_1_processing_system7_0_0.v" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/sim/bd_afc3.v" \

vlog -work xlconstant_v1_1_10  -incr -mfcu  "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a165/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_0/sim/bd_afc3_one_0.v" \

vcom -work proc_sys_reset_v5_0_17  -93  \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/9438/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_1/sim/bd_afc3_psr_aclk_0.vhd" \

vlog -work smartconnect_v1_0  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/sc_util_v1_0_vl_rfs.sv" \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/3718/hdl/sc_switchboard_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_2/sim/bd_afc3_arinsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_3/sim/bd_afc3_rinsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_4/sim/bd_afc3_awinsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_5/sim/bd_afc3_winsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_6/sim/bd_afc3_binsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_7/sim/bd_afc3_aroutsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_8/sim/bd_afc3_routsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_9/sim/bd_afc3_awoutsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_10/sim/bd_afc3_woutsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_11/sim/bd_afc3_boutsw_0.sv" \

vlog -work smartconnect_v1_0  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/sc_node_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_12/sim/bd_afc3_arni_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_13/sim/bd_afc3_rni_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_14/sim/bd_afc3_awni_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_15/sim/bd_afc3_wni_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_16/sim/bd_afc3_bni_0.sv" \

vlog -work smartconnect_v1_0  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/d800/hdl/sc_mmu_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_17/sim/bd_afc3_s00mmu_0.sv" \

vlog -work smartconnect_v1_0  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/2da8/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_18/sim/bd_afc3_s00tr_0.sv" \

vlog -work smartconnect_v1_0  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/dce3/hdl/sc_si_converter_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_19/sim/bd_afc3_s00sic_0.sv" \

vlog -work smartconnect_v1_0  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/cef3/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_20/sim/bd_afc3_s00a2s_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_21/sim/bd_afc3_sarn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_22/sim/bd_afc3_srn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_23/sim/bd_afc3_sawn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_24/sim/bd_afc3_swn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_25/sim/bd_afc3_sbn_0.sv" \

vlog -work smartconnect_v1_0  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/7f4f/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_26/sim/bd_afc3_m00s2a_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_27/sim/bd_afc3_m00arn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_28/sim/bd_afc3_m00rn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_29/sim/bd_afc3_m00awn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_30/sim/bd_afc3_m00wn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_31/sim/bd_afc3_m00bn_0.sv" \

vlog -work smartconnect_v1_0  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/0133/hdl/sc_exit_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_32/sim/bd_afc3_m00e_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_33/sim/bd_afc3_m01s2a_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_34/sim/bd_afc3_m01arn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_35/sim/bd_afc3_m01rn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_36/sim/bd_afc3_m01awn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_37/sim/bd_afc3_m01wn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_38/sim/bd_afc3_m01bn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_39/sim/bd_afc3_m01e_0.sv" \

vlog -work axi_register_slice_v2_1_35  -incr -mfcu  "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/c5b7/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/sim/design_1_axi_smc_0.sv" \

vcom -work xil_defaultlib  -93  \
"../../../bd/design_1/ip/design_1_rst_ps7_0_100M_0/sim/design_1_rst_ps7_0_100M_0.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/design_1/ipshared/498c/src/add.sv" \
"../../../bd/design_1/ipshared/498c/src/clockDivider.sv" \
"../../../bd/design_1/ipshared/498c/src/cos_core.sv" \
"../../../bd/design_1/ipshared/498c/src/debouncer.sv" \
"../../../bd/design_1/ipshared/498c/src/decoder.sv" \
"../../../bd/design_1/ipshared/498c/src/div.sv" \
"../../../bd/design_1/ipshared/498c/src/ds.sv" \
"../../../bd/design_1/ipshared/498c/src/exp_core.sv" \
"../../../bd/design_1/ipshared/498c/src/itp.sv" \
"../../../bd/design_1/ipshared/498c/src/kb.sv" \
"../../../bd/design_1/ipshared/498c/src/ln_core.sv" \
"../../../bd/design_1/ipshared/498c/src/log_core.sv" \
"../../../bd/design_1/ipshared/498c/src/mul.sv" \
"../../../bd/design_1/ipshared/498c/src/mul10Count.sv" \
"../../../bd/design_1/ipshared/498c/src/nb.sv" \
"../../../bd/design_1/ipshared/498c/src/pev.sv" \
"../../../bd/design_1/ipshared/498c/src/pow_core.sv" \
"../../../bd/design_1/ipshared/498c/src/seq_divider.sv" \
"../../../bd/design_1/ipshared/498c/src/seq_multiplier.sv" \
"../../../bd/design_1/ipshared/498c/src/sin_core.sv" \
"../../../bd/design_1/ipshared/498c/src/tan_core.sv" \
"../../../bd/design_1/ipshared/498c/src/parent.sv" \
"../../../bd/design_1/ip/design_1_parent_0_0/sim/design_1_parent_0_0.sv" \

vcom -work axi_lite_ipif_v3_0_4  -93  \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/66ea/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \

vcom -work interrupt_control_v3_1_5  -93  \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/d8cc/hdl/interrupt_control_v3_1_vh_rfs.vhd" \

vcom -work axi_iic_v2_1_11  -93  \
"../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/67c0/hdl/axi_iic_v2_1_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../bd/design_1/ip/design_1_axi_iic_0_0/sim/design_1_axi_iic_0_0.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/6cfa/hdl" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../calcFinal.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/design_1/sim/design_1.v" \

vlog -work xil_defaultlib \
"glbl.v"

