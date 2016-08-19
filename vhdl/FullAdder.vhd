-- Classical Full Adder (1 bit)
-- 
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity FullAdder is
	port (
		carry_in : in std_logic;
		a : in std_logic;
		b : in std_logic;
		sum : out std_logic;
		carry_out : out std_logic
	);
end FullAdder;

architecture glvl of FullAdder is
begin
	sum <= a xor b xor carry_in;
	carry_out <= (a and b) or (b and carry_in) or (a and carry_in);
end glvl;
