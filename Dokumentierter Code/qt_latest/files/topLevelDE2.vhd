-- Top Level DE2 project
-- For a project using the Intel SoPC Audio Codec Inteface IP

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
ENTITY topLevelDE2 IS
        generic (N: integer :=512; ldN: integer := 9);
        PORT (CLOCK_50,AUD_DACLRCK, AUD_ADCLRCK, 
              AUD_BCLK,AUD_ADCDAT     :IN STD_LOGIC;
              CLOCK2_50     :IN STD_LOGIC;
              KEY           :IN STD_LOGIC_VECTOR(0 DOWNTO 0);
              SW            :in STD_LOGIC_VECTOR(19 DOWNTO 0);
              LEDR          :out Std_LOGIC_VECTOR(19 Downto 0);
				  LEDG			 : out std_logic;
              I2C_SDAT      :INOUT STD_LOGIC;
              I2C_SCLK,AUD_DACDAT,AUD_XCK :OUT STD_LOGIC);
END topLevelDE2;

ARCHITECTURE Struct OF topLevelDE2 IS


        COMPONENT clock_generator
                PORT(   CLOCK2_50                                                                                                               :IN STD_LOGIC;
                        reset                                                                                                                   :IN STD_LOGIC;
                                AUD_XCK                                                                                                         :OUT STD_LOGIC);
        END COMPONENT;

        COMPONENT audio_and_video_config
                PORT(   CLOCK_50,reset                                                                                          :IN STD_LOGIC;
                        I2C_SDAT                                                                                                                :INOUT STD_LOGIC;
                                I2C_SCLK                                                                                                                :OUT STD_LOGIC);
        END COMPONENT;



      COMPONENT audio_codec
              PORT(CLOCK_50,reset,read_s,write_s               :IN STD_LOGIC;
                   writedata_left, writedata_right             :IN STD_LOGIC_VECTOR(23 DOWNTO 0);
                   AUD_ADCDAT,AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK :IN STD_LOGIC;
                   read_ready, write_ready                     :OUT STD_LOGIC;
                   readdata_left, readdata_right               :OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
                   AUD_DACDAT                                                                                                      :OUT STD_LOGIC);
      END COMPONENT;
      component yourCircuit is
        port(clk, reset: in std_logic;
             read_ready, write_ready: in STD_LOGIC;
             readdata_left, readdata_right:    in STD_LOGIC_VECTOR(23 DOWNTO 0);
              writedata_left, writedata_right:  out STD_LOGIC_VECTOR(23 DOWNTO 0);
              read_s, write_s: out STD_LOGIC);
      end component;
		
		  component copy_machine is
        port(clk, reset: in std_logic;
             read_ready, write_ready: in STD_LOGIC;
             readdata_left, readdata_right:    in STD_LOGIC_VECTOR(23 DOWNTO 0);
              writedata_left, writedata_right:  out STD_LOGIC_VECTOR(23 DOWNTO 0);
				  led_out : out STD_LOGIC;
              read_s, write_s: out STD_LOGIC);
      end component;
		
	
		
		signal led_on_off : std_logic;
      signal read_s, write_s, read_ready, write_ready: std_LOGIC;
      signal writedata_left, writedata_right, readdata_left, readdata_right: STD_LOGIC_VECTOR(23 DOWNTO 0); 
      signal reset: std_logic;
		
BEGIN
        cgen: clock_generator port map (cloCK2_50, reset, AUD_XCK);
        avIntf: audio_and_video_config
                PORT map(CLOCK_50,reset ,I2C_SDAT, I2C_SCLK);
        audio: audio_codec
          port map (CLOCK_50, reset, read_s, write_s,
                    writedata_left, writedata_right             ,
                    AUD_ADCDAT,AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK ,
                    read_ready, write_ready                     ,
                    readdata_left, readdata_right               ,
                    AUD_DACDAT);
        processing: copy_machine 
          port map(clock_50, reset, read_ready, write_ready, 
                   readdata_left, readdata_right,
                   writedata_left, writedata_right,
						 led_on_off,
                   read_s, write_s);
		
			
		
						 
        reset <= not key(0);
		  
		  
		  LEDG <= led_on_off;
		  

END Struct;