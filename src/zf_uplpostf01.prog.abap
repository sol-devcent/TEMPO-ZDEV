*----------------------------------------------------------------------*
*   INCLUDE ZF_UPLPOSTF01
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE 'X'.
    WHEN radio1.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'DAT'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio2.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'FLN' OR 'BUK' OR 'DAT'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio3.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'FLN'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  CASE 'X'.
    WHEN radio1.
      IF pa_bukrs IS INITIAL.
        PERFORM f_error_selection_screen USING 'BUK' ''.
      ENDIF.
      IF filename IS INITIAL.
        PERFORM f_error_selection_screen USING 'FLN' ''.
      ENDIF.
    WHEN radio2.
    WHEN radio3.
      IF pa_bukrs IS INITIAL.
        PERFORM f_error_selection_screen USING 'BUK' ''.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000


*&---------------------------------------------------------------------*
*&      Form  F_FILENAME_F4
*&---------------------------------------------------------------------*
FORM f_filename_f4  CHANGING fc_filename.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = sy-cprog
      dynpro_number = '1000'
    IMPORTING
      file_name     = fc_filename.
ENDFORM.                    " F_FILENAME_F4

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  DATA : lr_setname TYPE RANGE OF setname,
         lr_line    LIKE LINE OF lr_setname.

  DATA : BEGIN OF lt_setleaf OCCURS 0,
           valsign   TYPE raldb_sign,
           valoption TYPE raldb_opti,
           valfrom   TYPE setvalmin,
           valto     TYPE setvalmax,
         END OF lt_setleaf.

  lr_line-low     = 'FI010'.
  lr_line-high    = 'FI090'.
  lr_line-sign    = 'I'.
  lr_line-option  = 'BT'.
  APPEND lr_line TO lr_setname.

**Get user defaults
  CLEAR: gt_user, gt_user[].
  gt_user-bname = sy-uname.
  APPEND gt_user.
  CALL FUNCTION 'SUSR_GET_USER_DEFAULTS'
    EXPORTING
      langu = sy-langu
    TABLES
      users = gt_user.

  SELECT bschl shkzg koart
    FROM tbsl
    INTO TABLE gt_tbsl.

  CASE pa_bukrs.
    WHEN '8020' OR '8070' OR '8010' OR '8380' OR '8180'. "OR '8210' OR '8390' OR '8040'.
      gv_copa = 'X'.
  ENDCASE.

  SELECT valsign valoption valfrom valto
    FROM setleaf
    INTO TABLE lt_setleaf
    WHERE setclass EQ '0102'
      AND subclass EQ 'TSPC'
      AND setname  IN lr_setname.

  LOOP AT lt_setleaf.
    gr_line-low     = lt_setleaf-valfrom.
    gr_line-high    = lt_setleaf-valto.
    gr_line-sign    = lt_setleaf-valsign.
    gr_line-option  = lt_setleaf-valoption.
    APPEND gr_line TO gr_hkont.
  ENDLOOP.

  IF pa_bukrs = '8380'.
    gr_line-low     = '0841320030'.
    gr_line-high    = '0841320030'.
    gr_line-sign    = 'I'.
    gr_line-option  = 'BT'.
    APPEND gr_line TO gr_hkont.
  ENDIF.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA_UPLOAD
*---------------------------------------------------------------------*
FORM f_get_data_upload CHANGING fc_error.
  DATA: lv_buzei TYPE buzei,
        lv_waers TYPE waers,
        lv_kursf TYPE kursf,
        lv_koart TYPE koart.

  DATA: lt_excel LIKE gt_excel OCCURS 0 WITH HEADER LINE,
        lt_ska1  LIKE gt_ska1 OCCURS 0 WITH HEADER LINE.

  CLEAR: gt_excel, gt_excel[].
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = filename
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 75
      i_end_row               = 65000
    TABLES
      intern                  = gt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SORT gt_excel BY row col.

  lt_excel[]  = gt_excel[].

  LOOP AT gt_excel.
    CASE gt_excel-row.
      WHEN '0001'.
        IF gt_excel-col EQ '0002'.
          PERFORM f_date_modify USING gt_excel-value
                                CHANGING gt_header-bldat.
          gv_bldat  = gt_header-bldat.
        ELSEIF gt_excel-col EQ '0004'.
          gt_header-blart   = gt_excel-value.
        ENDIF.
      WHEN '0002'.
        IF gt_excel-col EQ '0002'.
          PERFORM f_date_modify USING gt_excel-value
                                CHANGING gt_header-budat.
          gv_budat  = gt_header-budat.
        ELSEIF gt_excel-col EQ '0004'.
          gt_header-bukrs  = gt_excel-value.
          IF gt_header-bukrs NE pa_bukrs.
            fc_error  = 1.
            EXIT.
          ENDIF.
        ENDIF.
      WHEN '0003'.
        IF gt_excel-col EQ '0002'.
          gt_header-xblnr = gt_excel-value.
          gv_xblnr        = gt_header-xblnr.
        ELSEIF gt_excel-col EQ '0004'.
          lv_waers  = gt_excel-value.
        ELSEIF gt_excel-col EQ '0005'.
          PERFORM f_kursf_modify USING gt_excel-value
                                 CHANGING lv_kursf.
        ENDIF.
      WHEN '0004'.
        IF gt_excel-col EQ '0002'.
          gt_header-bktxt = gt_excel-value.
          APPEND gt_header.
        ENDIF.
      WHEN '0001' OR '0006' OR '0007'.
        CONTINUE.
      WHEN OTHERS.
        CASE gt_excel-col.
          WHEN '0001'.
            CLEAR lv_koart.
            gt_detail-newbs  = gt_excel-value.
            READ TABLE gt_tbsl WITH KEY bschl = gt_detail-newbs.
            IF sy-subrc EQ 0.
              lv_koart  = gt_tbsl-koart.
            ENDIF.
          WHEN '0002'.
            IF gt_excel-value(1) = 'Z'.
              PERFORM f_modify_value USING gt_excel-value 'Z' ''
                                     CHANGING gt_detail-newko.
            ELSE.
              PERFORM f_modify_value USING gt_excel-value lv_koart ''
                                     CHANGING gt_detail-newko.
            ENDIF.
          WHEN '0003'.
            gt_detail-newum  = gt_excel-value.
          WHEN '0004'.
            gt_detail-newbw  = gt_excel-value.
          WHEN '0005'.
            PERFORM f_amount_modify USING gt_excel-value lv_waers ''
                                    CHANGING gt_detail-dmbtr.
          WHEN '0006'.
            gt_detail-mwskz  = gt_excel-value.
          WHEN '0007'.
            gt_detail-gsber  = gt_excel-value.
          WHEN '0008'.
            gt_detail-vbund  = gt_excel-value.
          WHEN '0009'.
            PERFORM f_modify_value USING gt_excel-value lv_koart '1'
                                   CHANGING gt_detail-kostl.
          WHEN '0010'.
            gt_detail-aufnr  = gt_excel-value.
          WHEN '0011'.
            gt_detail-prctr  = gt_excel-value.
          WHEN '0012'.
            gt_detail-werks  = gt_excel-value.
          WHEN '0013'.
            gt_detail-sgtxt  = gt_excel-value.
          WHEN '0014'.
            gt_detail-vkorg  = gt_excel-value.
          WHEN '0015'.
            gt_detail-vtweg  = gt_excel-value.
          WHEN '0016'.
            gt_detail-vkbur  = gt_excel-value.
          WHEN '0017'.
            gt_detail-wwsfr  = gt_excel-value.
          WHEN '0018'.
            gt_detail-wwpfn  = gt_excel-value.
          WHEN '0019'.
            gt_detail-wwpos  = gt_excel-value.
          WHEN '0020'.
            gt_detail-zuonr  = gt_excel-value.
* Tambahan baru untuk upload COPA
          WHEN '0021'.
            gt_detail-vkgrp  = gt_excel-value.
          WHEN '0022'.
            gt_detail-kndnr  = gt_excel-value.
          WHEN '0023'.
            gt_detail-artnr  = gt_excel-value.
          WHEN '0024'.
            gt_detail-wwpbr  = gt_excel-value.
          WHEN '0025'.
            gt_detail-wwpgr  = gt_excel-value.
          WHEN '0026'.
            gt_detail-wwprc  = gt_excel-value.
          WHEN '0027'.
            gt_detail-spart  = gt_excel-value.
          WHEN '0028'.
            gt_detail-kdgrp  = gt_excel-value.
          WHEN '0029'.
            gt_detail-matkl  = gt_excel-value.
          WHEN '0030'.
            gt_detail-wwctp  = gt_excel-value.
          WHEN '0031'.
            gt_detail-extwg  = gt_excel-value.
          WHEN '0032'.
            gt_detail-wwprr  = gt_excel-value.
          WHEN '0033'.
            gt_detail-wwprd  = gt_excel-value.
          WHEN '0034'.
            gt_detail-wwsec  = gt_excel-value.
          WHEN '0035'.
            gt_detail-wwtrz  = gt_excel-value.
          WHEN '0036'.
            gt_detail-matnr  = gt_excel-value.
*          WHEN '0037'.
*            gt_detail-zterm  = gt_excel-value.
        ENDCASE.
        AT END OF row.
          ADD 1 TO lv_buzei.
          gt_detail-buzei = lv_buzei.
          IF lv_waers IS INITIAL.
            lv_waers  = 'IDR'.
          ENDIF.
          gt_detail-waers = lv_waers.
          gt_detail-kursf = lv_kursf.
          APPEND gt_detail.
          CLEAR: gt_detail.
        ENDAT.
    ENDCASE.
  ENDLOOP.

  IF fc_error IS INITIAL.
    IF lv_waers NE 'IDR' AND
      lv_kursf IS INITIAL.
      fc_error  = 2.
    ENDIF.
  ENDIF.

  SORT gt_detail BY newko.
  LOOP AT gt_detail.
    IF gt_detail-dmbtr IS INITIAL.
      DELETE gt_detail.
    ELSE.
      READ TABLE gt_tbsl WITH KEY bschl = gt_detail-newbs.
      IF sy-subrc EQ 0.
        IF gt_tbsl-koart EQ 'S'.
          PERFORM f_modify_value USING gt_detail-newko '' 'X'
                                 CHANGING lt_ska1-saknr.
*          lt_ska1-saknr = gt_detail-newko.
          APPEND lt_ska1.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

*  DATA(lt_detail) = gt_detail[].
*  SORT lt_detail BY zterm.
*  DELETE ADJACENT DUPLICATES FROM lt_detail COMPARING zterm.
*  SELECT zterm ztagg ztag1
*    INTO CORRESPONDING FIELDS OF TABLE gt_t052
*    FROM t052 FOR ALL ENTRIES IN gt_detail
*    WHERE zterm = gt_detail-zterm.

  IF lt_ska1[] IS NOT INITIAL.
    SORT lt_ska1 BY saknr.
    DELETE ADJACENT DUPLICATES FROM lt_ska1 COMPARING saknr.
    SELECT ktopl saknr xbilk
      FROM ska1
      INTO TABLE gt_ska1
      FOR ALL ENTRIES IN lt_ska1
      WHERE ktopl EQ 'TSPC' AND
            saknr EQ lt_ska1-saknr.
  ENDIF.
ENDFORM.                    "F_GET_DATA_UPLOAD

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_DOWNLOAD
*&---------------------------------------------------------------------*
FORM f_get_data_download .
  CREATE OBJECT h_excel 'EXCEL.APPLICATION'.

  SET PROPERTY OF h_excel 'Visible' = 1.

  CALL METHOD OF h_excel 'Workbooks' = h_mapl.

  CALL METHOD OF h_mapl 'Add' = h_map.

  PERFORM fill_cell USING 2 1 1 'Doc.Date                :'.
  PERFORM fill_cell USING 2 3 1 'Type                      :'.
  PERFORM fill_cell USING 3 1 1 'Post.Date               :'.
  PERFORM fill_cell USING 3 3 1 'Company Code:'.
  PERFORM fill_cell USING 4 1 1 'Refference            :'.
  PERFORM fill_cell USING 4 3 1 'Currency/Rate  :'.
  PERFORM fill_cell USING 5 1 1 'Doc.Header Text :'.

  PERFORM fill_cell USING 8 1 1 'Posting Key'.
  PERFORM fill_cell USING 8 2 1 'Account'.
  PERFORM fill_cell USING 8 3 1 'SGL Ind'.
  PERFORM fill_cell USING 8 4 1 'TType'.
  PERFORM fill_cell USING 8 5 1 'Amount'.
  PERFORM fill_cell USING 8 6 1 'Tax.Code'.
  PERFORM fill_cell USING 8 7 1 'B.Area'.
  PERFORM fill_cell USING 8 8 1 'TRD.PART.'.
  PERFORM fill_cell USING 8 9 1 'Cost.Centre'.
  PERFORM fill_cell USING 8 10 1 'Order'.
  PERFORM fill_cell USING 8 11 1 'Profit center'.
  PERFORM fill_cell USING 8 12 1 'Plant'.
  PERFORM fill_cell USING 8 13 1 'Text'.
  PERFORM fill_cell USING 8 14 1 'SalesOrg'.
  PERFORM fill_cell USING 8 15 1 'DisChan'.
  PERFORM fill_cell USING 8 16 1 'Soff'.
  PERFORM fill_cell USING 8 17 1 'Sales Force'.
  PERFORM fill_cell USING 8 18 1 'Sales Area'.
  PERFORM fill_cell USING 8 19 1 'W&D category'.
  PERFORM fill_cell USING 8 20 1 'Assignment '.
* Tambahan untuk COPA
  PERFORM fill_cell USING 8 21 1 'SalesGrp'.
  PERFORM fill_cell USING 8 22 1 'Customer'.
  PERFORM fill_cell USING 8 23 1 'Product'.
  PERFORM fill_cell USING 8 24 1 'Pro.brand'.
  PERFORM fill_cell USING 8 25 1 'prdGrpTSP'.
  PERFORM fill_cell USING 8 26 1 'Principal'.
  PERFORM fill_cell USING 8 27 1 'Division'.
  PERFORM fill_cell USING 8 28 1 'Cust.Grp'.
  PERFORM fill_cell USING 8 29 1 'materialGrp'.
  PERFORM fill_cell USING 8 30 1 'Cust type'.
  PERFORM fill_cell USING 8 31 1 'Ext. Matl Grp'.
  PERFORM fill_cell USING 8 32 1 'prod. Range'.
  PERFORM fill_cell USING 8 33 1 'prdGrp PTT/EC'.
  PERFORM fill_cell USING 8 34 1 'SupportExpCategory'.
  PERFORM fill_cell USING 8 35 1 'key account'.
  PERFORM fill_cell USING 8 36 1 'Material'.
*  PERFORM fill_cell USING 8 37 1 'Term'.

  FREE OBJECT h_excel.
ENDFORM.                    " F_GET_DATA_DOWNLOAD

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  SELECT bukrs belnr gjahr filename xblnr zupld zuplt zuplu
    FROM zflogtr
    INTO CORRESPONDING FIELDS OF TABLE gt_zflogtr
    WHERE bukrs EQ pa_bukrs AND
          zupld IN so_datum.
ENDFORM.                    " F_GET_DATA

*---------------------------------------------------------------------*
*       FORM FILL_CELL                                                *
*---------------------------------------------------------------------*
*       sets cell at coordinates i,j to value val boldtype bold       *
*---------------------------------------------------------------------*
FORM fill_cell USING i j bold val.
  CALL METHOD OF h_excel 'Cells' = h_zl EXPORTING #1 = i #2 = j.
  SET PROPERTY OF h_zl 'Value' = val .
  GET PROPERTY OF h_zl 'Font' = h_f.
  SET PROPERTY OF h_f 'Bold' = bold .
ENDFORM.                    "fill_cell

*&---------------------------------------------------------------------*
*&      Form  F_DATE_MODIFY
*&---------------------------------------------------------------------*
FORM f_date_modify  USING    fu_datum
                    CHANGING fc_datum.
  CONCATENATE fu_datum+6(4) fu_datum+3(2) fu_datum(2)
  INTO fc_datum.
ENDFORM.                    " F_DATE_MODIFY

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  CASE 'X'.
    WHEN radio1.
      PERFORM f_alv TABLES gt_detail.
    WHEN radio2.
    WHEN radio3.
      PERFORM f_alv TABLES gt_zflogtr.
  ENDCASE.
ENDFORM.                    "F_PRINT_DATA

*---------------------------------------------------------------------*
*       FORM F_ALV
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  PERFORM f_build_event       TABLES  t_alv_event[].
  lv_func    = 'REUSE_ALV_LIST_DISPLAY'.

  CALL FUNCTION lv_func
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      i_grid_title             = lv_title
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
ENDFORM.                    "F_ALV

*---------------------------------------------------------------------*
*       FORM F_FIELDCAT
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.
  CASE 'X'.
    WHEN radio1.
* Begin remark unicode coversion - DEVK966040
* 17.03.2020 - sol chirka
**      PERFORM f_fieldcatg USING ft_report:
**        'ICON' '' '' '' '4' 'Sts' '' '' '' '' '' '' '' '' '' '',
**        'NEWBS' 'BSEG' 'BSCHL' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NEWKO' 'BSEG' 'HKONT' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NEWUM' 'BSEG' 'UMSKZ' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'NEWBW' 'RF05A' 'NEWBW' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'WAERS' 'BKPF' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'DMBTR' 'BSEG' 'DMBTR' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' '',
**        'MWSKZ' 'BSEG' 'MWSKZ' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'GSBER' 'BSEG' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'VBUND' 'BSEG' 'VBUND' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'KOSTL' 'BSEG' 'KOSTL' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'AUFNR' 'COBL' 'AUFNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'PRCTR' 'BSEG' 'PRCTR' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'WERKS' 'BSEG' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'SGTXT' 'BSEG' 'SGTXT' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'ZUONR' 'BSEG' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '' ''.
**    WHEN radio2.
**    WHEN radio3.
**      PERFORM f_fieldcatg USING ft_report:
**        'BUKRS' 'ZFLOGTR' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'BELNR' 'ZFLOGTR' 'BELNR' '' '' '' '' 'X' '' '' '' '' '' '' '' '',
**        'GJAHR' 'ZFLOGTR' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'FILENAME' 'ZFLOGTR' 'FILENAME' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'XBLNR' 'ZFLOGTR' 'XBLNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'ZUPLD' 'ZFLOGTR' 'ZUPLD' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'ZUPLT' 'ZFLOGTR' 'ZUPLT' '' '' '' '' '' '' '' '' '' '' '' '' '',
**        'ZUPLU' 'ZFLOGTR' 'ZUPLU' '' '' '' '' '' '' '' '' '' '' '' '' ''.
* End remark unicode coversion - DEVK966040
* Begin insert unicode conversion - DEVK966040
* 17.03.2020 - sol chirka
      PERFORM f_fieldcatg USING :
        'FT_REPORT' 'ICON'     ''        ''         '' '4' 'Sts' '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'NEWBS'    'BSEG'    'BSCHL'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'NEWKO'    'BSEG'    'HKONT'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'NEWUM'    'BSEG'    'UMSKZ'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'NEWBW'    'RF05A'   'NEWBW'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'WAERS'    'BKPF'    'WAERS'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'DMBTR'    'BSEG'    'DMBTR'    '' ''  ''    '' ''  '' '' '' 'WAERS' '' '' '' '',
        'FT_REPORT' 'MWSKZ'    'BSEG'    'MWSKZ'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'GSBER'    'BSEG'    'GSBER'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'VBUND'    'BSEG'    'VBUND'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'KOSTL'    'BSEG'    'KOSTL'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'AUFNR'    'COBL'    'AUFNR'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'PRCTR'    'BSEG'    'PRCTR'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'WERKS'    'BSEG'    'WERKS'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'SGTXT'    'BSEG'    'SGTXT'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'ZUONR'    'BSEG'    'ZUONR'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' ''.
*        'FT_REPORT' 'ZTERM'    'T052'    'ZTERM'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' ''.
    WHEN radio2.
    WHEN radio3.
      PERFORM f_fieldcatg USING :
        'FT_REPORT' 'BUKRS'    'ZFLOGTR' 'BUKRS'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'BELNR'    'ZFLOGTR' 'BELNR'    '' ''  ''    '' 'X' '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'GJAHR'    'ZFLOGTR' 'GJAHR'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'FILENAME' 'ZFLOGTR' 'FILENAME' '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'XBLNR'    'ZFLOGTR' 'XBLNR'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'ZUPLD'    'ZFLOGTR' 'ZUPLD'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'ZUPLT'    'ZFLOGTR' 'ZUPLT'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' '',
        'FT_REPORT' 'ZUPLU'    'ZFLOGTR' 'ZUPLU'    '' ''  ''    '' ''  '' '' '' ''      '' '' '' ''.
* End insert unicode conversion - DEVK966040
  ENDCASE.
ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*&  Emphasize
*&  - 1st char = C (color property)
*&  - 2nd char = color code (from 0 to 7)
*&    0 = background color
*&    1 = blue
*&    2 = gray
*&    3 = yellow
*&    4 = blue/gray
*&    5 = green
*&    6 = red
*&    7 = orange
*&  - 3rd char = intensified (0=off, 1=on)
*&  - 4th char = inverse display (0=off, 1=on)
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    VALUE(fu_types)
                          VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_fltxt)
                          VALUE(fu_dosum)
                          VALUE(fu_hotsp)
                          VALUE(fu_dec)
                          VALUE(fu_waers)
                          VALUE(fu_meins)
                          VALUE(fu_waers_f)
                          VALUE(fu_meins_f)
                          VALUE(fu_checkbox)
                          VALUE(fu_input)
                          VALUE(fu_emphasize).

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
  ld_fieldcat-input             = fu_input.
  ld_fieldcat-emphasize         = fu_emphasize.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.                    "F_BUILD_EVENT

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT_EXIT
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
ENDFORM.                    "F_BUILD_EVENT_EXIT

*---------------------------------------------------------------------*
*       FORM F_BUILD_LAYOUT
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
*  fu_layout-box_fieldname      = 'CHECK'.
ENDFORM.                    "F_BUILD_LAYOUT

*---------------------------------------------------------------------*
*       FORM F_BUILD_PRINT
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "F_BUILD_PRINT

*---------------------------------------------------------------------*
*       FORM F_BUILD_SORTFIELD
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'MATKL'.
*  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
**  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.
ENDFORM.                    "F_BUILD_SORTFIELD

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM f_top_of_page.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.
ENDFORM.                    "F_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory.
* here free all the internal table used in the program.
  CLEAR: gt_header, gt_header[], gt_detail, gt_detail[].
ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ALV_DATA
*&---------------------------------------------------------------------*
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
ENDFORM.                    " F_CLEAR_ALV_DATA

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  CASE 'X'.
    WHEN radio1.
      SET PF-STATUS 'TOEXECUTE'.
    WHEN radio2.
    WHEN radio3.
      SET PF-STATUS 'STANDARD'.
  ENDCASE.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM F_GUI_MESSAGE
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "F_GUI_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
FORM f_alv_variant_exist USING     fu_vari
                         CHANGING  fc_alv_variant STRUCTURE disvariant.
  IF NOT fu_vari IS INITIAL.
    MOVE fu_vari TO fc_alv_variant-variant.
    fc_alv_variant-report = d_repid.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save        = 'A'
      CHANGING
        cs_variant    = fc_alv_variant
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      IF NOT sy-msgid IS INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR fc_alv_variant.
    fc_alv_variant-report = sy-repid.
  ENDIF.
ENDFORM.                    " F_ALV_VARIANT_EXIST

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data.

ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread  LIKE dynpread OCCURS 0 WITH HEADER LINE,
        ffield(20),
        fvalue(20),
        lwa_zflogtr  LIKE gt_zflogtr,
        lv_mess(100),
        lv_flag      TYPE sy-subrc.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&IC1'.
      GET CURSOR FIELD ffield VALUE fvalue.
      IF ffield EQ 'GT_ZFLOGTR-BELNR'.
        READ TABLE gt_zflogtr INDEX fu_selfield-tabindex INTO lwa_zflogtr.
        SET PARAMETER ID 'BLN' FIELD fvalue.
        SET PARAMETER ID 'BUK' FIELD pa_bukrs.
        SET PARAMETER ID 'GJR' FIELD lwa_zflogtr-gjahr.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN '&POS' OR '&PARK'.
      IF gv_error IS INITIAL.
        IF fu_ucomm EQ '&POS'.
          lv_flag = 1.
        ELSE.
          lv_flag = 2.
        ENDIF.
        PERFORM f_post_entries USING 'POSTING' lv_flag
                               CHANGING gv_belnr.
        IF gv_belnr IS NOT INITIAL.
          CONCATENATE 'Document number' gv_belnr 'already posted' INTO lv_mess
          SEPARATED BY space.
          MESSAGE s000(zab) WITH lv_mess.
        ELSE.
          MESSAGE s000(zab) WITH ''.
        ENDIF.
        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE e000(zab) WITH 'Error posting, please check in Error Log'.
      ENDIF.

    WHEN '&LOG'.
      CALL SCREEN 500 STARTING AT 10 10 ENDING AT 132 22.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND


*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
FORM f_f4_for_variant_alv CHANGING fc_variant.
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
ENDFORM.                    " F_F4_FOR_VARIANT_ALV

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group fu_error.
  DATA: lv_mess(100).

  CASE fu_error.
    WHEN '0'.
      lv_mess = 'Fill in all required entry fields'.
    WHEN '1'.
      lv_mess = 'Error in Posting date'.
  ENDCASE.
  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input  = 1.
    ELSE.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries USING fu_process fu_flag
                    CHANGING fc_belnr.
  DATA: obj_type LIKE bapiache09-obj_type,
        lv_gjahr TYPE gjahr,
        lv_txt1  TYPE ztxt,
        lv_txt2  TYPE ztxt,
        lv_txt3  TYPE ztxt,
        lv_txt4  TYPE ztxt.

  CASE pa_bukrs.
    WHEN '8010' OR '8180'.
      SELECT aufnr, astkz INTO TABLE @DATA(lt_coas)
        FROM coas FOR ALL ENTRIES IN @gt_detail
        WHERE aufnr = @gt_detail-aufnr.
    WHEN OTHERS.
  ENDCASE.

  LOOP AT gt_header.
    documentheader-bus_act    = 'RFBU'.
    documentheader-username   = sy-uname.
    documentheader-comp_code  = pa_bukrs.
    documentheader-doc_date   = gv_bldat.
    documentheader-pstng_date = gv_budat.
    documentheader-doc_type   = gt_header-blart.
    documentheader-ref_doc_no = gt_header-xblnr.
    documentheader-header_txt = gt_header-bktxt.

    CASE fu_process.
      WHEN 'SIMULATE'.
        LOOP AT gt_detail.
          CASE pa_bukrs.
            WHEN '8010' OR '8180'.
              DATA(lv_astkz) = VALUE #( lt_coas[ aufnr = gt_detail-aufnr ]-astkz OPTIONAL ).
              IF lv_astkz IS INITIAL.
                CLEAR gv_copa.
              ELSE.
                gv_copa = 'X'.
              ENDIF.
            WHEN '8220'.
              CLEAR gv_copa.
*            WHEN '8390'.
*              IF gt_detail-zterm IS NOT INITIAL.
*                gt_detail-ztag1 = VALUE #( gt_t052[ zterm = gt_detail-zterm ]-ztag1 OPTIONAL ).
*              ENDIF.
*              IF gt_detail-prctr IS NOT INITIAL.
*                gv_copa = 'X'.
*              ELSE.
*                CLEAR gv_copa.
*              ENDIF.
            WHEN OTHERS.
          ENDCASE.
          PERFORM f_bapi_simulate USING gt_detail gv_copa.
          MODIFY gt_detail TRANSPORTING icon.
        ENDLOOP.

        PERFORM f_bapi_document_check CHANGING gv_error.

        IF gv_error IS NOT INITIAL.
          LOOP AT gt_detail.
            gt_detail-icon  = icon_led_red.
            MODIFY gt_detail TRANSPORTING icon.
          ENDLOOP.
        ENDIF.

      WHEN 'POSTING'.
        CLEAR: lv_txt1, lv_txt2, lv_txt3, lv_txt4.
        LOOP AT gt_detail WHERE icon  EQ icon_led_green.
          CASE pa_bukrs.
            WHEN '8010' OR '8180'.
              lv_astkz = VALUE #( lt_coas[ aufnr = gt_detail-aufnr ]-astkz OPTIONAL ).
              IF lv_astkz IS INITIAL.
                CLEAR gv_copa.
              ELSE.
                gv_copa = 'X'.
              ENDIF.
            WHEN '8220'.
              CLEAR gv_copa.
*            WHEN '8390'.
*              IF gt_detail-zterm IS NOT INITIAL.
*                gt_detail-ztag1 = VALUE #( gt_t052[ zterm = gt_detail-zterm ]-ztag1 OPTIONAL ).
*              ENDIF.
*              IF gt_detail-prctr IS NOT INITIAL.
*                gv_copa = 'X'.
*              ELSE.
*                CLEAR gv_copa.
*              ENDIF.
            WHEN OTHERS.
          ENDCASE.
          PERFORM f_bapi_simulate USING gt_detail gv_copa.
          IF gv_waers IS INITIAL.
            gv_waers  = gt_detail-waers.
          ENDIF.
        ENDLOOP.

        IF sy-subrc EQ 0.
          CASE fu_flag.
            WHEN 1.
              obj_type = 'BKPF'.
              PERFORM f_bapi_document_post USING obj_type
                                           CHANGING fc_belnr lv_gjahr.
            WHEN 2.
              PERFORM f_park_document USING gv_waers gv_bldat gv_budat
                                      CHANGING fc_belnr lv_gjahr.
          ENDCASE.

          IF fc_belnr IS NOT INITIAL.
            gt_zflogtr-bukrs     = pa_bukrs.
            gt_zflogtr-belnr     = fc_belnr.
            gt_zflogtr-gjahr     = lv_gjahr.
            gt_zflogtr-filename  = filename.
            gt_zflogtr-xblnr     = gv_xblnr.
            gt_zflogtr-zupld     = sy-datum.
            gt_zflogtr-zuplt     = sy-uzeit.
            gt_zflogtr-zuplu     = sy-uname.
            APPEND gt_zflogtr.

            LOOP AT gt_zflogtr.
              INSERT zflogtr FROM gt_zflogtr.
            ENDLOOP.
          ENDIF.
        ENDIF.
    ENDCASE.

    CLEAR: accountgl, accountpayable, accountreceivable,
           currencyamount, extension1, criteria,
           accountgl[], accountpayable[], accountreceivable[],
           currencyamount[], extension1[], criteria[].
  ENDLOOP.
ENDFORM.                    " F_POST_ENTRIES

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_DOCUMENT_CHECK
*&---------------------------------------------------------------------*
FORM f_bapi_document_check CHANGING fc_error.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
    EXPORTING
      documentheader    = documentheader
    TABLES
      accountgl         = accountgl
      accountpayable    = accountpayable
      accountreceivable = accountreceivable
      currencyamount    = currencyamount
      extension1        = extension1
      criteria          = criteria
      return            = return.

  LOOP AT return.
    IF return-type = 'A' OR return-type = 'E'.
      gt_error-bktxt    = documentheader-header_txt.
      gt_error-message  = return-message.
      fc_error          = 1.
      IF return-id NE 'RW' OR
        return-number NE '609'.
        APPEND gt_error.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_BAPI_DOCUMENT_CHECK

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_DOCUMENT_POST
*&---------------------------------------------------------------------*
FORM f_bapi_document_post  USING    obj_type
                           CHANGING fc_belnr fc_gjahr.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader    = documentheader
    IMPORTING
      obj_type          = obj_type
    TABLES
      accountgl         = accountgl
      accountpayable    = accountpayable
      accountreceivable = accountreceivable
      currencyamount    = currencyamount
      extension1        = extension1
      criteria          = criteria
      return            = return.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait   = 'X'
    IMPORTING
      return = return.

  LOOP AT return.
    IF return-type = 'S'.
      fc_belnr    = return-message_v2(10).
      fc_gjahr    = return-message_v2+14(4).
    ENDIF.
  ENDLOOP.

ENDFORM.                    " F_BAPI_DOCUMENT_POST

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_SIMULATE
*&---------------------------------------------------------------------*
FORM f_bapi_simulate USING ft_detail STRUCTURE gt_detail
                           fu_copa.
  DATA: lv_dmbtr   TYPE tslvt9,
        lv_xbilk   TYPE xbilk,
        lv_gvtyp   TYPE gvtyp,
        lv_copa(1).

  CLEAR: lv_xbilk, lv_gvtyp, lv_copa.

  lv_dmbtr = abs( gt_detail-dmbtr ).

  READ TABLE gt_tbsl WITH KEY bschl = ft_detail-newbs.
  IF sy-subrc EQ 0.
    CASE gt_tbsl-koart.
      WHEN 'D'.
*        IF pa_bukrs = '8390' AND ft_detail-zterm IS NOT INITIAL.
*          accountreceivable-pmnttrms    = ft_detail-zterm.
*          accountreceivable-bline_date  = gv_budat.
*          accountreceivable-dsct_days1  = ft_detail-ztag1.
*        ENDIF.
        accountreceivable-itemno_acc    = ft_detail-buzei.
        accountreceivable-customer      = ft_detail-newko.
        accountreceivable-item_text     = ft_detail-sgtxt.
        accountreceivable-bus_area      = ft_detail-gsber.
        accountreceivable-tax_code      = ft_detail-mwskz.
        accountreceivable-sp_gl_ind     = ft_detail-newum.
        accountreceivable-ref_key_3     = 'X'.
        accountreceivable-alloc_nmbr    = ft_detail-zuonr.
        APPEND accountreceivable.
      WHEN 'K'.
        accountpayable-itemno_acc       = ft_detail-buzei.
        accountpayable-vendor_no        = ft_detail-newko.
        accountpayable-item_text        = ft_detail-sgtxt.
        accountpayable-bus_area         = ft_detail-gsber.
        accountpayable-tax_code         = ft_detail-mwskz.
        accountpayable-sp_gl_ind        = ft_detail-newum.
        accountpayable-ref_key_3        = 'X'.
        accountpayable-alloc_nmbr       = ft_detail-zuonr.
        APPEND accountpayable.
      WHEN 'S'.
        accountgl-itemno_acc            = ft_detail-buzei.
        PERFORM f_modify_value USING ft_detail-newko '' 'X'
                               CHANGING accountgl-gl_account.
        accountgl-item_text             = ft_detail-sgtxt.
        accountgl-bus_area              = ft_detail-gsber.
        accountgl-tax_code              = ft_detail-mwskz.
        accountgl-trade_id              = ft_detail-vbund.
        accountgl-costcenter            = ft_detail-kostl.
        accountgl-orderid               = ft_detail-aufnr.
        accountgl-ref_key_3             = 'X'.
        accountgl-profit_ctr            = ft_detail-prctr.
        accountgl-cs_trans_t            = ft_detail-newbw.
        accountgl-plant                 = ft_detail-werks.
        accountgl-alloc_nmbr            = ft_detail-zuonr.
        accountgl-material              = ft_detail-matnr.
        APPEND accountgl.

        PERFORM f_gl_acc_detail USING pa_bukrs accountgl-gl_account ft_detail-kostl
                                CHANGING lv_xbilk lv_gvtyp lv_copa.

*        IF pa_bukrs = '8380'.
*          lv_copa = 'X'.
*        ENDIF.
    ENDCASE.

    extension1(3)                = ft_detail-buzei.
    extension1+3(2)              = ft_detail-newbs.
    APPEND extension1.

    currencyamount-itemno_acc    = ft_detail-buzei.
    currencyamount-curr_type     = '00'.
    currencyamount-currency      = ft_detail-waers.
    currencyamount-exch_rate     = ft_detail-kursf.
    PERFORM f_amount_modify USING lv_dmbtr ft_detail-waers gt_tbsl-shkzg
                            CHANGING ft_detail-dmbtr.
    currencyamount-amt_doccur    = ft_detail-dmbtr.
    APPEND currencyamount.

    IF lv_copa IS NOT INITIAL AND
      fu_copa EQ 'X'.
*    IF lv_xbilk IS INITIAL AND
*      fu_copa EQ 'X'.
      IF gt_tbsl-koart NE 'A'.
        criteria-itemno_acc        = ft_detail-buzei.
        criteria-fieldname         = 'VKORG'.
        criteria-character         = ft_detail-vkorg.
        APPEND criteria.
        criteria-fieldname         = 'VTWEG'.
        criteria-character         = ft_detail-vtweg.
        APPEND criteria.
        criteria-fieldname         = 'KMVKBU'.
        criteria-character         = ft_detail-vkbur.
        APPEND criteria.
        criteria-fieldname         = 'WWSFR'.
        criteria-character         = ft_detail-wwsfr.
        APPEND criteria.
        criteria-fieldname         = 'WWPFN'.
        criteria-character         = ft_detail-wwpfn.
        APPEND criteria.
        criteria-fieldname         = 'WWPOS'.
        criteria-character         = ft_detail-wwpos.
        APPEND criteria.
* Tambahan baru untuk upload COPA
        criteria-fieldname         = 'VKGRP'.
        criteria-character         = ft_detail-vkgrp.
        APPEND criteria.
        criteria-fieldname         = 'KNDNR'.
        criteria-character         = ft_detail-kndnr.
        APPEND criteria.
        criteria-fieldname         = 'ARTNR'.
        criteria-character         = ft_detail-artnr.
        APPEND criteria.
        criteria-fieldname         = 'WWPBR'.
        criteria-character         = ft_detail-wwpbr.
        APPEND criteria.
        criteria-fieldname         = 'WWPGR'.
        criteria-character         = ft_detail-wwpgr.
        APPEND criteria.
        criteria-fieldname         = 'WWPRC'.
        criteria-character         = ft_detail-wwprc.
        APPEND criteria.
        criteria-fieldname         = 'SPART'.
        criteria-character         = ft_detail-spart.
        APPEND criteria.
        criteria-fieldname         = 'KDGRP'.
        criteria-character         = ft_detail-kdgrp.
        APPEND criteria.
        criteria-fieldname         = 'MATKL'.
        criteria-character         = ft_detail-matkl.
        APPEND criteria.
        criteria-fieldname         = 'WWCTP'.
        criteria-character         = ft_detail-wwctp.
        APPEND criteria.
        criteria-fieldname         = 'EXTWG'.
        criteria-character         = ft_detail-extwg.
        APPEND criteria.
        criteria-fieldname         = 'WWPRR'.
        criteria-character         = ft_detail-wwprr.
        APPEND criteria.
        criteria-fieldname         = 'WWPRD'.
        criteria-character         = ft_detail-wwprd.
        APPEND criteria.
        criteria-fieldname         = 'WWSEC'.
        criteria-character         = ft_detail-wwsec.
        APPEND criteria.
        criteria-fieldname         = 'WWTRZ'.
        criteria-character         = ft_detail-wwtrz.
        APPEND criteria.
*****
      ENDIF.
    ENDIF.

    CLEAR: accountgl, accountpayable, accountreceivable,
           currencyamount, extension1, criteria.
  ENDIF.

  ft_detail-icon  = icon_led_green.
ENDFORM.                    " F_BAPI_SIMULATE

*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0500 OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " STATUS_0500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING_0500  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE list_processing_0500 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_error_log.
ENDMODULE.                 " LIST_PROCESSING_0500  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_LOG
*&---------------------------------------------------------------------*
FORM f_error_log .
  DATA: lv_zebra  TYPE i.

  WRITE: / sy-uline(121).
  FORMAT COLOR 1.
  WRITE: / sy-vline, (20) 'Document',
           sy-vline, (94) 'Message',
           sy-vline.
  WRITE: / sy-uline(121).
  FORMAT COLOR OFF.
  LOOP AT gt_error.
    IF lv_zebra IS INITIAL.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED ON.
      lv_zebra  = 1.
    ELSE.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED OFF.
      lv_zebra  = 0.
    ENDIF.
    WRITE: / sy-vline, (20) gt_error-bktxt,
             sy-vline, (94) gt_error-message,
             sy-vline.
  ENDLOOP.
  WRITE: / sy-uline(121).
ENDFORM.                    " F_ERROR_LOG

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_VALUE
*&---------------------------------------------------------------------*
FORM f_modify_value  USING    fu_value fu_koart fu_flag
                     CHANGING fc_value.
  DATA: lv_length   TYPE i.

  lv_length = strlen( fu_value ).

  IF fu_flag IS INITIAL.
    IF fu_koart EQ 'S'.
      PERFORM f_modify_alpha USING fu_value
                             CHANGING fc_value.
*      PERFORM f_modify_to_10_length USING lv_length fu_value
*                                    CHANGING fc_value.
    ELSE.
      fc_value  = fu_value.
    ENDIF.
  ELSE.
    PERFORM f_modify_alpha USING fu_value
                           CHANGING fc_value.
*    PERFORM f_modify_to_10_length USING lv_length fu_value
*                                  CHANGING fc_value.
  ENDIF.
ENDFORM.                    " F_MODIFY_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TO_10_LENGTH
*&---------------------------------------------------------------------*
FORM f_modify_to_10_length  USING    fu_length fu_value
                            CHANGING fc_value.
  CASE fu_length.
    WHEN 1.
      CONCATENATE '000000000' fu_value INTO fc_value.
    WHEN 2.
      CONCATENATE '00000000' fu_value INTO fc_value.
    WHEN 3.
      CONCATENATE '0000000' fu_value INTO fc_value.
    WHEN 4.
      CONCATENATE '000000' fu_value INTO fc_value.
    WHEN 5.
      CONCATENATE '00000' fu_value INTO fc_value.
    WHEN 6.
      CONCATENATE '0000' fu_value INTO fc_value.
    WHEN 7.
      CONCATENATE '000' fu_value INTO fc_value.
    WHEN 8.
      CONCATENATE '00' fu_value INTO fc_value.
    WHEN 9.
      CONCATENATE '0' fu_value INTO fc_value.
    WHEN OTHERS.
      fc_value  = fu_value.
  ENDCASE.
ENDFORM.                    " F_MODIFY_TO_10_LENGTH

*&---------------------------------------------------------------------*
*&      Form  F_AMOUNT_MODIFY
*&---------------------------------------------------------------------*
FORM f_amount_modify  USING    fu_value fu_waers fu_shkzg
                      CHANGING fc_dmbtr.
  DATA: lv_dmbtr(19),
        lv_subrc    TYPE sy-subrc.

  CLEAR fc_dmbtr.

  IF fu_waers IS INITIAL.
    fu_waers  = 'IDR'.
  ENDIF.

  IF fu_shkzg IS NOT INITIAL.
    lv_dmbtr  = fu_value.
    WHILE sy-subrc EQ 0.
      REPLACE '.' WITH space INTO lv_dmbtr.
    ENDWHILE.
    CONDENSE lv_dmbtr NO-GAPS.

    IF fu_waers NE 'IDR'.
      lv_dmbtr  = lv_dmbtr / 100.
    ENDIF.

    IF fu_shkzg EQ 'H'.
      fc_dmbtr  = lv_dmbtr * -1.
    ELSE.
      fc_dmbtr  = lv_dmbtr.
    ENDIF.
  ELSE.
    CALL FUNCTION 'ZPSSV_TEXT_INTO_FIELD_CURRENCY'
      EXPORTING
        i_amount       = fu_value
        i_currency     = fu_waers
      IMPORTING
        e_amount       = lv_dmbtr
      EXCEPTIONS
        wrong_amount   = 1
        wrong_currency = 2
        wrong_decimal  = 3
        OTHERS         = 4.

    WHILE sy-subrc EQ 0.
      REPLACE '.' WITH space INTO lv_dmbtr.
    ENDWHILE.
    CONDENSE lv_dmbtr NO-GAPS.
    fc_dmbtr  = lv_dmbtr / 100.
  ENDIF.
ENDFORM.                    " F_AMOUNT_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_KURSF_MODIFY
*&---------------------------------------------------------------------*
FORM f_kursf_modify  USING    fu_value
                     CHANGING fc_kursf.

  WHILE sy-subrc EQ 0.
    REPLACE ',' WITH '.' INTO fu_value.
  ENDWHILE.

  fc_kursf  = fu_value.
ENDFORM.                    " F_KURSF_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_POPUP_ERROR
*&---------------------------------------------------------------------*
FORM f_popup_error  USING    fu_title fu_message.
  CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
    EXPORTING
      popup_title  = fu_title
      message_text = fu_message.
ENDFORM.                    " F_POPUP_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_PARK_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_park_document  USING fu_waers fu_bldat fu_budat
                      CHANGING fc_belnr fc_gjahr.
  DATA: lv_bldat(8),
        lv_budat(8),
        lt_proc      LIKE gt_detail OCCURS 0 WITH HEADER LINE,
        lw_proc      LIKE lt_proc,
        lv_shkzg     TYPE shkzg,
        lv_koart     TYPE koart,
        lv_dmbtr(15),
        lv_flag      TYPE sy-subrc.

  lt_proc[] = gt_detail[].
  DELETE lt_proc WHERE icon EQ icon_led_red.

  IF lt_proc[] IS INITIAL.
    MESSAGE e000(zab) WITH 'No data to execute'.
  ELSE.

    d_bdc_tctxt = 'Executing Transaction FBV1'.
    d_bdc_batch = 'N'.

    CLEAR: t_bdcdata, t_bdcmsg.
    REFRESH: t_bdcdata, t_bdcmsg.

    PERFORM f_format_date USING    fu_bldat
                          CHANGING lv_bldat.
    PERFORM f_format_date USING    fu_budat
                          CHANGING lv_budat.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X' 'SAPLF040'          '0100',
      ' ' 'BDC_OKCODE'        '/00',
      ' ' 'BKPF-BLDAT'        lv_bldat,
      ' ' 'BKPF-BLART'        documentheader-doc_type,
      ' ' 'BKPF-BUKRS'        documentheader-comp_code,
      ' ' 'BKPF-BUDAT'        lv_budat,
      ' ' 'BKPF-MONAT'        fu_bldat+4(2),
      ' ' 'BKPF-WAERS'        fu_waers,
      ' ' 'BKPF-XBLNR'        documentheader-ref_doc_no,
      ' ' 'BKPF-BKTXT'        documentheader-header_txt.

    READ TABLE lt_proc INTO lw_proc INDEX 1.
    PERFORM f_bdc_data TABLES t_bdcdata USING:
      ' ' 'RF05V-NEWBS'       lw_proc-newbs,
      ' ' 'RF05V-NEWKO'       lw_proc-newko.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X' 'SAPLF040'          '0300',
      ' ' 'BDC_OKCODE'        '=ZK'.

    READ TABLE gt_tbsl WITH KEY bschl = lw_proc-newbs.
    IF sy-subrc EQ 0.
      lv_shkzg  = gt_tbsl-shkzg.
      lv_koart  = gt_tbsl-koart.
    ENDIF.

    PERFORM f_amount_modify USING lw_proc-dmbtr lw_proc-waers lv_shkzg
                            CHANGING lv_dmbtr.
    lv_dmbtr  = abs( lv_dmbtr ).
    PERFORM f_bdc_data TABLES t_bdcdata USING:
      ' ' 'BSEG-WRBTR'        lv_dmbtr,
      ' ' 'BSEG-ZUONR'        lw_proc-zuonr,
      ' ' 'BSEG-SGTXT'        lw_proc-sgtxt,
      ' ' 'DKACB-FMORE'       'X'.

    PERFORM f_copa USING lv_koart lw_proc.

    LOOP AT lt_proc INTO lw_proc FROM 2.
      CLEAR: lv_shkzg, lv_koart.

      READ TABLE gt_tbsl WITH KEY bschl = lw_proc-newbs.
      IF sy-subrc EQ 0.
        lv_shkzg  = gt_tbsl-shkzg.
        lv_koart  = gt_tbsl-koart.
      ENDIF.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X' 'SAPLF040'          '0330',
        ' ' 'BDC_OKCODE'        '/00',
        ' ' 'RF05V-NEWBS'       lw_proc-newbs,
        ' ' 'RF05V-NEWKO'       lw_proc-newko.

      PERFORM f_amount_modify USING lw_proc-dmbtr lw_proc-waers lv_shkzg
                              CHANGING lv_dmbtr.
      lv_dmbtr  = abs( lv_dmbtr ).

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X' 'SAPLF040'          '0300',
        ' ' 'BDC_OKCODE'        '=ZK',
        ' ' 'BSEG-WRBTR'        lv_dmbtr,
        ' ' 'BSEG-ZUONR'        lw_proc-zuonr,
        ' ' 'BSEG-SGTXT'        lw_proc-sgtxt,
        ' ' 'DKACB-FMORE'       'X'.

      PERFORM f_copa USING lv_koart lw_proc.
    ENDLOOP.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X' 'SAPLF040'          '0330',
      ' ' 'BDC_OKCODE'        '=BP'.

    PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                            t_bdcmsg
                                     USING 'FBV1' d_bdc_tctxt.

    IF t_bdcmsg-msgtyp EQ 'S'.
      fc_belnr  = t_bdcmsg-msgv1.
      fc_gjahr  = sy-datum(4).
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PARK_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_FORMAT_DATE
*&---------------------------------------------------------------------*
FORM f_format_date  USING    fu_datum
                    CHANGING fc_datum.

  READ TABLE gt_user INDEX 1.
  CASE gt_user-datfm.
    WHEN 'DD.MM.YYYY'.
      CONCATENATE fu_datum+6(2) fu_datum+4(2) fu_datum(4)
                  INTO fc_datum.
    WHEN 'MM/DD/YYYY' OR 'MM-DD-YYYY'.
      CONCATENATE fu_datum+4(2) fu_datum+6(2) fu_datum(4)
                  INTO fc_datum.
    WHEN 'YYYY.MM.DD' OR 'YYYY/MM/DD' OR 'YYYY-MM-DD'.
      CONCATENATE fu_datum(4) fu_datum+4(2) fu_datum+6(2)
                  INTO fc_datum.
  ENDCASE.
ENDFORM.                    " F_FORMAT_DATE

*&---------------------------------------------------------------------*
*&      Form  F_COPA
*&---------------------------------------------------------------------*
FORM f_copa  USING    fu_koart
                      lwa_proc STRUCTURE gt_detail.
  DATA : lv_saknr   TYPE ska1-saknr.

  PERFORM f_modify_alpha USING lwa_proc-newko
                         CHANGING lv_saknr.

  IF fu_koart EQ 'S'.
    READ TABLE gt_ska1 WITH KEY saknr = lv_saknr.
    IF sy-subrc EQ 0.
      IF gt_ska1-xbilk IS INITIAL.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPLKACB'          '0002',
          ' ' 'BDC_OKCODE'        '=ENTE',
          ' ' 'COBL-GSBER'        lwa_proc-gsber,
          ' ' 'COBL-KOSTL'        lwa_proc-kostl.
      ELSE.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
          'X' 'SAPLKACB'          '0002',
          ' ' 'BDC_OKCODE'        '=ENTE',
          ' ' 'COBL-GSBER'        lwa_proc-gsber.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_COPA

*&---------------------------------------------------------------------*
*&      Form  F_GL_ACC_DETAIL
*&---------------------------------------------------------------------*
FORM f_gl_acc_detail  USING    fu_bukrs fu_hkont fu_kostl
                      CHANGING fc_xbilk fc_gvtyp fc_copa.
  DATA: return         LIKE bapireturn,
        account_detail LIKE bapi3006_2.

  DATA : lr_kostl TYPE RANGE OF kostl,
         lr_lines LIKE LINE OF lr_kostl.

  DATA: lr_control TYPE RANGE OF hkont.

  CLEAR lr_lines.
  lr_lines-low    = '*101'.
  lr_lines-sign   = 'E'.
  lr_lines-option = 'CP'.
  APPEND lr_lines TO lr_kostl.
  CLEAR lr_lines.
  lr_lines-low    = '*109'.
  lr_lines-sign   = 'E'.
  lr_lines-option = 'CP'.
  APPEND lr_lines TO lr_kostl.
  CLEAR lr_lines.
  lr_lines-low    = '*201'.
  lr_lines-sign   = 'E'.
  lr_lines-option = 'CP'.
  APPEND lr_lines TO lr_kostl.

  CALL FUNCTION 'BAPI_GL_ACC_GETDETAIL'
    EXPORTING
      companycode    = fu_bukrs
      glacct         = fu_hkont
    IMPORTING
      return         = return
      account_detail = account_detail.

  fc_xbilk  = account_detail-bs_account.
  fc_gvtyp  = account_detail-pl_account.

  IF fu_hkont IN gr_hkont.
    fc_copa   = 'X'.
  ENDIF.

  IF pa_bukrs EQ '8020'.
    SELECT 'I' AS sign, 'EQ' AS option, field_value2 AS low, @space AS high
      INTO TABLE @lr_control
      FROM zfi_control WHERE ztype = 'ZF62'
                         AND field_name = 'BUKRS'
                         AND field_value = @pa_bukrs.
    IF fu_kostl IN lr_kostl.
      CLEAR fc_copa.
    ENDIF.
    IF lr_control[] IS NOT INITIAL AND
       fu_hkont IN lr_control.
      fc_copa   = 'X'.
    ENDIF.
  ENDIF.

  IF pa_bukrs EQ '8210' OR
    pa_bukrs EQ '8010' OR
    pa_bukrs EQ '8360' OR
    pa_bukrs EQ '8390' OR
    pa_bukrs EQ '8040' OR
    pa_bukrs EQ '8070' OR
    pa_bukrs EQ '8180'.
    IF fu_kostl IS NOT INITIAL.
      CLEAR fc_copa.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GL_ACC_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ALPHA
*&---------------------------------------------------------------------*
FORM f_modify_alpha  USING    fu_value
                     CHANGING fc_value.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_value
    IMPORTING
      output = fc_value.
ENDFORM.                    " F_MODIFY_ALPHA
