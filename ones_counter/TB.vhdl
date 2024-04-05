library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity TB is
end entity TB;

architecture behav of TB is
  constant CLK_SEMIPERIOD0 : time := 25 ns;
  constant CLK_SEMIPERIOD1 : time := 15 ns;
  constant CLK_PERIOD      : time := CLK_SEMIPERIOD0 + CLK_SEMIPERIOD1;
  constant RESET_TIME      : time := 3 * CLK_PERIOD + 9 ns;

  -- Simulation control signals
  signal start : integer := 0;
  signal done  : integer := 0;

  -- To the DUT
  signal clk, reset_n : std_logic;
  signal x            : std_logic_vector(7 downto 0) := (others => '0'); -- Initial value in order to avoid simulation warnings.
  signal datain       : std_logic := '0';
  signal calc         : std_logic := '0';

  -- From the DUT
  signal outp  : std_logic_vector(7 downto 0);
  signal ready : std_logic;
  signal ok    : std_logic;
begin

  dut : entity work.onescounter
    port map
    (
      clk     => clk,
      reset_n => reset_n,
      x       => x,
      datain  => datain,
      calc    => calc,
      outp    => outp,
      ready   => ready,
      ok      => ok
    );

  start_process : process
  begin

    reset_n <= '1';
    wait for 1 ns;
    reset_n <= '0';
    wait for RESET_TIME;
    reset_n <= '1';
    start   <= 1;
    wait;

  end process;

  clk_process : process
  begin

    if clk = '0' then
      clk <= '1';
      wait for CLK_SEMIPERIOD1;
    else
      clk <= '0';
      wait for CLK_SEMIPERIOD0;
    end if;

    if done = 1 then
      wait;
    end if;

  end process;

  read_file_process : process (clk)
    file in_file       : text open read_mode is "data.txt";
    variable in_line   : line;
    variable in_x      : bit_vector(x'range);
    variable in_datain : bit;
    variable in_calc   : bit;
  begin

    if clk = '0' and start = 1 and ready = '1' then
      if not endfile(in_file) then
        readline(in_file, in_line);
        read(in_line, in_x);
        readline(in_file, in_line);
        read(in_line, in_datain);
        readline(in_file, in_line);
        read(in_line, in_calc);
        readline(in_file, in_line);

        x          <= to_UX01(in_x);
        datain     <= to_UX01(in_datain);
        calc       <= to_UX01(in_calc);
      else -- End of file
        done <= 1;
      end if;
    end if;

  end process;

end architecture;