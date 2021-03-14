module VulkanShaders

using Vulkan
using SPIRV
using MLStyle
using Parameters
using DataStructures

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

        # descriptors
        DescriptorBinding,
        get_descriptor_sets,
        get_bindings,
        create_descriptor_set_layouts

end
