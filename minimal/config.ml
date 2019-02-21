open Mirage

let storage =
  let parser, printer =
    Cmdliner.Arg.enum [
      "filesystem", `Filesystem;
      "memory", `Memory;
  ] in
  let serialize ppf = function
  | `Filesystem -> Fmt.string ppf "`Filesystem"
  | `Memory -> Fmt.string ppf "`Memory"
  in
  let doc = Key.Arg.info ~doc:"Choice of storage backend, options: filesystem, memory" [ "storage" ] in
  let default_mem = `Memory in
  let converter = Key.Arg.conv ~conv:(parser, printer) ~serialize ~runtime_conv:"storage" in
  Key.(create "storage" Arg.(opt ~stage:`Configure converter default_mem doc))

let main = foreign "Unikernel.Main" (pclock @-> job)

let p1 = object
    inherit base_configurable
    method ty = pclock
    method name = "mirage-kv-mem"
    method module_name = "Mirage_kv_mem.Make"
  end

let p2 = impl @@ object
    inherit base_configurable
    method ty = pclock @-> pclock
    method name = "mirage-kv-mem"
    method module_name = "Mirage_kv_mem.Make"
  end

let store = (* p2 $ default_posix_clock <- works fine! *)
  match_impl (Key.value storage) [
   `Memory, p2 $ default_posix_clock ;
 ] ~default:(p2 $ default_posix_clock)

let () = register "blarf" [main $ store ]
