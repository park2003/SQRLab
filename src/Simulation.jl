module Simulation

using IonSim
using QuantumOptics
using Distributions # You'll need to add this package!
using ProgressMeter # For showing progress during the simulation

include("Pulse.jl")
using .Pulse

export run_simulation, run_simulation_hamiltonian, run_ramsey, simulate_decoherence

    function run_simulation(chamber, tspan)
        
        
        mode = zmodes(chamber)[1]
        #mode.N = 10
        C = Ca40([("S1/2", -1/2, "g"),("D5/2", -1/2, "e")])

        # Construct the time-independent Hamiltonian for the system
        # For a simple square pulse, the Hamiltonian is not time-dependent.
        # We set a high rwa_cutoff to ensure all terms are included.
        H = hamiltonian(chamber, rwa_cutoff=Inf)
        ψ_mode = fockstate(mode[1].basis, 0)
        ψ₀ = C["g"] ⊗ ψ_mode

        # Solve the time evolution using the Schrödinger equation solver from QuantumOptics.jl
        tout, sol = timeevolution.schroedinger_dynamic(tspan, ψ₀, H)

        # 5. Analyze and Visualize the Results
        # Calculate the population in the excited state |e⟩ over time
        excited_pop = expect(ionprojector(chamber, "e"), sol)
        return tout, excited_pop

    end

    @time function run_simulation_hamiltonian(t, h, tspan)
         mode = zmodes(t)[1]
        C = Ca40([("S1/2", -1/2, "g"),("D5/2", -1/2, "e")])
        H = hamiltonian(t,  rwa_cutoff=Inf)
        ψ_mode = fockstate(mode[1].basis, 0)
        ψ₀ = C["g"] ⊗ ψ_mode
        tout, sol = timeevolution.schroedinger_dynamic(tspan, ψ₀, h)
        # ψ_mode = fockstate(mode[1].basis, 0)
        # ψ₀ = C["g"] ⊗ ψ_mode
        excited_pop = expect(ionprojector(t, "e"), sol)
        return tout, excited_pop
    end

    # @time function run_ramsey(chamber, waittime, delB)
    #     x = Float64[]
    #     y = Float64[]

    #     for wait in waittime
    #         tspan1 = 0:0.1:wait
    #         bfield_fluctuation!(chamber, delB)
    #         h1_wait = pi2_pulse(chamber, apply_time=0.0, pitime=4e-6, phase_shift=false)
    #         h1_wait = pi2_pulse(chamber, apply_time=wait-2, pitime=4e-6 , phase_shift=true)
    #         tout1_wait, sol1_wait = run_simulation_hamiltonian(chamber, h1_wait, tspan1)
        

    #         push!(x, tout1_wait[end])
    #         push!(y, real(sol1_wait[end]))
    #     end

    #     println("Run ramsey $x $y ")
    #     flush(stdout)
    #     return x, y
    # end

    function run_ramsey(chamber, waittimes, b_flux)
    
    # 1. Apply your B-field changes
    bfield_fluctuation!(chamber, b_flux)
    
    # 2. Create the Reference pointer for the loop
    current_w = Ref(waittimes[1]) 
    
    # 3. Build the Hamiltonian ONLY ONCE before the loop starts
    h = pulse_dynamic(chamber, current_w, 4e-6)
    
    pops = Float64[]
    
    # 4. Run the loop
        for w in waittimes
            # Update the pointer. The laser functions inside 'h' will instantly see this new value!
            current_w[] = w 
            
            # Run the solver (it doesn't need to recompile, just computes the new numbers)
            tout, pop = run_simulation_hamiltonian(chamber, h, 0:0.1:w)
            
            # Save the final population
            push!(pops, pop[end])
        end
    
    return waittimes, pops
    end

    function run_ramsey_shot(t_wait, δB_shot)
    # The Chamber is now inside the function, as δB changes each time
    L = Laser()
    T = Chamber(
        iontrap=chain,
        B=0.37e-3,
        δB=δB_shot, # Use the random δB for this shot
        Bhat=ẑ,
        lasers=[L]
    )
    polarization!(L, (x̂ - ẑ)/√2)
    wavevector!(L, (x̂ + ẑ)/√2);
    wavelength_from_transition!(L, C, ("g", "e"), T)

    # Ramsey sequence: π/2 pulse, wait, π/2 pulse
    tspan = 0:0.1:t_wait*1e6
    h = pi2_pulse(chamber, apply_time=0.0, pitime=4e-6, phase_shift=false)
    h = pi2_pulse(chamber, apply_time=wait-2, pitime=4e-6 , phase_shift=true)
    tout, sol = run_simulation_hamiltonian(tspan, ψ₀, h)
    println("Run ramsey shot $tout $sol ")
     flush(stdout)
    return expect(ionprojector(T, "g"), sol[end])
end


# --- 4. Main Simulation Loop (Ensemble Average) ---
# function simulate_decoherence(noise_distribution)
#     wait_times = 8e-6:1e-6:1e-4 # Simulate for 300 ms, as in the paper's Ramsey fig
#     avg_g_population = []

#     @showprogress "Simulating Ramsey Fringes..." for t in wait_times
#         final_pops_for_t = zeros(N_shots)
#         for i in 1:N_shots
#             # For each shot, draw a NEW random magnetic field offset
#             δB_shot = rand(noise_distribution)
#             final_pops_for_t[i] = run_ramsey_shot(t, δB_shot)
#         end
#         # Average the results from all shots for this wait time
#         push!(avg_g_population, real(sum(final_pops_for_t) / N_shots))
#         println("Wait time $(t*1e3) ms: Avg. g-pop = $(avg_g_population)")
#          flush(stdout)
#     end
#     return wait_times, avg_g_population
# end


function simulate_decoherence(chamber, noise_distribution)
    N_shots = 200
    wait_times =8.0:1.0:100.0 
    avg_g_population = []

    @showprogress "Simulating Ramsey Fringes..." for t in wait_times
        final_pops_for_t = zeros(N_shots)
        for i in 1:N_shots
            # For each shot, draw a NEW random magnetic field offset
            δB_shot = rand(noise_distribution)
            x,y = run_ramsey(chamber, t, δB_shot) 
            final_pops_for_t[i] =1.0 - y[end]
        end
        # Average the results from all shots for this wait time
        push!(avg_g_population, real(sum(final_pops_for_t) / N_shots))
        println("Wait time $(t*1e3) ms: Avg. g-pop = $(avg_g_population)")
         flush(stdout)
    end
    return wait_times, avg_g_population
end

function simulate_decoherence(chamber, waittime, noise_distribution)
    N_shots = 200
    wait_times =8.0:1.0:waittime 
    avg_g_population = []

    @showprogress "Simulating Ramsey Fringes..." for t in wait_times
        final_pops_for_t = zeros(N_shots)
        for i in 1:N_shots
            # For each shot, draw a NEW random magnetic field offset
            δB_shot = rand(noise_distribution)
            x,y = run_ramsey(chamber, t, δB_shot) 
            final_pops_for_t[i] =1.0 - y[end]
        end
        # Average the results from all shots for this wait time
        push!(avg_g_population, real(sum(final_pops_for_t) / N_shots))
        println("Wait time $(t*1e3) ms: Avg. g-pop = $(avg_g_population)")
         flush(stdout)
    end
    return wait_times, avg_g_population
end
end