using GeneralAdaptivePicardChebyshev
using Test

@testset "GeneralAdaptivePicardChebyshev.jl" begin
    #simple 2nd order ode
    ode = f(t,y,dy,params) = [-(2*pi)^2*y[1]]
    y0 = [1]
    dy0 = [0]
    t0 = 0.0
    tf = 1
    params = Dict()
    tol = 1e-14
    
    
    t,y,dy,ddy = integrate_ivp2(y0,dy0,t0,tf,tol,ode,params,N=20,exponent=1/20)
    @test isapprox(y[end],cos(2*pi),rtol=1e-6)
end

@testset "clenshawcurtisivpii.jl" begin
    # Chebyshev matrix for N=5, M=5
    @test TAPC.chebyshev(5,5) == [1 -1 1 -1 1 -1
    1 -0.80901699437494734 0.30901699437494723 0.30901699437494773 -0.80901699437494767 1
    1 -0.30901699437494734 -0.80901699437494745 0.80901699437494734 0.30901699437494773 -1
    1 0.30901699437494745 -0.80901699437494734 -0.80901699437494745 0.30901699437494723 1
    1 0.80901699437494734 0.30901699437494728 -0.30901699437494778 -0.80901699437494767 -1
    1 1 1 1 1 1]

    # Chebyshev matrix for N=5, M=10
    @test isapprox(TAPC.chebyshev(5,10),[1 -1 1 -1 1 -1
    1 -0.95105651629515353 0.80901699437494734 -0.58778525229247292 0.30901699437494701 5.5109105961630896e-16
    1 -0.80901699437494734 0.30901699437494723 0.30901699437494773 -0.80901699437494767 1
    1 -0.58778525229247303 -0.30901699437494756 0.95105651629515364 -0.80901699437494723 -4.2862637970157361e-16
    1 -0.30901699437494734 -0.80901699437494745 0.80901699437494734 0.30901699437494773 -1
    1 6.123233995736766e-17 -1 -1.8369701987210297e-16 1 3.0616169978683831e-16
    1 0.30901699437494745 -0.80901699437494734 -0.80901699437494745 0.30901699437494723 1
    1 0.58778525229247292 -0.30901699437494778 -0.95105651629515386 -0.80901699437494701 7.0448139982802221e-16
    1 0.80901699437494734 0.30901699437494728 -0.30901699437494778 -0.80901699437494767 -1
    1 0.95105651629515353 0.80901699437494723 0.5877852522924728 0.30901699437494684 -8.2694607974275756e-16
    1 1 1 1 1 1])

    #LSQ matrices for N=3, M=5 (using N-2 degree poly for second order integral)
    T, A = TAPC.lsq_chebyshev_fit(3,5)
    @test isapprox(T,[1 -1 1 -1
    1 -0.809016994374947 0.309016994374947 0.309016994374948
    1 -0.309016994374947 -0.809016994374947 0.809016994374947
    1 0.309016994374947 -0.809016994374947 -0.809016994374947
    1 0.809016994374947 0.309016994374947 -0.309016994374948
    1 1 1 1]) && isapprox(A,[0.1 0.2 0.2 0.2 0.2 0.1
    -0.2 -0.323606797749979 -0.123606797749979 0.123606797749979 0.323606797749979 0.2
    0.2 0.123606797749979 -0.323606797749979 -0.323606797749979 0.123606797749979 0.2
    -0.2 0.123606797749979 0.323606797749979 -0.323606797749979 -0.123606797749979 0.2])

    #LSQ matrices for N=5, M=5
    T, A = TAPC.lsq_chebyshev_fit(5,5)
    @test A ≈ [  0.1                 0.2                 0.2                0.2                 0.2 0.1
    -0.2  -0.323606797749979 -0.1236067977499789  0.123606797749979   0.323606797749979 0.2
     0.2  0.1236067977499789  -0.323606797749979 -0.323606797749979  0.1236067977499789 0.2
    -0.2  0.1236067977499791   0.323606797749979 -0.323606797749979 -0.1236067977499791 0.2
     0.2 -0.3236067977499791  0.1236067977499791 0.1236067977499789 -0.3236067977499791 0.2
    -0.1                 0.2                -0.2                0.2                -0.2 0.1 ] &&
    T ≈ [ 1                  -1                   1                  -1                   1 -1
    1 -0.8090169943749473  0.3090169943749472  0.3090169943749477 -0.8090169943749477  1
    1 -0.3090169943749473 -0.8090169943749475  0.8090169943749473  0.3090169943749477 -1
    1  0.3090169943749475 -0.8090169943749473 -0.8090169943749475  0.3090169943749472  1
    1  0.8090169943749473  0.3090169943749473 -0.3090169943749478 -0.8090169943749477 -1
    1                   1                   1                   1                   1  1]

    #LSQ matrices for N=3, M=10
    T, A = TAPC.lsq_chebyshev_fit(3,10)
    @test T ≈ [1 -1 1 -1
    1 -0.951056516295154 0.809016994374947 -0.587785252292473
    1 -0.809016994374947 0.309016994374947 0.309016994374948
    1 -0.587785252292473 -0.309016994374948 0.951056516295154
    1 -0.309016994374947 -0.809016994374947 0.809016994374947
    1 6.12323399573677e-17 -1 -1.83697019872103e-16
    1 0.309016994374947 -0.809016994374947 -0.809016994374947
    1 0.587785252292473 -0.309016994374948 -0.951056516295154
    1 0.809016994374947 0.309016994374947 -0.309016994374948
    1 0.951056516295154 0.809016994374947 0.587785252292473
    1 1 1 1] &&  
    A ≈ [0.05 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.05
    -0.1 -0.190211303259031 -0.161803398874989 -0.117557050458495 -0.0618033988749895 1.22464679914735e-17 0.0618033988749895 0.117557050458495 0.161803398874989 0.190211303259031 0.1
    0.1 0.161803398874989 0.0618033988749895 -0.0618033988749895 -0.16180339887499 -0.2 -0.161803398874989 -0.0618033988749896 0.0618033988749895 0.161803398874989 0.1
    -0.1 -0.117557050458495 0.0618033988749895 0.190211303259031 0.161803398874989 -3.67394039744206e-17 -0.16180339887499 -0.190211303259031 -0.0618033988749896 0.117557050458495 0.1]
    
    # Clenshaw-Curtis quadrature matrices for N=5, M=5
    A, Ta, P1, T1, P2, T2 = clenshaw_curtis_ivpii(5)
    @test A ≈ 
    [0.1 0.2 0.2 0.2 0.2 0.1
    -0.2 -0.323606797749979 -0.1236067977499789  0.123606797749979   0.323606797749979 0.2
     0.2 0.1236067977499789  -0.323606797749979 -0.323606797749979  0.1236067977499789 0.2
    -0.2 0.1236067977499791   0.323606797749979 -0.323606797749979 -0.1236067977499791 0.2] &&
    Ta ≈ 
    [ 1                  -1                   1                  -1
      1 -0.8090169943749473  0.3090169943749472  0.3090169943749477
      1 -0.3090169943749473 -0.8090169943749475  0.8090169943749473
      1  0.3090169943749475 -0.8090169943749473 -0.8090169943749475
      1  0.8090169943749473  0.3090169943749473 -0.3090169943749478
      1                   1                   1                   1] &&
    P1 ≈ 
    [ 1 -0.25 -0.3333333333333334 0.125
      1     0                -0.5     0
      0  0.25                   0 -0.25
      0     0  0.1666666666666667     0
      0     0                   0 0.125] &&
    T1 ≈ 
    [ 1                  -1                   1                  -1                   1
      1 -0.8090169943749473  0.3090169943749472  0.3090169943749477 -0.8090169943749477
      1 -0.3090169943749473 -0.8090169943749475  0.8090169943749473  0.3090169943749477
      1  0.3090169943749475 -0.8090169943749473 -0.8090169943749475  0.3090169943749472
      1  0.8090169943749473  0.3090169943749473 -0.3090169943749478 -0.8090169943749477
      1                   1                   1                   1                   1] &&
    P2 ≈ [ 1 -0.25 -0.3333333333333334 0.125 -0.06666666666666665
      1     0                -0.5     0                   0
      0  0.25                   0 -0.25                   0
      0     0  0.1666666666666667     0 -0.1666666666666667
      0     0                   0 0.125                   0
      0     0                   0     0                 0.1]&&
    T2 ≈ 
    [ 1                  -1                   1                  -1                   1 -1
      1 -0.8090169943749473  0.3090169943749472  0.3090169943749477 -0.8090169943749477  1
      1 -0.3090169943749473 -0.8090169943749475  0.8090169943749473  0.3090169943749477 -1
      1  0.3090169943749475 -0.8090169943749473 -0.8090169943749475  0.3090169943749472  1
      1  0.8090169943749473  0.3090169943749473 -0.3090169943749478 -0.8090169943749477 -1
      1                   1                   1                   1                   1  1]
end