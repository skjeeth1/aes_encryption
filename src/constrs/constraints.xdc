create_clock -name clock -period 10.0 [get_ports clock]
set_property HD.CLK_SRC BUFGCTRL_X0Y0 [get_ports clock]
