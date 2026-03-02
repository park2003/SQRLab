SQRLab.jl

SQRLab is a custom Julia package built on top of IonSim.jl and QuantumOptics.jl. It provides high-level abstractions for designing trapped ion quantum experiments, applying custom laser pulse sequences, and simulating environmental noise (decoherence).

📦 Installation & Dependencies

To successfully compile and run SQRLab, ensure that you have added its core dependencies to your Julia environment.

Crucial Version Requirement (Optim.jl): The Optim.jl package must be installed for the package to compile. IonSim and SQRLab rely on optimization routines (such as calculating the required laser intensity for a specific $\pi$-time).

⚠️ Version Conflict Warning: Do not use Optim v1.12.0 or higher. Version 1.12.0 removed the g_reltol parameter, which IonSim strictly requires. Using v1.12.0 will cause compilation and runtime failures. You must downgrade and pin Optim to v1.11.0 to maintain a stable environment.

To set up your stable environment, open the Julia REPL, press ] to enter the Package Manager, and run:

```
pkg> add IonSim QuantumOptics 

pkg> add Optim@1.11.0
```



⚠️ Important Warnings & Incomplete Implementations

Before developing further, be aware of the following architectural quirks and performance traps:

1. The "Closure" Performance Trap & The Ref Trick

    If you compile a new hamiltonian(chamber) inside a loop (e.g., sweeping over 100 wait times for a Ramsey sequence), Julia will recompile the ODE solver from scratch for every single step. This can turn a 2-minute simulation into a 10-hour simulation.

    Solution: Use pulse_dynamic. It takes a Ref{Float64} (a pointer) for the wait time. This allows you to compile the Hamiltonian once, and update the time pointer dynamically during the loop without triggering recompilation.

2. State Populations & expect Errors

    When extracting state populations from the simulation, run_simulation_hamiltonian returns a standard Float array representing the excited state ("e") population.

    - Do not use expect() on the resulting Float array.

    - To get the ground state ("g") population, simply use 1.0 - pop_e.

3. Incomplete Noise Implementations

    Currently, bfield_detune is a placeholder for updating the static magnetic field. Depending on your version of IonSim.jl, you may need to manually update chamber.B or utilize IonSim's bfield_fluctuation! directly. Ensure your noise models strictly update the physical parameters before compiling the Hamiltonian.

Module Reference

Trap Module

Handles the physical setup of the ion trap, ions, and lasers.

- create_standard_chamber(): Initializes a default experimental chamber containing a Calcium-40 (Ca40) ion, vibrational modes, and a driving laser.

Pulse Module

Defines laser sequences, timings, and intensities.

- simple_pulse(chamber; Duration=20.0, pitime=4e-6): Sets up a standard Ramsey experiment schedule (a $\pi/2$ pulse at t=0, a wait time, and a second $\pi/2$ pulse at Duration).

- pi2_pulse(chamber; apply_time, pitime, phase_shift): Injects a single $\pi/2$ pulse into the laser's existing schedule at apply_time. It safely wraps existing laser functions to prevent recursion (StackOverflowError).

- pulse_dynamic(chamber, wait_time_ref::Ref{Float64}, pitime): Highly Optimized. Generates a Ramsey sequence where the wait time is linked to a mutable pointer (wait_time_ref). Use this for fast parameter sweeps.

- bfield_detune(chamber, dB): Modifies the magnetic field of the chamber to simulate Zeeman noise.

- print_pulse_schedule(chamber; t_start, t_end, step): A debugging tool that prints a table showing exactly when your laser turns on/off and its phase.

Simulation Module

Handles the quantum solvers and statistical averaging.

- run_simulation_hamiltonian(chamber, h, tspan): Runs the Schrödinger equation solver for a pre-compiled Hamiltonian h over the time vector tspan. Returns (time_out, excited_population).

- simulate_decoherence(chamber, noise_distribution): Runs a full Monte Carlo simulation for a Ramsey experiment over a range of wait times (8µs to 100µs), applying random magnetic field noise sampled from noise_distribution. Returns the wait times and averaged ground-state populations. Uses loop-inversion for maximum speed.