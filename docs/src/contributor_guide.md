# Contributing 

## Reporting issues

If you are having issues with the code, find bugs or otherwise want to report something about the package,
please submit an issue at our [GitHub repository](https://github.com/JuliaDynamics/TimeseriesSurrogates.jl/issues). 

## Feature requests

If you have requests for a new method but can't implement it yourself, you can also report it an an [issue](https://github.com/JuliaDynamics/TimeseriesSurrogates.jl/issues). The package developers or other volunteers might be able to help with the implementation. 

Please mark method requests clearly as "Method request: my new method...", and provide a reference to a scientific publication that outlines the algorithm. 

## Pull requests

Pull requests for new surrogate methods are very welcome. Ideally, your implementation should use the same API as the existing methods: 

- Create a `struct` for your surrogate method, e.g. `struct MyNewSurrogateMethod <: Surrogate`, that contain the parameters for the method. The docstring for the method should contain a reference to scientific publications detailing the algorithm,
as well as the intended purpose of the method, and potential implementation details that differ from the original algorithm. 
- Implement `surrogenerator(x, method::MyNewSurrogateMethod)`, where you pre-compute things for efficiency and return a `SurrogateGenerator` instance.
- Implement the `SurrogateGenerator{<:MyNewSurrogateMethod}` functor that produces surrogate time series on demand. This is where the precomputed things are used, and the actual algorithm is implemented.
- Then `surrogate(x, method::Surrogate)` will "just work". 

If you find this approach difficult and already have a basic implementation of a new surrogate method, the package maintainers may be able to help structuring the code. Let us know in an [issue](https://github.com/JuliaDynamics/TimeseriesSurrogates.jl/issues) or in a pull request!
