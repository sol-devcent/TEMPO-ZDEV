*&---------------------------------------------------------------------*
*&  Include           ZFI_E005F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_004      LIKE LINE OF gt_004,
         lv_fname    TYPE rlgrap-filename,
         lv_filename TYPE rlgrap-filename,
         lv_zbank1   TYPE zfidt004-zbank,
         lv_company  TYPE zfidt004-company,
         lv_bukrs    TYPE bkpf-bukrs,
         lv_str01    TYPE string,
         lv_ext      TYPE string.

  CLEAR gv_subrc.
  CASE 'X'.
    WHEN radio1.
    WHEN radio2.
      CLEAR : pa_fname.
    WHEN radio3.
      CLEAR : pa_fname.
    WHEN radio4.
      CLEAR : pa_fname.
  ENDCASE.

  SELECT *
    FROM t001
    INTO CORRESPONDING FIELDS OF TABLE gt_t001.

  SELECT *
    FROM tbsl
    INTO CORRESPONDING FIELDS OF TABLE gt_tbsl.

  SELECT *
    FROM zfidt004c
    INTO CORRESPONDING FIELDS OF TABLE gt_004c.

  SELECT *
    FROM biw_knb1t
    INTO CORRESPONDING FIELDS OF TABLE gt_biw_knb1t
    WHERE bukrs = pa_bukrs.

  SELECT *
    FROM zfidt004
    INTO CORRESPONDING FIELDS OF TABLE gt_004
    WHERE bukrs = pa_bukrs.

  IF pa_fname IS NOT INITIAL.
    PERFORM f_split_file USING pa_fname
                         CHANGING lv_fname.
    IF sy-subrc = 0.
      CLEAR gs_004.
      READ TABLE gt_004 INTO gs_004
                        WITH KEY bukrs  = pa_bukrs
                                 zbank  = pa_zbank
                                 znorek = pa_norek.
      IF sy-subrc = 0.
        lv_filename = gs_004-filename.
      ENDIF.

      SPLIT lv_fname AT '_' INTO lv_company lv_zbank1 lv_fname.
      SPLIT lv_fname AT '.' INTO lv_fname lv_ext.

      IF lv_zbank1 = lv_filename.
        CLEAR gs_004.
        READ TABLE gt_004 INTO gs_004
                          WITH KEY bukrs  = pa_bukrs
                                   zbank  = pa_zbank
                                   znorek = pa_norek.
        IF sy-subrc <> 0.
          gv_subrc = 4.
        ELSEIF lv_company <> gs_004-company.
          gv_subrc = 2.
        ENDIF.
      ELSE.
        gv_subrc = 1.
      ENDIF.
      TRANSLATE lv_ext TO UPPER CASE.
      IF pa_excel IS NOT INITIAL.
        IF lv_ext <> 'XLS' AND
          lv_ext <> 'XLSX'.
          gv_subrc = 7.
        ENDIF.
      ELSE.
        IF lv_ext = 'XLS' OR
          lv_ext = 'XLSX'.
          gv_subrc = 7.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_modify_screen USING : 'PZU' '0' '' '' '',
                                      'PZ1' '0' '' '' '',
                                      'SZ1' '0' '' '' '',
                                      'PPR' '0' '' '' '',
                                      'SBD' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'SZU' '0' '' '' ''.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'PFN' '0' '' '' '',
                                      'PZ1' '0' '' '' '',
                                      'SZ1' '0' '' '' '',
                                      'SBD' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'SZU' '0' '' '' '',
                                      'PNO' '0' '' '' '',
                                      'PEX' '0' '' '' '',
                                      'PWA' '0' '' '' '',
                                      'PPR' '0' '' '' ''.
    WHEN radio3.
      PERFORM f_modify_screen USING : 'PFN' '0' '' '' '',
                                      'PZ1' '0' '' '' '',
                                      'SZ1' '0' '' '' '',
                                      'SBD' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'SZU' '0' '' '' '',
                                      'PNO' '0' '' '' '',
                                      'PEX' '0' '' '' '',
                                      'PWA' '0' '' '' '',
                                      'PPR' '0' '' '' '',
                                      'PF1' '0' '' '' ''.
    WHEN radio4.
      PERFORM f_modify_screen USING : 'PZU' '0' '' '' '',
                                      'PZ1' '0' '' '' '',
                                      'SZ1' '0' '' '' '',
                                      'PFN' '0' '' '' '',
                                      'PPR' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'PBA' '0' '' '' '',
                                      'PNO' '0' '' '' '',
                                      'PEX' '0' '' '' '',
                                      'PWA' '0' '' '' '',
                                      'PF1' '0' '' '' ''.
    WHEN radio5.
      PERFORM f_modify_screen USING : 'PZU' '0' '' '' '',
                                      'PZ1' '0' '' '' '',
                                      'SZ1' '0' '' '' '',
                                      'PFN' '0' '' '' '',
                                      'PPR' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'PBA' '0' '' '' '',
                                      'PNO' '0' '' '' '',
                                      'SBD' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'SZU' '0' '' '' '',
                                      'PBU' '0' '' '' '',
                                      'PEX' '0' '' '' '',
                                      'PWA' '0' '' '' ''.
    WHEN radio6.
      PERFORM f_modify_screen USING : 'PZU' '0' '' '' '',
                                      'SZ1' '0' '' '' '',
                                      'PFN' '0' '' '' '',
                                      'PPR' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'PBA' '0' '' '' '',
                                      'PNO' '0' '' '' '',
                                      'SBD' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'SZU' '0' '' '' '',
                                      'PBU' '0' '' '' '',
                                      'PEX' '0' '' '' '',
                                      'PWA' '0' '' '' ''.
    WHEN radio7.
      PERFORM f_modify_screen USING : 'PZU' '0' '' '' '',
                                      'PZ1' '0' '' '' '',
                                      'PFN' '0' '' '' '',
                                      'PPR' '0' '' '' '',
                                      'PBD' '0' '' '' '',
                                      'PBA' '0' '' '' '',
                                      'PNO' '0' '' '' '',
                                      'PEX' '0' '' '' '',
                                      'PWA' '0' '' '' '',
                                      'SZU' '0' '' '' '',
                                      'PF1' '0' '' '' ''.
    WHEN radio8.
      PERFORM f_modify_screen USING : 'PFN' '0' '' '' '',
                                      'PZU' '0' '' '' '',
                                      'SZ1' '0' '' '' '',
                                      'SBD' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'SZU' '0' '' '' '',
                                      'PNO' '0' '' '' '',
                                      'PEX' '0' '' '' '',
                                      'PWA' '0' '' '' '',
                                      'PPR' '0' '' '' '',
                                      'PF1' '0' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  IF radio5 IS INITIAL AND
    radio6 IS INITIAL.
    IF pa_bukrs IS INITIAL.
      PERFORM f_error_message USING : 'PBU' ''.
    ENDIF.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      IF pa_zbank IS INITIAL.
        PERFORM f_error_message USING : 'PBA' ''.
      ENDIF.
      IF pa_norek IS INITIAL.
        PERFORM f_error_message USING : 'PNO' ''.
      ENDIF.
      IF pa_budat IS INITIAL.
        PERFORM f_error_message USING : 'PBD' ''.
      ENDIF.
      IF pa_fname IS INITIAL.
        PERFORM f_error_message USING : 'PFN' ''.
      ENDIF.
    WHEN radio2.
      IF pa_zbank IS INITIAL.
        PERFORM f_error_message USING : 'PBA' ''.
      ENDIF.
      IF pa_budat IS INITIAL.
        PERFORM f_error_message USING : 'PBD' ''.
      ENDIF.
      IF pa_zuonr IS INITIAL.
        PERFORM f_error_message USING : 'PZU' ''.
      ENDIF.
    WHEN radio3.
      IF pa_zbank IS INITIAL.
        PERFORM f_error_message USING : 'PBA' ''.
      ENDIF.
      IF pa_budat IS INITIAL.
        PERFORM f_error_message USING : 'PBD' ''.
      ENDIF.
      IF pa_zuonr IS INITIAL.
        PERFORM f_error_message USING : 'PZU' ''.
      ENDIF.
    WHEN radio8.
      IF pa_zbank IS INITIAL.
        PERFORM f_error_message USING : 'PBA' ''.
      ENDIF.
      IF pa_budat IS INITIAL.
        PERFORM f_error_message USING : 'PBD' ''.
      ENDIF.
      IF pa_zuon1 IS INITIAL.
        PERFORM f_error_message USING : 'PZ1' ''.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_F4_FILENAME
*&---------------------------------------------------------------------*
FORM f_f4_filename  USING  fu_proc
                    CHANGING fc_fname.
  DATA : directory TYPE string,
         filetable TYPE filetable,
         line      TYPE LINE OF filetable,
         rc        TYPE i.

  CASE fu_proc.
    WHEN 'FILE'.
      CALL METHOD cl_gui_frontend_services=>get_temp_directory
        CHANGING
          temp_dir = directory.
      CALL METHOD cl_gui_frontend_services=>file_open_dialog
        EXPORTING
          window_title      = 'Select file'
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

    WHEN 'PATH'.
      CALL METHOD cl_gui_frontend_services=>directory_browse
        EXPORTING
          window_title    = 'File Directory'
          initial_folder  = 'C:'
        CHANGING
          selected_folder = directory.

      fc_fname  = directory.
  ENDCASE.
ENDFORM.                    " F_F4_FILENAME

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_length.
  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
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

  IF fu_length IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-length  = fu_length.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_group fu_mess.
  DATA : lv_mess(100) VALUE 'Fill in all required entry fields',
         lr_group     TYPE RANGE OF char3,
         ls_group     LIKE LINE OF lr_group.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

  IF fu_group = 'DES'.
    ls_group-low    = 'DES'.
    ls_group-sign   = 'I'.
    ls_group-option = 'EQ'.
    APPEND ls_group TO lr_group.
    CLEAR ls_group.
    ls_group-low    = 'TRA'.
    ls_group-sign   = 'I'.
    ls_group-option = 'EQ'.
    APPEND ls_group TO lr_group.
    CLEAR ls_group.
  ENDIF.

  IF fu_group IS NOT INITIAL.
    IF fu_group = 'DES'.
      LOOP AT SCREEN.
        IF screen-group1 IN lr_group.
          screen-input  = 1.
        ELSE.
          screen-input  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ELSE.
      LOOP AT SCREEN.
        IF screen-group1 = fu_group.
          screen-input  = 1.
        ELSE.
          screen-input  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF lv_mess IS NOT INITIAL.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : ls_005  TYPE zfidt005,
         ls_bpvd LIKE LINE OF gt_bpvd,
         ls_bpv  LIKE LINE OF gt_bpv.

  CASE 'X'.
    WHEN radio1.
      IF pa_excel IS NOT INITIAL.
        PERFORM f_get_upload_excel_data.
      ELSE.
        PERFORM f_get_upload_data.
      ENDIF.

      SELECT *
        FROM zfidt005
        INTO CORRESPONDING FIELDS OF TABLE gt_x005
        WHERE bukrs = pa_bukrs
          AND budat = pa_budat
          AND zbank = pa_zbank.

    WHEN radio2.
      IF pa_zuonr IS INITIAL.
        SELECT *
          FROM zfidt005
          INTO CORRESPONDING FIELDS OF TABLE gt_x005
          WHERE bukrs = pa_bukrs
            AND budat = pa_budat
            AND zbank = pa_zbank.
      ELSE.
        SELECT *
          FROM zfidt005
          INTO CORRESPONDING FIELDS OF TABLE gt_x005
          WHERE bukrs = pa_bukrs
            AND budat = pa_budat
            AND zbank = pa_zbank
            AND zbrvn = pa_zuonr.
      ENDIF.

    WHEN radio3.
      SELECT *
        FROM zfidt005
        INTO CORRESPONDING FIELDS OF TABLE gt_x005
        WHERE bukrs = pa_bukrs
          AND budat = pa_budat
          AND zbank = pa_zbank
          AND zbrvn = pa_zuonr.

    WHEN radio4.
      SELECT *
        FROM zfidt005
        INTO CORRESPONDING FIELDS OF TABLE gt_x005
        WHERE bukrs = pa_bukrs
          AND zbank IN so_zbank
          AND zbrvn IN so_zuonr
          AND budat IN so_budat.

    WHEN radio6.
      SELECT *
        FROM zfidt006
        INTO CORRESPONDING FIELDS OF TABLE gt_bpv
        WHERE zbpvn = pa_zuon1.

      LOOP AT gt_bpv INTO ls_bpv.
        ls_bpvd-zbank2  = ls_bpv-zbank2.
        ls_bpvd-znorek2 = ls_bpv-znorek2.
        ls_bpvd-wrbtr2  = ls_bpv-wrbtr.
        ls_bpvd-zdesc2  = ls_bpv-descr.
        ls_bpvd-kursf   = ls_bpv-kursf.
        APPEND ls_bpvd TO gt_bpvd.
        CLEAR ls_bpvd.
      ENDLOOP.

      READ TABLE gt_bpv INTO gs_bpv INDEX 1.

    WHEN radio7.
      SELECT *
        FROM zfidt006
        INTO CORRESPONDING FIELDS OF TABLE gt_bpv
        WHERE bukrs  = pa_bukrs
          AND zbank1 IN so_zbank
          AND zbpvn  IN so_zuon1
          AND budat  IN so_budat.

    WHEN radio8.
      SELECT *
        FROM zfidt006
        INTO CORRESPONDING FIELDS OF TABLE gt_bpv
        WHERE bukrs  = pa_bukrs
          AND budat  = pa_budat
          AND zbank1 = pa_zbank
          AND zbpvn  = pa_zuon1.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_out  LIKE LINE OF gt_out,
         ls_x005 LIKE LINE OF gt_x005,
         ls_004  LIKE LINE OF gt_004.

  DATA : lv_tanggal    TYPE c LENGTH 30,
         lv_keterangan TYPE c LENGTH 30,
         lv_amount     TYPE c LENGTH 30,
         lv_wrbtr      TYPE c LENGTH 30,
         lv_sign       TYPE c LENGTH 30,
         lv_amntp      TYPE p DECIMALS 0,
         lv_line       TYPE string,
         lv_month      TYPE c LENGTH 3,
         lv_monat      TYPE c LENGTH 2,
         lv_datum      TYPE sy-datum,
         lv_zbank      TYPE zfidt004-zbank,
         lv_str01      TYPE string,
         lv_buzei      TYPE zfidt005-buzei,
         lv_budat      TYPE c LENGTH 20.

  DATA : lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.

  FIELD-SYMBOLS <fs>   TYPE any.

  CONCATENATE 'C' gs_004-zdcol+1(2) INTO lv_tanggal.
  CONCATENATE 'C' gs_004-zkcol+1(2) INTO lv_keterangan.
  CONCATENATE 'C' gs_004-zacol+1(2) INTO lv_amount.

  LOOP AT <fs_table> ASSIGNING <fs_wa>.
    ls_out-bukrs = pa_bukrs.

    SPLIT pa_zbank AT '-' INTO lv_zbank lv_str01.

    ls_out-zbank  = lv_zbank.
    ls_out-znorek = pa_norek.

    ASSIGN COMPONENT 'C01' OF STRUCTURE <fs_wa> TO <fs>.
    lv_line = <fs>.
    CASE lv_zbank.
      WHEN 'BCA'.
        SEARCH lv_line FOR 'Saldo Awal' AND MARK.
        IF sy-subrc = 0.
          EXIT.
        ENDIF.
      WHEN 'SMBC'.
        SEARCH lv_line FOR 'Information' AND MARK.
        IF sy-subrc = 0.
          EXIT.
        ENDIF.
    ENDCASE.

    ASSIGN COMPONENT lv_tanggal OF STRUCTURE <fs_wa> TO <fs>.
    lv_budat  = <fs>.
    PERFORM f_posting_date USING lv_zbank lv_budat
                           CHANGING ls_out-budat.

    ASSIGN COMPONENT lv_keterangan OF STRUCTURE <fs_wa> TO <fs>.
    ls_out-keterangan = <fs>.

    ASSIGN COMPONENT lv_amount OF STRUCTURE <fs_wa> TO <fs>.
    SPLIT <fs> AT space INTO lv_wrbtr lv_sign.
    TRANSLATE lv_wrbtr USING ', '.
    CONDENSE lv_wrbtr NO-GAPS.
    lv_amntp = lv_wrbtr.
    IF gs_004-waers = 'IDR'.
      ls_out-wrbtr = lv_amntp / 100.
    ELSE.
      ls_out-wrbtr = lv_wrbtr.
    ENDIF.
    ls_out-waers = gs_004-waers.
    ls_out-kursf = ls_out-kursf.

    IF gs_004-waers = 'IDR'.
      ls_out-dmbtr = ls_out-wrbtr.
    ELSE.
      ls_out-dmbtr = ls_out-dmbtr.
    ENDIF.

    IF ls_out-wrbtr = 0 OR
      lv_sign = 'DB'.
      CONTINUE.
    ENDIF.

    ADD 1 TO lv_buzei.
    ls_out-buzei  = lv_buzei.

    READ TABLE gt_x005 INTO ls_x005
                       WITH KEY bukrs  = ls_out-bukrs
                                budat  = ls_out-budat
                                znorek = ls_out-znorek
                                buzei  = ls_out-buzei.
    IF sy-subrc = 0.
      ls_stylerow-fieldname = 'MARK'.
      ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
      APPEND ls_stylerow TO ls_out-style.
      ls_out-kunnr  = ls_x005-kunnr.
      ls_out-znorek = ls_x005-znorek.
      ls_out-trans  = ls_x005-trans.
      ls_out-descr  = ls_x005-descr.
      ls_out-kursf  = ls_x005-kursf.
      ls_out-dmbtr  = ls_x005-dmbtr.
      ls_out-name1  = ls_x005-name1.
    ENDIF.

    APPEND ls_out TO gt_out.
    CLEAR ls_out.
  ENDLOOP.

  ASSIGN gt_out TO <fs_out>.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  IF <fs_out>[] IS NOT INITIAL.
    CALL SCREEN 101.
  ELSE.
    MESSAGE s000(zab) WITH 'Data not found' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DOCKING_SPLIT_CONTAINER
*&---------------------------------------------------------------------*
FORM f_docking_split_container .
  DATA : lv_contname(20).

  lv_contname   = 'CC_MAIN'.

  IF g_customcont IS INITIAL.
    CREATE OBJECT g_customcont
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
        parent  = g_customcont
        rows    = 1
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_contain01.
  ENDIF.
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  IF gt_bapiret2[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ENDIF.

  CASE 'X'.
    WHEN radio4.
      APPEND '&POS' TO fcode.
  ENDCASE.

  CASE sy-dynnr.
    WHEN '0100'.
      SET PF-STATUS 'PFSTATUS' EXCLUDING fcode.
      SET TITLEBAR 'TITLE02'.
    WHEN '0101'.
      SET PF-STATUS 'STANDARD' EXCLUDING fcode.
      SET TITLEBAR 'TITLE'.
    WHEN '0102'.
      SET PF-STATUS 'STATUS01' EXCLUDING fcode.
      SET TITLEBAR 'TITLE01'.
  ENDCASE.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
FORM f_exit .
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lt_bpv  TYPE STANDARD TABLE OF zfidt006,
         ls_bpv  LIKE LINE OF gt_bpv,
         ls_bpvd LIKE LINE OF gt_bpvd.

  DATA : lv_ucomm  TYPE sy-ucomm,
         lv_subrc  TYPE sy-subrc,
         lv_valid  TYPE c,
         lt_fidx   TYPE lvc_t_fidx,
         ls_fidx   TYPE sy-tabix,
         ls_filter LIKE LINE OF gt_filter.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&LOG'.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_bapiret2.

    WHEN '&ALL'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING 'X'.
      ENDIF.

    WHEN '&SAL'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING ''.
      ENDIF.

    WHEN '&POS'.
      CASE sy-dynnr.
        WHEN '0100'.
          PERFORM f_field_required TABLES gt_bpvd
                                   CHANGING lv_subrc.
          IF lv_subrc = 0.
            PERFORM f_validate_data TABLES gt_bpvd
                                    CHANGING lv_subrc.
          ENDIF.
          IF lv_subrc = 0.
            PERFORM f_save_data TABLES lt_bpv
                                CHANGING lv_subrc.
            IF lv_subrc = 0.
              PERFORM f_prepare_print_bpv TABLES lt_bpv
                                          USING gs_bpv-bukrs gs_bpv-zbpvn gs_bpv-budat
                                                gs_bpv-cheque gs_bpv-kursf pa_zbank.
              PERFORM f_print_form USING '' 'X' 'ZFTRS_F003' '' '' ''.
              MESSAGE s000(zab) WITH 'Data already saved'.
              LEAVE TO SCREEN 0.
            ELSE.
              MESSAGE s000(zab) WITH 'Number range belum dimaintain'
                                DISPLAY LIKE 'E'.
            ENDIF.
          ELSE.
            CASE lv_subrc.
              WHEN 1.
                MESSAGE s000(zab) WITH 'Fill in all required entry fields'
                                  DISPLAY LIKE 'E'.
              WHEN 2.
                MESSAGE s000(zab) WITH 'Total amount is difference'
                                  DISPLAY LIKE 'E'.
            ENDCASE.
          ENDIF.

        WHEN OTHERS.
          CALL METHOD g_tabgrid->check_changed_data
            IMPORTING
              e_valid = lv_valid.

          IF lv_valid IS NOT INITIAL.
            PERFORM f_posting_data.
          ENDIF.
      ENDCASE.

    WHEN '&OUP' OR '&ODN' OR '&OL0'.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.

      gt_xout[] = gt_out[].

    WHEN '&ILT'.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.

      CLEAR : gt_filter[].
      CALL METHOD g_tabgrid->get_filtered_entries
        IMPORTING
          et_filtered_entries = lt_fidx.

      IF lt_fidx[] IS INITIAL.
        PERFORM f_select USING ''.
      ELSE.
        LOOP AT lt_fidx INTO ls_fidx.
          ls_filter-index = ls_fidx.
          APPEND ls_filter TO gt_filter.
        ENDLOOP.
      ENDIF.

    WHEN 'CONT'.
      IF sy-dynnr = '0102'.
        IF lv_subrc = 0.
          IF p_trade = 'X'.
            PERFORM f_validate_receipt CHANGING lv_subrc.
            CLEAR : p_other, p_pindah.
          ELSEIF p_other = 'X'.
            CLEAR : p_trade, p_pindah.
            IF gv_descr IS INITIAL.
              lv_subrc = 4.
              MESSAGE s000(zab) WITH 'Fill in all required entry fields'
                                DISPLAY LIKE 'E'.
            ENDIF.
          ELSEIF p_pindah = 'X'.
            CLEAR : p_trade, p_other.
            IF gv_descr IS INITIAL.
              lv_subrc = 4.
              MESSAGE s000(zab) WITH 'Fill in all required entry fields'
                                DISPLAY LIKE 'E'.
            ENDIF.
          ENDIF.
        ELSE.
        ENDIF.
      ENDIF.

      IF lv_subrc = 0.
        CALL METHOD g_tabgrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          PERFORM f_modify_data.
          p_trade = 'X'.
          CLEAR : gv_kursf, p_other, p_pindah.
        ENDIF.
      ELSE.
        p_trade = 'X'.
        CLEAR : p_other, p_pindah.
      ENDIF.

      CLEAR : gv_customer, gv_descr.

    WHEN '&PREV'.
      CASE sy-dynnr.
        WHEN '0100'.
          PERFORM f_field_required TABLES   gt_bpvd
                                   CHANGING lv_subrc.
          IF lv_subrc = 0.
            PERFORM f_validate_data TABLES gt_bpvd
                                    CHANGING lv_subrc.
          ENDIF.
          IF lv_subrc = 0.
            IF lt_bpv[] IS INITIAL.
              LOOP AT gt_bpvd INTO ls_bpvd.
                MOVE-CORRESPONDING ls_bpvd TO ls_bpv.
                ls_bpv-wrbtr = ls_bpvd-wrbtr2.
                ls_bpv-waers = gs_bpv-waers.
                ls_bpv-descr = ls_bpvd-zdesc2.
                APPEND ls_bpv TO lt_bpv.
                CLEAR ls_bpv.
              ENDLOOP.
            ENDIF.
            PERFORM f_prepare_print_bpv TABLES lt_bpv
                                        USING gs_bpv-bukrs gs_bpv-zbpvn gs_bpv-budat
                                              gs_bpv-cheque gs_bpv-kursf pa_zbank.
            PERFORM f_print_form USING 'X' 'X' 'ZFTRS_F003' '' '' ''.
          ELSE.
            CASE lv_subrc.
              WHEN 1.
                MESSAGE s000(zab) WITH 'Fill in all required entry fields'
                                  DISPLAY LIKE 'E'.
              WHEN 2.
                MESSAGE s000(zab) WITH 'Total amount is difference'
                                  DISPLAY LIKE 'E'.
            ENDCASE.
          ENDIF.

        WHEN OTHERS.
          CALL METHOD g_tabgrid->check_changed_data
            IMPORTING
              e_valid = lv_valid.

          IF lv_valid IS NOT INITIAL.
            PERFORM f_prepare_print_brv USING pa_bukrs '' pa_budat
                                              pa_zbank pa_norek.
            PERFORM f_print_form USING 'X' 'X' 'ZFTRS_F002' '' '' ''.
          ENDIF.
      ENDCASE.

    WHEN OTHERS.
      IF radio5 <> 'X'.
        CALL METHOD g_tabgrid->set_function_code
          CHANGING
            c_ucomm = lv_ucomm.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_MAIN_ALV
*&---------------------------------------------------------------------*
FORM f_main_alv .
  IF g_tabgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_tabgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain01.

    PERFORM f_build_layout.
    PERFORM f_build_sort.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command FOR g_tabgrid.

    CALL METHOD g_tabgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_main_sort[]
        it_outtab            = <fs_out>[]
        it_fieldcatalog      = gt_main_fieldcat[].

    gt_xout[] = gt_out[].
  ENDIF.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
*  gs_layout_alv-sel_mode            = selected.
*  gs_layout_alv-box_fname           = 'CHECK'.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
*  gs_layout_alv-no_rowmark          = selected.
  gs_layout_alv-cwidth_opt          = selected.
  gs_layout_alv-stylefname          = 'STYLE'.
  gs_layout_alv-ctab_fname          = 'COLOR'.
  gs_layout_alv-zebra               = selected.
  gs_layout_alv-no_toolbar          = selected.
*  gs_layout_alv-totals_bef          = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
  CLEAR gt_main_sort.

*  PERFORM f_alv_sort USING : 1 'TKNUM' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  DATA : lr_tabdescr  TYPE REF TO cl_abap_structdescr,
         lt_dyn_table TYPE REF TO data,
         ls_line      TYPE REF TO data,
         lt_dfies     TYPE ddfields,
         ls_dfies     TYPE dfies,
         ls_fieldcat  TYPE lvc_s_fcat.

  CLEAR gt_main_fieldcat[].
  CASE 'X'.
    WHEN radio4.
      CREATE DATA lt_dyn_table LIKE LINE OF gt_r005.
    WHEN radio7.
      CREATE DATA lt_dyn_table LIKE LINE OF gt_r006.
    WHEN OTHERS.
      CREATE DATA lt_dyn_table LIKE LINE OF gt_out.
  ENDCASE.

  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lt_dyn_table ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).
  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR ls_fieldcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.
    CASE ls_dfies-fieldname.
      WHEN 'MARK'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' 'X' '' '' '' '' 'X' '' 'X' 'X' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'ICON'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Sts' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'BUZEI'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'No.' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'MENGE'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' 'MEINS' '' '' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'WRBTR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'DMBTR'.
        PERFORM f_change_dyn_fieldcat USING :
        'IDR' '' '' '' '' '' '' '' '' '' '' '' '' '' 'X' ''
        CHANGING ls_fieldcat.
      WHEN 'ZNOREK'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'No.Rekening' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'NAME1'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Company Receipt' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'KETERANGAN'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Keterangan' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
    ENDCASE.
    APPEND ls_fieldcat TO gt_main_fieldcat.
    CLEAR ls_fieldcat.
  ENDLOOP.
ENDFORM.                    " F_CREATE_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_int_table  USING    fu_fieldname fu_tabname
                               fu_currency fu_cfieldname fu_quantity
                               fu_qfieldname fu_checkbox fu_ref_field
                               fu_ref_table fu_coltext fu_outputlen
                               fu_inttype fu_no_out fu_edit fu_tech
                               fu_just fu_key fu_fix fu_icon fu_sum
                               fu_nosum.
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
  ls_dyn_fcat-inttype     = fu_inttype.
  ls_dyn_fcat-no_out      = fu_no_out.
  ls_dyn_fcat-tech        = fu_tech.
  ls_dyn_fcat-just        = fu_just.
  ls_dyn_fcat-key         = fu_key.
  ls_dyn_fcat-fix_column  = fu_fix.
  ls_dyn_fcat-icon        = fu_icon.
  ls_dyn_fcat-do_sum      = fu_sum.
  ls_dyn_fcat-no_sum      = fu_nosum.
  APPEND ls_dyn_fcat TO gt_main_fieldcat.
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
*&      Form  F_ALV_SORT
*&---------------------------------------------------------------------*
FORM f_alv_sort  USING    fu_spos fu_fieldname fu_up fu_down fu_subtot.

  gt_main_sort-spos      = fu_spos.
  gt_main_sort-fieldname = fu_fieldname.
  gt_main_sort-up        = fu_up.
  gt_main_sort-down      = fu_down.
  gt_main_sort-subtot    = fu_subtot.
  APPEND gt_main_sort.
  CLEAR gt_main_sort.
ENDFORM.                    " F_ALV_SORT

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check.
  DATA : ls_fieldcatalog    TYPE lvc_t_fcat WITH HEADER LINE.
  DATA : lv_style    TYPE lvc_s_styl-style,
         lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl,
         lv_tabix    TYPE sy-tabix,
         ls_filter   LIKE LINE OF gt_filter.

  DATA : ls_out             LIKE LINE OF gt_out.

  CALL METHOD g_tabgrid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = ls_fieldcatalog[].

  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'MARK'.
  IF sy-subrc = 0.
    IF ls_fieldcatalog-edit IS NOT INITIAL.
      LOOP AT gt_out INTO ls_out.
        lv_tabix = sy-tabix.

        READ TABLE ls_out-style INTO ls_stylerow
                                WITH KEY fieldname = 'MARK'.
        IF sy-subrc = 0 AND
            ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          CONTINUE.
        ENDIF.

        IF fu_check IS NOT INITIAL.
          CLEAR ls_filter.
          READ TABLE gt_filter INTO ls_filter
                               WITH KEY index = lv_tabix.
          IF sy-subrc = 0.
            CONTINUE.
          ENDIF.
        ENDIF.

        ls_out-mark = fu_check.
        MODIFY gt_out FROM ls_out.
        CLEAR ls_out.
      ENDLOOP.
    ENDIF.
    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refresh.
  IF fu_refresh IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    IF g_tabgrid IS NOT INITIAL.
      CALL METHOD g_tabgrid->refresh_table_display
        EXPORTING
          is_stable = gs_stable.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .
  DATA : lt_out  TYPE STANDARD TABLE OF ty_out,
         lt_xout TYPE STANDARD TABLE OF ty_out,
         lt_yout TYPE STANDARD TABLE OF ty_out,
         ls_out  LIKE LINE OF lt_out,
         ls_xout LIKE LINE OF lt_xout,
         ls_004  LIKE LINE OF gt_004.

  DATA : lv_subrc   TYPE sy-subrc,
         lv_zbrvn   TYPE zfidt005-zbrvn,
         lv_company TYPE zfidt004-company,
         lv_buzei   TYPE sy-tabix,
         lv_noopen,
         lv_noclose.

  READ TABLE gt_004 INTO ls_004 INDEX 1.
  IF sy-subrc = 0.
    lv_company = ls_004-company.
  ENDIF.

  lt_out[] = gt_out[].
  DELETE lt_out WHERE mark IS INITIAL.
  IF lt_out[] IS NOT INITIAL.
    READ TABLE lt_out INTO ls_out
                      WITH KEY trans = space.
    IF sy-subrc = 0.
      lv_buzei = ls_out-buzei.
      lv_subrc = 4.
      MESSAGE s000(zab) WITH 'Data belum bisa diposting' DISPLAY LIKE 'E'.
      ls_out-icon = icon_led_red.
      MODIFY gt_out FROM ls_out
                    TRANSPORTING icon
                    WHERE buzei = lv_buzei.
      CLEAR ls_out.
    ELSE.
      PERFORM f_check_number_ranges USING 'BRV' pa_bukrs pa_budat
                                    CHANGING lv_subrc.
      IF lv_subrc = 0.
        lt_xout[] = lt_out[].
        SORT lt_xout BY trans.
        DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING trans.
        LOOP AT lt_xout INTO ls_xout.
          AT FIRST.
            lv_noclose  = 'X'.
          ENDAT.

          AT LAST.
            lv_noclose  = space.
          ENDAT.

          PERFORM f_next_number USING 'BRV' pa_bukrs pa_budat lv_company
                                CHANGING lv_zbrvn.

          LOOP AT lt_out INTO ls_out WHERE trans = ls_xout-trans.
            APPEND ls_out TO lt_yout.
            CLEAR ls_out.
          ENDLOOP.
          PERFORM f_save_table TABLES lt_yout
                               USING lv_zbrvn
                               CHANGING lv_subrc.
          IF lv_subrc = 0.
            COMMIT WORK AND WAIT.
            PERFORM f_prepare_print_brv USING pa_bukrs lv_zbrvn pa_budat
                                              pa_zbank pa_norek.
            PERFORM f_print_form USING 'X' '' 'ZFTRS_F002' '' lv_noclose lv_noopen.
          ENDIF.
          lv_noopen = 'X'.
        ENDLOOP.
      ELSE.
        lv_subrc = 4.
        MESSAGE s000(zab) WITH 'Number range belum dimaintain'
                          DISPLAY LIKE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF lv_subrc = 0.
    MESSAGE s000(zab) WITH 'Data already saved'.
    LEAVE TO SCREEN 0.
  ENDIF.
  PERFORM f_alv_refresh USING 'X'.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_DYN_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_change_dyn_fieldcat  USING    fu_currency fu_cfieldname fu_quantity
                                     fu_qfieldname fu_checkbox fu_coltext
                                     fu_outputlen fu_inttype fu_no_out fu_edit
                                     fu_tech fu_key fu_fix fu_icon fu_sum
                                     fu_nosum
                            CHANGING fs_dyn_fcat  TYPE lvc_s_fcat.

  IF fu_coltext IS NOT INITIAL.
    PERFORM f_isi_judul USING fu_coltext '' '' ''
                        CHANGING fs_dyn_fcat-reptext fs_dyn_fcat-scrtext_l
                                 fs_dyn_fcat-scrtext_m fs_dyn_fcat-scrtext_s.
  ENDIF.

  PERFORM f_move_fieldcat USING fu_currency
                          CHANGING fs_dyn_fcat-currency.
  PERFORM f_move_fieldcat USING fu_cfieldname
                          CHANGING fs_dyn_fcat-cfieldname.
  PERFORM f_move_fieldcat USING fu_quantity
                          CHANGING fs_dyn_fcat-quantity.
  PERFORM f_move_fieldcat USING fu_qfieldname
                          CHANGING fs_dyn_fcat-qfieldname.
  PERFORM f_move_fieldcat USING fu_checkbox
                          CHANGING fs_dyn_fcat-checkbox.
  PERFORM f_move_fieldcat USING fu_edit
                          CHANGING fs_dyn_fcat-edit.
  PERFORM f_move_fieldcat USING fu_outputlen
                          CHANGING fs_dyn_fcat-outputlen.
  PERFORM f_move_fieldcat USING fu_inttype
                          CHANGING fs_dyn_fcat-inttype.
  PERFORM f_move_fieldcat USING fu_no_out
                          CHANGING fs_dyn_fcat-no_out.
  PERFORM f_move_fieldcat USING fu_tech
                          CHANGING fs_dyn_fcat-tech.
  PERFORM f_move_fieldcat USING fu_key
                          CHANGING fs_dyn_fcat-key.
  PERFORM f_move_fieldcat USING fu_fix
                          CHANGING fs_dyn_fcat-fix_column.
  PERFORM f_move_fieldcat USING fu_icon
                          CHANGING fs_dyn_fcat-icon.
  PERFORM f_move_fieldcat USING fu_sum
                          CHANGING fs_dyn_fcat-do_sum.
  PERFORM f_move_fieldcat USING fu_nosum
                          CHANGING fs_dyn_fcat-no_sum.
ENDFORM.                    " F_CHANGE_DYN_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_move_fieldcat  USING    fu_value
                      CHANGING fc_value.
  IF fu_value IS NOT INITIAL.
    fc_value = fu_value.
  ENDIF.
ENDFORM.                    " F_MOVE_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_GET_UPLOAD_DATA
*&---------------------------------------------------------------------*
FORM f_get_upload_data .
  DATA : filename  TYPE string,
         data_tab  TYPE STANDARD TABLE OF string,
         data_line LIKE LINE OF data_tab,
         lt_data   TYPE STANDARD TABLE OF ty_data,
         ls_data   LIKE LINE OF lt_data,
         itab      TYPE STANDARD TABLE OF string,
         xitab     TYPE STANDARD TABLE OF string,
         yitab     TYPE STANDARD TABLE OF string.

  DATA : lv_lines   TYPE c LENGTH 10,
         lv_string  TYPE string,
         lv_xstring TYPE xstring,
         lv_number  TYPE p DECIMALS 2,
         lv_count   TYPE n LENGTH 2,
         lv_field   TYPE c LENGTH 30,
         lv_subrc   TYPE sy-subrc,
         lv_budat   TYPE sy-datum,
         lv_flag    TYPE c LENGTH 1,
         lv_monat   TYPE c LENGTH 2,
         lv_month   TYPE c LENGTH 3,
         lv_zbank   TYPE zfidt004-zbank,
         lv_str01   TYPE string.

  FIELD-SYMBOLS <fs>  TYPE any.

  filename           = pa_fname.
  ASSIGN gt_data  TO <fs_table>.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename            = filename
      filetype            = 'ASC'
      has_field_separator = abap_true
    CHANGING
      data_tab            = data_tab.
  IF sy-subrc = 0.
    LOOP AT data_tab INTO data_line FROM gs_004-zrow.
      CLEAR lv_subrc.
      SPLIT data_line AT gs_004-delim INTO TABLE itab.
      CASE pa_zbank.
        WHEN 'STANDARD CHARTERED BANK'.
          xitab[] = itab[].
          CLEAR : itab[], lv_count.
          LOOP AT xitab INTO data_line.
            ADD 1 TO lv_count.
            IF lv_count = 2.
              APPEND data_line TO itab.
            ELSE.
              PERFORM f_cek_number USING data_line
                                   CHANGING lv_subrc.
              IF lv_subrc = 0.
                APPEND data_line TO itab.
              ELSE.
                SPLIT data_line AT c_comma INTO TABLE yitab.
                CLEAR data_line.
                LOOP AT yitab INTO data_line.
                  APPEND data_line TO itab.
                  CLEAR data_line.
                ENDLOOP.
              ENDIF.
              CLEAR yitab[].
            ENDIF.
          ENDLOOP.
        WHEN 'SMBC' OR 'CIMB NIAGA'.
          DELETE itab WHERE table_line = c_comma.
        WHEN OTHERS.
          DELETE itab WHERE table_line = c_comma.
          DELETE itab WHERE table_line IS INITIAL.
      ENDCASE.

      CLEAR lv_string.
      LOOP AT itab INTO DATA(ls_itab).
        lv_string = ls_itab.
        CLEAR lv_xstring.
        CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
          EXPORTING
            text   = lv_string
          IMPORTING
            buffer = lv_xstring.
        IF lv_xstring = '20'.
          DELETE itab.
        ELSE.
          IF sy-tabix = gs_004-zdcol.
            REPLACE ALL OCCURRENCES OF c_comma IN ls_itab WITH space.
            IF lv_flag IS INITIAL.
              lv_flag = 'X'.
              PERFORM f_posting_date USING pa_zbank ls_itab
                                     CHANGING lv_budat.
              IF lv_budat <> pa_budat.
                lv_subrc = 1.
                EXIT.
              ENDIF.
            ENDIF.
            MODIFY itab FROM ls_itab.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF lv_subrc = 0.
        CLEAR lv_count.
        DESCRIBE TABLE itab LINES lv_lines.
        IF lv_lines > 2.
          APPEND INITIAL LINE TO <fs_table> ASSIGNING <fs_wa>.
          LOOP AT itab INTO ls_itab.
            ADD 1 TO lv_count.
            CONCATENATE 'C' lv_count INTO lv_field.
            ASSIGN COMPONENT lv_field OF STRUCTURE <fs_wa> TO <fs>.
            <fs> = ls_itab.
          ENDLOOP.
        ENDIF.
      ELSEIF lv_subrc = 1.
        gv_subrc = 3.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MONTH_CONVERSION
*&---------------------------------------------------------------------*
FORM f_month_conversion  USING    fu_value
                         CHANGING fc_monat.
  CASE fu_value.
    WHEN 'Jan'.
      fc_monat = '01'.
    WHEN 'Feb'.
      fc_monat = '02'.
    WHEN 'Mar'.
      fc_monat = '03'.
    WHEN 'Apr'.
      fc_monat = '04'.
    WHEN 'May'.
      fc_monat = '05'.
    WHEN 'Jun'.
      fc_monat = '06'.
    WHEN 'Jul'.
      fc_monat = '07'.
    WHEN 'Aug'.
      fc_monat = '08'.
    WHEN 'Sep'.
      fc_monat = '09'.
    WHEN 'Oct'.
      fc_monat = '10'.
    WHEN 'Nov'.
      fc_monat = '11'.
    WHEN 'Dec'.
      fc_monat = '12'.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_UPLOAD_EXCEL_DATA
*&---------------------------------------------------------------------*
FORM f_get_upload_excel_data .
  DATA : intern    TYPE STANDARD TABLE OF alsmex_tabline,
         ls_intern TYPE alsmex_tabline,
         ls_data   LIKE LINE OF gt_data.

  DATA : i_begin_col TYPE i,
         i_begin_row TYPE i,
         i_end_col   TYPE i,
         i_end_row   TYPE i,
         lv_count    TYPE n LENGTH 2,
         lv_field    TYPE c LENGTH 30,
         lv_budat    TYPE sy-datum.

  FIELD-SYMBOLS : <fs>       TYPE any,
                  <fs_field> TYPE any.

  i_begin_col = 1.
  i_begin_row = 2.
  i_end_col   = 27.
  i_end_row   = 65000.

  IF gs_004-zrow IS NOT INITIAL.
    i_begin_row = gs_004-zrow.
  ENDIF.

*  ASSIGN gt_data  TO <fs_table>.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = pa_fname
      i_begin_col             = i_begin_col
      i_begin_row             = i_begin_row
      i_end_col               = i_end_col
      i_end_row               = i_end_row
    TABLES
      intern                  = intern
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  SORT intern BY row col.
  LOOP AT intern INTO ls_intern.
    CASE ls_intern-col.
      WHEN gs_004-zdcol.
        PERFORM f_check_value_date USING ls_intern-value.
        CONCATENATE 'LS_DATA-C' gs_004-zdcol+1(2) INTO lv_field.
        ASSIGN (lv_field) TO <fs>.
        <fs> = ls_intern-value.
        CONCATENATE <fs>+6(4) <fs>+3(2) <fs>(2) INTO lv_budat.
        IF lv_budat <> pa_budat.
          gv_subrc = 3.
          EXIT.
        ENDIF.
      WHEN gs_004-zkcol.
        CONCATENATE 'LS_DATA-C' gs_004-zkcol+1(2) INTO lv_field.
        ASSIGN (lv_field) TO <fs>.
        <fs> = ls_intern-value.
      WHEN gs_004-zacol.
        CONCATENATE 'LS_DATA-C' gs_004-zacol+1(2) INTO lv_field.
        ASSIGN (lv_field) TO <fs>.
        IF gs_004-zdeci = '.'.
          TRANSLATE ls_intern-value USING ', '.
          TRANSLATE ls_intern-value USING '.,'.
        ELSE.
          TRANSLATE ls_intern-value USING '. '.
          TRANSLATE ls_intern-value USING ',.'.
        ENDIF.
        CONDENSE ls_intern-value NO-GAPS.
        <fs> = ls_intern-value.
    ENDCASE.

    AT END OF row.
      APPEND ls_data TO gt_data.
      CLEAR : ls_data, lv_count.
    ENDAT.
  ENDLOOP.

  ASSIGN gt_data TO <fs_table>.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TABLE
*&---------------------------------------------------------------------*
FORM f_save_table  TABLES   ft_out LIKE gt_out
                   USING    fu_zbrvn
                   CHANGING fc_subrc.
  DATA : lt_005 TYPE STANDARD TABLE OF zfidt005,
         ls_005 LIKE LINE OF lt_005,
         ls_out LIKE LINE OF gt_out.

  DATA : lv_shkzg TYPE bseg-shkzg.

  lv_shkzg = 'H'.

  SORT ft_out BY bukrs budat zbank.
  LOOP AT ft_out INTO ls_out.
    ls_005-zbrvn        = fu_zbrvn.
    ls_005-bukrs        = ls_out-bukrs.
    ls_005-kunnr        = ls_out-kunnr.
    ls_005-name1        = ls_out-name1.
    ls_005-budat        = ls_out-budat.
    ls_005-zbank        = ls_out-zbank.
    ls_005-znorek       = pa_norek.
    ls_005-buzei        = ls_out-buzei.
    ls_005-shkzg        = lv_shkzg.
    ls_005-kursf        = ls_out-kursf.
    ls_005-wrbtr        = ls_out-wrbtr.
    ls_005-dmbtr        = ls_out-dmbtr.
    ls_005-waers        = ls_out-waers.
    ls_005-zbrvn        = fu_zbrvn.
    ls_005-trans        = ls_out-trans.
    ls_005-descr        = ls_out-descr.
    ls_005-keterangan   = ls_out-keterangan.
    APPEND ls_005 TO lt_005.
    CLEAR ls_005.
  ENDLOOP.

  IF lt_005[] IS NOT INITIAL.
    TRY .
        INSERT zfidt005 FROM TABLE lt_005.
      CATCH cx_sy_open_sql_db.
        fc_subrc = 4.
    ENDTRY.

    IF fc_subrc = 0.
      CLEAR : gt_x005[], ft_out[].
      gt_x005[] = lt_005[].
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_PRINT_BRV
*&---------------------------------------------------------------------*
FORM f_prepare_print_brv  USING    fu_bukrs fu_number fu_budat fu_zbank
                                   fu_norek.
  DATA : lt_skat   TYPE STANDARD TABLE OF skat,
         ls_skat   LIKE LINE OF lt_skat,
         ls_004    LIKE LINE OF gt_004,
         ls_x005   LIKE LINE OF gt_x005,
         ls_t001   LIKE LINE OF gt_t001,
         ls_detail LIKE LINE OF gt_detail,
         lt_005    TYPE STANDARD TABLE OF zfidt005,
         ls_005    LIKE LINE OF lt_005,
         lt_kna1   TYPE STANDARD TABLE OF kna1,
         ls_kna1   LIKE LINE OF lt_kna1.

  DATA : lv_date(10),
         lv_zbrvn        TYPE zfidt005-zbrvn,
         lv_wrbtr        TYPE bseg-wrbtr,
         in_words        TYPE spell,
         lv_langu        TYPE sy-langu,
         lv_waers        TYPE bkpf-waers,
         lv_buzei        TYPE bseg-buzei,
         lv_company(100),
         lv_kursf        TYPE c LENGTH 20,
         lv_frbtr        TYPE bseg-dmbtr,
         lv_trans        TYPE zfidt005-trans,
         lv_norek        TYPE zfidt005-znorek,
         lv_value        TYPE c LENGTH 20,
         lv_name1        TYPE kna1-name1.

  CLEAR : gs_header, gt_detail[], gt_window3[].

  READ TABLE gt_x005 INTO ls_x005 INDEX 1.

  IF fu_number IS INITIAL.
    IF pa_zuonr IS INITIAL.
      lv_zbrvn         = ls_x005-zbrvn.
    ELSE.
      lv_zbrvn         = pa_zuonr.
    ENDIF.
  ELSE.
    lv_zbrvn         = fu_number.
  ENDIF.

  IF fu_norek IS INITIAL.
    lv_norek = ls_x005-znorek.
  ELSE.
    lv_norek = fu_norek.
  ENDIF.
  gs_header-title  = 'BANK RECEIPT VOUCHER'.
  gs_header-bukrs  = fu_bukrs.
  SELECT SINGLE butxt name1
    FROM t001 JOIN adrc ON t001~adrnr = adrc~addrnumber
    INTO ( gs_header-butxt, gs_header-name1 )
    WHERE bukrs = gs_header-bukrs.
*  CONCATENATE pa_bukrs '-' gs_header-butxt INTO lv_company
*  SEPARATED BY space.
  CONCATENATE pa_bukrs '-' gs_header-name1 INTO lv_company
  SEPARATED BY space.
  TRANSLATE lv_company TO UPPER CASE.

  READ TABLE gt_004 INTO ls_004
                    WITH KEY bukrs  = fu_bukrs
                             zbank  = fu_zbank
                             znorek = lv_norek.

  WRITE fu_budat TO lv_date DD/MM/YYYY.
  CONCATENATE pa_zbank ls_004-waers INTO gs_header-txt20
  SEPARATED BY space.

  PERFORM f_header_window3 USING : 'Nomor Voucher' ':' fu_number ''
                                   'Receipt Date' ':' lv_date.
  PERFORM f_header_window3 USING : 'No.SAP' ':' '' ''
                                   'Bank Name' ':' gs_header-txt20.
  PERFORM f_header_window3 USING : 'Departemen' ':' 'Treasury' ''
                                   'Bank Account No.' ':' lv_norek.

  gs_header-zuonr = fu_number.

  lt_005[] = gt_x005[].
  SORT lt_005 BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_005 COMPARING kunnr.
  IF lt_005[] IS NOT INITIAL.
    SELECT *
      FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE lt_kna1
      FOR ALL ENTRIES IN lt_005
      WHERE kunnr = lt_005-kunnr.
  ENDIF.

  SORT gt_x005 BY zbank kunnr.
  LOOP AT gt_x005 INTO ls_x005 WHERE bukrs = fu_bukrs
                                 AND zbank = fu_zbank
                                 AND zbrvn = lv_zbrvn.
    CASE ls_x005-trans.
      WHEN 'TRADE'.
        CLEAR ls_kna1.
        READ TABLE lt_kna1 INTO ls_kna1
                           WITH KEY kunnr = ls_x005-kunnr.
        IF sy-subrc = 0.
          lv_name1  = ls_kna1-name1.
        ELSE.
          lv_name1  = ls_x005-name1.
        ENDIF.

        lv_frbtr = ls_x005-kursf * 10.
        WRITE lv_frbtr TO lv_kursf CURRENCY 'IDR'.
        CONDENSE lv_kursf NO-GAPS.
        IF ls_x005-waers = 'IDR'.
          CONCATENATE 'Terima dari' lv_name1
          INTO ls_detail-desc100
          SEPARATED BY space.
        ELSE.
          WRITE ls_x005-wrbtr TO lv_value CURRENCY ls_x005-waers.
          CONDENSE lv_value NO-GAPS.
          CONCATENATE ls_x005-waers lv_value '@ Rp.' lv_kursf
          INTO ls_detail-desc100
          SEPARATED BY space.
          CONCATENATE 'Terima dari' lv_name1 ls_detail-desc100
          INTO ls_detail-desc100
          SEPARATED BY space.
        ENDIF.
        ls_detail-wrbtr = ls_x005-dmbtr.
        lv_waers  = 'IDR'.
        lv_langu  = 'id'.
      WHEN 'OTHERS'.
        lv_frbtr = ls_x005-kursf * 1000.
        WRITE lv_frbtr TO lv_kursf CURRENCY ls_x005-waers.
        CONDENSE lv_kursf NO-GAPS.
        IF ls_x005-waers = 'IDR'.
          ls_detail-desc100 = ls_x005-descr.
        ELSE.
          WRITE ls_x005-wrbtr TO lv_value CURRENCY ls_x005-waers.
          CONDENSE lv_value NO-GAPS.
          CONCATENATE ls_x005-waers lv_value '@ Rp.' lv_kursf
          INTO ls_detail-desc100
          SEPARATED BY space.
          CONCATENATE ls_x005-descr ls_detail-desc100
          INTO ls_detail-desc100
          SEPARATED BY space.
        ENDIF.
        ls_detail-wrbtr = ls_x005-dmbtr.
        lv_waers  = 'IDR'.
        lv_langu  = 'id'.
      WHEN 'PEMINDAHAN'.
        lv_frbtr = ls_x005-kursf * 1000.
        WRITE lv_frbtr TO lv_kursf CURRENCY ls_x005-waers.
        CONDENSE lv_kursf NO-GAPS.
        IF ls_x005-waers = 'IDR'.
          ls_detail-desc100 = ls_x005-descr.
        ELSE.
          CONCATENATE '@' ls_x005-waers INTO ls_detail-desc100.
          CONCATENATE ls_x005-descr ls_detail-desc100 lv_kursf
          INTO ls_detail-desc100
          SEPARATED BY space.
        ENDIF.
        ls_detail-wrbtr = ls_x005-wrbtr.
        lv_waers  = ls_x005-waers.
        IF ls_x005-waers = 'IDR'.
          lv_langu  = 'id'.
        ELSE.
          lv_langu  = sy-langu.
        ENDIF.
    ENDCASE.
    ls_detail-waers = lv_waers.
    ADD ls_detail-wrbtr TO lv_wrbtr.
    COLLECT ls_detail INTO gt_detail.
    CLEAR ls_detail.
  ENDLOOP.

  LOOP AT gt_detail INTO ls_detail.
    ADD 1 TO lv_buzei.
    ls_detail-buzei = lv_buzei.
    SHIFT ls_detail-buzei LEFT DELETING LEADING '0'.
    WRITE ls_detail-wrbtr TO ls_detail-wrbtrt CURRENCY ls_detail-waers.
    MODIFY gt_detail FROM ls_detail
                     TRANSPORTING buzei wrbtrt.
    CLEAR ls_detail.
  ENDLOOP.

  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount    = lv_wrbtr
      currency  = lv_waers
      language  = lv_langu
    IMPORTING
      in_words  = in_words
    EXCEPTIONS
      not_found = 1
      too_large = 2
      OTHERS    = 3.

  IF lv_waers = 'IDR'.
    CONCATENATE in_words-word 'RUPIAH' INTO gs_header-terbilang SEPARATED BY space.
    TRANSLATE gs_header-terbilang TO UPPER CASE.
  ELSE.
    IF in_words-decimal = 0.
      CONCATENATE lv_waers in_words-word
      INTO gs_header-terbilang SEPARATED BY space.
    ELSE.
      CONCATENATE lv_waers in_words-word 'AND' in_words-decword 'CENTS'
      INTO gs_header-terbilang SEPARATED BY space.
      TRANSLATE gs_header-terbilang TO UPPER CASE.
    ENDIF.
  ENDIF.
  WRITE lv_wrbtr TO gs_header-totalt CURRENCY lv_waers.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_WINDOW3
*&---------------------------------------------------------------------*
FORM f_header_window3  USING    fu_cell14 fu_cell15 fu_cell16 fu_cell17
                                fu_cell18 fu_cell19 fu_cell20.
  DATA : ls_window3   LIKE LINE OF gt_window3.

  ls_window3-cell14 = fu_cell14.
  ls_window3-cell15 = fu_cell15.
  ls_window3-cell16 = fu_cell16.
  ls_window3-cell17 = fu_cell17.
  ls_window3-cell18 = fu_cell18.
  ls_window3-cell19 = fu_cell19.
  ls_window3-cell20 = fu_cell20.
  APPEND ls_window3 TO gt_window3.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form USING fu_prev fu_dialog fu_fname fu_all fu_noclose fu_noopen.
  DATA : lv_fname           TYPE ssfscreen-fname,
         lv_funcname        TYPE rs38l_fnam,
         filename           TYPE string,
         lwa_output_option  TYPE ssfcompop,
         lwa_control_option TYPE ssfctrlop,
         stripped_name      TYPE rlgrap-filename,
         extension          TYPE string,
         lv_dialog.

*  DATA : gt_detail  TYPE STANDARD TABLE OF zfexpstprnt.

  DATA : job_output_info    TYPE ssfcrescl,
         job_output_options TYPE ssfcresop.

  lv_fname = fu_fname.
  IF pa_pdfnm IS NOT INITIAL.
    lv_dialog = space.
  ELSE.
    lv_dialog = fu_dialog.
  ENDIF.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_fname
    IMPORTING
      fm_name            = lv_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc = 0.
    IF fu_all IS INITIAL.
      IF lv_dialog IS INITIAL.
        lwa_control_option-no_dialog = 'X'.
        lwa_output_option-tdnewid    = 'X'.
        lwa_output_option-tdimmed    = 'X'.
      ELSE.
        IF fu_prev IS INITIAL.
          lwa_output_option-tdnoprev  = 'X'.
          lwa_output_option-tdnewid   = 'X'.
        ELSE.
          lwa_output_option-tdnoprint = 'X'.
        ENDIF.
      ENDIF.
    ELSE.
      IF lv_dialog IS INITIAL.
        lwa_control_option-no_dialog = 'X'.
        lwa_output_option-tdnewid    = 'X'.
        lwa_output_option-tdimmed    = 'X'.
      ENDIF.
    ENDIF.

    lwa_control_option-no_close = fu_noclose.
    lwa_control_option-no_open  = fu_noopen.

    IF pa_pdfnm IS NOT INITIAL.
      filename  = pa_pdfnm.
      PERFORM f_split_file USING pa_pdfnm
                           CHANGING stripped_name.
      SPLIT stripped_name AT '.' INTO stripped_name extension.
      TRANSLATE extension TO UPPER CASE.
      IF extension = 'PDF'.
        lwa_control_option-getotf       = 'X'.
      ENDIF.
    ENDIF.

    CALL FUNCTION lv_funcname
      EXPORTING
        output_options     = lwa_output_option
        control_parameters = lwa_control_option
        user_settings      = 'X'
        gs_header          = gs_header
      IMPORTING
        job_output_info    = job_output_info
        job_output_options = job_output_options
      TABLES
        gt_window3         = gt_window3
        gt_detail          = gt_detail
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    PERFORM f_send_to_pdf USING job_output_info job_output_options
                                filename.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_handle_double_click  USING    fu_row fu_column.
  DATA : lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.

  DATA : lv_waers TYPE bkpf-waers,
         lv_dmbtr TYPE bseg-dmbtr.

  CLEAR : gs_out, gv_keterangan, gv_wrbtr, gv_waers, gv_kursf.
  READ TABLE gt_out INTO gs_out INDEX fu_row.
  IF sy-subrc = 0.
    READ TABLE gs_out-style INTO ls_stylerow
                            WITH KEY fieldname = 'MARK'.
    IF sy-subrc = 0 AND
      ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    ELSE.
      gv_keterangan = gs_out-keterangan.
      gv_wrbtr      = gs_out-wrbtr.
      gv_waers      = gs_out-waers.
      gv_row        = fu_row.
      p_trade       = 'X'.
      CLEAR : p_other, p_pindah.
      IF gv_waers <> 'IDR'.
        lv_waers = 'IDR'.
        PERFORM f_convert_to_local_currency USING gs_out-budat gs_out-wrbtr
                                                  gs_out-waers lv_waers
                                            CHANGING gv_kursf lv_dmbtr.
      ENDIF.

      CALL SCREEN 102 STARTING AT 10 10.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_CUSTOMER
*&---------------------------------------------------------------------*
FORM f_value_customer .
  TYPES : BEGIN OF ty_cabang,
            kunnr	TYPE zfidt004c-kunnr,
            name1	TYPE zfidt004c-name1,
          END OF ty_cabang.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval,
         field_tab  TYPE STANDARD TABLE OF dfies,
         ls_return  LIKE LINE OF return_tab,
         lt_cabang  TYPE STANDARD TABLE OF ty_cabang,
         ls_cabang  LIKE LINE OF lt_cabang,
         ls_004c    LIKE LINE OF gt_004c.

  DATA : lv_subrc   TYPE sy-subrc.

  LOOP AT gt_004c INTO ls_004c.
    ls_cabang-kunnr = ls_004c-kunnr.
    ls_cabang-name1 = ls_004c-name1.
    APPEND ls_cabang TO lt_cabang.
    CLEAR ls_cabang.
  ENDLOOP.

*  SELECT *
*    FROM biw_knb1t
*    INTO CORRESPONDING FIELDS OF TABLE lt_cabang
*    WHERE bukrs = pa_bukrs.

  ASSIGN lt_cabang[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'CUSTOMER' 'GV_CUSTOMER'
                          CHANGING lv_subrc.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM f_value_request  TABLES   return_tab STRUCTURE ddshretval
                      USING    fu_retfield fu_dynprofield
                      CHANGING fc_subrc.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield         = fu_retfield
      dynpprog         = sy-repid
      dynpnr           = sy-dynnr
      dynprofield      = fu_dynprofield
      value_org        = 'S'
      callback_program = sy-repid
      callback_form    = 'F4CALLBACK'
    TABLES
      value_tab        = <fs_tab>
      return_tab       = return_tab.

  fc_subrc         = sy-subrc.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f4callback
*&---------------------------------------------------------------------*
FORM f4callback TABLES   record_tab STRUCTURE seahlpres
                CHANGING shlp TYPE shlp_descr
                         callcontrol LIKE ddshf4ctrl.

  shlp-intdescr-dialogtype = 'D'.
  callcontrol-no_maxdisp = ''.
  callcontrol-maxrecords = 500.
ENDFORM.                                                    "f4callback

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DATA
*&---------------------------------------------------------------------*
FORM f_modify_data .
  DATA : ls_out  LIKE LINE OF gt_out,
         ls_004c LIKE LINE OF gt_004c.
*         ls_biw_knb1t LIKE LINE OF gt_biw_knb1t.

  gs_out-icon    = space.
  gs_out-name1   = gv_customer.

  IF p_trade = 'X'.
    CLEAR ls_004c.
    READ TABLE gt_004c INTO ls_004c
                       WITH KEY name1 = gv_customer.
    IF sy-subrc = 0.
      gs_out-kunnr  = ls_004c-kunnr.
      gs_out-mark   = 'X'.
      gs_out-trans  = 'TRADE'.
      gs_out-descr  = gv_descr.
      gs_out-name1  = gv_customer.
      PERFORM f_calculate_amount USING gs_out-budat gs_out-wrbtr
                                       gs_out-waers gv_waers gv_kursf
                                 CHANGING gs_out-dmbtr gs_out-kursf.
      MODIFY gt_out FROM gs_out INDEX gv_row.
    ENDIF.
  ELSEIF p_other = 'X'.
    CLEAR ls_004c.
    READ TABLE gt_004c INTO ls_004c
                       WITH KEY name1 = gv_customer.
    IF sy-subrc = 0.
      gs_out-kunnr  = ls_004c-kunnr.
    ENDIF.
    gs_out-mark   = 'X'.
    gs_out-trans  = 'OTHERS'.
    gs_out-descr  = gv_descr.
    gs_out-name1  = gv_customer.
    PERFORM f_calculate_amount USING gs_out-budat gs_out-wrbtr
                                     gs_out-waers gv_waers gv_kursf
                               CHANGING gs_out-dmbtr gs_out-kursf.
    MODIFY gt_out FROM gs_out INDEX gv_row.
  ELSEIF p_pindah = 'X'.
    CLEAR ls_004c.
    READ TABLE gt_004c INTO ls_004c
                       WITH KEY name1 = gv_customer.
    IF sy-subrc = 0.
      gs_out-kunnr  = ls_004c-kunnr.
    ENDIF.
    gs_out-mark   = 'X'.
    gs_out-trans  = 'PEMINDAHAN'.
    gs_out-descr  = gv_descr.
    gs_out-name1  = gv_customer.
    PERFORM f_calculate_amount USING gs_out-budat gs_out-wrbtr
                                     gs_out-waers gv_waers gv_kursf
                               CHANGING gs_out-dmbtr gs_out-kursf.
    MODIFY gt_out FROM gs_out INDEX gv_row.
  ENDIF.

  CLEAR : gs_out, gv_customer.

  PERFORM f_alv_refresh USING 'X'.
  LEAVE TO SCREEN 0.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_NEXT_NUMBER
*&---------------------------------------------------------------------*
FORM f_next_number  USING fu_process fu_bukrs fu_budat fu_company
                    CHANGING fc_value.
  DATA : lv_nrrange TYPE inri-nrrangenr,
         lv_object  TYPE inri-object,
         lv_gjahr   TYPE inri-toyear,
         ls_nriv    TYPE nriv,
         lv_number  TYPE c LENGTH 8.

  CLEAR : fc_value.

  lv_nrrange    = fu_budat+4(2).
  lv_gjahr      = fu_budat(4).

  CASE fu_process.
    WHEN 'BPV'.
      lv_object     = 'ZTRS_BP'.
    WHEN 'BRV'.
      lv_object     = 'ZTRS_AFFI'.
  ENDCASE.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = lv_nrrange
      object                  = lv_object
      toyear                  = lv_gjahr
      subobject               = fu_bukrs
    IMPORTING
      number                  = lv_number
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.

  fc_value = fu_company.
  CONCATENATE fc_value lv_number
  INTO fc_value.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_REVERSE_DATA
*&---------------------------------------------------------------------*
FORM f_reverse_data USING fu_process.
  DATA : answer,
         lv_text(100).

  lv_text = 'Data sudah ada, apakah mau direverse ?'.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Confirm'
      text_question         = lv_text
      display_cancel_button = ''
    IMPORTING
      answer                = answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF answer = '1'.
    CASE fu_process.
      WHEN 'BRV'.
        DELETE FROM zfidt005 WHERE bukrs = pa_bukrs
                               AND budat = pa_budat
                               AND zbank = pa_zbank
                               AND zbrvn = pa_zuonr.
      WHEN 'BPV'.
        DELETE FROM zfidt006 WHERE bukrs  = pa_bukrs
                               AND budat  = pa_budat
                               AND zbank1 = pa_zbank
                               AND zbpvn  = pa_zuon1.
    ENDCASE.

    COMMIT WORK.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_REPORT
*&---------------------------------------------------------------------*
FORM f_process_report .
  DATA : ls_x005 LIKE LINE OF gt_x005,
         ls_004  LIKE LINE OF gt_004,
         ls_r005 LIKE LINE OF gt_r005,
         ls_r006 LIKE LINE OF gt_r006,
         ls_bpv  LIKE LINE OF gt_bpv.

  CASE 'X'.
    WHEN radio4.
      LOOP AT gt_x005 INTO ls_x005.
        ls_r005-bukrs = ls_x005-bukrs.
        ls_r005-zbrvn = ls_x005-zbrvn.
        ls_r005-budat = ls_x005-budat.
        ls_r005-zbank = ls_x005-zbank.
        ls_r005-znorek = ls_x005-znorek.
        ls_r005-buzei = ls_x005-buzei.
        ls_r005-kunnr = ls_x005-kunnr.
        ls_r005-name1 = ls_x005-name1.
        ls_r005-shkzg = ls_x005-shkzg.
        ls_r005-kursf = ls_x005-kursf.
        ls_r005-wrbtr = ls_x005-wrbtr.
        ls_r005-dmbtr = ls_x005-dmbtr.
        ls_r005-waers = ls_x005-waers.
        ls_r005-trans = ls_x005-trans.
        ls_r005-descr = ls_x005-descr.
        ls_r005-keterangan = ls_x005-keterangan.
        APPEND ls_r005 TO gt_r005.
        CLEAR ls_r005.
      ENDLOOP.
      ASSIGN gt_r005 TO <fs_out>.

    WHEN radio7.
      LOOP AT gt_bpv INTO ls_bpv.
        ls_r006-bukrs = ls_bpv-bukrs.
        ls_r006-zbpvn = ls_bpv-zbpvn.
        ls_r006-budat = ls_bpv-budat.
        ls_r006-zbank1 = ls_bpv-zbank1.
        ls_r006-znorek1 = ls_bpv-znorek1.
        ls_r006-zbank2 = ls_bpv-zbank2.
        ls_r006-znorek2 = ls_bpv-znorek2.
        ls_r006-buzei = ls_bpv-buzei.
        ls_r006-shkzg = ls_bpv-shkzg.
        ls_r006-kursf = ls_bpv-kursf.
        ls_r006-wrbtr = ls_bpv-wrbtr.
        ls_r006-dmbtr = ls_bpv-dmbtr.
        ls_r006-waers = ls_bpv-waers.
        ls_r006-cheque = ls_bpv-cheque.
        ls_r006-descr = ls_bpv-descr.
        APPEND ls_r006 TO gt_r006.
        CLEAR ls_r006.
      ENDLOOP.
      ASSIGN gt_r006 TO <fs_out>.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_F4_BANK
*&---------------------------------------------------------------------*
FORM f_f4_bank  USING    fu_field fu_bukrs fu_retfield fu_field1.
  TYPES : BEGIN OF ty_bank,
            zbank TYPE zfidt004-zbank,
          END OF ty_bank.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval,
         field_tab  TYPE STANDARD TABLE OF dfies,
         ls_return  LIKE LINE OF return_tab,
         lt_bank    TYPE STANDARD TABLE OF ty_bank,
         ls_bank    LIKE LINE OF lt_bank.

  DATA : lv_bukrs TYPE zfidt004-bukrs,
         lv_subrc TYPE sy-subrc,
         lv_zbank TYPE zfidt004-zbank.

  PERFORM f_dynp_value_read USING fu_bukrs ''
                            CHANGING lv_bukrs.

  SELECT *
    FROM zfidt004
    INTO CORRESPONDING FIELDS OF TABLE lt_bank
    WHERE bukrs = lv_bukrs.

  SORT lt_bank BY zbank.
  DELETE ADJACENT DUPLICATES FROM lt_bank COMPARING zbank.
  ASSIGN lt_bank[] TO <fs_tab>.
  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING fu_retfield fu_field
                          CHANGING lv_subrc.
  IF lv_subrc = 0.
*    READ TABLE return_tab INTO ls_return INDEX 1.
*    IF sy-subrc = 0.
*      lv_zbank  = ls_return-fieldval.
*      READ TABLE lt_bank INTO ls_bank
*                         WITH KEY zbank = lv_zbank.
*      IF sy-subrc = 0.
*        PERFORM f_dynpfield TABLES dynpfields
*                            USING fu_field ls_bank-zbank ''.
*        PERFORM f_dynpfield TABLES dynpfields
*                            USING fu_field1 ls_bank-znorek ''.
*      ENDIF.
*      PERFORM f_dyn_values_update.
*    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DYNP_VALUE_READ
*&---------------------------------------------------------------------*
FORM f_dynp_value_read  USING    fieldname fu_stepl
                        CHANGING fc_value.

  DATA : lt_dynpfields TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0,
         ls_dynpfields LIKE LINE OF lt_dynpfields.

  ls_dynpfields-fieldname   = fieldname.
  APPEND ls_dynpfields TO lt_dynpfields.
  CLEAR ls_dynpfields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
      request              = 'A'
    TABLES
      dynpfields           = lt_dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.

  IF fu_stepl IS INITIAL.
    READ TABLE lt_dynpfields INTO ls_dynpfields
                             WITH KEY fieldname = fieldname.
  ELSE.
    READ TABLE lt_dynpfields INTO ls_dynpfields
                             WITH KEY fieldname = fieldname
                                      stepl     = fu_stepl.
  ENDIF.
  fc_value  = ls_dynpfields-fieldvalue.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DYN_VALUES_UPDATE
*&---------------------------------------------------------------------*
FORM f_dyn_values_update .
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DYNPFIELD
*&---------------------------------------------------------------------*
FORM f_dynpfield  TABLES   dynpfields STRUCTURE dynpread
                  USING    fieldname fieldvalue fu_waers.

  DATA : ls_dynpfields  LIKE LINE OF dynpfields.

  ls_dynpfields-fieldname  = fieldname.
  IF fu_waers IS NOT INITIAL.
    ls_dynpfields-fieldvalue = fieldvalue.
    TRANSLATE ls_dynpfields-fieldvalue USING '. '.
    CONDENSE ls_dynpfields-fieldvalue NO-GAPS.
  ELSE.
    ls_dynpfields-fieldvalue = fieldvalue.
  ENDIF.
  APPEND ls_dynpfields TO dynpfields.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data TABLES   ft_bpv    STRUCTURE zfidt006
                 CHANGING fc_subrc.
  DATA : ls_004  TYPE zfidt004,
         ls_bpvd TYPE ty_bpvd,
         ls_bpv  TYPE zfidt006.

  DATA : lv_company TYPE zfidt004-company,
         lv_subrc   TYPE sy-subrc,
         lv_waers   TYPE bkpf-waers,
         lv_buzei   TYPE zfidt006-buzei.

  CLEAR : ft_bpv[], fc_subrc.

  SELECT *
    FROM zfidt004
    INTO CORRESPONDING FIELDS OF TABLE gt_004
    WHERE bukrs = gs_bpv-bukrs.

  READ TABLE gt_004 INTO ls_004 INDEX 1.
  IF sy-subrc = 0.
    lv_company = ls_004-company.
  ENDIF.

  PERFORM f_check_number_ranges USING 'BPV' gs_bpv-bukrs gs_bpv-budat
                                CHANGING lv_subrc.
  IF lv_subrc = 0.
    PERFORM f_next_number USING 'BPV' gs_bpv-bukrs gs_bpv-budat lv_company
                          CHANGING gs_bpv-zbpvn.
    gs_bpv-shkzg = 'S'.

    LOOP AT gt_bpvd INTO ls_bpvd.
      ls_bpv-bukrs   = gs_bpv-bukrs.
      ls_bpv-zbpvn   = gs_bpv-zbpvn.
      ls_bpv-budat   = gs_bpv-budat.
      ls_bpv-zbank1  = gs_bpv-zbank1.
      ls_bpv-znorek1 = gs_bpv-znorek1.
      ls_bpv-cheque  = gs_bpv-cheque.
      ls_bpv-waers   = gs_bpv-waers.
      ls_bpv-shkzg   = gs_bpv-shkzg.
      ls_bpv-kursf   = gs_bpv-kursf.
      ADD 1 TO lv_buzei.
      ls_bpv-buzei   = lv_buzei.
      ls_bpv-zbank2  = ls_bpvd-zbank2.
      ls_bpv-znorek2 = ls_bpvd-znorek2.
      ls_bpv-wrbtr   = ls_bpvd-wrbtr2.
      ls_bpv-descr   = ls_bpvd-zdesc2.
      IF gs_bpv-waers <> 'IDR'.
        IF gs_bpv-kursf IS INITIAL.
          PERFORM f_convert_to_local_currency USING gs_bpv-budat ls_bpv-wrbtr
                                                    gs_bpv-waers lv_waers
                                              CHANGING ls_bpv-kursf ls_bpv-dmbtr.
        ELSE.
          ls_bpv-dmbtr = ls_bpv-wrbtr * ls_bpv-kursf.
        ENDIF.
      ELSE.
        ls_bpv-dmbtr = ls_bpv-wrbtr.
        CLEAR ls_bpv-kursf.
      ENDIF.
      APPEND ls_bpv TO ft_bpv.
      CLEAR ls_bpv.
    ENDLOOP.

    TRY .
        INSERT zfidt006 FROM TABLE ft_bpv.
      CATCH cx_sy_open_sql_db.
    ENDTRY.
  ELSE.
    fc_subrc = 4.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_REQUIRED
*&---------------------------------------------------------------------*
FORM f_field_required  TABLES   ft_bpv    LIKE gt_bpvd
                       CHANGING fc_subrc.
  DATA : ls_bpv   LIKE LINE OF gt_bpvd.

  CASE sy-dynnr.
    WHEN '0100'.
      IF gs_bpv-znorek1 IS INITIAL.
        fc_subrc = 1.
      ELSE.
        READ TABLE ft_bpv INTO ls_bpv
                          WITH KEY znorek2 = space.
        IF sy-subrc = 0.
          fc_subrc = 1.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_PRINT_BPV
*&---------------------------------------------------------------------*
FORM f_prepare_print_bpv  TABLES   ft_bpv   STRUCTURE zfidt006
                          USING    fu_bukrs fu_number fu_budat fu_cheque
                                   fu_kursf fu_zbank.
  DATA : in_words         TYPE spell,
         lv_langu         TYPE sy-langu,
         lv_date(10),
         ls_detail        LIKE LINE OF gt_detail,
         ls_bpv           TYPE zfidt006,
         lv_wrbtr         TYPE bseg-wrbtr,
         lv_waers         TYPE bkpf-waers,
         lv_currency(100),
         lv_frbtr         TYPE bseg-dmbtr,
         lv_kursf         TYPE c LENGTH 20.

  CLEAR : gs_header, gt_detail[], gt_window3[].

  gs_header-title  = 'BANK PAYMENT VOUCHER'.
  gs_header-bukrs  = fu_bukrs.
  SELECT SINGLE butxt name1
    FROM t001 JOIN adrc ON t001~adrnr = adrc~addrnumber
    INTO ( gs_header-butxt, gs_header-name1 )
    WHERE bukrs = gs_header-bukrs.

  gs_header-zuonr = fu_number.

  LOOP AT ft_bpv INTO ls_bpv.
    ADD ls_bpv-wrbtr TO lv_wrbtr.
    lv_waers  = ls_bpv-waers.
    IF lv_waers = 'IDR'.
      lv_langu = 'id'.
    ELSE.
      lv_langu = sy-langu.
    ENDIF.
    IF ls_bpv-descr IS INITIAL.
      CONCATENATE 'Transfer antar bank (' gs_bpv-zbank1 '-' ls_bpv-zbank2 ')'
      INTO ls_detail-desc100
      SEPARATED BY space.
    ELSE.
      ls_detail-desc100 = ls_bpv-descr.
    ENDIF.
    WRITE ls_bpv-wrbtr TO ls_detail-wrbtrt CURRENCY gs_bpv-waers.
    APPEND ls_detail TO gt_detail.
    CLEAR ls_detail.
  ENDLOOP.

  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount    = lv_wrbtr
      currency  = lv_waers
      language  = lv_langu
    IMPORTING
      in_words  = in_words
    EXCEPTIONS
      not_found = 1
      too_large = 2
      OTHERS    = 3.

  IF lv_waers = 'IDR'.
    CONCATENATE in_words-word 'RUPIAH' INTO gs_header-terbilang SEPARATED BY space.
    TRANSLATE gs_header-terbilang TO UPPER CASE.
    lv_currency = lv_waers.
  ELSE.
    lv_frbtr = fu_kursf * 1000.
    WRITE lv_frbtr TO lv_kursf CURRENCY lv_waers.
    CONDENSE lv_kursf NO-GAPS.
    IF in_words-decimal = 0.
      CONCATENATE lv_waers in_words-word
      INTO gs_header-terbilang SEPARATED BY space.
    ELSE.
      CONCATENATE lv_waers in_words-word 'AND' in_words-decword 'CENTS'
      INTO gs_header-terbilang SEPARATED BY space.
    ENDIF.
    CONCATENATE lv_waers '-' lv_kursf
    INTO lv_currency
    SEPARATED BY space.
  ENDIF.

  TRANSLATE gs_header-terbilang TO UPPER CASE.
  WRITE lv_wrbtr TO gs_header-totalt CURRENCY lv_waers.

  WRITE fu_budat TO lv_date DD/MM/YYYY.

  PERFORM f_header_window3 USING : 'Nomor Voucher' ':' fu_number ''
                                   'Payment Date' ':' lv_date.
  PERFORM f_header_window3 USING : 'No.SAP' ':' '' ''
                                   'Bank Name' ':' gs_bpv-zbank1.
  PERFORM f_header_window3 USING : 'Departemen' ':' 'Treasury' ''
                                   'Bank Account No.' ':' gs_bpv-znorek1.
  PERFORM f_header_window3 USING : 'Currency' ':' lv_currency ''
                                   'Cheque/Giro No.' ':' fu_cheque.

  CONCATENATE gs_bpv-zbank1 lv_waers INTO gs_header-txt20
  SEPARATED BY space.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PBO
*&---------------------------------------------------------------------*
FORM f_pbo .
  CASE sy-dynnr.
    WHEN '0100'.
      DESCRIBE TABLE gt_bpvd LINES fill.
      tc_bank-lines = fill.

    WHEN OTHERS.
      IF gv_waers = 'IDR'.
        PERFORM f_modify_screen USING : 'PWA' '' '0' '' ''.
      ENDIF.
      IF p_trade IS NOT INITIAL.
        PERFORM f_modify_screen USING : 'DES' '' '0' '' ''.
        CLEAR gv_descr.
      ENDIF.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PAI
*&---------------------------------------------------------------------*
FORM f_pai .

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_F4_NOREK
*&---------------------------------------------------------------------*
FORM f_f4_norek  USING    fu_field fu_bukrs fu_retfield fu_zbank fu_waers.
  TYPES : BEGIN OF ty_bank,
            zbank  TYPE zfidt004-zbank,
            znorek TYPE zfidt004-znorek,
            waers  TYPE zfidt004-waers,
          END OF ty_bank.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval,
         field_tab  TYPE STANDARD TABLE OF dfies,
         ls_return  LIKE LINE OF return_tab,
         lt_bank    TYPE STANDARD TABLE OF ty_bank,
         ls_bank    LIKE LINE OF lt_bank.

  DATA : lv_bukrs TYPE zfidt004-bukrs,
         lv_subrc TYPE sy-subrc,
         lv_zbank TYPE zfidt004-zbank,
         lv_norek TYPE zfidt004-znorek,
         lv_lines TYPE i.

  GET CURSOR LINE lv_lines.

  PERFORM f_dynp_value_read USING fu_bukrs ''
                            CHANGING lv_bukrs.
  PERFORM f_dynp_value_read USING fu_zbank lv_lines
                            CHANGING lv_zbank.

  SELECT *
    FROM zfidt004
    INTO CORRESPONDING FIELDS OF TABLE lt_bank
    WHERE bukrs = lv_bukrs
      AND zbank = lv_zbank.

  SORT lt_bank BY zbank znorek waers.
  DELETE ADJACENT DUPLICATES FROM lt_bank COMPARING zbank znorek waers.
  ASSIGN lt_bank[] TO <fs_tab>.
  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING fu_retfield fu_field
                          CHANGING lv_subrc.
  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      lv_norek  = ls_return-fieldval.
      READ TABLE lt_bank INTO ls_bank
                         WITH KEY zbank = lv_zbank
                                  znorek = lv_norek.
      IF sy-subrc = 0.
        gv_waers = ls_bank-waers.
        PERFORM f_dynpfield TABLES dynpfields
                            USING fu_field ls_bank-znorek ''.
        PERFORM f_dynpfield TABLES dynpfields
                            USING fu_waers ls_bank-waers ''.
      ENDIF.
      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_TO_LOCAL_CURRENCY
*&---------------------------------------------------------------------*
FORM f_convert_to_local_currency  USING    fu_budat fu_wrbtr fu_fwaer fu_lwaer
                                  CHANGING fc_kursf fc_dmbtr.
  CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
    EXPORTING
      date             = fu_budat
      foreign_amount   = fu_wrbtr
      foreign_currency = fu_fwaer
      local_currency   = fu_lwaer
    IMPORTING
      exchange_rate    = fc_kursf
      local_amount     = fc_dmbtr
    EXCEPTIONS
      no_rate_found    = 1
      overflow         = 2
      no_factors_found = 3
      no_spread_found  = 4
      derived_2_times  = 5
      OTHERS           = 6.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_NUMBER_RANGES
*&---------------------------------------------------------------------*
FORM f_check_number_ranges  USING    fu_process fu_bukrs fu_budat
                            CHANGING fc_subrc.
  DATA : lv_nrrange TYPE inri-nrrangenr,
         lv_object  TYPE inri-object,
         lv_gjahr   TYPE inri-toyear,
         ls_nriv    TYPE nriv,
         lv_number  TYPE c LENGTH 4.

  CLEAR : fc_subrc.

  lv_nrrange    = fu_budat+4(2).
  lv_gjahr      = fu_budat(4).

  CASE fu_process.
    WHEN 'BPV'.
      lv_object     = 'ZTRS_BP'.
    WHEN 'BRV'.
      lv_object     = 'ZTRS_AFFI'.
  ENDCASE.

  SELECT SINGLE *
    FROM nriv
    INTO CORRESPONDING FIELDS OF ls_nriv
    WHERE object    = lv_object
      AND subobject = fu_bukrs
      AND nrrangenr = lv_nrrange
      AND toyear    = lv_gjahr.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_RECEIPT
*&---------------------------------------------------------------------*
FORM f_validate_receipt  CHANGING fc_subrc.
  DATA : ls_004c       LIKE LINE OF gt_004c.

  IF gt_004c[] IS NOT INITIAL.
    READ TABLE gt_004c INTO ls_004c
                       WITH KEY name1 = gv_customer.
    fc_subrc = sy-subrc.
    IF sy-subrc <> 0.
      MESSAGE s000(zab) WITH 'Company receipt error' DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_FILL_TABLE_CONTROL
*&---------------------------------------------------------------------*
FORM f_fill_table_control .
  CASE sy-dynnr.
    WHEN '0100'.
      READ TABLE gt_bpvd INTO gs_bpvd INDEX tc_bank-current_line.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_READ_TABLE_CONTROL
*&---------------------------------------------------------------------*
FORM f_read_table_control .
  DATA : lv_dmbtr TYPE bseg-dmbtr,
         lv_waers TYPE bkpf-waers.

  lv_waers   = 'IDR'.

  CASE sy-dynnr.
    WHEN '0100'.
      IF gs_bpv-waers <> 'IDR'.
        IF gs_bpv-kursf IS INITIAL.
          PERFORM f_convert_to_local_currency USING gs_bpv-budat gs_bpv-wrbtr
                                                    gs_bpv-waers lv_waers
                                              CHANGING gs_bpv-kursf lv_dmbtr.
        ENDIF.
      ENDIF.

      MODIFY gt_bpvd FROM gs_bpvd INDEX tc_bank-current_line.
      IF sy-subrc <> 0.
        APPEND gs_bpvd TO gt_bpvd.
      ENDIF.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
FORM f_validate_data  TABLES   ft_bpv   LIKE gt_bpvd
                      CHANGING fc_subrc.
  DATA : ls_bpv      LIKE LINE OF gt_bpvd.

  DATA : lv_wrbtr     TYPE bseg-wrbtr.

  LOOP AT ft_bpv INTO ls_bpv.
    ADD ls_bpv-wrbtr2 TO lv_wrbtr.
  ENDLOOP.

  IF lv_wrbtr <> gs_bpv-wrbtr.
    fc_subrc = 2.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_AMOUNT
*&---------------------------------------------------------------------*
FORM f_calculate_amount  USING    fu_budat fu_wrbtr fu_waers fu_waerk fu_kursf
                         CHANGING fc_dmbtr fc_kursf.
  DATA : lv_kursf TYPE bkpf-kursf,
         lv_waers TYPE bkpf-waers.

  IF fu_waerk <> 'IDR'.
    lv_waers = 'IDR'.
    PERFORM f_convert_to_local_currency USING fu_budat fu_wrbtr
                                              fu_waers lv_waers
                                        CHANGING lv_kursf gs_out-dmbtr.
    IF lv_kursf <> fu_kursf.
      fc_dmbtr = ( fu_wrbtr * fu_kursf ) * 10.
      fc_kursf = fu_kursf.
    ELSE.
      fc_kursf = lv_kursf.
    ENDIF.
  ELSE.
    fc_dmbtr = fu_wrbtr.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATE
*&---------------------------------------------------------------------*
FORM f_posting_date  USING    fu_zbank fu_budat
                     CHANGING fc_budat.
  DATA : lv_month TYPE c LENGTH 3,
         lv_monat TYPE c LENGTH 2.

  CASE fu_zbank.
    WHEN 'BCA' OR 'MANDIRI' OR 'BCA SYARIAH' OR 'OCBC' OR
      'HSBC' OR 'OCBC NISP'.
      CONCATENATE fu_budat+6(4) fu_budat+3(2) fu_budat(2) INTO fc_budat.
    WHEN 'SMBC' OR 'STANDARD CHARTERED BANK'.
      CONCATENATE fu_budat+6(4) fu_budat+3(2) fu_budat(2) INTO fc_budat.
    WHEN 'CIMB NIAGA'.
      fc_budat(4)   = fu_budat+6(2) + 2000.
      fc_budat+6(2) = fu_budat+3(2).
      fc_budat+4(2) = fu_budat(2).
    WHEN 'BNI'.
      fc_budat(4)   = fu_budat+6(2) + 2000.
      fc_budat+4(2) = fu_budat+3(2).
      fc_budat+6(2) = fu_budat+(2).
    WHEN 'DANAMON'. " OR 'STANDARD CHARTERED BANK'.
      lv_month = fu_budat+3(3).
      PERFORM f_month_conversion USING lv_month
                                 CHANGING lv_monat.
      CONCATENATE fu_budat+7(4) lv_monat fu_budat(2) INTO fc_budat.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CEK_NUMBER
*&---------------------------------------------------------------------*
FORM f_cek_number  USING    fu_value
                   CHANGING fc_subrc.
  DATA : lv_string TYPE string,
         lv_number TYPE p DECIMALS 2.

  CLEAR fc_subrc.
  lv_string = fu_value.
  TRANSLATE lv_string USING ', '.
  CONDENSE lv_string NO-GAPS.
  TRY .
      lv_number = lv_string.
    CATCH cx_sy_conversion_no_number.
      fc_subrc = 4.
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SEND_TO_PDF
*&---------------------------------------------------------------------*
FORM f_send_to_pdf  USING    job_output_info TYPE ssfcrescl
                             job_output_options TYPE ssfcresop
                             filename.
  DATA : lt_otf TYPE STANDARD TABLE OF itcoo,
         lt_pdf TYPE STANDARD TABLE OF tline.

  DATA : lv_pdf_size TYPE i.

  lt_otf[] = job_output_info-otfdata[].

  IF lt_otf[] IS NOT INITIAL.
    CALL FUNCTION 'CONVERT_OTF'
      EXPORTING
        format                = 'PDF'
        max_linewidth         = 132
        pdf_preview           = 'X'
      IMPORTING
        bin_filesize          = lv_pdf_size
      TABLES
        otf                   = lt_otf
        lines                 = lt_pdf
      EXCEPTIONS
        err_max_linewidth     = 1
        err_format            = 2
        err_conv_not_possible = 3
        OTHERS                = 4.

    IF sy-subrc = 0.
      CALL METHOD cl_gui_frontend_services=>gui_download
        EXPORTING
          bin_filesize = lv_pdf_size
          filename     = filename
          filetype     = 'BIN'
        CHANGING
          data_tab     = lt_pdf[].
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_FILE
*&---------------------------------------------------------------------*
FORM f_split_file  USING    full_name
                   CHANGING stripped_name.

  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
    EXPORTING
      full_name     = full_name
    IMPORTING
      stripped_name = stripped_name
    EXCEPTIONS
      x_error       = 1
      OTHERS        = 2.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_VALUE_DATE
*&---------------------------------------------------------------------*
FORM f_check_value_date  USING    fu_value.
  SPLIT fu_value AT space INTO: DATA(lv_day)
                                DATA(lv_month)
                                DATA(lv_year).
  CASE lv_month.
    WHEN 'Jan'. lv_month = '01'. fu_value = |{ lv_day }/{ lv_month }/{ lv_year } |.
    WHEN 'Feb'. lv_month = '02'. fu_value = |{ lv_day }/{ lv_month }/{ lv_year } |.
    WHEN 'Mar'. lv_month = '03'. fu_value = |{ lv_day }/{ lv_month }/{ lv_year } |.
    WHEN 'Apr'. lv_month = '04'. fu_value = |{ lv_day }/{ lv_month }/{ lv_year } |.
    WHEN 'May' OR 'Mei'. lv_month = '05'. fu_value = |{ lv_day }/{ lv_month }/{ lv_year } |.
    WHEN 'Jun'. lv_month = '06'. fu_value = |{ lv_day }/{ lv_month }/{ lv_year } |.
    WHEN 'Jul'. lv_month = '07'. fu_value = |{ lv_day }/{ lv_month }/{ lv_year } |.
    WHEN 'Aug' OR 'Agu'. lv_month = '08'. fu_value = |{ lv_day }/{ lv_month }/{ lv_year } |.
    WHEN 'Sep'. lv_month = '09'. fu_value = |{ lv_day }/{ lv_month }/{ lv_year } |.
    WHEN 'Oct' OR 'Okt'. lv_month = '10'. fu_value = |{ lv_day }/{ lv_month }/{ lv_year } |.
    WHEN 'Nov'. lv_month = '11'. fu_value = |{ lv_day }/{ lv_month }/{ lv_year } |.
    WHEN 'Dec' OR 'Des'. lv_month = '12'. fu_value = |{ lv_day }/{ lv_month }/{ lv_year } |.
  ENDCASE.
ENDFORM.
