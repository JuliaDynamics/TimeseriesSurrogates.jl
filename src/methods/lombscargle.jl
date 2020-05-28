using LombScargle

export LS
"""

Compute a surrogate of the irregular time series x with supporting time steps t
based on the simulated annealing method described in

Testing for nonlinearity in unevenly sampled time seriesAndreas Schmitz and Thomas Schreiber
"""
struct LS <: Surrogate end

function loss(ls1, signal2,taxis;q=1)
    #lsplan1 = LombScargle.plan(taxis, signal1)
    lsplan2 = LombScargle.plan(taxis, signal2)
    #ls1 = lombscargle(lsplan1)
    ls2 = lombscargle(lsplan2)
    #@show ls1.power .- ls2.power
    return minkowski(ls1.power, ls2.power,q)
end



function surrogate(signal,taxis,sg::LS; N_total=10000, N_acc=2000, tol=1)
    n = length(signal)
    surr = surrogate(signal, RandomShuffle())
    lsorg = lombscargle(taxis, signal)
    lossold = loss(lsorg,surr, taxis)
    i = j = 1
    while i < N_total && j<N_acc
        if mod(i,500) ==0
            @show i, j,lossold
        end
        k,l = sample(1:n,2, replace=false)
        #@show k,l
        newsurr = copy(surr)
        newsurr[[k,l]] = surr[[l,k]]
        lossnew = loss(lsorg, newsurr, taxis)
        if lossnew < lossold
            lossnew <= tol && break
            #@show "update"
            surr, lossold = newsurr, lossnew
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
    return surr
end
