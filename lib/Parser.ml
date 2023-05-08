open Angstrom 
open Base

module A = Angstrom

(******************************************************************************)
(** Boolean predicates on characters *)

(** [is_digit c] returns true if [c] is a digit, false otherwise *)  
let is_digit (c : char) : bool = 
  match c with
  |'0'..'9' -> true 
  | _ -> false

(** [is_uppercase c] returns true if [c] is a capital letter, false otherwise *)  
let is_uppercase (c : char) : bool = 
  match c with 
  | 'A'..'Z' -> true 
  | _ -> false 

(** [is_letter c] returns true if [c] is a letter, false otherwise *)    
let is_letter (c : char) : bool = 
  match c with 
  | 'a'..'z' | 'A'..'Z' -> true 
  | _ -> false 


(** [is_whitespace c] returns true if [c] is a whitespace character *)
let is_whitespace (c : char) : bool = 
  match c with
  | '\x20' | '\x0a' | '\x0d' | '\x09' -> true
  | _ -> false  

(******************************************************************************)
(** Simple parsers *)  

(** Parser for capital letters *)    
let upperCaseP : char A.t = 
  A.satisfy is_uppercase

(** Parser for letters *)  
let letterP : char A.t = 
  A.satisfy is_letter

(** Parser for a single digit *)  
let digitP : char A.t = 
  A.satisfy is_digit

(** Parser for integers *)  
let intP : int A.t =
  Int.of_string <$> A.take_while1 is_digit

(** Parser for a whitespace character *)  
let whitespace : char A.t = 
  A.satisfy is_whitespace

(** Takes a parser [p], runs it & skips over any whitespace chars occurring afterwards *)
let wsP (p : 'a A.t) : 'a A.t = 
  p <* A.many whitespace

(** Accepts only a particular string [str] & consumes any white space that follows *)
let stringP (str : string) : unit A.t = 
  wsP (A.string str) >>| fun _ -> ()

(** Accepts a particular string s, returns a given value x,
    and consume any white space that follows *)  
let constP (s : string) (x : 'a) : 'a A.t = 
  stringP s *> return x

(** [between openP p closeP] parses [openP], followed by [p] and finally
--   [close]. Only the value of [p] is pure-ed.*)  
let between (openP : 'b A.t) (p : 'a A.t) (closeP : 'c A.t) : 'a A.t = 
  openP *> p <* closeP

(** [parens p] takes a parser [p] and parses it between parentheses *)
let parens (p : 'a A.t) : 'a A.t = 
  between (stringP "(") p (stringP ")")  

(** [chainl1 e op] parses one or more occurrences of [e], separated by [op],
    & returns a left-associative application of the functions returned by the [op]
    parser onto the values retruned by the [e] parser.
    Implementation of [chainl1] taken from Angstrom docs *)  
let chainl1 (e : 'a A.t) (op : ('a -> 'a -> 'a) A.t) : 'a A.t =
  let rec go (acc : 'a) : 'a A.t =
    (A.lift2 (fun f x -> f acc x) op e >>= go) <|> return acc in
  e >>= fun init -> go init  

(** [run_parser p s] uses the parser [p] to parse the string [s] *)  
let run_parser (p : 'a A.t) (s : string) = 
  A.parse_string ~consume:Consume.All p s 