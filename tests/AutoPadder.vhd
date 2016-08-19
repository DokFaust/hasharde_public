-- Simple block to pad the (part of the) string with a '1' bit
-- (Composition of AutoPadderBlock)
-- 
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity AutoPadder is
	port (
		wordin : in std_logic_vector(31 downto 0);
		nullcheck : out std_logic_vector(3 downto 0);
		wordout : out std_logic_vector(31 downto 0)
	);
end AutoPadder;

architecture rtl of AutoPadder is
	component AutoPadderBlock is
		port (
			wordin : in std_logic_vector(7 downto 0);
			prev : in std_logic;
			isnull : out std_logic;
			output : out std_logic_vector(7 downto 0)
		);
	end component;

	signal aa_out : std_logic_vector(7 downto 0);
	signal bb_out : std_logic_vector(7 downto 0);
	signal cc_out : std_logic_vector(7 downto 0);
	signal dd_out : std_logic_vector(7 downto 0);
	signal aa_isnull : std_logic;
	signal bb_isnull : std_logic;
	signal cc_isnull : std_logic;
	signal dd_isnull : std_logic;
begin
	c_a : AutoPadderBlock
	port map (
		wordin => wordin(31 downto 24),
		prev => '0',
		isnull => aa_isnull,
		output => aa_out
	);
	c_b : AutoPadderBlock
	port map (
		wordin => wordin(23 downto 16),
		prev => aa_isnull,
		isnull => bb_isnull,
		output => bb_out
	);
	c_c : AutoPadderBlock
	port map (
		wordin => wordin(15 downto 8),
		prev => bb_isnull,
		isnull => cc_isnull,
		output => cc_out
	);
	c_d : AutoPadderBlock
	port map (
		wordin => wordin(7 downto 0),
		prev => cc_isnull,
		isnull => dd_isnull,
		output => dd_out
	);

	nullcheck <= aa_isnull & bb_isnull & cc_isnull & dd_isnull;
	wordout <= aa_out & bb_out & cc_out & dd_out;
end rtl;
