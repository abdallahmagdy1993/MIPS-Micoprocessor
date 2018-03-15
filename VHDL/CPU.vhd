Library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

Entity CPU is
port(clk,rst: in std_logic;
	INT_IN : in std_logic;
	IN_PORT : in std_logic_vector(7 downto 0);
	OUT_PORT : out std_logic_vector(7 downto 0));   
end CPU;

Architecture arch of CPU is
	
	Component my_nDFF is
		Generic ( n : integer := 8);
		port( clk,rst,e : in std_logic;
		d : in std_logic_vector(n-1 downto 0);
		q : out std_logic_vector(n-1 downto 0));
	end Component;

	
	component reg_file is
		port (
		clk,rst,R,W,SP_EN : in std_logic;
		Rs1,Rs2,Rd : in std_logic_vector(1 downto 0);
		data_sp : in std_logic_vector(7 downto 0);
		data : in std_logic_vector(7 downto 0);
		S1,S2 : out std_logic_vector(7 downto 0));
	end component;

	component inst_ram is
	 port (
		clk : in std_logic;
		R : in std_logic;
		address : in std_logic_vector(7 downto 0);
		dataout : out std_logic_vector(7 downto 0) ;
		MFC : out std_logic);
	end component;

	
	component CU is
		port(clk,rst,INT_IN,stall,ret_Ex,ret_Mem,ret_WB,branch,EX_RTI: in std_logic;
		ret_PC : in std_logic_vector(7 downto 0);
		target_address: in std_logic_vector(7 downto 0);
		IF_ID: in std_logic_vector(31 downto 0);
		reg_R,inst_R,stall_en,IR_rst,f1_en,f2_en,imm_en: out std_logic;
		Rs1,Rs2,Rd: out std_logic_vector(1 downto 0);
		acc_mode :out std_logic_vector(2 downto 0);
		NOP,offset_en: out std_logic;
		offset : out std_logic_vector(7 downto 0);
		alu_op : out std_logic_vector(3 downto 0);
		change_flags : out std_logic;
		branch_mode	: out std_logic_vector(2 downto 0);
		ret : out std_logic;
		PC_src: out std_logic;
		push_PC,push_flags: out std_logic;
		return_address : out std_logic_vector(7 downto 0);
		return_address_src,flags_src : out std_logic;
		pre_RTI,pre_pop_flags : out std_logic;
		PCin : out std_logic_vector(7 downto 0)
		);   
	end component;

	-- Input: ID_EX
	-- S1(7-0), Rs1(9-8), S2(17-10), Rs2(19-18), offset(27-20), ALU(31-28), Rd(33-32), offset_en(34), access_mode(37-35),
	-- NOP(38), change_flags(39), s1_forward_en(40), s2_forward_en(41), ret(42), branch_mode(45 - 43)
	-- branch_rb(47 - 46), target_addr(55 - 48), rti(56), pop_flags(57)
	component execute is
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
	end component;
	-- Output: EX_MEM
 	-- Result(7-0), data(15-8), Rd(17-16), access_mode(18-20), NOP(21), ret_ex(22), pop_flags(23)

	
	-- Input: EX_MEM
	 -- Result(7-0), data(15-8), Rd(17-16), acc_mode (20-18) , NOP(21) , ret_Ex(22) , pop_flags(23)
	component memory_access is
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
	end component;
	--Output: Mem_WB
	-- result(7-0), data(15-8), RD(17-16),  acc_mode (20-18) , NOP(21) , ret_Mem(22) , pop_flags(23)
	
	-- Input: Mem_WB
	-- result(7-0), data(15-8), RD(17-16),  acc_mode (20-18) , NOP(21) , ret_Mem(22) , pop_flags(23)
	component write_back is
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
	end component;

	signal IF_IDin,IF_ID : std_logic_vector(31 downto 0);
	signal ID_EXin,ID_EX : std_logic_vector(63 downto 0);
	signal EX_MEMin,EX_MEM : std_logic_vector(31 downto 0);
	signal MEM_WBin,MEM_WB : std_logic_vector(31 downto 0);
	signal PC,PCin: std_logic_vector(7 downto 0) ;
	signal IR,offset :std_logic_vector(7 downto 0) ;
	signal flags_in,flags :std_logic_vector(3 downto 0) ;
	signal inst_MFC,inst_R : std_logic;
	---- register file signals
	signal reg_R,reg_W,SP_EN : std_logic;
	signal Rs1,Rs2,Rd:std_logic_vector(1 downto 0);
	signal S1,S2,SP_IN:std_logic_vector(7 downto 0);
	---- ID_EX signals
	signal NOP,offset_en,change_flags: std_logic;
	signal acc_mode:std_logic_vector(2 downto 0);
	signal alu_op:std_logic_vector(3 downto 0);
	signal f1_en,f2_en :std_logic;
	---- forwarding signals
	signal MEM_valid,WB_valid : std_logic;
	signal MEM_data,WB_data : std_logic_vector(7 downto 0);
	signal MEM_Rd,WB_Rd : std_logic_vector(1 downto 0);
	signal MEM_acc_mode : std_logic_vector(2 downto 0);
	-- stall signals
	signal stall_en,stall,IR_rst : std_logic;
	signal stall_Rd : std_logic_vector(1 downto 0);
	-- L-format signals
	signal imm_en:std_logic;
	---------------------------------------------------------------------------------------
	-- B-format signals
	signal ret,ret_Ex,ret_Mem,ret_WB,branch,PC_src: std_logic;
	signal branch_mode:std_logic_vector (2 downto 0);
	signal target_address: std_logic_vector(7 downto 0);
	-- INT signals
	signal push_PC, push_flags : std_logic;
	signal return_address: std_logic_vector(7 downto 0);
	signal return_address_src,flags_src,RTI,pop_flags: std_logic;
	signal flags_input : std_logic_vector(3 downto 0 );
	signal pre_RTI,pre_pop_flags,EX_RTI :std_logic;

begin
	
-------------------------------------------------------------- Fetch -------------------------------------------------------------------
PC_reg: my_nDFF generic map(8) port map(clk,rst,'1',PCin,PC);	-- PC
inst_mem: inst_ram port map(clk,inst_R,PCin,IR,inst_MFC);	-- instruction memory
-- IF_ID : PC|IR
IF_IDin(31 downto 26) <= (others => '0');
IF_IDin(25 downto 18) <= return_address;
IF_IDin(17) <= push_PC;
IF_IDin(16) <= push_flags;
IF_IDin(15 downto 8) <= IR-1 when rst='1'		-- high byte of IF_ID register = PC is loaded from mem[0]
else PCin;	
IF_IDin(7 downto 0)	<= "00000000" when rst='1' or IR_rst='1'	-- low byte of IF_ID register = IR
else IR;	
IF_ID_reg: my_nDFF generic map(32) port map(clk,'0',stall_en,IF_IDin,IF_ID);	-- IF_ID register
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------- Decode -------------------------------------------------------------------
CU_comp: CU port map(clk,rst,INT_IN,stall,ret_Ex,ret_Mem,ret_WB,branch,EX_RTI,WB_data,target_address,IF_ID,reg_R,inst_R,stall_en,IR_rst,f1_en,f2_en,imm_en,Rs1,Rs2,Rd,acc_mode,NOP,offset_en,offset,alu_op,change_flags,branch_mode,ret,PC_src,push_PC,push_flags,return_address,return_address_src,flags_src,pre_RTI,pre_pop_flags,PCin);	-- Control Unit
Registers_file: reg_file port map(clk,rst,reg_R,reg_W,SP_EN,Rs1,Rs2,WB_Rd,SP_IN,WB_data,S1,S2);	-- Registers file
ID_EXin(7 downto 0) <= IR when imm_en='1'
else S1;
ID_EXin(9 downto 8) <= Rs1;
ID_EXin(17 downto 10) <= return_address when return_address_src='1'
else "0000" & flags_input when flags_src='1'
else PCin when PC_src='1'
else S2;
ID_EXin(19 downto 18) <= Rs2;
ID_EXin(27 downto 20) <= offset;
ID_EXin(31 downto 28) <= alu_op;
ID_EXin(33 downto 32) <= Rd;
ID_EXin(34) <= offset_en;
ID_EXin(37 downto 35) <= acc_mode;
ID_EXin(38) <= NOP;
ID_EXin(39) <= change_flags;
ID_EXin(40) <= f1_en;
ID_EXin(41) <= f2_en;
ID_EXin(42) <= ret;
ID_EXin(45 downto 43) <= branch_mode;
ID_EXin(47 downto 46) <= Rs2;
ID_EXin(55 downto 48) <= S2;
ID_EXin(56) <= pre_RTI;
ID_EXin(57) <= pre_pop_flags;
ID_EXin(63 downto 58) <= (others => '0');
ID_EX_reg: my_nDFF generic map(64) port map(clk,rst,stall_en,ID_EXin,ID_EX);	-- ID_EX register
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------- Execute ------------------------------------------------------------------
Eexecute_unit: execute port map(ID_EX,flags,MEM_data,MEM_Rd,MEM_acc_mode,stall_Rd,MEM_valid,WB_data,WB_Rd,WB_valid,SP_IN,SP_EN,IN_PORT,EX_MEMin,flags_in,stall,ret_Ex,branch,target_address,EX_RTI);	-- execute unit
flags_input <= WB_data(3 downto 0) when pop_flags='1'
else flags_in;
flags_reg: my_nDFF generic map(4) port map(clk,rst,'1',flags_input,flags);	-- EX_MEM register
EX_MEM_reg: my_nDFF generic map(32) port map(clk,rst,'1',EX_MEMin,EX_MEM);	-- EX_MEM register
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------- Memory Access ------------------------------------------------------------
memory_access_unit: memory_access port map(EX_MEM,clk,MEM_WBin,MEM_Rd,MEM_data,MEM_acc_mode,stall_Rd,MEM_valid,ret_Mem);	-- memory access unit
MEM_WB_reg: my_nDFF generic map(32) port map(clk,rst,'1',MEM_WBin,MEM_WB);	-- MEM_WB register
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------- Write back ---------------------------------------------------------------
write_back_unit: write_back port map(MEM_WB,clk,reg_W,SP_EN,WB_Rd,WB_data,SP_IN,OUT_PORT,WB_valid,ret_WB,pop_flags);	-- write back unit
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
end arch;