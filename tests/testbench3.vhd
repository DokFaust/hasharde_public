-- testbench3 : test on sha block
--
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity testbench3 is
	port (
		hash : out std_logic_vector(255 downto 0);
		rdy : out std_logic;
		addr : out std_logic_vector(7 downto 0)
	);
end testbench3;

architecture imp of testbench3 is
	signal clk : std_logic;
	component sha256 is
		port(
			clk    : in std_logic;
			reset  : in std_logic;
			enable : in std_logic;
			ready  : out std_logic; -- Ready to process the next block
			update : in  std_logic; -- Start processing the next block
			word_address : out std_logic_vector(3 downto 0); -- Word 0 .. 15
			word_input   : in std_logic_vector(31 downto 0);
			hash_output : out std_logic_vector(255 downto 0);
			debug_port : out std_logic_vector(31 downto 0)
		);
	end component;
	signal sha_reset : std_logic;
	signal sha_ready : std_logic;
	signal sha_update : std_logic;
	signal sha_addr : std_logic_vector(3 downto 0);
	signal sha_in : std_logic_vector(31 downto 0);
	signal sha_out : std_logic_vector(255 downto 0);
	signal dbg : std_logic_vector(31 downto 0);

begin
	sha : sha256
	port map (
		clk => clk,
		reset => sha_reset,
		enable => '1',
		ready => sha_ready,
		update => sha_update,
		word_address => sha_addr,
		word_input => sha_in,
		hash_output => sha_out,
		debug_port => dbg
	);

	hash <= sha_out;
	rdy <= sha_ready;
	addr <= "0000" & sha_addr;

	clkproc : process
	begin
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
	end process;

	stim: process
	begin
		sha_reset <= '1';
		wait for 40 ns;
		sha_reset <= '0';
		sha_in <= x"41424380";
		wait for 20 ns;
		sha_update <= '1';
		wait for 20 ns;
		sha_update <= '0';
		wait for 20 ns;
		sha_in <= x"00000000";
		-- wait until sha_ready = '1';
		wait until sha_addr = "1111";
		wait for 5 ns;
		sha_in <= x"00000018";
		wait for 20 ns;
		sha_in <= x"00000000";
		wait;
	end process;
end imp;

