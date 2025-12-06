using Documenter, CAPCourseS26

makedocs(
    sitename = "CAPCourseS26.jl",
    modules = [CAPCourseS26],
    pages = [
        "Overview" => "index.md",
        "Weeks" => [
            "Part 1: Introduction to computer-assisted proofs" =>
                ["week-1.md", "week-2.md", "week-3.md", "week-4.md"],
            "Part 2: Introduction to rigorous numerics" => [
                "week-5.md",
                "week-6.md",
                "week-7.md",
                "week-8.md",
                "week-9.md",
                "week-10.md",
            ],
            "Part 3: Computer-assisted proofs in practice" =>
                ["week-11.md", "week-12.md", "week-13.md", "week-14.md", "week-15.md"],
        ],
    ],
    warnonly = [:missing_docs],
)

deploydocs(repo = "github.com/Joel-Dahne/CAPCourseS26.jl")
