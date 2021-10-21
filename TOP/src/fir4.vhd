library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- 0.04566357 * 2^6 = 2.92--> 3
-- 0.45433643 * 2^6 = 29.08 --> 29
-- 0.45433643 * 2^6 = 29.08 --> 29
-- 0.04566357 * 2^6 = 2.92--> 3


entity fir4 is
	port(
		-- clock
		clock: in std_logic;
		-- to know when we can accept input data
		data_valid: in std_logic;
		-- coefficients used for FIR filter
		-- input data
		i_data: in std_logic_vector(7 downto 0);
		-- ouput (filtered) data
		o_data: out std_logic_vector(7 downto 0)
	);
end entity fir4;

architecture rtl of fir4 is
	-- we declare types because type mark is expected in a subtype indication
	-- all the coefficients
	type t_coeffs is array (0 to 3) of signed(7 downto 0);
	constant s_coeffs: t_coeffs := (to_signed(3, 8), to_signed(29, 8), to_signed(29, 8), to_signed(3, 8));
	-- all the piped data needed for computation (num piped data = num coefficients)
	type t_pdata is array (0 to 3) of signed(7 downto 0);
	signal s_pdata: t_pdata := (others=>(to_signed(0, 8)));
	-- all the products used for the sum
	-- when multiplying two numbers of n bits, we need 2n bits to represent the sum
	type t_prod is array(0 to 3) of signed(8*2-1 downto 0);
	signal s_prod: t_prod := (others=>(to_signed(0, 8*2)));
	-- we sum with a binary algorithm
    	type t_sum0 is array(0 to 1) of signed(8*2+0 downto 0);
    	signal s_sum0: t_sum0 := (others=>(to_signed(0, 8*2+0+1)));
	signal s_sum1: signed(8*2+1 downto 0);

begin
	p_input: process(clock) is
	begin
		if rising_edge(clock) then
			if data_valid = '1' then
				-- pipe data
				s_pdata <= signed(i_data) & s_pdata(0 to s_pdata'length-2);
			end if;
		end if;
	end process p_input;
	
	p_prod: process(clock) is
	begin
		if rising_edge(clock) then
			if data_valid = '1' then
				for i in 0 to 3 loop
					s_prod(i) <= s_pdata(i) * s_coeffs(i);
				end loop;
			end if;
		end if;
	end process p_prod;
	
	p_sum0: process(clock) is
	begin
		if rising_edge(clock) then
			if data_valid = '1' then
				for i in 0 to 1 loop
					s_sum0(i) <= resize(s_prod(2*i), 2*8+1) 
						+ resize(s_prod(2*i+1), 2*8+1);
				end loop;
			end if;
		end if;
	end process p_sum0;
	
	p_sum1: process(clock) is
	begin
		if rising_edge(clock) then
			if data_valid = '1' then
				s_sum1 <= resize(s_sum0(0), 2*8+2)
					+ resize(s_sum0(1), 2*8+2);
			end if;
		end if;
	end process p_sum1;
	
	p_output: process(clock) is
	begin
		if rising_edge(clock) then
			if data_valid = '1' then
				-- we must lose precision in the 8bits output
				o_data <= std_logic_vector(shift_right(s_sum1, 6)(7 downto 0));
			end if;
		end if;
	end process p_output;
end architecture rtl;
