************************************************************************
*                  REPORT                                              *
*----------------------------------------------------------------------*
* ABAP Name   : ZFCASH_BANK_JURNAL                                     *
* Created by  : Didik Imawan                                           *
* Created on  : 09/01/2003                                             *
*----------------------------------------------------------------------*
* Description :                                                        *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
* Date    Programmer  Correction  Description                   *
*                                                                      *
************************************************************************
REPORT zfcash_bank_jurnal MESSAGE-ID zf
*                          LINE-SIZE 143
                          LINE-SIZE 156
                          LINE-COUNT 60
                          NO STANDARD PAGE HEADING.

INCLUDE zfcash_bank_jurnal_top.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS :
             pa_bukrs LIKE bsis-bukrs OBLIGATORY.
SELECT-OPTIONS:
             so_gsber FOR bsis-gsber,
             so_hkont FOR bsis-hkont OBLIGATORY,
             so_budat FOR bsis-budat OBLIGATORY.
** Revise by Budi 29/05/2006
SELECTION-SCREEN SKIP 1.
PARAMETERS :
             pa_test AS CHECKBOX.
** End Revise by Budi 29/05/2006
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio1 RADIOBUTTON GROUP grp1
             USER-COMMAND dik DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(22) text-003 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(22) text-004 FOR FIELD radio2.
SELECTION-SCREEN POSITION 28.
PARAMETERS : pa_waers LIKE bsis-waers MODIF ID yyy.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK block2.

*&---------------------------------------------------------------------*
*&      VALIDATE FOR SELECTION SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON so_hkont.
  IF so_hkont-low BETWEEN '0100000000' AND '0113999900'.
  ELSE.
    MESSAGE e000(zf) WITH
      'GL Account hanya untuk BANK account'.
  ENDIF.

  IF so_hkont-high NE space.
    IF so_hkont-high BETWEEN '0100000000' AND '0113999900'.
    ELSE.
      MESSAGE e000(zf) WITH
        'GL Account hanya untuk BANK account'.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON so_gsber.
  SELECT SINGLE * FROM tgsb
     WHERE gsber IN so_gsber.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Business area not found'.
  ENDIF.

  IF pa_bukrs EQ '8010'.
    IF so_gsber-low IS NOT INITIAL.
      IF so_gsber-low+0(2) NE '01'.
        MESSAGE e000(zf) WITH 'Business area must be entry 01xx'.
      ENDIF.
      IF so_gsber-high IS NOT INITIAL.
        IF so_gsber-high+0(2) NE '01'.
          MESSAGE e000(zf) WITH 'Business area must be entry 01xx'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pa_bukrs EQ '8020'.
    IF so_gsber-low IS NOT INITIAL.
      IF so_gsber-low+0(2) NE '02' AND
        so_gsber-low(1) NE 'T'.
        MESSAGE e000(zf) WITH 'Business area must be entry 02xx'.
      ENDIF.
      IF so_gsber-high IS NOT INITIAL.
        IF so_gsber-high+0(2) NE '02' AND
          so_gsber-high(1) NE 'T'.
          MESSAGE e000(zf) WITH 'Business area must be entry 02xx'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pa_bukrs EQ '8030'.
    IF so_gsber-low IS NOT INITIAL.
      IF so_gsber-low+0(2) NE '03'.
        MESSAGE e000(zf) WITH 'Business area must be entry 03xx'.
      ENDIF.
      IF so_gsber-high IS NOT INITIAL.
        IF so_gsber-high+0(2) NE '03'.
          MESSAGE e000(zf) WITH 'Business area must be entry 03xx'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  IF radio1 = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'YYY'.
        screen-input  = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    CLEAR: pa_waers.
  ELSEIF radio2 = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'YYY'.
        screen-input  = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  CLEAR: radio1.

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

*&---------------------------------------------------------------------*
*&      START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM cek_authority.

  IF pa_waers EQ space.
    MOVE 'IDR' TO current.
  ELSE.
    MOVE pa_waers TO current.
  ENDIF.

  MOVE so_budat-low+0(6) TO va_date.
  CONCATENATE va_date '01' INTO va_date.
  counter = 0.

** Revise by Budi 29/05/2006
  PERFORM get_hkont.
** End Revise by Budi 29/05/2006
  PERFORM get_data.
  PERFORM collect_begbal.
  PERFORM f_get_itab_glt0.
  PERFORM f_get_begining_balance.
  PERFORM proses_data.

  IF radio1 EQ 'X'.
    IF i_itab1 IS INITIAL.
      PERFORM cetak_data_gsber1.
    ELSE.
      PERFORM cetak_data_gsber.
    ENDIF.
  ELSEIF radio2 EQ 'X'.
    IF pa_waers EQ space.
      MESSAGE i000(zf) WITH 'Currency harus diisi'.
    ELSE.
      IF i_itab1 IS INITIAL.
        PERFORM cetak_data_gsber1.
      ELSE.
        PERFORM cetak_data_gsber.
      ENDIF.
    ENDIF.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&        AT LINE-SELECTION
*&---------------------------------------------------------------------*
AT LINE-SELECTION.
  READ CURRENT LINE FIELD VALUE: va_gtext, va_hkont1,
                                 wa_itab-belnr, wa_itab-gjahr.
  DATA : ffield(20), fvalue(20).
  GET CURSOR FIELD ffield VALUE fvalue.
  CASE ffield.
    WHEN 'VA_GTEXT'.
      SELECT SINGLE *
         FROM tgsbt
         WHERE gtext EQ va_gtext.
      REFRESH i_hkont.
      PERFORM collect_data_hkont.
      PERFORM cetak_header_hkont.
      PERFORM cetak_data_hkont.

    WHEN 'VA_HKONT1'.
      PERFORM cetak_header_detail.
      PERFORM cetak_data_detail.

    WHEN 'WA_ITAB-BELNR'.
      SET PARAMETER ID 'BLN' FIELD wa_itab-belnr.
      SET PARAMETER ID 'BUK' FIELD pa_bukrs.
      SET PARAMETER ID 'GJR' FIELD wa_itab-gjahr.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ENDCASE.

*&---------------------------------------------------------------------*
*&      Form  CETAK_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_header.
  DATA:  l_butxt LIKE t001-butxt,
         l_ort01 LIKE t001-ort01.

  SELECT SINGLE butxt ort01
    FROM t001
    INTO (l_butxt, l_ort01)
    WHERE bukrs EQ pa_bukrs.

  WRITE: /    l_butxt,
          63  'Cash Bank Journal',
          123 'Tanggal :', sy-datum.
  WRITE: /    l_ort01,
          60  so_budat-low, '-', so_budat-high,
          123 'Halaman :', sy-pagno.
  SKIP.
ENDFORM.                    " CETAK_HEADER

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data.
** Revise by Budi 29/05/2006
*  RANGES: R_HKONT FOR BSIS-HKONT.
*  IF PA_TEST = 'X'.
*     LOOP AT I_SKAT.
*       R_HKONT-SIGN = 'E'.
*       R_HKONT-OPTION = 'EQ'.
*       R_HKONT-LOW = I_SKAT-SAKNR.
*       APPEND R_HKONT.
*     ENDLOOP.
*  ENDIF.
** Revise by Budi 29/05/2006

  IF pa_waers EQ space.
    SELECT *
      FROM bsis
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      FOR ALL ENTRIES IN i_skat
      WHERE bukrs EQ pa_bukrs     AND
            hkont EQ i_skat-saknr AND
            budat IN so_budat     AND
            gsber IN so_gsber.

** Revise by Budi 29/05/2006
    IF sy-subrc = 0 AND pa_test = 'X'.
      SELECT *
        FROM bseg
        INTO CORRESPONDING FIELDS OF TABLE i_itab2
        FOR ALL ENTRIES IN i_itab
        WHERE bukrs EQ i_itab-bukrs AND
              belnr EQ i_itab-belnr AND
              gjahr EQ i_itab-gjahr AND
              hkont NE i_itab-hkont.
*       SELECT *
*         FROM BSAS
*         APPENDING CORRESPONDING FIELDS OF TABLE I_ITAB2
*         FOR ALL ENTRIES IN I_ITAB
*         WHERE BUKRS EQ I_ITAB-BUKRS AND
*               HKONT IN R_HKONT      AND
*               GJAHR EQ I_ITAB-GJAHR AND
*               BELNR EQ I_ITAB-BELNR.
    ENDIF.
** End Revise by Budi 29/05/2006

  ELSE.
    SELECT *
      FROM bsis
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      FOR ALL ENTRIES IN i_skat
      WHERE bukrs EQ pa_bukrs     AND
            hkont EQ i_skat-saknr AND
            budat IN so_budat     AND
            gsber IN so_gsber     AND
            waers EQ pa_waers.

** Revise by Budi 29/05/2006
    IF sy-subrc = 0 AND pa_test = 'X'.
      SELECT *
        FROM bseg
        INTO CORRESPONDING FIELDS OF TABLE i_itab2
        FOR ALL ENTRIES IN i_itab
        WHERE bukrs EQ i_itab-bukrs AND
              belnr EQ i_itab-belnr AND
              gjahr EQ i_itab-gjahr AND
              hkont NE i_itab-hkont AND
              pswsl EQ pa_waers.
*       SELECT *
*         FROM BSAS
*         APPENDING CORRESPONDING FIELDS OF TABLE I_ITAB2
*         FOR ALL ENTRIES IN I_ITAB
*         WHERE BUKRS EQ I_ITAB-BUKRS AND
*               HKONT IN R_HKONT      AND
*               GJAHR EQ I_ITAB-GJAHR AND
*               BELNR EQ I_ITAB-BELNR AND
*               WAERS EQ PA_WAERS.
    ENDIF.
** End Revise by Budi 29/05/2006

  ENDIF.
ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  COLLECT_BEGBAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM collect_begbal.
  DATA: lv_datfr TYPE datum,
        lv_datto TYPE datum.

  IF so_budat-low+6(2) NE '01'.
    CONCATENATE so_budat-low(6) '01' INTO lv_datfr.
    lv_datto = so_budat-low.
    SUBTRACT 1 FROM lv_datto .

    IF pa_waers EQ space.
      SELECT *
        FROM bsis
        INTO CORRESPONDING FIELDS OF TABLE i_itab1
        FOR ALL ENTRIES IN i_skat
        WHERE bukrs EQ pa_bukrs      AND
              hkont EQ i_skat-saknr  AND
*              BUDAT LT SO_BUDAT-LOW  AND
              budat BETWEEN lv_datfr AND lv_datto AND
              gsber IN so_gsber.
    ELSE.
      SELECT *
        FROM bsis
        INTO CORRESPONDING FIELDS OF TABLE i_itab1
        FOR ALL ENTRIES IN i_skat
        WHERE bukrs EQ pa_bukrs      AND
              hkont EQ i_skat-saknr  AND
*              BUDAT LT SO_BUDAT-LOW  AND
              budat BETWEEN lv_datfr AND lv_datto AND
              gsber IN so_gsber      AND
              waers EQ pa_waers.
    ENDIF.
  ENDIF.
ENDFORM.                    " COLLECT_BEGBAL

*&---------------------------------------------------------------------*
*&      Form  PROSES_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proses_data.
  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab.
    IF wa_itab-shkzg EQ 'S'.
      MOVE wa_itab-wrbtr TO wa_itab-wrbt1.
      MOVE wa_itab-dmbtr TO wa_itab-dmbt1.
    ELSE.
      MOVE wa_itab-wrbtr TO wa_itab-wrbt2.
      MOVE wa_itab-dmbtr TO wa_itab-dmbt2.
    ENDIF.
    MODIFY i_itab FROM wa_itab.
** Revise by Budi 29/05/2006
    IF pa_test = 'X'.
      CLEAR: i_itab2.
      LOOP AT i_itab2
        WHERE gjahr EQ wa_itab-gjahr AND
              belnr EQ wa_itab-belnr.
        IF i_itab2-shkzg EQ 'H'.
          MOVE i_itab2-wrbtr TO i_itab2-wrbt1.
          MOVE i_itab2-dmbtr TO i_itab2-dmbt1.
        ELSE.
          MOVE i_itab2-wrbtr TO i_itab2-wrbt2.
          MOVE i_itab2-dmbtr TO i_itab2-dmbt2.
        ENDIF.
        i_itab2-gsber = wa_itab-gsber.
        i_itab2-hkont1 = wa_itab-hkont.
        i_itab2-budat = wa_itab-budat.
        i_itab2-xblnr = wa_itab-xblnr.
        MODIFY i_itab2.
        CLEAR: i_itab2.
      ENDLOOP.
    ENDIF.
** End Revise by Budi 29/05/2006
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " PROSES_DATA

*&---------------------------------------------------------------------*
*&      Form  CETAK_DATA_GSBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_data_gsber.
  FORMAT INTENSIFIED OFF.
  zebra = 1.

  PERFORM cetak_header.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  WRITE: /    sy-uline(139).
  WRITE: /    sy-vline NO-GAP, 'No.' NO-GAP,
          6   sy-vline, 'Business Area',
          39  sy-vline, 'Curr',
          47  sy-vline, 'Beginning Balance',
          70  sy-vline, 'Debet',
          93  sy-vline, 'Kredit',
          116 sy-vline, 'Ending Balance',
          139 sy-vline.
  WRITE: /    sy-uline(139).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED OFF.

  CLEAR: wa_itab1.
  SORT i_itab1 BY gsber hkont budat.
  LOOP AT i_itab1 INTO wa_itab1.

    IF sy-linno EQ 60.
      WRITE: /    sy-uline(142).
      PERFORM cetak_header.
    ENDIF.

    IF radio1 EQ 'X'.
      IF wa_itab1-shkzg EQ 'S'.
        ADD wa_itab1-dmbtr TO va_begbal.
      ELSE.
        va_begbal = va_begbal - wa_itab1-dmbtr.
      ENDIF.
    ELSEIF radio2 EQ 'X'.
      IF wa_itab1-shkzg EQ 'S'.
        ADD wa_itab1-wrbtr TO va_begbal.
      ELSE.
        va_begbal = va_begbal - wa_itab1-wrbtr.
      ENDIF.
    ENDIF.

    SELECT SINGLE gtext
      FROM tgsbt
      INTO va_gtext
      WHERE gsber EQ wa_itab1-gsber.

    AT END OF gsber.
      CLEAR: wa_itab.
** Revise by Budi 29/05/2006
      IF NOT pa_test IS INITIAL.
        LOOP AT i_itab2 INTO wa_itab
          WHERE bukrs EQ wa_itab1-bukrs AND
                gsber EQ wa_itab1-gsber.
          IF radio1 = 'X'.
            ADD wa_itab-dmbt1 TO total1.
            ADD wa_itab-dmbt2 TO total2.
          ELSEIF radio2 = 'X'.
            ADD wa_itab-wrbt1 TO total1.
            ADD wa_itab-wrbt2 TO total2.
          ENDIF.
          CLEAR: wa_itab.
        ENDLOOP.
      ELSE.
** End Revise by Budi 29/05/2006
        LOOP AT i_itab INTO wa_itab
          WHERE bukrs EQ wa_itab1-bukrs AND
                gsber EQ wa_itab1-gsber.
          IF radio1 = 'X'.
            ADD wa_itab-dmbt1 TO total1.
            ADD wa_itab-dmbt2 TO total2.
          ELSEIF radio2 = 'X'.
            ADD wa_itab-wrbt1 TO total1.
            ADD wa_itab-wrbt2 TO total2.
          ENDIF.
          CLEAR: wa_itab.
        ENDLOOP.
      ENDIF.

      va_endbal = va_begbal + total1 - total2.
      WRITE va_begbal TO va_begbal1 CURRENCY current.
      WRITE total1    TO total1_out CURRENCY current.
      WRITE total2    TO total2_out CURRENCY current.
      WRITE va_endbal TO va_endbal1 CURRENCY current.

      IF zebra = 0.
        FORMAT COLOR 2.
        zebra = 1.
      ELSE.
        FORMAT COLOR 4.
        zebra = 0.
      ENDIF.

      IF va_begbal EQ 0 AND
         total1    EQ 0 AND
         total2    EQ 0 AND
         va_endbal EQ 0.
        CONTINUE.
      ELSE.
        ADD 1 TO nourut.
        WRITE nourut TO nourut_out.
        WRITE: / sy-vline NO-GAP, nourut_out RIGHT-JUSTIFIED,
                 sy-vline, va_gtext HOTSPOT,
                 sy-vline, current,
                 sy-vline, va_begbal1,
                 sy-vline, total1_out,
                 sy-vline, total2_out,
                 sy-vline, va_endbal1,
                 sy-vline.
        ADD va_begbal TO begbal_end.
        ADD total1    TO total1_end.
        ADD total2    TO total2_end.
        ADD va_endbal TO endbal_end.
      ENDIF.

      CLEAR: va_begbal, total1, total2, va_endbal.
    ENDAT.
    CLEAR: wa_itab1.
  ENDLOOP.

  CLEAR: wa_itab.
  SORT i_itab BY gsber hkont budat.
  LOOP AT i_itab INTO wa_itab.

    CLEAR: wa_itab.
  ENDLOOP.

  FORMAT INTENSIFIED OFF.
  FORMAT COLOR 3.
  WRITE begbal_end TO begbal_end_out CURRENCY current.
  WRITE total1_end TO total1_end_out CURRENCY current.
  WRITE total2_end TO total2_end_out CURRENCY current.
  WRITE endbal_end TO endbal_end_out CURRENCY current.

  SELECT SINGLE ktext
     FROM tcurt
     INTO va_ktext
     WHERE waers EQ current.

  WRITE: /    sy-uline(139).
  WRITE: /    'Total', current, va_ktext,
          49  begbal_end_out,
          72  total1_end_out,
          95  total2_end_out,
          118 endbal_end_out,
          139 space.

  nourut = 0.
  CLEAR: begbal_end, total1_end, total2_end, endbal_end.
  FORMAT INTENSIFIED OFF.
  FORMAT COLOR OFF.
ENDFORM.                    " CETAK_DATA_GSBER

*&---------------------------------------------------------------------*
*&      Form  CETAK_DATA_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_data_detail.
  DATA: sw TYPE i,
        l_txt20 LIKE skat-txt20,
        l_gtext LIKE tgsbt-gtext,
        l_hkont(35).

  FORMAT INTENSIFIED OFF.
  zebra  = 1.
  nourut = 0.
  sw     = 0.

  CLEAR: wa_itab.
** Revise by Budi 29/05/2006
  IF NOT pa_test IS INITIAL.
    SORT i_itab2 BY budat belnr.

    LOOP AT i_itab2 INTO wa_itab
      WHERE gsber EQ tgsbt-gsber AND
            hkont1 EQ va_hkont1.

      IF sy-linno EQ 59.
        WRITE: / sy-uline(156).
      ENDIF.

      IF sy-linno EQ 60.
        PERFORM cetak_header.
        WRITE: /    'Business Area :',
                    va_gtext.
        WRITE: /    'G/L Account   :',
                    va_hkont1, space(1),
                    va_txt20.
        FORMAT INTENSIFIED ON.
        FORMAT COLOR 3.
        WRITE: / sy-uline(156).
        WRITE: /    sy-vline, 'Beginning Balance', space(1),
                    current, va_ktext,
                126 va_begbal CURRENCY current,
                143 sy-vline.
        WRITE: / sy-uline(156).
        FORMAT INTENSIFIED ON.
        FORMAT COLOR 1.
        WRITE: / sy-uline(156).
        WRITE: /    sy-vline NO-GAP, 'No.' NO-GAP,
                 6  sy-vline, 'Pstg date',
                 19 sy-vline, 'Year',
                 26 sy-vline, 'Doc.no.',
                 39 sy-vline, 'Reference',
                 58 sy-vline, 'Description',
                 91 sy-vline NO-GAP, 'Curr',
                 97 sy-vline, 'Debit',
                120 sy-vline, 'Credit',
                143 sy-vline, 'Acct. No',
                156 sy-vline.
        WRITE: / sy-uline(156).
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR OFF.
      ENDIF.

      IF radio1 = 'X'.
        ADD wa_itab-dmbt1 TO total1.
        ADD wa_itab-dmbt2 TO total2.
      ELSEIF radio2 = 'X'.
        ADD wa_itab-wrbt1 TO total1.
        ADD wa_itab-wrbt2 TO total2.
      ENDIF.

      IF zebra = 0.
        FORMAT COLOR 2.
        zebra = 1.
      ELSE.
        FORMAT COLOR 4.
        zebra = 0.
      ENDIF.

      IF radio1 EQ 'X'.
        WRITE wa_itab-dmbt1 TO dmbt1_out CURRENCY current.
        WRITE wa_itab-dmbt2 TO dmbt2_out CURRENCY current.
      ELSEIF radio2 EQ 'X'.
        WRITE wa_itab-wrbt1 TO dmbt1_out CURRENCY current.
        WRITE wa_itab-wrbt2 TO dmbt2_out CURRENCY current.
      ENDIF.

      ADD 1 TO nourut.

      MOVE wa_itab-sgtxt TO va_desc.
      WRITE nourut TO nourut_out.
      WRITE: / sy-vline NO-GAP, nourut_out RIGHT-JUSTIFIED,
               sy-vline, wa_itab-budat,
               sy-vline, wa_itab-gjahr,
               sy-vline, wa_itab-belnr HOTSPOT,
               sy-vline, wa_itab-xblnr,
               sy-vline, va_desc,
               sy-vline NO-GAP, current NO-GAP,
               sy-vline, dmbt1_out,
               sy-vline, dmbt2_out,
               sy-vline, wa_itab-hkont1,
               sy-vline.
      FORMAT COLOR OFF.
      CLEAR: wa_itab.
    ENDLOOP.
  ELSE.
** End Revise by Budi 29/05/2006
    IF radio1 EQ 'X'.
      SORT i_itab BY dmbt2 budat belnr.
    ELSEIF radio2 EQ 'X'.
      SORT i_itab BY wrbt2 budat belnr.
    ENDIF.

    LOOP AT i_itab INTO wa_itab
      WHERE gsber EQ tgsbt-gsber AND
            hkont EQ va_hkont1.

      IF sy-linno EQ 59.
        WRITE: / sy-uline(143).
      ENDIF.

      IF sy-linno EQ 60.
        PERFORM cetak_header.
        WRITE: /    'Business Area :',
                    va_gtext.
        WRITE: /    'G/L Account   :',
                    va_hkont1, space(1),
                    va_txt20.
        FORMAT INTENSIFIED ON.
        FORMAT COLOR 3.
        WRITE: /    sy-uline(143).
        WRITE: /    sy-vline, 'Beginning Balance', space(1),
                    current, va_ktext,
                126 va_begbal CURRENCY current,
                143 sy-vline.
        WRITE: /    sy-uline(143).
        FORMAT INTENSIFIED ON.
        FORMAT COLOR 1.
        WRITE: / sy-uline(143).
        WRITE: /    sy-vline NO-GAP, 'No.' NO-GAP,
                 6  sy-vline, 'Pstg date',
                 19 sy-vline, 'Year',
                 26 sy-vline, 'Doc.no.',
                 39 sy-vline, 'Reference',
                 58 sy-vline, 'Description',
                 91 sy-vline NO-GAP, 'Curr',
                 97 sy-vline, 'Debit',
                120 sy-vline, 'Credit',
                143 sy-vline.
        WRITE: / sy-uline(143).
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR OFF.
      ENDIF.

      IF radio1 = 'X'.
        ADD wa_itab-dmbt1 TO total1.
        ADD wa_itab-dmbt2 TO total2.
      ELSEIF radio2 = 'X'.
        ADD wa_itab-wrbt1 TO total1.
        ADD wa_itab-wrbt2 TO total2.
      ENDIF.

      IF zebra = 0.
        FORMAT COLOR 2.
        zebra = 1.
      ELSE.
        FORMAT COLOR 4.
        zebra = 0.
      ENDIF.

      IF radio1 EQ 'X'.
        WRITE wa_itab-dmbt1 TO dmbt1_out CURRENCY current.
        WRITE wa_itab-dmbt2 TO dmbt2_out CURRENCY current.
      ELSEIF radio2 EQ 'X'.
        WRITE wa_itab-wrbt1 TO dmbt1_out CURRENCY current.
        WRITE wa_itab-wrbt2 TO dmbt2_out CURRENCY current.
      ENDIF.

      ADD 1 TO nourut.

      MOVE wa_itab-sgtxt TO va_desc.
      WRITE nourut TO nourut_out.
      WRITE: / sy-vline NO-GAP, nourut_out RIGHT-JUSTIFIED,
               sy-vline, wa_itab-budat,
               sy-vline, wa_itab-gjahr,
               sy-vline, wa_itab-belnr HOTSPOT,
               sy-vline, wa_itab-xblnr,
               sy-vline, va_desc,
               sy-vline NO-GAP, current NO-GAP,
               sy-vline, dmbt1_out,
               sy-vline, dmbt2_out,
               sy-vline.
      FORMAT COLOR OFF.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.

  va_endbal = va_begbal + total1 - total2.
  WRITE total1    TO total1_out CURRENCY current.
  WRITE total2    TO total2_out CURRENCY current.

** Revise by Budi 29/05/2006
  IF NOT pa_test IS INITIAL.
    FORMAT INTENSIFIED OFF.
    FORMAT COLOR 3.
    WRITE: / sy-uline(156).
    WRITE: /    'Total', space(1),
                current, va_ktext,
            99  total1_out,
            122 total2_out,
            156 space.
    FORMAT INTENSIFIED ON.
    FORMAT COLOR 3.
    IF sy-linno GE 52.
      NEW-PAGE.
      FORMAT INTENSIFIED OFF.
      FORMAT COLOR OFF.
      PERFORM cetak_header.
      WRITE: /    'Business Area :',
                  va_gtext.
      WRITE: /    'G/L Account   :',
                  va_hkont1, space(1),
                  va_txt20.
      FORMAT INTENSIFIED ON.
      FORMAT COLOR 3.
      WRITE: /    sy-uline(156).
      WRITE: /    sy-vline, 'Beginning Balance', space(1),
                  current, va_ktext,
              126 va_begbal CURRENCY current,
              156 sy-vline.
      WRITE: /    sy-uline(156).
      FORMAT INTENSIFIED ON.
      FORMAT COLOR 1.
      WRITE: / sy-uline(156).
      WRITE: /    sy-vline NO-GAP, 'No.' NO-GAP,
               6  sy-vline, 'Pstg date',
               19 sy-vline, 'Year',
               26 sy-vline, 'Doc.no.',
               39 sy-vline, 'Reference',
               58 sy-vline, 'Description',
               91 sy-vline NO-GAP, 'Curr',
               97 sy-vline, 'Debit',
              120 sy-vline, 'Credit',
              156 sy-vline.
      WRITE: / sy-uline(156).
      FORMAT INTENSIFIED ON.
      FORMAT COLOR 3.
      WRITE: /   sy-uline(156).
      WRITE: /   sy-vline, 'Ending Balance', space(1),
                 current, va_ktext,
             126 va_endbal CURRENCY current,
             156 sy-vline.
      WRITE: /   sy-uline(156).
      FORMAT COLOR OFF.
      FORMAT INTENSIFIED OFF.
      SKIP 1.
      WRITE: /    sy-uline(156).
      WRITE: /    sy-vline,
              20  'Prepared by:',
              64  'Approved by:',
              115 'Confirmed by:',
              156 sy-vline.
      WRITE: /    sy-vline,
              156 sy-vline.
      WRITE: /    sy-vline,
              156 sy-vline.
      WRITE: /    sy-vline,
              156 sy-vline.
      WRITE:/     sy-uline(156).

    ELSE.
      WRITE: /   sy-uline(156).
      WRITE: /   sy-vline, 'Ending Balance', space(1),
                 current, va_ktext,
             126 va_endbal CURRENCY current,
             156 sy-vline.
      WRITE: /   sy-uline(156).
      FORMAT COLOR OFF.
      FORMAT INTENSIFIED OFF.
      SKIP 1.
      WRITE: /    sy-uline(156).
      WRITE: /    sy-vline,
             20  'Prepared by:',
             64  'Approved by:',
             115 'Confirmed by:',
             156  sy-vline.
      WRITE: /    sy-vline,
              156 sy-vline.
      WRITE: /    sy-vline,
              156 sy-vline.
      WRITE: /    sy-vline,
              156 sy-vline.
      WRITE:/     sy-uline(156).
    ENDIF.
    FORMAT INTENSIFIED OFF.
    FORMAT COLOR OFF.
    CLEAR: total1, total2, va_endbal.
  ELSE.
** End Revise by Budi 29/05/2006
    FORMAT INTENSIFIED OFF.
    FORMAT COLOR 3.
    WRITE: / sy-uline(143).
    WRITE: /    'Total', space(1),
                current, va_ktext,
            99  total1_out,
            122 total2_out,
            143 space.
    FORMAT INTENSIFIED ON.
    FORMAT COLOR 3.
    IF sy-linno GE 52.
      NEW-PAGE.
      FORMAT INTENSIFIED OFF.
      FORMAT COLOR OFF.
      PERFORM cetak_header.
      WRITE: /    'Business Area :',
                  va_gtext.
      WRITE: /    'G/L Account   :',
                  va_hkont1, space(1),
                  va_txt20.
      FORMAT INTENSIFIED ON.
      FORMAT COLOR 3.
      WRITE: /    sy-uline(143).
      WRITE: /    sy-vline, 'Beginning Balance', space(1),
                  current, va_ktext,
              126 va_begbal CURRENCY current,
              143 sy-vline.
      WRITE: /    sy-uline(143).
      FORMAT INTENSIFIED ON.
      FORMAT COLOR 1.
      WRITE: / sy-uline(143).
      WRITE: /    sy-vline NO-GAP, 'No.' NO-GAP,
               6  sy-vline, 'Pstg date',
               19 sy-vline, 'Year',
               26 sy-vline, 'Doc.no.',
               39 sy-vline, 'Reference',
               58 sy-vline, 'Description',
               91 sy-vline NO-GAP, 'Curr',
               97 sy-vline, 'Debit',
              120 sy-vline, 'Credit',
              143 sy-vline.
      WRITE: / sy-uline(143).
      FORMAT INTENSIFIED ON.
      FORMAT COLOR 3.
      WRITE: /   sy-uline(143).
      WRITE: /   sy-vline, 'Ending Balance', space(1),
                 current, va_ktext,
             126 va_endbal CURRENCY current,
             143 sy-vline.
      WRITE: /   sy-uline(143).
      FORMAT COLOR OFF.
      FORMAT INTENSIFIED OFF.
      SKIP 1.
      WRITE: /    sy-uline(143).
      WRITE: /    sy-vline,
              20  'Prepared by:',
              64  'Approved by:',
              115 'Confirmed by:',
              143 sy-vline.
      WRITE: /    sy-vline,
              143 sy-vline.
      WRITE: /    sy-vline,
              143 sy-vline.
      WRITE: /    sy-vline,
              143 sy-vline.
      WRITE:/     sy-uline(143).

    ELSE.
      WRITE: /   sy-uline(143).
      WRITE: /   sy-vline, 'Ending Balance', space(1),
                 current, va_ktext,
             126 va_endbal CURRENCY current,
             143 sy-vline.
      WRITE: /   sy-uline(143).
      FORMAT COLOR OFF.
      FORMAT INTENSIFIED OFF.
      SKIP 1.
      WRITE: /    sy-uline(143).
      WRITE: /    sy-vline,
             20  'Prepared by:',
             64  'Approved by:',
             115 'Confirmed by:',
             143  sy-vline.
      WRITE: /    sy-vline,
              143 sy-vline.
      WRITE: /    sy-vline,
              143 sy-vline.
      WRITE: /    sy-vline,
              143 sy-vline.
      WRITE:/     sy-uline(143).
    ENDIF.
    FORMAT INTENSIFIED OFF.
    FORMAT COLOR OFF.
    CLEAR: total1, total2, va_endbal.
  ENDIF.
ENDFORM.                    " CETAK_DATA_DETAIL

*&---------------------------------------------------------------------*
*&      Form  CETAK_HEADER_HKONT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_header_hkont.
  FORMAT INTENSIFIED OFF.
  PERFORM cetak_header.

  WRITE: /    'Business Area :', va_gtext.

  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  WRITE: /    sy-uline(142).
  WRITE: /    sy-vline NO-GAP, 'No.' NO-GAP,
          6   sy-vline, 'G/L acct',
          19  sy-vline, 'Description',
          42  sy-vline, 'Curr',
          50  sy-vline, 'Beginning Balance',
          73  sy-vline, 'Debit',
          96  sy-vline, 'Credit',
          119 sy-vline, 'Ending Balance',
          142 sy-vline.
  WRITE: /    sy-uline(142).
ENDFORM.                    " CETAK_HEADER_HKONT

*&---------------------------------------------------------------------*
*&      Form  CETAK_HEADER_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_header_detail.
  FORMAT INTENSIFIED OFF.
  CLEAR: wa_itab1, va_begbal.
  SORT i_itab1 BY gsber hkont.
  LOOP AT i_itab1 INTO wa_itab1
    WHERE bukrs EQ pa_bukrs AND
          gsber EQ tgsbt-gsber AND
          hkont EQ va_hkont1.
    IF radio1 EQ 'X'.
      IF wa_itab1-shkzg EQ 'S'.
        ADD wa_itab1-dmbtr TO va_begbal.
      ELSE.
        va_begbal = va_begbal - wa_itab1-dmbtr.
      ENDIF.
    ELSEIF radio2 EQ 'X'.
      IF wa_itab1-shkzg EQ 'S'.
        ADD wa_itab1-wrbtr TO va_begbal.
      ELSE.
        va_begbal = va_begbal - wa_itab1-wrbtr.
      ENDIF.
    ENDIF.
    CLEAR: wa_itab1.
  ENDLOOP.

** Revise by Budi 29/05/2006
*      SELECT SINGLE TXT20
*        FROM SKAT
*        INTO VA_TXT20
*        WHERE SPRAS EQ 'EN' AND
*              SAKNR EQ VA_HKONT1.
  SORT i_skat BY saknr.
  CLEAR i_skat.
  READ TABLE i_skat WITH KEY saknr = va_hkont1 BINARY SEARCH.
  va_txt20 = i_skat-txt20.
** End Revise by Budi 29/05/2006

  SELECT SINGLE gtext
    FROM tgsbt
    INTO va_gtext
    WHERE gsber EQ wa_itab-gsber.

  SELECT SINGLE ktext
    FROM tcurt
    INTO va_ktext
    WHERE waers EQ current.

  PERFORM cetak_header.
  WRITE: /    'Business Area :',
              va_gtext.
  WRITE: /    'G/L Account   :',
              va_hkont1, space(1),
              va_txt20.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 3.
** Revise by Budi 29/05/2006
  IF NOT pa_test IS INITIAL.
    WRITE: / sy-uline(156).
    WRITE: /    sy-vline, 'Beginning Balance', space(1),
                current, va_ktext,
            126 va_begbal CURRENCY current,
            156 sy-vline.
    WRITE: / sy-uline(156).
    FORMAT INTENSIFIED ON.
    FORMAT COLOR 1.
    WRITE: / sy-uline(156).
    WRITE: /    sy-vline NO-GAP, 'No.' NO-GAP,
             6  sy-vline, 'Pstg date',
             19 sy-vline, 'Year',
             26 sy-vline, 'Doc.no.',
             39 sy-vline, 'Reference',
             58 sy-vline, 'Description',
             91 sy-vline NO-GAP, 'Curr',
             97 sy-vline, 'Debit',
            120 sy-vline, 'Credit',
            143 sy-vline, 'Acct. No',
            156 sy-vline.
    WRITE: / sy-uline(156).
    FORMAT INTENSIFIED OFF.
    FORMAT COLOR OFF.
    nourut = 0.
  ELSE.
** Revise by Budi 29/05/2006
    WRITE: / sy-uline(143).
    WRITE: /    sy-vline, 'Beginning Balance', space(1),
                current, va_ktext,
            126 va_begbal CURRENCY current,
            143 sy-vline.
    WRITE: / sy-uline(143).
    FORMAT INTENSIFIED ON.
    FORMAT COLOR 1.
    WRITE: / sy-uline(143).
    WRITE: /    sy-vline NO-GAP, 'No.' NO-GAP,
             6  sy-vline, 'Pstg date',
             19 sy-vline, 'Year',
             26 sy-vline, 'Doc.no.',
             39 sy-vline, 'Reference',
             58 sy-vline, 'Description',
             91 sy-vline NO-GAP, 'Curr',
             97 sy-vline, 'Debit',
            120 sy-vline, 'Credit',
            143 sy-vline.
    WRITE: / sy-uline(143).
    FORMAT INTENSIFIED OFF.
    FORMAT COLOR OFF.
    nourut = 0.
  ENDIF.
ENDFORM.                    " CETAK_HEADER_DETAIL

*&---------------------------------------------------------------------*
*&      Form  CEK_AUTHORITY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek_authority.
  DATA l_gsber LIKE bsis-gsber.

  l_gsber = so_gsber-low.

  IF l_gsber EQ space AND so_gsber-high EQ space.
    l_gsber = '*'.
  ELSEIF l_gsber NE space AND so_gsber-high NE space.
    l_gsber = '*'.
  ENDIF.

  AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
      ID 'GSBER' FIELD l_gsber
      ID 'ACTVT' FIELD '01'.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH
    'You have no authorization for Business Area' l_gsber.
  ENDIF.
ENDFORM.                    " CEK_AUTHORITY

*&---------------------------------------------------------------------*
*&      Form  CETAK_DATA_GSBER1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_data_gsber1.
  FORMAT INTENSIFIED OFF.
  zebra = 1.

  PERFORM cetak_header.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
  WRITE: /    sy-uline(139).
  WRITE: /    sy-vline NO-GAP, 'No.' NO-GAP,
          6   sy-vline, 'Business Area',
          39  sy-vline, 'Curr',
          47  sy-vline, 'Beginning Balance',
          70  sy-vline, 'Debet',
          93  sy-vline, 'Kredit',
          116 sy-vline, 'Ending Balance',
          139 sy-vline.
  WRITE: /    sy-uline(139).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED OFF.

  CLEAR: wa_itab.
** Revise by Budi 29/05/2006
  IF NOT pa_test IS INITIAL.
    SORT i_itab2 BY gsber hkont budat.
    LOOP AT i_itab2 INTO wa_itab.

      SELECT SINGLE ktext
        FROM tcurt
        INTO va_ktext
        WHERE waers EQ current.

      IF sy-linno EQ 60.
        PERFORM cetak_header.
      ENDIF.

      IF radio1 = 'X'.
        ADD wa_itab-dmbt1 TO total1.
        ADD wa_itab-dmbt2 TO total2.
      ELSEIF radio2 = 'X'.
        ADD wa_itab-wrbt1 TO total1.
        ADD wa_itab-wrbt2 TO total2.
      ENDIF.

      SELECT SINGLE gtext
        FROM tgsbt
        INTO va_gtext
        WHERE gsber EQ wa_itab-gsber.

      AT END OF gsber.
        CLEAR: wa_itab1, wa_itab.
        SORT i_itab1 BY gsber hkont.
        LOOP AT i_itab1 INTO wa_itab1
          WHERE bukrs EQ pa_bukrs AND
                gsber EQ wa_itab-gsber.
          IF radio1 EQ 'X'.
            IF wa_itab1-shkzg EQ 'S'.
              ADD wa_itab1-dmbtr TO va_begbal.
            ELSE.
              va_begbal = va_begbal - wa_itab1-dmbtr.
            ENDIF.
          ELSEIF radio2 EQ 'X'.
            IF wa_itab1-shkzg EQ 'S'.
              ADD wa_itab1-wrbtr TO va_begbal.
            ELSE.
              va_begbal = va_begbal - wa_itab1-wrbtr.
            ENDIF.
          ENDIF.
          CLEAR: wa_itab1.
        ENDLOOP.

        va_endbal = va_begbal + total1 - total2.
        WRITE va_begbal TO va_begbal1 CURRENCY current.
        WRITE total1    TO total1_out CURRENCY current.
        WRITE total2    TO total2_out CURRENCY current.
        WRITE va_endbal TO va_endbal1 CURRENCY current.

        IF zebra = 0.
          FORMAT COLOR 2.
          zebra = 1.
        ELSE.
          FORMAT COLOR 4.
          zebra = 0.
        ENDIF.

        ADD 1 TO nourut.
        WRITE nourut TO nourut_out.
        WRITE: / sy-vline NO-GAP, nourut_out RIGHT-JUSTIFIED,
                 sy-vline, va_gtext HOTSPOT,
                 sy-vline, current,
                 sy-vline, va_begbal1,
                 sy-vline, total1_out,
                 sy-vline, total2_out,
                 sy-vline, va_endbal1,
                 sy-vline.

        ADD va_begbal TO begbal_end.
        ADD total1    TO total1_end.
        ADD total2    TO total2_end.
        ADD va_endbal TO endbal_end.

        CLEAR: va_begbal, total1, total2, va_endbal.
      ENDAT.

      CLEAR: wa_itab.
    ENDLOOP.
  ELSE.
** End Revise by Budi 29/05/2006
    SORT i_itab BY gsber hkont budat.
    LOOP AT i_itab INTO wa_itab.

      SELECT SINGLE ktext
        FROM tcurt
        INTO va_ktext
        WHERE waers EQ current.

      IF sy-linno EQ 60.
        PERFORM cetak_header.
      ENDIF.

      IF radio1 = 'X'.
        ADD wa_itab-dmbt1 TO total1.
        ADD wa_itab-dmbt2 TO total2.
      ELSEIF radio2 = 'X'.
        ADD wa_itab-wrbt1 TO total1.
        ADD wa_itab-wrbt2 TO total2.
      ENDIF.

      SELECT SINGLE gtext
        FROM tgsbt
        INTO va_gtext
        WHERE gsber EQ wa_itab-gsber.

      AT END OF gsber.
        CLEAR: wa_itab1, wa_itab.
        SORT i_itab1 BY gsber hkont.
        LOOP AT i_itab1 INTO wa_itab1
          WHERE bukrs EQ pa_bukrs AND
                gsber EQ wa_itab-gsber.
          IF radio1 EQ 'X'.
            IF wa_itab1-shkzg EQ 'S'.
              ADD wa_itab1-dmbtr TO va_begbal.
            ELSE.
              va_begbal = va_begbal - wa_itab1-dmbtr.
            ENDIF.
          ELSEIF radio2 EQ 'X'.
            IF wa_itab1-shkzg EQ 'S'.
              ADD wa_itab1-wrbtr TO va_begbal.
            ELSE.
              va_begbal = va_begbal - wa_itab1-wrbtr.
            ENDIF.
          ENDIF.
          CLEAR: wa_itab1.
        ENDLOOP.

        va_endbal = va_begbal + total1 - total2.
        WRITE va_begbal TO va_begbal1 CURRENCY current.
        WRITE total1    TO total1_out CURRENCY current.
        WRITE total2    TO total2_out CURRENCY current.
        WRITE va_endbal TO va_endbal1 CURRENCY current.

        IF zebra = 0.
          FORMAT COLOR 2.
          zebra = 1.
        ELSE.
          FORMAT COLOR 4.
          zebra = 0.
        ENDIF.

        ADD 1 TO nourut.
        WRITE nourut TO nourut_out.
        WRITE: / sy-vline NO-GAP, nourut_out RIGHT-JUSTIFIED,
                 sy-vline, va_gtext HOTSPOT,
                 sy-vline, current,
                 sy-vline, va_begbal1,
                 sy-vline, total1_out,
                 sy-vline, total2_out,
                 sy-vline, va_endbal1,
                 sy-vline.

        ADD va_begbal TO begbal_end.
        ADD total1    TO total1_end.
        ADD total2    TO total2_end.
        ADD va_endbal TO endbal_end.

        CLEAR: va_begbal, total1, total2, va_endbal.
      ENDAT.

      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.

  FORMAT INTENSIFIED OFF.
  FORMAT COLOR 3.
  WRITE begbal_end TO begbal_end_out CURRENCY current.
  WRITE total1_end TO total1_end_out CURRENCY current.
  WRITE total2_end TO total2_end_out CURRENCY current.
  WRITE endbal_end TO endbal_end_out CURRENCY current.

  WRITE: /    sy-uline(139).
  WRITE: /    'Total', current, va_ktext,
          49  begbal_end_out,
          72  total1_end_out,
          95  total2_end_out,
          118 endbal_end_out,
          139 space.

  nourut = 0.
  CLEAR: begbal_end, total1_end, total2_end, endbal_end.
  FORMAT INTENSIFIED OFF.
  FORMAT COLOR OFF.
ENDFORM.                    " CETAK_DATA_GSBER1

*&---------------------------------------------------------------------*
*&      Form  CETAK_DATA_HKONT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_data_hkont.

  FORMAT INTENSIFIED OFF.
  zebra = 1.
  nourut = 0.

  IF sy-linno EQ 60.
    WRITE: /    sy-uline(142).
    PERFORM cetak_header.
  ENDIF.

  CLEAR: wa_hkont.
  SORT i_hkont1 BY hkont budat.
  LOOP AT i_hkont1 INTO wa_hkont
    WHERE gsber EQ tgsbt-gsber.

    MOVE wa_hkont-hkont  TO va_hkont1.
    MOVE wa_hkont-txt20  TO va_txt20.
    MOVE wa_hkont-waers  TO current.
    MOVE wa_hkont-begbal TO va_begbal.
    MOVE wa_hkont-debet  TO va_total1.
    MOVE wa_hkont-credit TO va_total2.
    MOVE wa_hkont-endbal TO va_endbal.

    AT END OF hkont.
      IF zebra = 0.
        FORMAT COLOR 2.
        zebra = 1.
      ELSE.
        FORMAT COLOR 4.
        zebra = 0.
      ENDIF.

      WRITE va_begbal TO va_begbal1 CURRENCY current.
      WRITE va_total1 TO total1_out CURRENCY current.
      WRITE va_total2 TO total2_out CURRENCY current.
      WRITE va_endbal TO va_endbal1 CURRENCY current.

      ADD 1 TO nourut.
      WRITE nourut TO nourut_out.
      WRITE: / sy-vline NO-GAP, nourut_out RIGHT-JUSTIFIED,
               sy-vline, va_hkont1 HOTSPOT,
               sy-vline, va_txt20,
               sy-vline, current,
               sy-vline, va_begbal1,
               sy-vline, total1_out,
               sy-vline, total2_out,
               sy-vline, va_endbal1,
               sy-vline.

      ADD va_begbal TO begbal_end.
      ADD va_total1 TO total1_end.
      ADD va_total2 TO total2_end.
      ADD va_endbal TO endbal_end.
      CLEAR: va_begbal, va_total1, va_total2, va_endbal.
    ENDAT.
    CLEAR: wa_hkont.
  ENDLOOP.

  WRITE begbal_end TO begbal_end_out CURRENCY current.
  WRITE total1_end TO total1_end_out CURRENCY current.
  WRITE total2_end TO total2_end_out CURRENCY current.
  WRITE endbal_end TO endbal_end_out CURRENCY current.

  FORMAT INTENSIFIED OFF.
  FORMAT COLOR 3.
  WRITE: /    sy-uline(142).
  WRITE: /    'Total', current, va_ktext,
          52  begbal_end_out,
          75  total1_end_out,
          98  total2_end_out,
          121 endbal_end_out,
          142 space.
  FORMAT INTENSIFIED OFF.
  FORMAT COLOR OFF.
  CLEAR: begbal_end, total1_end, total2_end, endbal_end.

  CLEAR: nourut.
  FORMAT INTENSIFIED OFF.
  FORMAT COLOR OFF.
ENDFORM.                    " CETAK_DATA_HKONT

*&---------------------------------------------------------------------*
*&      Form  COLLECT_DATA_HKONT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM collect_data_hkont.
  DATA: l_gtext LIKE tgsbt-gtext,
        l_txt20 LIKE skat-txt20.

  CLEAR: wa_itab, va_begbal.
** Revise by Budi 29/05/2006
  IF NOT pa_test IS INITIAL.
    SORT i_itab2 BY gsber hkont1 budat.
    LOOP AT i_itab2 WHERE gsber EQ tgsbt-gsber.
      AT NEW gsber.
        SORT i_skat BY saknr.
        SORT i_hkont BY gsber hkont.
      ENDAT.

      IF radio1 = 'X'.
        ADD i_itab2-dmbt1 TO total1.
        ADD i_itab2-dmbt2 TO total2.
      ELSEIF radio2 = 'X'.
        ADD i_itab2-wrbt1 TO total1.
        ADD i_itab2-wrbt2 TO total2.
      ENDIF.

      MOVE i_itab2-zuonr TO va_zuonr.
      MOVE i_itab2-budat TO va_budat.
      MOVE i_itab2-gjahr TO va_gjahr.
      MOVE i_itab2-belnr TO va_belnr.

      AT END OF hkont1.
        CLEAR: wa_itab1.
        SORT i_itab1 BY gsber hkont.
        LOOP AT i_itab1 INTO wa_itab1
          WHERE bukrs EQ pa_bukrs AND
*                GSBER EQ WA_ITAB-GSBER AND
                gsber EQ i_itab2-gsber AND
                hkont EQ i_itab2-hkont1.

          IF sy-subrc EQ 0.
            IF radio1 EQ 'X'.
              IF wa_itab1-shkzg EQ 'S'.
                ADD wa_itab1-dmbtr TO va_begbal.
              ELSE.
                va_begbal = va_begbal - wa_itab1-dmbtr.
              ENDIF.
            ELSEIF radio2 EQ 'X'.
              IF wa_itab1-shkzg EQ 'S'.
                ADD wa_itab1-wrbtr TO va_begbal.
              ELSE.
                va_begbal = va_begbal - wa_itab1-wrbtr.
              ENDIF.
            ENDIF.
          ELSE.
            va_begbal = 0.
          ENDIF.
          CLEAR: wa_itab1.
        ENDLOOP.

        va_endbal = va_begbal + total1 - total2.

*        SELECT SINGLE TXT20
*          FROM SKAT
*          INTO L_TXT20
*          WHERE SPRAS EQ 'EN' AND
*                SAKNR EQ I_ITAB2-HKONT1.
        CLEAR i_skat.
        READ TABLE i_skat WITH KEY saknr = i_itab2-hkont1 BINARY SEARCH.
        l_txt20 = i_skat-txt20.

        wa_hkont-bukrs  = i_itab2-bukrs.
        wa_hkont-gsber  = i_itab2-gsber.
        wa_hkont-gjahr  = i_itab2-gjahr.
        wa_hkont-hkont  = i_itab2-hkont1.
        wa_hkont-gjahr  = va_gjahr.
        wa_hkont-zuonr  = va_zuonr.
        wa_hkont-belnr  = va_belnr.
        wa_hkont-budat  = va_budat.
        wa_hkont-txt20  = l_txt20.
        wa_hkont-waers  = current.
        wa_hkont-begbal = va_begbal.
        wa_hkont-debet  = total1.
        wa_hkont-credit = total2.
        wa_hkont-endbal = va_endbal.
        READ TABLE i_hkont WITH KEY bukrs = i_itab2-bukrs
                                    gsber = i_itab2-gsber
*                                      GJAHR = I_ITAB2-GJAHR
                                    hkont = i_itab2-hkont1
                           BINARY SEARCH.
        IF sy-subrc = 0.
          MODIFY i_hkont FROM wa_hkont
            TRANSPORTING begbal debet credit endbal.
        ELSE.
          APPEND wa_hkont TO i_hkont.
        ENDIF.
        CLEAR: va_begbal, total1, total2, va_endbal.
      ENDAT.
      CLEAR: i_itab2.
    ENDLOOP.
  ELSE.
** End Revise by Budi 29/05/2006
    SORT i_itab BY gsber hkont budat.
    LOOP AT i_itab INTO wa_itab
      WHERE gsber EQ tgsbt-gsber.
      AT NEW gsber.
        SORT i_skat BY saknr.
      ENDAT.

      IF radio1 = 'X'.
        ADD wa_itab-dmbt1 TO total1.
        ADD wa_itab-dmbt2 TO total2.
      ELSEIF radio2 = 'X'.
        ADD wa_itab-wrbt1 TO total1.
        ADD wa_itab-wrbt2 TO total2.
      ENDIF.

      MOVE wa_itab-zuonr TO va_zuonr.
      MOVE wa_itab-budat TO va_budat.
      MOVE wa_itab-gjahr TO va_gjahr.
      MOVE wa_itab-belnr TO va_belnr.

      AT END OF hkont.
        CLEAR: wa_itab1.
        SORT i_itab1 BY gsber hkont.
        LOOP AT i_itab1 INTO wa_itab1
          WHERE bukrs EQ pa_bukrs AND
                gsber EQ wa_itab-gsber AND
                hkont EQ wa_itab-hkont.

          IF sy-subrc EQ 0.
            IF radio1 EQ 'X'.
              IF wa_itab1-shkzg EQ 'S'.
                ADD wa_itab1-dmbtr TO va_begbal.
              ELSE.
                va_begbal = va_begbal - wa_itab1-dmbtr.
              ENDIF.
            ELSEIF radio2 EQ 'X'.
              IF wa_itab1-shkzg EQ 'S'.
                ADD wa_itab1-wrbtr TO va_begbal.
              ELSE.
                va_begbal = va_begbal - wa_itab1-wrbtr.
              ENDIF.
            ENDIF.
          ELSE.
            va_begbal = 0.
          ENDIF.
          CLEAR: wa_itab1.
        ENDLOOP.

        va_endbal = va_begbal + total1 - total2.

** Revise by Budi 29/05/2006
*        SELECT SINGLE TXT20
*          FROM SKAT
*          INTO L_TXT20
*          WHERE SPRAS EQ 'EN' AND
*                SAKNR EQ WA_ITAB-HKONT.
        CLEAR i_skat.
        READ TABLE i_skat WITH KEY saknr = wa_itab-hkont BINARY SEARCH.
        l_txt20 = i_skat-txt20.
** End Revise by Budi 29/05/2006

        wa_hkont-bukrs  = wa_itab-bukrs.
        wa_hkont-gsber  = wa_itab-gsber.
        wa_hkont-gjahr  = wa_itab-gjahr.
        wa_hkont-hkont  = wa_itab-hkont.
        wa_hkont-gjahr  = va_gjahr.
        wa_hkont-zuonr  = va_zuonr.
        wa_hkont-belnr  = va_belnr.
        wa_hkont-budat  = va_budat.
        wa_hkont-txt20  = l_txt20.
        wa_hkont-waers  = current.
        wa_hkont-begbal = va_begbal.
        wa_hkont-debet  = total1.
        wa_hkont-credit = total2.
        wa_hkont-endbal = va_endbal.
        APPEND wa_hkont TO i_hkont.
        CLEAR: va_begbal, total1, total2, va_endbal.
      ENDAT.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.

  CLEAR: wa_itab1.
  SORT i_itab1 BY gsber hkont.
  LOOP AT i_itab1 INTO wa_itab1
     WHERE bukrs EQ pa_bukrs AND
           gsber EQ tgsbt-gsber.

    AT NEW gsber.
      SORT i_skat BY saknr.
    ENDAT.

    IF radio1 EQ 'X'.
      IF wa_itab1-shkzg EQ 'S'.
        ADD wa_itab1-dmbtr TO va_begbal.
      ELSE.
        va_begbal = va_begbal - wa_itab1-dmbtr.
      ENDIF.
    ELSEIF radio2 EQ 'X'.
      IF wa_itab1-shkzg EQ 'S'.
        ADD wa_itab1-wrbtr TO va_begbal.
      ELSE.
        va_begbal = va_begbal - wa_itab1-wrbtr.
      ENDIF.
    ENDIF.

    AT END OF hkont.
** Revise by Budi 29/05/2006
*        SELECT SINGLE TXT20
*          FROM SKAT
*          INTO L_TXT20
*          WHERE SPRAS EQ 'EN' AND
*                SAKNR EQ WA_ITAB1-HKONT.
      CLEAR i_skat.
      READ TABLE i_skat WITH KEY saknr = wa_itab1-hkont BINARY SEARCH.
      l_txt20 = i_skat-txt20.
** End Revise by Budi 29/05/2006

      CLEAR: wa_itab.
** Revise by Budi 29/05/2006
      IF NOT pa_test IS INITIAL.
        LOOP AT i_itab2 INTO wa_itab
           WHERE bukrs EQ pa_bukrs       AND
                 gsber EQ wa_itab1-gsber AND
                 hkont1 EQ wa_itab1-hkont.

          IF radio1 = 'X'.
            ADD wa_itab-dmbt1 TO total1.
            ADD wa_itab-dmbt2 TO total2.
          ELSEIF radio2 = 'X'.
            ADD wa_itab-wrbt1 TO total1.
            ADD wa_itab-wrbt2 TO total2.
          ENDIF.
          CLEAR: wa_itab.
        ENDLOOP.
      ELSE.
** End Revise by Budi 29/05/2006
        LOOP AT i_itab INTO wa_itab
           WHERE bukrs EQ pa_bukrs       AND
                 gsber EQ wa_itab1-gsber AND
                 hkont EQ wa_itab1-hkont.

          IF radio1 = 'X'.
            ADD wa_itab-dmbt1 TO total1.
            ADD wa_itab-dmbt2 TO total2.
          ELSEIF radio2 = 'X'.
            ADD wa_itab-wrbt1 TO total1.
            ADD wa_itab-wrbt2 TO total2.
          ENDIF.
          CLEAR: wa_itab.
        ENDLOOP.
      ENDIF.

      va_endbal = va_begbal + total1 - total2.

      IF va_begbal NE 0 OR total1 NE 0 OR total2 NE 0.
        LOOP AT i_hkont INTO wa_hkont
          WHERE bukrs EQ wa_itab1-bukrs AND
                gsber EQ wa_itab1-gsber AND
                hkont EQ wa_itab1-hkont.
          CONTINUE.
        ENDLOOP.

        wa_hkont-bukrs  = wa_itab1-bukrs.
        wa_hkont-gsber  = wa_itab1-gsber.
        wa_hkont-gjahr  = wa_itab1-gjahr.
        wa_hkont-hkont  = wa_itab1-hkont.
        wa_hkont-gjahr  = va_gjahr.
        wa_hkont-zuonr  = va_zuonr.
        wa_hkont-belnr  = va_belnr.
        wa_hkont-budat  = va_budat.
        wa_hkont-txt20  = l_txt20.
        wa_hkont-waers  = current.
        wa_hkont-begbal = va_begbal.
        wa_hkont-debet  = total1.
        wa_hkont-credit = total2.
        wa_hkont-endbal = va_endbal.
        APPEND wa_hkont TO i_hkont1.
      ENDIF.
      CLEAR: va_begbal, total1, total2, va_endbal.
    ENDAT.
    CLEAR: wa_itab1.
  ENDLOOP.

ENDFORM.                    " COLLECT_DATA_HKONT

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
*&      Form  F_GET_ITAB_GLT0
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_itab_glt0 .
  DATA: ld_year1 LIKE glt0-ryear,
        ld_year2 LIKE glt0-ryear,
        ld_curr LIKE glt0-rtcur,
        lt_glt0 LIKE t_glt0 OCCURS 0 WITH HEADER LINE.

  IF so_budat-high IS NOT INITIAL.
    ld_year1 = so_budat-low(4).
    ld_year2 = so_budat-high(4).
  ELSE.
    ld_year1 = ld_year2 = so_budat-low(4).
  ENDIF.

  IF pa_waers IS INITIAL.
    ld_curr = 'IDR'.
  ELSE.
    ld_curr = pa_waers.
  ENDIF.

  SELECT * INTO TABLE t_glt0
    FROM glt0 FOR ALL ENTRIES IN i_skat
    WHERE rldnr = c_rldnr   AND
          rrcty = c_rrcty   AND
          rvers = c_rvers   AND
          bukrs = pa_bukrs  AND
          ryear BETWEEN ld_year1 AND ld_year2  AND
          racct = i_skat-saknr AND
          rbusa IN so_gsber AND
          rtcur = ld_curr   AND
          drcrk IN ('H','S') AND
          rpmax = c_rpmax.

** Check opn. balance current year, jika 0 maka ambil data tahun sebelumnya
*  gv_flag = '1'.
*  lt_glt0[] = t_glt0[].
*  IF ld_year1 NE ld_year2.
*    DELETE lt_glt0 WHERE ryear = ld_year2.
*  ENDIF.
*  DELETE lt_glt0 WHERE tslvt IS INITIAL.
*
*  IF lt_glt0[] IS INITIAL.
*    CLEAR gv_flag.
*    SELECT * APPENDING TABLE t_glt0
*      FROM glt0 FOR ALL ENTRIES IN i_skat
*      WHERE rldnr = c_rldnr   AND
*            rrcty = c_rrcty   AND
*            rvers = c_rvers   AND
*            bukrs = pa_bukrs  AND
*            ryear LT ld_year1 AND
*            racct = i_skat-saknr AND
*            rbusa IN so_gsber AND
*            rtcur = ld_curr   AND
*            drcrk IN ('H','S') AND
*            rpmax = c_rpmax.
*  ENDIF.
ENDFORM.                    " F_GET_ITAB_GLT0

*&---------------------------------------------------------------------*
*&      Form  F_GET_BEGINING_BALANCE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_begining_balance .
  DATA: ld_monat      LIKE bkpf-monat,
        ld_field(12)  TYPE c.

  FIELD-SYMBOLS: <s>.

  SORT t_glt0 BY bukrs racct rbusa ryear DESCENDING.
*  LOOP AT t_glt0 WHERE ryear LE so_budat-low(4).
  LOOP AT t_glt0.
    wa_itab1-bukrs = t_glt0-bukrs.
    wa_itab1-gsber = t_glt0-rbusa.
    wa_itab1-hkont = t_glt0-racct.
    wa_itab1-gjahr = t_glt0-ryear.
    wa_itab1-waers = t_glt0-rtcur.
    wa_itab1-shkzg = t_glt0-drcrk.

    IF pa_waers IS INITIAL.
* Balance forward
      IF t_glt0-ryear = so_budat-low(4) AND t_glt0-hslvt IS NOT INITIAL.
        wa_itab1-dmbtr = t_glt0-hslvt.
        CONCATENATE wa_itab1-gjahr '01' '01' INTO wa_itab1-budat.
        IF wa_itab1-shkzg = 'H'.
          wa_itab1-dmbtr = wa_itab1-dmbtr * -1.
        ENDIF.
        APPEND wa_itab1 TO i_itab1.
      ENDIF.

      ld_field  = 'T_GLT0-HSLxx'.
      DO 12 TIMES.
        ld_monat      = sy-index.
        ld_field+10(2) = ld_monat.
        ASSIGN (ld_field) TO <s>.
        wa_itab1-dmbtr = <s>.
        CONCATENATE wa_itab1-gjahr ld_monat '10' INTO wa_itab1-budat.
        IF wa_itab1-shkzg = 'H'.
          wa_itab1-dmbtr = wa_itab1-dmbtr * -1.
        ENDIF.
*        IF wa_itab1-budat(6) BETWEEN so_budat-low(6) AND so_budat-high(6).
*          MOVE-CORRESPONDING wa_itab1 to wa_itab.
*          APPEND wa_itab TO i_itab.     "Append itab debet/credit
*        ENDIF.
        IF wa_itab1-budat(6) GE so_budat-low(6).
          EXIT.
        ENDIF.
        APPEND wa_itab1 TO i_itab1.     "Append itab begining balance
      ENDDO.

*      IF t_glt0-hslvt IS NOT INITIAL.
*        EXIT.
*      ENDIF.

    ELSE.
* Balance forward
      IF t_glt0-ryear = so_budat-low(4) AND t_glt0-tslvt IS NOT INITIAL.
        wa_itab1-wrbtr = t_glt0-tslvt.
        CONCATENATE wa_itab1-gjahr '01' '01' INTO wa_itab1-budat.
        IF wa_itab1-shkzg = 'H'.
          wa_itab1-wrbtr = wa_itab1-wrbtr * -1.
        ENDIF.
        APPEND wa_itab1 TO i_itab1.
      ENDIF.

      ld_field  = 'T_GLT0-TSLxx'.
      DO 12 TIMES.
        ld_monat      = sy-index.
        ld_field+10(2) = ld_monat.
        ASSIGN (ld_field) TO <s>.
        wa_itab1-wrbtr = <s>.
        CONCATENATE wa_itab1-gjahr ld_monat '10' INTO wa_itab1-budat.
        IF wa_itab1-shkzg = 'H'.
          wa_itab1-wrbtr = wa_itab1-wrbtr * -1.
        ENDIF.
*        IF wa_itab1-budat(6) BETWEEN so_budat-low(6) AND so_budat-high(6).
*          MOVE-CORRESPONDING wa_itab1 to wa_itab.
*          APPEND wa_itab TO i_itab.     "Append itab debet/credit
*        ENDIF.
        IF wa_itab1-budat(6) GE so_budat-low(6).
          EXIT.
        ENDIF.
        APPEND wa_itab1 TO i_itab1.     "Append itab begining balance
      ENDDO.

*      IF t_glt0-tslvt IS NOT INITIAL.
*        EXIT.
*      ENDIF.
    ENDIF.
    CLEAR wa_itab1.
  ENDLOOP.
ENDFORM.                    " F_GET_BEGINING_BALANCE
