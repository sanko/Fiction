/*

 Package: dyncall
 Library: portasm
 File: portasm/portasm-arm.S
 Description:
 License:

   Copyright (c) 2020 Bernhard Urban-Forster <beurba@microsoft.com>

   Permission to use, copy, modify, and distribute this software for any
   purpose with or without fee is hereby granted, provided that the above
   copyright notice and this permission notice appear in all copies.

   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
   WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
   MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
   ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
   WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
   ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
   OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

*/



#define BEGIN_ASM
#include "../dyncall/dyncall_macros.h"

#if defined(GEN_MASM)
#define TEXTAREA AREA .text, CODE, ARM64
#define ALIGN(X)
#define LABELDEF(X) dcCall_arm64_##X
#define LABELUSE(X) dcCall_arm64_##X
#define END_PROC ENDP
#define END_ASM END
#define GLOBAL_C(X) EXPORT X
#define ENTRY_C(X) X PROC

#else

#define TEXTAREA .text
#define ALIGN(X) .align 2
#define LABELDEF(X) .##X##:
#define LABELUSE(X) .##X
#define END_PROC
#define END_ASM

#if defined(DC__OS_Darwin)
#define GLOBAL_C(X) .globl _##X
#define ENTRY_C(X) _##X:
#else
#define GLOBAL_C(X) .globl X
#define ENTRY_C(X) X:
#endif

#endif

