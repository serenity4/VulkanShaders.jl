@with_kw struct Shader
    code::String
    stage::ShaderStageFlag
    bindings::Vector{DescriptorBinding} = DescriptorBinding[]
    entry_point::Symbol = :main
end

Shader(shader::ShaderFile, bindings; entry_point=:main) = Shader(code=spirv_code(shader), stage=shader.stage; bindings, entry_point)

has_bindings(shader::Shader) = !isempty(shader.bindings)

PipelineShaderStageCreateInfo(shader::Shader) = PipelineShaderStageCreateInfo(shader.stage, shader.mod, string(shader.entry_point))

function create_descriptor_set_layouts(shaders::AbstractVector{Shader})::Vector{DescriptorSetLayout}
    sets = DefaultOrderedDict{Int,Vector{_DescriptorSetLayoutBinding}}(() -> _DescriptorSetLayoutBinding[])
    for shader ∈ shaders
        for resource_binding ∈ shader.bindings
            push!(sets[resource_binding.set], _DescriptorSetLayoutBinding(resource_binding.binding, resource_binding.descriptor_type, shader.stage; descriptor_count=1))
        end
    end
    if !all(keys(sets) .== 0:(length(sets) - 1))
        error("Invalid layout description (non-contiguous sets from 0) in $sets.")
    end
    layout_bindings_vec = collect(values(sets))
    device = first(shaders).mod.device
    [DescriptorSetLayout(device, bindings) for bindings ∈ layout_bindings_vec]
end
