import QuantumToolbox as qt
using LinearAlgebra
using Symbolics

import NonlinearSolve as NLS
#using ProtoStructs

export Transmon, Init_Transmon

@kwdef struct SNAIL
    name :: String
    Eᶜ :: Float64
    Eʲ :: Float64
    Eˡ :: Float64
    α :: Float64 #
    Φ :: Float64 # Flux

    N_cut :: Int # U(1) Charge Number cutoff
    N :: Int # Number of Truncated Levels
    dim :: Int
    
    Ĥ_cut :: qt.QuantumObject
    Ĥ :: qt.QuantumObject

    n̂_cut :: qt.QuantumObject # Cut U(1) charge operator
    n̂ :: qt.QuantumObject # Truncated n operator

    eigsys_cut ::  qt.EigsolveResult
    eigsys :: qt.EigsolveResult
end


function SNAIL_c(n)
    @variables φ α N Φₑ

    U = -α*cos(φ) - N * cos((φ - Φₑ)/N)

    D = Differential(φ)^n

    return expand_derivatives(D(U))
end

function SNAIL_get_c_coeffs_bare(N_val, α_val, Φₑ_val)
    @variables φ N α Φₑ

    c_syms = []
    for n in 1:6
        c_sym = c(n)
        push!(c_syms, c_sym)
    end

    f_to_min(φ_val, p) = [Symbolics.value(substitute(c_syms[1], Dict(φ=>φ_val[1], N=>N_val, α => α_val, Φₑ => Φₑ_val)))]

    prob = NLS.NonlinearProblem(f_to_min, [0.0], [])
    ϕ_min = NLS.solve(prob)[1]
    @debug "ϕ_min: $ϕ_min"


    cs = [0]
    
    for n in 2:6
        push!(cs, Symbolics.value(substitute(c_syms[n], Dict(φ=>φ_min, N=>N_val, α=>α_val, Φₑ=>Φₑ_val))))
    end

    return cs
end

function SNAIL_get_c_coeffs_dressed(N, α, Φₑ, Eʲ, Eˡ)
    cs = SNAIL_get_c_coeffs_bare(N, α, Φₑ)
    φ = Eˡ/(Eˡ+cs[2]*Eʲ)

    c2_dr = φ*cs[2]
    c3_dr = cs[3]
    c4_dr = cs[4]-3*cs[3]^2/cs[2]*(1-φ)/φ
    c5_dr = cs[5]-10*cs[3]*cs[4]/cs[2]*(1-φ)/φ+15*cs[3]^2/cs[2]^2*(1-φ)^2/φ^2
    c6_dr = cs[6] - (10*cs[4]^2+15*cs[5]*cs[3])/(cs[2]*p)*(1-φ) * (105*cs[4]*cs[3]^2)/(cs[2]*φ)^2*(1-φ)^2-(105*cs[3]^4)/(cs[2]*φ)^3*(1-φ)^3

    return [0, c2_dr, c3_dr, c4_dr, c5_dr, c6_dr]
end

function Init_SNAIL(Eᶜ, Eʲ, Eˡ, α, Φₑ,  full_dim, N, name;  ng = 0)
    cs = SNAIL_get_c_coeffs_dressed(N, α, Φₑ, Eʲ, Eˡ)
    
    ν = sqrt(8*cs[2]*Eᶜ*Eʲ)
    φ_zpf = (2*Eᶜ/Eʲ/cs[2])

    â_full = qt.destroy(full_dim)
    n̂_full = 1im*(â_full'-â_full)
    φ̂_full = φ_zpf * (â_full'+â_full)

    Ĥ_full = ν*â_full'*â_full

    den = 2
    for n in 3:6
        den *= n
        Ĥ_full+=Eʲ*cs[n]/den*φ̂_full^n
    end

    eigsys_full = qt.eigenstates(Ĥ_full)
    
    Π = zeros(ComplexF64, full_dim, N)

    for i in 1:N
        Π[:, i] = eigsys_full.vectors[:,i]
    end

end
