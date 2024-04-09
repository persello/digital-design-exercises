library ieee;
use ieee.std_logic_1164.all;

-- Interface
entity ctrlunit is
  port
  (
    clk     : in std_logic; --! Clock
    reset_n : in std_logic; --! Reset

    -- Control signals
    datain : in std_logic; --! Signals that there is new data to load
    calc   : in std_logic; --! Signals that the input data is finished and a result should be provided

    -- Control outputs
    ready : out std_logic; --! The device signals that it is ready to receive new data
    ok    : out std_logic; --! The device signals that it has finished the calculation

    -- Datapath control signals
    a_load    : out std_logic; --! Load the A register in the datapath
    a_sel     : out std_logic; --! Select the data source for the A register: X or <A> >> 1
    ones_load : out std_logic; --! Load the ones register in the datapath
    ones_sel  : out std_logic_vector(1 downto 0); --! Select the data source for the ones register: 0, 1 or <ones> + 1

    -- Status signals
    a_lsb     : in std_logic; --! The LSB of the A register
    a_is_zero : in std_logic --! Signals that the A register is zero
  );
end entity ctrlunit;

architecture behav of ctrlunit is
  type statetype is (INIT, START, SHIFT, CALC_A, WAIT_DATA);
  signal state, nextstate : statetype;

begin

  -- State machine
  state <= INIT when reset_n = '0' else
    nextstate when rising_edge(clk);

  fsm : process (state, datain, calc, a_lsb, a_is_zero)
  begin
    case state is
      when INIT =>
        if calc /= '0' then
          nextstate <= INIT;
        elsif datain /= '1' then
          nextstate <= INIT;
        else
          nextstate <= START;
        end if;

      when START =>
        nextstate <= SHIFT;

      when SHIFT =>
        if a_is_zero = '0' then
          nextstate <= SHIFT;
        else
          nextstate <= WAIT_DATA;
        end if;

      when WAIT_DATA =>
        if calc = '1' then
          nextstate <= INIT;
        elsif datain = '0' then
          nextstate <= WAIT_DATA;
        else
          nextstate <= CALC_A;
        end if;

      when CALC_A =>
        nextstate <= SHIFT;

      when others =>
        nextstate <= INIT;
    end case;
  end process;

  -- Outputs
  a_load <= '1';

  a_sel <= '1' when state = START or state = SHIFT or
    state = CALC_A else
    '0'; -- '1' loads A << 1, '0' loads X.

  ones_load <= '1' when state = START or
    (state = SHIFT and a_lsb = '1') or
    (state = CALC_A and a_lsb = '1') else
    '0';

  ones_sel <= ('0' & a_lsb) when state = START else
    "10";

  READY <= '1' when state = INIT or state = WAIT_DATA else
    '0';

  OK <= '1' when state = INIT else
    '0';

end architecture;
