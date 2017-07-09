# FGb.jl

[![Build Status](https://travis-ci.org/tkluck/FGb.jl.svg?branch=master)](https://travis-ci.org/tkluck/FGb.jl)

[![Coverage Status](https://coveralls.io/repos/tkluck/FGb.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/tkluck/FGb.jl?branch=master)

[![codecov.io](http://codecov.io/github/tkluck/FGb.jl/coverage.svg?branch=master)](http://codecov.io/github/tkluck/FGb.jl?branch=master)

A Julia wrapper for Jean-Charles Faugère's famous [`FGb` library](http://www-polsys.lip6.fr/~jcf/FGb/index.html).

# Synopsis

```julia
R,(x,y,z) = polynomial_ring(Int, :x, :y, :z)
FGb_with(R) do FGbPolynomial
    f = FGbPolynomial(x^2*y)
    g = FGbPolynomial(x)
    G = groebner([f,g])

    println(G)
    println(map(g->convert(R,g), G))
end
```

