proc compile {top} {
    set src_dir ./src
    set cnstrs_dir ./cnstrs
    set reports_dir ./reports

    close_project -quiet
    link_design -part xc7a35tcpg236-1
    
    if {[glob -nocomplain $src_dir/*.sv] != ""} {
        puts "Reading SV files..."
        read_verilog -sv [glob $src_dir/*.sv]
    }
    if {[glob -nocomplain $src_dir/*.v] != ""} {
        puts "Reading Verilog files..."
        read_verilog  [glob $src_dir/*.v]
    }

    puts "Synthesizing design..."
    synth_design -top $top -flatten_hierarchy full 
    
    read_xdc $cnstrs_dir/cnstrs.xdc
    
    set_property CFGBVS VCCO [current_design]
    set_property CONFIG_VOLTAGE 3.3 [current_design]

    # Just implement. This will avoid errors for unconstrained pins. Allocate them randomly
    # !TODO: Error if i/o pins exceed the FPGA i/o pins
    set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]

    puts "Placing Design..."
    place_design
    
    puts "Routing Design..."
    route_design

    puts "Writing checkpoint"
    write_checkpoint -force $top.dcp

    # Reports for implementation
    puts "Generating implementation reports..."
    # report_timing_summary      -file "$reports_dir/timing_summary.rpt"      -warn_on_violation
    # report_timing              -file "$reports_dir/timing_paths.rpt"        -max_paths 50
    # report_utilization         -file "$reports_dir/utilization.rpt"
    # report_power               -file "$reports_dir/power.rpt"
    # report_drc                 -file "$reports_dir/drc.rpt"
    # report_methodology         -file "$reports_dir/methodology.rpt"
    # report_design_analysis     -file "$reports_dir/design_analysis.rpt"
    # report_clock_utilization   -file "$reports_dir/clock_utilization.rpt"
    # report_clock_interaction   -file "$reports_dir/clock_interaction.rpt"
    # report_qor_suggestions     -file "$reports_dir/qor_suggestions.rpt"
    # report_route_status        -file "$reports_dir/route_status.rpt"

    #puts "Writing bitstream"
    #write_bitstream -force $top.bit
    
    puts "All done..."

    #close_project
}
