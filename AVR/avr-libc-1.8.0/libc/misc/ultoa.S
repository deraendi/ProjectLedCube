/* Copyright (c) 2002, Reiner Patommel
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

   * Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in
     the documentation and/or other materials provided with the
     distribution.
   * Neither the name of the copyright holders nor the names of
     contributors may be used to endorse or promote products derived
     from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE. */

/* $Id: ultoa.S 1944 2009-04-01 23:12:20Z arcanum $ */

/*
   ultoa.S

   Contributors:
     Created by Reiner Patommel based on
     itoa.s by Michael Rickmann <mrickma@gwdg.de>
     19 June 2003 changed by Reiner Patommel bug# 4010

	#include <stdlib.h>
	char *ultoa(unsigned long int value, char *string, int radix);
  ----------------------------------------------------------------------
*/

#if !defined(__DOXYGEN__)

#include "macros.inc"
#include "ctoasm.inc"

    ASSEMBLY_CLIB_SECTION
	.global _U(ultoa)
	.func _U(ultoa)

/* function arguments */
#define a_val_hhi	r25
#define a_val_hlo	r24
#define a_val_hi 	r23
#define a_val_lo 	r22
#define a_str_hi 	r21
#define a_str_lo 	r20
#define a_radix_hi	r19
#define a_radix   	r18

/* local variables */
#define r_radix		r28


_U(ultoa):
	X_movw	ZL, a_str_lo	; Z = &string
	push	r28		; save r28
	push	ZH		; keep &string
	push	ZL
	cpi	a_radix, 2	; no radix < 2
	brlt	99f		; return with \0
	cpi	a_radix, 37	; no radix > 36
	brge	99f		; return with \0
	mov	r_radix, a_radix; save radix
1:
	mov	r18, r_radix	; radix is divisor
	clr	r19		; remainder of number is dividend
	clr	r20
	clr	r21
	push	ZH		; Z will be clobbered
	push	ZL		; dividend in r25:r22, divisor in r21:r18
	XCALL	_U(__udivmodsi4); quotient in r21:r18, remainder in r25:r22
	pop	ZL
	pop	ZH
	subi	r22, 0xd0	; + '0'
	cpi	r22, 0x3a	; > '9' ?
	brlt	10f
	subi	r22, 0xd9	; + 'a' - 10 - '0'
10:
	st	Z+, r22		; write character to string in reverse order!
	X_movw	a_val_lo, r18	; quotient -> dividend
	X_movw 	a_val_hlo, r20
	subi 	a_val_lo, 0
	sbci	a_val_hi, 0
	sbci	a_val_hlo, 0
	sbci 	a_val_hhi,0 	; value == 0 ?
	brne	1b
99:
	st	Z, __zero_reg__	; terminate string
	pop	a_val_hlo	; restore &string as return value
	pop	a_val_hhi
	pop	r28		; restore r28
	XJMP	_U(strrev)	; reverse string
	.endfunc

#endif /* not __DOXYGEN__ */
