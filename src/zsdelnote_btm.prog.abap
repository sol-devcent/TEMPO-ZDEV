*&---------------------------------------------------------------------*
*& Program Name     : xxxxxxxxxxx                                      *
*& Module Name      : FI,CO,MM,SD,PM,QM,PP                             *
*& Author           : xxxxxx xxx , xxxxx xxxxx                         *
*& Functional       :                                                  *
*& Create Date      : dd/mm/yyyy                                       *
*& Program Type     : Report/Enhancement                               *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*& Description      : xxxxxxxxxx xx xxxxxx xxxxxxx xxxx xxxx xxxxx     *
*&                    xxxx xx xxxxxxx xxxx xx xx xx xxxxxxxxx          *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT  zsdelnote_btm NO STANDARD PAGE HEADING.

TABLES: nast,
        tnapr,
        vttk,
        vbak,
        lips,
        likp.
CONSTANTS: _parvw      TYPE knvp-parvw VALUE 'AG',
           _kschl_zn01 TYPE konv-kschl VALUE 'ZN01',
           _kschl_za01 TYPE konv-kschl VALUE 'ZA01',
           _kschl_zf01 TYPE konv-kschl VALUE 'ZF01',
           _kschl_zf02 TYPE konv-kschl VALUE 'ZF02',
           _kschl_zf03 TYPE konv-kschl VALUE 'ZF03',
           _kschl_zf08 TYPE konv-kschl VALUE 'ZF08',
           _kschl_zfa1 TYPE konv-kschl VALUE 'ZFA1',
           _kschl_zv01 TYPE konv-kschl VALUE 'ZV01',
           _kschl_zsd0 TYPE konv-kschl VALUE 'ZSD0',
           _kschl_zsd1 TYPE konv-kschl VALUE 'ZSD1',
           _kschl_zvat TYPE konv-kschl VALUE 'ZVAT',
           _bukrs      TYPE bukrs VALUE '8070',
           _form_large TYPE ssfscreen-fname VALUE 'ZSSUT_F007', "'ZSSUT_F004',
           _form_small TYPE ssfscreen-fname VALUE 'ZSSUT_F005'.

TYPES: BEGIN OF ty_eina,
         infnr TYPE eina-lifnr,
         matnr TYPE eina-matnr,
         lifnr TYPE eina-matnr,
       END OF ty_eina.

DATA: gt_ztax           TYPE TABLE OF ztax WITH HEADER LINE.
DATA: gt_lips           TYPE TABLE OF lips WITH HEADER LINE.
DATA: gt_005            TYPE TABLE OF zmsutdt005 WITH HEADER LINE.
DATA: gt_item           TYPE TABLE OF zssutst006 WITH HEADER LINE.
DATA: gt_detail         TYPE TABLE OF zssutst007 WITH HEADER LINE.
DATA: gt_table_def      TYPE TABLE OF zssutst009 WITH HEADER LINE.
DATA: gt_new            TYPE TABLE OF zsdelnote WITH HEADER LINE.
DATA: gt_nast           TYPE TABLE OF nast WITH HEADER LINE.
DATA: gt_a017           TYPE TABLE OF a017 WITH HEADER LINE.
DATA: gt_eina           TYPE TABLE OF ty_eina WITH HEADER LINE.
DATA: gt_konp           TYPE TABLE OF konp WITH HEADER LINE.
DATA: gt_a934           TYPE TABLE OF a934 WITH HEADER LINE.

DATA: gs_header         TYPE zssutst005.
DATA: xscreen(1)        TYPE c.
DATA: gv_kschl          TYPE sna_kschl.
DATA: gv_style1(1) TYPE c,
      gv_style2(1) TYPE c,
      gv_style3(1) TYPE c,
      gv_style4(1) TYPE c,
      gv_style5(1) TYPE c,
      gv_style6(1) TYPE c,
      gv_batch(1).

DATA: BEGIN OF t_nast_key,
        tknum LIKE vttk-tknum,
      END OF t_nast_key.

DATA: gt_vbap  TYPE TABLE OF vbap WITH HEADER LINE.

DATA : BEGIN OF gt_vbfa OCCURS 0,
         vbelv   TYPE vbeln_von,
         posnv   TYPE posnr_von,
         vbeln   TYPE vbeln_nach,
         posnn   TYPE posnr_nach,
         vbtyp_n TYPE vbtyp_n,
         erdat   TYPE erdat,
         bwart   TYPE bwart,
         posnr   TYPE posnr_von,
         zeile   TYPE mblpo,
         charg   TYPE charg_d,
       END OF gt_vbfa.
DATA : BEGIN OF gt_mseg OCCURS 0,
         mblnr LIKE mseg-mblnr,
         smbln LIKE mseg-smbln,
       END OF gt_mseg.

DATA : BEGIN OF gt_vttp OCCURS 0,
         tknum LIKE vttp-tknum,
         tpnum LIKE vttp-tpnum,
         vbeln LIKE vttp-vbeln,
         erdat LIKE vttp-erdat,
       END OF gt_vttp.

DATA : BEGIN OF gt_vttk OCCURS 0,
         tknum LIKE vttk-tknum,
         erdat LIKE vttk-erdat,
         datbg LIKE vttk-datbg,
         route LIKE vttk-route,
       END OF gt_vttk.
DATA : gs_vttk  LIKE gt_vttk.

DATA : BEGIN OF gt_msegnew OCCURS 0,
         mblnr TYPE mblnr,
         mjahr TYPE mjahr,
         zeile TYPE mblpo,
         matnr TYPE matnr,
         charg TYPE charg_d,
         waers TYPE waers,
         dmbtr TYPE dmbtr,
         menge TYPE menge_d,
         meins TYPE meins,
       END OF gt_msegnew.
DATA : gt_msegsum   LIKE gt_msegnew OCCURS 0 WITH HEADER LINE.


DATA : gv_head_er LIKE zdg2sdstf001h.
DATA : gt_detl_er TYPE TABLE OF zdg2sdstf001d WITH HEADER LINE.

*------------------standard common includes----------------------------*
* Authorization checking macros
INCLUDE zabp_atz.

* common report header and other functions
INCLUDE zabp_header.

* other common functions
INCLUDE zabp_frm.

* BDC Include
INCLUDE zabp_bdc.


*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blxx WITH FRAME TITLE TEXT-dat.
PARAMETERS: p_tdform LIKE ssfscreen-fname DEFAULT 'ZSDELNOTE' NO-DISPLAY,
            p_dest   LIKE tsp03-padest DEFAULT 'TSTTDS6_EP01',
            p_disp   LIKE ssfctrlop-preview  AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK blxx.
INCLUDE zabp_smartform.
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-dat.
PARAMETER: p_vbeln LIKE likp-vbeln ."default '3120000134'.
SELECTION-SCREEN END OF BLOCK data.

START-OF-SELECTION.
  PERFORM f_process.

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS
*&---------------------------------------------------------------------*
FORM f_process .
  PERFORM f_clear_data.
  PERFORM f_get_fr_shipment.
  PERFORM f_get_data.
  " try
*  perform f_combine_data.
  " endtry
  PERFORM f_def_page.

  PERFORM f_new_delivery_note.

  CASE gv_kschl.
    WHEN 'ZDE5' OR 'ZDE7'.
      PERFORM f_new_calc.
    WHEN 'ZT07' OR 'ZT08'.
      PERFORM f_new_calc_fr_shipment.
    WHEN 'ZT09'.
      PERFORM f_new_calc_fr_shipment.
      PERFORM f_calc_pptz03.
  ENDCASE.

  IF d_frm_subrc IS INITIAL.
    CASE gv_kschl.
      WHEN 'ZT08'.
        PERFORM f_syn_form_er.
        PERFORM f_print_form_er.
      WHEN 'ZT09'.
        PERFORM f_print_form_pptz03.
      WHEN OTHERS.
        PERFORM f_print_form.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_PROCESS

*&---------------------------------------------------------------------*
*&      Form  entry
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RETURN_CODE  text
*      -->US_SCREEN    text
*----------------------------------------------------------------------*
FORM entry USING return_code us_screen.
  gv_kschl   = nast-kschl.
  t_nast_key = nast-objky.
  p_vbeln    = nast-objky.
  IF tnapr-fonam IS INITIAL.
    p_tdform  = tnapr-sform.
  ELSE.
    p_tdform   = tnapr-fonam.
  ENDIF.
  CLEAR: return_code, d_frm_subrc.
  p_disp = xscreen = us_screen.
  p_dest = nast-ldest.
*  PERFORM f_cek_authorisasi.
  PERFORM f_process.
  return_code = d_frm_subrc.
ENDFORM.                    "entry

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA: lt_discvc TYPE kwert,
        lv_reswk  TYPE reswk,
        lv_vbeln  LIKE vttp-vbeln.

  DATA: lt_ddstru TYPE TABLE OF zssutst007 WITH HEADER LINE.
  DATA: lt_konv TYPE TABLE OF konv WITH HEADER LINE.
  DATA: lt_lips_matnr TYPE TABLE OF lips WITH HEADER LINE.
  DATA: lt_vbak TYPE TABLE OF vbak WITH HEADER LINE.
  DATA: lr_knumv TYPE RANGE OF vbak-knumv WITH HEADER LINE.
  DATA: lt_lipsx LIKE TABLE OF gt_lips WITH HEADER LINE.

  " __* Reprint
  SELECT * INTO TABLE gt_nast
    FROM nast
    WHERE kappl EQ 'V2'
      AND objky EQ p_vbeln
      AND kschl EQ gv_kschl
      AND vstat EQ '1'.
  IF sy-subrc EQ 0 AND sy-ucomm = 'PRNT'.
    AUTHORITY-CHECK OBJECT 'ZREPRINT'
        ID 'ACTVT' FIELD '04'.
    IF sy-subrc NE 0.
      MESSAGE 'You are not authorization' TYPE 'I'.
      LEAVE SCREEN.
    ENDIF.

    LOOP AT gt_nast.
      IF gs_header-reprint IS INITIAL.
        gs_header-reprint = 'X'.
      ELSE.
        CONCATENATE gs_header-reprint 'X' INTO gs_header-reprint.
      ENDIF.
    ENDLOOP.
  ENDIF.

  READ TABLE gt_vttp INDEX 1.
  IF sy-subrc = 0.
    lv_vbeln  =  gt_vttp-vbeln.
  ENDIF.

  " __* Header
  SELECT SINGLE * FROM likp WHERE vbeln = lv_vbeln.
  IF sy-subrc = 0.
    gs_header-lprio = likp-lprio.
    gs_header-lifex = likp-lifex.
*    SELECT SINGLE bezei INTO gs_header-bezei
*      FROM tprit WHERE spras = sy-langu AND lprio = gs_header-lprio.
    IF gt_vttp[] IS NOT INITIAL.
      SELECT *
        FROM ztax
        INTO TABLE gt_ztax
        FOR ALL ENTRIES IN gt_vttp
        WHERE doc_num  = gt_vttp-vbeln.

      SELECT *
        FROM lips
        INTO TABLE gt_lips
        FOR ALL ENTRIES IN gt_vttp
        WHERE vbeln  = gt_vttp-vbeln.
    ENDIF.
    " __* Adrress/City1/
    READ TABLE gt_lips INDEX 1.
    IF sy-subrc = 0.
      " __* Account Bank
      PERFORM f_get_account_bank USING likp-vkorg gt_lips-vkbur.

      " temporary copy
      lt_lipsx[] = gt_lips[].
      " VBAK all
      SELECT * FROM vbak INTO TABLE lt_vbak FOR ALL ENTRIES IN gt_lips WHERE vbeln = gt_lips-vgbel.
      IF sy-subrc = 0.
        LOOP AT lt_vbak.
          lr_knumv-sign = 'I'.
          lr_knumv-option = 'EQ'.
          lr_knumv-low = lt_vbak-knumv.
          APPEND lr_knumv.
        ENDLOOP.
        SORT lr_knumv BY low.
        DELETE ADJACENT DUPLICATES FROM lr_knumv COMPARING low.
      ENDIF.
      " __* get data from ZMSUTDT005
      lt_lips_matnr[] = gt_lips[].
      SORT lt_lips_matnr BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_lips_matnr COMPARING matnr.
      IF lt_lips_matnr[] IS NOT INITIAL.
        SELECT * FROM zmsutdt005 INTO TABLE gt_005 FOR ALL ENTRIES IN lt_lips_matnr
          WHERE matnr = lt_lips_matnr-matnr AND bukrs = likp-vkorg.
      ENDIF.
      DATA ls_tvbur TYPE tvbur.
      SELECT SINGLE * FROM tvbur INTO ls_tvbur WHERE vkbur = gt_lips-vkbur.
      IF sy-subrc = 0.
        DATA ls_adrc TYPE adrc.
        SELECT SINGLE * FROM adrc INTO ls_adrc WHERE addrnumber = ls_tvbur-adrnr.
        IF sy-subrc = 0.
          gs_header-street     = ls_adrc-street. " ------------------------------------------------------------------------------------->
          gs_header-city1      = ls_adrc-city1.  " ------------------------------------------------------------------------------------->
          gs_header-tel_number = ls_adrc-tel_number.
          gs_header-fax_number = ls_adrc-fax_number.
        ENDIF.
*        " --------------------------------------------------------------------------------------------------------- SUpervisor & PBF Name & TTd ---> 38 39
*        DATA: ls_zsign_sp TYPE zsign_sp,
*              ls_zsign_bm TYPE zsign_bm,
*              ls_zsign    TYPE zsign,
*              ls_zscl_class TYPE zscl_class,
*              ls_zscl_range TYPE zscl_range.
*        SELECT SINGLE * FROM zscl_class INTO ls_zscl_class WHERE vkbur = gt_lips-vkbur.
*        IF sy-subrc = 0.
*          SELECT SINGLE * FROM zscl_range INTO ls_zscl_range WHERE zclass = ls_zscl_class-zclass AND zrange EQ 1.
*        ENDIF.
*        IF gs_header-kwertc37 < ls_zscl_range-zvalue_high.
*          SELECT SINGLE * FROM zsign_sp INTO ls_zsign_sp WHERE s_point = gt_lips-vkbur AND sales_group = gt_lips-vkgrp.
*          IF sy-subrc = 0.
*            gs_header-object_sp = ls_zsign_sp-object_name.
*            gs_header-name_sp   = ls_zsign_sp-user_name.
*          ENDIF.
*        ELSE.
*          SELECT SINGLE * FROM zsign_bm INTO ls_zsign_bm WHERE s_point = gt_lips-vkbur.
*          IF sy-subrc = 0.
*            gs_header-object_sp = ls_zsign_bm-object_name.
*            gs_header-name_sp   = ls_zsign_bm-user_name.
*          ENDIF.
*        ENDIF.
*        SELECT SINGLE * FROM zsign INTO ls_zsign WHERE s_point = gt_lips-vkbur.
*        IF sy-subrc = 0.
*          gs_header-object_pbf = ls_zsign-object_name.
*          gs_header-name_pbf   = ls_zsign-user_name.
*          gs_header-sk_pbf     = ls_zsign-no_sk.
*        ENDIF.
      ENDIF.
*      " __* Pbf No
*      DATA ls_zpbf TYPE zpbf.
*      SELECT SINGLE * FROM zpbf INTO ls_zpbf WHERE vkbur = gt_lips-vkbur.
*      IF sy-subrc = 0.
*        gs_header-pbfno = ls_zpbf-pbfno.
*      ENDIF.
      " __* AUART/MAHDT
      DATA ls_vbak TYPE vbak.
*        SELECT SINGLE * FROM vbak INTO ls_vbak WHERE vbeln = gt_lips-vgbel.
      READ TABLE lt_vbak INTO ls_vbak INDEX 1.
      IF sy-subrc = 0.
        gs_header-auart = ls_vbak-auart.
        gs_header-mahdt = ls_vbak-mahdt.
        gs_header-augru = ls_vbak-augru.
        gs_header-bstnk = ls_vbak-bstnk.
        gs_header-vbelna = ls_vbak-vbeln.
        gs_header-erdat = ls_vbak-erdat.
        " __
        IF ls_vbak-abrvw = 'M'.
          gs_header-kr1 = 'X'.
        ELSEIF ls_vbak-abrvw = 'E'.
          gs_header-kr2 = 'X'.
        ENDIF.
      ENDIF.
      " __* kode & nama salesman
      DATA ls_vbpa TYPE vbpa.
      SELECT SINGLE * FROM vbpa INTO ls_vbpa WHERE vbeln = gt_lips-vgbel
                                               AND parvw = 'VE'.
      IF sy-subrc = 0.
        gs_header-pernr = ls_vbpa-pernr.
        DATA ls_pa0001 TYPE pa0001.
        SELECT SINGLE * FROM pa0001 INTO ls_pa0001 WHERE pernr = gs_header-pernr AND endda = '99991231'.
        IF sy-subrc = 0.
          gs_header-sname = ls_pa0001-sname.
        ENDIF.
        SHIFT gs_header-pernr LEFT DELETING LEADING '0'.
      ENDIF.
      " __* Rayon salesman
      DATA lv_rayon	  TYPE name1_gp.
      CLEAR : ls_vbpa, lv_rayon.
      SELECT SINGLE * FROM vbpa INTO ls_vbpa WHERE vbeln = gt_lips-vgbel
                                               AND parvw = 'ZS'.
      IF sy-subrc = 0.
        CLEAR gs_header-rayon.
        SELECT SINGLE name1 INTO lv_rayon
          FROM kna1 WHERE kunnr = ls_vbpa-kunnr.
        IF sy-subrc = 0.
          gs_header-rayon = lv_rayon(9).
        ENDIF.
      ENDIF.
      " __* item HEADER
      DATA: lt_lipsh  TYPE TABLE OF lips WITH HEADER LINE, " item header
            lt_lipsh2 TYPE TABLE OF lips WITH HEADER LINE. " item header unique only
      DATA: lt_lipsh3 TYPE TABLE OF lips WITH HEADER LINE.
      " __* valid data HEADER + BATCH
      lt_lipsh[] = gt_lips[].
      SORT lt_lipsh BY uecha.
      DELETE lt_lipsh WHERE uecha IS NOT INITIAL.
      " __* collect item HEADER (main material) by UEPOS ...
      lt_lipsh2[] = lt_lipsh[].
      SORT lt_lipsh2 BY uepos.
      DELETE lt_lipsh2 WHERE uepos IS NOT INITIAL.
      " __> select from konv for kbetr
      IF lt_lipsh[] IS NOT INITIAL AND
        lr_knumv[] IS NOT INITIAL.
        SELECT * FROM konv INTO TABLE lt_konv FOR ALL ENTRIES IN lt_lipsh WHERE kposn = lt_lipsh-vgpos
                                                                     AND   ( kschl = _kschl_zn01 OR
                                                                             kschl = _kschl_za01 OR
                                                                             kschl = _kschl_zv01 OR
                                                                             kschl = _kschl_zvat OR     "SSP value
                                                                             kschl LIKE 'ZB%' OR
                                                                             kschl LIKE 'ZC%' OR
                                                                             kschl LIKE 'ZD%' OR
                                                                             kschl LIKE 'ZE%' OR
*                                                                             kschl = _kschl_zf01 OR
*                                                                             kschl = _kschl_zf02 )
                                                                             kschl LIKE 'ZF%' )
                                                                     AND     knumv IN lr_knumv[].
*                                                                       AND     knumv = ls_vbak-knumv.
      ENDIF.

      IF gv_kschl = 'ZDE5' OR gv_kschl = 'ZDE7'.
        PERFORM f_collect_pricing TABLES lt_konv
                                  USING  ls_vbak-vbeln.
      ENDIF.

      lt_lipsh3[] = gt_lips[].
      SORT lt_lipsh3 BY uecha.
      DELETE lt_lipsh3 WHERE uecha IS INITIAL.
      IF lt_lipsh3[] IS NOT INITIAL.
        gv_batch = 'X'.
      ENDIF.

      " __* loop per item header and transfer to itab item header
      DATA lv_sum27 TYPE kwert.
      DATA lt_007 TYPE TABLE OF zssutst007 WITH HEADER LINE.
      DATA lv_tabix LIKE sy-tabix.
      DATA lv_insert_tabix TYPE i.
      CLEAR: gs_header-kwert34a, gs_header-kwert34b, gs_header-kwert35, gs_header-kwert36, gs_header-kwert37.

      BREAK sap_dev02.
      LOOP AT lt_lipsh2. " header (main material)
        MOVE sy-tabix TO lv_tabix.
        LOOP AT lt_lipsh WHERE vbeln = lt_lipsh2-vbeln
                           AND uepos = lt_lipsh2-posnr. " free good
          IF lt_lipsh-matnr = lt_lipsh2-matnr.
            CONTINUE.
          ELSE.
            lv_insert_tabix = lv_tabix + 1.
            INSERT lt_lipsh INTO lt_lipsh2 INDEX lv_insert_tabix.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      " LOOP HEADER MATERIAL
      LOOP AT lt_lipsh2. " => loop Header (main material) only
        CLEAR: lv_sum27, gt_item.
        MOVE-CORRESPONDING lt_lipsh2 TO gt_item.

        " __* LFIMG (24)
        READ TABLE lt_lipsh3 WITH KEY vbeln = lt_lipsh2-vbeln
                                      uecha = lt_lipsh2-posnr.

        IF sy-subrc = 0.
          CLEAR gt_item-lfimg.
          LOOP AT lt_lipsh WHERE vbeln = lt_lipsh2-vbeln
                             AND matnr = lt_lipsh2-matnr. " AND uecha = lt_lipsh2-posnr.
            IF lt_lipsh-posnr = lt_lipsh2-posnr.
              IF lt_lipsh-lfimg IS NOT INITIAL.
                gt_item-lfimg = gt_item-lfimg + lt_lipsh-lfimg.
              ELSE.
                gt_item-lfimg = gt_item-lfimg + lt_lipsh-kcmeng.
              ENDIF.
*          ELSEIF lt_lipsh-uepos = lt_lipsh2-vgpos OR lt_lipsh-vgpos = lt_lipsh2-uepos.
*            IF lt_lipsh-lfimg IS NOT INITIAL.
*              gt_item-lfimg = gt_item-lfimg + lt_lipsh-lfimg.
*            ELSE.
*              gt_item-lfimg = gt_item-lfimg + lt_lipsh-kcmeng.
*            ENDIF.
            ELSEIF lt_lipsh-uepos = lt_lipsh2-posnr.
              IF lt_lipsh-lfimg IS NOT INITIAL.
                gt_item-lfimg = gt_item-lfimg + lt_lipsh-lfimg.
              ELSE.
                gt_item-lfimg = gt_item-lfimg + lt_lipsh-kcmeng.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ELSE.
          PERFORM f_get_lfimg_without_bs TABLES lt_lipsh
                                                lt_lipsh2.
        ENDIF.

        " __* KWERT (25)
        CLEAR lt_vbak.
        READ TABLE lt_vbak WITH KEY vbeln = lt_lipsh2-vgbel.
*          if sy-subrc = 0.
        CLEAR lt_konv.
        READ TABLE lt_konv WITH KEY kposn = lt_lipsh2-vgpos
                                    kschl = _kschl_zn01
                                    knumv = lt_vbak-knumv.
        IF sy-subrc = 0.
          gt_item-kwert = lt_konv-kbetr.
          PERFORM f_excl_tax CHANGING gt_item-kwert.
          WRITE gt_item-kwert TO gt_item-kwertc25 CURRENCY 'IDR' NO-SIGN.
          CONDENSE gt_item-kwertc25.
        ENDIF.
*          endif.
        " __* KWERT26
        gt_item-kwert26 = gt_item-lfimg * gt_item-kwert.
        WRITE gt_item-kwert26 TO gt_item-kwertc26 CURRENCY 'IDR'.
        CONDENSE gt_item-kwertc26.
        " __* discount A (27)
        CLEAR gt_item-discva.
        CLEAR: gt_item-discvb, gt_item-discvc, gt_item-discvd, gt_item-discve, gt_item-discvf1, gt_item-discvf2.
        CLEAR: gt_item-discpb, gt_item-discpc, gt_item-discpd, gt_item-discpe, gt_item-discpf1, gt_item-discpf2.

        LOOP AT lt_lipsx WHERE vbeln = lt_lipsh2-vbeln
                           AND matnr = lt_lipsh2-matnr
                           AND uecha IS INITIAL
                           AND posnr = lt_lipsh2-posnr.

          READ TABLE lt_konv WITH KEY kschl = _kschl_za01
                                      kposn = lt_lipsx-vgpos
                                      knumv = lt_vbak-knumv.
          IF sy-subrc = 0.
            gt_item-discva = gt_item-discva + lt_konv-kwert * -1.
            PERFORM f_excl_tax CHANGING gt_item-discva.
          ELSE.
            " __* sekarang ada diskon di freegoods, jadi cek diskon di freegoods
            LOOP AT lt_lipsh WHERE vbeln = lt_lipsh2-vbeln
                               AND uepos = lt_lipsh2-posnr
                               AND matnr = lt_lipsx-matnr.
              READ TABLE lt_konv WITH KEY kschl = _kschl_za01
                                          kposn = lt_lipsh-vgpos
                                          knumv = lt_vbak-knumv.
              IF sy-subrc = 0.
                gt_item-discva = gt_item-discva + lt_konv-kwert * -1.
                PERFORM f_excl_tax CHANGING gt_item-discva.
              ENDIF.
            ENDLOOP.
          ENDIF.

          READ TABLE lt_konv WITH KEY kschl = _kschl_zf01
                                      kposn = lt_lipsx-vgpos
                                      knumv = lt_vbak-knumv.
          IF sy-subrc = 0.
            gt_item-discpf1 = lt_konv-kbetr / -10 .
            PERFORM f_excl_tax CHANGING gt_item-discpf1.
          ELSE.
            " __* sekarang ada diskon di freegoods, jadi cek diskon di freegoods
            LOOP AT lt_lipsh WHERE uepos = lt_lipsh2-posnr
                               AND vbeln = lt_lipsx-vbeln
                               AND matnr = lt_lipsx-matnr.
              READ TABLE lt_konv WITH KEY kschl = _kschl_zf01
                                          kposn = lt_lipsh-vgpos
                                          knumv = lt_vbak-knumv.
              IF sy-subrc = 0.
                gt_item-discpf1 = lt_konv-kbetr / -10 .
                PERFORM f_excl_tax CHANGING gt_item-discpf1.
              ENDIF.
            ENDLOOP.
          ENDIF.

          READ TABLE lt_konv WITH KEY kschl = _kschl_zf02
                                      kposn = lt_lipsx-vgpos
                                      knumv = lt_vbak-knumv.
          IF sy-subrc = 0.
            gt_item-discpf2 = lt_konv-kbetr / -10 .
            PERFORM f_excl_tax CHANGING gt_item-discpf2.
          ELSE.
            " __* sekarang ada diskon di freegoods, jadi cek diskon di freegoods
            LOOP AT lt_lipsh WHERE uepos = lt_lipsh2-posnr
                               AND vbeln = lt_lipsx-vbeln
                               AND matnr = lt_lipsx-matnr.
              READ TABLE lt_konv WITH KEY kschl = _kschl_zf01
                                          kposn = lt_lipsh-vgpos
                                          knumv = lt_vbak-knumv.
              IF sy-subrc = 0.
                gt_item-discpf2 = lt_konv-kbetr / -10 .
                PERFORM f_excl_tax CHANGING gt_item-discpf2.
              ENDIF.
            ENDLOOP.
          ENDIF.

          " __* yang di SUM hanya diskon B & D
          LOOP AT lt_konv WHERE kposn = lt_lipsx-vgpos AND knumv = lt_vbak-knumv.
            " __* discount B
            IF lt_konv-kschl CP 'ZB*'.
              gt_item-discvb = gt_item-discvb + ( lt_konv-kwert * -1 ).
**              PERFORM f_excl_tax CHANGING gt_item-discvb.
              " __* discount C
            ELSEIF lt_konv-kschl CP 'ZC*'.
              gt_item-discpc = gt_item-discpc + ( lt_konv-kbetr / -10 ).
              gt_item-discvc = gt_item-discvc + ( lt_konv-kwert * -1 ).
**              PERFORM f_excl_tax CHANGING gt_item-discpc.
**              PERFORM f_excl_tax CHANGING gt_item-discvc.
              " __* discount D
            ELSEIF lt_konv-kschl CP 'ZD*'.
              gt_item-discpd = gt_item-discpd + ( lt_konv-kbetr / -10 ).
              gt_item-discvd = gt_item-discvd + ( lt_konv-kwert * -1 ).
**              PERFORM f_excl_tax CHANGING gt_item-discpd.
**              PERFORM f_excl_tax CHANGING gt_item-discvd.
              " __* discount E
            ELSEIF lt_konv-kschl CP 'ZE*'.
              gt_item-discpe = gt_item-discpe + ( lt_konv-kbetr / -10 ).
              gt_item-discve = gt_item-discve + ( lt_konv-kwert * -1 ).
**              PERFORM f_excl_tax CHANGING gt_item-discpe.
**              PERFORM f_excl_tax CHANGING gt_item-discve.
              " __* discount F1
            ELSEIF lt_konv-kschl = _kschl_zf01 OR lt_konv-kschl = _kschl_zf03.
*              gt_item-discpf1 = gt_item-discpf1 + ( lt_konv-kbetr / -10 ).
              gt_item-discvf1 = gt_item-discvf1 + ( lt_konv-kwert * -1 ).
**              PERFORM f_excl_tax CHANGING gt_item-discvf1.
              " __* discount F2
            ELSEIF lt_konv-kschl = _kschl_zf02 OR lt_konv-kschl = _kschl_zf08 OR
                   lt_konv-kschl = _kschl_zfa1.
*              gt_item-discpf2 = gt_item-discpf2 + ( lt_konv-kbetr / -10 ).
              gt_item-discvf2 = gt_item-discvf2 + ( lt_konv-kwert * -1 ).
**              PERFORM f_excl_tax CHANGING gt_item-discvf2.
            ENDIF.
          ENDLOOP.
        ENDLOOP. " >> loop diskon
        " ---------------------------------------------------------------------------------------------------------------------------------------- #2 $COMMENT
*        lv_sum27 = gt_item-discva + gt_item-discvb + gt_item-discvc + gt_item-discvd + gt_item-discve + gt_item-discvf1 + gt_item-discvf2.
        " ---------------------------------------------------------------------------------------------------------------------------------------- #2 $COMMENT.END
        " ---------------------------------------------------------------------------------------------------------------------------------------- #2 $ADD
        lv_sum27 = gt_item-discva + gt_item-discvb + gt_item-discvd + gt_item-discvf1 + gt_item-discvf2.
        " ---------------------------------------------------------------------------------------------------------------------------------------- #2 $ADD.END
        gt_item-kwert28 = gt_item-kwert26 - lv_sum27.
        WRITE gt_item-kwert28 TO gt_item-kwertc28 CURRENCY 'IDR'.
        CONDENSE gt_item-kwertc28.

        " __ write discounts in currency
        DATA: lv_char    TYPE char30, lv_char2 TYPE char30, lv_integer TYPE i.
        IF gt_item-discva IS NOT INITIAL.
          WRITE gt_item-discva TO gt_item-cdisca CURRENCY 'IDR'. CONDENSE gt_item-cdisca.
          CONCATENATE 'A:' gt_item-cdisca INTO gt_item-cdisca SEPARATED BY space.
        ENDIF.
        IF gt_item-discvb IS NOT INITIAL.
          WRITE gt_item-discvb TO gt_item-cdiscb CURRENCY 'IDR'.
          CONDENSE gt_item-cdiscb.
          CONCATENATE 'B:' gt_item-cdiscb INTO gt_item-cdiscb SEPARATED BY space.
          CONDENSE gt_item-cdiscb.
        ENDIF.
        IF gt_item-discvd IS NOT INITIAL OR gt_item-discpd IS NOT INITIAL.
          WRITE gt_item-discvd TO lv_char CURRENCY 'IDR'. CONDENSE lv_char.
          IF gt_item-discpd IS NOT INITIAL.
            " ------------------------------------------------------------------------------------ koreksi 8
*            move gt_item-discpd to lv_integer.
*            move lv_integer to lv_char2. condense lv_char2.
            MOVE gt_item-discpd TO lv_char2. CONDENSE lv_char2.
            CONCATENATE lv_char2 '%' INTO lv_char2.
          ENDIF.
          CONCATENATE 'D:' lv_char2 lv_char INTO gt_item-cdiscd SEPARATED BY space.
          CONDENSE gt_item-cdiscd.
        ENDIF.
        IF gt_item-discvf1 IS NOT INITIAL OR gt_item-discpf1 IS NOT INITIAL..
          WRITE gt_item-discvf1 TO lv_char CURRENCY 'IDR'. CONDENSE lv_char.
          IF gt_item-discpf1 IS NOT INITIAL.
            " ------------------------------------------------------------------------------------ koreksi 8
*            move gt_item-discpf1 to lv_integer.
*            move lv_integer to lv_char2. condense lv_char2.
            MOVE gt_item-discpf1 TO lv_char2. CONDENSE lv_char2.
            CONCATENATE lv_char2 '%' INTO lv_char2.
          ENDIF.
          CONCATENATE 'F1:' lv_char2 lv_char INTO gt_item-cdiscf1 SEPARATED BY space.
          CONDENSE gt_item-cdiscf1.
        ENDIF.
        IF gt_item-discvf2 IS NOT INITIAL OR gt_item-discpf2 IS NOT INITIAL..
          WRITE gt_item-discvf2 TO lv_char CURRENCY 'IDR'. CONDENSE lv_char.
          IF gt_item-discpf2 IS NOT INITIAL.
            " ------------------------------------------------------------------------------------ koreksi 8
*          move gt_item-discpf2 to lv_integer.
*          move lv_integer to lv_char2. condense lv_char2.
            MOVE gt_item-discpf2 TO lv_char2. CONDENSE lv_char2.
            CONCATENATE lv_char2 '%' INTO lv_char2.
          ENDIF.
          CONCATENATE 'F2:' lv_char2 lv_char INTO gt_item-cdiscf2 SEPARATED BY space.
          CONDENSE gt_item-cdiscf2.
        ENDIF.

        " start get detail item(structure ZSSUTST007)

        READ TABLE lt_lipsh3 WITH KEY uecha = lt_lipsh2-posnr.

        IF sy-subrc = 0.
          REFRESH lt_007. CLEAR lt_007.
*        LOOP AT lt_lipsx WHERE matnr = lt_lipsh2-matnr AND charg IS NOT INITIAL.
          LOOP AT lt_lipsx WHERE vbeln = lt_lipsh2-vbeln
                             AND matnr = lt_lipsh2-matnr
                             AND ( posnr = lt_lipsh2-posnr
                              OR   uecha = lt_lipsh2-posnr
                              OR   uepos = lt_lipsh2-posnr ).
            IF lt_lipsx-charg IS NOT INITIAL.
              IF lt_lipsx-uecha = lt_lipsh2-posnr OR
                lt_lipsx-uepos = lt_lipsh2-posnr OR
                lt_lipsx-uecha IS INITIAL.
                " __* TO-DOs
                READ TABLE lt_007 WITH KEY vbeln = lt_lipsx-vbeln
                                           charg = lt_lipsx-charg.
                IF sy-subrc = 0.
                  lt_007-lfimg = lt_007-lfimg + lt_lipsx-lfimg.
                  MODIFY lt_007 INDEX sy-tabix TRANSPORTING lfimg.
                ELSE.
                  lt_007-vbeln = lt_lipsx-vbeln.
                  lt_007-matnr = lt_lipsx-matnr.
                  lt_007-charg = lt_lipsx-charg.
                  CONCATENATE 'Batch' lt_007-charg INTO lt_007-charg_c SEPARATED BY space.
                  lt_007-vfdat = lt_lipsx-vfdat.
                  lt_007-lfimg = lt_lipsx-lfimg.
                  lt_007-vrkme = lt_lipsx-vrkme.
                  lt_007-uecha = lt_lipsx-uecha.
                  IF lt_007-uecha IS INITIAL.
*                    lt_007-uecha = lt_lipsx-posnr.
                    lt_007-uecha = lt_lipsh3-uecha.
                  ENDIF.
                  IF lt_lipsx-uepos IS NOT INITIAL.
                    lt_007-uecha = lt_lipsx-uepos.
                  ENDIF.
                  APPEND lt_007. CLEAR lt_007.
                ENDIF.
              ENDIF.
            ELSEIF lt_lipsx-xchpf IS INITIAL.
              IF lt_lipsx-uecha = lt_lipsh2-posnr OR
                 lt_lipsx-uepos = lt_lipsh2-posnr OR
                 lt_lipsx-posnr = lt_lipsh2-posnr.
*              READ TABLE lt_007 WITH KEY matnr = lt_lipsx-matnr.
                IF lt_lipsx-uepos IS INITIAL.
                  READ TABLE lt_007 WITH KEY vbeln = lt_lipsx-vbeln
                                             matnr = lt_lipsx-matnr
                                             uecha = lt_lipsx-posnr.
                ELSE.
                  READ TABLE lt_007 WITH KEY vbeln = lt_lipsx-vbeln
                                             matnr = lt_lipsx-matnr
                                             uecha = lt_lipsx-uepos.
                ENDIF.
                IF sy-subrc = 0.
                  lt_007-lfimg = lt_007-lfimg + lt_lipsx-lfimg.
                  MODIFY lt_007 INDEX sy-tabix TRANSPORTING lfimg.
                ELSE.
                  lt_007-vbeln = lt_lipsx-vbeln.
                  lt_007-matnr = lt_lipsx-matnr.
                  lt_007-charg = lt_lipsx-charg.
                  lt_007-vfdat = lt_lipsx-vfdat.
                  lt_007-lfimg = lt_lipsx-lfimg.
                  lt_007-vrkme = lt_lipsx-vrkme.
                  IF lt_lipsx-uepos IS NOT INITIAL.
                    lt_007-uecha = lt_lipsx-uepos.
                  ELSE.
                    lt_007-uecha = lt_lipsx-posnr.
                  ENDIF.
                  APPEND lt_007. CLEAR lt_007.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ELSE.
          PERFORM f_without_batch_split TABLES lt_007
                                               lt_lipsx
                                               lt_lipsh2.
        ENDIF.

        " __ get data from ZMSUTDT005 for UOM calculation
        DATA: lv_i1 TYPE i, lv_i2 TYPE i, lv_i3 TYPE i, lv_i4 TYPE i, lv_c3 TYPE char10, lv_c1 TYPE char10.
        DATA: lt_005 TYPE TABLE OF zmsutdt005 WITH HEADER LINE.
        REFRESH lt_005. CLEAR lt_005.
        LOOP AT gt_005 WHERE matnr = lt_lipsh2-matnr.
          APPEND gt_005 TO lt_005.
        ENDLOOP.
        SORT lt_005 BY umrez DESCENDING.
*        break sap_dev02.
        LOOP AT lt_007.
          CLEAR : lt_007-car31.
          CONCATENATE lt_007-vfdat+6(2) '.' lt_007-vfdat+4(2) '.' lt_007-vfdat+0(4) INTO  lt_007-car31.
          MOVE lt_007-lfimg TO lv_i1.
          DO 4 TIMES.
            READ TABLE lt_005 INDEX sy-index.
            IF sy-subrc = 0.
              MOVE lt_005-umrez TO lv_i2.
              lv_i3 = lv_i1 DIV lv_i2.
              lv_i4 = lv_i1 MOD lv_i2.
              MOVE lv_i3 TO lv_c3.
              CONDENSE lv_c3.
              IF lv_i3 > 0.
                CONCATENATE lt_007-car31 lv_c3 lt_005-zaun INTO lt_007-car31 SEPARATED BY space.
              ENDIF.
              IF lv_i4 <= 0.
                EXIT.
              ELSE.
                lv_i1 = lv_i4.
              ENDIF.
            ELSE.
              IF lv_i1 > 0.
                MOVE lv_i1 TO lv_c1.
                CONDENSE lv_c1.
                CONCATENATE lt_007-car31 lv_c1 lt_005-meins INTO lt_007-car31 SEPARATED BY space.
                EXIT.
              ENDIF.
            ENDIF.
          ENDDO.
          CONCATENATE 'ED' lt_007-car31 INTO lt_007-car31 SEPARATED BY space.
          DATA ld_length TYPE i.
          ld_length = strlen( lt_007-car31 ).
          IF ld_length GE 14.
            ld_length = ld_length - 14.
            lt_007-car31a = lt_007-car31+14(ld_length).
          ENDIF.
          MODIFY lt_007 TRANSPORTING car31 car31a.
*          lt_007-C31A1 =
*          lt_007-C31A2 =
*          lt_007-C31A3 =
*          lt_007-CAR31 =
        ENDLOOP.
        "
        APPEND LINES OF lt_007 TO gt_detail.


        "  end get detail


        " __* sum of Brutto (35)
        gs_header-kwert35 = gs_header-kwert35 + gt_item-kwert26.
        WRITE gs_header-kwert35 TO gs_header-kwertc35 CURRENCY 'IDR'.
        CONDENSE gs_header-kwertc35.
        " __* sum of Discount (value only) (36)
        gs_header-kwert36 = gs_header-kwert36 + ( gt_item-discva + gt_item-discvb + " gt_item-discvc +
                                                  gt_item-discvd + gt_item-discve + gt_item-discvf1 + gt_item-discvf2 ).
*        write gs_header-kwert36 to gs_header-kwertc36 currency 'IDR'.
*        condense gs_header-kwertc36 .
        " __* sum of Netto (37)
        gs_header-kwert37 = gs_header-kwert37 + gt_item-kwert28.
        WRITE gs_header-kwert37 TO gs_header-kwertc37 CURRENCY 'IDR'.
        CONDENSE gs_header-kwertc37.
        " __* discount C (34a)
**  Pindah logic untuk perhitungan discount C
**        gs_header-kwert34a = gs_header-kwert34a + gt_item-discvc.
**        IF gs_header-kwert34a IS NOT INITIAL.
**          WRITE gs_header-kwert34a TO gs_header-kwertc34a CURRENCY 'IDR'.
**          CONDENSE gs_header-kwertc34a.
**          CONCATENATE 'C:' gs_header-kwertc34a INTO gs_header-kwertcc34a SEPARATED BY space. "cl_abap_char_utilities=>horizontal_tab.
**          CONDENSE gs_header-kwertcc34a.
**        ENDIF.
        " __* discount E (34b)
        gs_header-kwert34b = gs_header-kwert34b + gt_item-discve.
        IF gs_header-kwert34b IS NOT INITIAL.
          WRITE gs_header-kwert34b TO gs_header-kwertc34b CURRENCY 'IDR'.
          CONDENSE gs_header-kwertc34b.
          CONCATENATE 'Disc. E :' gs_header-kwertc34b INTO gs_header-kwertcc34b SEPARATED BY space. "cl_abap_char_utilities=>horizontal_tab.
          CONDENSE gs_header-kwertcc34b.
        ENDIF.

        IF lt_lipsh2-uepos IS NOT INITIAL.
          gt_item-posnr = lt_lipsh2-uepos.
        ENDIF.

        " __* append Item header
        APPEND gt_item.
      ENDLOOP. " >> Loop Item Header

      LOOP AT lt_konv.
** Pengganti Logic pengambilan discount C
        IF lt_konv-kschl CP 'ZC*'.
          gs_header-kwert34a = gs_header-kwert34a + ( lt_konv-kwert * -1 ).

          "SSP value
        ELSEIF lt_konv-kschl EQ _kschl_zvat.
          ADD lt_konv-kwert TO gs_header-ssp.
        ENDIF.
      ENDLOOP.

      "SSP Value
      IF gs_header-ssp IS NOT INITIAL. " and gs_header-lifex is not initial.
        WRITE gs_header-ssp TO gs_header-sspc CURRENCY 'IDR'.
        CONDENSE gs_header-sspc.
      ENDIF.

      IF gs_header-kwert34a IS NOT INITIAL.
        WRITE gs_header-kwert34a TO gs_header-kwertc34a CURRENCY 'IDR'.
        CONDENSE gs_header-kwertc34a.
        CONCATENATE 'Disc. C :' gs_header-kwertc34a INTO gs_header-kwertcc34a SEPARATED BY space. "cl_abap_char_utilities=>horizontal_tab.
        CONDENSE gs_header-kwertcc34a.
      ENDIF.

      gs_header-kwert36 = gs_header-kwert36 + gs_header-kwert34a.
      " END LOOP HEADER MATERIAL

      " __*
    ENDIF. " >> LIPS (items) are available
    " __* Name1-4
    DATA: ls_knvp  TYPE knvp,
          ls_kna1  TYPE kna1,
          ls_vbpa1 TYPE vbpa.

    SELECT SINGLE * FROM knvp INTO ls_knvp WHERE kunnr = likp-kunnr AND parvw = _parvw AND defpa <> ''.
    IF sy-subrc = 0.
      IF likp-vkorg = '8070' AND ls_vbak-auart = 'YOT2'.
        SELECT SINGLE * FROM vbpa INTO ls_vbpa1 WHERE vbeln = ls_vbak-vbeln AND parvw = 'EM'.
        IF sy-subrc = 0.
          ls_knvp-kunn2 = ls_vbpa1-kunnr.
        ENDIF.
      ENDIF.
      SELECT SINGLE * FROM kna1 INTO ls_kna1 WHERE kunnr = ls_knvp-kunn2.
      IF sy-subrc = 0.
        PERFORM f_alamat_pelanggan USING ls_kna1-adrnr.
*        gs_header-name1 = ls_kna1-name1.
*        gs_header-name2 = ls_kna1-name2.
        gs_header-stceg = ls_kna1-stceg.
        gs_header-kunnr = ls_kna1-kunnr.
        gs_header-lzone = ls_kna1-lzone.
      ENDIF.
    ELSE.
      IF likp-vkorg = '8070' AND ls_vbak-auart = 'YOT2'.
        SELECT SINGLE * FROM vbpa INTO ls_vbpa1 WHERE vbeln = ls_vbak-vbeln AND parvw = 'EM'.
        IF sy-subrc = 0.
          likp-kunnr = ls_vbpa1-kunnr.
        ENDIF.
      ENDIF.
      SELECT SINGLE * FROM kna1 INTO ls_kna1 WHERE kunnr = likp-kunnr.
      IF sy-subrc = 0.
        PERFORM f_alamat_pelanggan USING ls_kna1-adrnr.
*        gs_header-name1 = ls_kna1-name1.
*        gs_header-name2 = ls_kna1-name2.
        gs_header-stceg = ls_kna1-stceg.
        gs_header-kunnr = ls_kna1-kunnr.
        gs_header-lzone = ls_kna1-lzone.
      ENDIF.
    ENDIF.

* United Project 08/09/2015
    CLEAR lv_reswk.
    CASE likp-vkorg.
      WHEN '8020'.
        SELECT SINGLE reswk INTO lv_reswk FROM zplbc
          WHERE bukrs = '8070'
            AND reswk = gt_lips-werks.
        IF lv_reswk IS NOT INITIAL.
          gs_header-lzone = likp-route.
        ENDIF.
      WHEN '8070'.
        SELECT SINGLE reswk INTO lv_reswk FROM zplbc
          WHERE bukrs = likp-vkorg
            AND werks = gt_lips-werks
            AND lgort = gt_lips-lgort.
        IF lv_reswk IS NOT INITIAL.
          gs_header-lzone = likp-route.
        ENDIF.
    ENDCASE.

    " __* username
    gs_header-uname = sy-uname.
    " __* Delivery No
    gs_header-vbelnl = gs_vttk-tknum. "likp-vbeln.
    " __* Tanggal
    gs_header-wadat = gs_vttk-datbg. "likp-wadat_ist.
    " __* TOP
    gs_header-top = gs_header-mahdt - gs_header-wadat.
    " __* discount volume (33)
    READ TABLE lt_konv WITH KEY kschl = _kschl_zv01.
    IF sy-subrc = 0.
      gs_header-kbetr33 = lt_konv-kbetr * -1 / 10.
    ENDIF.
    " __* value sum (33)
    CLEAR gs_header-kwert33.
    LOOP AT lt_konv WHERE kschl = _kschl_zv01.
      gs_header-kwert33 = gs_header-kwert33 + lt_konv-kwert * -1.
    ENDLOOP.
    IF gs_header-kbetr33 IS NOT INITIAL OR gs_header-kwert33 IS NOT INITIAL.
      WRITE gs_header-kwert33 TO gs_header-kwertc33 CURRENCY 'IDR'.
      CONDENSE gs_header-kwertc33.
      IF gs_header-kbetr33 IS NOT INITIAL.
*        move gs_header-kbetr33 to lv_integer.
*        move lv_integer to lv_char. condense lv_char.
*        move gs_header-kbetr33 to lv_char.condense lv_char.
        MOVE gs_header-kbetr33 TO lv_char. CONDENSE lv_char.
        CONCATENATE lv_char '%' INTO lv_char.
      ENDIF.
      CONCATENATE 'VOLUME DISC' lv_char INTO gs_header-kwertcc33 SEPARATED BY space.
      CONDENSE gs_header-kwertcc33.
    ENDIF.

    gs_header-kwert36 = gs_header-kwert36 + gs_header-kwert33.
    WRITE gs_header-kwert36 TO gs_header-kwertc36 CURRENCY 'IDR'.
    CONDENSE gs_header-kwertc36.
    gs_header-totalpage = 1.
    "
    " ---------------------------------------------------------------------------------------------------------------------------------------- #2 $ADD
    gs_header-kwert37 = gs_header-kwert37 - ( gs_header-kwert33 + gs_header-kwert34a + gs_header-kwert34b ).
    " cek ssp
    IF gs_header-lifex IS NOT INITIAL.
      ADD gs_header-ssp TO gs_header-kwert37.
    ENDIF.

    WRITE gs_header-kwert37 TO gs_header-kwertc37 CURRENCY 'IDR'.
    CONDENSE gs_header-kwertc37.
    gs_header-kwertcc37 = 'JUMLAH TAGIHAN'.
    " ---------------------------------------------------------------------------------------------------------------------------------------- #2 $ADD.END
*    " __* discount C (34)
*    LOOP AT lt_konv where kschl cp 'ZC%'.
*      gs_header-kwert34 = gs_header-kwert34 + lt_konv-kwert * -100.
*    ENDLOOP.
    " __*
    " __* TO-DO:
    " __* Point 10

    " __* spell amount
    DATA in_words TYPE spell.
    CALL FUNCTION 'SPELL_AMOUNT'
      EXPORTING
        amount    = gs_header-kwert37
        currency  = 'IDR'
*       FILLER    = ' '
        language  = 'i'
      IMPORTING
        in_words  = in_words
      EXCEPTIONS
        not_found = 1
        too_large = 2
        OTHERS    = 3.
    IF sy-subrc = 0.
      MOVE in_words-word TO gs_header-spell.
      CONDENSE gs_header-spell.
      CONCATENATE gs_header-spell 'RUPIAH' INTO gs_header-spell SEPARATED BY space.
    ENDIF.

    " --------------------------------------------------------------------------------------------------------- SUpervisor & PBF Name & TTd ---> 38 39
    DATA: ls_zsign_sp   TYPE zsign_sp,
          ls_zsign_bm   TYPE zsign_bm,
          ls_zsign      TYPE zsign,
          ls_zscl_class TYPE zscl_class,
          ls_zscl_range TYPE zscl_range.
    SELECT SINGLE * FROM zscl_class INTO ls_zscl_class WHERE vkbur = gt_lips-vkbur.
    IF sy-subrc = 0.
      SELECT SINGLE * FROM zscl_range INTO ls_zscl_range WHERE zclass = ls_zscl_class-zclass AND zrange EQ 1.
    ENDIF.
    IF gs_header-kwert37 < ls_zscl_range-zvalue_high.
      SELECT SINGLE * FROM zsign_sp INTO ls_zsign_sp WHERE s_point = gt_lips-vkbur AND sales_group = gt_lips-vkgrp.
      IF sy-subrc = 0.
        gs_header-object_sp = ls_zsign_sp-object_name.
        gs_header-name_sp   = ls_zsign_sp-user_name.
      ENDIF.
    ELSE.
      SELECT SINGLE * FROM zsign_bm INTO ls_zsign_bm WHERE s_point = gt_lips-vkbur.
      IF sy-subrc = 0.
        gs_header-object_sp = ls_zsign_bm-object_name.
        gs_header-name_sp   = ls_zsign_bm-user_name.
      ENDIF.
    ENDIF.
    SELECT SINGLE * FROM zsign INTO ls_zsign WHERE s_point = gt_lips-vkbur.
    IF sy-subrc = 0.
      gs_header-object_pbf = ls_zsign-object_name.
      gs_header-name_pbf   = ls_zsign-user_name.
      gs_header-sk_pbf     = ls_zsign-no_sk.
    ENDIF.
    " __* Pbf No
    DATA ls_zpbf TYPE zpbf.
    SELECT SINGLE * FROM zpbf INTO ls_zpbf WHERE vkbur = gt_lips-vkbur.
    IF sy-subrc = 0.
      gs_header-pbfno = ls_zpbf-pbfno.     " -------------------------------------------------------------------------------------> 3
    ENDIF.

    " __* Bank Account
*    break sap_dev02.
    DATA lt_bank TYPE TABLE OF zsaccbank WITH HEADER LINE.
    SELECT * FROM zsaccbank INTO TABLE lt_bank WHERE vkorg = likp-vkorg AND vkbur = gt_lips-vkbur. "vkbur = likp-vkbur.
    IF sy-subrc = 0.
      LOOP AT lt_bank.
        IF gs_header-bank IS INITIAL.
          CONCATENATE lt_bank-bank 'AC.' lt_bank-accno INTO gs_header-bank SEPARATED BY space.
        ELSE.
          CONCATENATE gs_header-bank 'atau' lt_bank-bank 'AC.' lt_bank-accno INTO gs_header-bank SEPARATED BY space.
        ENDIF.
      ENDLOOP.
    ENDIF.
*    break sap_dev02.
  ELSE.
    d_frm_subrc = 1.
  ENDIF. " __* Main SY_SUBRC
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form .
  SORT gt_new BY matnr.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

*  perform f_test_next_page.
  IF d_frm_subrc IS INITIAL.
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        gs_header          = gs_header
        gv_style1          = gv_style1
        gv_style2          = gv_style2
        gv_style3          = gv_style3
        gv_style4          = gv_style4
        gv_style5          = gv_style5
        gv_style6          = gv_style6
        gv_kschl           = gv_kschl
      TABLES
        gt_item            = gt_item[]
        gt_detail          = gt_detail[]
        gt_table_def       = gt_table_def[]
        gt_new             = gt_new[].
  ENDIF.
ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_DATA
*&---------------------------------------------------------------------*
FORM f_clear_data .
  CLEAR d_frm_subrc.
  CLEAR gs_header.
  CLEAR: gt_item, gt_table_def, gt_detail, gt_new.
  REFRESH: gt_item, gt_table_def, gt_detail, gt_new.
ENDFORM.                    " F_CLEAR_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DEF_PAGE
*&---------------------------------------------------------------------*
*& Use to define how many Line Break should be carried for each start
*& of detail item data
*&---------------------------------------------------------------------*
FORM f_def_page .
  DATA: lv_num1        TYPE i, lv_total_lines TYPE i.
  DATA: lv_p1 TYPE p DECIMALS 2.
  " __* change p_tdform (the name of form) based on the number of line (or number of page) to be drawn to smartforms ...
  " __* count the number of line ...

  CLEAR lv_total_lines.
  LOOP AT gt_item.
    " __* the number of line needed are based on 1) the number of line of ARKTX (name of product) and 2) number discount
    " take only the max between 1) and 2)
    CLEAR: lv_num1, gt_table_def.
    gt_table_def-matnr   = gt_item-matnr.
    gt_table_def-posnr   = gt_item-posnr.
    " __* number lines of arktx
    lv_p1 = strlen( gt_item-arktx ).
*    lv_p1 = lv_p1 / 26.
    lv_p1 = lv_p1 / 40.
    lv_num1 = ceil( lv_p1 ).
*    lv_num1 = ceil( strlen( gt_item-arktx ) / 23 ).
    gt_table_def-tlines = lv_num1.
    gt_table_def-hlines = gt_table_def-tlines - 1.
    " __ level detail (charg)
    LOOP AT gt_detail WHERE vbeln = gt_item-vbeln
                        AND matnr = gt_item-matnr
                        AND uecha = gt_item-posnr.
      gt_table_def-tlines = gt_table_def-tlines + 1.
    ENDLOOP.
    IF sy-subrc NE 0.
      gt_table_def-tlines = gt_table_def-tlines + 1.
    ENDIF.
    lv_total_lines = lv_total_lines + gt_table_def-tlines.
    APPEND gt_table_def.
  ENDLOOP.
*  gs_header-total_lines = lv_total_lines.
  " __* now define the smartform to be used...
*  if lv_total_lines > 22.
*    p_tdform = _form_large.
*  else.
*    p_tdform = _form_large. "_form_small.
*  endif.
ENDFORM.                    " F_DEF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_TEST_NEXT_PAGE
*&---------------------------------------------------------------------*
FORM f_test_next_page .
  DATA: lv_no TYPE char2.
  DO 40 TIMES.
    CLEAR gt_item.
    ADD 1 TO lv_no.
    CONCATENATE 'XXXX' lv_no INTO gt_item-matnr.
    CONCATENATE 'Barang' lv_no INTO gt_item-arktx SEPARATED BY space.
    APPEND gt_item.
  ENDDO.
ENDFORM.                    " F_TEST_NEXT_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_COMBINE_DATA
*&---------------------------------------------------------------------*
FORM f_combine_data .
  DATA: lt_item LIKE TABLE OF gt_item WITH HEADER LINE.
  LOOP AT gt_item.
    CLEAR lt_item.
    APPEND gt_item TO lt_item.
    LOOP AT gt_detail WHERE matnr = gt_item-matnr.
      CLEAR lt_item.
      lt_item-flag = 'X'.
      MOVE gt_detail-charg TO lt_item-matnr. CONDENSE lt_item-matnr.
      CONCATENATE gt_detail-vfdat+6(2) '.' gt_detail-vfdat+4(2) '.' gt_detail-vfdat+0(2) INTO lt_item-arktx. CONDENSE lt_item-arktx.
      lt_item-lfimg = gt_detail-lfimg.
      APPEND lt_item.
    ENDLOOP.
  ENDLOOP.
  REFRESH gt_item.
  gt_item[] = lt_item[].
ENDFORM.                    " F_COMBINE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_ALAMAT_PELANGGAN
*&---------------------------------------------------------------------*
FORM f_alamat_pelanggan  USING    fu_adrnr.
  DATA ls_adrc  TYPE adrc.

  DATA : d_datab LIKE zproject-datab,
         d_flag  LIKE zproject-flag.

  CLEAR : d_datab, d_flag.

  SELECT SINGLE * FROM adrc INTO ls_adrc WHERE addrnumber = fu_adrnr.
  gs_header-name_co = ls_adrc-name_co.
  gs_header-str_suppl1 = ls_adrc-str_suppl1.
  gs_header-str_suppl2 = ls_adrc-str_suppl2.
  gs_header-str_suppl3 = ls_adrc-str_suppl3.
*  gs_header-street1    = ls_adrc-street.
  gs_header-name1      = ls_adrc-name1.
  gs_header-name2      = ls_adrc-name2.
  gs_header-name3      = ls_adrc-name3.

  SELECT SINGLE datab flag
    INTO (d_datab, d_flag)
    FROM zproject
    WHERE name = 'ZCITY'.

  IF ( sy-datum >= d_datab AND d_flag = 'X' ).
    IF gs_header-name3 IS INITIAL.
      gs_header-name3 = ls_adrc-city1.
    ELSE.
      gs_header-name4 = ls_adrc-city1.
    ENDIF.
  ELSE.
    gs_header-name4 = ls_adrc-name4.
  ENDIF.
ENDFORM.                    " F_ALAMAT_PELANGGAN

*&---------------------------------------------------------------------*
*&      Form  F_NEW_DELIVERY_NOTE
*&---------------------------------------------------------------------*
FORM f_new_delivery_note .
  DATA : lwa_item   LIKE gt_item,
         lv_count   TYPE i,
         lv_matnr   TYPE matnr,
         lv_arktx   TYPE arktx,
         lv_discv   TYPE kbetr,
         lv_total   TYPE wertv9,
         lv_nsp     TYPE wertv9,
         lv_total1  TYPE kzwi5,
         lv_name    TYPE tdobname,
         lt_lines   LIKE tline OCCURS 0 WITH HEADER LINE,
         lv_flag    TYPE i,
         lv_sign(1),
         lv_zeile   TYPE mblpo,
         lv_vbeln   LIKE vbfa-vbeln,
         lv_kwert   TYPE kwert,
         lv_kwert1  TYPE kwert,
         lv_subrc   TYPE sy-subrc.

  DATA : lv_bruto  TYPE wertv8,
         lv_disc   TYPE wertv8,
         lv_sales  TYPE wertv8,
         lv_slstmp TYPE p DECIMALS 1,
         lv_ppn    TYPE wertv8,
         lv_length TYPE i.

  DATA : et_docflow          TYPE tdt_docflow,
         lw_docflow          TYPE tds_docflow OCCURS 0 WITH HEADER LINE,
         i_bapi_view         LIKE order_view,
         sales_documents     LIKE sales_key OCCURS 0 WITH HEADER LINE,
         order_textlines_out LIKE bapitextli OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF lt_temp OCCURS 0,
           matnr TYPE matnr,
           lfimg TYPE lfimg,
           disc  TYPE kbetr,
           total TYPE kbetr,
         END OF lt_temp.
  DATA : lt_new   LIKE lt_temp OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF lt_vbfa OCCURS 0,
           vbelv   TYPE vbeln_von,
           posnv   TYPE posnr_von,
           vbeln   TYPE vbeln_nach,
           posnn   TYPE posnr_nach,
           vbtyp_n TYPE vbtyp_n,
           erdat   TYPE erdat,
           bwart   TYPE bwart,
           posnr   TYPE posnr_von,
           zeile   TYPE mblpo,
           charg   TYPE charg_d,
           matnr   TYPE matnr,
         END OF lt_vbfa.
  DATA : lt_vbfah   LIKE gt_vbfa OCCURS 0 WITH HEADER LINE.
  DATA : lt_msegh   LIKE gt_mseg OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF lt_mseg OCCURS 0,
           mblnr TYPE mblnr,
           mjahr TYPE mjahr,
           zeile TYPE mblpo,
           matnr TYPE matnr,
           charg TYPE charg_d,
           waers TYPE waers,
           dmbtr TYPE dmbtr,
           menge TYPE menge_d,
           meins TYPE meins,
         END OF lt_mseg.

  DATA : lt_xmseg   LIKE lt_mseg OCCURS 0 WITH HEADER LINE.

  DATA : lv_dmbtr  TYPE dmbtr,
         lv_dmbtr1 TYPE dmbtr.

  DATA : ls_a017  LIKE LINE OF gt_a017,
         ls_konp  LIKE LINE OF gt_konp,
         ls_eina  LIKE LINE OF gt_eina,
         lv_wadat TYPE sy-datum.

  gs_header-kschl = gv_kschl.
  lv_name = p_vbeln.
  CONDENSE lv_name.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = '0002'
      language                = sy-langu
      name                    = lv_name
      object                  = 'VBBK'
    TABLES
      lines                   = lt_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  READ TABLE lt_lines INDEX 1.
  IF sy-subrc EQ 0.
    gs_header-header_text = lt_lines-tdline.
  ENDIF.

  IF gs_header-header_text IS INITIAL.
    CALL FUNCTION 'SD_DOCUMENT_FLOW_GET'
      EXPORTING
        iv_docnum  = p_vbeln
      IMPORTING
        et_docflow = et_docflow.

    LOOP AT et_docflow INTO lw_docflow.
      IF lw_docflow-docnuv IS INITIAL AND
        lw_docflow-vbtyp_n EQ 'C'.
        i_bapi_view-text  = 'X'.
        sales_documents   = lw_docflow-docnum.
        APPEND sales_documents.
        CALL FUNCTION 'BAPISDORDER_GETDETAILEDLIST'
          EXPORTING
            i_bapi_view         = i_bapi_view
          TABLES
            sales_documents     = sales_documents
            order_textlines_out = order_textlines_out.

        READ TABLE order_textlines_out WITH KEY line_cnt = '00000001'.
        IF sy-subrc EQ 0.
          gs_header-header_text = order_textlines_out-line.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  PERFORM f_a511 USING gs_header-kunnr likp-erdat
                 CHANGING gs_header-maxdate.

  SORT gt_detail BY uecha lfimg DESCENDING.
  LOOP AT gt_item INTO lwa_item.
    gt_new-zdisc1 = lwa_item-discva.
    WRITE lwa_item-discva TO gt_new-cdisca CURRENCY 'IDR'.
    CONDENSE gt_new-cdisca.
*    lv_discv  = lwa_item-discvb + lwa_item-discvd + lwa_item-discvd5 +
*                lwa_item-discve + lwa_item-discvf1 + lwa_item-discvf2.
    lv_discv  = lwa_item-discvb + lwa_item-discvd + lwa_item-discvd5 +
                lwa_item-discvf1 + lwa_item-discvf2.

    PERFORM f_excl_tax CHANGING lv_discv.

    PERFORM f_recalc_value USING p_vbeln lwa_item-posnr
                           CHANGING lv_discv.

    ADD lv_discv TO lv_disc.
    ADD lwa_item-discva TO lv_disc.
    ADD lv_discv TO lv_bruto.
    ADD lwa_item-discva TO lv_bruto.

    WRITE lv_discv TO gt_new-cdisc CURRENCY 'IDR'.
    CONDENSE gt_new-cdisc.

    CLEAR lv_flag.
    LOOP AT gt_detail WHERE vbeln EQ lwa_item-vbeln
                        AND matnr EQ lwa_item-matnr
                        AND uecha EQ lwa_item-posnr.
      ADD 1 TO lv_count.
      gt_new-posnr     = lwa_item-posnr.
      gt_new-matnr     = lwa_item-matnr.
      gt_new-arktx     = lwa_item-arktx.
      gt_new-kwert     = lwa_item-kwert.
      gt_new-kwertc25  = lwa_item-kwertc25.

      CLEAR lv_length.
      gt_new-charg     = gt_detail-charg.
      lv_length = strlen( gt_detail-charg ).
      IF lv_length  GT 9.
        gt_new-batch  = 'X'.
      ENDIF.

      IF gt_detail-vfdat IS NOT INITIAL.
        WRITE gt_detail-vfdat TO gt_new-vfdatc DD/MM/YYYY.
      ENDIF.
      gt_new-lfimg  = gt_detail-lfimg.
      WRITE gt_detail-lfimg TO gt_new-lfimgc UNIT gt_detail-vrkme.
      CONDENSE gt_new-lfimgc.
      CONCATENATE gt_new-lfimgc gt_detail-vrkme INTO gt_new-lfimgc
      SEPARATED BY space.
      gt_new-car31a    = gt_detail-car31a.
      IF lv_count EQ 1.
        lv_total = ( gt_detail-lfimg * lwa_item-kwert ) - lv_discv - lwa_item-discva.
      ELSE.
        lv_total  = gt_detail-lfimg * lwa_item-kwert.
      ENDIF.

      ADD lv_total TO lv_bruto.

*      WRITE lv_total TO gt_new-total CURRENCY 'IDR' NO-SIGN NO-GAP.
      WRITE lv_total TO gt_new-total CURRENCY 'IDR' NO-GAP.
      CONDENSE gt_new-total.

* BPJS Condition
      IF gv_kschl = 'ZDE5' OR gv_kschl = 'ZDE7'.
        CLEAR : lv_nsp, lv_total1.
        PERFORM f_get_cmpre USING lwa_item-posnr
                            CHANGING lv_nsp lv_total1.

        PERFORM f_conv_to_char USING lv_total1
                               CHANGING gt_new-kzwi5 gt_new-kzwi5c.

        WRITE lv_nsp TO gt_new-nsp CURRENCY 'IDR' NO-SIGN.
        CONDENSE gt_new-nsp.

*        lv_nsp = lv_total / gt_detail-lfimg.
*        WRITE lv_nsp TO gt_new-nsp CURRENCY 'IDR' NO-SIGN.
*        CONDENSE gt_new-nsp.

* New calculation Qty, Harga Satuan & Harga
        lt_temp-matnr  = gt_new-matnr.
        lt_temp-lfimg  = gt_detail-lfimg.
        IF lv_flag IS INITIAL.
          lv_flag = 1.
          lt_temp-disc   = lv_discv.
        ENDIF.
        lt_temp-total  = lv_total.
        APPEND lt_temp.
        CLEAR lt_temp.

        gt_new-kwertc25 = gt_new-nsp.
        CLEAR gt_new-cdisc.
      ENDIF.

      IF gv_kschl = 'ZDE6' AND lv_count EQ 1.
        ADD lwa_item-discva TO lv_discv.
        CLEAR: gt_new-cdisca,gt_new-cdisc.
        WRITE lv_discv TO gt_new-cdisc CURRENCY 'IDR'.
        CONDENSE gt_new-cdisc.
      ENDIF.

      ADD 2 TO gs_header-total_lines.

      APPEND gt_new.
      CLEAR : gt_new, lv_total, lv_nsp.
    ENDLOOP.

    IF lv_count IS INITIAL.
      gt_new-matnr     = lwa_item-matnr.
      gt_new-arktx     = lwa_item-arktx.
      gt_new-kwertc25  = lwa_item-kwertc25.
      gt_new-zdisc1    = lwa_item-discva.
      WRITE lwa_item-discva TO gt_new-cdisca CURRENCY 'IDR'.
      CONDENSE gt_new-cdisca.
      lv_discv  = lwa_item-discvb + lwa_item-discvd + lwa_item-discvd5 +
                  lwa_item-discve + lwa_item-discvf1 + lwa_item-discvf2.

      PERFORM f_excl_tax CHANGING lv_discv.

      ADD lv_discv TO lv_disc.
      ADD lwa_item-discva TO lv_disc.
      ADD lv_discv TO lv_bruto.
      ADD lwa_item-discva TO lv_bruto.

      gt_new-lfimg  = gt_detail-lfimg.

      WRITE lv_discv TO gt_new-cdisc CURRENCY 'IDR'.
      CONDENSE gt_new-cdisc.
      lv_total = ( lwa_item-lfimg * lwa_item-kwert ) - lv_discv - lwa_item-discva.
      WRITE lv_total TO gt_new-total CURRENCY 'IDR' NO-SIGN NO-GAP.
      CONDENSE gt_new-total.
      WRITE lwa_item-lfimg TO gt_new-lfimgc UNIT lwa_item-vrkme.
      CONDENSE gt_new-lfimgc.
      CONCATENATE gt_new-lfimgc lwa_item-vrkme INTO gt_new-lfimgc
      SEPARATED BY space.

      ADD lv_total TO lv_bruto.

* BPJS Condition
      IF gv_kschl = 'ZDE5' OR gv_kschl = 'ZDE7'.
        CLEAR : lv_nsp, lv_total1.
        PERFORM f_get_cmpre USING lwa_item-posnr
                            CHANGING lv_nsp lv_total1.

        PERFORM f_conv_to_char USING lv_total1
                               CHANGING gt_new-kzwi5 gt_new-kzwi5c.

        WRITE lv_nsp TO gt_new-nsp CURRENCY 'IDR' NO-SIGN.
        CONDENSE gt_new-nsp.

*        lv_nsp = lv_total / gt_detail-lfimg.
*        WRITE lv_nsp TO gt_new-nsp CURRENCY 'IDR' NO-SIGN.
*        CONDENSE gt_new-nsp.

* New calculation Qty, Harga Satuan & Harga
        lt_temp-matnr  = gt_new-matnr.
        lt_temp-lfimg  = gt_detail-lfimg.
        lt_temp-disc   = lv_discv.
        lt_temp-total  = lv_total.
        APPEND lt_temp.
        CLEAR lt_temp.

        gt_new-kwertc25 = gt_new-nsp.
        CLEAR gt_new-cdisc.
      ENDIF.

      ADD 2 TO gs_header-total_lines.

      APPEND gt_new.
    ENDIF.
    CLEAR : gt_new, lv_count, lv_discv.
  ENDLOOP.

  IF gv_kschl EQ 'ZDE6'.
    WRITE lv_bruto TO gs_header-totalbrutot CURRENCY 'IDR'
                                            NO-SIGN NO-GAP.
    CONDENSE gs_header-totalbrutot.
    CONCATENATE 'Total Bruto : ' gs_header-totalbrutot
    INTO gs_header-totalbrutot
    SEPARATED BY space.

    WRITE lv_disc TO gs_header-totaldisct CURRENCY 'IDR'
                                          NO-SIGN NO-GAP.
    CONDENSE gs_header-totaldisct.
    CONCATENATE 'Total Discount : ' gs_header-totaldisct
    INTO gs_header-totaldisct
    SEPARATED BY space.

    lv_sales  = lv_bruto - lv_disc.
    WRITE lv_sales TO gs_header-totalsalest CURRENCY 'IDR'
                                            NO-SIGN NO-GAP.
    CONDENSE gs_header-totalsalest.
    CONCATENATE 'Total Sales : ' gs_header-totalsalest
    INTO gs_header-totalsalest
    SEPARATED BY space.

*      lv_slstmp = lv_sales.
    IF gt_ztax-do_flag IS NOT INITIAL.
      lv_sign = '+'.
    ELSE.
      lv_sign = '-'.
    ENDIF.
    CALL FUNCTION 'ROUND'
      EXPORTING
        decimals      = 1
        input         = lv_sales
        sign          = lv_sign
      IMPORTING
        output        = lv_slstmp
      EXCEPTIONS
        input_invalid = 1
        overflow      = 2
        type_invalid  = 3
        OTHERS        = 4.

*    lv_ppn = lv_sales * 10 / 100.
    lv_ppn = lv_slstmp * 10 / 100.
    WRITE lv_ppn TO gs_header-ppnt CURRENCY 'IDR'
                                   NO-SIGN NO-GAP DECIMALS 0.
    CONDENSE gs_header-ppnt.
    CONCATENATE 'PPN : ' gs_header-ppnt
    INTO gs_header-ppnt
    SEPARATED BY space.

    gs_header-kwert37 = lv_sales + lv_ppn.
    WRITE gs_header-kwert37 TO gs_header-kwertc37 CURRENCY 'IDR'.
    CONDENSE gs_header-kwertc37.

    DATA in_words TYPE spell.
    CALL FUNCTION 'SPELL_AMOUNT'
      EXPORTING
        amount    = gs_header-kwert37
        currency  = 'IDR'
        language  = 'i'
      IMPORTING
        in_words  = in_words
      EXCEPTIONS
        not_found = 1
        too_large = 2
        OTHERS    = 3.
    IF sy-subrc = 0.
      MOVE in_words-word TO gs_header-spell.
      CONDENSE gs_header-spell.
      CONCATENATE gs_header-spell 'RUPIAH'
      INTO gs_header-spell
      SEPARATED BY space.
    ENDIF.
  ENDIF.

  lv_length = strlen( gs_header-name_co ).
  IF lv_length GT 23.
    gv_style1  = 'X'.
  ENDIF.

  lv_length = strlen( gs_header-name2 ).
  IF lv_length GT 23.
    gv_style2  = 'X'.
  ENDIF.

  lv_length = strlen( gs_header-str_suppl1 ).
  IF lv_length GT 23.
    gv_style3  = 'X'.
  ENDIF.

  CASE gv_kschl.
    WHEN 'ZDE5' OR 'ZDE7'.
* New calculation Qty, Harga Satuan & Harga
      SORT lt_temp BY matnr.
      LOOP AT lt_temp.
        lt_new-matnr  = lt_temp-matnr.
        lt_new-lfimg  = lt_temp-lfimg.
        lt_new-disc   = lt_temp-disc.
        lt_new-total  = lt_temp-total.
        COLLECT lt_new.
        CLEAR lt_new.
      ENDLOOP.

      LOOP AT gt_new.
        CLEAR : lv_total, lv_nsp.
        READ TABLE lt_new WITH KEY matnr = gt_new-matnr.
        IF sy-subrc = 0.
          PERFORM f_modify_value USING gt_new-kwertc25
                                 CHANGING gt_new-kwert.
          lv_total  = ( gt_new-kwert / lt_new-lfimg ) * lt_new-total.

          CLEAR lv_nsp.
          lv_nsp    = lv_total / gt_new-kwert.

          lv_total  = lv_nsp * gt_new-lfimg.
        ENDIF.

        WRITE lv_nsp TO gt_new-nsp CURRENCY 'IDR' NO-SIGN.
        CONDENSE gt_new-nsp.

        PERFORM f_get_cmpre USING gt_new-posnr
                            CHANGING lv_nsp lv_total1.

        PERFORM f_conv_to_char USING lv_total1
                       CHANGING gt_new-kzwi5 gt_new-kzwi5c.

        WRITE lv_nsp TO gt_new-kwertc25 CURRENCY 'IDR' NO-SIGN.
        CONDENSE gt_new-kwertc25.
*        gt_new-kwertc25 = gt_new-nsp.

        WRITE lv_total TO gt_new-total CURRENCY 'IDR' NO-SIGN.
        CONDENSE gt_new-total.
        MODIFY gt_new TRANSPORTING kwertc25 nsp total.
      ENDLOOP.

    WHEN 'ZST7' OR 'ZT07' OR 'ZT08' OR 'ZT09' OR 'ZT10'.
* New calculation Qty, Harga Satuan & Harga for Batam
      IF gv_kschl = 'ZST7'.
        SELECT vbelv posnv vbeln posnn vbtyp_n erdat bwart
          FROM vbfa
          INTO TABLE lt_vbfa
          WHERE vbelv   = p_vbeln
            AND vbtyp_n = 'R'
            AND bwart <> space.
      ELSEIF gt_vttp[] IS NOT INITIAL.
        SELECT vbelv posnv vbeln posnn vbtyp_n erdat bwart matnr
          FROM vbfa
          INTO CORRESPONDING FIELDS OF TABLE lt_vbfa
          FOR ALL ENTRIES IN gt_vttp
          WHERE vbelv   = gt_vttp-vbeln
            AND vbtyp_n = 'R'
            AND bwart <> space.
      ENDIF.
      IF gv_kschl NE 'ZT09'.
        CHECK lt_vbfa[] IS NOT INITIAL.
      ENDIF.

      PERFORM f_cek_cancel_gi TABLES lt_vbfah
                                     lt_msegh.

      LOOP AT lt_vbfa.
        READ TABLE lt_msegh WITH KEY smbln = lt_vbfa-vbeln.
        IF sy-subrc = 0.
          DELETE lt_vbfa WHERE vbeln = lt_msegh-smbln.
          CONTINUE.
        ENDIF.

        lt_vbfa-zeile   = lt_vbfa-posnn.
        READ TABLE gt_lips WITH KEY posnr = lt_vbfa-posnv.
        IF sy-subrc = 0.
          lt_vbfa-posnr = gt_lips-uecha.
          lt_vbfa-charg = gt_lips-charg.
          IF gt_lips-uecha IS INITIAL.
            lt_vbfa-posnr = lt_vbfa-posnv.
          ENDIF.
        ENDIF.

        MODIFY lt_vbfa  TRANSPORTING zeile posnr charg.
      ENDLOOP.

      IF lt_vbfa[] IS NOT INITIAL.
        SELECT mblnr mjahr zeile matnr charg waers dmbtr menge meins
          FROM mseg
          INTO TABLE lt_mseg
          FOR ALL ENTRIES IN lt_vbfa
          WHERE mblnr   = lt_vbfa-vbeln
            AND zeile   = lt_vbfa-zeile.
      ENDIF.

      CASE gv_kschl.
        WHEN 'ZT07' OR 'ZT09'.
          IF gs_vttk-erdat IS INITIAL.
            lv_wadat = sy-datum.
          ELSE.
            lv_wadat = gs_vttk-erdat.
          ENDIF.

          lt_xmseg[] = lt_mseg[].
          SORT lt_xmseg BY matnr.
          DELETE ADJACENT DUPLICATES FROM lt_xmseg COMPARING matnr.
          IF lt_xmseg[] IS NOT INITIAL.
          ENDIF.

          lt_xmseg[] = lt_mseg[].
          SORT lt_xmseg BY matnr.
          DELETE ADJACENT DUPLICATES FROM lt_xmseg COMPARING matnr.
          IF lt_xmseg[] IS NOT INITIAL.
            SELECT eina~infnr matnr lifnr
              FROM eina JOIN eine ON eina~infnr = eine~infnr
              INTO CORRESPONDING FIELDS OF TABLE gt_eina
              FOR ALL ENTRIES IN lt_xmseg
              WHERE eina~matnr = lt_xmseg-matnr
                AND eina~loekz = space
                AND eine~ekorg = 'SOM'
                AND eine~esokz = '0'
                AND eine~werks = '0200'
                AND eine~loekz = space.

            SELECT *
              FROM a017
              INTO CORRESPONDING FIELDS OF TABLE gt_a017
              FOR ALL ENTRIES IN lt_xmseg
              WHERE kappl = 'M'
                AND kschl = 'ZHJP'
                AND matnr = lt_xmseg-matnr
                AND ekorg = 'SOM'
                AND werks = '0200'
                AND esokz = '0'
                AND datab <= lv_wadat
                AND datbi >= lv_wadat
              ORDER BY PRIMARY KEY.

            IF gt_a017[] IS NOT INITIAL.
              SELECT *
                FROM konp
                INTO CORRESPONDING FIELDS OF TABLE gt_konp
                FOR ALL ENTRIES IN gt_a017
                WHERE knumh = gt_a017-knumh
                ORDER BY PRIMARY KEY.
            ENDIF.
          ENDIF.

        WHEN OTHERS.
      ENDCASE.

      gt_msegnew[]  = lt_mseg[].
      SORT gt_msegnew BY matnr charg.

      CLEAR : gt_msegsum[], gt_msegsum.
      LOOP AT gt_msegnew.
        gt_msegsum-matnr  = gt_msegnew-matnr.
        gt_msegsum-charg  = gt_msegnew-charg.

        LOOP AT gt_a017 INTO ls_a017 WHERE matnr = gt_msegnew-matnr.
          CLEAR ls_eina.
          READ TABLE gt_eina INTO ls_eina
                             WITH KEY lifnr = ls_a017-lifnr
                                      matnr = ls_a017-matnr.
          IF sy-subrc = 0.
            CLEAR ls_konp.
            READ TABLE gt_konp INTO ls_konp
                               WITH KEY knumh = ls_a017-knumh.
            IF sy-subrc = 0.
              gt_msegnew-dmbtr = gt_msegnew-menge * ( ls_konp-kbetr / ls_konp-kpein ).
              MODIFY gt_msegnew TRANSPORTING dmbtr.
            ENDIF.
          ENDIF.
        ENDLOOP.

*        CLEAR ls_a017.
*        READ TABLE gt_a017 INTO ls_a017
*                           WITH KEY matnr = gt_msegnew-matnr.
*        IF sy-subrc = 0.
*          CLEAR ls_konp.
*          READ TABLE gt_konp INTO ls_konp
*                             WITH KEY knumh = ls_a017-knumh.
*          IF sy-subrc = 0.
*            gt_msegnew-dmbtr = gt_msegnew-menge * ( ls_konp-kbetr / ls_konp-kpein ).
*            MODIFY gt_msegnew TRANSPORTING dmbtr.
*          ENDIF.
*        ENDIF.

        gt_msegsum-dmbtr  = gt_msegnew-dmbtr.
        COLLECT gt_msegsum.
        CLEAR gt_msegsum.
      ENDLOOP.

      BREAK bcdik.
      DELETE ADJACENT DUPLICATES FROM gt_msegnew COMPARING matnr charg.

      CLEAR : gs_header-kwert36, gs_header-kwert37, gs_header-kwert33,
              gs_header-kwertc33, gs_header-kwertcc33.

      LOOP AT gt_new.
        CLEAR : lv_zeile, lv_subrc.
* Same batch on batch split
        CLEAR : lv_kwert, lv_kwert1, lv_dmbtr1.
        LOOP AT lt_vbfa WHERE posnr = gt_new-posnr
                          AND charg = gt_new-charg
                          AND matnr = gt_new-matnr.

          lv_zeile    = lt_vbfa-zeile.

          READ TABLE lt_mseg WITH KEY zeile = lv_zeile
                                      matnr = gt_new-matnr
                                      charg = gt_new-charg.
          IF sy-subrc = 0.
            CLEAR lv_dmbtr.
            LOOP AT lt_mseg WHERE zeile = lv_zeile
                              AND matnr = gt_new-matnr
                              AND charg = gt_new-charg.
              ADD lt_mseg-dmbtr TO lv_dmbtr.
            ENDLOOP.
            CLEAR : lv_kwert.
            lv_kwert  = lv_dmbtr / gt_new-lfimg.
            ADD lv_kwert TO lv_kwert1.
            gt_new-kwert = lv_kwert1.
            WRITE gt_new-kwert TO gt_new-nsp CURRENCY 'IDR' NO-SIGN.
            CONDENSE gt_new-nsp.
            gt_new-kwertc25 = gt_new-nsp.

            ADD lv_dmbtr TO lv_dmbtr1.
            WRITE lv_dmbtr1 TO gt_new-total CURRENCY 'IDR' NO-SIGN.
            CONDENSE gt_new-total.

            MODIFY gt_new TRANSPORTING kwert kwertc25 nsp total.

            ADD lv_dmbtr TO gs_header-kwert36.
            ADD lv_dmbtr TO gs_header-kwert37.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      WRITE gs_header-kwert36 TO gs_header-kwertc36 CURRENCY 'IDR'.
      CONDENSE gs_header-kwertc36.
      WRITE gs_header-kwert37 TO gs_header-kwertc37 CURRENCY 'IDR'.
      CONDENSE gs_header-kwertc37.

      CLEAR in_words.

      CALL FUNCTION 'SPELL_AMOUNT'
        EXPORTING
          amount    = gs_header-kwert37
          currency  = 'IDR'
          language  = 'i'
        IMPORTING
          in_words  = in_words
        EXCEPTIONS
          not_found = 1
          too_large = 2
          OTHERS    = 3.
      IF sy-subrc = 0.
        MOVE in_words-word TO gs_header-spell.
        CONDENSE gs_header-spell.
        CONCATENATE gs_header-spell 'RUPIAH'
        INTO gs_header-spell
        SEPARATED BY space.
      ENDIF.

      gv_style4  = 'X'.
      gs_header-street     =
      'GEDUNG TEMPO SCAN TOWER LT. 16 JL. HR RASUNA SAID KAV. 3-4'.
      gs_header-city1      = 'JAKARTA SELATAN'.
      gs_header-tel_number = '021 29218888'.
      gs_header-pbfno      = 'HK.02.06.PBF/V/043/2015'.
      gs_header-name_pbf   = 'APJ'.
      gs_header-name_sp    = 'DC Manager'.
  ENDCASE.
ENDFORM.                    " F_NEW_DELIVERY_NOTE

*&---------------------------------------------------------------------*
*&      Form  F_A511
*&---------------------------------------------------------------------*
FORM f_a511  USING    fu_kunnr fu_erdat
             CHANGING fc_maxdate.
  DATA : BEGIN OF lt_a511 OCCURS 0,
           kappl TYPE kappl,
           kschl TYPE kscha,
           vkorg TYPE vkorg,
           katr1 TYPE katr1,
           vkbur TYPE vkbur,
           kdgrp TYPE kdgrp,
           kunwe TYPE kunwe,
           zday1 TYPE bzirk,
           zday2 TYPE zday2,
           zday3 TYPE zday3,
           zday4 TYPE zday4,
           zday5 TYPE zday5,
           zday6 TYPE zday6,
         END OF lt_a511.

  DATA : lv_bzirk TYPE bzirk,
         lv_kdgrp TYPE kdgrp,
         lv_vkbur TYPE vkbur,
         lv_katr1 TYPE katr1,
         lv_times TYPE i,
         lv_subrc TYPE sy-subrc,
         lv_datum TYPE sy-datum.

  DATA : holidays  LIKE iscal_day OCCURS 0 WITH HEADER LINE.

  SELECT kappl kschl vkorg katr1 vkbur kdgrp kunwe
    zday1 zday2 zday3 zday4 zday5 zday6
    FROM a511
    INTO TABLE lt_a511
    WHERE kappl EQ 'V'
      AND kschl EQ 'ZDLV'
      AND vkorg EQ likp-vkorg
      AND datbi GE sy-datum
      AND datab LE sy-datum.

  SELECT SINGLE katr1 bzirk kdgrp vkbur
    FROM kna1 JOIN knvv ON kna1~kunnr EQ knvv~kunnr
    INTO (lv_katr1, lv_bzirk, lv_kdgrp, lv_vkbur)
    WHERE kna1~kunnr EQ fu_kunnr.

  IF lv_bzirk IS NOT INITIAL.
    READ TABLE lt_a511 WITH KEY zday1 = lv_bzirk.
    IF sy-subrc EQ 0.
    ELSE.
      READ TABLE lt_a511 WITH KEY vkbur = lv_vkbur
                                  kdgrp = lv_kdgrp
                                  katr1 = lv_katr1.
      IF sy-subrc EQ 0.
      ELSE.
        READ TABLE lt_a511 WITH KEY kdgrp = lv_kdgrp
                                    katr1 = lv_katr1.
      ENDIF.
    ENDIF.
  ELSE.
    READ TABLE lt_a511 WITH KEY vkbur = lv_vkbur
                                kdgrp = lv_kdgrp
                                katr1 = lv_katr1.
    IF sy-subrc EQ 0.
    ELSE.
      READ TABLE lt_a511 WITH KEY kdgrp = lv_kdgrp
                                  katr1 = lv_katr1.
    ENDIF.
  ENDIF.

  lv_times  = lt_a511-zday3 + lt_a511-zday4 + lt_a511-zday5 +
              lt_a511-zday6.

  lv_datum  = fu_erdat.
  DO lv_times TIMES.
    CLEAR lv_subrc.
    lv_datum  = lv_datum + 1.
    WHILE lv_subrc IS INITIAL.
      CLEAR : holidays, holidays[].
      CALL FUNCTION 'HOLIDAY_GET'
        EXPORTING
          holiday_calendar           = 'T1'
          factory_calendar           = 'T1'
          date_from                  = lv_datum
          date_to                    = lv_datum
        TABLES
          holidays                   = holidays
        EXCEPTIONS
          factory_calendar_not_found = 1
          holiday_calendar_not_found = 2
          date_has_invalid_format    = 3
          date_inconsistency         = 4
          OTHERS                     = 5.

      lv_subrc  = sy-subrc.
      IF holidays[] IS NOT INITIAL.
        lv_datum  = lv_datum + 1.
      ELSE.
        lv_subrc  = 4.
      ENDIF.
    ENDWHILE.
  ENDDO.

  WRITE lv_datum TO fc_maxdate DD/MM/YYYY.
ENDFORM.                                                    " F_A511

*&---------------------------------------------------------------------*
*&      Form  F_GET_ACCOUNT_BANK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_VKORG  text
*      -->FU_VKBUR  text
*----------------------------------------------------------------------*
FORM f_get_account_bank  USING    fu_vkorg
                                  fu_vkbur.
  DATA: lt_accbank LIKE zsaccbank OCCURS 0 WITH HEADER LINE.

*{   REPLACE        P01K910454                                        1
*\  SELECT * INTO TABLE lt_accbank
*\    FROM zsaccbank
*\    WHERE vkorg = fu_vkorg AND
*\          vkbur = fu_vkbur.
  "Start SOH: Shell SCI Adjustment 20240222 RZL
  SELECT * INTO TABLE lt_accbank
    FROM zsaccbank
    WHERE vkorg = fu_vkorg AND
          vkbur = fu_vkbur ORDER BY PRIMARY KEY.
  "End SOH: Shell SCI Adjustment 20240222 RZL
*}   REPLACE
  LOOP AT lt_accbank.
    AT FIRST.
      gs_header-transfer = 'Pembayaran ditransfer ke : '.
    ENDAT.
    IF gs_header-accbank1 IS INITIAL.
      CONCATENATE lt_accbank-bank 'AC.' lt_accbank-accno
        INTO gs_header-accbank1 SEPARATED BY space.
    ELSEIF gs_header-accbank1 IS NOT INITIAL AND
           gs_header-accbank2 IS INITIAL.
      CONCATENATE gs_header-accbank1 'atau'
        INTO gs_header-accbank1 SEPARATED BY space.
      CONCATENATE lt_accbank-bank 'AC.' lt_accbank-accno
        INTO gs_header-accbank2 SEPARATED BY space.
    ELSEIF gs_header-accbank1 IS NOT INITIAL AND
           gs_header-accbank2 IS NOT INITIAL AND
           gs_header-accbank3 IS INITIAL.
      CONCATENATE gs_header-accbank2 'atau'
        INTO gs_header-accbank2 SEPARATED BY space.
      CONCATENATE lt_accbank-bank 'AC.' lt_accbank-accno
        INTO gs_header-accbank3 SEPARATED BY space.
    ELSEIF gs_header-accbank1 IS NOT INITIAL AND
           gs_header-accbank2 IS NOT INITIAL AND
           gs_header-accbank3 IS NOT INITIAL AND
           gs_header-accbank4 IS INITIAL.
      CONCATENATE gs_header-accbank3 'atau'
        INTO gs_header-accbank3 SEPARATED BY space.
      CONCATENATE lt_accbank-bank 'AC.' lt_accbank-accno
        INTO gs_header-accbank4 SEPARATED BY space.
    ELSEIF gs_header-accbank1 IS NOT INITIAL AND
           gs_header-accbank2 IS NOT INITIAL AND
           gs_header-accbank3 IS NOT INITIAL AND
           gs_header-accbank4 IS NOT INITIAL AND
           gs_header-accbank5 IS INITIAL.
      CONCATENATE gs_header-accbank4 'atau'
        INTO gs_header-accbank4 SEPARATED BY space.
      CONCATENATE lt_accbank-bank 'AC.' lt_accbank-accno
        INTO gs_header-accbank5 SEPARATED BY space.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " F_GET_ACCOUNT_BANK

*&---------------------------------------------------------------------*
*&      Form  F_CEK_AUTHORISASI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cek_authorisasi .
  CASE gv_kschl.
    WHEN 'ZDE4' OR 'ZDE5' OR 'ZDE6' OR 'ZST4' OR 'ZDE7'.
      AUTHORITY-CHECK OBJECT 'ZREPRINT'
          ID 'ACTVT' FIELD '04'.
      IF sy-subrc NE 0.
        MESSAGE 'You are not authorization' TYPE 'I'.
        LEAVE SCREEN.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_CEK_AUTHORISASI

*&---------------------------------------------------------------------*
*&      Form  F_EXCL_TAX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--FC_VALUE  text
*----------------------------------------------------------------------*
FORM f_excl_tax  CHANGING fc_value.
  IF gv_kschl = 'ZDE6'.
    fc_value = fc_value * ( 10 / 11 ).
  ENDIF.
ENDFORM.                    " F_EXCL_TAX

*&---------------------------------------------------------------------*
*&      Form  F_RECALC_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_VBELN  text
*      -->FU_POSNR  text
*      <--FC_DISCV  text
*----------------------------------------------------------------------*
FORM f_recalc_value  USING    fu_vbeln
                              fu_posnr
                     CHANGING fc_discv.
  IF gv_kschl = 'ZDE6'.
    READ TABLE gt_ztax WITH KEY doc_num = fu_vbeln
                                item_no = fu_posnr.
    IF sy-subrc = 0.
      fc_discv = fc_discv + ( gt_ztax-dis_val / 100 ).
    ENDIF.
  ENDIF.
ENDFORM.                    " F_RECALC_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_VALUE
*&---------------------------------------------------------------------*
FORM f_modify_value  USING    fu_kwert
                     CHANGING fc_kwert.

  DATA : lv_subrc     TYPE sy-subrc,
         lv_kwert(20).

  lv_kwert  = fu_kwert.
  WHILE lv_subrc IS INITIAL.
    REPLACE '.' WITH space INTO lv_kwert.
    lv_subrc  = sy-subrc.
  ENDWHILE.
  CONDENSE lv_kwert NO-GAPS.
  fc_kwert  = lv_kwert / 100.
ENDFORM.                    " F_MODIFY_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_NEW_CALC
*&---------------------------------------------------------------------*
FORM f_new_calc .
  DATA : lv_matnr1   TYPE matnr,
         lv_matnr2   TYPE matnr,
         lv_cdisca   TYPE kwert,
         lv_total    TYPE kwert,
         lv_lfimg    TYPE lfimg,
         lv_count    TYPE int4,
         lv_sumtotal TYPE kwert.

  DATA : lwa_lips  LIKE lips,
         lwa_lips1 LIKE lips,
         lwa_lips2 LIKE lips.

  DATA : BEGIN OF lt_head OCCURS 0,
           matnr TYPE matnr,
           posnr TYPE posnr,
           flag  TYPE int4,
           count TYPE int4,
         END OF lt_head.

  SORT gt_new BY posnr.
  LOOP AT gt_new.
    lt_head-matnr = gt_new-matnr.
    lt_head-posnr = gt_new-posnr.
    lt_head-count = 1.
    IF gt_new-zdisc1 <> 0.
      lt_head-flag  = 1.
    ELSE.
      CLEAR lt_head-flag.
    ENDIF.
    COLLECT lt_head.
    CLEAR lt_head.
  ENDLOOP.

  LOOP AT gt_new.
    CLEAR lt_head.
    READ TABLE lt_head WITH KEY matnr = gt_new-matnr
                                posnr = gt_new-posnr.
    IF sy-subrc = 0.
      IF lt_head-flag IS NOT INITIAL.
        CLEAR lwa_lips.
        READ TABLE gt_lips INTO lwa_lips WITH KEY matnr = gt_new-matnr
                                                  posnr = gt_new-posnr
                                         TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          IF gt_new-zdisc1 <> 0.
            CLEAR lwa_lips.
            READ TABLE gt_lips INTO lwa_lips WITH KEY pstyv = 'TANN'
                                                      uepos = gt_new-posnr.
            IF sy-subrc = 0.
              READ TABLE gt_lips INTO lwa_lips1 WITH KEY posnr = lwa_lips-uepos.
              IF lwa_lips1-matnr = gt_new-matnr.
                PERFORM f_modify_kwert USING    gt_new-kwertc25
                                       CHANGING gt_new-kwert.
                CLEAR : lwa_lips2, lv_lfimg.
                LOOP AT gt_lips INTO lwa_lips2 WHERE uecha = lwa_lips-posnr
                                                 AND matnr = lwa_lips-matnr.
                  ADD lwa_lips2-lfimg TO lv_lfimg.
                ENDLOOP.
                IF lv_lfimg = 0.
                  gt_new-zdisc1 = gt_new-kwert * lwa_lips-lfimg.
                  lv_total      = gt_new-kwert * gt_new-lfimg - gt_new-zdisc1.
                ELSE.
                  gt_new-zdisc1 = gt_new-kwert * lv_lfimg.
                  lv_total      = gt_new-kwert * gt_new-lfimg - gt_new-zdisc1.
                ENDIF.
                WRITE gt_new-zdisc1 TO gt_new-cdisca CURRENCY 'IDR'.
                CONDENSE gt_new-cdisca NO-GAPS.
                WRITE lv_total TO gt_new-total CURRENCY 'IDR'.
                CONDENSE gt_new-total NO-GAPS.
                MODIFY gt_new TRANSPORTING cdisca total.
              ELSE.
                WRITE gt_new-kwert TO gt_new-kwertc25 CURRENCY 'IDR'.
                CONDENSE gt_new-kwertc25 NO-GAPS.
                lv_total = ( gt_new-lfimg * gt_new-kwert ) - gt_new-zdisc1.
                WRITE lv_total TO gt_new-total CURRENCY 'IDR'.
                CONDENSE gt_new-total NO-GAPS.
                MODIFY gt_new TRANSPORTING kwertc25 total.
              ENDIF.
            ENDIF.
          ELSE.
            PERFORM f_modify_kwert USING    gt_new-kwertc25
                                   CHANGING gt_new-kwert.
            WRITE gt_new-kwert TO gt_new-kwertc25 CURRENCY 'IDR'.
            CONDENSE gt_new-kwertc25 NO-GAPS.
            lv_total = gt_new-lfimg * gt_new-kwert.
            WRITE lv_total TO gt_new-total CURRENCY 'IDR'.
            CONDENSE gt_new-total NO-GAPS.
            MODIFY gt_new TRANSPORTING kwertc25 total.
          ENDIF.
        ELSE.
          WRITE gt_new-kwert TO gt_new-kwertc25 CURRENCY 'IDR'.
          CONDENSE gt_new-kwertc25 NO-GAPS.
          lv_total = ( gt_new-lfimg * gt_new-kwert ) - gt_new-zdisc1.
          WRITE lv_total TO gt_new-total CURRENCY 'IDR'.
          CONDENSE gt_new-total NO-GAPS.
          MODIFY gt_new TRANSPORTING kwertc25 total.
        ENDIF.
      ELSE.
        PERFORM f_modify_value USING gt_new-kwertc25
                               CHANGING gt_new-kwert.
        IF lt_head-count = 1.
          gt_new-total = gt_new-kzwi5c.
        ELSE.
          ADD 1 TO lv_count.
          IF lv_count = lt_head-count.
            lv_total = gt_new-kzwi5 - lv_sumtotal.
            WRITE lv_total TO gt_new-total CURRENCY 'IDR'.
            CONDENSE gt_new-total NO-GAPS.
            CLEAR : lv_count, lv_sumtotal.
          ELSE.
            lv_total = ( gt_new-lfimg * gt_new-kwert ).
            ADD lv_total TO lv_sumtotal.
            WRITE lv_total TO gt_new-total CURRENCY 'IDR'.
            CONDENSE gt_new-total NO-GAPS.
          ENDIF.
        ENDIF.
        MODIFY gt_new TRANSPORTING total.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_NEW_CALC

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_PRICING
*&---------------------------------------------------------------------*
FORM f_collect_pricing  TABLES   ft_konv STRUCTURE konv
                        USING    fu_vbeln.
  SELECT *
    FROM vbap
    INTO CORRESPONDING FIELDS OF TABLE gt_vbap
    WHERE vbeln = fu_vbeln.
ENDFORM.                    " F_COLLECT_PRICING

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_KWERT
*&---------------------------------------------------------------------*
FORM f_modify_kwert  USING    fu_value
                     CHANGING fc_value.
  DATA : lv_value(20),
         lv_subrc   TYPE sy-subrc.

  lv_value  = fu_value.
  WHILE lv_subrc IS INITIAL.
    REPLACE '.' WITH space INTO lv_value.
    lv_subrc = sy-subrc.
  ENDWHILE.
  CONDENSE lv_value NO-GAPS.
  fc_value = lv_value / 100.
ENDFORM.                    " F_MODIFY_KWERT

*&---------------------------------------------------------------------*
*&      Form  F_GET_CMPRE
*&---------------------------------------------------------------------*
FORM f_get_cmpre  USING    fu_item-posnr
                  CHANGING fc_nsp fc_total.

  READ TABLE gt_lips WITH KEY posnr = fu_item-posnr
                              uepos = space.
  IF sy-subrc = 0.
    READ TABLE gt_vbap WITH KEY posnr = gt_lips-vgpos.
    IF sy-subrc = 0.
      fc_nsp    = gt_vbap-cmpre.
      fc_total  = gt_vbap-kzwi5.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_CMPRE

*&---------------------------------------------------------------------*
*&      Form  F_CONV_TO_CHAR
*&---------------------------------------------------------------------*
FORM f_conv_to_char  USING    fu_value
                     CHANGING fc_value fc_valuetxt.
  fc_value  = fu_value.

  WRITE fu_value TO fc_valuetxt CURRENCY 'IDR' NO-SIGN.
  CONDENSE fc_valuetxt.
ENDFORM.                    " F_CONV_TO_CHAR

*&---------------------------------------------------------------------*
*&      Form  F_WITHOUT_BATCH_SPLIT
*&---------------------------------------------------------------------*
FORM f_without_batch_split  TABLES   ft_007 STRUCTURE zssutst007
                                     ft_lipsx STRUCTURE lips
                                     ft_lipsh2 STRUCTURE lips.

  REFRESH ft_007.
*        LOOP AT ft_lipsx WHERE matnr = ft_lipsh2-matnr AND charg IS NOT INITIAL.
  LOOP AT ft_lipsx WHERE vbeln = ft_lipsh2-vbeln
                     AND matnr = ft_lipsh2-matnr
                     AND ( posnr = ft_lipsh2-posnr
                      OR   uecha = ft_lipsh2-posnr
                      OR   uepos = ft_lipsh2-posnr ).
    IF ft_lipsx-charg IS NOT INITIAL.
      IF ft_lipsx-uecha = ft_lipsh2-posnr OR ft_lipsx-uepos = ft_lipsh2-posnr OR ft_lipsx-uecha IS INITIAL.
        " __* TO-DOs
        READ TABLE ft_007 WITH KEY vbeln = ft_lipsx-vbeln
                                   charg = ft_lipsx-charg.
        IF sy-subrc = 0.
          ft_007-lfimg = ft_007-lfimg + ft_lipsx-lfimg.
          MODIFY ft_007 INDEX sy-tabix TRANSPORTING lfimg.
        ELSE.
          ft_007-vbeln = ft_lipsx-vbeln.
          ft_007-matnr = ft_lipsx-matnr.
          ft_007-charg = ft_lipsx-charg.
          CONCATENATE 'Batch' ft_007-charg INTO ft_007-charg_c SEPARATED BY space.
          ft_007-vfdat = ft_lipsx-vfdat.
          ft_007-lfimg = ft_lipsx-lfimg.
          ft_007-vrkme = ft_lipsx-vrkme.
          ft_007-uecha = ft_lipsx-uecha.
          IF ft_007-uecha IS INITIAL.
            ft_007-uecha = ft_lipsx-posnr.
          ENDIF.
          IF ft_lipsx-uepos IS NOT INITIAL.
            ft_007-uecha = ft_lipsx-uepos.
          ENDIF.
          APPEND ft_007. CLEAR ft_007.
        ENDIF.
      ENDIF.
    ELSEIF ft_lipsx-xchpf IS INITIAL.
      IF ft_lipsx-uecha = ft_lipsh2-posnr OR
         ft_lipsx-uepos = ft_lipsh2-posnr OR
         ft_lipsx-posnr = ft_lipsh2-posnr.
*              READ TABLE ft_007 WITH KEY matnr = ft_lipsx-matnr.
        IF ft_lipsx-uepos IS INITIAL.
          READ TABLE ft_007 WITH KEY vbeln = ft_lipsx-vbeln
                                     matnr = ft_lipsx-matnr
                                     uecha = ft_lipsx-posnr.
        ELSE.
          READ TABLE ft_007 WITH KEY vbeln = ft_lipsx-vbeln
                                     matnr = ft_lipsx-matnr
                                     uecha = ft_lipsx-uepos.
        ENDIF.
        IF sy-subrc = 0.
          ft_007-lfimg = ft_007-lfimg + ft_lipsx-lfimg.
          MODIFY ft_007 INDEX sy-tabix TRANSPORTING lfimg.
        ELSE.
          ft_007-vbeln = ft_lipsx-vbeln.
          ft_007-matnr = ft_lipsx-matnr.
          ft_007-charg = ft_lipsx-charg.
          ft_007-vfdat = ft_lipsx-vfdat.
          ft_007-lfimg = ft_lipsx-lfimg.
          ft_007-vrkme = ft_lipsx-vrkme.
          IF ft_lipsx-uepos IS NOT INITIAL.
            ft_007-uecha = ft_lipsx-uepos.
          ELSE.
            ft_007-uecha = ft_lipsx-posnr.
          ENDIF.
          APPEND ft_007. CLEAR ft_007.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_WITHOUT_BATCH_SPLIT

*&---------------------------------------------------------------------*
*&      Form  F_GET_LFIMG_WITHOUT_BS
*&---------------------------------------------------------------------*
FORM f_get_lfimg_without_bs  TABLES   ft_lipsh STRUCTURE lips
                                      ft_lipsh2 STRUCTURE lips.
  CLEAR gt_item-lfimg.
  LOOP AT ft_lipsh WHERE vbeln = ft_lipsh2-vbeln
                     AND matnr = ft_lipsh2-matnr. " AND uecha = ft_lipsh2-posnr.
    IF ft_lipsh-posnr = ft_lipsh2-posnr.
      IF ft_lipsh-lfimg IS NOT INITIAL.
        gt_item-lfimg = gt_item-lfimg + ft_lipsh-lfimg.
      ELSE.
        gt_item-lfimg = gt_item-lfimg + ft_lipsh-kcmeng.
      ENDIF.
*          ELSEIF ft_lipsh-uepos = ft_lipsh2-vgpos OR ft_lipsh-vgpos = ft_lipsh2-uepos.
*            IF ft_lipsh-lfimg IS NOT INITIAL.
*              gt_item-lfimg = gt_item-lfimg + ft_lipsh-lfimg.
*            ELSE.
*              gt_item-lfimg = gt_item-lfimg + ft_lipsh-kcmeng.
*            ENDIF.
    ELSEIF ft_lipsh-uepos = ft_lipsh2-posnr.
      IF ft_lipsh-lfimg IS NOT INITIAL.
        gt_item-lfimg = gt_item-lfimg + ft_lipsh-lfimg.
      ELSE.
        gt_item-lfimg = gt_item-lfimg + ft_lipsh-kcmeng.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_LFIMG_WITHOUT_BS

*&---------------------------------------------------------------------*
*&      Form  F_CEK_CANCEL_GI
*&---------------------------------------------------------------------*
FORM f_cek_cancel_gi  TABLES   ft_vbfa STRUCTURE gt_vbfa
                               ft_mseg STRUCTURE gt_mseg.

  CASE gv_kschl.
    WHEN 'ZST7'.
      SELECT vbelv posnv vbeln posnn vbtyp_n erdat bwart
        FROM vbfa
        INTO TABLE ft_vbfa
        WHERE vbelv   = p_vbeln
          AND vbtyp_n = 'h'
          AND bwart <> space.
    WHEN 'ZT07' OR 'ZT08' OR 'ZT09'.
      SELECT vbelv posnv vbeln posnn vbtyp_n erdat bwart matnr
        FROM vbfa
        INTO CORRESPONDING FIELDS OF TABLE ft_vbfa
        FOR ALL ENTRIES IN gt_vttp
        WHERE vbelv   = gt_vttp-vbeln
          AND vbtyp_n = 'h'
          AND bwart <> space.
  ENDCASE.

  IF ft_vbfa[] IS NOT INITIAL.
    SELECT mblnr smbln
      FROM mseg
      INTO TABLE ft_mseg
      FOR ALL ENTRIES IN ft_vbfa
      WHERE mblnr = ft_vbfa-vbeln
        AND xauto = space.
  ENDIF.
ENDFORM.                    " F_CEK_CANCEL_GI

*&---------------------------------------------------------------------*
*&      Form  F_GET_FR_SHIPMENT
*&---------------------------------------------------------------------*
FORM f_get_fr_shipment .
  SELECT SINGLE tknum erdat datbg route
    FROM vttk
    INTO gs_vttk
    WHERE tknum = p_vbeln.

  SELECT tknum tpnum vbeln erdat
    FROM vttp
    INTO TABLE gt_vttp
    WHERE tknum = p_vbeln.
ENDFORM.                    " F_GET_FR_SHIPMENT

*&---------------------------------------------------------------------*
*&      Form  F_NEW_CALC_FR_SHIPMENT
*&---------------------------------------------------------------------*
FORM f_new_calc_fr_shipment .
  DATA : lt_new    LIKE gt_new OCCURS 0 WITH HEADER LINE,
         lt_005    LIKE zmsutdt005 OCCURS 0 WITH HEADER LINE,
         lv_vrkme  LIKE zsdelnote-vrkme,
         lv_total  LIKE zsdelnote-kwert,
         lv_kwert  LIKE zsdelnote-kwert,
         lv_kwertp TYPE p DECIMALS 5.

  lt_new[] = gt_new[].
  SORT lt_new[] BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_new COMPARING matnr.
  IF lt_new[] IS NOT INITIAL.
    SELECT *
      FROM zmsutdt005
      INTO CORRESPONDING FIELDS OF TABLE lt_005
      FOR ALL ENTRIES IN lt_new
      WHERE bukrs = likp-vkorg
        AND matnr = lt_new-matnr.
  ENDIF.

  CLEAR : lt_new[], lt_new.
  lt_new[]  = gt_new[].

  CLEAR : gt_new[], gt_new.

  LOOP AT lt_new.
    gt_new-matnr  = lt_new-matnr.
    gt_new-arktx  = lt_new-arktx.
    gt_new-charg  = lt_new-charg.
    gt_new-vfdatc = lt_new-vfdatc.
    gt_new-lfimg  = lt_new-lfimg.
*    gt_new-kwert  = lt_new-kwert.
    READ TABLE gt_detail WITH KEY matnr = lt_new-matnr
                                  charg = lt_new-charg.
    IF sy-subrc = 0.
      gt_new-vrkme  = gt_detail-vrkme.
    ENDIF.
    COLLECT gt_new.
    CLEAR gt_new.
  ENDLOOP.

  SORT lt_005 BY matnr umrez DESCENDING.

  BREAK bcdik.

  SORT gt_msegnew BY matnr charg.

  LOOP AT gt_new.
    WRITE gt_new-lfimg TO gt_new-lfimgc UNIT gt_new-vrkme.
    CONDENSE gt_new-lfimgc NO-GAPS.

    CLEAR : gt_msegnew, lv_kwert.
    READ TABLE gt_msegnew WITH KEY matnr = gt_new-matnr
                                   charg = gt_new-charg.
    IF sy-subrc = 0.
      gt_new-kwert  = gt_msegnew-dmbtr / gt_msegnew-menge.
      lv_kwertp     = gt_msegnew-dmbtr / gt_msegnew-menge.
      READ TABLE gt_msegsum WITH KEY matnr = gt_msegnew-matnr
                                     charg = gt_msegnew-charg.
      IF sy-subrc = 0.
        lv_kwert  = gt_msegsum-dmbtr.
      ENDIF.
    ENDIF.

    WRITE gt_new-kwert TO gt_new-kwertc25 CURRENCY 'IDR'.
    CONDENSE gt_new-kwertc25 NO-GAPS.

    gt_new-kzwi5  = gt_new-lfimg * gt_new-kwert.
*    gt_new-kzwi5  = gt_new-lfimg * lv_kwertp.
*    gt_new-kzwi5  = lv_kwert.

    WRITE gt_new-kzwi5 TO gt_new-total CURRENCY 'IDR'.
    CONDENSE gt_new-total NO-GAPS.

    PERFORM f_split_quantity TABLES   lt_005
                             USING    gt_new-matnr gt_new-lfimg
                                      gt_new-lfimgc gt_new-vrkme
                             CHANGING gt_new-car31a.

    PERFORM f_conversion_exit_cunit USING gt_new-vrkme
                                    CHANGING lv_vrkme.

    CONCATENATE gt_new-lfimgc gt_new-vrkme INTO gt_new-lfimgc
    SEPARATED BY space.

    MODIFY gt_new TRANSPORTING lfimgc car31a kwert kwertc25 kzwi5 total.
  ENDLOOP.

  BREAK bcdik.

  CLEAR : lv_total, gs_header-kwert37.
  LOOP AT gt_new.
    lv_total  = gt_new-kzwi5.
    ADD lv_total TO gs_header-kwert37.
  ENDLOOP.

  WRITE gs_header-kwert37 TO gs_header-kwertc37 CURRENCY 'IDR'.
  CONDENSE gs_header-kwertc37.

  DATA in_words TYPE spell.
  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount    = gs_header-kwertc37
      currency  = 'IDR'
      language  = 'i'
    IMPORTING
      in_words  = in_words
    EXCEPTIONS
      not_found = 1
      too_large = 2
      OTHERS    = 3.
  IF sy-subrc = 0.
    MOVE in_words-word TO gs_header-spell.
    CONDENSE gs_header-spell.
    CONCATENATE gs_header-spell 'RUPIAH'
    INTO gs_header-spell
    SEPARATED BY space.
  ENDIF.
ENDFORM.                    " F_NEW_CALC_FR_SHIPMENT

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_QUANTITY
*&---------------------------------------------------------------------*
FORM f_split_quantity  TABLES   ft_005 STRUCTURE zmsutdt005
                       USING    fu_matnr fu_lfimg fu_lfimgc fu_vrkme
                       CHANGING fc_car31a.
  DATA : lv_count  TYPE i,
         lv_i1     TYPE i, lv_c1(10),
         lv_i2     TYPE i,
         lv_i3     TYPE i, lv_c3(10),
         lv_i4     TYPE i,
         lv_vrkme  LIKE zsdelnote-vrkme.

  CLEAR : fc_car31a.

  lv_i1 = fu_lfimg.

  READ TABLE ft_005 WITH KEY matnr = fu_matnr
                    TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    LOOP AT ft_005 FROM sy-tabix.
      IF ft_005-matnr <> fu_matnr.
        lv_c1 = lv_i1.
        CONDENSE lv_c1 NO-GAPS.

        PERFORM f_conversion_exit_cunit USING fu_vrkme
                                        CHANGING lv_vrkme.

        CONCATENATE fc_car31a lv_c1 lv_vrkme INTO fc_car31a
        SEPARATED BY space.
        EXIT.
      ENDIF.

      lv_i2 = ft_005-umrez.
      lv_i3 = lv_i1 DIV lv_i2.
      lv_i4 = lv_i1 MOD lv_i2.

      IF lv_i3 > 0.
        lv_c3 = lv_i3.
        CONDENSE lv_c3 NO-GAPS.
        PERFORM f_conversion_exit_cunit USING ft_005-zaun
                                        CHANGING lv_vrkme.

        CONCATENATE fc_car31a lv_c3 lv_vrkme INTO fc_car31a
        SEPARATED BY space.
      ENDIF.
      IF lv_i4 <= 0.
        EXIT.
      ELSE.
        lv_i1 = lv_i4.
      ENDIF.
    ENDLOOP.
  ELSE.
    PERFORM f_conversion_exit_cunit USING fu_vrkme
                                    CHANGING lv_vrkme.

    CONCATENATE fu_lfimgc lv_vrkme INTO fc_car31a
    SEPARATED BY space.
  ENDIF.
ENDFORM.                    " F_SPLIT_QUANTITY

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_EXIT_CUNIT
*&---------------------------------------------------------------------*
FORM f_conversion_exit_cunit  USING    fu_vrkme
                              CHANGING fc_vrkme.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fu_vrkme
    IMPORTING
      output         = fc_vrkme
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
ENDFORM.                    " F_CONVERSION_EXIT_CUNIT

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM_ER
*&---------------------------------------------------------------------*
FORM f_print_form_er .
  SORT gt_detl_er BY matnr.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  IF d_frm_subrc IS INITIAL.
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        gv_header          = gv_head_er
      TABLES
        gt_detail          = gt_detl_er.
  ENDIF.
ENDFORM.                    " F_PRINT_FORM_ER

*&---------------------------------------------------------------------*
*&      Form  F_SYN_FORM_ER
*&---------------------------------------------------------------------*
FORM f_syn_form_er .
  DATA : lt_new  TYPE TABLE OF zsdelnote WITH HEADER LINE,
         lt_mara TYPE STANDARD TABLE OF mara,
         ls_mara LIKE LINE OF lt_mara,
         lt_makt TYPE STANDARD TABLE OF makt,
         ls_makt LIKE LINE OF lt_makt.

  DATA : lt_konp   TYPE TABLE OF konp WITH HEADER LINE,
         lt_a934   TYPE TABLE OF a934 WITH HEADER LINE,
         ls_vtpa   LIKE vtpa,
         lv_jumlah TYPE kwert,
         lv_dpp    TYPE kwert,
         lv_ppn    TYPE kwert.

  IF gt_new[] IS NOT INITIAL.
    SELECT * INTO TABLE lt_a934
      FROM a934 FOR ALL ENTRIES IN gt_new
      WHERE kappl = 'V'
        AND kschl = 'ZHET'
        AND vkorg = likp-vkorg
        AND auart_sd = space
        AND matnr = gt_new-matnr
        AND datbi GE gs_header-wadat
        AND datab LE gs_header-wadat.
    IF sy-subrc = 0.
      SELECT * INTO TABLE lt_konp
        FROM konp FOR ALL ENTRIES IN lt_a934
        WHERE knumh = lt_a934-knumh.
    ENDIF.
  ENDIF.

  SELECT SINGLE * INTO ls_vtpa FROM vtpa
    WHERE vbeln = p_vbeln
      AND parvw = 'WE'.

  PERFORM f_alamat_pelanggan USING ls_vtpa-adrnr.

  CLEAR : gv_head_er, gt_detl_er[], gt_detl_er.

  gv_head_er-vbeln        = gs_header-vbelnl.
  READ TABLE gt_vttp INDEX 1.
  IF sy-subrc = 0.
    gv_head_er-vgbel        = gt_vttp-vbeln.
  ENDIF.
  gv_head_er-textname     = 'ZSD_8220_INVGT_SIGNER'.
*  gv_head_er-kunnr        = gs_header-kunnr.
*  gv_head_er-kunrg        = gs_header-kunnr.
  gv_head_er-kunnr        = ls_vtpa-kunnr.
  gv_head_er-kunrg        = ls_vtpa-kunnr.
  gv_head_er-fkdat        = gs_header-wadat.
  gv_head_er-harga_jual   = gs_header-kwertc37.
  gv_head_er-nilai_fak    = gs_header-kwertc37.
  gv_head_er-sp_name1     = gs_header-name1.
  IF gs_header-tdline IS INITIAL.
    gv_head_er-p_name1      = gs_header-name1.
  ELSE.
    gv_head_er-p_name1      = gs_header-tdline.
  ENDIF.
  gv_head_er-sp_addr1     = gs_header-name2.
  gv_head_er-sp_addr2     = gs_header-name3.
  gv_head_er-sp_addr3     = gs_header-name4.
*  SELECT SINGLE tel_number
*    FROM kna1 JOIN adrc ON kna1~adrnr = adrc~addrnumber
*    INTO gv_head_er-sp_phone
*    WHERE kunnr = gs_header-kunnr.
  SELECT SINGLE tel_number INTO gv_head_er-sp_phone
    FROM adrc WHERE addrnumber = ls_vtpa-adrnr.
  SELECT SINGLE stceg INTO gv_head_er-p_npwp
    FROM kna1 WHERE kunnr = gv_head_er-kunnr.

*  gv_head_er-p_npwp       = gs_header-stceg.
  gv_head_er-area         = 'BATAM'.
  SELECT SINGLE bezei
    FROM tvrot
    INTO gv_head_er-bezei
    WHERE spras = sy-langu
      AND route = gs_vttk-route.

  lt_new[] = gt_new[].
  SORT lt_new BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_new COMPARING matnr.
  IF lt_new[] IS NOT INITIAL.
    SELECT matnr bismt ean11
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE lt_mara
      FOR ALL ENTRIES IN lt_new
      WHERE matnr = lt_new-matnr.

    SELECT matnr maktx
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE lt_makt
      FOR ALL ENTRIES IN lt_new
      WHERE matnr = lt_new-matnr
        AND spras = sy-langu.
  ENDIF.

  LOOP AT gt_new.
    gt_detl_er-matnr  = gt_new-matnr.

    READ TABLE lt_mara INTO ls_mara WITH KEY matnr = gt_new-matnr.
    IF sy-subrc = 0.
      gt_detl_er-bismt  = ls_mara-bismt.
      gt_detl_er-ean11  = ls_mara-ean11.
    ENDIF.
    READ TABLE lt_makt INTO ls_makt WITH KEY matnr = gt_new-matnr.
    IF sy-subrc = 0.
      gt_detl_er-maktx  = ls_makt-maktx.
    ENDIF.

    WRITE gt_new-lfimg TO gt_detl_er-quantity UNIT gt_new-vrkme.
*    gt_detl_er-harga_sat  = gt_new-kwertc25.
*    gt_detl_er-jumlah     = gt_new-total.

    CLEAR: lt_konp,lt_a934,lv_jumlah.
    READ TABLE lt_a934 WITH KEY matnr = gt_detl_er-matnr.
    READ TABLE lt_konp WITH KEY knumh = lt_a934-knumh.

    lt_konp-kbetr = lt_konp-kbetr * ( 100 / 111 ).
    lv_jumlah = gt_new-lfimg * lt_konp-kbetr.
    WRITE lt_konp-kbetr TO gt_detl_er-harga_sat CURRENCY 'IDR'.
    WRITE lv_jumlah TO gt_detl_er-jumlah CURRENCY 'IDR'.

    ADD lv_jumlah TO gs_header-kwert37.

    APPEND gt_detl_er.
    CLEAR gt_detl_er.
  ENDLOOP.

  lv_dpp  = gs_header-kwert37 * 10 / 11.

** Project PPN 11% - begin
  DATA: "ls_zproject TYPE zproject,
    ls_11 TYPE zproject,
    ls_12 TYPE zproject.

  DATA : lr_datab TYPE RANGE OF datab,
         ls_datab LIKE LINE OF lr_datab.

*****  SELECT SINGLE * INTO ls_zproject
*****    FROM zproject WHERE name = 'PPN11'
*****                    AND flag = 'X'.
*****  IF sy-subrc = 0 AND likp-wadat_ist GE ls_zproject-datab.
*****    CLEAR: lv_dpp.
*****    lv_dpp = gs_header-kwert37 * ls_zproject-char1 / ls_zproject-char2.
*****  ENDIF.
** Project PPN 11% - end

  SELECT SINGLE * INTO ls_11
    FROM zproject WHERE name = 'PPN11'
                    AND flag = 'X'.
  SELECT SINGLE * INTO ls_12
*   FROM zproject WHERE name = 'PPN12'
    FROM zproject WHERE name = 'DPP12'
                    AND flag = 'X'.
  ls_datab-low    = ls_11-datab.
  ls_datab-high   = ls_12-datab.
  ls_datab-sign   = 'I'.
  ls_datab-option = 'BT'.
  APPEND ls_datab TO lr_datab.

  IF likp-wadat_ist IN lr_datab.
    CLEAR: lv_dpp.
*    lv_dpp = gs_header-kwert37 * ls_11-char1 / ls_11-char2.
    lv_dpp = gs_header-kwert37 * ( 10 / 11 ).
  ELSEIF likp-wadat_ist > ls_12-datab.
    CLEAR: lv_dpp.
*    lv_dpp = gs_header-kwert37 * ls_12-char1 / ls_12-char2.
     lv_dpp = gs_header-kwert37 * ( 11 / 12 ).
  ENDIF.

*  lv_ppn  = gs_header-kwert37 - lv_dpp.
  lv_ppn  = lv_dpp * ( 12 / 100 ).

  WRITE gs_header-kwert37 TO gs_header-kwertc37 CURRENCY 'IDR'.
  CONDENSE gs_header-kwertc37.
  WRITE lv_dpp TO gv_head_er-nilai_dpp CURRENCY 'IDR'.
  CONDENSE gv_head_er-nilai_dpp.
  WRITE lv_ppn TO gv_head_er-nilai_ppn CURRENCY 'IDR'.
  CONDENSE gv_head_er-nilai_ppn.

  gv_head_er-harga_jual   = gs_header-kwertc37.
*  gv_head_er-nilai_fak    = gs_header-kwertc37.
  DATA: kwert37 TYPE kwert.
  kwert37 = gs_header-kwert37 + lv_ppn .
  WRITE kwert37 TO gv_head_er-nilai_fak CURRENCY 'IDR'.
  CONDENSE gv_head_er-nilai_fak.

  DATA in_words TYPE spell.
  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount    = gs_header-kwertc37
      currency  = 'IDR'
      language  = 'i'
    IMPORTING
      in_words  = in_words
    EXCEPTIONS
      not_found = 1
      too_large = 2
      OTHERS    = 3.
  IF sy-subrc = 0.
    MOVE in_words-word TO gs_header-spell.
    CONDENSE gs_header-spell.
    CONCATENATE gs_header-spell 'RUPIAH'
    INTO gs_header-spell
    SEPARATED BY space.
  ENDIF.
ENDFORM.                    " F_SYN_FORM_ER

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM_PPTZ03
*&---------------------------------------------------------------------*
FORM f_print_form_pptz03 .
  SORT gt_new BY matnr.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

*  perform f_test_next_page.
  IF d_frm_subrc IS INITIAL.
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        gs_header          = gs_header
      TABLES
        gt_new             = gt_new[].
  ENDIF.
ENDFORM.                    " F_PRINT_FORM_PPTZ03

*&---------------------------------------------------------------------*
*&      Form  F_CALC_PPTZ03
*&---------------------------------------------------------------------*
FORM f_calc_pptz03 .
  DATA : holidays  TYPE STANDARD TABLE OF iscal_day,
         lv_subrc  TYPE sy-subrc,
         lv_length TYPE i,
         lt_xnew   TYPE STANDARD TABLE OF zsdelnote,
         ls_xnew   LIKE LINE OF lt_xnew,
         ls_new    LIKE LINE OF gt_new,
         lv_lfimg  TYPE lips-lfimg,
         lv_nou    TYPE i,
         lv_kunnr  TYPE likp-kunnr,
         lv_werks  TYPE t001w-werks.

  DATA : ls_a934 LIKE LINE OF gt_a934,
         ls_konp LIKE LINE OF gt_konp.

  lv_length = strlen( gs_vttk-tknum ).
  lv_length = lv_length - 3.

  READ TABLE gt_lips INDEX 1.
  IF sy-subrc = 0.
    SELECT SINGLE name1
      FROM t001w
      INTO gs_header-name_co
      WHERE werks = gt_lips-werks.
    SELECT SINGLE kunnr
      FROM likp
      INTO lv_kunnr
      WHERE vbeln = gt_lips-vbeln.
    IF sy-subrc = 0.
      SELECT SINGLE werks
        FROM t001w
        INTO lv_werks
        WHERE kunnr = lv_kunnr.
      IF sy-subrc <> 0.
        SELECT SINGLE werks
          FROM t001l
          INTO lv_werks
          WHERE kunnr = lv_kunnr.
      ENDIF.
    ENDIF.
    PERFORM f_modify_harga USING gt_lips-werks.
  ENDIF.

  CONCATENATE lv_werks '-' 'BTM ' INTO gs_header-header_text.
  CONCATENATE gs_header-header_text gs_vttk-tknum+lv_length(3) gs_vttk-erdat+4(2) gs_vttk-erdat(4)
  INTO gs_header-header_text
  SEPARATED BY '/'.
  gs_header-mahdt = gs_vttk-erdat - 2.
  lv_subrc = 4.
  WHILE lv_subrc = 4.
    CLEAR holidays[].
    CALL FUNCTION 'HOLIDAY_GET'
      EXPORTING
        holiday_calendar           = 'T1'
        factory_calendar           = 'T1'
        date_from                  = gs_header-mahdt
        date_to                    = gs_header-mahdt
      TABLES
        holidays                   = holidays
      EXCEPTIONS
        factory_calendar_not_found = 1
        holiday_calendar_not_found = 2
        date_has_invalid_format    = 3
        date_inconsistency         = 4
        OTHERS                     = 5.

    IF holidays[] IS NOT INITIAL.
      gs_header-mahdt = gs_header-mahdt - 1.
    ELSE.
      CLEAR lv_subrc.
    ENDIF.
  ENDWHILE.

  lt_xnew[] = gt_new[].
  CLEAR : gt_new[], gt_new.

  LOOP AT lt_xnew INTO ls_xnew.
    gt_new-matnr    = ls_xnew-matnr.
    gt_new-arktx    = ls_xnew-arktx.
    gt_new-lfimg    = ls_xnew-lfimg.
    gt_new-vrkme    = ls_xnew-vrkme.

    IF gt_lips-werks = '2200'.
      CLEAR : ls_a934, ls_konp.
      READ TABLE gt_a934 INTO ls_a934
                         WITH KEY matnr = ls_xnew-matnr.
      IF sy-subrc = 0.
        READ TABLE gt_konp INTO ls_konp
                           WITH KEY knumh = ls_a934-knumh.
        IF sy-subrc = 0.
          WRITE ls_konp-kbetr TO ls_xnew-kwertc25 CURRENCY 'IDR'.
          ls_xnew-kzwi5 = ls_konp-kbetr * ls_xnew-lfimg.
        ENDIF.
      ENDIF.

      gt_new-kwertc25 = ls_xnew-kwertc25.
      gt_new-kzwi5    = ls_xnew-kzwi5.
    ELSE.
      gt_new-kwertc25 = ls_xnew-kwertc25.
      gt_new-kzwi5    = ls_xnew-kzwi5.
    ENDIF.
    COLLECT gt_new.
    CLEAR gt_new.
  ENDLOOP.

  SORT gt_new BY matnr.
  LOOP AT gt_new INTO ls_new.
    ADD 1 TO lv_nou.
    WRITE lv_nou TO ls_new-nou DECIMALS 0.
    WRITE ls_new-lfimg TO ls_new-lfimgc UNIT ls_new-vrkme.
    ADD ls_new-lfimg TO lv_lfimg.
    WRITE ls_new-kzwi5 TO ls_new-total CURRENCY 'IDR'.
    ADD ls_new-kzwi5 TO gs_header-kwert33.
    MODIFY gt_new FROM ls_new TRANSPORTING nou lfimgc total.
    CLEAR ls_new.
  ENDLOOP.

  WRITE gs_header-kwert33 TO gs_header-totalsalest CURRENCY 'IDR'.
  WRITE lv_lfimg TO gs_header-kwertc38 DECIMALS 0.
ENDFORM.                    " F_CALC_PPTZ03

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_HARGA
*&---------------------------------------------------------------------*
FORM f_modify_harga USING fu_werks.
  IF fu_werks = '2200'.
    CLEAR : gt_konp, gt_konp[].
    IF gt_new[] IS NOT INITIAL.
      SELECT *
        FROM a934
        INTO TABLE gt_a934
        FOR ALL ENTRIES IN gt_new
        WHERE kappl = 'V'
          AND kschl = 'ZHET'
          AND vkorg = likp-vkorg
          AND auart_sd = space
          AND matnr = gt_new-matnr
          AND datbi GE gs_vttk-erdat
          AND datab LE gs_vttk-erdat.
      IF sy-subrc = 0.
        SELECT *
          FROM konp
          INTO TABLE gt_konp
          FOR ALL ENTRIES IN gt_a934
          WHERE knumh = gt_a934-knumh.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_HARGA
