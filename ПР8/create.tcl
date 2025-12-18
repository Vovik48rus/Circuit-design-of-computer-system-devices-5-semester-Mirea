cd [file dirname [info script]]
create_project divider_project divider_project -part xc7a100tcsg324-1
import_files -norecurse divider_project/divider.v
update_compile_order -fileset sources_1
file mkdir divider_project/divider_project.srcs/constrs_1
add_files -fileset constrs_1 -norecurse constr.xdc
import_files -fileset constrs_1 constr.xdc
launch_runs impl_1 -to_step write_bitstream -jobs 16
