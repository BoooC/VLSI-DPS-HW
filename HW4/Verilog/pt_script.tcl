#PrimeTime Script
set power_enable_analysis TRUE
set power_analysis_mode time_based

read_file -format verilog  ./qr_cordic.v
current_design qr_cordic
link

source ./qr_cordic_APR.sdc
#read_parasitics -format SPEF -verbose  ./qr_cordic_pr.spef


## Measure  power
read_vcd  -strip_path test/u_qr_cordic  ./qr_cordic.fsdb
#report_switching_activity -list_not_annotated -show_pin

update_power

report_power


