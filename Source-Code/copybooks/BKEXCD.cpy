      ******************************************************************
      * DCLGEN  : BKEXCD                                              *
      * TABELA  : BANCO.EXTRATO_MOV                                   *
      * DESCRICAO: MOVIMENTOS BANCARIOS (EXTRATO)                     *
      ******************************************************************
           EXEC SQL DECLARE BANCO.EXTRATO_MOV TABLE
           ( EX_COD_AGENCIA          CHAR(4)         NOT NULL,
             EX_NUM_CONTA            CHAR(10)        NOT NULL,
             EX_DAT_MOVIMENTO        DATE            NOT NULL,
             EX_NUM_SEQ              SMALLINT        NOT NULL,
             EX_COD_TIPO_MOV         CHAR(3)         NOT NULL,
             EX_DES_HISTORICO        VARCHAR(20)     NOT NULL,
             EX_VLR_MOVIMENTO        DECIMAL(13,2)   NOT NULL,
             EX_VLR_SALDO_APOS       DECIMAL(15,2)   NOT NULL
           ) END-EXEC.
      ******************************************************************
      * DCLGEN AREA - 01 DCLEXTRATO
      ******************************************************************
        01  DCLEXTRATO.
            12  EX-COD-AGENCIA       PIC X(4).
            12  EX-NUM-CONTA         PIC X(10).
            12  EX-DAT-MOVIMENTO     PIC X(10).
            12  EX-NUM-SEQ           PIC S9(4)       COMP.
            12  EX-COD-TIPO-MOV      PIC X(3).
            12  EX-DES-HISTORICO.
                16  EX-DES-HIST-LEN  PIC S9(4)       COMP.
                16  EX-DES-HIST-TEXT PIC X(20).
            12  EX-VLR-MOVIMENTO     PIC S9(11)V99   COMP-3.
            12  EX-VLR-SALDO-APOS    PIC S9(13)V99   COMP-3.
      ******************************************************************
      * INDICATOR VARIABLES
      ******************************************************************
        01  DCLEXTRATO-IND.
            12  EXIND-COD-AGENCIA    PIC S9(4)       COMP  VALUE 0.
            12  EXIND-NUM-CONTA      PIC S9(4)       COMP  VALUE 0.
            12  EXIND-DAT-MOVIMENTO  PIC S9(4)       COMP  VALUE 0.
            12  EXIND-NUM-SEQ        PIC S9(4)       COMP  VALUE 0.
            12  EXIND-COD-TIPO-MOV   PIC S9(4)       COMP  VALUE 0.
            12  EXIND-DES-HISTORICO  PIC S9(4)       COMP  VALUE 0.
            12  EXIND-VLR-MOVIMENTO  PIC S9(4)       COMP  VALUE 0.
            12  EXIND-VLR-SALDO-APOS PIC S9(4)       COMP  VALUE 0.
