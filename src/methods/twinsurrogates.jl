using Distances
using TimeseriesSurrogates
using Plots
using GroupSlices

"""
    twin(points)

Create twin surrogates according to the procedure by Thiel et al. [1]. The twin surrogates
works for any embedding of univariate series and multivariate time series.

The embedding must be provided as an array of size dim-by-n_points.

# Literature references

1. Thiel et al. *Europhys. Lett.*, 75 (4), pp.535-541 (2006). DOI: 10.1209/epl/i2006-10147-0
"""
function twin(embedding, δ)
    # Necessary pairwise distances for construction of the recurrence matrix
    n = size(embedding, 2) # number of points in the embedding
    pairwise_distances = Distances.pairwise(Distances.Euclidean(), embedding)

    # Construct recurrence matrix. All pairs of points for which d(xᵢ, xⱼ) < δ are
    # considered neighbours.
    RM = δ - pairwise_distances
    RM[RM .>= 0] = 1.0
    RM[RM .< 0] = 0.0
    println(count(RM .== 1)/length(RM)*100, "% 1's in the recurrence matrix")


    # Indentify which group of (possible) multiples of twins each point belongs to
    groupindices = groupslices(RM, 1)

    # First occurences
    firstindices = firstinds(groupindices)

    # Identify indices of twin groups (get M sets of row indices for the M set of twins)
    twinindices = groupinds(groupindices)

    M = length(twinindices)
    # Generate surrogate trajectory.
    surrogate_trajectory = similar(embedding)

    n_possible = length(firstindices)
    coming_from = rand(1:n_possible) # index of point we're coming from. arbitrary first choice.
    surrogate_trajectory[:, 1] = embedding[:, coming_from]

    jumping_to = rand(setdiff(1:length(firstindices), coming_from))

    n_placed = 1
    for j = 2:n
        if !(n_placed >= n)
            # Jump to any group of twins but the one we're coming from


            # Find potential twins for this destination point. If the point has no twins,
            # set the jth point in the surrogate trajectory to p[jumping_to] and the (j+1)th
            # point to p[jumping_to+1]. Otherwise, if the destination point has a twin,
            # jump to any of its twins (with equal probabilities).
            twins = twinindices[jumping_to]
            if length(twins) == 1
                nextpoint = twins[1]
                surrogate_trajectory[:, n_placed + 1] = embedding[:, j]
                n_placed += 1
                if n_placed < n
                    surrogate_trajectory[:, n_placed + 1] = embedding[:, nextpoint]
                    n_placed += 1
                    coming_from = nextpoint
                end

                jumping_to = rand(setdiff(1:length(firstindices), coming_from))

            else
                surrogate_trajectory[:, n_placed + 1] = embedding[:, firstindices[jumping_to]]
                n_placed += 1
                if n_placed < n
                    target_twin = rand(twins)
                    surrogate_trajectory[:, n_placed + 1] = embedding[:, target_twin]
                    n_placed += 1
                    coming_from = target_twin
                end
                jumping_to = rand(setdiff(1:length(firstindices), coming_from))
            end
        end
        j += 1
    end
    RM, surrogate_trajectory
end
#
# using TimeseriesSurrogates, Plots, StatsBase
# n = 1000
# embedding = [NSAR2(n_steps = n) rand(n) AR1(n_steps = n)].'
# surrplot(embedding[1, :], twin(embedding, 2)[1, :])
# surrplot(embedding[1, :], iaaft(embedding[1, :]))
