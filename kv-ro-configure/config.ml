open Mirage

let dir =
  let doc = Key.Arg.info ~doc:"Directory." [ "dir" ] in
  Key.(create "dir" Arg.(opt ~stage:`Configure string "data" doc))

type kv_ro = KV_RO
let kv_ro = Type KV_RO

let crunch =
  let key = Key.abstract dir in
  object
    inherit base_configurable
    method ty = kv_ro
    (* in mirage_impl_kv_ro:
       val name = Name.create ("static" ^ dirname) ~prefix:"static"
       method name = name *)
    method name = "crunch"
    method module_name = "Static"
    method! keys = [ key ]
    method! packages =
      Key.pure [
        package ~min:"2.0.0" ~max:"3.0.0" "io-page";
        package ~min:"2.0.0" ~max:"3.0.0" ~build:true "crunch"
      ]
    method! connect _ modname _ = Fmt.strf "%s.connect ()" modname
    method! build _i =
      let dir = Fpath.(v dirname) in
      let file = Fpath.(v name + "ml") in
      Bos.OS.Path.exists dir >>= function
      | true ->
        Mirage_impl_misc.Log.info (fun m -> m "Generating: %a" Fpath.pp file);
        Bos.OS.Cmd.run Bos.Cmd.(v "ocaml-crunch" % "-o" % p file % p dir)
      | false ->
        R.error_msg (Fmt.strf "The directory %s does not exist." dirname)
    method! clean _i =
      Bos.OS.File.delete Fpath.(v name + "ml") >>= fun () ->
      Bos.OS.File.delete Fpath.(v name + "mli")
  end

let main =
  foreign
    "Unikernel.Hello" (kv_ro @-> job)

let kv = impl crunch

let () =
  register "kv_ro_configure" [main $ kv]
