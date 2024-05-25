# operating conditions and boundary conditions #

set cycle 15.0
create_clock -name clk  -period $cycle   [get_ports  clk] 

set_clock_uncertainty  0.1  [all_clocks]
set_clock_latency      1.0  [all_clocks]


#Don't touch the basic env setting as below
set_input_delay  1   -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 1    -clock clk [all_outputs]

set_load         1   [all_outputs]
set_drive        0.1   [all_inputs]

set_operating_conditions -max_library slow -max slow
set_wire_load_model -name tsmc13_wl10 -library slow                        
set_max_fanout 20 [all_inputs]

