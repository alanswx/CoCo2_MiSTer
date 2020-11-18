
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity samglue is
    generic
        (
            T1_VARIANT   : boolean := false;
            CVBS_NOT_VGA : boolean := false);
    port
        (
   clk_57M272            : in  std_logic;
   platform_rst            : in  std_logic;
   clk_14M318_ena            : in  std_logic;
   ras_n            : in  std_logic;
   cas_n            : in  std_logic;
   clk_e            : in  std_logic;
   clk_q            : in  std_logic;
	ma					: in std_logic_vector(7 downto 0);
	vdg_data					: in std_logic_vector(7 downto 0);
	ram_dout					: out std_logic_vector(7 downto 0);
	ram_dout_b					: out std_logic_vector(7 downto 0);
	sam_a					: out std_logic_vector(15 downto 0)
            );
end samglue;

architecture SYN of samglue is

begin


	

	process (clk_57M272, platform_rst)
    variable ras_n_r  : std_logic := '0';
    variable cas_n_r  : std_logic := '0';
    variable e_r      : std_logic := '0';
    variable q_r      : std_logic := '0';
	begin
    if platform_rst = '1' then
      ras_n_r := '0';
      cas_n_r := '0';
      e_r := '0';
      q_r := '0';
		elsif rising_edge (clk_57M272) then
      if clk_14M318_ena = '1' then
        -- need to latch for CPU09 core
          if ras_n = '1' and ras_n_r = '0' and clk_e = '1' then
           	ram_dout<=vdg_data;
          end if;
        if ras_n = '0' and ras_n_r = '1' then
          sam_a(7 downto 0) <= ma;
        elsif cas_n = '0' and cas_n_r = '1' then
          sam_a(15 downto 8) <= ma;
        end if;
        if clk_q = '1' and q_r = '0' then
 		   ram_dout_b<=vdg_data;-- <= sram_i.d(ram_datao'range);

        end if;
        -- for edge-detect
        ras_n_r := ras_n;
        cas_n_r := cas_n;
        e_r := clk_e;
        q_r := clk_q;
      end if;
		end if;
	end process;


end SYN;