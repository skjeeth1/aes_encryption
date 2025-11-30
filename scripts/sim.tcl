proc run_sim {project_name top_module tb_module} {

    set part xc7a35tcpg236-1  ;# Basys3
    set src_dir ./src
    set tb_dir ./tests
    set sim_dir ./sim
    set xpr_file "$project_name.xpr"

    file delete -force -- {*}[glob -nocomplain *.xpr *.os *.jou *.log *.srcs *.cache *.runs .Xil *.hw *.ip_user_files *.sim *.str *.pb]
    # Check if a project is already open
    if {[string length [current_project -quiet]]} {
        puts "Project already open: [current_project]"
    } else {
        # No project open, check if an .xpr exists
        if {[file exists $xpr_file]} {
            puts "Opening existing project $xpr_file..."
            open_project $xpr_file
        } else {
            puts "Creating new project $project_name..."
            create_project $project_name -part $part -force
        }
    }

    if {[glob -nocomplain $src_dir/*.sv] != ""} {
        puts "Reading SV files..."
        add_files -fileset sources_1 [glob $src_dir/*.sv]
    }
    if {[glob -nocomplain $src_dir/*.v] != ""} {
        puts "Reading Verilog files..."
        add_files -fileset sources_1 [glob $src_dir/*.v]
    }

    set_property top $top_module [current_fileset]

    if {[glob -nocomplain $tb_dir/*.sv] != ""} {
        puts "Reading SV files..."
        add_files -fileset sim_1 [glob $tb_dir/*.sv]
    }
    if {[glob -nocomplain $tb_dir/*.v] != ""} {
        puts "Reading Verilog files..."
        add_files -fileset sim_1 [glob $tb_dir/*.v]
    }

    puts $tb_module
    set_property top $tb_module [get_filesets sim_1]
    
    # Kill any running simulation
    if {[string length [current_sim -quiet]]} {
        close_sim -force
    }

    launch_simulation
    # add_wave -r [get_scopes /$tb_module]
    # relaunch_sim
    #
    # save_wave_config $sim_dir/$top_module.wcfg
    # write_wave_database $sim_dir/$top_module.wdb
    #
    # start_gui
    
}
