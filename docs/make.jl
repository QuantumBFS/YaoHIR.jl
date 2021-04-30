using YaoHIR
using Documenter

DocMeta.setdocmeta!(YaoHIR, :DocTestSetup, :(using YaoHIR); recursive=true)

makedocs(;
    modules=[YaoHIR],
    authors="Roger-Luo <rogerluo.rl18@gmail.com> and contributors",
    repo="https://github.com/QuantumBFS/YaoHIR.jl/blob/{commit}{path}#{line}",
    sitename="YaoHIR.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://QuantumBFS.github.io/YaoHIR.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/QuantumBFS/YaoHIR.jl",
)
