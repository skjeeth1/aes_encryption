proc run_sim {top_module tb_module} {

    set part xc7a35tcpg236-1  ;# Basys3
    set src_dir ./src
    set tb_dir ./tests
    set sim_dir ./sim
   
    # Close any open projects
    close_project -quiet
    file delete -force -- {*}[glob -nocomplain *.xpr *.os *.jou *.log *.srcs *.cache *.runs .Xil *.hw *.ip_user_files *.sim *.str *.pb]

    # Kill any running sims
    if {[string length [current_sim -quiet]]} {
        close_sim -force
    }
    
    # Create a dummy project
    create_project [string toupper $top_module] -part $part -force

    # Read SV and V source files
    if {[glob -nocomplain $src_dir/*.sv] != ""} {
        puts "Reading RTL SV files..."
        add_files -fileset sources_1 [glob $src_dir/*.sv]
    }
    if {[glob -nocomplain $src_dir/*.v] != ""} {
        puts "Reading RTL Verilog files..."
        add_files -fileset sources_1 [glob $src_dir/*.v]
    }

    # set_property top $top_module [current_fileset]

    # Read SV and V tb files
    if {[glob -nocomplain $tb_dir/*.sv] != ""} {
        puts "Reading TB SV files..."
        add_files -fileset sim_1 [glob $tb_dir/*.sv]
    }
    if {[glob -nocomplain $tb_dir/*.v] != ""} {
        puts "Reading TB Verilog files..."
        add_files -fileset sim_1 [glob $tb_dir/*.v]
    }

    set_property top $tb_module [get_filesets sim_1]
    
    launch_simulation -simset sim_1 -mode behavioral
    # start_gui
    
}
