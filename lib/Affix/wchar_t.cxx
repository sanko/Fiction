#include "../Affix.h"

SV *wchar2utf(pTHX_ wchar_t *src, size_t len) {
#if defined(DC__OS_Win32) || defined(DC__OS_Win64)
    size_t outlen = WideCharToMultiByte(CP_UTF8, 0, src, len, NULL, 0, NULL, NULL);
    char *r = (char *)safecalloc(outlen + 1, sizeof(char));
    WideCharToMultiByte(CP_UTF8, 0, src, len, r, outlen, NULL, NULL);
    SV *RETVAL = newSVpvn_utf8(r, strlen(r), true);
    safefree((DCpointer)r);
#else
    SV *RETVAL = newSV(0);
    U8 *dst = (U8 *)safecalloc(len + 1, SIZEOF_WCHAR);
    U8 *d = dst;
    while (len--) {
        if (*src < 256)
            *d = (U8)*src;
        else
            d = uvchr_to_utf8(d, *src++);
    }
    sv_setpv(RETVAL, (char *)dst);
    sv_utf8_decode(RETVAL);
    safefree(dst);
#endif
    return RETVAL;
}

wchar_t *utf2wchar(pTHX_ SV *src, size_t len) {
    wchar_t *RETVAL = (wchar_t *)safemalloc((len + 1) * SIZEOF_WCHAR);
#if defined(DC__OS_Win32) || defined(DC__OS_Win64)
    MultiByteToWideChar(CP_UTF8, MB_PRECOMPOSED, SvPV_nolen(src), -1, RETVAL, len + 1);
#else
    wchar_t *p = RETVAL;
    if (SvUTF8(src)) {
        STRLEN len_;
        char *raw = SvPVutf8(src, len_);

        mbstowcs(RETVAL, raw, (len_ + 1) * SIZEOF_WCHAR); // Include space for null terminator

        /*
        STRLEN xlen;
        size_t utflen;
        while (*raw) {
            utflen = isUTF8_CHAR(raw, raw + SIZEOF_WCHAR);
            if (utflen) {
                *p++ = utf8_to_uvchr_buf(raw, raw +( utflen* 4), &xlen);
                raw += xlen;
            }
            else
                *p++ = (wchar_t)*raw++;
        }*/
    }
    //~ else {
        //~ while (*raw) {
            //~ *p++ = (wchar_t)*raw++;
        //~ }
    //~ }
    //~ *p = 0;
#endif
    return RETVAL;
}
