-- Simple 4-to-1 n-bit Multiplexer
-- 
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity Mux_4to1 is
	generic (
		nbit : integer := 32
	);
	port (
		in0 : in std_logic_vector(nbit-1 downto 0);
		in1 : in std_logic_vector(nbit-1 downto 0);
		in2 : in std_logic_vector(nbit-1 downto 0);
		in3 : in std_logic_vector(nbit-1 downto 0);
		sel : in std_logic_vector(1 downto 0);
		output : out std_logic_vector(nbit-1 downto 0)
	);
end Mux_4to1;

architecture bhv of Mux_4to1 is
begin
	output <= in0 when sel="00" else
		  in1 when sel="01" else
		  in2 when sel="10" else
		  in3 when sel="11" else
		  (others=>'0');
end bhv;

