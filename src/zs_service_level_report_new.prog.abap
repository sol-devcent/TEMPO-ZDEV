REPORT zs_service_level_report_new MESSAGE-ID zs
*                                  LINE-SIZE 260
                                   LINE-SIZE 567
                                   LINE-COUNT 67
                                   NO STANDARD PAGE HEADING.

INCLUDE zs_service_level_report_newf01.
INCLUDE zs_service_level_report_newtop.
DATA: v_prodh LIKE t179-prodh.
RANGES: r_matkl FOR vbap-matkl.

****************************************************
*        SELECTION-SCREEN                          *
****************************************************
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS      p_vkorg LIKE tvko-vkorg DEFAULT '8020' OBLIGATORY.
SELECT-OPTIONS: s_vkbur FOR vbak-vkbur OBLIGATORY MODIF ID xxx,
                s_erdat FOR vbak-erdat OBLIGATORY,
                s_auart FOR vbak-auart DEFAULT 'ZQ*' OPTION CP
                            NO INTERVALS MODIF ID bud,
*                s_kdgrp FOR vbkd-kdgrp,
                s_kvgr4 FOR knvv-kvgr4 OBLIGATORY,
                s_knkli FOR vbak-knkli,
                s_matkl FOR vbap-matkl,
                s_matnr FOR vbap-matnr,
                s_bstnk FOR vbak-bstnk,
                s_bstdk FOR vbak-bstdk.
*                s_vbeln FOR vbak-vbeln.
PARAMETERS      p_down  AS CHECKBOX MODIF ID dwn.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block3 WITH FRAME TITLE text-003.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_val RADIOBUTTON GROUP grp2
                               DEFAULT 'X' USER-COMMAND grp2.
SELECTION-SCREEN : COMMENT (40) text-010 FOR FIELD p_val.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_qty RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT (40) text-011 FOR FIELD p_qty.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block3.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE text-002.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio1 RADIOBUTTON GROUP grp1
                                  DEFAULT 'X' USER-COMMAND grp1.
SELECTION-SCREEN : COMMENT (20) text-012 FOR FIELD p_radio1.
SELECTION-SCREEN POSITION 56.
PARAMETERS : p_stkout AS CHECKBOX MODIF ID 001.
SELECTION-SCREEN : COMMENT (25) text-013 FOR FIELD p_stkout.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio7 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (44) text-027 FOR FIELD p_radio7.
SELECTION-SCREEN POSITION 56.
PARAMETERS : p_stkou1 AS CHECKBOX MODIF ID 007.
SELECTION-SCREEN : COMMENT (25) text-028 FOR FIELD p_stkou1.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (61) text-016 FOR FIELD p_radio3.
SELECTION-SCREEN POSITION 65.
PARAMETERS : p_total3 AS CHECKBOX MODIF ID 003.
SELECTION-SCREEN : COMMENT (9) text-022 FOR FIELD p_total3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 65.
PARAMETERS : p_total7 AS CHECKBOX MODIF ID 003.
SELECTION-SCREEN : COMMENT (13) text-023 FOR FIELD p_total7.
SELECTION-SCREEN END OF LINE.
** Using Radiobutton
*SELECTION-SCREEN POSITION 65.
*PARAMETERS : p_total3 RADIOBUTTON GROUP grp2 MODIF ID 003.
*SELECTION-SCREEN : COMMENT (20) text-022 FOR FIELD p_total3.
*SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN POSITION 65.
*PARAMETERS : p_total7 RADIOBUTTON GROUP grp2 MODIF ID 003.
*SELECTION-SCREEN : COMMENT (20) text-023 FOR FIELD p_total7.
*SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (45) text-018 FOR FIELD p_radio4.
SELECTION-SCREEN POSITION 65.
PARAMETERS : p_total4 AS CHECKBOX MODIF ID 004.
SELECTION-SCREEN : COMMENT (11) text-021 FOR FIELD p_total4.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (52) text-020 FOR FIELD p_radio5.
SELECTION-SCREEN POSITION 65.
PARAMETERS : p_total5 AS CHECKBOX MODIF ID 005.
SELECTION-SCREEN : COMMENT (11) text-021 FOR FIELD p_total5.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio6 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (49) text-026 FOR FIELD p_radio6.
SELECTION-SCREEN POSITION 65.
PARAMETERS : p_total6 AS CHECKBOX MODIF ID 006.
SELECTION-SCREEN : COMMENT (11) text-021 FOR FIELD p_total6.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (62) text-014 FOR FIELD p_radio2.
SELECTION-SCREEN POSITION 65.
PARAMETERS : p_total2 AS CHECKBOX MODIF ID 002.
SELECTION-SCREEN : COMMENT (11) text-021 FOR FIELD p_total2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block2.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF p_radio2 ='X'.
      CLEAR s_vkbur. REFRESH s_vkbur.
      IF screen-group1 = 'XXX'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF screen-group1 = 'BUD'.
      screen-input = '0'.
    ENDIF.
    IF p_radio1 NE 'X'.
      IF screen-group1 = '001'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF p_radio2 NE 'X'.
      IF screen-group1 = '002'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF p_radio3 NE 'X'.
      IF screen-group1 = '003'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF p_radio4 NE 'X'.
      IF screen-group1 = '004'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF p_radio5 NE 'X'.
      IF screen-group1 = '005'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF p_radio6 NE 'X'.
      IF screen-group1 = '006'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF p_radio7 NE 'X'.
      IF screen-group1 = '007'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF screen-group1 = 'DWN'.
      AUTHORITY-CHECK OBJECT 'ZROFO'
                ID 'ACTVT' FIELD '61'.
      IF sy-subrc = 0.
        screen-active = '1'.
      ELSE.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.


AT SELECTION-SCREEN ON s_matkl.
  REFRESH: r_matkl.
  SELECT prodh INTO v_prodh FROM t179 WHERE  prodh IN s_matkl.
    AUTHORITY-CHECK OBJECT 'ZPRINCIPAL'
        ID 'PRODH' FIELD v_prodh(3).
    IF sy-subrc EQ 0.
      r_matkl-sign  = 'I'.
      r_matkl-option = 'EQ'.
      r_matkl-low = v_prodh.
      APPEND r_matkl.
    ENDIF.
  ENDSELECT.
  IF r_matkl IS INITIAL.
    MESSAGE e002(zz) WITH 'You are not authorized'.
  ENDIF.
  s_auart-low     = 'ZQ9D'.
  s_auart-sign    = 'I'.
  s_auart-option  = 'EQ'.
  APPEND s_auart.

*  SELECT SINGLE * FROM tvkbz
*         WHERE vkbur EQ so_vkbur.


INITIALIZATION.
  CONCATENATE sy-datum(6) '01' INTO s_erdat-low.
  s_erdat-high = sy-datum.
  s_erdat-sign = 'I'.
  s_erdat-option = 'BT'.
  APPEND s_erdat.

*  s_kvgr4-sign = 'I'.
*  s_kvgr4-option = 'NE'.
*  APPEND s_kvgr4.

*****************************************************
*        START-OF-SELECTION                         *
*****************************************************
START-OF-SELECTION.

  IF p_val = 'X'.
    va_text = 'By Value'.
  ELSE.
    va_text = 'By Quantity'.
  ENDIF.
  IF r_matkl IS NOT INITIAL.
    REFRESH: s_matkl.
    s_matkl[] = r_matkl[].
  ELSE.
    MESSAGE a002(zz) WITH 'You are not authorized'.
    STOP.
  ENDIF.

  PERFORM get_data.

* Output Type 1
  IF p_radio1 = 'X'.
    PERFORM proses_data1.
    PERFORM f_clear_alv_data.
    PERFORM f_build_fieldcat1.
    PERFORM f_build_layout      USING d_layout.
    PERFORM f_build_sortfield1  USING sortcat[].
    PERFORM f_build_event1      TABLES evtab[].
    PERFORM f_build_print       USING   d_print.
*    PERFORM f_output_alv        TABLES i_output1.
    IF p_down IS NOT INITIAL.
      PERFORM f_download.
      MESSAGE s000(zab) WITH 'Data already downloaded'.
    ELSE.
      PERFORM write_data1.
    ENDIF.

* Output Type 2
  ELSEIF p_radio2 = 'X'.
    PERFORM proses_data2.
    PERFORM f_clear_alv_data.
    PERFORM f_build_fieldcat2.
    PERFORM f_build_layout      USING d_layout.
    PERFORM f_build_sortfield2  USING sortcat[].
    PERFORM f_build_event2      TABLES evtab[].
    PERFORM f_output_alv        TABLES i_output2.

* Output Type 3
  ELSEIF p_radio3 = 'X'.
    PERFORM proses_data3.
    PERFORM f_clear_alv_data.
    PERFORM f_build_fieldcat3.
    PERFORM f_build_layout      USING d_layout.
    PERFORM f_build_sortfield3  USING sortcat[].
    PERFORM f_build_event3      TABLES evtab[].
    PERFORM f_output_alv        TABLES i_output3.

* Output Type 4
  ELSEIF p_radio4 = 'X'.
    PERFORM proses_data4.
    PERFORM f_clear_alv_data.
    PERFORM f_build_fieldcat4.
    PERFORM f_build_layout      USING d_layout.
    PERFORM f_build_sortfield4  USING sortcat[].
    PERFORM f_build_event4      TABLES evtab[].
    PERFORM f_output_alv        TABLES i_output4.

* Output Type 5
  ELSEIF p_radio5 = 'X'.
    PERFORM proses_data5.
    PERFORM f_clear_alv_data.
    PERFORM f_build_fieldcat5.
    PERFORM f_build_layout      USING d_layout.
    PERFORM f_build_sortfield5  USING sortcat[].
    PERFORM f_build_event5      TABLES evtab[].
    PERFORM f_output_alv        TABLES i_output5.

* Output Type 6
  ELSEIF p_radio6 = 'X'.
    PERFORM proses_data6.
    PERFORM f_clear_alv_data.
    PERFORM f_build_fieldcat6.
    PERFORM f_build_layout      USING d_layout.
    PERFORM f_build_sortfield6  USING sortcat[].
    PERFORM f_build_event6      TABLES evtab[].
    PERFORM f_output_alv        TABLES i_output6.

* Output Type 7
  ELSEIF p_radio7 = 'X'.
    PERFORM proses_data7.
    PERFORM f_clear_alv_data.
    PERFORM f_build_fieldcat7.
    PERFORM f_build_layout      USING d_layout.
    PERFORM f_build_sortfield7  USING sortcat[].
    PERFORM f_build_event7      TABLES evtab[].
    PERFORM f_output_alv        TABLES i_output7.

  ENDIF.

END-OF-SELECTION.

TOP-OF-PAGE.
  PERFORM f_top_of_page1.
  FORMAT COLOR 1.
  PERFORM f_sub_header1.
  FORMAT COLOR OFF.

*&---------------------------------------------------------------------*
*&      Form  Get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data.
  DATA : lt_detquot   LIKE i_detquot OCCURS 0.

  FIELD-SYMBOLS: <fs_abgru> LIKE t_abgru.

  IF p_radio2 ='X'.
    CLEAR s_vkbur. REFRESH s_vkbur.
  ENDIF.

*** Select Reason for rejection
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE t_abgru
    FROM zsd_abgru2
    WHERE vkorg = p_vkorg.
  IF sy-subrc = 0.
    t_abgru-abgru = '99'.
    MODIFY t_abgru TRANSPORTING abgru WHERE abgru = space.
    SORT t_abgru BY abgru.
  ENDIF.

  CLEAR: t_abgru_ori,t_abgru_ori[].
  t_abgru_ori[] = t_abgru[].

  APPEND INITIAL LINE TO t_abgru ASSIGNING <fs_abgru>.
  <fs_abgru>-vkorg = p_vkorg.
  <fs_abgru>-abgru = '98'.
  <fs_abgru>-bezei = 'Other'.
  SORT t_abgru BY abgru.

*** Select Document Quotation ***
  SELECT DISTINCT a~vbeln
    FROM vbak AS a JOIN vbap AS b ON a~vbeln = b~vbeln
                   JOIN knvv AS c ON "a~vkbur = c~vkbur AND
                                     a~vkorg = c~vkorg AND
                                     a~vtweg = c~vtweg AND
                                     a~spart = c~spart AND
                                     a~knkli = c~kunnr
*                   JOIN vbkd AS c ON a~vbeln = c~vbeln
    INTO TABLE i_quot
    WHERE a~kkber = '8000'   AND
          a~vkorg = p_vkorg  AND
          a~vkbur IN s_vkbur AND
          a~auart IN s_auart AND
          a~knkli IN s_knkli AND
*          a~vbeln IN s_vbeln AND
          a~erdat IN s_erdat AND
          a~bstnk IN s_bstnk AND
          a~bstdk IN s_bstdk AND
          b~matkl IN s_matkl AND
          b~matnr IN s_matnr AND
*          c~kdgrp IN s_kdgrp AND
          c~kvgr4 IN s_kvgr4.


  CHECK NOT i_quot[] IS INITIAL.

*** Select Document Sales (SO) ***
  SELECT vbeln FROM vbak INTO TABLE i_sales
    FOR ALL ENTRIES IN i_quot
    WHERE vgbel = i_quot-vbeln.

*** Select Item Quotation ***
  IF p_radio1 = 'X'.
    SELECT a~vkbur a~knkli a~vbeln a~erdat
           a~bstnk a~bstdk
           b~posnr b~matnr b~pstyv b~kwmeng
           b~kzwi1 b~abgru b~matkl b~kdmat
           c~maktx
           d~name1 d~kukla
           e~kvgr4 "e~kdgrp
           f~bsark
      INTO CORRESPONDING FIELDS OF TABLE i_detquot
      FROM vbak AS a JOIN vbap AS b ON a~vbeln = b~vbeln
                     JOIN makt AS c ON b~matnr = c~matnr AND
                                       c~spras = sy-langu
                     JOIN kna1 AS d ON a~knkli = d~kunnr
                     JOIN vbkd AS f ON a~vbeln = f~vbeln
                     JOIN knvv AS e ON "a~vkbur = e~vkbur AND
                                       a~vkorg = e~vkorg AND
                                       a~vtweg = e~vtweg AND
                                       a~spart = e~spart AND
                                       a~knkli = e~kunnr
      FOR ALL ENTRIES IN i_quot
      WHERE a~vbeln = i_quot-vbeln AND
            b~matkl IN s_matkl     AND
            b~matnr IN s_matnr.

    lt_detquot[] = i_detquot[].
    SORT lt_detquot BY vkbur bstnk.
    DELETE ADJACENT DUPLICATES FROM lt_detquot COMPARING vkbur bstnk.
    IF lt_detquot[] IS NOT INITIAL.
      SELECT *
        FROM zsdfixpo
        INTO CORRESPONDING FIELDS OF TABLE gt_fix
        FOR ALL ENTRIES IN lt_detquot
        WHERE vkbur = lt_detquot-vkbur
          AND ebeln = lt_detquot-bstnk.
    ENDIF.

  ELSEIF p_radio2 = 'X'.
    SELECT a~vkbur a~knkli a~vbeln a~erdat
           a~bstnk a~bstdk
           b~posnr b~matnr b~pstyv b~kwmeng
           b~kzwi1 b~abgru b~matkl b~kdmat
           c~maktx
           d~name1
           e~kvgr4 "e~kdgrp
           f~bsark
      INTO CORRESPONDING FIELDS OF TABLE i_detquot2
      FROM vbak AS a JOIN vbap AS b ON a~vbeln = b~vbeln
                     JOIN makt AS c ON b~matnr = c~matnr AND
                                       c~spras = sy-langu
                     JOIN kna1 AS d ON a~knkli = d~kunnr
                     JOIN vbkd AS f ON a~vbeln = f~vbeln
                     JOIN knvv AS e ON "a~vkbur = e~vkbur AND
                                       a~vkorg = e~vkorg AND
                                       a~vtweg = e~vtweg AND
                                       a~spart = e~spart AND
                                       a~knkli = e~kunnr
      FOR ALL ENTRIES IN i_quot
      WHERE a~vbeln = i_quot-vbeln AND
            b~matkl IN s_matkl     AND
            b~matnr IN s_matnr.
    LOOP AT i_detquot2.
      SELECT SINGLE princ INTO i_detquot2-princ
        FROM zsprlsom
        WHERE matkl = i_detquot2-matkl.
      MODIFY i_detquot2 TRANSPORTING princ.
    ENDLOOP.
  ELSEIF p_radio3 = 'X'.
    SELECT a~vkbur a~knkli a~vbeln a~erdat
           a~bstnk a~bstdk
           b~posnr b~matnr b~pstyv b~kwmeng
           b~kzwi1 b~abgru b~matkl b~kdmat
           c~maktx
           d~name1
           e~kvgr4 "e~kdgrp
           f~bsark
      INTO CORRESPONDING FIELDS OF TABLE i_detquot3
      FROM vbak AS a JOIN vbap AS b ON a~vbeln = b~vbeln
                     JOIN makt AS c ON b~matnr = c~matnr AND
                                       c~spras = sy-langu
                     JOIN kna1 AS d ON a~knkli = d~kunnr
                     JOIN vbkd AS f ON a~vbeln = f~vbeln
                     JOIN knvv AS e ON "a~vkbur = e~vkbur AND
                                       a~vkorg = e~vkorg AND
                                       a~vtweg = e~vtweg AND
                                       a~spart = e~spart AND
                                       a~knkli = e~kunnr
      FOR ALL ENTRIES IN i_quot
      WHERE a~vbeln = i_quot-vbeln AND
            b~matkl IN s_matkl     AND
            b~matnr IN s_matnr.
    LOOP AT i_detquot3.
      SELECT SINGLE princ INTO i_detquot3-princ
        FROM zsprlsom
        WHERE matkl = i_detquot3-matkl.
      MODIFY i_detquot3 TRANSPORTING princ.
    ENDLOOP.
  ELSEIF p_radio4 = 'X'.
    SELECT a~vkbur a~knkli a~vbeln a~erdat
           a~bstnk a~bstdk
           b~posnr b~matnr b~pstyv b~kwmeng
           b~kzwi1 b~abgru b~matkl b~kdmat
           c~maktx
           d~name1
           e~kvgr4 "e~kdgrp
           f~bsark
      INTO CORRESPONDING FIELDS OF TABLE i_detquot4
      FROM vbak AS a JOIN vbap AS b ON a~vbeln = b~vbeln
                     JOIN makt AS c ON b~matnr = c~matnr AND
                                       c~spras = sy-langu
                     JOIN kna1 AS d ON a~knkli = d~kunnr
                     JOIN vbkd AS f ON a~vbeln = f~vbeln
                     JOIN knvv AS e ON "a~vkbur = e~vkbur AND
                                       a~vkorg = e~vkorg AND
                                       a~vtweg = e~vtweg AND
                                       a~spart = e~spart AND
                                       a~knkli = e~kunnr
      FOR ALL ENTRIES IN i_quot
      WHERE a~vbeln = i_quot-vbeln AND
            b~matkl IN s_matkl     AND
            b~matnr IN s_matnr.
    LOOP AT i_detquot4.
      SELECT SINGLE princ INTO i_detquot4-princ
        FROM zsprlsom
        WHERE matkl = i_detquot4-matkl.
      MODIFY i_detquot4 TRANSPORTING princ.
    ENDLOOP.
  ELSEIF p_radio5 = 'X'.
    SELECT a~vkbur a~knkli a~vbeln a~erdat
           a~bstnk a~bstdk
           b~posnr b~matnr b~pstyv b~kwmeng
           b~kzwi1 b~abgru b~matkl b~kdmat
           c~maktx
           d~name1
           e~kvgr4 "e~kdgrp
           f~bsark
      INTO CORRESPONDING FIELDS OF TABLE i_detquot5
      FROM vbak AS a JOIN vbap AS b ON a~vbeln = b~vbeln
                     JOIN makt AS c ON b~matnr = c~matnr AND
                                       c~spras = sy-langu
                     JOIN kna1 AS d ON a~knkli = d~kunnr
                     JOIN vbkd AS f ON a~vbeln = f~vbeln
                     JOIN knvv AS e ON "a~vkbur = e~vkbur AND
                                       a~vkorg = e~vkorg AND
                                       a~vtweg = e~vtweg AND
                                       a~spart = e~spart AND
                                       a~knkli = e~kunnr
      FOR ALL ENTRIES IN i_quot
      WHERE a~vbeln = i_quot-vbeln AND
            b~matkl IN s_matkl     AND
            b~matnr IN s_matnr.
  ELSEIF p_radio6 = 'X'.
    SELECT a~vkbur a~knkli a~vbeln a~erdat
           a~bstnk a~bstdk
           b~posnr b~matnr b~pstyv b~kwmeng
           b~kzwi1 b~abgru b~matkl b~kdmat
           c~maktx
           d~name1
           e~kvgr4 "e~kdgrp
           f~bsark
      INTO CORRESPONDING FIELDS OF TABLE i_detquot6
      FROM vbak AS a JOIN vbap AS b ON a~vbeln = b~vbeln
                     JOIN makt AS c ON b~matnr = c~matnr AND
                                       c~spras = sy-langu
                     JOIN kna1 AS d ON a~knkli = d~kunnr
                     JOIN vbkd AS f ON a~vbeln = f~vbeln
                     JOIN knvv AS e ON "a~vkbur = e~vkbur AND
                                       a~vkorg = e~vkorg AND
                                       a~vtweg = e~vtweg AND
                                       a~spart = e~spart AND
                                       a~knkli = e~kunnr
      FOR ALL ENTRIES IN i_quot
      WHERE a~vbeln = i_quot-vbeln AND
            b~matkl IN s_matkl     AND
            b~matnr IN s_matnr.
    LOOP AT i_detquot6.
      SELECT SINGLE princ INTO i_detquot6-princ
        FROM zsprlsom
        WHERE matkl = i_detquot6-matkl.
      MODIFY i_detquot6 TRANSPORTING princ.
    ENDLOOP.
  ELSEIF p_radio7 = 'X'.
    SELECT a~vkbur a~knkli a~vbeln a~erdat
           a~bstnk a~bstdk
           b~posnr b~matnr b~pstyv b~kwmeng
           b~kzwi1 b~abgru b~matkl b~kdmat
           c~maktx
           d~name1
           e~kvgr4 "e~kdgrp
           f~bsark
      INTO CORRESPONDING FIELDS OF TABLE i_detquot7
      FROM vbak AS a JOIN vbap AS b ON a~vbeln = b~vbeln
                     JOIN makt AS c ON b~matnr = c~matnr AND
                                       c~spras = sy-langu
                     JOIN kna1 AS d ON a~knkli = d~kunnr
                     JOIN vbkd AS f ON a~vbeln = f~vbeln
                     JOIN knvv AS e ON "a~vkbur = e~vkbur AND
                                       a~vkorg = e~vkorg AND
                                       a~vtweg = e~vtweg AND
                                       a~spart = e~spart AND
                                       a~knkli = e~kunnr
      FOR ALL ENTRIES IN i_quot
      WHERE a~vbeln = i_quot-vbeln AND
            b~matkl IN s_matkl     AND
            b~matnr IN s_matnr.
    LOOP AT i_detquot7.
      SELECT SINGLE princ INTO i_detquot7-princ
        FROM zsprlsom
        WHERE matkl = i_detquot7-matkl.
      MODIFY i_detquot7 TRANSPORTING princ.
    ENDLOOP.
  ENDIF.

  CHECK NOT i_sales[] IS INITIAL.

*** Select Document Delivery (DO) ***
*  SELECT DISTINCT vbeln FROM lips INTO TABLE i_delv
*    FOR ALL ENTRIES IN i_sales
*    WHERE vgbel = i_sales-vbeln AND
*          matkl IN s_matkl      AND
*          matnr IN s_matnr.
  SELECT DISTINCT vbeln FROM lips INTO TABLE i_delv
    FOR ALL ENTRIES IN i_sales
    WHERE vgbel = i_sales-vbeln.

*** Select Item Sales ***
  SELECT a~vbeln a~erdat a~vgbel
         b~posnr b~matnr b~pstyv b~kwmeng
         b~kzwi1 b~abgru b~vgpos
         c~maktx
    INTO CORRESPONDING FIELDS OF TABLE i_detsales
    FROM vbak AS a JOIN vbap AS b ON a~vbeln = b~vbeln
                   JOIN makt AS c ON b~matnr = c~matnr
    FOR ALL ENTRIES IN i_sales
    WHERE a~vbeln = i_sales-vbeln AND
          b~matkl IN s_matkl      AND
          b~matnr IN s_matnr.


  CHECK NOT i_delv[] IS INITIAL.

*** Select Document Billing ***
*  SELECT vbeln zuonr erdat FROM vbrk INTO TABLE i_bill
*    FOR ALL ENTRIES IN i_delv
*    WHERE zuonr = i_delv-vbeln.

*** Select Item Delivery ***
  SELECT a~vbeln a~wadat_ist a~erdat
         b~posnr b~matnr b~lfimg b~kzwi1
         b~vgbel b~vgpos
         c~maktx
    INTO CORRESPONDING FIELDS OF TABLE i_detdelv
    FROM likp AS a JOIN lips AS b ON a~vbeln = b~vbeln
                   JOIN makt AS c ON b~matnr = c~matnr
    FOR ALL ENTRIES IN i_sales
    WHERE b~vgbel = i_sales-vbeln AND
          b~posnr LT 900000       AND
          b~matkl IN s_matkl      AND
          b~matnr IN s_matnr.

ENDFORM.                    " Get_data

*&---------------------------------------------------------------------*
*&      Form  Proses_data1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proses_data1.

  SORT i_detquot BY vkbur knkli bstnk matnr.
*  SORT i_detsales BY vgbel posnr.
  SORT i_detsales BY vgbel vgpos.
  SORT i_detdelv  BY vgbel vgpos.

  IF NOT p_stkout IS INITIAL.
    PERFORM f_check_stock_outs.
  ENDIF.

  LOOP AT i_detquot.

    CLEAR : i_detsales, i_detdelv, i_output1. ", i_detquot-abgru.

    READ TABLE i_detsales WITH KEY
                               vgbel = i_detquot-vbeln
*                               posnr = i_detquot-posnr BINARY SEARCH.
                               vgpos = i_detquot-posnr." BINARY SEARCH.
    IF sy-subrc = 0.
      IF i_detsales-abgru IS NOT INITIAL.
        i_detquot-abgru = i_detsales-abgru.
      ENDIF.
    ENDIF.

    READ TABLE i_detdelv WITH KEY
                              vgbel = i_detsales-vbeln
                              vgpos = i_detsales-posnr." BINARY SEARCH.

    PERFORM append_itab1.

    IF NOT i_output1-abgru IS INITIAL.
      PERFORM append_reason.
    ENDIF.

* Total PO
    AT END OF bstnk.
      wa_stot3-vkbur = i_output1-vkbur.
      wa_stot3-knkli = i_output1-knkli.
      wa_stot3-name1 = i_output1-name1.
      CONCATENATE '*    Total PO' i_detquot-bstnk
                  INTO wa_stot3-maktx SEPARATED BY space.
      wa_stot3-info = 'C30'.
      wa_stot3-curr = 'IDR'.
      APPEND wa_stot3 TO i_output1.

      wa_stot3-maktx = '           Percentage(%)'.
      IF wa_stot3-kzwi1 NE wa_stot3-btamt.
        IF p_val = 'X'.
          wa_stot3-percen = wa_stot3-dlval / ( wa_stot3-kzwi1 -
                            wa_stot3-btamt ) * 100.
          wa_stot3-unprc  = wa_stot3-unval / ( wa_stot3-kzwi1 -
                            wa_stot3-btamt ) * 100.
          wa_stot3-lead1% = wa_stot3-lead1 / ( wa_stot3-kzwi1 -
                            wa_stot3-btamt ) * 100.
          wa_stot3-lead2% = wa_stot3-lead2 / ( wa_stot3-kzwi1 -
                            wa_stot3-btamt ) * 100.
          wa_stot3-lead3% = wa_stot3-lead3 / ( wa_stot3-kzwi1 -
                            wa_stot3-btamt ) * 100.
          wa_stot3-lead4% = wa_stot3-lead4 / ( wa_stot3-kzwi1 -
                            wa_stot3-btamt ) * 100.
          wa_stot3-lead5% = wa_stot3-lead5 / ( wa_stot3-kzwi1 -
                            wa_stot3-btamt ) * 100.
          wa_stot3-lead6% = wa_stot3-lead6 / ( wa_stot3-kzwi1 -
                            wa_stot3-btamt ) * 100.
          wa_stot3-poout% = wa_stot3-poout / ( wa_stot3-kzwi1 -
                            wa_stot3-btamt ) * 100.
          wa_stot3-btprc% = wa_stot3-btamt / wa_stot3-kzwi1 * 100.
          wa_stot3-stkout% = wa_stot3-stkout / ( wa_stot3-kzwi1 -
                            wa_stot3-btamt ) * 100.
          wa_stot3-cltop% = wa_stot3-cltop / ( wa_stot3-kzwi1 -
                            wa_stot3-btamt ) * 100.
          wa_stot3-salah% = wa_stot3-salah / ( wa_stot3-kzwi1 -
                            wa_stot3-btamt ) * 100.
          wa_stot3-other% = wa_stot3-other / ( wa_stot3-kzwi1 -
                            wa_stot3-btamt ) * 100.

          PERFORM f_hitung_stot3 USING wa_stot3-kzwi1
                                       wa_stot3-btamt
                                       wa_stot3-kwmeng
                                       wa_stot3-btqty
                                       p_val
                                       '1'.

        ELSE.
          wa_stot3-percen = wa_stot3-dlqty / ( wa_stot3-kwmeng -
                            wa_stot3-btqty ) * 100.
          wa_stot3-unprc  = wa_stot3-unqty / ( wa_stot3-kwmeng -
                            wa_stot3-btqty ) * 100.
          wa_stot3-lead1% = wa_stot3-lead1q / ( wa_stot3-kwmeng -
                            wa_stot3-btqty ) * 100.
          wa_stot3-lead2% = wa_stot3-lead2q / ( wa_stot3-kwmeng -
                            wa_stot3-btqty ) * 100.
          wa_stot3-lead3% = wa_stot3-lead3q / ( wa_stot3-kwmeng -
                            wa_stot3-btqty ) * 100.
          wa_stot3-lead4% = wa_stot3-lead4q / ( wa_stot3-kwmeng -
                            wa_stot3-btqty ) * 100.
          wa_stot3-lead5% = wa_stot3-lead5q / ( wa_stot3-kwmeng -
                            wa_stot3-btqty ) * 100.
          wa_stot3-lead6% = wa_stot3-lead6q / ( wa_stot3-kwmeng -
                            wa_stot3-btqty ) * 100.
          wa_stot3-poout% = wa_stot3-poqty / ( wa_stot3-kwmeng -
                            wa_stot3-btqty ) * 100.
          wa_stot3-btprc% = wa_stot3-btqty / wa_stot3-kwmeng * 100.
          wa_stot3-stkout% = wa_stot3-stkoutq / ( wa_stot3-kwmeng -
                            wa_stot3-btqty ) * 100.
          wa_stot3-cltop% = wa_stot3-cltopq / ( wa_stot3-kwmeng -
                            wa_stot3-btqty ) * 100.
          wa_stot3-salah% = wa_stot3-salahq / ( wa_stot3-kwmeng -
                            wa_stot3-btqty ) * 100.
          wa_stot3-other% = wa_stot3-otherq / ( wa_stot3-kwmeng -
                            wa_stot3-btqty ) * 100.

          PERFORM f_hitung_stot3 USING wa_stot3-kzwi1
                                       wa_stot3-btamt
                                       wa_stot3-kwmeng
                                       wa_stot3-btqty
                                       p_val
                                       '1'.

        ENDIF.
      ENDIF.

      IF p_val = 'X'.
        wa_stot3-unval = wa_stot3-unprc.
        wa_stot3-lead1 = wa_stot3-lead1%.
        wa_stot3-lead2 = wa_stot3-lead2%.
        wa_stot3-lead3 = wa_stot3-lead3%.
        wa_stot3-lead4 = wa_stot3-lead4%.
        wa_stot3-lead5 = wa_stot3-lead5%.
        wa_stot3-lead6 = wa_stot3-lead6%.
        wa_stot3-poout = wa_stot3-poout%.
        wa_stot3-btamt = wa_stot3-btprc%.
        wa_stot3-stkout = wa_stot3-stkout%.
        wa_stot3-cltop = wa_stot3-cltop%.
        wa_stot3-salah = wa_stot3-salah%.
        wa_stot3-other = wa_stot3-other%.

        PERFORM f_move_stot3 USING p_val '1'.

      ELSE.
        wa_stot3-unqty = wa_stot3-unprc.
        wa_stot3-lead1q = wa_stot3-lead1%.
        wa_stot3-lead2q = wa_stot3-lead2%.
        wa_stot3-lead3q = wa_stot3-lead3%.
        wa_stot3-lead4q = wa_stot3-lead4%.
        wa_stot3-lead5q = wa_stot3-lead5%.
        wa_stot3-lead6q = wa_stot3-lead6%.
        wa_stot3-poqty = wa_stot3-poout%.
        wa_stot3-btqty = wa_stot3-btprc%.
        wa_stot3-stkoutq = wa_stot3-stkout%.
        wa_stot3-cltopq = wa_stot3-cltop%.
        wa_stot3-salahq = wa_stot3-salah%.
        wa_stot3-otherq = wa_stot3-other%.

        PERFORM f_move_stot3 USING p_val '1'.

      ENDIF.
      wa_stot3-deci = 2.
      CLEAR: wa_stot3-kwmeng, wa_stot3-kzwi1,
              wa_stot3-dlqty, wa_stot3-dlval,
              wa_stot3-curr.
      APPEND wa_stot3 TO i_output1.
      CLEAR: wa_stot3.
    ENDAT.

* Total Customer
    AT END OF knkli.
      wa_stot2-vkbur = i_output1-vkbur.
      wa_stot2-knkli = i_output1-knkli.
      wa_stot2-name1 = i_output1-name1.
      CONCATENATE '**   Total Cust' i_detquot-knkli
                  INTO wa_stot2-maktx SEPARATED BY space.
      wa_stot2-info = 'C31'.
      wa_stot2-curr = 'IDR'.
      wa_stot2-sort1 = 'X'.
      APPEND wa_stot2 TO i_output1.

      wa_stot2-maktx = '           Percentage(%)'.
      IF wa_stot2-kzwi1 NE wa_stot2-btamt.
        IF p_val = 'X'.
          wa_stot2-percen = wa_stot2-dlval / ( wa_stot2-kzwi1 -
                            wa_stot2-btamt ) * 100.
          wa_stot2-unprc = wa_stot2-unval / ( wa_stot2-kzwi1 -
                            wa_stot2-btamt ) * 100.
          wa_stot2-lead1% = wa_stot2-lead1 / ( wa_stot2-kzwi1 -
                            wa_stot2-btamt ) * 100.
          wa_stot2-lead2% = wa_stot2-lead2 / ( wa_stot2-kzwi1 -
                            wa_stot2-btamt ) * 100.
          wa_stot2-lead3% = wa_stot2-lead3 / ( wa_stot2-kzwi1 -
                            wa_stot2-btamt ) * 100.
          wa_stot2-lead4% = wa_stot2-lead4 / ( wa_stot2-kzwi1 -
                            wa_stot2-btamt ) * 100.
          wa_stot2-lead5% = wa_stot2-lead5 / ( wa_stot2-kzwi1 -
                            wa_stot2-btamt ) * 100.
          wa_stot2-lead6% = wa_stot2-lead6 / ( wa_stot2-kzwi1 -
                            wa_stot2-btamt ) * 100.
          wa_stot2-poout% = wa_stot2-poout / ( wa_stot2-kzwi1 -
                            wa_stot2-btamt ) * 100.
          wa_stot2-btprc% = wa_stot2-btamt / wa_stot2-kzwi1 * 100.
          wa_stot2-stkout% = wa_stot2-stkout / ( wa_stot2-kzwi1 -
                            wa_stot2-btamt ) * 100.
          wa_stot2-cltop% = wa_stot2-cltop / ( wa_stot2-kzwi1 -
                            wa_stot2-btamt ) * 100.
          wa_stot2-salah% = wa_stot2-salah / ( wa_stot2-kzwi1 -
                            wa_stot2-btamt ) * 100.
          wa_stot2-other% = wa_stot2-other / ( wa_stot2-kzwi1 -
                            wa_stot2-btamt ) * 100.

          PERFORM f_hitung_stot2 USING wa_stot2-kzwi1
                                       wa_stot2-btamt
                                       wa_stot2-kwmeng
                                       wa_stot2-btqty
                                       p_val
                                       '1'.

        ELSE.
          wa_stot2-percen = wa_stot2-dlqty / ( wa_stot2-kwmeng -
                            wa_stot2-btqty ) * 100.
          wa_stot2-unprc = wa_stot2-unqty / ( wa_stot2-kwmeng -
                            wa_stot2-btqty ) * 100.
          wa_stot2-lead1% = wa_stot2-lead1q / ( wa_stot2-kwmeng -
                            wa_stot2-btqty ) * 100.
          wa_stot2-lead2% = wa_stot2-lead2q / ( wa_stot2-kwmeng -
                            wa_stot2-btqty ) * 100.
          wa_stot2-lead3% = wa_stot2-lead3q / ( wa_stot2-kwmeng -
                            wa_stot2-btqty ) * 100.
          wa_stot2-lead4% = wa_stot2-lead4q / ( wa_stot2-kwmeng -
                            wa_stot2-btqty ) * 100.
          wa_stot2-lead5% = wa_stot2-lead5q / ( wa_stot2-kwmeng -
                            wa_stot2-btqty ) * 100.
          wa_stot2-lead6% = wa_stot2-lead6q / ( wa_stot2-kwmeng -
                            wa_stot2-btqty ) * 100.
          wa_stot2-poout% = wa_stot2-poqty / ( wa_stot2-kwmeng -
                            wa_stot2-btqty ) * 100.
          wa_stot2-btprc% = wa_stot2-btqty / wa_stot2-kwmeng * 100.
          wa_stot2-stkout% = wa_stot2-stkoutq / ( wa_stot2-kwmeng -
                            wa_stot2-btqty ) * 100.
          wa_stot2-cltop% = wa_stot2-cltopq / ( wa_stot2-kwmeng -
                            wa_stot2-btqty ) * 100.
          wa_stot2-salah% = wa_stot2-salahq / ( wa_stot2-kwmeng -
                            wa_stot2-btqty ) * 100.
          wa_stot2-other% = wa_stot2-otherq / ( wa_stot2-kwmeng -
                            wa_stot2-btqty ) * 100.

          PERFORM f_hitung_stot2 USING wa_stot2-kzwi1
                                       wa_stot2-btamt
                                       wa_stot2-kwmeng
                                       wa_stot2-btqty
                                       p_val
                                       '1'.

        ENDIF.
      ENDIF.

      IF p_val = 'X'.
        wa_stot2-unval = wa_stot2-unprc.
        wa_stot2-lead1 = wa_stot2-lead1%.
        wa_stot2-lead2 = wa_stot2-lead2%.
        wa_stot2-lead3 = wa_stot2-lead3%.
        wa_stot2-lead4 = wa_stot2-lead4%.
        wa_stot2-lead5 = wa_stot2-lead5%.
        wa_stot2-lead6 = wa_stot2-lead6%.
        wa_stot2-poout = wa_stot2-poout%.
        wa_stot2-btamt = wa_stot2-btprc%.
        wa_stot2-stkout = wa_stot2-stkout%.
        wa_stot2-cltop = wa_stot2-cltop%.
        wa_stot2-salah = wa_stot2-salah%.
        wa_stot2-other = wa_stot2-other%.

        PERFORM f_move_stot2 USING p_val '1'.

      ELSE.
        wa_stot2-unqty = wa_stot2-unprc.
        wa_stot2-lead1q = wa_stot2-lead1%.
        wa_stot2-lead2q = wa_stot2-lead2%.
        wa_stot2-lead3q = wa_stot2-lead3%.
        wa_stot2-lead4q = wa_stot2-lead4%.
        wa_stot2-lead5q = wa_stot2-lead5%.
        wa_stot2-lead6q = wa_stot2-lead6%.
        wa_stot2-poqty = wa_stot2-poout%.
        wa_stot2-btqty = wa_stot2-btprc%.
        wa_stot2-stkoutq = wa_stot2-stkout%.
        wa_stot2-cltopq = wa_stot2-cltop%.
        wa_stot2-salahq = wa_stot2-salah%.
        wa_stot2-otherq = wa_stot2-other%.

        PERFORM f_move_stot2 USING p_val '1'.

      ENDIF.
      wa_stot2-deci = 2.
      CLEAR: wa_stot2-kwmeng, wa_stot2-kzwi1,
             wa_stot2-dlqty, wa_stot2-dlval,
             wa_stot2-curr.
      APPEND wa_stot2 TO i_output1.
      CLEAR: wa_stot2.
    ENDAT.

* Total Sales Office
    AT END OF vkbur.
      wa_stot1-vkbur = i_output1-vkbur.
      wa_stot1-knkli = i_output1-knkli.
      wa_stot1-name1 = i_output1-name1.
      CONCATENATE '***  Total Sloff' i_detquot-vkbur
                  INTO wa_stot1-maktx SEPARATED BY space.
      wa_stot1-info = 'C70'.
      wa_stot1-curr = 'IDR'.
      wa_stot1-sort1 = 'X'.
      wa_stot1-sort2 = 'X'.
      APPEND wa_stot1 TO i_output1.

      wa_stot1-maktx = '           Percentage(%)'.
      IF wa_stot1-kzwi1 NE wa_stot1-btamt.
        IF p_val = 'X'.
          wa_stot1-percen = wa_stot1-dlval / ( wa_stot1-kzwi1 -
                            wa_stot1-btamt ) * 100.
          wa_stot1-unprc = wa_stot1-unval / ( wa_stot1-kzwi1 -
                            wa_stot1-btamt ) * 100.
          wa_stot1-lead1% = wa_stot1-lead1 / ( wa_stot1-kzwi1 -
                            wa_stot1-btamt ) * 100.
          wa_stot1-lead2% = wa_stot1-lead2 / ( wa_stot1-kzwi1 -
                            wa_stot1-btamt ) * 100.
          wa_stot1-lead3% = wa_stot1-lead3 / ( wa_stot1-kzwi1 -
                            wa_stot1-btamt ) * 100.
          wa_stot1-lead4% = wa_stot1-lead4 / ( wa_stot1-kzwi1 -
                            wa_stot1-btamt ) * 100.
          wa_stot1-lead5% = wa_stot1-lead5 / ( wa_stot1-kzwi1 -
                            wa_stot1-btamt ) * 100.
          wa_stot1-lead6% = wa_stot1-lead6 / ( wa_stot1-kzwi1 -
                            wa_stot1-btamt ) * 100.
          wa_stot1-poout% = wa_stot1-poout / ( wa_stot1-kzwi1 -
                            wa_stot1-btamt ) * 100.
          wa_stot1-btprc% = wa_stot1-btamt / wa_stot1-kzwi1 * 100.
          wa_stot1-stkout% = wa_stot1-stkout / ( wa_stot1-kzwi1 -
                            wa_stot1-btamt ) * 100.
          wa_stot1-cltop% = wa_stot1-cltop / ( wa_stot1-kzwi1 -
                            wa_stot1-btamt ) * 100.
          wa_stot1-salah% = wa_stot1-salah / ( wa_stot1-kzwi1 -
                            wa_stot1-btamt ) * 100.
          wa_stot1-other% = wa_stot1-other / ( wa_stot1-kzwi1 -
                            wa_stot1-btamt ) * 100.

          PERFORM f_hitung_stot1 USING wa_stot1-kzwi1
                                       wa_stot1-btamt
                                       wa_stot1-kwmeng
                                       wa_stot1-btqty
                                       p_val
                                       '1'.

        ELSE.
          wa_stot1-percen = wa_stot1-dlqty / ( wa_stot1-kwmeng -
                            wa_stot1-btqty ) * 100.
          wa_stot1-unprc = wa_stot1-unqty / ( wa_stot1-kwmeng -
                            wa_stot1-btqty ) * 100.
          wa_stot1-lead1% = wa_stot1-lead1q / ( wa_stot1-kwmeng -
                            wa_stot1-btqty ) * 100.
          wa_stot1-lead2% = wa_stot1-lead2q / ( wa_stot1-kwmeng -
                            wa_stot1-btqty ) * 100.
          wa_stot1-lead3% = wa_stot1-lead3q / ( wa_stot1-kwmeng -
                            wa_stot1-btqty ) * 100.
          wa_stot1-lead4% = wa_stot1-lead4q / ( wa_stot1-kwmeng -
                            wa_stot1-btqty ) * 100.
          wa_stot1-lead5% = wa_stot1-lead5q / ( wa_stot1-kwmeng -
                            wa_stot1-btqty ) * 100.
          wa_stot1-lead6% = wa_stot1-lead6q / ( wa_stot1-kwmeng -
                            wa_stot1-btqty ) * 100.
          wa_stot1-poout% = wa_stot1-poqty / ( wa_stot1-kwmeng -
                            wa_stot1-btqty ) * 100.
          wa_stot1-btprc% = wa_stot1-btqty / wa_stot1-kwmeng * 100.
          wa_stot1-stkout% = wa_stot1-stkoutq / ( wa_stot1-kwmeng -
                            wa_stot1-btqty ) * 100.
          wa_stot1-cltop% = wa_stot1-cltopq / ( wa_stot1-kwmeng -
                            wa_stot1-btqty ) * 100.
          wa_stot1-salah% = wa_stot1-salahq / ( wa_stot1-kwmeng -
                            wa_stot1-btqty ) * 100.
          wa_stot1-other% = wa_stot1-otherq / ( wa_stot1-kwmeng -
                            wa_stot1-btqty ) * 100.

          PERFORM f_hitung_stot1 USING wa_stot1-kzwi1
                                       wa_stot1-btamt
                                       wa_stot1-kwmeng
                                       wa_stot1-btqty
                                       p_val
                                       '1'.

        ENDIF.
      ENDIF.

      IF p_val = 'X'.
        wa_stot1-unval = wa_stot1-unprc.
        wa_stot1-lead1 = wa_stot1-lead1%.
        wa_stot1-lead2 = wa_stot1-lead2%.
        wa_stot1-lead3 = wa_stot1-lead3%.
        wa_stot1-lead4 = wa_stot1-lead4%.
        wa_stot1-lead5 = wa_stot1-lead5%.
        wa_stot1-lead6 = wa_stot1-lead6%.
        wa_stot1-poout = wa_stot1-poout%.
        wa_stot1-btamt = wa_stot1-btprc%.
        wa_stot1-stkout = wa_stot1-stkout%.
        wa_stot1-cltop = wa_stot1-cltop%.
        wa_stot1-salah = wa_stot1-salah%.
        wa_stot1-other = wa_stot1-other%.

        PERFORM f_move_stot1 USING p_val '1'.

      ELSE.
        wa_stot1-unqty = wa_stot1-unprc.
        wa_stot1-lead1q = wa_stot1-lead1%.
        wa_stot1-lead2q = wa_stot1-lead2%.
        wa_stot1-lead3q = wa_stot1-lead3%.
        wa_stot1-lead4q = wa_stot1-lead4%.
        wa_stot1-lead5q = wa_stot1-lead5%.
        wa_stot1-lead6q = wa_stot1-lead6%.
        wa_stot1-poqty = wa_stot1-poout%.
        wa_stot1-btqty = wa_stot1-btprc%.
        wa_stot1-stkoutq = wa_stot1-stkout%.
        wa_stot1-cltopq = wa_stot1-cltop%.
        wa_stot1-salahq = wa_stot1-salah%.
        wa_stot1-otherq = wa_stot1-other%.

        PERFORM f_move_stot1 USING p_val '1'.

      ENDIF.
      wa_stot1-deci = 2.
      CLEAR: wa_stot1-kwmeng, wa_stot1-kzwi1,
             wa_stot1-dlqty, wa_stot1-dlval,
             wa_stot1-curr.
      APPEND wa_stot1 TO i_output1.
      CLEAR: wa_stot1.
    ENDAT.

  ENDLOOP.

* Total Grand
  wa_gtot-vkbur = i_output1-vkbur.
  wa_gtot-knkli = i_output1-knkli.
  wa_gtot-maktx = '**** Grand Total'.
  wa_gtot-info = 'C71'.
  wa_gtot-curr = 'IDR'.
  wa_gtot-sort1 = 'X'.
  wa_gtot-sort2 = 'X'.
  wa_gtot-sort3 = 'X'.
  APPEND wa_gtot TO i_output1.

  wa_gtot-maktx = '           Percentage(%)'.
  IF wa_gtot-kzwi1 NE wa_gtot-btamt.
    IF p_val = 'X'.
      wa_gtot-percen = wa_gtot-dlval / ( wa_gtot-kzwi1 -
                            wa_gtot-btamt ) * 100.
      wa_gtot-unprc = wa_gtot-unval / ( wa_gtot-kzwi1 -
                            wa_gtot-btamt ) * 100.
      wa_gtot-lead1% = wa_gtot-lead1 / ( wa_gtot-kzwi1 -
                            wa_gtot-btamt ) * 100.
      wa_gtot-lead2% = wa_gtot-lead2 / ( wa_gtot-kzwi1 -
                            wa_gtot-btamt ) * 100.
      wa_gtot-lead3% = wa_gtot-lead3 / ( wa_gtot-kzwi1 -
                            wa_gtot-btamt ) * 100.
      wa_gtot-lead4% = wa_gtot-lead4 / ( wa_gtot-kzwi1 -
                            wa_gtot-btamt ) * 100.
      wa_gtot-lead5% = wa_gtot-lead5 / ( wa_gtot-kzwi1 -
                            wa_gtot-btamt ) * 100.
      wa_gtot-lead6% = wa_gtot-lead6 / ( wa_gtot-kzwi1 -
                            wa_gtot-btamt ) * 100.
      wa_gtot-poout% = wa_gtot-poout / ( wa_gtot-kzwi1 -
                            wa_gtot-btamt ) * 100.
      wa_gtot-btprc% = wa_gtot-btamt / wa_gtot-kzwi1 * 100.
      wa_gtot-stkout% = wa_gtot-stkout / ( wa_gtot-kzwi1 -
                            wa_gtot-btamt ) * 100.
      wa_gtot-cltop% = wa_gtot-cltop / ( wa_gtot-kzwi1 -
                            wa_gtot-btamt ) * 100.
      wa_gtot-salah% = wa_gtot-salah / ( wa_gtot-kzwi1 -
                            wa_gtot-btamt ) * 100.
      wa_gtot-other% = wa_gtot-other / ( wa_gtot-kzwi1 -
                            wa_gtot-btamt ) * 100.

      PERFORM f_hitung_gtot USING wa_gtot-kzwi1
                                   wa_gtot-btamt
                                   wa_gtot-kwmeng
                                   wa_gtot-btqty
                                   p_val
                                   '1'.

    ELSE.
      wa_gtot-percen = wa_gtot-dlqty / ( wa_gtot-kwmeng -
                            wa_gtot-btqty ) * 100.
      wa_gtot-unprc = wa_gtot-unqty / ( wa_gtot-kwmeng -
                            wa_gtot-btqty ) * 100.
      wa_gtot-lead1% = wa_gtot-lead1q / ( wa_gtot-kwmeng -
                            wa_gtot-btqty ) * 100.
      wa_gtot-lead2% = wa_gtot-lead2q / ( wa_gtot-kwmeng -
                            wa_gtot-btqty ) * 100.
      wa_gtot-lead3% = wa_gtot-lead3q / ( wa_gtot-kwmeng -
                            wa_gtot-btqty ) * 100.
      wa_gtot-lead4% = wa_gtot-lead4q / ( wa_gtot-kwmeng -
                            wa_gtot-btqty ) * 100.
      wa_gtot-lead5% = wa_gtot-lead5q / ( wa_gtot-kwmeng -
                            wa_gtot-btqty ) * 100.
      wa_gtot-lead6% = wa_gtot-lead6q / ( wa_gtot-kwmeng -
                            wa_gtot-btqty ) * 100.
      wa_gtot-poout% = wa_gtot-poqty / ( wa_gtot-kwmeng -
                            wa_gtot-btqty ) * 100.
      wa_gtot-btprc% = wa_gtot-btqty / wa_gtot-kwmeng * 100.
      wa_gtot-stkout% = wa_gtot-stkoutq / ( wa_gtot-kwmeng -
                            wa_gtot-btqty ) * 100.
      wa_gtot-cltop% = wa_gtot-cltopq / ( wa_gtot-kwmeng -
                            wa_gtot-btqty ) * 100.
      wa_gtot-salah% = wa_gtot-salahq / ( wa_gtot-kwmeng -
                            wa_gtot-btqty ) * 100.
      wa_gtot-other% = wa_gtot-otherq / ( wa_gtot-kwmeng -
                            wa_gtot-btqty ) * 100.

      PERFORM f_hitung_gtot USING wa_gtot-kzwi1
                                   wa_gtot-btamt
                                   wa_gtot-kwmeng
                                   wa_gtot-btqty
                                   p_val
                                   '1'.

    ENDIF.
  ENDIF.

  IF p_val = 'X'.
    wa_gtot-unval = wa_gtot-unprc.
    wa_gtot-lead1 = wa_gtot-lead1%.
    wa_gtot-lead2 = wa_gtot-lead2%.
    wa_gtot-lead3 = wa_gtot-lead3%.
    wa_gtot-lead4 = wa_gtot-lead4%.
    wa_gtot-lead5 = wa_gtot-lead5%.
    wa_gtot-lead6 = wa_gtot-lead6%.
    wa_gtot-poout = wa_gtot-poout%.
    wa_gtot-btamt = wa_gtot-btprc%.
    wa_gtot-stkout = wa_gtot-stkout%.
    wa_gtot-cltop = wa_gtot-cltop%.
    wa_gtot-salah = wa_gtot-salah%.
    wa_gtot-other = wa_gtot-other%.

    PERFORM f_move_gtot USING p_val '1'.

  ELSE.
    wa_gtot-unqty = wa_gtot-unprc.
    wa_gtot-lead1q = wa_gtot-lead1%.
    wa_gtot-lead2q = wa_gtot-lead2%.
    wa_gtot-lead3q = wa_gtot-lead3%.
    wa_gtot-lead4q = wa_gtot-lead4%.
    wa_gtot-lead5q = wa_gtot-lead5%.
    wa_gtot-lead6q = wa_gtot-lead6%.
    wa_gtot-poqty = wa_gtot-poout%.
    wa_gtot-btqty = wa_gtot-btprc%.
    wa_gtot-stkoutq = wa_gtot-stkout%.
    wa_gtot-cltopq = wa_gtot-cltop%.
    wa_gtot-salahq = wa_gtot-salah%.
    wa_gtot-otherq = wa_gtot-other%.

    PERFORM f_move_gtot USING p_val '1'.

  ENDIF.
  wa_gtot-deci = 2.
  CLEAR: wa_gtot-kwmeng, wa_gtot-kzwi1,
         wa_gtot-dlqty, wa_gtot-dlval,
         wa_gtot-curr.
  APPEND wa_gtot TO i_output1.

ENDFORM.                    " Proses_data1

*&---------------------------------------------------------------------*
*&      Form  Append_itab1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_itab1.

  DATA : l_qtval  LIKE  vbap-kzwi5,
         l_doval  LIKE  vbap-kzwi5,
         l_leadt  TYPE  i,
         ls_fix   LIKE LINE OF gt_fix.

  MOVE-CORRESPONDING i_detquot TO i_output1.

  CLEAR ls_fix.
  READ TABLE gt_fix INTO ls_fix
                    WITH KEY vkbur = i_output1-vkbur
                             ebeln = i_output1-bstnk.
  IF sy-subrc = 0.
    i_output1-fixpo   = 'Fix PO'.
  ELSE.
    CLEAR i_output1-fixpo.
  ENDIF.

  IF NOT i_detdelv-vbeln IS INITIAL.
    i_output1-dlnum = i_detdelv-vbeln.
    i_output1-dldat = i_detdelv-erdat.
    i_output1-gidat = i_detdelv-wadat_ist.
*    i_output1-dlpos = i_detdelv-posnr.
    i_output1-dlmat = i_detdelv-matnr.
    i_output1-dlqty = i_detsales-kwmeng.
    i_output1-dlval = i_detsales-kzwi1 .
    i_output1-unqty = i_output1-kwmeng - i_output1-dlqty.
    i_output1-unval = i_output1-kzwi1 - i_output1-dlval.

    IF i_output1-unqty LT 0.
      CLEAR: i_output1-unqty,i_output1-unval.
    ENDIF.

    SELECT SINGLE maktx INTO i_output1-dlmatx
      FROM makt WHERE matnr = i_output1-dlmat AND
                      spras = sy-langu.

    SELECT SINGLE crdat FROM zmm_cust_rec
      INTO i_output1-crdat
      WHERE vbeln = i_output1-dlnum.

    IF i_output1-crdat IS INITIAL.
      i_output1-lead6q = i_output1-dlqty.
      i_output1-lead6 = i_output1-dlval.
    ELSE.
      l_leadt = i_output1-crdat - i_output1-bstdk.
      IF l_leadt LE 3.
        i_output1-lead1q = i_output1-dlqty.
        i_output1-lead1 = i_output1-dlval.
      ELSEIF l_leadt = 4.
        i_output1-lead2q = i_output1-dlqty.
        i_output1-lead2 = i_output1-dlval.
      ELSEIF l_leadt GE 5.
        i_output1-lead3q = i_output1-dlqty.
        i_output1-lead3 = i_output1-dlval.
      ENDIF.
    ENDIF.

    IF p_val = 'X'.
      l_qtval = i_output1-kzwi1 * 100.
      l_doval = i_output1-dlval * 100.
      IF l_qtval = 0.
        i_output1-percen = 0.
      ELSE.
        i_output1-percen = l_doval / l_qtval * 100.
      ENDIF.
    ELSE.
      IF i_output1-kwmeng = 0.
        i_output1-percen = 0.
      ELSE.
        i_output1-percen = i_output1-dlqty / i_output1-kwmeng * 100.
      ENDIF.
    ENDIF.

  ELSE.

    IF i_detsales-vbeln IS INITIAL.
      i_output1-unqty = i_output1-kwmeng.
      i_output1-unval = i_output1-kzwi1.
      i_output1-abgru = i_detquot-abgru.
    ELSE.
      IF NOT i_output1-abgru IS INITIAL.
        i_output1-unqty = i_output1-kwmeng.
        i_output1-unval = i_output1-kzwi1.
      ELSE.
        i_output1-poqty = i_output1-kwmeng.
        i_output1-poout = i_output1-kzwi1.
      ENDIF.
    ENDIF.

  ENDIF.

  PERFORM f_reason_for_rejection USING i_output1-abgru
                                       i_output1-unqty
                                       i_output1-unval
                                       '1'.

  SELECT SINGLE bezei FROM tvagt
    INTO i_output1-bezei
    WHERE spras = sy-langu AND
          abgru = i_output1-abgru.

  SELECT SINGLE bezei FROM tvkbt
    INTO i_output1-vkburt
    WHERE spras = sy-langu AND
          vkbur = i_output1-vkbur.

  PERFORM hitung_total1.

  i_output1-curr = 'IDR'.
  APPEND i_output1.

ENDFORM.                    " Append_itab1

*&---------------------------------------------------------------------*
*&      Form  f_build_fieldcat1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_fieldcat1.
  DATA : ls_dyn_fcat    TYPE lvc_s_fcat.
  DATA : ls_fieldcat    TYPE slis_fieldcat_alv.

  DEFINE mac_header.
    read table t_abgru index &1.
    if sy-subrc eq 0.
      if p_val = 'X'.
        fieldcat-fieldname = 'VAL&1'.
        fieldcat-ref_fieldname = ''.
        fieldcat-tabname = 'I_OUTPUT1'.
        fieldcat-outputlen = 15.
        fieldcat-cfieldname = 'CURR'.
        fieldcat-seltext_s = t_abgru-bezei.
        fieldcat-seltext_m = t_abgru-bezei.
        fieldcat-seltext_l = t_abgru-bezei.
        append fieldcat. "clear fieldcat.
      else.
        fieldcat-fieldname = 'QTY&1'.
        fieldcat-ref_fieldname = ''.
        fieldcat-tabname = 'I_OUTPUT1'.
        fieldcat-outputlen = 15.
        fieldcat-decimals_out = '0'.
        fieldcat-seltext_s = t_abgru-bezei.
        fieldcat-seltext_m = t_abgru-bezei.
        fieldcat-seltext_l = t_abgru-bezei.
        append fieldcat. "clear fieldcat.
      endif.
    endif.
  END-OF-DEFINITION.

  fieldcat-fieldname = 'BSTNK'.
  fieldcat-ref_fieldname = 'BSTNK'.
  fieldcat-tabname = 'I_OUTPUT1'.
  fieldcat-outputlen = 20.
  fieldcat-seltext_s = 'PO Number'.
  fieldcat-seltext_m = 'PO Number'.
  fieldcat-seltext_l = 'PO Number'.
  fieldcat-no_sign   = 'X'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'BSTDK'.
  fieldcat-ref_fieldname = 'BSTDK'.
  fieldcat-tabname = 'I_OUTPUT1'.
  fieldcat-outputlen = 8.
  fieldcat-seltext_s = 'PO Date'.
  fieldcat-seltext_m = 'PO Date'.
  fieldcat-seltext_l = 'PO Date'.
*  fieldcat-edit_mask = '__/__/__'.
  APPEND fieldcat. "clear fieldcat.
*  clear fieldcat-edit_mask.

*  fieldcat-fieldname = 'KDMAT'.
*  fieldcat-ref_fieldname = 'KDMAT'.
*  fieldcat-tabname = 'I_OUTPUT1'.
*  fieldcat-outputlen = 10.
*  fieldcat-seltext_s = 'PO Mat Cust'.
*  fieldcat-seltext_m = 'PO Material Cust'.
*  fieldcat-seltext_l = 'PO Material Customer'.
*  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'MATNR'.
  fieldcat-ref_fieldname = 'MATNR'.
  fieldcat-tabname = 'I_OUTPUT1'.
  fieldcat-outputlen = 9.
  fieldcat-seltext_s = 'PO Material'.
  fieldcat-seltext_m = 'PO Material'.
  fieldcat-seltext_l = 'PO Material'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'MAKTX'.
  fieldcat-ref_fieldname = 'MAKTX'.
  fieldcat-tabname = 'I_OUTPUT1'.
  fieldcat-outputlen = 20.
  fieldcat-seltext_s = 'PO Material Descriptions'.
  fieldcat-seltext_m = 'PO Material Descriptions'.
  fieldcat-seltext_l = 'PO Material Descriptions'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'KWMENG'.
  fieldcat-ref_fieldname = 'KWMENG'.
  fieldcat-tabname = 'I_OUTPUT1'.
  fieldcat-outputlen = 8.
  fieldcat-seltext_s = 'PO Qty'.
  fieldcat-seltext_m = 'PO Qty'.
  fieldcat-seltext_l = 'PO Qty'.
  fieldcat-decimals_out = '0'.
  fieldcat-no_zero = 'X'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'KZWI1'.
  fieldcat-ref_fieldname = 'KZWI1'.
  fieldcat-tabname = 'I_OUTPUT1'.
  fieldcat-outputlen = 11.
  fieldcat-seltext_s = 'PO Amount'.
  fieldcat-seltext_m = 'PO Amount'.
  fieldcat-seltext_l = 'PO Amount'.
  fieldcat-currency = 'IDR'.
  fieldcat-decimals_out = '0'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out.

*  IF p_val = 'X'.
*    fieldcat-fieldname = 'BTAMT'.
*    fieldcat-ref_fieldname = 'BTAMT'.
*    fieldcat-tabname = 'I_OUTPUT1'.
*    fieldcat-outputlen = 11.
*    fieldcat-seltext_s = 'PO Batal'.
*    fieldcat-seltext_m = 'PO Batal'.
*    fieldcat-seltext_l = 'PO Batal'.
*    fieldcat-currency = 'IDR'.
*    APPEND fieldcat. "clear fieldcat.
*  ELSE.
*    fieldcat-fieldname = 'BTQTY'.
*    fieldcat-ref_fieldname = 'BTQTY'.
*    fieldcat-tabname = 'I_OUTPUT1'.
*    fieldcat-outputlen = 11.
*    fieldcat-seltext_s = 'PO Batal'.
*    fieldcat-seltext_m = 'PO Batal'.
*    fieldcat-seltext_l = 'PO Batal'.
*    fieldcat-currency = 'IDR'.
*    APPEND fieldcat. "clear fieldcat.
*  ENDIF.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out.

  fieldcat-fieldname = 'DLNUM'.
  fieldcat-ref_fieldname = 'DLNUM'.
  fieldcat-tabname = 'I_OUTPUT1'.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'DO Number'.
  fieldcat-seltext_m = 'DO Number'.
  fieldcat-seltext_l = 'DO Number'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'DLDAT'.
  fieldcat-ref_fieldname = 'DLDAT'.
  fieldcat-tabname = 'I_OUTPUT1'.
  fieldcat-outputlen = 8.
  fieldcat-seltext_s = 'DO Date'.
  fieldcat-seltext_m = 'DO Date'.
  fieldcat-seltext_l = 'DO Date'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'CRDAT'.
  fieldcat-ref_fieldname = 'CRDAT'.
  fieldcat-tabname = 'I_OUTPUT1'.
  fieldcat-outputlen = 8.
  fieldcat-seltext_s = 'Rec Date'.
  fieldcat-seltext_m = 'Received Date'.
  fieldcat-seltext_l = 'Received Date'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'DLMAT'.
  fieldcat-ref_fieldname = 'DLMAT'.
  fieldcat-tabname = 'I_OUTPUT1'.
  fieldcat-outputlen = 9.
  fieldcat-seltext_s = 'DO Material'.
  fieldcat-seltext_m = 'DO Material'.
  fieldcat-seltext_l = 'DO Material'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'DLMATX'.
  fieldcat-ref_fieldname = 'DLMATX'.
  fieldcat-tabname = 'I_OUTPUT1'.
  fieldcat-outputlen = 25.
  fieldcat-seltext_s = 'DO Material Descriptions'.
  fieldcat-seltext_m = 'DO Material Descriptions'.
  fieldcat-seltext_l = 'DO Material Descriptions'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'DLQTY'.
  fieldcat-ref_fieldname = 'DLQTY'.
  fieldcat-tabname = 'I_OUTPUT1'.
  fieldcat-outputlen = 8.
  fieldcat-seltext_s = 'DO Qty'.
  fieldcat-seltext_m = 'DO Qty'.
  fieldcat-seltext_l = 'DO Qty'.
  fieldcat-decimals_out = '0'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'DLVAL'.
  fieldcat-ref_fieldname = 'DLVAL'.
  fieldcat-tabname = 'I_OUTPUT1'.
  fieldcat-outputlen = 11.
  fieldcat-seltext_s = 'DO Amount'.
  fieldcat-seltext_m = 'DO Amount'.
  fieldcat-seltext_l = 'DO Amount'.
  fieldcat-decimals_out = '0'.
  fieldcat-currency = 'IDR'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out.

  fieldcat-fieldname = 'PERCEN'.
  fieldcat-ref_fieldname = 'PERCEN'.
  fieldcat-tabname = 'I_OUTPUT1'.
  fieldcat-outputlen = 6.
  fieldcat-seltext_s = 'Level %'.
  fieldcat-seltext_m = 'Level %'.
  fieldcat-seltext_l = 'Level %'.
  fieldcat-decimals_out = '2'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out.

  IF p_val = 'X'.
    fieldcat-fieldname = 'LEAD6'.
    fieldcat-ref_fieldname = 'LEAD6'.
    fieldcat-tabname = 'I_OUTPUT1'.
    fieldcat-outputlen = 11.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Intransit'.
    fieldcat-seltext_m = 'Intransit'.
    fieldcat-seltext_l = 'Intransit'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD1'.
    fieldcat-ref_fieldname = 'LEAD1'.
    fieldcat-tabname = 'I_OUTPUT1'.
    fieldcat-outputlen = 11.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead <= 3'.
    fieldcat-seltext_m = 'Lead <= 3'.
    fieldcat-seltext_l = 'Lead <= 3'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD2'.
    fieldcat-ref_fieldname = 'LEAD2'.
    fieldcat-tabname = 'I_OUTPUT1'.
    fieldcat-outputlen = 11.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead = 4'.
    fieldcat-seltext_m = 'Lead = 4'.
    fieldcat-seltext_l = 'Lead = 4'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD3'.
    fieldcat-ref_fieldname = 'LEAD3'.
    fieldcat-tabname = 'I_OUTPUT1'.
    fieldcat-outputlen = 11.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead >= 5'.
    fieldcat-seltext_m = 'Lead >= 5'.
    fieldcat-seltext_l = 'Lead >= 5'.
    APPEND fieldcat. "clear fieldcat.
  ELSE.
    fieldcat-fieldname = 'LEAD6Q'.
    fieldcat-ref_fieldname = 'LEAD6Q'.
    fieldcat-tabname = 'I_OUTPUT1'.
    fieldcat-outputlen = 11.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Intransit'.
    fieldcat-seltext_m = 'Intransit'.
    fieldcat-seltext_l = 'Intransit'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD1Q'.
    fieldcat-ref_fieldname = 'LEAD1Q'.
    fieldcat-tabname = 'I_OUTPUT1'.
    fieldcat-outputlen = 11.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead <= 3'.
    fieldcat-seltext_m = 'Lead <= 3'.
    fieldcat-seltext_l = 'Lead <= 3'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD2Q'.
    fieldcat-ref_fieldname = 'LEAD2Q'.
    fieldcat-tabname = 'I_OUTPUT1'.
    fieldcat-outputlen = 11.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead = 4'.
    fieldcat-seltext_m = 'Lead = 4'.
    fieldcat-seltext_l = 'Lead = 4'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD3Q'.
    fieldcat-ref_fieldname = 'LEAD3Q'.
    fieldcat-tabname = 'I_OUTPUT1'.
    fieldcat-outputlen = 11.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead >= 5'.
    fieldcat-seltext_m = 'Lead >= 5'.
    fieldcat-seltext_l = 'Lead >= 5'.
    APPEND fieldcat. "clear fieldcat.
  ENDIF.

*  fieldcat-fieldname = 'LEAD4'.
*  fieldcat-ref_fieldname = 'LEAD4'.
*  fieldcat-tabname = 'I_OUTPUT1'.
*  fieldcat-outputlen = 11.
*  fieldcat-cfieldname = 'CURR'.
*  fieldcat-seltext_s = 'Lead >= 6'.
*  fieldcat-seltext_m = 'Lead >= 6'.
*  fieldcat-seltext_l = 'Lead >= 6'.
*  APPEND fieldcat. "clear fieldcat.

*  fieldcat-fieldname = 'LEAD5'.
*  fieldcat-ref_fieldname = 'LEAD5'.
*  fieldcat-tabname = 'I_OUTPUT1'.
*  fieldcat-outputlen = 11.
*  fieldcat-cfieldname = 'CURR'.
*  fieldcat-seltext_s = 'Lead >= 7'.
*  fieldcat-seltext_m = 'Lead => 7'.
*  fieldcat-seltext_l = 'Lead => 7'.
*  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out.

  IF p_qty = 'X'.
    fieldcat-fieldname = 'UNQTY'.
    fieldcat-ref_fieldname = 'UNQTY'.
    fieldcat-tabname = 'I_OUTPUT1'.
    fieldcat-outputlen = 11.
    fieldcat-seltext_s = 'Undl Qty'.
    fieldcat-seltext_m = 'Undelivered Quantity'.
    fieldcat-seltext_l = 'Undelivered Quantity'.
    fieldcat-decimals_out = '0'.
    APPEND fieldcat. "clear fieldcat.

    CLEAR: fieldcat-currency,
           fieldcat-decimals_out.
  ELSE.
    fieldcat-fieldname = 'UNVAL'.
    fieldcat-ref_fieldname = 'UNVAL'.
    fieldcat-tabname = 'I_OUTPUT1'.
    fieldcat-outputlen = 11.
    fieldcat-seltext_s = 'Undlv Amount'.
    fieldcat-seltext_m = 'Undelivered Amount'.
    fieldcat-seltext_l = 'Undelivered Amount'.
    fieldcat-cfieldname = 'CURR'.
    APPEND fieldcat. "clear fieldcat.

    CLEAR: fieldcat-cfieldname.
  ENDIF.

  mac_header : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.

  fieldcat-fieldname = 'FIXPO'.
  fieldcat-tabname = 'I_OUTPUT1'.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'Status'.
  fieldcat-seltext_m = 'Status'.
  fieldcat-seltext_l = 'Status'.
  APPEND fieldcat. "clear fieldcat.

  LOOP AT fieldcat INTO ls_fieldcat.
    CLEAR ls_dyn_fcat.
    MOVE-CORRESPONDING ls_fieldcat TO ls_dyn_fcat.
    ls_dyn_fcat-coltext = ls_fieldcat-seltext_s.
    APPEND ls_dyn_fcat TO gt_dyn_fcat.
  ENDLOOP.
ENDFORM.                    " f_build_fieldcat1

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE1                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page1.

  DATA : l_line1(70),
         l_line2(60),
         l_sloff(80),
         l_cust(80),
         l_fdate(10),
         l_tdate(10).

  WRITE s_erdat-low TO l_fdate.
  WRITE s_erdat-high TO l_tdate.
*--- Title
  CONCATENATE sy-title 'By Branch, Outlet, PO#' '(01)'
              INTO l_line1 SEPARATED BY space.
*--- Period
  CONCATENATE 'Period :' l_fdate 'to' l_tdate
              INTO l_line2 SEPARATED BY space.
*--- Sales Office
  CONCATENATE 'Sales Office :' i_output1-vkbur i_output1-vkburt
              INTO l_sloff SEPARATED BY space.
*--- Customer
  CONCATENATE 'Customer     :' i_output1-knkli i_output1-name1
              INTO l_cust SEPARATED BY space.

  v_vkbur = i_output1-vkbur.
  v_knkli = i_output1-knkli.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING l_line1.
  PERFORM f_hdr_line2 USING l_sloff l_line2.
  PERFORM f_hdr_line3 USING l_cust va_text.
  PERFORM f_hdr_uline.

ENDFORM.                    "f_top_of_page1

*---------------------------------------------------------------------*
*       FORM F_END_OF_LIST1                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_end_of_list1.

*** For ALV LIST
  DATA: l_totqty LIKE i_reason1-unqty,
        l_totval LIKE i_reason1-unval,
        l_totprc LIKE i_reason1-percen,
        l_totlead TYPE i,
        l_lines   TYPE i.

  DESCRIBE TABLE i_delv LINES l_lines.
  l_totlead = wa_gtot-leadt / l_lines.

  FORMAT COLOR 7.
  SKIP.
  WRITE: /(42) 'Reason' CENTERED,
          (15) 'Quantity' RIGHT-JUSTIFIED,
          (17) 'Value' RIGHT-JUSTIFIED,
           (9) 'Jml Item' CENTERED,
           (9) 'Percen' CENTERED.
  WRITE: /(96) sy-uline.
  FORMAT COLOR OFF.

  SORT i_reason1 BY abgru.
*  LOOP AT i_reason1.
*    i_reason1-percen = i_reason1-count / i_reason1-total * 100.
*    ADD i_reason1-unqty TO l_totqty.
*    ADD i_reason1-unval TO l_totval.
*    ADD i_reason1-percen TO l_totprc.
*    WRITE: /     i_reason1-abgru,
*                 i_reason1-bezei,
*            (15) i_reason1-unqty DECIMALS 2,
*            (17) i_reason1-unval CURRENCY 'IDR',
*             (8) i_reason1-count,
*             (8) i_reason1-percen NO-GAP, '%'.
*  ENDLOOP.

ENDFORM.                    "f_end_of_list1

*---------------------------------------------------------------------*
*       FORM f_build_event1                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_EVENTS                                                     *
*---------------------------------------------------------------------*
FORM f_build_event1 TABLES ft_events LIKE t_events.

  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE1'.
  APPEND ft_events.

  CLEAR ft_events.
  ft_events-name = slis_ev_end_of_list.
  ft_events-form = 'F_END_OF_LIST1'.
  APPEND ft_events.

ENDFORM.                    "f_build_event1

*&---------------------------------------------------------------------*
*&      Form  f_build_sortfield1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      --> FU_SORT
*----------------------------------------------------------------------*
FORM f_build_sortfield1 USING fu_sort TYPE slis_t_sortinfo_alv.

  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'VKBUR'.
  ld_sort-up        = 'X'.
  ld_sort-group     = '*'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'KNKLI'.
  ld_sort-up        = 'X'.
  ld_sort-group     = '*'.
  APPEND ld_sort TO fu_sort.

ENDFORM.                    " f_build_sortfield1

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos = 'X'.
  fu_print-no_print_selinfos  = 'X'.
  fu_print-no_coverpage       = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
  fu_print-reserve_lines      = 3.
ENDFORM.                    "f_build_print

*&---------------------------------------------------------------------*
*&      Form  append_reason
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_reason.

  MOVE-CORRESPONDING i_output1 TO i_reason1.
  COLLECT i_reason1.

ENDFORM.                    " append_reason

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

*&---------------------------------------------------------------------*
*&      Form  f_build_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.

* fu_layout-f2code             = '&ETA'.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-info_fieldname     = 'INFO'.

ENDFORM.                    " f_build_layout

*&---------------------------------------------------------------------*
*&      Form  f_hdr_uline
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hdr_uline.
  IF d_hdr_rpt_lines = 'X'.
    ULINE.
  ENDIF.
ENDFORM.                    " f_hdr_uline

*&---------------------------------------------------------------------*
*&      Form  f_hdr_line1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->fu_company
*----------------------------------------------------------------------*
FORM f_hdr_line1 USING fu_company.
  DATA:
    page_number(10) VALUE 'Page: nnnn',
    progname(42) VALUE 'Program: xx',
    ld_progname(20),
    page(4).

*--- Page number
  page = sy-pagno.
  REPLACE 'nnnn' WITH page INTO page_number.
  IF sy-cprog EQ sy-repid.
    REPLACE 'xx' WITH sy-repid INTO progname.
  ELSE.
    CONCATENATE sy-repid '(' sy-cprog ')' INTO ld_progname.
    REPLACE 'xx' WITH ld_progname INTO progname.
  ENDIF.

*--- Output line
  PERFORM f_hdr_pad_title USING progname fu_company page_number.
ENDFORM.                    " f_hdr_line1

*&---------------------------------------------------------------------*
*&      Form  f_hdr_line2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->fu_title
*----------------------------------------------------------------------*
FORM f_hdr_line2 USING fu_title1 fu_title.
  DATA: ld_sysid(25) VALUE 'XXX(YYY) / ZZZ'.

*--- system info
  REPLACE 'XXX' WITH sy-sysid(3) INTO ld_sysid.
  REPLACE 'YYY' WITH sy-mandt INTO ld_sysid.
*--- user
  REPLACE 'ZZZ' WITH sy-uname INTO ld_sysid.

*--- output line
  PERFORM f_hdr_pad_title USING fu_title1 fu_title ld_sysid.
ENDFORM.                    " F_HDR_LINE2

*&---------------------------------------------------------------------*
*&      Form  f_hdr_line3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->fu_title
*----------------------------------------------------------------------*
FORM f_hdr_line3 USING fu_title fu_title1.
  DATA: ld_datum(20) VALUE 'AA.BB.CCCC / hh:mm'.

*--- date
  REPLACE 'AA' WITH sy-datum+6(2) INTO ld_datum.
  REPLACE 'BB' WITH sy-datum+4(2) INTO ld_datum.
  REPLACE 'CCCC' WITH sy-datum+0(4) INTO ld_datum.
*--- time
  REPLACE 'hh' WITH sy-uzeit(2) INTO ld_datum.     " hour
  REPLACE 'mm' WITH sy-uzeit+2(2) INTO ld_datum.   " minute

  PERFORM f_hdr_pad_title USING fu_title fu_title1 ld_datum.
ENDFORM.                    " f_hdr_line3

*&---------------------------------------------------------------------*
*&      Form  f_hdr_line4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->fu_title
*----------------------------------------------------------------------*
FORM f_hdr_line4 USING fu_title.
*--- output line
  PERFORM f_hdr_pad_title USING '' fu_title ''.
ENDFORM.                    " f_hdr_line4

*&---------------------------------------------------------------------*
*&      Form  f_hdr_pad_title
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      v_left_text v_middle_text v_right_text
*----------------------------------------------------------------------*
FORM f_hdr_pad_title USING v_left_text v_middle_text v_right_text.
  DATA:
      page_width TYPE i,       " Width of page
      middle_length TYPE i,    " Length of title text
      left_length TYPE i,      " Length of left text
      right_length TYPE i,     " Length of right text
      left_start TYPE i,       " Position on line for start of left tex
      middle_start TYPE i,     " Position on line for start of middl tex
      right_start TYPE i.      " Position on line for start of right tex

*--- Start with a blank title
  CLEAR d_hdr_title.
  page_width = sy-linsz - 1.

*--- Compute space on either side of title allowing vertical border
  COMPUTE middle_length = STRLEN( v_middle_text ).
  COMPUTE left_length = STRLEN( v_left_text ).
  COMPUTE right_length = STRLEN( v_right_text ).

  COMPUTE middle_start = ( sy-linsz - middle_length ) / 2.

*--- Allow for vertical lines
  left_start = 0.
  IF d_hdr_rpt_lines = 'X'.
    d_hdr_title(1) = sy-vline.
    d_hdr_title+page_width(1) = sy-vline.
    left_start = 1.
  ENDIF.
  right_start = sy-linsz - left_start - right_length - 1.
  WRITE:/ sy-vline.
*--- Insert texts
  IF left_length <> 0.
*    d_hdr_title+left_start(left_length) = v_left_text.
    WRITE AT (left_length) v_left_text.
  ENDIF.
  IF middle_length <> 0.
    WRITE AT middle_start(middle_length) v_middle_text.
*    d_hdr_title+middle_start(middle_length) = v_middle_text.
  ENDIF.
  IF right_length <> 0.
    WRITE AT right_start(right_length) v_right_text.
*    d_hdr_title+right_start(right_length) = v_right_text.
  ENDIF.
  WRITE AT sy-linsz sy-vline.
ENDFORM.                    " f_hdr_pad_title

*&---------------------------------------------------------------------*
*&      Form  hitung_total1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hitung_total1.

  ADD i_output1-kwmeng TO wa_stot1-kwmeng.
  ADD i_output1-kwmeng TO wa_stot2-kwmeng.
  ADD i_output1-kwmeng TO wa_stot3-kwmeng.
  ADD i_output1-kwmeng TO wa_gtot-kwmeng.
  ADD i_output1-kzwi1 TO wa_stot1-kzwi1.
  ADD i_output1-kzwi1 TO wa_stot2-kzwi1.
  ADD i_output1-kzwi1 TO wa_stot3-kzwi1.
  ADD i_output1-kzwi1 TO wa_gtot-kzwi1.
  ADD i_output1-dlqty TO wa_stot1-dlqty.
  ADD i_output1-dlqty TO wa_stot2-dlqty.
  ADD i_output1-dlqty TO wa_stot3-dlqty.
  ADD i_output1-dlqty TO wa_gtot-dlqty.
  ADD i_output1-dlval TO wa_stot1-dlval.
  ADD i_output1-dlval TO wa_stot2-dlval.
  ADD i_output1-dlval TO wa_stot3-dlval.
  ADD i_output1-dlval TO wa_gtot-dlval.
  ADD i_output1-unqty TO wa_stot1-unqty.
  ADD i_output1-unqty TO wa_stot2-unqty.
  ADD i_output1-unqty TO wa_stot3-unqty.
  ADD i_output1-unqty TO wa_gtot-unqty.
  ADD i_output1-unval TO wa_stot1-unval.
  ADD i_output1-unval TO wa_stot2-unval.
  ADD i_output1-unval TO wa_stot3-unval.
  ADD i_output1-unval TO wa_gtot-unval.
  ADD i_output1-lead1q TO wa_stot1-lead1q.
  ADD i_output1-lead1q TO wa_stot2-lead1q.
  ADD i_output1-lead1q TO wa_stot3-lead1q.
  ADD i_output1-lead1q TO wa_gtot-lead1q.
  ADD i_output1-lead1 TO wa_stot1-lead1.
  ADD i_output1-lead1 TO wa_stot2-lead1.
  ADD i_output1-lead1 TO wa_stot3-lead1.
  ADD i_output1-lead1 TO wa_gtot-lead1.
  ADD i_output1-lead2q TO wa_stot1-lead2q.
  ADD i_output1-lead2q TO wa_stot2-lead2q.
  ADD i_output1-lead2q TO wa_stot3-lead2q.
  ADD i_output1-lead2q TO wa_gtot-lead2q.
  ADD i_output1-lead2 TO wa_stot1-lead2.
  ADD i_output1-lead2 TO wa_stot2-lead2.
  ADD i_output1-lead2 TO wa_stot3-lead2.
  ADD i_output1-lead2 TO wa_gtot-lead2.
  ADD i_output1-lead3q TO wa_stot1-lead3q.
  ADD i_output1-lead3q TO wa_stot2-lead3q.
  ADD i_output1-lead3q TO wa_stot3-lead3q.
  ADD i_output1-lead3q TO wa_gtot-lead3q.
  ADD i_output1-lead3 TO wa_stot1-lead3.
  ADD i_output1-lead3 TO wa_stot2-lead3.
  ADD i_output1-lead3 TO wa_stot3-lead3.
  ADD i_output1-lead3 TO wa_gtot-lead3.
  ADD i_output1-lead4q TO wa_stot1-lead4q.
  ADD i_output1-lead4q TO wa_stot2-lead4q.
  ADD i_output1-lead4q TO wa_stot3-lead4q.
  ADD i_output1-lead4q TO wa_gtot-lead4q.
  ADD i_output1-lead4 TO wa_stot1-lead4.
  ADD i_output1-lead4 TO wa_stot2-lead4.
  ADD i_output1-lead4 TO wa_stot3-lead4.
  ADD i_output1-lead4 TO wa_gtot-lead4.
  ADD i_output1-lead5q TO wa_stot1-lead5q.
  ADD i_output1-lead5q TO wa_stot2-lead5q.
  ADD i_output1-lead5q TO wa_stot3-lead5q.
  ADD i_output1-lead5q TO wa_gtot-lead5q.
  ADD i_output1-lead5 TO wa_stot1-lead5.
  ADD i_output1-lead5 TO wa_stot2-lead5.
  ADD i_output1-lead5 TO wa_stot3-lead5.
  ADD i_output1-lead5 TO wa_gtot-lead5.
  ADD i_output1-lead6q TO wa_stot1-lead6q.
  ADD i_output1-lead6q TO wa_stot2-lead6q.
  ADD i_output1-lead6q TO wa_stot3-lead6q.
  ADD i_output1-lead6q TO wa_gtot-lead6q.
  ADD i_output1-lead6 TO wa_stot1-lead6.
  ADD i_output1-lead6 TO wa_stot2-lead6.
  ADD i_output1-lead6 TO wa_stot3-lead6.
  ADD i_output1-lead6 TO wa_gtot-lead6.
  ADD i_output1-stkoutq TO wa_stot1-stkoutq.
  ADD i_output1-stkoutq TO wa_stot2-stkoutq.
  ADD i_output1-stkoutq TO wa_stot3-stkoutq.
  ADD i_output1-stkoutq TO wa_gtot-stkoutq.
  ADD i_output1-stkout TO wa_stot1-stkout.
  ADD i_output1-stkout TO wa_stot2-stkout.
  ADD i_output1-stkout TO wa_stot3-stkout.
  ADD i_output1-stkout TO wa_gtot-stkout.
  ADD i_output1-cltopq TO wa_stot1-cltopq.
  ADD i_output1-cltopq TO wa_stot2-cltopq.
  ADD i_output1-cltopq TO wa_stot3-cltopq.
  ADD i_output1-cltopq TO wa_gtot-cltopq.
  ADD i_output1-cltop TO wa_stot1-cltop.
  ADD i_output1-cltop TO wa_stot2-cltop.
  ADD i_output1-cltop TO wa_stot3-cltop.
  ADD i_output1-cltop TO wa_gtot-cltop.
  ADD i_output1-salahq TO wa_stot1-salahq.
  ADD i_output1-salahq TO wa_stot2-salahq.
  ADD i_output1-salahq TO wa_stot3-salahq.
  ADD i_output1-salahq TO wa_gtot-salahq.
  ADD i_output1-salah TO wa_stot1-salah.
  ADD i_output1-salah TO wa_stot2-salah.
  ADD i_output1-salah TO wa_stot3-salah.
  ADD i_output1-salah TO wa_gtot-salah.
  ADD i_output1-otherq TO wa_stot1-otherq.
  ADD i_output1-otherq TO wa_stot2-otherq.
  ADD i_output1-otherq TO wa_stot3-otherq.
  ADD i_output1-otherq TO wa_gtot-otherq.
  ADD i_output1-other TO wa_stot1-other.
  ADD i_output1-other TO wa_stot2-other.
  ADD i_output1-other TO wa_stot3-other.
  ADD i_output1-other TO wa_gtot-other.
  ADD i_output1-poqty TO wa_stot1-poqty.
  ADD i_output1-poqty TO wa_stot2-poqty.
  ADD i_output1-poqty TO wa_stot3-poqty.
  ADD i_output1-poqty TO wa_gtot-poqty.
  ADD i_output1-poout TO wa_stot1-poout.
  ADD i_output1-poout TO wa_stot2-poout.
  ADD i_output1-poout TO wa_stot3-poout.
  ADD i_output1-poout TO wa_gtot-poout.
  ADD i_output1-btqty TO wa_stot1-btqty.
  ADD i_output1-btqty TO wa_stot2-btqty.
  ADD i_output1-btqty TO wa_stot3-btqty.
  ADD i_output1-btqty TO wa_gtot-btqty.
  ADD i_output1-btamt TO wa_stot1-btamt.
  ADD i_output1-btamt TO wa_stot2-btamt.
  ADD i_output1-btamt TO wa_stot3-btamt.
  ADD i_output1-btamt TO wa_gtot-btamt.

  PERFORM f_hitung_total USING '1'.

ENDFORM.                    " hitung_total1

*&---------------------------------------------------------------------*
*&      Form  f_output_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_output_alv TABLES ft_table.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = 'ZS_SERVICE_LEVEL_REPORT_NEW'
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = e_user_command
*      i_background_id          = 'ALV_BACKGROUND'
      is_variant               = disvariant
      is_layout                = d_layout
      it_fieldcat              = fieldcat[]
      it_events                = evtab[]
      is_print                 = d_print
      it_sort                  = sortcat[]
      i_save                   = 'A'
    IMPORTING
      e_exit_caused_by_caller  = g_exit_caused_by_caller
      es_exit_caused_by_user   = gs_exit_caused_by_user
    TABLES
      t_outtab                 = ft_table
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

ENDFORM.                    " f_output_alv

*&---------------------------------------------------------------------*
*&      Form  proses_data2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proses_data2.

  SORT i_detquot2  BY kvgr4 princ matkl matnr vbeln posnr.
*  SORT i_detsales BY vgbel posnr.
  SORT i_detsales BY vgbel vgpos.
  SORT i_detdelv  BY vgbel vgpos.
  LOOP AT i_detquot2.

    CLEAR : i_detsales, i_detdelv, i_output2. ", i_detquot2-abgru.

    READ TABLE i_detsales WITH KEY
                               vgbel = i_detquot2-vbeln
*                               posnr = i_detquot2-posnr BINARY SEARCH.
                               vgpos = i_detquot2-posnr. " BINARY SEARCH.
    IF sy-subrc = 0.
      IF i_detsales-abgru IS NOT INITIAL.
        i_detquot2-abgru = i_detsales-abgru.
      ENDIF.
    ENDIF.

    READ TABLE i_detdelv WITH KEY
                              vgbel = i_detsales-vbeln
                              vgpos = i_detsales-posnr. " BINARY SEARCH.

    PERFORM append_itab2.

* Total Material Group
    AT END OF matkl.
      wa_stot23-kvgr4 = i_output2-kvgr4.
      wa_stot23-bezei = i_output2-bezei.
      CONCATENATE '*    Total' i_output2-matkl
                  INTO wa_stot23-maktx SEPARATED BY space.
      wa_stot23-info = 'C30'.
      wa_stot23-curr = 'IDR'.
      wa_stot23-index = '20'.
      wa_stot23-deci = '0'.
      wa_stot23-matkx = i_output2-matkl.
      wa_stot23-prinx = i_output2-princ.
      APPEND wa_stot23 TO i_output2.

      wa_stot23-maktx = '          Percentage(%)'.
      IF wa_stot23-kzwi1 NE wa_stot23-btamt.
        IF p_val = 'X'.
          wa_stot23-dlval% = wa_stot23-dlval / ( wa_stot23-kzwi1 -
                             wa_stot23-btamt ) * 100.
          wa_stot23-unprc = wa_stot23-unval / ( wa_stot23-kzwi1 -
                            wa_stot23-btamt ) * 100.
          wa_stot23-lead1% = wa_stot23-lead1 / ( wa_stot23-kzwi1 -
                             wa_stot23-btamt ) * 100.
          wa_stot23-lead2% = wa_stot23-lead2 / ( wa_stot23-kzwi1 -
                             wa_stot23-btamt ) * 100.
          wa_stot23-lead3% = wa_stot23-lead3 / ( wa_stot23-kzwi1 -
                             wa_stot23-btamt ) * 100.
          wa_stot23-lead4% = wa_stot23-lead4 / ( wa_stot23-kzwi1 -
                             wa_stot23-btamt ) * 100.
          wa_stot23-lead5% = wa_stot23-lead5 / ( wa_stot23-kzwi1 -
                             wa_stot23-btamt ) * 100.
          wa_stot23-lead6% = wa_stot23-lead6 / ( wa_stot23-kzwi1 -
                             wa_stot23-btamt ) * 100.
          wa_stot23-poout% = wa_stot23-poout / ( wa_stot23-kzwi1 -
                             wa_stot23-btamt ) * 100.
          wa_stot23-btprc% = wa_stot23-btamt / wa_stot23-kzwi1 * 100.
          wa_stot23-stkout% = wa_stot23-stkout / ( wa_stot23-kzwi1 -
                             wa_stot23-btamt ) * 100.
          wa_stot23-cltop% = wa_stot23-cltop / ( wa_stot23-kzwi1 -
                             wa_stot23-btamt ) * 100.
          wa_stot23-salah% = wa_stot23-salah / ( wa_stot23-kzwi1 -
                             wa_stot23-btamt ) * 100.
          wa_stot23-other% = wa_stot23-other / ( wa_stot23-kzwi1 -
                             wa_stot23-btamt ) * 100.
          wa_stot23-reject% = wa_stot23-reject / ( wa_stot23-kzwi1 -
                             wa_stot23-btamt ) * 100.

          PERFORM f_hitung_stot3 USING wa_stot23-kzwi1
                                       wa_stot23-btamt
                                       wa_stot23-kwmeng
                                       wa_stot23-btqty
                                       p_val
                                       '2'.

        ELSE.
          wa_stot23-dlval% = wa_stot23-dlqty / ( wa_stot23-kwmeng -
                             wa_stot23-btqty ) * 100.
          wa_stot23-unprc = wa_stot23-unqty / ( wa_stot23-kwmeng -
                            wa_stot23-btqty ) * 100.
          wa_stot23-lead1% = wa_stot23-lead1q / ( wa_stot23-kwmeng -
                             wa_stot23-btqty ) * 100.
          wa_stot23-lead2% = wa_stot23-lead2q / ( wa_stot23-kwmeng -
                             wa_stot23-btqty ) * 100.
          wa_stot23-lead3% = wa_stot23-lead3q / ( wa_stot23-kwmeng -
                             wa_stot23-btqty ) * 100.
          wa_stot23-lead4% = wa_stot23-lead4q / ( wa_stot23-kwmeng -
                             wa_stot23-btqty ) * 100.
          wa_stot23-lead5% = wa_stot23-lead5q / ( wa_stot23-kwmeng -
                             wa_stot23-btqty ) * 100.
          wa_stot23-lead6% = wa_stot23-lead6q / ( wa_stot23-kwmeng -
                             wa_stot23-btqty ) * 100.
          wa_stot23-poout% = wa_stot23-pooutq / ( wa_stot23-kwmeng -
                             wa_stot23-btqty ) * 100.
          wa_stot23-btprc% = wa_stot23-btqty / wa_stot23-kwmeng * 100.
          wa_stot23-stkout% = wa_stot23-stkoutq / ( wa_stot23-kwmeng -
                             wa_stot23-btqty ) * 100.
          wa_stot23-cltop% = wa_stot23-cltopq / ( wa_stot23-kwmeng -
                             wa_stot23-btqty ) * 100.
          wa_stot23-salah% = wa_stot23-salahq / ( wa_stot23-kwmeng -
                             wa_stot23-btqty ) * 100.
          wa_stot23-other% = wa_stot23-otherq / ( wa_stot23-kwmeng -
                             wa_stot23-btqty ) * 100.
          wa_stot23-reject% = wa_stot23-rejectq / ( wa_stot23-kwmeng -
                             wa_stot23-btqty ) * 100.

          PERFORM f_hitung_stot3 USING wa_stot23-kzwi1
                                       wa_stot23-btamt
                                       wa_stot23-kwmeng
                                       wa_stot23-btqty
                                       p_val
                                       '2'.

        ENDIF.
      ENDIF.

      wa_stot23-dlval = wa_stot23-dlval%.
      IF p_val = 'X'.
        wa_stot23-unval = wa_stot23-unprc.
        wa_stot23-lead1 = wa_stot23-lead1%.
        wa_stot23-lead2 = wa_stot23-lead2%.
        wa_stot23-lead3 = wa_stot23-lead3%.
        wa_stot23-lead4 = wa_stot23-lead4%.
        wa_stot23-lead5 = wa_stot23-lead5%.
        wa_stot23-lead6 = wa_stot23-lead6%.
        wa_stot23-poout = wa_stot23-poout%.
        wa_stot23-btamt = wa_stot23-btprc%.
        wa_stot23-stkout = wa_stot23-stkout%.
        wa_stot23-cltop = wa_stot23-cltop%.
        wa_stot23-salah = wa_stot23-salah%.
        wa_stot23-other = wa_stot23-other%.
        wa_stot23-reject = wa_stot23-reject%.

        PERFORM f_move_stot3 USING p_val '2'.

      ELSE.
        wa_stot23-unqty = wa_stot23-unprc.
        wa_stot23-lead1q = wa_stot23-lead1%.
        wa_stot23-lead2q = wa_stot23-lead2%.
        wa_stot23-lead3q = wa_stot23-lead3%.
        wa_stot23-lead4q = wa_stot23-lead4%.
        wa_stot23-lead5q = wa_stot23-lead5%.
        wa_stot23-lead6q = wa_stot23-lead6%.
        wa_stot23-pooutq = wa_stot23-poout%.
        wa_stot23-btqty = wa_stot23-btprc%.
        wa_stot23-stkoutq = wa_stot23-stkout%.
        wa_stot23-cltopq = wa_stot23-cltop%.
        wa_stot23-salahq = wa_stot23-salah%.
        wa_stot23-otherq = wa_stot23-other%.
        wa_stot23-rejectq = wa_stot23-reject%.

        PERFORM f_move_stot3 USING p_val '2'.

      ENDIF.
      wa_stot23-deci = '2'.
      CLEAR: wa_stot23-curr, wa_stot23-kwmeng,
             wa_stot23-kzwi1, wa_stot23-dlqty.
      APPEND wa_stot23 TO i_output2.
      CLEAR: wa_stot23.
    ENDAT.

* Total Principal
    AT END OF princ.
      wa_stot22-kvgr4 = i_output2-kvgr4.
      wa_stot22-bezei = i_output2-bezei.
      CONCATENATE '**   Total' i_output2-princ
                  INTO wa_stot22-maktx SEPARATED BY space.
      wa_stot22-info = 'C30'.
      wa_stot22-curr = 'IDR'.
      wa_stot22-index = '30'.
      wa_stot22-deci = '0'.
      wa_stot22-matkx = i_output2-matkl.
      wa_stot22-prinx = i_output2-princ.
      APPEND wa_stot22 TO i_output2.

      wa_stot22-maktx = '          Percentage(%)'.
      IF wa_stot22-kzwi1 NE wa_stot22-btamt.
        IF p_val = 'X'.
          wa_stot22-dlval% = wa_stot22-dlval / ( wa_stot22-kzwi1 -
                             wa_stot22-btamt ) * 100.
          wa_stot22-unprc = wa_stot22-unval / ( wa_stot22-kzwi1 -
                            wa_stot22-btamt ) * 100.
          wa_stot22-lead1% = wa_stot22-lead1 / ( wa_stot22-kzwi1 -
                            wa_stot22-btamt ) * 100.
          wa_stot22-lead2% = wa_stot22-lead2 / ( wa_stot22-kzwi1 -
                            wa_stot22-btamt ) * 100.
          wa_stot22-lead3% = wa_stot22-lead3 / ( wa_stot22-kzwi1 -
                            wa_stot22-btamt ) * 100.
          wa_stot22-lead4% = wa_stot22-lead4 / ( wa_stot22-kzwi1 -
                            wa_stot22-btamt ) * 100.
          wa_stot22-lead5% = wa_stot22-lead5 / ( wa_stot22-kzwi1 -
                            wa_stot22-btamt ) * 100.
          wa_stot22-lead6% = wa_stot22-lead6 / ( wa_stot22-kzwi1 -
                            wa_stot22-btamt ) * 100.
          wa_stot22-poout% = wa_stot22-poout / ( wa_stot22-kzwi1 -
                            wa_stot22-btamt ) * 100.
          wa_stot22-btprc% = wa_stot22-btamt / wa_stot22-kzwi1 * 100.
          wa_stot22-stkout% = wa_stot22-stkout / ( wa_stot22-kzwi1 -
                            wa_stot22-btamt ) * 100.
          wa_stot22-cltop% = wa_stot22-cltop / ( wa_stot22-kzwi1 -
                            wa_stot22-btamt ) * 100.
          wa_stot22-salah% = wa_stot22-salah / ( wa_stot22-kzwi1 -
                            wa_stot22-btamt ) * 100.
          wa_stot22-other% = wa_stot22-other / ( wa_stot22-kzwi1 -
                            wa_stot22-btamt ) * 100.
          wa_stot22-reject% = wa_stot22-reject / ( wa_stot22-kzwi1 -
                            wa_stot22-btamt ) * 100.

          PERFORM f_hitung_stot2 USING wa_stot22-kzwi1
                                       wa_stot22-btamt
                                       wa_stot22-kwmeng
                                       wa_stot22-btqty
                                       p_val
                                       '2'.

        ELSE.
          wa_stot22-dlval% = wa_stot22-dlqty / ( wa_stot22-kwmeng -
                             wa_stot22-btqty ) * 100.
          wa_stot22-unprc = wa_stot22-unqty / ( wa_stot22-kwmeng -
                            wa_stot22-btqty ) * 100.
          wa_stot22-lead1% = wa_stot22-lead1q / ( wa_stot22-kwmeng -
                            wa_stot22-btqty ) * 100.
          wa_stot22-lead2% = wa_stot22-lead2q / ( wa_stot22-kwmeng -
                            wa_stot22-btqty ) * 100.
          wa_stot22-lead3% = wa_stot22-lead3q / ( wa_stot22-kwmeng -
                            wa_stot22-btqty ) * 100.
          wa_stot22-lead4% = wa_stot22-lead4q / ( wa_stot22-kwmeng -
                            wa_stot22-btqty ) * 100.
          wa_stot22-lead5% = wa_stot22-lead5q / ( wa_stot22-kwmeng -
                            wa_stot22-btqty ) * 100.
          wa_stot22-lead6% = wa_stot22-lead6q / ( wa_stot22-kwmeng -
                            wa_stot22-btqty ) * 100.
          wa_stot22-poout% = wa_stot22-pooutq / ( wa_stot22-kwmeng -
                            wa_stot22-btqty ) * 100.
          wa_stot22-btprc% = wa_stot22-btqty / wa_stot22-kwmeng * 100.
          wa_stot22-stkout% = wa_stot22-stkoutq / ( wa_stot22-kwmeng -
                            wa_stot22-btqty ) * 100.
          wa_stot22-cltop% = wa_stot22-cltopq / ( wa_stot22-kwmeng -
                            wa_stot22-btqty ) * 100.
          wa_stot22-salah% = wa_stot22-salahq / ( wa_stot22-kwmeng -
                            wa_stot22-btqty ) * 100.
          wa_stot22-other% = wa_stot22-otherq / ( wa_stot22-kwmeng -
                            wa_stot22-btqty ) * 100.
          wa_stot22-reject% = wa_stot22-rejectq / ( wa_stot22-kwmeng -
                            wa_stot22-btqty ) * 100.

          PERFORM f_hitung_stot2 USING wa_stot22-kzwi1
                                       wa_stot22-btamt
                                       wa_stot22-kwmeng
                                       wa_stot22-btqty
                                       p_val
                                       '2'.

        ENDIF.
      ENDIF.

      wa_stot22-dlval = wa_stot22-dlval%.
      IF p_val = 'X'.
        wa_stot22-unval = wa_stot22-unprc.
        wa_stot22-lead1 = wa_stot22-lead1%.
        wa_stot22-lead2 = wa_stot22-lead2%.
        wa_stot22-lead3 = wa_stot22-lead3%.
        wa_stot22-lead4 = wa_stot22-lead4%.
        wa_stot22-lead5 = wa_stot22-lead5%.
        wa_stot22-lead6 = wa_stot22-lead6%.
        wa_stot22-poout = wa_stot22-poout%.
        wa_stot22-btamt = wa_stot22-btprc%.
        wa_stot22-stkout = wa_stot22-stkout%.
        wa_stot22-cltop = wa_stot22-cltop%.
        wa_stot22-salah = wa_stot22-salah%.
        wa_stot22-other = wa_stot22-other%.
        wa_stot22-reject = wa_stot22-reject%.

        PERFORM f_move_stot2 USING p_val '2'.

      ELSE.
        wa_stot22-unqty = wa_stot22-unprc.
        wa_stot22-lead1q = wa_stot22-lead1%.
        wa_stot22-lead2q = wa_stot22-lead2%.
        wa_stot22-lead3q = wa_stot22-lead3%.
        wa_stot22-lead4q = wa_stot22-lead4%.
        wa_stot22-lead5q = wa_stot22-lead5%.
        wa_stot22-lead6q = wa_stot22-lead6%.
        wa_stot22-pooutq = wa_stot22-poout%.
        wa_stot22-btqty = wa_stot22-btprc%.
        wa_stot22-stkoutq = wa_stot22-stkout%.
        wa_stot22-cltopq = wa_stot22-cltop%.
        wa_stot22-salahq = wa_stot22-salah%.
        wa_stot22-otherq = wa_stot22-other%.
        wa_stot22-rejectq = wa_stot22-reject%.

        PERFORM f_move_stot2 USING p_val '2'.

      ENDIF.
      wa_stot22-deci = '2'.
      CLEAR: wa_stot22-curr, wa_stot22-kwmeng,
             wa_stot22-kzwi1, wa_stot22-dlqty.
      APPEND wa_stot22 TO i_output2.
      CLEAR: wa_stot22, wa_stot23.
    ENDAT.

* Total Customer Group
    AT END OF kvgr4.
      wa_stot21-kvgr4 = i_output2-kvgr4.
      wa_stot21-bezei = i_output2-bezei.
      CONCATENATE '***  Total' i_output2-kvgr4 i_output2-bezei
                  INTO wa_stot21-maktx SEPARATED BY space.
      wa_stot21-info = 'C31'.
      wa_stot21-curr = 'IDR'.
      wa_stot21-index = '40'.
      wa_stot21-deci = '0'.
      wa_stot21-matkx = i_output2-matkl.
      wa_stot21-prinx = i_output2-princ.
      APPEND wa_stot21 TO i_output2.

      wa_stot21-maktx = '          Percentage(%)'.
      IF wa_stot21-kzwi1 NE wa_stot21-btamt.
        IF p_val = 'X'.
          wa_stot21-dlval% = wa_stot21-dlval / ( wa_stot21-kzwi1 -
                             wa_stot21-btamt ) * 100.
          wa_stot21-unprc = wa_stot21-unval / ( wa_stot21-kzwi1 -
                            wa_stot21-btamt ) * 100.
          wa_stot21-lead1% = wa_stot21-lead1 / ( wa_stot21-kzwi1 -
                             wa_stot21-btamt ) * 100.
          wa_stot21-lead2% = wa_stot21-lead2 / ( wa_stot21-kzwi1 -
                             wa_stot21-btamt ) * 100.
          wa_stot21-lead3% = wa_stot21-lead3 / ( wa_stot21-kzwi1 -
                             wa_stot21-btamt ) * 100.
          wa_stot21-lead4% = wa_stot21-lead4 / ( wa_stot21-kzwi1 -
                             wa_stot21-btamt ) * 100.
          wa_stot21-lead5% = wa_stot21-lead5 / ( wa_stot21-kzwi1 -
                             wa_stot21-btamt ) * 100.
          wa_stot21-lead6% = wa_stot21-lead6 / ( wa_stot21-kzwi1 -
                             wa_stot21-btamt ) * 100.
          wa_stot21-poout% = wa_stot21-poout / ( wa_stot21-kzwi1 -
                             wa_stot21-btamt ) * 100.
          wa_stot21-btprc% = wa_stot21-btamt / wa_stot21-kzwi1 * 100.
          wa_stot21-stkout% = wa_stot21-stkout / ( wa_stot21-kzwi1 -
                             wa_stot21-btamt ) * 100.
          wa_stot21-cltop% = wa_stot21-cltop / ( wa_stot21-kzwi1 -
                            wa_stot21-btamt ) * 100.
          wa_stot21-salah% = wa_stot21-salah / ( wa_stot21-kzwi1 -
                            wa_stot21-btamt ) * 100.
          wa_stot21-other% = wa_stot21-other / ( wa_stot21-kzwi1 -
                            wa_stot21-btamt ) * 100.
          wa_stot21-reject% = wa_stot21-reject / ( wa_stot21-kzwi1 -
                             wa_stot21-btamt ) * 100.

          PERFORM f_hitung_stot1 USING wa_stot21-kzwi1
                                       wa_stot21-btamt
                                       wa_stot21-kwmeng
                                       wa_stot21-btqty
                                       p_val
                                       '2'.

        ELSE.
          wa_stot21-dlval% = wa_stot21-dlqty / ( wa_stot21-kwmeng -
                             wa_stot21-btqty ) * 100.
          wa_stot21-unprc = wa_stot21-unqty / ( wa_stot21-kwmeng -
                            wa_stot21-btqty ) * 100.
          wa_stot21-lead1% = wa_stot21-lead1q / ( wa_stot21-kwmeng -
                             wa_stot21-btqty ) * 100.
          wa_stot21-lead2% = wa_stot21-lead2q / ( wa_stot21-kwmeng -
                             wa_stot21-btqty ) * 100.
          wa_stot21-lead3% = wa_stot21-lead3q / ( wa_stot21-kwmeng -
                             wa_stot21-btqty ) * 100.
          wa_stot21-lead4% = wa_stot21-lead4q / ( wa_stot21-kwmeng -
                             wa_stot21-btqty ) * 100.
          wa_stot21-lead5% = wa_stot21-lead5q / ( wa_stot21-kwmeng -
                             wa_stot21-btqty ) * 100.
          wa_stot21-lead6% = wa_stot21-lead6q / ( wa_stot21-kwmeng -
                             wa_stot21-btqty ) * 100.
          wa_stot21-poout% = wa_stot21-pooutq / ( wa_stot21-kwmeng -
                             wa_stot21-btqty ) * 100.
          wa_stot21-btprc% = wa_stot21-btqty / wa_stot21-kwmeng * 100.
          wa_stot21-stkout% = wa_stot21-stkoutq / ( wa_stot21-kwmeng -
                             wa_stot21-btqty ) * 100.
          wa_stot21-cltop% = wa_stot21-cltopq / ( wa_stot21-kwmeng -
                            wa_stot21-btqty ) * 100.
          wa_stot21-salah% = wa_stot21-salahq / ( wa_stot21-kwmeng -
                            wa_stot21-btqty ) * 100.
          wa_stot21-other% = wa_stot21-otherq / ( wa_stot21-kwmeng -
                            wa_stot21-btqty ) * 100.
          wa_stot21-reject% = wa_stot21-rejectq / ( wa_stot21-kwmeng -
                             wa_stot21-btqty ) * 100.

          PERFORM f_hitung_stot1 USING wa_stot21-kzwi1
                                       wa_stot21-btamt
                                       wa_stot21-kwmeng
                                       wa_stot21-btqty
                                       p_val
                                       '2'.

        ENDIF.
      ENDIF.

      wa_stot21-dlval = wa_stot21-dlval%.
      IF p_val = 'X'.
        wa_stot21-unval = wa_stot21-unprc.
        wa_stot21-lead1 = wa_stot21-lead1%.
        wa_stot21-lead2 = wa_stot21-lead2%.
        wa_stot21-lead3 = wa_stot21-lead3%.
        wa_stot21-lead4 = wa_stot21-lead4%.
        wa_stot21-lead5 = wa_stot21-lead5%.
        wa_stot21-lead6 = wa_stot21-lead6%.
        wa_stot21-poout = wa_stot21-poout%.
        wa_stot21-btamt = wa_stot21-btprc%.
        wa_stot21-stkout = wa_stot21-stkout%.
        wa_stot21-cltop = wa_stot21-cltop%.
        wa_stot21-salah = wa_stot21-salah%.
        wa_stot21-other = wa_stot21-other%.
        wa_stot21-reject = wa_stot21-reject%.

        PERFORM f_move_stot1 USING p_val '2'.

      ELSE.
        wa_stot21-unqty = wa_stot21-unprc.
        wa_stot21-lead1q = wa_stot21-lead1%.
        wa_stot21-lead2q = wa_stot21-lead2%.
        wa_stot21-lead3q = wa_stot21-lead3%.
        wa_stot21-lead4q = wa_stot21-lead4%.
        wa_stot21-lead5q = wa_stot21-lead5%.
        wa_stot21-lead6q = wa_stot21-lead6%.
        wa_stot21-pooutq = wa_stot21-poout%.
        wa_stot21-btqty = wa_stot21-btprc%.
        wa_stot21-stkoutq = wa_stot21-stkout%.
        wa_stot21-cltopq = wa_stot21-cltop%.
        wa_stot21-salahq = wa_stot21-salah%.
        wa_stot21-otherq = wa_stot21-other%.
        wa_stot21-rejectq = wa_stot21-reject%.

        PERFORM f_move_stot1 USING p_val '2'.

      ENDIF.
      wa_stot21-deci = '2'.
      CLEAR: wa_stot21-curr, wa_stot21-kwmeng,
             wa_stot21-kzwi1, wa_stot21-dlqty.
      APPEND wa_stot21 TO i_output2.
      CLEAR: wa_stot21, wa_stot22.
    ENDAT.

  ENDLOOP.

* Total Grand
  wa_gtot2-kvgr4 = i_output2-kvgr4.
  wa_gtot2-bezei = i_output2-bezei.
  wa_gtot2-maktx = '**** Grand Total'.
  wa_gtot2-info = 'C71'.
  wa_gtot2-curr = 'IDR'.
  wa_gtot2-index = '50'.
  wa_gtot2-deci = '0'.
  wa_gtot2-matkx = i_output2-matkl.
  wa_gtot2-prinx = i_output2-princ.
  APPEND wa_gtot2 TO i_output2.

  wa_gtot2-maktx = '          Percentage(%)'.
  IF wa_gtot2-kzwi1 NE wa_gtot2-btamt.
    IF p_val = 'X'.
      wa_gtot2-dlval% = wa_gtot2-dlval / ( wa_gtot2-kzwi1 -
                        wa_gtot2-btamt ) * 100.
      wa_gtot2-unprc = wa_gtot2-unval / ( wa_gtot2-kzwi1 -
                       wa_gtot2-btamt ) * 100.
      wa_gtot2-lead1% = wa_gtot2-lead1 / ( wa_gtot2-kzwi1 -
                        wa_gtot2-btamt ) * 100.
      wa_gtot2-lead2% = wa_gtot2-lead2 / ( wa_gtot2-kzwi1 -
                        wa_gtot2-btamt ) * 100.
      wa_gtot2-lead3% = wa_gtot2-lead3 / ( wa_gtot2-kzwi1 -
                        wa_gtot2-btamt ) * 100.
      wa_gtot2-lead4% = wa_gtot2-lead4 / ( wa_gtot2-kzwi1 -
                        wa_gtot2-btamt ) * 100.
      wa_gtot2-lead5% = wa_gtot2-lead5 / ( wa_gtot2-kzwi1 -
                        wa_gtot2-btamt ) * 100.
      wa_gtot2-lead6% = wa_gtot2-lead6 / ( wa_gtot2-kzwi1 -
                        wa_gtot2-btamt ) * 100.
      wa_gtot2-poout% = wa_gtot2-poout / ( wa_gtot2-kzwi1 -
                        wa_gtot2-btamt ) * 100.
      wa_gtot2-btprc% = wa_gtot2-btamt / wa_gtot2-kzwi1 * 100.
      wa_gtot2-stkout% = wa_gtot2-stkout / ( wa_gtot2-kzwi1 -
                        wa_gtot2-btamt ) * 100.
      wa_gtot2-cltop% = wa_gtot2-cltop / ( wa_gtot2-kzwi1 -
                        wa_gtot2-btamt ) * 100.
      wa_gtot2-salah% = wa_gtot2-salah / ( wa_gtot2-kzwi1 -
                        wa_gtot2-btamt ) * 100.
      wa_gtot2-other% = wa_gtot2-other / ( wa_gtot2-kzwi1 -
                        wa_gtot2-btamt ) * 100.
      wa_gtot2-reject% = wa_gtot2-reject / ( wa_gtot2-kzwi1 -
                        wa_gtot2-btamt ) * 100.

      PERFORM f_hitung_gtot USING wa_gtot2-kzwi1
                                   wa_gtot2-btamt
                                   wa_gtot2-kwmeng
                                   wa_gtot2-btqty
                                   p_val
                                   '2'.

    ELSE.
      wa_gtot2-dlval% = wa_gtot2-dlqty / ( wa_gtot2-kwmeng -
                        wa_gtot2-btqty ) * 100.
      wa_gtot2-unprc = wa_gtot2-unqty / ( wa_gtot2-kwmeng -
                       wa_gtot2-btqty ) * 100.
      wa_gtot2-lead1% = wa_gtot2-lead1q / ( wa_gtot2-kwmeng -
                        wa_gtot2-btqty ) * 100.
      wa_gtot2-lead2% = wa_gtot2-lead2q / ( wa_gtot2-kwmeng -
                        wa_gtot2-btqty ) * 100.
      wa_gtot2-lead3% = wa_gtot2-lead3q / ( wa_gtot2-kwmeng -
                        wa_gtot2-btqty ) * 100.
      wa_gtot2-lead4% = wa_gtot2-lead4q / ( wa_gtot2-kwmeng -
                        wa_gtot2-btqty ) * 100.
      wa_gtot2-lead5% = wa_gtot2-lead5q / ( wa_gtot2-kwmeng -
                        wa_gtot2-btqty ) * 100.
      wa_gtot2-lead6% = wa_gtot2-lead6q / ( wa_gtot2-kwmeng -
                        wa_gtot2-btqty ) * 100.
      wa_gtot2-poout% = wa_gtot2-pooutq / ( wa_gtot2-kwmeng -
                        wa_gtot2-btqty ) * 100.
      wa_gtot2-btprc% = wa_gtot2-btqty / wa_gtot2-kwmeng * 100.
      wa_gtot2-stkout% = wa_gtot2-stkoutq / ( wa_gtot2-kwmeng -
                        wa_gtot2-btqty ) * 100.
      wa_gtot2-cltop% = wa_gtot2-cltopq / ( wa_gtot2-kwmeng -
                        wa_gtot2-btqty ) * 100.
      wa_gtot2-salah% = wa_gtot2-salahq / ( wa_gtot2-kwmeng -
                        wa_gtot2-btqty ) * 100.
      wa_gtot2-other% = wa_gtot2-otherq / ( wa_gtot2-kwmeng -
                        wa_gtot2-btqty ) * 100.
      wa_gtot2-reject% = wa_gtot2-rejectq / ( wa_gtot2-kwmeng -
                        wa_gtot2-btqty ) * 100.

      PERFORM f_hitung_gtot USING wa_gtot2-kzwi1
                                   wa_gtot2-btamt
                                   wa_gtot2-kwmeng
                                   wa_gtot2-btqty
                                   p_val
                                   '2'.

    ENDIF.
  ENDIF.

  wa_gtot2-dlval = wa_gtot2-dlval%.
  IF p_val = 'X'.
    wa_gtot2-unval = wa_gtot2-unprc.
    wa_gtot2-lead1 = wa_gtot2-lead1%.
    wa_gtot2-lead2 = wa_gtot2-lead2%.
    wa_gtot2-lead3 = wa_gtot2-lead3%.
    wa_gtot2-lead4 = wa_gtot2-lead4%.
    wa_gtot2-lead5 = wa_gtot2-lead5%.
    wa_gtot2-lead6 = wa_gtot2-lead6%.
    wa_gtot2-poout = wa_gtot2-poout%.
    wa_gtot2-btamt = wa_gtot2-btprc%.
    wa_gtot2-stkout = wa_gtot2-stkout%.
    wa_gtot2-cltop = wa_gtot2-cltop%.
    wa_gtot2-salah = wa_gtot2-salah%.
    wa_gtot2-other = wa_gtot2-other%.
    wa_gtot2-reject = wa_gtot2-reject%.

    PERFORM f_move_gtot USING p_val '2'.

  ELSE.
    wa_gtot2-unqty = wa_gtot2-unprc.
    wa_gtot2-lead1q = wa_gtot2-lead1%.
    wa_gtot2-lead2q = wa_gtot2-lead2%.
    wa_gtot2-lead3q = wa_gtot2-lead3%.
    wa_gtot2-lead4q = wa_gtot2-lead4%.
    wa_gtot2-lead5q = wa_gtot2-lead5%.
    wa_gtot2-lead6q = wa_gtot2-lead6%.
    wa_gtot2-pooutq = wa_gtot2-poout%.
    wa_gtot2-btqty = wa_gtot2-btprc%.
    wa_gtot2-stkoutq = wa_gtot2-stkout%.
    wa_gtot2-cltopq = wa_gtot2-cltop%.
    wa_gtot2-salahq = wa_gtot2-salah%.
    wa_gtot2-otherq = wa_gtot2-other%.
    wa_gtot2-rejectq = wa_gtot2-reject%.

    PERFORM f_move_gtot USING p_val '2'.

  ENDIF.
  wa_gtot2-deci = '2'.
  CLEAR: wa_gtot2-curr, wa_gtot2-kwmeng,
         wa_gtot2-kzwi1, wa_gtot2-dlqty.
  APPEND wa_gtot2 TO i_output2.
  CLEAR: wa_gtot2, wa_stot21, wa_stot22.

  IF p_total2 = 'X'.
    DELETE i_output2 WHERE index LT '40'.
  ENDIF.

ENDFORM.                    " proses_data2

*&---------------------------------------------------------------------*
*&      Form  append_itab2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_itab2.

  DATA : l_crdat  LIKE  zmm_cust_rec-crdat,
         l_leadt  TYPE  i.

  MOVE-CORRESPONDING i_detquot2 TO i_output2.

  IF NOT i_detdelv-vbeln IS INITIAL.
    i_output2-dlqty = i_detsales-kwmeng.
    i_output2-dlval = i_detsales-kzwi1.
    i_output2-unqty = i_output2-kwmeng - i_output2-dlqty.
    i_output2-unval = i_output2-kzwi1 - i_output2-dlval.

    IF i_output2-unqty LT 0.
      CLEAR: i_output2-unqty,i_output2-unval.
    ENDIF.

    SELECT SINGLE crdat FROM zmm_cust_rec
      INTO l_crdat
      WHERE vbeln = i_detdelv-vbeln.

    IF l_crdat IS INITIAL.
      i_output2-lead6q = i_output2-dlqty.
      i_output2-lead6 = i_output2-dlval.
    ELSE.
      l_leadt = l_crdat - i_detquot2-bstdk.
      IF l_leadt LE 3.
        i_output2-lead1q = i_output2-dlqty.
        i_output2-lead1 = i_output2-dlval.
      ELSEIF l_leadt = 4.
        i_output2-lead2q = i_output2-dlqty.
        i_output2-lead2 = i_output2-dlval.
      ELSEIF l_leadt GE 5.
        i_output2-lead3q = i_output2-dlqty.
        i_output2-lead3 = i_output2-dlval.
*      ELSEIF l_leadt GE 6.
*        i_output2-lead4 = i_output2-dlval.
*      ELSEIF l_leadt GE 7.
*        i_output2-lead5 = i_output2-dlval.
      ENDIF.
    ENDIF.
  ELSE.
    IF i_detsales-vbeln IS INITIAL.
      i_output2-unqty = i_output2-kwmeng.
      i_output2-unval = i_output2-kzwi1.
    ELSE.
      IF NOT i_detquot2-abgru IS INITIAL.
        i_output2-unqty = i_output2-kwmeng.
        i_output2-unval = i_output2-kzwi1.
      ELSE.
        i_output2-pooutq = i_output2-kwmeng.
        i_output2-poout = i_output2-kzwi1.
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM f_reason_for_rejection USING i_detquot2-abgru
                                       i_output2-unqty
                                       i_output2-unval
                                       '2'.

  i_output2-reject = i_output2-unval - i_output2-stkout.

  SELECT SINGLE bezei INTO i_output2-bezei
    FROM tvv4t
    WHERE spras = sy-langu AND
          kvgr4 = i_output2-kvgr4.

  PERFORM hitung_total2.

  i_output2-curr = 'IDR'.
  i_output2-index = '10'.
  i_output2-deci = '0'.
  i_output2-matkx = i_output2-matkl.
  i_output2-prinx = i_output2-princ.

  COLLECT i_output2.

ENDFORM.                    " append_itab2

*&---------------------------------------------------------------------*
*&      Form  f_build_fieldcat2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_fieldcat2.
  DEFINE mac_header2.
    read table t_abgru index &1.
    if sy-subrc eq 0.
      if p_val = 'X'.
        fieldcat-fieldname = 'VAL&1'.
        fieldcat-ref_fieldname = ''.
        fieldcat-tabname = 'I_OUTPUT2'.
        fieldcat-outputlen = 15.
        fieldcat-cfieldname = 'CURR'.
        fieldcat-seltext_s = t_abgru-bezei.
        fieldcat-seltext_m = t_abgru-bezei.
        fieldcat-seltext_l = t_abgru-bezei.
        append fieldcat. "clear fieldcat.
      else.
        fieldcat-fieldname = 'QTY&1'.
        fieldcat-ref_fieldname = ''.
        fieldcat-tabname = 'I_OUTPUT2'.
        fieldcat-outputlen = 15.
        fieldcat-decimalsfieldname = 'DECI'.
        fieldcat-seltext_s = t_abgru-bezei.
        fieldcat-seltext_m = t_abgru-bezei.
        fieldcat-seltext_l = t_abgru-bezei.
        append fieldcat. "clear fieldcat.
      endif.
    endif.
  END-OF-DEFINITION.

  fieldcat-fieldname = 'PRINC'.
  fieldcat-ref_fieldname = 'PRINC'.
  fieldcat-tabname = 'I_OUTPUT2'.
  fieldcat-outputlen = 6.
  fieldcat-seltext_s = 'Princp'.
  fieldcat-seltext_m = 'Principal'.
  fieldcat-seltext_l = 'Principal'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'MATKL'.
  fieldcat-ref_fieldname = 'MATKL'.
  fieldcat-tabname = 'I_OUTPUT2'.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'Mat Group'.
  fieldcat-seltext_m = 'Material Group'.
  fieldcat-seltext_l = 'Material Group'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'MATNR'.
  fieldcat-ref_fieldname = 'MATNR'.
  fieldcat-tabname = 'I_OUTPUT2'.
  fieldcat-outputlen = 11.
  fieldcat-seltext_s = 'Material'.
  fieldcat-seltext_m = 'Material'.
  fieldcat-seltext_l = 'Material'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'MAKTX'.
  fieldcat-ref_fieldname = 'MAKTX'.
  fieldcat-tabname = 'I_OUTPUT2'.
  fieldcat-outputlen = 25.
  fieldcat-seltext_s = 'Material Desc'.
  fieldcat-seltext_m = 'Material Desc'.
  fieldcat-seltext_l = 'Material Descriptions'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'KWMENG'.
  fieldcat-ref_fieldname = 'KWMENG'.
  fieldcat-tabname = 'I_OUTPUT2'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'PO Qty'.
  fieldcat-seltext_m = 'PO Quantity'.
  fieldcat-seltext_l = 'PO Quantity'.
  fieldcat-decimals_out = '0'.
  fieldcat-no_zero = 'X'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'KZWI1'.
  fieldcat-ref_fieldname = 'KZWI1'.
  fieldcat-tabname = 'I_OUTPUT2'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'PO Amount'.
  fieldcat-seltext_m = 'PO Amount'.
  fieldcat-seltext_l = 'PO Amount'.
  fieldcat-currency = 'IDR'.
  fieldcat-decimals_out = '0'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out.

*  IF p_val = 'X'.
*    fieldcat-fieldname = 'BTAMT'.
*    fieldcat-ref_fieldname = 'BTAMT'.
*    fieldcat-tabname = 'I_OUTPUT2'.
*    fieldcat-outputlen = 13.
*    fieldcat-seltext_s = 'PO Batal'.
*    fieldcat-seltext_m = 'PO Batal'.
*    fieldcat-seltext_l = 'PO Batal'.
*    fieldcat-cfieldname = 'CURR'.
*    APPEND fieldcat. "clear fieldcat.
*  ELSE.
*    fieldcat-fieldname = 'BTQTY'.
*    fieldcat-ref_fieldname = 'BTQTY'.
*    fieldcat-tabname = 'I_OUTPUT2'.
*    fieldcat-outputlen = 13.
*    fieldcat-seltext_s = 'PO Batal'.
*    fieldcat-seltext_m = 'PO Batal'.
*    fieldcat-seltext_l = 'PO Batal'.
*    fieldcat-decimalsfieldname = 'DECI'.
*    APPEND fieldcat. "clear fieldcat.
*  ENDIF.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname,
         fieldcat-decimalsfieldname.

  fieldcat-fieldname = 'DLQTY'.
  fieldcat-ref_fieldname = 'DLQTY'.
  fieldcat-tabname = 'I_OUTPUT2'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'DO Qty'.
  fieldcat-seltext_m = 'DO Quantity'.
  fieldcat-seltext_l = 'DO Quantity'.
  fieldcat-decimals_out = '0'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname.

  fieldcat-fieldname = 'DLVAL'.
  fieldcat-ref_fieldname = 'DLVAL'.
  fieldcat-tabname = 'I_OUTPUT2'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'DO Amount'.
  fieldcat-seltext_m = 'DO Amount'.
  fieldcat-seltext_l = 'DO Amount'.
  fieldcat-cfieldname = 'CURR'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname.

  IF p_val = 'X'.
    fieldcat-fieldname = 'LEAD6'.
    fieldcat-ref_fieldname = 'LEAD6'.
    fieldcat-tabname = 'I_OUTPUT2'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Intransit'.
    fieldcat-seltext_m = 'Intransit'.
    fieldcat-seltext_l = 'Intransit'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD1'.
    fieldcat-ref_fieldname = 'LEAD1'.
    fieldcat-tabname = 'I_OUTPUT2'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead <= 3'.
    fieldcat-seltext_m = 'Lead <= 3'.
    fieldcat-seltext_l = 'Lead <= 3'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD2'.
    fieldcat-ref_fieldname = 'LEAD2'.
    fieldcat-tabname = 'I_OUTPUT2'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead = 4'.
    fieldcat-seltext_m = 'Lead = 4'.
    fieldcat-seltext_l = 'Lead = 4'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD3'.
    fieldcat-ref_fieldname = 'LEAD3'.
    fieldcat-tabname = 'I_OUTPUT2'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead >= 5'.
    fieldcat-seltext_m = 'Lead >= 5'.
    fieldcat-seltext_l = 'Lead >= 5'.
    APPEND fieldcat. "clear fieldcat.
  ELSE.
    fieldcat-fieldname = 'LEAD6Q'.
    fieldcat-ref_fieldname = 'LEAD6Q'.
    fieldcat-tabname = 'I_OUTPUT2'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Intransit'.
    fieldcat-seltext_m = 'Intransit'.
    fieldcat-seltext_l = 'Intransit'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD1Q'.
    fieldcat-ref_fieldname = 'LEAD1Q'.
    fieldcat-tabname = 'I_OUTPUT2'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead <= 3'.
    fieldcat-seltext_m = 'Lead <= 3'.
    fieldcat-seltext_l = 'Lead <= 3'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD2Q'.
    fieldcat-ref_fieldname = 'LEAD2Q'.
    fieldcat-tabname = 'I_OUTPUT2'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead = 4'.
    fieldcat-seltext_m = 'Lead = 4'.
    fieldcat-seltext_l = 'Lead = 4'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD3Q'.
    fieldcat-ref_fieldname = 'LEAD3Q'.
    fieldcat-tabname = 'I_OUTPUT2'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead >= 5'.
    fieldcat-seltext_m = 'Lead >= 5'.
    fieldcat-seltext_l = 'Lead >= 5'.
    APPEND fieldcat. "clear fieldcat.
  ENDIF.

*  fieldcat-fieldname = 'LEAD4'.
*  fieldcat-ref_fieldname = 'LEAD4'.
*  fieldcat-tabname = 'I_OUTPUT2'.
*  fieldcat-outputlen = 13.
*  fieldcat-cfieldname = 'CURR'.
*  fieldcat-seltext_s = 'Lead >= 6'.
*  fieldcat-seltext_m = 'Lead >= 6'.
*  fieldcat-seltext_l = 'Lead >= 6'.
*  APPEND fieldcat. "clear fieldcat.

*  fieldcat-fieldname = 'LEAD5'.
*  fieldcat-ref_fieldname = 'LEAD5'.
*  fieldcat-tabname = 'I_OUTPUT2'.
*  fieldcat-outputlen = 13.
*  fieldcat-cfieldname = 'CURR'.
*  fieldcat-seltext_s = 'Lead >= 7'.
*  fieldcat-seltext_m = 'Lead => 7'.
*  fieldcat-seltext_l = 'Lead => 7'.
*  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname,
         fieldcat-decimalsfieldname.

  IF p_val = 'X'.
    fieldcat-fieldname = 'UNVAL'.
    fieldcat-ref_fieldname = 'UNVAL'.
    fieldcat-tabname = 'I_OUTPUT2'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Undlv Amount'.
    fieldcat-seltext_m = 'Undelivered Amount'.
    fieldcat-seltext_l = 'Undelivered Amount'.
    APPEND fieldcat. "clear fieldcat.

*    fieldcat-fieldname = 'CLTOP'.
*    fieldcat-ref_fieldname = 'CLTOP'.
*    fieldcat-tabname = 'I_OUTPUT2'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'CL / TOP'.
*    fieldcat-seltext_m = 'CL / TOP'.
*    fieldcat-seltext_l = 'CL / TOP'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'STKOUT'.
*    fieldcat-ref_fieldname = 'STKOUT'.
*    fieldcat-tabname = 'I_OUTPUT2'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Stock Out'.
*    fieldcat-seltext_m = 'Stock Out'.
*    fieldcat-seltext_l = 'Stock Out'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'SALAH'.
*    fieldcat-ref_fieldname = 'SALAH'.
*    fieldcat-tabname = 'I_OUTPUT2'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Salah Harga'.
*    fieldcat-seltext_m = 'Salah Harga'.
*    fieldcat-seltext_l = 'Salah Harga'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'OTHER'.
*    fieldcat-ref_fieldname = 'OTHER'.
*    fieldcat-tabname = 'I_OUTPUT2'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Other'.
*    fieldcat-seltext_m = 'Other'.
*    fieldcat-seltext_l = 'Other'.
*    APPEND fieldcat. "clear fieldcat.
*
**  fieldcat-fieldname = 'REJECT'.
**  fieldcat-ref_fieldname = 'REJECT'.
**  fieldcat-tabname = 'I_OUTPUT2'.
**  fieldcat-outputlen = 11.
**  fieldcat-cfieldname = 'CURR'.
**  fieldcat-seltext_s = 'CL / TOP '.
**  fieldcat-seltext_m = 'CL / TOP '.
**  fieldcat-seltext_l = 'CL / TOP '.
**  APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'POOUT'.
*    fieldcat-ref_fieldname = 'POOUT'.
*    fieldcat-tabname = 'I_OUTPUT2'.
*    fieldcat-outputlen = 13.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'PO Outs'.
*    fieldcat-seltext_m = 'PO Outstanding'.
*    fieldcat-seltext_l = 'PO Outstanding'.
*    APPEND fieldcat. "clear fieldcat.
  ELSE.
    fieldcat-fieldname = 'UNQTY'.
    fieldcat-ref_fieldname = 'UNQTY'.
    fieldcat-tabname = 'I_OUTPUT2'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Undlv Qty'.
    fieldcat-seltext_m = 'Undelivered Quantity'.
    fieldcat-seltext_l = 'Undelivered Quantity'.
    APPEND fieldcat. "clear fieldcat.

*    fieldcat-fieldname = 'CLTOPQ'.
*    fieldcat-ref_fieldname = 'CLTOPQ'.
*    fieldcat-tabname = 'I_OUTPUT2'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'CL / TOP'.
*    fieldcat-seltext_m = 'CL / TOP'.
*    fieldcat-seltext_l = 'CL / TOP'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'STKOUTQ'.
*    fieldcat-ref_fieldname = 'STKOUTQ'.
*    fieldcat-tabname = 'I_OUTPUT2'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Stock Out'.
*    fieldcat-seltext_m = 'Stock Out'.
*    fieldcat-seltext_l = 'Stock Out'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'SALAHQ'.
*    fieldcat-ref_fieldname = 'SALAHQ'.
*    fieldcat-tabname = 'I_OUTPUT2'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Salah Harga'.
*    fieldcat-seltext_m = 'Salah Harga'.
*    fieldcat-seltext_l = 'Salah Harga'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'OTHERQ'.
*    fieldcat-ref_fieldname = 'OTHERQ'.
*    fieldcat-tabname = 'I_OUTPUT2'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Other'.
*    fieldcat-seltext_m = 'Other'.
*    fieldcat-seltext_l = 'Other'.
*    APPEND fieldcat. "clear fieldcat.
*
**  fieldcat-fieldname = 'REJECTQ'.
**  fieldcat-ref_fieldname = 'REJECTQ'.
**  fieldcat-tabname = 'I_OUTPUT2'.
**  fieldcat-outputlen = 11.
**  fieldcat-decimalsfieldname = 'DECI'.
**  fieldcat-seltext_s = 'CL / TOP '.
**  fieldcat-seltext_m = 'CL / TOP '.
**  fieldcat-seltext_l = 'CL / TOP '.
**  APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'POOUTQ'.
*    fieldcat-ref_fieldname = 'POOUTQ'.
*    fieldcat-tabname = 'I_OUTPUT2'.
*    fieldcat-outputlen = 13.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'PO Outs'.
*    fieldcat-seltext_m = 'PO Outstanding'.
*    fieldcat-seltext_l = 'PO Outstanding'.
*    APPEND fieldcat. "clear fieldcat.
  ENDIF.

  mac_header2 : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.

ENDFORM.                    " f_build_fieldcat2

*&---------------------------------------------------------------------*
*&      Form  f_build_sortfield2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_SORT
*----------------------------------------------------------------------*
FORM f_build_sortfield2 USING fu_sort TYPE slis_t_sortinfo_alv.

  DATA: ld_sort TYPE slis_sortinfo_alv.

  IF p_total2 IS INITIAL.
    CLEAR ld_sort.
    ld_sort-fieldname = 'KVGR4'.
    ld_sort-up        = 'X'.
    ld_sort-group     = '*'.
    APPEND ld_sort TO fu_sort.
  ELSE.
    CLEAR ld_sort.
    ld_sort-fieldname = 'KVGR4'.
    ld_sort-up        = 'X'.
*  ld_sort-group     = '*'.
    APPEND ld_sort TO fu_sort.
  ENDIF.

  CLEAR ld_sort.
  ld_sort-fieldname = 'PRINX'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'MATKX'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'INDEX'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  APPEND ld_sort TO fu_sort.

ENDFORM.                    " f_build_sortfield2

*&---------------------------------------------------------------------*
*&      Form  f_build_event2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_EVENTS
*----------------------------------------------------------------------*
FORM f_build_event2 TABLES ft_events LIKE t_events.

  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE2'.
  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_end_of_list.
*  ft_events-form = 'F_END_OF_LIST2'.
*  APPEND ft_events.

ENDFORM.                    " f_build_event2

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE2                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page2.

  DATA : l_line1(70),
         l_line2(60),
         l_line3(60),
         l_sloff(80),
         l_fdate(10),
         l_tdate(10).

  WRITE s_erdat-low TO l_fdate.
  WRITE s_erdat-high TO l_tdate.
*--- Title
  CONCATENATE sy-title 'By Key Account Grp, Material Grp' '(07)'
              INTO l_line1 SEPARATED BY space.
*--- Period
  CONCATENATE 'Period :' l_fdate 'to' l_tdate
              INTO l_line2 SEPARATED BY space.
*--- Sales Office
  CONCATENATE 'Sales Office    :' 'NATIONAL'
              INTO l_sloff SEPARATED BY space.
*--- Customer
  IF p_total2 IS INITIAL.
    CONCATENATE 'Key Account Grp :' i_output2-kvgr4 i_output2-bezei
                INTO l_line3 SEPARATED BY space.
  ELSE.
    l_line3 = 'SUMMARY'.
  ENDIF.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING l_line1.
  PERFORM f_hdr_line2 USING l_sloff l_line2.
  PERFORM f_hdr_line3 USING l_line3 va_text.
  PERFORM f_hdr_uline.

ENDFORM.                    "f_top_of_page2

*&---------------------------------------------------------------------*
*&      Form  hitung_total2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hitung_total2.

  ADD i_output2-kwmeng TO wa_stot21-kwmeng.
  ADD i_output2-kwmeng TO wa_stot22-kwmeng.
  ADD i_output2-kwmeng TO wa_stot23-kwmeng.
  ADD i_output2-kwmeng TO wa_gtot2-kwmeng.
  ADD i_output2-kzwi1 TO wa_stot21-kzwi1.
  ADD i_output2-kzwi1 TO wa_stot22-kzwi1.
  ADD i_output2-kzwi1 TO wa_stot23-kzwi1.
  ADD i_output2-kzwi1 TO wa_gtot2-kzwi1.
  ADD i_output2-dlqty TO wa_stot21-dlqty.
  ADD i_output2-dlqty TO wa_stot22-dlqty.
  ADD i_output2-dlqty TO wa_stot23-dlqty.
  ADD i_output2-dlqty TO wa_gtot2-dlqty.
  ADD i_output2-dlval TO wa_stot21-dlval.
  ADD i_output2-dlval TO wa_stot22-dlval.
  ADD i_output2-dlval TO wa_stot23-dlval.
  ADD i_output2-dlval TO wa_gtot2-dlval.
  ADD i_output2-unqty TO wa_stot21-unqty.
  ADD i_output2-unqty TO wa_stot22-unqty.
  ADD i_output2-unqty TO wa_stot23-unqty.
  ADD i_output2-unqty TO wa_gtot2-unqty.
  ADD i_output2-unval TO wa_stot21-unval.
  ADD i_output2-unval TO wa_stot22-unval.
  ADD i_output2-unval TO wa_stot23-unval.
  ADD i_output2-unval TO wa_gtot2-unval.
  ADD i_output2-lead1q TO wa_stot21-lead1q.
  ADD i_output2-lead1q TO wa_stot22-lead1q.
  ADD i_output2-lead1q TO wa_stot23-lead1q.
  ADD i_output2-lead1q TO wa_gtot2-lead1q.
  ADD i_output2-lead1 TO wa_stot21-lead1.
  ADD i_output2-lead1 TO wa_stot22-lead1.
  ADD i_output2-lead1 TO wa_stot23-lead1.
  ADD i_output2-lead1 TO wa_gtot2-lead1.
  ADD i_output2-lead2q TO wa_stot21-lead2q.
  ADD i_output2-lead2q TO wa_stot22-lead2q.
  ADD i_output2-lead2q TO wa_stot23-lead2q.
  ADD i_output2-lead2q TO wa_gtot2-lead2q.
  ADD i_output2-lead2 TO wa_stot21-lead2.
  ADD i_output2-lead2 TO wa_stot22-lead2.
  ADD i_output2-lead2 TO wa_stot23-lead2.
  ADD i_output2-lead2 TO wa_gtot2-lead2.
  ADD i_output2-lead3q TO wa_stot21-lead3q.
  ADD i_output2-lead3q TO wa_stot22-lead3q.
  ADD i_output2-lead3q TO wa_stot23-lead3q.
  ADD i_output2-lead3q TO wa_gtot2-lead3q.
  ADD i_output2-lead3 TO wa_stot21-lead3.
  ADD i_output2-lead3 TO wa_stot22-lead3.
  ADD i_output2-lead3 TO wa_stot23-lead3.
  ADD i_output2-lead3 TO wa_gtot2-lead3.
  ADD i_output2-lead4q TO wa_stot21-lead4q.
  ADD i_output2-lead4q TO wa_stot22-lead4q.
  ADD i_output2-lead4q TO wa_stot23-lead4q.
  ADD i_output2-lead4q TO wa_gtot2-lead4q.
  ADD i_output2-lead4 TO wa_stot21-lead4.
  ADD i_output2-lead4 TO wa_stot22-lead4.
  ADD i_output2-lead4 TO wa_stot23-lead4.
  ADD i_output2-lead4 TO wa_gtot2-lead4.
  ADD i_output2-lead5q TO wa_stot21-lead5q.
  ADD i_output2-lead5q TO wa_stot22-lead5q.
  ADD i_output2-lead5q TO wa_stot23-lead5q.
  ADD i_output2-lead5q TO wa_gtot2-lead5q.
  ADD i_output2-lead5 TO wa_stot21-lead5.
  ADD i_output2-lead5 TO wa_stot22-lead5.
  ADD i_output2-lead5 TO wa_stot23-lead5.
  ADD i_output2-lead5 TO wa_gtot2-lead5.
  ADD i_output2-lead6q TO wa_stot21-lead6q.
  ADD i_output2-lead6q TO wa_stot22-lead6q.
  ADD i_output2-lead6q TO wa_stot23-lead6q.
  ADD i_output2-lead6q TO wa_gtot2-lead6q.
  ADD i_output2-lead6 TO wa_stot21-lead6.
  ADD i_output2-lead6 TO wa_stot22-lead6.
  ADD i_output2-lead6 TO wa_stot23-lead6.
  ADD i_output2-lead6 TO wa_gtot2-lead6.
  ADD i_output2-stkoutq TO wa_stot21-stkoutq.
  ADD i_output2-stkoutq TO wa_stot22-stkoutq.
  ADD i_output2-stkoutq TO wa_stot23-stkoutq.
  ADD i_output2-stkoutq TO wa_gtot2-stkoutq.
  ADD i_output2-stkout TO wa_stot21-stkout.
  ADD i_output2-stkout TO wa_stot22-stkout.
  ADD i_output2-stkout TO wa_stot23-stkout.
  ADD i_output2-stkout TO wa_gtot2-stkout.
  ADD i_output2-cltopq TO wa_stot21-cltopq.
  ADD i_output2-cltopq TO wa_stot22-cltopq.
  ADD i_output2-cltopq TO wa_stot23-cltopq.
  ADD i_output2-cltopq TO wa_gtot2-cltopq.
  ADD i_output2-cltop TO wa_stot21-cltop.
  ADD i_output2-cltop TO wa_stot22-cltop.
  ADD i_output2-cltop TO wa_stot23-cltop.
  ADD i_output2-cltop TO wa_gtot2-cltop.
  ADD i_output2-salahq TO wa_stot21-salahq.
  ADD i_output2-salahq TO wa_stot22-salahq.
  ADD i_output2-salahq TO wa_stot23-salahq.
  ADD i_output2-salahq TO wa_gtot2-salahq.
  ADD i_output2-salah TO wa_stot21-salah.
  ADD i_output2-salah TO wa_stot22-salah.
  ADD i_output2-salah TO wa_stot23-salah.
  ADD i_output2-salah TO wa_gtot2-salah.
  ADD i_output2-otherq TO wa_stot21-otherq.
  ADD i_output2-otherq TO wa_stot22-otherq.
  ADD i_output2-otherq TO wa_stot23-otherq.
  ADD i_output2-otherq TO wa_gtot2-otherq.
  ADD i_output2-other TO wa_stot21-other.
  ADD i_output2-other TO wa_stot22-other.
  ADD i_output2-other TO wa_stot23-other.
  ADD i_output2-other TO wa_gtot2-other.
  ADD i_output2-rejectq TO wa_stot21-rejectq.
  ADD i_output2-rejectq TO wa_stot22-rejectq.
  ADD i_output2-rejectq TO wa_stot23-rejectq.
  ADD i_output2-rejectq TO wa_gtot2-rejectq.
  ADD i_output2-reject TO wa_stot21-reject.
  ADD i_output2-reject TO wa_stot22-reject.
  ADD i_output2-reject TO wa_stot23-reject.
  ADD i_output2-reject TO wa_gtot2-reject.
  ADD i_output2-pooutq TO wa_stot21-pooutq.
  ADD i_output2-pooutq TO wa_stot22-pooutq.
  ADD i_output2-pooutq TO wa_stot23-pooutq.
  ADD i_output2-pooutq TO wa_gtot2-pooutq.
  ADD i_output2-poout TO wa_stot21-poout.
  ADD i_output2-poout TO wa_stot22-poout.
  ADD i_output2-poout TO wa_stot23-poout.
  ADD i_output2-poout TO wa_gtot2-poout.
  ADD i_output2-btqty TO wa_stot21-btqty.
  ADD i_output2-btqty TO wa_stot22-btqty.
  ADD i_output2-btqty TO wa_stot23-btqty.
  ADD i_output2-btqty TO wa_gtot2-btqty.
  ADD i_output2-btamt TO wa_stot21-btamt.
  ADD i_output2-btamt TO wa_stot22-btamt.
  ADD i_output2-btamt TO wa_stot23-btamt.
  ADD i_output2-btamt TO wa_gtot2-btamt.

  PERFORM f_hitung_total USING '2'.

ENDFORM.                    " hitung_total2

*&---------------------------------------------------------------------*
*&      Form  proses_data3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proses_data3.

  SORT i_detquot3  BY vkbur kvgr4 princ matkl matnr.
*  SORT i_detsales BY vgbel posnr.
  SORT i_detsales BY vgbel vgpos.
  SORT i_detdelv  BY vgbel vgpos.
  LOOP AT i_detquot3.

    CLEAR : i_detsales, i_detdelv, i_output3. ", i_detquot3-abgru.

    READ TABLE i_detsales WITH KEY
                               vgbel = i_detquot3-vbeln
*                               posnr = i_detquot3-posnr BINARY SEARCH.
                               vgpos = i_detquot3-posnr. " BINARY SEARCH.
    IF sy-subrc = 0.
      IF i_detsales-abgru IS NOT INITIAL.
        i_detquot3-abgru = i_detsales-abgru.
      ENDIF.
    ENDIF.

    READ TABLE i_detdelv WITH KEY
                              vgbel = i_detsales-vbeln
                              vgpos = i_detsales-posnr. " BINARY SEARCH.

    PERFORM append_itab3.

* Total Material Group
    AT END OF matkl.
      wa_stot34-vkbur = i_output3-vkbur.
      wa_stot34-vkburt = i_output3-vkburt.
      wa_stot34-kvgr4 = i_output3-kvgr4.
      wa_stot34-bezei = i_output3-bezei.
      CONCATENATE '*    Total' i_output3-matkl
                  INTO wa_stot34-maktx SEPARATED BY space.
      wa_stot34-info = 'C30'.
      wa_stot34-curr = 'IDR'.
      wa_stot34-index = '20'.
      wa_stot34-deci = '0'.
      wa_stot34-prinx = i_output3-princ.
      wa_stot34-matkx = i_output3-matkl.
      APPEND wa_stot34 TO i_output3.

      wa_stot34-maktx = '           Percentage(%)'.
      IF wa_stot34-kzwi1 NE wa_stot34-btamt.
        IF p_val = 'X'.
          wa_stot34-dlval% = wa_stot34-dlval / ( wa_stot34-kzwi1 -
                             wa_stot34-btamt ) * 100.
          wa_stot34-unprc = wa_stot34-unval / ( wa_stot34-kzwi1 -
                            wa_stot34-btamt ) * 100.
          wa_stot34-lead1% = wa_stot34-lead1 / ( wa_stot34-kzwi1 -
                             wa_stot34-btamt ) * 100.
          wa_stot34-lead2% = wa_stot34-lead2 / ( wa_stot34-kzwi1 -
                             wa_stot34-btamt ) * 100.
          wa_stot34-lead3% = wa_stot34-lead3 / ( wa_stot34-kzwi1 -
                             wa_stot34-btamt ) * 100.
          wa_stot34-lead4% = wa_stot34-lead4 / ( wa_stot34-kzwi1 -
                             wa_stot34-btamt ) * 100.
          wa_stot34-lead5% = wa_stot34-lead5 / ( wa_stot34-kzwi1 -
                             wa_stot34-btamt ) * 100.
          wa_stot34-lead6% = wa_stot34-lead6 / ( wa_stot34-kzwi1 -
                             wa_stot34-btamt ) * 100.
          wa_stot34-poout% = wa_stot34-poout / ( wa_stot34-kzwi1 -
                             wa_stot34-btamt ) * 100.
          wa_stot34-btprc% = wa_stot34-btamt / wa_stot34-kzwi1 * 100.
          wa_stot34-stkout% = wa_stot34-stkout / ( wa_stot34-kzwi1 -
                             wa_stot34-btamt ) * 100.
          wa_stot34-cltop% = wa_stot34-cltop / ( wa_stot34-kzwi1 -
                            wa_stot34-btamt ) * 100.
          wa_stot34-salah% = wa_stot34-salah / ( wa_stot34-kzwi1 -
                            wa_stot34-btamt ) * 100.
          wa_stot34-other% = wa_stot34-other / ( wa_stot34-kzwi1 -
                            wa_stot34-btamt ) * 100.
          wa_stot34-reject% = wa_stot34-reject / ( wa_stot34-kzwi1 -
                             wa_stot34-btamt ) * 100.

          PERFORM f_hitung_stot4 USING wa_stot34-kzwi1
                                       wa_stot34-btamt
                                       wa_stot34-kwmeng
                                       wa_stot34-btqty
                                       p_val
                                       '3'.

        ELSE.
          wa_stot34-dlval% = wa_stot34-dlqty / ( wa_stot34-kwmeng -
                             wa_stot34-btqty ) * 100.
          wa_stot34-unprc = wa_stot34-unqty / ( wa_stot34-kwmeng -
                            wa_stot34-btqty ) * 100.
          wa_stot34-lead1% = wa_stot34-lead1q / ( wa_stot34-kwmeng -
                             wa_stot34-btqty ) * 100.
          wa_stot34-lead2% = wa_stot34-lead2q / ( wa_stot34-kwmeng -
                             wa_stot34-btqty ) * 100.
          wa_stot34-lead3% = wa_stot34-lead3q / ( wa_stot34-kwmeng -
                             wa_stot34-btqty ) * 100.
          wa_stot34-lead4% = wa_stot34-lead4q / ( wa_stot34-kwmeng -
                             wa_stot34-btqty ) * 100.
          wa_stot34-lead5% = wa_stot34-lead5q / ( wa_stot34-kwmeng -
                             wa_stot34-btqty ) * 100.
          wa_stot34-lead6% = wa_stot34-lead6q / ( wa_stot34-kwmeng -
                             wa_stot34-btqty ) * 100.
          wa_stot34-poout% = wa_stot34-pooutq / ( wa_stot34-kwmeng -
                             wa_stot34-btqty ) * 100.
          wa_stot34-btprc% = wa_stot34-btqty / wa_stot34-kwmeng * 100.
          wa_stot34-stkout% = wa_stot34-stkoutq / ( wa_stot34-kwmeng -
                             wa_stot34-btqty ) * 100.
          wa_stot34-cltop% = wa_stot34-cltopq / ( wa_stot34-kwmeng -
                            wa_stot34-btqty ) * 100.
          wa_stot34-salah% = wa_stot34-salahq / ( wa_stot34-kwmeng -
                            wa_stot34-btqty ) * 100.
          wa_stot34-other% = wa_stot34-otherq / ( wa_stot34-kwmeng -
                            wa_stot34-btqty ) * 100.
          wa_stot34-reject% = wa_stot34-rejectq / ( wa_stot34-kwmeng -
                             wa_stot34-btqty ) * 100.

          PERFORM f_hitung_stot4 USING wa_stot34-kzwi1
                                       wa_stot34-btamt
                                       wa_stot34-kwmeng
                                       wa_stot34-btqty
                                       p_val
                                       '3'.

        ENDIF.
      ENDIF.

      wa_stot34-dlval = wa_stot34-dlval%.
      IF p_val = 'X'.
        wa_stot34-unval = wa_stot34-unprc.
        wa_stot34-lead1 = wa_stot34-lead1%.
        wa_stot34-lead2 = wa_stot34-lead2%.
        wa_stot34-lead3 = wa_stot34-lead3%.
        wa_stot34-lead4 = wa_stot34-lead4%.
        wa_stot34-lead5 = wa_stot34-lead5%.
        wa_stot34-lead6 = wa_stot34-lead6%.
        wa_stot34-poout = wa_stot34-poout%.
        wa_stot34-btamt = wa_stot34-btprc%.
        wa_stot34-stkout = wa_stot34-stkout%.
        wa_stot34-cltop = wa_stot34-cltop%.
        wa_stot34-salah = wa_stot34-salah%.
        wa_stot34-other = wa_stot34-other%.
        wa_stot34-reject = wa_stot34-reject%.

        PERFORM f_move_stot4 USING p_val '3'.

      ELSE.
        wa_stot34-unqty = wa_stot34-unprc.
        wa_stot34-lead1q = wa_stot34-lead1%.
        wa_stot34-lead2q = wa_stot34-lead2%.
        wa_stot34-lead3q = wa_stot34-lead3%.
        wa_stot34-lead4q = wa_stot34-lead4%.
        wa_stot34-lead5q = wa_stot34-lead5%.
        wa_stot34-lead6q = wa_stot34-lead6%.
        wa_stot34-pooutq = wa_stot34-poout%.
        wa_stot34-btqty = wa_stot34-btprc%.
        wa_stot34-stkoutq = wa_stot34-stkout%.
        wa_stot34-cltopq = wa_stot34-cltop%.
        wa_stot34-salahq = wa_stot34-salah%.
        wa_stot34-otherq = wa_stot34-other%.
        wa_stot34-rejectq = wa_stot34-reject%.

        PERFORM f_move_stot4 USING p_val '3'.

      ENDIF.
      wa_stot34-deci = '2'.
      CLEAR: wa_stot34-curr, wa_stot34-kwmeng,
             wa_stot34-kzwi1, wa_stot34-dlqty.
      APPEND wa_stot34 TO i_output3.
      CLEAR: wa_stot34.
    ENDAT.

* Total Principal
    AT END OF princ.
      wa_stot33-vkbur = i_output3-vkbur.
      wa_stot33-vkburt = i_output3-vkburt.
      wa_stot33-kvgr4 = i_output3-kvgr4.
      wa_stot33-bezei = i_output3-bezei.
      CONCATENATE '*    Total' i_output3-princ
                  INTO wa_stot33-maktx SEPARATED BY space.
      wa_stot33-info = 'C30'.
      wa_stot33-curr = 'IDR'.
      wa_stot33-index = '30'.
      wa_stot33-deci = '0'.
      wa_stot33-prinx = i_output3-princ.
      wa_stot33-matkx = i_output3-matkl.
      APPEND wa_stot33 TO i_output3.

      wa_stot33-maktx = '           Percentage(%)'.
      IF wa_stot33-kzwi1 NE wa_stot33-btamt.
        IF p_val = 'X'.
          wa_stot33-dlval% = wa_stot33-dlval / ( wa_stot33-kzwi1 -
                             wa_stot33-btamt ) * 100.
          wa_stot33-unprc = wa_stot33-unval / ( wa_stot33-kzwi1 -
                            wa_stot33-btamt ) * 100.
          wa_stot33-lead1% = wa_stot33-lead1 / ( wa_stot33-kzwi1 -
                             wa_stot33-btamt ) * 100.
          wa_stot33-lead2% = wa_stot33-lead2 / ( wa_stot33-kzwi1 -
                             wa_stot33-btamt ) * 100.
          wa_stot33-lead3% = wa_stot33-lead3 / ( wa_stot33-kzwi1 -
                             wa_stot33-btamt ) * 100.
          wa_stot33-lead4% = wa_stot33-lead4 / ( wa_stot33-kzwi1 -
                             wa_stot33-btamt ) * 100.
          wa_stot33-lead5% = wa_stot33-lead5 / ( wa_stot33-kzwi1 -
                             wa_stot33-btamt ) * 100.
          wa_stot33-lead6% = wa_stot33-lead6 / ( wa_stot33-kzwi1 -
                             wa_stot33-btamt ) * 100.
          wa_stot33-poout% = wa_stot33-poout / ( wa_stot33-kzwi1 -
                             wa_stot33-btamt ) * 100.
          wa_stot33-btprc% = wa_stot33-btamt / wa_stot33-kzwi1 * 100.
          wa_stot33-stkout% = wa_stot33-stkout / ( wa_stot33-kzwi1 -
                             wa_stot33-btamt ) * 100.
          wa_stot33-cltop% = wa_stot33-cltop / ( wa_stot33-kzwi1 -
                            wa_stot33-btamt ) * 100.
          wa_stot33-salah% = wa_stot33-salah / ( wa_stot33-kzwi1 -
                            wa_stot33-btamt ) * 100.
          wa_stot33-other% = wa_stot33-other / ( wa_stot33-kzwi1 -
                            wa_stot33-btamt ) * 100.
          wa_stot33-reject% = wa_stot33-reject / ( wa_stot33-kzwi1 -
                             wa_stot33-btamt ) * 100.

          PERFORM f_hitung_stot3 USING wa_stot33-kzwi1
                                       wa_stot33-btamt
                                       wa_stot33-kwmeng
                                       wa_stot33-btqty
                                       p_val
                                       '3'.

        ELSE.
          wa_stot33-dlval% = wa_stot33-dlqty / ( wa_stot33-kwmeng -
                             wa_stot33-btqty ) * 100.
          wa_stot33-unprc = wa_stot33-unqty / ( wa_stot33-kwmeng -
                            wa_stot33-btqty ) * 100.
          wa_stot33-lead1% = wa_stot33-lead1q / ( wa_stot33-kwmeng -
                             wa_stot33-btqty ) * 100.
          wa_stot33-lead2% = wa_stot33-lead2q / ( wa_stot33-kwmeng -
                             wa_stot33-btqty ) * 100.
          wa_stot33-lead3% = wa_stot33-lead3q / ( wa_stot33-kwmeng -
                             wa_stot33-btqty ) * 100.
          wa_stot33-lead4% = wa_stot33-lead4q / ( wa_stot33-kwmeng -
                             wa_stot33-btqty ) * 100.
          wa_stot33-lead5% = wa_stot33-lead5q / ( wa_stot33-kwmeng -
                             wa_stot33-btqty ) * 100.
          wa_stot33-lead6% = wa_stot33-lead6q / ( wa_stot33-kwmeng -
                             wa_stot33-btqty ) * 100.
          wa_stot33-poout% = wa_stot33-pooutq / ( wa_stot33-kwmeng -
                             wa_stot33-btqty ) * 100.
          wa_stot33-btprc% = wa_stot33-btqty / wa_stot33-kwmeng * 100.
          wa_stot33-stkout% = wa_stot33-stkoutq / ( wa_stot33-kwmeng -
                             wa_stot33-btqty ) * 100.
          wa_stot33-cltop% = wa_stot33-cltopq / ( wa_stot33-kwmeng -
                            wa_stot33-btqty ) * 100.
          wa_stot33-salah% = wa_stot33-salahq / ( wa_stot33-kwmeng -
                            wa_stot33-btqty ) * 100.
          wa_stot33-other% = wa_stot33-otherq / ( wa_stot33-kwmeng -
                            wa_stot33-btqty ) * 100.
          wa_stot33-reject% = wa_stot33-rejectq / ( wa_stot33-kwmeng -
                             wa_stot33-btqty ) * 100.

          PERFORM f_hitung_stot3 USING wa_stot33-kzwi1
                                       wa_stot33-btamt
                                       wa_stot33-kwmeng
                                       wa_stot33-btqty
                                       p_val
                                       '3'.

        ENDIF.
      ENDIF.

      wa_stot33-dlval = wa_stot33-dlval%.
      IF p_val = 'X'.
        wa_stot33-unval = wa_stot33-unprc.
        wa_stot33-lead1 = wa_stot33-lead1%.
        wa_stot33-lead2 = wa_stot33-lead2%.
        wa_stot33-lead3 = wa_stot33-lead3%.
        wa_stot33-lead4 = wa_stot33-lead4%.
        wa_stot33-lead5 = wa_stot33-lead5%.
        wa_stot33-lead6 = wa_stot33-lead6%.
        wa_stot33-poout = wa_stot33-poout%.
        wa_stot33-btamt = wa_stot33-btprc%.
        wa_stot33-stkout = wa_stot33-stkout%.
        wa_stot33-cltop = wa_stot33-cltop%.
        wa_stot33-salah = wa_stot33-salah%.
        wa_stot33-other = wa_stot33-other%.
        wa_stot33-reject = wa_stot33-reject%.

        PERFORM f_move_stot3 USING p_val '3'.

      ELSE.
        wa_stot33-unqty = wa_stot33-unprc.
        wa_stot33-lead1q = wa_stot33-lead1%.
        wa_stot33-lead2q = wa_stot33-lead2%.
        wa_stot33-lead3q = wa_stot33-lead3%.
        wa_stot33-lead4q = wa_stot33-lead4%.
        wa_stot33-lead5q = wa_stot33-lead5%.
        wa_stot33-lead6q = wa_stot33-lead6%.
        wa_stot33-pooutq = wa_stot33-poout%.
        wa_stot33-btqty = wa_stot33-btprc%.
        wa_stot33-stkoutq = wa_stot33-stkout%.
        wa_stot33-cltopq = wa_stot33-cltop%.
        wa_stot33-salahq = wa_stot33-salah%.
        wa_stot33-otherq = wa_stot33-other%.
        wa_stot33-rejectq = wa_stot33-reject%.

        PERFORM f_move_stot3 USING p_val '3'.

      ENDIF.
      wa_stot33-deci = '2'.
      CLEAR: wa_stot33-curr, wa_stot33-kwmeng,
             wa_stot33-kzwi1, wa_stot33-dlqty.
      APPEND wa_stot33 TO i_output3.
      CLEAR: wa_stot33, wa_stot34.
    ENDAT.

* Total Customer Group
    AT END OF kvgr4.
      wa_stot32-vkbur = i_output3-vkbur.
      wa_stot32-vkburt = i_output3-vkburt.
      wa_stot32-kvgr4 = i_output3-kvgr4.
      wa_stot32-bezei = i_output3-bezei.
      CONCATENATE '**   Total' i_output3-kvgr4 i_output3-bezei
                  INTO wa_stot32-maktx SEPARATED BY space.
      wa_stot32-info = 'C31'.
      wa_stot32-curr = 'IDR'.
      wa_stot32-index = '40'.
      wa_stot32-deci = '0'.
      wa_stot32-prinx = i_output3-princ.
      wa_stot32-matkx = i_output3-matkl.
      APPEND wa_stot32 TO i_output3.

      wa_stot32-maktx = '           Percentage(%)'.
      IF wa_stot32-kzwi1 NE wa_stot32-btamt.
        IF p_val = 'X'.
          wa_stot32-dlval% = wa_stot32-dlval / ( wa_stot32-kzwi1 -
                             wa_stot32-btamt ) * 100.
          wa_stot32-unprc = wa_stot32-unval / ( wa_stot32-kzwi1 -
                            wa_stot32-btamt ) * 100.
          wa_stot32-lead1% = wa_stot32-lead1 / ( wa_stot32-kzwi1 -
                             wa_stot32-btamt ) * 100.
          wa_stot32-lead2% = wa_stot32-lead2 / ( wa_stot32-kzwi1 -
                             wa_stot32-btamt ) * 100.
          wa_stot32-lead3% = wa_stot32-lead3 / ( wa_stot32-kzwi1 -
                             wa_stot32-btamt ) * 100.
          wa_stot32-lead4% = wa_stot32-lead4 / ( wa_stot32-kzwi1 -
                             wa_stot32-btamt ) * 100.
          wa_stot32-lead5% = wa_stot32-lead5 / ( wa_stot32-kzwi1 -
                             wa_stot32-btamt ) * 100.
          wa_stot32-lead6% = wa_stot32-lead6 / ( wa_stot32-kzwi1 -
                             wa_stot32-btamt ) * 100.
          wa_stot32-poout% = wa_stot32-poout / ( wa_stot32-kzwi1 -
                             wa_stot32-btamt ) * 100.
          wa_stot32-btprc% = wa_stot32-btamt / wa_stot32-kzwi1 * 100.
          wa_stot32-stkout% = wa_stot32-stkout / ( wa_stot32-kzwi1 -
                             wa_stot32-btamt ) * 100.
          wa_stot32-cltop% = wa_stot32-cltop / ( wa_stot32-kzwi1 -
                            wa_stot32-btamt ) * 100.
          wa_stot32-salah% = wa_stot32-salah / ( wa_stot32-kzwi1 -
                            wa_stot32-btamt ) * 100.
          wa_stot32-other% = wa_stot32-other / ( wa_stot32-kzwi1 -
                            wa_stot32-btamt ) * 100.
          wa_stot32-reject% = wa_stot32-reject / ( wa_stot32-kzwi1 -
                             wa_stot32-btamt ) * 100.

          PERFORM f_hitung_stot2 USING wa_stot32-kzwi1
                                       wa_stot32-btamt
                                       wa_stot32-kwmeng
                                       wa_stot32-btqty
                                       p_val
                                       '3'.

        ELSE.
          wa_stot32-dlval% = wa_stot32-dlqty / ( wa_stot32-kwmeng -
                             wa_stot32-btqty ) * 100.
          wa_stot32-unprc = wa_stot32-unqty / ( wa_stot32-kwmeng -
                            wa_stot32-btqty ) * 100.
          wa_stot32-lead1% = wa_stot32-lead1q / ( wa_stot32-kwmeng -
                             wa_stot32-btqty ) * 100.
          wa_stot32-lead2% = wa_stot32-lead2q / ( wa_stot32-kwmeng -
                             wa_stot32-btqty ) * 100.
          wa_stot32-lead3% = wa_stot32-lead3q / ( wa_stot32-kwmeng -
                             wa_stot32-btqty ) * 100.
          wa_stot32-lead4% = wa_stot32-lead4q / ( wa_stot32-kwmeng -
                             wa_stot32-btqty ) * 100.
          wa_stot32-lead5% = wa_stot32-lead5q / ( wa_stot32-kwmeng -
                             wa_stot32-btqty ) * 100.
          wa_stot32-lead6% = wa_stot32-lead6q / ( wa_stot32-kwmeng -
                             wa_stot32-btqty ) * 100.
          wa_stot32-poout% = wa_stot32-pooutq / ( wa_stot32-kwmeng -
                             wa_stot32-btqty ) * 100.
          wa_stot32-btprc% = wa_stot32-btqty / wa_stot32-kwmeng * 100.
          wa_stot32-stkout% = wa_stot32-stkoutq / ( wa_stot32-kwmeng -
                             wa_stot32-btqty ) * 100.
          wa_stot32-cltop% = wa_stot32-cltopq / ( wa_stot32-kwmeng -
                            wa_stot32-btqty ) * 100.
          wa_stot32-salah% = wa_stot32-salahq / ( wa_stot32-kwmeng -
                            wa_stot32-btqty ) * 100.
          wa_stot32-other% = wa_stot32-otherq / ( wa_stot32-kwmeng -
                            wa_stot32-btqty ) * 100.
          wa_stot32-reject% = wa_stot32-rejectq / ( wa_stot32-kwmeng -
                             wa_stot32-btqty ) * 100.

          PERFORM f_hitung_stot2 USING wa_stot32-kzwi1
                                       wa_stot32-btamt
                                       wa_stot32-kwmeng
                                       wa_stot32-btqty
                                       p_val
                                       '3'.

        ENDIF.
      ENDIF.

      wa_stot32-dlval = wa_stot32-dlval%.
      IF p_val = 'X'.
        wa_stot32-unval = wa_stot32-unprc.
        wa_stot32-lead1 = wa_stot32-lead1%.
        wa_stot32-lead2 = wa_stot32-lead2%.
        wa_stot32-lead3 = wa_stot32-lead3%.
        wa_stot32-lead4 = wa_stot32-lead4%.
        wa_stot32-lead5 = wa_stot32-lead5%.
        wa_stot32-lead6 = wa_stot32-lead6%.
        wa_stot32-poout = wa_stot32-poout%.
        wa_stot32-btamt = wa_stot32-btprc%.
        wa_stot32-stkout = wa_stot32-stkout%.
        wa_stot32-cltop = wa_stot32-cltop%.
        wa_stot32-salah = wa_stot32-salah%.
        wa_stot32-other = wa_stot32-other%.
        wa_stot32-reject = wa_stot32-reject%.

        PERFORM f_move_stot2 USING p_val '3'.

      ELSE.
        wa_stot32-unqty = wa_stot32-unprc.
        wa_stot32-lead1q = wa_stot32-lead1%.
        wa_stot32-lead2q = wa_stot32-lead2%.
        wa_stot32-lead3q = wa_stot32-lead3%.
        wa_stot32-lead4q = wa_stot32-lead4%.
        wa_stot32-lead5q = wa_stot32-lead5%.
        wa_stot32-lead6q = wa_stot32-lead6%.
        wa_stot32-pooutq = wa_stot32-poout%.
        wa_stot32-btqty = wa_stot32-btprc%.
        wa_stot32-stkoutq = wa_stot32-stkout%.
        wa_stot32-cltopq = wa_stot32-cltop%.
        wa_stot32-salahq = wa_stot32-salah%.
        wa_stot32-otherq = wa_stot32-other%.
        wa_stot32-rejectq = wa_stot32-reject%.

        PERFORM f_move_stot2 USING p_val '3'.

      ENDIF.
      wa_stot32-deci = '2'.
      CLEAR: wa_stot32-curr, wa_stot32-kwmeng,
             wa_stot32-kzwi1, wa_stot32-dlqty.
      APPEND wa_stot32 TO i_output3.
      CLEAR: wa_stot32, wa_stot33, wa_stot34.
    ENDAT.

* Total Sales Office
    AT END OF vkbur.
      wa_stot31-vkbur = i_output3-vkbur.
      wa_stot31-vkburt = i_output3-vkburt.
      wa_stot31-kvgr4 = i_output3-kvgr4.
      wa_stot31-bezei = i_output3-bezei.
      CONCATENATE '***  Total' i_output3-vkbur
                  INTO wa_stot31-maktx SEPARATED BY space.
      wa_stot31-info = 'C70'.
      wa_stot31-curr = 'IDR'.
      wa_stot31-index = '50'.
      wa_stot31-deci = '0'.
      wa_stot31-prinx = i_output3-princ.
      wa_stot31-matkx = i_output3-matkl.
      APPEND wa_stot31 TO i_output3.

      wa_stot31-maktx = '           Percentage(%)'.
      IF wa_stot31-kzwi1 NE wa_stot31-btamt.
        IF p_val = 'X'.
          wa_stot31-dlval% = wa_stot31-dlval / ( wa_stot31-kzwi1 -
                             wa_stot31-btamt ) * 100.
          wa_stot31-unprc = wa_stot31-unval / ( wa_stot31-kzwi1 -
                             wa_stot31-btamt ) * 100.
          wa_stot31-lead1% = wa_stot31-lead1 / ( wa_stot31-kzwi1 -
                             wa_stot31-btamt ) * 100.
          wa_stot31-lead2% = wa_stot31-lead2 / ( wa_stot31-kzwi1 -
                             wa_stot31-btamt ) * 100.
          wa_stot31-lead3% = wa_stot31-lead3 / ( wa_stot31-kzwi1 -
                             wa_stot31-btamt ) * 100.
          wa_stot31-lead4% = wa_stot31-lead4 / ( wa_stot31-kzwi1 -
                             wa_stot31-btamt ) * 100.
          wa_stot31-lead5% = wa_stot31-lead5 / ( wa_stot31-kzwi1 -
                             wa_stot31-btamt ) * 100.
          wa_stot31-lead6% = wa_stot31-lead6 / ( wa_stot31-kzwi1 -
                             wa_stot31-btamt ) * 100.
          wa_stot31-poout% = wa_stot31-poout / ( wa_stot31-kzwi1 -
                             wa_stot31-btamt ) * 100.
          wa_stot31-btprc% = wa_stot31-btamt / wa_stot31-kzwi1 * 100.
          wa_stot31-stkout% = wa_stot31-stkout / ( wa_stot31-kzwi1 -
                             wa_stot31-btamt ) * 100.
          wa_stot31-cltop% = wa_stot31-cltop / ( wa_stot31-kzwi1 -
                            wa_stot31-btamt ) * 100.
          wa_stot31-salah% = wa_stot31-salah / ( wa_stot31-kzwi1 -
                            wa_stot31-btamt ) * 100.
          wa_stot31-other% = wa_stot31-other / ( wa_stot31-kzwi1 -
                            wa_stot31-btamt ) * 100.
          wa_stot31-reject% = wa_stot31-reject / ( wa_stot31-kzwi1 -
                             wa_stot31-btamt ) * 100.

          PERFORM f_hitung_stot1 USING wa_stot31-kzwi1
                                       wa_stot31-btamt
                                       wa_stot31-kwmeng
                                       wa_stot31-btqty
                                       p_val
                                       '3'.

        ELSE.
          wa_stot31-dlval% = wa_stot31-dlqty / ( wa_stot31-kwmeng -
                             wa_stot31-btqty ) * 100.
          wa_stot31-unprc = wa_stot31-unqty / ( wa_stot31-kwmeng -
                             wa_stot31-btqty ) * 100.
          wa_stot31-lead1% = wa_stot31-lead1q / ( wa_stot31-kwmeng -
                             wa_stot31-btqty ) * 100.
          wa_stot31-lead2% = wa_stot31-lead2q / ( wa_stot31-kwmeng -
                             wa_stot31-btqty ) * 100.
          wa_stot31-lead3% = wa_stot31-lead3q / ( wa_stot31-kwmeng -
                             wa_stot31-btqty ) * 100.
          wa_stot31-lead4% = wa_stot31-lead4q / ( wa_stot31-kwmeng -
                             wa_stot31-btqty ) * 100.
          wa_stot31-lead5% = wa_stot31-lead5q / ( wa_stot31-kwmeng -
                             wa_stot31-btqty ) * 100.
          wa_stot31-lead6% = wa_stot31-lead6q / ( wa_stot31-kwmeng -
                             wa_stot31-btqty ) * 100.
          wa_stot31-poout% = wa_stot31-pooutq / ( wa_stot31-kwmeng -
                             wa_stot31-btqty ) * 100.
          wa_stot31-btprc% = wa_stot31-btqty / wa_stot31-kwmeng * 100.
          wa_stot31-stkout% = wa_stot31-stkoutq / ( wa_stot31-kwmeng -
                             wa_stot31-btqty ) * 100.
          wa_stot31-cltop% = wa_stot31-cltopq / ( wa_stot31-kwmeng -
                            wa_stot31-btqty ) * 100.
          wa_stot31-salah% = wa_stot31-salahq / ( wa_stot31-kwmeng -
                            wa_stot31-btqty ) * 100.
          wa_stot31-other% = wa_stot31-otherq / ( wa_stot31-kwmeng -
                            wa_stot31-btqty ) * 100.
          wa_stot31-reject% = wa_stot31-rejectq / ( wa_stot31-kwmeng -
                             wa_stot31-btqty ) * 100.

          PERFORM f_hitung_stot1 USING wa_stot31-kzwi1
                                       wa_stot31-btamt
                                       wa_stot31-kwmeng
                                       wa_stot31-btqty
                                       p_val
                                       '3'.

        ENDIF.
      ENDIF.

      wa_stot31-dlval = wa_stot31-dlval%.
      IF p_val = 'X'.
        wa_stot31-unval = wa_stot31-unprc.
        wa_stot31-lead1 = wa_stot31-lead1%.
        wa_stot31-lead2 = wa_stot31-lead2%.
        wa_stot31-lead3 = wa_stot31-lead3%.
        wa_stot31-lead4 = wa_stot31-lead4%.
        wa_stot31-lead5 = wa_stot31-lead5%.
        wa_stot31-lead6 = wa_stot31-lead6%.
        wa_stot31-poout = wa_stot31-poout%.
        wa_stot31-btamt = wa_stot31-btprc%.
        wa_stot31-stkout = wa_stot31-stkout%.
        wa_stot31-cltop = wa_stot31-cltop%.
        wa_stot31-salah = wa_stot31-salah%.
        wa_stot31-other = wa_stot31-other%.
        wa_stot31-reject = wa_stot31-reject%.

        PERFORM f_move_stot1 USING p_val '3'.

      ELSE.
        wa_stot31-unqty = wa_stot31-unprc.
        wa_stot31-lead1q = wa_stot31-lead1%.
        wa_stot31-lead2q = wa_stot31-lead2%.
        wa_stot31-lead3q = wa_stot31-lead3%.
        wa_stot31-lead4q = wa_stot31-lead4%.
        wa_stot31-lead5q = wa_stot31-lead5%.
        wa_stot31-lead6q = wa_stot31-lead6%.
        wa_stot31-pooutq = wa_stot31-poout%.
        wa_stot31-btqty = wa_stot31-btprc%.
        wa_stot31-stkoutq = wa_stot31-stkout%.
        wa_stot31-cltopq = wa_stot31-cltop%.
        wa_stot31-salahq = wa_stot31-salah%.
        wa_stot31-otherq = wa_stot31-other%.
        wa_stot31-rejectq = wa_stot31-reject%.

        PERFORM f_move_stot1 USING p_val '3'.

      ENDIF.
      wa_stot31-deci = '2'.
      CLEAR: wa_stot31-curr, wa_stot31-kwmeng,
             wa_stot31-kzwi1, wa_stot31-dlqty.
      APPEND wa_stot31 TO i_output3.
      CLEAR: wa_stot31, wa_stot32, wa_stot33, wa_stot34.
    ENDAT.

  ENDLOOP.

* Total Grand
  wa_gtot3-vkbur = i_output3-vkbur.
  wa_gtot3-vkburt = i_output3-vkburt.
  wa_gtot3-kvgr4 = i_output3-kvgr4.
  wa_gtot3-bezei = i_output3-bezei.
  wa_gtot3-maktx = '**** Grand Total'.
  wa_gtot3-info = 'C71'.
  wa_gtot3-curr = 'IDR'.
  wa_gtot3-index = '60'.
  wa_gtot3-deci = '0'.
  wa_gtot3-prinx = i_output3-princ.
  wa_gtot3-matkx = i_output3-matkl.
  APPEND wa_gtot3 TO i_output3.

  wa_gtot3-maktx = '           Percentage(%)'.
  IF wa_gtot3-kzwi1 NE wa_gtot3-btamt.
    IF p_val = 'X'.
      wa_gtot3-dlval% = wa_gtot3-dlval / ( wa_gtot3-kzwi1 -
                             wa_gtot3-btamt ) * 100.
      wa_gtot3-unprc = wa_gtot3-unval / ( wa_gtot3-kzwi1 -
                             wa_gtot3-btamt ) * 100.
      wa_gtot3-lead1% = wa_gtot3-lead1 / ( wa_gtot3-kzwi1 -
                             wa_gtot3-btamt ) * 100.
      wa_gtot3-lead2% = wa_gtot3-lead2 / ( wa_gtot3-kzwi1 -
                             wa_gtot3-btamt ) * 100.
      wa_gtot3-lead3% = wa_gtot3-lead3 / ( wa_gtot3-kzwi1 -
                             wa_gtot3-btamt ) * 100..
      wa_gtot3-lead4% = wa_gtot3-lead4 / ( wa_gtot3-kzwi1 -
                             wa_gtot3-btamt ) * 100.
      wa_gtot3-lead5% = wa_gtot3-lead5 / ( wa_gtot3-kzwi1 -
                             wa_gtot3-btamt ) * 100.
      wa_gtot3-lead6% = wa_gtot3-lead6 / ( wa_gtot3-kzwi1 -
                             wa_gtot3-btamt ) * 100.
      wa_gtot3-poout% = wa_gtot3-poout / ( wa_gtot3-kzwi1 -
                             wa_gtot3-btamt ) * 100.
      wa_gtot3-btprc% = wa_gtot3-btamt / wa_gtot3-kzwi1 * 100.
      wa_gtot3-stkout% = wa_gtot3-stkout / ( wa_gtot3-kzwi1 -
                             wa_gtot3-btamt ) * 100.
      wa_gtot3-cltop% = wa_gtot3-cltop / ( wa_gtot3-kzwi1 -
                        wa_gtot3-btamt ) * 100.
      wa_gtot3-salah% = wa_gtot3-salah / ( wa_gtot3-kzwi1 -
                        wa_gtot3-btamt ) * 100.
      wa_gtot3-other% = wa_gtot3-other / ( wa_gtot3-kzwi1 -
                        wa_gtot3-btamt ) * 100.
      wa_gtot3-reject% = wa_gtot3-reject / ( wa_gtot3-kzwi1 -
                             wa_gtot3-btamt ) * 100.

      PERFORM f_hitung_gtot USING wa_gtot3-kzwi1
                                   wa_gtot3-btamt
                                   wa_gtot3-kwmeng
                                   wa_gtot3-btqty
                                   p_val
                                   '3'.

    ELSE.
      wa_gtot3-dlval% = wa_gtot3-dlqty / ( wa_gtot3-kwmeng -
                        wa_gtot3-btqty ) * 100.
      wa_gtot3-unprc = wa_gtot3-unqty / ( wa_gtot3-kwmeng -
                             wa_gtot3-btqty ) * 100.
      wa_gtot3-lead1% = wa_gtot3-lead1q / ( wa_gtot3-kwmeng -
                             wa_gtot3-btqty ) * 100.
      wa_gtot3-lead2% = wa_gtot3-lead2q / ( wa_gtot3-kwmeng -
                             wa_gtot3-btqty ) * 100.
      wa_gtot3-lead3% = wa_gtot3-lead3q / ( wa_gtot3-kwmeng -
                             wa_gtot3-btqty ) * 100..
      wa_gtot3-lead4% = wa_gtot3-lead4q / ( wa_gtot3-kwmeng -
                             wa_gtot3-btqty ) * 100.
      wa_gtot3-lead5% = wa_gtot3-lead5q / ( wa_gtot3-kwmeng -
                             wa_gtot3-btqty ) * 100.
      wa_gtot3-lead6% = wa_gtot3-lead6q / ( wa_gtot3-kwmeng -
                             wa_gtot3-btqty ) * 100.
      wa_gtot3-poout% = wa_gtot3-pooutq / ( wa_gtot3-kwmeng -
                             wa_gtot3-btqty ) * 100.
      wa_gtot3-btprc% = wa_gtot3-btqty / wa_gtot3-kwmeng * 100.
      wa_gtot3-stkout% = wa_gtot3-stkoutq / ( wa_gtot3-kwmeng -
                             wa_gtot3-btqty ) * 100.
      wa_gtot3-cltop% = wa_gtot3-cltopq / ( wa_gtot3-kwmeng -
                        wa_gtot3-btqty ) * 100.
      wa_gtot3-salah% = wa_gtot3-salahq / ( wa_gtot3-kwmeng -
                        wa_gtot3-btqty ) * 100.
      wa_gtot3-other% = wa_gtot3-otherq / ( wa_gtot3-kwmeng -
                        wa_gtot3-btqty ) * 100.
      wa_gtot3-reject% = wa_gtot3-rejectq / ( wa_gtot3-kwmeng -
                             wa_gtot3-btqty ) * 100.

      PERFORM f_hitung_gtot USING wa_gtot3-kzwi1
                                   wa_gtot3-btamt
                                   wa_gtot3-kwmeng
                                   wa_gtot3-btqty
                                   p_val
                                   '3'.

    ENDIF.
  ENDIF.

  wa_gtot3-dlval = wa_gtot3-dlval%.
  IF p_val = 'X'.
    wa_gtot3-unval = wa_gtot3-unprc.
    wa_gtot3-lead1 = wa_gtot3-lead1%.
    wa_gtot3-lead2 = wa_gtot3-lead2%.
    wa_gtot3-lead3 = wa_gtot3-lead3%.
    wa_gtot3-lead4 = wa_gtot3-lead4%.
    wa_gtot3-lead5 = wa_gtot3-lead5%.
    wa_gtot3-lead6 = wa_gtot3-lead6%.
    wa_gtot3-poout = wa_gtot3-poout%.
    wa_gtot3-btamt = wa_gtot3-btprc%.
    wa_gtot3-cltop = wa_gtot3-cltop%.
    wa_gtot3-salah = wa_gtot3-salah%.
    wa_gtot3-other = wa_gtot3-other%.
    wa_gtot3-stkout = wa_gtot3-stkout%.
    wa_gtot3-reject = wa_gtot3-reject%.

    PERFORM f_move_gtot USING p_val '3'.

  ELSE.
    wa_gtot3-unqty = wa_gtot3-unprc.
    wa_gtot3-lead1q = wa_gtot3-lead1%.
    wa_gtot3-lead2q = wa_gtot3-lead2%.
    wa_gtot3-lead3q = wa_gtot3-lead3%.
    wa_gtot3-lead4q = wa_gtot3-lead4%.
    wa_gtot3-lead5q = wa_gtot3-lead5%.
    wa_gtot3-lead6q = wa_gtot3-lead6%.
    wa_gtot3-pooutq = wa_gtot3-poout%.
    wa_gtot3-btqty = wa_gtot3-btprc%.
    wa_gtot3-cltopq = wa_gtot3-cltop%.
    wa_gtot3-salahq = wa_gtot3-salah%.
    wa_gtot3-otherq = wa_gtot3-other%.
    wa_gtot3-stkoutq = wa_gtot3-stkout%.
    wa_gtot3-rejectq = wa_gtot3-reject%.

    PERFORM f_move_gtot USING p_val '3'.

  ENDIF.
  wa_gtot3-deci = '2'.
  CLEAR: wa_gtot3-curr, wa_gtot3-kwmeng,
         wa_gtot3-kzwi1, wa_gtot3-dlqty.
  APPEND wa_gtot3 TO i_output3.
  CLEAR: wa_gtot3.

  IF p_total3 = 'X'.
    DELETE i_output3 WHERE index LT '40'.
  ELSEIF p_total7 = 'X'.
    DELETE i_output3 WHERE index LT '50'.
  ENDIF.

ENDFORM.                    " proses_data3

*&---------------------------------------------------------------------*
*&      Form  append_itab3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_itab3.

  DATA : l_crdat  LIKE  zmm_cust_rec-crdat,
         l_leadt  TYPE  i.

  MOVE-CORRESPONDING i_detquot3 TO i_output3.

  IF NOT i_detdelv-vbeln IS INITIAL.
    i_output3-dlqty = i_detsales-kwmeng.
    i_output3-dlval = i_detsales-kzwi1.
    i_output3-unqty = i_output3-kwmeng - i_output3-dlqty.
    i_output3-unval = i_output3-kzwi1 - i_output3-dlval.

    IF i_output3-unqty LT 0.
      CLEAR: i_output3-unqty,i_output3-unval.
    ENDIF.

    SELECT SINGLE crdat FROM zmm_cust_rec
      INTO l_crdat
      WHERE vbeln = i_detdelv-vbeln.

    IF l_crdat IS INITIAL.
      i_output3-lead6q = i_output3-dlqty.
      i_output3-lead6 = i_output3-dlval.
    ELSE.
      l_leadt = l_crdat - i_detquot3-bstdk.
      IF l_leadt LE 3.
        i_output3-lead1q = i_output3-dlqty.
        i_output3-lead1 = i_output3-dlval.
      ELSEIF l_leadt = 4.
        i_output3-lead2q = i_output3-dlqty.
        i_output3-lead2 = i_output3-dlval.
      ELSEIF l_leadt GE 5.
        i_output3-lead3q = i_output3-dlqty.
        i_output3-lead3 = i_output3-dlval.
*      ELSEIF l_leadt GE 6.
*        i_output3-lead4 = i_output3-dlval.
*      ELSEIF l_leadt GE 7.
*        i_output3-lead5 = i_output3-dlval.
      ENDIF.
    ENDIF.
  ELSE.
    IF i_detsales-vbeln IS INITIAL.
      i_output3-unqty = i_output3-kwmeng.
      i_output3-unval = i_output3-kzwi1.
    ELSE.
      IF NOT i_detquot3-abgru IS INITIAL.
        i_output3-unqty = i_output3-kwmeng.
        i_output3-unval = i_output3-kzwi1.
      ELSE.
        i_output3-pooutq = i_output3-kwmeng.
        i_output3-poout = i_output3-kzwi1.
      ENDIF.
    ENDIF.
  ENDIF.


  PERFORM f_reason_for_rejection USING i_detquot3-abgru
                                       i_output3-unqty
                                       i_output3-unval
                                       '3'.

  SELECT SINGLE bezei INTO i_output3-bezei
    FROM tvv4t
    WHERE spras = sy-langu AND
          kvgr4 = i_output3-kvgr4.

  SELECT SINGLE bezei FROM tvkbt
    INTO i_output3-vkburt
    WHERE spras = sy-langu AND
          vkbur = i_output3-vkbur.

  i_output3-reject = i_output3-unval - i_output3-stkout.

  PERFORM hitung_total3.

  i_output3-curr = 'IDR'.
  i_output3-index = '10'.
  i_output3-deci = '0'.
  i_output3-prinx = i_output3-princ.
  i_output3-matkx = i_output3-matkl.

  COLLECT i_output3.

ENDFORM.              " append_itab3

*&---------------------------------------------------------------------*
*&      Form  hitung_total3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hitung_total3.

  ADD i_output3-kwmeng TO wa_stot31-kwmeng.
  ADD i_output3-kwmeng TO wa_stot32-kwmeng.
  ADD i_output3-kwmeng TO wa_stot33-kwmeng.
  ADD i_output3-kwmeng TO wa_stot34-kwmeng.
  ADD i_output3-kwmeng TO wa_gtot3-kwmeng.
  ADD i_output3-kzwi1 TO wa_stot31-kzwi1.
  ADD i_output3-kzwi1 TO wa_stot32-kzwi1.
  ADD i_output3-kzwi1 TO wa_stot33-kzwi1.
  ADD i_output3-kzwi1 TO wa_stot34-kzwi1.
  ADD i_output3-kzwi1 TO wa_gtot3-kzwi1.
  ADD i_output3-dlqty TO wa_stot31-dlqty.
  ADD i_output3-dlqty TO wa_stot32-dlqty.
  ADD i_output3-dlqty TO wa_stot33-dlqty.
  ADD i_output3-dlqty TO wa_stot34-dlqty.
  ADD i_output3-dlqty TO wa_gtot3-dlqty.
  ADD i_output3-dlval TO wa_stot31-dlval.
  ADD i_output3-dlval TO wa_stot32-dlval.
  ADD i_output3-dlval TO wa_stot33-dlval.
  ADD i_output3-dlval TO wa_stot34-dlval.
  ADD i_output3-dlval TO wa_gtot3-dlval.
  ADD i_output3-unqty TO wa_stot31-unqty.
  ADD i_output3-unqty TO wa_stot32-unqty.
  ADD i_output3-unqty TO wa_stot33-unqty.
  ADD i_output3-unqty TO wa_stot34-unqty.
  ADD i_output3-unqty TO wa_gtot3-unqty.
  ADD i_output3-unval TO wa_stot31-unval.
  ADD i_output3-unval TO wa_stot32-unval.
  ADD i_output3-unval TO wa_stot33-unval.
  ADD i_output3-unval TO wa_stot34-unval.
  ADD i_output3-unval TO wa_gtot3-unval.
  ADD i_output3-lead1q TO wa_stot31-lead1q.
  ADD i_output3-lead1q TO wa_stot32-lead1q.
  ADD i_output3-lead1q TO wa_stot33-lead1q.
  ADD i_output3-lead1q TO wa_stot34-lead1q.
  ADD i_output3-lead1q TO wa_gtot3-lead1q.
  ADD i_output3-lead1 TO wa_stot31-lead1.
  ADD i_output3-lead1 TO wa_stot32-lead1.
  ADD i_output3-lead1 TO wa_stot33-lead1.
  ADD i_output3-lead1 TO wa_stot34-lead1.
  ADD i_output3-lead1 TO wa_gtot3-lead1.
  ADD i_output3-lead2 TO wa_stot31-lead2q.
  ADD i_output3-lead2 TO wa_stot32-lead2q.
  ADD i_output3-lead2 TO wa_stot33-lead2q.
  ADD i_output3-lead2 TO wa_stot34-lead2q.
  ADD i_output3-lead2 TO wa_gtot3-lead2q.
  ADD i_output3-lead2 TO wa_stot31-lead2.
  ADD i_output3-lead2 TO wa_stot32-lead2.
  ADD i_output3-lead2 TO wa_stot33-lead2.
  ADD i_output3-lead2 TO wa_stot34-lead2.
  ADD i_output3-lead2 TO wa_gtot3-lead2.
  ADD i_output3-lead3q TO wa_stot31-lead3q.
  ADD i_output3-lead3q TO wa_stot32-lead3q.
  ADD i_output3-lead3q TO wa_stot33-lead3q.
  ADD i_output3-lead3q TO wa_stot34-lead3q.
  ADD i_output3-lead3q TO wa_gtot3-lead3q.
  ADD i_output3-lead3 TO wa_stot31-lead3.
  ADD i_output3-lead3 TO wa_stot32-lead3.
  ADD i_output3-lead3 TO wa_stot33-lead3.
  ADD i_output3-lead3 TO wa_stot34-lead3.
  ADD i_output3-lead3 TO wa_gtot3-lead3.
  ADD i_output3-lead4q TO wa_stot31-lead4q.
  ADD i_output3-lead4q TO wa_stot32-lead4q.
  ADD i_output3-lead4q TO wa_stot33-lead4q.
  ADD i_output3-lead4q TO wa_stot34-lead4q.
  ADD i_output3-lead4q TO wa_gtot3-lead4q.
  ADD i_output3-lead4 TO wa_stot31-lead4.
  ADD i_output3-lead4 TO wa_stot32-lead4.
  ADD i_output3-lead4 TO wa_stot33-lead4.
  ADD i_output3-lead4 TO wa_stot34-lead4.
  ADD i_output3-lead4 TO wa_gtot3-lead4.
  ADD i_output3-lead5q TO wa_stot31-lead5q.
  ADD i_output3-lead5q TO wa_stot32-lead5q.
  ADD i_output3-lead5q TO wa_stot33-lead5q.
  ADD i_output3-lead5q TO wa_stot34-lead5q.
  ADD i_output3-lead5q TO wa_gtot3-lead5q.
  ADD i_output3-lead5 TO wa_stot31-lead5.
  ADD i_output3-lead5 TO wa_stot32-lead5.
  ADD i_output3-lead5 TO wa_stot33-lead5.
  ADD i_output3-lead5 TO wa_stot34-lead5.
  ADD i_output3-lead5 TO wa_gtot3-lead5.
  ADD i_output3-lead6q TO wa_stot31-lead6q.
  ADD i_output3-lead6q TO wa_stot32-lead6q.
  ADD i_output3-lead6q TO wa_stot33-lead6q.
  ADD i_output3-lead6q TO wa_stot34-lead6q.
  ADD i_output3-lead6q TO wa_gtot3-lead6q.
  ADD i_output3-lead6 TO wa_stot31-lead6.
  ADD i_output3-lead6 TO wa_stot32-lead6.
  ADD i_output3-lead6 TO wa_stot33-lead6.
  ADD i_output3-lead6 TO wa_stot34-lead6.
  ADD i_output3-lead6 TO wa_gtot3-lead6.
  ADD i_output3-stkoutq TO wa_stot31-stkoutq.
  ADD i_output3-stkoutq TO wa_stot32-stkoutq.
  ADD i_output3-stkoutq TO wa_stot33-stkoutq.
  ADD i_output3-stkoutq TO wa_stot34-stkoutq.
  ADD i_output3-stkoutq TO wa_gtot3-stkoutq.
  ADD i_output3-stkout TO wa_stot31-stkout.
  ADD i_output3-stkout TO wa_stot32-stkout.
  ADD i_output3-stkout TO wa_stot33-stkout.
  ADD i_output3-stkout TO wa_stot34-stkout.
  ADD i_output3-stkout TO wa_gtot3-stkout.
  ADD i_output3-cltopq TO wa_stot31-cltopq.
  ADD i_output3-cltopq TO wa_stot32-cltopq.
  ADD i_output3-cltopq TO wa_stot33-cltopq.
  ADD i_output3-cltopq TO wa_stot34-cltopq.
  ADD i_output3-cltopq TO wa_gtot3-cltopq.
  ADD i_output3-cltop TO wa_stot31-cltop.
  ADD i_output3-cltop TO wa_stot32-cltop.
  ADD i_output3-cltop TO wa_stot33-cltop.
  ADD i_output3-cltop TO wa_stot34-cltop.
  ADD i_output3-cltop TO wa_gtot3-cltop.
  ADD i_output3-salahq TO wa_stot31-salahq.
  ADD i_output3-salahq TO wa_stot32-salahq.
  ADD i_output3-salahq TO wa_stot33-salahq.
  ADD i_output3-salahq TO wa_stot34-salahq.
  ADD i_output3-salahq TO wa_gtot3-salahq.
  ADD i_output3-salah TO wa_stot31-salah.
  ADD i_output3-salah TO wa_stot32-salah.
  ADD i_output3-salah TO wa_stot33-salah.
  ADD i_output3-salah TO wa_stot34-salah.
  ADD i_output3-salah TO wa_gtot3-salah.
  ADD i_output3-otherq TO wa_stot31-otherq.
  ADD i_output3-otherq TO wa_stot32-otherq.
  ADD i_output3-otherq TO wa_stot33-otherq.
  ADD i_output3-otherq TO wa_stot34-otherq.
  ADD i_output3-otherq TO wa_gtot3-otherq.
  ADD i_output3-other TO wa_stot31-other.
  ADD i_output3-other TO wa_stot32-other.
  ADD i_output3-other TO wa_stot33-other.
  ADD i_output3-other TO wa_stot34-other.
  ADD i_output3-other TO wa_gtot3-other.
  ADD i_output3-rejectq TO wa_stot31-rejectq.
  ADD i_output3-rejectq TO wa_stot32-rejectq.
  ADD i_output3-rejectq TO wa_stot33-rejectq.
  ADD i_output3-rejectq TO wa_stot34-rejectq.
  ADD i_output3-rejectq TO wa_gtot3-rejectq.
  ADD i_output3-reject TO wa_stot31-reject.
  ADD i_output3-reject TO wa_stot32-reject.
  ADD i_output3-reject TO wa_stot33-reject.
  ADD i_output3-reject TO wa_stot34-reject.
  ADD i_output3-reject TO wa_gtot3-reject.
  ADD i_output3-pooutq TO wa_stot31-pooutq.
  ADD i_output3-pooutq TO wa_stot32-pooutq.
  ADD i_output3-pooutq TO wa_stot33-pooutq.
  ADD i_output3-pooutq TO wa_stot34-pooutq.
  ADD i_output3-pooutq TO wa_gtot3-pooutq.
  ADD i_output3-poout TO wa_stot31-poout.
  ADD i_output3-poout TO wa_stot32-poout.
  ADD i_output3-poout TO wa_stot33-poout.
  ADD i_output3-poout TO wa_stot34-poout.
  ADD i_output3-poout TO wa_gtot3-poout.
  ADD i_output3-btqty TO wa_stot31-btqty.
  ADD i_output3-btqty TO wa_stot32-btqty.
  ADD i_output3-btqty TO wa_stot33-btqty.
  ADD i_output3-btqty TO wa_stot34-btqty.
  ADD i_output3-btqty TO wa_gtot3-btqty.
  ADD i_output3-btamt TO wa_stot31-btamt.
  ADD i_output3-btamt TO wa_stot32-btamt.
  ADD i_output3-btamt TO wa_stot33-btamt.
  ADD i_output3-btamt TO wa_stot34-btamt.
  ADD i_output3-btamt TO wa_gtot3-btamt.

  PERFORM f_hitung_total USING '3'.

ENDFORM.                    " hitung_total3

*&---------------------------------------------------------------------*
*&      Form  f_build_fieldcat3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_fieldcat3.
  DEFINE mac_header3.
    read table t_abgru index &1.
    if sy-subrc eq 0.
      if p_val = 'X'.
        fieldcat-fieldname = 'VAL&1'.
        fieldcat-ref_fieldname = ''.
        fieldcat-tabname = 'I_OUTPUT3'.
        fieldcat-outputlen = 15.
        fieldcat-cfieldname = 'CURR'.
        fieldcat-seltext_s = t_abgru-bezei.
        fieldcat-seltext_m = t_abgru-bezei.
        fieldcat-seltext_l = t_abgru-bezei.
        append fieldcat. "clear fieldcat.
      else.
        fieldcat-fieldname = 'QTY&1'.
        fieldcat-ref_fieldname = ''.
        fieldcat-tabname = 'I_OUTPUT3'.
        fieldcat-outputlen = 15.
        fieldcat-decimalsfieldname = 'DECI'.
        fieldcat-seltext_s = t_abgru-bezei.
        fieldcat-seltext_m = t_abgru-bezei.
        fieldcat-seltext_l = t_abgru-bezei.
        append fieldcat. "clear fieldcat.
      endif.
    endif.
  END-OF-DEFINITION.

  fieldcat-fieldname = 'PRINC'.
  fieldcat-ref_fieldname = 'PRINC'.
  fieldcat-tabname = 'I_OUTPUT3'.
  fieldcat-outputlen = 6.
  fieldcat-seltext_s = 'Princp'.
  fieldcat-seltext_m = 'Principal'.
  fieldcat-seltext_l = 'Principal'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'MATKL'.
  fieldcat-ref_fieldname = 'MATKL'.
  fieldcat-tabname = 'I_OUTPUT3'.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'Mat Group'.
  fieldcat-seltext_m = 'Material Group'.
  fieldcat-seltext_l = 'Material Group'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'MATNR'.
  fieldcat-ref_fieldname = 'MATNR'.
  fieldcat-tabname = 'I_OUTPUT3'.
  fieldcat-outputlen = 11.
  fieldcat-seltext_s = 'Material'.
  fieldcat-seltext_m = 'Material'.
  fieldcat-seltext_l = 'Material'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'MAKTX'.
  fieldcat-ref_fieldname = 'MAKTX'.
  fieldcat-tabname = 'I_OUTPUT3'.
  fieldcat-outputlen = 25.
  fieldcat-seltext_s = 'Material Desc'.
  fieldcat-seltext_m = 'Material Desc'.
  fieldcat-seltext_l = 'Material Descriptions'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'KWMENG'.
  fieldcat-ref_fieldname = 'KWMENG'.
  fieldcat-tabname = 'I_OUTPUT3'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'PO Qty'.
  fieldcat-seltext_m = 'PO Quantity'.
  fieldcat-seltext_l = 'PO Quantity'.
  fieldcat-decimals_out = '0'.
  fieldcat-no_zero = 'X'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'KZWI1'.
  fieldcat-ref_fieldname = 'KZWI1'.
  fieldcat-tabname = 'I_OUTPUT3'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'PO Amount'.
  fieldcat-seltext_m = 'PO Amount'.
  fieldcat-seltext_l = 'PO Amount'.
  fieldcat-currency = 'IDR'.
  fieldcat-decimals_out = '0'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out.

*  IF p_val = 'X'.
*    fieldcat-fieldname = 'BTAMT'.
*    fieldcat-ref_fieldname = 'BTAMT'.
*    fieldcat-tabname = 'I_OUTPUT3'.
*    fieldcat-outputlen = 13.
*    fieldcat-seltext_s = 'PO Batal'.
*    fieldcat-seltext_m = 'PO Batal'.
*    fieldcat-seltext_l = 'PO Batal'.
*    fieldcat-cfieldname = 'CURR'.
*    APPEND fieldcat. "clear fieldcat.
*  ELSE.
*    fieldcat-fieldname = 'BTQTY'.
*    fieldcat-ref_fieldname = 'BTQTY'.
*    fieldcat-tabname = 'I_OUTPUT3'.
*    fieldcat-outputlen = 13.
*    fieldcat-seltext_s = 'PO Batal'.
*    fieldcat-seltext_m = 'PO Batal'.
*    fieldcat-seltext_l = 'PO Batal'.
*    fieldcat-decimalsfieldname = 'DECI'.
*    APPEND fieldcat. "clear fieldcat.
*  ENDIF.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname,
         fieldcat-decimalsfieldname.

  fieldcat-fieldname = 'DLQTY'.
  fieldcat-ref_fieldname = 'DLQTY'.
  fieldcat-tabname = 'I_OUTPUT3'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'DO Qty'.
  fieldcat-seltext_m = 'DO Quantity'.
  fieldcat-seltext_l = 'DO Quantity'.
  fieldcat-decimals_out = '0'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname.

  fieldcat-fieldname = 'DLVAL'.
  fieldcat-ref_fieldname = 'DLVAL'.
  fieldcat-tabname = 'I_OUTPUT3'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'DO Amount'.
  fieldcat-seltext_m = 'DO Amount'.
  fieldcat-seltext_l = 'DO Amount'.
  fieldcat-cfieldname = 'CURR'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname.

  IF p_val = 'X'.
    fieldcat-fieldname = 'LEAD6'.
    fieldcat-ref_fieldname = 'LEAD6'.
    fieldcat-tabname = 'I_OUTPUT3'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Intransit'.
    fieldcat-seltext_m = 'Intransit'.
    fieldcat-seltext_l = 'Intransit'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD1'.
    fieldcat-ref_fieldname = 'LEAD1'.
    fieldcat-tabname = 'I_OUTPUT3'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead <= 3'.
    fieldcat-seltext_m = 'Lead <= 3'.
    fieldcat-seltext_l = 'Lead <= 3'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD2'.
    fieldcat-ref_fieldname = 'LEAD2'.
    fieldcat-tabname = 'I_OUTPUT3'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead = 4'.
    fieldcat-seltext_m = 'Lead = 4'.
    fieldcat-seltext_l = 'Lead = 4'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD3'.
    fieldcat-ref_fieldname = 'LEAD3'.
    fieldcat-tabname = 'I_OUTPUT3'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead >= 5'.
    fieldcat-seltext_m = 'Lead >= 5'.
    fieldcat-seltext_l = 'Lead >= 5'.
    APPEND fieldcat. "clear fieldcat.
  ELSE.
    fieldcat-fieldname = 'LEAD6Q'.
    fieldcat-ref_fieldname = 'LEAD6Q'.
    fieldcat-tabname = 'I_OUTPUT3'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Intransit'.
    fieldcat-seltext_m = 'Intransit'.
    fieldcat-seltext_l = 'Intransit'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD1Q'.
    fieldcat-ref_fieldname = 'LEAD1Q'.
    fieldcat-tabname = 'I_OUTPUT3'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead <= 3'.
    fieldcat-seltext_m = 'Lead <= 3'.
    fieldcat-seltext_l = 'Lead <= 3'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD2Q'.
    fieldcat-ref_fieldname = 'LEAD2Q'.
    fieldcat-tabname = 'I_OUTPUT3'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead = 4'.
    fieldcat-seltext_m = 'Lead = 4'.
    fieldcat-seltext_l = 'Lead = 4'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD3Q'.
    fieldcat-ref_fieldname = 'LEAD3Q'.
    fieldcat-tabname = 'I_OUTPUT3'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead >= 5'.
    fieldcat-seltext_m = 'Lead >= 5'.
    fieldcat-seltext_l = 'Lead >= 5'.
    APPEND fieldcat. "clear fieldcat.
  ENDIF.

*  fieldcat-fieldname = 'LEAD4'.
*  fieldcat-ref_fieldname = 'LEAD4'.
*  fieldcat-tabname = 'I_OUTPUT3'.
*  fieldcat-outputlen = 13.
*  fieldcat-cfieldname = 'CURR'.
*  fieldcat-seltext_s = 'Lead >= 6'.
*  fieldcat-seltext_m = 'Lead >= 6'.
*  fieldcat-seltext_l = 'Lead >= 6'.
*  APPEND fieldcat. "clear fieldcat.

*  fieldcat-fieldname = 'LEAD5'.
*  fieldcat-ref_fieldname = 'LEAD5'.
*  fieldcat-tabname = 'I_OUTPUT3'.
*  fieldcat-outputlen = 13.
*  fieldcat-cfieldname = 'CURR'.
*  fieldcat-seltext_s = 'Lead >= 7'.
*  fieldcat-seltext_m = 'Lead => 7'.
*  fieldcat-seltext_l = 'Lead => 7'.
*  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname,
         fieldcat-decimalsfieldname.

  IF p_val = 'X'.
    fieldcat-fieldname = 'UNVAL'.
    fieldcat-ref_fieldname = 'UNVAL'.
    fieldcat-tabname = 'I_OUTPUT3'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Undlv Amount'.
    fieldcat-seltext_m = 'Undelivered Amount'.
    fieldcat-seltext_l = 'Undelivered Amount'.
    APPEND fieldcat. "clear fieldcat.

*    fieldcat-fieldname = 'CLTOP'.
*    fieldcat-ref_fieldname = 'CLTOP'.
*    fieldcat-tabname = 'I_OUTPUT3'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'CL / TOP'.
*    fieldcat-seltext_m = 'CL / TOP'.
*    fieldcat-seltext_l = 'CL / TOP'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'STKOUT'.
*    fieldcat-ref_fieldname = 'STKOUT'.
*    fieldcat-tabname = 'I_OUTPUT3'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Stock Out'.
*    fieldcat-seltext_m = 'Stock Out'.
*    fieldcat-seltext_l = 'Stock Out'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'SALAH'.
*    fieldcat-ref_fieldname = 'SALAH'.
*    fieldcat-tabname = 'I_OUTPUT3'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Salah Harga'.
*    fieldcat-seltext_m = 'Salah Harga'.
*    fieldcat-seltext_l = 'Salah Harga'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'OTHER'.
*    fieldcat-ref_fieldname = 'OTHER'.
*    fieldcat-tabname = 'I_OUTPUT3'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Other'.
*    fieldcat-seltext_m = 'Other'.
*    fieldcat-seltext_l = 'Other'.
*    APPEND fieldcat. "clear fieldcat.
*
**  fieldcat-fieldname = 'REJECT'.
**  fieldcat-ref_fieldname = 'REJECT'.
**  fieldcat-tabname = 'I_OUTPUT3'.
**  fieldcat-outputlen = 11.
**  fieldcat-cfieldname = 'CURR'.
**  fieldcat-seltext_s = 'CL / TOP'.
**  fieldcat-seltext_m = 'CL / TOP'.
**  fieldcat-seltext_l = 'CL / TOP'.
**  APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'POOUT'.
*    fieldcat-ref_fieldname = 'POOUT'.
*    fieldcat-tabname = 'I_OUTPUT3'.
*    fieldcat-outputlen = 13.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'PO Outs'.
*    fieldcat-seltext_m = 'PO Outstanding'.
*    fieldcat-seltext_l = 'PO Outstanding'.
*    APPEND fieldcat. "clear fieldcat.
  ELSE.
    fieldcat-fieldname = 'UNQTY'.
    fieldcat-ref_fieldname = 'UNQTY'.
    fieldcat-tabname = 'I_OUTPUT3'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Undlv Qty'.
    fieldcat-seltext_m = 'Undelivered Quantity'.
    fieldcat-seltext_l = 'Undelivered Quantity'.
    APPEND fieldcat. "clear fieldcat.

*    fieldcat-fieldname = 'CLTOPQ'.
*    fieldcat-ref_fieldname = 'CLTOPQ'.
*    fieldcat-tabname = 'I_OUTPUT3'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'CL / TOP'.
*    fieldcat-seltext_m = 'CL / TOP'.
*    fieldcat-seltext_l = 'CL / TOP'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'STKOUTQ'.
*    fieldcat-ref_fieldname = 'STKOUTQ'.
*    fieldcat-tabname = 'I_OUTPUT3'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Stock Out'.
*    fieldcat-seltext_m = 'Stock Out'.
*    fieldcat-seltext_l = 'Stock Out'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'SALAHQ'.
*    fieldcat-ref_fieldname = 'SALAHQ'.
*    fieldcat-tabname = 'I_OUTPUT3'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Salah Harga'.
*    fieldcat-seltext_m = 'Salah Harga'.
*    fieldcat-seltext_l = 'Salah Harga'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'OTHERQ'.
*    fieldcat-ref_fieldname = 'OTHERQ'.
*    fieldcat-tabname = 'I_OUTPUT3'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Other'.
*    fieldcat-seltext_m = 'Other'.
*    fieldcat-seltext_l = 'Other'.
*    APPEND fieldcat. "clear fieldcat.
*
**  fieldcat-fieldname = 'REJECTQ'.
**  fieldcat-ref_fieldname = 'REJECTQ'.
**  fieldcat-tabname = 'I_OUTPUT3'.
**  fieldcat-outputlen = 11.
**    fieldcat-decimalsfieldname = 'DECI'.
**  fieldcat-seltext_s = 'CL / TOP'.
**  fieldcat-seltext_m = 'CL / TOP'.
**  fieldcat-seltext_l = 'CL / TOP'.
**  APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'POOUTQ'.
*    fieldcat-ref_fieldname = 'POOUTQ'.
*    fieldcat-tabname = 'I_OUTPUT3'.
*    fieldcat-outputlen = 13.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'PO Outs'.
*    fieldcat-seltext_m = 'PO Outstanding'.
*    fieldcat-seltext_l = 'PO Outstanding'.
*    APPEND fieldcat. "clear fieldcat.
  ENDIF.

  mac_header3 : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.

ENDFORM.                    " f_build_fieldcat3

*&---------------------------------------------------------------------*
*&      Form  f_build_sortfield3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_SORT
*----------------------------------------------------------------------*
FORM f_build_sortfield3 USING fu_sort TYPE slis_t_sortinfo_alv.

  DATA: ld_sort TYPE slis_sortinfo_alv.

  IF NOT p_total3 IS INITIAL.
    CLEAR ld_sort.
    ld_sort-fieldname = 'VKBUR'.
    ld_sort-up        = 'X'.
    ld_sort-group     = '*'.
    ld_sort-spos      = '01'.
    APPEND ld_sort TO fu_sort.
    CLEAR ld_sort.
    ld_sort-fieldname = 'KVGR4'.
    ld_sort-up        = 'X'.
*  ld_sort-group     = '*'.
    ld_sort-spos      = '02'.
    APPEND ld_sort TO fu_sort.

  ELSEIF NOT p_total7 IS INITIAL.
    CLEAR ld_sort.
    ld_sort-fieldname = 'VKBUR'.
    ld_sort-up        = 'X'.
*    ld_sort-group     = '*'.
    ld_sort-spos      = '01'.
    APPEND ld_sort TO fu_sort.
    CLEAR ld_sort.
    ld_sort-fieldname = 'KVGR4'.
    ld_sort-up        = 'X'.
*  ld_sort-group     = '*'.
    ld_sort-spos      = '02'.
    APPEND ld_sort TO fu_sort.

  ELSE.
    CLEAR ld_sort.
    ld_sort-fieldname = 'VKBUR'.
    ld_sort-up        = 'X'.
    ld_sort-group     = '*'.
    ld_sort-spos      = '01'.
    APPEND ld_sort TO fu_sort.
    CLEAR ld_sort.
    ld_sort-fieldname = 'KVGR4'.
    ld_sort-up        = 'X'.
    ld_sort-group     = '*'.
    ld_sort-spos      = '02'.
    APPEND ld_sort TO fu_sort.
  ENDIF.

  CLEAR ld_sort.
  ld_sort-fieldname = 'PRINX'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
  ld_sort-spos      = '03'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'MATKX'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
  ld_sort-spos      = '04'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'INDEX'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-spos      = '05'.
  APPEND ld_sort TO fu_sort.

ENDFORM.                    " f_build_sortfield3

*&---------------------------------------------------------------------*
*&      Form  f_build_event3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_EVENTS
*----------------------------------------------------------------------*
FORM f_build_event3 TABLES ft_events LIKE t_events.

  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE3'.
  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_end_of_list.
*  ft_events-form = 'F_END_OF_LIST3'.
*  APPEND ft_events.

ENDFORM.                    " f_build_event3

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE3                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page3.

  DATA : l_line1(70),
         l_line2(60),
         l_sloff(80),
         l_cust(80),
         l_fdate(10),
         l_tdate(10).

  WRITE s_erdat-low TO l_fdate.
  WRITE s_erdat-high TO l_tdate.
*--- Title
  CONCATENATE sy-title 'By Branch, Key Account Grp, Material Grp' '(03)'
                                         INTO l_line1 SEPARATED BY space.
*--- Period
  CONCATENATE 'Period :' l_fdate 'to' l_tdate
              INTO l_line2 SEPARATED BY space.

  IF NOT p_total3 IS INITIAL.
*--- Sales Office
    CONCATENATE 'Sales Office    :' i_output3-vkbur i_output3-vkburt
                INTO l_sloff SEPARATED BY space.
    l_cust = 'SUMMARY'.
  ELSEIF NOT p_total7 IS INITIAL.
*--- Sales Office
    l_sloff = 'SUMMARY'.
    CLEAR l_cust.
  ELSE.
*--- Sales Office
    CONCATENATE 'Sales Office    :' i_output3-vkbur i_output3-vkburt
                INTO l_sloff SEPARATED BY space.
*--- Group Customer
    CONCATENATE 'Key Account Grp :' i_output3-kvgr4 i_output3-bezei
                INTO l_cust SEPARATED BY space.
  ENDIF.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING l_line1.
  PERFORM f_hdr_line2 USING l_sloff l_line2.
  PERFORM f_hdr_line3 USING l_cust va_text.
  PERFORM f_hdr_uline.

ENDFORM.                    "f_top_of_page3

*&---------------------------------------------------------------------*
*&      Form  proses_data5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proses_data5.

  SORT i_detquot5  BY matkl kvgr4 vkbur knkli.
*  SORT i_detsales BY vgbel posnr.
  SORT i_detsales BY vgbel vgpos.
  SORT i_detdelv  BY vgbel vgpos.
  LOOP AT i_detquot5.

    CLEAR : i_detsales, i_detdelv, i_output5. ", i_detquot5-abgru.

    READ TABLE i_detsales WITH KEY
                               vgbel = i_detquot5-vbeln
*                               posnr = i_detquot5-posnr BINARY SEARCH.
                               vgpos = i_detquot5-posnr. " BINARY SEARCH.
    IF sy-subrc = 0.
      IF i_detsales-abgru IS NOT INITIAL.
        i_detquot5-abgru = i_detsales-abgru.
      ENDIF.
    ENDIF.

    READ TABLE i_detdelv WITH KEY
                              vgbel = i_detsales-vbeln
                              vgpos = i_detsales-posnr. " BINARY SEARCH.

    PERFORM append_itab5.

* Total Sales Office
    AT END OF vkbur.
      wa_stot53-matkl = i_output5-matkl.
      wa_stot53-kvgr4 = i_output5-kvgr4.
      wa_stot53-bezei = i_output5-bezei.
      CONCATENATE '*    Total' i_output5-vkbur
                  INTO wa_stot53-name1 SEPARATED BY space.
      wa_stot53-info = 'C30'.
      wa_stot53-curr = 'IDR'.
      wa_stot53-index = '20'.
      wa_stot53-deci = '0'.
      wa_stot53-vkbux = i_output5-vkbur.
      APPEND wa_stot53 TO i_output5.

      wa_stot53-name1 = '           Percentage(%)'.
      IF wa_stot53-kzwi1 NE wa_stot53-btamt.
        IF p_val = 'X'.
          wa_stot53-dlval% = wa_stot53-dlval / ( wa_stot53-kzwi1 -
                             wa_stot53-btamt ) * 100.
          wa_stot53-unprc = wa_stot53-unval / ( wa_stot53-kzwi1 -
                             wa_stot53-btamt ) * 100.
          wa_stot53-lead1% = wa_stot53-lead1 / ( wa_stot53-kzwi1 -
                             wa_stot53-btamt ) * 100.
          wa_stot53-lead2% = wa_stot53-lead2 / ( wa_stot53-kzwi1 -
                             wa_stot53-btamt ) * 100.
          wa_stot53-lead3% = wa_stot53-lead3 / ( wa_stot53-kzwi1 -
                             wa_stot53-btamt ) * 100.
          wa_stot53-lead4% = wa_stot53-lead4 / ( wa_stot53-kzwi1 -
                             wa_stot53-btamt ) * 100.
          wa_stot53-lead5% = wa_stot53-lead5 / ( wa_stot53-kzwi1 -
                             wa_stot53-btamt ) * 100.
          wa_stot53-lead6% = wa_stot53-lead6 / ( wa_stot53-kzwi1 -
                             wa_stot53-btamt ) * 100.
          wa_stot53-poout% = wa_stot53-poout / ( wa_stot53-kzwi1 -
                             wa_stot53-btamt ) * 100.
          wa_stot53-btprc% = wa_stot53-btamt / wa_stot53-kzwi1 * 100.
          wa_stot53-stkout% = wa_stot53-stkout / ( wa_stot53-kzwi1 -
                             wa_stot53-btamt ) * 100.
          wa_stot53-cltop% = wa_stot53-cltop / ( wa_stot53-kzwi1 -
                            wa_stot53-btamt ) * 100.
          wa_stot53-salah% = wa_stot53-salah / ( wa_stot53-kzwi1 -
                            wa_stot53-btamt ) * 100.
          wa_stot53-other% = wa_stot53-other / ( wa_stot53-kzwi1 -
                            wa_stot53-btamt ) * 100.
          wa_stot53-reject% = wa_stot53-reject / ( wa_stot53-kzwi1 -
                             wa_stot53-btamt ) * 100.

          PERFORM f_hitung_stot3 USING wa_stot53-kzwi1
                                       wa_stot53-btamt
                                       wa_stot53-kwmeng
                                       wa_stot53-btqty
                                       p_val
                                       '5'.

        ELSE.
          wa_stot53-dlval% = wa_stot53-dlqty / ( wa_stot53-kwmeng -
                             wa_stot53-btqty ) * 100.
          wa_stot53-unprc = wa_stot53-unqty / ( wa_stot53-kwmeng -
                             wa_stot53-btqty ) * 100.
          wa_stot53-lead1% = wa_stot53-lead1q / ( wa_stot53-kwmeng -
                             wa_stot53-btqty ) * 100.
          wa_stot53-lead2% = wa_stot53-lead2q / ( wa_stot53-kwmeng -
                             wa_stot53-btqty ) * 100.
          wa_stot53-lead3% = wa_stot53-lead3q / ( wa_stot53-kwmeng -
                             wa_stot53-btqty ) * 100.
          wa_stot53-lead4% = wa_stot53-lead4q / ( wa_stot53-kwmeng -
                             wa_stot53-btqty ) * 100.
          wa_stot53-lead5% = wa_stot53-lead5q / ( wa_stot53-kwmeng -
                             wa_stot53-btqty ) * 100.
          wa_stot53-lead6% = wa_stot53-lead6q / ( wa_stot53-kwmeng -
                             wa_stot53-btqty ) * 100.
          wa_stot53-poout% = wa_stot53-pooutq / ( wa_stot53-kwmeng -
                             wa_stot53-btqty ) * 100.
          wa_stot53-btprc% = wa_stot53-btqty / wa_stot53-kwmeng * 100.
          wa_stot53-stkout% = wa_stot53-stkoutq / ( wa_stot53-kwmeng -
                             wa_stot53-btqty ) * 100.
          wa_stot53-cltop% = wa_stot53-cltopq / ( wa_stot53-kwmeng -
                            wa_stot53-btqty ) * 100.
          wa_stot53-salah% = wa_stot53-salahq / ( wa_stot53-kwmeng -
                            wa_stot53-btqty ) * 100.
          wa_stot53-other% = wa_stot53-otherq / ( wa_stot53-kwmeng -
                            wa_stot53-btqty ) * 100.
          wa_stot53-reject% = wa_stot53-rejectq / ( wa_stot53-kwmeng -
                             wa_stot53-btqty ) * 100.

          PERFORM f_hitung_stot3 USING wa_stot53-kzwi1
                                       wa_stot53-btamt
                                       wa_stot53-kwmeng
                                       wa_stot53-btqty
                                       p_val
                                       '5'.

        ENDIF.
      ENDIF.

      wa_stot53-dlval = wa_stot53-dlval%.
      IF p_val = 'X'.
        wa_stot53-unval = wa_stot53-unprc.
        wa_stot53-lead1 = wa_stot53-lead1%.
        wa_stot53-lead2 = wa_stot53-lead2%.
        wa_stot53-lead3 = wa_stot53-lead3%.
        wa_stot53-lead4 = wa_stot53-lead4%.
        wa_stot53-lead5 = wa_stot53-lead5%.
        wa_stot53-lead6 = wa_stot53-lead6%.
        wa_stot53-poout = wa_stot53-poout%.
        wa_stot53-btamt = wa_stot53-btprc%.
        wa_stot53-stkout = wa_stot53-stkout%.
        wa_stot53-cltop = wa_stot53-cltop%.
        wa_stot53-salah = wa_stot53-salah%.
        wa_stot53-other = wa_stot53-other%.
        wa_stot53-reject = wa_stot53-reject%.

        PERFORM f_move_stot3 USING p_val '5'.

      ELSE.
        wa_stot53-unqty = wa_stot53-unprc.
        wa_stot53-lead1q = wa_stot53-lead1%.
        wa_stot53-lead2q = wa_stot53-lead2%.
        wa_stot53-lead3q = wa_stot53-lead3%.
        wa_stot53-lead4q = wa_stot53-lead4%.
        wa_stot53-lead5q = wa_stot53-lead5%.
        wa_stot53-lead6q = wa_stot53-lead6%.
        wa_stot53-pooutq = wa_stot53-poout%.
        wa_stot53-btqty = wa_stot53-btprc%.
        wa_stot53-stkoutq = wa_stot53-stkout%.
        wa_stot53-cltopq = wa_stot53-cltop%.
        wa_stot53-salahq = wa_stot53-salah%.
        wa_stot53-otherq = wa_stot53-other%.
        wa_stot53-rejectq = wa_stot53-reject%.

        PERFORM f_move_stot3 USING p_val '5'.

      ENDIF.
      wa_stot53-deci = '2'.
      CLEAR: wa_stot53-vkbur, wa_stot53-knkli,
             wa_stot53-curr, wa_stot53-kwmeng, wa_stot53-kzwi1,
             wa_stot53-dlqty.
      APPEND wa_stot53 TO i_output5.
      CLEAR: wa_stot53.
    ENDAT.

* Total Customer Group
    AT END OF kvgr4.
      wa_stot52-matkl = i_output5-matkl.
      wa_stot52-kvgr4 = i_output5-kvgr4.
      wa_stot52-bezei = i_output5-bezei.
      CONCATENATE '**   Total' i_output5-kvgr4 i_output5-bezei
                  INTO wa_stot52-name1 SEPARATED BY space.
      wa_stot52-info = 'C31'.
      wa_stot52-curr = 'IDR'.
      wa_stot52-index = '30'.
      wa_stot52-deci = '0'.
      wa_stot52-vkbux = i_output5-vkbur.
      APPEND wa_stot52 TO i_output5.

      wa_stot52-name1 = '           Percentage(%)'.
      IF wa_stot52-kzwi1 NE wa_stot52-btamt.
        IF p_val = 'X'.
          wa_stot52-unprc = wa_stot52-unval / ( wa_stot52-kzwi1 -
                             wa_stot52-btamt ) * 100.
          wa_stot52-dlval% = wa_stot52-dlval / ( wa_stot52-kzwi1 -
                             wa_stot52-btamt ) * 100.
          wa_stot52-lead1% = wa_stot52-lead1 / ( wa_stot52-kzwi1 -
                             wa_stot52-btamt ) * 100.
          wa_stot52-lead2% = wa_stot52-lead2 / ( wa_stot52-kzwi1 -
                             wa_stot52-btamt ) * 100.
          wa_stot52-lead3% = wa_stot52-lead3 / ( wa_stot52-kzwi1 -
                             wa_stot52-btamt ) * 100.
          wa_stot52-lead4% = wa_stot52-lead4 / ( wa_stot52-kzwi1 -
                             wa_stot52-btamt ) * 100.
          wa_stot52-lead5% = wa_stot52-lead5 / ( wa_stot52-kzwi1 -
                             wa_stot52-btamt ) * 100.
          wa_stot52-lead6% = wa_stot52-lead6 / ( wa_stot52-kzwi1 -
                             wa_stot52-btamt ) * 100.
          wa_stot52-poout% = wa_stot52-poout / ( wa_stot52-kzwi1 -
                             wa_stot52-btamt ) * 100.
          wa_stot52-btprc% = wa_stot52-btamt / wa_stot52-kzwi1 * 100.
          wa_stot52-stkout% = wa_stot52-stkout / ( wa_stot52-kzwi1 -
                             wa_stot52-btamt ) * 100.
          wa_stot52-cltop% = wa_stot52-cltop / ( wa_stot52-kzwi1 -
                            wa_stot52-btamt ) * 100.
          wa_stot52-salah% = wa_stot52-salah / ( wa_stot52-kzwi1 -
                            wa_stot52-btamt ) * 100.
          wa_stot52-other% = wa_stot52-other / ( wa_stot52-kzwi1 -
                            wa_stot52-btamt ) * 100.
          wa_stot52-reject% = wa_stot52-reject / ( wa_stot52-kzwi1 -
                             wa_stot52-btamt ) * 100.

          PERFORM f_hitung_stot2 USING wa_stot52-kzwi1
                                       wa_stot52-btamt
                                       wa_stot52-kwmeng
                                       wa_stot52-btqty
                                       p_val
                                       '5'.

        ELSE.
          wa_stot52-unprc = wa_stot52-unqty / ( wa_stot52-kwmeng -
                             wa_stot52-btqty ) * 100.
          wa_stot52-dlval% = wa_stot52-dlqty / ( wa_stot52-kwmeng -
                             wa_stot52-btqty ) * 100.
          wa_stot52-lead1% = wa_stot52-lead1q / ( wa_stot52-kwmeng -
                             wa_stot52-btqty ) * 100.
          wa_stot52-lead2% = wa_stot52-lead2q / ( wa_stot52-kwmeng -
                             wa_stot52-btqty ) * 100.
          wa_stot52-lead3% = wa_stot52-lead3q / ( wa_stot52-kwmeng -
                             wa_stot52-btqty ) * 100.
          wa_stot52-lead4% = wa_stot52-lead4q / ( wa_stot52-kwmeng -
                             wa_stot52-btqty ) * 100.
          wa_stot52-lead5% = wa_stot52-lead5q / ( wa_stot52-kwmeng -
                             wa_stot52-btqty ) * 100.
          wa_stot52-lead6% = wa_stot52-lead6q / ( wa_stot52-kwmeng -
                             wa_stot52-btqty ) * 100.
          wa_stot52-poout% = wa_stot52-pooutq / ( wa_stot52-kwmeng -
                             wa_stot52-btqty ) * 100.
          wa_stot52-btprc% = wa_stot52-btqty / wa_stot52-kwmeng * 100.
          wa_stot52-stkout% = wa_stot52-stkoutq / ( wa_stot52-kwmeng -
                             wa_stot52-btqty ) * 100.
          wa_stot52-cltop% = wa_stot52-cltopq / ( wa_stot52-kwmeng -
                            wa_stot52-btqty ) * 100.
          wa_stot52-salah% = wa_stot52-salahq / ( wa_stot52-kwmeng -
                            wa_stot52-btqty ) * 100.
          wa_stot52-other% = wa_stot52-otherq / ( wa_stot52-kwmeng -
                            wa_stot52-btqty ) * 100.
          wa_stot52-reject% = wa_stot52-rejectq / ( wa_stot52-kwmeng -
                             wa_stot52-btqty ) * 100.

          PERFORM f_hitung_stot2 USING wa_stot52-kzwi1
                                       wa_stot52-btamt
                                       wa_stot52-kwmeng
                                       wa_stot52-btqty
                                       p_val
                                       '5'.

        ENDIF.
      ENDIF.

      wa_stot52-dlval = wa_stot52-dlval%.
      IF p_val = 'X'.
        wa_stot52-unval = wa_stot52-unprc.
        wa_stot52-lead1 = wa_stot52-lead1%.
        wa_stot52-lead2 = wa_stot52-lead2%.
        wa_stot52-lead3 = wa_stot52-lead3%.
        wa_stot52-lead4 = wa_stot52-lead4%.
        wa_stot52-lead5 = wa_stot52-lead5%.
        wa_stot52-lead6 = wa_stot52-lead6%.
        wa_stot52-poout = wa_stot52-poout%.
        wa_stot52-btamt = wa_stot52-btprc%.
        wa_stot52-stkout = wa_stot52-stkout%.
        wa_stot52-cltop = wa_stot52-cltop%.
        wa_stot52-salah = wa_stot52-salah%.
        wa_stot52-other = wa_stot52-other%.
        wa_stot52-reject = wa_stot52-reject%.

        PERFORM f_move_stot2 USING p_val '5'.

      ELSE.
        wa_stot52-unqty = wa_stot52-unprc.
        wa_stot52-lead1q = wa_stot52-lead1%.
        wa_stot52-lead2q = wa_stot52-lead2%.
        wa_stot52-lead3q = wa_stot52-lead3%.
        wa_stot52-lead4q = wa_stot52-lead4%.
        wa_stot52-lead5q = wa_stot52-lead5%.
        wa_stot52-lead6q = wa_stot52-lead6%.
        wa_stot52-pooutq = wa_stot52-poout%.
        wa_stot52-btqty = wa_stot52-btprc%.
        wa_stot52-stkoutq = wa_stot52-stkout%.
        wa_stot52-cltopq = wa_stot52-cltop%.
        wa_stot52-salahq = wa_stot52-salah%.
        wa_stot52-otherq = wa_stot52-other%.
        wa_stot52-rejectq = wa_stot52-reject%.

        PERFORM f_move_stot2 USING p_val '5'.

      ENDIF.
      wa_stot52-deci = '2'.
      CLEAR: wa_stot52-vkbur, wa_stot52-knkli,
             wa_stot52-curr, wa_stot52-kwmeng, wa_stot52-kzwi1,
             wa_stot52-dlqty.
      APPEND wa_stot52 TO i_output5.
      CLEAR: wa_stot52, wa_stot53.
    ENDAT.

* Total Material Group
    AT END OF matkl.
      wa_stot51-matkl = i_output5-matkl.
      wa_stot51-kvgr4 = i_output5-kvgr4.
      wa_stot51-bezei = i_output5-bezei.
      CONCATENATE '***  Total' i_output5-matkl
                  INTO wa_stot51-name1 SEPARATED BY space.
      wa_stot51-info = 'C70'.
      wa_stot51-curr = 'IDR'.
      wa_stot51-index = '40'.
      wa_stot51-deci = '0'.
      wa_stot51-vkbux = i_output5-vkbur.
      APPEND wa_stot51 TO i_output5.

      wa_stot51-name1 = '           Percentage(%)'.
      IF wa_stot51-kzwi1 NE wa_stot51-btamt.
        IF p_val = 'X'.
          wa_stot51-dlval% = wa_stot51-dlval / ( wa_stot51-kzwi1 -
                             wa_stot51-btamt ) * 100.
          wa_stot51-unprc = wa_stot51-unval / ( wa_stot51-kzwi1 -
                             wa_stot51-btamt ) * 100.
          wa_stot51-lead1% = wa_stot51-lead1 / ( wa_stot51-kzwi1 -
                             wa_stot51-btamt ) * 100.
          wa_stot51-lead2% = wa_stot51-lead2 / ( wa_stot51-kzwi1 -
                             wa_stot51-btamt ) * 100.
          wa_stot51-lead3% = wa_stot51-lead3 / ( wa_stot51-kzwi1 -
                             wa_stot51-btamt ) * 100.
          wa_stot51-lead4% = wa_stot51-lead4 / ( wa_stot51-kzwi1 -
                             wa_stot51-btamt ) * 100.
          wa_stot51-lead5% = wa_stot51-lead5 / ( wa_stot51-kzwi1 -
                             wa_stot51-btamt ) * 100.
          wa_stot51-lead6% = wa_stot51-lead6 / ( wa_stot51-kzwi1 -
                             wa_stot51-btamt ) * 100.
          wa_stot51-poout% = wa_stot51-poout / ( wa_stot51-kzwi1 -
                             wa_stot51-btamt ) * 100.
          wa_stot51-btprc% = wa_stot51-btamt / wa_stot51-kzwi1 * 100.
          wa_stot51-stkout% = wa_stot51-stkout / ( wa_stot51-kzwi1 -
                             wa_stot51-btamt ) * 100.
          wa_stot51-cltop% = wa_stot51-cltop / ( wa_stot51-kzwi1 -
                            wa_stot51-btamt ) * 100.
          wa_stot51-salah% = wa_stot51-salah / ( wa_stot51-kzwi1 -
                            wa_stot51-btamt ) * 100.
          wa_stot51-other% = wa_stot51-other / ( wa_stot51-kzwi1 -
                            wa_stot51-btamt ) * 100.
          wa_stot51-reject% = wa_stot51-reject / ( wa_stot51-kzwi1 -
                             wa_stot51-btamt ) * 100.

          PERFORM f_hitung_stot1 USING wa_stot51-kzwi1
                                       wa_stot51-btamt
                                       wa_stot51-kwmeng
                                       wa_stot51-btqty
                                       p_val
                                       '5'.

        ELSE.
          wa_stot51-dlval% = wa_stot51-dlqty / ( wa_stot51-kwmeng -
                             wa_stot51-btqty ) * 100.
          wa_stot51-unprc = wa_stot51-unqty / ( wa_stot51-kwmeng -
                             wa_stot51-btqty ) * 100.
          wa_stot51-lead1% = wa_stot51-lead1q / ( wa_stot51-kwmeng -
                             wa_stot51-btqty ) * 100.
          wa_stot51-lead2% = wa_stot51-lead2q / ( wa_stot51-kwmeng -
                             wa_stot51-btqty ) * 100.
          wa_stot51-lead3% = wa_stot51-lead3q / ( wa_stot51-kwmeng -
                             wa_stot51-btqty ) * 100.
          wa_stot51-lead4% = wa_stot51-lead4q / ( wa_stot51-kwmeng -
                             wa_stot51-btqty ) * 100.
          wa_stot51-lead5% = wa_stot51-lead5q / ( wa_stot51-kwmeng -
                             wa_stot51-btqty ) * 100.
          wa_stot51-lead6% = wa_stot51-lead6q / ( wa_stot51-kwmeng -
                             wa_stot51-btqty ) * 100.
          wa_stot51-poout% = wa_stot51-pooutq / ( wa_stot51-kwmeng -
                             wa_stot51-btqty ) * 100.
          wa_stot51-btprc% = wa_stot51-btqty / wa_stot51-kwmeng * 100.
          wa_stot51-stkout% = wa_stot51-stkoutq / ( wa_stot51-kwmeng -
                             wa_stot51-btqty ) * 100.
          wa_stot51-cltop% = wa_stot51-cltopq / ( wa_stot51-kwmeng -
                            wa_stot51-btqty ) * 100.
          wa_stot51-salah% = wa_stot51-salahq / ( wa_stot51-kwmeng -
                            wa_stot51-btqty ) * 100.
          wa_stot51-other% = wa_stot51-otherq / ( wa_stot51-kwmeng -
                            wa_stot51-btqty ) * 100.
          wa_stot51-reject% = wa_stot51-rejectq / ( wa_stot51-kwmeng -
                             wa_stot51-btqty ) * 100.

          PERFORM f_hitung_stot1 USING wa_stot51-kzwi1
                                       wa_stot51-btamt
                                       wa_stot51-kwmeng
                                       wa_stot51-btqty
                                       p_val
                                       '5'.

        ENDIF.
      ENDIF.

      wa_stot51-dlval = wa_stot51-dlval%.
      IF p_val = 'X'.
        wa_stot51-unval = wa_stot51-unprc.
        wa_stot51-lead1 = wa_stot51-lead1%.
        wa_stot51-lead2 = wa_stot51-lead2%.
        wa_stot51-lead3 = wa_stot51-lead3%.
        wa_stot51-lead4 = wa_stot51-lead4%.
        wa_stot51-lead5 = wa_stot51-lead5%.
        wa_stot51-lead6 = wa_stot51-lead6%.
        wa_stot51-poout = wa_stot51-poout%.
        wa_stot51-btamt = wa_stot51-btprc%.
        wa_stot51-stkout = wa_stot51-stkout%.
        wa_stot51-cltop = wa_stot51-cltop%.
        wa_stot51-salah = wa_stot51-salah%.
        wa_stot51-other = wa_stot51-other%.
        wa_stot51-reject = wa_stot51-reject%.

        PERFORM f_move_stot1 USING p_val '5'.

      ELSE.
        wa_stot51-unqty = wa_stot51-unprc.
        wa_stot51-lead1q = wa_stot51-lead1%.
        wa_stot51-lead2q = wa_stot51-lead2%.
        wa_stot51-lead3q = wa_stot51-lead3%.
        wa_stot51-lead4q = wa_stot51-lead4%.
        wa_stot51-lead5q = wa_stot51-lead5%.
        wa_stot51-lead6q = wa_stot51-lead6%.
        wa_stot51-pooutq = wa_stot51-poout%.
        wa_stot51-btqty = wa_stot51-btprc%.
        wa_stot51-stkoutq = wa_stot51-stkout%.
        wa_stot51-cltopq = wa_stot51-cltop%.
        wa_stot51-salahq = wa_stot51-salah%.
        wa_stot51-otherq = wa_stot51-other%.
        wa_stot51-rejectq = wa_stot51-reject%.

        PERFORM f_move_stot1 USING p_val '5'.

      ENDIF.
      wa_stot51-deci = '2'.
      CLEAR: wa_stot51-vkbur, wa_stot51-knkli,
             wa_stot51-curr, wa_stot51-kwmeng, wa_stot51-kzwi1,
             wa_stot51-dlqty.
      APPEND wa_stot51 TO i_output5.
      CLEAR: wa_stot51, wa_stot52, wa_stot53.
    ENDAT.

  ENDLOOP.

* Total Grand
  wa_gtot5-matkl = i_output5-matkl.
  wa_gtot5-kvgr4 = i_output5-kvgr4.
  wa_gtot5-bezei = i_output5-bezei.
  wa_gtot5-name1 = '**** Grand Total'.
  wa_gtot5-info = 'C71'.
  wa_gtot5-curr = 'IDR'.
  wa_gtot5-index = '50'.
  wa_gtot5-deci = '0'.
  wa_gtot5-vkbux = i_output5-vkbur.
  APPEND wa_gtot5 TO i_output5.

  wa_gtot5-name1 = '           Percentage(%)'.
  IF wa_gtot5-kzwi1 NE wa_gtot5-btamt.
    IF p_val = 'X'.
      wa_gtot5-unprc = wa_gtot5-unval / ( wa_gtot5-kzwi1 -
                             wa_gtot5-btamt ) * 100.
      wa_gtot5-dlval% = wa_gtot5-dlval / ( wa_gtot5-kzwi1 -
                             wa_gtot5-btamt ) * 100.
      wa_gtot5-lead1% = wa_gtot5-lead1 / ( wa_gtot5-kzwi1 -
                             wa_gtot5-btamt ) * 100.
      wa_gtot5-lead2% = wa_gtot5-lead2 / ( wa_gtot5-kzwi1 -
                             wa_gtot5-btamt ) * 100.
      wa_gtot5-lead3% = wa_gtot5-lead3 / ( wa_gtot5-kzwi1 -
                             wa_gtot5-btamt ) * 100.
      wa_gtot5-lead4% = wa_gtot5-lead4 / ( wa_gtot5-kzwi1 -
                             wa_gtot5-btamt ) * 100.
      wa_gtot5-lead5% = wa_gtot5-lead5 / ( wa_gtot5-kzwi1 -
                             wa_gtot5-btamt ) * 100.
      wa_gtot5-lead6% = wa_gtot5-lead6 / ( wa_gtot5-kzwi1 -
                             wa_gtot5-btamt ) * 100.
      wa_gtot5-poout% = wa_gtot5-poout / ( wa_gtot5-kzwi1 -
                             wa_gtot5-btamt ) * 100.
      wa_gtot5-btprc% = wa_gtot5-btamt / wa_gtot5-kzwi1 * 100.
      wa_gtot5-stkout% = wa_gtot5-stkout / ( wa_gtot5-kzwi1 -
                             wa_gtot5-btamt ) * 100.
      wa_gtot5-cltop% = wa_gtot5-cltop / ( wa_gtot5-kzwi1 -
                        wa_gtot5-btamt ) * 100.
      wa_gtot5-salah% = wa_gtot5-salah / ( wa_gtot5-kzwi1 -
                        wa_gtot5-btamt ) * 100.
      wa_gtot5-other% = wa_gtot5-other / ( wa_gtot5-kzwi1 -
                        wa_gtot5-btamt ) * 100.
      wa_gtot5-reject% = wa_gtot5-reject / ( wa_gtot5-kzwi1 -
                             wa_gtot5-btamt ) * 100.

      PERFORM f_hitung_gtot USING wa_gtot5-kzwi1
                                   wa_gtot5-btamt
                                   wa_gtot5-kwmeng
                                   wa_gtot5-btqty
                                   p_val
                                   '5'.

    ELSE.
      wa_gtot5-unprc = wa_gtot5-unqty / ( wa_gtot5-kwmeng -
                             wa_gtot5-btqty ) * 100.
      wa_gtot5-dlval% = wa_gtot5-dlqty / ( wa_gtot5-kwmeng -
                             wa_gtot5-btqty ) * 100.
      wa_gtot5-lead1% = wa_gtot5-lead1q / ( wa_gtot5-kwmeng -
                             wa_gtot5-btqty ) * 100.
      wa_gtot5-lead2% = wa_gtot5-lead2q / ( wa_gtot5-kwmeng -
                             wa_gtot5-btqty ) * 100.
      wa_gtot5-lead3% = wa_gtot5-lead3q / ( wa_gtot5-kwmeng -
                             wa_gtot5-btqty ) * 100.
      wa_gtot5-lead4% = wa_gtot5-lead4q / ( wa_gtot5-kwmeng -
                             wa_gtot5-btqty ) * 100.
      wa_gtot5-lead5% = wa_gtot5-lead5q / ( wa_gtot5-kwmeng -
                             wa_gtot5-btqty ) * 100.
      wa_gtot5-lead6% = wa_gtot5-lead6q / ( wa_gtot5-kwmeng -
                             wa_gtot5-btqty ) * 100.
      wa_gtot5-poout% = wa_gtot5-pooutq / ( wa_gtot5-kwmeng -
                             wa_gtot5-btqty ) * 100.
      wa_gtot5-btprc% = wa_gtot5-btqty / wa_gtot5-kwmeng * 100.
      wa_gtot5-stkout% = wa_gtot5-stkoutq / ( wa_gtot5-kwmeng -
                             wa_gtot5-btqty ) * 100.
      wa_gtot5-cltop% = wa_gtot5-cltopq / ( wa_gtot5-kwmeng -
                        wa_gtot5-btqty ) * 100.
      wa_gtot5-salah% = wa_gtot5-salahq / ( wa_gtot5-kwmeng -
                        wa_gtot5-btqty ) * 100.
      wa_gtot5-other% = wa_gtot5-otherq / ( wa_gtot5-kwmeng -
                        wa_gtot5-btqty ) * 100.
      wa_gtot5-reject% = wa_gtot5-rejectq / ( wa_gtot5-kwmeng -
                             wa_gtot5-btqty ) * 100.

      PERFORM f_hitung_gtot USING wa_gtot5-kzwi1
                                   wa_gtot5-btamt
                                   wa_gtot5-kwmeng
                                   wa_gtot5-btqty
                                   p_val
                                   '5'.

    ENDIF.
  ENDIF.

  wa_gtot5-dlval = wa_gtot5-dlval%.
  IF p_val = 'X'.
    wa_gtot5-unval = wa_gtot5-unprc.
    wa_gtot5-lead1 = wa_gtot5-lead1%.
    wa_gtot5-lead2 = wa_gtot5-lead2%.
    wa_gtot5-lead3 = wa_gtot5-lead3%.
    wa_gtot5-lead4 = wa_gtot5-lead4%.
    wa_gtot5-lead5 = wa_gtot5-lead5%.
    wa_gtot5-lead6 = wa_gtot5-lead6%.
    wa_gtot5-poout = wa_gtot5-poout%.
    wa_gtot5-btamt = wa_gtot5-btprc%.
    wa_gtot5-stkout = wa_gtot5-stkout%.
    wa_gtot5-cltop = wa_gtot5-cltop%.
    wa_gtot5-salah = wa_gtot5-salah%.
    wa_gtot5-other = wa_gtot5-other%.
    wa_gtot5-reject = wa_gtot5-reject%.

    PERFORM f_move_gtot USING p_val '5'.

  ELSE.
    wa_gtot5-unqty = wa_gtot5-unprc.
    wa_gtot5-lead1q = wa_gtot5-lead1%.
    wa_gtot5-lead2q = wa_gtot5-lead2%.
    wa_gtot5-lead3q = wa_gtot5-lead3%.
    wa_gtot5-lead4q = wa_gtot5-lead4%.
    wa_gtot5-lead5q = wa_gtot5-lead5%.
    wa_gtot5-lead6q = wa_gtot5-lead6%.
    wa_gtot5-pooutq = wa_gtot5-poout%.
    wa_gtot5-btqty = wa_gtot5-btprc%.
    wa_gtot5-cltopq = wa_gtot5-cltop%.
    wa_gtot5-salahq = wa_gtot5-salah%.
    wa_gtot5-otherq = wa_gtot5-other%.
    wa_gtot5-stkoutq = wa_gtot5-stkout%.
    wa_gtot5-rejectq = wa_gtot5-reject%.

    PERFORM f_move_gtot USING p_val '5'.

  ENDIF.
  wa_gtot5-deci = '2'.
  CLEAR: wa_gtot5-vkbur, wa_gtot5-knkli,
         wa_gtot5-curr, wa_gtot5-kwmeng, wa_gtot5-kzwi1,
         wa_gtot5-dlqty.
  APPEND wa_gtot5 TO i_output5.
  CLEAR: wa_gtot5.

  IF p_total5 = 'X'.
    DELETE i_output5 WHERE index LT '30'.
  ENDIF.

ENDFORM.                    " proses_data5

*&---------------------------------------------------------------------*
*&      Form  append_itab5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_itab5.

  DATA : l_crdat  LIKE  zmm_cust_rec-crdat,
         l_leadt  TYPE  i.

  MOVE-CORRESPONDING i_detquot5 TO i_output5.

  IF NOT i_detdelv-vbeln IS INITIAL.
    i_output5-dlqty = i_detsales-kwmeng.
    i_output5-dlval = i_detsales-kzwi1.
    i_output5-unqty = i_output5-kwmeng - i_output5-dlqty.
    i_output5-unval = i_output5-kzwi1 - i_output5-dlval.

    IF i_output5-unqty LT 0.
      CLEAR: i_output5-unqty,i_output5-unval.
    ENDIF.

    SELECT SINGLE crdat FROM zmm_cust_rec
      INTO l_crdat
      WHERE vbeln = i_detdelv-vbeln.

    IF l_crdat IS INITIAL.
      i_output5-lead6q = i_output5-dlqty.
      i_output5-lead6 = i_output5-dlval.
    ELSE.
      l_leadt = l_crdat - i_detquot5-bstdk.
      IF l_leadt LE 3.
        i_output5-lead1q = i_output5-dlqty.
        i_output5-lead1 = i_output5-dlval.
      ELSEIF l_leadt = 4.
        i_output5-lead2q = i_output5-dlqty.
        i_output5-lead2 = i_output5-dlval.
      ELSEIF l_leadt GE 5.
        i_output5-lead3q = i_output5-dlqty.
        i_output5-lead3 = i_output5-dlval.
*      ELSEIF l_leadt GE 6.
*        i_output5-lead4 = i_output5-dlval.
*      ELSEIF l_leadt GE 7.
*        i_output5-lead5 = i_output5-dlval.
      ENDIF.
    ENDIF.
  ELSE.
    IF i_detsales-vbeln IS INITIAL.
      i_output5-unqty = i_output5-kwmeng.
      i_output5-unval = i_output5-kzwi1.
    ELSE.
      IF NOT i_detquot5-abgru IS INITIAL.
        i_output5-unqty = i_output5-kwmeng.
        i_output5-unval = i_output5-kzwi1.
      ELSE.
        i_output5-pooutq = i_output5-kwmeng.
        i_output5-poout = i_output5-kzwi1.
      ENDIF.
    ENDIF.
  ENDIF.


  PERFORM f_reason_for_rejection USING i_detquot5-abgru
                                       i_output5-unqty
                                       i_output5-unval
                                       '5'.


  SELECT SINGLE bezei INTO i_output5-bezei
    FROM tvv4t
    WHERE spras = sy-langu AND
          kvgr4 = i_output5-kvgr4.

  SELECT SINGLE bezei FROM tvkbt
    INTO i_output5-vkburt
    WHERE spras = sy-langu AND
          vkbur = i_output5-vkbur.

  i_output5-reject = i_output5-unval - i_output5-stkout.

  PERFORM hitung_total5.

  i_output5-curr = 'IDR'.
  i_output5-index = '10'.
  i_output5-deci = '0'.
  i_output5-vkbux = i_output5-vkbur.

  COLLECT i_output5.

ENDFORM.                    " append_itab5

*&---------------------------------------------------------------------*
*&      Form  hitung_total5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hitung_total5.

  ADD i_output5-kwmeng TO wa_stot51-kwmeng.
  ADD i_output5-kwmeng TO wa_stot52-kwmeng.
  ADD i_output5-kwmeng TO wa_stot53-kwmeng.
  ADD i_output5-kwmeng TO wa_gtot5-kwmeng.
  ADD i_output5-kzwi1 TO wa_stot51-kzwi1.
  ADD i_output5-kzwi1 TO wa_stot52-kzwi1.
  ADD i_output5-kzwi1 TO wa_stot53-kzwi1.
  ADD i_output5-kzwi1 TO wa_gtot5-kzwi1.
  ADD i_output5-dlqty TO wa_stot51-dlqty.
  ADD i_output5-dlqty TO wa_stot52-dlqty.
  ADD i_output5-dlqty TO wa_stot53-dlqty.
  ADD i_output5-dlqty TO wa_gtot5-dlqty.
  ADD i_output5-dlval TO wa_stot51-dlval.
  ADD i_output5-dlval TO wa_stot52-dlval.
  ADD i_output5-dlval TO wa_stot53-dlval.
  ADD i_output5-dlval TO wa_gtot5-dlval.
  ADD i_output5-unqty TO wa_stot51-unqty.
  ADD i_output5-unqty TO wa_stot52-unqty.
  ADD i_output5-unqty TO wa_stot53-unqty.
  ADD i_output5-unqty TO wa_gtot5-unqty.
  ADD i_output5-unval TO wa_stot51-unval.
  ADD i_output5-unval TO wa_stot52-unval.
  ADD i_output5-unval TO wa_stot53-unval.
  ADD i_output5-unval TO wa_gtot5-unval.
  ADD i_output5-lead1q TO wa_stot51-lead1q.
  ADD i_output5-lead1q TO wa_stot52-lead1q.
  ADD i_output5-lead1q TO wa_stot53-lead1q.
  ADD i_output5-lead1q TO wa_gtot5-lead1q.
  ADD i_output5-lead1 TO wa_stot51-lead1.
  ADD i_output5-lead1 TO wa_stot52-lead1.
  ADD i_output5-lead1 TO wa_stot53-lead1.
  ADD i_output5-lead1 TO wa_gtot5-lead1.
  ADD i_output5-lead2 TO wa_stot51-lead2q.
  ADD i_output5-lead2 TO wa_stot52-lead2q.
  ADD i_output5-lead2 TO wa_stot53-lead2q.
  ADD i_output5-lead2 TO wa_gtot5-lead2q.
  ADD i_output5-lead2 TO wa_stot51-lead2.
  ADD i_output5-lead2 TO wa_stot52-lead2.
  ADD i_output5-lead2 TO wa_stot53-lead2.
  ADD i_output5-lead2 TO wa_gtot5-lead2.
  ADD i_output5-lead3q TO wa_stot51-lead3q.
  ADD i_output5-lead3q TO wa_stot52-lead3q.
  ADD i_output5-lead3q TO wa_stot53-lead3q.
  ADD i_output5-lead3q TO wa_gtot5-lead3q.
  ADD i_output5-lead3 TO wa_stot51-lead3.
  ADD i_output5-lead3 TO wa_stot52-lead3.
  ADD i_output5-lead3 TO wa_stot53-lead3.
  ADD i_output5-lead3 TO wa_gtot5-lead3.
  ADD i_output5-lead4q TO wa_stot51-lead4q.
  ADD i_output5-lead4q TO wa_stot52-lead4q.
  ADD i_output5-lead4q TO wa_stot53-lead4q.
  ADD i_output5-lead4q TO wa_gtot5-lead4q.
  ADD i_output5-lead4 TO wa_stot51-lead4.
  ADD i_output5-lead4 TO wa_stot52-lead4.
  ADD i_output5-lead4 TO wa_stot53-lead4.
  ADD i_output5-lead4 TO wa_gtot5-lead4.
  ADD i_output5-lead5q TO wa_stot51-lead5q.
  ADD i_output5-lead5q TO wa_stot52-lead5q.
  ADD i_output5-lead5q TO wa_stot53-lead5q.
  ADD i_output5-lead5q TO wa_gtot5-lead5q.
  ADD i_output5-lead5 TO wa_stot51-lead5.
  ADD i_output5-lead5 TO wa_stot52-lead5.
  ADD i_output5-lead5 TO wa_stot53-lead5.
  ADD i_output5-lead5 TO wa_gtot5-lead5.
  ADD i_output5-lead6q TO wa_stot51-lead6q.
  ADD i_output5-lead6q TO wa_stot52-lead6q.
  ADD i_output5-lead6q TO wa_stot53-lead6q.
  ADD i_output5-lead6q TO wa_gtot5-lead6q.
  ADD i_output5-lead6 TO wa_stot51-lead6.
  ADD i_output5-lead6 TO wa_stot52-lead6.
  ADD i_output5-lead6 TO wa_stot53-lead6.
  ADD i_output5-lead6 TO wa_gtot5-lead6.
  ADD i_output5-stkoutq TO wa_stot51-stkoutq.
  ADD i_output5-stkoutq TO wa_stot52-stkoutq.
  ADD i_output5-stkoutq TO wa_stot53-stkoutq.
  ADD i_output5-stkoutq TO wa_gtot5-stkoutq.
  ADD i_output5-stkout TO wa_stot51-stkout.
  ADD i_output5-stkout TO wa_stot52-stkout.
  ADD i_output5-stkout TO wa_stot53-stkout.
  ADD i_output5-stkout TO wa_gtot5-stkout.
  ADD i_output5-cltopq TO wa_stot51-cltopq.
  ADD i_output5-cltopq TO wa_stot52-cltopq.
  ADD i_output5-cltopq TO wa_stot53-cltopq.
  ADD i_output5-cltopq TO wa_gtot5-cltopq.
  ADD i_output5-cltop TO wa_stot51-cltop.
  ADD i_output5-cltop TO wa_stot52-cltop.
  ADD i_output5-cltop TO wa_stot53-cltop.
  ADD i_output5-cltop TO wa_gtot5-cltop.
  ADD i_output5-salahq TO wa_stot51-salahq.
  ADD i_output5-salahq TO wa_stot52-salahq.
  ADD i_output5-salahq TO wa_stot53-salahq.
  ADD i_output5-salahq TO wa_gtot5-salahq.
  ADD i_output5-salah TO wa_stot51-salah.
  ADD i_output5-salah TO wa_stot52-salah.
  ADD i_output5-salah TO wa_stot53-salah.
  ADD i_output5-salah TO wa_gtot5-salah.
  ADD i_output5-otherq TO wa_stot51-otherq.
  ADD i_output5-otherq TO wa_stot52-otherq.
  ADD i_output5-otherq TO wa_stot53-otherq.
  ADD i_output5-otherq TO wa_gtot5-otherq.
  ADD i_output5-other TO wa_stot51-other.
  ADD i_output5-other TO wa_stot52-other.
  ADD i_output5-other TO wa_stot53-other.
  ADD i_output5-other TO wa_gtot5-other.
  ADD i_output5-rejectq TO wa_stot51-rejectq.
  ADD i_output5-rejectq TO wa_stot52-rejectq.
  ADD i_output5-rejectq TO wa_stot53-rejectq.
  ADD i_output5-rejectq TO wa_gtot5-rejectq.
  ADD i_output5-reject TO wa_stot51-reject.
  ADD i_output5-reject TO wa_stot52-reject.
  ADD i_output5-reject TO wa_stot53-reject.
  ADD i_output5-reject TO wa_gtot5-reject.
  ADD i_output5-pooutq TO wa_stot51-pooutq.
  ADD i_output5-pooutq TO wa_stot52-pooutq.
  ADD i_output5-pooutq TO wa_stot53-pooutq.
  ADD i_output5-pooutq TO wa_gtot5-pooutq.
  ADD i_output5-poout TO wa_stot51-poout.
  ADD i_output5-poout TO wa_stot52-poout.
  ADD i_output5-poout TO wa_stot53-poout.
  ADD i_output5-poout TO wa_gtot5-poout.
  ADD i_output5-btqty TO wa_stot51-btqty.
  ADD i_output5-btqty TO wa_stot52-btqty.
  ADD i_output5-btqty TO wa_stot53-btqty.
  ADD i_output5-btqty TO wa_gtot5-btqty.
  ADD i_output5-btamt TO wa_stot51-btamt.
  ADD i_output5-btamt TO wa_stot52-btamt.
  ADD i_output5-btamt TO wa_stot53-btamt.
  ADD i_output5-btamt TO wa_gtot5-btamt.

  PERFORM f_hitung_total USING '5'.

ENDFORM.                    " hitung_total5

*&---------------------------------------------------------------------*
*&      Form  f_build_fieldcat5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_fieldcat5.
  DEFINE mac_header5.
    read table t_abgru index &1.
    if sy-subrc eq 0.
      if p_val = 'X'.
        fieldcat-fieldname = 'VAL&1'.
        fieldcat-ref_fieldname = ''.
        fieldcat-tabname = 'I_OUTPUT5'.
        fieldcat-outputlen = 15.
        fieldcat-cfieldname = 'CURR'.
        fieldcat-seltext_s = t_abgru-bezei.
        fieldcat-seltext_m = t_abgru-bezei.
        fieldcat-seltext_l = t_abgru-bezei.
        append fieldcat. "clear fieldcat.
      else.
        fieldcat-fieldname = 'QTY&1'.
        fieldcat-ref_fieldname = ''.
        fieldcat-tabname = 'I_OUTPUT5'.
        fieldcat-outputlen = 15.
        fieldcat-decimalsfieldname = 'DECI'.
        fieldcat-seltext_s = t_abgru-bezei.
        fieldcat-seltext_m = t_abgru-bezei.
        fieldcat-seltext_l = t_abgru-bezei.
        append fieldcat. "clear fieldcat.
      endif.
    endif.
  END-OF-DEFINITION.

  fieldcat-fieldname = 'VKBUR'.
  fieldcat-ref_fieldname = 'VKBUR'.
  fieldcat-tabname = 'I_OUTPUT5'.
  fieldcat-outputlen = 6.
  fieldcat-seltext_s = 'Sl Off'.
  fieldcat-seltext_m = 'Sls Off'.
  fieldcat-seltext_l = 'Sales Office'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'KNKLI'.
  fieldcat-ref_fieldname = 'KNKLI'.
  fieldcat-tabname = 'I_OUTPUT5'.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'Customer'.
  fieldcat-seltext_m = 'Customer'.
  fieldcat-seltext_l = 'Customer'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'NAME1'.
  fieldcat-ref_fieldname = 'NAME1'.
  fieldcat-tabname = 'I_OUTPUT5'.
  fieldcat-outputlen = 25.
  fieldcat-seltext_s = 'Customer Name'.
  fieldcat-seltext_m = 'Customer Name'.
  fieldcat-seltext_l = 'Customer Name'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'KWMENG'.
  fieldcat-ref_fieldname = 'KWMENG'.
  fieldcat-tabname = 'I_OUTPUT5'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'PO Qty'.
  fieldcat-seltext_m = 'PO Quantity'.
  fieldcat-seltext_l = 'PO Quantity'.
  fieldcat-decimals_out = '0'.
  fieldcat-no_zero = 'X'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'KZWI1'.
  fieldcat-ref_fieldname = 'KZWI1'.
  fieldcat-tabname = 'I_OUTPUT5'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'PO Amount'.
  fieldcat-seltext_m = 'PO Amount'.
  fieldcat-seltext_l = 'PO Amount'.
  fieldcat-currency = 'IDR'.
  fieldcat-decimals_out = '0'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out.

*  IF p_val = 'X'.
*    fieldcat-fieldname = 'BTAMT'.
*    fieldcat-ref_fieldname = 'BTAMT'.
*    fieldcat-tabname = 'I_OUTPUT5'.
*    fieldcat-outputlen = 13.
*    fieldcat-seltext_s = 'PO Batal'.
*    fieldcat-seltext_m = 'PO Batal'.
*    fieldcat-seltext_l = 'PO Batal'.
*    fieldcat-cfieldname = 'CURR'.
*    APPEND fieldcat. "clear fieldcat.
*  ELSE.
*    fieldcat-fieldname = 'BTQTY'.
*    fieldcat-ref_fieldname = 'BTQTY'.
*    fieldcat-tabname = 'I_OUTPUT5'.
*    fieldcat-outputlen = 13.
*    fieldcat-seltext_s = 'PO Batal'.
*    fieldcat-seltext_m = 'PO Batal'.
*    fieldcat-seltext_l = 'PO Batal'.
*    fieldcat-decimalsfieldname = 'DECI'.
*    APPEND fieldcat. "clear fieldcat.
*  ENDIF.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname,
         fieldcat-decimalsfieldname.

  fieldcat-fieldname = 'DLQTY'.
  fieldcat-ref_fieldname = 'DLQTY'.
  fieldcat-tabname = 'I_OUTPUT5'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'DO Qty'.
  fieldcat-seltext_m = 'DO Quantity'.
  fieldcat-seltext_l = 'DO Quantity'.
  fieldcat-decimals_out = '0'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname.

  fieldcat-fieldname = 'DLVAL'.
  fieldcat-ref_fieldname = 'DLVAL'.
  fieldcat-tabname = 'I_OUTPUT5'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'DO Amount'.
  fieldcat-seltext_m = 'DO AMount'.
  fieldcat-seltext_l = 'DO AMount'.
  fieldcat-cfieldname = 'CURR'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname.

  IF p_val = 'X'.
    fieldcat-fieldname = 'LEAD6'.
    fieldcat-ref_fieldname = 'LEAD6'.
    fieldcat-tabname = 'I_OUTPUT5'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Intransit'.
    fieldcat-seltext_m = 'Intransit'.
    fieldcat-seltext_l = 'Intransit'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD1'.
    fieldcat-ref_fieldname = 'LEAD1'.
    fieldcat-tabname = 'I_OUTPUT5'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead <= 3'.
    fieldcat-seltext_m = 'Lead <= 3'.
    fieldcat-seltext_l = 'Lead <= 3'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD2'.
    fieldcat-ref_fieldname = 'LEAD2'.
    fieldcat-tabname = 'I_OUTPUT5'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead = 4'.
    fieldcat-seltext_m = 'Lead = 4'.
    fieldcat-seltext_l = 'Lead = 4'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD3'.
    fieldcat-ref_fieldname = 'LEAD3'.
    fieldcat-tabname = 'I_OUTPUT5'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead >= 5'.
    fieldcat-seltext_m = 'Lead >= 5'.
    fieldcat-seltext_l = 'Lead >= 5'.
    APPEND fieldcat. "clear fieldcat.
  ELSE.
    fieldcat-fieldname = 'LEAD6Q'.
    fieldcat-ref_fieldname = 'LEAD6Q'.
    fieldcat-tabname = 'I_OUTPUT5'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Intransit'.
    fieldcat-seltext_m = 'Intransit'.
    fieldcat-seltext_l = 'Intransit'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD1Q'.
    fieldcat-ref_fieldname = 'LEAD1Q'.
    fieldcat-tabname = 'I_OUTPUT5'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead <= 3'.
    fieldcat-seltext_m = 'Lead <= 3'.
    fieldcat-seltext_l = 'Lead <= 3'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD2Q'.
    fieldcat-ref_fieldname = 'LEAD2Q'.
    fieldcat-tabname = 'I_OUTPUT5'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead = 4'.
    fieldcat-seltext_m = 'Lead = 4'.
    fieldcat-seltext_l = 'Lead = 4'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD3Q'.
    fieldcat-ref_fieldname = 'LEAD3Q'.
    fieldcat-tabname = 'I_OUTPUT5'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead >= 5'.
    fieldcat-seltext_m = 'Lead >= 5'.
    fieldcat-seltext_l = 'Lead >= 5'.
    APPEND fieldcat. "clear fieldcat.
  ENDIF.

*  fieldcat-fieldname = 'LEAD4'.
*  fieldcat-ref_fieldname = 'LEAD4'.
*  fieldcat-tabname = 'I_OUTPUT5'.
*  fieldcat-outputlen = 13.
*  fieldcat-cfieldname = 'CURR'.
*  fieldcat-seltext_s = 'Lead >= 6'.
*  fieldcat-seltext_m = 'Lead >= 6'.
*  fieldcat-seltext_l = 'Lead >= 6'.
*  APPEND fieldcat. "clear fieldcat.

*  fieldcat-fieldname = 'LEAD5'.
*  fieldcat-ref_fieldname = 'LEAD5'.
*  fieldcat-tabname = 'I_OUTPUT5'.
*  fieldcat-outputlen = 13.
*  fieldcat-cfieldname = 'CURR'.
*  fieldcat-seltext_s = 'Lead >= 7'.
*  fieldcat-seltext_m = 'Lead >= 7'.
*  fieldcat-seltext_l = 'Lead >= 7'.
*  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname,
         fieldcat-decimalsfieldname.

  IF p_val = 'X'.
    fieldcat-fieldname = 'UNVAL'.
    fieldcat-ref_fieldname = 'UNVAL'.
    fieldcat-tabname = 'I_OUTPUT5'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Undlv Amount'.
    fieldcat-seltext_m = 'Undelivered Amount'.
    fieldcat-seltext_l = 'Undelivered Amount'.
    APPEND fieldcat. "clear fieldcat.

*    fieldcat-fieldname = 'CLTOP'.
*    fieldcat-ref_fieldname = 'CLTOP'.
*    fieldcat-tabname = 'I_OUTPUT5'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'CL / TOP'.
*    fieldcat-seltext_m = 'CL / TOP'.
*    fieldcat-seltext_l = 'CL / TOP'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'STKOUT'.
*    fieldcat-ref_fieldname = 'STKOUT'.
*    fieldcat-tabname = 'I_OUTPUT5'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Stock Out'.
*    fieldcat-seltext_m = 'Stock Out'.
*    fieldcat-seltext_l = 'Stock Out'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'SALAH'.
*    fieldcat-ref_fieldname = 'SALAH'.
*    fieldcat-tabname = 'I_OUTPUT5'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Salah Harga'.
*    fieldcat-seltext_m = 'Salah Harga'.
*    fieldcat-seltext_l = 'Salah Harga'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'OTHER'.
*    fieldcat-ref_fieldname = 'OTHER'.
*    fieldcat-tabname = 'I_OUTPUT5'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Other'.
*    fieldcat-seltext_m = 'Other'.
*    fieldcat-seltext_l = 'Other'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'POOUT'.
*    fieldcat-ref_fieldname = 'POOUT'.
*    fieldcat-tabname = 'I_OUTPUT5'.
*    fieldcat-outputlen = 13.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'PO Outs'.
*    fieldcat-seltext_m = 'PO Outstanding'.
*    fieldcat-seltext_l = 'PO Outstanding'.
*    APPEND fieldcat. "clear fieldcat.
  ELSE.
    fieldcat-fieldname = 'UNQTY'.
    fieldcat-ref_fieldname = 'UNQTY'.
    fieldcat-tabname = 'I_OUTPUT5'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Undlv Qty'.
    fieldcat-seltext_m = 'Undelivered Quantity'.
    fieldcat-seltext_l = 'Undelivered Quantity'.
    APPEND fieldcat. "clear fieldcat.

*    fieldcat-fieldname = 'CLTOPQ'.
*    fieldcat-ref_fieldname = 'CLTOPQ'.
*    fieldcat-tabname = 'I_OUTPUT5'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'CL / TOP'.
*    fieldcat-seltext_m = 'CL / TOP'.
*    fieldcat-seltext_l = 'CL / TOP'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'STKOUTQ'.
*    fieldcat-ref_fieldname = 'STKOUTQ'.
*    fieldcat-tabname = 'I_OUTPUT5'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Stock Out'.
*    fieldcat-seltext_m = 'Stock Out'.
*    fieldcat-seltext_l = 'Stock Out'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'SALAHQ'.
*    fieldcat-ref_fieldname = 'SALAHQ'.
*    fieldcat-tabname = 'I_OUTPUT5'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Salah Harga'.
*    fieldcat-seltext_m = 'Salah Harga'.
*    fieldcat-seltext_l = 'Salah Harga'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'OTHERQ'.
*    fieldcat-ref_fieldname = 'OTHERQ'.
*    fieldcat-tabname = 'I_OUTPUT5'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Other'.
*    fieldcat-seltext_m = 'Other'.
*    fieldcat-seltext_l = 'Other'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'POOUTQ'.
*    fieldcat-ref_fieldname = 'POOUTQ'.
*    fieldcat-tabname = 'I_OUTPUT5'.
*    fieldcat-outputlen = 13.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'PO Outs'.
*    fieldcat-seltext_m = 'PO Outstanding'.
*    fieldcat-seltext_l = 'PO Outstanding'.
*    APPEND fieldcat. "clear fieldcat.
  ENDIF.

  mac_header5 : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.

ENDFORM.                    " f_build_fieldcat5

*&---------------------------------------------------------------------*
*&      Form  f_build_sortfield5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_SORT
*----------------------------------------------------------------------*
FORM f_build_sortfield5 USING fu_sort TYPE slis_t_sortinfo_alv.

  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'MATKL'.
  ld_sort-up        = 'X'.
  ld_sort-group     = '*'.
  APPEND ld_sort TO fu_sort.

  IF p_total5 IS INITIAL.
    CLEAR ld_sort.
    ld_sort-fieldname = 'KVGR4'.
    ld_sort-up        = 'X'.
    ld_sort-group     = '*'.
    APPEND ld_sort TO fu_sort.
  ELSE.
    CLEAR ld_sort.
    ld_sort-fieldname = 'KVGR4'.
    ld_sort-up        = 'X'.
*  ld_sort-group     = '*'.
    APPEND ld_sort TO fu_sort.
  ENDIF.

  CLEAR ld_sort.
  ld_sort-fieldname = 'VKBUX'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'INDEX'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  APPEND ld_sort TO fu_sort.

ENDFORM.                    " f_build_sortfield5

*&---------------------------------------------------------------------*
*&      Form  f_build_event5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_EVENTS
*----------------------------------------------------------------------*
FORM f_build_event5 TABLES ft_events LIKE t_events.

  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE5'.
  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_end_of_list.
*  ft_events-form = 'F_END_OF_LIST5'.
*  APPEND ft_events.

ENDFORM.                    " f_build_event5

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE5                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page5.

  DATA : l_line1(70),
         l_line2(60),
         l_matkl(80),
         l_kvgr4(80),
         l_fdate(10),
         l_tdate(10).

  WRITE s_erdat-low TO l_fdate.
  WRITE s_erdat-high TO l_tdate.
*--- Title
  CONCATENATE sy-title 'By Material Grp, Key Account Grp' '(05)'
              INTO l_line1 SEPARATED BY space.
*--- Period
  CONCATENATE 'Period :' l_fdate 'to' l_tdate
              INTO l_line2 SEPARATED BY space.
*--- Material Group
  CONCATENATE 'Material Group  :' i_output5-matkl
              INTO l_matkl SEPARATED BY space.
*--- Customer Group
  IF p_total5 IS INITIAL.
    CONCATENATE 'Key Account Grp :' i_output5-kvgr4 i_output5-bezei
                INTO l_kvgr4 SEPARATED BY space.
  ELSE.
    l_kvgr4 = 'SUMMARY'.
  ENDIF.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING l_line1.
  PERFORM f_hdr_line2 USING l_matkl l_line2.
  PERFORM f_hdr_line3 USING l_kvgr4 va_text.
  PERFORM f_hdr_uline.

ENDFORM.                    "f_top_of_page5

*&---------------------------------------------------------------------*
*&      Form  proses_data4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proses_data4.

  SORT i_detquot4  BY vkbur knkli princ matkl matnr.
*  SORT i_detsales BY vgbel posnr.
  SORT i_detsales BY vgbel vgpos.
  SORT i_detdelv  BY vgbel vgpos.
  LOOP AT i_detquot4.

    CLEAR : i_detsales, i_detdelv, i_output4. ", i_detquot4-abgru.

    READ TABLE i_detsales WITH KEY
                               vgbel = i_detquot4-vbeln
*                               posnr = i_detquot4-posnr BINARY SEARCH.
                               vgpos = i_detquot4-posnr. " BINARY SEARCH.
    IF sy-subrc = 0.
      IF i_detsales-abgru IS NOT INITIAL.
        i_detquot4-abgru = i_detsales-abgru.
      ENDIF.
    ENDIF.

    READ TABLE i_detdelv WITH KEY
                              vgbel = i_detsales-vbeln
                              vgpos = i_detsales-posnr. " BINARY SEARCH.

    PERFORM append_itab4.

* Total Material Group
    AT END OF matkl.
      wa_stot44-vkbur = i_output4-vkbur.
      wa_stot44-vkburt = i_output4-vkburt.
      wa_stot44-knkli = i_output4-knkli.
      wa_stot44-name1 = i_output4-name1.
      CONCATENATE '*    Total' i_output4-matkl
                  INTO wa_stot44-maktx SEPARATED BY space.
      wa_stot44-info = 'C30'.
      wa_stot44-curr = 'IDR'.
      wa_stot44-index = '20'.
      wa_stot44-deci = '0'.
      wa_stot44-matkx = i_output4-matkl.
      wa_stot44-prinx = i_output4-princ.
      APPEND wa_stot44 TO i_output4.

      wa_stot44-maktx = '           Percentage(%)'.
      IF wa_stot44-kzwi1 NE wa_stot44-btamt.
        IF p_val = 'X'.
          wa_stot44-dlval% = wa_stot44-dlval / ( wa_stot44-kzwi1 -
                             wa_stot44-btamt ) * 100.
          wa_stot44-unprc = wa_stot44-unval / ( wa_stot44-kzwi1 -
                            wa_stot44-btamt ) * 100.
          wa_stot44-lead1% = wa_stot44-lead1 / ( wa_stot44-kzwi1 -
                            wa_stot44-btamt ) * 100.
          wa_stot44-lead2% = wa_stot44-lead2 / ( wa_stot44-kzwi1 -
                            wa_stot44-btamt ) * 100.
          wa_stot44-lead3% = wa_stot44-lead3 / ( wa_stot44-kzwi1 -
                            wa_stot44-btamt ) * 100.
          wa_stot44-lead4% = wa_stot44-lead4 / ( wa_stot44-kzwi1 -
                            wa_stot44-btamt ) * 100.
          wa_stot44-lead5% = wa_stot44-lead5 / ( wa_stot44-kzwi1 -
                            wa_stot44-btamt ) * 100.
          wa_stot44-lead6% = wa_stot44-lead6 / ( wa_stot44-kzwi1 -
                            wa_stot44-btamt ) * 100.
          wa_stot44-poout% = wa_stot44-poout / ( wa_stot44-kzwi1 -
                            wa_stot44-btamt ) * 100.
          wa_stot44-btprc% = wa_stot44-btamt / wa_stot44-kzwi1 * 100.
          wa_stot44-stkout% = wa_stot44-stkout / ( wa_stot44-kzwi1 -
                            wa_stot44-btamt ) * 100.
          wa_stot44-cltop% = wa_stot44-cltop / ( wa_stot44-kzwi1 -
                            wa_stot44-btamt ) * 100.
          wa_stot44-salah% = wa_stot44-salah / ( wa_stot44-kzwi1 -
                            wa_stot44-btamt ) * 100.
          wa_stot44-other% = wa_stot44-other / ( wa_stot44-kzwi1 -
                            wa_stot44-btamt ) * 100.
          wa_stot44-reject% = wa_stot44-reject / ( wa_stot44-kzwi1 -
                            wa_stot44-btamt ) * 100.

          PERFORM f_hitung_stot4 USING wa_stot44-kzwi1
                                       wa_stot44-btamt
                                       wa_stot44-kwmeng
                                       wa_stot44-btqty
                                       p_val
                                       '4'.

        ELSE.
          wa_stot44-dlval% = wa_stot44-dlqty / ( wa_stot44-kwmeng -
                             wa_stot44-btqty ) * 100.
          wa_stot44-unprc = wa_stot44-unqty / ( wa_stot44-kwmeng -
                            wa_stot44-btqty ) * 100.
          wa_stot44-lead1% = wa_stot44-lead1q / ( wa_stot44-kwmeng -
                            wa_stot44-btqty ) * 100.
          wa_stot44-lead2% = wa_stot44-lead2q / ( wa_stot44-kwmeng -
                            wa_stot44-btqty ) * 100.
          wa_stot44-lead3% = wa_stot44-lead3q / ( wa_stot44-kwmeng -
                            wa_stot44-btqty ) * 100.
          wa_stot44-lead4% = wa_stot44-lead4q / ( wa_stot44-kwmeng -
                            wa_stot44-btqty ) * 100.
          wa_stot44-lead5% = wa_stot44-lead5q / ( wa_stot44-kwmeng -
                            wa_stot44-btqty ) * 100.
          wa_stot44-lead6% = wa_stot44-lead6q / ( wa_stot44-kwmeng -
                            wa_stot44-btqty ) * 100.
          wa_stot44-poout% = wa_stot44-pooutq / ( wa_stot44-kwmeng -
                            wa_stot44-btqty ) * 100.
          wa_stot44-btprc% = wa_stot44-btqty / wa_stot44-kwmeng * 100.
          wa_stot44-stkout% = wa_stot44-stkoutq / ( wa_stot44-kwmeng -
                            wa_stot44-btqty ) * 100.
          wa_stot44-cltop% = wa_stot44-cltopq / ( wa_stot44-kwmeng -
                            wa_stot44-btqty ) * 100.
          wa_stot44-salah% = wa_stot44-salahq / ( wa_stot44-kwmeng -
                            wa_stot44-btqty ) * 100.
          wa_stot44-other% = wa_stot44-otherq / ( wa_stot44-kwmeng -
                            wa_stot44-btqty ) * 100.
          wa_stot44-reject% = wa_stot44-rejectq / ( wa_stot44-kwmeng -
                            wa_stot44-btqty ) * 100.

          PERFORM f_hitung_stot4 USING wa_stot44-kzwi1
                                       wa_stot44-btamt
                                       wa_stot44-kwmeng
                                       wa_stot44-btqty
                                       p_val
                                       '4'.

        ENDIF.
      ENDIF.

      wa_stot44-dlval = wa_stot44-dlval%.
      IF p_val = 'X'.
        wa_stot44-unval = wa_stot44-unprc.
        wa_stot44-lead1 = wa_stot44-lead1%.
        wa_stot44-lead2 = wa_stot44-lead2%.
        wa_stot44-lead3 = wa_stot44-lead3%.
        wa_stot44-lead4 = wa_stot44-lead4%.
        wa_stot44-lead5 = wa_stot44-lead5%.
        wa_stot44-lead6 = wa_stot44-lead6%.
        wa_stot44-poout = wa_stot44-poout%.
        wa_stot44-btamt = wa_stot44-btprc%.
        wa_stot44-stkout = wa_stot44-stkout%.
        wa_stot44-cltop = wa_stot44-cltop%.
        wa_stot44-salah = wa_stot44-salah%.
        wa_stot44-other = wa_stot44-other%.
        wa_stot44-reject = wa_stot44-reject%.

        PERFORM f_move_stot4 USING p_val '4'.

      ELSE.
        wa_stot44-unqty = wa_stot44-unprc.
        wa_stot44-lead1q = wa_stot44-lead1%.
        wa_stot44-lead2q = wa_stot44-lead2%.
        wa_stot44-lead3q = wa_stot44-lead3%.
        wa_stot44-lead4q = wa_stot44-lead4%.
        wa_stot44-lead5q = wa_stot44-lead5%.
        wa_stot44-lead6q = wa_stot44-lead6%.
        wa_stot44-pooutq = wa_stot44-poout%.
        wa_stot44-btqty = wa_stot44-btprc%.
        wa_stot44-stkoutq = wa_stot44-stkout%.
        wa_stot44-cltopq = wa_stot44-cltop%.
        wa_stot44-salahq = wa_stot44-salah%.
        wa_stot44-otherq = wa_stot44-other%.
        wa_stot44-rejectq = wa_stot44-reject%.

        PERFORM f_move_stot4 USING p_val '4'.

      ENDIF.
      wa_stot44-deci = '2'.
      CLEAR: wa_stot44-curr, wa_stot44-kwmeng,
             wa_stot44-kzwi1, wa_stot44-dlqty.
      APPEND wa_stot44 TO i_output4.
      CLEAR: wa_stot44.
    ENDAT.

* Total Principal
    AT END OF princ.
      wa_stot43-vkbur = i_output4-vkbur.
      wa_stot43-vkburt = i_output4-vkburt.
      wa_stot43-knkli = i_output4-knkli.
      wa_stot43-name1 = i_output4-name1.
      CONCATENATE '*    Total' i_output4-princ
                  INTO wa_stot43-maktx SEPARATED BY space.
      wa_stot43-info = 'C30'.
      wa_stot43-curr = 'IDR'.
      wa_stot43-index = '30'.
      wa_stot43-deci = '0'.
      wa_stot43-matkx = i_output4-matkl.
      wa_stot43-prinx = i_output4-princ.
      APPEND wa_stot43 TO i_output4.

      wa_stot43-maktx = '           Percentage(%)'.
      IF wa_stot43-kzwi1 NE wa_stot43-btamt.
        IF p_val = 'X'.
          wa_stot43-dlval% = wa_stot43-dlval / ( wa_stot43-kzwi1 -
                             wa_stot43-btamt ) * 100.
          wa_stot43-unprc = wa_stot43-unval / ( wa_stot43-kzwi1 -
                            wa_stot43-btamt ) * 100.
          wa_stot43-lead1% = wa_stot43-lead1 / ( wa_stot43-kzwi1 -
                            wa_stot43-btamt ) * 100.
          wa_stot43-lead2% = wa_stot43-lead2 / ( wa_stot43-kzwi1 -
                            wa_stot43-btamt ) * 100.
          wa_stot43-lead3% = wa_stot43-lead3 / ( wa_stot43-kzwi1 -
                            wa_stot43-btamt ) * 100.
          wa_stot43-lead4% = wa_stot43-lead4 / ( wa_stot43-kzwi1 -
                            wa_stot43-btamt ) * 100.
          wa_stot43-lead5% = wa_stot43-lead5 / ( wa_stot43-kzwi1 -
                            wa_stot43-btamt ) * 100.
          wa_stot43-lead6% = wa_stot43-lead6 / ( wa_stot43-kzwi1 -
                            wa_stot43-btamt ) * 100.
          wa_stot43-poout% = wa_stot43-poout / ( wa_stot43-kzwi1 -
                            wa_stot43-btamt ) * 100.
          wa_stot43-btprc% = wa_stot43-btamt / wa_stot43-kzwi1 * 100.
          wa_stot43-stkout% = wa_stot43-stkout / ( wa_stot43-kzwi1 -
                            wa_stot43-btamt ) * 100.
          wa_stot43-cltop% = wa_stot43-cltop / ( wa_stot43-kzwi1 -
                            wa_stot43-btamt ) * 100.
          wa_stot43-salah% = wa_stot43-salah / ( wa_stot43-kzwi1 -
                            wa_stot43-btamt ) * 100.
          wa_stot43-other% = wa_stot43-other / ( wa_stot43-kzwi1 -
                            wa_stot43-btamt ) * 100.
          wa_stot43-reject% = wa_stot43-reject / ( wa_stot43-kzwi1 -
                            wa_stot43-btamt ) * 100.

          PERFORM f_hitung_stot3 USING wa_stot43-kzwi1
                                       wa_stot43-btamt
                                       wa_stot43-kwmeng
                                       wa_stot43-btqty
                                       p_val
                                       '4'.

        ELSE.
          wa_stot43-dlval% = wa_stot43-dlqty / ( wa_stot43-kwmeng -
                             wa_stot43-btqty ) * 100.
          wa_stot43-unprc = wa_stot43-unqty / ( wa_stot43-kwmeng -
                            wa_stot43-btqty ) * 100.
          wa_stot43-lead1% = wa_stot43-lead1q / ( wa_stot43-kwmeng -
                            wa_stot43-btqty ) * 100.
          wa_stot43-lead2% = wa_stot43-lead2q / ( wa_stot43-kwmeng -
                            wa_stot43-btqty ) * 100.
          wa_stot43-lead3% = wa_stot43-lead3q / ( wa_stot43-kwmeng -
                            wa_stot43-btqty ) * 100.
          wa_stot43-lead4% = wa_stot43-lead4q / ( wa_stot43-kwmeng -
                            wa_stot43-btqty ) * 100.
          wa_stot43-lead5% = wa_stot43-lead5q / ( wa_stot43-kwmeng -
                            wa_stot43-btqty ) * 100.
          wa_stot43-lead6% = wa_stot43-lead6q / ( wa_stot43-kwmeng -
                            wa_stot43-btqty ) * 100.
          wa_stot43-poout% = wa_stot43-pooutq / ( wa_stot43-kwmeng -
                            wa_stot43-btqty ) * 100.
          wa_stot43-btprc% = wa_stot43-btqty / wa_stot43-kwmeng * 100.
          wa_stot43-stkout% = wa_stot43-stkoutq / ( wa_stot43-kwmeng -
                            wa_stot43-btqty ) * 100.
          wa_stot43-cltop% = wa_stot43-cltopq / ( wa_stot43-kwmeng -
                            wa_stot43-btqty ) * 100.
          wa_stot43-salah% = wa_stot43-salahq / ( wa_stot43-kwmeng -
                            wa_stot43-btqty ) * 100.
          wa_stot43-other% = wa_stot43-otherq / ( wa_stot43-kwmeng -
                            wa_stot43-btqty ) * 100.
          wa_stot43-reject% = wa_stot43-rejectq / ( wa_stot43-kwmeng -
                            wa_stot43-btqty ) * 100.

          PERFORM f_hitung_stot3 USING wa_stot43-kzwi1
                                       wa_stot43-btamt
                                       wa_stot43-kwmeng
                                       wa_stot43-btqty
                                       p_val
                                       '4'.

        ENDIF.
      ENDIF.

      wa_stot43-dlval = wa_stot43-dlval%.
      IF p_val = 'X'.
        wa_stot43-unval = wa_stot43-unprc.
        wa_stot43-lead1 = wa_stot43-lead1%.
        wa_stot43-lead2 = wa_stot43-lead2%.
        wa_stot43-lead3 = wa_stot43-lead3%.
        wa_stot43-lead4 = wa_stot43-lead4%.
        wa_stot43-lead5 = wa_stot43-lead5%.
        wa_stot43-lead6 = wa_stot43-lead6%.
        wa_stot43-poout = wa_stot43-poout%.
        wa_stot43-btamt = wa_stot43-btprc%.
        wa_stot43-stkout = wa_stot43-stkout%.
        wa_stot43-cltop = wa_stot43-cltop%.
        wa_stot43-salah = wa_stot43-salah%.
        wa_stot43-other = wa_stot43-other%.
        wa_stot43-reject = wa_stot43-reject%.

        PERFORM f_move_stot3 USING p_val '4'.

      ELSE.
        wa_stot43-unqty = wa_stot43-unprc.
        wa_stot43-lead1q = wa_stot43-lead1%.
        wa_stot43-lead2q = wa_stot43-lead2%.
        wa_stot43-lead3q = wa_stot43-lead3%.
        wa_stot43-lead4q = wa_stot43-lead4%.
        wa_stot43-lead5q = wa_stot43-lead5%.
        wa_stot43-lead6q = wa_stot43-lead6%.
        wa_stot43-pooutq = wa_stot43-poout%.
        wa_stot43-btqty = wa_stot43-btprc%.
        wa_stot43-stkoutq = wa_stot43-stkout%.
        wa_stot43-cltopq = wa_stot43-cltop%.
        wa_stot43-salahq = wa_stot43-salah%.
        wa_stot43-otherq = wa_stot43-other%.
        wa_stot43-rejectq = wa_stot43-reject%.

        PERFORM f_move_stot3 USING p_val '4'.

      ENDIF.
      wa_stot43-deci = '2'.
      CLEAR: wa_stot43-curr, wa_stot43-kwmeng,
             wa_stot43-kzwi1, wa_stot43-dlqty.
      APPEND wa_stot43 TO i_output4.
      CLEAR: wa_stot43, wa_stot44.
    ENDAT.

* Total Customer Group
    AT END OF knkli.
      wa_stot42-vkbur = i_output4-vkbur.
      wa_stot42-vkburt = i_output4-vkburt.
      wa_stot42-knkli = i_output4-knkli.
      wa_stot42-name1 = i_output4-name1.
      CONCATENATE '**   Total' i_output4-knkli i_output4-name1
                  INTO wa_stot42-maktx SEPARATED BY space.
      wa_stot42-info = 'C31'.
      wa_stot42-curr = 'IDR'.
      wa_stot42-index = '40'.
      wa_stot42-deci = '0'.
      wa_stot42-matkx = i_output4-matkl.
      wa_stot42-prinx = i_output4-princ.
      APPEND wa_stot42 TO i_output4.

      wa_stot42-maktx = '           Percentage(%)'.
      IF wa_stot42-kzwi1 NE wa_stot42-btamt.
        IF p_val = 'X'.
          wa_stot42-dlval% = wa_stot42-dlval / ( wa_stot42-kzwi1 -
                             wa_stot42-btamt ) * 100.
          wa_stot42-unprc = wa_stot42-unval / ( wa_stot42-kzwi1 -
                            wa_stot42-btamt ) * 100.
          wa_stot42-lead1% = wa_stot42-lead1 / ( wa_stot42-kzwi1 -
                            wa_stot42-btamt ) * 100.
          wa_stot42-lead2% = wa_stot42-lead2 / ( wa_stot42-kzwi1 -
                            wa_stot42-btamt ) * 100.
          wa_stot42-lead3% = wa_stot42-lead3 / ( wa_stot42-kzwi1 -
                            wa_stot42-btamt ) * 100.
          wa_stot42-lead4% = wa_stot42-lead4 / ( wa_stot42-kzwi1 -
                            wa_stot42-btamt ) * 100.
          wa_stot42-lead5% = wa_stot42-lead5 / ( wa_stot42-kzwi1 -
                            wa_stot42-btamt ) * 100.
          wa_stot42-lead6% = wa_stot42-lead6 / ( wa_stot42-kzwi1 -
                            wa_stot42-btamt ) * 100.
          wa_stot42-poout% = wa_stot42-poout / ( wa_stot42-kzwi1 -
                            wa_stot42-btamt ) * 100.
          wa_stot42-btprc% = wa_stot42-btamt / wa_stot42-kzwi1 * 100.
          wa_stot42-stkout% = wa_stot42-stkout / ( wa_stot42-kzwi1 -
                            wa_stot42-btamt ) * 100.
          wa_stot42-cltop% = wa_stot42-cltop / ( wa_stot42-kzwi1 -
                            wa_stot42-btamt ) * 100.
          wa_stot42-salah% = wa_stot42-salah / ( wa_stot42-kzwi1 -
                            wa_stot42-btamt ) * 100.
          wa_stot42-other% = wa_stot42-other / ( wa_stot42-kzwi1 -
                            wa_stot42-btamt ) * 100.
          wa_stot42-reject% = wa_stot42-reject / ( wa_stot42-kzwi1 -
                            wa_stot42-btamt ) * 100.

          PERFORM f_hitung_stot2 USING wa_stot42-kzwi1
                                       wa_stot42-btamt
                                       wa_stot42-kwmeng
                                       wa_stot42-btqty
                                       p_val
                                       '4'.

        ELSE.
          wa_stot42-dlval% = wa_stot42-dlqty / ( wa_stot42-kwmeng -
                             wa_stot42-btqty ) * 100.
          wa_stot42-unprc = wa_stot42-unqty / ( wa_stot42-kwmeng -
                            wa_stot42-btqty ) * 100.
          wa_stot42-lead1% = wa_stot42-lead1q / ( wa_stot42-kwmeng -
                            wa_stot42-btqty ) * 100.
          wa_stot42-lead2% = wa_stot42-lead2q / ( wa_stot42-kwmeng -
                            wa_stot42-btqty ) * 100.
          wa_stot42-lead3% = wa_stot42-lead3q / ( wa_stot42-kwmeng -
                            wa_stot42-btqty ) * 100.
          wa_stot42-lead4% = wa_stot42-lead4q / ( wa_stot42-kwmeng -
                            wa_stot42-btqty ) * 100.
          wa_stot42-lead5% = wa_stot42-lead5q / ( wa_stot42-kwmeng -
                            wa_stot42-btqty ) * 100.
          wa_stot42-lead6% = wa_stot42-lead6q / ( wa_stot42-kwmeng -
                            wa_stot42-btqty ) * 100.
          wa_stot42-poout% = wa_stot42-pooutq / ( wa_stot42-kwmeng -
                            wa_stot42-btqty ) * 100.
          wa_stot42-btprc% = wa_stot42-btqty / wa_stot42-kwmeng * 100.
          wa_stot42-stkout% = wa_stot42-stkoutq / ( wa_stot42-kwmeng -
                            wa_stot42-btqty ) * 100.
          wa_stot42-cltop% = wa_stot42-cltopq / ( wa_stot42-kwmeng -
                            wa_stot42-btqty ) * 100.
          wa_stot42-salah% = wa_stot42-salahq / ( wa_stot42-kwmeng -
                            wa_stot42-btqty ) * 100.
          wa_stot42-other% = wa_stot42-otherq / ( wa_stot42-kwmeng -
                            wa_stot42-btqty ) * 100.
          wa_stot42-reject% = wa_stot42-rejectq / ( wa_stot42-kwmeng -
                            wa_stot42-btqty ) * 100.

          PERFORM f_hitung_stot2 USING wa_stot42-kzwi1
                                       wa_stot42-btamt
                                       wa_stot42-kwmeng
                                       wa_stot42-btqty
                                       p_val
                                       '4'.

        ENDIF.
      ENDIF.

      wa_stot42-dlval = wa_stot42-dlval%.
      IF p_val = 'X'.
        wa_stot42-unval = wa_stot42-unprc.
        wa_stot42-lead1 = wa_stot42-lead1%.
        wa_stot42-lead2 = wa_stot42-lead2%.
        wa_stot42-lead3 = wa_stot42-lead3%.
        wa_stot42-lead4 = wa_stot42-lead4%.
        wa_stot42-lead5 = wa_stot42-lead5%.
        wa_stot42-lead6 = wa_stot42-lead6%.
        wa_stot42-poout = wa_stot42-poout%.
        wa_stot42-btamt = wa_stot42-btprc%.
        wa_stot42-stkout = wa_stot42-stkout%.
        wa_stot42-cltop = wa_stot42-cltop%.
        wa_stot42-salah = wa_stot42-salah%.
        wa_stot42-other = wa_stot42-other%.
        wa_stot42-reject = wa_stot42-reject%.

        PERFORM f_move_stot2 USING p_val '4'.

      ELSE.
        wa_stot42-unqty = wa_stot42-unprc.
        wa_stot42-lead1q = wa_stot42-lead1%.
        wa_stot42-lead2q = wa_stot42-lead2%.
        wa_stot42-lead3q = wa_stot42-lead3%.
        wa_stot42-lead4q = wa_stot42-lead4%.
        wa_stot42-lead5q = wa_stot42-lead5%.
        wa_stot42-lead6q = wa_stot42-lead6%.
        wa_stot42-pooutq = wa_stot42-poout%.
        wa_stot42-btqty = wa_stot42-btprc%.
        wa_stot42-stkoutq = wa_stot42-stkout%.
        wa_stot42-cltopq = wa_stot42-cltop%.
        wa_stot42-salahq = wa_stot42-salah%.
        wa_stot42-otherq = wa_stot42-other%.
        wa_stot42-rejectq = wa_stot42-reject%.

        PERFORM f_move_stot2 USING p_val '4'.

      ENDIF.
      wa_stot42-deci = '2'.
      CLEAR: wa_stot42-curr, wa_stot42-kwmeng,
             wa_stot42-kzwi1, wa_stot42-dlqty.
      APPEND wa_stot42 TO i_output4.
      CLEAR: wa_stot42, wa_stot43, wa_stot44.
    ENDAT.

* Total Sales Office
    AT END OF vkbur.
      wa_stot41-vkbur = i_output4-vkbur.
      wa_stot41-vkburt = i_output4-vkburt.
      wa_stot41-knkli = i_output4-knkli.
      wa_stot41-name1 = i_output4-name1.
      CONCATENATE '***  Total' i_output4-vkbur
                  INTO wa_stot41-maktx SEPARATED BY space.
      wa_stot41-info = 'C70'.
      wa_stot41-curr = 'IDR'.
      wa_stot41-index = '50'.
      wa_stot41-deci = '0'.
      wa_stot41-matkx = i_output4-matkl.
      wa_stot41-prinx = i_output4-princ.
      APPEND wa_stot41 TO i_output4.

      wa_stot41-maktx = '           Percentage(%)'.
      IF wa_stot41-kzwi1 NE wa_stot41-btamt.
        IF p_val = 'X'.
          wa_stot41-unprc = wa_stot41-unval / ( wa_stot41-kzwi1 -
                            wa_stot41-btamt ) * 100.
          wa_stot41-dlval% = wa_stot41-dlval / ( wa_stot41-kzwi1 -
                             wa_stot41-btamt ) * 100.
          wa_stot41-lead1% = wa_stot41-lead1 / ( wa_stot41-kzwi1 -
                            wa_stot41-btamt ) * 100.
          wa_stot41-lead2% = wa_stot41-lead2 / ( wa_stot41-kzwi1 -
                            wa_stot41-btamt ) * 100.
          wa_stot41-lead3% = wa_stot41-lead3 / ( wa_stot41-kzwi1 -
                            wa_stot41-btamt ) * 100.
          wa_stot41-lead4% = wa_stot41-lead4 / ( wa_stot41-kzwi1 -
                            wa_stot41-btamt ) * 100.
          wa_stot41-lead5% = wa_stot41-lead5 / ( wa_stot41-kzwi1 -
                            wa_stot41-btamt ) * 100.
          wa_stot41-lead6% = wa_stot41-lead6 / ( wa_stot41-kzwi1 -
                            wa_stot41-btamt ) * 100.
          wa_stot41-poout% = wa_stot41-poout / ( wa_stot41-kzwi1 -
                            wa_stot41-btamt ) * 100.
          wa_stot41-btprc% = wa_stot41-btamt / wa_stot41-kzwi1 * 100.
          wa_stot41-stkout% = wa_stot41-stkout / ( wa_stot41-kzwi1 -
                            wa_stot41-btamt ) * 100.
          wa_stot41-cltop% = wa_stot41-cltop / ( wa_stot41-kzwi1 -
                            wa_stot41-btamt ) * 100.
          wa_stot41-salah% = wa_stot41-salah / ( wa_stot41-kzwi1 -
                            wa_stot41-btamt ) * 100.
          wa_stot41-other% = wa_stot41-other / ( wa_stot41-kzwi1 -
                            wa_stot41-btamt ) * 100.
          wa_stot41-reject% = wa_stot41-reject / ( wa_stot41-kzwi1 -
                            wa_stot41-btamt ) * 100.

          PERFORM f_hitung_stot1 USING wa_stot41-kzwi1
                                       wa_stot41-btamt
                                       wa_stot41-kwmeng
                                       wa_stot41-btqty
                                       p_val
                                       '4'.

        ELSE.
          wa_stot41-unprc = wa_stot41-unqty / ( wa_stot41-kwmeng -
                            wa_stot41-btqty ) * 100.
          wa_stot41-dlval% = wa_stot41-dlqty / ( wa_stot41-kwmeng -
                             wa_stot41-btqty ) * 100.
          wa_stot41-lead1% = wa_stot41-lead1q / ( wa_stot41-kwmeng -
                            wa_stot41-btqty ) * 100.
          wa_stot41-lead2% = wa_stot41-lead2q / ( wa_stot41-kwmeng -
                            wa_stot41-btqty ) * 100.
          wa_stot41-lead3% = wa_stot41-lead3q / ( wa_stot41-kwmeng -
                            wa_stot41-btqty ) * 100.
          wa_stot41-lead4% = wa_stot41-lead4q / ( wa_stot41-kwmeng -
                            wa_stot41-btqty ) * 100.
          wa_stot41-lead5% = wa_stot41-lead5q / ( wa_stot41-kwmeng -
                            wa_stot41-btqty ) * 100.
          wa_stot41-lead6% = wa_stot41-lead6q / ( wa_stot41-kwmeng -
                            wa_stot41-btqty ) * 100.
          wa_stot41-poout% = wa_stot41-pooutq / ( wa_stot41-kwmeng -
                            wa_stot41-btqty ) * 100.
          wa_stot41-btprc% = wa_stot41-btqty / wa_stot41-kwmeng * 100.
          wa_stot41-stkout% = wa_stot41-stkoutq / ( wa_stot41-kwmeng -
                            wa_stot41-btqty ) * 100.
          wa_stot41-cltop% = wa_stot41-cltopq / ( wa_stot41-kwmeng -
                            wa_stot41-btqty ) * 100.
          wa_stot41-salah% = wa_stot41-salahq / ( wa_stot41-kwmeng -
                            wa_stot41-btqty ) * 100.
          wa_stot41-other% = wa_stot41-otherq / ( wa_stot41-kwmeng -
                            wa_stot41-btqty ) * 100.
          wa_stot41-reject% = wa_stot41-rejectq / ( wa_stot41-kwmeng -
                            wa_stot41-btqty ) * 100.

          PERFORM f_hitung_stot1 USING wa_stot41-kzwi1
                                       wa_stot41-btamt
                                       wa_stot41-kwmeng
                                       wa_stot41-btqty
                                       p_val
                                       '4'.

        ENDIF.
      ENDIF.

      wa_stot41-dlval = wa_stot41-dlval%.
      IF p_val = 'X'.
        wa_stot41-unval = wa_stot41-unprc.
        wa_stot41-lead1 = wa_stot41-lead1%.
        wa_stot41-lead2 = wa_stot41-lead2%.
        wa_stot41-lead3 = wa_stot41-lead3%.
        wa_stot41-lead4 = wa_stot41-lead4%.
        wa_stot41-lead5 = wa_stot41-lead5%.
        wa_stot41-lead6 = wa_stot41-lead6%.
        wa_stot41-poout = wa_stot41-poout%.
        wa_stot41-btamt = wa_stot41-btprc%.
        wa_stot41-stkout = wa_stot41-stkout%.
        wa_stot41-cltop = wa_stot41-cltop%.
        wa_stot41-salah = wa_stot41-salah%.
        wa_stot41-other = wa_stot41-other%.
        wa_stot41-reject = wa_stot41-reject%.

        PERFORM f_move_stot1 USING p_val '4'.

      ELSE.
        wa_stot41-unqty = wa_stot41-unprc.
        wa_stot41-lead1q = wa_stot41-lead1%.
        wa_stot41-lead2q = wa_stot41-lead2%.
        wa_stot41-lead3q = wa_stot41-lead3%.
        wa_stot41-lead4q = wa_stot41-lead4%.
        wa_stot41-lead5q = wa_stot41-lead5%.
        wa_stot41-lead6q = wa_stot41-lead6%.
        wa_stot41-pooutq = wa_stot41-poout%.
        wa_stot41-btqty = wa_stot41-btprc%.
        wa_stot41-stkoutq = wa_stot41-stkout%.
        wa_stot41-cltopq = wa_stot41-cltop%.
        wa_stot41-salahq = wa_stot41-salah%.
        wa_stot41-otherq = wa_stot41-other%.
        wa_stot41-rejectq = wa_stot41-reject%.

        PERFORM f_move_stot1 USING p_val '4'.

      ENDIF.
      wa_stot41-deci = '2'.
      CLEAR: wa_stot41-curr, wa_stot41-kwmeng,
             wa_stot41-kzwi1, wa_stot41-dlqty.
      APPEND wa_stot41 TO i_output4.
      CLEAR: wa_stot41, wa_stot42, wa_stot43, wa_stot44.
    ENDAT.

  ENDLOOP.

* Total Grand
  wa_gtot4-vkbur = i_output4-vkbur.
  wa_gtot4-vkburt = i_output4-vkburt.
  wa_gtot4-knkli = i_output4-knkli.
  wa_gtot4-name1 = i_output4-name1.
  wa_gtot4-maktx = '**** Grand Total'.
  wa_gtot4-info = 'C71'.
  wa_gtot4-curr = 'IDR'.
  wa_gtot4-index = '60'.
  wa_gtot4-deci = '0'.
  wa_gtot4-matkx = i_output4-matkl.
  wa_gtot4-prinx = i_output4-princ.
  APPEND wa_gtot4 TO i_output4.

  wa_gtot4-maktx = '           Percentage(%)'.
  IF wa_gtot4-kzwi1 NE wa_gtot4-btamt.
    IF p_val = 'X'.
      wa_gtot4-unprc = wa_gtot4-unval / ( wa_gtot4-kzwi1 -
                            wa_gtot4-btamt ) * 100.
      wa_gtot4-dlval% = wa_gtot4-dlval / ( wa_gtot4-kzwi1 -
                            wa_gtot4-btamt ) * 100.
      wa_gtot4-lead1% = wa_gtot4-lead1 / ( wa_gtot4-kzwi1 -
                            wa_gtot4-btamt ) * 100.
      wa_gtot4-lead2% = wa_gtot4-lead2 / ( wa_gtot4-kzwi1 -
                            wa_gtot4-btamt ) * 100.
      wa_gtot4-lead3% = wa_gtot4-lead3 / ( wa_gtot4-kzwi1 -
                            wa_gtot4-btamt ) * 100.
      wa_gtot4-lead4% = wa_gtot4-lead4 / ( wa_gtot4-kzwi1 -
                            wa_gtot4-btamt ) * 100.
      wa_gtot4-lead5% = wa_gtot4-lead5 / ( wa_gtot4-kzwi1 -
                            wa_gtot4-btamt ) * 100.
      wa_gtot4-lead6% = wa_gtot4-lead6 / ( wa_gtot4-kzwi1 -
                            wa_gtot4-btamt ) * 100.
      wa_gtot4-poout% = wa_gtot4-poout / ( wa_gtot4-kzwi1 -
                            wa_gtot4-btamt ) * 100.
      wa_gtot4-btprc% = wa_gtot4-btamt / wa_gtot4-kzwi1 * 100.
      wa_gtot4-stkout% = wa_gtot4-stkout / ( wa_gtot4-kzwi1 -
                            wa_gtot4-btamt ) * 100.
      wa_gtot4-cltop% = wa_gtot4-cltop / ( wa_gtot4-kzwi1 -
                        wa_gtot4-btamt ) * 100.
      wa_gtot4-salah% = wa_gtot4-salah / ( wa_gtot4-kzwi1 -
                        wa_gtot4-btamt ) * 100.
      wa_gtot4-other% = wa_gtot4-other / ( wa_gtot4-kzwi1 -
                        wa_gtot4-btamt ) * 100.
      wa_gtot4-reject% = wa_gtot4-reject / ( wa_gtot4-kzwi1 -
                            wa_gtot4-btamt ) * 100.

      PERFORM f_hitung_gtot USING wa_gtot4-kzwi1
                                   wa_gtot4-btamt
                                   wa_gtot4-kwmeng
                                   wa_gtot4-btqty
                                   p_val
                                   '4'.

    ELSE.
      wa_gtot4-unprc = wa_gtot4-unqty / ( wa_gtot4-kwmeng -
                            wa_gtot4-btqty ) * 100.
      wa_gtot4-dlval% = wa_gtot4-dlqty / ( wa_gtot4-kwmeng -
                            wa_gtot4-btqty ) * 100.
      wa_gtot4-lead1% = wa_gtot4-lead1q / ( wa_gtot4-kwmeng -
                            wa_gtot4-btqty ) * 100.
      wa_gtot4-lead2% = wa_gtot4-lead2q / ( wa_gtot4-kwmeng -
                            wa_gtot4-btqty ) * 100.
      wa_gtot4-lead3% = wa_gtot4-lead3q / ( wa_gtot4-kwmeng -
                            wa_gtot4-btqty ) * 100.
      wa_gtot4-lead4% = wa_gtot4-lead4q / ( wa_gtot4-kwmeng -
                            wa_gtot4-btqty ) * 100.
      wa_gtot4-lead5% = wa_gtot4-lead5q / ( wa_gtot4-kwmeng -
                            wa_gtot4-btqty ) * 100.
      wa_gtot4-lead6% = wa_gtot4-lead6q / ( wa_gtot4-kwmeng -
                            wa_gtot4-btqty ) * 100.
      wa_gtot4-poout% = wa_gtot4-pooutq / ( wa_gtot4-kwmeng -
                            wa_gtot4-btqty ) * 100.
      wa_gtot4-btprc% = wa_gtot4-btqty / wa_gtot4-kwmeng * 100.
      wa_gtot4-stkout% = wa_gtot4-stkoutq / ( wa_gtot4-kwmeng -
                            wa_gtot4-btqty ) * 100.
      wa_gtot4-cltop% = wa_gtot4-cltopq / ( wa_gtot4-kwmeng -
                        wa_gtot4-btqty ) * 100.
      wa_gtot4-salah% = wa_gtot4-salahq / ( wa_gtot4-kwmeng -
                        wa_gtot4-btqty ) * 100.
      wa_gtot4-other% = wa_gtot4-otherq / ( wa_gtot4-kwmeng -
                        wa_gtot4-btqty ) * 100.
      wa_gtot4-reject% = wa_gtot4-rejectq / ( wa_gtot4-kwmeng -
                        wa_gtot4-btqty ) * 100.

      PERFORM f_hitung_gtot USING wa_gtot4-kzwi1
                                   wa_gtot4-btamt
                                   wa_gtot4-kwmeng
                                   wa_gtot4-btqty
                                   p_val
                                   '4'.

    ENDIF.
  ENDIF.

  wa_gtot4-dlval = wa_gtot4-dlval%.
  IF p_val = 'X'.
    wa_gtot4-unval = wa_gtot4-unprc.
    wa_gtot4-lead1 = wa_gtot4-lead1%.
    wa_gtot4-lead2 = wa_gtot4-lead2%.
    wa_gtot4-lead3 = wa_gtot4-lead3%.
    wa_gtot4-lead4 = wa_gtot4-lead4%.
    wa_gtot4-lead5 = wa_gtot4-lead5%.
    wa_gtot4-lead6 = wa_gtot4-lead6%.
    wa_gtot4-poout = wa_gtot4-poout%.
    wa_gtot4-btamt = wa_gtot4-btprc%.
    wa_gtot4-stkout = wa_gtot4-stkout%.
    wa_gtot4-cltop = wa_gtot4-cltop%.
    wa_gtot4-salah = wa_gtot4-salah%.
    wa_gtot4-other = wa_gtot4-other%.
    wa_gtot4-reject = wa_gtot4-reject%.

    PERFORM f_move_gtot USING p_val '4'.

  ELSE.
    wa_gtot4-unqty = wa_gtot4-unprc.
    wa_gtot4-lead1q = wa_gtot4-lead1%.
    wa_gtot4-lead2q = wa_gtot4-lead2%.
    wa_gtot4-lead3q = wa_gtot4-lead3%.
    wa_gtot4-lead4q = wa_gtot4-lead4%.
    wa_gtot4-lead5q = wa_gtot4-lead5%.
    wa_gtot4-lead6q = wa_gtot4-lead6%.
    wa_gtot4-pooutq = wa_gtot4-poout%.
    wa_gtot4-btqty = wa_gtot4-btprc%.
    wa_gtot4-cltopq = wa_gtot4-cltop%.
    wa_gtot4-salahq = wa_gtot4-salah%.
    wa_gtot4-otherq = wa_gtot4-other%.
    wa_gtot4-stkoutq = wa_gtot4-stkout%.
    wa_gtot4-rejectq = wa_gtot4-reject%.

    PERFORM f_move_gtot USING p_val '4'.

  ENDIF.
  wa_gtot4-deci = '2'.
  CLEAR: wa_gtot4-curr, wa_gtot4-kwmeng,
         wa_gtot4-kzwi1, wa_gtot4-dlqty.
  APPEND wa_gtot4 TO i_output4.
  CLEAR: wa_gtot4.

  IF p_total4 = 'X'.
    DELETE i_output4 WHERE index LT '40'.
  ENDIF.

ENDFORM.                    " proses_data4

*&---------------------------------------------------------------------*
*&      Form  append_itab4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_itab4.

  DATA : l_crdat  LIKE  zmm_cust_rec-crdat,
         l_leadt  TYPE  i.

  MOVE-CORRESPONDING i_detquot4 TO i_output4.

  IF NOT i_detdelv-vbeln IS INITIAL.
    i_output4-dlqty = i_detsales-kwmeng.
    i_output4-dlval = i_detsales-kzwi1.
    i_output4-unqty = i_output4-kwmeng - i_output4-dlqty.
    i_output4-unval = i_output4-kzwi1 - i_output4-dlval.

    IF i_output4-unqty LT 0.
      CLEAR: i_output4-unqty,i_output4-unval.
    ENDIF.

    SELECT SINGLE crdat FROM zmm_cust_rec
      INTO l_crdat
      WHERE vbeln = i_detdelv-vbeln.

    IF l_crdat IS INITIAL.
      i_output4-lead6q = i_output4-dlqty.
      i_output4-lead6 = i_output4-dlval.
    ELSE.
      l_leadt = l_crdat - i_detquot4-bstdk.
      IF l_leadt LE 3.
        i_output4-lead1q = i_output4-dlqty.
        i_output4-lead1 = i_output4-dlval.
      ELSEIF l_leadt = 4.
        i_output4-lead2q = i_output4-dlqty.
        i_output4-lead2 = i_output4-dlval.
      ELSEIF l_leadt GE 5.
        i_output4-lead3q = i_output4-dlqty.
        i_output4-lead3 = i_output4-dlval.
*      ELSEIF l_leadt GE 6.
*        i_output4-lead4 = i_output4-dlval.
*      ELSEIF l_leadt GE 7.
*        i_output4-lead5 = i_output4-dlval.
      ENDIF.
    ENDIF.
  ELSE.
    IF i_detsales-vbeln IS INITIAL.
      i_output4-unqty = i_output4-kwmeng.
      i_output4-unval = i_output4-kzwi1.
    ELSE.
      IF NOT i_detquot4-abgru IS INITIAL.
        i_output4-unqty = i_output4-kwmeng.
        i_output4-unval = i_output4-kzwi1.
      ELSE.
        i_output4-pooutq = i_output4-kwmeng.
        i_output4-poout = i_output4-kzwi1.
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM f_reason_for_rejection USING i_detquot4-abgru
                                       i_output4-unqty
                                       i_output4-unval
                                       '4'.

  SELECT SINGLE bezei FROM tvkbt
    INTO i_output4-vkburt
    WHERE spras = sy-langu AND
          vkbur = i_output4-vkbur.

  i_output4-reject = i_output4-unval - i_output4-stkout.

  PERFORM hitung_total4.

  i_output4-curr = 'IDR'.
  i_output4-index = '10'.
  i_output4-deci = '0'.
  i_output4-matkx = i_output4-matkl.
  i_output4-prinx = i_output4-princ.

  COLLECT i_output4.

ENDFORM.                    " append_itab4

*&---------------------------------------------------------------------*
*&      Form  hitung_total4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hitung_total4.

  ADD i_output4-kwmeng TO wa_stot41-kwmeng.
  ADD i_output4-kwmeng TO wa_stot42-kwmeng.
  ADD i_output4-kwmeng TO wa_stot43-kwmeng.
  ADD i_output4-kwmeng TO wa_stot44-kwmeng.
  ADD i_output4-kwmeng TO wa_gtot4-kwmeng.
  ADD i_output4-kzwi1 TO wa_stot41-kzwi1.
  ADD i_output4-kzwi1 TO wa_stot42-kzwi1.
  ADD i_output4-kzwi1 TO wa_stot43-kzwi1.
  ADD i_output4-kzwi1 TO wa_stot44-kzwi1.
  ADD i_output4-kzwi1 TO wa_gtot4-kzwi1.
  ADD i_output4-dlqty TO wa_stot41-dlqty.
  ADD i_output4-dlqty TO wa_stot42-dlqty.
  ADD i_output4-dlqty TO wa_stot43-dlqty.
  ADD i_output4-dlqty TO wa_stot44-dlqty.
  ADD i_output4-dlqty TO wa_gtot4-dlqty.
  ADD i_output4-dlval TO wa_stot41-dlval.
  ADD i_output4-dlval TO wa_stot42-dlval.
  ADD i_output4-dlval TO wa_stot43-dlval.
  ADD i_output4-dlval TO wa_stot44-dlval.
  ADD i_output4-dlval TO wa_gtot4-dlval.
  ADD i_output4-unqty TO wa_stot41-unqty.
  ADD i_output4-unqty TO wa_stot42-unqty.
  ADD i_output4-unqty TO wa_stot43-unqty.
  ADD i_output4-unqty TO wa_stot44-unqty.
  ADD i_output4-unqty TO wa_gtot4-unqty.
  ADD i_output4-unval TO wa_stot41-unval.
  ADD i_output4-unval TO wa_stot42-unval.
  ADD i_output4-unval TO wa_stot43-unval.
  ADD i_output4-unval TO wa_stot44-unval.
  ADD i_output4-unval TO wa_gtot4-unval.
  ADD i_output4-lead1q TO wa_stot41-lead1q.
  ADD i_output4-lead1q TO wa_stot42-lead1q.
  ADD i_output4-lead1q TO wa_stot43-lead1q.
  ADD i_output4-lead1q TO wa_stot44-lead1q.
  ADD i_output4-lead1q TO wa_gtot4-lead1q.
  ADD i_output4-lead1 TO wa_stot41-lead1.
  ADD i_output4-lead1 TO wa_stot42-lead1.
  ADD i_output4-lead1 TO wa_stot43-lead1.
  ADD i_output4-lead1 TO wa_stot44-lead1.
  ADD i_output4-lead1 TO wa_gtot4-lead1.
  ADD i_output4-lead2 TO wa_stot41-lead2q.
  ADD i_output4-lead2 TO wa_stot42-lead2q.
  ADD i_output4-lead2 TO wa_stot43-lead2q.
  ADD i_output4-lead2 TO wa_stot44-lead2q.
  ADD i_output4-lead2 TO wa_gtot4-lead2q.
  ADD i_output4-lead2 TO wa_stot41-lead2.
  ADD i_output4-lead2 TO wa_stot42-lead2.
  ADD i_output4-lead2 TO wa_stot43-lead2.
  ADD i_output4-lead2 TO wa_stot44-lead2.
  ADD i_output4-lead2 TO wa_gtot4-lead2.
  ADD i_output4-lead3q TO wa_stot41-lead3q.
  ADD i_output4-lead3q TO wa_stot42-lead3q.
  ADD i_output4-lead3q TO wa_stot43-lead3q.
  ADD i_output4-lead3q TO wa_stot44-lead3q.
  ADD i_output4-lead3q TO wa_gtot4-lead3q.
  ADD i_output4-lead3 TO wa_stot41-lead3.
  ADD i_output4-lead3 TO wa_stot42-lead3.
  ADD i_output4-lead3 TO wa_stot43-lead3.
  ADD i_output4-lead3 TO wa_stot44-lead3.
  ADD i_output4-lead3 TO wa_gtot4-lead3.
  ADD i_output4-lead4q TO wa_stot41-lead4q.
  ADD i_output4-lead4q TO wa_stot42-lead4q.
  ADD i_output4-lead4q TO wa_stot43-lead4q.
  ADD i_output4-lead4q TO wa_stot44-lead4q.
  ADD i_output4-lead4q TO wa_gtot4-lead4q.
  ADD i_output4-lead4 TO wa_stot41-lead4.
  ADD i_output4-lead4 TO wa_stot42-lead4.
  ADD i_output4-lead4 TO wa_stot43-lead4.
  ADD i_output4-lead4 TO wa_stot44-lead4.
  ADD i_output4-lead4 TO wa_gtot4-lead4.
  ADD i_output4-lead5q TO wa_stot41-lead5q.
  ADD i_output4-lead5q TO wa_stot42-lead5q.
  ADD i_output4-lead5q TO wa_stot43-lead5q.
  ADD i_output4-lead5q TO wa_stot44-lead5q.
  ADD i_output4-lead5q TO wa_gtot4-lead5q.
  ADD i_output4-lead5 TO wa_stot41-lead5.
  ADD i_output4-lead5 TO wa_stot42-lead5.
  ADD i_output4-lead5 TO wa_stot43-lead5.
  ADD i_output4-lead5 TO wa_stot44-lead5.
  ADD i_output4-lead5 TO wa_gtot4-lead5.
  ADD i_output4-lead6q TO wa_stot41-lead6q.
  ADD i_output4-lead6q TO wa_stot42-lead6q.
  ADD i_output4-lead6q TO wa_stot43-lead6q.
  ADD i_output4-lead6q TO wa_stot44-lead6q.
  ADD i_output4-lead6q TO wa_gtot4-lead6q.
  ADD i_output4-lead6 TO wa_stot41-lead6.
  ADD i_output4-lead6 TO wa_stot42-lead6.
  ADD i_output4-lead6 TO wa_stot43-lead6.
  ADD i_output4-lead6 TO wa_stot44-lead6.
  ADD i_output4-lead6 TO wa_gtot4-lead6.
  ADD i_output4-stkoutq TO wa_stot41-stkoutq.
  ADD i_output4-stkoutq TO wa_stot42-stkoutq.
  ADD i_output4-stkoutq TO wa_stot43-stkoutq.
  ADD i_output4-stkoutq TO wa_stot44-stkoutq.
  ADD i_output4-stkoutq TO wa_gtot4-stkoutq.
  ADD i_output4-stkout TO wa_stot41-stkout.
  ADD i_output4-stkout TO wa_stot42-stkout.
  ADD i_output4-stkout TO wa_stot43-stkout.
  ADD i_output4-stkout TO wa_stot44-stkout.
  ADD i_output4-stkout TO wa_gtot4-stkout.
  ADD i_output4-cltopq TO wa_stot41-cltopq.
  ADD i_output4-cltopq TO wa_stot42-cltopq.
  ADD i_output4-cltopq TO wa_stot43-cltopq.
  ADD i_output4-cltopq TO wa_stot44-cltopq.
  ADD i_output4-cltopq TO wa_gtot4-cltopq.
  ADD i_output4-cltop TO wa_stot41-cltop.
  ADD i_output4-cltop TO wa_stot42-cltop.
  ADD i_output4-cltop TO wa_stot43-cltop.
  ADD i_output4-cltop TO wa_stot44-cltop.
  ADD i_output4-cltop TO wa_gtot4-cltop.
  ADD i_output4-salahq TO wa_stot41-salahq.
  ADD i_output4-salahq TO wa_stot42-salahq.
  ADD i_output4-salahq TO wa_stot43-salahq.
  ADD i_output4-salahq TO wa_stot44-salahq.
  ADD i_output4-salahq TO wa_gtot4-salahq.
  ADD i_output4-salah TO wa_stot41-salah.
  ADD i_output4-salah TO wa_stot42-salah.
  ADD i_output4-salah TO wa_stot43-salah.
  ADD i_output4-salah TO wa_stot44-salah.
  ADD i_output4-salah TO wa_gtot4-salah.
  ADD i_output4-otherq TO wa_stot41-otherq.
  ADD i_output4-otherq TO wa_stot42-otherq.
  ADD i_output4-otherq TO wa_stot43-otherq.
  ADD i_output4-otherq TO wa_stot44-otherq.
  ADD i_output4-otherq TO wa_gtot4-otherq.
  ADD i_output4-other TO wa_stot41-other.
  ADD i_output4-other TO wa_stot42-other.
  ADD i_output4-other TO wa_stot43-other.
  ADD i_output4-other TO wa_stot44-other.
  ADD i_output4-other TO wa_gtot4-other.
  ADD i_output4-rejectq TO wa_stot41-rejectq.
  ADD i_output4-rejectq TO wa_stot42-rejectq.
  ADD i_output4-rejectq TO wa_stot43-rejectq.
  ADD i_output4-rejectq TO wa_stot44-rejectq.
  ADD i_output4-rejectq TO wa_gtot4-rejectq.
  ADD i_output4-reject TO wa_stot41-reject.
  ADD i_output4-reject TO wa_stot42-reject.
  ADD i_output4-reject TO wa_stot43-reject.
  ADD i_output4-reject TO wa_stot44-reject.
  ADD i_output4-reject TO wa_gtot4-reject.
  ADD i_output4-pooutq TO wa_stot41-pooutq.
  ADD i_output4-pooutq TO wa_stot42-pooutq.
  ADD i_output4-pooutq TO wa_stot43-pooutq.
  ADD i_output4-pooutq TO wa_stot44-pooutq.
  ADD i_output4-pooutq TO wa_gtot4-pooutq.
  ADD i_output4-poout TO wa_stot41-poout.
  ADD i_output4-poout TO wa_stot42-poout.
  ADD i_output4-poout TO wa_stot43-poout.
  ADD i_output4-poout TO wa_stot44-poout.
  ADD i_output4-poout TO wa_gtot4-poout.
  ADD i_output4-btqty TO wa_stot41-btqty.
  ADD i_output4-btqty TO wa_stot42-btqty.
  ADD i_output4-btqty TO wa_stot43-btqty.
  ADD i_output4-btqty TO wa_stot44-btqty.
  ADD i_output4-btqty TO wa_gtot4-btqty.
  ADD i_output4-btamt TO wa_stot41-btamt.
  ADD i_output4-btamt TO wa_stot42-btamt.
  ADD i_output4-btamt TO wa_stot43-btamt.
  ADD i_output4-btamt TO wa_stot44-btamt.
  ADD i_output4-btamt TO wa_gtot4-btamt.

  PERFORM f_hitung_total USING '4'.

ENDFORM.                    " hitung_total4

*&---------------------------------------------------------------------*
*&      Form  f_build_fieldcat4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_fieldcat4.
  DEFINE mac_header4.
    read table t_abgru index &1.
    if sy-subrc eq 0.
      if p_val = 'X'.
        fieldcat-fieldname = 'VAL&1'.
        fieldcat-ref_fieldname = ''.
        fieldcat-tabname = 'I_OUTPUT4'.
        fieldcat-outputlen = 15.
        fieldcat-cfieldname = 'CURR'.
        fieldcat-seltext_s = t_abgru-bezei.
        fieldcat-seltext_m = t_abgru-bezei.
        fieldcat-seltext_l = t_abgru-bezei.
        append fieldcat. "clear fieldcat.
      else.
        fieldcat-fieldname = 'QTY&1'.
        fieldcat-ref_fieldname = ''.
        fieldcat-tabname = 'I_OUTPUT4'.
        fieldcat-outputlen = 15.
        fieldcat-decimalsfieldname = 'DECI'.
        fieldcat-seltext_s = t_abgru-bezei.
        fieldcat-seltext_m = t_abgru-bezei.
        fieldcat-seltext_l = t_abgru-bezei.
        append fieldcat. "clear fieldcat.
      endif.
    endif.
  END-OF-DEFINITION.

  fieldcat-fieldname = 'PRINC'.
  fieldcat-ref_fieldname = 'PRINC'.
  fieldcat-tabname = 'I_OUTPUT4'.
  fieldcat-outputlen = 6.
  fieldcat-seltext_s = 'Princp'.
  fieldcat-seltext_m = 'Principal'.
  fieldcat-seltext_l = 'Principal'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'MATKL'.
  fieldcat-ref_fieldname = 'MATKL'.
  fieldcat-tabname = 'I_OUTPUT4'.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'Mat Group'.
  fieldcat-seltext_m = 'Material Group'.
  fieldcat-seltext_l = 'Material Group'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'MATNR'.
  fieldcat-ref_fieldname = 'MATNR'.
  fieldcat-tabname = 'I_OUTPUT4'.
  fieldcat-outputlen = 11.
  fieldcat-seltext_s = 'Material'.
  fieldcat-seltext_m = 'Material'.
  fieldcat-seltext_l = 'Material'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'MAKTX'.
  fieldcat-ref_fieldname = 'MAKTX'.
  fieldcat-tabname = 'I_OUTPUT4'.
  fieldcat-outputlen = 30.
  fieldcat-seltext_s = 'Material Desc'.
  fieldcat-seltext_m = 'Material Desc'.
  fieldcat-seltext_l = 'Material Descriptions'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'KWMENG'.
  fieldcat-ref_fieldname = 'KWMENG'.
  fieldcat-tabname = 'I_OUTPUT4'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'PO Qty'.
  fieldcat-seltext_m = 'PO Quantity'.
  fieldcat-seltext_l = 'PO Quantity'.
  fieldcat-decimals_out = '0'.
  fieldcat-no_zero = 'X'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'KZWI1'.
  fieldcat-ref_fieldname = 'KZWI1'.
  fieldcat-tabname = 'I_OUTPUT4'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'PO Amount'.
  fieldcat-seltext_m = 'PO Amount'.
  fieldcat-seltext_l = 'PO Amount'.
  fieldcat-currency = 'IDR'.
  fieldcat-decimals_out = '0'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out.

*  IF p_val = 'X'.
*    fieldcat-fieldname = 'BTAMT'.
*    fieldcat-ref_fieldname = 'BTAMT'.
*    fieldcat-tabname = 'I_OUTPUT4'.
*    fieldcat-outputlen = 13.
*    fieldcat-seltext_s = 'PO Batal'.
*    fieldcat-seltext_m = 'PO Batal'.
*    fieldcat-seltext_l = 'PO Batal'.
*    fieldcat-cfieldname = 'CURR'.
*    APPEND fieldcat. "clear fieldcat.
*  ELSE.
*    fieldcat-fieldname = 'BTQTY'.
*    fieldcat-ref_fieldname = 'BTQTY'.
*    fieldcat-tabname = 'I_OUTPUT4'.
*    fieldcat-outputlen = 13.
*    fieldcat-seltext_s = 'PO Batal'.
*    fieldcat-seltext_m = 'PO Batal'.
*    fieldcat-seltext_l = 'PO Batal'.
*    fieldcat-decimalsfieldname = 'DECI'.
*    APPEND fieldcat. "clear fieldcat.
*  ENDIF.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname,
         fieldcat-decimalsfieldname.

  fieldcat-fieldname = 'DLQTY'.
  fieldcat-ref_fieldname = 'DLQTY'.
  fieldcat-tabname = 'I_OUTPUT4'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'DO Qty'.
  fieldcat-seltext_m = 'DO Quantity'.
  fieldcat-seltext_l = 'DO Quantity'.
  fieldcat-decimals_out = '0'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname.

  fieldcat-fieldname = 'DLVAL'.
  fieldcat-ref_fieldname = 'DLVAL'.
  fieldcat-tabname = 'I_OUTPUT4'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'DO Amount'.
  fieldcat-seltext_m = 'DO Aomunt'.
  fieldcat-seltext_l = 'DO Amount'.
  fieldcat-cfieldname = 'CURR'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname.

  IF p_val = 'X'.
    fieldcat-fieldname = 'LEAD6'.
    fieldcat-ref_fieldname = 'LEAD6'.
    fieldcat-tabname = 'I_OUTPUT4'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Intransit'.
    fieldcat-seltext_m = 'Intransit'.
    fieldcat-seltext_l = 'Intransit'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD1'.
    fieldcat-ref_fieldname = 'LEAD1'.
    fieldcat-tabname = 'I_OUTPUT4'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead <= 3'.
    fieldcat-seltext_m = 'Lead <= 3'.
    fieldcat-seltext_l = 'Lead <= 3'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD2'.
    fieldcat-ref_fieldname = 'LEAD2'.
    fieldcat-tabname = 'I_OUTPUT4'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead = 4'.
    fieldcat-seltext_m = 'Lead = 4'.
    fieldcat-seltext_l = 'Lead = 4'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD3'.
    fieldcat-ref_fieldname = 'LEAD3'.
    fieldcat-tabname = 'I_OUTPUT4'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead >= 5'.
    fieldcat-seltext_m = 'Lead >= 5'.
    fieldcat-seltext_l = 'Lead >= 5'.
    APPEND fieldcat. "clear fieldcat.
  ELSE.
    fieldcat-fieldname = 'LEAD6Q'.
    fieldcat-ref_fieldname = 'LEAD6Q'.
    fieldcat-tabname = 'I_OUTPUT4'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Intransit'.
    fieldcat-seltext_m = 'Intransit'.
    fieldcat-seltext_l = 'Intransit'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD1Q'.
    fieldcat-ref_fieldname = 'LEAD1Q'.
    fieldcat-tabname = 'I_OUTPUT4'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead <= 3'.
    fieldcat-seltext_m = 'Lead <= 3'.
    fieldcat-seltext_l = 'Lead <= 3'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD2Q'.
    fieldcat-ref_fieldname = 'LEAD2Q'.
    fieldcat-tabname = 'I_OUTPUT4'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead = 4'.
    fieldcat-seltext_m = 'Lead = 4'.
    fieldcat-seltext_l = 'Lead = 4'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD3Q'.
    fieldcat-ref_fieldname = 'LEAD3Q'.
    fieldcat-tabname = 'I_OUTPUT4'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead >= 5'.
    fieldcat-seltext_m = 'Lead >= 5'.
    fieldcat-seltext_l = 'Lead >= 5'.
    APPEND fieldcat. "clear fieldcat.
  ENDIF.

*  fieldcat-fieldname = 'LEAD4'.
*  fieldcat-ref_fieldname = 'LEAD4'.
*  fieldcat-tabname = 'I_OUTPUT4'.
*  fieldcat-outputlen = 13.
*  fieldcat-cfieldname = 'CURR'.
*  fieldcat-seltext_s = 'Lead >= 6'.
*  fieldcat-seltext_m = 'Lead >= 6'.
*  fieldcat-seltext_l = 'Lead >= 6'.
*  APPEND fieldcat. "clear fieldcat.

*  fieldcat-fieldname = 'LEAD5'.
*  fieldcat-ref_fieldname = 'LEAD5'.
*  fieldcat-tabname = 'I_OUTPUT4'.
*  fieldcat-outputlen = 13.
*  fieldcat-cfieldname = 'CURR'.
*  fieldcat-seltext_s = 'Lead >= 7'.
*  fieldcat-seltext_m = 'Lead >= 7'.
*  fieldcat-seltext_l = 'Lead >= 7'.
*  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname,
         fieldcat-decimalsfieldname.

  IF p_val = 'X'.
    fieldcat-fieldname = 'UNVAL'.
    fieldcat-ref_fieldname = 'UNVAL'.
    fieldcat-tabname = 'I_OUTPUT4'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Undlv Amount'.
    fieldcat-seltext_m = 'Undelivered Amount'.
    fieldcat-seltext_l = 'Undelivered Amount'.
    APPEND fieldcat. "clear fieldcat.

*    fieldcat-fieldname = 'CLTOP'.
*    fieldcat-ref_fieldname = 'CLTOP'.
*    fieldcat-tabname = 'I_OUTPUT4'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'CL / TOP'.
*    fieldcat-seltext_m = 'CL / TOP'.
*    fieldcat-seltext_l = 'CL / TOP'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'STKOUT'.
*    fieldcat-ref_fieldname = 'STKOUT'.
*    fieldcat-tabname = 'I_OUTPUT4'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Stock Out'.
*    fieldcat-seltext_m = 'Stock Out'.
*    fieldcat-seltext_l = 'Stock Out'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'SALAH'.
*    fieldcat-ref_fieldname = 'SALAH'.
*    fieldcat-tabname = 'I_OUTPUT4'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Salah Harga'.
*    fieldcat-seltext_m = 'Salah Harga'.
*    fieldcat-seltext_l = 'Salah Harga'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'OTHER'.
*    fieldcat-ref_fieldname = 'OTHER'.
*    fieldcat-tabname = 'I_OUTPUT4'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Other'.
*    fieldcat-seltext_m = 'Other'.
*    fieldcat-seltext_l = 'Other'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'POOUT'.
*    fieldcat-ref_fieldname = 'POOUT'.
*    fieldcat-tabname = 'I_OUTPUT4'.
*    fieldcat-outputlen = 13.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'PO Outs'.
*    fieldcat-seltext_m = 'PO Outstanding'.
*    fieldcat-seltext_l = 'PO Outstanding'.
*    APPEND fieldcat. "clear fieldcat.
  ELSE.
    fieldcat-fieldname = 'UNQTY'.
    fieldcat-ref_fieldname = 'UNQTY'.
    fieldcat-tabname = 'I_OUTPUT4'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Undlv Qty'.
    fieldcat-seltext_m = 'Undelivered Quantity'.
    fieldcat-seltext_l = 'Undelivered Quantity'.
    APPEND fieldcat. "clear fieldcat.

*    fieldcat-fieldname = 'CLTOPQ'.
*    fieldcat-ref_fieldname = 'CLTOPQ'.
*    fieldcat-tabname = 'I_OUTPUT4'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'CL / TOP'.
*    fieldcat-seltext_m = 'CL / TOP'.
*    fieldcat-seltext_l = 'CL / TOP'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'STKOUTQ'.
*    fieldcat-ref_fieldname = 'STKOUTQ'.
*    fieldcat-tabname = 'I_OUTPUT4'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Stock Out'.
*    fieldcat-seltext_m = 'Stock Out'.
*    fieldcat-seltext_l = 'Stock Out'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'SALAHQ'.
*    fieldcat-ref_fieldname = 'SALAHQ'.
*    fieldcat-tabname = 'I_OUTPUT4'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Salah Harga'.
*    fieldcat-seltext_m = 'Salah Harga'.
*    fieldcat-seltext_l = 'Salah Harga'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'OTHERQ'.
*    fieldcat-ref_fieldname = 'OTHERQ'.
*    fieldcat-tabname = 'I_OUTPUT4'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Other'.
*    fieldcat-seltext_m = 'Other'.
*    fieldcat-seltext_l = 'Other'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'POOUTQ'.
*    fieldcat-ref_fieldname = 'POOUTQ'.
*    fieldcat-tabname = 'I_OUTPUT4'.
*    fieldcat-outputlen = 13.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'PO Outs'.
*    fieldcat-seltext_m = 'PO Outstanding'.
*    fieldcat-seltext_l = 'PO Outstanding'.
*    APPEND fieldcat. "clear fieldcat.
  ENDIF.

  mac_header4 : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.

ENDFORM.                    " f_build_fieldcat4

*&---------------------------------------------------------------------*
*&      Form  f_build_sortfield4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_SORT
*----------------------------------------------------------------------*
FORM f_build_sortfield4 USING fu_sort TYPE slis_t_sortinfo_alv.

  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'VKBUR'.
  ld_sort-up        = 'X'.
  ld_sort-group     = '*'.
  ld_sort-spos      = '01'.
  APPEND ld_sort TO fu_sort.

  IF p_total4 IS INITIAL.
    CLEAR ld_sort.
    ld_sort-fieldname = 'KNKLI'.
    ld_sort-up        = 'X'.
    ld_sort-group     = '*'.
    ld_sort-spos      = '02'.
    APPEND ld_sort TO fu_sort.
  ELSE.
    CLEAR ld_sort.
    ld_sort-fieldname = 'KNKLI'.
    ld_sort-up        = 'X'.
*  ld_sort-group     = '*'.
    ld_sort-spos      = '02'.
    APPEND ld_sort TO fu_sort.
  ENDIF.

  CLEAR ld_sort.
  ld_sort-fieldname = 'PRINX'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
  ld_sort-spos      = '03'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'MATKX'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
  ld_sort-spos      = '04'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'INDEX'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-spos      = '05'.
  APPEND ld_sort TO fu_sort.

ENDFORM.                    " f_build_sortfield4

*&---------------------------------------------------------------------*
*&      Form  f_build_event4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_EVENTS
*----------------------------------------------------------------------*
FORM f_build_event4 TABLES ft_events LIKE t_events.

  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE4'.
  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_end_of_list.
*  ft_events-form = 'F_END_OF_LIST4'.
*  APPEND ft_events.

ENDFORM.                    " f_build_event4

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE4                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page4.

  DATA : l_line1(70),
         l_line2(60),
         l_sloff(80),
         l_cust(80),
         l_fdate(10),
         l_tdate(10).

  WRITE s_erdat-low TO l_fdate.
  WRITE s_erdat-high TO l_tdate.
*--- Title
  CONCATENATE sy-title 'By Branch, Customer, Material Grp' '(04)'
              INTO l_line1 SEPARATED BY space.
*--- Period
  CONCATENATE 'Period :' l_fdate 'to' l_tdate
              INTO l_line2 SEPARATED BY space.
*--- Sales Office
  CONCATENATE 'Sales Office :' i_output4-vkbur i_output4-vkburt
              INTO l_sloff SEPARATED BY space.
*--- Customer
  IF p_total4 IS INITIAL.
    CONCATENATE 'Customer     :' i_output4-knkli i_output4-name1
                INTO l_cust SEPARATED BY space.
  ELSE.
    l_cust = 'SUMMARY'.
  ENDIF.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING l_line1.
  PERFORM f_hdr_line2 USING l_sloff l_line2.
  PERFORM f_hdr_line3 USING l_cust va_text.
  PERFORM f_hdr_uline.

ENDFORM.                    "f_top_of_page4

*&---------------------------------------------------------------------*
*&      Form  write_data1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_data1.

  DATA: l_field(20),
        l_sw(1),
        l_sw1(1),
        l_sw2(1),
        l_sw3(1),
        l_color TYPE i,
        ld_kolom TYPE i.

  DEFINE mac_reason.
    ld_kolom = &1 * 16 + 221.
    if p_val = 'X'.
      write at ld_kolom(15) i_output1-val&1 no-zero  "no-sign
                            currency i_output1-curr no-gap.
      ld_kolom = ld_kolom + 15.
      write at ld_kolom(1) sy-vline no-gap.
    else.
      write at ld_kolom(15) i_output1-qty&1 no-zero  "no-sign
                            decimals i_output1-deci no-gap.
      ld_kolom = ld_kolom + 15.
      write at ld_kolom(1) sy-vline no-gap.
    endif.
  END-OF-DEFINITION.

  SORT i_reason1 BY abgru.
  LOOP AT i_output1.

    IF l_sw1 = 'X'                AND
       i_output1-sort1 IS INITIAL AND
       i_output1-sort2 IS INITIAL AND
       i_output1-sort3 IS INITIAL.
      CLEAR l_sw1.
*      ULINE.
*      PERFORM f_cetak_reason.
      NEW-PAGE.
    ENDIF.

    IF i_output1-info IS INITIAL.
      IF l_sw IS INITIAL.
        FORMAT COLOR 2 INTENSIFIED OFF.
        l_sw = '1'.
      ELSE.
        FORMAT COLOR 2 INTENSIFIED ON.
        CLEAR l_sw.
      ENDIF.
    ELSE.
      CASE i_output1-info+1(2).
        WHEN '30'.
          FORMAT COLOR 3 INTENSIFIED OFF.
        WHEN '31'.
          FORMAT COLOR 3 INTENSIFIED ON.
*        WHEN '61'.
*          FORMAT COLOR 6 INTENSIFIED ON.
        WHEN '70'.
          FORMAT COLOR 7 INTENSIFIED OFF.
        WHEN '71'.
          FORMAT COLOR 7 INTENSIFIED ON.
      ENDCASE.
    ENDIF.
    IF i_output1-maktx CS '*    Total PO'.
      ULINE.
    ENDIF.

    WRITE:/     sy-vline NO-GAP,
           (20) i_output1-bstnk NO-GAP,
                sy-vline NO-GAP,
            (8) i_output1-bstdk NO-ZERO NO-GAP DD/MM/YY,
                sy-vline NO-GAP,
*           (10) i_output1-kdmat NO-GAP,
*                sy-vline NO-GAP,
            (9) i_output1-matnr NO-GAP,
                sy-vline NO-GAP,
           (20) i_output1-maktx NO-GAP,
                sy-vline NO-GAP,
            (8) i_output1-kwmeng NO-ZERO  NO-SIGN
                                 DECIMALS 0 NO-GAP,
                sy-vline NO-GAP,
           (11) i_output1-kzwi1 NO-ZERO  NO-SIGN
                                CURRENCY i_output1-curr NO-GAP,
                sy-vline NO-GAP.

    WRITE: 84(10) i_output1-dlnum NO-GAP,
               sy-vline NO-GAP,
           (8) i_output1-dldat NO-ZERO NO-GAP DD/MM/YY,
               sy-vline NO-GAP,
           (8) i_output1-crdat NO-ZERO NO-GAP DD/MM/YY,
               sy-vline NO-GAP,
           (9) i_output1-dlmat NO-GAP,
               sy-vline NO-GAP,
          (25) i_output1-dlmatx NO-GAP,
               sy-vline NO-GAP,
           (8) i_output1-dlqty NO-ZERO  NO-SIGN
                               DECIMALS 0 NO-GAP,
               sy-vline NO-GAP,
          (11) i_output1-dlval NO-ZERO  NO-SIGN
                               CURRENCY i_output1-curr NO-GAP,
               sy-vline NO-GAP,
           (6) i_output1-percen NO-ZERO  NO-SIGN
                                DECIMALS 2 NO-GAP,
               sy-vline NO-GAP.

    IF p_val = 'X'.
*      WRITE:  141(11) i_output1-lead6 NO-ZERO  NO-SIGN
      WRITE:  177(11) i_output1-lead6 NO-ZERO  NO-SIGN
                                  CURRENCY i_output1-curr NO-GAP,
                      sy-vline NO-GAP,
                 (11) i_output1-lead1 NO-ZERO  NO-SIGN
                                      CURRENCY i_output1-curr NO-GAP,
                      sy-vline NO-GAP,
                 (11) i_output1-lead2 NO-ZERO  NO-SIGN
                                      CURRENCY i_output1-curr NO-GAP,
                      sy-vline NO-GAP,
                 (11) i_output1-lead3 NO-ZERO  NO-SIGN
                                      CURRENCY i_output1-curr NO-GAP,
                      sy-vline NO-GAP,
                 (11) i_output1-unval NO-ZERO  "NO-SIGN
                                      CURRENCY i_output1-curr NO-GAP,
                      sy-vline NO-GAP.
    ELSE.
*      WRITE:  141(11) i_output1-lead6q NO-ZERO  NO-SIGN
      WRITE:  177(11) i_output1-lead6q NO-ZERO  NO-SIGN
                                       DECIMALS i_output1-deci NO-GAP,
                      sy-vline NO-GAP,
                 (11) i_output1-lead1q NO-ZERO  NO-SIGN
                                       DECIMALS i_output1-deci NO-GAP,
                      sy-vline NO-GAP,
                 (11) i_output1-lead2q NO-ZERO  NO-SIGN
                                       DECIMALS i_output1-deci NO-GAP,
                      sy-vline NO-GAP,
                 (11) i_output1-lead3q NO-ZERO  NO-SIGN
                                       DECIMALS i_output1-deci NO-GAP,
                      sy-vline NO-GAP,
                 (11) i_output1-unqty NO-ZERO  "NO-SIGN
                                      DECIMALS i_output1-deci NO-GAP,
                      sy-vline NO-GAP.
    ENDIF.

    mac_reason : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.

    WRITE: (10) i_output1-fixpo NO-GAP,
                sy-vline NO-GAP.

    IF i_output1-maktx CS 'Percentage'.
      ULINE.
    ENDIF.
    IF i_output1-sort1 = 'X' OR
       i_output1-sort2 = 'X' OR
       i_output1-sort3 = 'X'.
      l_sw1 = 'X'.
    ENDIF.
    IF i_output1-curr = 'IDR' AND
        i_output1-sort1 = 'X' AND
        i_output1-sort2 = ''  AND
        i_output1-sort3 = ''.
      v_kzwi1 = i_output1-kzwi1.
      v_btamt = i_output1-btamt.
    ENDIF.

  ENDLOOP.
  IF l_sw1 = 'X'.
    CLEAR l_sw1.
*    ULINE.
*    PERFORM f_cetak_reason.
  ELSE.
    ULINE.
  ENDIF.

ENDFORM.                    " write_data1

*&---------------------------------------------------------------------*
*&      Form  f_sub_header1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sub_header1.
  DATA: l_length TYPE i.
  ULINE.
  NEW-LINE.
  LOOP AT fieldcat.
    l_length = fieldcat-outputlen.
    CASE l_length.
      WHEN 2.
        WRITE: sy-vline NO-GAP,
               (2) fieldcat-seltext_s NO-GAP.
      WHEN 6.
        WRITE: sy-vline NO-GAP,
               (6) fieldcat-seltext_s NO-GAP.
      WHEN 8.
        WRITE: sy-vline NO-GAP,
               (8) fieldcat-seltext_s RIGHT-JUSTIFIED
               NO-GAP.
      WHEN 9.
        WRITE: sy-vline NO-GAP,
               (9) fieldcat-seltext_s NO-GAP.
      WHEN 10.
        WRITE: sy-vline NO-GAP,
               (10) fieldcat-seltext_s NO-GAP.
      WHEN 11.
        WRITE: sy-vline NO-GAP,
               (11) fieldcat-seltext_s RIGHT-JUSTIFIED
               NO-GAP.
      WHEN 15.
        WRITE: sy-vline NO-GAP,
               (15) fieldcat-seltext_m NO-GAP.
      WHEN 20.
        WRITE: sy-vline NO-GAP,
               (20) fieldcat-seltext_m NO-GAP.
      WHEN 25.
        WRITE: sy-vline NO-GAP,
               (25) fieldcat-seltext_l NO-GAP.
    ENDCASE.
  ENDLOOP.
  WRITE: sy-vline NO-GAP.
  ULINE.
ENDFORM.                    " f_sub_header1

*&---------------------------------------------------------------------*
*&      Form  f_cetak_reason
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cetak_reason.

  READ TABLE i_reason1 WITH KEY vkbur = v_vkbur
                                knkli = v_knkli.
  CHECK sy-subrc = 0.
  FORMAT COLOR 7.
  SKIP.
  WRITE: /(42) 'Reason' CENTERED,
          (15) 'Quantity' RIGHT-JUSTIFIED,
          (17) 'Amount' RIGHT-JUSTIFIED,
          (10) 'Percen' CENTERED.
  WRITE: /(96) sy-uline.
  FORMAT COLOR OFF.

  LOOP AT i_reason1 WHERE vkbur = v_vkbur AND
                          knkli = v_knkli.
    i_reason1-percen = i_reason1-unval / ( v_kzwi1 - v_btamt ) * 100.
    WRITE: /     i_reason1-abgru,
                 i_reason1-bezei,
            (15) i_reason1-unqty DECIMALS 2,
            (17) i_reason1-unval CURRENCY 'IDR',
             (8) i_reason1-percen NO-GAP, '%'.
  ENDLOOP.

ENDFORM.                    " f_cetak_reason

*&---------------------------------------------------------------------*
*&      Form  proses_data6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proses_data6.

  SORT i_detquot6  BY princ kvgr4 vkbur knkli.
*  SORT i_detsales BY vgbel posnr.
  SORT i_detsales BY vgbel vgpos.
  SORT i_detdelv  BY vgbel vgpos.
  LOOP AT i_detquot6.

    CLEAR : i_detsales, i_detdelv, i_output6. ", i_detquot6-abgru.

    READ TABLE i_detsales WITH KEY
                               vgbel = i_detquot6-vbeln
*                               posnr = i_detquot6-posnr BINARY SEARCH.
                               vgpos = i_detquot6-posnr. " BINARY SEARCH.
    IF sy-subrc = 0.
      IF i_detsales-abgru IS NOT INITIAL.
        i_detquot6-abgru = i_detsales-abgru.
      ENDIF.
    ENDIF.

    READ TABLE i_detdelv WITH KEY
                              vgbel = i_detsales-vbeln
                              vgpos = i_detsales-posnr. " BINARY SEARCH.

    PERFORM append_itab6.

* Total Sales Office
    AT END OF vkbur.
      wa_stot63-princ = i_output6-princ.
      wa_stot63-kvgr4 = i_output6-kvgr4.
      wa_stot63-bezei = i_output6-bezei.
      CONCATENATE '*    Total' i_output6-vkbur
                  INTO wa_stot63-name1 SEPARATED BY space.
      wa_stot63-info = 'C30'.
      wa_stot63-curr = 'IDR'.
      wa_stot63-index = '20'.
      wa_stot63-deci = '0'.
      wa_stot63-vkbux = i_output6-vkbur.
      APPEND wa_stot63 TO i_output6.

      wa_stot63-name1 = '           Percentage(%)'.
      IF wa_stot63-kzwi1 NE wa_stot63-btamt.
        IF p_val = 'X'.
          wa_stot63-unprc = wa_stot63-unval / ( wa_stot63-kzwi1 -
                            wa_stot63-btamt ) * 100.
          wa_stot63-dlval% = wa_stot63-dlval / ( wa_stot63-kzwi1 -
                            wa_stot63-btamt ) * 100.
          wa_stot63-lead1% = wa_stot63-lead1 / ( wa_stot63-kzwi1 -
                            wa_stot63-btamt ) * 100.
          wa_stot63-lead2% = wa_stot63-lead2 / ( wa_stot63-kzwi1 -
                            wa_stot63-btamt ) * 100.
          wa_stot63-lead3% = wa_stot63-lead3 / ( wa_stot63-kzwi1 -
                            wa_stot63-btamt ) * 100.
          wa_stot63-lead4% = wa_stot63-lead4 / ( wa_stot63-kzwi1 -
                            wa_stot63-btamt ) * 100.
          wa_stot63-lead5% = wa_stot63-lead5 / ( wa_stot63-kzwi1 -
                            wa_stot63-btamt ) * 100.
          wa_stot63-lead6% = wa_stot63-lead6 / ( wa_stot63-kzwi1 -
                            wa_stot63-btamt ) * 100.
          wa_stot63-poout% = wa_stot63-poout / ( wa_stot63-kzwi1 -
                            wa_stot63-btamt ) * 100.
          wa_stot63-btprc% = wa_stot63-btamt / wa_stot63-kzwi1 * 100.
          wa_stot63-stkout% = wa_stot63-stkout / ( wa_stot63-kzwi1 -
                            wa_stot63-btamt ) * 100.
          wa_stot63-cltop% = wa_stot63-cltop / ( wa_stot63-kzwi1 -
                            wa_stot63-btamt ) * 100.
          wa_stot63-salah% = wa_stot63-salah / ( wa_stot63-kzwi1 -
                            wa_stot63-btamt ) * 100.
          wa_stot63-other% = wa_stot63-other / ( wa_stot63-kzwi1 -
                            wa_stot63-btamt ) * 100.
          wa_stot63-reject% = wa_stot63-reject / ( wa_stot63-kzwi1 -
                            wa_stot63-btamt ) * 100.

          PERFORM f_hitung_stot3 USING wa_stot63-kzwi1
                                       wa_stot63-btamt
                                       wa_stot63-kwmeng
                                       wa_stot63-btqty
                                       p_val
                                       '6'.

        ELSE.
          wa_stot63-unprc = wa_stot63-unqty / ( wa_stot63-kwmeng -
                            wa_stot63-btqty ) * 100.
          wa_stot63-dlval% = wa_stot63-dlqty / ( wa_stot63-kwmeng -
                            wa_stot63-btqty ) * 100.
          wa_stot63-lead1% = wa_stot63-lead1q / ( wa_stot63-kwmeng -
                            wa_stot63-btqty ) * 100.
          wa_stot63-lead2% = wa_stot63-lead2q / ( wa_stot63-kwmeng -
                            wa_stot63-btqty ) * 100.
          wa_stot63-lead3% = wa_stot63-lead3q / ( wa_stot63-kwmeng -
                            wa_stot63-btqty ) * 100.
          wa_stot63-lead4% = wa_stot63-lead4q / ( wa_stot63-kwmeng -
                            wa_stot63-btqty ) * 100.
          wa_stot63-lead5% = wa_stot63-lead5q / ( wa_stot63-kwmeng -
                            wa_stot63-btqty ) * 100.
          wa_stot63-lead6% = wa_stot63-lead6q / ( wa_stot63-kwmeng -
                            wa_stot63-btqty ) * 100.
          wa_stot63-poout% = wa_stot63-pooutq / ( wa_stot63-kwmeng -
                            wa_stot63-btqty ) * 100.
          wa_stot63-btprc% = wa_stot63-btqty / wa_stot63-kwmeng * 100.
          wa_stot63-stkout% = wa_stot63-stkoutq / ( wa_stot63-kwmeng -
                            wa_stot63-btqty ) * 100.
          wa_stot63-cltop% = wa_stot63-cltopq / ( wa_stot63-kwmeng -
                            wa_stot63-btqty ) * 100.
          wa_stot63-salah% = wa_stot63-salahq / ( wa_stot63-kwmeng -
                            wa_stot63-btqty ) * 100.
          wa_stot63-other% = wa_stot63-otherq / ( wa_stot63-kwmeng -
                            wa_stot63-btqty ) * 100.
          wa_stot63-reject% = wa_stot63-rejectq / ( wa_stot63-kwmeng -
                            wa_stot63-btqty ) * 100.

          PERFORM f_hitung_stot3 USING wa_stot63-kzwi1
                                       wa_stot63-btamt
                                       wa_stot63-kwmeng
                                       wa_stot63-btqty
                                       p_val
                                       '6'.

        ENDIF.
      ENDIF.

      wa_stot63-dlval = wa_stot63-dlval%.
      IF p_val = 'X'.
        wa_stot63-unval = wa_stot63-unprc.
        wa_stot63-lead1 = wa_stot63-lead1%.
        wa_stot63-lead2 = wa_stot63-lead2%.
        wa_stot63-lead3 = wa_stot63-lead3%.
        wa_stot63-lead4 = wa_stot63-lead4%.
        wa_stot63-lead5 = wa_stot63-lead5%.
        wa_stot63-lead6 = wa_stot63-lead6%.
        wa_stot63-poout = wa_stot63-poout%.
        wa_stot63-btamt = wa_stot63-btprc%.
        wa_stot63-stkout = wa_stot63-stkout%.
        wa_stot63-cltop = wa_stot63-cltop%.
        wa_stot63-salah = wa_stot63-salah%.
        wa_stot63-other = wa_stot63-other%.
        wa_stot63-reject = wa_stot63-reject%.

        PERFORM f_move_stot3 USING p_val '6'.

      ELSE.
        wa_stot63-unqty = wa_stot63-unprc.
        wa_stot63-lead1q = wa_stot63-lead1%.
        wa_stot63-lead2q = wa_stot63-lead2%.
        wa_stot63-lead3q = wa_stot63-lead3%.
        wa_stot63-lead4q = wa_stot63-lead4%.
        wa_stot63-lead5q = wa_stot63-lead5%.
        wa_stot63-lead6q = wa_stot63-lead6%.
        wa_stot63-pooutq = wa_stot63-poout%.
        wa_stot63-btqty = wa_stot63-btprc%.
        wa_stot63-stkoutq = wa_stot63-stkout%.
        wa_stot63-cltopq = wa_stot63-cltop%.
        wa_stot63-salahq = wa_stot63-salah%.
        wa_stot63-otherq = wa_stot63-other%.
        wa_stot63-rejectq = wa_stot63-reject%.

        PERFORM f_move_stot3 USING p_val '6'.

      ENDIF.
      wa_stot63-deci = '2'.
      CLEAR: wa_stot63-vkbur, wa_stot63-knkli,
             wa_stot63-curr, wa_stot63-kwmeng, wa_stot63-kzwi1,
             wa_stot63-dlqty.
      APPEND wa_stot63 TO i_output6.
      CLEAR: wa_stot63.
    ENDAT.

* Total Customer Group
    AT END OF kvgr4.
      wa_stot62-princ = i_output6-princ.
      wa_stot62-kvgr4 = i_output6-kvgr4.
      wa_stot62-bezei = i_output6-bezei.
      CONCATENATE '**   Total' i_output6-kvgr4 i_output6-bezei
                  INTO wa_stot62-name1 SEPARATED BY space.
      wa_stot62-info = 'C31'.
      wa_stot62-curr = 'IDR'.
      wa_stot62-index = '30'.
      wa_stot62-deci = '0'.
      wa_stot62-vkbux = i_output6-vkbur.
      APPEND wa_stot62 TO i_output6.

      wa_stot62-name1 = '           Percentage(%)'.
      IF wa_stot62-kzwi1 NE wa_stot62-btamt.
        IF p_val = 'X'.
          wa_stot62-unprc = wa_stot62-unval / ( wa_stot62-kzwi1 -
                            wa_stot62-btamt ) * 100.
          wa_stot62-dlval% = wa_stot62-dlval / ( wa_stot62-kzwi1 -
                            wa_stot62-btamt ) * 100.
          wa_stot62-lead1% = wa_stot62-lead1 / ( wa_stot62-kzwi1 -
                            wa_stot62-btamt ) * 100.
          wa_stot62-lead2% = wa_stot62-lead2 / ( wa_stot62-kzwi1 -
                            wa_stot62-btamt ) * 100.
          wa_stot62-lead3% = wa_stot62-lead3 / ( wa_stot62-kzwi1 -
                            wa_stot62-btamt ) * 100.
          wa_stot62-lead4% = wa_stot62-lead4 / ( wa_stot62-kzwi1 -
                            wa_stot62-btamt ) * 100.
          wa_stot62-lead5% = wa_stot62-lead5 / ( wa_stot62-kzwi1 -
                            wa_stot62-btamt ) * 100.
          wa_stot62-lead6% = wa_stot62-lead6 / ( wa_stot62-kzwi1 -
                            wa_stot62-btamt ) * 100.
          wa_stot62-poout% = wa_stot62-poout / ( wa_stot62-kzwi1 -
                            wa_stot62-btamt ) * 100.
          wa_stot62-btprc% = wa_stot62-btamt / wa_stot62-kzwi1 * 100.
          wa_stot62-stkout% = wa_stot62-stkout / ( wa_stot62-kzwi1 -
                            wa_stot62-btamt ) * 100.
          wa_stot62-cltop% = wa_stot62-cltop / ( wa_stot62-kzwi1 -
                            wa_stot62-btamt ) * 100.
          wa_stot62-salah% = wa_stot62-salah / ( wa_stot62-kzwi1 -
                            wa_stot62-btamt ) * 100.
          wa_stot62-other% = wa_stot62-other / ( wa_stot62-kzwi1 -
                            wa_stot62-btamt ) * 100.
          wa_stot62-reject% = wa_stot62-reject / ( wa_stot62-kzwi1 -
                            wa_stot62-btamt ) * 100.

          PERFORM f_hitung_stot2 USING wa_stot62-kzwi1
                                       wa_stot62-btamt
                                       wa_stot62-kwmeng
                                       wa_stot62-btqty
                                       p_val
                                       '6'.

        ELSE.
          wa_stot62-unprc = wa_stot62-unqty / ( wa_stot62-kwmeng -
                            wa_stot62-btqty ) * 100.
          wa_stot62-dlval% = wa_stot62-dlqty / ( wa_stot62-kwmeng -
                            wa_stot62-btqty ) * 100.
          wa_stot62-lead1% = wa_stot62-lead1q / ( wa_stot62-kwmeng -
                            wa_stot62-btqty ) * 100.
          wa_stot62-lead2% = wa_stot62-lead2q / ( wa_stot62-kwmeng -
                            wa_stot62-btqty ) * 100.
          wa_stot62-lead3% = wa_stot62-lead3q / ( wa_stot62-kwmeng -
                            wa_stot62-btqty ) * 100.
          wa_stot62-lead4% = wa_stot62-lead4q / ( wa_stot62-kwmeng -
                            wa_stot62-btqty ) * 100.
          wa_stot62-lead5% = wa_stot62-lead5q / ( wa_stot62-kwmeng -
                            wa_stot62-btqty ) * 100.
          wa_stot62-lead6% = wa_stot62-lead6q / ( wa_stot62-kwmeng -
                            wa_stot62-btqty ) * 100.
          wa_stot62-poout% = wa_stot62-pooutq / ( wa_stot62-kwmeng -
                            wa_stot62-btqty ) * 100.
          wa_stot62-btprc% = wa_stot62-btqty / wa_stot62-kwmeng * 100.
          wa_stot62-stkout% = wa_stot62-stkoutq / ( wa_stot62-kwmeng -
                            wa_stot62-btqty ) * 100.
          wa_stot62-cltop% = wa_stot62-cltopq / ( wa_stot62-kwmeng -
                            wa_stot62-btqty ) * 100.
          wa_stot62-salah% = wa_stot62-salahq / ( wa_stot62-kwmeng -
                            wa_stot62-btqty ) * 100.
          wa_stot62-other% = wa_stot62-otherq / ( wa_stot62-kwmeng -
                            wa_stot62-btqty ) * 100.
          wa_stot62-reject% = wa_stot62-rejectq / ( wa_stot62-kwmeng -
                            wa_stot62-btqty ) * 100.

          PERFORM f_hitung_stot2 USING wa_stot62-kzwi1
                                       wa_stot62-btamt
                                       wa_stot62-kwmeng
                                       wa_stot62-btqty
                                       p_val
                                       '6'.

        ENDIF.
      ENDIF.

      wa_stot62-dlval = wa_stot62-dlval%.
      IF p_val = 'X'.
        wa_stot62-unval = wa_stot62-unprc.
        wa_stot62-lead1 = wa_stot62-lead1%.
        wa_stot62-lead2 = wa_stot62-lead2%.
        wa_stot62-lead3 = wa_stot62-lead3%.
        wa_stot62-lead4 = wa_stot62-lead4%.
        wa_stot62-lead5 = wa_stot62-lead5%.
        wa_stot62-lead6 = wa_stot62-lead6%.
        wa_stot62-poout = wa_stot62-poout%.
        wa_stot62-btamt = wa_stot62-btprc%.
        wa_stot62-stkout = wa_stot62-stkout%.
        wa_stot62-cltop = wa_stot62-cltop%.
        wa_stot62-salah = wa_stot62-salah%.
        wa_stot62-other = wa_stot62-other%.
        wa_stot62-reject = wa_stot62-reject%.

        PERFORM f_move_stot2 USING p_val '6'.

      ELSE.
        wa_stot62-unqty = wa_stot62-unprc.
        wa_stot62-lead1q = wa_stot62-lead1%.
        wa_stot62-lead2q = wa_stot62-lead2%.
        wa_stot62-lead3q = wa_stot62-lead3%.
        wa_stot62-lead4q = wa_stot62-lead4%.
        wa_stot62-lead5q = wa_stot62-lead5%.
        wa_stot62-lead6q = wa_stot62-lead6%.
        wa_stot62-pooutq = wa_stot62-poout%.
        wa_stot62-btqty = wa_stot62-btprc%.
        wa_stot62-stkoutq = wa_stot62-stkout%.
        wa_stot62-cltopq = wa_stot62-cltop%.
        wa_stot62-salahq = wa_stot62-salah%.
        wa_stot62-otherq = wa_stot62-other%.
        wa_stot62-rejectq = wa_stot62-reject%.

        PERFORM f_move_stot2 USING p_val '6'.

      ENDIF.
      wa_stot62-deci = '2'.
      CLEAR: wa_stot62-vkbur, wa_stot62-knkli,
             wa_stot62-curr, wa_stot62-kwmeng, wa_stot62-kzwi1,
             wa_stot62-dlqty.
      APPEND wa_stot62 TO i_output6.
      CLEAR: wa_stot62, wa_stot63.
    ENDAT.

* Total Principal
    AT END OF princ.
      wa_stot61-princ = i_output6-princ.
      wa_stot61-kvgr4 = i_output6-kvgr4.
      wa_stot61-bezei = i_output6-bezei.
      CONCATENATE '***  Total' i_output6-princ
                  INTO wa_stot61-name1 SEPARATED BY space.
      wa_stot61-info = 'C70'.
      wa_stot61-curr = 'IDR'.
      wa_stot61-index = '40'.
      wa_stot61-deci = '0'.
      wa_stot61-vkbux = i_output6-vkbur.
      APPEND wa_stot61 TO i_output6.

      wa_stot61-name1 = '           Percentage(%)'.
      IF wa_stot61-kzwi1 NE wa_stot61-btamt.
        IF p_val = 'X'.
          wa_stot61-unprc = wa_stot61-unval / ( wa_stot61-kzwi1 -
                            wa_stot61-btamt ) * 100.
          wa_stot61-dlval% = wa_stot61-dlval / ( wa_stot61-kzwi1 -
                            wa_stot61-btamt ) * 100.
          wa_stot61-lead1% = wa_stot61-lead1 / ( wa_stot61-kzwi1 -
                            wa_stot61-btamt ) * 100.
          wa_stot61-lead2% = wa_stot61-lead2 / ( wa_stot61-kzwi1 -
                            wa_stot61-btamt ) * 100.
          wa_stot61-lead3% = wa_stot61-lead3 / ( wa_stot61-kzwi1 -
                            wa_stot61-btamt ) * 100.
          wa_stot61-lead4% = wa_stot61-lead4 / ( wa_stot61-kzwi1 -
                            wa_stot61-btamt ) * 100.
          wa_stot61-lead5% = wa_stot61-lead5 / ( wa_stot61-kzwi1 -
                            wa_stot61-btamt ) * 100.
          wa_stot61-lead6% = wa_stot61-lead6 / ( wa_stot61-kzwi1 -
                            wa_stot61-btamt ) * 100.
          wa_stot61-poout% = wa_stot61-poout / ( wa_stot61-kzwi1 -
                            wa_stot61-btamt ) * 100.
          wa_stot61-btprc% = wa_stot61-btamt / wa_stot61-kzwi1 * 100.
          wa_stot61-stkout% = wa_stot61-stkout / ( wa_stot61-kzwi1 -
                            wa_stot61-btamt ) * 100.
          wa_stot61-cltop% = wa_stot61-cltop / ( wa_stot61-kzwi1 -
                            wa_stot61-btamt ) * 100.
          wa_stot61-salah% = wa_stot61-salah / ( wa_stot61-kzwi1 -
                            wa_stot61-btamt ) * 100.
          wa_stot61-other% = wa_stot61-other / ( wa_stot61-kzwi1 -
                            wa_stot61-btamt ) * 100.
          wa_stot61-reject% = wa_stot61-reject / ( wa_stot61-kzwi1 -
                            wa_stot61-btamt ) * 100.

          PERFORM f_hitung_stot1 USING wa_stot61-kzwi1
                                       wa_stot61-btamt
                                       wa_stot61-kwmeng
                                       wa_stot61-btqty
                                       p_val
                                       '6'.

        ELSE.
          wa_stot61-unprc = wa_stot61-unqty / ( wa_stot61-kwmeng -
                            wa_stot61-btqty ) * 100.
          wa_stot61-dlval% = wa_stot61-dlqty / ( wa_stot61-kwmeng -
                            wa_stot61-btqty ) * 100.
          wa_stot61-lead1% = wa_stot61-lead1q / ( wa_stot61-kwmeng -
                            wa_stot61-btqty ) * 100.
          wa_stot61-lead2% = wa_stot61-lead2q / ( wa_stot61-kwmeng -
                            wa_stot61-btqty ) * 100.
          wa_stot61-lead3% = wa_stot61-lead3q / ( wa_stot61-kwmeng -
                            wa_stot61-btqty ) * 100.
          wa_stot61-lead4% = wa_stot61-lead4q / ( wa_stot61-kwmeng -
                            wa_stot61-btqty ) * 100.
          wa_stot61-lead5% = wa_stot61-lead5q / ( wa_stot61-kwmeng -
                            wa_stot61-btqty ) * 100.
          wa_stot61-lead6% = wa_stot61-lead6q / ( wa_stot61-kwmeng -
                            wa_stot61-btqty ) * 100.
          wa_stot61-poout% = wa_stot61-pooutq / ( wa_stot61-kwmeng -
                            wa_stot61-btqty ) * 100.
          wa_stot61-btprc% = wa_stot61-btqty / wa_stot61-kwmeng * 100.
          wa_stot61-stkout% = wa_stot61-stkoutq / ( wa_stot61-kwmeng -
                            wa_stot61-btqty ) * 100.
          wa_stot61-cltop% = wa_stot61-cltopq / ( wa_stot61-kwmeng -
                            wa_stot61-btqty ) * 100.
          wa_stot61-salah% = wa_stot61-salahq / ( wa_stot61-kwmeng -
                            wa_stot61-btqty ) * 100.
          wa_stot61-other% = wa_stot61-otherq / ( wa_stot61-kwmeng -
                            wa_stot61-btqty ) * 100.
          wa_stot61-reject% = wa_stot61-rejectq / ( wa_stot61-kwmeng -
                            wa_stot61-btqty ) * 100.

          PERFORM f_hitung_stot1 USING wa_stot61-kzwi1
                                       wa_stot61-btamt
                                       wa_stot61-kwmeng
                                       wa_stot61-btqty
                                       p_val
                                       '6'.

        ENDIF.
      ENDIF.

      wa_stot61-dlval = wa_stot61-dlval%.
      IF p_val = 'X'.
        wa_stot61-unval = wa_stot61-unprc.
        wa_stot61-lead1 = wa_stot61-lead1%.
        wa_stot61-lead2 = wa_stot61-lead2%.
        wa_stot61-lead3 = wa_stot61-lead3%.
        wa_stot61-lead4 = wa_stot61-lead4%.
        wa_stot61-lead5 = wa_stot61-lead5%.
        wa_stot61-lead6 = wa_stot61-lead6%.
        wa_stot61-poout = wa_stot61-poout%.
        wa_stot61-btamt = wa_stot61-btprc%.
        wa_stot61-stkout = wa_stot61-stkout%.
        wa_stot61-cltop = wa_stot61-cltop%.
        wa_stot61-salah = wa_stot61-salah%.
        wa_stot61-other = wa_stot61-other%.
        wa_stot61-reject = wa_stot61-reject%.

        PERFORM f_move_stot1 USING p_val '6'.

      ELSE.
        wa_stot61-unqty = wa_stot61-unprc.
        wa_stot61-lead1q = wa_stot61-lead1%.
        wa_stot61-lead2q = wa_stot61-lead2%.
        wa_stot61-lead3q = wa_stot61-lead3%.
        wa_stot61-lead4q = wa_stot61-lead4%.
        wa_stot61-lead5q = wa_stot61-lead5%.
        wa_stot61-lead6q = wa_stot61-lead6%.
        wa_stot61-pooutq = wa_stot61-poout%.
        wa_stot61-btqty = wa_stot61-btprc%.
        wa_stot61-stkoutq = wa_stot61-stkout%.
        wa_stot61-cltopq = wa_stot61-cltop%.
        wa_stot61-salahq = wa_stot61-salah%.
        wa_stot61-otherq = wa_stot61-other%.
        wa_stot61-rejectq = wa_stot61-reject%.

        PERFORM f_move_stot1 USING p_val '6'.

      ENDIF.
      wa_stot61-deci = '2'.
      CLEAR: wa_stot61-vkbur, wa_stot61-knkli,
             wa_stot61-curr, wa_stot61-kwmeng, wa_stot61-kzwi1,
             wa_stot61-dlqty.
      APPEND wa_stot61 TO i_output6.
      CLEAR: wa_stot61, wa_stot62, wa_stot63.
    ENDAT.

  ENDLOOP.

* Total Grand
  wa_gtot6-princ = i_output6-princ.
  wa_gtot6-kvgr4 = i_output6-kvgr4.
  wa_gtot6-bezei = i_output6-bezei.
  wa_gtot6-name1 = '**** Grand Total'.
  wa_gtot6-info = 'C71'.
  wa_gtot6-curr = 'IDR'.
  wa_gtot6-index = '50'.
  wa_gtot6-deci = '0'.
  wa_gtot6-vkbux = i_output6-vkbur.
  APPEND wa_gtot6 TO i_output6.

  wa_gtot6-name1 = '           Percentage(%)'.
  IF wa_gtot6-kzwi1 NE wa_gtot6-btamt.
    IF p_val = 'X'.
      wa_gtot6-unprc = wa_gtot6-unval / ( wa_gtot6-kzwi1 -
                            wa_gtot6-btamt ) * 100.
      wa_gtot6-dlval% = wa_gtot6-dlval / ( wa_gtot6-kzwi1 -
                            wa_gtot6-btamt ) * 100.
      wa_gtot6-lead1% = wa_gtot6-lead1 / ( wa_gtot6-kzwi1 -
                            wa_gtot6-btamt ) * 100.
      wa_gtot6-lead2% = wa_gtot6-lead2 / ( wa_gtot6-kzwi1 -
                            wa_gtot6-btamt ) * 100.
      wa_gtot6-lead3% = wa_gtot6-lead3 / ( wa_gtot6-kzwi1 -
                            wa_gtot6-btamt ) * 100.
      wa_gtot6-lead4% = wa_gtot6-lead4 / ( wa_gtot6-kzwi1 -
                            wa_gtot6-btamt ) * 100.
      wa_gtot6-lead5% = wa_gtot6-lead5 / ( wa_gtot6-kzwi1 -
                            wa_gtot6-btamt ) * 100.
      wa_gtot6-lead6% = wa_gtot6-lead6 / ( wa_gtot6-kzwi1 -
                            wa_gtot6-btamt ) * 100.
      wa_gtot6-poout% = wa_gtot6-poout / ( wa_gtot6-kzwi1 -
                            wa_gtot6-btamt ) * 100.
      wa_gtot6-btprc% = wa_gtot6-btamt / wa_gtot6-kzwi1 * 100.
      wa_gtot6-stkout% = wa_gtot6-stkout / ( wa_gtot6-kzwi1 -
                            wa_gtot6-btamt ) * 100.
      wa_gtot6-cltop% = wa_gtot6-cltop / ( wa_gtot6-kzwi1 -
                        wa_gtot6-btamt ) * 100.
      wa_gtot6-salah% = wa_gtot6-salah / ( wa_gtot6-kzwi1 -
                        wa_gtot6-btamt ) * 100.
      wa_gtot6-other% = wa_gtot6-other / ( wa_gtot6-kzwi1 -
                        wa_gtot6-btamt ) * 100.
      wa_gtot6-reject% = wa_gtot6-reject / ( wa_gtot6-kzwi1 -
                            wa_gtot6-btamt ) * 100.

      PERFORM f_hitung_gtot USING wa_gtot6-kzwi1
                                   wa_gtot6-btamt
                                   wa_gtot6-kwmeng
                                   wa_gtot6-btqty
                                   p_val
                                   '6'.

    ELSE.
      wa_gtot6-unprc = wa_gtot6-unqty / ( wa_gtot6-kwmeng -
                            wa_gtot6-btqty ) * 100.
      wa_gtot6-dlval% = wa_gtot6-dlqty / ( wa_gtot6-kwmeng -
                            wa_gtot6-btqty ) * 100.
      wa_gtot6-lead1% = wa_gtot6-lead1q / ( wa_gtot6-kwmeng -
                            wa_gtot6-btqty ) * 100.
      wa_gtot6-lead2% = wa_gtot6-lead2q / ( wa_gtot6-kwmeng -
                            wa_gtot6-btqty ) * 100.
      wa_gtot6-lead3% = wa_gtot6-lead3q / ( wa_gtot6-kwmeng -
                            wa_gtot6-btqty ) * 100.
      wa_gtot6-lead4% = wa_gtot6-lead4q / ( wa_gtot6-kwmeng -
                            wa_gtot6-btqty ) * 100.
      wa_gtot6-lead5% = wa_gtot6-lead5q / ( wa_gtot6-kwmeng -
                            wa_gtot6-btqty ) * 100.
      wa_gtot6-lead6% = wa_gtot6-lead6q / ( wa_gtot6-kwmeng -
                            wa_gtot6-btqty ) * 100.
      wa_gtot6-poout% = wa_gtot6-pooutq / ( wa_gtot6-kwmeng -
                            wa_gtot6-btqty ) * 100.
      wa_gtot6-btprc% = wa_gtot6-btqty / wa_gtot6-kwmeng * 100.
      wa_gtot6-stkout% = wa_gtot6-stkoutq / ( wa_gtot6-kwmeng -
                            wa_gtot6-btqty ) * 100.
      wa_gtot6-cltop% = wa_gtot6-cltopq / ( wa_gtot6-kwmeng -
                        wa_gtot6-btqty ) * 100.
      wa_gtot6-salah% = wa_gtot6-salahq / ( wa_gtot6-kwmeng -
                        wa_gtot6-btqty ) * 100.
      wa_gtot6-other% = wa_gtot6-otherq / ( wa_gtot6-kwmeng -
                        wa_gtot6-btqty ) * 100.
      wa_gtot6-reject% = wa_gtot6-rejectq / ( wa_gtot6-kwmeng -
                            wa_gtot6-btqty ) * 100.

      PERFORM f_hitung_gtot USING wa_gtot6-kzwi1
                                   wa_gtot6-btamt
                                   wa_gtot6-kwmeng
                                   wa_gtot6-btqty
                                   p_val
                                   '6'.

    ENDIF.
  ENDIF.

  wa_gtot6-dlval = wa_gtot6-dlval%.
  IF p_val = 'X'.
    wa_gtot6-unval = wa_gtot6-unprc.
    wa_gtot6-lead1 = wa_gtot6-lead1%.
    wa_gtot6-lead2 = wa_gtot6-lead2%.
    wa_gtot6-lead3 = wa_gtot6-lead3%.
    wa_gtot6-lead4 = wa_gtot6-lead4%.
    wa_gtot6-lead5 = wa_gtot6-lead5%.
    wa_gtot6-lead6 = wa_gtot6-lead6%.
    wa_gtot6-poout = wa_gtot6-poout%.
    wa_gtot6-btamt = wa_gtot6-btprc%.
    wa_gtot6-stkout = wa_gtot6-stkout%.
    wa_gtot6-cltop = wa_gtot6-cltop%.
    wa_gtot6-salah = wa_gtot6-salah%.
    wa_gtot6-other = wa_gtot6-other%.
    wa_gtot6-reject = wa_gtot6-reject%.

    PERFORM f_move_gtot USING p_val '6'.

  ELSE.
    wa_gtot6-unqty = wa_gtot6-unprc.
    wa_gtot6-lead1q = wa_gtot6-lead1%.
    wa_gtot6-lead2q = wa_gtot6-lead2%.
    wa_gtot6-lead3q = wa_gtot6-lead3%.
    wa_gtot6-lead4q = wa_gtot6-lead4%.
    wa_gtot6-lead5q = wa_gtot6-lead5%.
    wa_gtot6-lead6q = wa_gtot6-lead6%.
    wa_gtot6-pooutq = wa_gtot6-poout%.
    wa_gtot6-btqty = wa_gtot6-btprc%.
    wa_gtot6-cltopq = wa_gtot6-cltop%.
    wa_gtot6-salahq = wa_gtot6-salah%.
    wa_gtot6-otherq = wa_gtot6-other%.
    wa_gtot6-stkoutq = wa_gtot6-stkout%.
    wa_gtot6-rejectq = wa_gtot6-reject%.

    PERFORM f_move_gtot USING p_val '6'.

  ENDIF.
  wa_gtot6-deci = '2'.
  CLEAR: wa_gtot6-vkbur, wa_gtot6-knkli,
         wa_gtot6-curr, wa_gtot6-kwmeng, wa_gtot6-kzwi1,
         wa_gtot6-dlqty.
  APPEND wa_gtot6 TO i_output6.
  CLEAR: wa_gtot6.

  IF p_total6 = 'X'.
    DELETE i_output6 WHERE index LT '30'.
  ENDIF.

ENDFORM.                    " proses_data6

*&---------------------------------------------------------------------*
*&      Form  f_build_fieldcat6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_fieldcat6.
  DEFINE mac_header6.
    read table t_abgru index &1.
    if sy-subrc eq 0.
      if p_val = 'X'.
        fieldcat-fieldname = 'VAL&1'.
        fieldcat-ref_fieldname = ''.
        fieldcat-tabname = 'I_OUTPUT6'.
        fieldcat-outputlen = 15.
        fieldcat-cfieldname = 'CURR'.
        fieldcat-seltext_s = t_abgru-bezei.
        fieldcat-seltext_m = t_abgru-bezei.
        fieldcat-seltext_l = t_abgru-bezei.
        append fieldcat. "clear fieldcat.
      else.
        fieldcat-fieldname = 'QTY&1'.
        fieldcat-ref_fieldname = ''.
        fieldcat-tabname = 'I_OUTPUT6'.
        fieldcat-outputlen = 15.
        fieldcat-decimalsfieldname = 'DECI'.
        fieldcat-seltext_s = t_abgru-bezei.
        fieldcat-seltext_m = t_abgru-bezei.
        fieldcat-seltext_l = t_abgru-bezei.
        append fieldcat. "clear fieldcat.
      endif.
    endif.
  END-OF-DEFINITION.

  fieldcat-fieldname = 'VKBUR'.
  fieldcat-ref_fieldname = 'VKBUR'.
  fieldcat-tabname = 'I_OUTPUT6'.
  fieldcat-outputlen = 6.
  fieldcat-seltext_s = 'Sl Off'.
  fieldcat-seltext_m = 'Sls Off'.
  fieldcat-seltext_l = 'Sales Office'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'KNKLI'.
  fieldcat-ref_fieldname = 'KNKLI'.
  fieldcat-tabname = 'I_OUTPUT6'.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'Customer'.
  fieldcat-seltext_m = 'Customer'.
  fieldcat-seltext_l = 'Customer'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'NAME1'.
  fieldcat-ref_fieldname = 'NAME1'.
  fieldcat-tabname = 'I_OUTPUT6'.
  fieldcat-outputlen = 25.
  fieldcat-seltext_s = 'Customer Name'.
  fieldcat-seltext_m = 'Customer Name'.
  fieldcat-seltext_l = 'Customer Name'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'KWMENG'.
  fieldcat-ref_fieldname = 'KWMENG'.
  fieldcat-tabname = 'I_OUTPUT6'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'PO Qty'.
  fieldcat-seltext_m = 'PO Quantity'.
  fieldcat-seltext_l = 'PO Quantity'.
  fieldcat-decimals_out = '0'.
  fieldcat-no_zero = 'X'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'KZWI1'.
  fieldcat-ref_fieldname = 'KZWI1'.
  fieldcat-tabname = 'I_OUTPUT6'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'PO Amount'.
  fieldcat-seltext_m = 'PO Amount'.
  fieldcat-seltext_l = 'PO Amount'.
  fieldcat-currency = 'IDR'.
  fieldcat-decimals_out = '0'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out.

*  IF p_val = 'X'.
*    fieldcat-fieldname = 'BTAMT'.
*    fieldcat-ref_fieldname = 'BTAMT'.
*    fieldcat-tabname = 'I_OUTPUT6'.
*    fieldcat-outputlen = 13.
*    fieldcat-seltext_s = 'PO Batal'.
*    fieldcat-seltext_m = 'PO Batal'.
*    fieldcat-seltext_l = 'PO Batal'.
*    fieldcat-cfieldname = 'CURR'.
*    APPEND fieldcat. "clear fieldcat.
*  ELSE.
*    fieldcat-fieldname = 'BTQTY'.
*    fieldcat-ref_fieldname = 'BTQTY'.
*    fieldcat-tabname = 'I_OUTPUT6'.
*    fieldcat-outputlen = 13.
*    fieldcat-seltext_s = 'PO Batal'.
*    fieldcat-seltext_m = 'PO Batal'.
*    fieldcat-seltext_l = 'PO Batal'.
*    fieldcat-decimalsfieldname = 'DECI'.
*    APPEND fieldcat. "clear fieldcat.
*  ENDIF.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname,
         fieldcat-decimalsfieldname.

  fieldcat-fieldname = 'DLQTY'.
  fieldcat-ref_fieldname = 'DLQTY'.
  fieldcat-tabname = 'I_OUTPUT6'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'DO Qty'.
  fieldcat-seltext_m = 'DO Quantity'.
  fieldcat-seltext_l = 'DO Quantity'.
  fieldcat-decimals_out = '0'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname.

  fieldcat-fieldname = 'DLVAL'.
  fieldcat-ref_fieldname = 'DLVAL'.
  fieldcat-tabname = 'I_OUTPUT6'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'DO Amount'.
  fieldcat-seltext_m = 'DO AMount'.
  fieldcat-seltext_l = 'DO AMount'.
  fieldcat-cfieldname = 'CURR'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname.

  IF p_val = 'X'.
    fieldcat-fieldname = 'LEAD6'.
    fieldcat-ref_fieldname = 'LEAD6'.
    fieldcat-tabname = 'I_OUTPUT6'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Intransit'.
    fieldcat-seltext_m = 'Intransit'.
    fieldcat-seltext_l = 'Intransit'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD1'.
    fieldcat-ref_fieldname = 'LEAD1'.
    fieldcat-tabname = 'I_OUTPUT6'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead <= 3'.
    fieldcat-seltext_m = 'Lead <= 3'.
    fieldcat-seltext_l = 'Lead <= 3'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD2'.
    fieldcat-ref_fieldname = 'LEAD2'.
    fieldcat-tabname = 'I_OUTPUT6'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead = 4'.
    fieldcat-seltext_m = 'Lead = 4'.
    fieldcat-seltext_l = 'Lead = 4'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD3'.
    fieldcat-ref_fieldname = 'LEAD3'.
    fieldcat-tabname = 'I_OUTPUT6'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead >= 5'.
    fieldcat-seltext_m = 'Lead >= 5'.
    fieldcat-seltext_l = 'Lead >= 5'.
    APPEND fieldcat. "clear fieldcat.
  ELSE.
    fieldcat-fieldname = 'LEAD6Q'.
    fieldcat-ref_fieldname = 'LEAD6Q'.
    fieldcat-tabname = 'I_OUTPUT6'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Intransit'.
    fieldcat-seltext_m = 'Intransit'.
    fieldcat-seltext_l = 'Intransit'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD1Q'.
    fieldcat-ref_fieldname = 'LEAD1Q'.
    fieldcat-tabname = 'I_OUTPUT6'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead <= 3'.
    fieldcat-seltext_m = 'Lead <= 3'.
    fieldcat-seltext_l = 'Lead <= 3'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD2Q'.
    fieldcat-ref_fieldname = 'LEAD2Q'.
    fieldcat-tabname = 'I_OUTPUT6'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead = 4'.
    fieldcat-seltext_m = 'Lead = 4'.
    fieldcat-seltext_l = 'Lead = 4'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD3Q'.
    fieldcat-ref_fieldname = 'LEAD3Q'.
    fieldcat-tabname = 'I_OUTPUT6'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead >= 5'.
    fieldcat-seltext_m = 'Lead >= 5'.
    fieldcat-seltext_l = 'Lead >= 5'.
    APPEND fieldcat. "clear fieldcat.
  ENDIF.

*  fieldcat-fieldname = 'LEAD4'.
*  fieldcat-ref_fieldname = 'LEAD4'.
*  fieldcat-tabname = 'I_OUTPUT6'.
*  fieldcat-outputlen = 13.
*  fieldcat-cfieldname = 'CURR'.
*  fieldcat-seltext_s = 'Lead >= 6'.
*  fieldcat-seltext_m = 'Lead >= 6'.
*  fieldcat-seltext_l = 'Lead >= 6'.
*  APPEND fieldcat. "clear fieldcat.

*  fieldcat-fieldname = 'LEAD5'.
*  fieldcat-ref_fieldname = 'LEAD5'.
*  fieldcat-tabname = 'I_OUTPUT6'.
*  fieldcat-outputlen = 13.
*  fieldcat-cfieldname = 'CURR'.
*  fieldcat-seltext_s = 'Lead >= 7'.
*  fieldcat-seltext_m = 'Lead >= 7'.
*  fieldcat-seltext_l = 'Lead >= 7'.
*  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname,
         fieldcat-decimalsfieldname.

  IF p_val = 'X'.
    fieldcat-fieldname = 'UNVAL'.
    fieldcat-ref_fieldname = 'UNVAL'.
    fieldcat-tabname = 'I_OUTPUT6'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Undlv Amount'.
    fieldcat-seltext_m = 'Undelivered Amount'.
    fieldcat-seltext_l = 'Undelivered Amount'.
    APPEND fieldcat. "clear fieldcat.

*    fieldcat-fieldname = 'CLTOP'.
*    fieldcat-ref_fieldname = 'CLTOP'.
*    fieldcat-tabname = 'I_OUTPUT6'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'CL / TOP'.
*    fieldcat-seltext_m = 'CL / TOP'.
*    fieldcat-seltext_l = 'CL / TOP'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'STKOUT'.
*    fieldcat-ref_fieldname = 'STKOUT'.
*    fieldcat-tabname = 'I_OUTPUT6'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Stock Out'.
*    fieldcat-seltext_m = 'Stock Out'.
*    fieldcat-seltext_l = 'Stock Out'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'SALAH'.
*    fieldcat-ref_fieldname = 'SALAH'.
*    fieldcat-tabname = 'I_OUTPUT6'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Salah Harga'.
*    fieldcat-seltext_m = 'Salah Harga'.
*    fieldcat-seltext_l = 'Salah Harga'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'OTHER'.
*    fieldcat-ref_fieldname = 'OTHER'.
*    fieldcat-tabname = 'I_OUTPUT6'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Other'.
*    fieldcat-seltext_m = 'Other'.
*    fieldcat-seltext_l = 'Other'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'POOUT'.
*    fieldcat-ref_fieldname = 'POOUT'.
*    fieldcat-tabname = 'I_OUTPUT6'.
*    fieldcat-outputlen = 13.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'PO Outs'.
*    fieldcat-seltext_m = 'PO Outstanding'.
*    fieldcat-seltext_l = 'PO Outstanding'.
*    APPEND fieldcat. "clear fieldcat.
  ELSE.
    fieldcat-fieldname = 'UNQTY'.
    fieldcat-ref_fieldname = 'UNQTY'.
    fieldcat-tabname = 'I_OUTPUT6'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Undlv Qty'.
    fieldcat-seltext_m = 'Undelivered Quantity'.
    fieldcat-seltext_l = 'Undelivered Quantity'.
    APPEND fieldcat. "clear fieldcat.

*    fieldcat-fieldname = 'CLTOPQ'.
*    fieldcat-ref_fieldname = 'CLTOPQ'.
*    fieldcat-tabname = 'I_OUTPUT6'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'CL / TOP'.
*    fieldcat-seltext_m = 'CL / TOP'.
*    fieldcat-seltext_l = 'CL / TOP'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'STKOUTQ'.
*    fieldcat-ref_fieldname = 'STKOUTQ'.
*    fieldcat-tabname = 'I_OUTPUT6'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Stock Out'.
*    fieldcat-seltext_m = 'Stock Out'.
*    fieldcat-seltext_l = 'Stock Out'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'SALAHQ'.
*    fieldcat-ref_fieldname = 'SALAHQ'.
*    fieldcat-tabname = 'I_OUTPUT6'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Salah Harga'.
*    fieldcat-seltext_m = 'Salah Harga'.
*    fieldcat-seltext_l = 'Salah Harga'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'OTHERQ'.
*    fieldcat-ref_fieldname = 'OTHERQ'.
*    fieldcat-tabname = 'I_OUTPUT6'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Other'.
*    fieldcat-seltext_m = 'Other'.
*    fieldcat-seltext_l = 'Other'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'POOUTQ'.
*    fieldcat-ref_fieldname = 'POOUTQ'.
*    fieldcat-tabname = 'I_OUTPUT6'.
*    fieldcat-outputlen = 13.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'PO Outs'.
*    fieldcat-seltext_m = 'PO Outstanding'.
*    fieldcat-seltext_l = 'PO Outstanding'.
*    APPEND fieldcat. "clear fieldcat.
  ENDIF.

  mac_header6 : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.

ENDFORM.                    " f_build_fieldcat6

*&---------------------------------------------------------------------*
*&      Form  f_build_sortfield6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_SORT
*----------------------------------------------------------------------*
FORM f_build_sortfield6 USING fu_sort TYPE slis_t_sortinfo_alv.

  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'PRINC'.
  ld_sort-up        = 'X'.
  ld_sort-group     = '*'.
  APPEND ld_sort TO fu_sort.

  IF p_total6 IS INITIAL.
    CLEAR ld_sort.
    ld_sort-fieldname = 'KVGR4'.
    ld_sort-up        = 'X'.
    ld_sort-group     = '*'.
    APPEND ld_sort TO fu_sort.
  ELSE.
    CLEAR ld_sort.
    ld_sort-fieldname = 'KVGR4'.
    ld_sort-up        = 'X'.
*  ld_sort-group     = '*'.
    APPEND ld_sort TO fu_sort.
  ENDIF.

  CLEAR ld_sort.
  ld_sort-fieldname = 'VKBUX'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'INDEX'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  APPEND ld_sort TO fu_sort.

ENDFORM.                    " f_build_sortfield6

*&---------------------------------------------------------------------*
*&      Form  f_build_event6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_EVENTS
*----------------------------------------------------------------------*
FORM f_build_event6 TABLES ft_events LIKE t_events.

  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE6'.
  APPEND ft_events.

ENDFORM.                    " f_build_event5

*&---------------------------------------------------------------------*
*&      Form  append_itab6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_itab6.

  DATA : l_crdat  LIKE  zmm_cust_rec-crdat,
         l_leadt  TYPE  i.

  MOVE-CORRESPONDING i_detquot6 TO i_output6.

  IF NOT i_detdelv-vbeln IS INITIAL.
    i_output6-dlqty = i_detsales-kwmeng.
    i_output6-dlval = i_detsales-kzwi1.
    i_output6-unqty = i_output6-kwmeng - i_output6-dlqty.
    i_output6-unval = i_output6-kzwi1 - i_output6-dlval.

    IF i_output6-unqty LT 0.
      CLEAR: i_output6-unqty,i_output6-unval.
    ENDIF.

    SELECT SINGLE crdat FROM zmm_cust_rec
      INTO l_crdat
      WHERE vbeln = i_detdelv-vbeln.

    IF l_crdat IS INITIAL.
      i_output6-lead6q = i_output6-dlqty.
      i_output6-lead6 = i_output6-dlval.
    ELSE.
      l_leadt = l_crdat - i_detquot6-bstdk.
      IF l_leadt LE 3.
        i_output6-lead1q = i_output6-dlqty.
        i_output6-lead1 = i_output6-dlval.
      ELSEIF l_leadt = 4.
        i_output6-lead2q = i_output6-dlqty.
        i_output6-lead2 = i_output6-dlval.
      ELSEIF l_leadt GE 5.
        i_output6-lead3q = i_output6-dlqty.
        i_output6-lead3 = i_output6-dlval.
*      ELSEIF l_leadt GE 6.
*        i_output6-lead4 = i_output6-dlval.
*      ELSEIF l_leadt GE 7.
*        i_output6-lead5 = i_output6-dlval.
      ENDIF.
    ENDIF.
  ELSE.
    IF i_detsales-vbeln IS INITIAL.
      i_output6-unqty = i_output6-kwmeng.
      i_output6-unval = i_output6-kzwi1.
    ELSE.
      IF NOT i_detquot6-abgru IS INITIAL.
        i_output6-unqty = i_output6-kwmeng.
        i_output6-unval = i_output6-kzwi1.
      ELSE.
        i_output6-pooutq = i_output6-kwmeng.
        i_output6-poout = i_output6-kzwi1.
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM f_reason_for_rejection USING i_detquot6-abgru
                                       i_output6-unqty
                                       i_output6-unval
                                       '6'.

  SELECT SINGLE bezei INTO i_output6-bezei
    FROM tvv4t
    WHERE spras = sy-langu AND
          kvgr4 = i_output6-kvgr4.

  SELECT SINGLE bezei FROM tvkbt
    INTO i_output6-vkburt
    WHERE spras = sy-langu AND
          vkbur = i_output6-vkbur.

  i_output6-reject = i_output6-unval - i_output6-stkout.

  PERFORM hitung_total6.

  i_output6-curr = 'IDR'.
  i_output6-index = '10'.
  i_output6-deci = '0'.
  i_output6-vkbux = i_output6-vkbur.

  COLLECT i_output6.

ENDFORM.                    " append_itab6

*&---------------------------------------------------------------------*
*&      Form  hitung_total6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hitung_total6.

  ADD i_output6-kwmeng TO wa_stot61-kwmeng.
  ADD i_output6-kwmeng TO wa_stot62-kwmeng.
  ADD i_output6-kwmeng TO wa_stot63-kwmeng.
  ADD i_output6-kwmeng TO wa_gtot6-kwmeng.
  ADD i_output6-kzwi1 TO wa_stot61-kzwi1.
  ADD i_output6-kzwi1 TO wa_stot62-kzwi1.
  ADD i_output6-kzwi1 TO wa_stot63-kzwi1.
  ADD i_output6-kzwi1 TO wa_gtot6-kzwi1.
  ADD i_output6-dlqty TO wa_stot61-dlqty.
  ADD i_output6-dlqty TO wa_stot62-dlqty.
  ADD i_output6-dlqty TO wa_stot63-dlqty.
  ADD i_output6-dlqty TO wa_gtot6-dlqty.
  ADD i_output6-dlval TO wa_stot61-dlval.
  ADD i_output6-dlval TO wa_stot62-dlval.
  ADD i_output6-dlval TO wa_stot63-dlval.
  ADD i_output6-dlval TO wa_gtot6-dlval.
  ADD i_output6-unqty TO wa_stot61-unqty.
  ADD i_output6-unqty TO wa_stot62-unqty.
  ADD i_output6-unqty TO wa_stot63-unqty.
  ADD i_output6-unqty TO wa_gtot6-unqty.
  ADD i_output6-unval TO wa_stot61-unval.
  ADD i_output6-unval TO wa_stot62-unval.
  ADD i_output6-unval TO wa_stot63-unval.
  ADD i_output6-unval TO wa_gtot6-unval.
  ADD i_output6-lead1q TO wa_stot61-lead1q.
  ADD i_output6-lead1q TO wa_stot62-lead1q.
  ADD i_output6-lead1q TO wa_stot63-lead1q.
  ADD i_output6-lead1q TO wa_gtot6-lead1q.
  ADD i_output6-lead1 TO wa_stot61-lead1.
  ADD i_output6-lead1 TO wa_stot62-lead1.
  ADD i_output6-lead1 TO wa_stot63-lead1.
  ADD i_output6-lead1 TO wa_gtot6-lead1.
  ADD i_output6-lead2 TO wa_stot61-lead2q.
  ADD i_output6-lead2 TO wa_stot62-lead2q.
  ADD i_output6-lead2 TO wa_stot63-lead2q.
  ADD i_output6-lead2 TO wa_gtot6-lead2q.
  ADD i_output6-lead2 TO wa_stot61-lead2.
  ADD i_output6-lead2 TO wa_stot62-lead2.
  ADD i_output6-lead2 TO wa_stot63-lead2.
  ADD i_output6-lead2 TO wa_gtot6-lead2.
  ADD i_output6-lead3q TO wa_stot61-lead3q.
  ADD i_output6-lead3q TO wa_stot62-lead3q.
  ADD i_output6-lead3q TO wa_stot63-lead3q.
  ADD i_output6-lead3q TO wa_gtot6-lead3q.
  ADD i_output6-lead3 TO wa_stot61-lead3.
  ADD i_output6-lead3 TO wa_stot62-lead3.
  ADD i_output6-lead3 TO wa_stot63-lead3.
  ADD i_output6-lead3 TO wa_gtot6-lead3.
  ADD i_output6-lead4q TO wa_stot61-lead4q.
  ADD i_output6-lead4q TO wa_stot62-lead4q.
  ADD i_output6-lead4q TO wa_stot63-lead4q.
  ADD i_output6-lead4q TO wa_gtot6-lead4q.
  ADD i_output6-lead4 TO wa_stot61-lead4.
  ADD i_output6-lead4 TO wa_stot62-lead4.
  ADD i_output6-lead4 TO wa_stot63-lead4.
  ADD i_output6-lead4 TO wa_gtot6-lead4.
  ADD i_output6-lead5q TO wa_stot61-lead5q.
  ADD i_output6-lead5q TO wa_stot62-lead5q.
  ADD i_output6-lead5q TO wa_stot63-lead5q.
  ADD i_output6-lead5q TO wa_gtot6-lead5q.
  ADD i_output6-lead5 TO wa_stot61-lead5.
  ADD i_output6-lead5 TO wa_stot62-lead5.
  ADD i_output6-lead5 TO wa_stot63-lead5.
  ADD i_output6-lead5 TO wa_gtot6-lead5.
  ADD i_output6-lead6q TO wa_stot61-lead6q.
  ADD i_output6-lead6q TO wa_stot62-lead6q.
  ADD i_output6-lead6q TO wa_stot63-lead6q.
  ADD i_output6-lead6q TO wa_gtot6-lead6q.
  ADD i_output6-lead6 TO wa_stot61-lead6.
  ADD i_output6-lead6 TO wa_stot62-lead6.
  ADD i_output6-lead6 TO wa_stot63-lead6.
  ADD i_output6-lead6 TO wa_gtot6-lead6.
  ADD i_output6-stkoutq TO wa_stot61-stkoutq.
  ADD i_output6-stkoutq TO wa_stot62-stkoutq.
  ADD i_output6-stkoutq TO wa_stot63-stkoutq.
  ADD i_output6-stkoutq TO wa_gtot6-stkoutq.
  ADD i_output6-stkout TO wa_stot61-stkout.
  ADD i_output6-stkout TO wa_stot62-stkout.
  ADD i_output6-stkout TO wa_stot63-stkout.
  ADD i_output6-stkout TO wa_gtot6-stkout.
  ADD i_output6-cltopq TO wa_stot61-cltopq.
  ADD i_output6-cltopq TO wa_stot62-cltopq.
  ADD i_output6-cltopq TO wa_stot63-cltopq.
  ADD i_output6-cltopq TO wa_gtot6-cltopq.
  ADD i_output6-cltop TO wa_stot61-cltop.
  ADD i_output6-cltop TO wa_stot62-cltop.
  ADD i_output6-cltop TO wa_stot63-cltop.
  ADD i_output6-cltop TO wa_gtot6-cltop.
  ADD i_output6-salahq TO wa_stot61-salahq.
  ADD i_output6-salahq TO wa_stot62-salahq.
  ADD i_output6-salahq TO wa_stot63-salahq.
  ADD i_output6-salahq TO wa_gtot6-salahq.
  ADD i_output6-salah TO wa_stot61-salah.
  ADD i_output6-salah TO wa_stot62-salah.
  ADD i_output6-salah TO wa_stot63-salah.
  ADD i_output6-salah TO wa_gtot6-salah.
  ADD i_output6-otherq TO wa_stot61-otherq.
  ADD i_output6-otherq TO wa_stot62-otherq.
  ADD i_output6-otherq TO wa_stot63-otherq.
  ADD i_output6-otherq TO wa_gtot6-otherq.
  ADD i_output6-other TO wa_stot61-other.
  ADD i_output6-other TO wa_stot62-other.
  ADD i_output6-other TO wa_stot63-other.
  ADD i_output6-other TO wa_gtot6-other.
  ADD i_output6-rejectq TO wa_stot61-rejectq.
  ADD i_output6-rejectq TO wa_stot62-rejectq.
  ADD i_output6-rejectq TO wa_stot63-rejectq.
  ADD i_output6-rejectq TO wa_gtot6-rejectq.
  ADD i_output6-reject TO wa_stot61-reject.
  ADD i_output6-reject TO wa_stot62-reject.
  ADD i_output6-reject TO wa_stot63-reject.
  ADD i_output6-reject TO wa_gtot6-reject.
  ADD i_output6-pooutq TO wa_stot61-pooutq.
  ADD i_output6-pooutq TO wa_stot62-pooutq.
  ADD i_output6-pooutq TO wa_stot63-pooutq.
  ADD i_output6-pooutq TO wa_gtot6-pooutq.
  ADD i_output6-poout TO wa_stot61-poout.
  ADD i_output6-poout TO wa_stot62-poout.
  ADD i_output6-poout TO wa_stot63-poout.
  ADD i_output6-poout TO wa_gtot6-poout.
  ADD i_output6-btqty TO wa_stot61-btqty.
  ADD i_output6-btqty TO wa_stot62-btqty.
  ADD i_output6-btqty TO wa_stot63-btqty.
  ADD i_output6-btqty TO wa_gtot6-btqty.
  ADD i_output6-btamt TO wa_stot61-btamt.
  ADD i_output6-btamt TO wa_stot62-btamt.
  ADD i_output6-btamt TO wa_stot63-btamt.
  ADD i_output6-btamt TO wa_gtot6-btamt.

  PERFORM f_hitung_total USING '6'.

ENDFORM.                    " hitung_total6

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE6                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page6.

  DATA : l_line1(70),
         l_line2(60),
         l_princ(80),
         l_kvgr4(80),
         l_fdate(10),
         l_tdate(10).

  WRITE s_erdat-low TO l_fdate.
  WRITE s_erdat-high TO l_tdate.
*--- Title
  CONCATENATE sy-title 'By Principal, Key Account Grp' '(06)'
              INTO l_line1 SEPARATED BY space.
*--- Period
  CONCATENATE 'Period :' l_fdate 'to' l_tdate
              INTO l_line2 SEPARATED BY space.
*--- Material Group
  CONCATENATE 'Principal       :' i_output6-princ
              INTO l_princ SEPARATED BY space.
*--- Customer Group
  IF p_total6 IS INITIAL.
    CONCATENATE 'Key Account Grp :' i_output6-kvgr4 i_output6-bezei
                INTO l_kvgr4 SEPARATED BY space.
  ELSE.
    l_kvgr4 = 'SUMMARY'.
  ENDIF.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING l_line1.
  PERFORM f_hdr_line2 USING l_princ l_line2.
  PERFORM f_hdr_line3 USING l_kvgr4 va_text.
  PERFORM f_hdr_uline.

ENDFORM.                    "f_top_of_page6

*&---------------------------------------------------------------------*
*&      Form  proses_data7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proses_data7.

  SORT i_detquot7  BY vkbur princ matkl matnr.
*  SORT i_detsales BY vgbel posnr.
  SORT i_detsales BY vgbel vgpos.
  SORT i_detdelv  BY vgbel vgpos.

  IF NOT p_stkou1 IS INITIAL.
    PERFORM f_check_stock_outs1.
  ENDIF.

  LOOP AT i_detquot7.

    CLEAR : i_detsales, i_detdelv, i_output7. ", i_detquot7-abgru.

    READ TABLE i_detsales WITH KEY
                               vgbel = i_detquot7-vbeln
*                               posnr = i_detquot7-posnr BINARY SEARCH.
                               vgpos = i_detquot7-posnr. " BINARY SEARCH.
    IF sy-subrc = 0.
      IF i_detsales-abgru IS NOT INITIAL.
        i_detquot7-abgru = i_detsales-abgru.
      ENDIF.
    ENDIF.

    READ TABLE i_detdelv WITH KEY
                              vgbel = i_detsales-vbeln
                              vgpos = i_detsales-posnr. " BINARY SEARCH.

    PERFORM append_itab7.

* Total Material Group
    AT END OF matkl.
      wa_stot73-vkbur = i_output7-vkbur.
      wa_stot73-vkburt = i_output7-vkburt.
      wa_stot73-princ = i_output7-princ.
      CONCATENATE '*    Total' i_output7-matkl
                  INTO wa_stot73-maktx SEPARATED BY space.
      wa_stot73-info = 'C30'.
      wa_stot73-curr = 'IDR'.
      wa_stot73-index = '20'.
      wa_stot73-deci = '0'.
      wa_stot73-prinx = i_output7-princ.
      wa_stot73-matkx = i_output7-matkl.
      APPEND wa_stot73 TO i_output7.

      wa_stot73-maktx = '           Percentage(%)'.
      IF wa_stot73-kzwi1 NE wa_stot73-btamt.
        IF p_val = 'X'.
          wa_stot73-dlval% = wa_stot73-dlval / ( wa_stot73-kzwi1 -
                             wa_stot73-btamt ) * 100.
          wa_stot73-unprc = wa_stot73-unval / ( wa_stot73-kzwi1 -
                            wa_stot73-btamt ) * 100.
          wa_stot73-lead1% = wa_stot73-lead1 / ( wa_stot73-kzwi1 -
                             wa_stot73-btamt ) * 100.
          wa_stot73-lead2% = wa_stot73-lead2 / ( wa_stot73-kzwi1 -
                             wa_stot73-btamt ) * 100.
          wa_stot73-lead3% = wa_stot73-lead3 / ( wa_stot73-kzwi1 -
                             wa_stot73-btamt ) * 100.
          wa_stot73-lead4% = wa_stot73-lead4 / ( wa_stot73-kzwi1 -
                             wa_stot73-btamt ) * 100.
          wa_stot73-lead5% = wa_stot73-lead5 / ( wa_stot73-kzwi1 -
                             wa_stot73-btamt ) * 100.
          wa_stot73-lead6% = wa_stot73-lead6 / ( wa_stot73-kzwi1 -
                             wa_stot73-btamt ) * 100.
          wa_stot73-poout% = wa_stot73-poout / ( wa_stot73-kzwi1 -
                             wa_stot73-btamt ) * 100.
          wa_stot73-btprc% = wa_stot73-btamt / wa_stot73-kzwi1 * 100.
          wa_stot73-stkout% = wa_stot73-stkout / ( wa_stot73-kzwi1 -
                             wa_stot73-btamt ) * 100.
          wa_stot73-cltop% = wa_stot73-cltop / ( wa_stot73-kzwi1 -
                            wa_stot73-btamt ) * 100.
          wa_stot73-salah% = wa_stot73-salah / ( wa_stot73-kzwi1 -
                            wa_stot73-btamt ) * 100.
          wa_stot73-other% = wa_stot73-other / ( wa_stot73-kzwi1 -
                            wa_stot73-btamt ) * 100.
          wa_stot73-reject% = wa_stot73-reject / ( wa_stot73-kzwi1 -
                             wa_stot73-btamt ) * 100.

          PERFORM f_hitung_stot3 USING wa_stot73-kzwi1
                                       wa_stot73-btamt
                                       wa_stot73-kwmeng
                                       wa_stot73-btqty
                                       p_val
                                       '7'.

        ELSE.
          wa_stot73-dlval% = wa_stot73-dlqty / ( wa_stot73-kwmeng -
                             wa_stot73-btqty ) * 100.
          wa_stot73-unprc = wa_stot73-unqty / ( wa_stot73-kwmeng -
                            wa_stot73-btqty ) * 100.
          wa_stot73-lead1% = wa_stot73-lead1q / ( wa_stot73-kwmeng -
                             wa_stot73-btqty ) * 100.
          wa_stot73-lead2% = wa_stot73-lead2q / ( wa_stot73-kwmeng -
                             wa_stot73-btqty ) * 100.
          wa_stot73-lead3% = wa_stot73-lead3q / ( wa_stot73-kwmeng -
                             wa_stot73-btqty ) * 100.
          wa_stot73-lead4% = wa_stot73-lead4q / ( wa_stot73-kwmeng -
                             wa_stot73-btqty ) * 100.
          wa_stot73-lead5% = wa_stot73-lead5q / ( wa_stot73-kwmeng -
                             wa_stot73-btqty ) * 100.
          wa_stot73-lead6% = wa_stot73-lead6q / ( wa_stot73-kwmeng -
                             wa_stot73-btqty ) * 100.
          wa_stot73-poout% = wa_stot73-pooutq / ( wa_stot73-kwmeng -
                             wa_stot73-btqty ) * 100.
          wa_stot73-btprc% = wa_stot73-btqty / wa_stot73-kwmeng * 100.
          wa_stot73-stkout% = wa_stot73-stkoutq / ( wa_stot73-kwmeng -
                             wa_stot73-btqty ) * 100.
          wa_stot73-cltop% = wa_stot73-cltopq / ( wa_stot73-kwmeng -
                            wa_stot73-btqty ) * 100.
          wa_stot73-salah% = wa_stot73-salahq / ( wa_stot73-kwmeng -
                            wa_stot73-btqty ) * 100.
          wa_stot73-other% = wa_stot73-otherq / ( wa_stot73-kwmeng -
                            wa_stot73-btqty ) * 100.
          wa_stot73-reject% = wa_stot73-rejectq / ( wa_stot73-kwmeng -
                             wa_stot73-btqty ) * 100.

          PERFORM f_hitung_stot3 USING wa_stot73-kzwi1
                                       wa_stot73-btamt
                                       wa_stot73-kwmeng
                                       wa_stot73-btqty
                                       p_val
                                       '7'.

        ENDIF.
      ENDIF.

      wa_stot73-dlval = wa_stot73-dlval%.
      IF p_val = 'X'.
        wa_stot73-unval = wa_stot73-unprc.
        wa_stot73-lead1 = wa_stot73-lead1%.
        wa_stot73-lead2 = wa_stot73-lead2%.
        wa_stot73-lead3 = wa_stot73-lead3%.
        wa_stot73-lead4 = wa_stot73-lead4%.
        wa_stot73-lead5 = wa_stot73-lead5%.
        wa_stot73-lead6 = wa_stot73-lead6%.
        wa_stot73-poout = wa_stot73-poout%.
        wa_stot73-btamt = wa_stot73-btprc%.
        wa_stot73-stkout = wa_stot73-stkout%.
        wa_stot73-cltop = wa_stot73-cltop%.
        wa_stot73-salah = wa_stot73-salah%.
        wa_stot73-other = wa_stot73-other%.
        wa_stot73-reject = wa_stot73-reject%.

        PERFORM f_move_stot3 USING p_val '7'.

      ELSE.
        wa_stot73-unqty = wa_stot73-unprc.
        wa_stot73-lead1q = wa_stot73-lead1%.
        wa_stot73-lead2q = wa_stot73-lead2%.
        wa_stot73-lead3q = wa_stot73-lead3%.
        wa_stot73-lead4q = wa_stot73-lead4%.
        wa_stot73-lead5q = wa_stot73-lead5%.
        wa_stot73-lead6q = wa_stot73-lead6%.
        wa_stot73-pooutq = wa_stot73-poout%.
        wa_stot73-btqty = wa_stot73-btprc%.
        wa_stot73-stkoutq = wa_stot73-stkout%.
        wa_stot73-cltopq = wa_stot73-cltop%.
        wa_stot73-salahq = wa_stot73-salah%.
        wa_stot73-otherq = wa_stot73-other%.
        wa_stot73-rejectq = wa_stot73-reject%.

        PERFORM f_move_stot3 USING p_val '7'.

      ENDIF.
      wa_stot73-deci = '2'.
      CLEAR: wa_stot73-curr, wa_stot73-kwmeng,
             wa_stot73-kzwi1, wa_stot73-dlqty.
      APPEND wa_stot73 TO i_output7.
      CLEAR: wa_stot73.
    ENDAT.

* Total Principal
    AT END OF princ.
      wa_stot72-vkbur = i_output7-vkbur.
      wa_stot72-vkburt = i_output7-vkburt.
      wa_stot72-princ = i_output7-princ.
      CONCATENATE '**   Total' i_output7-princ
                  INTO wa_stot72-maktx SEPARATED BY space.
      wa_stot72-info = 'C30'.
      wa_stot72-curr = 'IDR'.
      wa_stot72-index = '30'.
      wa_stot72-deci = '0'.
      wa_stot72-prinx = i_output7-princ.
      wa_stot72-matkx = i_output7-matkl.
      APPEND wa_stot72 TO i_output7.

      wa_stot72-maktx = '           Percentage(%)'.
      IF wa_stot72-kzwi1 NE wa_stot72-btamt.
        IF p_val = 'X'.
          wa_stot72-dlval% = wa_stot72-dlval / ( wa_stot72-kzwi1 -
                             wa_stot72-btamt ) * 100.
          wa_stot72-unprc = wa_stot72-unval / ( wa_stot72-kzwi1 -
                            wa_stot72-btamt ) * 100.
          wa_stot72-lead1% = wa_stot72-lead1 / ( wa_stot72-kzwi1 -
                             wa_stot72-btamt ) * 100.
          wa_stot72-lead2% = wa_stot72-lead2 / ( wa_stot72-kzwi1 -
                             wa_stot72-btamt ) * 100.
          wa_stot72-lead3% = wa_stot72-lead3 / ( wa_stot72-kzwi1 -
                             wa_stot72-btamt ) * 100.
          wa_stot72-lead4% = wa_stot72-lead4 / ( wa_stot72-kzwi1 -
                             wa_stot72-btamt ) * 100.
          wa_stot72-lead5% = wa_stot72-lead5 / ( wa_stot72-kzwi1 -
                             wa_stot72-btamt ) * 100.
          wa_stot72-lead6% = wa_stot72-lead6 / ( wa_stot72-kzwi1 -
                             wa_stot72-btamt ) * 100.
          wa_stot72-poout% = wa_stot72-poout / ( wa_stot72-kzwi1 -
                             wa_stot72-btamt ) * 100.
          wa_stot72-btprc% = wa_stot72-btamt / wa_stot72-kzwi1 * 100.
          wa_stot72-stkout% = wa_stot72-stkout / ( wa_stot72-kzwi1 -
                             wa_stot72-btamt ) * 100.
          wa_stot72-cltop% = wa_stot72-cltop / ( wa_stot72-kzwi1 -
                            wa_stot72-btamt ) * 100.
          wa_stot72-salah% = wa_stot72-salah / ( wa_stot72-kzwi1 -
                            wa_stot72-btamt ) * 100.
          wa_stot72-other% = wa_stot72-other / ( wa_stot72-kzwi1 -
                            wa_stot72-btamt ) * 100.
          wa_stot72-reject% = wa_stot72-reject / ( wa_stot72-kzwi1 -
                             wa_stot72-btamt ) * 100.

          PERFORM f_hitung_stot2 USING wa_stot72-kzwi1
                                       wa_stot72-btamt
                                       wa_stot72-kwmeng
                                       wa_stot72-btqty
                                       p_val
                                       '7'.

        ELSE.
          wa_stot72-dlval% = wa_stot72-dlqty / ( wa_stot72-kwmeng -
                             wa_stot72-btqty ) * 100.
          wa_stot72-unprc = wa_stot72-unqty / ( wa_stot72-kwmeng -
                            wa_stot72-btqty ) * 100.
          wa_stot72-lead1% = wa_stot72-lead1q / ( wa_stot72-kwmeng -
                             wa_stot72-btqty ) * 100.
          wa_stot72-lead2% = wa_stot72-lead2q / ( wa_stot72-kwmeng -
                             wa_stot72-btqty ) * 100.
          wa_stot72-lead3% = wa_stot72-lead3q / ( wa_stot72-kwmeng -
                             wa_stot72-btqty ) * 100.
          wa_stot72-lead4% = wa_stot72-lead4q / ( wa_stot72-kwmeng -
                             wa_stot72-btqty ) * 100.
          wa_stot72-lead5% = wa_stot72-lead5q / ( wa_stot72-kwmeng -
                             wa_stot72-btqty ) * 100.
          wa_stot72-lead6% = wa_stot72-lead6q / ( wa_stot72-kwmeng -
                             wa_stot72-btqty ) * 100.
          wa_stot72-poout% = wa_stot72-pooutq / ( wa_stot72-kwmeng -
                             wa_stot72-btqty ) * 100.
          wa_stot72-btprc% = wa_stot72-btqty / wa_stot72-kwmeng * 100.
          wa_stot72-stkout% = wa_stot72-stkoutq / ( wa_stot72-kwmeng -
                             wa_stot72-btqty ) * 100.
          wa_stot72-cltop% = wa_stot72-cltopq / ( wa_stot72-kwmeng -
                            wa_stot72-btqty ) * 100.
          wa_stot72-salah% = wa_stot72-salahq / ( wa_stot72-kwmeng -
                            wa_stot72-btqty ) * 100.
          wa_stot72-other% = wa_stot72-otherq / ( wa_stot72-kwmeng -
                            wa_stot72-btqty ) * 100.
          wa_stot72-reject% = wa_stot72-rejectq / ( wa_stot72-kwmeng -
                             wa_stot72-btqty ) * 100.

          PERFORM f_hitung_stot2 USING wa_stot72-kzwi1
                                       wa_stot72-btamt
                                       wa_stot72-kwmeng
                                       wa_stot72-btqty
                                       p_val
                                       '7'.

        ENDIF.
      ENDIF.

      wa_stot72-dlval = wa_stot72-dlval%.
      IF p_val = 'X'.
        wa_stot72-unval = wa_stot72-unprc.
        wa_stot72-lead1 = wa_stot72-lead1%.
        wa_stot72-lead2 = wa_stot72-lead2%.
        wa_stot72-lead3 = wa_stot72-lead3%.
        wa_stot72-lead4 = wa_stot72-lead4%.
        wa_stot72-lead5 = wa_stot72-lead5%.
        wa_stot72-lead6 = wa_stot72-lead6%.
        wa_stot72-poout = wa_stot72-poout%.
        wa_stot72-btamt = wa_stot72-btprc%.
        wa_stot72-stkout = wa_stot72-stkout%.
        wa_stot72-cltop = wa_stot72-cltop%.
        wa_stot72-salah = wa_stot72-salah%.
        wa_stot72-other = wa_stot72-other%.
        wa_stot72-reject = wa_stot72-reject%.

        PERFORM f_move_stot2 USING p_val '7'.

      ELSE.
        wa_stot72-unqty = wa_stot72-unprc.
        wa_stot72-lead1q = wa_stot72-lead1%.
        wa_stot72-lead2q = wa_stot72-lead2%.
        wa_stot72-lead3q = wa_stot72-lead3%.
        wa_stot72-lead4q = wa_stot72-lead4%.
        wa_stot72-lead5q = wa_stot72-lead5%.
        wa_stot72-lead6q = wa_stot72-lead6%.
        wa_stot72-pooutq = wa_stot72-poout%.
        wa_stot72-btqty = wa_stot72-btprc%.
        wa_stot72-stkoutq = wa_stot72-stkout%.
        wa_stot72-cltopq = wa_stot72-cltop%.
        wa_stot72-salahq = wa_stot72-salah%.
        wa_stot72-otherq = wa_stot72-other%.
        wa_stot72-rejectq = wa_stot72-reject%.

        PERFORM f_move_stot2 USING p_val '7'.

      ENDIF.
      wa_stot72-deci = '2'.
      CLEAR: wa_stot72-curr, wa_stot72-kwmeng,
             wa_stot72-kzwi1, wa_stot72-dlqty.
      APPEND wa_stot72 TO i_output7.
      CLEAR: wa_stot72, wa_stot73.
    ENDAT.

* Total Sales Office
    AT END OF vkbur.
      wa_stot71-vkbur = i_output7-vkbur.
      wa_stot71-vkburt = i_output7-vkburt.
      wa_stot71-princ = i_output7-princ.
      CONCATENATE '***  Total' i_output7-vkbur
                  INTO wa_stot71-maktx SEPARATED BY space.
      wa_stot71-info = 'C70'.
      wa_stot71-curr = 'IDR'.
      wa_stot71-index = '50'.
      wa_stot71-deci = '0'.
      wa_stot71-prinx = i_output7-princ.
      wa_stot71-matkx = i_output7-matkl.
      APPEND wa_stot71 TO i_output7.

      wa_stot71-maktx = '           Percentage(%)'.
      IF wa_stot71-kzwi1 NE wa_stot71-btamt.
        IF p_val = 'X'.
          wa_stot71-dlval% = wa_stot71-dlval / ( wa_stot71-kzwi1 -
                             wa_stot71-btamt ) * 100.
          wa_stot71-unprc = wa_stot71-unval / ( wa_stot71-kzwi1 -
                             wa_stot71-btamt ) * 100.
          wa_stot71-lead1% = wa_stot71-lead1 / ( wa_stot71-kzwi1 -
                             wa_stot71-btamt ) * 100.
          wa_stot71-lead2% = wa_stot71-lead2 / ( wa_stot71-kzwi1 -
                             wa_stot71-btamt ) * 100.
          wa_stot71-lead3% = wa_stot71-lead3 / ( wa_stot71-kzwi1 -
                             wa_stot71-btamt ) * 100.
          wa_stot71-lead4% = wa_stot71-lead4 / ( wa_stot71-kzwi1 -
                             wa_stot71-btamt ) * 100.
          wa_stot71-lead5% = wa_stot71-lead5 / ( wa_stot71-kzwi1 -
                             wa_stot71-btamt ) * 100.
          wa_stot71-lead6% = wa_stot71-lead6 / ( wa_stot71-kzwi1 -
                             wa_stot71-btamt ) * 100.
          wa_stot71-poout% = wa_stot71-poout / ( wa_stot71-kzwi1 -
                             wa_stot71-btamt ) * 100.
          wa_stot71-btprc% = wa_stot71-btamt / wa_stot71-kzwi1 * 100.
          wa_stot71-stkout% = wa_stot71-stkout / ( wa_stot71-kzwi1 -
                             wa_stot71-btamt ) * 100.
          wa_stot71-cltop% = wa_stot71-cltop / ( wa_stot71-kzwi1 -
                            wa_stot71-btamt ) * 100.
          wa_stot71-salah% = wa_stot71-salah / ( wa_stot71-kzwi1 -
                            wa_stot71-btamt ) * 100.
          wa_stot71-other% = wa_stot71-other / ( wa_stot71-kzwi1 -
                            wa_stot71-btamt ) * 100.
          wa_stot71-reject% = wa_stot71-reject / ( wa_stot71-kzwi1 -
                             wa_stot71-btamt ) * 100.

          PERFORM f_hitung_stot1 USING wa_stot71-kzwi1
                                       wa_stot71-btamt
                                       wa_stot71-kwmeng
                                       wa_stot71-btqty
                                       p_val
                                       '7'.

        ELSE.
          wa_stot71-dlval% = wa_stot71-dlqty / ( wa_stot71-kwmeng -
                             wa_stot71-btqty ) * 100.
          wa_stot71-unprc = wa_stot71-unqty / ( wa_stot71-kwmeng -
                             wa_stot71-btqty ) * 100.
          wa_stot71-lead1% = wa_stot71-lead1q / ( wa_stot71-kwmeng -
                             wa_stot71-btqty ) * 100.
          wa_stot71-lead2% = wa_stot71-lead2q / ( wa_stot71-kwmeng -
                             wa_stot71-btqty ) * 100.
          wa_stot71-lead3% = wa_stot71-lead3q / ( wa_stot71-kwmeng -
                             wa_stot71-btqty ) * 100.
          wa_stot71-lead4% = wa_stot71-lead4q / ( wa_stot71-kwmeng -
                             wa_stot71-btqty ) * 100.
          wa_stot71-lead5% = wa_stot71-lead5q / ( wa_stot71-kwmeng -
                             wa_stot71-btqty ) * 100.
          wa_stot71-lead6% = wa_stot71-lead6q / ( wa_stot71-kwmeng -
                             wa_stot71-btqty ) * 100.
          wa_stot71-poout% = wa_stot71-pooutq / ( wa_stot71-kwmeng -
                             wa_stot71-btqty ) * 100.
          wa_stot71-btprc% = wa_stot71-btqty / wa_stot71-kwmeng * 100.
          wa_stot71-stkout% = wa_stot71-stkoutq / ( wa_stot71-kwmeng -
                             wa_stot71-btqty ) * 100.
          wa_stot71-cltop% = wa_stot71-cltopq / ( wa_stot71-kwmeng -
                            wa_stot71-btqty ) * 100.
          wa_stot71-salah% = wa_stot71-salahq / ( wa_stot71-kwmeng -
                            wa_stot71-btqty ) * 100.
          wa_stot71-other% = wa_stot71-otherq / ( wa_stot71-kwmeng -
                            wa_stot71-btqty ) * 100.
          wa_stot71-reject% = wa_stot71-rejectq / ( wa_stot71-kwmeng -
                             wa_stot71-btqty ) * 100.

          PERFORM f_hitung_stot1 USING wa_stot71-kzwi1
                                       wa_stot71-btamt
                                       wa_stot71-kwmeng
                                       wa_stot71-btqty
                                       p_val
                                       '7'.

        ENDIF.
      ENDIF.

      wa_stot71-dlval = wa_stot71-dlval%.
      IF p_val = 'X'.
        wa_stot71-unval = wa_stot71-unprc.
        wa_stot71-lead1 = wa_stot71-lead1%.
        wa_stot71-lead2 = wa_stot71-lead2%.
        wa_stot71-lead3 = wa_stot71-lead3%.
        wa_stot71-lead4 = wa_stot71-lead4%.
        wa_stot71-lead5 = wa_stot71-lead5%.
        wa_stot71-lead6 = wa_stot71-lead6%.
        wa_stot71-poout = wa_stot71-poout%.
        wa_stot71-btamt = wa_stot71-btprc%.
        wa_stot71-stkout = wa_stot71-stkout%.
        wa_stot71-cltop = wa_stot71-cltop%.
        wa_stot71-salah = wa_stot71-salah%.
        wa_stot71-other = wa_stot71-other%.
        wa_stot71-reject = wa_stot71-reject%.

        PERFORM f_move_stot1 USING p_val '7'.

      ELSE.
        wa_stot71-unqty = wa_stot71-unprc.
        wa_stot71-lead1q = wa_stot71-lead1%.
        wa_stot71-lead2q = wa_stot71-lead2%.
        wa_stot71-lead3q = wa_stot71-lead3%.
        wa_stot71-lead4q = wa_stot71-lead4%.
        wa_stot71-lead5q = wa_stot71-lead5%.
        wa_stot71-lead6q = wa_stot71-lead6%.
        wa_stot71-pooutq = wa_stot71-poout%.
        wa_stot71-btqty = wa_stot71-btprc%.
        wa_stot71-stkoutq = wa_stot71-stkout%.
        wa_stot71-cltopq = wa_stot71-cltop%.
        wa_stot71-salahq = wa_stot71-salah%.
        wa_stot71-otherq = wa_stot71-other%.
        wa_stot71-rejectq = wa_stot71-reject%.

        PERFORM f_move_stot1 USING p_val '7'.

      ENDIF.
      wa_stot71-deci = '2'.
      CLEAR: wa_stot71-curr, wa_stot71-kwmeng,
             wa_stot71-kzwi1, wa_stot71-dlqty.
      APPEND wa_stot71 TO i_output7.
      CLEAR: wa_stot71, wa_stot72, wa_stot73.
    ENDAT.

  ENDLOOP.

* Total Grand
  wa_gtot7-vkbur = i_output7-vkbur.
  wa_gtot7-vkburt = i_output7-vkburt.
  wa_gtot7-princ = i_output7-princ.
  wa_gtot7-maktx = '**** Grand Total'.
  wa_gtot7-info = 'C71'.
  wa_gtot7-curr = 'IDR'.
  wa_gtot7-index = '60'.
  wa_gtot7-deci = '0'.
  wa_gtot7-prinx = i_output7-princ.
  wa_gtot7-matkx = i_output7-matkl.
  APPEND wa_gtot7 TO i_output7.

  wa_gtot7-maktx = '           Percentage(%)'.
  IF wa_gtot7-kzwi1 NE wa_gtot7-btamt.
    IF p_val = 'X'.
      wa_gtot7-dlval% = wa_gtot7-dlval / ( wa_gtot7-kzwi1 -
                             wa_gtot7-btamt ) * 100.
      wa_gtot7-unprc = wa_gtot7-unval / ( wa_gtot7-kzwi1 -
                             wa_gtot7-btamt ) * 100.
      wa_gtot7-lead1% = wa_gtot7-lead1 / ( wa_gtot7-kzwi1 -
                             wa_gtot7-btamt ) * 100.
      wa_gtot7-lead2% = wa_gtot7-lead2 / ( wa_gtot7-kzwi1 -
                             wa_gtot7-btamt ) * 100.
      wa_gtot7-lead3% = wa_gtot7-lead3 / ( wa_gtot7-kzwi1 -
                             wa_gtot7-btamt ) * 100..
      wa_gtot7-lead4% = wa_gtot7-lead4 / ( wa_gtot7-kzwi1 -
                             wa_gtot7-btamt ) * 100.
      wa_gtot7-lead5% = wa_gtot7-lead5 / ( wa_gtot7-kzwi1 -
                             wa_gtot7-btamt ) * 100.
      wa_gtot7-lead6% = wa_gtot7-lead6 / ( wa_gtot7-kzwi1 -
                             wa_gtot7-btamt ) * 100.
      wa_gtot7-poout% = wa_gtot7-poout / ( wa_gtot7-kzwi1 -
                             wa_gtot7-btamt ) * 100.
      wa_gtot7-btprc% = wa_gtot7-btamt / wa_gtot7-kzwi1 * 100.
      wa_gtot7-stkout% = wa_gtot7-stkout / ( wa_gtot7-kzwi1 -
                             wa_gtot7-btamt ) * 100.
      wa_gtot7-cltop% = wa_gtot7-cltop / ( wa_gtot7-kzwi1 -
                        wa_gtot7-btamt ) * 100.
      wa_gtot7-salah% = wa_gtot7-salah / ( wa_gtot7-kzwi1 -
                        wa_gtot7-btamt ) * 100.
      wa_gtot7-other% = wa_gtot7-other / ( wa_gtot7-kzwi1 -
                        wa_gtot7-btamt ) * 100.
      wa_gtot7-reject% = wa_gtot7-reject / ( wa_gtot7-kzwi1 -
                             wa_gtot7-btamt ) * 100.

      PERFORM f_hitung_gtot USING wa_gtot7-kzwi1
                                   wa_gtot7-btamt
                                   wa_gtot7-kwmeng
                                   wa_gtot7-btqty
                                   p_val
                                   '7'.

    ELSE.
      wa_gtot7-dlval% = wa_gtot7-dlqty / ( wa_gtot7-kwmeng -
                             wa_gtot7-btqty ) * 100.
      wa_gtot7-unprc = wa_gtot7-unqty / ( wa_gtot7-kwmeng -
                             wa_gtot7-btqty ) * 100.
      wa_gtot7-lead1% = wa_gtot7-lead1q / ( wa_gtot7-kwmeng -
                             wa_gtot7-btqty ) * 100.
      wa_gtot7-lead2% = wa_gtot7-lead2q / ( wa_gtot7-kwmeng -
                             wa_gtot7-btqty ) * 100.
      wa_gtot7-lead3% = wa_gtot7-lead3q / ( wa_gtot7-kwmeng -
                             wa_gtot7-btqty ) * 100..
      wa_gtot7-lead4% = wa_gtot7-lead4q / ( wa_gtot7-kwmeng -
                             wa_gtot7-btqty ) * 100.
      wa_gtot7-lead5% = wa_gtot7-lead5q / ( wa_gtot7-kwmeng -
                             wa_gtot7-btqty ) * 100.
      wa_gtot7-lead6% = wa_gtot7-lead6q / ( wa_gtot7-kwmeng -
                             wa_gtot7-btqty ) * 100.
      wa_gtot7-poout% = wa_gtot7-pooutq / ( wa_gtot7-kwmeng -
                             wa_gtot7-btqty ) * 100.
      wa_gtot7-btprc% = wa_gtot7-btqty / wa_gtot7-kwmeng * 100.
      wa_gtot7-stkout% = wa_gtot7-stkoutq / ( wa_gtot7-kwmeng -
                             wa_gtot7-btqty ) * 100.
      wa_gtot7-cltop% = wa_gtot7-cltopq / ( wa_gtot7-kwmeng -
                        wa_gtot7-btqty ) * 100.
      wa_gtot7-salah% = wa_gtot7-salahq / ( wa_gtot7-kwmeng -
                        wa_gtot7-btqty ) * 100.
      wa_gtot7-other% = wa_gtot7-otherq / ( wa_gtot7-kwmeng -
                        wa_gtot7-btqty ) * 100.
      wa_gtot7-reject% = wa_gtot7-rejectq / ( wa_gtot7-kwmeng -
                             wa_gtot7-btqty ) * 100.

      PERFORM f_hitung_gtot USING wa_gtot7-kzwi1
                                   wa_gtot7-btamt
                                   wa_gtot7-kwmeng
                                   wa_gtot7-btqty
                                   p_val
                                   '7'.

    ENDIF.
  ENDIF.

  wa_gtot7-dlval = wa_gtot7-dlval%.
  wa_gtot7-lead1 = wa_gtot7-lead1%.
  IF p_val = 'X'.
    wa_gtot7-unval = wa_gtot7-unprc.
    wa_gtot7-lead2 = wa_gtot7-lead2%.
    wa_gtot7-lead3 = wa_gtot7-lead3%.
    wa_gtot7-lead4 = wa_gtot7-lead4%.
    wa_gtot7-lead5 = wa_gtot7-lead5%.
    wa_gtot7-lead6 = wa_gtot7-lead6%.
    wa_gtot7-poout = wa_gtot7-poout%.
    wa_gtot7-btamt = wa_gtot7-btprc%.
    wa_gtot7-stkout = wa_gtot7-stkout%.
    wa_gtot7-cltop = wa_gtot7-cltop%.
    wa_gtot7-salah = wa_gtot7-salah%.
    wa_gtot7-other = wa_gtot7-other%.
    wa_gtot7-reject = wa_gtot7-reject%.

    PERFORM f_move_gtot USING p_val '7'.

  ELSE.
    wa_gtot7-unqty = wa_gtot7-unprc.
    wa_gtot7-lead1q = wa_gtot7-lead1%.
    wa_gtot7-lead2q = wa_gtot7-lead2%.
    wa_gtot7-lead3q = wa_gtot7-lead3%.
    wa_gtot7-lead4q = wa_gtot7-lead4%.
    wa_gtot7-lead5q = wa_gtot7-lead5%.
    wa_gtot7-lead6q = wa_gtot7-lead6%.
    wa_gtot7-pooutq = wa_gtot7-poout%.
    wa_gtot7-btqty = wa_gtot7-btprc%.
    wa_gtot7-cltopq = wa_gtot7-cltop%.
    wa_gtot7-salahq = wa_gtot7-salah%.
    wa_gtot7-otherq = wa_gtot7-other%.
    wa_gtot7-stkoutq = wa_gtot7-stkout%.
    wa_gtot7-rejectq = wa_gtot7-reject%.

    PERFORM f_move_gtot USING p_val '7'.

  ENDIF.
  wa_gtot7-deci = '2'.
  CLEAR: wa_gtot7-curr, wa_gtot7-kwmeng,
         wa_gtot7-kzwi1, wa_gtot7-dlqty.
  APPEND wa_gtot7 TO i_output7.
  CLEAR: wa_gtot7.

ENDFORM.                    " proses_data7

*&---------------------------------------------------------------------*
*&      Form  append_itab7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_itab7.

  DATA : l_crdat  LIKE  zmm_cust_rec-crdat,
         l_leadt  TYPE  i.

  MOVE-CORRESPONDING i_detquot7 TO i_output7.

  IF NOT i_detdelv-vbeln IS INITIAL.
    i_output7-dlqty = i_detsales-kwmeng.
    i_output7-dlval = i_detsales-kzwi1.
    i_output7-unqty = i_output7-kwmeng - i_output7-dlqty.
    i_output7-unval = i_output7-kzwi1 - i_output7-dlval.

    IF i_output7-unqty LT 0.
      CLEAR: i_output7-unqty,i_output7-unval.
    ENDIF.

    SELECT SINGLE crdat FROM zmm_cust_rec
      INTO l_crdat
      WHERE vbeln = i_detdelv-vbeln.

    IF l_crdat IS INITIAL.
      i_output7-lead6q = i_output7-dlqty.
      i_output7-lead6 = i_output7-dlval.
    ELSE.
      l_leadt = l_crdat - i_detquot7-bstdk.
      IF l_leadt LE 3.
        i_output7-lead1q = i_output7-dlqty.
        i_output7-lead1 = i_output7-dlval.
      ELSEIF l_leadt = 4.
        i_output7-lead2q = i_output7-dlqty.
        i_output7-lead2 = i_output7-dlval.
      ELSEIF l_leadt GE 5.
        i_output7-lead3q = i_output7-dlqty.
        i_output7-lead3 = i_output7-dlval.
*      ELSEIF l_leadt GE 6.
*        i_output7-lead4 = i_output7-dlval.
*      ELSEIF l_leadt GE 7.
*        i_output7-lead5 = i_output7-dlval.
      ENDIF.
    ENDIF.
  ELSE.
    IF i_detsales-vbeln IS INITIAL.
      i_output7-unqty = i_output7-kwmeng.
      i_output7-unval = i_output7-kzwi1.
    ELSE.
      IF NOT i_detquot7-abgru IS INITIAL.
        i_output7-unqty = i_output7-kwmeng.
        i_output7-unval = i_output7-kzwi1.
      ELSE.
        i_output7-pooutq = i_output7-kwmeng.
        i_output7-poout = i_output7-kzwi1.
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM f_reason_for_rejection USING i_detquot7-abgru
                                       i_output7-unqty
                                       i_output7-unval
                                       '7'.

  SELECT SINGLE bezei FROM tvkbt
    INTO i_output7-vkburt
    WHERE spras = sy-langu AND
          vkbur = i_output7-vkbur.

  i_output7-reject = i_output7-unval - i_output7-stkout.

  PERFORM hitung_total7.

  i_output7-curr = 'IDR'.
  i_output7-index = '10'.
  i_output7-deci = '0'.
  i_output7-prinx = i_output7-princ.
  i_output7-matkx = i_output7-matkl.

  COLLECT i_output7.

ENDFORM.              " append_itab7

*&---------------------------------------------------------------------*
*&      Form  hitung_total7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hitung_total7.

  ADD i_output7-kwmeng TO wa_stot71-kwmeng.
  ADD i_output7-kwmeng TO wa_stot72-kwmeng.
  ADD i_output7-kwmeng TO wa_stot73-kwmeng.
  ADD i_output7-kwmeng TO wa_gtot7-kwmeng.
  ADD i_output7-kzwi1 TO wa_stot71-kzwi1.
  ADD i_output7-kzwi1 TO wa_stot72-kzwi1.
  ADD i_output7-kzwi1 TO wa_stot73-kzwi1.
  ADD i_output7-kzwi1 TO wa_gtot7-kzwi1.
  ADD i_output7-dlqty TO wa_stot71-dlqty.
  ADD i_output7-dlqty TO wa_stot72-dlqty.
  ADD i_output7-dlqty TO wa_stot73-dlqty.
  ADD i_output7-dlqty TO wa_gtot7-dlqty.
  ADD i_output7-dlval TO wa_stot71-dlval.
  ADD i_output7-dlval TO wa_stot72-dlval.
  ADD i_output7-dlval TO wa_stot73-dlval.
  ADD i_output7-dlval TO wa_gtot7-dlval.
  ADD i_output7-unqty TO wa_stot71-unqty.
  ADD i_output7-unqty TO wa_stot72-unqty.
  ADD i_output7-unqty TO wa_stot73-unqty.
  ADD i_output7-unqty TO wa_gtot7-unqty.
  ADD i_output7-unval TO wa_stot71-unval.
  ADD i_output7-unval TO wa_stot72-unval.
  ADD i_output7-unval TO wa_stot73-unval.
  ADD i_output7-unval TO wa_gtot7-unval.
  ADD i_output7-lead1q TO wa_stot71-lead1q.
  ADD i_output7-lead1q TO wa_stot72-lead1q.
  ADD i_output7-lead1q TO wa_stot73-lead1q.
  ADD i_output7-lead1q TO wa_gtot7-lead1q.
  ADD i_output7-lead1 TO wa_stot71-lead1.
  ADD i_output7-lead1 TO wa_stot72-lead1.
  ADD i_output7-lead1 TO wa_stot73-lead1.
  ADD i_output7-lead1 TO wa_gtot7-lead1.
  ADD i_output7-lead2 TO wa_stot71-lead2q.
  ADD i_output7-lead2 TO wa_stot72-lead2q.
  ADD i_output7-lead2 TO wa_stot73-lead2q.
  ADD i_output7-lead2 TO wa_gtot7-lead2q.
  ADD i_output7-lead2 TO wa_stot71-lead2.
  ADD i_output7-lead2 TO wa_stot72-lead2.
  ADD i_output7-lead2 TO wa_stot73-lead2.
  ADD i_output7-lead2 TO wa_gtot7-lead2.
  ADD i_output7-lead3q TO wa_stot71-lead3q.
  ADD i_output7-lead3q TO wa_stot72-lead3q.
  ADD i_output7-lead3q TO wa_stot73-lead3q.
  ADD i_output7-lead3q TO wa_gtot7-lead3q.
  ADD i_output7-lead3 TO wa_stot71-lead3.
  ADD i_output7-lead3 TO wa_stot72-lead3.
  ADD i_output7-lead3 TO wa_stot73-lead3.
  ADD i_output7-lead3 TO wa_gtot7-lead3.
  ADD i_output7-lead4q TO wa_stot71-lead4q.
  ADD i_output7-lead4q TO wa_stot72-lead4q.
  ADD i_output7-lead4q TO wa_stot73-lead4q.
  ADD i_output7-lead4q TO wa_gtot7-lead4q.
  ADD i_output7-lead4 TO wa_stot71-lead4.
  ADD i_output7-lead4 TO wa_stot72-lead4.
  ADD i_output7-lead4 TO wa_stot73-lead4.
  ADD i_output7-lead4 TO wa_gtot7-lead4.
  ADD i_output7-lead5q TO wa_stot71-lead5q.
  ADD i_output7-lead5q TO wa_stot72-lead5q.
  ADD i_output7-lead5q TO wa_stot73-lead5q.
  ADD i_output7-lead5q TO wa_gtot7-lead5q.
  ADD i_output7-lead5 TO wa_stot71-lead5.
  ADD i_output7-lead5 TO wa_stot72-lead5.
  ADD i_output7-lead5 TO wa_stot73-lead5.
  ADD i_output7-lead5 TO wa_gtot7-lead5.
  ADD i_output7-lead6q TO wa_stot71-lead6q.
  ADD i_output7-lead6q TO wa_stot72-lead6q.
  ADD i_output7-lead6q TO wa_stot73-lead6q.
  ADD i_output7-lead6q TO wa_gtot7-lead6q.
  ADD i_output7-lead6 TO wa_stot71-lead6.
  ADD i_output7-lead6 TO wa_stot72-lead6.
  ADD i_output7-lead6 TO wa_stot73-lead6.
  ADD i_output7-lead6 TO wa_gtot7-lead6.
  ADD i_output7-stkoutq TO wa_stot71-stkoutq.
  ADD i_output7-stkoutq TO wa_stot72-stkoutq.
  ADD i_output7-stkoutq TO wa_stot73-stkoutq.
  ADD i_output7-stkoutq TO wa_gtot7-stkoutq.
  ADD i_output7-stkout TO wa_stot71-stkout.
  ADD i_output7-stkout TO wa_stot72-stkout.
  ADD i_output7-stkout TO wa_stot73-stkout.
  ADD i_output7-stkout TO wa_gtot7-stkout.
  ADD i_output7-cltopq TO wa_stot71-cltopq.
  ADD i_output7-cltopq TO wa_stot72-cltopq.
  ADD i_output7-cltopq TO wa_stot73-cltopq.
  ADD i_output7-cltopq TO wa_gtot7-cltopq.
  ADD i_output7-cltop TO wa_stot71-cltop.
  ADD i_output7-cltop TO wa_stot72-cltop.
  ADD i_output7-cltop TO wa_stot73-cltop.
  ADD i_output7-cltop TO wa_gtot7-cltop.
  ADD i_output7-salahq TO wa_stot71-salahq.
  ADD i_output7-salahq TO wa_stot72-salahq.
  ADD i_output7-salahq TO wa_stot73-salahq.
  ADD i_output7-salahq TO wa_gtot7-salahq.
  ADD i_output7-salah TO wa_stot71-salah.
  ADD i_output7-salah TO wa_stot72-salah.
  ADD i_output7-salah TO wa_stot73-salah.
  ADD i_output7-salah TO wa_gtot7-salah.
  ADD i_output7-otherq TO wa_stot71-otherq.
  ADD i_output7-otherq TO wa_stot72-otherq.
  ADD i_output7-otherq TO wa_stot73-otherq.
  ADD i_output7-otherq TO wa_gtot7-otherq.
  ADD i_output7-other TO wa_stot71-other.
  ADD i_output7-other TO wa_stot72-other.
  ADD i_output7-other TO wa_stot73-other.
  ADD i_output7-other TO wa_gtot7-other.
  ADD i_output7-rejectq TO wa_stot71-rejectq.
  ADD i_output7-rejectq TO wa_stot72-rejectq.
  ADD i_output7-rejectq TO wa_stot73-rejectq.
  ADD i_output7-rejectq TO wa_gtot7-rejectq.
  ADD i_output7-reject TO wa_stot71-reject.
  ADD i_output7-reject TO wa_stot72-reject.
  ADD i_output7-reject TO wa_stot73-reject.
  ADD i_output7-reject TO wa_gtot7-reject.
  ADD i_output7-pooutq TO wa_stot71-pooutq.
  ADD i_output7-pooutq TO wa_stot72-pooutq.
  ADD i_output7-pooutq TO wa_stot73-pooutq.
  ADD i_output7-pooutq TO wa_gtot7-pooutq.
  ADD i_output7-poout TO wa_stot71-poout.
  ADD i_output7-poout TO wa_stot72-poout.
  ADD i_output7-poout TO wa_stot73-poout.
  ADD i_output7-poout TO wa_gtot7-poout.
  ADD i_output7-btqty TO wa_stot71-btqty.
  ADD i_output7-btqty TO wa_stot72-btqty.
  ADD i_output7-btqty TO wa_stot73-btqty.
  ADD i_output7-btqty TO wa_gtot7-btqty.
  ADD i_output7-btamt TO wa_stot71-btamt.
  ADD i_output7-btamt TO wa_stot72-btamt.
  ADD i_output7-btamt TO wa_stot73-btamt.
  ADD i_output7-btamt TO wa_gtot7-btamt.

  PERFORM f_hitung_total USING '7'.

ENDFORM.                    " hitung_total7

*&---------------------------------------------------------------------*
*&      Form  f_build_fieldcat7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_fieldcat7.
  DEFINE mac_header7.
    read table t_abgru index &1.
    if sy-subrc eq 0.
      if p_val = 'X'.
        fieldcat-fieldname = 'VAL&1'.
        fieldcat-ref_fieldname = ''.
        fieldcat-tabname = 'I_OUTPUT7'.
        fieldcat-outputlen = 15.
        fieldcat-cfieldname = 'CURR'.
        fieldcat-seltext_s = t_abgru-bezei.
        fieldcat-seltext_m = t_abgru-bezei.
        fieldcat-seltext_l = t_abgru-bezei.
        append fieldcat. "clear fieldcat.
      else.
        fieldcat-fieldname = 'QTY&1'.
        fieldcat-ref_fieldname = ''.
        fieldcat-tabname = 'I_OUTPUT7'.
        fieldcat-outputlen = 15.
        fieldcat-decimalsfieldname = 'DECI'.
        fieldcat-seltext_s = t_abgru-bezei.
        fieldcat-seltext_m = t_abgru-bezei.
        fieldcat-seltext_l = t_abgru-bezei.
        append fieldcat. "clear fieldcat.
      endif.
    endif.
  END-OF-DEFINITION.

*  fieldcat-fieldname = 'PRINC'.
*  fieldcat-ref_fieldname = 'PRINC'.
*  fieldcat-tabname = 'I_OUTPUT7'.
*  fieldcat-outputlen = 6.
*  fieldcat-seltext_s = 'Princp'.
*  fieldcat-seltext_m = 'Principal'.
*  fieldcat-seltext_l = 'Principal'.
*  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'MATKL'.
  fieldcat-ref_fieldname = 'MATKL'.
  fieldcat-tabname = 'I_OUTPUT7'.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'Mat Group'.
  fieldcat-seltext_m = 'Material Group'.
  fieldcat-seltext_l = 'Material Group'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'MATNR'.
  fieldcat-ref_fieldname = 'MATNR'.
  fieldcat-tabname = 'I_OUTPUT7'.
  fieldcat-outputlen = 11.
  fieldcat-seltext_s = 'Material'.
  fieldcat-seltext_m = 'Material'.
  fieldcat-seltext_l = 'Material'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'MAKTX'.
  fieldcat-ref_fieldname = 'MAKTX'.
  fieldcat-tabname = 'I_OUTPUT7'.
  fieldcat-outputlen = 25.
  fieldcat-seltext_s = 'Material Desc'.
  fieldcat-seltext_m = 'Material Desc'.
  fieldcat-seltext_l = 'Material Descriptions'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'KWMENG'.
  fieldcat-ref_fieldname = 'KWMENG'.
  fieldcat-tabname = 'I_OUTPUT7'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'PO Qty'.
  fieldcat-seltext_m = 'PO Quantity'.
  fieldcat-seltext_l = 'PO Quantity'.
  fieldcat-decimals_out = '0'.
  fieldcat-no_zero = 'X'.
  APPEND fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'KZWI1'.
  fieldcat-ref_fieldname = 'KZWI1'.
  fieldcat-tabname = 'I_OUTPUT7'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'PO Amount'.
  fieldcat-seltext_m = 'PO Amount'.
  fieldcat-seltext_l = 'PO Amount'.
  fieldcat-currency = 'IDR'.
  fieldcat-decimals_out = '0'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out.

*  IF p_val = 'X'.
*    fieldcat-fieldname = 'BTAMT'.
*    fieldcat-ref_fieldname = 'BTAMT'.
*    fieldcat-tabname = 'I_OUTPUT7'.
*    fieldcat-outputlen = 13.
*    fieldcat-seltext_s = 'PO Batal'.
*    fieldcat-seltext_m = 'PO Batal'.
*    fieldcat-seltext_l = 'PO Batal'.
*    fieldcat-cfieldname = 'CURR'.
*    APPEND fieldcat. "clear fieldcat.
*  ELSE.
*    fieldcat-fieldname = 'BTQTY'.
*    fieldcat-ref_fieldname = 'BTQTY'.
*    fieldcat-tabname = 'I_OUTPUT7'.
*    fieldcat-outputlen = 13.
*    fieldcat-seltext_s = 'PO Batal'.
*    fieldcat-seltext_m = 'PO Batal'.
*    fieldcat-seltext_l = 'PO Batal'.
*    fieldcat-decimalsfieldname = 'DECI'.
*    APPEND fieldcat. "clear fieldcat.
*  ENDIF.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname,
         fieldcat-decimalsfieldname.

  fieldcat-fieldname = 'DLQTY'.
  fieldcat-ref_fieldname = 'DLQTY'.
  fieldcat-tabname = 'I_OUTPUT7'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'DO Qty'.
  fieldcat-seltext_m = 'DO Quantity'.
  fieldcat-seltext_l = 'DO Quantity'.
  fieldcat-decimals_out = '0'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname.

  fieldcat-fieldname = 'DLVAL'.
  fieldcat-ref_fieldname = 'DLVAL'.
  fieldcat-tabname = 'I_OUTPUT7'.
  fieldcat-outputlen = 13.
  fieldcat-seltext_s = 'DO Amount'.
  fieldcat-seltext_m = 'DO Amount'.
  fieldcat-seltext_l = 'DO Amount'.
  fieldcat-cfieldname = 'CURR'.
  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname.

  IF p_val = 'X'.
    fieldcat-fieldname = 'LEAD6'.
    fieldcat-ref_fieldname = 'LEAD6'.
    fieldcat-tabname = 'I_OUTPUT7'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Intransit'.
    fieldcat-seltext_m = 'Intransit'.
    fieldcat-seltext_l = 'Intransit'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD1'.
    fieldcat-ref_fieldname = 'LEAD1'.
    fieldcat-tabname = 'I_OUTPUT7'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead <= 3'.
    fieldcat-seltext_m = 'Lead <= 3'.
    fieldcat-seltext_l = 'Lead <= 3'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD2'.
    fieldcat-ref_fieldname = 'LEAD2'.
    fieldcat-tabname = 'I_OUTPUT7'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead = 4'.
    fieldcat-seltext_m = 'Lead = 4'.
    fieldcat-seltext_l = 'Lead = 4'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD3'.
    fieldcat-ref_fieldname = 'LEAD3'.
    fieldcat-tabname = 'I_OUTPUT7'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Lead >= 5'.
    fieldcat-seltext_m = 'Lead >= 5'.
    fieldcat-seltext_l = 'Lead >= 5'.
    APPEND fieldcat. "clear fieldcat.
  ELSE.
    fieldcat-fieldname = 'LEAD6Q'.
    fieldcat-ref_fieldname = 'LEAD6Q'.
    fieldcat-tabname = 'I_OUTPUT7'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Intransit'.
    fieldcat-seltext_m = 'Intransit'.
    fieldcat-seltext_l = 'Intransit'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD1Q'.
    fieldcat-ref_fieldname = 'LEAD1Q'.
    fieldcat-tabname = 'I_OUTPUT7'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead <= 3'.
    fieldcat-seltext_m = 'Lead <= 3'.
    fieldcat-seltext_l = 'Lead <= 3'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD2Q'.
    fieldcat-ref_fieldname = 'LEAD2Q'.
    fieldcat-tabname = 'I_OUTPUT7'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead = 4'.
    fieldcat-seltext_m = 'Lead = 4'.
    fieldcat-seltext_l = 'Lead = 4'.
    APPEND fieldcat. "clear fieldcat.

    fieldcat-fieldname = 'LEAD3Q'.
    fieldcat-ref_fieldname = 'LEAD3Q'.
    fieldcat-tabname = 'I_OUTPUT7'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Lead >= 5'.
    fieldcat-seltext_m = 'Lead >= 5'.
    fieldcat-seltext_l = 'Lead >= 5'.
    APPEND fieldcat. "clear fieldcat.
  ENDIF.

*  fieldcat-fieldname = 'LEAD4'.
*  fieldcat-ref_fieldname = 'LEAD4'.
*  fieldcat-tabname = 'I_OUTPUT7'.
*  fieldcat-outputlen = 13.
*  fieldcat-cfieldname = 'CURR'.
*  fieldcat-seltext_s = 'Lead >= 6'.
*  fieldcat-seltext_m = 'Lead >= 6'.
*  fieldcat-seltext_l = 'Lead >= 6'.
*  APPEND fieldcat. "clear fieldcat.

*  fieldcat-fieldname = 'LEAD5'.
*  fieldcat-ref_fieldname = 'LEAD5'.
*  fieldcat-tabname = 'I_OUTPUT7'.
*  fieldcat-outputlen = 13.
*  fieldcat-cfieldname = 'CURR'.
*  fieldcat-seltext_s = 'Lead >= 7'.
*  fieldcat-seltext_m = 'Lead => 7'.
*  fieldcat-seltext_l = 'Lead => 7'.
*  APPEND fieldcat. "clear fieldcat.

  CLEAR: fieldcat-currency,
         fieldcat-decimals_out,
         fieldcat-cfieldname,
         fieldcat-decimalsfieldname.

  IF p_val = 'X'.
    fieldcat-fieldname = 'UNVAL'.
    fieldcat-ref_fieldname = 'UNVAL'.
    fieldcat-tabname = 'I_OUTPUT7'.
    fieldcat-outputlen = 13.
    fieldcat-cfieldname = 'CURR'.
    fieldcat-seltext_s = 'Undlv Amount'.
    fieldcat-seltext_m = 'Undelivered Amount'.
    fieldcat-seltext_l = 'Undelivered Amount'.
    APPEND fieldcat. "clear fieldcat.

*    fieldcat-fieldname = 'CLTOP'.
*    fieldcat-ref_fieldname = 'CLTOP'.
*    fieldcat-tabname = 'I_OUTPUT7'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'CL / TOP'.
*    fieldcat-seltext_m = 'CL / TOP'.
*    fieldcat-seltext_l = 'CL / TOP'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'STKOUT'.
*    fieldcat-ref_fieldname = 'STKOUT'.
*    fieldcat-tabname = 'I_OUTPUT7'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Stock Out'.
*    fieldcat-seltext_m = 'Stock Out'.
*    fieldcat-seltext_l = 'Stock Out'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'SALAH'.
*    fieldcat-ref_fieldname = 'SALAH'.
*    fieldcat-tabname = 'I_OUTPUT7'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Salah Harga'.
*    fieldcat-seltext_m = 'Salah Harga'.
*    fieldcat-seltext_l = 'Salah Harga'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'OTHER'.
*    fieldcat-ref_fieldname = 'OTHER'.
*    fieldcat-tabname = 'I_OUTPUT7'.
*    fieldcat-outputlen = 11.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'Other'.
*    fieldcat-seltext_m = 'Other'.
*    fieldcat-seltext_l = 'Other'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'POOUT'.
*    fieldcat-ref_fieldname = 'POOUT'.
*    fieldcat-tabname = 'I_OUTPUT7'.
*    fieldcat-outputlen = 13.
*    fieldcat-cfieldname = 'CURR'.
*    fieldcat-seltext_s = 'PO Outs'.
*    fieldcat-seltext_m = 'PO Outstanding'.
*    fieldcat-seltext_l = 'PO Outstanding'.
*    APPEND fieldcat. "clear fieldcat.
  ELSE.
    fieldcat-fieldname = 'UNQTY'.
    fieldcat-ref_fieldname = 'UNQTY'.
    fieldcat-tabname = 'I_OUTPUT7'.
    fieldcat-outputlen = 13.
    fieldcat-decimalsfieldname = 'DECI'.
    fieldcat-seltext_s = 'Undlv Qty'.
    fieldcat-seltext_m = 'Undelivered Quantity'.
    fieldcat-seltext_l = 'Undelivered Quantity'.
    APPEND fieldcat. "clear fieldcat.

*    fieldcat-fieldname = 'CLTOPQ'.
*    fieldcat-ref_fieldname = 'CLTOPQ'.
*    fieldcat-tabname = 'I_OUTPUT7'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'CL / TOP'.
*    fieldcat-seltext_m = 'CL / TOP'.
*    fieldcat-seltext_l = 'CL / TOP'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'STKOUTQ'.
*    fieldcat-ref_fieldname = 'STKOUTQ'.
*    fieldcat-tabname = 'I_OUTPUT7'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Stock Out'.
*    fieldcat-seltext_m = 'Stock Out'.
*    fieldcat-seltext_l = 'Stock Out'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'SALAHQ'.
*    fieldcat-ref_fieldname = 'SALAHQ'.
*    fieldcat-tabname = 'I_OUTPUT7'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Salah Harga'.
*    fieldcat-seltext_m = 'Salah Harga'.
*    fieldcat-seltext_l = 'Salah Harga'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'OTHERQ'.
*    fieldcat-ref_fieldname = 'OTHERQ'.
*    fieldcat-tabname = 'I_OUTPUT7'.
*    fieldcat-outputlen = 11.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'Other'.
*    fieldcat-seltext_m = 'Other'.
*    fieldcat-seltext_l = 'Other'.
*    APPEND fieldcat. "clear fieldcat.
*
*    fieldcat-fieldname = 'POOUTQ'.
*    fieldcat-ref_fieldname = 'POOUTQ'.
*    fieldcat-tabname = 'I_OUTPUT7'.
*    fieldcat-outputlen = 13.
*    fieldcat-decimalsfieldname = 'DECI'.
*    fieldcat-seltext_s = 'PO Outs'.
*    fieldcat-seltext_m = 'PO Outstanding'.
*    fieldcat-seltext_l = 'PO Outstanding'.
*    APPEND fieldcat. "clear fieldcat.
  ENDIF.

  mac_header7 : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.

ENDFORM.                    " f_build_fieldcat7

*&---------------------------------------------------------------------*
*&      Form  f_build_sortfield7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_SORT
*----------------------------------------------------------------------*
FORM f_build_sortfield7 USING fu_sort TYPE slis_t_sortinfo_alv.

  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'VKBUR'.
  ld_sort-up        = 'X'.
  ld_sort-group     = '*'.
  ld_sort-spos      = '01'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'PRINC'.
  ld_sort-up        = 'X'.
  ld_sort-group     = '*'.
  ld_sort-spos      = '02'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'PRINX'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
  ld_sort-spos      = '03'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'MATKX'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
  ld_sort-spos      = '04'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'INDEX'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-spos      = '05'.
  APPEND ld_sort TO fu_sort.

ENDFORM.                    " f_build_sortfield7

*&---------------------------------------------------------------------*
*&      Form  f_build_event7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_EVENTS
*----------------------------------------------------------------------*
FORM f_build_event7 TABLES ft_events LIKE t_events.

  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE7'.
  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_end_of_list.
*  ft_events-form = 'F_END_OF_LIST3'.
*  APPEND ft_events.

ENDFORM.                    " f_build_event3

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE7                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page7.

  DATA : l_line1(70),
         l_line2(60),
         l_sloff(80),
         l_cust(80),
         l_fdate(10),
         l_tdate(10).

  WRITE s_erdat-low TO l_fdate.
  WRITE s_erdat-high TO l_tdate.
*--- Title
  CONCATENATE sy-title 'By Branch, Principal, Material Grp' '(02)'
                                        INTO l_line1 SEPARATED BY space.
*--- Period
  CONCATENATE 'Period :' l_fdate 'to' l_tdate
              INTO l_line2 SEPARATED BY space.

*  IF NOT p_total3 IS INITIAL.
**--- Sales Office
*    CONCATENATE 'Sales Office    :' i_output7-vkbur i_output7-vkburt
*                INTO l_sloff SEPARATED BY space.
*    l_cust = 'SUMMARY'.
*  ELSEIF NOT p_total7 IS INITIAL.
**--- Sales Office
*    l_sloff = 'SUMMARY'.
*    CLEAR l_cust.
*  ELSE.
*--- Sales Office
  CONCATENATE 'Sales Office    :' i_output7-vkbur i_output7-vkburt
              INTO l_sloff SEPARATED BY space.
*--- Group Customer
  CONCATENATE 'Principal       :' i_output7-princ
              INTO l_cust SEPARATED BY space.
*  ENDIF.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING l_line1.
  PERFORM f_hdr_line2 USING l_sloff l_line2.
  PERFORM f_hdr_line3 USING l_cust va_text.
  PERFORM f_hdr_uline.

ENDFORM.                    "f_top_of_page7

*&---------------------------------------------------------------------*
*&      Form  f_check_stock_outs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_stock_outs.

  DATA : lw_output1 LIKE i_output1,
         l_index LIKE sy-tabix.

  LOOP AT i_detquot.

    l_index = sy-tabix.
    CLEAR : i_detsales, i_detdelv, lw_output1. ", i_detquot-abgru.

    READ TABLE i_detsales WITH KEY
                               vgbel = i_detquot-vbeln
                               posnr = i_detquot-posnr. " BINARY SEARCH.
    IF sy-subrc = 0.
      i_detquot-abgru = i_detsales-abgru.
    ENDIF.

    MOVE-CORRESPONDING i_detquot TO lw_output1.

    READ TABLE i_detdelv WITH KEY
                              vgbel = i_detsales-vbeln
                              vgpos = i_detsales-posnr. " BINARY SEARCH.
    IF sy-subrc = 0.
      lw_output1-unqty = lw_output1-kwmeng - i_detsales-kwmeng.
      lw_output1-unval = lw_output1-kzwi1 - i_detsales-kzwi1.
    ELSE.
      IF i_detsales-vbeln IS INITIAL.
        lw_output1-unqty = lw_output1-kwmeng.
        lw_output1-unval = lw_output1-kzwi1.
      ENDIF.
    ENDIF.

    IF lw_output1-unqty NE 0 AND NOT i_detdelv-vbeln IS INITIAL.
      lw_output1-abgru = '00'.
    ENDIF.

    IF lw_output1-abgru = '00'.
      lw_output1-stkout = lw_output1-unval.
    ENDIF.

    IF lw_output1-stkout IS INITIAL.
      DELETE i_detquot INDEX l_index .
    ENDIF.

  ENDLOOP.

ENDFORM.                    " f_check_stock_outs

*&---------------------------------------------------------------------*
*&      Form  f_check_stock_outs1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_stock_outs1.

  DATA : lw_output1 LIKE i_output1,
         l_index LIKE sy-tabix.

  LOOP AT i_detquot7.

    l_index = sy-tabix.
    CLEAR : i_detsales, i_detdelv, lw_output1. ", i_detquot7-abgru.

    READ TABLE i_detsales WITH KEY
                               vgbel = i_detquot7-vbeln
                               posnr = i_detquot7-posnr. " BINARY SEARCH.
    IF sy-subrc = 0.
      i_detquot7-abgru = i_detsales-abgru.
    ENDIF.

    MOVE-CORRESPONDING i_detquot7 TO lw_output1.

    READ TABLE i_detdelv WITH KEY
                              vgbel = i_detsales-vbeln
                              vgpos = i_detsales-posnr. " BINARY SEARCH.
    IF sy-subrc = 0.
      lw_output1-unqty = lw_output1-kwmeng - i_detsales-kwmeng.
      lw_output1-unval = lw_output1-kzwi1 - i_detsales-kzwi1.
    ELSE.
      IF i_detsales-vbeln IS INITIAL.
        lw_output1-unqty = lw_output1-kwmeng.
        lw_output1-unval = lw_output1-kzwi1.
      ENDIF.
    ENDIF.

    IF lw_output1-unqty NE 0 AND NOT i_detdelv-vbeln IS INITIAL.
      lw_output1-abgru = '00'.
    ENDIF.

    IF lw_output1-abgru = '00'.
      lw_output1-stkout = lw_output1-unval.
    ENDIF.

    IF lw_output1-stkout IS INITIAL.
      DELETE i_detquot7 INDEX l_index .
    ENDIF.

  ENDLOOP.

ENDFORM.                    " f_check_stock_outs1

*&---------------------------------------------------------------------*
*&      Form  F_REASON_FOR_REJECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_ABGRU  text
*      -->FU_UNQTY  text
*      -->FU_UNVAL  text
*      -->FU_FLG    text
*----------------------------------------------------------------------*
FORM f_reason_for_rejection  USING  fu_abgru fu_unqty fu_unval fu_flg.
  DEFINE mac_collect.
    case fu_flg.
      when 1.
        i_output1-qty&1 = i_output1-unqty.
        i_output1-val&1 = i_output1-unval.
      when 2.
        i_output2-qty&1 = i_output2-unqty.
        i_output2-val&1 = i_output2-unval.
      when 3.
        i_output3-qty&1 = i_output3-unqty.
        i_output3-val&1 = i_output3-unval.
      when 4.
        i_output4-qty&1 = i_output4-unqty.
        i_output4-val&1 = i_output4-unval.
      when 5.
        i_output5-qty&1 = i_output5-unqty.
        i_output5-val&1 = i_output5-unval.
      when 6.
        i_output6-qty&1 = i_output6-unqty.
        i_output6-val&1 = i_output6-unval.
      when 7.
        i_output7-qty&1 = i_output7-unqty.
        i_output7-val&1 = i_output7-unval.
      when others.
    endcase.
  END-OF-DEFINITION.

  READ TABLE t_abgru_ori WITH KEY abgru = fu_abgru.
  IF sy-subrc NE 0.
    IF fu_abgru IS INITIAL.
      fu_abgru = '99'.
    ELSE.
      fu_abgru = '98'.
    ENDIF.
    READ TABLE t_abgru WITH KEY abgru = fu_abgru.
  ENDIF.
  CASE sy-tabix.
    WHEN 1.
      mac_collect : 1.
    WHEN 2.
      mac_collect : 2.
    WHEN 3.
      mac_collect : 3.
    WHEN 4.
      mac_collect : 4.
    WHEN 5.
      mac_collect : 5.
    WHEN 6.
      mac_collect : 6.
    WHEN 7.
      mac_collect : 7.
    WHEN 8.
      mac_collect : 8.
    WHEN 9.
      mac_collect : 9.
    WHEN 10.
      mac_collect : 10.
    WHEN 11.
      mac_collect : 11.
    WHEN 12.
      mac_collect : 12.
    WHEN 13.
      mac_collect : 13.
    WHEN 14.
      mac_collect : 14.
    WHEN 15.
      mac_collect : 15.
    WHEN 16.
      mac_collect : 16.
    WHEN 17.
      mac_collect : 17.
    WHEN 18.
      mac_collect : 18.
    WHEN 19.
      mac_collect : 19.
    WHEN 20.
      mac_collect : 20.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_REASON_FOR_REJECTION

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_TOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_FLG   text
*----------------------------------------------------------------------*
FORM f_hitung_total  USING  fu_flg.
  DEFINE mac_total.
    case fu_flg.
      when 1.
        add i_output1-qty&1 to wa_stot1-qty&1.
        add i_output1-qty&1 to wa_stot2-qty&1.
        add i_output1-qty&1 to wa_stot3-qty&1.
        add i_output1-qty&1 to wa_gtot-qty&1.
        add i_output1-val&1 to wa_stot1-val&1.
        add i_output1-val&1 to wa_stot2-val&1.
        add i_output1-val&1 to wa_stot3-val&1.
        add i_output1-val&1 to wa_gtot-val&1.
      when 2.
        add i_output2-qty&1 to wa_stot21-qty&1.
        add i_output2-qty&1 to wa_stot22-qty&1.
        add i_output2-qty&1 to wa_stot23-qty&1.
        add i_output2-qty&1 to wa_gtot2-qty&1.
        add i_output2-val&1 to wa_stot21-val&1.
        add i_output2-val&1 to wa_stot22-val&1.
        add i_output2-val&1 to wa_stot23-val&1.
        add i_output2-val&1 to wa_gtot2-val&1.
      when 3.
        add i_output3-qty&1 to wa_stot31-qty&1.
        add i_output3-qty&1 to wa_stot32-qty&1.
        add i_output3-qty&1 to wa_stot33-qty&1.
        add i_output3-qty&1 to wa_stot34-qty&1.
        add i_output3-qty&1 to wa_gtot3-qty&1.
        add i_output3-val&1 to wa_stot31-val&1.
        add i_output3-val&1 to wa_stot32-val&1.
        add i_output3-val&1 to wa_stot33-val&1.
        add i_output3-val&1 to wa_stot34-val&1.
        add i_output3-val&1 to wa_gtot3-val&1.
      when 4.
        add i_output4-qty&1 to wa_stot41-qty&1.
        add i_output4-qty&1 to wa_stot42-qty&1.
        add i_output4-qty&1 to wa_stot43-qty&1.
        add i_output4-qty&1 to wa_stot44-qty&1.
        add i_output4-qty&1 to wa_gtot4-qty&1.
        add i_output4-val&1 to wa_stot41-val&1.
        add i_output4-val&1 to wa_stot42-val&1.
        add i_output4-val&1 to wa_stot43-val&1.
        add i_output4-val&1 to wa_stot44-val&1.
        add i_output4-val&1 to wa_gtot4-val&1.
      when 5.
        add i_output5-qty&1 to wa_stot51-qty&1.
        add i_output5-qty&1 to wa_stot52-qty&1.
        add i_output5-qty&1 to wa_stot53-qty&1.
        add i_output5-qty&1 to wa_gtot5-qty&1.
        add i_output5-val&1 to wa_stot51-val&1.
        add i_output5-val&1 to wa_stot52-val&1.
        add i_output5-val&1 to wa_stot53-val&1.
        add i_output5-val&1 to wa_gtot5-val&1.
      when 6.
        add i_output6-qty&1 to wa_stot61-qty&1.
        add i_output6-qty&1 to wa_stot62-qty&1.
        add i_output6-qty&1 to wa_stot63-qty&1.
        add i_output6-qty&1 to wa_gtot6-qty&1.
        add i_output6-val&1 to wa_stot61-val&1.
        add i_output6-val&1 to wa_stot62-val&1.
        add i_output6-val&1 to wa_stot63-val&1.
        add i_output6-val&1 to wa_gtot6-val&1.
      when 7.
        add i_output7-qty&1 to wa_stot71-qty&1.
        add i_output7-qty&1 to wa_stot72-qty&1.
        add i_output7-qty&1 to wa_stot73-qty&1.
        add i_output7-qty&1 to wa_gtot7-qty&1.
        add i_output7-val&1 to wa_stot71-val&1.
        add i_output7-val&1 to wa_stot72-val&1.
        add i_output7-val&1 to wa_stot73-val&1.
        add i_output7-val&1 to wa_gtot7-val&1.
      when others.
    endcase.
  END-OF-DEFINITION.

  mac_total : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.
ENDFORM.                    " F_HITUNG_TOTAL

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_STOT4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_KZWI1  text
*      -->FU_BTAMT  text
*      -->FU_KWMENG text
*      -->FU_BTQTY  text
*      -->FU_VAL    text
*      -->FU_FLG    text
*----------------------------------------------------------------------*
FORM f_hitung_stot4  USING    fu_kzwi1
                              fu_btamt
                              fu_kwmeng
                              fu_btqty
                              fu_val
                              fu_flg.
  DEFINE mac_total4.
    case fu_flg.
      when 3.
        if fu_val is initial.
          wa_stot34-prc&1 = wa_stot34-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot34-prc&1 = wa_stot34-val&1 / ( fu_kzwi1 - fu_btamt ) * 100.
        endif.
      when 4.
        if fu_val is initial.
          wa_stot44-prc&1 = wa_stot44-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot44-prc&1 = wa_stot44-val&1 / ( fu_kzwi1 - fu_btamt ) * 100.
        endif.
      when others.
    endcase.
  END-OF-DEFINITION.

  mac_total4 : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.
ENDFORM.                    " F_HITUNG_STOT4

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_STOT4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_VAL    text
*      -->FU_FLG    text
*----------------------------------------------------------------------*
FORM f_move_stot4  USING  fu_val fu_flg.
  DEFINE mac_move4.
    case fu_flg.
      when 3.
        if fu_val is initial.
          wa_stot34-qty&1 = wa_stot34-prc&1.
        else.
          wa_stot34-val&1 = wa_stot34-prc&1.
        endif.
      when 4.
        if fu_val is initial.
          wa_stot44-qty&1 = wa_stot44-prc&1.
        else.
          wa_stot44-val&1 = wa_stot44-prc&1.
        endif.
      when others.
    endcase.
  END-OF-DEFINITION.

  mac_move4 : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.
ENDFORM.                    " F_MOVE_STOT4

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_STOT3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_KZWI1  text
*      -->FU_BTAMT  text
*      -->FU_KWMENG text
*      -->FU_BTQTY  text
*      -->FU_VAL    text
*      -->FU_FLG    text
*----------------------------------------------------------------------*
FORM f_hitung_stot3  USING    fu_kzwi1
                              fu_btamt
                              fu_kwmeng
                              fu_btqty
                              fu_val
                              fu_flg.
  DEFINE mac_total3.
    case fu_flg.
      when 1.
        if fu_val is initial.
          wa_stot3-prc&1 = wa_stot3-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot3-prc&1 = wa_stot3-val&1 / ( fu_kzwi1 - fu_btamt ) * 100.
        endif.
      when 2.
        if fu_val is initial.
          wa_stot23-prc&1 = wa_stot23-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot23-prc&1 = wa_stot23-val&1 / ( fu_kzwi1 - fu_btamt ) * 100.
        endif.
      when 3.
        if fu_val is initial.
          wa_stot33-prc&1 = wa_stot33-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot33-prc&1 = wa_stot33-val&1 / ( fu_kzwi1 - fu_btamt ) * 100.
        endif.
      when 4.
        if fu_val is initial.
          wa_stot43-prc&1 = wa_stot43-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot43-prc&1 = wa_stot43-val&1 / ( fu_kzwi1 - fu_btamt ) * 100.
        endif.
      when 5.
        if fu_val is initial.
          wa_stot53-prc&1 = wa_stot53-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot53-prc&1 = wa_stot53-val&1 / ( fu_kzwi1 - fu_btamt ) * 100.
        endif.
      when 6.
        if fu_val is initial.
          wa_stot63-prc&1 = wa_stot63-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot63-prc&1 = wa_stot63-val&1 / ( fu_kzwi1 - fu_btamt ) * 100.
        endif.
      when 7.
        if fu_val is initial.
          wa_stot73-prc&1 = wa_stot73-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot73-prc&1 = wa_stot73-val&1 / ( fu_kzwi1 - fu_btamt ) * 100.
        endif.
      when others.
    endcase.
  END-OF-DEFINITION.

  mac_total3 : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.
ENDFORM.                    " F_HITUNG_STOT3

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_STOT3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_VAL    text
*      -->FU_FLG    text
*----------------------------------------------------------------------*
FORM f_move_stot3  USING  fu_val fu_flg.
  DEFINE mac_move3.
    case fu_flg.
      when 1.
        if fu_val is initial.
          wa_stot3-qty&1 = wa_stot3-prc&1.
        else.
          wa_stot3-val&1 = wa_stot3-prc&1.
        endif.
      when 2.
        if fu_val is initial.
          wa_stot23-qty&1 = wa_stot23-prc&1.
        else.
          wa_stot23-val&1 = wa_stot23-prc&1.
        endif.
      when 3.
        if fu_val is initial.
          wa_stot33-qty&1 = wa_stot33-prc&1.
        else.
          wa_stot33-val&1 = wa_stot33-prc&1.
        endif.
      when 4.
        if fu_val is initial.
          wa_stot43-qty&1 = wa_stot43-prc&1.
        else.
          wa_stot43-val&1 = wa_stot43-prc&1.
        endif.
      when 5.
        if fu_val is initial.
          wa_stot53-qty&1 = wa_stot53-prc&1.
        else.
          wa_stot53-val&1 = wa_stot53-prc&1.
        endif.
      when 6.
        if fu_val is initial.
          wa_stot63-qty&1 = wa_stot63-prc&1.
        else.
          wa_stot63-val&1 = wa_stot63-prc&1.
        endif.
      when 7.
        if fu_val is initial.
          wa_stot73-qty&1 = wa_stot73-prc&1.
        else.
          wa_stot73-val&1 = wa_stot73-prc&1.
        endif.
      when others.
    endcase.
  END-OF-DEFINITION.

  mac_move3 : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.
ENDFORM.                    " F_MOVE_STOT3

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_STOT2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_KZWI1  text
*      -->FU_BTAMT  text
*      -->FU_KWMENG text
*      -->FU_BTQTY  text
*      -->FU_VAL    text
*      -->FU_FLG    text
*----------------------------------------------------------------------*
FORM f_hitung_stot2  USING    fu_kzwi1
                              fu_btamt
                              fu_kwmeng
                              fu_btqty
                              fu_val
                              fu_flg.
  DEFINE mac_total2.
    case fu_flg.
      when 1.
        if fu_val is initial.
          wa_stot2-prc&1 = wa_stot2-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot2-prc&1 = wa_stot2-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 2.
        if fu_val is initial.
          wa_stot22-prc&1 = wa_stot22-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot22-prc&1 = wa_stot22-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 3.
        if fu_val is initial.
          wa_stot32-prc&1 = wa_stot32-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot32-prc&1 = wa_stot32-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 4.
        if fu_val is initial.
          wa_stot42-prc&1 = wa_stot42-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot42-prc&1 = wa_stot42-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 5.
        if fu_val is initial.
          wa_stot52-prc&1 = wa_stot52-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot52-prc&1 = wa_stot52-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 6.
        if fu_val is initial.
          wa_stot62-prc&1 = wa_stot62-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot62-prc&1 = wa_stot62-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 7.
        if fu_val is initial.
          wa_stot72-prc&1 = wa_stot72-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot72-prc&1 = wa_stot72-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when others.
    endcase.
  END-OF-DEFINITION.

  mac_total2 : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.
ENDFORM.                    " F_HITUNG_STOT2

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_STOT2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_VAL    text
*      -->FU_FLG    text
*----------------------------------------------------------------------*
FORM f_move_stot2  USING   fu_val fu_flg.
  DEFINE mac_move2.
    case fu_flg.
      when 1.
        if fu_val is initial.
          wa_stot2-qty&1 = wa_stot2-prc&1.
        else.
          wa_stot2-val&1 = wa_stot2-prc&1.
        endif.
      when 2.
        if fu_val is initial.
          wa_stot22-qty&1 = wa_stot22-prc&1.
        else.
          wa_stot22-val&1 = wa_stot22-prc&1.
        endif.
      when 3.
        if fu_val is initial.
          wa_stot32-qty&1 = wa_stot32-prc&1.
        else.
          wa_stot32-val&1 = wa_stot32-prc&1.
        endif.
      when 4.
        if fu_val is initial.
          wa_stot42-qty&1 = wa_stot42-prc&1.
        else.
          wa_stot42-val&1 = wa_stot42-prc&1.
        endif.
      when 5.
        if fu_val is initial.
          wa_stot52-qty&1 = wa_stot52-prc&1.
        else.
          wa_stot52-val&1 = wa_stot52-prc&1.
        endif.
      when 6.
        if fu_val is initial.
          wa_stot62-qty&1 = wa_stot62-prc&1.
        else.
          wa_stot62-val&1 = wa_stot62-prc&1.
        endif.
      when 7.
        if fu_val is initial.
          wa_stot72-qty&1 = wa_stot72-prc&1.
        else.
          wa_stot72-val&1 = wa_stot72-prc&1.
        endif.
      when others.
    endcase.
  END-OF-DEFINITION.

  mac_move2 : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.
ENDFORM.                    " F_MOVE_STOT2

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_STOT1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_KZWI1  text
*      -->FU_BTAMT  text
*      -->FU_KWMENG text
*      -->FU_BTQTY  text
*      -->FU_VAL    text
*      -->FU_FLG    text
*----------------------------------------------------------------------*
FORM f_hitung_stot1  USING    fu_kzwi1
                              fu_btamt
                              fu_kwmeng
                              fu_btqty
                              fu_val
                              fu_flg.
  DEFINE mac_total1.
    case fu_flg.
      when 1.
        if fu_val is initial.
          wa_stot1-prc&1 = wa_stot1-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot1-prc&1 = wa_stot1-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 2.
        if fu_val is initial.
          wa_stot21-prc&1 = wa_stot21-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot21-prc&1 = wa_stot21-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 3.
        if fu_val is initial.
          wa_stot31-prc&1 = wa_stot31-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot31-prc&1 = wa_stot31-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 4.
        if fu_val is initial.
          wa_stot41-prc&1 = wa_stot41-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot41-prc&1 = wa_stot41-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 5.
        if fu_val is initial.
          wa_stot51-prc&1 = wa_stot51-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot51-prc&1 = wa_stot51-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 6.
        if fu_val is initial.
          wa_stot61-prc&1 = wa_stot61-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot61-prc&1 = wa_stot61-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 7.
        if fu_val is initial.
          wa_stot71-prc&1 = wa_stot71-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_stot71-prc&1 = wa_stot71-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when others.
    endcase.
  END-OF-DEFINITION.

  mac_total1 : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.
ENDFORM.                    " F_HITUNG_STOT1

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_STOT1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_VAL    text
*      -->FU_FLG    text
*----------------------------------------------------------------------*
FORM f_move_stot1  USING   fu_val fu_flg.
  DEFINE mac_move1.
    case fu_flg.
      when 1.
        if fu_val is initial.
          wa_stot1-qty&1 = wa_stot1-prc&1.
        else.
          wa_stot1-val&1 = wa_stot1-prc&1.
        endif.
      when 2.
        if fu_val is initial.
          wa_stot21-qty&1 = wa_stot21-prc&1.
        else.
          wa_stot21-val&1 = wa_stot21-prc&1.
        endif.
      when 3.
        if fu_val is initial.
          wa_stot31-qty&1 = wa_stot31-prc&1.
        else.
          wa_stot31-val&1 = wa_stot31-prc&1.
        endif.
      when 4.
        if fu_val is initial.
          wa_stot41-qty&1 = wa_stot41-prc&1.
        else.
          wa_stot41-val&1 = wa_stot41-prc&1.
        endif.
      when 5.
        if fu_val is initial.
          wa_stot51-qty&1 = wa_stot51-prc&1.
        else.
          wa_stot51-val&1 = wa_stot51-prc&1.
        endif.
      when 6.
        if fu_val is initial.
          wa_stot61-qty&1 = wa_stot61-prc&1.
        else.
          wa_stot61-val&1 = wa_stot61-prc&1.
        endif.
      when 7.
        if fu_val is initial.
          wa_stot71-qty&1 = wa_stot71-prc&1.
        else.
          wa_stot71-val&1 = wa_stot71-prc&1.
        endif.
      when others.
    endcase.
  END-OF-DEFINITION.

  mac_move1 : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.
ENDFORM.                    " F_MOVE_STOT1

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_GTOT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_KZWI1  text
*      -->FU_BTAMT  text
*      -->FU_KWMENG text
*      -->FU_BTQTY  text
*      -->FU_VAL    text
*      -->FU_FLG    text
*----------------------------------------------------------------------*
FORM f_hitung_gtot  USING     fu_kzwi1
                              fu_btamt
                              fu_kwmeng
                              fu_btqty
                              fu_val
                              fu_flg.
  DEFINE mac_gtotal.
    case fu_flg.
      when 1.
        if fu_val is initial.
          wa_gtot-prc&1 = wa_gtot-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_gtot-prc&1 = wa_gtot-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 2.
        if fu_val is initial.
          wa_gtot2-prc&1 = wa_gtot2-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_gtot2-prc&1 = wa_gtot2-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 3.
        if fu_val is initial.
          wa_gtot3-prc&1 = wa_gtot3-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_gtot3-prc&1 = wa_gtot3-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 4.
        if fu_val is initial.
          wa_gtot4-prc&1 = wa_gtot4-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_gtot4-prc&1 = wa_gtot4-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 5.
        if fu_val is initial.
          wa_gtot5-prc&1 = wa_gtot5-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_gtot5-prc&1 = wa_gtot5-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 6.
        if fu_val is initial.
          wa_gtot6-prc&1 = wa_gtot6-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_gtot6-prc&1 = wa_gtot6-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when 7.
        if fu_val is initial.
          wa_gtot7-prc&1 = wa_gtot7-qty&1 / ( fu_kwmeng - fu_btqty ) * 100.
        else.
          wa_gtot7-prc&1 = wa_gtot7-val&1 / ( fu_kzwi1 -  fu_btamt ) * 100.
        endif.
      when others.
    endcase.
  END-OF-DEFINITION.

  mac_gtotal : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.
ENDFORM.                    " F_HITUNG_GTOT

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_GTOT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_VAL    text
*      -->FU_FLG    text
*----------------------------------------------------------------------*
FORM f_move_gtot  USING   fu_val fu_flg.
  DEFINE mac_moveg.
    case fu_flg.
      when 1.
        if fu_val is initial.
          wa_gtot-qty&1 = wa_gtot-prc&1.
        else.
          wa_gtot-val&1 = wa_gtot-prc&1.
        endif.
      when 2.
        if fu_val is initial.
          wa_gtot2-qty&1 = wa_gtot2-prc&1.
        else.
          wa_gtot2-val&1 = wa_gtot2-prc&1.
        endif.
      when 3.
        if fu_val is initial.
          wa_gtot3-qty&1 = wa_gtot3-prc&1.
        else.
          wa_gtot3-val&1 = wa_gtot3-prc&1.
        endif.
      when 4.
        if fu_val is initial.
          wa_gtot4-qty&1 = wa_gtot4-prc&1.
        else.
          wa_gtot4-val&1 = wa_gtot4-prc&1.
        endif.
      when 5.
        if fu_val is initial.
          wa_gtot5-qty&1 = wa_gtot5-prc&1.
        else.
          wa_gtot5-val&1 = wa_gtot5-prc&1.
        endif.
      when 6.
        if fu_val is initial.
          wa_gtot6-qty&1 = wa_gtot6-prc&1.
        else.
          wa_gtot6-val&1 = wa_gtot6-prc&1.
        endif.
      when 7.
        if fu_val is initial.
          wa_gtot7-qty&1 = wa_gtot7-prc&1.
        else.
          wa_gtot7-val&1 = wa_gtot7-prc&1.
        endif.
      when others.
    endcase.
  END-OF-DEFINITION.

  mac_moveg : 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20.
ENDFORM.                    " F_MOVE_GTOT


*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD
*&---------------------------------------------------------------------*
FORM f_download .
  DATA : lt_download    TYPE truxs_t_text_data,
         ls_download    LIKE LINE OF lt_download,
         lv_command(125).

  DATA : lv_path      TYPE char128,
         lv_leadt     TYPE i,
         lv_kwmeng    TYPE vbap-kwmeng,
         lv_kzwi1     TYPE vbap-kzwi1,
         lv_month(6),
         lv_fieldnm(20),
         lv_tabix     TYPE char2,
         lv_percen    TYPE p DECIMALS 2.

  DATA : BEGIN OF tabl OCCURS 10,
           line(200),
         END OF tabl.

  DATA : ls_char  TYPE ty_char.
  DATA : ls_knvv  LIKE LINE OF i_knvv.

  IF s_erdat-high IS NOT INITIAL.
    lv_month = s_erdat-high(6).
  ELSE.
    lv_month = s_erdat-low(6).
  ENDIF.

  SELECT SINGLE low
    FROM tvarvc
    INTO lv_path
    WHERE name = 'ZDSP_PATHSL'.

  IF sy-subrc = 0.
*    CONCATENATE lv_path p_vkorg '_SO_' lv_month '.csv' INTO lv_path.
    CONCATENATE lv_path s_vkbur-low '_SO_' lv_month '.csv' INTO lv_path.

    LOOP AT i_output1.
      PERFORM f_unit_convert USING i_output1-kwmeng ''
                             CHANGING ls_char-poqty.
      PERFORM f_curr_convert USING i_output1-kzwi1 ''
                             CHANGING ls_char-poval.
      PERFORM f_unit_convert USING i_output1-dlqty ''
                             CHANGING ls_char-doqty.
      PERFORM f_curr_convert USING i_output1-dlval ''
                             CHANGING ls_char-doval.
      PERFORM f_unit_convert USING i_output1-lead6q ''
                             CHANGING ls_char-lead6q.
      PERFORM f_curr_convert USING i_output1-lead6 ''
                             CHANGING ls_char-lead6v.
      PERFORM f_unit_convert USING i_output1-lead1q ''
                             CHANGING ls_char-lead1q.
      PERFORM f_curr_convert USING i_output1-lead1 ''
                             CHANGING ls_char-lead1v.
      PERFORM f_unit_convert USING i_output1-lead2q ''
                             CHANGING ls_char-lead2q.
      PERFORM f_curr_convert USING i_output1-lead2 ''
                             CHANGING ls_char-lead2v.
      PERFORM f_unit_convert USING i_output1-lead3q ''
                             CHANGING ls_char-lead3q.
      PERFORM f_curr_convert USING i_output1-lead3 ''
                             CHANGING ls_char-lead3v.
      PERFORM f_unit_convert USING i_output1-unqty ''
                             CHANGING ls_char-unqty.
      PERFORM f_curr_convert USING i_output1-unval ''
                             CHANGING ls_char-unval.

      CLEAR ls_knvv.
      READ TABLE i_knvv INTO ls_knvv WITH KEY kunnr = i_output1-knkli.

      CONCATENATE lv_month p_vkorg i_output1-vkbur ls_knvv-vkbur
                  i_output1-kukla i_output1-knkli i_output1-vbeln
                  i_output1-princ i_output1-matkl i_output1-matnr
                  i_output1-bstnk i_output1-abgru
                  ls_char-poqty ls_char-poval

                  i_detdelv-vbeln i_detdelv-erdat t_cust-crdat
                  i_detdelv-matnr
                  ls_char-doqty ls_char-doval

                  ls_char-lead1q ls_char-lead1v
                  ls_char-lead2q ls_char-lead2v
                  ls_char-lead3q ls_char-lead3v
                  ls_char-unqty ls_char-unval
      INTO ls_download
      SEPARATED BY '|'.

      CLEAR lv_tabix.

      DO 20 TIMES.
        lv_tabix = sy-index.
        CLEAR: lv_fieldnm,ls_char-qty.
        UNASSIGN <fs_dfield>.

        CONCATENATE 'I_OUTPUT1-QTY' lv_tabix INTO lv_fieldnm.
        ASSIGN (lv_fieldnm) TO <fs_dfield>.
        IF <fs_dfield> IS INITIAL.
          CONCATENATE ls_download '|' '0' INTO ls_download.
        ELSE.
          PERFORM f_unit_convert USING <fs_dfield> ''
                                 CHANGING ls_char-qty.
          CONCATENATE ls_download '|' ls_char-qty INTO ls_download.
        ENDIF.

        CLEAR: lv_fieldnm,ls_char-val.
        UNASSIGN <fs_dfield>.

        CONCATENATE 'I_OUTPUT1-VAL' lv_tabix INTO lv_fieldnm.
        ASSIGN (lv_fieldnm) TO <fs_dfield>.
        IF <fs_dfield> IS INITIAL.
          CONCATENATE ls_download '|' '0.00' INTO ls_download.
        ELSE.
          PERFORM f_curr_convert USING <fs_dfield> ''
                                 CHANGING ls_char-val.
          CONCATENATE ls_download '|' ls_char-val INTO ls_download.
        ENDIF.
      ENDDO.

      APPEND ls_download TO lt_download.
      CLEAR : ls_download, ls_char.
    ENDLOOP.

    CALL METHOD zcl_util=>m_delete_file
      EXPORTING
        param_name = lv_path.

    CALL METHOD zcl_util=>m_download_dataset
      EXPORTING
        param_name = lv_path
        pti_data   = lt_download[].

    CONCATENATE 'chmod 666' lv_path INTO lv_command SEPARATED BY space.
    CALL 'SYSTEM' ID 'COMMAND' FIELD lv_command
                  ID 'TAB' FIELD tabl-*sys*.

  ENDIF.
ENDFORM.                    " F_DOWNLOAD

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERT
*&---------------------------------------------------------------------*
FORM f_unit_convert  USING    fu_value fu_meins
                     CHANGING fc_value.
  CLEAR fc_value.
  WRITE fu_value TO fc_value DECIMALS 0.
  TRANSLATE fc_value USING '. '.
  TRANSLATE fc_value USING ',.'.
  CONDENSE fc_value NO-GAPS.
ENDFORM.                    " F_UNIT_CONVERT

*&---------------------------------------------------------------------*
*&      Form  F_CURR_CONVERT
*&---------------------------------------------------------------------*
FORM f_curr_convert  USING    fu_value fu_curr
                     CHANGING fc_value.
  CLEAR fc_value.
  WRITE fu_value TO fc_value.
  TRANSLATE fc_value USING '. '.
  TRANSLATE fc_value USING ',.'.
  CONDENSE fc_value NO-GAPS.
ENDFORM.                    " F_CURR_CONVERT
