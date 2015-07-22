----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:35:26 11/17/2010 
-- Design Name: 
-- Module Name:    FIFO - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity FWFT_FIFO is
	Generic (
		constant DATA_WIDTH  : positive := 8;
		constant FIFO_DEPTH	: positive := 256;
		constant PROG_FULL   : natural  := 128
	);
	Port ( 
		CLK		: in  STD_LOGIC;
		RST 		: in  STD_LOGIC;
		WriteEn	: in  STD_LOGIC;
		DataIn 	: in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		ReadEn	: in  STD_LOGIC;
		DataOut	: out	STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		Empty		: out	STD_LOGIC;
		Full		: out	STD_LOGIC;
		ProgFull : out STD_LOGIC
	);
end FWFT_FIFO;

architecture Behavioral of FWFT_FIFO is

begin

	-- Memory Pointer Process
	fifo_proc : process (CLK)
		type FIFO_Memory is array (0 to FIFO_DEPTH - 1) of STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		variable Memory : FIFO_Memory;
		
		variable Head : natural range 0 to FIFO_DEPTH - 1;
		variable Tail : natural range 0 to FIFO_DEPTH - 1;
		
		variable Looped : boolean;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				Head := 0;
				Tail := 0;
				
				Looped   := false;
				
				ProgFull <= '0';
				Full     <= '0';
				Empty    <= '1';
			else
				if (ReadEn = '1') then
					if ((Looped = true) or (Head /= Tail)) then
						-- Update Tail pointer as needed
						if (Tail = FIFO_DEPTH - 1) then
							Tail := 0;
							
							Looped := false;
						else
							Tail := Tail + 1;
						end if;
					end if;
				end if;
				
				if (WriteEn = '1') then
					if ((Looped = false) or (Head /= Tail)) then
						-- Write Data to Memory
						Memory(Head) := DataIn;
						
						-- Increment Head pointer as needed
						if (Head = FIFO_DEPTH - 1) then
							Head := 0;
							
							Looped := true;
						else
							Head := Head + 1;
						end if;
					end if;
				end if;

				-- Update data output
				DataOut <= Memory(Tail);
				
				-- Update Empty and Full flags
				if (Head = Tail) then
					if Looped then
						Full <= '1';
					else
						Empty <= '1';
					end if;
				else
					Empty	<= '0';
					Full	<= '0';
				end if;
				
				-- Update Programable Full Flag
				if Looped then
					if ((FIFO_DEPTH - Tail + Head) >= PROG_FULL) then
						ProgFull <= '1';
					else
					   ProgFull <= '0';
					end if;
				else
					if ((Head - Tail) >= PROG_FULL) then
						ProgFull <= '1';
					else
						ProgFull <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;
		
end Behavioral;