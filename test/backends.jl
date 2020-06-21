using Test
using InteractiveUtils

using AxisArrays
using DimensionalData

test_file = joinpath(dir_testfiles, "era5-levels-members.grib")

BACKENDS = [
    CfGRIB.Backends.AxisArrayWrapper,
    CfGRIB.Backends.DimensionalArrayWrapper,
]

#  Generic tests to see if required methods exist, and that they can at least be
#  called without errors
@testset "method checks for $backend backend" for backend in BACKENDS
    #  Ought to provide getindex, getproperty, haskey, and keys
    backend_method_names = [m.name for m in methodswith(backend)]
    #  Ought to provide convert as that dispatches on Type{backend}
    append!(backend_method_names, [m.name for m in methodswith(Type{backend})])

    expected_methods = [
        :getindex,
        :getproperty,
        :haskey,
        :keys,
        :convert,
    ]

    @testset "expected $expected method" for expected in expected_methods
        @test expected in backend_method_names
    end

    ds = DataSet(test_file)
    da = convert(backend, ds)

    expected_keys = Set((:z, :t))
    @test Set(keys(da)) == expected_keys

    @testset "test access for $key" for key in expected_keys
        @test getproperty(da, key)[1] isa Number
        @test getproperty(da, key) == da[key]
        @test haskey(da, key)
    end
end

#  Backend specific tests are placed into their own files if required
include("./backends/dimensionaldata.jl")
include("./backends/axisarrays.jl")