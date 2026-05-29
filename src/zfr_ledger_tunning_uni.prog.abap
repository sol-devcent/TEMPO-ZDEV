************************************************************************
*                  REPORT                                              *
*----------------------------------------------------------------------*
* ABAP Name   : ZFR_LEDGER                                             *
* Created by  : Didik Imawan                                           *
* Created on  : 12/05/2003                                             *
*----------------------------------------------------------------------*
* Description :                                                        *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
* Date    Programmer  Correction  Description                   *
*                                                                      *
************************************************************************
REPORT zfr_ledger MESSAGE-ID zf
                  LINE-SIZE  400
                  LINE-COUNT 60
                  NO STANDARD PAGE HEADING.

INCLUDE zfr_ledger_tunning_top.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS :
             pa_bukrs LIKE bsid-bukrs OBLIGATORY.
SELECT-OPTIONS :
             so_hkont  FOR bsid-hkont,
             so_gsber  FOR bsis-gsber MODIF ID gsb,
             so_budat  FOR bkpf-budat OBLIGATORY DEFAULT sy-datum.
SELECT-OPTIONS : so_monat FOR bkpf-monat OBLIGATORY MODIF ID mon
                                         DEFAULT sy-datum+4(2).
SELECTION-SCREEN SKIP 1.
PARAMETERS : pa_text(30).
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : loccurr RADIOBUTTON GROUP grp1
             USER-COMMAND rad DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(22) TEXT-013 FOR FIELD loccurr.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : doccurr RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(22) TEXT-014 FOR FIELD doccurr.
SELECTION-SCREEN POSITION 28.
SELECT-OPTIONS : so_waers FOR bsis-waers NO INTERVALS MODIF ID yyy.
SELECTION-SCREEN END OF LINE.SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio10 RADIOBUTTON GROUP grp3
            USER-COMMAND kid DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 4(24) TEXT-003 FOR FIELD radio10.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio11 RADIOBUTTON GROUP grp3.
SELECTION-SCREEN : COMMENT 4(24) TEXT-004 FOR FIELD radio11.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio12 RADIOBUTTON GROUP grp3.
SELECTION-SCREEN : COMMENT 4(24) TEXT-005 FOR FIELD radio12.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF BLOCK block5 WITH FRAME TITLE TEXT-015.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : cb_vbund AS CHECKBOX.
SELECTION-SCREEN : COMMENT 4(15) TEXT-900 FOR FIELD cb_vbund.
SELECTION-SCREEN POSITION 22.
PARAMETERS : cb_zuonr AS CHECKBOX.
SELECTION-SCREEN : COMMENT 24(15) TEXT-901 FOR FIELD cb_zuonr.
SELECTION-SCREEN POSITION 42.
PARAMETERS : cb_sgtxt AS CHECKBOX.
SELECTION-SCREEN : COMMENT 44(15) TEXT-902 FOR FIELD cb_sgtxt.
SELECTION-SCREEN POSITION 62.
PARAMETERS : cb_statu AS CHECKBOX.
SELECTION-SCREEN : COMMENT 64(15) TEXT-911 FOR FIELD cb_statu.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : cb_xref3 AS CHECKBOX.
SELECTION-SCREEN : COMMENT 4(15) TEXT-903 FOR FIELD cb_xref3.
SELECTION-SCREEN POSITION 22.
PARAMETERS : cb_bktxt AS CHECKBOX.
SELECTION-SCREEN : COMMENT 24(15) TEXT-904 FOR FIELD cb_bktxt.
SELECTION-SCREEN POSITION 42.
PARAMETERS : cb_kostl AS CHECKBOX.
SELECTION-SCREEN : COMMENT 44(15) TEXT-905 FOR FIELD cb_kostl.
SELECTION-SCREEN POSITION 62.
PARAMETERS : cb_augdt AS CHECKBOX.
SELECTION-SCREEN : COMMENT 64(15) TEXT-912 FOR FIELD cb_augdt.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : cb_aufnr AS CHECKBOX.
SELECTION-SCREEN : COMMENT 4(15) TEXT-906 FOR FIELD cb_aufnr.
SELECTION-SCREEN POSITION 22.
PARAMETERS : cb_prctr AS CHECKBOX.
SELECTION-SCREEN : COMMENT 24(15) TEXT-907 FOR FIELD cb_prctr.
SELECTION-SCREEN POSITION 42.
PARAMETERS : cb_bldat AS CHECKBOX.
SELECTION-SCREEN : COMMENT 44(15) TEXT-910 FOR FIELD cb_bldat.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : cb_rstgr AS CHECKBOX.
SELECTION-SCREEN : COMMENT 4(15) TEXT-908 FOR FIELD cb_rstgr.
SELECTION-SCREEN POSITION 22.
PARAMETERS : cb_fipex AS CHECKBOX.
SELECTION-SCREEN : COMMENT 24(15) TEXT-909 FOR FIELD cb_fipex.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block5.

SELECTION-SCREEN BEGIN OF BLOCK block3 WITH FRAME TITLE TEXT-006.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio1 RADIOBUTTON GROUP grp2
             USER-COMMAND dik DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(26) TEXT-008 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio2 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(26) TEXT-010 FOR FIELD radio2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio3 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(26) TEXT-007 FOR FIELD radio3.
SELECTION-SCREEN POSITION 30.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio4 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(26) TEXT-009 FOR FIELD radio4.
SELECTION-SCREEN POSITION 30.
SELECT-OPTIONS : so_vbund FOR bsid-vbund MODIF ID vbu.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio5 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(26) TEXT-011 FOR FIELD radio5.
SELECTION-SCREEN POSITION 30.
SELECT-OPTIONS : so_kostl FOR bsid-kostl MODIF ID kos.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio6 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(26) TEXT-012 FOR FIELD radio6.
SELECTION-SCREEN POSITION 30.
SELECT-OPTIONS : so_prctr FOR cepc-prctr MODIF ID prc.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block3.

SELECTION-SCREEN BEGIN OF BLOCK block4 WITH FRAME TITLE TEXT-999.
PARAMETERS : radio92 RADIOBUTTON GROUP grp9
             USER-COMMAND dik DEFAULT 'X'.
PARAMETERS : radio90 RADIOBUTTON GROUP grp9.
PARAMETERS : radio91 RADIOBUTTON GROUP grp9.
SELECTION-SCREEN SKIP 1.
*    PARAMETERS: P_FILENM(52) LOWER CASE MODIF ID 001.
PARAMETERS: p_filenm LIKE rlgrap-filename LOWER CASE MODIF ID 001.
SELECTION-SCREEN END OF BLOCK block4.

************************************************************************
*   AT SELECTION-SCREEN OUTPUT
************************************************************************
AT SELECTION-SCREEN OUTPUT.
  IF radio4 = 'X'.
    LOOP AT SCREEN.
      IF ( screen-group1 = 'KOS' OR
           screen-group1 = 'PRC' ).
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    CLEAR so_kostl. REFRESH so_kostl.
    CLEAR so_prctr. REFRESH so_prctr.
  ELSEIF radio3 = 'X'.
    LOOP AT SCREEN.
      IF ( screen-group1 = 'VBU' OR screen-group1 = 'KOS' OR
           screen-group1 = 'PRC' ).
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    CLEAR so_vbund. REFRESH so_vbund.
    CLEAR so_kostl. REFRESH so_kostl.
    CLEAR so_prctr. REFRESH so_prctr.
  ELSEIF radio1 = 'X'.
    LOOP AT SCREEN.
      IF ( screen-group1 = 'VBU' OR screen-group1 = 'KOS' OR
           screen-group1 = 'PRC' ).
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    CLEAR so_vbund. REFRESH so_vbund.
    CLEAR so_kostl. REFRESH so_kostl.
    CLEAR so_prctr. REFRESH so_prctr.
  ELSEIF radio2 = 'X'.
    LOOP AT SCREEN.
      IF ( screen-group1 = 'VBU' OR screen-group1 = 'KOS' OR
           screen-group1 = 'PRC' ).
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    CLEAR so_vbund. REFRESH so_vbund.
    CLEAR so_kostl. REFRESH so_kostl.
    CLEAR so_prctr. REFRESH so_prctr.
  ELSEIF radio5 = 'X'.
    LOOP AT SCREEN.
      IF ( screen-group1 = 'VBU' OR screen-group1 = 'PRC' ).
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    CLEAR so_vbund. REFRESH so_vbund.
    CLEAR so_prctr. REFRESH so_prctr.
  ELSEIF radio6 = 'X'.
    LOOP AT SCREEN.
      IF ( screen-group1 = 'VBU' OR screen-group1 = 'KOS' ).
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    CLEAR so_vbund. REFRESH so_vbund.
    CLEAR so_kostl. REFRESH so_kostl.
  ENDIF.

  IF radio92 = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = '001'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

************************************************************************
*   AT SELECTION-SCREEN
************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_filenm.
  PERFORM f_get_filename.

AT SELECTION-SCREEN ON so_gsber.
  IF pa_bukrs EQ '8010'.
    IF so_gsber-low+0(2) NE '01' AND so_gsber-low NE space.
      MESSAGE e000(zf) WITH 'Business Area must be entry 01xx'.
    ENDIF.
    IF so_gsber-high+0(2) NE '01' AND so_gsber-high NE space.
      MESSAGE e000(zf) WITH 'Business Area must be entry 01xx'.
    ENDIF.
  ELSEIF pa_bukrs EQ '8020'.
    IF so_gsber-low+0(2) NE '02' AND so_gsber-low NE space AND
          so_gsber-low(1) NE 'T'.
      MESSAGE e000(zf) WITH 'Business Area must be entry 02xx'.
    ENDIF.
    IF so_gsber-high+0(2) NE '02' AND so_gsber-high NE space AND
          so_gsber-high(1) NE 'T'.
      MESSAGE e000(zf) WITH 'Business Area must be entry 02xx'.
    ENDIF.
  ELSEIF pa_bukrs EQ '8030'.
    IF so_gsber-low+0(2) NE '03' AND so_gsber-low NE space.
      MESSAGE e000(zf) WITH 'Business Area must be entry 03xx'.
    ENDIF.
    IF so_gsber-high+0(2) NE '03' AND so_gsber-high NE space.
      MESSAGE e000(zf) WITH 'Business Area must be entry 03xx'.
    ELSE.
      SELECT SINGLE gsber FROM tgsb INTO va_gsber
      WHERE gsber IN so_gsber.
      IF sy-subrc NE 0.
        MESSAGE e000(zf) WITH 'Business Area not found'.
      ENDIF.
    ENDIF.
  ENDIF.

*  AT SELECTION-SCREEN ON p_filenm.
*   If radio90 = 'X'.
*      open dataset p_filenm for input in text mode.
*      if sy-subrc = 0.
*        Message e000(zf) with 'File Sudah Ada'.
*      endif.
*   else.
*   endif.

*&---------------------------------------------------------------------*
*&        AT LINE-SELECTION
*&---------------------------------------------------------------------*
AT LINE-SELECTION.
  READ CURRENT LINE FIELD VALUE: va_gtext, va_belnr, va_name1,
                                 va_ltext, wa_budat-budat,
                                 wa_prctr-prctr, va_hkont.

  DATA : ffield(20), fvalue(50).
  GET CURSOR FIELD ffield VALUE fvalue.
  CASE ffield.
    WHEN 'WA_BUDAT-BUDAT'.
      CONCATENATE fvalue+6(4) fvalue+3(2) fvalue(2) INTO va_budat.
      PERFORM cetak_radio2_detail.

    WHEN 'VA_GTEXT'.
      IF radio3 EQ 'X'.
        SELECT SINGLE *
          FROM tgsbt
          WHERE gtext EQ va_gtext.
        zebra1 = 0.
        PERFORM cetak_radio3_detail.
      ENDIF.

    WHEN 'VA_NAME1'.
      SELECT SINGLE *
        FROM t880
        WHERE name1 EQ va_name1.
      zebra1 = 0.
      PERFORM cetak_radio4_detail.

    WHEN 'VA_LTEXT'.
      IF radio5 EQ 'X'.
        SELECT SINGLE *
          FROM cskt
          WHERE ltext EQ va_ltext.
        zebra1 = 0.
        PERFORM cetak_radio5_detail.
      ENDIF.

      IF radio6 EQ 'X'.
        zebra1 = 0.
        PERFORM cetak_radio6_detail.
      ENDIF.

    WHEN 'VA_BELNR'.
      SET PARAMETER ID 'BLN' FIELD va_belnr.
      SET PARAMETER ID 'BUK' FIELD pa_bukrs.
      SET PARAMETER ID 'GJR' FIELD va_gjahr.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ENDCASE.

*&---------------------------------------------------------------------*
*&      INITIALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  DATA lv_parva(40).

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'BUK'.

  IF sy-subrc EQ 0.
    pa_bukrs  = lv_parva.
  ENDIF.

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'GSB'.

  IF sy-subrc EQ 0.
    so_gsber-low  = lv_parva.
    APPEND so_gsber.
  ENDIF.

*  If sy-opsys = 'AIX'.
*    P_FILENM = '/interface/LEDGER/'.
*  Else.
*    P_FILENM = '\\tdsdev01\interface\LEDGER\'.
*  Endif.

*&---------------------------------------------------------------------*
*&      START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  IF radio92 = 'X'.
    CLEAR p_filenm.
  ENDIF.

  zebra1 = 0.
  zebra2 = 0.
  sw          = 0.

  PERFORM cek.

  va_monat1 = so_budat-low+4(2).
  va_monat2 = so_budat-low+4(2) + 1.
  va_budat3 = so_budat-low - 1.

  CONCATENATE so_budat-low(4) va_monat1 '01' INTO va_budat1.
  CONCATENATE so_budat-low(4) va_monat2 '01' INTO va_budat2.

  PERFORM init_column.
  PERFORM get_hkont.
  PERFORM get_begbal.
  PERFORM add_begbal.
  PERFORM get_main_data.
  PERFORM proses_data.

  IF radio1 EQ 'X'.
    IF i_hkont IS INITIAL.
      MESSAGE s000(zf) WITH 'No items selected'.
    ELSE.
      PERFORM cetak_radio1.
      IF p_filenm NE space.
        PERFORM download.
      ENDIF.
    ENDIF.
    REFRESH: i_outpl, i_dataset.
  ENDIF.

  IF radio2 EQ 'X'.
    IF i_budat IS INITIAL.
      MESSAGE s000(zf) WITH 'No items selected'.
    ELSE.
      PERFORM cetak_radio2.
      IF p_filenm NE space.
        PERFORM download.
      ENDIF.
    ENDIF.
    REFRESH: i_outpl, i_dataset.
  ENDIF.

  IF radio3 EQ 'X'.
    IF i_hkont IS INITIAL.
      MESSAGE s000(zf) WITH 'No items selected'.
    ELSE.
      PERFORM cetak_radio3.
      IF p_filenm NE space.
        PERFORM download.
      ENDIF.
    ENDIF.
    REFRESH: i_outpl, i_dataset.
  ENDIF.

  IF radio4 EQ 'X'.
    IF i_vbund IS INITIAL.
      MESSAGE s000(zf) WITH 'No items selected'.
    ELSE.
      PERFORM cetak_radio4.
      IF p_filenm NE space.
        PERFORM download.
      ENDIF.
    ENDIF.
    REFRESH: i_outpl, i_dataset.
  ENDIF.

  IF radio5 EQ 'X'.
    IF i_kostl IS INITIAL.
      MESSAGE s000(zf) WITH 'No items selected'.
    ELSE.
      PERFORM cetak_radio5.
      IF p_filenm NE space.
        PERFORM download.
      ENDIF.
    ENDIF.
    REFRESH: i_outpl, i_dataset.
  ENDIF.

  IF radio6 EQ 'X'.
    IF i_prctr IS INITIAL.
      MESSAGE s000(zf) WITH 'No items selected'.
    ELSE.
      PERFORM cetak_radio6.
      IF p_filenm NE space.
        PERFORM download.
      ENDIF.
    ENDIF.
    REFRESH: i_outpl, i_dataset.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  INIT_COLUMN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_column.
  w1   =  32.
  w1a  =  12.
  w1b  =  22.
  w1c  =  10.
  w1d  =  6.
  w1e  =  10.
  w1f  =  4.
  w1g  =  16.
  w1h  =  50.
  w1i  =  25.
  w1j  =  19.
  w1k  =  31.
  w1l  =  12.
  w1m  =  10.
  w1n  =  3.
  w1o  =  24.
  w1p  =  17.
  w1q  =  11.
  w2   =  5.
  w3   =  22.
  w4   =  20.
  w4a  =  16.
  w5   =  20.
  w5a  =  16.
  w6   =  22.
  w7   =  18.
  w8   =  18.
  w9   =  18.
  w10  =  18.
  w11  =  18.
  w12  =  18.
  c1 = 0.
ENDFORM.                    " INIT_COLUMN

*&---------------------------------------------------------------------*
*&      Form  GET_HKONT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_hkont.
  SELECT *
    FROM skat
    INTO CORRESPONDING FIELDS OF TABLE i_skat
    WHERE ( spras EQ 'EN'    OR
          spras EQ 'E' )     AND
          ktopl EQ 'TSPC'    AND
          saknr IN so_hkont.
ENDFORM.                    " GET_HKONT

*&---------------------------------------------------------------------*
*&      Form  GET_BEGBAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_begbal.
  IF i_skat[] IS NOT INITIAL.
    CASE 'X'.
      WHEN loccurr.
        SELECT *
          FROM glt0
          INTO CORRESPONDING FIELDS OF TABLE i_glt0
          FOR ALL ENTRIES IN i_skat
          WHERE bukrs EQ pa_bukrs        AND
                racct EQ i_skat-saknr    AND
                rbusa IN so_gsber        AND
                ryear EQ so_budat-low(4).
      WHEN doccurr.
        SELECT *
          FROM glt0
          INTO CORRESPONDING FIELDS OF TABLE i_glt0
          FOR ALL ENTRIES IN i_skat
          WHERE bukrs EQ pa_bukrs        AND
                racct EQ i_skat-saknr    AND
                rbusa IN so_gsber        AND
                ryear EQ so_budat-low(4) AND
                rtcur IN so_waers.
    ENDCASE.
  ENDIF.
ENDFORM.                    " GET_BEGBAL

*&---------------------------------------------------------------------*
*&      Form  GET_MAIN_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_main_data.
* BY DOCUMENT NUMBER, DOCUMENT DATE AND BUSINESS AREA
  IF radio1 EQ 'X' OR
     radio2 EQ 'X' OR
     radio3 EQ 'X'.
    IF radio10 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsis
          INTO CORRESPONDING FIELDS OF TABLE i_bsis
          FOR ALL ENTRIES IN i_skat
          WHERE bukrs EQ pa_bukrs       AND
                hkont EQ i_skat-saknr   AND
                budat IN so_budat       AND
                gsber IN so_gsber.

        SELECT *
          FROM bsas
          APPENDING  CORRESPONDING FIELDS OF TABLE i_bsis
          FOR ALL ENTRIES IN i_skat
          WHERE bukrs EQ pa_bukrs       AND
                hkont EQ i_skat-saknr   AND
                budat IN so_budat       AND
                augdt GE va_budat1      AND
                gsber IN so_gsber.
        SORT i_bsis BY bukrs belnr gjahr buzei.      "SOH Adj 20240807
      ENDIF.
    ENDIF.

    IF radio11 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                           b~vkorg EQ pa_bukrs
                         JOIN kna1 AS c ON a~kunnr EQ c~kunnr
          INTO CORRESPONDING FIELDS OF TABLE i_kunnr
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~budat IN so_budat       AND
                b~vwerk IN so_gsber       AND
                b~vwerk NE space          AND
                b~vtweg EQ '10'.

        SELECT *
          FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                           b~vkorg EQ pa_bukrs
                         JOIN kna1 AS c ON a~kunnr EQ c~kunnr
          APPENDING  CORRESPONDING FIELDS OF TABLE i_kunnr
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~budat IN so_budat       AND
                a~augdt GE va_budat1      AND
                b~vwerk IN so_gsber       AND
                b~vwerk NE space          AND
                b~vtweg EQ '10'.
      ENDIF.
    ENDIF.

    IF radio12 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsik AS a JOIN lfa1 AS b ON a~lifnr EQ b~lifnr
          INTO CORRESPONDING FIELDS OF TABLE i_lifnr
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~gsber IN so_gsber       AND
                a~gsber NE space          AND
                a~budat IN so_budat.

        SELECT *
          FROM bsak AS a JOIN lfa1 AS b ON a~lifnr EQ b~lifnr
          APPENDING CORRESPONDING FIELDS OF TABLE i_lifnr
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~gsber IN so_gsber       AND
                a~gsber NE space          AND
                a~budat IN so_budat       AND
                a~augdt GE va_budat1.
      ENDIF.
    ENDIF.
  ENDIF.

* BY TRADING PARTNER
  IF radio4 EQ 'X'.
    IF radio10 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsis AS a JOIN t880 AS b ON a~vbund EQ b~rcomp
          INTO CORRESPONDING FIELDS OF TABLE i_bsis
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~budat IN so_budat       AND
                a~vbund IN so_vbund.

        SELECT *
          FROM bsas AS a JOIN t880 AS b ON a~vbund EQ b~rcomp
          APPENDING  CORRESPONDING FIELDS OF TABLE i_bsis
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~budat IN so_budat       AND
                a~augdt GE va_budat1      AND
                a~vbund IN so_vbund.
        SORT i_bsis BY bukrs belnr gjahr buzei.      "SOH Adj 20240807
      ENDIF.
    ENDIF.

    IF radio11 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsid AS a JOIN t880 AS b ON a~vbund EQ b~rcomp
          INTO CORRESPONDING FIELDS OF TABLE i_kunnr
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~vbund IN so_vbund       AND
                a~budat IN so_budat.

        SELECT *
          FROM bsad AS a JOIN t880 AS b ON a~vbund EQ b~rcomp
          APPENDING CORRESPONDING FIELDS OF TABLE i_kunnr
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~vbund IN so_vbund       AND
                a~budat IN so_budat       AND
                a~augdt GE va_budat1.
      ENDIF.
    ENDIF.

    IF radio12 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsik AS a JOIN t880 AS b ON a~vbund EQ b~rcomp
          INTO CORRESPONDING FIELDS OF TABLE i_lifnr
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~vbund IN so_vbund       AND
                a~budat IN so_budat.

        SELECT *
          FROM bsak AS a JOIN t880 AS b ON a~vbund EQ b~rcomp
          APPENDING CORRESPONDING FIELDS OF TABLE i_lifnr
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~vbund IN so_vbund       AND
                a~budat IN so_budat       AND
                a~augdt GE va_budat1.
      ENDIF.
    ENDIF.
  ENDIF.

* BY COST CENTER
  IF radio5 EQ 'X'.
    IF radio10 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsis AS a JOIN cskt AS b ON a~kostl EQ b~kostl AND
                                           b~spras EQ 'EN'
          INTO CORRESPONDING FIELDS OF TABLE i_bsis
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~budat IN so_budat       AND
                a~kostl IN so_kostl.

        SELECT *
          FROM bsas AS a JOIN cskt AS b ON a~kostl EQ b~kostl AND
                                           b~spras EQ 'EN'
          APPENDING  CORRESPONDING FIELDS OF TABLE i_bsis
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~budat IN so_budat       AND
                a~augdt GE va_budat1      AND
                a~kostl IN so_kostl.
        SORT i_bsis BY bukrs belnr gjahr buzei.      "SOH Adj 20240807
      ENDIF.
    ENDIF.

    IF radio11 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsid AS a JOIN cskt AS b ON a~kostl EQ b~kostl AND
                                           b~spras EQ 'EN'
          INTO CORRESPONDING FIELDS OF TABLE i_kunnr
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~kostl IN so_kostl       AND
                a~budat IN so_budat.

        SELECT *
          FROM bsad AS a JOIN cskt AS b ON a~kostl EQ b~kostl AND
                                           b~spras EQ 'EN'
          APPENDING CORRESPONDING FIELDS OF TABLE i_kunnr
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~kostl IN so_kostl       AND
                a~budat IN so_budat       AND
                a~augdt GE va_budat1.
      ENDIF.
    ENDIF.

    IF radio12 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsik AS a JOIN cskt AS b ON a~kostl EQ b~kostl AND
                                           b~spras EQ 'EN'
          INTO CORRESPONDING FIELDS OF TABLE i_lifnr
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~kostl IN so_kostl       AND
                a~budat IN so_budat.

        SELECT *
          FROM bsak AS a JOIN cskt AS b ON a~kostl EQ b~kostl AND
                                           b~spras EQ 'EN'
          APPENDING CORRESPONDING FIELDS OF TABLE i_lifnr
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~kostl IN so_kostl       AND
                a~budat IN so_budat       AND
                a~augdt GE va_budat1.
      ENDIF.
    ENDIF.
  ENDIF.

* BY PROFIT CENTER
  IF radio6 EQ 'X'.
    IF radio10 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsis AS a JOIN cepct AS b ON a~prctr EQ b~prctr AND
                                            b~spras EQ 'EN'
          INTO CORRESPONDING FIELDS OF TABLE i_bsis
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~budat IN so_budat       AND
                a~prctr IN so_prctr.

        SELECT *
          FROM bsas AS a JOIN cepct AS b ON a~prctr EQ b~prctr AND
                                            b~spras EQ 'EN'
          APPENDING  CORRESPONDING FIELDS OF TABLE i_bsis
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~budat IN so_budat       AND
                a~augdt GE va_budat1      AND
                a~prctr IN so_prctr.
      ENDIF.
    ENDIF.

    IF radio11 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsid AS a JOIN cepct AS b ON a~prctr EQ b~prctr AND
                                            b~spras EQ 'EN'
          INTO CORRESPONDING FIELDS OF TABLE i_kunnr
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~prctr IN so_prctr       AND
                a~budat IN so_budat.

        SELECT *
          FROM bsad AS a JOIN cepct AS b ON a~prctr EQ b~prctr AND
                                            b~spras EQ 'EN'
          APPENDING CORRESPONDING FIELDS OF TABLE i_kunnr
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~prctr IN so_prctr       AND
                a~budat IN so_budat       AND
                a~augdt GE va_budat1.
      ENDIF.
    ENDIF.

    IF radio12 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsik AS a JOIN cepct AS b ON a~prctr EQ b~prctr AND
                                            b~spras EQ 'EN'
          INTO CORRESPONDING FIELDS OF TABLE i_lifnr
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~prctr IN so_prctr       AND
                a~budat IN so_budat.

        SELECT *
          FROM bsak AS a JOIN cepct AS b ON a~prctr EQ b~prctr AND
                                            b~spras EQ 'EN'
          APPENDING CORRESPONDING FIELDS OF TABLE i_lifnr
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~prctr IN so_prctr       AND
                a~budat IN so_budat       AND
                a~augdt GE va_budat1.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_MAIN_DATA

*&---------------------------------------------------------------------*
*&      Form  PROSES_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proses_data.

  CLEAR: wa_bsis.
  LOOP AT i_bsis INTO wa_bsis.
    IF radio1 EQ 'X' OR
       radio3 EQ 'X'.
      MOVE wa_bsis-bukrs   TO wa_hkont-bukrs.
      MOVE wa_bsis-hkont   TO wa_hkont-hkont.
      "IF wa_bsis-werks EQ space.
      MOVE wa_bsis-gsber   TO wa_hkont-gsber.
      "ELSE.
      "  MOVE wa_bsis-werks   TO wa_hkont-gsber.
      "ENDIF.
      MOVE wa_bsis-belnr   TO wa_hkont-belnr.
      MOVE wa_bsis-budat   TO wa_hkont-budat.
      MOVE wa_bsis-gjahr   TO wa_hkont-gjahr.
      MOVE wa_bsis-monat   TO wa_hkont-monat.
      MOVE wa_bsis-blart   TO wa_hkont-blart.
      MOVE wa_bsis-zuonr   TO wa_hkont-zuonr.
      MOVE wa_bsis-sgtxt   TO wa_hkont-sgtxt.
      MOVE wa_bsis-xblnr   TO wa_hkont-xblnr.
      MOVE wa_bsis-waers   TO wa_hkont-waers.
      MOVE wa_bsis-shkzg   TO wa_hkont-shkzg.
      MOVE wa_bsis-dmbtr   TO wa_hkont-dmbtr.
      IF wa_bsis-shkzg EQ 'S'.
        MOVE wa_bsis-dmbtr   TO wa_hkont-debet.
      ELSEIF wa_bsis-shkzg EQ 'H'.
        MOVE wa_bsis-dmbtr   TO wa_hkont-credit.
      ENDIF.
      IF wa_bsis-waers NE 'IDR'.
        IF wa_bsis-shkzg EQ 'S'.
          MOVE wa_bsis-wrbtr   TO wa_hkont-debet1.
        ELSEIF wa_bsis-shkzg EQ 'H'.
          MOVE wa_bsis-wrbtr   TO wa_hkont-credit1.
        ENDIF.
      ELSE.
        MOVE space TO wa_hkont-debet1.
        MOVE space TO wa_hkont-credit1.
      ENDIF.
      APPEND wa_hkont TO i_hkont.
      CLEAR: wa_hkont-debet, wa_hkont-credit,
             wa_hkont-debet1, wa_hkont-credit1.
    ENDIF.

    IF radio2 EQ 'X'.
      MOVE wa_bsis-bukrs   TO wa_budat-bukrs.
      MOVE wa_bsis-hkont   TO wa_budat-hkont.
      "IF wa_bsis-werks EQ space.
      MOVE wa_bsis-gsber   TO wa_budat-gsber.
      "ELSE.
      "  MOVE wa_bsis-werks   TO wa_budat-gsber.
      "ENDIF.
      MOVE wa_bsis-belnr   TO wa_budat-belnr.
      MOVE wa_bsis-budat   TO wa_budat-budat.
      MOVE wa_bsis-gjahr   TO wa_budat-gjahr.
      MOVE wa_bsis-monat   TO wa_budat-monat.
      MOVE wa_bsis-blart   TO wa_budat-blart.
      MOVE wa_bsis-zuonr   TO wa_budat-zuonr.
      MOVE wa_bsis-sgtxt   TO wa_budat-sgtxt.
      MOVE wa_bsis-xblnr   TO wa_budat-xblnr.
      MOVE wa_bsis-waers   TO wa_budat-waers.
      MOVE wa_bsis-shkzg   TO wa_budat-shkzg.
      MOVE wa_bsis-dmbtr   TO wa_budat-dmbtr.
      IF wa_bsis-shkzg EQ 'S'.
        MOVE wa_bsis-dmbtr   TO wa_budat-debet.
      ELSEIF wa_bsis-shkzg EQ 'H'.
        MOVE wa_bsis-dmbtr   TO wa_budat-credit.
      ENDIF.
      IF wa_bsis-waers NE 'IDR'.
        IF wa_bsis-shkzg EQ 'S'.
          MOVE wa_bsis-wrbtr   TO wa_budat-debet1.
        ELSEIF wa_bsis-shkzg EQ 'H'.
          MOVE wa_bsis-wrbtr   TO wa_budat-credit1.
        ENDIF.
      ELSE.
        MOVE space TO wa_budat-debet1.
        MOVE space TO wa_budat-credit1.
      ENDIF.
      APPEND wa_budat TO i_budat.
      CLEAR: wa_budat-debet, wa_budat-credit,
             wa_hkont-debet1, wa_hkont-credit1.
    ENDIF.

    IF radio4 EQ 'X'.
      MOVE wa_bsis-bukrs   TO wa_vbund-bukrs.
      MOVE wa_bsis-hkont   TO wa_vbund-hkont.
      MOVE wa_bsis-vbund   TO wa_vbund-vbund.
      MOVE wa_bsis-name1   TO wa_vbund-name1.
      MOVE wa_bsis-belnr   TO wa_vbund-belnr.
      MOVE wa_bsis-budat   TO wa_vbund-budat.
      MOVE wa_bsis-gjahr   TO wa_vbund-gjahr.
      MOVE wa_bsis-monat   TO wa_vbund-monat.
      MOVE wa_bsis-blart   TO wa_vbund-blart.
      MOVE wa_bsis-zuonr   TO wa_vbund-zuonr.
      MOVE wa_bsis-sgtxt   TO wa_vbund-sgtxt.
      MOVE wa_bsis-xblnr   TO wa_vbund-xblnr.
      MOVE wa_bsis-waers   TO wa_vbund-waers.
      MOVE wa_bsis-shkzg   TO wa_vbund-shkzg.
      MOVE wa_bsis-dmbtr   TO wa_vbund-dmbtr.
      IF wa_bsis-shkzg EQ 'S'.
        MOVE wa_bsis-dmbtr   TO wa_vbund-debet.
      ELSEIF wa_bsis-shkzg EQ 'H'.
        MOVE wa_bsis-dmbtr   TO wa_vbund-credit.
      ENDIF.
      IF wa_bsis-waers NE 'IDR'.
        IF wa_bsis-shkzg EQ 'S'.
          MOVE wa_bsis-wrbtr   TO wa_vbund-debet1.
        ELSEIF wa_bsis-shkzg EQ 'H'.
          MOVE wa_bsis-wrbtr   TO wa_vbund-credit1.
        ENDIF.
      ELSE.
        MOVE space TO wa_vbund-debet1.
        MOVE space TO wa_vbund-credit1.
      ENDIF.
      APPEND wa_vbund TO i_vbund.
      CLEAR: wa_vbund-debet, wa_vbund-credit,
             wa_hkont-debet1, wa_hkont-credit1.
    ENDIF.

    IF radio5 EQ 'X'.
      MOVE wa_bsis-bukrs   TO wa_kostl-bukrs.
      MOVE wa_bsis-hkont   TO wa_kostl-hkont.
      MOVE wa_bsis-kostl   TO wa_kostl-kostl.
      MOVE wa_bsis-ltext   TO wa_kostl-ltext.
      MOVE wa_bsis-belnr   TO wa_kostl-belnr.
      MOVE wa_bsis-budat   TO wa_kostl-budat.
      MOVE wa_bsis-gjahr   TO wa_kostl-gjahr.
      MOVE wa_bsis-monat   TO wa_kostl-monat.
      MOVE wa_bsis-blart   TO wa_kostl-blart.
      MOVE wa_bsis-zuonr   TO wa_kostl-zuonr.
      MOVE wa_bsis-sgtxt   TO wa_kostl-sgtxt.
      MOVE wa_bsis-xblnr   TO wa_kostl-xblnr.
      MOVE wa_bsis-waers   TO wa_kostl-waers.
      MOVE wa_bsis-shkzg   TO wa_kostl-shkzg.
      MOVE wa_bsis-dmbtr   TO wa_kostl-dmbtr.
      IF wa_bsis-shkzg EQ 'S'.
        MOVE wa_bsis-dmbtr   TO wa_kostl-debet.
      ELSEIF wa_bsis-shkzg EQ 'H'.
        MOVE wa_bsis-dmbtr   TO wa_kostl-credit.
      ENDIF.
      IF wa_bsis-waers NE 'IDR'.
        IF wa_bsis-shkzg EQ 'S'.
          MOVE wa_bsis-wrbtr   TO wa_kostl-debet1.
        ELSEIF wa_bsis-shkzg EQ 'H'.
          MOVE wa_bsis-wrbtr   TO wa_kostl-credit1.
        ENDIF.
      ELSE.
        MOVE space TO wa_kostl-debet1.
        MOVE space TO wa_kostl-credit1.
      ENDIF.
      APPEND wa_kostl TO i_kostl.
      CLEAR: wa_kostl-debet, wa_kostl-credit,
             wa_hkont-debet1, wa_hkont-credit1.
    ENDIF.

    IF radio6 EQ 'X'.
      MOVE wa_bsis-bukrs   TO wa_prctr-bukrs.
      MOVE wa_bsis-hkont   TO wa_prctr-hkont.
      MOVE wa_bsis-prctr   TO wa_prctr-prctr.
      MOVE wa_bsis-ltext   TO wa_prctr-ltext.
      MOVE wa_bsis-belnr   TO wa_prctr-belnr.
      MOVE wa_bsis-budat   TO wa_prctr-budat.
      MOVE wa_bsis-gjahr   TO wa_prctr-gjahr.
      MOVE wa_bsis-monat   TO wa_prctr-monat.
      MOVE wa_bsis-blart   TO wa_prctr-blart.
      MOVE wa_bsis-zuonr   TO wa_prctr-zuonr.
      MOVE wa_bsis-sgtxt   TO wa_prctr-sgtxt.
      MOVE wa_bsis-xblnr   TO wa_prctr-xblnr.
      MOVE wa_bsis-waers   TO wa_prctr-waers.
      MOVE wa_bsis-shkzg   TO wa_prctr-shkzg.
      MOVE wa_bsis-dmbtr   TO wa_prctr-dmbtr.
      IF wa_bsis-shkzg EQ 'S'.
        MOVE wa_bsis-dmbtr   TO wa_prctr-debet.
      ELSEIF wa_bsis-shkzg EQ 'H'.
        MOVE wa_bsis-dmbtr   TO wa_prctr-credit.
      ENDIF.
      IF wa_bsis-waers NE 'IDR'.
        IF wa_bsis-shkzg EQ 'S'.
          MOVE wa_bsis-wrbtr   TO wa_prctr-debet1.
        ELSEIF wa_bsis-shkzg EQ 'H'.
          MOVE wa_bsis-wrbtr   TO wa_prctr-credit1.
        ENDIF.
      ELSE.
        MOVE space TO wa_prctr-debet1.
        MOVE space TO wa_prctr-credit1.
      ENDIF.
      APPEND wa_prctr TO i_prctr.
      CLEAR: wa_prctr-debet, wa_prctr-credit,
             wa_hkont-debet1, wa_hkont-credit1.
    ENDIF.
    CLEAR: wa_bsis.
  ENDLOOP.

  CLEAR: wa_kunnr.
  LOOP AT i_kunnr INTO wa_kunnr.
    IF radio1 EQ 'X' OR
       radio3 EQ 'X'.
      MOVE wa_kunnr-bukrs  TO wa_hkont-bukrs.
      MOVE wa_kunnr-hkont  TO wa_hkont-hkont.
      MOVE wa_kunnr-vwerk  TO wa_hkont-gsber.
      MOVE wa_kunnr-kunnr  TO wa_hkont-kunnr.
      MOVE wa_kunnr-name1  TO wa_hkont-name1.
      MOVE wa_kunnr-belnr  TO wa_hkont-belnr.
      MOVE wa_kunnr-budat  TO wa_hkont-budat.
      MOVE wa_kunnr-gjahr  TO wa_hkont-gjahr.
      MOVE wa_kunnr-monat  TO wa_hkont-monat.
      MOVE wa_kunnr-blart  TO wa_hkont-blart.
      MOVE wa_kunnr-zuonr  TO wa_hkont-zuonr.
      MOVE wa_kunnr-sgtxt  TO wa_hkont-sgtxt.
      MOVE wa_kunnr-xblnr  TO wa_hkont-xblnr.
      MOVE wa_kunnr-waers  TO wa_hkont-waers.
      MOVE wa_kunnr-shkzg  TO wa_hkont-shkzg.
      MOVE wa_kunnr-dmbtr  TO wa_hkont-dmbtr.
      IF wa_kunnr-shkzg EQ 'S'.
        MOVE wa_kunnr-dmbtr   TO wa_hkont-debet.
      ELSEIF wa_kunnr-shkzg EQ 'H'.
        MOVE wa_kunnr-dmbtr   TO wa_hkont-credit.
      ENDIF.
      IF wa_kunnr-waers NE 'IDR'.
        IF wa_kunnr-shkzg EQ 'S'.
          MOVE wa_kunnr-wrbtr   TO wa_hkont-debet1.
        ELSEIF wa_kunnr-shkzg EQ 'H'.
          MOVE wa_kunnr-wrbtr   TO wa_hkont-credit1.
        ENDIF.
      ELSE.
        MOVE space TO wa_hkont-debet1.
        MOVE space TO wa_hkont-credit1.
      ENDIF.
      APPEND wa_hkont TO i_hkont.
      CLEAR: wa_hkont-debet, wa_hkont-credit,
             wa_hkont-debet1, wa_hkont-credit1.
    ENDIF.

    IF radio2 EQ 'X'.
      MOVE wa_kunnr-bukrs  TO wa_budat-bukrs.
      MOVE wa_kunnr-hkont  TO wa_budat-hkont.
      MOVE wa_kunnr-vwerk  TO wa_budat-gsber.
      MOVE wa_kunnr-kunnr  TO wa_budat-kunnr.
      MOVE wa_kunnr-name1  TO wa_budat-name1.
      MOVE wa_kunnr-belnr  TO wa_budat-belnr.
      MOVE wa_kunnr-budat  TO wa_budat-budat.
      MOVE wa_kunnr-gjahr  TO wa_budat-gjahr.
      MOVE wa_kunnr-monat  TO wa_budat-monat.
      MOVE wa_kunnr-blart  TO wa_budat-blart.
      MOVE wa_kunnr-zuonr  TO wa_budat-zuonr.
      MOVE wa_kunnr-sgtxt  TO wa_budat-sgtxt.
      MOVE wa_kunnr-xblnr  TO wa_budat-xblnr.
      MOVE wa_kunnr-waers  TO wa_budat-waers.
      MOVE wa_kunnr-shkzg  TO wa_budat-shkzg.
      MOVE wa_kunnr-dmbtr  TO wa_budat-dmbtr.
      IF wa_kunnr-shkzg EQ 'S'.
        MOVE wa_kunnr-dmbtr   TO wa_budat-debet.
      ELSEIF wa_kunnr-shkzg EQ 'H'.
        MOVE wa_kunnr-dmbtr   TO wa_budat-credit.
      ENDIF.
      IF wa_kunnr-waers NE 'IDR'.
        IF wa_kunnr-shkzg EQ 'S'.
          MOVE wa_kunnr-wrbtr   TO wa_budat-debet1.
        ELSEIF wa_kunnr-shkzg EQ 'H'.
          MOVE wa_kunnr-wrbtr   TO wa_budat-credit1.
        ENDIF.
      ELSE.
        MOVE space TO wa_budat-debet1.
        MOVE space TO wa_budat-credit1.
      ENDIF.
      APPEND wa_budat TO i_budat.
      CLEAR: wa_budat-debet, wa_budat-credit,
             wa_hkont-debet1, wa_hkont-credit1.
    ENDIF.

    IF radio4 EQ 'X'.
      MOVE wa_kunnr-bukrs  TO wa_vbund-bukrs.
      MOVE wa_kunnr-hkont  TO wa_vbund-hkont.
      MOVE wa_kunnr-vbund  TO wa_vbund-vbund.
      MOVE wa_kunnr-name1  TO wa_vbund-name1.
      MOVE wa_kunnr-belnr  TO wa_vbund-belnr.
      MOVE wa_kunnr-budat  TO wa_vbund-budat.
      MOVE wa_kunnr-gjahr  TO wa_vbund-gjahr.
      MOVE wa_kunnr-monat  TO wa_vbund-monat.
      MOVE wa_kunnr-blart  TO wa_vbund-blart.
      MOVE wa_kunnr-zuonr  TO wa_vbund-zuonr.
      MOVE wa_kunnr-sgtxt  TO wa_vbund-sgtxt.
      MOVE wa_kunnr-xblnr  TO wa_vbund-xblnr.
      MOVE wa_kunnr-waers  TO wa_vbund-waers.
      MOVE wa_kunnr-shkzg  TO wa_vbund-shkzg.
      MOVE wa_kunnr-dmbtr  TO wa_vbund-dmbtr.
      IF wa_kunnr-shkzg EQ 'S'.
        MOVE wa_kunnr-dmbtr   TO wa_vbund-debet.
      ELSEIF wa_kunnr-shkzg EQ 'H'.
        MOVE wa_kunnr-dmbtr   TO wa_vbund-credit.
      ENDIF.
      IF wa_kunnr-waers NE 'IDR'.
        IF wa_kunnr-shkzg EQ 'S'.
          MOVE wa_kunnr-wrbtr   TO wa_vbund-debet1.
        ELSEIF wa_kunnr-shkzg EQ 'H'.
          MOVE wa_kunnr-wrbtr   TO wa_vbund-credit1.
        ENDIF.
      ELSE.
        MOVE space TO wa_vbund-debet1.
        MOVE space TO wa_vbund-credit1.
      ENDIF.
      APPEND wa_vbund TO i_vbund.
      CLEAR: wa_vbund-debet, wa_vbund-credit,
             wa_hkont-debet1, wa_hkont-credit1.
    ENDIF.

    IF radio5 EQ 'X'.
      MOVE wa_kunnr-bukrs  TO wa_kostl-bukrs.
      MOVE wa_kunnr-hkont  TO wa_kostl-hkont.
      MOVE wa_kunnr-kostl  TO wa_kostl-kostl.
      MOVE wa_kunnr-ltext  TO wa_kostl-ltext.
      MOVE wa_kunnr-belnr  TO wa_kostl-belnr.
      MOVE wa_kunnr-budat  TO wa_kostl-budat.
      MOVE wa_kunnr-gjahr  TO wa_kostl-gjahr.
      MOVE wa_kunnr-monat  TO wa_kostl-monat.
      MOVE wa_kunnr-blart  TO wa_kostl-blart.
      MOVE wa_kunnr-zuonr  TO wa_kostl-zuonr.
      MOVE wa_kunnr-sgtxt  TO wa_kostl-sgtxt.
      MOVE wa_kunnr-xblnr  TO wa_kostl-xblnr.
      MOVE wa_kunnr-waers  TO wa_kostl-waers.
      MOVE wa_kunnr-shkzg  TO wa_kostl-shkzg.
      MOVE wa_kunnr-dmbtr  TO wa_kostl-dmbtr.
      IF wa_kunnr-shkzg EQ 'S'.
        MOVE wa_kunnr-dmbtr   TO wa_kostl-debet.
      ELSEIF wa_kunnr-shkzg EQ 'H'.
        MOVE wa_kunnr-dmbtr   TO wa_kostl-credit.
      ENDIF.
      IF wa_kunnr-waers NE 'IDR'.
        IF wa_kunnr-shkzg EQ 'S'.
          MOVE wa_kunnr-wrbtr   TO wa_kostl-debet1.
        ELSEIF wa_kunnr-shkzg EQ 'H'.
          MOVE wa_kunnr-wrbtr   TO wa_kostl-credit1.
        ENDIF.
      ELSE.
        MOVE space TO wa_kostl-debet1.
        MOVE space TO wa_kostl-credit1.
      ENDIF.
      APPEND wa_kostl TO i_kostl.
      CLEAR: wa_kostl-debet, wa_kostl-credit,
             wa_hkont-debet1, wa_hkont-credit1.
    ENDIF.

    IF radio6 EQ 'X'.
      MOVE wa_kunnr-bukrs  TO wa_prctr-bukrs.
      MOVE wa_kunnr-hkont  TO wa_prctr-hkont.
      MOVE wa_kunnr-prctr  TO wa_prctr-prctr.
      MOVE wa_kunnr-ltext  TO wa_prctr-ltext.
      MOVE wa_kunnr-belnr  TO wa_prctr-belnr.
      MOVE wa_kunnr-budat  TO wa_prctr-budat.
      MOVE wa_kunnr-gjahr  TO wa_prctr-gjahr.
      MOVE wa_kunnr-monat  TO wa_prctr-monat.
      MOVE wa_kunnr-blart  TO wa_prctr-blart.
      MOVE wa_kunnr-zuonr  TO wa_prctr-zuonr.
      MOVE wa_kunnr-sgtxt  TO wa_prctr-sgtxt.
      MOVE wa_kunnr-xblnr  TO wa_prctr-xblnr.
      MOVE wa_kunnr-waers  TO wa_prctr-waers.
      MOVE wa_kunnr-shkzg  TO wa_prctr-shkzg.
      MOVE wa_kunnr-dmbtr  TO wa_prctr-dmbtr.
      IF wa_kunnr-shkzg EQ 'S'.
        MOVE wa_kunnr-dmbtr   TO wa_prctr-debet.
      ELSEIF wa_kunnr-shkzg EQ 'H'.
        MOVE wa_kunnr-dmbtr   TO wa_prctr-credit.
      ENDIF.
      IF wa_kunnr-waers NE 'IDR'.
        IF wa_kunnr-shkzg EQ 'S'.
          MOVE wa_kunnr-wrbtr   TO wa_prctr-debet1.
        ELSEIF wa_kunnr-shkzg EQ 'H'.
          MOVE wa_kunnr-wrbtr   TO wa_prctr-credit1.
        ENDIF.
      ELSE.
        MOVE space TO wa_prctr-debet1.
        MOVE space TO wa_prctr-credit1.
      ENDIF.
      APPEND wa_prctr TO i_prctr.
      CLEAR: wa_prctr-debet, wa_prctr-credit,
             wa_hkont-debet1, wa_hkont-credit1.
    ENDIF.
    CLEAR: wa_kunnr.
  ENDLOOP.

  CLEAR: wa_lifnr.
  LOOP AT i_lifnr INTO wa_lifnr.
    IF radio1 EQ 'X' OR
       radio3 EQ 'X'.
      MOVE wa_lifnr-bukrs  TO wa_hkont-bukrs.
      MOVE wa_lifnr-hkont  TO wa_hkont-hkont.
      MOVE wa_lifnr-gsber  TO wa_hkont-gsber.
      MOVE wa_lifnr-lifnr  TO wa_hkont-lifnr.
      MOVE wa_lifnr-name1  TO wa_hkont-name1.
      MOVE wa_lifnr-belnr  TO wa_hkont-belnr.
      MOVE wa_lifnr-budat  TO wa_hkont-budat.
      MOVE wa_lifnr-gjahr  TO wa_hkont-gjahr.
      MOVE wa_lifnr-monat  TO wa_hkont-monat.
      MOVE wa_lifnr-blart  TO wa_hkont-blart.
      MOVE wa_lifnr-zuonr  TO wa_hkont-zuonr.
      MOVE wa_lifnr-sgtxt  TO wa_hkont-sgtxt.
      MOVE wa_lifnr-xblnr  TO wa_hkont-xblnr.
      MOVE wa_lifnr-waers  TO wa_hkont-waers.
      MOVE wa_lifnr-shkzg  TO wa_hkont-shkzg.
      MOVE wa_lifnr-dmbtr  TO wa_hkont-dmbtr.
      IF wa_lifnr-shkzg EQ 'S'.
        MOVE wa_lifnr-dmbtr   TO wa_hkont-debet.
      ELSEIF wa_lifnr-shkzg EQ 'H'.
        MOVE wa_lifnr-dmbtr   TO wa_hkont-credit.
      ENDIF.
      IF wa_lifnr-waers NE 'IDR'.
        IF wa_lifnr-shkzg EQ 'S'.
          MOVE wa_lifnr-wrbtr   TO wa_hkont-debet1.
        ELSEIF wa_lifnr-shkzg EQ 'H'.
          MOVE wa_lifnr-wrbtr   TO wa_hkont-credit1.
        ENDIF.
      ELSE.
        MOVE space TO wa_hkont-debet1.
        MOVE space TO wa_hkont-credit1.
      ENDIF.
      APPEND wa_hkont TO i_hkont.
      CLEAR: wa_hkont-debet, wa_hkont-credit,
             wa_hkont-debet1, wa_hkont-credit1.
    ENDIF.

    IF radio2 EQ 'X'.
      MOVE wa_lifnr-bukrs  TO wa_budat-bukrs.
      MOVE wa_lifnr-hkont  TO wa_budat-hkont.
      MOVE wa_lifnr-gsber  TO wa_budat-gsber.
      MOVE wa_lifnr-lifnr  TO wa_budat-lifnr.
      MOVE wa_lifnr-name1  TO wa_budat-name1.
      MOVE wa_lifnr-belnr  TO wa_budat-belnr.
      MOVE wa_lifnr-budat  TO wa_budat-budat.
      MOVE wa_lifnr-gjahr  TO wa_budat-gjahr.
      MOVE wa_lifnr-monat  TO wa_budat-monat.
      MOVE wa_lifnr-blart  TO wa_budat-blart.
      MOVE wa_lifnr-zuonr  TO wa_budat-zuonr.
      MOVE wa_lifnr-sgtxt  TO wa_budat-sgtxt.
      MOVE wa_lifnr-xblnr  TO wa_budat-xblnr.
      MOVE wa_lifnr-waers  TO wa_budat-waers.
      MOVE wa_lifnr-shkzg  TO wa_budat-shkzg.
      MOVE wa_lifnr-dmbtr  TO wa_budat-dmbtr.
      IF wa_lifnr-shkzg EQ 'S'.
        MOVE wa_lifnr-dmbtr   TO wa_budat-debet.
      ELSEIF wa_lifnr-shkzg EQ 'H'.
        MOVE wa_lifnr-dmbtr   TO wa_budat-credit.
      ENDIF.
      IF wa_lifnr-waers NE 'IDR'.
        IF wa_lifnr-shkzg EQ 'S'.
          MOVE wa_lifnr-wrbtr   TO wa_budat-debet1.
        ELSEIF wa_lifnr-shkzg EQ 'H'.
          MOVE wa_lifnr-wrbtr   TO wa_budat-credit1.
        ENDIF.
      ELSE.
        MOVE space TO wa_budat-debet1.
        MOVE space TO wa_budat-credit1.
      ENDIF.
      APPEND wa_budat TO i_budat.
      CLEAR: wa_budat-debet, wa_budat-credit,
             wa_hkont-debet1, wa_hkont-credit1.
    ENDIF.

    IF radio4 EQ 'X'.
      MOVE wa_lifnr-bukrs  TO wa_vbund-bukrs.
      MOVE wa_lifnr-hkont  TO wa_vbund-hkont.
      MOVE wa_lifnr-vbund  TO wa_vbund-vbund.
      MOVE wa_lifnr-name1  TO wa_vbund-name1.
      MOVE wa_lifnr-belnr  TO wa_vbund-belnr.
      MOVE wa_lifnr-budat  TO wa_vbund-budat.
      MOVE wa_lifnr-gjahr  TO wa_vbund-gjahr.
      MOVE wa_lifnr-monat  TO wa_vbund-monat.
      MOVE wa_lifnr-blart  TO wa_vbund-blart.
      MOVE wa_lifnr-zuonr  TO wa_vbund-zuonr.
      MOVE wa_lifnr-sgtxt  TO wa_vbund-sgtxt.
      MOVE wa_lifnr-xblnr  TO wa_vbund-xblnr.
      MOVE wa_lifnr-waers  TO wa_vbund-waers.
      MOVE wa_lifnr-shkzg  TO wa_vbund-shkzg.
      MOVE wa_lifnr-dmbtr  TO wa_vbund-dmbtr.
      IF wa_lifnr-shkzg EQ 'S'.
        MOVE wa_lifnr-dmbtr   TO wa_vbund-debet.
      ELSEIF wa_lifnr-shkzg EQ 'H'.
        MOVE wa_lifnr-dmbtr   TO wa_vbund-credit.
      ENDIF.
      IF wa_lifnr-waers NE 'IDR'.
        IF wa_lifnr-shkzg EQ 'S'.
          MOVE wa_lifnr-wrbtr   TO wa_vbund-debet1.
        ELSEIF wa_lifnr-shkzg EQ 'H'.
          MOVE wa_lifnr-wrbtr   TO wa_vbund-credit1.
        ENDIF.
      ELSE.
        MOVE space TO wa_vbund-debet1.
        MOVE space TO wa_vbund-credit1.
      ENDIF.
      APPEND wa_vbund TO i_vbund.
      CLEAR: wa_vbund-debet, wa_vbund-credit,
             wa_hkont-debet1, wa_hkont-credit1.
    ENDIF.

    IF radio5 EQ 'X'.
      MOVE wa_lifnr-bukrs  TO wa_kostl-bukrs.
      MOVE wa_lifnr-hkont  TO wa_kostl-hkont.
      MOVE wa_lifnr-kostl  TO wa_kostl-kostl.
      MOVE wa_lifnr-ltext  TO wa_kostl-ltext.
      MOVE wa_lifnr-belnr  TO wa_kostl-belnr.
      MOVE wa_lifnr-budat  TO wa_kostl-budat.
      MOVE wa_lifnr-gjahr  TO wa_kostl-gjahr.
      MOVE wa_lifnr-monat  TO wa_kostl-monat.
      MOVE wa_lifnr-blart  TO wa_kostl-blart.
      MOVE wa_lifnr-zuonr  TO wa_kostl-zuonr.
      MOVE wa_lifnr-sgtxt  TO wa_kostl-sgtxt.
      MOVE wa_lifnr-xblnr  TO wa_kostl-xblnr.
      MOVE wa_lifnr-waers  TO wa_kostl-waers.
      MOVE wa_lifnr-shkzg  TO wa_kostl-shkzg.
      MOVE wa_lifnr-dmbtr  TO wa_kostl-dmbtr.
      IF wa_lifnr-shkzg EQ 'S'.
        MOVE wa_lifnr-dmbtr   TO wa_kostl-debet.
      ELSEIF wa_lifnr-shkzg EQ 'H'.
        MOVE wa_lifnr-dmbtr   TO wa_kostl-credit.
      ENDIF.
      IF wa_lifnr-waers NE 'IDR'.
        IF wa_lifnr-shkzg EQ 'S'.
          MOVE wa_lifnr-wrbtr   TO wa_kostl-debet1.
        ELSEIF wa_lifnr-shkzg EQ 'H'.
          MOVE wa_lifnr-wrbtr   TO wa_kostl-credit1.
        ENDIF.
      ELSE.
        MOVE space TO wa_kostl-debet1.
        MOVE space TO wa_kostl-credit1.
      ENDIF.
      APPEND wa_kostl TO i_kostl.
      CLEAR: wa_kostl-debet, wa_kostl-credit,
             wa_hkont-debet1, wa_hkont-credit1.
    ENDIF.

    IF radio6 EQ 'X'.
      MOVE wa_lifnr-bukrs  TO wa_prctr-bukrs.
      MOVE wa_lifnr-hkont  TO wa_prctr-hkont.
      MOVE wa_lifnr-prctr  TO wa_prctr-prctr.
      MOVE wa_lifnr-ltext  TO wa_prctr-ltext.
      MOVE wa_lifnr-belnr  TO wa_prctr-belnr.
      MOVE wa_lifnr-budat  TO wa_prctr-budat.
      MOVE wa_lifnr-gjahr  TO wa_prctr-gjahr.
      MOVE wa_lifnr-monat  TO wa_prctr-monat.
      MOVE wa_lifnr-blart  TO wa_prctr-blart.
      MOVE wa_lifnr-zuonr  TO wa_prctr-zuonr.
      MOVE wa_lifnr-sgtxt  TO wa_prctr-sgtxt.
      MOVE wa_lifnr-xblnr  TO wa_prctr-xblnr.
      MOVE wa_lifnr-waers  TO wa_prctr-waers.
      MOVE wa_lifnr-shkzg  TO wa_prctr-shkzg.
      MOVE wa_lifnr-dmbtr  TO wa_prctr-dmbtr.
      IF wa_lifnr-shkzg EQ 'S'.
        MOVE wa_lifnr-dmbtr   TO wa_prctr-debet.
      ELSEIF wa_lifnr-shkzg EQ 'H'.
        MOVE wa_lifnr-dmbtr   TO wa_prctr-credit.
      ENDIF.
      IF wa_lifnr-waers NE 'IDR'.
        IF wa_lifnr-shkzg EQ 'S'.
          MOVE wa_lifnr-wrbtr   TO wa_prctr-debet1.
        ELSEIF wa_lifnr-shkzg EQ 'H'.
          MOVE wa_lifnr-wrbtr   TO wa_prctr-credit1.
        ENDIF.
      ELSE.
        MOVE space TO wa_prctr-debet1.
        MOVE space TO wa_prctr-credit1.
      ENDIF.
      APPEND wa_prctr TO i_prctr.
      CLEAR: wa_prctr-debet, wa_prctr-credit,
             wa_hkont-debet1, wa_hkont-credit1.
    ENDIF.
    CLEAR: wa_lifnr.
  ENDLOOP.
ENDFORM.                    " PROSES_DATA

*&---------------------------------------------------------------------*
*&      Form  MAIN_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM main_header.
  DATA:  l_butxt LIKE t001-butxt.

  IF sy-linno GE 53.
    NEW-PAGE.
  ENDIF.

  MOVE so_budat-low+4(2) TO bulan.
  MOVE so_budat-high+4(2) TO bulan1.
  PERFORM bulan.

  SELECT SINGLE butxt
    FROM t001
    INTO l_butxt
    WHERE bukrs EQ pa_bukrs.

  WRITE: /    l_butxt,
          61  'LEDGER REPORT',
          95  'Printing Date : ', sy-datum.

  CLEAR: wa_skat.
  LOOP AT i_skat INTO wa_skat
    WHERE saknr EQ va_hkont.
    MOVE wa_skat-txt50 TO va_txt50.
    CLEAR: wa_skat.
  ENDLOOP.

  WRITE: /    'G/L Account   : ', va_hkont, '-', va_txt50.
ENDFORM.                    " MAIN_HEADER

*&---------------------------------------------------------------------*
*&      Form  HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header.
  PERFORM main_header.
  IF so_budat-high EQ 0.
    WRITE: 95  'Posting Date  : ', so_budat-low.
*    WRITE: /95  'Period        : ', VA_PERIOD.
    WRITE: /53  pa_text CENTERED.
    WRITE:  95  'Period        : ', va_period.
  ELSE.
    WRITE: 95  'Posting Date  : ', so_budat-low, '-', so_budat-high.
    IF so_budat-high(6) EQ so_budat-low(6).
*      WRITE: /95  'Period        : ', VA_PERIOD.
      WRITE: /53  pa_text CENTERED.
      WRITE:  95  'Period        : ', va_period.
    ELSE.
*      WRITE: /95  'Period        : ', VA_PERIOD, '-', VA_PERIOD1.
      WRITE: /53  pa_text CENTERED.
      WRITE:  95  'Period        : ', va_period, '-', va_period1.
    ENDIF.
  ENDIF.

  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  WRITE: /    sy-uline(128).
  WRITE: /    sy-vline.
  c1 = 1.
  c1 = c1 + 1.
  WRITE AT c1(w1) 'Business Area'. c1 = c1 + w1.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w2) 'LCurr'. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w3) 'Beg. Balance' RIGHT-JUSTIFIED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w4) 'Debet' RIGHT-JUSTIFIED. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w5) 'Credit' RIGHT-JUSTIFIED. c1 = c1 + w5.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w6) 'End. Balance' RIGHT-JUSTIFIED. c1 = c1 + w6.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE: /    sy-uline(128).
ENDFORM.                    " HEADER

*&---------------------------------------------------------------------*
*&      Form  HEADER1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header1.
  PERFORM main_header.
  IF so_budat-high EQ 0.
    WRITE: 95  'Posting Date  : ', so_budat-low.
    WRITE: /    'Business Area : ', va_gtext.
    WRITE: 53  pa_text CENTERED.
    WRITE: 95  'Period        : ', va_period.
  ELSE.
    WRITE: 95  'Posting Date  : ', so_budat-low, '-', so_budat-high.
    IF so_budat-high(6) EQ so_budat-low(6).
      WRITE: /    'Business Area : ', va_gtext.
      WRITE: 53  pa_text CENTERED.
      WRITE: 95  'Period        : ', va_period.
    ELSE.
      WRITE: /    'Business Area : ', va_gtext.
      WRITE: 53  pa_text CENTERED.
      WRITE: 95  'Period        : ', va_period, '-', va_period1.
    ENDIF.
  ENDIF.

  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  WRITE: /    sy-uline(169).
  WRITE: /    sy-vline.
  c1 = 1.
  c1 = c1 + 1.
  WRITE AT c1(w1c) 'Pstg date'. c1 = c1 + w1c.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1e) 'Doc.no.'. c1 = c1 + w1e.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1f) 'BusA'. c1 = c1 + w1f.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1f) 'Type'. c1 = c1 + w1f.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1g) 'Reference'. c1 = c1 + w1g.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1h) 'Description'. c1 = c1 + w1h.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w2) 'LCurr'. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w4) 'Debet' RIGHT-JUSTIFIED. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w5) 'Credit' RIGHT-JUSTIFIED. c1 = c1 + w5.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w2) 'Curr'. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w4a) 'Debet' RIGHT-JUSTIFIED. c1 = c1 + w4a.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w5a) 'Credit' RIGHT-JUSTIFIED. c1 = c1 + w5a.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE: /    sy-uline(164).

  zebra1 = 0.
ENDFORM.                                                    " HEADER1

*&---------------------------------------------------------------------*
*&      Form  HEADER2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header2.
  PERFORM main_header.
  IF so_budat-high EQ 0.
    WRITE: 95  'Posting Date  : ', so_budat-low.
*    WRITE: /95  'Period        : ', VA_PERIOD.
    WRITE: /53  pa_text CENTERED.
    WRITE:  95  'Period        : ', va_period.
  ELSE.
    WRITE: 95  'Posting Date  : ', so_budat-low, '-', so_budat-high.
    IF so_budat-high(6) EQ so_budat-low(6).
*      WRITE: /95  'Period        : ', VA_PERIOD.
      WRITE: /53  pa_text CENTERED.
      WRITE:  95  'Period        : ', va_period.
    ELSE.
*      WRITE: /95  'Period        : ', VA_PERIOD, '-', VA_PERIOD1.
      WRITE: /53  pa_text CENTERED.
      WRITE:  95  'Period        : ', va_period, '-', va_period1.
    ENDIF.
  ENDIF.

  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  WRITE: /    sy-uline.
  WRITE: /    sy-vline.
  c1 = 1.
  c1 = c1 + 1.
  WRITE AT c1(w1c) 'Pstg date'. c1 = c1 + w1c.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1e) 'Doc.no.'. c1 = c1 + w1e.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1f) 'BusA'. c1 = c1 + w1f.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1f) 'Type'. c1 = c1 + w1f.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1g) 'Reference'. c1 = c1 + w1g.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1h) 'Description'. c1 = c1 + w1h.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w2) 'LCurr'. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w4) 'Debet' RIGHT-JUSTIFIED. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w5) 'Credit' RIGHT-JUSTIFIED. c1 = c1 + w5.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w2) 'Curr'. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w4a) 'Debet' RIGHT-JUSTIFIED. c1 = c1 + w4a.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w5a) 'Credit' RIGHT-JUSTIFIED. c1 = c1 + w5a.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE: /    sy-uline.

  zebra1 = 0.
ENDFORM.                                                    " HEADER2

*&---------------------------------------------------------------------*
*&      Form  HEADER2A
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header2a.
  PERFORM main_header.
  IF so_budat-high EQ 0.
    WRITE: 95  'Posting Date  : ', so_budat-low.
*    WRITE: /95  'Period        : ', VA_PERIOD.
    WRITE: /53  pa_text CENTERED.
    WRITE:  95  'Period        : ', va_period.
  ELSE.
    WRITE: 95  'Posting Date  : ', so_budat-low, '-', so_budat-high.
    IF so_budat-high(6) EQ so_budat-low(6).
*      WRITE: /95  'Period        : ', VA_PERIOD.
      WRITE: /53  pa_text CENTERED.
      WRITE:  95  'Period        : ', va_period.
    ELSE.
*      WRITE: /95  'Period        : ', VA_PERIOD, '-', VA_PERIOD1.
      WRITE: /53  pa_text CENTERED.
      WRITE:  95  'Period        : ', va_period, '-', va_period1.
    ENDIF.
  ENDIF.

  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  WRITE: /    sy-uline(66).
  WRITE: /    sy-vline.
  c1 = 1.
  c1 = c1 + 1.
  WRITE AT c1(w1a) 'Pstg date'. c1 = c1 + w1a.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w2) 'LCurr'. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w3) 'Debet' RIGHT-JUSTIFIED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w3) 'Credit' RIGHT-JUSTIFIED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE: /    sy-uline(66).
ENDFORM.                                                    " HEADER2A

*&---------------------------------------------------------------------*
*&      Form  HEADER3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header3.
  PERFORM main_header.
  IF so_budat-high EQ 0.
    WRITE: 95  'Posting Date  : ', so_budat-low.
*    WRITE: /95  'Period        : ', VA_PERIOD.
    WRITE: /53  pa_text CENTERED.
    WRITE:  95  'Period        : ', va_period.
  ELSE.
    WRITE: 95  'Posting Date  : ', so_budat-low, '-', so_budat-high.
    IF so_budat-high(6) EQ so_budat-low(6).
*      WRITE: /95  'Period        : ', VA_PERIOD.
      WRITE: /53  pa_text CENTERED.
      WRITE:  95  'Period        : ', va_period.
    ELSE.
*      WRITE: /95  'Period        : ', VA_PERIOD, '-', VA_PERIOD1.
      WRITE: /53  pa_text CENTERED.
      WRITE:  95  'Period        : ', va_period, '-', va_period1.
    ENDIF.
  ENDIF.

  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  WRITE: /    sy-uline(86).
  WRITE: /    sy-vline.
  c1 = 1.
  c1 = c1 + 1.
  WRITE AT c1(w1) 'Trading Partner'. c1 = c1 + w1.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w2) 'LCurr'. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w3) 'Debet' RIGHT-JUSTIFIED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w3) 'Credit' RIGHT-JUSTIFIED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE: /    sy-uline(86).
ENDFORM.                                                    " HEADER3

*&---------------------------------------------------------------------*
*&      Form  HEADER4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header4.
  PERFORM main_header.
  IF so_budat-high EQ 0.
    WRITE: 95  'Posting Date  : ', so_budat-low.
    WRITE: /    'Trading Partner : ', va_name1.
    WRITE: 95  'Period        : ', va_period.
    WRITE: 53  pa_text CENTERED.
  ELSE.
    WRITE: 95  'Posting Date  : ', so_budat-low, '-', so_budat-high.
    IF so_budat-high(6) EQ so_budat-low(6).
      WRITE: /    'Trading Partner : ', va_name1.
      WRITE: 95  'Period        : ', va_period.
      WRITE: 53  pa_text CENTERED.
    ELSE.
      WRITE: /    'Trading Partner : ', va_name1.
      WRITE: 95  'Period        : ', va_period, '-', va_period1.
      WRITE: 53  pa_text CENTERED.
    ENDIF.
  ENDIF.

  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  WRITE: /    sy-uline(164).
  WRITE: /    sy-vline.
  c1 = 1.
  c1 = c1 + 1.
  WRITE AT c1(w1c) 'Pstg date'. c1 = c1 + w1c.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1e) 'Doc.no.'. c1 = c1 + w1e.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1f) 'Type'. c1 = c1 + w1f.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1g) 'Reference'. c1 = c1 + w1g.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1h) 'Description'. c1 = c1 + w1h.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w2) 'LCurr'. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w4) 'Debet' RIGHT-JUSTIFIED. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w5) 'Credit' RIGHT-JUSTIFIED. c1 = c1 + w5.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w2) 'Curr'. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w4a) 'Debet' RIGHT-JUSTIFIED. c1 = c1 + w4a.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w5a) 'Credit' RIGHT-JUSTIFIED. c1 = c1 + w5a.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE: /    sy-uline(164).

  zebra1 = 0.
ENDFORM.                                                    " HEADER4

*&---------------------------------------------------------------------*
*&      Form  HEADER5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header5.
  PERFORM main_header.
  IF so_budat-high EQ 0.
    WRITE: 95  'Posting Date  : ', so_budat-low.
*    WRITE: /95  'Period        : ', VA_PERIOD.
    WRITE: /53  pa_text CENTERED.
    WRITE:  95  'Period        : ', va_period.
  ELSE.
    WRITE: 95  'Posting Date  : ', so_budat-low, '-', so_budat-high.
    IF so_budat-high(6) EQ so_budat-low(6).
*      WRITE: /95  'Period        : ', VA_PERIOD.
      WRITE: /53  pa_text CENTERED.
      WRITE:  95  'Period        : ', va_period.
    ELSE.
*      WRITE: /95  'Period        : ', VA_PERIOD, '-', VA_PERIOD1.
      WRITE: /53  pa_text CENTERED.
      WRITE:  95  'Period        : ', va_period, '-', va_period1.
    ENDIF.
  ENDIF.

  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  WRITE: /    sy-uline(86).
  WRITE: /    sy-vline.
  c1 = 1.
  c1 = c1 + 1.
  WRITE AT c1(w1) 'Cost Center'. c1 = c1 + w1.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w2) 'LCurr'. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w3) 'Debet' RIGHT-JUSTIFIED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w3) 'Credit' RIGHT-JUSTIFIED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE: /    sy-uline(86).
ENDFORM.                                                    " HEADER5

*&---------------------------------------------------------------------*
*&      Form  HEADER6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header6.
  PERFORM main_header.
  IF so_budat-high EQ 0.
    WRITE: 95  'Posting Date  : ', so_budat-low.
    WRITE: /    'Cost Center     : ', va_ltext.
    WRITE: 95  'Period        : ', va_period.
    WRITE: 53  pa_text CENTERED.
  ELSE.
    WRITE: 95  'Posting Date  : ', so_budat-low, '-', so_budat-high.
    IF so_budat-high(6) EQ so_budat-low(6).
      WRITE: /    'Cost Center     : ', va_ltext.
      WRITE: 95  'Period        : ', va_period.
      WRITE: 53  pa_text CENTERED.
    ELSE.
      WRITE: /    'Cost Center     : ', va_ltext.
      WRITE: 95  'Period        : ', va_period, '-', va_period1.
      WRITE: 53  pa_text CENTERED.
    ENDIF.
  ENDIF.

  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  WRITE: /    sy-uline(164).
  WRITE: /    sy-vline.
  c1 = 1.
  c1 = c1 + 1.
  WRITE AT c1(w1c) 'Pstg date'. c1 = c1 + w1c.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1e) 'Doc.no.'. c1 = c1 + w1e.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1f) 'Type'. c1 = c1 + w1f.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1g) 'Reference'. c1 = c1 + w1g.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1h) 'Description'. c1 = c1 + w1h.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w2) 'LCurr'. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w4) 'Debet' RIGHT-JUSTIFIED. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w5) 'Credit' RIGHT-JUSTIFIED. c1 = c1 + w5.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w2) 'Curr'. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w4a) 'Debet' RIGHT-JUSTIFIED. c1 = c1 + w4a.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w5a) 'Credit' RIGHT-JUSTIFIED. c1 = c1 + w5a.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE: /    sy-uline(164).

  zebra1 = 0.
ENDFORM.                                                    " HEADER6

*&---------------------------------------------------------------------*
*&      Form  HEADER7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header7.
  PERFORM main_header.
  IF so_budat-high EQ 0.
    WRITE: 95  'Posting Date  : ', so_budat-low.
*    WRITE: /95  'Period        : ', VA_PERIOD.
    WRITE: /53  pa_text CENTERED.
    WRITE:  95  'Period        : ', va_period.
  ELSE.
    WRITE: 95  'Posting Date  : ', so_budat-low, '-', so_budat-high.
    IF so_budat-high(6) EQ so_budat-low(6).
*      WRITE: /95  'Period        : ', VA_PERIOD.
      WRITE: /53  pa_text CENTERED.
      WRITE:  95  'Period        : ', va_period.
    ELSE.
*      WRITE: /95  'Period        : ', VA_PERIOD, '-', VA_PERIOD1.
      WRITE: /53  pa_text CENTERED.
      WRITE:  95  'Period        : ', va_period, '-', va_period1.
    ENDIF.
  ENDIF.

  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  WRITE: /    sy-uline(86).
  WRITE: /    sy-vline.
  c1 = 1.
  c1 = c1 + 1.
  WRITE AT c1(w1) 'Profit Center'. c1 = c1 + w1.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w2) 'LCurr'. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w3) 'Debet' RIGHT-JUSTIFIED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w3) 'Credit' RIGHT-JUSTIFIED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE: /    sy-uline(86).
ENDFORM.                                                    " HEADER7

*&---------------------------------------------------------------------*
*&      Form  HEADER8
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header8.
  PERFORM main_header.
  IF so_budat-high EQ 0.
    WRITE: 95  'Posting Date  : ', so_budat-low.
    WRITE: /    'Profit Center   : ', va_ltext.
    WRITE: 95  'Period        : ', va_period.
    WRITE: 53  pa_text CENTERED.
  ELSE.
    WRITE: 95  'Posting Date  : ', so_budat-low, '-', so_budat-high.
    IF so_budat-high(6) EQ so_budat-low(6).
      WRITE: /    'Profit Center   : ', va_ltext.
      WRITE: 95  'Period        : ', va_period.
      WRITE: 53  pa_text CENTERED.
    ELSE.
      WRITE: /    'Profit Center   : ', va_ltext.
      WRITE: 95  'Period        : ', va_period, '-', va_period1.
      WRITE: 52  pa_text CENTERED.
    ENDIF.
  ENDIF.

  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  WRITE: /    sy-uline(164).
  WRITE: /    sy-vline.
  c1 = 1.
  c1 = c1 + 1.
  WRITE AT c1(w1c) 'Pstg date'. c1 = c1 + w1c.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1e) 'Doc.no.'. c1 = c1 + w1e.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1f) 'Type'. c1 = c1 + w1f.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1g) 'Reference'. c1 = c1 + w1g.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1h) 'Description'. c1 = c1 + w1h.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w2) 'LCurr'. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w4) 'Debet' RIGHT-JUSTIFIED. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w5) 'Credit' RIGHT-JUSTIFIED. c1 = c1 + w5.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w2) 'Curr'. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w4a) 'Debet' RIGHT-JUSTIFIED. c1 = c1 + w4a.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w5a) 'Credit' RIGHT-JUSTIFIED. c1 = c1 + w5a.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE: /    sy-uline(164).

  zebra1 = 0.
ENDFORM.                                                    " HEADER8

*&---------------------------------------------------------------------*
*&      Form  CETAK_RADIO1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_radio1.
  DATA : lv_space       TYPE i,
         lv_uline       TYPE i,
         lv_kosong(15),
         lv_curr(3),
         lv_begbalp(16),
         lv_begbaln(16),
         lv_endbalp(16),
         lv_endbaln(16),
         lv_tdebet(18),
         lv_tcredit(18).

  PERFORM f_get_additional_field CHANGING lv_space lv_uline.

  NEW-PAGE LINE-SIZE lv_uline.

  CLEAR: wa_hkont.

  SORT i_hkont BY hkont budat belnr shkzg sgtxt.
  LOOP AT i_hkont INTO wa_hkont.

    IF p_filenm NE space.
      PERFORM move_outpl1 USING wa_hkont-belnr wa_hkont-hkont.
    ENDIF.

    AT NEW hkont.
      CLEAR: wa_glt0, va_begbal.
      CASE 'X'.
        WHEN loccurr.
          PERFORM f_calc_begbal USING 'LOCCURR' wa_hkont-hkont
                                CHANGING va_begbal.
        WHEN doccurr.
          PERFORM f_calc_begbal USING 'DOCCURR' wa_hkont-hkont
                                CHANGING va_begbal.
      ENDCASE.

      IF sw = 0.
        sw = 1.
        MOVE va_begbal TO va_begbal1.
      ELSE.
        FORMAT INTENSIFIED ON.
        FORMAT COLOR 3.
        WRITE: /    sy-uline.
        WRITE: /    sy-vline, ' Total'.
        WRITE AT lv_space sy-vline NO-GAP.
        WRITE total_debet TO lv_tdebet CURRENCY 'IDR'.
        WRITE total_credit TO lv_tcredit CURRENCY 'IDR'.
        WRITE:      lv_tdebet NO-GAP,
                    sy-vline NO-GAP, lv_tcredit NO-GAP,
                    sy-vline, lv_curr,
                    sy-vline, lv_kosong,
                    sy-vline, lv_kosong,
                    sy-vline.
        WRITE: /    sy-uline.

        va_endbal = va_begbal1 + total_debet - total_credit.
        MOVE va_begbal TO va_begbal1.

        FORMAT INTENSIFIED OFF.
        WRITE: /    sy-vline, 'Ending Balance'.
        CLEAR : lv_endbalp, lv_endbaln.
        IF va_endbal GE 0.
          WRITE va_endbal CURRENCY 'IDR' TO lv_endbalp.
        ELSE.
          WRITE va_endbal CURRENCY 'IDR' TO lv_endbaln.
        ENDIF.
        WRITE AT lv_space sy-vline.
        WRITE : lv_endbalp, sy-vline, lv_endbaln, sy-vline.
        WRITE:   lv_curr, sy-vline, lv_kosong,
                 sy-vline, lv_kosong,
                 sy-vline.
        WRITE: /    sy-uline.
        SKIP 1.
        FORMAT INTENSIFIED ON.
        CLEAR: total_begbal, total_debet, total_credit, total_endbal.
      ENDIF.

      FORMAT COLOR OFF.
      FORMAT INTENSIFIED ON.
      zebra1 = 0.
      MOVE wa_hkont-hkont TO va_hkont.

      PERFORM header2_additional USING lv_uline.

      FORMAT INTENSIFIED OFF.

* Revisi perhitungan dmbtr 20/02/2007
      READ TABLE t_dmbtr WITH KEY hkont = wa_hkont-hkont.
      IF sy-subrc EQ 0.
        va_dmbtr = t_dmbtr-dmbtr.
      ELSE.
        CLEAR: va_dmbtr.
      ENDIF.
* End revisi

      va_begbal = va_begbal + va_dmbtr.
      FORMAT COLOR 3.
      WRITE: /    sy-vline, 'Beginning Balance'.
      CLEAR : lv_begbalp, lv_begbaln.
      IF va_begbal GE 0.
        WRITE va_begbal CURRENCY 'IDR' TO lv_begbalp.
      ELSE.
        WRITE va_begbal CURRENCY 'IDR' TO lv_begbaln.
      ENDIF.
      WRITE AT lv_space sy-vline.
      WRITE : lv_begbalp, sy-vline, lv_begbaln, sy-vline.
      va_begbal1 = va_begbal.
      WRITE:   lv_curr, sy-vline, lv_kosong,
               sy-vline, lv_kosong,
               sy-vline.
      WRITE: /    sy-uline.

      FORMAT INTENSIFIED ON.
      FORMAT COLOR 1.
    ENDAT.

    MOVE wa_hkont-monat TO va_monat.
    MOVE wa_hkont-sgtxt TO va_sgtxt.
    MOVE wa_hkont-belnr TO va_belnr.
    MOVE wa_hkont-gsber TO va_gsber1.
    MOVE wa_hkont-budat TO va_budat.
    MOVE wa_hkont-xblnr TO va_xblnr.
    MOVE wa_hkont-blart TO va_blart.
    IF wa_hkont-waers NE 'IDR'.
      MOVE wa_hkont-waers TO va_waers.
    ELSE.
      MOVE space TO va_waers.
    ENDIF.
    MOVE wa_hkont-gjahr TO va_gjahr.
    ADD wa_hkont-debet  TO total_debet.
    ADD wa_hkont-credit TO total_credit.
    ADD wa_hkont-debet  TO va_debet.
    ADD wa_hkont-credit TO va_credit.
    ADD wa_hkont-debet1 TO va_debet1.
    ADD wa_hkont-credit1 TO va_credit1.

    IF wa_hkont-debet  NE 0 OR
       wa_hkont-credit NE 0.

      AT END OF belnr.
        IF zebra1 = 0.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 2.
          zebra1 = 1.
        ELSE.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 1.
          zebra1 = 0.
        ENDIF.

        WRITE: /   sy-vline NO-GAP, va_budat NO-GAP,
                   sy-vline, va_monat,
                   sy-vline NO-GAP, va_belnr HOTSPOT NO-GAP,
                   sy-vline NO-GAP, va_gsber1 NO-GAP,
                   sy-vline, va_blart,
                   sy-vline NO-GAP, va_xblnr NO-GAP,
                   sy-vline NO-GAP, va_sgtxt NO-GAP.
        PERFORM f_detail_additional USING va_belnr wa_hkont-hkont.
        WRITE:     sy-vline, 'IDR',
                   sy-vline, va_debet CURRENCY 'IDR',
                   sy-vline, va_credit CURRENCY 'IDR',
                   sy-vline, va_waers,
                   sy-vline NO-GAP, va_debet1 CURRENCY va_waers,
                   sy-vline NO-GAP, va_credit1 CURRENCY va_waers,
                   sy-vline.

        HIDE: va_gjahr.

        IF sy-linno EQ 59.
          WRITE: / sy-uline.
          FORMAT INTENSIFIED ON.
          FORMAT COLOR OFF.
          PERFORM header2_additional USING lv_uline.
        ENDIF.
        CLEAR: va_debet, va_credit, va_debet1, va_credit1.
      ENDAT.
    ENDIF.
    CLEAR: wa_hkont.
  ENDLOOP.

  va_endbal = va_begbal1 + total_debet - total_credit.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 3.
  WRITE: /    sy-uline.
  WRITE: /    sy-vline, ' Total'.
  WRITE AT lv_space sy-vline NO-GAP.
  WRITE total_debet TO lv_tdebet CURRENCY 'IDR'.
  WRITE total_credit TO lv_tcredit CURRENCY 'IDR'.
  WRITE:      lv_tdebet NO-GAP,
              sy-vline NO-GAP, lv_tcredit NO-GAP,
              sy-vline, lv_curr,
              sy-vline, lv_kosong,
              sy-vline, lv_kosong,
              sy-vline.
  WRITE: /    sy-uline.
  FORMAT INTENSIFIED OFF.
  WRITE: /    sy-vline, 'Ending Balance'.
  CLEAR : lv_endbalp, lv_endbaln.
  IF va_endbal GE 0.
    WRITE va_endbal CURRENCY 'IDR' TO lv_endbalp.
  ELSE.
    WRITE va_endbal CURRENCY 'IDR' TO lv_endbaln.
  ENDIF.
  WRITE AT lv_space sy-vline.
  WRITE : lv_endbalp, sy-vline, lv_endbaln, sy-vline.
  WRITE:   lv_curr, sy-vline, lv_kosong,
           sy-vline, lv_kosong,
           sy-vline.
  WRITE: /    sy-uline.
  SKIP 1.
  FORMAT INTENSIFIED ON.
  CLEAR: total_begbal, total_debet, total_credit, total_endbal.
ENDFORM.                    " CETAK_RADIO1

*&---------------------------------------------------------------------*
*&      Form  CETAK_RADIO2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_radio2.
  CLEAR: wa_budat.
  LOOP AT i_budat INTO wa_budat.
    MOVE-CORRESPONDING wa_budat TO wa_budat1.
    APPEND wa_budat1 TO i_budat1.
    CLEAR: wa_budat.
  ENDLOOP.

  CLEAR: wa_budat.
  SORT i_budat BY hkont budat.
  LOOP AT i_budat INTO wa_budat.
    IF p_filenm NE space.
      PERFORM move_outpl2.
    ENDIF.

    AT NEW hkont.
      CLEAR: wa_glt0, va_begbal.
      CASE 'X'.
        WHEN loccurr.
          PERFORM f_calc_begbal USING 'LOCCURR' wa_budat-hkont
                                CHANGING va_begbal.
        WHEN doccurr.
          PERFORM f_calc_begbal USING 'DOCCURR' wa_budat-hkont
                                CHANGING va_begbal.
      ENDCASE.

      IF sw = 0.
        sw = 1.
        MOVE va_begbal TO va_begbal1.
      ELSE.
        FORMAT INTENSIFIED ON.
        FORMAT COLOR 3.
        WRITE: /    sy-uline(66).
        WRITE: /    sy-vline, ' Total',
                20  sy-vline, total_debet CURRENCY 'IDR',
                43  sy-vline, total_credit CURRENCY 'IDR',
                    sy-vline.
        WRITE: /    sy-uline(66).

        va_endbal = va_begbal1 + total_debet - total_credit.
        MOVE va_begbal TO va_begbal1.

        FORMAT INTENSIFIED OFF.
        WRITE: /    sy-vline, 'Ending Balance'.
        IF va_endbal GE 0.
          WRITE:  20  sy-vline, 22 va_endbal CURRENCY 'IDR',
                  43  sy-vline.
        ELSE.
          WRITE:  20  sy-vline,
                  43  sy-vline, va_endbal CURRENCY 'IDR'.
        ENDIF.
        WRITE:  66 sy-vline.
        WRITE: /    sy-uline(66).
        SKIP 1.
        FORMAT INTENSIFIED ON.
        CLEAR: total_begbal, total_debet, total_credit, total_endbal.
      ENDIF.

      FORMAT COLOR OFF.
      FORMAT INTENSIFIED ON.
      zebra1 = 0.
      MOVE wa_budat-hkont TO va_hkont.
      PERFORM header2a.

      FORMAT INTENSIFIED OFF.
      FORMAT COLOR 3.

* Revisi perhitungan dmbtr 20/02/2007
      READ TABLE t_dmbtr WITH KEY hkont = wa_budat-hkont.
      IF sy-subrc EQ 0.
        va_dmbtr = t_dmbtr-dmbtr.
      ELSE.
        CLEAR: va_dmbtr.
      ENDIF.
* End revisi

      va_begbal = va_begbal + va_dmbtr.
      WRITE: /    sy-vline NO-GAP, 'Beginning Balance' NO-GAP.
      IF va_begbal GE 0.
        WRITE:  20  sy-vline, 22 va_begbal CURRENCY 'IDR',
                43  sy-vline.
      ELSE.
        WRITE:  20  sy-vline,
                43  sy-vline, va_begbal CURRENCY 'IDR'.
      ENDIF.
      va_begbal1 = va_begbal.
      WRITE:  66 sy-vline.
      WRITE: / sy-uline(66).

      FORMAT INTENSIFIED ON.
      FORMAT COLOR 1.
    ENDAT.

    MOVE wa_budat-belnr TO va_belnr.
    ADD wa_budat-debet  TO va_debet.
    ADD wa_budat-credit TO va_credit.

    IF wa_budat-debet  NE 0 OR
       wa_budat-credit NE 0.

      AT END OF budat.
        IF zebra1 = 0.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 2.
          zebra1 = 1.
        ELSE.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 1.
          zebra1 = 0.
        ENDIF.

        WRITE: /    sy-vline, wa_budat-budat HOTSPOT,
                    sy-vline, 'IDR',
                    sy-vline, 26 va_debet CURRENCY 'IDR',
                    sy-vline, 49 va_credit CURRENCY 'IDR',
                    sy-vline.
        ADD va_debet  TO total_debet.
        ADD va_credit TO total_credit.
        HIDE: wa_budat-hkont.
        CLEAR: va_debet, va_credit.

        IF sy-linno EQ 59.
          WRITE: / sy-uline(66).
          FORMAT INTENSIFIED ON.
          FORMAT COLOR OFF.
          PERFORM header2a.
        ENDIF.
      ENDAT.
    ENDIF.
    CLEAR: wa_budat.
  ENDLOOP.

  va_endbal = va_begbal1 + total_debet - total_credit.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 3.
  WRITE: /    sy-uline(66).
  WRITE: /    sy-vline, ' Total',
          20  sy-vline, total_debet CURRENCY 'IDR',
          43  sy-vline, total_credit CURRENCY 'IDR',
              sy-vline.
  WRITE: /    sy-uline(66).
  FORMAT INTENSIFIED OFF.
  WRITE: /    sy-vline, 'Ending Balance'.
  IF va_endbal GE 0.
    WRITE:  20  sy-vline, 22 va_endbal CURRENCY 'IDR',
            43  sy-vline.
  ELSE.
    WRITE:  20  sy-vline,
            43  sy-vline, va_endbal CURRENCY 'IDR'.
  ENDIF.
  WRITE: 66  sy-vline.
  WRITE: /    sy-uline(66).
  SKIP 1.
  FORMAT INTENSIFIED ON.
  CLEAR: total_begbal, total_debet, total_credit, total_endbal.
ENDFORM.                    " CETAK_RADIO2

*&---------------------------------------------------------------------*
*&      Form  CETAK_RADIO3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_radio3.
  CLEAR: wa_hkont.
  LOOP AT i_hkont INTO wa_hkont.
    MOVE-CORRESPONDING wa_hkont TO wa_hkont2.
    APPEND wa_hkont2 TO i_hkont2.
    CLEAR: wa_hkont.
  ENDLOOP.

  PERFORM f_add_balance.

  CLEAR: wa_hkont2.
  SORT i_hkont2 BY bukrs hkont gsber.
  LOOP AT i_hkont2 INTO wa_hkont2.

    IF p_filenm NE space.
      PERFORM move_outpl3.
    ENDIF.

    MOVE wa_hkont2-hkont TO va_hkont.
    MOVE wa_hkont2-gsber TO va_gsber.
    MOVE wa_hkont2-waers TO va_waers.
    ADD wa_hkont2-debet  TO va_debet.
    ADD wa_hkont2-credit TO va_credit.

    AT NEW hkont.
      IF sw = 0.
        sw = 1.
      ELSE.
        WRITE: /    sy-uline(128).
        FORMAT INTENSIFIED ON.
        FORMAT COLOR 3.
        WRITE: /    sy-vline.
        c1 = 1.
        c1 = c1 + 1.
        WRITE AT c1(w1) ' Total'. c1 = c1 + w1.
        c1 = c1 + 1.
        c1 = c1 + w2.
        WRITE AT c1(1) sy-vline. c1 = c1 + 1.
        WRITE:    total_begbal CURRENCY 'IDR',
                  sy-vline NO-GAP, total_debet CURRENCY 'IDR' NO-GAP,
                  sy-vline NO-GAP, total_credit CURRENCY 'IDR' NO-GAP,
                  sy-vline, total_endbal CURRENCY 'IDR',
                  sy-vline.
        WRITE: /    sy-uline(128).
        SKIP 1.
        CLEAR: total_begbal, total_debet, total_credit, total_endbal.
      ENDIF.

      FORMAT COLOR OFF.
      FORMAT INTENSIFIED ON.
      zebra1 = 0.
      MOVE wa_hkont2-hkont TO va_hkont.
      PERFORM header.
    ENDAT.

    AT END OF gsber.
      CLEAR: wa_glt0, va_begbal.
      CASE 'X'.
        WHEN loccurr.
          PERFORM f_calc_begbal1 USING 'LOCCURR' wa_hkont2-hkont wa_hkont2-gsber
                                 CHANGING va_begbal.
        WHEN doccurr.
          PERFORM f_calc_begbal1 USING 'DOCCURR' wa_hkont2-hkont wa_hkont2-gsber
                                 CHANGING va_begbal.
      ENDCASE.

      IF va_begbal NE 0 OR
         va_debet  NE 0 OR
         va_credit NE 0.
        IF zebra1 = 0.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 2.
          zebra1 = 1.
        ELSE.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 1.
          zebra1 = 0.
        ENDIF.

        va_endbal = va_begbal + va_debet - va_credit.

        SELECT SINGLE gtext
          FROM tgsbt
          INTO va_gtext
          WHERE gsber EQ wa_hkont2-gsber.

        WRITE: /    sy-vline, va_gtext HOTSPOT,
                    sy-vline, 'IDR',
                    sy-vline, va_begbal CURRENCY 'IDR',
                    sy-vline, 68 va_debet CURRENCY 'IDR' NO-GAP,
                    sy-vline, 89 va_credit CURRENCY 'IDR' NO-GAP,
                    sy-vline, va_endbal CURRENCY 'IDR',
                    sy-vline.
        HIDE: va_hkont, va_gsber.

        IF sy-linno EQ 59.
          WRITE: / sy-uline(128).
          FORMAT INTENSIFIED ON.
          FORMAT COLOR OFF.
          PERFORM header.
        ENDIF.
        ADD va_begbal TO total_begbal.
        ADD va_debet  TO total_debet.
        ADD va_credit TO total_credit.
        ADD va_endbal TO total_endbal.
        CLEAR: va_begbal, va_debet, va_credit.
      ENDIF.
    ENDAT.
    CLEAR: wa_hkont2.
  ENDLOOP.
  WRITE: /    sy-uline(128).
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 3.
  WRITE: /    sy-vline.
  c1 = 1.
  c1 = c1 + 1.
  WRITE AT c1(w1) ' Total'. c1 = c1 + w1.
  c1 = c1 + 1.
  c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE:    total_begbal CURRENCY 'IDR',
            sy-vline NO-GAP, total_debet CURRENCY 'IDR' NO-GAP,
            sy-vline NO-GAP, total_credit CURRENCY 'IDR' NO-GAP,
            sy-vline, total_endbal CURRENCY 'IDR',
            sy-vline.
  WRITE: /    sy-uline(128).

  SKIP 1.
  FORMAT INTENSIFIED ON.
  CLEAR: total_begbal, total_debet, total_credit, total_endbal.
ENDFORM.                    " CETAK_RADIO3

*&---------------------------------------------------------------------*
*&      Form  CETAK_RADIO2_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_radio2_detail.
  PERFORM header2.
  CLEAR: wa_budat1.
  SORT i_budat1 BY hkont belnr.
  LOOP AT i_budat1 INTO wa_budat1
    WHERE budat EQ va_budat AND
          hkont EQ wa_budat-hkont.
    MOVE wa_budat1-sgtxt TO va_sgtxt.
    MOVE wa_budat1-belnr TO va_belnr.
    MOVE wa_budat1-gsber TO va_gsber1.
    MOVE wa_budat1-blart TO va_blart.
    MOVE wa_budat1-xblnr TO va_xblnr.
    MOVE wa_budat1-gjahr TO va_gjahr.
    IF wa_budat1-waers NE 'IDR'.
      MOVE wa_budat1-waers TO va_waers.
    ELSE.
      MOVE space TO va_waers.
    ENDIF.
    ADD wa_budat1-debet  TO total_debet.
    ADD wa_budat1-credit TO total_credit.
    ADD wa_budat1-debet  TO va_debet.
    ADD wa_budat1-credit TO va_credit.
    ADD wa_budat1-debet1 TO va_debet1.
    ADD wa_budat1-credit1 TO va_credit1.

    AT END OF belnr.
      IF zebra1 = 0.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR 2.
        zebra1 = 1.
      ELSE.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR 1.
        zebra1 = 0.
      ENDIF.

      WRITE: /   sy-vline NO-GAP, wa_budat1-budat NO-GAP,
                 sy-vline NO-GAP, va_belnr HOTSPOT NO-GAP,
                 sy-vline NO-GAP, va_gsber1 NO-GAP,
                 sy-vline, va_blart,
                 sy-vline NO-GAP, va_xblnr NO-GAP,
                 sy-vline NO-GAP, va_sgtxt NO-GAP,
                 sy-vline, 'IDR',
                 sy-vline, 92  va_debet CURRENCY 'IDR' NO-GAP,
                 sy-vline, 113 va_credit CURRENCY 'IDR' NO-GAP,
                 sy-vline, va_waers,
                 sy-vline NO-GAP, va_debet1 CURRENCY va_waers NO-GAP,
                 sy-vline NO-GAP, va_credit1 CURRENCY va_waers NO-GAP,
                 sy-vline.

      HIDE: va_gjahr.

      IF sy-linno EQ 59.
        WRITE: / sy-uline(169).
        FORMAT INTENSIFIED ON.
        FORMAT COLOR OFF.
        PERFORM header2.
      ENDIF.
      CLEAR: va_debet, va_credit, va_debet1, va_credit1.
    ENDAT.
    CLEAR: wa_budat1.
  ENDLOOP.

  va_endbal = va_begbal1 + total_debet - total_credit.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 3.
  WRITE: /    sy-uline(169).
  WRITE: /    sy-vline, ' Total',
          87  sy-vline NO-GAP, total_debet CURRENCY 'IDR' NO-GAP,
              sy-vline NO-GAP, total_credit CURRENCY 'IDR' NO-GAP,
              sy-vline,
          135 sy-vline,
          152 sy-vline,
          169 sy-vline.
  WRITE: /    sy-uline(169).
  SKIP 1.
  zebra1 = 0.
  FORMAT INTENSIFIED ON.
  CLEAR: total_begbal, total_debet, total_credit, total_endbal.
ENDFORM.                    " CETAK_RADIO2_DETAIL

*&---------------------------------------------------------------------*
*&      Form  CETAK_RADIO3_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_radio3_detail.
  PERFORM header1.

  CLEAR: wa_glt0, va_begbal.
  CASE 'X'.
    WHEN loccurr.
      PERFORM f_calc_begbal1 USING 'LOCCURR' va_hkont tgsbt-gsber
                             CHANGING va_begbal.
    WHEN doccurr.
      PERFORM f_calc_begbal1 USING 'DOCCURR' va_hkont tgsbt-gsber
                             CHANGING va_begbal.
  ENDCASE.

  FORMAT INTENSIFIED OFF.
  FORMAT COLOR 3.

* Revisi perhitungan dmbtr 20/02/2007
  READ TABLE t_dmbtr WITH KEY hkont = va_hkont.
  IF sy-subrc EQ 0.
    va_dmbtr = t_dmbtr-dmbtr.
  ELSE.
    CLEAR: va_dmbtr.
  ENDIF.
* End revisi

  va_begbal = va_begbal + va_dmbtr.
  WRITE: /    sy-vline, 'Beginning Balance'.
  IF va_begbal GE 0.
    WRITE:  87  sy-vline, 88 va_begbal CURRENCY 'IDR',
            108 sy-vline.
  ELSE.
    va_begbal = va_begbal * -1.
    WRITE:  87  sy-vline,
            108 sy-vline, 109 va_begbal CURRENCY 'IDR'.
    va_begbal = va_begbal * -1.
  ENDIF.
  va_begbal1 = va_begbal.
  WRITE:  129 sy-vline,
          135 sy-vline,
          152 sy-vline,
          169 sy-vline.
  WRITE: /    sy-uline(169).

  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.

  CLEAR: wa_hkont.
  SORT i_hkont BY bukrs hkont gsber budat belnr.
  LOOP AT i_hkont INTO wa_hkont
    WHERE hkont EQ va_hkont AND
          gsber EQ tgsbt-gsber.
    IF wa_hkont-debet  NE 0 OR
       wa_hkont-credit NE 0.
      MOVE wa_hkont-budat TO va_budat.
      MOVE wa_hkont-sgtxt TO va_sgtxt.
      MOVE wa_hkont-belnr TO va_belnr.
      MOVE wa_hkont-blart TO va_blart.
      MOVE wa_hkont-xblnr TO va_xblnr.
      MOVE wa_hkont-gsber TO va_gsber1.
      IF wa_hkont-waers NE 'IDR'.
        MOVE wa_hkont-waers TO va_waers.
      ELSE.
        MOVE space TO va_waers.
      ENDIF.
      MOVE wa_hkont-gjahr TO va_gjahr.
      ADD wa_hkont-debet  TO total_debet.
      ADD wa_hkont-credit TO total_credit.
      ADD wa_hkont-debet  TO va_debet.
      ADD wa_hkont-credit TO va_credit.
      ADD wa_hkont-debet1 TO va_debet1.
      ADD wa_hkont-credit1 TO va_credit1.

      AT END OF belnr.
        IF zebra1 = 0.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 2.
          zebra1 = 1.
        ELSE.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 1.
          zebra1 = 0.
        ENDIF.

        WRITE: / sy-vline NO-GAP, va_budat NO-GAP,
                 sy-vline NO-GAP, va_belnr HOTSPOT NO-GAP,
                 sy-vline NO-GAP, va_gsber1 NO-GAP,
                 sy-vline, va_blart,
                 sy-vline NO-GAP, va_xblnr NO-GAP,
                 sy-vline NO-GAP, va_sgtxt NO-GAP,
                 sy-vline, 'IDR',
                 sy-vline, 92 va_debet CURRENCY 'IDR' NO-GAP,
                 sy-vline, 113 va_credit CURRENCY 'IDR' NO-GAP,
                 sy-vline, va_waers,
                 sy-vline NO-GAP, va_debet1 CURRENCY va_waers NO-GAP,
                 sy-vline NO-GAP, va_credit1 CURRENCY va_waers NO-GAP,
                 sy-vline.

        HIDE: va_gjahr.

        IF sy-linno EQ 59.
          WRITE: / sy-uline(169).
          FORMAT INTENSIFIED ON.
          FORMAT COLOR OFF.
          PERFORM header1.
        ENDIF.
        CLEAR: va_debet, va_credit, va_debet1, va_credit1.
      ENDAT.
    ENDIF.
    CLEAR: wa_hkont.
  ENDLOOP.

  va_endbal = va_begbal + total_debet - total_credit.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 3.
  WRITE: /    sy-uline(169).
  WRITE: /    sy-vline, ' Total',
          87  sy-vline NO-GAP, total_debet CURRENCY 'IDR' NO-GAP,
              sy-vline NO-GAP, total_credit CURRENCY 'IDR' NO-GAP,
              sy-vline,
          135 sy-vline,
          152 sy-vline,
          169 sy-vline.
  WRITE: /    sy-uline(169).

  FORMAT INTENSIFIED OFF.
  WRITE: /    sy-vline, 'Ending Balance'.
  IF va_endbal GE 0.
    WRITE:  87  sy-vline, 88 va_endbal CURRENCY 'IDR',
            108 sy-vline.
  ELSE.
    va_endbal = va_endbal * -1.
    WRITE:  87  sy-vline,
            108 sy-vline, va_endbal CURRENCY 'IDR'.
  ENDIF.
  WRITE:  129 sy-vline,
          135 sy-vline,
          152 sy-vline,
          169 sy-vline.
  WRITE: /    sy-uline(169).
  SKIP 1.
  FORMAT INTENSIFIED ON.
  CLEAR: va_begbal, total_debet, total_credit, va_endbal.
ENDFORM.                    " CETAK_RADIO3_DETAIL

*&---------------------------------------------------------------------*
*&      Form  CETAK_RADIO4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_radio4.
  CLEAR: wa_vbund.
  SORT i_vbund BY bukrs hkont vbund.
  LOOP AT i_vbund INTO wa_vbund.

    MOVE wa_vbund-vbund TO va_vbund.
    MOVE wa_vbund-waers TO va_waers.
    MOVE wa_vbund-name1 TO va_name1.
    ADD wa_vbund-debet  TO va_debet.
    ADD wa_vbund-credit TO va_credit.

    IF p_filenm NE space.
      PERFORM move_outpl4.
    ENDIF.

    AT NEW hkont.
      CLEAR: wa_glt0, va_begbal.
      CASE 'X'.
        WHEN loccurr.
          PERFORM f_calc_begbal USING 'LOCCURR' wa_vbund-hkont
                                CHANGING va_begbal.
        WHEN doccurr.
          PERFORM f_calc_begbal USING 'DOCCURR' wa_vbund-hkont
                                CHANGING va_begbal.
      ENDCASE.

      IF sw = 0.
        sw = 1.
        MOVE va_begbal TO va_begbal1.
      ELSE.
        WRITE: /    sy-uline(86).
        FORMAT INTENSIFIED ON.
        FORMAT COLOR 3.
        WRITE: /    sy-vline.
        c1 = 1.
        c1 = c1 + 1.
        WRITE AT c1(w1) ' Total'. c1 = c1 + w1.
        c1 = c1 + 1.
        c1 = c1 + w2.
        WRITE AT c1(1) sy-vline. c1 = c1 + 1.
        WRITE:              43 total_debet CURRENCY 'IDR',
               63 sy-vline, total_credit CURRENCY 'IDR',
                  sy-vline.
        WRITE: /    sy-uline(86).

        va_endbal = va_begbal1 + total_debet - total_credit.
        MOVE va_begbal TO va_begbal1.

        FORMAT INTENSIFIED OFF.
        WRITE: /    sy-vline, 'Ending Balance'.
        IF va_endbal GE 0.
          WRITE:  40  sy-vline, 43 va_endbal CURRENCY 'IDR',
                  63  sy-vline.
        ELSE.
          WRITE:  40  sy-vline,
                  63  sy-vline, va_endbal CURRENCY 'IDR'.
        ENDIF.
        WRITE:  86 sy-vline.
        WRITE: /    sy-uline(86).
        SKIP 1.
        FORMAT INTENSIFIED ON.
        CLEAR: total_begbal, total_debet, total_credit, total_endbal.
      ENDIF.

      FORMAT COLOR OFF.
      FORMAT INTENSIFIED ON.
      zebra1 = 0.
      MOVE wa_vbund-hkont TO va_hkont.
      PERFORM header3.

      FORMAT INTENSIFIED OFF.
      FORMAT COLOR 3.

* Revisi perhitungan dmbtr 20/02/2007
      READ TABLE t_dmbtr WITH KEY hkont = wa_vbund-hkont.
      IF sy-subrc EQ 0.
        va_dmbtr = t_dmbtr-dmbtr.
      ELSE.
        CLEAR: va_dmbtr.
      ENDIF.
* End revisi

      va_begbal = va_begbal + va_dmbtr.
      WRITE: /    sy-vline, 'Beginning Balance'.
      IF va_begbal GE 0.
        WRITE:  40  sy-vline, 43 va_begbal CURRENCY 'IDR',
                63  sy-vline.
      ELSE.
        WRITE:  40  sy-vline,
                63  sy-vline, va_begbal CURRENCY 'IDR'.
      ENDIF.
      va_begbal1 = va_begbal.
      WRITE:  86  sy-vline.
      WRITE: / sy-uline(86).

      FORMAT INTENSIFIED ON.
      FORMAT COLOR 1.
    ENDAT.

    AT END OF vbund.
      IF va_begbal NE 0 OR
         va_debet  NE 0 OR
         va_credit NE 0.
        IF zebra1 = 0.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 2.
          zebra1 = 1.
        ELSE.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 1.
          zebra1 = 0.
        ENDIF.

        va_endbal = va_begbal + va_debet - va_credit.

        WRITE: /    sy-vline, va_name1 HOTSPOT,
                    sy-vline, 'IDR',
                    sy-vline, 47 va_debet CURRENCY 'IDR' NO-GAP,
                    sy-vline, 70 va_credit CURRENCY 'IDR' NO-GAP,
                    sy-vline.
        HIDE: va_hkont.

        IF sy-linno EQ 59.
          WRITE: / sy-uline(86).
          FORMAT INTENSIFIED ON.
          FORMAT COLOR OFF.
          PERFORM header3.
        ENDIF.

        ADD va_debet  TO total_debet.
        ADD va_credit TO total_credit.
        CLEAR: va_debet, va_credit.
      ENDIF.
    ENDAT.
    CLEAR: wa_vbund.
  ENDLOOP.
  WRITE: /    sy-uline(86).
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 3.
  WRITE: /    sy-vline.
  c1 = 1.
  c1 = c1 + 1.
  WRITE AT c1(w1) ' Total'. c1 = c1 + w1.
  c1 = c1 + 1.
  c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE:              43 total_debet CURRENCY 'IDR',
        63  sy-vline, total_credit CURRENCY 'IDR',
            sy-vline.
  WRITE: /    sy-uline(86).

  va_endbal = va_begbal1 + total_debet - total_credit.
  FORMAT INTENSIFIED OFF.
  WRITE: /    sy-vline, 'Ending Balance'.
  IF va_endbal GE 0.
    WRITE:  40  sy-vline, 43 va_endbal CURRENCY 'IDR',
            63  sy-vline.
  ELSE.
    WRITE:  40  sy-vline,
            63  sy-vline, va_endbal CURRENCY 'IDR'.
  ENDIF.
  WRITE:  86 sy-vline.
  WRITE: /    sy-uline(86).
  SKIP 1.
  FORMAT INTENSIFIED ON.
  CLEAR: total_begbal, total_debet, total_credit, total_endbal.
ENDFORM.                    " CETAK_RADIO4

*&---------------------------------------------------------------------*
*&      Form  CETAK_RADIO5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_radio5.
  CLEAR: wa_kostl.
  SORT i_kostl BY bukrs hkont kostl.
  LOOP AT i_kostl INTO wa_kostl.

    MOVE wa_kostl-kostl TO va_kostl.
    MOVE wa_kostl-waers TO va_waers.
    MOVE wa_kostl-ltext TO va_ltext.
    ADD wa_kostl-debet  TO va_debet.
    ADD wa_kostl-credit TO va_credit.

    IF p_filenm NE space.
      PERFORM move_outpl5.
    ENDIF.

    AT NEW hkont.
      CLEAR: wa_glt0, va_begbal.
      CASE 'X'.
        WHEN loccurr.
          PERFORM f_calc_begbal USING 'LOCCURR' wa_kostl-hkont
                                CHANGING va_begbal.
        WHEN doccurr.
          PERFORM f_calc_begbal USING 'DOCCURR' wa_kostl-hkont
                                CHANGING va_begbal.
      ENDCASE.

      IF sw = 0.
        sw = 1.
        MOVE va_begbal TO va_begbal1.
      ELSE.
        WRITE: /    sy-uline(86).
        FORMAT INTENSIFIED ON.
        FORMAT COLOR 3.
        WRITE: /    sy-vline.
        c1 = 1.
        c1 = c1 + 1.
        WRITE AT c1(w1) ' Total'. c1 = c1 + w1.
        c1 = c1 + 1.
        c1 = c1 + w2.
        WRITE AT c1(1) sy-vline. c1 = c1 + 1.
        WRITE:              43 total_debet CURRENCY 'IDR' NO-GAP,
                  sy-vline, 66 total_credit CURRENCY 'IDR' NO-GAP,
                  sy-vline.
        WRITE: /    sy-uline(86).

        va_endbal = va_begbal1 + total_debet - total_credit.
        MOVE va_begbal TO va_begbal1.

        FORMAT INTENSIFIED OFF.
        WRITE: /    sy-vline, 'Ending Balance'.
        IF va_endbal GE 0.
          WRITE:  40  sy-vline, 43 va_endbal CURRENCY 'IDR',
                  63  sy-vline.
        ELSE.
          WRITE:  40  sy-vline,
                  63  sy-vline, va_endbal CURRENCY 'IDR'.
        ENDIF.
        WRITE:  86 sy-vline.
        WRITE: /    sy-uline(86).
        SKIP 1.
        FORMAT INTENSIFIED ON.
        CLEAR: total_begbal, total_debet, total_credit, total_endbal.
      ENDIF.

      FORMAT COLOR OFF.
      FORMAT INTENSIFIED ON.
      zebra1 = 0.
      MOVE wa_kostl-hkont TO va_hkont.
      PERFORM header5.

      FORMAT INTENSIFIED OFF.
      FORMAT COLOR 3.

* Revisi perhitungan dmbtr 20/02/2007
      READ TABLE t_dmbtr WITH KEY hkont = wa_kostl-hkont.
      IF sy-subrc EQ 0.
        va_dmbtr = t_dmbtr-dmbtr.
      ELSE.
        CLEAR: va_dmbtr.
      ENDIF.
* End revisi

      va_begbal = va_begbal + va_dmbtr.
      WRITE: /    sy-vline, 'Beginning Balance'.
      IF va_begbal GE 0.
        WRITE:  40  sy-vline, 43 va_begbal CURRENCY 'IDR',
                63  sy-vline.
      ELSE.
        WRITE:  40  sy-vline,
                63  sy-vline, va_begbal CURRENCY 'IDR'.
      ENDIF.
      va_begbal1 = va_begbal.
      WRITE:  86  sy-vline.
      WRITE: / sy-uline(86).

      FORMAT INTENSIFIED ON.
      FORMAT COLOR 1.
    ENDAT.

    AT END OF kostl.
      IF va_begbal NE 0 OR
         va_debet  NE 0 OR
         va_credit NE 0.
        IF zebra1 = 0.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 2.
          zebra1 = 1.
        ELSE.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 1.
          zebra1 = 0.
        ENDIF.

        va_endbal = va_begbal + va_debet - va_credit.

        WRITE: /    sy-vline, va_ltext HOTSPOT,
                    sy-vline, 'IDR',
                    sy-vline, 47 va_debet CURRENCY 'IDR' NO-GAP,
                    sy-vline, 70 va_credit CURRENCY 'IDR' NO-GAP,
                    sy-vline.
        HIDE: va_hkont.

        IF sy-linno EQ 59.
          WRITE: / sy-uline(86).
          FORMAT INTENSIFIED ON.
          FORMAT COLOR OFF.
          PERFORM header5.
        ENDIF.

        ADD va_debet  TO total_debet.
        ADD va_credit TO total_credit.
        CLEAR: va_debet, va_credit.
      ENDIF.
    ENDAT.
    CLEAR: wa_kostl.
  ENDLOOP.
  WRITE: /    sy-uline(86).
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 3.
  WRITE: /    sy-vline.
  c1 = 1.
  c1 = c1 + 1.
  WRITE AT c1(w1) ' Total'. c1 = c1 + w1.
  c1 = c1 + 1.
  c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE:              43 total_debet CURRENCY 'IDR' NO-GAP,
            sy-vline, 66 total_credit CURRENCY 'IDR' NO-GAP,
            sy-vline.
  WRITE: /    sy-uline(86).

  va_endbal = va_begbal1 + total_debet - total_credit.
  FORMAT INTENSIFIED OFF.
  WRITE: /    sy-vline, 'Ending Balance'.
  IF va_endbal GE 0.
    WRITE:  40  sy-vline, 43 va_endbal CURRENCY 'IDR',
            63  sy-vline.
  ELSE.
    WRITE:  40  sy-vline,
            63  sy-vline, va_endbal CURRENCY 'IDR'.
  ENDIF.
  WRITE:  86 sy-vline.
  WRITE: /    sy-uline(86).
  SKIP 1.
  FORMAT INTENSIFIED ON.
  CLEAR: total_begbal, total_debet, total_credit, total_endbal.
ENDFORM.                    " CETAK_RADIO5

*&---------------------------------------------------------------------*
*&      Form  CETAK_RADIO6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_radio6.
  CLEAR: wa_prctr.
  SORT i_prctr BY bukrs hkont prctr.
  LOOP AT i_prctr INTO wa_prctr.

    MOVE wa_prctr-prctr TO va_prctr.
    MOVE wa_prctr-waers TO va_waers.
    MOVE wa_prctr-ltext TO va_ltext.
    ADD wa_prctr-debet  TO va_debet.
    ADD wa_prctr-credit TO va_credit.

    IF p_filenm NE space.
      PERFORM move_outpl6.
    ENDIF.

    AT NEW hkont.
      CLEAR: wa_glt0, va_begbal.
      CASE 'X'.
        WHEN loccurr.
          PERFORM f_calc_begbal USING 'LOCCURR' wa_prctr-hkont
                                CHANGING va_begbal.
        WHEN doccurr.
          PERFORM f_calc_begbal USING 'DOCCURR' wa_prctr-hkont
                                CHANGING va_begbal.
      ENDCASE.

      IF sw = 0.
        sw = 1.
        MOVE va_begbal TO va_begbal1.
      ELSE.
        WRITE: /    sy-uline(86).
        FORMAT INTENSIFIED ON.
        FORMAT COLOR 3.
        WRITE: /    sy-vline.
        c1 = 1.
        c1 = c1 + 1.
        WRITE AT c1(w1) ' Total'. c1 = c1 + w1.
        c1 = c1 + 1.
        c1 = c1 + w2.
        WRITE AT c1(1) sy-vline. c1 = c1 + 1.
        WRITE:              43 total_debet CURRENCY 'IDR' NO-GAP,
                  sy-vline, 66 total_credit CURRENCY 'IDR' NO-GAP,
                  sy-vline.
        WRITE: /    sy-uline(86).

        va_endbal = va_begbal1 + total_debet - total_credit.
        MOVE va_begbal TO va_begbal1.

        FORMAT INTENSIFIED OFF.
        WRITE: /    sy-vline, 'Ending Balance'.
        IF va_endbal GE 0.
          WRITE:  40  sy-vline, 43 va_endbal CURRENCY 'IDR',
                  63  sy-vline.
        ELSE.
          WRITE:  40  sy-vline,
                  63  sy-vline, va_endbal CURRENCY 'IDR'.
        ENDIF.
        WRITE:  86 sy-vline.
        WRITE: /    sy-uline(86).
        SKIP 1.
        FORMAT INTENSIFIED ON.
        CLEAR: total_begbal, total_debet, total_credit, total_endbal.
      ENDIF.

      FORMAT COLOR OFF.
      FORMAT INTENSIFIED ON.
      zebra1 = 0.
      MOVE wa_prctr-hkont TO va_hkont.
      PERFORM header7.

      FORMAT INTENSIFIED OFF.
      FORMAT COLOR 3.

* Revisi perhitungan dmbtr 20/02/2007
      READ TABLE t_dmbtr WITH KEY hkont = wa_prctr-hkont.
      IF sy-subrc EQ 0.
        va_dmbtr = t_dmbtr-dmbtr.
      ELSE.
        CLEAR: va_dmbtr.
      ENDIF.
* End revisi

      va_begbal = va_begbal + va_dmbtr.
      WRITE: /    sy-vline, 'Beginning Balance'.
      IF va_begbal GE 0.
        WRITE:  40  sy-vline, 43 va_begbal CURRENCY 'IDR',
                63  sy-vline.
      ELSE.
        WRITE:  40  sy-vline,
                63  sy-vline, va_begbal CURRENCY 'IDR'.
      ENDIF.
      va_begbal1 = va_begbal.
      WRITE:  86  sy-vline.
      WRITE: / sy-uline(86).

      FORMAT INTENSIFIED ON.
      FORMAT COLOR 1.
    ENDAT.

    AT END OF prctr.
      MOVE wa_prctr-prctr TO va_prctr.
      IF va_begbal NE 0 OR
         va_debet  NE 0 OR
         va_credit NE 0.
        IF zebra1 = 0.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 2.
          zebra1 = 1.
        ELSE.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 1.
          zebra1 = 0.
        ENDIF.

        WRITE: /    sy-vline, va_ltext HOTSPOT,
                    sy-vline, 'IDR',
                    sy-vline, 47 va_debet CURRENCY 'IDR' NO-GAP,
                    sy-vline, 70 va_credit CURRENCY 'IDR' NO-GAP,
                    sy-vline.
        HIDE: va_hkont, va_prctr.

        IF sy-linno EQ 59.
          WRITE: / sy-uline(86).
          FORMAT INTENSIFIED ON.
          FORMAT COLOR OFF.
          PERFORM header7.
        ENDIF.

        ADD va_debet  TO total_debet.
        ADD va_credit TO total_credit.
        CLEAR: va_debet, va_credit.
      ENDIF.
    ENDAT.
    CLEAR: wa_prctr.
  ENDLOOP.
  WRITE: /    sy-uline(86).
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 3.
  WRITE: /    sy-vline.
  c1 = 1.
  c1 = c1 + 1.
  WRITE AT c1(w1) ' Total'. c1 = c1 + w1.
  c1 = c1 + 1.
  c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE:              43 total_debet CURRENCY 'IDR' NO-GAP,
            sy-vline, 66 total_credit CURRENCY 'IDR' NO-GAP,
            sy-vline.
  WRITE: /    sy-uline(86).

  va_endbal = va_begbal1 + total_debet - total_credit.
  FORMAT INTENSIFIED OFF.
  WRITE: /    sy-vline, 'Ending Balance'.
  IF va_endbal GE 0.
    WRITE:  40  sy-vline, 43 va_endbal CURRENCY 'IDR',
            63  sy-vline.
  ELSE.
    WRITE:  40  sy-vline,
            63  sy-vline, va_endbal CURRENCY 'IDR'.
  ENDIF.
  WRITE:  86 sy-vline.
  WRITE: /    sy-uline(86).
  SKIP 1.
  FORMAT INTENSIFIED ON.
  CLEAR: total_begbal, total_debet, total_credit, total_endbal.
ENDFORM.                    " CETAK_RADIO6

*&---------------------------------------------------------------------*
*&      Form  CETAK_RADIO4_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_radio4_detail.
  PERFORM header4.
  CLEAR: wa_vbund.
  SORT i_vbund BY bukrs hkont vbund budat belnr.
  LOOP AT i_vbund INTO wa_vbund
    WHERE hkont EQ va_hkont AND
          vbund EQ t880-rcomp.
    IF wa_vbund-debet  NE 0 OR
       wa_vbund-credit NE 0.
      MOVE wa_vbund-budat TO va_budat.
      MOVE wa_vbund-sgtxt TO va_sgtxt.
      MOVE wa_vbund-belnr TO va_belnr.
      MOVE wa_vbund-blart TO va_blart.
      MOVE wa_vbund-xblnr TO va_xblnr.
      IF wa_vbund-waers NE 'IDR'.
        MOVE wa_vbund-waers TO va_waers.
      ELSE.
        MOVE space TO va_waers.
      ENDIF.
      MOVE wa_vbund-gjahr TO va_gjahr.
      ADD wa_vbund-debet  TO total_debet.
      ADD wa_vbund-credit TO total_credit.
      ADD wa_vbund-debet  TO va_debet.
      ADD wa_vbund-credit TO va_credit.
      ADD wa_vbund-debet1 TO va_debet1.
      ADD wa_vbund-credit1 TO va_credit1.

      AT END OF belnr.
        IF zebra1 = 0.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 2.
          zebra1 = 1.
        ELSE.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 1.
          zebra1 = 0.
        ENDIF.

        WRITE: / sy-vline NO-GAP, va_budat NO-GAP,
                 sy-vline NO-GAP, va_belnr HOTSPOT NO-GAP,
                 sy-vline, va_blart,
                 sy-vline NO-GAP, va_xblnr NO-GAP,
                 sy-vline NO-GAP, va_sgtxt NO-GAP,
                 sy-vline, 'IDR',
                 sy-vline, 87 va_debet CURRENCY 'IDR' NO-GAP,
                 sy-vline, 108 va_credit CURRENCY 'IDR' NO-GAP,
                 sy-vline, va_waers,
                 sy-vline NO-GAP, va_debet1 CURRENCY va_waers NO-GAP,
                 sy-vline NO-GAP, va_credit1 CURRENCY va_waers NO-GAP,
                 sy-vline.

        HIDE: va_gjahr.

        IF sy-linno EQ 59.
          WRITE: / sy-uline(164).
          FORMAT INTENSIFIED ON.
          FORMAT COLOR OFF.
          PERFORM header4.
        ENDIF.
        CLEAR: va_debet, va_credit, va_debet1, va_credit1.
      ENDAT.
    ENDIF.
    CLEAR: wa_vbund.
  ENDLOOP.

  FORMAT INTENSIFIED ON.
  FORMAT COLOR 3.
  WRITE: /    sy-uline(164).
  WRITE: /    sy-vline, ' Total',
          82  sy-vline NO-GAP, total_debet CURRENCY 'IDR' NO-GAP,
              sy-vline NO-GAP, total_credit CURRENCY 'IDR' NO-GAP,
              sy-vline,
          130 sy-vline,
          147 sy-vline,
          164 sy-vline.
  WRITE: /    sy-uline(164).
  SKIP 1.
  CLEAR: total_debet, total_credit.
ENDFORM.                    " CETAK_RADIO4_DETAIL

*&---------------------------------------------------------------------*
*&      Form  CETAK_RADIO5_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_radio5_detail.
  PERFORM header6.
  CLEAR: wa_kostl.
  SORT i_kostl BY bukrs hkont kostl budat belnr.
  LOOP AT i_kostl INTO wa_kostl
    WHERE hkont EQ va_hkont AND
          kostl EQ cskt-kostl.

    IF wa_kostl-debet  NE 0 OR
       wa_kostl-credit NE 0.
      MOVE wa_kostl-budat TO va_budat.
      MOVE wa_kostl-sgtxt TO va_sgtxt.
      MOVE wa_kostl-belnr TO va_belnr.
      MOVE wa_kostl-blart TO va_blart.
      MOVE wa_kostl-xblnr TO va_xblnr.
      IF wa_kostl-waers NE 'IDR'.
        MOVE wa_kostl-waers TO va_waers.
      ELSE.
        MOVE space TO va_waers.
      ENDIF.
      MOVE wa_kostl-gjahr TO va_gjahr.
      ADD wa_kostl-debet  TO total_debet.
      ADD wa_kostl-credit TO total_credit.
      ADD wa_kostl-debet  TO va_debet.
      ADD wa_kostl-credit TO va_credit.
      ADD wa_kostl-debet1 TO va_debet1.
      ADD wa_kostl-credit1 TO va_credit1.

      AT END OF belnr.
        IF zebra1 = 0.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 2.
          zebra1 = 1.
        ELSE.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 1.
          zebra1 = 0.
        ENDIF.

        WRITE: /   sy-vline NO-GAP, va_budat NO-GAP,
                   sy-vline NO-GAP, va_belnr HOTSPOT NO-GAP,
                   sy-vline, va_blart,
                   sy-vline NO-GAP, va_xblnr NO-GAP,
                   sy-vline NO-GAP, va_sgtxt NO-GAP,
                   sy-vline, 'IDR',
                   sy-vline, 87 va_debet CURRENCY 'IDR' NO-GAP,
                   sy-vline, 108 va_credit CURRENCY 'IDR' NO-GAP,
                   sy-vline, va_waers,
                   sy-vline NO-GAP, va_debet1 CURRENCY va_waers NO-GAP,
                   sy-vline NO-GAP, va_credit1 CURRENCY va_waers NO-GAP,
                   sy-vline.

        HIDE: va_gjahr.

        IF sy-linno EQ 59.
          WRITE: / sy-uline(138).
          FORMAT INTENSIFIED ON.
          FORMAT COLOR OFF.
          PERFORM header6.
        ENDIF.
        CLEAR: va_debet, va_credit.
      ENDAT.
    ENDIF.
    CLEAR: wa_kostl.
  ENDLOOP.

  va_endbal = va_begbal + total_debet - total_credit.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 3.
  WRITE: /    sy-uline(164).
  WRITE: /    sy-vline, ' Total',
          82  sy-vline NO-GAP, total_debet CURRENCY 'IDR' NO-GAP,
              sy-vline NO-GAP, total_credit CURRENCY 'IDR' NO-GAP,
              sy-vline,
          130 sy-vline,
          147 sy-vline,
          164 sy-vline.
  WRITE: /    sy-uline(164).
  SKIP 1.
  FORMAT INTENSIFIED ON.
  CLEAR: total_debet, total_credit.
ENDFORM.                    " CETAK_RADIO5_DETAIL

*&---------------------------------------------------------------------*
*&      Form  CETAK_RADIO6_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_radio6_detail.
  PERFORM header8.
  CLEAR: wa_prctr.
  SORT i_prctr BY bukrs hkont prctr budat belnr.
  LOOP AT i_prctr INTO wa_prctr
    WHERE hkont EQ va_hkont AND
          prctr EQ va_prctr.
    IF wa_prctr-debet  NE 0 OR
       wa_prctr-credit NE 0.
      MOVE wa_prctr-budat TO va_budat.
      MOVE wa_prctr-sgtxt TO va_sgtxt.
      MOVE wa_prctr-belnr TO va_belnr.
      MOVE wa_prctr-blart TO va_blart.
      MOVE wa_prctr-xblnr TO va_xblnr.
      IF wa_prctr-waers NE 'IDR'.
        MOVE wa_prctr-waers TO va_waers.
      ELSE.
        MOVE space TO va_waers.
      ENDIF.
      MOVE wa_prctr-gjahr TO va_gjahr.
      ADD wa_prctr-debet  TO total_debet.
      ADD wa_prctr-credit TO total_credit.
      ADD wa_prctr-debet  TO va_debet.
      ADD wa_prctr-credit TO va_credit.
      ADD wa_prctr-debet1 TO va_debet1.
      ADD wa_prctr-credit1 TO va_credit1.

      AT END OF belnr.
        IF zebra1 = 0.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 2.
          zebra1 = 1.
        ELSE.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 1.
          zebra1 = 0.
        ENDIF.

        WRITE: /   sy-vline NO-GAP, va_budat NO-GAP,
                   sy-vline NO-GAP, va_belnr HOTSPOT NO-GAP,
                   sy-vline, va_blart,
                   sy-vline NO-GAP, va_xblnr NO-GAP,
                   sy-vline NO-GAP, va_sgtxt NO-GAP,
                   sy-vline, 'IDR',
                   sy-vline, 87 va_debet CURRENCY 'IDR' NO-GAP,
                   sy-vline, 108 va_credit CURRENCY 'IDR' NO-GAP,
                   sy-vline, va_waers,
                   sy-vline NO-GAP, va_debet1 CURRENCY va_waers NO-GAP,
                   sy-vline NO-GAP, va_credit1 CURRENCY va_waers NO-GAP,
                   sy-vline.

        HIDE: va_gjahr.

        IF sy-linno EQ 59.
          WRITE: / sy-uline(138).
          FORMAT INTENSIFIED ON.
          FORMAT COLOR OFF.
          PERFORM header8.
        ENDIF.
        CLEAR: va_debet, va_credit, va_debet1, va_credit1.
      ENDAT.
    ENDIF.
    CLEAR: wa_prctr.
  ENDLOOP.

  va_endbal = va_begbal + total_debet - total_credit.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 3.
  WRITE: /    sy-uline(164).
  WRITE: /    sy-vline, ' Total',
          82  sy-vline NO-GAP, total_debet CURRENCY 'IDR' NO-GAP,
              sy-vline NO-GAP, total_credit CURRENCY 'IDR' NO-GAP,
              sy-vline,
          130 sy-vline,
          147 sy-vline,
          164 sy-vline.
  WRITE: /    sy-uline(164).
  SKIP 1.
  FORMAT INTENSIFIED ON.
  CLEAR: total_debet, total_credit.
ENDFORM.                    " CETAK_RADIO6_DETAIL

*&---------------------------------------------------------------------*
*&      Form  BULAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bulan.
  CASE bulan.
    WHEN '01'.
      CONCATENATE 'Januari' so_budat-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '02'.
      CONCATENATE 'Februari' so_budat-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '03'.
      CONCATENATE 'Maret' so_budat-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '04'.
      CONCATENATE 'April' so_budat-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '05'.
      CONCATENATE 'Mei' so_budat-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '06'.
      CONCATENATE 'Juni' so_budat-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '07'.
      CONCATENATE 'Juli' so_budat-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '08'.
      CONCATENATE 'Agustus' so_budat-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '09'.
      CONCATENATE 'September' so_budat-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '10'.
      CONCATENATE 'Oktober' so_budat-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '11'.
      CONCATENATE 'November' so_budat-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '12'.
      CONCATENATE 'Desember' so_budat-low+0(4) INTO va_period
        SEPARATED BY space.
  ENDCASE.

  CASE bulan1.
    WHEN '01'.
      CONCATENATE 'Januari' so_budat-high+0(4) INTO va_period1
        SEPARATED BY space.
    WHEN '02'.
      CONCATENATE 'Februari' so_budat-high+0(4) INTO va_period1
        SEPARATED BY space.
    WHEN '03'.
      CONCATENATE 'Maret' so_budat-high+0(4) INTO va_period1
        SEPARATED BY space.
    WHEN '04'.
      CONCATENATE 'April' so_budat-high+0(4) INTO va_period1
        SEPARATED BY space.
    WHEN '05'.
      CONCATENATE 'Mei' so_budat-high+0(4) INTO va_period1
        SEPARATED BY space.
    WHEN '06'.
      CONCATENATE 'Juni' so_budat-high+0(4) INTO va_period1
        SEPARATED BY space.
    WHEN '07'.
      CONCATENATE 'Juli' so_budat-high+0(4) INTO va_period1
        SEPARATED BY space.
    WHEN '08'.
      CONCATENATE 'Agustus' so_budat-high+0(4) INTO va_period1
        SEPARATED BY space.
    WHEN '09'.
      CONCATENATE 'September' so_budat-high+0(4) INTO va_period1
        SEPARATED BY space.
    WHEN '10'.
      CONCATENATE 'Oktober' so_budat-high+0(4) INTO va_period1
        SEPARATED BY space.
    WHEN '11'.
      CONCATENATE 'November' so_budat-high+0(4) INTO va_period1
        SEPARATED BY space.
    WHEN '12'.
      CONCATENATE 'Desember' so_budat-high+0(4) INTO va_period1
        SEPARATED BY space.
  ENDCASE.
ENDFORM.                    " BULAN

*&---------------------------------------------------------------------*
*&      Form  CEK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek.
*DATA L_GSBER LIKE BSID-GSBER.
*
*L_GSBER = SO_GSBER-LOW.
*
*IF L_GSBER EQ SPACE AND SO_GSBER-HIGH EQ SPACE.
*   L_GSBER = '*'.
*ELSEIF L_GSBER NE SPACE AND SO_GSBER-HIGH NE SPACE.
*   L_GSBER = '*'.
*ENDIF.
*
*    AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
*        ID 'GSBER' FIELD L_GSBER
*        ID 'ACTVT' FIELD '01'.
*        IF SY-SUBRC NE 0.
*           MESSAGE E002(ZZ) WITH
*           'You have no authorization for Sales Office' L_GSBER.
*        ENDIF.
  DATA : i_gsber TYPE tgsb-gsber OCCURS 0 WITH HEADER LINE.

  SELECT gsber INTO TABLE i_gsber
    FROM tgsb WHERE gsber IN so_gsber.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
           ID 'BUKRS' FIELD pa_bukrs
           ID 'ACTVT' FIELD '01'.
  IF sy-subrc NE 0.
    MESSAGE i002(zz) WITH
      'You have no authorization for Company Code' pa_bukrs.
    STOP.
  ENDIF.
  LOOP AT i_gsber.
    AUTHORITY-CHECK OBJECT 'F_BKPF_GSB'
             ID 'GSBER' FIELD i_gsber
             ID 'ACTVT' FIELD '01'.
    IF sy-subrc NE 0.
      MESSAGE i002(zz) WITH
        'You have no authorization for Business Area' i_gsber.
      STOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " CEK

*&---------------------------------------------------------------------*
*&      Form  move_outpl1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move_outpl1 USING fu_belnr fu_hkont.
*  MOVE wa_hkont-belnr  TO wa_outpl-belnr.
*  MOVE wa_hkont-budat  TO wa_outpl-budat.
*  MOVE wa_hkont-hkont  TO wa_outpl-hkont.
*  MOVE wa_hkont-debet  TO wa_outpl-debet.
*  MOVE wa_hkont-credit TO wa_outpl-credit.
*  MOVE wa_hkont-sgtxt  TO wa_outpl-sgtxt.
  MOVE-CORRESPONDING wa_hkont TO wa_outpl.

  READ TABLE gt_bkpf WITH KEY belnr = fu_belnr.
  IF sy-subrc EQ 0.
    IF cb_bktxt IS NOT INITIAL.
      wa_outpl-bktxt  = gt_bkpf-bktxt.
    ENDIF.
    IF cb_bldat IS NOT INITIAL.
      wa_outpl-bldat  = gt_bkpf-bldat.
    ENDIF.
  ENDIF.

  READ TABLE gt_bseg WITH KEY belnr = fu_belnr
                              hkont = fu_hkont.
  IF sy-subrc EQ 0.
    IF cb_vbund IS NOT INITIAL.
      wa_outpl-vbund  = gt_bseg-vbund.
    ENDIF.
    IF cb_zuonr IS NOT INITIAL.
      wa_outpl-zuonr  = gt_bseg-zuonr.
    ENDIF.
    IF cb_xref3 IS NOT INITIAL.
      wa_outpl-xref3  = gt_bseg-xref3.
    ENDIF.
    IF cb_rstgr IS NOT INITIAL.
      wa_outpl-rstgr  = gt_bseg-rstgr.
    ENDIF.
    IF cb_sgtxt IS NOT INITIAL.
      wa_outpl-zeile  = gt_bseg-sgtxt.
    ENDIF.
    IF cb_aufnr IS NOT INITIAL.
      wa_outpl-aufnr  = gt_bseg-aufnr.
    ENDIF.
    IF cb_prctr IS NOT INITIAL.
      wa_outpl-prctr  = gt_bseg-prctr.
    ENDIF.
    IF cb_kostl IS NOT INITIAL.
      wa_outpl-kostl  = gt_bseg-kostl.
    ENDIF.
    IF cb_fipex IS NOT INITIAL.
      wa_outpl-fipex  = gt_bseg-fipos.
    ENDIF.
    IF cb_augdt IS NOT INITIAL.
      wa_outpl-augdt  = gt_bseg-augdt.
    ENDIF.
    IF cb_statu IS NOT INITIAL.
      IF gt_bseg-xopvw IS NOT INITIAL AND
        gt_bseg-augdt IS NOT INITIAL.
        wa_outpl-statu = 'CLEARED'.
      ELSEIF gt_bseg-xopvw IS NOT INITIAL AND
        gt_bseg-augdt IS INITIAL.
        wa_outpl-statu = 'NOT CLEARED'.
      ELSE.
        wa_outpl-statu = 'LINE ITEM'.
      ENDIF.
    ENDIF.
  ENDIF.

  APPEND wa_outpl TO i_outpl.
  CLEAR wa_outpl.
*  CLEAR: wa_outpl-belnr, wa_outpl-budat, wa_outpl-hkont,
*         wa_outpl-debet, wa_outpl-credit, wa_outpl-sgtxt.
ENDFORM.                    " move_outpl1

*&---------------------------------------------------------------------*
*&      Form  move_outpl2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move_outpl2.
*  MOVE wa_budat-belnr  TO wa_outpl-belnr.
*  MOVE wa_budat-budat  TO wa_outpl-budat.
*  MOVE wa_budat-hkont  TO wa_outpl-hkont.
*  MOVE wa_budat-debet  TO wa_outpl-debet.
*  MOVE wa_budat-credit TO wa_outpl-credit.
*  MOVE wa_budat-sgtxt  TO wa_outpl-sgtxt.
  MOVE-CORRESPONDING wa_budat TO wa_outpl.
  APPEND wa_outpl TO i_outpl.
  CLEAR wa_outpl.
*  CLEAR: wa_outpl-belnr, wa_outpl-budat, wa_outpl-hkont,
*         wa_outpl-debet, wa_outpl-credit, wa_outpl-sgtxt.
ENDFORM.                    " move_outpl2

*&---------------------------------------------------------------------*
*&      Form  move_outpl3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move_outpl3.
*  MOVE wa_hkont2-belnr  TO wa_outpl-belnr.
*  MOVE wa_hkont2-budat  TO wa_outpl-budat.
*  MOVE wa_hkont2-hkont  TO wa_outpl-hkont.
*  MOVE wa_hkont2-debet  TO wa_outpl-debet.
*  MOVE wa_hkont2-credit TO wa_outpl-credit.
*  MOVE wa_hkont2-sgtxt  TO wa_outpl-sgtxt.
  MOVE-CORRESPONDING wa_hkont2 TO wa_outpl.
  APPEND wa_outpl TO i_outpl.
  CLEAR wa_outpl.
*  CLEAR: wa_outpl-belnr, wa_outpl-budat, wa_outpl-hkont,
*         wa_outpl-debet, wa_outpl-credit, wa_outpl-sgtxt.
ENDFORM.                    " move_outpl3

*&---------------------------------------------------------------------*
*&      Form  move_outpl4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move_outpl4.
*  MOVE wa_vbund-belnr  TO wa_outpl-belnr.
*  MOVE wa_vbund-budat  TO wa_outpl-budat.
*  MOVE wa_vbund-hkont  TO wa_outpl-hkont.
*  MOVE wa_vbund-debet  TO wa_outpl-debet.
*  MOVE wa_vbund-credit TO wa_outpl-credit.
*  MOVE wa_vbund-sgtxt  TO wa_outpl-sgtxt.
  MOVE-CORRESPONDING wa_vbund TO wa_outpl.
  APPEND wa_outpl TO i_outpl.
  CLEAR wa_outpl.
*  CLEAR: wa_outpl-belnr, wa_outpl-budat, wa_outpl-hkont,
*         wa_outpl-debet, wa_outpl-credit, wa_outpl-sgtxt.
ENDFORM.                    " move_outpl4

*&---------------------------------------------------------------------*
*&      Form  move_outpl5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move_outpl5.
*  MOVE wa_kostl-belnr  TO wa_outpl-belnr.
*  MOVE wa_kostl-budat  TO wa_outpl-budat.
*  MOVE wa_kostl-hkont  TO wa_outpl-hkont.
*  MOVE wa_kostl-debet  TO wa_outpl-debet.
*  MOVE wa_kostl-credit TO wa_outpl-credit.
*  MOVE wa_kostl-sgtxt  TO wa_outpl-sgtxt.
  MOVE-CORRESPONDING wa_kostl TO wa_outpl.
  APPEND wa_outpl TO i_outpl.
  CLEAR wa_outpl.
* CLEAR: wa_outpl-belnr, wa_outpl-budat, wa_outpl-hkont,
*         wa_outpl-debet, wa_outpl-credit, wa_outpl-sgtxt.
ENDFORM.                    " move_outpl5

*&---------------------------------------------------------------------*
*&      Form  move_outpl6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move_outpl6.
*  MOVE wa_prctr-belnr  TO wa_outpl-belnr.
*  MOVE wa_prctr-budat  TO wa_outpl-budat.
*  MOVE wa_prctr-hkont  TO wa_outpl-hkont.
*  MOVE wa_prctr-debet  TO wa_outpl-debet.
*  MOVE wa_prctr-credit TO wa_outpl-credit.
*  MOVE wa_prctr-sgtxt  TO wa_outpl-sgtxt.
  MOVE-CORRESPONDING wa_prctr TO wa_outpl.
  APPEND wa_outpl TO i_outpl.
  CLEAR wa_outpl.
*  CLEAR: wa_outpl-belnr, wa_outpl-budat, wa_outpl-hkont,
*         wa_outpl-debet, wa_outpl-credit, wa_outpl-sgtxt.
ENDFORM.                    " move_outpl6

*&---------------------------------------------------------------------*
*&      Form  download
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM download.
  SORT i_outpl BY belnr hkont.
  IF radio90 = 'X'.
    PERFORM f_download_dataset.
  ELSE.
    PERFORM f_download_local.
  ENDIF.
ENDFORM.                    " download

*&---------------------------------------------------------------------*
*&      Form  f_download_dataset
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download_dataset.

  DATA : BEGIN OF tabl OCCURS 10,
           line(200),
         END OF tabl.
  DATA : l_command(125) TYPE c.

*** Open Dataset
  OPEN DATASET p_filenm FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc = 0.
*     delete dataset p_filenm.
    MESSAGE i000(zf) WITH 'Download Gagal Karena File Sudah Ada'.
    EXIT.
*     delete dataset p_filenm.
*     open dataset p_filenm for appending in text mode.
  ELSE.
    OPEN DATASET p_filenm FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
  ENDIF.

*** Write Dataset
  LOOP AT i_outpl.
    MOVE-CORRESPONDING i_outpl TO i_dataset.
    WRITE i_outpl-debet TO i_dataset-debet CURRENCY i_dataset-waers.
    WRITE i_outpl-credit TO i_dataset-credit CURRENCY i_dataset-waers.
    TRANSFER i_dataset TO p_filenm.
  ENDLOOP.

*** Close Dataset
  CLOSE DATASET p_filenm.

  IF sy-opsys = 'AIX'.
    CLEAR l_command.
    CONCATENATE 'chmod 777' p_filenm INTO l_command SEPARATED BY ' '.
    CALL 'SYSTEM' ID 'COMMAND' FIELD l_command
                  ID 'TAB' FIELD tabl-*sys*.
  ENDIF.

ENDFORM.                    " f_download_dataset

*&---------------------------------------------------------------------*
*&      Form  f_get_filename
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_filename.

  DATA: v_repid LIKE sy-repid.
  v_repid = sy-repid.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = v_repid
      dynpro_number = sy-dynnr
      field_name    = 'P_FILENM'
    IMPORTING
      file_name     = p_filenm
    EXCEPTIONS
      OTHERS        = 1.

  IF sy-subrc <> 0.
    CLEAR p_filenm.
  ENDIF.

ENDFORM.                    " f_get_filename

*&---------------------------------------------------------------------*
*&      Form  f_download_local
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download_local.

  CLEAR i_local. REFRESH i_local.

  LOOP AT i_outpl.
    MOVE-CORRESPONDING i_outpl TO i_local.
    i_local-debet = i_outpl-debet * 100.
    i_local-credit = i_outpl-credit * 100.

*  WRITE i_outpl-debet to i_local-debet CURRENCY i_local-waers.
*  WRITE i_outpl-credit to i_local-credit CURRENCY i_local-waers.
    APPEND i_local.

    i_outpl-debet = i_outpl-debet * 100.
    i_outpl-credit = i_outpl-credit * 100.
    MODIFY i_outpl TRANSPORTING debet credit.
  ENDLOOP.

  PERFORM f_crt_dwnfield.

*Begin remark Unicode conversion - DEVK965554
*26.02.2020 - SOL_FELIX
*  CALL FUNCTION 'DOWNLOAD'
*     EXPORTING
*          filename = p_filenm
*          filetype = 'DBF'
*     IMPORTING
*          cancel = canc
*          filesize = size
*     TABLES
**        DATA_TAB = i_outpl
*          data_tab   = i_local
*          fieldnames = dwn_field
*     EXCEPTIONS
*          file_open_error  = 1
*          file_write_error = 2.
*End remark Unicode conversion - DEVK965554
*Begin insert Unicode conversion - DEVK965554
  DATA: lv_filename TYPE string.
  lv_filename = p_filenm.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = lv_filename
      filetype                = 'DBF'
      fieldnames              = dwn_field
    CHANGING
      data_tab                = i_outpl[]
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
*End insert Unicode conversion - DEVK965554

  CLEAR i_local. REFRESH i_local.

ENDFORM.                    " f_download_local

*&---------------------------------------------------------------------*
*&      Form  ADD_BEGBAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_begbal.
  ra_budat-low     = va_budat1.
  ra_budat-high    = va_budat3.
  ra_budat-sign    = 'I'.
  ra_budat-option  = 'BT'.
  APPEND ra_budat.

* BY DOCUMENT NUMBER, DOCUMENT DATE AND BUSINESS AREA
  IF radio1 EQ 'X' OR
     radio2 EQ 'X' OR
     radio3 EQ 'X'.
    IF radio10 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsis
          INTO CORRESPONDING FIELDS OF TABLE i_bsis1
          FOR ALL ENTRIES IN i_skat
          WHERE bukrs EQ pa_bukrs       AND
                hkont EQ i_skat-saknr   AND
                budat IN ra_budat       AND
                gsber IN so_gsber.

        SELECT *
          FROM bsas
          APPENDING  CORRESPONDING FIELDS OF TABLE i_bsis1
          FOR ALL ENTRIES IN i_skat
          WHERE bukrs EQ pa_bukrs       AND
                hkont EQ i_skat-saknr   AND
                budat IN ra_budat       AND
                augdt GE va_budat1      AND
                gsber IN so_gsber.
      ENDIF.
    ENDIF.

    IF radio11 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                           b~vkorg EQ pa_bukrs
                         JOIN kna1 AS c ON a~kunnr EQ c~kunnr
          INTO CORRESPONDING FIELDS OF TABLE i_kunnr1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~budat IN ra_budat       AND
                b~vwerk IN so_gsber       AND
                b~vwerk NE space          AND
                b~vtweg EQ '10'.

        SELECT *
          FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                           b~vkorg EQ pa_bukrs
                         JOIN kna1 AS c ON a~kunnr EQ c~kunnr
          APPENDING  CORRESPONDING FIELDS OF TABLE i_kunnr1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~budat IN ra_budat       AND
                a~augdt GE va_budat1      AND
                b~vwerk IN so_gsber       AND
                b~vwerk NE space          AND
                b~vtweg EQ '10'.
      ENDIF.
    ENDIF.

    IF radio12 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsik AS a JOIN lfa1 AS b ON a~lifnr EQ b~lifnr
          INTO CORRESPONDING FIELDS OF TABLE i_lifnr1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~gsber IN so_gsber       AND
                a~gsber NE space          AND
                a~budat IN ra_budat.

        SELECT *
          FROM bsak AS a JOIN lfa1 AS b ON a~lifnr EQ b~lifnr
          APPENDING CORRESPONDING FIELDS OF TABLE i_lifnr1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~gsber IN so_gsber       AND
                a~gsber NE space          AND
                a~budat IN ra_budat       AND
                a~augdt GE va_budat1.
      ENDIF.
    ENDIF.
  ENDIF.

* BY TRADING PARTNER
  IF radio4 EQ 'X'.
    IF radio10 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsis AS a JOIN t880 AS b ON a~vbund EQ b~rcomp
          INTO CORRESPONDING FIELDS OF TABLE i_bsis1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~budat IN ra_budat       AND
                a~vbund IN so_vbund.

        SELECT *
          FROM bsas AS a JOIN t880 AS b ON a~vbund EQ b~rcomp
          APPENDING  CORRESPONDING FIELDS OF TABLE i_bsis1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~budat IN ra_budat       AND
                a~augdt GE va_budat1      AND
                a~vbund IN so_vbund.
      ENDIF.
    ENDIF.

    IF radio11 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsid AS a JOIN t880 AS b ON a~vbund EQ b~rcomp
          INTO CORRESPONDING FIELDS OF TABLE i_kunnr1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~vbund IN so_vbund       AND
                a~budat IN ra_budat.

        SELECT *
          FROM bsad AS a JOIN t880 AS b ON a~vbund EQ b~rcomp
          APPENDING CORRESPONDING FIELDS OF TABLE i_kunnr1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~vbund IN so_vbund       AND
                a~budat IN ra_budat       AND
                a~augdt GE va_budat1.
      ENDIF.
    ENDIF.

    IF radio12 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsik AS a JOIN t880 AS b ON a~vbund EQ b~rcomp
          INTO CORRESPONDING FIELDS OF TABLE i_lifnr1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~vbund IN so_vbund       AND
                a~budat IN ra_budat.

        SELECT *
          FROM bsak AS a JOIN t880 AS b ON a~vbund EQ b~rcomp
          APPENDING CORRESPONDING FIELDS OF TABLE i_lifnr1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~vbund IN so_vbund       AND
                a~budat IN ra_budat       AND
                a~augdt GE va_budat1.
      ENDIF.
    ENDIF.
  ENDIF.

* BY COST CENTER
  IF radio5 EQ 'X'.
    IF radio10 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsis AS a JOIN cskt AS b ON a~kostl EQ b~kostl AND
                                           b~spras EQ 'EN'
          INTO CORRESPONDING FIELDS OF TABLE i_bsis1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~budat IN ra_budat       AND
                a~kostl IN so_kostl.

        SELECT *
          FROM bsas AS a JOIN cskt AS b ON a~kostl EQ b~kostl AND
                                           b~spras EQ 'EN'
          APPENDING  CORRESPONDING FIELDS OF TABLE i_bsis1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~budat IN ra_budat       AND
                a~augdt GE va_budat1      AND
                a~kostl IN so_kostl.
      ENDIF.
    ENDIF.

    IF radio11 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsid AS a JOIN cskt AS b ON a~kostl EQ b~kostl AND
                                           b~spras EQ 'EN'
          INTO CORRESPONDING FIELDS OF TABLE i_kunnr1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~kostl IN so_kostl       AND
                a~budat IN ra_budat.

        SELECT *
          FROM bsad AS a JOIN cskt AS b ON a~kostl EQ b~kostl AND
                                           b~spras EQ 'EN'
          APPENDING CORRESPONDING FIELDS OF TABLE i_kunnr1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~kostl IN so_kostl       AND
                a~budat IN ra_budat       AND
                a~augdt GE va_budat1.
      ENDIF.
    ENDIF.

    IF radio12 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsik AS a JOIN cskt AS b ON a~kostl EQ b~kostl AND
                                           b~spras EQ 'EN'
          INTO CORRESPONDING FIELDS OF TABLE i_lifnr1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~kostl IN so_kostl       AND
                a~budat IN ra_budat.

        SELECT *
          FROM bsak AS a JOIN cskt AS b ON a~kostl EQ b~kostl AND
                                           b~spras EQ 'EN'
          APPENDING CORRESPONDING FIELDS OF TABLE i_lifnr1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~kostl IN so_kostl       AND
                a~budat IN ra_budat       AND
                a~augdt GE va_budat1.
      ENDIF.
    ENDIF.
  ENDIF.

* BY PROFIT CENTER
  IF radio6 EQ 'X'.
    IF radio10 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsis AS a JOIN cepct AS b ON a~prctr EQ b~prctr AND
                                            b~spras EQ 'EN'
          INTO CORRESPONDING FIELDS OF TABLE i_bsis1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~budat IN ra_budat       AND
                a~prctr IN so_prctr.

        SELECT *
          FROM bsas AS a JOIN cepct AS b ON a~prctr EQ b~prctr AND
                                            b~spras EQ 'EN'
          APPENDING  CORRESPONDING FIELDS OF TABLE i_bsis1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~budat IN ra_budat       AND
                a~augdt GE va_budat1      AND
                a~prctr IN so_prctr.
      ENDIF.
    ENDIF.

    IF radio11 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsid AS a JOIN cepct AS b ON a~prctr EQ b~prctr AND
                                            b~spras EQ 'EN'
          INTO CORRESPONDING FIELDS OF TABLE i_kunnr1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~prctr IN so_prctr       AND
                a~budat IN ra_budat.

        SELECT *
          FROM bsad AS a JOIN cepct AS b ON a~prctr EQ b~prctr AND
                                            b~spras EQ 'EN'
          APPENDING CORRESPONDING FIELDS OF TABLE i_kunnr1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~prctr IN so_prctr       AND
                a~budat IN ra_budat       AND
                a~augdt GE va_budat1.
      ENDIF.
    ENDIF.

    IF radio12 EQ 'X'.
      IF i_skat[] IS NOT INITIAL.
        SELECT *
          FROM bsik AS a JOIN cepct AS b ON a~prctr EQ b~prctr AND
                                            b~spras EQ 'EN'
          INTO CORRESPONDING FIELDS OF TABLE i_lifnr1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~prctr IN so_prctr       AND
                a~budat IN ra_budat.

        SELECT *
          FROM bsak AS a JOIN cepct AS b ON a~prctr EQ b~prctr AND
                                            b~spras EQ 'EN'
          APPENDING CORRESPONDING FIELDS OF TABLE i_lifnr1
          FOR ALL ENTRIES IN i_skat
          WHERE a~bukrs EQ pa_bukrs       AND
                a~hkont EQ i_skat-saknr   AND
                a~prctr IN so_prctr       AND
                a~budat IN ra_budat       AND
                a~augdt GE va_budat1.
      ENDIF.
    ENDIF.
  ENDIF.

* Revisi perhitungan dmbtr 20/02/2007
*  IF NOT I_BSIS1 IS INITIAL.
*    CLEAR: WA_BSIS1.
*    LOOP AT I_BSIS1 INTO WA_BSIS1.
*      IF WA_BSIS1-SHKZG EQ 'H'.
*        WA_BSIS1-DMBTR = WA_BSIS1-DMBTR * -1.
*      ENDIF.
*      ADD WA_BSIS1-DMBTR TO VA_DMBTR.
*      CLEAR: WA_BSIS1.
*    ENDLOOP.
*  ENDIF.
*  IF NOT I_KUNNR1 IS INITIAL.
*    CLEAR: WA_KUNNR1.
*    LOOP AT I_KUNNR1 INTO WA_KUNNR1.
*      IF WA_KUNNR1-SHKZG EQ 'H'.
*        WA_KUNNR1-DMBTR = WA_KUNNR1-DMBTR * -1.
*      ENDIF.
*      ADD WA_KUNNR1-DMBTR TO VA_DMBTR.
*      CLEAR: WA_KUNNR1.
*    ENDLOOP.
*  ENDIF.
*
*  IF NOT I_LIFNR1 IS INITIAL.
*    CLEAR: WA_LIFNR1.
*    LOOP AT I_LIFNR1 INTO WA_LIFNR1.
*      IF WA_LIFNR1-SHKZG EQ 'H'.
*        WA_LIFNR1-DMBTR = WA_LIFNR1-DMBTR * -1.
*      ENDIF.
*      ADD WA_LIFNR1-DMBTR TO VA_DMBTR.
*      CLEAR: WA_LIFNR1.
*    ENDLOOP.
*  ENDIF.

  SORT i_bsis1 BY hkont.
  IF NOT i_bsis1[] IS INITIAL.
    CLEAR: wa_bsis1.
    LOOP AT i_bsis1 INTO wa_bsis1.
      t_dmbtr-hkont = wa_bsis1-hkont.
      IF wa_bsis1-shkzg EQ 'H'.
        t_dmbtr-dmbtr = wa_bsis1-dmbtr * -1.
      ENDIF.
      COLLECT t_dmbtr.
      CLEAR: wa_bsis1.
    ENDLOOP.
  ENDIF.

  IF NOT i_kunnr1 IS INITIAL.
    CLEAR: wa_kunnr1.
    LOOP AT i_kunnr1 INTO wa_kunnr1.
      t_dmbtr-hkont = wa_kunnr1-hkont.
      IF wa_kunnr1-shkzg EQ 'H'.
        wa_kunnr1-dmbtr = wa_kunnr1-dmbtr * -1.
      ENDIF.
      COLLECT t_dmbtr.
      CLEAR: wa_kunnr1.
    ENDLOOP.
  ENDIF.

  IF NOT i_lifnr1 IS INITIAL.
    CLEAR: wa_lifnr1.
    LOOP AT i_lifnr1 INTO wa_lifnr1.
      t_dmbtr-hkont = wa_lifnr1-hkont.
      IF wa_lifnr1-shkzg EQ 'H'.
        wa_lifnr1-dmbtr = wa_lifnr1-dmbtr * -1.
      ENDIF.
      COLLECT t_dmbtr.
      CLEAR: wa_lifnr1.
    ENDLOOP.
  ENDIF.
* End revisi
ENDFORM.                    " ADD_BEGBAL

*&---------------------------------------------------------------------*
*&      Form  F_CRT_DWNFIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_crt_dwnfield .
  DATA count TYPE i.
  CLEAR count.
  DO 11 TIMES.
    CLEAR wa_dwn_field.
    ADD 1 TO count.
    CASE count.
      WHEN '1'.
        wa_dwn_field-txt_field = 'Comp. Code'.
      WHEN '2'.
        wa_dwn_field-txt_field = 'Doc. Type'.
      WHEN '3'.
        wa_dwn_field-txt_field = 'Doc.Number'.
      WHEN '4'.
        wa_dwn_field-txt_field = 'Sls Office'.
      WHEN '5'.
        wa_dwn_field-txt_field = 'Post Date'.
      WHEN '6'.
        wa_dwn_field-txt_field = 'GL Account'.
      WHEN '7'.
        wa_dwn_field-txt_field = 'Loc Curr'.
      WHEN '8'.
        wa_dwn_field-txt_field = 'Debet'.
      WHEN '9'.
        wa_dwn_field-txt_field = 'Credit'.
      WHEN '10'.
        wa_dwn_field-txt_field = 'Assignment'.
      WHEN '11'.
        wa_dwn_field-txt_field = 'Descript'.
      WHEN '12'.
        wa_dwn_field-txt_field = 'Document header Text'.
      WHEN '13'.
        wa_dwn_field-txt_field = 'Tr.Prt'.
      WHEN '14'.
        wa_dwn_field-txt_field = 'Refference key 3'.
      WHEN '15'.
        wa_dwn_field-txt_field = 'Long text'.
      WHEN '16'.
        wa_dwn_field-txt_field = 'RCd'.
      WHEN '17'.
        wa_dwn_field-txt_field = 'Order'.
      WHEN '18'.
        wa_dwn_field-txt_field = 'Profit Ctr'.
      WHEN '19'.
        wa_dwn_field-txt_field = 'Cost Ctr'.
      WHEN '20'.
        wa_dwn_field-txt_field = 'Commitment item'.
    ENDCASE.
    APPEND wa_dwn_field TO dwn_field.
  ENDDO.
ENDFORM.                    " F_CRT_DWNFIELD

*&---------------------------------------------------------------------*
*&      Form  f_add_balance
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_add_balance .
  DATA: lt_glt0 TYPE ta_glt0 OCCURS 0.

  lt_glt0[] = i_glt0[].
  SORT i_hkont2 BY hkont gsber.
  SORT lt_glt0 BY racct rbusa.
  LOOP AT i_hkont2 INTO wa_hkont2.
    READ TABLE lt_glt0 INTO wa_glt0 WITH KEY racct = wa_hkont2-hkont
                                             rbusa = wa_hkont2-gsber
                                             BINARY SEARCH.
    IF sy-subrc EQ 0.
      DELETE lt_glt0 WHERE racct EQ wa_hkont2-hkont AND
                           rbusa EQ wa_hkont2-gsber.
    ENDIF.
  ENDLOOP.

  IF lt_glt0[] IS NOT INITIAL.
    SORT lt_glt0 BY racct.
    SORT i_hkont2 BY hkont.
    LOOP AT lt_glt0 INTO wa_glt0.
      READ TABLE i_hkont2 INTO wa_hkont2 WITH KEY hkont = wa_glt0-racct
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        wa_hkont2-hkont = wa_glt0-racct.
        wa_hkont2-gsber = wa_glt0-rbusa.
        CLEAR: wa_hkont2-debet, wa_hkont2-credit,
               wa_hkont2-debet1, wa_hkont2-credit1.
        APPEND wa_hkont2 TO i_hkont2.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_add_balance

*&---------------------------------------------------------------------*
*&      Form  F_CALC_BEGBAL
*&---------------------------------------------------------------------*
FORM f_calc_begbal  USING    fu_option fu_hkont
                    CHANGING fc_begbal.

  CASE fu_option.
    WHEN 'LOCCURR'.
      LOOP AT i_glt0 INTO wa_glt0
      WHERE racct EQ fu_hkont.
        ADD wa_glt0-hslvt TO fc_begbal.
        CASE so_budat-low+4(2).
          WHEN '02'.
            fc_begbal = fc_begbal + wa_glt0-hsl01.
          WHEN '03'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02.
          WHEN '04'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03.
          WHEN '05'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03 +
                        wa_glt0-hsl04.
          WHEN '06'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03 +
                        wa_glt0-hsl04 + wa_glt0-hsl05.
          WHEN '07'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03 +
                        wa_glt0-hsl04 + wa_glt0-hsl05 +
                        wa_glt0-hsl06.
          WHEN '08'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03 +
                        wa_glt0-hsl04 + wa_glt0-hsl05 +
                        wa_glt0-hsl06 + wa_glt0-hsl07.
          WHEN '09'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03 +
                        wa_glt0-hsl04 + wa_glt0-hsl05 +
                        wa_glt0-hsl06 + wa_glt0-hsl07 +
                        wa_glt0-hsl08.
          WHEN '10'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03 +
                        wa_glt0-hsl04 + wa_glt0-hsl05 +
                        wa_glt0-hsl06 + wa_glt0-hsl07 +
                        wa_glt0-hsl08 + wa_glt0-hsl09.
          WHEN '11'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03 +
                        wa_glt0-hsl04 + wa_glt0-hsl05 +
                        wa_glt0-hsl06 + wa_glt0-hsl07 +
                        wa_glt0-hsl08 + wa_glt0-hsl09 +
                        wa_glt0-hsl10.
          WHEN '12'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03 +
                        wa_glt0-hsl04 + wa_glt0-hsl05 +
                        wa_glt0-hsl06 + wa_glt0-hsl07 +
                        wa_glt0-hsl08 + wa_glt0-hsl09 +
                        wa_glt0-hsl10 + wa_glt0-hsl11.
        ENDCASE.
        CLEAR: wa_glt0.
      ENDLOOP.

    WHEN 'DOCCURR'.
      LOOP AT i_glt0 INTO wa_glt0
      WHERE racct EQ fu_hkont.
        ADD wa_glt0-tslvt TO fc_begbal.
        CASE so_budat-low+4(2).
          WHEN '02'.
            fc_begbal = fc_begbal + wa_glt0-tsl01.
          WHEN '03'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02.
          WHEN '04'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03.
          WHEN '05'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03 +
                        wa_glt0-tsl04.
          WHEN '06'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03 +
                        wa_glt0-tsl04 + wa_glt0-tsl05.
          WHEN '07'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03 +
                        wa_glt0-tsl04 + wa_glt0-tsl05 +
                        wa_glt0-tsl06.
          WHEN '08'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03 +
                        wa_glt0-tsl04 + wa_glt0-tsl05 +
                        wa_glt0-tsl06 + wa_glt0-tsl07.
          WHEN '09'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03 +
                        wa_glt0-tsl04 + wa_glt0-tsl05 +
                        wa_glt0-tsl06 + wa_glt0-tsl07 +
                        wa_glt0-tsl08.
          WHEN '10'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03 +
                        wa_glt0-tsl04 + wa_glt0-tsl05 +
                        wa_glt0-tsl06 + wa_glt0-tsl07 +
                        wa_glt0-tsl08 + wa_glt0-tsl09.
          WHEN '11'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03 +
                        wa_glt0-tsl04 + wa_glt0-tsl05 +
                        wa_glt0-tsl06 + wa_glt0-tsl07 +
                        wa_glt0-tsl08 + wa_glt0-tsl09 +
                        wa_glt0-tsl10.
          WHEN '12'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03 +
                        wa_glt0-tsl04 + wa_glt0-tsl05 +
                        wa_glt0-tsl06 + wa_glt0-tsl07 +
                        wa_glt0-tsl08 + wa_glt0-tsl09 +
                        wa_glt0-tsl10 + wa_glt0-tsl11.
        ENDCASE.
        CLEAR: wa_glt0.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_CALC_BEGBAL

*&---------------------------------------------------------------------*
*&      Form  F_CALC_BEGBAL1
*&---------------------------------------------------------------------*
FORM f_calc_begbal1  USING    fu_option fu_hkont fu_gsber
                     CHANGING fc_begbal.

  CASE fu_option.
    WHEN 'LOCCURR'.
      LOOP AT i_glt0 INTO wa_glt0
      WHERE racct EQ fu_hkont AND
            rbusa EQ fu_gsber.
        ADD wa_glt0-hslvt TO fc_begbal.
        CASE so_budat-low+4(2).
          WHEN '02'.
            fc_begbal = fc_begbal + wa_glt0-hsl01.
          WHEN '03'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02.
          WHEN '04'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03.
          WHEN '05'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03 +
                        wa_glt0-hsl04.
          WHEN '06'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03 +
                        wa_glt0-hsl04 + wa_glt0-hsl05.
          WHEN '07'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03 +
                        wa_glt0-hsl04 + wa_glt0-hsl05 +
                        wa_glt0-hsl06.
          WHEN '08'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03 +
                        wa_glt0-hsl04 + wa_glt0-hsl05 +
                        wa_glt0-hsl06 + wa_glt0-hsl07.
          WHEN '09'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03 +
                        wa_glt0-hsl04 + wa_glt0-hsl05 +
                        wa_glt0-hsl06 + wa_glt0-hsl07 +
                        wa_glt0-hsl08.
          WHEN '10'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03 +
                        wa_glt0-hsl04 + wa_glt0-hsl05 +
                        wa_glt0-hsl06 + wa_glt0-hsl07 +
                        wa_glt0-hsl08 + wa_glt0-hsl09.
          WHEN '11'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03 +
                        wa_glt0-hsl04 + wa_glt0-hsl05 +
                        wa_glt0-hsl06 + wa_glt0-hsl07 +
                        wa_glt0-hsl08 + wa_glt0-hsl09 +
                        wa_glt0-hsl10.
          WHEN '12'.
            fc_begbal = fc_begbal + wa_glt0-hsl01 +
                        wa_glt0-hsl02 + wa_glt0-hsl03 +
                        wa_glt0-hsl04 + wa_glt0-hsl05 +
                        wa_glt0-hsl06 + wa_glt0-hsl07 +
                        wa_glt0-hsl08 + wa_glt0-hsl09 +
                        wa_glt0-hsl10 + wa_glt0-hsl11.
        ENDCASE.
        CLEAR: wa_glt0.
      ENDLOOP.

    WHEN 'DOCCURR'.
      LOOP AT i_glt0 INTO wa_glt0
      WHERE racct EQ fu_hkont AND
            rbusa EQ fu_gsber.
        ADD wa_glt0-tslvt TO fc_begbal.
        CASE so_budat-low+4(2).
          WHEN '02'.
            fc_begbal = fc_begbal + wa_glt0-tsl01.
          WHEN '03'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02.
          WHEN '04'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03.
          WHEN '05'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03 +
                        wa_glt0-tsl04.
          WHEN '06'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03 +
                        wa_glt0-tsl04 + wa_glt0-tsl05.
          WHEN '07'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03 +
                        wa_glt0-tsl04 + wa_glt0-tsl05 +
                        wa_glt0-tsl06.
          WHEN '08'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03 +
                        wa_glt0-tsl04 + wa_glt0-tsl05 +
                        wa_glt0-tsl06 + wa_glt0-tsl07.
          WHEN '09'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03 +
                        wa_glt0-tsl04 + wa_glt0-tsl05 +
                        wa_glt0-tsl06 + wa_glt0-tsl07 +
                        wa_glt0-tsl08.
          WHEN '10'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03 +
                        wa_glt0-tsl04 + wa_glt0-tsl05 +
                        wa_glt0-tsl06 + wa_glt0-tsl07 +
                        wa_glt0-tsl08 + wa_glt0-tsl09.
          WHEN '11'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03 +
                        wa_glt0-tsl04 + wa_glt0-tsl05 +
                        wa_glt0-tsl06 + wa_glt0-tsl07 +
                        wa_glt0-tsl08 + wa_glt0-tsl09 +
                        wa_glt0-tsl10.
          WHEN '12'.
            fc_begbal = fc_begbal + wa_glt0-tsl01 +
                        wa_glt0-tsl02 + wa_glt0-tsl03 +
                        wa_glt0-tsl04 + wa_glt0-tsl05 +
                        wa_glt0-tsl06 + wa_glt0-tsl07 +
                        wa_glt0-tsl08 + wa_glt0-tsl09 +
                        wa_glt0-tsl10 + wa_glt0-tsl11.
        ENDCASE.
        CLEAR: wa_glt0.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_CALC_BEGBAL1

*&---------------------------------------------------------------------*
*&      Form  F_GET_ADDITIONAL_FIELD
*&---------------------------------------------------------------------*
FORM f_get_additional_field CHANGING fc_space fc_uline.
  IF i_hkont[] IS NOT INITIAL.
    SELECT bukrs belnr gjahr budat bldat monat bktxt
      FROM bkpf
      INTO TABLE gt_bkpf
      FOR ALL ENTRIES IN i_hkont
      WHERE bukrs EQ pa_bukrs
        AND belnr EQ i_hkont-belnr
        AND budat IN so_budat
        AND monat IN so_monat.
    SORT gt_bkpf BY bukrs belnr gjahr.              "SOH Adj 20240808
    IF gt_bkpf[] IS NOT INITIAL.
      SELECT bukrs belnr gjahr buzei vbund zuonr xref3 rstgr
             hkont sgtxt aufnr prctr kostl fipos xopvw augdt
        FROM bseg
        INTO TABLE gt_bseg
        FOR ALL ENTRIES IN gt_bkpf
        WHERE bukrs EQ pa_bukrs
          AND belnr EQ gt_bkpf-belnr
          AND gjahr EQ gt_bkpf-gjahr.
      SORT gt_bseg BY bukrs belnr gjahr buzei.      "SOH Adj 20240808
    ENDIF.
  ENDIF.

  fc_space = 105.
  IF cb_vbund IS NOT INITIAL.
    fc_space = fc_space + 7.
  ENDIF.
  IF cb_zuonr IS NOT INITIAL.
    fc_space = fc_space + 20.
  ENDIF.
  IF cb_xref3 IS NOT INITIAL.
    fc_space = fc_space + 21.
  ENDIF.
  IF cb_bktxt IS NOT INITIAL.
    fc_space = fc_space + 26.
  ENDIF.
  IF cb_bldat IS NOT INITIAL.
    fc_space = fc_space + 11.
  ENDIF.
  IF cb_sgtxt IS NOT INITIAL.
    fc_space = fc_space + 32.
  ENDIF.
  IF cb_aufnr IS NOT INITIAL.
    fc_space = fc_space + 13.
  ENDIF.
  IF cb_prctr IS NOT INITIAL.
    fc_space = fc_space + 11.
  ENDIF.
  IF cb_kostl IS NOT INITIAL.
    fc_space = fc_space + 11.
  ENDIF.
  IF cb_rstgr IS NOT INITIAL.
    fc_space = fc_space + 4.
  ENDIF.
  IF cb_fipex IS NOT INITIAL.
    fc_space = fc_space + 25.
  ENDIF.
  IF cb_augdt IS NOT INITIAL.
    fc_space = fc_space + 11.
  ENDIF.
  IF cb_statu IS NOT INITIAL.
    fc_space = fc_space + 12.
  ENDIF.
  fc_space  = fc_space + 7.
  fc_uline = fc_space + 80.
ENDFORM.                    " F_GET_ADDITIONAL_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_ADDITIONAL_FIELD
*&---------------------------------------------------------------------*
FORM f_additional_field.
  IF cb_vbund IS NOT INITIAL.
    WRITE AT c1(w1d) 'Tr.Prt'. c1 = c1 + w1d.
    WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  ENDIF.
  IF cb_zuonr IS NOT INITIAL.
    WRITE AT c1(w1j) 'Assignment'. c1 = c1 + w1j.
    WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  ENDIF.
  IF cb_xref3 IS NOT INITIAL.
    WRITE AT c1(w5) 'Refference key 3'. c1 = c1 + w5.
    WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  ENDIF.
  IF cb_bktxt IS NOT INITIAL.
    WRITE AT c1(w1i) 'Document header Text'. c1 = c1 + w1i.
    WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  ENDIF.
  IF cb_sgtxt IS NOT INITIAL.
    WRITE AT c1(w1k) 'Long text'. c1 = c1 + w1k.
    WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  ENDIF.
  IF cb_aufnr IS NOT INITIAL.
    WRITE AT c1(w1l) 'Order'. c1 = c1 + w1l.
    WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  ENDIF.
  IF cb_prctr IS NOT INITIAL.
    WRITE AT c1(w1m) 'Profit Ctr'. c1 = c1 + w1m.
    WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  ENDIF.
  IF cb_kostl IS NOT INITIAL.
    WRITE AT c1(w1m) 'Cost Ctr'. c1 = c1 + w1m.
    WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  ENDIF.
  IF cb_rstgr IS NOT INITIAL.
    WRITE AT c1(w1n) 'RCd'. c1 = c1 + w1n.
    WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  ENDIF.
  IF cb_fipex IS NOT INITIAL.
    WRITE AT c1(w1o) 'Commitment item'. c1 = c1 + w1o.
    WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  ENDIF.
  IF cb_bldat IS NOT INITIAL.
    WRITE AT c1(w1c) 'Doc. Date'. c1 = c1 + w1c.
    WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  ENDIF.
  IF cb_augdt IS NOT INITIAL.
    WRITE AT c1(w1c) 'Clearing'. c1 = c1 + w1c.
    WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  ENDIF.
  IF cb_statu IS NOT INITIAL.
    WRITE AT c1(w1q) 'Status'. c1 = c1 + w1q.
    WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  ENDIF.
ENDFORM.                    " F_ADDITIONAL_FIELD

*&---------------------------------------------------------------------*
*&      Form  HEADER2_ADDITIONAL
*&---------------------------------------------------------------------*
FORM header2_additional USING fu_uline.

  PERFORM main_header.
  IF so_budat-high EQ 0.
    WRITE: 95  'Posting Date  : ', so_budat-low.
*    WRITE: /95  'Period        : ', VA_PERIOD.
    WRITE: /53  pa_text CENTERED.
    WRITE:  95  'Period        : ', va_period.
  ELSE.
    WRITE: 95  'Posting Date  : ', so_budat-low, '-', so_budat-high.
    IF so_budat-high(6) EQ so_budat-low(6).
*      WRITE: /95  'Period        : ', VA_PERIOD.
      WRITE: /53  pa_text CENTERED.
      WRITE:  95  'Period        : ', va_period.
    ELSE.
*      WRITE: /95  'Period        : ', VA_PERIOD, '-', VA_PERIOD1.
      WRITE: /53  pa_text CENTERED.
      WRITE:  95  'Period        : ', va_period, '-', va_period1.
    ENDIF.
  ENDIF.

  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  WRITE: /    sy-uline.
  WRITE: /    sy-vline.
  c1 = 1.
  c1 = c1 + 1.
  WRITE AT c1(w1c) 'Pstg date'. c1 = c1 + w1c.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1f) 'Per.'. c1 = c1 + w1f.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1e) 'Doc.no.'. c1 = c1 + w1e.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1f) 'BusA'. c1 = c1 + w1f.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1f) 'Type'. c1 = c1 + w1f.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1g) 'Reference'. c1 = c1 + w1g.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1h) 'Description'. c1 = c1 + w1h.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  PERFORM f_additional_field.
  WRITE AT c1(w2) 'LCurr'. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w7) 'Debet' RIGHT-JUSTIFIED. c1 = c1 + w7.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w7) 'Credit' RIGHT-JUSTIFIED. c1 = c1 + w7.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w2) 'Curr'. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1p) 'Debet' RIGHT-JUSTIFIED. c1 = c1 + w1p.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1p) 'Credit' RIGHT-JUSTIFIED. c1 = c1 + w1p.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE: /    sy-uline.

  zebra1 = 0.
ENDFORM.                    " HEADER2_ADDITIONAL

*&---------------------------------------------------------------------*
*&      Form  F_DETAIL_ADDITIONAL
*&---------------------------------------------------------------------*
FORM f_detail_additional USING fu_belnr fu_hkont.
  DATA : lv_vbund     TYPE vbund,
         lv_zuonr     TYPE zuonr,
         lv_xref3     TYPE xref3,
         lv_bktxt     TYPE bktxt,
         lv_sgtxt     TYPE sgtxt,
         lv_aufnr     TYPE aufnr,
         lv_prctr     TYPE prctr,
         lv_kostl     TYPE kostl,
         lv_rstgr     TYPE rstgr,
         lv_fipex     TYPE fipex,
         lv_bldat     TYPE bldat,
         lv_augdt     TYPE augdt,
         lv_statu(11).

  DATA : tdobname TYPE tdobname.
  DATA : lines    TYPE STANDARD TABLE OF tline,
         wa_lines LIKE LINE OF lines.

  CLEAR : lv_vbund, lv_zuonr, lv_xref3, lv_bktxt, lv_sgtxt,
          lv_aufnr, lv_prctr, lv_kostl, lv_rstgr, lv_fipex,
          lv_bldat, lv_augdt, lv_statu.

  READ TABLE gt_bkpf WITH KEY belnr = fu_belnr.
  IF sy-subrc EQ 0.
    lv_bktxt  = gt_bkpf-bktxt.
    lv_bldat  = gt_bkpf-bldat.
  ENDIF.

  READ TABLE gt_bseg WITH KEY belnr = fu_belnr
                              hkont = fu_hkont.
  IF sy-subrc EQ 0.
    lv_vbund  = gt_bseg-vbund.
    lv_zuonr  = gt_bseg-zuonr.
    lv_xref3  = gt_bseg-xref3.
    lv_rstgr  = gt_bseg-rstgr.
    CONCATENATE pa_bukrs fu_belnr gt_bseg-gjahr gt_bseg-buzei
    INTO tdobname.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = '0001'
        language                = sy-langu
        name                    = tdobname
        object                  = 'DOC_ITEM'
      TABLES
        lines                   = lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.

    IF sy-subrc EQ 0.
      READ TABLE lines INTO wa_lines INDEX 1.
      IF sy-subrc EQ 0.
        lv_sgtxt  = wa_lines-tdline.
      ENDIF.
    ENDIF.
    lv_aufnr  = gt_bseg-aufnr.
    lv_prctr  = gt_bseg-prctr.
    lv_kostl  = gt_bseg-kostl.
    lv_fipex  = gt_bseg-fipos.
    lv_augdt  = gt_bseg-augdt.

    IF gt_bseg-xopvw IS NOT INITIAL AND
      gt_bseg-augdt IS NOT INITIAL.
      lv_statu = 'CLEARED'.
    ELSEIF gt_bseg-xopvw IS NOT INITIAL AND
      gt_bseg-augdt IS INITIAL.
      lv_statu = 'NOT CLEARED'.
    ELSE.
      lv_statu = 'LINE ITEM'.
    ENDIF.
  ENDIF.

  IF cb_vbund IS NOT INITIAL.
    WRITE: sy-vline NO-GAP, lv_vbund NO-GAP.
  ENDIF.
  IF cb_zuonr IS NOT INITIAL.
    WRITE: sy-vline NO-GAP,(18) lv_zuonr.
  ENDIF.
  IF cb_xref3 IS NOT INITIAL.
    WRITE: sy-vline NO-GAP, lv_xref3 NO-GAP.
  ENDIF.
  IF cb_bktxt IS NOT INITIAL.
    WRITE: sy-vline NO-GAP, lv_bktxt NO-GAP.
  ENDIF.
  IF cb_sgtxt IS NOT INITIAL.
    WRITE: sy-vline NO-GAP,(30) lv_sgtxt.
  ENDIF.
  IF cb_aufnr IS NOT INITIAL.
    WRITE: sy-vline NO-GAP, lv_aufnr NO-GAP.
  ENDIF.
  IF cb_prctr IS NOT INITIAL.
    WRITE: sy-vline NO-GAP, lv_prctr NO-GAP.
  ENDIF.
  IF cb_kostl IS NOT INITIAL.
    WRITE: sy-vline NO-GAP, lv_kostl NO-GAP.
  ENDIF.
  IF cb_rstgr IS NOT INITIAL.
    WRITE: sy-vline NO-GAP, lv_rstgr NO-GAP.
  ENDIF.
  IF cb_fipex IS NOT INITIAL.
    WRITE: sy-vline NO-GAP, lv_fipex NO-GAP.
  ENDIF.
  IF cb_bldat IS NOT INITIAL.
    WRITE: sy-vline NO-GAP, lv_bldat NO-GAP.
  ENDIF.
  IF cb_augdt IS NOT INITIAL.
    WRITE: sy-vline NO-GAP, lv_augdt NO-GAP.
  ENDIF.
  IF cb_statu IS NOT INITIAL.
    WRITE: sy-vline NO-GAP, lv_statu NO-GAP.
  ENDIF.
ENDFORM.                    " F_DETAIL_ADDITIONAL
