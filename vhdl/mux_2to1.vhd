-- Simple 2-to-1 n-bit Multiplexer
-- 
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity Mux_2to1 is
	generic (
		nbit : integer := 32
	);
	port (
		in0 : in std_logic_vector(nbit-1 downto 0);
		in1 : in std_logic_vector(nbit-1 downto 0);
		sel : in std_logic;
		output : out std_logic_vector(nbit-1 downto 0)
	);
end Mux_2to1;

architecture bhv of Mux_2to1 is
begin
	output <= in0 when sel='0' else
		  in1 when sel='1' else
		  (others=>'0');
end bhv;
