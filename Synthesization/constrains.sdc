###################################################################
set PERIOD  7.0
set RESET_DELAY  0.85
set INPUT_DELAY  1.0
set OUTPUT_DELAY  1.0
set CLOCK_LATENCY 0.4       
set MIN_IO_DELAY 1.0
set MAX_TRANSITION 0.5

#reference library cells
set REFLIB "saed90nm_typ_ht_pg.db:saed90nm_typ_ht_pg"
set BUFFER "NBUFFX16"
set SDFF  "SDFFARX1"
set BUF_IN_PIN "IN"
set BUF_OUT_PIN "Q"
set WIRELOAD_LIB_NAME "saed90nm_typ_ht.db:saed90nm_typ_ht"
echo "===============initials finishes============"

###################################################################
#set sdc_version 1.8
#set_units -time ns -resistance kOhm -capacitance pF -voltage V -current uA


###################################################
## CLOCK BASICS
create_clock -name "clock" -period $PERIOD [get_ports clk]
#set_clock_latency $CLOCK_LATENCY  [get_clocks clock]
#set_clock_uncertainty 0.3 [get_clocks clock ]
#set_clock_transition 0.4 [get_clocks clock ]


#set_input_delay -clock clock  $RESET_DELAY  [get_ports rst]
echo "===============Clock basics finishes============"
#################################################################
## GROUPING
group_path  -name CLOCK\
            -from clock\
            -weight 1

group_path  -name INPUTS\
            -through [all_inputs]\
            -weight 1

group_path  -name OUTPUTS\
            -to [all_outputs]\
            -weight 1
#################################################################			
## IN/OUT
set INPUTPORTS [remove_from_collection [all_inputs] [get_ports {clk rst} ]]
set OUTPUTPORTS [all_outputs]

set_driving_cell -lib_cell NBUFFX16 -pin Q [get_ports clk] -no_design_rule
set_driving_cell -lib_cell SDFFARX1 -pin Q [get_ports rst] -no_design_rule


set_wire_load_model -lib $WIRELOAD_LIB_NAME -name "ForQA"
#set_load -pin_load 0.004 $OUTPUTPORTS

#set_input_delay -clock "clock" -max $INPUT_DELAY $INPUTPORTS 
#set_output_delay -clock "clock"  -max $OUTPUT_DELAY $OUTPUTPORTS
#set_input_delay -clock "clock" -min $MIN_IO_DELAY $INPUTPORTS 
#set_output_delay -clock "clock" -min $MIN_IO_DELAY $OUTPUTPORTS


set_fix_hold clock

echo "===============IO finishes============"
#################################################################
## Area
#set_max_area  13000
echo "===============Area finishes============"
#################################################################	
## DRC
#set_max_transition $MAX_TRANSITION [current_design]
#set_max_fanout 1000 [current_design]
echo "===============All finishes============"
