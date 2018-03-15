Library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

Entity CU is
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
end entity CU;
-- input
-- IR(7 downto 0) , PC(15 downto 8) , pushFlags(16) , pushPC(17) , return_address(25 downto 18)

Architecture arch of CU is
	

	signal Ra,Rb : std_logic_vector(1 downto 0);
	signal opcode : std_logic_vector(3 downto 0);
	signal INT : std_logic;
	signal fetch_pushPC,fetch_pushFlags:std_logic;
	signal fetch_returnAddress: std_logic_vector(7 downto 0);
	signal exception,used_INT: std_logic;
begin
	

	-- checks for INT_IN signal
	process	(used_INT, rst,clk) is
		begin
		if rst = '1' or (INT = '1' and clk='1')  then
			INT <= '0';
		elsif(rising_edge(used_INT)) then
		  INT<='1';
		end if;
	end process;

	-- throw exception in case of undefined code
	exception <= '1' when opcode="1111" and rst='0'
	else '0';

	used_INT <= exception or INT_IN;

	opcode <= IF_ID(7 downto 4) when fetch_pushPC/='1' and fetch_pushFlags/='1'
	else "0000";
	Ra <= IF_ID(3 downto 2);
	Rb <= IF_ID(1 downto 0);	
	fetch_pushFlags <= IF_ID(16);
	fetch_pushPC <= IF_ID(17);
	fetch_returnAddress <= IF_ID(25 downto 18);

	-- next PC
	PCin <= IF_ID(7 downto 0) when fetch_pushFlags='1' and rst='0'				-- load PC form M[1] in case of INT
	else "00000001" when INT='1' and rst='0'									-- load new address from M[1]
	else target_address when branch='1' and rst='0'								-- load new PC in case of branch
	else ret_PC when ret_WB='1' and rst='0'										-- load PC from stack in RET instruction
	else IF_ID(15 downto 8) when rst='0' and (stall='1' or fetch_pushPC='1')	-- don't change the PC
	else IF_ID(15 downto 8)+1 ;													-- PC=PC+1

	-- push_flags in case of INT
	push_flags <= '1' when INT='1'
	else '0';

	-- pushPC in case of INT
	push_PC <='1' when fetch_pushFlags = '1'
	else '0';

	-- save next instructions
	return_address <= IF_ID(15 downto 8)+1 when INT='1'
	else fetch_returnAddress when fetch_pushFlags='1' or fetch_pushPC='1'
	else "00000000";

	-- read return address as S2 (interrupt)
	return_address_src <= '1' when fetch_pushPC='1'
	else '0'; 


	-- read S2 as flags
	flags_src <= '1' when fetch_pushFlags='1'
	else '0';


	-- read PC as S2 (Call)
	PC_src <= '1' when (opcode="1011" and Ra="01")	-- CALL instructions
	else '0';

	-- pre_RTI
	pre_RTI <= '1' when opcode="1011" and Ra="11"
	else '0';

	-- pre_pop_flags
	pre_pop_flags <= '1' when EX_RTI='1'
	else '0';


	-- rst for IR in case of reading 2 bytes in memory (L-format) , branch is taken , RET
	IR_rst <= '1' when (opcode="1100" or (opcode="1011" and Ra="10") or ret_Ex='1' or ret_Mem='1' or fetch_pushFlags='1') and rst='0'
	else '0';

	-- ret in case of RET
	ret <= '1' when ((opcode="1011" and Ra="10") or (opcode="1011" and Ra="11")) and rst='0'
	else '0';

	-- instruction ram read signal
	inst_R <= '0' when stall='1'
	else '1';

	-- IF_ID register enable
	stall_en <= '0' when stall='1'
	else '1';

	-- source operands indeces
	Rs1 <= "11" when (opcode="0111" and Ra="00") or (opcode="0111" and Ra="01") or	(opcode="1011" and Ra="01") or (opcode="1011" and Ra="10") or fetch_pushFlags='1' or fetch_pushPC='1' or EX_RTI='1' or (opcode="1011" and Ra="11") -- S1=SP in case of push,pop,CALL,RET,INT
	else Ra;
	Rs2 <= Rb;


	-- enable the forwarding in Rs1
	f1_en<='0' when opcode="0110" or (opcode="0111" and Ra="10") or (opcode="0111" and Ra="11") or opcode="1000" or opcode="1001" or (opcode="1011" and Ra="00") or opcode="1100" -- 2 bytes instruction in L-format
	else '1';

	-- enable the forwarding in Rs2
	f2_en<='0' when (opcode="0110" and Ra="10") or (opcode="0110" and Ra="11") or (opcode="0111" and Ra="01") or (opcode="0111" and Ra="11") or (opcode="1011" and Ra="01") or (opcode="1011" and Ra="10") or (opcode="1011" and Ra="11") or  (opcode="1100" and Ra="00") or (opcode="1100" and Ra="01") or (opcode="1101") or fetch_pushFlags='1' or fetch_pushPC='1' or  EX_RTI='1' 	-- CALL,INT_IN,LDI,LDM,LDD,POP
	else '1';

	-- destination index
	Rd <= Ra when opcode="0000" or opcode="0001" or opcode="0010" or opcode="0011" or opcode="0100" or opcode="0101" or opcode="1010"
	else Rb when opcode="0110" or opcode="0111" or opcode="1000" or opcode="1100" or opcode="1101" or opcode="1110"
	else "00";
	
	reg_R <= '1';

	-- acc_mode for memory_access and write_back
	acc_mode <= "111" when (opcode="0110" and Ra="10") or (opcode="0110" and Ra="11")	-- carry mode
	else "110" when (opcode="0111" and Ra="11") -- IN PORT
	else "101" when (opcode="0111" and Ra="10") -- OUT PORT
	else "100" when (opcode="0111" and Ra="00") or (opcode="1011" and Ra="01") or fetch_pushFlags='1' or fetch_pushPC='1'	-- Push,CALL,INT
	else "011" when (opcode="0111" and Ra="01") or (opcode="1011" and Ra="10") or (opcode="1011" and Ra="11") or EX_RTI='1'	-- Pop,RET,RTI
	else "010" when (opcode="1100" and Ra="10") or opcode="1110" -- store
	else "001" when (opcode="1100" and Ra="01") or opcode="1101" -- load
	else "000";	-- no MEM
	

	-- branch_mode for the execute unit to check for the branch condition
	branch_mode <= "001" when (opcode="1011" and Ra="00") or (opcode="1011" and Ra="01")	-- JMP,CALL
	else "010" when opcode="1001" and Ra="00"	-- JZ
	else "011" when opcode="1001" and Ra="01"	-- JN
	else "100" when opcode="1001" and Ra="10"	-- JC
	else "101" when opcode="1001" and Ra="11"	-- JV
	else "110" when opcode="1010"				-- LOOP
	else "000";									-- NO JMP

		
	-- NOP is active low
	NOP <= '0' when (opcode="0000" or rst='1' or opcode="1001" or (opcode="1011" and Ra="00") or branch='1' or exception='1') and fetch_pushPC/='1' and fetch_pushFlags/='1'	and EX_RTI/='1' -- branch or LOOP,exception
	else '1';
	

	--offset enable
	offset_en<='1' when (opcode="0111" and Ra="00") or (opcode="0111" and Ra="01") or opcode="1100" or opcode="1101" or opcode="1110" or opcode="1010" or (opcode="1011" and Ra="01") or (opcode="1011" and Ra="10") or fetch_pushFlags='1' or fetch_pushPC='1' or EX_RTI='1' or (opcode="1011" and Ra="11")	-- offset_en=1 when pop or push or LD , LOOP , CALL , RET , INT
	else '0';
	
	-- offset value
	offset <= "00000001" when (opcode="0111" and Ra="01") or opcode="1010" or (opcode="1011" and Ra="10") or EX_RTI='1' or (opcode="1011" and Ra="11")	-- offset = 1 when pop,LOOP,RET
	else "00000000";										-- offset = 0 when push,CALL,INT
	
	imm_en <= '1' when opcode="1100"	--enable for reading immediate value from ram
	else '0';

	--ALSU operations
	alu_op <= "0000" when opcode="0000" and fetch_pushPC/='1' and fetch_pushFlags/='1' and EX_RTI/='1' --NOP
	else "0001" when opcode="0001" or (opcode="0111" and Ra="10") --MOV //in OUT F=B to make PORT=B
	else "0010" when opcode="0010" or (opcode="0111" and Ra="00") or (opcode="0111" and Ra="01") or opcode="1100" or opcode="1101" or opcode="1110" or (opcode="1011" and Ra="01") or (opcode="1011" and Ra="10") or fetch_pushFlags='1' or fetch_pushPC='1' or EX_RTI='1' or (opcode="1011" and Ra="11") --ADD //in (push,pop,CALL,RET,INT,RTI) add SP+offset
	else "0011" when opcode="0011" or opcode="1010" --SUB,LOOP
	else "0100" when opcode="0100" --AND
	else "0101" when opcode="0101" --OR
	else "0110" when opcode="0110" and Ra="00" --RLC
	else "0111" when opcode="0110" and Ra="01" --RRC
	else "1000" when opcode="1000" and Ra="00" --NOT
	else "1001" when opcode="1000" and Ra="01" --NEG
	else "1010" when opcode="1000" and Ra="10" --INC
	else "1011" when opcode="1000" and Ra="11" --DEC
	else "1100" when opcode="0110" and Ra="10" --SETC
	else "1101" when opcode="0110" and Ra="11" --CLRC
	else "0000";

	
	
	--enable changing the flags in main operations only
	change_flags <= '1' when opcode="0001" or opcode="0010" or opcode="0011" or opcode="0100"  or opcode="0101"  or opcode="0110" or opcode="1000"
	else '0';
end arch;

--  acc_mode
-- 000 | no MEM
---------------------------------------------------------
-- 001 | load
---------------------------------------------------------
-- 010 | store
---------------------------------------------------
-- 011 | pop
-------------------------------------------------- 
-- 100 | push
-----------------------------------------------
-- 101 | port out
------------------------------------------------
-- 110 | port in
------------------------------------------------
-- 111 | carry
