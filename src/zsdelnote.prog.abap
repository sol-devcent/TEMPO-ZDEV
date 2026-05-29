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
REPORT  zsdelnote NO STANDARD PAGE HEADING.

INCLUDE rvadtabl.

TABLES: "nast,
  "tnapr,
  vttk,
  vbak,
  lips,
  likp.
CONSTANTS: _parvw      TYPE knvp-parvw VALUE 'AG',
           _kschl_zn01 TYPE konv-kschl VALUE 'ZN01',
           _kschl_za01 TYPE konv-kschl VALUE 'ZA01',
           _kschl_za02 TYPE konv-kschl VALUE 'ZA02',
           _kschl_zd11 TYPE konv-kschl VALUE 'ZD11',
           _kschl_zf01 TYPE konv-kschl VALUE 'ZF01',
           _kschl_zf02 TYPE konv-kschl VALUE 'ZF02',
           _kschl_zf03 TYPE konv-kschl VALUE 'ZF03',
           _kschl_zf08 TYPE konv-kschl VALUE 'ZF08',
           _kschl_zf05 TYPE konv-kschl VALUE 'ZF05',
           _kschl_zf06 TYPE konv-kschl VALUE 'ZF06',
           _kschl_zf07 TYPE konv-kschl VALUE 'ZF07',
           _kschl_zf11 TYPE konv-kschl VALUE 'ZF11',
           _kschl_zf12 TYPE konv-kschl VALUE 'ZF12',
           _kschl_zf09 TYPE konv-kschl VALUE 'ZF09',
           _kschl_zf10 TYPE konv-kschl VALUE 'ZF10',
           _kschl_zfa1 TYPE konv-kschl VALUE 'ZFA1',
           _kschl_zv01 TYPE konv-kschl VALUE 'ZV01',
           _kschl_zsd0 TYPE konv-kschl VALUE 'ZSD0',
           _kschl_zsd1 TYPE konv-kschl VALUE 'ZSD1',
           _kschl_zvat TYPE konv-kschl VALUE 'ZVAT',
           _kschl_zhjr TYPE konv-kschl VALUE 'ZHJR',
           _kschl_zdd3 TYPE konv-kschl VALUE 'ZDD3',
           _bukrs      TYPE bukrs VALUE '8070',
           _form_large TYPE ssfscreen-fname VALUE 'ZSSUT_F007', "'ZSSUT_F004',
           _form_small TYPE ssfscreen-fname VALUE 'ZSSUT_F005'.

DATA: gt_ztax           TYPE TABLE OF ztax WITH HEADER LINE.
DATA: gt_lips           TYPE TABLE OF lips WITH HEADER LINE.
DATA: gt_tdg41          TYPE TABLE OF tdg41 WITH HEADER LINE.
DATA: gt_005            TYPE TABLE OF zmsutdt005 WITH HEADER LINE.
DATA: gt_item           TYPE TABLE OF zssutst006 WITH HEADER LINE.
DATA: gt_detail         TYPE TABLE OF zssutst007 WITH HEADER LINE.
DATA: gt_table_def      TYPE TABLE OF zssutst009 WITH HEADER LINE.
DATA: gt_new            TYPE TABLE OF zsdelnote WITH HEADER LINE.
DATA: gt_nast           TYPE TABLE OF nast WITH HEADER LINE.

DATA: gs_header         TYPE zssutst005.
DATA: xscreen(1)        TYPE c.
DATA: gv_kschl          TYPE sna_kschl.
DATA: gv_noprnt(1)      TYPE c.
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

*DATA: gt_zsdisce TYPE TABLE OF zsdisce WITH HEADER LINE.

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
  PERFORM f_get_data.
  " try
*  perform f_combine_data.
  " endtry
  PERFORM f_def_page.

  PERFORM f_new_delivery_note.

  IF gv_kschl = 'ZDE5' OR gv_kschl = 'ZDE7' OR gv_kschl = 'ZDE8'.
    PERFORM f_new_calc.
    PERFORM f_cold_chain.
  ELSEIF gv_kschl = 'ZDE4'.
    PERFORM f_get_top.
    PERFORM f_calc_zv04.
    PERFORM f_get_no_sertifikasi.
    PERFORM f_cold_chain.
  ENDIF.

  IF d_frm_subrc IS INITIAL.
    PERFORM f_print_form.
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
        lv_reswk  TYPE reswk.

  DATA: lt_ddstru TYPE TABLE OF zssutst007 WITH HEADER LINE.
  DATA: lt_konv TYPE TABLE OF konv WITH HEADER LINE.
  DATA: lt_lips_matnr TYPE TABLE OF lips WITH HEADER LINE.
  DATA: lt_vbak TYPE TABLE OF vbak WITH HEADER LINE.
  DATA: lr_knumv TYPE RANGE OF vbak-knumv WITH HEADER LINE.
  DATA: lt_lipsx LIKE TABLE OF gt_lips WITH HEADER LINE.

  DATA : lv_vkbur   LIKE lips-vkbur.
  DATA : lv_adrnr   LIKE tvbur-adrnr.

  " __* Reprint
  SELECT * INTO TABLE gt_nast
    FROM nast
    WHERE kappl EQ 'V2'
      AND objky EQ p_vbeln
      AND kschl EQ gv_kschl
      AND vstat EQ '1'.
  IF sy-subrc EQ 0 AND
    ( sy-ucomm = 'PRNT' OR sy-ucomm = 'VIEW').
    IF sy-ucomm = 'PRNT'.
      AUTHORITY-CHECK OBJECT 'ZREPRINT'
          ID 'ACTVT' FIELD '04'.
      IF sy-subrc NE 0.
        MESSAGE 'You are not authorization' TYPE 'I'.
        LEAVE SCREEN.
      ENDIF.
    ENDIF.

    IF sy-ucomm = 'VIEW'.
      CLEAR gv_noprnt.
      AUTHORITY-CHECK OBJECT 'ZREPRINT'
          ID 'ACTVT' FIELD '04'.
      IF sy-subrc NE 0.
        gv_noprnt = 'X'.
      ENDIF.
    ENDIF.

    LOOP AT gt_nast.
      IF gs_header-reprint IS INITIAL.
        gs_header-reprint = 'X'.
      ELSE.
        CONCATENATE gs_header-reprint 'X' INTO gs_header-reprint.
      ENDIF.
    ENDLOOP.
  ENDIF.

  " __* Header
  SELECT SINGLE * FROM likp WHERE vbeln = p_vbeln.
  IF sy-subrc = 0.
    gs_header-vstel = likp-vstel.
    gs_header-vkorg = likp-vkorg.
    gs_header-lfart = likp-lfart.
    gs_header-lprio = likp-lprio.
    gs_header-lifex = likp-lifex.
*    SELECT SINGLE bezei INTO gs_header-bezei
*      FROM tprit WHERE spras = sy-langu AND lprio = gs_header-lprio.
*    SELECT * FROM zsdisce INTO TABLE gt_zsdisce WHERE vbeln = p_vbeln.
    SELECT * FROM ztax INTO TABLE gt_ztax WHERE doc_num  = p_vbeln.
    SELECT * FROM lips INTO TABLE gt_lips WHERE vbeln  = p_vbeln.
***    IF gt_lips[] IS NOT INITIAL.
***      SELECT profl idago
***        INTO CORRESPONDING FIELDS OF TABLE gt_tdg41
***        FROM tdg41 FOR ALL ENTRIES IN gt_lips
***        WHERE profl = gt_lips-profl.
***    ENDIF.
    " __* Adrress/City1/

*****    PERFORM f_recalc_gt_lips.   "DEVK977473       TDS_DEV01    08.12.2022 GH:AB BUD Revisi ZSDELNOTE

    PERFORM f_ie_matnr USING likp-vkorg.

    READ TABLE gt_lips INDEX 1.
    IF sy-subrc = 0.
      " __* Account Bank
*      PERFORM f_get_account_bank USING likp-vkorg gt_lips-vkbur.

      " temporary copy
      lt_lipsx[] = gt_lips[].
      PERFORM f_tempoindonesia.

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

        READ TABLE lt_vbak INDEX 1.
        IF lt_vbak-auart(3) = 'ZT7' OR
           lt_vbak-auart(3) = 'ZA7'                  .
          SELECT SINGLE vkbur
            FROM knvv
            INTO lv_vkbur
            WHERE kunnr = likp-kunnr.

          IF lv_vkbur <> gt_lips-vkbur.
            gs_header-copy  = 'X'.
          ENDIF.

        ELSE.
          lv_vkbur  = gt_lips-vkbur.
        ENDIF.

* *Get Telp. No
*        CLEAR lv_adrnr.
*        SELECT SINGLE adrnr INTO lv_adrnr
*          FROM tvbur WHERE vkbur = lv_vkbur.
*        IF sy-subrc = 0.
*          SELECT SINGLE tel_number INTO gs_header-tel_number2
*            FROM adr2 WHERE addrnumber = lv_adrnr
*                        AND r3_user = '3'.
*        ENDIF.
      ENDIF.

      gs_header-vkbur = lv_vkbur.

      PERFORM f_get_account_bank USING likp-vkorg lv_vkbur.

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
        gs_header-submi = ls_vbak-submi.
        " __
        CASE ls_vbak-abrvw.
          WHEN 'M'.
            gs_header-kr1 = 'X'.
          WHEN 'E'.
            gs_header-kr2 = 'X'.
            gs_header-cod = 'COD'.
          WHEN 'C' OR 'COD' OR 'CD'.
            gs_header-cod = 'COD'.
          WHEN 'CBD' OR 'CB'.
            gs_header-cod = 'CBD'.
        ENDCASE.

        gs_header-ponum = strlen( gs_header-bstnk ).
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
                                                                             kschl = _kschl_zhjr OR
                                                                             kschl = _kschl_za01 OR
                                                                             kschl = _kschl_za02 OR
                                                                             kschl = _kschl_zv01 OR
                                                                             kschl = _kschl_zvat OR     "SSP value
                                                                             kschl LIKE 'ZB%' OR
                                                                             kschl LIKE 'ZC%' OR
                                                                             kschl LIKE 'ZD%' OR
                                                                             kschl LIKE 'ZE%' OR
*                                                                             kschl = _kschl_zf01 OR
*                                                                             kschl = _kschl_zf02 )
                                                                             kschl LIKE 'ZF%' OR
                                                                             kschl LIKE 'ZV04' )
                                                                     AND     knumv IN lr_knumv[]
                                                                     AND     kinak EQ space.
*                                                                       AND     knumv = ls_vbak-knumv.
      ENDIF.

      IF gv_kschl = 'ZDE5' OR gv_kschl = 'ZDE7' OR gv_kschl = 'ZDE8'.
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
        LOOP AT lt_lipsh WHERE uepos = lt_lipsh2-posnr. " free good
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
        READ TABLE lt_lipsh3 WITH KEY uecha = lt_lipsh2-posnr.

        IF sy-subrc = 0.
          CLEAR gt_item-lfimg.
          LOOP AT lt_lipsh WHERE matnr = lt_lipsh2-matnr. " AND uecha = lt_lipsh2-posnr.
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
        IF sy-subrc NE 0.
          READ TABLE lt_konv WITH KEY kposn = lt_lipsh2-vgpos
                                      kschl = _kschl_zhjr
                                      knumv = lt_vbak-knumv.
        ENDIF.
*        IF sy-subrc = 0.
        IF lt_konv IS NOT INITIAL.
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
        CLEAR: gt_item-discvb, gt_item-discvc, gt_item-discvd, gt_item-discve, gt_item-discvf1, gt_item-discvf2,
               gt_item-discvf9.
        CLEAR: gt_item-discpb, gt_item-discpc, gt_item-discpd, gt_item-discpe, gt_item-discpf1, gt_item-discpf2,
               gt_item-discpf9.

        LOOP AT lt_lipsx WHERE matnr = lt_lipsh2-matnr AND uecha IS INITIAL AND posnr = lt_lipsh2-posnr.
          DATA : lv_subrc   TYPE sy-subrc.
          lv_subrc = 4.
          PERFORM f_disca TABLES lt_konv
                          USING lt_lipsx-vgpos lt_vbak-knumv
                          CHANGING lv_subrc gt_item-discva.

*          READ TABLE lt_konv WITH KEY kschl = _kschl_za01
*                                      kposn = lt_lipsx-vgpos
*                                      knumv = lt_vbak-knumv.
*          IF sy-subrc = 0.
          IF lv_subrc = 0.
*            gt_item-discva = gt_item-discva + lt_konv-kwert * -1.
            PERFORM f_excl_tax CHANGING gt_item-discva.
          ELSE.
            " __* sekarang ada diskon di freegoods, jadi cek diskon di freegoods
            LOOP AT lt_lipsh WHERE uepos = lt_lipsh2-posnr AND matnr = lt_lipsx-matnr.
              lv_subrc = 4.
              PERFORM f_disca TABLES lt_konv
                              USING lt_lipsh-vgpos lt_vbak-knumv
                              CHANGING lv_subrc gt_item-discva.

*              READ TABLE lt_konv WITH KEY kschl = _kschl_za01
*                                          kposn = lt_lipsh-vgpos
*                                          knumv = lt_vbak-knumv.
*              IF sy-subrc = 0.
              IF lv_subrc = 0.
*                gt_item-discva = gt_item-discva + lt_konv-kwert * -1.
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
            LOOP AT lt_lipsh WHERE uepos = lt_lipsh2-posnr AND matnr = lt_lipsx-matnr.
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
            LOOP AT lt_lipsh WHERE uepos = lt_lipsh2-posnr AND matnr = lt_lipsx-matnr.
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
              CASE lt_konv-kschl.
                WHEN 'ZD02' OR 'ZD08' OR 'ZD12'.
                  IF lt_konv-kbetr <> 0.
                    gs_header-kbetrzd02 = ( lt_konv-kbetr / -10 ).
                    gs_header-kwertzd02 = gs_header-kwertzd02 + ( lt_konv-kwert * -1 ).
                  ENDIF.
                WHEN 'ZD06'.
                  gs_header-kbetrzd06 = ( lt_konv-kbetr / -10 ).
                  gs_header-kwertzd06 = gs_header-kwertzd06 + ( lt_konv-kwert * -1 ).
                WHEN 'ZD11'.
                WHEN OTHERS.
                  gt_item-discpd = gt_item-discpd + ( lt_konv-kbetr / -10 ).
                  gt_item-discvd = gt_item-discvd + ( lt_konv-kwert * -1 ).
              ENDCASE.
**              PERFORM f_excl_tax CHANGING gt_item-discpd.
**              PERFORM f_excl_tax CHANGING gt_item-discvd.
              " __* discount E
            ELSEIF lt_konv-kschl CP 'ZE*'.
              gt_item-discpe = gt_item-discpe + ( lt_konv-kbetr / -10 ).
              gt_item-discve = gt_item-discve + ( lt_konv-kwert * -1 ).
**              PERFORM f_excl_tax CHANGING gt_item-discpe.
**              PERFORM f_excl_tax CHANGING gt_item-discve.
              " __* discount F1
            ELSEIF lt_konv-kschl = _kschl_zf01 OR lt_konv-kschl = _kschl_zf03 OR
                   lt_konv-kschl = _kschl_zf05 OR lt_konv-kschl = _kschl_zf10 OR
                   lt_konv-kschl = _kschl_zf07 OR lt_konv-kschl = _kschl_zf11 OR
                   lt_konv-kschl = _kschl_zf12.
*              gt_item-discpf1 = gt_item-discpf1 + ( lt_konv-kbetr / -10 ).
              gt_item-discvf1 = gt_item-discvf1 + ( lt_konv-kwert * -1 ).
**              PERFORM f_excl_tax CHANGING gt_item-discvf1.
              " __* discount F2
            ELSEIF lt_konv-kschl = _kschl_zf02 OR lt_konv-kschl = _kschl_zf08 OR
                   lt_konv-kschl = _kschl_zfa1 OR lt_konv-kschl = _kschl_zf06.
*              gt_item-discpf2 = gt_item-discpf2 + ( lt_konv-kbetr / -10 ).
              gt_item-discvf2 = gt_item-discvf2 + ( lt_konv-kwert * -1 ).
**              PERFORM f_excl_tax CHANGING gt_item-discvf2.
              " __* discount F9
            ELSEIF lt_konv-kschl = _kschl_zf09.
*              gt_item-discpf9 = gt_item-discpf9 + ( lt_konv-kbetr / -10 ).
              gt_item-discvf9 = gt_item-discvf9 + ( lt_konv-kwert * -1 ).
**              PERFORM f_excl_tax CHANGING gt_item-discvf9.
            ENDIF.
          ENDLOOP.
        ENDLOOP. " >> loop diskon

        " ---------------------------------------------------------------------------------------------------------------------------------------- #2 $COMMENT
*        lv_sum27 = gt_item-discva + gt_item-discvb + gt_item-discvc + gt_item-discvd + gt_item-discve + gt_item-discvf1 + gt_item-discvf2.
        " ---------------------------------------------------------------------------------------------------------------------------------------- #2 $COMMENT.END
        " ---------------------------------------------------------------------------------------------------------------------------------------- #2 $ADD
        lv_sum27 = gt_item-discva + gt_item-discvb + gt_item-discvd + gt_item-discvf1 +
                   gt_item-discvf2 + gt_item-discvf9.
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

        BREAK bcdik.

        READ TABLE lt_lipsh3 WITH KEY uecha = lt_lipsh2-posnr.

        IF sy-subrc = 0.
          REFRESH lt_007.
*        LOOP AT lt_lipsx WHERE matnr = lt_lipsh2-matnr AND charg IS NOT INITIAL.
          LOOP AT lt_lipsx WHERE matnr = lt_lipsh2-matnr
                             AND ( posnr = lt_lipsh2-posnr
                              OR   uecha = lt_lipsh2-posnr
                              OR   uepos = lt_lipsh2-posnr ).
            IF lt_lipsx-charg IS NOT INITIAL.
              IF lt_lipsx-uecha = lt_lipsh2-posnr OR
                lt_lipsx-uepos = lt_lipsh2-posnr OR
                lt_lipsx-uecha IS INITIAL.
                " __* TO-DOs
                READ TABLE lt_007 WITH KEY charg = lt_lipsx-charg.
                IF sy-subrc = 0.
                  lt_007-lfimg = lt_007-lfimg + lt_lipsx-lfimg.
                  MODIFY lt_007 INDEX sy-tabix TRANSPORTING lfimg.
                ELSE.
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
                  READ TABLE lt_007 WITH KEY matnr = lt_lipsx-matnr
                                             uecha = lt_lipsx-posnr.
                ELSE.
                  READ TABLE lt_007 WITH KEY matnr = lt_lipsx-matnr
                                             uecha = lt_lipsx-uepos.
                ENDIF.
                IF sy-subrc = 0.
                  lt_007-lfimg = lt_007-lfimg + lt_lipsx-lfimg.
                  MODIFY lt_007 INDEX sy-tabix TRANSPORTING lfimg.
                ELSE.
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
        REFRESH lt_005.
        LOOP AT gt_005 WHERE matnr = lt_lipsh2-matnr.
          APPEND gt_005 TO lt_005.
        ENDLOOP.
        SORT lt_005 BY umrez DESCENDING.
*        break sap_dev02.
        LOOP AT lt_007.
          CLEAR :lt_007-car31, lt_007-car31a.
*          CONCATENATE lt_007-vfdat+6(2) '.' lt_007-vfdat+4(2) '.' lt_007-vfdat+0(4) INTO  lt_007-car31. "Remove to line 846 to collect conversion first
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
*                CONCATENATE lt_007-car31 lv_c3 lt_005-zaun INTO lt_007-car31 SEPARATED BY space. "Remove to collect conversion first
                CONCATENATE lv_c3 lt_005-zaun INTO lt_007-car31 SEPARATED BY space.
                IF lt_007-car31a IS INITIAL.
                  lt_007-car31a = lt_007-car31.
                ELSE.
                  CONCATENATE lt_007-car31a lt_007-car31 INTO lt_007-car31a SEPARATED BY space. "New logic to collect material conversion first
                ENDIF.
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
*                CONCATENATE lt_007-car31 lv_c1 lt_005-meins INTO lt_007-car31 SEPARATED BY space. "Remove to collect conversion first
                CONCATENATE lv_c1 lt_005-meins INTO lt_007-car31 SEPARATED BY space.
                IF lt_007-car31a IS INITIAL.
                  lt_007-car31a = lt_007-car31.
                ELSE.
                  CONCATENATE lt_007-car31a lt_007-car31 INTO lt_007-car31a SEPARATED BY space. "New logic to collect material conversion first
                ENDIF.
                EXIT.
              ENDIF.
            ENDIF.
          ENDDO.

          CLEAR lt_007-car31.
          CONCATENATE lt_007-vfdat+6(2) '.' lt_007-vfdat+4(2) '.' lt_007-vfdat+0(4) INTO  lt_007-car31. "new line add from line 814
          CONCATENATE lt_007-car31 lt_007-car31a INTO lt_007-car31 SEPARATED BY space.
          "End Add Logic to collect material conversion first
          CONCATENATE 'ED' lt_007-car31 INTO lt_007-car31 SEPARATED BY space.
*          DATA ld_length TYPE i.
*          ld_length = STRLEN( lt_007-car31 ).
*          IF ld_length GE 14.
*            ld_length = ld_length - 14.
*            lt_007-car31a = lt_007-car31+14(ld_length). " remove to new logic at line 844
*          ENDIF.
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
*        IF gt_zsdisce[] IS NOT INITIAL.
*          READ TABLE gt_zsdisce INDEX 1.
*          CLEAR: gs_header-kwert34b,gs_header-kwertc34b,gs_header-kwertcc34b.
*          gs_header-kwert34b = gt_zsdisce-disce.
*          WRITE gs_header-kwert34b TO gs_header-kwertc34b CURRENCY 'IDR'.
*          CONDENSE gs_header-kwertc34b.
*          CONCATENATE 'Disc. E :' gs_header-kwertc34b INTO gs_header-kwertcc34b SEPARATED BY space. "cl_abap_char_utilities=>horizontal_tab.
*          CONDENSE gs_header-kwertcc34b.
*        ENDIF.

        " __* discount F9 (38b)
        gs_header-kwert38 = gs_header-kwert38 + gt_item-discvf9.
        IF gs_header-kwert38 IS NOT INITIAL.
          WRITE gs_header-kwert38 TO gs_header-kwertc38 CURRENCY 'IDR'.
          CONDENSE gs_header-kwertc38.
          CONCATENATE 'Disc. F9 :' gs_header-kwertc38 INTO gs_header-kwertcc38 SEPARATED BY space. "cl_abap_char_utilities=>horizontal_tab.
          CONDENSE gs_header-kwertcc38.
        ENDIF.

        IF lt_lipsh2-uepos IS NOT INITIAL.
          gt_item-posnr = lt_lipsh2-uepos.
        ENDIF.

        gt_item-mtart = lt_lipsh2-mtart.
*        gt_item-mtart = 'ZPHA'.
***        READ TABLE gt_tdg41 WITH KEY profl = lt_lipsh2-profl
***                                     idago = 'X'.
***        IF sy-subrc = 0.
***          gt_item-mtart = 'ZPHA'.
***        ELSE.
***          CLEAR gt_item-mtart.
***        ENDIF.

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
        ELSEIF lt_konv-kschl = 'ZV04'.
          gs_header-zzv04 = gs_header-zzv04 + lt_konv-kwert.
        ENDIF.
      ENDLOOP.

      WRITE gs_header-zzv04 TO gs_header-zzv04t CURRENCY 'IDR'.
      CONDENSE gs_header-zzv04t NO-GAPS.
      REPLACE '-' WITH space INTO gs_header-zzv04t.

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

      "Get ALKES
*      IF gt_lips-mvgr1 = '04'.
*        gs_header-mvgr1 = gt_lips-mvgr1.
*        SELECT SINGLE pakno INTO gs_header-pakno
*          FROM zpbf WHERE vkbur = gt_lips-vkbur.
      IF line_exists( gt_lips[ mvgr1 = '04' ] ).
        IF line_exists( gt_lips[ mvgr1 = '01' ] ).
          gs_header-mvgr1 = '01'.
        ELSE.
          gs_header-mvgr1 = '04'.
          SELECT SINGLE pakno INTO gs_header-pakno
            FROM zpbf WHERE vkbur = gt_lips-vkbur.
        ENDIF.
      ENDIF.

      CLEAR: gs_header-mahdt.
      PERFORM f_modify_mahdt USING likp-vkorg
                                   likp-wadat_ist
                                   likp-kunnr
                                   gt_lips-kvgr3
                                   lt_vbak-vbeln
                                   lt_vbak-abrvw
                                   lt_vbak-auart
                             CHANGING gs_header-mahdt.

    ENDIF. " >> LIPS (items) are available
    " __* Name1-4
    DATA: ls_knvp  TYPE knvp,
          ls_kna1  TYPE kna1,
          ls_vbpa1 TYPE vbpa,
          ls_knvv  TYPE knvv.

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
        SELECT SINGLE * FROM knvv INTO ls_knvv WHERE kunnr = likp-kunnr.
        PERFORM f_alamat_pelanggan USING ls_kna1-adrnr ls_knvv-vkbur.
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
        SELECT SINGLE * FROM knvv INTO ls_knvv WHERE kunnr = likp-kunnr.
        PERFORM f_alamat_pelanggan USING ls_kna1-adrnr ls_knvv-vkbur.
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
    gs_header-vbelnl = likp-vbeln.
    " __* Tanggal
    gs_header-wadat = likp-wadat_ist.
    " __* TOP
    gs_header-top = gs_header-mahdt - gs_header-wadat.
    " __* discount volume (33)
    READ TABLE lt_konv WITH KEY kschl = _kschl_zv01.
    IF sy-subrc = 0.
      gs_header-kbetr33 = lt_konv-kbetr * -1 / 10.
    ENDIF.
    " __* value sum (33)
    DATA: lv_disval LIKE ztax-dis_val.
    CLEAR gs_header-kwert33.
    LOOP AT lt_konv WHERE kschl = _kschl_zv01.
      gs_header-kwert33 = gs_header-kwert33 + lt_konv-kwert * -1.
    ENDLOOP.
    IF gs_header-kbetr33 IS NOT INITIAL OR gs_header-kwert33 IS NOT INITIAL.
      IF nast-kschl = 'ZDE4'.
        CLEAR lv_disval.
        SELECT SINGLE dis_val INTO lv_disval FROM ztax
          WHERE doc_num = gs_header-vbelnl.
        gs_header-kwert33 = gs_header-kwert33 + ( lv_disval / 100 ).
      ENDIF.
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
      IF gv_kschl = 'ZDE4'.
        gs_header-kwertcc33 = 'VOLUME DISC'.
      ENDIF.
      CONDENSE gs_header-kwertcc33.
    ENDIF.

    gs_header-kwert36 = gs_header-kwert36 + gs_header-kwert33.
    WRITE gs_header-kwert36 TO gs_header-kwertc36 CURRENCY 'IDR'.
    CONDENSE gs_header-kwertc36.

    CLEAR lv_char.
    IF gs_header-kbetrzd02 IS NOT INITIAL.
*      lv_char = gs_header-kbetrzd02. CONDENSE lv_char.
*      CONCATENATE lv_char '%' INTO lv_char.
*      CONCATENATE 'CASH DISCOUNT' lv_char INTO gs_header-kbetrzd02t
      CONCATENATE 'CD' lv_char INTO gs_header-kbetrzd02t
      SEPARATED BY space.
      CONDENSE gs_header-kbetrzd02t.
      WRITE gs_header-kwertzd02 TO gs_header-kwertzd02t CURRENCY 'IDR'.
      CONDENSE gs_header-kwertzd02t.
    ENDIF.

    CLEAR lv_char.
    IF gs_header-kbetrzd06 IS NOT INITIAL.
      WRITE gs_header-kwertzd06 TO gs_header-kwertzd06t CURRENCY 'IDR'.
      CONDENSE gs_header-kwertzd06t.
      CONCATENATE 'Disc. D6 :' gs_header-kwertzd06t INTO gs_header-kwertzd06t SEPARATED BY space.
    ENDIF.

    gs_header-totalpage = 1.
    "
    " ---------------------------------------------------------------------------------------------------------------------------------------- #2 $ADD
    gs_header-kwert37 = gs_header-kwert37 - ( gs_header-kwert33 +
                                              gs_header-kwert34a +
                                              gs_header-kwert34b +
                                              gs_header-kwertzd02 +
                                              gs_header-kwertzd06 ).

    "Clear lifex for 8380
    IF gs_header-vkorg = '8380'.
      CLEAR gs_header-lifex.
    ENDIF.

    " cek ssp
    IF gs_header-lifex IS NOT INITIAL.
      ADD gs_header-ssp TO gs_header-kwert37.
    ENDIF.

    IF gs_header-zzv04 IS NOT INITIAL.
      ADD gs_header-zzv04 TO gs_header-kwert37.
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

    "ALKES
    IF gs_header-mvgr1 = '04'.
      SELECT SINGLE object_name user_name no_sk
        INTO (gs_header-object_pbf, gs_header-name_pbf, gs_header-sk_pbf)
        FROM zsign_pja WHERE s_point = gt_lips-vkbur.
*      IF sy-subrc = 0.
*        gs_header-object_pbf = ls_zsign-object_name.
*        gs_header-name_pbf   = ls_zsign-user_name.
*        gs_header-sk_pbf     = ls_zsign-no_sk.
*      ENDIF.
    ENDIF.

  ELSE.
    d_frm_subrc = 1.
  ENDIF. " __* Main SY_SUBRC
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form .
  DATA: BEGIN OF li_status,
          nomor_order_sfa(10),
          nomor_quotation(10),
          tanggal_quotation(10),
          nomor_dn(10),
          tanggal_dn(10),
          nomor_billing(10),
          tanggal_billing(10),
          nomor_shipment(10),
          tanggal_shipment(10),
          amount(15),
          status(1),
          idoc(20),
        END  OF li_status.
  DATA: lv_str      TYPE string, lv_error(1).
  DATA: l_ctr TYPE i.
  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.
*  perform f_test_next_page.
  IF d_frm_subrc IS INITIAL.
    d_output_opt-tddelete = 'X'.
    IF gv_noprnt IS NOT INITIAL.
      d_output_opt-tdnoprint = 'X'.
    ENDIF.
    DATA: usergroups LIKE usgroups OCCURS 0 WITH HEADER LINE.
    CALL FUNCTION 'SUSR_USER_GROUP_GROUPS_GET'
      EXPORTING
        bname      = sy-uname
      TABLES
        usergroups = usergroups.
    IF sy-subrc = 0.
      READ TABLE usergroups WITH KEY usergroup = 'ZHO'.
      IF sy-subrc = 0.
        CLEAR d_output_opt-tddelete.
      ENDIF.
    ENDIF.
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

**** Tambahan Proses untuk mengirimkan order status ke TiMOS dengan menggunakan API
***  Tanggal: 07 Jan 2021
***   By SUK

*****    CLEAR: li_status,  lv_str.
*****    CONDENSE: gs_header-submi, gs_header-vbelna, gs_header-vbelnl.
*****    li_status-nomor_order_sfa = gs_header-submi.
*****    li_status-nomor_quotation = gs_header-vbelna.
*****    li_status-tanggal_quotation = gs_header-erdat.
*****    li_status-nomor_dn = gs_header-vbelnl. "vbelnl.
*****    li_status-tanggal_dn = gs_header-wadat.
*****    li_status-status = 'S'.
*****    IF gs_header-submi IS NOT INITIAL.
*****      PERFORM f_send_order_status(zsfa_i0001) USING li_status
*****                                gs_header-vkorg gs_header-vkbur
*****                             CHANGING sy-subrc  lv_str .
*****    ENDIF.
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
FORM       f_def_page .
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
    LOOP AT gt_detail WHERE matnr = gt_item-matnr AND uecha = gt_item-posnr.
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
FORM f_alamat_pelanggan  USING    fu_adrnr fu_vkbur.
  DATA ls_adrc  TYPE adrc.

  DATA : d_datab LIKE zproject-datab,
         d_flag  LIKE zproject-flag.

  DATA : lv_werks LIKE zplbc-werks,
         lv_live  LIKE zplbc-live,
         lv_adrnr LIKE tvbur-adrnr.

  DATA : ls_zscust_control LIKE zscust_control.

  CLEAR : d_datab, d_flag.

*  IF likp-vkorg = '8380'.
  SELECT SINGLE * INTO ls_zscust_control
    FROM zscust_control WHERE vkorg = likp-vkorg
                          AND cek = 'ADR'
                          AND field_name = 'PARVW'.
  IF sy-subrc = 0.
    SELECT SINGLE adrnr INTO fu_adrnr
      FROM vbpa WHERE vbeln = likp-vbeln
                  AND parvw = ls_zscust_control-field_value
                  AND xcpdk = 'X'.
  ENDIF.
*  ENDIF.

  SELECT SINGLE * FROM adrc INTO ls_adrc WHERE addrnumber = fu_adrnr.
  gs_header-name_co = ls_adrc-name_co.
  gs_header-str_suppl1 = ls_adrc-str_suppl1.
  gs_header-str_suppl2 = ls_adrc-str_suppl2.
  gs_header-str_suppl3 = ls_adrc-str_suppl3.
*  gs_header-street1    = ls_adrc-street.
  gs_header-name1      = ls_adrc-name1.
  gs_header-name2      = ls_adrc-name2.
  gs_header-name3      = ls_adrc-name3.
  gs_header-sort2      = ls_adrc-sort2.

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

*Logika 2 Project 16/07/2018
  lv_werks = gs_header-sort2.
  SELECT SINGLE vkbur
    FROM tvbur
    INTO lv_werks
    WHERE vkbur = lv_werks.
  IF sy-subrc <> 0.
    lv_werks  = fu_vkbur.
  ENDIF.

  IF lv_werks IS NOT INITIAL.
    SELECT SINGLE live INTO lv_live FROM zplbc
    WHERE bukrs = likp-vkorg
    AND   werks = lv_werks.
    IF sy-subrc = 0.
      IF lv_live <> 'X'.
        gs_header-legacy = 'X'.
      ENDIF.
    ELSE.
      gs_header-legacy = 'X'.
    ENDIF.

    IF gs_header-legacy = 'X'.
      CLEAR : gs_header-accbank1, gs_header-accbank2, gs_header-accbank3,
              gs_header-accbank4, gs_header-accbank5.
      PERFORM f_get_account_bank USING likp-vkorg lv_werks.
    ENDIF.

* Get Telp. No
    CLEAR lv_adrnr.
    SELECT SINGLE adrnr INTO lv_adrnr
      FROM tvbur WHERE vkbur = lv_werks.
    IF sy-subrc = 0.
      SELECT SINGLE tel_number INTO gs_header-tel_number2
        FROM adr2 WHERE addrnumber = lv_adrnr
                    AND r3_user = '3'.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_ALAMAT_PELANGGAN

*&---------------------------------------------------------------------*
*&      Form  F_NEW_DELIVERY_NOTE
*&---------------------------------------------------------------------*
FORM f_new_delivery_note .
  DATA : lwa_item   LIKE gt_item,
         lv_count   TYPE i,
         lv_nou     TYPE i,
         lv_matnr   TYPE matnr,
         lv_arktx   TYPE arktx,
         lv_discv   TYPE kbetr,
         lv_discvf2 TYPE kbetr,
         lv_total   TYPE wertv9,
         lv_nsp     TYPE wertv9,
         lv_total1  TYPE kzwi5,
         lv_name    TYPE tdobname,
         lt_lines   LIKE tline OCCURS 0 WITH HEADER LINE,
         lv_flag    TYPE i,
         lv_sign(1),
         lv_zeile   TYPE mblpo,
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

  DATA : lv_dmbtr  TYPE dmbtr,
         lv_dmbtr1 TYPE dmbtr,
         lv_udate  TYPE sy-datum,
         lv_utime  TYPE sy-uzeit.

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

  PERFORM f_gi_date_time  USING p_vbeln
                          CHANGING lv_udate lv_utime.

*  PERFORM f_a511 USING gs_header-kunnr likp-wadat_ist lv_utime
*                 CHANGING gs_header-maxdate.

  PERFORM f_a511 USING gs_header-kunnr likp-erdat lv_utime
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
    LOOP AT gt_detail WHERE matnr EQ lwa_item-matnr
                        AND uecha EQ lwa_item-posnr.
      ADD 1 TO lv_count.
      ADD 1 TO lv_nou.
      gt_new-nou       = lv_nou.
      gt_new-posnr     = lwa_item-posnr.
      gt_new-matnr     = lwa_item-matnr.
      gt_new-arktx     = lwa_item-arktx.
      gt_new-kwert     = lwa_item-kwert.
      gt_new-kwertc25  = lwa_item-kwertc25.
      gt_new-mtart     = lwa_item-mtart.

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
      IF gv_kschl = 'ZDE5' OR gv_kschl = 'ZDE7' OR gv_kschl = 'ZDE8'.
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
      IF gt_new-cdisca NE '0'.
        IF gv_kschl NE 'ZDE7' AND gv_kschl NE 'ZDE8'.
          ADD 1 TO gs_header-total_lines.
        ENDIF.
      ENDIF.
      ADD 1 TO gs_header-total_lines.

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
      IF gv_kschl = 'ZDE5' OR gv_kschl = 'ZDE7' OR gv_kschl = 'ZDE8'.
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
***** Kenapa ini harus add 2 to gs_header-total_lines
** Perlu dicari tahu... kalau ada kasus cetak form
** Command ad by sukardi 17.04.2018
** efek dari perubahan etak form dengan output type "ZDE4"
      ADD 2 TO gs_header-total_lines.

      APPEND gt_new.
    ENDIF.
    CLEAR : gt_new, lv_count, lv_discv, lv_discvf2.
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

  CLEAR : lt_lines[], lt_lines.
  lv_name = gs_header-kunnr.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = '0017'
      language                = sy-langu
      name                    = lv_name
      object                  = 'KNA1'
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

  IF gv_kschl EQ 'ZDE4' OR
    gv_kschl EQ 'ZDE5' OR
    gv_kschl EQ 'ZDE6' OR
    gv_kschl EQ 'ZDE7' OR
    gv_kschl EQ 'ZDE8' OR
    gv_kschl EQ 'ZDE9'.
    READ TABLE lt_lines INDEX 1.
    IF sy-subrc = 0.
      gs_header-tdline  = lt_lines-tdline.
      lv_length = strlen( gs_header-tdline ).
      IF lv_length GE 23.
        gv_style1  = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.

  lv_length = strlen( gs_header-name_co ).
  IF lv_length GE 23.
    gv_style1  = 'X'.

  ENDIF.

  lv_length = strlen( gs_header-name2 ).
  IF lv_length <= 23.
    gv_style2  = 'X'.
  ENDIF.

  lv_length = strlen( gs_header-str_suppl1 ).
  IF lv_length <= 23.
    gv_style3  = 'X'.
  ENDIF.

  lv_length = strlen( gs_header-str_suppl2 ).
  IF lv_length <= 23.
    gv_style5  = 'X'.
  ENDIF.

  lv_length = strlen( gs_header-str_suppl3 ).
  IF lv_length <= 23.
    gv_style6  = 'X'.
  ENDIF.

  CASE gv_kschl.
    WHEN 'ZDE5' OR 'ZDE7' OR 'ZDE8'.
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

    WHEN 'ZST7'.
* New calculation Qty, Harga Satuan & Harga for Batam
      SELECT vbelv posnv vbeln posnn vbtyp_n erdat bwart
        FROM vbfa
        INTO TABLE lt_vbfa
        WHERE vbelv   = p_vbeln
          AND vbtyp_n = 'R'
          AND bwart <> space.

      CHECK lt_vbfa[] IS NOT INITIAL.

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

      CLEAR : gs_header-kwert36, gs_header-kwert37, gs_header-kwert33,
              gs_header-kwertc33, gs_header-kwertcc33.

      BREAK bcdik.

      LOOP AT gt_new.
        CLEAR : lv_zeile, lv_subrc.
*        READ TABLE lt_vbfa WITH KEY posnr = gt_new-posnr
*                                    charg = gt_new-charg.
*        IF sy-subrc = 0.
*          lv_zeile  = lt_vbfa-zeile.
*        ENDIF.

* Same batch on batch split
        CLEAR : lv_kwert, lv_kwert1, lv_dmbtr1.
        LOOP AT lt_vbfa WHERE posnr = gt_new-posnr
                          AND charg = gt_new-charg.

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
FORM f_a511  USING    fu_kunnr fu_udate fu_utime
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

  DATA : lv_bzirk  TYPE bzirk,
         lv_kdgrp  TYPE kdgrp,
         lv_vkbur  TYPE vkbur,
         lv_katr1  TYPE katr1,
         lv_times  TYPE i,
         lv_subrc  TYPE sy-subrc,
         lv_datum  TYPE sy-datum,
         lv_uzeit  TYPE sy-uzeit,
         lv_second TYPE p DECIMALS 0.

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

  IF lv_bzirk = 'SLK1'.
    lv_times  = lv_times.
    lv_second = 86400.
    DO lv_times TIMES.
      CALL FUNCTION 'C14Z_CALC_DATE_TIME'
        EXPORTING
          i_add_seconds = lv_second
          i_uzeit       = fu_utime
          i_datum       = fu_udate
        IMPORTING
          e_datum       = lv_datum
          e_uzeit       = lv_uzeit.

      CLEAR lv_subrc.
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
          fu_udate  = lv_datum.
          fu_utime  = lv_uzeit.
        ENDIF.
      ENDWHILE.
    ENDDO.
  ELSE.
    lv_second = 86400 * ( lv_times + 1 ).

    CALL FUNCTION 'C14Z_CALC_DATE_TIME'
      EXPORTING
        i_add_seconds = lv_second
        i_uzeit       = fu_utime
        i_datum       = fu_udate
      IMPORTING
        e_datum       = lv_datum
        e_uzeit       = lv_uzeit.

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
  ENDIF.

**  DO lv_times TIMES.
**    CLEAR lv_subrc.
**    lv_datum  = lv_datum + 1.
**    WHILE lv_subrc IS INITIAL.
**      CLEAR : holidays, holidays[].
**      CALL FUNCTION 'HOLIDAY_GET'
**        EXPORTING
**          holiday_calendar           = 'T1'
**          factory_calendar           = 'T1'
**          date_from                  = lv_datum
**          date_to                    = lv_datum
**        TABLES
**          holidays                   = holidays
**        EXCEPTIONS
**          factory_calendar_not_found = 1
**          holiday_calendar_not_found = 2
**          date_has_invalid_format    = 3
**          date_inconsistency         = 4
**          OTHERS                     = 5.
**
**      lv_subrc  = sy-subrc.
**      IF holidays[] IS NOT INITIAL.
**        lv_datum  = lv_datum + 1.
**      ELSE.
**        lv_subrc  = 4.
**      ENDIF.
**    ENDWHILE.
**  ENDDO.

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

  SELECT * INTO TABLE lt_accbank
    FROM zsaccbank
    WHERE vkorg = fu_vkorg AND
          vkbur = fu_vkbur.
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
    WHEN 'ZDE4' OR 'ZDE5' OR 'ZDE6' OR 'ZST4' OR 'ZDE7' OR 'ZDE8'.
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
  DATA: ls_zproject TYPE zproject.

  IF gv_kschl = 'ZDE6'.
    fc_value = fc_value * ( 10 / 11 ).

** Project PPN 11% - begin
    SELECT SINGLE * INTO ls_zproject
      FROM zproject WHERE name = 'PPN11'
                      AND flag = 'X'.
    IF sy-subrc = 0 AND likp-wadat_ist GE ls_zproject-datab.
      CLEAR fc_value.
      fc_value = fc_value * ( ls_zproject-char1 / ls_zproject-char2 ).
    ENDIF.
** Project PPN 11% - end

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
*    CASE gt_new-kschl.
*    	WHEN '.
*    	WHEN .
*    	WHEN OTHERS.
*    ENDCASE.
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
*        READ TABLE gt_lips WITH KEY matnr = gt_new-matnr
*                                    posnr = gt_new-posnr.
*        IF sy-subrc = 0.
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
*        ELSE.
*          lv_total = ( gt_new-lfimg * gt_new-kwert ).
*          WRITE lv_total TO gt_new-total CURRENCY 'IDR'.
*          CONDENSE gt_new-total NO-GAPS.
*          MODIFY gt_new TRANSPORTING total.
*        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.




*    IF gt_new-cdisca IS NOT INITIAL.
*      CLEAR lwa_lips.
*      READ TABLE gt_lips INTO lwa_lips WITH KEY pstyv = 'TAN'
*                                                uepos = gt_new-posnr.
*      IF sy-subrc = 0.
*        CLEAR lwa_lips1.
*        READ TABLE gt_lips INTO lwa_lips1 WITH KEY posnr = lwa_lips-uepos.
*        IF lwa_lips1-matnr = gt_new-matnr.
*          PERFORM f_modify_kwert USING    gt_new-kwertc25
*                                 CHANGING gt_new-kwert.
*          CLEAR : lwa_lips2, lv_lfimg.
*          LOOP AT gt_lips INTO lwa_lips2 WHERE uecha = lwa_lips-posnr
*                                           AND matnr = lwa_lips-matnr.
*            ADD lwa_lips2-lfimg TO lv_lfimg.
*          ENDLOOP.
*          IF lv_lfimg = 0.
*            gt_new-zdisc1 = gt_new-kwert * lwa_lips-lfimg.
*            lv_total      = gt_new-kwert * gt_new-lfimg - gt_new-zdisc1.
*          ELSE.
*            gt_new-zdisc1 = gt_new-kwert * lv_lfimg.
*            lv_total      = gt_new-kwert * gt_new-lfimg - gt_new-zdisc1.
*          ENDIF.
*          WRITE gt_new-zdisc1 TO gt_new-cdisca CURRENCY 'IDR'.
*          CONDENSE gt_new-cdisca NO-GAPS.
*          WRITE lv_total TO gt_new-total CURRENCY 'IDR'.
*          CONDENSE gt_new-total NO-GAPS.
*          MODIFY gt_new TRANSPORTING cdisca total.
*        ELSE.
*          WRITE gt_new-kwert TO gt_new-kwertc25 CURRENCY 'IDR'.
*          CONDENSE gt_new-kwertc25 NO-GAPS.
*          lv_total = ( gt_new-lfimg * gt_new-kwert ) - gt_new-zdisc1.
*          WRITE lv_total TO gt_new-total CURRENCY 'IDR'.
*          CONDENSE gt_new-total NO-GAPS.
*          MODIFY gt_new TRANSPORTING kwertc25 total.
*        ENDIF.
*      ELSE.
**        IF gt_new-cdisca IS NOT INITIAL.
**          CLEAR gt_new-cdisca.
**          MODIFY gt_new TRANSPORTING cdisca.
**        ENDIF.
*      ENDIF.
*    ELSE.
*    ENDIF.
*  ENDLOOP.
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
  LOOP AT ft_lipsx WHERE matnr = ft_lipsh2-matnr
                     AND ( posnr = ft_lipsh2-posnr
                      OR   uecha = ft_lipsh2-posnr
                      OR   uepos = ft_lipsh2-posnr ).
    IF ft_lipsx-charg IS NOT INITIAL.
      IF ft_lipsx-uecha = ft_lipsh2-posnr OR ft_lipsx-uepos = ft_lipsh2-posnr OR ft_lipsx-uecha IS INITIAL.
        " __* TO-DOs
        READ TABLE ft_007 WITH KEY charg = ft_lipsx-charg.
        IF sy-subrc = 0.
          ft_007-lfimg = ft_007-lfimg + ft_lipsx-lfimg.
          MODIFY ft_007 INDEX sy-tabix TRANSPORTING lfimg.
        ELSE.
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
          READ TABLE ft_007 WITH KEY matnr = ft_lipsx-matnr
                                     uecha = ft_lipsx-posnr.
        ELSE.
          READ TABLE ft_007 WITH KEY matnr = ft_lipsx-matnr
                                     uecha = ft_lipsx-uepos.
        ENDIF.
        IF sy-subrc = 0.
          ft_007-lfimg = ft_007-lfimg + ft_lipsx-lfimg.
          MODIFY ft_007 INDEX sy-tabix TRANSPORTING lfimg.
        ELSE.
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
  LOOP AT ft_lipsh WHERE matnr = ft_lipsh2-matnr. " AND uecha = ft_lipsh2-posnr.
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
  SELECT vbelv posnv vbeln posnn vbtyp_n erdat bwart
    FROM vbfa
    INTO TABLE ft_vbfa
    WHERE vbelv   = p_vbeln
      AND vbtyp_n = 'h'
      AND bwart <> space.
  IF sy-subrc = 0.
    SELECT mblnr smbln
      FROM mseg
      INTO TABLE ft_mseg
      FOR ALL ENTRIES IN ft_vbfa
      WHERE mblnr = ft_vbfa-vbeln
        AND xauto = space.
  ENDIF.
ENDFORM.                    " F_CEK_CANCEL_GI

*&---------------------------------------------------------------------*
*&      Form  F_GI_DATE_TIME
*&---------------------------------------------------------------------*
FORM f_gi_date_time  USING    fu_vbeln
                     CHANGING fc_udate fc_utime.

  DATA : lv_objectid TYPE cdpos-objectid,
         lv_changenr TYPE cdpos-changenr.

  lv_objectid = fu_vbeln.

  SELECT SINGLE changenr
    FROM cdpos
    INTO lv_changenr
      WHERE objectclas = 'LIEFERUNG'
        AND objectid   = lv_objectid
        AND tabname    = 'VBUK'
        AND fname      = 'WBSTK'
        AND value_new  = 'C'.
  IF sy-subrc = 0.
    SELECT SINGLE udate utime
      FROM cdhdr
      INTO (fc_udate, fc_utime)
       WHERE objectclas = 'LIEFERUNG'
         AND objectid   = lv_objectid
         AND changenr   = lv_changenr.
  ENDIF.
ENDFORM.                    " F_GI_DATE_TIME

*&---------------------------------------------------------------------*
*&      Form  F_DISCA
*&---------------------------------------------------------------------*
FORM f_disca  TABLES   ft_konv STRUCTURE konv
              USING    fu_kposn fu_knumv
              CHANGING fc_subrc fc_discva.

  DATA : lv_kwert  TYPE konv-kwert.
  DATA : ls_konv   LIKE konv.

  LOOP AT ft_konv WHERE kposn = fu_kposn
                    AND knumv = fu_knumv.
    IF ft_konv-kschl = _kschl_za01 OR
      ft_konv-kschl = _kschl_za02 OR
      ft_konv-kschl = _kschl_zd11.
      ADD ft_konv-kwert TO lv_kwert.

      IF ft_konv-kschl = _kschl_za01.
        READ TABLE ft_konv INTO ls_konv WITH KEY knumv = fu_knumv
                                                 kposn = fu_kposn
                                                 kschl = _kschl_zdd3.
        ADD ls_konv-kwert TO lv_kwert.
      ENDIF.

      CLEAR fc_subrc.
    ENDIF.
  ENDLOOP.
  gt_item-discva = gt_item-discva + lv_kwert * -1.
ENDFORM.                    " F_DISCA

*&---------------------------------------------------------------------*
*&      Form  F_IE_MATNR
*&---------------------------------------------------------------------*
FORM f_ie_matnr USING fu_vkorg.
  DATA : lt_control TYPE STANDARD TABLE OF zscust_control,
         ls_control LIKE LINE OF lt_control,
         lr_matnr   TYPE RANGE OF matnr,
         ls_matnr   LIKE LINE OF lr_matnr.

  SELECT *
    FROM zscust_control
    INTO CORRESPONDING FIELDS OF TABLE lt_control
    WHERE vkorg       = fu_vkorg
*      AND cek         = 'MSK'
      AND cek         IN ('MSK','HMV')
      AND field_name  = 'MATNR'.

  IF sy-subrc = 0.
    SORT lt_control BY field_value2.
    DELETE ADJACENT DUPLICATES FROM lt_control COMPARING field_value2.
    LOOP AT lt_control INTO ls_control.
      ls_matnr-low    = ls_control-field_value2.
      IF gv_kschl = 'ZTT1'.
        ls_matnr-sign   = 'E'.
      ELSE.
        ls_matnr-sign   = 'I'.
      ENDIF.
      ls_matnr-option = 'EQ'.
      APPEND ls_matnr TO lr_matnr.
      CLEAR ls_matnr.
    ENDLOOP.

    LOOP AT gt_lips.
      IF gt_lips-matnr IN lr_matnr.
        DELETE gt_lips.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_IE_MATNR

*&---------------------------------------------------------------------*
*&      Form  F_CALC_ZV04
*&---------------------------------------------------------------------*
FORM f_calc_zv04 .

ENDFORM.                    " F_CALC_ZV04

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_MAHDT
*&---------------------------------------------------------------------*
FORM f_modify_mahdt  USING    fu_vkorg
                              fu_wadat_ist
                              fu_kunnr
                              fu_kvgr3
                              fu_vbeln
                              fu_abrvw
                              fu_auart
                     CHANGING fc_mahdt.
  DATA: ls_zftop  TYPE zftop,
        ls_zftop2 TYPE zftop2,
        lv_zterm  TYPE vbkd-zterm.

  DATA : ls_control   TYPE zscust_control.

  SELECT SINGLE zterm INTO lv_zterm
    FROM vbkd WHERE vbeln = fu_vbeln.

  CASE fu_vkorg.
    WHEN '8020'.
      SELECT SINGLE * INTO ls_zftop
        FROM zftop WHERE bukrs = fu_vkorg
                     AND kvgr3 = fu_kvgr3.

      IF sy-subrc = 0 AND ls_zftop-topstd IS NOT INITIAL.
        "Do nothing
      ELSE.
        ls_zftop-topstd = '14'.
      ENDIF.

      IF lv_zterm = 'ZT00' OR fu_abrvw = 'E'  OR fu_abrvw = 'C'.
        CLEAR ls_zftop-topstd.
      ENDIF.

      fc_mahdt = fu_wadat_ist + ls_zftop-topstd.

    WHEN '8070'.
      SELECT SINGLE * INTO ls_zftop2
        FROM zftop2 WHERE bukrs = fu_vkorg
                      AND auart = fu_auart.

      IF sy-subrc = 0 AND ls_zftop2-topstd IS NOT INITIAL.
        "Do nothing
      ELSE.
        ls_zftop2-topstd = '14'.
      ENDIF.

      IF lv_zterm = 'ZT00' OR fu_abrvw = 'E'  OR fu_abrvw = 'C'.
        CLEAR ls_zftop2-topstd.
      ENDIF.

      fc_mahdt = fu_wadat_ist + ls_zftop2-topstd.
  ENDCASE.

  SELECT SINGLE *
    FROM zscust_control
    INTO CORRESPONDING FIELDS OF ls_control
    WHERE vkorg        = fu_vkorg
      AND cek          = 'TOP'
      AND field_name   = 'KUNNR'
      AND field_value  = fu_kunnr.
  IF sy-subrc = 0.
    fc_mahdt = fu_wadat_ist + ls_control-field_value2.
  ENDIF.
ENDFORM.                    " F_MODIFY_MAHDT

*&---------------------------------------------------------------------*
*&      Form  F_RECALC_GT_LIPS
*&---------------------------------------------------------------------*
FORM f_recalc_gt_lips .
  DATA: lt_lips1 TYPE TABLE OF lips WITH HEADER LINE,
        lt_lips2 TYPE TABLE OF lips WITH HEADER LINE,
        lv_lvstk LIKE vbuk-lvstk.

  IF gv_kschl = 'ZDE4'.
    SELECT SINGLE lvstk INTO lv_lvstk
      FROM vbuk WHERE vbeln = p_vbeln.

    IF lv_lvstk IS NOT INITIAL.    "WM
      lt_lips1[] = lt_lips2[] = gt_lips[].
      CLEAR: gt_lips,gt_lips[].

      SORT: lt_lips1 BY vgbel vgpos vbeln posnr,
            lt_lips2 BY vgbel vgpos vbeln posnr.
      DELETE ADJACENT DUPLICATES FROM lt_lips1
        COMPARING vgbel vgpos.

      LOOP AT lt_lips1.
        LOOP AT lt_lips2 WHERE vgbel = lt_lips1-vgbel
                           AND vgpos = lt_lips1-vgpos.
          IF lt_lips2-posnr = lt_lips1-posnr.
            MOVE-CORRESPONDING lt_lips2 TO gt_lips.
          ELSE.
            gt_lips-lfimg = lt_lips2-lfimg.
            gt_lips-brgew = lt_lips2-brgew.
            gt_lips-volum = lt_lips2-volum.
            gt_lips-lgmng = lt_lips2-lgmng.
            gt_lips-ormng = lt_lips2-ormng.
          ENDIF.
          COLLECT gt_lips.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_RECALC_GT_LIPS

*&---------------------------------------------------------------------*
*&      Form  F_GET_TOP
*&---------------------------------------------------------------------*
FORM f_get_top .
  DATA : ls_control   TYPE zscust_control.

  IF gs_header-vkorg = '8380' AND
    gs_header-lfart(3) = 'ZTS'.
    SELECT SINGLE *
      FROM zscust_control
      INTO CORRESPONDING FIELDS OF ls_control
      WHERE vkorg        = gs_header-vkorg
        AND cek          = 'JTT'
        AND field_name   = 'KUNNR'
        AND field_value  = gs_header-kunnr.
    IF sy-subrc = 0.
      gs_header-top  = ls_control-field_value2.
    ELSE.
      SELECT SINGLE *
        FROM zscust_control
        INTO CORRESPONDING FIELDS OF ls_control
        WHERE vkorg        = gs_header-vkorg
          AND cek          = 'JTT'
          AND field_name   = 'VKGRP'
          AND field_value  = 'ER'.
      IF sy-subrc = 0.
        gs_header-top  = ls_control-field_value2.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_TOP

*&---------------------------------------------------------------------*
*&      Form  F_GET_NO_SERTIFIKASI
*&---------------------------------------------------------------------*
FORM f_get_no_sertifikasi .
  DATA : lv_str01    TYPE zstr01,
         lv_str02    TYPE zstr02,
         lv_ed01(25),
         lv_ed02(25).

  SELECT SINGLE str01 str02 ed01 ed02
    INTO (lv_str01,lv_str02,lv_ed01,lv_ed02)
    FROM zsd_sertifikasi WHERE vkbur = gt_lips-vkbur
                           AND objtyp = 'CDOB'.

  CONCATENATE 'OL:' lv_str01 INTO gs_header-nosert1.
  IF lv_ed01 IS NOT INITIAL.
    CONCATENATE gs_header-nosert1 lv_ed01 INTO gs_header-nosert1
    SEPARATED BY space.
  ENDIF.
  CONCATENATE 'CCP:' lv_str02 INTO gs_header-nosert2.
  IF lv_ed02 IS NOT INITIAL.
    CONCATENATE gs_header-nosert2 lv_ed02 INTO gs_header-nosert2
    SEPARATED BY space.
  ENDIF.
ENDFORM.                    " F_GET_NO_SERTIFIKASI

*&---------------------------------------------------------------------*
*&      Form  F_COLD_CHAIN
*&---------------------------------------------------------------------*
FORM f_cold_chain .
*  TYPES : BEGIN OF ty_mara,
*            matnr TYPE mara-matnr,
*            profl TYPE mara-profl,
*          END OF ty_mara.
*  DATA : lt_mara    TYPE STANDARD TABLE OF ty_mara.
*
*  IF gt_lips[] IS NOT INITIAL.
*    SELECT matnr profl
*      FROM mara
*      INTO TABLE lt_mara
*      FOR ALL ENTRIES IN gt_lips
*      WHERE matnr = gt_lips-matnr
*        AND profl = 'RCC'.
*    IF lt_mara[] IS NOT INITIAL.
*      gs_header-cold = 'X'.
*    ENDIF.
*  ENDIF.
ENDFORM.                    " F_COLD_CHAIN

*&---------------------------------------------------------------------*
*&      Form  F_TEMPOINDONESIA
*&---------------------------------------------------------------------*
FORM f_tempoindonesia .
  DATA : lv_subrc TYPE sy-subrc,
         lv_mvgr1 TYPE lips-mvgr1.

  CLEAR lv_subrc.
  LOOP AT gt_lips.
    IF gt_lips-mvgr1 = '00' OR
      gt_lips-mvgr1 = '01'.
      lv_mvgr1 = gt_lips-mvgr1.
    ELSE.
      lv_subrc = 4.
    ENDIF.
  ENDLOOP.

  IF lv_subrc = 0.
    gs_header-mvgr1 = lv_mvgr1.
  ENDIF.
ENDFORM.                    " F_TEMPOINDONESIA
