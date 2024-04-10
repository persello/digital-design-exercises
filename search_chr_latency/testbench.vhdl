library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity testbench;

architecture behav of testbench is

  signal n_simul_cycles : integer := 0;
  signal started        : boolean := false;
  signal end_simul      : boolean := false;

  signal clk   : std_logic;
  signal rst_n : std_logic;

  type tb_state_t is (INIT, TEST1, WAIT1, FINISHED1, FINISHED2, FINISHED3);
  signal tb_state, tb_next_state : tb_state_t;

  type array_of_integers is array (natural range <>) of integer;

  constant ADDRESSES : array_of_integers := (3, 5, 20);
  constant CHARS     : array_of_integers := (3, 3, 5);
  constant LENS      : array_of_integers := (10, 10, 15);

  signal start         : std_logic;
  signal address       : std_logic_vector(31 downto 0);
  signal char          : std_logic_vector(7 downto 0);
  signal len           : std_logic_vector(5 downto 0);
  signal ready         : std_logic;
  signal n_found       : std_logic_vector(5 downto 0);
  signal mem_enable    : std_logic;
  signal mem_we        : std_logic;
  signal mem_addr      : std_logic_vector(31 downto 0);
  signal data_from_mem : std_logic_vector(7 downto 0);
  signal data_to_mem   : std_logic_vector(7 downto 0);
  signal mem_ready     : std_logic;

  signal cnt, in_cnt, cnt2, in_cnt2 : integer := 0;

begin

  start_process : process
  begin
    rst_n   <= '1', '0' after 1 ns, '1' after 199 ns;
    started <= true;
    wait;
  end process;

  clk_gen : process
  begin
    clk <= '1', '0' after 5 ns;

    wait for 10 ns;

    if end_simul then
      wait;
    else
      n_simul_cycles <= n_simul_cycles + 1;
    end if;
  end process;

  dut : entity work.search_chr
    port map
    (
      clk         => clk,
      rst_n       => rst_n,
      start       => start,
      address     => address,
      char        => char,
      len         => len,
      n_found     => n_found,
      ready       => ready,
      mem_enable  => mem_enable,
      mem_we      => mem_we,
      mem_addr    => mem_addr,
      mem_datain  => data_from_mem,
      mem_dataout => data_to_mem,
      mem_ready   => mem_ready
    );

  mem : entity work.memory
    port
    map (
    clk     => clk,
    address => mem_addr,
    enable  => mem_enable,
    we      => mem_we,
    ready   => mem_ready,
    datain  => data_to_mem,
    dataout => data_from_mem
    );

  tb_state <= INIT when rst_n = '0' else
    tb_next_state when rising_edge(CLK);

  process (tb_state, ready, cnt, cnt2) begin
    case tb_state is
      when INIT =>
        tb_next_state <= TEST1;

      when TEST1 =>
        tb_next_state <= WAIT1;

      when WAIT1 =>
        if READY = '1' then
          if cnt = ADDRESSES'length then
            tb_next_state <= FINISHED1;
          else
            tb_next_state <= TEST1;
          end if;
        else
          tb_next_state <= WAIT1;
        end if;

      when FINISHED1 =>
        tb_next_state <= FINISHED2;

      when FINISHED2 =>
        if cnt2 = 10 then
          tb_next_state <= FINISHED3;
          end_simul     <= true;
        else
          tb_next_state <= FINISHED2;
        end if;

      when FINISHED3 =>
        tb_next_state <= FINISHED3;

    end case;
  end process;

  start <= '1' when tb_state = TEST1 else
    '0';
  address <= std_logic_vector(to_unsigned(ADDRESSES(cnt), address'length)) when tb_state = TEST1 else
    (others => '-');
  char <= std_logic_vector(to_unsigned(CHARS(cnt), char'length)) when tb_state = TEST1 else
    (others => '-');
  len <= std_logic_vector(to_unsigned(LENS(cnt), len'length)) when tb_state = TEST1 else
    (others => '-');

  in_cnt <= 0 when tb_state = INIT else
    cnt + 1 when tb_state = TEST1 else
    0;

  cnt <= in_cnt when rising_edge(CLK) and (tb_state = INIT or tb_state = TEST1);

  in_cnt2 <= 0 when tb_state = FINISHED1 else
    cnt2 + 1 when tb_state = FINISHED2 else
    0;

  cnt2 <= in_cnt2 when rising_edge(CLK) and
    (tb_state = FINISHED1 or tb_state = FINISHED2);
end architecture;