open Syntax
open Eval
open Printf

let rec print_result ls = match ls with
  | [] -> ()
  | it :: rest -> match it with (id, v) ->
      printf "val %s = " id;
      pp_val v;
      print_newline ();
      print_result rest

let rec read_file_eval_print ic env =
  try 
    while true; do 
      let line = input_line ic
        in let decl = Parser.toplevel Lexer.main (Lexing.from_string (line)) in
          print_endline ("# " ^ line);
          let (ls, newenv) =  eval_decl env decl in 
            print_result ls;
            read_file_eval_print ic newenv
    done
  with
    | Error msg -> err msg; read_file_eval_print ic env
    | e -> close_in ic
  

let err msg = Printf.printf "Error: %s\n" msg

let rec read_eval_print env =
  print_string("# ");
  flush stdout;
  let decl = Parser.toplevel Lexer.main (Lexing.from_channel stdin) in
    (* Ex 3.2.2 *)
    try 
      let (ls, newenv) =  eval_decl env decl in
        print_result ls;
        read_eval_print newenv
    with
      | Error msg -> err msg; read_eval_print env
    (**)

(* Ex 3.2.1 *)
let initial_env = 
  Environment.extend "i" (IntV 1)
    (Environment.extend "ii" (IntV 2)
      (Environment.extend "iii" (IntV 3)
        (Environment.extend "iv" (IntV 4)
          (Environment.extend "v" (IntV 5) 
            (Environment.extend "x" (IntV 10) Environment.empty)))))
(**)

let _ = let env = initial_env in
  if Array.length Sys.argv > 1 then
    read_file_eval_print (open_in Sys.argv.(1)) env
  else read_eval_print env
