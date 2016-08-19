library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FastMem_testbench is
end FastMem_testbench;

architecture sim of FastMem_testbench is
	component FastMem is
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
	
	signal clk : std_logic;
	signal mem_rw : std_logic;
	signal mem_addr : std_logic_vector(3 downto 0);
	signal d : std_logic_vector(7 downto 0);
	signal q : std_logic_vector(7 downto 0);

begin
	mem : FastMem
	port map (
		clk => clk,
		rw => mem_rw,
		addr => mem_addr,
		datain => d,
		dataout => q
	);

	process
	begin
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
	end process;

	stim : process
	begin
		wait for 35 ns;
		mem_rw <= '1';
		mem_addr <= x"5";
		d <= x"DA";
		wait for 20 ns;
		mem_addr <= x"2";
		d <= x"89";
		wait for 20 ns;
		mem_rw <= '0';
	end process;
end sim;

