using Base.Test
using PolynomialRings
using FGb: FGb_with, groebner

@testset "FGb" begin
    R = @ring! ℤ[x,y,z]

    FGb_with(R) do FGbPolynomial
        f = FGbPolynomial(x^2*y)
        g = FGbPolynomial(x)
        G = groebner([f,g])

        println(G)
        println(map(g->convert(R,g), G))
    end

    S = @ring! ℤ[c[]]
    c1,c2,c3 = c[]

    FGb_with(S, 3) do FGbPolynomial
        f = FGbPolynomial(c1*c2)
        g = FGbPolynomial(c1)
        G = groebner([f,g])

        println(G)
        println(map(g->convert(S,g), G))
    end
end

@testset "Groebner testset" begin
    include(Pkg.dir("PolynomialRings", "test", "Groebner.jl"))
end
