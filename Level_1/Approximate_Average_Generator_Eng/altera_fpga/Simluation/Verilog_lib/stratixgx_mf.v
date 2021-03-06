//
// Copyright (C) Altera Corporation
//
// Any megafunction design, and related net list (encrypted or decrypted),
// support information, device programming or simulation file, and any
// other associated documentation or information provided by Altera or a
// partner under Altera's Megafunction Partnership Program may be used only
// to program PLD devices (but not masked PLD devices) from Altera.  Any
// other use of such megafunction design, net list, support information,
// device programming or simulation file, or any other related
// documentation or information is prohibited for any other purpose,
// including, but not limited to modification, reverse engineering, de-
// compiling, or use with any other silicon devices, unless such use is
// explicitly licensed under a separate agreement with Altera or a
// megafunction partner.  Title to the intellectual property, including
// patents, copyrights, trademarks, trade secrets, or maskworks, embodied
// in any such megafunction design, net list, support information, device
// programming or simulation file, or any other related documentation or
// information provided by Altera or a megafunction partner, remains with
// Altera, the megafunction partner, or their respective licensors.  No
// other licenses, including any licenses needed under any third party's
// intellectual property, are provided herein.
//--------------------------------------------------------------------------
// Stratix GX Megafunction Simulation File
//
//--------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////
//
//                           altgxb megafunction
//
///////////////////////////////////////////////////////////////////////////////



`define HSSI_MAXCDR  20
`define HSSI_MAXQUAD  5
`define HSSI_MAXCWIDTH 20
`define HSSI_MAXDIV   1000000000000.0


`timescale 1 ps / 1 ps

module altgxb (
               inclk, 
               pll_areset, 
               rx_in, 
               rx_coreclk, 
               rx_cruclk, 
               rx_aclr, 
               rx_bitslip,                
               rx_enacdet, 
               rx_we, 
               rx_re, 
               rx_slpbk, 
               rx_a1a2size, 
               rx_equalizerctrl, 
               rx_locktorefclk, 
               rx_locktodata,
               tx_in, 
               tx_coreclk, 
               tx_aclr, 
               tx_ctrlenable, 
               tx_forcedisparity, 
               tx_srlpbk, 
               tx_vodctrl,                
               tx_preemphasisctrl,
               txdigitalreset, 
               rxdigitalreset, 
               rxanalogreset, 
               pllenable,
               pll_locked, 
               coreclk_out, 
               rx_out, 
               rx_clkout, 
               rx_locked, 
               rx_freqlocked, 
               rx_rlv, 
               rx_syncstatus,
               rx_patterndetect, 
               rx_ctrldetect, 
               rx_errdetect, 
               rx_disperr, 
               rx_signaldetect,
//               rx_fifoempty, 
//               rx_fifofull, 
               rx_fifoalmostempty, 
               rx_fifoalmostfull,                
               rx_channelaligned,
               rx_bisterr, 
               rx_bistdone, 
               rx_a1a2sizeout,
               tx_out);
    


    parameter operation_mode = "DUPLEX";     // Other modes- "RX", "TX", "DUPLEX"
    parameter loopback_mode = "NONE"; // "SLB", "RSLB", "PLB", "RPLB", "P8LB"
    parameter reverse_loopback_mode = "NONE";
    parameter protocol  = "NONE";     // Other protocols -  "GIGE", "INFINIBAND", "RAPIDIO", "FIBRECHANNEL"
    parameter number_of_channels = 20;
    parameter number_of_quads = 1;
    parameter channel_width = 10;
    parameter pll_inclock_period = 20000;       // 20000ps = 50MHz
    parameter data_rate = 0;  // May be unused
    parameter data_rate_remainder = 0;  // 2.2 

    parameter use_8b_10b_mode = "OFF";
    parameter use_double_data_mode = "OFF";
    parameter dwidth_factor = 2;

   // RX mode
    parameter disparity_mode = "OFF";
    parameter cru_inclock_period = 0;
    parameter run_length = 128;              
    parameter run_length_enable = "OFF";              
    parameter use_channel_align = "OFF";
    parameter use_auto_bit_slip  = "ON";

    parameter use_symbol_align = "ON";
    parameter align_pattern = "0000000101111100";
    parameter align_pattern_length = 10;
    parameter infiniband_invalid_code = 0; 
    parameter clk_out_mode_reference = "ON";
    parameter use_rate_match_fifo = "ON";
    parameter tx_termination = 0; // new in 3.0
    parameter use_fifo_mode = "ON";

    parameter for_engineering_sample_device = "ON"; // new in 3.0 sp2
    // TX mode

    parameter intended_device_family = "ALTGXB";
    parameter force_disparity_mode = "OFF";
    parameter lpm_type = "altgxb";
    
    // Quartus 2.2 new parameters
    // common
    parameter use_self_test_mode = "OFF";
    parameter self_test_mode = 0;

    // Receiver
    parameter use_equalizer_ctrl_signal = "OFF";
    parameter equalizer_ctrl_setting = 0;
    parameter signal_threshold_select = 80;
    parameter rx_bandwidth_type = "NEW_MEDIUM";
    parameter rx_enable_dc_coupling = "OFF";
    parameter use_vod_ctrl_signal = "OFF";
    parameter vod_ctrl_setting = 1000;
    parameter use_preemphasis_ctrl_signal = "OFF";
    parameter preemphasis_ctrl_setting = 0;
    parameter use_phase_shift = "ON";
    parameter pll_bandwidth_type = "LOW";
    parameter pll_use_dc_coupling = "OFF";
    parameter rx_ppm_setting = 1000;
    parameter device_family = "";
    parameter use_rx_cruclk = "OFF";
    parameter use_rx_clkout = "OFF";

    parameter use_rx_coreclk   = "OFF";
    parameter use_tx_coreclk   = "OFF";
    parameter instantiate_transmitter_pll = "OFF";
    parameter consider_instantiate_transmitter_pll_param = "OFF";
    parameter use_generic_fifo   = "OFF";
    parameter rx_force_signal_detect = "OFF";
    parameter flip_rx_out = "OFF";
    parameter flip_tx_in = "OFF";
    parameter add_generic_fifo_we_synch_register = "OFF";
    parameter consider_enable_tx_8b_10b_i1i2_generation = "OFF";
    parameter enable_tx_8b_10b_i1i2_generation = "OFF";

    parameter rx_channel_width = (((use_generic_fifo == "ON") || (clk_out_mode_reference == "OFF")) &&
                                 ((channel_width == 16)    ||
                                   (channel_width == 20)))? channel_width/2: channel_width;

    parameter rx_channel_width_div2  = rx_channel_width/2;
    parameter channel_width_div2  = channel_width/2;
    parameter rx_use_double_data_mode = (clk_out_mode_reference == "OFF")?"OFF":use_double_data_mode;


    
    parameter rx_dwidth_factor = (((use_generic_fifo == "ON") || (clk_out_mode_reference == "OFF")) &&
                                  (dwidth_factor == 2))? dwidth_factor/2: dwidth_factor;



    parameter c_align_pattern = (align_pattern_length <= 0)?" ":align_pattern[8 * (align_pattern_length)-1:0];

    parameter deserialization_factor =  (use_8b_10b_mode == "ON")?
                                        10:((use_double_data_mode== "ON")?channel_width/2:channel_width);
   


    parameter rx_data_rate = 0;  // May be unused
    parameter rx_data_rate_remainder = 0;  // 2.2 


    parameter pll_data_rate = (data_rate > 0)?data_rate : rx_data_rate;
    parameter pll_data_rate_remainder = (data_rate_remainder > 0)?data_rate_remainder : rx_data_rate_remainder;


    parameter cru_data_rate = (rx_data_rate > 0)?rx_data_rate : data_rate;
    parameter cru_data_rate_remainder = (rx_data_rate_remainder > 0)?rx_data_rate_remainder : data_rate_remainder;


    parameter pll_mult_value = (((pll_data_rate * 100 + pll_data_rate_remainder/10000) * 
                                  pll_inclock_period)/ 1000000  + 50)/100;

    parameter pllclk_mult = (pll_mult_value == 5)?pll_mult_value:pll_mult_value/2;
    parameter pllclk0_div = (pll_mult_value == 5)?2 : 1;
    parameter pllclk_div_adj = (pll_mult_value == 5)?1 : 2;

    parameter int_cru_inclock_period = (cru_inclock_period ==0)?
                                       (pll_inclock_period * deserialization_factor/pll_mult_value):cru_inclock_period;

    
    parameter cru_mult_value = (((cru_data_rate * 100 + cru_data_rate_remainder/10000) * 
                                  int_cru_inclock_period)/ 1000000 + 50)/100;


    parameter cruclk_div = ((cru_inclock_period > 0) && ((cru_mult_value == 4) || (cru_mult_value == 5)))?"ON":"OFF";
    parameter cruclk_mult = ((cru_mult_value == 4) || (cru_mult_value == 5))?cru_mult_value:cru_mult_value/2;
    parameter pllclk2_divisor = (use_double_data_mode == "ON")?deserialization_factor*2:deserialization_factor;





    parameter protocol_to_mode = ((protocol == "XAUI") || (protocol == "XAUI"))?"XAUI":
                           ((protocol == "GIGE") || (protocol == "GIGE"))?"GIGE":"NONE";


     
    parameter tx_transmit_protocol = 
            (consider_enable_tx_8b_10b_i1i2_generation == "OFF")? protocol_to_mode:
              ((protocol == "XAUI") || (protocol == "XAUI"))?"XAUI":
                 (enable_tx_8b_10b_i1i2_generation == "ON")?"GIGE":"NONE";
                           




    // To support for bypass all design - the symbol_align cannot bypass
    parameter d_use_symbol_align = (use_symbol_align == "OFF")?"ON":use_symbol_align;
    parameter d_use_auto_bit_slip = (use_symbol_align == "OFF")?"ON":use_auto_bit_slip;
    parameter d_protocol_to_mode = (use_symbol_align == "OFF")?"NONE":protocol_to_mode;
    parameter d_align_pattern_length = (use_symbol_align == "OFF")?
                                       ((deserialization_factor == 10)?10:16):align_pattern_length;
    parameter d_align_pattern = (use_symbol_align == "OFF")?
        ((deserialization_factor == 10)?"0101111100":"0000111100001111"):c_align_pattern;



    // Common input ports for Rx and Tx mode
    input [number_of_quads-1:0] inclk;
//    input [number_of_channels-1:0] coreclk;
    input [number_of_quads-1:0] pll_areset; // tri0



    // Input ports for RX mode
    input [number_of_channels-1:0] rx_in;
    input [number_of_channels-1:0] rx_coreclk;
    input [number_of_quads-1:0]    rx_cruclk;
    input [number_of_channels-1:0] rx_aclr;    // tri0
    input [number_of_channels-1:0] rx_bitslip;
    input [number_of_channels-1:0] rx_enacdet;
    input [number_of_channels-1:0] rx_we;
    input [number_of_channels-1:0] rx_re;
    input [number_of_channels-1:0] rx_slpbk;
    input [number_of_channels-1:0] rx_a1a2size;
    input [number_of_channels * 3-1:0] rx_equalizerctrl;
    input [number_of_channels-1:0] rx_locktorefclk;
    input [number_of_channels-1:0] rx_locktodata;







    // Input ports for TX mode
    input [channel_width * number_of_channels-1:0] tx_in;
    input [number_of_channels-1:0] tx_coreclk;
    input [number_of_channels-1:0] tx_aclr;  // tri0
    input [dwidth_factor * number_of_channels-1:0] tx_ctrlenable;
    input [dwidth_factor * number_of_channels-1:0] tx_forcedisparity;
    input [number_of_channels-1:0] tx_srlpbk;
    input [number_of_channels * 3-1:0] tx_vodctrl;
    input [number_of_channels * 3-1:0] tx_preemphasisctrl;

    // XGM Input ports, common for Both Rx and Tx Mode

    input [number_of_channels - 1:0] txdigitalreset;
    input [number_of_channels - 1:0] rxdigitalreset;
    input [number_of_channels - 1:0] rxanalogreset;
    input [number_of_quads - 1:0]     pllenable;




  
    // Common output ports for RX and TX mode
    output [number_of_quads-1:0] pll_locked;
    output [number_of_quads-1:0] coreclk_out;

   // Output ports for RX mode
    output [rx_channel_width*number_of_channels-1:0] rx_out;
    output [number_of_channels-1:0] rx_clkout;
    output [number_of_channels-1:0] rx_locked;
    output [number_of_channels-1:0] rx_freqlocked;
    output [number_of_channels-1:0] rx_rlv;
    output [rx_dwidth_factor * number_of_channels-1:0] rx_syncstatus;
    output [rx_dwidth_factor * number_of_channels-1:0] rx_patterndetect;
    output [rx_dwidth_factor * number_of_channels-1:0] rx_ctrldetect;
    output [rx_dwidth_factor * number_of_channels-1:0] rx_errdetect;
    output [rx_dwidth_factor * number_of_channels-1:0] rx_disperr;
    output [number_of_channels-1:0] rx_signaldetect;
//    output [number_of_channels-1:0] rx_fifoempty;
//    output [number_of_channels-1:0] rx_fifofull;
    output [number_of_channels-1:0] rx_fifoalmostempty;
    output [number_of_channels-1:0] rx_fifoalmostfull;
    output [number_of_quads-1:0] rx_channelaligned;
    output [number_of_channels-1:0] rx_bisterr;
    output [number_of_channels-1:0] rx_bistdone;
    output [rx_dwidth_factor * number_of_channels-1:0] rx_a1a2sizeout;


   // Output ports for TX mode
    output [number_of_channels-1:0] tx_out;

   // Output ports from XGM State Machines
//    output [number_of_quads-1:0] xgm_alignstatus;


    // Variables  for Receivers
    reg  [`HSSI_MAXCDR-1:0] i_rx_in;
                            
    reg  [`HSSI_MAXCDR-1:0] i_rx_bitslip;
    reg  [`HSSI_MAXCDR-1:0] i_rx_enacdet;
    reg  [`HSSI_MAXCDR-1:0] i_rx_we;
    reg  [`HSSI_MAXCDR-1:0] i_rx_re;
    reg  [`HSSI_MAXCDR-1:0] i_rx_slpbk;

    reg  [`HSSI_MAXCDR-1:0] i_rx_coreclk;


    // 2.2 Input Ports

    tri0  [`HSSI_MAXCDR-1:0] i_rx_a1a2size;
    reg  [`HSSI_MAXCDR * 3-1:0] i_rx_equalizerctrl;
    reg  [`HSSI_MAXCDR-1:0] i_rx_locktorefclk;
    reg  [`HSSI_MAXCDR-1:0] i_rx_locktodata;


    reg  [`HSSI_MAXCDR * 3-1:0] i_tx_vodctrl;
    reg  [`HSSI_MAXCDR * 3-1:0] i_tx_preemphasisctrl;
    


    wire w_rx_inclk0;
    wire [2 * `HSSI_MAXCDR-1:0] i_rx_syncstatus;
    wire [2 * `HSSI_MAXCDR-1:0] i_rx_patterndetect;
    wire [2 * `HSSI_MAXCDR-1:0] i_rx_ctrldetect;
    wire [2 * `HSSI_MAXCDR-1:0] i_rx_errdetect;
    wire [2 * `HSSI_MAXCDR-1:0] i_rx_disperr;


    reg [2 * `HSSI_MAXCDR-1:0] t_rx_syncstatus;
    reg [2 * `HSSI_MAXCDR-1:0] t_rx_patterndetect;
    reg [2 * `HSSI_MAXCDR-1:0] t_rx_ctrldetect;
    reg [2 * `HSSI_MAXCDR-1:0] t_rx_errdetect;
    reg [2 * `HSSI_MAXCDR-1:0] t_rx_disperr;




    wire  [`HSSI_MAXCDR-1:0] rx_fifofull;
    wire  [`HSSI_MAXCDR-1:0] rx_fifoempty;



    wire  [`HSSI_MAXCDR-1:0] i_rx_syncstatusdeskew;
    wire  [`HSSI_MAXCDR-1:0] i_rx_adetectdeskew;
    wire  [`HSSI_MAXCDR-1:0] i_rx_fifofull;
    wire  [`HSSI_MAXCDR-1:0] i_rx_fifoempty;
    wire  [`HSSI_MAXCDR-1:0] i_rx_fifoalmostfull;
    wire  [`HSSI_MAXCDR-1:0] i_rx_fifoalmostempty;
    wire  [`HSSI_MAXCDR-1:0] i_rx_signaldetect;

    wire  [`HSSI_MAXCDR-1:0] i_rx_locked;
    wire  [`HSSI_MAXCDR-1:0] i_rx_freqlocked;
    wire  [`HSSI_MAXCDR-1:0] i_rx_rlv;
    wire  [`HSSI_MAXCDR-1:0] i_rx_clkout;
    wire  [`HSSI_MAXCDR-1:0] i_rx_recovclkout;


   // 2.2 New Output ports
    wire  [`HSSI_MAXCDR-1:0] i_rx_bisterr;
    wire  [`HSSI_MAXCDR-1:0] i_rx_bistdone;
    wire  [2 * `HSSI_MAXCDR-1:0] i_rx_a1a2sizeout;
    reg  [2 * `HSSI_MAXCDR-1:0] t_rx_a1a2sizeout;



  
    wire  [rx_channel_width * 4 -1:0] w_rx_out00;
    wire  [rx_channel_width * 4 -1:0] w_rx_out01;
    wire  [rx_channel_width * 4 -1:0] w_rx_out02;
    wire  [rx_channel_width * 4 -1:0] w_rx_out03;
    wire  [rx_channel_width * 4 -1:0] w_rx_out04;


    reg  [channel_width * 4 -1:0] w_tx_in00;
    reg  [channel_width * 4 -1:0] w_tx_in01;
    reg  [channel_width * 4 -1:0] w_tx_in02;
    reg  [channel_width * 4 -1:0] w_tx_in03;
    reg  [channel_width * 4 -1:0] w_tx_in04;

    reg   [rx_channel_width*`HSSI_MAXCDR-1:0] t_rx_out;

    reg   [rx_channel_width*`HSSI_MAXCDR-1:0] i_rx_out;
    reg   [rx_channel_width*`HSSI_MAXCDR-1:0] i_w_rx_out;

    // Variables  for Transmitters

    wire  [`HSSI_MAXCDR-1:0] w_tx_out;


    reg  [`HSSI_MAXCDR-1:0] i_tx_coreclk;
    reg  [2 * `HSSI_MAXCDR-1:0] i_tx_ctrlenable;
    reg  [2 * `HSSI_MAXCDR-1:0] i_tx_forcedisparity;
    reg  [`HSSI_MAXCDR-1:0] i_tx_srlpbk;


    reg [20 * `HSSI_MAXCDR - 1:0] i_tx_in;
    reg [20 * `HSSI_MAXCDR - 1:0] tx_in_int;













    // Variables for XGM State Machines
    wire [`HSSI_MAXQUAD-1:0] i_pll_locked;
    wire [`HSSI_MAXQUAD-1:0] i_coreclk_out;
    wire [`HSSI_MAXQUAD-1:0] i_rx_channelaligned;

    reg [`HSSI_MAXQUAD-1:0] i_inclk;
    
    reg [`HSSI_MAXQUAD-1:0] i_rx_cruclk;

    reg [`HSSI_MAXCDR  -1:0] i_txdigitalreset;
    reg [`HSSI_MAXCDR  -1:0] i_rxdigitalreset;
    reg [`HSSI_MAXCDR  -1:0] i_rxanalogreset;
//    reg [`HSSI_MAXQUAD-1:0] i_pllenable;


    tri0 [`HSSI_MAXQUAD-1:0] i_pll_areset;
    tri1 [`HSSI_MAXQUAD - 1 : 0] my_pllenable;


  // Variables for PLL Clock

    integer i;
    integer j;
    integer channel_pos;
// Change Parameter to match the atom level
// PLL Stuff


//    wire [8 * (align_pattern_length)-1:0] c_align_pattern;





   specify
      
   endspecify
   
   initial
      begin

      if (operation_mode == "RX")
       begin
       end
      if (operation_mode == "TX")
       begin
       end
      if (operation_mode == "DUPLEX")
       begin
       end

      end
                                                   
    assign my_pllenable = pllenable[number_of_quads - 1 : 0];
    assign i_pll_areset = pll_areset[number_of_quads - 1: 0];
    assign i_rx_a1a2size= rx_a1a2size[number_of_channels - 1: 0];


    hssi_quad quad0 (.inclk(i_inclk[0]), 
                     .rx_coreclk(i_rx_coreclk[3:0]), 
                     .pll_areset(i_pll_areset[0]), 
                     .rx_cruclk(i_rx_cruclk[0]),
                     .rx_in(i_rx_in[3:0]), 
                     .rx_bitslip(i_rx_bitslip[3:0]), 
                     .rx_enacdet(i_rx_enacdet[3:0]), 
                     .rx_we(i_rx_we[3:0]), 
                     .rx_re(i_rx_re[3:0]), 
                     .rx_slpbk(i_rx_slpbk[3:0]), 
                     .rx_a1a2size(i_rx_a1a2size[3:0]), 
                     .rx_equalizerctrl(i_rx_equalizerctrl[11:0]), 
                     .rx_locktorefclk(i_rx_locktorefclk[3:0]), 
                     .rx_locktodata(i_rx_locktodata[3:0]), 
                     .tx_vodctrl(i_tx_vodctrl[11:0]), 
                     .tx_preemphasisctrl(i_tx_preemphasisctrl[11:0]), 
                     .txdigitalreset(i_txdigitalreset[3:0]),
                     .rxdigitalreset(i_rxdigitalreset[3:0]),
                     .rxanalogreset(i_rxanalogreset[3:0]),
                     .pllenable(my_pllenable[0]),

                     .tx_in(w_tx_in00),
                     .tx_coreclk(i_tx_coreclk[3:0]), 
                     .tx_ctrlenable(i_tx_ctrlenable[7:0]), 
                     .tx_forcedisparity(i_tx_forcedisparity[7:0]), 
                     .tx_srlpbk(i_tx_srlpbk[3:0]), 
                     .pll_locked(i_pll_locked[0]),
                     .coreclk_out(i_coreclk_out[0]), 
                     .rx_out(w_rx_out00), 
                     .rx_clkout(i_rx_clkout[3:0]), 
                     .rx_locked(i_rx_locked[3:0]), 
                     .rx_freqlocked(i_rx_freqlocked[3:0]), 
                     .rx_rlv(i_rx_rlv[3:0]),
                     .rx_syncstatus(i_rx_syncstatus[7:0]),
                     .rx_patterndetect(i_rx_patterndetect[7:0]), 
                     .rx_ctrldetect(i_rx_ctrldetect[7:0]), 
                     .rx_errdetect(i_rx_errdetect[7:0]), 
                     .rx_disperr(i_rx_disperr[7:0]),
                     .rx_signaldetect(i_rx_signaldetect[3:0]),
                     .rx_fifoempty(i_rx_fifoempty[3:0]), 
                     .rx_fifofull(i_rx_fifofull[3:0]), 
                     .rx_fifoalmostempty(i_rx_fifoalmostempty[3:0]), 
                     .rx_fifoalmostfull(i_rx_fifoalmostfull[3:0]), 
                     .rx_channelaligned(i_rx_channelaligned[0]),
                     .rx_bisterr(i_rx_bisterr[3:0]),
                     .rx_bistdone(i_rx_bistdone[3:0]),
                     .rx_a1a2sizeout(i_rx_a1a2sizeout[7:0]),
                     .tx_out(w_tx_out[3:0]));
              defparam
                   quad0.operation_mode               = operation_mode,
                   quad0.loopback_mode                = loopback_mode,
                   quad0.reverse_loopback_mode        = reverse_loopback_mode,
                   quad0.pll_inclock_period           = pll_inclock_period,
                   quad0.data_rate                    = data_rate,
                   quad0.number_of_channels           = 4,
                   quad0.channel_width                = channel_width,
                   quad0.rx_channel_width             = rx_channel_width,
                   quad0.rx_dwidth_factor             = rx_dwidth_factor,
                   quad0.c_use_8b_10b_mode            = use_8b_10b_mode,
                   quad0.c_use_double_data_mode       = use_double_data_mode,
                   quad0.rx_use_double_data_mode      = rx_use_double_data_mode,
                   quad0.protocol                     = protocol,
                   quad0.run_length                   = run_length,
                   quad0.run_length_enable            = run_length_enable,
                   quad0.c_use_rate_match_fifo        = use_rate_match_fifo,
                   quad0.c_use_channel_align          = use_channel_align,
                   quad0.protocol_to_mode             = d_protocol_to_mode,
                   quad0.tx_transmit_protocol         = tx_transmit_protocol,
                   quad0.c_use_symbol_align           = d_use_symbol_align,
                   quad0.c_use_auto_bit_slip          = d_use_auto_bit_slip,
                   quad0.align_pattern                = d_align_pattern,
                   quad0.align_pattern_length         = d_align_pattern_length,
                   quad0.infiniband_invalid_code      = infiniband_invalid_code,
                   quad0.c_disparity_mode             = disparity_mode,
                   quad0.c_force_disparity_mode       = force_disparity_mode,
                   quad0.c_clk_out_mode_reference     = clk_out_mode_reference,
                   quad0.intended_device_family       = intended_device_family,
                   quad0.deserialization_factor       = deserialization_factor,
                   quad0.pll_mult_value               = pll_mult_value,
                   quad0.cru_inclock_period           = int_cru_inclock_period,
                   quad0.cruclk_mult                  = cruclk_mult,
                   quad0.cruclk_div                   = cruclk_div,
                   quad0.pllclk_mult                  = pllclk_mult,
                   quad0.pllclk0_div                  = pllclk0_div,
                   quad0.pllclk_div_adj               = pllclk_div_adj,
                   quad0.pllclk2_divisor              = pllclk2_divisor,
                   quad0.use_self_test_mode           = use_self_test_mode,
                   quad0.self_test_mode               = self_test_mode,
                   quad0.use_equalizer_ctrl_signal    = use_equalizer_ctrl_signal,
                   quad0.equalizer_ctrl_setting       = equalizer_ctrl_setting,
                   quad0.signal_threshold_select      = signal_threshold_select,
                   quad0.rx_bandwidth_type            = rx_bandwidth_type,
                   quad0.rx_enable_dc_coupling        = rx_enable_dc_coupling,
                   quad0.use_vod_ctrl_signal          = use_vod_ctrl_signal,
                   quad0.vod_ctrl_setting             = vod_ctrl_setting,
                   quad0.use_preemphasis_ctrl_signal  = use_preemphasis_ctrl_signal,
                   quad0.preemphasis_ctrl_setting     = preemphasis_ctrl_setting,
                   quad0.use_phase_shift              = use_phase_shift,
                   quad0.pll_bandwidth_type           = pll_bandwidth_type,
                   quad0.pll_use_dc_coupling          = pll_use_dc_coupling,
                   quad0.rx_ppm_setting               = rx_ppm_setting,
                   quad0.device_family                = device_family,
                   quad0.use_rx_cruclk                = use_rx_cruclk,
                   quad0.use_rx_clkout                = use_rx_clkout,
                   quad0.use_rx_coreclk               = use_rx_coreclk,
                   quad0.use_tx_coreclk               = use_tx_coreclk,
                   quad0.instantiate_transmitter_pll  = instantiate_transmitter_pll,
                   quad0.consider_instantiate_transmitter_pll_param  = consider_instantiate_transmitter_pll_param,
                   quad0.flip_rx_out                  = flip_rx_out,
                   quad0.flip_tx_in                   = flip_tx_in,
                   quad0.add_generic_fifo_we_synch_register= add_generic_fifo_we_synch_register,
                   quad0.for_engineering_sample_device     = for_engineering_sample_device;

                   




    hssi_quad quad1 (.inclk(i_inclk[1]), 
                     .rx_coreclk(i_rx_coreclk[7:4]), 
                     .pll_areset(i_pll_areset[1]), 
                     .rx_cruclk(i_rx_cruclk[1]),
                     .rx_in(i_rx_in[7:4]), 

                     .rx_bitslip(i_rx_bitslip[7:4]), 
                     .rx_enacdet(i_rx_enacdet[7:4]), 
                     .rx_we(i_rx_we[7:4]), 
                     .rx_re(i_rx_re[7:4]), 
                     .rx_slpbk(i_rx_slpbk[7:4]), 
                     .rx_a1a2size(i_rx_a1a2size[7:4]), 
                     .rx_equalizerctrl(i_rx_equalizerctrl[23:12]), 
                     .rx_locktorefclk(i_rx_locktorefclk[7:4]), 
                     .rx_locktodata(i_rx_locktodata[7:4]), 
                     .tx_vodctrl(i_tx_vodctrl[23:12]), 
                     .tx_preemphasisctrl(i_tx_preemphasisctrl[23:12]), 

                     .txdigitalreset(i_txdigitalreset[7:4]),
                     .rxdigitalreset(i_rxdigitalreset[7:4]),
                     .rxanalogreset(i_rxanalogreset[7:4]),
                     .pllenable(my_pllenable[1]),

                     .tx_in(w_tx_in01),
                     .tx_coreclk(i_tx_coreclk[7:4]), 
                     .tx_ctrlenable(i_tx_ctrlenable[15:8]), 
                     .tx_forcedisparity(i_tx_forcedisparity[15:8]), 
                     .tx_srlpbk(i_tx_srlpbk[7:4]), 
                     .pll_locked(i_pll_locked[1]),
                     .coreclk_out(i_coreclk_out[1]), 
                     .rx_out(w_rx_out01), 
                     .rx_clkout(i_rx_clkout[7:4]), 
                     .rx_locked(i_rx_locked[7:4]), 
                     .rx_freqlocked(i_rx_freqlocked[7:4]), 
                     .rx_rlv(i_rx_rlv[7:4]),
                     .rx_syncstatus(i_rx_syncstatus[15:8]),
                     .rx_patterndetect(i_rx_patterndetect[15:8]),
                     .rx_ctrldetect(i_rx_ctrldetect[15:8]),
                     .rx_errdetect(i_rx_errdetect[15:8]),
                     .rx_disperr(i_rx_disperr[15:8]),
                     .rx_signaldetect(i_rx_signaldetect[7:4]),
                     .rx_fifoempty(i_rx_fifoempty[7:4]), 
                     .rx_fifofull(i_rx_fifofull[7:4]), 
                     .rx_fifoalmostempty(i_rx_fifoalmostempty[7:4]), 
                     .rx_fifoalmostfull(i_rx_fifoalmostfull[7:4]), 
                     .rx_channelaligned(i_rx_channelaligned[1]),
                     .rx_bisterr(i_rx_bisterr[7:4]),
                     .rx_bistdone(i_rx_bistdone[7:4]),
                     .rx_a1a2sizeout(i_rx_a1a2sizeout[15:8]),
                     .tx_out(w_tx_out[7:4]));
              defparam
                   quad1.operation_mode               = operation_mode,
                   quad1.loopback_mode                = loopback_mode,
                   quad1.reverse_loopback_mode        = reverse_loopback_mode,
                   quad1.pll_inclock_period           = pll_inclock_period,
                   quad1.data_rate                    = data_rate,
                   quad1.number_of_channels           = 4,
                   quad1.protocol                     = protocol,
                   quad1.channel_width                = channel_width,
                   quad1.rx_channel_width             = rx_channel_width,
                   quad1.rx_dwidth_factor             = rx_dwidth_factor,
                   quad1.c_use_8b_10b_mode            = use_8b_10b_mode,
                   quad1.c_use_double_data_mode       = use_double_data_mode,
                   quad1.rx_use_double_data_mode      = rx_use_double_data_mode,
                   quad1.run_length                   = run_length,
                   quad1.run_length_enable            = run_length_enable,
                   quad1.c_use_rate_match_fifo        = use_rate_match_fifo,
                   quad1.c_use_channel_align          = use_channel_align,
                   quad1.protocol_to_mode             = d_protocol_to_mode,
                   quad1.tx_transmit_protocol         = tx_transmit_protocol,
                   quad1.c_use_symbol_align           = d_use_symbol_align,
                   quad1.c_use_auto_bit_slip          = d_use_auto_bit_slip,
                   quad1.align_pattern                = d_align_pattern,
                   quad1.align_pattern_length         = d_align_pattern_length,
                   quad1.infiniband_invalid_code      = infiniband_invalid_code,
                   quad1.c_disparity_mode             = disparity_mode,
                   quad1.c_force_disparity_mode       = force_disparity_mode,
                   quad1.c_clk_out_mode_reference     = clk_out_mode_reference,
                   quad1.intended_device_family       = intended_device_family,
                   quad1.deserialization_factor       = deserialization_factor,
                   quad1.pll_mult_value               = pll_mult_value,
                   quad1.cru_inclock_period           = int_cru_inclock_period,
                   quad1.cruclk_mult                  = cruclk_mult,
                   quad1.cruclk_div                   = cruclk_div,
                   quad1.pllclk_mult                  = pllclk_mult,
                   quad1.pllclk0_div                  = pllclk0_div,
                   quad1.pllclk_div_adj               = pllclk_div_adj,
                   quad1.pllclk2_divisor              = pllclk2_divisor,
                   quad1.use_self_test_mode           = use_self_test_mode,
                   quad1.self_test_mode               = self_test_mode,
                   quad1.use_equalizer_ctrl_signal    = use_equalizer_ctrl_signal,
                   quad1.equalizer_ctrl_setting       = equalizer_ctrl_setting,
                   quad1.signal_threshold_select      = signal_threshold_select,
                   quad1.rx_bandwidth_type            = rx_bandwidth_type,
                   quad1.rx_enable_dc_coupling        = rx_enable_dc_coupling,
                   quad1.use_vod_ctrl_signal          = use_vod_ctrl_signal,
                   quad1.vod_ctrl_setting             = vod_ctrl_setting,
                   quad1.use_preemphasis_ctrl_signal  = use_preemphasis_ctrl_signal,
                   quad1.preemphasis_ctrl_setting     = preemphasis_ctrl_setting,
                   quad1.use_phase_shift              = use_phase_shift,
                   quad1.pll_bandwidth_type           = pll_bandwidth_type,
                   quad1.pll_use_dc_coupling          = pll_use_dc_coupling,
                   quad1.rx_ppm_setting               = rx_ppm_setting,
                   quad1.device_family                = device_family,
                   quad1.use_rx_cruclk                = use_rx_cruclk,
                   quad1.use_rx_clkout                = use_rx_clkout,
                   quad1.use_rx_coreclk               = use_rx_coreclk,
                   quad1.use_tx_coreclk               = use_tx_coreclk,
                   quad1.instantiate_transmitter_pll  = instantiate_transmitter_pll,
                   quad1.consider_instantiate_transmitter_pll_param  = consider_instantiate_transmitter_pll_param,
                   quad1.flip_rx_out                  = flip_rx_out,
                   quad1.flip_tx_in                   = flip_tx_in,
                   quad1.add_generic_fifo_we_synch_register= add_generic_fifo_we_synch_register,
                   quad1.for_engineering_sample_device     = for_engineering_sample_device;







    hssi_quad quad2 (.inclk(i_inclk[2]), 
                     .rx_coreclk(i_rx_coreclk[11:8]), 
                     .pll_areset(i_pll_areset[2]), 
                     .rx_cruclk(i_rx_cruclk[2]),
                     .rx_in(i_rx_in[11:8]), 

                     .rx_bitslip(i_rx_bitslip[11:8]), 
                     .rx_enacdet(i_rx_enacdet[11:8]), 
                     .rx_we(i_rx_we[11:8]), 
                     .rx_re(i_rx_re[11:8]), 
                     .rx_slpbk(i_rx_slpbk[11:8]), 
                     .rx_a1a2size(i_rx_a1a2size[11:8]), 
                     .rx_equalizerctrl(i_rx_equalizerctrl[35:24]), 
                     .rx_locktorefclk(i_rx_locktorefclk[11:8]), 
                     .rx_locktodata(i_rx_locktodata[11:8]), 
                     .tx_vodctrl(i_tx_vodctrl[35:24]), 
                     .tx_preemphasisctrl(i_tx_preemphasisctrl[35:24]), 

                     .txdigitalreset(i_txdigitalreset[11:8]),
                     .rxdigitalreset(i_rxdigitalreset[11:8]),
                     .rxanalogreset(i_rxanalogreset[11:8]),
                     .pllenable(my_pllenable[2]),

                     .tx_in(w_tx_in02),
                     .tx_coreclk(i_tx_coreclk[11:8]), 

                     .tx_ctrlenable(i_tx_ctrlenable[23:16]), 
                     .tx_forcedisparity(i_tx_forcedisparity[23:16]), 
                     .tx_srlpbk(i_tx_srlpbk[11:8]), 
                     .pll_locked(i_pll_locked[2]),
                     .coreclk_out(i_coreclk_out[2]), 
                     .rx_out(w_rx_out02), 
                     .rx_clkout(i_rx_clkout[11:8]), 
                     .rx_locked(i_rx_locked[11:8]), 
                     .rx_freqlocked(i_rx_freqlocked[11:8]), 
                     .rx_rlv(i_rx_rlv[11:8]),
                     .rx_syncstatus(i_rx_syncstatus[23:16]), 
                     .rx_patterndetect(i_rx_patterndetect[23:16]), 
                     .rx_ctrldetect(i_rx_ctrldetect[23:16]), 
                     .rx_errdetect(i_rx_errdetect[23:16]), 
                     .rx_disperr(i_rx_disperr[23:16]), 
                     .rx_signaldetect(i_rx_signaldetect[11:8]),
                     .rx_fifoempty(i_rx_fifoempty[11:8]), 
                     .rx_fifofull(i_rx_fifofull[11:8]), 
                     .rx_fifoalmostempty(i_rx_fifoalmostempty[11:8]), 
                     .rx_fifoalmostfull(i_rx_fifoalmostfull[11:8]), 
                     .rx_channelaligned(i_rx_channelaligned[2]),
                     .rx_bisterr(i_rx_bisterr[11:8]),
                     .rx_bistdone(i_rx_bistdone[11:8]),
                     .rx_a1a2sizeout(i_rx_a1a2sizeout[23:16]),
                     .tx_out(w_tx_out[11:8]));
              defparam
                   quad2.operation_mode               = operation_mode,
                   quad2.loopback_mode                = loopback_mode,
                   quad2.reverse_loopback_mode        = reverse_loopback_mode,
                   quad2.pll_inclock_period           = pll_inclock_period,
                   quad2.data_rate                    = data_rate,
                   quad2.number_of_channels           = 4,
                   quad2.protocol                     = protocol,
                   quad2.channel_width                = channel_width,
                   quad2.rx_channel_width             = rx_channel_width,
                   quad2.rx_dwidth_factor             = rx_dwidth_factor,
                   quad2.c_use_8b_10b_mode            = use_8b_10b_mode,
                   quad2.c_use_double_data_mode       = use_double_data_mode,
                   quad2.rx_use_double_data_mode      = rx_use_double_data_mode,
                   quad2.run_length                   = run_length,
                   quad2.run_length_enable            = run_length_enable,
                   quad2.c_use_rate_match_fifo        = use_rate_match_fifo,
                   quad2.c_use_channel_align          = use_channel_align,
                   quad2.protocol_to_mode             = d_protocol_to_mode,
                   quad2.tx_transmit_protocol         = tx_transmit_protocol,
                   quad2.c_use_symbol_align           = d_use_symbol_align,
                   quad2.c_use_auto_bit_slip          = d_use_auto_bit_slip,
                   quad2.align_pattern                = d_align_pattern,
                   quad2.align_pattern_length         = d_align_pattern_length,
                   quad2.infiniband_invalid_code      = infiniband_invalid_code,
                   quad2.c_disparity_mode             = disparity_mode,
                   quad2.c_force_disparity_mode       = force_disparity_mode,
                   quad2.c_clk_out_mode_reference     = clk_out_mode_reference,
                   quad2.intended_device_family       = intended_device_family,
                   quad2.deserialization_factor       = deserialization_factor,
                   quad2.pll_mult_value               = pll_mult_value,
                   quad2.cru_inclock_period           = int_cru_inclock_period,
                   quad2.cruclk_mult                  = cruclk_mult,
                   quad2.cruclk_div                   = cruclk_div,
                   quad2.pllclk_mult                  = pllclk_mult,
                   quad2.pllclk0_div                  = pllclk0_div,
                   quad2.pllclk_div_adj               = pllclk_div_adj,
                   quad2.pllclk2_divisor              = pllclk2_divisor,
                   quad2.use_self_test_mode           = use_self_test_mode,
                   quad2.self_test_mode               = self_test_mode,
                   quad2.use_equalizer_ctrl_signal    = use_equalizer_ctrl_signal,
                   quad2.equalizer_ctrl_setting       = equalizer_ctrl_setting,
                   quad2.signal_threshold_select      = signal_threshold_select,
                   quad2.rx_bandwidth_type            = rx_bandwidth_type,
                   quad2.rx_enable_dc_coupling        = rx_enable_dc_coupling,
                   quad2.use_vod_ctrl_signal          = use_vod_ctrl_signal,
                   quad2.vod_ctrl_setting             = vod_ctrl_setting,
                   quad2.use_preemphasis_ctrl_signal  = use_preemphasis_ctrl_signal,
                   quad2.preemphasis_ctrl_setting     = preemphasis_ctrl_setting,
                   quad2.use_phase_shift              = use_phase_shift,
                   quad2.pll_bandwidth_type           = pll_bandwidth_type,
                   quad2.pll_use_dc_coupling          = pll_use_dc_coupling,
                   quad2.rx_ppm_setting               = rx_ppm_setting,
                   quad2.device_family                = device_family,
                   quad2.use_rx_cruclk                = use_rx_cruclk,
                   quad2.use_rx_clkout                = use_rx_clkout,
                   quad2.use_rx_coreclk               = use_rx_coreclk,
                   quad2.use_tx_coreclk               = use_tx_coreclk,
                   quad2.instantiate_transmitter_pll  = instantiate_transmitter_pll,
                   quad2.consider_instantiate_transmitter_pll_param  = consider_instantiate_transmitter_pll_param,
                   quad2.flip_rx_out                  = flip_rx_out,
                   quad2.flip_tx_in                   = flip_tx_in,
                   quad2.add_generic_fifo_we_synch_register= add_generic_fifo_we_synch_register,
                   quad2.for_engineering_sample_device     = for_engineering_sample_device;







    hssi_quad quad3 (.inclk(i_inclk[3]), 
                     .rx_coreclk(i_rx_coreclk[15:12]), 
                     .pll_areset(i_pll_areset[3]), 
                     .rx_cruclk(i_rx_cruclk[3]),
                     .rx_in(i_rx_in[15:12]), 

                     .rx_bitslip(i_rx_bitslip[15:12]), 
                     .rx_enacdet(i_rx_enacdet[15:12]), 
                     .rx_we(i_rx_we[15:12]), 
                     .rx_re(i_rx_re[15:12]), 
                     .rx_slpbk(i_rx_slpbk[15:12]), 
                     .rx_a1a2size(i_rx_a1a2size[15:12]), 
                     .rx_equalizerctrl(i_rx_equalizerctrl[47:36]), 
                     .rx_locktorefclk(i_rx_locktorefclk[15:12]), 
                     .rx_locktodata(i_rx_locktodata[15:12]), 
                     .tx_vodctrl(i_tx_vodctrl[47:36]), 
                     .tx_preemphasisctrl(i_tx_preemphasisctrl[47:36]), 

                     .txdigitalreset(i_txdigitalreset[15:12]),
                     .rxdigitalreset(i_rxdigitalreset[15:12]),
                     .rxanalogreset(i_rxanalogreset[15:12]),
                     .pllenable(my_pllenable[3]),

                     .tx_in(w_tx_in03),
                     .tx_coreclk(i_tx_coreclk[15:12]), 

                     .tx_ctrlenable(i_tx_ctrlenable[31:24]), 
                     .tx_forcedisparity(i_tx_forcedisparity[31:24]), 
                     .tx_srlpbk(i_tx_srlpbk[15:12]), 
                     .pll_locked(i_pll_locked[3]),
                     .coreclk_out(i_coreclk_out[3]), 
                     .rx_out(w_rx_out03), 
                     .rx_clkout(i_rx_clkout[15:12]), 
                     .rx_locked(i_rx_locked[15:12]), 
                     .rx_freqlocked(i_rx_freqlocked[15:12]), 
                     .rx_rlv(i_rx_rlv[15:12]),
                     .rx_syncstatus(i_rx_syncstatus[31:24]), 
                     .rx_patterndetect(i_rx_patterndetect[31:24]), 
                     .rx_ctrldetect(i_rx_ctrldetect[31:24]), 
                     .rx_errdetect(i_rx_errdetect[31:24]), 
                     .rx_disperr(i_rx_disperr[31:24]), 
                     .rx_signaldetect(i_rx_signaldetect[15:12]),
                     .rx_fifoempty(i_rx_fifoempty[15:12]), 
                     .rx_fifofull(i_rx_fifofull[15:12]), 
                     .rx_fifoalmostempty(i_rx_fifoalmostempty[15:12]), 
                     .rx_fifoalmostfull(i_rx_fifoalmostfull[15:12]), 
                     .rx_channelaligned(i_rx_channelaligned[3]),
                     .rx_bisterr(i_rx_bisterr[15:12]),
                     .rx_bistdone(i_rx_bistdone[15:12]),
                     .rx_a1a2sizeout(i_rx_a1a2sizeout[31:24]),
                     .tx_out(w_tx_out[15:12]));
              defparam
                   quad3.operation_mode               = operation_mode,
                   quad3.loopback_mode                = loopback_mode,
                   quad3.reverse_loopback_mode        = reverse_loopback_mode,
                   quad3.pll_inclock_period           = pll_inclock_period,
                   quad3.data_rate                    = data_rate,
                   quad3.number_of_channels           = 4,
                   quad3.protocol                     = protocol,
                   quad3.channel_width                = channel_width,
                   quad3.rx_channel_width             = rx_channel_width,
                   quad3.rx_dwidth_factor             = rx_dwidth_factor,
                   quad3.c_use_8b_10b_mode            = use_8b_10b_mode,
                   quad3.c_use_double_data_mode       = use_double_data_mode,
                   quad3.rx_use_double_data_mode      = rx_use_double_data_mode,
                   quad3.run_length                   = run_length,
                   quad3.run_length_enable            = run_length_enable,
                   quad3.c_use_rate_match_fifo        = use_rate_match_fifo,
                   quad3.c_use_channel_align          = use_channel_align,
                   quad3.protocol_to_mode             = d_protocol_to_mode,
                   quad3.tx_transmit_protocol         = tx_transmit_protocol,
                   quad3.c_use_symbol_align           = d_use_symbol_align,
                   quad3.c_use_auto_bit_slip          = d_use_auto_bit_slip,
                   quad3.align_pattern                = d_align_pattern,
                   quad3.align_pattern_length         = d_align_pattern_length,
                   quad3.infiniband_invalid_code      = infiniband_invalid_code,
                   quad3.c_disparity_mode             = disparity_mode,
                   quad3.c_force_disparity_mode       = force_disparity_mode,
                   quad3.c_clk_out_mode_reference     = clk_out_mode_reference,
                   quad3.intended_device_family       = intended_device_family,
                   quad3.deserialization_factor       = deserialization_factor,
                   quad3.pll_mult_value               = pll_mult_value,
                   quad3.cru_inclock_period           = int_cru_inclock_period,
                   quad3.cruclk_mult                  = cruclk_mult,
                   quad3.cruclk_div                   = cruclk_div,
                   quad3.pllclk_mult                  = pllclk_mult,
                   quad3.pllclk0_div                  = pllclk0_div,
                   quad3.pllclk_div_adj               = pllclk_div_adj,
                   quad3.pllclk2_divisor              = pllclk2_divisor,
                   quad3.use_self_test_mode           = use_self_test_mode,
                   quad3.self_test_mode               = self_test_mode,
                   quad3.use_equalizer_ctrl_signal    = use_equalizer_ctrl_signal,
                   quad3.equalizer_ctrl_setting       = equalizer_ctrl_setting,
                   quad3.signal_threshold_select      = signal_threshold_select,
                   quad3.rx_bandwidth_type            = rx_bandwidth_type,
                   quad3.rx_enable_dc_coupling        = rx_enable_dc_coupling,
                   quad3.use_vod_ctrl_signal          = use_vod_ctrl_signal,
                   quad3.vod_ctrl_setting             = vod_ctrl_setting,
                   quad3.use_preemphasis_ctrl_signal  = use_preemphasis_ctrl_signal,
                   quad3.preemphasis_ctrl_setting     = preemphasis_ctrl_setting,
                   quad3.use_phase_shift              = use_phase_shift,
                   quad3.pll_bandwidth_type           = pll_bandwidth_type,
                   quad3.pll_use_dc_coupling          = pll_use_dc_coupling,
                   quad3.rx_ppm_setting               = rx_ppm_setting,
                   quad3.device_family                = device_family,
                   quad3.use_rx_cruclk                = use_rx_cruclk,
                   quad3.use_rx_clkout                = use_rx_clkout,
                   quad3.use_rx_coreclk               = use_rx_coreclk,
                   quad3.use_tx_coreclk               = use_tx_coreclk,
                   quad3.instantiate_transmitter_pll  = instantiate_transmitter_pll,
                   quad3.consider_instantiate_transmitter_pll_param  = consider_instantiate_transmitter_pll_param,
                   quad3.flip_rx_out                  = flip_rx_out,
                   quad3.flip_tx_in                   = flip_tx_in,
                   quad3.add_generic_fifo_we_synch_register= add_generic_fifo_we_synch_register,
                   quad3.for_engineering_sample_device     = for_engineering_sample_device;




    hssi_quad quad4 (.inclk(i_inclk[4]), 
                     .rx_coreclk(i_rx_coreclk[19:16]), 
                     .pll_areset(i_pll_areset[4]), 
                     .rx_cruclk(i_rx_cruclk[4]),
                     .rx_in(i_rx_in[19:16]), 

                     .rx_bitslip(i_rx_bitslip[19:16]), 
                     .rx_enacdet(i_rx_enacdet[19:16]), 
                     .rx_we(i_rx_we[19:16]), 
                     .rx_re(i_rx_re[19:16]), 
                     .rx_slpbk(i_rx_slpbk[19:16]), 
                     .rx_a1a2size(i_rx_a1a2size[19:16]), 
                     .rx_equalizerctrl(i_rx_equalizerctrl[59:48]), 
                     .rx_locktorefclk(i_rx_locktorefclk[19:16]), 
                     .rx_locktodata(i_rx_locktodata[19:16]), 
                     .tx_vodctrl(i_tx_vodctrl[59:48]), 
                     .tx_preemphasisctrl(i_tx_preemphasisctrl[59:48]), 

                     .txdigitalreset(i_txdigitalreset[19:16]),
                     .rxdigitalreset(i_rxdigitalreset[19:16]),
                     .rxanalogreset(i_rxanalogreset[19:16]),
                     .pllenable(my_pllenable[4]),

                     .tx_in(w_tx_in04),
                     .tx_coreclk(i_tx_coreclk[19:16]), 

                     .tx_ctrlenable(i_tx_ctrlenable[39:32]), 
                     .tx_forcedisparity(i_tx_forcedisparity[39:32]), 
                     .tx_srlpbk(i_tx_srlpbk[19:16]), 
                     .pll_locked(i_pll_locked[4]),
                     .coreclk_out(i_coreclk_out[4]), 
                     .rx_out(w_rx_out04), 
                     .rx_clkout(i_rx_clkout[19:16]), 
                     .rx_locked(i_rx_locked[19:16]), 
                     .rx_freqlocked(i_rx_freqlocked[19:16]), 
                     .rx_rlv(i_rx_rlv[19:16]),
                     .rx_syncstatus(i_rx_syncstatus[39:32]), 
                     .rx_patterndetect(i_rx_patterndetect[39:32]), 
                     .rx_ctrldetect(i_rx_ctrldetect[39:32]), 
                     .rx_errdetect(i_rx_errdetect[39:32]), 
                     .rx_disperr(i_rx_disperr[39:32]), 
                     .rx_signaldetect(i_rx_signaldetect[19:16]),
                     .rx_fifoempty(i_rx_fifoempty[19:16]), 
                     .rx_fifofull(i_rx_fifofull[19:16]), 
                     .rx_fifoalmostempty(i_rx_fifoalmostempty[19:16]), 
                     .rx_fifoalmostfull(i_rx_fifoalmostfull[19:16]), 
                     .rx_channelaligned(i_rx_channelaligned[4]),
                     .rx_bisterr(i_rx_bisterr[19:16]),
                     .rx_bistdone(i_rx_bistdone[19:16]),
                     .rx_a1a2sizeout(i_rx_a1a2sizeout[39:32]),
                     .tx_out(w_tx_out[19:16]));
              defparam
                   quad4.operation_mode               = operation_mode,
                   quad4.loopback_mode                = loopback_mode,
                   quad4.reverse_loopback_mode        = reverse_loopback_mode,
                   quad4.pll_inclock_period           = pll_inclock_period,
                   quad4.data_rate                    = data_rate,
                   quad4.number_of_channels           = 4,
                   quad4.channel_width                = channel_width,
                   quad4.rx_channel_width             = rx_channel_width,
                   quad4.rx_dwidth_factor             = rx_dwidth_factor,
                   quad4.c_use_8b_10b_mode            = use_8b_10b_mode,
                   quad4.c_use_double_data_mode       = use_double_data_mode,
                   quad4.rx_use_double_data_mode      = rx_use_double_data_mode,
                   quad4.protocol                     = protocol,
                   quad4.run_length                   = run_length,
                   quad4.run_length_enable            = run_length_enable,
                   quad4.c_use_rate_match_fifo        = use_rate_match_fifo,
                   quad4.c_use_channel_align          = use_channel_align,
                   quad4.protocol_to_mode             = d_protocol_to_mode,
                   quad4.tx_transmit_protocol         = tx_transmit_protocol,
                   quad4.c_use_symbol_align           = d_use_symbol_align,
                   quad4.c_use_auto_bit_slip          = d_use_auto_bit_slip,
                   quad4.align_pattern                = d_align_pattern,
                   quad4.align_pattern_length         = d_align_pattern_length,
                   quad4.infiniband_invalid_code      = infiniband_invalid_code,
                   quad4.c_disparity_mode             = disparity_mode,
                   quad4.c_force_disparity_mode       = force_disparity_mode,
                   quad4.c_clk_out_mode_reference     = clk_out_mode_reference,
                   quad4.intended_device_family       = intended_device_family,
                   quad4.deserialization_factor       = deserialization_factor,
                   quad4.pll_mult_value               = pll_mult_value,
                   quad4.cru_inclock_period           = int_cru_inclock_period,
                   quad4.cruclk_mult                  = cruclk_mult,
                   quad4.cruclk_div                   = cruclk_div,
                   quad4.pllclk_mult                  = pllclk_mult,
                   quad4.pllclk0_div                  = pllclk0_div,
                   quad4.pllclk_div_adj               = pllclk_div_adj,
                   quad4.pllclk2_divisor              = pllclk2_divisor,
                   quad4.use_self_test_mode           = use_self_test_mode,
                   quad4.self_test_mode               = self_test_mode,
                   quad4.use_equalizer_ctrl_signal    = use_equalizer_ctrl_signal,
                   quad4.equalizer_ctrl_setting       = equalizer_ctrl_setting,
                   quad4.signal_threshold_select      = signal_threshold_select,
                   quad4.rx_bandwidth_type            = rx_bandwidth_type,
                   quad4.rx_enable_dc_coupling        = rx_enable_dc_coupling,
                   quad4.use_vod_ctrl_signal          = use_vod_ctrl_signal,
                   quad4.vod_ctrl_setting             = vod_ctrl_setting,
                   quad4.use_preemphasis_ctrl_signal  = use_preemphasis_ctrl_signal,
                   quad4.preemphasis_ctrl_setting     = preemphasis_ctrl_setting,
                   quad4.use_phase_shift              = use_phase_shift,
                   quad4.pll_bandwidth_type           = pll_bandwidth_type,
                   quad4.pll_use_dc_coupling          = pll_use_dc_coupling,
                   quad4.rx_ppm_setting               = rx_ppm_setting,
                   quad4.device_family                = device_family,
                   quad4.use_rx_cruclk                = use_rx_cruclk,
                   quad4.use_rx_clkout                = use_rx_clkout,
                   quad4.use_rx_coreclk               = use_rx_coreclk,
                   quad4.use_tx_coreclk               = use_tx_coreclk,
                   quad4.instantiate_transmitter_pll  = instantiate_transmitter_pll,
                   quad4.consider_instantiate_transmitter_pll_param  = consider_instantiate_transmitter_pll_param,
                   quad4.flip_rx_out                  = flip_rx_out,
                   quad4.flip_tx_in                   = flip_tx_in,
                   quad4.add_generic_fifo_we_synch_register= add_generic_fifo_we_synch_register,
                   quad4.for_engineering_sample_device     = for_engineering_sample_device;


  // For Receivers
  // Inputs

                        
    always @(rx_in)
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
            i_rx_in[i] = (number_of_channels > i) ? rx_in[i] : 0;



    always @(rx_bitslip)
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
            i_rx_bitslip[i] = (number_of_channels > i) ? rx_bitslip[i] : 0;

    always @(rx_enacdet)
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
            i_rx_enacdet[i] = (number_of_channels > i) ? rx_enacdet[i] : 0;


    always @(rx_we)
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
            i_rx_we[i] = (number_of_channels > i) ? rx_we[i] : 0;

    always @(rx_re)
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
            i_rx_re[i] = (number_of_channels > i) ? rx_re[i] : 0;

    always @(rx_slpbk)
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
            i_rx_slpbk[i] = (number_of_channels > i) ? rx_slpbk[i] : 0;


    always @(rx_equalizerctrl)
    begin
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
            begin
            i_rx_equalizerctrl[i * 3]     = (number_of_channels > i) ? rx_equalizerctrl[i * 3] : 0; 
            i_rx_equalizerctrl[i * 3 + 1] = (number_of_channels > i) ? rx_equalizerctrl[i * 3 + 1] : 0; 
            i_rx_equalizerctrl[i * 3 + 2] = (number_of_channels > i) ? rx_equalizerctrl[i * 3 + 2] : 0; 

            end
    end

    always @(tx_vodctrl)
    begin
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
            begin
            i_tx_vodctrl[i * 3]     = (number_of_channels > i) ? tx_vodctrl[i * 3] : 0; 
            i_tx_vodctrl[i * 3 + 1] = (number_of_channels > i) ? tx_vodctrl[i * 3 + 1] : 0; 
            i_tx_vodctrl[i * 3 + 2] = (number_of_channels > i) ? tx_vodctrl[i * 3 + 2] : 0; 

            end
    end
    always @(tx_preemphasisctrl)
    begin
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
            begin
            i_tx_preemphasisctrl[i * 3]     = (number_of_channels > i) ? tx_preemphasisctrl[i * 3] : 0; 
            i_tx_preemphasisctrl[i * 3 + 1] = (number_of_channels > i) ? tx_preemphasisctrl[i * 3 + 1] : 0; 
            i_tx_preemphasisctrl[i * 3 + 2] = (number_of_channels > i) ? tx_preemphasisctrl[i * 3 + 2] : 0; 

            end
    end

    always @(rx_locktorefclk)
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
            i_rx_locktorefclk[i] = (number_of_channels > i) ? rx_locktorefclk[i] : 0;

    always @(rx_locktodata)
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
            i_rx_locktodata[i] = (number_of_channels > i) ? rx_locktodata[i] : 0;

    always @(inclk)
        for(i=0; i < `HSSI_MAXQUAD; i=i+1)
            i_inclk[i] = (number_of_quads > i) ? inclk[i] : 0;

    
    always @(txdigitalreset)
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
            i_txdigitalreset[i] = (number_of_channels > i) ? txdigitalreset[i] : 0;


    always @(rxdigitalreset)
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
            i_rxdigitalreset[i] = (number_of_channels > i) ? rxdigitalreset[i] : 0;


    always @(rxanalogreset)
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
            i_rxanalogreset[i] = (number_of_channels > i) ? rxanalogreset[i] : 0;





    always @(rx_cruclk)
        for(i=0; i < `HSSI_MAXQUAD; i=i+1)
            i_rx_cruclk[i] = (number_of_quads > i) ? rx_cruclk[i] : 0;

    always @(rx_coreclk)
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
            i_rx_coreclk[i] = (number_of_channels > i) ? rx_coreclk[i] : 0;

    always @(tx_coreclk)
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
            i_tx_coreclk[i] = (number_of_channels > i) ? tx_coreclk[i] : 0;


  // For XGM State Machines only
  // Inputs



//  always @
//    output [number_of_quads-1:0] pll_locked;
//    output [number_of_quads-1:0] pll_clkout;



// For transmitter only
  // Inputs
    always @(tx_ctrlenable)
    begin
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
         begin

           if (dwidth_factor == 1) 
            begin
            i_tx_ctrlenable[i * 2] = (number_of_channels > i) ? tx_ctrlenable[i] : 0;
            i_tx_ctrlenable[(i +1) * 2 - 1] = 0;
           end
           if (dwidth_factor == 2)
            begin
            i_tx_ctrlenable[i * 2] = (number_of_channels > i) ? tx_ctrlenable[i * 2] : 0;
            i_tx_ctrlenable[(i +1) * 2 - 1] = (number_of_channels > i) ? tx_ctrlenable[(i+1) * 2 - 1] : 0;
           end
         end

    end
//            i_tx_ctrlenable[(i + 1) * 2 - 1: i * 2] = (number_of_channels > i) ? tx_ctrlenable[(i + 1) * 2 - 1: i * 2] : 0;


    always @(tx_forcedisparity)
    begin
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
         begin

           if (dwidth_factor == 1) 
            begin
            i_tx_forcedisparity[i * 2] = (number_of_channels > i) ? tx_forcedisparity[i] : 0;
            i_tx_forcedisparity[(i +1) * 2 - 1] = 0;
           end
           if (dwidth_factor == 2)
            begin
            i_tx_forcedisparity[i * 2] = (number_of_channels > i) ? tx_forcedisparity[i * 2] : 0;
            i_tx_forcedisparity[(i +1) * 2 - 1] = (number_of_channels > i) ? tx_forcedisparity[(i+1) * 2 - 1] : 0;
           end
         end
    end
    always @(tx_srlpbk)
        for(i=0; i < `HSSI_MAXCDR; i=i+1)
            i_tx_srlpbk[i] = (number_of_channels > i) ? tx_srlpbk[i] : 0;

    always @ (tx_in)
       i_tx_in[channel_width*number_of_channels-1: 0] = tx_in;


    always @(i_tx_in)
    begin
    if (flip_tx_in == "OFF")
       tx_in_int[channel_width*number_of_channels-1: 0] = i_tx_in[channel_width*number_of_channels-1: 0];


    if ((flip_tx_in == "ON") && (channel_width > 10))
    begin
       for(i=0; i < number_of_channels ; i=i+1)
       begin
         channel_pos = i * channel_width;
         for (j=0; j < channel_width_div2; j=j+1) 
          begin
            tx_in_int[channel_pos + j] = i_tx_in[channel_pos + channel_width_div2 - 1 - j];    
            tx_in_int[channel_pos + channel_width_div2  + j] = 
                   i_tx_in[channel_pos + channel_width_div2 + channel_width_div2 - 1 - j];    
          end
        end
    end
    if ((flip_tx_in == "ON") && (channel_width <= 10))
    begin
       for(i=0; i < number_of_channels ; i=i+1)
       begin
         channel_pos = i * channel_width;
         for (j=0; j < channel_width; j=j+1) 
            tx_in_int[channel_pos + j] = i_tx_in[i * channel_width + channel_width - 1 - j];    
       end
    end

        w_tx_in00 =
            tx_in_int[01*channel_width * 4 -1:00*channel_width * 4];

        w_tx_in01 =
            tx_in_int[02*channel_width * 4 -1:01*channel_width * 4];

        w_tx_in02 =
            tx_in_int[03*channel_width * 4 -1:02*channel_width * 4];

        w_tx_in03 =
            tx_in_int[04*channel_width * 4 -1:03*channel_width * 4];

        w_tx_in04 =
            tx_in_int[05*channel_width * 4 -1:04*channel_width * 4];
    end

  // Outputs for Receiver
   always @(w_rx_out00) 
      i_rx_out[rx_channel_width * 4 - 1: 0 * 4 ] = w_rx_out00[rx_channel_width * 4 - 1: 0 * 4 ];


   always @(w_rx_out01)
    i_rx_out[rx_channel_width * 8 - 1 : rx_channel_width *  4 ] = w_rx_out01;

   always @(w_rx_out02)
    i_rx_out[rx_channel_width * 12 - 1: rx_channel_width *  8 ] = w_rx_out02;

   always @(w_rx_out03)
    i_rx_out[rx_channel_width * 16 - 1: rx_channel_width *  12 ] = w_rx_out03;

   always @(w_rx_out04)
    i_rx_out[rx_channel_width * 20 - 1: rx_channel_width *  16 ] = w_rx_out04;


   always @(i_rx_out) 
   begin

    if (flip_rx_out == "OFF")
        t_rx_out             = i_rx_out[rx_channel_width * number_of_channels-1:0];


    if ((flip_rx_out == "ON") && (rx_channel_width > 10))
    begin
       for(i=0; i < number_of_channels ; i=i+1)
       begin
         channel_pos = i * rx_channel_width;
         for (j=0; j < rx_channel_width_div2; j=j+1) 
          begin
            t_rx_out[channel_pos + j] = i_rx_out[channel_pos + rx_channel_width_div2 - 1 - j];    
            t_rx_out[channel_pos + rx_channel_width_div2  + j] = 
                   i_rx_out[channel_pos + rx_channel_width_div2 + rx_channel_width_div2 - 1 - j];    
          end
        end
    end

    if ((flip_rx_out == "ON") && (rx_channel_width <= 10))
    begin
       for(i=0; i < number_of_channels ; i=i+1)
       begin
         channel_pos = i * rx_channel_width;
         for (j=0; j < rx_channel_width; j=j+1) 
            t_rx_out[channel_pos + j] = i_rx_out[i * rx_channel_width + rx_channel_width - 1 - j];    
       end
    end
   end



   assign rx_out             = t_rx_out[rx_channel_width * number_of_channels-1:0];
   assign rx_clkout          = i_rx_clkout[number_of_channels-1:0];
   assign rx_locked          = i_rx_locked[number_of_channels-1:0];
   assign rx_freqlocked      = i_rx_freqlocked[number_of_channels-1:0];
   assign rx_rlv             = i_rx_rlv[number_of_channels-1:0];
   assign rx_signaldetect    = i_rx_signaldetect[number_of_channels-1:0];
   assign rx_fifoempty       = i_rx_fifoempty[number_of_channels-1:0];
   assign rx_fifofull        = i_rx_fifofull[number_of_channels-1:0];
   assign rx_fifoalmostempty = i_rx_fifoalmostempty[number_of_channels-1:0];
   assign rx_fifoalmostfull  = i_rx_fifoalmostfull[number_of_channels-1:0];
   assign rx_bisterr         = i_rx_bisterr[number_of_channels-1:0];
   assign rx_bistdone        = i_rx_bistdone[number_of_channels-1:0];



    always @(i_rx_syncstatus)
    begin
        for(i=0; i < number_of_channels; i=i+1)
         begin

           if (rx_dwidth_factor == 1) 
            begin
            t_rx_syncstatus[i] = i_rx_syncstatus[i*2];
           end
           if (rx_dwidth_factor == 2)
            begin
             t_rx_syncstatus[i*2] = i_rx_syncstatus[i*2];
             t_rx_syncstatus[(i +1) * 2 - 1] = i_rx_syncstatus[(i +1) * 2 - 1];
           end
         end
    end

    always @(i_rx_patterndetect)
    begin
        for(i=0; i < number_of_channels; i=i+1)
         begin

           if (rx_dwidth_factor == 1) 
            begin
             t_rx_patterndetect[i] = i_rx_patterndetect[i*2];
           end
           if (rx_dwidth_factor == 2)
            begin
             t_rx_patterndetect[i*2] = i_rx_patterndetect[i*2];
             t_rx_patterndetect[(i +1) * 2 - 1] = i_rx_patterndetect[(i +1) * 2 - 1];
           end
         end
    end


    always @(i_rx_ctrldetect)
    begin
        for(i=0; i < number_of_channels; i=i+1)
         begin

           if (rx_dwidth_factor == 1) 
            begin
             t_rx_ctrldetect[i] = i_rx_ctrldetect[i*2];
           end
           if (rx_dwidth_factor == 2)
            begin
             t_rx_ctrldetect[i*2] = i_rx_ctrldetect[i*2];
             t_rx_ctrldetect[(i +1) * 2 - 1] = i_rx_ctrldetect[(i +1) * 2 - 1];
           end
         end
    end

    always @(i_rx_errdetect)
    begin
        for(i=0; i < number_of_channels; i=i+1)
         begin

           if (rx_dwidth_factor == 1) 
            begin
             t_rx_errdetect[i] = i_rx_errdetect[i*2];
           end
           if (rx_dwidth_factor == 2)
            begin
             t_rx_errdetect[i*2] = i_rx_errdetect[i*2];
             t_rx_errdetect[(i +1) * 2 - 1] = i_rx_errdetect[(i +1) * 2 - 1];
           end
         end
    end

    always @(i_rx_disperr)
    begin
        for(i=0; i < number_of_channels; i=i+1)
         begin

           if (rx_dwidth_factor == 1) 
            begin
             t_rx_disperr[i] = i_rx_disperr[i*2];
           end
           if (rx_dwidth_factor == 2)
            begin
             t_rx_disperr[i*2] = i_rx_disperr[i*2];
             t_rx_disperr[(i +1) * 2 - 1] = i_rx_disperr[(i +1) * 2 - 1];
           end
         end
    end

    always @(i_rx_a1a2sizeout)
    begin
        for(i=0; i < number_of_channels; i=i+1)
         begin

           if (rx_dwidth_factor == 1) 
            begin
             t_rx_a1a2sizeout[i] = i_rx_a1a2sizeout[i*2];
           end
           if (rx_dwidth_factor == 2)
            begin
             t_rx_a1a2sizeout[i*2] = i_rx_a1a2sizeout[i*2];
             t_rx_a1a2sizeout[(i +1) * 2 - 1] = i_rx_a1a2sizeout[(i +1) * 2 - 1];
           end
         end
    end






  // Outputs for Transmitter
  assign tx_out = w_tx_out[number_of_channels-1:0];

   assign rx_syncstatus    = t_rx_syncstatus[rx_dwidth_factor * number_of_channels-1:0];
   assign rx_patterndetect = t_rx_patterndetect[rx_dwidth_factor * number_of_channels-1:0];
   assign rx_ctrldetect    = t_rx_ctrldetect[rx_dwidth_factor * number_of_channels-1:0];
   assign rx_errdetect     = t_rx_errdetect[rx_dwidth_factor * number_of_channels-1:0];
   assign rx_disperr       = t_rx_disperr[rx_dwidth_factor * number_of_channels-1:0];
   assign rx_a1a2sizeout   = t_rx_a1a2sizeout[rx_dwidth_factor * number_of_channels-1:0];




 // Outputs For PLL Clock
   assign pll_locked = i_pll_locked[number_of_quads-1:0];
   assign coreclk_out = i_coreclk_out[number_of_quads-1:0];
   assign rx_channelaligned = i_rx_channelaligned[number_of_quads-1:0];

endmodule

`timescale 1 ps / 1 ps

module hssi_quad (
               inclk, 
               pll_areset, 
               rx_cruclk, 
               rx_coreclk, 
               rx_in, 
               rx_bitslip,                
               rx_enacdet, 
               rx_we, 
               rx_re, 
               rx_slpbk, 
               rx_a1a2size, 
               rx_equalizerctrl, 
               rx_locktorefclk, 
               rx_locktodata,
               tx_in,
               tx_coreclk, 
               tx_ctrlenable, 
               tx_forcedisparity, 
               tx_srlpbk, 
               tx_vodctrl,                
               tx_preemphasisctrl,
               txdigitalreset, 
               rxdigitalreset, 
               rxanalogreset, 
               pllenable,
               pll_locked, 
               coreclk_out, 
               rx_out, 
               rx_clkout, 
               rx_locked, 
               rx_freqlocked, 
               rx_rlv, 
               rx_syncstatus,
               rx_patterndetect, 
               rx_ctrldetect, 
               rx_errdetect, 
               rx_disperr, 
               rx_signaldetect,
               rx_fifoempty, 
               rx_fifofull, 
               rx_fifoalmostempty, 
               rx_fifoalmostfull,                
               rx_channelaligned,
               rx_bisterr, 
               rx_bistdone, 
               rx_a1a2sizeout,
               tx_out);
    
               
    parameter operation_mode = "DUPLEX";     // Other modes- "RX", "TX", "DUPLEX"
    parameter loopback_mode = "NONE"; // "SLB", "RSLB", "PLB", "RPLB", "P8LB"
    parameter reverse_loopback_mode = "NONE";

    parameter protocol  = "NONE";     // Other protocols -  "GIGE", "INFINIBAND", "RAPIDIO", "FIBRECHANNEL"
    parameter protocol_to_mode  = "NONE";     // Other protocols -  "GIGE", "INFINIBAND", "RAPIDIO", "FIBRECHANNEL"
    parameter tx_transmit_protocol = "NONE";
    parameter number_of_channels = 4;
    parameter channel_width = 20;
    parameter pll_inclock_period = 20000;       // 20000ps = 50MHz
    parameter data_rate = 10;  // May be unused
    parameter c_use_8b_10b_mode = "OFF";
    parameter c_use_double_data_mode = "OFF";
    parameter rx_use_double_data_mode = "OFF";

    parameter c_disparity_mode = "OFF";
    parameter c_force_disparity_mode = "OFF";
    parameter cru_inclock_period = 0;

     // RX mode
    parameter run_length = 128;              
    parameter run_length_enable = "OFF";              
    parameter c_use_channel_align = "OFF";
    parameter c_use_auto_bit_slip  = "ON";
    parameter c_use_rate_match_fifo = "ON";
    parameter c_use_symbol_align = "ON";
    parameter align_pattern = "";
    parameter align_pattern_length = 0;
    parameter infiniband_invalid_code = 0; 
    parameter c_clk_out_mode_reference = "ON";
    // TX mode
    parameter c_use_fifo_mode = "ON";
    parameter intended_device_family = "ALTGXB";
    parameter deserialization_factor = 8;
    parameter pll_mult_value = 1;
    parameter pllclk2_divisor = 2;
    parameter cruclk_mult = 0;
    parameter cruclk_div = "";
    parameter pllclk_mult = 1;
    parameter pllclk0_div = 1;
    parameter pllclk_div_adj = 1;

    // Quartus 2.2 new parameters
    // common
    parameter use_self_test_mode = "OFF";
    parameter self_test_mode = 0;
    
    // Receiver
    parameter use_equalizer_ctrl_signal = "OFF";
    parameter equalizer_ctrl_setting = 0;
    parameter signal_threshold_select  = 80;
    parameter rx_bandwidth_type = "NEW_MEDIUM";
    parameter rx_enable_dc_coupling = "OFF";
    parameter use_vod_ctrl_signal = "OFF";
    parameter vod_ctrl_setting = 1000;
    parameter use_preemphasis_ctrl_signal = "OFF";
    parameter preemphasis_ctrl_setting = 0;
    parameter use_phase_shift = "ON";
    parameter pll_bandwidth_type = "LOW";
    parameter pll_use_dc_coupling = "OFF";
    parameter rx_ppm_setting = 1000;
    parameter device_family = "";
    parameter use_rx_cruclk = "OFF";
    parameter use_rx_clkout = "OFF";
    parameter use_rx_coreclk   = "OFF";
    parameter use_tx_coreclk   = "OFF";
    parameter instantiate_transmitter_pll = "OFF";
    parameter consider_instantiate_transmitter_pll_param = "OFF";
    parameter use_generic_fifo = "OFF";
    parameter flip_rx_out = "OFF";
    parameter flip_tx_in = "OFF";
    parameter add_generic_fifo_we_synch_register = "OFF";

    parameter rx_channel_width = channel_width;
    parameter rx_dwidth_factor    = 2;
    parameter for_engineering_sample_device = "ON"; // new in 3.0 sp2

    // 2.2 Settings
    parameter c_use_parallel_feedback =  (loopback_mode  == "PLB")?"ON":"OFF";
    parameter c_use_post8b10b_feedback =  (loopback_mode  == "P8LB")?"ON":"OFF";
    parameter c_send_reverse_parallel_feedback =  (reverse_loopback_mode  == "RPLB")?"ON":"OFF";
    parameter c_use_reverse_parallel_feedback = (reverse_loopback_mode  == "RPLB")?"ON":"OFF";
    parameter mode_is_xaui = (protocol == "XAUI")?"ON":"OFF";

    // Phase shift usage
    parameter pllclk_mult_temp = (pllclk_mult == 0) ? 1 : pllclk_mult;
    parameter pllclk0_period   =  (1.0 * pll_inclock_period * pllclk0_div/pllclk_mult_temp) 
                                     + 0.5;
    parameter pllclk1_period   =  (1.0 * pll_inclock_period * deserialization_factor/ (pllclk_div_adj * pllclk_mult_temp)+ 0.5);

    parameter t_pll_phase_shift_0 = (use_phase_shift == "ON")?
               (((1.0 * pll_inclock_period * pllclk0_div/pllclk_mult_temp) + 0.5)/2.0):0.0;
    parameter t_pll_phase_shift_1 = (use_phase_shift == "ON")?
         ( (7.0 * pll_inclock_period * pllclk0_div/pllclk_mult_temp)/4.0 + 
           (1.0 * pll_inclock_period * deserialization_factor)/(pllclk_div_adj *             
             pllclk_mult_temp)/2.0 + 0.5):0.0;
    parameter t_pll_phase_shift_2 = (use_phase_shift == "ON")?t_pll_phase_shift_1:0.0;

    parameter pll_phase_shift_0 = t_pll_phase_shift_0 * 100/100;
    parameter pll_phase_shift_1 = t_pll_phase_shift_1 * 100/100;

    parameter pll_phase_shift_2 = t_pll_phase_shift_2* 100/100;







    // Common input ports for Rx and Tx mode
    input inclk;
    input pll_areset; // tri0
    input [number_of_channels-1:0] rx_coreclk;


    // Input ports for RX mode
    input rx_cruclk;
    input [number_of_channels-1:0] rx_in;

    input [number_of_channels-1:0] rx_bitslip;
    input [number_of_channels-1:0] rx_enacdet;
    input [number_of_channels-1:0] rx_we;
    input [number_of_channels-1:0] rx_re;
    input [number_of_channels-1:0] rx_slpbk;

    input [number_of_channels-1:0]   rx_a1a2size;
    input [number_of_channels * 3 -1:0] rx_equalizerctrl;
    input [number_of_channels-1:0]   rx_locktorefclk;
    input [number_of_channels-1:0]   rx_locktodata;


    // XGM Input ports, common for Both Rx and Tx Mode

    input [3:0] txdigitalreset;
    input [3:0] rxdigitalreset;
    input [3:0] rxanalogreset;
    input pllenable;





    // Input ports for TX mode
    input [channel_width * number_of_channels-1:0] tx_in;
    input [number_of_channels-1:0] tx_coreclk;


    input [2 * number_of_channels-1:0] tx_ctrlenable;
    input [2 * number_of_channels-1:0] tx_forcedisparity;
    input [number_of_channels-1:0] tx_srlpbk;


    input [number_of_channels * 3 -1:0] tx_vodctrl;
    input [number_of_channels * 3 -1:0] tx_preemphasisctrl;


    // Common output ports for RX and TX mode
    output pll_locked;
    output coreclk_out;

   // Output ports for RX mode
    output [rx_channel_width*number_of_channels-1:0] rx_out;
    output [number_of_channels-1:0] rx_clkout;
    output [number_of_channels-1:0] rx_locked;
    output [number_of_channels-1:0] rx_freqlocked;
    output [number_of_channels-1:0] rx_rlv;

    output [2 * number_of_channels-1:0] rx_syncstatus;
    output [2 * number_of_channels-1:0] rx_patterndetect;
    output [2 * number_of_channels-1:0] rx_ctrldetect;
    output [2 * number_of_channels-1:0] rx_errdetect;
    output [2 * number_of_channels-1:0] rx_disperr;

    output [number_of_channels-1:0] rx_signaldetect;
    output [number_of_channels-1:0] rx_fifoempty;
    output [number_of_channels-1:0] rx_fifofull;
    output [number_of_channels-1:0] rx_fifoalmostempty;
    output [number_of_channels-1:0] rx_fifoalmostfull;
    output rx_channelaligned;
    output [number_of_channels-1:0] rx_bisterr;
    output [number_of_channels-1:0] rx_bistdone;
    output [2 * number_of_channels-1:0] rx_a1a2sizeout;

   // Output ports for TX mode
    output [number_of_channels-1:0] tx_out;

 
    // Variables  for Receivers

    wire w_rx_inclk0;
    reg   [rx_channel_width* 4 -1:0] i_rx_out;
    reg   [rx_channel_width* 4 -1:0] i_w_rx_out;

    // Variables  for Transmitters

    wire  [`HSSI_MAXCDR-1:0] w_tx_out;

    wire  [`HSSI_MAXCWIDTH - 1:0] w_rx_out00;
    wire  [`HSSI_MAXCWIDTH - 1:0] w_rx_out01;
    wire  [`HSSI_MAXCWIDTH - 1:0] w_rx_out02;
    wire  [`HSSI_MAXCWIDTH - 1:0] w_rx_out03;



    reg  [`HSSI_MAXCWIDTH  -1:0] w_tx_in00;
    reg  [`HSSI_MAXCWIDTH  -1:0] w_tx_in01;
    reg  [`HSSI_MAXCWIDTH  -1:0] w_tx_in02;
    reg  [`HSSI_MAXCWIDTH  -1:0] w_tx_in03;

    wire [9:0] w_parallelfdbkdata00;
    wire [9:0] w_parallelfdbkdata01;
    wire [9:0] w_parallelfdbkdata02;
    wire [9:0] w_parallelfdbkdata03;

    wire [9:0] w_pre8b10bdata00;
    wire [9:0] w_pre8b10bdata01;
    wire [9:0] w_pre8b10bdata02;
    wire [9:0] w_pre8b10bdata03;
    wire i_pllaresetout;
    wire [3:0] t_rx_we;
    reg  [3:0] i_rx_we;
    wire [3:0] i_sync_rx;
  


    // Variables for XGM State Machines





    wire  [3:0] i_rx_syncstatusdeskew;
    wire  [3:0] i_rx_adetectdeskew;



    wire [31:0] i_xgm_txdatain;
    wire [3:0]  i_xgm_txctrl;
    wire tx00_rd_enable_sync;

    wire [31:0] i_xgm_rxdatain;
    wire [3:0]  i_xgm_rxctrl;
    wire [3:0]  i_xgm_rxrunningdisp;
    wire [3:0]  i_xgm_rx_data_valid_in;
    wire [3:0]  i_xgm_adet;
    wire [3:0]  i_xgm_syncstatus_deskew;
    wire [3:0]  i_xgm_rdalign;

    wire [31:0] i_xgm_txdataout;
   

    wire [3:0] i_xgm_txctrlout;


    wire channels_are_aligned;
    wire enable_deskew_fifo;
    wire recovered_clk0;
    wire reset_deskew_fifo;

    wire [31:0] i_xgm_rxdataout;
    wire [3:0]  i_xgm_rxctrlout;
 // Variables for PLL Clock

//    wire  [i_pll_locked;
    // Signals used for controlling the rate matching fifos
    wire fifo_rd_out0;
    wire disable_fifo_rd_out0;
    wire disable_fifo_wr_out0;

    integer i;
    wire slow_pll_clk, fast_pll_clk;
    wire [2:0] temp_clk;
    reg temp_inclk;
    reg i_cruclk;
    reg  [3:0] i_rx_coreclk;   
    reg  [3:0] i_tx_coreclk;   


    wire [3:0] i_txdigitalresetout;
    wire [3:0]i_rxdigitalresetout;
    wire [3:0]i_txanalogresetout;
    wire [3:0]i_rxanalogresetout;


   specify
      
   endspecify
   
   initial
      begin

      if (operation_mode == "RX")
       begin
       end
      if (operation_mode == "TX")
       begin
       end
      if (operation_mode == "DUPLEX")
       begin
       end
       temp_inclk = 1'b0;

      end
                                                   
    altgxb_dffe we_synch_rx0_a (.D(rx_we[0]),
                         .CLRN(1'b1),
                         .PRN(1'b1),
                         .ENA(1'b1),
                         .CLK(i_rx_coreclk[0]),
                         .Q(i_sync_rx[0])
                   );


    altgxb_dffe we_synch_rx0_b (.D(i_sync_rx[0]),
                         .CLRN(1'b1),
                         .PRN(1'b1),
                         .ENA(1'b1),
                         .CLK(i_rx_coreclk[0]),
                         .Q(t_rx_we[0])
                   );



                                                   
    altgxb_dffe we_synch_rx1_a (.D(rx_we[1]),
                         .CLRN(1'b1),
                         .PRN(1'b1),
                         .ENA(1'b1),
                         .CLK(i_rx_coreclk[1]),
                         .Q(i_sync_rx[1])
                   );


    altgxb_dffe we_synch_rx1_b (.D(i_sync_rx[1]),
                         .CLRN(1'b1),
                         .PRN(1'b1),
                         .ENA(1'b1),
                         .CLK(i_rx_coreclk[1]),
                         .Q(t_rx_we[1])
                   );


                                                   
    altgxb_dffe we_synch_rx2_a (.D(rx_we[2]),
                         .CLRN(1'b1),
                         .PRN(1'b1),
                         .ENA(1'b1),
                         .CLK(i_rx_coreclk[2]),
                         .Q(i_sync_rx[2])
                   );


    altgxb_dffe we_synch_rx2_b (.D(i_sync_rx[2]),
                         .CLRN(1'b1),
                         .PRN(1'b1),
                         .ENA(1'b1),
                         .CLK(i_rx_coreclk[2]),
                         .Q(t_rx_we[2])
                   );




                                                   
    altgxb_dffe we_synch_rx3_a (.D(rx_we[3]),
                         .CLRN(1'b1),
                         .PRN(1'b1),
                         .ENA(1'b1),
                         .CLK(i_rx_coreclk[3]),
                         .Q(i_sync_rx[3])
                   );


    altgxb_dffe we_synch_rx3_b (.D(i_sync_rx[3]),
                         .CLRN(1'b1),
                         .PRN(1'b1),
                         .ENA(1'b1),
                         .CLK(i_rx_coreclk[3]),
                         .Q(t_rx_we[3])
                   );







     altgxb_hssi_receiver rx00 ( 
                             // General Input
                            .datain(rx_in[0]), 
                            .cruclk(i_cruclk), 
                            .pllclk(slow_pll_clk), 
                            .coreclk(i_rx_coreclk[0]),
                            .softreset(i_rxdigitalresetout[0]),
                            .analogreset(i_rxanalogresetout[0]),
                            .serialfdbk(w_tx_out[0]), 
                            .slpbk(rx_slpbk[0]), 
                            .parallelfdbk(w_parallelfdbkdata00),

                            .post8b10b(w_pre8b10bdata00),

                            .bitslip(rx_bitslip[0]), 
                            .enacdet(rx_enacdet[0]), 
                            .we(i_rx_we[0]), 
                            .re(rx_re[0]), 
                            .devclrn(1'b1), 
                            .devpor(1'b1),
                            // Input from RX 0                                                    
                            .masterclk(recovered_clk0), 
                            .alignstatus(channels_are_aligned),
                            .disablefifordin(disable_fifo_rd_out0), 
                            .disablefifowrin(disable_fifo_wr_out0), 
                            .fifordin(fifo_rd_out0),

                            // Input from XGM/Deskew SM
                            .enabledeskew(enable_deskew_fifo),
                            .fiforesetrd(reset_deskew_fifo),
                            .xgmdatain(i_xgm_rxdataout[7:0]), 
                            .xgmctrlin(i_xgm_rxctrlout[0]),

                            // General Outputs 
                            .dataout(w_rx_out00),
                            .syncstatus(rx_syncstatus[1:0]), 
                            .patterndetect(rx_patterndetect[1:0]),
                            .ctrldetect(rx_ctrldetect[1:0]), 

                            .errdetect(rx_errdetect[1:0]),
                            .disperr(rx_disperr[1:0]), 
                            .fifofull(rx_fifofull[0]), 
                            .fifoalmostfull(rx_fifoalmostfull[0]),
                            .fifoempty(rx_fifoempty[0]), 
                            .fifoalmostempty(rx_fifoalmostempty[0]),
                            .signaldetect(rx_signaldetect[0]), 
                            .lock(rx_locked[0]), 
                            .freqlock(rx_freqlocked[0]),
                            .clkout(rx_clkout[0]), 
                            .rlv(rx_rlv[0]), 

                            // 2.2 Input ports
                            .a1a2size(rx_a1a2size[0]),
                            .equalizerctrl(rx_equalizerctrl[2:0]),
                            .locktorefclk(rx_locktorefclk[0]),
                            .locktodata(rx_locktodata[0]),




                            // 2.2 Output ports
                            .bisterr(rx_bisterr[0]), 
                            .bistdone(rx_bistdone[0]), 
                            .a1a2sizeout(rx_a1a2sizeout[1:0]), 
                            

                            // Outputs to XGM/Deskew SM                          
                            .adetectdeskew(i_xgm_adet[0]), 
                            .rdalign(i_xgm_rdalign[0]),
                            .xgmdataout(i_xgm_rxdatain[7:0]),
                            .xgmctrldet(i_xgm_rxctrl[0]),
                            .xgmrunningdisp(i_xgm_rxrunningdisp[0]),
                            .xgmdatavalid(i_xgm_rx_data_valid_in[0]),
                            .syncstatusdeskew(i_xgm_syncstatus_deskew[0]),
                            // outputs to other RX's
                            .fifordout(fifo_rd_out0),
                            .disablefifowrout(disable_fifo_wr_out0),
                            .disablefifordout(disable_fifo_rd_out0),
                            .recovclkout(recovered_clk0)
                          
                            );

                          defparam
                            rx00.channel_num             = 0,
                            rx00.channel_width           = rx_channel_width,
                            rx00.run_length              = run_length,
                            rx00.run_length_enable       = run_length_enable,
                            rx00.use_8b_10b_mode         = c_use_8b_10b_mode,
                            rx00.use_double_data_mode    = rx_use_double_data_mode,
                            rx00.use_rate_match_fifo     = c_use_rate_match_fifo,
                            rx00.rate_matching_fifo_mode = protocol_to_mode,
                            rx00.deserialization_factor  = deserialization_factor,
                            rx00.synchronization_mode    = protocol_to_mode,
                            rx00.use_channel_align       = c_use_channel_align,
                            rx00.use_symbol_align        = c_use_symbol_align,
                            rx00.use_auto_bit_slip       = c_use_auto_bit_slip,
                            rx00.align_pattern           = align_pattern,
                            rx00.align_pattern_length    = align_pattern_length,
                            rx00.infiniband_invalid_code = infiniband_invalid_code,
                            rx00.disparity_mode          = c_disparity_mode,
                            rx00.cruclk_period           = cru_inclock_period,
                            rx00.clk_out_mode_reference  = c_clk_out_mode_reference,
                            rx00.cruclk_multiplier       = cruclk_mult,
                            rx00.use_cruclk_divider      = cruclk_div,
                            rx00.use_self_test_mode      = use_self_test_mode,
                            rx00.self_test_mode          = self_test_mode,
                            rx00.use_parallel_feedback   = c_use_parallel_feedback,
                            rx00.use_post8b10b_feedback  = c_use_post8b10b_feedback,
                            rx00.send_reverse_parallel_feedback  = c_send_reverse_parallel_feedback,
                            rx00.use_equalizer_ctrl_signal  = use_equalizer_ctrl_signal,
                            rx00.equalizer_ctrl_setting  = equalizer_ctrl_setting,
                            rx00.bandwidth_type = rx_bandwidth_type,
                            rx00.enable_dc_coupling = rx_enable_dc_coupling,
                            rx00.for_engineering_sample_device = for_engineering_sample_device;



         






     altgxb_hssi_receiver rx01 ( 
                             // General Input
                            .datain(rx_in[1]), 
                            .cruclk(i_cruclk), 
                            .pllclk(slow_pll_clk), 
                            .coreclk(i_rx_coreclk[1]),
                            .softreset(i_rxdigitalresetout[1]),
                            .analogreset(i_rxanalogresetout[1]),
                            .serialfdbk(w_tx_out[1]), 
                            .slpbk(rx_slpbk[1]), 
                            .parallelfdbk(w_parallelfdbkdata01),
                            .post8b10b(w_pre8b10bdata01),
                            .bitslip(rx_bitslip[1]), 
                            .enacdet(rx_enacdet[1]), 
                            .we(i_rx_we[1]), 
                            .re(rx_re[1]), 
                            .devclrn(1'b1), 
                            .devpor(1'b1),
                            // Input from RX 0                                                    
                            .masterclk(recovered_clk0), 
                            .alignstatus(channels_are_aligned),
                            .disablefifordin(disable_fifo_rd_out0), 
                            .disablefifowrin(disable_fifo_wr_out0), 
                            .fifordin(fifo_rd_out0),

                            // Input from XGM/Deskew SM
                            .enabledeskew(enable_deskew_fifo),
                            .fiforesetrd(reset_deskew_fifo),
                            .xgmdatain(i_xgm_rxdataout[15:8]), 
                            .xgmctrlin(i_xgm_rxctrlout[1]),

                            // General Outputs 
                            .dataout(w_rx_out01),
                            .syncstatus(rx_syncstatus[3:2]), 
                            .patterndetect(rx_patterndetect[3:2]),
                            .ctrldetect(rx_ctrldetect[3:2]), 
                            .errdetect(rx_errdetect[3:2]),
                            .disperr(rx_disperr[3:2]), 
                            .fifofull(rx_fifofull[1]), 
                            .fifoalmostfull(rx_fifoalmostfull[1]),
                            .fifoempty(rx_fifoempty[1]), 
                            .fifoalmostempty(rx_fifoalmostempty[1]),
                            .signaldetect(rx_signaldetect[1]), 
                            .lock(rx_locked[1]), 
                            .freqlock(rx_freqlocked[1]),
                            .clkout(rx_clkout[1]), 
                            .rlv(rx_rlv[1]), 

                            // 2.2 Input ports
                            .a1a2size(rx_a1a2size[1]),
                            .equalizerctrl(rx_equalizerctrl[5:3]),
                            .locktorefclk(rx_locktorefclk[1]),
                            .locktodata(rx_locktodata[1]),

                            // 2.2 Output ports
                            .bisterr(rx_bisterr[1]), 
                            .bistdone(rx_bistdone[1]), 
                            .a1a2sizeout(rx_a1a2sizeout[3:2]), 

                            // Outputs to XGM/Deskew SM                          
                            .adetectdeskew(i_xgm_adet[1]), 
                            .rdalign(i_xgm_rdalign[1]),
                            .xgmdataout(i_xgm_rxdatain[15:8]),
                            .xgmctrldet(i_xgm_rxctrl[1]),
                            .xgmrunningdisp(i_xgm_rxrunningdisp[1]),
                            .xgmdatavalid(i_xgm_rx_data_valid_in[1]),
                            .syncstatusdeskew(i_xgm_syncstatus_deskew[1]),
                             // outputs to other RX's
                            .fifordout(),
                            .disablefifowrout(),
                            .disablefifordout(),
                            .recovclkout()
                          
                            );

                          defparam
                            rx01.channel_num             = 1,
                            rx01.channel_width           = rx_channel_width,
                            rx01.run_length              = run_length,
                            rx01.run_length_enable       = run_length_enable,
                            rx01.use_8b_10b_mode         = c_use_8b_10b_mode,
                            rx01.use_double_data_mode    = rx_use_double_data_mode,
                            rx01.use_rate_match_fifo     = c_use_rate_match_fifo,
                            rx01.rate_matching_fifo_mode = protocol_to_mode,
                            rx01.synchronization_mode    = protocol_to_mode,
                            rx01.deserialization_factor  = deserialization_factor,
                            rx01.use_channel_align       = c_use_channel_align,
                            rx01.use_symbol_align        = c_use_symbol_align,
                            rx01.use_auto_bit_slip       = c_use_auto_bit_slip,
                            rx01.align_pattern           = align_pattern,
                            rx01.align_pattern_length    = align_pattern_length,
                            rx01.infiniband_invalid_code = infiniband_invalid_code,
                            rx01.disparity_mode          = c_disparity_mode,
                            rx01.cruclk_period            = cru_inclock_period,
                            rx01.clk_out_mode_reference  = c_clk_out_mode_reference,
                            rx01.cruclk_multiplier = cruclk_mult,
                            rx01.use_cruclk_divider      = cruclk_div,
                            rx01.use_self_test_mode      = use_self_test_mode,
                            rx01.self_test_mode          = self_test_mode,
                            rx01.use_parallel_feedback   = c_use_parallel_feedback,
                            rx01.use_post8b10b_feedback  = c_use_post8b10b_feedback,
                            rx01.send_reverse_parallel_feedback  = c_send_reverse_parallel_feedback,
                            rx01.use_equalizer_ctrl_signal  = use_equalizer_ctrl_signal,
                            rx01.equalizer_ctrl_setting  = equalizer_ctrl_setting,
                            rx01.bandwidth_type = rx_bandwidth_type,
                            rx01.enable_dc_coupling = rx_enable_dc_coupling,
                            rx01.for_engineering_sample_device = for_engineering_sample_device;

            


     altgxb_hssi_receiver rx02 ( 
                             // General Input
                            .datain(rx_in[2]), 
                            .cruclk(i_cruclk), 
                            .pllclk(slow_pll_clk), 
                            .coreclk(i_rx_coreclk[2]),
                            .softreset(i_rxdigitalresetout[2]),
                            .analogreset(i_rxanalogresetout[2]),
                            .serialfdbk(w_tx_out[2]), 
                            .slpbk(rx_slpbk[2]), 
                            .parallelfdbk(w_parallelfdbkdata02),
                            .post8b10b(w_pre8b10bdata02),
                            .bitslip(rx_bitslip[2]), 
                            .enacdet(rx_enacdet[2]), 
                            .we(i_rx_we[2]), 
                            .re(rx_re[2]), 
                            .devclrn(1'b1), 
                            .devpor(1'b1),
                            // Input from RX 0                                                    
                            .masterclk(recovered_clk0), 
                            .alignstatus(channels_are_aligned),
                            .disablefifordin(disable_fifo_rd_out0), 
                            .disablefifowrin(disable_fifo_wr_out0), 
                            .fifordin(fifo_rd_out0),

                            // Input from XGM/Deskew SM
                            .enabledeskew(enable_deskew_fifo),
                            .fiforesetrd(reset_deskew_fifo),
                            .xgmdatain(i_xgm_rxdataout[23:16]), 
                            .xgmctrlin(i_xgm_rxctrlout[2]),

                            // General Outputs 
                            .dataout(w_rx_out02),
                            .syncstatus(rx_syncstatus[5:4]), 
                            .patterndetect(rx_patterndetect[5:4]),
                            .ctrldetect(rx_ctrldetect[5:4]), 
                            .errdetect(rx_errdetect[5:4]),
                            .disperr(rx_disperr[5:4]), 
                            .fifofull(rx_fifofull[2]), 
                            .fifoalmostfull(rx_fifoalmostfull[2]),
                            .fifoempty(rx_fifoempty[2]), 
                            .fifoalmostempty(rx_fifoalmostempty[2]),
                            .signaldetect(rx_signaldetect[2]), 
                            .lock(rx_locked[2]), 
                            .freqlock(rx_freqlocked[2]),
                            .clkout(rx_clkout[2]), 
                            .rlv(rx_rlv[2]), 

                            // 2.2 Input ports
                            .a1a2size(rx_a1a2size[2]),
                            .equalizerctrl(rx_equalizerctrl[8:6]),
                            .locktorefclk(rx_locktorefclk[2]),
                            .locktodata(rx_locktodata[2]),


                            // 2.2 Output ports
                            .bisterr(rx_bisterr[2]), 
                            .bistdone(rx_bistdone[2]), 
                            .a1a2sizeout(rx_a1a2sizeout[5:4]), 

                            // Outputs to XGM/Deskew SM                          
                            .adetectdeskew(i_xgm_adet[2]), 
                            .rdalign(i_xgm_rdalign[2]),
                            .xgmdataout(i_xgm_rxdatain[23:16]),
                            .xgmctrldet(i_xgm_rxctrl[2]),
                            .xgmrunningdisp(i_xgm_rxrunningdisp[2]),
                            .xgmdatavalid(i_xgm_rx_data_valid_in[2]),
                            .syncstatusdeskew(i_xgm_syncstatus_deskew[2]),
                            // outputs to other RX's
                            .fifordout(),
                            .disablefifowrout(),
                            .disablefifordout(),
                            .recovclkout()
                          
                            );

                          defparam
                            rx02.channel_num             = 2,
                            rx02.channel_width           = rx_channel_width,
                            rx02.run_length              = run_length,
                            rx02.run_length_enable       = run_length_enable,
                            rx02.use_8b_10b_mode         = c_use_8b_10b_mode,
                            rx02.use_double_data_mode    = rx_use_double_data_mode,
                            rx02.use_rate_match_fifo     = c_use_rate_match_fifo,
                            rx02.rate_matching_fifo_mode = protocol_to_mode,
                            rx02.synchronization_mode    = protocol_to_mode,
                            rx02.deserialization_factor  = deserialization_factor,
                            rx02.use_channel_align       = c_use_channel_align,
                            rx02.use_symbol_align        = c_use_symbol_align,
                            rx02.use_auto_bit_slip       = c_use_auto_bit_slip,
                            rx02.align_pattern           = align_pattern,
                            rx02.align_pattern_length    = align_pattern_length,
                            rx02.infiniband_invalid_code = infiniband_invalid_code,
                            rx02.disparity_mode          = c_disparity_mode,
                            rx02.cruclk_period            = cru_inclock_period,
                            rx02.clk_out_mode_reference  = c_clk_out_mode_reference,
                            rx02.cruclk_multiplier = cruclk_mult,
                            rx02.use_cruclk_divider      = cruclk_div,
                            rx02.use_self_test_mode      = use_self_test_mode,
                            rx02.self_test_mode          = self_test_mode,
                            rx02.use_parallel_feedback   = c_use_parallel_feedback,
                            rx02.use_post8b10b_feedback  = c_use_post8b10b_feedback,
                            rx02.send_reverse_parallel_feedback  = c_send_reverse_parallel_feedback,
                            rx02.use_equalizer_ctrl_signal  = use_equalizer_ctrl_signal,
                            rx02.equalizer_ctrl_setting  = equalizer_ctrl_setting,
                            rx02.bandwidth_type = rx_bandwidth_type,
                            rx02.enable_dc_coupling = rx_enable_dc_coupling,
                            rx02.for_engineering_sample_device = for_engineering_sample_device;
            


     altgxb_hssi_receiver rx03 ( 
                             // General Input
                            .datain(rx_in[3]), 
                            .cruclk(i_cruclk), 
                            .pllclk(slow_pll_clk), 
                            .coreclk(i_rx_coreclk[3]),
                            .softreset(i_rxdigitalresetout[3]),
                            .analogreset(i_rxanalogresetout[3]),
                            .serialfdbk(w_tx_out[3]), 
                            .slpbk(rx_slpbk[3]), 
                            .parallelfdbk(w_parallelfdbkdata03),
                            .post8b10b(w_pre8b10bdata03),
                            .bitslip(rx_bitslip[3]), 
                            .enacdet(rx_enacdet[3]), 
                            .we(i_rx_we[3]), 
                            .re(rx_re[3]), 
                            .devclrn(1'b1), 
                            .devpor(1'b1),
                            // Input from RX 0                                                    
                            .masterclk(recovered_clk0), 
                            .alignstatus(channels_are_aligned),
                            .disablefifordin(disable_fifo_rd_out0), 
                            .disablefifowrin(disable_fifo_wr_out0), 
                            .fifordin(fifo_rd_out0),

                            // Input from XGM/Deskew SM
                            .enabledeskew(enable_deskew_fifo),
                            .fiforesetrd(reset_deskew_fifo),
                            .xgmdatain(i_xgm_rxdataout[31:24]), 
                            .xgmctrlin(i_xgm_rxctrlout[3]),

                            // General Outputs 
                            .dataout(w_rx_out03),
                            .syncstatus(rx_syncstatus[7:6]), 
                            .patterndetect(rx_patterndetect[7:6]),
                            .ctrldetect(rx_ctrldetect[7:6]),
                            .errdetect(rx_errdetect[7:6]),
                            .disperr(rx_disperr[7:6]), 



                            .fifofull(rx_fifofull[3]), 
                            .fifoalmostfull(rx_fifoalmostfull[3]),
                            .fifoempty(rx_fifoempty[3]), 
                            .fifoalmostempty(rx_fifoalmostempty[3]),
                            .signaldetect(rx_signaldetect[3]), 
                            .lock(rx_locked[3]), 
                            .freqlock(rx_freqlocked[3]),
                            .clkout(rx_clkout[3]), 
                            .rlv(rx_rlv[3]), 

                            // 2.2 Input ports
                            .a1a2size(rx_a1a2size[3]),
                            .equalizerctrl(rx_equalizerctrl[11:9]),
                            .locktorefclk(rx_locktorefclk[3]),
                            .locktodata(rx_locktodata[3]),

                            // 2.2 Output ports
                            .bisterr(rx_bisterr[3]), 
                            .bistdone(rx_bistdone[3]), 
                            .a1a2sizeout(rx_a1a2sizeout[7:6]), 

                            // Outputs to XGM/Deskew SM                          
                            .adetectdeskew(i_xgm_adet[3]), 
                            .rdalign(i_xgm_rdalign[3]),
                            .xgmdataout(i_xgm_rxdatain[31:24]),
                            .xgmctrldet(i_xgm_rxctrl[3]),
                            .xgmrunningdisp(i_xgm_rxrunningdisp[3]),
                            .xgmdatavalid(i_xgm_rx_data_valid_in[3]),
                            .syncstatusdeskew(i_xgm_syncstatus_deskew[3]),
                            // outputs to other RX's
                            .fifordout(),
                            .disablefifowrout(),
                            .disablefifordout(),
                            .recovclkout()
                          
                            );

                          defparam
                            rx03.channel_num             = 3,
                            rx03.channel_width           = rx_channel_width,
                            rx03.run_length              = run_length,
                            rx03.run_length_enable       = run_length_enable,
                            rx03.use_8b_10b_mode         = c_use_8b_10b_mode,
                            rx03.use_double_data_mode    = rx_use_double_data_mode,
                            rx03.use_rate_match_fifo     = c_use_rate_match_fifo,
                            rx03.rate_matching_fifo_mode = protocol_to_mode,
                            rx03.synchronization_mode    = protocol_to_mode,
                            rx03.deserialization_factor  = deserialization_factor,
                            rx03.use_channel_align       = c_use_channel_align,
                            rx03.use_symbol_align        = c_use_symbol_align,
                            rx03.use_auto_bit_slip       = c_use_auto_bit_slip,
                            rx03.align_pattern           = align_pattern,
                            rx03.align_pattern_length    = align_pattern_length,
                            rx03.infiniband_invalid_code = infiniband_invalid_code,
                            rx03.disparity_mode          = c_disparity_mode,
                            rx03.cruclk_period           = cru_inclock_period,
                            rx03.clk_out_mode_reference  = c_clk_out_mode_reference,
                            rx03.cruclk_multiplier = cruclk_mult,
                            rx03.use_cruclk_divider      = cruclk_div,
                            rx03.use_self_test_mode      = use_self_test_mode,
                            rx03.self_test_mode          = self_test_mode,
                            rx03.use_parallel_feedback   = c_use_parallel_feedback,
                            rx03.use_post8b10b_feedback  = c_use_post8b10b_feedback,
                            rx03.send_reverse_parallel_feedback  = c_send_reverse_parallel_feedback,
                            rx03.use_equalizer_ctrl_signal  = use_equalizer_ctrl_signal,
                            rx03.equalizer_ctrl_setting  = equalizer_ctrl_setting,
                            rx03.bandwidth_type = rx_bandwidth_type,
                            rx03.enable_dc_coupling = rx_enable_dc_coupling,
                            rx03.for_engineering_sample_device = for_engineering_sample_device;
            
 








    altgxb_hssi_transmitter tx00 ( 
                             // Inputs
                            .datain(w_tx_in00), 
                            .pllclk(slow_pll_clk), 
                            .fastpllclk(fast_pll_clk),
                            .coreclk(i_tx_coreclk[0]),
                            .softreset(i_txdigitalresetout[0]),
                            .analogreset(i_txanalogresetout[0]),
                            .ctrlenable(tx_ctrlenable[1:0]),
                            .forcedisparity(tx_forcedisparity[1:0]), 
                            .xgmdatain(i_xgm_txdataout[7:0]),
                            .xgmctrl(i_xgm_txctrlout[0]),
                            .serialdatain(rx_in[0]),
                            .srlpbk(tx_srlpbk[0]), 
                            .devclrn(1'b1), 
                            .devpor(1'b1),
                            .vodctrl(tx_vodctrl[2:0]),
                            .preemphasisctrl(tx_preemphasisctrl[2:0]),
                            // Outputs
                            .dataout(w_tx_out[0]),
                            .xgmdataout(i_xgm_txdatain[7:0]), 
                            .xgmctrlenable(i_xgm_txctrl[0]), 
                            .rdenablesync(tx00_rd_enable_sync), 
                            .parallelfdbkdata(w_parallelfdbkdata00),
                            .pre8b10bdata(w_pre8b10bdata00)

                             );

                          defparam
                            tx00.channel_num           = 0,
                            tx00.channel_width         = channel_width,
                            tx00.serialization_factor  = deserialization_factor,
                            tx00.use_8b_10b_mode       = c_use_8b_10b_mode,
                            tx00.use_double_data_mode  = c_use_double_data_mode,
                            tx00.use_fifo_mode         = c_use_fifo_mode,
                            tx00.force_disparity_mode  = c_force_disparity_mode,
                            tx00.transmit_protocol     = tx_transmit_protocol,
                            tx00.use_self_test_mode    = use_self_test_mode,
                            tx00.self_test_mode        = self_test_mode,
                            tx00.use_vod_ctrl_signal   = use_vod_ctrl_signal,
                            tx00.vod_ctrl_setting      = vod_ctrl_setting,
                            tx00.use_preemphasis_ctrl_signal   = use_preemphasis_ctrl_signal,
                            tx00.preemphasis_ctrl_setting      = preemphasis_ctrl_setting,
                            tx00.use_reverse_parallel_feedback = c_use_reverse_parallel_feedback;

            
 

    altgxb_hssi_transmitter tx01 ( 
                             // Inputs
                            .datain(w_tx_in01), 
                            .pllclk(slow_pll_clk), 
                            .fastpllclk(fast_pll_clk),
                            .coreclk(i_tx_coreclk[1]),
                            .softreset(i_txdigitalresetout[1]),
                            .analogreset(i_txanalogresetout[1]),
                            .ctrlenable(tx_ctrlenable[3:2]),
                            .forcedisparity(tx_forcedisparity[3:2]), 
                            .xgmdatain(i_xgm_txdataout[15:8]),
                            .xgmctrl(i_xgm_txctrlout[1]),
                            .serialdatain(rx_in[1]),
                            .srlpbk(tx_srlpbk[1]), 
                            .devclrn(1'b1), 
                            .devpor(1'b1),
                            .vodctrl(tx_vodctrl[5:3]),
                            .preemphasisctrl(tx_preemphasisctrl[5:3]),
                            .dataout(w_tx_out[1]),
                            // Outputs
                            .xgmdataout(i_xgm_txdatain[15:8]), 
                            .xgmctrlenable(i_xgm_txctrl[1]), 
//                            .rdenablesync(tx00_rd_enable_sync), 
                            .rdenablesync(), 
                            .parallelfdbkdata(w_parallelfdbkdata01),
                            .pre8b10bdata(w_pre8b10bdata01)

                             );


                          defparam
                            tx01.channel_num           = 1,
                            tx01.serialization_factor  = deserialization_factor,
                            tx01.channel_width         = channel_width,
                            tx01.use_8b_10b_mode       = c_use_8b_10b_mode,
                            tx01.use_double_data_mode  = c_use_double_data_mode,
                            tx01.use_fifo_mode         = c_use_fifo_mode,
                            tx01.force_disparity_mode  = c_force_disparity_mode,
                            tx01.transmit_protocol     = tx_transmit_protocol,
                            tx01.use_self_test_mode    = use_self_test_mode,
                            tx01.self_test_mode        = self_test_mode,
                            tx01.use_vod_ctrl_signal   = use_vod_ctrl_signal,
                            tx01.vod_ctrl_setting      = vod_ctrl_setting,
                            tx01.use_preemphasis_ctrl_signal   = use_preemphasis_ctrl_signal,
                            tx01.preemphasis_ctrl_setting      = preemphasis_ctrl_setting,
                            tx01.use_reverse_parallel_feedback = c_use_reverse_parallel_feedback;


    altgxb_hssi_transmitter tx02 ( 
                             // Inputs
                            .datain(w_tx_in02), 
                            .pllclk(slow_pll_clk), 
                            .fastpllclk(fast_pll_clk),
                            .coreclk(i_tx_coreclk[2]),
                            .softreset(i_txdigitalresetout[2]),
                            .analogreset(i_txanalogresetout[2]),
                            .ctrlenable(tx_ctrlenable[5:4]),
                            .forcedisparity(tx_forcedisparity[5:4]), 
                            .xgmdatain(i_xgm_txdataout[23:16]),
                            .xgmctrl(i_xgm_txctrlout[2]),
                            .serialdatain(rx_in[2]),
                            .srlpbk(tx_srlpbk[2]), 
                            .devclrn(1'b1), 
                            .devpor(1'b1),
                            .vodctrl(tx_vodctrl[8:6]),
                            .preemphasisctrl(tx_preemphasisctrl[8:6]),
                            // Outputs
                            .dataout(w_tx_out[2]),
                            .xgmdataout(i_xgm_txdatain[23:16]), 
                            .xgmctrlenable(i_xgm_txctrl[2]), 
//                            .rdenablesync(tx00_rd_enable_sync), 
                            .rdenablesync(), 
                            .parallelfdbkdata(w_parallelfdbkdata02),
                            .pre8b10bdata(w_pre8b10bdata02)


                             );


                          defparam
                            tx02.channel_num           = 2,
                            tx02.serialization_factor  = deserialization_factor,
                            tx02.channel_width         = channel_width,
                            tx02.use_8b_10b_mode       = c_use_8b_10b_mode,
                            tx02.use_double_data_mode  = c_use_double_data_mode,
                            tx02.use_fifo_mode         = c_use_fifo_mode,
                            tx02.force_disparity_mode  = c_force_disparity_mode,
                            tx02.transmit_protocol     = tx_transmit_protocol,
                            tx02.use_self_test_mode    = use_self_test_mode,
                            tx02.self_test_mode        = self_test_mode,
                            tx02.use_vod_ctrl_signal   = use_vod_ctrl_signal,
                            tx02.vod_ctrl_setting      = vod_ctrl_setting,
                            tx02.use_preemphasis_ctrl_signal   = use_preemphasis_ctrl_signal,
                            tx02.preemphasis_ctrl_setting      = preemphasis_ctrl_setting,
                            tx02.use_reverse_parallel_feedback = c_use_reverse_parallel_feedback;




    altgxb_hssi_transmitter tx03 ( 
                             // Inputs
                            .datain(w_tx_in03), 
                            .pllclk(slow_pll_clk), 
                            .fastpllclk(fast_pll_clk),
                            .coreclk(i_tx_coreclk[3]),
                            .softreset(i_txdigitalresetout[3]),
                            .analogreset(i_txanalogresetout[3]),
                            .ctrlenable(tx_ctrlenable[7:6]),
                            .forcedisparity(tx_forcedisparity[7:6]), 
                            .xgmdatain(i_xgm_txdataout[31:24]),
                            .xgmctrl(i_xgm_txctrlout[3]),
                            .serialdatain(rx_in[3]),
                            .srlpbk(tx_srlpbk[3]), 
                            .devclrn(1'b1), 
                            .devpor(1'b1),
                            .vodctrl(tx_vodctrl[11:9]),
                            .preemphasisctrl(tx_preemphasisctrl[11:9]),
                            // Outputs
                            .dataout(w_tx_out[3]),
                            .xgmdataout(i_xgm_txdatain[31:24]), 
                            .xgmctrlenable(i_xgm_txctrl[3]), 
//                            .rdenablesync(tx00_rd_enable_sync), 
                            .rdenablesync(), 
                            .parallelfdbkdata(w_parallelfdbkdata03),
                            .pre8b10bdata(w_pre8b10bdata03)


                             );


                          defparam
                            tx03.channel_num           = 3,
                            tx03.serialization_factor  = deserialization_factor,
                            tx03.channel_width         = channel_width,
                            tx03.use_8b_10b_mode       = c_use_8b_10b_mode,
                            tx03.use_double_data_mode  = c_use_double_data_mode,
                            tx03.use_fifo_mode         = c_use_fifo_mode,
                            tx03.force_disparity_mode  = c_force_disparity_mode,
                            tx03.transmit_protocol     = tx_transmit_protocol,
                            tx03.use_self_test_mode    = use_self_test_mode,
                            tx03.self_test_mode        = self_test_mode,
                            tx03.use_vod_ctrl_signal   = use_vod_ctrl_signal,
                            tx03.vod_ctrl_setting      = vod_ctrl_setting,
                            tx03.use_preemphasis_ctrl_signal   = use_preemphasis_ctrl_signal,
                            tx03.preemphasis_ctrl_setting      = preemphasis_ctrl_setting,
                            tx03.use_reverse_parallel_feedback = c_use_reverse_parallel_feedback;







// PLL Atom


altgxb_pll quad_pll(
                 .inclk({temp_inclk,inclk}),
                 .pllena(1'b1),
                 .clkswitch(1'b0),
                 .areset(i_pllresetout),
                 .pfdena(1'b1),
                 .fbin(1'b1),
               	 .clkena(6'b000111),
	         .extclkena(4'b0000),
                 .scanclk(),
                 .scanaclr(1'b0),
                 .scandata(1'b0),
                 .clk({temp_clk, coreclk_out, slow_pll_clk, fast_pll_clk}),
                 .extclk(),
                 .clkbad(),
                 .activeclock(),
                 .clkloss(),
                 .locked(pll_locked), 
                 .scandataout()
              );
              
              
     defparam
         quad_pll.pll_type = "cdr",
         quad_pll.operation_mode = "normal",
         quad_pll.primary_clock = "inclk0",
         quad_pll.inclk0_input_frequency = pll_inclock_period,
         quad_pll.inclk1_input_frequency = pll_inclock_period,
         quad_pll.clk0_multiply_by = pllclk_mult,
         quad_pll.clk0_divide_by   = pllclk0_div,
         quad_pll.clk0_phase_shift_num = pll_phase_shift_0,
         quad_pll.clk1_multiply_by = pllclk_mult,
         quad_pll.clk1_divide_by   = deserialization_factor/pllclk_div_adj,
         quad_pll.clk1_phase_shift_num = pll_phase_shift_1,
         quad_pll.clk2_multiply_by = pllclk_mult,
         quad_pll.clk2_divide_by   = pllclk2_divisor/pllclk_div_adj,
         quad_pll.clk2_phase_shift_num = pll_phase_shift_2,
         quad_pll.simulation_type = "functional";



/*
				quad_pll.primary_clock = "inclk0",
				quad_pll.inclk0_input_frequency = 6400,
				quad_pll.clk0_multiply_by = 5,
				quad_pll.clk0_divide_by = 1,
				quad_pll.clk1_multiply_by = 5,
				quad_pll.clk1_divide_by = 5,
				quad_pll.clk2_multiply_by = 5,
				quad_pll.clk2_divide_by = 5;
*/


//  
// XGM Interface in atom level.

    altgxb_xgm_interface    xgm00 ( 
                                    // Input
                                    .txdatain(i_xgm_txdatain), 
                                    .txctrl(i_xgm_txctrl),

                                    .rdenablesync(tx00_rd_enable_sync), 
                                    .txclk(slow_pll_clk),
                                    .rxdatain(i_xgm_rxdatain), 
                                    .rxctrl(i_xgm_rxctrl),
                                    .rxrunningdisp(i_xgm_rxrunningdisp),
                                    .rxdatavalid(i_xgm_rx_data_valid_in),
  
                                    .rxclk(slow_pll_clk),
                                    .resetall(),
                                    .adet(i_xgm_adet),
                                    .syncstatus(i_xgm_syncstatus_deskew),
                                    .rdalign(i_xgm_rdalign),
                                    .recovclk(recovered_clk0),
                                    .devclrn(1'b1), 
                                    .devpor(1'b1),

                                    // PE ONLY PORTS
                                    .scanclk(), 
                                    .scanin(),
                                    .scanshift(),
                                    .scanmode(),
                                    .scanout(),
                                    .test(),
                                    .digitalsmtest(),
                                    .calibrationstatus(),
                                    // MDIO PORTS
                                    .mdiodisable(),
                                    .mdioclk(),
                                    .mdioin(),
                                    .rxppmselect(1'b0),
                                    .mdioout(),
                                    .mdiooe(),
                                    // RESET PORTS
                                    .txdigitalreset(txdigitalreset),
                                    .rxdigitalreset(rxdigitalreset),
                                    .rxanalogreset(rxanalogreset),
                                    .pllreset(pll_areset),
                                    .pllenable(pllenable),
                                    .txdigitalresetout(i_txdigitalresetout),
                                    .rxdigitalresetout(i_rxdigitalresetout),
                                    .txanalogresetout(i_txanalogresetout),
                                    .rxanalogresetout(i_rxanalogresetout),
                                    .pllresetout(i_pllresetout),


                                    // Output
                                    .txdataout(i_xgm_txdataout),
                                    .txctrlout(i_xgm_txctrlout),
                                    .rxdataout(i_xgm_rxdataout),
                                    .rxctrlout(i_xgm_rxctrlout),
                                    .alignstatus(channels_are_aligned),
	                            .enabledeskew(enable_deskew_fifo),
                                    .fiforesetrd(reset_deskew_fifo),
                                    .resetout()
                                   );
                         defparam
                            xgm00.mode_is_xaui                    = mode_is_xaui,
                            xgm00.use_continuous_calibration_mode = "ON",
                            xgm00.rx_ppm_setting_0                = rx_ppm_setting,
                            xgm00.rx_ppm_setting_1                = rx_ppm_setting;
            


 





    always @ (tx_in)
    begin
     if (reverse_loopback_mode != "RPLB")
      begin
        w_tx_in00 =
            tx_in[01*channel_width -1:00*channel_width];

        w_tx_in01 =
            tx_in[02*channel_width -1:01*channel_width];

        w_tx_in02 =
            tx_in[03*channel_width -1:02*channel_width];

        w_tx_in03 =
            tx_in[04*channel_width -1:03*channel_width];
       end

    end


   always @(slow_pll_clk or rx_cruclk) 
    begin
      if ((protocol_to_mode == "XAUI") || (use_rx_cruclk == "OFF"))
          begin
             i_cruclk =slow_pll_clk; 
          end
      else 
          begin
             i_cruclk = rx_cruclk;
          end
    end

   always @(coreclk_out or rx_clkout or rx_coreclk or tx_coreclk)
    begin
    // connect RX's coreclk to pll.clk[2] in Reverse Parallel Loopback mode
    if (reverse_loopback_mode == "RPLB")
    begin
           i_rx_coreclk[0] = coreclk_out;
           i_rx_coreclk[1] = coreclk_out;
           i_rx_coreclk[2] = coreclk_out;
           i_rx_coreclk[3] = coreclk_out;
    end
    else if (use_rx_coreclk == "ON")
      begin
           i_rx_coreclk[0] = rx_coreclk[0];
           i_rx_coreclk[1] = rx_coreclk[1];
           i_rx_coreclk[2] = rx_coreclk[2];
           i_rx_coreclk[3] = rx_coreclk[3];
      end
   else if ((protocol_to_mode == "XAUI") || 
          (protocol_to_mode == "GIGE") || 
          (use_rx_clkout == "OFF"))
        begin
           i_rx_coreclk[0] = coreclk_out;
           i_rx_coreclk[1] = coreclk_out;
           i_rx_coreclk[2] = coreclk_out;
           i_rx_coreclk[3] = coreclk_out;
        end
    else 
    begin
           i_rx_coreclk[0] = rx_clkout[0];
           i_rx_coreclk[1] = rx_clkout[1];
           i_rx_coreclk[2] = rx_clkout[2];
           i_rx_coreclk[3] = rx_clkout[3];
    end



    if (use_tx_coreclk == "ON")
      begin
           i_tx_coreclk[0] = tx_coreclk[0];
           i_tx_coreclk[1] = tx_coreclk[1];
           i_tx_coreclk[2] = tx_coreclk[2];
           i_tx_coreclk[3] = tx_coreclk[3];
      end
   else 
    begin
           i_tx_coreclk[0] = coreclk_out;
           i_tx_coreclk[1] = coreclk_out;
           i_tx_coreclk[2] = coreclk_out;
           i_tx_coreclk[3] = coreclk_out;
    end


  end
   always @(rx_we or t_rx_we)
   begin
    if (add_generic_fifo_we_synch_register == "ON")
      begin
           i_rx_we[0] = t_rx_we[0];
           i_rx_we[1] = t_rx_we[1];
           i_rx_we[2] = t_rx_we[2];
           i_rx_we[3] = t_rx_we[3];
      end
   else 
    begin
           i_rx_we[0] = rx_we[0];
           i_rx_we[1] = rx_we[1];
           i_rx_we[2] = rx_we[2];
           i_rx_we[3] = rx_we[3];
    end

   end


   always @(w_rx_out00)
    begin
       i_rx_out[rx_channel_width * 1 - 1: rx_channel_width * 0 ] = w_rx_out00[rx_channel_width-1:0];
       if (reverse_loopback_mode == "RPLB")
        begin
          w_tx_in00 = w_rx_out00[rx_channel_width-1:0];
        end

    end

   always @(w_rx_out01)
    begin
       i_rx_out[rx_channel_width * 2 - 1: rx_channel_width * 1 ] = w_rx_out01[rx_channel_width-1:0];
       if (reverse_loopback_mode == "RPLB")
        begin
          w_tx_in01 = w_rx_out01[rx_channel_width-1:0];
        end

    end

   always @(w_rx_out02)
    begin
       i_rx_out[rx_channel_width * 3 - 1: rx_channel_width * 2 ] = w_rx_out02[rx_channel_width-1:0];
       if (reverse_loopback_mode == "RPLB")
        begin
          w_tx_in02 = w_rx_out02[rx_channel_width-1:0];
        end

    end

   always @(w_rx_out03)
     begin
       i_rx_out[rx_channel_width * 4 - 1: rx_channel_width * 3 ] = w_rx_out03[rx_channel_width-1:0];
       if (reverse_loopback_mode == "RPLB")
        begin
          w_tx_in03 = w_rx_out03[rx_channel_width-1:0];
        end

    end

  // Outputs for Receiver
   assign rx_out = i_rx_out[rx_channel_width * number_of_channels-1:0];

  // Outputs for Transmitter
  assign tx_out = w_tx_out[number_of_channels-1:0];
  assign rx_channelaligned = channels_are_aligned;


endmodule



///////////////////////////////////////////////////////////////////////////////
//
//                          end of altgxb megafunction
//
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
//
//                         GXB Codes from atom level
//
///////////////////////////////////////////////////////////////////////////////




///////////////////////////////////////////////////////////////////////////////
//
//                             altgxb_pll
//
///////////////////////////////////////////////////////////////////////////////




`timescale 1ps / 1ps

// ***** DFFE

primitive ALTGXB_PRIM_DFFE (Q, ENA, D, CLK, CLRN, PRN, notifier);
   input D;   
   input CLRN;
   input PRN;
   input CLK;
   input ENA;
   input notifier;
   output Q; reg Q;

   initial Q = 1'b0;

    table

    //  ENA  D   CLK   CLRN  PRN  notifier  :   Qt  :   Qt+1

        (??) ?    ?      1    1      ?      :   ?   :   -;  // pessimism
         x   ?    ?      1    1      ?      :   ?   :   -;  // pessimism
         1   1   (01)    1    1      ?      :   ?   :   1;  // clocked data
         1   1   (01)    1    x      ?      :   ?   :   1;  // pessimism
 
         1   1    ?      1    x      ?      :   1   :   1;  // pessimism
 
         1   0    0      1    x      ?      :   1   :   1;  // pessimism
         1   0    x      1  (?x)     ?      :   1   :   1;  // pessimism
         1   0    1      1  (?x)     ?      :   1   :   1;  // pessimism
 
         1   x    0      1    x      ?      :   1   :   1;  // pessimism
         1   x    x      1  (?x)     ?      :   1   :   1;  // pessimism
         1   x    1      1  (?x)     ?      :   1   :   1;  // pessimism
 
         1   0   (01)    1    1      ?      :   ?   :   0;  // clocked data

         1   0   (01)    x    1      ?      :   ?   :   0;  // pessimism

         1   0    ?      x    1      ?      :   0   :   0;  // pessimism
         0   ?    ?      x    1      ?      :   ?   :   -;

         1   1    0      x    1      ?      :   0   :   0;  // pessimism
         1   1    x    (?x)   1      ?      :   0   :   0;  // pessimism
         1   1    1    (?x)   1      ?      :   0   :   0;  // pessimism

         1   x    0      x    1      ?      :   0   :   0;  // pessimism
         1   x    x    (?x)   1      ?      :   0   :   0;  // pessimism
         1   x    1    (?x)   1      ?      :   0   :   0;  // pessimism

//       1   1   (x1)    1    1      ?      :   1   :   1;  // reducing pessimism
//       1   0   (x1)    1    1      ?      :   0   :   0;
         1   ?   (x1)    1    1      ?      :   ?   :   -;  // spr 80166-ignore
                                                            // x->1 edge
         1   1   (0x)    1    1      ?      :   1   :   1;
         1   0   (0x)    1    1      ?      :   0   :   0;

         ?   ?   ?       0    1      ?      :   ?   :   0;  // asynch clear

         ?   ?   ?       1    0      ?      :   ?   :   1;  // asynch set

         1   ?   (?0)    1    1      ?      :   ?   :   -;  // ignore falling clock
         1   ?   (1x)    1    1      ?      :   ?   :   -;  // ignore falling clock
         1   *    ?      ?    ?      ?      :   ?   :   -; // ignore data edges

         1   ?   ?     (?1)   ?      ?      :   ?   :   -;  // ignore edges on
         1   ?   ?       ?  (?1)     ?      :   ?   :   -;  //  set and clear

         0   ?   ?       1    1      ?      :   ?   :   -;  //  set and clear

	 ?   ?   ?       1    1      *      :   ?   :   x; // spr 36954 - at any
							   // notifier event,
							   // output 'x'
    endtable

endprimitive

module altgxb_dffe ( Q, CLK, ENA, D, CLRN, PRN );
   input D;
   input CLK;
   input CLRN;
   input PRN;
   input ENA;
   output Q;
   
   buf (D_ipd, D);
   buf (ENA_ipd, ENA);
   buf (CLK_ipd, CLK);
   buf (PRN_ipd, PRN);
   buf (CLRN_ipd, CLRN);
   
   wire   legal;
   reg 	  viol_notifier;
   
   ALTGXB_PRIM_DFFE ( Q, ENA_ipd, D_ipd, CLK_ipd, CLRN_ipd, PRN_ipd, viol_notifier );
   
   and(legal, ENA_ipd, CLRN_ipd, PRN_ipd);
   specify
      
      specparam TREG = 0;
      specparam TREN = 0;
      specparam TRSU = 0;
      specparam TRH  = 0;
      specparam TRPR = 0;
      specparam TRCL = 0;
      
      $setup  (  D, posedge CLK &&& legal, TRSU, viol_notifier  ) ;
      $hold   (  posedge CLK &&& legal, D, TRH, viol_notifier   ) ;
      $setup  (  ENA, posedge CLK &&& legal, TREN, viol_notifier  ) ;
      $hold   (  posedge CLK &&& legal, ENA, 0, viol_notifier   ) ;
 
      ( negedge CLRN => (Q  +: 1'b0)) = ( TRCL, TRCL) ;
      ( negedge PRN  => (Q  +: 1'b1)) = ( TRPR, TRPR) ;
      ( posedge CLK  => (Q  +: D)) = ( TREG, TREG) ;
      
   endspecify
endmodule     



///////////////////////////////////////////////////////////////////////////////
//
// Module Name : altgxb_m_cntr
//
// Description : Timing simulation model for the M counter. This is the
//               loop feedback counter for the Stratix PLL.
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps
module altgxb_m_cntr (clk,
               reset,
               cout,
               initial_value,
               modulus,
               time_delay
              );

    // INPUT PORTS
    input clk;
    input reset;
    input [31:0] initial_value;
    input [31:0] modulus;
   input [31:0] time_delay;

    // OUTPUT PORTS
   output cout;

    // INTERNAL VARIABLES AND NETS
   integer count;
   reg tmp_cout;
   reg first_rising_edge;
   reg clk_last_value;
   reg cout_tmp;

initial
begin
   count = 1;
   first_rising_edge = 1;
   clk_last_value = 0;
end

always @(reset or clk)
begin
   if (reset)
   begin
       count = 1;
       tmp_cout = 0;
       first_rising_edge = 1;
   end
        else begin
            if (clk == 1 && clk_last_value !== clk && first_rising_edge)
       begin
          first_rising_edge = 0;
          tmp_cout = clk;
       end
       else if (first_rising_edge == 0)
       begin
          if (count < modulus)
             count = count + 1;
          else
          begin
             count = 1;
             tmp_cout = ~tmp_cout;
          end
       end
   end
   clk_last_value = clk;

   cout_tmp <= #(time_delay) tmp_cout;
end

and (cout, cout_tmp, 1'b1);

endmodule // altgxb_m_cntr

///////////////////////////////////////////////////////////////////////////////
//
// Module Name : altgxb_n_cntr
//
// Description : Timing simulation model for the N counter. This is the
//               input clock divide counter for the Stratix PLL.
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps
module altgxb_n_cntr (clk,
               reset,
               cout,
               modulus,
               time_delay
              );

    // INPUT PORTS
    input clk;
    input reset;
    input [31:0] modulus;
    input [31:0] time_delay;

    // OUTPUT PORTS
    output cout;

    // INTERNAL VARIABLES AND NETS
    integer count;
    reg tmp_cout;
    reg first_rising_edge;
    reg clk_last_value;
    reg cout_tmp;

    initial
    begin
        count = 1;
        first_rising_edge = 1;
        clk_last_value = 0;
    end

    always @(reset or clk)
    begin
        if (reset)
        begin
            count = 1;
            tmp_cout = 0;
            first_rising_edge = 1;
        end
        else begin
            if (clk == 1 && clk_last_value !== clk && first_rising_edge)
            begin
                first_rising_edge = 0;
                tmp_cout = clk;
            end
            else if (first_rising_edge == 0)
            begin
                if (count < modulus)
                    count = count + 1;
                else
                begin
                    count = 1;
                    tmp_cout = ~tmp_cout;
                end
            end
        end
        clk_last_value = clk;

        cout_tmp <= #(time_delay) tmp_cout;
    end

    and (cout, cout_tmp, 1'b1);

endmodule // altgxb_n_cntr

///////////////////////////////////////////////////////////////////////////////
//
// Module Name : altgxb_scale_cntr
//
// Description : Timing simulation model for the output scale-down counters.
//               This is a common model for the L0, L1, G0, G1, G2, G3, E0,
//               E1, E2 and E3 output counters of the Stratix PLL.
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps
module altgxb_scale_cntr(clk,
                  reset,
                  cout,
                  high,
                  low,
                  initial_value,
                  mode,
                  time_delay,
                  ph_tap
                 );

    // INPUT PORTS
    input clk;
    input reset;
    input [31:0] high;
    input [31:0] low;
input [31:0] initial_value;
input [8*6:1] mode;
input [31:0] time_delay;
input [31:0] ph_tap;

    // OUTPUT PORTS
output cout;

    // INTERNAL VARIABLES AND NETS
   reg tmp_cout;
   reg first_rising_edge;
   reg clk_last_value;
   reg init;
   integer count;
   integer output_shift_count;
   reg cout_tmp;
   reg [31:0] high_reg;
   reg [31:0] low_reg;

   initial
   begin
      count = 1;
      first_rising_edge = 0;
      tmp_cout = 0;
      output_shift_count = 0;
   end

    always @(clk or reset)
   begin
        if (init !== 1'b1)
        begin
            high_reg = high;
            low_reg = low;
            clk_last_value = 0;
            init = 1'b1;
        end
        if (reset)
      begin
         count = 1;
         output_shift_count = 0;
         tmp_cout = 0;
         first_rising_edge = 0;
      end
        else if (clk_last_value !== clk)
      begin
         if (mode == "off")
            tmp_cout = 0;
         else if (mode == "bypass")
            tmp_cout = clk;
         else if (first_rising_edge == 0)
         begin
            if (clk == 1)
            begin
               output_shift_count = output_shift_count + 1;
               if (output_shift_count == initial_value)
               begin
                  tmp_cout = clk;
                  first_rising_edge = 1;
               end
            end
         end
         else if (output_shift_count < initial_value)
         begin
            if (clk == 1)
               output_shift_count = output_shift_count + 1;
         end
         else
         begin
            count = count + 1;
                if (mode == "even" && (count == (high_reg*2) + 1))
                begin
               tmp_cout = 0;
                    low_reg = low;
                end
                else if (mode == "odd" && (count == (high_reg*2)))
                begin
               tmp_cout = 0;
                    low_reg = low;
                end
                else if (count == (high_reg + low_reg)*2 + 1)
            begin
               tmp_cout = 1;
               count = 1;        // reset count
                    high_reg = high;
            end
         end
      end
      clk_last_value = clk;
        cout_tmp <= #(time_delay) tmp_cout;
   end

    and (cout, cout_tmp, 1'b1);

endmodule // altgxb_scale_cntr

///////////////////////////////////////////////////////////////////////////////
//
// Module Name : altgxb_pll_reg
//
// Description : Simulation model for a simple DFF.
//               This is required for the generation of the bit slip-signals.
//               No timing, powers upto 0.
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ps / 1ps
module altgxb_pll_reg (q,
                clk,
                ena,
                d,
                clrn,
                prn
               );

    // INPUT PORTS
    input d;
    input clk;
    input clrn;
    input prn;
    input ena;

    // OUTPUT PORTS
    output q;

    // INTERNAL VARIABLES
    reg q;

    // DEFAULT VALUES THRO' PULLUPs
    tri1 prn, clrn, ena;

    initial q = 0;

    always @ (posedge clk or negedge clrn or negedge prn )
    begin
        if (prn == 1'b0)
            q <= 1;
        else if (clrn == 1'b0)
            q <= 0;
        else if ((clk == 1) & (ena == 1'b1))
            q <= d;
    end

endmodule // altgxb_pll_reg
//////////////////////////////////////////////////////////////////////////////
//
// Module Name : stratix_pll
//
// Description : Timing simulation model for the Stratix StratixGX PLL.
//               In the functional mode, it is also the model for the altpll
//               megafunction.
// 
// Limitations : Does not support Spread Spectrum and Bandwidth.
//
// Outputs     : Up to 10 output clocks, each defined by its own set of
//               parameters. Locked output (active high) indicates when the
//               PLL locks. clkbad, clkloss and activeclock are used for
//               clock switchover to inidicate which input clock has gone
//               bad, when the clock switchover initiates and which input
//               clock is being used as the reference, respectively.
//               scandataout is the data output of the serial scan chain.
//
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps/1 ps
`define ALTGXB_PLL_WORD_LENGTH 18

module altgxb_stratix_pll (inclk,
                    fbin,
                    ena,
                    clkswitch,
                    areset,
                    pfdena,
                    clkena,
                    extclkena,
                    scanclk,
                    scanaclr,
                    scandata,
                    clk,
                    extclk,
                    clkbad,
                    activeclock,
                    locked,
                    clkloss,
                    scandataout,
                    // lvds mode specific ports
                    comparator,
                    enable0,
                    enable1
                   );

    parameter operation_mode = "normal";
    parameter qualify_conf_done = "off";
    parameter compensate_clock = "clk0";
    parameter pll_type = "auto";
    parameter scan_chain = "long";
    parameter lpm_type = "stratix_pll";

    parameter clk0_multiply_by = 1;
    parameter clk0_divide_by = 1;
    parameter clk0_phase_shift = 0;
    parameter clk0_time_delay = 0;
    parameter clk0_duty_cycle = 50;

    parameter clk1_multiply_by = 1;
    parameter clk1_divide_by = 1;
    parameter clk1_phase_shift = 0;
    parameter clk1_time_delay = 0;
    parameter clk1_duty_cycle = 50;

    parameter clk2_multiply_by = 1;
    parameter clk2_divide_by = 1;
    parameter clk2_phase_shift = 0;
    parameter clk2_time_delay = 0;
    parameter clk2_duty_cycle = 50;

    parameter clk3_multiply_by = 1;
    parameter clk3_divide_by = 1;
    parameter clk3_phase_shift = 0;
    parameter clk3_time_delay = 0;
    parameter clk3_duty_cycle = 50;

    parameter clk4_multiply_by = 1;
    parameter clk4_divide_by = 1;
    parameter clk4_phase_shift = 0;
    parameter clk4_time_delay = 0;
    parameter clk4_duty_cycle = 50;

    parameter clk5_multiply_by = 1;
    parameter clk5_divide_by = 1;
    parameter clk5_phase_shift = 0;
    parameter clk5_time_delay = 0;
    parameter clk5_duty_cycle = 50;

    parameter extclk0_multiply_by = 1;
    parameter extclk0_divide_by = 1;
    parameter extclk0_phase_shift = 0;
    parameter extclk0_time_delay = 0;
    parameter extclk0_duty_cycle = 50;

    parameter extclk1_multiply_by = 1;
    parameter extclk1_divide_by = 1;
    parameter extclk1_phase_shift = 0;
    parameter extclk1_time_delay = 0;
    parameter extclk1_duty_cycle = 50;

    parameter extclk2_multiply_by = 1;
    parameter extclk2_divide_by = 1;
    parameter extclk2_phase_shift = 0;
    parameter extclk2_time_delay = 0;
    parameter extclk2_duty_cycle = 50;

    parameter extclk3_multiply_by = 1;
    parameter extclk3_divide_by = 1;
    parameter extclk3_phase_shift = 0;
    parameter extclk3_time_delay = 0;
    parameter extclk3_duty_cycle = 50;

    parameter primary_clock = "inclk0";
    parameter inclk0_input_frequency = 10000;
    parameter inclk1_input_frequency = 10000;
    parameter gate_lock_signal = "no";
    parameter gate_lock_counter = 1;
    parameter valid_lock_multiplier = 5;
    parameter invalid_lock_multiplier = 5;

    parameter switch_over_on_lossclk = "off";
    parameter switch_over_on_gated_lock = "off";
    parameter switch_over_counter = 1;
    parameter enable_switch_over_counter = "off";
    parameter feedback_source = "e0";
    parameter bandwidth = 0;
    parameter bandwidth_type = "auto";
    parameter down_spread = "0.0";
    parameter spread_frequency = 0;
    parameter common_rx_tx = "off";
    parameter rx_outclock_resource = "auto";
    parameter use_vco_bypass = "OFF";
    parameter use_dc_coupling = "OFF";

    parameter pfd_min = 0;
    parameter pfd_max = 0;
    parameter vco_min = 0;
    parameter vco_max = 0;
    parameter vco_center = 0;

    // ADVANCED USE PARAMETERS
    parameter m_initial = 1;
    parameter m = 1;
    parameter n = 1;
    parameter m2 = 1;
    parameter n2 = 1;
    parameter ss = 0;

    parameter l0_high = 1;
    parameter l0_low = 1;
    parameter l0_initial = 1;
    parameter l0_mode = "bypass";
    parameter l0_ph = 0;
    parameter l0_time_delay = 0;

    parameter l1_high = 1;
    parameter l1_low = 1;
    parameter l1_initial = 1;
    parameter l1_mode = "bypass";
    parameter l1_ph = 0;
    parameter l1_time_delay = 0;

    parameter g0_high = 1;
    parameter g0_low = 1;
    parameter g0_initial = 1;
    parameter g0_mode = "bypass";
    parameter g0_ph = 0;
    parameter g0_time_delay = 0;

    parameter g1_high = 1;
    parameter g1_low = 1;
    parameter g1_initial = 1;
    parameter g1_mode = "bypass";
    parameter g1_ph = 0;
    parameter g1_time_delay = 0;

    parameter g2_high = 1;
    parameter g2_low = 1;
    parameter g2_initial = 1;
    parameter g2_mode = "bypass";
    parameter g2_ph = 0;
    parameter g2_time_delay = 0;

    parameter g3_high = 1;
    parameter g3_low = 1;
    parameter g3_initial = 1;
    parameter g3_mode = "bypass";
    parameter g3_ph = 0;
    parameter g3_time_delay = 0;

    parameter e0_high = 1;
    parameter e0_low = 1;
    parameter e0_initial = 1;
    parameter e0_mode = "bypass";
    parameter e0_ph = 0;
    parameter e0_time_delay = 0;

    parameter e1_high = 1;
    parameter e1_low = 1;
    parameter e1_initial = 1;
    parameter e1_mode = "bypass";
    parameter e1_ph = 0;
    parameter e1_time_delay = 0;

    parameter e2_high = 1;
    parameter e2_low = 1;
    parameter e2_initial = 1;
    parameter e2_mode = "bypass";
    parameter e2_ph = 0;
    parameter e2_time_delay = 0;

    parameter e3_high = 1;
    parameter e3_low = 1;
    parameter e3_initial = 1;
    parameter e3_mode = "bypass";
    parameter e3_ph = 0;
    parameter e3_time_delay = 0;

    parameter m_ph = 0;
    parameter m_time_delay = 0;
    parameter n_time_delay = 0;

    parameter extclk0_counter = "e0";
    parameter extclk1_counter = "e1";
    parameter extclk2_counter = "e2";
    parameter extclk3_counter = "e3";

    parameter clk0_counter = "g0";
    parameter clk1_counter = "g1";
    parameter clk2_counter = "g2";
    parameter clk3_counter = "g3";
    parameter clk4_counter = "l0";
    parameter clk5_counter = "l1";

    // LVDS mode parameters
    parameter enable0_counter = "l0";
    parameter enable1_counter = "l0";

    parameter charge_pump_current = 0;
    parameter loop_filter_r = "1.0";
    parameter loop_filter_c = 1;

    parameter pll_compensation_delay = 0;
    parameter simulation_type = "timing";
    parameter source_is_pll = "off";

    //parameter for stratix lvds
    parameter clk0_phase_shift_num = 0;
    parameter clk1_phase_shift_num = 0;
    parameter clk2_phase_shift_num = 0;

    parameter skip_vco = "off";

    // INPUT PORTS
    input [1:0] inclk;
    input fbin;
    input ena;
    input clkswitch;
    input areset;
    input pfdena;
    input [5:0] clkena;
    input [3:0] extclkena;
    input scanclk;
    input scanaclr;
    input scandata;
    // lvds specific input ports
    input comparator;

    // OUTPUT PORTS
    output [5:0] clk;
    output [3:0] extclk;
    output [1:0] clkbad;
    output activeclock;
    output locked;
    output clkloss;
    output scandataout;
    // lvds specific output ports
    output enable0;
    output enable1;

    // BUFFER INPUTS
    buf (inclk0_ipd, inclk[0]);
    buf (inclk1_ipd, inclk[1]);
    buf (ena_ipd, ena);
    buf (fbin_ipd, fbin);
    buf (areset_ipd, areset);
    buf (pfdena_ipd, pfdena);
    buf (clkena0_ipd, clkena[0]);
    buf (clkena1_ipd, clkena[1]);
    buf (clkena2_ipd, clkena[2]);
    buf (clkena3_ipd, clkena[3]);
    buf (clkena4_ipd, clkena[4]);
    buf (clkena5_ipd, clkena[5]);
    buf (extclkena0_ipd, extclkena[0]);
    buf (extclkena1_ipd, extclkena[1]);
    buf (extclkena2_ipd, extclkena[2]);
    buf (extclkena3_ipd, extclkena[3]);
    buf (scanclk_ipd, scanclk);
    buf (scanaclr_ipd, scanaclr);
    buf (scandata_ipd, scandata);
    buf (comparator_ipd, comparator);
    buf (clkswitch_ipd, clkswitch);

    // INTERNAL VARIABLES AND NETS
    integer scan_chain_length;
    integer i;
    integer j;
    integer k;
    integer l_index;
    integer gate_count;
    integer egpp_offset;
    integer sched_time;
    integer delay_chain;
    integer low;
    integer high;
    integer initial_delay;
    integer fbk_phase;
    integer fbk_delay;
    integer phase_shift[0:7];
    integer last_phase_shift[0:7];

    integer m_times_vco_period;
    integer new_m_times_vco_period;
    integer refclk_period;
    integer fbclk_period;
    integer primary_clock_frequency;
    integer high_time;
    integer low_time;
    integer my_rem;
    integer tmp_rem;
    integer rem;
    integer tmp_vco_per;
    integer vco_per;
    integer offset;
    integer temp_offset;
    integer cycles_to_lock;
    integer cycles_to_unlock;
    integer l0_count;
    integer l1_count;
    integer loop_xplier;
    integer loop_initial;
    integer loop_ph;
    integer loop_time_delay;
    integer cycle_to_adjust;
    integer total_pull_back;
    integer pull_back_M;
    integer pull_back_ext_cntr;

    time    fbclk_time;
    time    first_fbclk_time;
    time    refclk_time;
    time    scanaclr_rising_time;
    time    scanaclr_falling_time;
 
    reg got_first_refclk;
    reg got_second_refclk;
    reg got_first_fbclk;
    reg refclk_last_value;
    reg fbclk_last_value;
    reg inclk_last_value;
    reg pll_is_locked;
    reg pll_about_to_lock;
    reg locked_tmp;
    reg l0_got_first_rising_edge;
    reg l1_got_first_rising_edge;
    reg vco_l0_last_value;
    reg vco_l1_last_value;
    reg areset_ipd_last_value;
    reg ena_ipd_last_value;
    reg pfdena_ipd_last_value;
    reg inclk_out_of_range;
    reg schedule_vco_last_value;

    reg gate_out;
    reg vco_val;

    reg [31:0] m_initial_val;
    reg [31:0] m_val;
    reg [31:0] m2_val;
    reg [31:0] n_val;
    reg [31:0] n2_val;
    reg [31:0] m_time_delay_val;
    reg [31:0] n_time_delay_val;
    reg [31:0] m_delay;
    reg [8*6:1] m_mode_val;
    reg [8*6:1] m2_mode_val;
    reg [8*6:1] n_mode_val;
    reg [8*6:1] n2_mode_val;
    reg [31:0] l0_high_val;
    reg [31:0] l0_low_val;
    reg [31:0] l0_initial_val;
    reg [31:0] l0_time_delay_val;
    reg [8*6:1] l0_mode_val;
    reg [31:0] l1_high_val;
    reg [31:0] l1_low_val;
    reg [31:0] l1_initial_val;
    reg [31:0] l1_time_delay_val;
    reg [8*6:1] l1_mode_val;

    reg [31:0] g0_high_val;
    reg [31:0] g0_low_val;
    reg [31:0] g0_initial_val;
    reg [31:0] g0_time_delay_val;
    reg [8*6:1] g0_mode_val;

    reg [31:0] g1_high_val;
    reg [31:0] g1_low_val;
    reg [31:0] g1_initial_val;
    reg [31:0] g1_time_delay_val;
    reg [8*6:1] g1_mode_val;

    reg [31:0] g2_high_val;
    reg [31:0] g2_low_val;
    reg [31:0] g2_initial_val;
    reg [31:0] g2_time_delay_val;
    reg [8*6:1] g2_mode_val;

    reg [31:0] g3_high_val;
    reg [31:0] g3_low_val;
    reg [31:0] g3_initial_val;
    reg [31:0] g3_time_delay_val;
    reg [8*6:1] g3_mode_val;

    reg [31:0] e0_high_val;
    reg [31:0] e0_low_val;
    reg [31:0] e0_initial_val;
    reg [31:0] e0_time_delay_val;
    reg [8*6:1] e0_mode_val;

    reg [31:0] e1_high_val;
    reg [31:0] e1_low_val;
    reg [31:0] e1_initial_val;
    reg [31:0] e1_time_delay_val;
    reg [8*6:1] e1_mode_val;

    reg [31:0] e2_high_val;
    reg [31:0] e2_low_val;
    reg [31:0] e2_initial_val;
    reg [31:0] e2_time_delay_val;
    reg [8*6:1] e2_mode_val;

    reg [31:0] e3_high_val;
    reg [31:0] e3_low_val;
    reg [31:0] e3_initial_val;
    reg [31:0] e3_time_delay_val;
    reg [8*6:1] e3_mode_val;

    reg scanclk_last_value;
    reg scanaclr_last_value;
    reg transfer;
    reg transfer_enable;
    reg [288:0] scan_data;
    reg schedule_vco;
    reg schedule_offset;
    reg stop_vco;
    reg inclk_n;

    reg [7:0] vco_out;
    wire inclk_l0;
    wire inclk_l1;
    wire inclk_m;
    wire clk0_tmp;
    wire clk1_tmp;
    wire clk2_tmp;
    wire clk3_tmp;
    wire clk4_tmp;
    wire clk5_tmp;
    wire extclk0_tmp;
    wire extclk1_tmp;
    wire extclk2_tmp;
    wire extclk3_tmp;
    wire nce_l0;
    wire nce_l1;
    wire nce_temp;

    reg vco_l0;
    reg vco_l1;

    wire clk0;
    wire clk1;
    wire clk2;
    wire clk3;
    wire clk4;
    wire clk5;
    wire extclk0;
    wire extclk1;
    wire extclk2;
    wire extclk3;
    
    wire lvds_dffb_clk;
    wire dffa_out;
    
    reg first_schedule;

    wire enable0_tmp;
    wire enable1_tmp;
    wire enable_0;
    wire enable_1;
    reg l0_tmp;
    reg l1_tmp;

    reg vco_period_was_phase_adjusted;
    reg phase_adjust_was_scheduled;

    // for external feedback mode

    reg [31:0] ext_fbk_cntr_high;
    reg [31:0] ext_fbk_cntr_low;
    reg [31:0] ext_fbk_cntr_delay;
    reg [8*2:1] ext_fbk_cntr;
    integer ext_fbk_cntr_ph;
    integer ext_fbk_cntr_initial;

    wire inclk_e0;
    wire inclk_e1;
    wire inclk_e2;
    wire inclk_e3;
    wire [31:0] cntr_e0_initial;
    wire [31:0] cntr_e1_initial;
    wire [31:0] cntr_e2_initial;
    wire [31:0] cntr_e3_initial;
    wire [31:0] cntr_e0_delay;
    wire [31:0] cntr_e1_delay;
    wire [31:0] cntr_e2_delay;
    wire [31:0] cntr_e3_delay;
    reg  [31:0] ext_fbk_delay;

    // variables for clk_switch
    reg clk0_is_bad;
    reg clk1_is_bad;
    reg inclk0_last_value;
    reg inclk1_last_value;
    reg other_clock_value;
    reg other_clock_last_value;
    reg primary_clk_is_bad;
    reg current_clk_is_bad;
    reg external_switch;
    reg [8*6:1] current_clock;
    reg active_clock;
    reg clkloss_tmp;
    reg got_curr_clk_falling_edge_after_clkswitch;
    reg active_clk_was_switched;

    integer clk0_count;
    integer clk1_count;
    integer switch_over_count;

    reg scandataout_tmp;
    integer quiet_time;
    reg pll_in_quiet_period;
    time start_quiet_time;
    reg quiet_period_violation;
    reg reconfig_err;
    reg scanclr_violation;
    reg scanclr_clk_violation;
    reg got_first_scanclk_after_scanclr_inactive_edge;
    reg error;

    reg no_warn;

    // internal parameters
    parameter EGPP_SCAN_CHAIN = 289;
    parameter GPP_SCAN_CHAIN = 193;
    parameter TRST = 5000;
    parameter TRSTCLK = 5000;

    // user to advanced internal signals

    integer   i_m_initial;
    integer   i_m;
    integer   i_n;
    integer   i_m2;
    integer   i_n2;
    integer   i_ss;
    integer   i_l0_high;
    integer   i_l1_high;
    integer   i_g0_high;
    integer   i_g1_high;
    integer   i_g2_high;
    integer   i_g3_high;
    integer   i_e0_high;
    integer   i_e1_high;
    integer   i_e2_high;
    integer   i_e3_high;
    integer   i_l0_low;
    integer   i_l1_low;
    integer   i_g0_low;
    integer   i_g1_low;
    integer   i_g2_low;
    integer   i_g3_low;
    integer   i_e0_low;
    integer   i_e1_low;
    integer   i_e2_low;
    integer   i_e3_low;
    integer   i_l0_initial;
    integer   i_l1_initial;
    integer   i_g0_initial;
    integer   i_g1_initial;
    integer   i_g2_initial;
    integer   i_g3_initial;
    integer   i_e0_initial;
    integer   i_e1_initial;
    integer   i_e2_initial;
    integer   i_e3_initial;
    reg [8*6:1]   i_l0_mode;
    reg [8*6:1]   i_l1_mode;
    reg [8*6:1]   i_g0_mode;
    reg [8*6:1]   i_g1_mode;
    reg [8*6:1]   i_g2_mode;
    reg [8*6:1]   i_g3_mode;
    reg [8*6:1]   i_e0_mode;
    reg [8*6:1]   i_e1_mode;
    reg [8*6:1]   i_e2_mode;
    reg [8*6:1]   i_e3_mode;
    integer   i_vco_min;
    integer   i_vco_max;
    integer   i_vco_center;
    integer   i_pfd_min;
    integer   i_pfd_max;
    integer   i_l0_ph;
    integer   i_l1_ph;
    integer   i_g0_ph;
    integer   i_g1_ph;
    integer   i_g2_ph;
    integer   i_g3_ph;
    integer   i_e0_ph;
    integer   i_e1_ph;
    integer   i_e2_ph;
    integer   i_e3_ph;
    integer   i_m_ph;
    integer   m_ph_val;
    integer   i_l0_time_delay;
    integer   i_l1_time_delay;
    integer   i_g0_time_delay;
    integer   i_g1_time_delay;
    integer   i_g2_time_delay;
    integer   i_g3_time_delay;
    integer   i_e0_time_delay;
    integer   i_e1_time_delay;
    integer   i_e2_time_delay;
    integer   i_e3_time_delay;
    integer   i_m_time_delay;
    integer   i_n_time_delay;
    integer   i_extclk3_counter;
    integer   i_extclk2_counter;
    integer   i_extclk1_counter;
    integer   i_extclk0_counter;
    integer   i_clk5_counter;
    integer   i_clk4_counter;
    integer   i_clk3_counter;
    integer   i_clk2_counter;
    integer   i_clk1_counter;
    integer   i_clk0_counter;
    integer   i_charge_pump_current;
    integer   i_loop_filter_r;
    integer   max_neg_abs;
    integer   output_count;

    // uppercase to lowercase parameter values
    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] l_operation_mode;
    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] l_pll_type;
    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] l_qualify_conf_done;
    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] l_compensate_clock;
    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] l_scan_chain;
    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] l_primary_clock;
    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] l_gate_lock_signal;
    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] l_switch_over_on_lossclk;
    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] l_switch_over_on_gated_lock;
    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] l_enable_switch_over_counter;
    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] l_feedback_source;
    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] l_bandwidth_type;
    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] l_simulation_type;
//    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] l_source_is_pll;
    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] l_enable0_counter;
    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] l_enable1_counter;

    reg init;

    specify
    endspecify

    function integer abs;
    input value;
    integer value;
    begin
       if (value < 0)
          abs = value * -1;
       else abs = value;
    end
    endfunction

    // find twice the period of the slowest clock
    function integer slowest_clk;
    input L0, L1, G0, G1, G2, G3, E0, E1, E2, E3, scan_chain, refclk, m_mod;
    integer L0, L1, G0, G1, G2, G3, E0, E1, E2, E3;
    reg [8*5:1] scan_chain;
    integer refclk;
    reg [31:0] m_mod;
    integer max_modulus;
    begin
       if (L0 > L1)
           max_modulus = L0;
       else
           max_modulus = L1;
       if (G0 > max_modulus)
           max_modulus = G0;
       if (G1 > max_modulus)
           max_modulus = G1;
       if (G2 > max_modulus)
           max_modulus = G2;
       if (G3 > max_modulus)
           max_modulus = G3;
       if (scan_chain == "long")
       begin
          if (E0 > max_modulus)
              max_modulus = E0;
          if (E1 > max_modulus)
              max_modulus = E1;
          if (E2 > max_modulus)
              max_modulus = E2;
          if (E3 > max_modulus)
              max_modulus = E3;
       end

       slowest_clk = ((refclk/m_mod) * max_modulus *2);
    end
    endfunction

    // find the greatest common denominator of X and Y
    function integer gcd;
    input X,Y;
    integer X,Y;
    integer L, S, R, G;
    begin
        if (X < Y) // find which is smaller.
        begin
            S = X;
            L = Y;
        end
        else
        begin
            S = Y;
            L = X;
        end

        R = S;
        while ( R > 1)
        begin
            S = L;
            L = R;
            R = S % L; // divide bigger number by smaller.
                       // remainder becomes smaller number.
        end
        if (R == 0)    // if evenly divisible then L is gcd else it is 1.
            G = L;
        else
            G = R;
        gcd = G;
    end
    endfunction

    // find the least common multiple of A1 to A10
    function integer lcm;
    input A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, P;
    integer A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, P;
    integer M1, M2, M3, M4, M5 , M6, M7, M8, M9, R;
    begin
        M1 = (A1 * A2)/gcd(A1, A2);
        M2 = (M1 * A3)/gcd(M1, A3);
        M3 = (M2 * A4)/gcd(M2, A4);
        M4 = (M3 * A5)/gcd(M3, A5);
        M5 = (M4 * A6)/gcd(M4, A6);
        M6 = (M5 * A7)/gcd(M5, A7);
        M7 = (M6 * A8)/gcd(M6, A8);
        M8 = (M7 * A9)/gcd(M7, A9);
        M9 = (M8 * A10)/gcd(M8, A10);
        if (M9 < 3)
            R = 10;
        else if ((M9 < 10) && (M9 > 3))
            R = 4 * M9;
        else
            R = M9;
        lcm = R; 
    end
    endfunction

    // find the factor of division of the output clock frequency
    // compared to the VCO
    function integer output_counter_value;
    input clk_divide, clk_mult, M, N;
    integer clk_divide, clk_mult, M, N;
    integer R;
    begin
        R = (clk_divide * M)/(clk_mult * N);
        output_counter_value = R;
    end
    endfunction

    // find the mode of each of the PLL counters - bypass, even or odd
    function [8*6:1] counter_mode;
    input duty_cycle;
    input output_counter_value;
    integer duty_cycle;
    integer output_counter_value;
    integer half_cycle_high;
    reg [8*6:1] R;
    begin
        half_cycle_high = (2*duty_cycle*output_counter_value)/100;
        if (output_counter_value == 1)
            R = "bypass";
        else if ((half_cycle_high % 2) == 0)
            R = "even";
        else
            R = "odd";
        counter_mode = R;
    end
    endfunction

    // find the number of VCO clock cycles to hold the output clock high
    function integer counter_high;
    input output_counter_value, duty_cycle;
    integer output_counter_value, duty_cycle;
    integer half_cycle_high;
    integer tmp_counter_high;
    integer mode;
    begin
        half_cycle_high = (2*duty_cycle*output_counter_value)/100;
        mode = ((half_cycle_high % 2) == 0);
        tmp_counter_high = half_cycle_high/2;
        counter_high = tmp_counter_high + !mode;
    end
    endfunction

    // find the number of VCO clock cycles to hold the output clock low
    function integer counter_low;
    input output_counter_value, duty_cycle;
    integer output_counter_value, duty_cycle, counter_h;
    integer half_cycle_high;
    integer mode;
    integer tmp_counter_high;
    begin
        half_cycle_high = (2*duty_cycle*output_counter_value)/100;
        mode = ((half_cycle_high % 2) == 0);
        tmp_counter_high = half_cycle_high/2;
        counter_h = tmp_counter_high + !mode;
        counter_low =  output_counter_value - counter_h;
    end
    endfunction

    // find the smallest time delay amongst t1 to t10
    function integer mintimedelay;
    input t1, t2, t3, t4, t5, t6, t7, t8, t9, t10;
    integer t1, t2, t3, t4, t5, t6, t7, t8, t9, t10;
    integer m1,m2,m3,m4,m5,m6,m7,m8,m9;
    begin
        if (t1 < t2)
            m1 = t1;
        else
            m1 = t2;
        if (m1 < t3)
            m2 = m1;
        else
            m2 = t3;
        if (m2 < t4)
            m3 = m2;
        else
            m3 = t4;
        if (m3 < t5)
            m4 = m3;
        else
            m4 = t5;
        if (m4 < t6)
            m5 = m4;
        else
            m5 = t6;
        if (m5 < t7)
            m6 = m5;
        else
            m6 = t7;
        if (m6 < t8)
            m7 = m6;
        else
            m7 = t8;
        if (m7 < t9)
            m8 = m7;
        else
            m8 = t9;
        if (m8 < t10)
            m9 = m8;
        else
            m9 = t10;
        if (m9 > 0)
            mintimedelay = m9;
        else
            mintimedelay = 0;
    end
    endfunction

    // find the numerically largest negative number, and return its absolute value
    function integer maxnegabs;
    input t1, t2, t3, t4, t5, t6, t7, t8, t9, t10;
    integer t1, t2, t3, t4, t5, t6, t7, t8, t9, t10;
    integer m1,m2,m3,m4,m5,m6,m7,m8,m9;
    begin
        if (t1 < t2) m1 = t1; else m1 = t2;
        if (m1 < t3) m2 = m1; else m2 = t3;
        if (m2 < t4) m3 = m2; else m3 = t4;
        if (m3 < t5) m4 = m3; else m4 = t5;
        if (m4 < t6) m5 = m4; else m5 = t6;
        if (m5 < t7) m6 = m5; else m6 = t7;
        if (m6 < t8) m7 = m6; else m7 = t8;
        if (m7 < t9) m8 = m7; else m8 = t9;
        if (m8 < t10) m9 = m8; else m9 = t10;
        maxnegabs = (m9 < 0) ? 0 - m9 : 0;
    end
    endfunction

    // adjust the given tap_phase by adding the largest negative number (ph_base) 
    function integer ph_adjust;
    input tap_phase, ph_base;
    integer tap_phase, ph_base;
    begin
        ph_adjust = tap_phase + ph_base;
    end
    endfunction

    // find the actual time delay for each PLL counter
    function integer counter_time_delay;
    input clk_time_delay, m_time_delay, n_time_delay;
    integer clk_time_delay, m_time_delay, n_time_delay;
    begin
        counter_time_delay = clk_time_delay + m_time_delay - n_time_delay;
    end
    endfunction

    // find the number of VCO clock cycles to wait initially before the first 
    // rising edge of the output clock
    function integer counter_initial;
    input tap_phase, m, n;
    integer tap_phase, m, n, phase;
    begin
        if (tap_phase < 0) tap_phase = 0 - tap_phase;
        // adding 0.5 for rounding correction (required in order to round
        // to the nearest integer instead of truncating)
        phase = ((tap_phase * m) / (360 * n)) + 0.5;
        counter_initial = phase;
    end
    endfunction

    // find which VCO phase tap to align the rising edge of the output clock to
    function integer counter_ph;
    input tap_phase;
    input m,n;
    integer m,n, phase;
    integer tap_phase;
    begin
    // adding 0.5 for rounding correction
        phase = (tap_phase * m / n) + 0.5;
        counter_ph = (phase % 360)/45;
    end
    endfunction

    // convert the given string to length 6 by padding with spaces
    function [8*6:1] translate_string;
    input mode;
    reg [8*6:1] new_mode;
    begin
        if (mode == "bypass")
           new_mode = "bypass";
        else if (mode == "even")
            new_mode = "  even";
        else if (mode == "odd")
            new_mode = "   odd";

        translate_string = new_mode;
    end
    endfunction

    // convert string to integer with sign
    function integer str2int; 
    input [8*16:1] s;

    reg [8*16:1] reg_s;
    reg [8:1] digit;
    reg [8:1] tmp;
    integer m, magnitude;
    integer sign;

    begin
        sign = 1;
        magnitude = 0;
        reg_s = s;
        for (m=1; m<=16; m=m+1)
        begin
            tmp = reg_s[128:121];
            digit = tmp & 8'b00001111;
            reg_s = reg_s << 8;
            // Accumulate ascii digits 0-9 only.
            if ((tmp>=48) && (tmp<=57)) 
                magnitude = (magnitude * 10) + digit;
            if (tmp == 45)
                sign = -1;  // Found a '-' character, i.e. number is negative.
        end
        str2int = sign*magnitude;
    end
    endfunction

    // this is for stratix lvds only
    // convert phase delay to integer
    function integer get_int_phase_shift; 
    input [8*16:1] s;
    input i_phase_shift;
    integer i_phase_shift;

    begin
        if (i_phase_shift != 0)
        begin                   
            get_int_phase_shift = i_phase_shift;
        end       
        else
        begin
            get_int_phase_shift = str2int(s);
        end        
    end
    endfunction

    // calculate the given phase shift (in ps) in terms of degrees
    function integer get_phase_degree; 
    input phase_shift;
    integer phase_shift, result;
    begin
        result = (phase_shift * 360) / inclk0_input_frequency;
        // this is to round up the calculation result
        if ( result > 0 )
            result = result + 1;
        else if ( result < 0 )
            result = result - 1;
        else
            result = 0;

        // assign the rounded up result
        get_phase_degree = result;
    end
    endfunction

    // convert uppercase parameter values to lowercase
    // assumes that the maximum character length of a parameter is 18
    function [8*`ALTGXB_PLL_WORD_LENGTH:1] alpha_tolower;
    input [8*`ALTGXB_PLL_WORD_LENGTH:1] given_string;

    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] return_string;
    reg [8*`ALTGXB_PLL_WORD_LENGTH:1] reg_string;
    reg [8:1] tmp;
    reg [8:1] conv_char;
    integer byte_count;
    begin
        return_string = "                    "; // initialise strings to spaces
        conv_char = "        ";
        reg_string = given_string;
        for (byte_count = `ALTGXB_PLL_WORD_LENGTH; byte_count >= 1; byte_count = byte_count - 1)
        begin
            tmp = reg_string[8*`ALTGXB_PLL_WORD_LENGTH:(8*(`ALTGXB_PLL_WORD_LENGTH-1)+1)];
            reg_string = reg_string << 8;
            if ((tmp >= 65) && (tmp <= 90)) // ASCII number of 'A' is 65, 'Z' is 90
            begin
                conv_char = tmp + 32; // 32 is the difference in the position of 'A' and 'a' in the ASCII char set
                return_string = {return_string, conv_char};
            end
            else
                return_string = {return_string, tmp};
        end
    
        alpha_tolower = return_string;
    end
    endfunction

    initial
    begin

        // convert string parameter values from uppercase to lowercase,
        // as expected in this model
        l_operation_mode             = alpha_tolower(operation_mode);
        l_pll_type                   = alpha_tolower(pll_type);
        l_qualify_conf_done          = alpha_tolower(qualify_conf_done);
        l_compensate_clock           = alpha_tolower(compensate_clock);
        l_scan_chain                 = alpha_tolower(scan_chain);
        l_primary_clock              = alpha_tolower(primary_clock);
        l_gate_lock_signal           = alpha_tolower(gate_lock_signal);
        l_switch_over_on_lossclk     = alpha_tolower(switch_over_on_lossclk);
        l_switch_over_on_gated_lock  = alpha_tolower(switch_over_on_gated_lock);
        l_enable_switch_over_counter = alpha_tolower(enable_switch_over_counter);
        l_feedback_source            = alpha_tolower(feedback_source);
        l_bandwidth_type             = alpha_tolower(bandwidth_type);
        l_simulation_type            = alpha_tolower(simulation_type);
//        l_source_is_pll              = alpha_tolower(source_is_pll);
        l_enable0_counter            = alpha_tolower(enable0_counter);
        l_enable1_counter            = alpha_tolower(enable1_counter);

        if (m == 0)
        begin 
            // convert user parameters to advanced
            i_n = 1;
            i_m = lcm (clk0_multiply_by, clk1_multiply_by,
                       clk2_multiply_by, clk3_multiply_by,
                       clk4_multiply_by, clk5_multiply_by,
                       extclk0_multiply_by,
                       extclk1_multiply_by, extclk2_multiply_by,
                       extclk3_multiply_by, inclk0_input_frequency);
            i_m_time_delay = maxnegabs(str2int(clk0_time_delay),
                                     str2int(clk1_time_delay),
                                     str2int(clk2_time_delay),
                                     str2int(clk3_time_delay),
                                     str2int(clk4_time_delay),
                                     str2int(clk5_time_delay),
                                     str2int(extclk0_time_delay),
                                     str2int(extclk1_time_delay),
                                     str2int(extclk2_time_delay),
                                     str2int(extclk3_time_delay));
            i_n_time_delay = mintimedelay(str2int(clk0_time_delay),
                                     str2int(clk1_time_delay),
                                     str2int(clk2_time_delay),
                                     str2int(clk3_time_delay),
                                     str2int(clk4_time_delay),
                                     str2int(clk5_time_delay),
                                     str2int(extclk0_time_delay),
                                     str2int(extclk1_time_delay),
                                     str2int(extclk2_time_delay),
                                     str2int(extclk3_time_delay));
            i_g0_high = counter_high(output_counter_value(clk0_divide_by,
                        clk0_multiply_by, i_m, i_n), clk0_duty_cycle);
            i_g1_high = counter_high(output_counter_value(clk1_divide_by,
                        clk1_multiply_by, i_m, i_n), clk1_duty_cycle);
            i_g2_high = counter_high(output_counter_value(clk2_divide_by,
                        clk2_multiply_by, i_m, i_n), clk2_duty_cycle);
            i_g3_high = counter_high(output_counter_value(clk3_divide_by,
                        clk3_multiply_by, i_m, i_n), clk3_duty_cycle);
            i_l0_high = counter_high(output_counter_value(clk4_divide_by,
                        clk4_multiply_by,  i_m, i_n), clk4_duty_cycle);
            i_l1_high = counter_high(output_counter_value(clk5_divide_by,
                        clk5_multiply_by,  i_m, i_n), clk5_duty_cycle);
            i_e0_high = counter_high(output_counter_value(extclk0_divide_by,
                        extclk0_multiply_by,  i_m, i_n), extclk0_duty_cycle);
            i_e1_high = counter_high(output_counter_value(extclk1_divide_by,
                        extclk1_multiply_by,  i_m, i_n), extclk1_duty_cycle);
            i_e2_high = counter_high(output_counter_value(extclk2_divide_by,
                        extclk2_multiply_by,  i_m, i_n), extclk2_duty_cycle);
            i_e3_high = counter_high(output_counter_value(extclk3_divide_by,
                        extclk3_multiply_by,  i_m, i_n), extclk3_duty_cycle);
            i_g0_low  = counter_low(output_counter_value(clk0_divide_by,
                        clk0_multiply_by,  i_m, i_n), clk0_duty_cycle);
            i_g1_low  = counter_low(output_counter_value(clk1_divide_by,
                        clk1_multiply_by,  i_m, i_n), clk1_duty_cycle);
            i_g2_low  = counter_low(output_counter_value(clk2_divide_by,
                        clk2_multiply_by,  i_m, i_n), clk2_duty_cycle);
            i_g3_low  = counter_low(output_counter_value(clk3_divide_by,
                        clk3_multiply_by,  i_m, i_n), clk3_duty_cycle);
            i_l0_low  = counter_low(output_counter_value(clk4_divide_by,
                        clk4_multiply_by,  i_m, i_n), clk4_duty_cycle);
            i_l1_low  = counter_low(output_counter_value(clk5_divide_by,
                        clk5_multiply_by,  i_m, i_n), clk5_duty_cycle);
            i_e0_low  = counter_low(output_counter_value(extclk0_divide_by,
                        extclk0_multiply_by,  i_m, i_n), extclk0_duty_cycle);
            i_e1_low  = counter_low(output_counter_value(extclk1_divide_by,
                        extclk1_multiply_by,  i_m, i_n), extclk1_duty_cycle);
            i_e2_low  = counter_low(output_counter_value(extclk2_divide_by,
                        extclk2_multiply_by,  i_m, i_n), extclk2_duty_cycle);
            i_e3_low  = counter_low(output_counter_value(extclk3_divide_by,
                        extclk3_multiply_by,  i_m, i_n), extclk3_duty_cycle);
            max_neg_abs = maxnegabs( get_int_phase_shift(clk0_phase_shift, clk0_phase_shift_num),
                                     get_int_phase_shift(clk1_phase_shift, clk1_phase_shift_num),
                                     get_int_phase_shift(clk2_phase_shift, clk2_phase_shift_num),
                                     str2int(clk3_phase_shift),
                                     str2int(clk4_phase_shift),
                                     str2int(clk5_phase_shift),
                                     str2int(extclk0_phase_shift),
                                     str2int(extclk1_phase_shift),
                                     str2int(extclk2_phase_shift),
                                     str2int(extclk3_phase_shift));
            i_g0_initial = counter_initial(get_phase_degree(ph_adjust(get_int_phase_shift(clk0_phase_shift, clk0_phase_shift_num), max_neg_abs)), i_m, i_n);
            i_g1_initial = counter_initial(get_phase_degree(ph_adjust(get_int_phase_shift(clk1_phase_shift, clk1_phase_shift_num), max_neg_abs)), i_m, i_n);
            i_g2_initial = counter_initial(get_phase_degree(ph_adjust(get_int_phase_shift(clk2_phase_shift, clk2_phase_shift_num), max_neg_abs)), i_m, i_n);
            i_g3_initial = counter_initial(get_phase_degree(ph_adjust(str2int(clk3_phase_shift), max_neg_abs)), i_m, i_n);
            i_l0_initial = counter_initial(get_phase_degree(ph_adjust(str2int(clk4_phase_shift), max_neg_abs)), i_m, i_n);
            i_l1_initial = counter_initial(get_phase_degree(ph_adjust(str2int(clk5_phase_shift), max_neg_abs)), i_m, i_n);
            i_e0_initial = counter_initial(get_phase_degree(ph_adjust(str2int(extclk0_phase_shift), max_neg_abs)), i_m, i_n);
            i_e1_initial = counter_initial(get_phase_degree(ph_adjust(str2int(extclk1_phase_shift), max_neg_abs)), i_m, i_n);
            i_e2_initial = counter_initial(get_phase_degree(ph_adjust(str2int(extclk2_phase_shift), max_neg_abs)), i_m, i_n);
            i_e3_initial = counter_initial(get_phase_degree(ph_adjust(str2int(extclk3_phase_shift), max_neg_abs)), i_m, i_n);
            i_g0_mode = counter_mode(clk0_duty_cycle, output_counter_value(clk0_divide_by, clk0_multiply_by,  i_m, i_n));
            i_g1_mode = counter_mode(clk1_duty_cycle,output_counter_value(clk1_divide_by, clk1_multiply_by,  i_m, i_n));
            i_g2_mode = counter_mode(clk2_duty_cycle,output_counter_value(clk2_divide_by, clk2_multiply_by,  i_m, i_n));
            i_g3_mode = counter_mode(clk3_duty_cycle,output_counter_value(clk3_divide_by, clk3_multiply_by,  i_m, i_n));
            i_l0_mode = counter_mode(clk4_duty_cycle,output_counter_value(clk4_divide_by, clk4_multiply_by,  i_m, i_n));
            i_l1_mode = counter_mode(clk5_duty_cycle,output_counter_value(clk5_divide_by, clk5_multiply_by,  i_m, i_n));
            i_e0_mode = counter_mode(extclk0_duty_cycle,output_counter_value(extclk0_divide_by, extclk0_multiply_by,  i_m, i_n));
            i_e1_mode = counter_mode(extclk1_duty_cycle,output_counter_value(extclk1_divide_by, extclk1_multiply_by,  i_m, i_n));
            i_e2_mode = counter_mode(extclk2_duty_cycle,output_counter_value(extclk2_divide_by, extclk2_multiply_by,  i_m, i_n));
            i_e3_mode = counter_mode(extclk3_duty_cycle,output_counter_value(extclk3_divide_by, extclk3_multiply_by,  i_m, i_n));
            i_m_ph    = counter_ph(get_phase_degree(max_neg_abs), i_m, i_n);
            i_m_initial = counter_initial(get_phase_degree(max_neg_abs), i_m, i_n);
            i_g0_ph = counter_ph(get_phase_degree(ph_adjust(get_int_phase_shift(clk0_phase_shift, clk0_phase_shift_num),max_neg_abs)), i_m, i_n);
            i_g1_ph = counter_ph(get_phase_degree(ph_adjust(get_int_phase_shift(clk1_phase_shift, clk1_phase_shift_num),max_neg_abs)), i_m, i_n);
            i_g2_ph = counter_ph(get_phase_degree(ph_adjust(get_int_phase_shift(clk2_phase_shift, clk2_phase_shift_num),max_neg_abs)), i_m, i_n);
            i_g3_ph = counter_ph(get_phase_degree(ph_adjust(str2int(clk3_phase_shift),max_neg_abs)), i_m, i_n);
            i_l0_ph = counter_ph(get_phase_degree(ph_adjust(str2int(clk4_phase_shift),max_neg_abs)), i_m, i_n);
            i_l1_ph = counter_ph(get_phase_degree(ph_adjust(str2int(clk5_phase_shift),max_neg_abs)), i_m, i_n);
            i_e0_ph = counter_ph(get_phase_degree(ph_adjust(str2int(extclk0_phase_shift),max_neg_abs)), i_m, i_n);
            i_e1_ph = counter_ph(get_phase_degree(ph_adjust(str2int(extclk1_phase_shift),max_neg_abs)), i_m, i_n);
            i_e2_ph = counter_ph(get_phase_degree(ph_adjust(str2int(extclk2_phase_shift),max_neg_abs)), i_m, i_n);
            i_e3_ph = counter_ph(get_phase_degree(ph_adjust(str2int(extclk3_phase_shift),max_neg_abs)), i_m, i_n);

            i_g0_time_delay = counter_time_delay(str2int(clk0_time_delay),
                                                 i_m_time_delay,
                                                 i_n_time_delay);
            i_g1_time_delay = counter_time_delay(str2int(clk1_time_delay),
                                                 i_m_time_delay,
                                                 i_n_time_delay);
            i_g2_time_delay = counter_time_delay(str2int(clk2_time_delay),
                                                 i_m_time_delay,
                                                 i_n_time_delay);
            i_g3_time_delay = counter_time_delay(str2int(clk3_time_delay),
                                                 i_m_time_delay,
                                                 i_n_time_delay);
            i_l0_time_delay = counter_time_delay(str2int(clk4_time_delay),
                                                 i_m_time_delay,
                                                 i_n_time_delay);
            i_l1_time_delay = counter_time_delay(str2int(clk5_time_delay),
                                                 i_m_time_delay,
                                                 i_n_time_delay);
            i_e0_time_delay = counter_time_delay(str2int(extclk0_time_delay),
                                                 i_m_time_delay,
                                                 i_n_time_delay);
            i_e1_time_delay = counter_time_delay(str2int(extclk1_time_delay),
                                                 i_m_time_delay,
                                                 i_n_time_delay);
            i_e2_time_delay = counter_time_delay(str2int(extclk2_time_delay),
                                                 i_m_time_delay,
                                                 i_n_time_delay);
            i_e3_time_delay = counter_time_delay(str2int(extclk3_time_delay),
                                                 i_m_time_delay,
                                                 i_n_time_delay);
            i_extclk3_counter = "e3" ;
            i_extclk2_counter = "e2" ;
            i_extclk1_counter = "e1" ;
            i_extclk0_counter = "e0" ;
            i_clk5_counter    = "l1" ;
            i_clk4_counter    = "l0" ;
            i_clk3_counter    = "g3" ;
            i_clk2_counter    = "g2" ;
            i_clk1_counter    = "g1" ;
            i_clk0_counter    = "g0" ;

            // in external feedback mode, need to adjust M value to take
            // into consideration the external feedback counter value
            if (l_operation_mode == "external_feedback")
            begin
                // if there is a negative phase shift, m_initial can only be 1
                if (max_neg_abs > 0)
                    i_m_initial = 1;

                if (l_feedback_source == "extclk0")
                begin
                    if (i_e0_mode == "bypass")
                        output_count = 1;
                    else
                        output_count = i_e0_high + i_e0_low;
                end
                else if (l_feedback_source == "extclk1")
                begin
                    if (i_e1_mode == "bypass")
                        output_count = 1;
                    else
                        output_count = i_e1_high + i_e1_low;
                end
                else if (l_feedback_source == "extclk2")
                begin
                    if (i_e2_mode == "bypass")
                        output_count = 1;
                    else
                        output_count = i_e2_high + i_e2_low;
                end
                else if (l_feedback_source == "extclk3")
                begin
                    if (i_e3_mode == "bypass")
                        output_count = 1;
                    else
                        output_count = i_e3_high + i_e3_low;
                end
                else // default to e0
                begin
                    if (i_e0_mode == "bypass")
                        output_count = 1;
                    else
                        output_count = i_e0_high + i_e0_low;
                end

                i_m = i_m / output_count;
            end

        end
        else 
        begin //  m != 0

            i_n = n;
            i_m = m;
            i_l0_high = l0_high;
            i_l1_high = l1_high;
            i_g0_high = g0_high;
            i_g1_high = g1_high;
            i_g2_high = g2_high;
            i_g3_high = g3_high;
            i_e0_high = e0_high;
            i_e1_high = e1_high;
            i_e2_high = e2_high;
            i_e3_high = e3_high;
            i_l0_low  = l0_low;
            i_l1_low  = l1_low;
            i_g0_low  = g0_low;
            i_g1_low  = g1_low;
            i_g2_low  = g2_low;
            i_g3_low  = g3_low;
            i_e0_low  = e0_low;
            i_e1_low  = e1_low;
            i_e2_low  = e2_low;
            i_e3_low  = e3_low;
            i_l0_initial = l0_initial;
            i_l1_initial = l1_initial;
            i_g0_initial = g0_initial;
            i_g1_initial = g1_initial;
            i_g2_initial = g2_initial;
            i_g3_initial = g3_initial;
            i_e0_initial = e0_initial;
            i_e1_initial = e1_initial;
            i_e2_initial = e2_initial;
            i_e3_initial = e3_initial;
            i_l0_mode = alpha_tolower(l0_mode);
            i_l1_mode = alpha_tolower(l1_mode);
            i_g0_mode = alpha_tolower(g0_mode);
            i_g1_mode = alpha_tolower(g1_mode);
            i_g2_mode = alpha_tolower(g2_mode);
            i_g3_mode = alpha_tolower(g3_mode);
            i_e0_mode = alpha_tolower(e0_mode);
            i_e1_mode = alpha_tolower(e1_mode);
            i_e2_mode = alpha_tolower(e2_mode);
            i_e3_mode = alpha_tolower(e3_mode);
            i_l0_ph  = l0_ph;
            i_l1_ph  = l1_ph;
            i_g0_ph  = g0_ph;
            i_g1_ph  = g1_ph;
            i_g2_ph  = g2_ph;
            i_g3_ph  = g3_ph;
            i_e0_ph  = e0_ph;
            i_e1_ph  = e1_ph;
            i_e2_ph  = e2_ph;
            i_e3_ph  = e3_ph;
            i_m_ph   = m_ph;        // default
            i_m_initial = m_initial;
            i_l0_time_delay = l0_time_delay;
            i_l1_time_delay = l1_time_delay;
            i_g0_time_delay = g0_time_delay;
            i_g1_time_delay = g1_time_delay;
            i_g2_time_delay = g2_time_delay;
            i_g3_time_delay = g3_time_delay;
            i_e0_time_delay = e0_time_delay;
            i_e1_time_delay = e1_time_delay;
            i_e2_time_delay = e2_time_delay;
            i_e3_time_delay = e3_time_delay;
            i_m_time_delay  = m_time_delay;
            i_n_time_delay  = n_time_delay;
            i_extclk3_counter = alpha_tolower(extclk3_counter);
            i_extclk2_counter = alpha_tolower(extclk2_counter);
            i_extclk1_counter = alpha_tolower(extclk1_counter);
            i_extclk0_counter = alpha_tolower(extclk0_counter);
            i_clk5_counter    = alpha_tolower(clk5_counter);
            i_clk4_counter    = alpha_tolower(clk4_counter);
            i_clk3_counter    = alpha_tolower(clk3_counter);
            i_clk2_counter    = alpha_tolower(clk2_counter);
            i_clk1_counter    = alpha_tolower(clk1_counter);
            i_clk0_counter    = alpha_tolower(clk0_counter);

        end // user to advanced conversion

        // set the scan_chain length
        if (l_scan_chain == "long")
            scan_chain_length = EGPP_SCAN_CHAIN;
        else if (l_scan_chain == "short")
            scan_chain_length = GPP_SCAN_CHAIN;

        if (l_primary_clock == "inclk0")
        begin
            refclk_period = inclk0_input_frequency * n;
            primary_clock_frequency = inclk0_input_frequency;
        end
        else if (l_primary_clock == "inclk1")
        begin
            refclk_period = inclk1_input_frequency * n;
            primary_clock_frequency = inclk1_input_frequency;
        end

        m_times_vco_period = refclk_period;
        new_m_times_vco_period = refclk_period;

        fbclk_period = 0;
        high_time = 0;
        low_time = 0;
        schedule_vco = 0;
        schedule_offset = 1;
        vco_out[7:0] = 8'b0;
        fbclk_last_value = 0;
        offset = 0;
        temp_offset = 0;
        got_first_refclk = 0;
        got_first_fbclk = 0;
        fbclk_time = 0;
        first_fbclk_time = 0;
        refclk_time = 0;
        first_schedule = 1;
        sched_time = 0;
        vco_val = 0;
        l0_got_first_rising_edge = 0;
        l1_got_first_rising_edge = 0;
        vco_l0_last_value = 0;
        l0_count = 1;
        l1_count = 1;
        l0_tmp = 0;
        l1_tmp = 0;
        gate_count = 0;
        gate_out = 0;
        initial_delay = 0;
        fbk_phase = 0;
        for (i = 0; i <= 7; i = i + 1)
        begin
           phase_shift[i] = 0;
           last_phase_shift[i] = 0;
        end
        fbk_delay = 0;
        inclk_n = 0;
        cycle_to_adjust = 0;
        m_delay = 0;
        vco_l0 = 0;
        vco_l1 = 0;
        total_pull_back = 0;
        pull_back_M = 0;
        pull_back_ext_cntr = 0;
        vco_period_was_phase_adjusted = 0;
        phase_adjust_was_scheduled = 0;
        ena_ipd_last_value = 0;
        inclk_out_of_range = 0;
        scandataout_tmp = 0;
        schedule_vco_last_value = 0;

        // set initial values for counter parameters
        m_initial_val = i_m_initial;
        m_val = i_m;
        m_time_delay_val = i_m_time_delay;
        n_val = i_n;
        n_time_delay_val = i_n_time_delay;
        m_ph_val = i_m_ph;

        m2_val = m2;
        n2_val = n2;

        if (m_val == 1)
            m_mode_val = "bypass";
        if (m2_val == 1)
            m2_mode_val = "bypass";
        if (n_val == 1)
            n_mode_val = "bypass";
        if (n2_val == 1)
            n2_mode_val = "bypass";

        if (skip_vco == "on")
        begin
            m_val = 1;
            m_initial_val = 1;
            m_time_delay_val = 0;
            m_ph_val = 0;
        end

        l0_high_val = i_l0_high;
        l0_low_val = i_l0_low;
        l0_initial_val = i_l0_initial;
        l0_mode_val = i_l0_mode;
        l0_time_delay_val = i_l0_time_delay;

        l1_high_val = i_l1_high;
        l1_low_val = i_l1_low;
        l1_initial_val = i_l1_initial;
        l1_mode_val = i_l1_mode;
        l1_time_delay_val = i_l1_time_delay;

        g0_high_val = i_g0_high;
        g0_low_val = i_g0_low;
        g0_initial_val = i_g0_initial;
        g0_mode_val = i_g0_mode;
        g0_time_delay_val = i_g0_time_delay;

        g1_high_val = i_g1_high;
        g1_low_val = i_g1_low;
        g1_initial_val = i_g1_initial;
        g1_mode_val = i_g1_mode;
        g1_time_delay_val = i_g1_time_delay;

        g2_high_val = i_g2_high;
        g2_low_val = i_g2_low;
        g2_initial_val = i_g2_initial;
        g2_mode_val = i_g2_mode;
        g2_time_delay_val = i_g2_time_delay;

        g3_high_val = i_g3_high;
        g3_low_val = i_g3_low;
        g3_initial_val = i_g3_initial;
        g3_mode_val = i_g3_mode;
        g3_time_delay_val = i_g3_time_delay;

        e0_high_val = i_e0_high;
        e0_low_val = i_e0_low;
        e0_initial_val = i_e0_initial;
        e0_mode_val = i_e0_mode;
        e0_time_delay_val = i_e0_time_delay;

        e1_high_val = i_e1_high;
        e1_low_val = i_e1_low;
        e1_initial_val = i_e1_initial;
        e1_mode_val = i_e1_mode;
        e1_time_delay_val = i_e1_time_delay;

        e2_high_val = i_e2_high;
        e2_low_val = i_e2_low;
        e2_initial_val = i_e2_initial;
        e2_mode_val = i_e2_mode;
        e2_time_delay_val = i_e2_time_delay;

        e3_high_val = i_e3_high;
        e3_low_val = i_e3_low;
        e3_initial_val = i_e3_initial;
        e3_mode_val = i_e3_mode;
        e3_time_delay_val = i_e3_time_delay;

        i = 0;
        j = 0;
        inclk_last_value = 0;

        ext_fbk_cntr_ph = 0;
        ext_fbk_cntr_initial = 1;

        // initialize clkswitch variables

        clk0_is_bad = 0;
        clk1_is_bad = 0;
        inclk0_last_value = 0;
        inclk1_last_value = 0;
        other_clock_value = 0;
        other_clock_last_value = 0;
        primary_clk_is_bad = 0;
        current_clk_is_bad = 0;
        external_switch = 0;
        current_clock = l_primary_clock;
        if (l_primary_clock == "inclk0")
           active_clock = 0;
        else
           active_clock = 1;
        clkloss_tmp = 0;
        got_curr_clk_falling_edge_after_clkswitch = 0;
        clk0_count = 0;
        clk1_count = 0;
        switch_over_count = 0;
        active_clk_was_switched = 0;

        // initialize quiet_time
        quiet_time = slowest_clk(l0_high_val+l0_low_val,
                                 l1_high_val+l1_low_val,
                                 g0_high_val+g0_low_val,
                                 g1_high_val+g1_low_val,
                                 g2_high_val+g2_low_val,
                                 g3_high_val+g3_low_val,
                                 e0_high_val+e0_low_val,
                                 e1_high_val+e1_low_val,
                                 e2_high_val+e2_low_val,
                                 e3_high_val+e3_low_val,
                                 l_scan_chain,
                                 refclk_period, m_val);
        pll_in_quiet_period = 0;
        start_quiet_time = 0; 
        quiet_period_violation = 0;
        reconfig_err = 0;
        scanclr_violation = 0;
        scanclr_clk_violation = 0;
        got_first_scanclk_after_scanclr_inactive_edge = 0;
        error = 0;
        scanaclr_rising_time = 0;
        scanaclr_falling_time = 0;

        // VCO feedback loop settings for external feedback mode
        // first find which ext counter is used for feedback

        if (l_operation_mode == "external_feedback")
        begin
           if (l_feedback_source == "extclk0")
           begin
              if (i_extclk0_counter == "e0")
                  ext_fbk_cntr = "e0";
              else if (i_extclk0_counter == "e1")
                  ext_fbk_cntr = "e1";
              else if (i_extclk0_counter == "e2")
                  ext_fbk_cntr = "e2";
              else if (i_extclk0_counter == "e3")
                  ext_fbk_cntr = "e3";
              else ext_fbk_cntr = "e0";
           end
           else if (l_feedback_source == "extclk1")
           begin
              if (i_extclk1_counter == "e0")
                  ext_fbk_cntr = "e0";
              else if (i_extclk1_counter == "e1")
                  ext_fbk_cntr = "e1";
              else if (i_extclk1_counter == "e2")
                  ext_fbk_cntr = "e2";
              else if (i_extclk1_counter == "e3")
                  ext_fbk_cntr = "e3";
              else ext_fbk_cntr = "e0";
           end
           else if (l_feedback_source == "extclk2")
           begin
              if (i_extclk2_counter == "e0")
                  ext_fbk_cntr = "e0";
              else if (i_extclk2_counter == "e1")
                  ext_fbk_cntr = "e1";
              else if (i_extclk2_counter == "e2")
                  ext_fbk_cntr = "e2";
              else if (i_extclk2_counter == "e3")
                  ext_fbk_cntr = "e3";
              else ext_fbk_cntr = "e0";
           end
           else if (l_feedback_source == "extclk3")
           begin
              if (i_extclk3_counter == "e0")
                  ext_fbk_cntr = "e0";
              else if (i_extclk3_counter == "e1")
                  ext_fbk_cntr = "e1";
              else if (i_extclk3_counter == "e2")
                  ext_fbk_cntr = "e2";
              else if (i_extclk3_counter == "e3")
                  ext_fbk_cntr = "e3";
              else ext_fbk_cntr = "e0";
           end

           // now save this counter's parameters
           if (ext_fbk_cntr == "e0")
              ext_fbk_cntr_high = e0_high_val;
           else if (ext_fbk_cntr == "e1")
              ext_fbk_cntr_high = e1_high_val;
           else if (ext_fbk_cntr == "e2")
              ext_fbk_cntr_high = e2_high_val;
           else if (ext_fbk_cntr == "e3")
              ext_fbk_cntr_high = e3_high_val;

           if (ext_fbk_cntr == "e0")
              ext_fbk_cntr_low = e0_low_val;
           else if (ext_fbk_cntr == "e1")
              ext_fbk_cntr_low = e1_low_val;
           else if (ext_fbk_cntr == "e2")
              ext_fbk_cntr_low = e2_low_val;
           else if (ext_fbk_cntr == "e3")
              ext_fbk_cntr_low = e3_low_val;

           if (ext_fbk_cntr == "e0")
              ext_fbk_cntr_ph = i_e0_ph;
           else if (ext_fbk_cntr == "e1")
              ext_fbk_cntr_ph = i_e1_ph;
           else if (ext_fbk_cntr == "e2")
              ext_fbk_cntr_ph = i_e2_ph;
           else if (ext_fbk_cntr == "e3")
              ext_fbk_cntr_ph = i_e3_ph;

           if (ext_fbk_cntr == "e0")
              ext_fbk_cntr_initial = i_e0_initial;
           else if (ext_fbk_cntr == "e1")
              ext_fbk_cntr_initial = i_e1_initial;
           else if (ext_fbk_cntr == "e2")
              ext_fbk_cntr_initial = i_e2_initial;
           else if (ext_fbk_cntr == "e3")
              ext_fbk_cntr_initial = i_e3_initial;

           if (ext_fbk_cntr == "e0")
              ext_fbk_cntr_delay = e0_time_delay_val;
           else if (ext_fbk_cntr == "e1")
              ext_fbk_cntr_delay = e1_time_delay_val;
           else if (ext_fbk_cntr == "e2")
              ext_fbk_cntr_delay = e2_time_delay_val;
           else if (ext_fbk_cntr == "e3")
              ext_fbk_cntr_delay = e3_time_delay_val;
        end

        l_index = 1;
        stop_vco = 0;
        cycles_to_lock = 0;
        cycles_to_unlock = 0;
        if (l_pll_type == "fast")
           locked_tmp = 1;
        else
           locked_tmp = 0;
        pll_is_locked = 0;
        pll_about_to_lock = 0;

        no_warn = 0;
    end

    assign inclk_m = l_operation_mode == "external_feedback" ? (l_feedback_source == "extclk0" ? extclk0_tmp :
                     l_feedback_source == "extclk1" ? extclk1_tmp :
                     l_feedback_source == "extclk2" ? extclk2_tmp :
                     l_feedback_source == "extclk3" ? extclk3_tmp : 'b0) :
                     vco_out[m_ph_val];

    altgxb_m_cntr m1 (.clk(inclk_m),
                .reset(areset_ipd || (!ena_ipd) || stop_vco),
                .cout(fbclk),
                .initial_value(m_initial_val),
                .modulus(m_val),
                .time_delay(m_delay));

    always @(clkswitch_ipd)
    begin
       if (clkswitch_ipd == 1'b1)
          external_switch = 1;
    end

    always @(inclk0_ipd or inclk1_ipd)
    begin
        // save the inclk event value
        if (inclk0_ipd !== inclk0_last_value)
        begin
            if (current_clock !== "inclk0")
                other_clock_value = inclk0_ipd;
        end
        if (inclk1_ipd !== inclk1_last_value)
        begin
            if (current_clock !== "inclk1")
                other_clock_value = inclk1_ipd;
        end

        // check if either input clk is bad
        if (inclk0_ipd === 1'b1 && inclk0_ipd !== inclk0_last_value)
        begin
            clk0_count = clk0_count + 1;
            clk0_is_bad = 0;
            clk1_count = 0;
            if (clk0_count > 2)
            begin
               // no event on other clk for 2 cycles
               clk1_is_bad = 1;
               if (current_clock == "inclk1")
                  current_clk_is_bad = 1;
            end
        end
        if (inclk1_ipd === 1'b1 && inclk1_ipd !== inclk1_last_value)
        begin
            clk1_count = clk1_count + 1;
            clk1_is_bad = 0;
            clk0_count = 0;
            if (clk1_count > 2)
            begin
               // no event on other clk for 2 cycles
               clk0_is_bad = 1;
               if (current_clock == "inclk0")
                  current_clk_is_bad = 1;
            end
        end

        // check if the bad clk is the primary clock
        if (((l_primary_clock == "inclk0") && (clk0_is_bad == 1'b1)) || ((l_primary_clock == "inclk1") && (clk1_is_bad == 1'b1)))
           primary_clk_is_bad = 1;
        else
           primary_clk_is_bad = 0;

        // actual switching
        if ((inclk0_ipd !== inclk0_last_value) && current_clock == "inclk0")
        begin
           if (external_switch == 1'b1)
           begin
              if (!got_curr_clk_falling_edge_after_clkswitch)
              begin
                 if (inclk0_ipd === 1'b0)
                    got_curr_clk_falling_edge_after_clkswitch = 1;
                 inclk_n = inclk0_ipd;
              end
           end
           else inclk_n = inclk0_ipd;
        end
        if ((inclk1_ipd !== inclk1_last_value) && current_clock == "inclk1")
        begin
           if (external_switch == 1'b1)
           begin
              if (!got_curr_clk_falling_edge_after_clkswitch)
              begin
                 if (inclk1_ipd === 1'b0)
                    got_curr_clk_falling_edge_after_clkswitch = 1;
                 inclk_n = inclk1_ipd;
              end
           end
           else inclk_n = inclk1_ipd;
        end
        if ((other_clock_value == 1'b1) && (other_clock_value != other_clock_last_value) && (l_switch_over_on_lossclk == "on") && l_enable_switch_over_counter == "on" && primary_clk_is_bad)
            switch_over_count = switch_over_count + 1;
        if ((other_clock_value == 1'b0) && (other_clock_value != other_clock_last_value))
        begin
            if ((external_switch && (got_curr_clk_falling_edge_after_clkswitch || current_clk_is_bad)) || (l_switch_over_on_lossclk == "on" && primary_clk_is_bad && ((l_enable_switch_over_counter == "off" || switch_over_count == switch_over_counter))))
            begin
                got_curr_clk_falling_edge_after_clkswitch = 0;
                if (current_clock == "inclk0")
                   current_clock = "inclk1";
                else
                   current_clock = "inclk0";
                active_clock = ~active_clock;
                active_clk_was_switched = 1;
                switch_over_count = 0;
                external_switch = 0;
                current_clk_is_bad = 0;
            end
        end

        if (l_switch_over_on_lossclk == "on" && (clkswitch_ipd != 1'b1))
        begin
           if (primary_clk_is_bad)
              clkloss_tmp = 1;
           else
              clkloss_tmp = 0;
        end
        else clkloss_tmp = clkswitch_ipd;

        inclk0_last_value = inclk0_ipd;
        inclk1_last_value = inclk1_ipd;
        other_clock_last_value = other_clock_value;

    end

    and (clkbad[0], clk0_is_bad, 1'b1);
    and (clkbad[1], clk1_is_bad, 1'b1);
    and (activeclock, active_clock, 1'b1);
    and (clkloss, clkloss_tmp, 1'b1);

    altgxb_n_cntr n1 (.clk(inclk_n),
               .reset(areset_ipd),
               .cout(refclk),
               .modulus(n_val),
               .time_delay(n_time_delay_val)
              );

    altgxb_scale_cntr l0 (.clk(vco_out[i_l0_ph]),
                   .reset(areset_ipd || (!ena_ipd) || stop_vco),
                   .cout(l0_clk),
                   .high(l0_high_val),
                   .low(l0_low_val),
                   .initial_value(l0_initial_val),
                   .mode(l0_mode_val),
                   .time_delay(l0_time_delay_val),
                   .ph_tap(i_l0_ph)
                  );

    altgxb_scale_cntr l1 (.clk(vco_out[i_l1_ph]),
                   .reset(areset_ipd || (!ena_ipd) || stop_vco),
                   .cout(l1_clk),
                   .high(l1_high_val),
                   .low(l1_low_val),
                   .initial_value(l1_initial_val),
                   .mode(l1_mode_val),
                   .time_delay(l1_time_delay_val),
                   .ph_tap(i_l1_ph)
                  );

    altgxb_scale_cntr g0 (.clk(vco_out[i_g0_ph]),
                   .reset(areset_ipd || (!ena_ipd) || stop_vco),
                   .cout(g0_clk),
                   .high(g0_high_val),
                   .low(g0_low_val),
                   .initial_value(g0_initial_val),
                   .mode(g0_mode_val),
                   .time_delay(g0_time_delay_val),
                   .ph_tap(i_g0_ph)
                  );

    altgxb_pll_reg lvds_dffa (.d(comparator_ipd),
                       .clrn(1'b1),
                       .prn(1'b1),
                       .ena(1'b1),
                       .clk(g0_clk),
                       .q(dffa_out)
                      );

    altgxb_pll_reg lvds_dffb (.d(dffa_out),
                       .clrn(1'b1),
                       .prn(1'b1),
                       .ena(1'b1),
                       .clk(lvds_dffb_clk),
                       .q(dffb_out)
                      );

    assign lvds_dffb_clk = (l_enable0_counter == "l0") ? l0_clk : (l_enable0_counter == "l1") ? l1_clk : 1'b0;

    altgxb_pll_reg lvds_dffc (.d(dffb_out),
                       .clrn(1'b1),
                       .prn(1'b1),
                       .ena(1'b1),
                       .clk(lvds_dffc_clk),
                       .q(dffc_out)
                      );

    assign lvds_dffc_clk = (l_enable0_counter == "l0") ? l0_clk : (l_enable0_counter == "l1") ? l1_clk : 1'b0;

    assign nce_temp = ~dffc_out && dffb_out;

    altgxb_pll_reg lvds_dffd (.d(nce_temp),
                       .clrn(1'b1),
                       .prn(1'b1),
                       .ena(1'b1),
                       .clk(~lvds_dffd_clk),
                       .q(dffd_out)
                      );

    assign lvds_dffd_clk = (l_enable0_counter == "l0") ? l0_clk : (l_enable0_counter == "l1") ? l1_clk : 1'b0;

    assign nce_l0 = (l_enable0_counter == "l0") ? dffd_out : 'b0;
    assign nce_l1 = (l_enable0_counter == "l1") ? dffd_out : 'b0;

    altgxb_scale_cntr g1 (.clk(vco_out[i_g1_ph]),
                   .reset(areset_ipd || (!ena_ipd) || stop_vco),
                   .cout(g1_clk),
                   .high(g1_high_val),
                   .low(g1_low_val),
                   .initial_value(g1_initial_val),
                   .mode(g1_mode_val),
                   .time_delay(g1_time_delay_val),
                   .ph_tap(i_g1_ph)
                  );

    altgxb_scale_cntr g2 (.clk(vco_out[i_g2_ph]),
                   .reset(areset_ipd || (!ena_ipd) || stop_vco),
                   .cout(g2_clk),
                   .high(g2_high_val),
                   .low(g2_low_val),
                   .initial_value(g2_initial_val),
                   .mode(g2_mode_val),
                   .time_delay(g2_time_delay_val),
                   .ph_tap(i_g2_ph)
                  );

    altgxb_scale_cntr g3 (.clk(vco_out[i_g3_ph]),
                   .reset(areset_ipd || (!ena_ipd) || stop_vco),
                   .cout(g3_clk),
                   .high(g3_high_val),
                   .low(g3_low_val),
                   .initial_value(g3_initial_val),
                   .mode(g3_mode_val),
                   .time_delay(g3_time_delay_val),
                   .ph_tap(i_g3_ph)
                  );
    assign cntr_e0_initial = (l_operation_mode == "external_feedback" && ext_fbk_cntr == "e0") ? 1 : e0_initial_val;
    assign cntr_e0_delay = (l_operation_mode == "external_feedback" && ext_fbk_cntr == "e0") ? ext_fbk_delay : e0_time_delay_val;

    altgxb_scale_cntr e0 (.clk(vco_out[i_e0_ph]),
                   .reset(areset_ipd || (!ena_ipd) || stop_vco),
                   .cout(e0_clk),
                   .high(e0_high_val),
                   .low(e0_low_val),
                   .initial_value(cntr_e0_initial),
                   .mode(e0_mode_val),
                   .time_delay(cntr_e0_delay),
                   .ph_tap(i_e0_ph)
                  );

    assign cntr_e1_initial = (l_operation_mode == "external_feedback" && ext_fbk_cntr == "e1") ? 1 : e1_initial_val;
    assign cntr_e1_delay = (l_operation_mode == "external_feedback" && ext_fbk_cntr == "e1") ? ext_fbk_delay : e1_time_delay_val;
    altgxb_scale_cntr e1 (.clk(vco_out[i_e1_ph]),
                   .reset(areset_ipd || (!ena_ipd) || stop_vco),
                   .cout(e1_clk),
                   .high(e1_high_val),
                   .low(e1_low_val),
                   .initial_value(cntr_e1_initial),
                   .mode(e1_mode_val),
                   .time_delay(cntr_e1_delay),
                   .ph_tap(i_e1_ph)
                  );

    assign cntr_e2_initial = (l_operation_mode == "external_feedback" && ext_fbk_cntr == "e2") ? 1 : e2_initial_val;
    assign cntr_e2_delay = (l_operation_mode == "external_feedback" && ext_fbk_cntr == "e2") ? ext_fbk_delay : e2_time_delay_val;
    altgxb_scale_cntr e2 (.clk(vco_out[i_e2_ph]),
                   .reset(areset_ipd || (!ena_ipd) || stop_vco),
                   .cout(e2_clk),
                   .high(e2_high_val),
                   .low(e2_low_val),
                   .initial_value(cntr_e2_initial),
                   .mode(e2_mode_val),
                   .time_delay(cntr_e2_delay),
                   .ph_tap(i_e2_ph)
                  );

    assign cntr_e3_initial = (l_operation_mode == "external_feedback" && ext_fbk_cntr == "e3") ? 1 : e3_initial_val;
    assign cntr_e3_delay = (l_operation_mode == "external_feedback" && ext_fbk_cntr == "e3") ? ext_fbk_delay : e3_time_delay_val;
    altgxb_scale_cntr e3 (.clk(vco_out[i_e3_ph]),
                   .reset(areset_ipd || (!ena_ipd) || stop_vco),
                   .cout(e3_clk),
                   .high(e3_high_val),
                   .low(e3_low_val),
                   .initial_value(cntr_e3_initial),
                   .mode(e3_mode_val),
                   .time_delay(cntr_e3_delay),
                   .ph_tap(i_e3_ph)
                  );


    always @(vco_out[i_l0_ph] or posedge areset_ipd or negedge ena_ipd or stop_vco)
    begin
        if (areset_ipd == 1'b1 || ena_ipd == 1'b0 || stop_vco == 1'b1)
        begin
            l0_count = 1;
            l0_got_first_rising_edge = 0;
        end
        else begin
            if (nce_l0 == 1'b0)
            begin
                if (l0_got_first_rising_edge == 1'b0)
                begin
                    if (vco_out[i_l0_ph] == 1'b1 && vco_out[i_l0_ph] != vco_l0_last_value)
                        l0_got_first_rising_edge = 1;
                end
                else if (vco_out[i_l0_ph] != vco_l0_last_value)
                begin
                    l0_count = l0_count + 1;
                    if (l0_count == (l0_high_val + l0_low_val) * 2)
                        l0_count  = 1;
                end
            end
            if (vco_out[i_l0_ph] == 1'b0 && vco_out[i_l0_ph] != vco_l0_last_value)
            begin
                if (l0_count == 1)
                begin
                    l0_tmp = 1;
                    l0_got_first_rising_edge = 0;
                end
                else l0_tmp = 0;
            end
        end
        vco_l0_last_value = vco_out[i_l0_ph];
    end

    always @(vco_out[i_l1_ph] or posedge areset_ipd or negedge ena_ipd or stop_vco)
    begin
        if (areset_ipd == 1'b1 || ena_ipd == 1'b0 || stop_vco == 1'b1)
        begin
            l1_count = 1;
            l1_got_first_rising_edge = 0;
        end
        else begin
            if (nce_l1 == 1'b0)
            begin
                if (l1_got_first_rising_edge == 1'b0)
                begin
                    if (vco_out[i_l1_ph] == 1'b1 && vco_out[i_l1_ph] != vco_l1_last_value)
                        l1_got_first_rising_edge = 1;
                end
                else if (vco_out[i_l1_ph] != vco_l1_last_value)
                begin
                    l1_count = l1_count + 1;
                    if (l1_count == (l1_high_val + l1_low_val) * 2)
                        l1_count  = 1;
                end
            end
            if (vco_out[i_l1_ph] == 1'b0 && vco_out[i_l1_ph] != vco_l1_last_value)
            begin
                if (l1_count == 1)
                begin
                    l1_tmp = 1;
                    l1_got_first_rising_edge = 0;
                end
                else l1_tmp = 0;
            end
        end
        vco_l1_last_value = vco_out[i_l1_ph];
    end

    assign enable0_tmp = (l_enable0_counter == "l0") ? l0_tmp : l1_tmp;
    assign enable1_tmp = (l_enable1_counter == "l0") ? l0_tmp : l1_tmp;

    always @ (inclk_n or ena_ipd or areset_ipd)
    begin
       if (areset_ipd == 'b1)
       begin
           gate_count = 0;
           gate_out = 0; 
       end
       else if (inclk_n == 'b1 && inclk_last_value != inclk_n)
           if (ena_ipd == 'b1)
           begin
               gate_count = gate_count + 1;
               if (gate_count == gate_lock_counter)
                   gate_out = 1;
           end
       inclk_last_value = inclk_n;
    end

    assign locked = (l_gate_lock_signal == "yes") ? gate_out && locked_tmp : locked_tmp;

    always @ (scanclk_ipd or scanaclr_ipd)
    begin
        if (scanaclr_ipd === 1'b1 && scanaclr_last_value === 1'b0)
            scanaclr_rising_time = $time;
        else if (scanaclr_ipd === 1'b0 && scanaclr_last_value === 1'b1)
        begin
            scanaclr_falling_time = $time;
            // check for scanaclr active pulse width
            if ($time - scanaclr_rising_time < TRST)
            begin
                scanclr_violation = 1;
                $display ("Warning : Detected SCANACLR ACTIVE pulse width violation. Required is 5000 ps, actual is %0t. Reconfiguration may not work.", $time - scanaclr_rising_time);
                $display ("Time: %0t  Instance: %m", $time);
            end
            else begin
                scanclr_violation = 0;
                for (i = 0; i <= scan_chain_length; i = i + 1)
                   scan_data[i] = 0;
            end
            got_first_scanclk_after_scanclr_inactive_edge = 0;
        end
        else if ((scanclk_ipd === 'b1 && scanclk_last_value !== scanclk_ipd) && (got_first_scanclk_after_scanclr_inactive_edge === 1'b0) && ($time - scanaclr_falling_time < TRSTCLK))
        begin
            scanclr_clk_violation = 1;
            $display ("Warning : Detected SCANACLR INACTIVE time violation before rising edge of SCANCLK. Required is 5000 ps, actual is %0t. Reconfiguration may not work.", $time - scanaclr_falling_time);
            $display ("Time: %0t  Instance: %m", $time);
            got_first_scanclk_after_scanclr_inactive_edge = 1;
        end
        else if (scanclk_ipd == 'b1 && scanclk_last_value != scanclk_ipd && scanaclr_ipd === 1'b0)
        begin
            if (pll_in_quiet_period && ($time - start_quiet_time < quiet_time))
            begin
                $display("Time: %0t", $time, "   Warning : Detected transition on SCANCLK during quiet time. PLL may not function correctly."); 
                quiet_period_violation = 1;
            end
            else begin
                pll_in_quiet_period = 0;
                for (j = scan_chain_length-1; j >= 1; j = j - 1)
                begin
                    scan_data[j] = scan_data[j - 1];
                end
                scan_data[0] = scandata_ipd;
            end
            if (got_first_scanclk_after_scanclr_inactive_edge === 1'b0)
            begin
                got_first_scanclk_after_scanclr_inactive_edge = 1;
                scanclr_clk_violation = 0;
            end
        end
        else if (scanclk_ipd === 1'b0 && scanclk_last_value !== scanclk_ipd && scanaclr_ipd === 1'b0)
        begin
            if (pll_in_quiet_period && ($time - start_quiet_time < quiet_time))
            begin
                $display("Time: %0t", $time, "   Warning : Detected transition on SCANCLK during quiet time. PLL may not function correctly."); 
                quiet_period_violation = 1;
            end
            else if (scan_data[scan_chain_length-1] == 1'b1)
            begin
                pll_in_quiet_period = 1;
                quiet_period_violation = 0;
                reconfig_err = 0;
                start_quiet_time = $time;
                // initiate transfer
                scandataout_tmp <= 1'b1;
                quiet_time = slowest_clk(l0_high_val+l0_low_val,
                                         l1_high_val+l1_low_val,
                                         g0_high_val+g0_low_val,
                                         g1_high_val+g1_low_val,
                                         g2_high_val+g2_low_val,
                                         g3_high_val+g3_low_val,
                                         e0_high_val+e0_low_val,
                                         e1_high_val+e1_low_val,
                                         e2_high_val+e2_low_val,
                                         e3_high_val+e3_low_val,
                                         l_scan_chain,
                                         refclk_period, m_val);
                transfer = 1;
            end
        end
        scanclk_last_value = scanclk_ipd;
        scanaclr_last_value = scanaclr_ipd;
    end

    always @(scandataout_tmp)
    begin
        if (scandataout_tmp == 1'b1)
            scandataout_tmp <= #(quiet_time) 1'b0;
    end

    always @(posedge transfer)
    begin
        if (transfer == 1'b1)
        begin
            $display("NOTE : Reconfiguring PLL");
            $display ("Time: %0t  Instance: %m", $time);
            if (l_scan_chain == "long")
            begin
               // cntr e3
               error = 0;
               if (scan_data[273] == 1'b1)
               begin
                   e3_mode_val = "bypass";
                   if (scan_data[283] == 1'b1)
                   begin
                       e3_mode_val = "off";
                       $display("Warning : The specified bit settings will turn OFF the E3 counter. It cannot be turned on unless the part is re-initialized.");
                   end
               end
               else if (scan_data[283] == 1'b1)
                   e3_mode_val = "odd";
               else
                   e3_mode_val = "even";
               // before reading delay bits, clear e3_time_delay_val
               e3_time_delay_val = 32'b0;
               e3_time_delay_val = scan_data[287:284];
               e3_time_delay_val = e3_time_delay_val * 250;
               if (e3_time_delay_val > 3000)
                   e3_time_delay_val = 3000;
               e3_high_val[8:0] = scan_data[272:264];
               e3_low_val[8:0] = scan_data[282:274];
               if (e3_high_val[8:0] == 9'b000000000)
                   e3_high_val[9:0] = 10'b1000000000;
               if (e3_low_val[8:0] == 9'b000000000)
                   e3_low_val[9:0] = 10'b1000000000;

               if (ext_fbk_cntr == "e3")
               begin
                   ext_fbk_cntr_high = e3_high_val;
                   ext_fbk_cntr_low = e3_low_val;
                   ext_fbk_cntr_delay = e3_time_delay_val;
               end

               // cntr e2
               if (scan_data[249] == 1'b1)
               begin
                   e2_mode_val = "bypass";
                   if (scan_data[259] == 1'b1)
                   begin
                       e2_mode_val = "off";
                       $display("Warning : The specified bit settings will turn OFF the E2 counter. It cannot be turned on unless the part is re-initialized.");
                   end
               end
               else if (scan_data[259] == 1'b1)
                   e2_mode_val = "odd";
               else
                   e2_mode_val = "even";
               e2_time_delay_val = 32'b0;
               e2_time_delay_val = scan_data[263:260];
               e2_time_delay_val = e2_time_delay_val * 250;
               if (e2_time_delay_val > 3000)
                   e2_time_delay_val = 3000;
               e2_high_val[8:0] = scan_data[248:240];
               e2_low_val[8:0] = scan_data[258:250];
               if (e2_high_val[8:0] == 9'b000000000)
                   e2_high_val[9:0] = 10'b1000000000;
               if (e2_low_val[8:0] == 9'b000000000)
                   e2_low_val[9:0] = 10'b1000000000;

               if (ext_fbk_cntr == "e2")
               begin
                   ext_fbk_cntr_high = e2_high_val;
                   ext_fbk_cntr_low = e2_low_val;
                   ext_fbk_cntr_delay = e2_time_delay_val;
               end

               // cntr e1
               if (scan_data[225] == 1'b1)
               begin
                   e1_mode_val = "bypass";
                   if (scan_data[235] == 1'b1)
                   begin
                       e1_mode_val = "off";
                       $display("Warning : The specified bit settings will turn OFF the E1 counter. It cannot be turned on unless the part is re-initialized.");
                   end
               end
               else if (scan_data[235] == 1'b1)
                   e1_mode_val = "odd";
               else
                   e1_mode_val = "even";
               e1_time_delay_val = 32'b0;
               e1_time_delay_val = scan_data[239:236];
               e1_time_delay_val = e1_time_delay_val * 250;
               if (e1_time_delay_val > 3000)
                   e1_time_delay_val = 3000;
               e1_high_val[8:0] = scan_data[224:216];
               e1_low_val[8:0] = scan_data[234:226];
               if (e1_high_val[8:0] == 9'b000000000)
                   e1_high_val[9:0] = 10'b1000000000;
               if (e1_low_val[8:0] == 9'b000000000)
                   e1_low_val[9:0] = 10'b1000000000;

               if (ext_fbk_cntr == "e1")
               begin
                   ext_fbk_cntr_high = e1_high_val;
                   ext_fbk_cntr_low = e1_low_val;
                   ext_fbk_cntr_delay = e1_time_delay_val;
               end

               // cntr e0
               if (scan_data[201] == 1'b1)
               begin
                   e0_mode_val = "bypass";
                   if (scan_data[211] == 1'b1)
                   begin
                       e0_mode_val = "off";
                       $display("Warning : The specified bit settings will turn OFF the E0 counter. It cannot be turned on unless the part is re-initialized.");
                   end
               end
               else if (scan_data[211] == 1'b1)
                   e0_mode_val = "odd";
               else
                   e0_mode_val = "even";
               e0_time_delay_val = 32'b0;
               e0_time_delay_val = scan_data[215:212];
               e0_time_delay_val = e0_time_delay_val * 250;
               if (e0_time_delay_val > 3000)
                   e0_time_delay_val = 3000;
               e0_high_val[8:0] = scan_data[200:192];
               e0_low_val[8:0] = scan_data[210:202];
               if (e0_high_val[8:0] == 9'b000000000)
                   e0_high_val[9:0] = 10'b1000000000;
               if (e0_low_val[8:0] == 9'b000000000)
                   e0_low_val[9:0] = 10'b1000000000;

               if (ext_fbk_cntr == "e0")
               begin
                   ext_fbk_cntr_high = e0_high_val;
                   ext_fbk_cntr_low = e0_low_val;
                   ext_fbk_cntr_delay = e0_time_delay_val;
               end

               $display("PLL reconfigured with E3 high = %d, E3 low = %d, E3 mode = %s, E3 time delay = %0d", e3_high_val[9:0], e3_low_val[9:0], e3_mode_val, e3_time_delay_val);
               $display("                                   E2 high = %d, E2 low = %d, E2 mode = %s, E2 time delay = %0d", e2_high_val[9:0], e2_low_val[9:0], e2_mode_val, e2_time_delay_val);
               $display("                                   E1 high = %d, E1 low = %d, E1 mode = %s, E1 time delay = %0d", e1_high_val[9:0], e1_low_val[9:0], e1_mode_val, e1_time_delay_val);
               $display("                                   E0 high = %d, E0 low = %d, E0 mode = %s, E0 time delay = %0d", e0_high_val[9:0], e0_low_val[9:0], e0_mode_val, e0_time_delay_val);

            end
            // cntr l1
            if (scan_data[177] == 1'b1)
            begin
                l1_mode_val = "bypass";
                if (scan_data[187] == 1'b1)
                begin
                    l1_mode_val = "off";
                    $display("Warning : The specified bit settings will turn OFF the L1 counter. It cannot be turned on unless the part is re-initialized.");
                end
            end
            else if (scan_data[187] == 1'b1)
                l1_mode_val = "odd";
            else
                l1_mode_val = "even";
            l1_time_delay_val = 32'b0;
            l1_time_delay_val = scan_data[191:188];
            l1_time_delay_val = l1_time_delay_val * 250;
            if (l1_time_delay_val > 3000)
                l1_time_delay_val = 3000;
            l1_high_val[8:0] = scan_data[176:168];
            l1_low_val[8:0] = scan_data[186:178];
            if (l1_high_val[8:0] == 9'b000000000)
                l1_high_val[9:0] = 10'b1000000000;
            if (l1_low_val[8:0] == 9'b000000000)
                l1_low_val[9:0] = 10'b1000000000;

            // cntr l0
            if (scan_data[153] == 1'b1)
            begin
                l0_mode_val = "bypass";
                if (scan_data[163] == 1'b1)
                begin
                    l0_mode_val = "off";
                    $display("Warning : The specified bit settings will turn OFF the L0 counter. It cannot be turned on unless the part is re-initialized.");
                end
            end
            else if (scan_data[163] == 1'b1)
                l0_mode_val = "odd";
            else
                l0_mode_val = "even";
            l0_time_delay_val = 32'b0;
            l0_time_delay_val = scan_data[167:164];
            l0_time_delay_val = l0_time_delay_val * 250;
            if (l0_time_delay_val > 3000)
                l0_time_delay_val = 3000;
            l0_high_val[8:0] = scan_data[152:144];
            l0_low_val[8:0] = scan_data[162:154];
            if (l0_high_val[8:0] == 9'b000000000)
                l0_high_val[9:0] = 10'b1000000000;
            if (l0_low_val[8:0] == 9'b000000000)
                l0_low_val[9:0] = 10'b1000000000;

            $display("                                   L1 high = %d, L1 low = %d, L1 mode = %s, L1 time delay = %0d", l1_high_val[9:0], l1_low_val[9:0], l1_mode_val, l1_time_delay_val);
            $display("                                   L0 high = %d, L0 low = %d, L0 mode = %s, L0 time delay = %0d", l0_high_val[9:0], l0_low_val[9:0], l0_mode_val, l0_time_delay_val);

            // cntr g3
            if (scan_data[129] == 1'b1)
            begin
                g3_mode_val = "bypass";
                if (scan_data[139] == 1'b1)
                begin
                    g3_mode_val = "off";
                    $display("Warning : The specified bit settings will turn OFF the G3 counter. It cannot be turned on unless the part is re-initialized.");
                end
            end
            else if (scan_data[139] == 1'b1)
                g3_mode_val = "odd";
            else
                g3_mode_val = "even";
            g3_time_delay_val = 32'b0;
            g3_time_delay_val = scan_data[143:140];
            g3_time_delay_val = g3_time_delay_val * 250;
            if (g3_time_delay_val > 3000)
                g3_time_delay_val = 3000;
            g3_high_val[8:0] = scan_data[128:120];
            g3_low_val[8:0] = scan_data[138:130];
            if (g3_high_val[8:0] == 9'b000000000)
                g3_high_val[9:0] = 10'b1000000000;
            if (g3_low_val[8:0] == 9'b000000000)
                g3_low_val[9:0] = 10'b1000000000;

            // cntr g2
            if (scan_data[105] == 1'b1)
            begin
                g2_mode_val = "bypass";
                if (scan_data[115] == 1'b1)
                begin
                    g2_mode_val = "off";
                    $display("Warning : The specified bit settings will turn OFF the G2 counter. It cannot be turned on unless the part is re-initialized.");
                end
            end
            else if (scan_data[115] == 1'b1)
                g2_mode_val = "odd";
            else
                g2_mode_val = "even";
            g2_time_delay_val = 32'b0;
            g2_time_delay_val = scan_data[119:116];
            g2_time_delay_val = g2_time_delay_val * 250;
            if (g2_time_delay_val > 3000)
                g2_time_delay_val = 3000;
            g2_high_val[8:0] = scan_data[104:96];
            g2_low_val[8:0] = scan_data[114:106];
            if (g2_high_val[8:0] == 9'b000000000)
                g2_high_val[9:0] = 10'b1000000000;
            if (g2_low_val[8:0] == 9'b000000000)
                g2_low_val[9:0] = 10'b1000000000;

            // cntr g1
            if (scan_data[81] == 1'b1)
            begin
                g1_mode_val = "bypass";
                if (scan_data[91] == 1'b1)
                begin
                    g1_mode_val = "off";
                    $display("Warning : The specified bit settings will turn OFF the G1 counter. It cannot be turned on unless the part is re-initialized.");
                end
            end
            else if (scan_data[91] == 1'b1)
                g1_mode_val = "odd";
            else
                g1_mode_val = "even";
            g1_time_delay_val = 32'b0;
            g1_time_delay_val = scan_data[95:92];
            g1_time_delay_val = g1_time_delay_val * 250;
            if (g1_time_delay_val > 3000)
                g1_time_delay_val = 3000;
            g1_high_val[8:0] = scan_data[80:72];
            g1_low_val[8:0] = scan_data[90:82];
            if (g1_high_val[8:0] == 9'b000000000)
                g1_high_val[9:0] = 10'b1000000000;
            if (g1_low_val[8:0] == 9'b000000000)
                g1_low_val[9:0] = 10'b1000000000;

            // cntr g0
            if (scan_data[57] == 1'b1)
            begin
                g0_mode_val = "bypass";
                if (scan_data[67] == 1'b1)
                begin
                    g0_mode_val = "off";
                    $display("Warning : The specified bit settings will turn OFF the G0 counter. It cannot be turned on unless the part is re-initialized.");
                end
            end
            else if (scan_data[67] == 1'b1)
                g0_mode_val = "odd";
            else
                g0_mode_val = "even";
            g0_time_delay_val = 32'b0;
            g0_time_delay_val = scan_data[71:68];
            g0_time_delay_val = g0_time_delay_val * 250;
            if (g0_time_delay_val > 3000)
                g0_time_delay_val = 3000;
            g0_high_val[8:0] = scan_data[56:48];
            g0_low_val[8:0] = scan_data[66:58];
            if (g0_high_val[8:0] == 9'b000000000)
                g0_high_val[9:0] = 10'b1000000000;
            if (g0_low_val[8:0] == 9'b000000000)
                g0_low_val[9:0] = 10'b1000000000;

            $display("                                   G3 high = %d, G3 low = %d, G3 mode = %s, G3 time delay = %0d", g3_high_val[9:0], g3_low_val[9:0], g3_mode_val, g3_time_delay_val);
            $display("                                   G2 high = %d, G2 low = %d, G2 mode = %s, G2 time delay = %0d", g2_high_val[9:0], g2_low_val[9:0], g2_mode_val, g2_time_delay_val);
            $display("                                   G1 high = %d, G1 low = %d, G1 mode = %s, G1 time delay = %0d", g1_high_val[9:0], g1_low_val[9:0], g1_mode_val, g1_time_delay_val);
            $display("                                   G0 high = %d, G0 low = %d, G0 mode = %s, G0 time delay = %0d", g0_high_val[9:0], g0_low_val[9:0], g0_mode_val, g0_time_delay_val);

            // cntr M
            error = 0;
            m_val[8:0] = scan_data[32:24];
            if (scan_data[33] !== 1'b1)
            begin
                if (m_mode_val === "bypass")
                begin
                    reconfig_err = 1;
                    error = 1;
                    $display ("Warning : Illegal mode for the M counter. Cannot switch between BYPASS/NON-BYPASS modes. Reconfiguration may not work.");
                end
                else if (m_val[8:0] == 9'b000000001)
                begin
                    reconfig_err = 1;
                    error = 1;
                    $display ("Warning : Illegal 1 value for M counter. Instead, the M counter should be BYPASSED. Reconfiguration may not work.");
                end
                else if (m_val[8:0] == 9'b000000000)
                    m_val[9:0] = 10'b1000000000;
                m_mode_val = "";
            end
            else if (scan_data[33] == 1'b1)
            begin
                if (m_mode_val !== "bypass")
                begin
                    reconfig_err = 1;
                    error = 1;
                    $display ("Warning : Illegal mode for the M counter. Cannot switch between BYPASS/NON-BYPASS modes. Reconfiguration may not work.");
                end
                else if (scan_data[24] !== 1'b0)
                begin
                    reconfig_err = 1;
                    error = 1;
                    $display ("Warning : Illegal value for counter M in BYPASS mode. The LSB of the counter should be set to 0 in order to operate the counter in BYPASS mode. Reconfiguration may not work.");
                end
                else
                    m_val[9:0] = 10'b0000000001;
                m_mode_val = "bypass";
            end
            if (skip_vco == "on")
                m_val[9:0] = 10'b0000000001;
            if (error == 0)
                $display("                                   M modulus = %d ", m_val[9:0]);

            // cntr M2
            if (ss > 0)
            begin
                error = 0;
                m2_val[8:0] = scan_data[42:34];
                if (scan_data[43] !== 1'b1)
                begin
                    if (m2_mode_val === "bypass")
                    begin
                        reconfig_err = 1;
                        error = 1;
                        $display ("Warning : Illegal mode for the M2 counter. Cannot switch between BYPASS/NON-BYPASS modes. Reconfiguration may not work.");
                    end
                    else if (m2_val[8:0] == 9'b000000001)
                    begin
                        reconfig_err = 1;
                        error = 1;
                        $display ("Warning : Illegal 1 value for M2 counter. Instead, the N counter should be BYPASSED. Reconfiguration may not work.");
                    end
                    else if (m2_val[8:0] == 9'b000000000)
                        m2_val[9:0] = 10'b1000000000;
                    m2_mode_val = "";
                end
                else if (scan_data[43] == 1'b1)
                begin
                    if (m2_mode_val !== "bypass")
                    begin
                        reconfig_err = 1;
                        error = 1;
                        $display ("Warning : Illegal mode for the M2 counter. Cannot switch between BYPASS/NON-BYPASS modes. Reconfiguration may not work.");
                    end
                    else if (scan_data[34] !== 1'b0)
                    begin
                        reconfig_err = 1;
                        error = 1;
                        $display ("Warning : Illegal value for counter M2 in BYPASS mode. The LSB of the counter should be set to 0 in order to operate the counter in BYPASS mode. Reconfiguration may not work.");
                    end
                    else
                        m2_val[9:0] = 10'b0000000001;
                    m2_mode_val = "bypass";
                end
                if (m_mode_val != m2_mode_val)
                begin
                    reconfig_err = 1;
                    error = 1;
                    $display ("Warning : Incompatible modes for M1/M2 counters. Either both should be BYASSED or both NON-BYPASSED. Reconfiguration may not work.");
                end
                if (error == 0)
                    $display(" M2 modulus = %d ", m2_val[9:0]);
            end

            m_time_delay_val = 32'b0;
            m_time_delay_val = scan_data[47:44];
            m_time_delay_val = m_time_delay_val * 250;
            if (m_time_delay_val > 3000)
                m_time_delay_val = 3000;
            if (skip_vco == "on")
                m_time_delay_val = 32'b0;
            $display("                                   M time delay = %0d", m_time_delay_val);

            // cntr N
            error = 0;
            n_val[8:0] = scan_data[8:0];
            if (scan_data[9] !== 1'b1)
            begin
                if (n_mode_val === "bypass")
                begin
                    reconfig_err = 1;
                    error = 1;
                    $display ("Warning : Illegal mode for the N counter. Cannot switch between BYPASS/NON-BYPASS modes. Reconfiguration may not work.");
                end
                else if (n_val[8:0] == 9'b000000001)
                begin
                    reconfig_err = 1;
                    error = 1;
                    $display ("Warning : Illegal 1 value for N counter. Instead, the N counter should be BYPASSED. Reconfiguration may not work.");
                end
                else if (n_val[8:0] == 9'b000000000)
                    n_val[9:0] = 10'b1000000000;
                n_mode_val = "";
            end
            else if (scan_data[9] == 1'b1)     // bypass
            begin
                if (n_mode_val !== "bypass")
                begin
                    reconfig_err = 1;
                    error = 1;
                    $display ("Warning : Illegal mode for the N counter. Cannot switch between BYPASS/NON-BYPASS modes. Reconfiguration may not work.");
                end
                else if (scan_data[0] !== 1'b0)
                begin
                    reconfig_err = 1;
                    error = 1;
                    $display ("Warning : Illegal value for counter N in BYPASS mode. The LSB of the counter should be set to 0 in order to operate the counter in BYPASS mode. Reconfiguration may not work.");
                end
                else
                    n_val[9:0] = 10'b0000000001;

                n_mode_val = "bypass";
            end
            if (error == 0)
                $display("                                   N modulus = %d ", n_val[9:0]);

            // cntr N2
            if (ss > 0)
            begin
                error = 0;
                n2_val[8:0] = scan_data[18:10];
                if (scan_data[19] !== 1'b1)
                begin
                    if (n2_mode_val === "bypass")
                    begin
                        reconfig_err = 1;
                        error = 1;
                        $display ("Warning : Illegal mode for the N2 counter. Cannot switch between BYPASS/NON-BYPASS modes. Reconfiguration may not work.");
                    end
                    else if (n2_val[8:0] == 9'b000000001)
                    begin
                        reconfig_err = 1;
                        error = 1;
                        $display ("Warning : Illegal 1 value for N2 counter. Instead, the N2 counter should be BYPASSED. Reconfiguration may not work.");
                    end
                    else if (n2_val[8:0] == 9'b000000000)
                        n2_val = 10'b1000000000;
                    n2_mode_val = "";
                end
                else if (scan_data[19] == 1'b1)     // bypass
                begin
                    if (n2_mode_val !== "bypass")
                    begin
                        reconfig_err = 1;
                        error = 1;
                        $display ("Warning : Illegal mode for the N2 counter. Cannot switch between BYPASS/NON-BYPASS modes. Reconfiguration may not work.");
                    end
                    else if (scan_data[10] !== 1'b0)
                    begin
                        reconfig_err = 1;
                        error = 1;
                        $display ("Warning : Illegal value for counter N2 in BYPASS mode. The LSB of the counter should be set to 0 in order to operate the counter in BYPASS mode. Reconfiguration may not work.");
                    end
                    else
                        n2_val[9:0] = 10'b0000000001;

                    n2_mode_val = "bypass";
                end
                if (n_mode_val != n2_mode_val)
                begin
                    reconfig_err = 1;
                    error = 1;
                    $display ("Warning : Incompatible modes for N1/N2 counters. Either both should be BYASSED or both NON-BYPASSED.");
                end
                if (error == 0)
                    $display(" N2 modulus = %d ", n2_val[9:0]);
            end // ss > 0

            n_time_delay_val = 32'b0;
            n_time_delay_val = scan_data[23:20];
            n_time_delay_val = n_time_delay_val * 250;
            if (n_time_delay_val > 3000)
                n_time_delay_val = 3000;
            $display("                                   N time delay = %0d", n_time_delay_val);

            transfer = 0;
            // clear the scan_chain
            for (i = 0; i <= scan_chain_length; i = i + 1)
               scan_data[i] = 0;
        end
    end

always @(schedule_vco or areset_ipd or ena_ipd)
begin
    sched_time = 0;

    for (i = 0; i <= 7; i=i+1)
        last_phase_shift[i] = phase_shift[i];
 
    cycle_to_adjust = 0;
    l_index = 1;
    m_times_vco_period = new_m_times_vco_period;

    // give appropriate messages
    // if areset was asserted
    if (areset_ipd == 1'b1 && areset_ipd_last_value !== areset_ipd)
    begin
        $display (" Note : PLL was reset");
        $display ("Time: %0t  Instance: %m", $time);
    end

    // if ena was deasserted
    if (ena_ipd == 1'b0 && ena_ipd_last_value !== ena_ipd)
    begin
        $display (" Note : PLL was disabled");
        $display ("Time: %0t  Instance: %m", $time);
    end

    // illegal value on areset_ipd
    if (areset_ipd === 1'bx && (areset_ipd_last_value === 1'b0 || areset_ipd_last_value === 1'b1))
    begin
        $display("Warning : Illegal value 'X' detected on ARESET input");
        $display ("Time: %0t  Instance: %m", $time);
    end

   if ((schedule_vco !== schedule_vco_last_value) && (areset_ipd == 1'b1 || ena_ipd == 1'b0 || stop_vco == 1'b1))
   begin

      // drop VCO taps to 0
      for (i = 0; i <= 7; i=i+1)
      begin
         for (j = 0; j <= last_phase_shift[i] + 1; j=j+1)
             vco_out[i] <= #(j) 1'b0;
         phase_shift[i] = 0;
         last_phase_shift[i] = 0;
      end

      // reset lock parameters
      locked_tmp = 0;
      if (l_pll_type == "fast")
         locked_tmp = 1;
      pll_is_locked = 0;
      pll_about_to_lock = 0;
      cycles_to_lock = 0;
      cycles_to_unlock = 0;

      got_first_refclk = 0;
      got_second_refclk = 0;
      refclk_time = 0;
      got_first_fbclk = 0;
      fbclk_time = 0;
      first_fbclk_time = 0;
      fbclk_period = 0;

      first_schedule = 1;
      schedule_offset = 1;
      vco_val = 0;
      vco_period_was_phase_adjusted = 0;
      phase_adjust_was_scheduled = 0;

      // reset enable0 and enable1 counter parameters
//      l0_count = 1;
//      l1_count = 1;
//      l0_got_first_rising_edge = 0;
//      l1_got_first_rising_edge = 0;

   end else if (ena_ipd === 1'b1 && areset_ipd === 1'b0 && stop_vco === 1'b0)
   begin

       // else note areset deassert time
       // note it as refclk_time to prevent false triggering
       // of stop_vco after areset
       if (areset_ipd === 1'b0 && areset_ipd_last_value === 1'b1)
       begin
           refclk_time = $time;
       end

      // calculate loop_xplier : this will be different from m_val in ext. fbk mode
      loop_xplier = m_val;
      loop_initial = i_m_initial - 1;
      loop_ph = i_m_ph;
      loop_time_delay = m_time_delay_val;

      if (l_operation_mode == "external_feedback")
      begin
         loop_xplier = m_val * (ext_fbk_cntr_high + ext_fbk_cntr_low);
         loop_ph = ext_fbk_cntr_ph;
         loop_initial = ext_fbk_cntr_initial - 1 + ((i_m_initial - 1) * (ext_fbk_cntr_high + ext_fbk_cntr_low));
         loop_time_delay = m_time_delay_val + ext_fbk_cntr_delay;
      end

      // convert initial value to delay
      initial_delay = (loop_initial * m_times_vco_period)/loop_xplier;

      // convert loop ph_tap to delay
      rem = m_times_vco_period % loop_xplier;
      vco_per = m_times_vco_period/loop_xplier;
      if (rem != 0)
          vco_per = vco_per + 1;
      fbk_phase = (loop_ph * vco_per)/8;

      if (l_operation_mode == "external_feedback")
      begin
          pull_back_ext_cntr = ext_fbk_cntr_delay + (ext_fbk_cntr_initial - 1) * (m_times_vco_period/loop_xplier) + fbk_phase;

          while (pull_back_ext_cntr > refclk_period)
              pull_back_ext_cntr = pull_back_ext_cntr - refclk_period;

          pull_back_M =  m_time_delay_val + (i_m_initial - 1) * (ext_fbk_cntr_high + ext_fbk_cntr_low) * (m_times_vco_period/loop_xplier);

          while (pull_back_M > refclk_period)
              pull_back_M = pull_back_M - refclk_period;
      end
      else begin
          pull_back_ext_cntr = 0;
          pull_back_M = initial_delay + m_time_delay_val + fbk_phase;
      end

      total_pull_back = pull_back_M + pull_back_ext_cntr;
      if (l_simulation_type == "timing")
          total_pull_back = total_pull_back + pll_compensation_delay;

      while (total_pull_back > refclk_period)
          total_pull_back = total_pull_back - refclk_period;

      if (total_pull_back > 0)
          offset = refclk_period - total_pull_back;

      if (l_operation_mode == "external_feedback")
      begin
          fbk_delay = pull_back_M;
          if (l_simulation_type == "timing")
              fbk_delay = fbk_delay + pll_compensation_delay;

          ext_fbk_delay = pull_back_ext_cntr - fbk_phase;
      end
      else begin
          fbk_delay = total_pull_back - fbk_phase;
          if (fbk_delay < 0)
          begin
              offset = offset - fbk_phase;
              fbk_delay = total_pull_back;
          end
      end

      // assign m_delay
      m_delay = fbk_delay;

      for (i = 1; i <= loop_xplier; i=i+1)
      begin
         // adjust cycles
         tmp_vco_per = m_times_vco_period/loop_xplier;
         if (rem != 0 && l_index <= rem)
         begin
            tmp_rem = (loop_xplier * l_index) % rem;
            cycle_to_adjust = (loop_xplier * l_index) / rem;
            if (tmp_rem != 0)
               cycle_to_adjust = cycle_to_adjust + 1;
         end
         if (cycle_to_adjust == i)
         begin
            tmp_vco_per = tmp_vco_per + 1;
            l_index = l_index + 1;
         end

         // calculate high and low periods
         high_time = tmp_vco_per/2;
         if (tmp_vco_per % 2 != 0)
             high_time = high_time + 1;
         low_time = tmp_vco_per - high_time;

         // schedule the rising and falling egdes
         for (j=0; j<=1; j=j+1)
         begin
            vco_val = ~vco_val;
            if (vco_val == 1'b0)
                sched_time = sched_time + high_time;
            else
                sched_time = sched_time + low_time;

            // add offset
            if (schedule_offset == 1'b1)
            begin
               sched_time = sched_time + offset;
               schedule_offset = 0;
            end

            // schedule taps with appropriate phase shifts
            for (k = 0; k <= 7; k=k+1)
            begin
               phase_shift[k] = (k*tmp_vco_per)/8;
               if (first_schedule)
                   vco_out[k] <= #(sched_time + phase_shift[k]) vco_val;
               else
                   vco_out[k] <= #(sched_time + last_phase_shift[k]) vco_val;
            end
         end
      end
      if (first_schedule)
      begin
         vco_val = ~vco_val;
         if (vco_val == 1'b0)
             sched_time = sched_time + high_time;
         else
             sched_time = sched_time + low_time;
         for (k = 0; k <= 7; k=k+1)
         begin
            phase_shift[k] = (k*tmp_vco_per)/8;
            vco_out[k] <= #(sched_time+phase_shift[k]) vco_val;
         end
         first_schedule = 0;
      end

      // this may no longer be required

      schedule_vco <= #(sched_time) ~schedule_vco;
      if (vco_period_was_phase_adjusted)
      begin
          m_times_vco_period = refclk_period;
          new_m_times_vco_period = refclk_period;
          vco_period_was_phase_adjusted = 0;
          phase_adjust_was_scheduled = 1;

          tmp_vco_per = m_times_vco_period/loop_xplier;
          for (k = 0; k <= 7; k=k+1)
              phase_shift[k] = (k*tmp_vco_per)/8;
      end
   end

     areset_ipd_last_value = areset_ipd;
     ena_ipd_last_value = ena_ipd;
     schedule_vco_last_value = schedule_vco;

end

always @(pfdena_ipd)
begin
   if (pfdena_ipd === 1'b0)
   begin
      locked_tmp = 1'bx;
      pll_is_locked = 0;
      cycles_to_lock = 0;
      $display (" Note : PFDENA was deasserted");
      $display ("Time: %0t  Instance: %m", $time);
   end
   else if (pfdena_ipd === 1'b1 && pfdena_ipd_last_value === 1'b0)
   begin
       // PFD was disabled, now enabled again
      got_first_refclk = 0;
      got_second_refclk = 0;
      refclk_time = $time;
   end
   pfdena_ipd_last_value = pfdena_ipd;
end

always @(negedge refclk or negedge fbclk)
begin
   refclk_last_value = refclk;
   fbclk_last_value = fbclk;
end

always @(posedge refclk or posedge fbclk)
begin
    if (refclk == 1'b1 && refclk_last_value !== refclk && areset_ipd === 1'b0)
    begin
       if (! got_first_refclk)
       begin
          got_first_refclk = 1;
       end else
       begin
          got_second_refclk = 1;
          refclk_period = $time - refclk_time;

          // check if incoming freq. will cause VCO range to be
          // exceeded
          if ( (vco_max != 0 && vco_min != 0) && (skip_vco == "off") && (pfdena_ipd === 1'b1) &&
               ((refclk_period/loop_xplier > vco_max) ||
               (refclk_period/loop_xplier < vco_min)) )
          begin
              if (pll_is_locked == 1'b1)
              begin
                  $display ("Warning : Input clock freq. is not within VCO range. PLL may lose lock");
                  $display ("Time: %0t  Instance: %m", $time);
              end
              else begin
                  $display ("Warning : Input clock freq. is not within VCO range. PLL may not lock");
                  $display ("Time: %0t  Instance: %m", $time);
              end
              inclk_out_of_range = 1;
          end
          else if ( vco_min == 0 && vco_max == 0 && pll_type == "cdr")
          begin
              if (refclk_period != primary_clock_frequency)
              begin
                  if (no_warn == 0)
                  begin
                      $display("Warning : Incoming clock period %d for PLL does not match the specified inclock period %d. ALTGXB simulation may not function correctly.", refclk_period, primary_clock_frequency);
                      $display ("Time: %0t  Instance: %m", $time);
                      no_warn = 1;
                  end
              end
          end
          else begin
              inclk_out_of_range = 0;
          end

       end
       if (stop_vco == 1'b1)
       begin
          stop_vco = 0;
          schedule_vco = ~schedule_vco;
       end
       refclk_time = $time;
    end

    if (fbclk == 1'b1 && fbclk_last_value !== fbclk)
    begin
       if (!got_first_fbclk)
       begin
          got_first_fbclk = 1;
          first_fbclk_time = $time;
       end
       else
          fbclk_period = $time - fbclk_time;

       // need refclk_period here, so initialized to proper value above
       if ( ($time - refclk_time > 1.5 * refclk_period) && pfdena_ipd === 1'b1)
       begin
           stop_vco = 1;
           // reset
           got_first_refclk = 0;
           got_first_fbclk = 0;
           got_second_refclk = 0;
           if (pll_is_locked == 1'b1)
           begin
              pll_is_locked = 0;
              locked_tmp = 0;
              if (l_pll_type == "fast")
                 locked_tmp = 1;
              $display ("Note : PLL lost lock due to loss of input clock");
              $display ("Time: %0t  Instance: %m", $time);
           end
           pll_about_to_lock = 0;
           cycles_to_lock = 0;
           cycles_to_unlock = 0;
           first_schedule = 1;
       end
       fbclk_time = $time;
    end

    if (got_second_refclk && pfdena_ipd === 1'b1 && (!inclk_out_of_range))
    begin
       // now we know actual incoming period
//       if (abs(refclk_period - fbclk_period) > 2)
//       begin
//           new_m_times_vco_period = refclk_period;
//       end
//       else if (abs(fbclk_time - refclk_time) <= 2 || (refclk_period - abs(fbclk_time - refclk_time) <= 2))
       if (abs(fbclk_time - refclk_time) <= 5 || (got_first_fbclk && abs(refclk_period - abs(fbclk_time - refclk_time)) <= 5))
       begin
            // considered in phase
           if (cycles_to_lock == valid_lock_multiplier - 1)
              pll_about_to_lock <= 1;
           if (cycles_to_lock == valid_lock_multiplier)
           begin
              if (pll_is_locked === 1'b0)
              begin
                  $display (" Note : PLL locked to incoming clock");
                  $display ("Time: %0t  Instance: %m", $time);
              end
              pll_is_locked = 1;
              locked_tmp = 1;
              if (l_pll_type == "fast")
                 locked_tmp = 0;
           end
           // increment lock counter only if the second part of the above
           // time check is NOT true
           if (!(abs(refclk_period - abs(fbclk_time - refclk_time)) <= 5))
           begin
               cycles_to_lock = cycles_to_lock + 1;
           end

           // adjust m_times_vco_period
           new_m_times_vco_period = refclk_period;

       end else
       begin
           // if locked, begin unlock
           if (pll_is_locked)
           begin
               cycles_to_unlock = cycles_to_unlock + 1;
               if (cycles_to_unlock == invalid_lock_multiplier)
               begin
                   pll_is_locked = 0;
                   locked_tmp = 0;
                   if (l_pll_type == "fast")
                       locked_tmp = 1;
                   pll_about_to_lock = 0;
                   cycles_to_lock = 0;
                   $display ("Note : PLL lost lock");
                   $display ("Time: %0t  Instance: %m", $time);
                   first_schedule = 1;
                   schedule_offset = 1;
                   vco_period_was_phase_adjusted = 0;
                   phase_adjust_was_scheduled = 0;
               end
           end
           if (abs(refclk_period - fbclk_period) <= 2)
           begin
               // frequency is still good
               if ($time == fbclk_time && (!phase_adjust_was_scheduled))
               begin
                   if (abs(fbclk_time - refclk_time) > refclk_period/2)
                   begin
                       new_m_times_vco_period = m_times_vco_period + (refclk_period - abs(fbclk_time - refclk_time));
                       vco_period_was_phase_adjusted = 1;
                   end else
                   begin
                       new_m_times_vco_period = m_times_vco_period - abs(fbclk_time - refclk_time);
                       vco_period_was_phase_adjusted = 1;
                   end
               end
           end else
           begin
               new_m_times_vco_period = refclk_period;
               phase_adjust_was_scheduled = 0;
           end
       end
    end

    if (quiet_period_violation == 1'b1 || reconfig_err == 1'b1 || scanclr_violation == 1'b1 || scanclr_clk_violation == 1'b1)
    begin
        locked_tmp = 0;
        if (l_pll_type == "fast")
            locked_tmp = 1;
    end

    refclk_last_value = refclk;
    fbclk_last_value = fbclk;
end

    assign clk0_tmp = clk0_counter == "l0" ? l0_clk : clk0_counter == "l1" ? l1_clk : clk0_counter == "g0" ? g0_clk : clk0_counter == "g1" ? g1_clk : clk0_counter == "g2" ? g2_clk : clk0_counter == "g3" ? g3_clk : 'b0;

    assign clk0 = (areset_ipd === 1'b1 || ena_ipd === 1'b0) || (pll_about_to_lock == 1'b1 && !quiet_period_violation && !reconfig_err && !scanclr_violation && !scanclr_clk_violation) ? clk0_tmp : 'bx;

    altgxb_dffe ena0_reg (.D(clkena0_ipd),
                   .CLRN(1'b1),
                   .PRN(1'b1),
                   .ENA(1'b1),
                   .CLK(!clk0_tmp),
                   .Q(ena0)
                  );

    assign clk1_tmp = clk1_counter == "l0" ? l0_clk : clk1_counter == "l1" ? l1_clk : clk1_counter == "g0" ? g0_clk : clk1_counter == "g1" ? g1_clk : clk1_counter == "g2" ? g2_clk : clk1_counter == "g3" ? g3_clk : 'b0;

    assign clk1 = (areset_ipd === 1'b1 || ena_ipd === 1'b0) || (pll_about_to_lock == 1'b1 && !quiet_period_violation && !reconfig_err && !scanclr_violation && !scanclr_clk_violation) ? clk1_tmp : 'bx;

    altgxb_dffe ena1_reg (.D(clkena1_ipd),
                   .CLRN(1'b1),
                   .PRN(1'b1),
                   .ENA(1'b1),
                   .CLK(!clk1_tmp),
                   .Q(ena1)
                  );

    assign clk2_tmp = clk2_counter == "l0" ? l0_clk : clk2_counter == "l1" ? l1_clk : clk2_counter == "g0" ? g0_clk : clk2_counter == "g1" ? g1_clk : clk2_counter == "g2" ? g2_clk : clk2_counter == "g3" ? g3_clk : 'b0;

    assign clk2 = (areset_ipd === 1'b1 || ena_ipd === 1'b0) || (pll_about_to_lock == 1'b1 && !quiet_period_violation && !reconfig_err && !scanclr_violation && !scanclr_clk_violation) ? clk2_tmp : 'bx;

    altgxb_dffe ena2_reg (.D(clkena2_ipd),
                   .CLRN(1'b1),
                   .PRN(1'b1),
                   .ENA(1'b1),
                   .CLK(!clk2_tmp),
                   .Q(ena2)
                  );

    assign clk3_tmp = clk3_counter == "l0" ? l0_clk : clk3_counter == "l1" ? l1_clk : clk3_counter == "g0" ? g0_clk : clk3_counter == "g1" ? g1_clk : clk3_counter == "g2" ? g2_clk : clk3_counter == "g3" ? g3_clk : 'b0;

    assign clk3 = (areset_ipd === 1'b1 || ena_ipd === 1'b0) || (pll_about_to_lock == 1'b1 && !quiet_period_violation && !reconfig_err && !scanclr_violation && !scanclr_clk_violation) ? clk3_tmp : 'bx;

    altgxb_dffe ena3_reg (.D(clkena3_ipd),
                   .CLRN(1'b1),
                   .PRN(1'b1),
                   .ENA(1'b1),
                   .CLK(!clk3_tmp),
                   .Q(ena3)
                  );

    assign clk4_tmp = clk4_counter == "l0" ? l0_clk : clk4_counter == "l1" ? l1_clk : clk4_counter == "g0" ? g0_clk : clk4_counter == "g1" ? g1_clk : clk4_counter == "g2" ? g2_clk : clk4_counter == "g3" ? g3_clk : 'b0;

    assign clk4 = (areset_ipd === 1'b1 || ena_ipd === 1'b0) || (pll_about_to_lock == 1'b1 && !quiet_period_violation && !reconfig_err && !scanclr_violation && !scanclr_clk_violation) ? clk4_tmp : 'bx;

    altgxb_dffe ena4_reg (.D(clkena4_ipd),
                   .CLRN(1'b1),
                   .PRN(1'b1),
                   .ENA(1'b1),
                   .CLK(!clk4_tmp),
                   .Q(ena4)
                  );

    assign clk5_tmp = clk5_counter == "l0" ? l0_clk : clk5_counter == "l1" ? l1_clk : clk5_counter == "g0" ? g0_clk : clk5_counter == "g1" ? g1_clk : clk5_counter == "g2" ? g2_clk : clk5_counter == "g3" ? g3_clk : 'b0;

    assign clk5 = (areset_ipd === 1'b1 || ena_ipd === 1'b0) || (pll_about_to_lock == 1'b1 && !quiet_period_violation && !reconfig_err && !scanclr_violation && !scanclr_clk_violation) ? clk5_tmp : 'bx;

    altgxb_dffe ena5_reg (.D(clkena5_ipd),
                   .CLRN(1'b1),
                   .PRN(1'b1),
                   .ENA(1'b1),
                   .CLK(!clk5_tmp),
                   .Q(ena5)
                  );

    assign extclk0_tmp = extclk0_counter == "e0" ? e0_clk : extclk0_counter == "e1" ? e1_clk : extclk0_counter == "e2" ? e2_clk : extclk0_counter == "e3" ? e3_clk : 'b0;

    assign extclk0 = (areset_ipd === 1'b1 || ena_ipd === 1'b0) || (pll_about_to_lock == 1'b1 && !quiet_period_violation && !reconfig_err && !scanclr_violation && !scanclr_clk_violation) ? extclk0_tmp : 'bx;

    altgxb_dffe extena0_reg (.D(extclkena0_ipd),
                      .CLRN(1'b1),
                      .PRN(1'b1),
                      .ENA(1'b1),
                      .CLK(!extclk0_tmp),
                      .Q(extena0)
                     );

    assign extclk1_tmp = extclk1_counter == "e0" ? e0_clk : extclk1_counter == "e1" ? e1_clk : extclk1_counter == "e2" ? e2_clk : extclk1_counter == "e3" ? e3_clk : 'b0;

    assign extclk1 = (areset_ipd === 1'b1 || ena_ipd === 1'b0) || (pll_about_to_lock == 1'b1 && !quiet_period_violation && !reconfig_err && !scanclr_violation && !scanclr_clk_violation) ? extclk1_tmp : 'bx;

    altgxb_dffe extena1_reg (.D(extclkena1_ipd),
                      .CLRN(1'b1),
                      .PRN(1'b1),
                      .ENA(1'b1),
                      .CLK(!extclk1_tmp),
                      .Q(extena1)
                     );

    assign extclk2_tmp = extclk2_counter == "e0" ? e0_clk : extclk2_counter == "e1" ? e1_clk : extclk2_counter == "e2" ? e2_clk : extclk2_counter == "e3" ? e3_clk : 'b0;

    assign extclk2 = (areset_ipd === 1'b1 || ena_ipd === 1'b0) || (pll_about_to_lock == 1'b1 && !quiet_period_violation && !reconfig_err && !scanclr_violation && !scanclr_clk_violation) ? extclk2_tmp : 'bx;

    altgxb_dffe extena2_reg (.D(extclkena2_ipd),
                      .CLRN(1'b1),
                      .PRN(1'b1),
                      .ENA(1'b1),
                      .CLK(!extclk2_tmp),
                      .Q(extena2)
                     );

    assign extclk3_tmp = extclk3_counter == "e0" ? e0_clk : extclk3_counter == "e1" ? e1_clk : extclk3_counter == "e2" ? e2_clk : extclk3_counter == "e3" ? e3_clk : 'b0;

    assign extclk3 = (areset_ipd === 1'b1 || ena_ipd === 1'b0) || (pll_about_to_lock == 1'b1 && !quiet_period_violation && !reconfig_err && !scanclr_violation && !scanclr_clk_violation) ? extclk3_tmp : 'bx;

    altgxb_dffe extena3_reg (.D(extclkena3_ipd),
                      .CLRN(1'b1),
                      .PRN(1'b1),
                      .ENA(1'b1),
                      .CLK(!extclk3_tmp),
                      .Q(extena3)
                     );

    assign enable_0 = (areset_ipd === 1'b1 || ena_ipd === 1'b0) || pll_about_to_lock == 1'b1 ? enable0_tmp : 'bx;
    assign enable_1 = (areset_ipd === 1'b1 || ena_ipd === 1'b0) || pll_about_to_lock == 1'b1 ? enable1_tmp : 'bx;

    // ACCELERATE OUTPUTS
    and (clk[0], ena0, clk0);
    and (clk[1], ena1, clk1);
    and (clk[2], ena2, clk2);
    and (clk[3], ena3, clk3);
    and (clk[4], ena4, clk4);
    and (clk[5], ena5, clk5);

    and (extclk[0], extena0, extclk0);
    and (extclk[1], extena1, extclk1);
    and (extclk[2], extena2, extclk2);
    and (extclk[3], extena3, extclk3);

    and (enable0, 1'b1, enable_0);
    and (enable1, 1'b1, enable_1);

    and (scandataout, 1'b1, scandataout_tmp);

endmodule

// START MODULE NAME -----------------------------------------------------------
//
// Module Name : altgxb_pll
//
// Description : Phase-Locked Loop (PLL) behavioral model. Model supports basic
//               PLL features such as clock division and multiplication,
//               programmable duty cycle and phase shifts, various feedback modes
//               and clock delays. Also supports real-time reconfiguration of
//               PLL "parameters" and clock switchover between the 2 input
//               reference clocks. Up to 10 clock outputs may be used.
//
// Limitations : Applicable to Stratix and Stratix-GX device families only
//               There is no support in the model for spread-spectrum feature
//
// Expected results : Up to 10 output clocks, each defined by its own set of
//                    parameters. Locked output (active high) indicates when the
//                    PLL locks. clkbad, clkloss and activeclock are used for
//                    clock switchover to inidicate which input clock has gone
//                    bad, when the clock switchover initiates and which input
//                    clock is being used as the reference, respectively.
//                    scandataout is the data output of the serial scan chain.

//END MODULE NAME --------------------------------------------------------------

`timescale 1 ps / 1ps

// MODULE DECLARATION
module altgxb_pll (   
    inclk,      // input reference clock - up to 2 can be used
    fbin,       // external feedback input port
    pllena,     // PLL enable signal
    clkswitch,  // switch between inclk0 and inclk1
    areset,     // asynchronous reset
    pfdena,     // enable the Phase Frequency Detector (PFD)
    clkena,     // enable clk0 to clk5 clock outputs
    extclkena,  // enable extclk0 to extclk3 clock outputs
    scanclk,    // clock for the serial scan chain
    scanaclr,   // asynchronous clear the serial scan chain
    scandata,   // data for the scan chain
    clk,        // internal clock outputs (feeds the core)
    extclk,     // external clock outputs (feeds pins)
    clkbad,     // indicates if inclk0/inclk1 has gone bad
    activeclock,// indicates which input clock is being used
    clkloss,    // indicates when clock switchover initiates
    locked,     // indicates when the PLL locks onto the input clock
    scandataout // data output of the serial scan chain
);

// GLOBAL PARAMETER DECLARATION
parameter   intended_device_family    = "Stratix" ;
parameter   operation_mode            = "NORMAL" ;
parameter   pll_type                  = "AUTO" ;
parameter   qualify_conf_done         = "OFF" ;
parameter   compensate_clock          = "CLK0" ;
parameter   scan_chain                = "LONG";
parameter   primary_clock             = "inclk0";
parameter   inclk0_input_frequency    = 1000;
parameter   inclk1_input_frequency    = 1000;
parameter   gate_lock_signal          = "NO";
parameter   gate_lock_counter         = 0;
parameter   lock_high                 = 1;
parameter   lock_low                  = 5;
parameter   valid_lock_multiplier     = 1;
parameter   invalid_lock_multiplier   = 5;
parameter   switch_over_on_lossclk    = "OFF" ;
parameter   switch_over_on_gated_lock = "OFF" ;
parameter   enable_switch_over_counter = "OFF";
parameter   switch_over_counter       = 0;
parameter   feedback_source           = "EXTCLK0" ;
parameter   bandwidth                 = 0;
parameter   bandwidth_type            = "UNUSED";
parameter   spread_frequency          = 0;
parameter   down_spread               = "0.0";
// simulation-only parameters
parameter   simulation_type           = "functional";

parameter   skip_vco                    = "off";

//  internal clock specifications
parameter   clk5_multiply_by        = 1;
parameter   clk4_multiply_by        = 1;
parameter   clk3_multiply_by        = 1;
parameter   clk2_multiply_by        = 1;
parameter   clk1_multiply_by        = 1;
parameter   clk0_multiply_by        = 1;
parameter   clk5_divide_by          = 1;
parameter   clk4_divide_by          = 1;
parameter   clk3_divide_by          = 1;
parameter   clk2_divide_by          = 1;
parameter   clk1_divide_by          = 1;
parameter   clk0_divide_by          = 1;
parameter   clk5_phase_shift        = "0";
parameter   clk4_phase_shift        = "0";
parameter   clk3_phase_shift        = "0";
parameter   clk2_phase_shift        = "0";
parameter   clk1_phase_shift        = "0";
parameter   clk0_phase_shift        = "0";
// the 3 phase_shift_num parameters are for altlvds use only
parameter   clk2_phase_shift_num    = 0;
parameter   clk1_phase_shift_num    = 0;
parameter   clk0_phase_shift_num    = 0;
parameter   clk5_time_delay         = "0";
parameter   clk4_time_delay         = "0";
parameter   clk3_time_delay         = "0";
parameter   clk2_time_delay         = "0";
parameter   clk1_time_delay         = "0";
parameter   clk0_time_delay         = "0";
parameter   clk5_duty_cycle         = 50;
parameter   clk4_duty_cycle         = 50;
parameter   clk3_duty_cycle         = 50;
parameter   clk2_duty_cycle         = 50;
parameter   clk1_duty_cycle         = 50;
parameter   clk0_duty_cycle         = 50;
//  external clock specifications
parameter   extclk3_multiply_by     = 1;
parameter   extclk2_multiply_by     = 1;
parameter   extclk1_multiply_by     = 1;
parameter   extclk0_multiply_by     = 1;
parameter   extclk3_divide_by       = 1;
parameter   extclk2_divide_by       = 1;
parameter   extclk1_divide_by       = 1;
parameter   extclk0_divide_by       = 1;
parameter   extclk3_phase_shift     = "0";
parameter   extclk2_phase_shift     = "0";
parameter   extclk1_phase_shift     = "0";
parameter   extclk0_phase_shift     = "0";
parameter   extclk3_time_delay      = "0";
parameter   extclk2_time_delay      = "0";
parameter   extclk1_time_delay      = "0";
parameter   extclk0_time_delay      = "0";
parameter   extclk3_duty_cycle      = 50;
parameter   extclk2_duty_cycle      = 50;
parameter   extclk1_duty_cycle      = 50;
parameter   extclk0_duty_cycle      = 50;
//  advanced user parameters
parameter   vco_min             = 0;
parameter   vco_max             = 0;
parameter   vco_center          = 0;
parameter   pfd_min             = 0;
parameter   pfd_max             = 0;
parameter   m_initial           = 1;
parameter   m                   = 0; // m must default to 0 in order for altpll to calculate advanced parameters for itself
parameter   n                   = 1;
parameter   m2                  = 1;
parameter   n2                  = 1;
parameter   ss                  = 1;
parameter   l0_high             = 1;
parameter   l1_high             = 1;
parameter   g0_high             = 1;
parameter   g1_high             = 1;
parameter   g2_high             = 1;
parameter   g3_high             = 1;
parameter   e0_high             = 1;
parameter   e1_high             = 1;
parameter   e2_high             = 1;
parameter   e3_high             = 1;
parameter   l0_low              = 1;
parameter   l1_low              = 1;
parameter   g0_low              = 1;
parameter   g1_low              = 1;
parameter   g2_low              = 1;
parameter   g3_low              = 1;
parameter   e0_low              = 1;
parameter   e1_low              = 1;
parameter   e2_low              = 1;
parameter   e3_low              = 1;
parameter   l0_initial          = 1;
parameter   l1_initial          = 1;
parameter   g0_initial          = 1;
parameter   g1_initial          = 1;
parameter   g2_initial          = 1;
parameter   g3_initial          = 1;
parameter   e0_initial          = 1;
parameter   e1_initial          = 1;
parameter   e2_initial          = 1;
parameter   e3_initial          = 1;
parameter   l0_mode             = "bypass";
parameter   l1_mode             = "bypass";
parameter   g0_mode             = "bypass";
parameter   g1_mode             = "bypass";
parameter   g2_mode             = "bypass";
parameter   g3_mode             = "bypass";
parameter   e0_mode             = "bypass";
parameter   e1_mode             = "bypass";
parameter   e2_mode             = "bypass";
parameter   e3_mode             = "bypass";
parameter   l0_ph               = 0;
parameter   l1_ph               = 0;
parameter   g0_ph               = 0;
parameter   g1_ph               = 0;
parameter   g2_ph               = 0;
parameter   g3_ph               = 0;
parameter   e0_ph               = 0;
parameter   e1_ph               = 0;
parameter   e2_ph               = 0;
parameter   e3_ph               = 0;
parameter   m_ph                = 0;
parameter   l0_time_delay       = 0;
parameter   l1_time_delay       = 0;
parameter   g0_time_delay       = 0;
parameter   g1_time_delay       = 0;
parameter   g2_time_delay       = 0;
parameter   g3_time_delay       = 0;
parameter   e0_time_delay       = 0;
parameter   e1_time_delay       = 0;
parameter   e2_time_delay       = 0;
parameter   e3_time_delay       = 0;
parameter   m_time_delay        = 0;
parameter   n_time_delay        = 0;
parameter   extclk3_counter     = "e3" ;
parameter   extclk2_counter     = "e2" ;
parameter   extclk1_counter     = "e1" ;
parameter   extclk0_counter     = "e0" ;
parameter   clk5_counter        = "l1" ;
parameter   clk4_counter        = "l0" ;
parameter   clk3_counter        = "g3" ;
parameter   clk2_counter        = "g2" ;
parameter   clk1_counter        = "g1" ;
parameter   clk0_counter        = "g0" ;
parameter   enable0_counter     = "l0";
parameter   enable1_counter     = "l0";
parameter   charge_pump_current = 2;
parameter   loop_filter_r       = "1.0";
parameter   loop_filter_c       = 5;
parameter   lpm_type            = "altpll";

// INPUT PORT DECLARATION
input       [1:0] inclk;
input       fbin;
input       pllena;
input       clkswitch;
input       areset;
input       pfdena;
input       [5:0] clkena;
input       [3:0] extclkena;
input       scanclk;
input       scanaclr;
input       scandata;

// OUTPUT PORT DECLARATION
output        [5:0] clk;
output        [3:0] extclk;
output        [1:0] clkbad;
output        activeclock;
output        clkloss;
output        locked;
output        scandataout;

// pullups
tri1 fbin_pullup;
tri1 ena_pullup;
tri1 pfdena_pullup;
tri1 [5:0] clkena_pullup;
tri1 [3:0] extclkena_pullup;

// pulldowns
tri0 [1:0] inclk_pulldown;
tri0 clkswitch_pulldown;
tri0 areset_pulldown;
tri0 scanclr_pulldown;
tri0 scandata_pulldown;

assign fbin_pullup = fbin;
assign ena_pullup = pllena;
assign pfdena_pullup = pfdena;
assign clkena_pullup = clkena;
assign extclkena_pullup = extclkena;
assign scandata_pulldown = scandata;
assign inclk_pulldown = inclk;
assign clkswitch_pulldown = clkswitch;
assign areset_pulldown = areset;
assign scanclr_pulldown = scanaclr;

// For fast mode, the stratix pll atom model will give active low signal on locked output.
// Therefore, need to invert the lock signal for fast mode as in user view, locked signal is
// always active high.
wire locked_tmp;

assign locked = ((pll_type == "fast") || (pll_type == "FAST")) ? (!locked_tmp) : locked_tmp;

// COMPONENT INSTANTIATION
altgxb_stratix_pll pll0
(
    .inclk (inclk_pulldown),
    .fbin (fbin_pullup),
    .ena (ena_pullup),
    .clkswitch (clkswitch_pulldown),
    .areset (areset_pulldown),
    .pfdena (pfdena_pullup),
    .clkena (clkena_pullup),
    .extclkena (extclkena_pullup),
    .scanclk (scanclk),
    .scanaclr (scanclr_pulldown),
    .scandata (scandata_pulldown),
    .comparator (1'b0),
    .clk (clk),
    .extclk (extclk),
    .clkbad (clkbad),
    .activeclock (activeclock),
    .locked (locked_tmp),
    .clkloss (clkloss),
    .scandataout (scandataout),
    .enable0 (),
    .enable1 ()
);
    defparam
        pll0.operation_mode         = operation_mode,
        pll0.pll_type               = pll_type,
        pll0.qualify_conf_done      = qualify_conf_done,
        pll0.compensate_clock       = compensate_clock,
        pll0.scan_chain             = scan_chain,
        pll0.primary_clock          = primary_clock,
        pll0.inclk0_input_frequency = inclk0_input_frequency,
        pll0.inclk1_input_frequency = inclk1_input_frequency,
        pll0.gate_lock_signal       = gate_lock_signal,
        pll0.gate_lock_counter      = gate_lock_counter,
        pll0.valid_lock_multiplier  = valid_lock_multiplier,
        pll0.invalid_lock_multiplier = invalid_lock_multiplier,
        pll0.switch_over_on_lossclk = switch_over_on_lossclk,
        pll0.switch_over_on_gated_lock = switch_over_on_gated_lock,
        pll0.enable_switch_over_counter = enable_switch_over_counter,
        pll0.switch_over_counter    = switch_over_counter,
        pll0.feedback_source        = feedback_source,
        pll0.bandwidth              = bandwidth,
        pll0.bandwidth_type         = bandwidth_type,
        pll0.spread_frequency       = spread_frequency,
        pll0.down_spread            = down_spread,
        pll0.simulation_type        = simulation_type,
        pll0.skip_vco               = skip_vco,

        //  internal clock specifications
        pll0.clk5_multiply_by       = clk5_multiply_by,
        pll0.clk4_multiply_by       = clk4_multiply_by,
        pll0.clk3_multiply_by       = clk3_multiply_by,
        pll0.clk2_multiply_by       = clk2_multiply_by,
        pll0.clk1_multiply_by       = clk1_multiply_by,
        pll0.clk0_multiply_by       = clk0_multiply_by,
        pll0.clk5_divide_by         = clk5_divide_by,
        pll0.clk4_divide_by         = clk4_divide_by,
        pll0.clk3_divide_by         = clk3_divide_by,
        pll0.clk2_divide_by         = clk2_divide_by,
        pll0.clk1_divide_by         = clk1_divide_by,
        pll0.clk0_divide_by         = clk0_divide_by,
        pll0.clk5_phase_shift       = clk5_phase_shift,
        pll0.clk4_phase_shift       = clk4_phase_shift,
        pll0.clk3_phase_shift       = clk3_phase_shift,
        pll0.clk2_phase_shift       = clk2_phase_shift,
        pll0.clk1_phase_shift       = clk1_phase_shift,
        pll0.clk0_phase_shift       = clk0_phase_shift,
        pll0.clk2_phase_shift_num   = clk2_phase_shift_num,
        pll0.clk1_phase_shift_num   = clk1_phase_shift_num,
        pll0.clk0_phase_shift_num   = clk0_phase_shift_num,
        pll0.clk5_time_delay        = clk5_time_delay,
        pll0.clk4_time_delay        = clk4_time_delay,
        pll0.clk3_time_delay        = clk3_time_delay,
        pll0.clk2_time_delay        = clk2_time_delay,
        pll0.clk1_time_delay        = clk1_time_delay,
        pll0.clk0_time_delay        = clk0_time_delay,
        pll0.clk5_duty_cycle        = clk5_duty_cycle,
        pll0.clk4_duty_cycle        = clk4_duty_cycle,
        pll0.clk3_duty_cycle        = clk3_duty_cycle,
        pll0.clk2_duty_cycle        = clk2_duty_cycle,
        pll0.clk1_duty_cycle        = clk1_duty_cycle,
        pll0.clk0_duty_cycle        = clk0_duty_cycle,

        //  external clock specifications
        pll0.extclk3_multiply_by    = extclk3_multiply_by,
        pll0.extclk2_multiply_by    = extclk2_multiply_by,
        pll0.extclk1_multiply_by    = extclk1_multiply_by,
        pll0.extclk0_multiply_by    = extclk0_multiply_by,
        pll0.extclk3_divide_by      = extclk3_divide_by,
        pll0.extclk2_divide_by      = extclk2_divide_by,
        pll0.extclk1_divide_by      = extclk1_divide_by,
        pll0.extclk0_divide_by      = extclk0_divide_by,
        pll0.extclk3_phase_shift    = extclk3_phase_shift,
        pll0.extclk2_phase_shift    = extclk2_phase_shift,
        pll0.extclk1_phase_shift    = extclk1_phase_shift,
        pll0.extclk0_phase_shift    = extclk0_phase_shift,
        pll0.extclk3_time_delay     = extclk3_time_delay,
        pll0.extclk2_time_delay     = extclk2_time_delay,
        pll0.extclk1_time_delay     = extclk1_time_delay,
        pll0.extclk0_time_delay     = extclk0_time_delay,
        pll0.extclk3_duty_cycle     = extclk3_duty_cycle,
        pll0.extclk2_duty_cycle     = extclk2_duty_cycle,
        pll0.extclk1_duty_cycle     = extclk1_duty_cycle,
        pll0.extclk0_duty_cycle     = extclk0_duty_cycle,

        // advanced parameters
        pll0.vco_min                = vco_min,
        pll0.vco_max                = vco_max,
        pll0.vco_center             = vco_center,
        pll0.pfd_min                = pfd_min,
        pll0.pfd_max                = pfd_max,
        pll0.m_initial              = m_initial,
        pll0.m                      = m,
        pll0.n                      = n,
        pll0.m2                     = m2,
        pll0.n2                     = n2,
        pll0.ss                     = ss,
        pll0.l0_high                = l0_high,
        pll0.l1_high                = l1_high,
        pll0.g0_high                = g0_high,
        pll0.g1_high                = g1_high,
        pll0.g2_high                = g2_high,
        pll0.g3_high                = g3_high,
        pll0.e0_high                = e0_high,
        pll0.e1_high                = e1_high,
        pll0.e2_high                = e2_high,
        pll0.e3_high                = e3_high,
        pll0.l0_low                 = l0_low,
        pll0.l1_low                 = l1_low,
        pll0.g0_low                 = g0_low,
        pll0.g1_low                 = g1_low,
        pll0.g2_low                 = g2_low,
        pll0.g3_low                 = g3_low,
        pll0.e0_low                 = e0_low,
        pll0.e1_low                 = e1_low,
        pll0.e2_low                 = e2_low,
        pll0.e3_low                 = e3_low,
        pll0.l0_initial             = l0_initial,
        pll0.l1_initial             = l1_initial,
        pll0.g0_initial             = g0_initial,
        pll0.g1_initial             = g1_initial,
        pll0.g2_initial             = g2_initial,
        pll0.g3_initial             = g3_initial,
        pll0.e0_initial             = e0_initial,
        pll0.e1_initial             = e1_initial,
        pll0.e2_initial             = e2_initial,
        pll0.e3_initial             = e3_initial,
        pll0.l0_mode                = l0_mode,
        pll0.l1_mode                = l1_mode,
        pll0.g0_mode                = g0_mode,
        pll0.g1_mode                = g1_mode,
        pll0.g2_mode                = g2_mode,
        pll0.g3_mode                = g3_mode,
        pll0.e0_mode                = e0_mode,
        pll0.e1_mode                = e1_mode,
        pll0.e2_mode                = e2_mode,
        pll0.e3_mode                = e3_mode,
        pll0.l0_ph                  = l0_ph,
        pll0.l1_ph                  = l1_ph,
        pll0.g0_ph                  = g0_ph,
        pll0.g1_ph                  = g1_ph,
        pll0.g2_ph                  = g2_ph,
        pll0.g3_ph                  = g3_ph,
        pll0.e0_ph                  = e0_ph,
        pll0.e1_ph                  = e1_ph,
        pll0.e2_ph                  = e2_ph,
        pll0.e3_ph                  = e3_ph,
        pll0.m_ph                   = m_ph,
        pll0.l0_time_delay          = l0_time_delay,
        pll0.l1_time_delay          = l1_time_delay,
        pll0.g0_time_delay          = g0_time_delay,
        pll0.g1_time_delay          = g1_time_delay,
        pll0.g2_time_delay          = g2_time_delay,
        pll0.g3_time_delay          = g3_time_delay,
        pll0.e0_time_delay          = e0_time_delay,
        pll0.e1_time_delay          = e1_time_delay,
        pll0.e2_time_delay          = e2_time_delay,
        pll0.e3_time_delay          = e3_time_delay,
        pll0.m_time_delay           = m_time_delay,
        pll0.n_time_delay           = n_time_delay,
        pll0.extclk3_counter        = extclk3_counter,
        pll0.extclk2_counter        = extclk2_counter,
        pll0.extclk1_counter        = extclk1_counter,
        pll0.extclk0_counter        = extclk0_counter,
        pll0.clk5_counter           = clk5_counter,
        pll0.clk4_counter           = clk4_counter,
        pll0.clk3_counter           = clk3_counter,
        pll0.clk2_counter           = clk2_counter,
        pll0.clk1_counter           = clk1_counter,
        pll0.clk0_counter           = clk0_counter,
        pll0.enable0_counter        = enable0_counter,
        pll0.enable1_counter        = enable1_counter,
        pll0.charge_pump_current    = charge_pump_current,
        pll0.loop_filter_r          = loop_filter_r,
        pll0.loop_filter_c          = loop_filter_c;

endmodule //altgxb_pll



///////////////////////////////////////////////////////////////////////////////
//
//                         end of altgxb_pll
//
///////////////////////////////////////////////////////////////////////////////
//IP Functional Simulation Model
//VERSION_BEGIN 4.1 cbx_mgl 2004:06:17:17:30:06:SJ cbx_simgen 2004:06:22:10:53:08:SJ  VERSION_END


// Legal Notice: � 2003 Altera Corporation. All rights reserved.
// You may only use these  simulation  model  output files for simulation
// purposes and expressly not for synthesis or any other purposes (in which
// event  Altera disclaims all warranties of any kind). Your use of  Altera
// Corporation's design tools, logic functions and other software and tools,
// and its AMPP partner logic functions, and any output files any of the
// foregoing (including device programming or simulation files), and any
// associated documentation or information  are expressly subject to the
// terms and conditions of the  Altera Program License Subscription Agreement
// or other applicable license agreement, including, without limitation, that
// your use is for the sole purpose of programming logic devices manufactured
// by Altera and sold by Altera or its authorized distributors.  Please refer
// to the applicable agreement for further details.


//synopsys translate_off

//synthesis_resources = lut 137 mux21 348 
`timescale 1 ps / 1 ps
module  altgxb_xgm_rx_sm
	( 
	resetall,
	rxclk,
	rxctrl,
	rxctrlout,
	rxdatain,
	rxdataout,
	rxdatavalid,
	rxrunningdisp) /* synthesis synthesis_clearbox=1 */;
	input   resetall;
	input   rxclk;
	input   [3:0]  rxctrl;
	output   [3:0]  rxctrlout;
	input   [31:0]  rxdatain;
	output   [31:0]  rxdataout;
	input   [3:0]  rxdatavalid;
	input   [3:0]  rxrunningdisp;

	reg	n000i;
	reg	n000l;
	reg	n000O;
	reg	n00ii;
	reg	n00il;
	reg	n00iO;
	reg	n00li;
	reg	n0li;
	reg	n0ll;
	reg	n0OO;
	reg	n110i;
	reg	n110l;
	reg	n110O;
	reg	n111i;
	reg	n111l;
	reg	n111O;
	reg	n11ii;
	reg	n11il;
	reg	n1lOi;
	reg	n1lOl;
	reg	n1lOO;
	reg	n1O1i;
	reg	n1O1l;
	reg	ni10O;
	reg	ni1ii;
	reg	ni1il;
	reg	ni1iO;
	reg	ni1li;
	reg	ni1ll;
	reg	ni1lO;
	reg	ni1Oi;
	reg	ni1Ol;
	reg	niOli;
	reg	niOll;
	reg	niOlO;
	reg	niOOi;
	reg	niOOl;
	reg	niOOO;
	reg	nl0i0i58;
	reg	nl0i0i59;
	reg	nl0i0i60;
	reg	nl0iiO55;
	reg	nl0iiO56;
	reg	nl0iiO57;
	reg	nl0iOl52;
	reg	nl0iOl53;
	reg	nl0iOl54;
	reg	nl0l0l46;
	reg	nl0l0l47;
	reg	nl0l0l48;
	reg	nl0l1l49;
	reg	nl0l1l50;
	reg	nl0l1l51;
	reg	nl0liO43;
	reg	nl0liO44;
	reg	nl0liO45;
	reg	nl0llO40;
	reg	nl0llO41;
	reg	nl0llO42;
	reg	nl0lOO37;
	reg	nl0lOO38;
	reg	nl0lOO39;
	reg	nl0O0i34;
	reg	nl0O0i35;
	reg	nl0O0i36;
	reg	nl0O0O31;
	reg	nl0O0O32;
	reg	nl0O0O33;
	reg	nl0Oil28;
	reg	nl0Oil29;
	reg	nl0Oil30;
	reg	nl0Oll25;
	reg	nl0Oll26;
	reg	nl0Oll27;
	reg	nl0OOl22;
	reg	nl0OOl23;
	reg	nl0OOl24;
	reg	nl11i;
	reg	nl11l;
	reg	nl11O;
	reg	nli00i10;
	reg	nli00i11;
	reg	nli00i12;
	reg	nli0il7;
	reg	nli0il8;
	reg	nli0il9;
	reg	nli0ll4;
	reg	nli0ll5;
	reg	nli0ll6;
	reg	nli11O19;
	reg	nli11O20;
	reg	nli11O21;
	reg	nli1ii16;
	reg	nli1ii17;
	reg	nli1ii18;
	reg	nli1li13;
	reg	nli1li14;
	reg	nli1li15;
	reg	nlii1i1;
	reg	nlii1i2;
	reg	nlii1i3;
	reg	nllilO;
	reg	nlliOi;
	reg	nlliOl;
	reg	nlliOO;
	reg	nlll0i;
	reg	nlll0l;
	reg	nlll0O;
	reg	nlll1i;
	reg	nlll1l;
	reg	nlll1O;
	reg	nlllii;
	reg	nlllil;
	reg	nllliO;
	reg	nlllli;
	reg	nlllll;
	reg	nllllO;
	reg	nlllOi;
	reg	nlllOl;
	reg	nlllOO;
	reg	nllO1i;
	reg	nllO1l;
	reg	nllOl;
	reg	nllOO;
	reg	nlO00i;
	reg	nlO00l;
	reg	nlO00O;
	reg	nlO01O;
	reg	nlO0ii;
	reg	nlO0il;
	reg	nlO0iO;
	reg	nlO0li;
	reg	nlO0ll;
	reg	nlO1i;
	reg	nlO1l;
	reg	nlO1O;
	reg	nlOOOO;
	wire	wire_n00i_dataout;
	wire	wire_n00l_dataout;
	wire	wire_n00ll_dataout;
	wire	wire_n00lO_dataout;
	wire	wire_n00O_dataout;
	wire	wire_n00Oi_dataout;
	wire	wire_n00Ol_dataout;
	wire	wire_n00OO_dataout;
	wire	wire_n010i_dataout;
	wire	wire_n010l_dataout;
	wire	wire_n010O_dataout;
	wire	wire_n011i_dataout;
	wire	wire_n011l_dataout;
	wire	wire_n011O_dataout;
	wire	wire_n01i_dataout;
	wire	wire_n01ii_dataout;
	wire	wire_n01il_dataout;
	wire	wire_n01iO_dataout;
	wire	wire_n01l_dataout;
	wire	wire_n01li_dataout;
	wire	wire_n01ll_dataout;
	wire	wire_n01lO_dataout;
	wire	wire_n01O_dataout;
	wire	wire_n01Oi_dataout;
	wire	wire_n01Ol_dataout;
	wire	wire_n0i0i_dataout;
	wire	wire_n0i0l_dataout;
	wire	wire_n0i0O_dataout;
	wire	wire_n0i1i_dataout;
	wire	wire_n0i1l_dataout;
	wire	wire_n0i1O_dataout;
	wire	wire_n0ii_dataout;
	wire	wire_n0iii_dataout;
	wire	wire_n0iil_dataout;
	wire	wire_n0iiO_dataout;
	wire	wire_n0il_dataout;
	wire	wire_n0ili_dataout;
	wire	wire_n0ill_dataout;
	wire	wire_n0ilO_dataout;
	wire	wire_n0iO_dataout;
	wire	wire_n0iOi_dataout;
	wire	wire_n0iOl_dataout;
	wire	wire_n0iOO_dataout;
	wire	wire_n0l0i_dataout;
	wire	wire_n0l0l_dataout;
	wire	wire_n0l0O_dataout;
	wire	wire_n0l1i_dataout;
	wire	wire_n0l1l_dataout;
	wire	wire_n0l1O_dataout;
	wire	wire_n0lii_dataout;
	wire	wire_n0lil_dataout;
	wire	wire_n0liO_dataout;
	wire	wire_n0lli_dataout;
	wire	wire_n0lll_dataout;
	wire	wire_n0llO_dataout;
	wire	wire_n0lO_dataout;
	wire	wire_n0lOi_dataout;
	wire	wire_n0lOl_dataout;
	wire	wire_n0lOO_dataout;
	wire	wire_n0O0i_dataout;
	wire	wire_n0O0l_dataout;
	wire	wire_n0O0O_dataout;
	wire	wire_n0O1i_dataout;
	wire	wire_n0O1l_dataout;
	wire	wire_n0O1O_dataout;
	wire	wire_n0Oi_dataout;
	wire	wire_n0Oii_dataout;
	wire	wire_n0Oil_dataout;
	wire	wire_n0OiO_dataout;
	wire	wire_n0Oli_dataout;
	wire	wire_n0Oll_dataout;
	wire	wire_n0OlO_dataout;
	wire	wire_n0OOi_dataout;
	wire	wire_n0OOl_dataout;
	wire	wire_n0OOO_dataout;
	wire	wire_n100i_dataout;
	wire	wire_n100l_dataout;
	wire	wire_n100O_dataout;
	wire	wire_n101i_dataout;
	wire	wire_n101l_dataout;
	wire	wire_n101O_dataout;
	wire	wire_n10i_dataout;
	wire	wire_n10ii_dataout;
	wire	wire_n10il_dataout;
	wire	wire_n10iO_dataout;
	wire	wire_n10l_dataout;
	wire	wire_n10li_dataout;
	wire	wire_n10ll_dataout;
	wire	wire_n10lO_dataout;
	wire	wire_n10O_dataout;
	wire	wire_n10Oi_dataout;
	wire	wire_n10Ol_dataout;
	wire	wire_n10OO_dataout;
	wire	wire_n11i_dataout;
	wire	wire_n11iO_dataout;
	wire	wire_n11l_dataout;
	wire	wire_n11li_dataout;
	wire	wire_n11ll_dataout;
	wire	wire_n11lO_dataout;
	wire	wire_n11O_dataout;
	wire	wire_n11Oi_dataout;
	wire	wire_n11Ol_dataout;
	wire	wire_n11OO_dataout;
	wire	wire_n1i0i_dataout;
	wire	wire_n1i0l_dataout;
	wire	wire_n1i0O_dataout;
	wire	wire_n1i1i_dataout;
	wire	wire_n1i1l_dataout;
	wire	wire_n1i1O_dataout;
	wire	wire_n1ii_dataout;
	wire	wire_n1iii_dataout;
	wire	wire_n1iil_dataout;
	wire	wire_n1iiO_dataout;
	wire	wire_n1il_dataout;
	wire	wire_n1ili_dataout;
	wire	wire_n1ill_dataout;
	wire	wire_n1ilO_dataout;
	wire	wire_n1iO_dataout;
	wire	wire_n1iOi_dataout;
	wire	wire_n1iOl_dataout;
	wire	wire_n1l0i_dataout;
	wire	wire_n1l0l_dataout;
	wire	wire_n1l0O_dataout;
	wire	wire_n1l1O_dataout;
	wire	wire_n1li_dataout;
	wire	wire_n1lii_dataout;
	wire	wire_n1lil_dataout;
	wire	wire_n1liO_dataout;
	wire	wire_n1ll_dataout;
	wire	wire_n1lli_dataout;
	wire	wire_n1lll_dataout;
	wire	wire_n1lO_dataout;
	wire	wire_n1O0i_dataout;
	wire	wire_n1O0l_dataout;
	wire	wire_n1O0O_dataout;
	wire	wire_n1O1O_dataout;
	wire	wire_n1Oi_dataout;
	wire	wire_n1Oii_dataout;
	wire	wire_n1Oil_dataout;
	wire	wire_n1OiO_dataout;
	wire	wire_n1Ol_dataout;
	wire	wire_n1Oli_dataout;
	wire	wire_n1Oll_dataout;
	wire	wire_n1OlO_dataout;
	wire	wire_n1OO_dataout;
	wire	wire_n1OOi_dataout;
	wire	wire_n1OOl_dataout;
	wire	wire_n1OOO_dataout;
	wire	wire_ni00i_dataout;
	wire	wire_ni00l_dataout;
	wire	wire_ni00O_dataout;
	wire	wire_ni01i_dataout;
	wire	wire_ni01l_dataout;
	wire	wire_ni01O_dataout;
	wire	wire_ni0i_dataout;
	wire	wire_ni0ii_dataout;
	wire	wire_ni0il_dataout;
	wire	wire_ni0iO_dataout;
	wire	wire_ni0li_dataout;
	wire	wire_ni0ll_dataout;
	wire	wire_ni0lO_dataout;
	wire	wire_ni0Oi_dataout;
	wire	wire_ni0Ol_dataout;
	wire	wire_ni0OO_dataout;
	wire	wire_ni10i_dataout;
	wire	wire_ni11i_dataout;
	wire	wire_ni11l_dataout;
	wire	wire_ni11O_dataout;
	wire	wire_ni1i_dataout;
	wire	wire_ni1l_dataout;
	wire	wire_ni1O_dataout;
	wire	wire_ni1OO_dataout;
	wire	wire_nii0i_dataout;
	wire	wire_nii0l_dataout;
	wire	wire_nii0O_dataout;
	wire	wire_nii1i_dataout;
	wire	wire_nii1l_dataout;
	wire	wire_nii1O_dataout;
	wire	wire_niiii_dataout;
	wire	wire_niiil_dataout;
	wire	wire_niiiO_dataout;
	wire	wire_niili_dataout;
	wire	wire_niill_dataout;
	wire	wire_niilO_dataout;
	wire	wire_niiOi_dataout;
	wire	wire_niiOl_dataout;
	wire	wire_niiOO_dataout;
	wire	wire_nil0i_dataout;
	wire	wire_nil0l_dataout;
	wire	wire_nil0O_dataout;
	wire	wire_nil1i_dataout;
	wire	wire_nil1l_dataout;
	wire	wire_nil1O_dataout;
	wire	wire_nilii_dataout;
	wire	wire_nilil_dataout;
	wire	wire_niliO_dataout;
	wire	wire_nilli_dataout;
	wire	wire_nilll_dataout;
	wire	wire_nillO_dataout;
	wire	wire_nilOi_dataout;
	wire	wire_nilOl_dataout;
	wire	wire_nilOO_dataout;
	wire	wire_niO0i_dataout;
	wire	wire_niO0l_dataout;
	wire	wire_niO0O_dataout;
	wire	wire_niO1i_dataout;
	wire	wire_niO1l_dataout;
	wire	wire_niO1O_dataout;
	wire	wire_niOii_dataout;
	wire	wire_niOil_dataout;
	wire	wire_nl00i_dataout;
	wire	wire_nl00l_dataout;
	wire	wire_nl00O_dataout;
	wire	wire_nl01i_dataout;
	wire	wire_nl01l_dataout;
	wire	wire_nl01O_dataout;
	wire	wire_nl0ii_dataout;
	wire	wire_nl0il_dataout;
	wire	wire_nl0iO_dataout;
	wire	wire_nl0li_dataout;
	wire	wire_nl0ll_dataout;
	wire	wire_nl0lO_dataout;
	wire	wire_nl0Oi_dataout;
	wire	wire_nl0Ol_dataout;
	wire	wire_nl0OO_dataout;
	wire	wire_nl10i_dataout;
	wire	wire_nl10l_dataout;
	wire	wire_nl10O_dataout;
	wire	wire_nl1ii_dataout;
	wire	wire_nl1il_dataout;
	wire	wire_nl1iO_dataout;
	wire	wire_nl1li_dataout;
	wire	wire_nl1ll_dataout;
	wire	wire_nl1lO_dataout;
	wire	wire_nl1Oi_dataout;
	wire	wire_nl1Ol_dataout;
	wire	wire_nl1OO_dataout;
	wire	wire_nli0i_dataout;
	wire	wire_nli0l_dataout;
	wire	wire_nli0O_dataout;
	wire	wire_nli1i_dataout;
	wire	wire_nli1l_dataout;
	wire	wire_nli1O_dataout;
	wire	wire_nliii_dataout;
	wire	wire_nliil_dataout;
	wire	wire_nliiO_dataout;
	wire	wire_nlili_dataout;
	wire	wire_nlill_dataout;
	wire	wire_nlilO_dataout;
	wire	wire_nliOi_dataout;
	wire	wire_nliOl_dataout;
	wire	wire_nliOO_dataout;
	wire	wire_nll0i_dataout;
	wire	wire_nll0l_dataout;
	wire	wire_nll0O_dataout;
	wire	wire_nll1i_dataout;
	wire	wire_nll1l_dataout;
	wire	wire_nll1O_dataout;
	wire	wire_nllii_dataout;
	wire	wire_nllil_dataout;
	wire	wire_nlliO_dataout;
	wire	wire_nllli_dataout;
	wire	wire_nllll_dataout;
	wire	wire_nlllO_dataout;
	wire	wire_nllO0i_dataout;
	wire	wire_nllO0l_dataout;
	wire	wire_nllO0O_dataout;
	wire	wire_nllO1O_dataout;
	wire	wire_nllOii_dataout;
	wire	wire_nllOil_dataout;
	wire	wire_nllOiO_dataout;
	wire	wire_nllOli_dataout;
	wire	wire_nllOll_dataout;
	wire	wire_nllOlO_dataout;
	wire	wire_nllOOi_dataout;
	wire	wire_nllOOl_dataout;
	wire	wire_nllOOO_dataout;
	wire	wire_nlO0i_dataout;
	wire	wire_nlO0l_dataout;
	wire	wire_nlO0lO_dataout;
	wire	wire_nlO0O_dataout;
	wire	wire_nlO0Oi_dataout;
	wire	wire_nlO0Ol_dataout;
	wire	wire_nlO0OO_dataout;
	wire	wire_nlO10i_dataout;
	wire	wire_nlO10l_dataout;
	wire	wire_nlO10O_dataout;
	wire	wire_nlO11i_dataout;
	wire	wire_nlO11l_dataout;
	wire	wire_nlO11O_dataout;
	wire	wire_nlO1ii_dataout;
	wire	wire_nlO1il_dataout;
	wire	wire_nlO1iO_dataout;
	wire	wire_nlO1li_dataout;
	wire	wire_nlO1ll_dataout;
	wire	wire_nlO1lO_dataout;
	wire	wire_nlO1Oi_dataout;
	wire	wire_nlO1Ol_dataout;
	wire	wire_nlOi0i_dataout;
	wire	wire_nlOi0l_dataout;
	wire	wire_nlOi0O_dataout;
	wire	wire_nlOi1i_dataout;
	wire	wire_nlOi1l_dataout;
	wire	wire_nlOi1O_dataout;
	wire	wire_nlOii_dataout;
	wire	wire_nlOiii_dataout;
	wire	wire_nlOiil_dataout;
	wire	wire_nlOiiO_dataout;
	wire	wire_nlOil_dataout;
	wire	wire_nlOili_dataout;
	wire	wire_nlOill_dataout;
	wire	wire_nlOilO_dataout;
	wire	wire_nlOiO_dataout;
	wire	wire_nlOiOi_dataout;
	wire	wire_nlOiOl_dataout;
	wire	wire_nlOiOO_dataout;
	wire	wire_nlOl0i_dataout;
	wire	wire_nlOl0l_dataout;
	wire	wire_nlOl0O_dataout;
	wire	wire_nlOl1i_dataout;
	wire	wire_nlOl1l_dataout;
	wire	wire_nlOl1O_dataout;
	wire	wire_nlOli_dataout;
	wire	wire_nlOlii_dataout;
	wire	wire_nlOlil_dataout;
	wire	wire_nlOliO_dataout;
	wire	wire_nlOll_dataout;
	wire	wire_nlOlli_dataout;
	wire	wire_nlOlll_dataout;
	wire	wire_nlOllO_dataout;
	wire	wire_nlOlO_dataout;
	wire	wire_nlOlOi_dataout;
	wire	wire_nlOlOl_dataout;
	wire	wire_nlOlOO_dataout;
	wire	wire_nlOO0l_dataout;
	wire	wire_nlOO0O_dataout;
	wire	wire_nlOO1i_dataout;
	wire	wire_nlOO1l_dataout;
	wire	wire_nlOOi_dataout;
	wire	wire_nlOOii_dataout;
	wire	wire_nlOOil_dataout;
	wire	wire_nlOOiO_dataout;
	wire	wire_nlOOl_dataout;
	wire	wire_nlOOli_dataout;
	wire	wire_nlOOll_dataout;
	wire	wire_nlOOlO_dataout;
	wire	wire_nlOOO_dataout;
	wire	wire_nlOOOi_dataout;
	wire  nl00ll;
	wire  nl00lO;
	wire  nl00Oi;
	wire  nl00Ol;
	wire  nl00OO;
	wire  nl0i0O;
	wire  nl0i1i;
	wire  nl0i1l;
	wire  nl0i1O;
	wire  nl0iii;
	wire  nl0iil;
	wire  nl0ill;
	wire  nl0ilO;
	wire  nl0iOi;
	wire  nl0l0i;
	wire  nl0l1i;
	wire  nl0lii;
	wire  nl0lil;
	wire  nl0lll;
	wire  nl0lOl;
	wire  nl0O1l;
	wire  nl0O1O;
	wire  nl0Oli;
	wire  nl0OOi;
	wire  nli00O;
	wire  nli01i;
	wire  nli01l;
	wire  nli01O;
	wire  nli0ii;
	wire  nli0li;
	wire  nli0Oi;
	wire  nli0Ol;
	wire  nli0OO;
	wire  nli10l;
	wire  nli10O;
	wire  nli11i;
	wire  nli11l;
	wire  nli1iO;
	wire  nli1lO;
	wire  nli1Oi;
	wire  nli1Ol;
	wire  nli1OO;
	wire  w_nl0i0i320w;
	wire  w_nl0iiO310w;
	wire  w_nl0iOl297w;
	wire  w_nl0l0l267w;
	wire  w_nl0l1l280w;
	wire  w_nl0liO252w;
	wire  w_nl0llO245w;
	wire  w_nl0lOO233w;
	wire  w_nl0O0i209w;
	wire  w_nl0O0O201w;
	wire  w_nl0Oil191w;
	wire  w_nl0Oll183w;
	wire  w_nl0OOl176w;
	wire  w_nli00i87w;
	wire  w_nli0il59w;
	wire  w_nli0ll51w;
	wire  w_nli11O167w;
	wire  w_nli1ii147w;
	wire  w_nli1li141w;
	wire  w_nlii1i23w;

	initial
		n000i = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n000i <= 1'b0;
		else   n000i <= wire_n00ll_dataout;
	initial
		n000l = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n000l <= 1'b0;
		else   n000l <= wire_n00Oi_dataout;
	initial
		n000O = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n000O <= 1'b0;
		else   n000O <= wire_n00Ol_dataout;
	initial
		n00ii = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n00ii <= 1'b0;
		else   n00ii <= wire_n00OO_dataout;
	initial
		n00il = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n00il <= 1'b0;
		else   n00il <= wire_n0i1i_dataout;
	initial
		n00iO = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n00iO <= 1'b0;
		else   n00iO <= wire_n0i1l_dataout;
	initial
		n00li = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n00li <= 1'b0;
		else   n00li <= wire_n0i1O_dataout;
	initial
		n0li = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n0li <= 1'b0;
		else   n0li <= ((~ wire_ni0i_dataout) & (rxctrl[3:3] & (~ nl0l1i)));
	initial
		n0ll = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n0ll <= 1'b0;
		else   n0ll <= nl0l0i;
	initial
		n0OO = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n0OO <= 1'b0;
		else   n0OO <= nl0lil;
	initial
		n110i = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n110i <= 1'b0;
		else   n110i <= wire_n11lO_dataout;
	initial
		n110l = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n110l <= 1'b0;
		else   n110l <= wire_n11Oi_dataout;
	initial
		n110O = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n110O <= 1'b0;
		else   n110O <= wire_n11Ol_dataout;
	initial
		n111i = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n111i <= 1'b0;
		else   n111i <= wire_n11iO_dataout;
	initial
		n111l = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n111l <= 1'b0;
		else   n111l <= wire_n11li_dataout;
	initial
		n111O = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n111O <= 1'b0;
		else   n111O <= wire_n11ll_dataout;
	initial
		n11ii = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n11ii <= 1'b0;
		else   n11ii <= wire_n11OO_dataout;
	initial
		n11il = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n11il <= 1'b0;
		else   n11il <= wire_n101i_dataout;
	initial
		n1lOi = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n1lOi <= 1'b0;
		else   n1lOi <= wire_n101l_dataout;
	initial
		n1lOl = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n1lOl <= 1'b0;
		else   n1lOl <= wire_n1O0i_dataout;
	initial
		n1lOO = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n1lOO <= 1'b0;
		else   n1lOO <= wire_n1O0l_dataout;
	initial
		n1O1i = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n1O1i <= 1'b0;
		else   n1O1i <= wire_n1OiO_dataout;
	initial
		n1O1l = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) n1O1l <= 1'b0;
		else   n1O1l <= wire_n1Oli_dataout;
	initial
		ni10O = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) ni10O <= 1'b0;
		else   ni10O <= wire_n0i0i_dataout;
	initial
		ni1ii = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) ni1ii <= 1'b0;
		else   ni1ii <= wire_ni1OO_dataout;
	initial
		ni1il = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) ni1il <= 1'b0;
		else   ni1il <= wire_ni01i_dataout;
	initial
		ni1iO = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) ni1iO <= 1'b0;
		else   ni1iO <= wire_ni01l_dataout;
	initial
		ni1li = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) ni1li <= 1'b0;
		else   ni1li <= wire_ni01O_dataout;
	initial
		ni1ll = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) ni1ll <= 1'b0;
		else   ni1ll <= wire_ni00i_dataout;
	initial
		ni1lO = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) ni1lO <= 1'b0;
		else   ni1lO <= wire_ni00l_dataout;
	initial
		ni1Oi = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) ni1Oi <= 1'b0;
		else   ni1Oi <= wire_ni00O_dataout;
	initial
		ni1Ol = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) ni1Ol <= 1'b0;
		else   ni1Ol <= wire_ni0ii_dataout;
	initial
		niOli = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) niOli <= 1'b0;
		else   niOli <= wire_ni0il_dataout;
	initial
		niOll = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) niOll <= 1'b0;
		else   niOll <= wire_nl10i_dataout;
	initial
		niOlO = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) niOlO <= 1'b0;
		else   niOlO <= wire_nl10l_dataout;
	initial
		niOOi = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) niOOi <= 1'b0;
		else   niOOi <= wire_nl10O_dataout;
	initial
		niOOl = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) niOOl <= 1'b0;
		else   niOOl <= wire_nl1ii_dataout;
	initial
		niOOO = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) niOOO <= 1'b0;
		else   niOOO <= wire_nl1il_dataout;
	initial
		nl0i0i58 = 1'b1;
	always @ ( posedge nli0OO)
		  nl0i0i58 <= nl0i0i59;
	initial
		nl0i0i59 = 0;
	always @ ( posedge nli0OO)
		  nl0i0i59 <= nl0i0i58;
	initial
		nl0i0i60 = 0;
	always @ ( posedge nli0OO)
		  nl0i0i60 <= (nl0i0i59 ^ nl0i0i58);
	initial
		nl0iiO55 = 1'b1;
	always @ ( posedge nli0OO)
		  nl0iiO55 <= nl0iiO56;
	initial
		nl0iiO56 = 0;
	always @ ( posedge nli0OO)
		  nl0iiO56 <= nl0iiO55;
	initial
		nl0iiO57 = 0;
	always @ ( posedge nli0OO)
		  nl0iiO57 <= (nl0iiO56 ^ nl0iiO55);
	initial
		nl0iOl52 = 1'b1;
	always @ ( posedge nli0OO)
		  nl0iOl52 <= nl0iOl53;
	initial
		nl0iOl53 = 0;
	always @ ( posedge nli0OO)
		  nl0iOl53 <= nl0iOl52;
	initial
		nl0iOl54 = 0;
	always @ ( posedge nli0OO)
		  nl0iOl54 <= (nl0iOl53 ^ nl0iOl52);
	initial
		nl0l0l46 = 1'b1;
	always @ ( posedge nli0OO)
		  nl0l0l46 <= nl0l0l47;
	initial
		nl0l0l47 = 0;
	always @ ( posedge nli0OO)
		  nl0l0l47 <= nl0l0l46;
	initial
		nl0l0l48 = 0;
	always @ ( posedge nli0OO)
		  nl0l0l48 <= (nl0l0l47 ^ nl0l0l46);
	initial
		nl0l1l49 = 1'b1;
	always @ ( posedge nli0OO)
		  nl0l1l49 <= nl0l1l50;
	initial
		nl0l1l50 = 0;
	always @ ( posedge nli0OO)
		  nl0l1l50 <= nl0l1l49;
	initial
		nl0l1l51 = 0;
	always @ ( posedge nli0OO)
		  nl0l1l51 <= (nl0l1l50 ^ nl0l1l49);
	initial
		nl0liO43 = 1'b1;
	always @ ( posedge nli0OO)
		  nl0liO43 <= nl0liO44;
	initial
		nl0liO44 = 0;
	always @ ( posedge nli0OO)
		  nl0liO44 <= nl0liO43;
	initial
		nl0liO45 = 0;
	always @ ( posedge nli0OO)
		  nl0liO45 <= (nl0liO44 ^ nl0liO43);
	initial
		nl0llO40 = 1'b1;
	always @ ( posedge nli0OO)
		  nl0llO40 <= nl0llO41;
	initial
		nl0llO41 = 0;
	always @ ( posedge nli0OO)
		  nl0llO41 <= nl0llO40;
	initial
		nl0llO42 = 0;
	always @ ( posedge nli0OO)
		  nl0llO42 <= (nl0llO41 ^ nl0llO40);
	initial
		nl0lOO37 = 1'b1;
	always @ ( posedge nli0OO)
		  nl0lOO37 <= nl0lOO38;
	initial
		nl0lOO38 = 0;
	always @ ( posedge nli0OO)
		  nl0lOO38 <= nl0lOO37;
	initial
		nl0lOO39 = 0;
	always @ ( posedge nli0OO)
		  nl0lOO39 <= (nl0lOO38 ^ nl0lOO37);
	initial
		nl0O0i34 = 1'b1;
	always @ ( posedge nli0OO)
		  nl0O0i34 <= nl0O0i35;
	initial
		nl0O0i35 = 0;
	always @ ( posedge nli0OO)
		  nl0O0i35 <= nl0O0i34;
	initial
		nl0O0i36 = 0;
	always @ ( posedge nli0OO)
		  nl0O0i36 <= (nl0O0i35 ^ nl0O0i34);
	initial
		nl0O0O31 = 1'b1;
	always @ ( posedge nli0OO)
		  nl0O0O31 <= nl0O0O32;
	initial
		nl0O0O32 = 0;
	always @ ( posedge nli0OO)
		  nl0O0O32 <= nl0O0O31;
	initial
		nl0O0O33 = 0;
	always @ ( posedge nli0OO)
		  nl0O0O33 <= (nl0O0O32 ^ nl0O0O31);
	initial
		nl0Oil28 = 1'b1;
	always @ ( posedge nli0OO)
		  nl0Oil28 <= nl0Oil29;
	initial
		nl0Oil29 = 0;
	always @ ( posedge nli0OO)
		  nl0Oil29 <= nl0Oil28;
	initial
		nl0Oil30 = 0;
	always @ ( posedge nli0OO)
		  nl0Oil30 <= (nl0Oil29 ^ nl0Oil28);
	initial
		nl0Oll25 = 1'b1;
	always @ ( posedge nli0OO)
		  nl0Oll25 <= nl0Oll26;
	initial
		nl0Oll26 = 0;
	always @ ( posedge nli0OO)
		  nl0Oll26 <= nl0Oll25;
	initial
		nl0Oll27 = 0;
	always @ ( posedge nli0OO)
		  nl0Oll27 <= (nl0Oll26 ^ 
		nl0Oll25);
	initial
		nl0OOl22 = 1'b1;
	always @ ( posedge nli0OO)
		  nl0OOl22 <= nl0OOl23;
	initial
		nl0OOl23 = 0;
	always @ ( posedge nli0OO)
		  nl0OOl23 <= nl0OOl22;
	initial
		nl0OOl24 = 0;
	always @ ( posedge nli0OO)
		  nl0OOl24 <= (nl0OOl23 ^ nl0OOl22);
	initial
		nl11i = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nl11i <= 1'b0;
		else   nl11i <= wire_nl1iO_dataout;
	initial
		nl11l = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nl11l <= 1'b0;
		else   nl11l <= wire_nl1li_dataout;
	initial
		nl11O = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nl11O <= 1'b0;
		else   nl11O <= wire_nl1ll_dataout;
	initial
		nli00i10 = 1'b1;
	always @ ( posedge nli0OO)
		  nli00i10 <= nli00i11;
	initial
		nli00i11 = 0;
	always @ ( posedge nli0OO)
		  nli00i11 <= nli00i10;
	initial
		nli00i12 = 0;
	always @ ( posedge nli0OO)
		  nli00i12 <= (nli00i11 ^ nli00i10);
	initial
		nli0il7 = 1'b1;
	always @ ( posedge nli0OO)
		  nli0il7 <= nli0il8;
	initial
		nli0il8 = 0;
	always @ ( posedge nli0OO)
		  nli0il8 <= nli0il7;
	initial
		nli0il9 = 0;
	always @ ( posedge nli0OO)
		  nli0il9 <= (nli0il8 ^ nli0il7);
	initial
		nli0ll4 = 1'b1;
	always @ ( posedge nli0OO)
		  nli0ll4 <= nli0ll5;
	initial
		nli0ll5 = 0;
	always @ ( posedge nli0OO)
		  nli0ll5 <= nli0ll4;
	initial
		nli0ll6 = 0;
	always @ ( posedge nli0OO)
		  nli0ll6 <= (nli0ll5 ^ nli0ll4);
	initial
		nli11O19 = 1'b1;
	always @ ( posedge nli0OO)
		  nli11O19 <= nli11O20;
	initial
		nli11O20 = 0;
	always @ ( posedge nli0OO)
		  nli11O20 <= nli11O19;
	initial
		nli11O21 = 0;
	always @ ( posedge nli0OO)
		  nli11O21 <= (nli11O20 ^ nli11O19);
	initial
		nli1ii16 = 1'b1;
	always @ ( posedge nli0OO)
		  nli1ii16 <= nli1ii17;
	initial
		nli1ii17 = 0;
	always @ ( posedge nli0OO)
		  nli1ii17 <= nli1ii16;
	initial
		nli1ii18 = 0;
	always @ ( posedge nli0OO)
		  nli1ii18 <= (nli1ii17 ^ nli1ii16);
	initial
		nli1li13 = 1'b1;
	always @ ( posedge nli0OO)
		  nli1li13 <= nli1li14;
	initial
		nli1li14 = 0;
	always @ ( posedge nli0OO)
		  nli1li14 <= nli1li13;
	initial
		nli1li15 = 0;
	always @ ( posedge nli0OO)
		  nli1li15 <= (nli1li14 ^ nli1li13);
	initial
		nlii1i1 = 1'b1;
	always @ ( posedge nli0OO)
		  nlii1i1 <= nlii1i2;
	initial
		nlii1i2 = 0;
	always @ ( posedge nli0OO)
		  nlii1i2 <= nlii1i1;
	initial
		nlii1i3 = 0;
	always @ ( posedge nli0OO)
		  nlii1i3 <= (nlii1i2 ^ nlii1i1);
	initial
		nllilO = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nllilO <= 1'b1;
		else   nllilO <= wire_nllO0i_dataout;
	initial
		nlliOi = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlliOi <= 1'b1;
		else   nlliOi <= wire_n1O1O_dataout;
	initial
		nlliOl = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlliOl <= 1'b1;
		else   nlliOl <= wire_n1O0O_dataout;
	initial
		nlliOO = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlliOO <= 1'b1;
		else   nlliOO <= wire_n1Oii_dataout;
	initial
		nlll0i = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlll0i <= 1'b1;
		else   nlll0i <= wire_nlO0i_dataout;
	initial
		nlll0l = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlll0l <= 1'b1;
		else   nlll0l <= wire_nlOii_dataout;
	initial
		nlll0O = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlll0O <= 1'b1;
		else   nlll0O <= wire_nlOil_dataout;
	initial
		nlll1i = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlll1i <= 1'b1;
		else   nlll1i <= wire_n1Oil_dataout;
	initial
		nlll1l = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlll1l <= 1'b1;
		else   nlll1l <= wire_n1Oll_dataout;
	initial
		nlll1O = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlll1O <= 1'b1;
		else   nlll1O <= wire_n00lO_dataout;
	initial
		nlllii = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlllii <= 1'b1;
		else   nlllii <= wire_nlOiO_dataout;
	initial
		nlllil = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlllil <= 1'b1;
		else   nlllil <= wire_nlOlO_dataout;
	initial
		nllliO = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nllliO <= 1'b1;
		else   nllliO <= (~ nl0iOi);
	initial
		nlllli = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlllli <= 1'b0;
		else   nlllli <= wire_n0Oi_dataout;
	initial
		nlllll = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlllll <= 1'b0;
		else   nlllll <= wire_nllO1O_dataout;
	initial
		nllllO = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nllllO <= 1'b0;
		else   nllllO <= wire_nllO0l_dataout;
	initial
		nlllOi = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlllOi <= 1'b0;
		else   nlllOi <= wire_nllO0O_dataout;
	initial
		nlllOl = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlllOl <= 1'b0;
		else   nlllOl <= wire_nllOii_dataout;
	initial
		nlllOO = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlllOO <= 1'b0;
		else   nlllOO <= wire_nllOil_dataout;
	initial
		nllO1i = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nllO1i <= 1'b0;
		else   nllO1i <= wire_nllOiO_dataout;
	initial
		nllO1l = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nllO1l <= 1'b0;
		else   nllO1l <= wire_nllOli_dataout;
	initial
		nllOl = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nllOl <= 1'b0;
		else   nllOl <= wire_nl1lO_dataout;
	initial
		nllOO = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nllOO <= 1'b0;
		else   nllOO <= wire_nlO0l_dataout;
	initial
		nlO00i = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlO00i <= 1'b0;
		else   nlO00i <= wire_nlO0lO_dataout;
	initial
		nlO00l = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlO00l <= 1'b0;
		else   nlO00l <= wire_nlO0Oi_dataout;
	initial
		nlO00O = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlO00O <= 1'b0;
		else   nlO00O <= wire_nlO0Ol_dataout;
	initial
		nlO01O = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlO01O <= 1'b0;
		else   nlO01O <= wire_nllOll_dataout;
	initial
		nlO0ii = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlO0ii <= 1'b0;
		else   nlO0ii <= wire_nlO0OO_dataout;
	initial
		nlO0il = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlO0il <= 1'b0;
		else   nlO0il <= wire_nlOi1i_dataout;
	initial
		nlO0iO = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlO0iO <= 1'b0;
		else   nlO0iO <= wire_nlOi1l_dataout;
	initial
		nlO0li = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlO0li <= 1'b0;
		else   nlO0li <= wire_nlOi1O_dataout;
	initial
		nlO0ll = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlO0ll <= 1'b0;
		else   nlO0ll <= wire_nlOi0i_dataout;
	initial
		nlO1i = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlO1i <= 1'b0;
		else   nlO1i <= wire_nlO0O_dataout;
	initial
		nlO1l = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlO1l <= 1'b0;
		else   nlO1l <= wire_nlOli_dataout;
	initial
		nlO1O = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlO1O <= 1'b0;
		else   nlO1O <= wire_nlOll_dataout;
	initial
		nlOOOO = 0;
	always @ ( posedge rxclk or posedge resetall)
		if (resetall == 1'b1) nlOOOO <= 1'b0;
		else   nlOOOO <= wire_nlOi0l_dataout;
	or(wire_n00i_dataout, rxdatain[2:2], wire_ni1i_dataout);
	or(wire_n00l_dataout, rxdatain[3:3], wire_ni1i_dataout);
	assign		wire_n00ll_dataout = (nlllli === 1'b1) ? wire_n0O1l_dataout : wire_n0iOi_dataout;
	assign		wire_n00lO_dataout = (nlllli === 1'b1) ? wire_n0O1O_dataout : wire_n0i0l_dataout;
	or(wire_n00O_dataout, rxdatain[4:4], wire_ni1i_dataout);
	assign		wire_n00Oi_dataout = (nlllli === 1'b1) ? wire_n0O0i_dataout : wire_n0i0O_dataout;
	assign		wire_n00Ol_dataout = (nlllli === 1'b1) ? wire_n0O0l_dataout : wire_n0iii_dataout;
	assign		wire_n00OO_dataout = (nlllli === 1'b1) ? wire_n0O0O_dataout : wire_n0iil_dataout;
	assign		wire_n010i_dataout = (nl0iii === 1'b1) ? wire_n01Oi_dataout : nlO1O;
	assign		wire_n010l_dataout = (nl0iii === 1'b1) ? wire_n01Ol_dataout : nlllil;
	or(wire_n010O_dataout, nlll0i, nl0i0O);
	assign		wire_n011i_dataout = (nl0iii === 1'b1) ? wire_n01li_dataout : nlll0O;
	assign		wire_n011l_dataout = (nl0iii === 1'b1) ? wire_n01ll_dataout : nlllii;
	assign		wire_n011O_dataout = (nl0iii === 1'b1) ? wire_n01lO_dataout : nlO1l;
	or(wire_n01i_dataout, rxctrl[0:0], wire_ni1i_dataout);
	and(wire_n01ii_dataout, nllOO, ~{nl0i0O});
	or(wire_n01il_dataout, nlO1i, nl0i0O);
	or(wire_n01iO_dataout, nlll0l, nl0i0O);
	and(wire_n01l_dataout, rxdatain[0:0], ~{wire_ni1i_dataout});
	or(wire_n01li_dataout, nlll0O, nl0i0O);
	or(wire_n01ll_dataout, nlllii, nl0i0O);
	or(wire_n01lO_dataout, nlO1l, nl0i0O);
	or(wire_n01O_dataout, rxdatain[1:1], wire_ni1i_dataout);
	or(wire_n01Oi_dataout, nlO1O, nl0i0O);
	or(wire_n01Ol_dataout, nlllil, nl0i0O);
	assign		wire_n0i0i_dataout = (nlllli === 1'b1) ? wire_n0Oli_dataout : wire_n0ilO_dataout;
	or(wire_n0i0l_dataout, wire_n0iOO_dataout, (~ nl0iOi));
	and(wire_n0i0O_dataout, wire_n0l1i_dataout, ~{(~ nl0iOi)});
	assign		wire_n0i1i_dataout = (nlllli === 1'b1) ? wire_n0Oii_dataout : wire_n0iiO_dataout;
	assign		wire_n0i1l_dataout = (nlllli === 1'b1) ? wire_n0Oil_dataout : wire_n0ili_dataout;
	assign		wire_n0i1O_dataout = (nlllli === 1'b1) ? wire_n0OiO_dataout : wire_n0ill_dataout;
	or(wire_n0ii_dataout, rxdatain[5:5], wire_ni1i_dataout);
	and(wire_n0iii_dataout, wire_n0l1l_dataout, ~{(~ nl0iOi)});
	and(wire_n0iil_dataout, wire_n0l1O_dataout, ~{(~ nl0iOi)});
	and(wire_n0iiO_dataout, wire_n0l0i_dataout, ~{(~ nl0iOi)});
	or(wire_n0il_dataout, rxdatain[6:6], wire_ni1i_dataout);
	and(wire_n0ili_dataout, wire_n0l0l_dataout, ~{(~ nl0iOi)});
	and(wire_n0ill_dataout, wire_n0l0O_dataout, ~{(~ nl0iOi)});
	and(wire_n0ilO_dataout, wire_n0lii_dataout, ~{(~ nl0iOi)});
	or(wire_n0iO_dataout, rxdatain[7:7], wire_ni1i_dataout);
	and(wire_n0iOi_dataout, wire_n0iOl_dataout, ~{(~ nl0iOi)});
	or(wire_n0iOl_dataout, wire_n0lil_dataout, nl0O1O);
	or(wire_n0iOO_dataout, wire_n0liO_dataout, nl0O1O);
	and(wire_n0l0i_dataout, wire_n0lOi_dataout, ~{nl0O1O});
	and(wire_n0l0l_dataout, wire_n0lOl_dataout, ~{nl0O1O});
	and(wire_n0l0O_dataout, wire_n0lOO_dataout, ~{nl0O1O});
	or(wire_n0l1i_dataout, wire_n0lli_dataout, nl0O1O);
	or(wire_n0l1l_dataout, wire_n0lll_dataout, nl0O1O);
	and(wire_n0l1O_dataout, wire_n0llO_dataout, ~{nl0O1O});
	and(wire_n0lii_dataout, wire_n0O1i_dataout, ~{nl0O1O});
	or(wire_n0lil_dataout, rxctrl[3:3], wire_ni0i_dataout);
	and(wire_n0liO_dataout, rxdatain[24:24], ~{wire_ni0i_dataout});
	or(wire_n0lli_dataout, rxdatain[25:25], wire_ni0i_dataout);
	or(wire_n0lll_dataout, rxdatain[26:26], wire_ni0i_dataout);
	or(wire_n0llO_dataout, rxdatain[27:27], wire_ni0i_dataout);
	and(wire_n0lO_dataout, nl0O1O, ~{(~ nl0iOi)});
	or(wire_n0lOi_dataout, rxdatain[28:28], wire_ni0i_dataout);
	or(wire_n0lOl_dataout, rxdatain[29:29], wire_ni0i_dataout);
	or(wire_n0lOO_dataout, rxdatain[30:30], wire_ni0i_dataout);
	and(wire_n0O0i_dataout, wire_n0OOi_dataout, ~{(~ nl0iOi)});
	and(wire_n0O0l_dataout, wire_n0OOl_dataout, ~{(~ nl0iOi)});
	and(wire_n0O0O_dataout, wire_n0OOO_dataout, ~{(~ nl0iOi)});
	or(wire_n0O1i_dataout, rxdatain[31:31], wire_ni0i_dataout);
	and(wire_n0O1l_dataout, wire_n0Oll_dataout, ~{(~ nl0iOi)});
	or(wire_n0O1O_dataout, wire_n0OlO_dataout, (~ nl0iOi));
	and(wire_n0Oi_dataout, (~ nl0O1O), ~{(~ nl0iOi)});
	and(wire_n0Oii_dataout, wire_ni11i_dataout, ~{(~ nl0iOi)});
	and(wire_n0Oil_dataout, wire_ni11l_dataout, ~{(~ nl0iOi)});
	and(wire_n0OiO_dataout, wire_ni11O_dataout, ~{(~ nl0iOi)});
	and(wire_n0Oli_dataout, wire_ni10i_dataout, ~{(~ nl0iOi)});
	or(wire_n0Oll_dataout, wire_n0lil_dataout, nl0iil);
	or(wire_n0OlO_dataout, wire_n0liO_dataout, nl0iil);
	or(wire_n0OOi_dataout, wire_n0lli_dataout, nl0iil);
	or(wire_n0OOl_dataout, wire_n0lll_dataout, nl0iil);
	and(wire_n0OOO_dataout, wire_n0llO_dataout, ~{nl0iil});
	assign		wire_n100i_dataout = (nl0lOl === 1'b1) ? wire_n1l0i_dataout : wire_n10Oi_dataout;
	assign		wire_n100l_dataout = (nl0lOl === 1'b1) ? wire_n1l0l_dataout : wire_n10Ol_dataout;
	assign		wire_n100O_dataout = (nl0lOl === 1'b1) ? wire_n1l0O_dataout : wire_n10OO_dataout;
	and(wire_n101i_dataout, wire_n10li_dataout, ~{nllliO});
	and(wire_n101l_dataout, wire_n10ll_dataout, ~{nllliO});
	assign		wire_n101O_dataout = (nl0lOl === 1'b1) ? wire_n1l1O_dataout : wire_n10lO_dataout;
	and(wire_n10i_dataout, wire_n1Oi_dataout, ~{wire_n0lO_dataout});
	assign		wire_n10ii_dataout = (nl0lOl === 1'b1) ? wire_n1lii_dataout : wire_n1i1i_dataout;
	assign		wire_n10il_dataout = (nl0lOl === 1'b1) ? wire_n1lil_dataout : wire_n1i1l_dataout;
	assign		wire_n10iO_dataout = (nl0lOl === 1'b1) ? wire_n1liO_dataout : wire_n1i1O_dataout;
	and(wire_n10l_dataout, wire_n1Ol_dataout, ~{wire_n0lO_dataout});
	assign		wire_n10li_dataout = (nl0lOl === 1'b1) ? wire_n1lli_dataout : wire_n1i0i_dataout;
	assign		wire_n10ll_dataout = (nl0lOl === 1'b1) ? wire_n1lll_dataout : wire_n1i0l_dataout;
	assign		wire_n10lO_dataout = (nl0i1l === 1'b1) ? wire_n1i0O_dataout : niOll;
	and(wire_n10O_dataout, wire_n1OO_dataout, ~{wire_n0lO_dataout});
	assign		wire_n10Oi_dataout = (nl0i1l === 1'b1) ? wire_n1iii_dataout : niOlO;
	assign		wire_n10Ol_dataout = (nl0i1l === 1'b1) ? wire_n1iil_dataout : niOOi;
	assign		wire_n10OO_dataout = (nl0i1l === 1'b1) ? wire_n1iiO_dataout : niOOl;
	or(wire_n11i_dataout, wire_n1li_dataout, wire_n0lO_dataout);
	and(wire_n11iO_dataout, wire_n101O_dataout, ~{nllliO});
	and(wire_n11l_dataout, wire_n1ll_dataout, ~{wire_n0lO_dataout});
	and(wire_n11li_dataout, wire_n100i_dataout, ~{nllliO});
	and(wire_n11ll_dataout, wire_n100l_dataout, ~{nllliO});
	and(wire_n11lO_dataout, wire_n100O_dataout, ~{nllliO});
	and(wire_n11O_dataout, wire_n1lO_dataout, ~{wire_n0lO_dataout});
	and(wire_n11Oi_dataout, wire_n10ii_dataout, ~{nllliO});
	and(wire_n11Ol_dataout, wire_n10il_dataout, ~{nllliO});
	and(wire_n11OO_dataout, wire_n10iO_dataout, ~{nllliO});
	assign		wire_n1i0i_dataout = (nl0i1l === 1'b1) ? wire_n1iOi_dataout : nl11O;
	assign		wire_n1i0l_dataout = (nl0i1l === 1'b1) ? wire_n1iOl_dataout : nllOl;
	or(wire_n1i0O_dataout, niOll, nl0i1i);
	assign		wire_n1i1i_dataout = (nl0i1l === 1'b1) ? wire_n1ili_dataout : niOOO;
	assign		wire_n1i1l_dataout = (nl0i1l === 1'b1) ? wire_n1ill_dataout : nl11i;
	assign		wire_n1i1O_dataout = (nl0i1l === 1'b1) ? wire_n1ilO_dataout : nl11l;
	assign		wire_n1ii_dataout = (nl0lOl === 1'b1) ? rxctrl[0:0] : wire_n01i_dataout;
	and(wire_n1iii_dataout, niOlO, ~{nl0i1i});
	or(wire_n1iil_dataout, niOOi, nl0i1i);
	or(wire_n1iiO_dataout, niOOl, nl0i1i);
	assign		wire_n1il_dataout = (nl0lOl === 1'b1) ? rxdatain[0:0] : wire_n01l_dataout;
	or(wire_n1ili_dataout, niOOO, nl0i1i);
	or(wire_n1ill_dataout, nl11i, nl0i1i);
	or(wire_n1ilO_dataout, nl11l, nl0i1i);
	assign		wire_n1iO_dataout = (nl0lOl === 1'b1) ? rxdatain[1:1] : wire_n01O_dataout;
	or(wire_n1iOi_dataout, nl11O, nl0i1i);
	or(wire_n1iOl_dataout, nllOl, nl0i1i);
	and(wire_n1l0i_dataout, niOlO, ~{nl0i1O});
	or(wire_n1l0l_dataout, niOOi, nl0i1O);
	or(wire_n1l0O_dataout, niOOl, nl0i1O);
	or(wire_n1l1O_dataout, niOll, nl0i1O);
	assign		wire_n1li_dataout = (nl0lOl === 1'b1) ? rxdatain[2:2] : wire_n00i_dataout;
	or(wire_n1lii_dataout, niOOO, nl0i1O);
	or(wire_n1lil_dataout, nl11i, nl0i1O);
	or(wire_n1liO_dataout, nl11l, nl0i1O);
	assign		wire_n1ll_dataout = (nl0lOl === 1'b1) ? rxdatain[3:3] : wire_n00l_dataout;
	or(wire_n1lli_dataout, nl11O, nl0i1O);
	or(wire_n1lll_dataout, nllOl, nl0i1O);
	assign		wire_n1lO_dataout = (nl0lOl === 1'b1) ? rxdatain[4:4] : wire_n00O_dataout;
	and(wire_n1O0i_dataout, wire_n1OOi_dataout, ~{nllliO});
	and(wire_n1O0l_dataout, wire_n1OOl_dataout, ~{nllliO});
	or(wire_n1O0O_dataout, wire_n1OOO_dataout, nllliO);
	or(wire_n1O1O_dataout, wire_n1OlO_dataout, nllliO);
	assign		wire_n1Oi_dataout = (nl0lOl === 1'b1) ? rxdatain[5:5] : wire_n0ii_dataout;
	or(wire_n1Oii_dataout, wire_n011i_dataout, nllliO);
	or(wire_n1Oil_dataout, wire_n011l_dataout, nllliO);
	and(wire_n1OiO_dataout, wire_n011O_dataout, ~{nllliO});
	assign		wire_n1Ol_dataout = (nl0lOl === 1'b1) ? rxdatain[6:6] : wire_n0il_dataout;
	and(wire_n1Oli_dataout, wire_n010i_dataout, ~{nllliO});
	or(wire_n1Oll_dataout, wire_n010l_dataout, nllliO);
	assign		wire_n1OlO_dataout = (nl0iii === 1'b1) ? wire_n010O_dataout : nlll0i;
	assign		wire_n1OO_dataout = (nl0lOl === 1'b1) ? rxdatain[7:7] : wire_n0iO_dataout;
	assign		wire_n1OOi_dataout = (nl0iii === 1'b1) ? wire_n01ii_dataout : nllOO;
	assign		wire_n1OOl_dataout = (nl0iii === 1'b1) ? wire_n01il_dataout : nlO1i;
	assign		wire_n1OOO_dataout = (nl0iii === 1'b1) ? wire_n01iO_dataout : nlll0l;
	assign		wire_ni00i_dataout = (nlllli === 1'b1) ? wire_nilli_dataout : wire_ni0Oi_dataout;
	assign		wire_ni00l_dataout = (nlllli === 1'b1) ? wire_nilll_dataout : wire_ni0Ol_dataout;
	assign		wire_ni00O_dataout = (nlllli === 1'b1) ? wire_nillO_dataout : wire_ni0OO_dataout;
	assign		wire_ni01i_dataout = (nlllli === 1'b1) ? wire_nilii_dataout : wire_ni0li_dataout;
	assign		wire_ni01l_dataout = (nlllli === 1'b1) ? wire_nilil_dataout : wire_ni0ll_dataout;
	assign		wire_ni01O_dataout = (nlllli === 1'b1) ? wire_niliO_dataout : wire_ni0lO_dataout;
	and(wire_ni0i_dataout, rxrunningdisp[3:3], ~{nllliO});
	assign		wire_ni0ii_dataout = (nlllli === 1'b1) ? wire_nilOi_dataout : wire_nii1i_dataout;
	assign		wire_ni0il_dataout = (nlllli === 1'b1) ? wire_nilOl_dataout : wire_nii1l_dataout;
	and(wire_ni0iO_dataout, wire_nii1O_dataout, ~{(~ nl0iOi)});
	or(wire_ni0li_dataout, wire_nii0i_dataout, (~ nl0iOi));
	and(wire_ni0ll_dataout, wire_nii0l_dataout, ~{(~ nl0iOi)});
	and(wire_ni0lO_dataout, wire_nii0O_dataout, ~{(~ nl0iOi)});
	and(wire_ni0Oi_dataout, wire_niiii_dataout, ~{(~ nl0iOi)});
	and(wire_ni0Ol_dataout, wire_niiil_dataout, ~{(~ nl0iOi)});
	and(wire_ni0OO_dataout, wire_niiiO_dataout, ~{(~ nl0iOi)});
	and(wire_ni10i_dataout, wire_n0O1i_dataout, ~{nl0iil});
	and(wire_ni11i_dataout, wire_n0lOi_dataout, ~{nl0iil});
	and(wire_ni11l_dataout, wire_n0lOl_dataout, ~{nl0iil});
	and(wire_ni11O_dataout, wire_n0lOO_dataout, ~{nl0iil});
	and(wire_ni1i_dataout, rxrunningdisp[0:0], ~{nllliO});
	and(wire_ni1l_dataout, rxrunningdisp[1:1], ~{nllliO});
	and(wire_ni1O_dataout, rxrunningdisp[2:2], ~{nllliO});
	assign		wire_ni1OO_dataout = (nlllli === 1'b1) ? wire_nil0O_dataout : wire_ni0iO_dataout;
	or(wire_nii0i_dataout, wire_niiOi_dataout, nl0O1O);
	or(wire_nii0l_dataout, wire_niiOl_dataout, nl0O1O);
	or(wire_nii0O_dataout, wire_niiOO_dataout, nl0O1O);
	and(wire_nii1i_dataout, wire_niili_dataout, ~{(~ nl0iOi)});
	and(wire_nii1l_dataout, wire_niill_dataout, ~{(~ nl0iOi)});
	or(wire_nii1O_dataout, wire_niilO_dataout, nl0O1O);
	and(wire_niiii_dataout, wire_nil1i_dataout, ~{nl0O1O});
	and(wire_niiil_dataout, wire_nil1l_dataout, ~{nl0O1O});
	and(wire_niiiO_dataout, wire_nil1O_dataout, ~{nl0O1O});
	and(wire_niili_dataout, wire_nil0i_dataout, ~{nl0O1O});
	and(wire_niill_dataout, wire_nil0l_dataout, ~{nl0O1O});
	or(wire_niilO_dataout, rxctrl[2:2], wire_ni1O_dataout);
	and(wire_niiOi_dataout, rxdatain[16:16], ~{wire_ni1O_dataout});
	or(wire_niiOl_dataout, rxdatain[17:17], wire_ni1O_dataout);
	or(wire_niiOO_dataout, rxdatain[18:18], wire_ni1O_dataout);
	or(wire_nil0i_dataout, rxdatain[22:22], wire_ni1O_dataout);
	or(wire_nil0l_dataout, rxdatain[23:23], wire_ni1O_dataout);
	and(wire_nil0O_dataout, wire_nilOO_dataout, ~{(~ nl0iOi)});
	or(wire_nil1i_dataout, rxdatain[19:19], wire_ni1O_dataout);
	or(wire_nil1l_dataout, rxdatain[20:20], wire_ni1O_dataout);
	or(wire_nil1O_dataout, rxdatain[21:21], wire_ni1O_dataout);
	and(wire_nilii_dataout, wire_niO1i_dataout, ~{(~ nl0iOi)});
	and(wire_nilil_dataout, wire_niO1l_dataout, ~{(~ nl0iOi)});
	and(wire_niliO_dataout, wire_niO1O_dataout, ~{(~ nl0iOi)});
	and(wire_nilli_dataout, wire_niO0i_dataout, ~{(~ nl0iOi)});
	and(wire_nilll_dataout, wire_niO0l_dataout, ~{(~ nl0iOi)});
	and(wire_nillO_dataout, wire_niO0O_dataout, ~{(~ nl0iOi)});
	and(wire_nilOi_dataout, wire_niOii_dataout, ~{(~ nl0iOi)});
	and(wire_nilOl_dataout, wire_niOil_dataout, ~{(~ nl0iOi)});
	or(wire_nilOO_dataout, wire_niilO_dataout, nl0ill);
	and(wire_niO0i_dataout, wire_nil1i_dataout, ~{nl0ill});
	and(wire_niO0l_dataout, wire_nil1l_dataout, ~{nl0ill});
	and(wire_niO0O_dataout, wire_nil1O_dataout, ~{nl0ill});
	or(wire_niO1i_dataout, wire_niiOi_dataout, nl0ill);
	or(wire_niO1l_dataout, wire_niiOl_dataout, nl0ill);
	or(wire_niO1O_dataout, wire_niiOO_dataout, nl0ill);
	and(wire_niOii_dataout, wire_nil0i_dataout, ~{nl0ill});
	and(wire_niOil_dataout, wire_nil0l_dataout, ~{nl0ill});
	and(wire_nl00i_dataout, wire_nl0Oi_dataout, ~{(~ nl0iOi)});
	and(wire_nl00l_dataout, wire_nl0Ol_dataout, ~{(~ nl0iOi)});
	and(wire_nl00O_dataout, wire_nl0OO_dataout, ~{(~ nl0iOi)});
	and(wire_nl01i_dataout, wire_nl0li_dataout, ~{(~ nl0iOi)});
	and(wire_nl01l_dataout, wire_nl0ll_dataout, ~{(~ nl0iOi)});
	and(wire_nl01O_dataout, wire_nl0lO_dataout, ~{(~ nl0iOi)});
	or(wire_nl0ii_dataout, wire_nli1i_dataout, nl0O1O);
	or(wire_nl0il_dataout, wire_nli1l_dataout, nl0O1O);
	or(wire_nl0iO_dataout, wire_nli1O_dataout, nl0O1O);
	or(wire_nl0li_dataout, wire_nli0i_dataout, nl0O1O);
	and(wire_nl0ll_dataout, wire_nli0l_dataout, ~{nl0O1O});
	and(wire_nl0lO_dataout, wire_nli0O_dataout, ~{nl0O1O});
	and(wire_nl0Oi_dataout, wire_nliii_dataout, ~{nl0O1O});
	and(wire_nl0Ol_dataout, wire_nliil_dataout, ~{nl0O1O});
	and(wire_nl0OO_dataout, wire_nliiO_dataout, ~{nl0O1O});
	assign		wire_nl10i_dataout = (nlllli === 1'b1) ? wire_nlili_dataout : wire_nl1Oi_dataout;
	assign		wire_nl10l_dataout = (nlllli === 1'b1) ? wire_nlill_dataout : wire_nl1Ol_dataout;
	assign		wire_nl10O_dataout = (nlllli === 1'b1) ? wire_nlilO_dataout : wire_nl1OO_dataout;
	assign		wire_nl1ii_dataout = (nlllli === 1'b1) ? wire_nliOi_dataout : wire_nl01i_dataout;
	assign		wire_nl1il_dataout = (nlllli === 1'b1) ? wire_nliOl_dataout : wire_nl01l_dataout;
	assign		wire_nl1iO_dataout = (nlllli === 1'b1) ? wire_nliOO_dataout : wire_nl01O_dataout;
	assign		wire_nl1li_dataout = (nlllli === 1'b1) ? wire_nll1i_dataout : wire_nl00i_dataout;
	assign		wire_nl1ll_dataout = (nlllli === 1'b1) ? wire_nll1l_dataout : wire_nl00l_dataout;
	assign		wire_nl1lO_dataout = (nlllli === 1'b1) ? wire_nll1O_dataout : wire_nl00O_dataout;
	and(wire_nl1Oi_dataout, wire_nl0ii_dataout, ~{(~ nl0iOi)});
	and(wire_nl1Ol_dataout, wire_nl0il_dataout, ~{(~ nl0iOi)});
	and(wire_nl1OO_dataout, wire_nl0iO_dataout, ~{(~ nl0iOi)});
	or(wire_nli0i_dataout, rxdatain[10:10], wire_ni1l_dataout);
	or(wire_nli0l_dataout, rxdatain[11:11], wire_ni1l_dataout);
	or(wire_nli0O_dataout, rxdatain[12:12], wire_ni1l_dataout);
	or(wire_nli1i_dataout, rxctrl[1:1], wire_ni1l_dataout);
	and(wire_nli1l_dataout, rxdatain[8:8], ~{wire_ni1l_dataout});
	or(wire_nli1O_dataout, rxdatain[9:9], wire_ni1l_dataout);
	or(wire_nliii_dataout, rxdatain[13:13], wire_ni1l_dataout);
	or(wire_nliil_dataout, rxdatain[14:14], wire_ni1l_dataout);
	or(wire_nliiO_dataout, rxdatain[15:15], wire_ni1l_dataout);
	and(wire_nlili_dataout, wire_nll0i_dataout, ~{(~ nl0iOi)});
	and(wire_nlill_dataout, wire_nll0l_dataout, ~{(~ nl0iOi)});
	and(wire_nlilO_dataout, wire_nll0O_dataout, ~{(~ nl0iOi)});
	and(wire_nliOi_dataout, wire_nllii_dataout, ~{(~ nl0iOi)});
	and(wire_nliOl_dataout, wire_nllil_dataout, ~{(~ nl0iOi)});
	and(wire_nliOO_dataout, wire_nlliO_dataout, ~{(~ nl0iOi)});
	or(wire_nll0i_dataout, wire_nli1i_dataout, nl0ilO);
	or(wire_nll0l_dataout, wire_nli1l_dataout, nl0ilO);
	or(wire_nll0O_dataout, wire_nli1O_dataout, nl0ilO);
	and(wire_nll1i_dataout, wire_nllli_dataout, ~{(~ nl0iOi)});
	and(wire_nll1l_dataout, wire_nllll_dataout, ~{(~ nl0iOi)});
	and(wire_nll1O_dataout, wire_nlllO_dataout, ~{(~ nl0iOi)});
	or(wire_nllii_dataout, wire_nli0i_dataout, nl0ilO);
	and(wire_nllil_dataout, wire_nli0l_dataout, ~{nl0ilO});
	and(wire_nlliO_dataout, wire_nli0O_dataout, ~{nl0ilO});
	and(wire_nllli_dataout, wire_nliii_dataout, ~{nl0ilO});
	and(wire_nllll_dataout, wire_nliil_dataout, ~{nl0ilO});
	and(wire_nlllO_dataout, wire_nliiO_dataout, ~{nl0ilO});
	or(wire_nllO0i_dataout, wire_nllOlO_dataout, nllliO);
	and(wire_nllO0l_dataout, wire_nllOOi_dataout, ~{nllliO});
	and(wire_nllO0O_dataout, wire_nllOOl_dataout, ~{nllliO});
	and(wire_nllO1O_dataout, wire_nlO10l_dataout, ~{nllliO});
	and(wire_nllOii_dataout, wire_nllOOO_dataout, ~{nllliO});
	and(wire_nllOil_dataout, wire_nlO11i_dataout, ~{nllliO});
	and(wire_nllOiO_dataout, wire_nlO11l_dataout, ~{nllliO});
	and(wire_nllOli_dataout, wire_nlO11O_dataout, ~{nllliO});
	and(wire_nllOll_dataout, wire_nlO10i_dataout, ~{nllliO});
	assign		wire_nllOlO_dataout = (nl00lO === 1'b1) ? wire_nlO10O_dataout : nlll1O;
	assign		wire_nllOOi_dataout = (nl00lO === 1'b1) ? wire_nlO1ii_dataout : n000l;
	assign		wire_nllOOl_dataout = (nl00lO === 1'b1) ? wire_nlO1il_dataout : n000O;
	assign		wire_nllOOO_dataout = (nl00lO === 1'b1) ? wire_nlO1iO_dataout : n00ii;
	or(wire_nlO0i_dataout, wire_nlOOi_dataout, (~ nl0iOi));
	and(wire_nlO0l_dataout, wire_nlOOl_dataout, ~{(~ nl0iOi)});
	and(wire_nlO0lO_dataout, wire_nlOi0O_dataout, ~{nllliO});
	and(wire_nlO0O_dataout, wire_nlOOO_dataout, ~{(~ nl0iOi)});
	and(wire_nlO0Oi_dataout, wire_nlOiii_dataout, ~{nllliO});
	and(wire_nlO0Ol_dataout, wire_nlOiil_dataout, ~{nllliO});
	and(wire_nlO0OO_dataout, wire_nlOiiO_dataout, ~{nllliO});
	assign		wire_nlO10i_dataout = (nl00lO === 1'b1) ? wire_nlO1Oi_dataout : ni10O;
	assign		wire_nlO10l_dataout = (nl00lO === 1'b1) ? wire_nlO1Ol_dataout : n000i;
	and(wire_nlO10O_dataout, nlll1O, ~{nl00ll});
	assign		wire_nlO11i_dataout = (nl00lO === 1'b1) ? wire_nlO1li_dataout : n00il;
	assign		wire_nlO11l_dataout = (nl00lO === 1'b1) ? wire_nlO1ll_dataout : n00iO;
	assign		wire_nlO11O_dataout = (nl00lO === 1'b1) ? wire_nlO1lO_dataout : n00li;
	or(wire_nlO1ii_dataout, n000l, nl00ll);
	or(wire_nlO1il_dataout, n000O, nl00ll);
	or(wire_nlO1iO_dataout, n00ii, nl00ll);
	or(wire_nlO1li_dataout, n00il, nl00ll);
	or(wire_nlO1ll_dataout, n00iO, nl00ll);
	or(wire_nlO1lO_dataout, n00li, nl00ll);
	or(wire_nlO1Oi_dataout, ni10O, nl00ll);
	or(wire_nlO1Ol_dataout, n000i, nl00ll);
	and(wire_nlOi0i_dataout, wire_nlOiOi_dataout, ~{nllliO});
	and(wire_nlOi0l_dataout, wire_nlOiOl_dataout, ~{nllliO});
	assign		wire_nlOi0O_dataout = (nl00Oi === 1'b1) ? wire_nlOO0l_dataout : wire_nlOiOO_dataout;
	and(wire_nlOi1i_dataout, wire_nlOili_dataout, ~{nllliO});
	and(wire_nlOi1l_dataout, wire_nlOill_dataout, ~{nllliO});
	and(wire_nlOi1O_dataout, wire_nlOilO_dataout, ~{nllliO});
	or(wire_nlOii_dataout, wire_n11i_dataout, (~ nl0iOi));
	assign		wire_nlOiii_dataout = (nl00Oi === 1'b1) ? wire_nlOO0O_dataout : wire_nlOl1i_dataout;
	assign		wire_nlOiil_dataout = (nl00Oi === 1'b1) ? wire_nlOOii_dataout : wire_nlOl1l_dataout;
	assign		wire_nlOiiO_dataout = (nl00Oi === 1'b1) ? wire_nlOOil_dataout : wire_nlOl1O_dataout;
	or(wire_nlOil_dataout, wire_n11l_dataout, (~ nl0iOi));
	assign		wire_nlOili_dataout = (nl00Oi === 1'b1) ? wire_nlOOiO_dataout : wire_nlOl0i_dataout;
	assign		wire_nlOill_dataout = (nl00Oi === 1'b1) ? wire_nlOOli_dataout : wire_nlOl0l_dataout;
	assign		wire_nlOilO_dataout = (nl00Oi === 1'b1) ? wire_nlOOll_dataout : wire_nlOl0O_dataout;
	or(wire_nlOiO_dataout, wire_n11O_dataout, (~ nl0iOi));
	assign		wire_nlOiOi_dataout = (nl00Oi === 1'b1) ? wire_nlOOlO_dataout : wire_nlOlii_dataout;
	assign		wire_nlOiOl_dataout = (nl00Oi === 1'b1) ? wire_nlOOOi_dataout : wire_nlOlil_dataout;
	assign		wire_nlOiOO_dataout = (n0li === 1'b1) ? wire_nlOliO_dataout : ni1ii;
	assign		wire_nlOl0i_dataout = (n0li === 1'b1) ? wire_nlOlOi_dataout : ni1ll;
	assign		wire_nlOl0l_dataout = (n0li === 1'b1) ? wire_nlOlOl_dataout : ni1lO;
	assign		wire_nlOl0O_dataout = (n0li === 1'b1) ? wire_nlOlOO_dataout : ni1Oi;
	assign		wire_nlOl1i_dataout = (n0li === 1'b1) ? wire_nlOlli_dataout : ni1il;
	assign		wire_nlOl1l_dataout = (n0li === 1'b1) ? wire_nlOlll_dataout : ni1iO;
	assign		wire_nlOl1O_dataout = (n0li === 1'b1) ? wire_nlOllO_dataout : ni1li;
	and(wire_nlOli_dataout, wire_n10i_dataout, ~{(~ nl0iOi)});
	assign		wire_nlOlii_dataout = (n0li === 1'b1) ? wire_nlOO1i_dataout : ni1Ol;
	assign		wire_nlOlil_dataout = (n0li === 1'b1) ? wire_nlOO1l_dataout : niOli;
	or(wire_nlOliO_dataout, ni1ii, nl00Ol);
	and(wire_nlOll_dataout, wire_n10l_dataout, ~{(~ nl0iOi)});
	and(wire_nlOlli_dataout, ni1il, ~{nl00Ol});
	or(wire_nlOlll_dataout, ni1iO, nl00Ol);
	or(wire_nlOllO_dataout, ni1li, nl00Ol);
	or(wire_nlOlO_dataout, wire_n10O_dataout, (~ nl0iOi));
	or(wire_nlOlOi_dataout, ni1ll, nl00Ol);
	or(wire_nlOlOl_dataout, ni1lO, nl00Ol);
	or(wire_nlOlOO_dataout, ni1Oi, nl00Ol);
	or(wire_nlOO0l_dataout, ni1ii, nl00OO);
	and(wire_nlOO0O_dataout, ni1il, ~{nl00OO});
	or(wire_nlOO1i_dataout, ni1Ol, nl00Ol);
	or(wire_nlOO1l_dataout, niOli, nl00Ol);
	or(wire_nlOOi_dataout, wire_n1ii_dataout, wire_n0lO_dataout);
	or(wire_nlOOii_dataout, ni1iO, nl00OO);
	or(wire_nlOOil_dataout, ni1li, nl00OO);
	or(wire_nlOOiO_dataout, ni1ll, nl00OO);
	or(wire_nlOOl_dataout, wire_n1il_dataout, wire_n0lO_dataout);
	or(wire_nlOOli_dataout, ni1lO, nl00OO);
	or(wire_nlOOll_dataout, ni1Oi, nl00OO);
	or(wire_nlOOlO_dataout, ni1Ol, nl00OO);
	or(wire_nlOOO_dataout, wire_n1iO_dataout, wire_n0lO_dataout);
	or(wire_nlOOOi_dataout, niOli, nl00OO);
	assign
		nl00ll = (wire_ni0i_dataout | nli01i),
		nl00lO = (nl0l0i | nl00Oi),
		nl00Oi = (nl0lil | nl0lOl),
		nl00Ol = (wire_ni1O_dataout | (nli10O & nli01O)),
		nl00OO = (wire_ni1O_dataout | nli01O),
		nl0i0O = (wire_ni1i_dataout | (nli1Ol & nli0Oi)),
		nl0i1i = (wire_ni1l_dataout | (nli1lO & nli0ii)),
		nl0i1l = (n0li | n0ll),
		nl0i1O = ((wire_ni1l_dataout | nli0ii) | (~ w_nl0i0i320w)),
		nl0iii = (n0li | (n0ll | n0OO)),
		nl0iil = ((nl0l0i | nl0ill) | (~ w_nl0iiO310w)),
		nl0ill = (nl0lil | nl0ilO),
		nl0ilO = (nl0lOl | nl0O1O),
		nl0iOi = ((((rxdatavalid[3:3] & rxdatavalid[2:2]) & rxdatavalid[1:1]) & rxdatavalid[0:0]) & w_nl0iOl297w),
		nl0l0i = (((rxctrl[2:2] & (~ nl0lii)) & w_nl0l0l267w) & (~ wire_ni1O_dataout)),
		nl0l1i = (((((((((~ rxdatain[31:31]) | rxdatain[25:25]) | (~ rxdatain[24:24])) | (~ rxdatain[26:26])) | (~ rxdatain[27:27])) | (~ rxdatain[28:28])) | (~ rxdatain[29:29])) | (~ rxdatain[30:30])) | (~ w_nl0l1l280w)),
		nl0lii = ((((((((~ rxdatain[23:23]) | rxdatain[17:17]) | (~ rxdatain[16:16])) | (~ rxdatain[18:18])) | (~ rxdatain[19:19])) | (~ rxdatain[20:20])) | (~ rxdatain[21:21])) | (~ rxdatain[22:22])),
		nl0lil = (((rxctrl[1:1] & (~ nl0lll)) & w_nl0liO252w) & (~ wire_ni1l_dataout)),
		nl0lll = (((((((((~ rxdatain[15:15]) | rxdatain[9:9]) | (~ rxdatain[8:8])) | (~ rxdatain[10:10])) | (~ rxdatain[11:11])) | (~ rxdatain[12:12])) | (~ rxdatain[13:13])) | (~ rxdatain[14:14])) | (~ w_nl0llO245w)),
		nl0lOl = ((~ wire_ni1i_dataout) & ((rxctrl[0:0] & (~ nl0O1l)) & w_nl0lOO233w)),
		nl0O1l = ((((((((~ rxdatain[6:6]) | (~ rxdatain[7:7])) | rxdatain[1:1]) | (~ rxdatain[0:0])) | (~ rxdatain[2:2])) | (~ rxdatain[3:3])) | (~ rxdatain[4:4])) | (~ rxdatain[5:5])),
		nl0O1O = (((~ (((nli10O | nli1lO) | nli1Ol) | (((~ rxctrl[3:3]) | nli10l) | (~ w_nl0Oil191w)))) | (~ ((((nli01i | nli01O) | nli0ii) | nli0Oi) | (~ w_nl0O0O201w)))) | (~ ((((((~ rxctrl[3:3]) | nl0Oli) | (~ w_nl0O0i209w)) | ((~ rxctrl[2:2]) | nl0OOi)) | ((~ rxctrl[1:1]) | nli11i)) | ((~ rxctrl[0:0]) | nli11l)))),
		nl0Oli = ((((((((rxdatain[31:31] | rxdatain[25:25]) | rxdatain[24:24]) | (~ rxdatain[26:26])) | (~ rxdatain[27:27])) | (~ rxdatain[28:28])) | rxdatain[29:29]) | rxdatain[30:30]) | (~ w_nl0Oll183w)),
		nl0OOi = ((((((((rxdatain[23:23] | rxdatain[17:17]) | rxdatain[16:16]) | (~ rxdatain[18:18])) | (~ rxdatain[19:19])) | (~ rxdatain[20:20])) | rxdatain[21:21]) | rxdatain[22:22]) | (~ w_nl0OOl176w)),
		nli00O = ((((((((~ rxdatain[23:23]) | rxdatain[17:17]) | rxdatain[16:16]) | (~ rxdatain[18:18])) | (~ rxdatain[19:19])) | (~ rxdatain[20:20])) | (~ rxdatain[21:21])) | rxdatain[22:22]),
		nli01i = ((~ rxctrl[3:3]) | nli01l),
		nli01l = ((((((((~ rxdatain[31:31]) | rxdatain[25:25]) | rxdatain[24:24]) | (~ rxdatain[26:26])) | (~ rxdatain[27:27])) | (~ rxdatain[28:28])) | (~ rxdatain[29:29])) | rxdatain[30:30]),
		nli01O = (((~ rxctrl[2:2]) | nli00O) | (~ w_nli00i87w)),
		nli0ii = (((~ rxctrl[1:1]) | nli0li) | (~ w_nli0il59w)),
		nli0li = (((((((((~ rxdatain[15:15]) | rxdatain[9:9]) | rxdatain[8:8]) | (~ rxdatain[10:10])) | (~ rxdatain[11:11])) | (~ rxdatain[12:12])) | (~ rxdatain[13:13])) | rxdatain[14:14]) | (~ w_nli0ll51w)),
		nli0Oi = ((~ rxctrl[0:0]) | nli0Ol),
		nli0Ol = ((((((((rxdatain[6:6] | (~ rxdatain[7:7])) | rxdatain[1:1]) | rxdatain[0:0]) | (~ rxdatain[2:2])) | (~ rxdatain[3:3])) | (~ rxdatain[4:4])) | (~ rxdatain[5:5])) | (~ w_nlii1i23w)),
		nli0OO = rxclk,
		nli10l = (((((((rxdatain[31:31] | rxdatain[25:25]) | rxdatain[24:24]) | (~ rxdatain[26:26])) | (~ rxdatain[27:27])) | (~ rxdatain[28:28])) | (~ rxdatain[29:29])) | (~ rxdatain[30:30])),
		nli10O = (((~ rxctrl[2:2]) | nli1iO) | (~ w_nli1ii147w)),
		nli11i = (((((((rxdatain[15:15] | rxdatain[9:9]) | rxdatain[8:8]) | (~ rxdatain[10:10])) | (~ rxdatain[11:11])) | (~ rxdatain[12:12])) | rxdatain[13:13]) | rxdatain[14:14]),
		nli11l = ((((((((rxdatain[6:6] | rxdatain[7:7]) | rxdatain[1:1]) | rxdatain[0:0]) | (~ rxdatain[2:2])) | (~ rxdatain[3:3])) | (~ rxdatain[4:4])) | rxdatain[5:5]) | (~ w_nli11O167w)),
		nli1iO = ((((((((rxdatain[23:23] | rxdatain[17:17]) | rxdatain[16:16]) | (~ rxdatain[18:18])) | (~ rxdatain[19:19])) | (~ rxdatain[20:20])) | (~ rxdatain[21:21])) | (~ rxdatain[22:22])) | (~ w_nli1li141w)),
		nli1lO = ((~ rxctrl[1:1]) | nli1Oi),
		nli1Oi = (((((((rxdatain[15:15] | rxdatain[9:9]) | rxdatain[8:8]) | (~ rxdatain[10:10])) | (~ rxdatain[11:11])) | (~ rxdatain[12:12])) | (~ rxdatain[13:13])) | (~ rxdatain[14:14])),
		nli1Ol = ((~ rxctrl[0:0]) | nli1OO),
		nli1OO = ((((((((~ rxdatain[6:6]) | rxdatain[7:7]) | rxdatain[1:1]) | rxdatain[0:0]) | (~ rxdatain[2:2])) | (~ rxdatain[3:3])) | (~ rxdatain[4:4])) | (~ rxdatain[5:5])),
		rxctrlout = {nlllll, nlO00i, n111i, nlliOi},
		rxdataout = {nlO01O, nllO1l, nllO1i, nlllOO, nlllOl, nlllOi, nllllO, nllilO, nlOOOO, nlO0ll, nlO0li, nlO0iO, nlO0il, nlO0ii, nlO00O, nlO00l, n1lOi, n11il, n11ii, n110O, n110l, n110i, n111O, n111l, nlll1l, n1O1l, n1O1i, nlll1i, nlliOO, nlliOl, n1lOO, n1lOl},
		w_nl0i0i320w = nl0i0i60,
		w_nl0iiO310w = nl0iiO57,
		w_nl0iOl297w = nl0iOl54,
		w_nl0l0l267w = nl0l0l48,
		w_nl0l1l280w = nl0l1l51,
		w_nl0liO252w = nl0liO45,
		w_nl0llO245w = nl0llO42,
		w_nl0lOO233w = nl0lOO39,
		w_nl0O0i209w = nl0O0i36,
		w_nl0O0O201w = nl0O0O33,
		w_nl0Oil191w = nl0Oil30,
		w_nl0Oll183w = nl0Oll27,
		w_nl0OOl176w = nl0OOl24,
		w_nli00i87w = nli00i12,
		w_nli0il59w = nli0il9,
		w_nli0ll51w = nli0ll6,
		w_nli11O167w = nli11O21,
		w_nli1ii147w = nli1ii18,
		w_nli1li141w = nli1li15,
		w_nlii1i23w = nlii1i3;
endmodule //altgxb_xgm_rx_sm
//synopsys translate_on
//VALID FILE
//IP Functional Simulation Model
//VERSION_BEGIN 4.1 cbx_mgl 2004:06:17:17:30:06:SJ cbx_simgen 2004:06:22:10:53:08:SJ  VERSION_END


// Legal Notice: � 2003 Altera Corporation. All rights reserved.
// You may only use these  simulation  model  output files for simulation
// purposes and expressly not for synthesis or any other purposes (in which
// event  Altera disclaims all warranties of any kind). Your use of  Altera
// Corporation's design tools, logic functions and other software and tools,
// and its AMPP partner logic functions, and any output files any of the
// foregoing (including device programming or simulation files), and any
// associated documentation or information  are expressly subject to the
// terms and conditions of the  Altera Program License Subscription Agreement
// or other applicable license agreement, including, without limitation, that
// your use is for the sole purpose of programming logic devices manufactured
// by Altera and sold by Altera or its authorized distributors.  Please refer
// to the applicable agreement for further details.


//synopsys translate_off

//synthesis_resources = lut 42 mux21 20 oper_selector 10 
`timescale 1 ps / 1 ps
module  altgxb_xgm_dskw_sm
	( 
	adet,
	alignstatus,
	enabledeskew,
	fiforesetrd,
	rdalign,
	recovclk,
	resetall,
	syncstatus) /* synthesis synthesis_clearbox=1 */;
	input   [3:0]  adet;
	output   alignstatus;
	output   enabledeskew;
	output   fiforesetrd;
	input   [3:0]  rdalign;
	input   recovclk;
	input   resetall;
	input   [3:0]  syncstatus;

	reg	n01i;
	reg	n01l;
	reg	n0i;
	reg	n0l;
	reg	n0O;
	reg	n1i;
	reg	n1l;
	reg	n1O;
	reg	n1Oi;
	reg	n1Ol;
	reg	n1OO;
	reg	nil;
	reg	niO;
	reg	nli;
	reg	nliii25;
	reg	nliii26;
	reg	nliii27;
	reg	nliiO22;
	reg	nliiO23;
	reg	nliiO24;
	reg	nlilO19;
	reg	nlilO20;
	reg	nlilO21;
	reg	nll1i16;
	reg	nll1i17;
	reg	nll1i18;
	reg	nllii13;
	reg	nllii14;
	reg	nllii15;
	reg	nllll10;
	reg	nllll11;
	reg	nllll12;
	reg	nllOl7;
	reg	nllOl8;
	reg	nllOl9;
	reg	nlO1O4;
	reg	nlO1O5;
	reg	nlO1O6;
	reg	nlOii1;
	reg	nlOii2;
	reg	nlOii3;
	reg	nlOO;
	wire	wire_ni0O_dataout;
	wire	wire_niii_dataout;
	wire	wire_niil_dataout;
	wire	wire_niiO_dataout;
	wire	wire_nill_dataout;
	wire	wire_nilO_dataout;
	wire	wire_niOi_dataout;
	wire	wire_niOl_dataout;
	wire	wire_niOO_dataout;
	wire	wire_nl0i_dataout;
	wire	wire_nl0l_dataout;
	wire	wire_nl0O_dataout;
	wire	wire_nl1i_dataout;
	wire	wire_nl1l_dataout;
	wire	wire_nl1O_dataout;
	wire	wire_nlii_dataout;
	wire	wire_nlil_dataout;
	wire	wire_nliO_dataout;
	wire	wire_nlli_dataout;
	wire	wire_nlOi_dataout;
	wire  wire_n00l_o;
	wire  wire_n00O_o;
	wire  wire_n01O_o;
	wire  wire_n0ii_o;
	wire  wire_n0iO_o;
	wire  wire_n0ll_o;
	wire  wire_n0Oi_o;
	wire  wire_n0OO_o;
	wire  wire_ni0i_o;
	wire  wire_ni1l_o;
	wire  nlill;
	wire  nliOl;
	wire  nliOO;
	wire  nll0i;
	wire  nll0l;
	wire  nll0O;
	wire  nll1O;
	wire  nlliO;
	wire  nllli;
	wire  nllOi;
	wire  nlO0l;
	wire  nlO0O;
	wire  nlO1i;
	wire  nlO1l;
	wire  w_nliii222w;
	wire  w_nliiO200w;
	wire  w_nlilO141w;
	wire  w_nll1i115w;
	wire  w_nllii52w;
	wire  w_nllll41w;
	wire  w_nllOl34w;
	wire  w_nlO1O19w;
	wire  w_nlOii10w;

	initial
		n01i = 0;
	always @ ( posedge recovclk or posedge resetall)
		if (resetall == 1'b1) n01i <= 1'b1;
		else   n01i <= wire_n00l_o;
	initial
		n01l = 0;
	always @ ( posedge recovclk or posedge resetall)
		if (resetall == 1'b1) n01l <= 1'b0;
		else   n01l <= (((syncstatus[3:3] & syncstatus[2:2]) & syncstatus[1:1]) & syncstatus[0:0]);
	initial
		n0i = 0;
	always @ ( posedge recovclk or posedge resetall)
		if (resetall == 1'b1) n0i <= 1'b0;
		else   n0i <= wire_n0OO_o;
	initial
		n0l = 0;
	always @ ( posedge recovclk or posedge resetall)
		if (resetall == 1'b1) n0l <= 1'b0;
		else   n0l <= wire_ni1l_o;
	initial
		n0O = 0;
	always @ ( posedge recovclk or posedge resetall)
		if (resetall == 1'b1) n0O <= 1'b0;
		else   n0O <= wire_ni0i_o;
	initial
		n1i = 0;
	always @ ( posedge recovclk or posedge resetall)
		if (resetall == 1'b1) n1i <= 1'b0;
		else   n1i <= wire_n0iO_o;
	initial
		n1l = 0;
	always @ ( posedge recovclk or posedge resetall)
		if (resetall == 1'b1) n1l <= 1'b0;
		else   n1l <= wire_n0ll_o;
	initial
		n1O = 0;
	always @ ( posedge recovclk or posedge resetall)
		if (resetall == 1'b1) n1O <= 1'b0;
		else   n1O <= wire_n0Oi_o;
	initial
		n1Oi = 0;
	always @ ( posedge recovclk or posedge resetall)
		if (resetall == 1'b1) n1Oi <= 1'b1;
		else   n1Oi <= wire_n00O_o;
	initial
		n1Ol = 0;
	always @ ( posedge recovclk or posedge resetall)
		if (resetall == 1'b1) n1Ol <= 1'b1;
		else   n1Ol <= n1OO;
	initial
		n1OO = 0;
	always @ ( posedge recovclk or posedge resetall)
		if (resetall == 1'b1) n1OO <= 1'b1;
		else   n1OO <= n01i;
	initial
		nil = 0;
	always @ ( posedge recovclk or posedge resetall)
		if (resetall == 1'b1) nil <= 1'b0;
		else   nil <= niO;
	initial
		niO = 0;
	always @ ( posedge recovclk or posedge resetall)
		if (resetall == 1'b1) niO <= 1'b0;
		else   niO <= wire_n01O_o;
	initial
		nli = 0;
	always @ ( posedge recovclk or posedge resetall)
		if (resetall == 1'b1) nli <= 1'b0;
		else   nli <= n01l;
	initial
		nliii25 = 1'b1;
	always @ ( posedge nlO0O)
		  nliii25 <= nliii26;
	initial
		nliii26 = 0;
	always @ ( posedge nlO0O)
		  nliii26 <= nliii25;
	initial
		nliii27 = 0;
	always @ ( posedge nlO0O)
		  nliii27 <= (nliii26 ^ nliii25);
	initial
		nliiO22 = 1'b1;
	always @ ( posedge nlO0O)
		  nliiO22 <= nliiO23;
	initial
		nliiO23 = 0;
	always @ ( posedge nlO0O)
		  nliiO23 <= nliiO22;
	initial
		nliiO24 = 0;
	always @ ( posedge nlO0O)
		  nliiO24 <= (nliiO23 ^ nliiO22);
	initial
		nlilO19 = 1'b1;
	always @ ( posedge nlO0O)
		  nlilO19 <= nlilO20;
	initial
		nlilO20 = 0;
	always @ ( posedge nlO0O)
		  nlilO20 <= nlilO19;
	initial
		nlilO21 = 0;
	always @ ( posedge nlO0O)
		  nlilO21 <= (nlilO20 ^ nlilO19);
	initial
		nll1i16 = 1'b1;
	always @ ( posedge nlO0O)
		  nll1i16 <= nll1i17;
	initial
		nll1i17 = 0;
	always @ ( posedge nlO0O)
		  nll1i17 <= nll1i16;
	initial
		nll1i18 = 0;
	always @ ( posedge nlO0O)
		  nll1i18 <= (nll1i17 ^ nll1i16);
	initial
		nllii13 = 1'b1;
	always @ ( posedge nlO0O)
		  nllii13 <= nllii14;
	initial
		nllii14 = 0;
	always @ ( posedge nlO0O)
		  nllii14 <= nllii13;
	initial
		nllii15 = 0;
	always @ ( posedge nlO0O)
		  nllii15 <= (nllii14 ^ nllii13);
	initial
		nllll10 = 1'b1;
	always @ ( posedge nlO0O)
		  nllll10 <= nllll11;
	initial
		nllll11 = 0;
	always @ ( posedge nlO0O)
		  nllll11 <= nllll10;
	initial
		nllll12 = 0;
	always @ ( posedge nlO0O)
		  nllll12 <= (nllll11 ^ nllll10);
	initial
		nllOl7 = 1'b1;
	always @ ( posedge nlO0O)
		  nllOl7 <= nllOl8;
	initial
		nllOl8 = 0;
	always @ ( posedge nlO0O)
		  nllOl8 <= nllOl7;
	initial
		nllOl9 = 0;
	always @ ( posedge nlO0O)
		  nllOl9 <= (nllOl8 ^ nllOl7);
	initial
		nlO1O4 = 1'b1;
	always @ ( posedge nlO0O)
		  nlO1O4 <= nlO1O5;
	initial
		nlO1O5 = 0;
	always @ ( posedge nlO0O)
		  nlO1O5 <= nlO1O4;
	initial
		nlO1O6 = 0;
	always @ ( posedge nlO0O)
		  nlO1O6 <= (nlO1O5 ^ nlO1O4);
	initial
		nlOii1 = 1'b1;
	always @ ( posedge nlO0O)
		  nlOii1 <= nlOii2;
	initial
		nlOii2 = 0;
	always @ ( posedge nlO0O)
		  nlOii2 <= nlOii1;
	initial
		nlOii3 = 0;
	always @ ( posedge nlO0O)
		  nlOii3 <= (nlOii2 ^ nlOii1);
	initial
		nlOO = 0;
	always @ ( posedge recovclk or posedge resetall)
		if (resetall == 1'b1) nlOO <= 1'b0;
		else   nlOO <= wire_n0ii_o;
	or(wire_ni0O_dataout, n01i, nlliO);
	and(wire_niii_dataout, niO, ~{nlliO});
	and(wire_niil_dataout, nlO0l, ~{nlliO});
	and(wire_niiO_dataout, (~ nlO0l), ~{nlliO});
	and(wire_nill_dataout, wire_niOl_dataout, ~{(~ nli)});
	and(wire_nilO_dataout, wire_niOO_dataout, ~{(~ nli)});
	and(wire_niOi_dataout, nlO1l, ~{(~ nli)});
	and(wire_niOl_dataout, nlO0l, ~{nlO1l});
	and(wire_niOO_dataout, (~ nlO0l), ~{nlO1l});
	assign		wire_nl0i_dataout = (nllOi === 1'b1) ? niO : wire_nlii_dataout;
	and(wire_nl0l_dataout, (~ nlO0l), ~{nllOi});
	and(wire_nl0O_dataout, nlO0l, ~{nllOi});
	or(wire_nl1i_dataout, n01i, (~ nli));
	and(wire_nl1l_dataout, niO, ~{(~ nli)});
	and(wire_nl1O_dataout, (~ nlO1l), ~{(~ nli)});
	or(wire_nlii_dataout, niO, nlO0l);
	or(wire_nlil_dataout, n01i, nllOi);
	and(wire_nliO_dataout, (~ nllli), ~{nllOi});
	and(wire_nlli_dataout, nllli, ~{nllOi});
	and(wire_nlOi_dataout, n01i, ~{nlO1i});
	oper_selector   n00l
	( 
	.data({wire_nlOi_dataout, wire_nlil_dataout, wire_nlil_dataout, wire_nlil_dataout, wire_nl1i_dataout, wire_nl1i_dataout, wire_nl1i_dataout, wire_ni0O_dataout}),
	.o(wire_n00l_o),
	.sel({n1Oi, nlOO, n1i, n1l, n1O, n0i, n0l, n0O}));
	defparam
		n00l.width_data = 8,
		n00l.width_sel = 8;
	oper_selector   n00O
	( 
	.data({(~ nlO1i), nllOi, nllOi, nllOi, (~ nli), (~ nli), (~ nli), nlliO}),
	.o(wire_n00O_o),
	.sel({n1Oi, nlOO, n1i, n1l, n1O, n0i, n0l, n0O}));
	defparam
		n00O.width_data = 8,
		n00O.width_sel = 8;
	oper_selector   n01O
	( 
	.data({niO, wire_nl0i_dataout, wire_nl1l_dataout, wire_nl1l_dataout, wire_nl1l_dataout, wire_niii_dataout}),
	.o(wire_n01O_o),
	.sel({(((n1i | nlOO) | n1Oi) | (~ w_nliiO200w)), n1l, n1O, n0i, n0l, n0O}));
	defparam
		n01O.width_data = 6,
		n01O.width_sel = 6;
	oper_selector   n0ii
	( 
	.data({nlO1i, wire_nliO_dataout, 1'b0}),
	.o(wire_n0ii_o),
	.sel({n1Oi, nlOO, nlill}));
	defparam
		n0ii.width_data = 3,
		n0ii.width_sel = 3;
	oper_selector   n0iO
	( 
	.data({1'b0, wire_nlli_dataout, wire_nl0l_dataout}),
	.o(wire_n0iO_o),
	.sel({nliOl, nlOO, n1i}));
	defparam
		n0iO.width_data = 3,
		n0iO.width_sel = 3;
	oper_selector   n0ll
	( 
	.data({1'b0, wire_nl0O_dataout, wire_nl0l_dataout}),
	.o(wire_n0ll_o),
	.sel({nliOO, n1i, n1l}));
	defparam
		n0ll.width_data = 3,
		n0ll.width_sel = 3;
	oper_selector   n0Oi
	( 
	.data({1'b0, wire_nl0O_dataout, wire_nl1O_dataout, wire_nill_dataout}),
	.o(wire_n0Oi_o),
	.sel({nll1O, n1l, n1O, n0i}));
	defparam
		n0Oi.width_data = 4,
		n0Oi.width_sel = 4;
	oper_selector   n0OO
	( 
	.data({1'b0, wire_niOi_dataout, wire_nilO_dataout, wire_nill_dataout}),
	.o(wire_n0OO_o),
	.sel({nll0i, n1O, n0i, n0l}));
	defparam
		n0OO.width_data = 4,
		n0OO.width_sel = 4;
	oper_selector   ni0i
	( 
	.data({1'b0, wire_niOi_dataout, wire_niiO_dataout}),
	.o(wire_ni0i_o),
	.sel({nll0O, n0l, n0O}));
	defparam
		ni0i.width_data = 3,
		ni0i.width_sel = 3;
	oper_selector   ni1l
	( 
	.data({1'b0, wire_niOi_dataout, wire_nilO_dataout, wire_niil_dataout}),
	.o(wire_ni1l_o),
	.sel({nll0l, n0i, n0l, n0O}));
	defparam
		ni1l.width_data = 4,
		ni1l.width_sel = 4;
	assign
		alignstatus = nil,
		enabledeskew = n01i,
		fiforesetrd = ((n01i & (~ n1OO)) & w_nliii222w),
		nlill = ((((((n0O | n0l) | n0i) | n1O) | n1l) | n1i) | (~ w_nlilO141w)),
		nliOl = (((((n0O | n0l) | n0i) | n1O) | n1l) | n1Oi),
		nliOO = ((((((n0O | n0l) | n0i) | n1O) | nlOO) | n1Oi) | (~ w_nll1i115w)),
		nll0i = ((((n0O | n1l) | n1i) | nlOO) | n1Oi),
		nll0l = ((((n1O | n1l) | n1i) | nlOO) | n1Oi),
		nll0O = ((((((n0i | n1O) | n1l) | n1i) | nlOO) | n1Oi) | (~ w_nllii52w)),
		nll1O = ((((n0O | n0l) | n1i) | nlOO) | n1Oi),
		nlliO = ((~ nli) | nlO1l),
		nllli = ((nlO0l & (~ n1Ol)) & w_nllll41w),
		nllOi = (((~ nli) | nlO1l) | (~ w_nllOl34w)),
		nlO0l = ((((rdalign[3:3] & rdalign[2:2]) & rdalign[1:1]) & rdalign[0:0]) & w_nlOii10w),
		nlO0O = recovclk,
		nlO1i = (nli & (((adet[3:3] & adet[2:2]) & adet[1:1]) & adet[0:0])),
		nlO1l = (((((rdalign[3:3] | rdalign[2:2]) | rdalign[1:1]) | rdalign[0:0]) & (~ nlO0l)) & w_nlO1O19w),
		w_nliii222w = nliii27,
		w_nliiO200w = nliiO24,
		w_nlilO141w = nlilO21,
		w_nll1i115w = nll1i18,
		w_nllii52w = nllii15,
		w_nllll41w = nllll12,
		w_nllOl34w = nllOl9,
		w_nlO1O19w = nlO1O6,
		w_nlOii10w = nlOii3;
endmodule //altgxb_xgm_dskw_sm
//synopsys translate_on
//VALID FILE
//IP Functional Simulation Model
//VERSION_BEGIN 4.1 cbx_mgl 2004:06:17:17:30:06:SJ cbx_simgen 2004:06:22:10:53:08:SJ  VERSION_END


// Legal Notice: � 2003 Altera Corporation. All rights reserved.
// You may only use these  simulation  model  output files for simulation
// purposes and expressly not for synthesis or any other purposes (in which
// event  Altera disclaims all warranties of any kind). Your use of  Altera
// Corporation's design tools, logic functions and other software and tools,
// and its AMPP partner logic functions, and any output files any of the
// foregoing (including device programming or simulation files), and any
// associated documentation or information  are expressly subject to the
// terms and conditions of the  Altera Program License Subscription Agreement
// or other applicable license agreement, including, without limitation, that
// your use is for the sole purpose of programming logic devices manufactured
// by Altera and sold by Altera or its authorized distributors.  Please refer
// to the applicable agreement for further details.


//synopsys translate_off

//synthesis_resources = lut 146 mux21 317 oper_add 1 oper_decoder 1 oper_less_than 1 oper_selector 39 
`timescale 1 ps / 1 ps
module  altgxb_xgm_tx_sm
	( 
	rdenablesync,
	resetall,
	txclk,
	txctrl,
	txctrlout,
	txdatain,
	txdataout) /* synthesis synthesis_clearbox=1 */;
	input   rdenablesync;
	input   resetall;
	input   txclk;
	input   [3:0]  txctrl;
	output   [3:0]  txctrlout;
	input   [31:0]  txdatain;
	output   [31:0]  txdataout;

	reg	n0iil;
	reg	n0iiO;
	reg	n0ili;
	reg	n10ll;
	reg	n10lO;
	reg	n10Oi;
	reg	nl000i4;
	reg	nl000i5;
	reg	nl000i6;
	reg	nl001i7;
	reg	nl001i8;
	reg	nl001i9;
	reg	nl00li1;
	reg	nl00li2;
	reg	nl00li3;
	reg	nl010i13;
	reg	nl010i14;
	reg	nl010i15;
	reg	nl011i16;
	reg	nl011i17;
	reg	nl011i18;
	reg	nl01ll10;
	reg	nl01ll11;
	reg	nl01ll12;
	reg	nl0li;
	reg	nl0ll;
	reg	nl0lO;
	reg	nl0Oi;
	reg	nl0Ol;
	reg	nl0OO;
	reg	nl10i;
	reg	nl10li58;
	reg	nl10li59;
	reg	nl10li60;
	reg	nl10lO55;
	reg	nl10lO56;
	reg	nl10lO57;
	reg	nl10Ol52;
	reg	nl10Ol53;
	reg	nl10Ol54;
	reg	nl11i;
	reg	nl11l;
	reg	nl11O;
	reg	nl1i0l46;
	reg	nl1i0l47;
	reg	nl1i0l48;
	reg	nl1i1i49;
	reg	nl1i1i50;
	reg	nl1i1i51;
	reg	nl1ili43;
	reg	nl1ili44;
	reg	nl1ili45;
	reg	nl1iOl40;
	reg	nl1iOl41;
	reg	nl1iOl42;
	reg	nl1l0O34;
	reg	nl1l0O35;
	reg	nl1l0O36;
	reg	nl1l1l37;
	reg	nl1l1l38;
	reg	nl1l1l39;
	reg	nl1lli31;
	reg	nl1lli32;
	reg	nl1lli33;
	reg	nl1lOO28;
	reg	nl1lOO29;
	reg	nl1lOO30;
	reg	nl1O1O25;
	reg	nl1O1O26;
	reg	nl1O1O27;
	reg	nl1Oli22;
	reg	nl1Oli23;
	reg	nl1Oli24;
	reg	nl1OOi19;
	reg	nl1OOi20;
	reg	nl1OOi21;
	reg	nli0i;
	reg	nli0l;
	reg	nli0O;
	reg	nli0Ol;
	reg	nli0OO;
	reg	nli1i;
	reg	nli1l;
	reg	nli1O;
	reg	nlii0i;
	reg	nlii0l;
	reg	nlii0O;
	reg	nlii1i;
	reg	nlii1l;
	reg	nlii1O;
	reg	nliii;
	reg	nliiii;
	reg	nliiil;
	reg	nliiiO;
	reg	nliil;
	reg	nliili;
	reg	nliill;
	reg	nliilO;
	reg	nliiO;
	reg	nliiOi;
	reg	nliiOl;
	reg	nliiOO;
	reg	nlil0i;
	reg	nlil0l;
	reg	nlil0O;
	reg	nlil1i;
	reg	nlil1l;
	reg	nlil1O;
	reg	nlili;
	reg	nlilii;
	reg	nlilil;
	reg	nliliO;
	reg	nlill;
	reg	nlilli;
	reg	nlilll;
	reg	nlillO;
	reg	nlilO;
	reg	nlilOi;
	reg	nlilOl;
	reg	nlilOO;
	reg	nliO0i;
	reg	nliO0l;
	reg	nliO0O;
	reg	nliO1i;
	reg	nliO1l;
	reg	nliO1O;
	reg	nliOi;
	reg	nliOii;
	reg	nliOil;
	reg	nliOiO;
	reg	nliOl;
	reg	nliOli;
	reg	nliOll;
	reg	nliOlO;
	reg	nliOO;
	reg	nll0i;
	reg	nll0l;
	reg	nll0O;
	reg	nll1i;
	reg	nll1l;
	reg	nll1O;
	reg	nllOO;
	reg	nlO01i;
	reg	nlO1i;
	reg	nlO1Ol;
	reg	nlO1OO;
	wire	wire_n000i_dataout;
	wire	wire_n000l_dataout;
	wire	wire_n000O_dataout;
	wire	wire_n001i_dataout;
	wire	wire_n001l_dataout;
	wire	wire_n001O_dataout;
	wire	wire_n00ii_dataout;
	wire	wire_n00il_dataout;
	wire	wire_n00iO_dataout;
	wire	wire_n00li_dataout;
	wire	wire_n00ll_dataout;
	wire	wire_n00lO_dataout;
	wire	wire_n00Oi_dataout;
	wire	wire_n00Ol_dataout;
	wire	wire_n00OO_dataout;
	wire	wire_n010i_dataout;
	wire	wire_n010l_dataout;
	wire	wire_n010O_dataout;
	wire	wire_n011i_dataout;
	wire	wire_n011l_dataout;
	wire	wire_n011O_dataout;
	wire	wire_n01ii_dataout;
	wire	wire_n01il_dataout;
	wire	wire_n01iO_dataout;
	wire	wire_n01li_dataout;
	wire	wire_n01ll_dataout;
	wire	wire_n01lO_dataout;
	wire	wire_n01Oi_dataout;
	wire	wire_n01Ol_dataout;
	wire	wire_n01OO_dataout;
	wire	wire_n0i0i_dataout;
	wire	wire_n0i0l_dataout;
	wire	wire_n0i0O_dataout;
	wire	wire_n0i1i_dataout;
	wire	wire_n0i1l_dataout;
	wire	wire_n0i1O_dataout;
	wire	wire_n0iii_dataout;
	wire	wire_n0ill_dataout;
	wire	wire_n0ilO_dataout;
	wire	wire_n0iOi_dataout;
	wire	wire_n0iOl_dataout;
	wire	wire_n0iOO_dataout;
	wire	wire_n0l0i_dataout;
	wire	wire_n0l1i_dataout;
	wire	wire_n0l1l_dataout;
	wire	wire_n0l1O_dataout;
	wire	wire_n0lOO_dataout;
	wire	wire_n0O0i_dataout;
	wire	wire_n0O0l_dataout;
	wire	wire_n0O0O_dataout;
	wire	wire_n0O1i_dataout;
	wire	wire_n0O1l_dataout;
	wire	wire_n0O1O_dataout;
	wire	wire_n0Oii_dataout;
	wire	wire_n0Oil_dataout;
	wire	wire_n0OiO_dataout;
	wire	wire_n0Oli_dataout;
	wire	wire_n0Oll_dataout;
	wire	wire_n0OlO_dataout;
	wire	wire_n0OOi_dataout;
	wire	wire_n0OOl_dataout;
	wire	wire_n0OOO_dataout;
	wire	wire_n100i_dataout;
	wire	wire_n100l_dataout;
	wire	wire_n100O_dataout;
	wire	wire_n101i_dataout;
	wire	wire_n101l_dataout;
	wire	wire_n101O_dataout;
	wire	wire_n10ii_dataout;
	wire	wire_n10il_dataout;
	wire	wire_n10iO_dataout;
	wire	wire_n10li_dataout;
	wire	wire_n10Ol_dataout;
	wire	wire_n10OO_dataout;
	wire	wire_n110i_dataout;
	wire	wire_n110l_dataout;
	wire	wire_n110O_dataout;
	wire	wire_n111i_dataout;
	wire	wire_n111l_dataout;
	wire	wire_n111O_dataout;
	wire	wire_n11ii_dataout;
	wire	wire_n11il_dataout;
	wire	wire_n11iO_dataout;
	wire	wire_n11li_dataout;
	wire	wire_n11ll_dataout;
	wire	wire_n11lO_dataout;
	wire	wire_n11Oi_dataout;
	wire	wire_n11Ol_dataout;
	wire	wire_n11OO_dataout;
	wire	wire_n1i0i_dataout;
	wire	wire_n1i0l_dataout;
	wire	wire_n1i0O_dataout;
	wire	wire_n1i1i_dataout;
	wire	wire_n1i1l_dataout;
	wire	wire_n1i1O_dataout;
	wire	wire_n1iii_dataout;
	wire	wire_n1l0i_dataout;
	wire	wire_n1l0l_dataout;
	wire	wire_n1l0O_dataout;
	wire	wire_n1l1O_dataout;
	wire	wire_n1lii_dataout;
	wire	wire_n1lil_dataout;
	wire	wire_n1liO_dataout;
	wire	wire_n1lli_dataout;
	wire	wire_n1lll_dataout;
	wire	wire_n1llO_dataout;
	wire	wire_n1lOi_dataout;
	wire	wire_n1lOl_dataout;
	wire	wire_n1lOO_dataout;
	wire	wire_n1O0i_dataout;
	wire	wire_n1O0l_dataout;
	wire	wire_n1O0O_dataout;
	wire	wire_n1O1i_dataout;
	wire	wire_n1O1l_dataout;
	wire	wire_n1O1O_dataout;
	wire	wire_n1Oii_dataout;
	wire	wire_n1Oil_dataout;
	wire	wire_n1OiO_dataout;
	wire	wire_n1Oli_dataout;
	wire	wire_n1Oll_dataout;
	wire	wire_n1OlO_dataout;
	wire	wire_n1OOi_dataout;
	wire	wire_n1OOl_dataout;
	wire	wire_n1OOO_dataout;
	wire	wire_ni00i_dataout;
	wire	wire_ni00l_dataout;
	wire	wire_ni00O_dataout;
	wire	wire_ni01i_dataout;
	wire	wire_ni01l_dataout;
	wire	wire_ni01O_dataout;
	wire	wire_ni0ii_dataout;
	wire	wire_ni0il_dataout;
	wire	wire_ni0iO_dataout;
	wire	wire_ni0li_dataout;
	wire	wire_ni0ll_dataout;
	wire	wire_ni0lO_dataout;
	wire	wire_ni0Oi_dataout;
	wire	wire_ni0Ol_dataout;
	wire	wire_ni0OO_dataout;
	wire	wire_ni10i_dataout;
	wire	wire_ni10l_dataout;
	wire	wire_ni10O_dataout;
	wire	wire_ni11i_dataout;
	wire	wire_ni11l_dataout;
	wire	wire_ni11O_dataout;
	wire	wire_ni1ii_dataout;
	wire	wire_ni1il_dataout;
	wire	wire_ni1iO_dataout;
	wire	wire_ni1li_dataout;
	wire	wire_ni1ll_dataout;
	wire	wire_ni1lO_dataout;
	wire	wire_ni1Oi_dataout;
	wire	wire_ni1Ol_dataout;
	wire	wire_ni1OO_dataout;
	wire	wire_nii0i_dataout;
	wire	wire_nii0l_dataout;
	wire	wire_nii0O_dataout;
	wire	wire_nii1i_dataout;
	wire	wire_nii1l_dataout;
	wire	wire_nii1O_dataout;
	wire	wire_niiii_dataout;
	wire	wire_niiil_dataout;
	wire	wire_niiiO_dataout;
	wire	wire_nil0i_dataout;
	wire	wire_nil0l_dataout;
	wire	wire_nil0O_dataout;
	wire	wire_nil1i_dataout;
	wire	wire_nil1l_dataout;
	wire	wire_nil1O_dataout;
	wire	wire_nilii_dataout;
	wire	wire_nilil_dataout;
	wire	wire_niliO_dataout;
	wire	wire_nilli_dataout;
	wire	wire_nilll_dataout;
	wire	wire_nillO_dataout;
	wire	wire_nilOi_dataout;
	wire	wire_nilOl_dataout;
	wire	wire_nilOO_dataout;
	wire	wire_niO1i_dataout;
	wire	wire_niO1l_dataout;
	wire	wire_nl10l_dataout;
	wire	wire_nl10O_dataout;
	wire	wire_nl1ii_dataout;
	wire	wire_nl1il_dataout;
	wire	wire_nl1iO_dataout;
	wire	wire_nl1li_dataout;
	wire	wire_nl1ll_dataout;
	wire	wire_nl1lO_dataout;
	wire	wire_nl1Oi_dataout;
	wire	wire_nl1Ol_dataout;
	wire	wire_nliOOi_dataout;
	wire	wire_nliOOl_dataout;
	wire	wire_nliOOO_dataout;
	wire	wire_nll00i_dataout;
	wire	wire_nll00l_dataout;
	wire	wire_nll00O_dataout;
	wire	wire_nll01O_dataout;
	wire	wire_nll0ii_dataout;
	wire	wire_nll0il_dataout;
	wire	wire_nll0iO_dataout;
	wire	wire_nll0li_dataout;
	wire	wire_nll0ll_dataout;
	wire	wire_nll0lO_dataout;
	wire	wire_nll0Oi_dataout;
	wire	wire_nll0Ol_dataout;
	wire	wire_nll0OO_dataout;
	wire	wire_nll10i_dataout;
	wire	wire_nll10l_dataout;
	wire	wire_nll10O_dataout;
	wire	wire_nll11i_dataout;
	wire	wire_nll11l_dataout;
	wire	wire_nll11O_dataout;
	wire	wire_nlli0i_dataout;
	wire	wire_nlli0l_dataout;
	wire	wire_nlli0O_dataout;
	wire	wire_nlli1i_dataout;
	wire	wire_nlli1l_dataout;
	wire	wire_nlli1O_dataout;
	wire	wire_nllii_dataout;
	wire	wire_nlliii_dataout;
	wire	wire_nlliil_dataout;
	wire	wire_nlliiO_dataout;
	wire	wire_nllil_dataout;
	wire	wire_nllili_dataout;
	wire	wire_nllill_dataout;
	wire	wire_nllilO_dataout;
	wire	wire_nlliOi_dataout;
	wire	wire_nlliOl_dataout;
	wire	wire_nlll0i_dataout;
	wire	wire_nlll0l_dataout;
	wire	wire_nlll0O_dataout;
	wire	wire_nlll1O_dataout;
	wire	wire_nlllii_dataout;
	wire	wire_nlllil_dataout;
	wire	wire_nllliO_dataout;
	wire	wire_nlllli_dataout;
	wire	wire_nlllll_dataout;
	wire	wire_nllllO_dataout;
	wire	wire_nlllOi_dataout;
	wire	wire_nlllOl_dataout;
	wire	wire_nlllOO_dataout;
	wire	wire_nllO0i_dataout;
	wire	wire_nllO0l_dataout;
	wire	wire_nllO0O_dataout;
	wire	wire_nllO1i_dataout;
	wire	wire_nllO1l_dataout;
	wire	wire_nllO1O_dataout;
	wire	wire_nllOii_dataout;
	wire	wire_nllOil_dataout;
	wire	wire_nllOiO_dataout;
	wire	wire_nllOli_dataout;
	wire	wire_nllOll_dataout;
	wire	wire_nllOlO_dataout;
	wire	wire_nllOOi_dataout;
	wire	wire_nllOOl_dataout;
	wire	wire_nllOOO_dataout;
	wire	wire_nlO00i_dataout;
	wire	wire_nlO00l_dataout;
	wire	wire_nlO00O_dataout;
	wire	wire_nlO01l_dataout;
	wire	wire_nlO01O_dataout;
	wire	wire_nlO0ii_dataout;
	wire	wire_nlO0il_dataout;
	wire	wire_nlO0iO_dataout;
	wire	wire_nlO0li_dataout;
	wire	wire_nlO10l_dataout;
	wire	wire_nlO10O_dataout;
	wire	wire_nlO11i_dataout;
	wire	wire_nlO11l_dataout;
	wire	wire_nlO11O_dataout;
	wire	wire_nlO1ii_dataout;
	wire	wire_nlO1il_dataout;
	wire	wire_nlO1iO_dataout;
	wire	wire_nlO1li_dataout;
	wire	wire_nlO1ll_dataout;
	wire	wire_nlO1lO_dataout;
	wire	wire_nlO1Oi_dataout;
	wire	wire_nlOi0O_dataout;
	wire	wire_nlOiii_dataout;
	wire	wire_nlOiil_dataout;
	wire	wire_nlOiiO_dataout;
	wire	wire_nlOili_dataout;
	wire	wire_nlOill_dataout;
	wire	wire_nlOilO_dataout;
	wire	wire_nlOiOi_dataout;
	wire	wire_nlOiOl_dataout;
	wire	wire_nlOiOO_dataout;
	wire	wire_nlOl0i_dataout;
	wire	wire_nlOl0l_dataout;
	wire	wire_nlOl0O_dataout;
	wire	wire_nlOl1i_dataout;
	wire	wire_nlOl1l_dataout;
	wire	wire_nlOl1O_dataout;
	wire	wire_nlOlii_dataout;
	wire	wire_nlOlil_dataout;
	wire	wire_nlOliO_dataout;
	wire	wire_nlOlli_dataout;
	wire	wire_nlOlll_dataout;
	wire	wire_nlOllO_dataout;
	wire	wire_nlOlOi_dataout;
	wire	wire_nlOlOl_dataout;
	wire	wire_nlOlOO_dataout;
	wire	wire_nlOO0i_dataout;
	wire	wire_nlOO0l_dataout;
	wire	wire_nlOO0O_dataout;
	wire	wire_nlOO1i_dataout;
	wire	wire_nlOO1l_dataout;
	wire	wire_nlOO1O_dataout;
	wire	wire_nlOOii_dataout;
	wire	wire_nlOOil_dataout;
	wire	wire_nlOOiO_dataout;
	wire	wire_nlOOli_dataout;
	wire	wire_nlOOll_dataout;
	wire	wire_nlOOlO_dataout;
	wire	wire_nlOOOi_dataout;
	wire	wire_nlOOOl_dataout;
	wire	wire_nlOOOO_dataout;
	wire  [5:0]   wire_nl1OO_o;
	wire  [15:0]   wire_nll01l_o;
	wire  wire_niOOi_o;
	wire  wire_n0l0l_o;
	wire  wire_n0l0O_o;
	wire  wire_n0lii_o;
	wire  wire_n0lil_o;
	wire  wire_n0liO_o;
	wire  wire_n0lli_o;
	wire  wire_n0lll_o;
	wire  wire_n0llO_o;
	wire  wire_n0lOi_o;
	wire  wire_n1iil_o;
	wire  wire_n1iiO_o;
	wire  wire_n1ili_o;
	wire  wire_n1ill_o;
	wire  wire_n1ilO_o;
	wire  wire_n1iOi_o;
	wire  wire_n1iOl_o;
	wire  wire_n1iOO_o;
	wire  wire_n1l1i_o;
	wire  wire_niili_o;
	wire  wire_niilO_o;
	wire  wire_niiOl_o;
	wire  wire_nll1ii_o;
	wire  wire_nll1il_o;
	wire  wire_nll1iO_o;
	wire  wire_nll1li_o;
	wire  wire_nll1ll_o;
	wire  wire_nll1lO_o;
	wire  wire_nll1Oi_o;
	wire  wire_nll1Ol_o;
	wire  wire_nll1OO_o;
	wire  wire_nlO0ll_o;
	wire  wire_nlO0lO_o;
	wire  wire_nlO0Oi_o;
	wire  wire_nlO0Ol_o;
	wire  wire_nlO0OO_o;
	wire  wire_nlOi0i_o;
	wire  wire_nlOi1i_o;
	wire  wire_nlOi1l_o;
	wire  wire_nlOi1O_o;
	wire  niOOil;
	wire  niOOiO;
	wire  niOOli;
	wire  niOOll;
	wire  niOOlO;
	wire  niOOOi;
	wire  niOOOl;
	wire  niOOOO;
	wire  nl000O;
	wire  nl001O;
	wire  nl00ii;
	wire  nl00il;
	wire  nl00iO;
	wire  nl010O;
	wire  nl011O;
	wire  nl01ii;
	wire  nl01il;
	wire  nl01iO;
	wire  nl01li;
	wire  nl01Oi;
	wire  nl01Ol;
	wire  nl01OO;
	wire  nl100i;
	wire  nl100l;
	wire  nl100O;
	wire  nl101i;
	wire  nl101l;
	wire  nl101O;
	wire  nl10ii;
	wire  nl10il;
	wire  nl10iO;
	wire  nl110i;
	wire  nl110l;
	wire  nl110O;
	wire  nl111i;
	wire  nl111l;
	wire  nl111O;
	wire  nl11ii;
	wire  nl11il;
	wire  nl11iO;
	wire  nl11li;
	wire  nl11ll;
	wire  nl11lO;
	wire  nl11Oi;
	wire  nl11Ol;
	wire  nl11OO;
	wire  nl1i0i;
	wire  nl1i1O;
	wire  nl1iii;
	wire  nl1iil;
	wire  nl1iiO;
	wire  nl1ilO;
	wire  nl1iOi;
	wire  nl1l0i;
	wire  nl1l0l;
	wire  nl1l1i;
	wire  nl1lil;
	wire  nl1liO;
	wire  nl1llO;
	wire  nl1lOi;
	wire  nl1lOl;
	wire  nl1O0l;
	wire  nl1O0O;
	wire  nl1O1l;
	wire  nl1Oii;
	wire  nl1Oil;
	wire  nl1OiO;
	wire  nl1OlO;
	wire  nl1OOO;
	wire  w_nl000i80w;
	wire  w_nl001i95w;
	wire  w_nl00li21w;
	wire  w_nl010i174w;
	wire  w_nl011i182w;
	wire  w_nl01ll130w;
	wire  w_nl10li364w;
	wire  w_nl10lO359w;
	wire  w_nl10Ol354w;
	wire  w_nl1i0l334w;
	wire  w_nl1i1i345w;
	wire  w_nl1ili317w;
	wire  w_nl1iOl308w;
	wire  w_nl1l0O288w;
	wire  w_nl1l1l301w;
	wire  w_nl1lli271w;
	wire  w_nl1lOO246w;
	wire  w_nl1O1O234w;
	wire  w_nl1Oli198w;
	wire  w_nl1OOi190w;

	initial
		n0iil = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) n0iil <= 1'b0;
		else   n0iil <= wire_n0ilO_dataout;
	initial
		n0iiO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) n0iiO <= 1'b0;
		else   n0iiO <= wire_n0iOi_dataout;
	initial
		n0ili = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) n0ili <= 1'b0;
		else   n0ili <= wire_n0l1O_dataout;
	initial
		n10ll = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) n10ll <= 1'b0;
		else   n10ll <= wire_n10OO_dataout;
	initial
		n10lO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) n10lO <= 1'b0;
		else   n10lO <= wire_n1i1i_dataout;
	initial
		n10Oi = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) n10Oi <= 1'b0;
		else   n10Oi <= wire_n1i0O_dataout;
	initial
		nl000i4 = 1'b1;
	always @ ( posedge nl00iO)
		  nl000i4 <= nl000i5;
	initial
		nl000i5 = 0;
	always @ ( posedge nl00iO)
		  nl000i5 <= nl000i4;
	initial
		nl000i6 = 0;
	always @ ( posedge nl00iO)
		  nl000i6 <= (nl000i5 ^ nl000i4);
	initial
		nl001i7 = 1'b1;
	always @ ( posedge nl00iO)
		  nl001i7 <= nl001i8;
	initial
		nl001i8 = 0;
	always @ ( posedge nl00iO)
		  nl001i8 <= nl001i7;
	initial
		nl001i9 = 0;
	always @ ( posedge nl00iO)
		  nl001i9 <= (nl001i8 ^ nl001i7);
	initial
		nl00li1 = 1'b1;
	always @ ( posedge nl00iO)
		  nl00li1 <= nl00li2;
	initial
		nl00li2 = 0;
	always @ ( posedge nl00iO)
		  nl00li2 <= nl00li1;
	initial
		nl00li3 = 0;
	always @ ( posedge nl00iO)
		  nl00li3 <= (nl00li2 ^ nl00li1);
	initial
		nl010i13 = 1'b1;
	always @ ( posedge nl00iO)
		  nl010i13 <= nl010i14;
	initial
		nl010i14 = 0;
	always @ ( posedge nl00iO)
		  nl010i14 <= nl010i13;
	initial
		nl010i15 = 0;
	always @ ( posedge nl00iO)
		  nl010i15 <= (nl010i14 ^ nl010i13);
	initial
		nl011i16 = 1'b1;
	always @ ( posedge nl00iO)
		  nl011i16 <= nl011i17;
	initial
		nl011i17 = 0;
	always @ ( posedge nl00iO)
		  nl011i17 <= nl011i16;
	initial
		nl011i18 = 0;
	always @ ( posedge nl00iO)
		  nl011i18 <= (nl011i17 ^ nl011i16);
	initial
		nl01ll10 = 1'b1;
	always @ ( posedge nl00iO)
		  nl01ll10 <= nl01ll11;
	initial
		nl01ll11 = 0;
	always @ ( posedge nl00iO)
		  nl01ll11 <= nl01ll10;
	initial
		nl01ll12 = 0;
	always @ ( posedge nl00iO)
		  nl01ll12 <= (nl01ll11 ^ nl01ll10);
	initial
		nl0li = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nl0li <= 1'b0;
		else if  (nl11iO == 1'b1)   nl0li <= txdatain[0:0];
	initial
		nl0ll = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nl0ll <= 1'b0;
		else if  (nl11iO == 1'b1)   nl0ll <= txdatain[1:1];
	initial
		nl0lO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nl0lO <= 1'b0;
		else if  (nl11iO == 1'b1)   nl0lO <= txdatain[5:5];
	initial
		nl0Oi = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nl0Oi <= 1'b0;
		else if  (nl11iO == 1'b1)   nl0Oi <= txdatain[6:6];
	initial
		nl0Ol = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nl0Ol <= 1'b0;
		else if  (nl11iO == 1'b1)   nl0Ol <= txdatain[8:8];
	initial
		nl0OO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nl0OO <= 1'b0;
		else if  (nl11iO == 1'b1)   nl0OO <= txdatain[9:9];
	initial
		nl10i = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nl10i <= 1'b0;
		else   nl10i <= wire_nl1il_dataout;
	initial
		nl10li58 = 1'b1;
	always @ ( posedge nl00iO)
		  nl10li58 <= nl10li59;
	initial
		nl10li59 = 0;
	always @ ( posedge nl00iO)
		  nl10li59 <= nl10li58;
	initial
		nl10li60 = 0;
	always @ ( posedge nl00iO)
		  nl10li60 <= (nl10li59 ^ nl10li58);
	initial
		nl10lO55 = 1'b1;
	always @ ( posedge nl00iO)
		  nl10lO55 <= nl10lO56;
	initial
		nl10lO56 = 0;
	always @ ( posedge nl00iO)
		  nl10lO56 <= nl10lO55;
	initial
		nl10lO57 = 0;
	always @ ( posedge nl00iO)
		  nl10lO57 <= (nl10lO56 ^ nl10lO55);
	initial
		nl10Ol52 = 1'b1;
	always @ ( posedge nl00iO)
		  nl10Ol52 <= nl10Ol53;
	initial
		nl10Ol53 = 0;
	always @ ( posedge nl00iO)
		  nl10Ol53 <= nl10Ol52;
	initial
		nl10Ol54 = 0;
	always @ ( posedge nl00iO)
		  nl10Ol54 <= (nl10Ol53 ^ nl10Ol52);
	initial
		nl11i = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nl11i <= 1'b0;
		else   nl11i <= wire_nl10l_dataout;
	initial
		nl11l = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nl11l <= 1'b0;
		else   nl11l <= wire_nl10O_dataout;
	initial
		nl11O = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nl11O <= 1'b0;
		else   nl11O <= wire_nl1ii_dataout;
	initial
		nl1i0l46 = 1'b1;
	always @ ( posedge nl00iO)
		  nl1i0l46 <= nl1i0l47;
	initial
		nl1i0l47 = 0;
	always @ ( posedge nl00iO)
		  nl1i0l47 <= nl1i0l46;
	initial
		nl1i0l48 = 0;
	always @ ( posedge nl00iO)
		  nl1i0l48 <= (nl1i0l47 ^ nl1i0l46);
	initial
		nl1i1i49 = 1'b1;
	always @ ( posedge nl00iO)
		  nl1i1i49 <= nl1i1i50;
	initial
		nl1i1i50 = 0;
	always @ ( posedge nl00iO)
		  nl1i1i50 <= nl1i1i49;
	initial
		nl1i1i51 = 0;
	always @ ( posedge nl00iO)
		  nl1i1i51 <= (nl1i1i50 ^ nl1i1i49);
	initial
		nl1ili43 = 1'b1;
	always @ ( posedge nl00iO)
		  nl1ili43 <= nl1ili44;
	initial
		nl1ili44 = 0;
	always @ ( posedge nl00iO)
		  nl1ili44 <= nl1ili43;
	initial
		nl1ili45 = 0;
	always @ ( posedge nl00iO)
		  nl1ili45 <= (nl1ili44 ^ nl1ili43);
	initial
		nl1iOl40 = 1'b1;
	always @ ( posedge nl00iO)
		  nl1iOl40 <= nl1iOl41;
	initial
		nl1iOl41 = 0;
	always @ ( posedge nl00iO)
		  nl1iOl41 <= nl1iOl40;
	initial
		nl1iOl42 = 0;
	always @ ( posedge nl00iO)
		  nl1iOl42 <= (nl1iOl41 ^ nl1iOl40);
	initial
		nl1l0O34 = 1'b1;
	always @ ( posedge nl00iO)
		  nl1l0O34 <= nl1l0O35;
	initial
		nl1l0O35 = 0;
	always @ ( posedge nl00iO)
		  nl1l0O35 <= nl1l0O34;
	initial
		nl1l0O36 = 0;
	always @ ( posedge nl00iO)
		  nl1l0O36 <= (nl1l0O35 ^ nl1l0O34);
	initial
		nl1l1l37 = 1'b1;
	always @ ( posedge nl00iO)
		  nl1l1l37 <= nl1l1l38;
	initial
		nl1l1l38 = 0;
	always @ ( posedge nl00iO)
		  nl1l1l38 <= nl1l1l37;
	initial
		nl1l1l39 = 0;
	always @ ( posedge nl00iO)
		  nl1l1l39 <= (nl1l1l38 ^ nl1l1l37);
	initial
		nl1lli31 = 1'b1;
	always @ ( posedge nl00iO)
		  nl1lli31 <= nl1lli32;
	initial
		nl1lli32 = 0;
	always @ ( posedge nl00iO)
		  nl1lli32 <= nl1lli31;
	initial
		nl1lli33 = 0;
	always @ ( posedge nl00iO)
		  nl1lli33 <= (nl1lli32 ^ nl1lli31);
	initial
		nl1lOO28 = 1'b1;
	always @ ( posedge nl00iO)
		  nl1lOO28 <= nl1lOO29;
	initial
		nl1lOO29 = 0;
	always @ ( posedge nl00iO)
		  nl1lOO29 <= nl1lOO28;
	initial
		nl1lOO30 = 0;
	always @ ( posedge nl00iO)
		  nl1lOO30 <= (nl1lOO29 ^ nl1lOO28);
	initial
		nl1O1O25 = 1'b1;
	always @ ( posedge nl00iO)
		  nl1O1O25 <= nl1O1O26;
	initial
		nl1O1O26 = 0;
	always @ ( posedge nl00iO)
		  nl1O1O26 <= nl1O1O25;
	initial
		nl1O1O27 = 0;
	always @ ( posedge nl00iO)
		  nl1O1O27 <= (nl1O1O26 ^ nl1O1O25);
	initial
		nl1Oli22 = 1'b1;
	always @ ( posedge nl00iO)
		  nl1Oli22 <= nl1Oli23;
	initial
		nl1Oli23 = 0;
	always @ ( posedge nl00iO)
		  nl1Oli23 <= nl1Oli22;
	initial
		nl1Oli24 = 0;
	always @ ( posedge nl00iO)
		  nl1Oli24 <= (nl1Oli23 ^ nl1Oli22);
	initial
		nl1OOi19 = 1'b1;
	always @ ( posedge nl00iO)
		  nl1OOi19 <= nl1OOi20;
	initial
		nl1OOi20 = 0;
	always @ ( posedge nl00iO)
		  nl1OOi20 <= nl1OOi19;
	initial
		nl1OOi21 = 0;
	always @ ( posedge nl00iO)
		  nl1OOi21 <= (nl1OOi20 ^ nl1OOi19);
	initial
		nli0i = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nli0i <= 1'b0;
		else if  (nl11iO == 1'b1)   nli0i <= txdatain[13:13];
	initial
		nli0l = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nli0l <= 1'b0;
		else if  (nl11iO == 1'b1)   nli0l <= txdatain[14:14];
	initial
		nli0O = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nli0O <= 1'b0;
		else if  (nl11iO == 1'b1)   nli0O <= txdatain[15:15];
	initial
		nli0Ol = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nli0Ol <= 1'b1;
		else   nli0Ol <= wire_nliOOi_dataout;
	initial
		nli0OO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nli0OO <= 1'b1;
		else   nli0OO <= wire_nll11i_dataout;
	initial
		nli1i = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nli1i <= 1'b0;
		else if  (nl11iO == 1'b1)   nli1i <= txdatain[10:10];
	initial
		nli1l = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nli1l <= 1'b0;
		else if  (nl11iO == 1'b1)   nli1l <= txdatain[11:11];
	initial
		nli1O = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nli1O <= 1'b0;
		else if  (nl11iO == 1'b1)   nli1O <= txdatain[12:12];
	initial
		nlii0i = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlii0i <= 1'b1;
		else   nlii0i <= wire_nll10O_dataout;
	initial
		nlii0l = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlii0l <= 1'b1;
		else   nlii0l <= wire_nlO01l_dataout;
	initial
		nlii0O = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlii0O <= 1'b1;
		else   nlii0O <= wire_nlO00l_dataout;
	initial
		nlii1i = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlii1i <= 1'b1;
		else   nlii1i <= wire_nll11l_dataout;
	initial
		nlii1l = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlii1l <= 1'b1;
		else   nlii1l <= wire_nll11O_dataout;
	initial
		nlii1O = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlii1O <= 1'b1;
		else   nlii1O <= wire_nll10i_dataout;
	initial
		nliii = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliii <= 1'b0;
		else if  (nl11iO == 1'b1)   nliii <= txdatain[16:16];
	initial
		nliiii = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliiii <= 1'b1;
		else   nliiii <= wire_nlO00O_dataout;
	initial
		nliiil = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliiil <= 1'b1;
		else   nliiil <= wire_nlO0ii_dataout;
	initial
		nliiiO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliiiO <= 1'b1;
		else   nliiiO <= wire_nlO0il_dataout;
	initial
		nliil = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliil <= 1'b0;
		else if  (nl11iO == 1'b1)   nliil <= txdatain[17:17];
	initial
		nliili = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliili <= 1'b1;
		else   nliili <= wire_nlO0li_dataout;
	initial
		nliill = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliill <= 1'b1;
		else   nliill <= wire_n10Ol_dataout;
	initial
		nliilO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliilO <= 1'b1;
		else   nliilO <= wire_n1i1l_dataout;
	initial
		nliiO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliiO <= 1'b0;
		else if  (nl11iO == 1'b1)   nliiO <= txdatain[18:18];
	initial
		nliiOi = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliiOi <= 1'b1;
		else   nliiOi <= wire_n1i1O_dataout;
	initial
		nliiOl = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliiOl <= 1'b1;
		else   nliiOl <= wire_n1i0i_dataout;
	initial
		nliiOO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliiOO <= 1'b1;
		else   nliiOO <= wire_n1i0l_dataout;
	initial
		nlil0i = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlil0i <= 1'b1;
		else   nlil0i <= wire_n0iOO_dataout;
	initial
		nlil0l = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlil0l <= 1'b1;
		else   nlil0l <= wire_n0l1i_dataout;
	initial
		nlil0O = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlil0O <= 1'b1;
		else   nlil0O <= wire_n0l1l_dataout;
	initial
		nlil1i = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlil1i <= 1'b1;
		else   nlil1i <= wire_n1iii_dataout;
	initial
		nlil1l = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlil1l <= 1'b1;
		else   nlil1l <= wire_n0ill_dataout;
	initial
		nlil1O = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlil1O <= 1'b1;
		else   nlil1O <= wire_n0iOl_dataout;
	initial
		nlili = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlili <= 1'b0;
		else if  (nl11iO == 1'b1)   nlili <= txdatain[19:19];
	initial
		nlilii = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlilii <= 1'b1;
		else   nlilii <= wire_n0l0i_dataout;
	initial
		nlilil = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlilil <= 1'b1;
		else   nlilil <= wire_niO1i_dataout;
	initial
		nliliO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliliO <= 1'b1;
		else   nliliO <= wire_nl1iO_dataout;
	initial
		nlill = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlill <= 1'b0;
		else if  (nl11iO == 1'b1)   nlill <= txdatain[20:20];
	initial
		nlilli = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlilli <= 1'b1;
		else   nlilli <= (nliO1i ^ 
		nlilOO);
	initial
		nlilll = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlilll <= 1'b1;
		else   nlilll <= nlilli;
	initial
		nlillO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlillO <= 1'b1;
		else   nlillO <= nlilll;
	initial
		nlilO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlilO <= 1'b0;
		else if  (nl11iO == 1'b1)   nlilO <= txdatain[21:21];
	initial
		nlilOi = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlilOi <= 1'b1;
		else   nlilOi <= nlillO;
	initial
		nlilOl = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlilOl <= 1'b1;
		else   nlilOl <= nlilOi;
	initial
		nlilOO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlilOO <= 1'b1;
		else   nlilOO <= nlilOl;
	initial
		nliO0i = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliO0i <= 1'b1;
		else if  (nl11iO == 1'b1)   nliO0i <= txdatain[4:4];
	initial
		nliO0l = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliO0l <= 1'b1;
		else if  (nl11iO == 1'b1)   nliO0l <= txdatain[7:7];
	initial
		nliO0O = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliO0O <= 1'b1;
		else if  (nl11iO == 1'b1)   nliO0O <= txdatain[25:25];
	initial
		nliO1i = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliO1i <= 1'b1;
		else   nliO1i <= nlilOO;
	initial
		nliO1l = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliO1l <= 1'b1;
		else if  (nl11iO == 1'b1)   nliO1l <= txdatain[2:2];
	initial
		nliO1O = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliO1O <= 1'b1;
		else if  (nl11iO == 1'b1)   nliO1O <= txdatain[3:3];
	initial
		nliOi = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliOi <= 1'b0;
		else if  (nl11iO == 1'b1)   nliOi <= txdatain[22:22];
	initial
		nliOii = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliOii <= 1'b1;
		else   nliOii <= wire_niili_o;
	initial
		nliOil = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliOil <= 1'b1;
		else   nliOil <= wire_niilO_o;
	initial
		nliOiO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliOiO <= 1'b0;
		else   nliOiO <= wire_nil1i_dataout;
	initial
		nliOl = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliOl <= 1'b0;
		else if  (nl11iO == 1'b1)   nliOl <= txdatain[23:23];
	initial
		nliOli = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliOli <= 1'b0;
		else   nliOli <= wire_nliOOl_dataout;
	initial
		nliOll = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliOll <= 1'b0;
		else   nliOll <= wire_nliOOO_dataout;
	initial
		nliOlO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliOlO <= 1'b0;
		else   nliOlO <= wire_nll10l_dataout;
	initial
		nliOO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nliOO <= 1'b0;
		else if  (nl11iO == 1'b1)   nliOO <= txdatain[24:24];
	initial
		nll0i = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nll0i <= 1'b0;
		else if  (nl11iO == 1'b1)   nll0i <= txdatain[29:29];
	initial
		nll0l = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nll0l <= 1'b0;
		else if  (nl11iO == 1'b1)   nll0l <= txdatain[30:30];
	initial
		nll0O = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nll0O <= 1'b0;
		else if  (nl11iO == 1'b1)   nll0O <= txdatain[31:31];
	initial
		nll1i = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nll1i <= 1'b0;
		else if  (nl11iO == 1'b1)   nll1i <= txdatain[26:26];
	initial
		nll1l = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nll1l <= 1'b0;
		else if  (nl11iO == 1'b1)   nll1l <= txdatain[27:27];
	initial
		nll1O = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nll1O <= 1'b0;
		else if  (nl11iO == 1'b1)   nll1O <= txdatain[28:28];
	initial
		nllOO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nllOO <= 1'b0;
		else   nllOO <= wire_nllii_dataout;
	initial
		nlO01i = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlO01i <= 1'b0;
		else   nlO01i <= wire_nlO0iO_dataout;
	initial
		nlO1i = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlO1i <= 1'b0;
		else   nlO1i <= wire_niiOl_o;
	initial
		nlO1Ol = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlO1Ol <= 1'b0;
		else   nlO1Ol <= wire_nlO01O_dataout;
	initial
		nlO1OO = 0;
	always @ ( posedge txclk or posedge resetall)
		if (resetall == 1'b1) nlO1OO <= 1'b0;
		else   nlO1OO <= wire_nlO00i_dataout;
	assign		wire_n000i_dataout = (nl111i === 1'b1) ? wire_n1O0l_dataout : wire_nllOiO_dataout;
	and(wire_n000l_dataout, wire_n1O1O_dataout, nl111i);
	and(wire_n000O_dataout, wire_n1O0l_dataout, nl111i);
	assign		wire_n001i_dataout = (nllOO === 1'b1) ? nli0O : (~ nlilli);
	assign		wire_n001l_dataout = (nl111i === 1'b1) ? wire_n1O1O_dataout : wire_nllOil_dataout;
	assign		wire_n001O_dataout = (nl111i === 1'b1) ? wire_n1O0i_dataout : (~ nl110O);
	assign		wire_n00ii_dataout = (nl111i === 1'b1) ? wire_n1O1O_dataout : wire_n00iO_dataout;
	assign		wire_n00il_dataout = (nl111i === 1'b1) ? wire_n1O0l_dataout : wire_n00li_dataout;
	and(wire_n00iO_dataout, nli0i, nllOO);
	and(wire_n00li_dataout, nli0O, nllOO);
	or(wire_n00ll_dataout, wire_n1O1O_dataout, ~{nl111i});
	assign		wire_n00lO_dataout = (nl111i === 1'b1) ? wire_n1O0i_dataout : nl111l;
	assign		wire_n00Oi_dataout = (nl111i === 1'b1) ? wire_n1O0l_dataout : (~ nl111l);
	or(wire_n00Ol_dataout, wire_n1l1O_dataout, ~{rdenablesync});
	and(wire_n00OO_dataout, wire_n1l0i_dataout, rdenablesync);
	assign		wire_n010i_dataout = (nl111i === 1'b1) ? wire_n1O1i_dataout : wire_n01lO_dataout;
	assign		wire_n010l_dataout = (nl111i === 1'b1) ? wire_n1O1l_dataout : wire_n01Oi_dataout;
	assign		wire_n010O_dataout = (nl111i === 1'b1) ? wire_n1O1O_dataout : wire_n01Ol_dataout;
	assign		wire_n011i_dataout = (nl111i === 1'b1) ? wire_n1lOi_dataout : wire_n01iO_dataout;
	assign		wire_n011l_dataout = (nl111i === 1'b1) ? wire_n1lOl_dataout : wire_n01li_dataout;
	assign		wire_n011O_dataout = (nl111i === 1'b1) ? wire_n1lOO_dataout : wire_n01ll_dataout;
	assign		wire_n01ii_dataout = (nl111i === 1'b1) ? wire_n1O0i_dataout : wire_n01OO_dataout;
	assign		wire_n01il_dataout = (nl111i === 1'b1) ? wire_n1O0l_dataout : wire_n001i_dataout;
	and(wire_n01iO_dataout, nl0Ol, nllOO);
	and(wire_n01li_dataout, nl0OO, nllOO);
	or(wire_n01ll_dataout, nli1i, ~{nllOO});
	or(wire_n01lO_dataout, nli1l, ~{nllOO});
	or(wire_n01Oi_dataout, nli1O, ~{nllOO});
	assign		wire_n01Ol_dataout = (nllOO === 1'b1) ? nli0i : (~ nlilli);
	and(wire_n01OO_dataout, nli0l, nllOO);
	or(wire_n0i0i_dataout, wire_n1lil_dataout, ~{rdenablesync});
	or(wire_n0i0l_dataout, wire_n000l_dataout, ~{rdenablesync});
	and(wire_n0i0O_dataout, wire_n1lli_dataout, rdenablesync);
	and(wire_n0i1i_dataout, wire_n1l0l_dataout, rdenablesync);
	or(wire_n0i1l_dataout, wire_n1l0O_dataout, ~{rdenablesync});
	or(wire_n0i1O_dataout, wire_n1lii_dataout, ~{rdenablesync});
	or(wire_n0iii_dataout, wire_n000O_dataout, ~{rdenablesync});
	or(wire_n0ill_dataout, wire_n0l0l_o, nl10iO);
	and(wire_n0ilO_dataout, wire_n0l0O_o, ~{nl10iO});
	or(wire_n0iOi_dataout, wire_n0lii_o, nl10iO);
	or(wire_n0iOl_dataout, wire_n0lil_o, nl10iO);
	or(wire_n0iOO_dataout, wire_n0liO_o, nl10iO);
	or(wire_n0l0i_dataout, wire_n0lOi_o, nl10iO);
	or(wire_n0l1i_dataout, wire_n0lli_o, nl10iO);
	or(wire_n0l1l_dataout, wire_n0lll_o, nl10iO);
	or(wire_n0l1O_dataout, wire_n0llO_o, nl10iO);
	or(wire_n0lOO_dataout, wire_n0OiO_dataout, ~{nl111i});
	or(wire_n0O0i_dataout, wire_n0OOi_dataout, ~{nl111i});
	or(wire_n0O0l_dataout, wire_n0OOl_dataout, ~{nl111i});
	assign		wire_n0O0O_dataout = (nl111i === 1'b1) ? wire_n0OOO_dataout : (~ nlilli);
	and(wire_n0O1i_dataout, wire_n0Oli_dataout, nl111i);
	and(wire_n0O1l_dataout, wire_n0Oll_dataout, nl111i);
	or(wire_n0O1O_dataout, wire_n0OlO_dataout, ~{nl111i});
	and(wire_n0Oii_dataout, wire_ni11i_dataout, nl111i);
	assign		wire_n0Oil_dataout = (nl111i === 1'b1) ? wire_ni11l_dataout : (~ nlilli);
	or(wire_n0OiO_dataout, txctrl[0:0], nl101l);
	or(wire_n0Oli_dataout, txdatain[0:0], nl101l);
	and(wire_n0Oll_dataout, txdatain[1:1], ~{nl101l});
	or(wire_n0OlO_dataout, txdatain[2:2], nl101l);
	or(wire_n0OOi_dataout, txdatain[3:3], nl101l);
	or(wire_n0OOl_dataout, txdatain[4:4], nl101l);
	or(wire_n0OOO_dataout, txdatain[5:5], nl101l);
	and(wire_n100i_dataout, wire_nlOiil_dataout, rdenablesync);
	or(wire_n100l_dataout, wire_nlOiiO_dataout, ~{rdenablesync});
	or(wire_n100O_dataout, wire_nlOili_dataout, ~{rdenablesync});
	assign		wire_n101i_dataout = (nl111i === 1'b1) ? wire_nlOlil_dataout : (~ nl111l);
	or(wire_n101l_dataout, wire_nlOi0O_dataout, ~{rdenablesync});
	and(wire_n101O_dataout, wire_nlOiii_dataout, rdenablesync);
	or(wire_n10ii_dataout, wire_nlOill_dataout, ~{rdenablesync});
	or(wire_n10il_dataout, wire_n11il_dataout, ~{rdenablesync});
	and(wire_n10iO_dataout, wire_nlOiOi_dataout, rdenablesync);
	or(wire_n10li_dataout, wire_n11iO_dataout, ~{rdenablesync});
	or(wire_n10Ol_dataout, wire_n1iil_o, nl10il);
	and(wire_n10OO_dataout, wire_n1iiO_o, ~{nl10il});
	assign		wire_n110i_dataout = (nllOO === 1'b1) ? nliOl : (~ nlilli);
	assign		wire_n110l_dataout = (nl111i === 1'b1) ? wire_nlOl0O_dataout : wire_nllOil_dataout;
	assign		wire_n110O_dataout = (nl111i === 1'b1) ? wire_nlOlii_dataout : (~ nl110O);
	or(wire_n111i_dataout, nlill, ~{nllOO});
	assign		wire_n111l_dataout = (nllOO === 1'b1) ? nlilO : (~ nlilli);
	and(wire_n111O_dataout, nliOi, nllOO);
	assign		wire_n11ii_dataout = (nl111i === 1'b1) ? wire_nlOlil_dataout : wire_nllOiO_dataout;
	and(wire_n11il_dataout, wire_nlOl0O_dataout, nl111i);
	and(wire_n11iO_dataout, wire_nlOlil_dataout, nl111i);
	assign		wire_n11li_dataout = (nl111i === 1'b1) ? wire_nlOl0O_dataout : wire_n11lO_dataout;
	assign		wire_n11ll_dataout = (nl111i === 1'b1) ? wire_nlOlil_dataout : wire_n11Oi_dataout;
	and(wire_n11lO_dataout, nlilO, nllOO);
	and(wire_n11Oi_dataout, nliOl, nllOO);
	or(wire_n11Ol_dataout, wire_nlOl0O_dataout, ~{nl111i});
	assign		wire_n11OO_dataout = (nl111i === 1'b1) ? wire_nlOlii_dataout : nl111l;
	or(wire_n1i0i_dataout, wire_n1iOi_o, nl10il);
	or(wire_n1i0l_dataout, wire_n1iOl_o, nl10il);
	or(wire_n1i0O_dataout, wire_n1iOO_o, nl10il);
	or(wire_n1i1i_dataout, wire_n1ili_o, nl10il);
	or(wire_n1i1l_dataout, wire_n1ill_o, nl10il);
	or(wire_n1i1O_dataout, wire_n1ilO_o, nl10il);
	or(wire_n1iii_dataout, wire_n1l1i_o, nl10il);
	and(wire_n1l0i_dataout, wire_n1lOi_dataout, nl111i);
	and(wire_n1l0l_dataout, wire_n1lOl_dataout, nl111i);
	or(wire_n1l0O_dataout, wire_n1lOO_dataout, ~{nl111i});
	or(wire_n1l1O_dataout, wire_n1llO_dataout, ~{nl111i});
	or(wire_n1lii_dataout, wire_n1O1i_dataout, ~{nl111i});
	or(wire_n1lil_dataout, wire_n1O1l_dataout, ~{nl111i});
	assign		wire_n1liO_dataout = (nl111i === 1'b1) ? wire_n1O1O_dataout : (~ nlilli);
	and(wire_n1lli_dataout, wire_n1O0i_dataout, nl111i);
	assign		wire_n1lll_dataout = (nl111i === 1'b1) ? wire_n1O0l_dataout : (~ nlilli);
	or(wire_n1llO_dataout, wire_n1O0O_dataout, nl101l);
	and(wire_n1lOi_dataout, wire_n1Oii_dataout, ~{nl101l});
	and(wire_n1lOl_dataout, wire_n1Oil_dataout, ~{nl101l});
	or(wire_n1lOO_dataout, wire_n1OiO_dataout, nl101l);
	and(wire_n1O0i_dataout, wire_n1OOi_dataout, ~{nl101l});
	or(wire_n1O0l_dataout, wire_n1OOl_dataout, nl101l);
	or(wire_n1O0O_dataout, txctrl[1:1], nl11OO);
	or(wire_n1O1i_dataout, wire_n1Oli_dataout, nl101l);
	or(wire_n1O1l_dataout, wire_n1Oll_dataout, nl101l);
	or(wire_n1O1O_dataout, wire_n1OlO_dataout, nl101l);
	or(wire_n1Oii_dataout, txdatain[8:8], nl11OO);
	and(wire_n1Oil_dataout, txdatain[9:9], ~{nl11OO});
	or(wire_n1OiO_dataout, txdatain[10:10], nl11OO);
	or(wire_n1Oli_dataout, txdatain[11:11], nl11OO);
	or(wire_n1Oll_dataout, txdatain[12:12], nl11OO);
	or(wire_n1OlO_dataout, txdatain[13:13], nl11OO);
	or(wire_n1OOi_dataout, txdatain[14:14], nl11OO);
	or(wire_n1OOl_dataout, txdatain[15:15], nl11OO);
	assign		wire_n1OOO_dataout = (nl111i === 1'b1) ? wire_n1llO_dataout : (~ nllOO);
	assign		wire_ni00i_dataout = (nl111i === 1'b1) ? wire_n0OOO_dataout : wire_nllOil_dataout;
	assign		wire_ni00l_dataout = (nl111i === 1'b1) ? wire_ni11i_dataout : (~ nl110O);
	assign		wire_ni00O_dataout = (nl111i === 1'b1) ? wire_ni11l_dataout : wire_nllOiO_dataout;
	assign		wire_ni01i_dataout = (nllOO === 1'b1) ? nl0lO : (~ nlilli);
	and(wire_ni01l_dataout, nl0Oi, nllOO);
	assign		wire_ni01O_dataout = (nllOO === 1'b1) ? nliO0l : (~ nlilli);
	and(wire_ni0ii_dataout, wire_n0OOO_dataout, nl111i);
	and(wire_ni0il_dataout, wire_ni11l_dataout, nl111i);
	assign		wire_ni0iO_dataout = (nl111i === 1'b1) ? wire_n0OOO_dataout : wire_ni0ll_dataout;
	assign		wire_ni0li_dataout = (nl111i === 1'b1) ? wire_ni11l_dataout : wire_ni0lO_dataout;
	and(wire_ni0ll_dataout, nl0lO, nllOO);
	and(wire_ni0lO_dataout, nliO0l, nllOO);
	or(wire_ni0Oi_dataout, wire_n0OOO_dataout, ~{nl111i});
	assign		wire_ni0Ol_dataout = (nl111i === 1'b1) ? wire_ni11i_dataout : nl111l;
	assign		wire_ni0OO_dataout = (nl111i === 1'b1) ? wire_ni11l_dataout : (~ nl111l);
	assign		wire_ni10i_dataout = (nl111i === 1'b1) ? wire_n0Oll_dataout : wire_ni1lO_dataout;
	assign		wire_ni10l_dataout = (nl111i === 1'b1) ? wire_n0OlO_dataout : wire_ni1Oi_dataout;
	assign		wire_ni10O_dataout = (nl111i === 1'b1) ? wire_n0OOi_dataout : wire_ni1Ol_dataout;
	or(wire_ni11i_dataout, txdatain[6:6], nl101l);
	or(wire_ni11l_dataout, txdatain[7:7], nl101l);
	assign		wire_ni11O_dataout = (nl111i === 1'b1) ? wire_n0Oli_dataout : wire_ni1ll_dataout;
	assign		wire_ni1ii_dataout = (nl111i === 1'b1) ? wire_n0OOl_dataout : wire_ni1OO_dataout;
	assign		wire_ni1il_dataout = (nl111i === 1'b1) ? wire_n0OOO_dataout : wire_ni01i_dataout;
	assign		wire_ni1iO_dataout = (nl111i === 1'b1) ? wire_ni11i_dataout : wire_ni01l_dataout;
	assign		wire_ni1li_dataout = (nl111i === 1'b1) ? wire_ni11l_dataout : wire_ni01O_dataout;
	and(wire_ni1ll_dataout, nl0li, nllOO);
	and(wire_ni1lO_dataout, nl0ll, nllOO);
	or(wire_ni1Oi_dataout, nliO1l, ~{nllOO});
	or(wire_ni1Ol_dataout, nliO1O, ~{nllOO});
	or(wire_ni1OO_dataout, nliO0i, ~{nllOO});
	or(wire_nii0i_dataout, wire_n0O1O_dataout, ~{rdenablesync});
	or(wire_nii0l_dataout, wire_n0O0i_dataout, ~{rdenablesync});
	or(wire_nii0O_dataout, wire_n0O0l_dataout, ~{rdenablesync});
	or(wire_nii1i_dataout, wire_n0lOO_dataout, ~{rdenablesync});
	and(wire_nii1l_dataout, wire_n0O1i_dataout, rdenablesync);
	and(wire_nii1O_dataout, wire_n0O1l_dataout, rdenablesync);
	or(wire_niiii_dataout, wire_ni0ii_dataout, ~{rdenablesync});
	and(wire_niiil_dataout, wire_n0Oii_dataout, rdenablesync);
	or(wire_niiiO_dataout, wire_ni0il_dataout, ~{rdenablesync});
	or(wire_nil0i_dataout, wire_nilil_dataout, nl111i);
	and(wire_nil0l_dataout, wire_niliO_dataout, ~{nl111i});
	and(wire_nil0O_dataout, (~ nllOO), ~{nl111i});
	and(wire_nil1i_dataout, wire_nilii_dataout, wire_nll01l_o[7:7]);
	or(wire_nil1l_dataout, nlilli, nl111i);
	and(wire_nil1O_dataout, (~ nlilli), ~{nl111i});
	and(wire_nilii_dataout, nllOO, ~{nl111i});
	and(wire_nilil_dataout, nlilli, ~{nllOO});
	and(wire_niliO_dataout, (~ nlilli), ~{nllOO});
	or(wire_nilli_dataout, wire_nillO_dataout, nl111i);
	and(wire_nilll_dataout, wire_nllOil_dataout, ~{nl111i});
	or(wire_nillO_dataout, nlilli, (~ nl110O));
	or(wire_nilOi_dataout, (~ nllOO), nl111i);
	or(wire_nilOl_dataout, (~ nl111l), nl111i);
	and(wire_nilOO_dataout, (~ nl111i), rdenablesync);
	or(wire_niO1i_dataout, wire_niO1l_dataout, (((wire_niOOi_o | 
		((~ rdenablesync) & (~ nl110i))) | (nl11il & (rdenablesync & (~ nl110i)))) | (nl111O & ((~ nlilil) | nl110O))));
	and(wire_niO1l_dataout, nlilil, ~{(nl111l & nl111O)});
	assign		wire_nl10l_dataout = (nl110l === 1'b1) ? nlilli : wire_nl1li_dataout;
	assign		wire_nl10O_dataout = (nl110l === 1'b1) ? nlilll : wire_nl1ll_dataout;
	assign		wire_nl1ii_dataout = (nl110l === 1'b1) ? nlillO : wire_nl1lO_dataout;
	assign		wire_nl1il_dataout = (nl110l === 1'b1) ? nlilOi : wire_nl1Oi_dataout;
	or(wire_nl1iO_dataout, wire_nl1Ol_dataout, nl110l);
	assign		wire_nl1li_dataout = (nl110O === 1'b1) ? wire_nl1OO_o[1:1] : nl11i;
	assign		wire_nl1ll_dataout = (nl110O === 1'b1) ? wire_nl1OO_o[2:2] : nl11l;
	assign		wire_nl1lO_dataout = (nl110O === 1'b1) ? wire_nl1OO_o[3:3] : nl11O;
	assign		wire_nl1Oi_dataout = (nl110O === 1'b1) ? wire_nl1OO_o[4:4] : nl10i;
	assign		wire_nl1Ol_dataout = (nl110O === 1'b1) ? wire_nl1OO_o[5:5] : nliliO;
	or(wire_nliOOi_dataout, wire_nll1ii_o, nl100O);
	and(wire_nliOOl_dataout, wire_nll1il_o, ~{nl100O});
	or(wire_nliOOO_dataout, wire_nll1iO_o, nl100O);
	and(wire_nll00i_dataout, wire_nll0Oi_dataout, nl111i);
	and(wire_nll00l_dataout, wire_nll0Ol_dataout, nl111i);
	or(wire_nll00O_dataout, wire_nll0OO_dataout, ~{nl111i});
	or(wire_nll01O_dataout, wire_nll0lO_dataout, ~{nl111i});
	or(wire_nll0ii_dataout, wire_nlli1i_dataout, ~{nl111i});
	or(wire_nll0il_dataout, wire_nlli1l_dataout, ~{nl111i});
	assign		wire_nll0iO_dataout = (nl111i === 1'b1) ? wire_nlli1O_dataout : (~ nlilli);
	and(wire_nll0li_dataout, wire_nlli0i_dataout, nl111i);
	assign		wire_nll0ll_dataout = (nl111i === 1'b1) ? wire_nlli0l_dataout : (~ nlilli);
	or(wire_nll0lO_dataout, wire_nlli0O_dataout, niOOiO);
	and(wire_nll0Oi_dataout, wire_nlliii_dataout, ~{niOOiO});
	and(wire_nll0Ol_dataout, wire_nlliil_dataout, ~{niOOiO});
	or(wire_nll0OO_dataout, wire_nlliiO_dataout, niOOiO);
	or(wire_nll10i_dataout, wire_nll1Oi_o, nl100O);
	or(wire_nll10l_dataout, wire_nll1Ol_o, nl100O);
	or(wire_nll10O_dataout, wire_nll1OO_o, nl100O);
	or(wire_nll11i_dataout, wire_nll1li_o, nl100O);
	or(wire_nll11l_dataout, wire_nll1ll_o, nl100O);
	or(wire_nll11O_dataout, wire_nll1lO_o, nl100O);
	and(wire_nlli0i_dataout, wire_nlliOi_dataout, ~{niOOiO});
	or(wire_nlli0l_dataout, wire_nlliOl_dataout, niOOiO);
	or(wire_nlli0O_dataout, txctrl[3:3], nl11ll);
	or(wire_nlli1i_dataout, wire_nllili_dataout, niOOiO);
	or(wire_nlli1l_dataout, wire_nllill_dataout, niOOiO);
	or(wire_nlli1O_dataout, wire_nllilO_dataout, niOOiO);
	or(wire_nllii_dataout, wire_nllil_dataout, nl11iO);
	or(wire_nlliii_dataout, txdatain[24:24], nl11ll);
	and(wire_nlliil_dataout, txdatain[25:25], ~{nl11ll});
	or(wire_nlliiO_dataout, txdatain[26:26], nl11ll);
	and(wire_nllil_dataout, nllOO, ~{(nllOO & (nl11il & ((~ (((nlO1i | nliOiO) | (~ nliOil)) | nliOii)) | (~ ((((~ nlO1i) | nliOiO) | (~ nliOil)) | (~ nliOii))))))});
	or(wire_nllili_dataout, txdatain[27:27], nl11ll);
	or(wire_nllill_dataout, txdatain[28:28], nl11ll);
	or(wire_nllilO_dataout, txdatain[29:29], nl11ll);
	or(wire_nlliOi_dataout, txdatain[30:30], nl11ll);
	or(wire_nlliOl_dataout, txdatain[31:31], nl11ll);
	assign		wire_nlll0i_dataout = (nl111i === 1'b1) ? wire_nll0Oi_dataout : wire_nllllO_dataout;
	assign		wire_nlll0l_dataout = (nl111i === 1'b1) ? wire_nll0Ol_dataout : wire_nlllOi_dataout;
	assign		wire_nlll0O_dataout = (nl111i === 1'b1) ? wire_nll0OO_dataout : wire_nlllOl_dataout;
	assign		wire_nlll1O_dataout = (nl111i === 1'b1) ? wire_nll0lO_dataout : (~ nllOO);
	assign		wire_nlllii_dataout = (nl111i === 1'b1) ? wire_nlli1i_dataout : wire_nlllOO_dataout;
	assign		wire_nlllil_dataout = (nl111i === 1'b1) ? wire_nlli1l_dataout : wire_nllO1i_dataout;
	assign		wire_nllliO_dataout = (nl111i === 1'b1) ? wire_nlli1O_dataout : wire_nllO1l_dataout;
	assign		wire_nlllli_dataout = (nl111i === 1'b1) ? wire_nlli0i_dataout : wire_nllO1O_dataout;
	assign		wire_nlllll_dataout = (nl111i === 1'b1) ? wire_nlli0l_dataout : wire_nllO0i_dataout;
	and(wire_nllllO_dataout, nliOO, nllOO);
	and(wire_nlllOi_dataout, nliO0O, nllOO);
	or(wire_nlllOl_dataout, nll1i, ~{nllOO});
	or(wire_nlllOO_dataout, nll1l, ~{nllOO});
	assign		wire_nllO0i_dataout = (nllOO === 1'b1) ? nll0O : (~ nlilli);
	assign		wire_nllO0l_dataout = (nl111i === 1'b1) ? wire_nlli1O_dataout : wire_nllOil_dataout;
	assign		wire_nllO0O_dataout = (nl111i === 1'b1) ? wire_nlli0i_dataout : (~ nl110O);
	or(wire_nllO1i_dataout, nll1O, ~{nllOO});
	assign		wire_nllO1l_dataout = (nllOO === 1'b1) ? nll0i : (~ nlilli);
	and(wire_nllO1O_dataout, nll0l, nllOO);
	assign		wire_nllOii_dataout = (nl111i === 1'b1) ? wire_nlli0l_dataout : wire_nllOiO_dataout;
	or(wire_nllOil_dataout, (~ nlilli), (~ nl110O));
	and(wire_nllOiO_dataout, (~ nlilli), ~{(~ nl110O)});
	and(wire_nllOli_dataout, wire_nlli1O_dataout, nl111i);
	and(wire_nllOll_dataout, wire_nlli0l_dataout, nl111i);
	assign		wire_nllOlO_dataout = (nl111i === 1'b1) ? wire_nlli1O_dataout : wire_nllOOl_dataout;
	assign		wire_nllOOi_dataout = (nl111i === 1'b1) ? wire_nlli0l_dataout : wire_nllOOO_dataout;
	and(wire_nllOOl_dataout, nll0i, nllOO);
	and(wire_nllOOO_dataout, nll0O, nllOO);
	or(wire_nlO00i_dataout, wire_nlO0Oi_o, nl10ii);
	or(wire_nlO00l_dataout, wire_nlO0Ol_o, nl10ii);
	or(wire_nlO00O_dataout, wire_nlO0OO_o, nl10ii);
	or(wire_nlO01l_dataout, wire_nlO0ll_o, nl10ii);
	and(wire_nlO01O_dataout, wire_nlO0lO_o, ~{nl10ii});
	or(wire_nlO0ii_dataout, wire_nlOi1i_o, nl10ii);
	or(wire_nlO0il_dataout, wire_nlOi1l_o, nl10ii);
	or(wire_nlO0iO_dataout, wire_nlOi1O_o, nl10ii);
	or(wire_nlO0li_dataout, wire_nlOi0i_o, nl10ii);
	or(wire_nlO10l_dataout, wire_nll01O_dataout, ~{rdenablesync});
	and(wire_nlO10O_dataout, wire_nll00i_dataout, rdenablesync);
	or(wire_nlO11i_dataout, wire_nlli1O_dataout, ~{nl111i});
	assign		wire_nlO11l_dataout = (nl111i === 1'b1) ? wire_nlli0i_dataout : nl111l;
	assign		wire_nlO11O_dataout = (nl111i === 1'b1) ? wire_nlli0l_dataout : (~ nl111l);
	and(wire_nlO1ii_dataout, wire_nll00l_dataout, rdenablesync);
	or(wire_nlO1il_dataout, wire_nll00O_dataout, ~{rdenablesync});
	or(wire_nlO1iO_dataout, wire_nll0ii_dataout, ~{rdenablesync});
	or(wire_nlO1li_dataout, wire_nll0il_dataout, ~{rdenablesync});
	or(wire_nlO1ll_dataout, wire_nllOli_dataout, ~{rdenablesync});
	and(wire_nlO1lO_dataout, wire_nll0li_dataout, rdenablesync);
	or(wire_nlO1Oi_dataout, wire_nllOll_dataout, ~{rdenablesync});
	or(wire_nlOi0O_dataout, wire_nlOiOO_dataout, ~{nl111i});
	and(wire_nlOiii_dataout, wire_nlOl1i_dataout, nl111i);
	and(wire_nlOiil_dataout, wire_nlOl1l_dataout, nl111i);
	or(wire_nlOiiO_dataout, wire_nlOl1O_dataout, ~{nl111i});
	or(wire_nlOili_dataout, wire_nlOl0i_dataout, ~{nl111i});
	or(wire_nlOill_dataout, wire_nlOl0l_dataout, ~{nl111i});
	assign		wire_nlOilO_dataout = (nl111i === 1'b1) ? wire_nlOl0O_dataout : (~ nlilli);
	and(wire_nlOiOi_dataout, wire_nlOlii_dataout, nl111i);
	assign		wire_nlOiOl_dataout = (nl111i === 1'b1) ? wire_nlOlil_dataout : (~ nlilli);
	or(wire_nlOiOO_dataout, wire_nlOliO_dataout, niOOll);
	or(wire_nlOl0i_dataout, wire_nlOlOi_dataout, niOOll);
	or(wire_nlOl0l_dataout, wire_nlOlOl_dataout, niOOll);
	or(wire_nlOl0O_dataout, wire_nlOlOO_dataout, niOOll);
	and(wire_nlOl1i_dataout, wire_nlOlli_dataout, ~{niOOll});
	and(wire_nlOl1l_dataout, wire_nlOlll_dataout, ~{niOOll});
	or(wire_nlOl1O_dataout, wire_nlOllO_dataout, niOOll);
	and(wire_nlOlii_dataout, wire_nlOO1i_dataout, ~{niOOll});
	or(wire_nlOlil_dataout, wire_nlOO1l_dataout, niOOll);
	or(wire_nlOliO_dataout, txctrl[2:2], nl11Oi);
	or(wire_nlOlli_dataout, txdatain[16:16], nl11Oi);
	and(wire_nlOlll_dataout, txdatain[17:17], ~{nl11Oi});
	or(wire_nlOllO_dataout, txdatain[18:18], nl11Oi);
	or(wire_nlOlOi_dataout, txdatain[19:19], nl11Oi);
	or(wire_nlOlOl_dataout, txdatain[20:20], nl11Oi);
	or(wire_nlOlOO_dataout, txdatain[21:21], nl11Oi);
	assign		wire_nlOO0i_dataout = (nl111i === 1'b1) ? wire_nlOl1i_dataout : wire_nlOOlO_dataout;
	assign		wire_nlOO0l_dataout = (nl111i === 1'b1) ? wire_nlOl1l_dataout : wire_nlOOOi_dataout;
	assign		wire_nlOO0O_dataout = (nl111i === 1'b1) ? wire_nlOl1O_dataout : wire_nlOOOl_dataout;
	or(wire_nlOO1i_dataout, txdatain[22:22], nl11Oi);
	or(wire_nlOO1l_dataout, txdatain[23:23], nl11Oi);
	assign		wire_nlOO1O_dataout = (nl111i === 1'b1) ? wire_nlOiOO_dataout : (~ nllOO);
	assign		wire_nlOOii_dataout = (nl111i === 1'b1) ? wire_nlOl0i_dataout : wire_nlOOOO_dataout;
	assign		wire_nlOOil_dataout = (nl111i === 1'b1) ? wire_nlOl0l_dataout : wire_n111i_dataout;
	assign		wire_nlOOiO_dataout = (nl111i === 1'b1) ? wire_nlOl0O_dataout : wire_n111l_dataout;
	assign		wire_nlOOli_dataout = (nl111i === 1'b1) ? wire_nlOlii_dataout : wire_n111O_dataout;
	assign		wire_nlOOll_dataout = (nl111i === 1'b1) ? wire_nlOlil_dataout : wire_n110i_dataout;
	and(wire_nlOOlO_dataout, nliii, nllOO);
	and(wire_nlOOOi_dataout, nliil, nllOO);
	or(wire_nlOOOl_dataout, nliiO, ~{nllOO});
	or(wire_nlOOOO_dataout, nlili, ~{nllOO});
	oper_add   nl1OO
	( 
	.a({nliliO
		, nl10i, nl11O, nl11l, nl11i, 1'b1}),
	.b({1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1}),
	.cin(1'b0),
	.cout(),
	.o(wire_nl1OO_o));
	defparam
		nl1OO.sgate_representation = 0,
		nl1OO.width_a = 6,
		nl1OO.width_b = 6,
		nl1OO.width_o = 6;
	oper_decoder   nll01l
	( 
	.i({nliOiO, nlO1i, nliOil, nliOii}),
	.o(wire_nll01l_o));
	defparam
		nll01l.width_i = 4,
		nll01l.width_o = 16;
	oper_less_than   niOOi
	( 
	.a({1'b1, 1'b0, 1'b0, 1'b0}),
	.b({nliOiO, nlO1i, nliOil, nliOii}),
	.cin(1'b0),
	.o(wire_niOOi_o));
	defparam
		niOOi.sgate_representation = 0,
		niOOi.width_a = 4,
		niOOi.width_b = 4;
	oper_selector   n0l0l
	( 
	.data({1'b1, wire_n0lOO_dataout, wire_n0lOO_dataout, wire_n0lOO_dataout, wire_n0lOO_dataout, wire_n0lOO_dataout, wire_nii1i_dataout, wire_n0lOO_dataout, wire_n0lOO_dataout}),
	.o(wire_n0l0l_o),
	.sel({niOOOl, wire_nll01l_o[8:1]}));
	defparam
		n0l0l.width_data = 9,
		n0l0l.width_sel = 9;
	oper_selector   n0l0O
	( 
	.data({1'b0, wire_n0O1i_dataout, wire_ni11O_dataout, wire_n0O1i_dataout, wire_n0O1i_dataout, wire_n0O1i_dataout, wire_nii1l_dataout, wire_ni11O_dataout, wire_n0O1i_dataout}),
	.o(wire_n0l0O_o),
	.sel({niOOOl, wire_nll01l_o[8:1]}));
	defparam
		n0l0O.width_data = 9,
		n0l0O.width_sel = 9;
	oper_selector   n0lii
	( 
	.data({1'b0, wire_n0O1l_dataout, wire_ni10i_dataout, wire_n0O1l_dataout, wire_n0O1l_dataout, wire_n0O1l_dataout, wire_nii1O_dataout, wire_ni10i_dataout, wire_n0O1l_dataout}),
	.o(wire_n0lii_o),
	.sel({niOOOl, wire_nll01l_o[8:1]}));
	defparam
		n0lii.width_data = 9,
		n0lii.width_sel = 9;
	oper_selector   n0lil
	( 
	.data({1'b1, wire_n0O1O_dataout, wire_ni10l_dataout, wire_n0O1O_dataout, wire_n0O1O_dataout, wire_n0O1O_dataout, wire_nii0i_dataout, wire_ni10l_dataout, wire_n0O1O_dataout}),
	.o(wire_n0lil_o),
	.sel({niOOOl, wire_nll01l_o[8:1]}));
	defparam
		n0lil.width_data = 9,
		n0lil.width_sel = 9;
	oper_selector   n0liO
	( 
	.data({1'b1, wire_n0O0i_dataout, wire_ni10O_dataout, wire_n0O0i_dataout, wire_n0O0i_dataout, wire_n0O0i_dataout, wire_nii0l_dataout, wire_ni10O_dataout, wire_n0O0i_dataout}),
	.o(wire_n0liO_o),
	.sel({niOOOl, wire_nll01l_o[8:1]}));
	defparam
		n0liO.width_data = 9,
		n0liO.width_sel = 9;
	oper_selector   n0lli
	( 
	.data({1'b1, wire_n0O0l_dataout, wire_ni1ii_dataout, wire_n0O0l_dataout, wire_n0O0l_dataout, wire_n0O0l_dataout, wire_nii0O_dataout, wire_ni1ii_dataout, wire_n0O0l_dataout}),
	.o(wire_n0lli_o),
	.sel({niOOOl, wire_nll01l_o[8:1]}));
	defparam
		n0lli.width_data = 9,
		n0lli.width_sel = 9;
	oper_selector   n0lll
	( 
	.data({1'b1, wire_n0O0O_dataout, wire_ni1il_dataout, wire_ni00i_dataout, wire_ni00i_dataout, wire_ni0ii_dataout, wire_niiii_dataout, wire_ni0iO_dataout, wire_ni0Oi_dataout}),
	.o(wire_n0lll_o),
	.sel({niOOOl, wire_nll01l_o[8:1]}));
	defparam
		n0lll.width_data = 9,
		n0lll.width_sel = 9;
	oper_selector   n0llO
	( 
	.data({1'b0, wire_n0Oii_dataout, wire_ni1iO_dataout, wire_ni00l_dataout, wire_ni00l_dataout, wire_n0Oii_dataout, wire_niiil_dataout, wire_ni1iO_dataout, wire_ni0Ol_dataout}),
	.o(wire_n0llO_o),
	.sel({niOOOl, wire_nll01l_o[8:1]}));
	defparam
		n0llO.width_data = 9,
		n0llO.width_sel = 9;
	oper_selector   n0lOi
	( 
	.data({1'b1, wire_n0Oil_dataout, wire_ni1li_dataout, wire_ni00O_dataout, wire_ni00O_dataout, wire_ni0il_dataout, wire_niiiO_dataout, wire_ni0li_dataout, wire_ni0OO_dataout}),
	.o(wire_n0lOi_o),
	.sel({niOOOl, wire_nll01l_o[8:1]}));
	defparam
		n0lOi.width_data = 9,
		n0lOi.width_sel = 9;
	oper_selector   n1iil
	( 
	.data({1'b1, wire_n1l1O_dataout, wire_n1OOO_dataout, wire_n1l1O_dataout, wire_n1l1O_dataout, wire_n1l1O_dataout, wire_n00Ol_dataout, wire_n1OOO_dataout, wire_n1l1O_dataout}),
	.o(wire_n1iil_o),
	.sel({niOOOl, wire_nll01l_o[8:1]}));
	defparam
		n1iil.width_data = 9,
		n1iil.width_sel = 9;
	oper_selector   n1iiO
	( 
	.data({1'b0, wire_n1l0i_dataout, wire_n011i_dataout, wire_n1l0i_dataout, wire_n1l0i_dataout, wire_n1l0i_dataout, wire_n00OO_dataout, wire_n011i_dataout, wire_n1l0i_dataout}),
	.o(wire_n1iiO_o),
	.sel({niOOlO, wire_nll01l_o[8:1]}));
	defparam
		n1iiO.width_data = 9,
		n1iiO.width_sel = 9;
	oper_selector   n1ili
	( 
	.data({1'b0, wire_n1l0l_dataout, wire_n011l_dataout, wire_n1l0l_dataout, wire_n1l0l_dataout, wire_n1l0l_dataout, wire_n0i1i_dataout, wire_n011l_dataout, wire_n1l0l_dataout}),
	.o(wire_n1ili_o),
	.sel({niOOlO, wire_nll01l_o[8:1]}));
	defparam
		n1ili.width_data = 9,
		n1ili.width_sel = 9;
	oper_selector   n1ill
	( 
	.data({1'b1, wire_n1l0O_dataout, wire_n011O_dataout
		, wire_n1l0O_dataout, wire_n1l0O_dataout, wire_n1l0O_dataout, wire_n0i1l_dataout, wire_n011O_dataout, wire_n1l0O_dataout}),
	.o(wire_n1ill_o),
	.sel({niOOlO, wire_nll01l_o[8:1]}));
	defparam
		n1ill.width_data = 9,
		n1ill.width_sel = 9;
	oper_selector   n1ilO
	( 
	.data({1'b1, wire_n1lii_dataout, wire_n010i_dataout, wire_n1lii_dataout, wire_n1lii_dataout, wire_n1lii_dataout, wire_n0i1O_dataout, wire_n010i_dataout, wire_n1lii_dataout}),
	.o(wire_n1ilO_o),
	.sel({niOOlO, wire_nll01l_o[8:1]}));
	defparam
		n1ilO.width_data = 9,
		n1ilO.width_sel = 9;
	oper_selector   n1iOi
	( 
	.data({1'b1, wire_n1lil_dataout, wire_n010l_dataout, wire_n1lil_dataout, wire_n1lil_dataout, wire_n1lil_dataout, wire_n0i0i_dataout, wire_n010l_dataout, wire_n1lil_dataout}),
	.o(wire_n1iOi_o),
	.sel({niOOlO, wire_nll01l_o[8:1]}));
	defparam
		n1iOi.width_data = 9,
		n1iOi.width_sel = 9;
	oper_selector   n1iOl
	( 
	.data({1'b1, wire_n1liO_dataout, wire_n010O_dataout, wire_n001l_dataout, wire_n001l_dataout, wire_n000l_dataout, wire_n0i0l_dataout, wire_n00ii_dataout, wire_n00ll_dataout}),
	.o(wire_n1iOl_o),
	.sel({niOOlO, wire_nll01l_o[8:1]}));
	defparam
		n1iOl.width_data = 9,
		n1iOl.width_sel = 9;
	oper_selector   n1iOO
	( 
	.data({1'b0, wire_n1lli_dataout, wire_n01ii_dataout, wire_n001O_dataout, wire_n001O_dataout, wire_n1lli_dataout, wire_n0i0O_dataout, wire_n01ii_dataout, wire_n00lO_dataout}),
	.o(wire_n1iOO_o),
	.sel({niOOlO, wire_nll01l_o[8:1]}));
	defparam
		n1iOO.width_data = 9,
		n1iOO.width_sel = 9;
	oper_selector   n1l1i
	( 
	.data({1'b1, wire_n1lll_dataout, wire_n01il_dataout, wire_n000i_dataout, wire_n000i_dataout, wire_n000O_dataout, wire_n0iii_dataout, wire_n00il_dataout, wire_n00Oi_dataout}),
	.o(wire_n1l1i_o),
	.sel({niOOlO, wire_nll01l_o[8:1]}));
	defparam
		n1l1i.width_data = 9,
		n1l1i.width_sel = 9;
	oper_selector   niili
	( 
	.data({1'b1, wire_nil1l_dataout, wire_nil0i_dataout, wire_nilli_dataout, wire_nilli_dataout, wire_nilOi_dataout, wire_nilOl_dataout}),
	.o(wire_niili_o),
	.sel({niOOOi, wire_nll01l_o[8:5], wire_nll01l_o[2:1]}));
	defparam
		niili.width_data = 7,
		niili.width_sel = 7;
	oper_selector   niilO
	( 
	.data({1'b1, wire_nil1O_dataout, wire_nil0l_dataout, wire_nilll_dataout, wire_nilll_dataout, 1'b0, (~ rdenablesync), (~ nl111i)}),
	.o(wire_niilO_o),
	.sel({niOOOl, wire_nll01l_o[8:5], (wire_nll01l_o[4:4] | wire_nll01l_o[2:2]), wire_nll01l_o[3:3], wire_nll01l_o[1:1]}));
	defparam
		niilO.width_data = 8,
		niilO.width_sel = 8;
	oper_selector   niiOl
	( 
	.data({1'b0, (~ nl111i), wire_nil0O_dataout, (~ nl111i), (~ nl111i), (~ nl111i), wire_nilOO_dataout, (~ nl111i)}),
	.o(wire_niiOl_o),
	.sel({niOOOO, wire_nll01l_o[8:2]}));
	defparam
		niiOl.width_data = 8,
		niiOl.width_sel = 8;
	oper_selector   nll1ii
	( 
	.data({1'b1, wire_nll01O_dataout, wire_nlll1O_dataout, wire_nll01O_dataout, wire_nll01O_dataout, wire_nll01O_dataout, wire_nlO10l_dataout, wire_nlll1O_dataout, wire_nll01O_dataout}),
	.o(wire_nll1ii_o),
	.sel({niOOOl, wire_nll01l_o[8:1]}));
	defparam
		nll1ii.width_data = 9,
		nll1ii.width_sel = 9;
	oper_selector   nll1il
	( 
	.data({1'b0, wire_nll00i_dataout, wire_nlll0i_dataout, wire_nll00i_dataout, wire_nll00i_dataout, wire_nll00i_dataout, wire_nlO10O_dataout, wire_nlll0i_dataout, wire_nll00i_dataout}),
	.o(wire_nll1il_o),
	.sel({niOOil, wire_nll01l_o[8:1]}));
	defparam
		nll1il.width_data = 9,
		nll1il.width_sel = 9;
	oper_selector   nll1iO
	( 
	.data({1'b0, wire_nll00l_dataout, wire_nlll0l_dataout, wire_nll00l_dataout, wire_nll00l_dataout, wire_nll00l_dataout, wire_nlO1ii_dataout, wire_nlll0l_dataout, wire_nll00l_dataout}),
	.o(wire_nll1iO_o),
	.sel({niOOil, wire_nll01l_o[8:1]}));
	defparam
		nll1iO.width_data = 9,
		nll1iO.width_sel = 9;
	oper_selector   nll1li
	( 
	.data({1'b1, wire_nll00O_dataout, wire_nlll0O_dataout, wire_nll00O_dataout, wire_nll00O_dataout, wire_nll00O_dataout, wire_nlO1il_dataout, wire_nlll0O_dataout, wire_nll00O_dataout}),
	.o(wire_nll1li_o),
	.sel({niOOil, wire_nll01l_o[8:1]}));
	defparam
		nll1li.width_data = 9,
		nll1li.width_sel = 9;
	oper_selector   nll1ll
	( 
	.data({1'b1, wire_nll0ii_dataout, wire_nlllii_dataout
		, wire_nll0ii_dataout, wire_nll0ii_dataout, wire_nll0ii_dataout, wire_nlO1iO_dataout, wire_nlllii_dataout, wire_nll0ii_dataout}),
	.o(wire_nll1ll_o),
	.sel({niOOil, wire_nll01l_o[8:1]}));
	defparam
		nll1ll.width_data = 9,
		nll1ll.width_sel = 9;
	oper_selector   nll1lO
	( 
	.data({1'b1, wire_nll0il_dataout, wire_nlllil_dataout, wire_nll0il_dataout, wire_nll0il_dataout, wire_nll0il_dataout, wire_nlO1li_dataout, wire_nlllil_dataout, wire_nll0il_dataout}),
	.o(wire_nll1lO_o),
	.sel({niOOil, wire_nll01l_o[8:1]}));
	defparam
		nll1lO.width_data = 9,
		nll1lO.width_sel = 9;
	oper_selector   nll1Oi
	( 
	.data({1'b1, wire_nll0iO_dataout, wire_nllliO_dataout, wire_nllO0l_dataout, wire_nllO0l_dataout, wire_nllOli_dataout, wire_nlO1ll_dataout, wire_nllOlO_dataout, wire_nlO11i_dataout}),
	.o(wire_nll1Oi_o),
	.sel({niOOil, wire_nll01l_o[8:1]}));
	defparam
		nll1Oi.width_data = 9,
		nll1Oi.width_sel = 9;
	oper_selector   nll1Ol
	( 
	.data({1'b0, wire_nll0li_dataout, wire_nlllli_dataout, wire_nllO0O_dataout, wire_nllO0O_dataout, wire_nll0li_dataout, wire_nlO1lO_dataout, wire_nlllli_dataout, wire_nlO11l_dataout}),
	.o(wire_nll1Ol_o),
	.sel({niOOil, wire_nll01l_o[8:1]}));
	defparam
		nll1Ol.width_data = 9,
		nll1Ol.width_sel = 9;
	oper_selector   nll1OO
	( 
	.data({1'b1, wire_nll0ll_dataout, wire_nlllll_dataout, wire_nllOii_dataout, wire_nllOii_dataout, wire_nllOll_dataout, wire_nlO1Oi_dataout, wire_nllOOi_dataout, wire_nlO11O_dataout}),
	.o(wire_nll1OO_o),
	.sel({niOOil, wire_nll01l_o[8:1]}));
	defparam
		nll1OO.width_data = 9,
		nll1OO.width_sel = 9;
	oper_selector   nlO0ll
	( 
	.data({1'b1, wire_nlOi0O_dataout, wire_nlOO1O_dataout, wire_nlOi0O_dataout, wire_nlOi0O_dataout, wire_nlOi0O_dataout, wire_n101l_dataout, wire_nlOO1O_dataout, wire_nlOi0O_dataout}),
	.o(wire_nlO0ll_o),
	.sel({niOOOl, wire_nll01l_o[8:1]}));
	defparam
		nlO0ll.width_data = 9,
		nlO0ll.width_sel = 9;
	oper_selector   nlO0lO
	( 
	.data({1'b0, wire_nlOiii_dataout, wire_nlOO0i_dataout, wire_nlOiii_dataout, wire_nlOiii_dataout, wire_nlOiii_dataout, wire_n101O_dataout, wire_nlOO0i_dataout, wire_nlOiii_dataout}),
	.o(wire_nlO0lO_o),
	.sel({niOOli, wire_nll01l_o[8:1]}));
	defparam
		nlO0lO.width_data = 9,
		nlO0lO.width_sel = 9;
	oper_selector   nlO0Oi
	( 
	.data({1'b0, wire_nlOiil_dataout, wire_nlOO0l_dataout, wire_nlOiil_dataout, wire_nlOiil_dataout, wire_nlOiil_dataout, wire_n100i_dataout, wire_nlOO0l_dataout, wire_nlOiil_dataout}),
	.o(wire_nlO0Oi_o),
	.sel({niOOli, wire_nll01l_o[8:1]}));
	defparam
		nlO0Oi.width_data = 9,
		nlO0Oi.width_sel = 9;
	oper_selector   nlO0Ol
	( 
	.data({1'b1, wire_nlOiiO_dataout, wire_nlOO0O_dataout, wire_nlOiiO_dataout, wire_nlOiiO_dataout, wire_nlOiiO_dataout, wire_n100l_dataout, wire_nlOO0O_dataout, wire_nlOiiO_dataout}),
	.o(wire_nlO0Ol_o),
	.sel({niOOli, wire_nll01l_o[8:1]}));
	defparam
		nlO0Ol.width_data = 9,
		nlO0Ol.width_sel = 9;
	oper_selector   nlO0OO
	( 
	.data({1'b1, wire_nlOili_dataout, wire_nlOOii_dataout, wire_nlOili_dataout, wire_nlOili_dataout, wire_nlOili_dataout, wire_n100O_dataout, wire_nlOOii_dataout, wire_nlOili_dataout}),
	.o(wire_nlO0OO_o),
	.sel({niOOli, wire_nll01l_o[8:1]}));
	defparam
		nlO0OO.width_data = 9,
		nlO0OO.width_sel = 9;
	oper_selector   nlOi0i
	( 
	.data({1'b1, wire_nlOiOl_dataout, wire_nlOOll_dataout, wire_n11ii_dataout, wire_n11ii_dataout, wire_n11iO_dataout, wire_n10li_dataout, wire_n11ll_dataout, wire_n101i_dataout}),
	.o(wire_nlOi0i_o),
	.sel({niOOli, wire_nll01l_o[8:1]}));
	defparam
		nlOi0i.width_data = 9,
		nlOi0i.width_sel = 9;
	oper_selector   nlOi1i
	( 
	.data({1'b1, wire_nlOill_dataout, wire_nlOOil_dataout, wire_nlOill_dataout, wire_nlOill_dataout, wire_nlOill_dataout, wire_n10ii_dataout, wire_nlOOil_dataout, wire_nlOill_dataout}),
	.o(wire_nlOi1i_o),
	.sel({niOOli, wire_nll01l_o[8:1]}));
	defparam
		nlOi1i.width_data = 9,
		nlOi1i.width_sel = 9;
	oper_selector   nlOi1l
	( 
	.data({1'b1, wire_nlOilO_dataout, wire_nlOOiO_dataout, wire_n110l_dataout
		, wire_n110l_dataout, wire_n11il_dataout, wire_n10il_dataout, wire_n11li_dataout, wire_n11Ol_dataout}),
	.o(wire_nlOi1l_o),
	.sel({niOOli, wire_nll01l_o[8:1]}));
	defparam
		nlOi1l.width_data = 9,
		nlOi1l.width_sel = 9;
	oper_selector   nlOi1O
	( 
	.data({1'b0, wire_nlOiOi_dataout, wire_nlOOli_dataout, wire_n110O_dataout, wire_n110O_dataout, wire_nlOiOi_dataout, wire_n10iO_dataout, wire_nlOOli_dataout, wire_n11OO_dataout}),
	.o(wire_nlOi1O_o),
	.sel({niOOli, wire_nll01l_o[8:1]}));
	defparam
		nlOi1O.width_data = 9,
		nlOi1O.width_sel = 9;
	assign
		niOOil = (((((((wire_nll01l_o[15:15] | wire_nll01l_o[14:14]) | wire_nll01l_o[13:13]) | wire_nll01l_o[12:12]) | wire_nll01l_o[11:11]) | wire_nll01l_o[10:10]) | wire_nll01l_o[9:9]) | wire_nll01l_o[0:0]),
		niOOiO = (nl11Oi | niOOll),
		niOOli = (((((((wire_nll01l_o[15:15] | wire_nll01l_o[14:14]) | wire_nll01l_o[13:13]) | wire_nll01l_o[12:12]) | wire_nll01l_o[11:11]) | wire_nll01l_o[10:10]) | wire_nll01l_o[9:9]) | wire_nll01l_o[0:0]),
		niOOll = (nl101l | nl11OO),
		niOOlO = (((((((wire_nll01l_o[15:15] | wire_nll01l_o[14:14]) | wire_nll01l_o[13:13]) | wire_nll01l_o[12:12]) | wire_nll01l_o[11:11]) | wire_nll01l_o[10:10]) | wire_nll01l_o[9:9]) | wire_nll01l_o[0:0]),
		niOOOi = (((((((((wire_nll01l_o[4:4] | wire_nll01l_o[3:3]) | wire_nll01l_o[15:15]) | wire_nll01l_o[14:14]) | wire_nll01l_o[13:13]) | wire_nll01l_o[12:12]) | wire_nll01l_o[11:11]) | wire_nll01l_o[10:10]) | wire_nll01l_o[9:9]) | wire_nll01l_o[0:0]),
		niOOOl = (((((((wire_nll01l_o[15:15] | wire_nll01l_o[14:14]) | wire_nll01l_o[13:13]) | wire_nll01l_o[12:12]) | wire_nll01l_o[11:11]) | wire_nll01l_o[10:10]) | wire_nll01l_o[9:9]) | wire_nll01l_o[0:0]),
		niOOOO = ((((((((wire_nll01l_o[1:1] | wire_nll01l_o[15:15]) | wire_nll01l_o[14:14]) | wire_nll01l_o[13:13]) | wire_nll01l_o[12:12]) | wire_nll01l_o[11:11]) | wire_nll01l_o[10:10]) | wire_nll01l_o[9:9]) | wire_nll01l_o[0:0]),
		nl000O = (((((((txdatain[23:23] | txdatain[22:22]) | txdatain[21:21]) | txdatain[20:20]) | txdatain[19:19]) | (~ txdatain[17:17])) | (~ txdatain[16:16])) | (~ txdatain[18:18])),
		nl001O = ((((((((txdatain[31:31] | txdatain[30:30]) | txdatain[29:29]) | txdatain[28:28]) | txdatain[27:27]) | (~ txdatain[25:25])) | (~ txdatain[24:24])) | (~ txdatain[26:26])) | (~ w_nl000i80w)),
		nl00ii = (((((((txdatain[15:15] | txdatain[14:14]) | txdatain[13:13]) | txdatain[12:12]) | txdatain[11:11]) | (~ txdatain[9:9])) | (~ txdatain[8:8])) | (~ txdatain[10:10])),
		nl00il = ((((((((txdatain[7:7] | txdatain[6:6]) | txdatain[5:5]) | txdatain[4:4]) | txdatain[3:3]) | (~ txdatain[1:1])) | (~ txdatain[0:0])) | (~ txdatain[2:2])) | (~ w_nl00li21w)),
		nl00iO = txclk,
		nl010O = ((((((((~ txdatain[31:31]) | (~ txdatain[30:30])) | (~ txdatain[29:29])) | (~ txdatain[28:28])) | (~ txdatain[27:27])) | (~ txdatain[25:25])) | (~ txdatain[24:24])) | txdatain[26:26]),
		nl011O = (((((((((~ txdatain[7:7]) | (~ txdatain[6:6])) | (~ txdatain[5:5])) | (~ txdatain[4:4])) | (~ txdatain[3:3])) | txdatain[1:1]) | (~ txdatain[0:0])) | (~ txdatain[2:2])) | (~ w_nl010i174w)),
		nl01ii = ((((((((~ txdatain[23:23]) | (~ txdatain[22:22])) | (~ txdatain[21:21])) | (~ txdatain[20:20])) | (~ txdatain[19:19])) | (~ txdatain[17:17])) | (~ txdatain[16:16])) | txdatain[18:18]),
		nl01il = ((((((((~ txdatain[15:15]) | (~ txdatain[14:14])) | (~ txdatain[13:13])) | (~ txdatain[12:12])) | (~ txdatain[11:11])) | (~ txdatain[9:9])) | (~ txdatain[8:8])) | txdatain[10:10]),
		nl01iO = ((((((((~ txdatain[7:7]) | (~ txdatain[6:6])) | (~ txdatain[5:5])) | (~ txdatain[4:4])) | (~ txdatain[3:3])) | (~ txdatain[1:1])) | (~ txdatain[0:0])) | txdatain[2:2]),
		nl01li = (((((((((~ txdatain[31:31]) | txdatain[30:30]) | txdatain[29:29]) | (~ txdatain[28:28])) | (~ txdatain[27:27])) | txdatain[25:25]) | txdatain[24:24]) | (~ txdatain[26:26])) | (~ w_nl01ll130w)),
		nl01Oi = ((((((((~ txdatain[23:23]) | txdatain[22:22]) | txdatain[21:21]) | (~ txdatain[20:20])) | (~ txdatain[19:19])) | txdatain[17:17]) | txdatain[16:16]) | (~ txdatain[18:18])),
		nl01Ol = ((((((((~ txdatain[15:15]) | txdatain[14:14]) | txdatain[13:13]) | (~ txdatain[12:12])) | (~ txdatain[11:11])) | txdatain[9:9]) | txdatain[8:8]) | (~ txdatain[10:10])),
		nl01OO = (((((((((~ txdatain[7:7]) | txdatain[6:6]) | txdatain[5:5]) | (~ txdatain[4:4])) | (~ txdatain[3:3])) | txdatain[1:1]) | txdatain[0:0]) | (~ txdatain[2:2])) | (~ w_nl001i95w)),
		nl100i = ((((txctrl[3:3] & txctrl[2:2]) & txctrl[1:1]) & txctrl[0:0]) & (~ nl100l)),
		nl100l = (((((((((((((((((((((((((((((((txdatain[31:31] | txdatain[30:30]) | txdatain[29:29]) | txdatain[28:28]) | txdatain[27:27]) | (~ txdatain[25:25])) | (~ txdatain[24:24])) | (~ txdatain[26:26])) | txdatain[23:23]) | txdatain[22:22]) | txdatain[21:21]) | txdatain[20:20]) | txdatain[19:19]) | (~ txdatain[17:17])) | (~ txdatain[16:16])) | (~ txdatain[18:18])) | txdatain[15:15]) | txdatain[14:14]) | txdatain[13:13]) | txdatain[12:12]) | txdatain[11:11]) | (~ txdatain[9:9])) | (~ txdatain[8:8])) | (~ txdatain[10:10])) | txdatain[7:7]) | txdatain[6:6]) | txdatain[5:5]) | txdatain[4:4]) | txdatain[3:3]) | (~ txdatain[1:1])) | (~ txdatain[0:0])) | (~ txdatain[2:2])),
		nl100O = (nl1i1O & (nl1iiO & (nl1l0i & (nl1llO & (nl1O0l & (nl1OiO & (nl010O & (nl01li & (txctrl[3:3] & nl001O))))))))),
		nl101i = (((((((((((((((((((((((txdatain[31:31] | txdatain[30:30]) | txdatain[29:29]) | txdatain[28:28]) | txdatain[27:27]) | (~ txdatain[25:25])) | (~ txdatain[24:24])) | (~ txdatain[26:26])) | txdatain[23:23]) | txdatain[22:22]) | txdatain[21:21]) | txdatain[20:20]) | txdatain[19:19]) | (~ txdatain[17:17])) | (~ txdatain[16:16])) | (~ txdatain[18:18])) | (~ txdatain[15:15])) | (~ txdatain[14:14])) | (~ txdatain[13:13])) | (~ txdatain[12:12])) | (~ txdatain[11:11])) | txdatain[9:9]) | (~ txdatain[8:8])) | (~ txdatain[10:10])),
		nl101l = ((~ ((((~ txctrl[3:3]) | (~ txctrl[2:2])) | (~ txctrl[1:1])) | (~ txctrl[0:0]))) & (~ nl101O)),
		nl101O = (((((((((((((((((((((((((((((((txdatain[31:31] | txdatain[30:30]) | txdatain[29:29]) | txdatain[28:28]) | txdatain[27:27]) | (~ txdatain[25:25])) | (~ txdatain[24:24])) | (~ txdatain[26:26])) | txdatain[23:23]) | txdatain[22:22]) | txdatain[21:21]) | txdatain[20:20]) | txdatain[19:19]) | (~ txdatain[17:17])) | (~ txdatain[16:16])) | (~ txdatain[18:18])) | txdatain[15:15]) | txdatain[14:14]) | txdatain[13:13]) | txdatain[12:12]) | txdatain[11:11]) | (~ txdatain[9:9])) | (~ txdatain[8:8])) | (~ txdatain[10:10])) | (~ txdatain[7:7])) | (~ txdatain[6:6])) | (~ txdatain[5:5])) | (~ txdatain[4:4])) | (~ txdatain[3:3])) | txdatain[1:1]) | (~ txdatain[0:0])) | (~ txdatain[2:2])),
		nl10ii = (nl1i0i & (nl1ilO & (nl1l0l & (nl1lOi & (nl1O0O & (nl1OlO & (nl01ii & (nl01Oi & (txctrl[2:2] & nl000O))))))))),
		nl10il = (nl1iii & (nl1iOi & (nl1lil & (nl1lOl & (nl1Oii & (nl1OOO & (nl01il & (nl01Ol & (txctrl[1:1] & nl00ii))))))))),
		nl10iO = (nl1iil & ((nl1l1i & ((nl1liO & ((nl1O1l & (nl1Oil & (nl011O & (nl01iO & (nl01OO & ((txctrl[0:0] & nl00il) & w_nl1i1i345w)))))) & w_nl10Ol354w)) & w_nl10lO359w)) & w_nl10li364w)),
		nl110i = (((nlO1i | nliOiO) | (~ nliOil)) | (~ nliOii)),
		nl110l = (((~ nl110O) & nl11il) & (((~ ((((~ nlO1i) | nliOiO) | (~ nliOil)) | nliOii)) | (~ ((((~ nlO1i) | nliOiO) | nliOil) | (~ nliOii)))) | (nlilil & (~ nl11ii)))),
		nl110O = ((((nl10i | nl11O) | nl11l) | nl11i) | nliliO),
		nl111i = ((~ nl100i) & (~ nl11iO)),
		nl111l = (nlilil & (~ nl110O)),
		nl111O = (nl11il & (~ nl11ii)),
		nl11ii = (((nlO1i | nliOiO) | nliOil) | (~ nliOii)),
		nl11il = (nl100i | nl11iO),
		nl11iO = ((~ (((txctrl[3:3] | txctrl[2:2]) | txctrl[1:1]) | (~ txctrl[0:0]))) & (~ nl11li)),
		nl11li = ((((((((~ txdatain[7:7]) | txdatain[6:6]) | txdatain[5:5]) | (~ txdatain[4:4])) | (~ txdatain[3:3])) | txdatain[1:1]) | txdatain[0:0]) | (~ txdatain[2:2])),
		nl11ll = (txctrl[3:3] & (~ nl11lO)),
		nl11lO = ((((((((~ txdatain[31:31]) | (~ txdatain[30:30])) | (~ txdatain[29:29])) | (~ txdatain[28:28])) | (~ txdatain[27:27])) | txdatain[25:25]) | (~ txdatain[24:24])) | (~ txdatain[26:26])),
		nl11Oi = ((~ ((~ txctrl[3:3]) | (~ txctrl[2:2]))) & (~ nl11Ol)),
		nl11Ol = (((((((((((((((txdatain[31:31] | txdatain[30:30]) | txdatain[29:29]) | txdatain[28:28]) | txdatain[27:27]) | (~ txdatain[25:25])) | (~ txdatain[24:24])) | (~ txdatain[26:26])) | (~ txdatain[23:23])) | (~ txdatain[22:22])) | (~ txdatain[21:21])) | (~ txdatain[20:20])) | (~ txdatain[19:19])) | txdatain[17:17]) | (~ txdatain[16:16])) | (~ txdatain[18:18])),
		nl11OO = ((~ (((~ txctrl[3:3]) | (~ txctrl[2:2])) | (~ txctrl[1:1]))) & (~ nl101i)),
		nl1i0i = (((((((((~ txdatain[23:23]) | (~ txdatain[22:22])) | (~ txdatain[21:21])) | (~ txdatain[20:20])) | txdatain[19:19]) | (~ txdatain[17:17])) | (~ txdatain[16:16])) | (~ txdatain[18:18])) | (~ w_nl1i0l334w)),
		nl1i1O = ((((((((~ txdatain[31:31]) | (~ txdatain[30:30])) | (~ txdatain[29:29])) | (~ txdatain[28:28])) | txdatain[27:27]) | (~ txdatain[25:25])) | (~ txdatain[24:24])) | (~ txdatain[26:26])),
		nl1iii = ((((((((~ txdatain[15:15]) | (~ txdatain[14:14])) | (~ txdatain[13:13])) | (~ txdatain[12:12])) | txdatain[11:11]) | (~ txdatain[9:9])) | (~ txdatain[8:8])) | (~ txdatain[10:10])),
		nl1iil = ((((((((~ txdatain[7:7]) | (~ txdatain[6:6])) | (~ txdatain[5:5])) | (~ txdatain[4:4])) | txdatain[3:3]) | (~ txdatain[1:1])) | (~ txdatain[0:0])) | (~ txdatain[2:2])),
		nl1iiO = (((((((((~ txdatain[31:31]) | (~ txdatain[30:30])) | (~ txdatain[29:29])) | (~ txdatain[28:28])) | (~ txdatain[27:27])) | txdatain[25:25]) | txdatain[24:24]) | (~ txdatain[26:26])) | (~ w_nl1ili317w)),
		nl1ilO = ((((((((~ txdatain[23:23]) | (~ txdatain[22:22])) | (~ txdatain[21:21])) | (~ txdatain[20:20])) | (~ txdatain[19:19])) | txdatain[17:17]) | txdatain[16:16]) | (~ txdatain[18:18])),
		nl1iOi = (((((((((~ txdatain[15:15]) | (~ txdatain[14:14])) | (~ txdatain[13:13])) | (~ txdatain[12:12])) | (~ txdatain[11:11])) | txdatain[9:9]) | txdatain[8:8]) | (~ txdatain[10:10])) | (~ w_nl1iOl308w)),
		nl1l0i = ((((((((~ txdatain[31:31]) | (~ txdatain[30:30])) | txdatain[29:29]) | (~ txdatain[28:28])) | (~ txdatain[27:27])) | txdatain[25:25]) | txdatain[24:24]) | (~ txdatain[26:26])),
		nl1l0l = (((((((((~ txdatain[23:23]) | (~ txdatain[22:22])) | txdatain[21:21]) | (~ txdatain[20:20])) | (~ txdatain[19:19])) | txdatain[17:17]) | txdatain[16:16]) | (~ txdatain[18:18])) | (~ w_nl1l0O288w)),
		nl1l1i = (((((((((~ txdatain[7:7]) | (~ txdatain[6:6])) | (~ txdatain[5:5])) | (~ txdatain[4:4])) | (~ txdatain[3:3])) | txdatain[1:1]) | txdatain[0:0]) | (~ txdatain[2:2])) | (~ w_nl1l1l301w)),
		nl1lil = ((((((((~ txdatain[15:15]) | (~ txdatain[14:14])) | txdatain[13:13]) | (~ txdatain[12:12])) | (~ txdatain[11:11])) | txdatain[9:9]) | txdatain[8:8]) | (~ txdatain[10:10])),
		nl1liO = (((((((((~ txdatain[7:7]) | (~ txdatain[6:6])) | txdatain[5:5]) | (~ txdatain[4:4])) | (~ txdatain[3:3])) | txdatain[1:1]) | txdatain[0:0]) | (~ txdatain[2:2])) | (~ w_nl1lli271w)),
		nl1llO = (((((((txdatain[31:31] | (~ txdatain[30:30])) | txdatain[29:29]) | (~ txdatain[28:28])) | (~ txdatain[27:27])) | txdatain[25:25]) | txdatain[24:24]) | (~ txdatain[26:26])),
		nl1lOi = (((((((txdatain[23:23] | (~ txdatain[22:22])) | txdatain[21:21]) | (~ txdatain[20:20])) | (~ txdatain[19:19])) | txdatain[17:17]) | txdatain[16:16]) | (~ txdatain[18:18])),
		nl1lOl = ((((((((txdatain[15:15] | (~ txdatain[14:14])) | txdatain[13:13]) | (~ txdatain[12:12])) | (~ txdatain[11:11])) | txdatain[9:9]) | txdatain[8:8]) | (~ txdatain[10:10])) | (~ w_nl1lOO246w)),
		nl1O0l = (((((((txdatain[31:31] | txdatain[30:30]) | (~ txdatain[29:29])) | (~ txdatain[28:28])) | (~ txdatain[27:27])) | txdatain[25:25]) | txdatain[24:24]) | (~ txdatain[26:26])),
		nl1O0O = (((((((txdatain[23:23] | txdatain[22:22]) | (~ txdatain[21:21])) | (~ txdatain[20:20])) | (~ txdatain[19:19])) | txdatain[17:17]) | txdatain[16:16]) | (~ txdatain[18:18])),
		nl1O1l = ((((((((txdatain[7:7] | (~ txdatain[6:6])) | txdatain[5:5]) | (~ txdatain[4:4])) | (~ txdatain[3:3])) | txdatain[1:1]) | txdatain[0:0]) | (~ txdatain[2:2])) | (~ w_nl1O1O234w)),
		nl1Oii = (((((((txdatain[15:15] | txdatain[14:14]) | (~ txdatain[13:13])) | (~ txdatain[12:12])) | (~ txdatain[11:11])) | txdatain[9:9]) | txdatain[8:8]) | (~ txdatain[10:10])),
		nl1Oil = (((((((txdatain[7:7] | txdatain[6:6]) | (~ txdatain[5:5])) | (~ txdatain[4:4])) | (~ txdatain[3:3])) | txdatain[1:1]) | txdatain[0:0]) | (~ txdatain[2:2])),
		nl1OiO = (((((((((~ txdatain[31:31]) | (~ txdatain[30:30])) | (~ txdatain[29:29])) | (~ txdatain[28:28])) | (~ txdatain[27:27])) | txdatain[25:25]) | (~ txdatain[24:24])) | (~ txdatain[26:26])) | (~ w_nl1Oli198w)),
		nl1OlO = (((((((((~ txdatain[23:23]) | (~ txdatain[22:22])) | (~ txdatain[21:21])) | (~ txdatain[20:20])) | (~ txdatain[19:19])) | txdatain[17:17]) | (~ txdatain[16:16])) | (~ txdatain[18:18])) | (~ w_nl1OOi190w)),
		nl1OOO = (((((((((~ txdatain[15:15]) | (~ txdatain[14:14])) | (~ txdatain[13:13])) | (~ txdatain[12:12])) | (~ txdatain[11:11])) | txdatain[9:9]) | (~ txdatain[8:8])) | (~ txdatain[10:10])) | (~ w_nl011i182w)),
		txctrlout = {nli0Ol, nlii0l, nliill, nlil1l},
		txdataout = {nlii0i, nliOlO, nlii1O, nlii1l, nlii1i, nli0OO, nliOll, nliOli, nliili, nlO01i, nliiiO, nliiil, nliiii, nlii0O, nlO1OO, nlO1Ol, nlil1i, n10Oi, nliiOO, nliiOl, nliiOi, nliilO, n10lO, n10ll, nlilii, n0ili, nlil0O, nlil0l, nlil0i, nlil1O, n0iiO, n0iil},
		w_nl000i80w = nl000i6,
		w_nl001i95w = nl001i9,
		w_nl00li21w = nl00li3,
		w_nl010i174w = nl010i15,
		w_nl011i182w = nl011i18,
		w_nl01ll130w = nl01ll12,
		w_nl10li364w = nl10li60,
		w_nl10lO359w = nl10lO57,
		w_nl10Ol354w = nl10Ol54,
		w_nl1i0l334w = nl1i0l48,
		w_nl1i1i345w = nl1i1i51,
		w_nl1ili317w = nl1ili45,
		w_nl1iOl308w = nl1iOl42,
		w_nl1l0O288w = nl1l0O36,
		w_nl1l1l301w = nl1l1l39,
		w_nl1lli271w = nl1lli33,
		w_nl1lOO246w = nl1lOO30,
		w_nl1O1O234w = nl1O1O27,
		w_nl1Oli198w = nl1Oli24,
		w_nl1OOi190w = nl1OOi21;
endmodule //altgxb_xgm_tx_sm
//synopsys translate_on
//VALID FILE
//
// altgxb_reset
//

module altgxb_xgm_reset_block
   (
    txdigitalreset,
    rxdigitalreset,
    rxanalogreset,
    pllreset,
    pllenable,
    txdigitalresetout,
    rxdigitalresetout,   
    txanalogresetout,
    rxanalogresetout,
    pllresetout
    );

   // INPUTs
   input [3:0] txdigitalreset;
   input [3:0] rxdigitalreset;
   input [3:0] rxanalogreset;
   input       pllreset;
   input       pllenable;

   // OUTPUTs:
   output [3:0] txdigitalresetout;
   output [3:0] rxdigitalresetout;   
   output [3:0] txanalogresetout;
   output [3:0] rxanalogresetout;
   output 	pllresetout;

   // WIREs:
   wire 	HARD_RESET;

   assign HARD_RESET = pllreset || !pllenable;

   // RESET OUTPUTs
   assign rxanalogresetout = {(HARD_RESET | rxanalogreset[3]),
			      (HARD_RESET | rxanalogreset[2]),
			      (HARD_RESET | rxanalogreset[1]),
			      (HARD_RESET | rxanalogreset[0])};
   
   assign txanalogresetout = {HARD_RESET, HARD_RESET,
			      HARD_RESET, HARD_RESET};
      
   assign pllresetout       = rxanalogresetout[0] & rxanalogresetout[1] & 
			      rxanalogresetout[2] & rxanalogresetout[3] & 
			      txanalogresetout[0] & txanalogresetout[1] & 
			      txanalogresetout[2] & txanalogresetout[3];

   assign rxdigitalresetout = {(HARD_RESET | rxdigitalreset[3]),
			       (HARD_RESET | rxdigitalreset[2]),
			       (HARD_RESET | rxdigitalreset[1]),
			       (HARD_RESET | rxdigitalreset[0])};

   assign txdigitalresetout = {(HARD_RESET | txdigitalreset[3]),
			       (HARD_RESET | txdigitalreset[2]),
			       (HARD_RESET | txdigitalreset[1]),
			       (HARD_RESET | txdigitalreset[0])};
         
endmodule // altgxb_reset_block
///////////////////////////////////////////////////////////////////////////////
//
//                           ALTGXB_XGM_INTERFACE
//
///////////////////////////////////////////////////////////////////////////////



//
// altgxb_xgm_interface
//

`timescale 1 ps/1 ps

module altgxb_xgm_interface
   (
    txdatain,
    txctrl,
    rdenablesync,
    txclk,
    rxdatain,
    rxctrl,
    rxrunningdisp,
    rxdatavalid,
    rxclk,
    resetall,
    adet,
    syncstatus,
    rdalign,
    recovclk,
    devpor,
    devclrn,
    txdataout,
    txctrlout,
    rxdataout,
    rxctrlout,
    resetout,
    alignstatus,
    enabledeskew,
    fiforesetrd,
    // PE ONLY PORTS
    scanclk, 
    scanin, 
    scanshift,
    scanmode,
    scanout,
    test,
    digitalsmtest,
    calibrationstatus,
    // MDIO PORTS
    mdiodisable,
    mdioclk,
    mdioin,
    rxppmselect,
    mdioout,
    mdiooe,
    // RESET PORTS
    txdigitalreset,
    rxdigitalreset,
    rxanalogreset,
    pllreset,
    pllenable,
    txdigitalresetout,
    rxdigitalresetout,   
    txanalogresetout,
    rxanalogresetout,
    pllresetout
    );

   parameter use_continuous_calibration_mode = "OFF";
   parameter mode_is_xaui = "OFF";
   parameter digital_test_output_select = 0;
   parameter analog_test_output_signal_select = 0;
   parameter analog_test_output_channel_select = 0;
   parameter rx_ppm_setting_0 = 0;
   parameter rx_ppm_setting_1 = 0;
   parameter use_rx_calibration_status = "OFF";
   parameter use_global_serial_loopback = "OFF";
   parameter rx_calibration_test_write_value = 0;
   parameter enable_rx_calibration_test_write = "OFF";
   parameter tx_calibration_test_write_value = 0;
   parameter enable_tx_calibration_test_write = "OFF";
      
   input [31 : 0] txdatain;
   input [3 : 0]  txctrl;
   input 	  rdenablesync;
   input 	  txclk;
   input [31 : 0] rxdatain;
   input [3 : 0]  rxctrl;
   input [3 : 0]  rxrunningdisp;
   input [3 : 0]  rxdatavalid;
   input 	  rxclk;
   input 	  resetall;
   input [3 : 0]  adet;
   input [3 : 0]  syncstatus;
   input [3 : 0]  rdalign;
   input 	  recovclk;
   input 	  devpor;
   input 	  devclrn;
   
   // RESET PORTS
   input [3:0] 	  txdigitalreset;
   input [3:0] 	  rxdigitalreset;
   input [3:0] 	  rxanalogreset;
   input 	  pllreset;
   input 	  pllenable;

   // NEW MDIO/PE ONLY PORTS
   input 	  mdioclk;
   input 	  mdiodisable;
   input 	  mdioin;
   input 	  rxppmselect;
   input 	  scanclk;
   input 	  scanin;
   input 	  scanmode;
   input 	  scanshift;
   
   output [31 : 0] txdataout;
   output [3 : 0]  txctrlout;
   output [31 : 0] rxdataout;
   output [3 : 0]  rxctrlout;
   output 	   resetout;
   output 	   alignstatus;
   output 	   enabledeskew;
   output 	   fiforesetrd;
   
   // RESET PORTS
   output [3:0]    txdigitalresetout;
   output [3:0]    rxdigitalresetout;   
   output [3:0]    txanalogresetout;
   output [3:0]    rxanalogresetout;
   output 	   pllresetout;

   // NEW MDIO/PE ONLY PORTS
   output [4:0]    calibrationstatus;
   output [3:0]    digitalsmtest;
   output 	   mdiooe;
   output 	   mdioout;
   output 	   scanout;
   output 	   test;


// input buffers
buf(txdatain_in0, txdatain[0]);
buf(txdatain_in1, txdatain[1]);
buf(txdatain_in2, txdatain[2]);
buf(txdatain_in3, txdatain[3]);
buf(txdatain_in4, txdatain[4]);
buf(txdatain_in5, txdatain[5]);
buf(txdatain_in6, txdatain[6]);
buf(txdatain_in7, txdatain[7]);
buf(txdatain_in8, txdatain[8]);
buf(txdatain_in9, txdatain[9]);
buf(txdatain_in10, txdatain[10]);
buf(txdatain_in11, txdatain[11]);
buf(txdatain_in12, txdatain[12]);
buf(txdatain_in13, txdatain[13]);
buf(txdatain_in14, txdatain[14]);
buf(txdatain_in15, txdatain[15]);
buf(txdatain_in16, txdatain[16]);
buf(txdatain_in17, txdatain[17]);
buf(txdatain_in18, txdatain[18]);
buf(txdatain_in19, txdatain[19]);
buf(txdatain_in20, txdatain[20]);
buf(txdatain_in21, txdatain[21]);
buf(txdatain_in22, txdatain[22]);
buf(txdatain_in23, txdatain[23]);
buf(txdatain_in24, txdatain[24]);
buf(txdatain_in25, txdatain[25]);
buf(txdatain_in26, txdatain[26]);
buf(txdatain_in27, txdatain[27]);
buf(txdatain_in28, txdatain[28]);
buf(txdatain_in29, txdatain[29]);
buf(txdatain_in30, txdatain[30]);
buf(txdatain_in31, txdatain[31]);

buf(rxdatain_in0, rxdatain[0]);
buf(rxdatain_in1, rxdatain[1]);
buf(rxdatain_in2, rxdatain[2]);
buf(rxdatain_in3, rxdatain[3]);
buf(rxdatain_in4, rxdatain[4]);
buf(rxdatain_in5, rxdatain[5]);
buf(rxdatain_in6, rxdatain[6]);
buf(rxdatain_in7, rxdatain[7]);
buf(rxdatain_in8, rxdatain[8]);
buf(rxdatain_in9, rxdatain[9]);
buf(rxdatain_in10, rxdatain[10]);
buf(rxdatain_in11, rxdatain[11]);
buf(rxdatain_in12, rxdatain[12]);
buf(rxdatain_in13, rxdatain[13]);
buf(rxdatain_in14, rxdatain[14]);
buf(rxdatain_in15, rxdatain[15]);
buf(rxdatain_in16, rxdatain[16]);
buf(rxdatain_in17, rxdatain[17]);
buf(rxdatain_in18, rxdatain[18]);
buf(rxdatain_in19, rxdatain[19]);
buf(rxdatain_in20, rxdatain[20]);
buf(rxdatain_in21, rxdatain[21]);
buf(rxdatain_in22, rxdatain[22]);
buf(rxdatain_in23, rxdatain[23]);
buf(rxdatain_in24, rxdatain[24]);
buf(rxdatain_in25, rxdatain[25]);
buf(rxdatain_in26, rxdatain[26]);
buf(rxdatain_in27, rxdatain[27]);
buf(rxdatain_in28, rxdatain[28]);
buf(rxdatain_in29, rxdatain[29]);
buf(rxdatain_in30, rxdatain[30]);
buf(rxdatain_in31, rxdatain[31]);

buf(txctrl_in0, txctrl[0]);
buf(txctrl_in1, txctrl[1]);
buf(txctrl_in2, txctrl[2]);
buf(txctrl_in3, txctrl[3]);

buf(rxctrl_in0, rxctrl[0]);
buf(rxctrl_in1, rxctrl[1]);
buf(rxctrl_in2, rxctrl[2]);
buf(rxctrl_in3, rxctrl[3]);

buf(txclk_in, txclk);
buf(rxclk_in, rxclk);
buf(recovclk_in, recovclk);

buf (rdenablesync_in, rdenablesync);
buf (resetall_in, resetall);

buf(rxrunningdisp_in0, rxrunningdisp[0]);
buf(rxrunningdisp_in1, rxrunningdisp[1]);
buf(rxrunningdisp_in2, rxrunningdisp[2]);
buf(rxrunningdisp_in3, rxrunningdisp[3]);

buf(rxdatavalid_in0, rxdatavalid[0]);
buf(rxdatavalid_in1, rxdatavalid[1]);
buf(rxdatavalid_in2, rxdatavalid[2]);
buf(rxdatavalid_in3, rxdatavalid[3]);

buf(adet_in0, adet[0]);
buf(adet_in1, adet[1]);
buf(adet_in2, adet[2]);
buf(adet_in3, adet[3]);

buf(syncstatus_in0, syncstatus[0]);
buf(syncstatus_in1, syncstatus[1]);
buf(syncstatus_in2, syncstatus[2]);
buf(syncstatus_in3, syncstatus[3]);

buf(rdalign_in0, rdalign[0]);
buf(rdalign_in1, rdalign[1]);
buf(rdalign_in2, rdalign[2]);
buf(rdalign_in3, rdalign[3]);

// internal input signals
wire reset_int;

assign reset_int = resetall_in;

// internal data bus
wire [31 : 0] txdatain_in;
wire [31 : 0] rxdatain_in;
wire [3 : 0] txctrl_in;
wire [3 : 0] rxctrl_in;
wire [3 : 0] rxrunningdisp_in;
wire [3 : 0] rxdatavalid_in;
wire [3 : 0] adet_in;
wire [3 : 0] syncstatus_in;
wire [3 : 0] rdalign_in;

assign txdatain_in = {
							txdatain_in31, txdatain_in30, txdatain_in29,
							txdatain_in28, txdatain_in27, txdatain_in26,
							txdatain_in25, txdatain_in24, txdatain_in23,
							txdatain_in22, txdatain_in21, txdatain_in20,
							txdatain_in19, txdatain_in18, txdatain_in17,
							txdatain_in16, txdatain_in15, txdatain_in14,
							txdatain_in13, txdatain_in12, txdatain_in11,
							txdatain_in10, txdatain_in9, txdatain_in8,
							txdatain_in7, txdatain_in6, txdatain_in5,
							txdatain_in4, txdatain_in3, txdatain_in2,
							txdatain_in1, txdatain_in0
							};
							
assign rxdatain_in = {
							rxdatain_in31, rxdatain_in30, rxdatain_in29,
							rxdatain_in28, rxdatain_in27, rxdatain_in26,
							rxdatain_in25, rxdatain_in24, rxdatain_in23,
							rxdatain_in22, rxdatain_in21, rxdatain_in20,
							rxdatain_in19, rxdatain_in18, rxdatain_in17,
							rxdatain_in16, rxdatain_in15, rxdatain_in14,
							rxdatain_in13, rxdatain_in12, rxdatain_in11,
							rxdatain_in10, rxdatain_in9, rxdatain_in8,
							rxdatain_in7, rxdatain_in6, rxdatain_in5,
							rxdatain_in4, rxdatain_in3, rxdatain_in2,
							rxdatain_in1, rxdatain_in0
							};
							
assign txctrl_in = {txctrl_in3, txctrl_in2, txctrl_in1, txctrl_in0};
assign rxctrl_in = {rxctrl_in3, rxctrl_in2, rxctrl_in1, rxctrl_in0};

assign rxrunningdisp_in = {rxrunningdisp_in3, rxrunningdisp_in2, 
									rxrunningdisp_in1, rxrunningdisp_in0};

assign rxdatavalid_in = {rxdatavalid_in3, rxdatavalid_in2, 
								rxdatavalid_in1, rxdatavalid_in0};

assign adet_in = {adet_in3, adet_in2, adet_in1, adet_in0};

assign syncstatus_in = {syncstatus_in3, syncstatus_in2, 
								syncstatus_in1, syncstatus_in0};

assign rdalign_in = {rdalign_in3, rdalign_in2, 
							rdalign_in1, rdalign_in0};

// internal output signals
wire resetout_tmp;

assign resetout_tmp = resetall_in;

// adding devpor and devclrn - do not merge to MF models
wire extended_pllreset;
assign extended_pllreset = pllreset || (!devpor) || (!devclrn);

   altgxb_xgm_reset_block altgxb_reset
      (
       .txdigitalreset(txdigitalreset),
       .rxdigitalreset(rxdigitalreset),
       .rxanalogreset(rxanalogreset),
       .pllreset(extended_pllreset),
       .pllenable(pllenable),
       .txdigitalresetout(txdigitalresetout),
       .rxdigitalresetout(rxdigitalresetout),
       .txanalogresetout(txanalogresetout),
       .rxanalogresetout(rxanalogresetout),
       .pllresetout(pllresetout)
       );

   altgxb_xgm_rx_sm s_xgm_rx_sm	
      (
       .rxdatain(rxdatain_in),
       .rxctrl(rxctrl_in),
       .rxrunningdisp(rxrunningdisp_in),
       .rxdatavalid(rxdatavalid_in),
       .rxclk(rxclk_in),
       .resetall(rxdigitalresetout[0]),
       .rxdataout(rxdataout),
       .rxctrlout(rxctrlout)
       );
   
   altgxb_xgm_tx_sm s_xgm_tx_sm	
      (
       .txdatain(txdatain_in),
       .txctrl(txctrl_in),
       .rdenablesync(rdenablesync_in),
       .txclk(txclk_in),
       .resetall(txdigitalresetout[0]),
       .txdataout(txdataout),
       .txctrlout(txctrlout)
       );
   
   altgxb_xgm_dskw_sm s_xgm_dskw_sm 
      (
       .resetall(rxdigitalresetout[0]),
       .adet(adet_in),
       .syncstatus(syncstatus_in),
       .rdalign(rdalign_in),
       .recovclk(recovclk_in),
       .alignstatus(alignstatus),
       .enabledeskew(enabledeskew),
       .fiforesetrd(fiforesetrd)
       );
   
   and (resetout, resetout_tmp,  1'b1);
   
endmodule

///////////////////////////////////////////////////////////////////////////////
//
//                               ALTGXB_TX_CORE
//
///////////////////////////////////////////////////////////////////////////////
   
`timescale 10 ps / 1 ps
module altgxb_tx_core 
   (
    reset,
    datain,
    writeclk,
    readclk,
    ctrlena,
    forcedisp,
    dataout,
    forcedispout,
    ctrlenaout,
    rdenasync,
    xgmctrlena,
    xgmdataout,
    pre8b10bdataout
    );

   parameter use_double_data_mode = "OFF";    
   parameter use_fifo_mode        = "ON";
   parameter transmit_protocol    = "NONE";
   parameter channel_width        = 10;
   parameter KCHAR  = 1'b0; // enable control char 
   parameter ECHAR  = 1'b0; // enable error char

   input reset;
   input [19:0] datain;
   input writeclk;
   input readclk;
   input [1:0] ctrlena;
   input [1:0] forcedisp;
   
   output      forcedispout;
   output      ctrlenaout;
   output      rdenasync;
   output      xgmctrlena;
   output [9:0] dataout;
   output [7:0] xgmdataout;
   output [9:0] pre8b10bdataout;
   
   reg 		kchar_sync_1;
   reg 		kchar_sync;
   reg 		echar_sync_1;
   reg 		echar_sync;
   reg [11:0] 	datain_high;
   reg [11:0] 	datain_low;
   reg [11:0] 	fifo_high_tmp;
   reg [11:0] 	fifo_high_dly1;
   reg [11:0] 	fifo_high_dly2;
   reg [11:0] 	fifo_high_dly3;
   reg [11:0] 	fifo_low_tmp;
   reg [11:0] 	fifo_low_dly1;
   reg [11:0] 	fifo_low_dly2;
   reg [11:0] 	fifo_low_dly3;
   reg 		wr_enable;
   reg 		rd_enable_sync_1;
   reg 		rd_enable_sync_2; 
   reg 		rd_enable_sync_out;
   reg 		fifo_select_out;
   wire 	rdenasync_tmp; 

   reg	    writeclk_dly; 
   reg [11:0] 	dataout_read;

   wire 	out_ena1;
   wire 	out_ena2;
   wire 	out_ena3;
   wire 	out_ena4;
   wire 	out_ena5;
   wire 	doublewidth;
   wire 	disablefifo;
   wire 	individual;

   assign doublewidth = (use_double_data_mode == "ON") ? 1'b1 : 1'b0;
   assign disablefifo = (use_fifo_mode == "OFF") ? 1'b1 : 1'b0;
   assign individual  = (transmit_protocol != "XAUI") ? 1'b1 : 1'b0;

   always @ (writeclk)
     begin
       writeclk_dly <= writeclk;
     end

   // READ CLOCK SYNC LOGIC
   always @ (posedge reset or posedge readclk)
      begin
	 if (reset)
	    begin
	       kchar_sync_1 <= 1'b0;
	       kchar_sync   <= 1'b0;
	       echar_sync_1 <= 1'b0;
	       echar_sync   <= 1'b0;
	    end
	 else
	    begin
	       kchar_sync_1 <= KCHAR;
	       kchar_sync   <= kchar_sync_1;
	       echar_sync_1 <= ECHAR;
	       echar_sync   <= echar_sync_1;
	    end
      end
   
   assign dataout         = dataout_read[9:0];
   assign xgmdataout      = dataout_read[7:0];
   assign pre8b10bdataout = dataout_read[9:0];

   assign forcedispout    = dataout_read[10];
   assign ctrlenaout      = dataout_read[11];
   assign xgmctrlena      = dataout_read[11];

   assign rdenasync       = rdenasync_tmp;
      
   always @ (reset or writeclk_dly or datain or forcedisp or ctrlena)
   begin
	 if (reset)
	   begin
	      datain_high[11:0]   <= 'b0;
	      datain_low[11:0]   <= 'b0;
	   end
	 else
	   begin
	      if (channel_width == 10 || channel_width == 20)
		    begin
              if (doublewidth)
		        datain_high[11:0] <= {ctrlena[1], forcedisp[1], datain[19:10]};
		      else
		        datain_high[11:0] <= {ctrlena[0], forcedisp[0], datain[9:0]};
		   
		      datain_low[11:0] <= {ctrlena[0], forcedisp[0], datain[9:0]};
		    end
	      else
		    begin
              if (doublewidth)
                datain_high[11:0] <= {ctrlena[1], forcedisp[1], 2'b00, datain[15:8]};
		      else
                datain_high[11:0] <= {ctrlena[0], forcedisp[0], 2'b00, datain[7:0]};
		   
		     datain_low[11:0] <= {ctrlena[0], forcedisp[0], 2'b00, datain[7:0]};
		    end

	   end
   end
   
   // FIFO FOR HIGH BITS
   always @ (posedge reset or posedge writeclk_dly)
      begin
	 if (reset)
	    begin
	       fifo_high_dly1 <= 10'b0;
	       fifo_high_dly2 <= 10'b0;
	       fifo_high_dly3 <= 10'b0;
	       fifo_high_tmp  <= 10'b0;
	    end
	 else
	    begin
	       fifo_high_dly1 <= datain_high;
	       fifo_high_dly2 <= fifo_high_dly1;
	       fifo_high_dly3 <= fifo_high_dly2;
	       fifo_high_tmp  <= fifo_high_dly3;
	    end
      end 

   // FIFO FOR LOWER BITS
   always @ (posedge reset or posedge writeclk_dly)
      begin
	 if (reset)
	    begin
	       fifo_low_dly1 <= 'b0;
	       fifo_low_dly2 <= 'b0;
	       fifo_low_dly3 <= 'b0;
	       fifo_low_tmp  <= 'b0;
	    end
	 else
	    begin
	       fifo_low_dly1 <= datain_low;
	       fifo_low_dly2 <= fifo_low_dly1;
	       fifo_low_dly3 <= fifo_low_dly2;
	       fifo_low_tmp  <= fifo_low_dly3;
	    end
      end 

   // DATAOUT ENABLE LOGIC
   assign out_ena1 = (~disablefifo & rdenasync_tmp & (~doublewidth | fifo_select_out) & ~kchar_sync & ~echar_sync);
   assign out_ena2 = (~disablefifo & rdenasync_tmp & (doublewidth & ~fifo_select_out) & ~kchar_sync & ~echar_sync);
   assign out_ena3 = (disablefifo & (~doublewidth | ~fifo_select_out) & ~kchar_sync & ~echar_sync);
   assign out_ena4 = (~kchar_sync & echar_sync);
   assign out_ena5 = (disablefifo & doublewidth & fifo_select_out & ~kchar_sync & ~echar_sync);
   
   // Dataout, CTRL, FORCE_DISP registered by read clock
   always @ (posedge reset or posedge readclk)
     begin
	 if (reset)
	     dataout_read      <= 'b0;
	 else
	   begin
	   if (out_ena1)
    	 dataout_read <= fifo_low_tmp;
	   else if (out_ena2)
	     dataout_read <= fifo_high_tmp;
	   else if (out_ena3)
	     dataout_read <= datain_low;	     
	   else if (out_ena4)
	     begin
		   dataout_read[7:0] <= 8'b11111110;
		   dataout_read[10] <= 1'b0;
		   dataout_read[11] <= 1'b1;
		 end
	   else if (out_ena5)
	     begin
		   dataout_read <= datain_high;
		 end
	   else 
	     begin
		   dataout_read[10] <= 1'b0;
		   dataout_read[11] <= 1'b1;  // fixed from 3.0
		   if (~individual)
	         dataout_read[7:0] <= 8'b00000111; 
	       else
	         dataout_read[7:0] <= 8'b10111100;
		 end
	     
	   end // end of not reset
     end // end of always


   // fifo_select_out == 1: send out low byte

   always @(posedge reset or writeclk_dly)
     begin
	   if (reset | writeclk_dly)
	     fifo_select_out  <= 1'b1;
	   else
	     fifo_select_out  <= 1'b0;
       end

   // Delay chains on RD_ENA 
   always @(posedge reset or posedge readclk)
     begin
	if (reset)
	  begin
	     rd_enable_sync_1 <= 1'b0;
	     rd_enable_sync_2 <= 1'b0;
	     rd_enable_sync_out <= 1'b0;
	  end
	else
	  begin
	     rd_enable_sync_1 <= wr_enable | disablefifo;
	     rd_enable_sync_2 <= rd_enable_sync_1;
	     rd_enable_sync_out <= rd_enable_sync_2;
	  end
     end
   
   always @ (posedge reset or posedge writeclk_dly)
     begin
	if (reset)
	  wr_enable <= 1'b0;
	else
	  wr_enable <= 1'b1;
     end

   assign rdenasync_tmp  = (individual)? rd_enable_sync_out : rd_enable_sync_1;
   
endmodule // altgxb_tx_core

//
// ALTGXB_HSSI_TX_SERDES
//

`timescale 1 ps/1 ps

module altgxb_hssi_tx_serdes
	(
		clk, 
		clk1, 
		datain, 
		serialdatain, 
		srlpbk, 
		areset, 
		dataout 
	);

input [9:0] datain;
input clk; // fast clock
input clk1; //slow clock
input	serialdatain;
input	srlpbk;
input areset;

output dataout;

parameter channel_width = 10;

integer i;
integer pclk_count;
integer shift_edge;
reg dataout_tmp;
reg [9:0] regdata;
reg [9:0] shiftdata;

reg clk_dly;
reg clk1_dly;

buf (datain_in0, datain[0]);
buf (datain_in1, datain[1]);
buf (datain_in2, datain[2]);
buf (datain_in3, datain[3]);
buf (datain_in4, datain[4]);
buf (datain_in5, datain[5]);
buf (datain_in6, datain[6]);
buf (datain_in7, datain[7]);
buf (datain_in8, datain[8]);
buf (datain_in9, datain[9]);

initial
begin
   i = 0;
   pclk_count = 0;
   shift_edge = channel_width/2;
   dataout_tmp = 1'bX;
 	for (i = 9; i >= 0; i = i - 1) 
	begin
		regdata[i] = 1'bZ;
		shiftdata[i] = 1'bZ;
	end
end

always @(clk or clk1)
begin
   clk_dly <= clk;
   clk1_dly = clk1;
end

always @(clk_dly or areset)
begin
	if (areset == 1'b1)
      dataout_tmp = 1'bZ;
   else 
   begin // dataout comes out on both edges 
      //load on the first fast clk after slow clk to avoid race condition
      if (pclk_count == 1)
      begin
			regdata[0] = datain_in9; 
	      regdata[1] = datain_in8; 
	      regdata[2] = datain_in7; 
	      regdata[3] = datain_in6; 
	      regdata[4] = datain_in5; 
	      regdata[5] = datain_in4; 
	      regdata[6] = datain_in3; 
	      regdata[7] = datain_in2; 
	      regdata[8] = datain_in1; 
	      regdata[9] = datain_in0; 
      end

      if (clk == 1'b1) // rising edge
      begin
         pclk_count = pclk_count + 1;

         // loading edge
         if (pclk_count == shift_edge) 
            shiftdata = regdata;
      end

		if (srlpbk == 1'b1)
      	dataout_tmp = serialdatain;
		else
      	dataout_tmp = shiftdata[9];

      for (i = 9; i > (10 - channel_width); i = i - 1)
			shiftdata[i] = shiftdata[i-1];
	end
end

always @(posedge clk1_dly or areset)
begin
	if (areset == 1'b1)
   begin
   	for (i = 9; i >= 0; i = i - 1) 
		begin
			regdata[i] = 1'bZ;
			shiftdata[i] = 1'bZ;
		end
   end
   else 
      begin
         pclk_count = 0;
		end
end

and (dataout, dataout_tmp,  1'b1);

endmodule
//IP Functional Simulation Model
//VERSION_BEGIN 4.1 cbx_mgl 2004:06:17:17:30:06:SJ cbx_simgen 2004:06:22:10:53:08:SJ  VERSION_END


// Legal Notice: � 2003 Altera Corporation. All rights reserved.
// You may only use these  simulation  model  output files for simulation
// purposes and expressly not for synthesis or any other purposes (in which
// event  Altera disclaims all warranties of any kind). Your use of  Altera
// Corporation's design tools, logic functions and other software and tools,
// and its AMPP partner logic functions, and any output files any of the
// foregoing (including device programming or simulation files), and any
// associated documentation or information  are expressly subject to the
// terms and conditions of the  Altera Program License Subscription Agreement
// or other applicable license agreement, including, without limitation, that
// your use is for the sole purpose of programming logic devices manufactured
// by Altera and sold by Altera or its authorized distributors.  Please refer
// to the applicable agreement for further details.


//synopsys translate_off

//synthesis_resources = lut 83 mux21 46 oper_decoder 1 oper_selector 10 
`timescale 1 ps / 1 ps
module  altgxb_hssi_tx_enc_rtl
	( 
	ENDEC,
	GE_XAUI_SEL,
	IB_FORCE_DISPARITY,
	INDV,
	prbs_en,
	PUDR,
	soft_reset,
	tx_clk,
	tx_ctl_tc,
	tx_ctl_ts,
	tx_data_9_tc,
	tx_data_pg,
	tx_data_tc,
	tx_data_ts,
	TXLP10B) /* synthesis synthesis_clearbox=1 */;
	input   ENDEC;
	input   GE_XAUI_SEL;
	input   IB_FORCE_DISPARITY;
	input   INDV;
	input   prbs_en;
	output   [9:0]  PUDR;
	input   soft_reset;
	input   tx_clk;
	input   tx_ctl_tc;
	input   tx_ctl_ts;
	input   tx_data_9_tc;
	input   [9:0]  tx_data_pg;
	input   [7:0]  tx_data_tc;
	input   [7:0]  tx_data_ts;
	output   [9:0]  TXLP10B;

	reg	n00i;
	reg	n00l;
	reg	n00O;
	reg	n01i;
	reg	n01l;
	reg	n01O;
	reg	n0ii;
	reg	n100l43;
	reg	n100l44;
	reg	n100l45;
	reg	n101O46;
	reg	n101O47;
	reg	n101O48;
	reg	n10il40;
	reg	n10il41;
	reg	n10il42;
	reg	n10l;
	reg	n10li37;
	reg	n10li38;
	reg	n10li39;
	reg	n10O;
	wire	wire_n10O_ENA;
	reg	n10Oi34;
	reg	n10Oi35;
	reg	n10Oi36;
	reg	n10OO31;
	reg	n10OO32;
	reg	n10OO33;
	reg	n110i58;
	reg	n110i59;
	reg	n110i60;
	reg	n11iO55;
	reg	n11iO56;
	reg	n11iO57;
	reg	n11ll52;
	reg	n11ll53;
	reg	n11ll54;
	reg	n11Oi49;
	reg	n11Oi50;
	reg	n11Oi51;
	reg	n1i0l25;
	reg	n1i0l26;
	reg	n1i0l27;
	reg	n1i1O28;
	reg	n1i1O29;
	reg	n1i1O30;
	reg	n1ii;
	reg	n1iii22;
	reg	n1iii23;
	reg	n1iii24;
	reg	n1iiO19;
	reg	n1iiO20;
	reg	n1iiO21;
	reg	n1il;
	reg	n1ill16;
	reg	n1ill17;
	reg	n1ill18;
	reg	n1iO;
	reg	n1iOi13;
	reg	n1iOi14;
	reg	n1iOi15;
	reg	n1iOO10;
	reg	n1iOO11;
	reg	n1iOO12;
	reg	n1l0O4;
	reg	n1l0O5;
	reg	n1l0O6;
	reg	n1l1O7;
	reg	n1l1O8;
	reg	n1l1O9;
	reg	n1li;
	reg	n1lli1;
	reg	n1lli2;
	reg	n1lli3;
	reg	n1Oi;
	reg	n1Ol;
	reg	n1OO;
	reg	nlO0i;
	reg	nlO0l;
	reg	nlO0O;
	reg	nlO1i;
	reg	nlO1l;
	reg	nlO1O;
	reg	nlOii;
	wire	wire_n0iiO_dataout;
	wire	wire_n0liO_dataout;
	wire	wire_n0ll_dataout;
	wire	wire_n0lli_dataout;
	wire	wire_n0lll_dataout;
	wire	wire_n0llO_dataout;
	wire	wire_n0lO_dataout;
	wire	wire_n0lOi_dataout;
	wire	wire_n0lOl_dataout;
	wire	wire_n0Oi_dataout;
	wire	wire_n0Ol_dataout;
	wire	wire_n0OO_dataout;
	wire	wire_n1i_dataout;
	wire	wire_n1l_dataout;
	wire	wire_ni01l_dataout;
	wire	wire_ni0i_dataout;
	wire	wire_ni0l_dataout;
	wire	wire_ni0O_dataout;
	wire	wire_ni1i_dataout;
	wire	wire_ni1l_dataout;
	wire	wire_ni1li_dataout;
	wire	wire_ni1ll_dataout;
	wire	wire_ni1O_dataout;
	wire	wire_niii_dataout;
	wire	wire_niil_dataout;
	wire	wire_niiO_dataout;
	wire	wire_nili_dataout;
	wire	wire_nill_dataout;
	wire	wire_nilO_dataout;
	wire	wire_nilOO_dataout;
	wire	wire_niO0i_dataout;
	wire	wire_niO1O_dataout;
	wire	wire_niOi_dataout;
	wire	wire_niOil_dataout;
	wire	wire_niOl_dataout;
	wire	wire_niOli_dataout;
	wire	wire_niOll_dataout;
	wire	wire_niOlO_dataout;
	wire	wire_niOO_dataout;
	wire	wire_niOOi_dataout;
	wire	wire_niOOl_dataout;
	wire	wire_nl0i_dataout;
	wire	wire_nl1i_dataout;
	wire	wire_nl1l_dataout;
	wire	wire_nl1O_dataout;
	wire	wire_nlOO_dataout;
	wire  [3:0]   wire_n10i_o;
	wire  wire_n11i_o;
	wire  wire_n11l_o;
	wire  wire_nlOil_o;
	wire  wire_nlOiO_o;
	wire  wire_nlOli_o;
	wire  wire_nlOll_o;
	wire  wire_nlOlO_o;
	wire  wire_nlOOi_o;
	wire  wire_nlOOl_o;
	wire  wire_nlOOO_o;
	wire  n101i;
	wire  n101l;
	wire  n10ii;
	wire  n10lO;
	wire  n110O;
	wire  n111i;
	wire  n111l;
	wire  n111O;
	wire  n11ii;
	wire  n11il;
	wire  n11OO;
	wire  n1i1l;
	wire  n1l0l;
	wire  n1l1l;
	wire  n1lil;
	wire  n1liO;
	wire  nlOlOl;
	wire  nlOlOO;
	wire  nlOO0i;
	wire  nlOO0l;
	wire  nlOO0O;
	wire  nlOO1i;
	wire  nlOO1l;
	wire  nlOO1O;
	wire  nlOOii;
	wire  nlOOil;
	wire  nlOOiO;
	wire  nlOOli;
	wire  nlOOll;
	wire  nlOOlO;
	wire  nlOOOi;
	wire  nlOOOl;
	wire  nlOOOO;
	wire  w_n100l136w;
	wire  w_n101O147w;
	wire  w_n10il129w;
	wire  w_n10li123w;
	wire  w_n10Oi106w;
	wire  w_n10OO101w;
	wire  w_n110i291w;
	wire  w_n11iO281w;
	wire  w_n11ll275w;
	wire  w_n11Oi269w;
	wire  w_n1i0l89w;
	wire  w_n1i1O93w;
	wire  w_n1iii83w;
	wire  w_n1iiO78w;
	wire  w_n1ill73w;
	wire  w_n1iOi68w;
	wire  w_n1iOO62w;
	wire  w_n1l0O39w;
	wire  w_n1l1O54w;
	wire  w_n1lli24w;

	initial
		n00i = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n00i <= 1'b0;
		else   n00i <= wire_nlOOi_o;
	initial
		n00l = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n00l <= 1'b0;
		else   n00l <= wire_nlOOl_o;
	initial
		n00O = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n00O <= 1'b0;
		else   n00O <= wire_nlOOO_o;
	initial
		n01i = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n01i <= 1'b0;
		else   n01i <= wire_nlOli_o;
	initial
		n01l = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n01l <= 1'b0;
		else   n01l <= wire_nlOll_o;
	initial
		n01O = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n01O <= 1'b0;
		else   n01O <= wire_nlOlO_o;
	initial
		n0ii = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0ii <= 1'b0;
		else   n0ii <= wire_n11i_o;
	initial
		n100l43 = 1'b1;
	always @ ( posedge n1liO)
		  n100l43 <= n100l44;
	initial
		n100l44 = 0;
	always @ ( posedge n1liO)
		  n100l44 <= n100l43;
	initial
		n100l45 = 0;
	always @ ( posedge n1liO)
		  n100l45 <= (n100l44 ^ n100l43);
	initial
		n101O46 = 1'b1;
	always @ ( posedge n1liO)
		  n101O46 <= n101O47;
	initial
		n101O47 = 0;
	always @ ( posedge n1liO)
		  n101O47 <= n101O46;
	initial
		n101O48 = 0;
	always @ ( posedge n1liO)
		  n101O48 <= (n101O47 ^ n101O46);
	initial
		n10il40 = 1'b1;
	always @ ( posedge n1liO)
		  n10il40 <= n10il41;
	initial
		n10il41 = 0;
	always @ ( posedge n1liO)
		  n10il41 <= n10il40;
	initial
		n10il42 = 0;
	always @ ( posedge n1liO)
		  n10il42 <= (n10il41 ^ n10il40);
	initial
		n10l = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n10l <= 1'b0;
		else   n10l <= wire_nilOO_dataout;
	initial
		n10li37 = 1'b1;
	always @ ( posedge n1liO)
		  n10li37 <= n10li38;
	initial
		n10li38 = 0;
	always @ ( posedge n1liO)
		  n10li38 <= n10li37;
	initial
		n10li39 = 0;
	always @ ( posedge n1liO)
		  n10li39 <= (n10li38 ^ n10li37);
	initial
		n10O = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n10O <= 1'b0;
		else if  (wire_n10O_ENA == 1'b1)   n10O <= 1;
	assign
		wire_n10O_ENA = ((~ n10O) & ((tx_data_9_tc & IB_FORCE_DISPARITY) & w_n100l136w));
	initial
		n10Oi34 = 1'b1;
	always @ ( posedge n1liO)
		  n10Oi34 <= n10Oi35;
	initial
		n10Oi35 = 0;
	always @ ( posedge n1liO)
		  n10Oi35 <= n10Oi34;
	initial
		n10Oi36 = 0;
	always @ ( posedge n1liO)
		  n10Oi36 <= (n10Oi35 ^ n10Oi34);
	initial
		n10OO31 = 1'b1;
	always @ ( posedge n1liO)
		  n10OO31 <= n10OO32;
	initial
		n10OO32 = 0;
	always @ ( posedge n1liO)
		  n10OO32 <= n10OO31;
	initial
		n10OO33 = 0;
	always @ ( posedge n1liO)
		  n10OO33 <= (n10OO32 ^ n10OO31);
	initial
		n110i58 = 1'b1;
	always @ ( posedge n1liO)
		  n110i58 <= n110i59;
	initial
		n110i59 = 0;
	always @ ( posedge n1liO)
		  n110i59 <= n110i58;
	initial
		n110i60 = 0;
	always @ ( posedge n1liO)
		  n110i60 <= (n110i59 ^ n110i58);
	initial
		n11iO55 = 1'b1;
	always @ ( posedge n1liO)
		  n11iO55 <= n11iO56;
	initial
		n11iO56 = 0;
	always @ ( posedge n1liO)
		  n11iO56 <= n11iO55;
	initial
		n11iO57 = 0;
	always @ ( posedge n1liO)
		  n11iO57 <= (n11iO56 ^ n11iO55);
	initial
		n11ll52 = 1'b1;
	always @ ( posedge n1liO)
		  n11ll52 <= n11ll53;
	initial
		n11ll53 = 0;
	always @ ( posedge n1liO)
		  n11ll53 <= n11ll52;
	initial
		n11ll54 = 0;
	always @ ( posedge n1liO)
		  n11ll54 <= (n11ll53 ^ n11ll52);
	initial
		n11Oi49 = 1'b1;
	always @ ( posedge n1liO)
		  n11Oi49 <= n11Oi50;
	initial
		n11Oi50 = 0;
	always @ ( posedge n1liO)
		  n11Oi50 <= n11Oi49;
	initial
		n11Oi51 = 0;
	always @ ( posedge n1liO)
		  n11Oi51 <= (n11Oi50 ^ n11Oi49);
	initial
		n1i0l25 = 1'b1;
	always @ ( posedge n1liO)
		  n1i0l25 <= n1i0l26;
	initial
		n1i0l26 = 0;
	always @ ( posedge n1liO)
		  n1i0l26 <= n1i0l25;
	initial
		n1i0l27 = 0;
	always @ ( posedge n1liO)
		  n1i0l27 <= (n1i0l26 ^ n1i0l25);
	initial
		n1i1O28 = 1'b1;
	always @ ( posedge n1liO)
		  n1i1O28 <= n1i1O29;
	initial
		n1i1O29 = 0;
	always @ ( posedge n1liO)
		  n1i1O29 <= n1i1O28;
	initial
		n1i1O30 = 0;
	always @ ( posedge n1liO)
		  n1i1O30 <= (n1i1O29 ^ n1i1O28);
	initial
		n1ii = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n1ii <= 1'b0;
		else   n1ii <= (~ n1l1l);
	initial
		n1iii22 = 1'b1;
	always @ ( posedge n1liO)
		  n1iii22 <= n1iii23;
	initial
		n1iii23 = 0;
	always @ ( posedge n1liO)
		  n1iii23 <= n1iii22;
	initial
		n1iii24 = 0;
	always @ ( posedge n1liO)
		  n1iii24 <= (n1iii23 ^ n1iii22);
	initial
		n1iiO19 = 1'b1;
	always @ ( posedge n1liO)
		  n1iiO19 <= n1iiO20;
	initial
		n1iiO20 = 0;
	always @ ( posedge n1liO)
		  n1iiO20 <= n1iiO19;
	initial
		n1iiO21 = 0;
	always @ ( posedge n1liO)
		  n1iiO21 <= (n1iiO20 ^ n1iiO19);
	initial
		n1il = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n1il <= 1'b0;
		else   n1il <= wire_n0liO_dataout;
	initial
		n1ill16 = 1'b1;
	always @ ( posedge n1liO)
		  n1ill16 <= n1ill17;
	initial
		n1ill17 = 0;
	always @ ( posedge n1liO)
		  n1ill17 <= n1ill16;
	initial
		n1ill18 = 0;
	always @ ( posedge n1liO)
		  n1ill18 <= (n1ill17 ^ n1ill16);
	initial
		n1iO = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n1iO <= 1'b0;
		else   n1iO <= wire_n0lli_dataout;
	initial
		n1iOi13 = 1'b1;
	always @ ( posedge n1liO)
		  n1iOi13 <= n1iOi14;
	initial
		n1iOi14 = 0;
	always @ ( posedge n1liO)
		  n1iOi14 <= n1iOi13;
	initial
		n1iOi15 = 0;
	always @ ( posedge n1liO)
		  n1iOi15 <= (n1iOi14 ^ n1iOi13);
	initial
		n1iOO10 = 1'b1;
	always @ ( posedge n1liO)
		  n1iOO10 <= n1iOO11;
	initial
		n1iOO11 = 0;
	always @ ( posedge n1liO)
		  n1iOO11 <= n1iOO10;
	initial
		n1iOO12 = 0;
	always @ ( posedge n1liO)
		  n1iOO12 <= (n1iOO11 ^ n1iOO10);
	initial
		n1l0O4 = 1'b1;
	always @ ( posedge n1liO)
		  n1l0O4 <= n1l0O5;
	initial
		n1l0O5 = 0;
	always @ ( posedge n1liO)
		  n1l0O5 <= n1l0O4;
	initial
		n1l0O6 = 0;
	always @ ( posedge n1liO)
		  n1l0O6 <= (n1l0O5 ^ n1l0O4);
	initial
		n1l1O7 = 1'b1;
	always @ ( posedge n1liO)
		  n1l1O7 <= n1l1O8;
	initial
		n1l1O8 = 0;
	always @ ( posedge n1liO)
		  n1l1O8 <= n1l1O7;
	initial
		n1l1O9 = 0;
	always @ ( posedge n1liO)
		  n1l1O9 <= (n1l1O8 ^ n1l1O7);
	initial
		n1li = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n1li <= 1'b0;
		else   n1li <= wire_niOlO_dataout;
	initial
		n1lli1 = 1'b1;
	always @ ( posedge n1liO)
		  n1lli1 <= n1lli2;
	initial
		n1lli2 = 0;
	always @ ( posedge n1liO)
		  n1lli2 <= n1lli1;
	initial
		n1lli3 = 0;
	always @ ( posedge n1liO)
		  n1lli3 <= (n1lli2 ^ n1lli1);
	initial
		n1Oi = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n1Oi <= 1'b0;
		else   n1Oi <= wire_niOOl_dataout;
	initial
		n1Ol = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n1Ol <= 1'b0;
		else   n1Ol <= wire_nlOil_o;
	initial
		n1OO = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n1OO <= 1'b0;
		else   n1OO <= wire_nlOiO_o;
	initial
		nlO0i = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nlO0i <= 1'b1;
		else   nlO0i <= wire_n0lOl_dataout;
	initial
		nlO0l = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nlO0l <= 1'b1;
		else   nlO0l <= wire_niOll_dataout;
	initial
		nlO0O = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nlO0O <= 1'b1;
		else   nlO0O <= wire_niOOi_dataout;
	initial
		nlO1i = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nlO1i <= 1'b1;
		else   nlO1i <= wire_n0lll_dataout;
	initial
		nlO1l = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nlO1l <= 1'b1;
		else   nlO1l <= wire_n0llO_dataout;
	initial
		nlO1O = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nlO1O <= 1'b1;
		else   nlO1O <= wire_n0lOi_dataout;
	initial
		nlOii = 0;
	always @ ( posedge tx_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nlOii <= 1'b0;
		else   nlOii <= wire_n11l_o;
	assign		wire_n0iiO_dataout = ((nlOO0i | (nlOOll | (nlOOOi | (nlOOOl | wire_n1i_dataout)))) === 1'b1) ? (~ n10ii) : n10ii;
	assign		wire_n0liO_dataout = (nlOO1O === 1'b1) ? (~ wire_ni0i_dataout) : wire_ni0i_dataout;
	assign		wire_n0ll_dataout = (INDV === 1'b1) ? tx_data_tc[0:0] : tx_data_ts[0:0];
	assign		wire_n0lli_dataout = (nlOO1O === 1'b1) ? (~ wire_ni01l_dataout) : wire_ni01l_dataout;
	assign		wire_n0lll_dataout = (nlOO1O === 1'b1) ? (~ wire_ni1ll_dataout) : wire_ni1ll_dataout;
	assign		wire_n0llO_dataout = (nlOO1O === 1'b1) ? (~ wire_ni1li_dataout) : wire_ni1li_dataout;
	assign		wire_n0lO_dataout = (INDV === 1'b1) ? tx_data_tc[1:1] : tx_data_ts[1:1];
	assign		wire_n0lOi_dataout = (nlOO1O === 1'b1) ? (~ nlOOiO) : nlOOiO;
	assign		wire_n0lOl_dataout = (nlOO1O === 1'b1) ? (~ nlOO0O) : nlOO0O;
	assign		wire_n0Oi_dataout = (INDV === 1'b1) ? tx_data_tc[2:2] : tx_data_ts[2:2];
	assign		wire_n0Ol_dataout = (INDV === 1'b1) ? tx_data_tc[3:3] : tx_data_ts[3:3];
	assign		wire_n0OO_dataout = (INDV === 1'b1) ? tx_data_tc[4:4] : tx_data_ts[4:4];
	and(wire_n1i_dataout, wire_n1l_dataout, ~{((n10l & 
		(n1ii & (((~ tx_ctl_tc) & ((GE_XAUI_SEL & ((n1lil & n1l0l) & w_n1ill73w)) & w_n1iiO78w)) & w_n1iii83w))) & w_n1i0l89w)});
	and(wire_n1l_dataout, wire_nlOO_dataout, ~{((~ n10l) & ((n1ii & ((~ tx_ctl_tc) & ((GE_XAUI_SEL & (n1lil & n1l0l)) & w_n1iOO62w))) & w_n1iOi68w))});
	assign		wire_ni01l_dataout = (nlOOOO === 1'b1) ? (~ wire_ni0l_dataout) : wire_ni0l_dataout;
	and(wire_ni0i_dataout, wire_nilO_dataout, ~{n1i1l});
	and(wire_ni0l_dataout, wire_niOi_dataout, ~{n1i1l});
	and(wire_ni0O_dataout, wire_niOl_dataout, ~{n1i1l});
	assign		wire_ni1i_dataout = (INDV === 1'b1) ? tx_data_tc[5:5] : tx_data_ts[5:5];
	assign		wire_ni1l_dataout = (INDV === 1'b1) ? tx_data_tc[6:6] : tx_data_ts[6:6];
	assign		wire_ni1li_dataout = (nlOOOi === 1'b1) ? (~ wire_niii_dataout) : wire_niii_dataout;
	assign		wire_ni1ll_dataout = ((nlOOOl | (wire_niil_dataout & (wire_niii_dataout & ((~ wire_ni0O_dataout) & ((~ wire_ni0i_dataout) & (~ wire_ni0l_dataout)))))) === 1'b1) ? (~ wire_ni0O_dataout) : wire_ni0O_dataout;
	assign		wire_ni1O_dataout = (INDV === 1'b1) ? tx_data_tc[7:7] : tx_data_ts[7:7];
	and(wire_niii_dataout, wire_niOO_dataout, ~{n1i1l});
	or(wire_niil_dataout, wire_nl1i_dataout, n1i1l);
	and(wire_niiO_dataout, wire_nl1l_dataout, ~{n1i1l});
	or(wire_nili_dataout, wire_nl1O_dataout, n1i1l);
	and(wire_nill_dataout, wire_nl0i_dataout, ~{n1i1l});
	or(wire_nilO_dataout, wire_n0ll_dataout, n10lO);
	assign		wire_nilOO_dataout = ((n111O | (n11OO & wire_nill_dataout)) === 1'b1) ? (~ wire_n0iiO_dataout) : wire_n0iiO_dataout;
	and(wire_niO0i_dataout, (~ n11OO), ~{wire_nill_dataout});
	or(wire_niO1O_dataout, wire_niO0i_dataout, n11ii);
	and(wire_niOi_dataout, wire_n0lO_dataout, ~{n10lO});
	assign		wire_niOil_dataout = (n111O === 1'b1) ? (~ wire_nili_dataout) : wire_nili_dataout;
	or(wire_niOl_dataout, wire_n0Oi_dataout, n10lO);
	and(wire_niOli_dataout, wire_niiO_dataout, ~{n11ii});
	assign		wire_niOll_dataout = (n11il === 1'b1) ? (~ wire_niOli_dataout) : wire_niOli_dataout;
	assign		wire_niOlO_dataout = (n11il === 1'b1) ? (~ wire_niOil_dataout) : wire_niOil_dataout;
	and(wire_niOO_dataout, wire_n0Ol_dataout, ~{n10lO});
	assign		wire_niOOi_dataout = (n11il === 1'b1) ? (~ wire_nill_dataout) : wire_nill_dataout;
	assign		wire_niOOl_dataout = (n11il === 1'b1) ? (~ wire_niO1O_dataout) : wire_niO1O_dataout;
	or(wire_nl0i_dataout, wire_ni1O_dataout, n10lO);
	and(wire_nl1i_dataout, wire_n0OO_dataout, ~{n10lO});
	and(wire_nl1l_dataout, wire_ni1i_dataout, ~{n10lO});
	or(wire_nl1O_dataout, wire_ni1l_dataout, n10lO);
	assign		wire_nlOO_dataout = (INDV === 1'b1) ? tx_ctl_tc : tx_ctl_ts;
	oper_decoder   n10i
	( 
	.i({ENDEC, prbs_en}),
	.o(wire_n10i_o));
	defparam
		n10i.width_i = 2,
		n10i.width_o = 4;
	oper_selector   n11i
	( 
	.data({tx_data_pg[8:8], nlO0O, tx_ctl_tc}),
	.o(wire_n11i_o),
	.sel({n101l, wire_n10i_o[2:2], wire_n10i_o[0:0]}));
	defparam
		n11i.width_data = 3,
		n11i.width_sel = 3;
	oper_selector   n11l
	( 
	.data({tx_data_pg[9:9], n1Oi, tx_data_9_tc}),
	.o(wire_n11l_o),
	.sel({n101l, wire_n10i_o[2:2], wire_n10i_o[0:0]}));
	defparam
		n11l.width_data = 3,
		n11l.width_sel = 3;
	oper_selector   nlOil
	( 
	.data({tx_data_pg[0:0], n1il, tx_data_tc[0:0]}),
	.o(wire_nlOil_o),
	.sel({n101l, wire_n10i_o[2:2], wire_n10i_o[0:0]}));
	defparam
		nlOil.width_data = 3,
		nlOil.width_sel = 3;
	oper_selector   nlOiO
	( 
	.data({tx_data_pg[1:1], n1iO, tx_data_tc[1:1]}),
	.o(wire_nlOiO_o),
	.sel({n101l, wire_n10i_o[2:2], wire_n10i_o[0:0]}));
	defparam
		nlOiO.width_data = 3,
		nlOiO.width_sel = 3;
	oper_selector   nlOli
	( 
	.data({tx_data_pg[2:2], nlO1i, tx_data_tc[2:2]}),
	.o(wire_nlOli_o),
	.sel({n101l, wire_n10i_o[2:2], wire_n10i_o[0:0]}));
	defparam
		nlOli.width_data = 3,
		nlOli.width_sel = 3;
	oper_selector   nlOll
	( 
	.data({tx_data_pg[3:3], nlO1l, tx_data_tc[3:3]}),
	.o(wire_nlOll_o),
	.sel({n101l, wire_n10i_o[2:2], wire_n10i_o[0:0]}));
	defparam
		nlOll.width_data = 3,
		nlOll.width_sel = 3;
	oper_selector   nlOlO
	( 
	.data({tx_data_pg[4:4], nlO1O, tx_data_tc[4:4]}),
	.o(wire_nlOlO_o),
	.sel({n101l, wire_n10i_o[2:2], wire_n10i_o[0:0]}));
	defparam
		nlOlO.width_data = 3,
		nlOlO.width_sel = 3;
	oper_selector   nlOOi
	( 
	.data({tx_data_pg[5:5], nlO0i, tx_data_tc[5:5]}),
	.o(wire_nlOOi_o),
	.sel({n101l, wire_n10i_o[2:2], wire_n10i_o[0:0]}));
	defparam
		nlOOi.width_data = 3,
		nlOOi.width_sel = 3;
	oper_selector   nlOOl
	( 
	.data({tx_data_pg[6:6], nlO0l, tx_data_tc[6:6]}),
	.o(wire_nlOOl_o),
	.sel({n101l, wire_n10i_o[2:2], wire_n10i_o[0:0]}));
	defparam
		nlOOl.width_data = 3,
		nlOOl.width_sel = 3;
	oper_selector   nlOOO
	( 
	.data({tx_data_pg[7:7], n1li, tx_data_tc[7:7]}),
	.o(wire_nlOOO_o),
	.sel({n101l, wire_n10i_o[2:2], wire_n10i_o[0:0]}));
	defparam
		nlOOO.width_data = 3,
		nlOOO.width_sel = 3;
	assign
		n101i = (wire_niiO_dataout & wire_nili_dataout),
		n101l = ((wire_n10i_o[3:3] | wire_n10i_o[1:1]) | (~ w_n101O147w)),
		n10ii = ((n10l | ((~ n10O) & ((tx_data_9_tc & IB_FORCE_DISPARITY) & w_n10li123w))) | (~ w_n10il129w)),
		n10lO = ((~ n10l) & (n1ii & ((~ tx_ctl_tc) & ((GE_XAUI_SEL & ((n1lil & n1l0l) & w_n10OO101w)) & w_n10Oi106w)))),
		n110O = ((~ wire_niiO_dataout) & (~ wire_nili_dataout)),
		n111i = (wire_ni0i_dataout & wire_ni0l_dataout),
		n111l = ((~ wire_ni0i_dataout) & (~ wire_ni0l_dataout)),
		n111O = ((n110O & (~ wire_nill_dataout)) & w_n110i291w),
		n11ii = (wire_nill_dataout & (wire_nili_dataout & (wire_niiO_dataout & ((((((((((wire_ni0i_dataout & (~ wire_ni0l_dataout)) & (~ wire_ni0O_dataout)) & (~ wire_niii_dataout)) | ((~ wire_niii_dataout) & ((~ wire_ni0O_dataout) & ((~ wire_ni0i_dataout) & wire_ni0l_dataout)))) | ((~ wire_niii_dataout) & (wire_ni0O_dataout & n111l))) | (wire_niii_dataout & ((~ wire_ni0O_dataout) & n111l))) & ((~ wire_niii_dataout) & wire_niil_dataout)) & (~ wire_n0iiO_dataout)) | (wire_n0iiO_dataout & ((((((~ wire_niii_dataout) & (wire_ni0O_dataout & n111i)) | (wire_niii_dataout & ((~ wire_ni0O_dataout) & n111i))) | (wire_niii_dataout & (wire_ni0O_dataout & (wire_ni0i_dataout & (~ wire_ni0l_dataout))))) | (wire_niii_dataout & (wire_ni0O_dataout & ((~ wire_ni0i_dataout) & wire_ni0l_dataout)))) & (wire_niii_dataout & (~ wire_niil_dataout))))) | (wire_nill_dataout & (wire_nili_dataout & (wire_niiO_dataout & wire_n1i_dataout))))))),
		n11il = (((n101i | ((~ wire_n0iiO_dataout) & (((~ n11OO) & wire_n1i_dataout) & w_n11Oi269w))) | (~ w_n11ll275w)) ^ ((n11OO & (~ wire_n0iiO_dataout)) & w_n11iO281w)),
		n11OO = (n101i | n110O),
		n1i1l = (n10l & (n1ii & ((~ tx_ctl_tc) & (GE_XAUI_SEL & ((n1lil & n1l0l) & w_n1i1O93w))))),
		n1l0l = (((((((((tx_ctl_tc | tx_data_tc[7:7]) | (~ tx_data_tc[6:6])) | tx_data_tc[5:5]) | tx_data_tc[4:4]) | tx_data_tc[3:3]) | tx_data_tc[2:2]) | (~ tx_data_tc[1:1])) | tx_data_tc[0:0]) | (~ w_n1l0O39w)),
		n1l1l = ((((((((((~ tx_ctl_tc) | (~ tx_data_tc[7:7])) | tx_data_tc[6:6]) | (~ tx_data_tc[5:5])) | (~ tx_data_tc[4:4])) | (~ tx_data_tc[3:3])) | (~ tx_data_tc[2:2])) | tx_data_tc[1:1]) | tx_data_tc[0:0]) | (~ w_n1l1O54w)),
		n1lil = (((((((((tx_ctl_tc | (~ tx_data_tc[7:7])) | tx_data_tc[6:6]) | (~ tx_data_tc[5:5])) | (~ tx_data_tc[4:4])) | tx_data_tc[3:3]) | (~ tx_data_tc[2:2])) | tx_data_tc[1:1]) | (~ tx_data_tc[0:0])) | (~ w_n1lli24w)),
		n1liO = tx_clk,
		nlOlOl = (wire_ni0i_dataout & wire_ni0l_dataout),
		nlOlOO = ((~ wire_ni0i_dataout) & (~ wire_ni0l_dataout)),
		nlOO0i = (wire_niil_dataout & (nlOOii | (wire_niii_dataout & nlOOlO))),
		nlOO0l = (wire_n1i_dataout & nlOOil),
		nlOO0O = ((nlOOil & ((~ wire_niil_dataout) | wire_n1i_dataout)) | (wire_niil_dataout & (((~ nlOOii) & (~ nlOOil)) & nlOOli))),
		nlOO1i = ((~ wire_ni0i_dataout) & wire_ni0l_dataout),
		nlOO1l = (wire_ni0i_dataout & (~ wire_ni0l_dataout)),
		nlOO1O = (((((((~ wire_niii_dataout) & (wire_ni0O_dataout & (wire_ni0i_dataout & wire_ni0l_dataout))) | (wire_niil_dataout & nlOOOl)) | (wire_niil_dataout & nlOOOi)) | (wire_niil_dataout & nlOOii)) | nlOO0l) ^ ((~ n10ii) & (nlOO0l | (nlOO0i | (nlOOOO | ((~ wire_niil_dataout) & (nlOOlO | ((~ wire_niii_dataout) & nlOOii)))))))),
		nlOOii = (((((~ wire_niii_dataout) & (wire_ni0O_dataout & nlOlOl)) | (wire_niii_dataout & ((~ wire_ni0O_dataout) & nlOlOl))) | (wire_niii_dataout & (wire_ni0O_dataout & (wire_ni0i_dataout & (~ wire_ni0l_dataout))))) | (wire_niii_dataout & (wire_ni0O_dataout & ((~ wire_ni0i_dataout) & wire_ni0l_dataout)))),
		nlOOil = (((((((~ wire_niii_dataout) & ((~ wire_ni0O_dataout) & (wire_ni0i_dataout & wire_ni0l_dataout))) | ((~ wire_niii_dataout) & (wire_ni0O_dataout & nlOO1l))) | ((~ wire_niii_dataout) & (wire_ni0O_dataout & nlOO1i))) | (wire_niii_dataout & ((~ wire_ni0O_dataout) & nlOO1l))) | (wire_niii_dataout & ((~ wire_ni0O_dataout) & nlOO1i))) | (wire_niii_dataout & (wire_ni0O_dataout & ((~ wire_ni0i_dataout) & (~ wire_ni0l_dataout))))),
		nlOOiO = (nlOOll | (wire_niil_dataout & nlOOli)),
		nlOOli = ((~ wire_niii_dataout) | (wire_ni0O_dataout | (wire_ni0i_dataout | wire_ni0l_dataout))),
		nlOOll = ((~ wire_niil_dataout) & nlOOlO),
		nlOOlO = (((((~ wire_niii_dataout) & ((~ wire_ni0O_dataout) & (wire_ni0i_dataout & (~ wire_ni0l_dataout)))) | ((~ wire_niii_dataout) & ((~ wire_ni0O_dataout) & ((~ wire_ni0i_dataout) & wire_ni0l_dataout)))) | ((~ wire_niii_dataout) & (wire_ni0O_dataout & nlOlOO))) | (wire_niii_dataout & ((~ wire_ni0O_dataout) & nlOlOO))),
		nlOOOi = (wire_niii_dataout & (wire_ni0O_dataout & (wire_ni0i_dataout & wire_ni0l_dataout))),
		nlOOOl = ((~ wire_niii_dataout) & ((~ wire_ni0O_dataout) & ((~ wire_ni0i_dataout) & (~ wire_ni0l_dataout)))),
		nlOOOO = (nlOOOi | nlOOOl),
		PUDR = {wire_n11l_o, wire_n11i_o, wire_nlOOO_o, wire_nlOOl_o, wire_nlOOi_o, wire_nlOlO_o, wire_nlOll_o, wire_nlOli_o, wire_nlOiO_o, wire_nlOil_o},
		TXLP10B = {nlOii, n0ii, n00O, n00l, n00i, n01O, n01l, n01i, n1OO, n1Ol},
		w_n100l136w = n100l45,
		w_n101O147w = n101O48,
		w_n10il129w = n10il42,
		w_n10li123w = n10li39,
		w_n10Oi106w = n10Oi36,
		w_n10OO101w = n10OO33,
		w_n110i291w = n110i60,
		w_n11iO281w = n11iO57,
		w_n11ll275w = n11ll54,
		w_n11Oi269w = n11Oi51,
		w_n1i0l89w = n1i0l27,
		w_n1i1O93w = n1i1O30,
		w_n1iii83w = n1iii24,
		w_n1iiO78w = n1iiO21,
		w_n1ill73w = n1ill18,
		w_n1iOi68w = n1iOi15,
		w_n1iOO62w = n1iOO12,
		w_n1l0O39w = n1l0O6,
		w_n1l1O54w = n1l1O9,
		w_n1lli24w = n1lli3;
endmodule //altgxb_hssi_tx_enc_rtl
//synopsys translate_on
//VALID FILE
///////////////////////////////////////////////////////////////////////////////
//
//                           ALTGXB_8b10b_ENCODER
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

  module altgxb_8b10b_encoder 
    (
     clk, 
     reset,
     xgmctrl,
     kin,
     xgmdatain,
     datain,
     forcedisparity,
     dataout,
     parafbkdataout
     );
   
   parameter 	transmit_protocol = "NONE";
   parameter 	use_8b_10b_mode = "ON";
   parameter 	force_disparity_mode = "OFF";
   
   input 	clk; 
   input 	reset;   // asynchronously resets the core
   input 	kin;     // command byte indicator 
   input [7:0] 	datain;   // data or command word
   input [7:0] 	xgmdatain;// XGM State Machine Data Input
   input 	xgmctrl;  // XGM Control Enable
   input 	forcedisparity;
   
   output [9:0] dataout; // 10-bit encoded output
   output [9:0] parafbkdataout; // Parallel Feedback To Top Level
   
   // CORE MODULE INPUTs
   wire 	tx_clk; 
   wire 	soft_reset;
   wire 	INDV;
   wire 	ENDEC;
   wire 	GE_XAUI_SEL;
   wire 	IB_FORCE_DISPARITY;
   wire 	prbs_en;
   wire 	tx_ctl_ts;
   wire 	tx_ctl_tc;
   wire [7:0] 	tx_data_ts;
   wire [7:0] 	tx_data_tc;
   wire 	tx_data_9_tc;
   wire [9:0] 	tx_data_pg;

   // CORE MODULE OUTPUTs
   wire [9:0] 	TXLP10B;
   wire [9:0] 	PUDR;

   // ASSIGN INPUTS
   assign  tx_clk = clk;
   assign  soft_reset = reset;
   assign INDV = (transmit_protocol != "XAUI") ? 1'b1 : 1'b0;
   assign ENDEC = (use_8b_10b_mode == "ON") ? 1'b1 : 1'b0;
   assign GE_XAUI_SEL = (transmit_protocol == "GIGE") ? 1'b1 : 1'b0;
   assign IB_FORCE_DISPARITY = (force_disparity_mode == "ON") ? 1'b1 : 1'b0;
   assign prbs_en = 1'b0;
   assign tx_ctl_ts = xgmctrl;
   assign tx_ctl_tc = kin;
   assign tx_data_ts = xgmdatain;
   assign tx_data_tc = datain;
   assign tx_data_9_tc = forcedisparity;
   assign tx_data_pg = 'b0;
   
   // ASSIGN OUTPUTS
   assign dataout = PUDR;
   assign parafbkdataout = TXLP10B;

   // Instantiate core module
   altgxb_hssi_tx_enc_rtl m_enc_core (
				.tx_clk(tx_clk), 
				.soft_reset(soft_reset),
				.INDV(INDV), 
				.ENDEC(ENDEC), 
				.GE_XAUI_SEL(GE_XAUI_SEL),
				.IB_FORCE_DISPARITY(IB_FORCE_DISPARITY),
				.prbs_en(prbs_en),
				.tx_ctl_ts(tx_ctl_ts),
				.tx_ctl_tc(tx_ctl_tc),
				.tx_data_ts(tx_data_ts),
				.tx_data_tc(tx_data_tc),
				.tx_data_9_tc(tx_data_9_tc),
				.tx_data_pg(tx_data_pg), 
				.PUDR(PUDR),
				.TXLP10B(TXLP10B)
    );
   
endmodule

///////////////////////////////////////////////////////////////////////////////
//
//                           ALTGXB_HSSI_TRANSMITTER
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ps/1 ps

module altgxb_hssi_transmitter
   (
    pllclk,
    fastpllclk,
    coreclk,
    softreset,
    serialdatain,
    xgmctrl,
    srlpbk,
    analogreset,
    datain,
    ctrlenable,
    forcedisparity,
    xgmdatain,
    vodctrl,
    preemphasisctrl,
    devclrn,
    devpor,
    dataout,
    xgmctrlenable,
    rdenablesync,
    xgmdataout,
    parallelfdbkdata,
    pre8b10bdata
    );

parameter channel_num = 1; 
parameter channel_width = 8; // (The width of the datain port)>;	
parameter serialization_factor = 8; 
parameter use_double_data_mode = "OFF";
parameter use_8b_10b_mode = "OFF";
parameter use_fifo_mode = "OFF";
parameter use_reverse_parallel_feedback = "OFF";
parameter force_disparity_mode = "OFF";
parameter transmit_protocol = "NONE"; // <gige, xaui, none>;
parameter use_vod_ctrl_signal = "OFF";
parameter use_preemphasis_ctrl_signal = "OFF";
parameter use_self_test_mode = "OFF";
parameter self_test_mode = 0;
parameter vod_ctrl_setting = 4;  
parameter preemphasis_ctrl_setting = 5;
parameter termination = 0; // new in 3.0


input [19 : 0] datain; // (<input bus>),
input pllclk; // (<pll clock source (ref_clk)>), 
input fastpllclk; // (<pll clock source powering SERDES>),
input coreclk; // (<core clock source>), 
input softreset; // (<unknown reset source>),
input [1 : 0] ctrlenable; // (<data sent is control code>),
input [1 : 0] forcedisparity; // (<force disparity for 8B / 10B>),
input serialdatain; // (<data to be sent directly to data output>),
input [7 : 0] xgmdatain; // (<data input from the XGM SM system>),
input xgmctrl; // (<control input from the XGM SM system>),
input srlpbk; 
input devpor;
input devclrn;
input analogreset;
input [2 : 0] vodctrl;
input [2 : 0] preemphasisctrl;
   
output dataout; // (<data output of HSSI channel>),
output [7 : 0] xgmdataout; // (<data output before 8B/10B to XGM SM>),
output xgmctrlenable; // (<ctrlenable output before 8B/10B to XGM SM>),
output rdenablesync; 
output [9 : 0] parallelfdbkdata; // (<parallel data output>),
output [9 : 0] pre8b10bdata; // (<pararrel non-encoded data output>)
   

buf (datain_in0, datain[0]);
buf (datain_in1, datain[1]);
buf (datain_in2, datain[2]);
buf (datain_in3, datain[3]);
buf (datain_in4, datain[4]);
buf (datain_in5, datain[5]);
buf (datain_in6, datain[6]);
buf (datain_in7, datain[7]);
buf (datain_in8, datain[8]);
buf (datain_in9, datain[9]);
buf (datain_in10, datain[10]);
buf (datain_in11, datain[11]);
buf (datain_in12, datain[12]);
buf (datain_in13, datain[13]);
buf (datain_in14, datain[14]);
buf (datain_in15, datain[15]);
buf (datain_in16, datain[16]);
buf (datain_in17, datain[17]);
buf (datain_in18, datain[18]);
buf (datain_in19, datain[19]);

buf (pllclk_in, pllclk);
buf (fastpllclk_in, fastpllclk);
buf (coreclk_in, coreclk);
buf (softreset_in, softreset);
buf (analogreset_in, analogreset);
buf (vodctrl_in0, vodctrl[0]);
buf (vodctrl_in1, vodctrl[1]);
buf (vodctrl_in2, vodctrl[2]);
buf (preemphasisctrl_in0, preemphasisctrl[0]);
buf (preemphasisctrl_in1, preemphasisctrl[1]);
buf (preemphasisctrl_in2, preemphasisctrl[2]);
buf (ctrlenable_in0, ctrlenable[0]);
buf (ctrlenable_in1, ctrlenable[1]);
buf (forcedisparity_in0, forcedisparity[0]);
buf (forcedisparity_in1, forcedisparity[1]);
buf (serialdatain_in, serialdatain);

buf (xgmdatain_in0, xgmdatain[0]);
buf (xgmdatain_in1, xgmdatain[1]);
buf (xgmdatain_in2, xgmdatain[2]);
buf (xgmdatain_in3, xgmdatain[3]);
buf (xgmdatain_in4, xgmdatain[4]);
buf (xgmdatain_in5, xgmdatain[5]);
buf (xgmdatain_in6, xgmdatain[6]);
buf (xgmdatain_in7, xgmdatain[7]);

buf (xgmctrl_in, xgmctrl);
buf (srlpbk_in, srlpbk);
   
//constant signals
wire vcc, gnd;
wire [9 : 0] idle_bus;

//lower lever softreset
wire reset_int;

// internal bus for XGM data
wire [7 : 0] xgmdatain_in;
wire [19 : 0] datain_in;

assign xgmdatain_in = {
								xgmdatain_in7, xgmdatain_in6,
								xgmdatain_in5, xgmdatain_in4,
							  	xgmdatain_in3, xgmdatain_in2,
							  	xgmdatain_in1, xgmdatain_in0
							 };
assign datain_in = {
								datain_in19, datain_in18,
								datain_in17, datain_in16,
								datain_in15, datain_in14,
							  	datain_in13, datain_in12,
								datain_in11, datain_in10,
								datain_in9, datain_in8,
								datain_in7, datain_in6,
								datain_in5, datain_in4,
							  	datain_in3, datain_in2,
							  	datain_in1, datain_in0
							 };

assign reset_int = softreset_in;
assign vcc = 1'b1;
assign gnd = 1'b0;
assign idle_bus = 10'b0000000000;

// tx_core input/output signals
wire [19:0] core_datain;
wire core_writeclk;
wire core_readclk;
wire [1:0] core_ctrlena;
wire [1:0] core_forcedisp;
   
wire [9:0] core_dataout;
wire core_forcedispout;
wire core_ctrlenaout;
wire core_rdenasync;
wire core_xgmctrlena;
wire [7:0] core_xgmdataout;
wire [9:0] core_pre8b10bdataout;

// serdes input/output signals
wire [9:0] serdes_datain;
wire serdes_clk;
wire serdes_clk1;
wire serdes_serialdatain;
wire serdes_srlpbk;

wire serdes_dataout;

// encoder input/output signals
wire encoder_clk; 
wire encoder_kin; 
wire [7:0] encoder_datain;
wire [7:0] encoder_xgmdatain;
wire encoder_xgmctrl; 
      
wire [9:0] encoder_dataout;
wire [9:0] encoder_para;

// internal signal for parallelfdbkdata
wire [9 : 0] parallelfdbkdata_tmp; 

// TX CLOCK MUX
wire      txclk;
wire      pllclk_int;
      
specify

	$setuphold(posedge coreclk, datain[0], 0, 0);
	$setuphold(posedge coreclk, datain[1], 0, 0);
	$setuphold(posedge coreclk, datain[2], 0, 0);
	$setuphold(posedge coreclk, datain[3], 0, 0);
	$setuphold(posedge coreclk, datain[4], 0, 0);
	$setuphold(posedge coreclk, datain[5], 0, 0);
	$setuphold(posedge coreclk, datain[6], 0, 0);
	$setuphold(posedge coreclk, datain[7], 0, 0);
	$setuphold(posedge coreclk, datain[8], 0, 0);
	$setuphold(posedge coreclk, datain[9], 0, 0);
	$setuphold(posedge coreclk, datain[10], 0, 0);
	$setuphold(posedge coreclk, datain[11], 0, 0);
	$setuphold(posedge coreclk, datain[12], 0, 0);
	$setuphold(posedge coreclk, datain[13], 0, 0);
	$setuphold(posedge coreclk, datain[14], 0, 0);
	$setuphold(posedge coreclk, datain[15], 0, 0);
	$setuphold(posedge coreclk, datain[16], 0, 0);
	$setuphold(posedge coreclk, datain[17], 0, 0);
	$setuphold(posedge coreclk, datain[18], 0, 0);
	$setuphold(posedge coreclk, datain[19], 0, 0);

	$setuphold(posedge coreclk, ctrlenable[0], 0, 0);
	$setuphold(posedge coreclk, ctrlenable[1], 0, 0);

	$setuphold(posedge coreclk, forcedisparity[0], 0, 0);
	$setuphold(posedge coreclk, forcedisparity[1], 0, 0);
endspecify
   
// generate internal inut signals

// TX CLOCK MUX
altgxb_hssi_divide_by_two txclk_block	
   (
    .reset(1'b0),
    .clkin(pllclk_in), 
    .clkout(pllclk_int)
    );
   defparam  txclk_block.divide = use_double_data_mode;

assign txclk = (use_reverse_parallel_feedback == "ON") ?  pllclk_int : coreclk_in;
   
// tx_core inputs
assign core_datain = datain_in;
assign core_writeclk = txclk;
assign core_readclk = pllclk_in;
assign core_ctrlena = {ctrlenable_in1, ctrlenable_in0};
assign core_forcedisp = {forcedisparity_in1, forcedisparity_in0};
	 
// encoder inputs
assign encoder_clk = pllclk_in; 
assign encoder_kin = core_ctrlenaout;
assign encoder_datain = core_dataout[7:0];
assign encoder_xgmdatain = xgmdatain_in;
assign encoder_xgmctrl = xgmctrl_in; 

// serdes inputs
assign serdes_datain = (use_8b_10b_mode == "ON") ? encoder_dataout : core_dataout;
assign serdes_clk = fastpllclk_in;
assign serdes_clk1 = pllclk_in;
assign serdes_serialdatain = serialdatain_in;
assign serdes_srlpbk = srlpbk_in;

// parallelfdbkdata generation
assign parallelfdbkdata_tmp = (use_8b_10b_mode == "ON") ? encoder_dataout : core_dataout; 

// sub modules

altgxb_tx_core s_tx_core	
   (
    .reset(reset_int),
    .datain(core_datain),
    .writeclk(core_writeclk),
    .readclk(core_readclk),
    .ctrlena(core_ctrlena),
    .forcedisp(core_forcedisp),
    .dataout(core_dataout),
    .forcedispout(core_forcedispout),
    .ctrlenaout(core_ctrlenaout),
    .rdenasync(core_rdenasync),
    .xgmctrlena(core_xgmctrlena),
    .xgmdataout(core_xgmdataout),
    .pre8b10bdataout(core_pre8b10bdataout)
    );
   defparam  s_tx_core.use_double_data_mode = use_double_data_mode;
   defparam  s_tx_core.use_fifo_mode = use_fifo_mode;
   defparam  s_tx_core.channel_width = channel_width;
   defparam  s_tx_core.transmit_protocol = transmit_protocol;   
   
altgxb_8b10b_encoder s_encoder	
   (
    .clk(encoder_clk), 
    .reset(reset_int), 
    .kin(encoder_kin),
    .datain(encoder_datain),
    .xgmdatain(encoder_xgmdatain),
    .xgmctrl(encoder_xgmctrl),
    .forcedisparity(core_forcedispout),
    .dataout(encoder_dataout),
    .parafbkdataout(encoder_para)
    );
   defparam  s_encoder.transmit_protocol = transmit_protocol;
   defparam  s_encoder.use_8b_10b_mode = use_8b_10b_mode;
   defparam  s_encoder.force_disparity_mode = force_disparity_mode;

altgxb_hssi_tx_serdes s_tx_serdes	
  (
   .clk(serdes_clk), 
   .clk1(serdes_clk1), 
   .datain(serdes_datain),
   .serialdatain(serdes_serialdatain),
   .srlpbk(serdes_srlpbk),
   .areset(analogreset_in),
   .dataout(serdes_dataout)
   );
   defparam  s_tx_serdes.channel_width = serialization_factor;

// gererate output signals
and (dataout, 1'b1, serdes_dataout); 
and (xgmctrlenable, 1'b1, core_xgmctrlena);
and (rdenablesync, 1'b1, core_rdenasync); 

buf (xgmdataout[0], core_xgmdataout[0]);
buf (xgmdataout[1], core_xgmdataout[1]);
buf (xgmdataout[2], core_xgmdataout[2]);
buf (xgmdataout[3], core_xgmdataout[3]);
buf (xgmdataout[4], core_xgmdataout[4]);
buf (xgmdataout[5], core_xgmdataout[5]);
buf (xgmdataout[6], core_xgmdataout[6]);
buf (xgmdataout[7], core_xgmdataout[7]);

buf (pre8b10bdata[0], core_pre8b10bdataout[0]);
buf (pre8b10bdata[1], core_pre8b10bdataout[1]);
buf (pre8b10bdata[2], core_pre8b10bdataout[2]);
buf (pre8b10bdata[3], core_pre8b10bdataout[3]);
buf (pre8b10bdata[4], core_pre8b10bdataout[4]);
buf (pre8b10bdata[5], core_pre8b10bdataout[5]);
buf (pre8b10bdata[6], core_pre8b10bdataout[6]);
buf (pre8b10bdata[7], core_pre8b10bdataout[7]);
buf (pre8b10bdata[8], core_pre8b10bdataout[8]);
buf (pre8b10bdata[9], core_pre8b10bdataout[9]);

buf (parallelfdbkdata[0], parallelfdbkdata_tmp[0]); 
buf (parallelfdbkdata[1], parallelfdbkdata_tmp[1]); 
buf (parallelfdbkdata[2], parallelfdbkdata_tmp[2]); 
buf (parallelfdbkdata[3], parallelfdbkdata_tmp[3]); 
buf (parallelfdbkdata[4], parallelfdbkdata_tmp[4]); 
buf (parallelfdbkdata[5], parallelfdbkdata_tmp[5]); 
buf (parallelfdbkdata[6], parallelfdbkdata_tmp[6]); 
buf (parallelfdbkdata[7], parallelfdbkdata_tmp[7]); 
buf (parallelfdbkdata[8], parallelfdbkdata_tmp[8]); 
buf (parallelfdbkdata[9], parallelfdbkdata_tmp[9]); 

endmodule // altgxb_hssi_transmitter

//IP Functional Simulation Model
//VERSION_BEGIN 4.1 cbx_mgl 2004:06:17:17:30:06:SJ cbx_simgen 2004:06:22:10:53:08:SJ  VERSION_END


// Legal Notice: � 2003 Altera Corporation. All rights reserved.
// You may only use these  simulation  model  output files for simulation
// purposes and expressly not for synthesis or any other purposes (in which
// event  Altera disclaims all warranties of any kind). Your use of  Altera
// Corporation's design tools, logic functions and other software and tools,
// and its AMPP partner logic functions, and any output files any of the
// foregoing (including device programming or simulation files), and any
// associated documentation or information  are expressly subject to the
// terms and conditions of the  Altera Program License Subscription Agreement
// or other applicable license agreement, including, without limitation, that
// your use is for the sole purpose of programming logic devices manufactured
// by Altera and sold by Altera or its authorized distributors.  Please refer
// to the applicable agreement for further details.


//synopsys translate_off

//synthesis_resources = lut 97 mux21 43 
`timescale 1 ps / 1 ps
module  altgxb_8b10b_decoder
	( 
	clk,
	datain,
	datainvalid,
	dataout,
	decdatavalid,
	disperr,
	disperrin,
	errdetect,
	errdetectin,
	kout,
	patterndetect,
	patterndetectin,
	rderr,
	reset,
	syncstatus,
	syncstatusin,
	tenBdata,
	valid,
	xgmctrldet,
	xgmdataout,
	xgmdatavalid,
	xgmrunningdisp) /* synthesis synthesis_clearbox=1 */;
	input   clk;
	input   [9:0]  datain;
	input   datainvalid;
	output   [7:0]  dataout;
	output   decdatavalid;
	output   disperr;
	input   disperrin;
	output   errdetect;
	input   errdetectin;
	output   kout;
	output   patterndetect;
	input   patterndetectin;
	output   rderr;
	input   reset;
	output   syncstatus;
	input   syncstatusin;
	output   [9:0]  tenBdata;
	output   valid;
	output   xgmctrldet;
	output   [7:0]  xgmdataout;
	output   xgmdatavalid;
	output   xgmrunningdisp;

	reg	n0i;
	reg	n0l;
	reg	n0l0l58;
	reg	n0l0l59;
	reg	n0l0l60;
	reg	n0lii55;
	reg	n0lii56;
	reg	n0lii57;
	reg	n0liO52;
	reg	n0liO53;
	reg	n0liO54;
	reg	n0lll49;
	reg	n0lll50;
	reg	n0lll51;
	reg	n0lOi46;
	reg	n0lOi47;
	reg	n0lOi48;
	reg	n0lOO43;
	reg	n0lOO44;
	reg	n0lOO45;
	reg	n0O;
	reg	n0O0l37;
	reg	n0O0l38;
	reg	n0O0l39;
	reg	n0O1O40;
	reg	n0O1O41;
	reg	n0O1O42;
	reg	n0OiO34;
	reg	n0OiO35;
	reg	n0OiO36;
	reg	n0Oll31;
	reg	n0Oll32;
	reg	n0Oll33;
	reg	n0OOl28;
	reg	n0OOl29;
	reg	n0OOl30;
	reg	n1i;
	reg	n1l;
	reg	n1O;
	reg	ni;
	reg	ni00l4;
	reg	ni00l5;
	reg	ni00l6;
	reg	ni01l7;
	reg	ni01l8;
	reg	ni01l9;
	reg	ni0il1;
	reg	ni0il2;
	reg	ni0il3;
	reg	ni10l19;
	reg	ni10l20;
	reg	ni10l21;
	reg	ni11i25;
	reg	ni11i26;
	reg	ni11i27;
	reg	ni11O22;
	reg	ni11O23;
	reg	ni11O24;
	reg	ni1ii16;
	reg	ni1ii17;
	reg	ni1ii18;
	reg	ni1iO13;
	reg	ni1iO14;
	reg	ni1iO15;
	reg	ni1ll10;
	reg	ni1ll11;
	reg	ni1ll12;
	reg	nii;
	reg	niiO;
	reg	nil;
	reg	nili;
	reg	nill;
	reg	nilO;
	reg	niO;
	reg	niOi;
	reg	niOl;
	reg	niOO;
	reg	nl;
	reg	nl0i;
	reg	nl0l;
	reg	nl0O;
	reg	nl1i;
	reg	nl1l;
	reg	nl1O;
	reg	nli;
	reg	nlii;
	reg	nlil;
	reg	nliO;
	reg	nll;
	reg	nlli;
	reg	nlll;
	reg	nllO;
	reg	nlO;
	reg	nlOi;
	reg	nlOl;
	reg	nlOO;
	reg	nO;
	wire	wire_niO0i_dataout;
	wire	wire_niO0l_dataout;
	wire	wire_niO0O_dataout;
	wire	wire_niOii_dataout;
	wire	wire_niOil_dataout;
	wire	wire_niOiO_dataout;
	wire	wire_niOli_dataout;
	wire	wire_niOll_dataout;
	wire	wire_niOlO_dataout;
	wire	wire_niOOi_dataout;
	wire	wire_niOOl_dataout;
	wire	wire_niOOO_dataout;
	wire	wire_nl10i_dataout;
	wire	wire_nl10l_dataout;
	wire	wire_nl10O_dataout;
	wire	wire_nl11i_dataout;
	wire	wire_nl11l_dataout;
	wire	wire_nl11O_dataout;
	wire	wire_nl1ii_dataout;
	wire	wire_nl1il_dataout;
	wire	wire_nl1li_dataout;
	wire	wire_nl1ll_dataout;
	wire	wire_nl1lO_dataout;
	wire	wire_nli0i_dataout;
	wire	wire_nli0l_dataout;
	wire	wire_nli0O_dataout;
	wire	wire_nliii_dataout;
	wire	wire_nliil_dataout;
	wire	wire_nlill_dataout;
	wire	wire_nlilO_dataout;
	wire	wire_nliOi_dataout;
	wire	wire_nliOl_dataout;
	wire	wire_nliOO_dataout;
	wire	wire_nll0i_dataout;
	wire	wire_nll0l_dataout;
	wire	wire_nll0O_dataout;
	wire	wire_nll1i_dataout;
	wire	wire_nll1l_dataout;
	wire	wire_nll1O_dataout;
	wire	wire_nllii_dataout;
	wire	wire_nlllO_dataout;
	wire	wire_nllOi_dataout;
	wire	wire_nllOl_dataout;
	wire  n0iOO;
	wire  n0l0i;
	wire  n0l1i;
	wire  n0l1l;
	wire  n0l1O;
	wire  n0O1l;
	wire  n0Oii;
	wire  n0Oil;
	wire  n0OOi;
	wire  ni00i;
	wire  ni01i;
	wire  ni0ii;
	wire  ni0li;
	wire  ni0Oi;
	wire  ni1Oi;
	wire  ni1Ol;
	wire  ni1OO;
	wire  w_n0l0l182w;
	wire  w_n0lii175w;
	wire  w_n0liO167w;
	wire  w_n0lll162w;
	wire  w_n0lOi157w;
	wire  w_n0lOO151w;
	wire  w_n0O0l138w;
	wire  w_n0O1O143w;
	wire  w_n0OiO129w;
	wire  w_n0Oll121w;
	wire  w_n0OOl115w;
	wire  w_ni00l57w;
	wire  w_ni01l63w;
	wire  w_ni0il49w;
	wire  w_ni10l97w;
	wire  w_ni11i109w;
	wire  w_ni11O102w;
	wire  w_ni1ii92w;
	wire  w_ni1iO87w;
	wire  w_ni1ll74w;

	initial
		n0i = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) n0i <= 1'b0;
		else   n0i <= disperrin;
	initial
		n0l = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) n0l <= 1'b0;
		else   n0l <= errdetectin;
	initial
		n0l0l58 = 1'b1;
	always @ ( posedge ni0Oi)
		  n0l0l58 <= n0l0l59;
	initial
		n0l0l59 = 0;
	always @ ( posedge ni0Oi)
		  n0l0l59 <= n0l0l58;
	initial
		n0l0l60 = 0;
	always @ ( posedge ni0Oi)
		  n0l0l60 <= (n0l0l59 ^ n0l0l58);
	initial
		n0lii55 = 1'b1;
	always @ ( posedge ni0Oi)
		  n0lii55 <= n0lii56;
	initial
		n0lii56 = 0;
	always @ ( posedge ni0Oi)
		  n0lii56 <= n0lii55;
	initial
		n0lii57 = 0;
	always @ ( posedge ni0Oi)
		  n0lii57 <= (n0lii56 ^ n0lii55);
	initial
		n0liO52 = 1'b1;
	always @ ( posedge ni0Oi)
		  n0liO52 <= n0liO53;
	initial
		n0liO53 = 0;
	always @ ( posedge ni0Oi)
		  n0liO53 <= n0liO52;
	initial
		n0liO54 = 0;
	always @ ( posedge ni0Oi)
		  n0liO54 <= (n0liO53 ^ n0liO52);
	initial
		n0lll49 = 1'b1;
	always @ ( posedge ni0Oi)
		  n0lll49 <= n0lll50;
	initial
		n0lll50 = 0;
	always @ ( posedge ni0Oi)
		  n0lll50 <= n0lll49;
	initial
		n0lll51 = 0;
	always @ ( posedge ni0Oi)
		  n0lll51 <= (n0lll50 ^ n0lll49);
	initial
		n0lOi46 = 1'b1;
	always @ ( posedge ni0Oi)
		  n0lOi46 <= n0lOi47;
	initial
		n0lOi47 = 0;
	always @ ( posedge ni0Oi)
		  n0lOi47 <= n0lOi46;
	initial
		n0lOi48 = 0;
	always @ ( posedge ni0Oi)
		  n0lOi48 <= (n0lOi47 ^ n0lOi46);
	initial
		n0lOO43 = 1'b1;
	always @ ( posedge ni0Oi)
		  n0lOO43 <= n0lOO44;
	initial
		n0lOO44 = 0;
	always @ ( posedge ni0Oi)
		  n0lOO44 <= n0lOO43;
	initial
		n0lOO45 = 0;
	always @ ( posedge ni0Oi)
		  n0lOO45 <= (n0lOO44 ^ n0lOO43);
	initial
		n0O = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) n0O <= 1'b0;
		else   n0O <= datainvalid;
	initial
		n0O0l37 = 1'b1;
	always @ ( posedge ni0Oi)
		  n0O0l37 <= n0O0l38;
	initial
		n0O0l38 = 0;
	always @ ( posedge ni0Oi)
		  n0O0l38 <= n0O0l37;
	initial
		n0O0l39 = 0;
	always @ ( posedge ni0Oi)
		  n0O0l39 <= (n0O0l38 ^ n0O0l37);
	initial
		n0O1O40 = 1'b1;
	always @ ( posedge ni0Oi)
		  n0O1O40 <= n0O1O41;
	initial
		n0O1O41 = 0;
	always @ ( posedge ni0Oi)
		  n0O1O41 <= n0O1O40;
	initial
		n0O1O42 = 0;
	always @ ( posedge ni0Oi)
		  n0O1O42 <= (n0O1O41 ^ n0O1O40);
	initial
		n0OiO34 = 1'b1;
	always @ ( posedge ni0Oi)
		  n0OiO34 <= n0OiO35;
	initial
		n0OiO35 = 0;
	always @ ( posedge ni0Oi)
		  n0OiO35 <= n0OiO34;
	initial
		n0OiO36 = 0;
	always @ ( posedge ni0Oi)
		  n0OiO36 <= (n0OiO35 ^ n0OiO34);
	initial
		n0Oll31 = 1'b1;
	always @ ( posedge ni0Oi)
		  n0Oll31 <= n0Oll32;
	initial
		n0Oll32 = 0;
	always @ ( posedge ni0Oi)
		  n0Oll32 <= n0Oll31;
	initial
		n0Oll33 = 0;
	always @ ( posedge ni0Oi)
		  n0Oll33 <= (n0Oll32 ^ n0Oll31);
	initial
		n0OOl28 = 1'b1;
	always @ ( posedge ni0Oi)
		  n0OOl28 <= n0OOl29;
	initial
		n0OOl29 = 0;
	always @ ( posedge ni0Oi)
		  n0OOl29 <= n0OOl28;
	initial
		n0OOl30 = 0;
	always @ ( posedge ni0Oi)
		  n0OOl30 <= (n0OOl29 ^ n0OOl28);
	initial
		n1i = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) n1i <= 1'b0;
		else   n1i <= disperrin;
	initial
		n1l = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) n1l <= 1'b0;
		else   n1l <= patterndetectin;
	initial
		n1O = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) n1O <= 1'b0;
		else   n1O <= syncstatusin;
	initial
		ni = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) ni <= 1'b0;
		else   ni <= wire_niO0i_dataout;
	initial
		ni00l4 = 1'b1;
	always @ ( posedge ni0Oi)
		  ni00l4 <= ni00l5;
	initial
		ni00l5 = 0;
	always @ ( posedge ni0Oi)
		  ni00l5 <= ni00l4;
	initial
		ni00l6 = 0;
	always @ ( posedge ni0Oi)
		  ni00l6 <= (ni00l5 ^ ni00l4);
	initial
		ni01l7 = 1'b1;
	always @ ( posedge ni0Oi)
		  ni01l7 <= ni01l8;
	initial
		ni01l8 = 0;
	always @ ( posedge ni0Oi)
		  ni01l8 <= ni01l7;
	initial
		ni01l9 = 0;
	always @ ( posedge ni0Oi)
		  ni01l9 <= (ni01l8 ^ ni01l7);
	initial
		ni0il1 = 1'b1;
	always @ ( posedge ni0Oi)
		  ni0il1 <= ni0il2;
	initial
		ni0il2 = 0;
	always @ ( posedge ni0Oi)
		  ni0il2 <= ni0il1;
	initial
		ni0il3 = 0;
	always @ ( posedge ni0Oi)
		  ni0il3 <= (ni0il2 ^ ni0il1);
	initial
		ni10l19 = 1'b1;
	always @ ( posedge ni0Oi)
		  ni10l19 <= ni10l20;
	initial
		ni10l20 = 0;
	always @ ( posedge ni0Oi)
		  ni10l20 <= ni10l19;
	initial
		ni10l21 = 0;
	always @ ( posedge ni0Oi)
		  ni10l21 <= (ni10l20 ^ ni10l19);
	initial
		ni11i25 = 1'b1;
	always @ ( posedge ni0Oi)
		  ni11i25 <= ni11i26;
	initial
		ni11i26 = 0;
	always @ ( posedge ni0Oi)
		  ni11i26 <= ni11i25;
	initial
		ni11i27 = 0;
	always @ ( posedge ni0Oi)
		  ni11i27 <= (ni11i26 ^ ni11i25);
	initial
		ni11O22 = 1'b1;
	always @ ( posedge ni0Oi)
		  ni11O22 <= ni11O23;
	initial
		ni11O23 = 0;
	always @ ( posedge ni0Oi)
		  ni11O23 <= ni11O22;
	initial
		ni11O24 = 0;
	always @ ( posedge ni0Oi)
		  ni11O24 <= (ni11O23 ^ ni11O22);
	initial
		ni1ii16 = 1'b1;
	always @ ( posedge ni0Oi)
		  ni1ii16 <= ni1ii17;
	initial
		ni1ii17 = 0;
	always @ ( posedge ni0Oi)
		  ni1ii17 <= ni1ii16;
	initial
		ni1ii18 = 0;
	always @ ( posedge ni0Oi)
		  ni1ii18 <= (ni1ii17 ^ ni1ii16);
	initial
		ni1iO13 = 1'b1;
	always @ ( posedge ni0Oi)
		  ni1iO13 <= ni1iO14;
	initial
		ni1iO14 = 0;
	always @ ( posedge ni0Oi)
		  ni1iO14 <= ni1iO13;
	initial
		ni1iO15 = 0;
	always @ ( posedge ni0Oi)
		  ni1iO15 <= (ni1iO14 ^ ni1iO13);
	initial
		ni1ll10 = 1'b1;
	always @ ( posedge ni0Oi)
		  ni1ll10 <= ni1ll11;
	initial
		ni1ll11 = 0;
	always @ ( posedge ni0Oi)
		  ni1ll11 <= ni1ll10;
	initial
		ni1ll12 = 0;
	always @ ( posedge ni0Oi)
		  ni1ll12 <= (ni1ll11 ^ ni1ll10);
	initial
		nii = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nii <= 1'b0;
		else   nii <= wire_niO0l_dataout;
	initial
		niiO = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) niiO <= 1'b1;
		else   niiO <= ni0li;
	initial
		nil = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nil <= 1'b0;
		else   nil <= wire_niO0i_dataout;
	initial
		nili = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nili <= 1'b1;
		else   nili <= ni0li;
	initial
		nill = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nill <= 1'b1;
		else   nill <= wire_niOil_dataout;
	initial
		nilO = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nilO <= 1'b1;
		else   nilO <= wire_niOii_dataout;
	initial
		niO = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) niO <= 1'b0;
		else   niO <= wire_nliOi_dataout;
	initial
		niOi = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) niOi <= 1'b1;
		else   niOi <= wire_niO0O_dataout;
	initial
		niOl = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) niOl <= 1'b1;
		else   niOl <= wire_niOil_dataout;
	initial
		niOO = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) niOO <= 1'b1;
		else   niOO <= wire_niOii_dataout;
	initial
		nl = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nl <= 1'b0;
		else   nl <= wire_nliOi_dataout;
	initial
		nl0i = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nl0i <= 1'b0;
		else   nl0i <= datain[1:1];
	initial
		nl0l = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nl0l <= 1'b0;
		else   nl0l <= datain[2:2];
	initial
		nl0O = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nl0O <= 1'b0;
		else   nl0O <= datain[3:3];
	initial
		nl1i = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nl1i <= 1'b1;
		else   nl1i <= wire_niO0O_dataout;
	initial
		nl1l = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nl1l <= 1'b0;
		else   nl1l <= wire_nlill_dataout;
	initial
		nl1O = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nl1O <= 1'b0;
		else   nl1O <= datain[0:0];
	initial
		nli = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nli <= 1'b0;
		else   nli <= wire_nlilO_dataout;
	initial
		nlii = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nlii <= 1'b0;
		else   nlii <= datain[4:4];
	initial
		nlil = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nlil <= 1'b0;
		else   nlil <= datain[5:5];
	initial
		nliO = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nliO <= 1'b0;
		else   nliO <= datain[6:6];
	initial
		nll = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nll <= 1'b0;
		else   nll <= wire_nlill_dataout;
	initial
		nlli = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nlli <= 1'b0;
		else   nlli <= datain[7:7];
	initial
		nlll = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nlll <= 1'b0;
		else   nlll <= datain[8:8];
	initial
		nllO = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nllO <= 1'b0;
		else   nllO <= datain[9:9];
	initial
		nlO = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nlO <= 1'b0;
		else   nlO <= wire_niO0l_dataout;
	initial
		nlOi = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nlOi <= 1'b0;
		else   nlOi <= disperrin;
	initial
		nlOl = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nlOl <= 1'b0;
		else   nlOl <= datainvalid;
	initial
		nlOO = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nlOO <= 1'b0;
		else   nlOO <= datainvalid;
	initial
		nO = 0;
	always @ ( posedge clk or posedge reset)
		if (reset == 1'b1) nO <= 1'b0;
		else   nO <= wire_nlilO_dataout;
	or(wire_niO0i_dataout, wire_niOiO_dataout, ni1OO);
	or(wire_niO0l_dataout, wire_niOli_dataout, ni1OO);
	or(wire_niO0O_dataout, wire_niOll_dataout, ni1OO);
	and(wire_niOii_dataout, wire_niOlO_dataout, ~{ni1OO});
	and(wire_niOil_dataout, wire_niOOi_dataout, ~{ni1OO});
	or(wire_niOiO_dataout, wire_niOOl_dataout, n0OOi);
	or(wire_niOli_dataout, wire_niOOO_dataout, n0OOi);
	and(wire_niOll_dataout, wire_nl11i_dataout, ~{n0OOi});
	and(wire_niOlO_dataout, wire_nl11l_dataout, ~{n0OOi});
	and(wire_niOOi_dataout, wire_nl11O_dataout, ~{n0OOi});
	assign		wire_niOOl_dataout = (n0Oil === 1'b1) ? wire_nl1li_dataout : wire_nl10i_dataout;
	assign		wire_niOOO_dataout = (n0Oil === 1'b1) ? wire_nl1ll_dataout : wire_nl10l_dataout;
	assign		wire_nl10i_dataout = (n0l1O === 1'b1) ? datain[4:4] : ni1Oi;
	assign		wire_nl10l_dataout = (n0l1O === 1'b1) ? datain[3:3] : (~ wire_nli0l_dataout);
	assign		wire_nl10O_dataout = (n0l1O === 1'b1) ? datain[2:2] : (~ wire_nli0O_dataout);
	assign		wire_nl11i_dataout = (n0Oil === 1'b1) ? wire_nl1ll_dataout : wire_nl10O_dataout;
	assign		wire_nl11l_dataout = (n0Oil === 1'b1) ? wire_nl1ll_dataout : wire_nl1ii_dataout;
	assign		wire_nl11O_dataout = (n0Oil === 1'b1) ? wire_nl1ll_dataout : wire_nl1il_dataout;
	assign		wire_nl1ii_dataout = (n0l1O === 1'b1) ? datain[1:1] : (~ wire_nliii_dataout);
	assign		wire_nl1il_dataout = (n0l1O === 1'b1) ? datain[0:0] : (~ wire_nliil_dataout);
	and(wire_nl1li_dataout, wire_nl1lO_dataout, ~{n0l1l});
	and(wire_nl1ll_dataout, (~ n0l1i), ~{n0l1l});
	or(wire_nl1lO_dataout, (~ ((~ wire_nli0O_dataout) & 
		wire_nliii_dataout)), n0l1i);
	assign		wire_nli0i_dataout = (datain[5:5] === 1'b1) ? datain[4:4] : (~ datain[4:4]);
	assign		wire_nli0l_dataout = (datain[5:5] === 1'b1) ? datain[3:3] : (~ datain[3:3]);
	assign		wire_nli0O_dataout = (datain[5:5] === 1'b1) ? datain[2:2] : (~ datain[2:2]);
	assign		wire_nliii_dataout = (datain[5:5] === 1'b1) ? datain[1:1] : (~ datain[1:1]);
	assign		wire_nliil_dataout = (datain[5:5] === 1'b1) ? datain[0:0] : (~ datain[0:0]);
	and(wire_nlill_dataout, wire_nliOl_dataout, ~{(~ ni0ii)});
	and(wire_nlilO_dataout, wire_nliOO_dataout, ~{(~ ni0ii)});
	and(wire_nliOi_dataout, wire_nll1i_dataout, ~{(~ ni0ii)});
	or(wire_nliOl_dataout, wire_nll1l_dataout, (~ ni00i));
	or(wire_nliOO_dataout, wire_nll1O_dataout, (~ ni00i));
	assign		wire_nll0i_dataout = ((~ ni01i) === 1'b1) ? wire_nllOl_dataout : wire_nllii_dataout;
	assign		wire_nll0l_dataout = (ni1Ol === 1'b1) ? (~ datain[8:8]) : datain[8:8];
	assign		wire_nll0O_dataout = (ni1Ol === 1'b1) ? (~ datain[7:7]) : datain[7:7];
	or(wire_nll1i_dataout, wire_nll0i_dataout, (~ ni00i));
	assign		wire_nll1l_dataout = ((~ ni01i) === 1'b1) ? wire_nlllO_dataout : wire_nll0l_dataout;
	assign		wire_nll1O_dataout = ((~ ni01i) === 1'b1) ? wire_nllOi_dataout : wire_nll0O_dataout;
	assign		wire_nllii_dataout = (ni1Ol === 1'b1) ? (~ datain[6:6]) : datain[6:6];
	assign		wire_nlllO_dataout = (datain[9:9] === 1'b1) ? (~ datain[8:8]) : datain[8:8];
	assign		wire_nllOi_dataout = (datain[9:9] === 1'b1) ? (~ datain[7:7]) : datain[7:7];
	assign		wire_nllOl_dataout = (datain[9:9] === 1'b1) ? (~ datain[6:6]) : datain[6:6];
	assign
		dataout = {nl1l, nO, nl, ni, nlO, nl1i, niOO, niOl},
		decdatavalid = nlOO,
		disperr = n1i,
		errdetect = n0l,
		kout = nili,
		n0iOO = ((~ wire_nliil_dataout) & (~ wire_nliii_dataout)),
		n0l0i = (((((~ wire_nli0l_dataout) & ((~ wire_nli0O_dataout) & (wire_nliil_dataout & (~ wire_nliii_dataout)))) | ((~ wire_nli0l_dataout) & ((~ wire_nli0O_dataout) & ((~ wire_nliil_dataout) & wire_nliii_dataout)))) | ((~ wire_nli0l_dataout) & (wire_nli0O_dataout & n0iOO))) | (wire_nli0l_dataout & ((~ wire_nli0O_dataout) & n0iOO))),
		n0l1i = (wire_nli0O_dataout & wire_nliii_dataout),
		n0l1l = ((~ wire_nli0O_dataout) & (~ wire_nliii_dataout)),
		n0l1O = ((((~ wire_nli0i_dataout) & (((((((((((~ wire_nli0l_dataout) & ((~ wire_nli0O_dataout) & (wire_nliil_dataout & wire_nliii_dataout))) | (((~ wire_nli0l_dataout) & (wire_nli0O_dataout & n0Oii)) & w_n0O0l138w)) | (~ w_n0O1O143w)) | ((~ wire_nli0l_dataout) & (wire_nli0O_dataout & n0O1l))) | (~ w_n0lOO151w)) | ((wire_nli0l_dataout & (((~ wire_nli0O_dataout) & n0Oii) & w_n0lOi157w)) & w_n0lll162w)) | (~ w_n0liO167w)) | (wire_nli0l_dataout & ((~ wire_nli0O_dataout) & n0O1l))) | (~ w_n0lii175w)) | ((wire_nli0l_dataout & (wire_nli0O_dataout & ((~ wire_nliil_dataout) & (~ wire_nliii_dataout)))) & w_n0l0l182w))) | (wire_nli0i_dataout & n0l0i)) & (wire_nli0O_dataout | (wire_nliil_dataout | wire_nliii_dataout))),
		n0O1l = ((~ wire_nliil_dataout) & wire_nliii_dataout),
		n0Oii = (wire_nliil_dataout & (~ wire_nliii_dataout)),
		n0Oil = ((wire_nli0i_dataout & (((wire_nliil_dataout ^ wire_nliii_dataout) ^ (~ w_n0Oll121w)) & (wire_nli0l_dataout ^ wire_nli0O_dataout))) & w_n0OiO129w),
		n0OOi = (wire_nli0i_dataout & (((~ wire_nli0l_dataout) & ((~ wire_nli0O_dataout) & ((wire_nliil_dataout & wire_nliii_dataout) & w_ni11i109w))) & w_n0OOl115w)),
		ni00i = (((wire_nlllO_dataout | wire_nllOi_dataout) | (~ wire_nllOl_dataout)) | (~ w_ni00l57w)),
		ni01i = ((datain[7:7] ^ datain[6:6]) ^ (~ w_ni01l63w)),
		ni0ii = (((wire_nlllO_dataout | (~ wire_nllOi_dataout)) | wire_nllOl_dataout) | (~ w_ni0il49w)),
		ni0li = (ni1OO | (((~ ni00i) & ni1Oi) & w_ni1ll74w)),
		ni0Oi = clk,
		ni1Oi = ((~ wire_nli0i_dataout) & n0l0i),
		ni1Ol = ((~ datain[5:5]) & ni1OO),
		ni1OO = ((wire_nli0i_dataout & ((wire_nli0l_dataout & ((wire_nli0O_dataout & (((~ wire_nliil_dataout) & (~ wire_nliii_dataout)) & w_ni1iO87w)) & w_ni1ii92w)) & w_ni10l97w)) & w_ni11O102w),
		patterndetect = n1l,
		rderr = n0i,
		syncstatus = n1O,
		tenBdata = {nllO, nlll, nlli, nliO, nlil, nlii, nl0O, nl0l, nl0i, nl1O},
		valid = n0O,
		w_n0l0l182w = n0l0l60,
		w_n0lii175w = n0lii57,
		w_n0liO167w = n0liO54,
		w_n0lll162w = n0lll51,
		w_n0lOi157w = n0lOi48,
		w_n0lOO151w = n0lOO45,
		w_n0O0l138w = n0O0l39,
		w_n0O1O143w = n0O1O42,
		w_n0OiO129w = n0OiO36,
		w_n0Oll121w = n0Oll33,
		w_n0OOl115w = n0OOl30,
		w_ni00l57w = ni00l6,
		w_ni01l63w = ni01l9,
		w_ni0il49w = ni0il3,
		w_ni10l97w = ni10l21,
		w_ni11i109w = ni11i27,
		w_ni11O102w = ni11O24,
		w_ni1ii92w = ni1ii18,
		w_ni1iO87w = ni1iO15,
		w_ni1ll74w = ni1ll12,
		xgmctrldet = niiO,
		xgmdataout = {nll, nli, niO, nil, nii, niOi, nilO, nill},
		xgmdatavalid = nlOl,
		xgmrunningdisp = nlOi;
endmodule //altgxb_8b10b_decoder
//synopsys translate_on
//VALID FILE
///////////////////////////////////////////////////////////////////////////////
//
//                            DESKEW FIFO RAM MODULE
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module deskew_ram_block (
    clk,
    reset, 
    addrwr,
    addrrd1,
    addrrd2,
    datain,
    we,
    re,
    dataout1,
    dataout2
    );

input 		clk;
input 		reset;
input 	[15:0]	addrwr;
input 	[15:0] 	addrrd1;
input 	[15:0] 	addrrd2;
input 	[13:0] 	datain;
input 		we, re;
output 	[13:0] 	dataout1;
output 	[13:0] 	dataout2;

parameter read_access_time = 0;
parameter write_access_time = 0;
parameter ram_width = 14;

reg [ram_width-1:0] dataout1_i, dataout2_i;
reg [ram_width-1:0] ram_array_d_0, ram_array_d_1, ram_array_d_2, ram_array_d_3,
		    ram_array_d_4, ram_array_d_5, ram_array_d_6, ram_array_d_7,
		    ram_array_d_8, ram_array_d_9, ram_array_d_10, ram_array_d_11,
		    ram_array_d_12, ram_array_d_13, ram_array_d_14, ram_array_d_15,
		    ram_array_q_0, ram_array_q_1, ram_array_q_2, ram_array_q_3,
		    ram_array_q_4, ram_array_q_5, ram_array_q_6, ram_array_q_7,
		    ram_array_q_8, ram_array_q_9, ram_array_q_10, ram_array_q_11,
		    ram_array_q_12, ram_array_q_13, ram_array_q_14, ram_array_q_15;
wire [ram_width-1:0] data_reg_0, data_reg_1, data_reg_2, data_reg_3,
		     data_reg_4, data_reg_5, data_reg_6, data_reg_7,
		     data_reg_8, data_reg_9, data_reg_10, data_reg_11,
		     data_reg_12, data_reg_13, data_reg_14, data_reg_15;

 /* Modelling the read port */
 /* Assuming address trigerred operation only */
//assignment
assign
    data_reg_0 = ( addrwr[0] == 1'b1 ) ? datain : ram_array_q_0,
    data_reg_1 = ( addrwr[1] == 1'b1 ) ? datain : ram_array_q_1,
    data_reg_2 = ( addrwr[2] == 1'b1 ) ? datain : ram_array_q_2,
    data_reg_3 = ( addrwr[3] == 1'b1 ) ? datain : ram_array_q_3,
    data_reg_4 = ( addrwr[4] == 1'b1 ) ? datain : ram_array_q_4,
    data_reg_5 = ( addrwr[5] == 1'b1 ) ? datain : ram_array_q_5,
    data_reg_6 = ( addrwr[6] == 1'b1 ) ? datain : ram_array_q_6,
    data_reg_7 = ( addrwr[7] == 1'b1 ) ? datain : ram_array_q_7,
    data_reg_8 = ( addrwr[8] == 1'b1 ) ? datain : ram_array_q_8,
    data_reg_9 = ( addrwr[9] == 1'b1 ) ? datain : ram_array_q_9,
    data_reg_10 = ( addrwr[10] == 1'b1 ) ? datain : ram_array_q_10,
    data_reg_11 = ( addrwr[11] == 1'b1 ) ? datain : ram_array_q_11,
    data_reg_12 = ( addrwr[12] == 1'b1 ) ? datain : ram_array_q_12,
    data_reg_13 = ( addrwr[13] == 1'b1 ) ? datain : ram_array_q_13,
    data_reg_14 = ( addrwr[14] == 1'b1 ) ? datain : ram_array_q_14,
    data_reg_15 = ( addrwr[15] == 1'b1 ) ? datain : ram_array_q_15;


assign #read_access_time dataout1 = re ? 13'b0000000000000 : dataout1_i;
assign #read_access_time dataout2 = re ? 13'b0000000000000 : dataout2_i;


always @(
    ram_array_q_0	or 
    ram_array_q_1	or 
    ram_array_q_2	or 
    ram_array_q_3	or 
    ram_array_q_4       or
    ram_array_q_5       or
    ram_array_q_6       or
    ram_array_q_7       or 
    ram_array_q_8       or
    ram_array_q_9       or
    ram_array_q_10      or
    ram_array_q_11      or 
    ram_array_q_12      or
    ram_array_q_13      or
    ram_array_q_14      or
    ram_array_q_15      or 
    addrrd1		or
    addrrd2		)
begin
    case ( addrrd1 )  // synopsys parallel_case full_case
    16'b0000000000000001 : dataout1_i = ram_array_q_0;
    16'b0000000000000010 : dataout1_i = ram_array_q_1;
    16'b0000000000000100 : dataout1_i = ram_array_q_2;
    16'b0000000000001000 : dataout1_i = ram_array_q_3;
    16'b0000000000010000 : dataout1_i = ram_array_q_4;
    16'b0000000000100000 : dataout1_i = ram_array_q_5;
    16'b0000000001000000 : dataout1_i = ram_array_q_6;
    16'b0000000010000000 : dataout1_i = ram_array_q_7;
    16'b0000000100000000 : dataout1_i = ram_array_q_8;
    16'b0000001000000000 : dataout1_i = ram_array_q_9;
    16'b0000010000000000 : dataout1_i = ram_array_q_10;
    16'b0000100000000000 : dataout1_i = ram_array_q_11;
    16'b0001000000000000 : dataout1_i = ram_array_q_12;
    16'b0010000000000000 : dataout1_i = ram_array_q_13;
    16'b0100000000000000 : dataout1_i = ram_array_q_14;
    16'b1000000000000000 : dataout1_i = ram_array_q_15;
    endcase

    case ( addrrd2 )  // synopsys parallel_case full_case
    16'b0000000000000001 : dataout2_i = ram_array_q_0;
    16'b0000000000000010 : dataout2_i = ram_array_q_1;
    16'b0000000000000100 : dataout2_i = ram_array_q_2;
    16'b0000000000001000 : dataout2_i = ram_array_q_3;
    16'b0000000000010000 : dataout2_i = ram_array_q_4;
    16'b0000000000100000 : dataout2_i = ram_array_q_5;
    16'b0000000001000000 : dataout2_i = ram_array_q_6;
    16'b0000000010000000 : dataout2_i = ram_array_q_7;
    16'b0000000100000000 : dataout2_i = ram_array_q_8;
    16'b0000001000000000 : dataout2_i = ram_array_q_9;
    16'b0000010000000000 : dataout2_i = ram_array_q_10;
    16'b0000100000000000 : dataout2_i = ram_array_q_11;
    16'b0001000000000000 : dataout2_i = ram_array_q_12;
    16'b0010000000000000 : dataout2_i = ram_array_q_13;
    16'b0100000000000000 : dataout2_i = ram_array_q_14;
    16'b1000000000000000 : dataout2_i = ram_array_q_15;
    endcase

end


/* Modelling the write port */
always @(posedge clk or posedge reset) 
begin
    if(reset) begin
	ram_array_q_0 <= #write_access_time 0;
	ram_array_q_1 <= #write_access_time 0;
	ram_array_q_2 <= #write_access_time 0; 
	ram_array_q_3 <= #write_access_time 0; 
        ram_array_q_4 <= #write_access_time 0;
        ram_array_q_5 <= #write_access_time 0;
        ram_array_q_6 <= #write_access_time 0;
        ram_array_q_7 <= #write_access_time 0; 
        ram_array_q_8 <= #write_access_time 0;
        ram_array_q_9 <= #write_access_time 0;
        ram_array_q_10 <= #write_access_time 0;
        ram_array_q_11 <= #write_access_time 0; 
        ram_array_q_12 <= #write_access_time 0;
        ram_array_q_13 <= #write_access_time 0;
        ram_array_q_14 <= #write_access_time 0;
        ram_array_q_15 <= #write_access_time 0; 
    end
    else begin
	ram_array_q_0 <= #write_access_time ram_array_d_0;
	ram_array_q_1 <= #write_access_time ram_array_d_1;
	ram_array_q_2 <= #write_access_time ram_array_d_2;
	ram_array_q_3 <= #write_access_time ram_array_d_3;
        ram_array_q_4 <= #write_access_time ram_array_d_4;
        ram_array_q_5 <= #write_access_time ram_array_d_5;
        ram_array_q_6 <= #write_access_time ram_array_d_6;
        ram_array_q_7 <= #write_access_time ram_array_d_7;
        ram_array_q_8 <= #write_access_time ram_array_d_8;
        ram_array_q_9 <= #write_access_time ram_array_d_9;
        ram_array_q_10 <= #write_access_time ram_array_d_10;
        ram_array_q_11 <= #write_access_time ram_array_d_11;
        ram_array_q_12 <= #write_access_time ram_array_d_12;
        ram_array_q_13 <= #write_access_time ram_array_d_13;
        ram_array_q_14 <= #write_access_time ram_array_d_14;
        ram_array_q_15 <= #write_access_time ram_array_d_15;
    end
end
         

always @( 
    we 			or 
    data_reg_0 		or 
    data_reg_1 		or 
    data_reg_2		or 
    data_reg_3		or
    data_reg_4          or
    data_reg_5          or
    data_reg_6          or
    data_reg_7          or
    data_reg_8          or
    data_reg_9          or
    data_reg_10         or
    data_reg_11         or
    data_reg_12         or
    data_reg_13         or
    data_reg_14         or
    data_reg_15         or
    ram_array_q_0 	or 
    ram_array_q_1	or
    ram_array_q_2	or
    ram_array_q_3	or
    ram_array_q_4       or
    ram_array_q_5       or
    ram_array_q_6       or
    ram_array_q_7	or
    ram_array_q_8       or
    ram_array_q_9       or
    ram_array_q_10      or
    ram_array_q_11	or
    ram_array_q_12      or
    ram_array_q_13      or
    ram_array_q_14      or
    ram_array_q_15	)
begin
    if(we) begin
	ram_array_d_0 <= #write_access_time data_reg_0;
	ram_array_d_1 <= #write_access_time data_reg_1;
	ram_array_d_2 <= #write_access_time data_reg_2;
	ram_array_d_3 <= #write_access_time data_reg_3;
        ram_array_d_4 <= #write_access_time data_reg_4;
        ram_array_d_5 <= #write_access_time data_reg_5;
        ram_array_d_6 <= #write_access_time data_reg_6;
        ram_array_d_7 <= #write_access_time data_reg_7; 
        ram_array_d_8 <= #write_access_time data_reg_8;
        ram_array_d_9 <= #write_access_time data_reg_9;
        ram_array_d_10 <= #write_access_time data_reg_10;
        ram_array_d_11 <= #write_access_time data_reg_11; 
        ram_array_d_12 <= #write_access_time data_reg_12;
        ram_array_d_13 <= #write_access_time data_reg_13;
        ram_array_d_14 <= #write_access_time data_reg_14;
        ram_array_d_15 <= #write_access_time data_reg_15; 
    end
    else begin
	ram_array_d_0 <= #write_access_time ram_array_q_0;
	ram_array_d_1 <= #write_access_time ram_array_q_1;
	ram_array_d_2 <= #write_access_time ram_array_q_2;
	ram_array_d_3 <= #write_access_time ram_array_q_3;
        ram_array_d_4 <= #write_access_time ram_array_q_4;
        ram_array_d_5 <= #write_access_time ram_array_q_5;
        ram_array_d_6 <= #write_access_time ram_array_q_6;
        ram_array_d_7 <= #write_access_time ram_array_q_7;
        ram_array_d_8 <= #write_access_time ram_array_q_8;
        ram_array_d_9 <= #write_access_time ram_array_q_9;
        ram_array_d_10 <= #write_access_time ram_array_q_10;
        ram_array_d_11 <= #write_access_time ram_array_q_11;
        ram_array_d_12 <= #write_access_time ram_array_q_12;
        ram_array_d_13 <= #write_access_time ram_array_q_13;
        ram_array_d_14 <= #write_access_time ram_array_q_14;
        ram_array_d_15 <= #write_access_time ram_array_q_15;

    end
end

endmodule

//IP Functional Simulation Model
//VERSION_BEGIN 4.1 cbx_mgl 2004:06:17:17:30:06:SJ cbx_simgen 2004:06:22:10:53:08:SJ  VERSION_END


// Legal Notice: � 2003 Altera Corporation. All rights reserved.
// You may only use these  simulation  model  output files for simulation
// purposes and expressly not for synthesis or any other purposes (in which
// event  Altera disclaims all warranties of any kind). Your use of  Altera
// Corporation's design tools, logic functions and other software and tools,
// and its AMPP partner logic functions, and any output files any of the
// foregoing (including device programming or simulation files), and any
// associated documentation or information  are expressly subject to the
// terms and conditions of the  Altera Program License Subscription Agreement
// or other applicable license agreement, including, without limitation, that
// your use is for the sole purpose of programming logic devices manufactured
// by Altera and sold by Altera or its authorized distributors.  Please refer
// to the applicable agreement for further details.


//synopsys translate_off

//synthesis_resources = deskew_ram_block 1 lut 102 mux21 112 oper_add 1 
`timescale 1 ps / 1 ps
module  altgxb_deskew_fifo_rtl
	( 
	adetectdeskew,
	datain,
	dataout,
	dataoutpre,
	disperr,
	disperrin,
	disperrpre,
	enabledeskew,
	errdetect,
	errdetectin,
	errdetectpre,
	fiforesetrd,
	patterndetect,
	patterndetectin,
	patterndetectpre,
	readclock,
	reset,
	syncstatus,
	syncstatusin,
	syncstatuspre,
	wr_align,
	writeclock) /* synthesis synthesis_clearbox=1 */;
	output   adetectdeskew;
	input   [9:0]  datain;
	output   [9:0]  dataout;
	output   [9:0]  dataoutpre;
	output   disperr;
	input   disperrin;
	output   disperrpre;
	input   enabledeskew;
	output   errdetect;
	input   errdetectin;
	output   errdetectpre;
	input   fiforesetrd;
	output   patterndetect;
	input   patterndetectin;
	output   patterndetectpre;
	input   readclock;
	input   reset;
	output   syncstatus;
	input   syncstatusin;
	output   syncstatuspre;
	input   wr_align;
	input   writeclock;

	wire  [13:0]   wire_n0iOl_dataout1;
	wire  [13:0]   wire_n0iOl_dataout2;
	reg	n00Ol13;
	reg	n00Ol14;
	reg	n00Ol15;
	reg	n0i0i7;
	reg	n0i0i8;
	reg	n0i0i9;
	reg	n0i1i10;
	reg	n0i1i11;
	reg	n0i1i12;
	reg	n0iii4;
	reg	n0iii5;
	reg	n0iii6;
	reg	n0ili1;
	reg	n0ili2;
	reg	n0ili3;
	reg	n0lO;
	reg	n0Oi;
	reg	n0Ol;
	reg	n0OO;
	reg	ni00i;
	reg	ni00l;
	reg	ni00O;
	reg	ni0i;
	reg	ni0ii;
	reg	ni0il;
	reg	ni0iO;
	reg	ni0l;
	reg	ni0li;
	reg	ni0O;
	reg	ni0Ol;
	reg	ni0OO;
	reg	ni1i;
	reg	ni1l;
	reg	ni1O;
	reg	nii1i;
	reg	nii1l;
	reg	nii1O;
	reg	niii;
	reg	niil;
	reg	niiO;
	reg	nil1O;
	reg	nili;
	reg	nilii;
	reg	nill;
	reg	nilli;
	reg	nilll;
	reg	nillO;
	reg	nilOi;
	reg	nilOl;
	reg	nilOO;
	reg	niO0i;
	reg	niO0l;
	reg	niO0O;
	reg	niO1i;
	reg	niO1l;
	reg	niO1O;
	reg	niOii;
	reg	niOil;
	reg	niOiO;
	reg	niOli;
	reg	niOll;
	reg	niOlO;
	reg	niOOi;
	reg	niOOl;
	reg	niOOO;
	reg	nl00i;
	reg	nl00l;
	reg	nl00O;
	reg	nl01i;
	reg	nl01l;
	reg	nl01O;
	reg	nl0ii;
	reg	nl0il;
	reg	nl0iO;
	reg	nl0li;
	reg	nl0ll;
	reg	nl0lO;
	reg	nl0Oi;
	reg	nl0Ol;
	reg	nl0OO;
	reg	nl10i;
	reg	nl10l;
	reg	nl10O;
	reg	nl11i;
	reg	nl11l;
	reg	nl11O;
	reg	nl1ii;
	reg	nl1il;
	reg	nl1iO;
	reg	nl1li;
	reg	nl1ll;
	reg	nl1lO;
	reg	nl1Oi;
	reg	nl1Ol;
	reg	nl1OO;
	reg	nli0i;
	reg	nli0l;
	reg	nli0O;
	reg	nli1i;
	reg	nli1l;
	reg	nli1O;
	reg	nliii;
	wire	wire_n00i_dataout;
	wire	wire_n00l_dataout;
	wire	wire_n00O_dataout;
	wire	wire_n01i_dataout;
	wire	wire_n01l_dataout;
	wire	wire_n01O_dataout;
	wire	wire_n0i_dataout;
	wire	wire_n0ii_dataout;
	wire	wire_n0il_dataout;
	wire	wire_n0iO_dataout;
	wire	wire_n0l_dataout;
	wire	wire_n0li_dataout;
	wire	wire_n0ll_dataout;
	wire	wire_n0O_dataout;
	wire	wire_n10i_dataout;
	wire	wire_n10l_dataout;
	wire	wire_n10O_dataout;
	wire	wire_n11i_dataout;
	wire	wire_n11l_dataout;
	wire	wire_n11O_dataout;
	wire	wire_n1i_dataout;
	wire	wire_n1ii_dataout;
	wire	wire_n1il_dataout;
	wire	wire_n1iO_dataout;
	wire	wire_n1l_dataout;
	wire	wire_n1li_dataout;
	wire	wire_n1ll_dataout;
	wire	wire_n1lO_dataout;
	wire	wire_n1O_dataout;
	wire	wire_n1Oi_dataout;
	wire	wire_n1Ol_dataout;
	wire	wire_n1OO_dataout;
	wire	wire_ni_dataout;
	wire	wire_nii_dataout;
	wire	wire_nii0i_dataout;
	wire	wire_nii0l_dataout;
	wire	wire_nii0O_dataout;
	wire	wire_niiii_dataout;
	wire	wire_niiil_dataout;
	wire	wire_niiiO_dataout;
	wire	wire_niili_dataout;
	wire	wire_niill_dataout;
	wire	wire_niilO_dataout;
	wire	wire_niiOi_dataout;
	wire	wire_niiOl_dataout;
	wire	wire_niiOO_dataout;
	wire	wire_nil_dataout;
	wire	wire_nil0i_dataout;
	wire	wire_nil0l_dataout;
	wire	wire_nilil_dataout;
	wire	wire_niliO_dataout;
	wire	wire_nilO_dataout;
	wire	wire_niO_dataout;
	wire	wire_niOi_dataout;
	wire	wire_niOl_dataout;
	wire	wire_niOO_dataout;
	wire	wire_nl0i_dataout;
	wire	wire_nl0l_dataout;
	wire	wire_nl0O_dataout;
	wire	wire_nl1i_dataout;
	wire	wire_nl1l_dataout;
	wire	wire_nl1O_dataout;
	wire	wire_nli_dataout;
	wire	wire_nlii_dataout;
	wire	wire_nliil_dataout;
	wire	wire_nliiO_dataout;
	wire	wire_nlil_dataout;
	wire	wire_nlili_dataout;
	wire	wire_nlill_dataout;
	wire	wire_nlilO_dataout;
	wire	wire_nliO_dataout;
	wire	wire_nliOi_dataout;
	wire	wire_nliOl_dataout;
	wire	wire_nliOO_dataout;
	wire	wire_nll_dataout;
	wire	wire_nll0i_dataout;
	wire	wire_nll0l_dataout;
	wire	wire_nll0O_dataout;
	wire	wire_nll1i_dataout;
	wire	wire_nll1l_dataout;
	wire	wire_nll1O_dataout;
	wire	wire_nlli_dataout;
	wire	wire_nllii_dataout;
	wire	wire_nllil_dataout;
	wire	wire_nlliO_dataout;
	wire	wire_nlll_dataout;
	wire	wire_nllli_dataout;
	wire	wire_nllll_dataout;
	wire	wire_nlllO_dataout;
	wire	wire_nllO_dataout;
	wire	wire_nllOi_dataout;
	wire	wire_nllOl_dataout;
	wire	wire_nllOO_dataout;
	wire	wire_nlO_dataout;
	wire	wire_nlO0i_dataout;
	wire	wire_nlO0l_dataout;
	wire	wire_nlO0O_dataout;
	wire	wire_nlO1i_dataout;
	wire	wire_nlO1l_dataout;
	wire	wire_nlO1O_dataout;
	wire	wire_nlOi_dataout;
	wire	wire_nlOii_dataout;
	wire	wire_nlOil_dataout;
	wire	wire_nlOiO_dataout;
	wire	wire_nlOl_dataout;
	wire	wire_nlOli_dataout;
	wire	wire_nlOll_dataout;
	wire	wire_nlOlO_dataout;
	wire	wire_nlOO_dataout;
	wire	wire_nlOOi_dataout;
	wire	wire_nlOOl_dataout;
	wire	wire_nlOOO_dataout;
	wire  [4:0]   wire_nil1i_o;
	wire  n00Oi;
	wire  n0i0O;
	wire  n0i1O;
	wire  n0iiO;
	wire  w_n00Ol62w;
	wire  w_n0i0i18w;
	wire  w_n0i1i56w;
	wire  w_n0iii12w;
	wire  w_n0ili4w;

	deskew_ram_block   n0iOl
	( 
	.addrrd1({n0lO, nliii, nli0O, nli0l, nli0i, nli1O, nli1l, nli1i, nl0OO, nl0Ol, nl0Oi, nl0lO, nl0ll, nl0li, nl0iO, ni0il}),
	.addrrd2({nl0il, nl0ii, nl00O, nl00l, nl00i, nl01O, nl01l, nl01i, nl1OO, nl1Ol, nl1Oi, nl1lO, nl1ll, nl1li, ni0ii, nl1iO}),
	.addrwr({ni0li, nill, nili, niiO, niil, niii, ni0O, ni0l, ni0i, ni1O, ni1l, ni1i, n0OO, n0Ol, n0Oi, ni0iO}),
	.clk(writeclock),
	.datain({patterndetectin, disperrin, syncstatusin, errdetectin, datain[9:0]}),
	.dataout1(wire_n0iOl_dataout1),
	.dataout2(wire_n0iOl_dataout2),
	.re(1'b0),
	.reset(reset),
	.we(1'b1));
	defparam
		n0iOl.ram_width = 14,
		n0iOl.read_access_time = 0,
		n0iOl.write_access_time = 0;
	initial
		n00Ol13 = 1'b1;
	always @ ( posedge n0iiO)
		  n00Ol13 <= n00Ol14;
	initial
		n00Ol14 = 0;
	always @ ( posedge n0iiO)
		  n00Ol14 <= n00Ol13;
	initial
		n00Ol15 = 0;
	always @ ( posedge n0iiO)
		  n00Ol15 <= (n00Ol14 ^ n00Ol13);
	initial
		n0i0i7 = 1'b1;
	always @ ( posedge n0iiO)
		  n0i0i7 <= n0i0i8;
	initial
		n0i0i8 = 0;
	always @ ( posedge n0iiO)
		  n0i0i8 <= n0i0i7;
	initial
		n0i0i9 = 0;
	always @ ( posedge n0iiO)
		  n0i0i9 <= (n0i0i8 ^ n0i0i7);
	initial
		n0i1i10 = 1'b1;
	always @ ( posedge n0iiO)
		  n0i1i10 <= n0i1i11;
	initial
		n0i1i11 = 0;
	always @ ( posedge n0iiO)
		  n0i1i11 <= n0i1i10;
	initial
		n0i1i12 = 0;
	always @ ( posedge n0iiO)
		  n0i1i12 <= (n0i1i11 ^ n0i1i10);
	initial
		n0iii4 = 1'b1;
	always @ ( posedge n0iiO)
		  n0iii4 <= n0iii5;
	initial
		n0iii5 = 0;
	always @ ( posedge n0iiO)
		  n0iii5 <= n0iii4;
	initial
		n0iii6 = 0;
	always @ ( posedge n0iiO)
		  n0iii6 <= (n0iii5 ^ n0iii4);
	initial
		n0ili1 = 1'b1;
	always @ ( posedge n0iiO)
		  n0ili1 <= n0ili2;
	initial
		n0ili2 = 0;
	always @ ( posedge n0iiO)
		  n0ili2 <= n0ili1;
	initial
		n0ili3 = 0;
	always @ ( posedge n0iiO)
		  n0ili3 <= (n0ili2 ^ n0ili1);
	initial
		n0lO = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) n0lO <= 1'b0;
		else   n0lO <= wire_nlOiO_dataout;
	initial
		n0Oi = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) n0Oi <= 1'b0;
		else   n0Oi <= wire_niOi_dataout;
	initial
		n0Ol = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) n0Ol <= 1'b0;
		else   n0Ol <= wire_niOl_dataout;
	initial
		n0OO = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) n0OO <= 1'b0;
		else   n0OO <= wire_niOO_dataout;
	initial
		ni00i = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) ni00i <= 1'b1;
		else   ni00i <= ni00l;
	initial
		ni00l = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) ni00l <= 1'b1;
		else   ni00l <= ni00O;
	initial
		ni00O = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) ni00O <= 1'b1;
		else   ni00O <= enabledeskew;
	initial
		ni0i = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) ni0i <= 1'b0;
		else   ni0i <= wire_nl0i_dataout;
	initial
		ni0ii = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) ni0ii <= 1'b1;
		else   ni0ii <= wire_nliiO_dataout;
	initial
		ni0il = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) ni0il <= 1'b1;
		else   ni0il <= wire_nlliO_dataout;
	initial
		ni0iO = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) ni0iO <= 1'b1;
		else   ni0iO <= wire_nilO_dataout;
	initial
		ni0l = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) ni0l <= 1'b0;
		else   ni0l <= wire_nl0l_dataout;
	initial
		ni0li = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) ni0li <= 1'b0;
		else   ni0li <= wire_nllO_dataout;
	initial
		ni0O = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) ni0O <= 1'b0;
		else   ni0O <= wire_nl0O_dataout;
	initial
		ni0Ol = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) ni0Ol <= 1'b0;
		else   ni0Ol <= ni0OO;
	initial
		ni0OO = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) ni0OO <= 1'b0;
		else   ni0OO <= nilii;
	initial
		ni1i = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) ni1i <= 1'b0;
		else   ni1i <= wire_nl1i_dataout;
	initial
		ni1l = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) ni1l <= 1'b0;
		else   ni1l <= wire_nl1l_dataout;
	initial
		ni1O = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) ni1O <= 1'b0;
		else   ni1O <= wire_nl1O_dataout;
	initial
		nii1i = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) nii1i <= 1'b0;
		else   nii1i <= wire_nii0i_dataout;
	initial
		nii1l = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) nii1l <= 1'b0;
		else   nii1l <= wire_nii0l_dataout;
	initial
		nii1O = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) nii1O <= 1'b0;
		else   nii1O <= wire_nii0O_dataout;
	initial
		niii = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) niii <= 1'b0;
		else   niii <= wire_nlii_dataout;
	initial
		niil = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) niil <= 1'b0;
		else   niil <= wire_nlil_dataout;
	initial
		niiO = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) niiO <= 1'b0;
		else   niiO <= wire_nliO_dataout;
	initial
		nil1O = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) nil1O <= 1'b0;
		else   nil1O <= wire_niiii_dataout;
	initial
		nili = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) nili <= 1'b0;
		else   nili <= wire_nlli_dataout;
	initial
		nilii = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) nilii <= 1'b0;
		else   nilii <= wire_nil0i_dataout;
	initial
		nill = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) nill <= 1'b0;
		else   nill <= wire_nlll_dataout;
	initial
		nilli = 0;
	always @ ( posedge writeclock or posedge reset)
		if (reset == 1'b1) nilli <= 1'b0;
		else   nilli <= wire_nilil_dataout;
	initial
		nilll = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nilll <= 1'b0;
		else   nilll <= wire_n0iOl_dataout2[13:13];
	initial
		nillO = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nillO <= 1'b0;
		else   nillO <= wire_n0iOl_dataout1[13:13];
	initial
		nilOi = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nilOi <= 1'b0;
		else   nilOi <= wire_n0iOl_dataout2[12:12];
	initial
		nilOl = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nilOl <= 1'b0;
		else   nilOl <= wire_n0iOl_dataout2[11:11];
	initial
		nilOO = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nilOO <= 1'b0;
		else   nilOO <= wire_n0iOl_dataout2[10:10];
	initial
		niO0i = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) niO0i <= 1'b0;
		else   niO0i <= wire_n0iOl_dataout2[3:3];
	initial
		niO0l = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) niO0l <= 1'b0;
		else   niO0l <= wire_n0iOl_dataout2[4:4];
	initial
		niO0O = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) niO0O <= 1'b0;
		else   niO0O <= wire_n0iOl_dataout2[5:5];
	initial
		niO1i = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) niO1i <= 1'b0;
		else   niO1i <= wire_n0iOl_dataout2[0:0];
	initial
		niO1l = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) niO1l <= 1'b0;
		else   niO1l <= wire_n0iOl_dataout2[1:1];
	initial
		niO1O = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) niO1O <= 1'b0;
		else   niO1O <= wire_n0iOl_dataout2[2:2];
	initial
		niOii = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) niOii <= 1'b0;
		else   niOii <= wire_n0iOl_dataout2[6:6];
	initial
		niOil = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) niOil <= 1'b0;
		else   niOil <= wire_n0iOl_dataout2[7:7];
	initial
		niOiO = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) niOiO <= 1'b0;
		else   niOiO <= wire_n0iOl_dataout2[8:8];
	initial
		niOli = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) niOli <= 1'b0;
		else   niOli <= wire_n0iOl_dataout2[9:9];
	initial
		niOll = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) niOll <= 1'b0;
		else   niOll <= wire_n0iOl_dataout1[12:12];
	initial
		niOlO = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) niOlO <= 1'b0;
		else   niOlO <= wire_n0iOl_dataout1[11:11];
	initial
		niOOi = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) niOOi <= 1'b0;
		else   niOOi <= wire_n0iOl_dataout1[10:10];
	initial
		niOOl = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) niOOl <= 1'b0;
		else   niOOl <= wire_n0iOl_dataout1[0:0];
	initial
		niOOO = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) niOOO <= 1'b0;
		else   niOOO <= wire_n0iOl_dataout1[1:1];
	initial
		nl00i = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl00i <= 1'b0;
		else   nl00i <= wire_nll0i_dataout;
	initial
		nl00l = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl00l <= 1'b0;
		else   nl00l <= wire_nll0l_dataout;
	initial
		nl00O = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl00O <= 1'b0;
		else   nl00O <= wire_nll0O_dataout;
	initial
		nl01i = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl01i <= 1'b0;
		else   nl01i <= wire_nll1i_dataout;
	initial
		nl01l = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl01l <= 1'b0;
		else   nl01l <= wire_nll1l_dataout;
	initial
		nl01O = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl01O <= 1'b0;
		else   nl01O <= wire_nll1O_dataout;
	initial
		nl0ii = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl0ii <= 1'b0;
		else   nl0ii <= wire_nllii_dataout;
	initial
		nl0il = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl0il <= 1'b0;
		else   nl0il <= wire_nllil_dataout;
	initial
		nl0iO = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl0iO <= 1'b0;
		else   nl0iO <= wire_nllli_dataout;
	initial
		nl0li = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl0li <= 1'b0;
		else   nl0li <= wire_nllll_dataout;
	initial
		nl0ll = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl0ll <= 1'b0;
		else   nl0ll <= wire_nlllO_dataout;
	initial
		nl0lO = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl0lO <= 1'b0;
		else   nl0lO <= wire_nllOi_dataout;
	initial
		nl0Oi = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl0Oi <= 1'b0;
		else   nl0Oi <= wire_nllOl_dataout;
	initial
		nl0Ol = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl0Ol <= 1'b0;
		else   nl0Ol <= wire_nllOO_dataout;
	initial
		nl0OO = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl0OO <= 1'b0;
		else   nl0OO <= wire_nlO1i_dataout;
	initial
		nl10i = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl10i <= 1'b0;
		else   nl10i <= wire_n0iOl_dataout1[5:5];
	initial
		nl10l = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl10l <= 1'b0;
		else   nl10l <= wire_n0iOl_dataout1[6:6];
	initial
		nl10O = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl10O <= 1'b0;
		else   nl10O <= wire_n0iOl_dataout1[7:7];
	initial
		nl11i = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl11i <= 1'b0;
		else   nl11i <= wire_n0iOl_dataout1[2:2];
	initial
		nl11l = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl11l <= 1'b0;
		else   nl11l <= wire_n0iOl_dataout1[3:3];
	initial
		nl11O = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl11O <= 1'b0;
		else   nl11O <= wire_n0iOl_dataout1[4:4];
	initial
		nl1ii = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl1ii <= 1'b0;
		else   nl1ii <= wire_n0iOl_dataout1[8:8];
	initial
		nl1il = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl1il <= 1'b0;
		else   nl1il <= wire_n0iOl_dataout1[9:9];
	initial
		nl1iO = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl1iO <= 1'b0;
		else   nl1iO <= wire_nliil_dataout;
	initial
		nl1li = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl1li <= 1'b0;
		else   nl1li <= wire_nlili_dataout;
	initial
		nl1ll = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl1ll <= 1'b0;
		else   nl1ll <= wire_nlill_dataout;
	initial
		nl1lO = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl1lO <= 1'b0;
		else   nl1lO <= wire_nlilO_dataout;
	initial
		nl1Oi = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl1Oi <= 1'b0;
		else   nl1Oi <= wire_nliOi_dataout;
	initial
		nl1Ol = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl1Ol <= 1'b0;
		else   nl1Ol <= wire_nliOl_dataout;
	initial
		nl1OO = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nl1OO <= 1'b0;
		else   nl1OO <= wire_nliOO_dataout;
	initial
		nli0i = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nli0i <= 1'b0;
		else   nli0i <= wire_nlO0l_dataout;
	initial
		nli0l = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nli0l <= 1'b0;
		else   nli0l <= wire_nlO0O_dataout;
	initial
		nli0O = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nli0O <= 1'b0;
		else   nli0O <= wire_nlOii_dataout;
	initial
		nli1i = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nli1i <= 1'b0;
		else   nli1i <= wire_nlO1l_dataout;
	initial
		nli1l = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nli1l <= 1'b0;
		else   nli1l <= wire_nlO1O_dataout;
	initial
		nli1O = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nli1O <= 1'b0;
		else   nli1O <= wire_nlO0i_dataout;
	initial
		nliii = 0;
	always @ ( posedge readclock or posedge reset)
		if (reset == 1'b1) nliii <= 1'b0;
		else   nliii <= wire_nlOil_dataout;
	and(wire_n00i_dataout, nl0OO, (~ enabledeskew));
	and(wire_n00l_dataout, nli1i, (~ enabledeskew));
	and(wire_n00O_dataout, nli1l, (~ enabledeskew));
	and(wire_n01i_dataout, nl0lO, (~ enabledeskew));
	and(wire_n01l_dataout, nl0Oi, (~ enabledeskew));
	and(wire_n01O_dataout, nl0Ol, (~ enabledeskew));
	assign		wire_n0i_dataout = (n0i1O === 1'b1) ? ni1l : ni1O;
	and(wire_n0ii_dataout, nli1O, (~ enabledeskew));
	and(wire_n0il_dataout, nli0i, (~ enabledeskew));
	and(wire_n0iO_dataout, nli0l, (~ enabledeskew));
	assign		wire_n0l_dataout = (n0i1O === 1'b1) ? ni1O : ni0i;
	and(wire_n0li_dataout, nli0O, (~ enabledeskew));
	and(wire_n0ll_dataout, nliii, (~ enabledeskew));
	assign		wire_n0O_dataout = (n0i1O === 1'b1) ? ni0i : ni0l;
	and(wire_n10i_dataout, nl01i, (~ enabledeskew));
	and(wire_n10l_dataout, nl01l, (~ enabledeskew));
	and(wire_n10O_dataout, nl01O, (~ enabledeskew));
	and(wire_n11i_dataout, nl1Oi, (~ enabledeskew));
	and(wire_n11l_dataout, nl1Ol, (~ enabledeskew));
	and(wire_n11O_dataout, nl1OO, (~ enabledeskew));
	assign		wire_n1i_dataout = (n0i1O === 1'b1) ? n0Ol : n0OO;
	and(wire_n1ii_dataout, nl00i, (~ enabledeskew));
	and(wire_n1il_dataout, nl00l, (~ enabledeskew));
	and(wire_n1iO_dataout, nl00O, (~ enabledeskew));
	assign		wire_n1l_dataout = (n0i1O === 1'b1) ? n0OO : ni1i;
	and(wire_n1li_dataout, nl0ii, (~ enabledeskew));
	or(wire_n1ll_dataout, n0lO, ~{(~ enabledeskew)});
	and(wire_n1lO_dataout, ni0il, (~ enabledeskew));
	assign		wire_n1O_dataout = (n0i1O === 1'b1) ? ni1i : ni1l;
	and(wire_n1Oi_dataout, nl0iO, (~ enabledeskew));
	and(wire_n1Ol_dataout, nl0li, (~ enabledeskew));
	and(wire_n1OO_dataout, nl0ll, (~ enabledeskew));
	assign		wire_ni_dataout = (n0i1O === 1'b1) ? nill : ni0li;
	assign		wire_nii_dataout = (n0i1O === 1'b1) ? ni0l : ni0O;
	and(wire_nii0i_dataout, wire_niiil_dataout, ~{(~ ni00l)});
	and(wire_nii0l_dataout, wire_niiiO_dataout, ~{(~ ni00l)});
	and(wire_nii0O_dataout, wire_niili_dataout, ~{(~ ni00l)});
	and(wire_niiii_dataout, wire_niill_dataout, ~{(~ ni00l)});
	or(wire_niiil_dataout, wire_niilO_dataout, wr_align);
	and(wire_niiiO_dataout, wire_niiOi_dataout, ~{wr_align});
	and(wire_niili_dataout, wire_niiOl_dataout, ~{wr_align});
	or(wire_niill_dataout, wire_niiOO_dataout, wr_align);
	assign		wire_niilO_dataout = (n00Oi === 1'b1) ? wire_nil1i_o[1:1] : nii1i;
	assign		wire_niiOi_dataout = (n00Oi === 1'b1) ? wire_nil1i_o[2:2] : nii1l;
	assign		wire_niiOl_dataout = (n00Oi === 1'b1) ? wire_nil1i_o[3:3] : nii1O;
	assign		wire_niiOO_dataout = (n00Oi === 1'b1) ? wire_nil1i_o[4:4] : nil1O;
	assign		wire_nil_dataout = (n0i1O === 1'b1) ? ni0O : niii;
	or(wire_nil0i_dataout, wire_nil0l_dataout, wr_align);
	and(wire_nil0l_dataout, nilii, ~{(~ ((((nil1O | 
		nii1O) | nii1l) | nii1i) | (~ w_n0i1i56w)))});
	and(wire_nilil_dataout, wire_niliO_dataout, ~{n0i0O});
	or(wire_niliO_dataout, nilli, wr_align);
	or(wire_nilO_dataout, wire_nlOi_dataout, n0i0O);
	assign		wire_niO_dataout = (n0i1O === 1'b1) ? niii : niil;
	and(wire_niOi_dataout, wire_nlOl_dataout, ~{n0i0O});
	and(wire_niOl_dataout, wire_nlOO_dataout, ~{n0i0O});
	and(wire_niOO_dataout, wire_n1i_dataout, ~{n0i0O});
	and(wire_nl0i_dataout, wire_n0l_dataout, ~{n0i0O});
	and(wire_nl0l_dataout, wire_n0O_dataout, ~{n0i0O});
	and(wire_nl0O_dataout, wire_nii_dataout, ~{n0i0O});
	and(wire_nl1i_dataout, wire_n1l_dataout, ~{n0i0O});
	and(wire_nl1l_dataout, wire_n1O_dataout, ~{n0i0O});
	and(wire_nl1O_dataout, wire_n0i_dataout, ~{n0i0O});
	assign		wire_nli_dataout = (n0i1O === 1'b1) ? niil : niiO;
	and(wire_nlii_dataout, wire_nil_dataout, ~{n0i0O});
	and(wire_nliil_dataout, wire_nlOli_dataout, ~{fiforesetrd});
	or(wire_nliiO_dataout, wire_nlOll_dataout, fiforesetrd);
	and(wire_nlil_dataout, wire_niO_dataout, ~{n0i0O});
	and(wire_nlili_dataout, wire_nlOlO_dataout, ~{fiforesetrd});
	and(wire_nlill_dataout, wire_nlOOi_dataout, ~{fiforesetrd});
	and(wire_nlilO_dataout, wire_nlOOl_dataout, ~{fiforesetrd});
	and(wire_nliO_dataout, wire_nli_dataout, ~{n0i0O});
	and(wire_nliOi_dataout, wire_nlOOO_dataout, ~{fiforesetrd});
	and(wire_nliOl_dataout, wire_n11i_dataout, ~{fiforesetrd});
	and(wire_nliOO_dataout, wire_n11l_dataout, ~{fiforesetrd});
	assign		wire_nll_dataout = (n0i1O === 1'b1) ? niiO : nili;
	and(wire_nll0i_dataout, wire_n10O_dataout, ~{fiforesetrd});
	and(wire_nll0l_dataout, wire_n1ii_dataout, ~{fiforesetrd});
	and(wire_nll0O_dataout, wire_n1il_dataout, ~{fiforesetrd});
	and(wire_nll1i_dataout, wire_n11O_dataout, ~{fiforesetrd});
	and(wire_nll1l_dataout, wire_n10i_dataout, ~{fiforesetrd});
	and(wire_nll1O_dataout, wire_n10l_dataout, ~{fiforesetrd});
	and(wire_nlli_dataout, wire_nll_dataout, ~{n0i0O});
	and(wire_nllii_dataout, wire_n1iO_dataout, ~{fiforesetrd});
	and(wire_nllil_dataout, wire_n1li_dataout, ~{fiforesetrd});
	or(wire_nlliO_dataout, wire_n1ll_dataout, fiforesetrd);
	and(wire_nlll_dataout, wire_nlO_dataout, ~{n0i0O});
	and(wire_nllli_dataout, wire_n1lO_dataout, ~{fiforesetrd});
	and(wire_nllll_dataout, wire_n1Oi_dataout, ~{fiforesetrd});
	and(wire_nlllO_dataout, wire_n1Ol_dataout, ~{fiforesetrd});
	and(wire_nllO_dataout, wire_ni_dataout, ~{n0i0O});
	and(wire_nllOi_dataout, wire_n1OO_dataout, ~{fiforesetrd});
	and(wire_nllOl_dataout, wire_n01i_dataout, ~{fiforesetrd});
	and(wire_nllOO_dataout, wire_n01l_dataout, ~{fiforesetrd});
	assign		wire_nlO_dataout = (n0i1O === 1'b1) ? nili : nill;
	and(wire_nlO0i_dataout, wire_n00O_dataout, ~{fiforesetrd});
	and(wire_nlO0l_dataout, wire_n0ii_dataout, ~{fiforesetrd});
	and(wire_nlO0O_dataout, wire_n0il_dataout, ~{fiforesetrd});
	and(wire_nlO1i_dataout, wire_n01O_dataout, ~{fiforesetrd});
	and(wire_nlO1l_dataout, wire_n00i_dataout, ~{fiforesetrd});
	and(wire_nlO1O_dataout, wire_n00l_dataout, ~{fiforesetrd});
	assign		wire_nlOi_dataout = (n0i1O === 1'b1) ? ni0li : ni0iO;
	and(wire_nlOii_dataout, wire_n0iO_dataout, ~{fiforesetrd});
	and(wire_nlOil_dataout, wire_n0li_dataout, ~{fiforesetrd});
	and(wire_nlOiO_dataout, wire_n0ll_dataout, ~{fiforesetrd});
	assign		wire_nlOl_dataout = (n0i1O === 1'b1) ? ni0iO : n0Oi;
	and(wire_nlOli_dataout, nl0il, (~ enabledeskew));
	or(wire_nlOll_dataout, nl1iO, ~{(~ enabledeskew)});
	and(wire_nlOlO_dataout, ni0ii, (~ enabledeskew));
	assign		wire_nlOO_dataout = (n0i1O === 1'b1) ? n0Oi : n0Ol;
	and(wire_nlOOi_dataout, nl1li, (~ enabledeskew));
	and(wire_nlOOl_dataout, nl1ll, (~ enabledeskew));
	and(wire_nlOOO_dataout, nl1lO, (~ enabledeskew));
	oper_add   nil1i
	( 
	.a({nil1O, nii1O, nii1l, nii1i, 1'b1}),
	.b({1'b1, 1'b1, 1'b1, 1'b0, 1'b1}),
	.cin(1'b0),
	.cout(),
	.o(wire_nil1i_o));
	defparam
		nil1i.sgate_representation = 0,
		nil1i.width_a = 5,
		nil1i.width_b = 5,
		nil1i.width_o = 5;
	assign
		adetectdeskew = ni0Ol,
		dataout = {nl1il, nl1ii, nl10O, nl10l, nl10i, nl11O, nl11l, nl11i, niOOO, niOOl},
		dataoutpre = {niOli, niOiO, niOil, niOii, niO0O, niO0l, niO0i, niO1O, niO1l, niO1i},
		disperr = niOll,
		disperrpre = nilOi,
		errdetect = niOOi,
		errdetectpre = nilOO,
		n00Oi = ((((nil1O | nii1O) | nii1l) | nii1i) | (~ w_n00Ol62w)),
		n0i0O = (((ni00l & ((ni0li & nilli) & w_n0ili4w)) | (ni00l & (~ ni00i))) | (~ w_n0iii12w)),
		n0i1O = ((nilli | wr_align) | (~ w_n0i0i18w)),
		n0iiO = writeclock,
		patterndetect = nillO,
		patterndetectpre = nilll,
		syncstatus = niOlO,
		syncstatuspre = nilOl,
		w_n00Ol62w = n00Ol15,
		w_n0i0i18w = n0i0i9,
		w_n0i1i56w = n0i1i12,
		w_n0iii12w = n0iii6,
		w_n0ili4w = n0ili3;
endmodule //altgxb_deskew_fifo_rtl
//synopsys translate_on
//VALID FILE
///////////////////////////////////////////////////////////////////////////////
//
//                            ALTGXB_DESKEW_FIFO
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ps/1 ps

   module altgxb_deskew_fifo
      (
       datain,
       errdetectin,
       syncstatusin,
       disperrin,   
       patterndetectin,   
       writeclock,  
       readclock,   
       adetectdeskew,
       fiforesetrd,
       enabledeskew,
       reset,
       dataout,      
       dataoutpre,      
       errdetect,    
       syncstatus,   
       disperr,
       patterndetect,
       errdetectpre,    
       syncstatuspre,
       disperrpre,
       patterndetectpre,
       rdalign
       );

   input [9:0] datain;        // encoded word
   input       errdetectin;   // From word aligner (if invalid_code)
   input       syncstatusin;  // From word aligner (not used)
   input       disperrin;     // From word aligner (not used)
   input       patterndetectin;
   input       writeclock;    // From recovered clock 
   input       readclock;     // From master clock
   input       fiforesetrd;   // reset read ptr 
   input       enabledeskew;  // enable the deskw fifo      
   input       reset;
   output [9:0] dataout;      // aligned data
   output [9:0] dataoutpre;   // aligned data
   output errdetect;          // straight output from invalid_code_in and synchronized with output
   output syncstatus;         // straight output from syncstatusin and synchronized with output
   output disperr;            // straight output from disperrin and synchronized with output
   output patterndetect;      // from word align 
   output errdetectpre;       // straight output from invalid_code_in and synchronized with output
   output syncstatuspre;      // straight output from syncstatusin and synchronized with output
   output disperrpre;         // straight output from disperrin and synchronized with output
   output patterndetectpre;   // from word align WARNING: CRITICAL TO ADD FUNCT
   output adetectdeskew;      // |A| is detected. It goes to input port adet of XGM_ATOM
   output rdalign;            // <deskew state machine |A| detect after read>
   
   parameter a = 10'b0011000011; //10'b0011110011;  - K28.3

   wire wr_align;
   wire wr_align_tmp;
   wire rdalign;
   wire rdalign_tmp;

   reg  enabledeskew_dly0;
   reg  enabledeskew_dly1;


   assign rdalign_tmp = ((dataout[9:0] == a) || (dataout[9:0] == ~a)) && ~disperr && ~errdetect;
   assign wr_align_tmp = ((datain[9:0] == a) || (datain[9:0] == ~a)) && enabledeskew_dly1 && ~disperrin && ~errdetectin;

   // filtering X
   assign wr_align = (wr_align_tmp === 1'b1) ? 1'b1 : 1'b0;
   assign rdalign = (rdalign_tmp === 1'b1) ? 1'b1 : 1'b0;

   
   // ENABLE DESKEW DELAY LOGIC - enable delay chain
   always@(posedge writeclock or posedge reset)
   begin
     if(reset)
	    begin
           enabledeskew_dly0 <= 1'b1;
           enabledeskew_dly1 <= 1'b1;
        end 
     else
        begin
           enabledeskew_dly0 <= enabledeskew;
           enabledeskew_dly1 <= enabledeskew_dly0;
        end
   end 
   

   // instantiate core
   altgxb_deskew_fifo_rtl m_dskw_fifo_rtl
   (
       .wr_align(wr_align),
       .datain(datain),
       .errdetectin(errdetectin),
       .syncstatusin(syncstatusin),
       .disperrin(disperrin),   
       .patterndetectin(patterndetectin),   
       .writeclock(writeclock),  
       .readclock(readclock),   
       .fiforesetrd(fiforesetrd),
       .enabledeskew(enabledeskew),
       .reset(reset),
       .adetectdeskew(adetectdeskew),
       .dataout(dataout),      
       .dataoutpre(dataoutpre),      
       .errdetect(errdetect),    
       .syncstatus(syncstatus),   
       .disperr(disperr),
       .patterndetect(patterndetect),
       .errdetectpre(errdetectpre),    
       .syncstatuspre(syncstatuspre),
       .disperrpre(disperrpre),
       .patterndetectpre(patterndetectpre)
   );
      
endmodule

//IP Functional Simulation Model
//VERSION_BEGIN 4.1 cbx_mgl 2004:06:17:17:30:06:SJ cbx_simgen 2004:06:22:10:53:08:SJ  VERSION_END


// Legal Notice: � 2003 Altera Corporation. All rights reserved.
// You may only use these  simulation  model  output files for simulation
// purposes and expressly not for synthesis or any other purposes (in which
// event  Altera disclaims all warranties of any kind). Your use of  Altera
// Corporation's design tools, logic functions and other software and tools,
// and its AMPP partner logic functions, and any output files any of the
// foregoing (including device programming or simulation files), and any
// associated documentation or information  are expressly subject to the
// terms and conditions of the  Altera Program License Subscription Agreement
// or other applicable license agreement, including, without limitation, that
// your use is for the sole purpose of programming logic devices manufactured
// by Altera and sold by Altera or its authorized distributors.  Please refer
// to the applicable agreement for further details.


//synopsys translate_off

//synthesis_resources = lut 289 mux21 285 oper_add 5 oper_decoder 10 oper_less_than 1 oper_selector 60 
`timescale 1 ps / 1 ps
module  altgxb_hssi_rx_wal_rtl
	( 
	A1A2_SIZE,
	AUTOBYTEALIGN_DIS,
	BITSLIP,
	cg_comma,
	DISABLE_RX_DISP,
	DWIDTH,
	encdet_prbs,
	ENCDT,
	GE_XAUI_SEL,
	IB_INVALID_CODE,
	LP10BEN,
	PMADATAWIDTH,
	prbs_en,
	PUDI,
	PUDR,
	rcvd_clk,
	RLV,
	RLV_EN,
	RLV_lt,
	RUNDISP_SEL,
	signal_detect,
	signal_detect_sync,
	soft_reset,
	SUDI,
	SUDI_pre,
	SYNC_COMP_PAT,
	SYNC_COMP_SIZE,
	sync_curr_st,
	SYNC_SM_DIS,
	sync_status) /* synthesis synthesis_clearbox=1 */;
	input   A1A2_SIZE;
	input   AUTOBYTEALIGN_DIS;
	input   BITSLIP;
	output   cg_comma;
	input   DISABLE_RX_DISP;
	input   DWIDTH;
	input   encdet_prbs;
	input   ENCDT;
	input   GE_XAUI_SEL;
	input   [1:0]  IB_INVALID_CODE;
	input   LP10BEN;
	input   PMADATAWIDTH;
	input   prbs_en;
	input   [9:0]  PUDI;
	input   [9:0]  PUDR;
	input   rcvd_clk;
	output   RLV;
	input   RLV_EN;
	output   RLV_lt;
	input   [4:0]  RUNDISP_SEL;
	input   signal_detect;
	output   signal_detect_sync;
	input   soft_reset;
	output   [12:0]  SUDI;
	output   [9:0]  SUDI_pre;
	input   [15:0]  SYNC_COMP_PAT;
	input   [1:0]  SYNC_COMP_SIZE;
	output   [3:0]  sync_curr_st;
	input   SYNC_SM_DIS;
	output   sync_status;

	reg	n0000i;
	reg	n0000l;
	reg	n0000O;
	reg	n0001i;
	reg	n0001l;
	reg	n0001O;
	reg	n0010i;
	reg	n0010l;
	reg	n0010O;
	reg	n001ii;
	reg	n001il;
	reg	n001iO;
	reg	n001li;
	reg	n001ll;
	reg	n001lO;
	reg	n001Oi;
	reg	n001Ol;
	reg	n001OO;
	reg	n0i00i;
	reg	n0i00l;
	reg	n0i00O;
	reg	n0i01i;
	reg	n0i01l;
	reg	n0i01O;
	reg	n0i0ii;
	reg	n0i0il;
	reg	n0i0iO;
	reg	n0i0li;
	reg	n0i0ll;
	reg	n0i0lO;
	reg	n0i0Oi;
	reg	n0i1Oi;
	reg	n0i1Ol;
	reg	n0i1OO;
	reg	n0iiOO;
	reg	n0il0i;
	reg	n0il0l;
	reg	n0il0O;
	reg	n0il1i;
	reg	n0il1l;
	reg	n0il1O;
	reg	n0ilii;
	reg	n1lO0l55;
	reg	n1lO0l56;
	reg	n1lO0l57;
	reg	n1lO1O58;
	reg	n1lO1O59;
	reg	n1lO1O60;
	reg	n1lOil52;
	reg	n1lOil53;
	reg	n1lOil54;
	reg	n1lOli49;
	reg	n1lOli50;
	reg	n1lOli51;
	reg	n1lOlO46;
	reg	n1lOlO47;
	reg	n1lOlO48;
	reg	n1lOOl43;
	reg	n1lOOl44;
	reg	n1lOOl45;
	reg	n1O00i16;
	reg	n1O00i17;
	reg	n1O00i18;
	reg	n1O00O13;
	reg	n1O00O14;
	reg	n1O00O15;
	reg	n1O01l19;
	reg	n1O01l20;
	reg	n1O01l21;
	reg	n1O0lO10;
	reg	n1O0lO11;
	reg	n1O0lO12;
	reg	n1O10i37;
	reg	n1O10i38;
	reg	n1O10i39;
	reg	n1O10O34;
	reg	n1O10O35;
	reg	n1O10O36;
	reg	n1O11i40;
	reg	n1O11i41;
	reg	n1O11i42;
	reg	n1O1il31;
	reg	n1O1il32;
	reg	n1O1il33;
	reg	n1O1li28;
	reg	n1O1li29;
	reg	n1O1li30;
	reg	n1O1Oi25;
	reg	n1O1Oi26;
	reg	n1O1Oi27;
	reg	n1O1OO22;
	reg	n1O1OO23;
	reg	n1O1OO24;
	reg	n1Oi0i7;
	reg	n1Oi0i8;
	reg	n1Oi0i9;
	reg	n1Oill4;
	reg	n1Oill5;
	reg	n1Oill6;
	reg	n1OiOi1;
	reg	n1OiOi2;
	reg	n1OiOi3;
	reg	n1Ol0i;
	reg	n1Ol0l;
	reg	n1Ol0O;
	reg	n1Olii;
	reg	n1Olil;
	reg	n1OliO;
	reg	n1OlOi;
	reg	ni0liO;
	reg	ni0lli;
	reg	ni0lll;
	reg	ni0llO;
	reg	ni0lOi;
	reg	ni0lOl;
	reg	ni0lOO;
	reg	ni0OOO;
	reg	ni1O0i;
	reg	ni1O0l;
	reg	ni1O0O;
	reg	ni1Oii;
	reg	ni1Oil;
	reg	ni1OiO;
	reg	ni1Oli;
	reg	ni1Oll;
	reg	ni1OlO;
	reg	nii11i;
	reg	nii11l;
	reg	nii11O;
	reg	nii1iO;
	reg	nii1li;
	reg	nii1ll;
	reg	nii1lO;
	reg	niiiOi;
	reg	niiiOl;
	reg	niiiOO;
	reg	niil0i;
	reg	niil0l;
	reg	niil0O;
	reg	niil1i;
	reg	niil1l;
	reg	niil1O;
	reg	niilii;
	reg	niilil;
	reg	niiliO;
	reg	niilli;
	reg	niilll;
	reg	niillO;
	reg	niiOOi;
	reg	niiOOl;
	reg	niiOOO;
	reg	nil10i;
	reg	nil10l;
	reg	nil10O;
	reg	nil11i;
	reg	nil11l;
	reg	nil11O;
	reg	nil1ii;
	reg	nil1il;
	reg	nil1iO;
	reg	nil1li;
	reg	nil1ll;
	reg	nilii;
	reg	nilil;
	reg	niliO;
	reg	nilli;
	reg	nilll;
	reg	nillO;
	reg	nilOi;
	reg	nilOl;
	reg	nilOO;
	reg	niO0i;
	reg	niO0l;
	reg	niO0O;
	reg	niO1i;
	reg	niO1l;
	reg	niO1O;
	reg	niOii;
	reg	niOil;
	reg	niOiO;
	reg	niOli;
	reg	niOll;
	reg	niOlO;
	reg	niOOi;
	reg	niOOl;
	reg	niOOO;
	reg	nl000i;
	reg	nl000l;
	reg	nl000O;
	reg	nl001i;
	reg	nl001l;
	reg	nl001O;
	reg	nl00ii;
	reg	nl00il;
	reg	nl00iO;
	reg	nl00li;
	reg	nl00ll;
	reg	nl00lO;
	reg	nl00Oi;
	reg	nl00Ol;
	reg	nl00OO;
	reg	nl010i;
	reg	nl010l;
	reg	nl010O;
	reg	nl011i;
	reg	nl011l;
	reg	nl011O;
	reg	nl01ii;
	reg	nl01il;
	reg	nl01iO;
	reg	nl01li;
	reg	nl01ll;
	reg	nl01lO;
	reg	nl01Oi;
	reg	nl01Ol;
	reg	nl01OO;
	reg	nl0i0i;
	reg	nl0i1i;
	reg	nl0i1l;
	reg	nl0i1O;
	reg	nl10i;
	reg	nl10l;
	reg	nl10O;
	reg	nl11i;
	reg	nl11l;
	reg	nl11O;
	reg	nl1i0i;
	reg	nl1i0l;
	reg	nl1i0O;
	reg	nl1ii;
	reg	nl1iii;
	reg	nl1iil;
	reg	nl1iiO;
	reg	nl1il;
	reg	nl1ili;
	reg	nl1ill;
	reg	nl1iO;
	reg	nl1li;
	reg	nl1ll;
	reg	nl1lO;
	reg	nl1O0O;
	reg	nl1Oi;
	reg	nl1Oii;
	reg	nl1Oil;
	reg	nl1OiO;
	reg	nl1Ol;
	reg	nl1Oli;
	reg	nl1Oll;
	reg	nl1OlO;
	reg	nl1OO;
	reg	nl1OOi;
	reg	nl1OOl;
	reg	nl1OOO;
	reg	nli00i;
	reg	nli00l;
	reg	nli01i;
	reg	nli01l;
	reg	nli01O;
	reg	nli1ll;
	reg	nli1lO;
	reg	nli1Oi;
	reg	nli1Ol;
	reg	nli1OO;
	reg	nliilO;
	reg	nliiOi;
	reg	nliiOl;
	reg	nliiOO;
	reg	nlil0i;
	reg	nlil0l;
	reg	nlil1l;
	reg	nlil1O;
	reg	nlilO;
	reg	nliO1O;
	reg	nliOi;
	reg	nliOll;
	reg	nliOlO;
	reg	nliOOi;
	reg	nliOOl;
	reg	nliOOO;
	reg	nll10i;
	reg	nll10l;
	reg	nll10O;
	reg	nll11i;
	reg	nll11l;
	reg	nll11O;
	reg	nll1ii;
	reg	nll1il;
	reg	nll1iO;
	reg	nlllO;
	wire	wire_n0011i_dataout;
	wire	wire_n0011l_dataout;
	wire	wire_n00iil_dataout;
	wire	wire_n00iOO_dataout;
	wire	wire_n00lii_dataout;
	wire	wire_n00lOl_dataout;
	wire	wire_n00O0O_dataout;
	wire	wire_n00OOi_dataout;
	wire	wire_n0101i_dataout;
	wire	wire_n0101l_dataout;
	wire	wire_n0101O_dataout;
	wire	wire_n010ii_dataout;
	wire	wire_n010il_dataout;
	wire	wire_n010iO_dataout;
	wire	wire_n010ll_dataout;
	wire	wire_n010lO_dataout;
	wire	wire_n010Oi_dataout;
	wire	wire_n010Ol_dataout;
	wire	wire_n010OO_dataout;
	wire	wire_n011OO_dataout;
	wire	wire_n01i0i_dataout;
	wire	wire_n01i0l_dataout;
	wire	wire_n01i0O_dataout;
	wire	wire_n01i1i_dataout;
	wire	wire_n01i1O_dataout;
	wire	wire_n01iii_dataout;
	wire	wire_n01iil_dataout;
	wire	wire_n01iiO_dataout;
	wire	wire_n01ili_dataout;
	wire	wire_n01ill_dataout;
	wire	wire_n01ilO_dataout;
	wire	wire_n01iOl_dataout;
	wire	wire_n01iOO_dataout;
	wire	wire_n01l0i_dataout;
	wire	wire_n01l0l_dataout;
	wire	wire_n01l1i_dataout;
	wire	wire_n01l1l_dataout;
	wire	wire_n01l1O_dataout;
	wire	wire_n01lOl_dataout;
	wire	wire_n01lOO_dataout;
	wire	wire_n01O0i_dataout;
	wire	wire_n01O0l_dataout;
	wire	wire_n01O0O_dataout;
	wire	wire_n01O1O_dataout;
	wire	wire_n01Oii_dataout;
	wire	wire_n01Oli_dataout;
	wire	wire_n01Oll_dataout;
	wire	wire_n01OlO_dataout;
	wire	wire_n01OOi_dataout;
	wire	wire_n01OOl_dataout;
	wire	wire_n01OOO_dataout;
	wire	wire_n0i10l_dataout;
	wire	wire_n0i1lO_dataout;
	wire	wire_n0liil_dataout;
	wire	wire_n0lil_dataout;
	wire	wire_n0liO_dataout;
	wire	wire_n0lli_dataout;
	wire	wire_n0lll_dataout;
	wire	wire_n0llO_dataout;
	wire	wire_n0lOi_dataout;
	wire	wire_n0lOl_dataout;
	wire	wire_n0lOO_dataout;
	wire	wire_n0O0i_dataout;
	wire	wire_n0O0l_dataout;
	wire	wire_n0O0O_dataout;
	wire	wire_n0O1i_dataout;
	wire	wire_n0O1l_dataout;
	wire	wire_n0O1O_dataout;
	wire	wire_n0Oii_dataout;
	wire	wire_n0Oil_dataout;
	wire	wire_n0OiO_dataout;
	wire	wire_n0Oli_dataout;
	wire	wire_n0Oll_dataout;
	wire	wire_n0OlO_dataout;
	wire	wire_n0OOi_dataout;
	wire	wire_n0OOl_dataout;
	wire	wire_n0OOO_dataout;
	wire	wire_n1Olli_dataout;
	wire	wire_n1Olll_dataout;
	wire	wire_n1OllO_dataout;
	wire	wire_ni000i_dataout;
	wire	wire_ni000l_dataout;
	wire	wire_ni000O_dataout;
	wire	wire_ni00i_dataout;
	wire	wire_ni00l_dataout;
	wire	wire_ni00O_dataout;
	wire	wire_ni00Ol_dataout;
	wire	wire_ni00OO_dataout;
	wire	wire_ni010i_dataout;
	wire	wire_ni010l_dataout;
	wire	wire_ni010O_dataout;
	wire	wire_ni011i_dataout;
	wire	wire_ni01i_dataout;
	wire	wire_ni01ii_dataout;
	wire	wire_ni01l_dataout;
	wire	wire_ni01O_dataout;
	wire	wire_ni0i0i_dataout;
	wire	wire_ni0i0l_dataout;
	wire	wire_ni0i0O_dataout;
	wire	wire_ni0i1i_dataout;
	wire	wire_ni0i1l_dataout;
	wire	wire_ni0i1O_dataout;
	wire	wire_ni0ii_dataout;
	wire	wire_ni0iii_dataout;
	wire	wire_ni0il_dataout;
	wire	wire_ni0ili_dataout;
	wire	wire_ni0ill_dataout;
	wire	wire_ni0ilO_dataout;
	wire	wire_ni0iO_dataout;
	wire	wire_ni0iOi_dataout;
	wire	wire_ni0iOO_dataout;
	wire	wire_ni0l0i_dataout;
	wire	wire_ni0l1i_dataout;
	wire	wire_ni0l1l_dataout;
	wire	wire_ni0l1O_dataout;
	wire	wire_ni0li_dataout;
	wire	wire_ni0lii_dataout;
	wire	wire_ni0lil_dataout;
	wire	wire_ni0ll_dataout;
	wire	wire_ni0lO_dataout;
	wire	wire_ni0O0i_dataout;
	wire	wire_ni0O0l_dataout;
	wire	wire_ni0O0O_dataout;
	wire	wire_ni0O1i_dataout;
	wire	wire_ni0O1l_dataout;
	wire	wire_ni0O1O_dataout;
	wire	wire_ni0Oi_dataout;
	wire	wire_ni0Oii_dataout;
	wire	wire_ni0Oil_dataout;
	wire	wire_ni0Ol_dataout;
	wire	wire_ni0OO_dataout;
	wire	wire_ni10i_dataout;
	wire	wire_ni10l_dataout;
	wire	wire_ni10O_dataout;
	wire	wire_ni11i_dataout;
	wire	wire_ni11l_dataout;
	wire	wire_ni11O_dataout;
	wire	wire_ni11Oi_dataout;
	wire	wire_ni1ii_dataout;
	wire	wire_ni1il_dataout;
	wire	wire_ni1iO_dataout;
	wire	wire_ni1li_dataout;
	wire	wire_ni1ll_dataout;
	wire	wire_ni1lO_dataout;
	wire	wire_ni1Oi_dataout;
	wire	wire_ni1Ol_dataout;
	wire	wire_ni1OO_dataout;
	wire	wire_ni1OOi_dataout;
	wire	wire_ni1OOl_dataout;
	wire	wire_ni1OOO_dataout;
	wire	wire_nii0i_dataout;
	wire	wire_nii0l_dataout;
	wire	wire_nii0O_dataout;
	wire	wire_nii10i_dataout;
	wire	wire_nii10l_dataout;
	wire	wire_nii10O_dataout;
	wire	wire_nii1i_dataout;
	wire	wire_nii1ii_dataout;
	wire	wire_nii1l_dataout;
	wire	wire_nii1O_dataout;
	wire	wire_niiii_dataout;
	wire	wire_niiil_dataout;
	wire	wire_niiili_dataout;
	wire	wire_niiiO_dataout;
	wire	wire_niili_dataout;
	wire	wire_niill_dataout;
	wire	wire_niilO_dataout;
	wire	wire_niilOi_dataout;
	wire	wire_niilOl_dataout;
	wire	wire_niilOO_dataout;
	wire	wire_niiO0i_dataout;
	wire	wire_niiO0l_dataout;
	wire	wire_niiO0O_dataout;
	wire	wire_niiO1i_dataout;
	wire	wire_niiO1l_dataout;
	wire	wire_niiO1O_dataout;
	wire	wire_niiOi_dataout;
	wire	wire_niiOii_dataout;
	wire	wire_niiOil_dataout;
	wire	wire_niiOiO_dataout;
	wire	wire_niiOl_dataout;
	wire	wire_niiOli_dataout;
	wire	wire_niiOll_dataout;
	wire	wire_niiOlO_dataout;
	wire	wire_nil00i_dataout;
	wire	wire_nil00l_dataout;
	wire	wire_nil00O_dataout;
	wire	wire_nil01i_dataout;
	wire	wire_nil01l_dataout;
	wire	wire_nil01O_dataout;
	wire	wire_nil0i_dataout;
	wire	wire_nil0ii_dataout;
	wire	wire_nil0il_dataout;
	wire	wire_nil0iO_dataout;
	wire	wire_nil0l_dataout;
	wire	wire_nil0li_dataout;
	wire	wire_nil0O_dataout;
	wire	wire_nil1l_dataout;
	wire	wire_nil1lO_dataout;
	wire	wire_nil1O_dataout;
	wire	wire_nil1Oi_dataout;
	wire	wire_nil1Ol_dataout;
	wire	wire_nil1OO_dataout;
	wire	wire_nl00i_dataout;
	wire	wire_nl00l_dataout;
	wire	wire_nl00O_dataout;
	wire	wire_nl01i_dataout;
	wire	wire_nl01l_dataout;
	wire	wire_nl01O_dataout;
	wire	wire_nl0ii_dataout;
	wire	wire_nl0il_dataout;
	wire	wire_nl0iO_dataout;
	wire	wire_nl0iOl_dataout;
	wire	wire_nl0iOO_dataout;
	wire	wire_nl0l0i_dataout;
	wire	wire_nl0l0l_dataout;
	wire	wire_nl0l0O_dataout;
	wire	wire_nl0l1i_dataout;
	wire	wire_nl0l1l_dataout;
	wire	wire_nl0l1O_dataout;
	wire	wire_nl0li_dataout;
	wire	wire_nl0lii_dataout;
	wire	wire_nl0lil_dataout;
	wire	wire_nl0liO_dataout;
	wire	wire_nl0ll_dataout;
	wire	wire_nl0lli_dataout;
	wire	wire_nl0lll_dataout;
	wire	wire_nl0llO_dataout;
	wire	wire_nl0lO_dataout;
	wire	wire_nl0lOi_dataout;
	wire	wire_nl0lOl_dataout;
	wire	wire_nl0lOO_dataout;
	wire	wire_nl0O1i_dataout;
	wire	wire_nl0O1l_dataout;
	wire	wire_nl0O1O_dataout;
	wire	wire_nl0Oi_dataout;
	wire	wire_nl0Oil_dataout;
	wire	wire_nl0OiO_dataout;
	wire	wire_nl0Ol_dataout;
	wire	wire_nl0Oli_dataout;
	wire	wire_nl0Oll_dataout;
	wire	wire_nl0OlO_dataout;
	wire	wire_nl0OO_dataout;
	wire	wire_nl0OOi_dataout;
	wire	wire_nl0OOl_dataout;
	wire	wire_nl0OOO_dataout;
	wire	wire_nli0i_dataout;
	wire	wire_nli0l_dataout;
	wire	wire_nli0O_dataout;
	wire	wire_nli1i_dataout;
	wire	wire_nli1l_dataout;
	wire	wire_nli1O_dataout;
	wire	wire_nliii_dataout;
	wire	wire_nliil_dataout;
	wire	wire_nliiO_dataout;
	wire	wire_nlil0O_dataout;
	wire	wire_nlili_dataout;
	wire	wire_nlilii_dataout;
	wire	wire_nlilil_dataout;
	wire	wire_nliliO_dataout;
	wire	wire_nlill_dataout;
	wire	wire_nlilli_dataout;
	wire	wire_nlilll_dataout;
	wire	wire_nlillO_dataout;
	wire	wire_nlilOi_dataout;
	wire	wire_nll0i_dataout;
	wire	wire_nll0l_dataout;
	wire	wire_nll0ll_dataout;
	wire	wire_nll0lO_dataout;
	wire	wire_nll0O_dataout;
	wire	wire_nll0Oi_dataout;
	wire	wire_nll0Ol_dataout;
	wire	wire_nll0OO_dataout;
	wire	wire_nll1O_dataout;
	wire	wire_nlli0i_dataout;
	wire	wire_nlli1l_dataout;
	wire	wire_nllii_dataout;
	wire	wire_nlliii_dataout;
	wire	wire_nllil_dataout;
	wire	wire_nllili_dataout;
	wire	wire_nlliOi_dataout;
	wire	wire_nlll0i_dataout;
	wire	wire_nlll1i_dataout;
	wire	wire_nlllii_dataout;
	wire	wire_nlllli_dataout;
	wire  [1:0]   wire_n01iOi_o;
	wire  [3:0]   wire_ni011l_o;
	wire  [4:0]   wire_ni011O_o;
	wire  [5:0]   wire_ni0OiO_o;
	wire  [4:0]   wire_nlilOl_o;
	wire  [3:0]   wire_n00iii_o;
	wire  [3:0]   wire_n00iOl_o;
	wire  [3:0]   wire_n00l0O_o;
	wire  [3:0]   wire_n00lOi_o;
	wire  [3:0]   wire_n00O0l_o;
	wire  [3:0]   wire_n00OlO_o;
	wire  [3:0]   wire_n0i10i_o;
	wire  [3:0]   wire_n0i1ll_o;
	wire  [3:0]   wire_nli1li_o;
	wire  [31:0]   wire_nliill_o;
	wire  wire_nii1il_o;
	wire  wire_n00i0l_o;
	wire  wire_n00ilO_o;
	wire  wire_n00l0i_o;
	wire  wire_n00lll_o;
	wire  wire_n00O1O_o;
	wire  wire_n00Oli_o;
	wire  wire_n0110i_o;
	wire  wire_n0110O_o;
	wire  wire_n0111l_o;
	wire  wire_n011il_o;
	wire  wire_n011li_o;
	wire  wire_n011ll_o;
	wire  wire_n011Oi_o;
	wire  wire_n0i11l_o;
	wire  wire_n0i1iO_o;
	wire  wire_n1OlOl_o;
	wire  wire_n1OlOO_o;
	wire  wire_n1OO0i_o;
	wire  wire_n1OO0l_o;
	wire  wire_n1OO0O_o;
	wire  wire_n1OO1l_o;
	wire  wire_n1OOii_o;
	wire  wire_n1OOiO_o;
	wire  wire_n1OOll_o;
	wire  wire_n1OOOi_o;
	wire  wire_n1OOOO_o;
	wire  wire_ni001i_o;
	wire  wire_ni00ii_o;
	wire  wire_ni00il_o;
	wire  wire_ni00li_o;
	wire  wire_ni00lO_o;
	wire  wire_ni01iO_o;
	wire  wire_ni01li_o;
	wire  wire_ni01ll_o;
	wire  wire_ni01lO_o;
	wire  wire_ni01Oi_o;
	wire  wire_ni01Ol_o;
	wire  wire_ni01OO_o;
	wire  wire_nli00O_o;
	wire  wire_nli0ii_o;
	wire  wire_nli0il_o;
	wire  wire_nli0iO_o;
	wire  wire_nli0li_o;
	wire  wire_nli0ll_o;
	wire  wire_nli0lO_o;
	wire  wire_nli0Oi_o;
	wire  wire_nli10i_o;
	wire  wire_nli10l_o;
	wire  wire_nli10O_o;
	wire  wire_nli11i_o;
	wire  wire_nli11l_o;
	wire  wire_nli11O_o;
	wire  wire_nli1ii_o;
	wire  wire_nli1il_o;
	wire  wire_nliiii_o;
	wire  wire_nliiil_o;
	wire  wire_nliOl_o;
	wire  wire_nliOO_o;
	wire  wire_nll1i_o;
	wire  wire_nll1l_o;
	wire  n1000i;
	wire  n1000l;
	wire  n1000O;
	wire  n1001i;
	wire  n1001l;
	wire  n1001O;
	wire  n100ii;
	wire  n100il;
	wire  n100iO;
	wire  n100li;
	wire  n100ll;
	wire  n100lO;
	wire  n100Oi;
	wire  n100Ol;
	wire  n100OO;
	wire  n1010i;
	wire  n1010l;
	wire  n1010O;
	wire  n1011i;
	wire  n1011l;
	wire  n1011O;
	wire  n101ii;
	wire  n101il;
	wire  n101iO;
	wire  n101li;
	wire  n101ll;
	wire  n101lO;
	wire  n101Oi;
	wire  n101Ol;
	wire  n101OO;
	wire  n10i0i;
	wire  n10i0l;
	wire  n10i0O;
	wire  n10i1i;
	wire  n10i1l;
	wire  n10i1O;
	wire  n10iii;
	wire  n10iil;
	wire  n10iiO;
	wire  n10ili;
	wire  n10ill;
	wire  n10ilO;
	wire  n10iOi;
	wire  n10iOl;
	wire  n10iOO;
	wire  n10l0i;
	wire  n10l0l;
	wire  n10l0O;
	wire  n10l1i;
	wire  n10l1l;
	wire  n10l1O;
	wire  n10lii;
	wire  n10lil;
	wire  n10liO;
	wire  n10lli;
	wire  n10lll;
	wire  n10llO;
	wire  n10lOi;
	wire  n10lOl;
	wire  n10lOO;
	wire  n10O0i;
	wire  n10O0l;
	wire  n10O0O;
	wire  n10O1i;
	wire  n10O1l;
	wire  n10O1O;
	wire  n10Oii;
	wire  n10Oil;
	wire  n10OiO;
	wire  n10Oli;
	wire  n10Oll;
	wire  n10OlO;
	wire  n10OOi;
	wire  n10OOl;
	wire  n10OOO;
	wire  n11l0l;
	wire  n11l0O;
	wire  n11lii;
	wire  n11lil;
	wire  n11liO;
	wire  n11lli;
	wire  n11lll;
	wire  n11llO;
	wire  n11lOi;
	wire  n11lOl;
	wire  n11lOO;
	wire  n11O0i;
	wire  n11O0l;
	wire  n11O0O;
	wire  n11O1i;
	wire  n11O1l;
	wire  n11O1O;
	wire  n11Oii;
	wire  n11Oil;
	wire  n11OiO;
	wire  n11Oli;
	wire  n11Oll;
	wire  n11OlO;
	wire  n11OOi;
	wire  n11OOl;
	wire  n11OOO;
	wire  n1i00i;
	wire  n1i00l;
	wire  n1i00O;
	wire  n1i01i;
	wire  n1i01l;
	wire  n1i01O;
	wire  n1i0ii;
	wire  n1i0il;
	wire  n1i0iO;
	wire  n1i0li;
	wire  n1i0ll;
	wire  n1i0lO;
	wire  n1i0Oi;
	wire  n1i0Ol;
	wire  n1i0OO;
	wire  n1i10i;
	wire  n1i10l;
	wire  n1i10O;
	wire  n1i11i;
	wire  n1i11l;
	wire  n1i11O;
	wire  n1i1ii;
	wire  n1i1il;
	wire  n1i1iO;
	wire  n1i1li;
	wire  n1i1ll;
	wire  n1i1lO;
	wire  n1i1Oi;
	wire  n1i1Ol;
	wire  n1i1OO;
	wire  n1ii0i;
	wire  n1ii0l;
	wire  n1ii0O;
	wire  n1ii1i;
	wire  n1ii1l;
	wire  n1ii1O;
	wire  n1iiii;
	wire  n1iiil;
	wire  n1iiiO;
	wire  n1iili;
	wire  n1iill;
	wire  n1iilO;
	wire  n1iiOi;
	wire  n1iiOl;
	wire  n1iiOO;
	wire  n1il0i;
	wire  n1il0l;
	wire  n1il0O;
	wire  n1il1i;
	wire  n1il1l;
	wire  n1il1O;
	wire  n1ilii;
	wire  n1ilil;
	wire  n1iliO;
	wire  n1illi;
	wire  n1illl;
	wire  n1illO;
	wire  n1ilOi;
	wire  n1ilOl;
	wire  n1ilOO;
	wire  n1iO0i;
	wire  n1iO0l;
	wire  n1iO0O;
	wire  n1iO1i;
	wire  n1iO1l;
	wire  n1iO1O;
	wire  n1iOii;
	wire  n1iOil;
	wire  n1iOiO;
	wire  n1iOli;
	wire  n1iOll;
	wire  n1iOlO;
	wire  n1iOOi;
	wire  n1iOOl;
	wire  n1iOOO;
	wire  n1l00i;
	wire  n1l00l;
	wire  n1l00O;
	wire  n1l01i;
	wire  n1l01l;
	wire  n1l01O;
	wire  n1l0ii;
	wire  n1l0il;
	wire  n1l0iO;
	wire  n1l0li;
	wire  n1l0ll;
	wire  n1l0lO;
	wire  n1l0Oi;
	wire  n1l0Ol;
	wire  n1l0OO;
	wire  n1l10i;
	wire  n1l10l;
	wire  n1l10O;
	wire  n1l11i;
	wire  n1l11l;
	wire  n1l11O;
	wire  n1l1ii;
	wire  n1l1il;
	wire  n1l1iO;
	wire  n1l1li;
	wire  n1l1ll;
	wire  n1l1lO;
	wire  n1l1Oi;
	wire  n1l1Ol;
	wire  n1l1OO;
	wire  n1li0i;
	wire  n1li0l;
	wire  n1li0O;
	wire  n1li1i;
	wire  n1li1l;
	wire  n1li1O;
	wire  n1liii;
	wire  n1liil;
	wire  n1liiO;
	wire  n1lili;
	wire  n1lill;
	wire  n1lilO;
	wire  n1liOi;
	wire  n1liOl;
	wire  n1liOO;
	wire  n1ll0i;
	wire  n1ll0l;
	wire  n1ll0O;
	wire  n1ll1i;
	wire  n1ll1l;
	wire  n1ll1O;
	wire  n1llii;
	wire  n1llil;
	wire  n1lliO;
	wire  n1llli;
	wire  n1llll;
	wire  n1lllO;
	wire  n1llOi;
	wire  n1llOl;
	wire  n1llOO;
	wire  n1lO1i;
	wire  n1lO1l;
	wire  n1lOii;
	wire  n1O0il;
	wire  n1O0iO;
	wire  n1O0li;
	wire  n1O0ll;
	wire  n1O0Ol;
	wire  n1O0OO;
	wire  n1O11O;
	wire  n1O1lO;
	wire  n1Oi0O;
	wire  n1Oi1i;
	wire  n1Oi1l;
	wire  n1Oi1O;
	wire  n1Oiii;
	wire  n1Oiil;
	wire  n1OiiO;
	wire  n1Oili;
	wire  n1OiOO;
	wire  n1Ol1O;
	wire  w_n1lO0l284w;
	wire  w_n1lO1O291w;
	wire  w_n1lOil274w;
	wire  w_n1lOli265w;
	wire  w_n1lOlO252w;
	wire  w_n1lOOl245w;
	wire  w_n1O00i166w;
	wire  w_n1O00O157w;
	wire  w_n1O01l173w;
	wire  w_n1O0lO58w;
	wire  w_n1O10i228w;
	wire  w_n1O10O217w;
	wire  w_n1O11i239w;
	wire  w_n1O1il210w;
	wire  w_n1O1li200w;
	wire  w_n1O1Oi194w;
	wire  w_n1O1OO184w;
	wire  w_n1Oi0i50w;
	wire  w_n1Oill36w;
	wire  w_n1OiOi29w;

	initial
		n0000i = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0000i <= 1'b0;
		else   n0000i <= n0000l;
	initial
		n0000l = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0000l <= 1'b0;
		else   n0000l <= prbs_en;
	initial
		n0000O = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0000O <= 1'b0;
		else   n0000O <= n1Olii;
	initial
		n0001i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0001i <= 1'b0;
		else   n0001i <= wire_n011Oi_o;
	initial
		n0001l = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0001l <= 1'b0;
		else   n0001l <= ((~ SYNC_SM_DIS) & (LP10BEN | signal_detect));
	initial
		n0001O = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0001O <= 1'b0;
		else   n0001O <= n0001l;
	initial
		n0010i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0010i <= 1'b0;
		else   n0010i <= wire_n1OlOO_o;
	initial
		n0010l = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0010l <= 1'b0;
		else   n0010l <= wire_n1OOii_o;
	initial
		n0010O = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0010O <= 1'b0;
		else   n0010O <= wire_n1OOiO_o;
	initial
		n001ii = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n001ii <= 1'b0;
		else   n001ii <= wire_n1OOll_o;
	initial
		n001il = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n001il <= 1'b0;
		else   n001il <= wire_n1OOOi_o;
	initial
		n001iO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n001iO <= 1'b0;
		else   n001iO <= wire_n1OOOO_o;
	initial
		n001li = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n001li <= 1'b0;
		else   n001li <= wire_n0111l_o;
	initial
		n001ll = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n001ll <= 1'b0;
		else   n001ll <= wire_n0110i_o;
	initial
		n001lO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n001lO <= 1'b0;
		else   n001lO <= wire_n0110O_o;
	initial
		n001Oi = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n001Oi <= 1'b0;
		else   n001Oi <= wire_n011il_o;
	initial
		n001Ol = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n001Ol <= 1'b0;
		else   n001Ol <= wire_n011li_o;
	initial
		n001OO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n001OO <= 1'b0;
		else   n001OO <= wire_n011ll_o;
	initial
		n0i00i = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0i00i <= 1'b0;
		else   n0i00i <= wire_n00Oli_o;
	initial
		n0i00l = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0i00l <= 1'b0;
		else   n0i00l <= (~ n1lllO);
	initial
		n0i00O = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0i00O <= 1'b0;
		else   n0i00O <= wire_n00O1O_o;
	initial
		n0i01i = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0i01i <= 1'b0;
		else   n0i01i <= (~ n1llil);
	initial
		n0i01l = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0i01l <= 1'b0;
		else   n0i01l <= wire_n0i11l_o;
	initial
		n0i01O = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0i01O <= 1'b0;
		else   n0i01O <= (~ n1llli);
	initial
		n0i0ii = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0i0ii <= 1'b0;
		else   n0i0ii <= (~ n1llOl);
	initial
		n0i0il = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0i0il <= 1'b0;
		else   n0i0il <= wire_n00lll_o;
	initial
		n0i0iO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0i0iO <= 1'b0;
		else   n0i0iO <= (~ n1lO1i);
	initial
		n0i0li = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0i0li <= 1'b0;
		else   n0i0li <= wire_n00l0i_o;
	initial
		n0i0ll = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0i0ll <= 1'b0;
		else   n0i0ll <= (~ n1lOii);
	initial
		n0i0lO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0i0lO <= 1'b0;
		else   n0i0lO <= wire_n00ilO_o;
	initial
		n0i0Oi = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0i0Oi <= 1'b0;
		else   n0i0Oi <= (~ n1O1lO);
	initial
		n0i1Oi = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0i1Oi <= 1'b0;
		else   n0i1Oi <= (~ n1ll0O);
	initial
		n0i1Ol = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0i1Ol <= 1'b0;
		else   n0i1Ol <= (~ n1ll0O);
	initial
		n0i1OO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0i1OO <= 1'b0;
		else   n0i1OO <= wire_n0i1iO_o;
	initial
		n0iiOO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0iiOO <= 1'b0;
		else   n0iiOO <= wire_n00i0l_o;
	initial
		n0il0i = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0il0i <= 1'b0;
		else   n0il0i <= (~ n1llOl);
	initial
		n0il0l = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0il0l <= 1'b0;
		else   n0il0l <= (~ n1lllO);
	initial
		n0il0O = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0il0O <= 1'b0;
		else   n0il0O <= (~ n1llli);
	initial
		n0il1i = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0il1i <= 1'b0;
		else   n0il1i <= (~ n1O1lO);
	initial
		n0il1l = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0il1l <= 1'b0;
		else   n0il1l <= (~ n1lOii);
	initial
		n0il1O = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0il1O <= 1'b0;
		else   n0il1O <= (~ n1lO1i);
	initial
		n0ilii = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n0ilii <= 1'b0;
		else   n0ilii <= (~ n1llil);
	initial
		n1lO0l55 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1lO0l55 <= n1lO0l56;
	initial
		n1lO0l56 = 0;
	always @ ( posedge n1Ol1O)
		  n1lO0l56 <= n1lO0l55;
	initial
		n1lO0l57 = 0;
	always @ ( posedge n1Ol1O)
		  n1lO0l57 <= (n1lO0l56 ^ n1lO0l55);
	initial
		n1lO1O58 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1lO1O58 <= n1lO1O59;
	initial
		n1lO1O59 = 0;
	always @ ( posedge n1Ol1O)
		  n1lO1O59 <= n1lO1O58;
	initial
		n1lO1O60 = 0;
	always @ ( posedge n1Ol1O)
		  n1lO1O60 <= (n1lO1O59 ^ n1lO1O58);
	initial
		n1lOil52 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1lOil52 <= n1lOil53;
	initial
		n1lOil53 = 0;
	always @ ( posedge n1Ol1O)
		  n1lOil53 <= n1lOil52;
	initial
		n1lOil54 = 0;
	always @ ( posedge n1Ol1O)
		  n1lOil54 <= (n1lOil53 ^ n1lOil52);
	initial
		n1lOli49 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1lOli49 <= n1lOli50;
	initial
		n1lOli50 = 0;
	always @ ( posedge n1Ol1O)
		  n1lOli50 <= n1lOli49;
	initial
		n1lOli51 = 0;
	always @ ( posedge n1Ol1O)
		  n1lOli51 <= (n1lOli50 ^ n1lOli49);
	initial
		n1lOlO46 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1lOlO46 <= n1lOlO47;
	initial
		n1lOlO47 = 0;
	always @ ( posedge n1Ol1O)
		  n1lOlO47 <= n1lOlO46;
	initial
		n1lOlO48 = 0;
	always @ ( posedge n1Ol1O)
		  n1lOlO48 <= (n1lOlO47 ^ n1lOlO46);
	initial
		n1lOOl43 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1lOOl43 <= n1lOOl44;
	initial
		n1lOOl44 = 0;
	always @ ( posedge n1Ol1O)
		  n1lOOl44 <= n1lOOl43;
	initial
		n1lOOl45 = 0;
	always @ ( posedge n1Ol1O)
		  n1lOOl45 <= (n1lOOl44 ^ n1lOOl43);
	initial
		n1O00i16 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1O00i16 <= n1O00i17;
	initial
		n1O00i17 = 0;
	always @ ( posedge n1Ol1O)
		  n1O00i17 <= n1O00i16;
	initial
		n1O00i18 = 0;
	always @ ( posedge n1Ol1O)
		  n1O00i18 <= (n1O00i17 ^ n1O00i16);
	initial
		n1O00O13 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1O00O13 <= n1O00O14;
	initial
		n1O00O14 = 0;
	always @ ( posedge n1Ol1O)
		  n1O00O14 <= n1O00O13;
	initial
		n1O00O15 = 0;
	always @ ( posedge n1Ol1O)
		  n1O00O15 <= (n1O00O14 ^ n1O00O13);
	initial
		n1O01l19 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1O01l19 <= n1O01l20;
	initial
		n1O01l20 = 0;
	always @ ( posedge n1Ol1O)
		  n1O01l20 <= n1O01l19;
	initial
		n1O01l21 = 0;
	always @ ( posedge n1Ol1O)
		  n1O01l21 <= (n1O01l20 ^ n1O01l19);
	initial
		n1O0lO10 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1O0lO10 <= n1O0lO11;
	initial
		n1O0lO11 = 0;
	always @ ( posedge n1Ol1O)
		  n1O0lO11 <= n1O0lO10;
	initial
		n1O0lO12 = 0;
	always @ ( posedge n1Ol1O)
		  n1O0lO12 <= (n1O0lO11 ^ 
		n1O0lO10);
	initial
		n1O10i37 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1O10i37 <= n1O10i38;
	initial
		n1O10i38 = 0;
	always @ ( posedge n1Ol1O)
		  n1O10i38 <= n1O10i37;
	initial
		n1O10i39 = 0;
	always @ ( posedge n1Ol1O)
		  n1O10i39 <= (n1O10i38 ^ n1O10i37);
	initial
		n1O10O34 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1O10O34 <= n1O10O35;
	initial
		n1O10O35 = 0;
	always @ ( posedge n1Ol1O)
		  n1O10O35 <= n1O10O34;
	initial
		n1O10O36 = 0;
	always @ ( posedge n1Ol1O)
		  n1O10O36 <= (n1O10O35 ^ n1O10O34);
	initial
		n1O11i40 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1O11i40 <= n1O11i41;
	initial
		n1O11i41 = 0;
	always @ ( posedge n1Ol1O)
		  n1O11i41 <= n1O11i40;
	initial
		n1O11i42 = 0;
	always @ ( posedge n1Ol1O)
		  n1O11i42 <= (n1O11i41 ^ n1O11i40);
	initial
		n1O1il31 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1O1il31 <= n1O1il32;
	initial
		n1O1il32 = 0;
	always @ ( posedge n1Ol1O)
		  n1O1il32 <= n1O1il31;
	initial
		n1O1il33 = 0;
	always @ ( posedge n1Ol1O)
		  n1O1il33 <= (n1O1il32 ^ n1O1il31);
	initial
		n1O1li28 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1O1li28 <= n1O1li29;
	initial
		n1O1li29 = 0;
	always @ ( posedge n1Ol1O)
		  n1O1li29 <= n1O1li28;
	initial
		n1O1li30 = 0;
	always @ ( posedge n1Ol1O)
		  n1O1li30 <= (n1O1li29 ^ n1O1li28);
	initial
		n1O1Oi25 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1O1Oi25 <= n1O1Oi26;
	initial
		n1O1Oi26 = 0;
	always @ ( posedge n1Ol1O)
		  n1O1Oi26 <= n1O1Oi25;
	initial
		n1O1Oi27 = 0;
	always @ ( posedge n1Ol1O)
		  n1O1Oi27 <= (n1O1Oi26 ^ n1O1Oi25);
	initial
		n1O1OO22 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1O1OO22 <= n1O1OO23;
	initial
		n1O1OO23 = 0;
	always @ ( posedge n1Ol1O)
		  n1O1OO23 <= n1O1OO22;
	initial
		n1O1OO24 = 0;
	always @ ( posedge n1Ol1O)
		  n1O1OO24 <= (n1O1OO23 ^ n1O1OO22);
	initial
		n1Oi0i7 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1Oi0i7 <= n1Oi0i8;
	initial
		n1Oi0i8 = 0;
	always @ ( posedge n1Ol1O)
		  n1Oi0i8 <= n1Oi0i7;
	initial
		n1Oi0i9 = 0;
	always @ ( posedge n1Ol1O)
		  n1Oi0i9 <= (n1Oi0i8 ^ n1Oi0i7);
	initial
		n1Oill4 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1Oill4 <= n1Oill5;
	initial
		n1Oill5 = 0;
	always @ ( posedge n1Ol1O)
		  n1Oill5 <= n1Oill4;
	initial
		n1Oill6 = 0;
	always @ ( posedge n1Ol1O)
		  n1Oill6 <= (n1Oill5 ^ n1Oill4);
	initial
		n1OiOi1 = 1'b1;
	always @ ( posedge n1Ol1O)
		  n1OiOi1 <= n1OiOi2;
	initial
		n1OiOi2 = 0;
	always @ ( posedge n1Ol1O)
		  n1OiOi2 <= n1OiOi1;
	initial
		n1OiOi3 = 0;
	always @ ( posedge n1Ol1O)
		  n1OiOi3 <= (n1OiOi2 ^ n1OiOi1);
	initial
		n1Ol0i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n1Ol0i <= 1'b1;
		else   n1Ol0i <= wire_n1OO0i_o;
	initial
		n1Ol0l = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n1Ol0l <= 1'b1;
		else   n1Ol0l <= wire_n1OO0O_o;
	initial
		n1Ol0O = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n1Ol0O <= 1'b1;
		else   n1Ol0O <= n1Ol0i;
	initial
		n1Olii = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n1Olii <= 1'b0;
		else   n1Olii <= ENCDT;
	initial
		n1Olil = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n1Olil <= 1'b0;
		else   n1Olil <= wire_n1OO1l_o;
	initial
		n1OliO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n1OliO <= 1'b0;
		else   n1OliO <= wire_n1OO0l_o;
	initial
		n1OlOi = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) n1OlOi <= 1'b0;
		else   n1OlOi <= wire_n1OlOl_o;
	initial
		ni0liO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) ni0liO <= 1'b0;
		else   ni0liO <= wire_ni011i_dataout;
	initial
		ni0lli = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) ni0lli <= 1'b0;
		else   ni0lli <= wire_ni000i_dataout;
	initial
		ni0lll = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) ni0lll <= 1'b0;
		else   ni0lll <= wire_ni000l_dataout;
	initial
		ni0llO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) ni0llO <= 1'b0;
		else   ni0llO <= wire_ni000O_dataout;
	initial
		ni0lOi = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) ni0lOi <= 1'b0;
		else   ni0lOi <= wire_ni00ii_o;
	initial
		ni0lOl = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) ni0lOl <= 1'b0;
		else   ni0lOl <= wire_ni00il_o;
	initial
		ni0lOO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) ni0lOO <= 1'b0;
		else   ni0lOO <= wire_ni00li_o;
	initial
		ni0OOO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) ni0OOO <= 1'b0;
		else   ni0OOO <= wire_ni00lO_o;
	initial
		ni1O0i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) ni1O0i <= 1'b1;
		else   ni1O0i <= (~ nii1lO);
	initial
		ni1O0l = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) ni1O0l <= 1'b0;
		else   ni1O0l <= wire_nil0li_dataout;
	initial
		ni1O0O = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) ni1O0O <= 1'b0;
		else   ni1O0O <= wire_ni011O_o[0:0];
	initial
		ni1Oii = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) ni1Oii <= 1'b0;
		else   ni1Oii <= wire_ni011O_o[1:1];
	initial
		ni1Oil = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) ni1Oil <= 1'b0;
		else   ni1Oil <= wire_ni011O_o[2:2];
	initial
		ni1OiO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) ni1OiO <= 1'b0;
		else   ni1OiO <= wire_ni011O_o[3:3];
	initial
		ni1Oli = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) ni1Oli <= 1'b0;
		else   ni1Oli <= wire_ni1OOi_dataout;
	initial
		ni1Oll = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) ni1Oll <= 1'b0;
		else   ni1Oll <= wire_ni1OOl_dataout;
	initial
		ni1OlO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) ni1OlO <= 1'b0;
		else   ni1OlO <= wire_ni1OOO_dataout;
	initial
		nii11i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nii11i <= 1'b0;
		else   nii11i <= wire_nii10i_dataout;
	initial
		nii11l = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nii11l <= 1'b0;
		else   nii11l <= wire_nii10l_dataout;
	initial
		nii11O = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nii11O <= 1'b0;
		else   nii11O <= wire_nii10O_dataout;
	initial
		nii1iO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nii1iO <= 1'b0;
		else   nii1iO <= wire_nii1ii_dataout;
	initial
		nii1li = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nii1li <= 1'b0;
		else   nii1li <= nii1ll;
	initial
		nii1ll = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nii1ll <= 1'b0;
		else   nii1ll <= (niiOOl | niiiOl);
	initial
		nii1lO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nii1lO <= 1'b0;
		else   nii1lO <= niiiOi;
	initial
		niiiOi = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niiiOi <= 1'b0;
		else   niiiOi <= RLV_EN;
	initial
		niiiOl = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niiiOl <= 1'b0;
		else   niiiOl <= wire_niilOi_dataout;
	initial
		niiiOO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niiiOO <= 1'b0;
		else   niiiOO <= wire_niilOl_dataout;
	initial
		niil0i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niil0i <= 1'b0;
		else   niil0i <= wire_niiO1O_dataout;
	initial
		niil0l = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niil0l <= 1'b0;
		else   niil0l <= wire_niiO0i_dataout;
	initial
		niil0O = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niil0O <= 1'b0;
		else   niil0O <= wire_niiO0l_dataout;
	initial
		niil1i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niil1i <= 1'b0;
		else   niil1i <= wire_niilOO_dataout;
	initial
		niil1l = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niil1l <= 1'b0;
		else   niil1l <= wire_niiO1i_dataout;
	initial
		niil1O = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niil1O <= 1'b0;
		else   niil1O <= wire_niiO1l_dataout;
	initial
		niilii = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niilii <= 1'b0;
		else   niilii <= wire_niiO0O_dataout;
	initial
		niilil = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niilil <= 1'b0;
		else   niilil <= wire_niiOii_dataout;
	initial
		niiliO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niiliO <= 1'b0;
		else   niiliO <= wire_niiOil_dataout;
	initial
		niilli = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niilli <= 1'b0;
		else   niilli <= wire_niiOiO_dataout;
	initial
		niilll = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niilll <= 1'b0;
		else   niilll <= wire_niiOli_dataout;
	initial
		niillO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niillO <= 1'b0;
		else   niillO <= wire_niiOll_dataout;
	initial
		niiOOi = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niiOOi <= 1'b0;
		else   niiOOi <= wire_niiOlO_dataout;
	initial
		niiOOl = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niiOOl <= 1'b0;
		else   niiOOl <= wire_nil1lO_dataout;
	initial
		niiOOO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niiOOO <= 1'b0;
		else   niiOOO <= wire_nil1Oi_dataout;
	initial
		nil10i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nil10i <= 1'b0;
		else   nil10i <= wire_nil01l_dataout;
	initial
		nil10l = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nil10l <= 1'b0;
		else   nil10l <= wire_nil01O_dataout;
	initial
		nil10O = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nil10O <= 1'b0;
		else   nil10O <= wire_nil00i_dataout;
	initial
		nil11i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nil11i <= 1'b0;
		else   nil11i <= wire_nil1Ol_dataout;
	initial
		nil11l = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nil11l <= 1'b0;
		else   nil11l <= wire_nil1OO_dataout;
	initial
		nil11O = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nil11O <= 1'b0;
		else   nil11O <= wire_nil01i_dataout;
	initial
		nil1ii = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nil1ii <= 1'b0;
		else   nil1ii <= wire_nil00l_dataout;
	initial
		nil1il = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nil1il <= 1'b0;
		else   nil1il <= wire_nil00O_dataout;
	initial
		nil1iO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nil1iO <= 1'b0;
		else   nil1iO <= wire_nil0ii_dataout;
	initial
		nil1li = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nil1li <= 1'b0;
		else   nil1li <= wire_nil0il_dataout;
	initial
		nil1ll = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nil1ll <= 1'b0;
		else   nil1ll <= wire_nil0iO_dataout;
	initial
		nilii = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nilii <= 1'b0;
		else if  (n1O0li == 1'b1)   nilii <= n1Oi1l;
	initial
		nilil = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nilil <= 1'b0;
		else   nilil <= nl1ii;
	initial
		niliO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niliO <= 1'b0;
		else   niliO <= nl1il;
	initial
		nilli = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nilli <= 1'b0;
		else   nilli <= nl1iO;
	initial
		nilll = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nilll <= 1'b0;
		else   nilll <= nl1li;
	initial
		nillO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nillO <= 1'b0;
		else   nillO <= nl1ll;
	initial
		nilOi = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nilOi <= 1'b0;
		else   nilOi <= nl1lO;
	initial
		nilOl = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nilOl <= 1'b0;
		else   nilOl <= nl1Oi;
	initial
		nilOO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nilOO <= 1'b0;
		else   nilOO <= nl1Ol;
	initial
		niO0i = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niO0i <= 1'b0;
		else if  (PMADATAWIDTH == 1'b0)   niO0i <= niOOl;
	initial
		niO0l = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niO0l <= 1'b0;
		else if  (PMADATAWIDTH == 1'b0)   niO0l <= niOOO;
	initial
		niO0O = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niO0O <= 1'b0;
		else   niO0O <= wire_nl01i_dataout;
	initial
		niO1i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niO1i <= 1'b0;
		else   niO1i <= nl1OO;
	initial
		niO1l = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niO1l <= 1'b0;
		else   niO1l <= nl1iiO;
	initial
		niO1O = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niO1O <= 1'b0;
		else if  (PMADATAWIDTH == 1'b0)   niO1O <= niOOi;
	initial
		niOii = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niOii <= 1'b0;
		else   niOii <= wire_nl01l_dataout;
	initial
		niOil = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niOil <= 1'b0;
		else   niOil <= wire_nl01O_dataout;
	initial
		niOiO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niOiO <= 1'b0;
		else   niOiO <= wire_nl00i_dataout;
	initial
		niOli = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niOli <= 1'b0;
		else   niOli <= wire_nl00l_dataout;
	initial
		niOll = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niOll <= 1'b0;
		else   niOll <= wire_nl00O_dataout;
	initial
		niOlO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niOlO <= 1'b0;
		else   niOlO <= wire_nl0ii_dataout;
	initial
		niOOi = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niOOi <= 1'b0;
		else   niOOi <= wire_nl0il_dataout;
	initial
		niOOl = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niOOl <= 1'b0;
		else   niOOl <= wire_nl0iO_dataout;
	initial
		niOOO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) niOOO <= 1'b0;
		else   niOOO <= wire_nl0li_dataout;
	initial
		nl000i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl000i <= 1'b0;
		else   nl000i <= wire_nli11O_o;
	initial
		nl000l = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl000l <= 1'b0;
		else   nl000l <= wire_nli10i_o;
	initial
		nl000O = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl000O <= 1'b0;
		else   nl000O <= wire_nli10l_o;
	initial
		nl001i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl001i <= 1'b0;
		else   nl001i <= nl00li;
	initial
		nl001l = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl001l <= 1'b0;
		else   nl001l <= wire_nli11i_o;
	initial
		nl001O = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl001O <= 1'b0;
		else   nl001O <= wire_nli11l_o;
	initial
		nl00ii = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl00ii <= 1'b0;
		else   nl00ii <= wire_nli10O_o;
	initial
		nl00il = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl00il <= 1'b0;
		else   nl00il <= wire_nli1ii_o;
	initial
		nl00iO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl00iO <= 1'b0;
		else   nl00iO <= wire_nli1il_o;
	initial
		nl00li = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl00li <= 1'b0;
		else   nl00li <= nll10i;
	initial
		nl00ll = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl00ll <= 1'b0;
		else   nl00ll <= nli1lO;
	initial
		nl00lO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl00lO <= 1'b0;
		else   nl00lO <= nli1Oi;
	initial
		nl00Oi = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl00Oi <= 1'b0;
		else   nl00Oi <= nli1Ol;
	initial
		nl00Ol = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl00Ol <= 1'b0;
		else   nl00Ol <= nli1OO;
	initial
		nl00OO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl00OO <= 1'b0;
		else   nl00OO <= nli01i;
	initial
		nl010i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl010i <= 1'b0;
		else   nl010i <= wire_nl0lil_dataout;
	initial
		nl010l = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl010l <= 1'b0;
		else   nl010l <= (~ n1l11i);
	initial
		nl010O = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl010O <= 1'b0;
		else   nl010O <= ((((~ PMADATAWIDTH) & 
		(nl1OiO & SYNC_SM_DIS)) | (PMADATAWIDTH & (SYNC_SM_DIS & nl1Oii))) | (n1Olil & (~ SYNC_SM_DIS)));
	initial
		nl011i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl011i <= 1'b0;
		else   nl011i <= wire_nl0l0l_dataout;
	initial
		nl011l = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl011l <= 1'b0;
		else   nl011l <= wire_nl0l0O_dataout;
	initial
		nl011O = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl011O <= 1'b0;
		else   nl011O <= wire_nl0lii_dataout;
	initial
		nl01ii = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl01ii <= 1'b0;
		else   nl01ii <= n1l11l;
	initial
		nl01il = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl01il <= 1'b0;
		else   nl01il <= wire_nl0Oil_dataout;
	initial
		nl01iO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl01iO <= 1'b0;
		else   nl01iO <= wire_nl0OiO_dataout;
	initial
		nl01li = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl01li <= 1'b0;
		else   nl01li <= wire_nl0Oli_dataout;
	initial
		nl01ll = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl01ll <= 1'b0;
		else   nl01ll <= wire_nl0Oll_dataout;
	initial
		nl01lO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl01lO <= 1'b0;
		else   nl01lO <= wire_nl0OlO_dataout;
	initial
		nl01Oi = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl01Oi <= 1'b0;
		else   nl01Oi <= wire_nl0OOi_dataout;
	initial
		nl01Ol = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl01Ol <= 1'b0;
		else   nl01Ol <= wire_nl0OOl_dataout;
	initial
		nl01OO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl01OO <= 1'b0;
		else   nl01OO <= wire_nl0OOO_dataout;
	initial
		nl0i0i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl0i0i <= 1'b0;
		else   nl0i0i <= nli00l;
	initial
		nl0i1i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl0i1i <= 1'b0;
		else   nl0i1i <= nli01l;
	initial
		nl0i1l = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl0i1l <= 1'b0;
		else   nl0i1l <= nli01O;
	initial
		nl0i1O = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl0i1O <= 1'b0;
		else   nl0i1O <= nli00i;
	initial
		nl10i = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl10i <= 1'b0;
		else   nl10i <= wire_nl0Ol_dataout;
	initial
		nl10l = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl10l <= 1'b0;
		else   nl10l <= wire_nl0OO_dataout;
	initial
		nl10O = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl10O <= 1'b0;
		else   nl10O <= wire_nli1i_dataout;
	initial
		nl11i = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl11i <= 1'b0;
		else   nl11i <= wire_nl0ll_dataout;
	initial
		nl11l = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl11l <= 1'b0;
		else   nl11l <= wire_nl0lO_dataout;
	initial
		nl11O = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl11O <= 1'b0;
		else   nl11O <= wire_nl0Oi_dataout;
	initial
		nl1i0i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1i0i <= 1'b1;
		else   nl1i0i <= (n1l11l | (~ n1l11i));
	initial
		nl1i0l = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1i0l <= 1'b1;
		else   nl1i0l <= (~ n1O0Ol);
	initial
		nl1i0O = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1i0O <= 1'b1;
		else   nl1i0O <= n1O0OO;
	initial
		nl1ii = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1ii <= 1'b0;
		else   nl1ii <= wire_nli1l_dataout;
	initial
		nl1iii = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1iii <= 1'b1;
		else   nl1iii <= n1Oi1i;
	initial
		nl1iil = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1iil <= 1'b1;
		else   nl1iil <= n1Oi1l;
	initial
		nl1iiO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1iiO <= 1'b0;
		else if  (PMADATAWIDTH == 1'b0)   nl1iiO <= wire_nlill_dataout;
	initial
		nl1il = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1il <= 1'b0;
		else   nl1il <= wire_nli1O_dataout;
	initial
		nl1ili = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1ili <= 1'b0;
		else   nl1ili <= (((n1iOOi | n1iOlO) | ((~ nli1ll) & ((~ nl0i0i) & ((~ nl0i1O) & n1iOll)))) | (nli1ll & (nl0i0i & (nl0i1O & n1iOli))));
	initial
		nl1ill = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1ill <= 1'b0;
		else   nl1ill <= wire_ni11Oi_dataout;
	initial
		nl1iO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1iO <= 1'b0;
		else   nl1iO <= wire_nli0i_dataout;
	initial
		nl1li = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1li <= 1'b0;
		else   nl1li <= wire_nli0l_dataout;
	initial
		nl1ll = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1ll <= 1'b0;
		else   nl1ll <= wire_nli0O_dataout;
	initial
		nl1lO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1lO <= 1'b0;
		else   nl1lO <= wire_nliii_dataout;
	initial
		nl1O0O = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1O0O <= 1'b0;
		else   nl1O0O <= ((~ PMADATAWIDTH) & ((~ n1iOOO) | (~ n1iOOl)));
	initial
		nl1Oi = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1Oi <= 1'b0;
		else   nl1Oi <= wire_nliil_dataout;
	initial
		nl1Oii = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1Oii <= 1'b0;
		else   nl1Oii <= nl1Oil;
	initial
		nl1Oil = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1Oil <= 1'b0;
		else   nl1Oil <= nl1OiO;
	initial
		nl1OiO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1OiO <= 1'b0;
		else   nl1OiO <= nliOll;
	initial
		nl1Ol = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1Ol <= 1'b0;
		else   nl1Ol <= wire_nliiO_dataout;
	initial
		nl1Oli = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1Oli <= 1'b0;
		else   nl1Oli <= wire_nl0iOl_dataout;
	initial
		nl1Oll = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1Oll <= 1'b0;
		else   nl1Oll <= wire_nl0iOO_dataout;
	initial
		nl1OlO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1OlO <= 1'b0;
		else   nl1OlO <= wire_nl0l1i_dataout;
	initial
		nl1OO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1OO <= 1'b0;
		else if  (PMADATAWIDTH == 1'b0)   nl1OO <= wire_nlili_dataout;
	initial
		nl1OOi = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1OOi <= 1'b0;
		else   nl1OOi <= wire_nl0l1l_dataout;
	initial
		nl1OOl = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1OOl <= 1'b0;
		else   nl1OOl <= wire_nl0l1O_dataout;
	initial
		nl1OOO = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nl1OOO <= 1'b0;
		else   nl1OOO <= wire_nl0l0i_dataout;
	initial
		nli00i = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nli00i <= 1'b0;
		else   nli00i <= wire_nli0Oi_o;
	initial
		nli00l = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nli00l <= 1'b0;
		else   nli00l <= wire_nliiii_o;
	initial
		nli01i = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nli01i <= 1'b0;
		else   nli01i <= wire_nli0li_o;
	initial
		nli01l = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nli01l <= 1'b0;
		else   nli01l <= wire_nli0ll_o;
	initial
		nli01O = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nli01O <= 1'b0;
		else   nli01O <= wire_nli0lO_o;
	initial
		nli1ll = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nli1ll <= 1'b0;
		else   nli1ll <= nliilO;
	initial
		nli1lO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nli1lO <= 1'b0;
		else   nli1lO <= wire_nli00O_o;
	initial
		nli1Oi = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nli1Oi <= 1'b0;
		else   nli1Oi <= wire_nli0ii_o;
	initial
		nli1Ol = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nli1Ol <= 1'b0;
		else   nli1Ol <= wire_nli0il_o;
	initial
		nli1OO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nli1OO <= 1'b0;
		else   nli1OO <= wire_nli0iO_o;
	initial
		nliilO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nliilO <= 1'b0;
		else   nliilO <= wire_nliiil_o;
	initial
		nliiOi = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nliiOi <= 1'b0;
		else   nliiOi <= (nliiOO & 
		(~ nliiOl));
	initial
		nliiOl = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nliiOl <= 1'b0;
		else   nliiOl <= nliiOO;
	initial
		nliiOO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nliiOO <= 1'b0;
		else   nliiOO <= nlil1l;
	initial
		nlil0i = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nlil0i <= 1'b0;
		else if  (nliiOi == 1'b1)   nlil0i <= wire_nlilii_dataout;
	initial
		nlil0l = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nlil0l <= 1'b0;
		else if  (nliiOi == 1'b1)   nlil0l <= wire_nlilil_dataout;
	initial
		nlil1l = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nlil1l <= 1'b0;
		else   nlil1l <= BITSLIP;
	initial
		nlil1O = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nlil1O <= 1'b0;
		else if  (nliiOi == 1'b1)   nlil1O <= wire_nlil0O_dataout;
	initial
		nlilO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nlilO <= 1'b1;
		else   nlilO <= wire_nliOO_o;
	initial
		nliO1O = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nliO1O <= 1'b0;
		else if  (nliiOi == 1'b1)   nliO1O <= wire_nliliO_dataout;
	initial
		nliOi = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nliOi <= 1'b0;
		else   nliOi <= wire_nll1l_o;
	initial
		nliOll = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nliOll <= 1'b0;
		else   nliOll <= (~ ((~ ((((~ nl1iil) | (~ nl1iii)) | (~ nl1i0O)) | (~ nl1i0l))) | (~ ((((nl1i0l ^ nliOOO) | (nl1i0O ^ nll11i)) | (nl1iii ^ nll11l)) | (nl1iil ^ nll11O)))));
	initial
		nliOlO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nliOlO <= 1'b0;
		else   nliOlO <= nliOOi;
	initial
		nliOOi = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nliOOi <= 1'b0;
		else   nliOOi <= nliOOl;
	initial
		nliOOl = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nliOOl <= 1'b0;
		else   nliOOl <= A1A2_SIZE;
	initial
		nliOOO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nliOOO <= 1'b0;
		else   nliOOO <= nll1ii;
	initial
		nll10i = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nll10i <= 1'b0;
		else   nll10i <= nliOlO;
	initial
		nll10l = 0;
	always @ ( posedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nll10l <= 1'b0;
		else   nll10l <= nll10O;
	initial
		nll10O = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nll10O <= 1'b0;
		else   nll10O <= n1O0li;
	initial
		nll11i = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nll11i <= 1'b0;
		else   nll11i <= nll1il;
	initial
		nll11l = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nll11l <= 1'b0;
		else   nll11l <= nll1iO;
	initial
		nll11O = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nll11O <= 1'b0;
		else   nll11O <= nilii;
	initial
		nll1ii = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nll1ii <= 1'b0;
		else if  (n1O0li == 1'b1)   nll1ii <= (~ n1O0Ol);
	initial
		nll1il = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nll1il <= 1'b0;
		else if  (n1O0li == 1'b1)   nll1il <= n1O0OO;
	initial
		nll1iO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nll1iO <= 1'b0;
		else if  (n1O0li == 1'b1)   nll1iO <= n1Oi1i;
	initial
		nlllO = 0;
	always @ ( negedge rcvd_clk or posedge soft_reset)
		if (soft_reset == 1'b1) nlllO <= 1'b0;
		else   nlllO <= wire_nll1i_o;
	and(wire_n0011i_dataout, n1Ol0i, n11OOl);
	or(wire_n0011l_dataout, (~ n1OliO), ~{n11OOl});
	or(wire_n00iil_dataout, (~ n1O11O), (~ n1O1lO));
	or(wire_n00iOO_dataout, (~ n1lO1l), (~ n1lOii));
	or(wire_n00lii_dataout, (~ n1llOO), (~ n1lO1i));
	or(wire_n00lOl_dataout, (~ n1llOi), (~ n1llOl));
	or(wire_n00O0O_dataout, (~ n1llll), (~ n1lllO));
	or(wire_n00OOi_dataout, (~ n1lliO), (~ n1llli));
	and(wire_n0101i_dataout, wire_n01iil_dataout, ~{n11Oli});
	and(wire_n0101l_dataout, n11O1O, ~{n11Oli});
	and(wire_n0101O_dataout, (~ n11O1O), ~{n11Oli});
	and(wire_n010ii_dataout, wire_n01iOi_o[0:0], ~{n11Oli});
	and(wire_n010il_dataout, wire_n01iOi_o[1:1], ~{n11Oli});
	and(wire_n010iO_dataout, n1Olil, ~{n11Oli});
	and(wire_n010ll_dataout, wire_n010Oi_dataout, ~{(~ n0001O)});
	and(wire_n010lO_dataout, wire_n010Ol_dataout, ~{(~ n0001O)});
	and(wire_n010Oi_dataout, n11O1O, ~{n11O0i});
	and(wire_n010Ol_dataout, (~ n11O1O), ~{n11O0i});
	and(wire_n010OO_dataout, (~ n11O0i), ~{(~ n0001O)});
	and(wire_n011OO_dataout, wire_n01iii_dataout, ~{n11Oli});
	and(wire_n01i0i_dataout, wire_n01i0O_dataout, ~{(~ n0001O)});
	and(wire_n01i0l_dataout, wire_n01iii_dataout, ~{n11O0i});
	and(wire_n01i0O_dataout, wire_n01iil_dataout, ~{n11O0i});
	and(wire_n01i1i_dataout, n11O0i, ~{(~ n0001O)});
	and(wire_n01i1O_dataout, wire_n01i0l_dataout, ~{(~ n0001O)});
	and(wire_n01iii_dataout, wire_n01iOi_o[0:0], ~{n11O1O});
	and(wire_n01iil_dataout, wire_n01iOi_o[1:1], ~{n11O1O});
	and(wire_n01iiO_dataout, wire_n01ill_dataout, ~{(~ n0001O)});
	and(wire_n01ili_dataout, wire_n01ilO_dataout, ~{(~ n0001O)});
	and(wire_n01ill_dataout, wire_n01iOi_o[0:0], ~{n11O0i});
	and(wire_n01ilO_dataout, wire_n01iOi_o[1:1], ~{n11O0i});
	or(wire_n01iOl_dataout, n1Ol0i, (~ n0001O));
	and(wire_n01iOO_dataout, n1Olil, ~{(~ n0001O)});
	and(wire_n01l0i_dataout, n11O0l, ~{n11O0O});
	or(wire_n01l0l_dataout, n1Olil, n11O0l);
	assign		wire_n01l1i_dataout = (n11O0O === 1'b1) ? n1Olil : wire_n01l0l_dataout;
	or(wire_n01l1l_dataout, n1Ol0i, n11O0O);
	and(wire_n01l1O_dataout, (~ n11O0l), ~{n11O0O});
	and(wire_n01lOl_dataout, n11Oll, ~{n11Oli});
	and(wire_n01lOO_dataout, (~ n11Oll), ~{n11Oli});
	and(wire_n01O0i_dataout, wire_n01Oii_dataout, ~{n11OlO});
	and(wire_n01O0l_dataout, n11OOi, ~{n11OlO});
	and(wire_n01O0O_dataout, (~ n11Oii), ~{n11OOi});
	and(wire_n01O1O_dataout, wire_n01O0O_dataout, ~{n11OlO});
	and(wire_n01Oii_dataout, n11Oii, ~{n11OOi});
	assign		wire_n01Oli_dataout = (n11Oli === 1'b1) ? (~ n1OliO) : wire_n01OlO_dataout;
	or(wire_n01Oll_dataout, n1Ol0i, n11Oli);
	or(wire_n01OlO_dataout, (~ n1OliO), n11Oll);
	assign		wire_n01OOi_dataout = (n11OlO === 1'b1) ? (~ n1OliO) : wire_n01OOO_dataout;
	or(wire_n01OOl_dataout, n1Ol0i, n11OlO);
	assign		wire_n01OOO_dataout = (n11OOi === 1'b1) ? (~ n1OliO) : n1OliO;
	or(wire_n0i10l_dataout, (~ n1llii), (~ n1llil));
	or(wire_n0i1lO_dataout, (~ n1ll0l), (~ n1ll0O));
	assign		wire_n0liil_dataout = (((((~ nl00Ol) & n1010O) | (nl00Ol & n1l1il)) | (n1l1Oi & n1l1Ol)) === 1'b1) ? nl1ill : (n1l1li | n1l1iO);
	assign		wire_n0lil_dataout = ((~ n1O0il) === 1'b1) ? niOOi : wire_n0O1O_dataout;
	assign		wire_n0liO_dataout = ((~ n1O0il) === 1'b1) ? niOOl : wire_n0O0i_dataout;
	assign		wire_n0lli_dataout = ((~ n1O0il) === 1'b1) ? niOOO : wire_n0O0l_dataout;
	assign		wire_n0lll_dataout = ((~ n1O0il) === 1'b1) ? nl11i : wire_n0O0O_dataout;
	assign		wire_n0llO_dataout = ((~ n1O0il) === 1'b1) ? nl11l : wire_n0Oii_dataout;
	assign		wire_n0lOi_dataout = ((~ n1O0il) === 1'b1) ? nl11O : wire_n0Oil_dataout;
	assign		wire_n0lOl_dataout = ((~ n1O0il) === 1'b1) ? nl10i : wire_n0OiO_dataout;
	and(wire_n0lOO_dataout, wire_n0Oli_dataout, ~{(~ n1O0il)});
	and(wire_n0O0i_dataout, niOOl, ~{(~ n1O0iO)});
	and(wire_n0O0l_dataout, niOOO, ~{(~ n1O0iO)});
	and(wire_n0O0O_dataout, nl11i, ~{(~ n1O0iO)});
	and(wire_n0O1i_dataout, wire_n0Oll_dataout, ~{(~ n1O0il)});
	and(wire_n0O1l_dataout, wire_n0OlO_dataout, ~{(~ n1O0il)});
	and(wire_n0O1O_dataout, niOOi, ~{(~ n1O0iO)});
	and(wire_n0Oii_dataout, nl11l, ~{(~ n1O0iO)});
	and(wire_n0Oil_dataout, nl11O, ~{(~ n1O0iO)});
	and(wire_n0OiO_dataout, nl10i, ~{(~ n1O0iO)});
	and(wire_n0Oli_dataout, nl10l, ~{(~ n1O0iO)});
	and(wire_n0Oll_dataout, nl10O, ~{(~ n1O0iO)});
	and(wire_n0OlO_dataout, nl1ii, ~{(~ n1O0iO)});
	assign		wire_n0OOi_dataout = ((~ n1O0il) === 1'b1) ? nl10l : wire_n0Oli_dataout;
	and(wire_n0OOl_dataout, wire_n0OOO_dataout, ~{(~ n1O0il)});
	and(wire_n0OOO_dataout, nl1il, ~{(~ n1O0iO)});
	assign		wire_n1Olli_dataout = (n0000i === 1'b1) ? encdet_prbs : wire_n1Olll_dataout;
	assign		wire_n1Olll_dataout = (SYNC_SM_DIS === 1'b1) ? wire_n1OllO_dataout : n1Ol0O;
	assign		wire_n1OllO_dataout = (PMADATAWIDTH === 1'b1) ? wire_nliOl_o : n0000O;
	and(wire_ni000i_dataout, nii1lO, ni1O0i);
	and(wire_ni000l_dataout, wire_ni0lii_dataout, ni0lli);
	and(wire_ni000O_dataout, wire_ni0lil_dataout, ni0lli);
	and(wire_ni00i_dataout, nl1Oi, ~{(~ n1O0il)});
	and(wire_ni00l_dataout, wire_ni00O_dataout, ~{(~ n1O0il)});
	and(wire_ni00O_dataout, nl1OO, ~{(~ n1O0iO)});
	and(wire_ni00Ol_dataout, niil1l, ~{n100OO});
	and(wire_ni00OO_dataout, niil1O, ~{n100OO});
	and(wire_ni010i_dataout, ni1Oli, n100ii);
	and(wire_ni010l_dataout, ni1Oll, n100ii);
	and(wire_ni010O_dataout, ni1OlO, n100ii);
	assign		wire_ni011i_dataout = (wire_ni011O_o[4:4] === 1'b1) ? wire_ni011l_o[3:3] : wire_ni01ii_dataout;
	and(wire_ni01i_dataout, nl1lO, ~{(~ n1O0il)});
	and(wire_ni01ii_dataout, ni0liO, n100ii);
	and(wire_ni01l_dataout, wire_ni01O_dataout, ~{(~ n1O0il)});
	and(wire_ni01O_dataout, nl1Ol, ~{(~ n1O0iO)});
	and(wire_ni0i0i_dataout, wire_ni0i0O_dataout, ~{(~ nii1lO)});
	and(wire_ni0i0l_dataout, wire_ni0iii_dataout, ~{(~ nii1lO)});
	and(wire_ni0i0O_dataout, n100Oi, ~{n100Ol});
	and(wire_ni0i1i_dataout, niil0i, ~{n100OO});
	and(wire_ni0i1l_dataout, niil0l, ~{n100OO});
	and(wire_ni0i1O_dataout, n100Ol, ~{(~ nii1lO)});
	and(wire_ni0ii_dataout, nl1Ol, ~{(~ n1O0il)});
	and(wire_ni0iii_dataout, (~ n100Oi), ~{n100Ol});
	and(wire_ni0il_dataout, wire_ni0iO_dataout, ~{(~ n1O0il)});
	and(wire_ni0ili_dataout, nil11i, ~{n100OO});
	and(wire_ni0ill_dataout, nil11l, ~{n100OO});
	and(wire_ni0ilO_dataout, nil11O, ~{n100OO});
	and(wire_ni0iO_dataout, nl1iiO, ~{(~ n1O0iO)});
	and(wire_ni0iOi_dataout, nil10i, ~{n100OO});
	and(wire_ni0iOO_dataout, n10i1l, ~{(~ nii1lO)});
	and(wire_ni0l0i_dataout, (~ n10i1i), ~{n10i1l});
	and(wire_ni0l1i_dataout, wire_ni0l1O_dataout, ~{(~ nii1lO)});
	and(wire_ni0l1l_dataout, wire_ni0l0i_dataout, ~{(~ nii1lO)});
	and(wire_ni0l1O_dataout, n10i1i, ~{n10i1l});
	assign		wire_ni0li_dataout = ((~ n1O0il) === 1'b1) ? (~ SYNC_COMP_PAT[0:0]) : wire_nii0l_dataout;
	and(wire_ni0lii_dataout, niiiOO, ~{(~ nii1lO)});
	and(wire_ni0lil_dataout, (~ niiiOO), ~{(~ nii1lO)});
	assign		wire_ni0ll_dataout = ((~ n1O0il) === 1'b1) ? (~ SYNC_COMP_PAT[1:1]) : wire_nii0O_dataout;
	assign		wire_ni0lO_dataout = ((~ n1O0il) === 1'b1) ? (~ SYNC_COMP_PAT[2:2]) : wire_niiii_dataout;
	assign		wire_ni0O0i_dataout = (PMADATAWIDTH === 1'b1) ? RUNDISP_SEL[1:1] : wire_ni0OiO_o[1:1];
	assign		wire_ni0O0l_dataout = (PMADATAWIDTH === 1'b1) ? RUNDISP_SEL[2:2] : wire_ni0OiO_o[2:2];
	assign		wire_ni0O0O_dataout = (PMADATAWIDTH === 1'b1) ? RUNDISP_SEL[3:3] : wire_ni0OiO_o[3:3];
	and(wire_ni0O1i_dataout, RUNDISP_SEL[0:0], ~{PMADATAWIDTH});
	and(wire_ni0O1l_dataout, RUNDISP_SEL[1:1], ~{PMADATAWIDTH});
	assign		wire_ni0O1O_dataout = (PMADATAWIDTH === 1'b1) ? RUNDISP_SEL[0:0] : wire_ni0OiO_o[0:0];
	assign		wire_ni0Oi_dataout = ((~ n1O0il) === 1'b1) ? (~ SYNC_COMP_PAT[3:3]) : wire_niiil_dataout;
	assign		wire_ni0Oii_dataout = (PMADATAWIDTH === 1'b1) ? RUNDISP_SEL[4:4] : wire_ni0OiO_o[4:4];
	assign		wire_ni0Oil_dataout = (PMADATAWIDTH === 1'b1) ? (~ n10i1O) : wire_ni0OiO_o[5:5];
	assign		wire_ni0Ol_dataout = ((~ n1O0il) === 1'b1) ? (~ SYNC_COMP_PAT[4:4]) : wire_niiiO_dataout;
	assign		wire_ni0OO_dataout = ((~ n1O0il) === 1'b1) ? (~ SYNC_COMP_PAT[5:5]) : wire_niili_dataout;
	and(wire_ni10i_dataout, nl1il, ~{(~ n1O0il)});
	and(wire_ni10l_dataout, wire_ni10O_dataout, ~{(~ n1O0il)});
	and(wire_ni10O_dataout, nl1li, ~{(~ n1O0iO)});
	and(wire_ni11i_dataout, nl1ii, ~{(~ n1O0il)});
	and(wire_ni11l_dataout, wire_ni11O_dataout, ~{(~ n1O0il)});
	and(wire_ni11O_dataout, nl1iO, ~{(~ n1O0iO)});
	assign		wire_ni11Oi_dataout = ((n1l11O & 
		(nl0i1O ^ nl0i1l)) === 1'b1) ? wire_n0liil_dataout : (n1l10l | n1l10i);
	and(wire_ni1ii_dataout, nl1iO, ~{(~ n1O0il)});
	and(wire_ni1il_dataout, wire_ni1iO_dataout, ~{(~ n1O0il)});
	and(wire_ni1iO_dataout, nl1ll, ~{(~ n1O0iO)});
	and(wire_ni1li_dataout, nl1li, ~{(~ n1O0il)});
	and(wire_ni1ll_dataout, wire_ni1lO_dataout, ~{(~ n1O0il)});
	and(wire_ni1lO_dataout, nl1lO, ~{(~ n1O0iO)});
	and(wire_ni1Oi_dataout, nl1ll, ~{(~ n1O0il)});
	and(wire_ni1Ol_dataout, wire_ni1OO_dataout, ~{(~ n1O0il)});
	and(wire_ni1OO_dataout, nl1Oi, ~{(~ n1O0iO)});
	assign		wire_ni1OOi_dataout = (wire_ni011O_o[4:4] === 1'b1) ? wire_ni011l_o[0:0] : wire_ni010i_dataout;
	assign		wire_ni1OOl_dataout = (wire_ni011O_o[4:4] === 1'b1) ? wire_ni011l_o[1:1] : wire_ni010l_dataout;
	assign		wire_ni1OOO_dataout = (wire_ni011O_o[4:4] === 1'b1) ? wire_ni011l_o[2:2] : wire_ni010O_dataout;
	and(wire_nii0i_dataout, wire_niiOl_dataout, ~{(~ n1O0il)});
	assign		wire_nii0l_dataout = ((~ n1O0iO) === 1'b1) ? SYNC_COMP_PAT[8:8] : (~ SYNC_COMP_PAT[0:0]);
	assign		wire_nii0O_dataout = ((~ n1O0iO) === 1'b1) ? SYNC_COMP_PAT[9:9] : (~ SYNC_COMP_PAT[1:1]);
	and(wire_nii10i_dataout, nii11l, nii1lO);
	and(wire_nii10l_dataout, nii11O, nii1lO);
	and(wire_nii10O_dataout, n1OiOO, nii1lO);
	assign		wire_nii1i_dataout = ((~ n1O0il) === 1'b1) ? (~ SYNC_COMP_PAT[6:6]) : wire_niill_dataout;
	and(wire_nii1ii_dataout, wire_nii1il_o, nii1lO);
	and(wire_nii1l_dataout, wire_niilO_dataout, ~{(~ n1O0il)});
	and(wire_nii1O_dataout, wire_niiOi_dataout, ~{(~ n1O0il)});
	assign		wire_niiii_dataout = ((~ n1O0iO) === 1'b1) ? SYNC_COMP_PAT[10:10] : (~ SYNC_COMP_PAT[2:2]);
	assign		wire_niiil_dataout = ((~ n1O0iO) === 1'b1) ? SYNC_COMP_PAT[11:11] : (~ SYNC_COMP_PAT[3:3]);
	assign		wire_niiili_dataout = (PMADATAWIDTH === 1'b1) ? (~ n10i0l) : (~ n10i0i);
	assign		wire_niiiO_dataout = ((~ n1O0iO) === 1'b1) ? SYNC_COMP_PAT[12:12] : (~ SYNC_COMP_PAT[4:4]);
	assign		wire_niili_dataout = ((~ n1O0iO) === 1'b1) ? SYNC_COMP_PAT[13:13] : (~ SYNC_COMP_PAT[5:5]);
	assign		wire_niill_dataout = ((~ n1O0iO) === 1'b1) ? SYNC_COMP_PAT[14:14] : (~ SYNC_COMP_PAT[6:6]);
	assign		wire_niilO_dataout = ((~ n1O0iO) === 1'b1) ? SYNC_COMP_PAT[15:15] : (~ SYNC_COMP_PAT[7:7]);
	and(wire_niilOi_dataout, ((~ n10ilO) | ((~ n10ill) | ((~ n10ili) | ((~ n10iiO) | ((~ n10iil) | ((~ n10iii) | (~ n10i0O))))))), nii1lO);
	and(wire_niilOl_dataout, n1iilO, nii1lO);
	and(wire_niilOO_dataout, (((~ PMADATAWIDTH) & n1i0il) | (PMADATAWIDTH & n1i0Oi)), nii1lO);
	and(wire_niiO0i_dataout, ((n1i0il | (~ n10lOl)) | (~ ((n1i0il | (~ n1i0Oi)) | n1i1OO))), nii1lO);
	and(wire_niiO0l_dataout, niilli, nii1lO);
	and(wire_niiO0O_dataout, niilll, nii1lO);
	and(wire_niiO1i_dataout, n10l0l, nii1lO);
	and(wire_niiO1l_dataout, n10l0O, nii1lO);
	and(wire_niiO1O_dataout, ((((~ n10lOi) | (~ n10llO)) | (~ n10lll)) | (~ n10lli)), nii1lO);
	and(wire_niiOi_dataout, (~ SYNC_COMP_PAT[8:8]), ~{(~ n1O0iO)});
	and(wire_niiOii_dataout, niillO, nii1lO);
	and(wire_niiOil_dataout, niiOOi, nii1lO);
	and(wire_niiOiO_dataout, n10lOO, nii1lO);
	and(wire_niiOl_dataout, (~ SYNC_COMP_PAT[9:9]), ~{(~ n1O0iO)});
	and(wire_niiOli_dataout, n10O1i, nii1lO);
	and(wire_niiOll_dataout, ((((~ n10Oil) | (~ n10Oii)) | (~ n10O0O)) | (~ n10O0l)), nii1lO);
	and(wire_niiOlO_dataout, ((n1i0il | (~ n10OiO)) | (~ ((n1i0il | n1i0li) | (~ n1i0lO)))), nii1lO);
	and(wire_nil00i_dataout, nil1li, nii1lO);
	and(wire_nil00l_dataout, nil1ll, nii1lO);
	and(wire_nil00O_dataout, ni1O0l, nii1lO);
	and(wire_nil01i_dataout, ((((~ n1i11O) | (~ n1i11l)) | (~ n1i11i)) | (~ n10OOO)), nii1lO);
	and(wire_nil01l_dataout, ((n1il0O | (~ n1i10i)) | (~ ((n1il0O | n1illl) | n1iiOi))), nii1lO);
	and(wire_nil01O_dataout, nil1iO, nii1lO);
	and(wire_nil0i_dataout, wire_nil0O_dataout, ~{(~ n1O0il)});
	and(wire_nil0ii_dataout, n1i10l, nii1lO);
	and(wire_nil0il_dataout, n1i10O, nii1lO);
	and(wire_nil0iO_dataout, ((((~ n1i1Oi) | (~ n1i1lO)) | (~ n1i1ll)) | (~ n1i1li)), nii1lO);
	and(wire_nil0l_dataout, SYNC_COMP_PAT[8:8], ~{(~ n1O0iO)});
	and(wire_nil0li_dataout, ((n1il0O | (~ n1i1Ol)) | (~ ((n1il0O | n1ilil) | (~ n1illi)))), nii1lO);
	and(wire_nil0O_dataout, SYNC_COMP_PAT[9:9], ~{(~ n1O0iO)});
	and(wire_nil1l_dataout, SYNC_COMP_PAT[7:7], ~{(~ n1O0il)});
	and(wire_nil1lO_dataout, ((~ n10l0i) | ((~ n10l1O) | ((~ n10l1l) | ((~ n10l1i) | ((~ n10iOO) | ((~ n10iOl) | (~ n10iOi))))))), nii1lO);
	and(wire_nil1O_dataout, wire_nil0l_dataout, ~{(~ n1O0il)});
	and(wire_nil1Oi_dataout, (((~ PMADATAWIDTH) & n1il0O) | (PMADATAWIDTH & (~ n1illl))), nii1lO);
	and(wire_nil1Ol_dataout, n10Oli, nii1lO);
	and(wire_nil1OO_dataout, n10Oll, nii1lO);
	assign		wire_nl00i_dataout = ((~ PMADATAWIDTH) === 1'b1) ? nl10i : nl11l;
	assign		wire_nl00l_dataout = ((~ PMADATAWIDTH) === 1'b1) ? nl10l : nl11O;
	assign		wire_nl00O_dataout = ((~ PMADATAWIDTH) === 1'b1) ? nl10O : nl10i;
	assign		wire_nl01i_dataout = ((~ PMADATAWIDTH) === 1'b1) ? nl11i : niOOl;
	assign		wire_nl01l_dataout = ((~ PMADATAWIDTH) === 1'b1) ? nl11l : niOOO;
	assign		wire_nl01O_dataout = ((~ PMADATAWIDTH) === 1'b1) ? nl11O : nl11i;
	assign		wire_nl0ii_dataout = ((~ PMADATAWIDTH) === 1'b1) ? nl1ii : nl10l;
	assign		wire_nl0il_dataout = ((~ PMADATAWIDTH) === 1'b1) ? nl1il : nl10O;
	assign		wire_nl0iO_dataout = ((~ PMADATAWIDTH) === 1'b1) ? nl1iO : nl1ii;
	assign		wire_nl0iOl_dataout = (n1l00l === 1'b1) ? SYNC_COMP_PAT[0:0] : wire_nl0liO_dataout;
	assign		wire_nl0iOO_dataout = (n1l00l === 1'b1) ? SYNC_COMP_PAT[1:1] : wire_nl0lli_dataout;
	assign		wire_nl0l0i_dataout = (n1l00l === 1'b1) ? SYNC_COMP_PAT[5:5] : wire_nl0lOl_dataout;
	assign		wire_nl0l0l_dataout = (n1l00l === 1'b1) ? SYNC_COMP_PAT[6:6] : wire_nl0lOO_dataout;
	assign		wire_nl0l0O_dataout = (n1l00l === 1'b1) ? SYNC_COMP_PAT[7:7] : wire_nl0O1i_dataout;
	assign		wire_nl0l1i_dataout = (n1l00l === 1'b1) ? SYNC_COMP_PAT[2:2] : wire_nl0lll_dataout;
	assign		wire_nl0l1l_dataout = (n1l00l === 1'b1) ? SYNC_COMP_PAT[3:3] : wire_nl0llO_dataout;
	assign		wire_nl0l1O_dataout = (n1l00l === 1'b1) ? SYNC_COMP_PAT[4:4] : wire_nl0lOi_dataout;
	assign		wire_nl0li_dataout = ((~ PMADATAWIDTH) === 1'b1) ? nl1li : nl1il;
	assign		wire_nl0lii_dataout = (n1l00l === 1'b1) ? nl001i : wire_nl0O1l_dataout;
	and(wire_nl0lil_dataout, wire_nl0O1O_dataout, ~{n1l00l});
	assign		wire_nl0liO_dataout = (n1l00i === 1'b1) ? nl01il : nl00ll;
	assign		wire_nl0ll_dataout = ((~ PMADATAWIDTH) === 1'b1) ? nl1ll : nl1iO;
	assign		wire_nl0lli_dataout = (n1l00i === 1'b1) ? nl01iO : nl00lO;
	assign		wire_nl0lll_dataout = (n1l00i === 1'b1) ? nl01li : nl00Oi;
	assign		wire_nl0llO_dataout = (n1l00i === 1'b1) ? nl01ll : nl00Ol;
	assign		wire_nl0lO_dataout = ((~ PMADATAWIDTH) === 1'b1) ? nl1lO : nl1li;
	assign		wire_nl0lOi_dataout = (n1l00i === 1'b1) ? nl01lO : nl00OO;
	assign		wire_nl0lOl_dataout = (n1l00i === 1'b1) ? nl01Oi : nl0i1i;
	assign		wire_nl0lOO_dataout = (n1l00i === 1'b1) ? nl01Ol : nl0i1l;
	assign		wire_nl0O1i_dataout = (n1l00i === 1'b1) ? nl01OO : nl0i1O;
	assign		wire_nl0O1l_dataout = (n1l00i === 1'b1) ? nl001i : nl0i0i;
	and(wire_nl0O1O_dataout, nli1ll, ~{n1l00i});
	assign		wire_nl0Oi_dataout = ((~ PMADATAWIDTH) === 1'b1) ? nl1Oi : nl1ll;
	assign		wire_nl0Oil_dataout = (n1l00O === 1'b1) ? SYNC_COMP_PAT[0:0] : nl001l;
	assign		wire_nl0OiO_dataout = (n1l00O === 1'b1) ? SYNC_COMP_PAT[1:1] : nl001O;
	assign		wire_nl0Ol_dataout = ((~ PMADATAWIDTH) === 1'b1) ? nl1Ol : nl1lO;
	assign		wire_nl0Oli_dataout = (n1l00O === 1'b1) ? SYNC_COMP_PAT[2:2] : nl000i;
	assign		wire_nl0Oll_dataout = (n1l00O === 1'b1) ? SYNC_COMP_PAT[3:3] : nl000l;
	assign		wire_nl0OlO_dataout = (n1l00O === 1'b1) ? SYNC_COMP_PAT[4:4] : nl000O;
	assign		wire_nl0OO_dataout = ((~ PMADATAWIDTH) === 1'b1) ? nl1OO : nl1Oi;
	assign		wire_nl0OOi_dataout = (n1l00O === 1'b1) ? SYNC_COMP_PAT[5:5] : nl00ii;
	assign		wire_nl0OOl_dataout = (n1l00O === 1'b1) ? SYNC_COMP_PAT[6:6] : nl00il;
	assign		wire_nl0OOO_dataout = (n1l00O === 1'b1) ? SYNC_COMP_PAT[7:7] : nl00iO;
	assign		wire_nli0i_dataout = (LP10BEN === 1'b1) ? PUDR[2:2] : PUDI[2:2];
	assign		wire_nli0l_dataout = (LP10BEN === 1'b1) ? PUDR[3:3] : PUDI[3:3];
	assign		wire_nli0O_dataout = (LP10BEN === 1'b1) ? PUDR[4:4] : PUDI[4:4];
	assign		wire_nli1i_dataout = ((~ PMADATAWIDTH) === 1'b1) ? nl1iiO : nl1Ol;
	assign		wire_nli1l_dataout = (LP10BEN === 1'b1) ? PUDR[0:0] : PUDI[0:0];
	assign		wire_nli1O_dataout = (LP10BEN === 1'b1) ? PUDR[1:1] : PUDI[1:1];
	assign		wire_nliii_dataout = (LP10BEN === 1'b1) ? PUDR[5:5] : PUDI[5:5];
	assign		wire_nliil_dataout = (LP10BEN === 1'b1) ? PUDR[6:6] : PUDI[6:6];
	assign		wire_nliiO_dataout = (LP10BEN === 1'b1) ? PUDR[7:7] : PUDI[7:7];
	or(wire_nlil0O_dataout, wire_nlilli_dataout, n1li0i);
	assign		wire_nlili_dataout = (LP10BEN === 1'b1) ? PUDR[8:8] : PUDI[8:8];
	and(wire_nlilii_dataout, wire_nlilll_dataout, ~{n1li0i});
	and(wire_nlilil_dataout, wire_nlillO_dataout, ~{n1li0i});
	or(wire_nliliO_dataout, wire_nlilOi_dataout, n1li0i);
	assign		wire_nlill_dataout = (LP10BEN === 1'b1) ? PUDR[9:9] : PUDI[9:9];
	or(wire_nlilli_dataout, wire_nlilOl_o[1:1], n1li1O);
	or(wire_nlilll_dataout, wire_nlilOl_o[2:2], n1li1O);
	or(wire_nlillO_dataout, wire_nlilOl_o[3:3], n1li1O);
	and(wire_nlilOi_dataout, wire_nlilOl_o[4:4], ~{n1li1O});
	and(wire_nll0i_dataout, (~ n1Oi1O), ~{n1O0ll});
	and(wire_nll0l_dataout, n1Oi1O, ~{n1O0ll});
	assign		wire_nll0ll_dataout = (AUTOBYTEALIGN_DIS === 1'b1) ? nlil1O : nll1ii;
	assign		wire_nll0lO_dataout = (AUTOBYTEALIGN_DIS === 1'b1) ? nlil0i : nll1il;
	or(wire_nll0O_dataout, n1O0ll, n1Oi1O);
	assign		wire_nll0Oi_dataout = (AUTOBYTEALIGN_DIS === 1'b1) ? nlil0l : nll1iO;
	assign		wire_nll0Ol_dataout = (AUTOBYTEALIGN_DIS === 1'b1) ? nliO1O : nilii;
	and(wire_nll0OO_dataout, ((~ n1ll1i) | 
		(~ n1ll1l)), ~{PMADATAWIDTH});
	or(wire_nll1O_dataout, n1Oi1O, n1O0ll);
	assign		wire_nlli0i_dataout = (PMADATAWIDTH === 1'b1) ? (((~ nliOOi) & ((~ n1ll0l) & n0i1Oi)) | (nliOOi & ((~ n1ll0l) & (~ ((~ n0i1OO) | n0i1Ol))))) : ((~ n1ll0O) | (~ n1ll0l));
	and(wire_nlli1l_dataout, ((~ n1ll1O) | (~ n1ll0i)), ~{PMADATAWIDTH});
	and(wire_nllii_dataout, (~ n1O0ll), ~{n1Oi1O});
	assign		wire_nlliii_dataout = (PMADATAWIDTH === 1'b1) ? (((~ nliOOi) & ((~ n1llii) & n0ilii)) | (nliOOi & ((~ n1llii) & (~ ((~ n0i01l) | n0i01i))))) : ((~ n1llil) | (~ n1llii));
	and(wire_nllil_dataout, n1O0ll, ~{n1Oi1O});
	assign		wire_nllili_dataout = (PMADATAWIDTH === 1'b1) ? (((~ nliOOi) & ((~ n1lliO) & n0il0O)) | (nliOOi & ((~ n1lliO) & (~ ((~ n0i00i) | n0i01O))))) : ((~ n1llli) | (~ n1lliO));
	assign		wire_nlliOi_dataout = (PMADATAWIDTH === 1'b1) ? (((~ nliOOi) & ((~ n1llll) & n0il0l)) | (nliOOi & ((~ n1llll) & (~ ((~ n0i00O) | n0i00l))))) : ((~ n1lllO) | (~ n1llll));
	assign		wire_nlll0i_dataout = (PMADATAWIDTH === 1'b1) ? (((~ nliOOi) & ((~ n1llOO) & n0il1O)) | (nliOOi & ((~ n1llOO) & (~ ((~ n0i0li) | n0i0iO))))) : ((~ n1lO1i) | (~ n1llOO));
	assign		wire_nlll1i_dataout = (PMADATAWIDTH === 1'b1) ? (((~ nliOOi) & ((~ n1llOi) & n0il0i)) | (nliOOi & ((~ n1llOi) & (~ ((~ n0i0il) | n0i0ii))))) : ((~ n1llOl) | (~ n1llOi));
	assign		wire_nlllii_dataout = (PMADATAWIDTH === 1'b1) ? (((~ nliOOi) & ((~ n1lO1l) & n0il1l)) | (nliOOi & ((~ n1lO1l) & (~ ((~ n0i0lO) | n0i0ll))))) : ((~ n1lOii) | (~ n1lO1l));
	assign		wire_nlllli_dataout = (PMADATAWIDTH === 1'b1) ? (((~ nliOOi) & ((~ n1O11O) & n0il1i)) | (nliOOi & ((~ n1O11O) & (~ ((~ n0iiOO) | n0i0Oi))))) : ((~ n1O1lO) | (~ n1O11O));
	oper_add   n01iOi
	( 
	.a({n0010i, n1OlOi}),
	.b({1'b0, 1'b1}),
	.cin(1'b0),
	.cout(),
	.o(wire_n01iOi_o));
	defparam
		n01iOi.sgate_representation = 0,
		n01iOi.width_a = 2,
		n01iOi.width_b = 2,
		n01iOi.width_o = 2;
	oper_add   ni011l
	( 
	.a({wire_ni01ii_dataout, wire_ni010O_dataout, wire_ni010l_dataout, wire_ni010i_dataout}),
	.b({1'b0, 1'b0, 1'b0, 1'b1}),
	.cin(1'b0),
	.cout(),
	.o(wire_ni011l_o));
	defparam
		ni011l.sgate_representation = 0,
		ni011l.width_a = 4,
		ni011l.width_b = 4,
		ni011l.width_o = 4;
	oper_add   ni011O
	( 
	.a({1'b0, wire_ni001i_o, wire_ni01OO_o, wire_ni01Ol_o, wire_ni01Oi_o}),
	.b({1'b0, wire_ni01lO_o, wire_ni01ll_o, wire_ni01li_o, wire_ni01iO_o}),
	.cin(1'b0),
	.cout(),
	.o(wire_ni011O_o));
	defparam
		ni011O.sgate_representation = 0,
		ni011O.width_a = 5,
		ni011O.width_b = 5,
		ni011O.width_o = 5;
	oper_add   ni0OiO
	( 
	.a({1'b0, 1'b0, (~ n10i1O), RUNDISP_SEL[4:2]}),
	.b({(~ n10i1O), RUNDISP_SEL[4:0]}),
	.cin(1'b0),
	.cout(),
	.o(wire_ni0OiO_o));
	defparam
		ni0OiO.sgate_representation = 0,
		ni0OiO.width_a = 6,
		ni0OiO.width_b = 6,
		ni0OiO.width_o = 6;
	oper_add   nlilOl
	( 
	.a({nliO1O, nlil0l, nlil0i, nlil1O, 1'b1}),
	.b({1'b1, 1'b1, 1'b1, 1'b0, 1'b1}),
	.cin(1'b0),
	.cout(),
	.o(wire_nlilOl_o));
	defparam
		nlilOl.sgate_representation = 0,
		nlilOl.width_a = 5,
		nlilOl.width_b = 5,
		nlilOl.width_o = 5;
	oper_decoder   n00iii
	( 
	.i({n0iiOO, n0i0Oi}),
	.o(wire_n00iii_o));
	defparam
		n00iii.width_i = 2,
		n00iii.width_o = 4;
	oper_decoder   n00iOl
	( 
	.i({n0i0lO, n0i0ll}),
	.o(wire_n00iOl_o));
	defparam
		n00iOl.width_i = 2,
		n00iOl.width_o = 4;
	oper_decoder   n00l0O
	( 
	.i({n0i0li, n0i0iO}),
	.o(wire_n00l0O_o));
	defparam
		n00l0O.width_i = 2,
		n00l0O.width_o = 4;
	oper_decoder   n00lOi
	( 
	.i({n0i0il, n0i0ii}),
	.o(wire_n00lOi_o));
	defparam
		n00lOi.width_i = 2,
		n00lOi.width_o = 4;
	oper_decoder   n00O0l
	( 
	.i({n0i00O, n0i00l}),
	.o(wire_n00O0l_o));
	defparam
		n00O0l.width_i = 2,
		n00O0l.width_o = 4;
	oper_decoder   n00OlO
	( 
	.i({n0i00i, n0i01O}),
	.o(wire_n00OlO_o));
	defparam
		n00OlO.width_i = 2,
		n00OlO.width_o = 4;
	oper_decoder   n0i10i
	( 
	.i({n0i01l, n0i01i}),
	.o(wire_n0i10i_o));
	defparam
		n0i10i.width_i = 2,
		n0i10i.width_o = 4;
	oper_decoder   n0i1ll
	( 
	.i({n0i1OO, n0i1Ol}),
	.o(wire_n0i1ll_o));
	defparam
		n0i1ll.width_i = 2,
		n0i1ll.width_o = 4;
	oper_decoder   nli1li
	( 
	.i({nll10l, nll10i}),
	.o(wire_nli1li_o));
	defparam
		nli1li.width_i = 2,
		nli1li.width_o = 4;
	oper_decoder   nliill
	( 
	.i({PMADATAWIDTH, wire_nll0Ol_dataout, wire_nll0Oi_dataout, wire_nll0lO_dataout, wire_nll0ll_dataout}),
	.o(wire_nliill_o));
	defparam
		nliill.width_i = 5,
		nliill.width_o = 32;
	oper_less_than   nii1il
	( 
	.a({wire_ni0Oil_dataout, wire_ni0Oii_dataout, wire_ni0O0O_dataout, wire_ni0O0l_dataout, wire_ni0O0i_dataout, wire_ni0O1O_dataout, wire_ni0O1l_dataout, wire_ni0O1i_dataout}),
	.b({ni0liO, ni1OlO, ni1Oll, ni1Oli, ni1OiO, ni1Oil, ni1Oii, ni1O0O}),
	.cin(1'b0),
	.o(wire_nii1il_o));
	defparam
		nii1il.sgate_representation = 0,
		nii1il.width_a = 8,
		nii1il.width_b = 8;
	oper_selector   n00i0l
	( 
	.data({wire_n00iil_dataout, 1'b0, (~ n1O1lO)}),
	.o(wire_n00i0l_o),
	.sel({wire_n00iii_o[3:3], (wire_n00iii_o[2:2] | wire_n00iii_o[0:0]), wire_n00iii_o[1:1]}));
	defparam
		n00i0l.width_data = 3,
		n00i0l.width_sel = 3;
	oper_selector   n00ilO
	( 
	.data({wire_n00iOO_dataout, 1'b0, (~ n1lOii)}),
	.o(wire_n00ilO_o),
	.sel({wire_n00iOl_o[3:3], (wire_n00iOl_o[2:2] | wire_n00iOl_o[0:0]), wire_n00iOl_o[1:1]}));
	defparam
		n00ilO.width_data = 3,
		n00ilO.width_sel = 3;
	oper_selector   n00l0i
	( 
	.data({wire_n00lii_dataout, 1'b0, (~ n1lO1i)}),
	.o(wire_n00l0i_o),
	.sel({wire_n00l0O_o[3:3], (wire_n00l0O_o[2:2] | wire_n00l0O_o[0:0]), wire_n00l0O_o[1:1]}));
	defparam
		n00l0i.width_data = 3,
		n00l0i.width_sel = 3;
	oper_selector   n00lll
	( 
	.data({wire_n00lOl_dataout, 1'b0, (~ n1llOl)}),
	.o(wire_n00lll_o),
	.sel({wire_n00lOi_o[3:3], (wire_n00lOi_o[2:2] | wire_n00lOi_o[0:0]), wire_n00lOi_o[1:1]}));
	defparam
		n00lll.width_data = 3,
		n00lll.width_sel = 3;
	oper_selector   n00O1O
	( 
	.data({wire_n00O0O_dataout, 1'b0, (~ n1lllO)}),
	.o(wire_n00O1O_o),
	.sel({wire_n00O0l_o[3:3], (wire_n00O0l_o[2:2] | wire_n00O0l_o[0:0]), wire_n00O0l_o[1:1]}));
	defparam
		n00O1O.width_data = 3,
		n00O1O.width_sel = 3;
	oper_selector   n00Oli
	( 
	.data({wire_n00OOi_dataout, 1'b0, (~ n1llli)}),
	.o(wire_n00Oli_o),
	.sel({wire_n00OlO_o[3:3], (wire_n00OlO_o[2:2] | wire_n00OlO_o[0:0]), wire_n00OlO_o[1:1]}));
	defparam
		n00Oli.width_data = 3,
		n00Oli.width_sel = 3;
	oper_selector   n0110i
	( 
	.data({1'b0, wire_n01i1i_dataout, wire_n010ll_dataout}),
	.o(wire_n0110i_o),
	.sel({n11lOi, n001li, n001Ol}));
	defparam
		n0110i.width_data = 3,
		n0110i.width_sel = 3;
	oper_selector   n0110O
	( 
	.data({1'b0, wire_n010OO_dataout, wire_n010lO_dataout}),
	.o(wire_n0110O_o),
	.sel({n11lOl, n001ll, n001lO}));
	defparam
		n0110O.width_data = 3,
		n0110O.width_sel = 3;
	oper_selector   n0111l
	( 
	.data({1'b0, wire_n01l0i_dataout, wire_n010OO_dataout, wire_n010ll_dataout}),
	.o(wire_n0111l_o),
	.sel({n11llO, n001ii, n001li, n001lO}));
	defparam
		n0111l.width_data = 4,
		n0111l.width_sel = 4;
	oper_selector   n011il
	( 
	.data({1'b0, wire_n01i1i_dataout, wire_n01i1i_dataout, wire_n0101l_dataout}),
	.o(wire_n011il_o),
	.sel({n11lOO, n001ll, n001lO, n0001i}));
	defparam
		n011il.width_data = 4,
		n011il.width_sel = 4;
	oper_selector   n011li
	( 
	.data({1'b0, wire_n010OO_dataout, wire_n010lO_dataout}),
	.o(wire_n011li_o),
	.sel({n11O1i, n001Oi, n001Ol}));
	defparam
		n011li.width_data = 3,
		n011li.width_sel = 3;
	oper_selector   n011ll
	( 
	.data({1'b0, wire_n01i1i_dataout
		, wire_n01i1i_dataout}),
	.o(wire_n011ll_o),
	.sel({n11O1i, n001Oi, n001Ol}));
	defparam
		n011ll.width_data = 3,
		n011ll.width_sel = 3;
	oper_selector   n011Oi
	( 
	.data({1'b0, (~ n11Oli), wire_n0101O_dataout}),
	.o(wire_n011Oi_o),
	.sel({n11O1l, n001OO, n0001i}));
	defparam
		n011Oi.width_data = 3,
		n011Oi.width_sel = 3;
	oper_selector   n0i11l
	( 
	.data({wire_n0i10l_dataout, 1'b0, (~ n1llil)}),
	.o(wire_n0i11l_o),
	.sel({wire_n0i10i_o[3:3], (wire_n0i10i_o[2:2] | wire_n0i10i_o[0:0]), wire_n0i10i_o[1:1]}));
	defparam
		n0i11l.width_data = 3,
		n0i11l.width_sel = 3;
	oper_selector   n0i1iO
	( 
	.data({wire_n0i1lO_dataout, 1'b0, (~ n1ll0O)}),
	.o(wire_n0i1iO_o),
	.sel({wire_n0i1ll_o[3:3], (wire_n0i1ll_o[2:2] | wire_n0i1ll_o[0:0]), wire_n0i1ll_o[1:1]}));
	defparam
		n0i1iO.width_data = 3,
		n0i1iO.width_sel = 3;
	oper_selector   n1OlOl
	( 
	.data({1'b0, wire_n01iiO_dataout, wire_n01i1O_dataout, wire_n01iiO_dataout, wire_n01i1O_dataout, wire_n010ii_dataout, wire_n011OO_dataout}),
	.o(wire_n1OlOl_o),
	.sel({n11l0l, n001ll, n001lO, n001Oi, n001Ol, n001OO, n0001i}));
	defparam
		n1OlOl.width_data = 7,
		n1OlOl.width_sel = 7;
	oper_selector   n1OlOO
	( 
	.data({1'b0, wire_n01ili_dataout, wire_n01i0i_dataout, wire_n01ili_dataout, wire_n01i0i_dataout, wire_n010il_dataout, wire_n0101i_dataout}),
	.o(wire_n1OlOO_o),
	.sel({n11l0l, n001ll, n001lO, n001Oi, n001Ol, n001OO, n0001i}));
	defparam
		n1OlOO.width_data = 7,
		n1OlOO.width_sel = 7;
	oper_selector   n1OO0i
	( 
	.data({wire_n0011i_dataout, wire_n01OOl_dataout, wire_n01Oll_dataout, wire_n01OOl_dataout, wire_n01Oll_dataout, wire_n01l1l_dataout, wire_n01iOl_dataout, wire_n01iOl_dataout, wire_n01iOl_dataout, wire_n01iOl_dataout, wire_n01iOl_dataout, wire_n01Oll_dataout, wire_n01Oll_dataout}),
	.o(wire_n1OO0i_o),
	.sel({n1Ol0l, n0010l, n001il, n0010O, n001iO, n001ii, n001li, n001ll, n001lO, n001Oi, n001Ol, n001OO, n0001i}));
	defparam
		n1OO0i.width_data = 13,
		n1OO0i.width_sel = 13;
	oper_selector   n1OO0l
	( 
	.data({wire_n0011l_dataout, wire_n01OOi_dataout, wire_n01Oli_dataout, wire_n01OOi_dataout, wire_n01Oli_dataout, (~ n1OliO), (~ n1OliO), (~ n1OliO), (~ n1OliO), (~ n1OliO), (~ n1OliO), (~ n1OliO), (~ n1OliO)}),
	.o(wire_n1OO0l_o),
	.sel({n1Ol0l, n0010l, n001il, n0010O, n001iO, n001ii, n001li, n001ll, n001lO, n001Oi, n001Ol, n001OO, n0001i}));
	defparam
		n1OO0l.width_data = 13,
		n1OO0l.width_sel = 13;
	oper_selector   n1OO0O
	( 
	.data({n11OOl, n11OlO, n11Oli, n11OlO, n11Oli, n11O0O, (~ n0001O), (~ n0001O), (~ n0001O), (~ n0001O), (~ n0001O), n11Oli, n11Oli}),
	.o(wire_n1OO0O_o),
	.sel({n1Ol0l, n0010l, n001il, n0010O, n001iO, n001ii, n001li, n001ll, n001lO, n001Oi, n001Ol, n001OO, n0001i}));
	defparam
		n1OO0O.width_data = 13,
		n1OO0O.width_sel = 13;
	oper_selector   n1OO1l
	( 
	.data({n1Olil, wire_n01l1i_dataout, wire_n01iOO_dataout, wire_n01iOO_dataout, wire_n01iOO_dataout, wire_n01iOO_dataout, wire_n01iOO_dataout, wire_n010iO_dataout, wire_n010iO_dataout}),
	.o(wire_n1OO1l_o),
	.sel({n11l0O, n001ii, n001li, n001ll, n001lO, n001Oi, n001Ol, n001OO, n0001i}));
	defparam
		n1OO1l.width_data = 9,
		n1OO1l.width_sel = 9;
	oper_selector   n1OOii
	( 
	.data({(~ n11OOl), wire_n01O1O_dataout, 1'b0}),
	.o(wire_n1OOii_o),
	.sel({n1Ol0l, n0010l, n11lii}));
	defparam
		n1OOii.width_data = 3,
		n1OOii.width_sel = 3;
	oper_selector   n1OOiO
	( 
	.data({1'b0, wire_n01O0i_dataout, wire_n01lOl_dataout, wire_n01O1O_dataout}),
	.o(wire_n1OOiO_o),
	.sel({n11lil, n0010l, n001il, n0010O}));
	defparam
		n1OOiO.width_data = 4,
		n1OOiO.width_sel = 4;
	oper_selector   n1OOll
	( 
	.data({1'b0, wire_n01O0i_dataout, wire_n01lOl_dataout, wire_n01l1O_dataout}),
	.o(wire_n1OOll_o),
	.sel({n11liO, n0010O, n001iO, n001ii}));
	defparam
		n1OOll.width_data = 4,
		n1OOll.width_sel = 4;
	oper_selector   n1OOOi
	( 
	.data({1'b0, wire_n01O0l_dataout, wire_n01lOO_dataout}),
	.o(wire_n1OOOi_o),
	.sel({n11lli, n0010l, n001il}));
	defparam
		n1OOOi.width_data = 3,
		n1OOOi.width_sel = 3;
	oper_selector   n1OOOO
	( 
	.data({1'b0, wire_n01O0l_dataout, wire_n01lOO_dataout}),
	.o(wire_n1OOOO_o),
	.sel({n11lll, n0010O, n001iO}));
	defparam
		n1OOOO.width_data = 3,
		n1OOOO.width_sel = 3;
	oper_selector   ni001i
	( 
	.data({1'b0, nil10i, wire_ni0iOi_dataout, niil0l, wire_ni0i1l_dataout}),
	.o(wire_ni001i_o),
	.sel({n100li, n100iO, ni0lOO, n100il, ni0OOO}));
	defparam
		ni001i.width_data = 5,
		ni001i.width_sel = 5;
	oper_selector   ni00ii
	( 
	.data({1'b0, wire_ni0iOO_dataout, wire_ni0iOO_dataout, wire_ni0iOO_dataout, wire_ni0i1O_dataout, wire_ni0i1O_dataout, wire_ni0i1O_dataout}),
	.o(wire_ni00ii_o),
	.sel({n100li, ni0llO, ni0lOl, ni0lOO, ni0lll, ni0lOi, ni0OOO}));
	defparam
		ni00ii.width_data = 7,
		ni00ii.width_sel = 7;
	oper_selector   ni00il
	( 
	.data({1'b0, wire_ni0l1i_dataout, wire_ni0l1i_dataout
		, wire_ni0l1i_dataout, wire_ni0i0i_dataout, wire_ni0i0i_dataout, wire_ni0i0i_dataout}),
	.o(wire_ni00il_o),
	.sel({n100li, ni0llO, ni0lOl, ni0lOO, ni0lll, ni0lOi, ni0OOO}));
	defparam
		ni00il.width_data = 7,
		ni00il.width_sel = 7;
	oper_selector   ni00li
	( 
	.data({1'b0, wire_ni0l1l_dataout, wire_ni0l1l_dataout, wire_ni0l1l_dataout}),
	.o(wire_ni00li_o),
	.sel({n100ll, ni0llO, ni0lOl, ni0lOO}));
	defparam
		ni00li.width_data = 4,
		ni00li.width_sel = 4;
	oper_selector   ni00lO
	( 
	.data({1'b0, wire_ni0i0l_dataout, wire_ni0i0l_dataout, wire_ni0i0l_dataout}),
	.o(wire_ni00lO_o),
	.sel({n100lO, ni0lll, ni0lOi, ni0OOO}));
	defparam
		ni00lO.width_data = 4,
		ni00lO.width_sel = 4;
	oper_selector   ni01iO
	( 
	.data({1'b0, nil10l, ni1O0O, niil0O}),
	.o(wire_ni01iO_o),
	.sel({n100li, n100iO, n100ii, n100il}));
	defparam
		ni01iO.width_data = 4,
		ni01iO.width_sel = 4;
	oper_selector   ni01li
	( 
	.data({1'b0, nil10O, ni1Oii, niilii}),
	.o(wire_ni01li_o),
	.sel({n100li, n100iO, n100ii, n100il}));
	defparam
		ni01li.width_data = 4,
		ni01li.width_sel = 4;
	oper_selector   ni01ll
	( 
	.data({1'b0, nil1ii, ni1Oil, niilil}),
	.o(wire_ni01ll_o),
	.sel({n100li, n100iO, n100ii, n100il}));
	defparam
		ni01ll.width_data = 4,
		ni01ll.width_sel = 4;
	oper_selector   ni01lO
	( 
	.data({1'b0, nil1il, ni1OiO, niiliO}),
	.o(wire_ni01lO_o),
	.sel({n100li, n100iO, n100ii, n100il}));
	defparam
		ni01lO.width_data = 4,
		ni01lO.width_sel = 4;
	oper_selector   ni01Oi
	( 
	.data({1'b0, nil11i, wire_ni0ili_dataout, niil1l, wire_ni00Ol_dataout}),
	.o(wire_ni01Oi_o),
	.sel({n100li, n100iO, ni0lOO, n100il, ni0OOO}));
	defparam
		ni01Oi.width_data = 5,
		ni01Oi.width_sel = 5;
	oper_selector   ni01Ol
	( 
	.data({1'b0, nil11l, wire_ni0ill_dataout, niil1O, wire_ni00OO_dataout}),
	.o(wire_ni01Ol_o),
	.sel({n100li, n100iO, ni0lOO, n100il, ni0OOO}));
	defparam
		ni01Ol.width_data = 5,
		ni01Ol.width_sel = 5;
	oper_selector   ni01OO
	( 
	.data({1'b0, nil11O, wire_ni0ilO_dataout, niil0i, wire_ni0i1i_dataout}),
	.o(wire_ni01OO_o),
	.sel({n100li, n100iO, ni0lOO, n100il, ni0OOO}));
	defparam
		ni01OO.width_data = 5,
		ni01OO.width_sel = 5;
	oper_selector   nli00O
	( 
	.data({niOlO, niO0l, niO0O, niOii, niOil, niOiO, niOli, niOll, niOOi, niOOl, niO1O, niO0i}),
	.o(wire_nli00O_o),
	.sel({n1l0OO, n1l0Ol, n1l0Oi, n1l0lO, n1l0ll, n1l0li, n1l0iO, n1l0il, wire_nliill_o[17:16], wire_nliill_o[9:8]}));
	defparam
		nli00O.width_data = 12,
		nli00O.width_sel = 12;
	oper_selector   nli0ii
	( 
	.data({niOOi, niO0O, niOii, niOil, niOiO, niOli, niOll, niOlO, niOOl, niOOO, niO0i, niO0l}),
	.o(wire_nli0ii_o),
	.sel({n1l0OO, n1l0Ol, n1l0Oi, n1l0lO, n1l0ll, n1l0li, n1l0iO, n1l0il, wire_nliill_o[17:16], wire_nliill_o[9:8]}));
	defparam
		nli0ii.width_data = 12,
		nli0ii.width_sel = 12;
	oper_selector   nli0il
	( 
	.data({niOOl, niOii, niOil, niOiO, niOli, niOll, niOlO, niOOi, niOOO, nl11i, niO0l, niO0O}),
	.o(wire_nli0il_o),
	.sel({n1l0OO, n1l0Ol, n1l0Oi, n1l0lO, n1l0ll, n1l0li, n1l0iO, n1l0il, wire_nliill_o[17:16], wire_nliill_o[9:8]}));
	defparam
		nli0il.width_data = 12,
		nli0il.width_sel = 12;
	oper_selector   nli0iO
	( 
	.data({niOOO, niOil, niOiO, niOli, niOll, niOlO, niOOi, niOOl, nl11i, nl11l, niO0O, niOii}),
	.o(wire_nli0iO_o),
	.sel({n1l0OO, n1l0Ol, n1l0Oi, n1l0lO, n1l0ll, n1l0li, n1l0iO, n1l0il, wire_nliill_o[17:16], wire_nliill_o[9:8]}));
	defparam
		nli0iO.width_data = 12,
		nli0iO.width_sel = 12;
	oper_selector   nli0li
	( 
	.data({nl11i, niOiO, niOli, niOll, niOlO, niOOi, niOOl, niOOO, nl11l, nl11O, niOii, niOil}),
	.o(wire_nli0li_o),
	.sel({n1l0OO, n1l0Ol, n1l0Oi, n1l0lO, n1l0ll, n1l0li, n1l0iO, n1l0il, wire_nliill_o[17:16], wire_nliill_o[9:8]}));
	defparam
		nli0li.width_data = 12,
		nli0li.width_sel = 12;
	oper_selector   nli0ll
	( 
	.data({nl11l, niOli, niOll, niOlO, niOOi, niOOl, niOOO, nl11i, nl11O, nl10i, niOil, niOiO}),
	.o(wire_nli0ll_o),
	.sel({n1l0OO, n1l0Ol, n1l0Oi, n1l0lO, n1l0ll, n1l0li, n1l0iO, n1l0il, wire_nliill_o[17:16], wire_nliill_o[9:8]}));
	defparam
		nli0ll.width_data = 12,
		nli0ll.width_sel = 12;
	oper_selector   nli0lO
	( 
	.data({nl11O, niOll, niOlO, niOOi, niOOl, niOOO, nl11i, nl11l, nl10i, nl10l, niOiO, niOli}),
	.o(wire_nli0lO_o),
	.sel({n1l0OO, n1l0Ol, n1l0Oi, n1l0lO, n1l0ll, n1l0li, n1l0iO, n1l0il, wire_nliill_o[17:16], wire_nliill_o[9:8]}));
	defparam
		nli0lO.width_data = 12,
		nli0lO.width_sel = 12;
	oper_selector   nli0Oi
	( 
	.data({nl10i, niOlO, niOOi, niOOl, niOOO, nl11i, nl11l, nl11O, nl10l, nl10O, niOli, niOll}),
	.o(wire_nli0Oi_o),
	.sel({n1l0OO, n1l0Ol, n1l0Oi, n1l0lO, n1l0ll, n1l0li, n1l0iO, n1l0il, wire_nliill_o[17:16], wire_nliill_o[9:8]}));
	defparam
		nli0Oi.width_data = 12,
		nli0Oi.width_sel = 12;
	oper_selector   nli10i
	( 
	.data({SYNC_COMP_PAT[11:11], SYNC_COMP_PAT[3:3], nl00Ol}),
	.o(wire_nli10i_o),
	.sel({wire_nli1li_o[3:2], n1l0ii}));
	defparam
		nli10i.width_data = 3,
		nli10i.width_sel = 3;
	oper_selector   nli10l
	( 
	.data({SYNC_COMP_PAT[12:12], SYNC_COMP_PAT[4:4], nl00OO}),
	.o(wire_nli10l_o),
	.sel({wire_nli1li_o[3:2], n1l0ii}));
	defparam
		nli10l.width_data = 3,
		nli10l.width_sel = 3;
	oper_selector   nli10O
	( 
	.data({SYNC_COMP_PAT[13:13], SYNC_COMP_PAT[5:5], nl0i1i}),
	.o(wire_nli10O_o),
	.sel({wire_nli1li_o[3:2], n1l0ii}));
	defparam
		nli10O.width_data = 3,
		nli10O.width_sel = 3;
	oper_selector   nli11i
	( 
	.data({SYNC_COMP_PAT[8:8], SYNC_COMP_PAT[0:0], nl00ll}),
	.o(wire_nli11i_o),
	.sel({wire_nli1li_o[3:2], n1l0ii}));
	defparam
		nli11i.width_data = 3,
		nli11i.width_sel = 3;
	oper_selector   nli11l
	( 
	.data({SYNC_COMP_PAT[9:9], SYNC_COMP_PAT[1:1], nl00lO}),
	.o(wire_nli11l_o),
	.sel({wire_nli1li_o[3:2], n1l0ii}));
	defparam
		nli11l.width_data = 3,
		nli11l.width_sel = 3;
	oper_selector   nli11O
	( 
	.data({SYNC_COMP_PAT[10:10], SYNC_COMP_PAT[2:2], nl00Oi}),
	.o(wire_nli11O_o),
	.sel({wire_nli1li_o[3:2]
		, n1l0ii}));
	defparam
		nli11O.width_data = 3,
		nli11O.width_sel = 3;
	oper_selector   nli1ii
	( 
	.data({SYNC_COMP_PAT[14:14], SYNC_COMP_PAT[6:6], nl0i1l}),
	.o(wire_nli1ii_o),
	.sel({wire_nli1li_o[3:2], n1l0ii}));
	defparam
		nli1ii.width_data = 3,
		nli1ii.width_sel = 3;
	oper_selector   nli1il
	( 
	.data({SYNC_COMP_PAT[15:15], SYNC_COMP_PAT[7:7], nl0i1O}),
	.o(wire_nli1il_o),
	.sel({wire_nli1li_o[3:2], n1l0ii}));
	defparam
		nli1il.width_data = 3,
		nli1il.width_sel = 3;
	oper_selector   nliiii
	( 
	.data({nl10l, nli00l, niOll, niOlO, niOOi, niOOl, niOOO, nl11i, nl11l, nl11O, nl10i}),
	.o(wire_nliiii_o),
	.sel({n1li1l, n1li1i, wire_nliill_o[9:1]}));
	defparam
		nliiii.width_data = 11,
		nliiii.width_sel = 11;
	oper_selector   nliiil
	( 
	.data({nl10O, nliilO, niOlO, niOOi, niOOl, niOOO, nl11i, nl11l, nl11O, nl10i, nl10l}),
	.o(wire_nliiil_o),
	.sel({n1li1l, n1li1i, wire_nliill_o[9:1]}));
	defparam
		nliiil.width_data = 11,
		nliiil.width_sel = 11;
	oper_selector   nliOl
	( 
	.data({wire_nll0O_dataout, wire_nll1O_dataout, 1'b0}),
	.o(wire_nliOl_o),
	.sel({nlilO, nlllO, nliOi}));
	defparam
		nliOl.width_data = 3,
		nliOl.width_sel = 3;
	oper_selector   nliOO
	( 
	.data({wire_nllii_dataout, wire_nll0i_dataout, (~ n0000O)}),
	.o(wire_nliOO_o),
	.sel({nlilO, nlllO, nliOi}));
	defparam
		nliOO.width_data = 3,
		nliOO.width_sel = 3;
	oper_selector   nll1i
	( 
	.data({n1Oi1O, wire_nll0l_dataout, 1'b0}),
	.o(wire_nll1i_o),
	.sel({nlilO, nlllO, nliOi}));
	defparam
		nll1i.width_data = 3,
		nll1i.width_sel = 3;
	oper_selector   nll1l
	( 
	.data({wire_nllil_dataout, n1O0ll, n0000O}),
	.o(wire_nll1l_o),
	.sel({nlilO, nlllO, nliOi}));
	defparam
		nll1l.width_data = 3,
		nll1l.width_sel = 3;
	assign
		cg_comma = nl1O0O,
		n1000i = (nl0i0i ^ nl0i1l),
		n1000l = (nli1ll & (nl0i0i & (nl0i1O & nl0i1l))),
		n1000O = (((((~ nli1ll) & (nl0i0i & n101ll)) | (nli1ll & ((~ nl0i0i) & n101ll))) | (nli1ll & (nl0i0i & ((~ nl0i1O) & nl0i1l)))) | (nli1ll & (nl0i0i & (nl0i1O & (~ nl0i1l))))),
		n1001i = ((n101iO & n101il) | (n101iO & n101li)),
		n1001l = (n1l1OO & n101il),
		n1001O = ((n101iO & (~ wire_n0liil_dataout)) | (n1l1OO & wire_n0liil_dataout)),
		n100ii = (ni0OOO | ni0lOO),
		n100il = (ni0lOi | ni0lll),
		n100iO = (ni0lOl | ni0llO),
		n100li = (ni0lli | ni1O0i),
		n100ll = ((((ni0OOO | ni0lOi) | ni0lll) | ni0lli) | ni1O0i),
		n100lO = ((((ni0lOO | ni0lOl) | ni0llO) | ni0lli) | ni1O0i),
		n100Oi = ((~ niil1i) & (~ niiiOO)),
		n100Ol = ((~ niil1i) & niiiOO),
		n100OO = (ni0liO & ni1OlO),
		n1010i = (nl00lO & (~ nl00ll)),
		n1010l = ((~ nl00lO) & nl00ll),
		n1010O = (n1l1lO & n101iO),
		n1011i = ((~ nl1ili) & (~ nl1i0i)),
		n1011l = (nl00lO & nl00ll),
		n1011O = ((~ nl00lO) & (~ nl00ll)),
		n101ii = ((~ nl00Ol) & ((~ nl00Oi) & ((~ nl00lO) & (~ nl00ll)))),
		n101il = (nl00Ol & (nl00Oi & (nl00lO & nl00ll))),
		n101iO = (nl0i1i & nl00OO),
		n101li = (((((~ nl00Ol) & (nl00Oi & n1011l)) | (nl00Ol & ((~ nl00Oi) & n1011l))) | (nl00Ol & (nl00Oi & ((~ nl00lO) & nl00ll)))) | (nl00Ol & (nl00Oi & (nl00lO & (~ nl00ll))))),
		n101ll = (nl0i1O & nl0i1l),
		n101lO = ((~ nl0i1O) & (~ nl0i1l)),
		n101Oi = (nl0i1O & (~ nl0i1l)),
		n101Ol = ((~ nl0i1O) & nl0i1l),
		n101OO = (n1l1Oi & n101il),
		n10i0i = (((((((wire_ni0Oil_dataout | wire_ni0Oii_dataout) | wire_ni0O0O_dataout) | wire_ni0O0l_dataout) | wire_ni0O0i_dataout) | (~ wire_ni0O1O_dataout)) | wire_ni0O1l_dataout) | (~ wire_ni0O1i_dataout)),
		n10i0l = (((((((wire_ni0Oil_dataout | wire_ni0Oii_dataout) | wire_ni0O0O_dataout) | wire_ni0O0l_dataout) | wire_ni0O0i_dataout) | (~ wire_ni0O1O_dataout)) | wire_ni0O1l_dataout) | wire_ni0O1i_dataout),
		n10i0O = ((((((((~ PMADATAWIDTH) | (~ nii1lO)) | (~ nilOi)) | (~ nillO)) | (~ nilll)) | (~ nilli)) | (~ niliO)) | (~ wire_niiili_dataout)),
		n10i1i = ((~ niiiOO) & (~ niiOOO)),
		n10i1l = (niiiOO & (~ niiOOO)),
		n10i1O = ((((RUNDISP_SEL[4:4] | RUNDISP_SEL[3:3]) | RUNDISP_SEL[2:2]) | RUNDISP_SEL[1:1]) | RUNDISP_SEL[0:0]),
		n10iii = ((((((((~ PMADATAWIDTH) | (~ nii1lO)) | (~ nilOi)) | (~ nillO)) | (~ nilll)) | (~ nilli)) | (~ wire_niiili_dataout)) | (~ nilOl)),
		n10iil = ((((((((~ PMADATAWIDTH) | (~ nii1lO)) | (~ nillO)) | (~ nilll)) | (~ nilli)) | (~ niliO)) | (~ nilil)) | (~ wire_niiili_dataout)),
		n10iiO = ((((((((PMADATAWIDTH | (~ nii1lO)) | (~ nilOi)) | (~ nillO)) | (~ nilll)) | (~ wire_niiili_dataout)) | (~ nilOl)) | (~ nilOO)) | (~ niO1i)),
		n10ili = ((((((((PMADATAWIDTH | (~ nii1lO)) | (~ nilOi)) | (~ nillO)) | (~ nilll)) | (~ nilli)) | (~ wire_niiili_dataout)) | (~ nilOl)) | (~ nilOO)),
		n10ill = ((((((((PMADATAWIDTH | (~ nii1lO)) | (~ nilOi)) | (~ nillO)) | (~ nilll)) | (~ nilli)) | (~ niliO)) | (~ wire_niiili_dataout)) | (~ nilOl)),
		n10ilO = ((((((((PMADATAWIDTH | (~ nii1lO)) | (~ nilOi)) | (~ nillO)) | (~ nilll)) | (~ nilli)) | (~ niliO)) | (~ nilil)) | (~ wire_niiili_dataout)),
		n10iOi = ((((((((~ PMADATAWIDTH) | (~ nii1lO)) | nilOi) | nillO) | nilll) | nilli) | niliO) | (~ wire_niiili_dataout)),
		n10iOl = ((((((((~ PMADATAWIDTH) | (~ nii1lO)) | nilOi) | nillO) | nilll) | nilli) | (~ wire_niiili_dataout)) | nilOl),
		n10iOO = ((((((((~ PMADATAWIDTH) | (~ nii1lO)) | nillO) | nilll) | nilli) | niliO) | nilil) | (~ wire_niiili_dataout)),
		n10l0i = ((((((((PMADATAWIDTH | (~ nii1lO)) | nilOi) | nillO) | nilll) | nilli) | niliO) | nilil) | (~ wire_niiili_dataout)),
		n10l0l = (((((~ n10lOl) | (~ n10lOi)) | (~ n10lll)) | (~ n10liO)) | (~ n10lii)),
		n10l0O = ((((n1i0il | (~ n10lOi)) | (~ n10llO)) | (~ n10liO)) | (~ n10lil)),
		n10l1i = ((((((((PMADATAWIDTH | (~ nii1lO)) | nilOi) | nillO) | nilll) | (~ wire_niiili_dataout)) | nilOl) | nilOO) | niO1i),
		n10l1l = ((((((((PMADATAWIDTH | (~ nii1lO)) | nilOi) | nillO) | nilll) | nilli) | (~ wire_niiili_dataout)) | nilOl) | nilOO),
		n10l1O = ((((((((PMADATAWIDTH | (~ nii1lO)) | nilOi) | nillO) | nilll) | nilli) | niliO) | (~ wire_niiili_dataout)) | nilOl),
		n10lii = ((((((((((~ nilil) | n1i0il) | n1i0Oi) | n1i1OO) | n1i01l) | n1i01O) | n1i00i) | n1i00l) | n1i00O) | n1i0ii),
		n10lil = ((((((((n1i0il | n1i0Oi) | n1i1OO) | n1i01l) | n1i01O) | n1i00i) | n1i00l) | n1i00O) | (~ n1i0ii)),
		n10liO = (((((((n1i0il | n1i0Oi) | n1i1OO) | n1i01l) | n1i01O) | n1i00i) | n1i00l) | (~ n1i00O)),
		n10lli = ((((((n1i0il | n1i0Oi) | n1i1OO) | n1i01l) | n1i01O) | n1i00i) | (~ n1i00l)),
		n10lll = (((((n1i0il | n1i0Oi) | n1i1OO) | n1i01l) | n1i01O) | (~ n1i00i)),
		n10llO = ((((n1i0il | n1i0Oi) | n1i1OO) | n1i01l) | (~ n1i01O)),
		n10lOi = (((n1i0il | n1i0Oi) | n1i1OO) | (~ n1i01l)),
		n10lOl = (n1i0il | (~ n1i1OO)),
		n10lOO = (((((~ n10OiO) | (~ n10Oil)) | (~ n10O0O)) | (~ n10O0i)) | (~ n10O1l)),
		n10O0i = (((((((n1i0il | n1i0li) | n1i0lO) | n1i0OO) | n1ii1O) | n1ii0O) | n1iiiO) | (~ n1iili)),
		n10O0l = ((((((n1i0il | n1i0li) | n1i0lO) | n1i0OO) | n1ii1O) | n1ii0O) | (~ n1iiiO)),
		n10O0O = (((((n1i0il | n1i0li) | n1i0lO) | n1i0OO) | n1ii1O) | (~ n1ii0O)),
		n10O1i = ((((n1i0il | (~ n10Oil)) | (~ n10Oii)) | (~ n10O0i)) | (~ n10O1O)),
		n10O1l = (((((((((n1i0il | (~ n1iilO)) | n1i0li) | n1i0lO) | n1i0OO) | n1ii1O) | n1ii0O) | n1iiiO) | n1iili) | n1iill),
		n10O1O = ((((((((n1i0il | n1i0li) | n1i0lO) | n1i0OO) | n1ii1O) | n1ii0O) | n1iiiO) | n1iili) | (~ n1iill)),
		n10Oii = ((((n1i0il | n1i0li) | n1i0lO) | n1i0OO) | (~ n1ii1O)),
		n10Oil = (((n1i0il | n1i0li) | n1i0lO) | (~ n1i0OO)),
		n10OiO = (n1i0il | (~ n1i0li)),
		n10Oli = (((((~ n1i10i) | (~ n1i11O)) | (~ n1i11i)) | (~ n10OOl)) | (~ n10OlO)),
		n10Oll = ((((n1il0O | (~ n1i11O)) | (~ n1i11l)) | (~ n10OOl)) | (~ n10OOi)),
		n10OlO = (((((((((nilil | n1il0O) | (~ n1illl)) | n1iiOi) | (~ n1iiOO)) | (~ n1il1i)) | (~ n1il1l)) | (~ n1il1O)) | (~ n1il0i)) | (~ n1il0l)),
		n10OOi = ((((((((n1il0O | (~ n1illl)) | n1iiOi) | (~ n1iiOO)) | (~ n1il1i)) | (~ n1il1l)) | (~ n1il1O)) | (~ n1il0i)) | n1il0l),
		n10OOl = (((((((n1il0O | (~ n1illl)) | n1iiOi) | (~ n1iiOO)) | (~ n1il1i)) | (~ n1il1l)) | (~ n1il1O)) | n1il0i),
		n10OOO = ((((((n1il0O | (~ n1illl)) | n1iiOi) | (~ n1iiOO)) | (~ n1il1i)) | (~ n1il1l)) | n1il1O),
		n11l0l = ((((((n001iO | n001il) | n001li) | n0010l) | n1Ol0l) | n001ii) | n0010O),
		n11l0O = ((((n001iO | n001il) | n0010l) | n1Ol0l) | n0010O),
		n11lii = ((((((((((n0001i | n001OO) | n001Ol) | n001iO) | n001il) | n001Oi) | n001lO) | n001ll) | n001li) | n001ii) | n0010O),
		n11lil = (((((((((n0001i | n001OO) | n001Ol) | n001iO) | n001Oi) | n001lO) | n001ll) | n001li) | n1Ol0l) | n001ii),
		n11liO = (((((((((n0001i | n001OO) | n001Ol) | n001il) | n001Oi) | n001lO) | n001ll) | n001li) | n0010l) | n1Ol0l),
		n11lli = ((((((((((n0001i | n001OO) | n001Ol) | n001iO) | n001Oi) | n001lO) | n001ll) | n001li) | n1Ol0l) | n001ii) | n0010O),
		n11lll = ((((((((((n0001i | n001OO) | n001Ol) | n001il) | n001Oi) | n001lO) | n001ll) | n001li) | n0010l) | n1Ol0l) | n001ii),
		n11llO = (((((((((n0001i | n001OO) | n001Ol) | n001iO) | n001il) | n001Oi) | n001ll) | n0010l) | n1Ol0l) | n0010O),
		n11lOi = ((((((((((n0001i | n001OO) | n001iO) | n001il) | n001Oi) | n001lO) | n001ll) | n0010l) | n1Ol0l) | n001ii) | n0010O),
		n11lOl = ((((((((((n0001i | n001OO) | n001Ol) | n001iO) | n001il) | n001Oi) | n001li) | n0010l) | n1Ol0l) | n001ii) | n0010O),
		n11lOO = (((((((((n001OO | n001Ol) | n001iO) | n001il) | n001Oi) | n001li) | n0010l) | n1Ol0l) | n001ii) | n0010O),
		n11O0i = (n0001O & n11OOO),
		n11O0l = (n11Oil | n11Oii),
		n11O0O = ((~ n0001O) | n11OiO),
		n11O1i = ((((((((((n0001i | n001OO) | n001iO) | n001il) | n001lO) | n001ll) | n001li) | n0010l) | n1Ol0l) | n001ii) | n0010O),
		n11O1l = ((((((((((n001Ol | n001iO) | n001il) | n001Oi) | n001lO) | n001ll) | n001li) | n0010l) | n1Ol0l) | n001ii) | n0010O),
		n11O1O = ((n0001O & (~ n11OOO)) & (~ ((~ n0010i) | (~ n1OlOi)))),
		n11Oii = (n0001O & (nl1O0O & (~ GE_XAUI_SEL))),
		n11Oil = (GE_XAUI_SEL & n1011i),
		n11OiO = ((GE_XAUI_SEL & (~ n1011i)) | ((~ GE_XAUI_SEL) & nl1i0i)),
		n11Oli = ((~ n0001O) | n11OOO),
		n11Oll = (n0001O & (nl1O0O & (~ n1OliO))),
		n11OlO = ((~ n0001O) | n11OiO),
		n11OOi = (n0001O & n11Oil),
		n11OOl = ((~ nl1O0O) | (~ n0001O)),
		n11OOO = (nl1i0i | (n1OliO & (nl1O0O & GE_XAUI_SEL))),
		n1i00i = ((((nillO & nilll) & nilli) & niliO) & nilil),
		n1i00l = (((nilll & nilli) & niliO) & nilil),
		n1i00O = ((nilli & niliO) & nilil),
		n1i01i = ((((((((nilOi & nillO) & nilll) & nilli) & niliO) & nilil) & nilOl) & nilOO) & niO1i),
		n1i01l = ((((((nilOi & nillO) & nilll) & nilli) & niliO) & nilil) & nilOl),
		n1i01O = (((((nilOi & nillO) & nilll) & nilli) & niliO) & nilil),
		n1i0ii = (niliO & nilil),
		n1i0il = ((~ PMADATAWIDTH) & n1i0iO),
		n1i0iO = (((((((((nilOi & nillO) & nilll) & nilli) & niliO) & nilil) & nilOl) & nilOO) & niO1i) & niO1l),
		n1i0li = ((~ PMADATAWIDTH) & n1i0ll),
		n1i0ll = ((((((((nilOi & nillO) & nilll) & nilli) & niliO) & nilOl) & nilOO) & niO1i) & niO1l),
		n1i0lO = (((~ PMADATAWIDTH) & n1i0Ol) | (PMADATAWIDTH & n1i0Oi)),
		n1i0Oi = (((((((nilOi & nillO) & nilll) & nilli) & niliO) & nilil) & nilOl) & nilOO),
		n1i0Ol = (((((((nilOi & nillO) & nilll) & nilli) & nilOl) & nilOO) & niO1i) & niO1l),
		n1i0OO = (((~ PMADATAWIDTH) & n1ii1l) | (PMADATAWIDTH & n1ii1i)),
		n1i10i = (n1il0O | (~ n1iiOi)),
		n1i10l = (((((~ n1i1Ol) | (~ n1i1Oi)) | (~ n1i1ll)) | (~ n1i1iO)) | (~ n1i1ii)),
		n1i10O = ((((n1il0O | (~ n1i1Oi)) | (~ n1i1lO)) | (~ n1i1iO)) | (~ n1i1il)),
		n1i11i = (((((n1il0O | (~ n1illl)) | n1iiOi) | (~ n1iiOO)) | (~ n1il1i)) | n1il1l),
		n1i11l = ((((n1il0O | (~ n1illl)) | n1iiOi) | (~ n1iiOO)) | n1il1i),
		n1i11O = (((n1il0O | (~ n1illl)) | n1iiOi) | n1iiOO),
		n1i1ii = (((((((((n1il0O | n1ilil) | n1illi) | n1ilOi) | n1iO1i) | n1iO0i) | n1iOii) | n1iOil) | n1iOiO) | (~ (((~ PMADATAWIDTH) & (~ niO1l)) | (PMADATAWIDTH & (~ nilOO))))),
		n1i1il = ((((((((n1il0O | n1ilil) | n1illi) | n1ilOi) | n1iO1i) | n1iO0i) | n1iOii) | n1iOil) | (~ n1iOiO)),
		n1i1iO = (((((((n1il0O | n1ilil) | n1illi) | n1ilOi) | n1iO1i) | n1iO0i) | n1iOii) | (~ n1iOil)),
		n1i1li = ((((((n1il0O | n1ilil) | n1illi) | n1ilOi) | n1iO1i) | n1iO0i) | (~ n1iOii)),
		n1i1ll = (((((n1il0O | n1ilil) | n1illi) | n1ilOi) | n1iO1i) | (~ n1iO0i)),
		n1i1lO = ((((n1il0O | n1ilil) | n1illi) | n1ilOi) | (~ n1iO1i)),
		n1i1Oi = (((n1il0O | n1ilil) | n1illi) | (~ n1ilOi)),
		n1i1Ol = (n1il0O | (~ n1ilil)),
		n1i1OO = ((~ PMADATAWIDTH) & n1i01i),
		n1ii0i = (((((nilOi & nillO) & nilll) & nilli) & nilOl) & nilOO),
		n1ii0l = (((((nilOi & nillO) & nilOl) & nilOO) & niO1i) & niO1l),
		n1ii0O = (((~ PMADATAWIDTH) & n1iiil) | (PMADATAWIDTH & n1iiii)),
		n1ii1i = ((((((nilOi & nillO) & nilll) & nilli) & niliO) & nilOl) & nilOO),
		n1ii1l = ((((((nilOi & nillO) & nilll) & nilOl) & nilOO) & niO1i) & niO1l),
		n1ii1O = (((~ PMADATAWIDTH) & n1ii0l) | (PMADATAWIDTH & n1ii0i)),
		n1iiii = ((((nilOi & nillO) & nilll) & nilOl) & nilOO),
		n1iiil = ((((nilOi & nilOl) & nilOO) & niO1i) & niO1l),
		n1iiiO = (((~ PMADATAWIDTH) & (((nilOl & nilOO) & niO1i) & niO1l)) | (PMADATAWIDTH & (((nilOi & nillO) & nilOl) & nilOO))),
		n1iili = (((~ PMADATAWIDTH) & ((nilOO & niO1i) & niO1l)) | (PMADATAWIDTH & ((nilOi & nilOl) & nilOO))),
		n1iill = (((~ PMADATAWIDTH) & (niO1i & niO1l)) | (PMADATAWIDTH & (nilOl & nilOO))),
		n1iilO = (((~ PMADATAWIDTH) & niO1l) | (PMADATAWIDTH & nilOO)),
		n1iiOi = ((~ PMADATAWIDTH) & (~ n1iiOl)),
		n1iiOl = ((((((((nilOi | nillO) | nilll) | nilli) | niliO) | nilil) | nilOl) | nilOO) | niO1i),
		n1iiOO = ((((((nilOi | nillO) | nilll) | nilli) | niliO) | nilil) | nilOl),
		n1il0i = ((nilli | niliO) | nilil),
		n1il0l = (niliO | nilil),
		n1il0O = ((~ PMADATAWIDTH) & (~ n1ilii)),
		n1il1i = (((((nilOi | nillO) | nilll) | nilli) | niliO) | nilil),
		n1il1l = ((((nillO | nilll) | nilli) | niliO) | nilil),
		n1il1O = (((nilll | nilli) | niliO) | nilil),
		n1ilii = (((((((((nilOi | nillO) | nilll) | nilli) | niliO) | nilil) | nilOl) | nilOO) | niO1i) | niO1l),
		n1ilil = ((~ PMADATAWIDTH) & (~ n1iliO)),
		n1iliO = ((((((((nilOi | nillO) | nilll) | nilli) | niliO) | nilOl) | nilOO) | niO1i) | niO1l),
		n1illi = (((~ PMADATAWIDTH) & (~ n1illO)) | (PMADATAWIDTH & (~ n1illl))),
		n1illl = (((((((nilOi | nillO) | nilll) | nilli) | niliO) | nilil) | nilOl) | nilOO),
		n1illO = (((((((nilOi | nillO) | nilll) | nilli) | nilOl) | nilOO) | niO1i) | niO1l),
		n1ilOi = (((~ PMADATAWIDTH) & (~ n1ilOO)) | (PMADATAWIDTH & (~ n1ilOl))),
		n1ilOl = ((((((nilOi | nillO) | nilll) | nilli) | niliO) | nilOl) | nilOO),
		n1ilOO = ((((((nilOi | nillO) | nilll) | nilOl) | nilOO) | niO1i) | niO1l),
		n1iO0i = (((~ PMADATAWIDTH) & (~ n1iO0O)) | (PMADATAWIDTH & (~ n1iO0l))),
		n1iO0l = ((((nilOi | nillO) | nilll) | nilOl) | nilOO),
		n1iO0O = ((((nilOi | nilOl) | nilOO) | niO1i) | niO1l),
		n1iO1i = (((~ PMADATAWIDTH) & (~ n1iO1O)) | (PMADATAWIDTH & (~ n1iO1l))),
		n1iO1l = (((((nilOi | nillO) | nilll) | nilli) | nilOl) | nilOO),
		n1iO1O = (((((nilOi | nillO) | nilOl) | nilOO) | niO1i) | niO1l),
		n1iOii = (((~ PMADATAWIDTH) & (~ (((nilOl | nilOO) | niO1i) | niO1l))) | (PMADATAWIDTH & (~ (((nilOi | nillO) | nilOl) | nilOO)))),
		n1iOil = (((~ PMADATAWIDTH) & (~ ((nilOO | niO1i) | niO1l))) | (PMADATAWIDTH & (~ ((nilOi | nilOl) | nilOO)))),
		n1iOiO = (((~ PMADATAWIDTH) & (~ (niO1i | niO1l))) | (PMADATAWIDTH & (~ (nilOl | nilOO)))),
		n1iOli = (nl0i1i & ((~ nl00OO) & n1l1lO)),
		n1iOll = ((~ nl0i1i) & (nl00OO & n101li)),
		n1iOlO = ((~ nl0i1i) & ((~ nl00OO) & ((~ nl00Ol) & ((~ nl00Oi) & (nl00lO & nl00ll))))),
		n1iOOi = (nl0i1i & (nl00OO & (nl00Ol & (nl00Oi & ((~ nl00lO) & (~ nl00ll)))))),
		n1iOOl = ((((((((((nl00ll ^ (~ SYNC_COMP_PAT[0:0])) | (nl00lO ^ (~ SYNC_COMP_PAT[1:1]))) | (nl00Oi ^ (~ SYNC_COMP_PAT[2:2]))) | (nl00Ol ^ (~ SYNC_COMP_PAT[3:3]))) | (nl00OO ^ (~ SYNC_COMP_PAT[4:4]))) | (nl0i1i ^ (~ SYNC_COMP_PAT[5:5]))) | (nl0i1l ^ (~ SYNC_COMP_PAT[6:6]))) | (nl0i1O ^ (~ SYNC_COMP_PAT[7:7]))) | (nl0i0i ^ (~ SYNC_COMP_PAT[8:8]))) | (nli1ll ^ (~ SYNC_COMP_PAT[9:9]))),
		n1iOOO = ((((((((((nl00ll ^ SYNC_COMP_PAT[0:0]) | (nl00lO ^ SYNC_COMP_PAT[1:1])) | (nl00Oi ^ SYNC_COMP_PAT[2:2])) | (nl00Ol ^ SYNC_COMP_PAT[3:3])) | (nl00OO ^ SYNC_COMP_PAT[4:4])) | (nl0i1i ^ SYNC_COMP_PAT[5:5])) | (nl0i1l ^ SYNC_COMP_PAT[6:6])) | (nl0i1O ^ SYNC_COMP_PAT[7:7])) | (nl0i0i ^ SYNC_COMP_PAT[8:8])) | (nli1ll ^ SYNC_COMP_PAT[9:9])),
		n1l00i = (PMADATAWIDTH & (~ n1l00O)),
		n1l00l = (nll10i & (PMADATAWIDTH & nll10l)),
		n1l00O = (nll10l & nll10i),
		n1l01i = (n1l1OO & n1l1lO),
		n1l01l = (n101ii & n1l1Oi),
		n1l01O = (n101ii & n1l1OO),
		n1l0ii = (wire_nli1li_o[1:1] | wire_nli1li_o[0:0]),
		n1l0il = (wire_nliill_o[1:1] | wire_nliill_o[19:19]),
		n1l0iO = (wire_nliill_o[2:2] | wire_nliill_o[20:20]),
		n1l0li = (wire_nliill_o[3:3] | wire_nliill_o[21:21]),
		n1l0ll = (wire_nliill_o[4:4] | wire_nliill_o[22:22]),
		n1l0lO = (wire_nliill_o[5:5] | wire_nliill_o[23:23]),
		n1l0Oi = (wire_nliill_o[6:6] | wire_nliill_o[24:24]),
		n1l0Ol = (wire_nliill_o[7:7] | wire_nliill_o[25:25]),
		n1l0OO = (((((((((((((wire_nliill_o[31:31] | wire_nliill_o[30:30]) | wire_nliill_o[29:29]) | wire_nliill_o[28:28]) | wire_nliill_o[27:27]) | wire_nliill_o[26:26]) | wire_nliill_o[15:15]) | wire_nliill_o[14:14]) | wire_nliill_o[13:13]) | wire_nliill_o[12:12]) | wire_nliill_o[11:11]) | wire_nliill_o[10:10]) | wire_nliill_o[0:0]) | wire_nliill_o[18:18]),
		n1l10i = (n1000O | n1000l),
		n1l10l = ((~ nl0i1O) & ((~ nl0i1l) & n1l11O)),
		n1l10O = ((~ nli1ll) & ((~ nl0i0i) & ((~ nl0i1O) & (~ nl0i1l)))),
		n1l11i = (((~ (((n1l10O | n1000l) | (((((~ nl0i1l) & n1000O) | (nl0i1l & n1l1ii)) & (~ n1001O)) & (~ (n1iOll | (n1iOli | (n1iOOi | n1iOlO)))))) | ((((~ nli1ll) & n1000O) | (nli1ll & n1l1ii)) & (n1iOlO | (n1001O | n1iOOi))))) & (~ ((n1001l | (n1001i | n101OO)) | (n1l1ll | (n1l01l | (n1l01O | n1l01i)))))) & (~ ((IB_INVALID_CODE[0:0] & ((((~ nl0i1O) & n1iOOi) & n1000i) | (n1000i & (nl0i1O & n1iOlO)))) | (IB_INVALID_CODE[1:1] & ((nl0i0i & (nl0i1O & (n1l11O & n1iOOi))) | ((~ nl0i0i) & ((~ nl0i1O) & (n1l11O & n1iOlO)))))))),
		n1l11l = ((((((~ nl1ill) & ((((((n1l01O | n1l01l) | n1l01i) | (n1l1OO & n1l1Ol)) | (n1l1Oi & n1l1lO)) | n1l1ll) | n1l1li)) | (nl1ill & (n1l1iO | ((~ nl00Ol) & n1l1il)))) | ((~ wire_n0liil_dataout) & ((n1l1ii | n1l10O) | n1l10l))) | (wire_n0liil_dataout & (n1l10i | (nl0i1O & (nl0i1l & n1l11O))))) & (~ DISABLE_RX_DISP)),
		n1l11O = (((((((~ nli1ll) & ((~ nl0i0i) & (nl0i1O & nl0i1l))) | ((~ nli1ll) & (nl0i0i & n101Ol))) | ((~ nli1ll) & (nl0i0i & n101Oi))) | (nli1ll & ((~ nl0i0i) & n101Ol))) | (nli1ll & ((~ nl0i0i) & n101Oi))) | (nli1ll & (nl0i0i & ((~ nl0i1O) & (~ nl0i1l))))),
		n1l1ii = (((((~ nli1ll) & ((~ nl0i0i) & ((~ nl0i1O) & nl0i1l))) | ((~ nli1ll) & ((~ nl0i0i) & (nl0i1O & (~ nl0i1l))))) | ((~ nli1ll) & (nl0i0i & n101lO))) | (nli1ll & ((~ nl0i0i) & n101lO))),
		n1l1il = (n1l1OO & n101li),
		n1l1iO = ((((n1001i | (n1l1Ol & n101iO)) | (n1l1Oi & n101li)) | n101OO) | n1001l),
		n1l1li = (nl00Ol & n1010O),
		n1l1ll = (n101ii & n101iO),
		n1l1lO = (((((~ nl00Ol) & ((~ nl00Oi) & ((~ nl00lO) & nl00ll))) | ((~ nl00Ol) & ((~ nl00Oi) & (nl00lO & (~ nl00ll))))) | ((~ nl00Ol) & (nl00Oi & n1011O))) | (nl00Ol & ((~ nl00Oi) & n1011O))),
		n1l1Oi = (((~ nl0i1i) & nl00OO) | (nl0i1i & (~ nl00OO))),
		n1l1Ol = (((((((~ nl00Ol) & ((~ nl00Oi) & (nl00lO & nl00ll))) | ((~ nl00Ol) & (nl00Oi & n1010l))) | ((~ nl00Ol) & (nl00Oi & n1010i))) | (nl00Ol & ((~ nl00Oi) & n1010l))) | (nl00Ol & ((~ nl00Oi) & n1010i))) | (nl00Ol & (nl00Oi & ((~ nl00lO) & (~ nl00ll))))),
		n1l1OO = ((~ nl0i1i) & (~ nl00OO)),
		n1li0i = ((~ PMADATAWIDTH) & (~ n1li0l)),
		n1li0l = (((nliO1O | nlil0l) | nlil0i) | nlil1O),
		n1li0O = (((((((((wire_nll0OO_dataout | (~ n1liOO)) | (~ n1liOl)) | (~ n1liOi)) | (~ n1lilO)) | (~ n1lill)) | (~ n1lili)) | (~ n1liiO)) | (~ n1liil)) | (~ n1liii)),
		n1li1i = (((((((((wire_nliill_o[25:25] | wire_nliill_o[24:24]) | wire_nliill_o[23:23]) | wire_nliill_o[22:22]) | wire_nliill_o[21:21]) | wire_nliill_o[20:20]) | wire_nliill_o[19:19]) | wire_nliill_o[18:18]) | wire_nliill_o[17:17]) | wire_nliill_o[16:16]),
		n1li1l = ((((((((((((wire_nliill_o[31:31] | wire_nliill_o[30:30]) | wire_nliill_o[29:29]) | wire_nliill_o[28:28]) | wire_nliill_o[27:27]) | wire_nliill_o[26:26]) | wire_nliill_o[15:15]) | wire_nliill_o[14:14]) | wire_nliill_o[13:13]) | wire_nliill_o[12:12]) | wire_nliill_o[11:11]) | wire_nliill_o[10:10]) | wire_nliill_o[0:0]),
		n1li1O = (PMADATAWIDTH & (~ n1li0l)),
		n1liii = (((((((((wire_nll0OO_dataout | wire_nlli1l_dataout) | wire_nlli0i_dataout) | wire_nlliii_dataout) | wire_nllili_dataout) | wire_nlliOi_dataout) | wire_nlll1i_dataout) | wire_nlll0i_dataout) | wire_nlllii_dataout) | (~ wire_nlllli_dataout)),
		n1liil = ((((((((wire_nll0OO_dataout | wire_nlli1l_dataout) | wire_nlli0i_dataout) | wire_nlliii_dataout) | wire_nllili_dataout) | wire_nlliOi_dataout) | wire_nlll1i_dataout) | wire_nlll0i_dataout) | (~ wire_nlllii_dataout)),
		n1liiO = (((((((wire_nll0OO_dataout | wire_nlli1l_dataout) | wire_nlli0i_dataout) | wire_nlliii_dataout) | wire_nllili_dataout) | wire_nlliOi_dataout) | wire_nlll1i_dataout) | (~ wire_nlll0i_dataout)),
		n1lili = ((((((wire_nll0OO_dataout | wire_nlli1l_dataout) | wire_nlli0i_dataout) | wire_nlliii_dataout) | wire_nllili_dataout) | wire_nlliOi_dataout) | (~ wire_nlll1i_dataout)),
		n1lill = (((((wire_nll0OO_dataout | wire_nlli1l_dataout) | wire_nlli0i_dataout) | wire_nlliii_dataout) | wire_nllili_dataout) | (~ wire_nlliOi_dataout)),
		n1lilO = ((((wire_nll0OO_dataout | wire_nlli1l_dataout) | wire_nlli0i_dataout) | wire_nlliii_dataout) | (~ wire_nllili_dataout)),
		n1liOi = (((wire_nll0OO_dataout | wire_nlli1l_dataout) | wire_nlli0i_dataout) | (~ wire_nlliii_dataout)),
		n1liOl = ((wire_nll0OO_dataout | wire_nlli1l_dataout) | (~ wire_nlli0i_dataout)),
		n1liOO = (wire_nll0OO_dataout | (~ wire_nlli1l_dataout)),
		n1ll0i = ((((((((((SYNC_COMP_PAT[0:0] ^ wire_n0liO_dataout) | (SYNC_COMP_PAT[1:1] ^ wire_n0lli_dataout)) | (SYNC_COMP_PAT[2:2] ^ wire_n0lll_dataout)) | (SYNC_COMP_PAT[3:3] ^ wire_n0llO_dataout)) | (SYNC_COMP_PAT[4:4] ^ wire_n0lOi_dataout)) | (SYNC_COMP_PAT[5:5] ^ wire_n0lOl_dataout)) | (SYNC_COMP_PAT[6:6] ^ wire_n0OOi_dataout)) | (wire_n0O1i_dataout ^ wire_nil1l_dataout)) | (wire_n0O1l_dataout ^ wire_nil1O_dataout)) | (wire_nil0i_dataout ^ wire_n0OOl_dataout)),
		n1ll0l = ((((((((((wire_ni0li_dataout ^ niOOO) | (wire_ni0ll_dataout ^ nl11i)) | (wire_ni0lO_dataout ^ nl11l)) | (wire_ni0Oi_dataout ^ nl11O)) | (wire_ni0Ol_dataout ^ nl10i)) | (wire_ni0OO_dataout ^ nl10l)) | (wire_nii1i_dataout ^ nl10O)) | (wire_nii1l_dataout ^ wire_ni11i_dataout)) | (wire_nii1O_dataout ^ wire_n0OOl_dataout)) | (wire_nii0i_dataout ^ wire_ni11l_dataout)),
		n1ll0O = ((((((((((SYNC_COMP_PAT[0:0] ^ niOOO) | (SYNC_COMP_PAT[1:1] ^ nl11i)) | (SYNC_COMP_PAT[2:2] ^ nl11l)) | (SYNC_COMP_PAT[3:3] ^ nl11O)) | (SYNC_COMP_PAT[4:4] ^ nl10i)) | (SYNC_COMP_PAT[5:5] ^ nl10l)) | (SYNC_COMP_PAT[6:6] ^ nl10O)) | (wire_nil1l_dataout ^ wire_ni11i_dataout)) | (wire_nil1O_dataout ^ wire_n0OOl_dataout)) | (wire_nil0i_dataout ^ wire_ni11l_dataout)),
		n1ll1i = ((((((((((wire_n0lil_dataout ^ wire_ni0li_dataout) | (wire_n0liO_dataout ^ wire_ni0ll_dataout)) | (wire_n0lli_dataout ^ wire_ni0lO_dataout)) | (wire_n0lll_dataout ^ wire_ni0Oi_dataout)) | (wire_n0llO_dataout ^ wire_ni0Ol_dataout)) | (wire_n0lOi_dataout ^ wire_ni0OO_dataout)) | (wire_n0lOl_dataout ^ wire_nii1i_dataout)) | (wire_n0lOO_dataout ^ wire_nii1l_dataout)) | (wire_n0O1i_dataout ^ wire_nii1O_dataout)) | (wire_n0O1l_dataout ^ wire_nii0i_dataout)),
		n1ll1l = ((((((((((SYNC_COMP_PAT[0:0] ^ wire_n0lil_dataout) | (SYNC_COMP_PAT[1:1] ^ wire_n0liO_dataout)) | (SYNC_COMP_PAT[2:2] ^ wire_n0lli_dataout)) | (SYNC_COMP_PAT[3:3] ^ wire_n0lll_dataout)) | (SYNC_COMP_PAT[4:4] ^ wire_n0llO_dataout)) | (SYNC_COMP_PAT[5:5] ^ wire_n0lOi_dataout)) | (SYNC_COMP_PAT[6:6] ^ wire_n0lOl_dataout)) | (wire_n0lOO_dataout ^ wire_nil1l_dataout)) | (wire_n0O1i_dataout ^ wire_nil1O_dataout)) | (wire_n0O1l_dataout ^ wire_nil0i_dataout)),
		n1ll1O = ((((((((((wire_ni0li_dataout ^ wire_n0liO_dataout) | (wire_ni0ll_dataout ^ wire_n0lli_dataout)) | (wire_ni0lO_dataout ^ wire_n0lll_dataout)) | (wire_ni0Oi_dataout ^ wire_n0llO_dataout)) | (wire_ni0Ol_dataout ^ wire_n0lOi_dataout)) | (wire_ni0OO_dataout ^ wire_n0lOl_dataout)) | (wire_nii1i_dataout ^ wire_n0OOi_dataout)) | (wire_nii1l_dataout ^ wire_n0O1i_dataout)) | (wire_nii1O_dataout ^ wire_n0O1l_dataout)) | (wire_nii0i_dataout ^ wire_n0OOl_dataout)),
		n1llii = ((((((((((wire_ni0li_dataout ^ nl11i) | (wire_ni0ll_dataout ^ nl11l)) | (wire_ni0lO_dataout ^ nl11O)) | (wire_ni0Oi_dataout ^ nl10i)) | (wire_ni0Ol_dataout ^ nl10l)) | (wire_ni0OO_dataout ^ nl10O)) | (wire_nii1i_dataout ^ nl1ii)) | (wire_nii1l_dataout ^ wire_ni10i_dataout)) | (wire_nii1O_dataout ^ wire_ni11l_dataout)) | (wire_nii0i_dataout ^ wire_ni10l_dataout)),
		n1llil = ((((((((((SYNC_COMP_PAT[0:0] ^ nl11i) | (SYNC_COMP_PAT[1:1] ^ nl11l)) | (SYNC_COMP_PAT[2:2] ^ nl11O)) | (SYNC_COMP_PAT[3:3] ^ nl10i)) | (SYNC_COMP_PAT[4:4] ^ nl10l)) | (SYNC_COMP_PAT[5:5] ^ nl10O)) | (SYNC_COMP_PAT[6:6] ^ nl1ii)) | (wire_nil1l_dataout ^ wire_ni10i_dataout)) | (wire_nil1O_dataout ^ wire_ni11l_dataout)) | (wire_nil0i_dataout ^ wire_ni10l_dataout)),
		n1lliO = ((((((((((wire_ni0li_dataout ^ nl11l) | (wire_ni0ll_dataout ^ nl11O)) | (wire_ni0lO_dataout ^ nl10i)) | (wire_ni0Oi_dataout ^ nl10l)) | (wire_ni0Ol_dataout ^ nl10O)) | (wire_ni0OO_dataout ^ nl1ii)) | (wire_nii1i_dataout ^ nl1il)) | (wire_nii1l_dataout ^ wire_ni1ii_dataout)) | (wire_nii1O_dataout ^ wire_ni10l_dataout)) | (wire_nii0i_dataout ^ wire_ni1il_dataout)),
		n1llli = ((((((((((SYNC_COMP_PAT[0:0] ^ nl11l) | (SYNC_COMP_PAT[1:1] ^ nl11O)) | (SYNC_COMP_PAT[2:2] ^ nl10i)) | (SYNC_COMP_PAT[3:3] ^ nl10l)) | (SYNC_COMP_PAT[4:4] ^ nl10O)) | (SYNC_COMP_PAT[5:5] ^ nl1ii)) | (SYNC_COMP_PAT[6:6] ^ nl1il)) | (wire_nil1l_dataout ^ wire_ni1ii_dataout)) | (wire_nil1O_dataout ^ wire_ni10l_dataout)) | (wire_nil0i_dataout ^ wire_ni1il_dataout)),
		n1llll = ((((((((((wire_ni0li_dataout ^ nl11O) | (wire_ni0ll_dataout ^ nl10i)) | (wire_ni0lO_dataout ^ nl10l)) | (wire_ni0Oi_dataout ^ nl10O)) | (wire_ni0Ol_dataout ^ nl1ii)) | (wire_ni0OO_dataout ^ nl1il)) | (wire_nii1i_dataout ^ nl1iO)) | (wire_nii1l_dataout ^ wire_ni1li_dataout)) | (wire_nii1O_dataout ^ wire_ni1il_dataout)) | (wire_nii0i_dataout ^ wire_ni1ll_dataout)),
		n1lllO = ((((((((((SYNC_COMP_PAT[0:0] ^ nl11O) | (SYNC_COMP_PAT[1:1] ^ nl10i)) | (SYNC_COMP_PAT[2:2] ^ nl10l)) | (SYNC_COMP_PAT[3:3] ^ nl10O)) | (SYNC_COMP_PAT[4:4] ^ nl1ii)) | (SYNC_COMP_PAT[5:5] ^ nl1il)) | (SYNC_COMP_PAT[6:6] ^ nl1iO)) | (wire_nil1l_dataout ^ wire_ni1li_dataout)) | (wire_nil1O_dataout ^ wire_ni1il_dataout)) | (wire_nil0i_dataout ^ wire_ni1ll_dataout)),
		n1llOi = ((((((((((wire_ni0li_dataout ^ nl10i) | (wire_ni0ll_dataout ^ nl10l)) | (wire_ni0lO_dataout ^ nl10O)) | (wire_ni0Oi_dataout ^ nl1ii)) | (wire_ni0Ol_dataout ^ nl1il)) | (wire_ni0OO_dataout ^ nl1iO)) | (wire_nii1i_dataout ^ nl1li)) | (wire_nii1l_dataout ^ wire_ni1Oi_dataout)) | (wire_nii1O_dataout ^ wire_ni1ll_dataout)) | (wire_nii0i_dataout ^ wire_ni1Ol_dataout)),
		n1llOl = ((((((((((SYNC_COMP_PAT[0:0] ^ nl10i) | (SYNC_COMP_PAT[1:1] ^ nl10l)) | (SYNC_COMP_PAT[2:2] ^ nl10O)) | (SYNC_COMP_PAT[3:3] ^ nl1ii)) | (SYNC_COMP_PAT[4:4] ^ nl1il)) | (SYNC_COMP_PAT[5:5] ^ nl1iO)) | (SYNC_COMP_PAT[6:6] ^ nl1li)) | (wire_nil1l_dataout ^ wire_ni1Oi_dataout)) | (wire_nil1O_dataout ^ wire_ni1ll_dataout)) | (wire_nil0i_dataout ^ wire_ni1Ol_dataout)),
		n1llOO = ((((((((((wire_ni0li_dataout ^ nl10l) | (wire_ni0ll_dataout ^ nl10O)) | (wire_ni0lO_dataout ^ nl1ii)) | (wire_ni0Oi_dataout ^ nl1il)) | (wire_ni0Ol_dataout ^ nl1iO)) | (wire_ni0OO_dataout ^ nl1li)) | (wire_nii1i_dataout ^ nl1ll)) | (wire_nii1l_dataout ^ wire_ni01i_dataout)) | (wire_nii1O_dataout ^ wire_ni1Ol_dataout)) | (wire_nii0i_dataout ^ wire_ni01l_dataout)),
		n1lO1i = ((((((((((SYNC_COMP_PAT[0:0] ^ nl10l) | (SYNC_COMP_PAT[1:1] ^ nl10O)) | (SYNC_COMP_PAT[2:2] ^ nl1ii)) | (SYNC_COMP_PAT[3:3] ^ nl1il)) | (SYNC_COMP_PAT[4:4] ^ nl1iO)) | (SYNC_COMP_PAT[5:5] ^ nl1li)) | (SYNC_COMP_PAT[6:6] ^ nl1ll)) | (wire_nil1l_dataout ^ wire_ni01i_dataout)) | (wire_nil1O_dataout ^ wire_ni1Ol_dataout)) | (wire_nil0i_dataout ^ wire_ni01l_dataout)),
		n1lO1l = ((((((((((wire_ni0li_dataout ^ nl10O) | ((wire_ni0ll_dataout ^ nl1ii) ^ (~ w_n1lO0l284w))) | ((wire_ni0lO_dataout ^ nl1il) ^ (~ w_n1lO1O291w))) | (wire_ni0Oi_dataout ^ nl1iO)) | (wire_ni0Ol_dataout ^ nl1li)) | (wire_ni0OO_dataout ^ nl1ll)) | (wire_nii1i_dataout ^ nl1lO)) | (wire_nii1l_dataout ^ wire_ni00i_dataout)) | (wire_nii1O_dataout ^ wire_ni01l_dataout)) | (wire_nii0i_dataout ^ wire_ni00l_dataout)),
		n1lOii = (((((((((((SYNC_COMP_PAT[0:0] ^ nl10O) ^ (~ w_n1O11i239w)) | ((SYNC_COMP_PAT[1:1] ^ nl1ii) ^ (~ w_n1lOOl245w))) | ((SYNC_COMP_PAT[2:2] ^ nl1il) ^ (~ w_n1lOlO252w))) | (SYNC_COMP_PAT[3:3] ^ nl1iO)) | (SYNC_COMP_PAT[4:4] ^ nl1li)) | (SYNC_COMP_PAT[5:5] ^ nl1ll)) | ((SYNC_COMP_PAT[6:6] ^ nl1lO) ^ (~ w_n1lOli265w))) | (wire_nil1l_dataout ^ wire_ni00i_dataout)) | ((wire_nil1O_dataout ^ wire_ni01l_dataout) ^ (~ w_n1lOil274w))) | (wire_nil0i_dataout ^ wire_ni00l_dataout)),
		n1O0il = (SYNC_COMP_SIZE[1:1] | SYNC_COMP_SIZE[0:0]),
		n1O0iO = (SYNC_COMP_SIZE[1:1] | (~ SYNC_COMP_SIZE[0:0])),
		n1O0li = (wire_n1Olli_dataout & (~ (((n1Oi1l & n1Oi1i) & n1O0OO) & (~ n1O0Ol)))),
		n1O0ll = (n0000O & (~ n1Oi0O)),
		n1O0Ol = (((((~ n1liOO) | (~ n1liOi)) | (~ n1lill)) | (~ n1liiO)) | (~ n1liii)),
		n1O0OO = (((((~ n1liOl) | (~ n1liOi)) | (~ n1lili)) | (~ n1liiO)) | (~ n1li0O)),
		n1O11O = (((((((((((wire_ni0li_dataout ^ nl1ii) ^ (~ w_n1O1li200w)) | (wire_ni0ll_dataout ^ nl1il)) | (wire_ni0lO_dataout ^ nl1iO)) | ((wire_ni0Oi_dataout ^ nl1li) ^ (~ w_n1O1il210w))) | ((wire_ni0Ol_dataout ^ nl1ll) ^ (~ w_n1O10O217w))) | (wire_ni0OO_dataout ^ nl1lO)) | (wire_nii1i_dataout ^ nl1Oi)) | ((wire_nii1l_dataout ^ wire_ni0ii_dataout) ^ (~ w_n1O10i228w))) | (wire_nii1O_dataout ^ wire_ni00l_dataout)) | (wire_nii0i_dataout ^ wire_ni0il_dataout)),
		n1O1lO = (((((((((((SYNC_COMP_PAT[0:0] ^ nl1ii) | ((SYNC_COMP_PAT[1:1] ^ nl1il) ^ (~ w_n1O00O157w))) | (SYNC_COMP_PAT[2:2] ^ nl1iO)) | ((SYNC_COMP_PAT[3:3] ^ nl1li) ^ (~ w_n1O00i166w))) | ((SYNC_COMP_PAT[4:4] ^ nl1ll) ^ (~ w_n1O01l173w))) | (SYNC_COMP_PAT[5:5] ^ nl1lO)) | (SYNC_COMP_PAT[6:6] ^ nl1Oi)) | ((wire_nil1l_dataout ^ wire_ni0ii_dataout) ^ (~ w_n1O1OO184w))) | (wire_nil1O_dataout ^ wire_ni00l_dataout)) | (wire_nil0i_dataout ^ wire_ni0il_dataout)) | (~ w_n1O1Oi194w)),
		n1Oi0O = ((((n1Oi1l & n1Oi1i) & n1O0OO) & (~ n1O0Ol)) & w_n1O0lO58w),
		n1Oi1i = (((((~ n1liOl) | (~ n1liOi)) | (~ n1lilO)) | (~ n1lill)) | (~ n1li0O)),
		n1Oi1l = ((wire_nll0OO_dataout | (~ n1liOO)) | (~ n1li0O)),
		n1Oi1O = ((n0000O & n1Oi0O) & w_n1Oi0i50w),
		n1Oiii = (((((n001OO | n001il) | n001Oi) | n001ll) | n0010l) | n001ii),
		n1Oiil = (((((n001OO | n001Ol) | n001ll) | n001li) | n0010l) | n1Ol0l),
		n1OiiO = ((((n001iO | n001Oi) | n001lO) | n001ll) | n001li),
		n1Oili = ((((n0001i | n001OO) | n001Ol) | n001iO) | n001il),
		n1OiOO = (nii1li | nii1iO),
		n1Ol1O = rcvd_clk,
		RLV = n1OiOO,
		RLV_lt = ((((nii11O | nii11l) | (~ w_n1OiOi29w)) | (nii11i & DWIDTH)) | (~ w_n1Oill36w)),
		signal_detect_sync = n0001O,
		SUDI = {nl01ii, nl010O, nl010l, nl010i, nl011O, nl011l, nl011i, nl1OOO, nl1OOl, nl1OOi, nl1OlO, nl1Oll, nl1Oli},
		SUDI_pre = {nli1ll, nl0i0i, nl0i1O, nl0i1l, nl0i1i, nl00OO, nl00Ol, nl00Oi, nl00lO, nl00ll},
		sync_curr_st = {n1Oili, n1OiiO, (~ n1Oiil), n1Oiii},
		sync_status = n1Olil,
		w_n1lO0l284w = n1lO0l57,
		w_n1lO1O291w = n1lO1O60,
		w_n1lOil274w = n1lOil54,
		w_n1lOli265w = n1lOli51,
		w_n1lOlO252w = n1lOlO48,
		w_n1lOOl245w = n1lOOl45,
		w_n1O00i166w = n1O00i18,
		w_n1O00O157w = n1O00O15,
		w_n1O01l173w = n1O01l21,
		w_n1O0lO58w = n1O0lO12,
		w_n1O10i228w = n1O10i39,
		w_n1O10O217w = n1O10O36,
		w_n1O11i239w = n1O11i42,
		w_n1O1il210w = n1O1il33,
		w_n1O1li200w = n1O1li30,
		w_n1O1Oi194w = n1O1Oi27,
		w_n1O1OO184w = n1O1OO24,
		w_n1Oi0i50w = n1Oi0i9,
		w_n1Oill36w = n1Oill6,
		w_n1OiOi29w = n1OiOi3;
endmodule //altgxb_hssi_rx_wal_rtl
//synopsys translate_on
//VALID FILE
//
// ALTGXB_HSSI_WORD_ALIGNER
//

`timescale 1 ps/1 ps

module altgxb_hssi_word_aligner 
	(
		datain, 
		clk, 
		softreset, 
		enacdet, 
		bitslip, 
		a1a2size, 
		aligneddata, 
		aligneddatapre, 
		invalidcode, 
		invalidcodepre, 
		syncstatus, 
		syncstatusdeskew, 
		disperr, 
		disperrpre, 
		patterndetectpre,
		patterndetect
	);

input [9:0] datain;
input clk;
input softreset;
input enacdet;
input bitslip;
input a1a2size;

output [9:0] aligneddata;
output [9:0] aligneddatapre;
output invalidcode;
output invalidcodepre;
output syncstatus;
output syncstatusdeskew;
output disperr;
output disperrpre;
output patterndetect;
output patterndetectpre;

parameter channel_width = 10;
parameter align_pattern_length = 10;
parameter infiniband_invalid_code = 0;
parameter align_pattern = "0000000101111100";
parameter synchronization_mode = "XAUI";
parameter use_8b_10b_mode = "ON";
parameter use_auto_bit_slip = "ON"; 


// input interface

wire         rcvd_clk;
wire         soft_reset;
wire         LP10BEN;
wire	     RLV_EN;
wire  [4:0]  RUNDISP_SEL;
wire 	     PMADATAWIDTH;
wire  [15:0] SYNC_COMP_PAT; 
wire  [1:0]  SYNC_COMP_SIZE;
wire  [1:0]  IB_INVALID_CODE;
wire         AUTOBYTEALIGN_DIS;
wire	     SYNC_SM_DIS;
wire	     GE_XAUI_SEL;
wire	     encdet_prbs;
wire	     BITSLIP;
wire         ENCDT;
wire         prbs_en;
wire         DISABLE_RX_DISP;
wire         signal_detect;       // signaldetect from PMA
wire  [9:0]  PUDI;                // from rx serdes
wire  [9:0]  PUDR;                // Loopback data from TX 

wire         A1A2_SIZE;           // PLD signal to select between 
                                  // A1A2 and A1A1A2A2 pattern detection
wire         DWIDTH;

// output interface

wire         cg_comma;            // is patterndetect when J = 10
wire         sync_status;         // from Sync SM to deskew state machine
wire         signal_detect_sync;  // Synchronized signal_detect
wire [12:0]  SUDI;               
wire [9:0]   SUDI_pre;            // to deskew fifo
wire         RLV;
wire         RLV_lt; 
wire [3:0]   sync_curr_st;        // Current state of Sync SM

// function to convert align_pattern to binary
function [15 : 0] pattern_conversion;
    input  [127 : 0] s;
    reg [127 : 0] reg_s;
    reg [15 : 0] digit;
    reg [7 : 0] tmp;
    integer   m;
    begin
      
        reg_s = s;
        for (m = 15; m >= 0; m = m-1 )
        begin
            tmp = reg_s[127 : 120];
            digit[m] = tmp & 8'b00000001;
            reg_s = reg_s << 8;
        end
          
        pattern_conversion = {digit[15], digit[14], digit[13], digit[12], digit[11], digit[10], digit[9], digit[8], digit[7], digit[6], digit[5], digit[4], digit[3], digit[2], digit[1], digit[0]};
    end   
endfunction


// assing input interface

assign RLV_EN      = 1'b0;          // in RX_SERDES
assign RUNDISP_SEL = 4'b1000;       // in RX_SERDES
assign DWIDTH      = 1'b0;          // in RX_SERDES - Only used in run length check
assign LP10BEN     = 1'b0;           // Mux is taken cared in top level
assign DISABLE_RX_DISP = 1'b0;      

assign PMADATAWIDTH   = (align_pattern_length == 16 || align_pattern_length == 8) ? 1'b1 : 1'b0; 
assign SYNC_COMP_PAT  = pattern_conversion(align_pattern);                                       
assign SYNC_COMP_SIZE = (align_pattern_length == 7)  ? 2'b00 : 
                        (align_pattern_length == 16 || align_pattern_length == 8) ? 2'b01 : 2'b10;  
								  

assign SYNC_SM_DIS = (synchronization_mode == "NONE" || synchronization_mode == "NONE") ? 1'b1 : 1'b0;
assign GE_XAUI_SEL = (synchronization_mode == "GIGE" || synchronization_mode == "GIGE") ? 1'b1 : 1'b0;  

assign AUTOBYTEALIGN_DIS = (use_auto_bit_slip == "ON" || use_auto_bit_slip == "ON") ? 1'b0 : 1'b1;
       
assign IB_INVALID_CODE = (infiniband_invalid_code == 0) ? 2'b00 :
                         (infiniband_invalid_code == 1) ? 2'b01 : 
                         (infiniband_invalid_code == 2) ? 2'b10 :  2'b11;

assign prbs_en = 1'b0;  
assign encdet_prbs = 1'b0;
assign signal_detect = 1'b1;

assign rcvd_clk   = clk;           
assign soft_reset = softreset;
assign BITSLIP    = bitslip;
assign ENCDT      = enacdet;

// filtering X values that impact state machines (cg_common, cg_invalid, kchar)
assign PUDI[0]    = (datain[0] === 1'b1 || datain[0] === 1'b0) ? datain[0] : 1'b0;
assign PUDI[1]    = (datain[1] === 1'b1 || datain[1] === 1'b0) ? datain[1] : 1'b0;
assign PUDI[2]    = (datain[2] === 1'b1 || datain[2] === 1'b0) ? datain[2] : 1'b0;
assign PUDI[3]    = (datain[3] === 1'b1 || datain[3] === 1'b0) ? datain[3] : 1'b0;
assign PUDI[4]    = (datain[4] === 1'b1 || datain[4] === 1'b0) ? datain[4] : 1'b0;
assign PUDI[5]    = (datain[5] === 1'b1 || datain[5] === 1'b0) ? datain[5] : 1'b0;
assign PUDI[6]    = (datain[6] === 1'b1 || datain[6] === 1'b0) ? datain[6] : 1'b0;
assign PUDI[7]    = (datain[7] === 1'b1 || datain[7] === 1'b0) ? datain[7] : 1'b0;
assign PUDI[8]    = (datain[8] === 1'b1 || datain[8] === 1'b0) ? datain[8] : 1'b0;
assign PUDI[9]    = (datain[9] === 1'b1 || datain[9] === 1'b0) ? datain[9] : 1'b0;

assign A1A2_SIZE  = a1a2size;
assign PUDR       = 10'bxxxxxxxxxx;  // Taken cared in top-level          


// assing output interface

assign aligneddata    = SUDI[9:0];
assign invalidcode    = SUDI[10];
assign syncstatus     = SUDI[11];
assign disperr        = SUDI[12];

// from GIGE/XAUI sync state machine - to XGM dskw SM and Rate Matching
assign syncstatusdeskew = sync_status;

assign patterndetect = cg_comma;    // only for J=10

assign aligneddatapre = SUDI_pre;
assign invalidcodepre = 1'b0;       // unused
assign disperrpre     = 1'b0;       // unused
assign patterndetectpre = 1'b0;     // unused


// instantiating RTL

altgxb_hssi_rx_wal_rtl m_wal_rtl (
                 .rcvd_clk (rcvd_clk),
                 .soft_reset (soft_reset),
                 .LP10BEN (LP10BEN),
			     .RLV_EN (RLV_EN),
			     .RUNDISP_SEL (RUNDISP_SEL),
			     .PMADATAWIDTH (PMADATAWIDTH),
			     .SYNC_COMP_PAT (SYNC_COMP_PAT),
			     .SYNC_COMP_SIZE (SYNC_COMP_SIZE),
			     .IB_INVALID_CODE (IB_INVALID_CODE),
			     .AUTOBYTEALIGN_DIS (AUTOBYTEALIGN_DIS),
			     .BITSLIP (BITSLIP),
                 .DISABLE_RX_DISP (DISABLE_RX_DISP),
                 .ENCDT (ENCDT),
                 .SYNC_SM_DIS (SYNC_SM_DIS),
                 .prbs_en (prbs_en),
			     .encdet_prbs (encdet_prbs),
			     .GE_XAUI_SEL (GE_XAUI_SEL),
                 .signal_detect (signal_detect),
                 .PUDI (PUDI),
                 .PUDR (PUDR),
                 .cg_comma (cg_comma),
                 .sync_status (sync_status),
                 .signal_detect_sync (signal_detect_sync),
                 .SUDI (SUDI),
                 .SUDI_pre (SUDI_pre),
                 .RLV (RLV),
                 .RLV_lt (RLV_lt),
			     .sync_curr_st (sync_curr_st),
                 .A1A2_SIZE(A1A2_SIZE),
                 .DWIDTH(DWIDTH)
);

endmodule
///////////////////////////////////////////////////////////////////////////////
//
//                            ALTGXB_COMP_FIFO_CORE
//
///////////////////////////////////////////////////////////////////////////////

module altgxb_comp_fifo_core
   (
    reset, 
    writeclk, 
    readclk, 
    underflow, 
    overflow,
    errdetectin,
    disperrin,   
    patterndetectin,
    disablefifowrin, 
    disablefifordin, 
    re, 
    we,
    datain,
    datainpre,
    syncstatusin, 
    disperr,
    alignstatus,
    fifordin, 
    fifordout,
    decsync, 
    fifocntlt5, 
    fifocntgt9, 
    done,
    fifoalmostful, 
    fifofull, 
    fifoalmostempty, 
    fifoempty,
    alignsyncstatus, 
    smenable, 
    disablefifordout,
    disablefifowrout, 
    dataout, 
    codevalid,
    errdetectout,
    patterndetect,    
    syncstatus
    );

   parameter 	 use_rate_match_fifo = "ON";
   parameter 	 rate_matching_fifo_mode = "XAUI";
   parameter 	 use_channel_align = "ON";
   parameter 	 channel_num = 0;
   parameter     for_engineering_sample_device = "ON";  // new in 3.0 sp2

   input 	reset;
   input 	writeclk;
   input 	readclk;
   input 	underflow;
   input 	overflow;
   input 	errdetectin;    
   input 	disperrin;      
   input 	patterndetectin;
   input 	disablefifordin;
   input 	disablefifowrin;
   wire 	ge_xaui_sel;
   input 	re;
   input 	we;
   input [9:0] 	datain;
   input [9:0] 	datainpre;
   input 	syncstatusin;
   input 	alignstatus;
   input 	fifordin;
   output 	fifordout;
   output 	fifoalmostful;
   output 	fifofull;
   output 	fifoalmostempty;
   output 	fifoempty;
   output 	decsync;
   output 	fifocntlt5;
   output 	fifocntgt9;
   output 	done;
   output 	alignsyncstatus;
   output 	smenable;
   output 	disablefifordout;
   output 	disablefifowrout;
   output [9:0] dataout;
   output 	 codevalid;
   output 	 errdetectout;
   output 	 syncstatus;
   output 	 patterndetect;
   output 	 disperr;

   reg 		 decsync;
   reg 		 decsync_1;
   wire 	 alignsyncstatus;
   wire	         alignstatus_dly;
   wire	         re_dly;
   wire [9:0] 	 dataout;
   wire 	 fifocntlt5;
   wire 	 fifo_cnt_lt_8;
   wire 	 fifo_cnt_lt_9;
   wire 	 fifo_cnt_lt_7;
   wire 	 fifo_cnt_lt_12;
   wire 	 fifo_cnt_lt_4;
   wire 	 fifo_cnt_gt_10;
   wire 	 fifocntgt9;
   wire 	 fifo_cnt_gt_8;
   wire 	 fifo_cnt_gt_13;
   wire 	 fifo_cnt_gt_5;
   wire 	 fifo_cnt_gt_6;
   wire 	 done;
   wire 	 smenable;
   wire 	 codevalid;
   
   reg 		 fifoalmostful;
   reg 		 fifofull;
   reg 		 fifoalmostempty;
   reg 		 fifoempty;
   reg 		 almostfull_1;
   reg 		 almostfull_sync;
   reg 		 almostempty_1;
   reg 		 almostempty_sync;
   reg 		 full_1;
   reg 		 full_sync;
   reg 		 empty_1;
   reg 		 empty_sync;
   reg 		 rdenable_sync_1;
   reg 		 rdenable_sync;
   reg 		 write_enable_sync;
   reg 		 write_enable_sync_1;
   reg 		 fifo_dec_dly;
   reg [3:0] 	 count;
   reg [1:0] 	 count_read;
   wire 	 comp_write_d;
   reg 		 comp_write_pre;
   wire 	 comp_write;
   wire 	 write_detect_d;
   reg 		 write_detect_pre;
   wire 	 write_detect;
   wire 	 comp_read_d;
   reg 		 comp_read;
   wire 	 detect_read_d;
   reg 		 detect_read;
   reg 		 comp_read_ext;
   wire 	 disablefifowrout;
   wire 	 disablefifordout;
   wire 	 fifordout;
   reg 		 read_eco;
   wire          read_eco_dly;
   wire 	 reset_fifo_dec;
   
   reg 		 read_sync_int_1;
   reg 		 read_sync_int;
   wire 	 read_sync;
   reg 		 fifo_dec;
   reg 		 done_write;
   reg 		 done_read;
   reg 		 underflow_sync_1;
   reg 		 underflow_sync;
   reg 		 done_read_sync_1;
   reg 		 done_read_sync;
   wire 	 alignsyncstatus_sync;
   reg 		 alignstatus_sync_1;
   reg 		 alignstatus_sync;
   reg 		 syncstatus_sync_1;
   reg 		 syncstatus_sync;
   
   integer 	 write_ptr, read_ptr1, read_ptr2;
   integer 	 i, j, k;
   reg [14*12-1:0] fifo;
   
   wire [10:0] 	   fifo_data_in;
   wire [11:0] 	   comp_pat1;
   wire [11:0] 	   comp_pat2;
   wire [12:0] 	   fifo_data_in_pre;
   reg [13:0] 	   fifo_data_out1_sync;
   reg [13:0] 	   fifo_data_out1_sync_dly;
   reg 		   fifo_data_out1_sync_valid;
   reg [13:0] 	   fifo_data_out2_sync;
   reg [13:0] 	   fifo_data_out1_tmp;
   reg [12:0] 	   fifo_data_out2_tmp;

   wire [13:0] 	   fifo_data_out1;
   wire [13:0] 	   fifo_data_out2;
   reg 		   genericfifo_sync_clk2_1, genericfifo_sync_clk2, genericfifo_sync_clk1_1, genericfifo_sync_clk1; 

   wire 	   onechannel;
   wire 	   deskewenable;
   wire 	   matchenable;
   wire 	   menable;
   wire 	   genericfifo;
   wire 	   globalenable;
   reg             writeclk_dly;
      
   assign onechannel   = (channel_num == 0) ? 1'b1 : 1'b0;
   assign deskewenable = (use_channel_align == "ON") ? 1'b1 : 1'b0;
   assign matchenable  = (use_rate_match_fifo == "ON") ? 1'b1 : 1'b0;
   assign menable      = matchenable && ~deskewenable;
   assign genericfifo  = (rate_matching_fifo_mode == "NONE") ? 1'b1 : 1'b0;
   assign globalenable = matchenable && deskewenable;
   assign ge_xaui_sel = (rate_matching_fifo_mode == "GIGE") ? 1'b1 : 1'b0;
   
   always @ (writeclk)
     begin
   writeclk_dly <= writeclk;
     end
   
   // COMPOSTION WRITE LOGIC
   always @ (posedge reset or posedge writeclk_dly)
      begin
	 if (reset)
	    comp_write_pre <= 1'b0;
	 else if (alignsyncstatus && (write_detect || ~ge_xaui_sel))
	    comp_write_pre <= comp_write_d;
	      else
		 comp_write_pre <= 1'b0;
      end
   
   // WRITE DETECT LOGIC
   always @ (posedge reset or posedge writeclk_dly)
      begin
	 if (reset)
	    write_detect_pre <= 1'b0;
	 else if (alignsyncstatus && ge_xaui_sel)
	    write_detect_pre <= write_detect_d;
	      else
		 write_detect_pre <= 1'b0;
      end
   
   // CLOCK COMP READ   
   always @ (posedge reset or posedge readclk)
      begin
	 if (reset)
	    begin
	       comp_read <= 1'b0;
	       comp_read_ext <= 1'b0;
	    end
	 else 
	    begin
	       comp_read_ext <= underflow_sync && comp_read && ge_xaui_sel;
	       if (alignsyncstatus_sync && (detect_read || ~ge_xaui_sel))
		  comp_read <= comp_read_d & ~fifo_data_out2_sync[10] & ~fifo_data_out2_sync[12];
	       else
		  comp_read <= 1'b0;
	    end
      end
   
   // READ DETECT LOGIC 
   always @ (posedge reset or posedge readclk)
      begin
	 if (reset)
	    detect_read <= 1'b0;
	 else if (alignsyncstatus_sync && ge_xaui_sel)
	    detect_read <= detect_read_d & ~fifo_data_out2_sync[10] & ~fifo_data_out2_sync[12];
	      else
		 detect_read <= 1'b0;
      end
   
   assign fifo_cnt_lt_4 = (count < 4);
   assign fifocntlt5 = (count < 5);
   assign fifo_cnt_lt_7 = (count < 7);
   assign fifo_cnt_lt_8 = (count < 8);  // added in REV-C
   assign fifo_cnt_lt_9 = (count < 9);
   assign fifo_cnt_lt_12 = (count < 12);
   assign fifo_cnt_gt_5 = (count > 5);
   assign fifo_cnt_gt_6 = (count > 6);  // added in REV-C
   assign fifo_cnt_gt_8 = (count > 8);
   assign fifocntgt9 = (count > 9);
   assign fifo_cnt_gt_10 = (count > 10);
   assign fifo_cnt_gt_13 = (count > 13);

   assign disablefifowrout = (globalenable && !onechannel) ? disablefifowrin : overflow & comp_write & ~done_write;

   // FIFO COUNT LOGIC   
   always @(posedge reset or posedge writeclk_dly)
      begin
	 if (reset)
	    count <= 4'b0000;
	 else if (genericfifo_sync_clk1)
	    begin
	       if (write_enable_sync && ~decsync)
		  count <= count + 1;
	       else if (write_enable_sync && decsync)
		  count <= count -2;
		    else if (~write_enable_sync && decsync)
		       count <= count - 3;
			 else
			    count <= count;
	    end
	      else 
		 begin
		    if (!alignsyncstatus)
		       count <= 4'b0000;
		    else if (~decsync && ~disablefifowrout)
		       count <= count + 1;
			 else if (decsync && ~disablefifowrout)
			    count <= count -2;
			      else if (~ge_xaui_sel && decsync && disablefifowrout)
				 count <= count - 3;
				   else if (ge_xaui_sel && decsync && disablefifowrout)
				      count <= count - 4;
					else if (ge_xaui_sel && ~decsync && disablefifowrout)
					   count <= count - 1;
					     else
						count <= count;
		 end
      end
   
   // COMPENSATION DONE LOGIC   
   always @(posedge reset or posedge writeclk_dly)
      begin
	 if (reset)
	    done_write <= 1'b0;
	 else
	    done_write <= overflow && comp_write; 
      end
   
   // FIFO ALMOST FULL   
   always @(posedge reset or posedge writeclk_dly)
      begin
	 if (reset)
	    almostfull_1 <= 1'b0;
	 else if (almostfull_1)
	    almostfull_1 <= ~fifo_cnt_lt_8;
	      else 
		 almostfull_1 <= fifocntgt9;
      end
   
   // FIFO ALMOST EMPTY LOGIC
   always @(posedge reset or posedge writeclk_dly)
      begin
	 if (reset)
	    almostempty_1 <= 1'b1;
	 else if (almostempty_1)
	    almostempty_1 <= ~fifo_cnt_gt_6;
	      else
		 almostempty_1 <= fifocntlt5;
      end
   
   // FIFO FULL LOGIC
   always @(posedge reset or posedge writeclk_dly)
      begin
	 if (reset)
	    full_1 <= 1'b0;
	 else if (full_1)
	    full_1 <= ~fifo_cnt_lt_12;
	      else
		 full_1 <= fifo_cnt_gt_13;
      end
   
   // FIFO EMPTY LOGIC
   always @(posedge reset or posedge writeclk_dly)
      begin
	 if (reset)
	    empty_1 <= 1'b1;
	 else if (empty_1)
	    empty_1 <= ~fifo_cnt_gt_5;
	      else
		 empty_1 <= fifo_cnt_lt_4;
      end
   
   assign read_sync = (globalenable && !onechannel)? fifordin : fifordout;
   assign fifordout = read_sync_int;

   always @ (posedge reset or posedge writeclk_dly)
      begin
	 if (reset)
	    read_eco <= 1'b0;
	 else if (read_eco && (count <= 4'd2))
	    read_eco <= 1'b0;
	      else if (!read_eco && (count == 4'd2))
		 read_eco <= 1'b1;
      end
   
   assign #1 alignstatus_dly = alignstatus;
   assign #1 read_eco_dly = read_eco;
   assign #1 re_dly = re;

   always @(posedge reset or posedge readclk)
      begin
	 if (reset)
	    begin
	       read_sync_int_1 <= 1'b0;
	       read_sync_int <= 1'b0;
	       underflow_sync_1 <= 1'b0;
	       underflow_sync <= 1'b0;
	       alignstatus_sync_1 <= 1'b0;
	       alignstatus_sync <= 1'b0;
	       syncstatus_sync_1 <= 1'b0;
	       syncstatus_sync <= 1'b0;
	       rdenable_sync_1 <= 1'b0;
	       rdenable_sync <= 1'b0;
	       fifo_data_out1_sync_valid <= 1'b0;
	       fifo_dec_dly <= 1'b0;
	       almostfull_sync <= 1'b0;
	       almostempty_sync <= 1'b1;
	       full_sync <= 1'b0;
	       empty_sync <= 1'b1;
	       fifoalmostful <= 1'b0;
	       fifoalmostempty <= 1'b1;
	       fifofull <= 1'b0;
	       fifoempty <= 1'b1;
	       genericfifo_sync_clk2_1 <= 1'b0;
	       genericfifo_sync_clk2   <= 1'b0;
	    end
	 else
	    begin
          read_sync_int_1 <= read_eco_dly & ~genericfifo_sync_clk2;
	       read_sync_int <= read_sync_int_1;
	       underflow_sync_1 <= underflow;
	       underflow_sync <= underflow_sync_1;
          alignstatus_sync_1 <= alignstatus_dly;
	       alignstatus_sync <= alignstatus_sync_1;
	       syncstatus_sync_1 <= syncstatusin;
	       syncstatus_sync <= syncstatus_sync_1;
	       rdenable_sync_1 <= (re_dly & genericfifo);
	       rdenable_sync <= rdenable_sync_1;
	       fifo_data_out1_sync_valid <= (~genericfifo_sync_clk2 & alignsyncstatus_sync & read_sync) |
					    (genericfifo_sync_clk2 & rdenable_sync);
	       fifo_dec_dly <= fifo_dec;
	       almostfull_sync <= almostfull_1;
	       almostempty_sync <= almostempty_1;
	       full_sync <= full_1;
	       empty_sync <= empty_1;
	       fifoalmostful <= almostfull_sync;
	       fifoalmostempty <= almostempty_sync;
	       fifofull <= full_sync;
	       fifoempty <= empty_sync;
	       genericfifo_sync_clk2_1 <= genericfifo;
	       genericfifo_sync_clk2   <= genericfifo_sync_clk2_1;
	    end
      end
   
   // DISABLE READ LOGIC
   assign disablefifordout = (globalenable && !onechannel) ? disablefifordin
			    : (underflow_sync & (comp_read | comp_read_ext) & ~done_read);
   
   // 2 BIT COUNTER LOGIC   
   always @(posedge reset or posedge readclk)
      begin
	 if (reset)
	    count_read <= 2'b00;
	 else if (!alignsyncstatus_sync && !genericfifo_sync_clk2)
	    count_read <= 2'b00;
	      else if ((read_sync && ~disablefifordout) || rdenable_sync)
		 if (count_read == 2'b10)
		    count_read <= 2'b00;
		 else
		    count_read <= count_read + 1;
		   else
		      count_read <= count_read;
      end
   
   // COMPENSATION DONE (READ)   
   always @(posedge reset or posedge readclk)
      begin
	 if (reset)
	    done_read <= 1'b0;
	 else if (underflow_sync && ((comp_read && ~ge_xaui_sel) || (comp_read_ext && ge_xaui_sel))) 
	    done_read <= 1'b1;
	      else if (~underflow_sync)
		 done_read <= 1'b0;
		   else
		      done_read <= done_read;
      end
   
   //DECREMENT FIFO LOGIC
   assign reset_fifo_dec = (reset | ~(~fifo_dec_dly | readclk));
   always @(posedge reset_fifo_dec or posedge readclk)
      begin
	 if (reset_fifo_dec) 
	    fifo_dec <= 1'b0;
	 else if (count_read == 2'b01 && ( (~disablefifordout && ~genericfifo_sync_clk2) || 
					    (rdenable_sync && genericfifo_sync_clk2) ))
	    fifo_dec <= 1'b1;
	      else
		 fifo_dec <= fifo_dec;
      end
   
   // WRITE CLOCK DELAY LOGIC
   always @(posedge reset or posedge writeclk_dly)
      begin
	 if (reset)
	    begin
	       decsync_1 <= 1'b0;
	       decsync <= 1'b0;
	       done_read_sync_1 <= 1'b0;
	       done_read_sync <= 1'b0;
	       write_enable_sync_1 <= 1'b0;
	       write_enable_sync <= 1'b0;
	       genericfifo_sync_clk1_1 <= 1'b0;
	       genericfifo_sync_clk1   <= 1'b0;
	    end
	 else
	    begin
	       decsync_1 <= fifo_dec;
	       decsync <= decsync_1 && ~decsync;
	       done_read_sync_1 <= done_read;
	       done_read_sync <= done_read_sync_1;
	       write_enable_sync_1 <= (we & genericfifo);
	       write_enable_sync <= write_enable_sync_1;
	       genericfifo_sync_clk1_1 <= genericfifo;
	       genericfifo_sync_clk1   <= genericfifo_sync_clk1_1;
	    end
      end

   // FIFO WRITE POINTER LOGIC 
   always @(posedge reset or writeclk_dly)
      begin
	 if (reset)
	    write_ptr <= 0; 
    if(writeclk_dly)
      begin
         if (!alignsyncstatus && !genericfifo_sync_clk1)
	    write_ptr <= 0; 
	      else if ( ((write_enable_sync && genericfifo_sync_clk1) || (!disablefifowrout && !genericfifo_sync_clk1)) )
		 begin
		    if(write_ptr != 11)
		       write_ptr <= write_ptr + 1;
		    else
		       write_ptr <= 0;
		 end
		   else if (disablefifowrout && ge_xaui_sel && !genericfifo_sync_clk1)
		      begin
			 if(write_ptr != 0)
			    write_ptr <= write_ptr - 1; 
			 else
			    write_ptr <= 11;
		      end 
      end
   end
   
   // FIFO READ POINTER LOGIC
   always @(posedge reset or posedge readclk)
      begin
	 if (reset)
	    begin
	       read_ptr1 <= 0;
	       read_ptr2 <= 1;
	    end
	 else if (!alignsyncstatus_sync && !genericfifo_sync_clk2)
	    begin
	       read_ptr1 <= 0;
	       read_ptr2 <= 1;
	    end
	      else if ((read_sync && !disablefifordout && !genericfifo_sync_clk2) ||
		       (rdenable_sync && genericfifo_sync_clk2))
		 begin
		    if(read_ptr1 != 11)
		       read_ptr1 <= read_ptr1 + 1;
		    else
		       read_ptr1 <= 0;
		    if(read_ptr2 != 11)
		       read_ptr2 <= read_ptr2 + 1;
		    else
		       read_ptr2 <= 0;
		 end
      end 
   
   // MAIN FIFO BLOCK
   always @(fifo_data_in or write_ptr or reset or errdetectin or syncstatusin or disperrin or patterndetectin)
      begin
	      #1;
	      if (reset)
		      begin
                  for (i = 0; i < 168; i = i + 1)  // 14*12 = 168
			          fifo[i] = 1'b0;
			  end
		  else 
		      begin
	              for (i = 0; i < 10; i = i + 1)
	                  fifo[write_ptr*14+i] = fifo_data_in[i];
	              fifo[write_ptr*14+10] = errdetectin;
	              fifo[write_ptr*14+11] = syncstatusin;
	              fifo[write_ptr*14+12] = disperrin;
	              fifo[write_ptr*14+13] = patterndetectin;
		      end
      end 
   
   always @ (posedge writeclk_dly or reset or read_ptr1 or read_ptr2)
      begin
	 for (j = 0; j < 14; j = j + 1)
	    fifo_data_out1_tmp[j] = fifo[read_ptr1*14+j];
	 for (k = 0; k < 13; k = k + 1)
	    fifo_data_out2_tmp[k] = fifo[read_ptr2*14+k];
      end 

   assign fifo_data_out1 = fifo_data_out1_tmp;
   assign fifo_data_out2 = fifo_data_out2_tmp;

   // DATAOUT DELAY LOGIC
   always @ (posedge reset or posedge readclk)
      begin
	 if (reset)
	    begin
	       fifo_data_out1_sync <= 'b0;
	       fifo_data_out1_sync_dly <= 'b0;
	       fifo_data_out2_sync <= 'b0;
	    end
	 else  
	    begin
	       if (ge_xaui_sel)
		  fifo_data_out1_sync_dly <=  fifo_data_out1_sync;
	       else
		  fifo_data_out1_sync_dly <= 'b0;
	       if (!disablefifordout)
		  begin
		     fifo_data_out1_sync <= fifo_data_out1;
		     fifo_data_out2_sync <= fifo_data_out2;
		  end
	       else if (ge_xaui_sel)
		  fifo_data_out1_sync <= fifo_data_out1_sync_dly;
	    end
      end
   
   assign done = done_write || done_read_sync;
   assign smenable = ((menable || (globalenable && onechannel)) && ~genericfifo_sync_clk1) ? 1'b1 : 1'b0;
   assign comp_pat1 = (ge_xaui_sel) ? 10'b1010110110 : 10'b0010111100;
   assign comp_pat2 = (ge_xaui_sel) ? ((for_engineering_sample_device == "ON") ? 10'b1010001010 : 10'b1010001001)  : 10'b1101000011;
   assign comp_write_d = (fifo_data_in_pre[9:0] == comp_pat1) || (fifo_data_in_pre[9:0] == comp_pat2) ? 1'b1 : 1'b0;
   assign comp_read_d = (fifo_data_out2_sync[9:0] == comp_pat1) || (fifo_data_out2_sync[9:0] == comp_pat2) ? 1'b1 : 1'b0;
   assign write_detect_d = (fifo_data_in_pre[9:0] == 10'b0101111100) || (fifo_data_in_pre[9:0] == 10'b1010000011) ? 1'b1 : 1'b0;
   assign detect_read_d = (fifo_data_out2_sync[9:0] == 10'b0101111100) || (fifo_data_out2_sync[9:0] == 10'b1010000011) ? 1'b1 : 1'b0;
   assign dataout = (matchenable || genericfifo_sync_clk2) ? fifo_data_out1_sync[9:0] : datain;
   assign errdetectout = (matchenable || genericfifo_sync_clk2) ? fifo_data_out1_sync[10] : errdetectin; 
   assign syncstatus = (matchenable || genericfifo_sync_clk2) ? fifo_data_out1_sync[11] : syncstatusin; 
   assign disperr = (matchenable || genericfifo_sync_clk2) ? fifo_data_out1_sync[12] : disperrin;
   assign patterndetect = (matchenable || genericfifo_sync_clk2) ? fifo_data_out1_sync[13]: patterndetectin;
   assign codevalid = (matchenable || genericfifo_sync_clk2) ? fifo_data_out1_sync_valid : (deskewenable) ? alignstatus_dly : syncstatusin;
   assign alignsyncstatus = (~matchenable || genericfifo_sync_clk1) ? 1'b0 : (deskewenable) ? alignstatus_dly : syncstatusin;
   assign alignsyncstatus_sync = (~matchenable || genericfifo_sync_clk2) ? 1'b0 : (deskewenable) ? alignstatus_sync : syncstatus_sync;
   assign fifo_data_in = datain; 
   assign fifo_data_in_pre = datainpre;
   assign comp_write = comp_write_pre & ~errdetectin & ~disperrin; 
   assign write_detect = write_detect_pre & ~errdetectin & ~disperrin; 
   
endmodule

//IP Functional Simulation Model
//VERSION_BEGIN 4.1 cbx_mgl 2004:06:17:17:30:06:SJ cbx_simgen 2004:06:22:10:53:08:SJ  VERSION_END


// Legal Notice: � 2003 Altera Corporation. All rights reserved.
// You may only use these  simulation  model  output files for simulation
// purposes and expressly not for synthesis or any other purposes (in which
// event  Altera disclaims all warranties of any kind). Your use of  Altera
// Corporation's design tools, logic functions and other software and tools,
// and its AMPP partner logic functions, and any output files any of the
// foregoing (including device programming or simulation files), and any
// associated documentation or information  are expressly subject to the
// terms and conditions of the  Altera Program License Subscription Agreement
// or other applicable license agreement, including, without limitation, that
// your use is for the sole purpose of programming logic devices manufactured
// by Altera and sold by Altera or its authorized distributors.  Please refer
// to the applicable agreement for further details.


//synopsys translate_off

//synthesis_resources = lut 15 mux21 14 oper_selector 6 
`timescale 1 ps / 1 ps
module  altgxb_comp_fifo_sm
	( 
	alignsyncstatus,
	decsync,
	done,
	fifocntgt9,
	fifocntlt5,
	overflow,
	reset,
	smenable,
	underflow,
	writeclk) /* synthesis synthesis_clearbox=1 */;
	input   alignsyncstatus;
	input   decsync;
	input   done;
	input   fifocntgt9;
	input   fifocntlt5;
	output   overflow;
	input   reset;
	input   smenable;
	output   underflow;
	input   writeclk;

	reg	n0iO7;
	reg	n0iO8;
	reg	n0iO9;
	reg	n0Oi4;
	reg	n0Oi5;
	reg	n0Oi6;
	reg	ni;
	reg	ni1i1;
	reg	ni1i2;
	reg	ni1i3;
	reg	nl;
	reg	nl1i;
	reg	nl1l;
	reg	nlO;
	reg	nO;
	wire	wire_n0i_dataout;
	wire	wire_n0l_dataout;
	wire	wire_n0O_dataout;
	wire	wire_n1i_dataout;
	wire	wire_n1l_dataout;
	wire	wire_n1O_dataout;
	wire	wire_nii_dataout;
	wire	wire_niO_dataout;
	wire	wire_nli_dataout;
	wire	wire_nlll_dataout;
	wire	wire_nllO_dataout;
	wire	wire_nlOi_dataout;
	wire	wire_nlOl_dataout;
	wire	wire_nlOO_dataout;
	wire  wire_nl0i_o;
	wire  wire_nl0O_o;
	wire  wire_nl1O_o;
	wire  wire_nlii_o;
	wire  wire_nlil_o;
	wire  wire_nlli_o;
	wire  n0ll;
	wire  n0lO;
	wire  n0OO;
	wire  ni0l;
	wire  w_n0iO32w;
	wire  w_n0Oi12w;
	wire  w_ni1i5w;

	initial
		n0iO7 = 1'b1;
	always @ ( posedge ni0l)
		  n0iO7 <= n0iO8;
	initial
		n0iO8 = 0;
	always @ ( posedge ni0l)
		  n0iO8 <= n0iO7;
	initial
		n0iO9 = 0;
	always @ ( posedge ni0l)
		  n0iO9 <= (n0iO8 ^ n0iO7);
	initial
		n0Oi4 = 1'b1;
	always @ ( posedge ni0l)
		  n0Oi4 <= n0Oi5;
	initial
		n0Oi5 = 0;
	always @ ( posedge ni0l)
		  n0Oi5 <= n0Oi4;
	initial
		n0Oi6 = 0;
	always @ ( posedge ni0l)
		  n0Oi6 <= (n0Oi5 ^ n0Oi4);
	initial
		ni = 0;
	always @ ( posedge writeclk or posedge reset)
		if (reset == 1'b1) ni <= 1'b0;
		else   ni <= wire_nl0i_o;
	initial
		ni1i1 = 1'b1;
	always @ ( posedge ni0l)
		  ni1i1 <= ni1i2;
	initial
		ni1i2 = 0;
	always @ ( posedge ni0l)
		  ni1i2 <= ni1i1;
	initial
		ni1i3 = 0;
	always @ ( posedge ni0l)
		  ni1i3 <= (ni1i2 ^ ni1i1);
	initial
		nl = 0;
	always @ ( posedge writeclk or posedge reset)
		if (reset == 1'b1) nl <= 1'b0;
		else   nl <= wire_nlii_o;
	initial
		nl1i = 0;
	always @ ( posedge writeclk or posedge reset)
		if (reset == 1'b1) nl1i <= 1'b1;
		else   nl1i <= wire_nl0O_o;
	initial
		nl1l = 0;
	always @ ( posedge writeclk or posedge reset)
		if (reset == 1'b1) nl1l <= 1'b0;
		else   nl1l <= wire_nlli_o;
	initial
		nlO = 0;
	always @ ( posedge writeclk or posedge reset)
		if (reset == 1'b1) nlO <= 1'b0;
		else   nlO <= wire_nl1O_o;
	initial
		nO = 0;
	always @ ( posedge writeclk or posedge reset)
		if (reset == 1'b1) nO <= 1'b0;
		else   nO <= wire_nlil_o;
	and(wire_n0i_dataout, (~ n0lO), ~{(~ alignsyncstatus)});
	and(wire_n0l_dataout, n0lO, ~{(~ alignsyncstatus)});
	assign		wire_n0O_dataout = (n0lO === 1'b1) ? fifocntgt9 : nlO;
	and(wire_n1i_dataout, nlO, ~{done});
	assign		wire_n1l_dataout = ((~ alignsyncstatus) === 1'b1) ? nlO : wire_n0O_dataout;
	assign		wire_n1O_dataout = ((~ alignsyncstatus) === 1'b1) ? ni : wire_nii_dataout;
	assign		wire_nii_dataout = (n0lO === 1'b1) ? fifocntlt5 : ni;
	and(wire_niO_dataout, (~ decsync), ~{(~ alignsyncstatus)});
	and(wire_nli_dataout, decsync, ~{(~ alignsyncstatus)});
	and(wire_nlll_dataout, done, ~{(~ alignsyncstatus)});
	and(wire_nllO_dataout, (~ done), ~{(~ alignsyncstatus)});
	and(wire_nlOi_dataout, wire_nlOO_dataout, ~{(~ alignsyncstatus)});
	and(wire_nlOl_dataout, wire_n1i_dataout, ~{(~ alignsyncstatus)});
	and(wire_nlOO_dataout, ni, ~{done});
	oper_selector   nl0i
	( 
	.data({ni, wire_n1O_dataout, wire_nlOi_dataout}),
	.o(wire_nl0i_o),
	.sel({n0ll, nO, nl1l}));
	defparam
		nl0i.width_data = 3,
		nl0i.width_sel = 3;
	oper_selector   nl0O
	( 
	.data({(~ n0OO), (~ alignsyncstatus), (~ alignsyncstatus), (~ alignsyncstatus)}),
	.o(wire_nl0O_o),
	.sel({nl1i, nl, nO, nl1l}));
	defparam
		nl0O.width_data = 4,
		nl0O.width_sel = 4;
	oper_selector   nl1O
	( 
	.data({nlO, wire_n1l_dataout, wire_nlOl_dataout}),
	.o(wire_nl1O_o),
	.sel({n0ll, nO, nl1l}));
	defparam
		nl1O.width_data = 3,
		nl1O.width_sel = 3;
	oper_selector   nlii
	( 
	.data({n0OO, wire_niO_dataout, 1'b0, wire_nlll_dataout}),
	.o(wire_nlii_o),
	.sel({nl1i, nl, nO, nl1l}));
	defparam
		nlii.width_data = 4,
		nlii.width_sel = 4;
	oper_selector   nlil
	( 
	.data({1'b0, wire_nli_dataout, wire_n0i_dataout}),
	.o(wire_nlil_o),
	.sel({((nl1l | nl1i) | (~ w_n0iO32w)), nl, nO}));
	defparam
		nlil.width_data = 3,
		nlil.width_sel = 3;
	oper_selector   nlli
	( 
	.data({1'b0, wire_n0l_dataout, wire_nllO_dataout}),
	.o(wire_nlli_o),
	.sel({n0ll, nO, nl1l}));
	defparam
		nlli.width_data = 3,
		nlli.width_sel = 3;
	assign
		n0ll = (nl | nl1i),
		n0lO = ((fifocntlt5 | fifocntgt9) | (~ w_n0Oi12w)),
		n0OO = ((alignsyncstatus & smenable) & w_ni1i5w),
		ni0l = writeclk,
		overflow = nlO,
		underflow = ni,
		w_n0iO32w = n0iO9,
		w_n0Oi12w = n0Oi6,
		w_ni1i5w = ni1i3;
endmodule //altgxb_comp_fifo_sm
//synopsys translate_on
//VALID FILE
///////////////////////////////////////////////////////////////////////////////
//
//                              ALTGXB_COMP_FIFO
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ps/1 ps

   module altgxb_comp_fifo
      (
       datain,
       datainpre,
       reset,
       errdetectin, 
       syncstatusin,
       disperrin,   
       patterndetectin,
       errdetectinpre,
       syncstatusinpre,
       disperrinpre,
       patterndetectinpre,
       writeclk,
       readclk,
       re,
       we,
       fifordin,
       disablefifordin,
       disablefifowrin,
       alignstatus,
       dataout,
       errdetectout,
       syncstatus,
       disperr,
       patterndetect,
       codevalid,
       fifofull,
       fifoalmostful,
       fifoempty,
       fifoalmostempty,
       disablefifordout,
       disablefifowrout,
       fifordout
       );

   parameter 	 use_rate_match_fifo = "ON";
   parameter 	 rate_matching_fifo_mode = "XAUI";
   parameter 	 use_channel_align = "ON";
   parameter 	 channel_num = 0;
   parameter     for_engineering_sample_device = "ON";
      
   input [9:0] datain;          // encoded word
   input [9:0] datainpre;       // word or dskw fifo
   input       reset;           // reset state machine
   input       errdetectin;     // from previous module
   input       syncstatusin;    // from previous module
   input       disperrin;       // from previous module
   input       patterndetectin; // from previous module
   input       errdetectinpre;     // from previous module
   input       syncstatusinpre;    // from previous module
   input       disperrinpre;       // from previous module
   input       patterndetectinpre; // from previous module
   input       writeclk;        // write clock to the internal FIFO
   input       readclk;         // read clock to the FIFO
   input       re;              // from core
   input       we;              // from core
   input       fifordin;        // indicates initial state of FIFO read
   input       disablefifordin; // do not move read pointer of FIFO
   input       disablefifowrin; // do not move write pointer of FIFO
   input       alignstatus;     // all channels aligned
   
   output [9:0] dataout;        // compensated output (sync with readclk)
   output 	 errdetectout;   // straight output from invalidcodein and synchronized with output
   output 	 syncstatus;     // straight output from syncstatusin and synchronized with output
   output 	 disperr;        // disperrin
   output        patterndetect;  // from previous module
   output 	 codevalid;      //indicating data is synchronized and aligned. Also feeding to xgmdatavalid
   output 	 fifofull;       // FIFO has 13 words
   output 	 fifoalmostful;  // FIFO contains 10 or more words
   output 	 fifoempty;      // FIFO has less than 4 words
   output 	 fifoalmostempty;// FIFO contains less than 7
   output 	 disablefifordout;// output of RX0
   output 	 disablefifowrout;// output of RX0
   output 	 fifordout;      // output of RX0
   
   wire 	 done;
   wire 	 fifocntgt9;
   wire 	 fifocntlt5;
   wire 	 decsync;
   wire 	 alignsyncstatus;
   wire 	 smenable;
   wire 	 overflow;
   wire 	 underflow;
   wire 	 disablefifordin;
   wire 	 disablefifowrin;
   wire [9:0] 	 dataout;
   
   altgxb_comp_fifo_core comp_fifo_core 
      (
       .reset(reset),
       .writeclk(writeclk),
       .readclk(readclk),
       .underflow(underflow),
       .overflow(overflow),
       .errdetectin(errdetectin),
       .disperrin(disperrin),   
       .patterndetectin(patterndetectin),
       .disablefifordin(disablefifordin),
       .disablefifowrin(disablefifowrin),
       .re (re),
       .we (we),
       .datain(datain),
       .datainpre(datainpre),
       .syncstatusin(syncstatusin),
       .disperr(disperr),
       .alignstatus(alignstatus),                        
       .fifordin (fifordin),
       .fifordout (fifordout),
       .fifoalmostful (fifoalmostful), 
       .fifofull (fifofull), 
       .fifoalmostempty (fifoalmostempty), 
       .fifoempty (fifoempty),
       .decsync(decsync),
       .fifocntlt5(fifocntlt5),
       .fifocntgt9(fifocntgt9),
       .done(done),
       .alignsyncstatus(alignsyncstatus),
       .smenable(smenable),
       .disablefifordout(disablefifordout),
       .disablefifowrout(disablefifowrout),
       .dataout(dataout),
       .codevalid (codevalid),
       .errdetectout(errdetectout),
       .patterndetect(patterndetect),
       .syncstatus(syncstatus)
       ); 
   defparam 	 comp_fifo_core.use_rate_match_fifo = use_rate_match_fifo;
   defparam 	 comp_fifo_core.rate_matching_fifo_mode = rate_matching_fifo_mode;
   defparam 	 comp_fifo_core.use_channel_align = use_channel_align;
   defparam 	 comp_fifo_core.channel_num = channel_num;
   defparam 	 comp_fifo_core.for_engineering_sample_device = for_engineering_sample_device; // new in 3.0 sp2
   
   altgxb_comp_fifo_sm comp_fifo_sm 
      (
       .writeclk(writeclk),
       .alignsyncstatus(alignsyncstatus),
       .reset(reset),
       .smenable(smenable),
       .done(done),
       .decsync(decsync),
       .fifocntlt5(fifocntlt5),
       .fifocntgt9(fifocntgt9),
       .underflow(underflow),
       .overflow(overflow)
       );
   
endmodule

///////////////////////////////////////////////////////////////////////////////
//
//                               ALTGXB_RX_CORE
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps
  module altgxb_rx_core
    (
     reset,
     writeclk,
     readclk,
     errdetectin,
     patterndetectin, 
     decdatavalid,
     xgmdatain,
     post8b10b,
     datain,
     xgmctrlin,
     ctrldetectin,
     syncstatusin,
     disparityerrin,
     syncstatus, 
     errdetect,  
     ctrldetect, 
     disparityerr, 
     patterndetect, 
     dataout, 
     a1a2sizeout, 
     clkout
     );

   parameter channel_width = 10;
   parameter use_double_data_mode = "OFF";
   parameter use_channel_align    = "OFF";
   parameter use_8b_10b_mode      = "ON";
   parameter synchronization_mode = "NONE";
   parameter align_pattern = "0000000101111100";
      
   input 	 reset;
   input 	 writeclk;
   input 	 readclk; 
   input 	 errdetectin;
   input 	 patterndetectin; 
   input 	 decdatavalid;
   input [7:0] 	 xgmdatain;
   input [9:0] 	 post8b10b;
   input [9:0] 	 datain;
   input 	 xgmctrlin;
   input 	 ctrldetectin;
   input 	 syncstatusin;
   input 	 disparityerrin;
   
   output [1:0]  syncstatus;
   output [1:0]  errdetect;
   output [1:0]  ctrldetect;
   output [1:0]  disparityerr;
   output [1:0]  patterndetect;
   output [19:0] dataout; 
   output [1:0]  a1a2sizeout;
   output 	 clkout;

   wire [19:0] 	 dataout;
   wire [1:0] 	 ctrldetect;
   wire 	 detect;
   wire [7:0] 	 xgmxor;
   wire 	 running_disp;
   
   reg 		 clkout;
   reg 		 resync_d;
   reg 		 disperr_d;
   reg 		 patterndetect_d;
   reg 		 syncstatusin_1;
   reg 		 syncstatusin_2;
   reg 		 disparityerrin_1;
   reg 		 disparityerrin_2;
   reg 		 patterndetectin_1;
   reg 		 patterndetectin_2;
   reg 		 writeclk_by2;
   reg [12:0] 	 data_low_sync;
   reg [12:0] 	 data_low;
   reg [12:0] 	 data_high;
   reg [9:0] 	 data_int;
   reg [19:0] 	 dataout_tmp;
   reg [1:0] 	 patterndetect_tmp;
   reg [1:0] 	 disparityerr_tmp;
   reg [1:0] 	 syncstatus_tmp;
   reg [1:0] 	 errdetect_tmp;
   reg [1:0] 	 ctrldetect_tmp;
   reg [1:0] 	 a1a2sizeout_tmp;
   reg [19:0] 	 dataout_sync1;
   reg [1:0] 	 patterndetect_sync1;
   reg [1:0] 	 disparityerr_sync1;
   reg [1:0] 	 syncstatus_sync1;
   reg [1:0] 	 errdetect_sync1;
   reg [1:0] 	 ctrldetect_sync1;
   reg [1:0] 	 a1a2sizeout_sync1;
   reg [19:0] 	 dataout_sync2;
   reg [1:0] 	 patterndetect_sync2;
   reg [1:0] 	 disparityerr_sync2;
   reg [1:0] 	 syncstatus_sync2;
   reg [1:0] 	 errdetect_sync2;
   reg [1:0] 	 ctrldetect_sync2;
   reg [1:0] 	 a1a2sizeout_sync2;

   wire 	 doublewidth;
   wire 	 individual;
   wire 	 ena8b10b;
   wire 	 smdisable;

   // A1A2 patterndetect related variables
   reg patterndetect_8b;
   reg patterndetect_1_latch;
   reg patterndetect_2_latch;
   reg patterndetect_3_latch;
   
   wire [15 : 0] align_pattern_int;

// function to convert align_pattern to binary
function [15 : 0] pattern_conversion;
	input  [127 : 0] s;
	reg [127 : 0] reg_s;
	reg [15 : 0] digit;
	reg [7 : 0] tmp;
	integer   m;
	begin

		reg_s = s;
		for (m = 15; m >= 0; m = m-1 )
		begin
			tmp = reg_s[127 : 120];
			digit[m] = tmp & 8'b00000001;
			reg_s = reg_s << 8;
		end

		pattern_conversion = {digit[15], digit[14], digit[13], digit[12], digit[11], digit[10], digit[9], digit[8], digit[7], digit[6], digit[5], digit[4], digit[3], digit[2], digit[1], digit[0]};
	end   
endfunction

   assign align_pattern_int = pattern_conversion(align_pattern);
   assign doublewidth = (use_double_data_mode == "ON") ? 1'b1 : 1'b0;
   assign individual  = (use_channel_align != "ON") ? 1'b1 : 1'b0;
   assign ena8b10b    = (use_8b_10b_mode == "ON") ? 1'b1 : 1'b0;
   assign smdisable   = (synchronization_mode == "NONE") ? 1'b1 : 1'b0;

   initial
      begin
	 writeclk_by2 = 1'b0;
      end
   
   // A1A2 patterndetect block
   always @ (datain or align_pattern_int or patterndetect_1_latch or patterndetect_3_latch)
   begin
      if (datain[8] == 1'b1)
         patterndetect_8b = (datain[7:0] == align_pattern_int[15:8])
                                      && patterndetect_3_latch;
      else 
         patterndetect_8b = (datain[7:0] == align_pattern_int[15:8]) 
                                      && patterndetect_1_latch;                 
   end

   // A1A2 patterndetect latch
   always @(posedge reset or posedge writeclk)
   begin
      if (reset)
      begin
         patterndetect_1_latch <= 1'b0;  // For first A1 match 
         patterndetect_2_latch <= 1'b0;  // For second A1 match
         patterndetect_3_latch <= 1'b0;  // For first A2 match
      end
      else
      begin
         patterndetect_1_latch <= (datain[7:0] == align_pattern_int[7:0]);
         patterndetect_2_latch <= (patterndetect_1_latch) &
                                (datain[7:0] == align_pattern_int[7:0]);  
         patterndetect_3_latch <= (patterndetect_2_latch) &
                                (datain[7:0] == align_pattern_int[15:8]); 
      end
   end
   
   assign running_disp = disparityerrin | errdetectin;
   
   always @ (xgmdatain or datain or xgmctrlin or 
	     ctrldetectin or decdatavalid or data_int or 
	     syncstatusin or disparityerrin or patterndetectin or
	     patterndetect_8b or syncstatusin_2 or disparityerrin_2 or 
	     patterndetectin_2 or running_disp)
      begin
	 if (ena8b10b)
	    if (individual)
	       begin
		  resync_d <= syncstatusin;
		  disperr_d <= disparityerrin;
		  if (!decdatavalid && !smdisable)
		     begin
			data_int[8:0] <= 9'h19C; 
			data_int[9]   <= 1'b0;   
			patterndetect_d <= 1'b0;
		     end
		  else 
		  begin
         if (channel_width == 10) 
			   patterndetect_d     <= patterndetectin;
         else
			   patterndetect_d     <= patterndetect_8b;

			if (decdatavalid && !smdisable && running_disp)
			   begin
			      data_int[8:0] <= 9'h1FE;
			      data_int[9]   <= running_disp;
			   end
			else
			   begin
			      data_int[8:0] <= {ctrldetectin, datain[7:0]};
			      data_int[9]   <= running_disp;
			   end
		     end
	       end
	    else
	       begin
		  resync_d        <= syncstatusin_2;
		  disperr_d       <= disparityerrin_2;
		  patterndetect_d <= patterndetectin_2;
		  data_int[8:0]   <= {xgmctrlin, xgmdatain[7:0]};
		  data_int[9]     <= xgmctrlin & ~(detect); 
	       end
	 else
	    begin
	       resync_d           <= syncstatusin;
	       disperr_d          <= disparityerrin;
	       data_int           <= datain;
	       if (!decdatavalid && !smdisable)
		       patterndetect_d <= 1'b0;
	       else
             if (channel_width == 10) 
			       patterndetect_d     <= patterndetectin;
             else
			       patterndetect_d     <= patterndetect_8b;
	    end
      end

   assign xgmxor = (xgmdatain[7:0]^8'hFE);
   assign detect = 1'b1 ? (xgmxor != 8'b00000000) : 1'b0;
      
   // MAIN FIFO BLOCK
   always @(posedge reset or posedge writeclk)
      begin
	 if (reset)
	    begin
	       writeclk_by2      <= 1'b0;
	       data_high         <= 13'h0000;
	       data_low          <= 13'h0000;
	       data_low_sync     <= 13'h0000;
	       syncstatusin_1    <= 1'b0;
	       syncstatusin_2    <= 1'b0;
	       disparityerrin_1  <= 1'b0;
	       disparityerrin_2  <= 1'b0;
	       patterndetectin_1 <= 1'b0;
	       patterndetectin_2 <= 1'b0;
	    end
	 else
	    begin
	       writeclk_by2      <= ~((writeclk_by2 && individual) || (writeclk_by2 && ~individual));
	       syncstatusin_1    <= syncstatusin;
	       syncstatusin_2    <= syncstatusin_1;
	       disparityerrin_1  <= disparityerrin;
	       disparityerrin_2  <= disparityerrin_1;
	       patterndetectin_1 <= patterndetectin;
	       patterndetectin_2 <= patterndetectin_1;
	       
	       if (doublewidth && !writeclk_by2)
		  begin
		     data_high[9:0] <= data_int;
		     data_high[10]  <= resync_d;
		     data_high[11]  <= disperr_d;
		     data_high[12]  <= patterndetect_d;		     
		  end
	       if (doublewidth & writeclk_by2)
		  begin
		     data_low[9:0]  <= data_int;
		     data_low[10]   <= resync_d;
		     data_low[11]   <= disperr_d;
		     data_low[12]   <= patterndetect_d;
		  end
	       if (!doublewidth)
		  begin
		     data_low_sync[9:0] <= data_int;
		     data_low_sync[10]  <= resync_d;
		     data_low_sync[11]  <= disperr_d;
		     data_low_sync[12]  <= patterndetect_d;
		  end
	       else 
		  data_low_sync <= data_low;
	    end
      end

   // CLOCK OUT BLOCK
   always @(writeclk_by2 or writeclk)
      begin
	 if (doublewidth)
	    clkout <= ~writeclk_by2; 
	 else
	    clkout <= ~writeclk;
      end
   
   // READ CLOCK BLOCK
   always @(posedge reset or posedge readclk)
      begin
	 if(reset)
	    begin
	       dataout_tmp       <= 20'b0;
	       patterndetect_tmp <= 2'b0;
	       disparityerr_tmp  <= 2'b0;
	       syncstatus_tmp    <= 2'b0;
	       errdetect_tmp     <= 2'b0;
	       ctrldetect_tmp    <= 2'b0;
	       a1a2sizeout_tmp    <= 2'b0;
	       dataout_sync1       <= 20'b0;
	       patterndetect_sync1 <= 2'b0;
	       disparityerr_sync1  <= 2'b0;
	       syncstatus_sync1    <= 2'b0;
	       errdetect_sync1     <= 2'b0;
	       ctrldetect_sync1    <= 2'b0;
	       a1a2sizeout_sync1    <= 2'b0;
	       dataout_sync2       <= 20'b0;
	       patterndetect_sync2 <= 2'b0;
	       disparityerr_sync2  <= 2'b0;
	       syncstatus_sync2    <= 2'b0;
	       errdetect_sync2     <= 2'b0;
	       ctrldetect_sync2    <= 2'b0;
	       a1a2sizeout_sync2    <= 2'b0;
	    end
	 else
	    begin
	       if (ena8b10b || channel_width == 8 || channel_width == 16)
	          dataout_sync1 <= {4'b0000, data_high[7:0], data_low_sync[7:0]};
          else
	          dataout_sync1 <= {data_high[9:0], data_low_sync[9:0]};

	       patterndetect_sync1 <= {data_high[12], data_low_sync[12]};
	       disparityerr_sync1  <= {data_high[11], data_low_sync[11]};
	       syncstatus_sync1    <= {data_high[10], data_low_sync[10]};
	       errdetect_sync1     <= {data_high[9], data_low_sync[9]};
	       ctrldetect_sync1    <= {data_high[8], data_low_sync[8]};
          if (channel_width == 8)
	          a1a2sizeout_sync1   <= {data_high[8], data_low_sync[8]};
          else
	          a1a2sizeout_sync1   <= 2'b0;
	       dataout_sync2       <= dataout_sync1;
	       patterndetect_sync2 <= patterndetect_sync1;
	       disparityerr_sync2  <= disparityerr_sync1;
	       syncstatus_sync2    <= syncstatus_sync1;
	       errdetect_sync2     <= errdetect_sync1;
	       ctrldetect_sync2    <= ctrldetect_sync1;
	       a1a2sizeout_sync2   <= a1a2sizeout_sync1;
	       dataout_tmp         <= dataout_sync2;
	       patterndetect_tmp   <= patterndetect_sync2;
	       disparityerr_tmp    <= disparityerr_sync2;
	       syncstatus_tmp      <= syncstatus_sync2;
	       errdetect_tmp       <= errdetect_sync2;
	       ctrldetect_tmp      <= ctrldetect_sync2;
	       a1a2sizeout_tmp     <= a1a2sizeout_sync2;
	    end
      end

   assign dataout = dataout_tmp;
   assign a1a2sizeout = a1a2sizeout_tmp;
   assign patterndetect = patterndetect_tmp;
   assign disparityerr = disparityerr_tmp;
   assign syncstatus = syncstatus_tmp;
   assign errdetect = errdetect_tmp;
   assign ctrldetect = ctrldetect_tmp;
      
endmodule // altgxb_rx_core
 
//
// ALTGXB_HSSI_RX_SERDES
//

`timescale 1 ps/1 ps

module altgxb_hssi_rx_serdes 
	(
		cruclk, 
		datain, 
		areset, 
		feedback, 
		fbkcntl, 
		ltr,		// q3.0ll
		ltd,		// q3.0ll
		clkout, 
		dataout, 
		rlv, 
		lock, 
		freqlock, 
		signaldetect 
	);

input datain;
input cruclk;
input areset;
input feedback;
input fbkcntl;
input ltr;
input ltd;

output [9:0] dataout;
output clkout;
output rlv;
output lock;
output freqlock;
output signaldetect;

parameter channel_width = 10;
parameter run_length = 4; 
parameter run_length_enable = "OFF";
parameter cruclk_period = 5000;
parameter cruclk_multiplier = 4;
parameter use_cruclk_divider = "OFF"; 
parameter use_double_data_mode = "OFF"; 
parameter channel_width_max = 10;

parameter init_lock_latency = 9;  // internal used for q3.0ll
integer cruclk_cnt;                
reg freqlock_tmp_dly;             
reg freqlock_tmp_dly1;           
reg freqlock_tmp_dly2;         
reg freqlock_tmp_dly3;        
reg freqlock_tmp_dly4;        

integer i, clk_count, rlv_count;
reg fastclk_last_value, clkout_last_value;
reg cruclk_last_value;
reg [channel_width_max-1:0] deser_data_arr;
reg [channel_width_max-1:0] deser_data_arr_tmp;
reg rlv_flag, rlv_set;
reg clkout_tmp;
reg lock_tmp;
reg freqlock_tmp;
reg signaldetect_tmp;
reg [9:0] dataout_tmp;
wire [9:0] data_out;
reg datain_in;
reg last_datain;
reg data_changed;

// clock generation
reg fastclk1;
reg fastclk;
integer n_fastclk;
integer fastclk_period;
integer rem;
integer my_rem;
integer tmp_fastclk_period;
integer cycle_to_adjust;
integer high_time;
integer low_time;
integer k;
integer sched_time;
reg     sched_val;

// new RLV variables
wire rlv_tmp;
reg rlv_tmp1, rlv_tmp2, rlv_tmp3;
wire min_length;

buf (cruclk_in, cruclk);
buf (datain_buf, datain);
buf (fbin_in, feedback);
buf (fbena_in, fbkcntl);
buf (areset_in, areset);
buf (ltr_in, ltr);          // q3.0ll
buf (ltd_in, ltd);          // q3.0ll

initial
begin
	i = 0;
	clk_count = channel_width;
	rlv_count = 0;
	fastclk_last_value = 'b0;
	//cruclk_last_value = 'b0;
  	clkout_last_value = 'b0;
	clkout_tmp = 'b0;
	rlv_tmp1 = 'b0;
	rlv_tmp2 = 'b0;
	rlv_tmp3 = 'b0;
	rlv_flag = 'b0;
	rlv_set = 'b0;

	lock_tmp = 'b1;             // q3.0ll
	freqlock_tmp = 'b0;	        
	cruclk_cnt = 0;	           
	freqlock_tmp_dly = 'b0;     
	freqlock_tmp_dly1 = 'b0;     
	freqlock_tmp_dly2 = 'b0;     
	freqlock_tmp_dly3 = 'b0;     
	freqlock_tmp_dly4 = 'b0;    //
      
	signaldetect_tmp = 'b1;
	dataout_tmp = 10'bX;
	last_datain = 'bX;
	data_changed = 'b0;
   for (i = channel_width_max - 1; i >= 0; i = i - 1)
   	deser_data_arr[i] = 1'b0;
   for (i = channel_width_max - 1; i >= 0; i = i - 1)
   	deser_data_arr_tmp[i] = 1'b0;

   // q4.0 -    
   if (use_cruclk_divider == "OFF")
       n_fastclk = cruclk_multiplier;
   else
       n_fastclk = cruclk_multiplier / 2;
       
   fastclk_period = cruclk_period / n_fastclk;
   rem = cruclk_period % n_fastclk;
end
        
assign min_length = (channel_width == 8) ? 4 : 5;
        
always @(cruclk_in)
begin
   if ((cruclk_in === 'b1) && (cruclk_last_value === 'b0))
   begin 
       // schedule n_fastclk of clk with period fastclk_period
       sched_time = 0;
       sched_val = 1'b1; // start with rising to match cruclk
       
       k = 1; // used to distribute rem ps to n_fastclk internals
       for (i = 1; i <= n_fastclk; i = i + 1)
       begin
           fastclk1 <= #(sched_time) sched_val; // rising
             
           // wether it needs to add extra ps to the period
           tmp_fastclk_period = fastclk_period;
           if (rem != 0 && k <= rem)
           begin
               cycle_to_adjust = (n_fastclk * k) / rem;
               my_rem = (n_fastclk * k) % rem;
               if (my_rem != 0)
                   cycle_to_adjust = cycle_to_adjust + 1;
                     
               if (cycle_to_adjust == i)
               begin
                   tmp_fastclk_period = tmp_fastclk_period + 1;
                   k = k + 1;
               end
           end
                     
           high_time = tmp_fastclk_period / 2;
           low_time  = tmp_fastclk_period - high_time; 
           sched_val = ~sched_val;
           sched_time = sched_time + high_time;
           fastclk1 <= #(sched_time) sched_val; // falling edge
           sched_time = sched_time + low_time;
 		   sched_val = ~sched_val;
       end           
   end // rising cruclk
             
   cruclk_last_value <= cruclk_in;
end

always @(fastclk1)
    fastclk <= fastclk1;
      
always @(fastclk or areset_in or fbena_in)
begin

	if (areset_in == 1'b1)
	begin
		dataout_tmp = 10'b0;
		clk_count = channel_width;
		clkout_tmp = 1'b0;
   	clkout_last_value = fastclk;
      rlv_tmp1 = 1'b0;
      rlv_tmp2 = 1'b0;
      rlv_tmp3 = 1'b0;
      rlv_flag = 1'b0;
      rlv_set = 1'b0;
      signaldetect_tmp = 1'b1;
      last_datain = 'bX;
      rlv_count = 0;
      data_changed = 'b0;
  	   for (i = channel_width_max - 1; i >= 0; i = i - 1)
  	       deser_data_arr[i] = 1'b0;
  	   for (i = channel_width_max - 1; i >= 0; i = i - 1)
  	       deser_data_arr_tmp[i] = 1'b0;
	end
   else 
	begin
		if (fbena_in == 1'b1)
			datain_in = fbin_in;
		else
			datain_in = datain_buf;

   	if (((fastclk == 'b1) && (fastclk_last_value !== fastclk)) ||
   		 ((fastclk == 'b0) && (fastclk_last_value !== fastclk)))
	   begin
			if (clk_count == channel_width)
			begin
				clk_count = 0;
				clkout_tmp = !clkout_last_value;
			end
			else if (clk_count == channel_width/2)
				clkout_tmp = !clkout_last_value;
			else if (clk_count < channel_width)
				clkout_tmp = clkout_last_value;
	      clk_count = clk_count + 1;
	   end

		// data loaded on both edges
   	if (((fastclk == 'b1) && (fastclk_last_value !== fastclk)) ||
   		 ((fastclk == 'b0) && (fastclk_last_value !== fastclk)))
   	begin
   	   for (i = 1; i < channel_width_max; i = i + 1)
   	       deser_data_arr[i - 1] <= deser_data_arr[i];
   	   deser_data_arr[channel_width_max - 1] <= datain_in;

			if (run_length_enable == "ON") //rlv checking
			begin
				if (last_datain !== datain_in)
				begin
					data_changed = 'b1;
					last_datain = datain_in;
					rlv_count = 1;
					rlv_set = 'b0;
				end
				else //data not changed
				begin
					rlv_count = rlv_count + 1;
					data_changed = 'b0;
				end
				if (rlv_count > run_length && rlv_count > min_length)
				begin
					rlv_flag = 'b1;
					rlv_set = 'b1;
				end
			end
   	end

   	clkout_last_value = clkout_tmp;

	end

   fastclk_last_value = fastclk;

end

always @(posedge clkout_tmp)
begin
	deser_data_arr_tmp <= deser_data_arr;

   dataout_tmp[channel_width_max-1:0] <= deser_data_arr_tmp;

	if (run_length_enable == "ON") //rlv checking
	begin
		if (rlv_flag == 'b1)
			if (rlv_set == 'b0)
				rlv_flag = 'b0;

		if (rlv_flag == 'b1)
		   rlv_tmp1 <= 'b1;
		else
			rlv_tmp1 <= 'b0;

      rlv_tmp2 <= rlv_tmp1;
      rlv_tmp3 <= rlv_tmp2;
	end

end

// q3.0ll - locked and freqlock based on LTR and LTD
always @(posedge areset_in or cruclk_in)
begin
  if ((cruclk_in == 1'b1) && (cruclk_last_value == 1'b0))
  begin
    if (areset_in == 1'b1)
        begin
    	    cruclk_cnt <= 0;
            lock_tmp <= 1'b1;
            freqlock_tmp <= 1'b0;
            freqlock_tmp_dly <= 1'b0;
            freqlock_tmp_dly1 <= 1'b0;     
            freqlock_tmp_dly2 <= 1'b0;     
            freqlock_tmp_dly3 <= 1'b0;     
            freqlock_tmp_dly4 <= 1'b0;
        end
    else if (cruclk_last_value == 'b0)
        begin
            freqlock_tmp_dly <= freqlock_tmp_dly4;
            freqlock_tmp_dly4 <= freqlock_tmp_dly3;
            freqlock_tmp_dly3 <= freqlock_tmp_dly2;
            freqlock_tmp_dly2 <= freqlock_tmp_dly1;
            freqlock_tmp_dly1 <= freqlock_tmp;

            // initial latency
            if (cruclk_cnt < init_lock_latency)
                cruclk_cnt <= cruclk_cnt + 1;
		
            if (cruclk_cnt == init_lock_latency)
                begin
                    if (ltd_in == 1'b1)
                        begin
                            freqlock_tmp <= 1'b1;
                        end
                    else if (ltr_in == 1'b1)
                        begin
                            lock_tmp <= 1'b0;
                            freqlock_tmp <= 1'b0;
                        end
                    else     // auto switch
                        begin
                            lock_tmp <= 1'b0;
                            freqlock_tmp <= 1'b1;
                        end
                end 			
        end
  end // end of cruclk == 1
end
 
assign rlv_tmp = (use_double_data_mode == "ON") ? (rlv_tmp1 | rlv_tmp2 | rlv_tmp3) : (rlv_tmp1 | rlv_tmp2);

assign data_out = dataout_tmp;

buf (dataout[0], data_out[0]);
buf (dataout[1], data_out[1]);
buf (dataout[2], data_out[2]);
buf (dataout[3], data_out[3]);
buf (dataout[4], data_out[4]);
buf (dataout[5], data_out[5]);
buf (dataout[6], data_out[6]);
buf (dataout[7], data_out[7]);
buf (dataout[8], data_out[8]);
buf (dataout[9], data_out[9]);

and (rlv, rlv_tmp, 1'b1);
and (lock, lock_tmp, 1'b1);
and (freqlock, freqlock_tmp_dly, 1'b1);      // q3.0ll extra latency on freqlock
and (signaldetect, signaldetect_tmp, 1'b1);
and (clkout, clkout_tmp, 1'b1);

endmodule

// 4 to 1 MULTIPLEXER
module altgxb_hssi_mux4(Y,I0,I1,I2,I3,C0,C1); 
  input I0,I1,I2,I3,C0,C1; 
  output Y; 
  reg   Y; 
  always@(I0 or I1 or I2 or I3 or C0 or C1) begin 
      case ({C1,C0})  
          2'b00 : Y = I0 ; 
          2'b01 : Y = I1 ; 
          2'b10 : Y = I2 ; 
          2'b11 : Y = I3 ; 
      endcase 
  end 
endmodule // altgxb_hssi_mux4

// DIVIDE BY TWO LOGIC
module altgxb_hssi_divide_by_two 
   (
    reset,
    clkin,
    clkout
    );
   parameter divide = "ON";

   input     reset;
   input     clkin;
   output    clkout;
   reg 	     clktmp;

   tri0      reset;

   initial
      begin
	 clktmp = 1'b0;
      end

   always@(clkin or posedge reset) 
   begin
	if(divide == "OFF")
	   clktmp <= clkin;
	else if (reset === 1'b1)
       clktmp <= 1'b0;
    else
	   if(clkin == 1'b1)
	      clktmp <= ~clktmp;
   end 

   assign clkout = clktmp;

endmodule
   

///////////////////////////////////////////////////////////////////////////////
//
//                           ALTGXB_HSSI_RECEIVER
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ps/1 ps

module altgxb_hssi_receiver 
   (
    datain,
    cruclk,
    pllclk,
    masterclk,
    coreclk,
    softreset,
    analogreset,
    serialfdbk,
    slpbk,
    bitslip,
    enacdet,
    we,
    re,
    alignstatus,
    disablefifordin,
    disablefifowrin,
    fifordin,
    enabledeskew,
    fiforesetrd,
    xgmctrlin,
    a1a2size,
    locktorefclk,
    locktodata,
    parallelfdbk,
    post8b10b,
    equalizerctrl,
    xgmdatain,
    devclrn,
    devpor,
    syncstatusdeskew,
    adetectdeskew,
    rdalign,
    xgmctrldet,
    xgmrunningdisp,
    xgmdatavalid,
    fifofull,
    fifoalmostfull,
    fifoempty,
    fifoalmostempty,
    disablefifordout,
    disablefifowrout,
    fifordout,
    bisterr,
    bistdone,
    a1a2sizeout,
    signaldetect,
    lock,
    freqlock,
    rlv,
    clkout,
    recovclkout,
    syncstatus,
    patterndetect,
    ctrldetect,
    errdetect,
    disperr,
    dataout,
    xgmdataout
    );
   
parameter channel_num = 1;
parameter channel_width = 20;
parameter deserialization_factor = 10;
parameter run_length = 4; 
parameter run_length_enable = "OFF"; 
parameter use_8b_10b_mode = "OFF"; 
parameter use_double_data_mode = "OFF"; 
parameter use_rate_match_fifo = "OFF"; 
parameter rate_matching_fifo_mode = "NONE"; 
parameter use_channel_align = "OFF"; 
parameter use_symbol_align = "ON"; 
parameter use_auto_bit_slip = "ON"; 
parameter synchronization_mode = "NONE"; 
parameter align_pattern = "0000000101111100";
parameter align_pattern_length = 7; 
parameter infiniband_invalid_code = 0; 
parameter disparity_mode = "OFF";
parameter clk_out_mode_reference = "ON";
parameter cruclk_period = 5000;
parameter cruclk_multiplier = 4;
parameter use_cruclk_divider = "OFF"; 
parameter use_parallel_feedback = "OFF";
parameter use_post8b10b_feedback = "OFF";
parameter send_reverse_parallel_feedback = "OFF";
parameter use_self_test_mode = "OFF";
parameter self_test_mode = 0;
parameter use_equalizer_ctrl_signal = "OFF";
parameter enable_dc_coupling = "OFF";
parameter equalizer_ctrl_setting = 20;
parameter signal_threshold_select = 2;
parameter vco_bypass = "OFF";
parameter force_signal_detect = "OFF";
parameter bandwidth_type = "LOW";
parameter for_engineering_sample_device = "ON"; // new in 3.0 sp2
     
input datain;
input cruclk;
input pllclk;
input masterclk;
input coreclk;
input softreset;
input serialfdbk;
input [9 : 0] parallelfdbk;
input [9 : 0] post8b10b;
input slpbk;
input bitslip;
input enacdet;
input we;
input re;
input alignstatus;
input disablefifordin;
input disablefifowrin;
input fifordin;
input enabledeskew;
input fiforesetrd;
input [7 : 0] xgmdatain;
input xgmctrlin;
input devclrn;
input devpor;
input analogreset;
input a1a2size;
input locktorefclk;
input locktodata;
input [2:0] equalizerctrl;
   
   
output [1 : 0] syncstatus;
output [1 : 0] patterndetect;
output [1 : 0] ctrldetect;
output [1 : 0] errdetect;
output [1 : 0] disperr;
output syncstatusdeskew;
output adetectdeskew;
output rdalign;
output [19:0] dataout;
output [7:0] xgmdataout;
output xgmctrldet;
output xgmrunningdisp;
output xgmdatavalid;
output fifofull;
output fifoalmostfull;
output fifoempty;
output fifoalmostempty;
output disablefifordout;
output disablefifowrout;
output fifordout;
output signaldetect;
output lock;
output freqlock;
output rlv;
output clkout;
output recovclkout;
output bisterr;
output bistdone;
output [1 : 0] a1a2sizeout; 
      
assign bisterr = 1'b0;
assign bistdone = 1'b1;
      
// input buffers
buf(datain_in, datain);
buf(cruclk_in, cruclk);
buf(pllclk_in, pllclk);
buf(masterclk_in, masterclk);
buf(coreclk_in, coreclk);
buf(softreset_in, softreset);
buf(serialfdbk_in, serialfdbk);
buf(analogreset_in, analogreset);
buf(locktorefclk_in, locktorefclk);
buf(locktodata_in, locktodata);
   
buf(parallelfdbk_in0, parallelfdbk[0]);
buf(parallelfdbk_in1, parallelfdbk[1]);
buf(parallelfdbk_in2, parallelfdbk[2]);
buf(parallelfdbk_in3, parallelfdbk[3]);
buf(parallelfdbk_in4, parallelfdbk[4]);
buf(parallelfdbk_in5, parallelfdbk[5]);
buf(parallelfdbk_in6, parallelfdbk[6]);
buf(parallelfdbk_in7, parallelfdbk[7]);
buf(parallelfdbk_in8, parallelfdbk[8]);
buf(parallelfdbk_in9, parallelfdbk[9]);

buf(post8b10b_in0, post8b10b[0]);
buf(post8b10b_in1, post8b10b[1]);
buf(post8b10b_in2, post8b10b[2]);
buf(post8b10b_in3, post8b10b[3]);
buf(post8b10b_in4, post8b10b[4]);
buf(post8b10b_in5, post8b10b[5]);
buf(post8b10b_in6, post8b10b[6]);
buf(post8b10b_in7, post8b10b[7]);
buf(post8b10b_in8, post8b10b[8]);
buf(post8b10b_in9, post8b10b[9]);

buf(slpbk_in, slpbk);
buf(bitslip_in, bitslip);
buf(a1a2size_in, a1a2size);
buf(enacdet_in, enacdet);
buf(we_in, we);
buf(re_in, re);
buf(alignstatus_in, alignstatus);
buf(disablefifordin_in, disablefifordin);
buf(disablefifowrin_in, disablefifowrin);
buf(fifordin_in, fifordin);
buf(enabledeskew_in, enabledeskew);
buf(fiforesetrd_in, fiforesetrd);

buf(xgmdatain_in0, xgmdatain[0]);
buf(xgmdatain_in1, xgmdatain[1]);
buf(xgmdatain_in2, xgmdatain[2]);
buf(xgmdatain_in3, xgmdatain[3]);
buf(xgmdatain_in4, xgmdatain[4]);
buf(xgmdatain_in5, xgmdatain[5]);
buf(xgmdatain_in6, xgmdatain[6]);
buf(xgmdatain_in7, xgmdatain[7]);

buf(xgmctrlin_in, xgmctrlin);

//constant signals
wire vcc, gnd;
wire [9 : 0] idle_bus;

//lower lever softreset
wire reset_int;

// internal bus for XGM/post8b10b data
wire [7 : 0] xgmdatain_in;
wire [9 : 0] post8b10b_in;

assign xgmdatain_in = {
								xgmdatain_in7, xgmdatain_in6,
								xgmdatain_in5, xgmdatain_in4,
							  	xgmdatain_in3, xgmdatain_in2,
							  	xgmdatain_in1, xgmdatain_in0
							 };
assign post8b10b_in = { 					post8b10b_in9, post8b10b_in8,
								post8b10b_in7, post8b10b_in6,
								post8b10b_in5, post8b10b_in4,
							  	post8b10b_in3, post8b10b_in2,
							  	post8b10b_in1, post8b10b_in0
							 };

assign reset_int = softreset_in;
assign vcc = 1'b1;
assign gnd = 1'b0;
assign idle_bus = 10'b0000000000;

// serdes output signals
wire serdes_clkout; //receovered clock
wire serdes_rlv;
wire serdes_signaldetect;
wire serdes_lock;
wire serdes_freqlock;
wire [9 : 0] serdes_dataout;

// word aligner input/output signals
wire [9 : 0] wa_datain;
wire wa_clk;
wire wa_enacdet;
wire wa_bitslip;
wire wa_a1a2size;

wire [9 : 0] wa_aligneddata;
wire [9 : 0] wa_aligneddatapre;
wire wa_invalidcode;
wire wa_invalidcodepre;
wire wa_disperr;
wire wa_disperrpre;
wire wa_patterndetect;
wire wa_patterndetectpre;
wire wa_syncstatus;
wire wa_syncstatusdeskew;

// deskew FIFO input/output signals
wire [9:0] dsfifo_datain;     
wire dsfifo_errdetectin;   
wire dsfifo_syncstatusin;  
wire dsfifo_disperrin; 
wire dsfifo_patterndetectin; 
wire dsfifo_writeclock;
wire dsfifo_readclock; 
wire dsfifo_fiforesetrd; 
wire dsfifo_enabledeskew;

wire [9:0] dsfifo_dataout; 
wire [9:0] dsfifo_dataoutpre; 
wire dsfifo_errdetect;   
wire dsfifo_syncstatus; 
wire dsfifo_disperr;    
wire dsfifo_errdetectpre;   
wire dsfifo_syncstatuspre; 
wire dsfifo_disperrpre;    
wire dsfifo_patterndetect; 
wire dsfifo_patterndetectpre; 
wire dsfifo_adetectdeskew;
wire dsfifo_rdalign;     
   
// comp FIFO input/output signals
   
wire [9:0] cmfifo_datain;
wire [9:0] cmfifo_datainpre;
wire cmfifo_invalidcodein; 
wire cmfifo_syncstatusin;
wire cmfifo_disperrin;  
wire cmfifo_patterndetectin;
wire cmfifo_invalidcodeinpre; 
wire cmfifo_syncstatusinpre;
wire cmfifo_disperrinpre;  
wire cmfifo_patterndetectinpre;
wire cmfifo_writeclk;      
wire cmfifo_readclk;      
wire cmfifo_alignstatus;
wire cmfifo_re;
wire cmfifo_we;
wire cmfifo_fifordin;
wire cmfifo_disablefifordin; 
wire cmfifo_disablefifowrin;
   
wire [9:0] cmfifo_dataout; 
wire cmfifo_invalidcode;
wire cmfifo_syncstatus;
wire cmfifo_disperr;
wire cmfifo_patterndetect;
wire cmfifo_datavalid;
wire cmfifo_fifofull;
wire cmfifo_fifoalmostfull;
wire cmfifo_fifoempty;
wire cmfifo_fifoalmostempty;
wire cmfifo_disablefifordout;
wire cmfifo_disablefifowrout;
wire cmfifo_fifordout;

// 8B10B decode input/output signals
wire decoder_clk; 
wire [9 : 0] decoder_datain;   
wire decoder_errdetectin;         
wire decoder_syncstatusin;         
wire decoder_disperrin;         
wire decoder_patterndetectin;         
wire decoder_indatavalid;         
   
wire [7 : 0] decoder_dataout;
wire [9 : 0] decoder_tenBdata; 
wire decoder_valid;         
wire decoder_errdetect;
wire decoder_rderr;         
wire decoder_syncstatus;         
wire decoder_disperr;         
wire decoder_patterndetect;         
wire decoder_decdatavalid;    
wire decoder_ctrldetect;   
wire decoder_xgmdatavalid;
wire decoder_xgmrunningdisp;
wire decoder_xgmctrldet;
wire [7 : 0] decoder_xgmdataout; 

// core interface input/output signals
wire [9:0] core_datain;
wire core_writeclk;
wire core_readclk;
wire core_decdatavalid;
wire [7:0] core_xgmdatain;
wire core_xgmctrlin;
wire [9:0] core_post8b10b;
wire core_syncstatusin;
wire core_errdetectin;
wire core_ctrldetectin;
wire core_disparityerrin;
wire core_patterndetectin;
   
wire [19:0] core_dataout;
wire core_clkout;
wire [1:0]  core_a1a2sizeout; 
wire [1:0]  core_syncstatus;
wire [1:0]  core_errdetect;
wire [1:0]  core_ctrldetect;
wire [1:0]  core_disparityerr;
wire [1:0]  core_patterndetect;

// interconnection variables
wire invalidcode;
wire [19 : 0] dataout_tmp;

// clkout mux output
// - added gfifo
wire clkoutmux_clkout;
wire clkoutmux_clkout_pre;

// MAIN CLOCKS
wire 	 rcvd_clk;
wire 	 clk_1;
wire 	 clk_2;
wire 	 rx_rd_clk;
wire 	 clk2_mux1;
wire 	 rx_rd_clk_mux;
   

specify


	(posedge coreclk => (dataout[0] +: dataout_tmp[0])) = (0, 0);
	(posedge coreclk => (dataout[1] +: dataout_tmp[1])) = (0, 0);
	(posedge coreclk => (dataout[2] +: dataout_tmp[2])) = (0, 0);
	(posedge coreclk => (dataout[3] +: dataout_tmp[3])) = (0, 0);
	(posedge coreclk => (dataout[4] +: dataout_tmp[4])) = (0, 0);
	(posedge coreclk => (dataout[5] +: dataout_tmp[5])) = (0, 0);
	(posedge coreclk => (dataout[6] +: dataout_tmp[6])) = (0, 0);
	(posedge coreclk => (dataout[7] +: dataout_tmp[7])) = (0, 0);
	(posedge coreclk => (dataout[8] +: dataout_tmp[8])) = (0, 0);
	(posedge coreclk => (dataout[9] +: dataout_tmp[9])) = (0, 0);
	(posedge coreclk => (dataout[10] +: dataout_tmp[10])) = (0, 0);
	(posedge coreclk => (dataout[11] +: dataout_tmp[11])) = (0, 0);
	(posedge coreclk => (dataout[12] +: dataout_tmp[12])) = (0, 0);
	(posedge coreclk => (dataout[13] +: dataout_tmp[13])) = (0, 0);
	(posedge coreclk => (dataout[14] +: dataout_tmp[14])) = (0, 0);
	(posedge coreclk => (dataout[15] +: dataout_tmp[15])) = (0, 0);
	(posedge coreclk => (dataout[16] +: dataout_tmp[16])) = (0, 0);
	(posedge coreclk => (dataout[17] +: dataout_tmp[17])) = (0, 0);
	(posedge coreclk => (dataout[18] +: dataout_tmp[18])) = (0, 0);
	(posedge coreclk => (dataout[19] +: dataout_tmp[19])) = (0, 0);

	(posedge coreclk => (syncstatus[0] +: core_syncstatus[0])) = (0, 0);
	(posedge coreclk => (syncstatus[1] +: core_syncstatus[1])) = (0, 0);

	(posedge coreclk => (patterndetect[0] +: core_patterndetect[0])) = (0, 0);
	(posedge coreclk => (patterndetect[1] +: core_patterndetect[1])) = (0, 0);

	(posedge coreclk => (ctrldetect[0] +: core_ctrldetect[0])) = (0, 0);
	(posedge coreclk => (ctrldetect[1] +: core_ctrldetect[1])) = (0, 0);

	(posedge coreclk => (errdetect[0] +: core_errdetect[0])) = (0, 0);
	(posedge coreclk => (errdetect[1] +: core_errdetect[1])) = (0, 0);

	(posedge coreclk => (disperr[0] +: core_disparityerr[0])) = (0, 0);
	(posedge coreclk => (disperr[1] +: core_disparityerr[1])) = (0, 0);

	(posedge coreclk => (a1a2sizeout[0] +: core_a1a2sizeout[0])) = (0, 0);
	(posedge coreclk => (a1a2sizeout[1] +: core_a1a2sizeout[1])) = (0, 0);

	(posedge coreclk => (fifofull +: cmfifo_fifofull)) = (0, 0);
	(posedge coreclk => (fifoempty +: cmfifo_fifoempty)) = (0, 0);
	(posedge coreclk => (fifoalmostfull +: cmfifo_fifoalmostfull)) = (0, 0);
	(posedge coreclk => (fifoalmostempty +: cmfifo_fifoalmostempty)) = (0, 0);
	$setuphold(posedge coreclk, re, 0, 0);


endspecify

// generate internal inut signals

   // generate internal input signals

   // RCVD_CLK LOGIC
   assign rcvd_clk = (use_parallel_feedback == "ON") ? pllclk_in : serdes_clkout;

   // CLK_1 LOGIC
   assign clk_1 = (use_parallel_feedback == "ON") ? pllclk_in : (use_channel_align == "ON") ? masterclk_in : serdes_clkout;
   
   // CLK_2 LOGIC
   // - added gfifo
   assign clk_2 = (clk_out_mode_reference == "OFF") ? coreclk_in : clk2_mux1;

   // RX_RD_CLK
   // - added gfifo
   assign rx_rd_clk = (clk_out_mode_reference == "OFF") ? coreclk_in : rx_rd_clk_mux;

   altgxb_hssi_mux4 clk2mux1 
      (
       .Y(clk2_mux1),
       .I0(serdes_clkout),
       .I1(masterclk_in),
       .I2(1'b0),
       .I3(pllclk_in),
       .C0(clk2mux1_c0),
       .C1(clk2mux1_c1)
       );
   
   assign clk2mux1_c0 = (use_parallel_feedback == "ON") | (use_channel_align == "ON") | (use_rate_match_fifo == "ON") ? 1'b1 : 1'b0;
   assign clk2mux1_c1 = (use_parallel_feedback == "ON") | (use_rate_match_fifo == "ON") ? 1'b1 : 1'b0;

   altgxb_hssi_mux4 rxrdclkmux1 
      (
       .Y(rxrdclk_mux1),
       .I0(serdes_clkout),
       .I1(masterclk_in),
       .I2(1'b0),
       .I3(pllclk_in),
       .C0(rxrdclkmux1_c0),
       .C1(rxrdclkmux1_c1)
       );
   
   assign rxrdclkmux1_c1 = (use_parallel_feedback == "ON") | (use_rate_match_fifo == "ON") ? 1'b1 : 1'b0;
   assign rxrdclkmux1_c0 = (use_parallel_feedback == "ON") | (use_channel_align == "ON") | (use_rate_match_fifo == "ON") ? 1'b1 : 1'b0;
      
   altgxb_hssi_mux4 rxrdclkmux2 
      (
       .Y(rx_rd_clk_mux),
       .I0(coreclk_in),
       .I1(1'b0),
       .I2(rxrdclk_mux1_by2),
       .I3(rxrdclk_mux1),
       .C0(rxrdclkmux2_c0),
       .C1(rxrdclkmux2_c1)
       );

   assign rxrdclkmux2_c1 = (send_reverse_parallel_feedback == "ON") ? 1'b1 : 1'b0;
   assign rxrdclkmux2_c0 = (use_double_data_mode == "OFF") && (send_reverse_parallel_feedback == "ON") ? 1'b1 : 1'b0;

   altgxb_hssi_divide_by_two rxrdclkmux_by2	
   (
    .reset(1'b0),
    .clkin(rxrdclk_mux1), 
    .clkout(rxrdclk_mux1_by2)
    );
   defparam rxrdclkmux_by2.divide = use_double_data_mode;
   
   // word_align inputs
   assign wa_datain = (use_parallel_feedback == "ON") ? parallelfdbk : serdes_dataout;
   assign wa_clk = rcvd_clk;
   assign wa_enacdet = enacdet_in; 
   assign wa_bitslip = bitslip_in; 
   assign wa_a1a2size = a1a2size_in; 
   
   // deskew FIFO inputs
   assign dsfifo_datain = (use_symbol_align == "ON") ? wa_aligneddata : idle_bus;     
   assign dsfifo_errdetectin = (use_symbol_align == "ON") ? wa_invalidcode : 1'b0;   
   assign dsfifo_syncstatusin = (use_symbol_align == "ON") ? wa_syncstatus : 1'b1;  
   assign dsfifo_disperrin = (use_symbol_align == "ON") ? wa_disperr : 1'b0; 
   assign dsfifo_patterndetectin = (use_symbol_align == "ON") ? wa_patterndetect : 1'b0; 
   assign dsfifo_writeclock = rcvd_clk;
   assign dsfifo_readclock = clk_1;
   assign dsfifo_fiforesetrd = fiforesetrd_in; 
   assign dsfifo_enabledeskew = enabledeskew_in;

// comp FIFO inputs
assign cmfifo_datain = (use_channel_align == "ON") ? dsfifo_dataout : ((use_symbol_align == "ON") ? wa_aligneddata : serdes_dataout);

assign cmfifo_datainpre = (use_channel_align == "ON") ? dsfifo_dataoutpre : ((use_symbol_align == "ON") ? wa_aligneddatapre : idle_bus);

assign cmfifo_invalidcodein = (use_channel_align == "ON") ? dsfifo_errdetect : ((use_symbol_align == "ON") ? wa_invalidcode : 1'b0);

assign cmfifo_syncstatusin = (use_channel_align == "ON") ? dsfifo_syncstatus : ((use_symbol_align == "ON") ? wa_syncstatus : 1'b1);

assign cmfifo_disperrin = (use_channel_align == "ON") ? dsfifo_disperr : ((use_symbol_align == "ON") ? wa_disperr : 1'b1);

assign cmfifo_patterndetectin = (use_channel_align == "ON") ? dsfifo_patterndetect : ((use_symbol_align == "ON") ? wa_patterndetect : 1'b1);

assign cmfifo_invalidcodeinpre = (use_channel_align == "ON") ? dsfifo_errdetectpre : ((use_symbol_align == "ON") ? wa_invalidcodepre : 1'b0);

assign cmfifo_syncstatusinpre = (use_channel_align == "ON") ? dsfifo_syncstatuspre : ((use_symbol_align == "ON") ? wa_syncstatusdeskew : 1'b1);

assign cmfifo_disperrinpre = (use_channel_align == "ON") ? dsfifo_disperrpre : ((use_symbol_align == "ON") ? wa_disperrpre : 1'b1);

assign cmfifo_patterndetectinpre = (use_channel_align == "ON") ? dsfifo_patterndetectpre : ((use_symbol_align == "ON") ? wa_patterndetectpre : 1'b1);

assign cmfifo_writeclk = clk_1;
assign cmfifo_readclk = clk_2;
assign cmfifo_alignstatus = alignstatus_in;
assign cmfifo_re = re_in;
assign cmfifo_we = we_in;
assign cmfifo_fifordin = fifordin_in;
assign cmfifo_disablefifordin = disablefifordin_in; 
assign cmfifo_disablefifowrin = disablefifowrin_in;

// 8B10B decoder inputs
assign decoder_clk = clk_2;
assign decoder_datain = (use_rate_match_fifo == "ON") ? cmfifo_dataout : (use_channel_align == "ON" ? dsfifo_dataout : (use_symbol_align == "ON" ? wa_aligneddata : serdes_dataout));   

assign decoder_errdetectin = (use_rate_match_fifo == "ON") ? cmfifo_invalidcode : (use_channel_align == "ON" ? dsfifo_errdetect : (use_symbol_align == "ON" ? wa_invalidcode : 1'b0));   

assign decoder_syncstatusin = (use_rate_match_fifo == "ON") ? cmfifo_syncstatus : (use_channel_align == "ON" ? dsfifo_syncstatus : (use_symbol_align == "ON" ? wa_syncstatus : 1'b1));   

assign decoder_disperrin = (use_rate_match_fifo == "ON") ? cmfifo_disperr : (use_channel_align == "ON" ? dsfifo_disperr : (use_symbol_align == "ON" ? wa_disperr : 1'b0));   

assign decoder_patterndetectin = (use_rate_match_fifo == "ON") ? cmfifo_patterndetect : (use_channel_align == "ON" ? dsfifo_patterndetect : (use_symbol_align == "ON" ? wa_patterndetect : 1'b0));   

assign decoder_indatavalid = (use_rate_match_fifo == "ON") ? cmfifo_datavalid : 1'b1;   

// rx_core inputs
assign core_datain          = (use_post8b10b_feedback == "ON") ? post8b10b : ((use_8b_10b_mode == "ON") ? {2'b00, decoder_dataout} : decoder_tenBdata);
assign core_writeclk        = clk_2;
assign core_readclk         = rx_rd_clk;
assign core_decdatavalid    = (use_8b_10b_mode == "ON") ? decoder_decdatavalid : 1'b1;
assign core_xgmdatain       = xgmdatain_in;
assign core_xgmctrlin       = xgmctrlin_in;
assign core_post8b10b       = post8b10b_in;
assign core_syncstatusin    = decoder_syncstatus;
assign core_errdetectin     = decoder_errdetect; 
assign core_ctrldetectin    = decoder_ctrldetect; 
assign core_disparityerrin  = decoder_disperr; 
assign core_patterndetectin = decoder_patterndetect; 

// sub modules
altgxb_hssi_rx_serdes s_rx_serdes	
  (
   .cruclk(cruclk), 
   .datain(datain), 
   .areset(analogreset_in), 
   .feedback(serialfdbk), 
   .fbkcntl(slpbk), 
   .ltr(locktorefclk),
   .ltd(locktodata),
   .clkout(serdes_clkout), 
   .dataout(serdes_dataout), 
   .rlv(serdes_rlv), 
   .lock(serdes_lock), 
   .freqlock(serdes_freqlock), 
   .signaldetect(serdes_signaldetect) 
   );
   defparam s_rx_serdes.channel_width = deserialization_factor;
   defparam s_rx_serdes.run_length_enable = run_length_enable;
   defparam s_rx_serdes.run_length = run_length; 
   defparam s_rx_serdes.cruclk_period = cruclk_period;
   defparam s_rx_serdes.cruclk_multiplier = cruclk_multiplier;
   defparam s_rx_serdes.use_cruclk_divider = use_cruclk_divider; 
   defparam s_rx_serdes.use_double_data_mode = use_double_data_mode; 

altgxb_hssi_word_aligner s_wordalign	(	
													.datain(wa_datain), 
													.clk(wa_clk), 
													.softreset(reset_int), 
													.enacdet(wa_enacdet), 
													.bitslip(wa_bitslip), 
													.a1a2size(wa_a1a2size), 
													.aligneddata(wa_aligneddata), 
													.aligneddatapre(wa_aligneddatapre), 
													.invalidcode(wa_invalidcode), 
													.invalidcodepre(wa_invalidcodepre), 
													.syncstatus(wa_syncstatus), 
													.syncstatusdeskew(wa_syncstatusdeskew), 
													.disperr(wa_disperr), 
													.disperrpre(wa_disperrpre), 
													.patterndetect(wa_patterndetect),
													.patterndetectpre(wa_patterndetectpre)
													);
	defparam s_wordalign.channel_width = deserialization_factor;
	defparam s_wordalign.align_pattern_length = align_pattern_length;
	defparam s_wordalign.infiniband_invalid_code = infiniband_invalid_code;
	defparam s_wordalign.align_pattern = align_pattern;
	defparam s_wordalign.synchronization_mode = synchronization_mode;
	defparam s_wordalign.use_auto_bit_slip = use_auto_bit_slip; 

altgxb_deskew_fifo s_dsfifo	(
										.datain(dsfifo_datain),
										.errdetectin(dsfifo_errdetectin),
										.syncstatusin(dsfifo_syncstatusin),
										.disperrin(dsfifo_disperrin),   
										.patterndetectin(dsfifo_patterndetectin),
										.writeclock(dsfifo_writeclock),  
										.readclock(dsfifo_readclock),   
										.adetectdeskew(dsfifo_adetectdeskew),
										.fiforesetrd(dsfifo_fiforesetrd),
										.enabledeskew(dsfifo_enabledeskew),
										.reset(reset_int),
										.dataout(dsfifo_dataout),   
										.dataoutpre(dsfifo_dataoutpre),   
										.errdetect(dsfifo_errdetect),    
										.syncstatus(dsfifo_syncstatus),
										.disperr(dsfifo_disperr),
										.errdetectpre(dsfifo_errdetectpre),    
										.syncstatuspre(dsfifo_syncstatuspre),
										.disperrpre(dsfifo_disperrpre),
										.patterndetect(dsfifo_patterndetect),
										.patterndetectpre(dsfifo_patterndetectpre),
										.rdalign(dsfifo_rdalign)
										);

altgxb_comp_fifo s_cmfifo	
   (
    .datain(cmfifo_datain),
    .datainpre(cmfifo_datainpre),
    .reset(reset_int),
    .errdetectin(cmfifo_invalidcodein), 
    .syncstatusin(cmfifo_syncstatusin),
    .disperrin(cmfifo_disperrin),
    .patterndetectin(cmfifo_patterndetectin),
    .errdetectinpre(cmfifo_invalidcodeinpre), 
    .syncstatusinpre(cmfifo_syncstatusinpre),
    .disperrinpre(cmfifo_disperrinpre),
    .patterndetectinpre(cmfifo_patterndetectinpre),
    .writeclk(cmfifo_writeclk),
    .readclk(cmfifo_readclk),
    .re(cmfifo_re),
    .we(cmfifo_we),
    .fifordin(cmfifo_fifordin),
    .disablefifordin(cmfifo_disablefifordin),
    .disablefifowrin(cmfifo_disablefifowrin),
    .alignstatus(cmfifo_alignstatus),
    .dataout(cmfifo_dataout),
    .errdetectout(cmfifo_invalidcode),
    .syncstatus(cmfifo_syncstatus),
    .disperr(cmfifo_disperr),
    .patterndetect(cmfifo_patterndetect),
    .codevalid(cmfifo_datavalid),
    .fifofull(cmfifo_fifofull),
    .fifoalmostful(cmfifo_fifoalmostfull),
    .fifoempty(cmfifo_fifoempty),
    .fifoalmostempty(cmfifo_fifoalmostempty),
    .disablefifordout(cmfifo_disablefifordout),
    .disablefifowrout(cmfifo_disablefifowrout),
    .fifordout(cmfifo_fifordout)
    );
   defparam 	 s_cmfifo.use_rate_match_fifo = use_rate_match_fifo;
   defparam 	 s_cmfifo.rate_matching_fifo_mode = rate_matching_fifo_mode;
   defparam 	 s_cmfifo.use_channel_align = use_channel_align;
   defparam 	 s_cmfifo.channel_num = channel_num;
   defparam 	 s_cmfifo.for_engineering_sample_device = for_engineering_sample_device; // new in 3.0 sp2 
      
altgxb_8b10b_decoder	s_decoder	
  (
   .clk(decoder_clk), 
   .reset(reset_int),  
   .errdetectin(decoder_errdetectin), 
   .syncstatusin(decoder_syncstatusin), 
   .disperrin(decoder_disperrin),
   .patterndetectin(decoder_patterndetectin),
   .datainvalid(decoder_indatavalid), 
   .datain(decoder_datain), 
   .valid(decoder_valid), 
   .dataout(decoder_dataout), 
   .tenBdata(decoder_tenBdata),
   .errdetect(decoder_errdetect),
   .rderr(decoder_rderr),
   .syncstatus(decoder_syncstatus),
   .disperr(decoder_disperr),
   .patterndetect(decoder_patterndetect),
   .kout(decoder_ctrldetect),
   .decdatavalid(decoder_decdatavalid),
   .xgmdatavalid(decoder_xgmdatavalid),
   .xgmrunningdisp(decoder_xgmrunningdisp),
   .xgmctrldet(decoder_xgmctrldet),
   .xgmdataout(decoder_xgmdataout)
   );
      
altgxb_rx_core s_rx_core	
   (
    .reset(reset_int),
    .datain(core_datain),
    .writeclk(core_writeclk),
    .readclk(core_readclk),
    .decdatavalid(core_decdatavalid),
    .xgmdatain(core_xgmdatain),
    .xgmctrlin(core_xgmctrlin),
    .post8b10b(core_post8b10b),
    .syncstatusin(core_syncstatusin),
    .errdetectin(core_errdetectin),
    .ctrldetectin(core_ctrldetectin),
    .disparityerrin(core_disparityerrin),
    .patterndetectin(core_patterndetectin),
    .dataout(core_dataout),
    .a1a2sizeout(core_a1a2sizeout),
    .syncstatus(core_syncstatus),
    .errdetect(core_errdetect),
    .ctrldetect(core_ctrldetect),
    .disparityerr(core_disparityerr),
    .patterndetect(core_patterndetect),
    .clkout(core_clkout)
    );
   defparam s_rx_core.channel_width        = deserialization_factor;
   defparam s_rx_core.use_double_data_mode = use_double_data_mode;
   defparam s_rx_core.use_channel_align    = use_channel_align;
   defparam s_rx_core.use_8b_10b_mode      = use_8b_10b_mode;
   defparam s_rx_core.synchronization_mode = synchronization_mode;
   defparam s_rx_core.align_pattern        = align_pattern;

// - added gfifo
altgxb_hssi_divide_by_two s_rx_clkout_mux	
(
   .reset(reset_int),
   .clkin(rxrdclk_mux1), 
   .clkout(clkoutmux_clkout_pre)
);
defparam s_rx_clkout_mux.divide = use_double_data_mode;

// gererate output signals

// outputs from serdes
and (recovclkout, 1'b1, serdes_clkout);
and (rlv, 1'b1, serdes_rlv);
and (lock, serdes_lock, 1'b1);
and (freqlock, serdes_freqlock, 1'b1);
and (signaldetect, serdes_signaldetect, 1'b1);

// outputs from word_aligner
and (syncstatusdeskew, wa_syncstatusdeskew, 1'b1);

// outputs from deskew FIFO
and (adetectdeskew, dsfifo_adetectdeskew, 1'b1);
and (rdalign, dsfifo_rdalign, 1'b1);

// outputs from comp FIFO
and (fifofull, cmfifo_fifofull, 1'b1);
and (fifoalmostfull, cmfifo_fifoalmostfull, 1'b1);
and (fifoempty, cmfifo_fifoempty, 1'b1);
and (fifoalmostempty, cmfifo_fifoalmostempty, 1'b1);
and (fifordout, cmfifo_fifordout, 1'b1);
and (disablefifordout, cmfifo_disablefifordout, 1'b1);
and (disablefifowrout, cmfifo_disablefifowrout, 1'b1);

// outputs from decoder 
and (xgmctrldet, decoder_xgmctrldet, 1'b1);
and (xgmrunningdisp, decoder_xgmrunningdisp, 1'b1);
and (xgmdatavalid, decoder_xgmdatavalid, 1'b1);

buf (xgmdataout[0], decoder_xgmdataout[0]);
buf (xgmdataout[1], decoder_xgmdataout[1]);
buf (xgmdataout[2], decoder_xgmdataout[2]);
buf (xgmdataout[3], decoder_xgmdataout[3]);
buf (xgmdataout[4], decoder_xgmdataout[4]);
buf (xgmdataout[5], decoder_xgmdataout[5]);
buf (xgmdataout[6], decoder_xgmdataout[6]);
buf (xgmdataout[7], decoder_xgmdataout[7]);

// outputs from rx_core
and (syncstatus[0], core_syncstatus[0], 1'b1);
and (syncstatus[1], core_syncstatus[1], 1'b1);

and (patterndetect[0], core_patterndetect[0], 1'b1);
and (patterndetect[1], core_patterndetect[1], 1'b1);

and (ctrldetect[0], core_ctrldetect[0], 1'b1);
and (ctrldetect[1], core_ctrldetect[1], 1'b1);

and (errdetect[0], core_errdetect[0], 1'b1);
and (errdetect[1], core_errdetect[1], 1'b1);

and (disperr[0], core_disparityerr[0], 1'b1);
and (disperr[1], core_disparityerr[1], 1'b1);

and (a1a2sizeout[0], core_a1a2sizeout[0], 1'b1);
and (a1a2sizeout[1], core_a1a2sizeout[1], 1'b1);

assign dataout_tmp = core_dataout;

buf (dataout[0], dataout_tmp[0]);
buf (dataout[1], dataout_tmp[1]);
buf (dataout[2], dataout_tmp[2]);
buf (dataout[3], dataout_tmp[3]);
buf (dataout[4], dataout_tmp[4]);
buf (dataout[5], dataout_tmp[5]);
buf (dataout[6], dataout_tmp[6]);
buf (dataout[7], dataout_tmp[7]);
buf (dataout[8], dataout_tmp[8]);
buf (dataout[9], dataout_tmp[9]);
buf (dataout[10], dataout_tmp[10]);
buf (dataout[11], dataout_tmp[11]);
buf (dataout[12], dataout_tmp[12]);
buf (dataout[13], dataout_tmp[13]);
buf (dataout[14], dataout_tmp[14]);
buf (dataout[15], dataout_tmp[15]);
buf (dataout[16], dataout_tmp[16]);
buf (dataout[17], dataout_tmp[17]);
buf (dataout[18], dataout_tmp[18]);
buf (dataout[19], dataout_tmp[19]);

// output from clkout mux
// - added gfifo
assign clkoutmux_clkout = ((use_parallel_feedback == "OFF") && clk_out_mode_reference == "OFF") ? serdes_clkout : clkoutmux_clkout_pre;
and (clkout, 1'b1, clkoutmux_clkout);

endmodule




