      ******************************************************************
      * DCLGEN  : BKCTCD                                              *
      * TABELA  : BANCO.CONTA                                         *
      * DESCRICAO: CADASTRO DE CONTAS BANCARIAS                       *
      ******************************************************************
           EXEC SQL DECLARE BANCO.CONTA TABLE
           ( CT_COD_AGENCIA          CHAR(4)         NOT NULL,
             CT_NUM_CONTA            CHAR(10)        NOT NULL,
             CT_NOM_CLIENTE          VARCHAR(40)     NOT NULL,
             CT_COD_TIPO_CONTA       CHAR(2)         NOT NULL,
             CT_DES_TIPO_CONTA       VARCHAR(20)     NOT NULL,
             CT_VLR_SALDO            DECIMAL(15,2)   NOT NULL,
             CT_DAT_ABERTURA         DATE            NOT NULL,
             CT_COD_STATUS           CHAR(1)         NOT NULL
           ) END-EXEC.
      ******************************************************************
      * DCLGEN AREA - 01 DCLCONTA
      ******************************************************************
        01  DCLCONTA.
            12  CT-COD-AGENCIA       PIC X(4).
            12  CT-NUM-CONTA         PIC X(10).
            12  CT-NOM-CLIENTE.
                16  CT-NOM-CLIENTE-LEN   PIC S9(4)   COMP.
                16  CT-NOM-CLIENTE-TEXT  PIC X(40).
            12  CT-COD-TIPO-CONTA    PIC X(2).
            12  CT-DES-TIPO-CONTA.
                16  CT-DES-TIPO-LEN      PIC S9(4)   COMP.
                16  CT-DES-TIPO-TEXT     PIC X(20).
            12  CT-VLR-SALDO         PIC S9(13)V99   COMP-3.
            12  CT-DAT-ABERTURA      PIC X(10).
            12  CT-COD-STATUS        PIC X(1).
      ******************************************************************
      * INDICATOR VARIABLES
      ******************************************************************
        01  DCLCONTA-IND.
            12  CTIND-COD-AGENCIA    PIC S9(4)       COMP  VALUE 0.
            12  CTIND-NUM-CONTA      PIC S9(4)       COMP  VALUE 0.
            12  CTIND-NOM-CLIENTE    PIC S9(4)       COMP  VALUE 0.
            12  CTIND-COD-TIPO-CONTA PIC S9(4)       COMP  VALUE 0.
            12  CTIND-DES-TIPO-CONTA PIC S9(4)       COMP  VALUE 0.
            12  CTIND-VLR-SALDO      PIC S9(4)       COMP  VALUE 0.
            12  CTIND-DAT-ABERTURA   PIC S9(4)       COMP  VALUE 0.
            12  CTIND-COD-STATUS     PIC S9(4)       COMP  VALUE 0.
