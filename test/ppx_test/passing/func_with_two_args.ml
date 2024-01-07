module type S = sig
  type 'a t

  val f : int -> 'a t -> 'a t
end
[@@deriving_inline mica_types]

type expr = F of int * expr
type ty = IntT

[@@@end]
