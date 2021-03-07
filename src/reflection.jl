struct ReflectedShader
    ir::IR
end

reflect(shader::ShaderFile{FormatSPIRV}) = ReflectedShader(generate_ir(SPIRModule(shader.file)))

descriptor_sets(shader::ReflectedShader) = vcat(SPIRV.descriptor_sets.(last.(shader.ir.variables))...)
bindings(shader::ReflectedShader) = vcat(SPIRV.bindings.(last.(shader.ir.variables))...)
