library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

Entity write_back is
port (
	write_in : in std_logic_vector(31 downto 0);
	clk : in std_logic;
	W,SP_EN :out std_logic;
	Rd :out std_logic_vector(1 downto 0);
	data,SP_in : out std_logic_vector(7 downto 0);
	port_out : out std_logic_vector(7 downto 0);
	valid : out std_logic;
	ret_WB: out std_logic;
	pop_flags : out std_logic
	);
end entity write_back;

architecture write_back_arch of write_back is

	signal read_en,write_en :std_logic;
	signal mfc_out : std_logic;
	signal res,temp_mem_out : std_logic_vector(7 downto 0);
	------------------------Write_back input signals---------------------
	signal NOP,ret_Mem,pop_flags_write : std_logic;
	signal acc_mode : std_logic_vector(2 downto 0);
	signal result,data_in,temp_port : std_logic_vector(7 downto 0);
begin

-- Input: Mem_WB
-- result(7-0), data(15-8), RD(17-16),  acc_mode (20-18) , NOP(21) , ret_Mem(22) , pop_flags(23)
--

	result <= write_in(7 downto 0);
	data_in <= write_in(15 downto 8);
	Rd <= write_in(17 downto 16);
	acc_mode <= write_in(20 downto 18);
	NOP <= write_in(21);
	ret_Mem <= write_in(22);
	pop_flags_write <= write_in(23);
	port_out<= temp_port;
	--------------------------------------------------------------------
	
	SP_EN <= '1' when (acc_mode = "011" or acc_mode = "100") and NOP = '1'
	else '0';
	
	
	data <= result when (acc_mode = "000" or acc_mode = "110") and NOP = '1'
	else data_in when (acc_mode = "001" or acc_mode = "011") and NOP = '1'
	else (others => '0');
	
	SP_in <= result when (acc_mode = "011" or acc_mode = "100") and NOP = '1'
	else (others => '0');
	
	temp_port <= result when acc_mode = "101" and NOP = '1'
	else "11111111" xnor temp_port;
	
	W <= '1' when (acc_mode = "000" or acc_mode = "001" or acc_mode = "011" or acc_mode = "110") and NOP = '1' and ret_Mem/='1' and pop_flags_write/='1'
	else '0';
	
	valid <= NOP when (acc_mode = "000" or acc_mode = "001" or acc_mode = "011" or acc_mode = "100" or acc_mode = "110")
	else '0';
	
	ret_WB <= ret_Mem;		-- signal to indicate that the current instruction is RET 
	pop_flags <= pop_flags_write;	-- signal to write in the flags not registers

end architecture write_back_arch;

--===================Write_back_modes=====================

-- NO MEM
-- 000 | data=result 
--	   | W=1
--	   | SP_EN=0
---------------------------------------------------------
-- load
-- 001 | data=data_in 
--	   | W=1
--	   | SP_EN=0
---------------------------------------------------------
-- store
-- 010 | data=0 
--	   | W=0
--	   | SP_EN=0
---------------------------------------------------
-- pop
-- 011 | data=data_in 
--	   | SP_in=result
--	   | W=1
--	   | SP_EN=1
-------------------------------------------------- 
-- push
-- 100 | data=0 
--	   | SP_in=result
--	   | W=0
--	   | SP_EN=1
-----------------------------------------------
-- port out
-- 101 | data=0
--	   | port_pin=result 
--	   | W=0
--	   | SP_EN=0
--	   | SP_in=0
------------------------------------------------
-- port in
-- 110 | data=result 
--	   | W=1
--	   | SP_EN=0
--	   | SP_in=0
------------------------------------------------
-- carry
-- 111 | data=0
--	   | W=0
--	   | SP_EN=0
--	   | SP_in=0
--	   | port_pin=port_pin 