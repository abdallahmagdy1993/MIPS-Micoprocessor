Library ieee;
Use ieee.std_logic_1164.all;

Entity my_nDFF is
Generic ( n : integer := 8);
port( clk,rst,e : in std_logic;
d : in std_logic_vector(n-1 downto 0);
q : out std_logic_vector(n-1 downto 0));
end my_nDFF;

Architecture a_my_nDFF of my_nDFF is
begin
Process (clk,rst)
begin
if rst = '1' then
q <= (others=>'0');
elsif rising_edge(clk) and e='1' then
q <= d;
end if;
end process;
end a_my_nDFF;

Architecture b_my_nDFF of my_nDFF is
	Component my_DFF is
               port( d,clk,rst,e : in std_logic;
			   q : out std_logic);
	end component;
begin
loop1: for i in 0 to n-1 generate
fx: my_DFF port map(d(i),clk,rst,e,q(i));
end generate;
end b_my_nDFF;
