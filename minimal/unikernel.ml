open Lwt.Infix

module Hello (P : Mirage_clock_lwt.PCLOCK) = struct

  let start _ =
    Logs.info (fun m -> m "started") ;
    Lwt.return_unit

end
