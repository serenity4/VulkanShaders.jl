struct ReflectedShader
    ir::IR
end

reflect(shader::ShaderFile{FormatSPIRV}) = ReflectedShader(generate_ir(SPIRModule(shader.file)))

get_descriptor_sets(shader::ReflectedShader) = vcat(SPIRV.descriptor_sets.(last.(shader.ir.variables))...)
get_bindings(shader::ReflectedShader) = vcat(SPIRV.bindings.(last.(shader.ir.variables))...)
