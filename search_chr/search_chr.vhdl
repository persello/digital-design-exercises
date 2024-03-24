library ieee;
use ieee.std_logic_1164.all;

entity search_chr is
  port
  (
    clk     : in std_logic;
    reset_n : in std_logic;

    -- Control signals
    start   : in std_logic; --! Start signal
    address : in std_logic_vector(31 downto 0); --! Address to start searching from
    len     : in std_logic_vector(5 downto 0); --! Length of the data to search
    nfound  : out std_logic_vector(5 downto 0); --! Number of occurrences found
    ready   : out std_logic; --! Ready signal

    -- Memory interface
    mem_enable  : out std_logic; --! Enable signal for the memory
    mem_we      : out std_logic; --! Write enable signal for the memory
    mem_addr    : out std_logic_vector(31 downto 0); --! Address bus for the memory
    mem_datain  : in std_logic_vector(7 downto 0); --! Incoming memory word
    mem_dataout : out std_logic_vector(7 downto 0); --! Outgoing memory word
    mem_ready   : in std_logic --! Ready signal from the memory

  );
end entity search_chr;

architecture rtl of search_chr is
  -- State machine signals.
  type state_type is (INIT, START_READ, FETCH, COMPARE);
  signal state, nextstate : state_type;

begin

  -- State machine.
  state <= INIT when reset_n = '0' else
    nextstate when rising_edge(clk);

  fsm : process (state, start) is
  begin
    case state is
      when INIT =>
        if start = '1' then
          nextstate <= START_READ;
        else
          nextstate <= INIT;
        end if;
      when START_READ =>
        -- Add code for START_READ state here

      when FETCH =>
        -- Add code for FETCH state here

      when COMPARE =>
        -- Add code for COMPARE state here

    end case;
  end process;

end architecture;