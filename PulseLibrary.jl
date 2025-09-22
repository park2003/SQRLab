module PulseLibrary

export Pulse, apply_pulse!, square_profile, gaussian_profile, blackman_profile

# #############################################################################
# 1. PULSE SHAPE LIBRARY
# A collection of functions that define normalized pulse envelopes.
# Each function takes a normalized time `t` from 0.0 to 1.0.
# #############################################################################

"""
    square_profile(t::Real)

A simple square (or "top-hat") pulse shape. Returns 1.0 for any `t` in .
"""
square_profile(t::Real) = 1.0

"""
    gaussian_profile(t::Real; σ::Real=0.15, μ::Real=0.5)

A Gaussian pulse shape, centered at `μ` (default 0.5) with standard deviation `σ`.
The function is truncated at t=0 and t=1 and normalized to have a peak value of 1.0.
"""
function gaussian_profile(t::Real; σ::Real=0.15, μ::Real=0.5)
    return exp(-((t - μ)^2) / (2 * σ^2))
end

"""
    blackman_profile(t::Real)

A Blackman window function, which provides excellent frequency selectivity.
It is a cosine-based envelope that goes smoothly to zero at the start and end.
See: https://en.wikipedia.org/wiki/Window_function#Blackman_window
"""
function blackman_profile(t::Real)
    # Standard Blackman window coefficients
    a0 = 0.42
    a1 = 0.5
    a2 = 0.08
    return a0 - a1 * cos(2π * t) + a2 * cos(4π * t)
end

#... (struct and function definitions below)...

end # module PulseLibrary