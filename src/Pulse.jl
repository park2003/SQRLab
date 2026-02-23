module Pulse

using IonSim
using QuantumOptics

export simple_pulse, bfield_detune, pi2_pulse


    function simple_pulse(chamber; Duration::Float64=20.0, pitime::Float64=4e-6)
        
        return h = experiment(chamber, Duration; pitime=pitime)
    end

    function pi2_pulse(chamber; apply_time::Float64=0.0, pitime::Float64=4e-6, phase_shift::Bool=false)
        
        # print(chamber.lasers[1].I)
        # print(chamber.lasers[1].ϕ)
        res_intensity = intensity_from_pitime(chamber.lasers[1], pitime, chamber.iontrap.ions[1], ("g", "e"), chamber)


        pi2_time = pitime*1e6/2
        original_intensity = chamber.lasers[1].I
        original_phase = chamber.lasers[1].ϕ
        function intensity_modify(t)
            if (t >=apply_time && t <= apply_time + pi2_time)
                return res_intensity
            else
                return original_intensity(t)
            end
        end

        function phase_modify(t)
            if(phase_shift)
                if (t >=apply_time && t <= apply_time + pi2_time)
                    return π
                else
                    return original_phase(t)
                end
            else
                return original_phase(t)
            end
        end

        intensity!(chamber.lasers[1], intensity_modify)
        phase!(chamber.lasers[1], phase_modify)

        h = hamiltonian(chamber, timescale=1e-6, rwa_cutoff=Inf);
        return h
    end

    function pulse(T:: Chamber , wait_time, pitime)
    # Define the laser that will drive the transition
    L = T.lasers[1]

    # Combine all components into a single Trap object, which represents the full experiment
    # This is the main object that holds the entire state of our physical system.
    
    pi2_time = pitime*1e6/2

    res_intensity = intensity_from_pitime(L, pitime, T.iontrap.ions[1], ("g", "e"), T)

    print(pi2_time, " ", res_intensity, " ", wait_time, "\n")
    function intensity_funtion(t)
    if(t<=pi2_time)
        return res_intensity
    elseif(t>=(wait_time - pi2_time) && t <= wait_time)
        return res_intensity
    else
        return 0.0
    end

    end
    intensity!(L, intensity_funtion)

    function phase_funtion(t)
        if(t<=pi2_time)
            return 2*pi
        elseif(t>=wait_time - pi2_time)
            return pi
        else
            return 0.0
        end
    end

        phase!(L, phase_funtion)
        h = hamiltonian(T, timescale=1e-6, rwa_cutoff=Inf);
        return h
    end


    function experiment(T::Chamber, wait_time; pitime::Float64=4e-6)
        h = pulse(T, wait_time, pitime)
        return h
    end

    function bfield_detune(T::Chamber, dB)
        bfield_fluctuation!(T, dB)
        return T
    end

end

export pulse_dynamic

    function pulse_dynamic(T::Chamber, wait_time_ref::Ref{Float64}, pitime::Float64)
        L = T.lasers[1]
        pi2_time = pitime * 1e6 / 2
        res_intensity = intensity_from_pitime(L, pitime, T.iontrap.ions[1], ("g", "e"), T)

        function intensity_function(t)
            wt = wait_time_ref[] # Check the pointer for the current wait time
            if t <= pi2_time
                return res_intensity
            elseif t >= (wt - pi2_time) && t <= wt
                return res_intensity
            else
                return 0.0
            end
        end
        intensity!(L, intensity_function)

        function phase_function(t)
            wt = wait_time_ref[] # Check the pointer
            if t <= pi2_time
                return 2*pi
            elseif t >= (wt - pi2_time)
                return pi
            else
                return 0.0
            end
        end
        phase!(L, phase_function)
        
        # We compile the Hamiltonian ONCE!
        h = hamiltonian(T, timescale=1e-6, rwa_cutoff=Inf)
        return h
    end
