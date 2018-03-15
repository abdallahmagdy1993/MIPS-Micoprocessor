library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

Entity inst_ram is
port (
clk : in std_logic;
R : in std_logic;
address : in std_logic_vector(7 downto 0);
dataout : out std_logic_vector(7 downto 0) ;
MFC : out std_logic);
end entity inst_ram;

architecture inst_ram_arch of inst_ram is

   type ram_type is array(0 to 255) of std_logic_vector(7 downto 0);

	signal ram : ram_type ;
	begin
		process(clk) is
		  Begin
			if falling_edge(clk) then  
			  if (R = '1') then
				dataout <= ram(to_integer(unsigned(address)));
				MFC <= '1';
			  else
				MFC <= '0';
			  end if;
			end if;
		end process;


end architecture inst_ram_arch;
