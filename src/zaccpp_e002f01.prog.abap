*&---------------------------------------------------------------------*
*&  Include           ZACCPP_E002F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FILENAME_F4
*&---------------------------------------------------------------------*
FORM f_filename_f4  CHANGING fc_filename.
  DATA : lv_rc  TYPE i.
  DATA : lt_file_table TYPE filetable,
         ls_file_table TYPE file_table.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title = 'Select a file'
    CHANGING
      file_table   = lt_file_table
      rc           = lv_rc.
  IF sy-subrc = 0.
    READ TABLE lt_file_table INTO ls_file_table INDEX 1.
    fc_filename = ls_file_table-filename.
  ENDIF.
ENDFORM.                    " F_FILENAME_F4

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_FR_EXCEL
*&---------------------------------------------------------------------*
FORM f_upload_fr_excel .
  TYPES : BEGIN OF ty_excel,
            row   TYPE kcd_ex_row_n,
            col   TYPE kcd_ex_col_n,
            value TYPE char50,
          END OF ty_excel.

  DATA : lt_excel TYPE STANDARD TABLE OF ty_excel,
         ls_excel LIKE LINE OF lt_excel.

  DATA : ls_upload     LIKE LINE OF gt_upload.

  IF filenm IS NOT INITIAL.
    CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
      EXPORTING
        filename                = filenm
        i_begin_col             = 1
        i_begin_row             = 3
        i_end_col               = 75
        i_end_row               = 65000
      TABLES
        intern                  = lt_excel
      EXCEPTIONS
        inconsistent_parameters = 1
        upload_ole              = 2
        OTHERS                  = 3.
  ENDIF.

  SORT lt_excel BY row col.
  LOOP AT lt_excel INTO ls_excel.
    CASE ls_excel-col.
      WHEN '0001'.
        PERFORM f_alpha_modify USING ls_excel-value
                               CHANGING ls_upload-aufnr.
      WHEN '0002'.
        ls_upload-psmng       = ls_excel-value.
      WHEN '0003'.
        ls_upload-matnr       = ls_excel-value.
      WHEN '0004'.
        ls_upload-maktx       = ls_excel-value.
      WHEN '0005'.
        ls_upload-werks       = ls_excel-value.
      WHEN '0006'.
        ls_upload-lgort       = ls_excel-value.
      WHEN '0007'.
        ls_upload-kemasan     = ls_excel-value.
      WHEN '0008'.
        ls_upload-nie         = ls_excel-value.
      WHEN '0009'.
        ls_upload-gtin        = ls_excel-value.
      WHEN '0010'.
        ls_upload-charg       = ls_excel-value.
      WHEN '0011'.
        PERFORM f_date_modify USING ls_excel-value
                              CHANGING ls_upload-vfdat.
      WHEN '0012'.
        ls_upload-senum       = ls_excel-value.
      WHEN '0013'.
        ls_upload-aggr1       = ls_excel-value.
      WHEN '0014'.
        PERFORM f_date_modify USING ls_excel-value
                              CHANGING ls_upload-packdat1.
      WHEN '0015'.
        ls_upload-aggr2       = ls_excel-value.
      WHEN '0016'.
        PERFORM f_date_modify USING ls_excel-value
                              CHANGING ls_upload-packdat2.
      WHEN '0017'.
        ls_upload-snsta       = ls_excel-value.
      WHEN '0018'.
        ls_upload-stsag       = ls_excel-value.
    ENDCASE.
    AT END OF row.
      IF ls_upload-aufnr IS NOT INITIAL.
        APPEND ls_upload TO gt_upload.
      ENDIF.
      CLEAR ls_upload.
    ENDAT.
  ENDLOOP.

  DESCRIBE TABLE gt_upload LINES gv_upload.
ENDFORM.                    " F_UPLOAD_FR_EXCEL

*&---------------------------------------------------------------------*
*&      Form  F_DATE_MODIFY
*&---------------------------------------------------------------------*
FORM f_date_modify  USING    fu_datum
                    CHANGING fc_datum.
  DATA : lv_datum TYPE sy-datum,
         lv_subrc TYPE sy-subrc,
         lv_count TYPE i.

  lv_datum  = fu_datum.
  lv_subrc  = 4.
  WHILE lv_subrc IS NOT INITIAL.
    ADD 1 TO lv_count.
    CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
      EXPORTING
        date                      = lv_datum
      EXCEPTIONS
        plausibility_check_failed = 1
        OTHERS                    = 2.

    IF sy-subrc <> 0.
      CASE lv_count.
        WHEN 1.
          CONCATENATE fu_datum(4) fu_datum+5(2) fu_datum+8(2) INTO lv_datum.
        WHEN 2.
          CONCATENATE fu_datum+6(4) fu_datum+4(2) fu_datum(2) INTO lv_datum.
        WHEN 3.
          CONCATENATE fu_datum+6(4) fu_datum+3(2) fu_datum(2) INTO lv_datum.
        WHEN 4.
          fc_datum = fu_datum.
          CLEAR lv_subrc.
      ENDCASE.
    ELSE.
      fc_datum  = lv_datum.
      CLEAR lv_subrc.
    ENDIF.
  ENDWHILE.
ENDFORM.                    " F_DATE_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_upload TYPE STANDARD TABLE OF zaccstp,
         lt_accdtm TYPE STANDARD TABLE OF zaccdtm.
  DATA: ls_accdtm  TYPE zaccdtm. "_crtd.
  DATA: ls_accdtm_crtd LIKE LINE OF gt_accdtm_crtd.
  DATA: ld_data TYPE zaccppdt002-zdata.
  DATA: ls_zaccppdt002 TYPE zaccppdt002.
  DATA: lt_zaccppdt002d TYPE STANDARD TABLE OF zaccppdt002d.
  DATA: ls_zaccppdt002d LIKE LINE OF lt_zaccppdt002d.

  DATA: lv_count TYPE i, lv_ctr TYPE i.
  CASE 'X'.
    WHEN radio3.
      IF gt_upload[] IS NOT INITIAL.
        SELECT *
          FROM zaccdtm
          INTO CORRESPONDING FIELDS OF TABLE gt_accdtm
          FOR ALL ENTRIES IN gt_upload
          WHERE matnr  = gt_upload-matnr
            AND charg  = gt_upload-charg
            AND senum  = gt_upload-senum
            AND snsta  = 'CRTD'.
        lt_accdtm[] = gt_zaccdtm[].
        SORT lt_accdtm BY aufnr.
        DELETE ADJACENT DUPLICATES FROM lt_accdtm COMPARING aufnr.
        LOOP AT lt_accdtm INTO ls_accdtm.
          ld_data = ls_accdtm-aufnr.
          SELECT SINGLE  zproses zdata MAX( zcounter ) AS zcounter INTO CORRESPONDING FIELDS OF ls_zaccppdt002 FROM zaccppdt002
            WHERE zproses = 'ZACCSEND'
              AND zdata = ld_data
              GROUP BY zproses zdata. "ls_ztdsitdt006-zdata.
          ls_zaccppdt002-zproses = 'ZACCSEND'. "p_event.
          ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
          ls_zaccppdt002-jmlrecord = lv_ctr.
          ls_zaccppdt002-message = ls_accdtm-aufnr.
          CONCATENATE 'Get data Status CRTD ( ' ls_zaccppdt002-message ')' INTO ls_zaccppdt002-message.
          ls_zaccppdt002-erdat = sy-datum.
          ls_zaccppdt002-ernam = sy-uname.
          ls_zaccppdt002-erzet = sy-uzeit.
          MODIFY zaccppdt002 FROM ls_zaccppdt002.
        ENDLOOP.
        COMMIT WORK AND WAIT.
        CLEAR: ls_zaccppdt002.
      ENDIF.

    WHEN radio2.
      IF gt_cancel[] IS NOT INITIAL.
        SELECT *
          FROM zaccdtm
          INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtm
          FOR ALL ENTRIES IN gt_cancel
          WHERE aufnr  = gt_cancel-aufnr
            AND snsta  = 'DLV'.

        lt_accdtm[] = gt_zaccdtm[].
        SORT lt_accdtm BY aufnr.
        DELETE ADJACENT DUPLICATES FROM lt_accdtm COMPARING aufnr.
        IF lt_accdtm[] IS NOT INITIAL.
          SELECT *
            FROM s501
            INTO CORRESPONDING FIELDS OF TABLE gt_s501
            FOR ALL ENTRIES IN lt_accdtm
            WHERE docat = 'ILOT'
              AND docno = lt_accdtm-aufnr.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
      lt_upload[] = gt_upload[].
      SORT lt_upload BY werks aufnr charg.
      CLEAR: gv_upload.
      CLEAR: gt_accdtm_crtd[], gt_accdtm_dlv[], gt_accdtm[].
      DELETE ADJACENT DUPLICATES FROM lt_upload COMPARING werks aufnr charg.
      IF lt_upload[] IS NOT INITIAL.
        SELECT *
          FROM zv_accdtm
          INTO CORRESPONDING FIELDS OF TABLE gt_accdtm_crtd
          FOR ALL ENTRIES IN gt_upload
          WHERE aufnr  = gt_upload-aufnr
            AND pwerk  = gt_upload-werks
            AND charg  = gt_upload-charg
            AND senum  = gt_upload-senum
            AND snsta  = 'CRTD'.
        IF gt_accdtm_crtd[] IS NOT INITIAL.
          ld_data = p_id.
          CLEAR: lv_count.
          DESCRIBE TABLE gt_accdtm_crtd LINES lv_count.
          SELECT SINGLE  zproses zdata MAX( zcounter ) AS zcounter INTO CORRESPONDING FIELDS OF ls_zaccppdt002 FROM zaccppdt002
            WHERE zproses = 'ACC_AGGR' AND
                  zdata = ld_data
              GROUP BY zproses zdata. "ls_ztdsitdt006-zdata.

          ls_zaccppdt002-zproses = 'ACC_AGGR'. "p_event.
          ls_zaccppdt002-zdata = ld_data. "p_zdata.
          ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
          ls_zaccppdt002-erdat = sy-datum.
          ls_zaccppdt002-ernam = sy-uname.
          ls_zaccppdt002-erzet = sy-uzeit.

          ls_zaccppdt002-jmlrecord = lv_count.
          ls_zaccppdt002-message = lv_count.
          CONDENSE ls_zaccppdt002-message.
          CONCATENATE 'Get data Status CRTD ( ' ls_zaccppdt002-message ')' INTO ls_zaccppdt002-message.
          MODIFY zaccppdt002 FROM ls_zaccppdt002.
          COMMIT WORK AND WAIT.
          LOOP AT gt_accdtm_crtd INTO ls_accdtm_crtd.
            ls_accdtm-snsta  = 'SEND'.
            ls_zaccppdt002d-zproses  = ls_zaccppdt002-zproses.
            ls_zaccppdt002d-zdata = ls_zaccppdt002-zdata.
            ls_zaccppdt002d-zcounter = ls_zaccppdt002-zcounter.
            ls_zaccppdt002d-matnr = ls_accdtm_crtd-matnr.
            ls_zaccppdt002d-charg = ls_accdtm_crtd-charg.
            ls_zaccppdt002d-senum  = ls_accdtm_crtd-senum.
            ls_zaccppdt002d-aufnr = ls_accdtm_crtd-aufnr.
            ls_zaccppdt002d-snsta = ls_accdtm-snsta.
            ls_zaccppdt002d-message = 'Update SNSTA dari : CRTD jadi SEND'  .
            MODIFY zaccppdt002d FROM ls_zaccppdt002d.
            TRY .
                UPDATE zaccdtm SET sendt = sy-datum
                                   snsta = ls_accdtm-snsta
                               WHERE matnr = ls_accdtm_crtd-matnr
                                 AND charg = ls_accdtm_crtd-charg
                                 AND senum = ls_accdtm_crtd-senum.
              CATCH cx_sy_dynamic_osql_error.
            ENDTRY.
            IF sy-subrc = 0.
              ADD 1 TO lv_count.
            ENDIF.
          ENDLOOP.
          COMMIT WORK AND WAIT.
        ENDIF.
        SELECT *
          FROM zv_accdtm
          INTO CORRESPONDING FIELDS OF TABLE gt_accdtm
          FOR ALL ENTRIES IN gt_upload
          WHERE aufnr  = gt_upload-aufnr
            AND pwerk  = gt_upload-werks
            AND charg  = gt_upload-charg
            AND senum  = gt_upload-senum
            AND snsta  = 'SEND'.
        SELECT *
          FROM zv_accdtm
          INTO CORRESPONDING FIELDS OF TABLE gt_accdtm_dlv
          FOR ALL ENTRIES IN gt_upload
          WHERE aufnr  = gt_upload-aufnr
            AND pwerk  = gt_upload-werks
            AND charg  = gt_upload-charg
            AND senum  = gt_upload-senum
            AND snsta  = 'DLV'.
        IF gt_accdtm[] IS NOT INITIAL.
          CLEAR: lv_count.
          DESCRIBE TABLE gt_accdtm LINES lv_count.
          ld_data = p_id.
          SELECT SINGLE  zproses zdata MAX( zcounter ) AS zcounter INTO CORRESPONDING FIELDS OF ls_zaccppdt002 FROM zaccppdt002
            WHERE zproses = 'ACC_AGGR'
              AND zdata = ld_data
              GROUP BY zproses zdata. "ls_ztdsitdt006-zdata.
          ls_zaccppdt002-zproses = 'ACC_AGGR'. "p_event.
          ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
          ls_zaccppdt002-jmlrecord = lv_count.
          ls_zaccppdt002-message = lv_count.
          CONDENSE ls_zaccppdt002-message.
          CONCATENATE 'Berhasil Get ZV_ACCDTM status SEND ( ' ls_zaccppdt002-message ' )' INTO ls_zaccppdt002-message.
          ls_zaccppdt002-erdat = sy-datum.
          ls_zaccppdt002-ernam = sy-uname.
          ls_zaccppdt002-erzet = sy-uzeit.
          MODIFY zaccppdt002 FROM ls_zaccppdt002.
        ENDIF.
        IF gt_accdtm_dlv[] IS NOT INITIAL.
          CLEAR: lv_count.
          DESCRIBE TABLE gt_accdtm_dlv LINES lv_count.
          ld_data = p_id.
          SELECT SINGLE  zproses zdata MAX( zcounter ) AS zcounter INTO CORRESPONDING FIELDS OF ls_zaccppdt002 FROM zaccppdt002
            WHERE zproses = 'ACC_AGGR'
              AND zdata = ld_data
              GROUP BY zproses zdata. "ls_ztdsitdt006-zdata.
          ls_zaccppdt002-zproses = 'ACC_AGGR'. "p_event.
          ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
          ls_zaccppdt002-jmlrecord = lv_count.
          ls_zaccppdt002-message = lv_count.
          CONDENSE  ls_zaccppdt002-message.
          CONCATENATE 'Berhasil Get ZV_ACCDTM status DLV ( ' ls_zaccppdt002-message ' )' INTO ls_zaccppdt002-message.
          ls_zaccppdt002-erdat = sy-datum.
          ls_zaccppdt002-ernam = sy-uname.
          ls_zaccppdt002-erzet = sy-uzeit.
          MODIFY zaccppdt002 FROM ls_zaccppdt002.
        ENDIF.
        PERFORM f_batch_detail.
        PERFORM f_get_het.
      ENDIF.

      SORT lt_upload BY aufnr.
      DELETE ADJACENT DUPLICATES FROM lt_upload COMPARING aufnr.
      IF lt_upload[] IS NOT INITIAL.
        SELECT *
          FROM s501
          INTO CORRESPONDING FIELDS OF TABLE gt_s501
          FOR ALL ENTRIES IN lt_upload
          WHERE docat = 'ILOT'
            AND docno = lt_upload-aufnr.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  FIELD-SYMBOLS <fs>   TYPE any.

  DATA : lt_proc TYPE STANDARD TABLE OF zaccstp,
         ls_proc LIKE LINE OF lt_proc.

  DATA : ls_upload LIKE LINE OF gt_upload,
         ls_accdtm LIKE LINE OF gt_accdtm,
         ls_mch1   LIKE LINE OF gt_mch1,
         ls_t001k  LIKE LINE OF gt_t001k,
         ls_a989   LIKE LINE OF gt_a989,
         ls_konp   LIKE LINE OF gt_konp,
         ls_mara   LIKE LINE OF gt_mara.

  DATA : ls_eaccdtm   LIKE LINE OF gt_eaccdtm.

  DATA : BEGIN OF varkey,
           aufnr TYPE zaccdtm-aufnr,
         END OF varkey.

  DATA: ld_data TYPE zaccppdt002-zdata.
  DATA: ls_zaccppdt002 TYPE zaccppdt002.

  DATA: lv_count TYPE i, lv_ctr TYPE i.


  SORT gt_s501 BY docno posnr DESCENDING.
  lt_proc[] = gt_upload[].
  SORT lt_proc BY aufnr.
  DELETE ADJACENT DUPLICATES FROM lt_proc COMPARING aufnr.

  LOOP AT lt_proc INTO ls_proc.
    varkey-aufnr    = ls_proc-aufnr.
    rstable-varkey  = varkey.

    CALL FUNCTION 'ENQUEUE_E_TABLE'
      EXPORTING
        tabname        = 'ZACCDTM'
        varkey         = rstable-varkey
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.

    IF sy-subrc = 0.
      LOOP AT gt_upload INTO ls_upload WHERE aufnr = ls_proc-aufnr.
        ASSIGN COMPONENT 'AUFNR' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_upload-aufnr.
        ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_upload-maktx.
        ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_upload-werks.
        ASSIGN COMPONENT 'LGORT' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_upload-lgort.
        ASSIGN COMPONENT 'SENUM' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_upload-senum.
        ASSIGN COMPONENT 'AGGR1' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_upload-aggr1.
        ASSIGN COMPONENT 'PACKDAT1' OF STRUCTURE <fs_ltop> TO <fs>.
        PERFORM f_date_modify USING ls_upload-packdat1
                              CHANGING <fs>.
        ASSIGN COMPONENT 'AGGR2' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_upload-aggr2.
        ASSIGN COMPONENT 'PACKDAT2' OF STRUCTURE <fs_ltop> TO <fs>.
        PERFORM f_date_modify USING ls_upload-packdat2
                              CHANGING <fs>.
        ASSIGN COMPONENT 'KEMASAN' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_upload-kemasan.

        CLEAR ls_accdtm.
        SORT gt_accdtm BY aufnr pwerk charg senum.
        READ TABLE gt_accdtm INTO ls_accdtm
                             WITH KEY aufnr = ls_upload-aufnr
                                      pwerk = ls_upload-werks
                                      charg = ls_upload-charg
*                                  nie   = ls_upload-nie
                                      senum = ls_upload-senum.
        IF sy-subrc = 0.
          ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_ltop> TO <fs>.
          <fs> = ls_accdtm-matnr.
          ASSIGN COMPONENT 'CHARG' OF STRUCTURE <fs_ltop> TO <fs>.
          <fs> = ls_accdtm-charg.
          ASSIGN COMPONENT 'NIE' OF STRUCTURE <fs_ltop> TO <fs>.
          <fs> = ls_accdtm-nie.
*          ASSIGN COMPONENT 'GTIN' OF STRUCTURE <fs_ltop> TO <fs>.
*          <fs> = ls_accdtm-gtin.

          ASSIGN COMPONENT 'STSPR' OF STRUCTURE <fs_ltop> TO <fs>.
          <fs> = ls_upload-stspr.
          ASSIGN COMPONENT 'STSAG' OF STRUCTURE <fs_ltop> TO <fs>.
          <fs> = ls_upload-stsag.
          ASSIGN COMPONENT 'STSAC' OF STRUCTURE <fs_ltop> TO <fs>.
          <fs> = ls_upload-stsac.

          CLEAR ls_accdtm-snsta.
          CASE ls_upload-stsag.
            WHEN '0'.
              ls_accdtm-snsta = 'NTUS'.
            WHEN '1'.
              ls_accdtm-snsta = 'DLV'.
            WHEN '2'.
              ls_accdtm-snsta = 'RTS'.
            WHEN '3'.
              ls_accdtm-snsta = 'RJCT'.
          ENDCASE.

          ASSIGN COMPONENT 'SNSTA' OF STRUCTURE <fs_ltop> TO <fs>.
          <fs> = ls_accdtm-snsta.

          MODIFY gt_accdtm FROM ls_accdtm
                           TRANSPORTING snsta
                           WHERE matnr = ls_upload-matnr
                             AND charg = ls_upload-charg
                             AND senum = ls_upload-senum.

          ASSIGN COMPONENT 'PSMNG' OF STRUCTURE <fs_ltop> TO <fs>.
          <fs> = ls_upload-psmng.
        ELSE.
          SORT gt_accdtm BY aufnr pwerk charg senum.
          READ TABLE gt_accdtm_dlv INTO ls_accdtm
                               WITH KEY aufnr = ls_upload-aufnr
                                        pwerk = ls_upload-werks
                                        charg = ls_upload-charg
*                                  nie   = ls_upload-nie
                                        senum = ls_upload-senum.
          IF sy-subrc NE 0.
            PERFORM f_error_message USING ls_upload.
          ENDIF.
          CONTINUE.
        ENDIF.

        CLEAR ls_mch1.
        READ TABLE gt_mch1 INTO ls_mch1
                           WITH KEY matnr = ls_accdtm-matnr
                                    charg = ls_accdtm-charg.
        IF sy-subrc = 0.
          IF ls_upload-vfdat = ls_mch1-vfdat.
            ASSIGN COMPONENT 'VFDAT' OF STRUCTURE <fs_ltop> TO <fs>.
            <fs> = ls_upload-vfdat.
          ENDIF.
        ENDIF.

        CLEAR ls_mara.
        READ TABLE gt_mara INTO ls_mara
                           WITH KEY matnr = ls_accdtm-matnr.
        IF sy-subrc = 0.
          ASSIGN COMPONENT 'AMEIN' OF STRUCTURE <fs_ltop> TO <fs>.
          <fs> = ls_mara-meins.
        ENDIF.

        PERFORM f_prepare_posting USING ls_upload ls_accdtm.

        APPEND <fs_ltop> TO <fs_top>.
        CLEAR <fs_ltop>.
      ENDLOOP.

      IF gv_backg IS NOT INITIAL.
        READ TABLE gt_eaccdtm INTO ls_eaccdtm
                              WITH KEY aufnr = ls_proc-aufnr.
        IF sy-subrc <> 0.
          IF gt_accdtm[] IS NOT INITIAL.
            PERFORM f_posting_data.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      WRITE: / 'Gagal Lock data : ', ls_proc-aufnr.
      ld_data = p_id.
      CLEAR: lv_count.
          DESCRIBE TABLE gt_accdtm LINES lv_count.

      SELECT SINGLE  zproses zdata MAX( zcounter ) AS zcounter INTO CORRESPONDING FIELDS OF ls_zaccppdt002 FROM zaccppdt002
        WHERE zproses = 'ACC_AGGR' AND
              zdata = ld_data
          GROUP BY zproses zdata. "ls_ztdsitdt006-zdata.

      ls_zaccppdt002-zproses = 'ACC_AGGR'. "p_event.
      ls_zaccppdt002-zdata = ld_data. "p_zdata.
      ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
      ls_zaccppdt002-erdat = sy-datum.
      ls_zaccppdt002-ernam = sy-uname.
      ls_zaccppdt002-erzet = sy-uzeit.
      "ls_proc-aufnr
      ls_zaccppdt002-jmlrecord = lv_count.
      ls_zaccppdt002-message = rstable-varkey.
      CONDENSE ls_zaccppdt002-message.
      CONCATENATE 'Gagal Lock Table ZACCDTM (' ls_proc-aufnr ') : ' ls_zaccppdt002-message  INTO ls_zaccppdt002-message.
      MODIFY zaccppdt002 FROM ls_zaccppdt002.
      COMMIT WORK AND WAIT.
    ENDIF.
    CLEAR : gt_accdtd[], gt_accdta[], gt_accdtd, gt_accdta,
            gs_header, gt_item[].
  ENDLOOP.
  IF gt_accdtm_dlv[] IS NOT INITIAL.
    PERFORM f_resend_posting_data.
  ENDIF.

  IF gt_eaccdtm[] IS NOT INITIAL.
    PERFORM f_write_error.
  ENDIF.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CALL SCREEN 100.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  DATA : fcode         TYPE TABLE OF sy-ucomm,
         lv_title(100).

  lv_title  = 'Posting'.

  SET PF-STATUS 'PF_STATUS' EXCLUDING fcode.
  SET TITLEBAR 'TITLE' WITH lv_title.

  PERFORM f_excluding_toolbar USING :
    '&INFO' 'T',
    '&GRAPH' 'T',

    '&INFO' 'B',
    '&GRAPH' 'B'.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_EXCLUDING_TOOLBAR
*&---------------------------------------------------------------------*
FORM f_excluding_toolbar  USING    fu_attribute fu_pos.
  DATA : ls_exclude   TYPE ui_func.

  ls_exclude = fu_attribute.
  CASE fu_pos.
    WHEN 'T'.
      APPEND ls_exclude TO gs_exclude_t.
    WHEN 'B'.
      APPEND ls_exclude TO gs_exclude_b.
  ENDCASE.
  CLEAR ls_exclude.
ENDFORM.                    " F_EXCLUDING_TOOLBAR

*&---------------------------------------------------------------------*
*&      Module  DOCKING_AND_SPLIT_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE docking_and_split_container OUTPUT.
  DATA : lv_contname(20).

  lv_contname   = 'CC_SILVER'.

  IF g_maincont IS INITIAL.
    CREATE OBJECT g_maincont
      EXPORTING
        container_name              = lv_contname
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_splitter
      EXPORTING
        parent  = g_maincont
        rows    = 1
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_top.

*    CALL METHOD g_splitter->get_container
*      EXPORTING
*        row       = 2
*        column    = 1
*      RECEIVING
*        container = g_bottom.
  ENDIF.
ENDMODULE.                 " DOCKING_AND_SPLIT_CONTAINER  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TOP_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE top_alv OUTPUT.
  IF g_tgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_tgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_top.

    PERFORM f_build_layout USING 'T'.
    PERFORM f_build_sort USING 'T'.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_clickt
                event_receiver->handle_toolbart
                event_receiver->handle_menu_buttont
                event_receiver->handle_user_commandt FOR g_tgrid.

    CALL METHOD g_tgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude_t
      CHANGING
        it_sort              = gt_main_sort[]
        it_outtab            = <fs_top>[]
        it_fieldcatalog      = gt_fieldcat_t[].
  ELSE.
    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
ENDMODULE.                 " TOP_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refresh.
  IF fu_refresh IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    IF g_tgrid IS NOT INITIAL.
      CALL METHOD g_tgrid->refresh_table_display
        EXPORTING
          is_stable = gs_stable.
    ENDIF.

    IF g_bgrid IS NOT INITIAL.
      CALL METHOD g_bgrid->refresh_table_display
        EXPORTING
          is_stable = gs_stable.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout  USING    fu_pos.
*  gs_layout_alv-box_fname           = 'CHECK'.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
  gs_layout_alv-no_rowmark          = selected.
*  gs_layout_alv-stylefname          = 'STYLE'.
*  gs_layout_alv-ctab_fname          = 'COLOR'.
  gs_layout_alv-cwidth_opt          = selected.
  CASE fu_pos.
    WHEN 'T'.
      gs_layout_alv-zebra               = selected.
      gs_layout_alv-no_toolbar          = space.
    WHEN 'B'.
      gs_layout_alv-zebra               = selected.
      gs_layout_alv-no_toolbar          = space.
  ENDCASE.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort  USING    fu_sort.
  CLEAR gt_main_sort.

  CASE fu_sort.
    WHEN 'T'.
    WHEN 'B'.
*      gt_main_sort-spos      = 1.
*      gt_main_sort-fieldname = ''.
*      gt_main_sort-up        = selected.
*      APPEND gt_main_sort.
*      CLEAR gt_main_sort.
  ENDCASE.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_zaccdtu LIKE LINE OF gt_zaccdtu,
         lv_procid  TYPE zaccdtu-procid,
         lv_procid1 TYPE zaccdtu-procid.

  SELECT *
    FROM zaccdtu
    INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtu
    WHERE company = 'POLYMARK'.

  CASE 'X'.
    WHEN radio1.
      lv_procid  = 6. "2.
      lv_procid1 = 4.
    WHEN radio2.
      lv_procid  = 5.
      lv_procid1 = 4.
    WHEN radio3.
      lv_procid  = 3.
  ENDCASE.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = lv_procid.
  IF sy-subrc = 0.
    gv_uri  =  ls_zaccdtu-uri.
  ENDIF.

  IF lv_procid1 IS NOT INITIAL.
    READ TABLE gt_zaccdtu INTO ls_zaccdtu
                          WITH KEY procid = lv_procid1.
    IF sy-subrc = 0.
      gv_uri1  =  ls_zaccdtu-uri.
    ENDIF.
  ENDIF.

  SELECT *
    FROM t001k
    INTO CORRESPONDING FIELDS OF TABLE gt_t001k.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CRT_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_crt_dyn_int_table  USING    fu_pos.
  DATA : fname        TYPE string,
         title        TYPE string,
         lt_dyn_table TYPE REF TO data,
         ls_line      TYPE REF TO data.

  CASE fu_pos.
    WHEN 'T'.
      PERFORM f_dyn_int_table USING :
        fu_pos 'AUFNR' '' '' '' '' '' '' 'AUFNR' 'AFPO' '' '' '' '' '' '' '' 'X',
        fu_pos 'PSMNG' '' '' '' '' 'AMEIN' '' 'PSMNG' 'AFPO' 'Order Qty' '' ''
        '' '' '' '' 'X',
        fu_pos 'AMEIN' '' '' '' '' '' '' 'AMEIN' 'AFPO' '' '' '' '' '' '' '' 'X',
        fu_pos 'MATNR' '' '' '' '' '' '' 'MATNR' 'AFPO' '' '' '' '' '' '' '' 'X',
        fu_pos 'MAKTX' '' '' '' '' '' '' 'MAKTX' 'MAKT' '' '' '' '' '' '' '' 'X',
        fu_pos 'WERKS' '' '' '' '' '' '' 'DWERK' 'AFPO' '' '' '' '' '' '' '' 'X',
        fu_pos 'LGORT' '' '' '' '' '' '' 'LGORT' 'AFPO' '' '' '' '' '' '' '' 'X',
        fu_pos 'KEMASAN' '' '' '' '' '' '' 'KEMASAN' 'ZTSPMMDT002' '' '' '' '' '' '' '' '',
        fu_pos 'NIE' '' '' '' '' '' '' 'NIE' 'ZTSPMMDT002' '' '' '' '' '' '' '' '',
*        fu_pos 'GTIN' '' '' '' '' '' '' '' '' 'GTIN' '' '' '' '' '' '' '',
        fu_pos 'CHARG' '' '' '' '' '' '' 'CHARG' 'AFPO' '' '' '' '' '' '' '' '',
        fu_pos 'VFDAT' '' '' '' '' '' '' 'VFDAT' 'MCH1' '' '' '' '' '' '' '' '',
        fu_pos 'SENUM' '' '' '' '' '' '' 'SENUM' 'ZACCDTM' '' '' '' '' '' '' '' '',
        fu_pos 'AGGR1' '' '' '' '' '' '' 'AGGR1' 'ZACCDTA' '' '' '' '' '' '' '' '',
        fu_pos 'PACKDAT1' '' '' '' '' '' '' 'PACKDAT1' 'ZACCDTA' '' '' '' '' '' '' '' '',
        fu_pos 'AGGR2' '' '' '' '' '' '' 'AGGR2' 'ZACCDTA' '' '' '' '' '' '' '' '',
        fu_pos 'PACKDAT2' '' '' '' '' '' '' 'PACKDAT2' 'ZACCDTA' '' '' '' '' '' '' '' '',
        fu_pos 'SNSTA' '' '' '' '' '' '' 'SNSTA' 'ZACCDTM' '' '' '' '' '' '' '' '',
        fu_pos 'STSPR' '' '' '' '' '' '' 'STSPR' 'ZACCSTP' '' '' '' '' '' '' '' '',
        fu_pos 'STSAG' '' '' '' '' '' '' 'STSAG' 'ZACCSTP' '' '' '' '' '' '' '' '',
        fu_pos 'STSAC' '' '' '' '' '' '' 'STSAC' 'ZACCSTP' '' '' '' '' '' '' '' ''.

      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog           = gt_fieldcat_t
          i_length_in_byte          = 'X'
        IMPORTING
          ep_table                  = lt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.
      IF sy-subrc EQ 0.
        ASSIGN lt_dyn_table->* TO <fs_top>.
        CREATE DATA ls_line LIKE LINE OF <fs_top>.
        ASSIGN ls_line->* TO <fs_ltop>.
      ENDIF.

    WHEN 'B'.
      PERFORM f_dyn_int_table USING :
        fu_pos 'KUNNR' '' '' '' '' '' '' 'KUNNR' 'KNA1' '' '' '' '' '' '' '' 'X'.

      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog           = gt_fieldcat_b
          i_length_in_byte          = 'X'
        IMPORTING
          ep_table                  = lt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.
      IF sy-subrc EQ 0.
        ASSIGN lt_dyn_table->* TO <fs_bottom>.
        CREATE DATA ls_line LIKE LINE OF <fs_bottom>.
        ASSIGN ls_line->* TO <fs_lbottom>.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_CRT_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_int_table  USING    fu_pos fu_fieldname fu_tabname
                               fu_currency fu_cfieldname fu_quantity
                               fu_qfieldname fu_checkbox fu_ref_field
                               fu_ref_table fu_coltext fu_outputlen
                               fu_no_out fu_edit fu_tech fu_just fu_icon
                               fu_fix.
  DATA : ls_dyn_fcat       TYPE lvc_s_fcat.

  PERFORM f_isi_judul USING fu_coltext '' '' ''
                      CHANGING ls_dyn_fcat-reptext ls_dyn_fcat-scrtext_l
                               ls_dyn_fcat-scrtext_m ls_dyn_fcat-scrtext_s.

  ls_dyn_fcat-fieldname   = fu_fieldname.
  ls_dyn_fcat-tabname     = fu_tabname.
  ls_dyn_fcat-currency    = fu_currency.
  ls_dyn_fcat-cfieldname  = fu_cfieldname.
  ls_dyn_fcat-quantity    = fu_quantity.
  ls_dyn_fcat-qfieldname  = fu_qfieldname.
  ls_dyn_fcat-checkbox    = fu_checkbox.
  ls_dyn_fcat-ref_field   = fu_ref_field.
  ls_dyn_fcat-ref_table   = fu_ref_table.
  ls_dyn_fcat-coltext     = fu_coltext.
  ls_dyn_fcat-edit        = fu_edit.
  ls_dyn_fcat-outputlen   = fu_outputlen.
  ls_dyn_fcat-no_out      = fu_no_out.
  ls_dyn_fcat-tech        = fu_tech.
  ls_dyn_fcat-just        = fu_just.
  ls_dyn_fcat-fix_column  = fu_fix.
  ls_dyn_fcat-icon        = fu_icon.
  CASE fu_pos.
    WHEN 'T'.
      APPEND ls_dyn_fcat TO gt_fieldcat_t.
    WHEN 'B'.
      APPEND ls_dyn_fcat TO gt_fieldcat_b.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ls_dyn_fcat.
ENDFORM.                    " F_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_ISI_JUDUL
*&---------------------------------------------------------------------*
FORM f_isi_judul  USING    fu_coltext fu_l fu_m fu_s
                  CHANGING fc_reptext fc_scrtext_l fc_scrtext_m fc_scrtext_s.

  fc_reptext    = fu_coltext.
  fc_scrtext_l  = fu_coltext.
  fc_scrtext_m  = fu_coltext.
  fc_scrtext_s  = fu_coltext.
ENDFORM.                    " F_ISI_JUDUL

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  CASE ok_code.
    WHEN '&POS'.
      PERFORM f_posting_data.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .
  DATA: ld_data        TYPE zaccppdt002-zdata,
        ls_zaccppdt002 TYPE zaccppdt002,
        ls_zaccppdt001 TYPE zaccppdt001.
  DATA: lv_data  TYPE zaccppdt001-zdata. "

  DATA : lt_xitem TYPE STANDARD TABLE OF bapi2017_gm_item_create,
         ls_xitem LIKE LINE OF lt_xitem,
         ls_item  LIKE LINE OF gt_item.

  DATA : goodsmvt_header  TYPE bapi2017_gm_head_01,
         goodsmvt_code    TYPE bapi2017_gm_code VALUE '02',
         goodsmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
         return           TYPE STANDARD TABLE OF bapiret2,
         materialdocument TYPE bapi2017_gm_head_ret-mat_doc,
         matdocumentyear  TYPE bapi2017_gm_head_ret-doc_year.

  DATA : ls_return              LIKE LINE OF return.

  goodsmvt_header-pstng_date       = gs_header-pstng_date.
  goodsmvt_header-doc_date         = gs_header-doc_date.
*  goodsmvt_header-header_txt       = mkpf-bktxt.
  goodsmvt_header-ref_doc_no       = gs_header-ref_doc_no.
  goodsmvt_header-pr_uname         = gs_header-pr_uname.
  goodsmvt_header-ver_gr_gi_slip   = gs_header-ver_gr_gi_slip.
  goodsmvt_header-ver_gr_gi_slipx  = gs_header-ver_gr_gi_slipx.

  "  DESCRIBE TABLE gt_upload LINES gv_upload.

  lt_xitem[] = gt_item[].
  SORT lt_xitem BY plant.
  DELETE ADJACENT DUPLICATES FROM lt_xitem COMPARING plant.
  LOOP AT lt_xitem INTO ls_xitem.
    LOOP AT gt_item INTO ls_item WHERE plant = ls_xitem-plant.
      APPEND ls_item TO goodsmvt_item.
      CLEAR ls_item.
    ENDLOOP.

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header  = goodsmvt_header
        goodsmvt_code    = goodsmvt_code
      IMPORTING
        materialdocument = materialdocument
        matdocumentyear  = matdocumentyear
      TABLES
        goodsmvt_item    = goodsmvt_item
        return           = return.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    WRITE : / 'Jumlah SN : ', gv_upload.
    DESCRIBE TABLE gt_accdtm LINES gv_upload.
    ld_data = p_id.

    SELECT SINGLE  zproses zdata MAX( zcounter ) AS zcounter INTO CORRESPONDING FIELDS OF ls_zaccppdt002 FROM zaccppdt002
      WHERE zproses = 'ACC_AGGR' AND
            zdata = ld_data
        GROUP BY zproses zdata. "ls_ztdsitdt006-zdata.

    ls_zaccppdt002-zproses = 'ACC_AGGR'. "p_event.
    ls_zaccppdt002-zdata = ld_data. "p_zdata.
    IF ls_zaccppdt002-zcounter IS NOT INITIAL.
      ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
    ELSE.
      ls_zaccppdt002-zcounter = 0.
    ENDIF.
    ls_zaccppdt002-erdat = sy-datum.
    ls_zaccppdt002-ernam = sy-uname.
    ls_zaccppdt002-erzet = sy-uzeit.

    ls_zaccppdt002-jmlrecord = gv_upload.
    ls_zaccppdt002-message = 'GR Data'.
    MODIFY zaccppdt002 FROM ls_zaccppdt002.
    COMMIT WORK AND WAIT.

    IF materialdocument IS NOT INITIAL.
      CALL FUNCTION 'DEQUEUE_E_TABLE'
        EXPORTING
          tabname = 'ZACCDTM'
          varkey  = rstable-varkey.
      PERFORM f_save_data TABLES goodsmvt_item
                          USING gs_header-pstng_date
                                materialdocument matdocumentyear.
      ls_zaccppdt002-status = 'S'.
      ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
      ls_zaccppdt002-erdat = sy-datum.
      ls_zaccppdt002-ernam = sy-uname.
      ls_zaccppdt002-erzet = sy-uzeit.
      CONCATENATE 'Data already posted' materialdocument INTO ls_zaccppdt002-message.
      MODIFY zaccppdt002 FROM ls_zaccppdt002.
      MESSAGE s000(zab) WITH 'Data already posted' materialdocument.
    ELSE.
      ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
      ls_zaccppdt002-erdat = sy-datum.
      ls_zaccppdt002-ernam = sy-uname.
      ls_zaccppdt002-erzet = sy-uzeit.
      "CONCATENATE 'Data already posted' materialdocument INTO
      ls_zaccppdt002-message = 'Gagal GR Data'.
      MODIFY zaccppdt002 FROM ls_zaccppdt002.
      LOOP AT return INTO ls_return WHERE type = 'E'.
        WRITE: / ls_return-message.
        ls_zaccppdt002-status = 'E'.
        CALL FUNCTION 'FORMAT_MESSAGE'
          EXPORTING
            id        = ls_return-id
            lang      = sy-langu
            no        = ls_return-number
            v1        = ls_return-message_v1
            v2        = ls_return-message_v2
            v3        = ls_return-message_v3
            v4        = ls_return-message_v4
          IMPORTING
            msg       = ls_return-message
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.
        ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
        ls_zaccppdt002-message = ls_return-message.
        ls_zaccppdt002-erdat = sy-datum.
        ls_zaccppdt002-ernam = sy-uname.
        ls_zaccppdt002-erzet = sy-uzeit.
        MODIFY zaccppdt002 FROM ls_zaccppdt002.
        lv_data = p_id.
        UPDATE zaccppdt001 SET status = 'E' WHERE zdata = lv_data.
        "        COMMIT WORK AND WAIT.
      ENDLOOP.
      COMMIT WORK AND WAIT.
    ENDIF.
    CLEAR : goodsmvt_item[], return[], materialdocument, matdocumentyear.
  ENDLOOP.
*  LEAVE TO SCREEN 0.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_POSTING
*&---------------------------------------------------------------------*
FORM f_prepare_posting  USING    fs_upload   LIKE LINE OF gt_upload
                                 fs_accdtm   LIKE LINE OF gt_accdtm.

  DATA : ls_accdtd LIKE LINE OF gt_accdtd,
         ls_accdta LIKE LINE OF gt_accdta.

  IF gs_header IS INITIAL.
    gs_header-pstng_date       = sy-datum.
    gs_header-doc_date         = sy-datum.
    gs_header-ref_doc_no       = fs_accdtm-aufnr.
    gs_header-pr_uname         = sy-uname.
    gs_header-ver_gr_gi_slip   = '3'.
    gs_header-ver_gr_gi_slipx  = 'X'.
  ENDIF.

  IF fs_accdtm-snsta  = 'DLV'.
    PERFORM f_add_item USING fs_upload fs_accdtm.
  ENDIF.

  ls_accdtd-docat   = 'ILOT'.
  ls_accdtd-docno   = fs_upload-aufnr.
  ls_accdtd-posnr   = fs_accdtm-posnr.
  ls_accdtd-senum   = fs_upload-senum.
  ls_accdtd-scandt  = sy-datum.
  ls_accdtd-ernam   = sy-uname.
  ls_accdtd-time    = sy-uzeit.
  APPEND ls_accdtd TO gt_accdtd.
  CLEAR ls_accdtd.

  ls_accdta-matnr     = fs_accdtm-matnr.
  ls_accdta-charg     = fs_upload-charg.
  ls_accdta-senum     = fs_upload-senum.
  ls_accdta-aggr1     = fs_upload-aggr1.
  ls_accdta-packdat1  = fs_upload-packdat1.
  IF fs_upload-aggr1 IS NOT INITIAL.
    ls_accdta-zact1     = selected.
  ENDIF.
  ls_accdta-aggr2     = fs_upload-aggr2.
  ls_accdta-packdat2  = fs_upload-packdat2.
  IF fs_upload-aggr2 IS NOT INITIAL.
    ls_accdta-zact2     = selected.
  ENDIF.
  APPEND ls_accdta TO gt_accdta.
  CLEAR ls_accdta.
ENDFORM.                    " F_PREPARE_POSTING

*&---------------------------------------------------------------------*
*&      Form  F_ALPHA_MODIFY
*&---------------------------------------------------------------------*
FORM f_alpha_modify  USING    fu_aufnr
                     CHANGING fc_aufnr.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_aufnr
    IMPORTING
      output = fc_aufnr.
ENDFORM.                    " F_ALPHA_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_BATCH_DETAIL
*&---------------------------------------------------------------------*
FORM f_batch_detail .
  DATA : lt_accdtm TYPE STANDARD TABLE OF zv_accdtm,
         ls_accdtm LIKE LINE OF lt_accdtm.

  lt_accdtm[] = gt_accdtm[].
  SORT lt_accdtm BY matnr charg.
  DELETE ADJACENT DUPLICATES FROM lt_accdtm COMPARING matnr charg.
  IF lt_accdtm[] IS NOT INITIAL.
    SELECT *
      FROM mch1
      INTO CORRESPONDING FIELDS OF TABLE gt_mch1
      FOR ALL ENTRIES IN lt_accdtm
      WHERE matnr = lt_accdtm-matnr
        AND charg = lt_accdtm-charg
        AND lvorm = space.
  ENDIF.

  SORT lt_accdtm BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_accdtm COMPARING matnr.
  IF lt_accdtm[] IS NOT INITIAL.
    SELECT *
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE gt_mara
      FOR ALL ENTRIES IN lt_accdtm
      WHERE matnr = lt_accdtm-matnr.
  ENDIF.
ENDFORM.                    " F_BATCH_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_GET_HET
*&---------------------------------------------------------------------*
FORM f_get_het .
  DATA : lt_accdtm   TYPE STANDARD TABLE OF zv_accdtm,
         ls_accdtm   LIKE LINE OF gt_accdtm,
         lt_a989_key TYPE STANDARD TABLE OF ty_a989_key,
         ls_a989_key LIKE LINE OF lt_a989_key,
         ls_t001k    LIKE LINE OF gt_t001k.

  lt_accdtm[] = gt_accdtm[].
  SORT lt_accdtm BY pwerk.
  DELETE ADJACENT DUPLICATES FROM lt_accdtm COMPARING pwerk.

  LOOP AT lt_accdtm INTO ls_accdtm.
    READ TABLE gt_t001k INTO ls_t001k
                        WITH KEY bwkey = ls_accdtm-pwerk.
    IF sy-subrc = 0.
      ls_a989_key-vkorg   = ls_t001k-bukrs.
      ls_a989_key-matnr   = ls_accdtm-matnr.
      APPEND ls_a989_key TO lt_a989_key.
      CLEAR ls_a989_key.
    ENDIF.
  ENDLOOP.

  IF lt_a989_key[] IS NOT INITIAL.
    SELECT *
      FROM a989
      INTO CORRESPONDING FIELDS OF TABLE gt_a989
      FOR ALL ENTRIES IN lt_a989_key
      WHERE kappl = 'V'
        AND kschl = 'ZHET'
        AND vkorg = lt_a989_key-vkorg
        AND matnr = lt_a989_key-matnr
        AND datab <= sy-datum
        AND datbi >= sy-datum.

    IF gt_a989[] IS NOT INITIAL.
      SELECT *
        FROM konp
        INTO CORRESPONDING FIELDS OF TABLE gt_konp
        FOR ALL ENTRIES IN gt_a989
        WHERE knumh = gt_a989-knumh.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_HET

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data  TABLES   ft_item    STRUCTURE bapi2017_gm_item_create
                  USING    fu_budat fu_mblnr fu_mjahr.
  DATA : ls_item   LIKE LINE OF gt_item,
         lt_s501   TYPE STANDARD TABLE OF s501,
         ls_s501   LIKE LINE OF lt_s501,
         ls_accdtm LIKE LINE OF gt_accdtm,
         ls_accdtd LIKE LINE OF gt_accdtd,
         lv_posnr  TYPE s501-posnr.

  DATA : lt_request_header TYPE STANDARD TABLE OF sbcheader.

  DATA : lv_json    TYPE string.
  DATA: lv_ctr TYPE i.
  DATA: ld_data        TYPE zaccppdt002-zdata,
        ls_zaccppdt002 TYPE zaccppdt002.

  LOOP AT ft_item INTO ls_item.
    ls_s501-spmon   = fu_budat(6).
    ls_s501-docat   = 'ILOT'.
    ls_s501-docno   = ls_item-orderid.

    READ TABLE gt_s501 INTO ls_s501
                       WITH KEY docno = ls_s501-docno.
    IF sy-subrc = 0.
      lv_posnr  = ls_s501-posnr + 1.
    ELSE.
      lv_posnr  = '000001'.
    ENDIF.
    ls_accdtd-posnr = lv_posnr.
    MODIFY gt_accdtd FROM ls_accdtd
                     TRANSPORTING posnr
                     WHERE docat = ls_s501-docat
                       AND docno = ls_s501-docno.
    ls_s501-posnr   = lv_posnr.
    ls_s501-vrsio   = '000'.
    ls_s501-sptag   = fu_budat.
    ls_s501-spwoc   = '000000'.
    ls_s501-spbup   = '000000'.
    ls_s501-ssour   = space.
    ls_s501-basme   = ls_item-entry_uom.
    ls_s501-werks   = ls_item-plant.
    ls_s501-lgort   = ls_item-stge_loc.
    ls_s501-matnr   = ls_item-material.
    ls_s501-charg   = ls_item-batch.
    ls_s501-menge   = ls_item-entry_qnt.
    ls_s501-meins   = ls_item-entry_uom.
    ls_s501-mblnr   = fu_mblnr.
    ls_s501-mjahr   = fu_mjahr.
    ls_s501-zeile   = ls_item-order_itno.
    APPEND ls_s501 TO lt_s501.
    CLEAR ls_s501.
  ENDLOOP.
  TRY.
      INSERT s501 FROM TABLE lt_s501.
    CATCH cx_sy_open_sql_db.
  ENDTRY.
  TRY.
      INSERT zaccdtd FROM TABLE gt_accdtd.
    CATCH cx_sy_open_sql_db.
  ENDTRY.
  TRY.
      INSERT zaccdta FROM TABLE gt_accdta.
    CATCH cx_sy_open_sql_db.
  ENDTRY.
  CLEAR: lv_ctr.
  LOOP AT gt_accdtm INTO ls_accdtm.
    TRY .
        UPDATE zaccdtm SET snsta = ls_accdtm-snsta
                       WHERE matnr = ls_accdtm-matnr
                         AND charg = ls_accdtm-charg
                         AND senum = ls_accdtm-senum.
      CATCH cx_sy_conversion_no_number.
    ENDTRY.
  ENDLOOP.
  DESCRIBE TABLE gt_accdtm LINES lv_ctr.
  "  if lv_ctr > 250.
  CLEAR: lv_ctr.
  LOOP AT gt_accdtm INTO ls_accdtm.
    ADD 1 TO lv_ctr.
*    PERFORM f_http_post USING gv_uri1 ls_accdtm-senum ''.
    PERFORM f_prepare_http_post TABLES lt_request_header
                                USING ls_accdtm-senum ''
                                CHANGING lv_json.
  ENDLOOP.
  IF lv_json IS NOT INITIAL.
    ld_data = p_id.
    SELECT SINGLE  zproses zdata MAX( zcounter ) AS zcounter INTO CORRESPONDING FIELDS OF ls_zaccppdt002 FROM zaccppdt002
      WHERE zproses = 'ACC_AGGR' AND
            zdata = ld_data
        GROUP BY zproses zdata. "ls_ztdsitdt006-zdata.
    ls_zaccppdt002-zproses = 'ACC_AGGR'. "p_event.
    ls_zaccppdt002-zdata = ld_data. "p_zdata.
    IF ls_zaccppdt002-zcounter IS NOT INITIAL.
      ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
    ELSE.
      ls_zaccppdt002-zcounter = 0.
    ENDIF.
    ls_zaccppdt002-erdat = sy-datum.
    ls_zaccppdt002-ernam = sy-uname.
    ls_zaccppdt002-erzet = sy-uzeit.

    ls_zaccppdt002-jmlrecord = lv_ctr.
    ls_zaccppdt002-message = 'Prepare data buat post ke api polymark'.
    MODIFY zaccppdt002 FROM ls_zaccppdt002.
    COMMIT WORK AND WAIT.
    PERFORM f_new_http_post "TABLES lt_request_header
                            USING gv_uri1 lv_json.
  ENDIF.


ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SELECTION
*&---------------------------------------------------------------------*
FORM f_modify_selection .
  PERFORM f_modify_screen USING : 'XXX' '0' '' '' ''.

  IF pa_xls IS INITIAL.
    PERFORM f_modify_screen USING : 'PFL' '0' '' '' ''.
  ENDIF.
  IF radio1 IS INITIAL.
    PERFORM f_modify_screen USING : 'PF2' '0' '' '' ''.
  ENDIF.
*  CASE 'X'.
*    WHEN radio1.
*      PERFORM f_modify_screen USING : 'PMB' '0' '' '' '',
*                                      'PGJ' '0' '' '' ''.
*    WHEN radio2.
*      PERFORM f_modify_screen USING : 'PFL' '0' '' '' ''.
*  ENDCASE.
ENDFORM.                    " F_MODIFY_SELECTION

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_required.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_required IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-required  = fu_required.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN
*&---------------------------------------------------------------------*
FORM f_validate_screen .
*  IF filenm IS INITIAL.
*    PERFORM f_error_message USING 'PFL' ''.
*  ENDIF.
*  CASE 'X'.
*    WHEN radio1.
*    WHEN radio2.
*      IF pa_mblnr IS INITIAL.
*        PERFORM f_error_message USING 'PMB' ''.
*      ENDIF.
*      IF pa_mjahr IS INITIAL.
*        PERFORM f_error_message USING 'PMJ' ''.
*      ENDIF.
*  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_FR_API
*&---------------------------------------------------------------------*
FORM f_upload_fr_api  USING    fu_uri fu_id.
  TYPES: BEGIN OF ty_dtarray,
           material TYPE string,
           batch    TYPE string,
           sn       TYPE string,
         END OF ty_dtarray.
  DATA : lv_uri(1000),
         temp_json         TYPE string,
         lv_str            TYPE string,
         writer            TYPE REF TO cl_sxml_string_writer,
         xml               TYPE xstring,
         ls_rif_ex         TYPE REF TO cx_root,
         ls_request_header LIKE LINE OF gt_request_header,
         ls_request_body   LIKE LINE OF gt_request_body,
         ls_var_text       TYPE string.
  DATA: lt_serial TYPE STANDARD TABLE OF ty_dtarray WITH DEFAULT KEY.
  DATA: ld_data TYPE zaccppdt001-zdata.
  DATA : lt_xml TYPE abap_trans_resbind_tab,
         ls_xml TYPE abap_trans_resbind.
  DATA: lv_name(15).
  DATA: ls_upload LIKE LINE OF gt_upload.
  DATA: lv_ctr TYPE i.
  DATA: ls_zaccppdt001 TYPE zaccppdt001.
  DATA: ls_zaccppdt002 TYPE zaccppdt002.
  DATA: lv_json TYPE string, l_str TYPE string..
  DATA: lv_text(200), lv_text1(10).
*  CONCATENATE fu_uri gv_token INTO lv_uri.
  CLEAR : gt_request_body[], gt_response_body[], lv_ctr,
          gt_response_header[], gt_request_header[].

  ls_request_header-header = 'Content-Type: application/json'.
  APPEND ls_request_header TO gt_request_header.
  IF fu_id IS NOT INITIAL.
    CONCATENATE '{ "sapprocessid" : " ' fu_id '"}' INTO ls_request_body-line.
    APPEND ls_request_body TO gt_request_body.
  ENDIF.

  CALL FUNCTION 'HTTP_POST'
    EXPORTING
      absolute_uri                = fu_uri
      request_entity_body_length  = 0
      blankstocrlf                = 'X'
    IMPORTING
      status_code                 = status_code
      status_text                 = status_text
      response_entity_body_length = len
    TABLES
      request_entity_body         = gt_request_body
      response_entity_body        = gt_response_body
      response_headers            = gt_response_header
      request_headers             = gt_request_header
    EXCEPTIONS
      connect_failed              = 1
      timeout                     = 2
      internal_error              = 3
      tcpip_error                 = 4
      data_error                  = 5
      system_failure              = 6
      communication_failure       = 7
      OTHERS                      = 8.
  WRITE: / 'subrc : ', sy-subrc.
  IF sy-subrc = 0.
    LOOP AT gt_response_body INTO temp_json.
      CONDENSE: temp_json, lv_str.
      CONCATENATE lv_str temp_json INTO lv_str. "loc_tempjson-json.
    ENDLOOP.
    REPLACE ALL OCCURRENCES OF REGEX 'null' IN lv_str WITH '"  "'.
**    LOOP AT gt_response_body.
**      temp_json = gt_response_body.
**      CONDENSE : lv_str.
**      "      WRITE: / temp_json.
**      IF sy-tabix = 1.
**        CONCATENATE lv_str temp_json INTO lv_str.
**      ELSE.
**        IF len = 1000.
**          CONCATENATE lv_str temp_json INTO lv_str.
**        ELSE.
**          CONCATENATE lv_str temp_json INTO lv_str
**          SEPARATED BY space.
**        ENDIF.
**      ENDIF.
**      CLEAR len.
**      len = strlen( gt_response_body ).
**      REPLACE ALL OCCURRENCES OF REGEX 'null' IN lv_str WITH '" "'.
**    ENDLOOP.
    lv_name = fu_id.
    IF lv_name IS INITIAL.
      lv_name = sy-datum.
      lv_text1 = sy-uzeit.
      CONCATENATE lv_name lv_text1 INTO lv_name SEPARATED BY '_'.
    ENDIF.
    PERFORM f_create_text_json(ztdsit_i001) USING lv_str lv_name '/outbound/acc/' 'ACC_AGGR'.
    writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_xml10 ).
    TRY.
        CALL TRANSFORMATION id SOURCE XML lv_str
                               RESULT XML writer.
        xml = writer->get_output( ).
      CATCH cx_root INTO ls_rif_ex.
        ls_var_text = ls_rif_ex->get_text( ).
*        WRITE: / 'Message Error JSON to XML: ', ls_var_text.
    ENDTRY.
    CASE 'X'.
      WHEN radio1.
        TRY.
            CALL TRANSFORMATION zacc_upload SOURCE XML xml
                                            RESULT upload = gt_upload.
          CATCH cx_root INTO ls_rif_ex.
            ls_var_text = ls_rif_ex->get_text( ).
*        WRITE: / 'Message Error XML to ITAB: ', ls_var_text.
        ENDTRY.
        IF fu_id IS NOT INITIAL.
          ld_data = fu_id.
          IF gt_upload[] IS NOT INITIAL.
            UPDATE zaccppdt001 SET status = 'G'
                   WHERE zproses = 'ACC_AGGR'
                     AND zdata = ld_data.
            COMMIT WORK AND WAIT.
            CONCATENATE '[ { "sapprocessid" : " ' fu_id '"} ]' INTO lv_json.
            PERFORM f_post_data_json(ztdsit_i001) USING lv_json 'ACC_AGGR' sy-subrc l_str.
            SELECT SINGLE  zproses zdata MAX( zcounter ) AS zcounter INTO CORRESPONDING FIELDS OF ls_zaccppdt002 FROM zaccppdt002
              WHERE zproses = 'ACC_AGGR' AND
                    zdata = ld_data
                GROUP BY zproses zdata. "ls_ztdsitdt006-zdata.
            ls_zaccppdt002-zproses = 'ACC_AGGR'. "p_event.
            ls_zaccppdt002-zdata = ld_data. "p_zdata.
            ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
            ls_zaccppdt002-erdat = sy-datum.
            ls_zaccppdt002-ernam = sy-uname.
            ls_zaccppdt002-erzet = sy-uzeit.
            WRITE: / 'POSTING'.
            WRITE: / 'Sap Proses id : ', fu_id.
            lv_ctr = 0.
            LOOP AT gt_upload INTO ls_upload.
              ADD 1 TO lv_ctr.
              WRITE: / lv_ctr, sy-vline, ls_upload-aufnr, sy-vline, ls_upload-matnr, sy-vline, ls_upload-charg, sy-vline, ls_upload-senum.
              lv_text = ls_upload-aufnr.
            ENDLOOP.
            lv_text1 = lv_ctr.
            CONDENSE: lv_text, lv_text1.
            CONCATENATE lv_text lv_text1 INTO lv_text SEPARATED BY '|'.
            ld_data = fu_id.
            SELECT SINGLE *  INTO ls_zaccppdt001 FROM zaccppdt001
                 WHERE zproses = 'ACC_AGGR'
                   AND zdata = ld_data.
            IF sy-subrc EQ 0.
              CONDENSE: lv_text, ls_zaccppdt001-ztext.
              CONCATENATE ls_zaccppdt001-ztext  lv_text INTO ls_zaccppdt001-ztext SEPARATED BY '|'.
              MODIFY zaccppdt001 FROM ls_zaccppdt001.
            ENDIF.
            ls_zaccppdt002-jmlrecord = lv_ctr.
            ls_zaccppdt002-message = lv_ctr.
            CONDENSE ls_zaccppdt002-message.
            CONCATENATE 'Berhasil Get ( ' ls_zaccppdt002-message ' )' INTO ls_zaccppdt002-message.
          ELSE.
            ls_zaccppdt002-zproses = 'ACC_AGGR'. "p_event.
            ls_zaccppdt002-zdata = ld_data. "p_zdata.
            ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
            ls_zaccppdt002-erdat = sy-datum.
            ls_zaccppdt002-ernam = sy-uname.
            ls_zaccppdt002-erzet = sy-uzeit.
            ls_zaccppdt002-message = 'Tidak ada data yang di GET'.
          ENDIF.
          MODIFY zaccppdt002 FROM ls_zaccppdt002.
          COMMIT WORK AND WAIT.
          CLEAR: ls_zaccppdt002.
        ENDIF.
      WHEN radio2.
        TRY.
            CALL TRANSFORMATION zacc_cancel SOURCE XML xml
                                            RESULT cancel = gt_upload.
            "RESULT upload = gt_upload.
          CATCH cx_root INTO ls_rif_ex.
            ls_var_text = ls_rif_ex->get_text( ).
*        WRITE: / 'Message Error XML to ITAB: ', ls_var_text.
        ENDTRY.
        WRITE: / 'CANCEL'.
        WRITE: / 'Sap Proses id : ', fu_id.
        lv_ctr = 0.
        LOOP AT gt_upload INTO ls_upload.
          ADD 1 TO lv_ctr.
          WRITE: / lv_ctr, sy-vline, ls_upload-aufnr, sy-vline, ls_upload-matnr, sy-vline, ls_upload-charg, sy-vline, ls_upload-senum.
        ENDLOOP.
      WHEN radio3.
        TRY.
            CALL TRANSFORMATION zacc_ackno_poly SOURCE XML xml
                                                RESULT ackno = gt_upload.
          CATCH cx_root INTO ls_rif_ex.
            ls_var_text = ls_rif_ex->get_text( ).
*        WRITE: / 'Message Error XML to ITAB: ', ls_var_text.
        ENDTRY.
        WRITE: / 'Cek status SEND'.
        lv_ctr = 0.
        SELECT SINGLE  zproses zdata MAX( zcounter ) AS zcounter INTO CORRESPONDING FIELDS OF ls_zaccppdt002 FROM zaccppdt002
          WHERE zproses = 'ZACCSEND'
            GROUP BY zproses zdata. "ls_ztdsitdt006-zdata.
        IF gt_upload[] IS NOT INITIAL.
          LOOP AT gt_upload INTO ls_upload.
            ADD 1 TO lv_ctr.
            WRITE: / lv_ctr, sy-vline, ls_upload-aufnr, sy-vline, ls_upload-matnr, sy-vline, ls_upload-charg, sy-vline, ls_upload-senum.
          ENDLOOP.
          WRITE: / 'Jumlah Record yg diget : ', lv_ctr.
          ls_zaccppdt002-zproses = 'ZACCSEND'. "p_event.
          ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
          ls_zaccppdt002-jmlrecord = lv_ctr.
          ls_zaccppdt002-message = lv_ctr.
          CONDENSE ls_zaccppdt002-message.
          CONCATENATE 'Get data ZACCSEND ( ' ls_zaccppdt002-message ')' INTO ls_zaccppdt002-message.
          ls_zaccppdt002-erdat = sy-datum.
          ls_zaccppdt002-ernam = sy-uname.
          ls_zaccppdt002-erzet = sy-uzeit.
          MODIFY zaccppdt002 FROM ls_zaccppdt002.
        ELSE.
          ls_zaccppdt002-zproses = 'ZACCSEND'. "p_event.
          ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
          ls_zaccppdt002-jmlrecord = lv_ctr.
          ls_zaccppdt002-message = lv_ctr.
          ls_zaccppdt002-message = 'Tidak ada data'..
          ls_zaccppdt002-erdat = sy-datum.
          ls_zaccppdt002-ernam = sy-uname.
          ls_zaccppdt002-erzet = sy-uzeit.
          MODIFY zaccppdt002 FROM ls_zaccppdt002.
          WRITE: / 'No data'.
        ENDIF.
        COMMIT WORK AND WAIT.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_UPLOAD_FR_API

*&---------------------------------------------------------------------*
*&      Form  F_HTTP_POST
*&---------------------------------------------------------------------*
FORM f_http_post  USING    fu_uri fu_senum fu_message.
  DATA : lt_request_header  TYPE TABLE OF sbcheader WITH HEADER LINE,
         lt_request_body    TYPE TABLE OF sbcbody WITH HEADER LINE,
         lt_response_header TYPE TABLE OF sbcheader WITH HEADER LINE,
         lt_response_body   TYPE TABLE OF sbcbody WITH HEADER LINE,
         ls_request_header  LIKE LINE OF lt_request_header.

  ls_request_header-header = 'Content-Type: application/json'.
  APPEND ls_request_header TO lt_request_header.

  CONCATENATE 'SN:' fu_senum INTO ls_request_header-header.
  APPEND ls_request_header TO lt_request_header.

  CASE 'X'.
    WHEN radio1.
      IF fu_message IS NOT INITIAL.
        CONCATENATE 'Message:' fu_message INTO ls_request_header-header.
        APPEND ls_request_header TO lt_request_header.
      ENDIF.
    WHEN radio2.
      CONCATENATE 'Message:' fu_message INTO ls_request_header-header.
      APPEND ls_request_header TO lt_request_header.
  ENDCASE.

  CALL FUNCTION 'HTTP_POST'
    EXPORTING
      absolute_uri                = fu_uri
      request_entity_body_length  = 0
      blankstocrlf                = 'X'
    IMPORTING
      status_code                 = status_code
      status_text                 = status_text
      response_entity_body_length = len
    TABLES
      request_entity_body         = lt_request_body
      response_entity_body        = lt_response_body
      response_headers            = lt_response_header
      request_headers             = lt_request_header
    EXCEPTIONS
      connect_failed              = 1
      timeout                     = 2
      internal_error              = 3
      tcpip_error                 = 4
      data_error                  = 5
      system_failure              = 6
      communication_failure       = 7
      OTHERS                      = 8.
ENDFORM.                    " F_HTTP_POST

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_DATA
*&---------------------------------------------------------------------*
FORM f_update_data .
  DATA : ls_accdtm LIKE LINE OF gt_accdtm,
         lv_total  TYPE sy-index,
         lv_count  TYPE sy-index.

  DESCRIBE TABLE gt_accdtm LINES lv_total.

  LOOP AT gt_accdtm INTO ls_accdtm.
    ls_accdtm-snsta  = 'SEND'.
    TRY .
        UPDATE zaccdtm SET sendt = sy-datum
                           snsta = ls_accdtm-snsta
                       WHERE matnr = ls_accdtm-matnr
                         AND charg = ls_accdtm-charg
                         AND senum = ls_accdtm-senum.
      CATCH cx_sy_dynamic_osql_error.
    ENDTRY.
    IF sy-subrc = 0.
      ADD 1 TO lv_count.
    ENDIF.
  ENDLOOP.
  IF lv_total <> lv_count.
    MESSAGE e000(zab) WITH 'There is data that is not uploaded'.
  ENDIF.
ENDFORM.                    " F_UPDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_DATA
*&---------------------------------------------------------------------*
FORM f_cancel_data .
  DATA : lt_s501    TYPE STANDARD TABLE OF s501,
         ls_s501    LIKE LINE OF lt_s501,
         ls_zaccdtm LIKE LINE OF gt_zaccdtm,
         ls_cancel  LIKE LINE OF gt_cancel,
         lt_zaccdtm TYPE STANDARD TABLE OF zaccdtm.

  DATA : return    TYPE STANDARD TABLE OF bapiret2,
         ls_return LIKE LINE OF return.

  lt_s501[] = gt_s501[].
  SORT lt_s501 BY mblnr mjahr.
  LOOP AT lt_s501 INTO ls_s501.
    CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
      EXPORTING
        materialdocument    = ls_s501-mblnr
        matdocumentyear     = ls_s501-mjahr
        goodsmvt_pstng_date = ls_s501-sptag
      TABLES
        return              = return.

    READ TABLE return INTO ls_return
                      WITH KEY type = 'E'.
    IF sy-subrc = 0.
      ROLLBACK WORK.
      LOOP AT gt_zaccdtm INTO ls_zaccdtm WHERE aufnr = ls_s501-docno.
        READ TABLE gt_cancel INTO ls_cancel
                             WITH KEY aufnr = ls_zaccdtm-aufnr
                                      senum = ls_zaccdtm-senum.
        IF sy-subrc = 0.
          PERFORM f_http_post USING gv_uri1 ls_zaccdtm-senum ls_return-message.
        ENDIF.
        CLEAR ls_zaccdtm.
      ENDLOOP.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      LOOP AT gt_zaccdtm INTO ls_zaccdtm WHERE aufnr = ls_s501-docno.
        READ TABLE gt_cancel INTO ls_cancel
                             WITH KEY aufnr = ls_zaccdtm-aufnr
                                      senum = ls_zaccdtm-senum.
        IF sy-subrc = 0.
          ls_zaccdtm-snsta = 'RJCT'.
          PERFORM f_http_post USING gv_uri1 ls_zaccdtm-senum ''.
        ELSE.
          ls_zaccdtm-snsta = 'SEND'.
        ENDIF.
        APPEND ls_zaccdtm TO lt_zaccdtm.
        CLEAR ls_zaccdtm.
      ENDLOOP.

      TRY .
          MODIFY zaccdtm FROM TABLE lt_zaccdtm.
        CATCH cx_sy_open_sql_db.
      ENDTRY.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CANCEL_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_PROCESS_ORDER
*&---------------------------------------------------------------------*
FORM f_check_process_order  TABLES   ft_upload STRUCTURE zaccstp.
  DATA : ls_upload  TYPE zaccstp,
         lt_zaccdtx TYPE STANDARD TABLE OF zaccdtx,
         ls_zaccdtx LIKE LINE OF lt_zaccdtx.

  IF ft_upload[] IS NOT INITIAL.
    SELECT *
      FROM zaccdtx
      INTO CORRESPONDING FIELDS OF TABLE lt_zaccdtx
      FOR ALL ENTRIES IN ft_upload
      WHERE werks = ft_upload-werks
        AND aufnr = ft_upload-aufnr
        AND charg = ft_upload-charg.

    LOOP AT ft_upload INTO ls_upload.
      CLEAR ls_zaccdtx.
      READ TABLE lt_zaccdtx INTO ls_zaccdtx
                            WITH KEY werks = ls_upload-werks
                                     aufnr = ls_upload-aufnr
                                     charg = ls_upload-charg.
      IF sy-subrc = 0.
        DELETE ft_upload WHERE werks = ls_upload-werks
                           AND aufnr = ls_upload-aufnr
                           AND charg = ls_upload-charg.

        DELETE gt_upload WHERE werks = ls_upload-werks
                           AND aufnr = ls_upload-aufnr
                           AND charg = ls_upload-charg.
      ELSE.
        ls_zaccdtx-werks  = ls_upload-werks.
        ls_zaccdtx-aufnr  = ls_upload-aufnr.
        ls_zaccdtx-charg  = ls_upload-charg.
        INSERT zaccdtx FROM ls_zaccdtx.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_CHECK_PROCESS_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_ADD_ITEM
*&---------------------------------------------------------------------*
FORM f_add_item  USING    fs_upload   LIKE LINE OF gt_upload
                          fs_accdtm   LIKE LINE OF gt_accdtm.
  DATA : ls_item    LIKE LINE OF gt_item.

  ls_item-material            = fs_accdtm-matnr.
  ls_item-plant               = fs_accdtm-pwerk.
  ls_item-stge_loc            = fs_upload-lgort.
  ls_item-batch               = fs_upload-charg.
  ls_item-move_type           = '101'.
  ls_item-orderid             = fs_accdtm-aufnr.
  ls_item-order_itno          = fs_accdtm-posnr.
  ls_item-entry_qnt           = 1.
  ls_item-entry_uom           = fs_accdtm-amein.
  ls_item-mvt_ind             = 'F'.
  ls_item-no_more_gr          = 'X'.
  COLLECT ls_item INTO gt_item.
  CLEAR ls_item.
ENDFORM.                    " F_ADD_ITEM

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fs_upload  LIKE LINE OF gt_upload.

  DATA : ls_eaccdtm   TYPE zaccstp.

  ls_eaccdtm-aufnr = fs_upload-aufnr.
  ls_eaccdtm-werks = fs_upload-werks.
  ls_eaccdtm-charg = fs_upload-charg.
  ls_eaccdtm-senum = fs_upload-senum.
  APPEND ls_eaccdtm TO gt_eaccdtm.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_ERROR
*&---------------------------------------------------------------------*
FORM f_write_error .
  DATA : ls_eaccdtm   TYPE zaccstp.
  DATA: ld_data TYPE zaccppdt002-zdata.
  DATA: ls_zaccppdt001 TYPE zaccppdt001,
        ls_zaccppdt002 TYPE zaccppdt002.

  "      DESCRIBE TABLE gt_upload LINES gv_upload.

  DESCRIBE TABLE gt_eaccdtm LINES gv_upload.
  ld_data = p_id.

  SELECT SINGLE  zproses zdata MAX( zcounter ) AS zcounter INTO CORRESPONDING FIELDS OF ls_zaccppdt002 FROM zaccppdt002
    WHERE zproses = 'ACC_AGGR' AND
          zdata = ld_data
      GROUP BY zproses zdata. "ls_ztdsitdt006-zdata.

  ls_zaccppdt002-zproses = 'ACC_AGGR'. "p_event.
  ls_zaccppdt002-zdata = ld_data. "p_zdata.
  ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
  ls_zaccppdt002-erdat = sy-datum.
  ls_zaccppdt002-ernam = sy-uname.
  ls_zaccppdt002-erzet = sy-uzeit.

  ls_zaccppdt002-jmlrecord = gv_upload.
  ls_zaccppdt002-message = gv_upload.
  CONCATENATE 'Ada Error SN ( ' ls_zaccppdt002-message ' ) Cek Log Spool' INTO ls_zaccppdt002-message.
  MODIFY zaccppdt002 FROM ls_zaccppdt002.
  COMMIT WORK AND WAIT.

  WRITE :/ sy-uline.
  WRITE: / 'Error SN'.
  LOOP AT gt_eaccdtm INTO ls_eaccdtm.
    WRITE :/ sy-vline,
             ls_eaccdtm-aufnr, sy-vline,
             ls_eaccdtm-werks, sy-vline,
             ls_eaccdtm-charg, sy-vline,
             ls_eaccdtm-senum, sy-vline.
    PERFORM f_http_post USING gv_uri1 ls_eaccdtm-senum 'Error'.
  ENDLOOP.
  WRITE :/ sy-uline.
ENDFORM.                    " F_WRITE_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_HTTP_POST
*&---------------------------------------------------------------------*
FORM f_prepare_http_post  TABLES   ft_request_header STRUCTURE sbcheader
                          USING    fu_senum fu_message
                          CHANGING fc_json.
  DATA : ls_request_header TYPE sbcheader,
         ls_request_body   TYPE sbcbody.

  ls_request_header-header = 'Content-Type: application/json'.
  APPEND ls_request_header TO ft_request_header.

  IF fc_json IS INITIAL.
    CONCATENATE '{"SN": ["' fu_senum '"' INTO fc_json.
  ELSE.
    CONCATENATE fc_json ', "' fu_senum '"' INTO fc_json.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      IF fu_message IS NOT INITIAL.
        CONCATENATE 'Message:' fu_message INTO ls_request_header-header.
        APPEND ls_request_header TO ft_request_header.
      ENDIF.
    WHEN radio2.
      IF fu_message IS NOT INITIAL.
        CONCATENATE 'Message:' fu_message INTO ls_request_header-header.
        APPEND ls_request_header TO ft_request_header.
      ENDIF.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_NEW_HTTP_POST
*&---------------------------------------------------------------------*
FORM f_new_http_post  "TABLES   ft_request_header STRUCTURE sbcheader
                      USING    fu_uri fu_json.
  DATA : lt_response_header TYPE TABLE OF sbcheader WITH HEADER LINE,
         lt_request_header  TYPE TABLE OF sbcheader WITH HEADER LINE,
         ls_request_header  TYPE sbcheader,
         lt_response_body   TYPE TABLE OF text WITH HEADER LINE,
         "sbcbody WITH HEADER LINE,
         lt_request_body    TYPE TABLE OF text, " WITH HEADER LINE,
         ls_response_body   LIKE LINE OF lt_response_body,
         ls_request_body    LIKE LINE OF lt_request_body.
  DATA: lv_str      TYPE string,
        lv_name(15), lv_text(10).
  DATA: json1 TYPE string, l_ctr TYPE i, l_len TYPE i.
  DATA:    gv_fullfile  LIKE edi_path-pthnam.
  DATA: ld_data        TYPE zaccppdt002-zdata,
        ls_zaccppdt002 TYPE zaccppdt002.

  lv_text = sy-uzeit.
  lv_name = sy-datum.
  CONDENSE: lv_name, lv_text.
  CONCATENATE 'New' lv_name lv_text INTO lv_name SEPARATED BY '_'.
  CONCATENATE fu_json ']}' INTO lv_str.

  json1 = lv_str.
  l_len = strlen( json1 ).

  DO 75000000 TIMES.
    FIND ',' IN json1 MATCH OFFSET l_ctr.
    IF sy-subrc NE 0.
      FIND '}' IN json1 MATCH OFFSET l_ctr.
    ENDIF.
    IF sy-subrc EQ 0.
      l_ctr = l_ctr + 1 .
      IF l_ctr > l_len.
        l_ctr = l_len.
      ENDIF.
      ls_request_body-line = json1(l_ctr). "(500).
      CONDENSE: ls_request_body-line.
      APPEND ls_request_body TO lt_request_body.
      IF l_ctr > l_len.
        l_len = l_ctr.
        l_ctr = 1000.
      ELSE.
        l_len = l_len - l_ctr.
      ENDIF.
      json1 = json1+l_ctr(l_len).
    ELSE.
      IF json1 IS INITIAL.
      ELSE.
        ls_request_body-line = json1(l_len). "(500).
        CONDENSE: ls_request_body-line.
        APPEND ls_request_body TO lt_request_body.
      ENDIF.
      EXIT.
    ENDIF.
  ENDDO.
  CLEAR: lv_str, gv_fullfile.
  CONCATENATE '/outbound/acc/' lv_name '.json' INTO gv_fullfile.
  OPEN DATASET gv_fullfile FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
  IF sy-subrc EQ 0.
    LOOP AT lt_request_body INTO ls_request_body.
      lv_str = ls_request_body-line.
      TRANSFER  lv_str TO gv_fullfile.
    ENDLOOP.
    CLOSE DATASET gv_fullfile.
  ENDIF.
  CLEAR: lt_request_header[].
  ls_request_header-header = 'Content-Type: application/json'.
  APPEND ls_request_header TO lt_request_header.
  CALL FUNCTION 'HTTP_POST'
    EXPORTING
      absolute_uri                = fu_uri
      request_entity_body_length  = 0
      blankstocrlf                = 'X'
    IMPORTING
      status_code                 = status_code
      status_text                 = status_text
      response_entity_body_length = len
    TABLES
      request_entity_body         = lt_request_body
      response_entity_body        = lt_response_body
      response_headers            = lt_response_header
      request_headers             = lt_request_header
    EXCEPTIONS
      connect_failed              = 1
      timeout                     = 2
      internal_error              = 3
      tcpip_error                 = 4
      data_error                  = 5
      system_failure              = 6
      communication_failure       = 7
      OTHERS                      = 8.
  "        lv_str         TYPE string.
  CLEAR: lv_str.
  LOOP AT lt_response_body INTO ls_response_body.
    CONDENSE: ls_response_body-line.
    CONCATENATE lv_str ls_response_body-line INTO lv_str.
  ENDLOOP.
  WRITE: / 'URL POST : ', fu_uri.
  WRITE: / 'Sy-subrc : ', sy-subrc.
  WRITE: / 'Respon Post to polimax : ', lv_str.
  WRITE: / 'Status Post : ', status_code, sy-vline, status_text.
  WRITE: / 'Respon Post Header : '.
  LOOP AT lt_response_header INTO ls_request_header.
    WRITE: / ls_request_header-header.
  ENDLOOP.
  ld_data = p_id.

  SELECT SINGLE  zproses zdata MAX( zcounter ) AS zcounter INTO CORRESPONDING FIELDS OF ls_zaccppdt002 FROM zaccppdt002
    WHERE zproses = 'ACC_AGGR' AND
          zdata = ld_data
      GROUP BY zproses zdata. "ls_ztdsitdt006-zdata.

  ls_zaccppdt002-zproses = 'ACC_AGGR'. "p_event.
  ls_zaccppdt002-status = 'S'.
  ls_zaccppdt002-zdata = ld_data. "p_zdata.
  ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
  ls_zaccppdt002-erdat = sy-datum.
  ls_zaccppdt002-ernam = sy-uname.
  ls_zaccppdt002-erzet = sy-uzeit.

  "  ls_zaccppdt002-jmlrecord = lv_ctr.
  ls_zaccppdt002-message = fu_uri.
  MODIFY zaccppdt002 FROM ls_zaccppdt002.

  ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
  ls_zaccppdt002-erdat = sy-datum.
  ls_zaccppdt002-ernam = sy-uname.
  ls_zaccppdt002-erzet = sy-uzeit.

  "  ls_zaccppdt002-jmlrecord = lv_ctr.
  ls_zaccppdt002-message = lv_str.
  MODIFY zaccppdt002 FROM ls_zaccppdt002.
  IF status_code = '200'.
    ls_zaccppdt002-status = 'S'.
    ls_zaccppdt002-erdat = sy-datum.
    ls_zaccppdt002-ernam = sy-uname.
    ls_zaccppdt002-erzet = sy-uzeit.

    ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
    "    ls_zaccppdt002-jmlrecord = lv_ctr.
    ls_zaccppdt002-message = 'Berhasil kirim data ke POLYMARK'.
    MODIFY zaccppdt002 FROM ls_zaccppdt002.

    UPDATE zaccppdt001 SET status ='S' WHERE zproses = 'ACC_AGGR' AND zdata = ld_data.
  ENDIF.
  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_RESEND_POSTING_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_resend_posting_data .

  DATA : ls_accdtm LIKE LINE OF gt_accdtm.
  DATA: lt_accdtm_dlv  TYPE STANDARD TABLE OF zv_accdtm.

  DATA : lt_request_header TYPE STANDARD TABLE OF sbcheader.

  DATA : lv_json    TYPE string.
  DATA: lv_ctr TYPE i.
  DATA: ld_data        TYPE zaccppdt002-zdata,
        ls_zaccppdt002 TYPE zaccppdt002.

  CLEAR: lv_ctr.
  DESCRIBE TABLE gt_accdtm_dlv LINES lv_ctr.
  CLEAR lv_ctr.
  WRITE: / 'SN Resend utk status DLV'.
  LOOP AT gt_accdtm_dlv INTO ls_accdtm.
    ADD 1 TO lv_ctr.
    WRITE: / sy-vline, lv_ctr, sy-vline, ls_accdtm-senum, sy-vline.
*    PERFORM f_http_post USING gv_uri1 ls_accdtm-senum ''.
    PERFORM f_prepare_http_post TABLES lt_request_header
                                USING ls_accdtm-senum ''
                                CHANGING lv_json.
  ENDLOOP.
  WRITE: / 'Total SN di resend untuk status DLV', lv_ctr.
  IF lv_json IS NOT INITIAL.
    ld_data = p_id.
    SELECT SINGLE  zproses zdata MAX( zcounter ) AS zcounter INTO CORRESPONDING FIELDS OF ls_zaccppdt002 FROM zaccppdt002
      WHERE zproses = 'ACC_AGGR' AND
            zdata = ld_data
        GROUP BY zproses zdata. "ls_ztdsitdt006-zdata.

    ls_zaccppdt002-zproses = 'ACC_AGGR'. "p_event.
    ls_zaccppdt002-zdata = ld_data. "p_zdata.
    ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
    ls_zaccppdt002-erdat = sy-datum.
    ls_zaccppdt002-ernam = sy-uname.
    ls_zaccppdt002-erzet = sy-uzeit.

    ls_zaccppdt002-jmlrecord = lv_ctr.
    ls_zaccppdt002-message = 'Prepare data buat ressend ke api polymark'.
    MODIFY zaccppdt002 FROM ls_zaccppdt002.
    COMMIT WORK AND WAIT.
    PERFORM f_new_http_post "TABLES lt_request_header
                            USING gv_uri1 lv_json.
  ENDIF.
  lv_ctr = 0.
  CLEAR: lv_json.
ENDFORM.
