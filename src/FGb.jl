module FGb

using PolynomialRings
using PolynomialRings: construct_monomial, variablesymbols
using PolynomialRings.Polynomials: terms
using PolynomialRings.Terms: coefficient, monomial

include("LibFGb.jl")

struct FGbPolynomial{T<:Polynomial}
    p::Ptr{Void}
end

in_FGb = false

function FGb_with(f::Function, ::Type{P}) where P<:Polynomial
    global in_FGb
    assert(!in_FGb)

    enter_INT()
    init_urgent(4,2,"DRLDRL",100000,0)
    log_file_handle = Ref{UInt}(0)
    init(1,1,0,log_file_handle)

    reset_coeffs(1)
    varnames = [String(var) for var in variablesymbols(P)]

    reset_expos(length(varnames), 0, varnames)

    internal_threads(8)
    mod_internal_threads(8)

    in_FGb = true
    res = try
        f(p -> convert(FGbPolynomial{P}, p))
    finally
        in_FGb = false
        reset_memory()
        exit_INT()
    end
    res
end

import Base: convert, show

function show(io::IO, f::FGbPolynomial{T}) where T
    print(io, "FGb(")
    show(io, convert(T,f))
    print(io, ")")
end

function convert(::Type{FGbPolynomial{T}}, f::T) where T<:Polynomial
    p = creat_poly(length(terms(f)))
    for (i,t) in enumerate(terms(f))
        exp = UInt32[e for e in monomial(t).e]
        set_expos2(p,i-1,exp,length(exp))
        set_coeff_gmp(p,i-1,coefficient(t))
    end
    full_sort_poly2(p)
    FGbPolynomial{T}(p)
end

function convert(::Type{T}, f::FGbPolynomial{T}) where T<:Polynomial
    n_vars = length(variablesymbols(T))
    n_terms = nb_terms(f.p)
    exponents = Vector{UInt32}(n_terms * n_vars)
    coeff_ptrs = Vector{Ptr{BigInt}}(n_terms)

    code = export_poly_INT_gmp2(n_vars, n_terms, coeff_ptrs, exponents, f.p)

    coefficients = map(unsafe_load, coeff_ptrs)

    sum( c * construct_monomial(T, exponents[(1+k*n_vars):((k+1)*n_vars)]) for (k,c) in zip(0:(n_terms-1), coefficients) )
end

function groebner(F::Vector{T}) where T <: FGbPolynomial
    OUTPUTSIZE=100000
    output_basis = Vector{Ptr{Void}}(OUTPUTSIZE)
    env = SFGB_Comp_Desc()
    cputime = Ref{Float64}(0)
    n = groebner(map(f->f.p, F), length(F), output_basis, 1, 0, cputime,0, -1, 0, env)
    [T(output_basis[i]) for i=1:n]
end

import PolynomialRings: groebner_basis, groebner_transformation, Term, TupleMonomial
import PolynomialRings.Backends.Groebner: Buchberger

struct FGbAlgorithm end

ApplicableBaserings = Union{BigInt, Rational{BigInt}}
ApplicablePolynomial = Polynomial{<:AbstractVector{<:Term{<:TupleMonomial,<:ApplicableBaserings}},:degrevlex}
function groebner_basis(::FGbAlgorithm, polynomials::AbstractArray{<:ApplicablePolynomial})
    integral_polynomials = [p for (p, _) in integral_fraction.(polynomials)]
    P = eltype(polynomials)
    PP = eltype(integral_polynomials)
    FGb_with(PP) do FGbPolynomial
        G = map(FGbPolynomial, integral_polynomials)
        gr = groebner(G)
        map(g -> convert(P, convert(PP,g)), gr)
    end
end

groebner_transformation(::FGbAlgorithm, args...) = groebner_transformation(Buchberger(), args...)
groebner_basis(::FGbAlgorithm, args...) = groebner_basis(Buchberger(), args...)

end
