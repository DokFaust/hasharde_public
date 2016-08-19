-- Block that generate the "delta length" in bit given the
-- position of the NUL byte
-- 
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity Gen_Delta is
	port (
		code : in std_logic_vector(3 downto 0);
		output : out std_logic_vector(63 downto 0)
	);
end Gen_Delta;

architecture glvl of Gen_Delta is
begin
	output <= x"0000000000000000" when code(3)='1' else
		  x"0000000000000008" when code(3 downto 2)="01" else
		  x"0000000000000010" when code(3 downto 1)="001" else
		  x"0000000000000018" when code(3 downto 0)="0001" else
		  x"0000000000000020";
end glvl;

