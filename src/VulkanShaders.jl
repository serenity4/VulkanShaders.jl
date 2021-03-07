module VulkanShaders

using Vulkan
using SPIRV
using MLStyle
using Parameters

import glslang_jll
import Vulkan: ShaderModule, DescriptorSetLayout, PipelineShaderStageCreateInfo
import SPIRV: IR

const glslangValidator = glslang_jll.glslangValidator(x -> x)

include("formats.jl")
include("bindings.jl")
include("compilation.jl")
include("reflection.jl")
include("shaders.jl")

export
        # formats
        ShaderFormat,
        BinaryFormat, TextFormat,
        FormatGLSL, FormatHLSL, FormatSPIRV,
        ShaderFile,
        bytes,

        # shaders
        Shader,
        compile,
        reflect,
        descriptor_sets,
        bindings,
        descriptor_set_layouts

end
