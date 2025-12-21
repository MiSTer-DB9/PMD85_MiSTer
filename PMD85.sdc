#
#
derive_pll_clocks
derive_clock_uncertainty

# core specific constraints

# core specific constraints
#
#create_generated_clock -name phi1 -source [get_nets {emu|pll|pll_inst|altera_pll_i|outclk_wire[0]}] -divide_by 9 -duty_cycle 22.23 [get_registers {emu:emu|PMD85_core:PMD85_core|i8224:i8224|phi1reg[0]}]
#create_generated_clock -name phi2 -source [get_nets {emu|pll|pll_inst|altera_pll_i|outclk_wire[0]}] -divide_by 9 -duty_cycle 55.56 [get_registers {emu:emu|PMD85_core:PMD85_core|i8224:i8224|phi2reg[0]}]

create_generated_clock -name phi1 -source [get_nets {emu|pll|pll_inst|altera_pll_i|outclk_wire[0]}] -divide_by 9 [get_registers {emu:emu|PMD85_core:PMD85_core|i8224:i8224|phi1reg[0]}]
create_generated_clock -name phi2 -source [get_nets {emu|pll|pll_inst|altera_pll_i|outclk_wire[0]}] -divide_by 9 [get_registers {emu:emu|PMD85_core:PMD85_core|i8224:i8224|phi2reg[0]}]


 
#
#set_multicycle_path -to {emu|PMD85_core|cpu|*} -setup 2
#set_multicycle_path -to {emu|PMD85_core|cpu|*} -hold 1


#create_generated_clock -name CAS -source [get_registers {emu:emu|PMD85_2A:PMD85core|i8224:i8224|phi2}] -divide_by 16 -duty_cycle 55.56  [get_registers {emu:emu|PMD85_2A:PMD85core|clk_shift[4]}]



### SDRAM delays
#set_input_delay -clock [get_clocks {emu|pll_SDRAM|pll_sdram_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] -max 6.4 [get_ports SDRAM_DQ[*]]
#set_input_delay -clock [get_clocks {emu|pll_SDRAM|pll_sdram_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] -min 3.2 [get_ports SDRAM_DQ[*]]
#
#set_output_delay -clock [get_clocks {emu|pll_SDRAM|pll_sdram_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] -max 1.5 [get_ports {SDRAM_D* SDRAM_A* SDRAM_BA* SDRAM_n* SDRAM_CKE}]
#set_output_delay -clock [get_clocks {emu|pll_SDRAM|pll_sdram_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] -min -0.8 [get_ports {SDRAM_D* SDRAM_A* SDRAM_BA* SDRAM_n* SDRAM_CKE}]
#set_output_delay -clock [get_clocks {emu|pll_SDRAM|pll_sdram_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] -max 1.5 [get_ports {SDRAM_CLK}]
#set_output_delay -clock [get_clocks {emu|pll_SDRAM|pll_sdram_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] -min -0.8 [get_ports {SDRAM_CLK}]


#  
#
#                                 
set_input_delay -clock [get_clocks {emu|pll|pll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}] -max 6.4 [get_ports SDRAM_DQ[*]]
set_input_delay -clock [get_clocks {emu|pll|pll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}] -min 3.2 [get_ports SDRAM_DQ[*]]

set_output_delay -clock [get_clocks {emu|pll|pll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}] -max 1.5 [get_ports {SDRAM_D* SDRAM_A* SDRAM_BA* SDRAM_n* SDRAM_CKE}]
set_output_delay -clock [get_clocks {emu|pll|pll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}] -min -0.8 [get_ports {SDRAM_D* SDRAM_A* SDRAM_BA* SDRAM_n* SDRAM_CKE}]
set_output_delay -clock [get_clocks {emu|pll|pll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}] -max 1.5 [get_ports {SDRAM_CLK}]
set_output_delay -clock [get_clocks {emu|pll|pll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}] -min -0.8 [get_ports {SDRAM_CLK}]


# 
#set_input_delay -clock [get_clocks {emu|pll|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -max 6.4 [get_ports SDRAM_DQ[*]]
#set_input_delay -clock [get_clocks {emu|pll|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -min 3.2 [get_ports SDRAM_DQ[*]]
#
#set_output_delay -clock [get_clocks {emu|pll|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -max 1.5 [get_ports {SDRAM_D* SDRAM_A* SDRAM_BA* SDRAM_n* SDRAM_CKE}]
#set_output_delay -clock [get_clocks {emu|pll|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -min -0.8 [get_ports {SDRAM_D* SDRAM_A* SDRAM_BA* SDRAM_n* SDRAM_CKE}]
#set_output_delay -clock [get_clocks {emu|pll|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -max 1.5 [get_ports {SDRAM_CLK}]
#set_output_delay -clock [get_clocks {emu|pll|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -min -0.8 [get_ports {SDRAM_CLK}]

