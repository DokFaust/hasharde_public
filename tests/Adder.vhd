-- Simple Carry Look-Ahead Adder
-- 
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

-- NOTE: It needs some fixes!

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity CLA_Adder is
	generic (
		nbit : integer := 32
	);
	port (
		carry_in : in std_logic;
		a : in std_logic_vector(nbit-1 downto 0);
		b : in std_logic_vector(nbit-1 downto 0);
		sum : out std_logic_vector(nbit-1 downto 0);
		carry_out : out std_logic
	);
end CLA_Adder;

architecture rtl of CLA_Adder is
	component FullAdder is
		port (
			carry_in : in std_logic;
			a : in std_logic;
			b : in std_logic;
			sum : out std_logic;
			carry_out : out std_logic
		);
	end component;

	signal carries_in : std_logic_vector(nbit-1 downto 0);
	signal as : std_logic_vector(nbit-1 downto 0);
	signal bs : std_logic_vector(nbit-1 downto 0);
	signal sums : std_logic_vector(nbit-1 downto 0);
	signal carries_out : std_logic_vector(nbit-1 downto 0);
begin
	ripple : for i in 0 to nbit-1 generate
	begin
		fa : FullAdder
		port map (
			carry_in => carries_in(i),
			a => as(i),
			b => bs(i),
			sum => sums(i),
			carry_out => carries_out(i)
		);
	end generate ripple;

	process(as, bs)
	begin
		-- sum
		for i in 0 to nbit-1 loop
			sums(i) <= as(i) xor bs(i);
		end loop;

		-- carries propagation
		carries_in(0) <= carry_in;
		for i in 0 to nbit-2 loop
			carries_in(i+1) <= (as(i) and bs(i)) or -- G(A,B)
					   ((as(i) xor bs(i)) and carries_in(i)); -- P*C
		end loop;
		carry_out <= carries_out(nbit-1);
	end process;
end rtl;

