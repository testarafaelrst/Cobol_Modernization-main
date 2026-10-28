      *===============================================================*
      * PROGRAMA  : BKC01                                            *
      * SISTEMA   : SISTEMA BANCARIO                                 *
      * TRANSACAO : BKQ1                                             *
      * MAPSET    : BKCONS0    MAP: BKCON01                          *
      *                                                               *
      * FUNCAO    : CONSULTA DE AGENCIA/CONTA BANCARIA               *
      *             - EXIBE DADOS CADASTRAIS DA CONTA                *
      *             - EXIBE SALDO ATUAL                              *
      *             - EXIBE EXTRATO DOS ULTIMOS 5 DIAS               *
      *                                                               *
      * TABELAS DB2:                                                  *
      *   BANCO.AGENCIA    - CADASTRO DE AGENCIAS (BKAGCD)           *
      *   BANCO.CONTA      - CADASTRO DE CONTAS   (BKCTCD)           *
      *   BANCO.EXTRATO_MOV- MOVIMENTOS BANCARIOS (BKEXCD)           *
      *                                                               *
      * PF KEYS:                                                      *
      *   ENTER = CONSULTAR                                           *
      *   PF3   = SAIR / RETORNAR AO MENU                            *
      *   PF7   = LIMPAR CAMPOS                                       *
      *                                                               *
      * ANALYST   : COBOL II / CICS BANKING DEMO                     *
      * USER      : OPERACAO BANCARIA                                 *
      * SYSTEM    : BANCO SISTEMA (BKSI)                              *
      *                                                               *
      * DATE-WRITTEN: 2024-01-01                                      *
      * AUTHOR      : DEMO COBOL II CICS                              *
      *                                                               *
      *===============================================================*
      * LOG DE ALTERACOES:                                            *
      *  DATA       ANALISTA  DESCRICAO                               *
      *  ---------- --------- ---------------------------------       *
      *  2024-01-01 DEMO      CRIACAO INICIAL                         *
      *===============================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID.    BKC01.
      *PROGRAM-TITLE. CONSULTA DE CONTA BANCARIA
      *AUTHOR.        COBOL II CICS BANKING DEMO
      *DATE-WRITTEN.  2024-01-01

      *================================================================
      * ENVIRONMENT DIVISION - NAO NECESSARIA EM CICS COBOL
      *================================================================
       ENVIRONMENT DIVISION.

      *================================================================
      * DATA DIVISION
      *================================================================
       DATA DIVISION.

      *----------------------------------------------------------------
      * FILE SECTION - NAO UTILIZADA EM CICS (FCT GERENCIA ARQUIVOS)
      *----------------------------------------------------------------
       FILE SECTION.

      *----------------------------------------------------------------
      * WORKING-STORAGE SECTION
      *----------------------------------------------------------------
       WORKING-STORAGE SECTION.

      *--- LITERAL DE INICIO PARA FACILITAR DUMP/DEBUG ----------------
        01  WSBK-BEGINS              PIC X(16)
                                     VALUE 'BKC01 WS BEGINS'.

      *--- CONSTANTES -------------------------------------------------
        01  WSBK-CONSTANTS.
            12  WSBK-PROGRAM-ID      PIC X(8)        VALUE 'BKC01   '.
            12  WSBK-MAPSET          PIC X(8)        VALUE 'BKCONS0 '.
            12  WSBK-MAP01           PIC X(8)        VALUE 'BKCON01 '.
            12  WSBK-TRANSID         PIC X(4)        VALUE 'BKQ1'.
            12  WSBK-MENU-PROGRAM    PIC X(8)        VALUE 'BKMEN01 '.

      *--- CAMPOS DE CHAVE --------------------------------------------
        01  WSBK-KEYS.
            12  WSBK-COD-AGENCIA     PIC X(4)        VALUE SPACES.
            12  WSBK-NUM-CONTA       PIC X(10)       VALUE SPACES.

      *--- SWITCHES / FLAGS -------------------------------------------
        01  WSBK-SWITCHES.
            12  WSBK-FIRST-TIME-SW   PIC X           VALUE 'Y'.
                88  WSBK-FIRST-TIME              VALUE 'Y'.
                88  WSBK-NOT-FIRST-TIME          VALUE 'N'.
            12  WSBK-EDIT-ERROR-SW   PIC X           VALUE 'N'.
                88  WSBK-EDIT-ERROR              VALUE 'Y'.
                88  WSBK-NO-EDIT-ERROR           VALUE 'N'.
            12  WSBK-FOUND-SW        PIC X           VALUE 'N'.
                88  WSBK-FOUND                   VALUE 'Y'.
                88  WSBK-NOT-FOUND               VALUE 'N'.

      *--- CAMPO PARA POSICAO DO CURSOR -------------------------------
        01  WSBK-CURSOR-ON           PIC S9(4)       VALUE -1    COMP.

      *--- CONTADORES -------------------------------------------------
        01  WSBK-COUNTERS.
            12  WSBK-EXTRATO-CTR     PIC S9(4)       COMP
                                     VALUE ZERO.

      *--- AREA DE DATA ATUAL -----------------------------------------
        01  WSBK-DATE-AREA.
            12  WSBK-ABSTIME         PIC S9(15)      COMP-3.
            12  WSBK-DATE-DISPLAY    PIC X(10)       VALUE SPACES.

      *--- AREAS DE MENSAGEM ------------------------------------------
        01  WSBK-MESSAGES.
            12  WSBK-MSG-NORMAL      PIC X(36)       VALUE SPACES.
            12  WSBK-MSG-ERROR       PIC X(36)       VALUE SPACES.

      *--- AREA DA RESPONSE CICS --------------------------------------
        01  WSBK-CICS-RESP           PIC S9(8)       COMP.
            88  WSBK-CICS-NORMAL             VALUE 0.
            88  WSBK-CICS-NOTFND             VALUE 13.
            88  WSBK-CICS-ENDFILE            VALUE 11.

      *--- AREA ABEND -------------------------------------------------
        01  WSBK-ABEND-CODE          PIC X(4)        VALUE 'BK01'.

      *--- AREA PARA FORMATACAO DO EXTRATO ----------------------------
        01  WSBK-EXTRATO-LINES.
            12  WSBK-EXT-ENTRY
                OCCURS 5 TIMES
                INDEXED BY WSBK-EXT-IDX.
                16  WSBK-EXT-DATA   PIC X(10)        VALUE SPACES.
                16  WSBK-EXT-HIST   PIC X(20)        VALUE SPACES.
                16  WSBK-EXT-TIPO   PIC X(6)         VALUE SPACES.
                16  WSBK-EXT-VALOR  PIC S9(11)V99    COMP-3
                                    VALUE ZERO.
                16  WSBK-EXT-SALDO  PIC S9(13)V99    COMP-3
                                    VALUE ZERO.

      *--- SQL INCLUDE - DCLGEN DAS TABELAS --------------------------
           EXEC SQL
               INCLUDE BKAGCD
           END-EXEC.

           EXEC SQL
               INCLUDE BKCTCD
           END-EXEC.

           EXEC SQL
               INCLUDE BKEXCD
           END-EXEC.

      *--- AREA DE SQLCA ----------------------------------------------
           EXEC SQL
               INCLUDE SQLCA
           END-EXEC.

      *--- COPY BMS DSECT - MAPA 01 -----------------------------------
           COPY BKCON01.

      *--- COPY DFHBMSCA - ATRIBUTOS BMS PADROES ----------------------
           COPY DFHBMSCA.

      *--- COPY DFHAID - IDENTIFICADORES DE ATENCAO ------------------
           COPY DFHAID.

      *================================================================
      * LINKAGE SECTION
      *================================================================
       LINKAGE SECTION.

        01  DFHCOMMAREA              PIC X(900).

      *================================================================
      * PROCEDURE DIVISION
      *================================================================
       PROCEDURE DIVISION.

      *================================================================
      * MAINLINE ROUTINE                                               *
      *================================================================
       000-MAINLINE.

           PERFORM 100-INITIALIZE
               THRU 100-EXIT

           EVALUATE TRUE
               WHEN WSBK-FIRST-TIME
                   PERFORM 200-INITIAL-DISPLAY
                       THRU 200-EXIT

               WHEN EIBAID = DFHPF3
                   PERFORM 700-EXIT-PROGRAM
                       THRU 700-EXIT

               WHEN EIBAID = DFHPF7
                   PERFORM 300-CLEAR-SCREEN
                       THRU 300-EXIT

               WHEN EIBAID = DFHENTER
                   PERFORM 400-PROCESS-INQUIRY
                       THRU 400-EXIT

               WHEN OTHER
                   MOVE 'TECLA INVALIDA - USE ENTER/PF3/PF7'
                       TO WSBK-MSG-ERROR
                   PERFORM 600-SEND-MAP
                       THRU 600-EXIT
           END-EVALUATE

           EXEC CICS RETURN
               TRANSID  (WSBK-TRANSID)
               COMMAREA (DFHCOMMAREA)
               LENGTH   (900)
               RESP     (WSBK-CICS-RESP)
           END-EXEC

           STOP RUN.

       000-EXIT.
           EXIT.

      *================================================================
      * PROCESSING ROUTINES                                            *
      *================================================================

      *----------------------------------------------------------------
      * 100-INITIALIZE: INICIALIZA O PROGRAMA                         *
      *----------------------------------------------------------------
       100-INITIALIZE.

           IF EIBCALEN = ZERO
               SET WSBK-FIRST-TIME            TO TRUE
           ELSE
               SET WSBK-NOT-FIRST-TIME        TO TRUE
           END-IF

           SET WSBK-NO-EDIT-ERROR             TO TRUE
           SET WSBK-NOT-FOUND                 TO TRUE

           MOVE SPACES                        TO WSBK-MSG-NORMAL
           MOVE SPACES                        TO WSBK-MSG-ERROR

           PERFORM 910-GET-CURRENT-DATE
               THRU 910-EXIT.

       100-EXIT.
           EXIT.

      *----------------------------------------------------------------
      * 200-INITIAL-DISPLAY: EXIBE TELA INICIAL EM BRANCO             *
      *----------------------------------------------------------------
       200-INITIAL-DISPLAY.

           MOVE SPACES                        TO BKCON01I
           MOVE WSBK-DATE-DISPLAY             TO M01DATEO
           MOVE 'BKC01'                       TO M01PROGO
           MOVE 'INFORME AGENCIA E CONTA'     TO M01MSGRO

           MOVE WSBK-CURSOR-ON                TO M01AGENL

           EXEC CICS SEND
               MAP     (WSBK-MAP01)
               MAPSET  (WSBK-MAPSET)
               FROM    (BKCON01O)
               ERASE
               FREEKB
               CURSOR
               RESP    (WSBK-CICS-RESP)
           END-EXEC

           IF NOT WSBK-CICS-NORMAL
               PERFORM 890-CICS-ERROR
                   THRU 890-EXIT
           END-IF.

       200-EXIT.
           EXIT.

      *----------------------------------------------------------------
      * 300-CLEAR-SCREEN: LIMPA CAMPOS DA TELA (PF7)                  *
      *----------------------------------------------------------------
       300-CLEAR-SCREEN.

           MOVE SPACES                        TO BKCON01I
           MOVE SPACES                        TO BKCON01O
           MOVE WSBK-DATE-DISPLAY             TO M01DATEO
           MOVE 'BKC01'                       TO M01PROGO
           MOVE 'TELA LIMPA - INFORME OS DADOS' TO M01MSGRO

           MOVE WSBK-CURSOR-ON                TO M01AGENL

           EXEC CICS SEND
               MAP     (WSBK-MAP01)
               MAPSET  (WSBK-MAPSET)
               FROM    (BKCON01O)
               ERASE
               FREEKB
               CURSOR
               RESP    (WSBK-CICS-RESP)
           END-EXEC

           IF NOT WSBK-CICS-NORMAL
               PERFORM 890-CICS-ERROR
                   THRU 890-EXIT
           END-IF.

       300-EXIT.
           EXIT.

      *----------------------------------------------------------------
      * 400-PROCESS-INQUIRY: PROCESSA CONSULTA ENTER                  *
      *----------------------------------------------------------------
       400-PROCESS-INQUIRY.

           PERFORM 410-RECEIVE-MAP
               THRU 410-EXIT

           IF WSBK-NO-EDIT-ERROR
               PERFORM 420-EDIT-FIELDS
                   THRU 420-EXIT
           END-IF

           IF WSBK-NO-EDIT-ERROR
               PERFORM 500-DB2-QUERY
                   THRU 500-EXIT
           END-IF

           PERFORM 600-SEND-MAP
               THRU 600-EXIT.

       400-EXIT.
           EXIT.

      *----------------------------------------------------------------
      * 410-RECEIVE-MAP: RECEBE ENTRADA DA TELA                       *
      *----------------------------------------------------------------
       410-RECEIVE-MAP.

           EXEC CICS RECEIVE
               MAP     (WSBK-MAP01)
               MAPSET  (WSBK-MAPSET)
               INTO    (BKCON01I)
               RESP    (WSBK-CICS-RESP)
           END-EXEC

           IF NOT WSBK-CICS-NORMAL
               PERFORM 890-CICS-ERROR
                   THRU 890-EXIT
           END-IF

           MOVE M01AGENI                      TO WSBK-COD-AGENCIA
           MOVE M01CONTI                      TO WSBK-NUM-CONTA.

       410-EXIT.
           EXIT.

      *----------------------------------------------------------------
      * 420-EDIT-FIELDS: VALIDA CAMPOS DE ENTRADA                     *
      *----------------------------------------------------------------
       420-EDIT-FIELDS.

      *--- EDITAR AGENCIA ---------------------------------------------
           IF M01AGENL = +0
               MOVE WSBK-CURSOR-ON            TO M01AGENL
               MOVE 'Y'                       TO WSBK-EDIT-ERROR-SW
               MOVE DFHBMFSB                  TO M01AGENA
           ELSE
               IF M01AGENI = SPACES
                   MOVE WSBK-CURSOR-ON        TO M01AGENL
                   MOVE 'Y'                   TO WSBK-EDIT-ERROR-SW
                   MOVE DFHBMFSB              TO M01AGENA
               ELSE
                   MOVE DFHBMASF              TO M01AGENA
               END-IF
           END-IF

      *--- EDITAR CONTA -----------------------------------------------
           IF M01CONTL = +0
               IF WSBK-NO-EDIT-ERROR
                   MOVE WSBK-CURSOR-ON        TO M01CONTL
               END-IF
               MOVE 'Y'                       TO WSBK-EDIT-ERROR-SW
               MOVE DFHBMFSB                  TO M01CONTA
           ELSE
               IF M01CONTI = SPACES
                   IF WSBK-NO-EDIT-ERROR
                       MOVE WSBK-CURSOR-ON    TO M01CONTL
                   END-IF
                   MOVE 'Y'                   TO WSBK-EDIT-ERROR-SW
                   MOVE DFHBMFSB              TO M01CONTA
               ELSE
                   MOVE DFHBMASF              TO M01CONTA
               END-IF
           END-IF

      *--- VERIFICAR SE HOUVE ERRO ------------------------------------
           IF WSBK-EDIT-ERROR
               MOVE 'EDIT ERROR DETECTED'     TO WSBK-MSG-ERROR
           END-IF.

       420-EXIT.
           EXIT.

      *----------------------------------------------------------------
      * 500-DB2-QUERY: CONSULTA DADOS NO DB2                          *
      *----------------------------------------------------------------
       500-DB2-QUERY.

           PERFORM 510-READ-AGENCIA
               THRU 510-EXIT

           IF WSBK-FOUND
               PERFORM 520-READ-CONTA
                   THRU 520-EXIT
           END-IF

           IF WSBK-FOUND
               PERFORM 530-READ-EXTRATO
                   THRU 530-EXIT
           END-IF

           IF WSBK-FOUND
               PERFORM 540-POPULATE-MAP
                   THRU 540-EXIT
               MOVE 'CONSULTA REALIZADA COM SUCESSO' TO WSBK-MSG-NORMAL
           END-IF.

       500-EXIT.
           EXIT.

      *----------------------------------------------------------------
      * 510-READ-AGENCIA: LE CADASTRO DA AGENCIA                      *
      *----------------------------------------------------------------
       510-READ-AGENCIA.

           MOVE WSBK-COD-AGENCIA              TO AG-COD-AGENCIA

           EXEC SQL
               SELECT AG_COD_AGENCIA,
                      AG_NOM_AGENCIA,
                      AG_NOM_CIDADE,
                      AG_NOM_ESTADO
               INTO   :AG-COD-AGENCIA,
                      :AG-NOM-AGENCIA,
                      :AG-NOM-CIDADE,
                      :AG-NOM-ESTADO
               FROM   BANCO.AGENCIA
               WHERE  AG_COD_AGENCIA = :AG-COD-AGENCIA
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   SET WSBK-FOUND             TO TRUE
               WHEN 100
                   SET WSBK-NOT-FOUND         TO TRUE
                   MOVE 'AGENCIA NAO ENCONTRADA'
                       TO WSBK-MSG-ERROR
                   MOVE WSBK-CURSOR-ON        TO M01AGENL
                   MOVE DFHBMFSB              TO M01AGENA
               WHEN OTHER
                   PERFORM 880-DB2-ERROR
                       THRU 880-EXIT
           END-EVALUATE.

       510-EXIT.
           EXIT.

      *----------------------------------------------------------------
      * 520-READ-CONTA: LE CADASTRO DA CONTA                          *
      *----------------------------------------------------------------
       520-READ-CONTA.

           MOVE WSBK-COD-AGENCIA              TO CT-COD-AGENCIA
           MOVE WSBK-NUM-CONTA                TO CT-NUM-CONTA

           EXEC SQL
               SELECT CT_COD_AGENCIA,
                      CT_NUM_CONTA,
                      CT_NOM_CLIENTE,
                      CT_COD_TIPO_CONTA,
                      CT_DES_TIPO_CONTA,
                      CT_VLR_SALDO,
                      CT_COD_STATUS
               INTO   :CT-COD-AGENCIA,
                      :CT-NUM-CONTA,
                      :CT-NOM-CLIENTE,
                      :CT-COD-TIPO-CONTA,
                      :CT-DES-TIPO-CONTA,
                      :CT-VLR-SALDO,
                      :CT-COD-STATUS
               FROM   BANCO.CONTA
               WHERE  CT_COD_AGENCIA = :CT-COD-AGENCIA
               AND    CT_NUM_CONTA   = :CT-NUM-CONTA
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   SET WSBK-FOUND             TO TRUE
               WHEN 100
                   SET WSBK-NOT-FOUND         TO TRUE
                   MOVE 'CONTA NAO ENCONTRADA' TO WSBK-MSG-ERROR
                   MOVE WSBK-CURSOR-ON        TO M01CONTL
                   MOVE DFHBMFSB              TO M01CONTA
               WHEN OTHER
                   PERFORM 880-DB2-ERROR
                       THRU 880-EXIT
           END-EVALUATE.

       520-EXIT.
           EXIT.

      *----------------------------------------------------------------
      * 530-READ-EXTRATO: LE OS ULTIMOS 5 MOVIMENTOS                  *
      *----------------------------------------------------------------
       530-READ-EXTRATO.

           MOVE WSBK-COD-AGENCIA              TO EX-COD-AGENCIA
           MOVE WSBK-NUM-CONTA                TO EX-NUM-CONTA
           MOVE 0                             TO WSBK-EXTRATO-CTR

           PERFORM VARYING WSBK-EXT-IDX FROM 1 BY 1
               UNTIL WSBK-EXT-IDX > 5
               MOVE SPACES
                   TO WSBK-EXT-DATA (WSBK-EXT-IDX)
               MOVE SPACES
                   TO WSBK-EXT-HIST (WSBK-EXT-IDX)
               MOVE SPACES
                   TO WSBK-EXT-TIPO (WSBK-EXT-IDX)
               MOVE ZEROS
                   TO WSBK-EXT-VALOR(WSBK-EXT-IDX)
               MOVE ZEROS
                   TO WSBK-EXT-SALDO(WSBK-EXT-IDX)
           END-PERFORM

           EXEC SQL
               DECLARE CSREXTRATO CURSOR FOR
               SELECT EX_DAT_MOVIMENTO,
                      EX_COD_TIPO_MOV,
                      EX_DES_HISTORICO,
                      EX_VLR_MOVIMENTO,
                      EX_VLR_SALDO_APOS
               FROM   BANCO.EXTRATO_MOV
               WHERE  EX_COD_AGENCIA = :EX-COD-AGENCIA
               AND    EX_NUM_CONTA   = :EX-NUM-CONTA
               AND    EX_DAT_MOVIMENTO >= CURRENT DATE - 5 DAYS
               ORDER  BY EX_DAT_MOVIMENTO DESC,
                         EX_NUM_SEQ      DESC
               FETCH  FIRST 5 ROWS ONLY
           END-EXEC

           EXEC SQL
               OPEN CSREXTRATO
           END-EXEC

           IF SQLCODE NOT = 0
               PERFORM 880-DB2-ERROR
                   THRU 880-EXIT
               GO TO 530-EXIT
           END-IF

           PERFORM UNTIL SQLCODE NOT = 0
               OR WSBK-EXTRATO-CTR = 5

               EXEC SQL
                   FETCH CSREXTRATO
                   INTO  :EX-DAT-MOVIMENTO,
                         :EX-COD-TIPO-MOV,
                         :EX-DES-HISTORICO,
                         :EX-VLR-MOVIMENTO,
                         :EX-VLR-SALDO-APOS
               END-EXEC

               IF SQLCODE = 0
                   ADD 1 TO WSBK-EXTRATO-CTR
                   SET WSBK-EXT-IDX
                       TO WSBK-EXTRATO-CTR
                   MOVE EX-DAT-MOVIMENTO
                       TO WSBK-EXT-DATA (WSBK-EXT-IDX)
                   MOVE EX-DES-HIST-TEXT
                       TO WSBK-EXT-HIST (WSBK-EXT-IDX)
                   MOVE EX-COD-TIPO-MOV
                       TO WSBK-EXT-TIPO (WSBK-EXT-IDX)
                   MOVE EX-VLR-MOVIMENTO
                       TO WSBK-EXT-VALOR(WSBK-EXT-IDX)
                   MOVE EX-VLR-SALDO-APOS
                       TO WSBK-EXT-SALDO(WSBK-EXT-IDX)
               END-IF

           END-PERFORM

           EXEC SQL
               CLOSE CSREXTRATO
           END-EXEC.

       530-EXIT.
           EXIT.

      *----------------------------------------------------------------
      * 540-POPULATE-MAP: POPULA OS CAMPOS DO MAPA                    *
      *----------------------------------------------------------------
       540-POPULATE-MAP.

      *--- DADOS FIXOS DA CONTA ---------------------------------------
           MOVE CT-NOM-CLIENTE-TEXT           TO M01NOMEO
           MOVE CT-DES-TIPO-TEXT              TO M01TIPOO
           MOVE CT-VLR-SALDO                  TO M01SALDO

      *--- LINHA 1 DO EXTRATO -----------------------------------------
           IF WSBK-EXTRATO-CTR >= 1
               MOVE WSBK-EXT-DATA (1)         TO M01DT1O
               MOVE WSBK-EXT-HIST (1)         TO M01HI1O
               MOVE WSBK-EXT-TIPO (1)         TO M01TP1O
               MOVE WSBK-EXT-VALOR(1)         TO M01VL1O
               MOVE WSBK-EXT-SALDO(1)         TO M01SL1O
           END-IF

      *--- LINHA 2 DO EXTRATO -----------------------------------------
           IF WSBK-EXTRATO-CTR >= 2
               MOVE WSBK-EXT-DATA (2)         TO M01DT2O
               MOVE WSBK-EXT-HIST (2)         TO M01HI2O
               MOVE WSBK-EXT-TIPO (2)         TO M01TP2O
               MOVE WSBK-EXT-VALOR(2)         TO M01VL2O
               MOVE WSBK-EXT-SALDO(2)         TO M01SL2O
           END-IF

      *--- LINHA 3 DO EXTRATO -----------------------------------------
           IF WSBK-EXTRATO-CTR >= 3
               MOVE WSBK-EXT-DATA (3)         TO M01DT3O
               MOVE WSBK-EXT-HIST (3)         TO M01HI3O
               MOVE WSBK-EXT-TIPO (3)         TO M01TP3O
               MOVE WSBK-EXT-VALOR(3)         TO M01VL3O
               MOVE WSBK-EXT-SALDO(3)         TO M01SL3O
           END-IF

      *--- LINHA 4 DO EXTRATO -----------------------------------------
           IF WSBK-EXTRATO-CTR >= 4
               MOVE WSBK-EXT-DATA (4)         TO M01DT4O
               MOVE WSBK-EXT-HIST (4)         TO M01HI4O
               MOVE WSBK-EXT-TIPO (4)         TO M01TP4O
               MOVE WSBK-EXT-VALOR(4)         TO M01VL4O
               MOVE WSBK-EXT-SALDO(4)         TO M01SL4O
           END-IF

      *--- LINHA 5 DO EXTRATO -----------------------------------------
           IF WSBK-EXTRATO-CTR >= 5
               MOVE WSBK-EXT-DATA (5)         TO M01DT5O
               MOVE WSBK-EXT-HIST (5)         TO M01HI5O
               MOVE WSBK-EXT-TIPO (5)         TO M01TP5O
               MOVE WSBK-EXT-VALOR(5)         TO M01VL5O
               MOVE WSBK-EXT-SALDO(5)         TO M01SL5O
           END-IF.

       540-EXIT.
           EXIT.

      *----------------------------------------------------------------
      * 600-SEND-MAP: ENVIA MAPA PARA O TERMINAL                      *
      *----------------------------------------------------------------
       600-SEND-MAP.

           MOVE WSBK-DATE-DISPLAY             TO M01DATEO
           MOVE 'BKC01'                       TO M01PROGO
           MOVE WSBK-MSG-ERROR                TO M01MSGLO
           MOVE WSBK-MSG-NORMAL               TO M01MSGRO

           EXEC CICS SEND
               MAP     (WSBK-MAP01)
               MAPSET  (WSBK-MAPSET)
               FROM    (BKCON01O)
               FREEKB
               CURSOR
               RESP    (WSBK-CICS-RESP)
           END-EXEC

           IF NOT WSBK-CICS-NORMAL
               PERFORM 890-CICS-ERROR
                   THRU 890-EXIT
           END-IF.

       600-EXIT.
           EXIT.

      *----------------------------------------------------------------
      * 700-EXIT-PROGRAM: RETORNA AO MENU (PF3)                       *
      *----------------------------------------------------------------
       700-EXIT-PROGRAM.

           EXEC CICS XCTL
               PROGRAM  (WSBK-MENU-PROGRAM)
               COMMAREA (DFHCOMMAREA)
               RESP     (WSBK-CICS-RESP)
           END-EXEC

           IF NOT WSBK-CICS-NORMAL
               PERFORM 890-CICS-ERROR
                   THRU 890-EXIT
           END-IF.

       700-EXIT.
           EXIT.

      *================================================================
      * INPUT-OUTPUT ROUTINES                                          *
      *================================================================

      *----------------------------------------------------------------
      * 880-DB2-ERROR: TRATA ERROS DE DB2                             *
      *----------------------------------------------------------------
       880-DB2-ERROR.

           MOVE 'ERRO DB2 - CONTATE O SUPORTE'
               TO WSBK-MSG-ERROR
           SET  WSBK-NOT-FOUND                TO TRUE

           EXEC CICS DUMP
               TASK
               DUMPCODE ('BKD2')
               RESP     (WSBK-CICS-RESP)
           END-EXEC.

       880-EXIT.
           EXIT.

      *----------------------------------------------------------------
      * 890-CICS-ERROR: TRATA ERROS DE CICS                           *
      *----------------------------------------------------------------
       890-CICS-ERROR.

           EXEC CICS ABEND
               ABCODE  (WSBK-ABEND-CODE)
           END-EXEC.

       890-EXIT.
           EXIT.

      *----------------------------------------------------------------
      * 910-GET-CURRENT-DATE: OBTEM DATA ATUAL VIA CICS               *
      *----------------------------------------------------------------
       910-GET-CURRENT-DATE.

           EXEC CICS ASKTIME
               ABSTIME (WSBK-ABSTIME)
               RESP    (WSBK-CICS-RESP)
           END-EXEC

           IF NOT WSBK-CICS-NORMAL
               MOVE SPACES                    TO WSBK-DATE-DISPLAY
               GO TO 910-EXIT
           END-IF

           EXEC CICS FORMATTIME
               ABSTIME   (WSBK-ABSTIME)
               DDMMYYYY  (WSBK-DATE-DISPLAY)
               DATESEP   ('/')
               RESP      (WSBK-CICS-RESP)
           END-EXEC

           IF NOT WSBK-CICS-NORMAL
               MOVE SPACES                    TO WSBK-DATE-DISPLAY
           END-IF.

       910-EXIT.
           EXIT.

       END PROGRAM BKC01.
