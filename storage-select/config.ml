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

type kv_rw = KV_RW
let kv_rw = Type KV_RW

let main =
  foreign
    "Unikernel.Main" (kv_rw @-> job)

let kv_mem = impl @@ object
    inherit base_configurable
    method ty = pclock @-> kv_rw
    method name = "mirage-kv-mem"
    method module_name = "Mirage_kv_mem.Make"
    method! packages =
      Key.pure [
        package "mirage-kv-mem";
      ]
    method! connect _ modname _ = Fmt.strf "%s.connect ()" modname
  end

let unix_dir =
  let doc = Key.Arg.info ~doc:"Location of calendar data." [ "unix-dir" ] ~docv:"DIR" in
  Key.(create "unix_dir" Arg.(opt (some string) None doc))

let kv_unix =
  let key = Key.abstract unix_dir in
  object
    inherit base_configurable
    method ty = kv_rw
    method name = "mirage-kv-unix"
    method module_name = "Mirage_kv_unix"
    method! keys = [ key ]
    method! packages =
      Key.pure [
        package "mirage-kv-unix";
      ]
    method! connect _ modname _ = Fmt.strf "%s.connect (match %a with Some x -> x | None -> assert false)" modname Key.serialize_call key 
  end

let store =
  match_impl (Key.value storage) [
   `Memory, kv_mem $ default_posix_clock ;
   `Filesystem, impl kv_unix
  ] ~default:(kv_mem $ default_posix_clock)

let () = register "blarf" [main $ store ]
