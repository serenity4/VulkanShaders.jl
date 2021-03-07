using VulkanShaders
using Documenter

DocMeta.setdocmeta!(VulkanShaders, :DocTestSetup, :(using VulkanShaders); recursive=true)

makedocs(;
    modules=[VulkanShaders],
    authors="Cédric Belmant",
    repo="https://github.com/serenity4/VulkanShaders.jl/blob/{commit}{path}#{line}",
    sitename="VulkanShaders.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
