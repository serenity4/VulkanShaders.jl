struct ShaderCompilationError <: Exception
    msg
end

Base.showerror(io::IO, err::ShaderCompilationError) = print(io, "ShaderCompilationError:\n\n$(err.msg)")

# WARNING: this is type piracy.
function ShaderModule(device::Device, code::Vector{UInt8})
    size = cld(length(code), 4)
    ShaderModule(device, size, reinterpret(UInt32, resize!(copy(code), size * 4)))
end

spirv_code(shader::ShaderFile{<:FormatSPIRV}) = read(shader.file)
spirv_code(shader::ShaderFile) = spirv_code(compile(shader))

"""
    compile(shader)

Compile a shader file in text format to SPIR-V.
"""
function compile(shader::ShaderFile{FormatGLSL}; extra_flags=[], validate_spirv=true)::ShaderFile{FormatSPIRV}
    if !isfile(shader.file)
        throw(ArgumentError("File $(shader.file) does not exist"))
    end

    flags = ["-V"]
    validate_spirv && "--SPIRV-val" ∉ extra_flags ? push!(flags, "--SPIRV-val") : nothing
    dst = tempname()
    err = IOBuffer()
    try
        run(pipeline(`$glslangValidator $flags -o $dst $(shader.file)`, stdout=err))
    catch e
        e isa ProcessFailedException
        err_str = String(take!(err))
        throw(ShaderCompilationError(err_str))
    end
    ShaderFile(dst, FormatSPIRV(), shader.stage)
end

compile(shader::ShaderFile{FormatHLSL}) = compile(convert(ShaderFile{FormatGLSL}, shader), extra_flags=["-D"])
