-- testbench2 : test on gen_delta, pipo and adder
--
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity testbench2 is
	port (
		lsb : out std_logic_vector(31 downto 0);
		msb : out std_logic_vector(31 downto 0)
	);
end testbench2;

architecture imp of testbench2 is
	component Gen_Delta is
		port (
			code : in std_logic_vector(3 downto 0);
			output : out std_logic_vector(63 downto 0)
		);
	end component;
	signal codein : std_logic_vector(3 downto 0);

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
	signal lenpipo_in : std_logic_vector(63 downto 0);
	signal lenpipo_out : std_logic_vector(63 downto 0);
	signal lenpipo_rst : std_logic;

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
	signal adder_sum : std_logic_vector(63 downto 0);
	signal adder_co : std_logic;
	signal adder_a : std_logic_vector(63 downto 0);
	signal adder_b : std_logic_vector(63 downto 0);




	signal clk : std_logic;
begin
	gen : Gen_Delta port map (codein, adder_a);

	adder : RippleAdder generic map (nbit => 64)
	port map (
		carry_in => '0',
		a => adder_a,
		b => adder_b,
		sum => adder_sum,
		carry_out => adder_co
	);

	lenpipo : reg_pipo generic map (nbit => 64)
	port map (
		clk => clk,
		rst => lenpipo_rst,
		enable => '1',
		d => lenpipo_in,
		q => lenpipo_out,
		rst_value => x"0000000000000000"
	);

	lsb <= lenpipo_out(31 downto 0);
	msb <= lenpipo_out(63 downto 32);
	adder_b <= lenpipo_out;
	lenpipo_in <= adder_sum;

	clkproc : process
	begin
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
	end process;

	stim: process
	begin
		codein <= "0000";
		
		lenpipo_rst <= '1';
		wait for 5 ns;
		lenpipo_rst <= '0';
		wait for 5 ns;

		codein <= "0000";
		wait for 50 ns;

		codein <= "0011";
		wait for 20 ns;

		codein <= "1111";
		wait;
	end process;
end imp;

