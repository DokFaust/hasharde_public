-- Simple Ripple Adder
-- 
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity RippleAdder is
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
end RippleAdder;

architecture rtl of RippleAdder is
	component FullAdder is
		port (
			carry_in : in std_logic;
			a : in std_logic;
			b : in std_logic;
			sum : out std_logic;
			carry_out : out std_logic
		);
	end component;

	signal as : std_logic_vector(nbit-1 downto 0);
	signal bs : std_logic_vector(nbit-1 downto 0);
	signal sums : std_logic_vector(nbit-1 downto 0);
	signal carries_out : std_logic_vector(nbit-1 downto 0);
begin
	fazero : FullAdder
	port map (
		carry_in => Carry_In,
		a => as(0),
		b => bs(0),
		sum => sums(0),
		carry_out => carries_out(0)
	);

	ripple : for i in 1 to nbit-1 generate
	begin
		fa : FullAdder
		port map (
			carry_in => carries_out(i-1),
			a => as(i),
			b => bs(i),
			sum => sums(i),
			carry_out => carries_out(i)
		);
	end generate ripple;

	as <= a;
	bs <= b;
	sum <= sums;
	carry_out <= carries_out(nbit-1);
end rtl;

