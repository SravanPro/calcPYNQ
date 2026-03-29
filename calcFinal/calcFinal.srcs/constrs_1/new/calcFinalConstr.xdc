# Reset (Active-High) mapped to BTN0
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports reset_0]

# Done signal mapped to R14
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports done_0]

# 5-bit Encoded Raw Input mapping
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {encodedRawInput_0[0]}]
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports {encodedRawInput_0[1]}]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {encodedRawInput_0[2]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {encodedRawInput_0[3]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {encodedRawInput_0[4]}]

# I2C Interface (SDA = W9, SCL = Y8)
set_property -dict {PACKAGE_PIN W9 IOSTANDARD LVCMOS33} [get_ports IIC_0_sda_io]
set_property -dict {PACKAGE_PIN Y8 IOSTANDARD LVCMOS33} [get_ports IIC_0_scl_io]

