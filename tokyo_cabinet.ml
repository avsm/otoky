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

exception Error of error * string

type omode = Oreader | Owriter | Ocreat | Otrunc | Onolck | Olcknb | Otsync

type opt = Tlarge | Tdeflate | Tbzip | Ttcbs

module ADB =
struct
  type t

  external new_ : unit -> t = "otoky_adb_new"

  external adddouble : t -> string -> float -> float = "otoky_adb_adddouble"
  external addint : t -> string -> int -> int = "otoky_adb_addint"
  external close : t -> unit = "otoky_adb_close"
  external copy : t -> string -> unit = "otoky_adb_copy"
  external fwmkeys : t -> ?max:int -> string -> string list = "otoky_adb_fwmkeys"
  let get t key = failwith "unimplemented"
  let iterinit t = failwith "unimplemented"
  let iternext t = failwith "unimplemented"
  let misc t name args = failwith "unimplemented"
  let open_ t name = failwith "unimplemented"
  let optimize t params = failwith "unimplemented"
  let out t key = failwith "unimplemented"
  let path t = failwith "unimplemented"
  let put t key value = failwith "unimplemented"
  let putcat t key value = failwith "unimplemented"
  let putkeep t key value = failwith "unimplemented"
  let rnum t = failwith "unimplemented"
  let size t = failwith "unimplemented"
  let sync t = failwith "unimplemented"
  let tranabort t = failwith "unimplemented"
  let tranbegin t = failwith "unimplemented"
  let trancommit t = failwith "unimplemented"
  let vanish t = failwith "unimplemented"
  let vsiz t key = failwith "unimplemented"
end

module BDB =
struct
  type cmpfunc = Cmp_lexical | Cmp_decimal | Cmp_int32 | Cmp_int64 | Cmp_custom of (string -> string -> int)

  type t

  let new_ () = failwith "unimplemented"

  let adddouble t key num = failwith "unimplemented"
  let addint t key num = failwith "unimplemented"
  let close t = failwith "unimplemented"
  let copy t path = failwith "unimplemented"
  let fsiz t = failwith "unimplemented"
  let fwmkeys t ?max prefix = failwith "unimplemented"
  let get t key = failwith "unimplemented"
  let getlist t key = failwith "unimplemented"
  let open_ t ?mode path = failwith "unimplemented"
  let optimize t ?lmemb ?nmemb ?bnum ?apow ?fpow ?opts () = failwith "unimplemented"
  let out t key = failwith "unimplemented"
  let outlist t key = failwith "unimplemented"
  let path t = failwith "unimplemented"
  let put t key value = failwith "unimplemented"
  let putcat t key value = failwith "unimplemented"
  let putdup t key value = failwith "unimplemented"
  let putkeep t key value = failwith "unimplemented"
  let putlist t key value = failwith "unimplemented"
  let range t ?bkey ?binc ?ekey ?einc ?max = failwith "unimplemented"
  let rnum t = failwith "unimplemented"
  let setcache t ?lcnum ?ncnum () = failwith "unimplemented"
  let setcmpfunc t cmp = failwith "unimplemented"
  let setdfunit t dfunit = failwith "unimplemented"
  let setxmsiz t xmsiz = failwith "unimplemented"
  let sync t = failwith "unimplemented"
  let tranabort t = failwith "unimplemented"
  let tranbegin t = failwith "unimplemented"
  let trancommit t = failwith "unimplemented"
  let tune t ?lmemb ?nmemb ?bnum ?apow ?fpow ?opts () = failwith "unimplemented"
  let vanish t = failwith "unimplemented"
  let vnum t key = failwith "unimplemented"
  let vsiz t key = failwith "unimplemented"
end

module BDBCUR =
struct
  type cpmode = Cp_current | Cp_before | Cp_after

  type t

  let new_ bdb = failwith "unimplemented"

  let first t = failwith "unimplemented"
  let jump t key = failwith "unimplemented"
  let key t = failwith "unimplemented"
  let last t = failwith "unimplemented"
  let next t = failwith "unimplemented"
  let out t = failwith "unimplemented"
  let prev t = failwith "unimplemented"
  let put t value cpmode = failwith "unimplemented"
  let val_ t = failwith "unimplemented"
end

module FDB =
struct
  let id_min = -1L
  let id_prev = -2L
  let id_max = -3L
  let id_next = -4L

  type t

  let new_ () = failwith "unimplemented"

  let adddouble t key num = failwith "unimplemented"
  let addint t key num = failwith "unimplemented"
  let close t = failwith "unimplemented"
  let copy t path = failwith "unimplemented"
  let fsiz t = failwith "unimplemented"
  let get t key = failwith "unimplemented"
  let iterinit t = failwith "unimplemented"
  let iternext t = failwith "unimplemented"
  let open_ t ?omode path = failwith "unimplemented"
  let optimize t ?width ?limsiz () = failwith "unimplemented"
  let out t key = failwith "unimplemented"
  let path t  = failwith "unimplemented"
  let put t key value = failwith "unimplemented"
  let putcat t key value = failwith "unimplemented"
  let putkeep t key value = failwith "unimplemented"
  let range t ?max interval = failwith "unimplemented"
  let rnum t = failwith "unimplemented"
  let sync t = failwith "unimplemented"
  let tranabort t = failwith "unimplemented"
  let tranbegin t = failwith "unimplemented"
  let trancommit t = failwith "unimplemented"
  let tune t ?width ?limsiz () = failwith "unimplemented"
  let vanish t = failwith "unimplemented"
  let vsiz t key = failwith "unimplemented"
end

module HDB =
struct
  type t

  let new_ () = failwith "unimplemented"

  let adddouble t key num = failwith "unimplemented"
  let addint t key num = failwith "unimplemented"
  let close t = failwith "unimplemented"
  let copy t path = failwith "unimplemented"
  let fsiz t = failwith "unimplemented"
  let fwmkeys t ?max prefix = failwith "unimplemented"
  let get t key = failwith "unimplemented"
  let iterinit t = failwith "unimplemented"
  let iternext t = failwith "unimplemented"
  let open_ t ?omode path = failwith "unimplemented"
  let optimize t ?bnum ?apow ?fpow ?opts () = failwith "unimplemented"
  let out t key = failwith "unimplemented"
  let path t = failwith "unimplemented"
  let put t key value = failwith "unimplemented"
  let putasync t key value = failwith "unimplemented"
  let putcat t key value = failwith "unimplemented"
  let putkeep t key value = failwith "unimplemented"
  let rnum t = failwith "unimplemented"
  let setcache t rcnum = failwith "unimplemented"
  let setdfunit t dfunit = failwith "unimplemented"
  let setxmsiz t xmsiz = failwith "unimplemented"
  let sync t = failwith "unimplemented"
  let tranabort t = failwith "unimplemented"
  let tranbegin t = failwith "unimplemented"
  let trancommit t = failwith "unimplemented"
  let tune t ?bnum ?apow ?fpow ?opts () = failwith "unimplemented"
  let vanish t = failwith "unimplemented"
  let vsiz t key = failwith "unimplemented"
end

module TDB =
struct
  type itype = It_lexical | It_decimal | It_token | It_qgram | It_opt | It_void | It_keep

  type t

  let new_ () = failwith "unimplemented"

  let adddouble t pkey num = failwith "unimplemented"
  let addint t pkey num = failwith "unimplemented"
  let close t = failwith "unimplemented"
  let copy t path = failwith "unimplemented"
  let fsiz t = failwith "unimplemented"
  let fwmkeys t ?max prefix = failwith "unimplemented"
  let genuid t = failwith "unimplemented"
  let get t pkey = failwith "unimplemented"
  let iterinit t = failwith "unimplemented"
  let iternext t = failwith "unimplemented"
  let open_ t ?omode path = failwith "unimplemented"
  let optimize t ?bnum ?apow ?fpow ?opts () = failwith "unimplemented"
  let out t pkey = failwith "unimplemented"
  let path t = failwith "unimplemented"
  let put t pkey cols = failwith "unimplemented"
  let putcat t pkey cols = failwith "unimplemented"
  let putkeep t pkey cols = failwith "unimplemented"
  let rnum t = failwith "unimplemented"
  let setcache t ?rcnum ?lcnum ?ncnum () = failwith "unimplemented"
  let setdfunit t dfunit = failwith "unimplemented"
  let setindex t name itype = failwith "unimplemented"
  let setxmsiz t xmsiz = failwith "unimplemented"
  let sync t = failwith "unimplemented"
  let tranabort t = failwith "unimplemented"
  let tranbegin t = failwith "unimplemented"
  let trancommit t = failwith "unimplemented"
  let tune t ?bnum ?apow ?fpow ?opts () = failwith "unimplemented"
  let vanish t = failwith "unimplemented"
  let vsiz t pkey = failwith "unimplemented"
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

  let new_ tdb = failwith "unimplemented"

  let addcond t name ?negate ?noidx op expr = failwith "unimplemented"
  let hint t = failwith "unimplemented"
  let kwic t ?name ?width ?opts cols = failwith "unimplemented"
  let metasearch t ?setop others = failwith "unimplemented"
  let proc t func = failwith "unimplemented"
  let search t = failwith "unimplemented"
  let searchout t = failwith "unimplemented"
  let setlimit t ?max ?skip () = failwith "unimplemented"
  let setorder t string qord = failwith "unimplemented"
end