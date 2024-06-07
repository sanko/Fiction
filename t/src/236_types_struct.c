#include "std.h"
// ext: .c
typedef struct {
    bool is_true;
    char ch;
    unsigned char uch;
    short s;
    unsigned short S;
    int i;
    unsigned int I;
    long l;
    unsigned long L;
    long long ll;
    unsigned long long LL;
    float f;
    double d;
    void *ptr;
    const char *str;
    // TODO:
    // Union
    // Struct
    // WChar
    // WString
    // CodeRef
    // Pointer[SV]
} Example;

size_t SIZEOF() {
    return sizeof(Example);
}

bool get_bool(Example ex) {
    return ex.is_true;
}
char get_char(Example ex) {
    return ex.ch;
}
unsigned char get_uchar(Example ex) {
    return ex.uch;
}
short get_short(Example ex) {
    return ex.s;
}
unsigned short get_ushort(Example ex) {
    return ex.S;
}
int get_int(Example ex) {
    return ex.i;
}
unsigned int get_uint(Example ex) {
    return ex.I;
}
long get_long(Example ex) {
    return ex.l;
}
unsigned long get_ulong(Example ex) {
    return ex.L;
}
long long get_longlong(Example ex) {
    return ex.ll;
}
unsigned long long get_ulonglong(Example ex) {
    return ex.LL;
}
float get_float(Example ex) {
    return ex.f;
}
double get_double(Example ex) {
    return ex.d;
}
//~ TODO:
void *get_ptr(Example ex) {
    warn("---> %p", ex.ptr);
    if (ex.ptr != NULL) DumpHex(ex.ptr, 16);
    return ex.ptr;
}
const char *get_str(Example ex) {
    return ex.str;
}
