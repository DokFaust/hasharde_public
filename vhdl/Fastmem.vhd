-- Simple Block Ram block
-- 
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FastMem is
	generic (
		n_addr_bit : integer := 4;
		bit_per_word : integer := 8
	);
	port (
		clk : in std_logic;
		rw : in std_logic;
		--start : in std_logic; -- Not needed; It acts up every r-edge
		addr : in std_logic_vector(n_addr_bit-1 downto 0);
		datain : in std_logic_vector(bit_per_word-1 downto 0);
		dataout : out std_logic_vector(bit_per_word-1 downto 0)
	);
end FastMem;

architecture rtl of FastMem is
	constant num_of_words : integer := (2**n_addr_bit);

	subtype tmp is std_logic_vector(bit_per_word-1 downto 0);
	type word_array is array (natural range <>) of tmp;

	signal words : word_array(0 to num_of_words-1);
begin
	process(clk)
	begin
		if (clk='1' and clk'event) then
			if (rw='1') then
				-- write
				dataout <= (others=>'0');
				words(to_integer(unsigned(addr))) <= datain;
			elsif (rw='0') then
				-- read
				dataout <= words(to_integer(unsigned(addr)));
			else
				-- error
				dataout <= (others=>'0');
			end if;
		end if;
	end process;
end rtl;
