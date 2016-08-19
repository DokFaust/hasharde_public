-- Hasharde : Main testbench
--
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity final_testbench is
end final_testbench;

architecture imp of final_testbench is
	component hasharde is
		port (
			clk : in std_logic;
			start : in std_logic;
			ready : out std_logic;
			found : out std_logic;
			addr_found : out std_logic_vector(7 downto 0)
		);
	end component;
	signal clk : std_logic;
	signal hh_start : std_logic;
	signal hh_ready : std_logic;
	signal hh_found : std_logic;
	signal hh_addr : std_logic_vector( 7 downto 0);
begin
	hh : hasharde
	port map (
		clk => clk,
		start => hh_start,
		ready => hh_ready,
		found => hh_found,
		addr_found => hh_addr
	);

	clk_proc : process
	begin
		clk <= '1';
		wait for 10 ns;
		clk <= '0';
		wait for 10 ns;
	end process;

	stim_proc : process
	begin
		wait for 40 ns;
		hh_start <= '1';
		wait for 20 ns;
		hh_start <= '0';
		wait until hh_ready = '1';
	end process;
end imp;

