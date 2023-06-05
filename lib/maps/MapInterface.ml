module type MapInterface = sig 
    type t
    val empty : t
    val insert : int -> string -> t -> t
    val find : int -> t -> string option 
    val remove : int -> t -> t
    val from_list : (int * string) list -> t
    val bindings : t -> (int * string) list 
end 


