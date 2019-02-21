open Lwt.Infix

module Hello (KV : Mirage_kv_lwt.RW) = struct

  let start fs =
    Logs.info (fun m -> m "started") ;
    Lwt.return_unit

end
