************************************************************************
*                                                                      *
*  PROGRAM NAME  :  ZS_MONITOR_SALES_TO_PAYMENT_NW ( REPORT )          *
*  PROGRAM DESC  :  SERVICE LEVEL                                      *
*  CREATED BY    :  Budi Pramono                                       *
*  CREATED ON    :  02/07/2007 (DD/MM/YY)                              *
*  VERSION       :  7.00                                               *
*                                                                      *
************************************************************************
*                                                                      *
*  MODIFICATION LOG :                                                  *
*                                                                      *
*  DATE        PROGRAMMER   CORRECTION  DESCRIPTION                    *
*  ----------  -----------  ----------  -----------------------------  *
*  XX/XX/XXXX  XXXXXX         XXXX      XXXXXXXXXXXXXXXXXX             *
*                                                                      *
************************************************************************
REPORT zs_monitor_sales_to_payment_nw MESSAGE-ID zs
                                      NO STANDARD PAGE HEADING.

INCLUDE zghsdalv001.  "ALV
INCLUDE zghsdtop008.  "TOP
INCLUDE zghsdalvf08.  "Form ALV

****************************************************
*        SELECTION-SCREEN                          *
****************************************************
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_path(52) LOWER CASE NO-DISPLAY.
PARAMETERS: p_kkber LIKE vbak-kkber DEFAULT '8000' NO-DISPLAY,
            p_vkorg LIKE vbak-vkorg DEFAULT '8020' MODIF ID 001.
*            p_spmon LIKE zsl_monitor-spmon DEFAULT sy-datum(6)
*                                           OBLIGATORY.
SELECT-OPTIONS: s_kkber FOR vbak-kkber NO-DISPLAY,
                s_vkbur FOR vbak-vkbur OBLIGATORY MEMORY ID vkb,
                s_augru FOR vbak-augru DEFAULT 'A19' MODIF ID aug,
                s_kdgrp FOR knvv-kdgrp,
                s_kvgr2 FOR vbak-kvgr2 MODIF ID 003,
                s_knkli FOR vbak-knkli MODIF ID 002,
                s_auart FOR vbak-auart NO INTERVALS MODIF ID 001,
                s_qtno  FOR vbak-vbeln MODIF ID 002,
                s_qtdat FOR vbak-erdat OBLIGATORY MEMORY ID erd,
                s_bstnk FOR vbak-bstnk MODIF ID 002,
                s_bstdk FOR vbak-bstdk MODIF ID 011,
                s_sono  FOR vbak-vbeln MODIF ID 002,
                s_sodat FOR vbak-erdat MODIF ID 012,
                s_dono  FOR likp-vbeln MODIF ID 002,
                s_dodat FOR likp-erdat MODIF ID 013,
                s_pkdat FOR likp-kodat MODIF ID 002,
                s_gidat FOR likp-kodat MODIF ID 014,
                s_cusdat FOR likp-kodat MODIF ID 015,
                s_poddat FOR likp-kodat MODIF ID 016,
                s_fkdat FOR likp-kodat MODIF ID 002,
                s_pydat FOR likp-kodat MODIF ID 002,
                s_matkl FOR vbap-matkl MODIF ID 004,
                s_xcusr FOR zsextrec-crdat MODIF ID 017,
                s_subhub FOR knvv-vkbur MODIF ID 999.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio1 RADIOBUTTON GROUP grp1
                                  DEFAULT 'X' USER-COMMAND grp1.
SELECTION-SCREEN : COMMENT (70) TEXT-021 FOR FIELD p_radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (70) TEXT-022 FOR FIELD p_radio2.
SELECTION-SCREEN POSITION 73.
PARAMETERS : p_matkl AS CHECKBOX.
SELECTION-SCREEN COMMENT (20) TEXT-028 FOR FIELD p_matkl.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (70) TEXT-023 FOR FIELD p_radio3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (70) TEXT-024 FOR FIELD p_radio4.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (70) TEXT-025 FOR FIELD p_radio5.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio6 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (70) TEXT-026 FOR FIELD p_radio6.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio7 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (70) TEXT-027 FOR FIELD p_radio7.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio8 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (70) TEXT-029 FOR FIELD p_radio8.
SELECTION-SCREEN POSITION 73.
PARAMETERS : p_slk AS CHECKBOX.
SELECTION-SCREEN COMMENT (20) TEXT-030 FOR FIELD p_slk.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio9 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (70) TEXT-031 FOR FIELD p_radio9.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF BLOCK block3 WITH FRAME TITLE TEXT-003.
PARAMETERS: p_vari  LIKE disvariant-variant. " ALV Variant
SELECTION-SCREEN END OF BLOCK block3.

************************************************************************
* AT SELECTION-SCREEN
************************************************************************
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = '001'.
      screen-input = '0'.
    ENDIF.
    IF p_radio1 = 'X'.
      IF screen-group1 = '003' OR
         screen-group1 = '004' OR
         screen-group1 = 'AUG' OR
         screen-group1 = '017'.
        screen-active = '0'.
      ENDIF.
    ELSEIF p_radio2 = 'X'.
      IF screen-group1 = '002' OR
         screen-group1 = '012' OR
         screen-group1 = '013' OR
         screen-group1 = '014' OR
         screen-group1 = '016' OR
         screen-group1 = 'AUG' OR
         screen-group1 = '017'.
        screen-active = '0'.
      ENDIF.
    ELSEIF p_radio3 = 'X'.
      IF screen-group1 = '002' OR
         screen-group1 = '013' OR
         screen-group1 = '014' OR
         screen-group1 = '015' OR
         screen-group1 = '016' OR
         screen-group1 = '004' OR
         screen-group1 = 'AUG' OR
         screen-group1 = '017'.
        screen-active = '0'.
      ENDIF.
    ELSEIF p_radio4 = 'X'.
      IF screen-group1 = '002' OR
         screen-group1 = '011' OR
         screen-group1 = '014' OR
         screen-group1 = '015' OR
         screen-group1 = '016' OR
         screen-group1 = '004' OR
         screen-group1 = 'AUG' OR
         screen-group1 = '017'.
        screen-active = '0'.
      ENDIF.
    ELSEIF p_radio5 = 'X'.
      IF screen-group1 = '002' OR
         screen-group1 = '011' OR
         screen-group1 = '012' OR
         screen-group1 = '015' OR
         screen-group1 = '016' OR
         screen-group1 = '004' OR
         screen-group1 = 'AUG' OR
         screen-group1 = '017'.
        screen-active = '0'.
      ENDIF.
    ELSEIF p_radio6 = 'X'.
      IF screen-group1 = '002' OR
         screen-group1 = '011' OR
         screen-group1 = '012' OR
         screen-group1 = '013' OR
         screen-group1 = '016' OR
         screen-group1 = '004' OR
         screen-group1 = 'AUG' OR
         screen-group1 = '017'.
        screen-active = '0'.
      ENDIF.
    ELSEIF p_radio7 = 'X'.
      IF screen-group1 = '002' OR
         screen-group1 = '011' OR
         screen-group1 = '012' OR
         screen-group1 = '013' OR
         screen-group1 = '014' OR
         screen-group1 = '004' OR
         screen-group1 = 'AUG' OR
         screen-group1 = '017'.
        screen-active = '0'.
      ENDIF.
    ELSEIF p_radio8 = 'X'.
      IF screen-group1 = '002' OR
         screen-group1 = '004' OR
         screen-group1 = '012' OR
         screen-group1 = '013' OR
         screen-group1 = '014' OR
         screen-group1 = '016' OR
         screen-group1 = 'AUG' OR
         screen-group1 = '999'.
        screen-active = '0'.
      ENDIF.
    ELSEIF p_radio9 = 'X'.
      IF screen-group1 = '002' OR
         screen-group1 = '003' OR
         screen-group1 = '004' OR
         screen-group1 = '014' OR
         screen-group1 = '015' OR
         screen-group1 = '016' OR
         screen-group1 = '017' OR
         screen-group1 = '999'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
* for alv variant
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f_f4_for_variant_alv USING p_vari.

*****************************************************
*        INITIALIZATION                             *
*****************************************************
INITIALIZATION.
  IF sy-opsys = 'AIX'.
    p_path = '/interface/SLS-CASH/'.
  ELSE.
    p_path = '\\tdsdev01\interface\SLS-CASH\'.
  ENDIF.

  s_qtdat-sign = 'I'.
  s_qtdat-option = 'BT'.
  CONCATENATE sy-datum(6) '01' INTO s_qtdat-low.
  s_qtdat-high = sy-datum.
  APPEND s_qtdat.

  SELECT SINGLE parva
    FROM usr05
    INTO p_vkorg
    WHERE bname EQ sy-uname AND
          parid EQ 'VKO'.

  SELECT SINGLE parva
    FROM usr05
    INTO s_vkbur-low
    WHERE bname EQ sy-uname AND
          parid EQ 'VKB'.
  APPEND s_vkbur.

  IF p_vkorg EQ '8070'.
    SELECT SINGLE parva
      FROM usr05
      INTO s_auart-low
      WHERE bname EQ sy-uname AND
            parid EQ 'AAT'.
    s_auart-sign = 'I'.
    s_auart-option = 'CP'.
    APPEND s_auart.
  ELSE.
    s_auart-sign = 'I'.
    s_auart-option = 'CP'.
    s_auart-low = 'ZQ*'.
    APPEND s_auart.
    s_auart-sign = 'I'.
    s_auart-option = 'EQ'.
    s_auart-low = 'ZO2O'.
    APPEND s_auart.
  ENDIF.

  IF p_vkorg EQ '8070'.
    s_kkber-sign = 'I'.
    s_kkber-option = 'EQ'.
    s_kkber-low = '8070'.
    APPEND s_kkber.
  ELSE.
    s_kkber-sign = 'I'.
    s_kkber-option = 'EQ'.
    s_kkber-low = '8000'.
    APPEND s_kkber.
    s_kkber-sign = 'I'.
    s_kkber-option = 'EQ'.
    s_kkber-low = '8020'.
    APPEND s_kkber.
  ENDIF.

*****************************************************
*        START-OF-SELECTION                         *
*****************************************************
START-OF-SELECTION.

  PERFORM validate.
  PERFORM get_general_data.
  PERFORM process_general_data.
  PERFORM f_modify_itab_monitor.  "For SlOff T2* only

  CASE 'X'.
    WHEN p_radio1 OR p_radio9.
      PERFORM get_data1.
      PERFORM process_data1.
      PERFORM f_add_field.
      IF p_radio9 = 'X'.
        PERFORM f_process_data9.
      ENDIF.
    WHEN p_radio2.
      PERFORM get_data2.
      PERFORM process_data2.
    WHEN p_radio3.
      PERFORM get_data3.
      PERFORM process_data3.
    WHEN p_radio4.
      PERFORM get_data4.
      PERFORM process_data4.
    WHEN p_radio5.
      PERFORM get_data5.
      PERFORM process_data5.
    WHEN p_radio6.
      PERFORM get_data6.
      PERFORM process_data6.
    WHEN p_radio7.
      PERFORM get_data7.
      PERFORM process_data7.
    WHEN p_radio8.
      PERFORM get_data8.
      PERFORM process_data8.
  ENDCASE.

  PERFORM f_subhub_selection.

  PERFORM print_data.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  validate
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate.
  DATA : lt_vkbur LIKE tvkbt OCCURS 0 WITH HEADER LINE.

  SELECT * FROM tvkbt
    INTO TABLE lt_vkbur
    WHERE spras = 'EN' AND
          vkbur IN s_vkbur.

** Check authorization vkbur
  LOOP AT lt_vkbur.
    AUTHORITY-CHECK OBJECT 'V_VBKA_VKO'
        ID 'VKBUR' FIELD lt_vkbur-vkbur.
    IF sy-subrc NE 0.
      MESSAGE i000(zs) WITH 'You are not authorized with Sales Office'
                             lt_vkbur-vkbur.
      STOP.
    ENDIF.
  ENDLOOP.

** Check entry date
  CASE 'X'.
    WHEN p_radio2.
      IF s_bstdk[] IS INITIAL.
        MESSAGE i000(zs) WITH 'PO date must be entry'.
        STOP.
      ENDIF.
    WHEN p_radio3.
      IF s_bstdk[] IS INITIAL.
        MESSAGE i000(zs) WITH 'PO date must be entry'.
        STOP.
      ENDIF.
    WHEN p_radio4.
      IF s_sodat[] IS INITIAL.
        MESSAGE i000(zs) WITH 'SO date must be entry'.
        STOP.
      ENDIF.
    WHEN p_radio5.
      IF s_dodat[] IS INITIAL.
        MESSAGE i000(zs) WITH 'DO date must be entry'.
        STOP.
      ENDIF.
    WHEN p_radio6.
      IF s_gidat[] IS INITIAL.
        MESSAGE i000(zs) WITH 'GI date must be entry'.
        STOP.
      ENDIF.
    WHEN p_radio7.
      IF s_cusdat[] IS INITIAL.
        MESSAGE i000(zs) WITH 'CR date must be entry'.
        STOP.
      ENDIF.
  ENDCASE.

** Check Material Group
  IF s_matkl[] IS NOT INITIAL AND p_matkl IS INITIAL.
    MESSAGE i000(zs) WITH 'Please check list material group'.
    STOP.
  ENDIF.

ENDFORM.                    " validate

*&---------------------------------------------------------------------*
*&      Form  get_data1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data1.

*** Select Data Monitoring ***
*  SELECT *
*    FROM zsl_monitor
*    INTO CORRESPONDING FIELDS OF TABLE i_monitor
*    WHERE spmon EQ p_spmon AND
*          vkbur IN s_vkbur AND
*          kdgrp IN s_kdgrp AND
*          knkli IN s_knkli AND
*          qtno  IN s_qtno  AND
*          qtdat IN s_qtdat AND
*          auart IN s_auart AND
*          bstnk IN s_bstnk AND
*          bstdk IN s_bstdk AND
*          sono  IN s_sono  AND
*          sodat IN s_sodat AND
*          dono  IN s_dono  AND
*          dodat IN s_dodat AND
*          pkdat IN s_pkdat AND
*          gidat IN s_gidat AND
*          podat IN s_poddat.

*  IF sy-subrc NE 0.
*    PERFORM get_data_textfile.
*    DELETE i_monitor WHERE NOT spmon EQ p_spmon.
*    DELETE i_monitor WHERE NOT vkbur IN s_vkbur.
*    DELETE i_monitor WHERE NOT kdgrp IN s_kdgrp.
*    DELETE i_monitor WHERE NOT knkli IN s_knkli.
*    DELETE i_monitor WHERE NOT qtno  IN s_qtno.
*    DELETE i_monitor WHERE NOT qtdat IN s_qtdat.
*    DELETE i_monitor WHERE NOT auart IN s_auart.
*    DELETE i_monitor WHERE NOT bstnk IN s_bstnk.
*    DELETE i_monitor WHERE NOT bstdk IN s_bstdk.
*    DELETE i_monitor WHERE NOT sono  IN s_sono.
*    DELETE i_monitor WHERE NOT sodat IN s_sodat.
*    DELETE i_monitor WHERE NOT dono  IN s_dono.
*    DELETE i_monitor WHERE NOT dodat IN s_dodat.
*    DELETE i_monitor WHERE NOT pkdat IN s_pkdat.
*    DELETE i_monitor WHERE NOT gidat IN s_gidat.
*    DELETE i_monitor WHERE NOT podat IN s_poddat.
*  ENDIF.

  CHECK NOT i_monitor[] IS INITIAL.

  SELECT DISTINCT vbeln posnr bstkd bstdk
    INTO CORRESPONDING FIELDS OF TABLE i_vbkd
    FROM vbkd FOR ALL ENTRIES IN i_monitor
    WHERE vbeln = i_monitor-sono.

  SELECT vbeln abrvw
    INTO CORRESPONDING FIELDS OF TABLE i_vbak
    FROM vbak FOR ALL ENTRIES IN i_monitor
    WHERE vbeln = i_monitor-sono.

*** Select Customer ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE knkli = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT kunnr name1 name2 ort01
      FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE i_kna1
      FOR ALL ENTRIES IN i_monitortmp
      WHERE kunnr = i_monitortmp-knkli.
  ENDIF.

*** Select Cust Received ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE dono = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT vbeln crdat crtim
      FROM zmm_cust_rec
      INTO CORRESPONDING FIELDS OF TABLE i_custrec
      FOR ALL ENTRIES IN i_monitortmp
      WHERE vbeln = i_monitortmp-dono AND
            crdat IN s_cusdat.
  ENDIF.

*** Select POD ***
*  SELECT vbeln podat potim
*    FROM likp
*    INTO CORRESPONDING FIELDS OF TABLE i_pod
*    FOR ALL ENTRIES IN i_monitor
*    WHERE vbeln =  i_monitor-dono.

*** Select Faktur Pajak ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE zuonr = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT zuonr vatdt vattm repdt reptm dudat
      FROM zfvato
      INTO CORRESPONDING FIELDS OF TABLE i_vato
      FOR ALL ENTRIES IN i_monitortmp
      WHERE vkorg =  p_vkorg   AND
*            vtart =  'SD'      AND
            vtart IN ('SD','DN') AND
            vkbur IN s_vkbur   AND
            zuonr =  i_monitortmp-zuonr.
  ENDIF.

*** Select Shipment ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE vttno = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT a~tknum a~tplst a~signi a~exti1 a~ernam a~erdat a~erzet a~add04 a~datbg
      b~tpnum b~vbeln
      FROM vttk AS a JOIN vttp AS b ON a~tknum = b~tknum
      INTO CORRESPONDING FIELDS OF TABLE i_vttp
      FOR ALL ENTRIES IN i_monitortmp
      WHERE vbeln = i_monitortmp-vttno.
  ENDIF.

*** Select Payment ***
  IF i_inv[] IS NOT INITIAL.
    IF i_monitor[] IS NOT INITIAL.
      CLEAR i_monitortmp. REFRESH i_monitortmp.
      i_monitortmp[] = i_monitor[].
      DELETE i_monitortmp WHERE zuonr = space.
      IF i_monitortmp[] IS NOT INITIAL.
        SELECT zuonr budat cpudt augdt wrbtr belnr
          FROM bsad
          INTO CORRESPONDING FIELDS OF TABLE i_bsad
          FOR ALL ENTRIES IN i_monitortmp
          WHERE bukrs EQ p_vkorg        AND
                kunnr EQ i_monitortmp-knkli AND
                zuonr EQ i_monitortmp-zuonr AND
                blart EQ 'DZ'         AND
                cpudt IN s_pydat.
        IF sy-subrc = 0.
*        SELECT a~bukrs a~vkbur a~bbeln a~bidat ebelp vbeln
*               gjahr zuonr fkdat kunnr bflag ptype tglttf
*          FROM zfbih AS a JOIN zfbid AS b ON a~bukrs = b~bukrs AND
*                                             a~vkbur = b~vkbur AND
*                                             a~bbeln = b~bbeln
*          INTO CORRESPONDING FIELDS OF TABLE i_zfbi
*          FOR ALL ENTRIES IN i_bsad
*          WHERE a~bukrs EQ p_vkorg    AND
*                a~vkbur IN s_vkbur    AND
*                zuonr EQ i_bsad-zuonr." AND
**                bflag NE 'D'.
        ENDIF.
        SELECT a~bukrs a~vkbur a~bbeln a~bidat ebelp vbeln
               gjahr zuonr fkdat kunnr bflag ptype tglttf
          FROM zfbih AS a JOIN zfbid AS b ON a~bukrs = b~bukrs AND
                                             a~vkbur = b~vkbur AND
                                             a~bbeln = b~bbeln
          INTO CORRESPONDING FIELDS OF TABLE i_zfbi
          FOR ALL ENTRIES IN i_monitortmp
          WHERE a~bukrs EQ p_vkorg    AND
                a~vkbur IN s_vkbur    AND
                zuonr EQ i_monitortmp-zuonr.
*                bflag NE 'D'.

        SELECT a~bukrs a~vkbur a~bbeln a~bidat ebelp vbeln
               gjahr zuonr fkdat kunnr bflag ptype tglttf
          FROM zfbih_sfa AS a JOIN zfbid_sfa AS b ON a~bukrs = b~bukrs AND
                                             a~vkbur = b~vkbur AND
                                             a~bbeln = b~bbeln
          APPENDING CORRESPONDING FIELDS OF TABLE i_zfbi
          FOR ALL ENTRIES IN i_monitortmp
          WHERE a~bukrs EQ p_vkorg    AND
                a~vkbur IN s_vkbur    AND
                zuonr EQ i_monitortmp-zuonr.

      ENDIF.
    ENDIF.

*    SELECT zuonr budat cpudt wrbtr
*      FROM bsad
*      INTO CORRESPONDING FIELDS OF TABLE i_bsad
*      FOR ALL ENTRIES IN i_inv
*      WHERE bukrs EQ p_vkorg        AND
*            belnr EQ i_inv-vbeln    AND
*            gjahr EQ i_inv-erdat(4) AND
*            blart EQ 'DZ'           AND
*            cpudt EQ i_inv-erdat    AND
*            budat IN s_pydat.
**    WHERE kunnr EQ i_monitor-knkli AND
**          bukrs EQ p_vkorg      AND
**          blart EQ 'DZ'         AND
**          zuonr EQ i_monitor-zuonr AND
**          budat IN s_pydat.
  ENDIF.

  SORT i_custrec BY vbeln.
*  SORT i_pod BY vbeln.
  SORT i_vato BY zuonr.
  SORT i_vttp BY vbeln.
  SORT i_bsad BY zuonr cpudt DESCENDING.
  SORT i_zfbi BY zuonr bbeln.

ENDFORM.                                                    " get_data1

*&---------------------------------------------------------------------*
*&      Form  get_data2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data2.

*** Select Data Monitoring ***
*  SELECT *
*    FROM zsl_monitor
*    INTO CORRESPONDING FIELDS OF TABLE i_monitor
*    WHERE spmon EQ p_spmon AND
*          vkbur IN s_vkbur AND
*          kvgr2 IN s_kvgr2 AND
*          kdgrp IN s_kdgrp AND
*          auart IN s_auart AND
*          bstdk IN s_bstdk.

*  IF sy-subrc NE 0.
*    PERFORM get_data_textfile.
*    DELETE i_monitor WHERE NOT spmon EQ p_spmon.
*    DELETE i_monitor WHERE NOT vkbur IN s_vkbur.
*    DELETE i_monitor WHERE NOT kvgr2 IN s_kvgr2.
*    DELETE i_monitor WHERE NOT kdgrp IN s_kdgrp.
*    DELETE i_monitor WHERE NOT auart IN s_auart.
*    DELETE i_monitor WHERE NOT bstdk IN s_bstdk.
*  ENDIF.

  CHECK NOT i_monitor[] IS INITIAL.

*** Select Customer ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE knkli = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT kunnr name1 name2 ort01 katr1
      FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE i_kna1
      FOR ALL ENTRIES IN i_monitortmp
      WHERE kunnr = i_monitortmp-knkli.
  ENDIF.

*** Select Cust Received ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE dono = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT vbeln crdat crtim
      FROM zmm_cust_rec
      INTO CORRESPONDING FIELDS OF TABLE i_custrec
      FOR ALL ENTRIES IN i_monitortmp
      WHERE vbeln =  i_monitortmp-dono AND
            crdat IN s_cusdat.
  ENDIF.

*** Select POD ***
*  SELECT vbeln podat potim
*    FROM likp
*    INTO CORRESPONDING FIELDS OF TABLE i_pod
*    FOR ALL ENTRIES IN i_monitor
*    WHERE vbeln =  i_monitor-dono.

*** Select Faktur Pajak ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE zuonr = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT zuonr vatdt vattm repdt reptm dudat
      FROM zfvato
      INTO CORRESPONDING FIELDS OF TABLE i_vato
      FOR ALL ENTRIES IN i_monitortmp
      WHERE vkorg =  p_vkorg         AND
*            vtart =  'SD'            AND
            vtart IN ('SD','DN')     AND
            vkbur IN s_vkbur         AND
            zuonr =  i_monitortmp-zuonr.
  ENDIF.

*** Select Payment ***
  IF i_inv[] IS NOT INITIAL.
    IF i_monitor[] IS NOT INITIAL.
      CLEAR i_monitortmp. REFRESH i_monitortmp.
      i_monitortmp[] = i_monitor[].
      DELETE i_monitortmp WHERE zuonr = space.
      IF i_monitortmp[] IS NOT INITIAL.
        SELECT zuonr budat cpudt wrbtr augdt belnr
          FROM bsad
          INTO CORRESPONDING FIELDS OF TABLE i_bsad
          FOR ALL ENTRIES IN i_monitortmp
          WHERE bukrs EQ p_vkorg        AND
                kunnr EQ i_monitortmp-knkli AND
                zuonr EQ i_monitortmp-zuonr AND
                blart EQ 'DZ'         AND
                cpudt IN s_pydat.
      ENDIF.

*** Select Shipment ***
      SELECT a~tknum a~tplst a~signi a~exti1 a~ernam a~erdat a~erzet a~add04 a~datbg
        b~tpnum b~vbeln
        FROM vttk AS a JOIN vttp AS b ON a~tknum = b~tknum
        INTO CORRESPONDING FIELDS OF TABLE i_vttp
        FOR ALL ENTRIES IN i_monitor
        WHERE vbeln = i_monitor-vttno.
    ENDIF.

    IF i_monitortmp[] IS NOT INITIAL.
      SELECT a~bukrs a~vkbur a~bbeln a~bidat ebelp vbeln
             gjahr zuonr fkdat kunnr bflag ptype tglttf
        FROM zfbih AS a JOIN zfbid AS b ON a~bukrs = b~bukrs AND
                                           a~vkbur = b~vkbur AND
                                           a~bbeln = b~bbeln
        INTO CORRESPONDING FIELDS OF TABLE i_zfbi
        FOR ALL ENTRIES IN i_monitortmp
        WHERE a~bukrs EQ p_vkorg    AND
              a~vkbur IN s_vkbur    AND
              zuonr EQ i_monitortmp-zuonr.

      SELECT a~bukrs a~vkbur a~bbeln a~bidat ebelp vbeln
             gjahr zuonr fkdat kunnr bflag ptype tglttf
        FROM zfbih_sfa AS a JOIN zfbid_sfa AS b ON a~bukrs = b~bukrs AND
                                           a~vkbur = b~vkbur AND
                                           a~bbeln = b~bbeln
        APPENDING CORRESPONDING FIELDS OF TABLE i_zfbi
        FOR ALL ENTRIES IN i_monitortmp
        WHERE a~bukrs EQ p_vkorg    AND
              a~vkbur IN s_vkbur    AND
              zuonr EQ i_monitortmp-zuonr.
*                  bflag NE 'D'.
    ENDIF.

*    SELECT zuonr budat cpudt wrbtr
*      FROM bsad
*      INTO CORRESPONDING FIELDS OF TABLE i_bsad
*      FOR ALL ENTRIES IN i_inv
*      WHERE bukrs EQ p_vkorg        AND
*            belnr EQ i_inv-vbeln    AND
*            gjahr EQ i_inv-erdat(4) AND
*            blart EQ 'DZ'           AND
*            cpudt EQ i_inv-erdat    AND
*            budat IN s_pydat.
**    WHERE kunnr EQ i_monitor-knkli AND
**          bukrs EQ p_vkorg         AND
**          blart EQ 'DZ'            AND
**          zuonr EQ i_monitor-zuonr.
  ENDIF.

*** Select group outlet ***
  SELECT * FROM tvv2t INTO TABLE i_tvv2t
    FOR ALL ENTRIES IN i_monitor
    WHERE spras = 'EN'             AND
          kvgr2 = i_monitor-kvgr2.

*** Select cust group ***
  SELECT * FROM t151t INTO TABLE i_t151t
    FOR ALL ENTRIES IN i_monitor
    WHERE spras = 'EN'             AND
          kdgrp = i_monitor-kdgrp.

  SORT i_custrec BY vbeln.
*  SORT i_pod BY vbeln.
  SORT i_vato BY zuonr.
  SORT i_bsad BY zuonr cpudt DESCENDING.

ENDFORM.                                                    " get_data2

*&---------------------------------------------------------------------*
*&      Form  get_data3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data3.

*** Select Data Monitoring ***
*  SELECT *
*    FROM zsl_monitor
*    INTO CORRESPONDING FIELDS OF TABLE i_monitor
*    WHERE spmon EQ p_spmon AND
*          vkbur IN s_vkbur AND
*          kvgr2 IN s_kvgr2 AND
*          kdgrp IN s_kdgrp AND
*          auart IN s_auart AND
*          bstdk IN s_bstdk AND
*          sodat IN s_sodat.

*  IF sy-subrc NE 0.
*    PERFORM get_data_textfile.
*    DELETE i_monitor WHERE NOT spmon EQ p_spmon.
*    DELETE i_monitor WHERE NOT vkbur IN s_vkbur.
*    DELETE i_monitor WHERE NOT kvgr2 IN s_kvgr2.
*    DELETE i_monitor WHERE NOT kdgrp IN s_kdgrp.
*    DELETE i_monitor WHERE NOT auart IN s_auart.
*    DELETE i_monitor WHERE NOT bstdk IN s_bstdk.
*    DELETE i_monitor WHERE NOT sodat IN s_sodat.
*  ENDIF.

  CHECK NOT i_monitor[] IS INITIAL.

*** Select Customer ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE knkli = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT kunnr name1 name2 ort01 katr1
      FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE i_kna1
      FOR ALL ENTRIES IN i_monitortmp
      WHERE kunnr = i_monitortmp-knkli.
  ENDIF.

*** Select Cust Received ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE dono = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT vbeln crdat crtim
      FROM zmm_cust_rec
      INTO CORRESPONDING FIELDS OF TABLE i_custrec
      FOR ALL ENTRIES IN i_monitortmp
      WHERE vbeln =  i_monitortmp-dono.
  ENDIF.

*** Select POD ***
*  SELECT vbeln podat potim
*    FROM likp
*    INTO CORRESPONDING FIELDS OF TABLE i_pod
*    FOR ALL ENTRIES IN i_monitor
*    WHERE vbeln =  i_monitor-dono.

*** Select Faktur Pajak ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE zuonr = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT zuonr vatdt vattm repdt reptm dudat
      FROM zfvato
      INTO CORRESPONDING FIELDS OF TABLE i_vato
      FOR ALL ENTRIES IN i_monitortmp
      WHERE vkorg =  p_vkorg   AND
*            vtart =  'SD'      AND
            vtart IN ('SD','DN') AND
            vkbur IN s_vkbur   AND
            zuonr =  i_monitortmp-zuonr.
  ENDIF.

*** Select Payment ***
  IF i_inv[] IS NOT INITIAL.

    IF i_monitor[] IS NOT INITIAL.
      CLEAR i_monitortmp. REFRESH i_monitortmp.
      i_monitortmp[] = i_monitor[].
      DELETE i_monitortmp WHERE zuonr = space.
      IF i_monitortmp[] IS NOT INITIAL.
        SELECT zuonr budat cpudt wrbtr augdt belnr
          FROM bsad
          INTO CORRESPONDING FIELDS OF TABLE i_bsad
          FOR ALL ENTRIES IN i_monitortmp
          WHERE bukrs EQ p_vkorg        AND
                kunnr EQ i_monitortmp-knkli AND
                zuonr EQ i_monitortmp-zuonr AND
                blart EQ 'DZ'         AND
                cpudt IN s_pydat.
      ENDIF.
    ENDIF.

*** Select Shipment ***
    CLEAR i_monitortmp. REFRESH i_monitortmp.
    i_monitortmp[] = i_monitor[].
    DELETE i_monitortmp WHERE vttno = space.
    IF i_monitortmp[] IS NOT INITIAL.
      SELECT a~tknum a~tplst a~signi a~exti1 a~ernam a~erdat a~erzet a~add04 a~datbg
        b~tpnum b~vbeln
        FROM vttk AS a JOIN vttp AS b ON a~tknum = b~tknum
        INTO CORRESPONDING FIELDS OF TABLE i_vttp
        FOR ALL ENTRIES IN i_monitortmp
        WHERE vbeln = i_monitortmp-vttno.
    ENDIF.

    CLEAR i_monitortmp. REFRESH i_monitortmp.
    i_monitortmp[] = i_monitor[].
    DELETE i_monitortmp WHERE zuonr = space.
    IF i_monitortmp[] IS NOT INITIAL.
      SELECT a~bukrs a~vkbur a~bbeln a~bidat ebelp vbeln
             gjahr zuonr fkdat kunnr bflag ptype tglttf
        FROM zfbih AS a JOIN zfbid AS b ON a~bukrs = b~bukrs AND
                                           a~vkbur = b~vkbur AND
                                           a~bbeln = b~bbeln
        INTO CORRESPONDING FIELDS OF TABLE i_zfbi
        FOR ALL ENTRIES IN i_monitortmp
        WHERE a~bukrs EQ p_vkorg    AND
              a~vkbur IN s_vkbur    AND
              zuonr EQ i_monitortmp-zuonr.
*                  bflag NE 'D'.
      SELECT a~bukrs a~vkbur a~bbeln a~bidat ebelp vbeln
             gjahr zuonr fkdat kunnr bflag ptype tglttf
        FROM zfbih_sfa AS a JOIN zfbid_sfa AS b ON a~bukrs = b~bukrs AND
                                           a~vkbur = b~vkbur AND
                                           a~bbeln = b~bbeln
        APPENDING CORRESPONDING FIELDS OF TABLE i_zfbi
        FOR ALL ENTRIES IN i_monitortmp
        WHERE a~bukrs EQ p_vkorg    AND
              a~vkbur IN s_vkbur    AND
              zuonr EQ i_monitortmp-zuonr.
    ENDIF.

*    SELECT zuonr budat cpudt wrbtr
*      FROM bsad
*      INTO CORRESPONDING FIELDS OF TABLE i_bsad
*      FOR ALL ENTRIES IN i_inv
*      WHERE bukrs EQ p_vkorg        AND
*            belnr EQ i_inv-vbeln    AND
*            gjahr EQ i_inv-erdat(4) AND
*            blart EQ 'DZ'           AND
*            cpudt EQ i_inv-erdat    AND
*            budat IN s_pydat.
**    WHERE kunnr EQ i_monitor-knkli AND
**          bukrs EQ p_vkorg         AND
**          blart EQ 'DZ'            AND
**          zuonr EQ i_monitor-zuonr.
  ENDIF.

*** Select group outlet ***
  SELECT * FROM tvv2t INTO TABLE i_tvv2t
    FOR ALL ENTRIES IN i_monitor
    WHERE spras = 'EN'           AND
          kvgr2 = i_monitor-kvgr2.

*** Select cust group ***
  SELECT * FROM t151t INTO TABLE i_t151t
    FOR ALL ENTRIES IN i_monitor
    WHERE spras = 'EN'           AND
          kdgrp = i_monitor-kdgrp.

  SORT i_custrec BY vbeln.
*  SORT i_pod BY vbeln.
  SORT i_vato BY zuonr.
  SORT i_bsad BY zuonr cpudt DESCENDING.

ENDFORM.                                                    " get_data3

*&---------------------------------------------------------------------*
*&      Form  get_data4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data4.

*** Select Data Monitoring ***
*  SELECT *
*    FROM zsl_monitor
*    INTO CORRESPONDING FIELDS OF TABLE i_monitor
*    WHERE spmon EQ p_spmon AND
*          vkbur IN s_vkbur AND
*          kvgr2 IN s_kvgr2 AND
*          kdgrp IN s_kdgrp AND
*          auart IN s_auart AND
*          sodat IN s_sodat AND
*          dodat IN s_dodat.

*  IF sy-subrc NE 0.
*    PERFORM get_data_textfile.
*    DELETE i_monitor WHERE NOT spmon EQ p_spmon.
*    DELETE i_monitor WHERE NOT vkbur IN s_vkbur.
*    DELETE i_monitor WHERE NOT kvgr2 IN s_kvgr2.
*    DELETE i_monitor WHERE NOT kdgrp IN s_kdgrp.
*    DELETE i_monitor WHERE NOT auart IN s_auart.
*    DELETE i_monitor WHERE NOT sodat IN s_sodat.
*    DELETE i_monitor WHERE NOT dodat IN s_dodat.
*  ENDIF.

  CHECK NOT i_monitor[] IS INITIAL.

*** Select Customer ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE knkli = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT kunnr name1 name2 ort01 katr1
      FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE i_kna1
      FOR ALL ENTRIES IN i_monitortmp
      WHERE kunnr = i_monitortmp-knkli.
  ENDIF.

*** Select Cust Received ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE dono = space.
  IF  i_monitortmp[] IS NOT INITIAL.
    SELECT vbeln crdat crtim
      FROM zmm_cust_rec
      INTO CORRESPONDING FIELDS OF TABLE i_custrec
      FOR ALL ENTRIES IN i_monitortmp
      WHERE vbeln =  i_monitortmp-dono.
  ENDIF.

*** Select POD ***
*  SELECT vbeln podat potim
*    FROM likp
*    INTO CORRESPONDING FIELDS OF TABLE i_pod
*    FOR ALL ENTRIES IN i_monitor
*    WHERE vbeln =  i_monitor-dono.

*** Select Faktur Pajak ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE zuonr = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT zuonr vatdt vattm repdt reptm dudat
      FROM zfvato
      INTO CORRESPONDING FIELDS OF TABLE i_vato
      FOR ALL ENTRIES IN i_monitortmp
      WHERE vkorg =  p_vkorg   AND
*            vtart =  'SD'      AND
            vtart IN ('SD','DN') AND
            vkbur IN s_vkbur   AND
            zuonr =  i_monitortmp-zuonr.
  ENDIF.

*** Select Payment ***
  IF i_inv[] IS NOT INITIAL.
    IF i_monitor[] IS NOT INITIAL.
      CLEAR i_monitortmp. REFRESH i_monitortmp.
      i_monitortmp[] = i_monitor[].
      DELETE i_monitortmp WHERE zuonr = space.
      IF i_monitortmp[] IS NOT INITIAL.
        SELECT zuonr budat cpudt wrbtr augdt belnr
          FROM bsad
          INTO CORRESPONDING FIELDS OF TABLE i_bsad
          FOR ALL ENTRIES IN i_monitortmp
          WHERE bukrs EQ p_vkorg        AND
                kunnr EQ i_monitortmp-knkli AND
                zuonr EQ i_monitortmp-zuonr AND
                blart EQ 'DZ'         AND
                cpudt IN s_pydat.
      ENDIF.
    ENDIF.

*** Select Shipment ***
    CLEAR i_monitortmp. REFRESH i_monitortmp.
    i_monitortmp[] = i_monitor[].
    DELETE i_monitortmp WHERE vttno = space.
    IF i_monitortmp[] IS NOT INITIAL.
      SELECT a~tknum a~tplst a~signi a~exti1 a~ernam a~erdat a~erzet a~add04 a~datbg
        b~tpnum b~vbeln
        FROM vttk AS a JOIN vttp AS b ON a~tknum = b~tknum
        INTO CORRESPONDING FIELDS OF TABLE i_vttp
        FOR ALL ENTRIES IN i_monitortmp
        WHERE vbeln = i_monitortmp-vttno.
    ENDIF.

    CLEAR i_monitortmp. REFRESH i_monitortmp.
    i_monitortmp[] = i_monitor[].
    DELETE i_monitortmp WHERE zuonr = space.
    IF i_monitortmp[] IS NOT INITIAL.
      SELECT a~bukrs a~vkbur a~bbeln a~bidat ebelp vbeln
             gjahr zuonr fkdat kunnr bflag ptype tglttf
        FROM zfbih AS a JOIN zfbid AS b ON a~bukrs = b~bukrs AND
                                           a~vkbur = b~vkbur AND
                                           a~bbeln = b~bbeln
        INTO CORRESPONDING FIELDS OF TABLE i_zfbi
        FOR ALL ENTRIES IN i_monitortmp
        WHERE a~bukrs EQ p_vkorg    AND
              a~vkbur IN s_vkbur    AND
              zuonr EQ i_monitortmp-zuonr.
*                  bflag NE 'D'.

      SELECT a~bukrs a~vkbur a~bbeln a~bidat ebelp vbeln
             gjahr zuonr fkdat kunnr bflag ptype tglttf
        FROM zfbih_sfa AS a JOIN zfbid_sfa AS b ON a~bukrs = b~bukrs AND
                                           a~vkbur = b~vkbur AND
                                           a~bbeln = b~bbeln
        APPENDING CORRESPONDING FIELDS OF TABLE i_zfbi
        FOR ALL ENTRIES IN i_monitortmp
        WHERE a~bukrs EQ p_vkorg    AND
              a~vkbur IN s_vkbur    AND
              zuonr EQ i_monitortmp-zuonr.

    ENDIF.

*    SELECT zuonr budat cpudt wrbtr
*      FROM bsad
*      INTO CORRESPONDING FIELDS OF TABLE i_bsad
*      FOR ALL ENTRIES IN i_inv
*      WHERE bukrs EQ p_vkorg        AND
*            belnr EQ i_inv-vbeln    AND
*            gjahr EQ i_inv-erdat(4) AND
*            blart EQ 'DZ'           AND
*            cpudt EQ i_inv-erdat    AND
*            budat IN s_pydat.
**    WHERE kunnr EQ i_monitor-knkli AND
**          bukrs EQ p_vkorg         AND
**          blart EQ 'DZ'            AND
**          zuonr EQ i_monitor-zuonr.
  ENDIF.

*** Select group outlet ***
  SELECT * FROM tvv2t INTO TABLE i_tvv2t
    FOR ALL ENTRIES IN i_monitor
    WHERE spras = 'EN'           AND
          kvgr2 = i_monitor-kvgr2.

*** Select cust group ***
  SELECT * FROM t151t INTO TABLE i_t151t
    FOR ALL ENTRIES IN i_monitor
    WHERE spras = 'EN'           AND
          kdgrp = i_monitor-kdgrp.

  SORT i_custrec BY vbeln.
*  SORT i_pod BY vbeln.
  SORT i_vato BY zuonr.
  SORT i_bsad BY zuonr cpudt DESCENDING.

ENDFORM.                                                    " get_data4

*&---------------------------------------------------------------------*
*&      Form  get_data5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data5.

*** Select Data Monitoring ***
*  SELECT *
*    FROM zsl_monitor
*    INTO CORRESPONDING FIELDS OF TABLE i_monitor
*    WHERE spmon EQ p_spmon AND
*          vkbur IN s_vkbur AND
*          kvgr2 IN s_kvgr2 AND
*          kdgrp IN s_kdgrp AND
*          auart IN s_auart AND
*          dodat IN s_dodat AND
*          gidat IN s_gidat.

*  IF sy-subrc NE 0.
*    PERFORM get_data_textfile.
*    DELETE i_monitor WHERE NOT spmon EQ p_spmon.
*    DELETE i_monitor WHERE NOT vkbur IN s_vkbur.
*    DELETE i_monitor WHERE NOT kvgr2 IN s_kvgr2.
*    DELETE i_monitor WHERE NOT kdgrp IN s_kdgrp.
*    DELETE i_monitor WHERE NOT auart IN s_auart.
*    DELETE i_monitor WHERE NOT dodat IN s_dodat.
*    DELETE i_monitor WHERE NOT gidat IN s_gidat.
*  ENDIF.

  CHECK NOT i_monitor[] IS INITIAL.

*** Select Customer ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE knkli = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT kunnr name1 name2 ort01 katr1
      FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE i_kna1
      FOR ALL ENTRIES IN i_monitortmp
      WHERE kunnr = i_monitortmp-knkli.
  ENDIF.

*** Select Cust Received ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE dono = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT vbeln crdat crtim
      FROM zmm_cust_rec
      INTO CORRESPONDING FIELDS OF TABLE i_custrec
      FOR ALL ENTRIES IN i_monitortmp
      WHERE vbeln =  i_monitortmp-dono.
  ENDIF.

*** Select POD ***
*  SELECT vbeln podat potim
*    FROM likp
*    INTO CORRESPONDING FIELDS OF TABLE i_pod
*    FOR ALL ENTRIES IN i_monitor
*    WHERE vbeln =  i_monitor-dono.

*** Select Faktur Pajak ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE zuonr = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT zuonr vatdt vattm repdt reptm dudat
      FROM zfvato
      INTO CORRESPONDING FIELDS OF TABLE i_vato
      FOR ALL ENTRIES IN i_monitortmp
      WHERE vkorg =  p_vkorg   AND
*            vtart =  'SD'      AND
            vtart IN ('SD','DN') AND
            vkbur IN s_vkbur   AND
            zuonr =  i_monitortmp-zuonr.
  ENDIF.

*** Select Payment ***
  IF i_inv[] IS NOT INITIAL.

    IF i_monitor[] IS NOT INITIAL.
      CLEAR i_monitortmp. REFRESH i_monitortmp.
      i_monitortmp[] = i_monitor[].
      DELETE i_monitortmp WHERE zuonr = space.
      IF i_monitortmp[] IS NOT INITIAL.
        SELECT zuonr budat cpudt wrbtr augdt belnr
          FROM bsad
          INTO CORRESPONDING FIELDS OF TABLE i_bsad
          FOR ALL ENTRIES IN i_monitortmp
          WHERE bukrs EQ p_vkorg        AND
                kunnr EQ i_monitortmp-knkli AND
                zuonr EQ i_monitortmp-zuonr AND
                blart EQ 'DZ'         AND
                cpudt IN s_pydat.
      ENDIF.
    ENDIF.

*** Select Shipment ***
    CLEAR i_monitortmp. REFRESH i_monitortmp.
    i_monitortmp[] = i_monitor[].
    DELETE i_monitortmp WHERE vttno = space.
    IF i_monitortmp[] IS NOT INITIAL.
      SELECT a~tknum a~tplst a~signi a~exti1 a~ernam a~erdat a~erzet a~add04 a~datbg
        b~tpnum b~vbeln
        FROM vttk AS a JOIN vttp AS b ON a~tknum = b~tknum
        INTO CORRESPONDING FIELDS OF TABLE i_vttp
        FOR ALL ENTRIES IN i_monitortmp
        WHERE vbeln = i_monitortmp-vttno.
    ENDIF.

    CLEAR i_monitortmp. REFRESH i_monitortmp.
    i_monitortmp[] = i_monitor[].
    DELETE i_monitortmp WHERE zuonr = space.
    IF i_monitortmp[] IS NOT INITIAL.
      SELECT a~bukrs a~vkbur a~bbeln a~bidat ebelp vbeln
             gjahr zuonr fkdat kunnr bflag ptype tglttf
        FROM zfbih AS a JOIN zfbid AS b ON a~bukrs = b~bukrs AND
                                           a~vkbur = b~vkbur AND
                                           a~bbeln = b~bbeln
        INTO CORRESPONDING FIELDS OF TABLE i_zfbi
        FOR ALL ENTRIES IN i_monitortmp
        WHERE a~bukrs EQ p_vkorg    AND
              a~vkbur IN s_vkbur    AND
              zuonr EQ i_monitortmp-zuonr.
*                  bflag NE 'D'.
      SELECT a~bukrs a~vkbur a~bbeln a~bidat ebelp vbeln
             gjahr zuonr fkdat kunnr bflag ptype tglttf
        FROM zfbih_sfa AS a JOIN zfbid_sfa AS b ON a~bukrs = b~bukrs AND
                                           a~vkbur = b~vkbur AND
                                           a~bbeln = b~bbeln
        APPENDING CORRESPONDING FIELDS OF TABLE i_zfbi
        FOR ALL ENTRIES IN i_monitortmp
        WHERE a~bukrs EQ p_vkorg    AND
              a~vkbur IN s_vkbur    AND
              zuonr EQ i_monitortmp-zuonr.
    ENDIF.

*    SELECT zuonr budat cpudt wrbtr
*      FROM bsad
*      INTO CORRESPONDING FIELDS OF TABLE i_bsad
*      FOR ALL ENTRIES IN i_inv
*      WHERE bukrs EQ p_vkorg        AND
*            belnr EQ i_inv-vbeln    AND
*            gjahr EQ i_inv-erdat(4) AND
*            blart EQ 'DZ'           AND
*            cpudt EQ i_inv-erdat    AND
*            budat IN s_pydat.
**    WHERE kunnr EQ i_monitor-knkli AND
**          bukrs EQ p_vkorg         AND
**          blart EQ 'DZ'            AND
**          zuonr EQ i_monitor-zuonr.
  ENDIF.

*** Select group outlet ***
  SELECT * FROM tvv2t INTO TABLE i_tvv2t
    FOR ALL ENTRIES IN i_monitor
    WHERE spras = 'EN'           AND
          kvgr2 = i_monitor-kvgr2.

*** Select cust group ***
  SELECT * FROM t151t INTO TABLE i_t151t
    FOR ALL ENTRIES IN i_monitor
    WHERE spras = 'EN'           AND
          kdgrp = i_monitor-kdgrp.

  SORT i_custrec BY vbeln.
*  SORT i_pod BY vbeln.
  SORT i_vato BY zuonr.
  SORT i_bsad BY zuonr cpudt DESCENDING.

ENDFORM.                                                    " get_data5

*&---------------------------------------------------------------------*
*&      Form  get_data6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data6.

*** Select Data Monitoring ***
*  SELECT *
*    FROM zsl_monitor
*    INTO CORRESPONDING FIELDS OF TABLE i_monitor
*    WHERE spmon EQ p_spmon AND
*          vkbur IN s_vkbur AND
*          kvgr2 IN s_kvgr2 AND
*          kdgrp IN s_kdgrp AND
*          auart IN s_auart AND
*          gidat IN s_gidat.

*  IF sy-subrc NE 0.
*    PERFORM get_data_textfile.
*    DELETE i_monitor WHERE NOT spmon EQ p_spmon.
*    DELETE i_monitor WHERE NOT vkbur IN s_vkbur.
*    DELETE i_monitor WHERE NOT kvgr2 IN s_kvgr2.
*    DELETE i_monitor WHERE NOT kdgrp IN s_kdgrp.
*    DELETE i_monitor WHERE NOT auart IN s_auart.
*    DELETE i_monitor WHERE NOT gidat IN s_gidat.
*  ENDIF.

  CHECK NOT i_monitor[] IS INITIAL.

*** Select Customer ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE knkli = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT kunnr name1 name2 ort01 katr1
      FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE i_kna1
      FOR ALL ENTRIES IN i_monitortmp
      WHERE kunnr = i_monitortmp-knkli.
  ENDIF.

*** Select Cust Received ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE dono = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT vbeln crdat crtim
      FROM zmm_cust_rec
      INTO CORRESPONDING FIELDS OF TABLE i_custrec
      FOR ALL ENTRIES IN i_monitortmp
      WHERE vbeln =  i_monitortmp-dono AND
            crdat IN s_cusdat.
  ENDIF.

*** Select POD ***
*  SELECT vbeln podat potim
*    FROM likp
*    INTO CORRESPONDING FIELDS OF TABLE i_pod
*    FOR ALL ENTRIES IN i_monitor
*    WHERE vbeln =  i_monitor-dono.

*** Select Faktur Pajak ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE zuonr = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT zuonr vatdt vattm repdt reptm dudat
      FROM zfvato
      INTO CORRESPONDING FIELDS OF TABLE i_vato
      FOR ALL ENTRIES IN i_monitortmp
      WHERE vkorg =  p_vkorg   AND
*            vtart =  'SD'      AND
            vtart IN ('SD','DN') AND
            vkbur IN s_vkbur   AND
            zuonr =  i_monitortmp-zuonr.
  ENDIF.

*** Select Payment ***
  IF i_inv[] IS NOT INITIAL.
    IF i_monitor[] IS NOT INITIAL.
      CLEAR i_monitortmp. REFRESH i_monitortmp.
      i_monitortmp[] = i_monitor[].
      DELETE i_monitortmp WHERE zuonr = space.
      IF i_monitortmp[] IS NOT INITIAL.
        SELECT zuonr budat cpudt wrbtr augdt belnr
          FROM bsad
          INTO CORRESPONDING FIELDS OF TABLE i_bsad
          FOR ALL ENTRIES IN i_monitortmp
          WHERE bukrs EQ p_vkorg        AND
                kunnr EQ i_monitortmp-knkli AND
                zuonr EQ i_monitortmp-zuonr AND
                blart EQ 'DZ'         AND
                cpudt IN s_pydat.
      ENDIF.
    ENDIF.

*** Select Shipment ***
    CLEAR i_monitortmp. REFRESH i_monitortmp.
    i_monitortmp[] = i_monitor[].
    DELETE i_monitortmp WHERE vttno = space.
    IF i_monitortmp[] IS NOT INITIAL.
      SELECT a~tknum a~tplst a~signi a~exti1 a~ernam a~erdat a~erzet a~add04 a~datbg
        b~tpnum b~vbeln
        FROM vttk AS a JOIN vttp AS b ON a~tknum = b~tknum
        INTO CORRESPONDING FIELDS OF TABLE i_vttp
        FOR ALL ENTRIES IN i_monitortmp
        WHERE vbeln = i_monitortmp-vttno.
    ENDIF.

    CLEAR i_monitortmp. REFRESH i_monitortmp.
    i_monitortmp[] = i_monitor[].
    DELETE i_monitortmp WHERE zuonr = space.
    IF i_monitortmp[] IS NOT INITIAL.
      SELECT a~bukrs a~vkbur a~bbeln a~bidat ebelp vbeln
             gjahr zuonr fkdat kunnr bflag ptype tglttf
        FROM zfbih AS a JOIN zfbid AS b ON a~bukrs = b~bukrs AND
                                           a~vkbur = b~vkbur AND
                                           a~bbeln = b~bbeln
        INTO CORRESPONDING FIELDS OF TABLE i_zfbi
        FOR ALL ENTRIES IN i_monitortmp
        WHERE a~bukrs EQ p_vkorg    AND
              a~vkbur IN s_vkbur    AND
              zuonr EQ i_monitortmp-zuonr.
*                  bflag NE 'D'.
      SELECT a~bukrs a~vkbur a~bbeln a~bidat ebelp vbeln
             gjahr zuonr fkdat kunnr bflag ptype tglttf
        FROM zfbih_sfa AS a JOIN zfbid_sfa AS b ON a~bukrs = b~bukrs AND
                                           a~vkbur = b~vkbur AND
                                           a~bbeln = b~bbeln
        APPENDING CORRESPONDING FIELDS OF TABLE i_zfbi
        FOR ALL ENTRIES IN i_monitortmp
        WHERE a~bukrs EQ p_vkorg    AND
              a~vkbur IN s_vkbur    AND
              zuonr EQ i_monitortmp-zuonr.
    ENDIF.

*    SELECT zuonr budat cpudt wrbtr
*      FROM bsad
*      INTO CORRESPONDING FIELDS OF TABLE i_bsad
*      FOR ALL ENTRIES IN i_inv
*      WHERE bukrs EQ p_vkorg        AND
*            belnr EQ i_inv-vbeln    AND
*            gjahr EQ i_inv-erdat(4) AND
*            blart EQ 'DZ'           AND
*            cpudt EQ i_inv-erdat    AND
*            budat IN s_pydat.
**    WHERE kunnr EQ i_monitor-knkli AND
**          bukrs EQ p_vkorg         AND
**          blart EQ 'DZ'            AND
**          zuonr EQ i_monitor-zuonr.
  ENDIF.

*** Select group outlet ***
  SELECT * FROM tvv2t INTO TABLE i_tvv2t
    FOR ALL ENTRIES IN i_monitor
    WHERE spras = 'EN'           AND
          kvgr2 = i_monitor-kvgr2.

*** Select cust group ***
  SELECT * FROM t151t INTO TABLE i_t151t
    FOR ALL ENTRIES IN i_monitor
    WHERE spras = 'EN'           AND
          kdgrp = i_monitor-kdgrp.

  SORT i_custrec BY vbeln.
*  SORT i_pod BY vbeln.
  SORT i_vato BY zuonr.
  SORT i_bsad BY zuonr cpudt DESCENDING.

ENDFORM.                                                    " get_data6

*&---------------------------------------------------------------------*
*&      Form  get_data7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data7.

*** Select Data Monitoring ***
*  SELECT *
*    FROM zsl_monitor
*    INTO CORRESPONDING FIELDS OF TABLE i_monitor
*    WHERE spmon EQ p_spmon AND
*          vkbur IN s_vkbur AND
*          kvgr2 IN s_kvgr2 AND
*          kdgrp IN s_kdgrp AND
*          auart IN s_auart AND
*          podat IN s_poddat.

*  IF sy-subrc NE 0.
*    PERFORM get_data_textfile.
*    DELETE i_monitor WHERE NOT spmon EQ p_spmon.
*    DELETE i_monitor WHERE NOT vkbur IN s_vkbur.
*    DELETE i_monitor WHERE NOT kvgr2 IN s_kvgr2.
*    DELETE i_monitor WHERE NOT kdgrp IN s_kdgrp.
*    DELETE i_monitor WHERE NOT auart IN s_auart.
*    DELETE i_monitor WHERE NOT podat IN s_poddat.
*  ENDIF.

  CHECK NOT i_monitor[] IS INITIAL.

*** Select Customer ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE knkli = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT kunnr name1 name2 ort01 katr1
      FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE i_kna1
      FOR ALL ENTRIES IN i_monitortmp
      WHERE kunnr = i_monitortmp-knkli.
  ENDIF.

*** Select Cust Received ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE dono = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT vbeln crdat crtim
      FROM zmm_cust_rec
      INTO CORRESPONDING FIELDS OF TABLE i_custrec
      FOR ALL ENTRIES IN i_monitortmp
      WHERE vbeln =  i_monitortmp-dono.
  ENDIF.

*** Select POD ***
*  SELECT vbeln podat potim
*    FROM likp
*    INTO CORRESPONDING FIELDS OF TABLE i_pod
*    FOR ALL ENTRIES IN i_monitor
*    WHERE vbeln =  i_monitor-dono.

*** Select Faktur Pajak ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE zuonr = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT zuonr vatdt vattm repdt reptm dudat
      FROM zfvato
      INTO CORRESPONDING FIELDS OF TABLE i_vato
      FOR ALL ENTRIES IN i_monitortmp
      WHERE vkorg =  p_vkorg   AND
*            vtart =  'SD'      AND
            vtart IN ('SD','DN') AND
            vkbur IN s_vkbur   AND
            zuonr =  i_monitortmp-zuonr.
  ENDIF.

*** Select Payment ***
  IF i_inv[] IS NOT INITIAL.
    IF i_monitor[] IS NOT INITIAL.
      CLEAR i_monitortmp. REFRESH i_monitortmp.
      i_monitortmp[] = i_monitor[].
      DELETE i_monitortmp WHERE zuonr = space.
      IF i_monitortmp[] IS NOT INITIAL.
        SELECT zuonr budat cpudt wrbtr augdt belnr
          FROM bsad
          INTO CORRESPONDING FIELDS OF TABLE i_bsad
          FOR ALL ENTRIES IN i_monitortmp
          WHERE bukrs EQ p_vkorg        AND
                kunnr EQ i_monitortmp-knkli AND
                zuonr EQ i_monitortmp-zuonr AND
                blart EQ 'DZ'         AND
                cpudt IN s_pydat.
      ENDIF.
    ENDIF.

*** Select Shipment ***
    CLEAR i_monitortmp. REFRESH i_monitortmp.
    i_monitortmp[] = i_monitor[].
    DELETE i_monitortmp WHERE vttno = space.
    IF i_monitortmp[] IS NOT INITIAL.
      SELECT a~tknum a~tplst a~signi a~exti1 a~ernam a~erdat a~erzet a~add04 a~datbg
        b~tpnum b~vbeln
        FROM vttk AS a JOIN vttp AS b ON a~tknum = b~tknum
        INTO CORRESPONDING FIELDS OF TABLE i_vttp
        FOR ALL ENTRIES IN i_monitortmp
        WHERE vbeln = i_monitortmp-vttno.
    ENDIF.

    CLEAR i_monitortmp. REFRESH i_monitortmp.
    i_monitortmp[] = i_monitor[].
    DELETE i_monitortmp WHERE zuonr = space.
    IF i_monitortmp[] IS NOT INITIAL.
      SELECT a~bukrs a~vkbur a~bbeln a~bidat ebelp vbeln
             gjahr zuonr fkdat kunnr bflag ptype tglttf
        FROM zfbih AS a JOIN zfbid AS b ON a~bukrs = b~bukrs AND
                                           a~vkbur = b~vkbur AND
                                           a~bbeln = b~bbeln
        INTO CORRESPONDING FIELDS OF TABLE i_zfbi
        FOR ALL ENTRIES IN i_monitortmp
        WHERE a~bukrs EQ p_vkorg    AND
              a~vkbur IN s_vkbur    AND
              zuonr EQ i_monitortmp-zuonr.
*                  bflag NE 'D'.
      SELECT a~bukrs a~vkbur a~bbeln a~bidat ebelp vbeln
             gjahr zuonr fkdat kunnr bflag ptype tglttf
        FROM zfbih_sfa AS a JOIN zfbid_sfa AS b ON a~bukrs = b~bukrs AND
                                           a~vkbur = b~vkbur AND
                                           a~bbeln = b~bbeln
        APPENDING CORRESPONDING FIELDS OF TABLE i_zfbi
        FOR ALL ENTRIES IN i_monitortmp
        WHERE a~bukrs EQ p_vkorg    AND
              a~vkbur IN s_vkbur    AND
              zuonr EQ i_monitortmp-zuonr.

    ENDIF.

*    SELECT zuonr budat cpudt wrbtr
*      FROM bsad
*      INTO CORRESPONDING FIELDS OF TABLE i_bsad
*      FOR ALL ENTRIES IN i_inv
*      WHERE bukrs EQ p_vkorg        AND
*            belnr EQ i_inv-vbeln    AND
*            gjahr EQ i_inv-erdat(4) AND
*            blart EQ 'DZ'           AND
*            cpudt EQ i_inv-erdat    AND
*            budat IN s_pydat.
**    WHERE kunnr EQ i_monitor-knkli AND
**          bukrs EQ p_vkorg         AND
**          blart EQ 'DZ'            AND
**          zuonr EQ i_monitor-zuonr.
  ENDIF.

*** Select group outlet ***
  SELECT * FROM tvv2t INTO TABLE i_tvv2t
    FOR ALL ENTRIES IN i_monitor
    WHERE spras = 'EN'           AND
          kvgr2 = i_monitor-kvgr2.

*** Select cust group ***
  SELECT * FROM t151t INTO TABLE i_t151t
    FOR ALL ENTRIES IN i_monitor
    WHERE spras = 'EN'           AND
          kdgrp = i_monitor-kdgrp.

  SORT i_custrec BY vbeln.
*  SORT i_pod BY vbeln.
  SORT i_vato BY zuonr.
  SORT i_bsad BY zuonr cpudt DESCENDING.

ENDFORM.                                                    " get_data7

*&---------------------------------------------------------------------*
*&      Form  get_data_textfile
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_textfile.

  DATA : l_filename(125) TYPE c.

*  CLEAR itabline. REFRESH itabline.
*  CONCATENATE p_path p_spmon '.txt' INTO l_filename.
*  OPEN DATASET l_filename FOR INPUT IN TEXT MODE.
*  IF sy-subrc EQ 0.
*    DO.
*      READ DATASET l_filename INTO wa_itabline.
*      IF sy-subrc <> 0.
*        EXIT.
*      ENDIF.
*      APPEND wa_itabline TO itabline.
*    ENDDO.
*  ENDIF.
*  CLOSE DATASET l_filename.

*  LOOP AT itabline INTO wa_itabline.
*    wa_dataset = wa_itabline.
*    MOVE-CORRESPONDING wa_dataset TO i_monitor.
*    APPEND i_monitor. CLEAR i_monitor.
*  ENDLOOP.

ENDFORM.                    " get_data_textfile

*&---------------------------------------------------------------------*
*&      Form  process_data1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data1.

  LOOP AT i_monitor.

    CLEAR: i_custrec,i_vato,i_bsad,i_kna1,i_detail,i_pod,i_vttp,i_zfbi.

** Baca customer receipt
    READ TABLE i_custrec WITH KEY vbeln = i_monitor-dono BINARY SEARCH.

** Baca POD
*    READ TABLE i_pod WITH KEY vbeln = i_monitor-dono BINARY SEARCH.

** Baca faktur pajak
    READ TABLE i_vato WITH KEY zuonr = i_monitor-zuonr BINARY SEARCH.

** Baca shipment
    READ TABLE i_vttp WITH KEY vbeln = i_monitor-vttno BINARY SEARCH.

** Baca payment
    CLEAR i_bsad.
    READ TABLE i_bsad WITH KEY zuonr = i_monitor-zuonr.
    i_detail-pydat = i_bsad-cpudt.
    i_detail-augdt = i_bsad-augdt.
    i_detail-belnr = i_bsad-belnr.
*    LOOP AT i_bsad WHERE zuonr = i_monitor-zuonr.
*      IF i_bsad-budat GT i_detail-pydat.
*        i_detail-pydat = i_bsad-budat.
*      ENDIF.
*    ENDLOOP.

** Baca customer name
    READ TABLE i_kna1 WITH KEY kunnr = i_monitor-knkli.

** Baca BI
    LOOP AT i_zfbi WHERE zuonr = i_monitor-zuonr." AND
*                         ptype NE space.
*      IF i_zfbi-tglttf IS NOT INITIAL.
      i_detail-bidat = i_zfbi-bidat.
      i_detail-ptype = i_zfbi-ptype.
      IF i_zfbi-tglttf IS NOT INITIAL AND i_zfbi-tglttf NE '00000000'.
        i_detail-tglttf = i_zfbi-tglttf.
      ENDIF.
*        EXIT.
*      ELSE.
*        IF i_zfbi-bflag NE 'D'.
*          i_detail-bidat = i_zfbi-bidat.
*          i_detail-ptype = i_zfbi-ptype.
*        ENDIF.
*      ENDIF.
    ENDLOOP.

    PERFORM append_data1.

  ENDLOOP.

ENDFORM.                    " process_data1

*&---------------------------------------------------------------------*
*&      Form  process_data2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data2.

  DATA : lt_holiday LIKE iscal_day OCCURS 0,
         l_day      TYPE i,
         l_holiday  TYPE i,
         l_workday  TYPE i.

  LOOP AT i_monitor.

    CLEAR: i_custrec,i_vato,lt_holiday,i_bsad,i_detail,i_kna1,l_day,
           l_holiday,l_workday,i_t151t,i_tvv2t,i_pod.
    REFRESH: lt_holiday.

** Baca customer receipt
    READ TABLE i_custrec WITH KEY vbeln = i_monitor-dono BINARY SEARCH.
*    IF sy-subrc NE 0.
*      CONTINUE.
*    ENDIF.

** Check data
    IF ( i_monitor-bstdk IN s_bstdk AND i_monitor-bstdk NE 0 ) AND
       ( i_custrec-crdat IN s_cusdat AND i_custrec-crdat NE 0 ).
    ELSE.
      CONTINUE.
    ENDIF.

** Baca POD
*    READ TABLE i_pod WITH KEY vbeln = i_monitor-dono BINARY SEARCH.

** Baca faktur pajak
    READ TABLE i_vato WITH KEY zuonr = i_monitor-zuonr BINARY SEARCH.

** Baca payment
    CLEAR i_bsad.
    READ TABLE i_bsad WITH KEY zuonr = i_monitor-zuonr.
    i_detail-pydat = i_bsad-cpudt.
    i_detail-augdt = i_bsad-augdt.
    i_detail-belnr = i_bsad-belnr.
*    LOOP AT i_bsad WHERE zuonr = i_monitor-zuonr.
*      IF i_bsad-budat GT i_detail-pydat.
*        i_detail-pydat = i_bsad-budat.
*      ENDIF.
*    ENDLOOP.

** Baca sales force group
    READ TABLE i_tvv2t WITH KEY kvgr2 = i_monitor-kvgr2.

** Baca customer group
    READ TABLE i_t151t WITH KEY kdgrp = i_monitor-kdgrp.

** Baca customer
    READ TABLE i_kna1 WITH KEY kunnr = i_monitor-knkli.

** Hitung hari kerja.
    CALL FUNCTION 'HOLIDAY_GET'
      EXPORTING
        holiday_calendar           = 'ID'
        factory_calendar           = 'T1'
        date_from                  = i_monitor-bstdk
        date_to                    = i_custrec-crdat
*      IMPORTING
*       YEAR_OF_VALID_FROM         =
*       YEAR_OF_VALID_TO           =
*       RETURNCODE                 =
      TABLES
        holidays                   = lt_holiday
      EXCEPTIONS
        factory_calendar_not_found = 1
        holiday_calendar_not_found = 2
        date_has_invalid_format    = 3
        date_inconsistency         = 4
        OTHERS                     = 5.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    DESCRIBE TABLE lt_holiday LINES l_holiday.
    l_day = i_custrec-crdat - i_monitor-bstdk.
    l_workday = l_day - l_holiday.

    IF l_workday = 0.
      i_detail-cnt01  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_workday = 1.
      i_detail-cnt02  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_workday = 2.
      i_detail-cnt03  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_workday = 3.
      i_detail-cnt04  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_workday = 4.
      i_detail-cnt05  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_workday GT 4.
      i_detail-cnt06  = 1.
      i_detail-cnt10  = 1.
*    ELSE.
*      i_detail-cnt09  = 1.
    ENDIF.
*    i_detail-cnt10  = 1.

    PERFORM f_std_count USING i_monitor-knkli i_custrec-crdat i_monitor-bstdk
                              i_monitor-kdgrp i_kna1-katr1 '' l_workday
                              i_monitor-bzirk i_monitor-vkbur
                        CHANGING i_detail-pocr i_detail-kbetr i_detail-valtg i_detail-coun2
                                 i_detail-coun5 i_detail-coun6.

    PERFORM append_data2.
  ENDLOOP.
  PERFORM f_persen_standart.
ENDFORM.                    " process_data2

*&---------------------------------------------------------------------*
*&      Form  process_data3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data3.

  DATA : lt_holiday  LIKE iscal_day OCCURS 0,
         l_holiday   TYPE i,
         l_erdat     LIKE vbak-erdat,
         l_minutes   TYPE i,
         l_hours(10) TYPE p DECIMALS 2.

  LOOP AT i_monitor.

    CLEAR: i_custrec,i_vato,lt_holiday,i_bsad,i_detail,i_kna1,l_holiday,
           l_erdat,l_minutes,l_hours,i_t151t,i_tvv2t,i_pod.
    REFRESH: lt_holiday.

** Check data
    IF ( i_monitor-bstdk IN s_bstdk AND i_monitor-bstdk NE 0 ) AND
       ( i_monitor-sodat IN s_sodat AND i_monitor-sodat NE 0 ).
    ELSE.
      CONTINUE.
    ENDIF.

** Baca customer receipt
    READ TABLE i_custrec WITH KEY vbeln = i_monitor-dono BINARY SEARCH.

** Baca POD
*    READ TABLE i_pod WITH KEY vbeln = i_monitor-dono BINARY SEARCH.

** Baca faktur pajak
    READ TABLE i_vato WITH KEY zuonr = i_monitor-zuonr BINARY SEARCH.

** Baca payment
    CLEAR i_bsad.
    READ TABLE i_bsad WITH KEY zuonr = i_monitor-zuonr.
    i_detail-pydat = i_bsad-cpudt.
    i_detail-augdt = i_bsad-augdt.
    i_detail-belnr = i_bsad-belnr.
*    LOOP AT i_bsad WHERE zuonr = i_monitor-zuonr.
*      IF i_bsad-budat GT i_detail-pydat.
*        i_detail-pydat = i_bsad-budat.
*      ENDIF.
*    ENDLOOP.

** Baca sales force group
    READ TABLE i_tvv2t WITH KEY kvgr2 = i_monitor-kvgr2.

** Baca customer group
    READ TABLE i_t151t WITH KEY kdgrp = i_monitor-kdgrp.

** Baca customer
    READ TABLE i_kna1 WITH KEY kunnr = i_monitor-knkli.

** Hitung hari kerja.
    CALL FUNCTION 'HOLIDAY_GET'
      EXPORTING
        holiday_calendar           = 'ID'
        factory_calendar           = 'T1'
        date_from                  = i_monitor-bstdk
        date_to                    = i_monitor-sodat
*      IMPORTING
*       YEAR_OF_VALID_FROM         =
*       YEAR_OF_VALID_TO           =
*       RETURNCODE                 =
      TABLES
        holidays                   = lt_holiday
      EXCEPTIONS
        factory_calendar_not_found = 1
        holiday_calendar_not_found = 2
        date_has_invalid_format    = 3
        date_inconsistency         = 4
        OTHERS                     = 5.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    DESCRIBE TABLE lt_holiday LINES l_holiday.
    l_erdat = i_monitor-sodat - l_holiday.

** Hitung selisih menit
    CALL FUNCTION 'DELTA_TIME_DAY_HOUR'
      EXPORTING
        t1      = i_monitor-qttim
        t2      = i_monitor-sotim
        d1      = i_monitor-bstdk
        d2      = l_erdat
      IMPORTING
        minutes = l_minutes.

    l_hours = l_minutes / 60.

    IF l_hours LE 3.
      i_detail-cnt01  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 6.
      i_detail-cnt02  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 12.
      i_detail-cnt03  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 24.
      i_detail-cnt04  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 48.
      i_detail-cnt05  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 72.
      i_detail-cnt06  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours GT 72.
      i_detail-cnt07  = 1.
      i_detail-cnt10  = 1.
*    ELSE.
*      i_detail-cnt09  = 1.
    ENDIF.
*    i_detail-cnt10  = 1.

    PERFORM append_data3.

  ENDLOOP.

ENDFORM.                    " process_data3

*&---------------------------------------------------------------------*
*&      Form  process_data4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data4.

  DATA : lt_holiday  LIKE iscal_day OCCURS 0,
         l_holiday   TYPE i,
         l_erdat     LIKE vbak-erdat,
         l_minutes   TYPE i,
         l_hours(10) TYPE p DECIMALS 2.

  LOOP AT i_monitor.

    CLEAR: i_custrec,i_vato,lt_holiday,i_bsad,i_detail,i_kna1,l_holiday,
           l_erdat,l_minutes,l_hours,i_t151t,i_tvv2t,i_pod.
    REFRESH: lt_holiday.

** Check data
    IF ( i_monitor-sodat IN s_sodat AND i_monitor-sodat NE 0 ) AND
       ( i_monitor-dodat IN s_dodat AND i_monitor-dodat NE 0 ).
    ELSE.
      CONTINUE.
    ENDIF.

** Baca customer receipt
    READ TABLE i_custrec WITH KEY vbeln = i_monitor-dono BINARY SEARCH.

** Baca POD
*    READ TABLE i_pod WITH KEY vbeln = i_monitor-dono BINARY SEARCH.

** Baca faktur pajak
    READ TABLE i_vato WITH KEY zuonr = i_monitor-zuonr BINARY SEARCH.

** Baca payment
    CLEAR i_bsad.
    READ TABLE i_bsad WITH KEY zuonr = i_monitor-zuonr.
    i_detail-pydat = i_bsad-cpudt.
    i_detail-augdt = i_bsad-augdt.
    i_detail-belnr = i_bsad-belnr.
*    LOOP AT i_bsad WHERE zuonr = i_monitor-zuonr.
*      IF i_bsad-budat GT i_detail-pydat.
*        i_detail-pydat = i_bsad-budat.
*      ENDIF.
*    ENDLOOP.

** Baca sales force group
    READ TABLE i_tvv2t WITH KEY kvgr2 = i_monitor-kvgr2.

** Baca customer group
    READ TABLE i_t151t WITH KEY kdgrp = i_monitor-kdgrp.

** Baca customer
    READ TABLE i_kna1 WITH KEY kunnr = i_monitor-knkli.

** Hitung hari kerja.
    CALL FUNCTION 'HOLIDAY_GET'
      EXPORTING
        holiday_calendar           = 'ID'
        factory_calendar           = 'T1'
        date_from                  = i_monitor-sodat
        date_to                    = i_monitor-dodat
*      IMPORTING
*       YEAR_OF_VALID_FROM         =
*       YEAR_OF_VALID_TO           =
*       RETURNCODE                 =
      TABLES
        holidays                   = lt_holiday
      EXCEPTIONS
        factory_calendar_not_found = 1
        holiday_calendar_not_found = 2
        date_has_invalid_format    = 3
        date_inconsistency         = 4
        OTHERS                     = 5.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    DESCRIBE TABLE lt_holiday LINES l_holiday.
    l_erdat = i_monitor-dodat - l_holiday.

** Hitung selisih menit
    CALL FUNCTION 'DELTA_TIME_DAY_HOUR'
      EXPORTING
        t1      = i_monitor-sotim
        t2      = i_monitor-dotim
        d1      = i_monitor-sodat
        d2      = l_erdat
      IMPORTING
        minutes = l_minutes.

** Conversi menit ke jam
    l_hours = l_minutes / 60.

    IF l_hours LE 3.
      i_detail-cnt01  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 6.
      i_detail-cnt02  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 12.
      i_detail-cnt03  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 24.
      i_detail-cnt04  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 48.
      i_detail-cnt05  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 72.
      i_detail-cnt06  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours GT 72.
      i_detail-cnt07  = 1.
      i_detail-cnt10  = 1.
*    ELSE.
*      i_detail-cnt09  = 1.
    ENDIF.
*    i_detail-cnt10  = 1.

    PERFORM append_data3.

  ENDLOOP.

ENDFORM.                    " process_data4

*&---------------------------------------------------------------------*
*&      Form  process_data5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data5.

  DATA : lt_holiday  LIKE iscal_day OCCURS 0,
         l_holiday   TYPE i,
         l_erdat     LIKE vbak-erdat,
         l_minutes   TYPE i,
         l_hours(10) TYPE p DECIMALS 2.

  SORT i_monitor BY knkli.
  LOOP AT i_monitor.

    CLEAR: i_custrec,i_vato,lt_holiday,i_bsad,i_detail,i_kna1,l_holiday,
           l_erdat,l_minutes,l_hours,i_t151t,i_tvv2t,i_pod.
    REFRESH: lt_holiday.

** Check data
    IF ( i_monitor-dodat IN s_dodat AND i_monitor-dodat NE 0 ) AND
       ( i_monitor-gidat IN s_gidat AND i_monitor-gidat NE 0 ).
    ELSE.
      CONTINUE.
    ENDIF.

** Baca customer receipt
    READ TABLE i_custrec WITH KEY vbeln = i_monitor-dono BINARY SEARCH.

** Baca POD
*    READ TABLE i_pod WITH KEY vbeln = i_monitor-dono BINARY SEARCH.

** Baca faktur pajak
    READ TABLE i_vato WITH KEY zuonr = i_monitor-zuonr BINARY SEARCH.

** Baca payment
    CLEAR i_bsad.
    READ TABLE i_bsad WITH KEY zuonr = i_monitor-zuonr.
    i_detail-pydat = i_bsad-cpudt.
    i_detail-augdt = i_bsad-augdt.
    i_detail-belnr = i_bsad-belnr.
*    LOOP AT i_bsad WHERE zuonr = i_monitor-zuonr.
*      IF i_bsad-budat GT i_detail-pydat.
*        i_detail-pydat = i_bsad-budat.
*      ENDIF.
*    ENDLOOP.

** Baca sales force group
    READ TABLE i_tvv2t WITH KEY kvgr2 = i_monitor-kvgr2.

** Baca customer group
    READ TABLE i_t151t WITH KEY kdgrp = i_monitor-kdgrp.

** Baca customer
    READ TABLE i_kna1 WITH KEY kunnr = i_monitor-knkli.

** Hitung hari kerja.
    CALL FUNCTION 'HOLIDAY_GET'
      EXPORTING
        holiday_calendar           = 'ID'
        factory_calendar           = 'T1'
        date_from                  = i_monitor-dodat
        date_to                    = i_monitor-gidat
*      IMPORTING
*       YEAR_OF_VALID_FROM         =
*       YEAR_OF_VALID_TO           =
*       RETURNCODE                 =
      TABLES
        holidays                   = lt_holiday
      EXCEPTIONS
        factory_calendar_not_found = 1
        holiday_calendar_not_found = 2
        date_has_invalid_format    = 3
        date_inconsistency         = 4
        OTHERS                     = 5.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    DESCRIBE TABLE lt_holiday LINES l_holiday.
    l_erdat = i_monitor-gidat - l_holiday.

** Hitung selisih menit
    CALL FUNCTION 'DELTA_TIME_DAY_HOUR'
      EXPORTING
        t1      = i_monitor-dotim
        t2      = i_monitor-gitim
        d1      = i_monitor-dodat
        d2      = l_erdat
      IMPORTING
        minutes = l_minutes.

** Conversi menit ke jam
    l_hours = l_minutes / 60.

    IF l_hours LE 3.
      i_detail-cnt01  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 6.
      i_detail-cnt02  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 12.
      i_detail-cnt03  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 24.
      i_detail-cnt04  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 48.
      i_detail-cnt05  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 72.
      i_detail-cnt06  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours GT 72.
      i_detail-cnt07  = 1.
      i_detail-cnt10  = 1.
*    ELSE.
*      i_detail-cnt09  = 1.
    ENDIF.
*    i_detail-cnt10  = 1.

    PERFORM f_std_count USING i_monitor-knkli i_monitor-dodat i_monitor-gidat
                              i_monitor-kdgrp i_kna1-katr1 l_hours ''
                              i_monitor-bzirk i_monitor-vkbur
                        CHANGING i_detail-pocr i_detail-kbetr i_detail-valtg i_detail-coun2
                                 i_detail-coun5 i_detail-coun6.

    PERFORM append_data3.
  ENDLOOP.
  PERFORM f_persen_standart.
ENDFORM.                    " process_data5

*&---------------------------------------------------------------------*
*&      Form  process_data6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data6.

  DATA : lt_holiday  LIKE iscal_day OCCURS 0,
         l_holiday   TYPE i,
         l_erdat     LIKE vbak-erdat,
         l_minutes   TYPE i,
         l_hours(10) TYPE p DECIMALS 2.

  LOOP AT i_monitor.

    CLEAR: i_custrec,i_vato,lt_holiday,i_bsad,i_detail,i_kna1,l_holiday,
           l_erdat,l_minutes,l_hours,i_t151t,i_tvv2t,i_pod.
    REFRESH: lt_holiday.

** Baca customer receipt
    READ TABLE i_custrec WITH KEY vbeln = i_monitor-dono BINARY SEARCH.
*    IF sy-subrc NE 0.
*      CONTINUE.
*    ENDIF.

** Check data
    IF ( i_monitor-gidat IN s_gidat AND i_monitor-gidat NE 0 ) AND
       ( i_custrec-crdat IN s_cusdat AND i_custrec-crdat NE 0 ).
    ELSE.
      CONTINUE.
    ENDIF.

** Baca POD
*    READ TABLE i_pod WITH KEY vbeln = i_monitor-dono BINARY SEARCH.

** Baca faktur pajak
    READ TABLE i_vato WITH KEY zuonr = i_monitor-zuonr BINARY SEARCH.

** Baca payment
    CLEAR i_bsad.
    READ TABLE i_bsad WITH KEY zuonr = i_monitor-zuonr.
    i_detail-pydat = i_bsad-cpudt.
    i_detail-augdt = i_bsad-augdt.
    i_detail-belnr = i_bsad-belnr.
*    LOOP AT i_bsad WHERE zuonr = i_monitor-zuonr.
*      IF i_bsad-budat GT i_detail-pydat.
*        i_detail-pydat = i_bsad-budat.
*      ENDIF.
*    ENDLOOP.

** Baca sales force group
    READ TABLE i_tvv2t WITH KEY kvgr2 = i_monitor-kvgr2.

** Baca customer group
    READ TABLE i_t151t WITH KEY kdgrp = i_monitor-kdgrp.

** Baca customer
    READ TABLE i_kna1 WITH KEY kunnr = i_monitor-knkli.

** Hitung hari kerja.
    CALL FUNCTION 'HOLIDAY_GET'
      EXPORTING
        holiday_calendar           = 'ID'
        factory_calendar           = 'T1'
        date_from                  = i_monitor-gidat
        date_to                    = i_custrec-crdat
*      IMPORTING
*       YEAR_OF_VALID_FROM         =
*       YEAR_OF_VALID_TO           =
*       RETURNCODE                 =
      TABLES
        holidays                   = lt_holiday
      EXCEPTIONS
        factory_calendar_not_found = 1
        holiday_calendar_not_found = 2
        date_has_invalid_format    = 3
        date_inconsistency         = 4
        OTHERS                     = 5.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    DESCRIBE TABLE lt_holiday LINES l_holiday.
    l_erdat = i_custrec-crdat - l_holiday.

** Hitung selisih menit
    CALL FUNCTION 'DELTA_TIME_DAY_HOUR'
      EXPORTING
        t1      = i_monitor-gitim
        t2      = i_custrec-crtim
        d1      = i_monitor-gidat
        d2      = l_erdat
      IMPORTING
        minutes = l_minutes.

** Conversi menit ke jam
    l_hours = l_minutes / 60.

    IF l_hours LE 3.
      i_detail-cnt01  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 6.
      i_detail-cnt02  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 12.
      i_detail-cnt03  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 24.
      i_detail-cnt04  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 48.
      i_detail-cnt05  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 72.
      i_detail-cnt06  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours GT 72.
      i_detail-cnt07  = 1.
      i_detail-cnt10  = 1.
*    ELSE.
*      i_detail-cnt09  = 1.
    ENDIF.
*    i_detail-cnt10  = 1.

    PERFORM f_std_count USING i_monitor-knkli i_monitor-dodat i_monitor-gidat
                              i_monitor-kdgrp i_kna1-katr1 l_hours ''
                              i_monitor-bzirk i_monitor-vkbur
                        CHANGING i_detail-pocr i_detail-kbetr i_detail-valtg i_detail-coun2
                                 i_detail-coun5 i_detail-coun6.

    PERFORM append_data3.
  ENDLOOP.
  PERFORM f_persen_standart.
ENDFORM.                    " process_data6

*&---------------------------------------------------------------------*
*&      Form  process_data7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data7.

  DATA : lt_holiday  LIKE iscal_day OCCURS 0,
         l_holiday   TYPE i,
         l_erdat     LIKE vbak-erdat,
         l_minutes   TYPE i,
         l_hours(10) TYPE p DECIMALS 2.

  LOOP AT i_monitor.

    CLEAR: i_custrec,i_vato,lt_holiday,i_bsad,i_detail,i_kna1,l_holiday,
           l_erdat,l_minutes,l_hours,i_t151t,i_tvv2t.
    REFRESH: lt_holiday.

** Baca customer receipt
    READ TABLE i_custrec WITH KEY vbeln = i_monitor-dono BINARY SEARCH.
*    IF sy-subrc NE 0.
*      CONTINUE.
*    ENDIF.

** Baca POD
*    READ TABLE i_pod WITH KEY vbeln = i_monitor-dono BINARY SEARCH.
*    IF sy-subrc NE 0.
*      CONTINUE.
*    ENDIF.

** Check data
    IF ( i_custrec-crdat IN s_cusdat AND i_custrec-crdat NE 0 ) AND
       ( i_monitor-podat IN s_poddat AND i_monitor-podat NE 0 ).
    ELSE.
      CONTINUE.
    ENDIF.

** Baca faktur pajak
    READ TABLE i_vato WITH KEY zuonr = i_monitor-zuonr BINARY SEARCH.

** Baca payment
    CLEAR i_bsad.
    READ TABLE i_bsad WITH KEY zuonr = i_monitor-zuonr.
    i_detail-pydat = i_bsad-cpudt.
    i_detail-augdt = i_bsad-augdt.
    i_detail-belnr = i_bsad-belnr.
*    LOOP AT i_bsad WHERE zuonr = i_monitor-zuonr.
*      IF i_bsad-budat GT i_detail-pydat.
*        i_detail-pydat = i_bsad-budat.
*      ENDIF.
*    ENDLOOP.

** Baca sales force group
    READ TABLE i_tvv2t WITH KEY kvgr2 = i_monitor-kvgr2.

** Baca customer group
    READ TABLE i_t151t WITH KEY kdgrp = i_monitor-kdgrp.

** Baca customer
    READ TABLE i_kna1 WITH KEY kunnr = i_monitor-knkli.

** Hitung hari kerja.
    CALL FUNCTION 'HOLIDAY_GET'
      EXPORTING
        holiday_calendar           = 'ID'
        factory_calendar           = 'T1'
        date_from                  = i_custrec-crdat
        date_to                    = i_monitor-podat
*      IMPORTING
*       YEAR_OF_VALID_FROM         =
*       YEAR_OF_VALID_TO           =
*       RETURNCODE                 =
      TABLES
        holidays                   = lt_holiday
      EXCEPTIONS
        factory_calendar_not_found = 1
        holiday_calendar_not_found = 2
        date_has_invalid_format    = 3
        date_inconsistency         = 4
        OTHERS                     = 5.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    DESCRIBE TABLE lt_holiday LINES l_holiday.
    l_erdat = i_monitor-podat - l_holiday.

** Hitung selisih menit
    CALL FUNCTION 'DELTA_TIME_DAY_HOUR'
      EXPORTING
        t1      = i_custrec-crtim
        t2      = i_monitor-potim
        d1      = i_custrec-crdat
        d2      = l_erdat
      IMPORTING
        minutes = l_minutes.

** Conversi menit ke jam
    l_hours = l_minutes / 60.

    IF l_hours LE 3.
      i_detail-cnt01  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 6.
      i_detail-cnt02  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 12.
      i_detail-cnt03  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 24.
      i_detail-cnt04  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 48.
      i_detail-cnt05  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours LE 72.
      i_detail-cnt06  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_hours GT 72.
      i_detail-cnt07  = 1.
      i_detail-cnt10  = 1.
*    ELSE.
*      i_detail-cnt09  = 1.
    ENDIF.
*    i_detail-cnt10  = 1.

    PERFORM append_data3.

  ENDLOOP.
ENDFORM.                    " process_data7

*&---------------------------------------------------------------------*
*&      Form  append_data1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_data1.

  i_detail-vkbur = i_monitor-vkbur.
  i_detail-kdgrp = i_monitor-kdgrp.
  i_detail-knkli = i_monitor-knkli.
  i_detail-name1 = i_kna1-name1.
  i_detail-auart = i_monitor-auart.
  i_detail-bstnk = i_monitor-bstnk.
  i_detail-bstdk = i_monitor-bstdk.
  i_detail-qttim = i_monitor-qttim.
  i_detail-qtno  = i_monitor-qtno.
  i_detail-sono  = i_monitor-sono.
  i_detail-sodat = i_monitor-sodat.
  i_detail-sotim = i_monitor-sotim.
  i_detail-dono  = i_monitor-dono.
  i_detail-dodat = i_monitor-dodat.
  i_detail-dotim = i_monitor-dotim.
  i_detail-crdat = i_custrec-crdat.
  i_detail-crtim = i_custrec-crtim.
  i_detail-podat = i_monitor-podat.
  i_detail-potim = i_monitor-potim.
  i_detail-pkdat = i_monitor-pkdat.
  i_detail-pktim = i_monitor-pktim.
  i_detail-gidat = i_monitor-gidat.
  i_detail-gitim = i_monitor-gitim.
  i_detail-podat = i_monitor-podat.
  i_detail-potim = i_monitor-potim.
  i_detail-kwert = i_monitor-kwert.
  i_detail-waerk = i_monitor-waerk.
  i_detail-rejid = i_monitor-rejid.
  i_detail-bnddt = i_monitor-bnddt.
  i_detail-tknum = i_vttp-tknum.
  i_detail-erdat = i_vttp-erdat.
  i_detail-datbg = i_vttp-datbg.
  IF i_vttp-tplst(2) EQ '05'.
    i_detail-signi = i_vttp-exti1.
  ELSE.
    i_detail-signi = i_vttp-signi.
  ENDIF.
  i_detail-add04  = i_vttp-add04.
  IF i_vato-repdt IS INITIAL.
    i_detail-vatdt = i_vato-vatdt.
    i_detail-vattm = i_vato-vattm.
  ELSE.
    i_detail-vatdt = i_vato-repdt.
    i_detail-vattm = i_vato-reptm.
  ENDIF.
  i_detail-dudat = i_vato-dudat.

** Check waktu POD tidak boleh lebih kecil dari Cust Recp
  IF i_detail-podat LT i_detail-gidat.
    CLEAR: i_detail-podat,i_detail-potim.
  ELSE.
    IF i_detail-podat EQ i_detail-gidat AND
       i_detail-potim LT i_detail-gitim.
      CLEAR: i_detail-podat,i_detail-potim.
    ENDIF.
  ENDIF.

** Check waktu good issue tidak boleh lebih kecil dari Picking
  IF i_detail-gidat LT i_detail-pkdat.
    CLEAR: i_detail-gidat,i_detail-gitim.
  ELSE.
    IF i_detail-gidat EQ i_detail-pkdat AND
       i_detail-gitim LT i_detail-pktim.
      CLEAR: i_detail-gidat,i_detail-gitim.
    ENDIF.
  ENDIF.

  CLEAR: i_vbkd,i_vbak.
  READ TABLE i_vbkd WITH KEY vbeln = i_detail-sono.
  READ TABLE i_vbak WITH KEY vbeln = i_detail-sono.
  i_detail-bstnk = i_vbkd-bstkd.
  i_detail-abrvw = i_vbak-abrvw.

  IF i_detail-rejid = '@0A@'.
    i_detail-objid = i_detail-sono.
  ENDIF.

  IF i_detail-sono IN s_sono AND
     i_detail-sodat IN s_sodat AND
     i_detail-dono IN s_dono AND
     i_detail-dodat IN s_dodat AND
     i_detail-pkdat IN s_pkdat AND
     i_detail-gidat IN s_gidat AND
     i_detail-crdat IN s_cusdat AND
     i_detail-podat IN s_poddat AND
     i_detail-vatdt IN s_fkdat AND
     i_detail-pydat IN s_pydat.
    APPEND i_detail. CLEAR i_detail.
  ENDIF.

ENDFORM.                    " append_data1

*&---------------------------------------------------------------------*
*&      Form  append_data2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_data2.

  i_detail-vkbur = i_monitor-vkbur.
  i_detail-kvgr2 = i_monitor-kvgr2.
  i_detail-bezei = i_tvv2t-bezei.
  i_detail-kdgrp = i_monitor-kdgrp.
  i_detail-ktext = i_t151t-ktext.
  i_detail-katr1 = i_kna1-katr1.
  i_detail-knkli = i_monitor-knkli.
  i_detail-name1 = i_kna1-name1.
  i_detail-auart = i_monitor-auart.
  i_detail-bstnk = i_monitor-bstnk.
  i_detail-bstdk = i_monitor-bstdk.
  i_detail-qtno  = i_monitor-qtno.
  i_detail-qttim = i_monitor-qttim.
  i_detail-sono  = i_monitor-sono.
  i_detail-sodat = i_monitor-sodat.
  i_detail-sotim = i_monitor-sotim.
  i_detail-dono  = i_monitor-dono.
  i_detail-dodat = i_monitor-dodat.
  i_detail-dotim = i_monitor-dotim.
  i_detail-crdat = i_custrec-crdat.
  i_detail-crtim = i_custrec-crtim.
  i_detail-podat = i_monitor-podat.
  i_detail-potim = i_monitor-potim.
  i_detail-pkdat = i_monitor-pkdat.
  i_detail-pktim = i_monitor-pktim.
  i_detail-gidat = i_monitor-gidat.
  i_detail-gitim = i_monitor-gitim.
  i_detail-podat = i_monitor-podat.
  i_detail-potim = i_monitor-potim.
  i_detail-kwert = i_monitor-kwert.
  i_detail-waerk = i_monitor-waerk.
  i_detail-rejid = i_monitor-rejid.
  i_detail-bnddt = i_monitor-bnddt.

  IF i_vato-repdt IS INITIAL.
    i_detail-vatdt = i_vato-vatdt.
    i_detail-vattm = i_vato-vattm.
  ELSE.
    i_detail-vatdt = i_vato-repdt.
    i_detail-vattm = i_vato-reptm.
  ENDIF.
  i_detail-dudat = i_vato-dudat.
  CONCATENATE i_detail-kvgr2 '-' i_detail-bezei INTO i_detail-bezei.

  IF i_detail-kdgrp = 'SB'.
    CLEAR i_detail-bezei.
  ENDIF.

** Baca shipment
  READ TABLE i_vttp WITH KEY vbeln = i_monitor-vttno.
  IF sy-subrc EQ 0.
    i_detail-tknum = i_vttp-tknum.
    i_detail-erdat = i_vttp-erdat.
    i_detail-datbg = i_vttp-datbg.
    IF i_vttp-tplst(2) EQ '05'.
      i_detail-signi = i_vttp-exti1.
    ELSE.
      i_detail-signi = i_vttp-signi.
    ENDIF.
    i_detail-add04  = i_vttp-add04.
  ENDIF.

** Baca BI
  LOOP AT i_zfbi WHERE zuonr = i_monitor-zuonr." AND
    i_detail-bidat = i_zfbi-bidat.
    i_detail-ptype = i_zfbi-ptype.
    IF i_zfbi-tglttf IS NOT INITIAL AND i_zfbi-tglttf NE '00000000'.
      i_detail-tglttf = i_zfbi-tglttf.
    ENDIF.
  ENDLOOP.

  READ TABLE gt_knvv WITH KEY kunnr = i_detail-knkli.
  IF sy-subrc = 0.
    i_detail-vkbur2 = gt_knvv-vkbur.
  ENDIF.

  MOVE-CORRESPONDING i_detail TO i_summary.

  IF i_detail-coun2 IS NOT INITIAL.
    i_summary-stdin  = 1.
    i_detail-stdin  = 1.
  ELSE.
    i_summary-stdout  = 1.
    i_detail-stdout  = 1.
  ENDIF.

  COLLECT i_summary. CLEAR i_summary.
  APPEND i_detail. CLEAR i_detail.

ENDFORM.                    " append_data2

*&---------------------------------------------------------------------*
*&      Form  append_data3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_data3.

  i_detail-vkbur = i_monitor-vkbur.
  i_detail-kvgr2 = i_monitor-kvgr2.
  i_detail-bezei = i_tvv2t-bezei.
  i_detail-kdgrp = i_monitor-kdgrp.
  i_detail-ktext = i_t151t-ktext.
  i_detail-katr1 = i_kna1-katr1.
  i_detail-knkli = i_monitor-knkli.
  i_detail-name1 = i_kna1-name1.
  i_detail-auart = i_monitor-auart.
  i_detail-bstnk = i_monitor-bstnk.
  i_detail-bstdk = i_monitor-bstdk.
  i_detail-qtno  = i_monitor-qtno.
  i_detail-qttim = i_monitor-qttim.
  i_detail-sono  = i_monitor-sono.
  i_detail-sodat = i_monitor-sodat.
  i_detail-sotim = i_monitor-sotim.
  i_detail-dono  = i_monitor-dono.
  i_detail-dodat = i_monitor-dodat.
  i_detail-dotim = i_monitor-dotim.
  i_detail-crdat = i_custrec-crdat.
  i_detail-crtim = i_custrec-crtim.
  i_detail-podat = i_monitor-podat.
  i_detail-potim = i_monitor-potim.
  i_detail-pkdat = i_monitor-pkdat.
  i_detail-pktim = i_monitor-pktim.
  i_detail-gidat = i_monitor-gidat.
  i_detail-gitim = i_monitor-gitim.
  i_detail-podat = i_monitor-podat.
  i_detail-potim = i_monitor-potim.
  i_detail-kwert = i_monitor-kwert.
  i_detail-waerk = i_monitor-waerk.
  i_detail-rejid = i_monitor-rejid.
  i_detail-bnddt = i_monitor-bnddt.

  IF i_vato-repdt IS INITIAL.
    i_detail-vatdt = i_vato-vatdt.
    i_detail-vattm = i_vato-vattm.
  ELSE.
    i_detail-vatdt = i_vato-repdt.
    i_detail-vattm = i_vato-reptm.
  ENDIF.
  i_detail-dudat = i_vato-dudat.
  CONCATENATE i_detail-kvgr2 '-' i_detail-bezei INTO i_detail-bezei.

  IF i_detail-kdgrp = 'SB'.
    CLEAR i_detail-bezei.
  ENDIF.

** Baca shipment
  READ TABLE i_vttp WITH KEY vbeln = i_monitor-vttno.
  IF sy-subrc EQ 0.
    i_detail-tknum = i_vttp-tknum.
    i_detail-erdat = i_vttp-erdat.
    i_detail-datbg = i_vttp-datbg.
    IF i_vttp-tplst(2) EQ '05'.
      i_detail-signi = i_vttp-exti1.
    ELSE.
      i_detail-signi = i_vttp-signi.
    ENDIF.
    i_detail-add04  = i_vttp-add04.
  ENDIF.

** Baca BI
  LOOP AT i_zfbi WHERE zuonr = i_monitor-zuonr." AND
    i_detail-bidat = i_zfbi-bidat.
    i_detail-ptype = i_zfbi-ptype.
    IF i_zfbi-tglttf IS NOT INITIAL AND i_zfbi-tglttf NE '00000000'.
      i_detail-tglttf = i_zfbi-tglttf.
    ENDIF.
  ENDLOOP.

  READ TABLE gt_knvv WITH KEY kunnr = i_detail-knkli.
  IF sy-subrc = 0.
    i_detail-vkbur2 = gt_knvv-vkbur.
  ENDIF.

  MOVE-CORRESPONDING i_detail TO i_summary.

  IF p_radio5 EQ 'X'.
    va_radio5 = 'X'.
    IF i_detail-coun5 IS NOT INITIAL.
      i_summary-stdin  = 1.
      i_detail-stdin  = 1.
    ELSE.
      i_summary-stdout  = 1.
      i_detail-stdout  = 1.
    ENDIF.
  ELSEIF p_radio6 EQ 'X'.
    va_radio6 = 'X'.
    IF i_detail-coun6 IS NOT INITIAL.
      i_summary-stdin  = 1.
      i_detail-stdin  = 1.
    ELSE.
      i_summary-stdout  = 1.
      i_detail-stdout  = 1.
    ENDIF.
  ENDIF.

  COLLECT i_summary. CLEAR i_summary.
  APPEND i_detail. CLEAR i_detail.
ENDFORM.                    " append_data3

*&---------------------------------------------------------------------*
*&      Form  append_data4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_data4.

ENDFORM.                    " append_data4

*&---------------------------------------------------------------------*
*&      Form  append_data5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_data5.

ENDFORM.                    " append_data5

*&---------------------------------------------------------------------*
*&      Form  append_data6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_data6.

ENDFORM.                    " append_data6

*&---------------------------------------------------------------------*
*&      Form  append_data7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_data7.

ENDFORM.                    " append_data7

*&---------------------------------------------------------------------*
*&      Form  print_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_data.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
  PERFORM f_alv_variant_exist USING   p_vari
                                      d_alv_variant.

  IF va_ucomm = '&IC1'.
    CASE 'X'.
      WHEN p_radio2.
        va_radio2 = 'X'.
        va_matkl = p_matkl.
      WHEN p_radio5.
        va_radio5 = 'X'.
      WHEN p_radio6.
        va_radio6 = 'X'.
      WHEN p_radio9.
        va_radio9 = 'X'.
    ENDCASE.
*    IF p_radio5 EQ 'X'.
*      va_radio5 = 'X'.
*    ELSEIF p_radio6 EQ 'X'.
*      va_radio6 = 'X'.
*    ENDIF.
    PERFORM f_build_fieldcat1   TABLES  i_detail1.
    PERFORM f_build_sortfield1  USING   t_alv_isort[].
    PERFORM f_output_alv        TABLES  i_detail1.
  ELSE.
    CASE 'X'.
      WHEN p_radio1.
        va_radio1 = 'X'.
*      WHEN p_radio1 OR p_radio9.
*        IF p_radio1 = 'X'.
*          va_radio1 = 'X'.
*        ELSEIF p_radio9 = 'X'.
*          va_radio9 = 'X'.
*        ENDIF.
        PERFORM f_build_fieldcat1   TABLES  i_detail.
        PERFORM f_build_sortfield1  USING   t_alv_isort[].
        PERFORM f_output_alv        TABLES  i_detail.
      WHEN p_radio2.
        PERFORM f_build_fieldcat2   TABLES  i_summary.
        PERFORM f_build_sortfield2  USING   t_alv_isort[].
        PERFORM f_output_alv        TABLES  i_summary.
      WHEN p_radio3.
        PERFORM f_build_fieldcat3   TABLES  i_summary.
        PERFORM f_build_sortfield2  USING   t_alv_isort[].
        PERFORM f_output_alv        TABLES  i_summary.
      WHEN p_radio4.
        PERFORM f_build_fieldcat3   TABLES  i_summary.
        PERFORM f_build_sortfield2  USING   t_alv_isort[].
        PERFORM f_output_alv        TABLES  i_summary.
      WHEN p_radio5.
        PERFORM f_build_fieldcat3   TABLES  i_summary.
        PERFORM f_build_sortfield2  USING   t_alv_isort[].
        PERFORM f_output_alv        TABLES  i_summary.
      WHEN p_radio6.
        PERFORM f_build_fieldcat3   TABLES  i_summary.
        PERFORM f_build_sortfield2  USING   t_alv_isort[].
        PERFORM f_output_alv        TABLES  i_summary.
      WHEN p_radio7.
        PERFORM f_build_fieldcat3   TABLES  i_summary.
        PERFORM f_build_sortfield2  USING   t_alv_isort[].
        PERFORM f_output_alv        TABLES  i_summary.
      WHEN p_radio8.
        PERFORM f_build_fieldcat8   TABLES  i_summary.
        PERFORM f_build_sortfield8  USING   t_alv_isort[].
        PERFORM f_output_alv        TABLES  i_summary.
      WHEN p_radio9.
        PERFORM f_build_fieldcat9   TABLES  i_summary9.
        PERFORM f_build_sortfield8  USING   t_alv_isort[].
        PERFORM f_output_alv        TABLES  i_summary9.
    ENDCASE.
  ENDIF.

ENDFORM.                    " print_data

*&---------------------------------------------------------------------*
*&      Form  f_f4_for_variant_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_VARI  text
*----------------------------------------------------------------------*
FORM f_f4_for_variant_alv USING fc_variant.

  DATA: ld_variant LIKE disvariant.
  DATA: ld_repid   LIKE sy-repid.
  ld_repid = sy-repid.
  ld_variant-report   = ld_repid.
  ld_variant-username = sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = ld_variant
      i_save     = 'A'
    IMPORTING
      es_variant = ld_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    fc_variant = ld_variant-variant.
  ENDIF.

ENDFORM.                    " f_f4_for_variant_alv

*&---------------------------------------------------------------------*
*&      Form  f_save_to_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_to_table.

ENDFORM.                    " f_save_to_table

*&---------------------------------------------------------------------*
*&      Form  F_HDR_ULINE
*&---------------------------------------------------------------------*
*       Draw underline if flag set
*----------------------------------------------------------------------*
FORM f_hdr_uline.
  IF d_hdr_rpt_lines = 'X'.
    ULINE.
  ENDIF.
ENDFORM.                    " F_HDR_ULINE

*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE1
*&---------------------------------------------------------------------*
*       Header line with report, title and page
*----------------------------------------------------------------------*
FORM f_hdr_line1 USING fu_company.
  DATA:
    page_number(10) VALUE 'Page: nnnn',
    progname(42)    VALUE 'Program: xx',
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

  IF va_count EQ 1.
    fu_company = 'Detail Report'.
  ELSE.
    CASE 'X'.
      WHEN p_radio1.
        fu_company = 'Detail Report'.
      WHEN p_radio2.
        fu_company = 'PO VS Recv ( Mengukur service level )'.
      WHEN p_radio3.
        fu_company = 'PO VS SO ( Mengukur kecepatan salesman & SA )'.
      WHEN p_radio4.
        fu_company =
   'SO VS DO ( Mengukur kecepatan masalah stok & piutang ( jika ada ))'.
      WHEN p_radio5.
        fu_company = 'DO VS GI ( Mengukur kecepatan picking )'.
      WHEN p_radio6.
        fu_company = 'GI VS Cust Recv ( Mengukur kecepatan delivery )'.
      WHEN p_radio7.
        fu_company = 'Cust Recv VS POD ( Mengukur kecepatan billing )'.
      WHEN p_radio9.
        fu_company = 'PO vs DO ( H+1 s/d 16:00 )'.
    ENDCASE.
  ENDIF.

*--- Output line
  PERFORM f_hdr_pad_title USING progname fu_company page_number.
ENDFORM.                    " F_HDR_LINE1


*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE2
*&---------------------------------------------------------------------*
*       Client, User text 1, Date and time
*----------------------------------------------------------------------*
FORM f_hdr_line2 USING fu_title.
  DATA:
    ld_sysid(18)  VALUE 'Client : XXX(YYY)',
*  ld_datum(18) value 'Date: AA/BB/CCCC'.
    ld_period(45),
    ld_datum(10),
    ld_datel      TYPE sy-datum,
    ld_dateh      TYPE sy-datum.

  CASE 'X'.
    WHEN p_radio1 OR p_radio9.
      ld_period = 'Quot. Date: AA/BB/CCCC to DD/EE/FFFF'.
      ld_datel  = s_qtdat-low.
      ld_dateh  = s_qtdat-high.
    WHEN p_radio2.
      ld_period = 'PO Date: AA/BB/CCCC to DD/EE/FFFF'.
      ld_datel  = s_bstdk-low.
      ld_dateh  = s_bstdk-high.
    WHEN p_radio3.
      ld_period = 'PO Date: AA/BB/CCCC to DD/EE/FFFF'.
      ld_datel  = s_bstdk-low.
      ld_dateh  = s_bstdk-high.
    WHEN p_radio4.
      ld_period = 'SO Date: AA/BB/CCCC to DD/EE/FFFF'.
      ld_datel  = s_sodat-low.
      ld_dateh  = s_sodat-high.
    WHEN p_radio5.
      ld_period = 'DO Date: AA/BB/CCCC to DD/EE/FFFF'.
      ld_datel  = s_dodat-low.
      ld_dateh  = s_dodat-high.
    WHEN p_radio6.
      ld_period = 'GI Date: AA/BB/CCCC to DD/EE/FFFF'.
      ld_datel  = s_gidat-low.
      ld_dateh  = s_gidat-high.
    WHEN p_radio7.
      ld_period = 'Cust Recv Date: AA/BB/CCCC to DD/EE/FFFF'.
      ld_datel  = s_cusdat-low.
      ld_dateh  = s_cusdat-high.
  ENDCASE.

*--- system info
  REPLACE 'XXX' WITH sy-sysid(3) INTO ld_sysid.
  REPLACE 'YYY' WITH sy-mandt INTO ld_sysid.

  REPLACE 'AA' WITH ld_datel+6(2) INTO ld_period.
  REPLACE 'BB' WITH ld_datel+4(2) INTO ld_period.
  REPLACE 'CCCC' WITH ld_datel(4) INTO ld_period.
  REPLACE 'DD' WITH ld_dateh+6(2) INTO ld_period.
  REPLACE 'EE' WITH ld_dateh+4(2) INTO ld_period.
  REPLACE 'FFFF' WITH ld_dateh(4) INTO ld_period.

*--- date
*  replace 'AA' with sy-datum+6(2) into ld_datum.
*  replace 'BB' with sy-datum+4(2) into ld_datum.
*  replace 'CCCC' with sy-datum+0(4) into ld_datum.
  WRITE sy-datum TO ld_datum.

*--- output line
  PERFORM f_hdr_pad_title USING ld_sysid ld_period ld_datum.
ENDFORM.                    " F_HDR_LINE2


*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE3
*&---------------------------------------------------------------------*
*       User name, text 2, time
*----------------------------------------------------------------------*
FORM f_hdr_line3 USING fu_title.
  DATA:
    ld_uzeit(5)   VALUE 'hh:mm',
    ld_period(45),
    ld_uname(21)  VALUE 'User:    xx',
    ld_datel      TYPE sy-datum,
    ld_dateh      TYPE sy-datum.


  CASE 'X'.
    WHEN p_radio1 OR p_radio9.
      ld_period = 'Clear Date: AA/BB/CCCC to DD/EE/FFFF'.
      ld_datel  = s_pydat-low.
      ld_dateh  = s_pydat-high.
    WHEN p_radio2.
      ld_period = 'Cust Recv Date: AA/BB/CCCC to DD/EE/FFFF'.
      ld_datel  = s_cusdat-low.
      ld_dateh  = s_cusdat-high.
    WHEN p_radio3.
      ld_period = 'SO Date: AA/BB/CCCC to DD/EE/FFFF'.
      ld_datel  = s_sodat-low.
      ld_dateh  = s_sodat-high.
    WHEN p_radio4.
      ld_period = 'DO Date: AA/BB/CCCC to DD/EE/FFFF'.
      ld_datel  = s_dodat-low.
      ld_dateh  = s_dodat-high.
    WHEN p_radio5.
      ld_period = 'GI Date: AA/BB/CCCC to DD/EE/FFFF'.
      ld_datel  = s_gidat-low.
      ld_dateh  = s_gidat-high.
    WHEN p_radio6.
      ld_period = 'Cust Recv Date: AA/BB/CCCC to DD/EE/FFFF'.
      ld_datel  = s_cusdat-low.
      ld_dateh  = s_cusdat-high.
    WHEN p_radio7.
      ld_period = 'POD Date: AA/BB/CCCC to DD/EE/FFFF'.
      ld_datel  = s_poddat-low.
      ld_dateh  = s_poddat-high.
  ENDCASE.

*--- time
  REPLACE 'hh' WITH sy-uzeit(2) INTO ld_uzeit.     " hour
  REPLACE 'mm' WITH sy-uzeit+2(2) INTO ld_uzeit.   " minute

  REPLACE 'AA' WITH ld_datel+6(2) INTO ld_period.
  REPLACE 'BB' WITH ld_datel+4(2) INTO ld_period.
  REPLACE 'CCCC' WITH ld_datel(4) INTO ld_period.
  REPLACE 'DD' WITH ld_dateh+6(2) INTO ld_period.
  REPLACE 'EE' WITH ld_dateh+4(2) INTO ld_period.
  REPLACE 'FFFF' WITH ld_dateh(4) INTO ld_period.

*--- user
  REPLACE 'xx' WITH sy-uname INTO ld_uname.

*--- output line
  PERFORM f_hdr_pad_title USING ld_uname ld_period ld_uzeit.

ENDFORM.                    " F_HDR_LINE3

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.

  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.
  CLEAR: va_ucomm, va_count.
  va_ucomm = fu_ucomm.

  CASE fu_ucomm.
    WHEN '&SAV'.
      PERFORM f_save_to_table.
    WHEN '&IC1'.
      va_count = 1.
      PERFORM f_listing_detail.
  ENDCASE.

ENDFORM.                    "f_user_command

*&---------------------------------------------------------------------*
*&      Form  f_listing_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_listing_detail.

  DATA : l_line(200),
         l_field(20),
         l_value(30),
         l_vkbur(4),
         l_kvgr2(2),
         l_kdgrp(2),
         l_katr1(2),
         l_bzirk(6).

  DATA : str1(50),
         str2(50),
         str3(50),
         str4(50),
         str5(50),
         str6(50),
         str7(50).

  CLEAR i_detail1. REFRESH i_detail1.
  READ CURRENT LINE LINE VALUE INTO l_line.
  GET CURSOR FIELD l_field VALUE l_value.

*  l_vkbur(4) = l_line+3(4).
*  l_kvgr2(2) = l_line+9(2).
*  l_kdgrp(2) = l_line+40(2).
*  l_katr1(2) = l_line+72(2).

  SPLIT l_line AT '|' INTO str1 str2 str3 str4 str5 str6 str7.

  CONDENSE str2 NO-GAPS.
  l_vkbur   = str2.
  l_kvgr2   = str3(2).
  l_kdgrp   = str4.
  l_katr1   = str6.
  l_bzirk   = str7.


  IF l_field = 'I_SUMMARY-CNT01' OR l_field = 'I_SUMMARY-CNT02' OR
     l_field = 'I_SUMMARY-CNT03' OR l_field = 'I_SUMMARY-CNT04' OR
     l_field = 'I_SUMMARY-CNT05' OR l_field = 'I_SUMMARY-CNT06' OR
     l_field = 'I_SUMMARY-CNT07' OR l_field = 'I_SUMMARY-CNT08' OR
     l_field = 'I_SUMMARY-CNT09' OR l_field = 'I_SUMMARY-CNT10' OR
     l_field = 'I_SUMMARY-STDIN' OR l_field = 'I_SUMMARY-STDOUT' OR
     l_field = 'I_SUMMARY9-QTN' OR l_field = 'I_SUMMARY9-HIT' OR
     l_field = 'I_SUMMARY9-NHIT'.

    i_detail1[] = i_detail[].

    IF p_slk IS NOT INITIAL.
      DELETE i_detail1 WHERE vkbur NE l_vkbur OR
                             kvgr2 NE l_kvgr2 OR
                             kdgrp NE l_kdgrp OR
                             katr1 NE l_katr1 OR
                             bzirk NE l_bzirk.
    ELSE.
      IF p_radio9 = 'X'.
        DELETE i_detail1 WHERE vkbur NE l_vkbur.
      ELSE.
        DELETE i_detail1 WHERE vkbur NE l_vkbur OR
                               kvgr2 NE l_kvgr2 OR
                               kdgrp NE l_kdgrp OR
                               katr1 NE l_katr1.
      ENDIF.
    ENDIF.

    CASE l_field.
      WHEN 'I_SUMMARY-CNT01'.
        DELETE i_detail1 WHERE cnt01 EQ 0.
      WHEN 'I_SUMMARY-CNT02'.
        DELETE i_detail1 WHERE cnt02 EQ 0.
      WHEN 'I_SUMMARY-CNT03'.
        DELETE i_detail1 WHERE cnt03 EQ 0.
      WHEN 'I_SUMMARY-CNT04'.
        DELETE i_detail1 WHERE cnt04 EQ 0.
      WHEN 'I_SUMMARY-CNT05'.
        DELETE i_detail1 WHERE cnt05 EQ 0.
      WHEN 'I_SUMMARY-CNT06'.
        DELETE i_detail1 WHERE cnt06 EQ 0.
      WHEN 'I_SUMMARY-CNT07'.
        DELETE i_detail1 WHERE cnt07 EQ 0.
      WHEN 'I_SUMMARY-CNT08'.
        DELETE i_detail1 WHERE cnt08 EQ 0.
      WHEN 'I_SUMMARY-CNT09'.
        DELETE i_detail1 WHERE cnt09 EQ 0.
      WHEN 'I_SUMMARY-CNT10'.
        DELETE i_detail1 WHERE cnt10 EQ 0.
      WHEN 'I_SUMMARY-STDIN'.
        DELETE i_detail1 WHERE stdin EQ 0.
      WHEN 'I_SUMMARY-STDOUT'.
        DELETE i_detail1 WHERE stdout EQ 0.
      WHEN 'I_SUMMARY9-HIT'.
        DELETE i_detail1 WHERE hit EQ 0.
      WHEN 'I_SUMMARY9-NHIT'.
        DELETE i_detail1 WHERE nhit EQ 0.
    ENDCASE.

    PERFORM print_data.

  ENDIF.

ENDFORM.                    " f_listing_detail

*&---------------------------------------------------------------------*
*&      Form  get_general_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_general_data .

  DATA : l_tabix   LIKE sy-tabix,
         l_vbelv   LIKE vbfa-vbelv,
         l_posnv   LIKE vbfa-posnv,
         l_vbeln   LIKE vbfa-vbeln,
         l_vbtyp_n LIKE vbfa-vbtyp_n,
         l_posnn   LIKE vbfa-posnn,
         l_bwart   LIKE vbfa-bwart.

  DATA : BEGIN OF lt_delv OCCURS 0,
           vbeln LIKE  cdhdr-objectid,
         END OF lt_delv.

  DATA : BEGIN OF lt_delv1 OCCURS 0,
           vbelv LIKE  vbfa-vbelv,
         END OF lt_delv1.

  DATA : li_gi LIKE i_vbfa OCCURS 0 WITH HEADER LINE.

  RANGES: lr_posnn  FOR vbfa-posnn.

  DATA : lr_vgtyp TYPE RANGE OF vbak-vgtyp,
         ls_vgtyp LIKE LINE OF lr_vgtyp.

  DATA : lt_quot    LIKE i_quot OCCURS 0 WITH HEADER LINE.

  lr_posnn-low     = '10'.
  lr_posnn-high    = '9000'.
  lr_posnn-sign    = 'I'.
  lr_posnn-option  = 'BT'.
  APPEND lr_posnn.

  lr_posnn-low     = '1'.
  lr_posnn-high    = '999'.
  lr_posnn-sign    = 'I'.
  lr_posnn-option  = 'BT'.
  APPEND lr_posnn.

  lr_posnn-low     = space.
  lr_posnn-high    = space.
  lr_posnn-sign    = 'I'.
  lr_posnn-option  = 'EQ'.
  APPEND lr_posnn.

  ls_vgtyp-low     = space.
  ls_vgtyp-sign    = 'I'.
  ls_vgtyp-option  = 'EQ'.
  APPEND ls_vgtyp TO lr_vgtyp.
  CLEAR ls_vgtyp.
  ls_vgtyp-low     = 'G'.
  ls_vgtyp-sign    = 'I'.
  ls_vgtyp-option  = 'EQ'.
  APPEND ls_vgtyp TO lr_vgtyp.

*** Select Document Quotation ***
  IF p_radio2 = 'X' AND p_matkl = 'X'.
    SELECT a~vkbur a~vbeln a~knkli a~auart a~knumv a~bstnk a~bstdk a~augru
           a~waerk a~erdat a~erzet a~bnddt b~kdgrp b~kvgr2 b~bzirk
      FROM vbak AS a JOIN knvv AS b ON a~knkli = b~kunnr AND
                                       a~vkorg = b~vkorg AND
                                       a~vtweg = b~vtweg AND
                                       a~spart = b~spart
                     JOIN vbap AS c ON a~vbeln = c~vbeln
      INTO CORRESPONDING FIELDS OF TABLE i_quot
      WHERE a~kkber IN s_kkber AND
            a~vkorg = p_vkorg  AND
            a~vkbur IN s_vkbur AND
            a~auart IN s_auart AND
            a~knkli IN s_knkli AND
            a~kvgr2 IN s_kvgr2 AND
            a~vbeln IN s_qtno  AND
            a~erdat IN s_qtdat AND
*            a~vgtyp = space    AND
            a~vgtyp IN lr_vgtyp   AND
            a~vbtyp IN ('C', 'B') AND
            b~kdgrp IN s_kdgrp AND
            c~matkl IN s_matkl.
    IF sy-subrc = 0.
      SORT i_quot BY vbeln.
      DELETE ADJACENT DUPLICATES FROM i_quot COMPARING vbeln.
    ENDIF.
  ELSEIF p_radio8 IS NOT INITIAL.
    SELECT a~vkbur a~vbeln a~knkli a~auart a~knumv a~bstnk a~bstdk a~augru
           a~waerk a~erdat a~erzet a~bnddt b~kdgrp b~kvgr2 b~bzirk
      FROM vbak AS a JOIN knvv AS b ON a~knkli = b~kunnr AND
                                       a~vkorg = b~vkorg AND
                                       a~vtweg = b~vtweg AND
                                       a~spart = b~spart
                     JOIN vbap AS c ON a~vbeln = c~vbeln
      INTO CORRESPONDING FIELDS OF TABLE i_quot
      WHERE a~kkber IN s_kkber AND
            a~vkorg = p_vkorg  AND
            a~vkbur IN s_vkbur AND
            a~auart IN s_auart AND
            a~knkli IN s_knkli AND
            a~kvgr2 IN s_kvgr2 AND
            a~vbeln IN s_qtno  AND
            a~erdat IN s_qtdat AND
*            a~vgtyp = space    AND
            a~vgtyp IN lr_vgtyp   AND
            a~vbtyp IN ('C', 'B') AND
            b~kdgrp IN s_kdgrp AND
            c~matkl IN s_matkl.
    IF sy-subrc = 0.
      SORT i_quot BY vbeln.
      DELETE ADJACENT DUPLICATES FROM i_quot COMPARING vbeln.
    ENDIF.
  ELSE.
    SELECT a~vkbur a~vbeln a~knkli a~auart a~knumv a~bstnk a~bstdk a~augru
           a~waerk a~erdat a~erzet a~bnddt b~kdgrp b~kvgr2 b~bzirk
*    FROM vbak AS a JOIN knvv AS b ON a~vkbur = b~vkbur AND
*                                     a~vkorg = b~vkorg AND
*                                     a~vtweg = b~vtweg AND
*                                     a~spart = b~spart AND
*                                     a~knkli = b~kunnr
      FROM vbak AS a JOIN knvv AS b ON a~knkli = b~kunnr AND
                                       a~vkorg = b~vkorg AND
                                       a~vtweg = b~vtweg AND
                                       a~spart = b~spart
      INTO CORRESPONDING FIELDS OF TABLE i_quot
      WHERE a~kkber IN s_kkber AND
            a~vkorg = p_vkorg  AND
            a~vkbur IN s_vkbur AND
            a~auart IN s_auart AND
            a~knkli IN s_knkli AND
            a~kvgr2 IN s_kvgr2 AND
            a~vbeln IN s_qtno  AND
            a~erdat IN s_qtdat AND
*            a~vgtyp = space    AND
            a~vgtyp IN lr_vgtyp   AND
            a~vbtyp IN ('C', 'B') AND
            b~kdgrp IN s_kdgrp.
  ENDIF.

  IF p_radio9 IS NOT INITIAL.
    DELETE i_quot WHERE augru NOT IN s_augru.
  ENDIF.

  CHECK NOT i_quot[] IS INITIAL.

  lt_quot[] = i_quot[].
  SORT lt_quot BY knkli.
  DELETE ADJACENT DUPLICATES FROM lt_quot COMPARING knkli.
  IF lt_quot[] IS NOT INITIAL.
    SELECT kunnr vkbur
      FROM knvv
      INTO CORRESPONDING FIELDS OF TABLE gt_knvv
      FOR ALL ENTRIES IN lt_quot
      WHERE kunnr = lt_quot-knkli.
  ENDIF.

*** Select Gross Sales ***
  SELECT vbeln posnr kzwi1
     INTO CORRESPONDING FIELDS OF TABLE i_grsls
     FROM vbap
     FOR ALL ENTRIES IN i_quot
     WHERE vbeln = i_quot-vbeln.

*** Select Document Flow ***
  SELECT vbelv posnv vbeln posnn vbtyp_n erdat erzet bwart mjahr
     INTO CORRESPONDING FIELDS OF TABLE i_vbfa
     FROM vbfa
     FOR ALL ENTRIES IN i_quot
     WHERE vbelv = i_quot-vbeln AND
*           posnn IN (' ','1','10').
           posnn IN lr_posnn.

  SORT i_vbfa BY vbelv vbeln.
  DELETE ADJACENT DUPLICATES FROM i_vbfa COMPARING vbeln.

  LOOP AT i_vbfa.
    IF i_vbfa-vbtyp_n = 'T' OR
       i_vbfa-vbtyp_n = 'N' OR
       i_vbfa-vbtyp_n = 'O' OR
       i_vbfa-vbtyp_n = 'h'.
      DELETE i_vbfa.
      IF i_vbfa-vbtyp_n EQ 'T' AND
        i_vbfa-bwart EQ '655'.
      ELSE.
        DELETE i_vbfa.
*        DELETE i_vbfa INDEX l_tabix.
      ENDIF.
*      IF i_vbfa-vbtyp_n EQ 'T'.
*        IF i_vbfa-bwart NE '655'.
*          DELETE i_vbfa.
*        ENDIF.
*      ENDIF.
    ENDIF.
    IF i_vbfa-vbtyp_n = 'R' AND
       i_vbfa-bwart = '653' AND
       l_vbtyp_n = 'R'.
      DELETE i_vbfa.
*      DELETE i_vbfa INDEX l_tabix.
      DELETE i_vbfa WHERE vbelv   = l_vbelv   AND
                          posnv   = l_posnv   AND
                          vbeln   = l_vbeln   AND
                          vbtyp_n = l_vbtyp_n AND
                          posnn   = l_posnn.

    ENDIF.
    l_tabix = sy-tabix.
    l_vbtyp_n = i_vbfa-vbtyp_n.

    IF i_vbfa-vbtyp_n = 'R'.
      l_vbelv   = i_vbfa-vbelv.
      l_posnv   = i_vbfa-posnv.
      l_vbeln   = i_vbfa-vbeln.
      l_vbtyp_n = i_vbfa-vbtyp_n.
      l_posnn   = i_vbfa-posnn.
    ENDIF.
  ENDLOOP.

  CHECK NOT i_vbfa[] IS INITIAL.

  PERFORM f_add_lines_so.

  i_so[] = i_do[] = i_gi[] = i_inv[] = i_vbfa[].
  DELETE i_so WHERE vbtyp_n NE 'C'.
  DELETE i_do WHERE vbtyp_n NE 'J'.
  DELETE i_gi WHERE vbtyp_n NE 'R'.
  DELETE i_inv WHERE vbtyp_n NE 'M'.

  SORT i_so BY vbelv.
  DELETE ADJACENT DUPLICATES FROM i_so COMPARING vbelv.

*** Select GI Date ***
  IF i_do[] IS NOT INITIAL.
    SELECT vbelv posnv vbeln posnn vbtyp_n erdat erzet bwart
       INTO CORRESPONDING FIELDS OF TABLE i_pick
       FROM vbfa
       FOR ALL ENTRIES IN i_do
       WHERE vbelv = i_do-vbeln AND
             vbtyp_n = 'Q'.
    SORT i_pick BY vbelv erdat DESCENDING erzet DESCENDING.
    DELETE ADJACENT DUPLICATES FROM i_pick COMPARING vbelv.
  ENDIF.

*** Select GI Date ***
  IF i_gi[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE i_mkpf
      FROM mkpf
      FOR ALL ENTRIES IN i_gi
      WHERE mblnr = i_gi-vbeln AND
            mjahr = i_gi-mjahr.       "i_gi-erdat(4).

    DATA: temp_vbelv TYPE vbfa-vbelv.
    SORT i_mkpf BY cpudt DESCENDING.
    SORT i_gi BY erdat DESCENDING.
    LOOP AT i_gi INTO DATA(ls_gi).
      IF i_gi-erdat+4(2) = '01'.
        MOVE-CORRESPONDING i_gi TO li_gi.
        SUBTRACT 1 FROM li_gi-erdat(4).
        APPEND li_gi. CLEAR li_gi.
      ENDIF.


*      Added
      READ TABLE i_mkpf INTO DATA(ls_mkpf) WITH KEY mblnr = ls_gi-vbeln mjahr = ls_gi-mjahr.  "ls_gi-erdat(4).
      IF sy-subrc = 0.
        IF temp_vbelv IS INITIAL.
          temp_vbelv = ls_gi-vbelv.
        ELSE.
          IF temp_vbelv = ls_gi-vbelv.
            DELETE i_mkpf WHERE mblnr = ls_gi-vbeln AND mjahr = ls_gi-mjahr.    "ls_gi-erdat(4).
            DELETE i_gi WHERE vbeln = ls_gi-vbeln AND mjahr = ls_gi-mjahr.   "erdat(4) = ls_gi-erdat(4).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

      IF li_gi[] IS NOT INITIAL.
        SELECT * APPENDING CORRESPONDING FIELDS OF TABLE i_mkpf
          FROM mkpf
          FOR ALL ENTRIES IN li_gi
          WHERE mblnr = li_gi-vbeln AND
                mjahr = li_gi-mjahr.      "li_gi-erdat(4).
        ENDIF.

        SORT i_mkpf BY mblnr mjahr.
        DELETE ADJACENT DUPLICATES FROM i_mkpf COMPARING mblnr mjahr.
      ENDIF.

      CHECK NOT i_so[] IS INITIAL.

*** Select Rejection ***
      SELECT vbeln abstk
         INTO CORRESPONDING FIELDS OF TABLE i_vbuk
         FROM vbuk
         FOR ALL ENTRIES IN i_so
         WHERE vbeln = i_so-vbeln.

*** PO Expirated Date ***
        SELECT vbeln bnddt
           INTO CORRESPONDING FIELDS OF TABLE i_poexd
           FROM vbak
           FOR ALL ENTRIES IN i_so
           WHERE vbeln = i_so-vbeln.

          CHECK NOT i_do[] IS INITIAL.

*** Select Document Delivery (DO) ***
          SELECT b~vbeln b~podat b~potim c~wbstk c~kostk
            FROM likp AS b JOIN vbuk AS c ON b~vbeln = c~vbeln
            INTO CORRESPONDING FIELDS OF TABLE i_delv
            FOR ALL ENTRIES IN i_do
            WHERE b~vbeln = i_do-vbeln." AND
*          b~vstel IN s_vkbur.

            lt_delv1[] = i_delv[].
            lt_delv[] = lt_delv1[].

*** Select POD Change Document ***
*  SELECT objectclas objectid changenr tabname tabkey fname
*         chngind value_new
*    FROM cdpos
*    INTO CORRESPONDING FIELDS OF TABLE i_cdpos
*    FOR ALL ENTRIES IN lt_delv
*    WHERE objectclas =  'LIEFERUNG'   AND
*          objectid   =  lt_delv-vbeln AND
*          fname      IN ('KOSTK','WBSTK').
*
*  IF sy-subrc = 0.
            SELECT objectclas objectid changenr username udate utime tcode
              FROM cdhdr
              INTO CORRESPONDING FIELDS OF TABLE i_cdhdr
              FOR ALL ENTRIES IN lt_delv
              WHERE objectclas = 'LIEFERUNG'   AND
                    objectid   = lt_delv-vbeln AND
                    tcode   LIKE 'VLPOD%'.
*  ENDIF.

              SELECT a~kschl a~vkorg a~vkbur a~kdgrp a~kunwe a~katr1 a~datbi
                     a~datab a~knumh a~zday1 a~zday2 a~zday3 a~zday4 a~zday5 a~zday6
                     b~kbetr b~valtg b~kmein
                FROM a511 AS a JOIN konp AS b ON a~knumh EQ b~knumh
                INTO CORRESPONDING FIELDS OF TABLE t_a511
                WHERE a~kschl    EQ 'ZDLV' AND
                      a~vkorg    EQ p_vkorg AND
                      b~loevm_ko EQ space.
ENDFORM.                    " get_general_data

*&---------------------------------------------------------------------*
*&      Form  process_general_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_general_data.
  DATA: l_tabix LIKE sy-tabix.

  SORT i_quot BY vbeln.
  SORT i_grsls BY vbeln.
  SORT i_so BY vbelv vbeln.
  SORT i_do BY vbelv vbeln.
  SORT i_inv BY vbelv vbeln.
  SORT i_gi BY vbelv vbeln.
  SORT i_pick BY vbelv vbeln.
  SORT i_vbuk BY vbeln.
  SORT i_delv BY vbeln.
  SORT i_poexd BY vbeln.

*  SORT i_cdpos ASCENDING BY objectclas objectid
*                            fname value_new changenr DESCENDING.
  SORT i_cdhdr ASCENDING BY objectclas objectid changenr DESCENDING.

  LOOP AT i_quot.

    CLEAR: i_grsls,i_so,i_do,i_gi,i_inv,i_pick,i_mkpf,i_vbuk,i_delv,i_cdpos,
           i_cdhdr,i_monitor,i_poexd.

** Hitung gross sales
    READ TABLE i_grsls WITH KEY vbeln = i_quot-vbeln BINARY SEARCH.
    l_tabix = sy-tabix.
    LOOP AT i_grsls FROM l_tabix.
      IF i_grsls-vbeln NE i_quot-vbeln.
        EXIT.
      ENDIF.
      ADD i_grsls-kzwi1 TO i_monitor-kwert.
    ENDLOOP.

** Baca SO
    READ TABLE i_so WITH KEY vbelv = i_quot-vbeln BINARY SEARCH.
** Baca SO
    IF sy-subrc = 0.
      READ TABLE i_poexd WITH KEY vbeln = i_so-vbeln BINARY SEARCH.
    ENDIF.

** Baca DO
    READ TABLE i_do WITH KEY vbelv = i_quot-vbeln BINARY SEARCH.

** Baca Invoice
    READ TABLE i_inv WITH KEY vbelv = i_quot-vbeln BINARY SEARCH.

** Baca GI
    LOOP AT i_gi WHERE vbelv = i_quot-vbeln.
      IF i_gi-bwart <> space.
        EXIT.
      ENDIF.
    ENDLOOP.
*    READ TABLE i_gi WITH KEY vbelv = i_quot-vbeln BINARY SEARCH.

** Baca Reject
    READ TABLE i_vbuk WITH KEY vbeln = i_so-vbeln BINARY SEARCH.

** Baca Delivery
    READ TABLE i_delv WITH KEY vbeln = i_do-vbeln BINARY SEARCH.

** Baca last change
    IF i_delv-kostk = 'C'.
*      READ TABLE i_cdpos WITH KEY objectid = i_delv-vbeln
*                                  fname    = 'KOSTK'
*                                  value_new = i_delv-kostk BINARY SEARCH.
*      IF sy-subrc = 0.
*        READ TABLE i_cdhdr WITH KEY changenr = i_cdpos-changenr.
*        IF sy-subrc = 0.
*          i_monitor-pkdat = i_cdhdr-udate.
*          i_monitor-pktim = i_cdhdr-utime.
*        ENDIF.
*      ENDIF.
      READ TABLE i_pick WITH KEY vbelv = i_do-vbeln.
    ENDIF.
    IF i_delv-wbstk = 'C'.
*      READ TABLE i_cdpos WITH KEY objectid = i_delv-vbeln
*                                  fname    = 'WBSTK'
*                                  value_new = i_delv-wbstk BINARY SEARCH.
*      IF sy-subrc = 0.
*        READ TABLE i_cdhdr WITH KEY changenr = i_cdpos-changenr.
*        IF sy-subrc = 0.
*          i_monitor-gidat = i_cdhdr-udate.
*          i_monitor-gitim = i_cdhdr-utime.
*        ENDIF.
*      ENDIF.
      READ TABLE i_mkpf WITH KEY mblnr = i_gi-vbeln.
    ENDIF.

** Baca Delivery
    READ TABLE i_cdhdr WITH KEY objectid = i_delv-vbeln BINARY SEARCH.

** Append itab
    i_monitor-spmon = i_quot-erdat(6).
    i_monitor-vkbur = i_quot-vkbur.
    i_monitor-kvgr2 = i_quot-kvgr2.
    i_monitor-kdgrp = i_quot-kdgrp.
    i_monitor-knkli = i_quot-knkli.
    i_monitor-auart = i_quot-auart.
    i_monitor-qtno  = i_quot-vbeln.
    i_monitor-qtdat = i_quot-erdat.
    i_monitor-qttim = i_quot-erzet.
    i_monitor-bstnk = i_quot-bstnk.
    i_monitor-bstdk = i_quot-bstdk.

    IF i_quot-vkbur(2) = 'T2'.
      i_monitor-sono  = i_quot-vbeln.
      i_monitor-sodat = i_quot-erdat.
      i_monitor-sotim = i_quot-erzet.
    ELSE.
      i_monitor-sono  = i_so-vbeln.
      i_monitor-sodat = i_so-erdat.
      i_monitor-sotim = i_so-erzet.
    ENDIF.

    i_monitor-bnddt = i_poexd-bnddt.
    i_monitor-dono  = i_do-vbeln.
    i_monitor-dodat = i_do-erdat.
    i_monitor-dotim = i_do-erzet.
    i_monitor-pkdat = i_pick-erdat.
    i_monitor-pktim = i_pick-erzet.
    i_monitor-gidat = i_mkpf-cpudt.
    i_monitor-gitim = i_mkpf-cputm.
    i_monitor-podat = i_cdhdr-udate.
    i_monitor-potim = i_cdhdr-utime.
    i_monitor-zuonr = i_delv-vbeln.
    i_monitor-waerk = i_quot-waerk.
    i_monitor-abstk = i_vbuk-abstk.
    i_monitor-vttno = i_delv-vbeln.
    i_monitor-bzirk = i_quot-bzirk.

    CASE i_monitor-abstk.
      WHEN 'A'.
        i_monitor-rejid = '@08@'.
      WHEN 'B'.
        i_monitor-rejid = '@09@'.
      WHEN 'C'.
        i_monitor-rejid = '@0A@'.
    ENDCASE.

    APPEND i_monitor. CLEAR i_monitor.

  ENDLOOP.

ENDFORM.                    " process_general_data

*&---------------------------------------------------------------------*
*&      Form  F_STD_COUNT
*&---------------------------------------------------------------------*
FORM f_std_count  USING    fu_knkli fu_dodat fu_gidat fu_kdgrp fu_katr1
                           fu_hours fu_workday fu_bzirk fu_vkbur
                  CHANGING fc_porc fc_kbetr fc_valtg fc_coun2 fc_coun5 fc_coun6.

  DATA: ld_hour1(10) TYPE p DECIMALS 2,
        ld_hour2(10) TYPE p DECIMALS 2.

  DATA: ls_control LIKE LINE OF gt_control.

  READ TABLE t_a511 WITH KEY kunwe = fu_knkli.
  IF sy-subrc EQ 0.
    PERFORM f_get_a511 USING t_a511-datbi t_a511-datab t_a511-zday2
                             t_a511-zday3 t_a511-zday4 t_a511-zday5
                             t_a511-zday6 fu_dodat fu_gidat
                       CHANGING fc_kbetr fc_valtg fc_porc.
  ELSE.
    IF fu_bzirk IS NOT INITIAL.
      READ TABLE t_a511 WITH KEY zday1 = fu_bzirk.
      IF sy-subrc EQ 0.
        PERFORM f_get_a511 USING t_a511-datbi t_a511-datab t_a511-zday2
                                 t_a511-zday3 t_a511-zday4 t_a511-zday5
                                 t_a511-zday6 fu_dodat fu_gidat
                           CHANGING fc_kbetr fc_valtg fc_porc.
      ELSE.
        READ TABLE t_a511 WITH KEY vkbur = fu_vkbur
                                   kdgrp = fu_kdgrp
                                   katr1 = fu_katr1.
        IF sy-subrc EQ 0.
          PERFORM f_get_a511 USING t_a511-datbi t_a511-datab t_a511-zday2
                                   t_a511-zday3 t_a511-zday4 t_a511-zday5
                                   t_a511-zday6 fu_dodat fu_gidat
                             CHANGING fc_kbetr fc_valtg fc_porc.
        ELSE.
          READ TABLE t_a511 WITH KEY kdgrp = fu_kdgrp
                                     katr1 = fu_katr1.
          IF sy-subrc EQ 0.
            PERFORM f_get_a511 USING t_a511-datbi t_a511-datab t_a511-zday2
                                     t_a511-zday3 t_a511-zday4 t_a511-zday5
                                     t_a511-zday6 fu_dodat fu_gidat
                               CHANGING fc_kbetr fc_valtg fc_porc.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      READ TABLE t_a511 WITH KEY vkbur = fu_vkbur
                                 kdgrp = fu_kdgrp
                                 katr1 = fu_katr1.
      IF sy-subrc EQ 0.
        PERFORM f_get_a511 USING t_a511-datbi t_a511-datab t_a511-zday2
                                 t_a511-zday3 t_a511-zday4 t_a511-zday5
                                 t_a511-zday6 fu_dodat fu_gidat
                           CHANGING fc_kbetr fc_valtg fc_porc.
      ELSE.
        READ TABLE t_a511 WITH KEY kdgrp = fu_kdgrp
                                   katr1 = fu_katr1.
        IF sy-subrc EQ 0.
          PERFORM f_get_a511 USING t_a511-datbi t_a511-datab t_a511-zday2
                                   t_a511-zday3 t_a511-zday4 t_a511-zday5
                                   t_a511-zday6 fu_dodat fu_gidat
                             CHANGING fc_kbetr fc_valtg fc_porc.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF p_radio8 IS NOT INITIAL.
    CLEAR fc_porc.
    IF fu_bzirk IS NOT INITIAL.
      READ TABLE gt_control INTO ls_control WITH KEY vkorg = p_vkorg
                                                     bzirk = fu_bzirk.
      IF sy-subrc = 0.
        fc_porc = ls_control-zposo + ls_control-zsodo + ls_control-zdopic +
                  ls_control-zpicgi + ls_control-zgishp + ls_control-zshpcr.
      ENDIF.
    ELSE.
      READ TABLE gt_control INTO ls_control WITH KEY vkorg = p_vkorg
                                                     katr1 = fu_katr1
                                                     kdgrp = fu_kdgrp.
      IF sy-subrc = 0.
        fc_porc = ls_control-zposo + ls_control-zsodo + ls_control-zdopic +
                  ls_control-zpicgi + ls_control-zgishp + ls_control-zshpcr.
      ENDIF.
    ENDIF.
  ENDIF.

  CASE 'X'.
    WHEN p_radio2 OR p_radio8.
      IF fu_workday LE fc_porc.
        fc_coun2  = 1.
      ENDIF.

    WHEN p_radio5 OR p_radio6.
      ld_hour1  = fc_kbetr * 24.
      ld_hour2  = fc_valtg * 24.
      IF ld_hour1 GT fu_hours.
        fc_coun5  = 1.
      ENDIF.
      IF ld_hour2 GT fu_hours.
        fc_coun6  = 1.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_STD_COUNT

*&---------------------------------------------------------------------*
*&      Form  F_PERSEN_STANDART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_persen_standart .
  DATA : ls_control LIKE LINE OF gt_control.

  LOOP AT i_summary.
    IF i_summary-cnt10 IS NOT INITIAL.
      i_summary-stdpercen  = ( i_summary-stdin / i_summary-cnt10 ) * 100.
    ENDIF.
    IF i_summary-bzirk IS NOT INITIAL.
      READ TABLE gt_control INTO ls_control WITH KEY bzirk = i_summary-bzirk.
      IF sy-subrc = 0.
        i_summary-target = ls_control-zposo + ls_control-zsodo +
                           ls_control-zdopic + ls_control-zpicgi +
                           ls_control-zgishp + ls_control-zshpcr.
      ENDIF.
    ELSE.
      READ TABLE gt_control INTO ls_control WITH KEY katr1 = i_summary-katr1
                                                     kdgrp = i_summary-kdgrp.
      IF sy-subrc = 0.
        i_summary-target = ls_control-zposo + ls_control-zsodo +
                           ls_control-zdopic + ls_control-zpicgi +
                           ls_control-zgishp + ls_control-zshpcr.
      ENDIF.
    ENDIF.
    MODIFY i_summary TRANSPORTING stdpercen target.
    CLEAR : i_summary-stdpercen, i_summary-target.
  ENDLOOP.
ENDFORM.                    " F_PERSEN_STANDART

*&---------------------------------------------------------------------*
*&      Form  F_GET_A511
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_a511  USING    fu_datbi fu_datab fu_zday2 fu_zday3
                          fu_zday4 fu_zday5 fu_zday6 fu_dodat fu_gidat
                 CHANGING fc_kbetr fc_valtg fc_porc.

  IF fu_datbi GE fu_dodat AND
    fu_datab LE fu_dodat.
    fc_kbetr = ( fu_zday3 + fu_zday4 ) + 1.
  ENDIF.

  IF fu_datbi GE fu_gidat AND
    fu_datab LE fu_gidat.
    fc_valtg = ( fu_zday5 + fu_zday6 ) + 1.
  ENDIF.

  IF fu_datbi GE fu_dodat AND
    fu_datab LE fu_dodat.
    fc_porc = ( fu_zday2 + fu_zday3 + fu_zday4 + fu_zday5 + fu_zday6 ) + 1.
  ENDIF.
ENDFORM.                    " F_GET_A511

*&---------------------------------------------------------------------*
*&      Form  F_ZSEXTREC
*&---------------------------------------------------------------------*
FORM f_zsextrec .
  DATA : lt_monitor  LIKE i_monitor OCCURS 0 WITH HEADER LINE.

  lt_monitor[] = i_monitor[].
  SORT lt_monitor BY dono.
  DELETE ADJACENT DUPLICATES FROM lt_monitor COMPARING dono.
  IF lt_monitor[] IS NOT INITIAL.
    SELECT *
      FROM zsextrec
      INTO CORRESPONDING FIELDS OF TABLE gt_zsextrec
      FOR ALL ENTRIES IN lt_monitor
      WHERE vbeln = lt_monitor-dono.
    ENDIF.
ENDFORM.                    " F_ZSEXTREC

*&---------------------------------------------------------------------*
*&      Form  GET_DATA8
*&---------------------------------------------------------------------*
FORM get_data8 .

  CHECK NOT i_monitor[] IS INITIAL.

*** Select Customer ***
  CLEAR i_monitortmp. REFRESH i_monitortmp.
  i_monitortmp[] = i_monitor[].
  DELETE i_monitortmp WHERE knkli = space.
  IF i_monitortmp[] IS NOT INITIAL.
    SELECT kunnr name1 name2 ort01 katr1
      FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE i_kna1
      FOR ALL ENTRIES IN i_monitortmp
      WHERE kunnr = i_monitortmp-knkli.
    ENDIF.

*** Select Cust Received ***
    CLEAR i_monitortmp. REFRESH i_monitortmp.
    i_monitortmp[] = i_monitor[].
    DELETE i_monitortmp WHERE dono = space.
    IF i_monitortmp[] IS NOT INITIAL.
      SELECT vbeln crdat crtim
        FROM zmm_cust_rec
        INTO CORRESPONDING FIELDS OF TABLE i_custrec
        FOR ALL ENTRIES IN i_monitortmp
        WHERE vbeln =  i_monitortmp-dono AND
              crdat IN s_cusdat.
      ENDIF.

*** Select Faktur Pajak ***
      CLEAR i_monitortmp. REFRESH i_monitortmp.
      i_monitortmp[] = i_monitor[].
      DELETE i_monitortmp WHERE zuonr = space.
      IF i_monitortmp[] IS NOT INITIAL.
        SELECT zuonr vatdt vattm repdt reptm dudat
          FROM zfvato
          INTO CORRESPONDING FIELDS OF TABLE i_vato
          FOR ALL ENTRIES IN i_monitortmp
          WHERE vkorg =  p_vkorg         AND
                vtart IN ('SD','DN')     AND
                vkbur IN s_vkbur         AND
                zuonr =  i_monitortmp-zuonr.
        ENDIF.

*** Select Payment ***
        IF i_inv[] IS NOT INITIAL.
          IF i_monitor[] IS NOT INITIAL.
            CLEAR i_monitortmp. REFRESH i_monitortmp.
            i_monitortmp[] = i_monitor[].
            DELETE i_monitortmp WHERE zuonr = space.
            IF i_monitortmp[] IS NOT INITIAL.
              SELECT zuonr budat cpudt wrbtr augdt belnr
                FROM bsad
                INTO CORRESPONDING FIELDS OF TABLE i_bsad
                FOR ALL ENTRIES IN i_monitortmp
                WHERE bukrs EQ p_vkorg        AND
                      kunnr EQ i_monitortmp-knkli AND
                      zuonr EQ i_monitortmp-zuonr AND
                      blart EQ 'DZ'         AND
                      cpudt IN s_pydat.
              ENDIF.

*** Select Shipment ***
              SELECT a~tknum a~tplst a~signi a~exti1 a~ernam a~erdat a~erzet a~add04 a~datbg
                b~tpnum b~vbeln
                FROM vttk AS a JOIN vttp AS b ON a~tknum = b~tknum
                INTO CORRESPONDING FIELDS OF TABLE i_vttp
                FOR ALL ENTRIES IN i_monitor
                WHERE vbeln = i_monitor-vttno.
              ENDIF.

              IF i_monitortmp[] IS NOT INITIAL.
                SELECT a~bukrs a~vkbur a~bbeln a~bidat ebelp vbeln
                       gjahr zuonr fkdat kunnr bflag ptype tglttf
                  FROM zfbih AS a JOIN zfbid AS b ON a~bukrs = b~bukrs AND
                                                     a~vkbur = b~vkbur AND
                                                     a~bbeln = b~bbeln
                  INTO CORRESPONDING FIELDS OF TABLE i_zfbi
                  FOR ALL ENTRIES IN i_monitortmp
                  WHERE a~bukrs EQ p_vkorg    AND
                        a~vkbur IN s_vkbur    AND
                        zuonr EQ i_monitortmp-zuonr.
                  SELECT a~bukrs a~vkbur a~bbeln a~bidat ebelp vbeln
                         gjahr zuonr fkdat kunnr bflag ptype tglttf
                    FROM zfbih_sfa AS a JOIN zfbid_sfa AS b ON a~bukrs = b~bukrs AND
                                                       a~vkbur = b~vkbur AND
                                                       a~bbeln = b~bbeln
                    APPENDING CORRESPONDING FIELDS OF TABLE i_zfbi
                    FOR ALL ENTRIES IN i_monitortmp
                    WHERE a~bukrs EQ p_vkorg    AND
                          a~vkbur IN s_vkbur    AND
                          zuonr EQ i_monitortmp-zuonr.
                  ENDIF.
                ENDIF.

*** Select group outlet ***
                SELECT * FROM tvv2t INTO TABLE i_tvv2t
                  FOR ALL ENTRIES IN i_monitor
                  WHERE spras = 'EN'             AND
                        kvgr2 = i_monitor-kvgr2.

*** Select cust group ***
                  SELECT * FROM t151t INTO TABLE i_t151t
                    FOR ALL ENTRIES IN i_monitor
                    WHERE spras = 'EN'             AND
                          kdgrp = i_monitor-kdgrp.

                    SELECT *
                      FROM zssl_control
                      INTO CORRESPONDING FIELDS OF TABLE gt_control
                      WHERE vkorg = p_vkorg.

                      SORT i_custrec BY vbeln.
                      SORT i_vato BY zuonr.
                      SORT i_bsad BY zuonr cpudt DESCENDING.
ENDFORM.                                                    " GET_DATA8

*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA8
*&---------------------------------------------------------------------*
FORM process_data8 .
  DATA : lt_holiday LIKE iscal_day OCCURS 0,
         l_day      TYPE p,
         l_holiday  TYPE i,
         l_workday  TYPE i.

  DATA : ls_zsextrec LIKE LINE OF gt_zsextrec,
         lv_crdat    TYPE sy-datum,
         lv_crtim    TYPE sy-uzeit.

  PERFORM f_zsextrec.

  LOOP AT i_monitor.
    CLEAR: i_custrec,i_vato,lt_holiday,i_bsad,i_detail,i_kna1,l_day,
           l_holiday,l_workday,i_t151t,i_tvv2t,i_pod.
    REFRESH: lt_holiday.

** Baca customer receipt
    READ TABLE i_custrec WITH KEY vbeln = i_monitor-dono BINARY SEARCH.

******* Check data
*****    IF ( i_monitor-bstdk IN s_bstdk AND i_monitor-bstdk NE 0 ) AND
*****       ( i_custrec-crdat IN s_cusdat AND i_custrec-crdat NE 0 ).
*****    ELSE.
*****      CONTINUE.
*****    ENDIF.

** Baca faktur pajak
    READ TABLE i_vato WITH KEY zuonr = i_monitor-zuonr BINARY SEARCH.

** Baca payment
    CLEAR i_bsad.
    READ TABLE i_bsad WITH KEY zuonr = i_monitor-zuonr.
    i_detail-pydat = i_bsad-cpudt.
    i_detail-augdt = i_bsad-augdt.
    i_detail-belnr = i_bsad-belnr.

** Baca sales force group
    READ TABLE i_tvv2t WITH KEY kvgr2 = i_monitor-kvgr2.

** Baca customer group
    READ TABLE i_t151t WITH KEY kdgrp = i_monitor-kdgrp.

** Baca customer
    READ TABLE i_kna1 WITH KEY kunnr = i_monitor-knkli.

    CLEAR : ls_zsextrec, lv_crdat.
    READ TABLE gt_zsextrec INTO ls_zsextrec WITH KEY vbeln = i_monitor-dono.
    IF sy-subrc = 0.
      i_detail-extcrdat  = ls_zsextrec-crdat.
      i_detail-extcrtim  = ls_zsextrec-crtim.
      i_detail-extcreas  = ls_zsextrec-crexdesc.
      lv_crdat           = ls_zsextrec-crdat.
      lv_crtim           = ls_zsextrec-crtim.
    ELSE.
      lv_crdat           = i_custrec-crdat.
      lv_crtim           = i_custrec-crtim.
    ENDIF.

** Check data
    IF ( i_monitor-bstdk IN s_bstdk AND i_monitor-bstdk NE 0 ) AND
       ( lv_crdat IN s_cusdat AND lv_crdat NE 0 ).
    ELSE.
      CONTINUE.
    ENDIF.

** Hitung hari kerja.
    CALL FUNCTION 'HOLIDAY_GET'
      EXPORTING
        holiday_calendar           = 'ID'
        factory_calendar           = 'T1'
        date_from                  = i_monitor-bstdk
        date_to                    = lv_crdat        " i_custrec-crdat
      TABLES
        holidays                   = lt_holiday
      EXCEPTIONS
        factory_calendar_not_found = 1
        holiday_calendar_not_found = 2
        date_has_invalid_format    = 3
        date_inconsistency         = 4
        OTHERS                     = 5.

    DESCRIBE TABLE lt_holiday LINES l_holiday.
*    l_day = i_custrec-crdat - i_monitor-bstdk.
*    l_day = lv_crdat - i_monitor-bstdk.

    CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
      EXPORTING
        date1            = i_monitor-bstdk
        time1            = i_monitor-qttim
        date2            = lv_crdat
        time2            = lv_crtim
      IMPORTING
        datediff         = l_day
      EXCEPTIONS
        invalid_datetime = 1
        OTHERS           = 2.

    l_workday = l_day - l_holiday.

    IF l_workday = 0.
      i_detail-cnt01  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_workday = 1.
      i_detail-cnt02  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_workday = 2.
      i_detail-cnt03  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_workday = 3.
      i_detail-cnt04  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_workday = 4.
      i_detail-cnt05  = 1.
      i_detail-cnt10  = 1.
    ELSEIF l_workday GT 4.
      i_detail-cnt06  = 1.
      i_detail-cnt10  = 1.
    ENDIF.

    PERFORM f_std_count USING i_monitor-knkli lv_crdat i_monitor-bstdk
                              i_monitor-kdgrp i_kna1-katr1 '' l_workday
                              i_monitor-bzirk i_monitor-vkbur
                        CHANGING i_detail-pocr i_detail-kbetr i_detail-valtg i_detail-coun2
                                 i_detail-coun5 i_detail-coun6.

    PERFORM append_data8.
  ENDLOOP.
  PERFORM f_persen_standart.
ENDFORM.                    " PROCESS_DATA8

*&---------------------------------------------------------------------*
*&      Form  APPEND_DATA8
*&---------------------------------------------------------------------*
FORM append_data8 .
  i_detail-vkbur = i_monitor-vkbur.
  i_detail-kvgr2 = i_monitor-kvgr2.
  i_detail-bezei = i_tvv2t-bezei.
  i_detail-kdgrp = i_monitor-kdgrp.
  i_detail-ktext = i_t151t-ktext.
  i_detail-katr1 = i_kna1-katr1.
  i_detail-knkli = i_monitor-knkli.
  i_detail-name1 = i_kna1-name1.
  i_detail-auart = i_monitor-auart.
  i_detail-bstnk = i_monitor-bstnk.
  i_detail-bstdk = i_monitor-bstdk.
  i_detail-qtno  = i_monitor-qtno.
  i_detail-qttim = i_monitor-qttim.
  i_detail-sono  = i_monitor-sono.
  i_detail-sodat = i_monitor-sodat.
  i_detail-sotim = i_monitor-sotim.
  i_detail-dono  = i_monitor-dono.
  i_detail-dodat = i_monitor-dodat.
  i_detail-dotim = i_monitor-dotim.
  i_detail-crdat = i_custrec-crdat.
  i_detail-crtim = i_custrec-crtim.
  i_detail-podat = i_monitor-podat.
  i_detail-potim = i_monitor-potim.
  i_detail-pkdat = i_monitor-pkdat.
  i_detail-pktim = i_monitor-pktim.
  i_detail-gidat = i_monitor-gidat.
  i_detail-gitim = i_monitor-gitim.
  i_detail-podat = i_monitor-podat.
  i_detail-potim = i_monitor-potim.
  i_detail-kwert = i_monitor-kwert.
  i_detail-waerk = i_monitor-waerk.
  i_detail-rejid = i_monitor-rejid.
  i_detail-bnddt = i_monitor-bnddt.

  IF p_slk IS NOT INITIAL.
    i_detail-bzirk = i_monitor-bzirk.
  ENDIF.

  IF i_vato-repdt IS INITIAL.
    i_detail-vatdt = i_vato-vatdt.
    i_detail-vattm = i_vato-vattm.
  ELSE.
    i_detail-vatdt = i_vato-repdt.
    i_detail-vattm = i_vato-reptm.
  ENDIF.
  i_detail-dudat = i_vato-dudat.
  CONCATENATE i_detail-kvgr2 '-' i_detail-bezei INTO i_detail-bezei.

  IF i_detail-kdgrp = 'SB'.
    CLEAR i_detail-bezei.
  ENDIF.

** Baca shipment
  READ TABLE i_vttp WITH KEY vbeln = i_monitor-vttno.
  IF sy-subrc EQ 0.
    i_detail-tknum = i_vttp-tknum.
    i_detail-erdat = i_vttp-erdat.
    i_detail-datbg = i_vttp-datbg.
    IF i_vttp-tplst(2) EQ '05'.
      i_detail-signi = i_vttp-exti1.
    ELSE.
      i_detail-signi = i_vttp-signi.
    ENDIF.
    i_detail-add04  = i_vttp-add04.
  ENDIF.

** Baca BI
  LOOP AT i_zfbi WHERE zuonr = i_monitor-zuonr." AND
    i_detail-bidat = i_zfbi-bidat.
    i_detail-ptype = i_zfbi-ptype.
    IF i_zfbi-tglttf IS NOT INITIAL AND i_zfbi-tglttf NE '00000000'.
      i_detail-tglttf = i_zfbi-tglttf.
    ENDIF.
  ENDLOOP.

  MOVE-CORRESPONDING i_detail TO i_summary.

  IF i_detail-coun2 IS NOT INITIAL.
    i_summary-stdin  = 1.
    i_detail-stdin  = 1.
  ELSE.
    i_summary-stdout  = 1.
    i_detail-stdout  = 1.
  ENDIF.

  PERFORM f_footer_calculate USING i_summary-bezei(2) i_summary-katr1
                                   i_summary-cnt10 i_summary-stdin.

  COLLECT i_summary. CLEAR i_summary.
  APPEND i_detail. CLEAR i_detail.
ENDFORM.                    " APPEND_DATA8

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT8
*&---------------------------------------------------------------------*
FORM f_build_fieldcat8  TABLES ft_report.

  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
    'VKBUR' 'VBAK' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BEZEI' '' '' '' '30' 'Group Outlet' '' '' '' '' '' '' '' '' '' '' '',
    'KDGRP' '' '' '' '10' 'Cust. Grp' '' '' '' '' '' '' '' '' '' '' '',
    'KTEXT' '' '' '' '20' 'Name' '' '' '' '' '' '' '' '' '' '' '',
    'KATR1' '' '' '' '5' 'DK/LK' '' '' '' '' '' '' '' '' '' '' ''.
  IF p_slk IS NOT INITIAL.
    PERFORM f_fieldcatg USING ft_report:
      'BZIRK' 'KNVV' 'BZIRK' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
  ENDIF.
  PERFORM f_fieldcatg USING ft_report:
    'TARGET' '' '' '' '' 'Target' '' '' '' '' '' '' '' '' '' '' '',
    'CNT01' '' '' '' '10' '0 Hari' 'X' 'X' '' '' '' '' '' '' '' '' '',
    'CNT02' '' '' '' '10' '1 Hari' 'X' 'X' '' '' '' '' '' '' '' '' '',
    'CNT03' '' '' '' '10' '2 Hari' 'X' 'X' '' '' '' '' '' '' '' '' '',
    'CNT04' '' '' '' '10' '3 Hari' 'X' 'X' '' '' '' '' '' '' '' '' '',
    'CNT05' '' '' '' '10' '4 Hari' 'X' 'X' '' '' '' '' '' '' '' '' '',
    'CNT06' '' '' '' '10' '>4 Hari' 'X' 'X' '' '' '' '' '' '' '' '' '',
    'CNT09' '' '' 'X' '10' 'Other' 'X' 'X' '' '' '' '' '' '' '' '' '',
    'CNT10' '' '' '' '10' 'Total' 'X' 'X' '' '' '' '' '' '' '' '' ''.

  PERFORM f_fieldcatg USING ft_report:
    'STDIN' '' '' '' '10' 'Std In' 'X' 'X' '' '' '' '' '' '' '' '' '',
    'STDOUT' '' '' '' '10' 'Std Out' 'X' 'X' '' '' '' '' '' '' '' '' ''.
  PERFORM f_fieldcatg USING ft_report:
    'STDPERCEN' '' '' '' '10' 'Std %' '' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_BUILD_FIELDCAT8

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT9
*&---------------------------------------------------------------------*
FORM f_build_fieldcat9  TABLES ft_report.

  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
    'VKBUR' 'VBAK' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'QTN' '' '' '' '10' 'PO' '' 'X' '' '' '' '' '' '' '' '' '',
    'HIT' '' '' '' '10' 'HIT' '' 'X' '' '' '' '' '' '' '' '' '',
    'NHIT' '' '' '' '10' 'Non HIT' '' 'X' '' '' '' '' '' '' '' '' '',
    'HIT%' '' '' '' '10' '% HIT' '' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_BUILD_FIELDCAT9

*&---------------------------------------------------------------------*
*&      Form  F_ADD_FIELD
*&---------------------------------------------------------------------*
FORM f_add_field .
  DATA : lt_detail   LIKE i_detail OCCURS 0 WITH HEADER LINE,
         lt_zsextrec TYPE STANDARD TABLE OF zsextrec INITIAL SIZE 0,
         ls_zsextrec LIKE LINE OF lt_zsextrec.

  DATA : lines    TYPE STANDARD TABLE OF tline INITIAL SIZE 0,
         ls_lines LIKE LINE OF lines,
         lv_name  TYPE thead-tdname.

  lt_detail[] = i_detail[].
  SORT lt_detail BY dono.
  DELETE ADJACENT DUPLICATES FROM lt_detail COMPARING dono.
  IF lt_detail[] IS NOT INITIAL.
    SELECT *
      FROM zsextrec
      INTO CORRESPONDING FIELDS OF TABLE lt_zsextrec
      FOR ALL ENTRIES IN lt_detail
      WHERE vbeln = lt_detail-dono.
    ENDIF.

    LOOP AT i_detail.
      CLEAR ls_zsextrec.
      READ TABLE lt_zsextrec INTO ls_zsextrec WITH KEY vbeln = i_detail-dono.
      IF sy-subrc = 0.
        i_detail-extcrdat  = ls_zsextrec-crdat.
        i_detail-extcrtim  = ls_zsextrec-crtim.
        i_detail-extcreas  = ls_zsextrec-crexdesc.
      ENDIF.

      CLEAR : lines[], lines, lv_name.
      lv_name  = i_detail-qtno.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = '0002'
          language                = sy-langu
          name                    = lv_name
          object                  = 'VBBK'
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

      CLEAR ls_lines.
      READ TABLE lines INTO ls_lines INDEX 1.
      IF sy-subrc = 0.
        i_detail-headt  = ls_lines-tdline.
      ENDIF.

      READ TABLE gt_knvv WITH KEY kunnr = i_detail-knkli.
      IF sy-subrc = 0.
        i_detail-vkbur2 = gt_knvv-vkbur.
      ENDIF.

      MODIFY i_detail TRANSPORTING headt extcrdat extcrtim extcreas vkbur2.
      CLEAR i_detail.
    ENDLOOP.
ENDFORM.                    " F_ADD_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_FOOTER
*&---------------------------------------------------------------------*
FORM f_footer .
  DATA: lv_average TYPE p DECIMALS 2,
        lv_hit     TYPE p DECIMALS 0,
        lv_total   TYPE p DECIMALS 0,
        lv_type(2).

  CASE 'X'.
    WHEN p_radio8.
      WRITE:/ sy-uline(72),
            / sy-vline, (20) 'Channel',
              sy-vline, (6) space,
              sy-vline, (10) 'Total',
              sy-vline, (10) 'HIT',
              sy-vline, (10) '%',
              sy-vline.
      WRITE:/ sy-uline(72).

      PERFORM f_write_footer USING '01' 'Corporate pharma'
                             CHANGING lv_hit lv_total.
      PERFORM f_write_footer USING '02' 'General trade'
                             CHANGING lv_hit lv_total.
      PERFORM f_write_footer USING '03' 'Modern trade'
                             CHANGING lv_hit lv_total.

      lv_average  = ( lv_hit / lv_total ) * 100.

      WRITE:/ sy-vline, (20) 'Total',
              sy-vline, (6) space,
              sy-vline, (10) lv_total,
              sy-vline, (10) lv_hit,
              sy-vline, (10) lv_average,
              sy-vline.
      WRITE:/ sy-uline(72).
  ENDCASE.
ENDFORM.                    " F_FOOTER

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_FOOTER
*&---------------------------------------------------------------------*
FORM f_write_footer  USING    fu_type fu_text
                     CHANGING fc_hit fc_total.
  DATA: lv_text(20),
        lv_average  TYPE p DECIMALS 2.

  CLEAR gt_footer.
  READ TABLE gt_footer WITH KEY type  = fu_type
                                katr1 = 'DK'.
  lv_average  = ( gt_footer-hit / gt_footer-total ) * 100.
  ADD gt_footer-hit TO fc_hit.
  ADD gt_footer-total TO fc_total.

  WRITE: / sy-vline, (20) space,
           sy-vline, (6) 'DK',
           sy-vline, (10) gt_footer-total,
           sy-vline, (10) gt_footer-hit,
           sy-vline, (10) lv_average,
           sy-vline.

  WRITE:/ sy-vline, (20) fu_text,
          sy-vline NO-GAP, sy-uline(47) NO-GAP,
          sy-vline.

  CLEAR gt_footer.
  READ TABLE gt_footer WITH KEY type  = fu_type
                                katr1 = 'LK'.
  lv_average  = ( gt_footer-hit / gt_footer-total ) * 100.
  ADD gt_footer-hit TO fc_hit.
  ADD gt_footer-total TO fc_total.

  WRITE: / sy-vline, (20) space,
           sy-vline, (6) 'LK',
           sy-vline, (10) gt_footer-total,
           sy-vline, (10) gt_footer-hit,
           sy-vline, (10) lv_average,
           sy-vline.
  WRITE:/ sy-uline(72).
ENDFORM.                    " F_WRITE_FOOTER

*&---------------------------------------------------------------------*
*&      Form  F_FOOTER_CALCULATE
*&---------------------------------------------------------------------*
FORM f_footer_calculate  USING    fu_type fu_katr1 fu_total fu_hit.
  gt_footer-type     = fu_type.
  gt_footer-katr1    = fu_katr1.
  gt_footer-total    = fu_total.
  gt_footer-hit      = fu_hit.
  COLLECT gt_footer.
  CLEAR gt_footer.
ENDFORM.                    " F_FOOTER_CALCULATE

*&---------------------------------------------------------------------*
*&      Form  F_SUBHUB_SELECTION
*&---------------------------------------------------------------------*
FORM f_subhub_selection .
  CASE 'X'.
    WHEN p_radio1.
      LOOP AT i_detail.
        IF i_detail-vkbur2 IN s_subhub.
          CONTINUE.
        ELSE.
          DELETE i_detail.
        ENDIF.
      ENDLOOP.
    WHEN p_radio2.
      LOOP AT i_summary.
        IF i_summary-vkbur2 IN s_subhub.
          CONTINUE.
        ELSE.
          DELETE i_summary.
        ENDIF.
      ENDLOOP.
    WHEN p_radio3.
      LOOP AT i_summary.
        IF i_summary-vkbur2 IN s_subhub.
          CONTINUE.
        ELSE.
          DELETE i_summary.
        ENDIF.
      ENDLOOP.
    WHEN p_radio4.
      LOOP AT i_summary.
        IF i_summary-vkbur2 IN s_subhub.
          CONTINUE.
        ELSE.
          DELETE i_summary.
        ENDIF.
      ENDLOOP.
    WHEN p_radio5.
      LOOP AT i_summary.
        IF i_summary-vkbur2 IN s_subhub.
          CONTINUE.
        ELSE.
          DELETE i_summary.
        ENDIF.
      ENDLOOP.
    WHEN p_radio6.
      LOOP AT i_summary.
        IF i_summary-vkbur2 IN s_subhub.
          CONTINUE.
        ELSE.
          DELETE i_summary.
        ENDIF.
      ENDLOOP.
    WHEN p_radio7.
      LOOP AT i_summary.
        IF i_summary-vkbur2 IN s_subhub.
          CONTINUE.
        ELSE.
          DELETE i_summary.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_SUBHUB_SELECTION

*&---------------------------------------------------------------------*
*&      Form  F_ADD_LINES_SO
*&---------------------------------------------------------------------*
FORM f_add_lines_so .
  DATA: lt_vbak TYPE TABLE OF vbak WITH HEADER LINE,
        lt_vbfa LIKE i_vbfa OCCURS 0 WITH HEADER LINE.

  lt_vbfa[] = i_vbfa[].
  SORT lt_vbfa BY vbelv.
  DELETE ADJACENT DUPLICATES FROM lt_vbfa COMPARING vbelv.

  SELECT vbeln erdat erzet auart vkorg vkbur
    INTO CORRESPONDING FIELDS OF TABLE lt_vbak
    FROM vbak FOR ALL ENTRIES IN lt_vbfa
    WHERE vbeln = lt_vbfa-vbelv
      AND auart = 'ZO2O'.

    CLEAR: lt_vbfa,lt_vbfa[].

    LOOP AT i_vbfa.
      READ TABLE lt_vbak WITH KEY vbeln = i_vbfa-vbelv.
      IF sy-subrc = 0.
        lt_vbfa-vbelv    = i_vbfa-vbelv.
        lt_vbfa-posnv    = i_vbfa-posnv.
        lt_vbfa-vbeln    = i_vbfa-vbelv.
        lt_vbfa-posnn    = i_vbfa-posnv.
        lt_vbfa-vbtyp_n  = 'C'.
        lt_vbfa-erdat    = lt_vbak-erdat.
        lt_vbfa-erzet    = lt_vbak-erzet.
        APPEND lt_vbfa.
      ENDIF.
    ENDLOOP.

    IF lt_vbfa[] IS NOT INITIAL.
      APPEND LINES OF lt_vbfa TO i_vbfa.
    ENDIF.
ENDFORM.                    " F_ADD_LINES_SO

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ITAB_MONITOR
*&---------------------------------------------------------------------*
FORM f_modify_itab_monitor .
  DATA: lt_monitor LIKE i_monitor OCCURS 0 WITH HEADER LINE,
        lt_vbak    TYPE TABLE OF vbak WITH HEADER LINE.

  FIELD-SYMBOLS: <fs_monitor> LIKE i_monitor.

  lt_monitor[] = i_monitor[].
  DELETE lt_monitor WHERE vkbur(2) NE 'T2'.

  IF lt_monitor[] IS NOT INITIAL.
    SELECT vbeln zuonr
      INTO CORRESPONDING FIELDS OF TABLE lt_vbak
      FROM vbak FOR ALL ENTRIES IN lt_monitor
      WHERE vbeln = lt_monitor-sono.

      LOOP AT i_monitor ASSIGNING <fs_monitor>
                        WHERE vkbur(2) = 'T2'.
        READ TABLE lt_vbak WITH KEY vbeln = <fs_monitor>-sono.
        IF sy-subrc = 0.
          <fs_monitor>-zuonr = lt_vbak-zuonr.
        ENDIF.
      ENDLOOP.
    ENDIF.
ENDFORM.                    " F_MODIFY_ITAB_MONITOR

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA9
*&---------------------------------------------------------------------*
FORM f_process_data9 .
  DATA: lt_detail LIKE i_detail OCCURS 0 WITH HEADER LINE,
        lt_cdpos  TYPE TABLE OF cdpos WITH HEADER LINE,
        lt_cdhdr  TYPE TABLE OF cdhdr WITH HEADER LINE,
        lv_days   TYPE int4.

  DATA: lv_date TYPE sy-datum,
        lv_time TYPE sy-uzeit.

  lt_detail[] = i_detail[].
  DELETE lt_detail WHERE rejid NE '@0A@'.

  IF lt_detail[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_cdpos
      FROM cdpos FOR ALL ENTRIES IN lt_detail
      WHERE objectclas = 'VERKBELEG'
        AND objectid   = lt_detail-objid
        AND fname      = 'ABGRU'.

      SORT lt_cdpos BY objectclas objectid changenr DESCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_cdpos
             COMPARING objectclas objectid changenr.

      IF lt_cdpos[] IS NOT INITIAL.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_cdhdr
          FROM cdhdr FOR ALL ENTRIES IN lt_cdpos
          WHERE objectclas = lt_cdpos-objectclas
            AND objectid   = lt_cdpos-objectid
            AND changenr   = lt_cdpos-changenr.
        ENDIF.
      ENDIF.

      LOOP AT i_detail.
        IF i_detail-rejid = '@0A@'.
          CLEAR: lt_cdpos,lt_cdhdr,lv_date,lv_time.
          READ TABLE lt_cdpos WITH KEY objectid = i_detail-objid.
          READ TABLE lt_cdhdr WITH KEY objectclas = lt_cdpos-objectclas
                                       objectid   = lt_cdpos-objectid
                                       changenr   = lt_cdpos-changenr.
          IF lt_cdhdr-udate IS INITIAL.
            lv_date = sy-datum.
            lv_time = sy-uzeit.
          ELSE.
            lv_date = i_detail-rejdt = lt_cdhdr-udate.
            lv_time = i_detail-rejtm = lt_cdhdr-utime.
          ENDIF.

          PERFORM f_get_days USING i_detail-bstdk lv_date   "i_detail-rejdt
                             CHANGING lv_days.

          IF lv_days = 0.
            i_detail-hit = 1.
          ELSEIF lv_days = 1.
*        IF i_detail-rejtm LE 160059.
            IF lv_time LE 160059.
              i_detail-hit = 1.
            ELSE.
              i_detail-nhit = 1.
            ENDIF.
          ELSE.
            i_detail-nhit = 1.
          ENDIF.

        ELSE.
          CLEAR: i_detail-rejdt,i_detail-rejtm,lv_date,lv_time.
          IF i_detail-dodat IS INITIAL.
*        lv_days = 9.
            lv_date = sy-datum.
            lv_time = sy-uzeit.
          ELSE.
*        PERFORM f_get_days USING i_detail-bstdk i_detail-dodat
*                           CHANGING lv_days.
            lv_date = i_detail-dodat.
            lv_time = i_detail-dotim.
          ENDIF.
          PERFORM f_get_days USING i_detail-bstdk lv_date   "i_detail-dodat
                             CHANGING lv_days.

          IF lv_days = 0.
            i_detail-hit = 1.
          ELSEIF lv_days = 1.
*        IF i_detail-dotim LE 160059.
            IF lv_time LE 160059.
              i_detail-hit = 1.
            ELSE.
              i_detail-nhit = 1.
            ENDIF.
          ELSE.
            i_detail-nhit = 1.
          ENDIF.
        ENDIF.

        MODIFY i_detail TRANSPORTING rejdt rejtm hit nhit.

        "Collect itab summary
        i_summary9-vkbur  = i_detail-vkbur.
        i_summary9-bezei  = i_detail-bezei.
        i_summary9-qtn    = 1.
        i_summary9-hit    = i_detail-hit.
        i_summary9-nhit   = i_detail-nhit.
        COLLECT i_summary9.
      ENDLOOP.

      LOOP AT i_summary9.
        i_summary9-hit%  = 100 * i_summary9-hit / i_summary9-qtn.
        i_summary9-nhit% = 100 * i_summary9-nhit / i_summary9-qtn.
        MODIFY i_summary9 TRANSPORTING hit% nhit%.
      ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA9

*&---------------------------------------------------------------------*
*&      Form  F_GET_DAYS
*&---------------------------------------------------------------------*
FORM f_get_days  USING    fu_datab
                          fu_datbi
                 CHANGING fc_days.
  DATA: lt_date LIKE rke_dat OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'RKE_SELECT_FACTDAYS_FOR_PERIOD'
    EXPORTING
      i_datab               = fu_datab
      i_datbi               = fu_datbi
      i_factid              = 'T1'
    TABLES
      eth_dats              = lt_date[]
    EXCEPTIONS
      date_conversion_error = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  DESCRIBE TABLE lt_date LINES fc_days.
  SUBTRACT 1 FROM fc_days.
ENDFORM.                    " F_GET_DAYS
