cd(@__DIR__) do
    if !ispath("call_FGb")
        run(`wget http://www-polsys.lip6.fr/\~jcf/FGb/C/@downloads/call_FGb6.maclinux.x64.tar.gz`)
        run(`tar -xzf call_FGb6.maclinux.x64.tar.gz`)
    end

    Cdir = joinpath("call_FGb","nv","maple","C")

    BLOBSDIR = is_linux() ? "x64" : is_apple() ? "macosx" : assert(false)
    LIBDIR = joinpath(Cdir, BLOBSDIR)

    run(`gcc -m64 -c -fPIC dummy-hooks.c`)
    run(`g++ -m64 -shared -o libfgb.so dummy-hooks.o -L$(LIBDIR) -Wl,-zmuldefs -Wl,--whole-archive -lfgb -lfgbexp -lgb -lgbexp -lminpoly -lminpolyvgf -Wl,--no-whole-archive -lgmp -lm -fopenmp`)
end
if nothing == try Pkg.installed("PolynomialRings") end
    Pkg.clone("https://github.com/tkluck/PolynomialRings.jl")
end
