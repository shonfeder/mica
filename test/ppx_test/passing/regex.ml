module type RegexMatcher = sig
  type t

  val void : t
  val empty : t
  val lit : char -> t
  val alt : t -> t -> t
  val cat : t -> t -> t
  val star : t -> t
  val matchString : t -> string -> bool
  val acceptsEmpty : t -> bool
end