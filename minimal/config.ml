open Mirage

let main = foreign "Unikernel.Main" (pclock @-> job)

let p2 = impl @@ object
    inherit base_configurable
    method ty = pclock @-> pclock
    method name = "mirage-kv-mem"
    method module_name = "Mirage_kv_mem.Make"
  end

let store =
  match_impl Key.(value target) [
   `Unix, p2 $ default_posix_clock ;
 ] ~default:(p2 $ default_posix_clock)

let () = register "blarf" [main $ store ]
