using Documenter, CAPCourseS26

makedocs(
    sitename = "CAPCourseS26.jl",
    modules = [CAPCourseS26],
    pages = [
        "index.md",
    ],
    warnonly = [:missing_docs],
)

deploydocs(repo = "github.com/Joel-Dahne/CAPCourseS26.jl")
