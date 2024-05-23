#RTL simulation, single pattern
vcs -R -sverilog qr_cordic_tb.v qr_cordic.v +access+r +vcs+fsdbon +fsdb+mda +fsdbfile+qr_cordic.fsdb


#Gate-Level simuation
#vcs -R -sverilog qr_cordic_tb.v qr_cordic_syn.v +define+SDF +access+r +neg_tchk +vcs+fsdbon +fsdb+mda +fsdbfile+qr_cordic.fsdb -v /home/cell_library/CBDK_IC_Contest_v2.5/Verilog/tsmc13_neg.v +maxdelays
