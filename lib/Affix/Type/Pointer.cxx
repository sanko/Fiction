#include "../../Affix.h"

XS_INTERNAL(Affix_cast) {
    dVAR;
    dXSARGS;
    PING;
    if (items != 2) croak_xs_usage(cv, "pointer, type");
    if (UNLIKELY(!sv_derived_from(ST(0), "Affix::Type")))
        croak("type is not of type Affix::Type::Pointer");

    SV *const xsub_tmp_sv = ST(0);
    SvGETMAGIC(xsub_tmp_sv);

    {
        AV *RETVALAV = newAV();
        {
            SV *TMP = newSV(0);
            DCpointer ptr = sv2ptr(aTHX_ ST(0), xsub_tmp_sv);
            if (ptr != NULL) DumpHex(ptr, 16);
            sv_setref_pv(TMP, NULL, ptr);
            av_store(RETVALAV, SLOT_POINTER_ADDR, TMP);
            av_store(RETVALAV, SLOT_POINTER_SUBTYPE, newSVsv(ST(1)));
            av_store(RETVALAV, SLOT_POINTER_COUNT, newSViv(1));
            av_store(RETVALAV, SLOT_POINTER_POSITION, newSViv(0));
        }
        SV *RETVAL = newRV_noinc(MUTABLE_SV(RETVALAV)); // Create a reference to the AV
        sv_bless(RETVAL, gv_stashpvn("Affix::Pointer::Unmanaged", 25, GV_ADD));
        ST(0) = sv_2mortal(RETVAL);
    }
    XSRETURN(1);
}

XS_INTERNAL(Affix_sv2ptr) {
    dVAR;
    dXSARGS;
    PING;
    if (items != 2) croak_xs_usage(cv, "type, data");
    if (UNLIKELY(!sv_derived_from(ST(0), "Affix::Type::Pointer")))
        croak("type is not of type Affix::Type::Pointer");

    SV *const xsub_tmp_sv = ST(1);
    SvGETMAGIC(xsub_tmp_sv);

    {
        AV *RETVALAV = newAV();
        {
            SV *TMP = newSV(0);
            DCpointer ptr = sv2ptr(aTHX_ ST(0), xsub_tmp_sv);
            if (ptr != NULL) DumpHex(ptr, 16);
            sv_setref_pv(TMP, NULL, ptr);
            av_store(RETVALAV, SLOT_POINTER_ADDR, TMP);
            av_store(RETVALAV, SLOT_POINTER_SUBTYPE, newSVsv(ST(0)));
            av_store(RETVALAV, SLOT_POINTER_COUNT, newSViv(1));
            av_store(RETVALAV, SLOT_POINTER_POSITION, newSViv(0));
        }
        SV *RETVAL = newRV_noinc(MUTABLE_SV(RETVALAV)); // Create a reference to the AV
        sv_bless(RETVAL, gv_stashpvn("Affix::Pointer::Unmanaged", 25, GV_ADD));
        ST(0) = sv_2mortal(RETVAL);
    }
    XSRETURN(1);
}

XS_INTERNAL(Affix_ptr2sv) {
    dVAR;
    dXSARGS;
    if (UNLIKELY(items != 2)) croak_xs_usage(cv, "type, ptr");
    if (UNLIKELY(!sv_derived_from(ST(0), "Affix::Type"))) croak("type is not of type Affix::Type");
    {
        SV *const xsub_tmp_sv = ST(1);
        SvGETMAGIC(xsub_tmp_sv);
        if (!(SvROK(xsub_tmp_sv) && SvTYPE(SvRV(xsub_tmp_sv)) == SVt_PVAV &&
              sv_derived_from(xsub_tmp_sv, "Affix::Pointer")))
            croak("ptr is not of type Affix::Pointer");
        {
            AV *array = MUTABLE_AV(SvRV(xsub_tmp_sv));
            SV *ptr_sv = AXT_POINTER_ADDR(array);
            if (SvOK(ptr_sv)) {
                IV tmp = SvIV(MUTABLE_SV(SvRV(ptr_sv)));
                DCpointer ptr;
                ptr = INT2PTR(DCpointer,
                              tmp + (AXT_TYPE_SIZEOF(ST(0)) * AXT_POINTER_POSITION(ST(0))));
                ST(0) = sv_2mortal(newRV(ptr2sv(aTHX_ ST(0), ptr)));
            }
            else
                ST(0) = sv_2mortal(newSV(0));
        }
    }
    XSRETURN(1);
}

XS_INTERNAL(Affix_Pointer_DumpHex) {
    dVAR;
    dXSARGS;
    if (items != 2) croak_xs_usage(cv, "ptr, size");
    SV *const xsub_tmp_sv = ST(0);
    SvGETMAGIC(xsub_tmp_sv);

    if (!(SvROK(xsub_tmp_sv) && SvTYPE(SvRV(xsub_tmp_sv)) == SVt_PVAV &&
          sv_derived_from(xsub_tmp_sv, "Affix::Pointer")))
        croak("ptr is not of type Affix::Pointer");
    size_t size = (size_t)SvUV(ST(1));
    {
        SV *ptr_sv = AXT_POINTER_ADDR(xsub_tmp_sv);
        if (SvOK(ptr_sv)) {
            IV tmp = SvIV(MUTABLE_SV(SvRV(ptr_sv)));
            DCpointer ptr;
            ptr = INT2PTR(DCpointer, tmp);
            _DumpHex(aTHX_ ptr, size, OutCopFILE(PL_curcop), CopLINE(PL_curcop));
        }
    }
    XSRETURN_EMPTY;
}

XS_INTERNAL(Affix_Pointer_sv) {
    dVAR;
    dXSARGS;
    if (items != 1) croak_xs_usage(cv, "ptr");
    SV *const xsub_tmp_sv = ST(0);
    SvGETMAGIC(xsub_tmp_sv);

    if (!(SvROK(xsub_tmp_sv) && SvTYPE(SvRV(xsub_tmp_sv)) == SVt_PVAV &&
          sv_derived_from(xsub_tmp_sv, "Affix::Pointer")))
        croak("ptr is not of type Affix::Pointer");
    {
        SV *ptr_sv = AXT_POINTER_ADDR(xsub_tmp_sv);
        if (SvOK(ptr_sv)) {
            IV tmp = SvIV(MUTABLE_SV(SvRV(ptr_sv)));
            warn("    AXT_POINTER_POSITION(xsub_tmp_sv) =                                   %d",
                 AXT_POINTER_POSITION(xsub_tmp_sv));
            //~ warn("AXT_TYPE_SIZEOF(AXT_POINTER_SUBTYPE(xsub_tmp_sv)) = %d",
            //~ AXT_TYPE_SIZEOF(AXT_POINTER_SUBTYPE(xsub_tmp_sv)));
            warn("    AXT_TYPE_SIZEOF(AXT_TYPE_SUBTYPE(AXT_POINTER_SUBTYPE(xsub_tmp_sv))) = %d",
                 AXT_TYPE_SIZEOF(AXT_TYPE_SUBTYPE(AXT_POINTER_SUBTYPE(xsub_tmp_sv))));

            tmp += (AXT_TYPE_SIZEOF(AXT_POINTER_SUBTYPE(xsub_tmp_sv)) *
                    AXT_POINTER_POSITION(xsub_tmp_sv));

            //~ warn("AXT_POINTER_POSITION(xsub_tmp_sv) == %d", AXT_POINTER_POSITION(xsub_tmp_sv));

            // DD(ST(0));
            DCpointer ptr;
            ptr = INT2PTR(DCpointer, tmp);
            //~ warn("========> ptr: %p", ptr);

            ST(0) = sv_2mortal(ptr2sv(aTHX_ AXT_POINTER_SUBTYPE(xsub_tmp_sv), ptr));
        }
        else
            ST(0) = sv_2mortal(newSV(0));
    }
    XSRETURN(1);
}

XS_INTERNAL(Affix_Pointer_raw) {
    dVAR;
    dXSARGS;
    if (items < 2 || items > 3) croak_xs_usage(cv, "ptr, size[, utf8]");
    {
        SV *RETVAL;
        size_t size = (size_t)SvUV(ST(1));
        bool utf8 = items < 3 ? false : SvTRUE(ST(2));
        {
            SV *const xsub_tmp_sv = ST(0);
            SvGETMAGIC(xsub_tmp_sv);

            if (!(SvROK(xsub_tmp_sv) && SvTYPE(SvRV(xsub_tmp_sv)) == SVt_PVAV &&
                  sv_derived_from(xsub_tmp_sv, "Affix::Pointer")))
                croak("ptr is not of type Affix::Pointer");
            size_t size = (size_t)SvUV(ST(1));
            {
                SV *ptr_sv = AXT_POINTER_ADDR(xsub_tmp_sv);
                if (SvOK(ptr_sv)) {
                    IV tmp = SvIV(MUTABLE_SV(SvRV(ptr_sv)));
                    DCpointer ptr;
                    ptr = INT2PTR(DCpointer, tmp);
                    RETVAL = newSVpvn_utf8((const char *)ptr, size, utf8 ? 1 : 0);
                }
                else
                    RETVAL = newSV(0);
            }
        }
        RETVAL = sv_2mortal(RETVAL);
        ST(0) = RETVAL;
    }
    XSRETURN(1);
}

XS_INTERNAL(Affix_Pointer_DESTROY) {
    dVAR;
    dXSARGS;
    if (items != 1) croak_xs_usage(cv, "ptr");
    SV *const xsub_tmp_sv = ST(0);
    SvGETMAGIC(xsub_tmp_sv);
    if (!(SvROK(xsub_tmp_sv) && SvTYPE(SvRV(xsub_tmp_sv)) == SVt_PVAV &&
          sv_derived_from(xsub_tmp_sv, "Affix::Pointer")))
        croak("ptr is not of type Affix::Pointer");
    DCpointer ptr;
    SV *ptr_sv = AXT_POINTER_ADDR(xsub_tmp_sv);
    if (SvOK(ptr_sv)) {
        IV tmp = SvIV(MUTABLE_SV(SvRV(ptr_sv)));
        ptr = INT2PTR(DCpointer, tmp);
        if (ptr != NULL) {
            // safefree(ptr);
            ptr = NULL;
        }
    }
    XSRETURN_EMPTY;
}

XS_INTERNAL(Affix_free) {
    dVAR;
    dXSARGS;
    if (items != 1) croak_xs_usage(cv, "ptr");
    SP -= items;

    SV *const xsub_tmp_sv = ST(0);
    SvGETMAGIC(xsub_tmp_sv);
    if (!(SvROK(xsub_tmp_sv) && SvTYPE(SvRV(xsub_tmp_sv)) == SVt_PVAV &&
          sv_derived_from(xsub_tmp_sv, "Affix::Pointer")))
        croak("ptr is not of type Affix::Pointer");
    {
        SV *ptr_sv = AXT_POINTER_ADDR(xsub_tmp_sv);
        if (SvOK(ptr_sv)) {
            DCpointer ptr;
            IV tmp = SvIV(MUTABLE_SV(SvRV(ptr_sv)));

            ptr = INT2PTR(DCpointer, tmp);
            if (ptr != NULL) {
                safefree(ptr);
                ptr = NULL;
            }
        }
    }

    sv_set_undef(ST(0));
    SvSETMAGIC(ST(0));

    // Let Affix::Pointer::DESTROY take care of the rest
    PUTBACK;
    XSRETURN(1);
}
// Nothing below this has been updated to the new array based ::Pointer objects
XS_INTERNAL(Affix_Pointer_plus) {
    dVAR;
    dXSARGS;
    PING;

    if (UNLIKELY(items != 3)) croak_xs_usage(cv, "ptr, other, swap");
    DCpointer ptr;
    IV other = (IV)SvIV(ST(1));
    // IV swap = (IV)SvIV(ST(2));
    if (UNLIKELY(!sv_derived_from(ST(0), "Affix::Pointer")))
        croak("ptr is not of type Affix::Pointer");
    IV tmp = SvIV((SV *)SvRV(ST(0)));
    ptr = INT2PTR(DCpointer, PTR2IV(tmp) + (other));
    {
        SV *RETVALSV;
        RETVALSV = sv_newmortal();
        sv_setref_pv(RETVALSV, "Affix::Pointer::Unmanaged", ptr);
        ST(0) = RETVALSV;
    }
    XSRETURN(1);
}

XS_INTERNAL(Affix_Pointer_minus) {
    dVAR;
    dXSARGS;
    PING;

    if (UNLIKELY(items != 3)) croak_xs_usage(cv, "ptr, other, swap");
    DCpointer ptr;
    IV other = (IV)SvIV(ST(1));
    //~ IV swap = (IV)SvIV(ST(2));
    if (UNLIKELY(!sv_derived_from(ST(0), "Affix::Pointer")))
        croak("ptr is not of type Affix::Pointer");
    IV tmp = SvIV((SV *)SvRV(ST(0)));
    ptr = INT2PTR(DCpointer, PTR2IV(tmp) - other);
    {
        SV *RETVALSV;
        RETVALSV = sv_newmortal();
        sv_setref_pv(RETVALSV, "Affix::Pointer::Unmanaged", ptr);
        ST(0) = RETVALSV;
    }
    XSRETURN(1);
}

XS_INTERNAL(Affix_malloc) {
    dVAR;
    dXSARGS;
    PING;

    if (items != 1) croak_xs_usage(cv, "size");

    DCpointer RETVAL;
    size_t size = (size_t)SvUV(ST(0));
    {
        RETVAL = safemalloc(size);
        if (RETVAL == NULL) XSRETURN_EMPTY;
    }
    {
        SV *RETVALSV;
        RETVALSV = sv_newmortal();
        sv_setref_pv(RETVALSV, "Affix::Pointer::Unmanaged", RETVAL);
        ST(0) = RETVALSV;
    }

    XSRETURN(1);
}

XS_INTERNAL(Affix_calloc) {
    dVAR;
    dXSARGS;
    PING;

    if (items != 2) croak_xs_usage(cv, "num, size");

    DCpointer RETVAL;
    size_t num = (size_t)SvUV(ST(0));
    size_t size = (size_t)SvUV(ST(1));
    {
        RETVAL = safecalloc(num, size);
        if (RETVAL == NULL) XSRETURN_EMPTY;
    }
    {
        SV *RETVALSV;
        RETVALSV = sv_newmortal();
        sv_setref_pv(RETVALSV, "Affix::Pointer::Unmanaged", RETVAL);
        ST(0) = RETVALSV;
    }

    XSRETURN(1);
}

XS_INTERNAL(Affix_realloc) {
    dVAR;
    dXSARGS;
    PING;

    if (items != 2) croak_xs_usage(cv, "ptr, size");
    DCpointer ptr;
    size_t size = (size_t)SvUV(ST(1));
    if (sv_derived_from(ST(0), "Affix::Pointer")) {
        IV tmp = SvIV((SV *)SvRV(ST(0)));
        ptr = INT2PTR(DCpointer, tmp);
    }
    else
        croak("ptr is not of type Affix::Pointer");
    ptr = saferealloc(ptr, size);
    sv_setref_pv(ST(0), "Affix::Pointer:Unmanaged", ptr);
    SvSETMAGIC(ST(0));
    {
        SV *RETVALSV;
        RETVALSV = sv_newmortal();
        sv_setref_pv(RETVALSV, "Affix::Pointer::Unmanaged", ptr);
        ST(0) = RETVALSV;
    }

    XSRETURN(1);
}

XS_INTERNAL(Affix_memchr) {
    dVAR;
    dXSARGS;
    PING;

    if (items != 3) croak_xs_usage(cv, "ptr, ch, count");
    {
        DCpointer RETVAL;
        DCpointer ptr;
        char ch = (char)*SvPV_nolen(ST(1));
        size_t count = (size_t)SvUV(ST(2));

        if (sv_derived_from(ST(0), "Affix::Pointer")) {
            IV tmp = SvIV((SV *)SvRV(ST(0)));
            ptr = INT2PTR(DCpointer, tmp);
        }
        else
            croak("ptr is not of type Affix::Pointer");

        RETVAL = memchr(ptr, ch, count);
        {
            SV *RETVALSV;
            RETVALSV = sv_newmortal();
            sv_setref_pv(RETVALSV, "Affix::Pointer::Unmanaged", RETVAL);
            ST(0) = RETVALSV;
        }
    }
    XSRETURN(1);
}

XS_INTERNAL(Affix_memcmp) {
    dVAR;
    dXSARGS;
    PING;

    if (items != 3) croak_xs_usage(cv, "lhs, rhs, count");
    {
        int RETVAL;
        dXSTARG;
        size_t count = (size_t)SvUV(ST(2));
        DCpointer lhs, rhs;
        {
            if (sv_derived_from(ST(0), "Affix::Pointer")) {
                IV tmp = SvIV((SV *)SvRV(ST(0)));
                lhs = INT2PTR(DCpointer, tmp);
            }
            else if (SvIOK(ST(0))) {
                IV tmp = SvIV((SV *)(ST(0)));
                lhs = INT2PTR(DCpointer, tmp);
            }
            else
                croak("ptr is not of type Affix::Pointer");
            if (sv_derived_from(ST(1), "Affix::Pointer")) {
                IV tmp = SvIV((SV *)SvRV(ST(1)));
                rhs = INT2PTR(DCpointer, tmp);
            }
            else if (SvIOK(ST(1))) {
                IV tmp = SvIV((SV *)(ST(1)));
                rhs = INT2PTR(DCpointer, tmp);
            }
            else if (SvPOK(ST(1))) { rhs = (DCpointer)(U8 *)SvPV_nolen(ST(1)); }
            else
                croak("dest is not of type Affix::Pointer");
            RETVAL = memcmp(lhs, rhs, count);
        }
        XSprePUSH;
        PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}

XS_INTERNAL(Affix_memset) {
    dVAR;
    dXSARGS;
    PING;

    if (items != 3) croak_xs_usage(cv, "dest, ch, count");
    {
        DCpointer RETVAL;
        DCpointer dest;
        char ch = (char)*SvPV_nolen(ST(1));
        size_t count = (size_t)SvUV(ST(2));

        if (sv_derived_from(ST(0), "Affix::Pointer")) {
            IV tmp = SvIV((SV *)SvRV(ST(0)));
            dest = INT2PTR(DCpointer, tmp);
        }
        else
            croak("dest is not of type Affix::Pointer");

        RETVAL = memset(dest, ch, count);
        {
            SV *RETVALSV;
            RETVALSV = sv_newmortal();
            sv_setref_pv(RETVALSV, "Affix::Pointer::Unmanaged", RETVAL);
            ST(0) = RETVALSV;
        }
    }
    XSRETURN(1);
}

XS_INTERNAL(Affix_memcpy) {
    dVAR;
    dXSARGS;
    PING;

    if (items != 3) croak_xs_usage(cv, "dest, src, nitems");
    size_t nitems = (size_t)SvUV(ST(2));
    DCpointer dest, src, RETVAL;

    if (sv_derived_from(ST(0), "Affix::Pointer")) {
        IV tmp = SvIV((SV *)SvRV(ST(0)));
        dest = INT2PTR(DCpointer, tmp);
    }
    else if (SvIOK(ST(0))) {
        IV tmp = SvIV((SV *)(ST(0)));
        dest = INT2PTR(DCpointer, tmp);
    }
    else
        croak("dest is not of type Affix::Pointer");
    if (sv_derived_from(ST(1), "Affix::Pointer")) {
        IV tmp = SvIV((SV *)SvRV(ST(1)));
        src = INT2PTR(DCpointer, tmp);
    }
    else if (SvIOK(ST(1))) {
        IV tmp = SvIV((SV *)(ST(1)));
        src = INT2PTR(DCpointer, tmp);
    }
    else if (SvPOK(ST(1))) { src = (DCpointer)(U8 *)SvPV_nolen(ST(1)); }
    else
        croak("dest is not of type Affix::Pointer");
    RETVAL = CopyD(src, dest, nitems, char);
    {
        SV *RETVALSV;
        RETVALSV = sv_newmortal();
        sv_setref_pv(RETVALSV, "Affix::Pointer::Unmanaged", RETVAL);
        ST(0) = RETVALSV;
    }
    XSRETURN(1);
}

XS_INTERNAL(Affix_memmove) {
    dVAR;
    dXSARGS;
    PING;

    if (items != 3) croak_xs_usage(cv, "dest, src, nitems");

    size_t nitems = (size_t)SvUV(ST(2));
    DCpointer dest, src, RETVAL;

    if (sv_derived_from(ST(0), "Affix::Pointer")) {
        IV tmp = SvIV((SV *)SvRV(ST(0)));
        dest = INT2PTR(DCpointer, tmp);
    }
    else if (SvIOK(ST(0))) {
        IV tmp = SvIV((SV *)(ST(0)));
        dest = INT2PTR(DCpointer, tmp);
    }
    else
        croak("dest is not of type Affix::Pointer");
    if (sv_derived_from(ST(1), "Affix::Pointer")) {
        IV tmp = SvIV((SV *)SvRV(ST(1)));
        src = INT2PTR(DCpointer, tmp);
    }
    else if (SvIOK(ST(1))) {
        IV tmp = SvIV((SV *)(ST(1)));
        src = INT2PTR(DCpointer, tmp);
    }
    else if (SvPOK(ST(1))) { src = (DCpointer)(U8 *)SvPV_nolen(ST(1)); }
    else
        croak("dest is not of type Affix::Pointer");

    RETVAL = MoveD(src, dest, nitems, char);
    {
        SV *RETVALSV;
        RETVALSV = sv_newmortal();
        sv_setref_pv(RETVALSV, "Affix::Pointer::Unmanaged", RETVAL);
        ST(0) = RETVALSV;
    }
    XSRETURN(1);
}

XS_INTERNAL(Affix_strdup) {
    dVAR;
    dXSARGS;
    PING;

    if (items != 1) croak_xs_usage(cv, "str1");

    DCpointer RETVAL;
    char *str1 = (char *)SvPV_nolen(ST(0));

    RETVAL = strdup(str1);
    {
        SV *RETVALSV;
        RETVALSV = sv_newmortal();
        sv_setref_pv(RETVALSV, "Affix::Pointer::Unmanaged", RETVAL);
        ST(0) = RETVALSV;
    }
    XSRETURN(1);
}

void boot_Affix_Pointer(pTHX_ CV *cv) {
    PERL_UNUSED_VAR(cv);
    {
        (void)newXSproto_portable("Affix::malloc", Affix_malloc, __FILE__, "$");
        export_function("Affix", "malloc", "memory");
        (void)newXSproto_portable("Affix::calloc", Affix_calloc, __FILE__, "$$");
        export_function("Affix", "calloc", "memory");
        (void)newXSproto_portable("Affix::realloc", Affix_realloc, __FILE__, "$$");
        export_function("Affix", "realloc", "memory");
        (void)newXSproto_portable("Affix::free", Affix_free, __FILE__, "$");
        export_function("Affix", "free", "memory");
        (void)newXSproto_portable("Affix::memchr", Affix_memchr, __FILE__, "$$$");
        export_function("Affix", "memchr", "memory");
        (void)newXSproto_portable("Affix::memcmp", Affix_memcmp, __FILE__, "$$$");
        export_function("Affix", "memcmp", "memory");
        (void)newXSproto_portable("Affix::memset", Affix_memset, __FILE__, "$$$");
        export_function("Affix", "memset", "memory");
        (void)newXSproto_portable("Affix::memcpy", Affix_memcpy, __FILE__, "$$$");
        export_function("Affix", "memcpy", "memory");
        (void)newXSproto_portable("Affix::memmove", Affix_memmove, __FILE__, "$$$");
        export_function("Affix", "memmove", "memory");
        (void)newXSproto_portable("Affix::strdup", Affix_strdup, __FILE__, "$");
        export_function("Affix", "strdup", "memory");
    }

    (void)newXSproto_portable("Affix::sv2ptr", Affix_sv2ptr, __FILE__, "$$");
    (void)newXSproto_portable("Affix::ptr2sv", Affix_ptr2sv, __FILE__, "$$");
    (void)newXSproto_portable("Affix::Pointer::sv", Affix_Pointer_sv, __FILE__, "$;$");
    (void)newXSproto_portable("Affix::Pointer::raw", Affix_Pointer_raw, __FILE__, "$$;$");
    (void)newXSproto_portable("Affix::Pointer::dump", Affix_Pointer_DumpHex, __FILE__, "$$");
    (void)newXSproto_portable("Affix::DumpHex", Affix_Pointer_DumpHex, __FILE__, "$$");
    (void)newXSproto_portable("Affix::Pointer::DESTROY", Affix_Pointer_DESTROY, __FILE__, "$");
    (void)newXSproto_portable("Affix::Pointer::free", Affix_free, __FILE__, "$");

    (void)newXSproto_portable("Affix::Pointer::cast", Affix_cast, __FILE__, "$");

    set_isa("Affix::Pointer::Unmanaged", "Affix::Pointer");
    set_isa("Affix::Type::Ref", "Affix::Type::Pointer");
    set_isa("Affix::Ref", "Affix::Pointer");
}
