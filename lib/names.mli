open Ppxlib

(******************************************************************************)
(** {1 Quoting names} *)

val add_prime : string -> string
val quote_name : string -> string
val update_expr_arg_names : string list -> string list -> string list

(******************************************************************************)
(** {1 Producing fresh identifiers} *)

val mk_fresh :
  loc:Location.t -> f:(loc:Location.t -> string -> 'a) -> core_type -> 'a

val mk_fresh_pvar : loc:Location.t -> core_type -> pattern
val mk_fresh_evar : loc:Location.t -> core_type -> expression

val varnames_of_cstr_args :
  loc:Location.t ->
  constructor_arguments ->
  f:(loc:Location.t -> string -> 'a) ->
  'a list

val pvars_of_cstr_args : loc:Location.t -> constructor_arguments -> pattern list

val evars_of_cstr_args :
  loc:Location.t -> constructor_arguments -> expression list

(******************************************************************************)
(** {1 Convering between different identifier types} *)

val ppat_construct_of_cstr_decl :
  loc:Location.t -> constructor_declaration -> pattern
