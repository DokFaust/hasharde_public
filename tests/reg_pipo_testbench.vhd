-- PIPO register testbench
--
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY reg_pipo_testbench IS
END reg_pipo_testbench;

ARCHITECTURE behavior OF reg_pipo_testbench IS
	COMPONENT reg_pipo
	PORT (
		clk : IN std_logic;
		rst : IN std_logic;
		enable : IN std_logic;
		d : IN std_logic_vector(7 downto 0);
		q : OUT std_logic_vector(7 downto 0);
		rst_value : IN std_logic_vector(7 downto 0)
	);
	END COMPONENT;

	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal enable : std_logic := '0';
	signal d : std_logic_vector(7 downto 0) := (others => '0');
	signal rst_value : std_logic_vector(7 downto 0) := (others => '0');
	signal q : std_logic_vector(7 downto 0);
	constant clk_period : time := 10 ns;
BEGIN
	uut: reg_pipo
	PORT MAP (
		clk => clk,
		rst => rst,
		enable => enable,
		d => d,
		q => q,
		rst_value => rst_value
	);

	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	stim_proc: process
	begin
		d <= x"11";
		wait for 12 ns;
		enable <= '0';
		wait for 15 ns;
		enable <= '1';
		wait for 15 ns;

		rst_value <= x"77";
		wait for 10 ns;

		rst <= '1';
		wait for 15 ns;
		rst <= '0';

		wait for 40 ns;
		d <= x"55";
		wait for clk_period*10;
		wait;
	end process;

END;
