read_verilog {rtl/top.v rtl/pc_unit.v rtl/imem.v rtl/decoder.v rtl/imm_gen.v rtl/regfile.v rtl/alu.v rtl/dmem.v}
read_xdc scripts/synth_timing.xdc
synth_design -top top -part xc7z020clg400-1
report_timing -delay_type max -max_paths 1 -file build/synth_timing_path.rpt
