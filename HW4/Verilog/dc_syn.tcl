#Read All Files
read_file -format verilog  qr_cordic.v
current_design qr_cordic
link

#Setting Clock Constraints
source -echo -verbose qr_cordic.sdc
check_design
set high_fanout_net_threshold 0
uniquify
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]
#set_max_area 0
#Synthesis all design
#compile -map_effort high -area_effort high
#compile -map_effort high -area_effort high -inc
#compile_ultra 
#compile_ultra -timing_high_effort_script
#compile_ultra -area_high_effort_script
#compile_ultra -area
compile

write -format ddc     -hierarchy -output "qr_cordic_syn.ddc"
write_sdf -version 1.0  qr_cordic_syn.sdf
write -format verilog -hierarchy -output qr_cordic_syn.v
report_area > area.log
report_timing > timing.log
report_power > power.log
report_qor   >  qr_cordic_syn.qor
