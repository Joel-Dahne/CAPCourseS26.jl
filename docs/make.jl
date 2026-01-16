using Documenter, CAPCourseS26

format = if length(ARGS) > 0
    Documenter.LaTeX()
else
    Documenter.HTML()
end

makedocs(
    sitename = "CAPCourseS26.jl",
    modules = [CAPCourseS26],
    pages = [
        "Overview" => "index.md",
        "Weeks" => [
            "Part 1: Introduction to computer-assisted proofs" => [
                "week-1-lecture-1.md",
                "week-1-lab.md",
                "week-2-lecture-1.md",
                "week-2-lecture-2.md",
                "week-2-lab.md",
                "week-3-lecture-1.md",
                "week-3-lecture-2.md",
                "week-3-lab.md",
                "week-4-lecture-1.md",
                "week-4-lecture-2.md",
                "week-4-lab.md",
            ],
            "Part 2: Introduction to rigorous numerics" => [
                "week-5-lecture-1.md",
                "week-5-lecture-2.md",
                "week-5-lab.md",
                "week-6-lecture-1.md",
                "week-6-lecture-2.md",
                "week-6-lab.md",
                "week-7-lecture-1.md",
                "week-7-lecture-2.md",
                "week-7-lab.md",
                "week-8-lecture-1.md",
                "week-8-lecture-2.md",
                "week-8-lab.md",
                "week-9-lecture-1.md",
                "week-9-lecture-2.md",
                "week-9-lab.md",
                "week-10-lecture-1.md",
                "week-10-lecture-2.md",
                "week-10-lab.md",
            ],
            "Part 3: Computer-assisted proofs in practice" => [
                "week-11-lecture-1.md",
                "week-11-lecture-2.md",
                "week-11-lab.md",
                "week-12-lecture-1.md",
                "week-12-lecture-2.md",
                "week-12-lab.md",
                "week-13-lecture-1.md",
                "week-13-lecture-2.md",
                "week-13-lab.md",
                "week-14-lecture-1.md",
                "week-14-lecture-2.md",
                "week-14-lab.md",
                "week-15-lecture-1.md",
                "week-15-lecture-2.md",
                "week-15-lab.md",
            ],
        ],
    ],
    warnonly = [:missing_docs];
    format,
)

deploydocs(repo = "github.com/Joel-Dahne/CAPCourseS26.jl")
