open Tokyo_common

let version () = failwith "unimplemented"

type error =
    | Ethread
    | Einvalid
    | Enofile
    | Enoperm
    | Emeta
    | Erhead
    | Eopen
    | Eclose
    | Etrunc
    | Esync
    | Estat
    | Eseek
    | Eread
    | Ewrite
    | Emmap
    | Elock
    | Eunlink
    | Erename
    | Emkdir
    | Ermdir
    | Ekeep
    | Enorec
    | Emisc

exception Error of error * string * string

let _ = Callback.register_exception "Tokyo_cabinet.Error" (Error (Emisc, "", ""))

type omode = Oreader | Owriter | Ocreat | Otrunc | Onolck | Olcknb | Otsync

type opt = Tlarge | Tdeflate | Tbzip | Ttcbs

module ADB =
struct
  type t

  module type Sig =
  sig
    type cstr_t
    type tclist_t

    val new_ : unit -> t

    val adddouble : t -> cstr_t -> float -> float
    val addint : t -> cstr_t -> int -> int
    val close : t -> unit
    val copy : t -> string -> unit
    val fwmkeys : t -> ?max:int -> cstr_t -> tclist_t
    val get : t -> cstr_t -> cstr_t
    val iterinit : t -> unit
    val iternext : t -> cstr_t
    val misc : t -> string -> tclist_t -> tclist_t
    val open_ : t -> string -> unit
    val optimize : t -> ?params:string -> unit -> unit
    val out : t -> cstr_t -> unit
    val path : t -> string
    val put : t -> cstr_t -> cstr_t -> unit
    val putcat : t -> cstr_t -> cstr_t -> unit
    val putkeep : t -> cstr_t -> cstr_t -> unit
    val rnum : t -> int64
    val size : t -> int64
    val sync : t -> unit
    val tranabort : t -> unit
    val tranbegin : t -> unit
    val trancommit : t -> unit
    val vanish : t -> unit
    val vsiz : t -> cstr_t -> int
  end

  module Fun (Cs : Cstr_t) (Tcl : Tclist_t) =
  struct
    type cstr_t = Cs.t
    type tclist_t = Tcl.t

    external new_ : unit -> t = "otoky_adb_new"

    external _adddouble : t -> string -> int -> float -> float = "otoky_adb_adddouble"
    let adddouble t key num = _adddouble t (Cs.string key) (Cs.length key) num

    external _addint : t -> string -> int -> int -> int = "otoky_adb_addint"
    let addint t key num = _addint t (Cs.string key) (Cs.length key) num

    external close : t -> unit = "otoky_adb_close"
    external copy : t -> string -> unit = "otoky_adb_copy"

    external _fwmkeys : t -> ?max:int -> string -> int -> Tclist.t = "otoky_adb_fwmkeys"
    let fwmkeys t ?max prefix =
      let tclist = _fwmkeys t ?max (Cs.string prefix) (Cs.length prefix) in
      let r = Tcl.of_tclist tclist in
      if Tcl.del then Tclist.del tclist;
      r

    external _get : t -> string -> int -> Cstr.t = "otoky_adb_get"
    let get t key =
      let cstr = _get t (Cs.string key) (Cs.length key) in
      let r = Cs.of_cstr cstr in
      if Cs.del then Cstr.del cstr;
      r

    external iterinit : t -> unit = "otoky_adb_iterinit"

    external _iternext : t -> Cstr.t = "otoky_adb_iternext"
    let iternext t =
      let cstr = _iternext t in
      let r = Cs.of_cstr cstr in
      if Cs.del then Cstr.del cstr;
      r

    external _misc : t -> string -> Tclist.t -> Tclist.t = "otoky_adb_misc"
    let misc t name args =
      if Tcl.del
      then
        let args_tclist = Tcl.to_tclist args in
        let ret_tclist =
          try _misc t name args_tclist
          with e -> Tclist.del args_tclist; raise e in
        Tclist.del args_tclist;
        let r = Tcl.of_tclist ret_tclist in
        Tclist.del ret_tclist;
        r
      else
        Tcl.of_tclist (_misc t name (Tcl.to_tclist args))

    external open_ : t -> string -> unit = "otoky_adb_open"
    external optimize : t -> ?params:string -> unit -> unit = "otoky_adb_optimize"

    external _out : t -> string -> int -> unit = "otoky_adb_out"
    let out t key = _out t (Cs.string key) (Cs.length key)

    external path : t -> string = "otoky_adb_path"

    external _put : t -> string -> int -> string -> int -> unit = "otoky_adb_put"
    let put t key value = _put t (Cs.string key) (Cs.length key) (Cs.string value) (Cs.length value)

    external _putcat : t -> string -> int -> string -> int -> unit = "otoky_adb_putcat"
    let putcat t key value = _putcat t (Cs.string key) (Cs.length key) (Cs.string value) (Cs.length value)

    external _putkeep : t -> string -> int -> string -> int -> unit = "otoky_adb_putkeep"
    let putkeep t key value = _putkeep t (Cs.string key) (Cs.length key) (Cs.string value) (Cs.length value)

    external rnum : t -> int64 = "otoky_adb_rnum"
    external size : t -> int64 = "otoky_adb_size"
    external sync : t -> unit = "otoky_adb_sync"
    external tranabort : t -> unit = "otoky_adb_tranabort"
    external tranbegin : t -> unit = "otoky_adb_tranbegin"
    external trancommit : t -> unit = "otoky_adb_trancommit"
    external vanish : t -> unit = "otoky_adb_vanish"

    external _vsiz : t -> string -> int -> int = "otoky_adb_vsiz"
    let vsiz t key = _vsiz t (Cs.string key) (Cs.length key)
  end

  include Fun (Cstr_string) (Tclist_list)
end

module BDB =
struct
  type cmpfunc =
      | Cmp_lexical | Cmp_decimal | Cmp_int32 | Cmp_int64
      | Cmp_custom of (string -> string -> int) | Cmp_custom_cstr of (string -> int -> string -> int -> int)

  type t

  module type Sig =
  sig
    type cstr_t
    type tclist_t

    val new_ : unit -> t

    val adddouble : t -> cstr_t -> float -> float
    val addint : t -> cstr_t -> int -> int
    val close : t -> unit
    val copy : t -> string -> unit
    val fsiz : t -> int64
    val fwmkeys : t -> ?max:int -> cstr_t -> tclist_t
    val get : t -> cstr_t -> cstr_t
    val getlist : t -> cstr_t -> tclist_t
    val open_ : t -> ?omode:omode list -> string -> unit
    val optimize : t -> ?lmemb:int32 -> ?nmemb:int32 -> ?bnum:int64 -> ?apow:int -> ?fpow:int -> ?opts:opt list -> unit -> unit
    val out : t -> cstr_t -> unit
    val outlist : t -> cstr_t -> unit
    val path : t -> string
    val put : t -> cstr_t -> cstr_t -> unit
    val putcat : t -> cstr_t -> cstr_t -> unit
    val putdup : t -> cstr_t -> cstr_t -> unit
    val putkeep : t -> cstr_t -> cstr_t -> unit
    val putlist : t -> cstr_t -> tclist_t -> unit
    val range : t -> ?bkey:cstr_t -> ?binc:bool -> ?ekey:cstr_t -> ?einc:bool -> ?max:int -> unit -> tclist_t
    val rnum : t -> int64
    val setcache : t -> ?lcnum:int32 -> ?ncnum:int32 -> unit -> unit
    val setcmpfunc : t -> cmpfunc -> unit
    val setdfunit : t -> int32 -> unit
    val setxmsiz : t -> int64 -> unit
    val sync : t -> unit
    val tranabort : t -> unit
    val tranbegin : t -> unit
    val trancommit : t -> unit
    val tune : t -> ?lmemb:int32 -> ?nmemb:int32 -> ?bnum:int64 -> ?apow:int -> ?fpow:int -> ?opts:opt list -> unit -> unit
    val vanish : t -> unit
    val vnum : t -> cstr_t -> int
    val vsiz : t -> cstr_t -> int
  end

  module Fun (Cs : Cstr_t) (Tcl : Tclist_t) =
  struct
    type cstr_t = Cs.t
    type tclist_t = Tcl.t

    external new_ : unit -> t = "otoky_bdb_new"

    external _adddouble : t -> string -> int -> float -> float = "otoky_bdb_adddouble"
    let adddouble t key num = _adddouble t (Cs.string key) (Cs.length key) num

    external _addint : t -> string -> int -> int -> int = "otoky_bdb_addint"
    let addint t key num = _addint t (Cs.string key) (Cs.length key) num

    external close : t -> unit = "otoky_bdb_close"
    external copy : t -> string -> unit = "otoky_bdb_copy"
    external fsiz : t -> int64 = "otoky_bdb_fsiz"

    external _fwmkeys : t -> ?max:int -> string -> int -> Tclist.t = "otoky_bdb_fwmkeys"
    let fwmkeys t ?max prefix =
      let tclist = _fwmkeys t ?max (Cs.string prefix) (Cs.length prefix) in
      let r = Tcl.of_tclist tclist in
      if Tcl.del then Tclist.del tclist;
      r

    external _get : t -> string -> int -> Cstr.t = "otoky_bdb_get"
    let get t key =
      let cstr = _get t (Cs.string key) (Cs.length key) in
      let r = Cs.of_cstr cstr in
      if Cs.del then Cstr.del cstr;
      r

    external _getlist : t -> string -> int -> Tclist.t = "otoky_bdb_getlist"
    let getlist t key =
      let tclist = _getlist t (Cs.string key) (Cs.length key) in
      let r = Tcl.of_tclist tclist in
      if Tcl.del then Tclist.del tclist;
      r

    external open_ : t -> ?omode:omode list -> string -> unit = "otoky_bdb_open"
    external optimize :
      t -> ?lmemb:int32 -> ?nmemb:int32 -> ?bnum:int64 -> ?apow:int -> ?fpow:int -> ?opts:opt list -> unit -> unit =
          "otoky_bdb_optimize_bc" "otoky_bdb_optimize"

    external _out : t -> string -> int -> unit = "otoky_bdb_out"
    let out t key = _out t (Cs.string key) (Cs.length key)

    external _outlist : t -> string -> int -> unit = "otoky_bdb_outlist"
    let outlist t key = _outlist t (Cs.string key) (Cs.length key)

    external path : t -> string = "otoky_bdb_path"

    external _put : t -> string -> int -> string -> int -> unit = "otoky_bdb_put"
    let put t key value = _put t (Cs.string key) (Cs.length key) (Cs.string value) (Cs.length value)

    external _putcat : t -> string -> int -> string -> int -> unit = "otoky_bdb_putcat"
    let putcat t key value = _putcat t (Cs.string key) (Cs.length key) (Cs.string value) (Cs.length value)

    external _putdup : t -> string -> int -> string -> int -> unit = "otoky_bdb_putdup"
    let putdup t key value = _putdup t (Cs.string key) (Cs.length key) (Cs.string value) (Cs.length value)

    external _putkeep : t -> string -> int -> string -> int -> unit = "otoky_bdb_putkeep"
    let putkeep t key value = _putkeep t (Cs.string key) (Cs.length key) (Cs.string value) (Cs.length value)

    external _putlist : t -> string -> int -> Tclist.t -> unit = "otoky_bdb_putlist"
    let putlist t key vals =
      if Tcl.del
      then
        let vals_tclist = Tcl.to_tclist vals in
        begin
          try _putlist t (Cs.string key) (Cs.length key) vals_tclist
          with e -> Tclist.del vals_tclist; raise e
        end;
        Tclist.del vals_tclist
      else
        _putlist t (Cs.string key) (Cs.length key) (Tcl.to_tclist vals)

    external _range :
      t -> ?bkey:string -> blen:int -> ?binc:bool -> ?ekey:string -> elen:int -> ?einc:bool -> ?max:int -> unit -> Tclist.t =
      "otoky_bdb_range_bc" "otoky_bdb_range"
    let range t ?bkey ?binc ?ekey ?einc ?max () =
      let bkey, blen = match bkey with None -> None, -1 | Some key -> Some (Cs.string key), (Cs.length key) in
      let ekey, elen = match ekey with None -> None, -1 | Some key -> Some (Cs.string key), (Cs.length key) in
      let tclist = _range t ?bkey ~blen ?binc ?ekey ~elen ?einc ?max () in
      let r = Tcl.of_tclist tclist in
      if Tcl.del then Tclist.del tclist;
      r

    external rnum : t -> int64 = "otoky_bdb_rnum"
    external setcache : t -> ?lcnum:int32 -> ?ncnum:int32 -> unit -> unit = "otoky_bdb_setcache"
    external setcmpfunc : t -> cmpfunc -> unit = "otoky_bdb_setcmpfunc"
    external setdfunit : t -> int32 -> unit = "otoky_bdb_setdfunit"
    external setxmsiz : t -> int64 -> unit = "otoky_bdb_setxmsiz"

    external sync : t -> unit = "otoky_bdb_sync"
    external tranabort : t -> unit = "otoky_bdb_tranabort"
    external tranbegin : t -> unit = "otoky_bdb_tranbegin"
    external trancommit : t -> unit = "otoky_bdb_trancommit"
    external tune :
      t -> ?lmemb:int32 -> ?nmemb:int32 -> ?bnum:int64 -> ?apow:int -> ?fpow:int -> ?opts:opt list -> unit -> unit =
          "otoky_bdb_tune_bc" "otoky_bdb_tune"
    external vanish : t -> unit = "otoky_bdb_vanish"

    external _vnum : t -> string -> int -> int = "otoky_bdb_vnum"
    let vnum t key = _vnum t (Cs.string key) (Cs.length key)

    external _vsiz : t -> string -> int -> int = "otoky_bdb_vsiz"
    let vsiz t key = _vsiz t (Cs.string key) (Cs.length key)
  end

  include Fun (Cstr_string) (Tclist_list)
end

module BDBCUR =
struct
  type cpmode = Cp_current | Cp_before | Cp_after

  type t

  module type Sig =
  sig
    type cstr_t

    val new_ : BDB.t -> t

    val first : t -> unit
    val jump : t -> cstr_t -> unit
    val key : t -> cstr_t
    val last : t -> unit
    val next : t -> unit
    val out : t -> unit
    val prev : t -> unit
    val put : t -> ?cpmode:cpmode -> cstr_t -> unit
    val val_ : t -> cstr_t
  end

  module Fun (Cs : Cstr_t) =
  struct
    type cstr_t = Cs.t

    external new_ : BDB.t -> t = "otoky_bdbcur_new"

    external first : t -> unit = "otoky_bdbcur_first"

    external _jump : t -> string -> int -> unit = "otoky_bdbcur_jump"
    let jump t key = _jump t (Cs.string key) (Cs.length key)

    external _key : t -> Cstr.t = "otoky_bdbcur_key"
    let key t =
      let cstr = _key t in
      let r = Cs.of_cstr cstr in
      if Cs.del then Cstr.del cstr;
      r

    external last : t -> unit = "otoky_bdbcur_last"
    external next : t -> unit = "otoky_bdbcur_next"
    external out : t -> unit = "otoky_bdbcur_out"
    external prev : t -> unit = "otoky_bdbcur_prev"

    external _put : t -> ?cpmode:cpmode -> string -> int -> unit = "otoky_bdbcur_put"
    let put t ?cpmode val_ = _put t ?cpmode (Cs.string val_) (Cs.length val_)

    external _val : t -> Cstr.t = "otoky_bdbcur_val"
    let val_ t =
      let cstr = _val t in
      let r = Cs.of_cstr cstr in
      if Cs.del then Cstr.del cstr;
      r
  end

  include Fun (Cstr_string)
end

module FDB =
struct
  let id_min = -1L
  let id_prev = -2L
  let id_max = -3L
  let id_next = -4L

  type t

  module type Sig =
  sig
    type cstr_t

    val new_ : unit -> t

    val adddouble : t -> int64 -> float -> float
    val addint : t -> int64 -> int -> int
    val close : t -> unit
    val copy : t -> string -> unit
    val fsiz : t -> int64
    val get : t -> int64 -> cstr_t
    val iterinit : t -> unit
    val iternext : t -> int64
    val open_ : t -> ?omode:omode list -> string -> unit
    val optimize : t -> ?width:int32 -> ?limsiz:int64 -> unit -> unit
    val out : t -> int64 -> unit
    val path : t -> string
    val put : t -> int64 -> cstr_t -> unit
    val putcat : t -> int64 -> cstr_t -> unit
    val putkeep : t -> int64 -> cstr_t -> unit
    val range : t -> ?lower:int64 -> ?upper:int64 -> ?max:int -> unit -> int64 array
    val rnum : t -> int64
    val sync : t -> unit
    val tranabort : t -> unit
    val tranbegin : t -> unit
    val trancommit : t -> unit
    val tune : t -> ?width:int32 -> ?limsiz:int64 -> unit -> unit
    val vanish : t -> unit
    val vsiz : t -> int64 -> int

    val width : t -> int32
  end

  module Fun (Cs : Cstr_t) =
  struct
    type cstr_t = Cs.t

    external new_ : unit -> t = "otoky_fdb_new"

    external adddouble : t -> int64 -> float -> float = "otoky_fdb_adddouble"
    external addint : t -> int64 -> int -> int = "otoky_fdb_addint"

    external close : t -> unit = "otoky_fdb_close"
    external copy : t -> string -> unit = "otoky_fdb_copy"
    external fsiz : t -> int64 = "otoky_fdb_fsiz"

    external _get : t -> int64 -> Cstr.t = "otoky_fdb_get"
    let get t key =
      let cstr = _get t key in
      let r = Cs.of_cstr cstr in
      if Cs.del then Cstr.del cstr;
      r

    external iterinit : t -> unit = "otoky_fdb_iterinit"
    external iternext : t -> int64 = "otoky_fdb_iternext"
    external open_ : t -> ?omode:omode list -> string -> unit = "otoky_fdb_open"
    external optimize : t -> ?width:int32 -> ?limsiz:int64 -> unit -> unit = "otoky_fdb_optimize"
    external out : t -> int64 -> unit = "otoky_fdb_out"
    external path : t -> string = "otoky_fdb_path"

    external _put : t -> int64 -> string -> int -> unit = "otoky_fdb_put"
    let put t key value = _put t key (Cs.string value) (Cs.length value)

    external _putcat : t -> int64 -> string -> int -> unit = "otoky_fdb_putcat"
    let putcat t key value = _putcat t key (Cs.string value) (Cs.length value)

    external _putkeep : t -> int64 -> string -> int -> unit = "otoky_fdb_putkeep"
    let putkeep t key value = _putkeep t key (Cs.string value) (Cs.length value)

    external range : t -> ?lower:int64 -> ?upper:int64 -> ?max:int -> unit -> int64 array = "otoky_fdb_range"
    external rnum : t -> int64 = "otoky_fdb_rnum"
    external sync : t -> unit = "otoky_fdb_sync"
    external tranabort : t -> unit = "otoky_fdb_tranabort"
    external tranbegin : t -> unit = "otoky_fdb_tranbegin"
    external trancommit : t -> unit = "otoky_fdb_trancommit"
    external tune : t -> ?width:int32 -> ?limsiz:int64 -> unit -> unit = "otoky_fdb_tune"
    external vanish : t -> unit = "otoky_fdb_vanish"
    external vsiz : t -> int64 -> int = "otoky_fdb_vsiz"

    external width : t -> int32 = "otoky_fdb_width"
  end

  include Fun (Cstr_string)
end

module HDB =
struct
  type t

  module type Sig =
  sig
    type cstr_t
    type tclist_t

    val new_ : unit -> t

    val adddouble : t -> cstr_t -> float -> float
    val addint : t -> cstr_t -> int -> int
    val close : t -> unit
    val copy : t -> string -> unit
    val fsiz : t -> int64
    val fwmkeys : t -> ?max:int -> cstr_t -> tclist_t
    val get : t -> cstr_t -> cstr_t
    val iterinit : t -> unit
    val iternext : t -> cstr_t
    val open_ : t -> ?omode:omode list -> string -> unit
    val optimize : t -> ?bnum:int64 -> ?apow:int -> ?fpow:int -> ?opts:opt list -> unit -> unit
    val out : t -> cstr_t -> unit
    val path : t -> string
    val put : t -> cstr_t -> cstr_t -> unit
    val putasync : t -> cstr_t -> cstr_t -> unit
    val putcat : t -> cstr_t -> cstr_t -> unit
    val putkeep : t -> cstr_t -> cstr_t -> unit
    val rnum : t -> int64
    val setcache : t -> int32 -> unit
    val setdfunit : t -> int32 -> unit
    val setxmsiz : t -> int64 -> unit
    val sync : t -> unit
    val tranabort : t -> unit
    val tranbegin : t -> unit
    val trancommit : t -> unit
    val tune : t -> ?bnum:int64 -> ?apow:int -> ?fpow:int -> ?opts:opt list -> unit -> unit
    val vanish : t -> unit
    val vsiz : t -> cstr_t -> int
  end

  module Fun (Cs : Cstr_t) (Tcl : Tclist_t) =
  struct
    type cstr_t = Cs.t
    type tclist_t = Tcl.t

    external new_ : unit -> t = "otoky_hdb_new"

    external _adddouble : t -> string -> int -> float -> float = "otoky_hdb_adddouble"
    let adddouble t key num = _adddouble t (Cs.string key) (Cs.length key) num

    external _addint : t -> string -> int -> int -> int = "otoky_hdb_addint"
    let addint t key num = _addint t (Cs.string key) (Cs.length key) num

    external close : t -> unit = "otoky_hdb_close"
    external copy : t -> string -> unit = "otoky_hdb_copy"
    external fsiz : t -> int64 = "otoky_hdb_fsiz"

    external _fwmkeys : t -> ?max:int -> string -> int -> Tclist.t = "otoky_hdb_fwmkeys"
    let fwmkeys t ?max prefix =
      let tclist = _fwmkeys t ?max (Cs.string prefix) (Cs.length prefix) in
      let r = Tcl.of_tclist tclist in
      if Tcl.del then Tclist.del tclist;
      r

    external _get : t -> string -> int -> Cstr.t = "otoky_hdb_get"
    let get t key =
      let cstr = _get t (Cs.string key) (Cs.length key) in
      let r = Cs.of_cstr cstr in
      if Cs.del then Cstr.del cstr;
      r

    external iterinit : t -> unit = "otoky_hdb_iterinit"

    external _iternext : t -> Cstr.t = "otoky_hdb_iternext"
    let iternext t =
      let cstr = _iternext t in
      let r = Cs.of_cstr cstr in
      if Cs.del then Cstr.del cstr;
      r

    external open_ : t -> ?omode:omode list -> string -> unit = "otoky_hdb_open"
    external optimize :
      t -> ?bnum:int64 -> ?apow:int -> ?fpow:int -> ?opts:opt list -> unit -> unit =
          "otoky_hdb_optimize_bc" "otoky_hdb_optimize"

    external _out : t -> string -> int -> unit = "otoky_hdb_out"
    let out t key = _out t (Cs.string key) (Cs.length key)

    external path : t -> string = "otoky_hdb_path"

    external _put : t -> string -> int -> string -> int -> unit = "otoky_hdb_put"
    let put t key value = _put t (Cs.string key) (Cs.length key) (Cs.string value) (Cs.length value)

    external _putasync : t -> string -> int -> string -> int -> unit = "otoky_hdb_putasync"
    let putasync t key value = _putasync t (Cs.string key) (Cs.length key) (Cs.string value) (Cs.length value)

    external _putcat : t -> string -> int -> string -> int -> unit = "otoky_hdb_putcat"
    let putcat t key value = _putcat t (Cs.string key) (Cs.length key) (Cs.string value) (Cs.length value)

    external _putkeep : t -> string -> int -> string -> int -> unit = "otoky_hdb_putkeep"
    let putkeep t key value = _putkeep t (Cs.string key) (Cs.length key) (Cs.string value) (Cs.length value)

    external rnum : t -> int64 = "otoky_hdb_rnum"

    external setcache : t -> int32 -> unit = "otoky_hdb_setcache"
    external setdfunit : t -> int32 -> unit = "otoky_hdb_setdfunit"
    external setxmsiz : t -> int64 -> unit = "otoky_hdb_setxmsiz"

    external sync : t -> unit = "otoky_hdb_sync"
    external tranabort : t -> unit = "otoky_hdb_tranabort"
    external tranbegin : t -> unit = "otoky_hdb_tranbegin"
    external trancommit : t -> unit = "otoky_hdb_trancommit"
    external tune :
      t -> ?bnum:int64 -> ?apow:int -> ?fpow:int -> ?opts:opt list -> unit -> unit =
          "otoky_hdb_tune_bc" "otoky_hdb_tune"
    external vanish : t -> unit = "otoky_hdb_vanish"

    external _vsiz : t -> string -> int -> int = "otoky_hdb_vsiz"
    let vsiz t key = _vsiz t (Cs.string key) (Cs.length key)
  end

  include Fun (Cstr_string) (Tclist_list)
end

module TDB =
struct
  type itype = It_lexical | It_decimal | It_token | It_qgram | It_opt | It_void

  type t

  module type Sig =
  sig
    type cstr_t
    type tclist_t
    type tcmap_t

    val new_ : unit -> t

    val adddouble : t -> cstr_t -> float -> float
    val addint : t -> cstr_t -> int -> int
    val close : t -> unit
    val copy : t -> string -> unit
    val fsiz : t -> int64
    val fwmkeys : t -> ?max:int -> cstr_t -> tclist_t
    val genuid : t -> int64
    val get : t -> cstr_t -> tcmap_t
    val iterinit : t -> unit
    val iternext : t -> cstr_t
    val open_ : t -> ?omode:omode list -> string -> unit
    val optimize : t -> ?bnum:int64 -> ?apow:int -> ?fpow:int -> ?opts:opt list -> unit -> unit
    val out : t -> cstr_t -> unit
    val path : t -> string
    val put : t -> cstr_t -> tcmap_t -> unit
    val putcat : t -> cstr_t -> tcmap_t -> unit
    val putkeep : t -> cstr_t -> tcmap_t -> unit
    val rnum : t -> int64
    val setcache : t -> ?rcnum:int32 -> ?lcnum:int32 -> ?ncnum:int32 -> unit -> unit
    val setdfunit : t -> int32 -> unit
    val setindex : t -> string -> ?keep:bool -> itype -> unit
    val setxmsiz : t -> int64 -> unit
    val sync : t -> unit
    val tranabort : t -> unit
    val tranbegin : t -> unit
    val trancommit : t -> unit
    val tune : t -> ?bnum:int64 -> ?apow:int -> ?fpow:int -> ?opts:opt list -> unit -> unit
    val vanish : t -> unit
    val vsiz : t -> cstr_t -> int
  end

  module Fun (Cs : Cstr_t) (Tcl : Tclist_t) (Tcm : Tcmap_t) =
  struct
    type cstr_t = Cs.t
    type tclist_t = Tcl.t
    type tcmap_t = Tcm.t

    external new_ : unit -> t = "otoky_tdb_new"

    external _adddouble : t -> string -> int -> float -> float = "otoky_tdb_adddouble"
    let adddouble t key num = _adddouble t (Cs.string key) (Cs.length key) num

    external _addint : t -> string -> int -> int -> int = "otoky_tdb_addint"
    let addint t key num = _addint t (Cs.string key) (Cs.length key) num

    external close : t -> unit = "otoky_tdb_close"
    external copy : t -> string -> unit = "otoky_tdb_copy"
    external fsiz : t -> int64 = "otoky_tdb_fsiz"

    external _fwmkeys : t -> ?max:int -> string -> int -> Tclist.t = "otoky_tdb_fwmkeys"
    let fwmkeys t ?max prefix =
      let tclist = _fwmkeys t ?max (Cs.string prefix) (Cs.length prefix) in
      let r = Tcl.of_tclist tclist in
      if Tcl.del then Tclist.del tclist;
      r

    external genuid : t -> int64 = "otoky_tdb_genuid"

    external _get : t -> string -> int -> Tcmap.t = "otoky_tdb_get"
    let get t key =
      let tcmap = _get t (Cs.string key) (Cs.length key) in
      let r = Tcm.of_tcmap tcmap in
      if Tcm.del then Tcmap.del tcmap;
      r

    external iterinit : t -> unit = "otoky_tdb_iterinit"

    external _iternext : t -> Cstr.t = "otoky_tdb_iternext"
    let iternext t =
      let cstr = _iternext t in
      let r = Cs.of_cstr cstr in
      if Cs.del then Cstr.del cstr;
      r

    external open_ : t -> ?omode:omode list -> string -> unit = "otoky_tdb_open"

    external optimize :
      t -> ?bnum:int64 -> ?apow:int -> ?fpow:int -> ?opts:opt list -> unit -> unit =
          "otoky_tdb_optimize_bc" "otoky_tdb_optimize"

    external _out : t -> string -> int -> unit = "otoky_tdb_out"
    let out t key = _out t (Cs.string key) (Cs.length key)

    external path : t -> string = "otoky_tdb_path"

    external _put : t -> string -> int -> Tcmap.t -> unit = "otoky_tdb_put"
    let put t pkey cols =
      if Tcm.del
      then
        let cols_tcmap = Tcm.to_tcmap cols in
        begin
          try _put t (Cs.string pkey) (Cs.length pkey) cols_tcmap
          with e -> Tcmap.del cols_tcmap; raise e
        end;
        Tcmap.del cols_tcmap
      else
        _put t (Cs.string pkey) (Cs.length pkey) (Tcm.to_tcmap cols)

    external _putcat : t -> string -> int -> Tcmap.t -> unit = "otoky_tdb_putcat"
    let putcat t pkey cols =
      if Tcm.del
      then
        let cols_tcmap = Tcm.to_tcmap cols in
        begin
          try _putcat t (Cs.string pkey) (Cs.length pkey) cols_tcmap
          with e -> Tcmap.del cols_tcmap; raise e
        end;
        Tcmap.del cols_tcmap
      else
        _putcat t (Cs.string pkey) (Cs.length pkey) (Tcm.to_tcmap cols)

    external _putkeep : t -> string -> int -> Tcmap.t -> unit = "otoky_tdb_putkeep"
    let putkeep t pkey cols =
      if Tcm.del
      then
        let cols_tcmap = Tcm.to_tcmap cols in
        begin
          try _putkeep t (Cs.string pkey) (Cs.length pkey) cols_tcmap
          with e -> Tcmap.del cols_tcmap; raise e
        end;
        Tcmap.del cols_tcmap
      else
        _putkeep t (Cs.string pkey) (Cs.length pkey) (Tcm.to_tcmap cols)

    external rnum : t -> int64 = "otoky_tdb_rnum"

    external setcache : t -> ?rcnum:int32 -> ?lcnum:int32 -> ?ncnum:int32 -> unit -> unit = "otoky_tdb_setcache"
    external setdfunit : t -> int32 -> unit = "otoky_tdb_setdfunit"
    external setindex : t -> string -> ?keep:bool -> itype -> unit = "otoky_tdb_setindex"
    external setxmsiz : t -> int64 -> unit = "otoky_tdb_setxmsiz"

    external sync : t -> unit = "otoky_tdb_sync"
    external tranabort : t -> unit = "otoky_tdb_tranabort"
    external tranbegin : t -> unit = "otoky_tdb_tranbegin"
    external trancommit : t -> unit = "otoky_tdb_trancommit"
    external tune :
      t -> ?bnum:int64 -> ?apow:int -> ?fpow:int -> ?opts:opt list -> unit -> unit =
          "otoky_tdb_tune_bc" "otoky_tdb_tune"
    external vanish : t -> unit = "otoky_tdb_vanish"

    external _vsiz : t -> string -> int -> int = "otoky_tdb_vsiz"
    let vsiz t pkey = _vsiz t (Cs.string pkey) (Cs.length pkey)
  end

  include Fun (Cstr_string) (Tclist_list) (Tcmap_list)
end

module TDBQRY =
struct
  type qcond =
      | Qc_streq | Qc_strinc | Qc_strbw | Qc_strew | Qc_strand | Qc_stror | Qc_stroreq | Qc_strrx
      | Qc_numeq | Qc_numgt | Qc_numge | Qc_numlt | Qc_numle | Qc_numbt | Qc_numoreq
      | Qc_ftsph | Qc_ftsand | Qc_ftsor | Qc_ftsex

  type qord = Qo_strasc | Qo_strdesc | Qo_numasc | Qo_numdesc

  type qpost = Qp_put | Qp_out | Qp_stop

  type msetop = Ms_union | Ms_isect | Ms_diff

  type kopt = Kw_mutab | Kw_muctrl | Kw_mubrct | Kw_noover | Kw_pulead

  type t

  module type Sig =
  sig
    type tclist_t
    type tcmap_t

    val new_ : TDB.t -> t
    val metasearch : ?setop:msetop -> t list -> tclist_t

    val addcond : t -> string -> ?negate:bool -> ?noidx:bool -> qcond -> string -> unit
    val hint : t -> string
    val kwic : t -> ?name:string -> ?width:int -> ?opts:kopt list -> tcmap_t -> tclist_t
    val proc : t -> (string -> tcmap_t ref -> qpost list) -> unit
    val search : t -> tclist_t
    val searchout : t -> unit
    val setlimit : t -> ?max:int -> ?skip:int -> unit -> unit
    val setorder : t -> ?qord:qord -> string -> unit
  end

  module Fun (Tcl : Tclist_t) (Tcm : Tcmap_t) =
  struct
    type tclist_t = Tcl.t
    type tcmap_t = Tcm.t

    external new_ : TDB.t -> t = "otoky_tdbqry_new"

    external addcond : t -> string -> ?negate:bool -> ?noidx:bool -> qcond -> string -> unit =
        "otoky_tdbqry_addcond_bc" "otoky_tdbqry_addcond"
    external hint : t -> string = "otoky_tdbqry_hint"

    external _kwic : t -> ?name:string -> ?width:int -> ?opts:kopt list -> Tcmap.t -> Tclist.t = "otoky_tdbqry_kwic"
    let kwic t ?name ?width ?opts cols =
      let tclist =
        if Tcm.del
        then
          let cols_tcmap = Tcm.to_tcmap cols in
          let tclist =
            try _kwic t ?name ?width ?opts cols_tcmap
            with e -> Tcmap.del cols_tcmap; raise e in
          Tcmap.del cols_tcmap;
          tclist
        else
          _kwic t ?name ?width ?opts (Tcm.to_tcmap cols) in
      let r = Tcl.of_tclist tclist in
      if Tcl.del then Tclist.del tclist;
      r

    external _metasearch : ?setop:msetop -> t list -> Tclist.t = "otoky_tdbqry_metasearch"
    let metasearch ?setop qrys =
      let tclist = _metasearch ?setop qrys in
      let r = Tcl.of_tclist tclist in
      if Tcl.del then Tclist.del tclist;
      r

    external _proc : t -> (string -> Tcmap.t -> qpost list) -> unit = "otoky_tdbqry_proc"
    let proc t func =
      _proc t begin fun key tcmap ->
        let cols = ref (Tcm.of_tcmap tcmap) in
        let qposts = func key cols in
        if List.mem Qp_put qposts
        then Tcm.replace_tcmap !cols tcmap;
        qposts
      end

    external _search : t -> Tclist.t = "otoky_tdbqry_search"
    let search t =
      let tclist = _search t in
      let r = Tcl.of_tclist tclist in
      if Tcl.del then Tclist.del tclist;
      r

    external searchout : t -> unit = "otoky_tdbqry_searchout"
    external setlimit : t -> ?max:int -> ?skip:int -> unit -> unit = "otoky_tdbqry_setlimit"
    external setorder : t -> ?qord:qord -> string -> unit = "otoky_tdbqry_setorder"
  end

  include Fun (Tclist_list) (Tcmap_list)
end
