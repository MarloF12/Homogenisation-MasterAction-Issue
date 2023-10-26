# This is the input file to recreate the hex fibre composite validation used here:
#   "Development of a finite element based strain periodicity implementation method", Biswas, Schwen, Hales. 2020. Page 10.
#   https://www.sciencedirect.com/science/article/pii/S1359836822003328


# The path to the periodic rve mesh.
mesh_file = 'mesh_file.msh'
# The output csv file name for the cell average values.
csv_file = 'csv_file_name'

# This defines the homogenisation constraints.
# For the small strain homogenisation, six different stress constraints need to be run.
# The mapping is 
#          xx, xy/yx, yy, yz/zy, xz/zx, zz
targets = 'zero zero zero zero zero small'

# The imposed cell average stress magnitude (N/µm^2 in this example)
constraint_magnitude = 1e-3

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  large_kinematics = false
[]

[Mesh]
  [base]
    type = FileMeshGenerator
    file = ${mesh_file}
  []
[]



[Modules]
  [TensorMechanics]
    [Master]
      [all]
        strain = SMALL
        add_variables = true
        new_system = true
        formulation = TOTAL
        volumetric_locking_correction = false
        # could apply a strain constraint instead of stress, but it is arbitrary
        constraint_types = 'stress stress none none stress stress stress none stress'
        targets = ${targets}
        generate_output = 'pk1_stress_xx pk1_stress_xy pk1_stress_xz pk1_stress_yx pk1_stress_yy pk1_stress_yz pk1_stress_zx pk1_stress_zy pk1_stress_zz deformation_gradient_xx deformation_gradient_xy deformation_gradient_xz deformation_gradient_yx deformation_gradient_yy deformation_gradient_yz deformation_gradient_zx deformation_gradient_zy deformation_gradient_zz cauchy_stress_xx cauchy_stress_xy cauchy_stress_xz cauchy_stress_yx cauchy_stress_yy cauchy_stress_yz cauchy_stress_zx cauchy_stress_zy cauchy_stress_zz mechanical_strain_xx mechanical_strain_xy mechanical_strain_xz mechanical_strain_yx mechanical_strain_yy mechanical_strain_yz mechanical_strain_zx mechanical_strain_zy mechanical_strain_zz l2norm_pk1_stress'
      []
    []
  []
[]

[Functions]
  [zero]
    type = ConstantFunction
    value = 0
  []
  [small]
    type = ParsedFunction
    expression = '${constraint_magnitude}*t'
  []
[]

[BCs]
  [Periodic]
    [x]
      variable = disp_x
      auto_direction = 'x y z'
    []
    [y]
      variable = disp_y
      auto_direction = 'x y z'
    []
    [z]
      variable = disp_z
      auto_direction = 'x y z'
    []
  []

  # constraint BCs
  [fix_all_x]
    type = DirichletBC
    boundary = "fix_all"
    variable = disp_x
    value = 0
  []
  [fix_all_y]
    type = DirichletBC
    boundary = "fix_all"
    variable = disp_y
    value = 0
  []
  [fix_all_z]
    type = DirichletBC
    boundary = "fix_all"
    variable = disp_z
    value = 0
  []
  [fix_xy_x]
    type = DirichletBC
    boundary = "fix_xy"
    variable = disp_x
    value = 0
  []
  [fix_xy_y]
    type = DirichletBC
    boundary = "fix_xy"
    variable = disp_y
    value = 0
  []
  [fix_xy_z]
    type = DirichletBC
    boundary = "fix_xy"
    variable = disp_z
    value = 0
  []
  [fix3_x]
    type = DirichletBC
    boundary = "fix_z"
    variable = disp_x
    value = 0
  []
  [fix3_y]
    type = DirichletBC
    boundary = "fix_z"
    variable = disp_y
    value = 0
  []
  [fix3_z]
    type = DirichletBC
    boundary = "fix_z"
    variable = disp_z
    value = 0
  []
[]

[Materials]
  [elastic_tensor_1]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 68.3e-3 # N/µm^2
    poissons_ratio = 0.3
    block = 'matrix'
  []
  [elastic_tensor_2]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 379e-3 # N/µm^2
    poissons_ratio = 0.1
    block = 'fibre'
  []
  [compute_stress]
    type = ComputeLagrangianLinearElasticStress
  []
[]


[Executioner]
  type = Transient
  solve_type = PJFNK
  line_search = none
  automatic_scaling = true
  petsc_options_iname = '-pc_type -sub_pc_type'
  petsc_options_value = 'asm lu'
  # petsc_options_iname = '-pc_type -pc_hypre_type'
  # petsc_options_value = 'hypre    boomeramg'
  l_tol = 1e-4
  nl_rel_tol = 1e-8
  nl_abs_tol = 5e-10

  start_time = 0.0
  dt = 0.25
  end_time = 1.0
[]

[Postprocessors]
  # get the volume average properties
  [cauchy_bar_xx]
    type = ElementAverageValue
    variable = cauchy_stress_xx
    execute_on = 'FINAL'
  []
  [cauchy_bar_xy]
    type = ElementAverageValue
    variable = cauchy_stress_xy
    execute_on = 'FINAL'
  []
  [cauchy_bar_xz]
    type = ElementAverageValue
    variable = cauchy_stress_xz
    execute_on = 'FINAL'
  []
  [cauchy_bar_yx]
    type = ElementAverageValue
    variable = cauchy_stress_yx
    execute_on = 'FINAL'
  []
  [cauchy_bar_yy]
    type = ElementAverageValue
    variable = cauchy_stress_yy
    execute_on = 'FINAL'
  []
  [cauchy_bar_yz]
    type = ElementAverageValue
    variable = cauchy_stress_yz
    execute_on = 'FINAL'
  []
  [cauchy_bar_zx]
    type = ElementAverageValue
    variable = cauchy_stress_zx
    execute_on = 'FINAL'
  []
  [cauchy_bar_zy]
    type = ElementAverageValue
    variable = cauchy_stress_zy
    execute_on = 'FINAL'
  []
  [cauchy_bar_zz]
    type = ElementAverageValue
    variable = cauchy_stress_zz
    execute_on = 'FINAL'
  []

  [pk1_bar_xx]
    type = ElementAverageValue
    variable = pk1_stress_xx
    execute_on = 'FINAL'
  []
  [pk1_bar_xy]
    type = ElementAverageValue
    variable = pk1_stress_xy
    execute_on = 'FINAL'
  []
  [pk1_bar_xz]
    type = ElementAverageValue
    variable = pk1_stress_xz
    execute_on = 'FINAL'
  []
  [pk1_bar_yx]
    type = ElementAverageValue
    variable = pk1_stress_yx
    execute_on = 'FINAL'
  []
  [pk1_bar_yy]
    type = ElementAverageValue
    variable = pk1_stress_yy
    execute_on = 'FINAL'
  []
  [pk1_bar_yz]
    type = ElementAverageValue
    variable = pk1_stress_yz
    execute_on = 'FINAL'
  []
  [pk1_bar_zx]
    type = ElementAverageValue
    variable = pk1_stress_zx
    execute_on = 'FINAL'
  []
  [pk1_bar_zy]
    type = ElementAverageValue
    variable = pk1_stress_zy
    execute_on = 'FINAL'
  []
  [pk1_bar_zz]
    type = ElementAverageValue
    variable = pk1_stress_zz
    execute_on = 'FINAL'
  []

  [strain_bar_xx]
    type = ElementAverageValue
    variable = mechanical_strain_xx
    execute_on = 'FINAL'
  []
  [strain_bar_xy]
    type = ElementAverageValue
    variable = mechanical_strain_xy
    execute_on = 'FINAL'
  []
  [strain_bar_xz]
    type = ElementAverageValue
    variable = mechanical_strain_xz
    execute_on = 'FINAL'
  []
  [strain_bar_yx]
    type = ElementAverageValue
    variable = mechanical_strain_yx
    execute_on = 'FINAL'
  []
  [strain_bar_yy]
    type = ElementAverageValue
    variable = mechanical_strain_yy
    execute_on = 'FINAL'
  []
  [strain_bar_yz]
    type = ElementAverageValue
    variable = mechanical_strain_yz
    execute_on = 'FINAL'
  []
  [strain_bar_zx]
    type = ElementAverageValue
    variable = mechanical_strain_zx
    execute_on = 'FINAL'
  []
  [strain_bar_zy]
    type = ElementAverageValue
    variable = mechanical_strain_zy
    execute_on = 'FINAL'
  []
  [strain_bar_zz]
    type = ElementAverageValue
    variable = mechanical_strain_zz
    execute_on = 'FINAL'
  []
[]
[Outputs]
  [mesh]
    type = Exodus
    file_base = ${csv_file}
  []
  [average_variable_values]
    type = CSV
    execute_on = 'FINAL'
    file_base = ${csv_file}
  []
#   [Console]
#     type = Console
#     execute_on = 'INITIAL TIMESTEP_BEGIN NONLINEAR FAILED'
#   []
[]
