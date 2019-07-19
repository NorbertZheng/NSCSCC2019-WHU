# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xc7a200tfbg676-2

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/run_vivado/mycpu_prj1/mycpu.cache/wt [current_project]
set_property parent.project_path C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/run_vivado/mycpu_prj1/mycpu.xpr [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_cache_permissions disable [current_project]
add_files C:/Users/Think/Desktop/func_test_v0.01/soft/func/obj/inst_ram.coe
read_verilog -library xil_defaultlib {
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Define/ALUOP_Define.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/EXE/ALU.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Define/COP0_Define.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/ID/COP0.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Define/Instruction_Define.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Define/LS_Define.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/ID/Control_Unit.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/EXE/Divider.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/EXE/EXE_MEM_REG/EXE_MEM_REG.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/EXE/EXE_MEM_REG/EXE_MEM_REG_PACKED.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Define/Fragment_Define.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Generatic/EXT.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/EXE/Forwarding_Unit.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/ID/Hazard_Detection_Unit.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/ID/ID_EXE_REG/ID_EXE_REG.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/ID/ID_EXE_REG/ID_EXE_REG_PACKED.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/IF/IF_ID_REG/IF_ID_REG.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/IF/IF_ID_REG/IF_ID_REG_PACKED.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/MEM/MEM_WB_REG.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/MEM/MEM_WB_REG_PACKED.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Mips.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Generatic/Mux.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/IF/PC/PC.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/IF/PC/PCPlus4.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/IF/PC/PCReg.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/ID/Registers.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Generatic/AdvancedCarryAdder/add.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/BRIDGE/bridge_1x2.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Generatic/AdvancedCarryAdder/cla32.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Generatic/AdvancedCarryAdder/cla_16.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Generatic/AdvancedCarryAdder/cla_2.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Generatic/AdvancedCarryAdder/cla_32.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Generatic/AdvancedCarryAdder/cla_4.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Generatic/AdvancedCarryAdder/cla_8.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/CONFREG/confreg.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Generatic/flopr.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Generatic/AdvancedCarryAdder/g_p.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/ID/hi_lo_reg.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/EXE/ll_bit.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/WB/modifyLoadData.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/MEM/modifyStoreData.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/mycpu_top.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/myCPU/CPU/Datapath/ID/victimInstDetector.v
  C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/soc_lite_top.v
}
read_ip -quiet C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/xilinx_ip/data_ram/data_ram.xci
set_property used_in_implementation false [get_files -all c:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/xilinx_ip/data_ram/data_ram_ooc.xdc]

read_ip -quiet C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/xilinx_ip/clk_pll/clk_pll.xci
set_property used_in_implementation false [get_files -all c:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/xilinx_ip/clk_pll/clk_pll_board.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/xilinx_ip/clk_pll/clk_pll.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/xilinx_ip/clk_pll/clk_pll_ooc.xdc]

read_ip -quiet C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/xilinx_ip/inst_ram/inst_ram.xci
set_property used_in_implementation false [get_files -all c:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/rtl/xilinx_ip/inst_ram/inst_ram_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/run_vivado/soc_lite.xdc
set_property used_in_implementation false [get_files C:/Users/Think/Desktop/func_test_v0.01/soc_sram_func/run_vivado/soc_lite.xdc]

set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top soc_lite_top -part xc7a200tfbg676-2


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef soc_lite_top.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file soc_lite_top_utilization_synth.rpt -pb soc_lite_top_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
