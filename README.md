# FGb.jl

[![Build Status](https://travis-ci.org/tkluck/FGb.jl.svg?branch=master)](https://travis-ci.org/tkluck/FGb.jl)

[![Coverage Status](https://coveralls.io/repos/tkluck/FGb.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/tkluck/FGb.jl?branch=master)

[![codecov.io](http://codecov.io/github/tkluck/FGb.jl/coverage.svg?branch=master)](http://codecov.io/github/tkluck/FGb.jl?branch=master)

A Julia wrapper for Jean-Charles Faugère's famous [`FGb` library](http://www-polsys.lip6.fr/~jcf/FGb/index.html).

# Synopsis

```julia
using PolynomialRings
@ring! ℤ[x,y]
using FGb # will automatically use FGb for subsequent calls to groebner_basis()
@show groebner_basis([x^5, x^2 + y, x*y + y^2]) # outputs [y + x^2, x*y, y^2]
```

