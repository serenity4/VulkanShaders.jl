@with_kw struct Shader
    mod::ShaderModule
    stage::ShaderStageFlag
    bindings::AbstractVector{<:DescriptorBinding} = ResourceBinding[]
    entry_point::Symbol = :main
end

Shader(device, shader::ShaderFile, bindings; entry_point=:main) = Shader(mod=ShaderModule(device, shader), stage=shader.stage; bindings, entry_point)

has_bindings(shader::Shader) = !isempty(shader.bindings)

PipelineShaderStageCreateInfo(shader::Shader) = PipelineShaderStageCreateInfo(shader.stage, shader.mod, string(shader.entry_point))

function descriptor_set_layouts(device, shaders::AbstractVector{Shader})
    sets = DefaultOrderedDict(() -> DescriptorSetLayoutBinding[])
    for shader ∈ shaders
        for resource_binding ∈ shader.bindings
            push!(sets[resource_binding.set], DescriptorSetLayoutBinding(resource_binding.binding, resource_binding.resource, shader.stage))
        end
    end
    @assert all(keys(sets) .== 0:(length(sets)-1)) "Invalid layout description (non-contiguous sets from 0) in $sets."
    DescriptorSetLayout.(device, DescriptorSetLayoutCreateInfo.(values(sets)))
end
