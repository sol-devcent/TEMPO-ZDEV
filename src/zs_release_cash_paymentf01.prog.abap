*----------------------------------------------------------------------*
***INCLUDE ZS_RELEASE_CASH_PAYMENTF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INITIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_initial .
  SELECT * INTO TABLE gt_zghsddt004 FROM zghsddt004 WHERE vkorg = pa_vkorg.

  SELECT * INTO TABLE gt_usgrp_user
          FROM usgrp_user
          WHERE bname  = sy-uname.
  SORT gt_zghsddt004 BY usrgroup.
  SORT gt_usgrp_user BY usergroup.
  CLEAR: va_netwr1, va_netwr2, va_usrgroup, va_netwr.
  LOOP AT gt_usgrp_user INTO gs_usgrp_user.
    READ TABLE gt_zghsddt004 INTO gs_zghsddt004 WITH KEY usrgroup = gs_usgrp_user-usergroup
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      IF gs_zghsddt004-zvalue_low >  va_netwr1.
        va_usrgroup = gs_usgrp_user-usergroup.
        va_netwr1 = gs_zghsddt004-zvalue_low.
        va_netwr2 = gs_zghsddt004-zvalue_high.
        va_netwr = va_netwr2.
        va_dept = gs_zghsddt004-zdept.
      ENDIF.
    ENDIF.
  ENDLOOP.
  ra_kkber-low    = '8000'.
  ra_kkber-sign   = 'I'.
  ra_kkber-option = 'EQ'.
  APPEND ra_kkber.
*ra_kkber-low    = '8020'.
  ra_kkber-low    = pa_vkorg.
  ra_kkber-sign   = 'I'.
  ra_kkber-option = 'EQ'.
  APPEND ra_kkber.

  SET PF-STATUS '100'.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zsmapping_soff FROM zsmapping_soff
     WHERE vkbur1 = pa_vkbur AND
           datab <= sy-datum AND
           datbi >= sy-datum.

ENDFORM.                    " F_INITIAL


*&---------------------------------------------------------------------*
*&      Form  f_init_column
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_column.
  w1   =   5.      w11 = 15.      w21 = 12.      w31 = 10.
  w2   =  15.      w12 = 15.      w22 = 10.      w32 = 12.
  w3   =  15.      w13 = 12.      w23 = 10.      w33 = 12.
  w4   =  25.      w14 = 10.      w24 = 12.      w34 = 10.
  w5   =  15.      w15 = 10.      w25 = 12.      w35 = 10.
  w6   =  12.      w16 = 12.      w26 = 10.
  w7   =  25.      w17 = 12.      w27 = 10.      w19a = 12.
  w8   =  10.      w18 = 10.      w28 = 12.
  w9   =  15.      w19 = 10.      w29 = 12.
  w10  =  15.      w20 = 12.      w30 = 10.
  c1 = 0.
ENDFORM.                    " f_init_column
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA: ctr TYPE i.
  DATA: BEGIN OF lt_kunnr OCCURS 0,
          kunnr LIKE kna1-kunnr,
        END OF lt_kunnr.
  DATA: l_numki      LIKE zsrange-numki_so,
        l_fromnumber LIKE nriv-fromnumber,
        l_nrlevel    LIKE nriv-nrlevel.

  DATA: lv_vkbur LIKE zsmapping_soff-vkbur2.
  RANGES: lr_auart FOR zsmapping_soff-auart, lr_vbeln FOR vbak-vbeln.

  lr_vbeln[] = so_vbeln[].
  REFRESH: lr_auart.
  LOOP AT gt_zsmapping_soff INTO gs_zsmapping_soff.
    lv_vkbur = gs_zsmapping_soff-vkbur2.
    lr_auart-sign    = 'I'.
    lr_auart-option  = 'EQ'.
    lr_auart-low     = gs_zsmapping_soff-auart.
    APPEND lr_auart.
  ENDLOOP.


  REFRESH: i_key.
  CLEAR: wa_key, i_key, ctr.
  IF so_vbeln IS INITIAL.
    CLEAR: l_numki, l_nrlevel, l_fromnumber.
    SELECT SINGLE numki_so FROM zsrange
           INTO l_numki
           WHERE vkbur EQ pa_vkbur.
    IF sy-subrc = 0.
      SELECT SINGLE fromnumber nrlevel
             INTO (l_fromnumber, l_nrlevel) FROM nriv
             WHERE object = 'RV_BELEG' AND
                   subobject = space AND
                   nrrangenr  = l_numki.
      IF sy-subrc EQ 0.
        so_vbeln-sign = 'I'.
        so_vbeln-option = 'BT'.
        so_vbeln-low = l_fromnumber.
        so_vbeln-high = l_nrlevel+10(10).
        APPEND so_vbeln.
      ENDIF.
    ENDIF.
  ENDIF.

  REFRESH: i_key.
  CLEAR: wa_key, i_key, ctr.
  SELECT vbeln
         INTO TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'C' AND
              lfgsk EQ 'A' AND
              cmgst IN ('','A','C','D') AND
              bestk EQ ' '.

  SELECT vbeln
    APPENDING TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'C' AND
              lfgsk EQ 'A' AND
              cmgst IN ('','A','C','D') AND
              bestk EQ 'C'.

  SELECT vbeln
    APPENDING TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'H' AND
              lfgsk EQ 'A' AND
              cmgst IN ('','A','C','D') AND
              bestk EQ ' '.

  SELECT vbeln
    APPENDING TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'H' AND
              lfgsk EQ 'A' AND
              cmgst IN ('','A','C','D') AND
              bestk EQ 'C'.

  DELETE i_key WHERE NOT ( vbeln IN so_vbeln ).

  DESCRIBE TABLE i_key LINES ctr.
  IF ctr <= 0.
    sy-subrc = 4.
*    MESSAGE s000(zs) WITH 'Data Not Found'.
*    LEAVE LIST-PROCESSING.
  ENDIF.

* Bila tanggal kosong, maka default data yang ditampilkan bulan ini dan
* bulan lalu
  IF so_audat IS INITIAL.
    so_audat-sign = 'I'.
    so_audat-option = 'BT'.
    so_audat-low = sy-datum.
    so_audat-low+6(2) = '01'.
    so_audat-low+4(2) = so_audat-low+4(2) - 1.
    IF so_audat-low+4(2) = 0.
      so_audat-low+4(2) = '12'.
      so_audat-low(4)   = so_audat-low(4) - 1.
    ENDIF.
    so_audat-high = sy-datum.
    APPEND so_audat.
  ENDIF.
  IF i_key[] IS NOT INITIAL.

    SELECT a~vkbur a~vbeln a~kunnr d~netwr a~audat a~lifsk b~name1
             a~auart a~bnddt a~abrvw a~bstnk d~kzwi5 d~posnr
          INTO CORRESPONDING FIELDS OF TABLE i_tmp "i_itab1
          FROM vbak AS a JOIN  kna1 AS b ON a~kunnr EQ b~kunnr
*                          JOIN knvv AS c  ON c~kunnr EQ a~kunnr
                          JOIN vbap AS d ON a~vbeln = d~vbeln
          FOR ALL ENTRIES IN i_key

          WHERE a~kkber IN ra_kkber AND
                a~vkorg EQ pa_vkorg AND
                a~vtweg IN so_vtweg AND
                a~vkbur EQ pa_vkbur AND
*                c~vkbur EQ pa_vkbur AND
              ( a~auart LIKE 'ZO%' OR a~auart LIKE 'ZR%' OR
                a~auart LIKE 'ZT%' OR a~auart LIKE 'ZA%' OR
                a~auart LIKE 'ZD%' OR a~auart LIKE 'YO%' OR
                a~auart LIKE 'YR%' OR a~auart LIKE 'YA%' ) AND
                a~vbeln EQ i_key-vbeln AND
                a~vkgrp IN so_vkgrp AND
                a~kunnr IN so_kunnr AND
                a~audat IN so_audat AND
                a~erdat IN so_erdat AND
                ( a~lifsk EQ 'Z4' ). "or a~abrvw = 'C' ).

    SORT i_tmp BY vbeln.
    LOOP AT i_tmp.
      MOVE-CORRESPONDING i_tmp TO i_itab1.
      COLLECT i_itab1.
    ENDLOOP.

*    IF i_itab1_temp[] IS NOT INITIAL.
*      i_itab1[] = i_itab1_temp[].
*
*    ELSE.
*      SELECT a~vkbur a~vbeln a~kunnr d~netwr a~audat a~lifsk b~name1
*                a~auart a~bnddt a~abrvw a~bstnk d~kzwi5
*             INTO CORRESPONDING FIELDS OF TABLE i_itab1
*             FROM vbak AS a JOIN  kna1 AS b ON a~kunnr EQ b~kunnr
**                        JOIN knvv AS c  ON c~kunnr EQ a~kunnr
*                             JOIN vbap AS d ON a~vbeln = d~vbeln
*             FOR ALL ENTRIES IN i_key
*
*             WHERE a~kkber IN ra_kkber AND
*                   a~vkorg EQ pa_vkorg AND
*                   a~vtweg IN so_vtweg AND
*                   a~vkbur EQ pa_vkbur AND
**              c~vkbur EQ pa_vkbur AND
*                 ( a~auart LIKE 'ZO%' OR a~auart LIKE 'ZR%' OR
*                   a~auart LIKE 'ZT%' OR a~auart LIKE 'ZA%' OR
*                   a~auart LIKE 'ZD%' OR a~auart LIKE 'YO%' OR
*                   a~auart LIKE 'YR%' OR a~auart LIKE 'YA%' ) AND
*                   ( a~auart = 'ZQ7A' OR a~auart = 'ZQ7B' OR a~auart = 'ZT7A' OR a~auart = 'ZT7B' ) AND
*                   a~vbeln EQ i_key-vbeln AND
*                   a~vkgrp IN so_vkgrp AND
*                   a~kunnr IN so_kunnr AND
*                   a~audat IN so_audat AND
*                   a~erdat IN so_erdat AND
*                   ( a~lifsk EQ 'Z4' ). "or a~abrvw = 'C' ).
*    ENDIF.




*    SELECT a~vkbur a~vbeln a~kunnr d~netwr a~audat a~lifsk b~name1
*           a~auart a~bnddt a~abrvw a~bstnk d~kzwi5
*        INTO CORRESPONDING FIELDS OF TABLE i_itab1
*        FROM vbak AS a JOIN  kna1 AS b ON a~kunnr EQ b~kunnr
*                        JOIN knvv AS c  ON c~kunnr EQ a~kunnr
*                        JOIN vbap AS d ON a~vbeln = d~vbeln
*        FOR ALL ENTRIES IN i_key
*
*        WHERE a~kkber IN ra_kkber AND
*              a~vkorg EQ pa_vkorg AND
*              a~vtweg IN so_vtweg AND
*              a~vkbur EQ pa_vkbur AND
*              c~vkbur EQ pa_vkbur AND
*            ( a~auart LIKE 'ZO%' OR a~auart LIKE 'ZR%' OR
*              a~auart LIKE 'ZT%' OR a~auart LIKE 'ZA%' OR
*              a~auart LIKE 'ZD%' OR a~auart LIKE 'YO%' OR
*              a~auart LIKE 'YR%' OR a~auart LIKE 'YA%' ) AND
*              a~vbeln EQ i_key-vbeln AND
*              a~vkgrp IN so_vkgrp AND
*              a~kunnr IN so_kunnr AND
*              a~audat IN so_audat AND
*              a~erdat IN so_erdat AND
*              ( a~lifsk EQ 'Z4' ). "or a~abrvw = 'C' ).
  ENDIF.

*** Tambahan selection data untuk project Logika - Hu dab Sub Hu
  REFRESH: i_key.
  CLEAR: wa_key, i_key, ctr.
  IF lr_vbeln IS INITIAL.
    CLEAR: l_numki, l_nrlevel, l_fromnumber.
    REFRESH: so_vbeln.
    SELECT SINGLE numki_so FROM zsrange
           INTO l_numki
           WHERE vkbur EQ lv_vkbur.
    IF sy-subrc = 0.
      SELECT SINGLE fromnumber nrlevel
             INTO (l_fromnumber, l_nrlevel) FROM nriv
             WHERE object = 'RV_BELEG' AND
                   subobject = space AND
                   nrrangenr  = l_numki.
      IF sy-subrc EQ 0.
        so_vbeln-sign = 'I'.
        so_vbeln-option = 'BT'.
        so_vbeln-low = l_fromnumber.
        so_vbeln-high = l_nrlevel+10(10).
        APPEND so_vbeln.
      ENDIF.
    ENDIF.
  ENDIF.

  REFRESH: i_key.
  CLEAR: wa_key, i_key, ctr.
  SELECT vbeln
         INTO TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'C' AND
              lfgsk EQ 'A' AND
              cmgst IN ('','A','C','D') AND
              bestk EQ ' '.

  SELECT vbeln
    APPENDING TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'C' AND
              lfgsk EQ 'A' AND
              cmgst IN ('','A','C','D') AND
              bestk EQ 'C'.

  SELECT vbeln
    APPENDING TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'H' AND
              lfgsk EQ 'A' AND
              cmgst IN ('','A','C','D') AND
              bestk EQ ' '.

  SELECT vbeln
    APPENDING TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'H' AND
              lfgsk EQ 'A' AND
              cmgst IN ('','A','C','D') AND
              bestk EQ 'C'.

  DELETE i_key WHERE NOT ( vbeln IN so_vbeln ).

  DESCRIBE TABLE i_key LINES ctr.

* Bila tanggal kosong, maka default data yang ditampilkan bulan ini dan
* bulan lalu
  IF so_audat IS INITIAL.
    so_audat-sign = 'I'.
    so_audat-option = 'BT'.
    so_audat-low = sy-datum.
    so_audat-low+6(2) = '01'.
    so_audat-low+4(2) = so_audat-low+4(2) - 1.
    IF so_audat-low+4(2) = 0.
      so_audat-low+4(2) = '12'.
      so_audat-low(4)   = so_audat-low(4) - 1.
    ENDIF.
    so_audat-high = sy-datum.
    APPEND so_audat.
  ENDIF.
  IF i_key[] IS NOT INITIAL AND lv_vkbur NE pa_vkbur.
    SELECT a~vkbur a~vbeln a~kunnr d~netwr a~audat a~lifsk b~name1 a~auart d~kzwi5
        INTO CORRESPONDING FIELDS OF TABLE i_itab3
        FROM vbak AS a JOIN  kna1 AS b ON a~kunnr EQ b~kunnr
                JOIN vbap AS d ON a~vbeln = d~vbeln
*                         JOIN knvv AS c  ON c~kunnr EQ a~kunnr
        FOR ALL ENTRIES IN i_key

        WHERE a~kkber IN ra_kkber AND
              a~vkorg EQ pa_vkorg AND
              a~vtweg IN so_vtweg AND
              a~vkbur EQ lv_vkbur AND
            ( a~auart LIKE 'ZO%' OR a~auart LIKE 'ZR%' OR
              a~auart LIKE 'ZT%' OR a~auart LIKE 'ZA%' OR
              a~auart LIKE 'ZD%' OR a~auart LIKE 'YO%' OR
              a~auart LIKE 'YR%' OR a~auart LIKE 'YA%' ) AND
              a~vbeln EQ i_key-vbeln AND
              a~vkgrp IN so_vkgrp AND
              a~kunnr IN so_kunnr AND
              a~audat IN so_audat AND
              a~erdat IN so_erdat AND
              a~lifsk EQ 'Z1'.
*               C~CMGST Ne 'B'      and
*               ( C~BESTK EQ ' ' OR  C~BESTK EQ 'C' )
*               ( C~BESTK Ne 'A' OR C~BESTK Ne 'B' )
*               order by a~vbeln
*               %_HINTS DB6 'USE_OPTLEVEL 0'.
    IF sy-subrc EQ 0.
      i_itab2[] = i_itab3[].
      SORT i_itab2 BY kunnr.
      DELETE ADJACENT DUPLICATES FROM i_itab2 COMPARING kunnr.
      SELECT kunnr INTO CORRESPONDING FIELDS OF TABLE lt_kunnr FROM knvv
        FOR ALL ENTRIES IN i_itab2
        WHERE kunnr = i_itab2-kunnr AND
              vkbur = pa_vkbur  AND
              vkorg = pa_vkorg.
      IF sy-subrc EQ 0.
        LOOP AT lt_kunnr. " INTO wa_kunnr.
          LOOP AT i_itab3 INTO wa_itab1 WHERE kunnr = lt_kunnr-kunnr.
            wa_itab1-vkbur = pa_vkbur.
            APPEND wa_itab1 TO i_itab1.
            CLEAR wa_itab1.
          ENDLOOP.
        ENDLOOP.
      ELSE.
        REFRESH: i_itab3.
      ENDIF.
      REFRESH: lt_kunnr, i_itab3, i_itab2.
    ENDIF.
  ENDIF.

  SORT i_itab1 BY netwr kunnr vbeln.
  IF i_itab1[] IS INITIAL.
    sy-subrc = 4.
    MESSAGE s000(zs) WITH 'Data Not Found'.
    LEAVE LIST-PROCESSING.
  ELSE.
    DATA: lv_sw(1).
    i_itab3[] = i_itab1[].
    CLEAR: i_itab1[], lv_sw.
    SORT i_itab3 BY vkbur auart vbeln.
    LOOP AT i_itab3 INTO wa_itab3.
      MOVE-CORRESPONDING wa_itab3 TO i_itab1.
      COLLECT i_itab1.
    ENDLOOP.
    SELECT * INTO TABLE gt_zghsddt005  FROM zghsddt005
      FOR ALL ENTRIES IN i_itab1
      WHERE vkbur = i_itab1-vkbur AND
            auart = i_itab1-auart AND
            vbeln = i_itab1-vbeln.
  ENDIF.

ENDFORM.                    " f_get_data
*&---------------------------------------------------------------------*
*&      Form  f_write_column_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_column_header.
  WRITE: / sy-uline(panjang).
  c1 = 1.
  WRITE: / sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1)  'ChBox' NO-GAP  CENTERED.  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w2) 'Purchase No' NO-GAP  CENTERED.   c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w2) 'Document No' NO-GAP  CENTERED.   c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w8) 'Payment' NO-GAP  CENTERED.   c1 = c1 + w8.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w2) 'Customer Code' NO-GAP  CENTERED.   c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4)  'Customer Name' NO-GAP  CENTERED. c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w5)  'Value Sales Order' NO-GAP  CENTERED. c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w6)  'Doc Date' NO-GAP CENTERED. c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w6)  'Pay Date' NO-GAP CENTERED. c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
*  WRITE AT c1(w6)  'PO. Exp.Date' NO-GAP CENTERED. c1 = c1 + w6.
*  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
*  WRITE AT c1(w6)  'Release 1' NO-GAP CENTERED. c1 = c1 + w6.
*  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
*  WRITE AT c1(w6)  'Ref. dari SO' NO-GAP CENTERED. c1 = c1 + w6.
*  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE: / sy-uline(panjang).
  c1 = 1.
ENDFORM.                    " f_write_column_header
*&---------------------------------------------------------------------*
*&      Form  f_write_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_detail.
  DATA: l_remark(25).
  c1 = 1.
  WRITE: /  sy-vline. c1 = c1 + 3.
  IF wa_itab1-auth = 'X'.
    WRITE AT c1   va_mark AS CHECKBOX NO-GAP CENTERED.
  ENDIF.
  c1 = c1 + w1 - 2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w2) wa_itab1-bstnk NO-GAP  .   c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w2) wa_itab1-vbeln NO-GAP  .   c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w8) wa_itab1-abrvw NO-GAP  .   c1 = c1 + w8.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w3) wa_itab1-kunnr NO-GAP  .   c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4) wa_itab1-name1 NO-GAP  . c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

*  WRITE AT c1(w5)   wa_itab1-netwr NO-GAP  DECIMALS 0. c1 = c1 + w5.
*  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w5)   wa_itab1-kzwi5 NO-GAP  DECIMALS 0. c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w6)  wa_itab1-audat NO-GAP . c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w6)  wa_itab1-budat NO-GAP . c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

**  WRITE AT c1(w5)   wa_itab1-kzwi5 NO-GAP  DECIMALS 0. c1 = c1 + w5.
**  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.


*  WRITE AT c1(w6)  wa_itab1-bnddt NO-GAP . c1 = c1 + w6.
*  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
*
*  WRITE AT c1(w6)  wa_itab1-usrgroup1 NO-GAP CENTERED. c1 = c1 + w6.
*  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
*
*  WRITE AT c1(w6)  wa_itab1-ihrez_e NO-GAP CENTERED. c1 = c1 + w6.
*  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

******  IF pa_mini = 'X'.
******    IF wa_itab1-mini = 'X' AND wa_itab1-auth = 'X'.
****  WRITE AT c1(w7)  l_remark INPUT ON NO-GAP. c1 = c1 + w7..
******    ELSE.
******      WRITE AT c1(w7)  ' ' NO-GAP . c1 = c1 + w7.
******
******    ENDIF.
****  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
******    IF wa_itab1-auth = 'X'.
****  WRITE AT c1(1)  wa_itab1-mini NO-GAP . c1 = c1 + 1.
******    ELSE.
******      WRITE AT c1(1)  ' ' NO-GAP . c1 = c1 + 1.
******    ENDIF.
****  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
******  ENDIF.
ENDFORM.                    " f_write_detail
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_header.
  DATA: v_right_header_len   TYPE i. " VALUE 50.   "space for date stamp

  CONSTANTS:
    c_sales(22)  TYPE c VALUE 'Sales Organization  : ',
    c_plant(22)  TYPE c VALUE 'Branch/Sales Office : ',
    c_userid(22) TYPE c VALUE 'User Name           : ',
    c_date(22)   TYPE c VALUE 'Processing Date     : ',
    c_value(22)  TYPE c VALUE 'Authorazation Value : ',
    c_group(22)  TYPE c VALUE 'User Group          : '.

  v_right_header_len = 85.

  WRITE: / c_sales, pa_vkorg.

  POSITION v_right_header_len.
  WRITE: c_date, sy-datum.

  WRITE: / c_plant, pa_vkbur.

  POSITION v_right_header_len.
  WRITE: c_value, va_netwr2 DECIMALS 0 CURRENCY 'IDR'.

  WRITE: / c_userid, sy-uname.
  POSITION v_right_header_len.
  WRITE: c_group, va_usrgroup.

ENDFORM.                    " F_WRITE_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_ORDER_CHANGE
*&---------------------------------------------------------------------*
FORM f_order_change  USING    fu_vbeln.
  DATA: lv_order_header_in  LIKE bapisdh1,
        lv_order_header_inx LIKE bapisdh1x,
        lv_mess(100),
        lt_return           TYPE TABLE OF bapiret2,
        ls_return           TYPE bapiret2.
  CLEAR: wa_itab1, wa_zghsddt005.
  LOOP AT i_itab1 INTO wa_itab1 WHERE vbeln = fu_vbeln.
  ENDLOOP.

*  Begin Comment
*  SELECT SINGLE * INTO wa_zghsddt005 FROM zghsddt005
*     WHERE  vkbur = pa_vkbur
*        AND auart = wa_itab1-auart
*        AND vbeln = wa_itab1-vbeln.
*  IF sy-subrc NE 0.
*    wa_zghsddt005-vkbur = pa_vkbur.
*    wa_zghsddt005-auart = wa_itab1-auart.
*    wa_zghsddt005-vbeln = wa_itab1-vbeln.
*    wa_zghsddt005-name1 = va_usrgroup. "va_remark.
*    wa_zghsddt005-bname = sy-uname.
*    wa_zghsddt005-utime = sy-uzeit.
*    wa_zghsddt005-udate = sy-datum.
*    MODIFY zghsddt005 FROM wa_zghsddt005.
*  ELSE.
*    SORT gt_zghsddt004 BY usrgroup.
*    READ TABLE gt_zghsddt004 INTO gs_zghsddt004
*    WITH KEY usrgroup = wa_zghsddt005-name1
*    BINARY SEARCH.
*    IF sy-subrc EQ 0.
*      IF va_dept = gs_zghsddt004-zdept.
*        CONCATENATE 'User Group : ' wa_zghsddt005-name1 'Sdh Release tgl : ' wa_zghsddt005-utime '|' wa_zghsddt005-bname
*        INTO lv_mess.
*        MESSAGE e000(zab) WITH lv_mess.
*        RETURN.
*      ENDIF.
*    ENDIF.
*  End Comment

  lv_order_header_in-name = sy-uname.
  lv_order_header_in-dlv_block = '  '.
  lv_order_header_inx-updateflag = 'U'.
  lv_order_header_inx-name = 'X'.
  lv_order_header_inx-dlv_block = 'X'.

  DATA(lv_abrvw) = va_list-line+39(3).
  IF lv_abrvw = 'CBD'.
    lv_order_header_in-dlv_block = space. "'Z3'.
  ENDIF.

  CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
    EXPORTING
      salesdocument    = fu_vbeln
      order_header_in  = lv_order_header_in
      order_header_inx = lv_order_header_inx
    TABLES
      return           = lt_return.

  READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    MESSAGE e000(zs) WITH ls_return-message.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

* Begin Comment
*      LOOP AT i_itab1 INTO wa_itab1 WHERE vbeln = fu_vbeln.
*        wa_zghsddt005-vkbur = pa_vkbur.
*        wa_zghsddt005-auart = wa_itab1-auart.
*        wa_zghsddt005-vbeln = wa_itab1-vbeln.
*        wa_zghsddt005-name2 = va_usrgroup. "va_remark.
*        wa_zghsddt005-bname2 = sy-uname.
*        wa_zghsddt005-utime2 = sy-uzeit.
*        wa_zghsddt005-udate2 = sy-datum.
*        MODIFY zghsddt005 FROM wa_zghsddt005.
*      ENDLOOP.
* End Comment

  ENDIF.
*  ENDIF.
ENDFORM.                    " F_ORDER_CHANGE

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_USER_GROUP
*&---------------------------------------------------------------------*
FORM f_validasi_user_group .
  DATA : ls_usrgrp  LIKE LINE OF gt_usrgrp.

  SELECT *
    FROM usgrp_user
    INTO CORRESPONDING FIELDS OF TABLE gt_usrgrp
    WHERE bname  = sy-uname.

  LOOP AT gt_usrgrp INTO ls_usrgrp.
    CASE ls_usrgrp-usergroup.
      WHEN 'BM'.
        CONCATENATE va_usrgroup 'BM' INTO va_usrgroup
        SEPARATED BY space.
      WHEN 'BSM'.
        CONCATENATE va_usrgroup 'BSM' INTO va_usrgroup
        SEPARATED BY space.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.
  CONDENSE: va_usrgroup.
  IF va_usrgroup(2) = 'BM' OR va_usrgroup(3) = 'BSM'.
  ELSE.
**  IF va_usrgroup IS NOT INITIAL.
    MESSAGE e002(zz) WITH 'Khusus User Group' va_usrgroup.
  ENDIF.
ENDFORM.                    " F_VALIDASI_USER_GROUP
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_data .
  "  DATA: lv_vkbur TYPE zscust_control-field_value.
  DATA: BEGIN OF lt_vbap OCCURS 0,
          vbeln TYPE vbap-vbeln,
          kzwi5 TYPE vbap-kzwi5,
        END OF lt_vbap.
  IF i_itab1[] IS NOT INITIAL.
    SELECT DISTINCT * INTO TABLE @DATA(lt_vbkd)
      FROM vbkd FOR ALL ENTRIES IN @i_itab1
      WHERE vbeln = @i_itab1-vbeln.
  ENDIF.

  SELECT SINGLE field_value INTO @DATA(lv_vkbur)
    FROM zscust_control
      WHERE vkorg       = @pa_vkorg
        AND cek         = 'CBD'
        AND field_name  = 'VKBUR'
        AND field_value = @pa_vkbur.
  IF sy-subrc EQ 0.
********************************************************
*va_USRGROUP  = pa_user.
********************************************************
    SELECT * INTO TABLE @DATA(lt_zfidt010)
      FROM zfidt010 FOR ALL ENTRIES IN @i_itab1
      WHERE bukrs = @pa_vkorg
        AND vkbur = @pa_vkbur
        AND vbeva = @i_itab1-vbeln.
**    IF lt_zfidt010[] IS NOT INITIAL.
**      SELECT vbeln SUM( kzwi5 ) as kzwi5 INTO TABLE lt_vbap
**        FROM vbap FOR ALL ENTRIES IN i_itab1
**        WHERE vbeln = i_itab1-vbeln
**        GROUP BY vbeln.
**    ENDIF.
  ELSE.
    DATA(lv_subrc) = sy-subrc.
  ENDIF.
  CLEAR wa_itab1.
  SORT i_itab1 BY vbeln DESCENDING.
  SORT lt_zfidt010 BY vbeva budat DESCENDING.
  LOOP AT i_itab1 INTO wa_itab1.
    IF line_exists( lt_zfidt010[ vbeva = wa_itab1-vbeln ] ).
      wa_itab1-budat = VALUE #( lt_zfidt010[ vbeva = wa_itab1-vbeln ]-budat ).
      DATA(lv_kzwi5) = wa_itab1-kzwi5. " VALUE #( lt_zfidt010[ vbeva = wa_itab1-vbeln ]-kzwi5 ).
      DATA(lv_dmbtr) = REDUCE dmbtr( INIT x TYPE dmbtr FOR wa_zfidt010 IN lt_zfidt010
                                                       WHERE ( vbeva = wa_itab1-vbeln )
                                     NEXT x = x + wa_zfidt010-dmbtr ).
      IF lv_dmbtr LT lv_kzwi5.
        DELETE TABLE i_itab1 FROM wa_itab1.
        CONTINUE.
      ENDIF.
    ELSE.
      IF wa_itab1-lifsk = 'Z4' AND lv_subrc IS NOT INITIAL.
      ELSE.
        DELETE TABLE i_itab1 FROM wa_itab1.
        CONTINUE.
      ENDIF.
    ENDIF.

    CLEAR: gs_zghsddt005, gs_zghsddt004.

    wa_itab1-netwr = wa_itab1-netwr * 110 / 100.

    MOVE va_usrgroup TO wa_itab1-usrgroup.

    SORT gt_zghsddt005 BY vkbur auart vbeln.
    READ TABLE gt_zghsddt005 INTO gs_zghsddt005
    WITH KEY vkbur = wa_itab1-vkbur
             auart = wa_itab1-auart
             vbeln = wa_itab1-vbeln
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      wa_itab1-usrgroup1 = gs_zghsddt005-name1.
      wa_itab1-usrgroup2 = gs_zghsddt005-name2.
      SORT gt_zghsddt004 BY usrgroup.
      READ TABLE gt_zghsddt004 INTO gs_zghsddt004
      WITH KEY usrgroup = wa_itab1-usrgroup1
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        wa_itab1-zdept = gs_zghsddt004-zdept.
      ENDIF.
    ENDIF.

    IF va_usrgroup IS NOT INITIAL.
      IF wa_itab1-netwr <= va_netwr2.
        IF va_dept = wa_itab1-zdept.
          wa_itab1-auth = ' '.
        ELSE.
          wa_itab1-auth = 'X'.
        ENDIF.
      ELSE.
        wa_itab1-auth = ' '.
      ENDIF.
    ELSE.
      wa_itab1-auth = ' '.
    ENDIF.

    READ TABLE lt_vbkd INTO DATA(lw_vbkd) WITH KEY vbeln = wa_itab1-vbeln.
    wa_itab1-ihrez_e = lw_vbkd-ihrez_e.
    CLEAR lw_vbkd.

    "Change ALL Authorization
    wa_itab1-auth = 'X'.

    MODIFY i_itab1 FROM wa_itab1.
    wa_itab1-netwr = wa_itab1-netwr * 100.
    wa_itab1-kzwi5 = wa_itab1-kzwi5 * 100.
    PERFORM f_write_detail.
    HIDE: wa_itab1-vbeln,wa_itab1-ihrez_e.
    CLEAR wa_itab1.
*
  ENDLOOP.


  WRITE: / sy-uline(panjang).

ENDFORM.                    " F_PROSES_DATA
