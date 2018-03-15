Library ieee;

Use ieee.std_logic_1164.all;

entity ALSU  is  
		port (a,b:in std_logic_vector (7 downto 0);
		s : in std_logic_vector(3 downto 0);
		cin : in std_logic;
		F : out std_logic_vector (7 downto 0);
		cout: out std_logic;
		zero : out std_logic;
		negative : out std_logic;
		overflow : out std_logic
		);    
	end entity ALSU ;

--  F=0	0000 : opcode only
--  F=B 0001 : opcode only
--	ADD 0010 : opcode only
--	SUB 0011 : opcode only
--	--------
--	AND 0100 : opcode only
--	OR  0101 : opcode only
--	--------
--	RLC 0110 : opcode or ra
--	RRC 0111 : opcode or ra
--	--------
--	NOT 1000 : opcode or ra
--	NEG 1001 : opcode or ra
--	INC 1010 : opcode or ra
--	DEC 1011 : opcode or ra
--  --------
--  SETC 1100 : ?
--  CLRC 1101 : ?
architecture  arch of ALSU is
  
	component partA  is  
		port (a,b:in std_logic_vector (7 downto 0);
		s : in std_logic;
		F : out std_logic_vector (7 downto 0);
		cout: out std_logic;
		zero : out std_logic; -- zero Signal
		negative : out std_logic; -- negative signal    
		overflow : out std_logic
		); -- overflow flag
	end component;


component partB  is  		
	port (a,b :in std_logic_vector (7 downto 0);
		s : in std_logic;
		F : out std_logic_vector (7 downto 0);
		zero : out std_logic;
		negative : out std_logic
		);       
	end component ;
	
component partC  is  
		port (a:in std_logic_vector (7 downto 0);
		s : in std_logic;
		cin : in std_logic;
		F : out std_logic_vector (7 downto 0);
		Cout : out std_logic;
		zero : out std_logic;
		negative : out std_logic
		);    
	end component ;
	
	component partD  is  
		port (a:in std_logic_vector (7 downto 0);
		s : in std_logic_vector ( 1 downto 0 );
		F : out std_logic_vector (7 downto 0);
		Cout : out std_logic;
		zero : out std_logic;
		negative : out std_logic;
		overflow : out std_logic
		); 
	end component ;
	
	signal w0,w1,w2,w3 : std_logic_vector(7 downto 0);
	signal overflows : std_logic_vector(1 downto 0);
	signal negatives : std_logic_vector(3 downto 0);
	signal carries : std_logic_vector(2 downto 0);
	signal zeros : std_logic_vector(3 downto 0);
begin
  
		u0:partA port map(a,b,s(0),w0,carries(0),zeros(0),negatives(0),overflows(0));
    u1:partB port map(a,b,s(0),w1,zeros(1),negatives(1));
    u2:partC port map(b,s(0),cin,w2,carries(1),zeros(2),negatives(2));
    u3:partD port map(b,s(1 downto 0),w3,carries(2),zeros(3),negatives(3),overflows(1));
      
      
	F <= 	 w0 				when s(3)='0' and s(2)='0' and s(1) = '1'
		else w1 				when s(3)='0' and s(2)='1' and s(1) = '0'
		else w2 				when s(3)='0' and s(2)='1' and s(1) = '1'
		else w3 				when s(3)='1' and s(2)='0'
		else "00000000" when s(3)='0' and s(2)='0' and s(1)='0' and s(0)='0'
		else b 					when s(3)='0' and s(2)='0' and s(1)='0' and s(0)='1';
 
	cout <=  carries(0) when s(3)='0' and s(2)='0' and s(1)='1'
			else '0' 				when s(3)='0' and s(2)='1' and s(1)='0'
			else carries(1) when s(3)='0' and s(2)='1' and s(1)='1'
			else carries(2) when s(3)='1' and s(2)='0'
			else '1' 				when s(3)='1' and s(2)='1' and s(1)='0' and s(0)='0'
			else '0'				when s(3)='1' and s(2)='1' and s(1)='0' and s(0)='1'
			else 'Z';
	
	zero <=  zeros(0) when s(3)='0' and s(2)='0' and s(1)='1'
			else zeros(1) when s(3)='0' and s(2)='1' and s(1)='0'
			else zeros(2) when s(3)='0' and s(2)='1' and s(1)='1'
			else zeros(3) when s(3)='1' and s(2)='0'
			else 'Z';
	
	negative <= negatives(0) when s(3)='0' and s(2)='0' and s(1)='1'
			else 		negatives(1) when s(3)='0' and s(2)='1' and s(1)='0'
			else 		negatives(2) when s(3)='0' and s(2)='1' and s(1)='1'
			else 		negatives(3) when s(3)='1' and s(2)='0'
			else 'Z';

overflow <= overflows(0) when s(3)='0' and s(2)='0' and s(1)='1'
			 else '0' 				 when s(3)='0' and s(2)='1' and s(1)='0'
			 else '0' 				 when s(3)='0' and s(2)='1' and s(1)='1'
			 else overflows(1) when s(3)='1' and s(2)='0'
			 else 'Z';
		
    
end arch;

