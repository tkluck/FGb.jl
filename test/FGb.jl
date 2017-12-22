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

    c1,c2,c3 = formal_coefficients(R, :c)
    c1 = @constant_coefficient c1 x y z
    c2 = @constant_coefficient c2 x y z
    c3 = @constant_coefficient c3 x y z
    S = typeof(c1)

    FGb_with(S, 3) do FGbPolynomial
        f = FGbPolynomial(c1*c2)
        g = FGbPolynomial(c1)
        G = groebner([f,g])

        println(G)
        println(map(g->convert(S,g), G))
    end
end
