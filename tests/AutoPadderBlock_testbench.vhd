LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity AutoPadderBlock_tb is
end AutoPadderBlock_tb;

architecture rtl of AutoPadderBlock_tb is
	component AutoPadderBlock is
		port (
			wordin : in std_logic_vector(7 downto 0);
			prev : in std_logic;
			isnull : out std_logic;
			output : out std_logic_vector(7 downto 0)
		);
	end component;

	signal w : std_logic_vector(31 downto 0) := X"41420000";
	signal aa_out : std_logic_vector(7 downto 0);
	signal bb_out : std_logic_vector(7 downto 0);
	signal cc_out : std_logic_vector(7 downto 0);
	signal dd_out : std_logic_vector(7 downto 0);
	signal aa_isnull : std_logic;
	signal bb_isnull : std_logic;
	signal cc_isnull : std_logic;
	signal dd_isnull : std_logic;

	signal clk : std_logic;
begin
	c_a : AutoPadderBlock
	port map (
		wordin => w(31 downto 24),
		prev => '0',
		isnull => aa_isnull,
		output => aa_out
	);
	c_b : AutoPadderBlock
	port map (
		wordin => w(23 downto 16),
		prev => aa_isnull,
		isnull => bb_isnull,
		output => bb_out
	);
	c_c : AutoPadderBlock
	port map (
		wordin => w(15 downto 8),
		prev => bb_isnull,
		isnull => cc_isnull,
		output => cc_out
	);
	c_d : AutoPadderBlock
	port map (
		wordin => w(7 downto 0),
		prev => cc_isnull,
		isnull => dd_isnull,
		output => dd_out
	);

	process
	begin
		clk <= '1';
		wait for 10 ns;
		clk <= '0';
		wait for 10 ns;
	end process;
end rtl;
