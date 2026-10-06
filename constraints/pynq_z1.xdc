## ============================================================================
## pynq_z1.xdc -- pins and timing for board/pynq_z1_top.v (PYNQ-Z1, xc7z020clg400-1)
## Pin numbers: PYNQ v3.0.1 boards/Pynq-Z1/base/vivado/constraints/base.xdc
## ============================================================================

## Clock: 125 MHz from the Ethernet PHY. The 50 MHz MMCM output clock is
## derived by Vivado from this one line; it is not declared here.
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports sysclk]
create_clock -name sysclk -period 8.000 [get_ports sysclk]

## Buttons (high when pressed)
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports {btn[0]}]
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports {btn[1]}]

## Slide switches
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS33} [get_ports {sw[0]}]
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports {sw[1]}]

## LEDs LD0..LD3 (high = on)
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {led[3]}]

## Tri-color LED LD4, green channel
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports led4_g]

## Buttons, switches and LEDs have no timing relationship to the clock.
## Tell the timing analyser not to check these paths.
set_false_path -from [get_ports {btn[*] sw[*]}]
set_false_path -to   [get_ports {led[*] led4_g}]
