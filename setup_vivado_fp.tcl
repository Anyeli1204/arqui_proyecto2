# ============================================================
# Script TCL para configurar proyecto de Vivado RISC-V Pipeline CON FP
# ============================================================
# USO:
#   1. Abre Vivado
#   2. En la Tcl Console, ejecuta:
#      cd C:/Users/anyel/OneDrive/Desktop/pipeline
#      source setup_vivado_fp.tcl
# ============================================================

# Directorio donde están los archivos fuente
set source_dir "C:/Users/anyel/OneDrive/Desktop/pipeline"

# Configuración del proyecto
set project_name "riscv_pipeline_fp"
set project_dir "C:/VivadoProjects/riscv_pipeline_fp"

# Crear directorio del proyecto si no existe
file mkdir $project_dir

# Crear o abrir proyecto
if {[file exists "$project_dir/$project_name.xpr"]} {
    puts "Abriendo proyecto existente..."
    open_project "$project_dir/$project_name.xpr"
} else {
    puts "Creando nuevo proyecto..."
    create_project $project_name $project_dir -part xc7a35tcpg236-1 -force
}

# Remover archivos antiguos si existen
if {[llength [get_files -of_objects [get_filesets sources_1]]] > 0} {
    puts "Removiendo archivos antiguos..."
    remove_files [get_files -of_objects [get_filesets sources_1]]
}

# Agregar TODOS los archivos fuente Verilog (CON FP)
puts "Agregando archivos fuente..."
add_files -fileset sources_1 [list \
    [file normalize "$source_dir/top.v"] \
    [file normalize "$source_dir/riscvpipeline.v"] \
    [file normalize "$source_dir/datapath.v"] \
    [file normalize "$source_dir/controller_fp.v"] \
    [file normalize "$source_dir/fpdec.v"] \
    [file normalize "$source_dir/hazard_unit.v"] \
    [file normalize "$source_dir/maindec.v"] \
    [file normalize "$source_dir/aludec.v"] \
    [file normalize "$source_dir/regfile.v"] \
    [file normalize "$source_dir/fregfile.v"] \
    [file normalize "$source_dir/extend.v"] \
    [file normalize "$source_dir/alu.v"] \
    [file normalize "$source_dir/alu_fp_full.v"] \
    [file normalize "$source_dir/adder.v"] \
    [file normalize "$source_dir/imem.v"] \
    [file normalize "$source_dir/dmem.v"] \
    [file normalize "$source_dir/flopr.v"] \
    [file normalize "$source_dir/mux2.v"] \
    [file normalize "$source_dir/mux3.v"] \
    [file normalize "$source_dir/mux_df.v"] \
    [file normalize "$source_dir/IF_ID.v"] \
    [file normalize "$source_dir/ID_EX.v"] \
    [file normalize "$source_dir/EX_MEM.v"] \
    [file normalize "$source_dir/MEM_WB.v"] \
]

# Agregar testbench si existe
if {[file exists "$source_dir/testbench.v"]} {
    puts "Agregando testbench..."
    add_files -fileset sim_1 [file normalize "$source_dir/testbench.v"]
    # Establecer testbench como top para simulación
    set_property top testbench [get_filesets sim_1]
    set_property top_lib xil_defaultlib [get_filesets sim_1]
}

# Establecer top module para síntesis
set_property top top [current_fileset]

# Actualizar orden de compilación
puts "Actualizando orden de compilación..."
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Configurar simulación
set_property target_simulator XSim [current_project]
set_property -name {xsim.simulate.runtime} -value {10000ns} -objects [get_filesets sim_1]

# Copiar archivo de memoria al directorio de simulación
if {[file exists "$source_dir/riscvtest_fp.txt"]} {
    set sim_dir "$project_dir/$project_name.sim/sim_1/behav/xsim"
    file mkdir $sim_dir
    file copy -force "$source_dir/riscvtest_fp.txt" "$sim_dir/riscvtest_fp.txt"
    puts "Archivo riscvtest_fp.txt copiado al directorio de simulación"
}

puts ""
puts "=========================================="
puts "Proyecto configurado exitosamente!"
puts "=========================================="
puts "Ubicación: $project_dir/$project_name.xpr"
puts "Top module (síntesis): top"
puts "Top module (simulación): testbench"
puts "Total archivos fuente: [llength [get_files -of_objects [get_filesets sources_1]]]"
puts "=========================================="
puts ""
puts "PRÓXIMOS PASOS:"
puts "1. Run Simulation -> Run Behavioral Simulation"
puts "2. Observa el waveform y la consola TCL"
puts "3. Agrega señales FP al waveform desde testbench/dut/rvpipeline/dp"
puts "=========================================="

