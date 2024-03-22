library ieee;
use ieee.std_logic_1164.all;

entity onescounter is
  port
  (
    clk     : in std_logic;
    reset_n : in std_logic;

    -- Data inputs
    x : in std_logic_vector(7 downto 0);

    -- Data outputs
    outp : out std_logic_vector(7 downto 0);

    -- Control inputs
    datain : in std_logic;
    calc   : in std_logic;

    -- Control outputs
    ready : out std_logic;
    ok    : out std_logic

  );
end entity onescounter;

architecture struct of onescounter is
  signal a_load : std_logic;
  signal a_sel  : std_logic;

  signal ones_load : std_logic;
  signal ones_sel  : std_logic;

  signal a_lsb     : std_logic;
  signal a_is_zero : std_logic;
begin

  cu : entity work.ctrlunit
    port map
    (
      clk       => clk,
      reset_n   => reset_n,
      datain    => datain,
      calc      => calc,
      a_load    => a_load,
      a_sel     => a_sel,
      ones_load => ones_load,
      ones_sel  => ones_sel,
      a_is_zero => a_is_zero,
      a_lsb     => a_lsb,
      ready     => ready,
      ok        => ok
    );

  datapath : entity work.datapath
    port
    map (
    clk       => clk,
    reset_n   => reset_n,
    a_load    => a_load,
    a_sel     => a_sel,
    ones_load => ones_load,
    ones_sel  => ones_sel,
    x         => x,
    outp      => outp,
    a_lsb     => a_lsb,
    a_is_zero => a_is_zero
    );

end architecture;