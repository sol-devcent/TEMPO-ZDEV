*&---------------------------------------------------------------------*
*&  Include           ZHSMMM_E008F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  TYPES : BEGIN OF ty_excel,
            row   LIKE alsmex_tabline-row,
            col   LIKE alsmex_tabline-col,
            value LIKE alsmex_tabline-value,
          END OF ty_excel.

  DATA : lt_excel   TYPE STANDARD TABLE OF ty_excel,
         ls_excel   LIKE LINE OF lt_excel,
         ls_data    TYPE ty_data.

  REFRESH lt_excel. CLEAR lt_excel.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = pa_fname
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 75
      i_end_row               = 65000
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  LOOP AT lt_excel INTO ls_excel.
    CASE ls_excel-col.
      WHEN '001'.
        ls_data-prgrp   = ls_excel-value.
      WHEN '002'.
        ls_data-pgktx   = ls_excel-value.
      WHEN '003'.
        ls_data-werks   = ls_excel-value.
      WHEN '004'.
        ls_data-meins   = ls_excel-value.
      WHEN '005'.
        ls_data-omima   = ls_excel-value.
      WHEN '006'.
        ls_data-omipg   = ls_excel-value.
      WHEN '007'.
        ls_data-nrmit   = ls_excel-value.
      WHEN '008'.
        ls_data-wemit   = ls_excel-value.
      WHEN '009'.
        ls_data-memit   = ls_excel-value.
      WHEN '010'.
        ls_data-txmit   = ls_excel-value.
    ENDCASE.
    AT END OF row.
      IF ls_data-omima IS NOT INITIAL.
        APPEND ls_data TO gt_omima.
      ELSEIF ls_data-omipg IS NOT INITIAL.
        APPEND ls_data TO gt_omipg.
      ENDIF.
      CLEAR ls_data.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_F4_FILENAME
*&---------------------------------------------------------------------*
FORM f_f4_filename  CHANGING fc_fname.
  DATA : directory  TYPE string,
         filetable  TYPE filetable,
         line       TYPE LINE OF filetable,
         rc         TYPE i.

  CALL METHOD cl_gui_frontend_services=>get_temp_directory
    CHANGING
      temp_dir = directory.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title      = 'Select the files'
      initial_directory = directory
      file_filter       = '*.*'
      multiselection    = ' '
    CHANGING
      file_table        = filetable
      rc                = rc.
  IF rc = 1.
    READ TABLE filetable INDEX 1 INTO line.
    fc_fname = line-filename.
  ENDIF.
ENDFORM.                    " F_F4_FILENAME

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_data      TYPE ty_data,
         ls_xdata     TYPE ty_data,
         ls_pgmi      TYPE pgmi.

  DATA : lt_omipg     TYPE STANDARD TABLE OF ty_data,
         lt_omima     TYPE STANDARD TABLE OF ty_data.

  DATA : "lv_mode,
         lv_update.

"  lv_mode   = pa_mode. "'N'.
  lv_update = 'S'.

  lt_omipg[] = gt_omipg[].
  SORT lt_omipg BY prgrp.
  DELETE ADJACENT DUPLICATES FROM lt_omipg COMPARING prgrp.

  LOOP AT lt_omipg INTO ls_xdata.
    SELECT SINGLE *
      FROM pgmi
      INTO ls_pgmi
      WHERE prgrp = ls_xdata-prgrp
        AND werks = ls_xdata-werks.
    IF sy-subrc <> 0.
      PERFORM f_bdc_mc84 USING ls_xdata pa_mode lv_update.
    ELSE.
      LOOP AT gt_omipg INTO ls_data WHERE prgrp = ls_xdata-prgrp
                                      AND werks = ls_xdata-werks.
        SELECT SINGLE *
          FROM pgmi
          INTO ls_pgmi
          WHERE prgrp = ls_data-prgrp
            AND werks = ls_data-werks
            AND nrmit = ls_data-nrmit.
        IF sy-subrc = 0.
          DELETE TABLE gt_omipg FROM ls_data.
        ENDIF.
      ENDLOOP.
      PERFORM f_bdc_mc86 USING ls_xdata pa_mode lv_update '' 'OMIPG'.
    ENDIF.
  ENDLOOP.

  lt_omima[] = gt_omima[].
  SORT lt_omima BY prgrp.
  DELETE ADJACENT DUPLICATES FROM lt_omima COMPARING prgrp.

  CLEAR ls_data.
  LOOP AT lt_omima INTO ls_data.
    SELECT SINGLE *
      FROM pgmi
      INTO ls_pgmi
      WHERE prgrp = ls_data-prgrp
        AND werks = ls_data-werks
        AND nrmit = ls_data-nrmit.
    IF sy-subrc <> 0.
      SELECT SINGLE *
        FROM pgmi
        INTO ls_pgmi
        WHERE prgrp = ls_data-prgrp
          AND werks = ls_data-werks.
      IF sy-subrc <> 0.
        PERFORM f_bdc_mc86 USING ls_data pa_mode lv_update 'X' 'OMIMA'.
      ELSE.
        PERFORM f_bdc_mc86 USING ls_data pa_mode lv_update '' 'OMIMA'.
      ENDIF.
    ELSE.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  MESSAGE s000(zab) WITH 'Data product group already upload'.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_BDC_MC84
*&---------------------------------------------------------------------*
FORM f_bdc_mc84  USING    fs_data   TYPE ty_data
                          fu_mode fu_update.

  DATA : ls_bdcmsg     LIKE LINE OF t_bdcmsg,
         ls_data       TYPE ty_data.

  CLEAR : t_bdcdata[], t_bdcmsg[], t_bdcdata, t_bdcmsg.

  PERFORM f_bdc_data TABLES t_bdcdata USING :
       'X'  'SAPMMCP3'          '0100',
       ' '  'BDC_OKCODE'        '/00',
       ' '  'RMCP3-PRGRP'       fs_data-prgrp,
       ' '  'RMCP3-PGKTX'       fs_data-pgktx,
       ' '  'RMCP3-WERKS'       fs_data-werks,
       ' '  'RMCP3-MEINS'       fs_data-meins,
       ' '  'RMCP3-OMIPG'       'X'.

  LOOP AT gt_omipg INTO ls_data WHERE prgrp = fs_data-prgrp.
    PERFORM f_bdc_data TABLES t_bdcdata USING :
         'X'  'SAPMMCP3'          '0200',
         ' '  'BDC_CURSOR'        'RMCP3-NRMIT(01)',
         ' '  'BDC_OKCODE'        '=EINZ'.

    PERFORM f_bdc_data TABLES t_bdcdata USING :
         'X'  'SAPMMCP3'          '0200',
         ' '  'BDC_OKCODE'        '/00',
         ' '  'RMCP3-NRMIT(01)'   ls_data-nrmit,
         ' '  'RMCP3-WEMIT(01)'   ls_data-wemit,
         ' '  'RMCP3-MEMIT(01)'   ls_data-memit,
         ' '  'RMCP3-TXMIT(01)'   ls_data-txmit.
  ENDLOOP.

  PERFORM f_bdc_data TABLES t_bdcdata USING :
       'X'  'SAPMMCP3'          '0200',
       ' '  'BDC_OKCODE'        '=VERB'.

  PERFORM f_bdc_data TABLES t_bdcdata USING :
       'X'  'SAPMMCP3'          '0250',
       ' '  'BDC_OKCODE'        '=JAAA'.

  CALL TRANSACTION 'MC84' USING t_bdcdata
                          MODE fu_mode
                          UPDATE fu_update
                          MESSAGES INTO t_bdcmsg.

  READ TABLE t_bdcmsg INTO ls_bdcmsg
                      WITH KEY msgtyp = 'E'.
  IF sy-subrc = 0.
  ENDIF.
ENDFORM.                    " F_BDC_MC84

*&---------------------------------------------------------------------*
*&      Form  F_BDC_MC86
*&---------------------------------------------------------------------*
FORM f_bdc_mc86  USING    fs_data   TYPE ty_data
                          fu_mode fu_update fu_omima fu_itab.

  DATA : ls_bdcmsg     LIKE LINE OF t_bdcmsg,
         ls_data       TYPE ty_data,
         lv_count      TYPE i,
         lt_data       TYPE STANDARD TABLE OF ty_data.

  CLEAR : t_bdcdata[], t_bdcmsg[], t_bdcdata, t_bdcmsg.

  PERFORM f_bdc_data TABLES t_bdcdata USING :
       'X'  'SAPMMCP3'          '2000',
       ' '  'BDC_OKCODE'        '/00',
       ' '  'RMCP3-PRGRP'       fs_data-prgrp,
       ' '  'RMCP3-WERKS'       fs_data-werks.

  IF fu_omima IS NOT INITIAL.
    PERFORM f_bdc_data TABLES t_bdcdata USING :
         'X'  'SAPMMCP3'          '2100',
         ' '  'BDC_OKCODE'        '=ENTE',
         ' '  'RMCP3-OMIMA'       fu_omima.
  ENDIF.

  CLEAR : lt_data[].
  CASE fu_itab.
    WHEN 'OMIPG'.
      LOOP AT gt_omipg INTO ls_data WHERE prgrp = fs_data-prgrp.
        APPEND ls_data TO lt_data.
      ENDLOOP.
    WHEN 'OMIMA'.
      LOOP AT gt_omima INTO ls_data WHERE prgrp = fs_data-prgrp.
        APPEND ls_data TO lt_data.
      ENDLOOP.
  ENDCASE.

  LOOP AT lt_data INTO ls_data WHERE prgrp = fs_data-prgrp.
    PERFORM f_bdc_data TABLES t_bdcdata USING :
         'X'  'SAPMMCP3'          '0200',
         ' '  'BDC_CURSOR'        'RMCP3-NRMIT(01)',
         ' '  'BDC_OKCODE'        '=EINZ'.

    PERFORM f_bdc_data TABLES t_bdcdata USING :
         'X'  'SAPMMCP3'          '0200',
         ' '  'BDC_OKCODE'        '/00',
         ' '  'RMCP3-NRMIT(01)'   ls_data-nrmit,
         ' '  'RMCP3-WEMIT(01)'   ls_data-wemit.
    IF fu_itab = 'OMIPG'.
      PERFORM f_bdc_data TABLES t_bdcdata USING :
           ' '  'RMCP3-MEMIT(01)'   ls_data-memit,
           ' '  'RMCP3-TXMIT(01)'   ls_data-txmit.
    ENDIF.
  ENDLOOP.

  PERFORM f_bdc_data TABLES t_bdcdata USING :
       'X'  'SAPMMCP3'          '0200',
       ' '  'BDC_OKCODE'        '=VERB'.

  PERFORM f_bdc_data TABLES t_bdcdata USING :
       'X'  'SAPMMCP3'          '0250',
       ' '  'BDC_OKCODE'        '=JAAA'.

  CALL TRANSACTION 'MC86' USING t_bdcdata
                          MODE fu_mode
                          UPDATE fu_update
                          MESSAGES INTO t_bdcmsg.

  READ TABLE t_bdcmsg INTO ls_bdcmsg
                      WITH KEY msgtyp = 'E'.
  IF sy-subrc = 0.
  ENDIF.
ENDFORM.                    " F_BDC_MC86
