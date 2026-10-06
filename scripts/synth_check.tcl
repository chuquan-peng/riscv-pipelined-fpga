read_verilog {rtl/top.v rtl/pc_unit.v rtl/imem.v rtl/decoder.v rtl/imm_gen.v rtl/regfile.v rtl/alu.v rtl/dmem.v} 
synth_design -top top -part xc7z020clg400-1 -flatten_hierarchy none 
file mkdir build 
report_utilization -hierarchical -file build/synth_check_util.rpt 
