# Week 1 Lab: Setup
The main goal of this lab is to:
- Install Julia
- Start the Julia REPL and run basic commands
- Download the course package
  - Run a Pluto notebook
  - Bonus: Build this documentation
- Install an editor for working with Julia files
- Bonus: Reproduce a computer-assisted proof

## Install Julia
The Julia website has a [page about install
Julia](https://julialang.org/downloads/). The recommended way to do
this is to use [`juliaup`](https://github.com/JuliaLang/juliaup).
Exactly how to install `juliaup` depends on your operating system. On
Linux and Mac it should be enough to run

``` shell
curl -fsSL https://install.julialang.org | sh
```

On Windows you can install it through the [Windows
store](https://apps.microsoft.com/detail/9njnww8pvkmn?hl=en-US&gl=US).
Alternatively you can use
[WSL](https://learn.microsoft.com/en-us/windows/wsl/install) and
install Julia inside the WSL environment.

## Julia REPL
The most common way to use Julia is through the interactive
command-line REPL (real-eval-print-loop). See the [Julia REPL
documentation](https://docs.julialang.org/en/v1/stdlib/REPL/) for much
more details than we'll cover here.

If you start Julia (by running `julia` from a terminal) you will be
greeted with a prompt where you can run Julia commands. You can for
example try running the following commands

``` @repl
1 + 1
sin(2)
f(x) = x - exp(x)
f(0.1)
f(-1)
M = [1 2; 3 4]
inv(M)
b = [5, 6]
a = M \ b
M * a
```

### REPL modes

When you start the Julia REPL you enter what is called the "Julian
mode", where you can run Julia code and see the results. The REPL also
has 3 other modes which are used in certain cases:
1. Help mode: You enter this mode by writing `?` when at an empty line
   in the Julian mode. You can then write the name of a function to
   get the documentation for that function. Try writing for example
   `?sin` and `?Int`.
2. Pkg mode: You can enter this mode by writing `]`. It is used for
   installing and interacting with packages, which we will do soon.
   Note that you can exit the mode by typing backspace.
3. Shell mode: You can enter this mode by writing `;`. It us used for
   running simple terminal commands directly from Julia. We won't make
   much use of it directly, but it is occasionally useful.

## Download course package
This documentation is structured as a Julia package, with the name
`CAPCourseS26.jl`. It is available in a [Github
repository](https://github.com/Joel-Dahne/CAPCourseS26.jl). Most of
the code we will work on in the course will be contained in this
package. To use the package we first have to download it.

To download the package we want to use
[git](https://en.wikipedia.org/wiki/Git), the version control tool
that Github derives it names from.
- If you are running Linux you probably already have git installed, on
  Debian based systems (e.g. Ubuntu) you can otherwise install it with
  `sudo apt install git`.
- On Mac you should be able to install it by just running `git` in the
  terminal and follow the prompts. You can also install it in other
  ways, see [Mac install
  instructions](https://git-scm.com/install/mac).
- On Windows you can use the git installer linked from the [Windows
  install instructions](https://git-scm.com/install/windows).

Once you have git installed you should be able to download the
repository. To do so navigate to the directory where you want to put
the repository and run

``` shell
git clone https://github.com/Joel-Dahne/CAPCourseS26.jl.git
```

This should create a directory with the name `CAPCourseS26.jl`. If you
navigate into `CAPCourseS26.jl` and start Julia you should then be
able to use the following code to run the tests in the package.

``` julia
using Pkg
Pkg.activate(".") # Activate the package CAPCourseS26
Pkg.instantiate() # Install all dependencies of CAPCourseS26
Pkg.test() # Run the tests for CAPCourseS26
```

If everything is working as it should this should, after some time,
end with something of the form.

```
     Testing Running tests...
Test Summary: | Pass  Total  Time
CAPCourses26  |    1      1  0.0s
     Testing CAPCourseS26 tests passed

```

### Pluto notebook
In addition to the Julia REPL we will make use of [Pluto
notebooks](https://plutojl.org/) as a tool for writing, running and
interacting with Julia code. Another common notebook tool which some
of you might have encountered is [Jupyter](https://jupyter.org/).
Jupyter also works with Julia (that is the Ju in Jupyter), but for
this course we will mainly make use of Pluto, which is Julia only.

To start Pluto navigate to the `notebooks` directory of this
repository and start Julia. You can activate the directory project
and start Pluto with

``` julia
using Pkg
Pkg.activate(".")
using Pluto
Pluto.run()
```

This should print a link which you can open in your browser. From the
browser you should then start the `lab-1.jl` notebook and follow the
directions in it.

### Bonus: Build this documentation
You can build the documentation that you are currently reading by
running the following code from the root of this directory.

``` shell
julia --project=docs docs/make.jl
```

This will build an HTML version of the package. To be able to read
this in a convenient way requires some more tools. If you have Python
installed you should be able to do so with

``` shell
cd docs/build
python3 -m http.server --bind localhost
```

and open http://127.0.0.1:8000/ in your browser. Alternatively you can
build a pdf version of the documentation with

``` shell
julia --project=docs docs/make.jl latex
```

and open the PDF-file `docs/build/CAPCourseS26.jl.pdf`.

## Install an editor
While it is possible to write Julia code in any text editor, one
usually uses an editor which has tools for working with Julia code.

If you don't know which editor to use you should probably use [VS
Code](https://code.visualstudio.com/). Follow the instructions on
their website to install it.

Personally, I use [Emacs](https://www.gnu.org/software/emacs/) as my
editor. Unless you have previous experience with Emacs I would however
not recommend starting with this. If you do want to use Emacs, these
are the most relevant parts of my configuration. Feel free to ask for
more details in case you are interested.

``` emacs-lisp
(use-package julia-mode
  :ensure julia-mode
  :bind ("C-c f" . jd/julia-format)
  :config (setq julia-max-block-lookback 50000))

(use-package julia-ts-mode
  :ensure t
  :mode ("\\.jl" . julia-ts-mode)
  :hook (julia-ts-mode . auto-revert-mode))

(defun jd/processor-count ()
  "Get the number of processors using nproc. If nproc is not found it returns 1"
  (if (executable-find "nproc")
      (with-temp-buffer
        (call-process (executable-find "nproc") nil t nil)
        (string-to-number (buffer-string)))
    1))

(defun jd/julia-repl-activate-cd-parent ()
  "Run julia-repl-activate-parent and also cd to the directory of the project file."
  (interactive)
  (progn
    (julia-repl-activate-parent nil)
    (if-let ((projectfile (julia-repl--find-projectfile)))
        (progn
          (message "cd-ing to %s" projectfile)
          (julia-repl--send-string
           (concat "cd(\""
                   (expand-file-name (file-name-directory projectfile)) "\")")))
      (message "could not find project file"))))

(use-package vterm
    :ensure t
    :config (progn (setq vterm-kill-buffer-on-exit nil)))

(use-package julia-repl
  :ensure t
  :hook julia-mode
  :config
  (julia-repl-set-terminal-backend 'vterm)
  (setenv "JULIA_NUM_THREADS" (number-to-string (/ (jd/processor-count) 2)))
  (define-key julia-repl-mode-map (kbd "C-c C-a") 'jd/julia-repl-activate-cd-parent))
```

For most people the editor is likely the place where they most of the
time interact with Julia. It is therefore a good idea to get
accustomed to the editor and the tools it offers. When showing Julia
code throughout the course I'll try to switch between using VS Code
and Emacs, to give you a feeling for how things differ between
editors.

We will take a closer look at how to use the editor for working with
Julia code next week.

## Bonus: Reproduce a computer-assisted proof
If you feel inclined you can try to use the things you have learned
above to reproduce a computer-assisted proof from a very recent paper.
At the time of writing the paper has been submitted to Arxiv, but is
still waiting to appear. At this point we have of course not learned
enough to actually understand the proof, but you can nevertheless run
the code.

In the [Github
repository](https://github.com/Joel-Dahne/SpectralRegularPolygon.jl)
for the paper is all the code used for the computer-assisted proof.
The proofs are presented in Pluto notebooks and our goal will be to
run one of these notebooks. To do this we need to:

1. Clone the repository
2. Start Julia from the repository
3. Install dependencies and start the Pluto notebook

To clone the repository you can navigate to the directory where you
want to place it and run

``` shell
git clone https://github.com/Joel-Dahne/SpectralRegularPolygon.jl.git
```

Next step is to start Julia from the `SpectralRegularPolygon.jl`
directory. Here we need to make one adjustment from before however. At
the time of writing the latest Julia version is 1.12.4 and this is the
one that was automatically installed when you installed `juliaup`
earlier. The computer-assisted proof was however done using Julia
1.11.8, so we need to run that version. You can install the version
with

``` shell
juliaup add 1.11.8
```

and to start the correct Julia version you then run

``` shell
julia +1.11.8
```

Note the extra `+1.11.8`! After you have started the right Julia
version you should be able to follow the instructions in the README of
the repository. Which is to first run

``` julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
Pkg.test()
```

to install the dependencies and run the package tests. This will
likely take some time! Next you want to start Pluto with

``` julia
using Pluto
Pluto.run()
```

This should open Pluto in your browser. From your browser window you
can then open the notebooks inside the `proofs` directory. There is
quite a few of them and some of them take some time to run. I would
recommend you open the one named `proposition_3_1.jl`, which has the
nicest plots!

!!! note
    The instructions here are slightly different from the earlier ones
    about how to start Pluto. In the earlier instructions you should
    navigate to the `notebooks` subdirectory and run
    `Pkg.activate(".")` from there. In these instructions you should
    run `Pkg.activate(".")` from the root of the directory. The reason
    for this difference is that Julia 1.12 introduced some features
    that simplifies some parts of project managements. Since we are
    here using Julia 1.11.8 these tools are not in place and the
    approach is slightly different.

If you have managed to get this far and run the above mentioned
notebook, then congratulations! You have just reproduced a
computer-assisted proof!
