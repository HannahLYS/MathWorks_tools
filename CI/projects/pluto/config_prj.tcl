# Add System Reset IP
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0
endgroup

connect_bd_net [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins sys_ps7/FCLK_RESET0_N]
connect_bd_net [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins axi_ad9361/l_clk]

# Add 1 extra AXI master ports to the interconnect
set_property -dict [list CONFIG.NUM_MI {5}] [get_bd_cells axi_cpu_interconnect]
connect_bd_net [get_bd_pins axi_cpu_interconnect/M04_ACLK] [get_bd_pins axi_ad9361/l_clk]
connect_bd_net [get_bd_pins axi_cpu_interconnect/M04_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]

# Configure DMA
set_property -dict [list CONFIG.DMA_DATA_WIDTH_SRC {32} CONFIG.DMA_DATA_WIDTH_DEST {256} CONFIG.SYNC_TRANSFER_START {false} CONFIG.DMA_AXI_PROTOCOL_DEST {0} CONFIG.DMA_TYPE_SRC {1} CONFIG.MAX_BYTES_PER_BURST {32768}] [get_bd_cells axi_ad9361_adc_dma]
connect_bd_net [get_bd_pins axi_ad9361_adc_dma/s_axis_aclk] [get_bd_pins axi_ad9361/l_clk]
#connect_bd_net [get_bd_pins fir_decimator/m_axis_data_tdata] [get_bd_pins axi_ad9361_adc_dma/s_axis_data]
#connect_bd_net [get_bd_pins fir_decimator/m_axis_data_tvalid] [get_bd_pins axi_ad9361_adc_dma/s_axis_valid]

# Remove filters
delete_bd_objs [get_bd_cells fir_decimator]
#delete_bd_objs [get_bd_cells fir_interpolator]

# Insert pack cores
startgroup
create_bd_cell -type ip -vlnv analog.com:user:util_cpack:1.0 util_cpack_0
endgroup
set_property -dict [list CONFIG.CHANNEL_DATA_WIDTH {16} CONFIG.NUM_OF_CHANNELS {2}] [get_bd_cells util_cpack_0]

connect_bd_net [get_bd_pins util_cpack_0/adc_clk] [get_bd_pins axi_ad9361/l_clk]
connect_bd_net [get_bd_pins util_cpack_0/adc_data] [get_bd_pins axi_ad9361_adc_dma/s_axis_data]
connect_bd_net [get_bd_pins util_cpack_0/adc_valid] [get_bd_pins axi_ad9361_adc_dma/s_axis_valid]
connect_bd_net [get_bd_pins util_cpack_0/adc_valid_0] [get_bd_pins util_cpack_0/adc_enable_0]
connect_bd_net [get_bd_pins util_cpack_0/adc_valid_0] [get_bd_pins util_cpack_0/adc_enable_1]
connect_bd_net [get_bd_pins util_cpack_0/adc_valid_1] [get_bd_pins util_cpack_0/adc_valid_0]
connect_bd_net [get_bd_pins util_cpack_0/adc_rst] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]