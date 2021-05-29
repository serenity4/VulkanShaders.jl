using Vulkan
using VulkanShaders
using Test

resource(filename) = joinpath(@__DIR__, "resources", filename)

eq(x::AbstractArray, y::AbstractArray) = length(x) == length(y) && all(x .== y)

function test_shader(basename, stage, _descriptor_sets, _bindings)
    shader = ShaderFile(resource("$stage.spv"), FormatSPIRV(), SHADER_STAGE_VERTEX_BIT)
    shader_glsl = ShaderFile(resource("$basename.$stage"), FormatGLSL())
    @test all(bytes(shader) .== bytes(compile(shader_glsl)))
    @test shader isa ShaderFile{FormatSPIRV}
    rshader = reflect(shader)
    @test_broken all(eq(descriptor_sets(rshader), _descriptor_sets))
    @test_broken all(eq(bindings(rshader), _bindings))
end

@testset "VulkanShaders.jl" begin
    test_shader("triangle", "vert", [0], [0])
    test_shader("triangle", "frag", [], [])
end
