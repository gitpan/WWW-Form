/*
 * This file was generated automatically by xsubpp version 1.9507 from the 
 * contents of Form.xs. Do not edit this file, edit Form.xs instead.
 *
 *	ANY CHANGES MADE HERE WILL BE LOST! 
 *
 */

#line 1 "Form.xs"
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

static int
not_here(char *s)
{
    croak("%s not implemented on this architecture", s);
    return -1;
}

static double
constant(char *name, int len, int arg)
{
    errno = EINVAL;
    return 0;
}

#line 29 "Form.c"
XS(XS_WWW__Form_constant)
{
    dXSARGS;
    if (items != 2)
	Perl_croak(aTHX_ "Usage: WWW::Form::constant(sv, arg)");
    {
#line 25 "Form.xs"
	STRLEN		len;
#line 38 "Form.c"
	SV *	sv = ST(0);
	char *	s = SvPV(sv, len);
	int	arg = (int)SvIV(ST(1));
	double	RETVAL;
	dXSTARG;
#line 31 "Form.xs"
	RETVAL = constant(s,len,arg);
#line 46 "Form.c"
	XSprePUSH; PUSHn((double)RETVAL);
    }
    XSRETURN(1);
}

#ifdef __cplusplus
extern "C"
#endif
XS(boot_WWW__Form)
{
    dXSARGS;
    char* file = __FILE__;

    XS_VERSION_BOOTCHECK ;

        newXS("WWW::Form::constant", XS_WWW__Form_constant, file);
    XSRETURN_YES;
}
