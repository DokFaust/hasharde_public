-- Simple block to pad the (part of the) string with a '1' bit
-- 
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity AutoPadderBlock is
	port (
		wordin : in std_logic_vector(7 downto 0);
		prev : in std_logic;
		isnull : out std_logic;
		output : out std_logic_vector(7 downto 0)
	);
end AutoPadderBlock;

architecture rtl of AutoPadderBlock is
    function OR_REDUCE(ARG: STD_LOGIC_VECTOR) return UX01 is
	variable result: STD_LOGIC;
    begin
	result := '0';
	for i in ARG'range loop
	    result := result or ARG(i);
	end loop;
        return result;
    end;

    function NOR_REDUCE(ARG: STD_LOGIC_VECTOR) return UX01 is
    begin
        return not OR_REDUCE(ARG);
    end;
    signal isnull_bis : std_logic;
begin
	isnull_bis <= nor_reduce(wordin);
	isnull <= isnull_bis;
	output <= wordin when (isnull_bis='0' and prev='0') else
		  X"80" when (isnull_bis='1' and prev='0') else
		  X"00";
end rtl;
