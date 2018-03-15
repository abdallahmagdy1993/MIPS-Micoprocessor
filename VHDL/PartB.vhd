
Library ieee;

Use ieee.std_logic_1164.all;

entity partB  is  
		port (a,b :in std_logic_vector (7 downto 0);
		s : in std_logic;
		F : out std_logic_vector (7 downto 0);
		zero : out std_logic;
		negative : out std_logic
		);    
	end entity partB ;


-- take care of the usage of when else 
architecture  arch1 of partB is

signal fout :  std_logic_vector(7 downto 0);
begin
 
fout <= a and b when s='0'
	else a or b when s ='1';
F <= fout;

zero <= '1' when fout = "00000000"
else '0';

negative <= fout(7);
-- TODO : write the architecture of mux2 
end arch1;

