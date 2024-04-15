library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

entity memory is
  port
  (
    clk     : in std_logic;
    address : in std_logic_vector(31 downto 0);
    enable  : in std_logic;
    we      : in std_logic;
    ready   : out std_logic;
    datain  : in std_logic_vector(7 downto 0);
    dataout : out std_logic_vector(7 downto 0)
  );
end entity memory;

architecture s of memory is
  type ram_type is array (0 to 1023) of bit_vector(7 downto 0);

  impure function loadmem return ram_type is
    file memory_file   : text;
    variable fstatus   : file_open_status;
    variable inputline : line;
    variable mem       : ram_type;
    variable i         : integer;
  begin

    file_open(fstatus, memory_file, "data.bin", READ_MODE);

    if fstatus = open_ok then
      i := 0;

      while (i < 1024 and not endfile(memory_file)) loop
        readline (memory_file, inputline);
        read (inputline, mem(i));
        i := i + 1;
      end loop;

    end if;

    return mem;
  end function;

  shared variable ram : ram_type := loadmem;
  constant latency : time := 1 fs;

begin
  process (clk)
  begin

    if rising_edge(CLK) and enable = '1' then
      if we = '1' then
        RAM(to_integer(unsigned(address))) := to_bitvector(datain);
        dataout <= (others => '-'); -- writing policy not specified
      else
        dataout <= (others => '-'), to_stdlogicvector(RAM(to_integer(unsigned(address)))) after latency;
        ready   <= '0', '1' after latency;
      end if;
    end if;
  end process;

end architecture;