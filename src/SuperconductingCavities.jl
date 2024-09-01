module SuperconductingCavities

import QuantumOptics as qo
using LinearAlgebra
using JSON

Base.:*(ket::qo.Ket, bra::qo.Bra) = qo.projector(ket, bra)

abstract type Model end

include("Hilbertspace_Constructor/Hilbertspace_Constructor.jl")
include("Circuits/Circuits.jl")
include("Utils/Utils.jl")



end