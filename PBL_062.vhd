---------------------------------------------------------
-- 32-Operation ALU — Nexys4 DDR (Xilinx Artix-7)
-- Author  : Karan Kumar
-- Board   : Nexys4 DDR
-- Tool    : Xilinx ISE
-- Description: Structural VHDL ALU supporting Arithmetic,
--              Logic, Shift/Rotate, and Set/Clear units
--              with 8-digit multiplexed 7-segment display.
---------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PBL_070 is
    Port (
        Clk     : in  STD_LOGIC;
        in1     : in  STD_LOGIC_VECTOR (3 downto 0);
        in2     : in  STD_LOGIC_VECTOR (3 downto 0);
        Sel     : in  STD_LOGIC_VECTOR (4 downto 0);
        Anode   : out STD_LOGIC_VECTOR (7 downto 0);
        Display : out STD_LOGIC_VECTOR (7 downto 0)
    );
end PBL_070;

architecture USAMA of PBL_070 is

    -- Roll number constants
    CONSTANT R1 : std_logic_vector(3 DOWNTO 0) := "0111"; -- 7
    CONSTANT R2 : std_logic_vector(3 DOWNTO 0) := "0000"; -- 0

    -- Internal signals
    Signal A, B              : std_logic_vector(7 downto 0);
    Signal logic             : std_logic_vector(7 downto 0);
    Signal Shift_rotate      : std_logic_vector(7 downto 0);
    Signal Set_clear         : std_logic_vector(7 downto 0);
    Signal Arith             : Signed(7 downto 0);
    SIGNAL A_sig, B_sig      : SIGNED(7 DOWNTO 0);
    Signal Slow              : std_logic;
    SIGNAL fast              : std_logic;
    Signal Temp              : std_logic_vector(3 downto 0);
    Signal sevensegcounter   : std_logic_vector(3 downto 0);

    -- Decimal conversion signals
    SIGNAL y_logicdecimal    : integer range 0 to 255;
    SIGNAL y_arithdecimal    : integer;
    SIGNAL y_SRdecimal       : integer range 0 to 255;
    SIGNAL y_SCdecimal       : integer range 0 to 255;
    SIGNAL ydigit1           : integer;
    SIGNAL ydigit2           : integer;
    SIGNAL ydigit3           : integer;
    SIGNAL ydigit1conv       : std_logic_vector(3 downto 0);
    SIGNAL ydigit2conv       : std_logic_vector(3 downto 0);
    SIGNAL ydigit3conv       : std_logic_vector(3 downto 0);
    SIGNAL y1, y2, y3        : STD_LOGIC_VECTOR(7 DOWNTO 0);

begin

    -- Input extension
    process(in1, in2)
    begin
        A <= in1 & "0110";
        B <= in2 & "0011";
    end process;

    -- LOGIC UNIT
    With Sel(2 downto 0) Select
        Logic <= (not B)      when "000",
                 (not A)      when "001",
                 (A and B)    when "010",
                 (A or B)     when "011",
                 (A nand B)   when "100",
                 (A nor B)    when "101",
                 (A xor B)    when "110",
                 (A xnor B)   when others;

    -- ARITHMETIC UNIT
    A_sig <= SIGNED(A);
    B_sig <= SIGNED(B);

    With Sel(2 downto 0) Select
        Arith <= B_sig           when "000",
                 A_sig           when "001",
                 (B_sig + 1)     when "010",
                 (B_sig - 1)     when "011",
                 (A_sig + 1)     when "100",
                 (A_sig - 1)     when "101",
                 (A_sig + B_sig) when "110",
                 (B_sig - A_sig) when others;

    -- SHIFT & ROTATE UNIT
    With Sel(2 downto 0) Select
        Shift_rotate <=
            (A(5 downto 0) & "00")              when "000", -- A SLL 2
            ("00" & B(7 downto 2))              when "001", -- B SRL 2
            (B(4 downto 0) & B(0) & B(0) & B(0)) when "010", -- B SLA 3
            (A(7) & A(7 downto 1))              when "011", -- A SRA 1
            (B(1 downto 0) & B(7 downto 2))     when "100", -- B ROR 2
            (A(3 downto 0) & A(7 downto 4))     when "101", -- A ROL 4
            ("00" & A(7 downto 2))              when "110", -- A SLL -2
            (B(5 downto 0) & "00")              when others; -- B SRL -2

    -- SET & CLEAR UNIT
    With Sel(2 downto 0) Select
        Set_clear <=
            (A and X"00")  when "000", -- Clear A
            (B xor X"FF")  when "001", -- Toggle B
            (A or  X"FF")  when "010", -- Set A
            (B and X"00")  when "011", -- Clear B
            (A xor X"FF")  when "100", -- Toggle A
            (A or  X"FF")  when "101", -- Set B
            (in2 & in1)    when "110", -- Concatenate
            set_clear      when others; -- No change

    -- FREQUENCY DIVIDER — 100 KHz (display refresh)
    process(clk, slow)
        variable divider : integer range 0 to 500;
    begin
        if (clk'event and clk = '1') then
            divider := divider + 1;
            if (divider = 500) then
                slow    <= not slow;
                divider := 0;
            end if;
        end if;
    end process;

    -- FREQUENCY DIVIDER — 10 seconds (display rotation)
    process(clk, fast)
        variable divider : integer range 0 to 100000000;
    begin
        if (rising_edge(clk)) then
            divider := divider + 1;
            if (divider = 100000000) then
                fast    <= not fast;
                divider := 0;
            end if;
        end if;
    end process;

    -- ANODE COUNTER
    Process(slow)
    begin
        if (slow'event and slow = '1') then
            Temp <= Temp + 1;
        end if;
    end process;

    -- 7-SEGMENT COUNTER
    Process(slow)
    begin
        if (slow'event and slow = '1') then
            sevensegcounter <= sevensegcounter + 1;
        end if;
    end process;

    -- ANODE SELECTION (active low)
    with Temp Select
        Anode <= "11111110" WHEN "0000",
                 "11111101" WHEN "0001",
                 "11111011" WHEN "0010",
                 "11110111" WHEN "0011",
                 "11101111" WHEN "0100",
                 "11011111" WHEN "0101",
                 "10111111" WHEN "0110",
                 "01111111" WHEN "0111",
                 "11111111" WHEN OTHERS;

    -- DECIMAL CONVERSION
    y_SCdecimal    <= to_integer(unsigned(Set_clear));
    y_SRdecimal    <= to_integer(unsigned(Shift_rotate));
    y_logicdecimal <= to_integer(unsigned(logic));
    y_arithdecimal <= to_integer(signed(Arith));

    -- OUTPUT MUX — digit 1
    WITH Sel(4 DOWNTO 3) SELECT
        ydigit1 <= y_logicdecimal mod 10  WHEN "00",
                   y_arithdecimal mod 10  WHEN "01",
                   y_SRdecimal mod 10     WHEN "10",
                   y_SCdecimal mod 10     WHEN OTHERS;

    -- OUTPUT MUX — digit 2
    WITH Sel(4 DOWNTO 3) SELECT
        ydigit2 <= y_logicdecimal / 10 mod 10  WHEN "00",
                   y_arithdecimal / 10 mod 10  WHEN "01",
                   y_SRdecimal / 10 mod 10     WHEN "10",
                   y_SCdecimal / 10 mod 10     WHEN OTHERS;

    -- OUTPUT MUX — digit 3
    WITH Sel(4 DOWNTO 3) SELECT
        ydigit3 <= y_logicdecimal / 100 mod 10  WHEN "00",
                   y_arithdecimal / 100 mod 10  WHEN "01",
                   y_SRdecimal / 100 mod 10     WHEN "10",
                   y_SCdecimal / 100 mod 10     WHEN OTHERS;

    -- INTEGER TO STD_LOGIC_VECTOR CONVERSION
    ydigit1conv <= std_logic_vector(to_unsigned(ydigit1, ydigit1conv'length));
    ydigit2conv <= std_logic_vector(to_unsigned(ydigit2, ydigit2conv'length));
    ydigit3conv <= std_logic_vector(to_unsigned(ydigit3, ydigit3conv'length));

    -- 7-SEGMENT DECODER — digit 1
    WITH ydigit1conv SELECT
        y1 <= "11111001" when "0001",
              "10100100" when "0010",
              "10110000" when "0011",
              "10011001" when "0100",
              "10010010" when "0101",
              "10000010" when "0110",
              "11111000" when "0111",
              "10000000" when "1000",
              "10010000" when "1001",
              "11000000" when "0000",
              "11111111" when others;

    -- 7-SEGMENT DECODER — digit 2
    WITH ydigit2conv SELECT
        y2 <= "11111001" when "0001",
              "10100100" when "0010",
              "10110000" when "0011",
              "10011001" when "0100",
              "10010010" when "0101",
              "10000010" when "0110",
              "11111000" when "0111",
              "10000000" when "1000",
              "10010000" when "1001",
              "11000000" when "0000",
              "11111111" when others;

    -- 7-SEGMENT DECODER — digit 3
    WITH ydigit3conv SELECT
        y3 <= "11111001" when "0001",
              "10100100" when "0010",
              "10110000" when "0011",
              "10011001" when "0100",
              "10010010" when "0101",
              "10000010" when "0110",
              "11111000" when "0111",
              "10000000" when "1000",
              "10010000" when "1001",
              "11000000" when "0000",
              "11111111" when others;

    -- SCROLLING DISPLAY (department/batch/roll)
    WITH sevensegcounter SELECT
        Display <= "11111000" WHEN "0000", -- 0
                   "10110000" WHEN "0001", -- 7
                   "11000000" WHEN "0010", -- O
                   "10101011" WHEN "0011", -- N
                   "11000111" WHEN "0100", -- L
                   "11000111" WHEN "0101", -- L
                   "11000000" WHEN "0110", -- O
                   "10101111" WHEN "0111", -- R
                   "11111111" WHEN OTHERS;

end Architecture USAMA;
