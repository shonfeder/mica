# ppx_mica (WIP)

Current progress:
The `mica` PPX deriver takes a module signature of the form 
```ocaml
module type S = sig
  type 'a t 
  val empty : 'a t
  val add : 'a -> 'a t -> 'a t
  ...
end
[@@deriving_inline mica] 
(* After users run [dune build --auto-promote], the derived PBT code is 
   automatically pasted inline into the source file here *)
...
[@@@end]
```
and derives the following code:
```ocaml 
(* Boilerplate omitted *)

module Mica = struct 
  (** Symbolic expressions *)
  type expr =
    | Empty
    | Is_empty of expr
    ...
  [@@deriving show, ...]

  (** Types of symbolic expressions *)
  type ty = Int | IntT | ... [@@deriving show, ...]

  (** QuickCheck generator for symbolic expressions of type [ty] *)
  let rec gen_expr : ty -> Core.Quickcheck.Generator.t = ...

  (** Functor that interprets symbolic expressions *)
  module Interpret (M : S) = struct   
    (* Values of symbolic expressions *)
    type value = ValInt of int | ValIntT of int M.t | ...

    (* Interprets symbolic expressions over [M] *)
    let rec interp : expr -> value = ...
  end 

  (** Functor that tests [M1] and [M2] for observational equivalence *)
  module TestHarness (M1 : S) (M2 : S) = struct 
    ...
  end
end
```
- To run the testing code derived by Mica, one can invoke the `run_tests : unit -> unit` function in Mica's `TestHarness` functor, like so:
```ocaml 
module T = Mica.TestHarness(M1)(M2)
let () = T.run_tests ()
```
- An example of the code automatically derived by Mica can be found in [`example.ml`](./example/example.ml).

**Functionality to be implemented**:
- Generate random `int -> int` functions in `gen_expr` 
- Automatically derive the `Seq` constructor for testing imperative code
- Automatically instrument testing code with boilerplate needed for Tyche integration

## Directory Overview
The [`lib/ppx`](./lib/ppx) subdirectory contains the code for the Mica PPX deriver. 
The [`lib/tyche_utils`](./lib/tyche_utils) subdirectory contains a small library for 
creating JSON files that are ingested by Tyche. 

The PPX code is organized as follows:
- [`ppx_mica.ml`](./lib/ppx/ppx_mica.ml): Declares the main Mica PPX deriver
- [`type_deriver.ml`](./lib/ppx/type_deriver.ml): Derives the definitions of auxiliary data types & the `gen_expr` Quickcheck generator
- [`interp_deriver.ml`](./lib/ppx/interp_deriver.ml): Derives the `Interpret` functor
- [`test_harness_deriver.ml`](./lib/ppx/test_harness_deriver.ml): Derives the `TestHarness` functor
- [`overall_deriver.ml`](./lib/ppx/overall_deriver.ml): Produces a module called `Mica` containing all the automatically derived code
- [`utils.ml`](./lib/ppx/utils.ml): Includes all the following helper modules for convenience:
  - [`builders.ml`](./lib/ppx/builders.ml): Functions for creating AST nodes
  - [`getters.ml`](./lib/ppx/getters.ml): Functions for inspecting AST nodes
  - [`equality.ml`](./lib/ppx/equality.ml): Location-agnostic equality functions for `Parsetree` types 
  - [`lident.ml`](./lib/ppx/lident.ml): Utilities for working with the `Longident` type
  - [`names.ml`](./lib/ppx/names.ml): Functions for generating fresh variable names & quoting expressions
  - [`printers.ml`](./lib/ppx/printers.ml): Pretty-printers for AST types
  - [`errors.ml`](./lib/ppx/errors.ml): Functions for error handling (embedding errors as extension nodes in the derived code)
  - [`inv_ctx.ml`](./lib/ppx/inv_ctx.ml): The "inverse typing context", mapping types `ty` to expressions of type `ty`
  - [`let_open.ml`](./lib/ppx/let_open.ml): Helpers for producing `let open` expressions
  - [`include.ml`](./lib/ppx/include.ml): Helpers for producing `include` statements
  - [`miscellany.ml`](./lib/ppx/miscellany.ml): Miscellaneous helpers for working with lists & strings
- [`json_utils.ml`](./lib/ppx/json_utils.ml): Tyche-related JSON utilities for collecting test statistics


## Testing 
1. [`test/utils_test`](./test/utils_test/) contains `Alcotest` unit tests for various helper functions.
- See the [README](./test/utils_test/README.md) in [`utils_test`](./test/utils_test/) for instructions
on how to add new tests to the Alcotest test suite.
2. `test/ppx_test` contains `.ml` test files used to test the PPX functionality
- To add a new test file to the corpus of test files, in either `ppx_test/passing` 
or `ppx_test/errors`, run:
```bash
$ touch test_file.{ml,expected}; dune runtest --auto-promote
```
(This automatically generates new Dune stanzas that are needed for 
the new test files to compile.)
- Then fill in the newly-created `.ml` and `.expected` files with the 
module signature under test (plus relevant PPX annotations), 
and execute `dune runtest`. If the test output from Dune looks good, 
run `dune promote` to update the `.expected` file with the contents 
of the `.actual` file (which contains what the PPX actually generated from that test run). 

## Local Development
- This repo has been tested with OCaml 5.1.0 on an M1 Mac.
- We recommend having the following libraries installed:
  - `ppxlib`
  - `ppx_jane`
  - `ppx_deriving.show`
  - `base`
  - `base_quickcheck`
  - `core`
  - `core_unix`
  - `alcotest`
  - `yojson`
- Note: in this codebase, we typically rely on the OCaml standard library, 
  but in a few (limited) instances, we use Jane Street's `Base` library. 
  To avoid namespace clashes, whenever we use a function from `Base`, 
  we always do a local `let open` within the body of the caller function.


