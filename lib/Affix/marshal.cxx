#include "../Affix.h"

void *sv2ptr(pTHX_ SV *type, SV *data, DCpointer ret) {
    //~ DD(type);
    //~ DD(data);
    size_t len = 0;
    switch (AXT_NUMERIC(type)) {
    case VOID_FLAG: {
        if (SvOK(data)) {
            if (SvTYPE(data) != SVt_NULL) {
                DCpointer ptr = SvPVbyte(data, len);
                if (ret == NULL) Newxz(ret, len, char);
                Copy(ptr, ret, len, char);
            }
            else
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_STRINGIFY(type), SvTYPE(data));
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
            if (SvPOK(data)) {
                char *i = SvUTF8(data) ? SvPVutf8(data, len) : SvPV(data, len);
                if (ret == NULL) Newxz(ret, len + 1, char);
                Copy(i, ret, len, char);
            }
            else if (SvIOK(data)) {
                len = 1;
                if (ret == NULL) Newxz(ret, len, char);
                char i = (char)SvIV(data);
                Copy(&i, ret, len, char);
            }
            else if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
                AV *array = MUTABLE_AV(SvRV(data));
                len = av_count(array);
                if (ret == NULL) Newxz(ret, len, int);
                char i;
                for (size_t x = 0; x < len; ++x) {
                    i = (char)SvIV(*av_fetch(array, x, 0));
                    Copy(&i, INT2PTR(char *, PTR2IV(ret) + (x * SIZEOF_CHAR)), 1, char);
                }
            }
            else
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_STRINGIFY(type), SvTYPE(data));
        }
    } break;
    case UCHAR_FLAG: {
        if (SvOK(data)) {
            if (SvPOK(data)) {
                // TODO: Store SvUTF8 value in subtype?
                char *i = SvUTF8(data) ? SvPVutf8(data, len) : SvPV(data, len);
                if (ret == NULL) Newxz(ret, len, char);
                Copy(i, ret, len, char);
            }
            else if (SvIOK(data)) {
                len = 1;
                if (ret == NULL) Newxz(ret, len, char);
                unsigned char i = (unsigned char)SvUV(data);
                Copy(&i, ret, len, unsigned char);
            }
            else if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
                AV *array = MUTABLE_AV(SvRV(data));
                len = av_count(array);
                if (ret == NULL) Newxz(ret, len, unsigned int);
                unsigned char i;
                for (size_t x = 0; x < len; ++x) {
                    i = (unsigned char)SvUV(*av_fetch(array, x, 0));
                    Copy(&i, INT2PTR(unsigned char *, PTR2IV(ret) + (x * SIZEOF_UCHAR)), 1,
                         unsigned char);
                }
            }
            else
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_STRINGIFY(type), SvTYPE(data));
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
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_STRINGIFY(type), SvTYPE(data));
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
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_STRINGIFY(type), SvTYPE(data));
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
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_STRINGIFY(type), SvTYPE(data));
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
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_STRINGIFY(type), SvTYPE(data));
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
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_STRINGIFY(type), SvTYPE(data));
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
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_STRINGIFY(type), SvTYPE(data));
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
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_STRINGIFY(type), SvTYPE(data));
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
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_STRINGIFY(type), SvTYPE(data));
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
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_STRINGIFY(type), SvTYPE(data));
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
                croak("Data type mismatch for Pointer[%s] [%d]", AXT_STRINGIFY(type), SvTYPE(data));
        }
    } break;
    case POINTER_FLAG: {
        SV *subtype = AXT_SUBTYPE(type);
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
            len = (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) ? av_count(MUTABLE_AV(data)) : 1;
            ret = sv2ptr(aTHX_ subtype, data);
        }
    } break;
    case CONST_FLAG: { // Basically a no-op
        SV *subtype = AXT_SUBTYPE(type);
        if (UNLIKELY(!sv_derived_from(subtype, "Affix::Type")))
            croak("subtype is not of type Affix::Type");
        len = (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) ? av_count(MUTABLE_AV(data)) : 1;
        ret = sv2ptr(aTHX_ subtype, data);
    } break;

    default:
        croak("Attempt to marshal unknown/unhandled type in sv2ptr: %s", (char)AXT_NUMERIC(type),
              AXT_STRINGIFY(type));
        break;
    }

    av_store(MUTABLE_AV(SvRV(type)), SLOT_POINTER_COUNT, newSViv(len));

    return ret;
}

SV *ptr2sv(pTHX_ SV *type, DCpointer ptr, size_t len) {
    //~ DD(type);
    if (ptr == NULL) return sv_2mortal(newSV(0)); // Don't waste any time on NULL pointers
    SV *ret;
    //~ DD(type);
    switch (AXT_NUMERIC(type)) {
    case VOID_FLAG:
        ret = newSVpv((char *)ptr, len);
        break;
    case BOOL_FLAG: {
        if (len == 1)
            ret = newSVbool(*(bool *)ptr);
        else {
            AV *ret_av = newAV();
            DCpointer tmp = ptr;
            for (size_t x = 0; x < len; ++x)
                av_push(ret_av,
                        newSVbool(*(bool *)INT2PTR(bool *, PTR2IV(ptr) + (x * SIZEOF_BOOL))));
            ret = newRV_noinc(MUTABLE_SV(ret_av));
        }
    } break;
    case CHAR_FLAG:
    case SCHAR_FLAG:
    case UCHAR_FLAG:
        len = strlen((char *)ptr);
        ret = newSVpvn_utf8((char *)ptr, len, is_utf8_string((U8 *)ptr, len));
        break;
    case SHORT_FLAG: {
        if (len == 1)
            ret = newSViv(*(short *)ptr);
        else {
            AV *ret_av = newAV();
            DCpointer tmp = ptr;
            for (size_t x = 0; x < len; ++x)
                av_push(ret_av,
                        newSViv(*(short *)INT2PTR(short *, PTR2IV(ptr) + (x * SIZEOF_SHORT))));
            ret = newRV_noinc(MUTABLE_SV(ret_av));
        }
    } break;
    case USHORT_FLAG: {
        if (len == 1)
            ret = newSVuv(*(unsigned short *)ptr);
        else {
            AV *ret_av = newAV();
            DCpointer tmp = ptr;
            for (size_t x = 0; x < len; ++x)
                av_push(ret_av, newSVuv(*(unsigned short *)INT2PTR(
                                    unsigned short *, PTR2IV(ptr) + (x * SIZEOF_USHORT))));
            ret = newRV_noinc(MUTABLE_SV(ret_av));
        }
    } break;
    case INT_FLAG: {
        if (len == 1)
            ret = newSViv(*(int *)ptr);
        else {
            AV *ret_av = newAV();
            DCpointer tmp = ptr;
            for (size_t x = 0; x < len; ++x)
                av_push(ret_av, newSViv(*(int *)INT2PTR(int *, PTR2IV(ptr) + (x * SIZEOF_INT))));
            ret = newRV_noinc(MUTABLE_SV(ret_av));
        }
    } break;
    case UINT_FLAG: {
        if (len == 1)
            ret = newSViv(*(unsigned int *)ptr);
        else {
            AV *ret_av = newAV();
            DCpointer tmp = ptr;
            for (size_t x = 0; x < len; ++x)
                av_push(ret_av, newSViv(*(unsigned int *)INT2PTR(unsigned int *,
                                                                 PTR2IV(ptr) + (x * SIZEOF_UINT))));
            ret = newRV_noinc(MUTABLE_SV(ret_av));
        }
    } break;
    case LONG_FLAG: {
        if (len == 1)
            ret = newSViv(*(long *)ptr);
        else {
            AV *ret_av = newAV();
            DCpointer tmp = ptr;
            for (size_t x = 0; x < len; ++x)
                av_push(ret_av, newSViv(*(long *)INT2PTR(long *, PTR2IV(ptr) + (x * SIZEOF_LONG))));
            ret = newRV_noinc(MUTABLE_SV(ret_av));
        }
    } break;
    case ULONG_FLAG: {
        if (len == 1)
            ret = newSViv(*(unsigned long *)ptr);
        else {
            AV *ret_av = newAV();
            DCpointer tmp = ptr;
            for (size_t x = 0; x < len; ++x)
                av_push(ret_av, newSViv(*(unsigned long *)INT2PTR(
                                    unsigned long *, PTR2IV(ptr) + (x * SIZEOF_ULONG))));
            ret = newRV_noinc(MUTABLE_SV(ret_av));
        }
    } break;
    case LONGLONG_FLAG: {
        if (len == 1)
            ret = newSViv(*(long long *)ptr);
        else {
            AV *ret_av = newAV();
            DCpointer tmp = ptr;
            for (size_t x = 0; x < len; ++x)
                av_push(ret_av, newSViv(*(long long *)INT2PTR(
                                    long long *, PTR2IV(ptr) + (x * SIZEOF_LONGLONG))));
            ret = newRV_noinc(MUTABLE_SV(ret_av));
        }
    } break;
    case ULONGLONG_FLAG: {
        if (len == 1)
            ret = newSViv(*(unsigned long long *)ptr);
        else {
            AV *ret_av = newAV();
            DCpointer tmp = ptr;
            for (size_t x = 0; x < len; ++x)
                av_push(ret_av, newSViv(*(unsigned long long *)INT2PTR(
                                    unsigned long long *, PTR2IV(ptr) + (x * SIZEOF_ULONGLONG))));
            ret = newRV_noinc(MUTABLE_SV(ret_av));
        }
    } break;
    case FLOAT_FLAG: {
        if (len == 1)
            ret = newSVnv(*(float *)ptr);
        else {
            AV *ret_av = newAV();
            DCpointer tmp = ptr;
            for (size_t x = 0; x < len; ++x)
                av_push(ret_av,
                        newSVnv(*(float *)INT2PTR(float *, PTR2IV(ptr) + (x * SIZEOF_FLOAT))));
            ret = newRV_noinc(MUTABLE_SV(ret_av));
        }
    } break;
    case DOUBLE_FLAG: {
        if (len == 1)
            ret = newSVnv(*(double *)ptr);
        else {
            AV *ret_av = newAV();
            DCpointer tmp = ptr;
            for (size_t x = 0; x < len; ++x)
                av_push(ret_av,
                        newSVnv(*(double *)INT2PTR(double *, PTR2IV(ptr) + (x * SIZEOF_DOUBLE))));
            ret = newRV_noinc(MUTABLE_SV(ret_av));
        }
    } break;

    case POINTER_FLAG: {
        SV *subtype = AXT_SUBTYPE(type);
        if (UNLIKELY(sv_derived_from(subtype, "Affix::Type::Pointer"))) {
            if (len == 1)
                ret = ptr2sv(aTHX_ subtype, *(DCpointer *)ptr);
            else {
                AV *ret_av = newAV();
                DCpointer tmp = ptr;
                for (size_t x = 0; x < len; ++x)
                    av_push(ret_av, ptr2sv(aTHX_ subtype,
                                           *(DCpointer *)INT2PTR(
                                               intptr_t *, PTR2IV(ptr) + (x * SIZEOF_INTPTR_T))));
                ret = newRV_noinc(MUTABLE_SV(ret_av));
            }
            break;
        }
    }
        // fallthrough
    case CONST_FLAG: { // No-Op
        SV *subtype = AXT_SUBTYPE(type);
        if (UNLIKELY(!sv_derived_from(subtype, "Affix::Type")))
            croak("subtype is not of type Affix::Type");
        ret = len ? ptr2sv(aTHX_ subtype, ptr, (size_t)AXT_POINTER_COUNT(subtype))
                  : ptr2sv(aTHX_ subtype, ptr);
    } break;
    default:
        croak("Attempt to marshal unknown/unhandled type in ptr2sv: %s", (char)AXT_NUMERIC(type),
              AXT_STRINGIFY(type));
    };
    return ret;
}

SV *ptr2av(pTHX_ DCpointer ptr, SV *type) {
    // #if DEBUG
    warn("ptr2av(%p, %s)) at %s line %d", ptr, AXT_STRINGIFY(type), __FILE__, __LINE__);
    // #endif
    PING;

    if (ptr == NULL) return newSV(0);

    SV *retval;
    {
        PING;

#if DEBUG > 1
        // size_t field_size = AXT_SIZEOF(type);
        // DumpHex(ptr, field_size);
#endif
        PING;
        AV *RETVAL_ = newAV_mortal();
        PING;

        SV *subtype = AXT_SUBTYPE(type);
        PING;

        size_t size = AXT_ARRAYLEN(type);
        PING;

        // TODO: dynamic size array
        size_t el_len = AXT_SIZEOF(subtype);
        PING;

        size_t pos = 0; // override
        warn("fyvyuudtivsryryustgjmdtgjjhmdctgdjchgh");
        switch (AXT_NUMERIC(subtype)) {
        case ARRAY_FLAG: {
            PING;

            void **_ptr = (void **)ptr;
            for (size_t i = 0; i < size; ++i) {
                av_push(RETVAL_, newRV(ptr2sv(aTHX_ subtype, _ptr[i])));
            }
        } break;
        default: {
            PING;

            for (size_t i = 0; i < size; ++i) {
                av_push(RETVAL_, ptr2sv(aTHX_ subtype, INT2PTR(DCpointer, PTR2IV(ptr) + pos)));
                pos += el_len;
            }
        }
        }
        PING;

        DD(MUTABLE_SV(RETVAL_));

        retval = MUTABLE_SV(RETVAL_);
        PING;
    }
#if DEBUG
    // warn("/ptr2av(%p, %s) at %s line %d", ptr, AXT_STRINGIFY(type), __FILE__, __LINE__);
    // DD(retval);
#endif
    return retval;
}
SV *ptr2svx(pTHX_ DCpointer ptr, SV *type) {
    PING;
    // #if DEBUG
    warn("ptr2sv(%p, %s) at %s line %d", ptr, AXT_STRINGIFY(type), __FILE__, __LINE__);
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
        switch (AXT_NUMERIC(type)) {
        case BOOL_FLAG: {
            warn("????? bool pointer");
            retval = newSV(0);
            sv_setbool_mg(retval, (bool)*(bool *)ptr);
        } break;
        case CHAR_FLAG:
        case SCHAR_FLAG: {
            retval = newSV(0);
            sv_setsv(retval, newSVpv((char *)ptr, strlen((char *)ptr)));
        } break;
        case UCHAR_FLAG: {
            retval = newSV(0);
            sv_setsv(retval, newSVpv((char *)(unsigned char *)ptr, strlen((char *)ptr)));
        } break;
        case WCHAR_FLAG: {
            if (wcslen((wchar_t *)ptr)) {
                retval = wchar2utf(aTHX_(wchar_t *) ptr, wcslen((wchar_t *)ptr));
            }
        } break;
        case SHORT_FLAG: {
            retval = newSViv(*(short *)ptr);
        } break;
        case USHORT_FLAG: {
            retval = newSVuv(*(unsigned short *)ptr);
        } break;
        case INT_FLAG: {
            retval = newSViv(*(int *)ptr);
        } break;
        case UINT_FLAG: {
            retval = newSVuv(*(unsigned int *)ptr);
        } break;
        case LONG_FLAG: {
            retval = newSViv(*(long *)ptr);
        } break;
        case ULONG_FLAG: {
            retval = newSVuv(*(unsigned long *)ptr);
        } break;
        case LONGLONG_FLAG: {
            retval = newSViv(*(long long *)ptr);
        } break;
        case ULONGLONG_FLAG: {
            retval = newSVuv(*(unsigned long long *)ptr);
        } break;
        case FLOAT_FLAG: {
            retval = newSVnv(*(float *)ptr);
        } break;
        case DOUBLE_FLAG: {
            retval = newSVnv(*(double *)ptr);
        } break;
        case STRING_FLAG: {
            char *str = (char *)*(void **)ptr;
            STRLEN len = strlen(str);
            retval = len ? newSVpv(str, len) : &PL_sv_undef;
        } break;
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
                    ptr2sv(aTHX_ subtype, INT2PTR(DCpointer, PTR2IV(ptr) + AXT_OFFSET(subtype))),
                    0);
            }
            SvSetSV(retval, newRV(MUTABLE_SV(RETVAL_)));
            //~ sv_dump(MUTABLE_SV(RETVAL_));
            //~ sv_dump(retval);
#endif
        } break;
        case ARRAY_FLAG: {
            retval = ptr2av(aTHX_ ptr, type);
        } break;
        case CODEREF_FLAG: {
            Callback *cb = (Callback *)dcbGetUserData((DCCallback *)((CallbackWrapper *)ptr)->cb);
            SvSetSV(retval, cb->cv);
        } break;
        case POINTER_FLAG: {
            SV *subtype = AXT_SUBTYPE(type);
            char subtype_c = AXT_NUMERIC(subtype);
            switch (subtype_c) {
            case CHAR_FLAG:
            case SCHAR_FLAG:
            case UCHAR_FLAG: {
                char *str = (char *)*(void **)&ptr;
                STRLEN len = strlen(str);
                retval = len ? newSVpv(str, len) : &PL_sv_undef;
            } break;
            case WCHAR_FLAG: {
                if (wcslen((wchar_t *)ptr)) {
                    retval = wchar2utf(aTHX_(wchar_t *) ptr, wcslen((wchar_t *)ptr));
                }
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
            default: {
                retval = ptr2sv(aTHX_ subtype, ptr);
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
        case CONST_FLAG:
            retval = ptr2sv(aTHX_ AXT_SUBTYPE(type), ptr);
            break;
        default:
            croak("Unhandled type: %s in ptr2sv", AXT_STRINGIFY(type));
        }
    }
    PING;
    // retval = sv_2mortal(retval);
    {
        PING;
        SV **typedef_sv = AXT_TYPEDEF(type);
        PING;

        if (typedef_sv != NULL) {
            // sv_bless(retval, SvSTASH(*typedef_ptr));
            PING;
            // retval = newSVrv(retval, SvPV_nolen(*typedef_ptr));
        }
    }
    PING;
#if DEBUG
    warn("/ptr2sv(%p, %s) at %s line %d", ptr, AXT_STRINGIFY(type), __FILE__, __LINE__);
    // DD(retval);
#endif
    return retval;
}

void *av2ptr(pTHX_ SV *type, AV *av_data) {
    warn("av2ptr(...)");
    PING;
    DD(type);

    // DCpointer ret = NULL;
    PING;

    //~ sv_dump(type);

    PING;

    SV *subtype = AXT_SUBTYPE(type);
    PING;
    int i_type = AXT_NUMERIC(type);
    PING;

#if DEBUG
    warn("av2ptr(%s, ...) at %s line %d", AXT_STRINGIFY(type), __FILE__, __LINE__);
#if DEBUG > 1
    DD(type);
    DD(MUTABLE_SV(av_data));
//~ sv_dump(av_data);
#endif
#endif
    PING;

    size_t size = AXT_ARRAYLEN(type);
    // if (size == 0)
    size = av_count(av_data);
    //~ warn("------------------ test, size == %ld", size);

    // XXX: THIS IS INCORRECT!!!!!!!!!!!!!!
    DCpointer ret = safemalloc(AXT_SIZEOF(type) * (size + 1));
    //~ if (size != NULL && SvOK(*size_ptr)) {
    //~ size_t av_len = av_count(av_data);
    //~ if (av_len != size) croak("Expected an array of %zu elements; found %zu", size, av_len);
    //~ }
    size_t el_len = AXT_SIZEOF(subtype);
    PING;
    size_t pos = 0; // override
    PING;
    switch (AXT_NUMERIC(subtype)) {
    case POINTER_FLAG:
    case ARRAY_FLAG: {
        warn("Here");
        PING;
        for (size_t i = 0; i < size; ++i) {
            PING;
            DCpointer block = sv2ptr(aTHX_ subtype, *(av_fetch(av_data, i, 0)));
            PING;
            Move(&block, INT2PTR(DCpointer, PTR2IV(ret) + pos), AXT_SIZEOF(subtype), char);
            PING;
            pos += el_len;
        }
    } break;
    default: {
        PING;
        warn("Not a deep array. %d elements", size);
        DD(MUTABLE_SV(av_data));

        for (size_t i = 0; i < size; ++i) {
            PING;
            DD(*(av_fetch(av_data, i, 0)));
            DCpointer block = sv2ptr(aTHX_ subtype, *(av_fetch(av_data, i, 0)));
            PING;
            Move(block, INT2PTR(DCpointer, PTR2IV(ret) + pos), AXT_SIZEOF(subtype), char);
            PING;
            //~ safefree(block);
            pos += el_len;
            PING;
        }
    }
    }
#if DEBUG
    warn("/av2ptr(%s, ...) => %p at %s line %d", AXT_STRINGIFY(type), ret, __FILE__, __LINE__);
#endif
    return ret;
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

    sv_dump(type);
    sv_dump(data);

    char type_c = AXT_NUMERIC(type);
    warn("Here %d", __LINE__);

    warn("type: %d/%c", type_c, type_c);
    PING;
    size_t size = AXT_SIZEOF(type);
    warn("after size: %d", size);
    PING;
#if DEBUG
    warn("sv2ptr(%s, ...) at %s line %d", AXT_STRINGIFY(type), __FILE__, __LINE__);
#if DEBUG > 1
    DD(data);
    DD(type);
#endif
#endif
    PING;
    switch (type_c) {
    case VOID_FLAG: {
        PING;
        if (!SvOK(data)) {
            ret = NULL;
            //~ ret = safemalloc(sizeof(intptr_t));
            //~ Zero(ret, 1, intptr_t);
        }
        else if (sv_derived_from(data, "Affix::Pointer")) {
            croak("UGH!");
            IV tmp = SvIV((SV *)SvRV(data));
            ret = INT2PTR(DCpointer, tmp);
        }
        else {
            croak("UGH!");
            size_t len;
            char *raw = SvPV(data, len);
            Renew(ret, len + 1, char);
            Copy((DCpointer)raw, ret, len + 1, char);
        }
    } break;
    case BOOL_FLAG: {
        PING;
        ret = safemalloc(SIZEOF_BOOL);
        bool value = SvOK(data) ? SvTRUE(data) : false; // default to false
        Copy(&value, ret, 1, bool);
    } break;
    case CHAR_FLAG: {
        warn("CHAR");
        PING;
        if (!SvOK(data)) { ret = safecalloc(SIZEOF_CHAR, 1); }
        else if (SvPOK(data)) {
            STRLEN len;
            DCpointer value = (DCpointer)SvPV(data, len);
            if (len) {
                warn("len: %d", len);
                ret = safecalloc(SIZEOF_CHAR, len + 1);
                Copy(value, ret, len + 1, char);
                DumpHex(ret, len + 1);
            }
            else
                ret = safecalloc(SIZEOF_CHAR, 1);
        }
        else {
            char value = SvIOK(data) ? SvIV(data) : 0;
            ret = safemalloc(SIZEOF_CHAR);
            Copy(&value, ret, 1, char);
        }
    } break;
    case UCHAR_FLAG: {
        PING;
        if (SvPOK(data)) {
            STRLEN len;
            DCpointer value = (DCpointer)SvPV(data, len);
            ret = safemalloc(SIZEOF_UCHAR * (len + 1));
            Copy(value, ret, len + 1, unsigned char);
        }
        else {
            unsigned char value = SvIOK(data) ? SvIV(data) : 0;
            ret = safemalloc(SIZEOF_UCHAR);
            Copy(&value, ret, 1, unsigned char);
        }
    } break;
    case WCHAR_FLAG: {
        PING;
        if (SvPOK(data)) {
            STRLEN len;
            (void)SvPVutf8(data, len);
            wchar_t *value = utf2wchar(aTHX_ data, len + 1);
            len = wcslen(value);
            Renew(ret, len + 1, wchar_t);
            Copy(value, ret, len + 1, wchar_t);
        }
        else {
            wchar_t value = SvIOK(data) ? SvIV(data) : 0;
            // Renew(ptr, 1, wchar_t);
            Copy(&value, ret, 1, wchar_t);
        }
    } break;
    case SHORT_FLAG: {
        PING;
        short value = SvOK(data) ? (short)SvIV(data) : 0;
        ret = safemalloc(sizeof(short));
        Copy(&value, ret, 1, short);
    } break;
    case USHORT_FLAG: {
        PING;
        unsigned short value = SvOK(data) ? (unsigned short)SvUV(data) : 0;
        ret = safemalloc(sizeof(unsigned short));
        Copy(&value, ret, 1, unsigned short);
    } break;
    case INT_FLAG: {
        PING;
        int value = SvOK(data) ? SvIV(data) : 0;
        ret = safemalloc(INTSIZE);
        Copy(&value, ret, 1, int);
    } break;
    case UINT_FLAG: {
        PING;
        unsigned int value = SvOK(data) ? SvUV(data) : 0;
        ret = safemalloc(sizeof(unsigned int));
        Copy(&value, ret, 1, unsigned int);
    } break;
    case LONG_FLAG: {
        PING;
        long value = SvOK(data) ? SvIV(data) : 0;
        ret = safemalloc(sizeof(long));
        Copy(&value, ret, 1, long);
    } break;
    case ULONG_FLAG: {
        PING;
        unsigned long value = SvOK(data) ? SvUV(data) : 0;
        ret = safemalloc(sizeof(unsigned long));
        Copy(&value, ret, 1, unsigned long);
    } break;
    case LONGLONG_FLAG: {
        PING;
        I64 value = SvOK(data) ? SvIV(data) : 0;
        ret = safemalloc(sizeof(long long));
        Copy(&value, ret, 1, I64);
    } break;
    case ULONGLONG_FLAG: {
        PING;
        U64 value = SvOK(data) ? SvUV(data) : 0;
        ret = safemalloc(sizeof(unsigned long long));
        Copy(&value, ret, 1, U64);
    } break;
    case FLOAT_FLAG: {
        float value = SvOK(data) ? SvNV(data) : 0;
        ret = safemalloc(sizeof(float));
        Copy(&value, ret, 1, float);
    } break;
    case DOUBLE_FLAG: {
        PING;
        double value = SvOK(data) ? SvNV(data) : 0;
        ret = safemalloc(sizeof(double));
        Copy(&value, ret, 1, double);
    } break;
    case POINTER_FLAG: {
        warn("POINTER");
        PING;
        SV *subtype = AXT_SUBTYPE(type);
        if (!SvOK(data)) { ret = safecalloc(AXT_SIZEOF(SvRV(subtype)), 1); }
        else if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
            warn("ARRAY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            ret = av2ptr(aTHX_ type, MUTABLE_AV(SvRV(data)));
        }
        else {
            DCpointer block = sv2ptr(aTHX_ subtype, data);
            ret = safemalloc(SIZEOF_INTPTR_T);
            Copy(block, ret, 1, intptr_t);
            safefree(block);
        }
    } break;
    case STRING_FLAG: {
        PING;
        if (SvPOK(data)) {
            STRLEN len;
            const char *str = SvPV(data, len);
            ret = safemalloc(SIZEOF_INTPTR_T);
            DCpointer value;
            Newxz(value, len + 1, char);
            Copy(str, value, len, char);
            Copy(&value, ret, 1, intptr_t);
        }
        else {
            const char *str = "";
            DCpointer value;
            ret = safemalloc(SIZEOF_CHAR);
            Newxz(value, 1, char);
            Copy(str, value, 1, char);
            Copy(&value, ret, 1, intptr_t);
        }
    } break;
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
        ret = safemalloc(AXT_SIZEOF(type));
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
                    Move(block, INT2PTR(DCpointer, PTR2IV(ret) + AXT_OFFSET(*type_ptr)),
                         AXT_SIZEOF(*type_ptr), char);
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
                    Move(block, INT2PTR(DCpointer, PTR2IV(ret) + AXT_OFFSET(*type_ptr)),
                         AXT_SIZEOF(*type_ptr), char);
                    safefree(block);
                    break;
                }
            }
        }
        else
            Zero(ret, 1, intptr_t);
    } break;
    case ARRAY_FLAG: {
        PING;
        warn("ARRAY");
        ret = safemalloc(size);
        if (SvOK(data)) {
            AV *elements;
            PING;
            if (SvPOK(data)) { // char[]
                PING;

                elements = newAV_mortal();
                STRLEN len;
                char *str = SvPV(data, len);
                for (size_t i = 0; i < len; ++i) {
                    av_push(elements, newSViv(str[i]));
                }
            }
            else
                elements = MUTABLE_AV(SvRV(data));
            PING;

            PING;

            // hv_stores(hv_ptr, "dyn_size", newSVuv(av_count(elements)));
            PING;

            ret = av2ptr(aTHX_ type, elements);
            PING;
        }
        else
            Zero(ret, 1, intptr_t);
        PING;

    } break;
    case CODEREF_FLAG: {
        if (SvOK(data)) {
            Callback *userdata;
            Newxz(userdata, 1, Callback);
            userdata->signature = SvPV_nolen(AXT_CODEREF_SIG(type));
            userdata->argtypes = AXT_CODEREF_ARGS(type);
            size_t arg_count = av_count(userdata->argtypes);
            userdata->restype = AXT_CODEREF_RET(type);
            userdata->restype_c = AXT_NUMERIC(userdata->restype);
            userdata->cv = SvREFCNT_inc(data);
            storeTHX(userdata->perl);
            Newxz(ret, 1, CallbackWrapper);
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
    case CONST_FLAG: {
        warn("CONST");
        PING;
        SV *subtype = AXT_SUBTYPE(type);
        /*
        if (!SvOK(data)) { ret = safecalloc(AXT_SIZEOF(SvRV(subtype)), 1); }
        else if (SvROK(data) && SvTYPE(SvRV(data)) == SVt_PVAV) {
            ret = av2ptr(aTHX_ subtype, MUTABLE_AV(SvRV(data)));
        }
        else {
            const DCpointer block = sv2ptr(aTHX_ subtype, data);
            ret = safemalloc(SIZEOF_INTPTR_T);
            Copy(block, ret, 1, intptr_t);
            safefree(block);
        }*/
        ret = sv2ptr(aTHX_ subtype, data);

    } break;
    default: {
        croak("%c is not a known type in sv2ptr(...)", type_c);
    }
    }
#if DEBUG
    warn("/sv2ptr(%s, ...) => %p at %s line %d", AXT_STRINGIFY(type), ret, __FILE__, __LINE__);
#endif
    return ret;
}
