#include "../Affix.h"

void *sv2ptr(pTHX_ SV *type, SV *data, DCpointer ret) {
    //~ DD(type);
    //~ DD(data);
    if (!SvOK(data) && SvREADONLY(data)) return NULL; // explicit undef
    size_t len = 0;
    switch (AXT_TYPE_NUMERIC(type)) {
    case VOID_FLAG: {
        if (SvOK(data)) {
            SV *const xsub_tmp_sv = data;
            SvGETMAGIC(xsub_tmp_sv);
            if ((SvROK(xsub_tmp_sv) && SvTYPE(SvRV(xsub_tmp_sv)) == SVt_PVAV &&
                 sv_derived_from(xsub_tmp_sv, "Affix::Pointer"))) {
                SV *ptr_sv = AXT_POINTER_ADDR(xsub_tmp_sv);
                if (SvOK(ptr_sv)) {
                    IV tmp = SvIV(MUTABLE_SV(SvRV(ptr_sv)));
                    ret = INT2PTR(DCpointer, tmp);
                }
            }
            else if (SvTYPE(data) != SVt_NULL) {
                DCpointer ptr = SvPVbyte(data, len);
                if (ret == NULL) Newxz(ret, len, char);
                Copy(ptr, ret, len, char);
            }
            else
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_TYPE_STRINGIFY(type),
                      SvTYPE(data));
        }
    } break;
    case BOOL_FLAG: {
        bool i;
        if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
            AV *array = MUTABLE_AV(SvRV(data));
            len = av_count(array);
            if (ret == NULL) Newxz(ret, len, bool);
            for (size_t x = 0; x < len; ++x) {
                i = SvTRUE(*av_fetch(array, x, 0));
                Copy(&i, INT2PTR(bool *, PTR2IV(ret) + (x * SIZEOF_BOOL)), 1, bool);
            }
        }
        else {
            len = 1;
            if (ret == NULL) Newxz(ret, len, bool);
            i = SvTRUE(data);
            Copy(&i, ret, len, bool);
        }
    } break;
    case CHAR_FLAG:
    case SCHAR_FLAG: {
        if (SvOK(data)) {

            if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
                AV *array = MUTABLE_AV(SvRV(data));
                len = av_count(array);
                if (ret == NULL) Newxz(ret, len, int);
                char i;
                for (size_t x = 0; x < len; ++x) {
                    i = (char)SvIV(*av_fetch(array, x, 0));
                    Copy(&i, INT2PTR(char *, PTR2IV(ret) + (x * SIZEOF_CHAR)), 1, char);
                }
            }
            else {
                char *i = SvUTF8(data) ? SvPVutf8(data, len) : SvPV(data, len);
                if (ret == NULL) Newxz(ret, len + 1, char);
                Copy(i, ret, len, char);
            }
        }
    } break;
    case UCHAR_FLAG: {
        if (SvOK(data)) {

            if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
                AV *array = MUTABLE_AV(SvRV(data));
                len = av_count(array);
                if (ret == NULL) Newxz(ret, len + 1, unsigned int);
                unsigned char i;
                for (size_t x = 0; x < len; ++x) {
                    i = (unsigned char)SvUV(*av_fetch(array, x, 0));
                    Copy(&i, INT2PTR(unsigned char *, PTR2IV(ret) + (x * SIZEOF_UCHAR)), 1,
                         unsigned char);
                }
            }
            else {
                char *i = SvUTF8(data) ? SvPVutf8(data, len) : SvPV(data, len);
                if (ret == NULL) Newxz(ret, len + 1, char);
                Copy(i, ret, len, char);
            }
        }
    } break;
    case SHORT_FLAG: {
        if (SvOK(data)) {
            short i;
            if (SvIOK(data)) {
                len = 1;
                if (ret == NULL) Newxz(ret, len, short);
                i = SvIV(data);
                Copy(&i, ret, len, short);
            }
            else if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
                AV *array = MUTABLE_AV(SvRV(data));
                len = av_count(array);
                if (ret == NULL) Newxz(ret, len, short);
                for (size_t x = 0; x < len; ++x) {
                    i = SvIV(*av_fetch(array, x, 0));
                    Copy(&i, INT2PTR(short *, PTR2IV(ret) + (x * SIZEOF_SHORT)), 1, short);
                }
            }
            else
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_TYPE_STRINGIFY(type),
                      SvTYPE(data));
        }
        // else if (ret == NULL)
        // Newxz(ret, 0, DCpointer); // HMM: void pointer?
    } break;
    case USHORT_FLAG: {
        if (SvOK(data)) {
            unsigned short i;
            if (SvIOK(data)) {
                len = 1;
                if (ret == NULL) Newxz(ret, len, unsigned short);
                i = SvUV(data);
                Copy(&i, ret, len, unsigned short);
            }
            else if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
                AV *array = MUTABLE_AV(SvRV(data));
                len = av_count(array);
                if (ret == NULL) Newxz(ret, len, unsigned short);
                for (size_t x = 0; x < len; ++x) {
                    i = SvUV(*av_fetch(array, x, 0));
                    Copy(&i, INT2PTR(unsigned short *, PTR2IV(ret) + (x * SIZEOF_USHORT)), 1,
                         unsigned short);
                }
            }
            else
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_TYPE_STRINGIFY(type),
                      SvTYPE(data));
        }
        // else if (ret == NULL)
        // Newxz(ret, 0, DCpointer); // HMM: void pointer?
    } break;
    case INT_FLAG: {
        if (SvOK(data)) {
            int i;
            if (SvIOK(data)) {
                len = 1;
                if (ret == NULL) Newxz(ret, len, int);
                i = SvIV(data);
                Copy(&i, ret, len, int);
            }
            else if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
                AV *array = MUTABLE_AV(SvRV(data));
                len = av_count(array);
                if (ret == NULL) Newxz(ret, len, int);
                for (size_t x = 0; x < len; ++x) {
                    i = SvIV(*av_fetch(array, x, 0));
                    Copy(&i, INT2PTR(int *, PTR2IV(ret) + (x * SIZEOF_INT)), 1, int);
                }
            }
            else
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_TYPE_STRINGIFY(type),
                      SvTYPE(data));
        }
    } break;
    case UINT_FLAG: {
        if (SvOK(data)) {
            unsigned int i;
            if (SvIOK(data)) {
                len = 1;
                if (ret == NULL) Newxz(ret, len, unsigned int);
                i = SvUV(data);
                Copy(&i, ret, len, unsigned int);
            }
            else if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
                AV *array = MUTABLE_AV(SvRV(data));
                len = av_count(array);
                if (ret == NULL) Newxz(ret, len, unsigned int);
                for (size_t x = 0; x < len; ++x) {
                    i = SvUV(*av_fetch(array, x, 0));
                    Copy(&i, INT2PTR(unsigned int *, PTR2IV(ret) + (x * SIZEOF_UINT)), 1,
                         unsigned int);
                }
            }
            else
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_TYPE_STRINGIFY(type),
                      SvTYPE(data));
        }
    } break;
    case LONG_FLAG: {
        if (SvOK(data)) {
            long i;
            if (SvIOK(data)) {
                len = 1;
                if (ret == NULL) Newxz(ret, len, long);
                i = SvIV(data);
                Copy(&i, ret, len, long);
            }
            else if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
                AV *array = MUTABLE_AV(SvRV(data));
                len = av_count(array);
                if (ret == NULL) Newxz(ret, len, long);
                for (size_t x = 0; x < len; ++x) {
                    i = SvIV(*av_fetch(array, x, 0));
                    Copy(&i, INT2PTR(long *, PTR2IV(ret) + (x * SIZEOF_LONG)), 1, long);
                }
            }
            else
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_TYPE_STRINGIFY(type),
                      SvTYPE(data));
        }
    } break;
    case ULONG_FLAG: {
        if (SvOK(data)) {
            unsigned long i;
            if (SvIOK(data)) {
                len = 1;
                if (ret == NULL) Newxz(ret, len, unsigned long);
                i = SvIV(data);
                Copy(&i, ret, len, unsigned long);
            }
            else if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
                AV *array = MUTABLE_AV(SvRV(data));
                len = av_count(array);
                if (ret == NULL) Newxz(ret, len, unsigned long);
                for (size_t x = 0; x < len; ++x) {
                    i = SvIV(*av_fetch(array, x, 0));
                    Copy(&i, INT2PTR(unsigned long *, PTR2IV(ret) + (x * SIZEOF_ULONG)), 1,
                         unsigned long);
                }
            }
            else
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_TYPE_STRINGIFY(type),
                      SvTYPE(data));
        }
    } break;
    case LONGLONG_FLAG: {
        if (SvOK(data)) {
            long long i;
            if (SvIOK(data)) {
                len = 1;
                if (ret == NULL) Newxz(ret, len, long long);
                i = SvIV(data);
                Copy(&i, ret, len, long long);
            }
            else if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
                AV *array = MUTABLE_AV(SvRV(data));
                len = av_count(array);
                if (ret == NULL) Newxz(ret, len, long long);
                for (size_t x = 0; x < len; ++x) {
                    i = SvIV(*av_fetch(array, x, 0));
                    Copy(&i, INT2PTR(long long *, PTR2IV(ret) + (x * SIZEOF_LONGLONG)), 1,
                         long long);
                }
            }
            else
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_TYPE_STRINGIFY(type),
                      SvTYPE(data));
        }
    } break;
    case ULONGLONG_FLAG: {
        if (SvOK(data)) {
            unsigned long long i;
            if (SvIOK(data)) {
                len = 1;
                if (ret == NULL) Newxz(ret, len, unsigned long long);
                i = SvIV(data);
                Copy(&i, ret, len, unsigned long long);
            }
            else if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
                AV *array = MUTABLE_AV(SvRV(data));
                len = av_count(array);
                if (ret == NULL) Newxz(ret, len, unsigned long long);
                for (size_t x = 0; x < len; ++x) {
                    i = SvIV(*av_fetch(array, x, 0));
                    Copy(&i, INT2PTR(unsigned long long *, PTR2IV(ret) + (x * SIZEOF_ULONGLONG)), 1,
                         unsigned long long);
                }
            }
            else
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_TYPE_STRINGIFY(type),
                      SvTYPE(data));
        }
    } break;
    case FLOAT_FLAG: {
        if (SvOK(data)) {
            float i;
            if (SvNOK(data) || SvIOK(data)) {
                len = 1;
                if (ret == NULL) Newxz(ret, len, float);
                i = SvNV(data);
                Copy(&i, ret, len, float);
            }
            else if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
                AV *array = MUTABLE_AV(SvRV(data));
                len = av_count(array);
                if (ret == NULL) Newxz(ret, len, float);
                for (size_t x = 0; x < len; ++x) {
                    i = SvNV(*av_fetch(array, x, 0));
                    Copy(&i, INT2PTR(float *, PTR2IV(ret) + (x * SIZEOF_FLOAT)), 1, float);
                }
            }
            else
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_TYPE_STRINGIFY(type),
                      SvTYPE(data));
        }
    } break;
    case DOUBLE_FLAG: {
        if (SvOK(data)) {
            double i;
            if (SvNOK(data) || SvIOK(data)) {
                len = 1;
                if (ret == NULL) Newxz(ret, len, double);
                i = SvNV(data);
                Copy(&i, ret, len, double);
            }
            else if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
                AV *array = MUTABLE_AV(SvRV(data));
                len = av_count(array);
                if (ret == NULL) Newxz(ret, len, double);
                for (size_t x = 0; x < len; ++x) {
                    i = SvNV(*av_fetch(array, x, 0));
                    Copy(&i, INT2PTR(double *, PTR2IV(ret) + (x * SIZEOF_DOUBLE)), 1, double);
                }
            }
            else
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_TYPE_STRINGIFY(type),
                      SvTYPE(data));
        }
    } break;
    case POINTER_FLAG: {
        SV *subtype = AXT_TYPE_SUBTYPE(type);
        if (UNLIKELY(sv_derived_from(subtype, "Affix::Type::Pointer"))) {
            if (SvOK(data)) {
                DCpointer i;
                if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
                    AV *array = MUTABLE_AV(SvRV(data));
                    len = av_count(array);
                    if (ret == NULL) Newxz(ret, len, intptr_t);
                    for (size_t x = 0; x < len; ++x) {
                        i = sv2ptr(aTHX_ subtype, *av_fetch(array, x, 0));
                        Copy(&i, INT2PTR(intptr_t *, PTR2IV(ret) + (x * SIZEOF_INTPTR_T)), 1,
                             intptr_t);
                    }
                }
                else {
                    len = 1;
                    if (ret == NULL) Newxz(ret, len, intptr_t);
                    i = sv2ptr(aTHX_ subtype, data);
                    Copy(&i, ret, len, intptr_t);
                }
            }
        }
        else {
            if (UNLIKELY(!sv_derived_from(subtype, "Affix::Type")))
                croak("subtype is not of type Affix::Type");

            if ((SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV &&
                 sv_derived_from(data, "Affix::Pointer"))) {
                SV *ptr_sv = AXT_POINTER_ADDR(data);
                if (SvOK(ptr_sv)) {
                    IV tmp = SvIV(MUTABLE_SV(SvRV(ptr_sv)));
                    ret = INT2PTR(DCpointer, tmp);
                    len = 1;
                }
            }
            else {
                len = (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) ? av_count(MUTABLE_AV(data))
                                                                      : 1;
                ret = sv2ptr(aTHX_ subtype, data);
            }
        }
    } break;
        //~ case CONST_FLAG: { // Basically a no-op
        //~ SV *subtype = AXT_TYPE_SUBTYPE(type);
        //~ if (UNLIKELY(!sv_derived_from(subtype, "Affix::Type")))
        //~ croak("subtype is not of type Affix::Type");
        //~ len = (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) ? av_count(MUTABLE_AV(data)) : 1;
        //~ ret = (const DCpointer)sv2ptr(aTHX_ subtype, data);
    //~ } break;
    case SV_FLAG: {
        SvREFCNT_inc(data); // TODO: This might leak; I'm just being lazy
        ret = MUTABLE_PTR(data);
    } break;
    case CODEREF_FLAG: {
        if (SvOK(data)) {
            CodeRef *userdata;
            Newxz(userdata, 1, CodeRef);
            userdata->signature = SvPV_nolen(AXT_CODEREF_SIG(type));
            userdata->argtypes = AXT_CODEREF_ARGS(type);
            //~ size_t arg_count = av_count(userdata->argtypes);
            userdata->restype = AXT_CODEREF_RET(type);
            userdata->restype_c = AXT_TYPE_NUMERIC(userdata->restype);
            userdata->cv = SvREFCNT_inc(data);
            storeTHX(userdata->perl);
            Newxz(ret, 1, CodeRefWrapper);
            ret = dcbNewCallback(userdata->signature, &cbHandlerXXXXX, userdata);
        }
        else { Newxz(ret, 1, intptr_t); }

    } break;
    case WCHAR_FLAG: {
        STRLEN len;
        (void)SvPVutf8(data, len);
        wchar_t *value = utf2wchar(aTHX_ data, len + 1);
        len = wcslen(value);
        Renew(ret, len + 1, wchar_t);
        Copy(value, ret, len + 1, wchar_t);
    } break;
    default:
        croak("Attempt to marshal unknown/unhandled type in sv2ptr: %s", AXT_TYPE_STRINGIFY(type));
        break;
    }
    return ret;
}

SV *ptr2obj(pTHX_ SV *type, DCpointer ptr) {
    if (ptr == NULL) return newSV(0); // Don't waste any time on NULL pointers
    SV *ret;
    AV *RETVALAV = newAV();
    {
        SV *TMP = newSV(0);
        sv_setref_pv(TMP, NULL, ptr);
        av_store(RETVALAV, SLOT_POINTER_ADDR, TMP);
        av_store(RETVALAV, SLOT_POINTER_SUBTYPE, newSVsv(type));
        //~ av_store(RETVALAV, SLOT_POINTER_COUNT, newSViv(AXT_POINTER_COUNT(type)));
    }
    ret = newRV_noinc(MUTABLE_SV(RETVALAV)); // Create a reference to the AV
    sv_bless(ret, gv_stashpvn("Affix::Pointer::Unmanaged", 25, GV_ADD));
    return ret;
}

SV *ptr2sv(pTHX_ SV *type, DCpointer ptr) {
    //~ DD(type);
    if (ptr == NULL) return newSV(0); // Don't waste any time on NULL pointers
    SV *ret;
    switch (AXT_TYPE_NUMERIC(type)) {
    case VOID_FLAG: {
        ret = ptr2obj(aTHX_ type, ptr); // Likely wanted ->raw(...)
    } break;
    case BOOL_FLAG: {
        ret = newSVbool(*(bool *)ptr);
    } break;
    case CHAR_FLAG:
    case SCHAR_FLAG:
    case UCHAR_FLAG: {
        size_t len = strlen((char *)ptr);
        ret = newSVpvn_utf8((char *)ptr, len, is_utf8_string((U8 *)ptr, len));
    } break;
    case SHORT_FLAG: {
        ret = newSViv(*(short *)ptr);
    } break;
    case USHORT_FLAG: {
        ret = newSVuv(*(unsigned short *)ptr);
    } break;
    case INT_FLAG: {
        ret = newSViv(*(int *)ptr);
    } break;
    case UINT_FLAG: {
        ret = newSViv(*(unsigned int *)ptr);
    } break;
    case LONG_FLAG: {
        ret = newSViv(*(long *)ptr);
    } break;
    case ULONG_FLAG: {
        ret = newSViv(*(unsigned long *)ptr);
    } break;
    case LONGLONG_FLAG: {
        ret = newSViv(*(long long *)ptr);
    } break;
    case ULONGLONG_FLAG: {
        ret = newSViv(*(unsigned long long *)ptr);
    } break;
    case FLOAT_FLAG: {
        ret = newSVnv(*(float *)ptr);
    } break;
    case DOUBLE_FLAG: {
        ret = newSVnv(*(double *)ptr);
    } break;
    case POINTER_FLAG: {
        SV *subtype = AXT_TYPE_SUBTYPE(type);
        char subtype_c = (char)AXT_TYPE_NUMERIC(subtype);
        size_t len = AXT_TYPE_ARRAYLEN(type);
        switch (subtype_c) {
        case POINTER_FLAG: {
            AV *ret_av = newAV();
            DCpointer tmp;
            int i = 0;
            do {
                tmp = *(DCpointer *)INT2PTR(DCpointer *, (i * SIZEOF_INTPTR_T) + PTR2IV(ptr));
                av_push(ret_av, ptr2sv(aTHX_ subtype, tmp));
                i++;
            } while (tmp != NULL);
            ret = newRV_noinc(MUTABLE_SV(ret_av));
        } break;
        case CHAR_FLAG:
        case UCHAR_FLAG:
        case SCHAR_FLAG:
            ret = ptr2sv(aTHX_ subtype, ptr);
            break;
        case WCHAR_FLAG: {
            size_t len = wcslen((wchar_t *)ptr);
            if (len) ret = wchar2utf(aTHX_(wchar_t *) ptr, len);
        } break;
        default: {
            if (len == 1) { ret = ptr2sv(aTHX_ subtype, ptr); }
            else {
                AV *ret_av = newAV();
                DCpointer tmp = ptr;
                size_t sizeof_subtype = AXT_TYPE_SIZEOF(subtype);
                for (size_t x = 0; x < len; ++x)
                    av_push(ret_av, ptr2sv(aTHX_ subtype,
                                           (DCpointer)INT2PTR(DCpointer,
                                                              (x * sizeof_subtype) + PTR2IV(ptr))));

                ret = newRV_noinc(MUTABLE_SV(ret_av));
            }
        }
        }
    } break;
    case SV_FLAG:
        ret = MUTABLE_SV(ptr);
        break;
    case WCHAR_FLAG: {
        size_t len = wcslen((wchar_t *)ptr);
        if (len) ret = wchar2utf(aTHX_(wchar_t *) ptr, len);
    } break;
    case CODEREF_FLAG: {
        fiction *cb;
        Newxz(cb, 1, fiction);
        char *prototype = NULL;
        {
            cb->signature = NULL;
            cb->restype = NULL;
            cb->restype_c = VOID_FLAG;
            cb->restype = newSVsv(AXT_CODEREF_RET(type));
            cb->restype_c = AXT_TYPE_NUMERIC(cb->restype);
            cb->restype = newSVsv(AXT_CODEREF_RET(type));
            cb->entry_point = ptr;
            cb->res = newSV(0);
            cb->argtypes = // MUTABLE_AV(SvREFCNT_inc(SvRV(newSVsv(
                AXT_CODEREF_ARGS(type)
                //))))
                ;
            size_t sig_len = av_count(cb->argtypes);
            Newxz(cb->signature, sig_len * 2, char); // extra room
            Newxz(prototype, sig_len + 1, char);
            char c_type;
            char scalar = '$';
            //~ char array = '@';
            //~ char code = '&';
            for (size_t i = 0; i < sig_len; i++) {
                c_type = AXT_TYPE_NUMERIC(*av_fetch(cb->argtypes, i, 0));
                Copy(&c_type, cb->signature + i, 1, char);
                // TODO: Generate a valid prototype w/ Array, Callbacks, etc.
                prototype[i + 1] = '$';
                //~ Copy(&scalar, prototype + i, 1, char);
            }
            warn("ret->signature: %s", cb->signature);
            warn("     prototype: %s", prototype);
            warn("ret->restype_c: %c", cb->restype_c);
            warn("t->entry_point: %p", cb->entry_point);
        }
        CV *cv;

        STMT_START {
            cv = newXSproto_portable(NULL, Fiction_trigger, __FILE__, prototype);
            cb->symbol = "anonymous subroutine";
            if (UNLIKELY(cv == NULL))
                croak("ARG! Something went really wrong while installing a new XSUB!");
            XSANY.any_ptr = (DCpointer)cb;
            if (prototype != NULL) safefree(prototype);
        }
        STMT_END;
        ret = // sv_2mortal(
            sv_bless(newRV_noinc(MUTABLE_SV(cv)), gv_stashpv("Affix", GV_ADD))
            //)
            ;
    } break;
    default:
        croak("Attempt to marshal unknown/unhandled type in ptr2sv: %s ",

              AXT_TYPE_STRINGIFY(type));
    };
    return ret;
}

SV *ptr2svx(pTHX_ DCpointer ptr, SV *type) {
    PING;
    // #if DEBUG
    warn("ptr2sv(%p, %s) at %s line %d", ptr, AXT_TYPE_STRINGIFY(type), __FILE__, __LINE__);
    // #endif
    PING;
    SV *retval = NULL;
    if (ptr == NULL) {
        warn("NULL pointer");
        retval = &PL_sv_undef;
    }
    else {
        PING;
#if DEBUG > 1
        // size_t field_size = AXT_SIZEOF(type);
        // if (ptr != NULL) DumpHex(ptr, field_size);
#endif
        switch (AXT_TYPE_NUMERIC(type)) {

        case WSTRING_FLAG: {
            if (ptr && wcslen((wchar_t *)ptr)) {
                retval = wchar2utf(aTHX_ * (wchar_t **)ptr, wcslen(*(wchar_t **)ptr));
            }
            else { retval = &PL_sv_undef; }
        } break;
        case STRUCT_FLAG:
        case CPPSTRUCT_FLAG: {
            retval = newSV(0);
            HV *RETVAL_ = newHV_mortal();
            HV *_type = MUTABLE_HV(SvRV(type));
#if TIE_MAGIC
            SV *p = newSV(0);
            warn("WHERE");

            sv_setref_pv(p, "Affix::Pointer::Unmanaged", ptr);
            SV *tie = newRV_noinc(MUTABLE_SV(newHV()));
            hv_store(MUTABLE_HV(SvRV(tie)), "pointer", 7, p, 0);
            hv_store(MUTABLE_HV(SvRV(tie)), "type", 4, newRV_inc(type), 0);
            sv_bless(tie, gv_stashpv("Affix::Struct", TRUE));
            hv_magic(RETVAL_, tie, PERL_MAGIC_tied);
            SvSetSV(retval, newRV(MUTABLE_SV(RETVAL_)));
#else
            AV *fields = MUTABLE_AV(SvRV(*hv_fetchs(_type, "fields", 0)));
            size_t field_count = av_count(fields);
            for (size_t i = 0; i < field_count; ++i) {
                AV *field = MUTABLE_AV(SvRV(*av_fetch(fields, i, 0)));
                SV *name = *av_fetch(field, 0, 0);
                SV *subtype = *av_fetch(field, 1, 0);
                (void)hv_store_ent(
                    RETVAL_, name,
                    ptr2sv(aTHX_ subtype,
                           INT2PTR(DCpointer, PTR2IV(ptr) + AXT_TYPE_OFFSET(subtype))),
                    0);
            }
            SvSetSV(retval, newRV(MUTABLE_SV(RETVAL_)));
            //~ sv_dump(MUTABLE_SV(RETVAL_));
            //~ sv_dump(retval);
#endif
        } break;
        case CODEREF_FLAG: {
            warn("        case CODEREF_FLAG: {");
            CodeRef *cb = (CodeRef *)dcbGetUserData((DCCallback *)((CodeRefWrapper *)ptr)->cb);
            SvSetSV(retval, cb->cv);
        } break;
        case POINTER_FLAG: {
            SV *subtype = AXT_TYPE_SUBTYPE(type);
            char subtype_c = (char)AXT_TYPE_NUMERIC(subtype);
            switch (subtype_c) {
            case CHAR_FLAG:
            case SCHAR_FLAG:
            case UCHAR_FLAG: {
                char *str = (char *)*(void **)&ptr;
                STRLEN len = strlen(str);
                retval = len ? newSVpv(str, len) : &PL_sv_undef;
            } break;
            case WCHAR_FLAG: {
                retval = wchar2utf(aTHX_(wchar_t *) ptr, wcslen((wchar_t *)ptr));
            } break;
            case VOID_FLAG: {
                retval = newSV(0);
                if (ptr != NULL) {
                    HV *_type = MUTABLE_HV(SvRV(type));
                    SV **typedef_ptr = hv_fetch(_type, "class", 5, 0);
                    if (typedef_ptr != NULL) {
                        sv_setref_pv(retval, SvPV_nolen(*typedef_ptr), ptr);
                    }
                    else { sv_setref_pv(retval, "Affix::Pointer::Unmanaged", ptr); }
                }
            } break;
            //~ case POINTER_FLAG:{
            //~ retval = ptr2sv(aTHX_ *(void**)ptr, subtype);
            //~ }break;
            //~ case STRUCT_FLAG:
            //~ case CPPSTRUCT_FLAG:
            //~ case UNION_FLAG: {
            //~ retval = ptr2sv(aTHX_ *(void**)ptr, subtype);
            //~ }break;
            case POINTER_FLAG: {
                sv_setsv(retval, sv_2mortal(ptr2obj(aTHX_ subtype, ptr)));
            } break;
            default: {
                //~ retval = ptr2sv(aTHX_ subtype, ptr);
            } break;
            }
        } break;
        case UNION_FLAG: {
            HV *RETVAL_ = newHV_mortal();
            warn("HEfdsafdasfdasfdsaRE");

            SV *p = newSV(0);
            sv_setref_pv(p, "Affix::Pointer::Unmanaged", ptr);
            SV *tie = newRV_noinc(MUTABLE_SV(newHV()));
            hv_store(MUTABLE_HV(SvRV(tie)), "pointer", 7, p, 0);
            hv_store(MUTABLE_HV(SvRV(tie)), "type", 4, newRV_inc(type), 0);
            sv_bless(tie, gv_stashpv("Affix::Union", TRUE));
            hv_magic(RETVAL_, tie, PERL_MAGIC_tied);
            retval = newRV(MUTABLE_SV(RETVAL_));
        } break;
        /*

        #define WCHAR_FLAG 44
        */
        case SV_FLAG: {
            if (ptr == NULL) { retval = newSV(0); }
            else if (*(void **)ptr != NULL && SvOK(MUTABLE_SV(*(void **)ptr))) {
                retval = MUTABLE_SV(*(void **)ptr);
            }
        } break;
        /*
                #define AFFIX_TYPE_REF 48
                    #define AFFIX_TYPE_STD_STRING 50
                    #define AFFIX_TYPE_INSTANCE_OF 52
                    */
        default:
            croak("Unhandled type: %s in ptr2sv", AXT_TYPE_STRINGIFY(type));
        }
    }
    PING;
    // retval = sv_2mortal(retval);
    {
        PING;
        SV **typedef_sv = AXT_TYPE_TYPEDEF(type);
        PING;

        if (typedef_sv != NULL) {
            // sv_bless(retval, SvSTASH(*typedef_ptr));
            PING;
            // retval = newSVrv(retval, SvPV_nolen(*typedef_ptr));
        }
    }
    PING;
#if DEBUG
    warn("/ptr2sv(%p, %s) at %s line %d", ptr, AXT_TYPE_STRINGIFY(type), __FILE__, __LINE__);
    // DD(retval);
#endif
    return retval;
}

void *sv2ptrx(pTHX_ SV *type, SV *data) {
    DD(type);
    DD(data);
    PING;
    warn("Here %d", __LINE__);
    DCpointer ret = NULL;
    PING;
    warn("Here %d", __LINE__);

    //~ while (SvROK(type))
    //~ type = SvRV(type);

    //~ sv_dump(type);
    //~ sv_dump(data);

    char type_c = AXT_TYPE_NUMERIC(type);
    warn("Here %d", __LINE__);

    warn("type: %d/%c", type_c, type_c);
    PING;
    size_t size = AXT_TYPE_SIZEOF(type);
    warn("after size: %d", size);
    PING;
#if DEBUG
    warn("sv2ptr(%s, ...) at %s line %d", AXT_TYPE_STRINGIFY(type), __FILE__, __LINE__);
#if DEBUG > 1
    DD(data);
    DD(type);
#endif
#endif
    PING;
    switch (type_c) {
    case WSTRING_FLAG: {
        PING;
        ret = safemalloc(SIZEOF_INTPTR_T);
        if (SvPOK(data)) {
            STRLEN len;
            (void)SvPVutf8(data, len);
            wchar_t *str = utf2wchar(aTHX_ data, len + 1);
            // safemalloc(len+1 * WCHAR_T_SIZE);
            //~ DumpHex(str, strlen(str_));
            DCpointer value;
            Newxz(value, len, wchar_t);
            Copy(str, value, len, wchar_t);
            Copy(&value, ret, 1, intptr_t);
        }
        else {
            // ret = safemalloc(0);
            Zero(ret, 1, intptr_t);
        }
    } break;
    case STRUCT_FLAG: {
        PING;
        ret = safemalloc(AXT_TYPE_SIZEOF(type));
        if (SvOK(data)) {
            if (SvTYPE(SvRV(data)) != SVt_PVHV) croak("Expected a hash reference");
            HV *hv_type = MUTABLE_HV(SvRV(type));
            HV *hv_data = MUTABLE_HV(SvRV(data));
            SV **sv_fields = hv_fetchs(hv_type, "fields", 0);
            AV *av_fields = MUTABLE_AV(SvRV(*sv_fields));
            size_t field_count = av_count(av_fields);
            for (size_t i = 0; i < field_count; ++i) {
                SV **field = av_fetch(av_fields, i, 0);
                AV *name_type = MUTABLE_AV(SvRV(*field));
                SV **name_ptr = av_fetch(name_type, 0, 0);
                SV **type_ptr = av_fetch(name_type, 1, 0);
                char *key = SvPVbytex_nolen(*name_ptr);
                SV **_data = hv_fetch(hv_data, key, strlen(key), 1);
                if (_data != NULL) {
                    DCpointer block = sv2ptr(aTHX_ * type_ptr, *_data);
                    Move(block, INT2PTR(DCpointer, PTR2IV(ret) + AXT_TYPE_OFFSET(*type_ptr)),
                         AXT_TYPE_SIZEOF(*type_ptr), char);
                    safefree(block);
                }
            }
        }
        else
            Zero(ret, 1, intptr_t);
    } break;
    case UNION_FLAG: {
        PING;
        ret = safemalloc(SIZEOF_INTPTR_T);
        if (SvOK(data)) {
            if (SvTYPE(SvRV(data)) != SVt_PVHV) croak("Expected a hash reference");
            HV *hv_type = MUTABLE_HV(SvRV(type));
            HV *hv_data = MUTABLE_HV(SvRV(data));
            SV **sv_fields = hv_fetchs(hv_type, "fields", 0);
            AV *av_fields = MUTABLE_AV(SvRV(*sv_fields));
            size_t field_count = av_count(av_fields);
            for (size_t i = 0; i < field_count; ++i) {
                SV **field = av_fetch(av_fields, i, 0);
                AV *name_type = MUTABLE_AV(SvRV(*field));
                SV **name_ptr = av_fetch(name_type, 0, 0);
                SV **type_ptr = av_fetch(name_type, 1, 0);
                char *key = SvPVbytex_nolen(*name_ptr);
                SV **_data = hv_fetch(hv_data, key, strlen(key), 1);
                if (data != NULL && SvOK(*_data)) {
                    DCpointer block =
                        sv2ptr(aTHX_ * type_ptr, *(hv_fetch(hv_data, key, strlen(key), 1)));
                    Move(block, INT2PTR(DCpointer, PTR2IV(ret) + AXT_TYPE_OFFSET(*type_ptr)),
                         AXT_TYPE_SIZEOF(*type_ptr), char);
                    safefree(block);
                    break;
                }
            }
        }
        else
            Zero(ret, 1, intptr_t);
    } break;
    case CODEREF_FLAG: {
        if (SvOK(data)) {
            CodeRef *userdata;
            Newxz(userdata, 1, CodeRef);
            userdata->signature = SvPV_nolen(AXT_CODEREF_SIG(type));
            userdata->argtypes = AXT_CODEREF_ARGS(type);
            //~ size_t arg_count = av_count(userdata->argtypes);
            userdata->restype = AXT_CODEREF_RET(type);
            userdata->restype_c = AXT_TYPE_NUMERIC(userdata->restype);
            userdata->cv = SvREFCNT_inc(data);
            storeTHX(userdata->perl);
            Newxz(ret, 1, CodeRefWrapper);
            ret = dcbNewCallback(userdata->signature, &cbHandlerXXXXX, userdata);
        }
        else { Newxz(ret, 1, intptr_t); }
    } break;
    case SV_FLAG: {
        PING;
        if (SvOK(data)) {
            ret = safemalloc(SIZEOF_INTPTR_T);
            SvREFCNT_inc(data); // TODO: This might leak; I'm just being lazy
            DCpointer value = (DCpointer)data;
            Renew(ret, 1, intptr_t);
            Copy(&value, ret, 1, intptr_t);
            //~ DD(data);
        }
    } break;

    default: {
        croak("%c is not a known type in sv2ptr(...)", type_c);
    }
    }
#if DEBUG
    warn("/sv2ptr(%s, ...) => %p at %s line %d", AXT_TYPE_STRINGIFY(type), ret, __FILE__, __LINE__);
#endif
    return ret;
}
