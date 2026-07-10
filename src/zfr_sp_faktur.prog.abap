************************************************************************
*                                                                      *
*  PROGRAM NAME  :  ZFR_SP_FAKTUR                                      *
*  PROGRAM DESC  :  Surat Pengantar Faktur ( DO/CN )                   *
*  CREATED BY    :  BUDI PRAMONO                                       *
*  CREATED ON    :  15/05/2002 (DMY)                                   *
*  VERSION       :  4.6C                                               *
*                                                                      *
************************************************************************
*                                                                      *
*  MODIFICATION LOG :                                                  *
*                                                                      *
*  DATE        PROGRAMMER       CORRECTION  DESCRIPTION                *
*  ----------  ---------------  ----------  -------------------------  *
*  DD/MM/YYYY  XXXXXXXXXXXXXXX  XXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXX  *
*                                                                      *
************************************************************************
REPORT zfr_sp_faktur MESSAGE-ID zf
                     LINE-SIZE 20
                     LINE-COUNT 80
                     NO STANDARD PAGE HEADING.

*----------------------------------------------------------------------*
* DEFINITION OF TABLES, TYPES & DATA                                   *
*----------------------------------------------------------------------*
INCLUDE zfr_sp_faktur_t.

*----------------------------------------------------------------------*
* DEFINITION OF PARAMETER & SELECTION                                  *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETER p_vkorg LIKE zfvato-vkorg OBLIGATORY DEFAULT '8020'
                                    MODIF ID aaa.
SELECT-OPTIONS s_vkbur FOR zfvato-vkbur.
*SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE text-003.
SELECT-OPTIONS s_prodt FOR zfvato-vatdt MODIF ID dos.
SELECT-OPTIONS s_erdat FOR zfvato-vatdt MODIF ID dos.
SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF BLOCK block3 WITH FRAME TITLE text-004.
PARAMETER p_period LIKE zfvato-duemm MODIF ID don.
SELECT-OPTIONS s_spdot FOR zsl_hsales-spdot MODIF ID don.
SELECT-OPTIONS s_prodt1 FOR zfvato-vatdt MODIF ID don.
SELECT-OPTIONS s_vatdt FOR zfvato-vatdt MODIF ID don.
SELECTION-SCREEN END OF BLOCK block3.

SELECTION-SCREEN BEGIN OF BLOCK block6 WITH FRAME TITLE text-009.
SELECT-OPTIONS s_bldat FOR zsl_hsales-bldat MODIF ID cns.
SELECTION-SCREEN END OF BLOCK block6.

SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block4 WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_do RADIOBUTTON GROUP grp1 USER-COMMAND grp1
                  DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(40) text-010 FOR FIELD p_do.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_cn RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(40) text-011 FOR FIELD p_cn.
SELECTION-SCREEN POSITION 55.
PARAMETERS : p_cn3 AS CHECKBOX DEFAULT 'X' MODIF ID 004.
SELECTION-SCREEN COMMENT (20) text-018 FOR FIELD p_cn3.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 55.
PARAMETERS : p_cn4 AS CHECKBOX MODIF ID 004.
SELECTION-SCREEN COMMENT (20) text-019 FOR FIELD p_cn4.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETER : p_sort1 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(40) text-014 FOR FIELD p_sort1.
SELECTION-SCREEN POSITION 55.
PARAMETERS : p_all RADIOBUTTON GROUP grp3 DEFAULT 'X' MODIF ID 003.
SELECTION-SCREEN COMMENT (20) text-015 FOR FIELD p_all.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 55.
PARAMETERS : p_std RADIOBUTTON GROUP grp3 MODIF ID 003.
SELECTION-SCREEN COMMENT (20) text-016 FOR FIELD p_std.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 55.
PARAMETERS : p_sed RADIOBUTTON GROUP grp3 MODIF ID 003.
SELECTION-SCREEN COMMENT (20) text-017 FOR FIELD p_sed.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block4.

SELECTION-SCREEN BEGIN OF BLOCK block5 WITH FRAME TITLE text-005.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_sap RADIOBUTTON GROUP grp2 USER-COMMAND grp2
                   MODIF ID tes DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(40) text-012 FOR FIELD p_sap MODIF ID tes.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_nosap RADIOBUTTON GROUP grp2 MODIF ID tes.
SELECTION-SCREEN COMMENT 5(40) text-013 FOR FIELD p_nosap MODIF ID tes.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN END OF BLOCK block5.

*
* VALIDATE FOR SELECTION
*------------------------
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF p_do = 'X' OR p_sort1 = 'X'.
      IF p_sap = 'X'.
        IF screen-group1 = 'DON'.
          screen-active = '0'.
        ENDIF.
        IF screen-group1 = 'CNS'.
          screen-active = '0'.
        ENDIF.
      ELSEIF p_nosap = 'X'.
        IF screen-group1 = 'DOS'.
          screen-active = '0'.
        ENDIF.
        IF screen-group1 = 'CNS'.
          screen-active = '0'.
        ENDIF.
      ENDIF.
    ELSEIF p_cn = 'X'.
      IF screen-group1 = 'DON'.
        screen-active = '0'.
      ENDIF.
      IF screen-group1 = 'DOS'.
        screen-active = '0'.
      ENDIF.
      IF screen-group1 = 'TES'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF p_sort1 NE 'X'.
      IF screen-group1 = '003'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF p_cn NE 'X'.
      IF screen-group1 = '004'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

AT SELECTION-SCREEN ON s_vkbur.
  IF p_vkorg = '8030'.
    IF s_vkbur-low = space AND s_vkbur-high = space.
      MESSAGE e000(zf) WITH 'Please Select The Sales Office'.
    ENDIF.
  ENDIF.
  SELECT vkbur bezei
    INTO CORRESPONDING FIELDS OF TABLE i_tvkbt
    FROM tvkbt
    WHERE spras = sy-langu AND
          vkbur IN s_vkbur.
  LOOP AT i_tvkbt.
    AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
        ID 'GSBER' FIELD i_tvkbt-vkbur
        ID 'ACTVT' FIELD '01'.
    IF sy-subrc NE 0.
      MESSAGE e000(zf) WITH
      'You have no authorization for Sales Office' i_tvkbt-vkbur
      i_tvkbt-bezei.
    ENDIF.
  ENDLOOP.

*AT SELECTION-SCREEN ON RADIOBUTTON GROUP GRP1.
*  IF P_CN = 'X'.
*    MESSAGE E000(ZF) WITH 'Select Process SP "DO"'.
*  ENDIF.

AT SELECTION-SCREEN ON RADIOBUTTON GROUP grp2.
*  IF P_DO = 'X' and P_SAP = 'X'.
*    IF S_ERDAT-LOW = 0 AND S_ERDAT-HIGH = 0.
*      MESSAGE I000(ZF) WITH 'Vat Out Date must be entry'.
*      LEAVE SCREEN.
*    ENDIF.
*  ELSEIF P_DO = 'X' and P_NOSAP = 'X'.
*    IF P_PERIOD = 0.
*      MESSAGE I000(ZF) WITH 'Periode must be Entry'.
*      LEAVE SCREEN.
*    ENDIF.
*  ENDIF.

*----------------------------------------------------------------------*
* PROGRAM LOGIC                                                        *
*----------------------------------------------------------------------*
INITIALIZATION.
  DATA: lv_parva(40).

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'VKO'.

  IF sy-subrc EQ 0.
    p_vkorg  = lv_parva.
  ENDIF.

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'VKB'.

  IF sy-subrc EQ 0.
    s_vkbur-low  = lv_parva.
    APPEND s_vkbur.
  ENDIF.


START-OF-SELECTION.

  IF ( p_do = 'X' OR p_sort1 = 'X' ) AND p_sap = 'X'.
*    IF S_ERDAT-LOW = 0 AND S_ERDAT-HIGH = 0.
    IF s_prodt-low = 0 AND s_prodt-high = 0 AND
       s_erdat-low = 0 AND s_erdat-high = 0.
      MESSAGE i000(zf) WITH 'Vat Out Date must be entry'.
      EXIT.
    ENDIF.
  ELSEIF ( p_do = 'X' OR p_sort1 = 'X' ) AND p_nosap = 'X'.
    IF p_period = 0.
      MESSAGE i000(zf) WITH 'Periode must be Entry'.
      EXIT.
    ENDIF.
    IF s_prodt1-low = 0 AND s_prodt1-high = 0 AND
       s_vatdt-low = 0 AND s_vatdt-high = 0.
      MESSAGE i000(zf) WITH 'Vat Out Date must be entry'.
      EXIT.
    ENDIF.
  ELSEIF p_cn = 'X'.
    IF s_bldat-low = 0 AND s_bldat-high = 0.
      MESSAGE i000(zf) WITH 'CN Date must be Entry'.
      EXIT.
    ENDIF.
  ENDIF.

  IF p_do = 'X' OR p_sort1 = 'X'.
    vtype = 'DO'.
    PERFORM f_getdata_do.
    PERFORM f_selectdata_do.
  ENDIF.
  IF p_cn = 'X'.
    vtype = 'CN'.
    PERFORM f_getdata_cn.
    PERFORM f_selectdata_cn.
  ENDIF.

END-OF-SELECTION.

  IF valid = space OR sy-subrc <> 0.
    MESSAGE i000(zf) WITH 'No Record Found'.
  ENDIF.

  CHECK valid <> space AND sy-subrc = 0.

  WRITE sy-repid TO vplist.
  WRITE sy-title TO vprtxt.
  CALL FUNCTION 'GET_PRINT_PARAMETERS'
    EXPORTING
      layout                 = 'Z_KB'
      line_count             = vlinct
      line_size              = vlinsz
      list_name              = vplist
      list_text              = vprtxt
      new_list_id            = 'X'
      priority               = 2
      immediately            = ' '
    IMPORTING
      out_parameters         = pripar
      out_archive_parameters = arcpar
      valid                  = val
    EXCEPTIONS
      archive_info_not_found = 1
      invalid_print_params   = 2
      invalid_archive_params = 3
      OTHERS                 = 4.

  CHECK val <> space AND sy-subrc = 0.
  PERFORM f_format.

*&---------------------------------------------------------------------*
*&      Form  F_GETDATA_DO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_getdata_do.

  DATA : l_spdot(3),
         n TYPE i.

  CLEAR watab1.
  IF p_sap = 'X'.
*{   REPLACE        P01K910424                                        1
*\    SELECT vkbur spart zuonr kunde erdat fkdat dudat ihrez
*\           kunrg name_co stceg vatpr tkwert mwsbk fkart
*\           vbeln vbtyp netwr
*\      FROM zfvato
*\      INTO CORRESPONDING FIELDS OF TABLE itab1
*\      WHERE vkorg = p_vkorg   AND
*\            vkbur IN s_vkbur  AND
*\            prodt IN s_prodt  AND
*\            vatdt IN s_erdat  AND
*\            fl_cancel = space AND
*\*            vtart = 'SD'.
*\            vtart IN ('SD','DN').
    "Start SOH: Shell SCI Adjustment 20240222 RZL
    SELECT vkbur spart zuonr kunde erdat fkdat dudat ihrez
           kunrg name_co stceg vatpr tkwert mwsbk fkart
           vbeln vbtyp netwr
      FROM zfvato
      INTO CORRESPONDING FIELDS OF TABLE itab1
      WHERE vkorg = p_vkorg   AND
            vkbur IN s_vkbur  AND
            prodt IN s_prodt  AND
            vatdt IN s_erdat  AND
            fl_cancel = space AND
*            vtart = 'SD'.
            vtart IN ('SD','DN') ORDER BY PRIMARY KEY.
    "End SOH: Shell SCI Adjustment 20240222 RZL
*}   REPLACE
*            ( FLAG1 = ' ' OR FLAG1 = 'L' ).
    IF sy-subrc = 0.
      LOOP AT itab1 INTO watab1.
        CLEAR v_live.
        SELECT SINGLE live
          FROM zplbc
          INTO v_live
          WHERE bukrs = p_vkorg AND
                werks = watab1-vkbur.
        IF v_live = 'X'.
** Koreksi by Budi 25/09/2006
          watab1-tkwert = watab1-netwr + watab1-mwsbk.
** End Koreksi by Budi 25/09/2006
          SELECT SINGLE bezei
            FROM tvkbt
            INTO watab1-bezei
            WHERE spras = 'EN' AND
                  vkbur = watab1-vkbur.
          SELECT SINGLE vtext
            FROM tspat
            INTO watab1-vtext
            WHERE spras = 'EN' AND
                  spart = watab1-spart.
          IF watab1-vbtyp = 'M'.
            SELECT SINGLE vbelv
              FROM vbfa
              INTO CORRESPONDING FIELDS OF watab1
              WHERE vbeln = watab1-vbeln   AND
                    vbtyp_n = watab1-vbtyp AND
                    stufe = '01'            AND
                    vbtyp_v = 'C'.
          ENDIF.
          IF watab1-vbtyp = '5'.
            SELECT SINGLE vbelv
              FROM vbfa
              INTO CORRESPONDING FIELDS OF watab1
              WHERE vbeln = watab1-vbeln   AND
                    vbtyp_n = watab1-vbtyp AND
                    vbtyp_v = 'J'.
          ENDIF.
          SELECT SINGLE auart
            FROM vbak
            INTO CORRESPONDING FIELDS OF watab1
            WHERE vbeln = watab1-vbelv.
          MODIFY itab1 FROM watab1.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  CLEAR watab1.
  IF p_nosap = 'X'.
*{   REPLACE        P01K910424                                        2
*\    SELECT vkbur spart zuonr kunde erdat fkdat dudat ihrez
*\           kunrg name_co stceg vatpr tkwert mwsbk fkart
*\           vbeln vbtyp netwr
*\      FROM zfvato
*\      INTO CORRESPONDING FIELDS OF TABLE itab1
*\      WHERE vkorg = p_vkorg   AND
*\            vkbur IN s_vkbur  AND
*\            prodt IN s_prodt1 AND
*\            vatdt IN s_vatdt  AND
*\            fl_cancel = space AND
*\*            vtart = 'SD'.
*\            vtart IN ('SD','DN').
    "Start SOH: Shell SCI Adjustment 20240222 RZL
    SELECT vkbur spart zuonr kunde erdat fkdat dudat ihrez
           kunrg name_co stceg vatpr tkwert mwsbk fkart
           vbeln vbtyp netwr
      FROM zfvato
      INTO CORRESPONDING FIELDS OF TABLE itab1
      WHERE vkorg = p_vkorg   AND
            vkbur IN s_vkbur  AND
            prodt IN s_prodt1 AND
            vatdt IN s_vatdt  AND
            fl_cancel = space AND
*            vtart = 'SD'.
            vtart IN ('SD','DN') ORDER BY PRIMARY KEY.
   "End SOH: Shell SCI Adjustment 20240222 RZL
*}   REPLACE
*            ( FLAG1 = ' ' OR FLAG1 = 'L' ).
    IF sy-subrc = 0.
      LOOP AT itab1 INTO watab1.
        CLEAR v_live.
        SELECT SINGLE live
          FROM zplbc
          INTO v_live
          WHERE bukrs = p_vkorg AND
                werks = watab1-vkbur.
        IF v_live = space.
** Koreksi by Budi 25/09/2006
          watab1-tkwert = watab1-netwr.
** End Koreksi by Budi 25/09/2006
          IF watab1-fkdat+4(2) = p_period.
            CLEAR l_spdot.
            WRITE watab1-ihrez+0(3) TO l_spdot.
            n = STRLEN( l_spdot ).
            DO n TIMES.
              IF l_spdot+0(1) = space.
                SHIFT l_spdot.
              ENDIF.
            ENDDO.
*              IF L_SPDOT < 100.
*                SHIFT L_SPDOT.
*              ELSE.
*                IF L_SPDOT < 10.
*                  SHIFT L_SPDOT BY 2 PLACES.
*                ELSE.
*                  IF L_SPDOT < 1.
*                    SHIFT L_SPDOT BY 3 PLACES.
*                  ENDIF.
*                ENDIF.
*              ENDIF.
            IF l_spdot IN s_spdot.
              SELECT SINGLE bezei
                FROM tvkbt
                INTO watab1-bezei
                WHERE spras = 'EN' AND
                      vkbur = watab1-vkbur.
              SELECT SINGLE vtext
                FROM tspat
                INTO watab1-vtext
                WHERE spras = 'EN' AND
                      spart = watab1-spart.
              MODIFY itab1 FROM watab1.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_GETDATA_DO

*&---------------------------------------------------------------------*
*&      Form  F_SELECTDATA_DO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_selectdata_do.

  DATA: vtkwert LIKE zfvato-tkwert,
        vmwsbk  LIKE zfvato-mwsbk,
        vmonth(2).

  CLEAR: watab1, watab2, watab3, valid.
  LOOP AT itab1 INTO watab1.
    AT FIRST.
      valid = 'X'.
    ENDAT.
    CLEAR: watab3, vmonth.
*    IF P_NOSAP = 'X'.
    CLEAR watab1-erdat.
    watab1-erdat = watab1-fkdat.
*    ENDIF.
    vmonth = watab1-erdat+4(2).
    IF p_sort1 = 'X'.
      IF p_sap = 'X'.
        watab2-fkart = watab1-auart.
        watab3-spfno = watab1-vkbur.
      ELSE.
        watab2-fkart = watab1-fkart.
        watab3-spfno = watab1-vkbur.
      ENDIF.
    ELSE.
      IF p_sap = 'X'.
        watab2-fkart = watab1-auart.
        CONCATENATE watab1-vkbur watab1-auart vmonth "WATAB1-SPART
                    INTO watab3-spfno SEPARATED BY '/'.
      ELSE.
        watab2-fkart = watab1-fkart.
        CONCATENATE watab1-vkbur watab1-fkart vmonth "WATAB1-SPART
                    watab1-ihrez+0(3)
                    INTO watab3-spfno SEPARATED BY '/'.
      ENDIF.
    ENDIF.
    watab2-bezei = watab1-bezei.
    watab2-erdat = watab1-erdat.
    watab2-ermon = vmonth.
    watab2-spart = watab1-spart.
    watab2-ihrez = watab1-ihrez.
    watab2-zuonr = watab1-zuonr.
    watab2-kunde = watab1-kunde.
    watab2-kunrg = watab1-kunrg.
    watab2-tkwert = watab1-tkwert.
    watab2-mwsbk = watab1-mwsbk.

    PERFORM f_tax_calc USING s_prodt1-low watab1-netwr 'A'
                       CHANGING watab2-netwr.

*    watab2-netwr = ( watab1-netwr * 100 ) / ( 110 / 100 ).

    watab3-bezei = watab1-bezei.
    watab3-vtext = watab1-vtext.
    watab3-zuonr = watab1-zuonr.
    watab3-kunde = watab1-kunde.
    watab3-erdat = watab1-erdat.
    watab3-dudat = watab1-dudat.
    watab3-kunrg = watab1-kunrg.
    watab3-name_co = watab1-name_co.
    watab3-stceg = watab1-stceg.
*    WATAB3-VATPR = WATAB1-VATPR.
    IF watab3-dudat GE '20070101'.
      watab3-vatpr = watab1-vatpr.
    ELSE.
      CONCATENATE watab1-vatpr(10) watab1-vatpr+11(7) INTO watab3-vatpr.
    ENDIF.
    watab3-tkwert = watab1-tkwert.
    watab3-mwsbk = watab1-mwsbk.

    PERFORM f_tax_calc USING s_prodt1-low watab1-netwr 'A'
                       CHANGING watab2-netwr.

*    watab3-netwr = ( watab1-netwr * 100 ) / ( 110 / 100 ).

    watab3-prefx = vtype.
    MODIFY itab1 FROM watab1.
    APPEND watab2 TO itab2.
    APPEND watab3 TO itab3.
  ENDLOOP.

ENDFORM.                    " F_SELECTDATA_DO

*&---------------------------------------------------------------------*
*&      Form  F_CETAK_SUMMARY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cetak_summary.

  DATA: v_totinv(8) TYPE p DECIMALS 0,
        v_tkwert(15) TYPE p DECIMALS 0,
        v_tmwsbk(12) TYPE p DECIMALS 0,
        v_tmwsbk2(12) TYPE p DECIMALS 0,
        v_totkwert(15) TYPE p DECIMALS 0,
        v_totmwsbk(12) TYPE p DECIMALS 0,
        v_totmwsbk2(12) TYPE p DECIMALS 0,
        v_btotsp(6) TYPE p DECIMALS 0,
        v_btotinv(8) TYPE p DECIMALS 0,
        v_btotkwert(15) TYPE p DECIMALS 0,
        v_btotmwsbk(12) TYPE p DECIMALS 0,
        v_btotmwsbk2(12) TYPE p DECIMALS 0,
        v_gtotsp(6) TYPE p DECIMALS 0,
        v_gtotinv(8) TYPE p DECIMALS 0,
        v_gtotkwert(15) TYPE p DECIMALS 0,
        v_gtotmwsbk(12) TYPE p DECIMALS 0,
        v_gtotmwsbk2(12) TYPE p DECIMALS 0,
        v_bezei  LIKE  tvkbt-bezei,
        v_erdat(10),
*        V_ERDAT  LIKE  ZFVATO-ERDAT,
        v_fkart  LIKE  zfvato-fkart,
        v_ermon(2),
        v_spart  LIKE  zfvato-spart,
        v_ihrez  LIKE  zfvato-ihrez,
        l_gform LIKE kna1-gform.

  CLEAR: watab2, page.
  SORT itab2 BY bezei erdat fkart ermon ihrez.
  LOOP AT itab2 INTO watab2.

    CLEAR: v_tkwert, v_tmwsbk, v_tmwsbk2.

*** KOREKSI ***
*    IF SY-LINNO = 1.
*      ADD 1 TO PAGE.
*      PERFORM F_CETAK_HEADER_SUMMARY.
*    ENDIF.

    AT FIRST.
      ADD 1 TO page.
      PERFORM f_cetak_header_summary.
    ENDAT.
*--------------
    AT NEW bezei.
      v_bezei = watab2-bezei.
      WRITE watab2-erdat TO v_erdat.
*      V_ERDAT = WATAB2-ERDAT.
      v_fkart = watab2-fkart.
      v_ermon = watab2-ermon.
      v_ihrez = watab2-ihrez.
    ENDAT.
    AT NEW erdat.
      WRITE watab2-erdat TO v_erdat.
*      V_ERDAT = WATAB2-ERDAT.
      v_fkart = watab2-fkart.
      v_ermon = watab2-ermon.
      v_ihrez = watab2-ihrez.
    ENDAT.
    AT NEW fkart.
      v_fkart = watab2-fkart.
      v_ermon = watab2-ermon.
      v_ihrez = watab2-ihrez.
    ENDAT.
    AT NEW ermon.
      v_ermon = watab2-ermon.
      v_ihrez = watab2-ihrez.
    ENDAT.
    AT NEW ihrez.
      v_ihrez = watab2-ihrez.
    ENDAT.

    SELECT SINGLE gform FROM kna1 INTO l_gform
      WHERE kunnr = watab2-kunrg.
    IF l_gform = 'A2'.
      v_tmwsbk2 = watab2-mwsbk * 100.
    ELSE.
      v_tmwsbk = watab2-mwsbk * 100.
    ENDIF.
    v_tkwert = watab2-tkwert * 100.
    ADD 1 TO v_totinv.
    ADD v_tkwert TO v_totkwert.
    ADD v_tmwsbk TO v_totmwsbk.
    ADD v_tmwsbk2 TO v_totmwsbk2.
    ADD 1 TO v_btotinv.
    ADD v_tkwert TO v_btotkwert.
    ADD v_tmwsbk TO v_btotmwsbk.
    ADD v_tmwsbk2 TO v_btotmwsbk2.
    ADD 1 TO v_gtotinv.
    ADD v_tkwert TO v_gtotkwert.
    ADD v_tmwsbk TO v_gtotmwsbk.
    ADD v_tmwsbk2 TO v_gtotmwsbk2.

    AT END OF ihrez.
      ADD 1 TO v_btotsp.
      ADD 1 TO v_gtotsp.
*** KOREKSI ***
      IF sy-linno = 80.
        NEW-PAGE.
        ADD 1 TO page.
        PERFORM f_cetak_header_summary.
      ENDIF.
*--------------
      WRITE: /1 v_bezei,
             25 v_erdat,
             38 v_fkart,
             46 v_ermon,
             52 v_ihrez,
             64 v_totinv,
             79 v_totkwert NO-GAP,
            109 v_totmwsbk NO-GAP,
            134 v_totmwsbk2 NO-GAP.
      CLEAR: v_totinv, v_totkwert, v_totmwsbk, v_totmwsbk2.
      CLEAR: v_bezei, v_erdat, v_fkart, v_ermon, v_ihrez.
    ENDAT.
    AT END OF bezei.
*** KOREKSI ***
      IF sy-linno = 80.
        NEW-PAGE.
        ADD 1 TO page.
        PERFORM f_cetak_header_summary.
      ENDIF.
*--------------
      WRITE /.
*** KOREKSI ***
      IF sy-linno = 80.
        NEW-PAGE.
        ADD 1 TO page.
        PERFORM f_cetak_header_summary.
      ENDIF.
*--------------
      WRITE: /20 'TOTAL', watab2-bezei,
              49 v_btotsp,
              64 v_btotinv,
              79 v_btotkwert,
             109 v_btotmwsbk,
             134 v_btotmwsbk2.
*** KOREKSI ***
      IF sy-linno = 80.
        NEW-PAGE.
        ADD 1 TO page.
        PERFORM f_cetak_header_summary.
      ENDIF.
*--------------
      WRITE /.
      CLEAR: v_btotsp,v_btotinv,v_btotkwert,v_btotmwsbk,v_btotmwsbk2.
    ENDAT.

  ENDLOOP.

  WRITE: /20 'G R A N D  T O T A L',
          49 v_gtotsp,
          64 v_gtotinv,
          79 v_gtotkwert,
         109 v_gtotmwsbk,
         134 v_gtotmwsbk2.

ENDFORM.                    " F_CETAK_SUMMARY

*&---------------------------------------------------------------------*
*&      Form  F_CETAK_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cetak_detail.

  DATA: v_tkwert(11) TYPE p DECIMALS 0,
        v_tmwsbk(9) TYPE p DECIMALS 0,
        v_tmwsbk2(9) TYPE p DECIMALS 0,
        v_totkwert(11) TYPE p DECIMALS 0,
        v_totmwsbk(9) TYPE p DECIMALS 0,
        v_totmwsbk2(9) TYPE p DECIMALS 0,
        v_tnetwr(11) TYPE p DECIMALS 0,
        v_totnetwr(11) TYPE p DECIMALS 0,
        v_seq(4) TYPE n,
        l_gform LIKE kna1-gform.

  CLEAR: watab3, page.
*  IF p_do = 'X'.
*    IF p_sap = 'X'.
*      SORT itab3 BY spfno vatpr.
*    ELSE.
*      SORT itab3 BY spfno zuonr.
*    ENDIF.
*  ELSE.
*    SORT itab3 BY spfno zuonr.
*  ENDIF.
  IF p_sort1 IS NOT INITIAL.
    SORT itab3 BY spfno vatpr zuonr.
  ELSE.
    SORT itab3 BY spfno zuonr vatpr.
  ENDIF.

  LOOP AT itab3 INTO watab3.

    IF p_sort1 = 'X'.
      IF p_std = 'X'.
        IF watab3-vatpr IS INITIAL.
          CONTINUE.
        ENDIF.
      ELSEIF p_sed = 'X'.
        IF watab3-vatpr IS NOT INITIAL.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.

    AT NEW spfno.
      CLEAR v_seq.
      NEW-PAGE.
      sy-linno = 1.
    ENDAT.
    IF sy-linno = 1.
      ADD 1 TO page.
      PERFORM f_cetak_header_detail.
    ENDIF.

    CLEAR: v_tkwert, v_tmwsbk, v_tmwsbk2, l_gform.
    SELECT SINGLE gform FROM kna1 INTO l_gform
      WHERE kunnr = watab3-kunrg.
    IF l_gform = 'A2'.
      v_tmwsbk2 = watab3-mwsbk * 100.
    ELSE.
      v_tmwsbk = watab3-mwsbk * 100.
    ENDIF.
    v_tkwert = watab3-tkwert * 100.
    v_tnetwr = watab3-netwr.
    ADD v_tkwert TO v_totkwert.
    ADD v_tmwsbk TO v_totmwsbk.
    ADD v_tmwsbk2 TO v_totmwsbk2.
    ADD v_tnetwr TO v_totnetwr.
    ADD 1 TO v_seq.
*** KOREKSI ***
    IF sy-linno = 80.
      NEW-PAGE.
      ADD 1 TO page.
      PERFORM f_cetak_header_detail.
    ENDIF.
*--------------
    IF p_sort1 = 'X' AND watab3-vatpr IS INITIAL.
      watab3-vatpr = watab3-zuonr.
    ENDIF.
    WRITE: / v_seq NO-ZERO, space,
             watab3-zuonr(10),
             watab3-kunde(10),
             watab3-erdat,
             watab3-dudat, space,
             watab3-kunrg(10),
             watab3-name_co(30), space,
             watab3-stceg(20),
             watab3-vatpr(20),
             v_tkwert,
             v_tmwsbk NO-GAP,
             v_tmwsbk2,
*             v_tnetwr,
             watab3-prefx.

    AT END OF spfno.
*** KOREKSI ***
      IF sy-linno = 80.
        NEW-PAGE.
        ADD 1 TO page.
        PERFORM f_cetak_header_detail.
      ENDIF.
*--------------
      WRITE: /.
*** KOREKSI ***
      IF sy-linno = 80.
        NEW-PAGE.
        ADD 1 TO page.
        PERFORM f_cetak_header_detail.
      ENDIF.
*--------------
      WRITE: /105 'TOTAL :',
              140 v_totkwert,
                  v_totmwsbk NO-GAP,
                  v_totmwsbk2.
*                  v_totnetwr.
      CLEAR: v_totkwert, v_totmwsbk, v_totmwsbk2, v_totnetwr.
    ENDAT.

  ENDLOOP.

ENDFORM.                    " F_CETAK_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_CETAK_HEADER_SUMMARY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cetak_header_summary.

  WRITE: /   'PT. TEMPO DATA SYSTEM',
         /   'DATE :', sy-datum,
          70 'SUMMARY OF TOTAL SP -', vtype,
         140 'PAGE :', page(4),
         /   'TIME :', sy-uzeit,
         /   sy-uline(157),
         /8  'BRANCH',
          28 'DATE',
          37 vtype, 'TYP',
          45 'MONTH',
          53 'NUMBER',
          68 'TOT.INVOICE',
          97 'TOTAL VALUE',
         122 'TOTAL A1 V.A.T',
         143 'TOTAL A2 V.A.T',
         /   sy-uline(157).

ENDFORM.                    " F_CETAK_HEADER_SUMMARY

*&---------------------------------------------------------------------*
*&      Form  F_CETAK_HEADER_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cetak_header_detail.

*  WRITE: /   'PT. TEMPO DATA SYSTEM',
*         /   'DATE :', sy-datum,
*          85 'SURAT PENGANTAR FAKTUR -', vtype,
*         180 'PAGE :', page,
*         /   'TIME :', sy-uzeit,
*          85 'SEND TO :', watab3-bezei,
*         /85 'DIVISI  :', watab3-vtext,
*         /85 'SEND DT :', watab3-erdat,
*         /   'SPF NO :', watab3-spfno.
  WRITE: /   'PT. TEMPO DATA SYSTEM',
          85 'SURAT PENGANTAR FAKTUR -', vtype,
         /   'DATE :', sy-datum,
          85 'SEND TO :', watab3-bezei,
         180 'PAGE :', page,
         /   'TIME :', sy-uzeit,
          85 'DIVISI  :', watab3-vtext.
*         /85 'SEND DT :', watab3-erdat.

  IF p_do = 'X' OR p_sort1 = 'X'.
    IF p_sap = 'X'.
      WRITE: /85 'Vat Out Printed Date :', s_erdat-low,
                 'To', s_erdat-high.
    ELSE.
      WRITE: /85 'Vat Out Printed Date :', s_vatdt-low,
                 'To', s_vatdt-high.
    ENDIF.
  ENDIF.

  IF p_sort1 = 'X'.
    WRITE: /   'BRANCH :', watab3-spfno.
  ELSE.
    WRITE: /   'SPF NO :', watab3-spfno.
  ENDIF.

  IF p_do = 'X' OR p_sort1 = 'X'.
    IF p_sap = 'X'.
*        WRITE: 85 'Vat Out Printed Date :',
*                   S_ERDAT-LOW,
*                   'To',
*                   S_ERDAT-HIGH.
      WRITE: 85 'Vat Out Process Date :',
                 s_prodt-low,
                 'To',
                 s_prodt-high.
    ELSE.
*        WRITE: 85 'Vat Out Printed Date :',
*                   S_VATDT-LOW,
*                   'To',
*                   S_VATDT-HIGH.
      WRITE: 85 'Vat Out Process Date :',
                 s_prodt1-low,
                 'To',
                 s_prodt1-high.
    ENDIF.
  ELSE.
    WRITE: 85 'CN Date :',
               s_bldat-low,
               'To',
               s_bldat-high.
  ENDIF.
  WRITE: /   sy-uline,
         /2  'SEQ',
          8  vtype, 'NUMBER',
          19 'ROUTE LIST',
          33 'DATE',
          42 'DUE DATE',
          55 'OUTLET',
          66 'DESCRIPTION',
         103 'NPWP',
         120 'FAKTUR PAJAK NO.',
         152 'VALUE A/R',
         171 'V.A.T  A1',
         189 'V.A.T  A2',
         199 'TYP',
         /   sy-uline.

ENDFORM.                    " F_CETAK_HEADER_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_FLAG_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_flag_data.

*  CLEAR WATAB1.
*  LOOP AT ITAB1 INTO WATAB1.
*    UPDATE ZFVATO SET FLAG1 = 'L'
*           WHERE VKORG = P_VKORG      AND
*                 VKBUR = WATAB1-VKBUR AND
*                 ZUONR = WATAB1-ZUONR AND
*                 SPART = WATAB1-SPART AND
*                 IHREZ = WATAB1-IHREZ AND
*                 VATPR = WATAB1-VATPR.
*  ENDLOOP.

ENDFORM.                    " F_FLAG_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FORMAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_format.

  CALL FUNCTION 'GET_PRINT_PARAMETERS'
    EXPORTING
      in_archive_parameters  = arcpar
      in_parameters          = pripar
      no_dialog              = 'X'
    IMPORTING
      out_archive_parameters = arcpar
      out_parameters         = pripar
      valid                  = val
    EXCEPTIONS
      archive_info_not_found = 1
      invalid_print_params   = 2
      invalid_archive_params = 3
      OTHERS                 = 4.

  IF val <> space AND sy-subrc = 0.

    CONCATENATE vprtxt 'SUM' INTO pripar-prtxt SEPARATED BY space.
    NEW-PAGE PRINT ON
      NEW-SECTION
      PARAMETERS pripar
      ARCHIVE PARAMETERS arcpar
      NO DIALOG.
    PERFORM f_cetak_summary.

    CONCATENATE vprtxt 'DET' INTO pripar-prtxt SEPARATED BY space.
    NEW-PAGE PRINT ON
      NEW-SECTION
      PARAMETERS pripar
      ARCHIVE PARAMETERS arcpar
      NO DIALOG.
    PERFORM f_cetak_detail.

*    PERFORM F_FLAG_DATA.

  ENDIF.

ENDFORM.                    " F_FORMAT

*&---------------------------------------------------------------------*
*&      Form  F_GETDATA_CN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_getdata_cn.

  DATA  :  l_adrnr LIKE kna1-adrnr,
           l_vkbur LIKE knvv-vkbur.
*{   INSERT         P01K900245                                        1
  DATA  :  l_belnr LIKE bsis-belnr,
           l_gjahr LIKE bsis-gjahr.

  DATA : lv_wrbtr   TYPE netwr_ak.
*}   INSERT

*  Get Data NONSAP Branch
*-------------------------
  IF p_cn3 = 'X'.
    IF p_vkorg = '8020'.
*{   REPLACE        P01K910424                                        4
*\      SELECT a~plant a~vbeln a~kunde a~bldat a~txdat a~spdot a~kunnr
*\             a~netwr a~mwsbp a~fkart a~account_no a~vbtyp a~tax_status
*\             a~vkbur
*\        INTO (watab1-vkbur, watab1-zuonr, watab1-kunde, watab1-fkdat,
*\              watab1-dudat, watab1-ihrez, watab1-kunrg, watab1-tkwert,
*\              watab1-mwsbk, watab1-fkart, watab1-vbeln, watab1-vbtyp,
*\              watab1-cityc, watab1-vkbur1)
*\        FROM zsl_hsales AS a
*\        WHERE a~vkorg = p_vkorg AND
*\              a~vkbur IN s_vkbur AND
*\              a~vbtyp = 'O' AND
*\              a~status NE '4' AND
*\              a~bldat IN s_bldat.
      "Start SOH: Shell SCI Adjustment 20240222 RZL
      SELECT a~plant a~vbeln a~kunde a~bldat a~txdat a~spdot a~kunnr
             a~netwr a~mwsbp a~fkart a~account_no a~vbtyp a~tax_status
             a~vkbur
        INTO (watab1-vkbur, watab1-zuonr, watab1-kunde, watab1-fkdat,
              watab1-dudat, watab1-ihrez, watab1-kunrg, watab1-tkwert,
              watab1-mwsbk, watab1-fkart, watab1-vbeln, watab1-vbtyp,
              watab1-cityc, watab1-vkbur1)
        FROM zsl_hsales AS a
        WHERE a~vkorg = p_vkorg AND
              a~vkbur IN s_vkbur AND
              a~vbtyp = 'O' AND
              a~status NE '4' AND
              a~bldat IN s_bldat ORDER BY PRIMARY KEY.
        "End SOH: Shell SCI Adjustment 20240222 RZL
*}   REPLACE
        APPEND watab1 TO itab1. CLEAR watab1.
      ENDSELECT.

    ELSEIF p_vkorg = '8070'.
*{   REPLACE        P01K910424                                        5
*\      SELECT a~plant a~vbeln a~kunde a~bldat a~txdat a~spdot a~kunnr
*\             a~netwr a~mwsbp a~fkart a~account_no a~vbtyp a~tax_status
*\             a~vkbur
*\        INTO (watab1-vkbur, watab1-zuonr, watab1-kunde, watab1-fkdat,
*\              watab1-dudat, watab1-ihrez, watab1-kunrg, watab1-tkwert,
*\              watab1-mwsbk, watab1-fkart, watab1-vbeln, watab1-vbtyp,
*\              watab1-cityc, watab1-vkbur1)
*\        FROM zssutdt005 AS a
*\        WHERE a~vkorg = p_vkorg AND
*\              a~vkbur IN s_vkbur AND
*\              a~vbtyp = 'O' AND
*\              a~status NE '4' AND
*\              a~bldat IN s_bldat.
      "Start SOH: Shell SCI Adjustment 20240222 RZL
      SELECT a~plant a~vbeln a~kunde a~bldat a~txdat a~spdot a~kunnr
             a~netwr a~mwsbp a~fkart a~account_no a~vbtyp a~tax_status
             a~vkbur
        INTO (watab1-vkbur, watab1-zuonr, watab1-kunde, watab1-fkdat,
              watab1-dudat, watab1-ihrez, watab1-kunrg, watab1-tkwert,
              watab1-mwsbk, watab1-fkart, watab1-vbeln, watab1-vbtyp,
              watab1-cityc, watab1-vkbur1)
        FROM zssutdt005 AS a
        WHERE a~vkorg = p_vkorg AND
              a~vkbur IN s_vkbur AND
              a~vbtyp = 'O' AND
              a~status NE '4' AND
              a~bldat IN s_bldat ORDER BY PRIMARY KEY.
       "End SOH: Shell SCI Adjustment 20240222 RZL
*}   REPLACE
        APPEND watab1 TO itab1. CLEAR watab1.
      ENDSELECT.
    ENDIF.
  ENDIF.

  IF p_cn4 = 'X'.
    IF p_vkorg = '8020'.
*{   REPLACE        P01K910424                                        6
*\      SELECT a~plant a~vbeln a~kunde a~bldat a~txdat a~spdot a~kunnr
*\             a~netwr a~mwsbp a~fkart a~account_no a~vbtyp a~tax_status
*\             a~vkbur
*\        INTO (watab1-vkbur, watab1-zuonr, watab1-kunde, watab1-fkdat,
*\              watab1-dudat, watab1-ihrez, watab1-kunrg, watab1-tkwert,
*\              watab1-mwsbk, watab1-fkart, watab1-vbeln, watab1-vbtyp,
*\              watab1-cityc, watab1-vkbur1)
*\        FROM zsl_hsales AS a
*\        WHERE a~vkorg = p_vkorg AND
*\              a~vkbur IN s_vkbur AND
*\              a~vbtyp = 'O' AND
*\              a~status = '4' AND
*\              a~bldat IN s_bldat.
      "Start SOH: Shell SCI Adjustment 20240222 RZL
      SELECT a~plant a~vbeln a~kunde a~bldat a~txdat a~spdot a~kunnr
             a~netwr a~mwsbp a~fkart a~account_no a~vbtyp a~tax_status
             a~vkbur
        INTO (watab1-vkbur, watab1-zuonr, watab1-kunde, watab1-fkdat,
              watab1-dudat, watab1-ihrez, watab1-kunrg, watab1-tkwert,
              watab1-mwsbk, watab1-fkart, watab1-vbeln, watab1-vbtyp,
              watab1-cityc, watab1-vkbur1)
        FROM zsl_hsales AS a
        WHERE a~vkorg = p_vkorg AND
              a~vkbur IN s_vkbur AND
              a~vbtyp = 'O' AND
              a~status = '4' AND
              a~bldat IN s_bldat ORDER BY PRIMARY KEY.
      "End SOH: Shell SCI Adjustment 20240222 RZL
*}   REPLACE
        APPEND watab1 TO itab1. CLEAR watab1.
      ENDSELECT.

    ELSEIF p_vkorg = '8070'.
*{   REPLACE        P01K910424                                        7
*\      SELECT a~plant a~vbeln a~kunde a~bldat a~txdat a~spdot a~kunnr
*\             a~netwr a~mwsbp a~fkart a~account_no a~vbtyp a~tax_status
*\             a~vkbur
*\        INTO (watab1-vkbur, watab1-zuonr, watab1-kunde, watab1-fkdat,
*\              watab1-dudat, watab1-ihrez, watab1-kunrg, watab1-tkwert,
*\              watab1-mwsbk, watab1-fkart, watab1-vbeln, watab1-vbtyp,
*\              watab1-cityc, watab1-vkbur1)
*\        FROM zssutdt005 AS a
*\        WHERE a~vkorg = p_vkorg AND
*\              a~vkbur IN s_vkbur AND
*\              a~vbtyp = 'O' AND
*\              a~status = '4' AND
*\              a~bldat IN s_bldat.
      "Start SOH: Shell SCI Adjustment 20240222 RZL
      SELECT a~plant a~vbeln a~kunde a~bldat a~txdat a~spdot a~kunnr
             a~netwr a~mwsbp a~fkart a~account_no a~vbtyp a~tax_status
             a~vkbur
        INTO (watab1-vkbur, watab1-zuonr, watab1-kunde, watab1-fkdat,
              watab1-dudat, watab1-ihrez, watab1-kunrg, watab1-tkwert,
              watab1-mwsbk, watab1-fkart, watab1-vbeln, watab1-vbtyp,
              watab1-cityc, watab1-vkbur1)
        FROM zssutdt005 AS a
        WHERE a~vkorg = p_vkorg AND
              a~vkbur IN s_vkbur AND
              a~vbtyp = 'O' AND
              a~status = '4' AND
              a~bldat IN s_bldat ORDER BY PRIMARY KEY.
       "End SOH: Shell SCI Adjustment 20240222 RZL
*}   REPLACE
        APPEND watab1 TO itab1. CLEAR watab1.
      ENDSELECT.
    ENDIF.
  ENDIF.

  LOOP AT itab1 INTO watab1.
    CLEAR: l_adrnr.
    watab1-spart = '00'.
    watab1-erdat = watab1-fkdat.
    SELECT SINGLE bezei INTO watab1-bezei
      FROM tvkbt WHERE spras = 'EN' AND
                       vkbur = watab1-vkbur.
    SELECT SINGLE adrnr stceg
      INTO (l_adrnr, watab1-stceg)
      FROM kna1 WHERE kunnr EQ watab1-kunrg.
    SELECT SINGLE name_co INTO watab1-name_co
      FROM adrc WHERE addrnumber = l_adrnr.
    SELECT SINGLE vtext INTO watab1-vtext
      FROM tspat WHERE spras = 'EN' AND
                       spart = watab1-spart.
*{   DELETE         P01K900245                                        2
*\    IF watab1-cityc = 'T0'.
*\      CLEAR watab1-mwsbk.
*\    ENDIF.
*}   DELETE
*{   INSERT         P01K900245                                        3
    l_gjahr = watab1-fkdat(4).
    SELECT SINGLE belnr INTO l_belnr
      FROM bsis WHERE bukrs = p_vkorg AND
                      hkont = '0315300100' AND
                      zuonr = watab1-zuonr AND
                      gjahr = l_gjahr.
    IF sy-subrc NE 0.
      SELECT SINGLE belnr INTO l_belnr
        FROM bsas WHERE bukrs = p_vkorg AND
                        hkont = '0315300100' AND
                        zuonr = watab1-zuonr AND
                        gjahr = l_gjahr.
      IF sy-subrc NE 0.
        CLEAR watab1-mwsbk.
      ENDIF.
    ENDIF.
*}   INSERT
    MODIFY itab1 FROM watab1.
    CLEAR watab1.
  ENDLOOP.

*  Get Data SAP Branch
*----------------------
  IF p_cn3 = 'X' AND p_cn4 = 'X'.
    SELECT b~vwerk a~zuonr a~fkdat a~kunrg a~netwr a~mwsbk a~fkart
           a~vbeln a~vbtyp a~spart a~cityc a~ktgrd b~vkbur
      INTO (watab1-vkbur, watab1-zuonr, watab1-fkdat, watab1-kunrg,
            watab1-tkwert, watab1-mwsbk, watab1-fkart, watab1-vbeln,
            watab1-vbtyp, watab1-spart, watab1-cityc, watab1-ktgrd,
            watab1-vkbur1)
      FROM vbrk AS a JOIN knvv AS b ON a~kunrg = b~kunnr AND
                                       a~vkorg = b~vkorg AND
                                       a~vtweg = b~vtweg AND
                                       a~spart = b~spart
                     JOIN tvkol AS d ON b~vkbur = d~vstel
                     JOIN zplbc AS c ON d~werks = c~werks AND
                                        d~lgort = c~lgort
      WHERE a~vkorg = p_vkorg  AND
            a~fkdat IN s_bldat AND
            a~fksto = space    AND
            ( a~vbtyp = 'O' OR a~vbtyp = '6' ) AND
            b~vkbur IN s_vkbur AND
            c~live = 'X'.

      SELECT SINGLE vkbur INTO l_vkbur FROM zsl_hsales
        WHERE bldat IN s_bldat AND
              plant = watab1-vkbur AND
              vkbur = watab1-vkbur1.

      IF sy-subrc NE 0.
        APPEND watab1 TO itab1. CLEAR watab1.
      ENDIF.
    ENDSELECT.
  ELSE.
    IF p_cn3 = 'X'.
      SELECT b~vwerk a~zuonr a~fkdat a~kunrg a~netwr a~mwsbk a~fkart
             a~vbeln a~vbtyp a~spart a~cityc a~ktgrd b~vkbur
        INTO (watab1-vkbur, watab1-zuonr, watab1-fkdat, watab1-kunrg,
              watab1-tkwert, watab1-mwsbk, watab1-fkart, watab1-vbeln,
              watab1-vbtyp, watab1-spart, watab1-cityc, watab1-ktgrd,
              watab1-vkbur1)
        FROM vbrk AS a JOIN knvv AS b ON a~kunrg = b~kunnr AND
                                         a~vkorg = b~vkorg AND
                                         a~vtweg = b~vtweg AND
                                         a~spart = b~spart
                       JOIN tvkol AS d ON b~vkbur = d~vstel
                       JOIN zplbc AS c ON d~werks = c~werks AND
                                          d~lgort = c~lgort
        WHERE a~vkorg = p_vkorg  AND
              a~fkdat IN s_bldat AND
              a~fksto = space    AND
              ( a~vbtyp = 'O' OR a~vbtyp = '6' ) AND
              b~vkbur IN s_vkbur AND
              c~live = 'X'.

        CLEAR: va_aubel, va_vbeln, va_auart.
        SELECT SINGLE aubel INTO (va_aubel)
          FROM vbrp
          WHERE vbeln = watab1-vbeln.
        IF sy-subrc = 0.
          SELECT SINGLE vbeln auart INTO (va_vbeln, va_auart)
            FROM vbak
            WHERE vbeln = va_aubel.
        ENDIF.
        IF va_auart(3) = 'ZRA'.
          CONTINUE.
        ENDIF.

        SELECT SINGLE vkbur INTO l_vkbur FROM zsl_hsales
          WHERE bldat IN s_bldat AND
                plant = watab1-vkbur AND
                vkbur = watab1-vkbur1.

        IF sy-subrc NE 0.
          APPEND watab1 TO itab1. CLEAR watab1.
        ENDIF.
      ENDSELECT.
    ENDIF.
    IF p_cn4 = 'X'.
      SELECT b~vwerk a~zuonr a~fkdat a~kunrg a~netwr a~mwsbk a~fkart
             a~vbeln a~vbtyp a~spart a~cityc a~ktgrd b~vkbur
        INTO (watab1-vkbur, watab1-zuonr, watab1-fkdat, watab1-kunrg,
              watab1-tkwert, watab1-mwsbk, watab1-fkart, watab1-vbeln,
              watab1-vbtyp, watab1-spart, watab1-cityc, watab1-ktgrd,
              watab1-vkbur1)
        FROM vbrk AS a JOIN knvv AS b ON a~kunrg = b~kunnr AND
                                         a~vkorg = b~vkorg AND
                                         a~vtweg = b~vtweg AND
                                         a~spart = b~spart
                       JOIN tvkol AS d ON b~vkbur = d~vstel
                       JOIN zplbc AS c ON d~werks = c~werks AND
                                          d~lgort = c~lgort
        WHERE a~vkorg = p_vkorg  AND
              a~fkdat IN s_bldat AND
              a~fksto = space    AND
              ( a~vbtyp = 'O' OR a~vbtyp = '6' ) AND
              b~vkbur IN s_vkbur AND
              c~live = 'X'.

        CLEAR: va_aubel, va_vbeln, va_auart.
        SELECT SINGLE aubel INTO (va_aubel)
          FROM vbrp
          WHERE vbeln = watab1-vbeln.
        IF sy-subrc = 0.
          SELECT SINGLE vbeln auart INTO (va_vbeln, va_auart)
            FROM vbak
            WHERE vbeln = va_aubel.
        ENDIF.
        IF va_auart(3) NE 'ZRA'.
          CONTINUE.
        ENDIF.

        SELECT SINGLE vkbur INTO l_vkbur FROM zsl_hsales
          WHERE bldat IN s_bldat AND
                plant = watab1-vkbur AND
                vkbur = watab1-vkbur1.

        IF sy-subrc NE 0.
          APPEND watab1 TO itab1. CLEAR watab1.
        ENDIF.
      ENDSELECT.
    ENDIF.
  ENDIF.
  LOOP AT itab1 INTO watab1 WHERE bezei = space.
    CLEAR: l_adrnr.
    watab1-erdat = watab1-fkdat.
    watab1-dudat = watab1-fkdat.
    watab1-ihrez = '00000000'.
    SELECT SINGLE bezei INTO watab1-bezei
      FROM tvkbt WHERE spras = 'EN' AND
                       vkbur = watab1-vkbur.
    SELECT SINGLE adrnr stceg
      INTO (l_adrnr, watab1-stceg)
      FROM kna1 WHERE kunnr EQ watab1-kunrg.
    SELECT SINGLE name_co INTO watab1-name_co
      FROM adrc WHERE addrnumber = l_adrnr.
    SELECT SINGLE vtext INTO watab1-vtext
      FROM tspat WHERE spras = 'EN' AND
                       spart = watab1-spart.
    SELECT SINGLE kunnr INTO watab1-kunde
      FROM vbpa WHERE vbeln = watab1-vbeln AND
                parvw = 'ZS'.
    SELECT SINGLE vbelv INTO watab1-vbelv
      FROM vbfa WHERE vbeln = watab1-vbeln   AND
                      vbtyp_n = watab1-vbtyp AND
                      stufe = '01'            AND
                      vbtyp_v = 'C'.
    SELECT SINGLE auart INTO watab1-auart
      FROM vbak WHERE vbeln = watab1-vbelv.
*    IF watab1-cityc = 'T0'.
    IF watab1-ktgrd = '00'.
      CLEAR watab1-mwsbk.
    ENDIF.
** Koreksi by budi 11/10/2006
*    IF watab1-cityc = 'T0'.
    IF watab1-ktgrd = '00'.
      watab1-tkwert = watab1-tkwert.
    ELSE.
      lv_wrbtr  = watab1-tkwert.
      CALL FUNCTION 'Z_PPN11'
        EXPORTING
          pi_wrbtr = lv_wrbtr
          pi_calty = 'B'
          pi_datum = s_prodt1-low
        IMPORTING
          po_wrbtr = lv_wrbtr.

      watab1-tkwert = lv_wrbtr.

*      watab1-tkwert = watab1-tkwert * 110 / 100.
    ENDIF.
** End Koreksi by budi 11/10/2006
    MODIFY itab1 FROM watab1.
    CLEAR watab1.
  ENDLOOP.

ENDFORM.                    " F_GETDATA_CN

*&---------------------------------------------------------------------*
*&      Form  F_SELECTDATA_CN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_selectdata_cn.

  DATA: vmonth(2).

  CLEAR: watab1, watab2, watab3, valid.
  LOOP AT itab1 INTO watab1.
*{   REPLACE        P01K910424                                        1
*\    AT FIRST.
    "Start SOH: Shell SCI Adjustment 20240222 RZL
    AT FIRST. "#EC CI_SORTED
    "End SOH: Shell SCI Adjustment 20240222 RZL
*}   REPLACE
      valid = 'X'.
    ENDAT.
    CLEAR: watab3, vmonth.
    vmonth = watab1-erdat+4(2).
    SELECT SINGLE * FROM zplbc WHERE bukrs = p_vkorg AND
                                     werks = watab1-vkbur.
    IF zplbc-live = 'X'.
*      WATAB2-FKART = WATAB1-AUART.
      CONCATENATE watab1-vkbur watab1-fkart vmonth "WATAB1-SPART
                  INTO watab3-spfno SEPARATED BY '/'.
    ELSE.
*      WATAB2-FKART = WATAB1-FKART.
      CONCATENATE watab1-vkbur watab1-fkart vmonth "WATAB1-SPART
                  watab1-ihrez+0(3)
                  INTO watab3-spfno SEPARATED BY '/'.
    ENDIF.
    watab2-bezei = watab1-bezei.
    watab2-erdat = watab1-erdat.
    watab2-ermon = vmonth.
    watab2-spart = watab1-spart.
    watab2-ihrez = watab1-ihrez.
    watab2-zuonr = watab1-zuonr.
    watab2-kunde = watab1-kunde.
    watab2-kunrg = watab1-kunrg.
    watab2-tkwert = watab1-tkwert.
    watab2-mwsbk = watab1-mwsbk.
    watab3-bezei = watab1-bezei.
    watab3-vtext = watab1-vtext.
    watab3-zuonr = watab1-zuonr.
    watab3-kunde = watab1-kunde.
    watab3-erdat = watab1-erdat.
    watab3-dudat = watab1-dudat.
    watab3-kunrg = watab1-kunrg.
    watab3-name_co = watab1-name_co.
    watab3-stceg = watab1-stceg.
*    WATAB3-VATPR = WATAB1-VATPR.
    CONCATENATE watab1-vatpr(10) watab1-vatpr+11(7) INTO watab3-vatpr.
    watab3-tkwert = watab1-tkwert.
    watab3-mwsbk = watab1-mwsbk.
    watab3-prefx = vtype.
*    MODIFY ITAB1 FROM WATAB1.
    APPEND watab2 TO itab2.
    APPEND watab3 TO itab3.
  ENDLOOP.

ENDFORM.                    " F_SELECTDATA_CN

*&---------------------------------------------------------------------*
*&      Form  F_TAX_CALC
*&---------------------------------------------------------------------*
FORM f_tax_calc  USING    fu_datum fu_wrbtr fu_calty
                 CHANGING fc_wrbtr.
  CALL FUNCTION 'Z_PPN11'
    EXPORTING
      pi_wrbtr = fu_wrbtr
      pi_calty = fu_calty
      pi_datum = fu_datum
    IMPORTING
      po_wrbtr = fc_wrbtr.
ENDFORM.                    " F_TAX_CALC
