### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 2308c374-1693-4b91-9143-469d218159cd
# Preliminaries and Pluto-related tools
begin
	using PlutoUI

	function img(path, scale=50)
		LocalResource("./$path", "style"=>"width:$scale%;margin:auto;display:block")
	end
	
	macro DumpAST(ex)
		quote
			Dump(Base.remove_linenums!($(QuoteNode(ex))))
		end
	end
	
	function Sprint(args...; kws...)
		Text(sprint(args...; kws...))
	end

	nothing
end

# ╔═╡ 8c557a45-8e2a-41c2-9bb8-5c98f1b5d468
begin

using ANSIColoredPrinters

function color_print(f)
	io = IOBuffer()
	f(IOContext(io, :color=>true))
	html_str = sprint(io2->show(io2, MIME"text/html"(),
					  HTMLPrinter(io, root_class="documenter-example-output")))
	HTML("$html_str")
end

# Hacky style setup for ANSIColoredPrinters. css taken from ANSIColoredPrinters example.
# Not sure why we need to modify the font size...
HTML("""
<style>
html .content pre {
    font-family: "JuliaMono", "Roboto Mono", "SFMono-Regular", "Menlo", "Consolas",
        "Liberation Mono", "DejaVu Sans Mono", monospace;
}

html pre.documenter-example-output {
    line-height: 125%;
	font-size: 60%
}

html span.sgr1 {
    font-weight: bolder;
}

html span.sgr2 {
    font-weight: lighter;
}

html span.sgr3 {
    font-style: italic;
}

html span.sgr4 {
    text-decoration: underline;
}

html span.sgr7 {
    color: #fff;
    background-color: #222;
}

html.theme--documenter-dark span.sgr7 {
    color: #1f2424;
    background-color: #fff;
}

html span.sgr8,
html span.sgr8 span,
html span span.sgr8 {
    color: transparent;
}

html span.sgr9 {
    text-decoration: line-through;
}


html span.sgr30 {
    color: #111;
}

html span.sgr31 {
    color: #944;
}

html span.sgr32 {
    color: #073;
}

html span.sgr33 {
    color: #870;
}

html span.sgr34 {
    color: #15a;
}

html span.sgr35 {
    color: #94a;
}

html span.sgr36 {
    color: #08a;
}

html span.sgr37 {
    color: #ddd;
}

html span.sgr40 {
    background-color: #111;
}

html span.sgr41 {
    background-color: #944;
}

html span.sgr42 {
    background-color: #073;
}

html span.sgr43 {
    background-color: #870;
}

html span.sgr44 {
    background-color: #15a;
}

html span.sgr45 {
    background-color: #94a;
}

html span.sgr46 {
    background-color: #08a;
}

html span.sgr47 {
    background-color: #ddd;
}

html span.sgr90 {
    color: #888;
}

html span.sgr91 {
    color: #d57;
}

html span.sgr92 {
    color: #2a5;
}

html span.sgr93 {
    color: #d94;
}

html span.sgr94 {
    color: #08d;
}

html span.sgr95 {
    color: #b8d;
}

html span.sgr96 {
    color: #0bc;
}

html span.sgr97 {
    color: #eee;
}


html span.sgr100 {
    background-color: #888;
}

html span.sgr101 {
    background-color: #d57;
}

html span.sgr102 {
    background-color: #2a5;
}

html span.sgr103 {
    background-color: #d94;
}

html span.sgr104 {
    background-color: #08d;
}

html span.sgr105 {
    background-color: #b8d;
}

html span.sgr106 {
    background-color: #0bc;
}

html span.sgr107 {
    background-color: #eee;
}

</style>""")
end

# ╔═╡ 18c4f7f8-6165-49f5-9c03-a1a767a71776
md"""
#### To follow along

<https://github.com/c42f/JuliaBrisbaneMeetup/tree/main/2021-04-21/julia_internals_chris_f>

Start a REPL, go to the directory with the checked out code, and run
```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
using Pluto
Pluto.run()
```

* Poll of proximate languages (python, C++, matlab, R, Fortran, ...)

##### Presentation setup code

(unfold the cells below to see some fun but unsightly hacks for the Pluto.jl presentation 😅)
"""

# ╔═╡ f1429e8b-8ccb-4c3a-bafc-40c26e464093
html"<button onclick='present()'>presentation mode</button>"

# ╔═╡ bf59cd5a-ca53-4ca6-8123-ef0af182dd50
begin
	
# hacks to make code_llvm, code_native, code_warntype work in Pluto.

macro code_warntype_(args...)
	code = macroexpand(@__MODULE__, :(@code_warntype $(args...)))
	@assert code.head == :call
	insert!(code.args, 2, :io)
	esc(quote # non-hygenic :(
		color_print() do io
		    $code
		end
	end)
end
	
macro code_llvm_(args...)
	code = macroexpand(@__MODULE__, :(@code_llvm $(args...)))
	@assert code.head == :call
	insert!(code.args, 2, :io)
	esc(quote # non-hygenic :(
		color_print() do io
		    $code
		end
	end)
end
	
macro code_native_(args...)
	code = macroexpand(@__MODULE__, :(@code_native $(args...)))
	@assert code.head == :call
	insert!(code.args, 2, :io)
	esc(quote # non-hygenic :(
		color_print() do io
		    $code
		end
	end)
end
	
end

# ╔═╡ ba3bb7d4-9a1d-4baf-af7f-42dfd5fb6959
md"""
# Welcome!

#### Brisbane Julia Meetup Group

* Aiming to meet about once a month
    * Informal short talks / demos
    * Workshops / hackathons (?)
* We love hearing about all sorts of applications of Julia.
* Anyone can present a talk or demo! We need volunteers :)

* Thanks to Yoni and UQ SMP for supporting the first meetup
"""

# ╔═╡ f5c3afd0-9fd4-11eb-248a-bbe5fd108765
md"""
# About Me

Chris Foster <https://github.com/c42f>

* I'm a computational physicist turned software engineer
* Formerly did geospatial software @ Fugro Roames, MRI @ Translational Research Institute
* Currently working for Julia Computing on various things, primarily JuliaHub (<https://juliahub.com>) — a site for
  - Exploring the open source package ecosystem
  - Running your Julia code at scale in the cloud
"""

# ╔═╡ 879df7e7-da76-4086-807f-ea2231db7d4d
md"""
# Why Julia? The backstory

* I used various languages for "technical computing" — mostly C++, Python and Matlab
* I wished for a language which was natively numerical like Matlab; interactive & general purpose like Python; fast like C++.
* I saw the [julia-0.1 blog post](https://julialang.org/blog/2012/02/why-we-created-julia/) and started dabbling with version ~0.2 in 2013
    * Adding new number types like intervals is so easy compared to Python
    * Matlab->Julia for an IMU/GPS sensor fusion problem. Got ~100x speedup + neater code(?!)
"""

# ╔═╡ 183ba856-9fd5-11eb-3648-154ad2971a4b
md"""
# Julia Internals — Outline

Julia's compilation stages are moderately standard. We'll take a tour of them.
  - Parsing
  - Lowering
  - Type Inference (ok, many compilers don't do this)
  - High-level Optimization
  - Low-level Code Generation (mature LLVM infrastructure)

Julia is special in helping you *inspect* and *customize* the stages. I'll talk through the tools for this. Understanding the compiler makes your code faster!
"""

# ╔═╡ b3c200c6-9fd6-11eb-0dc1-dd4c1c38f283
md"""
# Parsing

* **Input is text** — a sequence of characters
* **Output is an AST** (abstract syntax tree / parse tree) — a symbolic, hierarchical representation of the program
* Syntax tree is represented using objects of type `Expr`
* Syntax can be manipulated within *any Julia program*, not just "within the compiler".

```julia
struct Expr
	head::Symbol
    args::Vector{Any}
end
```
"""

# ╔═╡ 93b71fcc-4a1f-4130-8b7f-95ab37865c62
md"## Basic parsing examples

Parse code with `Meta.parse()`
"

# ╔═╡ 9736ee46-4c83-4a19-8e82-fb463328acb4
Dump(Meta.parse("x + 2"))

# ╔═╡ 9aeb03de-2130-40c8-87f0-c716531a8f27
md"""
* `Symbol` is a type used for "the name of identifiers in code". Like a string, but each symbol is stored only once ("interned").
* Expressions can be constructed manually with `Expr`.
"""

# ╔═╡ c1b6dad5-56b0-4cc9-9fdf-7d93122b2c20
Expr(Symbol("call"), Symbol("+"), Symbol("x"), 2)

# ╔═╡ 5bb6d2e6-29b7-4f56-b052-e577fbeece7e
md"""
Julia also has expression literals with `quote` and `:` syntax. You'll see these used more commonly, but occasionally `Meta.parse()` can be less confusing, especially with features like `$` interpolation.
"""

# ╔═╡ 21466a22-61d9-49d6-8b9b-b1943338c84f
xplus2 = :(x + 2)

# ╔═╡ 3cad286a-2810-4581-8178-516dae08cda4
xplus2.args

# ╔═╡ da38c4ad-74dd-4fdf-b272-148389a1e9ff
:x

# ╔═╡ d31ade63-8857-4874-a54f-ad5030faa5b0
Base.remove_linenums!(
	quote
		x + 2
		y
	end
)

# ╔═╡ 551bd18b-9621-4f54-8b74-c8eb7575e665
md"""
## Parse tree hierarchy

* Nested expressions produce *trees*. Here's the parse tree for ```sin(π * x)```

$(img("parse_sin_2x.png", 25))
"""

# ╔═╡ dc70d830-9fd6-11eb-31c9-478a4cf57514
Dump(Meta.parse("sin(π*x)"))

# ╔═╡ 0aa1911c-de07-4440-9298-397a3c798aa1
Expr(:call, :sin, Expr(:call, :*, :π, :x))

# ╔═╡ 2022f37f-52a0-4164-9a0a-c2f8c855c7ff
md"## `Expr` heads for all syntax elements

* functions, for loops, arrays, etc...
"

# ╔═╡ 4c4c0cdf-1eb6-433b-b516-c1782a9077da
import AbstractTrees

# ╔═╡ 3e89f2f6-b773-4acf-a905-b618a6f7c9b8
# Utility for printing expression trees in a Pluto-friendly way
function print_expr_tree(ex)
	Text(sprint(AbstractTrees.print_tree, Base.remove_linenums!(deepcopy(ex))))
end

# ╔═╡ 582006ce-2323-4d00-937e-7718a11b0cca
print_expr_tree(:(
	for i = 1:100
	    y += i
    end
))

# ╔═╡ 427e7de2-44ed-484d-8e1a-e0c51da316ac
img("for_ast.png", 40)

# ╔═╡ 82e6ecfe-b3fa-4c39-a02d-86590935874b
print_expr_tree(:(
	function f(x)
		y = x + 1
		return y^2
	end
))

# ╔═╡ 0fbac98e-cce7-4db6-b78f-577f8b030144
md"""
# Macros - customizing syntax

* A macro is a function taking an `Expr` and returning an `Expr`
* Names prefixed with `@` let the compiler know to invoke them *during compilation*, rather than during running of the code.
"""

# ╔═╡ 4ccf0a9c-ebfa-4c3c-a21d-391517751c44
# Show the symoblic form of an expression and the value of that expression
# (This is customized for Pluto.jl see also Base.@show)
macro show_expression(ex)
	ex_name = string(ex)
	quote
		ex_value = $(esc(ex))
		Text(string($ex_name, " = ", ex_value))
	end
end

# ╔═╡ 40abf2b4-c54e-486e-bb04-8f8fb95ef8c8
x = 100

# ╔═╡ f06bd007-2471-4cf4-996b-d4176dfe344b
@show_expression x^2 + 1

# ╔═╡ 0098d98f-ec29-4b2f-92ad-c31dc570cbc2
md"## Expanding macros

* `macroexpand()` and `@macroexpand` invoke the compiler's macro expansion logic — great for debugging custom macros!
* Scan an expression tree, calling macros in the right context.
* Produces another expression tree with macros replaced with expanded code
"

# ╔═╡ 0cb2c3f6-00aa-40bf-880e-83bdafa873db
Base.remove_linenums!(
	@macroexpand @show_expression(x^2 + 1)
)

# ╔═╡ 71ec831d-162f-475f-9155-6da7f2551ccc
md"""
As if you'd manually written
"""

# ╔═╡ 690094be-3c89-45eb-aa22-1bc9559014b8
begin
    the_value = x^2 + 1
    Text(string("x ^ 2 + 1", " = ", the_value))
end

# ╔═╡ e98403f6-d258-46fe-8569-7e5afef660e2
md"""
## Macro are cool, but use functions if you can!

* Macros are for manipulating code *symbolically*
* Occasionally for working around missed optimizations
* Always try functions first for manipulating *values*
* See Steven Johnson's JuliaCon keynote *Adventures in Code Generation* <https://www.youtube.com/watch?v=mSgXWpvQEHE>
"""

# ╔═╡ 773ac712-32b6-4f64-bfe9-d250988c45a0
md"""
# Lowering (syntax analysis)

Does *purely symbolic* transformations of the source code. Things which depend only on the "shape of the source code", nothing to do with running that code or type information.

* **Input is an Expr** — from parsing
* **Output is Julia untyped IR** — a non-hierarcical intermediate representation where code is a linear sequence of simple instructions. Intermediate results are in temporary variables, and all control flow is replaced by `goto` statements.

$(img("lowered_sin_2x.png", 60))
"""

# ╔═╡ 1e6b02dd-4a81-4d94-80c0-2942f6402ea8
md"""
## Lowering steps

Lowering is accessed with `Meta.lower()`

* Expand macros as in `@macroexpand`
* Simplify syntax ("desugaring") — for example, `x ? a : b` turns into `if ... else ... end`
* Analyze variable and scopes (local variables, global variables, closure captures)
* Convert closures to types
* Flatten hierarcical syntax tree into IR ("linearize")
"""

# ╔═╡ ca8b26b5-cc0f-4cb5-ac86-5996f8e3085e
md"""
## Introspecting lowering

* `@code_lowered` and `code_lowered` — see the lowered code for any function
* `Meta.lower()`, `Meta.@lower` — lower any `Expr`; can be used to see lowered code for function definitions, types, etc.
"""

# ╔═╡ c29b4525-5ccd-4912-a9d6-8539ee643041
function lowering_example(x,y)
	a = 10
	if y > 1
		z = a*x
	else
		z = b*x
	end
	return z
end

# ╔═╡ 187d1c39-3315-4a23-89a5-e28852cdc4f4
@code_lowered lowering_example(1,2)
# Calls code_lowered(lowering_example, (Int,Int))

# ╔═╡ e9fa9a99-732f-4f3f-bb48-05f9d775cf23
md"""
# Type Inference and Optimization

Much Julia code doesn't specify types, but we want fast code. We need type information for unboxing/devirtualization optimizations, etc.

Types are *inferred* when you run a function

* Input is **untyped IR** from lowering and **function argument types** found at *runtime*
* Output is **typed IR** — in single-static-assignment form "SSAIR"
"""


# ╔═╡ 044a189e-49c5-4f18-b22f-9dd653ff85a8
md"""
## Introspecting type inference

* `@code_typed` or `code_typed()` shows results of type inference on the body of a function
* Needs the function name *and* input argument types
* `@code_typed` lets you supply argument values, but only the type are used
"""

# ╔═╡ bcc6c126-a6e7-46df-a42d-801fabfd596d
function sin_example(x)
	return sin(π*x)
end

# ╔═╡ 17e1de40-97cf-4034-a1c4-26625d5b972c
let
	@code_typed optimize=false sin_example(1.0)
	# Only the types are used.
	# Same as code_typed(sin_example, (Float64,); optimize=false)
end

# ╔═╡ 279c852d-4e2d-4c09-8007-01c4be40e6df
sin_example(1.0)

# ╔═╡ f5cd81bb-5ccc-42af-9dcf-92317c15d214
sin_example(big"1.0")

# ╔═╡ b28c5671-c3fd-407b-a0a0-80cc5e1bc5a3
md"""
## Type inference algorithm

* Type of each value is initialized to `Union{}`
* Start with known types of function parameters
* Flow these through the program via abstract interpretation
    * As types propagate, widen the inferred type of each value
    * Prune program location working set when types converge
    * Give up and return `Any` if types get "too complex"
* Captures all ways in which types *might* flow through the program. Take both branches for `if/else` constructs, etc.

For much more detail, see a nice post by the JET.jl author <https://aviatesk.github.io/posts/data-flow-problem-20201109/>
"""

# ╔═╡ e2bfc8a7-135e-43a2-a11d-a82398796d5d
md"## Basic type inference example"

# ╔═╡ 759d57a3-488e-4add-b8b8-d0fe876b60fb
function func(x)
	return x*x + x - 1
end

# ╔═╡ 81593170-9684-481c-81f3-1847126d6592
@code_typed optimize=false func(1.0)

# ╔═╡ 5c24ff73-6ea0-46bd-81a4-8cb30bc152f9
let # `let` block only required due to a tricky-to-fix bug in Pluto :)
@code_typed optimize=false func(1)
end

# ╔═╡ 6a4aa9da-c164-4b00-8772-dd2d35e3f8e6
@code_lowered func(1)

# ╔═╡ a2052ba3-748c-479d-b89a-34a85978110b
let
@code_typed optimize=true func(1.0)
end

# ╔═╡ 7562b460-3aec-459a-90d1-436f3d8a29dc
let
@code_typed optimize=true func(20)
end

# ╔═╡ 4743bb49-f249-495d-bd0e-75e94ba9ea22
md"""
## Type instability

* Type inference often doesn't converge to a single concrete type
* Can be bad for performance. *Especially* if you get `Any`.
* `@code_warntype` pinpoints offending abstract types
"""

# ╔═╡ fe772a8a-43c1-4d0c-8ef4-a25dd4e3356a
# Naive implementation of sum() for vectors
function my_sum(xs)
	y = 0
	for i = 1:length(xs)
		y += xs[i]
	end
	return y
end

# ╔═╡ 9489ebb7-f164-4ae3-a142-4a520983e51a
# In terminal, use @code_warntype
@code_warntype_ my_sum([1.0, 2.0])

# ╔═╡ 0c734a23-da97-45bb-b05c-d1af052c0f5d
md"""
## JET.jl demo: program linting

* The type inference machiery is used to track other properties such as const-ness. 
* Can also used for program linting, as in <https://github.com/aviatesk/JET.jl>.
* Let's see it in action (demo)
"""

# ╔═╡ 78401e2a-18fe-4a83-b61f-258280e7596b
md"""
# Code Generation

Julia generates efficient machine code by translating the typed SSAIR into LLVM's (<https://llvm.org/>) abstract machine model. LLVM is very good at producing efficient machine code for many machines from a precise but low-level intermediate representation.

* **Input** is **Typed IR** — from type inference
* Intermediate result of LLVM IR
* **Output** is **Machine code** — may be viewed as assembly code

* Introspect with `@code_llvm` and `@code_native` / `code_llvm` and `code_native`.
"""

# ╔═╡ 9e73168e-d41e-4d74-9d9b-b21e5879dd0a
function func2(x)
	return x*x + x - 1
end

# ╔═╡ ea1aec52-fdc3-40dc-bd63-53a66252a2ff
# In terminal, use @code_llvm
@code_llvm_ func(1.0)

# ╔═╡ 9553eb9d-aaf9-46e0-b1a0-aeb530194b38
# In terminal, use @code_native
@code_native_ func(1.0)

# ╔═╡ 684e40a8-db67-4c8c-ae66-01c9320f8de6
md"""
# Conclusion

* Julia gives you a lot of tools to inspect compilation
* The tools help you to understand compilation, customize it, and optimize your code.
"""

# ╔═╡ b5e2edd2-e8d8-49e0-9a76-6b149926457a
md"""
## Bonus: `@generated` functions

* A function which takes *types* and produces *syntax* which is further compiled
* Fancy workaround for missed compiler optimizations
* Example: unrolling a loop for short vectors (cf. StaticArrays.jl)
"""

# ╔═╡ 9c264171-6c13-46d9-b9bc-9b015dd930e7
struct MyVec{N} <: AbstractVector{Float64}
	data::NTuple{N,Float64}
end

# ╔═╡ 5d24448a-f2be-42ff-aa30-645c049bec38
@generated function Base.:+(v1::MyVec{N}, v2::MyVec{N}) where {N}
	
end

# ╔═╡ 97d0d99d-a30e-4f23-a7f5-f0e6726ba3e1
md"""
# Extra: A Light-Hearted Demo — Gameoji

* An emoji-based dungeon crawler I made for my kids
* https://github.com/c42f/Gameoji (currently private though)
* Silly but fun 😅, and has various interesting technical points (level generation, multiplayer networking, remote REPL, ECS object model)
* Demo
"""

# ╔═╡ 46fac76e-a39c-4e4c-a571-81dd88baae94
md"""
## RemoteREPL.jl

* <https://github.com/c42f/RemoteREPL.jl>
* Get a new Julia REPL in an existing process
* Demo
"""

# ╔═╡ 3cb9de69-69de-421c-9ebe-515a3a3a6983
md"""
## Overseer.jl

* Entity-Component-System (ECS) library <https://github.com/louisponet/Overseer.jl>
* Entity — A thing in the game. Eg, player, monster, wall, etc.
* Component — Property of an entity. Eg, position, emoji icon, etc
* System — Reads or updates a small set of components, describing the game rules. The "physics" of the game world, if you like.  Eg, position upate, rendering, player input, etc.
"""

# ╔═╡ 5e5e8126-4453-4e04-9e01-f148ee980513
begin
	md"""

## Runtime
  - Garbage collection
  - Just in time compilation
  - World age mechanism
"""

	md"""# - - -
	
	Other notes"""
end

# ╔═╡ Cell order:
# ╟─18c4f7f8-6165-49f5-9c03-a1a767a71776
# ╟─f1429e8b-8ccb-4c3a-bafc-40c26e464093
# ╟─2308c374-1693-4b91-9143-469d218159cd
# ╟─8c557a45-8e2a-41c2-9bb8-5c98f1b5d468
# ╟─bf59cd5a-ca53-4ca6-8123-ef0af182dd50
# ╟─ba3bb7d4-9a1d-4baf-af7f-42dfd5fb6959
# ╟─f5c3afd0-9fd4-11eb-248a-bbe5fd108765
# ╟─879df7e7-da76-4086-807f-ea2231db7d4d
# ╟─183ba856-9fd5-11eb-3648-154ad2971a4b
# ╟─b3c200c6-9fd6-11eb-0dc1-dd4c1c38f283
# ╟─93b71fcc-4a1f-4130-8b7f-95ab37865c62
# ╠═9736ee46-4c83-4a19-8e82-fb463328acb4
# ╟─9aeb03de-2130-40c8-87f0-c716531a8f27
# ╠═c1b6dad5-56b0-4cc9-9fdf-7d93122b2c20
# ╟─5bb6d2e6-29b7-4f56-b052-e577fbeece7e
# ╠═21466a22-61d9-49d6-8b9b-b1943338c84f
# ╠═3cad286a-2810-4581-8178-516dae08cda4
# ╠═da38c4ad-74dd-4fdf-b272-148389a1e9ff
# ╠═d31ade63-8857-4874-a54f-ad5030faa5b0
# ╟─551bd18b-9621-4f54-8b74-c8eb7575e665
# ╠═dc70d830-9fd6-11eb-31c9-478a4cf57514
# ╠═0aa1911c-de07-4440-9298-397a3c798aa1
# ╟─2022f37f-52a0-4164-9a0a-c2f8c855c7ff
# ╠═4c4c0cdf-1eb6-433b-b516-c1782a9077da
# ╠═3e89f2f6-b773-4acf-a905-b618a6f7c9b8
# ╠═582006ce-2323-4d00-937e-7718a11b0cca
# ╟─427e7de2-44ed-484d-8e1a-e0c51da316ac
# ╠═82e6ecfe-b3fa-4c39-a02d-86590935874b
# ╟─0fbac98e-cce7-4db6-b78f-577f8b030144
# ╠═4ccf0a9c-ebfa-4c3c-a21d-391517751c44
# ╠═40abf2b4-c54e-486e-bb04-8f8fb95ef8c8
# ╠═f06bd007-2471-4cf4-996b-d4176dfe344b
# ╟─0098d98f-ec29-4b2f-92ad-c31dc570cbc2
# ╠═0cb2c3f6-00aa-40bf-880e-83bdafa873db
# ╟─71ec831d-162f-475f-9155-6da7f2551ccc
# ╠═690094be-3c89-45eb-aa22-1bc9559014b8
# ╟─e98403f6-d258-46fe-8569-7e5afef660e2
# ╟─773ac712-32b6-4f64-bfe9-d250988c45a0
# ╟─1e6b02dd-4a81-4d94-80c0-2942f6402ea8
# ╟─ca8b26b5-cc0f-4cb5-ac86-5996f8e3085e
# ╠═c29b4525-5ccd-4912-a9d6-8539ee643041
# ╠═187d1c39-3315-4a23-89a5-e28852cdc4f4
# ╟─e9fa9a99-732f-4f3f-bb48-05f9d775cf23
# ╟─044a189e-49c5-4f18-b22f-9dd653ff85a8
# ╠═bcc6c126-a6e7-46df-a42d-801fabfd596d
# ╠═17e1de40-97cf-4034-a1c4-26625d5b972c
# ╠═279c852d-4e2d-4c09-8007-01c4be40e6df
# ╠═f5cd81bb-5ccc-42af-9dcf-92317c15d214
# ╟─b28c5671-c3fd-407b-a0a0-80cc5e1bc5a3
# ╟─e2bfc8a7-135e-43a2-a11d-a82398796d5d
# ╠═759d57a3-488e-4add-b8b8-d0fe876b60fb
# ╠═81593170-9684-481c-81f3-1847126d6592
# ╠═5c24ff73-6ea0-46bd-81a4-8cb30bc152f9
# ╠═6a4aa9da-c164-4b00-8772-dd2d35e3f8e6
# ╠═a2052ba3-748c-479d-b89a-34a85978110b
# ╠═7562b460-3aec-459a-90d1-436f3d8a29dc
# ╟─4743bb49-f249-495d-bd0e-75e94ba9ea22
# ╠═fe772a8a-43c1-4d0c-8ef4-a25dd4e3356a
# ╠═9489ebb7-f164-4ae3-a142-4a520983e51a
# ╟─0c734a23-da97-45bb-b05c-d1af052c0f5d
# ╟─78401e2a-18fe-4a83-b61f-258280e7596b
# ╠═9e73168e-d41e-4d74-9d9b-b21e5879dd0a
# ╠═ea1aec52-fdc3-40dc-bd63-53a66252a2ff
# ╠═9553eb9d-aaf9-46e0-b1a0-aeb530194b38
# ╟─684e40a8-db67-4c8c-ae66-01c9320f8de6
# ╟─b5e2edd2-e8d8-49e0-9a76-6b149926457a
# ╠═9c264171-6c13-46d9-b9bc-9b015dd930e7
# ╠═5d24448a-f2be-42ff-aa30-645c049bec38
# ╟─97d0d99d-a30e-4f23-a7f5-f0e6726ba3e1
# ╟─46fac76e-a39c-4e4c-a571-81dd88baae94
# ╟─3cb9de69-69de-421c-9ebe-515a3a3a6983
# ╟─5e5e8126-4453-4e04-9e01-f148ee980513
