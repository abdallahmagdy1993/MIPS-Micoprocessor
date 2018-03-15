Library ieee;

Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
entity partD  is  
		port (a:in std_logic_vector (7 downto 0);
		s : in std_logic_vector ( 1 downto 0);
		F : out std_logic_vector (7 downto 0);
		Cout : out std_logic;
		zero : out std_logic;
		negative : out std_logic;
		overflow : out std_logic
		);    
end entity partD ;


-- take care of the usage of when else 
architecture  arch3 of partD is


	component my_nadder is
      generic (n : integer := 8);
			port(a, b : in std_logic_vector(n-1  downto 0) ;
          cin : in std_logic;  
          s : out std_logic_vector(n-1 downto 0);
          cout : out std_logic
          );
	end component;

	signal f_1,f_2,fout : std_logic_vector(7 downto 0);
	signal cout_tmp, cin : std_logic;
begin
f_1 <= not a when s(1)='0'
		else  a when s(1) ='1';

f_2 <= ( others => '1' ) when s(1) = '1' and s(0) = '1'
	else ( others => '0');

cin <= s(1) xor s(0);

u0: my_nadder port map(f_1,f_2,cin,fout,cout_tmp);

F <= fout;

zero <= '1' when fout = "00000000"
else '0';
 
negative <= fout(7);
 
overflow <= '1' when a(7) = '1' and fout(7) = '0' and s = "11"
			 else '1' when a(7) = '0' and fout(7) = '1' and s = "10"
		   else '0';
 
Cout <= not cout_tmp when s = "11"
	 else cout_tmp;

end arch3;

