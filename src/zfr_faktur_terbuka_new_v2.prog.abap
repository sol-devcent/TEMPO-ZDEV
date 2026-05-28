************************************************************************
*                  REPORT                                              *
*----------------------------------------------------------------------*
* ABAP Name   : ZFR_FAKTUR_TERBUKA                                     *
* Created by  : Didik Imawan                                           *
* Created on  : 05/05/2003                                             *
*----------------------------------------------------------------------*
* Description :                                                        *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
* Date    Programmer  Correction  Description                   *
*                                                                      *
************************************************************************
REPORT zfr_faktur_terbuka MESSAGE-ID zf
*{   REPLACE        P01K900245                                        1
*\                          LINE-SIZE  203
                          LINE-SIZE  255
*}   REPLACE
                          LINE-COUNT 60
                          NO STANDARD PAGE HEADING.

* ALV common functions
INCLUDE zabp_alv_common.

INCLUDE zfr_fakturterbuka_sloff_v2_top.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS pa_bukrs LIKE bsid-bukrs OBLIGATORY.
SELECT-OPTIONS so_gsber FOR tvbur-vkbur.
SELECT-OPTIONS so_kdgrp FOR knvv-kdgrp.
SELECT-OPTIONS so_kvgr3 FOR knvv-kvgr3 MODIF ID kv3.
SELECT-OPTIONS so_kunnr FOR bsid-kunnr.
PARAMETERS pa_gstid LIKE bsid-budat OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE text-003.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: x_norm LIKE itemset-xnorm AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 4(24) text-004 FOR FIELD x_norm.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: x_shbv LIKE itemset-xshbv AS CHECKBOX.
SELECTION-SCREEN : COMMENT 4(24) text-005 FOR FIELD x_shbv.
SELECTION-SCREEN:  POSITION 30.
SELECT-OPTIONS: so_umskz FOR bsid-umskz NO INTERVALS.
SELECTION-SCREEN END OF LINE.

PARAMETERS x_opdr AS CHECKBOX.
PARAMETERS p_05t  AS CHECKBOX USER-COMMAND chk.
PARAMETERS x_rtv AS CHECKBOX MODIF ID rtv.
SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF BLOCK block3 WITH FRAME TITLE text-006.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio1 RADIOBUTTON GROUP grp1
             USER-COMMAND dik DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(22) text-007 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(22) text-008 FOR FIELD radio2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block3.

SELECTION-SCREEN BEGIN OF BLOCK block4 WITH FRAME TITLE text-009.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio3 RADIOBUTTON GROUP grp2 DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(22) text-010 FOR FIELD radio3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio4 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(22) text-011 FOR FIELD radio4.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio5 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(22) text-012 FOR FIELD radio5.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio6 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(22) text-013 FOR FIELD radio6.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio7 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(22) text-014 FOR FIELD radio7.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio8 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(22) text-015 FOR FIELD radio8.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block4.

************************************************************************
*   AT SELECTION-SCREEN
************************************************************************
AT SELECTION-SCREEN ON p_05t.
  IF p_05t IS INITIAL.
    CLEAR: so_kvgr3,so_kvgr3[].
  ELSE.
    PERFORM f_init_kvgr3.
  ENDIF.

AT SELECTION-SCREEN ON pa_bukrs.
  IF pa_bukrs EQ '8010'.
    MESSAGE e000(zf)
      WITH 'Company Code must be entry 8020 or 8030'.
  ENDIF.

AT SELECTION-SCREEN ON so_gsber.
  IF pa_bukrs EQ '8020'.
    IF so_gsber-low+0(2) NE '02' AND so_gsber-low NE space.
      MESSAGE e000(zf) WITH 'Business Area must be entry 02xx'.
    ENDIF.
    IF so_gsber-high+0(2) NE '02' AND so_gsber-high NE space.
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
  ELSEIF pa_bukrs EQ '8070'.
    IF so_gsber-low+0(2) NE '07' AND so_gsber-low NE space.
      MESSAGE e000(zf) WITH 'Business Area must be entry 07xx'.
    ENDIF.
    IF so_gsber-high+0(2) NE '07' AND so_gsber-high NE space.
      MESSAGE e000(zf) WITH 'Business Area must be entry 07xx'.
    ELSE.
      SELECT SINGLE gsber FROM tgsb INTO va_gsber
      WHERE gsber IN so_gsber.
      IF sy-subrc NE 0.
        MESSAGE e000(zf) WITH 'Business Area not found'.
      ENDIF.
    ENDIF.
  ENDIF.

*&---------------------------------------------------------------------*
*&      VALIDATE FOR SELECTION SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'KV3'.
      IF p_05t = 'X'.
        screen-input  = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF radio2 IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'RTV'.
        screen-active  = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF sy-uname EQ 'TDS_DEV01' OR
     sy-uname EQ 'FISJT'     OR
     sy-uname EQ 'BCSUK'     OR
     sy-uname EQ 'BCADMIN'.
    LOOP AT SCREEN.
      IF screen-group1 = 'XXX'.
        screen-input  = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'XXX'.
        screen-input  = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

AT SELECTION-SCREEN ON so_umskz.
  IF x_shbv = 'X' AND so_umskz IS INITIAL.
    so_umskz-low = 'T'.
    so_umskz-sign = 'I'.
    so_umskz-option = 'EQ'.
    APPEND so_umskz.

    so_umskz-low = 'V'.
    so_umskz-sign = 'I'.
    so_umskz-option = 'EQ'.
    APPEND so_umskz.

    so_umskz-low = 'U'.
    so_umskz-sign = 'I'.
    so_umskz-option = 'EQ'.
    APPEND so_umskz.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Initialization
*&---------------------------------------------------------------------*
INITIALIZATION.
  w_repid = sy-repid.

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

*&---------------------------------------------------------------------*
*&      START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  zebra  = 0.
  zebra1 = 0.
  sw     = 0.
  sw1    = 0.

  PERFORM cek.
  SET PF-STATUS '100'.
  PERFORM init_column.
  PERFORM f_mapping_soff.
  PERFORM get_data.
  SORT i_itab BY vkbur kunnr belnr.
  PERFORM f_hapus_kunnr.
  PERFORM f_tambah_kunnr.

  IF i_itab IS INITIAL.
    MESSAGE s000(zf) WITH 'No items selected'.
  ELSE.
    IF x_rtv IS NOT INITIAL.
      PERFORM f_add_po_number_rtv.
    ENDIF.

    PERFORM proses_data.

    IF radio1 EQ 'X'.
      PERFORM cetak_main.
    ELSE.
      PERFORM proses_alv.

      IF va_switch IS INITIAL.
        PERFORM f_alv TABLES i_out.
      ELSE.
        PERFORM fieldcat_build.
        PERFORM event_build.
        PERFORM fill_sort.
        PERFORM layout_build.
        PERFORM display_data.
      ENDIF.
    ENDIF.
  ENDIF.

TOP-OF-PAGE.
  IF radio1 EQ 'X'.
    PERFORM top_of_page.
  ENDIF.

AT USER-COMMAND.
  CASE sy-ucomm.
    WHEN 'CHOOSE'.
      READ CURRENT LINE FIELD VALUE: va_period, va_belnr.
      DATA : ffield(20), fvalue(20).
      GET CURSOR FIELD ffield VALUE fvalue.
      CASE ffield.
        WHEN 'VA_PERIOD'.
          MOVE va_period+5(3) TO va_bulan2.
          PERFORM bulan.
          CONCATENATE va_period+9(4) va_bulan3 '01' INTO ta_date-low.
          CALL FUNCTION 'LAST_DAY_OF_MONTHS'
            EXPORTING
              day_in            = ta_date-low
            IMPORTING
              last_day_of_month = ta_date-high.
          ta_date-high = ta_date-high + 1.
          APPEND ta_date.
          PERFORM get_data_belnr.
          PERFORM cetak_belnr.

        WHEN 'VA_BELNR'.
          SET PARAMETER ID 'BLN' FIELD va_belnr.
          SET PARAMETER ID 'BUK' FIELD pa_bukrs.
          SET PARAMETER ID 'GJR' FIELD va_period+9(4).
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

        WHEN 'VA_ZUONR1'.
          SET PARAMETER ID 'BLN' FIELD va_belnr.
          SET PARAMETER ID 'BUK' FIELD pa_bukrs.
          SET PARAMETER ID 'GJR' FIELD va_period+9(4).
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDCASE.

    WHEN 'SUMMARY'.
      PERFORM proses_alv.
      IF va_switch IS INITIAL.
        PERFORM f_alv TABLES i_out.
      ELSE.
        PERFORM fieldcat_build.
        PERFORM event_build.
        PERFORM fill_sort.
        PERFORM layout_build.
        PERFORM display_data.
      ENDIF.
      REFRESH i_out.
  ENDCASE.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data.

  DATA : lv_gerdat TYPE sy-datum.

  va_monat1 = pa_gstid+4(2).
  va_monat2 = pa_gstid+4(2) + 1.

  CONCATENATE pa_gstid(4) va_monat1 '01' INTO va_gerdat1.
  CONCATENATE pa_gstid(4) va_monat2 '01' INTO va_gerdat2.

  PERFORM f_month_calc USING '12'
                       CHANGING lv_gerdat.

  IF x_norm EQ 'X' AND x_shbv EQ 'X'.
    IF x_opdr IS INITIAL.
      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart b~kdgrp a~zuonr
             a~gsber a~augbl a~zfbdt a~zterm a~cpudt a~xref2 a~anln1
             b~vkbur b~kvgr3
        INTO CORRESPONDING FIELDS OF TABLE i_itab
        FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr IN so_kunnr AND
              a~budat LE pa_gstid AND
              a~umskz EQ space    AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              b~vkbur IN so_gsber AND
              b~kdgrp IN so_kdgrp AND
              b~kvgr3 IN so_kvgr3 AND
              b~vtweg EQ '10'.

      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart a~xref2 b~kdgrp
             a~augdt a~zuonr a~gsber a~augbl a~zfbdt a~zterm a~cpudt
             a~anln1 b~vkbur b~kvgr3
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        FROM bsad AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        WHERE a~bukrs EQ pa_bukrs   AND
              a~kunnr IN so_kunnr   AND
              a~budat LE pa_gstid   AND
              a~augdt GE lv_gerdat  AND
              a~umskz EQ space      AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              b~vkbur IN so_gsber AND
              b~kdgrp IN so_kdgrp AND
              b~kvgr3 IN so_kvgr3 AND
              b~vtweg EQ '10'.

      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart b~kdgrp a~zuonr
             a~gsber a~augbl a~zfbdt a~zterm a~cpudt a~xref2 a~anln1
             b~vkbur b~kvgr3
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr IN so_kunnr AND
              a~budat LE pa_gstid AND
              a~umskz IN so_umskz AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              b~vkbur IN so_gsber AND
              b~kdgrp IN so_kdgrp AND
              b~kvgr3 IN so_kvgr3 AND
              b~vtweg EQ '10'.

      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~budat a~buzei
             a~monat a~dmbtr a~shkzg a~blart a~xref2 b~kdgrp a~zuonr a~augdt
             a~augbl a~gsber a~zfbdt a~zterm a~cpudt a~anln1 b~vkbur b~kvgr3
       APPENDING CORRESPONDING FIELDS OF TABLE i_itab
       FROM bsad AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
       WHERE a~bukrs EQ pa_bukrs AND
             a~kunnr IN so_kunnr AND
             a~budat LE pa_gstid AND
             a~augdt GE lv_gerdat AND
             a~umskz IN so_umskz   AND
             a~blart IN ('RV','DR','ZA','DA','DZ') AND
             b~vkbur IN so_gsber AND
             b~kdgrp IN so_kdgrp AND
             b~kvgr3 IN so_kvgr3 AND
             b~vtweg EQ '10'.
    ELSE.
      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart b~kdgrp a~zuonr
             a~gsber a~augbl a~zfbdt a~zterm a~cpudt a~xref2 a~anln1
             p~vkbur b~kvgr3
        INTO CORRESPONDING FIELDS OF TABLE i_itab
        FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                         p~posnr = '000010'
                       JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr IN so_kunnr AND
              a~budat LE pa_gstid AND
              a~umskz EQ space    AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              p~vkbur IN so_gsber AND
              b~kdgrp IN so_kdgrp AND
              b~kvgr3 IN so_kvgr3 AND
              b~vtweg EQ '10'.

      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart a~xref2 b~kdgrp
             a~augdt a~zuonr a~gsber a~augbl a~zfbdt a~zterm a~cpudt
             a~anln1 p~vkbur b~kvgr3
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                         p~posnr = '000010'
                       JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        WHERE a~bukrs EQ pa_bukrs   AND
              a~kunnr IN so_kunnr   AND
              a~budat LE pa_gstid   AND
              a~augdt GE lv_gerdat  AND
              a~umskz EQ space      AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              p~vkbur IN so_gsber AND
              b~kdgrp IN so_kdgrp AND
              b~kvgr3 IN so_kvgr3 AND
              b~vtweg EQ '10'.

      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart b~kdgrp a~zuonr
             a~gsber a~augbl a~zfbdt a~zterm a~cpudt a~xref2 a~anln1
             p~vkbur b~kvgr3
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                         p~posnr = '000010'
                       JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr IN so_kunnr AND
              a~budat LE pa_gstid AND
              a~umskz IN so_umskz AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              p~vkbur IN so_gsber AND
              b~kdgrp IN so_kdgrp AND
              b~kvgr3 IN so_kvgr3 AND
              b~vtweg EQ '10'.

      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart a~xref2 b~kdgrp
             a~zuonr a~augdt a~augbl a~gsber a~zfbdt a~zterm a~cpudt
             a~anln1 p~vkbur b~kvgr3
       APPENDING CORRESPONDING FIELDS OF TABLE i_itab
       FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                        p~posnr = '000010'
                      JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
       WHERE a~bukrs EQ pa_bukrs AND
             a~kunnr IN so_kunnr AND
             a~budat LE pa_gstid AND
             a~augdt GE lv_gerdat AND
             a~umskz IN so_umskz   AND
             a~blart IN ('RV','DR','ZA','DA','DZ') AND
             p~vkbur IN so_gsber AND
             b~kdgrp IN so_kdgrp AND
             b~kvgr3 IN so_kvgr3 AND
             b~vtweg EQ '10'.
    ENDIF.
  ENDIF.

  IF x_norm EQ 'X' AND x_shbv EQ space.
    IF x_opdr IS INITIAL.
      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart b~kdgrp a~zuonr
             a~gsber a~augbl a~zfbdt a~zterm a~cpudt a~xref2 a~anln1
             b~vkbur b~kvgr3
        INTO CORRESPONDING FIELDS OF TABLE i_itab
        FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr IN so_kunnr AND
              a~budat LE pa_gstid AND
              a~umskz EQ space    AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              b~vkbur IN so_gsber AND
              b~kdgrp IN so_kdgrp AND
              b~kvgr3 IN so_kvgr3 AND
              b~vtweg EQ '10'.

      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart a~xref2 b~kdgrp
             a~zuonr a~augdt a~gsber a~augbl a~zfbdt a~zterm a~cpudt
             a~anln1 b~vkbur b~kvgr3
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        FROM bsad AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr IN so_kunnr AND
              a~budat LE pa_gstid AND
              a~augdt GE lv_gerdat AND
              a~umskz EQ space     AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              b~vkbur IN so_gsber AND
              b~kdgrp IN so_kdgrp AND
              b~kvgr3 IN so_kvgr3 AND
              b~vtweg EQ '10'.
    ELSE.
      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart b~kdgrp a~zuonr
             a~gsber a~augbl a~zfbdt a~zterm a~cpudt a~xref2 a~anln1
             p~vkbur b~kvgr3
        INTO CORRESPONDING FIELDS OF TABLE i_itab
        FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                         p~posnr = '000010'
                       JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr IN so_kunnr AND
              a~budat LE pa_gstid AND
              a~umskz EQ space    AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              p~vkbur IN so_gsber AND
              b~kdgrp IN so_kdgrp AND
              b~kvgr3 IN so_kvgr3 AND
              b~vtweg EQ '10'.

      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart a~xref2 b~kdgrp
             a~zuonr a~augdt a~gsber a~augbl a~zfbdt a~zterm a~cpudt
             a~anln1 p~vkbur b~kvgr3
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                         p~posnr = '000010'
                       JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr IN so_kunnr AND
              a~budat LE pa_gstid AND
              a~augdt GE lv_gerdat AND
              a~umskz EQ space     AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              p~vkbur IN so_gsber AND
              b~kdgrp IN so_kdgrp AND
              b~kvgr3 IN so_kvgr3 AND
              b~vtweg EQ '10'.
    ENDIF.
  ENDIF.

  IF x_norm EQ space AND x_shbv EQ 'X'.
    IF x_opdr IS INITIAL.
      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart b~kdgrp a~zuonr
             a~gsber a~augbl a~zfbdt a~zterm a~cpudt a~xref2 a~anln1
             b~vkbur b~kvgr3
        INTO CORRESPONDING FIELDS OF TABLE i_itab
        FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr IN so_kunnr AND
              a~budat LE pa_gstid AND
              a~umskz IN so_umskz  AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              b~vkbur IN so_gsber AND
              b~kdgrp IN so_kdgrp AND
              b~kvgr3 IN so_kvgr3 AND
              b~vtweg EQ '10'.

      SELECT a~bukrs a~umskz a~gsber a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart a~xref2 b~kdgrp a~zuonr
             a~augdt a~augbl a~zfbdt a~zterm a~cpudt a~anln1 b~vkbur b~kvgr3
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        FROM bsad AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr IN so_kunnr AND
              a~budat LE pa_gstid AND
              a~augdt GE lv_gerdat AND
              a~umskz IN so_umskz   AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              b~vkbur IN so_gsber AND
              b~kdgrp IN so_kdgrp AND
              b~kvgr3 IN so_kvgr3 AND
              b~vtweg EQ '10'.
    ELSE.
      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart b~kdgrp a~zuonr
             a~gsber a~augbl a~zfbdt a~zterm a~cpudt a~xref2 a~anln1
             p~vkbur b~kvgr3
        INTO CORRESPONDING FIELDS OF TABLE i_itab
        FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                         p~posnr = '000010'
                       JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr IN so_kunnr AND
              a~budat LE pa_gstid AND
              a~umskz IN so_umskz  AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              p~vkbur IN so_gsber AND
              b~kdgrp IN so_kdgrp AND
              b~kvgr3 IN so_kvgr3 AND
              b~vtweg EQ '10'.

      SELECT a~bukrs a~umskz a~gsber a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart a~xref2 b~kdgrp a~zuonr
             a~augdt a~augbl a~zfbdt a~zterm a~cpudt a~anln1 p~vkbur b~kvgr3
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                         p~posnr = '000010'
                       JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr IN so_kunnr AND
              a~budat LE pa_gstid AND
              a~augdt GE lv_gerdat AND
              a~umskz IN so_umskz   AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              p~vkbur IN so_gsber AND
              b~kdgrp IN so_kdgrp AND
              b~kvgr3 IN so_kvgr3 AND
              b~vtweg EQ '10'.
    ENDIF.
  ENDIF.

*  PERFORM f_dn_number USING '1022000938'.
ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_BELNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_belnr.
  DATA: l_period(6).
*  REFRESH I_BELNR.
*  CLEAR: WA_CEK.
*  LOOP AT I_CEK INTO WA_CEK
*    WHERE VKBUR EQ VA_PERIOD+0(4) AND
*          BUDAT GE TA_DATE-LOW   AND
*          BUDAT LT TA_DATE-HIGH.
*
*      MOVE WA_CEK-BELNR TO WA_BELNR-BELNR.
*      MOVE WA_CEK-SHKZG TO WA_BELNR-SHKZG.
*      MOVE WA_CEK-KUNNR TO WA_BELNR-KUNNR.
*      MOVE WA_CEK-KOLOM1 TO WA_BELNR-KOLOM1.
*      MOVE WA_CEK-KOLOM2 TO WA_BELNR-KOLOM2.
*      MOVE WA_CEK-KOLOM3 TO WA_BELNR-KOLOM3.
*      MOVE WA_CEK-KOLOM4 TO WA_BELNR-KOLOM4.
*      MOVE WA_CEK-KOLOM5 TO WA_BELNR-KOLOM5.
*      MOVE WA_CEK-KOLOM6 TO WA_BELNR-KOLOM6.
*      MOVE WA_CEK-KOLOM7 TO WA_BELNR-KOLOM7.
*      MOVE WA_CEK-KOLOM8 TO WA_BELNR-KOLOM8.
*      MOVE WA_CEK-OTHER TO WA_BELNR-OTHER.
*
*      WA_BELNR-SALDO = WA_BELNR-KOLOM1 + WA_BELNR-KOLOM2 +
*                       WA_BELNR-KOLOM3 + WA_BELNR-KOLOM4 +
*                       WA_BELNR-KOLOM5 + WA_BELNR-KOLOM6 +
*                       WA_BELNR-KOLOM7 + WA_BELNR-KOLOM8 +
*                       WA_BELNR-OTHER.
*      APPEND WA_BELNR TO I_BELNR.
*      CLEAR: WA_CEK.
*  ENDLOOP.
  REFRESH i_belnr.
  CLEAR: wa_all.
  CONCATENATE va_period+9(4) va_bulan3 INTO l_period.
  SORT i_all BY period.
  LOOP AT i_all INTO wa_all
     WHERE vkbur EQ va_period+0(4) AND
           period EQ l_period.
*    WHERE vkbur EQ va_period+0(4) AND
*          budat GE ta_date-low   AND
*          budat LT ta_date-high.

    MOVE wa_all-belnr TO wa_belnr-belnr.
    MOVE wa_all-zuonr TO wa_belnr-zuonr.
    MOVE wa_all-shkzg TO wa_belnr-shkzg.
    MOVE wa_all-kunnr TO wa_belnr-kunnr.
    MOVE wa_all-kolom1 TO wa_belnr-kolom1.
    MOVE wa_all-kolom2 TO wa_belnr-kolom2.
    MOVE wa_all-kolom3 TO wa_belnr-kolom3.
    MOVE wa_all-kolom4 TO wa_belnr-kolom4.
    MOVE wa_all-kolom5 TO wa_belnr-kolom5.
    MOVE wa_all-kolom6 TO wa_belnr-kolom6.
    MOVE wa_all-kolom7 TO wa_belnr-kolom7.
    MOVE wa_all-kolom8 TO wa_belnr-kolom8.
    MOVE wa_all-other TO wa_belnr-other.

    wa_belnr-saldo = wa_belnr-kolom1 + wa_belnr-kolom2 +
                     wa_belnr-kolom3 + wa_belnr-kolom4 +
                     wa_belnr-kolom5 + wa_belnr-kolom6 +
                     wa_belnr-kolom7 + wa_belnr-kolom8 +
                     wa_belnr-other.
    APPEND wa_belnr TO i_belnr.
    CLEAR: wa_all.
  ENDLOOP.
ENDFORM.                    " GET_DATA_BELNR

*&---------------------------------------------------------------------*
*&      Form  PROSES_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proses_data.
  DATA: sw.
  DATA: i_itab2   TYPE ta_itab OCCURS 0,
        wa_itab2  TYPE ta_itab.
  DATA: l_gjahr   LIKE bsid-gjahr,
        l_monat   LIKE bsid-monat,
        l_flag    TYPE i,
        l_subrc   LIKE sy-subrc,
        l_budat   LIKE bsid-budat.
  DATA: lt_bsid   TYPE ta_itab OCCURS 0,
        ls_bsid   TYPE ta_itab,
        ls_itab1  TYPE ta_itab.

  LOOP AT i_itab INTO wa_itab.
    SHIFT wa_itab-zuonr LEFT DELETING LEADING space.
*    wa_itab-zuonr  = wa_itab-zuonr(10).
    wa_itab-zuonr  = wa_itab-zuonr.
    wa_itab-vbeln  = wa_itab-vbeln.
    MODIFY i_itab FROM wa_itab TRANSPORTING zuonr vbeln.
    CASE wa_itab-blart.
      WHEN 'RV' OR 'ZA'.
        APPEND wa_itab TO i_itab1.
      WHEN 'DA'.
        APPEND wa_itab TO gt_bsid.
      WHEN 'DR'.
        IF wa_itab-augbl IS INITIAL.
          APPEND wa_itab TO lt_bsid.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  i_itab3[] = i_itab[].
  SORT i_itab3 BY vkbur zuonr kunnr budat.
  DELETE ADJACENT DUPLICATES FROM i_itab3 COMPARING vkbur zuonr kunnr.

  sw = 0.
  CLEAR: wa_itab.
  CLEAR: l_gjahr, l_monat.
  SORT i_itab BY vkbur zuonr kunnr gjahr monat zfbdt shkzg.
  LOOP AT i_itab INTO wa_itab.
    ON CHANGE OF wa_itab-vkbur OR
                 wa_itab-zuonr OR
                 wa_itab-kunnr.
      IF sw = 1.
        wa_itab2-gjahr = l_gjahr.
        wa_itab2-monat = l_monat.
        APPEND wa_itab2 TO i_itab2.
        CLEAR: sw1, l_gjahr, l_monat.
      ENDIF.
      MOVE-CORRESPONDING wa_itab TO wa_itab2.
      l_gjahr = wa_itab-gjahr.
      l_monat = wa_itab-monat.
      CLEAR: wa_itab2-dmbtr.
    ENDON.
    sw = 1.
    IF wa_itab-shkzg = 'H'.
      wa_itab-dmbtr = wa_itab-dmbtr * -1.
    ENDIF.
    ADD wa_itab-dmbtr TO wa_itab2-dmbtr.
    CLEAR wa_itab.
  ENDLOOP.

  IF sw = 1.
    wa_itab2-gjahr = l_gjahr.
    wa_itab2-monat = l_monat.
    APPEND wa_itab2 TO i_itab2.
    CLEAR: sw1, l_gjahr, l_monat.
  ENDIF.
  DELETE i_itab2 WHERE dmbtr = 0.
  REFRESH: i_itab.
  CLEAR: i_itab.
  APPEND LINES OF i_itab2 TO i_itab.
  REFRESH: i_itab2.
  CLEAR: i_itab2.

  CLEAR: wa_itab.
  SORT i_itab BY vkbur zuonr.
  SORT i_itab1 BY vkbur zuonr cpudt DESCENDING belnr DESCENDING.
  SORT i_itab3 BY vkbur zuonr budat.

  LOOP AT i_itab INTO wa_itab.
    MOVE-CORRESPONDING wa_itab TO wa_all.
*    wa_all-vkbur  = wa_itab-vkbur.
    IF wa_itab-vkbur EQ space.
      wa_all-vkbur = '0200'.
    ENDIF.

    CLEAR ls_bsid.
    READ TABLE lt_bsid INTO ls_bsid
                       WITH KEY vkbur = wa_all-vkbur
                                zuonr = wa_all-zuonr
                                kunnr = wa_all-kunnr.
    IF sy-subrc = 0.
      wa_all-budat  = ls_bsid-budat.
      wa_all-zterm  = ls_bsid-zterm.
    ENDIF.

    IF pa_bukrs = '8070'.
      IF wa_all-blart = 'DZ'.
        CLEAR ls_itab1.
        READ TABLE i_itab1 INTO ls_itab1
                           WITH KEY vkbur = wa_all-vkbur
                                    zuonr = wa_all-zuonr
                                    kunnr = wa_all-kunnr.
        IF sy-subrc = 0.
          wa_all-budat  = ls_itab1-budat.
          wa_all-zterm  = ls_itab1-zterm.
        ENDIF.
      ENDIF.
    ENDIF.

    READ TABLE i_tvkol WITH KEY vstel = wa_all-vkbur.
    IF sy-subrc EQ 0.
      l_flag  = 1.
      IF i_tvkol-mixlive IS INITIAL.
        IF i_tvkol-live EQ 'X'.
          PERFORM f_get_rv_data USING l_flag
                                      wa_all-zuonr
                                      'RV' wa_itab-umskz
                                CHANGING l_subrc.
        ELSE.
          PERFORM f_get_rv_data USING l_flag
                                      wa_all-zuonr
                                      'ZA' wa_itab-umskz
                                CHANGING l_subrc.
        ENDIF.
      ELSE.
        PERFORM f_get_rv_data USING l_flag
                                    wa_all-zuonr
                                    'ZA' wa_itab-umskz
                              CHANGING l_subrc.
        IF l_subrc NE 0.
          PERFORM f_get_rv_data USING l_flag
                                      wa_all-zuonr
                                      'RV' wa_itab-umskz
                                CHANGING l_subrc.
        ENDIF.
      ENDIF.
    ENDIF.

*    CONCATENATE  wa_itab-gjahr wa_itab-monat
*      INTO wa_all-period.
    CONCATENATE  wa_all-gjahr wa_all-monat
      INTO wa_all-period.

    CASE wa_itab-kdgrp.
      WHEN '01'.
        MOVE wa_itab-dmbtr TO wa_all-kolom1.
      WHEN '02'.
        MOVE wa_itab-dmbtr TO wa_all-kolom2.
      WHEN '03'.
        MOVE wa_itab-dmbtr TO wa_all-kolom3.
      WHEN '04'.
        MOVE wa_itab-dmbtr TO wa_all-kolom4.
      WHEN '05'.
        MOVE wa_itab-dmbtr TO wa_all-kolom5.
      WHEN '06'.
        MOVE wa_itab-dmbtr TO wa_all-kolom6.
      WHEN '07'.
        MOVE wa_itab-dmbtr TO wa_all-kolom1.
      WHEN '08'.
        MOVE wa_itab-dmbtr TO wa_all-kolom7.
      WHEN '09'.
        MOVE wa_itab-dmbtr TO wa_all-kolom8.
      WHEN 'BR'.
        MOVE wa_itab-dmbtr TO wa_all-other.
      WHEN 'SB'.
        MOVE wa_itab-dmbtr TO wa_all-other.
      WHEN space.
        MOVE wa_itab-dmbtr TO wa_all-other.
*{   INSERT         P01K900245                                        1
      WHEN '10'.
        MOVE wa_itab-dmbtr TO wa_all-other.
      WHEN OTHERS.
        MOVE wa_itab-dmbtr TO wa_all-other.
*}   INSERT
    ENDCASE.

    APPEND wa_all TO i_all.
    CLEAR: wa_itab.
  ENDLOOP.

  IF radio1 EQ 'X'.
    SORT i_all BY vkbur gjahr monat.
    LOOP AT i_all INTO wa_all.
      wa_all1-vkbur   = wa_all-vkbur.
      wa_all1-period  = wa_all-period.
      wa_all1-kolom1  = wa_all-kolom1.
      wa_all1-kolom2  = wa_all-kolom2.
      wa_all1-kolom3  = wa_all-kolom3.
      wa_all1-kolom4  = wa_all-kolom4.
      wa_all1-kolom5  = wa_all-kolom5.
      wa_all1-kolom6  = wa_all-kolom6.
      wa_all1-kolom7  = wa_all-kolom7.
      wa_all1-kolom8  = wa_all-kolom8.
      wa_all1-other   = wa_all-other.
      COLLECT wa_all1 INTO i_all1.
      CLEAR: wa_all1.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " PROSES_DATA

*&---------------------------------------------------------------------*
*&      Form  CETAK_MAIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_main.
  CLEAR: wa_all1.
  SORT i_all1 BY vkbur period.
  LOOP AT i_all1 INTO wa_all1.
    ADD wa_all1-kolom1   TO kolom1.
    ADD wa_all1-kolom2   TO kolom2.
    ADD wa_all1-kolom3   TO kolom3.
    ADD wa_all1-kolom4   TO kolom4.
    ADD wa_all1-kolom5   TO kolom5.
    ADD wa_all1-kolom6   TO kolom6.
    ADD wa_all1-kolom7   TO kolom7.
    ADD wa_all1-kolom8   TO kolom8.
    ADD wa_all1-other    TO other.

    ON CHANGE OF wa_all1-vkbur.
      IF sw = 0.
        sw = 1.
      ELSE.
        FORMAT INTENSIFIED ON.
        FORMAT COLOR OFF.
*{   REPLACE        P01K900245                                        2
*\        WRITE:/    SY-ULINE(203),
*        WRITE:/    sy-uline(207),
        WRITE:/    sy-uline(215),
*}   REPLACE
              /    sy-vline, (29) 'TOTAL',
                   sy-vline NO-GAP, total_kolom1 CURRENCY 'IDR' NO-GAP,
                   sy-vline NO-GAP, total_kolom2 CURRENCY 'IDR' NO-GAP,
                   sy-vline NO-GAP, total_kolom3 CURRENCY 'IDR' NO-GAP,
                   sy-vline NO-GAP, total_kolom4 CURRENCY 'IDR' NO-GAP,
                   sy-vline NO-GAP, total_kolom5 CURRENCY 'IDR' NO-GAP,
                   sy-vline NO-GAP, total_kolom6 CURRENCY 'IDR' NO-GAP,
                   sy-vline NO-GAP, total_kolom7 CURRENCY 'IDR' NO-GAP,
                   sy-vline NO-GAP, total_kolom8 CURRENCY 'IDR' NO-GAP,
*{   REPLACE        P01K900245                                        1
*\                   SY-VLINE NO-GAP, TOTAL_OTHER CURRENCY 'IDR' NO-GAP,
                   sy-vline, (18) total_other CURRENCY 'IDR',
*}   REPLACE
                   sy-vline NO-GAP, total_kolom_saldo CURRENCY 'IDR'
                            NO-GAP,
                   sy-vline.
*{   REPLACE        P01K900245                                        3
*\        WRITE:/    SY-ULINE(203).
*        WRITE:/    sy-uline(207).
        WRITE:/    sy-uline(215).
*}   REPLACE
        CLEAR: total_kolom1, total_kolom2, total_kolom3, total_kolom4,
               total_kolom5, total_kolom6, total_kolom7, total_kolom8,
               total_other, total_kolom_saldo.
      ENDIF.

      zebra = 0.
      NEW-PAGE.
    ENDON.

    AT END OF period.
      MOVE wa_all1-period+4(2) TO va_bulan.
      PERFORM bulan.
      CONCATENATE va_bulan_text wa_all1-period+0(4)
        INTO va_period SEPARATED BY space.
      CONCATENATE wa_all1-vkbur va_period
        INTO va_period SEPARATED BY '|'.
      kolom_saldo = kolom1 + kolom2 + kolom3 + kolom4 + kolom5 + kolom6
                    + kolom7 + kolom8 + other.

      IF zebra = 0.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR 2.
        zebra = 1.
      ELSE.
        FORMAT COLOR 1.
        zebra = 0.
      ENDIF.

      ADD kolom1      TO total_kolom1.
      ADD kolom2      TO total_kolom2.
      ADD kolom3      TO total_kolom3.
      ADD kolom4      TO total_kolom4.
      ADD kolom5      TO total_kolom5.
      ADD kolom6      TO total_kolom6.
      ADD kolom7      TO total_kolom7.
      ADD kolom8      TO total_kolom8.
      ADD other       TO total_other.
      ADD kolom_saldo TO total_kolom_saldo.

*      WRITE:/   sy-vline, (29) va_period HOTSPOT,
      WRITE:/   sy-vline, (37) va_period HOTSPOT,
                sy-vline NO-GAP, kolom1 CURRENCY 'IDR' NO-GAP,
                sy-vline NO-GAP, kolom2 CURRENCY 'IDR' NO-GAP,
                sy-vline NO-GAP, kolom3 CURRENCY 'IDR' NO-GAP,
                sy-vline NO-GAP, kolom4 CURRENCY 'IDR' NO-GAP,
                sy-vline NO-GAP, kolom5 CURRENCY 'IDR' NO-GAP,
                sy-vline NO-GAP, kolom6 CURRENCY 'IDR' NO-GAP,
                sy-vline NO-GAP, kolom7 CURRENCY 'IDR' NO-GAP,
                sy-vline NO-GAP, kolom8 CURRENCY 'IDR' NO-GAP,
*{   REPLACE        P01K900245                                        4
*\                SY-VLINE NO-GAP, OTHER CURRENCY 'IDR' NO-GAP,
                sy-vline, (18) other CURRENCY 'IDR',
*}   REPLACE
                sy-vline NO-GAP, kolom_saldo CURRENCY 'IDR' NO-GAP,
                sy-vline.

      CLEAR: kolom1, kolom2, kolom3, kolom4, kolom5, kolom6, kolom7,
             kolom8, other, kolom_saldo.
    ENDAT.
    CLEAR: wa_all1.
  ENDLOOP.

  FORMAT INTENSIFIED ON.
  FORMAT COLOR OFF.
*{   REPLACE        P01K900245                                        5
*\  WRITE:/    SY-ULINE(203),
*  WRITE:/    sy-uline(207),
  WRITE:/    sy-uline(215),
*}   REPLACE
*        /    sy-vline, (29) 'TOTAL',
        /    sy-vline, (37) 'TOTAL',
             sy-vline NO-GAP, total_kolom1 CURRENCY 'IDR' NO-GAP,
             sy-vline NO-GAP, total_kolom2 CURRENCY 'IDR' NO-GAP,
             sy-vline NO-GAP, total_kolom3 CURRENCY 'IDR' NO-GAP,
             sy-vline NO-GAP, total_kolom4 CURRENCY 'IDR' NO-GAP,
             sy-vline NO-GAP, total_kolom5 CURRENCY 'IDR' NO-GAP,
             sy-vline NO-GAP, total_kolom6 CURRENCY 'IDR' NO-GAP,
             sy-vline NO-GAP, total_kolom7 CURRENCY 'IDR' NO-GAP,
             sy-vline NO-GAP, total_kolom8 CURRENCY 'IDR' NO-GAP,
*{   REPLACE        P01K900245                                        7
*\             SY-VLINE NO-GAP, TOTAL_OTHER CURRENCY 'IDR' NO-GAP,
             sy-vline, (18) total_other CURRENCY 'IDR',
*}   REPLACE
             sy-vline NO-GAP, total_kolom_saldo CURRENCY 'IDR' NO-GAP,
             sy-vline.
*{   REPLACE        P01K900245                                        6
*\  WRITE:/    SY-ULINE(203).
*  WRITE:/    sy-uline(207).
  WRITE:/    sy-uline(215).
*}   REPLACE
  PERFORM write_bottom.
ENDFORM.                    " CETAK_MAIN

*&---------------------------------------------------------------------*
*&      Form  CETAK_BELNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_belnr.
  DATA: l_name1  LIKE kna1-name1.

  PERFORM header_belnr.
  CLEAR: wa_belnr.
  SORT i_belnr BY belnr.
  LOOP AT i_belnr INTO wa_belnr.

    ADD wa_belnr-kolom1 TO belnr_kolom1.
    ADD wa_belnr-kolom2 TO belnr_kolom2.
    ADD wa_belnr-kolom3 TO belnr_kolom3.
    ADD wa_belnr-kolom4 TO belnr_kolom4.
    ADD wa_belnr-kolom5 TO belnr_kolom5.
    ADD wa_belnr-kolom6 TO belnr_kolom6.
    ADD wa_belnr-kolom7 TO belnr_kolom7.
    ADD wa_belnr-kolom8 TO belnr_kolom8.
    ADD wa_belnr-other  TO belnr_other.
    ADD wa_belnr-saldo  TO belnr_saldo.

    IF sy-linno EQ 59.
*      WRITE: /    sy-uline(207).
      WRITE: /    sy-uline(215).
      PERFORM header_belnr.
      zebra1 = 0.
    ENDIF.

    MOVE wa_belnr-belnr TO va_belnr.
    MOVE wa_belnr-zuonr TO va_zuonr1.

    IF wa_belnr-saldo NE 0.
      IF zebra1 = 0.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR 2.
        zebra1 = 1.
      ELSE.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR 1.
        zebra1 = 0.
      ENDIF.

      SELECT SINGLE name1
        FROM kna1
        INTO l_name1
        WHERE kunnr EQ wa_belnr-kunnr.

*      WRITE:/    sy-vline NO-GAP, (10) va_zuonr1 HOTSPOT NO-GAP,
      WRITE:/    sy-vline NO-GAP, (18) va_zuonr1 HOTSPOT NO-GAP,
*                 sy-vline NO-GAP, (10) va_belnr HOTSPOT NO-GAP ,
                 sy-vline NO-GAP, (20) l_name1 NO-GAP,
                 sy-vline NO-GAP, wa_belnr-kolom1 CURRENCY 'IDR' NO-GAP,
                 sy-vline NO-GAP, wa_belnr-kolom2 CURRENCY 'IDR' NO-GAP,
                 sy-vline NO-GAP, wa_belnr-kolom3 CURRENCY 'IDR' NO-GAP,
                 sy-vline NO-GAP, wa_belnr-kolom4 CURRENCY 'IDR' NO-GAP,
                 sy-vline NO-GAP, wa_belnr-kolom5 CURRENCY 'IDR' NO-GAP,
                 sy-vline NO-GAP, wa_belnr-kolom6 CURRENCY 'IDR' NO-GAP,
                 sy-vline NO-GAP, wa_belnr-kolom7 CURRENCY 'IDR' NO-GAP,
                 sy-vline NO-GAP, wa_belnr-kolom8 CURRENCY 'IDR' NO-GAP,
*{   REPLACE        P01K900245                                        1
*\                 SY-VLINE NO-GAP, WA_BELNR-OTHER CURRENCY 'IDR' NO-GAP,
                 sy-vline, (18) wa_belnr-other CURRENCY 'IDR',
*}   REPLACE
                 sy-vline NO-GAP, wa_belnr-saldo CURRENCY 'IDR' NO-GAP,
                 sy-vline.
      HIDE: va_belnr.
    ENDIF.
    CLEAR: wa_belnr.
  ENDLOOP.

  FORMAT INTENSIFIED ON.
  FORMAT COLOR OFF.
*  WRITE:/     sy-uline(207).
  WRITE:/     sy-uline(215).
  WRITE:/     sy-vline, 'TOTAL     ',
*         33   sy-vline NO-GAP, belnr_kolom1 CURRENCY 'IDR' NO-GAP,
         41   sy-vline NO-GAP, belnr_kolom1 CURRENCY 'IDR' NO-GAP,
              sy-vline NO-GAP, belnr_kolom2 CURRENCY 'IDR' NO-GAP,
              sy-vline NO-GAP, belnr_kolom3 CURRENCY 'IDR' NO-GAP,
              sy-vline NO-GAP, belnr_kolom4 CURRENCY 'IDR' NO-GAP,
              sy-vline NO-GAP, belnr_kolom5 CURRENCY 'IDR' NO-GAP,
              sy-vline NO-GAP, belnr_kolom6 CURRENCY 'IDR' NO-GAP,
              sy-vline NO-GAP, belnr_kolom7 CURRENCY 'IDR' NO-GAP,
              sy-vline NO-GAP, belnr_kolom8 CURRENCY 'IDR' NO-GAP,
*{   REPLACE        P01K900245                                        2
*\              SY-VLINE NO-GAP, BELNR_OTHER CURRENCY 'IDR' NO-GAP,
              sy-vline, (18) belnr_other CURRENCY 'IDR',
*}   REPLACE
              sy-vline NO-GAP, belnr_saldo CURRENCY 'IDR' NO-GAP,
              sy-vline.
*  WRITE:/     sy-uline(207).
  WRITE:/     sy-uline(215).

  FORMAT INTENSIFIED OFF.
  FORMAT COLOR OFF.
  zebra1 = 0.

  CLEAR: belnr_kolom1, belnr_kolom2, belnr_kolom3, belnr_kolom4,
         belnr_kolom5, belnr_kolom6, belnr_kolom7, belnr_kolom8,
         belnr_other, belnr_saldo.
  PERFORM write_bottom.
ENDFORM.                    " CETAK_BELNR

*&---------------------------------------------------------------------*
*&      Form  BULAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bulan.
  CASE va_bulan.
    WHEN '01'.
      va_bulan_text = 'Jan'.
    WHEN '02'.
      va_bulan_text = 'Feb'.
    WHEN '03'.
      va_bulan_text = 'Mar'.
    WHEN '04'.
      va_bulan_text = 'Apr'.
    WHEN '05'.
      va_bulan_text = 'Mei'.
    WHEN '06'.
      va_bulan_text = 'Jun'.
    WHEN '07'.
      va_bulan_text = 'Jul'.
    WHEN '08'.
      va_bulan_text = 'Aug'.
    WHEN '09'.
      va_bulan_text = 'Sep'.
    WHEN '10'.
      va_bulan_text = 'Okt'.
    WHEN '11'.
      va_bulan_text = 'Nov'.
    WHEN '12'.
      va_bulan_text = 'Des'.
  ENDCASE.

  CASE va_bulan1.
    WHEN '01'.
      va_bulan_text1 = 'Januari'.
    WHEN '02'.
      va_bulan_text1 = 'Februari'.
    WHEN '03'.
      va_bulan_text1 = 'Maret'.
    WHEN '04'.
      va_bulan_text1 = 'April'.
    WHEN '05'.
      va_bulan_text1 = 'Mei'.
    WHEN '06'.
      va_bulan_text1 = 'Juni'.
    WHEN '07'.
      va_bulan_text1 = 'Juli'.
    WHEN '08'.
      va_bulan_text1 = 'Agustus'.
    WHEN '09'.
      va_bulan_text1 = 'September'.
    WHEN '10'.
      va_bulan_text1 = 'Oktober'.
    WHEN '11'.
      va_bulan_text1 = 'November'.
    WHEN '12'.
      va_bulan_text1 = 'Desember'.
  ENDCASE.

  CASE va_bulan2.
    WHEN 'Jan'.
      va_bulan3 = '01'.
    WHEN 'Feb'.
      va_bulan3 = '02'.
    WHEN 'Mar'.
      va_bulan3 = '03'.
    WHEN 'Apr'.
      va_bulan3 = '04'.
    WHEN 'Mei'.
      va_bulan3 = '05'.
    WHEN 'Jun'.
      va_bulan3 = '06'.
    WHEN 'Jul'.
      va_bulan3 = '07'.
    WHEN 'Aug'.
      va_bulan3 = '08'.
    WHEN 'Sep'.
      va_bulan3 = '09'.
    WHEN 'Okt'.
      va_bulan3 = '10'.
    WHEN 'Nov'.
      va_bulan3 = '11'.
    WHEN 'Des'.
      va_bulan3 = '12'.
  ENDCASE.
ENDFORM.                    " BULAN

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM top_of_page.
  MOVE pa_gstid+4(2) TO va_bulan1.
  PERFORM bulan.
  CONCATENATE pa_gstid+6(2) va_bulan_text1 pa_gstid+0(4) INTO va_period1
    SEPARATED BY space.

  SELECT SINGLE bezei
    FROM tvkbt
    INTO va_gtext
    WHERE spras EQ sy-langu AND
          vkbur EQ wa_all1-vkbur.

  SELECT SINGLE butxt
    FROM t001
    INTO va_butxt
    WHERE bukrs EQ pa_bukrs.

  WRITE:/    va_butxt,
*        /83  'DAFTAR FAKTUR TERBUKA',
        185  'Page :', sy-pagno,
        /    'Sales Office : ', wa_all1-vkbur, '-', va_gtext,
         83  'DAFTAR FAKTUR TERBUKA',
        185  'Date :', sy-datum,
*        /    'Branch           : ', VA_GTEXT,
        /    'UserID       : ', sy-uname, '/', sy-tcode,
         83  'as of : ', va_period1,
        185  'Time :', sy-uzeit.

  PERFORM header_main.
ENDFORM.                    " TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  HEADER_MAIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header_main.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR 1.
*{   REPLACE        P01K900245                                        3
*\  WRITE:/    SY-ULINE(203).
*  WRITE:/    sy-uline(207).
  WRITE:/    sy-uline(215).
*}   REPLACE
  WRITE:/    sy-vline.
  c1 = 1.
  c1 = c1 + 1.
*  c1 = c1 + w1.
  c1 = c1 + w1 + 8.
  WRITE AT c1 sy-vline.
  c1 = c1 + 1.  SET LEFT SCROLL-BOUNDARY.
  WRITE AT c1(w2) 'GROUP 1 & 7' RIGHT-JUSTIFIED. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w3) 'GROUP 2' RIGHT-JUSTIFIED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w4) 'GROUP 3' RIGHT-JUSTIFIED. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w5) 'GROUP 4' RIGHT-JUSTIFIED. c1 = c1 + w5.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w6) 'GROUP 5' RIGHT-JUSTIFIED. c1 = c1 + w6.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w7) 'GROUP 6' RIGHT-JUSTIFIED. c1 = c1 + w7.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w8) 'GROUP 8' RIGHT-JUSTIFIED. c1 = c1 + w8.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w9) 'GROUP 9' RIGHT-JUSTIFIED. c1 = c1 + w9.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
*{   REPLACE        P01K900245                                        1
*\  WRITE AT C1(W10) 'OTHER'  RIGHT-JUSTIFIED. C1 = C1 + W10.
  WRITE AT c1(w9a) 'GROUP 10'  RIGHT-JUSTIFIED. c1 = c1 + w9a.
*}   REPLACE
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w12) 'TOTAL'  RIGHT-JUSTIFIED. c1 = c1 + w12.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.

  WRITE:/    sy-vline.
  c1 = 1.
  c1 = c1 + 1.
*  c1 = c1 + w1.
  c1 = c1 + w1 + 8.
  WRITE AT c1 sy-vline.
  c1 = c1 + 1.
  WRITE AT c1(w2) 'CORPORATE' RIGHT-JUSTIFIED. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w3) 'PBF/TENDER' RIGHT-JUSTIFIED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w4) 'SUPERMARKET' RIGHT-JUSTIFIED. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w5) 'TOKO OBAT' RIGHT-JUSTIFIED. c1 = c1 + w5.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w6) 'GROSSIR' RIGHT-JUSTIFIED. c1 = c1 + w6.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w7) 'DCS/HTH' RIGHT-JUSTIFIED. c1 = c1 + w7.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w8) 'DOKTER/RS' RIGHT-JUSTIFIED. c1 = c1 + w8.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w9) 'APOTIK' RIGHT-JUSTIFIED. c1 = c1 + w9.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
*{   REPLACE        P01K900245                                        6
*\  C1 = C1 + W10.
  WRITE AT c1(w9a) 'SUPER RETAIL/OTHERS' RIGHT-JUSTIFIED. c1 = c1 + w9a.
*}   REPLACE
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.
  WRITE AT c1(w12) 'SALDO' RIGHT-JUSTIFIED. c1 = c1 + w12.
  WRITE AT c1(1) sy-vline. c1 = c1 + 1.

*{   REPLACE        P01K900245                                        5
*\  WRITE:/    SY-ULINE(203).
*  WRITE:/    sy-uline(207).
  WRITE:/    sy-uline(215).
*}   REPLACE
  FORMAT INTENSIFIED OFF.
ENDFORM.                    " HEADER_MAIN

*&---------------------------------------------------------------------*
*&      Form  HEADER_BELNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header_belnr.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR OFF.
  MOVE pa_gstid+4(2) TO va_bulan1.
  PERFORM bulan.
  CONCATENATE pa_gstid+6(2) va_bulan_text1 pa_gstid+0(4) INTO va_period1
    SEPARATED BY space.

  SELECT SINGLE gtext
    FROM tgsbt
    INTO va_gtext
    WHERE gsber EQ va_period+0(4).

  SELECT SINGLE butxt
    FROM t001
    INTO va_butxt
    WHERE bukrs EQ pa_bukrs.

  WRITE:/    va_butxt,
*        /83  'DAFTAR FAKTUR TERBUKA',
        185  'Page :', sy-pagno,
        /    'Branch           : ', va_gtext,
         83  'DAFTAR FAKTUR TERBUKA',
        185  'Date :', sy-datum,
*        /    'Branch           : ', VA_GTEXT,
        /    'Period           : ', va_period+5(8),
         80  'POSISI A/R BULAN : ', va_period1,
        185  'Time :', sy-uzeit,
*        /    'Period           : ', VA_PERIOD+5(8).
        /    'UserID           : ', sy-uname, '/', sy-tcode.

  PERFORM header_main.
ENDFORM.                    " HEADER_BELNR

*&---------------------------------------------------------------------*
*&      Form  INIT_COLUMN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_column.
  w1   =  31.
  w2   =  16.
  w3   =  16.
  w4   =  16.
  w5   =  16.
  w6   =  16.
  w7   =  16.
  w8   =  16.
  w9   =  16.
*{   INSERT         P01K900245                                        1
  w9a   =  20.
*}   INSERT
  w10  =  16.
  w11  =  16.
  w12  =  16.
  c1 = 0.

ENDFORM.                    " INIT_COLUMN

*&---------------------------------------------------------------------*
*&      Form  CEK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek.
  DATA l_gsber LIKE bsid-gsber.

  SELECT a~vstel b~live b~mixlive a~werks a~lgort INTO TABLE i_tvkol FROM tvkol AS a
           JOIN zplbc AS b ON b~werks EQ a~werks AND
                              b~lgort EQ a~lgort
      WHERE vstel IN so_gsber.

  DELETE i_tvkol WHERE  vstel(2) NE '02'.
  DELETE i_tvkol WHERE  vstel    EQ '0200'.

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
    'You have no authorization for Sales Office' l_gsber.
  ENDIF.
ENDFORM.                    " CEK

*&---------------------------------------------------------------------*
*&      Form  PROSES_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proses_alv.
  DATA: l_name1(50),
        l_niels(2),
        l_year(4),
        l_2year(8),
        l_year1(4),
        l_quart11(6),
        l_feb(6),
        l_quart12(6),
        l_quart21(6),
        l_mei(6),
        l_quart22(6),
        l_quart31(6),
        l_aug(6),
        l_quart32(6),
        l_quart41(6),
        l_nov(6),
        l_quart42(6),
        l_jan2(6),
        l_feb2(6),
        l_mar2(6),
        l_apr2(6),
        l_mei2(6),
        l_jun2(6),
        l_jul2(6),
        l_aug2(6),
        l_sep2(6),
        l_okt2(6),
        l_nov2(6),
        l_des2(6),
        l_counter  TYPE i,
        l_ztag1    LIKE t052-ztag1,
        l_flag     TYPE i,
        l_subrc    LIKE sy-subrc.

  DATA : ls_knkk        LIKE LINE OF gt_knkk,
         ls_vbrk        LIKE LINE OF gt_vbrk,
         ls_itab        LIKE LINE OF i_itab,
         ls_zfbicheck   LIKE LINE OF gt_zfbicheck,
         ls_zfbic_sfa   LIKE LINE OF gt_zfbic_sfa,
         ls_hsales      LIKE LINE OF gt_hsales,
         ls_knvpzc      LIKE LINE OF gt_knvpzc,
         ls_knvpzp      LIKE LINE OF gt_knvpzp,
         ls_pa0001      LIKE LINE OF gt_pa0001,
         ls_bsid        LIKE LINE OF gt_bsid.

  l_year    = pa_gstid(4) - 2.
  l_year1   = pa_gstid(4) - 1.
  CONCATENATE l_year '1231' INTO l_2year.

* quarter 1
  CONCATENATE l_year1 '01' INTO l_quart11.
  CONCATENATE l_year1 '02' INTO l_feb.
  CONCATENATE l_year1 '03' INTO l_quart12.
* quarter 2
  CONCATENATE l_year1 '04' INTO l_quart21.
  CONCATENATE l_year1 '05' INTO l_mei.
  CONCATENATE l_year1 '06' INTO l_quart22.
* quarter 3
  CONCATENATE l_year1 '07' INTO l_quart31.
  CONCATENATE l_year1 '08' INTO l_aug.
  CONCATENATE l_year1 '09' INTO l_quart32.
* quarter 4
  CONCATENATE l_year1 '10' INTO l_quart41.
  CONCATENATE l_year1 '11' INTO l_nov.
  CONCATENATE l_year1 '12' INTO l_quart42.

* Januari
  CONCATENATE pa_gstid(4) '01' INTO l_jan2.
* Februari
  CONCATENATE pa_gstid(4) '02' INTO l_feb2.
* Maret
  CONCATENATE pa_gstid(4) '03' INTO l_mar2.
* April
  CONCATENATE pa_gstid(4) '04' INTO l_apr2.
* Mei
  CONCATENATE pa_gstid(4) '05' INTO l_mei2.
* Juni
  CONCATENATE pa_gstid(4) '06' INTO l_jun2.
* Juli
  CONCATENATE pa_gstid(4) '07' INTO l_jul2.
* Agustus
  CONCATENATE pa_gstid(4) '08' INTO l_aug2.
* September
  CONCATENATE pa_gstid(4) '09' INTO l_sep2.
* Oktober
  CONCATENATE pa_gstid(4) '10' INTO l_okt2.
* November
  CONCATENATE pa_gstid(4) '11' INTO l_nov2.
* Desember
  CONCATENATE pa_gstid(4) '12' INTO l_des2.

  PERFORM f_get_ttf.

  PERFORM f_get_additional_field.

  CLEAR: wa_all.
  SORT i_all BY vkbur kunnr.
  SORT gt_zfbid BY vkbur kunnr zuonr.
  SORT gt_bsid BY kunnr zuonr gjahr belnr.
  LOOP AT i_all INTO wa_all.
    l_counter = 0.
    SELECT SINGLE name1 niels
      FROM kna1
      INTO (l_name1, l_niels)
      WHERE kunnr EQ wa_all-kunnr.

    SELECT SINGLE bezei
      FROM tnlst
      INTO i_out-bezei
      WHERE spras EQ sy-langu AND
            niels EQ l_niels.

    SELECT SINGLE bezei
      FROM tvkbt
      INTO i_out-gtext
      WHERE spras EQ sy-langu AND
            vkbur EQ wa_all-vkbur.

    CONCATENATE wa_all-kunnr l_name1 INTO i_out-name1
      SEPARATED BY '-'.

    i_out-vkbur  = wa_all-vkbur.
    i_out-gjahr  = wa_all-gjahr.
    i_out-period = wa_all-period.
    i_out-zfbdt  = wa_all-zfbdt.
    i_out-kunnr  = wa_all-kunnr.
    i_out-kdgrp  = wa_all-kdgrp.
    i_out-belnr  = wa_all-belnr.
    i_out-zuonr  = wa_all-zuonr.
    i_out-anln1  = wa_all-anln1.
    i_out-zterm  = wa_all-zterm.
    i_out-budat  = wa_all-budat.
    i_out-xref2  = wa_all-xref2.
    CLEAR: l_ztag1.
    SELECT SINGLE ztag1 INTO l_ztag1 FROM t052
                   WHERE zterm = wa_all-zterm.
    i_out-duedt = wa_all-zfbdt + l_ztag1.

*
*    IF wa_all-shkzg EQ 'H'.
*      i_out-dmbtr = wa_all-dmbtr * -1.
*    ELSE.
    i_out-dmbtr = wa_all-dmbtr.
*    ENDIF.

*  < 2 tahun
    IF wa_all-gjahr LE l_year.
      i_out-kolom01 = i_out-dmbtr.
    ELSE.
      i_out-kolom01 = 0.
    ENDIF.

*  quarter 1
    IF wa_all-period GE l_quart11 AND
      wa_all-period LE l_quart12.
      i_out-kolom02 = i_out-dmbtr.
      IF wa_all-period EQ l_quart11.
        i_out-janytd = i_out-dmbtr.
      ENDIF.
      IF wa_all-period EQ l_feb.
        i_out-febytd = i_out-dmbtr.
      ENDIF.
      IF wa_all-period EQ l_quart12.
        i_out-marytd = i_out-dmbtr.
      ENDIF.
    ELSE.
      i_out-kolom02 = 0.
      i_out-janytd = 0.
      i_out-febytd = 0.
      i_out-marytd = 0.
    ENDIF.
*  quarter 2
    IF wa_all-period GE l_quart21 AND
      wa_all-period LE l_quart22.
      i_out-kolom03 = i_out-dmbtr.
      IF wa_all-period EQ l_quart21.
        i_out-aprytd = i_out-dmbtr.
      ENDIF.
      IF wa_all-period EQ l_mei.
        i_out-meiytd = i_out-dmbtr.
      ENDIF.
      IF wa_all-period EQ l_quart22.
        i_out-junytd = i_out-dmbtr.
      ENDIF.
    ELSE.
      i_out-kolom03 = 0.
      i_out-aprytd = 0.
      i_out-meiytd = 0.
      i_out-junytd = 0.
    ENDIF.
*  total smt 1
    i_out-kolom04 = i_out-kolom02 + i_out-kolom03.
*  quarter 3
    IF wa_all-period GE l_quart31 AND
      wa_all-period LE l_quart32.
      i_out-kolom05 = i_out-dmbtr.
      IF wa_all-period EQ l_quart31.
        i_out-julytd = i_out-dmbtr.
      ENDIF.
      IF wa_all-period EQ l_aug.
        i_out-augytd = i_out-dmbtr.
      ENDIF.
      IF wa_all-period EQ l_quart32.
        i_out-sepytd = i_out-dmbtr.
      ENDIF.
    ELSE.
      i_out-kolom05 = 0.
      i_out-julytd = 0.
      i_out-augytd = 0.
      i_out-sepytd = 0.
    ENDIF.
*  quarter 4
    IF wa_all-period GE l_quart41 AND
      wa_all-period LE l_quart42.
      i_out-kolom06 = i_out-dmbtr.
      IF wa_all-period EQ l_quart41.
        i_out-oktytd = i_out-dmbtr.
      ENDIF.
      IF wa_all-period EQ l_nov.
        i_out-novytd = i_out-dmbtr.
      ENDIF.
      IF wa_all-period EQ l_quart42.
        i_out-desytd = i_out-dmbtr.
      ENDIF.
    ELSE.
      i_out-kolom06 = 0.
    ENDIF.
*  total tahun
    i_out-kolom07 = i_out-kolom04 + i_out-kolom05 + i_out-kolom06.
* Januari
    IF wa_all-period EQ l_jan2.
      i_out-kolom08 = i_out-dmbtr.
    ENDIF.
* Februari
    IF wa_all-period EQ l_feb2.
*      IF pa_gstid LT l_feb2.
*        i_out-kolom09 = 0.
*      ELSE.
      i_out-kolom09 = i_out-dmbtr.
*      ENDIF.
    ENDIF.
* Maret
    IF wa_all-period EQ l_mar2.
*      IF pa_gstid LT l_mar2.
*        i_out-kolom10 = 0.
*      ELSE.
      i_out-kolom10 = i_out-dmbtr.
*      ENDIF.
    ENDIF.
* total quarter 1
    i_out-kolom11 = i_out-kolom08 + i_out-kolom09 + i_out-kolom10.
* April
    IF wa_all-period EQ l_apr2.
*      IF pa_gstid LT l_apr2.
*        i_out-kolom12 = 0.
*      ELSE.
      i_out-kolom12 = i_out-dmbtr.
*      ENDIF.
    ENDIF.
* Mei
    IF wa_all-period EQ l_mei2.
*      IF pa_gstid LT l_mei2.
*        i_out-kolom13 = 0.
*      ELSE.
      i_out-kolom13 = i_out-dmbtr.
*      ENDIF.
    ENDIF.
* Jun
    IF wa_all-period EQ l_jun2.
*      IF pa_gstid LT l_jun2.
*        i_out-kolom14 = 0.
*      ELSE.
      i_out-kolom14 = i_out-dmbtr.
*      ENDIF.
    ENDIF.
* total quarter 2
    i_out-kolom15 = i_out-kolom12 + i_out-kolom13 + i_out-kolom14.
* Jul
    IF wa_all-period EQ l_jul2.
*      IF pa_gstid LT l_jul2.
*        i_out-kolom16 = 0.
*      ELSE.
      i_out-kolom16 = i_out-dmbtr.
*      ENDIF.
    ENDIF.
* Aug
    IF wa_all-period EQ l_aug2.
*      IF pa_gstid LT l_aug2.
*        i_out-kolom17 = 0.
*      ELSE.
      i_out-kolom17 = i_out-dmbtr.
*      ENDIF.
    ENDIF.
* Sep
    IF wa_all-period EQ l_sep2.
*      IF pa_gstid LT l_sep2.
*        i_out-kolom18 = 0.
*      ELSE.
      i_out-kolom18 = i_out-dmbtr.
*      ENDIF.
    ENDIF.
* total quarter 3
    i_out-kolom19 = i_out-kolom16 + i_out-kolom17 + i_out-kolom18.
* Okt
    IF wa_all-period EQ l_okt2.
*      IF pa_gstid LT l_okt2.
*        i_out-kolom20 = 0.
*      ELSE.
      i_out-kolom20 = i_out-dmbtr.
*      ENDIF.
    ENDIF.
* Nov
    IF wa_all-period EQ l_nov2.
*      IF pa_gstid LT l_nov2.
*        i_out-kolom21 = 0.
*      ELSE.
      i_out-kolom21 = i_out-dmbtr.
*      ENDIF.
    ENDIF.
* Des
    IF wa_all-period EQ l_des2.
*      IF pa_gstid LT l_des2.
*        i_out-kolom22 = 0.
*      ELSE.
      i_out-kolom22 = i_out-dmbtr.
*      ENDIF.
    ENDIF.
* total quarter 4
    i_out-kolom23 = i_out-kolom20 + i_out-kolom21 + i_out-kolom22.

* total semester 1.
    i_out-kolom24 = i_out-kolom11 + i_out-kolom15.
* total semester 2
    i_out-kolom25 = i_out-kolom19 + i_out-kolom23.
* total tahun.
    i_out-kolom26 = i_out-kolom24 + i_out-kolom25.

* Grand
    i_out-kolom99 = i_out-kolom01 + i_out-kolom07 + i_out-kolom11 +
                    i_out-kolom15 + i_out-kolom19 + i_out-kolom23.

*   Aging & TTF
    CLEAR gt_zfbid.
    LOOP AT gt_zfbid WHERE vkbur = i_out-vkbur AND
                           kunnr = i_out-kunnr AND
                           zuonr = i_out-zuonr.
      IF gt_zfbid-tglttf IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.
    i_out-tglttf = gt_zfbid-tglttf.
*    i_out-aging = pa_gstid - i_out-duedt.
    i_out-aging = pa_gstid - i_out-zfbdt.
    IF i_out-tglttf IS NOT INITIAL.
      i_out-leadttf = i_out-tglttf - i_out-zfbdt.
    ELSE.
      CLEAR i_out-leadttf.
    ENDIF.

    READ TABLE gt_knkk INTO ls_knkk
                       WITH KEY kunnr = wa_all-kunnr.
    IF sy-subrc = 0.
      i_out-klimk = ls_knkk-klimk.
    ENDIF.

    CASE wa_all-blart.
      WHEN 'DA'.
        READ TABLE gt_bsid INTO ls_bsid
                           WITH KEY kunnr = wa_all-kunnr
                                    zuonr = wa_all-zuonr.
        IF sy-subrc = 0.
          IF wa_all-umskz IS NOT INITIAL.
            i_out-awal  = 0.
          ELSE.
            i_out-awal  = 0.
          ENDIF.
        ENDIF.

        READ TABLE gt_vbrk INTO ls_vbrk
                           WITH KEY zuonr = wa_all-zuonr.
        IF sy-subrc = 0.
          i_out-fkart = ls_vbrk-fkart.
        ENDIF.

      WHEN OTHERS.
        READ TABLE gt_vbrk INTO ls_vbrk
                           WITH KEY zuonr = wa_all-zuonr.
        IF sy-subrc = 0.
          i_out-fkart = ls_vbrk-fkart.
          i_out-awal  = ls_vbrk-netwr + ls_vbrk-mwsbk.
          IF ls_vbrk-vbtyp = 'O'.
            i_out-awal  = i_out-awal * -1.
          ENDIF.
          READ TABLE gt_bsid INTO ls_bsid
                             WITH KEY kunnr = wa_all-kunnr
                                      zuonr = wa_all-zuonr
                                      blart = 'DA'.
          IF sy-subrc = 0.
            IF wa_all-umskz IS NOT INITIAL.
              i_out-awal  = 0.
*              CLEAR i_out-fkart.
            ELSE.
              i_out-awal  = 0.
*              CLEAR i_out-fkart.
            ENDIF.
          ENDIF.
        ELSE.
          READ TABLE gt_hsales INTO ls_hsales
                               WITH KEY vbeln = wa_all-zuonr
                                        gjahr = wa_all-gjahr
                                        kunnr = wa_all-kunnr.
          IF sy-subrc = 0.
            i_out-fkart = ls_hsales-fkart.
            i_out-awal  = ls_hsales-netwr.
            i_out-rlcn  = ls_hsales-slcod.
            IF ls_hsales-vbtyp = 'O'.
              i_out-awal  = i_out-awal * -1.
            ENDIF.
          ENDIF.
        ENDIF.
    ENDCASE.

    LOOP AT gt_zfbicheck INTO ls_zfbicheck WHERE kunnr = wa_all-kunnr
                                             AND zuonr = wa_all-zuonr.
      IF i_out-duedtbi <> space.
        i_out-duedtbi   = ls_zfbicheck-duedt.
      ENDIF.
      ADD ls_zfbicheck-wrbtr TO i_out-wrbtrbi.
    ENDLOOP.

    LOOP AT gt_zfbic_sfa INTO ls_zfbic_sfa WHERE kunnr = wa_all-kunnr
                                             AND zuonr = wa_all-zuonr.
      IF i_out-duedtbi <> space.
        i_out-duedtbi   = ls_zfbic_sfa-bank_dudat.
      ENDIF.
      ADD ls_zfbic_sfa-bank_amt TO i_out-wrbtrbi.
    ENDLOOP.

    READ TABLE gt_knvpzc INTO ls_knvpzc
                         WITH KEY kunnr = wa_all-kunnr.
    IF sy-subrc = 0.
      READ TABLE gt_knvpzp INTO ls_knvpzp
                           WITH KEY kunnr = ls_knvpzc-kunn2.
      IF sy-subrc = 0.
        READ TABLE gt_pa0001 INTO ls_pa0001
                             WITH KEY pernr = ls_knvpzp-pernr.
        IF sy-subrc = 0.
          CONCATENATE ls_knvpzp-kunnr '/' ls_knvpzp-pernr '/' ls_pa0001-sname
          INTO i_out-rlcn.
        ENDIF.
      ENDIF.
    ENDIF.

    IF x_rtv IS NOT INITIAL.
      PERFORM f_arpot USING wa_all-zuonr
                      CHANGING i_out-noarp i_out-rtvnr.
    ENDIF.

*    IF i_out-kolom99 NE 0.
    APPEND i_out.
*    ENDIF.

    CLEAR: i_out-kolom01, i_out-kolom02, i_out-kolom03, i_out-kolom04,
           i_out-kolom05, i_out-kolom06, i_out-kolom07, i_out-kolom08,
           i_out-kolom09, i_out-kolom10, i_out-kolom11, i_out-kolom12,
           i_out-kolom13, i_out-kolom14, i_out-kolom15, i_out-kolom16,
           i_out-kolom17, i_out-kolom18, i_out-kolom19, i_out-kolom20,
           i_out-kolom21, i_out-kolom22, i_out-kolom23, i_out-kolom24,
           i_out-kolom25, i_out-kolom26, i_out-kolom99.
    CLEAR: i_out-janytd, i_out-febytd, i_out-marytd, i_out-aprytd,
           i_out-meiytd, i_out-junytd, i_out-julytd, i_out-augytd,
           i_out-sepytd, i_out-oktytd, i_out-novytd, i_out-desytd.
    CLEAR: i_out.
    CLEAR: wa_all.
  ENDLOOP.

  SORT i_out BY vkbur kunnr zuonr.

*  SORT i_out BY vkbur zuonr.
*  SORT i_itab1 BY vkbur zuonr cpudt DESCENDING belnr DESCENDING.
*  SORT i_itab1 BY vkbur zuonr cpudt belnr.
*  LOOP AT i_out.
*    READ TABLE i_tvkol WITH KEY vstel = i_out-vkbur.
*    IF sy-subrc EQ 0.
*      l_flag = 2.
*      IF i_tvkol-mixlive IS INITIAL.
*        IF i_tvkol-live EQ 'X'.
*          PERFORM f_get_rv_data USING l_flag
*                                      i_out-zuonr
*                                      'RV'
*                                CHANGING l_subrc.
*        ELSE.
*          PERFORM f_get_rv_data USING l_flag
*                                      i_out-zuonr
*                                      'ZA'
*                                CHANGING l_subrc.
*        ENDIF.
*      ELSE.
*        PERFORM f_get_rv_data USING l_flag
*                                    i_out-zuonr
*                                    'ZA'
*                              CHANGING l_subrc.
*        IF l_subrc NE 0.
*          PERFORM f_get_rv_data USING l_flag
*                                      i_out-zuonr
*                                      'RV'
*                                CHANGING l_subrc.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
ENDFORM.                    " PROSES_ALV

*&---------------------------------------------------------------------*
*&      Form  fieldcat_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fieldcat_build.
  DATA: l_year(4), l_year1(4),
        kolom01(20), kolom02(20), kolom03(20), kolom04(20), kolom05(20),
        kolom06(20), kolom07(20), kolom08(20), kolom09(20), kolom10(20),
        kolom11(20), kolom12(20), kolom13(20), kolom14(20), kolom15(20),
        kolom16(20), kolom17(20), kolom18(20), kolom19(20), kolom20(20),
        kolom21(20), kolom22(20), kolom23(20), kolom24(20), kolom25(20),
        kolom26(20), kolom99(20),
        janytd(20), febytd(20), marytd(20), aprytd(20),
        meiytd(20), junytd(20), julytd(20), augytd(20),
        sepytd(20), oktytd(20), novytd(20), desytd(20).

  DATA: l_round TYPE i.

  IF radio3 EQ 'X'.
    l_round = 0.
  ELSEIF radio4 EQ 'X'.
    l_round = 1.
  ELSEIF radio5 EQ 'X'.
    l_round = 2.
  ELSEIF radio6 EQ 'X'.
    l_round = 3.
  ELSEIF radio7 EQ 'X'.
    l_round = 4.
  ELSEIF radio8 EQ 'X'.
    l_round = 5.
  ENDIF.

  l_year  = pa_gstid(4) - 2.
  l_year1 = pa_gstid(4) - 1.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name     = w_repid
      i_internal_tabname = 'I_OUT'
      i_inclname         = w_repid
    CHANGING
      ct_fieldcat        = i_fieldcat_alv.

  CONCATENATE '< Des' l_year+2(2) INTO kolom01
    SEPARATED BY space.
  CONCATENATE 'Q1' l_year1+2(2) INTO kolom02
    SEPARATED BY '/'.
  CONCATENATE 'Q2' l_year1+2(2) INTO kolom03
    SEPARATED BY '/'.
  CONCATENATE 'Tot SMT 1' l_year1+2(2) INTO kolom04
    SEPARATED BY space.
  CONCATENATE 'Q3' l_year1+2(2) INTO kolom05
    SEPARATED BY '/'.
  CONCATENATE 'Q4' l_year1+2(2) INTO kolom06
    SEPARATED BY '/'.
  CONCATENATE 'Tot Thn' l_year1+2(2) INTO kolom07
    SEPARATED BY space.
  CONCATENATE 'JAN' pa_gstid+2(2) INTO kolom08
    SEPARATED BY space.
  CONCATENATE 'FEB' pa_gstid+2(2) INTO kolom09
    SEPARATED BY space.
  CONCATENATE 'MAR' pa_gstid+2(2) INTO kolom10
    SEPARATED BY space.
  CONCATENATE 'Tot Q1' pa_gstid+2(2) INTO kolom11
    SEPARATED BY '/'.
  CONCATENATE 'APR' pa_gstid+2(2) INTO kolom12
    SEPARATED BY space.
  CONCATENATE 'MEI' pa_gstid+2(2) INTO kolom13
    SEPARATED BY space.
  CONCATENATE 'JUN' pa_gstid+2(2) INTO kolom14
    SEPARATED BY space.
  CONCATENATE 'Tot Q2' pa_gstid+2(2) INTO kolom15
    SEPARATED BY '/'.
  CONCATENATE 'JUL' pa_gstid+2(2) INTO kolom16
    SEPARATED BY space.
  CONCATENATE 'AUG' pa_gstid+2(2) INTO kolom17
    SEPARATED BY space.
  CONCATENATE 'SEP' pa_gstid+2(2) INTO kolom18
    SEPARATED BY space.
  CONCATENATE 'Tot Q3' pa_gstid+2(2) INTO kolom19
    SEPARATED BY '/'.
  CONCATENATE 'OKT' pa_gstid+2(2) INTO kolom20
    SEPARATED BY space.
  CONCATENATE 'NOV' pa_gstid+2(2) INTO kolom21
    SEPARATED BY space.
  CONCATENATE 'DES' pa_gstid+2(2) INTO kolom22
    SEPARATED BY space.
  CONCATENATE 'Tot Q4' pa_gstid+2(2) INTO kolom23
    SEPARATED BY '/'.
  CONCATENATE 'Tot SMT 1' pa_gstid+2(2) INTO kolom24
    SEPARATED BY space.
  CONCATENATE 'Tot SMT 2' pa_gstid+2(2) INTO kolom25
    SEPARATED BY space.
  CONCATENATE 'Tot Thn' pa_gstid+2(2) INTO kolom26
    SEPARATED BY space.

  CONCATENATE 'JAN' l_year1+2(2) INTO janytd
    SEPARATED BY space.
  CONCATENATE 'FEB' l_year1+2(2) INTO febytd
    SEPARATED BY space.
  CONCATENATE 'MAR' l_year1+2(2) INTO marytd
    SEPARATED BY space.
  CONCATENATE 'APR' l_year1+2(2) INTO aprytd
    SEPARATED BY space.
  CONCATENATE 'MEI' l_year1+2(2) INTO meiytd
    SEPARATED BY space.
  CONCATENATE 'JUN' l_year1+2(2) INTO junytd
    SEPARATED BY space.
  CONCATENATE 'JUL' l_year1+2(2) INTO julytd
    SEPARATED BY space.
  CONCATENATE 'AUG' l_year1+2(2) INTO augytd
    SEPARATED BY space.
  CONCATENATE 'SEP' l_year1+2(2) INTO sepytd
    SEPARATED BY space.
  CONCATENATE 'OKT' l_year1+2(2) INTO oktytd
    SEPARATED BY space.
  CONCATENATE 'NOV' l_year1+2(2) INTO novytd
    SEPARATED BY space.
  CONCATENATE 'DES' l_year1+2(2) INTO desytd
    SEPARATED BY space.

  LOOP AT i_fieldcat_alv INTO w_fieldcat_alv.
    CASE w_fieldcat_alv-fieldname.
      WHEN 'BEZEI'.
        w_fieldcat_alv-reptext_ddic = 'Region'.
        w_fieldcat_alv-seltext_s    = 'Region'.
        w_fieldcat_alv-seltext_m    = 'Region'.
        w_fieldcat_alv-seltext_l    = 'Region'.
      WHEN 'GTEXT'.
        w_fieldcat_alv-reptext_ddic = 'Branch'.
        w_fieldcat_alv-seltext_s    = 'Branch'.
        w_fieldcat_alv-seltext_m    = 'Branch'.
        w_fieldcat_alv-seltext_l    = 'Branch'.
      WHEN 'PERIOD'.
        w_fieldcat_alv-reptext_ddic = 'Period'.
        w_fieldcat_alv-seltext_s    = 'Period'.
        w_fieldcat_alv-seltext_m    = 'Period'.
        w_fieldcat_alv-seltext_l    = 'Period'.
      WHEN 'NAME1'.
        w_fieldcat_alv-reptext_ddic = 'Customer'.
        w_fieldcat_alv-seltext_s    = 'Customer'.
        w_fieldcat_alv-seltext_m    = 'Customer'.
        w_fieldcat_alv-seltext_l    = 'Customer'.
      WHEN 'KDGRP'.
      WHEN 'BELNR'.
        w_fieldcat_alv-hotspot      = 'X'.
      WHEN 'KOLOM01'.
        w_fieldcat_alv-reptext_ddic = kolom01.
        w_fieldcat_alv-seltext_s    = kolom01.
        w_fieldcat_alv-seltext_m    = kolom01.
        w_fieldcat_alv-seltext_l    = kolom01.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM02'.
        w_fieldcat_alv-reptext_ddic = kolom02.
        w_fieldcat_alv-seltext_s    = kolom02.
        w_fieldcat_alv-seltext_m    = kolom02.
        w_fieldcat_alv-seltext_l    = kolom02.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM03'.
        w_fieldcat_alv-reptext_ddic = kolom03.
        w_fieldcat_alv-seltext_s    = kolom03.
        w_fieldcat_alv-seltext_m    = kolom03.
        w_fieldcat_alv-seltext_l    = kolom03.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM04'.
        w_fieldcat_alv-reptext_ddic = kolom04.
        w_fieldcat_alv-seltext_s    = kolom04.
        w_fieldcat_alv-seltext_m    = kolom04.
        w_fieldcat_alv-seltext_l    = kolom04.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM05'.
        w_fieldcat_alv-reptext_ddic = kolom05.
        w_fieldcat_alv-seltext_s    = kolom05.
        w_fieldcat_alv-seltext_m    = kolom05.
        w_fieldcat_alv-seltext_l    = kolom05.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM06'.
        w_fieldcat_alv-reptext_ddic = kolom06.
        w_fieldcat_alv-seltext_s    = kolom06.
        w_fieldcat_alv-seltext_m    = kolom06.
        w_fieldcat_alv-seltext_l    = kolom06.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM07'.
        w_fieldcat_alv-reptext_ddic = kolom07.
        w_fieldcat_alv-seltext_s    = kolom07.
        w_fieldcat_alv-seltext_m    = kolom07.
        w_fieldcat_alv-seltext_l    = kolom07.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM08'.
        w_fieldcat_alv-reptext_ddic = kolom08.
        w_fieldcat_alv-seltext_s    = kolom08.
        w_fieldcat_alv-seltext_m    = kolom08.
        w_fieldcat_alv-seltext_l    = kolom08.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM09'.
        w_fieldcat_alv-reptext_ddic = kolom09.
        w_fieldcat_alv-seltext_s    = kolom09.
        w_fieldcat_alv-seltext_m    = kolom09.
        w_fieldcat_alv-seltext_l    = kolom09.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM10'.
        w_fieldcat_alv-reptext_ddic = kolom10.
        w_fieldcat_alv-seltext_s    = kolom10.
        w_fieldcat_alv-seltext_m    = kolom10.
        w_fieldcat_alv-seltext_l    = kolom10.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM11'.
        w_fieldcat_alv-reptext_ddic = kolom11.
        w_fieldcat_alv-seltext_s    = kolom11.
        w_fieldcat_alv-seltext_m    = kolom11.
        w_fieldcat_alv-seltext_l    = kolom11.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM12'.
        w_fieldcat_alv-reptext_ddic = kolom12.
        w_fieldcat_alv-seltext_s    = kolom12.
        w_fieldcat_alv-seltext_m    = kolom12.
        w_fieldcat_alv-seltext_l    = kolom12.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM13'.
        w_fieldcat_alv-reptext_ddic = kolom13.
        w_fieldcat_alv-seltext_s    = kolom13.
        w_fieldcat_alv-seltext_m    = kolom13.
        w_fieldcat_alv-seltext_l    = kolom13.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM14'.
        w_fieldcat_alv-reptext_ddic = kolom14.
        w_fieldcat_alv-seltext_s    = kolom14.
        w_fieldcat_alv-seltext_m    = kolom14.
        w_fieldcat_alv-seltext_l    = kolom14.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM15'.
        w_fieldcat_alv-reptext_ddic = kolom15.
        w_fieldcat_alv-seltext_s    = kolom15.
        w_fieldcat_alv-seltext_m    = kolom15.
        w_fieldcat_alv-seltext_l    = kolom15.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM16'.
        w_fieldcat_alv-reptext_ddic = kolom16.
        w_fieldcat_alv-seltext_s    = kolom16.
        w_fieldcat_alv-seltext_m    = kolom16.
        w_fieldcat_alv-seltext_l    = kolom16.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM17'.
        w_fieldcat_alv-reptext_ddic = kolom17.
        w_fieldcat_alv-seltext_s    = kolom17.
        w_fieldcat_alv-seltext_m    = kolom17.
        w_fieldcat_alv-seltext_l    = kolom17.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM18'.
        w_fieldcat_alv-reptext_ddic = kolom18.
        w_fieldcat_alv-seltext_s    = kolom18.
        w_fieldcat_alv-seltext_m    = kolom18.
        w_fieldcat_alv-seltext_l    = kolom18.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM19'.
        w_fieldcat_alv-reptext_ddic = kolom19.
        w_fieldcat_alv-seltext_s    = kolom19.
        w_fieldcat_alv-seltext_m    = kolom19.
        w_fieldcat_alv-seltext_l    = kolom19.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM20'.
        w_fieldcat_alv-reptext_ddic = kolom20.
        w_fieldcat_alv-seltext_s    = kolom20.
        w_fieldcat_alv-seltext_m    = kolom20.
        w_fieldcat_alv-seltext_l    = kolom20.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM21'.
        w_fieldcat_alv-reptext_ddic = kolom21.
        w_fieldcat_alv-seltext_s    = kolom21.
        w_fieldcat_alv-seltext_m    = kolom21.
        w_fieldcat_alv-seltext_l    = kolom21.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM22'.
        w_fieldcat_alv-reptext_ddic = kolom22.
        w_fieldcat_alv-seltext_s    = kolom22.
        w_fieldcat_alv-seltext_m    = kolom22.
        w_fieldcat_alv-seltext_l    = kolom22.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM23'.
        w_fieldcat_alv-reptext_ddic = kolom23.
        w_fieldcat_alv-seltext_s    = kolom23.
        w_fieldcat_alv-seltext_m    = kolom23.
        w_fieldcat_alv-seltext_l    = kolom23.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM24'.
        w_fieldcat_alv-reptext_ddic = kolom24.
        w_fieldcat_alv-seltext_s    = kolom24.
        w_fieldcat_alv-seltext_m    = kolom24.
        w_fieldcat_alv-seltext_l    = kolom24.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-no_out       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM25'.
        w_fieldcat_alv-reptext_ddic = kolom25.
        w_fieldcat_alv-seltext_s    = kolom25.
        w_fieldcat_alv-seltext_m    = kolom25.
        w_fieldcat_alv-seltext_l    = kolom25.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-no_out       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM26'.
        w_fieldcat_alv-reptext_ddic = kolom26.
        w_fieldcat_alv-seltext_s    = kolom26.
        w_fieldcat_alv-seltext_m    = kolom26.
        w_fieldcat_alv-seltext_l    = kolom26.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-no_out       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'KOLOM99'.
        w_fieldcat_alv-reptext_ddic = 'Grand Tot'.
        w_fieldcat_alv-seltext_s    = 'Grand Tot'.
        w_fieldcat_alv-seltext_m    = 'Grand Tot'.
        w_fieldcat_alv-seltext_l    = 'Grand Tot'.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'JANYTD'.
        w_fieldcat_alv-reptext_ddic = janytd.
        w_fieldcat_alv-seltext_s    = janytd.
        w_fieldcat_alv-seltext_m    = janytd.
        w_fieldcat_alv-seltext_l    = janytd.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-no_out       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'FEBYTD'.
        w_fieldcat_alv-reptext_ddic = febytd.
        w_fieldcat_alv-seltext_s    = febytd.
        w_fieldcat_alv-seltext_m    = febytd.
        w_fieldcat_alv-seltext_l    = febytd.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-no_out       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'MARYTD'.
        w_fieldcat_alv-reptext_ddic = marytd.
        w_fieldcat_alv-seltext_s    = marytd.
        w_fieldcat_alv-seltext_m    = marytd.
        w_fieldcat_alv-seltext_l    = marytd.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-no_out       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'APRYTD'.
        w_fieldcat_alv-reptext_ddic = aprytd.
        w_fieldcat_alv-seltext_s    = aprytd.
        w_fieldcat_alv-seltext_m    = aprytd.
        w_fieldcat_alv-seltext_l    = aprytd.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-no_out       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'MEIYTD'.
        w_fieldcat_alv-reptext_ddic = meiytd.
        w_fieldcat_alv-seltext_s    = meiytd.
        w_fieldcat_alv-seltext_m    = meiytd.
        w_fieldcat_alv-seltext_l    = meiytd.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-no_out       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'JUNYTD'.
        w_fieldcat_alv-reptext_ddic = junytd.
        w_fieldcat_alv-seltext_s    = junytd.
        w_fieldcat_alv-seltext_m    = junytd.
        w_fieldcat_alv-seltext_l    = junytd.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-no_out       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'JULYTD'.
        w_fieldcat_alv-reptext_ddic = julytd.
        w_fieldcat_alv-seltext_s    = julytd.
        w_fieldcat_alv-seltext_m    = julytd.
        w_fieldcat_alv-seltext_l    = julytd.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-no_out       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'AUGYTD'.
        w_fieldcat_alv-reptext_ddic = augytd.
        w_fieldcat_alv-seltext_s    = augytd.
        w_fieldcat_alv-seltext_m    = augytd.
        w_fieldcat_alv-seltext_l    = augytd.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-no_out       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'SEPYTD'.
        w_fieldcat_alv-reptext_ddic = sepytd.
        w_fieldcat_alv-seltext_s    = sepytd.
        w_fieldcat_alv-seltext_m    = sepytd.
        w_fieldcat_alv-seltext_l    = sepytd.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-no_out       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'OKTYTD'.
        w_fieldcat_alv-reptext_ddic = oktytd.
        w_fieldcat_alv-seltext_s    = oktytd.
        w_fieldcat_alv-seltext_m    = oktytd.
        w_fieldcat_alv-seltext_l    = oktytd.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-no_out       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'NOVYTD'.
        w_fieldcat_alv-reptext_ddic = novytd.
        w_fieldcat_alv-seltext_s    = novytd.
        w_fieldcat_alv-seltext_m    = novytd.
        w_fieldcat_alv-seltext_l    = novytd.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-no_out       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN 'DESYTD'.
        w_fieldcat_alv-reptext_ddic = desytd.
        w_fieldcat_alv-seltext_s    = desytd.
        w_fieldcat_alv-seltext_m    = desytd.
        w_fieldcat_alv-seltext_l    = desytd.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-no_out       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
      WHEN OTHERS.
        w_fieldcat_alv-round        = l_round.
        w_fieldcat_alv-do_sum       = 'X'.
        w_fieldcat_alv-no_out       = 'X'.
        w_fieldcat_alv-currency     = 'IDR'.
    ENDCASE.
    MODIFY i_fieldcat_alv FROM w_fieldcat_alv.
  ENDLOOP.
ENDFORM.                    " fieldcat_build

*&---------------------------------------------------------------------*
*&      Form  event_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM event_build.
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = i_events.

  READ TABLE i_events WITH KEY name = slis_ev_top_of_page
    INTO w_events.
  IF sy-subrc = 0.
    MOVE 'ALV_TOP_OF_PAGE' TO w_events-form.
    MODIFY i_events FROM w_events INDEX sy-tabix.
  ENDIF.
ENDFORM.                    " event_build

*&---------------------------------------------------------------------*
*&      Form  fill_sort
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_sort.
  DATA: fieldsort TYPE slis_sortinfo_alv.

  fieldsort-spos = '1'.
  fieldsort-fieldname = 'BEZEI'.
  fieldsort-up   = 'X'.
  fieldsort-subtot = 'X'.
  APPEND fieldsort TO ta_sort.

  fieldsort-spos = '2'.
  fieldsort-fieldname = 'GTEXT'.
  fieldsort-up   = 'X'.
  fieldsort-subtot = 'X'.
  APPEND fieldsort TO ta_sort.
ENDFORM.                    " fill_sort

*&---------------------------------------------------------------------*
*&      Form  layout_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM layout_build.
  w_layout-zebra                = 'X'.
  w_layout-colwidth_optimize    = 'X'.
ENDFORM.                    " layout_build

*&---------------------------------------------------------------------*
*&      Form  display_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_data.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_background_id         = 'ALV_BACKGROUND'
      i_callback_program      = w_repid
      i_callback_user_command = w_callback_ucomm
      is_layout               = w_layout
      is_print                = w_print
      i_save                  = 'A'
      is_variant              = w_variant
      it_events               = i_events[]
      it_fieldcat             = i_fieldcat_alv[]
      it_sort                 = ta_sort[]
    TABLES
      t_outtab                = i_out.
ENDFORM.                    " display_data

*---------------------------------------------------------------------*
*       FORM ALV_TOP_OF_PAGE                                          *
*---------------------------------------------------------------------*
FORM alv_top_of_page.
  DATA: l_date(15),
        l_time(15),
        report1(25),    "Company code
        report2(30),    "Business area
        report3(60),    "Period
        report4(40),
        report5(10),
        report6(20).

  WRITE sy-datum TO l_date.
  WRITE sy-uzeit TO l_time.

* Company code
  SELECT SINGLE butxt
    FROM t001
    INTO report1
    WHERE bukrs EQ pa_bukrs.

* Business area
  IF so_gsber-low NE space.
    SELECT SINGLE gtext
      FROM tgsbt
      INTO report2
      WHERE spras EQ sy-langu AND
            gsber EQ so_gsber-low.
  ELSE.
    MOVE 'All Branch' TO report2.
  ENDIF.

  CONCATENATE pa_gstid+6(2) pa_gstid+4(2) pa_gstid(4) INTO report3
    SEPARATED BY '-'.
  CONCATENATE 'As of :' report3 INTO report3
    SEPARATED BY space.

* Tanggal Proses
  CONCATENATE 'Creation date :' l_date '-' l_time INTO report4
    SEPARATED BY space.

* Round
  IF radio3 EQ 'X'.
    report6 = space.
  ELSEIF radio4 EQ 'X'.
    report6 = '( x 0 )'.
  ELSEIF radio5 EQ 'X'.
    report6 = '( x 00 )'.
  ELSEIF radio6 EQ 'X'.
    report6 = '( x 000 )'.
  ELSEIF radio7 EQ 'X'.
    report6 = '( x 0000 )'.
  ELSEIF radio8 EQ 'X'.
    report6 = '( x 00000 )'.
  ENDIF.

* List Header
  w_list_comments-typ  = 'H'.
  w_list_comments-info = report1.
  APPEND w_list_comments TO i_list_comments.

  w_list_comments-typ  = 'H'.
  w_list_comments-info = report2.
  APPEND w_list_comments TO i_list_comments.

  w_list_comments-typ  = 'H'.
  w_list_comments-info = report3.
  APPEND w_list_comments TO i_list_comments.

  w_list_comments-typ  = 'A'.
  w_list_comments-info = report4.
  APPEND w_list_comments TO i_list_comments.

  w_list_comments-typ  = 'A'.
  w_list_comments-info = report6.
  APPEND w_list_comments TO i_list_comments.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = i_list_comments.
  CLEAR i_list_comments.
ENDFORM.                    "alv_top_of_page

*---------------------------------------------------------------------*
*       FORM user_command                                             *
*---------------------------------------------------------------------*
FORM callback_ucomm  USING r_ucomm LIKE sy-ucomm
                           rs_selfield TYPE slis_selfield.

  rs_selfield-refresh = 'X'.
  CASE r_ucomm.
    WHEN  'FEHL' OR '&IC1'.
      READ TABLE i_out INDEX rs_selfield-tabindex.

      IF rs_selfield-tabindex NE 0.
        IF rs_selfield-fieldname EQ 'BELNR'.
          SET PARAMETER ID 'BLN' FIELD i_out-belnr.
          SET PARAMETER ID 'BUK' FIELD pa_bukrs.
          SET PARAMETER ID 'GJR' FIELD i_out-gjahr.
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
        ENDIF.
      ELSE.
        MESSAGE e000(zf).
      ENDIF.
  ENDCASE.
ENDFORM.                    "callback_ucomm

*&---------------------------------------------------------------------*
*&      Form  WRITE_BOTTOM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_bottom.
  SKIP 2.
  WRITE : / 'REMARKS :'.
  IF x_norm = 'X'.
    WRITE : / ' X  Normal Item'.
  ENDIF.
  IF x_shbv = 'X'.
    WRITE : / ' X  Special G/L Transaction :'.
    LOOP AT so_umskz.
      WRITE : so_umskz-low, space .
    ENDLOOP.
  ENDIF.
ENDFORM.                    " WRITE_BOTTOM

*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
      it_sort                  = t_alv_isort[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      is_print                 = d_print
    TABLES
      t_outtab                 = ft_report
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    "f_alv

*---------------------------------------------------------------------*
*       FORM f_build_event                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_EVENTS                                                     *
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.                    "f_build_event

*---------------------------------------------------------------------*
*       FORM f_build_event_exit                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_event_exit.
  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.
ENDFORM.                    "f_build_event_exit

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.

  DATA: l_year(4), l_year1(4),
        kolom01(20), kolom02(20), kolom03(20), kolom04(20), kolom05(20),
        kolom06(20), kolom07(20), kolom08(20), kolom09(20), kolom10(20),
        kolom11(20), kolom12(20), kolom13(20), kolom14(20), kolom15(20),
        kolom16(20), kolom17(20), kolom18(20), kolom19(20), kolom20(20),
        kolom21(20), kolom22(20), kolom23(20), kolom24(20), kolom25(20),
        kolom26(20), kolom99(20),
        janytd(20), febytd(20), marytd(20), aprytd(20),
        meiytd(20), junytd(20), julytd(20), augytd(20),
        sepytd(20), oktytd(20), novytd(20), desytd(20).

  DATA: l_round TYPE i.

  IF radio3 EQ 'X'.
    l_round = 0.
  ELSEIF radio4 EQ 'X'.
    l_round = 1.
  ELSEIF radio5 EQ 'X'.
    l_round = 2.
  ELSEIF radio6 EQ 'X'.
    l_round = 3.
  ELSEIF radio7 EQ 'X'.
    l_round = 4.
  ELSEIF radio8 EQ 'X'.
    l_round = 5.
  ENDIF.

  l_year  = pa_gstid(4) - 2.
  l_year1 = pa_gstid(4) - 1.

  CONCATENATE '< Des' l_year+2(2) INTO kolom01
    SEPARATED BY space.
  CONCATENATE 'Q1' l_year1+2(2) INTO kolom02
    SEPARATED BY '/'.
  CONCATENATE 'Q2' l_year1+2(2) INTO kolom03
    SEPARATED BY '/'.
  CONCATENATE 'Tot SMT 1' l_year1+2(2) INTO kolom04
    SEPARATED BY space.
  CONCATENATE 'Q3' l_year1+2(2) INTO kolom05
    SEPARATED BY '/'.
  CONCATENATE 'Q4' l_year1+2(2) INTO kolom06
    SEPARATED BY '/'.
  CONCATENATE 'Tot Thn' l_year1+2(2) INTO kolom07
    SEPARATED BY space.
  CONCATENATE 'JAN' pa_gstid+2(2) INTO kolom08
    SEPARATED BY space.
  CONCATENATE 'FEB' pa_gstid+2(2) INTO kolom09
    SEPARATED BY space.
  CONCATENATE 'MAR' pa_gstid+2(2) INTO kolom10
    SEPARATED BY space.
  CONCATENATE 'Tot Q1' pa_gstid+2(2) INTO kolom11
    SEPARATED BY '/'.
  CONCATENATE 'APR' pa_gstid+2(2) INTO kolom12
    SEPARATED BY space.
  CONCATENATE 'MEI' pa_gstid+2(2) INTO kolom13
    SEPARATED BY space.
  CONCATENATE 'JUN' pa_gstid+2(2) INTO kolom14
    SEPARATED BY space.
  CONCATENATE 'Tot Q2' pa_gstid+2(2) INTO kolom15
    SEPARATED BY '/'.
  CONCATENATE 'JUL' pa_gstid+2(2) INTO kolom16
    SEPARATED BY space.
  CONCATENATE 'AUG' pa_gstid+2(2) INTO kolom17
    SEPARATED BY space.
  CONCATENATE 'SEP' pa_gstid+2(2) INTO kolom18
    SEPARATED BY space.
  CONCATENATE 'Tot Q3' pa_gstid+2(2) INTO kolom19
    SEPARATED BY '/'.
  CONCATENATE 'OKT' pa_gstid+2(2) INTO kolom20
    SEPARATED BY space.
  CONCATENATE 'NOV' pa_gstid+2(2) INTO kolom21
    SEPARATED BY space.
  CONCATENATE 'DES' pa_gstid+2(2) INTO kolom22
    SEPARATED BY space.
  CONCATENATE 'Tot Q4' pa_gstid+2(2) INTO kolom23
    SEPARATED BY '/'.
  CONCATENATE 'Tot SMT 1' pa_gstid+2(2) INTO kolom24
    SEPARATED BY space.
  CONCATENATE 'Tot SMT 2' pa_gstid+2(2) INTO kolom25
    SEPARATED BY space.
  CONCATENATE 'Tot Thn' pa_gstid+2(2) INTO kolom26
    SEPARATED BY space.

  CONCATENATE 'JAN' l_year1+2(2) INTO janytd
    SEPARATED BY space.
  CONCATENATE 'FEB' l_year1+2(2) INTO febytd
    SEPARATED BY space.
  CONCATENATE 'MAR' l_year1+2(2) INTO marytd
    SEPARATED BY space.
  CONCATENATE 'APR' l_year1+2(2) INTO aprytd
    SEPARATED BY space.
  CONCATENATE 'MEI' l_year1+2(2) INTO meiytd
    SEPARATED BY space.
  CONCATENATE 'JUN' l_year1+2(2) INTO junytd
    SEPARATED BY space.
  CONCATENATE 'JUL' l_year1+2(2) INTO julytd
    SEPARATED BY space.
  CONCATENATE 'AUG' l_year1+2(2) INTO augytd
    SEPARATED BY space.
  CONCATENATE 'SEP' l_year1+2(2) INTO sepytd
    SEPARATED BY space.
  CONCATENATE 'OKT' l_year1+2(2) INTO oktytd
    SEPARATED BY space.
  CONCATENATE 'NOV' l_year1+2(2) INTO novytd
    SEPARATED BY space.
  CONCATENATE 'DES' l_year1+2(2) INTO desytd
    SEPARATED BY space.

  PERFORM f_fieldcatg USING ft_report:
    'BEZEI' 'TNLST' 'BEZEI' '' '' '' '' '' '' '' '' '' '' '' '',
    'VKBUR' 'TVBUR' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '',
    'GTEXT' 'TGSBT' 'GTEXT' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZFBDT' 'BSID' 'ZFBDT' '' '10' 'DO date' '' '' '' '' '' '' '' '' '',
    'ZTERM' 'BSID' 'ZTERM' 'X' '' 'TOP' '' '' '' '' '' '' '' '' '',
    'DUEDT' '' '' '' '10' 'Due Date' '' '' '' '' '' '' '' '' '',
    'PERIOD' '' '' 'X' '8' 'Period' '' '' '' '' '' '' '' '' '',
    'NAME1' '' '' '' '50' 'Name' '' '' '' '' '' '' '' '' '',
    'RLCN' '' '' '' '50' 'Route List/Code/Name' '' '' '' '' '' '' '' '' '',
    'KDGRP' 'KNVV' 'KDGRP' '' '' '' '' '' '' '' '' '' '' '' '',
    'KLIMK' 'KNKK' 'KLIMK' '' '' '' '' '' '' 'IDR' '' '' '' '' '',
    'BELNR' 'BSID' 'BELNR' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'ZUONR' 'BSID' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' ''.

  IF p_05t = 'X'.
    PERFORM f_fieldcatg USING ft_report:
      'ANLN1' 'BSID' 'ANLN1' '' '' 'DN principal' '' '' '' '' '' '' '' '' ''.
  ENDIF.

  PERFORM f_fieldcatg USING ft_report:
    'BUDAT' 'BSID' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '',
    'XREF2' 'BSID' 'XREF2' '' '' '' '' '' '' '' '' '' '' '' '',
    'DUEDTBI' 'ZFBICHECK' 'DUEDT' '' '' 'Due Date Giro' '' '' '' '' '' '' '' '' '',
    'WRBTRBI' 'ZFBICHECK' 'WRBTR' '' '' 'Amount Giro' '' '' '' 'IDR' '' '' '' '' '',
    'FKART' 'VBRK' 'FKART' '' '' '' '' '' '' '' '' '' '' '' '',
    'AWAL' 'VBRK' 'NETWR' '' '' 'Nilai Faktur Awal' '' '' '' 'IDR' '' '' '' '' '',

    'KOLOM01' 'BSID' 'DMBTR' '' '' kolom01 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM02' 'BSID' 'DMBTR' '' '' kolom02 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM03' 'BSID' 'DMBTR' '' '' kolom03 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM04' 'BSID' 'DMBTR' '' '' kolom04 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM05' 'BSID' 'DMBTR' '' '' kolom05 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM06' 'BSID' 'DMBTR' '' '' kolom06 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM07' 'BSID' 'DMBTR' '' '' kolom07 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM08' 'BSID' 'DMBTR' '' '' kolom08 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM09' 'BSID' 'DMBTR' '' '' kolom09 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM10' 'BSID' 'DMBTR' '' '' kolom10 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM11' 'BSID' 'DMBTR' '' '' kolom11 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM12' 'BSID' 'DMBTR' '' '' kolom12 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM13' 'BSID' 'DMBTR' '' '' kolom13 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM14' 'BSID' 'DMBTR' '' '' kolom14 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM15' 'BSID' 'DMBTR' '' '' kolom15 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM16' 'BSID' 'DMBTR' '' '' kolom16 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM17' 'BSID' 'DMBTR' '' '' kolom17 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM18' 'BSID' 'DMBTR' '' '' kolom18 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM19' 'BSID' 'DMBTR' '' '' kolom19 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM20' 'BSID' 'DMBTR' '' '' kolom20 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM21' 'BSID' 'DMBTR' '' '' kolom21 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM22' 'BSID' 'DMBTR' '' '' kolom22 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM23' 'BSID' 'DMBTR' '' '' kolom23 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM24' 'BSID' 'DMBTR' '' '' kolom24 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM25' 'BSID' 'DMBTR' '' '' kolom25 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM26' 'BSID' 'DMBTR' '' '' kolom26 '' '' '' 'IDR' '' '' '' '' l_round,
    'KOLOM99' 'BSID' 'DMBTR' '' '' 'Saldo Faktur' '' '' '' 'IDR' '' '' '' '' l_round,
*    'DMBTR_RV' 'BSID' 'DMBTR' '' '' 'Nilai Faktur' '' '' '' 'IDR' '' '' '' '' l_round,

    'GJAHR' 'BSID' 'GJAHR' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'KUNNR' 'KNA1' 'KUNNR' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'DMBTR' 'BSID' 'DMBTR' 'X' '' '' '' '' '' 'IDR' '' '' '' '' '',
    'JANYTD' 'BSID' 'DMBTR' 'X' '' janytd '' '' '' 'IDR' '' '' '' '' l_round,
    'FEBYTD' 'BSID' 'DMBTR' 'X' '' febytd '' '' '' 'IDR' '' '' '' '' l_round,
    'MARYTD' 'BSID' 'DMBTR' 'X' '' marytd '' '' '' 'IDR' '' '' '' '' l_round,
    'APRYTD' 'BSID' 'DMBTR' 'X' '' aprytd '' '' '' 'IDR' '' '' '' '' l_round,
    'MEIYTD' 'BSID' 'DMBTR' 'X' '' meiytd '' '' '' 'IDR' '' '' '' '' l_round,
    'JUNYTD' 'BSID' 'DMBTR' 'X' '' junytd '' '' '' 'IDR' '' '' '' '' l_round,
    'JULYTD' 'BSID' 'DMBTR' 'X' '' julytd '' '' '' 'IDR' '' '' '' '' l_round,
    'AUGYTD' 'BSID' 'DMBTR' 'X' '' augytd '' '' '' 'IDR' '' '' '' '' l_round,
    'SEPYTD' 'BSID' 'DMBTR' 'X' '' sepytd '' '' '' 'IDR' '' '' '' '' l_round,
    'OKTYTD' 'BSID' 'DMBTR' 'X' '' oktytd '' '' '' 'IDR' '' '' '' '' l_round,
    'NOVYTD' 'BSID' 'DMBTR' 'X' '' novytd '' '' '' 'IDR' '' '' '' '' l_round,
    'DESYTD' 'BSID' 'DMBTR' 'X' '' desytd '' '' '' 'IDR' '' '' '' '' l_round,

    'AGING' '' '' '' '5' 'Aging' '' '' '' '' '' '' '' '' '',
    'TGLTTF' '' '' '' '10' 'Tgl TF' '' '' '' '' '' '' '' '' '',
    'LEADTTF' '' '' '' '10' 'Lead TTF' '' '' '' '' '' '' '' '' ''.

  IF x_rtv IS INITIAL.
    PERFORM f_fieldcatg USING ft_report:
    'NOARP' 'ZFARPOTD' 'NOARP' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'RTVNR' 'ZFARPOTD' 'RTVNR' 'X' '' '' '' '' '' '' '' '' '' '' ''.
  ELSE.
    PERFORM f_fieldcatg USING ft_report:
    'NOARP' 'ZFARPOTD' 'NOARP' '' '' '' '' '' '' '' '' '' '' '' '',
    'RTVNR' 'ZFARPOTD' 'RTVNR' '' '' '' '' '' '' '' '' '' '' '' ''.
  ENDIF.
ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "f_build_print

*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'ZUONR'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.                    "f_build_sortfield

*&---------------------------------------------------------------------*
*&      Form  f_clear_alv_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_clear_alv_data.
  CLEAR:t_alv_fieldcat,
        t_alv_event,
        t_events,
        t_alv_isort,
        t_alv_filter,
        t_event_exit,
        d_alv_isort,
        d_alv_variant,
        d_alv_list_scroll,
        d_alv_sort_postn,
        d_alv_keyinfo,
        d_alv_fieldcat,
        d_alv_formname,
        d_alv_ucomm,
        d_alv_print,
        d_alv_repid,
        d_alv_tabix,
        d_alv_subrc,
        d_alv_screen_start_column,
        d_alv_screen_start_line,
        d_alv_screen_end_column,
        d_alv_screen_end_line,
        d_alv_layout,
        d_layout,
        d_repid,
        d_print.

  REFRESH: t_alv_fieldcat,
           t_alv_event,
           t_events,
           t_alv_isort,
           t_alv_filter,
           t_event_exit.

  d_repid = sy-repid.
ENDFORM.                    " f_clear_alv_data

*---------------------------------------------------------------------*
*       FORM f_fieldcats                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_FNAME                                                      *
*  -->  FU_OUTLEN                                                     *
*  -->  FU_NOSIGN                                                     *
*  -->  FU_NOOUT                                                      *
*  -->  FU_TEXT                                                       *
*  -->  FU_REFTB                                                      *
*  -->  FU_REFFNAME                                                   *
*  -->  FU_DECIMALS                                                   *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    value(fu_types)
                          value(fu_fname)
                          value(fu_reftb)
                          value(fu_refld)
                          value(fu_noout)
                          value(fu_outln)
                          value(fu_fltxt)
                          value(fu_dosum)
                          value(fu_hotsp)
                          value(fu_dec)
                          value(fu_waers)
                          value(fu_meins)
                          value(fu_waers_f)
                          value(fu_meins_f)
                          value(fu_checkbox)
                          value(fu_round).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_tabname       = fu_reftb.
  ld_fieldcat-ref_fieldname     = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-seltext_l         = fu_fltxt.
  ld_fieldcat-seltext_m         = fu_fltxt.
  ld_fieldcat-seltext_s         = fu_fltxt.
  ld_fieldcat-reptext_ddic      = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_out      = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-round             = fu_round.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_gui_message                                            *
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "f_gui_message

*&---------------------------------------------------------------------*
*&      Form  f_mapping_soff
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_mapping_soff .
  DATA : lt_knvv  TYPE STANDARD TABLE OF knvv,
         ls_knvv  LIKE LINE OF lt_knvv.

  IF so_kunnr IS NOT INITIAL.
    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_dele
      WHERE kunnr    IN so_kunnr AND
            zvkbur1  IN so_gsber AND
            budat    GE pa_gstid.

    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_add
      WHERE kunnr  IN so_kunnr AND
            zvkbur IN so_gsber AND
            budat  GE pa_gstid.
  ELSE.
    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_dele
      WHERE zvkbur1  IN so_gsber AND
            budat    GE pa_gstid.

    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_add
      WHERE zvkbur IN so_gsber AND
            budat  GE pa_gstid.
  ENDIF.

  CLEAR : lt_knvv[].
  IF t_zfarsoff_dele[] IS NOT INITIAL.
    SELECT *
      FROM knvv
      INTO CORRESPONDING FIELDS OF TABLE lt_knvv
      FOR ALL ENTRIES IN t_zfarsoff_dele
      WHERE kunnr = t_zfarsoff_dele-kunnr
        AND vkbur IN so_gsber
        AND kdgrp IN so_kdgrp.

    LOOP AT t_zfarsoff_dele.
      READ TABLE lt_knvv INTO ls_knvv
                         WITH KEY kunnr = t_zfarsoff_dele-kunnr.
      IF sy-subrc <> 0.
        DELETE t_zfarsoff_dele.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CLEAR : lt_knvv[].
  IF t_zfarsoff_add[] IS NOT INITIAL.
    SELECT *
      FROM knvv
      INTO CORRESPONDING FIELDS OF TABLE lt_knvv
      FOR ALL ENTRIES IN t_zfarsoff_add
      WHERE kunnr = t_zfarsoff_add-kunnr
*        AND vkbur IN so_gsber
        AND kdgrp IN so_kdgrp.

    LOOP AT t_zfarsoff_add.
      READ TABLE lt_knvv INTO ls_knvv
                         WITH KEY kunnr = t_zfarsoff_add-kunnr.
      IF sy-subrc <> 0.
        DELETE t_zfarsoff_add.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_mapping_soff

*&---------------------------------------------------------------------*
*&      Form  f_hapus_kunnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hapus_kunnr .
  IF t_zfarsoff_dele[] IS NOT INITIAL.
    SORT i_itab BY kunnr.
    SORT t_zfarsoff_dele BY kunnr.
    LOOP AT i_itab INTO wa_itab.
      READ TABLE t_zfarsoff_dele WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        DELETE i_itab.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_hapus_kunnr

*&---------------------------------------------------------------------*
*&      Form  f_tambah_kunnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_tambah_kunnr .
  DATA : lv_gerdat TYPE sy-datum.

  IF t_zfarsoff_add[] IS NOT INITIAL.
    va_monat1 = pa_gstid+4(2).
    va_monat2 = pa_gstid+4(2) + 1.

    CONCATENATE pa_gstid(4) va_monat1 '01' INTO va_gerdat1.
    CONCATENATE pa_gstid(4) va_monat2 '01' INTO va_gerdat2.

    PERFORM f_month_calc USING '12'
                         CHANGING lv_gerdat.

    IF x_norm EQ 'X' AND x_shbv EQ 'X'.
      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart b~kdgrp a~zuonr
             a~gsber a~augbl a~zfbdt a~zterm a~cpudt b~vkbur
        FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        INTO CORRESPONDING FIELDS OF TABLE i_itab_add
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr EQ t_zfarsoff_add-kunnr AND
              a~budat LE pa_gstid AND
              a~umskz EQ space    AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1 AND
              b~vtweg EQ '10'.

      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart a~xref2 b~kdgrp
             a~augdt a~zuonr a~gsber a~augbl a~zfbdt a~zterm a~cpudt
             b~vkbur
        FROM bsad AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab_add
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ pa_bukrs   AND
              a~kunnr EQ t_zfarsoff_add-kunnr   AND
              a~budat LE pa_gstid   AND
              a~augdt GE lv_gerdat AND
              a~umskz EQ space      AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1 AND
              b~vtweg EQ '10'.

      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart b~kdgrp a~zuonr
             a~gsber a~augbl a~zfbdt a~zterm a~cpudt b~vkbur
        FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab_add
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr EQ t_zfarsoff_add-kunnr AND
              a~budat LE pa_gstid AND
              a~umskz IN so_umskz AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1 AND
              b~vtweg EQ '10'.

      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart a~xref2 b~kdgrp
             a~zuonr a~augdt a~augbl a~gsber a~zfbdt a~zterm a~cpudt
             b~vkbur
       FROM bsad AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
       APPENDING CORRESPONDING FIELDS OF TABLE i_itab_add
       FOR ALL ENTRIES IN t_zfarsoff_add
       WHERE a~bukrs EQ pa_bukrs AND
             a~kunnr EQ t_zfarsoff_add-kunnr AND
             a~budat LE pa_gstid AND
             a~augdt GE lv_gerdat AND
             a~umskz IN so_umskz   AND
             a~blart IN ('RV','DR','ZA','DA','DZ') AND
             b~vkbur EQ t_zfarsoff_add-zvkbur1 AND
             b~vtweg EQ '10'.
    ENDIF.

    IF x_norm EQ 'X' AND x_shbv EQ space.
      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart b~kdgrp a~zuonr
             a~gsber a~augbl a~zfbdt a~zterm a~cpudt b~vkbur
        FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        INTO CORRESPONDING FIELDS OF TABLE i_itab_add
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr EQ t_zfarsoff_add-kunnr AND
              a~budat LE pa_gstid AND
              a~umskz EQ space    AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1 AND
              b~vtweg EQ '10'.

      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart a~xref2 b~kdgrp
             a~zuonr a~augdt a~gsber a~augbl a~zfbdt a~zterm a~cpudt
             b~vkbur
        FROM bsad AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab_add
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr EQ t_zfarsoff_add-kunnr AND
              a~budat LE pa_gstid AND
              a~augdt GE lv_gerdat AND
              a~umskz EQ space     AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1 AND
              b~vtweg EQ '10'.
    ENDIF.

    IF x_norm EQ space AND x_shbv EQ 'X'.
      SELECT a~bukrs a~umskz a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart b~kdgrp a~zuonr
             a~gsber a~augbl a~zfbdt a~zterm a~cpudt b~vkbur
        FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        INTO CORRESPONDING FIELDS OF TABLE i_itab_add
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr EQ t_zfarsoff_add-kunnr AND
              a~budat LE pa_gstid AND
              a~umskz IN so_umskz  AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1 AND
              b~vtweg EQ '10'.

      SELECT a~bukrs a~umskz a~gsber a~kunnr b~vwerk a~gjahr a~belnr a~buzei
             a~budat a~monat a~dmbtr a~shkzg a~blart a~xref2 b~kdgrp a~zuonr
             a~augdt a~augbl a~zfbdt a~zterm a~cpudt b~vkbur
        FROM bsad AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                          b~vkorg EQ pa_bukrs
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab_add
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ pa_bukrs AND
              a~kunnr EQ t_zfarsoff_add-kunnr AND
              a~budat LE pa_gstid AND
              a~augdt GE lv_gerdat AND
              a~umskz IN so_umskz   AND
              a~blart IN ('RV','DR','ZA','DA','DZ') AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1 AND
              b~vtweg EQ '10'.
    ENDIF.

    SORT i_itab_add BY kunnr.
    SORT t_zfarsoff_add BY kunnr.
    LOOP AT i_itab_add INTO wa_itab.
      READ TABLE t_zfarsoff_add WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF pa_gstid LT t_zfarsoff_add-budat.
          IF t_zfarsoff_add-zvkbur IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur.
            APPEND wa_itab TO i_itab.
          ENDIF.
        ELSE.
          IF t_zfarsoff_add-zvkbur1 IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur1.
            APPEND wa_itab TO i_itab.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_tambah_kunnr

*&---------------------------------------------------------------------*
*&      Form  f_get_rv_data
*&---------------------------------------------------------------------*
FORM f_get_rv_data  USING    fu_flag fu_zuonr fu_blart fu_umskz
                    CHANGING fc_subrc.
  DATA: l_dmbtr    LIKE bsid-dmbtr,
        lw_itab    TYPE ta_itab,
        lv_datum   TYPE sy-datum.

  CASE fu_flag.
    WHEN 1.
      IF fu_umskz = 'V'.
        READ TABLE i_itab3 INTO lw_itab WITH KEY zuonr = fu_zuonr.
        IF sy-subrc = 0.
          fc_subrc = 0.
          lv_datum  = lw_itab-budat.
        ELSE.
          fc_subrc = 1.
        ENDIF.
      ELSE.
        READ TABLE i_itab1 INTO lw_itab WITH KEY zuonr = fu_zuonr
                                                 blart = fu_blart.
        IF sy-subrc = 0.
          fc_subrc = 0.
          lv_datum  = lw_itab-zfbdt.
        ELSE.
          fc_subrc = 1.
        ENDIF.
      ENDIF.

      IF fc_subrc EQ 0.
        wa_all-zuonr    = lw_itab-zuonr.
        wa_all-gjahr    = lw_itab-gjahr.
        wa_all-monat    = lw_itab-monat.
        wa_all-zterm    = lw_itab-zterm.
        wa_all-zfbdt    = lv_datum.
      ELSE.
        wa_all-gjahr    = wa_itab-zfbdt(4).
        wa_all-monat    = wa_itab-zfbdt+4(2).
        IF wa_itab-zuonr+10(1) = 'R'.
          wa_all-gjahr    = wa_itab-budat(4).
          wa_all-monat    = wa_itab-budat+4(2).
        ENDIF.
      ENDIF.

    WHEN 2.
      READ TABLE i_itab1 INTO wa_itab WITH KEY zuonr = fu_zuonr
                                               blart = fu_blart.
      IF sy-subrc EQ 0.
        fc_subrc = 0.
        IF wa_itab-shkzg EQ 'H'.
          i_out-dmbtr_rv = wa_itab-dmbtr * -1.
        ELSE.
          i_out-dmbtr_rv = wa_itab-dmbtr.
        ENDIF.
        MODIFY i_out TRANSPORTING dmbtr_rv.
      ELSE.
        fc_subrc = 1.
      ENDIF.
      CLEAR: i_out, l_dmbtr.
  ENDCASE.
ENDFORM.                    " f_get_rv_data

*&---------------------------------------------------------------------*
*&      Form  F_GET_TTF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_ttf .
  IF i_all[] IS NOT INITIAL.
    SELECT * INTO TABLE gt_zfbid
      FROM zfbid FOR ALL ENTRIES IN i_all
      WHERE bukrs EQ pa_bukrs
        AND vkbur IN so_gsber
        AND zuonr EQ i_all-zuonr.
  ENDIF.
ENDFORM.                    " F_GET_TTF

*&---------------------------------------------------------------------*
*&      Form  F_DN_NUMBER
*&---------------------------------------------------------------------*
FORM f_dn_number  USING    fu_zuonr.
  LOOP AT i_itab INTO wa_itab.
    IF wa_itab-zuonr <> fu_zuonr.
      DELETE i_itab.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_DN_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_MONTH_CALC
*&---------------------------------------------------------------------*
FORM f_month_calc  USING    fu_count
                   CHANGING fc_gerdat.

  DATA : lv_datum   TYPE sy-datum.

  lv_datum  = pa_gstid.

  DO fu_count TIMES.
    CONCATENATE lv_datum(6) '01' INTO fc_gerdat.
    lv_datum = fc_gerdat - 1.
  ENDDO.

  CONCATENATE lv_datum(6) '01' INTO fc_gerdat.
ENDFORM.                    " F_MONTH_CALC

*&---------------------------------------------------------------------*
*&      Form  F_GET_ADDITIONAL_FIELD
*&---------------------------------------------------------------------*
FORM f_get_additional_field .
  DATA : lt_all    TYPE ta_itab OCCURS 0,
         ls_all    LIKE LINE OF lt_all,
         lt_xall   TYPE ta_itab OCCURS 0,
         ls_xall   LIKE LINE OF lt_xall.

  DATA : lv_kkber  TYPE knkk-kkber.

  CASE pa_bukrs.
    WHEN '8020'.
      lv_kkber  = '8000'.
    WHEN OTHERS.
      lv_kkber  = pa_bukrs.
  ENDCASE.

  lt_all[] = i_all[].
  SORT lt_all BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_all COMPARING kunnr.
  IF lt_all[] IS NOT INITIAL.
    SELECT *
      FROM knkk
      INTO CORRESPONDING FIELDS OF TABLE gt_knkk
      FOR ALL ENTRIES IN lt_all
      WHERE kunnr = lt_all-kunnr
        AND kkber = lv_kkber.

    SELECT *
      FROM knvp
      INTO CORRESPONDING FIELDS OF TABLE gt_knvpzc
      FOR ALL ENTRIES IN lt_all
      WHERE kunnr = lt_all-kunnr
        AND parvw = 'ZC'.

    DELETE gt_knvpzc WHERE kunn2 IS INITIAL.

    IF gt_knvpzc[] IS NOT INITIAL.
      SELECT *
        FROM knvp
        INTO CORRESPONDING FIELDS OF TABLE gt_knvpzp
        FOR ALL ENTRIES IN gt_knvpzc
        WHERE kunnr = gt_knvpzc-kunn2
          AND parvw = 'ZP'.
    ENDIF.

    DELETE gt_knvpzp WHERE pernr IS INITIAL.

    IF gt_knvpzp[] IS NOT INITIAL.
      SELECT *
        FROM pa0001
        INTO CORRESPONDING FIELDS OF TABLE gt_pa0001
        FOR ALL ENTRIES IN gt_pa0001
        WHERE pernr = gt_pa0001-pernr.
    ENDIF.
  ENDIF.

  CLEAR lt_all[].
  lt_all[] = i_all[].
  SORT lt_all BY zuonr.
  DELETE ADJACENT DUPLICATES FROM lt_all COMPARING zuonr.
  IF lt_all[] IS NOT INITIAL.
    SELECT *
      FROM vbrk
      INTO CORRESPONDING FIELDS OF TABLE gt_vbrk
      FOR ALL ENTRIES IN lt_all
      WHERE zuonr = lt_all-zuonr.

    LOOP AT lt_all INTO ls_all.
      ls_xall-belnr   = ls_all-zuonr.
      APPEND ls_xall TO lt_xall.
      CLEAR ls_xall.
    ENDLOOP.

    SELECT *
      FROM zsl_hsales
      INTO CORRESPONDING FIELDS OF TABLE gt_hsales
      FOR ALL ENTRIES IN lt_xall
      WHERE vbeln = lt_xall-belnr.
  ENDIF.

  CLEAR lt_all[].
  lt_all[] = i_all[].
  SORT lt_all BY kunnr zuonr.
  DELETE ADJACENT DUPLICATES FROM lt_all COMPARING kunnr zuonr.
  IF lt_all[] IS NOT INITIAL.
    SELECT *
      FROM zfbicheck
      INTO CORRESPONDING FIELDS OF TABLE gt_zfbicheck
      FOR ALL ENTRIES IN lt_all
      WHERE kunnr = lt_all-kunnr
        AND zuonr = lt_all-zuonr
        AND pcair = space.

*    SELECT *
*      FROM zfbic_sfa
*      INTO CORRESPONDING FIELDS OF TABLE gt_zfbic_sfa
*      FOR ALL ENTRIES IN lt_all
*      WHERE kunnr = lt_all-kunnr
*        AND zuonr = lt_all-zuonr
*        AND pcair = space.
    SELECT *
      FROM zfbic_sfa
      INTO CORRESPONDING FIELDS OF TABLE gt_zfbic_sfa
      FOR ALL ENTRIES IN lt_all
      WHERE zuonr = lt_all-zuonr
        AND kunnr = lt_all-kunnr
        AND pcair = space.
  ENDIF.
ENDFORM.                    " F_GET_ADDITIONAL_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_INIT_KVGR3
*&---------------------------------------------------------------------*
FORM f_init_kvgr3 .
  CLEAR so_kvgr3.
  so_kvgr3-sign = 'I'.
  so_kvgr3-option = 'EQ'.
  so_kvgr3-low = '05T'.
  APPEND so_kvgr3. CLEAR so_kvgr3.
ENDFORM.                    " F_INIT_KVGR3

*&---------------------------------------------------------------------*
*&      Form  F_ADD_PO_NUMBER_RTV
*&---------------------------------------------------------------------*
FORM f_add_po_number_rtv .
  DATA : lt_itab        TYPE ta_itab OCCURS 0,
         ls_itab        LIKE LINE OF lt_itab,
         lt_xvbrp       TYPE STANDARD TABLE OF vbrp,
         lt_xfarpotd    TYPE STANDARD TABLE OF zfarpotd,
         ls_xvbak       LIKE LINE OF gt_xvbak,
         ls_xfarpotd    LIKE LINE OF lt_xfarpotd.

  DATA : ls_xvbfa       LIKE LINE OF gt_xvbfa,
         lt_vbfa        TYPE STANDARD TABLE OF vbfa,
         ls_vbfa        LIKE LINE OF lt_vbfa.

  lt_itab[] = i_itab[].
  SORT lt_itab BY zuonr.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING zuonr.
  IF lt_itab[] IS NOT INITIAL.
    LOOP AT lt_itab INTO ls_itab.
      ls_xvbfa-vbelv = ls_itab-zuonr.
      APPEND ls_xvbfa TO gt_xvbfa.
      CLEAR ls_xvbfa.
    ENDLOOP.
  ENDIF.

  IF gt_xvbfa[] IS NOT INITIAL.
    SELECT *
      FROM vbrp
      INTO CORRESPONDING FIELDS OF TABLE gt_xvbrp
      FOR ALL ENTRIES IN gt_xvbfa
      WHERE vbeln = gt_xvbfa-vbelv.

    lt_xvbrp[] = gt_xvbrp[].
    SORT lt_xvbrp BY aubel.
    DELETE ADJACENT DUPLICATES FROM lt_xvbrp COMPARING aubel.
    IF lt_xvbrp[] IS NOT INITIAL.
      SELECT *
        FROM vbak
        INTO CORRESPONDING FIELDS OF TABLE gt_xvbak
        FOR ALL ENTRIES IN lt_xvbrp
        WHERE vbeln = lt_xvbrp-aubel.

      LOOP AT gt_xvbak INTO ls_xvbak.
        ls_xfarpotd-bukrs = pa_bukrs.
        ls_xfarpotd-vkbur = ls_xvbak-vkbur.
        ls_xfarpotd-rtvnr = ls_xvbak-bstnk.
        APPEND ls_xfarpotd TO lt_xfarpotd.
        CLEAR ls_xfarpotd.
      ENDLOOP.
    ENDIF.

    SORT lt_xfarpotd BY bukrs vkbur rtvnr.
    DELETE ADJACENT DUPLICATES FROM lt_xfarpotd COMPARING bukrs vkbur rtvnr.
    IF lt_xfarpotd[] IS NOT INITIAL.
      SELECT *
        FROM zfarpotd
        INTO CORRESPONDING FIELDS OF TABLE gt_zfarpotd
        FOR ALL ENTRIES IN lt_xfarpotd
        WHERE bukrs = lt_xfarpotd-bukrs
          AND vkbur = lt_xfarpotd-vkbur
          AND rtvnr = lt_xfarpotd-rtvnr.
    ENDIF.

    lt_xfarpotd[] = gt_zfarpotd[].
    SORT lt_xfarpotd BY bukrs gsber vkbur noarp mjahr.
    DELETE ADJACENT DUPLICATES FROM lt_xfarpotd COMPARING bukrs gsber vkbur noarp mjahr.
    IF lt_xfarpotd[] IS NOT INITIAL.
      SELECT *
        FROM zfarpoth
        INTO CORRESPONDING FIELDS OF TABLE gt_zfarpoth
        FOR ALL ENTRIES IN lt_xfarpotd
        WHERE bukrs = lt_xfarpotd-bukrs
          AND gsber = lt_xfarpotd-gsber
          AND vkbur = lt_xfarpotd-vkbur
          AND noarp = lt_xfarpotd-noarp
          AND mjahr = lt_xfarpotd-mjahr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ADD_PO_NUMBER_RTV

*&---------------------------------------------------------------------*
*&      Form  F_ARPOT
*&---------------------------------------------------------------------*
FORM f_arpot  USING    fu_zuonr
              CHANGING fc_noarp fc_rtvnr.
  DATA : ls_xvbrp     LIKE LINE OF gt_xvbrp,
         ls_xvbak     LIKE LINE OF gt_xvbak,
         ls_zfarpotd  LIKE LINE OF gt_zfarpotd,
         ls_zfarpoth  LIKE LINE OF gt_zfarpoth,
         ls_xvbfa     LIKE LINE OF gt_xvbfa.

  CLEAR : ls_xvbrp, fc_noarp, fc_rtvnr.
  READ TABLE gt_xvbrp INTO ls_xvbrp
                      WITH KEY vbeln = fu_zuonr.
  IF sy-subrc = 0.
    CLEAR ls_xvbak.
    READ TABLE gt_xvbak INTO ls_xvbak
                        WITH KEY vbeln = ls_xvbrp-aubel.
    IF sy-subrc = 0.
      CLEAR ls_zfarpotd.
      READ TABLE gt_zfarpotd INTO ls_zfarpotd
                             WITH KEY rtvnr = ls_xvbak-bstnk
                                      kunnr = ls_xvbak-kunnr.
      IF sy-subrc = 0.
        CLEAR ls_zfarpoth.
        READ TABLE gt_zfarpoth INTO ls_zfarpoth
                               WITH KEY bukrs = ls_zfarpotd-bukrs
                                        gsber = ls_zfarpotd-gsber
                                        vkbur = ls_zfarpotd-vkbur
                                        noarp = ls_zfarpotd-noarp
                                        mjahr = ls_zfarpotd-mjahr.
        IF sy-subrc = 0.
          IF ls_zfarpoth-belnrrev IS INITIAL.
            fc_noarp = ls_zfarpotd-noarp.
            fc_rtvnr = ls_zfarpotd-rtvnr.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ARPOT
