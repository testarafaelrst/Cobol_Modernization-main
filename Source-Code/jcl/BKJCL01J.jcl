//*===============================================================*
//* JCL     : BKJCL01J                                          *
//* SISTEMA : SISTEMA BANCARIO - BKC01                          *
//*                                                              *
//* STEPS:                                                       *
//*   STEP1 - ASSEMBLA O MAPA BMS (BKCONS0)                     *
//*   STEP2 - LINKA  O MAPA BMS                                  *
//*   STEP3 - PRECOMPILA SQL (DB2 PRECOMPILE)                    *
//*   STEP4 - TRADUZ CICS (CICS TRANSLATOR)                      *
//*   STEP5 - COMPILA O PROGRAMA (COBOL II)                      *
//*   STEP6 - LINKA O PROGRAMA                                   *
//*===============================================================*
//BKJCL01J JOB (ACCT),'BKC01 COMPILE',
//             CLASS=A,
//             MSGCLASS=X,
//             MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//*
//*------------------------------------------------------------*
//* STEP1 - ASSEMBLY DO MAPSET BMS                             *
//*------------------------------------------------------------*
//ASMMAP   EXEC PGM=ASMA90,
//             PARM='DECK,NOOBJECT'
//SYSLIB    DD DSN=SYS1.MACLIB,DISP=SHR
//          DD DSN=CICS.SDFHMAC,DISP=SHR
//SYSUT1    DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSUT2    DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSUT3    DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSPUNCH  DD DSN=&&MAPOBJ,
//             DISP=(NEW,PASS),
//             UNIT=SYSDA,
//             SPACE=(TRK,(5,2))
//SYSPRINT  DD SYSOUT=*
//SYSIN     DD DSN=BANCO.CICS.MAPS(BKCONS0),DISP=SHR
//*
//*------------------------------------------------------------*
//* STEP2 - LINK DO MAPSET BMS                                 *
//*------------------------------------------------------------*
//LNKMAP   EXEC PGM=IEWL,
//             PARM='LIST,LET,XREF',
//             COND=(4,LT,ASMMAP)
//SYSLIB    DD DSN=CICS.SDFHLOAD,DISP=SHR
//SYSUT1    DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSPRINT  DD SYSOUT=*
//SYSLMOD   DD DSN=BANCO.CICS.LOAD(BKCONS0),
//             DISP=SHR
//SYSLIN    DD DSN=&&MAPOBJ,DISP=(OLD,DELETE)
//          DD DDNAME=SYSIN
//SYSIN     DD *
 NAME BKCONS0(R)
//*
//*------------------------------------------------------------*
//* STEP3 - DB2 PRECOMPILE                                     *
//*------------------------------------------------------------*
//DB2PREC  EXEC PGM=DSNHPC,
//             PARM='HOST(COBOL),VERSION(AUTO),APOSTSQL(YES)',
//             COND=(4,LT)
//DBRMLIB   DD DSN=BANCO.DBRMLIB(BKC01),
//             DISP=SHR
//SYSCIN    DD DSN=&&DB2OUT,
//             DISP=(NEW,PASS),
//             UNIT=SYSDA,
//             SPACE=(TRK,(10,5))
//SYSLIB    DD DSN=BANCO.CICS.COPYLIB,DISP=SHR
//          DD DSN=BANCO.DB2.DCLGEN,DISP=SHR
//SYSUT1    DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSPRINT  DD SYSOUT=*
//SYSIN     DD DSN=BANCO.CICS.SRC(BKC01),DISP=SHR
//*
//*------------------------------------------------------------*
//* STEP4 - CICS TRANSLATOR (COBOL II)                         *
//*------------------------------------------------------------*
//CICSTRAN EXEC PGM=DFHECP1$,
//             PARM='COBOL2,CICS',
//             COND=(4,LT)
//SYSLIB    DD DSN=BANCO.CICS.COPYLIB,DISP=SHR
//          DD DSN=BANCO.DB2.DCLGEN,DISP=SHR
//          DD DSN=CICS.SDFHCOB,DISP=SHR
//SYSUT1    DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSUT2    DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSUT3    DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSUT4    DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSUT5    DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSUT6    DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSUT7    DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSPRINT  DD SYSOUT=*
//SYSPUNCH  DD DSN=&&CICSOUT,
//             DISP=(NEW,PASS),
//             UNIT=SYSDA,
//             SPACE=(TRK,(15,5))
//SYSIN     DD DSN=&&DB2OUT,DISP=(OLD,DELETE)
//*
//*------------------------------------------------------------*
//* STEP5 - COMPILACAO COBOL II                                *
//*------------------------------------------------------------*
//COBCOMP  EXEC PGM=IGYCRCTL,
//             PARM='APOST,LIB,RENT,RES,OPT,NODYNAM,NODECK',
//             COND=(4,LT)
//STEPLIB   DD DSN=IGY.V2R4M0.SIGYCOMP,DISP=SHR
//SYSLIB    DD DSN=BANCO.CICS.COPYLIB,DISP=SHR
//          DD DSN=BANCO.DB2.DCLGEN,DISP=SHR
//          DD DSN=CICS.SDFHCOB,DISP=SHR
//SYSUT1    DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSUT2    DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSUT3    DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSUT4    DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSUT5    DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSUT6    DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSUT7    DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSPRINT  DD SYSOUT=*
//SYSLIN    DD DSN=&&COBOUT,
//             DISP=(NEW,PASS),
//             UNIT=SYSDA,
//             SPACE=(TRK,(15,5))
//SYSIN     DD DSN=&&CICSOUT,DISP=(OLD,DELETE)
//*
//*------------------------------------------------------------*
//* STEP6 - LINK-EDIT DO PROGRAMA                              *
//*------------------------------------------------------------*
//LNKPGM   EXEC PGM=IEWL,
//             PARM='LIST,LET,XREF,RENT,REUS',
//             COND=(4,LT)
//SYSLIB    DD DSN=CICS.SDFHLOAD,DISP=SHR
//          DD DSN=DSN.SDSNEXIT,DISP=SHR
//          DD DSN=DSN.SDSNLOAD,DISP=SHR
//          DD DSN=IGY.V2R4M0.SIGYCOMP,DISP=SHR
//          DD DSN=CEE.SCEERUN,DISP=SHR
//SYSUT1    DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSPRINT  DD SYSOUT=*
//SYSLMOD   DD DSN=BANCO.CICS.LOAD(BKC01),
//             DISP=SHR
//SYSLIN    DD DSN=&&COBOUT,DISP=(OLD,DELETE)
//          DD DDNAME=SYSIN
//SYSIN     DD *
 NAME BKC01(R)
//*===============================================================*
//* FIM DO JCL BKJCL01J                                          *
//*===============================================================*
