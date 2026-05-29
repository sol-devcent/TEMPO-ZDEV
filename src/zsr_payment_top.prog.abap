REPORT zsr_payment_top MESSAGE-ID zs
                       LINE-SIZE 255 LINE-COUNT 65
                       NO STANDARD PAGE HEADING.

INCLUDE zghsdalv001.  "ALV
INCLUDE zghsdtop005.  "TOP

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS     : p_vkorg LIKE knvv-vkorg DEFAULT '8020' OBLIGATORY
                                         MODIF ID yyy.
SELECT-OPTIONS : s_vkbur FOR knvv-vkbur OBLIGATORY,
                 s_kunnr FOR kna1-kunnr,
                 s_kdgrp FOR knvv-kdgrp,
                 s_matkl FOR mara-matkl,
                 s_matnr FOR mara-matnr MODIF ID mat,
                 s_fkart FOR vbrk-fkart OBLIGATORY,
                 s_fkdat FOR vbrk-fkdat,
                 s_augdt FOR bsad-budat OBLIGATORY MODIF ID xxx.
PARAMETER      : p_gerdat LIKE bsid-budat OBLIGATORY DEFAULT sy-datum MODIF ID zzz,
                 p_bckgrd(1) DEFAULT 'X' NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK lb1 WITH FRAME TITLE text-080.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS ext_p RADIOBUTTON GROUP grp USER-COMMAND outbut DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 3(20) text-003 FOR FIELD ext_p.
SELECTION-SCREEN POSITION 35.
PARAMETERS: l_extpm AS CHECKBOX MODIF ID ext.
SELECTION-SCREEN COMMENT (40) text-005 FOR FIELD l_extpm.
SELECTION-SCREEN END OF LINE.

PARAMETERS histo  RADIOBUTTON GROUP grp.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS l_bill RADIOBUTTON GROUP grp .
SELECTION-SCREEN : COMMENT 3(20) text-004 FOR FIELD l_bill.
SELECTION-SCREEN POSITION 35.
PARAMETERS: l_billm AS CHECKBOX MODIF ID bil.
SELECTION-SCREEN COMMENT (40) text-005 FOR FIELD l_billm.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK lb1.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE text-002.
PARAMETERS: p_vari  LIKE disvariant-variant. " ALV Variant
SELECTION-SCREEN END OF BLOCK block2.

************************************************************************
* AT SELECTION-SCREEN
************************************************************************
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'BIL'.
      screen-active = '0'.
    ENDIF.
    IF ext_p = 'X' OR histo EQ 'X'.
      CLEAR l_billm.
*      IF screen-group1 = 'BIL'.
*        screen-active = '0'.
*      ENDIF.
      IF screen-group1 = 'ZZZ'.
        screen-input = '0'.
        screen-invisible = '1'.
      ENDIF.
    ENDIF.
    IF l_bill = 'X'.
      CLEAR l_extpm.
      IF screen-group1 = 'EXT'.
        screen-active = '0'.
      ENDIF.
      IF screen-group1 = 'XXX'.
        screen-input = '0'.
        screen-invisible = '1'.
      ENDIF.
    ENDIF.
*    IF screen-group1 = 'YYY'.
*      screen-input = '0'.
*    ENDIF.
    IF l_billm = space AND l_extpm = space AND screen-group1 = 'MAT'.
      screen-active = '0'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

*AT SELECTION-SCREEN ON p_spmon.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM f_init_vkorg.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
* for alv variant
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f_f4_for_variant_alv USING p_vari.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  IF p_bckgrd = 'X'.
*    IF sy-batch <> 'X' AND sy-uzeit < '160000'.
*      MESSAGE i014(zz).
*      EXIT.
*    ENDIF.
  ENDIF.

  DATA : hari(4).
  IF s_augdt-high <> '00000000'.
    hari = s_augdt-high - s_augdt-low.
    IF hari > 180.
      MESSAGE i000(zs) WITH 'Selection data terlalu besar, mohon dikurangi'.
      STOP.
    ENDIF.
  ENDIF.

  PERFORM f_init_data.
  PERFORM f_get_data.
  IF histo EQ 'X'.
    PERFORM f_process_data_histo.
    PERFORM f_validate_data.
    PERFORM f_calc_weighted_v1.
*    PERFORM f_calc_weighted.
  ELSE.
    PERFORM f_process_data.
  ENDIF.

  IF l_bill EQ 'X'.
    PERFORM f_ar_open.
  ENDIF.

  DESCRIBE TABLE i_main LINES gv_lines.
  PERFORM f_print_data.

END-OF-SELECTION.

  INCLUDE zghsdalvf05.  "Form ALV


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
*&      Form  f_init_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data.

  CLEAR : i_cust,i_vbrk,i_bsid,i_main.
  REFRESH : i_cust,i_vbrk,i_bsid,i_main.

  SELECT *
    FROM zsrate
    INTO CORRESPONDING FIELDS OF TABLE t_zsrate.

ENDFORM.                    " f_init_data

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA : lt_branch LIKE gt_branch OCCURS 0 WITH HEADER LINE.

  DATA: lt_leg LIKE gt_branch OCCURS 0 WITH HEADER LINE,
        lt_sap LIKE gt_branch OCCURS 0 WITH HEADER LINE,
        lt_bsid LIKE i_bsid OCCURS 0 WITH HEADER LINE.

  r_saknr-low  = '0121000000'.
  r_saknr-high = '0121999999'.
  r_saknr-sign = 'I'.
  r_saknr-option = 'BT'.
  APPEND r_saknr.

* Get Branch
  SELECT a~vstel a~werks a~lgort b~legacy_branch b~live b~mixlive
    INTO CORRESPONDING FIELDS OF TABLE lt_branch
    FROM tvkol AS a JOIN zplbc AS b ON a~werks = b~werks AND
                                       a~lgort = b~lgort
    WHERE a~vstel IN s_vkbur AND
          b~bukrs = p_vkorg.

  lt_leg[] = lt_branch[].
  lt_sap[] = lt_branch[].

*  DELETE lt_leg WHERE live NE space.
*  DELETE lt_sap WHERE live EQ space.

*-----------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '25'
      text       = 'Data is being read...'.
*-----------------------------------------------------*
* Get cust SAP -----------------------------------------------
  IF NOT lt_sap[] IS INITIAL.
    SELECT a~kunnr a~kdgrp a~vkbur a~vwerk a~zterm b~name1
      INTO CORRESPONDING FIELDS OF TABLE i_cust
      FROM knvv AS a JOIN kna1 AS b ON a~kunnr = b~kunnr
      FOR ALL ENTRIES IN lt_sap
      WHERE a~vkbur EQ lt_sap-vstel AND
            a~vkorg EQ p_vkorg      AND
*            a~vtweg EQ '10'         AND
            a~vtweg IN ('10','20')  AND
            a~spart EQ '00'         AND
            a~kdgrp IN s_kdgrp      AND
            a~kunnr IN s_kunnr.
    DELETE i_cust WHERE vwerk EQ space.

    IF p_vkorg = '8070'.
      PERFORM f_get_top_sut.
    ENDIF.
  ENDIF.

* Get cust Legacy -----------------------------------------
  IF NOT lt_leg[] IS INITIAL.
    SELECT a~kunnr a~kdgrp a~vkbur a~vwerk a~zterm b~name1
      INTO CORRESPONDING FIELDS OF TABLE i_custleg
      FROM knvv AS a JOIN kna1 AS b ON a~kunnr = b~kunnr
      FOR ALL ENTRIES IN lt_leg
      WHERE a~vkbur EQ lt_leg-vstel AND
            a~vkorg EQ p_vkorg      AND
*            a~vtweg EQ '10'         AND
            a~vtweg IN ('10','20')  AND
            a~spart EQ '00'         AND
            a~kdgrp IN s_kdgrp      AND
            a~kunnr IN s_kunnr.
    DELETE i_custleg WHERE vwerk EQ space.
  ENDIF.

  PERFORM f_add_customer_mixlive TABLES lt_branch.

*-----------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '50'
      text       = 'Data is being read...'.
*-----------------------------------------------------*
* Select data by option
  CASE 'X'.
    WHEN ext_p OR histo.
* Get Data SAP -----------------------------------------------
      IF i_cust[] IS NOT INITIAL.
        PERFORM f_get_data_sap.
      ENDIF.

*-----------------------------------------------------*
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = '75'
          text       = 'Data is being read...'.
*-----------------------------------------------------*
* Get Data Legacy -----------------------------------------
      IF i_custleg[] IS NOT INITIAL.
        PERFORM f_get_data_legacy.
      ENDIF.

    WHEN l_bill.
* Get Data SAP -----------------------------------------------
      IF NOT i_cust[] IS INITIAL.
        SELECT vbeln kunrg zuonr fkart fkdat vkorg gjahr
          INTO CORRESPONDING FIELDS OF TABLE i_vbrk
          FROM vbrk
          FOR ALL ENTRIES IN i_cust
          WHERE vkorg EQ p_vkorg AND
                kunrg EQ i_cust-kunnr AND
                fkdat IN s_fkdat AND
                fkart IN s_fkart.
        IF sy-subrc = 0.
          LOOP AT i_vbrk.
            i_vbrk-gjahr = i_vbrk-fkdat(4).
            MODIFY i_vbrk TRANSPORTING gjahr.
            CLEAR i_vbrk.
          ENDLOOP.
        ENDIF.
      ENDIF.

      IF NOT i_vbrk[] IS INITIAL.
        SELECT kunnr zuonr zbd1t zfbdt budat dmbtr
               wrbtr waers bukrs gjahr blart belnr
          INTO CORRESPONDING FIELDS OF TABLE i_bsid
          FROM bsid
          FOR ALL ENTRIES IN i_vbrk
          WHERE bukrs = i_vbrk-vkorg AND
                kunnr = i_vbrk-kunrg AND
                umsks IN ('','T')        AND
                umskz IN ('','T')        AND
                zuonr = i_vbrk-zuonr AND
*                gjahr = i_vbrk-gjahr AND
*                blart IN ('RV','DZ','ZA').
                blart IN ('RV','DZ','ZA','DR').

        SELECT kunnr zuonr zbd1t zfbdt budat dmbtr
               wrbtr waers bukrs gjahr blart belnr
          INTO CORRESPONDING FIELDS OF TABLE i_bsad
          FROM bsad
          FOR ALL ENTRIES IN i_vbrk
          WHERE bukrs = i_vbrk-vkorg AND
                kunnr = i_vbrk-kunrg AND
                umsks IN ('','T')        AND
                umskz IN ('','T')        AND
                zuonr = i_vbrk-zuonr AND
*                gjahr = i_vbrk-gjahr AND
*                blart IN ('RV','DZ','ZA').
                blart IN ('RV','DZ','ZA','DR').
      ENDIF.

*-----------------------------------------------------*
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = '75'
          text       = 'Data is being read...'.
*-----------------------------------------------------*
* Get Data Legacy -----------------------------------------
      IF NOT i_custleg[] IS INITIAL.
        CASE p_vkorg.
          WHEN '8020'.
            SELECT vkorg plant vkbur gjahr kunnr vbeln
                   account_no fkart bldat ztop
              INTO CORRESPONDING FIELDS OF TABLE i_hsales
              FROM zsl_hsales
              FOR ALL ENTRIES IN i_custleg
              WHERE vkbur EQ i_custleg-vkbur AND
                    vbtyp IN ('M','O','5')   AND
                    stafjk IN ('X',' ')      AND
                    vkorg EQ p_vkorg         AND
                    bldat IN s_fkdat         AND
                    plant EQ i_custleg-vwerk AND
                    fkart IN s_fkart         AND
                    kunnr EQ i_custleg-kunnr.
          WHEN '8070'.
            SELECT vkorg plant vkbur gjahr kunnr vbeln
                   account_no fkart bldat ztop
              INTO CORRESPONDING FIELDS OF TABLE i_hsales
              FROM zssutdt005
              FOR ALL ENTRIES IN i_custleg
              WHERE vkbur EQ i_custleg-vkbur AND
                    vbtyp IN ('M','O','5')   AND
                    stafjk IN ('X',' ')      AND
                    vkorg EQ p_vkorg         AND
                    bldat IN s_fkdat         AND
                    plant EQ i_custleg-vwerk AND
                    fkart IN s_fkart         AND
                    kunnr EQ i_custleg-kunnr.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.

      IF NOT i_hsales[] IS INITIAL.
        SELECT kunnr zuonr zbd1t zfbdt budat dmbtr
               wrbtr waers bukrs gjahr blart belnr
          INTO CORRESPONDING FIELDS OF TABLE i_bsidleg
          FROM bsid
          FOR ALL ENTRIES IN i_hsales
          WHERE bukrs = i_hsales-vkorg AND
                kunnr = i_hsales-kunnr AND
                umsks IN ('','T')      AND
                umskz IN ('','T')      AND
                zuonr = i_hsales-vbeln AND
*                gjahr = i_hsales-gjahr AND
*                blart IN ('RV','DZ','ZA','DA').
                blart IN ('RV','DZ','ZA','DA','DR').

        SELECT kunnr zuonr zbd1t zfbdt budat dmbtr
               wrbtr waers bukrs gjahr blart belnr
          INTO CORRESPONDING FIELDS OF TABLE i_bsadleg
          FROM bsad
          FOR ALL ENTRIES IN i_hsales
          WHERE bukrs = i_hsales-vkorg AND
                kunnr = i_hsales-kunnr AND
                umsks IN ('','T')     AND
                umskz IN ('','T')     AND
                zuonr = i_hsales-vbeln AND
*                gjahr = i_hsales-gjahr AND
*                blart IN ('RV','DZ','ZA','DA').
                blart IN ('RV','DZ','ZA','DA','DR').
      ENDIF.

      IF i_vbrk[] IS INITIAL AND
         i_hsales[] IS INITIAL.
        MESSAGE i000(zs) WITH 'No record found'.
        STOP.
      ENDIF.
  ENDCASE.

ENDFORM.                    " f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.

  DATA: BEGIN OF ld_term OCCURS 0,
          zterm LIKE t052-zterm,
          ztag1 LIKE t052-ztag1,
        END OF ld_term.

  DATA: ld_cust LIKE i_cust OCCURS 0 WITH HEADER LINE,
        ld_termleg LIKE ld_term OCCURS 0 WITH HEADER LINE,
        lt_makt LIKE makt OCCURS 0 WITH HEADER LINE,
        lt_vbrpmat LIKE i_vbrpmat  OCCURS 0 WITH HEADER LINE,
        lt_dsalesmat LIKE i_dsalesmat  OCCURS 0 WITH HEADER LINE,
        ld_sw(1),
        ld_zbd1t  LIKE bsad-zbd1t,
        lv_zterm LIKE konp-zterm.

*-----------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '100'
      text       = 'Data is being process...'.
*-----------------------------------------------------*
* Get Data TOP -----------------------------------------------
  APPEND LINES OF i_cust TO ld_cust.
  APPEND LINES OF i_custleg TO ld_cust.
  SORT ld_cust BY zterm.
  DELETE ADJACENT DUPLICATES FROM ld_cust COMPARING zterm.

  IF NOT ld_cust[] IS INITIAL.
    SELECT zterm ztag1
      INTO CORRESPONDING FIELDS OF TABLE ld_term
      FROM t052
      FOR ALL ENTRIES IN ld_cust
      WHERE zterm = ld_cust-zterm.
    SORT ld_term BY zterm.
  ENDIF.

  IF p_vkorg = '8070'.
    IF gt_konp[] IS NOT INITIAL.
      SELECT zterm ztag1
        APPENDING CORRESPONDING FIELDS OF TABLE ld_term
        FROM t052
        FOR ALL ENTRIES IN gt_konp
        WHERE zterm = gt_konp-zterm.
      SORT ld_term BY zterm.
      DELETE ADJACENT DUPLICATES FROM ld_term COMPARING zterm.
    ENDIF.
  ENDIF.

* Get Data MATKL ---------------------------------------------
  IF NOT i_vbrk[] IS INITIAL.
    IF l_billm IS INITIAL AND l_extpm IS INITIAL.
      SELECT a~vbeln a~posnr a~matnr a~kzwi1 a~netwr a~mwsbp
             b~matkl
        INTO CORRESPONDING FIELDS OF TABLE i_vbrp
        FROM vbrp AS a JOIN mara AS b ON a~matnr = b~matnr
        FOR ALL ENTRIES IN i_vbrk
        WHERE vbeln = i_vbrk-vbeln AND
              b~matkl IN s_matkl.
    ELSE.
      SELECT a~vbeln a~posnr a~matnr a~kzwi1 a~netwr a~mwsbp
             b~matkl
        INTO CORRESPONDING FIELDS OF TABLE i_vbrp
        FROM vbrp AS a JOIN mara AS b ON a~matnr = b~matnr
        FOR ALL ENTRIES IN i_vbrk
        WHERE a~vbeln = i_vbrk-vbeln AND
              a~matnr IN s_matnr     AND
              b~matkl IN s_matkl.
    ENDIF.
  ENDIF.

  IF NOT i_hsales[] IS INITIAL.
    CASE p_vkorg.
      WHEN '8020'.
        IF l_billm IS INITIAL AND l_extpm IS INITIAL.
          SELECT a~vbeln a~gjahr a~posnr a~matnr a~nsp disa
                 disb disc disd disdc dise disf dissp disvol cod
                 b~matkl
            INTO CORRESPONDING FIELDS OF TABLE i_dsales
            FROM zsl_dsales AS a JOIN mara AS b ON a~matnr = b~matnr
            FOR ALL ENTRIES IN i_hsales
            WHERE vbeln = i_hsales-vbeln(10) AND
                  gjahr = i_hsales-gjahr AND
                  b~matkl IN s_matkl.
        ELSE.
          SELECT a~vbeln a~gjahr a~posnr a~matnr a~nsp disa
                 disb disc disd disdc dise disf dissp disvol cod
                 b~matkl
            INTO CORRESPONDING FIELDS OF TABLE i_dsales
            FROM zsl_dsales AS a JOIN mara AS b ON a~matnr = b~matnr
            FOR ALL ENTRIES IN i_hsales
            WHERE vbeln = i_hsales-vbeln(10) AND
                  gjahr = i_hsales-gjahr AND
                  a~matnr IN s_matnr     AND
                  b~matkl IN s_matkl.
        ENDIF.
      WHEN '8070'.
        IF l_billm IS INITIAL AND l_extpm IS INITIAL.
          SELECT a~vbeln a~gjahr a~posnr a~matnr a~nsp disa
                 disb disc disd disdc dise disf dissp disvol cod
                 b~matkl
            INTO CORRESPONDING FIELDS OF TABLE i_dsales
            FROM zssutdt006 AS a JOIN mara AS b ON a~matnr = b~matnr
            FOR ALL ENTRIES IN i_hsales
            WHERE vbeln = i_hsales-vbeln(10) AND
                  gjahr = i_hsales-gjahr AND
                  b~matkl IN s_matkl.
        ELSE.
          SELECT a~vbeln a~gjahr a~posnr a~matnr a~nsp disa
                 disb disc disd disdc dise disf dissp disvol cod
                 b~matkl
            INTO CORRESPONDING FIELDS OF TABLE i_dsales
            FROM zssutdt006 AS a JOIN mara AS b ON a~matnr = b~matnr
            FOR ALL ENTRIES IN i_hsales
            WHERE vbeln = i_hsales-vbeln(10) AND
                  gjahr = i_hsales-gjahr AND
                  a~matnr IN s_matnr     AND
                  b~matkl IN s_matkl.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.

    SELECT zterm ztag1
      INTO CORRESPONDING FIELDS OF TABLE ld_termleg
      FROM t052
      FOR ALL ENTRIES IN ld_cust
      WHERE zterm = ld_cust-zterm.
  ENDIF.

  LOOP AT i_vbrp.
    MOVE-CORRESPONDING i_vbrp TO i_vbrpsum.
    COLLECT i_vbrpsum. CLEAR  i_vbrpsum.
    MOVE-CORRESPONDING i_vbrp TO i_vbrpmat.
    COLLECT i_vbrpmat. CLEAR  i_vbrpmat.
  ENDLOOP.
  LOOP AT i_dsales.
    MOVE-CORRESPONDING i_dsales TO i_dsalessum.
    COLLECT i_dsalessum. CLEAR i_dsalessum.
    MOVE-CORRESPONDING i_dsales TO i_dsalesmat.
    COLLECT i_dsalesmat. CLEAR i_dsalesmat.
  ENDLOOP.

* Get Material description
  lt_vbrpmat[] = i_vbrpmat[].
  SORT lt_vbrpmat BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_vbrpmat COMPARING matnr.
  lt_dsalesmat[] = i_dsalesmat[].
  SORT lt_dsalesmat BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_dsalesmat COMPARING matnr.

  IF lt_vbrpmat[] IS NOT INITIAL.
    SELECT * FROM makt INTO TABLE lt_makt
      FOR ALL ENTRIES IN lt_vbrpmat
      WHERE matnr = lt_vbrpmat-matnr AND
            spras = sy-langu.
  ENDIF.
  IF lt_dsalesmat[] IS NOT INITIAL.
    SELECT * FROM makt APPENDING TABLE lt_makt
      FOR ALL ENTRIES IN lt_dsalesmat
      WHERE matnr = lt_dsalesmat-matnr AND
            spras = sy-langu.
  ENDIF.
  SORT lt_makt BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_makt COMPARING matnr.

  SORT i_vbrpsum BY vbeln matkl.
  SORT i_dsalessum BY vbeln matkl.
  SORT i_vbrpmat BY vbeln matkl matnr.
  SORT i_dsalesmat BY vbeln matkl matnr.

* Get Data SAP -----------------------------------------------
  IF NOT i_vbrk[] IS INITIAL.
    SORT i_cust BY kunnr.
    SORT i_bsid BY kunnr zuonr budat DESCENDING blart belnr DESCENDING.
    DELETE ADJACENT DUPLICATES FROM i_bsid COMPARING zuonr blart.
    SORT i_bsad BY kunnr zuonr budat DESCENDING blart belnr DESCENDING.
    DELETE ADJACENT DUPLICATES FROM i_bsad COMPARING zuonr blart.
*    SORT i_bsid DESCENDING BY kunnr zuonr budat
*                ASCENDING blart.
*    SORT i_bsad DESCENDING BY kunnr zuonr budat
*                ASCENDING blart.

    LOOP AT i_vbrk.
      SORT ld_term BY zterm.
      CLEAR: i_cust,ld_term.
      READ TABLE i_cust WITH KEY kunnr = i_vbrk-kunrg BINARY SEARCH.
      READ TABLE ld_term WITH KEY zterm = i_cust-zterm BINARY SEARCH.
      i_main-vkbur = i_cust-vkbur.
      i_main-name1 = i_cust-name1.
      i_main-kdgrp = i_cust-kdgrp.
      i_main-fkart = i_vbrk-fkart.
      i_main-fkdat = i_vbrk-fkdat.
      i_main-kunrg = i_vbrk-kunrg.
      i_main-zuonr = i_vbrk-zuonr.
      i_main-ztag1 = ld_term-ztag1.

      IF p_vkorg = '8070'.
        SORT ld_term BY zterm.
        CLEAR: lv_zterm,ld_term.
        PERFORM f_change_top USING i_main-fkart i_main-fkdat
                             CHANGING lv_zterm.
        READ TABLE ld_term WITH KEY zterm = lv_zterm BINARY SEARCH.
        i_main-ztag1 = ld_term-ztag1.
      ENDIF.

      READ TABLE i_bsad WITH KEY kunnr = i_vbrk-kunrg
                                 zuonr = i_vbrk-zuonr
      BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT i_bsad WHERE kunnr = i_vbrk-kunrg AND
                             zuonr = i_vbrk-zuonr.

          i_main-waers = i_bsad-waers.
          IF i_main-fkart+1(1) = 'C' OR i_main-fkart+2(1) = 'S'.
            i_bsad-wrbtr = i_bsad-wrbtr * -1.
          ENDIF.
          CASE i_bsad-blart.
            WHEN 'RV' OR 'ZA'.
*              i_main-ztag1 = i_bsad-zbd1t.
              i_main-zbd1t = i_bsad-zbd1t.
              i_main-zfbdt = i_bsad-zfbdt.
*              i_main-doval = i_bsad-wrbtr.
              i_main-dudat = i_main-zfbdt + i_main-ztag1.
              i_main-aging = i_main-dudat - sy-datum.
              i_main-belnr = i_bsad-belnr.
*            i_main-aropn = i_main-doval.
            WHEN 'DZ'.
              ld_sw = '1'.
*              i_main-bival = i_bsad-wrbtr.
              IF i_bsad-budat GT i_main-budat.
                i_main-budat = i_bsad-budat.
*                i_main-wtval = i_main-tunda * i_main-bival.
              ENDIF.
*              i_main-aging = i_main-dudat - i_main-budat.
*              i_main-aropn = i_main-aropn - i_main-bival.
            WHEN 'DR'.
*              i_main-ztag1 = i_bsad-zbd1t.
*              i_main-zbd1t = i_bsad-zbd1t.
*              i_main-zfbdt = i_bsad-zfbdt.
**              i_main-doval = i_bsad-wrbtr.
*              i_main-dudat = i_main-zfbdt + i_main-ztag1.
*              i_main-aging = i_main-dudat - sy-datum.
              i_main-belnr = i_vbrk-vbeln.
*            i_main-aropn = i_main-doval.
          ENDCASE.
* Revisi by Budi req. by Zul 13/10/2008
          IF l_bill = 'X'.
            IF i_bsad-blart = 'RV'.
              i_main-fkdat = i_bsad-zfbdt.
              i_main-dudat = i_bsad-zfbdt + i_bsad-zbd1t.
            ELSEIF i_bsad-blart = 'DZ' OR i_bsad-blart = 'DA'.
              i_main-dudat = i_bsad-zfbdt + i_bsad-zbd1t.
*              i_main-budat = i_bsad-zfbdt.
            ENDIF.
            i_main-doval = i_bsad-dmbtr.
            i_main-aging = p_gerdat - i_main-fkdat.
          ENDIF.
* End Revisi by Budi req. by Zul 13/10/2008
        ENDLOOP.
        IF i_main-budat <> '00000000'.
          CLEAR i_main-tunda.
          i_main-tunda = i_main-budat - i_main-dudat.
* Revisi by Budi req. by Zul 13/10/2008
          IF l_bill = 'X'.
            i_main-tunda = p_gerdat - i_main-budat.
          ENDIF.
* End Revisi by Budi req. by Zul 13/10/2008
        ENDIF.
      ELSE.
        LOOP AT i_bsid WHERE kunnr = i_vbrk-kunrg AND
                             zuonr = i_vbrk-zuonr.
          i_main-waers = i_bsid-waers.
          IF i_main-fkart+1(1) = 'C' OR i_main-fkart+2(1) = 'S'.
            i_bsid-wrbtr = i_bsid-wrbtr * -1.
          ENDIF.

          CASE i_bsid-blart.
            WHEN 'RV' OR 'ZA'.
*              i_main-ztag1 = i_bsid-zbd1t.
              i_main-zbd1t = i_bsid-zbd1t.
              i_main-zfbdt = i_bsid-zfbdt.
*            i_main-doval = i_bsid-wrbtr.
              i_main-dudat = i_main-zfbdt + i_main-ztag1.
              i_main-aging = i_main-dudat - sy-datum.
              i_main-belnr = i_bsid-belnr.
*            i_main-aropn = i_main-doval.
            WHEN 'DZ'.
*              ld_sw = '1'.
**            i_main-bival = i_bsid-wrbtr.
*              IF i_bsid-budat GT i_main-budat.
*                i_main-budat = i_bsid-budat.
*                i_main-tunda = i_main-budat - i_main-dudat.
**              i_main-wtval = i_main-tunda * i_main-bival.
*              ENDIF.
**            i_main-aging = i_main-dudat - i_main-budat.
**            i_main-aropn = i_main-aropn - i_main-bival.
            WHEN 'DR'.
*              i_main-ztag1 = i_bsid-zbd1t.
*              i_main-zbd1t = i_bsid-zbd1t.
*              i_main-zfbdt = i_bsid-zfbdt.
**            i_main-doval = i_bsid-wrbtr.
*              i_main-dudat = i_main-zfbdt + i_main-ztag1.
*              i_main-aging = i_main-dudat - sy-datum.
              i_main-belnr = i_vbrk-vbeln.
*            i_main-aropn = i_main-doval.
          ENDCASE.
* Revisi by Budi req. by Zul 13/10/2008
          IF l_bill = 'X'.
            IF i_bsid-blart = 'RV'.
              i_main-fkdat = i_bsid-zfbdt.
              i_main-dudat = i_bsid-zfbdt + i_bsid-zbd1t.
*            ELSEIF i_bsid-blart = 'DZ' OR i_bsid-blart = 'DA'.
*              i_main-dudat = i_bsid-zfbdt + i_bsid-zbd1t.
*              i_main-budat = i_bsid-zfbdt.
            ENDIF.
            i_main-doval = i_bsid-dmbtr.
            i_main-aging = p_gerdat - i_main-fkdat.
          ENDIF.
* End Revisi by Budi req. by Zul 13/10/2008
        ENDLOOP.
      ENDIF.

      IF l_billm IS INITIAL AND l_extpm IS INITIAL.
        LOOP AT i_vbrpsum WHERE vbeln = i_main-belnr.
          i_main-netval = i_vbrpsum-netwr + i_vbrpsum-mwsbp.
          IF i_main-fkart+1(1) = 'C' OR i_main-fkart+2(1) = 'S'.
            i_vbrpsum-kzwi1 = i_vbrpsum-kzwi1 * -1.
          ENDIF.
          i_main-matkl = i_vbrpsum-matkl.
          i_main-doval = i_vbrpsum-kzwi1.
          IF ld_sw = '1'.
            CLEAR i_main-aging.
            i_main-bival = i_vbrpsum-kzwi1.
            i_main-wtval = i_main-tunda * i_main-netval.
*            i_main-wtval = i_main-tunda * i_main-bival.
          ENDIF.

* Calculation Rate
          READ TABLE t_zsrate WITH KEY matkl = i_main-matkl.
          IF sy-subrc EQ 0.
            i_main-rate  = i_main-wtval * t_zsrate-rate / 100.
          ELSE.
            READ TABLE t_zsrate WITH KEY extwg = i_main-matkl(3).
            IF sy-subrc EQ 0.
              i_main-rate  = i_main-wtval * t_zsrate-rate / 100.
            ELSE.
              CLEAR: i_main-rate.
            ENDIF.
          ENDIF.

          APPEND i_main.
        ENDLOOP.
      ELSE.
        LOOP AT i_vbrpmat WHERE vbeln = i_main-belnr.
          i_main-netval = i_vbrpmat-netwr + i_vbrpmat-mwsbp.
          IF i_main-fkart+1(1) = 'C' OR i_main-fkart+2(1) = 'S'.
            i_vbrpmat-kzwi1 = i_vbrpmat-kzwi1 * -1.
          ENDIF.
          i_main-matkl = i_vbrpmat-matkl.
          i_main-matnr = i_vbrpmat-matnr.
          i_main-doval = i_vbrpmat-kzwi1.
          CLEAR lt_makt.
          READ TABLE lt_makt WITH KEY matnr = i_main-matnr.
          i_main-maktx = lt_makt-maktx.
          IF ld_sw = '1'.
            CLEAR i_main-aging.
            i_main-bival = i_vbrpmat-kzwi1.
            i_main-wtval = i_main-tunda * i_main-netval.
*            i_main-wtval = i_main-tunda * i_main-bival.
          ENDIF.

* Calculation Rate
          READ TABLE t_zsrate WITH KEY matkl = i_main-matkl.
          IF sy-subrc EQ 0.
            i_main-rate  = i_main-wtval * t_zsrate-rate / 100.
          ELSE.
            READ TABLE t_zsrate WITH KEY extwg = i_main-matkl(3).
            IF sy-subrc EQ 0.
              i_main-rate  = i_main-wtval * t_zsrate-rate / 100.
            ELSE.
              CLEAR: i_main-rate.
            ENDIF.
          ENDIF.

          APPEND i_main.
        ENDLOOP.
      ENDIF.
      CLEAR: i_main, ld_sw.

    ENDLOOP.
  ENDIF.

* Get Data Legacy -----------------------------------------
  IF NOT i_hsales[] IS INITIAL.
    SORT i_custleg BY kunnr.
    SORT i_hsales  BY kunnr vbeln.
    SORT i_bsidleg BY kunnr zuonr budat DESCENDING belnr.
    SORT i_bsadleg BY kunnr zuonr budat DESCENDING belnr.
*    SORT i_bsidleg DESCENDING BY kunnr zuonr budat
*                   ASCENDING blart.
*    SORT i_bsadleg DESCENDING BY kunnr zuonr budat
*                   ASCENDING blart.

    LOOP AT i_hsales.
      CLEAR: i_custleg,ld_term,ld_termleg.
      READ TABLE i_custleg WITH KEY kunnr = i_hsales-kunnr
                           BINARY SEARCH.
      READ TABLE ld_term WITH KEY zterm = i_custleg-zterm.  "08/02/2013
*      READ TABLE ld_termleg WITH KEY zterm = i_hsales-ztop.  "08/02/2013
      i_main-vkbur = i_custleg-vkbur.
      i_main-name1 = i_custleg-name1.
      i_main-kdgrp = i_custleg-kdgrp.
      i_main-fkart = i_hsales-fkart.
      i_main-fkdat = i_hsales-bldat.
      i_main-kunrg = i_hsales-kunnr.
      i_main-zuonr = i_hsales-vbeln.
      i_main-ztag1 = ld_term-ztag1.                         "08/02/2013
*      i_main-ztag1 = ld_termleg-ztag1.                       "08/02/2013

      READ TABLE i_bsadleg WITH KEY kunnr = i_hsales-kunnr
                                    zuonr = i_hsales-vbeln.
      IF sy-subrc = 0.
        CLEAR: ld_zbd1t.
        LOOP AT i_bsadleg WHERE kunnr = i_hsales-kunnr AND
                                zuonr = i_hsales-vbeln.

          i_main-waers = i_bsadleg-waers.
          IF i_hsales-fkart+1(1) = 'C'.
            i_bsadleg-wrbtr = i_bsadleg-wrbtr * -1.
          ENDIF.

          CASE i_bsadleg-blart.
            WHEN 'RV' OR 'ZA' OR 'DR'.
              i_main-zbd1t = i_bsadleg-zbd1t.
              i_main-zfbdt = i_bsadleg-zfbdt.
*            i_main-doval = i_bsadleg-wrbtr.
*              i_main-dudat = i_bsadleg-budat + i_main-ztag1.
**              IF i_bsadleg-blart EQ 'DR'.
**                IF i_main-zbd1t IS NOT INITIAL.
**                  ld_zbd1t  = i_main-zbd1t.
**                  i_main-dudat = i_main-fkdat + i_main-zbd1t.
**                ELSE.
**                  i_main-dudat = i_main-fkdat + ld_zbd1t.
**                ENDIF.
**              ELSE.
              i_main-dudat = i_main-fkdat + i_main-ztag1.
**              ENDIF.
              i_main-aging = i_main-dudat - sy-datum.
              i_main-belnr = i_bsadleg-belnr.
*            i_main-aropn = i_main-doval.
            WHEN 'DZ' OR 'DA'  OR 'ZA'.
              ld_sw = '1'.
*            i_main-bival = i_bsadleg-wrbtr.
              IF i_bsadleg-budat GT i_main-budat.
                i_main-budat = i_bsadleg-budat.
*              i_main-wtval = i_main-tunda * i_main-bival.
              ENDIF.
*            i_main-aging = i_main-dudat - i_main-budat.
*            i_main-aropn = i_main-aropn - i_main-bival.
          ENDCASE.

* Revisi by Budi req. by Zul 13/10/2008
          IF l_bill = 'X'.
            IF i_bsadleg-blart = 'RV'.
              i_main-fkdat = i_bsadleg-zfbdt.
**              i_main-dudat = i_bsadleg-zfbdt + i_bsadleg-zbd1t.
            ELSEIF i_bsadleg-blart = 'DZ' OR i_bsadleg-blart = 'DA' OR i_bsadleg-blart = 'ZA'.
**              i_main-dudat = i_bsadleg-zfbdt + i_bsadleg-zbd1t.
              i_main-budat = i_bsadleg-zfbdt.
            ENDIF.
            IF i_bsadleg-blart = 'ZA'.
              i_main-dudat = i_bsadleg-zfbdt + i_main-ztag1.
            ENDIF.
            i_main-doval = i_bsadleg-dmbtr.
            i_main-aging = p_gerdat - i_main-fkdat.
          ENDIF.
* End Revisi by Budi req. by Zul 13/10/2008
        ENDLOOP.

        IF i_main-budat <> '00000000'.
          CLEAR i_main-tunda.
          i_main-tunda = i_main-budat - i_main-dudat.
* Revisi by Budi req. by Zul 13/10/2008
          IF l_bill = 'X'.
            i_main-tunda = p_gerdat - i_main-budat.
          ENDIF.
* End Revisi by Budi req. by Zul 13/10/2008
        ENDIF.
      ELSE.
        CLEAR: ld_zbd1t.
        LOOP AT i_bsidleg WHERE kunnr = i_hsales-kunnr AND
                                zuonr = i_hsales-vbeln.
          i_main-waers = i_bsidleg-waers.
          IF i_hsales-fkart+1(1) = 'C'.
            i_bsidleg-wrbtr = i_bsidleg-wrbtr * -1.
          ENDIF.

          CASE i_bsidleg-blart.
            WHEN 'RV' OR 'ZA' OR 'DR'.
              i_main-zbd1t = i_bsidleg-zbd1t.
              i_main-zfbdt = i_bsidleg-zfbdt.
*            i_main-doval = i_bsidleg-wrbtr.

*              i_main-dudat = i_bsidleg-budat + i_main-ztag1.
**              IF i_bsadleg-blart EQ 'DR'.
**                IF i_main-zbd1t IS NOT INITIAL.
**                  ld_zbd1t  = i_main-zbd1t.
**                  i_main-dudat = i_main-fkdat + i_main-zbd1t.
**                ELSE.
**                  i_main-dudat = i_main-fkdat + ld_zbd1t.
**                ENDIF.
**              ELSE.
              i_main-dudat = i_main-fkdat + i_main-ztag1.
**              ENDIF.
              i_main-aging = i_main-dudat - sy-datum.
              i_main-belnr = i_bsidleg-belnr.
*            i_main-aropn = i_main-doval.

            WHEN 'DZ' OR 'DA'.
*              ld_sw = '1'.
**            i_main-bival = i_bsidleg-wrbtr.
*              IF i_bsidleg-budat GT i_main-budat.
*                i_main-budat = i_bsidleg-budat.
*                i_main-tunda = i_main-budat - i_main-dudat.
**              i_main-wtval = i_main-tunda * i_main-bival.
*              ENDIF.
**            i_main-aging = i_main-dudat - i_main-budat.
**            i_main-aropn = i_main-aropn - i_main-bival.
          ENDCASE.

* Revisi by Budi req. by Zul 13/10/2008
          IF l_bill = 'X'.
            IF i_bsidleg-blart = 'RV'.
              i_main-fkdat = i_bsidleg-zfbdt.
**              i_main-dudat = i_bsidleg-zfbdt + i_bsidleg-zbd1t.
*            ELSEIF i_bsidleg-blart = 'DZ' OR i_bsidleg-blart = 'DA'.
*              i_main-dudat = i_bsidleg-zfbdt + i_bsidleg-zbd1t.
*              i_main-budat = i_bsidleg-zfbdt.
            ENDIF.
            IF i_bsidleg-blart = 'ZA'.
              i_main-dudat = i_bsidleg-zfbdt + i_main-ztag1.
            ENDIF.
            i_main-doval = i_bsidleg-dmbtr.
            i_main-aging = p_gerdat - i_main-fkdat.
          ENDIF.
* End Revisi by Budi req. by Zul 13/10/2008
        ENDLOOP.
      ENDIF.

      IF l_billm IS INITIAL AND l_extpm IS INITIAL.
        LOOP AT i_dsalessum WHERE vbeln = i_main-zuonr.
          IF i_main-fkart+1(1) = 'C'.
            i_dsalessum-nsp = i_dsalessum-nsp * -1.
          ENDIF.
          i_main-matkl = i_dsalessum-matkl.
          i_main-doval = i_dsalessum-nsp.
          i_main-netval = i_dsalessum-nsp + i_dsalessum-disa  + i_dsalessum-disb +
                          i_dsalessum-disc + i_dsalessum-disd + i_dsalessum-disdc +
                          i_dsalessum-dise + i_dsalessum-disf + i_dsalessum-dissp +
                          i_dsalessum-disvol + i_dsalessum-cod.
          i_main-wvalue = i_main-netval * i_main-tunda.
          IF ld_sw = '1'.
            CLEAR i_main-aging.
            i_main-bival = i_dsalessum-nsp.
            i_main-wtval = i_main-tunda * i_main-netval.
*            i_main-wtval = i_main-tunda * i_main-bival.
          ENDIF.

* Calculation Rate
          READ TABLE t_zsrate WITH KEY matkl = i_main-matkl.
          IF sy-subrc EQ 0.
            i_main-rate  = i_main-wtval * t_zsrate-rate / 100.
          ELSE.
            READ TABLE t_zsrate WITH KEY extwg = i_main-matkl(3).
            IF sy-subrc EQ 0.
              i_main-rate  = i_main-wtval * t_zsrate-rate / 100.
            ELSE.
              CLEAR: i_main-rate.
            ENDIF.
          ENDIF.

          APPEND i_main.
        ENDLOOP.
      ELSE.
        LOOP AT i_dsalesmat WHERE vbeln = i_main-zuonr.
          IF i_main-fkart+1(1) = 'C'.
            i_dsalesmat-nsp = i_dsalesmat-nsp * -1.
          ENDIF.
          i_main-matkl = i_dsalesmat-matkl.
          i_main-matnr = i_dsalesmat-matnr.
          i_main-doval = i_dsalesmat-nsp.
          i_main-netval = i_dsalesmat-nsp + i_dsalesmat-disa  + i_dsalesmat-disb +
                          i_dsalesmat-disc + i_dsalesmat-disd + i_dsalesmat-disdc +
                          i_dsalesmat-dise + i_dsalesmat-disf + i_dsalesmat-dissp +
                          i_dsalesmat-disvol + i_dsalesmat-cod.
          i_main-wvalue = i_main-netval * i_main-tunda.
          CLEAR lt_makt.
          READ TABLE lt_makt WITH KEY matnr = i_main-matnr.
          i_main-maktx = lt_makt-maktx.
          IF ld_sw = '1'.
            CLEAR i_main-aging.
            i_main-bival = i_dsalesmat-nsp.
            i_main-wtval = i_main-tunda * i_main-netval.
*            i_main-wtval = i_main-tunda * i_main-bival.
          ENDIF.

* Calculation Rate
          READ TABLE t_zsrate WITH KEY matkl = i_main-matkl.
          IF sy-subrc EQ 0.
            i_main-rate  = i_main-wtval * t_zsrate-rate / 100.
          ELSE.
            READ TABLE t_zsrate WITH KEY extwg = i_main-matkl(3).
            IF sy-subrc EQ 0.
              i_main-rate  = i_main-wtval * t_zsrate-rate / 100.
            ELSE.
              CLEAR: i_main-rate.
            ENDIF.
          ENDIF.

          APPEND i_main.
        ENDLOOP.
      ENDIF.
      CLEAR: i_main, ld_sw.
    ENDLOOP.
  ENDIF.

  IF ext_p = 'X'.
    DELETE i_main WHERE budat = '00000000'.
    DELETE i_main WHERE tunda <= 0.
  ENDIF.

ENDFORM.                    " f_process_data

*&---------------------------------------------------------------------*
*&      Form  f_print_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_data.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  i_main
                              USING   l_billm l_extpm.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
  PERFORM f_alv_variant_exist USING   p_vari
                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
*   I_INTERFACE_CHECK              = ' '
*   I_BYPASSING_BUFFER             =
*   I_BUFFER_ACTIVE                = ' '
    i_callback_program             = d_repid
    i_callback_pf_status_set       = 'F_SET_PF_STATUS'
    i_callback_user_command        = 'F_USER_COMMAND'
*   I_STRUCTURE_NAME               =
    is_layout                      = d_layout
    it_fieldcat                    = t_alv_fieldcat[]
*   IT_EXCLUDING                   =
*   IT_SPECIAL_GROUPS              =
    it_sort                        = t_alv_isort[]
*   IT_FILTER                      =
*   IS_SEL_HIDE                    =
    i_default                      = 'X'
    i_save                         = 'A'
    is_variant                     = d_alv_variant
    it_events                      = t_alv_event[]
    it_event_exit                  = t_event_exit[]
    is_print                       = d_print
*   IS_REPREP_ID                   =
*   I_SCREEN_START_COLUMN          = 0
*   I_SCREEN_START_LINE            = 0
*   I_SCREEN_END_COLUMN            = 0
*   I_SCREEN_END_LINE              = 0
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER        =
*   ES_EXIT_CAUSED_BY_USER         =
    TABLES
      t_outtab                       = i_main
   EXCEPTIONS
     program_error                  = 1
     OTHERS                         = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " f_print_data

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
ENDFORM.                    " F_HDR_LINE1


*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE2
*&---------------------------------------------------------------------*
*       Client, User text 1, Date and time
*----------------------------------------------------------------------*
FORM f_hdr_line2 USING fu_title.
  DATA:
    ld_sysid(18) VALUE 'Client : XXX(YYY)',
*  ld_datum(18) value 'Date: AA/BB/CCCC'.
    ld_period(36) VALUE 'Bill  Date: AA/BB/CCCC to DD/EE/FFFF',
    ld_datum(10).

*--- system info
  REPLACE 'XXX' WITH sy-sysid(3) INTO ld_sysid.
  REPLACE 'YYY' WITH sy-mandt INTO ld_sysid.
  REPLACE 'AA' WITH s_fkdat-low+6(2) INTO ld_period.
  REPLACE 'BB' WITH s_fkdat-low+4(2) INTO ld_period.
  REPLACE 'CCCC' WITH s_fkdat-low(4) INTO ld_period.
  REPLACE 'DD' WITH s_fkdat-high+6(2) INTO ld_period.
  REPLACE 'EE' WITH s_fkdat-high+4(2) INTO ld_period.
  REPLACE 'FFFF' WITH s_fkdat-high(4) INTO ld_period.

*--- date
*  replace 'AA' with sy-datum+6(2) into ld_datum.
*  replace 'BB' with sy-datum+4(2) into ld_datum.
*  replace 'CCCC' with sy-datum+0(4) into ld_datum.
  WRITE sy-datum TO ld_datum.

*--- output line
  CASE 'X'.
    WHEN ext_p OR histo.
      PERFORM f_hdr_pad_title USING ld_sysid ld_period ld_datum.
    WHEN l_bill.
      PERFORM f_hdr_pad_title USING ld_sysid '' ld_datum.
  ENDCASE.
ENDFORM.                    " F_HDR_LINE2


*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE3
*&---------------------------------------------------------------------*
*       User name, text 2, time
*----------------------------------------------------------------------*
FORM f_hdr_line3 USING fu_title.
  DATA:
    ld_uzeit(5) VALUE 'hh:mm',
    ld_period(36) VALUE 'Clear Date: AA/BB/CCCC to DD/EE/FFFF',
    ld_period1(36) VALUE 'Open Items at key date: GG/HH/IIII',
    ld_uname(21) VALUE 'User:    xx'.

*--- time
  REPLACE 'hh' WITH sy-uzeit(2) INTO ld_uzeit.     " hour
  REPLACE 'mm' WITH sy-uzeit+2(2) INTO ld_uzeit.   " minute

  REPLACE 'AA' WITH s_augdt-low+6(2) INTO ld_period.
  REPLACE 'BB' WITH s_augdt-low+4(2) INTO ld_period.
  REPLACE 'CCCC' WITH s_augdt-low(4) INTO ld_period.
  REPLACE 'DD' WITH s_augdt-high+6(2) INTO ld_period.
  REPLACE 'EE' WITH s_augdt-high+4(2) INTO ld_period.
  REPLACE 'FFFF' WITH s_augdt-high(4) INTO ld_period.
  REPLACE 'GG' WITH p_gerdat+6(2) INTO ld_period1.
  REPLACE 'HH' WITH p_gerdat+4(2) INTO ld_period1.
  REPLACE 'IIII' WITH p_gerdat(4) INTO ld_period1.

*--- user
  REPLACE 'xx' WITH sy-uname INTO ld_uname.

*--- output line
  CASE 'X'.
    WHEN ext_p OR histo.
      PERFORM f_hdr_pad_title USING ld_uname ld_period ld_uzeit.
    WHEN l_bill.
      PERFORM f_hdr_pad_title USING ld_uname ld_period1 ld_uzeit.
  ENDCASE.

ENDFORM.                    " F_HDR_LINE3

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
*&      Form  F_AR_OPEN
*&---------------------------------------------------------------------*
FORM f_ar_open .
  DATA: lt_kna1   LIKE i_main OCCURS 0 WITH HEADER LINE,
        lineitems LIKE bapi3007_2 OCCURS 0 WITH HEADER LINE,
        BEGIN OF lt_ar OCCURS 0,
          kunnr   TYPE kunnr,
          belnr   TYPE belnr_d,
          zuonr   TYPE dzuonr,
          dmbtr   TYPE dmbtr,
        END OF lt_ar,
        return    TYPE bapireturn.

  lt_kna1[] = i_main[].
  SORT lt_kna1 BY kunrg.
  DELETE ADJACENT DUPLICATES FROM lt_kna1 COMPARING kunrg.

  LOOP AT lt_kna1.
    CLEAR: lineitems, lineitems.
    CALL FUNCTION 'BAPI_AR_ACC_GETOPENITEMS'
      EXPORTING
        companycode = p_vkorg
        customer    = lt_kna1-kunrg
        keydate     = p_gerdat
      TABLES
        lineitems   = lineitems.

    SORT lineitems BY customer alloc_nmbr.
    LOOP AT lineitems.
      lt_ar-kunnr   = lineitems-customer.
      lt_ar-zuonr   = lineitems-alloc_nmbr.

      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
        EXPORTING
          currency             = lineitems-loc_currcy
          amount_external      = lineitems-lc_amount
          max_number_of_digits = 13
        IMPORTING
          amount_internal      = lt_ar-dmbtr
          return               = return.
      IF sy-subrc EQ 0.
        IF lineitems-db_cr_ind EQ 'H'.
          lt_ar-dmbtr   = lt_ar-dmbtr * -1.
        ENDIF.
      ENDIF.
      COLLECT lt_ar.
      CLEAR: lt_ar.
    ENDLOOP.
  ENDLOOP.

  SORT i_main BY kunrg zuonr.
  SORT lt_ar BY kunnr zuonr.
  LOOP AT i_main.
    ON CHANGE OF i_main-kunrg OR i_main-zuonr.
      READ TABLE lt_ar WITH KEY kunnr = i_main-kunrg
                                zuonr = i_main-zuonr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        i_main-dmbtr  = lt_ar-dmbtr.
        MODIFY i_main TRANSPORTING dmbtr.
      ENDIF.
    ENDON.
  ENDLOOP.
ENDFORM.                    " F_AR_OPEN

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_HISTO
*&---------------------------------------------------------------------*
FORM f_process_data_histo .

  DATA: BEGIN OF ld_term OCCURS 0,
          zterm LIKE t052-zterm,
          ztag1 LIKE t052-ztag1,
        END OF ld_term.

  DATA: ld_cust LIKE i_cust OCCURS 0 WITH HEADER LINE,
        ld_termleg LIKE ld_term OCCURS 0 WITH HEADER LINE,
        lt_makt LIKE makt OCCURS 0 WITH HEADER LINE,
        lt_vbrpmat LIKE i_vbrpmat  OCCURS 0 WITH HEADER LINE,
        lt_dsalesmat LIKE i_dsalesmat  OCCURS 0 WITH HEADER LINE,
        ld_sw(1),
        ld_zbd1t  LIKE bsad-zbd1t.

*-----------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '100'
      text       = 'Data is being process...'.
*-----------------------------------------------------*
* Get Data TOP -----------------------------------------------
  APPEND LINES OF i_cust TO ld_cust.
  APPEND LINES OF i_custleg TO ld_cust.
  SORT ld_cust BY zterm.
  DELETE ADJACENT DUPLICATES FROM ld_cust COMPARING zterm.

  IF NOT ld_cust[] IS INITIAL.
    SELECT zterm ztag1
      INTO CORRESPONDING FIELDS OF TABLE ld_term
      FROM t052
      FOR ALL ENTRIES IN ld_cust
      WHERE zterm = ld_cust-zterm.
    SORT ld_term BY zterm.
  ENDIF.

* Get Data MATKL ---------------------------------------------
  IF NOT i_vbrk[] IS INITIAL.
    IF l_billm IS INITIAL AND l_extpm IS INITIAL.
      SELECT a~vbeln a~posnr a~matnr a~kzwi1 a~netwr a~mwsbp
             b~matkl
        INTO CORRESPONDING FIELDS OF TABLE i_vbrp
        FROM vbrp AS a JOIN mara AS b ON a~matnr = b~matnr
        FOR ALL ENTRIES IN i_vbrk
        WHERE vbeln = i_vbrk-vbeln AND
              b~matkl IN s_matkl.
    ELSE.
      SELECT a~vbeln a~posnr a~matnr a~kzwi1 a~netwr a~mwsbp
             b~matkl
        INTO CORRESPONDING FIELDS OF TABLE i_vbrp
        FROM vbrp AS a JOIN mara AS b ON a~matnr = b~matnr
        FOR ALL ENTRIES IN i_vbrk
        WHERE a~vbeln = i_vbrk-vbeln AND
              a~matnr IN s_matnr     AND
              b~matkl IN s_matkl.
    ENDIF.
  ENDIF.

  IF NOT i_hsales[] IS INITIAL.
    CASE p_vkorg.
      WHEN '8020'.
        IF l_billm IS INITIAL AND l_extpm IS INITIAL.
          SELECT a~vbeln a~gjahr a~posnr a~matnr a~nsp disa
                 disb disc disd disdc dise disf dissp disvol cod
                 b~matkl
            INTO CORRESPONDING FIELDS OF TABLE i_dsales
            FROM zsl_dsales AS a JOIN mara AS b ON a~matnr = b~matnr
            FOR ALL ENTRIES IN i_hsales
            WHERE vbeln = i_hsales-vbeln(10) AND
                  gjahr = i_hsales-gjahr AND
                  b~matkl IN s_matkl.
        ELSE.
          SELECT a~vbeln a~gjahr a~posnr a~matnr a~nsp disa
                 disb disc disd disdc dise disf dissp disvol cod
                 b~matkl
            INTO CORRESPONDING FIELDS OF TABLE i_dsales
            FROM zsl_dsales AS a JOIN mara AS b ON a~matnr = b~matnr
            FOR ALL ENTRIES IN i_hsales
            WHERE vbeln = i_hsales-vbeln(10) AND
                  gjahr = i_hsales-gjahr AND
                  a~matnr IN s_matnr     AND
                  b~matkl IN s_matkl.
        ENDIF.
      WHEN '8070'.
        IF l_billm IS INITIAL AND l_extpm IS INITIAL.
          SELECT a~vbeln a~gjahr a~posnr a~matnr a~nsp disa
                 disb disc disd disdc dise disf dissp disvol cod
                 b~matkl
            INTO CORRESPONDING FIELDS OF TABLE i_dsales
            FROM zssutdt006 AS a JOIN mara AS b ON a~matnr = b~matnr
            FOR ALL ENTRIES IN i_hsales
            WHERE vbeln = i_hsales-vbeln(10) AND
                  gjahr = i_hsales-gjahr AND
                  b~matkl IN s_matkl.
        ELSE.
          SELECT a~vbeln a~gjahr a~posnr a~matnr a~nsp disa
                 disb disc disd disdc dise disf dissp disvol cod
                 b~matkl
            INTO CORRESPONDING FIELDS OF TABLE i_dsales
            FROM zssutdt006 AS a JOIN mara AS b ON a~matnr = b~matnr
            FOR ALL ENTRIES IN i_hsales
            WHERE vbeln = i_hsales-vbeln(10) AND
                  gjahr = i_hsales-gjahr AND
                  a~matnr IN s_matnr     AND
                  b~matkl IN s_matkl.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.

    SELECT zterm ztag1
      INTO CORRESPONDING FIELDS OF TABLE ld_termleg
      FROM t052
      FOR ALL ENTRIES IN ld_cust
      WHERE zterm = ld_cust-zterm.
  ENDIF.

  LOOP AT i_vbrp.
    MOVE-CORRESPONDING i_vbrp TO i_vbrpsum.
    COLLECT i_vbrpsum. CLEAR  i_vbrpsum.
    MOVE-CORRESPONDING i_vbrp TO i_vbrpmat.
    COLLECT i_vbrpmat. CLEAR  i_vbrpmat.
  ENDLOOP.
  LOOP AT i_dsales.
    MOVE-CORRESPONDING i_dsales TO i_dsalessum.
    COLLECT i_dsalessum. CLEAR i_dsalessum.
    MOVE-CORRESPONDING i_dsales TO i_dsalesmat.
    COLLECT i_dsalesmat. CLEAR i_dsalesmat.
  ENDLOOP.

* Get Material description
  lt_vbrpmat[] = i_vbrpmat[].
  SORT lt_vbrpmat BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_vbrpmat COMPARING matnr.
  lt_dsalesmat[] = i_dsalesmat[].
  SORT lt_dsalesmat BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_dsalesmat COMPARING matnr.

  IF lt_vbrpmat[] IS NOT INITIAL.
    SELECT * FROM makt INTO TABLE lt_makt
      FOR ALL ENTRIES IN lt_vbrpmat
      WHERE matnr = lt_vbrpmat-matnr AND
            spras = sy-langu.
  ENDIF.
  IF lt_dsalesmat[] IS NOT INITIAL.
    SELECT * FROM makt APPENDING TABLE lt_makt
      FOR ALL ENTRIES IN lt_dsalesmat
      WHERE matnr = lt_dsalesmat-matnr AND
            spras = sy-langu.
  ENDIF.
  SORT lt_makt BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_makt COMPARING matnr.

  SORT i_vbrpsum BY vbeln matkl.
  SORT i_dsalessum BY vbeln matkl.
  SORT i_vbrpmat BY vbeln matkl matnr.
  SORT i_dsalesmat BY vbeln matkl matnr.

* Get Data SAP -----------------------------------------------
  IF NOT i_vbrk[] IS INITIAL.
    SORT i_cust BY kunnr.
    SORT i_bsid BY kunnr zuonr budat DESCENDING blart belnr DESCENDING.
    DELETE ADJACENT DUPLICATES FROM i_bsid COMPARING zuonr blart.
    SORT i_bsad BY kunnr zuonr budat DESCENDING blart belnr DESCENDING.
    DELETE ADJACENT DUPLICATES FROM i_bsad COMPARING zuonr blart.

    LOOP AT i_vbrk.
      CLEAR: i_cust,ld_term.
      READ TABLE i_cust WITH KEY kunnr = i_vbrk-kunrg BINARY SEARCH.
      READ TABLE ld_term WITH KEY zterm = i_cust-zterm BINARY SEARCH.
      i_main-vkbur = i_cust-vkbur.
      i_main-name1 = i_cust-name1.
      i_main-kdgrp = i_cust-kdgrp.
      i_main-fkart = i_vbrk-fkart.
      i_main-fkdat = i_vbrk-fkdat.
      i_main-kunrg = i_vbrk-kunrg.
      i_main-zuonr = i_vbrk-zuonr.
      i_main-ztag1 = ld_term-ztag1.
      READ TABLE i_bsad WITH KEY kunnr = i_vbrk-kunrg
                                 zuonr = i_vbrk-zuonr
      BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT i_bsad WHERE kunnr = i_vbrk-kunrg AND
                             zuonr = i_vbrk-zuonr.

          i_main-waers = i_bsad-waers.
          IF i_main-fkart+1(1) = 'C' OR i_main-fkart+2(1) = 'S'.
            i_bsad-wrbtr = i_bsad-wrbtr * -1.
          ENDIF.
          CASE i_bsad-blart.
            WHEN 'RV' OR 'ZA'.
              i_main-zbd1t = i_bsad-zbd1t.
              i_main-zfbdt = i_bsad-zfbdt.
              i_main-dudat = i_main-zfbdt + i_main-ztag1.
              i_main-aging = i_main-dudat - sy-datum.
              i_main-belnr = i_bsad-belnr.
            WHEN 'DZ'.
              ld_sw = '1'.
              IF i_bsad-budat GT i_main-budat.
                i_main-budat = i_bsad-budat.
              ENDIF.
            WHEN 'DR'.
              i_main-belnr = i_vbrk-vbeln.
          ENDCASE.
* Revisi by Budi req. by Zul 13/10/2008
          IF l_bill = 'X'.
            IF i_bsad-blart = 'RV'.
              i_main-fkdat = i_bsad-zfbdt.
              i_main-dudat = i_bsad-zfbdt + i_bsad-zbd1t.
            ELSEIF i_bsad-blart = 'DZ' OR i_bsad-blart = 'DA'.
              i_main-dudat = i_bsad-zfbdt + i_bsad-zbd1t.
              i_main-budat = i_bsad-zfbdt.
            ENDIF.
            i_main-doval = i_bsad-dmbtr.
            i_main-aging = p_gerdat - i_main-fkdat.
          ENDIF.
* End Revisi by Budi req. by Zul 13/10/2008
        ENDLOOP.
        IF i_main-budat <> '00000000'.
          CLEAR i_main-tunda.
          i_main-tunda = i_main-budat - i_main-dudat.
* Revisi by Budi req. by Zul 13/10/2008
          IF l_bill = 'X'.
            i_main-tunda = p_gerdat - i_main-budat.
          ENDIF.
* End Revisi by Budi req. by Zul 13/10/2008
        ENDIF.
      ELSE.
        LOOP AT i_bsid WHERE kunnr = i_vbrk-kunrg AND
                             zuonr = i_vbrk-zuonr.
          i_main-waers = i_bsid-waers.
          IF i_main-fkart+1(1) = 'C' OR i_main-fkart+2(1) = 'S'.
            i_bsid-wrbtr = i_bsid-wrbtr * -1.
          ENDIF.

          CASE i_bsid-blart.
            WHEN 'RV' OR 'ZA'.
              i_main-zbd1t = i_bsid-zbd1t.
              i_main-zfbdt = i_bsid-zfbdt.
              i_main-dudat = i_main-zfbdt + i_main-ztag1.
              i_main-aging = i_main-dudat - sy-datum.
              i_main-belnr = i_bsid-belnr.
            WHEN 'DR'.
              i_main-belnr = i_vbrk-vbeln.
          ENDCASE.
* Revisi by Budi req. by Zul 13/10/2008
          IF l_bill = 'X'.
            IF i_bsid-blart = 'RV'.
              i_main-fkdat = i_bsid-zfbdt.
              i_main-dudat = i_bsid-zfbdt + i_bsid-zbd1t.
            ENDIF.
            i_main-doval = i_bsid-dmbtr.
            i_main-aging = p_gerdat - i_main-fkdat.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF l_billm IS INITIAL AND l_extpm IS INITIAL.
        LOOP AT i_vbrpsum WHERE vbeln = i_main-belnr.
          i_main-netval = i_vbrpsum-netwr + i_vbrpsum-mwsbp.
          i_main-wvalue = i_main-netval * i_main-tunda.
          IF i_main-fkart+1(1) = 'C' OR i_main-fkart+2(1) = 'S'.
            i_vbrpsum-kzwi1 = i_vbrpsum-kzwi1 * -1.
          ENDIF.
          i_main-matkl = i_vbrpsum-matkl.
          i_main-doval = i_vbrpsum-kzwi1.
          IF ld_sw = '1'.
            CLEAR i_main-aging.
            i_main-bival = i_vbrpsum-kzwi1.
            i_main-wtval = i_main-tunda * i_main-netval.
*            i_main-wtval = i_main-tunda * i_main-bival.
          ENDIF.

* Calculation Rate
          READ TABLE t_zsrate WITH KEY matkl = i_main-matkl.
          IF sy-subrc EQ 0.
            i_main-rate  = i_main-wtval * t_zsrate-rate / 100.
          ELSE.
            READ TABLE t_zsrate WITH KEY extwg = i_main-matkl(3).
            IF sy-subrc EQ 0.
              i_main-rate  = i_main-wtval * t_zsrate-rate / 100.
            ELSE.
              CLEAR: i_main-rate.
            ENDIF.
          ENDIF.

          APPEND i_main.
        ENDLOOP.
      ELSE.
        LOOP AT i_vbrpmat WHERE vbeln = i_main-belnr.
          i_main-netval = i_vbrpmat-netwr + i_vbrpmat-mwsbp.
          i_main-wvalue = i_main-netval * i_main-tunda.
          IF i_main-fkart+1(1) = 'C' OR i_main-fkart+2(1) = 'S'.
            i_vbrpmat-kzwi1 = i_vbrpmat-kzwi1 * -1.
          ENDIF.
          i_main-matkl = i_vbrpmat-matkl.
          i_main-matnr = i_vbrpmat-matnr.
          i_main-doval = i_vbrpmat-kzwi1.
          CLEAR lt_makt.
          READ TABLE lt_makt WITH KEY matnr = i_main-matnr.
          i_main-maktx = lt_makt-maktx.
          IF ld_sw = '1'.
            CLEAR i_main-aging.
            i_main-bival = i_vbrpmat-kzwi1.
            i_main-wtval = i_main-tunda * i_main-netval.
*            i_main-wtval = i_main-tunda * i_main-bival.
          ENDIF.

* Calculation Rate
          READ TABLE t_zsrate WITH KEY matkl = i_main-matkl.
          IF sy-subrc EQ 0.
            i_main-rate  = i_main-wtval * t_zsrate-rate / 100.
          ELSE.
            READ TABLE t_zsrate WITH KEY extwg = i_main-matkl(3).
            IF sy-subrc EQ 0.
              i_main-rate  = i_main-wtval * t_zsrate-rate / 100.
            ELSE.
              CLEAR: i_main-rate.
            ENDIF.
          ENDIF.

          APPEND i_main.
        ENDLOOP.
      ENDIF.
      CLEAR: i_main, ld_sw.

    ENDLOOP.
  ENDIF.

* Get Data Legacy -----------------------------------------
  IF NOT i_hsales[] IS INITIAL.
    SORT i_custleg BY kunnr.
    SORT i_hsales  BY kunnr vbeln.
    SORT i_bsidleg BY kunnr zuonr budat DESCENDING belnr.
    SORT i_bsadleg BY kunnr zuonr budat DESCENDING belnr.

    LOOP AT i_hsales.
      CLEAR: i_custleg,ld_term,ld_termleg.
      READ TABLE i_custleg WITH KEY kunnr = i_hsales-kunnr
                           BINARY SEARCH.
      READ TABLE ld_term WITH KEY zterm = i_custleg-zterm.  "08/02/2013
      i_main-vkbur = i_custleg-vkbur.
      i_main-name1 = i_custleg-name1.
      i_main-kdgrp = i_custleg-kdgrp.
      i_main-fkart = i_hsales-fkart.
      i_main-fkdat = i_hsales-bldat.
      i_main-kunrg = i_hsales-kunnr.
      i_main-zuonr = i_hsales-vbeln.
      i_main-ztag1 = ld_term-ztag1.                         "08/02/2013

      READ TABLE i_bsadleg WITH KEY kunnr = i_hsales-kunnr
                                    zuonr = i_hsales-vbeln.
      IF sy-subrc = 0.
        CLEAR: ld_zbd1t.
        LOOP AT i_bsadleg WHERE kunnr = i_hsales-kunnr AND
                                zuonr = i_hsales-vbeln.

          i_main-waers = i_bsadleg-waers.
          IF i_hsales-fkart+1(1) = 'C'.
            i_bsadleg-wrbtr = i_bsadleg-wrbtr * -1.
          ENDIF.

          CASE i_bsadleg-blart.
            WHEN 'RV' OR 'ZA' OR 'DR'.
              i_main-zbd1t = i_bsadleg-zbd1t.
              i_main-zfbdt = i_bsadleg-zfbdt.
              i_main-dudat = i_main-fkdat + i_main-ztag1.
              i_main-aging = i_main-dudat - sy-datum.
              i_main-belnr = i_bsadleg-belnr.
            WHEN 'DZ' OR 'DA'  OR 'ZA'.
              ld_sw = '1'.
              IF i_bsadleg-budat GT i_main-budat.
                i_main-budat = i_bsadleg-budat.
              ENDIF.
          ENDCASE.

* Revisi by Budi req. by Zul 13/10/2008
          IF l_bill = 'X'.
            IF i_bsadleg-blart = 'RV'.
              i_main-fkdat = i_bsadleg-zfbdt.
            ELSEIF i_bsadleg-blart = 'DZ' OR i_bsadleg-blart = 'DA' OR i_bsadleg-blart = 'ZA'.
              i_main-budat = i_bsadleg-zfbdt.
            ENDIF.
            IF i_bsadleg-blart = 'ZA'.
              i_main-dudat = i_bsadleg-zfbdt + i_main-ztag1.
            ENDIF.
            i_main-doval = i_bsadleg-dmbtr.
            i_main-aging = p_gerdat - i_main-fkdat.
          ENDIF.
* End Revisi by Budi req. by Zul 13/10/2008
        ENDLOOP.

        IF i_main-budat <> '00000000'.
          CLEAR i_main-tunda.
          i_main-tunda = i_main-budat - i_main-dudat.
* Revisi by Budi req. by Zul 13/10/2008
          IF l_bill = 'X'.
            i_main-tunda = p_gerdat - i_main-budat.
          ENDIF.
* End Revisi by Budi req. by Zul 13/10/2008
        ENDIF.
      ELSE.
        CLEAR: ld_zbd1t.
        LOOP AT i_bsidleg WHERE kunnr = i_hsales-kunnr AND
                                zuonr = i_hsales-vbeln.
          i_main-waers = i_bsidleg-waers.
          IF i_hsales-fkart+1(1) = 'C'.
            i_bsidleg-wrbtr = i_bsidleg-wrbtr * -1.
          ENDIF.

          CASE i_bsidleg-blart.
            WHEN 'RV' OR 'ZA' OR 'DR'.
              i_main-zbd1t = i_bsidleg-zbd1t.
              i_main-zfbdt = i_bsidleg-zfbdt.
              i_main-dudat = i_main-fkdat + i_main-ztag1.
              i_main-aging = i_main-dudat - sy-datum.
              i_main-belnr = i_bsidleg-belnr.
          ENDCASE.

* Revisi by Budi req. by Zul 13/10/2008
          IF l_bill = 'X'.
            IF i_bsidleg-blart = 'RV'.
              i_main-fkdat = i_bsidleg-zfbdt.
            ENDIF.
            IF i_bsidleg-blart = 'ZA'.
              i_main-dudat = i_bsidleg-zfbdt + i_main-ztag1.
            ENDIF.
            i_main-doval = i_bsidleg-dmbtr.
            i_main-aging = p_gerdat - i_main-fkdat.
          ENDIF.
* End Revisi by Budi req. by Zul 13/10/2008
        ENDLOOP.
      ENDIF.

      IF l_billm IS INITIAL AND l_extpm IS INITIAL.
        LOOP AT i_dsalessum WHERE vbeln = i_main-zuonr.
          IF i_main-fkart+1(1) = 'C'.
            i_dsalessum-nsp = i_dsalessum-nsp * -1.
          ENDIF.
          i_main-matkl = i_dsalessum-matkl.
          i_main-doval = i_dsalessum-nsp.
          i_main-netval = i_dsalessum-nsp + i_dsalessum-disa  + i_dsalessum-disb +
                          i_dsalessum-disc + i_dsalessum-disd + i_dsalessum-disdc +
                          i_dsalessum-dise + i_dsalessum-disf + i_dsalessum-dissp +
                          i_dsalessum-disvol + i_dsalessum-cod.
          i_main-wvalue = i_main-netval * i_main-tunda.
          IF ld_sw = '1'.
            CLEAR i_main-aging.
            i_main-bival = i_dsalessum-nsp.
            i_main-wtval = i_main-tunda * i_main-netval.
*            i_main-wtval = i_main-tunda * i_main-bival.
          ENDIF.

* Calculation Rate
          READ TABLE t_zsrate WITH KEY matkl = i_main-matkl.
          IF sy-subrc EQ 0.
            i_main-rate  = i_main-wtval * t_zsrate-rate / 100.
          ELSE.
            READ TABLE t_zsrate WITH KEY extwg = i_main-matkl(3).
            IF sy-subrc EQ 0.
              i_main-rate  = i_main-wtval * t_zsrate-rate / 100.
            ELSE.
              CLEAR: i_main-rate.
            ENDIF.
          ENDIF.

          APPEND i_main.
        ENDLOOP.
      ELSE.
        LOOP AT i_dsalesmat WHERE vbeln = i_main-zuonr.
          IF i_main-fkart+1(1) = 'C'.
            i_dsalesmat-nsp = i_dsalesmat-nsp * -1.
          ENDIF.
          i_main-matkl = i_dsalesmat-matkl.
          i_main-matnr = i_dsalesmat-matnr.
          i_main-doval = i_dsalesmat-nsp.
          i_main-netval = i_dsalesmat-nsp + i_dsalesmat-disa  + i_dsalesmat-disb +
                          i_dsalesmat-disc + i_dsalesmat-disd + i_dsalesmat-disdc +
                          i_dsalesmat-dise + i_dsalesmat-disf + i_dsalesmat-dissp +
                          i_dsalesmat-disvol + i_dsalesmat-cod.
          i_main-wvalue = i_main-netval * i_main-tunda.
          CLEAR lt_makt.
          READ TABLE lt_makt WITH KEY matnr = i_main-matnr.
          i_main-maktx = lt_makt-maktx.
          IF ld_sw = '1'.
            CLEAR i_main-aging.
            i_main-bival = i_dsalesmat-nsp.
            i_main-wtval = i_main-tunda * i_main-netval.
*            i_main-wtval = i_main-tunda * i_main-bival.
          ENDIF.

* Calculation Rate
          READ TABLE t_zsrate WITH KEY matkl = i_main-matkl.
          IF sy-subrc EQ 0.
            i_main-rate  = i_main-wtval * t_zsrate-rate / 100.
          ELSE.
            READ TABLE t_zsrate WITH KEY extwg = i_main-matkl(3).
            IF sy-subrc EQ 0.
              i_main-rate  = i_main-wtval * t_zsrate-rate / 100.
            ELSE.
              CLEAR: i_main-rate.
            ENDIF.
          ENDIF.

          APPEND i_main.
        ENDLOOP.
      ENDIF.
      CLEAR: i_main, ld_sw.
    ENDLOOP.
  ENDIF.

  DELETE i_main WHERE budat = '00000000'.
*  DELETE i_main WHERE tunda <= 0.
ENDFORM.                    " F_PROCESS_DATA_HISTO

*&---------------------------------------------------------------------*
*&      Form  F_CALC_WEIGHTED
*&---------------------------------------------------------------------*
FORM f_calc_weighted .
  SORT i_main BY vkbur kunrg.
  LOOP AT i_main.
    gt_main-vkbur   = i_main-vkbur.
    gt_main-kunrg   = i_main-kunrg.
    gt_main-ztag1   = i_main-ztag1.
    gt_main-netval  = i_main-netval.
    gt_main-count   = 1.
    COLLECT gt_main.
  ENDLOOP.

  SORT i_main BY vkbur kunrg.
  SORT gt_main BY vkbur kunrg.
  LOOP AT i_main.
    i_main-payday = i_main-ztag1 + i_main-tunda.
    READ TABLE gt_main WITH KEY vkbur = i_main-vkbur
                                kunrg = i_main-kunrg
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      i_main-wdelay   = i_main-wvalue / gt_main-netval.
      i_main-wpayday  = ( gt_main-ztag1 / gt_main-count ) + i_main-wdelay.
      MODIFY i_main TRANSPORTING wdelay wpayday payday.
    ENDIF.
  ENDLOOP.

  LOOP AT i_main.
    gt_sub-vkbur    = i_main-vkbur.
    gt_sub-waers    = i_main-waers.
    gt_sub-netval   = i_main-netval.
    gt_sub-wvalue   = i_main-wvalue.
    gt_sub-tunda    = i_main-tunda.
    gt_sub-payday   = i_main-payday.
    gt_sub-wpayday  = i_main-wpayday.
    gt_sub-count    = 1.
    gt_sub-top      = i_main-ztag1.
    AT END OF vkbur.
      gt_sub-tabindex  = sy-tabix.
    ENDAT.
    AT LAST.
      gt_sub-last     = 1.
    ENDAT.
    COLLECT gt_sub.
    CLEAR gt_sub.

    gt_grand-netval   = i_main-netval.
    gt_grand-wvalue   = i_main-wvalue.
    gt_grand-tunda    = i_main-tunda.
    gt_grand-payday   = i_main-payday.
    gt_grand-wpayday  = i_main-wpayday.
    gt_grand-count    = 1.
    gt_grand-top      = i_main-ztag1.
    COLLECT gt_grand.
    CLEAR gt_grand.
  ENDLOOP.
ENDFORM.                    " F_CALC_WEIGHTED

*&---------------------------------------------------------------------*
*&      Form  F_CALC_WEIGHTED_V1
*&---------------------------------------------------------------------*
FORM f_calc_weighted_v1 .
  DATA: lv_tabix  TYPE sy-tabix,
        lv_ztax1  TYPE dztage,
        lv_count  TYPE i,
        lv_tunda  TYPE i,
        lv_vkbur  TYPE vkbur,
        lv_kunrg  TYPE kunrg,
        lv_payday TYPE p DECIMALS 2.

  SORT i_main BY vkbur kunrg.
  LOOP AT i_main.
    gt_main-vkbur   = i_main-vkbur.
    gt_main-kunrg   = i_main-kunrg.
    gt_main-ztag1   = i_main-ztag1.
    gt_main-netval  = i_main-netval.
    gt_main-count   = 1.
    ADD 1 TO lv_count.
    ADD i_main-tunda  TO lv_tunda.
    AT END OF kunrg.
      gt_main-tunda  = lv_tunda / lv_count.
      CLEAR: lv_tunda, lv_count.
    ENDAT.
    COLLECT gt_main.
    CLEAR gt_main.
  ENDLOOP.

  SORT i_main BY vkbur kunrg.
  SORT gt_main BY vkbur kunrg.
  LOOP AT i_main.
    ADD 1 TO lv_count.
    i_main-payday = i_main-ztag1 + i_main-tunda.
    READ TABLE gt_main WITH KEY vkbur = i_main-vkbur
                                kunrg = i_main-kunrg
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      i_main-wdelay   = i_main-wvalue / gt_main-netval.
      i_main-wpayday  = ( gt_main-ztag1 / gt_main-count ) + i_main-wdelay.
      MODIFY i_main TRANSPORTING wdelay wpayday payday.
    ENDIF.
    ADD i_main-payday TO lv_payday.
    lv_vkbur        = i_main-vkbur.
    lv_kunrg        = i_main-kunrg.
    AT END OF kunrg.
      gt_main-payday = lv_payday / lv_count.
      CLEAR: lv_payday, lv_count.
      MODIFY gt_main TRANSPORTING payday WHERE vkbur EQ lv_vkbur AND
                                               kunrg EQ lv_kunrg.
    ENDAT.
  ENDLOOP.

  CLEAR: lv_vkbur, lv_kunrg, gt_main.
  LOOP AT i_main.
    lv_tabix  = sy-tabix.
    gt_sub-count1    = 1.
    AT NEW kunrg.
      CLEAR: lv_count.
      gt_sub-count    = 1.
    ENDAT.
    ADD 1 TO lv_count.
    gt_sub-vkbur    = i_main-vkbur.
    gt_sub-waers    = i_main-waers.
    gt_sub-netval   = i_main-netval.
    gt_sub-wvalue   = i_main-wvalue.
    gt_sub-wpayday  = i_main-wpayday.
    gt_sub-top      = i_main-ztag1.
    lv_vkbur        = i_main-vkbur.
    lv_kunrg        = i_main-kunrg.
    AT END OF kunrg.
      READ TABLE gt_main WITH KEY vkbur = lv_vkbur
                                  kunrg = lv_kunrg.
      IF sy-subrc EQ 0.
        gt_sub-tunda  = gt_main-tunda.
        gt_sub-payday = gt_main-payday.
      ENDIF.
    ENDAT.

    AT END OF vkbur.
      gt_sub-tabindex  = lv_tabix.
    ENDAT.

    AT LAST.
      gt_sub-last     = 1.
    ENDAT.
    COLLECT gt_sub.
    CLEAR gt_sub.
  ENDLOOP.

  LOOP AT gt_sub.
    AT NEW vkbur.
      gt_grand-count    = 1.
    ENDAT.
    gt_grand-netval   = gt_sub-netval.
    gt_grand-wvalue   = gt_sub-wvalue.
    gt_grand-tunda    = gt_sub-tunda / gt_sub-count.
    gt_grand-payday   = gt_sub-payday / gt_sub-count.
    gt_grand-wpayday  = gt_sub-wpayday.
    gt_grand-top      = gt_sub-top.
    gt_grand-top1     = gt_sub-top / gt_sub-count1.
    AT LAST.
      gt_grand-tabindex = lv_tabix.
    ENDAT.
    COLLECT gt_grand.
    CLEAR: gt_grand, gt_main.
  ENDLOOP.
ENDFORM.                    " F_CALC_WEIGHTED_V1

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
FORM f_validate_data .
  LOOP AT i_main.
    IF s_fkdat[] IS NOT INITIAL.
      IF i_main-fkdat IN s_fkdat.
        CONTINUE.
      ELSE.
        DELETE i_main.
      ENDIF.
    ENDIF.

    IF s_augdt[] IS NOT INITIAL.
      IF i_main-budat IN s_augdt.
        CONTINUE.
      ELSE.
        DELETE i_main.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_VALIDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_INIT_VKORG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_vkorg .
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
ENDFORM.                    " F_INIT_VKORG
*&---------------------------------------------------------------------*
*&      Form  F_GET_TOP_SUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_top_sut .
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_a561
    FROM a561
    WHERE kappl = c_kappl AND
          kschl = c_kschl AND
          vkorg = p_vkorg.
  IF sy-subrc = 0.
    SELECT knumh kopos zterm
      INTO TABLE gt_konp
      FROM konp
      FOR ALL ENTRIES IN gt_a561
      WHERE knumh = gt_a561-knumh.
  ENDIF.
ENDFORM.                    " F_GET_TOP_SUT

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_TOP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_change_top  USING    fu_fkart
                            fu_fkdat
                   CHANGING fc_zterm.
  LOOP AT gt_a561 WHERE auart_sd+2(2) = fu_fkart+2(2).
    IF fu_fkdat BETWEEN gt_a561-datab AND gt_a561-datbi.
      READ TABLE gt_konp WITH KEY knumh = gt_a561-knumh.
      IF sy-subrc = 0.
        fc_zterm = gt_konp-zterm.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHANGE_TOP

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_SAP
*&---------------------------------------------------------------------*
FORM f_get_data_sap .
  SELECT vbrk~vbeln fkart kunrg bsad~zuonr fkdat vkorg
         bsad~gjahr
    INTO CORRESPONDING FIELDS OF TABLE i_vbrk
    FROM vbrk INNER JOIN bsad
    ON   vbrk~vbeln = bsad~belnr AND
         vbrk~vkorg = bsad~bukrs
    FOR ALL entries IN i_cust
    WHERE bsad~bukrs EQ p_vkorg AND
          kunnr EQ i_cust-kunnr AND
          umsks EQ ''           AND
          umskz EQ ''           AND
          augdt IN s_augdt      AND
*              blart EQ 'RV'         AND
          blart IN ('RV','DR')  AND
          vbrk~fkart IN s_fkart.

  SORT i_vbrk BY kunrg zuonr vbeln DESCENDING.
  DELETE ADJACENT DUPLICATES FROM i_vbrk COMPARING zuonr.

  IF NOT i_vbrk[] IS INITIAL.
    SELECT kunnr zuonr zbd1t zfbdt budat
           wrbtr waers bukrs gjahr blart belnr
      INTO CORRESPONDING FIELDS OF TABLE i_bsad
      FROM bsad
      FOR ALL ENTRIES IN i_vbrk
      WHERE bsad~bukrs EQ p_vkorg AND
            kunnr EQ i_vbrk-kunrg AND
            umsks IN ('','T')     AND
            umskz IN ('','T')     AND
*            augdt IN s_augdt      AND
            zuonr EQ i_vbrk-zuonr AND
            hkont IN r_saknr      AND
*                blart IN ('RV','DZ','ZA').
            blart IN ('RV','DZ','ZA','DR').
  ELSE.
    EXIT.
  ENDIF.
ENDFORM.                    " F_GET_DATA_SAP

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_LEGACY
*&---------------------------------------------------------------------*
FORM f_get_data_legacy .
  SELECT kunnr zuonr zbd1t zfbdt budat
         wrbtr waers bukrs gjahr blart belnr
    INTO CORRESPONDING FIELDS OF TABLE i_bsadleg
    FROM bsad
    FOR ALL ENTRIES IN i_custleg
    WHERE bukrs EQ p_vkorg         AND
          kunnr EQ i_custleg-kunnr AND
          umsks IN ('','T')        AND
          umskz IN ('','T')        AND
          augdt IN s_augdt         AND
          hkont IN r_saknr         AND
*                blart IN ('RV','DZ','ZA','DA').
          blart IN ('RV','DZ','ZA','DA','DR').

  IF i_bsadleg[] IS NOT INITIAL.
    CASE p_vkorg.
      WHEN '8020'.
        SELECT vkorg plant vkbur gjahr kunnr vbeln
               account_no fkart bldat ztop
          INTO CORRESPONDING FIELDS OF TABLE i_hsales
          FROM zsl_hsales
          FOR ALL ENTRIES IN i_bsadleg
          WHERE vbeln EQ i_bsadleg-zuonr(10) AND
                vkbur IN s_vkbur         AND
                vkorg EQ p_vkorg         AND
                bldat IN s_fkdat         AND
                fkart IN s_fkart.
      WHEN '8070'.
        SELECT vkorg plant vkbur gjahr kunnr vbeln
               account_no fkart bldat ztop
          INTO CORRESPONDING FIELDS OF TABLE i_hsales
          FROM zssutdt005
          FOR ALL ENTRIES IN i_bsadleg
          WHERE vbeln EQ i_bsadleg-zuonr(10) AND
                vkbur IN s_vkbur         AND
                vkorg EQ p_vkorg         AND
                bldat IN s_fkdat         AND
                fkart IN s_fkart.
      WHEN OTHERS.
    ENDCASE.
  ELSE.
    EXIT.
  ENDIF.
ENDFORM.                    " F_GET_DATA_LEGACY

*&---------------------------------------------------------------------*
*&      Form  F_ADD_CUSTOMER_MIXLIVE
*&---------------------------------------------------------------------*
FORM f_add_customer_mixlive  TABLES   ft_branch STRUCTURE gt_branch.
  LOOP AT ft_branch.
    IF ft_branch-mixlive IS INITIAL.
      CONTINUE.
    ELSE.
      LOOP AT i_cust WHERE vkbur EQ ft_branch-vstel.
        i_custleg  = i_cust.
        APPEND i_custleg.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_ADD_CUSTOMER_MIXLIVE
