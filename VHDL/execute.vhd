Library ieee;

Use ieee.std_logic_1164.all;

entity execute is
	port( ID_EX : in std_logic_vector(63 downto 0);
	     flags_in : in std_logic_vector(3 downto 0);
	     mem_data : in std_logic_vector(7 downto 0);
	     mem_rd	: in std_logic_vector(1 downto 0);
	     mem_acc_mode : in std_logic_vector(2 downto 0);
	     stall_Rd : in std_logic_vector(1 downto 0);
	     mem_valid : in std_logic;
	     wb_data : in std_logic_vector(7 downto 0);
	     wb_rd : in std_logic_vector(1 downto 0);
	     wb_valid : in std_logic;
	     sp_data : in std_logic_vector(7 downto 0);
	     sp_en : in std_logic;
	     IN_PORT : in std_logic_vector(7 downto 0);
	     EX_MEM : out std_logic_vector(31 downto 0);
	     flags_out : out std_logic_vector(3 downto 0);
	     stall : out std_logic;
	     ret_ex : out std_logic;
	     branch : out std_logic;
	     target_addr : out std_logic_vector(7 downto 0);
	     rti : out std_logic
	     );
end entity execute;
-- Input: ID_EX
-- S1(7-0), Rs1(9-8), S2(17-10), Rs2(19-18), offset(27-20), ALU(31-28), Rd(33-32), offset_en(34), access_mode(37-35),
-- NOP(38), change_flags(39), s1_forward_en(40), s2_forward_en(41), ret(42), branch_mode(45 - 43)
-- branch_rb(47 - 46), target_addr(55 - 48), rti(56), pop_flags(57)
 -- ===============================================================================================
 -- Output: EX_MEM
 -- Result(7-0), data(15-8), Rd(17-16), access_mode(18-20), NOP(21), ret_ex(22), pop_flags(23)
 -- ===============================================================================================
 -- Flags_in and Flags_out
 -- Z(0), N(1), C(2), V(3) 
architecture struct of execute is
	component ALSU  is  
		port (a,b:in std_logic_vector (7 downto 0);
		s : in std_logic_vector(3 downto 0);
		cin : in std_logic;
		F : out std_logic_vector (7 downto 0);
		cout: out std_logic;
		zero : out std_logic;
		negative : out std_logic;
		overflow : out std_logic
		);    
	end component;

	signal alu_b, result : std_logic_vector(7 downto 0);
	signal CCR : std_logic_vector(3 downto 0);
	-- signals for Data Forwardig
	signal s1_tmp, s2_tmp, rb_tmp : std_logic_vector(7 downto 0);
	signal data_haz : std_logic;

begin

-- check if rs1 is being used in forward stages
s1_tmp <= mem_data when  mem_rd = ID_EX(9 downto 8)  and mem_valid = '1' and ID_EX(40) = '1'
	   else wb_data  when  wb_rd  = ID_EX(9 downto 8)  and wb_valid = '1' and mem_rd /= ID_EX(9 downto 8) and ID_EX(40) = '1'
	   else sp_data  when  ID_EX(9 downto 8) = "11" and sp_en = '1' and ID_EX(40) = '1'
	   else ID_EX(7 downto 0);

s2_tmp <= mem_data when  mem_rd = ID_EX(19 downto 18)  and mem_valid = '1' and ID_EX(41) = '1'
	   else wb_data  when  wb_rd  = ID_EX(19 downto 18)  and wb_valid = '1' and mem_rd /= ID_EX(19 downto 18) and ID_EX(41) = '1'
	   else sp_data  when  ID_EX(19 downto 18) = "11" and sp_en = '1' and ID_EX(41) = '1'
	   else ID_EX(17 downto 10);

rb_tmp <= mem_data   when  mem_rd = ID_EX(47 downto 46) and mem_valid = '1'
		 else wb_data  when  wb_rd  = ID_EX(47 downto 46) and wb_valid  = '1' and mem_rd /= ID_EX(47 downto 46)
		 else sp_data  when  ID_EX(47 downto 46) = "11" and sp_en = '1'
		 else ID_EX(55 downto 48); -- target_addr(54 - 47)

---------------------------
alu_b <= s2_tmp when ID_EX(34) = '0'
		else ID_EX(27 downto 20);

alu0 : ALSU port map( s1_tmp , alu_b, ID_EX(31 downto 28), flags_in(2), result, CCR(2), CCR(0), CCR(1), CCR(3) ); 

-- change in ZERO flag
flags_out(0) <= CCR(0) when (ID_EX(31 downto 29) = "001" or ID_EX(31 downto 29) = "010" or ID_EX(31 downto 30) = "10") and ID_EX(38)/='0' and ID_EX(39) = '1'
					 else flags_in(0);

-- change in NEGATIVE flag
flags_out(1) <= CCR(1) when (ID_EX(31 downto 29) = "001" or ID_EX(31 downto 29) = "010" or ID_EX(31 downto 30) = "10") and ID_EX(38)/='0' and ID_EX(39) = '1'
					 else flags_in(1);

-- change in CARY flag
flags_out(2) <= CCR(2) when (ID_EX(31 downto 29) = "001" or ID_EX(31 downto 29) = "011" or ID_EX(31 downto 29) = "101" or ID_EX(31 downto 29) = "110") and ID_EX(38)/='0' and ID_EX(39) = '1'
					 else flags_in(2);

-- change in OVERFLOW flag
flags_out(3) <= CCR(3) when (ID_EX(31 downto 29) = "001" or ID_EX(31 downto 29) = "101") and ID_EX(38)/='0' and ID_EX(39) = '1'
					 else flags_in(3);

-- assigning values to output
EX_MEM( 7 downto 0 ) <= IN_PORT when ID_EX(37 downto 35) = "110"
									 else result; -- result
EX_MEM( 15 downto 8) <= s2_tmp; -- data
EX_MEM(17 downto 16) <= ID_EX(33 downto 32); -- Rd
EX_MEM(20 downto 18) <= ID_EX(37 downto 35); -- access_mode
EX_MEM(21)					 <= ID_EX(38) when data_haz = '0' -- NOP
									 else '0';
EX_MEM(22)					 <= ID_EX(42);				
EX_MEM(23)					 <= ID_EX(57); -- pop_flags			 
EX_MEM(31 downto 24) <= (others => '0');

ret_ex <= ID_EX(42);

branch <= '1' when ID_EX(45 downto 43) = "001" 											 -- JMP 
		 else '1' when ID_EX(45 downto 43) = "010" and flags_in(0) = '1' -- JZ 
		 else '1' when ID_EX(45 downto 43) = "011" and flags_in(1) = '1' -- JN
		 else '1' when ID_EX(45 downto 43) = "100" and flags_in(2) = '1' -- JC
		 else '1' when ID_EX(45 downto 43) = "101" and flags_in(3) = '1' -- JV
		 else '1' when ID_EX(45 downto 43) = "110" and CCR(0) 	   = '0' -- LOOP and Z 
		 else '0';

target_addr <= rb_tmp;

rti					<= ID_EX(56);
------------
data_haz <= '1' when ( (stall_Rd = ID_EX(9 downto 8) and ID_EX(40)='1' )or (stall_Rd = ID_EX(19 downto 18) and ID_EX(41)='1') ) and (mem_acc_mode = "011" or mem_acc_mode ="001") and ID_EX(38)/='0'
			 else '0';

stall <= '1' when data_haz = '1'
		else '0';
end struct;