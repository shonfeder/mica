module type SetInterface = sig
  type 'a t

  val empty : 'a t
  val is_empty : 'a t -> bool
  val mem : 'a -> 'a t -> bool
  val add : 'a -> 'a t -> 'a t
  val rem : 'a -> 'a t -> 'a t
  val size : 'a t -> int
  val union : 'a t -> 'a t -> 'a t
  val intersect : 'a t -> 'a t -> 'a t
  val invariant : 'a t -> bool
end


include
  struct
    [@@@ocaml.warning "-60"]
    type expr =
      | Empty
      | Is_empty of expr
      | Mem of int * expr
      | Add of int * expr
      | Rem of int * expr
      | Size of expr
      | Union of expr * expr
      | Intersect of expr * expr
      | Invariant of expr
    type ty =
      | Bool
      | Int
      | IntT
    let gen_expr ty =
      let open Base_quickcheck.Generator in
        let open Let_syntax in
          size >>=
            (fun x ->
               match ty with
               | Bool ->
                   of_list
                     [Is_empty expr__001_;
                     Mem (int__002_, expr__003_);
                     Invariant expr__013_]
               | Int -> of_list [Size expr__008_]
               | IntT ->
                   of_list
                     [Empty ();
                     Add (int__004_, expr__005_);
                     Rem (int__006_, expr__007_);
                     Union (expr__009_, expr__010_);
                     Intersect (expr__011_, expr__012_)])
    let _ = gen_expr
    module TestHarness(M:SetInterface) =
      struct
        include M
        type value =
          | ValBool of bool
          | ValInt of int
          | ValIntT of int t
        let rec interp e =
          match e with
          | Empty -> ValIntT M.empty
          | Is_empty expr__014_ ->
              (match interp expr__014_ with
               | ValIntT expr__014_' -> ValBool (M.is_empty expr__014_')
               | _ -> failwith "impossible: unary constructor")
          | Mem (int__015_, expr__016_) ->
              (match interp expr__016_ with
               | ValIntT expr__016_' -> ValBool (M.mem int__015_ expr__016_')
               | _ -> failwith "impossible: n-ary constructor")
          | Add (int__017_, expr__018_) ->
              (match interp expr__018_ with
               | ValIntT expr__018_' -> ValIntT (M.add int__017_ expr__018_')
               | _ -> failwith "impossible: n-ary constructor")
          | Rem (int__019_, expr__020_) ->
              (match interp expr__020_ with
               | ValIntT expr__020_' -> ValIntT (M.rem int__019_ expr__020_')
               | _ -> failwith "impossible: n-ary constructor")
          | Size expr__021_ ->
              (match interp expr__021_ with
               | ValIntT expr__021_' -> ValInt (M.size expr__021_')
               | _ -> failwith "impossible: unary constructor")
          | Union (expr__022_, expr__023_) ->
              (match ((interp expr__022_), (interp expr__023_)) with
               | (ValIntT expr__022_', ValIntT expr__023_') ->
                   ValIntT (M.union expr__022_' expr__023_')
               | _ -> failwith "impossible: n-ary constructor")
          | Intersect (expr__024_, expr__025_) ->
              (match ((interp expr__024_), (interp expr__025_)) with
               | (ValIntT expr__024_', ValIntT expr__025_') ->
                   ValIntT (M.intersect expr__024_' expr__025_')
               | _ -> failwith "impossible: n-ary constructor")
          | Invariant expr__026_ ->
              (match interp expr__026_ with
               | ValIntT expr__026_' -> ValBool (M.invariant expr__026_')
               | _ -> failwith "impossible: unary constructor")
        let _ = interp
      end
  end[@@ocaml.doc "@inline"]

