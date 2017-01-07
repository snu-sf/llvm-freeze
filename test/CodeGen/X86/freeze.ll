; RUN: llc -mtriple=x86_64-unknown-linux-gnu -print-machineinstrs=expand-isel-pseudos %s -o /dev/null 2>&1 | FileCheck %s --check-prefix=MCINSTR
; RUN: llc -mtriple=x86_64-unknown-linux-gnu < %s 2>&1 | FileCheck %s --check-prefix=X86ASM

; X86ASM: imull   %eax, %eax
; X86ASM: xorl    %eax, %eax
; X86ASM: retq

; MCINSTR: %vreg1[[attr1:.*]] = IMPLICIT_DEF;
; MCINSTR: %vreg2[[attr2:.*]] = IMUL32rr %vreg1[[attr3:.*]], %vreg1,
; MCINSTR: %vreg3[[attr4:.*]] = XOR32rr %vreg2[[attr5:.*]], %vreg1,
; MCINSTR: %EAX[[attr6:.*]] = COPY %vreg3;
; MCINSTR: RET 0, %EAX

define i32 @foo(i32 %x) {
  %y1 = freeze i32 undef
  %t1 = mul i32 %y1, %y1
  %t2 = xor i32 %t1, %y1
  ret i32 %t2
}
