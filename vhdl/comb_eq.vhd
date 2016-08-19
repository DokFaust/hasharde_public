-- Simple combinatorial equality comparator
-- 
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity comb_eq is
	generic (
		nbit : integer := 32
	);
	port (
		a : in std_logic_vector(nbit-1 downto 0);
		b : in std_logic_vector(nbit-1 downto 0);
		are_equal : out std_logic
	);
end comb_eq;

architecture glvl of comb_eq is
    function OR_REDUCE(ARG: STD_LOGIC_VECTOR) return UX01 is
	variable result: STD_LOGIC;
    begin
	result := '0';
	for i in ARG'range loop
	    result := result or ARG(i);
	end loop;
        return result;
    end;
    signal xored : std_logic_vector(nbit-1 downto 0);
begin
	main_proc : process(a, b)
	begin
		for i in nbit-1 downto 0 loop
			xored(i) <= a(i) xor b(i);
		end loop;
	end process;
	are_equal <= not or_reduce(xored);
end glvl;

