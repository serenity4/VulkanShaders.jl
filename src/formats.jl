"""
Format to which the shader conforms. It can be a text format (with a language such as FormatGLSL or FormatHLSL),
or a binary format (such as SPIR-V).
"""
abstract type ShaderFormat end

Base.broadcastable(x::ShaderFormat) = Ref(x)

"""
Human-readable shader format, usually written in a shading language
such as FormatGLSL or FormatHLSL.
"""
abstract type TextFormat <: ShaderFormat end

"""
Efficient format that requires disassembly by a specialized program to be human-readable.
"""
abstract type BinaryFormat <: ShaderFormat end

"""
OpenGL Shading Language format.
"""
struct FormatGLSL <: TextFormat end

"""
High Level Shading Language format, used by DirectX.
"""
struct FormatHLSL <: TextFormat end

"""
Standard Portable Intermediate Representation format, from The Khronos Group.
"""
struct FormatSPIRV <: BinaryFormat end

"""
    ShaderFile(file, format)
    ShaderFile(file, stage)

Shader resource as a file.
If one of the format or stage is not provided but the other is, then the former
will be retrieved from the file extension, if possible, or an error will be thrown.

## Examples

```julia
julia> ShaderFile("my_shader.geom", FormatGLSL())
ShaderFile{FormatGLSL}

julia> ShaderFile("my_shader.FormatGLSL", GeometryStage())
ShaderFile{FormatGLSL}
```
"""
struct ShaderFile{F<:ShaderFormat}
    file::String
    format::F
    stage::ShaderStageFlag
end

ShaderFile(file, format::TextFormat) = ShaderFile(file, format, shader_stage(file, format))
ShaderFile(file, stage::ShaderStageFlag) = ShaderFile(file, shader_format(file), stage)

bytes(shader::ShaderFile) = open(io -> readavailable(io), shader.file)

Base.convert(::Type{ShaderFile{F1}}, shader::ShaderFile{F2}) where {F1<:TextFormat, F2<:TextFormat} = ShaderFile(shader.file, F1(), shader.stage)

function file_ext(::Type{<:Union{FormatGLSL,FormatHLSL}}, stage::ShaderStageFlag)
    '.' * @match stage begin
        &SHADER_STAGE_VERTEX_BIT => "vert"
        &SHADER_STAGE_FRAGMENT_BIT => "frag"
        &SHADER_STAGE_TESSELLATION_CONTROL_BIT => "tesc"
        &SHADER_STAGE_TESSELLATION_EVALUATION_BIT => "tese"
        &SHADER_STAGE_GEOMETRY_BIT => "geom"
        _ => error("Unknown stage $stage")
    end
end

"""
    shader_stage(file_ext)

Automatically detect a shader stage from a file extension.
Can only be used with [`FormatGLSL`](@ref) and [`FormatHLSL`](@ref).

## Examples

```julia
julia> shader_stage("my_shader.frag", FormatGLSL()) == SHADER_STAGE_FRAGMENT_BIT
true

julia> shader_stage("my_shader.geom", FormatHLSL()) == SHADER_STAGE_GEOMETRY_BIT
true
```
"""
function shader_stage(file::AbstractString, ::Union{FormatHLSL,FormatGLSL})
    _, file_ext = splitext(file)
    @match file_ext begin
        ".vert" => SHADER_STAGE_VERTEX_BIT
        ".frag" => SHADER_STAGE_FRAGMENT_BIT
        ".tesc" => SHADER_STAGE_TESSELLATION_CONTROL_BIT
        ".tese" => SHADER_STAGE_TESSELLATION_EVALUATION_BIT
        ".geom" => SHADER_STAGE_GEOMETRY_BIT
        _ => error("Unknown file extension $file_ext")
    end
end

"""
    shader_format(file_ext)

Automatically detect a [`ShaderFormat`](@ref) from the file extension.
Currently, only .spv, .FormatGLSL and .FormatHLSL are recognized, mapping to
`FormatSPIRV()`, `FormatGLSL()` and `FormatHLSL()`. 

## Examples

```julia
julia> shader_format("my_shader.FormatGLSL")
FormatGLSL()
julia> shader_format("my_shader.spv")
FormatSPIRV()
```
"""
function shader_format(file::AbstractString)
    _, file_ext = splitext(file)
    @match file_ext begin
        ".spv" => FormatSPIRV()
        ".FormatGLSL" => FormatGLSL()
        ".FormatHLSL" => FormatHLSL()
        _ => error("Unknown file extension $file_ext")
    end
end
