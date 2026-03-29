-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
-- Date        : Sat Mar 28 01:32:33 2026
-- Host        : LAPTOP-QR3M58JR running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Vivado/FPGA/lab_Practise_PYNQ/misc_0/calcFinal/calcFinal.gen/sources_1/bd/design_1/ip/design_1_parent_0_0/design_1_parent_0_0_stub.vhdl
-- Design      : design_1_parent_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_parent_0_0 is
  Port ( 
    clockIn : in STD_LOGIC;
    reset : in STD_LOGIC;
    encodedRawInput : in STD_LOGIC_VECTOR ( 4 downto 0 );
    done : out STD_LOGIC;
    axiOut : out STD_LOGIC_VECTOR ( 319 downto 0 )
  );

  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of design_1_parent_0_0 : entity is "design_1_parent_0_0,parent,{}";
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of design_1_parent_0_0 : entity is "design_1_parent_0_0,parent,{x_ipProduct=Vivado 2025.1,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=parent,x_ipVersion=1.0,x_ipCoreRevision=4,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,buttons=27,page=16,depth=32,width=8,newWidth=44,freq=50000000,debounceTime=10}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of design_1_parent_0_0 : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of design_1_parent_0_0 : entity is "package_project";
end design_1_parent_0_0;

architecture stub of design_1_parent_0_0 is
  attribute syn_black_box : boolean;
  attribute black_box_pad_pin : string;
  attribute syn_black_box of stub : architecture is true;
  attribute black_box_pad_pin of stub : architecture is "clockIn,reset,encodedRawInput[4:0],done,axiOut[319:0]";
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of reset : signal is "xilinx.com:signal:reset:1.0 reset RST";
  attribute X_INTERFACE_MODE : string;
  attribute X_INTERFACE_MODE of reset : signal is "slave";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of reset : signal is "XIL_INTERFACENAME reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of stub : architecture is "parent,Vivado 2025.1";
begin
end;
