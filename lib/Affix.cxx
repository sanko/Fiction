#include "Affix.h"
/*
G|-------------------0----------------|--0---4----------------------------||
D|.----------0---3-------0---3---0----|----------3---0-------0---3---0---.||
A|.------2----------------------------|----------------------------------.||
E|---3--------------------------------|------------------3----------------||
     1 . + . 2 . + . 3 . + . 4 . + .     1 . + . 2 . + . 3 . + . 4 . + .
*/
/* globals */
#define MY_CXT_KEY "Affix::_guts" XS_VERSION

typedef struct {
    DCCallVM *cvm;
} my_cxt_t;

START_MY_CXT

DLLib *load_library(const char *lib) {
    return
#if defined(DC__OS_Win64) || defined(DC__OS_MacOSX)
        dlLoadLibrary(lib);
#else
        (DLLib *)dlopen(lib, RTLD_LAZY /* RTLD_NOW|RTLD_GLOBAL */);
#endif
}

void free_library(DLLib *lib) {
    dlFreeLibrary(lib);
}

DCpointer find_symbol(DLLib *lib, const char *name) {
    return dlFindSymbol(lib, name);
}

XS_INTERNAL(Affix_dlerror) {
    dXSARGS;
    dXSI32;
#if defined(DC__OS_Win64)
    const
#endif
        char *ret = dlerror();

    if (!ret) XSRETURN_UNDEF;
    SV *sv_ret = sv_2mortal(newSVpv(ret, 0));
    ST(0) = sv_ret;
    XSRETURN(1);
}

XS_INTERNAL(Affix_load_library) {
    dXSARGS;
    if (items != 1) croak_xs_usage(cv, "$lib");
    DCpointer lib;
    if (!SvOK(ST(0)) && SvREADONLY(ST(0))) // explicit undef
        lib = load_library(NULL);
    else
        lib = load_library(SvPV_nolen(ST(0)));
    if (!lib) XSRETURN_UNDEF;
    SV *LIBSV = sv_newmortal();
    sv_setref_pv(LIBSV, "Affix::Lib", lib);
    ST(0) = LIBSV;
    XSRETURN(1);
}

XS_INTERNAL(Affix_free_library) {
    dVAR;
    dXSARGS;
    if (items != 1) croak_xs_usage(cv, "lib");
    DLLib *lib;
    //~ if (sv_derived_from(ST(0), "Affix::Lib")) {
    if (SvROK(ST(0))) {
        IV tmp = SvIV((SV *)SvRV(ST(0)));
        lib = INT2PTR(DLLib *, tmp);
    }
    else
        croak("lib is not of type Affix::Lib");
    if (lib != NULL) free_library(lib);
    lib = NULL;
    XSRETURN_EMPTY;
}

XS_INTERNAL(Affix_list_symbols) {
    /* dlSymsName(...) is not thread-safe on MacOS */
    dVAR;
    dXSARGS;
    if (items != 1) croak_xs_usage(cv, "lib");
    AV *RETVAL;
    DLLib *lib;
    if (SvROK(ST(0))) {
        IV tmp = SvIV((SV *)SvRV(ST(0)));
        lib = INT2PTR(DLLib *, tmp);
    }
    else
        croak("lib is not of type Affix::Lib");
    RETVAL = newAV_mortal();
    char *name;
    Newxz(name, 1024, char);
    int len = dlGetLibraryPath(lib, name, 1024);
    if (len == 0) croak("Failed to get library name");
    DLSyms *syms = dlSymsInit(name);
    int count = dlSymsCount(syms);
    for (int i = 0; i < count; ++i) {
        const char *symbolName = dlSymsName(syms, i);
        if (strlen(symbolName)) av_push(RETVAL, newSVpv(symbolName, 0));
    }
    dlSymsCleanup(syms);
    safefree(name);
    ST(0) = newRV_noinc(MUTABLE_SV(RETVAL));
    XSRETURN(1);
}

XS_INTERNAL(Affix_find_symbol) {
    dVAR;
    dXSARGS;
    if (items != 2) croak_xs_usage(cv, "$lib, $symbol");
    AV *RETVAL;
    DLLib *lib;
    {
        if (!SvOK(ST(0)) && SvREADONLY(ST(0))) // explicit undef
            lib = load_library(NULL);
        else if (sv_isobject(ST(0)) && sv_derived_from(ST(0), "Affix::Lib")) {
            IV tmp = SvIV((SV *)SvRV(ST(0)));
            lib = INT2PTR(DLLib *, tmp);
        }
        else if (SvPOK(ST(0)) || (sv_isobject(ST(0)) && sv_derived_from(ST(0), "Path::Tiny")))
            lib = load_library(SvPV_nolen(ST(0)));
        if (!lib) XSRETURN_UNDEF;
    }
    RETVAL = newAV_mortal();
    char *name;
    Newxz(name, 1024, char);

    DCpointer lib_handle = find_symbol(lib, SvPV_nolen(ST(1)));
    if (!lib_handle) { croak("Failed to load lib %s", dlerror()); }
    SV *LIBSV = sv_newmortal();
    sv_setref_pv(LIBSV, NULL, (DCpointer)lib_handle);
    ST(0) = LIBSV;
    XSRETURN(1);
}

XS_INTERNAL(Affix_fiction) {
    dXSARGS;
    dXSI32;
    if (items < 2 || items > 4) croak_xs_usage(cv, "$lib, $symbol, [$argtypes, $rettype]");
    fiction *ret;
    Newxz(ret, 1, fiction);
    char *prototype = NULL;
    char *name;
    {
        SV *const xsub_tmp_sv = ST(0);
        SvGETMAGIC(xsub_tmp_sv);

        if (!SvOK(xsub_tmp_sv) && SvREADONLY(xsub_tmp_sv)) // explicit undef
            ret->lib = load_library(NULL);
        else if (sv_isobject(xsub_tmp_sv) && sv_derived_from(xsub_tmp_sv, "Affix::Lib")) {
            IV tmp = SvIV((SV *)SvRV(xsub_tmp_sv));
            ret->lib = INT2PTR(DLLib *, tmp);
        }
        else if (NULL == (ret->lib = load_library(SvPV_nolen(xsub_tmp_sv)))) {
            Stat_t statbuf;
            Zero(&statbuf, 1, Stat_t);
            if (PerlLIO_stat(SvPV_nolen(xsub_tmp_sv), &statbuf) < 0) {
                ENTER;
                SAVETMPS;
                PUSHMARK(SP);
                XPUSHs(xsub_tmp_sv);
                PUTBACK;
                int count = call_pv("Affix::find_library", G_SCALAR);
                SPAGAIN;
                ret->lib = load_library(SvPV_nolen(POPs));
                PUTBACK;
                FREETMPS;
                LEAVE;
            }
        }
        if (!ret->lib) {
            // TODO: Throw an error
            safefree(ret);
            croak("Failed to load library");
            XSRETURN_UNDEF;
        }
    }
    {
        SV *symbol;
        SV *const xsub_tmp_sv = ST(1);
        SvGETMAGIC(xsub_tmp_sv);
        if (SvROK(xsub_tmp_sv) && SvTYPE(SvRV(xsub_tmp_sv)) == SVt_PVAV) {
            //~ AV *tmp = MUTABLE_AV(SvRV(xsub_tmp_sv));
            AV *tmp = MUTABLE_AV(SvREFCNT_inc(SvRV(xsub_tmp_sv)));
            size_t tmp_len = av_count(tmp);
            if (tmp_len != 2) { croak("Expected a symbol and name"); }
            if (ix == 1 && tmp_len > 1) {
                warn("wrap( ... ) isn't expecting a name and has ignored it");
            }
            symbol = *av_fetch(tmp, 0, false);
            if (!SvPOK(symbol)) { croak("Undefined symbol name"); }
            ret->symbol = SvPV_nolen(*av_fetch(tmp, 0, false));
            name = SvPV_nolen(*av_fetch(tmp, 1, false));
        }
        else if (SvPOK(xsub_tmp_sv)) {
            symbol = xsub_tmp_sv;
            ret->symbol = name = SvPV_nolen(symbol);
        }
        ret->entry_point = find_symbol(ret->lib, ret->symbol);

        if (!ret->entry_point) {
            safefree(ret);
            croak("Failed to locate entry point named %s", ret->symbol);
            XSRETURN_UNDEF;
        }
    }
    {
        ret->signature = NULL;
        ret->restype = NULL;
        ret->restype_c = VOID_FLAG;

        switch (items) {
        case 4:
            ret->restype = newSVsv(ST(3));
            ret->restype_c = AXT_NUMERIC(ret->restype);
            switch (ret->restype_c) {
            case WCHAR_FLAG:
            case WSTRING_FLAG:
            case STDSTRING_FLAG:
                ret->res = newSVpvs("");
                break;
            default:
                ret->res = newSV(0);
                break;
            }
        // fallthrough
        case 3: {
            SV *const xsub_tmp_sv = ST(2);
            SvGETMAGIC(xsub_tmp_sv);
            if (!SvOK(xsub_tmp_sv) && SvREADONLY(xsub_tmp_sv)) { // explicit undef
                ret->signature = NULL;
                ret->argtypes = NULL;
            }
            else if (SvROK(xsub_tmp_sv) && SvTYPE(SvRV(xsub_tmp_sv)) == SVt_PVAV) {
                ret->argtypes = MUTABLE_AV(SvREFCNT_inc(SvRV(xsub_tmp_sv)));
                size_t sig_len = av_count(ret->argtypes);
                Newxz(ret->signature, sig_len * 2, char); // extra room
                Newxz(prototype, sig_len + 1, char);
                char c_type;
                char scalar = '$';
                char array = '@';
                char code = '&';
                for (size_t i = 0; i < sig_len; i++) {
                    c_type = AXT_NUMERIC(*av_fetch(ret->argtypes, i, 0));
                    Copy(&c_type, ret->signature + i, 1, char);
                    // TODO: Generate a valid prototype w/ Array, Callbacks, etc.
                    Copy(&scalar, prototype + i, 1, char);
                }
                //~ warn("ret->signature: %s", ret->signature);
            }
        } break;
            //~ default:
            //~ croak("Something's wrong!");
        }
    }
    STMT_START {
        cv = newXSproto_portable(ix == 0 ? name : NULL, Fiction_trigger, __FILE__, prototype);
        if (ret->symbol == NULL) ret->symbol = "anonymous subroutine";
        if (UNLIKELY(cv == NULL))
            croak("ARG! Something went really wrong while installing a new XSUB!");
        XSANY.any_ptr = (DCpointer)ret;
        if (prototype != NULL) safefree(prototype);
    }
    STMT_END;

    ST(0) = sv_2mortal(
        sv_bless((UNLIKELY(ix == 1) ? newRV_noinc(MUTABLE_SV(cv)) : newRV_inc(MUTABLE_SV(cv))),
                 gv_stashpv("Affix", GV_ADD)));
    XSRETURN(1);
}

XS_INTERNAL(Affix_DESTROY) {
    dXSARGS;
    PERL_UNUSED_VAR(items);
    fiction *fiction;
    STMT_START { // peel this grape
        HV *st;
        GV *gvp;
        SV *const xsub_tmp_sv = ST(0);
        SvGETMAGIC(xsub_tmp_sv);
        CV *cv = sv_2cv(xsub_tmp_sv, &st, &gvp, 0);
        fiction = (struct fiction *)XSANY.any_ptr;
    }
    STMT_END;
    if (fiction != NULL) {
        //~ if (fiction->entry_point) safefree(fiction->entry_point);
        if (fiction->signature) safefree((DCpointer)fiction->signature);
        //~ if (fiction->argtypes) sv_2mortal(MUTABLE_SV(fiction->argtypes));
        //~ if (fiction->restype) sv_2mortal(fiction->restype);
        //~ if (fiction->res) sv_2mortal(fiction->res);
        if (fiction->lib) dlFreeLibrary(fiction->lib);
    }
    Safefree(fiction);
    fiction = NULL;
    XSRETURN_EMPTY;
}

extern "C" void Fiction_trigger(pTHX_ CV *cv) {
    dSP;
    dAXMARK;

    fiction *a = (fiction *)XSANY.any_ptr;
    size_t items = (SP - MARK);

    dMY_CXT;
    DCCallVM *cvm = MY_CXT.cvm;
    dcReset(cvm);
    /*
    #define WSTRING_FLAG '<'

    #define STRUCT_FLAG 'A'
    #define CPPSTRUCT_FLAG 'B'
    #define UNION_FLAG 'u'
    #define ARRAY_FLAG '@'
    #define CODEREF_FLAG '&'
    #define POINTER_FLAG 'P'
    #define SV_FLAG '?'
        */
    if (a->signature != NULL) {
        size_t sig_len = strlen(a->signature);
        if (items != sig_len)
            croak("%s arguments for %s; expected %ld, found %ld)",
                  items > sig_len ? "Too many" : "Not enough", a->symbol, sig_len, items);

        for (size_t sig_pos = 0, st_pos = 0; sig_pos < sig_len; sig_pos++, st_pos++) {
            switch (a->signature[sig_pos]) {
            case VOID_FLAG:
                break; // ...skip?
            case BOOL_FLAG:
                dcArgBool(cvm, SvTRUE(ST(st_pos))); // Anything can be a bool
                break;
            case SCHAR_FLAG:
            case CHAR_FLAG: {
                SV *arg = ST(st_pos);
                if (SvIOK(arg)) { dcArgChar(cvm, (I8)SvIV(arg)); }
                else {
                    STRLEN len;
                    char *value = SvPVbyte(arg, len);
                    if (len > 1) { warn("Expected a single character; found %ld", len); }
                    dcArgChar(cvm, (I8)value[0]);
                }
                break;
            }
            case UCHAR_FLAG: {
                SV *arg = ST(st_pos);
                if (SvIOK(arg)) { dcArgChar(cvm, (U8)SvIV(arg)); }
                else {
                    STRLEN len;
                    char *value = SvPVbyte(arg, len);
                    if (len > 1) { warn("Expected a single unsigned character; found %ld", len); }
                    dcArgChar(cvm, (U8)value[0]);
                }
                break;
            }
            case WCHAR_FLAG: {
                SV *arg = ST(st_pos);
                if (SvOK(arg)) {
                    wchar_t *str = utf2wchar(aTHX_ ST(st_pos), 1);
#if WCHAR_MAX == LONG_MAX
                    // dcArgLong(cvm, str[0]);
#elif WCHAR_MAX == INT_MAX
                    // dcArgInt(cvm, str[0]);
#elif WCHAR_MAX == SHORT_MAX
                    // dcArgShort(cvm, str[0]);
#else
                    // dcArgChar(cvm, str[0]);
#endif
                    dcArgLong(cvm, str[0]);
                    safefree(str);
                }
                else
                    dcArgInt(cvm, 0);
                break;
            }
            case SHORT_FLAG:
                dcArgShort(cvm, SvIV(ST(st_pos)));
                break;
            case USHORT_FLAG:
                dcArgShort(cvm, SvUV(ST(st_pos)));
                break;
            case INT_FLAG:
                dcArgInt(cvm, SvIV(ST(st_pos)));
                break;
            case UINT_FLAG:
                dcArgInt(cvm, SvUV(ST(st_pos)));
                break;
            case LONG_FLAG:
                dcArgLong(cvm, SvIV(ST(st_pos)));
                break;
            case ULONG_FLAG:
                dcArgLong(cvm, SvUV(ST(st_pos)));
                break;
            case LONGLONG_FLAG:
                dcArgLongLong(cvm, SvIV(ST(st_pos)));
                break;
            case ULONGLONG_FLAG:
                dcArgLongLong(cvm, SvUV(ST(st_pos)));
                break;
            case FLOAT_FLAG:
                dcArgFloat(cvm, SvNV(ST(st_pos)));
                break;
            case DOUBLE_FLAG:
                dcArgDouble(cvm, SvNV(ST(st_pos)));
                break;
            case WSTRING_FLAG: { /*
                 DCpointer ptr = NULL;
                 SV *arg = ST(st_pos);
                 if (SvOK(arg)) {
                     if (a->temp_ptrs == NULL) Newxz(a->temp_ptrs, num_args, DCpointer);
                     a->temp_ptrs[st_pos] =
                         sv2ptr(aTHX_ MUTABLE_SV(affix->arg_info[arg_pos]), arg);
                     ptr = *(DCpointer *)(a->temp_ptrs[st_pos]);
                 }
                 dcArgPointer(cvm, ptr);*/
                break;
            }
            case STDSTRING_FLAG: {
                SV *arg = ST(st_pos);
                std::string tmp = SvOK(arg) ? SvPV_nolen(arg) : NULL;
                dcArgPointer(cvm, static_cast<void *>(&tmp));
                break;
            }
            case CODEREF_FLAG: {
                dcArgPointer(cvm, sv2ptr(aTHX_ * av_fetch(a->argtypes, st_pos, 0), ST(st_pos)));
                break;
            }

                //~ #define STRING_FLAG 'z'
                //~ #define WSTRING_FLAG '<'
                //~ #define STDSTRING_FLAG 'Y'
                //~ #define STRUCT_FLAG 'A'
                //~ #define CPPSTRUCT_FLAG 'B'
                //~ #define UNION_FLAG 'u'
                //~ #define ARRAY_FLAG '@'
                //~ #define CODEREF_FLAG '&'
            case POINTER_FLAG: {
                //~ sv_dump(*av_fetch(a->argtypes, st_pos, 0));
                //~ sv_dump(AXT_SUBTYPE(*av_fetch(a->argtypes, st_pos, 0)));

                SV *const xsub_tmp_sv = ST(st_pos);
                SvGETMAGIC(xsub_tmp_sv);

                dcArgPointer(
                    cvm, sv2ptr(aTHX_ AXT_SUBTYPE(*av_fetch(a->argtypes, st_pos, 0)), xsub_tmp_sv));
                break;
            }
            default:
                croak("Unhandled type! %c", a->signature[sig_pos]);
            }
        }
    }
    else {
        for (size_t i = 0; i < items; i++) {
            //~ warn("i: %d, %d", i, SvIV(ST(i)));
            if (SvNOK(ST(i)))
                dcArgDouble(cvm, SvNV(ST(i)));
            else if (SvUOK(ST(i)))
                dcArgInt(cvm, SvUV(ST(i)));
            else if (SvIOK(ST(i)))
                dcArgInt(cvm, SvIV(ST(i)));
        }
    }

    warn("a->restype_c: %c", a->restype_c);

    switch (a->restype_c) {
    case VOID_FLAG:
        dcCallVoid(cvm, a->entry_point);
        // sv_set_undef(a->res);
        break;
    case BOOL_FLAG:
        sv_setsv(a->res, boolSV(dcCallBool(cvm, a->entry_point)));
        break;
    case CHAR_FLAG:
    case SCHAR_FLAG: {
        char value[1];
        value[0] = dcCallChar(cvm, a->entry_point);
        sv_setsv(a->res, newSVpv(value, 1));
        (void)SvUPGRADE(a->res, SVt_PVIV);
        SvIV_set(a->res, ((IV)value[0]));
        SvIOK_on(a->res);
        sv_dump(a->res);
    } break;
    case UCHAR_FLAG: {
        char value[1];
        value[0] = dcCallChar(cvm, a->entry_point);
        sv_setsv(a->res, newSVpv(value, 1));
        (void)SvUPGRADE(a->res, SVt_PVIV);
        SvIV_set(a->res, ((UV)value[0]));
        SvIOK_on(a->res);
    } break;
    case WCHAR_FLAG: {
        wchar_t src[1];
        src[0] = (wchar_t)dcCallLong(cvm, a->entry_point);
        a->res = wchar2utf(aTHX_ src, 1);
    } break;
    case SHORT_FLAG:
        sv_setiv(a->res, (short)dcCallShort(cvm, a->entry_point));
        break;
    case USHORT_FLAG:
        sv_setuv(a->res, (unsigned short)dcCallShort(cvm, a->entry_point));
        break;
    case INT_FLAG:
        sv_setiv(a->res, dcCallInt(cvm, a->entry_point));
        break;
    case UINT_FLAG:
        sv_setuv(a->res, dcCallInt(cvm, a->entry_point));
        break;
    case LONG_FLAG:
        sv_setiv(a->res, dcCallLong(cvm, a->entry_point));
        break;
    case ULONG_FLAG:
        sv_setuv(a->res, dcCallLong(cvm, a->entry_point));
        break;
    case LONGLONG_FLAG:
        sv_setiv(a->res, dcCallLongLong(cvm, a->entry_point));
        break;
    case ULONGLONG_FLAG:
        sv_setuv(a->res, dcCallLongLong(cvm, a->entry_point));
        break;
    case FLOAT_FLAG:
        sv_setnv(a->res, dcCallFloat(cvm, a->entry_point));
        break;
    case DOUBLE_FLAG:
        sv_setnv(a->res, dcCallDouble(cvm, a->entry_point));
        break;

        //~ #define STRING_FLAG 'z'
        //~ #define WSTRING_FLAG '<'
        //~ #define STDSTRING_FLAG 'Y'
        //~ #define STRUCT_FLAG 'A'
        //~ #define CPPSTRUCT_FLAG 'B'
        //~ #define UNION_FLAG 'u'
        //~ #define ARRAY_FLAG '@'
        //~ #define CODEREF_FLAG '&'
        //~ #define POINTER_FLAG 'P'

    case POINTER_FLAG: {
        warn("...pointer 0");
        DCpointer ret = dcCallPointer(cvm, a->entry_point);
        warn("...pointer 1 [%p]", ret);
        typedef void (*ptr)(void);

        ptr fn = (ptr)ret;

        //~ fn();

        if (ret == NULL)
            sv_set_undef(a->res);
        else
            sv_setsv(a->res, sv_2mortal(ptr2sv(aTHX_ a->restype, ret)));
        warn("...pointer 2");

    } break;
    default:
        croak("Unknown or unhandled return type: %c", a->restype_c);
    };

    //~ sv_setnv(a->res, dcCallDouble(cvm, a->entry_point));
    if (a->res != NULL) ST(0) = a->res;
    XSRETURN(1);
}

extern "C" void Affix_trigger(pTHX_ CV *cv) {
    dSP;
    dAXMARK;

    Affix *affix = (Affix *)XSANY.any_ptr;
    size_t items = (SP - MARK);

    size_t num_args = affix->num_args;

    // This is dumb and wastes time
    if (!affix->ellipsis) {
        int __num_args = num_args;
        if (affix->_cpp_struct && !affix->_cpp_constructor) ++__num_args;
        if (UNLIKELY(items != __num_args)) {
            if (UNLIKELY(items > __num_args))
                croak("Too many arguments; wanted %d, found %d", __num_args, items);
            croak("Not enough arguments; wanted %d, found %d", __num_args, items);
        }
    }

    dMY_CXT;
    DCCallVM *cvm = MY_CXT.cvm;

    dcReset(cvm);
    bool reset_mode = false;

    size_t st_pos = 0, arg_pos = 0;

    DCpointer this_ptr = NULL;
    char *package = NULL;

    if (affix->_cpp_constructor) {
        Newxz(this_ptr, 1, intptr_t);
        dcArgPointer(cvm, this_ptr);
        package = SvPV_nolen(ST(st_pos++));
    }

    for (; st_pos < num_args; ++st_pos, ++arg_pos) {
        PING;
        warn("!!! affix->arg_types[arg_pos] == %d", affix->arg_types[arg_pos]);
        switch (affix->arg_types[arg_pos]) {
        // calling conventions first
        case RESET_FLAG: {
            PING;
            dcMode(cvm, DC_CALL_C_DEFAULT);
            dcReset(cvm);
            --st_pos;
        } break;
        case THIS_FLAG: {
            PING;
            reset_mode = true;
            dcMode(cvm, DC_CALL_C_DEFAULT_THIS);
            dcReset(cvm);
            --st_pos;
        } break;
        case ELLIPSIS_FLAG: {
            PING;
            reset_mode = true;
            dcMode(cvm, DC_CALL_C_ELLIPSIS);
            if (st_pos == items)
                dcArgPointer(cvm, NULL);
            else
                --st_pos;
        } break;
        case VARARGS_FLAG: {
            PING;
            reset_mode = true;
            dcMode(cvm, DC_CALL_C_ELLIPSIS_VARARGS);
            if (st_pos == items)
                dcArgPointer(cvm, NULL);
            else
                --st_pos;
        } break;
        case DCECL_FLAG: {
            PING;
            dcMode(cvm, DC_CALL_C_X86_CDECL);
            dcReset(cvm);
            --st_pos;
        } break;
        case STDCALL_FLAG: {
            PING;
            dcMode(cvm, DC_CALL_C_X86_WIN32_STD);
            dcReset(cvm);
            --st_pos;
        } break;
        case MSFASTCALL_FLAG: {
            PING;
            dcMode(cvm, DC_CALL_C_X86_WIN32_FAST_MS);
            dcReset(cvm);
            --st_pos;
        } break;
        case GNUFASTCALL_FLAG: {
            PING;
            dcMode(cvm, DC_CALL_C_X86_WIN32_FAST_GNU);
            dcReset(cvm);
            --st_pos;
        } break;
        case MSTHIS_FLAG: {
            PING;
            dcMode(cvm, DC_CALL_C_X86_WIN32_THIS_MS);
            dcReset(cvm);
            --st_pos;
        } break;
        case GNUTHIS_FLAG: {
            PING;
            dcMode(cvm, DC_CALL_C_X86_WIN32_THIS_GNU);
            dcReset(cvm);
            --st_pos;
        } break;
        case ARM_FLAG: {
            PING;
            dcMode(cvm, DC_CALL_C_ARM_ARM);
            dcReset(cvm);
            --st_pos;
        } break;
        case THUMB_FLAG: {
            PING;
            dcMode(cvm, DC_CALL_C_ARM_THUMB);
            dcReset(cvm);
            --st_pos;
        } break;
        case SYSCALL_FLAG: {
            PING;
            dcMode(cvm, DC_CALL_SYS_DEFAULT);
            dcReset(cvm);
            --st_pos;
        } break;
        // Work on arg types
        case VOID_FLAG: {
            PING;
        } break;
        case BOOL_FLAG: {
            PING;
            dcArgBool(cvm, SvTRUE(ST(st_pos))); // Anything can be a bool
        } break;
        case SCHAR_FLAG:
        case CHAR_FLAG: {
            PING;
            SV *arg = ST(st_pos);
            if (SvIOK(arg)) { dcArgChar(cvm, (I8)SvIV(arg)); }
            else {
                STRLEN len;
                char *value = SvPVbyte(arg, len);
                if (len > 1) { warn("Expected a single character; found %ld", len); }
                dcArgChar(cvm, (I8)value[0]);
            }
        } break;
        case UCHAR_FLAG: {
            PING;
            SV *arg = ST(st_pos);
            if (SvIOK(arg)) { dcArgChar(cvm, (U8)SvIV(arg)); }
            else {
                STRLEN len;
                char *value = SvPVbyte(arg, len);
                if (len > 1) { warn("Expected a single unsigned character; found %ld", len); }
                dcArgChar(cvm, (U8)value[0]);
            }
        } break;
        case WCHAR_FLAG: {
            PING;
            int value = 0;
            SV *arg = ST(st_pos);
            if (SvOK(arg)) {
                char *eh = SvPV_nolen(arg);
                PUTBACK;
                const char *pat = "W";
                SSize_t s = unpackstring(pat, pat + 1, eh, eh + SIZEOF_WCHAR + 1, SVt_PVAV);
                SPAGAIN;
                if (UNLIKELY(s != 1)) croak("Failed to unpack wchar_t");
                value = POPi;
            }
#if WCHAR_MAX == LONG_MAX
            dcArgLong(cvm, value);
#elif WCHAR_MAX == INT_MAX
            dcArgInt(cvm, value);
#elif WCHAR_MAX == SHORT_MAX
            dcArgShort(cvm, value);
#else
            dcArgChar(cvm, value);
#endif
        } break;
        case SHORT_FLAG: {
            PING;
            dcArgShort(cvm, SvIV(ST(st_pos)));
        } break;
        case USHORT_FLAG: {
            PING;
            dcArgShort(cvm, SvUV(ST(st_pos)));
        } break;
        case INT_FLAG: {
            PING;
            dcArgInt(cvm, SvIV(ST(st_pos)));
        } break;
        case UINT_FLAG: {
            PING;
            dcArgInt(cvm, SvUV(ST(st_pos)));
        } break;
        case LONG_FLAG: {
            PING;
            dcArgLong(cvm, SvIV(ST(st_pos)));
        } break;
        case ULONG_FLAG: {
            PING;
            dcArgLong(cvm, SvUV(ST(st_pos)));
        } break;
        case LONGLONG_FLAG: {
            PING;
            dcArgLongLong(cvm, SvIV(ST(st_pos)));
        } break;
        case ULONGLONG_FLAG: {
            PING;
            dcArgLongLong(cvm, SvUV(ST(st_pos)));
        } break;
        case FLOAT_FLAG: {
            PING;
            dcArgFloat(cvm, SvNV(ST(st_pos)));
        } break;
        case DOUBLE_FLAG: {
            PING;
            dcArgDouble(cvm, SvNV(ST(st_pos)));
        } break;
        case WSTRING_FLAG: {
            PING;
            DCpointer ptr = NULL;
            SV *arg = ST(st_pos);
            if (SvOK(arg)) {
                if (affix->temp_ptrs == NULL) Newxz(affix->temp_ptrs, num_args, DCpointer);
                affix->temp_ptrs[st_pos] = sv2ptr(aTHX_ MUTABLE_SV(affix->arg_info[arg_pos]), arg);
                ptr = *(DCpointer *)(affix->temp_ptrs[st_pos]);
            }
            dcArgPointer(cvm, ptr);
        } break;
        case STDSTRING_FLAG: {
            PING;
            SV *arg = ST(st_pos);
            std::string tmp = SvOK(arg) ? SvPV_nolen(arg) : NULL;
            dcArgPointer(cvm, static_cast<void *>(&tmp));
        } break;
        case STRUCT_FLAG:
        case CPPSTRUCT_FLAG:
        case UNION_FLAG: {
            PING;
            SV *arg = ST(st_pos);
            if (!SvOK(arg) && SvREADONLY(arg)) { // explicit undef
                PING;
                dcArgPointer(cvm, NULL);
            }
            else if (SvOK(arg) && sv_derived_from(arg, "Affix::Pointer")) {
                PING;
                IV tmp = SvIV(SvRV(arg));
                dcArgPointer(cvm, INT2PTR(DCpointer, tmp));
            }
            else {
                PING;
                if (affix->temp_ptrs == NULL) Newxz(affix->temp_ptrs, num_args, DCpointer);
                if (!SvROK(arg) || SvTYPE(SvRV(arg)) != SVt_PVHV)
                    croak("Type of arg %d must be an hash ref", arg_pos + 1);
                SV *type = MUTABLE_SV(affix->arg_info[arg_pos]);
                affix->temp_ptrs[st_pos] = sv2ptr(aTHX_ type, arg);
                dcArgAggr(cvm, affix->aggregates[st_pos], affix->temp_ptrs[st_pos]);
            }
        } break;
        case CODEREF_FLAG: {
            PING;
            SV *arg = ST(st_pos);
            if (SvOK(arg)) {
                PING;
                CodeRefWrapper *hold =
                    (CodeRefWrapper *)sv2ptr(aTHX_ MUTABLE_SV(affix->arg_info[arg_pos]), arg);
                dcArgPointer(cvm, hold->cb);
            }
            else {
                PING;
                dcArgPointer(cvm, NULL);
            }
        } break;
        case POINTER_FLAG: {
            PING;
            warn("POINTER!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            SV *arg = ST(st_pos);
            if (UNLIKELY(!SvOK(arg) && SvREADONLY(arg))) { // explicit undef
                warn("ASEEEA");
                PING;
                dcArgPointer(cvm, NULL);
                break;
            }
            if (SvROK(arg)) { // Might be a reference which we will handle as an lvalue on return
                PING;
                warn("EADFEA");

                arg = MUTABLE_SV(SvRV(arg));
                if (UNLIKELY(!SvOK(arg) && SvREADONLY(arg))) { // explicit undef
                    dcArgPointer(cvm, NULL);
                    break;
                }
                else {

                    if (affix->temp_ptrs == NULL) Newxz(affix->temp_ptrs, num_args, DCpointer);

                    affix->temp_ptrs[st_pos] =
                        sv2ptr(aTHX_ MUTABLE_SV(affix->arg_info[arg_pos]), ST(st_pos));
                    // safemalloc(AXT_SIZEOF(AXT_SUBTYPE(MUTABLE_SV(affix->arg_info[arg_pos]))));
                    dcArgPointer(cvm, affix->temp_ptrs[st_pos]);
                }
            }
            else if (SvOK(arg)) {
                PING;
                warn("FDSA");

                if (sv_derived_from(arg, "Affix::Pointer")) {
                    PING;

                    // pass pointers directly through
                    IV tmp = SvIV(SvRV(arg));
                    dcArgPointer(cvm, INT2PTR(DCpointer, tmp));
                }
                else {
                    PING;
                    if (affix->temp_ptrs == NULL) Newxz(affix->temp_ptrs, num_args, DCpointer);
                    PING;
                    SV *type = MUTABLE_SV(affix->arg_info[arg_pos]);
                    PING;
                    SV **package_ptr = AXT_TYPEDEF(type);
                    PING;
                    if (UNLIKELY(package_ptr != NULL) && UNLIKELY(SvOK(arg) && sv_isobject(arg)) &&
                        SvOK(*package_ptr) && !sv_derived_from_sv(arg, *package_ptr, SVf_UTF8)) {
                        PING;
                        croak("Expected a subclass of %s in argument %d", SvPV_nolen(*package_ptr),
                              st_pos + 1);
                    }
                    PING;
                    affix->temp_ptrs[st_pos] = sv2ptr(aTHX_ type, arg);
                    PING;
                    dcArgPointer(cvm, affix->temp_ptrs[st_pos]);
                }
            }
            else {
                warn("D");

                PING;
                if (affix->temp_ptrs == NULL) Newxz(affix->temp_ptrs, num_args, DCpointer);
                affix->temp_ptrs[st_pos] =
                    safemalloc(AXT_SIZEOF(AXT_SUBTYPE(MUTABLE_SV(affix->arg_info[arg_pos]))));
                dcArgPointer(cvm, affix->temp_ptrs[st_pos]);
            }
        } break;
        default: {
            croak("Unhandled argument type %s at %s line %d",
                  SvPV_nolen(MUTABLE_SV(affix->arg_info[arg_pos])), __FILE__, __LINE__);
        }
        }
    }
    PING;
    SV *RETVAL = NULL;
    switch (affix->ret_type) {
    case VOID_FLAG: {
        PING;
        dcCallVoid(cvm, affix->entry_point);
    } break;
    case BOOL_FLAG: {
        PING;
        RETVAL = boolSV(dcCallBool(cvm, affix->entry_point));
    } break;
    case SCHAR_FLAG:
    case CHAR_FLAG: {
        PING;
        char value[1];
        value[0] = dcCallChar(cvm, affix->entry_point);
        RETVAL = newSV(0);
        sv_setsv(RETVAL, newSVpv(value, 1));
        (void)SvUPGRADE(RETVAL, SVt_PVIV);
        SvIV_set(RETVAL, ((IV)value[0]));
        SvIOK_on(RETVAL);
    } break;
    case UCHAR_FLAG: {
        PING;
        unsigned char value[1];
        value[0] = dcCallChar(cvm, affix->entry_point);
        RETVAL = newSV(0);
        sv_setsv(RETVAL, newSVpv((char *)value, 1));
        (void)SvUPGRADE(RETVAL, SVt_PVIV);
        SvIV_set(RETVAL, ((UV)value[0]));
        SvIOK_on(RETVAL);
    } break;
    case WCHAR_FLAG: {
        PING;
        SV *container;
        RETVAL = newSVpvs("");
        const char *pat = "W";
#if WCHAR_MAX == LONG_MAX
        container = sv_2mortal(newSViv((int)dcCallLong(cvm, affix->entry_point)));
#elif WCHAR_MAX == INT_MAX
        container = newSViv((int)dcCallInt(cvm, affix->entry_point));
#elif WCHAR_MAX == SHORT_MAX
        container = newSViv((short)dcCallShort(cvm, affix->entry_point));
#else
        container = newSViv((char)dcCallChar(cvm, affix->entry_point));
#endif
        packlist(RETVAL, pat, pat + 1, &container, &container + 1);
        sv_2mortal(container);
    } break;
    case SHORT_FLAG: {
        PING;
        RETVAL = newSViv((short)dcCallShort(cvm, affix->entry_point));
    } break;
    case USHORT_FLAG: {
        PING;
        RETVAL = (newSVuv((unsigned short)dcCallShort(cvm, affix->entry_point)));
    } break;
    case INT_FLAG: {
        PING;
        RETVAL = (newSViv((int)dcCallInt(cvm, affix->entry_point)));
    } break;
    case UINT_FLAG: {
        PING;
        RETVAL = (newSVuv((unsigned int)dcCallInt(cvm, affix->entry_point)));
    } break;
    case LONG_FLAG: {
        PING;
        RETVAL = (newSViv((long)dcCallLong(cvm, affix->entry_point)));
    } break;
    case ULONG_FLAG: {
        PING;
        RETVAL = (newSVuv((unsigned long)dcCallLong(cvm, affix->entry_point)));
    } break;
    case LONGLONG_FLAG: {
        PING;
        RETVAL = (newSViv((long long)dcCallLongLong(cvm, affix->entry_point)));
    } break;
    case ULONGLONG_FLAG: {
        PING;
        RETVAL = (newSVuv((unsigned long long)dcCallLongLong(cvm, affix->entry_point)));
    } break;
    case FLOAT_FLAG: {
        PING;
        RETVAL = (newSVnv(dcCallFloat(cvm, affix->entry_point)));
    } break;
    case DOUBLE_FLAG: {
        PING;
        RETVAL = (newSVnv(dcCallDouble(cvm, affix->entry_point)));
    } break;
    case WSTRING_FLAG: {
        PING;
        wchar_t *str = (wchar_t *)dcCallPointer(cvm, affix->entry_point);
        RETVAL = (wchar2utf(aTHX_ str, wcslen(str)));
    } break;
    case STDSTRING_FLAG: {
        PING;
        std::string *str = static_cast<std::string *>(dcCallPointer(cvm, affix->entry_point));
        RETVAL = (newSVpv((char *)str->c_str(), str->length()));
        delete str;
    } break;
    case STRUCT_FLAG:
    case CPPSTRUCT_FLAG:
    case UNION_FLAG: {
        PING;
        if (affix->ret_ptr == NULL) affix->ret_ptr = safemalloc(AXT_SIZEOF(affix->ret_info));
        dcCallAggr(cvm, affix->entry_point, affix->ret_aggregate, affix->ret_ptr);
        PING;
        RETVAL = sv_2mortal(ptr2sv(aTHX_ affix->ret_info, affix->ret_ptr));
        PING;
    } break;
    case CODEREF_FLAG: {
        PING;
        warn("Returning a code ref is on the TODO list");
    } break;
    case POINTER_FLAG: {
        PING;
        PING;
        SV *subtype = AXT_SUBTYPE(affix->ret_info);
        DCpointer ptr = dcCallPointer(cvm, affix->entry_point);
        RETVAL = NULL;
        PING;

        if (sv_derived_from(subtype, "Affix::Type::Char")) {
            RETVAL = ptr2sv(aTHX_ affix->ret_info, ptr);
        }
        else {
            RETVAL = newSV(1);
            SV **package = AXT_TYPEDEF(affix->ret_info);
            if (package != NULL) { sv_setref_pv(RETVAL, SvPV_nolen(*package), ptr); }
            else { sv_setref_pv(RETVAL, "Affix::Pointer::Unmanaged", ptr); }
        }
    } break;
    default:
        croak("Unhandled return type %s at %s line %d", AXT_STRINGIFY(affix->ret_info), __FILE__,
              __LINE__);
    }
    PING;
    if (affix->temp_ptrs != NULL) {
        PING;
        for (st_pos = 0, arg_pos = 0; st_pos < num_args; ++st_pos, ++arg_pos) {
            PING;

            //~ sv_dump(ST(st_pos));
            if (affix->temp_ptrs[st_pos] != NULL && !SvREADONLY(ST(st_pos))) {
                PING;
#if DEBUG
                DumpHex(affix->temp_ptrs[st_pos], AXT_SIZEOF(MUTABLE_SV(affix->arg_info[st_pos])));
#endif
                //~ warn("st_pos: %d", st_pos);

                sv_setsv_mg(ST(st_pos), ptr2sv(aTHX_ MUTABLE_SV(affix->arg_info[st_pos]),
                                               affix->temp_ptrs[st_pos]));
                SvSETMAGIC(ST(st_pos));
                //~ DD(ST(st_pos));
            }
        }
    }
    PING;
    if (UNLIKELY(reset_mode)) dcMode(cvm, DC_CALL_C_DEFAULT);
    PING;
    //
    if (UNLIKELY(affix->ret_type == VOID_FLAG)) XSRETURN_EMPTY;
    PING;
    RETVAL = sv_2mortal(RETVAL);
    PING;
    ST(0) = RETVAL;
    PL_stack_sp = PL_stack_base + ax;
    return;
}
#if 0
extern "C" void Affix_trigger2(pTHX_ CV *cv) {
	dXSARGS;
	dMY_CXT;
	PING;

	Affix *affix = (Affix *)XSANY.any_ptr;
	char **free_strs = NULL;
	void **free_ptrs = NULL;
	PING;

	int num_args = affix->num_args;
	int num_strs = 0, num_ptrs = 0;
	int16_t *arg_types = affix->arg_types;
	bool void_ret = false;
	DCaggr *agg_ = NULL;
	char *package = NULL;
	PING;

	// dcMode(MY_CXT.cvm, affix->call_conv);
	dcReset(MY_CXT.cvm);
	PING;

	switch (affix->ret_type) {
	case AFFIX_TYPE_CUNION:
	case AFFIX_TYPE_CSTRUCT:
	case AFFIX_TYPE_CPPSTRUCT: {
			agg_ = _aggregate(aTHX_ affix->ret_info);
#if DEBUG > 1
			warn("  dcBeginCallAggr(%p, %p);", (void *)MY_CXT.cvm, (void *)agg_);
#endif
			dcBeginCallAggr(MY_CXT.cvm, agg_);
		}
		break;
	}
#if DEBUG > 1
	warn("args: ");
	DD(MUTABLE_SV(affix->arg_info));
#endif
	{
		// This is dumb
		int __num_args = num_args;
		if (affix->_cpp_struct && !affix->_cpp_constructor) ++__num_args;
		if (UNLIKELY(items != __num_args)) {
			if (UNLIKELY(items > __num_args))
				croak("Too many arguments; wanted %d, found %d", __num_args, items);
			croak("Not enough arguments; wanted %d, found %d", __num_args, items);
		}
	}

#if DEBUG > 1
	warn("Expecting %d arguments...", num_args);
#endif
	DCpointer this_ptr = NULL;

	for (int arg_pos = affix->_cpp_constructor ? 1 : 0, info_pos = 0; LIKELY(arg_pos < num_args);
			++arg_pos, ++info_pos) {
#if DEBUG
		warn("arg_pos: %d, num_args: %d, info_pos: %d", arg_pos, num_args, info_pos);
		warn("   type: %d, as_str: %s", arg_types[info_pos], AXT_STRINGIFY(arg_types[info_pos]));
#if DEBUG > 1
		DD(ST(arg_pos));
#endif
#endif
		switch (arg_types[info_pos]) {

		case DC_SIGCHAR_CC_PREFIX: {
				// TODO: Not a fan of this entire section
				// I could/should make CC_* scalarize to ints, and in Affix_affix put _PREFIX in
				// arg_types and the actuall CC object in arg_info
				SV *cc = *av_fetch(affix->arg_info, info_pos, 0);
				char mode = DC_SIGCHAR_CC_DEFAULT;
				if (sv_derived_from(cc, "Affix::Type::CC::DEFALT")) { mode = DC_SIGCHAR_CC_DEFAULT; }
				else if (UNLIKELY(sv_derived_from(cc, "Affix::Type::CC::THISCALL"))) {
					mode = DC_SIGCHAR_CC_THISCALL;
				} else if (UNLIKELY(sv_derived_from(cc, "Affix::Type::CC::ELLIPSIS"))) {
					mode = DC_SIGCHAR_CC_ELLIPSIS;
				} else if (UNLIKELY(sv_derived_from(cc, "Affix::Type::CC::ELLIPSIS_VARARGS"))) {
					mode = DC_SIGCHAR_CC_ELLIPSIS_VARARGS;
				} else if (UNLIKELY(sv_derived_from(cc, "Affix::Type::CC::CDECL"))) {
					mode = DC_SIGCHAR_CC_CDECL;
				} else if (UNLIKELY(sv_derived_from(cc, "Affix::Type::CC::STDCALL"))) {
					mode = DC_SIGCHAR_CC_STDCALL;
				} else if (UNLIKELY(sv_derived_from(cc, "Affix::Type::CC::FASTCALL_MS"))) {
					mode = DC_SIGCHAR_CC_FASTCALL_MS;
				} else if (UNLIKELY(sv_derived_from(cc, "Affix::Type::CC::FASTCALL_GNU"))) {
					mode = DC_SIGCHAR_CC_FASTCALL_GNU;
				} else if (UNLIKELY(sv_derived_from(cc, "Affix::Type::CC::THISCALL_MS"))) {
					mode = DC_SIGCHAR_CC_THISCALL_MS;
				} else if (UNLIKELY(sv_derived_from(cc, "Affix::Type::CC::THISCALL_GNU"))) {
					mode = DC_SIGCHAR_CC_THISCALL_GNU;
				} else if (UNLIKELY(sv_derived_from(cc, "Affix::Type::CC::ARM_ARM "))) {
					mode = DC_SIGCHAR_CC_ARM_ARM;
				} else if (UNLIKELY(sv_derived_from(cc, "Affix::Type::CC::ARM_THUMB"))) {
					mode = DC_SIGCHAR_CC_ARM_THUMB;
				} else if (UNLIKELY(sv_derived_from(cc, "Affix::Type::CC::SYSCALL"))) {
					mode = DC_SIGCHAR_CC_SYSCALL;
				} else { croak("Unknown calling convention"); }
				dcMode(MY_CXT.cvm, dcGetModeFromCCSigChar(mode));
				if (mode != DC_SIGCHAR_CC_ELLIPSIS && mode != DC_SIGCHAR_CC_ELLIPSIS_VARARGS) {
					dcReset(MY_CXT.cvm);
				}
				arg_pos--;
				if (affix->_cpp_constructor) {
					Newxz(this_ptr, 1, intptr_t);
					dcArgPointer(MY_CXT.cvm, this_ptr);
					package = SvPV_nolen(ST(0));
				}
			}
			break;
		case AFFIX_TYPE_VOID: {
#if DEBUG > 1
				warn("Skipping void parameter");
#endif
				// skip
			}
			break;
		case AFFIX_TYPE_BOOL: {
				dcArgBool(MY_CXT.cvm, SvTRUE(ST(arg_pos))); // Anything can be a bool
			}
			break;
		case AFFIX_TYPE_CHAR: {
				if (SvIOK(ST(arg_pos))) { dcArgChar(MY_CXT.cvm, (I8)SvIV(ST(arg_pos))); }
				else {
					STRLEN len;
					char *value = SvPVbyte(ST(arg_pos), len);
					if (len > 1) { warn("Expected a single character; found %ld", len); }
					dcArgChar(MY_CXT.cvm, (I8)value[0]);
				}
			}
			break;
		case AFFIX_TYPE_UCHAR: {
				if (SvIOK(ST(arg_pos))) { dcArgChar(MY_CXT.cvm, (U8)SvUV(ST(arg_pos))); }
				else {
					STRLEN len;
					char *value = SvPVbyte(ST(arg_pos), len);
					if (len > 1) { warn("Expected a single character; found %ld", len); }
					dcArgChar(MY_CXT.cvm, (U8)value[0]);
				}
			}
			break;
		case AFFIX_TYPE_WCHAR: {
				if (SvOK(ST(arg_pos))) {
					char *eh = SvPV_nolen(ST(arg_pos));
					PUTBACK;
					const char *pat = "W";
					SSize_t s = unpackstring(pat, pat + 1, eh, eh + SIZEOF_WCHAR + 1, SVt_PVAV);
					SPAGAIN;
					if (UNLIKELY(s != 1)) croak("Failed to unpack wchar_t");
					switch (SIZEOF_WCHAR) {
					case I8SIZE:
						dcArgChar(MY_CXT.cvm, (char)POPi);
						break;
					case SHORTSIZE:
						dcArgShort(MY_CXT.cvm, (short)POPi);
						break;
					case INTSIZE:
						dcArgInt(MY_CXT.cvm, (int)POPi);
						break;
					default:
						croak("Invalid wchar_t size for argument!");
					}
				} else
					dcArgInt(MY_CXT.cvm, 0);
			}
			break;
		case AFFIX_TYPE_SHORT: {
				dcArgShort(MY_CXT.cvm, (short)(SvIV(ST(arg_pos))));
			}
			break;
		case AFFIX_TYPE_USHORT: {
				dcArgShort(MY_CXT.cvm, (unsigned short)(SvUV(ST(arg_pos))));
			}
			break;
		case AFFIX_TYPE_INT: {
				dcArgInt(MY_CXT.cvm, (int)(SvIV(ST(arg_pos))));
			}
			break;
		case AFFIX_TYPE_UINT: {
				dcArgInt(MY_CXT.cvm, (unsigned int)(SvUV(ST(arg_pos))));
			}
			break;
		case AFFIX_TYPE_LONG:
			dcArgLong(MY_CXT.cvm, (unsigned long)(SvUV(ST(arg_pos))));
			break;
		case AFFIX_TYPE_ULONG: {
				dcArgLong(MY_CXT.cvm, (unsigned long)(SvUV(ST(arg_pos))));
			}
			break;
		case AFFIX_TYPE_LONGLONG: {
				dcArgLongLong(MY_CXT.cvm, (I64)(SvIV(ST(arg_pos))));
			}
			break;
		case AFFIX_TYPE_ULONGLONG:
			dcArgLongLong(MY_CXT.cvm, (U64)(SvUV(ST(arg_pos))));
			break;
		case AFFIX_TYPE_FLOAT: {
				dcArgFloat(MY_CXT.cvm, (float)SvNV(ST(arg_pos)));
			}
			break;
		case AFFIX_TYPE_DOUBLE: {
				dcArgDouble(MY_CXT.cvm, (double)SvNV(ST(arg_pos)));
			}
			break;
		case AFFIX_TYPE_ASCIISTR: {
				dcArgPointer(MY_CXT.cvm, SvOK(ST(arg_pos)) ? SvPV_nolen(ST(arg_pos)) : NULL);
			}
			break;
		case AFFIX_TYPE_STD_STRING: {
				std::string tmp = SvOK(ST(arg_pos)) ? SvPV_nolen(ST(arg_pos)) : NULL;
				dcArgPointer(MY_CXT.cvm, static_cast<void *>(&tmp));
			}
			break;
		case AFFIX_TYPE_UTF8STR:
		case AFFIX_TYPE_UTF16STR: {
				if (SvOK(ST(arg_pos))) {
					if (!free_ptrs) Newxz(free_ptrs, num_args, DCpointer);
					// Newxz(free_ptrs[num_ptrs], _sizeof(aTHX_ newSViv(AFFIX_TYPE_UTF16STR)), char);
					free_ptrs[num_ptrs] =
						sv2ptr(aTHX_ newSViv(AFFIX_TYPE_UTF16STR), ST(arg_pos));
					dcArgPointer(MY_CXT.cvm, *(DCpointer *)(free_ptrs[num_ptrs++]));
				} else { dcArgPointer(MY_CXT.cvm, NULL); }
			}
			break;
		case AFFIX_TYPE_CUNION:
		case AFFIX_TYPE_CSTRUCT:
		case AFFIX_TYPE_CPPSTRUCT: {
				if (!SvOK(ST(arg_pos)) && SvREADONLY(ST(arg_pos)) // explicit undef
				   ) {
					dcArgPointer(MY_CXT.cvm, NULL);
				} else if (SvOK(ST(arg_pos)) && sv_derived_from(ST(arg_pos), "Affix::Pointer")) {
					IV tmp = SvIV(SvRV(ST(arg_pos)));
					dcArgPointer(MY_CXT.cvm, INT2PTR(DCpointer, tmp));
				} else {
					if (!free_ptrs) Newxz(free_ptrs, num_args, DCpointer);
					if (!SvROK(ST(arg_pos)) || SvTYPE(SvRV(ST(arg_pos))) != SVt_PVHV)
						croak("Type of arg %d must be an hash ref", arg_pos + 1);
					//~ AV *elements = MUTABLE_AV(SvRV(ST(i)));
					SV **type = av_fetch(affix->arg_info, info_pos, 0);
					DCaggr *agg = _aggregate(aTHX_ * type);
					free_ptrs[num_ptrs] = sv2ptr(aTHX_ * type, ST(arg_pos));
					dcArgAggr(MY_CXT.cvm, agg, free_ptrs[num_ptrs++]);
				}
			}
			//~ croak("Unhandled arg type at %s line %d", __FILE__, __LINE__);
			break;
		case AFFIX_TYPE_CARRAY: {
				if (!SvOK(ST(arg_pos)) && SvREADONLY(ST(arg_pos)) // explicit undef
				   ) {
					dcArgPointer(MY_CXT.cvm, NULL);
				} else if (SvOK(ST(arg_pos)) && sv_derived_from(ST(arg_pos), "Affix::Pointer")) {
					IV tmp = SvIV(SvRV(ST(arg_pos)));
					dcArgPointer(MY_CXT.cvm, INT2PTR(DCpointer, tmp));
				} else {
					if (!free_ptrs) Newxz(free_ptrs, num_args, DCpointer);
					SV *type = *av_fetch(affix->arg_info, info_pos, 0);
					AV *av_ptr = MUTABLE_AV(SvRV(type));
					SV *subtype = *av_fetch(av_ptr, 5, 0);
					DD(subtype);
					HV *hv_ptr;
					croak("fdsafdsa");
					// free_ptrs = (void **)safemalloc(num_args * sizeof(DCpointer));
					if ((SvROK(ST(arg_pos)) && SvTYPE(SvRV(ST(arg_pos))) == SVt_PVAV) ||
							((sv_derived_from(subtype, "Affix::Type::Char") ||
							  sv_derived_from(subtype, "Affix::Type::UChar") ||
							  sv_derived_from(subtype, "Affix::Type::WChar")) &&
							 SvPOK(ST(arg_pos)))) {
						AV *elements = MUTABLE_AV(SvRV(ST(arg_pos)));
						size_t av_len;
						if (hv_exists(hv_ptr, "size", 4)) {
							av_len = SvIV(*hv_fetchs(hv_ptr, "size", 0));
							if (av_count(elements) != av_len)
								croak("Expected an array of %lu elements; found %ld", av_len,
								      av_count(elements));
						} else if (SvPOK(ST(arg_pos))) {
							(void)SvPV(ST(arg_pos), av_len);
							hv_stores(hv_ptr, "dyn_size", newSVuv(av_len));
						} else {
							PING;
							av_len = av_count(elements);
							hv_stores(hv_ptr, "dyn_size", newSVuv(av_len));
						}
						PING;
						//~ hv_stores(hv_ptr, "sizeof", newSViv(av_len));
						PING;
						free_ptrs[num_ptrs] = sv2ptr(aTHX_ type, ST(arg_pos));
						PING;
						dcArgPointer(MY_CXT.cvm, free_ptrs[num_ptrs++]);
						PING;
					} else
						croak("Arg %d must be an array reference", arg_pos + 1);
				}
			}
			break;
		case AFFIX_TYPE_CALLBACK: {
				if (SvOK(ST(arg_pos))) {
					//~ DCCallback *hold;
					//~ //Newxz(hold, 1, DCCallback);
					//~ sv2ptr(aTHX_ SvRV(*av_fetch(affix->arg_info, info_pos, 0)), ST(arg_pos), hold,
					// struct_packed::off); ~ dcArgPointer(MY_CXT.cvm, hold);
					CallbackWrapper *hold = (CallbackWrapper *)sv2ptr(
									aTHX_ * av_fetch(affix->arg_info, info_pos, 0), ST(arg_pos));
					dcArgPointer(MY_CXT.cvm, hold->cb);
				} else
					dcArgPointer(MY_CXT.cvm, NULL);
			}
			break;
		case AFFIX_TYPE_SV: {
				SV *type = *av_fetch(affix->arg_info, info_pos, 0);
				DCpointer blah = sv2ptr(aTHX_ type, ST(arg_pos));
				dcArgPointer(MY_CXT.cvm, blah);
			}
			break;
		case AFFIX_TYPE_CPOINTER:
		case AFFIX_TYPE_REF: {
#if DEBUG
				warn("AFFIX_TYPE_CPOINTER [%d, %ld/%s]", arg_pos,
				     SvIV(*av_fetch(affix->arg_info, info_pos, 0)),
				     AXT_STRINGIFY(affix->arg_info));
#if DEBUG > 1
				DD(MUTABLE_SV(affix->arg_info));
				DD(*av_fetch(affix->arg_info, info_pos, 0));
#endif
#endif

				if (UNLIKELY(!SvOK(ST(arg_pos)) && SvREADONLY(ST(arg_pos)))) { // explicit undef
					dcArgPointer(MY_CXT.cvm, NULL);
				} else if (SvOK(ST(arg_pos)) &&
						sv_derived_from(ST(arg_pos),
								"Affix::Pointer")) { // pass pointers directly through
					IV tmp = SvIV(SvRV(ST(arg_pos)));
					dcArgPointer(MY_CXT.cvm, INT2PTR(DCpointer, tmp));
				} else {
					PING;
					if (!free_ptrs) Newxz(free_ptrs, num_args, DCpointer);
					SV *type = *av_fetch(affix->arg_info, info_pos, 0);
					if (UNLIKELY(SvOK(ST(arg_pos)) && sv_isobject(ST(arg_pos)) &&
							sv_derived_from(type, "Affix::Type::InstanceOf"))) {
						SV *cls = *hv_fetch(MUTABLE_HV(SvRV(type)), "class", 5, 0);
						if (!sv_derived_from_sv(ST(arg_pos), cls, 0)) {
							croak("Expected a subclass of %s in argument %d", SvPV_nolen(cls),
							      arg_pos + 1);
						}
					}
					PING;
					free_ptrs[num_ptrs] = sv2ptr(aTHX_ type, ST(arg_pos));
					// DumpHex(free_ptrs[num_ptrs], size);
					dcArgPointer(MY_CXT.cvm, free_ptrs[num_ptrs]);
					num_ptrs++;
				}
			}
			break;
		default:
			croak("Unhandled arg type %s at %s line %d", AXT_STRINGIFY(arg_types[info_pos]),			      __FILE__, __LINE__);
			break;
		}
	}

	SV *RETVAL;

	if (UNLIKELY(UNLIKELY(affix->_cpp_constructor) &&
			LIKELY(this_ptr != NULL && package != NULL))) {
#if DEBUG
		warn("Return type %s from C++ constructor / %p at %s line %d", package, affix->entry_point,
		     __FILE__, __LINE__);
#endif
		//~ TODO: Make package inherit from Affix::Pointer::Unmanaged
		dcCallVoid(MY_CXT.cvm, affix->entry_point);
		RETVAL = newSV(1);
		sv_setref_pv(RETVAL, package, this_ptr);
	} else {
#if DEBUG
		warn("Return type %d (%s) / %p at %s line %d", affix->ret_type,
		     AXT_STRINGIFY(affix->ret_type), affix->entry_point, __FILE__, __LINE__);
#endif
		switch (affix->ret_type) {
		case AFFIX_TYPE_VOID:
			void_ret = true;
			dcCallVoid(MY_CXT.cvm, affix->entry_point);
			break;
		case AFFIX_TYPE_BOOL: // DCbool is an int!
			RETVAL = boolSV((bool)dcCallBool(MY_CXT.cvm, affix->entry_point));
			break;
		case AFFIX_TYPE_CHAR: {
				char value[1];
				value[0] = dcCallChar(MY_CXT.cvm, affix->entry_point);
				RETVAL = newSV(0);
				sv_setsv(RETVAL, newSVpv(value, 1));
				(void)SvUPGRADE(RETVAL, SVt_PVIV);
				SvIV_set(RETVAL, ((IV)value[0]));
				SvIOK_on(RETVAL);
			}
			break;
		case AFFIX_TYPE_UCHAR: {
				unsigned char value[1];
				value[0] = dcCallChar(MY_CXT.cvm, affix->entry_point);
				RETVAL = newSV(0);
				sv_setsv(RETVAL, newSVpv((char *)value, 1));
				(void)SvUPGRADE(RETVAL, SVt_PVIV);
				SvIV_set(RETVAL, ((UV)value[0]));
				SvIOK_on(RETVAL);
			}
			break;
		case AFFIX_TYPE_WCHAR: {
				SV *container;
				RETVAL = newSVpvs("");
				const char *pat = "W";
				switch (SIZEOF_WCHAR) {
				case I8SIZE:
					container = newSViv((char)dcCallChar(MY_CXT.cvm, affix->entry_point));
					break;
				case SHORTSIZE:
					container = newSViv((short)dcCallShort(MY_CXT.cvm, affix->entry_point));
					break;
				case INTSIZE:
					container = newSViv((int)dcCallInt(MY_CXT.cvm, affix->entry_point));
					break;
				default:
					croak("Invalid wchar_t size for argument!");
				}
				sv_2mortal(container);
				packlist(RETVAL, pat, pat + 1, &container, &container + 1);
			}
			break;
		case AFFIX_TYPE_SHORT:
			RETVAL = newSViv((short)dcCallShort(MY_CXT.cvm, affix->entry_point));
			break;
		case AFFIX_TYPE_USHORT:
			RETVAL = newSVuv((unsigned short)dcCallShort(MY_CXT.cvm, affix->entry_point));
			break;
		case AFFIX_TYPE_INT:
			RETVAL = newSViv((signed int)dcCallInt(MY_CXT.cvm, affix->entry_point));
			break;
		case AFFIX_TYPE_UINT:
			RETVAL = newSVuv((unsigned int)dcCallInt(MY_CXT.cvm, affix->entry_point));
			break;
		case AFFIX_TYPE_LONG:
			RETVAL = newSViv((long)dcCallLong(MY_CXT.cvm, affix->entry_point));
			break;
		case AFFIX_TYPE_ULONG:
			RETVAL = newSVuv((unsigned long)dcCallLong(MY_CXT.cvm, affix->entry_point));
			break;
		case AFFIX_TYPE_LONGLONG:
			RETVAL = newSViv((I64)dcCallLongLong(MY_CXT.cvm, affix->entry_point));
			break;
		case AFFIX_TYPE_ULONGLONG:
			RETVAL = newSVuv((U64)dcCallLongLong(MY_CXT.cvm, affix->entry_point));
			break;
		case AFFIX_TYPE_FLOAT:
			RETVAL = newSVnv(dcCallFloat(MY_CXT.cvm, affix->entry_point));
			break;
		case AFFIX_TYPE_DOUBLE:
			RETVAL = newSVnv(dcCallDouble(MY_CXT.cvm, affix->entry_point));
			break;
		case AFFIX_TYPE_ASCIISTR:
			RETVAL = newSVpv((char *)dcCallPointer(MY_CXT.cvm, affix->entry_point), 0);
			break;
		case AFFIX_TYPE_UTF16STR: {
				wchar_t *str = (wchar_t *)dcCallPointer(MY_CXT.cvm, affix->entry_point);
				RETVAL = wchar2utf(aTHX_ str, wcslen(str));
			}
			break;
		case AFFIX_TYPE_CPOINTER:
		case AFFIX_TYPE_REF: {
				PING;
				SV *subtype = *hv_fetchs(MUTABLE_HV(SvRV(affix->ret_info)), "type", 0);
				PING;

				DCpointer p = dcCallPointer(MY_CXT.cvm, affix->entry_point);
				PING;
				if (sv_derived_from(subtype, "Affix::Type::Char")) {
					PING;
					RETVAL = ptr2sv(aTHX_ p, affix->ret_info);
				}
				//~
				//~ DCpointer p = dcCallPointer(MY_CXT.cvm, affix->entry_point);
				//~ if(UNLIKELY(sv_derived_from(affix->ret_info, "Affix::Type::InstanceOf"))){
				//~ SV *cls = *hv_fetchs(MUTABLE_HV(SvRV(affix->ret_info)), "class", 0);
				//~ sv_setref_pv(RETVAL, SvPV_nolen(cls), p);
				//~ }

				else {
					RETVAL = newSV(1);
					HV *_type = MUTABLE_HV(SvRV(affix->ret_info));
					SV **typedef_ptr = hv_fetch(_type, "class", 5, 0);

					if (typedef_ptr != NULL) { sv_setref_pv(RETVAL, SvPV_nolen(*typedef_ptr), p); }
					else {

						PING;
						PING;
						sv_dump(affix->ret_info);
						sv_setref_pv(RETVAL, "Affix::Pointer::Unmanaged::505", p);
					}
					// sv_dump(affix->ret_info);
				}
				//~ }
				//~ else {

				//~ }
				PING;

			}
			break;
		case AFFIX_TYPE_CUNION:
		case AFFIX_TYPE_CSTRUCT:
		case AFFIX_TYPE_CPPSTRUCT: {
				DCpointer p = safemalloc(_sizeof(aTHX_ affix->ret_info));
#if DEBUG
				warn("  DCpointer p [%p] = safemalloc(%ld);", p, _sizeof(aTHX_ affix->ret_info));
				warn("  dcCallAggr(%p, %p, %p, %p);", (void *)MY_CXT.cvm, (void *)affix->entry_point,
				     (void *)agg_, p);
#endif
				dcCallAggr(MY_CXT.cvm, affix->entry_point, agg_, p);
				PING;
				RETVAL = ptr2sv(aTHX_ p, affix->ret_info);
				PING;
			}
			break;
		case AFFIX_TYPE_CARRAY: {
				//~ warn ("        _sizeof(aTHX_ affix->ret_info): %d",_sizeof(aTHX_ affix->ret_info));
				// DCpointer p = safemalloc(_sizeof(aTHX_ affix->ret_info));
				// dcCallAggr(MY_CXT.cvm, affix->entry_point, agg_, p);
				DCpointer p = dcCallPointer(MY_CXT.cvm, affix->entry_point);
				RETVAL = ptr2sv(aTHX_ p, affix->ret_info);
			}
			break;
		case AFFIX_TYPE_STD_STRING:
		default:
			//~ sv_dump(affix->ret_info);
			DD(affix->ret_info);
			PING;
			croak("Unknown return type: %s (%d)", AXT_STRINGIFY(affix->ret_type), affix->ret_type);
			break;
		}
	}
	/*
	#define AFFIX_TYPE_UTF8STR 18
	#define AFFIX_TYPE_CALLBACK 26
	#define AFFIX_TYPE_CPOINTER 28
	#define AFFIX_TYPE_VMARRAY 30
	#define AFFIX_TYPE_CUNION 42
	#define AFFIX_TYPE_CPPSTRUCT 36
	#define AFFIX_TYPE_WCHAR 46
	*/
	//
	PING;
	//
	/* Free any memory that we need to. */
	if (free_strs != NULL) {
		for (int i = 0; UNLIKELY(i < num_strs); ++i)
			safefree(free_strs[i]);
		safefree(free_strs);
	}

	// TODO: This would be faster if I had a way to mark lvalues
	if (free_ptrs != NULL) {
		for (int i = 0, p = 0; LIKELY(i < items); ++i) {
			PING;
			if (SvREADONLY(ST(i)) // explicit undef
					|| (SvOK(ST(i)) && sv_derived_from(ST(i), "Affix::Pointer"))) {
				PING;
				continue; // No need to try and update a pointer
			}
			PING;
			switch (arg_types[i]) {
			case AFFIX_TYPE_CARRAY: {
					SV *sv = ptr2sv(aTHX_ free_ptrs[p++], *av_fetch(affix->arg_info, i, 0));
					if (SvFLAGS(ST(i)) & SVs_TEMP) { // likely a temp ref
						AV *av = MUTABLE_AV(SvRV(sv));
						av_clear(MUTABLE_AV(SvRV(ST(i))));
						size_t av_len = av_count(av);
						for (size_t q = 0; q < av_len; ++q) {
							sv_setsv(*av_fetch(MUTABLE_AV(SvRV(ST(i))), q, 1), *av_fetch(av, q, 0));
						}
						SvSETMAGIC(SvRV(ST(i)));
					} else { // scalar ref is faster :D
						SvSetMagicSV(ST(i), sv);
					}

				}
				break;
			case AFFIX_TYPE_CPOINTER:
			case AFFIX_TYPE_REF: {
					PING;
					if (SvOK(ST(i)) && sv_derived_from((ST(i)), "Affix::Pointer")) {
						;
						//~ warn("raw pointer");
					} else if (!SvREADONLY(ST(i))) {
#if TIE_MAGIC
						if (SvOK(ST(i))) {
							const MAGIC *mg = SvTIED_mg((SV *)SvRV(ST(i)), PERL_MAGIC_tied);
							if (LIKELY(SvOK(ST(i)) && SvTYPE(SvRV(ST(i))) == SVt_PVHV && mg
									//~ &&  sv_derived_from(SvRV(ST(i)), "Affix::Union")
								  )) { // Already a known union pointer
							} else {
								sv_setsv_mg(ST(i), ptr2sv(aTHX_ free_ptrs[p++],
											  *av_fetch(affix->arg_info, i, 0)));
							}
						} else {
							sv_setsv_mg(ST(i),
								    ptr2sv(aTHX_ free_ptrs[p++], *av_fetch(affix->arg_info, i, 0)));
						}
#else
						sv_setsv_mg(ST(i),
							    ptr2sv(aTHX_ free_ptrs[p++], *av_fetch(affix->arg_info, i, 0)));
#endif
					}
				}
				break;
			}
		}
	}
	PING;

	//~ if (UNLIKELY(free_ptrs != NULL)) {
	//~ for (int i = 0; LIKELY(i < num_ptrs); ++i) {
	//~ safefree(free_ptrs[i]);
	//~ }
	//~ safefree(free_ptrs);
	//~ }

	//~ if (agg_ != NULL) {
	//~ dcFreeAggr(agg_);
	//~ agg_ = NULL;
	//~ }
	PING;

	if (UNLIKELY(void_ret)) XSRETURN_EMPTY;
	PING;
	ST(0) = sv_2mortal(RETVAL);
	PING;

	XSRETURN(1);
}

#endif

XS_INTERNAL(Affix_affix) {
    dXSARGS;
    dXSI32;
    PING;
    if (items != 4) croak_xs_usage(cv, "$lib, $symbol, @arg_types, $ret_type");
    SV *RETVAL;
    Affix *affix;
    Newx(affix, 1, Affix);

    // Dumb defaults
    affix->num_args = 0;
    affix->entry_point = NULL;
    affix->lib_name = NULL;
    affix->lib_handle = NULL;
    affix->arg_info = NULL;
    affix->aggregates = NULL;
    affix->ret_info = NULL;
    affix->ret_aggregate = NULL;
    affix->call_conv = DC_SIGCHAR_CC_DEFAULT;
    affix->ellipsis = false;
    affix->_cpp_struct = false;
    affix->_cpp_constructor = false;
    affix->_cpp_this_info = NULL;
    affix->temp_ptrs = NULL;
    affix->ret_ptr = NULL;

    char *prototype = NULL;
    char *perl_name = NULL;
    SV *symbol;

    {
        if (UNLIKELY(SvROK(ST(1)) && SvTYPE(SvRV(ST(1))) == SVt_PVAV)) {
            AV *tmp = MUTABLE_AV(SvRV(ST(1)));
            size_t tmp_len = av_count(tmp);
            if (tmp_len != 2) { croak("Expected a symbol and name"); }
            if (ix == 1 && tmp_len > 1) {
                croak("wrap( ... ) isn't expecting a name and has ignored it");
            }
            symbol = *av_fetch(tmp, 0, false);
            if (!SvPOK(symbol)) { croak("Undefined symbol name"); }
            perl_name = SvPV_nolen(*av_fetch(tmp, 1, false));
        }
        else if (UNLIKELY(!SvPOK(ST(1)))) { croak("Undefined symbol name"); }
        else {
            symbol = ST(1);
            perl_name = SvPV_nolen(symbol);
        }
    }
    char *sym_name = SvPV_nolen(symbol);
    PING;
    // Support for Some::Some(), etc.
    if (instr(sym_name, "::") != NULL) { affix->_cpp_struct = true; }

    // TODO: Support C++ const member functions
    affix->_cpp_const = false;
    PING;

    {
        SV *lib, *ver;
        // affix($lib, ..., ..., ...)
        // affix([$lib, 1.2.0], ..., ..., ...)
        // wrap($lib, ..., ...., ...
        // wrap([$lib, 'v3'], ..., ...., ...
        {
            if (UNLIKELY(SvROK(ST(0)) && SvTYPE(SvRV(ST(0))) == SVt_PVAV)) {
                PING;

                AV *tmp = MUTABLE_AV(SvRV(ST(0)));
                size_t tmp_len = av_count(tmp);
                // Non-fatal
                if (UNLIKELY(!(tmp_len == 1 || tmp_len == 2))) {
                    PING;

                    warn("Expected a lib and version");
                }
                lib = *av_fetch(tmp, 0, false);
                ver = *av_fetch(tmp, 1, false);
            }
            else {
                PING;

                lib = newSVsv(ST(0));
                ver = newSV(0);
            }
            if (sv_isobject(lib) && sv_derived_from(lib, "Affix::Lib")) {

                IV tmp = SvIV(SvRV(lib));
                affix->lib_handle = INT2PTR(DLLib *, tmp);
                char *name;
                Newxz(name, 1024, char);
                int len = dlGetLibraryPath(affix->lib_handle, name, 1024);
                Newxz(affix->lib_name, len + 1, char);
                Copy(name, affix->lib_name, len, char);
            }
            else {
                affix->lib_name = locate_lib(aTHX_ lib, ver);
                affix->lib_handle =
#if defined(DC__OS_Win64) || defined(DC__OS_MacOSX)
                    dlLoadLibrary(affix->lib_name);
#else
                    (DLLib *)dlopen(affix->lib_name, RTLD_LAZY /* RTLD_NOW|RTLD_GLOBAL */);
#endif
                if (!affix->lib_handle) {
                    croak("Failed to load lib %s", dlerror());
                }
            }
        }

        // affix(..., ..., [Int], ...)
        // wrap(..., ..., [], ...)
        {
            STMT_START {
                SV *const xsub_tmp_sv = ST(2);
                SvGETMAGIC(xsub_tmp_sv);
                if (SvROK(xsub_tmp_sv) && SvTYPE(SvRV(xsub_tmp_sv)) == SVt_PVAV) {
                    AV *tmp_args = (AV *)SvRV(xsub_tmp_sv);
                    size_t num_args = av_count(tmp_args);
                    Newxz(affix->arg_types, num_args + 1, int16_t);
                    Newxz(prototype, num_args + 1, char);
                    SV *type;
                    Newxz(affix->arg_info, num_args, DCpointer);

                    for (size_t arg_pos = 0, prototype_pos = 0; arg_pos < num_args; ++arg_pos) {
                        //~ warn("arg_pos: %d, prototype_pos: %d", arg_pos, prototype_pos);
                        type = *av_fetch(tmp_args, arg_pos, false);
                        if (LIKELY(SvROK(type) && sv_derived_from(type, "Affix::Type"))) {
                            affix->arg_types[arg_pos] = AXT_NUMERIC(type);
                            //~ warn("affix->arg_types[%d] = %d", arg_pos,
                            // affix->arg_types[arg_pos]);
                            switch (affix->arg_types[arg_pos]) {
                            case ELLIPSIS_FLAG:
                            case VARARGS_FLAG: {
                                affix->ellipsis = true;
                                prototype[prototype_pos++] = ';';
                            } break;
                            case RESET_FLAG:
                            case THIS_FLAG:
                            case DCECL_FLAG:
                            case STDCALL_FLAG:
                            case MSFASTCALL_FLAG:
                            case GNUFASTCALL_FLAG:
                            case MSTHIS_FLAG:
                            case GNUTHIS_FLAG:
                            case ARM_FLAG:
                            case THUMB_FLAG:
                            case SYSCALL_FLAG:
                                // do nothing
                                break;
                            case STRUCT_FLAG:
                            case CPPSTRUCT_FLAG:
                            case UNION_FLAG: {
                                if (affix->aggregates == NULL)
                                    Newxz(affix->aggregates, num_args, DCaggr *);
                                affix->aggregates[arg_pos] = _aggregate(aTHX_ type);
                            }
                            // fall-through
                            default: {
                                ++affix->num_args;
                                prototype[prototype_pos++] = '$';
                            }
                            }
                            affix->arg_info[arg_pos] = newSVsv(type);
                        }
                        else { croak("Unexpected arg type in slot %ld", arg_pos + 1); }
                    }
                }
                else { croak("Expected a list of argument types as an array ref"); }
            }
            STMT_END;
        }
        //~ warn("prototype: [%s]", prototype);

        STMT_START {
            cv =
                newXSproto_portable(ix == 0 ? perl_name : NULL, Affix_trigger, __FILE__, prototype);
            if (UNLIKELY(cv == NULL))
                croak("ARG! Something went really wrong while installing a new XSUB!");
            XSANY.any_ptr = (DCpointer)affix;
        }
        STMT_END;
        RETVAL =
            sv_bless((UNLIKELY(ix == 1) ? newRV_noinc(MUTABLE_SV(cv)) : newRV_inc(MUTABLE_SV(cv))),
                     gv_stashpv("Affix", GV_ADD));

        // affix(..., $symbol, ..., ...)
        // affix(..., [$symbol, $name], ..., ...)
        // wrap(..., $symbol, ..., ...)
        {
            affix->entry_point = dlFindSymbol(affix->lib_handle, sym_name);
            if (affix->entry_point == NULL) {
                affix->entry_point = dlFindSymbol(affix->lib_handle,
                                                  mangle(aTHX_ "Itanium", RETVAL, sym_name, ST(2)));
            }
            if (affix->entry_point == NULL) {
                affix->entry_point =
                    dlFindSymbol(affix->lib_handle, mangle(aTHX_ "Rust", RETVAL, sym_name, ST(2)));
            }
            if (affix->entry_point == NULL) {
                affix->entry_point = dlFindSymbol(affix->lib_handle,
                                                  mangle(aTHX_ "Fortran", RETVAL, sym_name, ST(2)));
            }
            // TODO: D and Swift
            if (affix->entry_point == NULL) { croak("Failed to find symbol named %s", sym_name); }
        }
        PING;

        // affix(..., ..., ..., $ret)
        // wrap(..., ..., ..., $ret)
        if (LIKELY(SvROK(ST(3)) && sv_derived_from(ST(3), "Affix::Type"))) {
            if (UNLIKELY(sv_derived_from(ST(3), "Affix::Type::Array")) &&
                !hv_exists(MUTABLE_HV(SvRV(ST(3))), "size", 4)) {
                warn("Returning an array of unknown length is undefined behavior");
            }
            affix->ret_info = newSVsv(ST(3));
            affix->ret_type = AXT_NUMERIC(ST(3));
        }
        else { croak("Unknown return type"); }
    }

    if (affix->_cpp_constructor) { ++affix->num_args; } // Expect Class->new(...)

#if DEBUG
    warn("lib: %p, entry_point: %p, as: %s, prototype: %s, ix: %d ", (DCpointer)affix->lib_handle,
         affix->entry_point, perl_name, prototype, ix);
#endif
    ST(0) = sv_2mortal(RETVAL);
    if (prototype) safefree(prototype);
    XSRETURN(1);
}
// Expose internals
#define AFFIX_METHOD_GUTS                                                                          \
    dXSARGS;                                                                                       \
    PERL_UNUSED_VAR(items);                                                                        \
    Affix *affix;                                                                                  \
    CV *THIS;                                                                                      \
    STMT_START {                                                                                   \
        HV *st;                                                                                    \
        GV *gvp;                                                                                   \
        SV *const xsub_tmp_sv = ST(0);                                                             \
        SvGETMAGIC(xsub_tmp_sv);                                                                   \
        THIS = sv_2cv(xsub_tmp_sv, &st, &gvp, 0);                                                  \
        {                                                                                          \
            CV *cv = THIS;                                                                         \
            affix = (Affix *)XSANY.any_ptr;                                                        \
        }                                                                                          \
    }                                                                                              \
    STMT_END;

XS_INTERNAL(Affix_args) {
    AFFIX_METHOD_GUTS
    ST(0) = (MUTABLE_SV(affix->arg_info));
    XSRETURN(1);
}

XS_INTERNAL(Affix_retval) {
    AFFIX_METHOD_GUTS
    ST(0) = affix->ret_info;
    XSRETURN(1);
}

XS_INTERNAL(Affix_lib) {
    AFFIX_METHOD_GUTS
    SV *LIBSV = sv_newmortal();
    sv_setref_pv(LIBSV, "Affix::Lib", (DCpointer)affix->lib_handle);
    ST(0) = LIBSV;
    XSRETURN(1);
}

XS_INTERNAL(Affix_cpp_constructor) {
    AFFIX_METHOD_GUTS
    if (items == 2) affix->_cpp_constructor = SvTRUE(ST(1));
    ST(0) = newSVbool(affix->_cpp_constructor);
    XSRETURN(1);
}

XS_INTERNAL(Affix_cpp_const) {
    AFFIX_METHOD_GUTS
    ST(0) = newSVbool(affix->_cpp_const);
    XSRETURN(1);
}

XS_INTERNAL(Affix_cpp_struct) {
    AFFIX_METHOD_GUTS
    ST(0) = newSVbool(affix->_cpp_struct);
    XSRETURN(1);
}

XS_INTERNAL(Affix_DESTROYxxxxxxxxxx) {
    AFFIX_METHOD_GUTS
    if (affix->lib_handle != NULL) {
        dlFreeLibrary(affix->lib_handle);
        affix->lib_handle = NULL;
    }
    if (affix->entry_point != NULL) {
        //~ safefree(affix->entry_point);
        affix->entry_point = NULL;
    }
    size_t index = 0;
    for (index = 0; index < affix->num_args; ++index) {
        (void)sv_2mortal(MUTABLE_SV(affix->arg_info[index]));
    }
    safefree(affix->arg_types);
    safefree(affix->lib_name);
    if (affix->aggregates != NULL) {
        for (index = 0; index < affix->num_args; ++index) {
            if (affix->aggregates[index] != NULL) dcFreeAggr(affix->aggregates[index]);
        }
        safefree(affix->aggregates);
    }
    (void)sv_2mortal(affix->ret_info);
    if (affix->ret_aggregate != NULL) dcFreeAggr(affix->ret_aggregate);
    if (affix->ret_ptr != NULL) safefree(affix->ret_ptr);
    if (affix->_cpp_this_info != NULL) (void)sv_2mortal(affix->_cpp_this_info);

    if (affix->temp_ptrs != NULL) {
        for (size_t index = 0; index < affix->num_args; ++index) {
            if (affix->temp_ptrs[index] != NULL) safefree(affix->temp_ptrs[index]);
        }
        safefree(affix->temp_ptrs);
    }
    safefree(affix);
    XSRETURN_EMPTY;
}

XS_INTERNAL(Affix_END) { // cleanup
    dXSARGS;
    PERL_UNUSED_VAR(items);
    dMY_CXT;
    if (MY_CXT.cvm) dcFree(MY_CXT.cvm);
    XSRETURN_EMPTY;
}

// Utilities
XS_INTERNAL(Affix_sv_dump) {
    dVAR;
    dXSARGS;
    PING;

    if (items != 1) croak_xs_usage(cv, "sv");
    SV *sv = ST(0);
    sv_dump(sv);
    XSRETURN_EMPTY;
}

XS_EXTERNAL(boot_Affix) {
    dVAR;

    dXSBOOTARGSXSAPIVERCHK;
    PERL_UNUSED_VAR(items);

#ifdef USE_ITHREADS
    my_perl = (PerlInterpreter *)PERL_GET_CONTEXT;
#endif

    MY_CXT_INIT;

    // Allow user defined value in a BEGIN{ } block
    SV *vmsize = get_sv("Affix::VMSize", 0);
    MY_CXT.cvm = dcNewCallVM(vmsize == NULL ? 8192 : SvIV(vmsize));

    //
    //~ cv = newXSproto_portable("Affix::affix", Affix_affix, __FILE__, "$$@$");
    //~ XSANY.any_i32 = 0;
    //~ export_function("Affix", "affix", "base");
    //~ cv = newXSproto_portable("Affix::wrap", Affix_affix, __FILE__, "$$@$");
    //~ XSANY.any_i32 = 1;
    //~ export_function("Affix", "wrap", "base");

    //~ (void)newXSproto_portable("Affix::args", Affix_args, __FILE__, "$");
    //~ (void)newXSproto_portable("Affix::retval", Affix_retval, __FILE__, "$");
    //~ (void)newXSproto_portable("Affix::lib", Affix_lib, __FILE__, "$");

    //~ (void)newXSproto_portable("Affix::cpp_constructor", Affix_cpp_constructor, __FILE__, "$;$");
    //~ (void)newXSproto_portable("Affix::cpp_const", Affix_cpp_const, __FILE__, "$");
    //~ (void)newXSproto_portable("Affix::cpp_struct", Affix_cpp_struct, __FILE__, "$");

    (void)newXSproto_portable("Affix::DESTROY", Affix_DESTROY, __FILE__, "$;$");
    (void)newXSproto_portable("Affix::END", Affix_END, __FILE__, "");

    //~ (void)newXSproto_portable("Affix::CLONE", XS_Affix_CLONE, __FILE__, ";@");

    // Utilities
    (void)newXSproto_portable("Affix::sv_dump", Affix_sv_dump, __FILE__, "$");

    //~ export_function("Affix", "DEFAULT_ALIGNMENT", "vars");

    (void)newXSproto_portable("Affix::load_library", Affix_load_library, __FILE__, "$");
    (void)newXSproto_portable("Affix::free_library", Affix_free_library, __FILE__, "$;$");
    (void)newXSproto_portable("Affix::list_symbols", Affix_list_symbols, __FILE__, "$");
    (void)newXSproto_portable("Affix::find_symbol", Affix_find_symbol, __FILE__, "$$");
    (void)newXSproto_portable("Affix::dlerror", Affix_dlerror, __FILE__, "");

    // XXX: Remove before stable
    //~ (void)newXSproto_portable("Affix::fiction_call", Affix_fiction_call, __FILE__, "$;@");

    //
    cv = newXSproto_portable("Affix::affix", Affix_fiction, __FILE__, "$$;$$");
    XSANY.any_i32 = 0;
    export_function("Affix", "affix", "base");
    cv = newXSproto_portable("Affix::wrap", Affix_fiction, __FILE__, "$$;$$");
    XSANY.any_i32 = 1;
    export_function("Affix", "wrap", "base");

    // general purpose flags
    export_constant("Affix", "VOID_FLAG", "flags", VOID_FLAG);
    export_constant("Affix", "BOOL_FLAG", "flags", BOOL_FLAG);
    export_constant("Affix", "SCHAR_FLAG", "flags", SCHAR_FLAG);
    export_constant("Affix", "CHAR_FLAG", "flags", CHAR_FLAG);
    export_constant("Affix", "UCHAR_FLAG", "flags", UCHAR_FLAG);
    export_constant("Affix", "WCHAR_FLAG", "flags", WCHAR_FLAG);
    export_constant("Affix", "SHORT_FLAG", "flags", SHORT_FLAG);
    export_constant("Affix", "USHORT_FLAG", "flags", USHORT_FLAG);
    export_constant("Affix", "INT_FLAG", "flags", INT_FLAG);
    export_constant("Affix", "UINT_FLAG", "flags", UINT_FLAG);
    export_constant("Affix", "LONG_FLAG", "flags", LONG_FLAG);
    export_constant("Affix", "ULONG_FLAG", "flags", ULONG_FLAG);
    export_constant("Affix", "LONGLONG_FLAG", "flags", LONGLONG_FLAG);
    export_constant("Affix", "ULONGLONG_FLAG", "flags", ULONGLONG_FLAG);
    export_constant("Affix", "SIZE_T_FLAG", "flags", SIZE_T_FLAG);
    export_constant("Affix", "FLOAT_FLAG", "flags", FLOAT_FLAG);
    export_constant("Affix", "DOUBLE_FLAG", "flags", DOUBLE_FLAG);
    export_constant("Affix", "WSTRING_FLAG", "flags", WSTRING_FLAG);
    export_constant("Affix", "STDSTRING_FLAG", "flags", STDSTRING_FLAG);
    export_constant("Affix", "STRUCT_FLAG", "flags", STRUCT_FLAG);
    export_constant("Affix", "AFFIX_FLAG", "flags", AFFIX_FLAG);
    export_constant("Affix", "CPPSTRUCT_FLAG", "flags", CPPSTRUCT_FLAG);
    export_constant("Affix", "UNION_FLAG", "flags", UNION_FLAG);
    export_constant("Affix", "CODEREF_FLAG", "flags", CODEREF_FLAG);
    export_constant("Affix", "POINTER_FLAG", "flags", POINTER_FLAG);
    export_constant("Affix", "SV_FLAG", "flags", SV_FLAG);

    // Qualifiers
    export_constant("Affix", "CONST_FLAG", "all", CONST_FLAG);
    export_constant("Affix", "VOLATILE_FLAG", "all", VOLATILE_FLAG);
    export_constant("Affix", "RESTRICT_FLAG", "all", RESTRICT_FLAG);
    export_constant("Affix", "REFERENCE_FLAG", "all", REFERENCE_FLAG);

    // calling conventions
    export_constant("Affix", "RESET_FLAG", "flags", RESET_FLAG);
    export_constant("Affix", "THIS_FLAG", "flags", THIS_FLAG);
    export_constant("Affix", "ELLIPSIS_FLAG", "flags", ELLIPSIS_FLAG);
    export_constant("Affix", "VARARGS_FLAG", "flags", VARARGS_FLAG);
    export_constant("Affix", "DCECL_FLAG", "flags", DCECL_FLAG);
    export_constant("Affix", "STDCALL_FLAG", "flags", STDCALL_FLAG);
    export_constant("Affix", "MSFASTCALL_FLAG", "flags", MSFASTCALL_FLAG);
    export_constant("Affix", "GNUFASTCALL_FLAG", "flags", GNUFASTCALL_FLAG);
    export_constant("Affix", "MSTHIS_FLAG", "flags", MSTHIS_FLAG);
    export_constant("Affix", "GNUTHIS_FLAG", "flags", GNUTHIS_FLAG);
    export_constant("Affix", "ARM_FLAG", "flags", ARM_FLAG);
    export_constant("Affix", "THUMB_FLAG", "flags", THUMB_FLAG);
    export_constant("Affix", "SYSCALL_FLAG", "flags", SYSCALL_FLAG);

    // Type object slots
    export_constant("Affix", "SLOT_STRINGIFY", "flags", SLOT_STRINGIFY);
    export_constant("Affix", "SLOT_NUMERIC", "flags", SLOT_NUMERIC);
    export_constant("Affix", "SLOT_SIZEOF", "flags", SLOT_SIZEOF);
    export_constant("Affix", "SLOT_ALIGNMENT", "flags", SLOT_ALIGNMENT);
    export_constant("Affix", "SLOT_OFFSET", "flags", SLOT_OFFSET);
    export_constant("Affix", "SLOT_SUBTYPE", "flags", SLOT_SUBTYPE);
    export_constant("Affix", "SLOT_ARRAYLEN", "flags", SLOT_ARRAYLEN);
    export_constant("Affix", "SLOT_AGGREGATE", "flags", SLOT_AGGREGATE);
    export_constant("Affix", "SLOT_TYPEDEF", "flags", SLOT_TYPEDEF);
    export_constant("Affix", "SLOT_CAST", "flags", SLOT_CAST);
    export_constant("Affix", "SLOT_CODEREF_ARGS", "flags", SLOT_CODEREF_ARGS);

    //
    //~ boot_Affix_Aggregate(aTHX_ cv);
    //~ boot_Affix_pin(aTHX_ cv);
    boot_Affix_Pointer(aTHX_ cv);
    boot_Affix_Lib(aTHX_ cv);
    boot_Affix_Platform(aTHX_ cv);

    Perl_xs_boot_epilog(aTHX_ ax);
}
