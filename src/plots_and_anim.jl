
for surrogate_type in surrogate_methods
    surrtype = Symbol("$(surrogate_type)")

    ############################
    # User provided time series
    ############################
    fname1 = Symbol("$(surrtype)_plot")
    @eval begin
        """
                `$($surrtype)_plot(ts)`

            Visualize a `$($surrtype)` surrogate.
        """
        function $(fname1)(ts)
            surrplot(ts, $(surrtype)(ts))
        end
    end

    fname2 = Symbol("$(surrtype)_anim")
    @eval begin
        """
                `$($surrtype)_anim(ts; [n_iters::Int])`

            Create `n_iters` `$($surrtype)` surrogates for `ts` and animate them. Returns a `Plots.Animation` instance.
        """
        function $(fname2)(ts; n_iters = 15)
            anim = Plots.@animate for i = 1:n_iters
                surrplot(ts, $(surrtype)(ts))
            end
        end
    end


    fname2b = Symbol("$(surrtype)_gif")
    @eval begin
        """
                `$($surrtype)_gif(ts; [n_iters::Int])`

            Create `n_iters` `$($surrtype)` surrogates for `ts`, animate them and create
            a gif from the animation.
        """
        function $(fname2b)(ts; fps = 2, n_iters = 15)
            anim = Plots.@animate for i = 1:n_iters
                surrplot(ts, $(surrtype)(ts))
            end
            gif(anim, fps = fps)
        end
    end

    eval(Expr(:export, fname1))
    eval(Expr(:export, fname2))
    eval(Expr(:export, fname2b))

    ################################
    # Synthetic time series examples
    ################################


    for process in processes
        proc = Symbol("$(process)")

        # Surrogate panel plots for combinations of processes and surrogate types
        fname3 = Symbol("$(surrtype)_$(process)_plot")
        @eval begin
            """
                    `$($fname3)(; [fps, n_iters, n_steps, new_realization_every_iter::Bool])`

                Create a `$($surrtype)` surrogate for a realization of a `$($proc)` process and visualize it.
            """
            function $(fname3)(;n_iters = 15,
                                n_steps = 500,
                                new_realization_every_iter::Bool = false)
                # generate time series
                ts = $(proc)(n_steps = n_steps)
                surrplot(ts, $(surrtype)(ts))
            end
        end


        # Animate surrogate generation for different surrogate types and processes
        fname4 = Symbol("$(surrtype)_$(process)_anim")
        @eval begin
            """
                    `$($fname4)(; [fps, n_iters, n_steps, new_realization_every_iter::Bool])`

                Create `n_iters` `$($surrtype)` surrogates for realizations of a `$($proc)` process and animate them. Returns a `Plots.Animation` instance.

                If `new_realization_every_iter = true`, then a fresh `$($proc)` realization is used at each iteration. Otherwise, the same time series, generating only the surrogates anew at each iteration.
            """
            function $(fname4)(;n_iters = 15,
                                n_steps = 500,
                                new_realization_every_iter::Bool = false)
                # generate time series
                ts = $(proc)(n_steps = n_steps)

                # animate
                anim = Plots.@animate for i = 1:n_iters
                    if new_realization_every_iter
                        ts = $(proc)(n_steps = n_steps)
                        surrplot(ts, $(surrtype)(ts))
                    else
                        surrplot(ts, $(surrtype)(ts))
                    end
                end
            end
        end

        # Animate surrogate generation for different surrogate types and processes
        fname4b = Symbol("$(surrtype)_$(process)_gif")
        @eval begin
            """
                    `$($fname4b)(; [fps, n_iters, n_steps, new_realization_every_iter::Bool])`

                Create `n_iters` `$($surrtype)` surrogates for realizations of a `$($proc)`
                process, animate them and create a gif from the animation.

                If `new_realization_every_iter = true`, then a fresh `$($proc)` realization is used at each iteration. Otherwise, the same time series, generating only the surrogates anew at each iteration.
            """
            function $(fname4b)(;fps = 2, n_iters = 15,
                                n_steps = 500,
                                new_realization_every_iter::Bool = false)
                # generate time series
                ts = $(proc)(n_steps = n_steps)

                # animate
                anim = Plots.@animate for i = 1:n_iters
                    if new_realization_every_iter
                        ts = $(proc)(n_steps = n_steps)
                        surrplot(ts, $(surrtype)(ts))
                    else
                        surrplot(ts, $(surrtype)(ts))
                    end
                end

                gif(anim, fps = fps)
            end
        end

        eval(Expr(:export, fname3))
        eval(Expr(:export, fname4))
        eval(Expr(:export, fname4b))
    end
end
