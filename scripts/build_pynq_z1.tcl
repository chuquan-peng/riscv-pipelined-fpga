# ============================================================================
# build_pynq_z1.tcl -- RTL to bitstream for PYNQ-Z1, Vivado non-project mode
# Run from the repository root (prog.hex is read from the working directory):
#   vivado -mode batch -source scripts/build_pynq_z1.tcl
# ============================================================================

set out build/pynq_z1
file mkdir $out

# Inputs
read_verilog {
    rtl/top.v rtl/pc_unit.v rtl/imem.v rtl/decoder.v
    rtl/imm_gen.v rtl/regfile.v rtl/alu.v rtl/dmem.v
    board/pynq_z1_top.v
}
read_xdc constraints/pynq_z1.xdc

# Synthesis, then implementation
synth_design -top pynq_z1_top -part xc7z020clg400-1
opt_design
place_design
route_design

# Reports on the routed design
report_clocks                                     -file $out/clocks.rpt
report_timing -delay_type max -max_paths 1        -file $out/timing_setup.rpt
report_timing -delay_type min -max_paths 1        -file $out/timing_hold.rpt
report_timing_summary                             -file $out/timing_summary.rpt
report_utilization -hierarchical                  -file $out/util_hier.rpt

# Outputs
write_checkpoint -force $out/post_route.dcp
write_bitstream  -force $out/pynq_z1_top.bit
