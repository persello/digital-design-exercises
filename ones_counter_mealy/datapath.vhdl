library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
  port
  (
    clk     : in std_logic;
    reset_n : in std_logic;

    -- Data inputs
    x : in std_logic_vector(7 downto 0); --! 8-bit input

    -- Data outputs
    outp : out std_logic_vector(7 downto 0); --! Counter output

    -- Control signals
    a_load    : in std_logic; --! Load the A register in the datapath
    a_sel     : in std_logic; --! Select the data source for the A register: X or <A> >> 1
    ones_load : in std_logic; --! Load the ones register in the datapath
    ones_sel  : in std_logic_vector(1 downto 0); --! Select the data source for the ones register: 0, 1 or <ones> + 1

    -- Status signals
    a_lsb     : out std_logic; --! The least significant bit of the A register
    a_is_zero : out std_logic --! True if the A register is zero
  );
end entity datapath;

architecture s of datapath is
  signal R_a  : std_logic_vector(7 downto 0); --! A register
  signal a_in : std_logic_vector(7 downto 0); --! Input to the A register

  signal R_ones  : std_logic_vector(7 downto 0); --! Ones register
  signal ones_in : std_logic_vector(7 downto 0); --! Input to the ones register

  signal adder1 : std_logic_vector(R_ones'range); --! Adder output
begin

  -- Registers
  R_a <= (others => '0') when reset_n = '0' else
    a_in when rising_edge(clk) and a_load = '1';

  R_ones <= (others => '0') when reset_n = '0' else
    ones_in when rising_edge(clk) and ones_load = '1';

  -- Muxes
  a_in <= x when a_sel = '0' else
    '0' & R_a(7 downto 1);

  ones_in <= (others => '0') when ones_sel = "00" else
    "00000001" when ones_sel = "01" else
    adder1;

  -- Adder
  adder1 <= std_logic_vector(unsigned(R_ones) + 1);

  -- Status signals
  a_lsb     <= R_a(0);
  a_is_zero <= '1' when unsigned(R_a) = 0 else
    '0';

  -- Data output
  outp <= R_ones;

end architecture;