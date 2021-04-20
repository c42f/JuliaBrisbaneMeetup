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
	
	nothing
end

# ╔═╡ ba3bb7d4-9a1d-4baf-af7f-42dfd5fb6959
md"
# Welcome!

#### Brisbane Julia Meetup Group

* Aiming to meet about once a month
    * Informal short talks / demos
    * Workshops / hackathons (?)
* We love hearing about all sorts of applications of Julia.
* Anyone can present a talk or demo!
"

# ╔═╡ f1429e8b-8ccb-4c3a-bafc-40c26e464093
html"<button onclick='present()'>presentation mode</button>"

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

* I used various languages for "technical computing" — mostly C++, python and matlab
* I wished for a language which was natively numerical like matlab; interactive & general purpose like python; fast like C++.
* Saw the [julia-0.1 blog post](https://julialang.org/blog/2012/02/why-we-created-julia/) and started dabbling with version ~0.2 in 2013
    * Adding new number types looked so easy compared to python
    * matlab->julia for an IMU/GPS sensor fusion problem. ~100x speedup? neater code?
"""

# ╔═╡ 183ba856-9fd5-11eb-3648-154ad2971a4b
md"""
# Julia Internals

Compilation stages are kind of standard
  - Parsing
  - Lowering
  - Type Inference
  - Code Generation (LLVM / Machine code)

But Julia is unusual in helping you inspect, understand and customize the stages.

Understanding what the compiler does with your code can be helpful!
"""

# ╔═╡ b3c200c6-9fd6-11eb-0dc1-dd4c1c38f283
md"""
# Parsing

* The first compiler pass `Meta.parse()`
* **Input text** — a sequence of characters
* **Output an AST** (abstract syntax tree) — a symbolic hierarchical representation of the program
* Parse tree is made of objects of type `Expr`
"""

# ╔═╡ 9736ee46-4c83-4a19-8e82-fb463328acb4
Dump(Meta.parse("x + 2"))

# ╔═╡ 9aeb03de-2130-40c8-87f0-c716531a8f27
md"""
* `Symbol` is a type used for "the name of identifiers in code". Basically a string, but each symbol is stored only once ("interned").
* Expressions can be constructed manually with `Expr`.
"""

# ╔═╡ c1b6dad5-56b0-4cc9-9fdf-7d93122b2c20
Expr(Symbol("call"), Symbol("+"), Symbol("x"), 2)

# ╔═╡ 551bd18b-9621-4f54-8b74-c8eb7575e665
md"""
## Parse tree hierarchy

Here's the parse tree for ```sin(π * x)```

$(img("parse_sin_2x.png", 25))
"""

# ╔═╡ 3ce1afbe-bb2f-49b1-aee6-f773614e6202
ex = Meta.parse("sin(π*x)")

# ╔═╡ dc70d830-9fd6-11eb-31c9-478a4cf57514
Dump(ex)

# ╔═╡ 0aa1911c-de07-4440-9298-397a3c798aa1
Expr(:call, :sin, Expr(:call, :*, :π, :x))

# ╔═╡ 2022f37f-52a0-4164-9a0a-c2f8c855c7ff
md"## `Expr` heads for all surface syntax

* functions
* for loops
* arrays
* etc...
"

# ╔═╡ 4c4c0cdf-1eb6-433b-b516-c1782a9077da
import AbstractTrees

# ╔═╡ 3e89f2f6-b773-4acf-a905-b618a6f7c9b8
function print_expr_tree(ex)
	Text(sprint(AbstractTrees.print_tree, Base.remove_linenums!(deepcopy(ex))))
end

# ╔═╡ ec4bab3e-1aa1-40c9-ae24-f6ef65ad92f2
print_expr_tree(ex)

# ╔═╡ 582006ce-2323-4d00-937e-7718a11b0cca
print_expr_tree(:(for i = 1:100
	y += i
end))

# ╔═╡ 427e7de2-44ed-484d-8e1a-e0c51da316ac
img("for_ast.png", 40)

# ╔═╡ 82e6ecfe-b3fa-4c39-a02d-86590935874b
print_expr_tree(:(function f(x)
	x + 1
end))

# ╔═╡ 0fbac98e-cce7-4db6-b78f-577f8b030144
md"""
# Macros

* Macros let you *customize syntax*
* Julia functions taking an `Expr` and returning an `Expr`
* Name prefixed with `@` lets the compiler know to invoke them *during compilation*, not while runnind the code.
* `@macroexpand` lets you see macro expansion
"""

# ╔═╡ 4ccf0a9c-ebfa-4c3c-a21d-391517751c44
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

# ╔═╡ 0cb2c3f6-00aa-40bf-880e-83bdafa873db
Base.remove_linenums!(@macroexpand @show_expression x^2 + 1)

# ╔═╡ 71ec831d-162f-475f-9155-6da7f2551ccc
md"""
Just like if you'd manually written out

```
begin
    value = x^2 + 1
    Text(string("x ^ 2 + 1", " = ", value))
end
```
"""

# ╔═╡ 773ac712-32b6-4f64-bfe9-d250988c45a0
md"""
# Lowering

Does all *purely symbolic* transformations of the source code. Things which depend only on the "shape of the source code", nothing to do with running the code.

1. Expand macros - `@macroexpand`
2. Other analysis - `Meta.@lower`
    * Simplify syntax ("desugaring")
    * Analyze variable and scopes (local variables, global variables, closure captures)
    * Convert closures to types
    * Flatten hierarcical syntax tree ("linearize")

(Precompilation is lowering + running top-level module code.)
"""

# ╔═╡ 7bd9a79d-028e-4542-a29b-dd6b3f1890d8
# Desugaring
Meta.@lower a ? b : c

# ╔═╡ e9fa9a99-732f-4f3f-bb48-05f9d775cf23
md"""
# Type Inference

Triggered when you run a function with particular input types

* Inspect with `@code_typed`
* 
"""

# ╔═╡ 759d57a3-488e-4add-b8b8-d0fe876b60fb
function func(x)
	return x*x + x + 1
end

# ╔═╡ 6a4aa9da-c164-4b00-8772-dd2d35e3f8e6
@code_lowered func(1.0)

# ╔═╡ 81593170-9684-481c-81f3-1847126d6592
@code_typed optimize=false func(1.0)

# ╔═╡ a2052ba3-748c-479d-b89a-34a85978110b
let # extra `let` only required due to a bug in Pluto!
	@code_typed optimize=true func(1.0)
end

# ╔═╡ 5e5e8126-4453-4e04-9e01-f148ee980513
md"""

## Runtime
  - Garbage collection
  - Just in time compilation
  - World age mechanism
"""

# ╔═╡ Cell order:
# ╟─ba3bb7d4-9a1d-4baf-af7f-42dfd5fb6959
# ╟─f1429e8b-8ccb-4c3a-bafc-40c26e464093
# ╟─2308c374-1693-4b91-9143-469d218159cd
# ╟─f5c3afd0-9fd4-11eb-248a-bbe5fd108765
# ╟─879df7e7-da76-4086-807f-ea2231db7d4d
# ╟─183ba856-9fd5-11eb-3648-154ad2971a4b
# ╟─b3c200c6-9fd6-11eb-0dc1-dd4c1c38f283
# ╠═9736ee46-4c83-4a19-8e82-fb463328acb4
# ╟─9aeb03de-2130-40c8-87f0-c716531a8f27
# ╠═c1b6dad5-56b0-4cc9-9fdf-7d93122b2c20
# ╟─551bd18b-9621-4f54-8b74-c8eb7575e665
# ╠═3ce1afbe-bb2f-49b1-aee6-f773614e6202
# ╠═dc70d830-9fd6-11eb-31c9-478a4cf57514
# ╠═0aa1911c-de07-4440-9298-397a3c798aa1
# ╟─2022f37f-52a0-4164-9a0a-c2f8c855c7ff
# ╠═4c4c0cdf-1eb6-433b-b516-c1782a9077da
# ╠═3e89f2f6-b773-4acf-a905-b618a6f7c9b8
# ╠═ec4bab3e-1aa1-40c9-ae24-f6ef65ad92f2
# ╠═582006ce-2323-4d00-937e-7718a11b0cca
# ╠═427e7de2-44ed-484d-8e1a-e0c51da316ac
# ╠═82e6ecfe-b3fa-4c39-a02d-86590935874b
# ╟─0fbac98e-cce7-4db6-b78f-577f8b030144
# ╠═4ccf0a9c-ebfa-4c3c-a21d-391517751c44
# ╠═40abf2b4-c54e-486e-bb04-8f8fb95ef8c8
# ╠═f06bd007-2471-4cf4-996b-d4176dfe344b
# ╠═0cb2c3f6-00aa-40bf-880e-83bdafa873db
# ╠═71ec831d-162f-475f-9155-6da7f2551ccc
# ╠═773ac712-32b6-4f64-bfe9-d250988c45a0
# ╠═7bd9a79d-028e-4542-a29b-dd6b3f1890d8
# ╠═e9fa9a99-732f-4f3f-bb48-05f9d775cf23
# ╠═759d57a3-488e-4add-b8b8-d0fe876b60fb
# ╠═6a4aa9da-c164-4b00-8772-dd2d35e3f8e6
# ╠═81593170-9684-481c-81f3-1847126d6592
# ╠═a2052ba3-748c-479d-b89a-34a85978110b
# ╠═5e5e8126-4453-4e04-9e01-f148ee980513
