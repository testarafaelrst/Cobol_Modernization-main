      ******************************************************************
      * DCLGEN  : BKAGCD                                              *
      * TABELA  : BANCO.AGENCIA                                       *
      * DESCRICAO: CADASTRO DE AGENCIAS BANCARIAS                     *
      ******************************************************************
           EXEC SQL DECLARE BANCO.AGENCIA TABLE
           ( AG_COD_AGENCIA          CHAR(4)         NOT NULL,
             AG_NOM_AGENCIA          VARCHAR(40)     NOT NULL,
             AG_NOM_CIDADE           VARCHAR(30)     NOT NULL,
             AG_NOM_ESTADO           CHAR(2)         NOT NULL,
             AG_NUM_TELEFONE         CHAR(14),
             AG_DAT_ABERTURA         DATE            NOT NULL
           ) END-EXEC.
      ******************************************************************
      * DCLGEN AREA - 01 DCLAGENCIA
      ******************************************************************
        01  DCLAGENCIA.
            12  AG-COD-AGENCIA       PIC X(4).
            12  AG-NOM-AGENCIA.
                16  AG-NOM-AGENCIA-LEN   PIC S9(4)   COMP.
                16  AG-NOM-AGENCIA-TEXT  PIC X(40).
            12  AG-NOM-CIDADE.
                16  AG-NOM-CIDADE-LEN    PIC S9(4)   COMP.
                16  AG-NOM-CIDADE-TEXT   PIC X(30).
            12  AG-NOM-ESTADO        PIC X(2).
            12  AG-NUM-TELEFONE      PIC X(14).
            12  AG-DAT-ABERTURA      PIC X(10).
      ******************************************************************
      * SQLDA - INDICATOR VARIABLES
      ******************************************************************
        01  DCLAGENCIA-IND.
            12  AGIND-COD-AGENCIA    PIC S9(4)       COMP  VALUE 0.
            12  AGIND-NOM-AGENCIA    PIC S9(4)       COMP  VALUE 0.
            12  AGIND-NOM-CIDADE     PIC S9(4)       COMP  VALUE 0.
            12  AGIND-NOM-ESTADO     PIC S9(4)       COMP  VALUE 0.
            12  AGIND-NUM-TELEFONE   PIC S9(4)       COMP  VALUE 0.
            12  AGIND-DAT-ABERTURA   PIC S9(4)       COMP  VALUE 0.
