#include <string.h>
#include <stdarg.h>

#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/signals.h>
#include <caml/bigarray.h>

#include <tcadb.h>



#define int_option(v) ((v == Val_int(0)) ? -1 : Int_val(Field(v, 0)))
#define int32_option(v) ((v == Val_int(0)) ? (int32)-1 : Int32_val(Field(v, 0)))



CAMLprim
value otoky_cstr_del(value vcstr)
{
  tcfree((void *)Field(vcstr, 0));
  return Val_unit;
}

CAMLprim
value otoky_cstr_to_bigarray(value vcstr)
{
  intnat dims[1] = { Int_val(Field(vcstr, 1)) };
  return caml_ba_alloc(CAML_BA_C_LAYOUT | CAML_BA_UINT8,
                       1,
                       (void *)Field(vcstr, 0),
                       dims);
}

CAMLprim
value otoky_cstr_of_bigarray(value vlen, value vba)
{
  CAMLparam1(vba);

  value vpair = caml_alloc_tuple(3);
  Field(vpair, 0) = (value)Caml_ba_data_val(vba);
  Field(vpair, 1) = vlen == Val_int(0) ? Val_int(Caml_ba_array_val(vba)->dim[0]) : Field(vlen, 0);

  /*
    wow, this is a dirty hack. if we don't hang on to the Bigarray
    pointer it might be gc'd, freeing the data the Cstr.t points
    to. we don't otherwise need it. code expecting a pair doesn't care
    if there's an extra field, although if the parts are copied to a
    new pair we'd lose the Bigarray.

    we could make this field explicit in Cstr.t, but the typing is
    weird--we don't care about it, we can't use it, we don't want to
    know about it. it should have existential type.

    we could make Cstr.t an object (or pair of functions) so
    implementations could use whatever underlying type they lik, but
    it is supposed to be lightweight.

    we could replace Cstr.t with Bigarray. but it is supposed to be
    lightweight, and that would overcommit the interface.

    we could make client code be responsible for the lifetime of the
    Bigarray, but this hairs up the interface--e.g. a marshaller would
    need to return a Cstr.t plus a cleanup function, or something.
  */
  Field(vpair, 2) = vba;

  CAMLreturn(vpair);
}



CAMLprim
TCLIST *otoky_tclist_new(value vanum, value vunit)
{
  int anum = int_option(vanum);
  TCLIST *tclist;
  if (anum == -1)
    tclist = tclistnew();
  else
    tclist = tclistnew2(anum);
  return tclist;
}

CAMLprim
value otoky_tclist_del(TCLIST *tclist)
{
  tclistdel(tclist);
  return Val_unit;
}

CAMLprim
value otoky_tclist_num(TCLIST *tclist)
{
  return Val_int(tclistnum(tclist));
}

CAMLprim
const void *otoky_tclist_val(TCLIST *tclist, value vindex, value vlen)
{
  int len;
  const void *val = tclistval(tclist, Int_val(vindex), &len);
  Field(vlen, 0) = Val_int(len);
  return val;
}

CAMLprim
value otoky_tclist_push(TCLIST *tclist, value vstring, value vlen)
{
  tclistpush(tclist, String_val(vstring), Int_val(vlen));
  return Val_unit;
}

CAMLprim
value otoky_tclist_lsearch(TCLIST *tclist, value vstring, value vlen)
{
  return Val_int(tclistlsearch(tclist, String_val(vstring), Int_val(vlen)));
}

CAMLprim
value otoky_tclist_bsearch(TCLIST *tclist, value vstring, value vlen)
{
  return Val_int(tclistbsearch(tclist, String_val(vstring), Int_val(vlen)));
}



CAMLprim
TCMAP *otoky_tcmap_new(value vbnum, value vunit)
{
  int32 bnum = int32_option(vbnum);
  TCMAP *tcmap;
  if (bnum == -1)
    tcmap = tcmapnew();
  else
    tcmap = tcmapnew2(bnum);
  return tcmap;
}

CAMLprim
value otoky_tcmap_clear(TCMAP *tcmap)
{
  tcmapclear(tcmap);
  return Val_unit;
}

CAMLprim
value otoky_tcmap_del(TCMAP *tcmap)
{
  tcmapdel(tcmap);
  return Val_unit;
}

CAMLprim
value otoky_tcmap_put(TCMAP *tcmap, value vkey, value vkeylen, value vval, value vvallen)
{
  tcmapput(tcmap, String_val(vkey), Int_val(vkeylen), String_val(vval), Int_val(vvallen));
  return Val_unit;
}

CAMLprim
value otoky_tcmap_putcat(TCMAP *tcmap, value vkey, value vkeylen, value vval, value vvallen)
{
  tcmapputcat(tcmap, String_val(vkey), Int_val(vkeylen), String_val(vval), Int_val(vvallen));
  return Val_unit;
}

CAMLprim
value otoky_tcmap_putkeep(TCMAP *tcmap, value vkey, value vkeylen, value vval, value vvallen)
{
  tcmapputkeep(tcmap, String_val(vkey), Int_val(vkeylen), String_val(vval), Int_val(vvallen));
  return Val_unit;
}

CAMLprim
value otoky_tcmap_out(TCMAP *tcmap, value vkey, value vlen)
{
  tcmapout(tcmap, String_val(vkey), Int_val(vlen));
  return Val_unit;
}

CAMLprim
const void *otoky_tcmap_get(TCMAP *tcmap, value vkey, value vkeylen, value vvallen)
{
  int vallen;
  const void *val = tcmapget(tcmap, String_val(vkey), Int_val(vkeylen), &vallen);
  if (!val) caml_raise_not_found();
  Field(vvallen, 0) = Val_int(vallen);
  return val;
}

CAMLprim
value otoky_tcmap_iterinit(TCMAP *tcmap)
{
  tcmapiterinit(tcmap);
  return Val_unit;
}

CAMLprim
const void *otoky_tcmap_iternext(TCMAP *tcmap, value vlen)
{
  int len;
  const void *val = tcmapiternext(tcmap, &len);
  if (!val) caml_raise_not_found();
  Field(vlen, 0) = Val_int(len);
  return val;
}

CAMLprim
value otoky_tcmap_rnum(TCMAP *tcmap)
{
  return caml_copy_int64(tcmaprnum(tcmap));
}

CAMLprim
value otoky_tcmap_msiz(TCMAP *tcmap)
{
  return caml_copy_int64(tcmapmsiz(tcmap));
}

CAMLprim
TCLIST *otoky_tcmap_keys(TCMAP *tcmap)
{
  return tcmapkeys(tcmap);
}

CAMLprim
TCLIST *otoky_tcmap_vals(TCMAP *tcmap)
{
  return tcmapvals(tcmap);
}
