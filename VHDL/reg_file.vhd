library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

Entity reg_file is
port (
clk,rst,R,W,SP_EN : in std_logic;
Rs1,Rs2,Rd : in std_logic_vector(1 downto 0);
data_sp : in std_logic_vector(7 downto 0);
data : in std_logic_vector(7 downto 0);
S1,S2 : out std_logic_vector(7 downto 0));
end entity reg_file;

architecture reg_file_arch of reg_file is
	component my_nDFF  is  
		Generic ( n : integer := 8);
		port( clk,rst,e : in std_logic;
		d : in std_logic_vector(n-1 downto 0);
		q : out std_logic_vector(n-1 downto 0));
	end component ;
	
	signal R0,R1,R2,R3,R3_in:std_logic_vector(7 downto 0);
	signal R0_en,R1_en,R2_en,R3_en:std_logic;
	signal used_clk:std_logic;
begin
	
	
	S1 <= R0 when Rs1 = "00" and R = '1'
	else R1 when Rs1 = "01" and R = '1'
	else R2 when Rs1 = "10" and R = '1'
	else R3 when Rs1 = "11" and R = '1'
	else "00000000";
	
	S2 <= R0 when Rs2 = "00" and R = '1'
	else R1 when Rs2 = "01" and R = '1' 
	else R2 when Rs2 = "10" and R = '1' 
	else R3 when Rs2 = "11" and R = '1'
	else "00000000";
	
	R0_en <= '1' when Rd = "00" and W = '1' and rst = '0'
	else '0';
	R1_en <= '1' when Rd = "01" and W = '1' and rst = '0'
	else '0';
	R2_en <= '1' when Rd = "10" and W = '1' and rst = '0'
	else '0';
	R3_en <= '1' when (Rd = "11" and W = '1' and rst = '0') or SP_EN = '1' or rst='1'
	else '0';
	
	R3_in <= data when Rd = "11" and rst='0'
	else "11111111" when rst='1'
	else data_sp when SP_EN='1';
	
	used_clk <= not clk;
	R0_dest : my_nDFF port map(used_clk,rst,R0_en,data,R0);
	R1_dest : my_nDFF port map(used_clk,rst,R1_en,data,R1);
	R2_dest : my_nDFF port map(used_clk,rst,R2_en,data,R2);
	R3_dest : my_nDFF port map(used_clk,'0',R3_en,R3_in,R3);
end architecture reg_file_arch;
