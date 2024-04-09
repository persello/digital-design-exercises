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
    ones_sel  : out std_logic; --! Select the data source for the ones register: 0 or <ones> + 1

    -- Status signals
    a_lsb     : in std_logic; --! The LSB of the A register
    a_is_zero : in std_logic --! Signals that the A register is zero
  );
end entity ctrlunit;

architecture behav of ctrlunit is
  type statetype is (INIT, START, INC, SHIFT, CALC_A, WAIT_DATA);
  signal state, nextstate : statetype;

begin

  -- State machine
  state <= INIT when reset_n = '0' else
    nextstate when rising_edge(clk);

  fsm: process (state, datain, calc, a_lsb, a_is_zero)
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
        if a_lsb = '0' then
          nextstate <= SHIFT;
        else
          nextstate <= INC;
        end if;

      when INC =>
        if a_is_zero = '1' then
          nextstate <= WAIT_DATA;
        elsif a_lsb = '1' then
          nextstate <= INC;
        else
          nextstate <= SHIFT;
        end if;

      when SHIFT =>
        if a_is_zero = '1' then
          nextstate <= WAIT_DATA;
        elsif a_lsb = '1' then
          nextstate <= INC;
        else
          nextstate <= SHIFT;
        end if;

      when CALC_A =>
        if a_lsb = '0' then
          nextstate <= SHIFT;
        else
          nextstate <= INC;
        end if;

      when WAIT_DATA =>
        if CALC = '1' then
          nextstate <= INIT;
        elsif DATAIN = '0' then
          nextstate <= WAIT_DATA;
        else
          nextstate <= CALC_A;
        end if;

      when others =>
        nextstate <= INIT;
    end case;
  end process;

  -- Outputs
  a_load <= '1' when state = INIT or state = START or
    state = INC or state = SHIFT or state = WAIT_DATA or state = CALC_A else
    '0';

  a_sel <= '1' when state = START or state = SHIFT or
    state = INC or
    state = CALC_A else
    '0';

  ones_load <= '1' when state = START or
    state = INC else
    '0';

  ones_sel <= '1' when state = INC else
    '0';

  READY <= '1' when state = INIT or state = WAIT_DATA else
    '0';

  OK <= '1' when state = INIT else
    '0';

end architecture;
