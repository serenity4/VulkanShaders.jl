struct ShaderCompilationError <: Exception
    msg
end

Base.showerror(io::IO, err::ShaderCompilationError) = print(io, "ShaderCompilationError:\n\n$(err.msg)")

function ShaderModule(device, shader::ShaderFile{FormatSPIRV})
    filesize = stat(shader.file).size
    code = Vector{UInt8}(undef, cld(filesize, 4))
    open(shader.file) do io
        readbytes!(io, code, filesize)
    end
    ShaderModule(device, filesize, reinterpret(UInt32, code))
end

ShaderModule(device, shader::ShaderFile{<:TextFormat}) = ShaderModule(device, compile(shader))

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

compile(shader::ShaderFile{FormatHLSL})::ShaderFile{FormatSPIRV} = compile(convert(ShaderFile{FormatGLSL}, shader), extra_flags=["-D"])
