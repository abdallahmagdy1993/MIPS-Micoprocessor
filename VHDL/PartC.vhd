Library ieee;

Use ieee.std_logic_1164.all;

entity partC  is  
		port (a:in std_logic_vector (7 downto 0);
		s : in std_logic;
		cin : in std_logic;
		F : out std_logic_vector (7 downto 0);
		Cout : out std_logic;
		zero : out std_logic;
		negative : out std_logic
		);    
	end entity partC ;


-- take care of the usage of when else 
architecture  arch2 of partC is

signal fout : std_logic_vector(7 downto 0);
begin
fout <= cin & a(7 downto 1) when s = '1'
	else   a(6 downto 0) & cin  when s = '0';

F <= fout;

Cout <= a(7) when s = '0'
 else a(0) when s = '1';	

zero <= '1' when fout = "00000000"
	 else '0';

negative <= fout(7);

end arch2;

