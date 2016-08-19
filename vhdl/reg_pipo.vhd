-- Simple PIPO register with enable and user-defined reset value
--
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_pipo is
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
end reg_pipo;

architecture gatelvl of reg_pipo is
	signal output : std_logic_vector(nbit-1 downto 0);
begin
	process (clk, rst, enable)
	begin
		if (enable = '0') then
			output <= (others=>'0');
		elsif (rst = '1') then
			output <= rst_value;
		elsif rising_edge(clk) then
			output <= d;
		end if;
	end process;
	
	q <= output;
end gatelvl;

