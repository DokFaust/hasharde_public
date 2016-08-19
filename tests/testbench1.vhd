-- testbench1 : test on mem and AutoPadder
--
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity testbench1 is
	port (
		--clk : in std_logic;
		g_wordout : out std_logic_vector(31 downto 0);
		g_nullcheck : out std_logic_vector(3 downto 0)
	);
end testbench1;

architecture imp of testbench1 is
	component AutoPadder is
		port (
			wordin : in std_logic_vector(31 downto 0);
			nullcheck : out std_logic_vector(3 downto 0);
			wordout : out std_logic_vector(31 downto 0)
		);
	end component;
	signal ap_wordin : std_logic_vector(31 downto 0);
	signal ap_nullchk : std_logic_vector(3 downto 0);
	signal ap_out : std_logic_vector(31 downto 0);

	component TestMem is
		generic (
			n_addr_bit : integer := 4;
			bit_per_word : integer := 8
		);
		port (
			clk : in std_logic;
			rw : in std_logic;
			--start : in std_logic;
			addr : in std_logic_vector(n_addr_bit-1 downto 0);
			datain : in std_logic_vector(bit_per_word-1 downto 0);
			dataout : out std_logic_vector(bit_per_word-1 downto 0)
		);
	end component;
	signal mem_clk : std_logic;
	signal mem_rw : std_logic;
	signal mem_addr : std_logic_vector(7 downto 0);
	signal mem_datain : std_logic_vector(31 downto 0);
	signal mem_dataout : std_logic_vector(31 downto 0);

	--
	signal clk : std_logic;
	signal mem_enable : std_logic;

begin
	mem : TestMem generic map (n_addr_bit => 8, bit_per_word => 32)
	port map (
		clk => mem_clk,
		rw => mem_rw,
		addr => mem_addr,
		datain => mem_datain,
		dataout => mem_dataout
	);

	autopad : AutoPadder
	port map (
		wordin => ap_wordin,
		nullcheck => ap_nullchk,
		wordout => ap_out
	);

	-- wiring
	ap_wordin <= mem_dataout;
	g_nullcheck <= ap_nullchk;
	g_wordout <= ap_out;

	mem_clk <= clk and mem_enable;
	mem_rw <= '0';

	clkproc : process
	begin
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
	end process;

	stim: process
	begin
		mem_enable <= '1';
		wait for 10 ns;
		for i in 0 to 255 loop
			mem_addr <= std_logic_vector(to_unsigned(i, 8));
			wait for 20 ns;
		end loop;
		wait;
	end process;
end imp;

