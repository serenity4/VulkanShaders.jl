module VulkanShaders

using Vulkan
using MLStyle

import glslang_jll
import Vulkan: ShaderModule, DescriptorSetLayout

const glslangValidator = glslang_jll.glslangValidator(x -> x)

include("formats.jl")
include("resources.jl")
include("conversions.jl")
include("compilation.jl")

@with_kw struct Shader
    mod::ShaderModule
    stage::ShaderStage
    resources::AbstractVector{<:ResourceBinding} = ResourceBinding[]
    entry_point::Symbol = :main
end

Shader(device, shader::ShaderFile, resources; entry_point=:main) = Shader(mod=ShaderModule(device, shader), stage=shader.stage; resources, entry_point)

has_resources(shader::Shader) = !isempty(shader.resources)

set(shader::Shader) = vcat(set.(shader.resources)...)
binding(shader::Shader) = vcat(binding.(shader.resources)...)

PipelineShaderStageCreateInfo(shader::Shader) = PipelineShaderStageCreateInfo(shader.stage, shader.mod, string(shader.entry_point))

function descriptor_set_layouts(device, shaders::AbstractVector{Shader})
    sets = DefaultOrderedDict(() -> DescriptorSetLayoutBinding[])
    for shader ∈ shaders
        for resource_binding ∈ shader.resources
            push!(sets[resource_binding.set], DescriptorSetLayoutBinding(resource_binding.binding, resource_binding.resource, shader.stage))
        end
    end
    @assert all(keys(sets) .== 0:(length(sets)-1)) "Invalid layout description (non-contiguous sets from 0) in $sets."
    DescriptorSetLayout.(device, DescriptorSetLayoutCreateInfo.(values(sets)))
end

end
