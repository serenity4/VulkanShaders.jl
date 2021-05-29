struct ReflectedShader
    ir::IR
end

reflect(shader::ShaderFile{FormatSPIRV}) = ReflectedShader(IR(SPIRV.Module(shader.file)))
