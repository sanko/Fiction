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
    struct {
        int i;
        char c;
    } nested;
    struct {char* str2;} nested2;
    // TODO:
    // Union
    // Struct
    // WChar
    // WString
    // CodeRef
    // Pointer[SV]
    // Array
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
void *get_ptr(Example ex) {
    return ex.ptr;
}
const char *get_str(Example ex) {
    return ex.str;
}

// TODO:
size_t get_nested_offset() {
    return offsetof(Example, nested);
}

int get_nested_int(Example ex) {
    return ex.nested.i;
}

size_t get_nested2_offset() {
    return offsetof(Example, nested2);
}
char* get_nested_str(Example ex) {
    warn("HERE! I! AM!");
    if(!&ex) croak("UGH!!!");
    warn("str2 is %s", ex.nested2.str2);
    return ex.nested2.str2;
}

Example get_struct() {
    Example ret = {.is_true = 1,
                   .ch = 'M',
                   .uch = 'm',
                   .s = 35,
                   .S = 88,
                   .i = 1123,
                   .I = 8890,
                   .l = 13579,
                   .L = 97531,
                   .ll = 1122334455,
                   .LL = 9988776655,
                   .f = 2.3,
                   .d = 9.7,
                   .ptr = NULL, // TODO
                   .str = "Hello!",
                   .nested = {.i = 1111, .c = 'Q'},
                   .nested2 ={.str2 = "Alpha"}};
    DumpHex(&(ret.nested2), sizeof(ret));
    return ret;
}
