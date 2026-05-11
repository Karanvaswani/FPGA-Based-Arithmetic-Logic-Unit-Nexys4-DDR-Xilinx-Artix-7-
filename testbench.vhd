---------------------------------------------------------
-- Testbench for 32-Operation ALU — PBL_070
-- Author  : Karan Kumar
-- Tool    : Xilinx ISE Simulator (ISim)
-- Description: Cycles through all 32 opcodes to verify
--              correct ALU output across all functional units.
---------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbenchpbl IS
END testbenchpbl;

ARCHITECTURE bench OF testbenchpbl IS

    -- Component Declaration
    COMPONENT PBL_070
        PORT(
            in1     : IN  std_logic_vector(3 downto 0);
            in2     : IN  std_logic_vector(3 downto 0);
            Sel     : IN  std_logic_vector(4 downto 0);
            clk     : IN  std_logic;
            Anode   : OUT std_logic_vector(7 downto 0);
            Display : OUT std_logic_vector(7 downto 0)
        );
    END COMPONENT;

    -- Inputs
    signal in1  : std_logic_vector(3 downto 0) := (others => '0');
    signal in2  : std_logic_vector(3 downto 0) := (others => '0');
    signal Sel  : std_logic_vector(4 downto 0) := (others => '0');
    signal clk  : std_logic := '0';

    -- Outputs
    signal Anode   : std_logic_vector(7 downto 0);
    signal Display : std_logic_vector(7 downto 0);

BEGIN

    -- Instantiate Unit Under Test (UUT)
    uut: PBL_070 PORT MAP (
        in1     => in1,
        in2     => in2,
        Sel     => Sel,
        clk     => clk,
        Anode   => Anode,
        Display => Display
    );

    -- Clock process: 1 ps period
    clk_process : process
    begin
        clk <= '1';
        wait for 1 ps;
        clk <= '0';
        wait for 1 ps;
    end process;

    -- Stimulus: cycle through all 32 opcodes
    stim_proc: process
    begin
        in1 <= "0000";
        in2 <= "0000";
        Sel <= "00000";

        for i in 0 to 31 loop
            Sel <= Sel + 1;
            wait for 2 ps;
        end process;

        -- Hold final state
        wait;
    end process;

END bench;
