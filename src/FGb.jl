module FGb

using PolynomialRings
using PolynomialRings: construct_monomial, variablesymbols
using PolynomialRings.Monomials: enumeratenz, AbstractMonomial
using PolynomialRings.Polynomials: terms
using PolynomialRings.Terms: coefficient, monomial
using PolynomialRings.NamedPolynomials: NamedPolynomial, PolynomialBy

include("LibFGb.jl")

struct FGbPolynomial{T<:Polynomial,N}
    p::Ptr{Void}
end

in_FGb = false

function FGb_with(f::Function, ::Type{P}, num_vars::Integer) where P<:Polynomial
    global in_FGb
    assert(!in_FGb)

    enter_INT()
    init_urgent(4,2,"DRLDRL",100000,0)
    log_file_handle = Ref{UInt}(0)
    init(1,1,0,log_file_handle)

    reset_coeffs(1)
    varnames = ["xx$n" for n=1:num_vars]

    reset_expos(num_vars, 0, varnames)

    internal_threads(8)
    mod_internal_threads(8)

    in_FGb = true
    res = try
        f(p -> convert(FGbPolynomial{P, num_vars}, p))
    finally
        in_FGb = false
        reset_memory()
        exit_INT()
    end
    res
end

FGb_with(f::Function, ::Type{P}) where P<:NamedPolynomial = FGb_with(f, P, length(variablesymbols(P)))

import Base: convert, show

function show(io::IO, f::FGbPolynomial{T}) where T
    print(io, "FGb(")
    show(io, convert(T,f))
    print(io, ")")
end

function convert(::Type{FGbPolynomial{T,N}}, f::T) where T<:Polynomial where N
    p = creat_poly(length(terms(f)))
    for (i,t) in enumerate(terms(f))
        exp = zeros(UInt32, N)
        for (j,e) in enumeratenz(monomial(t))
            exp[j] = e
        end
        set_expos2(p,i-1,exp,length(exp))
        set_coeff_gmp(p,i-1,coefficient(t))
    end
    full_sort_poly2(p)
    FGbPolynomial{T,N}(p)
end

function convert(::Type{T}, f::FGbPolynomial{T,N}) where T<:Polynomial where N
    n_terms = nb_terms(f.p)
    exponents = Vector{UInt32}(n_terms * N)
    coeff_ptrs = Vector{Ptr{BigInt}}(n_terms)

    code = export_poly_INT_gmp2(N, n_terms, coeff_ptrs, exponents, f.p)

    coefficients = map(unsafe_load, coeff_ptrs)

    sum( c * construct_monomial(T, exponents[(1+k*N):((k+1)*N)]) for (k,c) in zip(0:(n_terms-1), coefficients) )
end

function groebner(F::Vector{T}) where T <: FGbPolynomial
    OUTPUTSIZE=100000
    output_basis = Vector{Ptr{Void}}(OUTPUTSIZE)
    env = SFGB_Comp_Desc()
    cputime = Ref{Float64}(0)
    n = groebner(map(f->f.p, F), length(F), output_basis, 1, 0, cputime,0, -1, 0, env)
    [T(output_basis[i]) for i=1:n]
end

import PolynomialRings
import PolynomialRings: gröbner_basis

struct FGbAlgorithm <: PolynomialRings.Backends.Gröbner.Backend end

const ApplicableBaserings = Union{BigInt, Rational{BigInt}}
const ApplicablePolynomial = PolynomialBy{:degrevlex,<:ApplicableBaserings}

function gröbner_basis(::FGbAlgorithm, polynomials::AbstractArray{<:ApplicablePolynomial})
    length(polynomials) == 0 && return polynomials
    integral_polynomials = [p for (p, _) in integral_fraction.(polynomials)]
    P = eltype(polynomials)
    PP = eltype(integral_polynomials)
    num_vars = maximum(max_variable_index, integral_polynomials)
    FGb_with(PP, num_vars) do FGbPolynomial
        G = map(FGbPolynomial, integral_polynomials)
        gr = groebner(G)
        map(g -> convert(P, convert(PP,g)), gr)
    end
end

PolynomialRings.Backends.Gröbner.set_default(FGbAlgorithm())

end
