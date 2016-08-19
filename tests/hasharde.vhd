-- Hasharde : Password Cracker for FPGA
--
-- MOCA 2016 Talk "FPGA4Hackers"
-- Author: Walter Tiberti <wtuniv@gmail.com>
-- License: GPLv2

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity hasharde is
	port (
		clk : in std_logic;
		start : in std_logic;
		ready : out std_logic;
		found : out std_logic;
		addr_found : out std_logic_vector(7 downto 0)
		-- Note: additional signals may be needed in some cases
		-- to fill memory with appropriate content
	);
end hasharde;

architecture imp of hasharde is
	component comb_eq is
	generic (
		nbit : integer := 32
	);
	port (
		a : in std_logic_vector(nbit-1 downto 0);
		b : in std_logic_vector(nbit-1 downto 0);
		are_equal : out std_logic
	);
	end component;

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
	signal lenpipo_clk : std_logic;
	signal lenpipo_enable : std_logic;

	signal off_clk : std_logic;
	signal off_rst : std_logic;
	signal off_in : std_logic_vector(7 downto 0);
	signal off_out : std_logic_vector(7 downto 0);
	signal off_enable : std_logic;

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

	signal adder_sum : std_logic_vector(63 downto 0);
	signal adder_co : std_logic;
	signal adder_a : std_logic_vector(63 downto 0);
	signal adder_b : std_logic_vector(63 downto 0);

	component Mux_4to1 is
		generic (
			nbit : integer := 32
		);
		port (
			in0 : in std_logic_vector(nbit-1 downto 0);
			in1 : in std_logic_vector(nbit-1 downto 0);
			in2 : in std_logic_vector(nbit-1 downto 0);
			in3 : in std_logic_vector(nbit-1 downto 0);
			sel : in std_logic_vector(1 downto 0);
			output : out std_logic_vector(nbit-1 downto 0)
		);
	end component;
	signal mux_sel : std_logic_vector(1 downto 0);
	signal mux_out : std_logic_vector(31 downto 0);

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
	signal sha_rst : std_logic;
	signal sha_ready : std_logic;
	signal sha_up : std_logic;
	signal sha_addr : std_logic_vector(3 downto 0);
	signal sha_in : std_logic_vector(31 downto 0);
	signal sha_out : std_logic_vector(255 downto 0);
	signal dbg : std_logic_vector(31 downto 0);

	signal mem_enable : std_logic;
	signal ff : std_logic;
	signal lsb : std_logic_vector(31 downto 0);
	signal msb : std_logic_vector(31 downto 0);
	signal hash_was_found : std_logic;

	signal mux_sel_ff_out : std_logic_vector(1 downto 0);
	signal mux_sel_ff_clk : std_logic;

	-- For testing purposes
	constant target_hash : std_logic_vector(255 downto 0) :=
	x"0620ee600e6340dae9db62ae39a1fb2a90a85b57af66ab22156afe260709a645";

	type state_t is (SLEEP, RESET, PRE_EXEC,
			EXEC, PRE_FILL, FILL, END_FILL, LEN_MSB, LEN_LSB,
			NEXT_STRING, SUCCESS, HASH_READY
			);
	signal state : state_t := SLEEP;
begin
	sha : sha256
	port map (
		clk => clk,
		reset => sha_rst,
		enable => '1',
		ready => sha_ready,
		update => sha_up,
		word_address => sha_addr,
		word_input => sha_in,
		hash_output => sha_out,
		debug_port => dbg
	);

	cmp : comb_eq generic map (nbit => 256)
	port map (
		a => target_hash,
		b => sha_out,
		are_equal => hash_was_found
	);

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
		clk => lenpipo_clk,
		rst => lenpipo_rst,
		enable => '1',
		d => lenpipo_in,
		q => lenpipo_out,
		rst_value => x"0000000000000000"
	);

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

	main_mux : Mux_4to1 generic map (nbit => 32)
	port map (
		in0 => ap_out,
		in1 => lsb,
		in2 => msb,
		in3 => x"00000000",
		sel => mux_sel_ff_out,
		output => mux_out
	);

	mux_sel_ff : reg_pipo generic map (nbit => 2)
	port map (
		clk => mux_sel_ff_clk,
		rst => '0',
		enable => '1',
		d => mux_sel,
		q => mux_sel_ff_out,
		rst_value => "00"
	);

	mem_rw <= '0'; -- For testing purposes
	mem_clk <= (not clk) and mem_enable;
	mem_addr <= offset_add_sum;
	off_clk <= (not clk) and off_enable;
	off_in <= offset_add_sum;

	mux_sel_ff_clk <= not clk;
	lsb <= lenpipo_out(31 downto 0);
	msb <= lenpipo_out(63 downto 32);

	ap_wordin <= mem_dataout;
	codein <= ap_nullchk;
	adder_b <= lenpipo_out;
	lenpipo_in <= adder_sum;
	lenpipo_clk <= clk and lenpipo_enable and (sha_addr(0) or sha_addr(1) or sha_addr(2) or sha_addr(3));
	ff <= (ap_nullchk(0) or ap_nullchk(1) or ap_nullchk(2) or ap_nullchk(3));

	offset_add_b <= "0000" & sha_addr;
	sha_in <= mux_out;

	f_x : process(clk)
	begin
		if rising_edge(clk) then
			case state is
			when SLEEP =>
				if start = '1' then
					state <= RESET;
				end if;

			when RESET =>
				state <= PRE_EXEC;

			when PRE_EXEC =>
				state <= EXEC;

			when EXEC =>
				if ff = '1' then
					state <= PRE_FILL; -- string ended - filling with 0s
				elsif offset_add_b = x"0E" then
					state <= LEN_MSB;
				end if;

			when PRE_FILL =>
				-- Used to store actual offset in mem
				if mem_addr = x"00" then -- memory addr overflow
					state <= END_FILL;
				elsif offset_add_b = x"0E" then
					state <= LEN_MSB;
				end if;
				state <= FILL;

			when LEN_MSB =>
				state <= LEN_LSB;

			when LEN_LSB =>
				state <= END_FILL;

			when FILL =>
				if offset_add_b = x"0D" then
					state <= LEN_MSB;
				end if;

			when END_FILL =>
				-- Waits for ready to be 1
				if sha_ready = '1' then
					state <= HASH_READY;
				end if;

			when HASH_READY =>
				-- TODO : inserire pausa?
				if hash_was_found = '1' then
					state <= SUCCESS;
				else
					state <= NEXT_STRING;
				end if;

			when NEXT_STRING =>
				state <= PRE_EXEC;

			when SUCCESS =>
				state <= SLEEP;

			when others =>
				state <= SLEEP;
			end case;
		end if;
	end process;

	g_x : process(state)
	begin
		case state is
		when SLEEP =>
			mem_enable <= '0';
			off_enable <= '0';
			lenpipo_enable <= '0';
			off_rst <= '0';
			lenpipo_rst <= '0';
			mux_sel <= "11";
			sha_up <= '0';
			sha_rst <= '0';
			ready <= '1';
			found <= '0';
			addr_found <= x"00";

		when RESET =>
			mem_enable <= '0';
			off_enable <= '0';
			lenpipo_enable <= '0';
			off_rst <= '1';
			lenpipo_rst <= '1';
			mux_sel <= "11";
			sha_up <= '0';
			sha_rst <= '1';
			ready <= '0';
			found <= '0';
			addr_found <= x"00";

		when PRE_EXEC =>
			mem_enable <= '1';
			off_enable <= '0';
			lenpipo_enable <= '0';
			off_rst <= '0';
			lenpipo_rst <= '0';
			mux_sel <= "00";
			sha_up <= '1';
			sha_rst <= '0';
			ready <= '0';
			found <= '0';
			addr_found <= x"00";

		when EXEC =>
			mem_enable <= '1';
			off_enable <= '0';
			lenpipo_enable <= '1';
			off_rst <= '0';
			lenpipo_rst <= '0';
			mux_sel <= "00";
			sha_up <= '0';
			sha_rst <= '0';
			ready <= '0';
			found <= '0';
			addr_found <= x"00";

		when PRE_FILL =>
			mem_enable <= '0';
			off_enable <= '1';
			lenpipo_enable <= '0';
			off_rst <= '0';
			lenpipo_rst <= '0';
			mux_sel <= "11";
			sha_up <= '0';
			sha_rst <= '0';
			ready <= '0';
			found <= '0';
			addr_found <= x"00";

		when FILL =>
			mem_enable <= '0';
			off_enable <= '0';
			lenpipo_enable <= '0';
			off_rst <= '0';
			lenpipo_rst <= '0';
			mux_sel <= "11";
			sha_up <= '0';
			sha_rst <= '0';
			ready <= '0';
			found <= '0';
			addr_found <= x"00";

		when LEN_MSB =>
			mem_enable <= '0';
			off_enable <= '0';
			lenpipo_enable <= '0';
			off_rst <= '0';
			lenpipo_rst <= '0';
			mux_sel <= "10";
			sha_up <= '0';
			sha_rst <= '0';
			ready <= '0';
			found <= '0';
			addr_found <= x"00";

		when LEN_LSB =>
			mem_enable <= '0';
			off_enable <= '0';
			lenpipo_enable <= '0';
			off_rst <= '0';
			lenpipo_rst <= '0';
			mux_sel <= "01";
			sha_up <= '0';
			sha_rst <= '0';
			ready <= '0';
			found <= '0';
			addr_found <= x"00";

		when END_FILL =>
			mem_enable <= '0';
			off_enable <= '0';
			lenpipo_enable <= '0';
			off_rst <= '0';
			lenpipo_rst <= '0';
			mux_sel <= "01";
			sha_up <= '0';
			sha_rst <= '0';
			ready <= '0';
			found <= '0';
			addr_found <= x"00";

		when NEXT_STRING =>
			mem_enable <= '0';
			off_enable <= '0';
			lenpipo_enable <= '0';
			off_rst <= '0';
			lenpipo_rst <= '1';
			mux_sel <= "11";
			sha_up <= '0';
			sha_rst <= '1';
			ready <= '0';
			found <= '0';
			addr_found <= x"00";

		when HASH_READY =>
			mem_enable <= '0';
			off_enable <= '0';
			lenpipo_enable <= '0';
			off_rst <= '0';
			lenpipo_rst <= '0';
			mux_sel <= "11";
			sha_up <= '0';
			sha_rst <= '0';
			found <= '0';
			addr_found <= x"00";

		when SUCCESS =>
			mem_enable <= '0';
			off_enable <= '0';
			lenpipo_enable <= '0';
			off_rst <= '0';
			lenpipo_rst <= '0';
			mux_sel <= "11";
			sha_up <= '0';
			sha_rst <= '0';
			ready <= '0';
			found <= '1';
			addr_found <= off_out;

		when others =>
			mem_enable <= '0';
			off_enable <= '0';
			lenpipo_enable <= '0';
			off_rst <= '0';
			lenpipo_rst <= '0';
			mux_sel <= "11";
			sha_up <= '0';
			sha_rst <= '0';
			ready <= '0';
			found <= '0';
			addr_found <= x"00";

		end case;
	end process;
end imp;

