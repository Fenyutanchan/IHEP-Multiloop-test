using FeynUtils
using FIRE
# using Dates
# using JLD2
using OrderedCollections
using SeRA
using TestIHEPMultiloop
# using SymEngine
using YAML

set_PATH()
set_FIRE()
ENV["VAC_REDUCTION_SCRIPTS_DIR"] = @__DIR__

#--------------------------------------------------------------------
# Two-loop Self-energy Integral (TSI)
#--------------------------------------------------------------------

#############################
function gen_yaml_str(
    indices::Vector{Int64}
)::String
#############################

  return """

  name: "TSI$(reduce( *, to_String(indices) ))"

  n_loop: 2

  min_ep_xpt: -4
  max_ep_xpt: 0

  external_momenta: [ K1 ]

  kin_relation:
    - [ "SP(K1,K1)", "mm^2" ]

  den_list: [
  "Den(q2,0,ieta)",
  "Den(q1+K1,m0,ieta)",
  "Den(q2+K1,0,ieta)",
  "Den(q1+q2,0,ieta)",
  "Den(q1,0,ieta)"
  ]

  den_xpt_list: [ $(join( to_String(indices), ", " )) ]

  numerator: "1"

  momentum_symmetry: []

  color_symmetry: []

  comment: "Yaml file for TSI"

  """

end # function gen_yaml_str


##########################
function main()::Nothing
##########################

  #--------------------------------------------------------------------------
  all_SI_list = to_Basic([
  "SI(0,0,1,1,0)",
  "SI(0,1,0,1,0)",
  "SI(1,1,0,1,0)",
  "SI(1,1,0,2,0)",
  "SI(1,2,0,1,0)"
  ])

  seed_indices = [1,1,1,1,1]
  seed_name = "TSI$(reduce( *, to_String(seed_indices) ))"

  file = open( "$(seed_name).yaml", "w" )
  write( file, gen_yaml_str(seed_indices) )
  close( file )

  #--------------------------------------------------------
  file_dict = YAML.load_file( "$(seed_name).yaml"; dicttype=OrderedDict{String,Any} )
  loop_den_list = to_Basic( file_dict["den_list"] )
  vac_top_list, vac_master_symmetry, vac_master_list = gen_vac_reduction_ieta( loop_den_list )
  #--------------------------------------------------------

  #----------------------------------
  box_message( "Generate $(seed_name)" )
  generate_integral( "$(seed_name).yaml", vac_top_list, vac_master_symmetry, vac_master_list )
  #----------------------------------

  #----------------------------------
  scan_formfactors( "$(seed_name).jld2" )
  #----------------------------------

  #----------------------------------
  bk_mkdir( "workon_TSI" )
  cp( "phase_space_list.yaml", "workon_TSI/phase_space_list.yaml" )
  cp( "mass_config.yaml", "workon_TSI/mass_config.yaml" )
  cp( "$(seed_name).jld2", "workon_TSI/$(seed_name).jld2" )

  cd( "workon_TSI" )
  phase_space_list = read_phase_space_list("phase_space_list.yaml")
  n_ps = length(phase_space_list)
  for index in 1:n_ps
    phase_space = phase_space_list[index]
    fire_reduction_scripts( "$(seed_name).jld2", all_SI_list, phase_space, "fire_ieta_ps$(index)" )
  end # for index
  cd( ".." )
  #----------------------------------


  #----------------------------
  file = open( "fire_run_phase_space.sh", "w" )
  for index in 1:n_ps
  write( file, """
  cd workon_TSI/fire_ieta_ps$(index)
  julia --project=$((dirname∘Base.active_project)()) $(seed_name).jl
  cd ../..

  """ )
  end # for index
  close( file )

  run( `sh fire_run_phase_space.sh` )
  #----------------------------

  #-----------------------------------------------------
  # Choose one of the phase space
  ps_index = 1
  reduction_tables = "workon_TSI/fire_ieta_ps$(ps_index)/$(seed_name).tables"
  collect_master_integrals( ps_index, "$(seed_name).jld2", reduction_tables )
  #-----------------------------------------------------

  return nothing

end # function main

#########
main()
#########

