-- Copyright (C) 1988-2002 Altera Corporation
-- Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
-- support information,  device programming or simulation file,  and any other
-- associated  documentation or information  provided by  Altera  or a partner
-- under  Altera's   Megafunction   Partnership   Program  may  be  used  only
-- to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
-- other  use  of such  megafunction  design,  netlist,  support  information,
-- device programming or simulation file,  or any other  related documentation
-- or information  is prohibited  for  any  other purpose,  including, but not
-- limited to  modification,  reverse engineering,  de-compiling, or use  with
-- any other  silicon devices,  unless such use is  explicitly  licensed under
-- a separate agreement with  Altera  or a megafunction partner.  Title to the
-- intellectual property,  including patents,  copyrights,  trademarks,  trade
-- secrets,  or maskworks,  embodied in any such megafunction design, netlist,
-- support  information,  device programming or simulation file,  or any other
-- related documentation or information provided by  Altera  or a megafunction
-- partner, remains with Altera, the megafunction partner, or their respective
-- licensors. No other licenses, including any licenses needed under any third
-- party's intellectual property, are provided herein.


-- Quartus II 4.1 Build 181 06/29/2004


library IEEE, cyclone;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;
use cyclone.atom_pack.all;

package CYCLONE_COMPONENTS is

--
-- CYCLONE_LCELL
--
  
component cyclone_lcell
  generic 
    (
      operation_mode  : string := "normal";
      synch_mode      : string := "off";
      register_cascade_mode   : string := "off";
      sum_lutc_input  : string := "datac";
      lut_mask        : string := "ffff";
      power_up        : string := "low";
      cin0_used       : string := "false";
      cin1_used       : string := "false";
      cin_used        : string := "false";
      output_mode     : string := "comb_only";
      lpm_type        : string := "cyclone_lcell";
      x_on_violation  : string := "on"
      );
  port
    (
      clk       : in std_logic := '0';
      dataa     : in std_logic := '1';
      datab     : in std_logic := '1';
      datac     : in std_logic := '1';
      datad     : in std_logic := '1';
      aclr      : in std_logic := '0';
      aload     : in std_logic := '0';
      sclr      : in std_logic := '0';
      sload     : in std_logic := '0';
      ena       : in std_logic := '1';
      cin       : in std_logic := '0';
      cin0      : in std_logic := '0';
      cin1      : in std_logic := '1';
      inverta   : in std_logic := '0';
      regcascin : in std_logic := '0';
      devclrn   : in std_logic := '1';
      devpor    : in std_logic := '1';
      combout   : out std_logic;
      regout    : out std_logic;
      cout      : out std_logic;
      cout0     : out std_logic;
      cout1     : out std_logic
      );
end component;

--
-- CYCLONE_RAM_BLOCK
--

component cyclone_ram_block
  generic 
    (
      operation_mode            : string := "single_port";
      mixed_port_feed_through_mode : string := "dont_care"; 
      ram_block_type            : string := "auto"; 
      logical_ram_name          : string := "ram_name"; 
      init_file                 : string := "init_file.hex"; 
      init_file_layout          : string := "none";
      data_interleave_width_in_bits : integer := 1;
      data_interleave_offset_in_bits : integer := 1;
      port_a_logical_ram_depth  : integer := 0;
      port_a_logical_ram_width  : integer := 0;
      port_a_data_in_clear      : string := "none";
      port_a_address_clear      : string := "none";
      port_a_write_enable_clear : string := "none";
      port_a_data_out_clock     : string := "none";
      port_a_data_out_clear     : string := "none";
      port_a_first_address      : integer := 0;
      port_a_last_address       : integer := 0;
      port_a_first_bit_number   : integer := 0;
      port_a_data_width         : integer := 144;
      port_a_byte_enable_clear  : string := "none";
      port_a_data_in_clock      : string := "clock0"; 
      port_a_address_clock      : string := "clock0"; 
      port_a_write_enable_clock : string := "clock0";
      port_a_byte_enable_clock  : string := "clock0";
      port_b_logical_ram_depth  : integer := 0;
      port_b_logical_ram_width  : integer := 0;
      port_b_data_in_clock      : string := "none";
      port_b_data_in_clear      : string := "none";
      port_b_address_clock      : string := "none";
      port_b_address_clear      : string := "none";
      port_b_read_enable_write_enable_clock : string := "none";
      port_b_read_enable_write_enable_clear : string := "none";
      port_b_data_out_clock     : string := "none";
      port_b_data_out_clear     : string := "none";
      port_b_first_address      : integer := 0;
      port_b_last_address       : integer := 0;
      port_b_first_bit_number   : integer := 0;
      port_b_data_width         : integer := 72;
      port_b_byte_enable_clear  : string := "none";
      port_b_byte_enable_clock  : string := "none";
      port_a_address_width      : integer := 16; 
      port_b_address_width      : integer := 16; 
      port_a_byte_enable_mask_width : integer := 0; 
      port_b_byte_enable_mask_width : integer := 0; 
      power_up_uninitialized	: string := "false";
      lpm_type                  : string := "cyclone_ram_block";
      connectivity_checking     : string := "off";
      mem1 : std_logic_vector(512 downto 1) := (OTHERS => '0');
      mem2 : std_logic_vector(512 downto 1) := (OTHERS => '0');
      mem3 : std_logic_vector(512 downto 1) := (OTHERS => '0');
      mem4 : std_logic_vector(512 downto 1) := (OTHERS => '0');
      mem5 : std_logic_vector(512 downto 1) := (OTHERS => '0');
      mem6 : std_logic_vector(512 downto 1) := (OTHERS => '0');
      mem7 : std_logic_vector(512 downto 1) := (OTHERS => '0');
      mem8 : std_logic_vector(512 downto 1) := (OTHERS => '0');
      mem9 : std_logic_vector(512 downto 1) := (OTHERS => '0')
    );
  port
    (
      portawe           : in std_logic := '0';
      portabyteenamasks : in std_logic_vector (15 downto 0) := (others => '1');
      portbbyteenamasks : in std_logic_vector (15 downto 0) := (others => '1');
      portbrewe         : in std_logic := '0';
      clr0              : in std_logic := '0';
      clr1              : in std_logic := '0';
      clk0              : in std_logic := '0';
      clk1              : in std_logic := '0';
      ena0              : in std_logic := '1';
      ena1              : in std_logic := '1';
      portadatain       : in std_logic_vector (143 downto 0) := (others => '0');
      portbdatain       : in std_logic_vector (71 downto 0) := (others => '0');
      portaaddr         : in std_logic_vector (15 downto 0) := (others => '0');
      portbaddr         : in std_logic_vector (15 downto 0) := (others => '0');
      devclrn           : in std_logic := '1';
      devpor            : in std_logic := '1';
      portadataout      : out std_logic_vector (143 downto 0);
      portbdataout      : out std_logic_vector (143 downto 0)
    );
end component;

--
-- CYCLONE_PLL
--

COMPONENT cyclone_pll
    GENERIC (operation_mode              : string := "normal";
             qualify_conf_done           : string := "off";
             compensate_clock            : string := "clk0";
             pll_type                    : string := "auto";
             scan_chain                  : string := "long";
             lpm_type                    : string := "cyclone_pll";

             clk0_multiply_by            : integer := 1;
             clk0_divide_by              : integer := 1;
             clk0_phase_shift            : string := "0";
             clk0_time_delay             : string := "0";
             clk0_duty_cycle             : integer := 50;

             clk1_multiply_by            : integer := 1;
             clk1_divide_by              : integer := 1;
             clk1_phase_shift            : string := "0";
             clk1_time_delay             : string := "0";
             clk1_duty_cycle             : integer := 50;

             clk2_multiply_by            : integer := 1;
             clk2_divide_by              : integer := 1;
             clk2_phase_shift            : string := "0";
             clk2_time_delay             : string := "0";
             clk2_duty_cycle             : integer := 50;

             clk3_multiply_by            : integer := 1;
             clk3_divide_by              : integer := 1;
             clk3_phase_shift            : string := "0";
             clk3_time_delay             : string := "0";
             clk3_duty_cycle             : integer := 50;

             clk4_multiply_by            : integer := 1;
             clk4_divide_by              : integer := 1;
             clk4_phase_shift            : string := "0";
             clk4_time_delay             : string := "0";
             clk4_duty_cycle             : integer := 50;

             clk5_multiply_by            : integer := 1;
             clk5_divide_by              : integer := 1;
             clk5_phase_shift            : string := "0";
             clk5_time_delay             : string := "0";
             clk5_duty_cycle             : integer := 50;

             extclk0_multiply_by         : integer := 1;
             extclk0_divide_by           : integer := 1;
             extclk0_phase_shift         : string := "0";
             extclk0_time_delay          : string := "0";
             extclk0_duty_cycle          : integer := 50;

             extclk1_multiply_by         : integer := 1;
             extclk1_divide_by           : integer := 1;
             extclk1_phase_shift         : string := "0";
             extclk1_time_delay          : string := "0";
             extclk1_duty_cycle          : integer := 50;

             extclk2_multiply_by         : integer := 1;
             extclk2_divide_by           : integer := 1;
             extclk2_phase_shift         : string := "0";
             extclk2_time_delay          : string := "0";
             extclk2_duty_cycle          : integer := 50;

             extclk3_multiply_by         : integer := 1;
             extclk3_divide_by           : integer := 1;
             extclk3_phase_shift         : string := "0";
             extclk3_time_delay          : string := "0";
             extclk3_duty_cycle          : integer := 50;

             primary_clock               : string := "inclk0";
             inclk0_input_frequency      : integer := 10000;
             inclk1_input_frequency      : integer := 10000;
             gate_lock_signal            : string := "yes";
             gate_lock_counter           : integer := 1;
             valid_lock_multiplier       : integer := 5;
             invalid_lock_multiplier     : integer := 5;
             switch_over_on_lossclk      : string := "off";
             switch_over_on_gated_lock   : string := "off";
             enable_switch_over_counter  : string := "off";
             switch_over_counter         : integer := 1;
             feedback_source             : string := "e0";
             bandwidth_type              : string := "auto";
             bandwidth                   : integer := 0;
             spread_frequency            : integer := 0;
             down_spread                 : string := "0 %";
             common_rx_tx                : string := "off";
             rx_outclock_resource        : string := "auto";
             use_vco_bypass              : string := "false";
             use_dc_coupling             : string := "false";

             pfd_min                     : integer := 0;
             pfd_max                     : integer := 0;
             vco_min                     : integer := 0;
             vco_max                     : integer := 0;
             vco_center                  : integer := 0;

             -- ADVANCED USE PARAMETERS
             m_initial                   : integer := 1;
             m                           : integer := 1;
             n                           : integer := 1;
             m2                          : integer := 1;
             n2                          : integer := 1;
             ss                          : integer := 0;

             l0_high                     : integer := 1;
             l0_low                      : integer := 1;
             l0_initial                  : integer := 1;
             l0_mode                     : string := "bypass";
             l0_ph                       : integer := 0;
             l0_time_delay               : integer := 0;

             l1_high                     : integer := 1;
             l1_low                      : integer := 1;
             l1_initial                  : integer := 1;
             l1_mode                     : string := "bypass";
             l1_ph                       : integer := 0;
             l1_time_delay               : integer := 0;

             g0_high                     : integer := 1;
             g0_low                      : integer := 1;
             g0_initial                  : integer := 1;
             g0_mode                     : string := "bypass";
             g0_ph                       : integer := 0;
             g0_time_delay               : integer := 0;

             g1_high                     : integer := 1;
             g1_low                      : integer := 1;
             g1_initial                  : integer := 1;
             g1_mode                     : string := "bypass";
             g1_ph                       : integer := 0;
             g1_time_delay               : integer := 0;

             g2_high                     : integer := 1;
             g2_low                      : integer := 1;
             g2_initial                  : integer := 1;
             g2_mode                     : string := "bypass";
             g2_ph                       : integer := 0;
             g2_time_delay               : integer := 0;

             g3_high                     : integer := 1;
             g3_low                      : integer := 1;
             g3_initial                  : integer := 1;
             g3_mode                     : string := "bypass";
             g3_ph                       : integer := 0;
             g3_time_delay               : integer := 0;

             e0_high                     : integer := 1;
             e0_low                      : integer := 1;
             e0_initial                  : integer := 1;
             e0_mode                     : string := "bypass";
             e0_ph                       : integer := 0;
             e0_time_delay               : integer := 0;

             e1_high                     : integer := 1;
             e1_low                      : integer := 1;
             e1_initial                  : integer := 1;
             e1_mode                     : string := "bypass";
             e1_ph                       : integer := 0;
             e1_time_delay               : integer := 0;

             e2_high                     : integer := 1;
             e2_low                      : integer := 1;
             e2_initial                  : integer := 1;
             e2_mode                     : string := "bypass";
             e2_ph                       : integer := 0;
             e2_time_delay               : integer := 0;

             e3_high                     : integer := 1;
             e3_low                      : integer := 1;
             e3_initial                  : integer := 1;
             e3_mode                     : string := "bypass";
             e3_ph                       : integer := 0;
             e3_time_delay               : integer := 0;

             m_ph                        : integer := 0;
             m_time_delay                : integer := 0;
             n_time_delay                : integer := 0;

             extclk0_counter             : string := "e0";
             extclk1_counter             : string := "e1";
             extclk2_counter             : string := "e2";
             extclk3_counter             : string := "e3";
             clk0_counter                : string := "g0";
             clk1_counter                : string := "g1";
             clk2_counter                : string := "g2";
             clk3_counter                : string := "g3";
             clk4_counter                : string := "l0";
             clk5_counter                : string := "l1";
             enable0_counter             : string := "l0";
             enable1_counter             : string := "l0";

             charge_pump_current         : integer := 0;
             loop_filter_c               : integer := 1;
             loop_filter_r               : string := "1.0" ;

             pll_compensation_delay      : integer := 0;
             simulation_type             : string := "timing";
             source_is_pll               : string := "off";
             skip_vco                    : string := "off";

             XOn: Boolean                := DefGlitchXOn;
             MsgOn: Boolean              := DefGlitchMsgOn;
             tipd_inclk                  : VitalDelayArrayType01(1 downto 0) := (OTHERS => DefPropDelay01);
             tipd_clkena                 : VitalDelayArrayType01(5 downto 0) := (OTHERS => DefPropDelay01);
             tipd_extclkena              : VitalDelayArrayType01(3 downto 0) := (OTHERS => DefPropDelay01);
             tipd_ena                    : VitalDelayType01 := DefPropDelay01;
             tipd_pfdena                 : VitalDelayType01 := DefPropDelay01;
             tipd_areset                 : VitalDelayType01 := DefPropDelay01;
             tipd_fbin                   : VitalDelayType01 := DefPropDelay01;
             tipd_scanclk                : VitalDelayType01 := DefPropDelay01;
             tipd_scanaclr               : VitalDelayType01 := DefPropDelay01;
             tipd_scandata               : VitalDelayType01 := DefPropDelay01;
             tipd_comparator             : VitalDelayType01 := DefPropDelay01

            );

    PORT    (inclk          : IN std_logic_vector(1 downto 0);
             fbin           : IN std_logic := '0';
             ena            : IN std_logic := '1';
             clkswitch      : IN std_logic := '0';
             areset         : IN std_logic := '0';
             pfdena         : IN std_logic := '1';
             clkena         : IN std_logic_vector(5 downto 0) := "111111";
             extclkena      : IN std_logic_vector(3 downto 0) := "1111";
             scanaclr       : IN std_logic := '0';
             scandata       : IN std_logic := '0';
             scanclk        : IN std_logic := '0';
             clk            : OUT std_logic_vector(5 downto 0);
             extclk         : OUT std_logic_vector(3 downto 0);
             clkbad         : OUT std_logic_vector(1 downto 0);
             activeclock    : OUT std_logic;
             locked         : OUT std_logic;
             clkloss        : OUT std_logic;
             scandataout    : OUT std_logic;
             -- lvds specific ports
             comparator     : IN std_logic := '0';
             enable0        : OUT std_logic;
             enable1        : OUT std_logic
            );
END COMPONENT;
--
-- CYCLONE_DLL
--

COMPONENT cyclone_dll
    GENERIC ( input_frequency   : string  := "10000 ps";
              phase_shift       : string  := "0";
              sim_valid_lock    : integer := 1;
              sim_invalid_lock  : integer := 5;
              lpm_type          : string  := "cyclone_dll"
            );

    PORT    (clk            : IN std_logic;
             delayctrlout   : OUT std_logic
            );
END COMPONENT;
--
-- CYCLONE_JTAG
--

component  cyclone_jtag 
	 generic (
					lpm_type	: string := "cyclone_jtag"
				);
    port (tms : in std_logic := '0'; 
    		 tck : in std_logic := '0'; 
    		 tdi : in std_logic := '0'; 
    		 ntrst : in std_logic := '0'; 
    		 tdoutap : in std_logic := '0'; 
    		 tdouser : in std_logic := '0'; 
          tdo: out std_logic; 
          tmsutap: out std_logic; 
          tckutap: out std_logic; 
          tdiutap: out std_logic; 
          shiftuser: out std_logic; 
          clkdruser: out std_logic; 
          updateuser: out std_logic; 
          runidleuser: out std_logic; 
          usr1user: out std_logic);
end component;

--
--
--  CYCLONE_CRCBLOCK 
--
--

component  cyclone_crcblock 
	generic 	(
					oscillator_divider	: integer := 1;
					lpm_type	: string := "cyclone_crcblock"
				);
	port (clk 			: in std_logic := '0'; 
   		shiftnld		: in std_logic := '0'; 
    		ldsrc			: in std_logic := '0'; 
         crcerror		: out std_logic; 
         regout		: out std_logic); 
end component;
--
-- CYCLONE_IO
--

component cyclone_io
    generic (
		operation_mode : string := "input";
		open_drain_output : string := "false";
		bus_hold : string := "false";
		output_register_mode : string := "none";
		output_async_reset : string := "none";
		output_sync_reset : string := "none";
		output_power_up : string := "low";
		tie_off_output_clock_enable : string := "false";
		oe_register_mode : string := "none";
		oe_async_reset : string := "none";
		oe_sync_reset : string := "none";
		oe_power_up : string := "low";
		tie_off_oe_clock_enable : string := "false";
		input_register_mode : string := "none";
		input_async_reset : string := "none";
		input_sync_reset : string := "none";
		input_power_up : string := "low");
	port (
		datain          : in std_logic := '0';
		oe              : in std_logic := '1';
		outclk          : in std_logic := '0';
		outclkena       : in std_logic := '1';
		inclk           : in std_logic := '0';
		inclkena        : in std_logic := '1';
		areset          : in std_logic := '0';
		sreset          : in std_logic := '0';
		devclrn         : in std_logic := '1';
		devpor          : in std_logic := '1';
		devoe           : in std_logic := '0';
		combout         : out std_logic;
		regout          : out std_logic;
		padio           : inout std_logic);
end component;

--
-- CYCLONE_ASMIBLOCK
--
component  cyclone_asmiblock
	 generic (
					lpm_type	: string := "cyclone_asmiblock"
				);	
    port (
          dclkin : in std_logic; 
    		 scein : in std_logic; 
    		 sdoin : in std_logic; 
    		 oe : in std_logic; 
          data0out: out std_logic
         );

end component;


end cyclone_components;
