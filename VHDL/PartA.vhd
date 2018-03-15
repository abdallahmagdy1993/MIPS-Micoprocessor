Library ieee;

Use ieee.std_logic_1164.all;

entity partA  is  
		port (a,b:in std_logic_vector (7 downto 0);
		s : in std_logic;
		F : out std_logic_vector(7 downto 0);
		cout: out std_logic;
		zero : out std_logic; -- zero Signal
		negative : out std_logic; -- negative signal    
		overflow : out std_logic
		); -- overflow flag
	end entity partA ;


-- take care of the usage of when else 
architecture  arch4 of partA is

component my_nadder is
       generic (n : integer := 8);
port   (a, b : in std_logic_vector(n-1  downto 0) ;
             cin : in std_logic;  
             s : out std_logic_vector(n-1 downto 0);
             cout : out std_logic);
end component;

signal bb,out1 :std_logic_vector(7 downto 0);
signal	cout1 :std_logic;		
begin

bb <= b when s = '0'
	else not b when s = '1';



u0:my_nadder port map(a,bb,s,out1,cout1);


F <= out1;

-- overflow flag, check last bit of the 2 operands and the result
overflow <= '1' when ( a(7) = '1' and bb(7) = '1' and out1(7) = '0' ) or ( a(7) = '0' and bb(7) = '0' and  out1(7) ='1' ) 
else '0';

-- zero bit
zero <= '1' when out1 = "00000000"
      else '0'; 
	
-- negative bit
negative <= out1(7);

cout <= cout1 when s = '0'
	 else not cout1; 
     -- TODO : write the architecture of mux2 
end arch4;


