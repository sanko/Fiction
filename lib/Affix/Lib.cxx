#include "../Affix.h"

char *locate_lib(pTHX_ SV *_lib, SV *_ver) {
    // Use perl to get the actual path to the library
    dSP;
    int count;
    char *retval = NULL;
    //~ if (!SvOK(_lib)) {
    //~ GV *tmpgv = gv_fetchpvs("\030", GV_ADD | GV_NOTQUAL, SVt_PV); /* $^X */
    //~ _lib = GvSV(tmpgv);
    //~ }
    if (SvOK(_lib) /*&& SvREADONLY(_lib)*/) {
        ENTER;
        SAVETMPS;
        PUSHMARK(SP);
        XPUSHs(_lib);
        XPUSHs(_ver);
        PUTBACK;
        count = call_pv("Affix::locate_lib", G_SCALAR);
        SPAGAIN;
        if (count == 1) {
            SV *ret = POPs;
            if (SvOK(ret)) {
                STRLEN len;
                //~ sv_dump(ret);
                char *__lib = SvPVx(ret, len);
                if (len) {
                    Newxz(retval, len + 1, char);
                    Copy(__lib, retval, len, char);
                }
            }
        }
        PUTBACK;
        FREETMPS;
        LEAVE;
    }
    return retval;
}

char *mangle(pTHX_ const char *abi, SV *affix, const char *symbol, SV *args) {
    char *retval;
    load_module(PERL_LOADMOD_NOIMPORT, newSVpvf("Affix::ABI::%s", abi), NULL, NULL);
    {
        dSP;
        SV *err_tmp;
        ENTER;
        SAVETMPS;
        PUSHMARK(SP);
        XPUSHs(affix);
        mXPUSHp(symbol, strlen(symbol));
        XPUSHs(args);
        PUTBACK;
        (void)call_pv(form("Affix::ABI::%s::mangle", abi), G_SCALAR | G_EVAL | G_KEEPERR);
        SPAGAIN;
        err_tmp = ERRSV;
        if (SvTRUE(err_tmp)) {
            croak("Malformed call to Affix::ABI::%s::mangle( ... ): %s\n", abi,
                  SvPV_nolen(err_tmp));
            (void)POPs;
        }
        else {
            retval = POPp;
            // SvSetMagicSV(type, retval);
        }
        // FREETMPS;
        LEAVE;
    }
    warn("! mangled: %s", retval);
    return retval;
}

#if defined(DC__C_GNU) || defined(DC__C_CLANG)
XS_INTERNAL(Affix_Lib_list_unmangled_symbols) {
    /* dlSymsName(...) is not thread-safe on MacOS */
    dVAR;
    dXSARGS;
    if (items != 1) croak_xs_usage(cv, "lib");

    AV *RETVAL;
    DLLib *lib;

    if (sv_derived_from(ST(0), "Affix::Lib")) {
        IV tmp = SvIV((SV *)SvRV(ST(0)));
        lib = INT2PTR(DLLib *, tmp);
    }
    else
        croak("lib is not of type Affix::Lib");

    RETVAL = newAV();
    char *name;
    Newxz(name, 1024, char);
    int len = dlGetLibraryPath(lib, name, 1024);
    if (len == 0) croak("Failed to get library name");

    HV *cache = get_hv(form("Affix::Cache::Symbol::%s", name), 0);
    while (HE *next = hv_iternext(cache)) {
        av_push(RETVAL, newSVsv(hv_iterval(cache, next)));
    }

    ST(0) = sv_2mortal(newRV_noinc(MUTABLE_SV(RETVAL)));
    XSRETURN(1);
}
#endif

XS_INTERNAL(Affix_Lib_path) {
    dVAR;
    dXSARGS;
    if (items != 1) croak_xs_usage(cv, "lib");

    SV *RETVAL;
    DLLib *lib;

    if (sv_derived_from(ST(0), "Affix::Lib")) {
        IV tmp = SvIV((SV *)SvRV(ST(0)));
        lib = INT2PTR(DLLib *, tmp);
    }
    else
        croak("lib is not of type Affix::Lib");

    char *name;
    Newxz(name, 1024, char);
    int len = dlGetLibraryPath(lib, name, 1024);
    PING;
    if (len == 0) croak("Failed to get library name");
    RETVAL = newSVpv(name, len - 1);
    safefree(name);
    {
        RETVAL = sv_2mortal(RETVAL);
        ST(0) = RETVAL;
    }

    XSRETURN(1);
}

void boot_Affix_Lib(pTHX_ CV *cv) {
    PERL_UNUSED_VAR(cv);

    //~ (void)newXSproto_portable("Affix::load_lib", Affix_load_lib, __FILE__, "$;$");
    //~ export_function("Affix", "load_lib", "lib");
#if defined(DC__C_GNU) || defined(DC__C_CLANG)
    (void)newXSproto_portable("Affix::Lib::list_unmangled_symbols",
                              Affix_Lib_list_unmangled_symbols, __FILE__, "$");
#endif
    (void)newXSproto_portable("Affix::Lib::path", Affix_Lib_path, __FILE__, "$");
}
