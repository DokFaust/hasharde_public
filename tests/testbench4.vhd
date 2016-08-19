-- testbench4 : testbench1 + address generation part
--
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity testbench4 is
	port (
		--clk : in std_logic;
		g_wordout : out std_logic_vector(31 downto 0);
		g_nullcheck : out std_logic_vector(3 downto 0)
	);
end testbench4;

architecture imp of testbench4 is
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

	component reg_pipo is
		generic (
			nbit : integer := 8
		);
		port (
			clk : in std_logic;
			rst : in std_logic;
			enable : in std_logic;
			d : in std_logic_vector(nbit-1 downto 0);
			q : out std_logic_vector(nbit-1 downto 0);
			rst_value : in std_logic_vector(nbit-1 downto 0)
		);
	end component;
	signal off_clk : std_logic;
	signal off_rst : std_logic;
	signal off_in : std_logic_vector(7 downto 0);
	signal off_out : std_logic_vector(7 downto 0);

	component RippleAdder is
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
	end component;
	signal offset_add_b : std_logic_vector(7 downto 0);
	signal offset_add_sum : std_logic_vector(7 downto 0);
	signal offset_add_carryout : std_logic;

	--
	signal clk : std_logic;
	signal mem_enable : std_logic;
	signal ff : std_logic;

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

	offset_reg : reg_pipo generic map (nbit => 8)
	port map (
		clk => off_clk,
		rst => off_rst,
		enable => '1',
		d => off_in,
		q => off_out,
		rst_value => x"00"
	);

	offset_add : RippleAdder generic map (nbit => 8)
	port map (
		carry_in => '0',
		a => off_out,
		b => offset_add_b,
		sum => offset_add_sum,
		carry_out => offset_add_carryout
	);


	-- wiring
	ap_wordin <= mem_dataout;
	g_nullcheck <= ap_nullchk;
	g_wordout <= ap_out;

	mem_clk <= clk and mem_enable;
	mem_rw <= '0';

	off_in <= offset_add_sum;
	mem_addr <= offset_add_sum;

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
		off_rst <= '1';
		wait for 5 ns;
		off_rst <= '0';
		wait for 10 ns;
		
		for i in 0 to 15 loop
			offset_add_b <= std_logic_vector(to_unsigned(i, 8));
			ff <= (ap_nullchk(0) or ap_nullchk(1) or ap_nullchk(2) or ap_nullchk(3));
			wait for 20 ns;
		end loop;
		wait;
	end process;
	
	ff_proc : process(clk)
	begin
		if rising_edge(clk) then
			off_clk <= ff;
		end if;
	end process;
end imp;

