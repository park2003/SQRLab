module SQRLab

using IonSim
using Distributions
using LsqFit
using Plots

include("Trap.jl")
include("Simulation.jl")
include("Pulse.jl")

using .Trap
using .Simulation
using .Pulse

export create_standard_chamber, run_simulation, run_simulation_hamiltonian, simple_pulse, bfield_detune, pi2_pulse, run_ramsey, simulate_decoherence

end