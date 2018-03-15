library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

Entity memory_access is
port (
mem_in : in std_logic_vector(31 downto 0);
clk : in std_logic;
mem_out : out std_logic_vector(31 downto 0);
MEM_RD : out std_logic_vector(1 downto 0);
MEM_data :out std_logic_vector(7 downto 0);
MEM_acc_mode :out std_logic_vector(2 downto 0);
stall_Rd : out std_logic_vector(1 downto 0);
valid : out std_logic;
ret_Mem: out std_logic
);
end entity memory_access;

architecture memory_access_arch of memory_access is
	component data_ram  is  
	port (
		clk : in std_logic;
		R,W : in std_logic;
		address : in std_logic_vector(7 downto 0);
		datain : in std_logic_vector(7 downto 0);
		dataout : out std_logic_vector(7 downto 0) ;
		MFC : out std_logic);
	end component ;
	
	signal read_en,write_en :std_logic;
	signal mfc_out : std_logic;
	signal res,temp_mem_out : std_logic_vector(7 downto 0);
	------------------------Memory input signals---------------------
	signal NOP,ret_Ex: std_logic;
	signal acc_mode : std_logic_vector(2 downto 0);
	signal RD : std_logic_vector(1 downto 0);
	signal result,data : std_logic_vector(7 downto 0);
begin

 -- Input: EX_MEM
 -- Result(7-0), data(15-8), Rd(17-16), acc_mode (20-18) , NOP(21) , ret_Ex(22) , pop_flags(23)
 --
	result <= mem_in(7 downto 0);
	data <= mem_in(15 downto 8);
	RD <= mem_in(17 downto 16);
	acc_mode <= mem_in(20 downto 18);
	NOP <= mem_in(21);
	ret_Ex <= mem_in(22);
--Output: Mem_WB
-- result(7-0), data(15-8), RD(17-16),  acc_mode (20-18) , NOP(21) , ret_Mem(22) , pop_flags(23)
--
	mem_out(31 downto 24)<= (others => '0');
	mem_out (23) <= mem_in(23);
	mem_out(22) <= ret_Ex;
	mem_out(21) <= NOP;
	mem_out(20 downto 18) <= acc_mode when NOP='1'
	else (others => '0');
	mem_out(17 downto 16) <= RD when NOP='1'
	else (others => '0');
	mem_out(15 downto 8) <= temp_mem_out when NOP='1' and read_en='1'
	else (others => '0');
	
	mem_out(7 downto 0) <= res when NOP='1'
	else (others => '0');
	
	read_en <= '1' when (acc_mode = "001" or acc_mode = "011") and NOP = '1' 
	else '0';
	
	write_en <= '1' when (acc_mode = "010" or acc_mode = "100") and NOP = '1' 
	else '0';

	res <= std_logic_vector(unsigned(result)-1) when acc_mode = "100" and NOP = '1' 
	else result;
	
	MEM_RD <= RD when (acc_mode = "000" or acc_mode = "110") and NOP = '1' --no mem case and port in case
	else "11" when (acc_mode = "011" or acc_mode = "100") and NOP = '1' --pop and push (stack ptr)
	else "00";
	
	MEM_data <= res when (acc_mode = "000" or acc_mode = "011" or acc_mode = "100" or acc_mode = "110") and NOP = '1' --no mem case or pop case or push case or port in case
	else (others => '0');
	
	valid <= NOP when (acc_mode = "000" or acc_mode = "011" or acc_mode = "100" or acc_mode = "110")
	else '0';
	
	MEM_acc_mode <= acc_mode when NOP='1'
	else (others => '0');

	stall_Rd <= RD when NOP='1'
	else "00";
	
	ret_Mem <= ret_Ex;		-- signal to indicate that the current instruction is RET 
	mem_acc: data_ram port map(clk,read_en,write_en,result,data,temp_mem_out,mfc_out);
	
end architecture memory_access_arch;

--===================Access_Memory_modes=====================

-- NO MEM
-- 000 | R=0 
--	   | W=0
--	   | res=result
---------------------------------------------------------
-- load
-- 001 | R=1 
--	   | W=0
--	   | res=result
---------------------------------------------------------
-- store
-- 010 | R=0 
--	   | W=1
--	   | res=result
---------------------------------------------------
-- pop
-- 011 | R=1 
--	   | W=0
--	   | res=result
-------------------------------------------------- 
-- push
-- 100 | R=0 
--	   | W=1
--	   | res=result-1
-----------------------------------------------
-- port out
-- 101 | R=0 
--	   | W=0
--	   | res=result
------------------------------------------------
-- port in
-- 110 | R=0 
--	   | W=0
--	   | res=result
------------------------------------------------
-- carry
-- 111 | R=0 
--	   | W=0
--	   | res=result