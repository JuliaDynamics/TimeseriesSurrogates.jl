using LombScargle

export LS
"""
LS(t; tol=1, N_total=10000, N_acc=2000,q=1)
Compute a surrogate of the irregular time series with supporting time steps t
based on the simulated annealing method described in

[^SchmitzSchreiber1999] A.Schmitz T.Schreiber (1999). "Testing for nonlinearity in unevenly sampled time series" [Phys. Rev E](https://journals.aps.org/pre/pdf/10.1103/PhysRevE.59.4044)
"""
struct LS{T<:AbstractVector,S<:Real} <: Surrogate
    t::T
    tol::S
    N_total::Int
    N_acc::Int
    q::Int
end

LS(t;tol=1.0, N_total=10000, N_acc=5000, q=1) = LS(t, tol, N_total, N_acc,q)


function surrogenerator(x, method::LS)
    lsplan = LombScargle.plan(method.t, x, fit_mean=false)
    x_ls = lombscargle(lsplan)
    xpower = x_ls.power
    @show sum(xpower)
    dist=Minkowski(method.q)
    init = (lsplan=lsplan, xpower=xpower, n=length(x), dist=dist)
    return SurrogateGenerator(method, x, init)
end


function (sg::SurrogateGenerator{<:LS})()
    lsplan, xpower, n, dist = sg.init
    t = sg.method.t
    tol = sg.method.tol
    #@show lsplan, xpower, n
    s = surrogate(sg.x, RandomShuffle())
    #@show sg.x== s
    lsplan = LombScargle.plan(t,s, fit_mean=false)
    s_ls = lombscargle(lsplan)
    #@show sum(xpower)
    #@show xpower== s_ls.power
    #@show xpower
    #@show s_ls.power
    lossold = evaluate(dist,xpower, s_ls.power)
    i = j = 0
    newsurr = zero(s)
    while i < sg.method.N_total && j<sg.method.N_acc
        if mod(i,2000) ==0
            @show i, j,lossold
            #@show sum(xpower), xpower[1:5]
            #@show sum(s_ls.power), s_ls.power[1:5]
        end

        k,l = sample(1:n,2, replace=false)
        #@show k,l
        copy!(newsurr, s)
        #@show length(newsurr)
        #@show newsurr[1]
        newsurr[[k,l]] .= s[[l,k]]
        lsplan = LombScargle.plan(t, newsurr, fit_mean=false)
        s_ls = lombscargle(lsplan)
        lossnew = evaluate(dist,xpower, s_ls.power)
        #@show lossnew, lossold
        if lossnew < lossold
            lossnew <= tol && break
            #@show "update"
            s, lossold = copy(newsurr), lossnew
            #@show length(s)
            j += 1
        #=else
            ## Implement drawing with a probability p
            lossdiff = lossnew - lossold
            @show lossdiff
            T = 1
            p = exp(-lossdiff/log(i)) # Where does T come from?
            if rand() < p
                @show p
                surr, lossold = newsurr, lossnew
                j += 1
            end
        =#
        end
        i+=1
    end
    @info i,j, lossold
    return s
end
