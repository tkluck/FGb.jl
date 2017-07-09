using Base.Test
using PolynomialRings
using FGb

@testset "FGb" begin
    R,(x,y,z) = polynomial_ring(BigInt, :x, :y, :z)

    FGb_with(R) do FGbPolynomial
        f = FGbPolynomial(x^2*y)
        g = FGbPolynomial(x)
        G = groebner([f,g])

        println(G)
        println(map(g->convert(R,g), G))
    end
end
