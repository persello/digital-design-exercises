library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity search_chr is
  port
  (
    clk   : in std_logic;
    rst_n : in std_logic;

    -- Control signals
    start   : in std_logic; --! Start signal
    address : in std_logic_vector(31 downto 0); --! Address to start searching from
    char    : in std_logic_vector(7 downto 0); --! Character to search for
    len     : in std_logic_vector(5 downto 0); --! Length of the data to search
    n_found : out std_logic_vector(5 downto 0); --! Number of occurrences found
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

  -- State
  type state_t is (INIT, START_READ, FETCH, COMPARE);
  signal state, next_state : state_t;

  -- Registers
  signal reg_A     : std_logic_vector(31 downto 0); --! Current address
  signal reg_C     : std_logic_vector(7 downto 0); --! Character to search for
  signal reg_D     : std_logic_vector(7 downto 0); --! Latest data
  signal reg_L     : std_logic_vector(5 downto 0); --! Length of the data to search
  signal reg_COUNT : std_logic_vector(5 downto 0); --! Number of iterations
  signal reg_FOUND : std_logic_vector(5 downto 0); --! Number of occurrences found

  -- Register input signals
  signal reg_A_in     : std_logic_vector(31 downto 0);
  signal reg_C_in     : std_logic_vector(7 downto 0);
  signal reg_D_in     : std_logic_vector(7 downto 0);
  signal reg_L_in     : std_logic_vector(5 downto 0);
  signal reg_COUNT_in : std_logic_vector(5 downto 0);
  signal reg_FOUND_in : std_logic_vector(5 downto 0);

  -- Register load signals
  signal reg_A_ld     : std_logic;
  signal reg_C_ld     : std_logic;
  signal reg_D_ld     : std_logic;
  signal reg_L_ld     : std_logic;
  signal reg_COUNT_ld : std_logic;
  signal reg_FOUND_ld : std_logic;

  -- Signals
  signal count_eq_l : std_logic;
  signal c_eq_d     : std_logic;

begin

  -- Next state logic
  state <= INIT when rst_n = '0' else
    next_state when rising_edge(clk);

  fsm : process (clk, start, mem_ready)
  begin
    case state is
      when INIT =>
        if start = '1' then
          next_state <= START_READ;
        else
          next_state <= INIT;
        end if;
      when START_READ => next_state <= FETCH;
      when FETCH      =>
        if mem_ready = '1' then
          next_state <= COMPARE;
        else
          next_state <= FETCH;
        end if;
      when COMPARE =>
        if COUNT_eq_L = '1' then
          next_state <= INIT;
        else
          next_state <= FETCH;
        end if;
    end case;
  end process;

  -- Internal logic
  count_eq_l <= '1' when reg_COUNT = reg_L else
    '0';
  c_eq_d <= '1' when reg_C = reg_D else
    '0';

  -- Muxes
  reg_A_in <= address when state = INIT else
    std_logic_vector(unsigned(reg_A) + 1);

  reg_C_in <= char;

  reg_D_in <= mem_datain;

  reg_L_in <= len;

  reg_COUNT_in <= (others => '0') when state = INIT else
    std_logic_vector(unsigned(reg_COUNT) + 1);

  reg_FOUND_in <= (others => '0') when state = INIT else
    std_logic_vector(unsigned(reg_FOUND) + 1);

  -- Load logic
  reg_A_ld <= '1' when (state = INIT and start = '1') or (state = FETCH and mem_ready = '1') else
    '0';

  reg_C_ld <= '1' when (state = INIT and start = '1') else
    '0';

  reg_D_ld <= '1' when (state = FETCH and mem_ready = '1') else
    '0';

  reg_L_ld <= '1' when (state = INIT and start = '1') else
    '0';

  reg_COUNT_ld <= '1' when state = INIT or (state = FETCH and mem_ready = '1') else
    '0';

  reg_FOUND_ld <= '1' when (state = INIT and start = '1') or (state = COMPARE and c_eq_d = '1') else
    '0';

  -- Registers assignments
  reg_A     <= reg_A_in when rising_edge(clk) and reg_A_ld = '1';
  reg_C     <= reg_C_in when rising_edge(clk) and reg_C_ld = '1';
  reg_D     <= reg_D_in when rising_edge(clk) and reg_D_ld = '1';
  reg_L     <= reg_L_in when rising_edge(clk) and reg_L_ld = '1';
  reg_COUNT <= reg_COUNT_in when rising_edge(clk) and reg_COUNT_ld = '1';
  reg_FOUND <= reg_FOUND_in when rising_edge(clk) and reg_FOUND_ld = '1';

  -- Outputs
  mem_addr    <= reg_A;
  mem_dataout <= (others => '-');
  n_found     <= reg_FOUND;
  mem_we      <= '0';
  mem_enable  <= '1';
  ready       <= '1' when state = INIT else
    '0';

end architecture;