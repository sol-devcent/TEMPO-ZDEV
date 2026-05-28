*&---------------------------------------------------------------------*
*&  Include           ZHSMMM_E007F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_FRGCO
*&---------------------------------------------------------------------*
FORM f_check_frgco .
  DATA : lv_frggr  TYPE t16fg-frggr,
         auth_flag.

  DATA : BEGIN OF xt16fg OCCURS 10.
           INCLUDE STRUCTURE t16fg.
         DATA : END OF xt16fg.

  DATA : BEGIN OF xt16fc OCCURS 10.
           INCLUDE STRUCTURE t16fc.
         DATA : END OF xt16fc.

  lv_frggr = '41'.

  SELECT *
    FROM t16fg
    INTO TABLE xt16fg
    WHERE frgot = '2'
      AND frggr = lv_frggr.
  IF sy-subrc <> 0.
    MESSAGE e163(se).
  ENDIF.

  IF xt16fg[] IS NOT INITIAL.
    SELECT *
      FROM t16fc
      INTO TABLE xt16fc
      FOR ALL ENTRIES IN xt16fg
      WHERE frggr = xt16fg-frggr
        AND frgco = pa_frgco.
    IF sy-subrc <> 0.
      MESSAGE e161(se).
    ENDIF.
  ENDIF.

  CLEAR auth_flag.
  LOOP AT xt16fc.
    AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
      ID 'FRGGR' FIELD lv_frggr
      ID 'FRGCO' FIELD pa_frgco.
    IF sy-subrc EQ 0.
      auth_flag = 'X'.
    ENDIF.
  ENDLOOP.
  IF auth_flag IS INITIAL.
    MESSAGE e162(se) WITH pa_frgco.
  ENDIF.
ENDFORM.                    " F_CHECK_FRGCO

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_05    LIKE LINE OF gt_05,
         lv_srno1 TYPE zhsmmmdt005-srno1.

  DATA : lv_frggr  TYPE t16fd-frggr,
         path      TYPE string,
         ftab(200) TYPE c OCCURS 0,
         i         TYPE i,
         ls_tab    LIKE LINE OF ftab,
         filename  TYPE string,
         rc        TYPE i.

  PERFORM f_clear_pdf_temp.

  gv_mail   = 'X'.

  SELECT *
    FROM zhsmmmdt005
    INTO CORRESPONDING FIELDS OF TABLE gt_05
    WHERE tcode = 'ZMME013'.
*      AND ekgrp = pa_ekgrp.
  SELECT *
    FROM zhsmmmdt008
    INTO CORRESPONDING FIELDS OF TABLE gt_08
    WHERE tcode = 'ZMME013'.

  READ TABLE gt_05 INTO ls_05
                   WITH KEY frgco = pa_frgco.
  IF sy-subrc = 0.
    DESCRIBE TABLE gt_05 LINES gv_srno1.
  ELSE.
    gv_subrc = sy-subrc.
  ENDIF.

  gv_ekorg  = 'TNT'.

  PERFORM f_free_pdf_temp.

ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  PERFORM f_modify_screen USING : 'PEK' '0' '' '' ''.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  IF pa_frgco IS NOT INITIAL.
    PERFORM f_check_frgco.
  ENDIF.
*  PERFORM f_error_message USING '' ''.
ENDFORM.                    " F_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_F4_FILENAME
*&---------------------------------------------------------------------*
FORM f_f4_filename  CHANGING fc_fname.
  DATA : directory TYPE string,
         filetable TYPE filetable,
         line      TYPE LINE OF filetable,
         rc        TYPE i.

  CALL METHOD cl_gui_frontend_services=>get_temp_directory
    CHANGING
      temp_dir = directory.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title      = 'SELECT THE FILE'
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
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

  IF fu_group IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF lv_mess IS NOT INITIAL.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_x04x  TYPE STANDARD TABLE OF zgdmmt004x,
         ls_x04x  LIKE LINE OF lt_x04x,
         lt_x04y  TYPE STANDARD TABLE OF zgdmmt004y,
         ls_x04y  LIKE LINE OF lt_x04y,
         lt_x04z  TYPE STANDARD TABLE OF zgdmmt004z,
         ls_x04z  LIKE LINE OF lt_x04z,
         lr_matnr TYPE RANGE OF matnr,
         ls_matnr LIKE LINE OF lr_matnr,
         ls_04z   LIKE LINE OF gt_04z,
         ls_05    LIKE LINE OF gt_05.

  DATA : lr_frgco TYPE RANGE OF frgco,
         ls_frgco LIKE LINE OF lr_frgco,
         lr_ekgrp TYPE RANGE OF ekgrp,
         ls_ekgrp LIKE LINE OF lr_ekgrp,
         lv_srno1 TYPE zhsmmmdt005-srno1.

  DATA : lr_procstat TYPE RANGE OF meprocstate,
         ls_procstat LIKE LINE OF lr_procstat.

  DATA : lt_x05   TYPE STANDARD TABLE OF zhsmmmdt005,
         ls_x05   LIKE LINE OF lt_x05,
         lv_ekgrp TYPE zhsmmmdt005-ekgrp,
         lv_subrc TYPE sy-subrc,
         lv_count TYPE i.

  READ TABLE gt_05 INTO ls_05
                   WITH KEY frgco = pa_frgco.

  SELECT *
    FROM zhsmmmdt005
    INTO CORRESPONDING FIELDS OF TABLE lt_x05
    WHERE tcode     = 'ZMME013'
      AND frgco     = pa_frgco.

  CASE 'X'.
    WHEN radio1.
      CASE ls_05-srno1.
        WHEN 0.
        WHEN 1.
          ls_frgco-low    = space.
          ls_frgco-sign   = 'E'.
          ls_frgco-option = 'EQ'.
          APPEND ls_frgco TO lr_frgco.

          LOOP AT gt_05 INTO ls_05 WHERE frgco = pa_frgco.
            ls_ekgrp-low    = ls_05-ekgrp.
            ls_ekgrp-sign   = 'I'.
            ls_ekgrp-option = 'EQ'.
            APPEND ls_ekgrp TO lr_ekgrp.
          ENDLOOP.
        WHEN OTHERS.
          READ TABLE lt_x05 INTO ls_x05
                            WITH KEY ekgrp = ls_05-ekgrp.
          IF ls_x05-smtp_addr IS NOT INITIAL.
            lv_subrc = 4.
            WHILE lv_subrc IS NOT INITIAL.
              ADD 1 TO lv_count.
              lv_srno1  = ls_05-srno1 - 1.
              READ TABLE gt_05 INTO ls_05
                               WITH KEY srno1 = lv_srno1.
              IF ls_05-smtp_addr IS NOT INITIAL.
                CLEAR lv_subrc.
              ELSEIF lv_count = 10.
                CLEAR lv_subrc.
              ENDIF.
            ENDWHILE.
*          lv_srno1  = ls_05-srno1 - 1.
            LOOP AT gt_05 INTO ls_05 WHERE srno1 = lv_srno1.
              READ TABLE lt_x05 INTO ls_x05
                                WITH KEY ekgrp = ls_05-ekgrp.
              IF sy-subrc <> 0.
                CONTINUE.
              ENDIF.
              ls_frgco-low    = ls_05-frgco.
              ls_frgco-sign   = 'E'.
              ls_frgco-option = 'EQ'.
              APPEND ls_frgco TO lr_frgco.

              ls_ekgrp-low    = ls_05-ekgrp.
              ls_ekgrp-sign   = 'I'.
              ls_ekgrp-option = 'EQ'.
              APPEND ls_ekgrp TO lr_ekgrp.
            ENDLOOP.
          ENDIF.
      ENDCASE.

    WHEN radio2.
      CASE ls_05-srno1.
        WHEN 0.
        WHEN OTHERS.
          IF ls_05-smtp_addr IS NOT INITIAL.
            ls_frgco-low    = ls_05-frgco.
            ls_frgco-sign   = 'E'.
            ls_frgco-option = 'EQ'.
            APPEND ls_frgco TO lr_frgco.

            LOOP AT gt_05 INTO ls_05 WHERE frgco = pa_frgco.
              ls_ekgrp-low    = ls_05-ekgrp.
              ls_ekgrp-sign   = 'I'.
              ls_ekgrp-option = 'EQ'.
              APPEND ls_ekgrp TO lr_ekgrp.
            ENDLOOP.
          ENDIF.
      ENDCASE.
  ENDCASE.

  SELECT *
    FROM zgdmmt004z
    INTO CORRESPONDING FIELDS OF TABLE gt_04z
    WHERE zalno IN so_zalno
      AND submi IN so_submi
      AND zaldt IN so_zaldt
      AND ekgrp IN lr_ekgrp.

  SORT gt_04z BY zalno modda DESCENDING.
  DELETE ADJACENT DUPLICATES FROM gt_04z COMPARING zalno.

  LOOP AT gt_04z INTO ls_04z.
    CASE ls_05-srno1.
      WHEN 0.
        IF ls_04z-merge IS INITIAL.
          DELETE TABLE gt_04z FROM ls_04z.
        ELSE.
          CASE 'X'.
            WHEN radio1.
              IF ls_04z-merno IS NOT INITIAL.
                DELETE TABLE gt_04z FROM ls_04z.
              ENDIF.
            WHEN radio2.
              IF ls_04z-merno IS INITIAL.
                DELETE TABLE gt_04z FROM ls_04z.
              ENDIF.
          ENDCASE.
        ENDIF.
      WHEN OTHERS.
        IF ls_04z-merge IS NOT INITIAL AND
          ls_04z-merno IS INITIAL.
          DELETE TABLE gt_04z FROM ls_04z.
        ENDIF.

        IF ls_04z-procstat = '08'.
          CASE 'X'.
            WHEN radio1.
              DELETE TABLE gt_04z FROM ls_04z.
          ENDCASE.
        ELSE.
          CASE 'X'.
            WHEN radio1.
              DELETE gt_04z WHERE frgco IN lr_frgco.

            WHEN radio2.
              DELETE gt_04z WHERE frgco IN lr_frgco.
          ENDCASE.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  IF gt_04z[] IS NOT INITIAL.
    lt_x04z[] = gt_04z[].
    SORT lt_x04z BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_x04z COMPARING matnr.
    LOOP AT lt_x04z INTO ls_x04z.
      CONCATENATE ls_x04z-matnr '*' INTO ls_x04z-matnr.
      ls_matnr-low    = ls_x04z-matnr.
      ls_matnr-sign   = 'I'.
      ls_matnr-option = 'CP'.
      APPEND ls_matnr TO lr_matnr.
      CLEAR ls_matnr.
    ENDLOOP.

    SELECT *
      FROM zgdmmt004x
      INTO CORRESPONDING FIELDS OF TABLE gt_04x
      FOR ALL ENTRIES IN gt_04z
      WHERE zalno = gt_04z-zalno.

    SELECT *
      FROM zgdmmt004y
      INTO CORRESPONDING FIELDS OF TABLE gt_04y
      FOR ALL ENTRIES IN gt_04z
      WHERE zalno = gt_04z-zalno
        AND bsmng <> 0.

    SELECT *
      FROM zgdmmt004p
      INTO CORRESPONDING FIELDS OF TABLE gt_04p
      FOR ALL ENTRIES IN gt_04z
      WHERE zalno = gt_04z-zalno
        AND menge <> 0.
  ENDIF.

  lt_x04x[] = gt_04x[].
  SORT lt_x04x BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_x04x COMPARING lifnr.
  IF lt_x04x[] IS NOT INITIAL.
    SELECT *
      FROM qinf
      INTO CORRESPONDING FIELDS OF TABLE gt_qinf
      FOR ALL ENTRIES IN lt_x04x
      WHERE lieferant = lt_x04x-lifnr
        AND matnr     IN lr_matnr
        AND frei_dat  > sy-datum.

    SELECT *
      FROM lfm1
      INTO CORRESPONDING FIELDS OF TABLE gt_lfm1
      FOR ALL ENTRIES IN lt_x04x
      WHERE lifnr = lt_x04x-lifnr
        AND ekorg = 'TNT'.

    SELECT *
      FROM eina
      INTO CORRESPONDING FIELDS OF TABLE gt_eina
      FOR ALL ENTRIES IN lt_x04x
      WHERE lifnr = lt_x04x-lifnr
        AND matnr IN lr_matnr
        AND loekz = space.
    IF gt_eina[] IS NOT INITIAL.
      SELECT *
        FROM eine
        INTO CORRESPONDING FIELDS OF TABLE gt_eine
        FOR ALL ENTRIES IN gt_eina
        WHERE infnr = gt_eina-infnr
          AND loekz = space.
    ENDIF.
  ENDIF.

  PERFORM f_get_pir_mpn.

  lt_x04y[] = gt_04y[].
  SORT lt_x04y BY ebeln.
  DELETE ADJACENT DUPLICATES FROM lt_x04y COMPARING ebeln.
  IF lt_x04y[] IS NOT INITIAL.
    SELECT *
      FROM ekpo
      INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
      FOR ALL ENTRIES IN lt_x04y
      WHERE ebeln = lt_x04y-ebeln
        AND loekz = space.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_04x   LIKE LINE OF gt_04x,
         ls_04y   LIKE LINE OF gt_04y,
         ls_04z   LIKE LINE OF gt_04z,
         ls_05    LIKE LINE OF gt_05,
         ls_out   LIKE LINE OF gt_out,
         ls_ekpo  LIKE LINE OF gt_ekpo,
         ls_xekpo LIKE LINE OF gt_xekpo,
         lt_x04x  TYPE STANDARD TABLE OF zgdmmt004x,
         ls_x04x  LIKE LINE OF gt_04x,
         ls_eina  LIKE LINE OF gt_eina,
         ls_eine  LIKE LINE OF gt_eine.

  DATA : lv_flag.

  DATA : lt_celltab TYPE lvc_t_styl WITH HEADER LINE,
         lt_tcol    TYPE lvc_t_scol,
         lv_col	    TYPE lvc_col,
         lv_int	    TYPE lvc_int,
         lv_inv	    TYPE lvc_inv.

  DATA : lr_matnr TYPE RANGE OF matnr,
         ls_matnr LIKE LINE OF lr_matnr.

  DATA : lt_05 TYPE STANDARD TABLE OF zhsmmmdt005.
  DATA : ls_08    LIKE LINE OF gt_08.

  lt_x04x[] = gt_04x[].
  SORT lt_x04x BY zalno.
  DELETE ADJACENT DUPLICATES FROM lt_x04x COMPARING zalno.

  LOOP AT lt_x04x INTO ls_x04x.
    lv_flag = 'X'.
    ls_out-atach  = icon_attachment.
    LOOP AT gt_04x INTO ls_04x WHERE zalno = ls_x04x-zalno.
      CLEAR ls_04y.
      READ TABLE gt_04y INTO ls_04y
                        WITH KEY zalno = ls_04x-zalno
                                 lifnr = ls_04x-lifnr.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF lv_flag IS INITIAL.
        lt_celltab-style     = cl_gui_alv_grid=>mc_style_disabled.
        lt_celltab-fieldname = 'MARK'.
        APPEND lt_celltab.
        INSERT LINES OF lt_celltab INTO TABLE ls_out-style.
      ENDIF.

      ls_out-zalno  = ls_04x-zalno.
      ls_out-lifnr  = ls_04x-lifnr.
      ls_out-name1  = ls_04x-name1.
      ls_out-matnr  = ls_04x-matnr.
      ls_out-maktx  = ls_04x-maktx.
      ls_out-meins  = ls_04x-bamei.
      ls_out-menge  = ls_04x-bamng.
      ls_out-kbetr  = ls_04x-kbetr.
      ls_out-alloc  = ls_04x-menge.
      ls_out-kbet1  = ls_04x-kbet1.

      READ TABLE gt_04z INTO ls_04z
                        WITH KEY zalno = ls_x04x-zalno.
      IF sy-subrc = 0.
        ls_out-vrsio    = ls_04z-vrsio.
        ls_out-submi    = ls_04z-submi.
        ls_out-ekgrp    = ls_04z-ekgrp.
        ls_out-frgco    = ls_04z-frgco.
        ls_out-procstat = ls_04z-procstat.
        IF ls_04z-frgco IS NOT INITIAL.
          lt_05[] = gt_05[].
          SORT lt_05 BY ekgrp srno1 frgco.
          DELETE ADJACENT DUPLICATES FROM lt_05 COMPARING ekgrp srno1 frgco.
*          LOOP AT gt_05 INTO ls_05 WHERE ekgrp = ls_04z-ekgrp.
          LOOP AT lt_05 INTO ls_05 WHERE ekgrp = ls_04z-ekgrp.
            CONCATENATE ls_out-anzef ls_05-frgco INTO ls_out-anzef
            SEPARATED BY space.
            IF ls_05-frgco = ls_04z-frgco.
              EXIT.
            ENDIF.
          ENDLOOP.
          SHIFT ls_out-anzef LEFT DELETING LEADING space.
        ELSE.
          ls_out-anzef = ls_04z-frgco.
        ENDIF.

        IF lv_flag IS NOT INITIAL.
          IF ls_04z-url IS NOT INITIAL.
            ls_out-fpkh  = icon_pdf.
          ENDIF.
          IF ls_04z-lampiran IS NOT INITIAL. " AND pa_frgco = 'FD'.
            SORT gt_08 BY uname.
            READ TABLE gt_08 INTO ls_08 WITH KEY uname = sy-uname BINARY SEARCH.
            IF sy-subrc EQ 0.
              ls_out-lamp  = icon_pdf.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      CASE ls_out-procstat.
        WHEN '03'.
          PERFORM f_coloring_column TABLES lt_tcol
                                    USING 'PROCSTAT' '3' lv_int lv_inv.
        WHEN '05'.
          PERFORM f_coloring_column TABLES lt_tcol
                                    USING 'PROCSTAT' '5' lv_int lv_inv.
        WHEN '08'.
          PERFORM f_coloring_column TABLES lt_tcol
                                    USING 'PROCSTAT' '6' lv_int lv_inv.
        WHEN OTHERS.
          CLEAR lt_tcol[].
      ENDCASE.

      ls_out-color  = lt_tcol.

      CLEAR : lr_matnr[], ls_xekpo.
      READ TABLE gt_xekpo INTO ls_xekpo
                          WITH KEY ebeln = ls_04x-ebeln
                                   matnr = ls_04x-matnr.
      IF ls_xekpo-idnlf IS INITIAL.
        ls_matnr-low = ls_out-matnr.
      ELSE.
*        CONCATENATE ls_out-matnr '*' INTO ls_matnr-low.
        ls_matnr-low = ls_xekpo-idnlf.
      ENDIF.

      ls_matnr-sign   = 'I'.
      ls_matnr-option = 'EQ'.
      APPEND ls_matnr TO lr_matnr.
      CLEAR ls_matnr.

      CLEAR ls_eina.
      LOOP AT gt_eina INTO ls_eina WHERE lifnr = ls_out-lifnr.
        IF ls_eina-matnr IN lr_matnr.
          CLEAR ls_eine.
          READ TABLE gt_eine INTO ls_eine
                             WITH KEY infnr = ls_eina-infnr.
          IF sy-subrc = 0.
            ls_out-netpr  = ls_eine-netpr.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF lt_celltab[] IS INITIAL.
        PERFORM f_lock_data USING 'X' ls_out-zalno ls_out-submi
                            CHANGING ls_out-icon.

        IF ls_out-icon = icon_locked.
          lt_celltab-style     = cl_gui_alv_grid=>mc_style_disabled.
          lt_celltab-fieldname = 'MARK'.
          APPEND lt_celltab.
          INSERT LINES OF lt_celltab INTO TABLE ls_out-style.
        ENDIF.
      ENDIF.

      APPEND ls_out TO gt_out.
      CLEAR : ls_out, lv_flag, lt_celltab[], lt_celltab, lt_tcol[], lt_tcol.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  IF gt_out[] IS NOT INITIAL.
    CALL SCREEN 101.
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
  DATA : fcode TYPE TABLE OF sy-ucomm,
         ls_05 LIKE LINE OF gt_05.

*  IF gt_bapiret2[] IS NOT INITIAL.
*    dynlog-icon_id      = icon_error_protocol.
*    dynlog-icon_text    = 'Error Log'.
*  ENDIF.
  CLEAR ls_05.
  READ TABLE gt_05 INTO ls_05
                   WITH KEY frgco = pa_frgco.

  CASE sy-dynnr.
    WHEN '0101'.
      CASE 'X'.
        WHEN radio1.
          dyn_merge-icon_id     = icon_previous_hierarchy_level.
          dyn_merge-icon_text   = 'Merge'.
          dyn_appr-icon_id      = icon_allow.
          dyn_appr-icon_text    = 'Approve'.
          dyn_rjct-icon_id      = icon_reject.
          dyn_rjct-icon_text    = 'Reject'.

        WHEN radio2.
          dyn_merge-icon_id     = icon_next_hierarchy_level.
          dyn_merge-icon_text   = 'Cancel Merge'.
          dyn_appr-icon_id      = icon_allow.
          dyn_appr-icon_text    = 'Cancel Approve'.
          dyn_rjct-icon_id      = icon_reject.
          dyn_rjct-icon_text    = 'Cancel Reject'.
      ENDCASE.

      IF ls_05-srno1 = 0.
        APPEND '&APPR' TO fcode.
        APPEND '&RJCT' TO fcode.
      ELSE.
        APPEND '&MERGE' TO fcode.
      ENDIF.

      SET PF-STATUS 'STANDARD' EXCLUDING fcode.
      SET TITLEBAR 'TITLE'.

    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
FORM f_exit .
  CALL FUNCTION 'DEQUEUE_EZGDMMT004Z'.
*  PERFORM f_delete_temporary_form.

  CASE sy-dynnr.
    WHEN '0102'.
      CALL METHOD g_html_control->free
        EXCEPTIONS
          cntl_error        = 1
          cntl_system_error = 2
          OTHERS            = 3.
  ENDCASE.

  LEAVE TO SCREEN 0.
ENDFORM.                    " F_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm     TYPE sy-ucomm,
         lv_valid     TYPE c,
         lt_fidx      TYPE lvc_t_fidx,
         ls_fidx      TYPE sy-tabix,
         ls_filter    LIKE LINE OF gt_filter,
         lv_answer,
         lv_text(100).

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
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_posting_data.
      ENDIF.

    WHEN '&MERGE'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        CASE 'X'.
          WHEN radio1.
            lv_text = 'Are you sure want to merged ?'.
            PERFORM f_confirmation USING lv_text
                                   CHANGING lv_answer.
            IF lv_answer = 1.
              PERFORM f_merge_data.
            ENDIF.
          WHEN radio2.
            lv_text = 'Are you sure want to unmerged ?'.
            PERFORM f_confirmation USING lv_text
                                   CHANGING lv_answer.
            IF lv_answer = 1.
              PERFORM f_unmerge_data.
            ENDIF.
        ENDCASE.
      ENDIF.

    WHEN '&APPR'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        CASE 'X'.
          WHEN radio1.
            lv_text = 'Are you sure want to approved ?'.
          WHEN radio2.
            lv_text = 'Are you sure want to cancel approved ?'.
        ENDCASE.

        PERFORM f_confirmation USING lv_text
                               CHANGING lv_answer.
        IF lv_answer = '1'.
          PERFORM f_approve_data USING lv_ucomm.
        ENDIF.
      ENDIF.

    WHEN '&RJCT'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        CASE 'X'.
          WHEN radio1.
            lv_text = 'Are you sure want to rejected ?'.
          WHEN radio2.
            lv_text = 'Are you sure want to cancel rejected ?'.
        ENDCASE.

        PERFORM f_confirmation USING lv_text
                               CHANGING lv_answer.
        IF lv_answer = '1'.
          PERFORM f_reject_data USING lv_ucomm.
        ENDIF.
      ENDIF.

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

    WHEN OTHERS.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
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
        it_outtab            = gt_out[]
        it_fieldcatalog      = gt_main_fieldcat[].

    gt_xout[] = gt_out[].
  ENDIF.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
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

  PERFORM f_alv_sort USING : 1 'ZALNO' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  DATA: ls_08           LIKE LINE OF gt_08.
  PERFORM f_dyn_int_table USING :
    'MARK' '' '' '' '' '' 'X' '' '' '' '' '' '' 'X' '' ''
    'X' 'X' '' '' '' ''.

  PERFORM f_dyn_int_table USING :
    'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
    'X' 'X' '' '' '' ''.

  PERFORM f_dyn_int_table USING :
    'ZALNO' '' '' '' '' '' '' 'ZALNO' 'ZGDMMT004X' '' '' '' '' '' ''
    '' '' '' '' '' '' '',
    'SUBMI' '' '' '' '' '' '' 'SUBMI' 'ZGDMMT004Z' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'EKGRP' '' '' '' '' '' '' 'EKGRP' 'ZGDMMT004Z' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'LIFNR' '' '' '' '' '' '' 'LIFNR' 'EKKO' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'NAME1' '' '' '' '' '' '' 'NAME1' 'LFA1' 'Vendor Name'
    '' '' '' '' '' '' '' '' '' '' '' '',
    'MATNR' '' '' '' '' '' '' 'MATNR' 'MARA' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MAKTX' '' '' '' '' '' '' 'MAKTX' 'MAKT' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MEINS' '' '' '' '' '' '' 'MEINS' 'EKPO' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MENGE' '' '' '' '' 'MEINS' '' 'MENGE' 'EKET' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'KBETR' '' '' '' '' '' '' 'KBETR' 'KONP' '%' ''
    '' '' '' '' '' '' '' '' '' '' '',
    'ALLOC' '' '' '' '' 'MEINS' '' 'MENGE' 'EKET' 'Quantity Alokasi' ''
    '' '' '' '' '' '' '' '' '' '' '',
    'KBET1' '' '' '' '' '' '' 'KBETR' 'KONP' '%' '' '' '' '' ''
    '' '' '' '' '' '' '',
    'ANZEF' '' '' '' '' '' '' 'ANZEF' 'RM06B' '' '' '' '' '' ''
    '' '' '' '' '' '' '',
    'PROCSTAT' '' '' '' '' '' '' 'PROCSTAT' 'ZGDMMT004Z' '' '' '' '' ''
    '' '' '' '' '' '' '' ''.

  SORT gt_08 BY uname.
  READ TABLE gt_08 INTO ls_08 WITH KEY uname = sy-uname BINARY SEARCH.
  IF sy-subrc EQ 0.
    PERFORM f_dyn_int_table USING :
      'ATACH' '' '' '' '' '' '' '' '' 'Attachment' '' '' '' '' '' 'C'
      '' '' '' '' '' '',
      'FPKH' '' '' '' '' '' '' '' '' 'FPKH' '' '' '' '' '' 'C'
      '' '' '' '' '' '',
      'LAMP' '' '' '' '' '' '' '' '' 'LAMP' '' '' '' '' '' 'C'
      '' '' '' '' '' ''.
  ELSE.
    PERFORM f_dyn_int_table USING :
      'ATACH' '' '' '' '' '' '' '' '' 'Attachment' '' '' '' '' '' 'C'
      '' '' '' '' '' '',
      'FPKH' '' '' '' '' '' '' '' '' 'FPKH' '' '' '' '' '' 'C'
      '' '' '' '' '' ''.

  ENDIF.



  PERFORM f_dyn_mint_table USING :
    'ZALNO' '' 'ZALNO' 'ZGDMMT004X',
    'ZALDT' '' 'ZALDT' 'ZGDMMT004Z'.
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
                               fu_nosum fu_colpos.
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
  ls_dyn_fcat-col_pos     = fu_colpos.
  APPEND ls_dyn_fcat TO gt_main_fieldcat.
  CLEAR ls_dyn_fcat.
ENDFORM.                    " F_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_MINT_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_mint_table  USING    fu_fieldname fu_tabname fu_ref_field
                                fu_ref_table.
  DATA : ls_dyn_fcat       TYPE slis_fieldcat_alv.

  ls_dyn_fcat-fieldname       = fu_fieldname.
  ls_dyn_fcat-tabname         = fu_tabname.
  ls_dyn_fcat-ref_fieldname   = fu_ref_field.
  ls_dyn_fcat-ref_tabname     = fu_ref_table.

  APPEND ls_dyn_fcat TO gt_merge_fieldcat.
  CLEAR ls_dyn_fcat.
ENDFORM.                    " F_DYN_MINT_TABLE

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
        READ TABLE ls_out-style INTO ls_stylerow
                                WITH KEY fieldname = 'MARK'.
        IF sy-subrc = 0 AND
            ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          CONTINUE.
        ENDIF.

        IF fu_check IS NOT INITIAL.
*          CLEAR : ls_sort, lv_tabix.
*          READ TABLE gt_sort INTO ls_sort
*                             WITH KEY banfn = ls_out-banfn
*                                      bnfpo = ls_out-bnfpo.
          IF sy-subrc = 0.
            lv_tabix = sy-tabix.
            CLEAR ls_filter.
            READ TABLE gt_filter INTO ls_filter
                                 WITH KEY index = lv_tabix.
            IF sy-subrc = 0.
              CONTINUE.
            ENDIF.
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
  DATA : lt_out TYPE STANDARD TABLE OF ty_out,
         ls_out LIKE LINE OF lt_out.

  lt_out[] = gt_out[].
  DELETE lt_out WHERE mark IS INITIAL.
  DELETE lt_out WHERE procstat <> '05'.
  IF lt_out[] IS NOT INITIAL.
    LOOP AT lt_out INTO ls_out.

    ENDLOOP.
  ELSE.
    MESSAGE s000(zab) WITH 'No data processed' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_handle_double_click  USING    fu_row fu_column.
  DATA : lv_getoff.

  CASE fu_column.
    WHEN 'ATACH'.
*      PERFORM f_delete_temporary_form.
*      PERFORM f_display_attachment USING fu_row fu_column.
      lv_getoff = 'X'.
      PERFORM f_display_attachment_new USING fu_row fu_column lv_getoff.
    WHEN 'FPKH'.
      PERFORM f_print_fpkh USING fu_row fu_column.
    WHEN 'LAMP'.
      PERFORM f_print_lamp USING fu_row fu_column.
    WHEN 'ICON'.
      PERFORM f_display_message USING fu_row fu_column.
  ENDCASE.
ENDFORM.                    " F_HANDLE_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ATTACHMENT
*&---------------------------------------------------------------------*
FORM f_display_attachment USING   fu_row fu_column.
  DATA : ls_out      LIKE LINE OF gt_out,
         lv_filepath TYPE string VALUE '/eprocurement',
         lv_filename TYPE string,
         itabline    TYPE TABLE OF solix,
         ls_itabline LIKE LINE OF itabline,
         directory   TYPE string,
         document    TYPE string,
         filesize    TYPE i,
         ls_temp     LIKE LINE OF gt_temp,
         result      TYPE tdbool,
         true        TYPE tdbool VALUE 'X',
         false       TYPE tdbool VALUE space.

  DATA : o_exception TYPE REF TO cx_root,
         lv_message  TYPE string.

  CASE fu_column.
    WHEN 'ATACH'.
      READ TABLE gt_out INTO ls_out INDEX fu_row.
      IF sy-subrc = 0.
        CONCATENATE ls_out-zalno ls_out-vrsio '.pdf' INTO lv_filename.
        CONCATENATE lv_filepath '/' lv_filename INTO lv_filepath.

        CALL METHOD cl_gui_frontend_services=>get_sapgui_workdir
          CHANGING
            sapworkdir            = directory
          EXCEPTIONS
            get_sapworkdir_failed = 1
            cntl_error            = 2
            error_no_gui          = 3
            not_supported_by_gui  = 4
            OTHERS                = 5.
        IF sy-subrc = 0.
          CONCATENATE directory '\' lv_filename INTO document.

          CALL METHOD cl_gui_frontend_services=>file_exist
            EXPORTING
              file            = document
            RECEIVING
              result          = result
            EXCEPTIONS
              cntl_error      = 1
              error_no_gui    = 2
              wrong_parameter = 3
              OTHERS          = 5.

          IF result = false.
            CALL METHOD cl_gui_frontend_services=>file_get_size
              EXPORTING
                file_name            = document
              IMPORTING
                file_size            = filesize
              EXCEPTIONS
                file_get_size_failed = 1
                cntl_error           = 2
                error_no_gui         = 3
                not_supported_by_gui = 4
                OTHERS               = 99.

            TRY .
                OPEN DATASET lv_filepath FOR INPUT IN BINARY MODE.
                DO.
                  READ DATASET lv_filepath INTO ls_itabline.
                  IF sy-subrc <> 0.
                    EXIT.
                  ENDIF.
                  APPEND ls_itabline TO itabline.
                ENDDO.
                CLOSE DATASET lv_filepath.
              CATCH cx_root INTO o_exception.
                CALL METHOD o_exception->if_message~get_text
                  RECEIVING
                    result = lv_message.
            ENDTRY.

            IF lv_message IS INITIAL.
              CALL METHOD cl_gui_frontend_services=>gui_download
                EXPORTING
                  bin_filesize            = filesize
                  filename                = document
                  filetype                = 'BIN'
                CHANGING
                  data_tab                = itabline
                EXCEPTIONS
                  file_write_error        = 1
                  no_batch                = 2
                  gui_refuse_filetransfer = 3
                  invalid_type            = 4
                  no_authority            = 5
                  unknown_error           = 6
                  header_not_allowed      = 7
                  separator_not_allowed   = 8
                  filesize_not_allowed    = 9
                  header_too_long         = 10
                  dp_error_create         = 11
                  dp_error_send           = 12
                  dp_error_write          = 13
                  unknown_dp_error        = 14
                  access_denied           = 15
                  dp_out_of_memory        = 16
                  disk_full               = 17
                  dp_timeout              = 18
                  file_not_found          = 19
                  dataprovider_exception  = 20
                  control_flush_error     = 21
                  not_supported_by_gui    = 22
                  error_no_gui            = 23
                  OTHERS                  = 24.

              ls_temp-document  = document.
              APPEND ls_temp TO gt_temp.
              CLEAR ls_temp.
            ENDIF.
          ENDIF.

          IF lv_message IS INITIAL.
            CALL METHOD cl_gui_frontend_services=>execute
              EXPORTING
                document               = document
              EXCEPTIONS
                cntl_error             = 1
                error_no_gui           = 2
                bad_parameter          = 3
                file_not_found         = 4
                path_not_found         = 5
                file_extension_unknown = 6
                error_execute_failed   = 7
                synchronous_failed     = 8
                not_supported_by_gui   = 9
                OTHERS                 = 10.
          ENDIF.
        ENDIF.
      ENDIF.

      IF lv_message IS NOT INITIAL .
        MESSAGE s000(zab) WITH 'Attachment not found' DISPLAY LIKE 'E'.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_DISPLAY_ATTACHMENT

*&---------------------------------------------------------------------*
*&      Form  F_APPROVE_DATA
*&---------------------------------------------------------------------*
FORM f_approve_data USING fu_ucomm.
  DATA : lt_xout      TYPE STANDARD TABLE OF ty_out,
         lt_celltab   TYPE lvc_t_styl WITH HEADER LINE,
         ls_xout      LIKE LINE OF lt_xout,
         ls_out       LIKE LINE OF gt_out,
         lv_anzef     LIKE ls_xout-anzef,
         ls_mess(100).

  DATA : lt_poemail  TYPE STANDARD TABLE OF ty_poemail,
         ls_poemail  LIKE LINE OF gt_poemail,
         ls_createpo LIKE LINE OF gt_createpo.

  DATA : ls_05       LIKE LINE OF gt_05,
         lv_frgco    TYPE t16fc-frgco,
         lv_srno1    TYPE zhsmmmdt005-srno1,
         lv_procstat TYPE zgdmmt004z-procstat,
         lv_subrc    TYPE sy-subrc,
         lv_count    TYPE i,
         lv_nomerge.

  DATA : lt_tcol     TYPE lvc_t_scol,
         lv_col	     TYPE lvc_col,
         lv_int	     TYPE lvc_int,
         lv_inv	     TYPE lvc_inv,
         objectclass TYPE cdhdr-objectclas.

  DATA : lt_05 TYPE STANDARD TABLE OF zhsmmmdt005.

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE mark IS INITIAL.

  IF lt_xout[] IS NOT INITIAL.
    LOOP AT lt_xout INTO ls_xout.
      PERFORM f_check_authorization USING ls_xout-ekgrp ls_xout-frgco
                                          ls_xout-procstat fu_ucomm
                                    CHANGING lv_subrc lv_frgco lv_procstat.

*      PERFORM f_check_po_open USING ls_xout-zalno
*                              CHANGING lv_subrc.
      IF lv_subrc = 0.
        TRY .
            UPDATE zgdmmt004z SET frgco     = lv_frgco
                                  procstat  = lv_procstat
                              WHERE zalno = ls_xout-zalno.
          CATCH cx_sy_open_sql_db.
        ENDTRY.

        READ TABLE gt_out INTO ls_out
                          WITH KEY zalno = ls_xout-zalno.
        IF sy-subrc = 0.
          CLEAR ls_out-anzef.
          IF lv_frgco IS INITIAL OR
            lv_srno1 = 1.
            CLEAR : lv_procstat.
          ELSE.
            lt_05[] = gt_05[].
            SORT lt_05 BY ekgrp srno1 frgco.
            DELETE ADJACENT DUPLICATES FROM lt_05 COMPARING ekgrp srno1 frgco.
*            LOOP AT gt_05 INTO ls_05 WHERE ekgrp = ls_xout-ekgrp.
            LOOP AT lt_05 INTO ls_05 WHERE ekgrp = ls_xout-ekgrp.
              CONCATENATE ls_out-anzef ls_05-frgco INTO ls_out-anzef
              SEPARATED BY space.
              IF ls_05-frgco = lv_frgco.
                SHIFT ls_out-anzef LEFT DELETING LEADING space.
                EXIT.
              ENDIF.
            ENDLOOP.
          ENDIF.
          ls_out-frgco    = lv_frgco.
          ls_out-procstat = lv_procstat.

          CASE ls_out-procstat.
            WHEN '03'.
              PERFORM f_coloring_column TABLES lt_tcol
                                        USING 'PROCSTAT' '3' lv_int lv_inv.
            WHEN '05'.
              PERFORM f_coloring_column TABLES lt_tcol
                                        USING 'PROCSTAT' '5' lv_int lv_inv.
            WHEN '08'.
              PERFORM f_coloring_column TABLES lt_tcol
                                        USING 'PROCSTAT' '6' lv_int lv_inv.
            WHEN OTHERS.
              CLEAR lt_tcol[].
          ENDCASE.

          ls_out-color  = lt_tcol.
          CLEAR ls_out-icon.

          CLEAR : lt_celltab[].
          lt_celltab-style     = cl_gui_alv_grid=>mc_style_disabled.
          lt_celltab-fieldname = 'MARK'.
          APPEND lt_celltab.
          INSERT LINES OF lt_celltab INTO TABLE ls_out-style.
          CLEAR : ls_out-mark.

          MODIFY gt_out FROM ls_out
                        TRANSPORTING anzef procstat frgco color icon
                                     mark style
                        WHERE zalno = ls_xout-zalno.

          COMMIT WORK AND WAIT.

          objectclass = 'EPROC_APPR'.

          PERFORM f_save_changes USING ls_xout-zalno
                                       ls_out-procstat ls_out-frgco
                                       objectclass.

          IF lv_procstat = '05'.
*            PERFORM f_create_po USING ls_xout-zalno.
            PERFORM f_merge_alokasi USING ls_xout-zalno
                                    CHANGING lv_nomerge.

            IF lv_nomerge = 'X'.
              PERFORM f_new_create_po USING ls_xout-zalno.
            ENDIF.

            lt_poemail[]  = gt_poemail[].
            SORT lt_poemail BY ernam.
            DELETE ADJACENT DUPLICATES FROM lt_poemail COMPARING ernam.
            LOOP AT lt_poemail INTO ls_poemail.
              PERFORM f_send_email USING '' '' '' '' ls_poemail-ernam
                                         ls_xout-ekgrp.
            ENDLOOP.
            CLEAR : gt_poemail[].
*            PERFORM f_event_raise USING ls_xout-zalno.
          ELSE.
            CASE 'X'.
              WHEN radio1.
                PERFORM f_send_email USING '' ls_xout-zalno fu_ucomm
                                           pa_frgco '' ls_xout-ekgrp.
            ENDCASE.
          ENDIF.
        ENDIF.

        PERFORM f_add_signature USING ls_xout-zalno.

      ELSE.
        ADD 1 TO lv_count.
        ls_out-icon           = icon_led_red.
        PERFORM f_save_message USING ls_xout-zalno lv_subrc ''.

        MODIFY gt_out FROM ls_out
                      TRANSPORTING icon
                      WHERE zalno = ls_xout-zalno.
      ENDIF.
    ENDLOOP.

    IF gt_createpo[] IS NOT INITIAL.
      PERFORM f_create_po_merge.
    ENDIF.

    PERFORM f_save_error_log.
    PERFORM f_alv_refresh USING 'X'.
    CASE 'X'.
      WHEN radio1.
        IF lv_count IS INITIAL.
          MESSAGE s000(zab) WITH 'Data already approved'.
        ELSE.
          MESSAGE s000(zab) WITH 'Data processed with error' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN radio2.
        IF lv_count IS INITIAL.
          MESSAGE s000(zab) WITH 'Data already cancel approved'.
        ELSE.
          MESSAGE s000(zab) WITH 'Data processed with error' DISPLAY LIKE 'E'.
        ENDIF.
    ENDCASE.
  ELSE.
    CASE 'X'.
      WHEN radio1.
        MESSAGE s000(zab) WITH 'No data approved' DISPLAY LIKE 'E'.
      WHEN radio2.
        MESSAGE s000(zab) WITH 'No data cancel approved' DISPLAY LIKE 'E'.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_APPROVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_REJECT_DATA
*&---------------------------------------------------------------------*
FORM f_reject_data USING    fu_ucomm.
  DATA : lt_xout     TYPE STANDARD TABLE OF ty_out,
         lt_celltab  TYPE lvc_t_styl WITH HEADER LINE,
         ls_xout     LIKE LINE OF lt_xout,
         ls_out      LIKE LINE OF gt_out,
         lv_procstat TYPE zgdmmt004z-procstat,
         ls_05       LIKE LINE OF gt_05.

  DATA : lv_frgco TYPE t16fc-frgco,
         lv_subrc TYPE sy-subrc,
         lv_count TYPE i.

  DATA : lt_tcol     TYPE lvc_t_scol,
         lv_col	     TYPE lvc_col,
         lv_int	     TYPE lvc_int,
         lv_inv	     TYPE lvc_inv,
         objectclass TYPE cdhdr-objectclas.

  DATA : lt_05 TYPE STANDARD TABLE OF zhsmmmdt005.

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE mark IS INITIAL.

  IF lt_xout[] IS NOT INITIAL.
    LOOP AT lt_xout INTO ls_xout.
      PERFORM f_check_authorization USING ls_xout-ekgrp ls_xout-frgco
                                          ls_xout-procstat fu_ucomm
                                    CHANGING lv_subrc lv_frgco lv_procstat.
      IF lv_subrc = 0.
        TRY .
            UPDATE zgdmmt004z SET frgco     = lv_frgco
                                  procstat  = lv_procstat
                              WHERE zalno = ls_xout-zalno.
          CATCH cx_sy_open_sql_db.
        ENDTRY.

        READ TABLE gt_out INTO ls_out
                          WITH KEY zalno = ls_xout-zalno.
        IF sy-subrc = 0.
          CLEAR ls_out-anzef.
          IF lv_frgco IS NOT INITIAL.
            lt_05[] = gt_05[].
            SORT lt_05 BY ekgrp srno1 frgco.
            DELETE ADJACENT DUPLICATES FROM lt_05 COMPARING ekgrp srno1 frgco.
*            LOOP AT gt_05 INTO ls_05 WHERE ekgrp = ls_xout-ekgrp.
            LOOP AT lt_05 INTO ls_05 WHERE ekgrp = ls_xout-ekgrp.
              IF ls_05-frgco = pa_frgco.
                EXIT.
              ENDIF.
              CONCATENATE ls_out-anzef ls_05-frgco INTO ls_out-anzef
              SEPARATED BY space.
            ENDLOOP.
            SHIFT ls_out-anzef LEFT DELETING LEADING space.
          ENDIF.
        ENDIF.

        ls_out-procstat = lv_procstat.
        ls_out-frgco    = lv_frgco.

        CASE ls_out-procstat.
          WHEN '03'.
            PERFORM f_coloring_column TABLES lt_tcol
                                      USING 'PROCSTAT' '3' lv_int lv_inv.
          WHEN '05'.
            PERFORM f_coloring_column TABLES lt_tcol
                                      USING 'PROCSTAT' '5' lv_int lv_inv.
          WHEN '08'.
            PERFORM f_coloring_column TABLES lt_tcol
                                      USING 'PROCSTAT' '6' lv_int lv_inv.
          WHEN OTHERS.
            CLEAR lt_tcol[].
        ENDCASE.

        ls_out-color  = lt_tcol.
        CLEAR : ls_out-icon.

        CLEAR : lt_celltab[].
        lt_celltab-style     = cl_gui_alv_grid=>mc_style_disabled.
        lt_celltab-fieldname = 'MARK'.
        APPEND lt_celltab.
        INSERT LINES OF lt_celltab INTO TABLE ls_out-style.
        CLEAR : ls_out-mark.

        MODIFY gt_out FROM ls_out
                      TRANSPORTING anzef procstat frgco color icon
                                   mark style
                      WHERE zalno = ls_xout-zalno.

        COMMIT WORK AND WAIT.

        objectclass = 'EPROC_RJCT'.

        PERFORM f_save_changes USING ls_xout-zalno
                                     ls_out-procstat ls_out-frgco
                                     objectclass.

        PERFORM f_send_email USING '' ls_xout-zalno fu_ucomm
                                   pa_frgco '' ls_xout-ekgrp.

        PERFORM f_add_signature USING ls_xout-zalno.
      ELSE.
        ADD 1 TO lv_count.
        ls_out-icon           = icon_led_red.
        PERFORM f_save_message USING ls_xout-zalno lv_subrc ''.

        MODIFY gt_out FROM ls_out
                      TRANSPORTING icon
                      WHERE zalno = ls_xout-zalno.
      ENDIF.
    ENDLOOP.

    CASE 'X'.
      WHEN radio1.
        IF lv_count IS INITIAL.
          MESSAGE s000(zab) WITH 'Data already rejected'.
        ELSE.
          MESSAGE s000(zab) WITH 'Data processed with error' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN radio2.
        IF lv_count IS INITIAL.
          MESSAGE s000(zab) WITH 'Data already cancel rejected'.
        ELSE.
          MESSAGE s000(zab) WITH 'Data processed with error' DISPLAY LIKE 'E'.
        ENDIF.
    ENDCASE.
    PERFORM f_alv_refresh USING 'X'.
  ELSE.
    CASE 'X'.
      WHEN radio1.
        MESSAGE s000(zab) WITH 'No data rejected' DISPLAY LIKE 'E'.
      WHEN radio2.
        MESSAGE s000(zab) WITH 'No data cancel rejected' DISPLAY LIKE 'E'.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_REJECT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_PO
*&---------------------------------------------------------------------*
FORM f_create_po  USING    fu_zalno.
******  DATA : lt_04x           TYPE STANDARD TABLE OF zgdmmt004x,
******         lt_x04y          TYPE STANDARD TABLE OF zgdmmt004y,
******         ls_x04y          LIKE LINE OF lt_x04y,
******         lt_y04y          TYPE STANDARD TABLE OF zgdmmt004y,
******         ls_y04y          LIKE LINE OF lt_x04y,
******         ls_04z           LIKE LINE OF gt_04z,
******         ls_04y           LIKE LINE OF gt_04y,
******         ls_04x           LIKE LINE OF gt_04x,
******         ls_04e           LIKE LINE OF gt_04e,
******         ls_lfm1          LIKE LINE OF gt_lfm1.
******
******  DATA : poheader         TYPE bapimepoheader,
******         poheaderx        TYPE bapimepoheaderx,
******         poitem           TYPE STANDARD TABLE OF bapimepoitem,
******         ls_item          LIKE LINE OF poitem,
******         poitemx          TYPE STANDARD TABLE OF bapimepoitemx,
******         ls_itemx         LIKE LINE OF poitemx,
******         poschedule       TYPE STANDARD TABLE OF bapimeposchedule,
******         ls_schedule      LIKE LINE OF poschedule,
******         poschedulex      TYPE STANDARD TABLE OF bapimeposchedulx,
******         ls_schedulex     LIKE LINE OF poschedulex,
******         return           TYPE STANDARD TABLE OF bapiret2,
******         ls_return        LIKE LINE OF return.
******
******  DATA : lv_ebeln         TYPE ekko-ebeln,
******         lv_werks         TYPE ekpo-werks,
******         lv_ebelp         TYPE ekpo-ebelp,
******         lv_etenr         TYPE eket-etenr,
******         lv_zrow          TYPE i.
******
******  lt_04x[] = gt_04x[].
******  DELETE lt_04x WHERE zalno <> fu_zalno.
******  lt_x04y[] = gt_04y[].
******  DELETE lt_x04y WHERE zalno <> fu_zalno.
******  SORT lt_x04y BY lifnr banfn.
******  DELETE ADJACENT DUPLICATES FROM lt_x04y COMPARING lifnr banfn.
******  lt_y04y[] = lt_x04y[].
******  SORT lt_y04y BY lifnr.
******  DELETE ADJACENT DUPLICATES FROM lt_y04y COMPARING lifnr.
******
******  LOOP AT lt_04x INTO ls_04x WHERE zalno = fu_zalno.
******    CLEAR : ls_lfm1.
******    READ TABLE gt_lfm1 INTO ls_lfm1
******                       WITH KEY lifnr = ls_04x-lifnr.
******    IF sy-subrc = 0.
******      CASE ls_lfm1-kalsk.
******        WHEN '01'.
******          poheader-doc_type  = 'ZLOC'.
******        WHEN '02'.
******          poheader-doc_type  = 'ZIMP'.
******      ENDCASE.
******    ENDIF.
******
******    poheader-purch_org = gv_ekorg.
******    poheader-doc_date  = sy-datum.
******    poheader-vendor    = ls_04x-lifnr.
******    CLEAR ls_04z.
******    READ TABLE gt_04z INTO ls_04z
******                      WITH KEY zalno = ls_04x-zalno.
******    IF sy-subrc = 0.
******      poheader-currency  = ls_04z-bwaer.
******      poheader-pur_group = ls_04z-ekgrp.
******      lv_werks           = ls_04z-werks.
******    ENDIF.
******    poheaderx-doc_type  = 'X'.
******    poheaderx-purch_org = 'X'.
******    poheaderx-pur_group = 'X'.
******    poheaderx-doc_date  = 'X'.
******    poheaderx-vendor    = 'X'.
******    poheaderx-currency  = 'X'.
******
******    CLEAR lv_ebelp.
******    LOOP AT lt_y04y INTO ls_y04y WHERE lifnr = ls_04x-lifnr.
******      ADD 10 TO lv_ebelp.
******      ls_item-po_item    = lv_ebelp.
******      ls_item-plant      = lv_werks.
******
*******      ls_item-material   = ls_04x-matnr.
******      PERFORM f_get_material_mpn USING ls_04x-lifnr lv_werks ls_04x-matnr
******                                 CHANGING ls_item-material.
******
******      ls_item-quantity   = ls_04x-menge.
******      ls_item-po_unit    = ls_y04y-meins.
******      ls_item-pricedate  = 1.
******      ls_item-trackingno = fu_zalno.
*******      ls_item-period_ind_expiration_date = 'D'.
******      APPEND ls_item TO poitem.
******
******      ls_itemx-po_item    = lv_ebelp.
******      ls_itemx-po_itemx   = 'X'.
******      ls_itemx-plant      = 'X'.
******      ls_itemx-material   = 'X'.
*******      ls_itemx-ematerial  = 'X'.
******      ls_itemx-quantity   = 'X'.
******      ls_itemx-po_unit    = 'X'.
******      ls_itemx-pricedate  = 'X'.
******      ls_itemx-trackingno = 'X'.
*******      ls_itemx-period_ind_expiration_date = 'X'.
******      APPEND ls_itemx TO poitemx.
******
******      CLEAR lv_etenr.
******      LOOP AT gt_04y INTO ls_04y WHERE zalno = fu_zalno
******                                   AND lifnr = ls_04x-lifnr.
******        IF ls_04y-bsmng = 0.
******          CONTINUE.
******        ENDIF.
******        ADD 1 TO lv_etenr.
******        ls_schedule-po_item        = lv_ebelp.
******        ls_schedule-sched_line     = lv_etenr.
******        ls_schedule-del_datcat_ext = 'D'.
******        ls_schedule-delivery_date  = ls_04y-lfdat.
******        ls_schedule-quantity       = ls_04y-bsmng.
******        ls_schedule-preq_no        = ls_04y-banfn.
******        ls_schedule-preq_item      = ls_04y-bnfpo.
******        APPEND ls_schedule TO poschedule.
******
******        ls_schedulex-po_item        = lv_ebelp.
******        ls_schedulex-po_itemx       = 'X'.
******        ls_schedulex-sched_line     = lv_etenr.
******        ls_schedulex-sched_linex    = 'X'.
******        ls_schedulex-del_datcat_ext = 'X'.
******        ls_schedulex-delivery_date  = 'X'.
******        ls_schedulex-quantity       = 'X'.
******        ls_schedulex-preq_no        = 'X'.
******        ls_schedulex-preq_item      = 'X'.
******        APPEND ls_schedulex TO poschedulex.
******      ENDLOOP.
******    ENDLOOP.
******
******    IF poschedule[] IS NOT INITIAL.
******      CALL FUNCTION 'BAPI_PO_CREATE1'
******        EXPORTING
******          poheader          = poheader
******          poheaderx         = poheaderx
******          memory_uncomplete = 'X'
******          memory_complete   = 'X'
******        IMPORTING
******          exppurchaseorder  = lv_ebeln
******        TABLES
******          return            = return
******          poitem            = poitem
******          poitemx           = poitemx
******          poschedule        = poschedule
******          poschedulex       = poschedulex.
******
******      IF lv_ebeln IS NOT INITIAL.
******        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
******          EXPORTING
******            wait = 'X'.
******
******        DELETE FROM zgdmmt004e WHERE zalno = fu_zalno
******                                 AND lifnr = ls_04x-lifnr.
******
******        LOOP AT poschedule INTO ls_schedule.
******          TRY .
******              UPDATE zgdmmt004y SET ebeln = lv_ebeln
******                                WHERE zalno = fu_zalno
******                                  AND lifnr = ls_04x-lifnr
******                                  AND banfn = ls_schedule-preq_no
******                                  AND	bnfpo = ls_schedule-preq_item.
******            CATCH cx_sy_open_sql_db.
******          ENDTRY.
******        ENDLOOP.
******
******        PERFORM f_prepare_po_email USING '' lv_ebeln fu_zalno.
******      ELSE.
******        PERFORM f_prepare_po_email USING 'X' lv_ebeln fu_zalno.
******
******        LOOP AT return INTO ls_return.
******          IF ls_return-type = 'E'.
******            MOVE-CORRESPONDING ls_return TO ls_04e.
******            ADD 1 TO lv_zrow.
******            ls_04e-zalno    = fu_zalno.
******            ls_04e-lifnr    = ls_04x-lifnr.
******            ls_04e-zrow     = lv_zrow.
******            ls_04e-znumber  = ls_return-number.
******            APPEND ls_04e TO gt_04e.
******          ENDIF.
******          CLEAR ls_04e.
******        ENDLOOP.
******      ENDIF.
******    ENDIF.
******
******    CLEAR : poheader, poheaderx, poitem[], poitem, poitemx[], poitemx,
******            poschedule[], poschedule, poschedulex[], poschedulex,
******            return[], return, lv_zrow.
******  ENDLOOP.
ENDFORM.                    " F_CREATE_PO

*&---------------------------------------------------------------------*
*&      Form  F_SEND_EMAIL
*&---------------------------------------------------------------------*
FORM f_send_email  USING    fu_ebeln fu_zalno fu_ucomm fu_anzef fu_ernam
                            fu_ekgrp.
  DATA : lo_send_request TYPE REF TO cl_bcs,
         lo_document     TYPE REF TO cl_document_bcs,
         lo_sender       TYPE REF TO if_sender_bcs,
         lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL,
         lo_mime_helper  TYPE REF TO cl_gbt_multirelated_service.
  DATA:     bcs_exception TYPE REF TO cx_bcs.

  DATA : lv_zalno(10),
         lv_subject      TYPE so_obj_des,
         lt_message_body TYPE bcsy_text,
         lv_text         TYPE string,
         lv_sent_to_all  TYPE os_boolean,
         lv_status       TYPE bcs_rqst.

  DATA : ls_05    LIKE LINE OF gt_05,
         lv_to    TYPE zhsmmmdt005-smtp_addr,
         lv_cc    TYPE zhsmmmdt005-smtp_addr,
         lv_srno1 TYPE zhsmmmdt005-srno1,
         lv_email TYPE bapiadsmtp-e_mail.

  IF gv_mail IS NOT INITIAL.
    lv_zalno  = fu_zalno.

    "create send request
    lo_send_request = cl_bcs=>create_persistent( ).

    CASE fu_ucomm.
      WHEN '&APPR'.
        "create subject
        SHIFT lv_zalno LEFT DELETING LEADING '0'.
        CONCATENATE 'Approval Form Allocation No.' lv_zalno '( No reply )'
        INTO lv_subject
        SEPARATED BY space.

        "create message body
        CLEAR :  lt_message_body[].
        PERFORM f_create_body TABLES lt_message_body
                              USING lv_zalno fu_anzef '' ''
                                    'ZAPPROVALALOKASI' ''.

      WHEN '&RJCT'.
        "create subject
        SHIFT lv_zalno LEFT DELETING LEADING '0'.
        CONCATENATE 'Reject Form Allocation No.' lv_zalno '( No reply )'
        INTO lv_subject
        SEPARATED BY space.

        "create message body
        CLEAR :  lt_message_body[].
        PERFORM f_create_body TABLES lt_message_body
                              USING lv_zalno fu_anzef '' ''
                                    'ZREJECTALOKASI' ''.

      WHEN OTHERS.
        "create subject
        lv_subject = 'PO No. fully created ( No reply )'.

        "create message body
        CLEAR :  lt_message_body[].
        PERFORM f_create_body TABLES lt_message_body
                              USING lv_zalno fu_anzef fu_ebeln fu_ernam
                                    'ZCREATEPO' 'X'.
    ENDCASE.

    CREATE OBJECT lo_mime_helper.

    CALL METHOD lo_mime_helper->set_main_html
      EXPORTING
        content = lt_message_body.

    lo_document = cl_document_bcs=>create_from_multirelated(
    i_subject          = lv_subject
    i_importance       = '9'
    i_multirel_service = lo_mime_helper ).

    lo_send_request->set_document( lo_document ).

*  lo_sender = cl_sapuser_bcs=>create( sy-uname ).
*
*  lo_send_request->set_sender( lo_sender ).

    READ TABLE gt_05 INTO ls_05
                     WITH KEY ekgrp = fu_ekgrp
                              frgco = pa_frgco.
    IF sy-subrc = 0.
      lv_cc   = ls_05-smtp_addr.
      PERFORM f_get_srno USING fu_ucomm ls_05-srno1
                         CHANGING lv_srno1.
      CLEAR ls_05.
      READ TABLE gt_05 INTO ls_05
                       WITH KEY ekgrp = fu_ekgrp
                                srno1 = lv_srno1
                                zto   = 'X'.
      IF sy-subrc = 0.
        IF ls_05-smtp_addr IS INITIAL.
          PERFORM f_get_srno USING fu_ucomm ls_05-srno1
                             CHANGING lv_srno1.
          CLEAR ls_05.
          READ TABLE gt_05 INTO ls_05
                           WITH KEY ekgrp = fu_ekgrp
                                    srno1 = lv_srno1
                                    zto   = 'X'.
        ENDIF.
        lv_to = ls_05-smtp_addr.
        IF lv_to IS INITIAL.
          CLEAR gv_mail.
        ENDIF.
      ENDIF.
    ENDIF.

    CLEAR lo_recipient.
* Add To
    CASE fu_ucomm.
      WHEN '&APPR'.
        IF lv_to IS INITIAL.
          PERFORM f_get_creator_email USING fu_zalno ''
                                      CHANGING lv_to.
        ENDIF.
        lo_recipient = cl_cam_address_bcs=>create_internet_address( i_address_string = lv_to ).
        lo_send_request->add_recipient( i_recipient  = lo_recipient ).
      WHEN '&RJCT'.
        PERFORM f_get_creator_email USING fu_zalno ''
                                    CHANGING lv_email.
        IF lv_email IS NOT INITIAL.
          lo_recipient = cl_cam_address_bcs=>create_internet_address(
                         i_address_string = lv_email ).
          lo_send_request->add_recipient( i_recipient  = lo_recipient ).
        ENDIF.
      WHEN OTHERS.
        PERFORM f_get_creator_email USING fu_zalno fu_ernam
                                    CHANGING lv_email.
        IF lv_email IS NOT INITIAL.
          lo_recipient = cl_cam_address_bcs=>create_internet_address(
                         i_address_string = lv_email ).
          lo_send_request->add_recipient( i_recipient  = lo_recipient ).
        ENDIF.
    ENDCASE.

** Add CC
*  IF fu_ucomm IS INITIAL.
*  ELSE.
*    lo_recipient = cl_cam_address_bcs=>create_internet_address( i_address_string = lv_cc ).
*    lo_send_request->add_recipient( i_recipient  = lo_recipient
*                                    i_copy       = 'X').
*  ENDIF.
    lv_status = 'N'.
    CALL METHOD lo_send_request->set_status_attributes
      EXPORTING
        i_requested_status = lv_status.
    "EXCEPTIONS
    "  CX_SEND_REQ_BCS .
    TRY.
        lo_send_request->send( ).
        COMMIT WORK.
      CATCH cx_bcs." INTO bcs_exception..
        ROLLBACK WORK.
    ENDTRY.
  ENDIF.
ENDFORM.                    " F_SEND_EMAIL

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_MPN
*&---------------------------------------------------------------------*
FORM f_get_material_mpn  USING    fu_lifnr fu_werks fu_ebeln fu_matnr
                         CHANGING fc_matnr.
  DATA : lr_matnr TYPE RANGE OF matnr,
         ls_matnr LIKE LINE OF lr_matnr,
         ls_qinf  LIKE LINE OF gt_qinf,
         ls_xekpo LIKE LINE OF gt_xekpo.

  CONCATENATE fu_matnr '*' INTO ls_matnr-low.
  ls_matnr-sign   = 'I'.
  ls_matnr-option = 'CP'.
  APPEND ls_matnr TO lr_matnr.
  CLEAR ls_matnr.

  fc_matnr = fu_matnr.

  IF gt_qinf[] IS INITIAL.
    CLEAR ls_xekpo.
    READ TABLE gt_xekpo INTO ls_xekpo
                        WITH KEY ebeln = fu_ebeln
                                 matnr = fu_matnr.
    IF ls_xekpo-idnlf IS INITIAL.
      fc_matnr = fu_matnr.
    ELSE.
      fc_matnr = ls_xekpo-idnlf.
    ENDIF.
  ELSE.
    CLEAR ls_qinf.
    LOOP AT gt_qinf INTO ls_qinf WHERE lieferant = fu_lifnr
                                   AND werk      = fu_werks.
      IF ls_qinf-matnr IN lr_matnr.
        fc_matnr = ls_qinf-matnr.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_MATERIAL_MPN

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_ERROR_LOG
*&---------------------------------------------------------------------*
FORM f_save_error_log .
  DATA : lt_x04e         TYPE STANDARD TABLE OF zgdmmt004e,
         ls_x04e         LIKE LINE OF lt_x04e,
         lv_message(100),
         oref            TYPE REF TO cx_root.

  lt_x04e[] = gt_04e[].
  SORT lt_x04e BY zalno lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_x04e COMPARING zalno lifnr.
  LOOP AT lt_x04e INTO ls_x04e.
    DELETE FROM zgdmmt004e WHERE zalno = ls_x04e-zalno
                             AND lifnr = ls_x04e-lifnr.
  ENDLOOP.

  TRY .
      INSERT zgdmmt004e FROM TABLE gt_04e.
    CATCH cx_sy_open_sql_db INTO oref.
      lv_message = oref->get_text( ).
  ENDTRY.
ENDFORM.                    " F_SAVE_ERROR_LOG

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_BODY
*&---------------------------------------------------------------------*
FORM f_create_body  TABLES   ft_body STRUCTURE soli
                    USING    fu_zalno fu_anzef fu_ebeln fu_ernam
                             fu_name fu_table.

  TYPES : BEGIN OF ty_relcd,
            frgco TYPE t16fd-frgco,
          END OF ty_relcd.

  DATA : lv_name  TYPE thead-tdname,
         lines    TYPE STANDARD TABLE OF tline,
         ls_line  LIKE LINE OF lines,
         lv_line  TYPE i,
         lv_code  TYPE string,
         ls_05    LIKE LINE OF gt_05,
         lv_count TYPE i.

  DATA : lt_relcd TYPE STANDARD TABLE OF ty_relcd,
         ls_relcd LIKE LINE OF lt_relcd.

  DATA : ls_fcat  TYPE lvc_s_fcat,
         lt_body  TYPE bcsy_text,
         ls_body  TYPE soli,
         lt_space TYPE STANDARD TABLE OF string.

  DATA : lt_fields    TYPE STANDARD TABLE OF w3fields.

  lv_name = fu_name.
  SPLIT fu_anzef AT space INTO TABLE lt_relcd.
  LOOP AT lt_relcd INTO ls_relcd.
    READ TABLE gt_05 INTO ls_05
                     WITH KEY frgco = ls_relcd-frgco.
    IF sy-subrc = 0.
      CONCATENATE lv_code ls_05-frgct INTO lv_code
      SEPARATED BY space.
    ENDIF.
  ENDLOOP.

  SHIFT lv_code LEFT DELETING LEADING space.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'ST'
      language                = sy-langu
      name                    = lv_name
      object                  = 'TEXT'
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

  LOOP AT lines INTO ls_line.
    REPLACE ALL OCCURRENCES OF REGEX '&ALLOC&' IN ls_line-tdline WITH fu_zalno.
    REPLACE ALL OCCURRENCES OF REGEX '&RELEASECODE&' IN ls_line-tdline WITH lv_code.
    REPLACE ALL OCCURRENCES OF REGEX '&PONUMBER&' IN ls_line-tdline WITH fu_ebeln.

    IF ls_line-tdformat IS INITIAL.
      DESCRIBE TABLE lt_body LINES lv_line.
      READ TABLE lt_body INTO ls_body INDEX lv_line.
      CONCATENATE ls_body ls_line-tdline INTO ls_body
      SEPARATED BY space.
      MODIFY lt_body FROM ls_body INDEX lv_line.
    ELSE.
      APPEND ls_line-tdline TO lt_body.
    ENDIF.
  ENDLOOP.

  CLEAR : ft_body[], lv_line.
  IF fu_table IS NOT INITIAL.
    CLEAR : gt_tfcat[], gt_ffcat[].
    PERFORM f_create_mail_fieldcat USING : 'PO No.' '',
                                           'Alokasi No.' '',
                                           'Alokasi No.' 'X'.
    IF gt_tfcat[] IS NOT INITIAL.
      PERFORM f_create_mail_table TABLES gt_tfcat
                                  USING 'green' fu_ernam.
    ENDIF.

    IF gt_ffcat[] IS NOT INITIAL.
      PERFORM f_create_mail_table TABLES gt_ffcat
                                  USING 'red' fu_ernam.
    ENDIF.

    LOOP AT lt_body INTO ls_body.
      IF lv_line IS NOT INITIAL.
        IF ls_body-line IS NOT INITIAL.
          EXIT.
        ENDIF.
      ENDIF.
      ADD 1 TO lv_line.
      IF ls_body-line IS INITIAL.
        ls_body-line = '<br />'.
      ENDIF.
      APPEND ls_body TO ft_body.
      CLEAR ls_body.
    ENDLOOP.

    IF gt_thtml[] IS NOT INITIAL.
      LOOP AT gt_thtml INTO ls_body.
        APPEND ls_body TO ft_body.
        CLEAR ls_body.
      ENDLOOP.

      DO 2 TIMES.
        ls_body-line = '<br />'.
        APPEND ls_body TO ft_body.
        CLEAR ls_body.
      ENDDO.
    ENDIF.

    LOOP AT gt_fhtml INTO ls_body.
      APPEND ls_body TO ft_body.
      CLEAR ls_body.
    ENDLOOP.

    LOOP AT lt_body INTO ls_body FROM lv_line.
      IF ls_body-line IS INITIAL.
        ls_body-line = '<br />'.
      ELSE.
        CONCATENATE ls_body-line '<br />' INTO ls_body-line
        SEPARATED BY space.
      ENDIF.
      APPEND ls_body TO ft_body.
      CLEAR ls_body.
    ENDLOOP.
  ELSE.
    LOOP AT lt_body INTO ls_body.
      IF ls_body-line IS INITIAL.
        ls_body-line = '<br />'.
      ELSE.
        CONCATENATE ls_body-line '<br />' INTO ls_body-line
        SEPARATED BY space.
      ENDIF.
      APPEND ls_body TO ft_body.
      CLEAR ls_body.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_CREATE_BODY

*&---------------------------------------------------------------------*
*&      Form  F_GET_CREATOR_EMAIL
*&---------------------------------------------------------------------*
FORM f_get_creator_email  USING    fu_zalno fu_ernam
                          CHANGING fc_email.
  DATA : ls_04z     LIKE LINE OF gt_04z,
         addsmtp    TYPE STANDARD TABLE OF bapiadsmtp,
         return     TYPE STANDARD TABLE OF bapiret2,
         ls_addsmtp LIKE LINE OF addsmtp.

  IF fu_zalno IS INITIAL.
    ls_04z-ernam  = fu_ernam.
  ELSE.
    CLEAR ls_04z.
    READ TABLE gt_04z INTO ls_04z
                      WITH KEY zalno = fu_zalno.
  ENDIF.

  IF ls_04z-ernam IS NOT INITIAL.
    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        username = ls_04z-ernam
      TABLES
        return   = return
        addsmtp  = addsmtp.

    READ TABLE addsmtp INTO ls_addsmtp INDEX 1.
    IF sy-subrc = 0.
      fc_email  = ls_addsmtp-e_mail.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_CREATOR_EMAIL

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_PO_EMAIL
*&---------------------------------------------------------------------*
FORM f_prepare_po_email  USING    fu_error fu_ebeln fu_zalno.
  DATA : ls_poemail LIKE LINE OF gt_poemail,
         ls_04z     LIKE LINE OF gt_04z.

  ls_poemail-ebeln  = fu_ebeln.
  ls_poemail-zalno  = fu_zalno.
  READ TABLE gt_04z INTO ls_04z
                    WITH KEY zalno = fu_zalno.
  IF sy-subrc = 0.
    ls_poemail-ernam    = ls_04z-ernam.
  ENDIF.
  APPEND ls_poemail TO gt_poemail.
ENDFORM.                    " F_PREPARE_PO_EMAIL

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_MAIL_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_create_mail_fieldcat  USING    fu_coltext fu_flag.
  DATA : ls_fcat      TYPE lvc_s_fcat.

  ls_fcat-coltext = fu_coltext.
  IF fu_flag IS INITIAL.
    APPEND ls_fcat TO gt_tfcat.
  ELSE.
    APPEND ls_fcat TO gt_ffcat.
  ENDIF.
ENDFORM.                    " F_CREATE_MAIL_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_MAIL_TABLE
*&---------------------------------------------------------------------*
FORM f_create_mail_table  TABLES   ft_fcat  TYPE lvc_t_fcat
                          USING    fu_bgcolor fu_ernam.
  TYPES : BEGIN OF ty_ttable,
            ebeln TYPE ekko-ebeln,
            zalno TYPE zgdmmt004z-zalno,
          END OF ty_ttable.

  TYPES : BEGIN OF ty_ftable,
            zalno TYPE zgdmmt004z-zalno,
          END OF ty_ftable.

  DATA : lt_header  TYPE STANDARD TABLE OF w3head,
         lt_fields  TYPE STANDARD TABLE OF w3fields,
         lt_poemail TYPE STANDARD TABLE OF ty_poemail,
         ls_email   TYPE ty_poemail,
         lv_text    TYPE w3head-text.

  DATA : lt_ttable TYPE STANDARD TABLE OF ty_ttable,
         ls_ttable LIKE LINE OF lt_ttable,
         lt_ftable TYPE STANDARD TABLE OF ty_ftable,
         ls_ftable LIKE LINE OF lt_ftable,
         ls_fcat   TYPE lvc_s_fcat.

  LOOP AT ft_fcat INTO ls_fcat.
    lv_text = ls_fcat-coltext.
    CALL FUNCTION 'WWW_ITAB_TO_HTML_HEADERS'
      EXPORTING
        field_nr = sy-tabix
        text     = lv_text
        fgcolor  = 'black'
        bgcolor  = fu_bgcolor
      TABLES
        header   = lt_header.

    CALL FUNCTION 'WWW_ITAB_TO_HTML_LAYOUT'
      EXPORTING
        field_nr = sy-tabix
        fgcolor  = 'black'
        size     = '3'
      TABLES
        fields   = lt_fields.
  ENDLOOP.

  CASE fu_bgcolor.
    WHEN 'green'.
      LOOP AT gt_poemail INTO ls_email WHERE ebeln <> space
                                         AND ernam = fu_ernam.
        ls_ttable-zalno   = ls_email-zalno.
        ls_ttable-ebeln   = ls_email-ebeln.
        APPEND ls_ttable TO lt_ttable.
        CLEAR ls_ttable.
      ENDLOOP.
      SORT lt_ttable BY zalno ebeln.
      DELETE ADJACENT DUPLICATES FROM lt_ttable COMPARING zalno ebeln.

      CLEAR gt_thtml[].
      IF lt_ttable[] IS NOT INITIAL.
        CALL FUNCTION 'WWW_ITAB_TO_HTML'
          TABLES
            html       = gt_thtml
            fields     = lt_fields
            row_header = lt_header
            itable     = lt_ttable.
      ENDIF.

    WHEN 'red'.
      LOOP AT gt_poemail INTO ls_email WHERE ebeln = space
                                         AND ernam = fu_ernam.
        ls_ftable-zalno   = ls_email-zalno.
        APPEND ls_ftable TO lt_ftable.
        CLEAR ls_ftable.
      ENDLOOP.
      SORT lt_ftable BY zalno.
      DELETE ADJACENT DUPLICATES FROM lt_ftable COMPARING zalno.

      CLEAR gt_fhtml[].
      IF lt_ftable[] IS NOT INITIAL.
        CALL FUNCTION 'WWW_ITAB_TO_HTML'
          TABLES
            html       = gt_fhtml
            fields     = lt_fields
            row_header = lt_header
            itable     = lt_ftable.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_CREATE_MAIL_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_PO_OPEN
*&---------------------------------------------------------------------*
FORM f_check_po_open  USING    fu_zalno
                      CHANGING fc_subrc.
  DATA : ls_04y  LIKE LINE OF gt_04y,
         ls_ekpo LIKE LINE OF gt_ekpo,
         ls_out  LIKE LINE OF gt_out,
         ls_05   LIKE LINE OF gt_05.

  DATA : lv_line(3)   TYPE n.

  DESCRIBE TABLE gt_05 LINES lv_line.
  CLEAR ls_05.
  READ TABLE gt_05 INTO ls_05
                   WITH KEY frgco = pa_frgco.
  IF ls_05-srno1 = lv_line.
    CLEAR : fc_subrc, ls_04y.
    READ TABLE gt_04y INTO ls_04y
                      WITH KEY zalno = fu_zalno.
    IF ls_04y-ebeln IS NOT INITIAL.
      CLEAR ls_ekpo.
      READ TABLE gt_ekpo INTO ls_ekpo
                         WITH KEY ebeln = ls_04y-ebeln.
      IF sy-subrc = 0.
        fc_subrc    = 4.
        ls_out-icon = icon_led_red.
      ELSE.
        CLEAR ls_out-icon.
      ENDIF.
      MODIFY gt_out FROM ls_out
                    TRANSPORTING icon
                    WHERE zalno = fu_zalno.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_PO_OPEN

*&---------------------------------------------------------------------*
*&      Form  F_COLORING_COLUMN
*&---------------------------------------------------------------------*
FORM f_coloring_column  TABLES   ft_tcol  TYPE table
                        USING    fu_fieldname fu_col fu_int fu_inv.
  DATA : ls_scol    TYPE lvc_s_scol.

  CLEAR ls_scol.
  ls_scol-fname     = fu_fieldname.
  ls_scol-color-col = fu_col.
  ls_scol-color-int = fu_int.
  ls_scol-color-inv = fu_inv.
  INSERT ls_scol INTO TABLE ft_tcol..
ENDFORM.                    " F_COLORING_COLUMN

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_AUTHORIZATION
*&---------------------------------------------------------------------*
FORM f_check_authorization  USING    fu_ekgrp fu_frgco fu_procstat fu_ucomm
                            CHANGING fc_subrc fc_frgco fc_procstat.
  DATA : lt_x05 TYPE STANDARD TABLE OF zhsmmmdt005,
         ls_x05 LIKE LINE OF lt_x05,
         ls_05  LIKE LINE OF gt_05,
         ls_005 TYPE zhsmmmdt005.

  DATA : lv_srno1 TYPE zhsmmmdt005-srno1,
         lv_srno2 TYPE zhsmmmdt005-srno1,
         lv_frgco TYPE zhsmmmdt005-frgco,
         lv_count TYPE i,
         lv_subrc TYPE sy-subrc.

  CLEAR : fc_subrc, fc_frgco, fc_procstat.

  lt_x05[] = gt_05[].
  DELETE lt_x05 WHERE ekgrp <> fu_ekgrp.
  SORT lt_x05 BY srno1 DESCENDING.
  CLEAR ls_x05.
  READ TABLE lt_x05 INTO ls_x05 INDEX 1.

  CLEAR ls_05.
  READ TABLE gt_05 INTO ls_05
                    WITH KEY ekgrp = fu_ekgrp
                             frgco = fu_frgco.
  IF sy-subrc = 0.
    lv_srno1  = ls_05-srno1.
  ENDIF.

  CLEAR ls_05.
  READ TABLE gt_05 INTO ls_05
                    WITH KEY ekgrp = fu_ekgrp
                             frgco = pa_frgco.
  IF sy-subrc = 0.
    lv_srno2  = ls_05-srno1.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      CASE fu_ucomm.
        WHEN '&APPR'.
          lv_srno2  = lv_srno2 - 1.
          SELECT SINGLE *
            FROM zhsmmmdt005
            INTO CORRESPONDING FIELDS OF ls_005
            WHERE srno1 = lv_srno2
              AND frgco = fu_frgco.
          IF sy-subrc = 0.
*          IF lv_srno1 = lv_srno2.    " remarks due to replicate line for the same frgco read
            IF fu_procstat <> '08'.
              fc_frgco    = ls_05-frgco.
              IF ls_x05-frgco = pa_frgco.
                fc_procstat = '05'.
              ELSE.
                fc_procstat = '03'.
              ENDIF.
            ELSE.
              fc_subrc = 3.
            ENDIF.
          ELSE.
            IF fu_frgco = pa_frgco.
              fc_subrc = 2.
            ELSE.
              fc_subrc = 1.
            ENDIF.
          ENDIF.
        WHEN '&RJCT'.
          lv_subrc = 4.
          WHILE lv_subrc IS NOT INITIAL.
            ADD 1 TO lv_count.
            lv_srno2  = lv_srno2 - 1.
            READ TABLE gt_05 INTO ls_05
                  WITH KEY ekgrp = fu_ekgrp
                           srno1 = lv_srno2.
            IF sy-subrc = 0 AND
              ls_05-smtp_addr IS NOT INITIAL.
              CLEAR lv_subrc.
            ELSEIF lv_count = 10.
              CLEAR lv_subrc.
            ENDIF.
          ENDWHILE.
          IF lv_srno1 = lv_srno2.
            fc_frgco    = fu_frgco.
            fc_procstat = '08'.
          ELSE.
            fc_subrc = 1.
          ENDIF.
      ENDCASE.

    WHEN radio2.
      CASE fu_ucomm.
        WHEN '&APPR'.
          IF lv_srno2 = lv_srno1.
            IF lv_srno1 = 1.
              CLEAR : fc_frgco, fc_procstat.
            ELSE.
              fc_procstat = '03'.
              lv_subrc = 4.
              WHILE lv_subrc IS NOT INITIAL.
                ADD 1 TO lv_count.
                lv_srno2  = lv_srno2 - 1.
                CLEAR ls_05.
                READ TABLE gt_05 INTO ls_05
                                  WITH KEY ekgrp = fu_ekgrp
                                           srno1 = lv_srno2.
                IF sy-subrc = 0 AND
                  ls_05-smtp_addr IS NOT INITIAL.
                  CLEAR lv_subrc.
                  fc_frgco    = ls_05-frgco.
                ELSEIF lv_count = 10.
                  CLEAR lv_subrc.
                ENDIF.
              ENDWHILE.
            ENDIF.
          ELSE.
            fc_subrc = 1.
          ENDIF.
        WHEN '&RJCT'.
          IF fu_procstat = '08'.
            lv_subrc = 4.
            WHILE lv_subrc IS NOT INITIAL.
              ADD 1 TO lv_count.
              lv_srno2  = lv_srno2 - 1.
              READ TABLE gt_05 INTO ls_05
                                WITH KEY ekgrp = fu_ekgrp
                                         srno1 = lv_srno2.
              IF sy-subrc = 0 AND
                ls_05-smtp_addr IS NOT INITIAL.
                CLEAR lv_subrc.
              ELSEIF lv_count = 10.
                CLEAR lv_subrc.
              ENDIF.
            ENDWHILE.
            IF lv_srno1 = lv_srno2.
*              lv_srno2 = lv_srno2 + 1.
              READ TABLE gt_05 INTO ls_05
                                WITH KEY ekgrp = fu_ekgrp
                                         srno1 = lv_srno2.
              IF sy-subrc = 0.
                fc_frgco    = ls_05-frgco.
                fc_procstat = '03'.
              ENDIF.
            ELSE.
              fc_subrc = 1.
            ENDIF.
          ELSE.
            fc_subrc = 1.
          ENDIF.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_CHECK_AUTHORIZATION

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_TEMPORARY_FORM
*&---------------------------------------------------------------------*
FORM f_delete_temporary_form .
  DATA : ls_temp   LIKE LINE OF gt_temp,
         rc        TYPE i,
         directory TYPE string,
         document  TYPE string,
         filesize  TYPE i,
         i         TYPE i,
         result    TYPE tdbool,
         ftab(200) TYPE c OCCURS 0,
         ls_ftab   LIKE LINE OF ftab.

  CALL METHOD cl_gui_frontend_services=>get_sapgui_workdir
    CHANGING
      sapworkdir            = directory
    EXCEPTIONS
      get_sapworkdir_failed = 1
      cntl_error            = 2
      error_no_gui          = 3
      not_supported_by_gui  = 4
      OTHERS                = 5.
  IF sy-subrc = 0.
    CALL METHOD cl_gui_frontend_services=>directory_list_files
      EXPORTING
        directory                   = directory
        filter                      = '*.pdf'
      CHANGING
        file_table                  = ftab
        count                       = i
      EXCEPTIONS
        cntl_error                  = 1
        directory_list_files_failed = 2
        wrong_parameter             = 3
        error_no_gui                = 4
        OTHERS                      = 5.
  ENDIF.

  LOOP AT ftab INTO ls_ftab.
    ls_temp-document  = ls_ftab.
    APPEND ls_temp TO gt_temp.
    CLEAR ls_temp.
  ENDLOOP.

  LOOP AT gt_temp INTO ls_temp.
    CALL METHOD cl_gui_frontend_services=>file_delete
      EXPORTING
        filename             = ls_temp-document
      CHANGING
        rc                   = rc
      EXCEPTIONS
        file_delete_failed   = 1
        cntl_error           = 2
        error_no_gui         = 3
        file_not_found       = 4
        access_denied        = 5
        unknown_error        = 6
        not_supported_by_gui = 7
        wrong_parameter      = 8.
  ENDLOOP.
ENDFORM.                    " F_DELETE_TEMPORARY_FORM

*&---------------------------------------------------------------------*
*&      Form  F_NEW_CREATE_PO
*&---------------------------------------------------------------------*
FORM f_new_create_po  USING    fu_zalno.
  DATA : lt_04x  TYPE STANDARD TABLE OF zgdmmt004x,
         lt_x04y TYPE STANDARD TABLE OF zgdmmt004y,
         lt_x04p TYPE STANDARD TABLE OF zgdmmt004p,
         ls_x04y LIKE LINE OF lt_x04y,
         lt_y04y TYPE STANDARD TABLE OF zgdmmt004y,
         ls_y04y LIKE LINE OF lt_x04y,
         ls_x04p LIKE LINE OF lt_x04p,
         ls_04z  LIKE LINE OF gt_04z,
         ls_04y  LIKE LINE OF gt_04y,
         ls_04x  LIKE LINE OF gt_04x,
         ls_04p  LIKE LINE OF gt_04p,
         ls_04e  LIKE LINE OF gt_04e,
         ls_lfm1 LIKE LINE OF gt_lfm1.

  DATA : poheader     TYPE bapimepoheader,
         poheaderx    TYPE bapimepoheaderx,
         poitem       TYPE STANDARD TABLE OF bapimepoitem,
         ls_item      LIKE LINE OF poitem,
         poitemx      TYPE STANDARD TABLE OF bapimepoitemx,
         ls_itemx     LIKE LINE OF poitemx,
         poschedule   TYPE STANDARD TABLE OF bapimeposchedule,
         ls_schedule  LIKE LINE OF poschedule,
         poschedulex  TYPE STANDARD TABLE OF bapimeposchedulx,
         ls_schedulex LIKE LINE OF poschedulex,
         return       TYPE STANDARD TABLE OF bapiret2,
         ls_return    LIKE LINE OF return,
         ls_out       LIKE LINE OF gt_out.

  DATA : lv_ebeln TYPE ekko-ebeln,
         lv_werks TYPE ekpo-werks,
         lv_ebelp TYPE ekpo-ebelp,
         lv_etenr TYPE eket-etenr,
         lv_zrow  TYPE i.

  lt_04x[] = gt_04x[].
  DELETE lt_04x WHERE zalno <> fu_zalno.
  lt_x04y[] = gt_04y[].
  DELETE lt_x04y WHERE zalno <> fu_zalno.
  SORT lt_x04y BY lifnr banfn.
  DELETE ADJACENT DUPLICATES FROM lt_x04y COMPARING lifnr banfn.
  lt_y04y[] = lt_x04y[].
  SORT lt_y04y BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_y04y COMPARING lifnr.
  SORT gt_04p BY lifnr zeile.
  lt_x04p[] = gt_04p[].
  DELETE lt_x04p WHERE zalno <> fu_zalno.
  DELETE ADJACENT DUPLICATES FROM lt_x04p COMPARING lifnr zeile.

  LOOP AT lt_04x INTO ls_04x.
    PERFORM f_get_netpr_from_pir USING ls_04x-lifnr ls_04x-ebeln ls_04x-matnr
                                 CHANGING ls_04x-netpr.
*    CLEAR ls_out.
*    READ TABLE gt_out INTO ls_out
*                      WITH KEY zalno = fu_zalno
*                               lifnr = ls_04x-lifnr.
*
*    IF ls_04x-waers <> 'IDR'.
*      CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
*        EXPORTING
*          date             = sy-datum
*          foreign_amount   = ls_out-netpr
*          foreign_currency = ls_04x-waers
*          local_currency   = 'IDR'
*        IMPORTING
*          local_amount     = ls_out-netpr.
*    ENDIF.
*
*    ls_04x-netpr  = ls_out-netpr.
    MODIFY lt_04x FROM ls_04x TRANSPORTING netpr.
  ENDLOOP.

  SORT lt_04x BY zalno netpr.
  LOOP AT lt_04x INTO ls_04x WHERE zalno = fu_zalno.
    CLEAR : ls_lfm1.
    READ TABLE gt_lfm1 INTO ls_lfm1
                       WITH KEY lifnr = ls_04x-lifnr.
    IF sy-subrc = 0.
      CASE ls_lfm1-kalsk.
        WHEN '01'.
          poheader-doc_type  = 'ZLOC'.
        WHEN '02'.
          poheader-doc_type  = 'ZIMP'.
      ENDCASE.
    ENDIF.

    poheader-purch_org = gv_ekorg.
    poheader-doc_date  = sy-datum.
    poheader-vendor    = ls_04x-lifnr.
    poheader-currency  = ls_04x-waers.
    CLEAR ls_04z.
    READ TABLE gt_04z INTO ls_04z
                      WITH KEY zalno = ls_04x-zalno.
    IF sy-subrc = 0.
      poheader-pur_group  = ls_04z-ekgrp.
      poheader-created_by = ls_04z-ernam.
      lv_werks            = ls_04z-werks.
    ENDIF.
    poheaderx-doc_type    = 'X'.
    poheaderx-purch_org   = 'X'.
    poheaderx-pur_group   = 'X'.
    poheaderx-doc_date    = 'X'.
    poheaderx-vendor      = 'X'.
    poheaderx-created_by  = 'X'.
    poheaderx-currency    = 'X'.

    CLEAR lv_ebelp.
    LOOP AT lt_x04p INTO ls_x04p WHERE lifnr = ls_04x-lifnr.
      ADD 10 TO lv_ebelp.
      CLEAR: lv_etenr, ls_item-quantity.
      LOOP AT gt_04p INTO ls_04p WHERE zalno = fu_zalno
                                   AND lifnr = ls_x04p-lifnr
                                   AND zeile = ls_x04p-zeile.
        IF ls_04p-menge = 0.
          CONTINUE.
        ENDIF.
        READ TABLE gt_04y INTO ls_04y WITH KEY zalno = fu_zalno
                                               lifnr = ls_04p-lifnr
                                               banfn = ls_04p-banfn
                                               bnfpo = ls_04p-bnfpo.
*            IF ls_04y-bsmng = 0.
*              CONTINUE.
*            ENDIF.
        ADD 1 TO lv_etenr.
        ls_schedule-po_item        = lv_ebelp.
        ls_schedule-sched_line     = lv_etenr.
        ls_schedule-del_datcat_ext = 'D'.
        ls_schedule-delivery_date  = ls_04y-lfdat.
        ls_schedule-quantity       = ls_04p-menge.
        ls_schedule-preq_no        = ls_04y-banfn.
        ls_schedule-preq_item      = ls_04y-bnfpo.
        APPEND ls_schedule TO poschedule.

        ls_schedulex-po_item        = lv_ebelp.
        ls_schedulex-po_itemx       = 'X'.
        ls_schedulex-sched_line     = lv_etenr.
        ls_schedulex-sched_linex    = 'X'.
        ls_schedulex-del_datcat_ext = 'X'.
        ls_schedulex-delivery_date  = 'X'.
        ls_schedulex-quantity       = 'X'.
        ls_schedulex-preq_no        = 'X'.
        ls_schedulex-preq_item      = 'X'.
        APPEND ls_schedulex TO poschedulex.
        ls_item-quantity = ls_item-quantity + ls_04p-menge.
      ENDLOOP.

*        LOOP AT lt_y04y INTO ls_y04y WHERE lifnr = ls_04p-lifnr
*                                       AND banfn = ls_04p-banfn
*                                       AND bnfpo = ls_04p-bnfpo.
*
      ls_item-po_item    = lv_ebelp.
      ls_item-plant      = lv_werks.

*      ls_item-material   = ls_04x-matnr.
      PERFORM f_get_material_mpn USING ls_04x-lifnr lv_werks ls_04x-ebeln ls_04x-matnr
                                 CHANGING ls_item-material.

*      ls_item-quantity   = ls_04x-menge.
      ls_item-po_unit    = ls_x04p-meins.     "ls_y04y-meins.
      ls_item-pricedate  = 1.
      ls_item-trackingno = fu_zalno.
      ls_item-stge_loc   = ls_x04p-lgort.     "ls_y04y-lgort.
*      ls_item-period_ind_expiration_date = 'D'.
      APPEND ls_item TO poitem.

      ls_itemx-po_item    = lv_ebelp.
      ls_itemx-po_itemx   = 'X'.
      ls_itemx-plant      = 'X'.
      ls_itemx-material   = 'X'.
*      ls_itemx-ematerial  = 'X'.
      ls_itemx-quantity   = 'X'.
      ls_itemx-po_unit    = 'X'.
      ls_itemx-pricedate  = 'X'.
      ls_itemx-trackingno = 'X'.
      ls_itemx-stge_loc   = 'X'.
*      ls_itemx-period_ind_expiration_date = 'X'.
      APPEND ls_itemx TO poitemx.

*        endloop.

      IF poschedule[] IS NOT INITIAL.
        CALL FUNCTION 'BAPI_PO_CREATE1'
          EXPORTING
            poheader          = poheader
            poheaderx         = poheaderx
            memory_uncomplete = 'X'
            memory_complete   = 'X'
          IMPORTING
            exppurchaseorder  = lv_ebeln
          TABLES
            return            = return
            poitem            = poitem
            poitemx           = poitemx
            poschedule        = poschedule
            poschedulex       = poschedulex.

        IF lv_ebeln IS NOT INITIAL.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.

          DELETE FROM zgdmmt004e WHERE zalno = fu_zalno
                                   AND lifnr = ls_04x-lifnr.

          LOOP AT poschedule INTO ls_schedule.
            TRY .
                UPDATE zgdmmt004p SET ebeln  = lv_ebeln
                                  WHERE zalno = fu_zalno
                                    AND lifnr = ls_04x-lifnr
                                    AND banfn = ls_schedule-preq_no
                                    AND	bnfpo = ls_schedule-preq_item
                                    AND zeile = ls_04p-zeile.
              CATCH cx_sy_open_sql_db.
            ENDTRY.
          ENDLOOP.

          PERFORM f_prepare_po_email USING '' lv_ebeln fu_zalno.
        ELSE.
          PERFORM f_prepare_po_email USING 'X' lv_ebeln fu_zalno.

          LOOP AT return INTO ls_return.
            IF ls_return-type = 'E'.
              MOVE-CORRESPONDING ls_return TO ls_04e.
              ADD 1 TO lv_zrow.
              ls_04e-zalno    = fu_zalno.
              ls_04e-lifnr    = ls_04x-lifnr.
              ls_04e-zrow     = lv_zrow.
              ls_04e-znumber  = ls_return-number.
              APPEND ls_04e TO gt_04e.
            ENDIF.
            CLEAR ls_04e.
          ENDLOOP.
        ENDIF.
      ENDIF.
      CLEAR : poitem[], poitem, poitemx[], poitemx,
              poschedule[], poschedule, poschedulex[], poschedulex,
              return[], return, lv_zrow.
    ENDLOOP.
    CLEAR : poheader, poheaderx, poitem[], poitem, poitemx[], poitemx,
            poschedule[], poschedule, poschedulex[], poschedulex,
            return[], return, lv_zrow.
  ENDLOOP.
*ENDLOOP.
ENDFORM.                    " F_NEW_CREATE_PO

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_MESSAGE
*&---------------------------------------------------------------------*
FORM f_display_message  USING    fu_row fu_column.
  DATA : ls_out      LIKE LINE OF gt_out,
         ls_return   LIKE LINE OF gt_return,
         lt_bapiret2 TYPE STANDARD TABLE OF bapiret2,
         ls_bapiret2 LIKE LINE OF gt_bapiret2.

  DATA  : lv_line       TYPE i.

  READ TABLE gt_out INTO ls_out INDEX fu_row.
  IF ls_out-icon = icon_led_red OR
    ls_out-icon = icon_locked.
    LOOP AT gt_return INTO ls_return WHERE zalno = ls_out-zalno.
      MOVE-CORRESPONDING ls_return TO ls_bapiret2.
      APPEND ls_bapiret2 TO lt_bapiret2.
      CLEAR ls_bapiret2.
    ENDLOOP.

    IF lt_bapiret2[] IS NOT INITIAL.
      DESCRIBE TABLE lt_bapiret2 LINES lv_line.
      IF lv_line = 1.
        APPEND INITIAL LINE TO lt_bapiret2.
      ENDIF.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = lt_bapiret2.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DISPLAY_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_MESSAGE
*&---------------------------------------------------------------------*
FORM f_save_message  USING    fu_zalno fu_subrc fu_guname.
  DATA : ls_return LIKE LINE OF gt_return,
         lv_mess   TYPE bapiret2-message_v1.

  CASE fu_subrc.
    WHEN '1'.
      lv_mess   = 'You are not authorized'.
    WHEN '2'.
      CONCATENATE 'You are already approved Allocation' fu_zalno
      INTO lv_mess
      SEPARATED BY space.
    WHEN '3'.
      CONCATENATE 'Allocation' fu_zalno 'rejected'
      INTO lv_mess
      SEPARATED BY space.
    WHEN '4'.
      CONCATENATE 'Transaction lock by' fu_guname
      INTO lv_mess
      SEPARATED BY space.
  ENDCASE.

  ls_return-zalno       = fu_zalno.
  ls_return-type        = 'E'.
  ls_return-id          = 'ZAB'.
  ls_return-message_v1  = lv_mess.
  APPEND ls_return TO gt_return.
  CLEAR ls_return.
ENDFORM.                    " F_SAVE_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_F4_FRGCO
*&---------------------------------------------------------------------*
FORM f_f4_frgco  CHANGING fc_frgco.
  TYPES : BEGIN OF ty_release,
            ekgrp TYPE zhsmmmdt005-ekgrp,
            frgco TYPE zhsmmmdt005-frgco,
            frgct TYPE zhsmmmdt005-frgct,
          END OF ty_release.

  DATA : lt_005     TYPE STANDARD TABLE OF zhsmmmdt005,
         lt_release TYPE STANDARD TABLE OF ty_release,
         ls_005     LIKE LINE OF lt_005,
         ls_release LIKE LINE OF lt_release.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : lv_subrc       TYPE sy-subrc.

  SELECT *
    FROM zhsmmmdt005
    INTO CORRESPONDING FIELDS OF TABLE lt_005
    WHERE tcode = 'ZMME013'.

  LOOP AT lt_005 INTO ls_005.
    MOVE-CORRESPONDING ls_005 TO ls_release.
    APPEND ls_release TO lt_release.
  ENDLOOP.

  ASSIGN lt_release[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'FRGCO' 'PA_FRGCO'
                          CHANGING lv_subrc.
ENDFORM.                    " F_F4_FRGCO

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

  fc_subrc  = sy-subrc.
ENDFORM.                    " F_VALUE_REQUEST

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
*&      Form  F_EVENT_RAISE
*&---------------------------------------------------------------------*
FORM f_event_raise  USING    fu_zalno.
  DATA : ls_003     TYPE zhsmmmdt003.

  CALL FUNCTION 'ZBP_EVENT_RAISE'
    EXPORTING
      eventid                = 'EPROC_PO'
    EXCEPTIONS
      bad_eventid            = 1
      eventid_does_not_exist = 2
      eventid_missing        = 3
      raise_failed           = 4.
  "OTHERS                 = 5.
  ls_003-zproses = 'HSM_CREATEPO'.
  ls_003-zdata   = fu_zalno.
  ls_003-erdat   = sy-datum.
  ls_003-ernam   = sy-uname.
  ls_003-erzet   = sy-uzeit.
  MODIFY zhsmmmdt003 FROM ls_003.
ENDFORM.                    " F_EVENT_RAISE

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_CHANGES
*&---------------------------------------------------------------------*
FORM f_save_changes  USING    fu_zalno fu_procstat fu_frgco fu_objectclass.
  DATA : ls_04z  LIKE LINE OF gt_04z,
         ls_o04z TYPE zgdmmst004z,
         ls_n04z TYPE zgdmmst004z.

  DATA : objectclass TYPE cdhdr-objectclas,
         objectid    TYPE cdhdr-objectid,
         texttable   TYPE STANDARD TABLE OF cdtxt.

  READ TABLE gt_04z INTO ls_04z
                    WITH KEY zalno = fu_zalno.
  IF sy-subrc = 0.
    MOVE-CORRESPONDING ls_04z TO ls_o04z.
    ls_n04z           = ls_o04z.
    ls_n04z-frgco     = fu_frgco.

    objectid          = fu_zalno.
    objectclass       = fu_objectclass.

    CALL FUNCTION 'ZHSMMM_FM001'
      EXPORTING
        objectclass      = objectclass
        objectid         = objectid
        tcode            = sy-tcode
        utime            = sy-uzeit
        udate            = sy-datum
        username         = sy-uname
        workarea_new     = ls_n04z
        workarea_old     = ls_o04z
        change_indicator = 'U'
      TABLES
        texttable        = texttable.
  ENDIF.
ENDFORM.                    " F_SAVE_CHANGES

*&---------------------------------------------------------------------*
*&      Form  F_ADD_SIGNATURE
*&---------------------------------------------------------------------*
FORM f_add_signature USING fu_zalno.
  DATA : ls_04z   LIKE LINE OF gt_04z.

  READ TABLE gt_04z INTO ls_04z
                    WITH KEY zalno = fu_zalno.
  IF sy-subrc = 0.
    CALL FUNCTION 'ZHSMMM_FM002'
      EXPORTING
        pi_submi            = ls_04z-submi
        pi_zalno            = ls_04z-zalno
        pi_prgrp            = ls_04z-prgrp
        pi_getoff           = 'X'
        pi_tdnoprev         = 'X'
        pi_nodialog         = 'X'
      EXCEPTIONS
        product_group_error = 1
        OTHERS              = 2.
  ENDIF.
ENDFORM.                    " F_ADD_SIGNATURE

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_PDF_TEMP
*&---------------------------------------------------------------------*
FORM f_clear_pdf_temp .
*  PERFORM f_delete_temporary_form.
ENDFORM.                    " F_CLEAR_PDF_TEMP

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_DATA
*&---------------------------------------------------------------------*
FORM f_lock_data  USING    fu_lock fu_zalno fu_submi
                  CHANGING fc_icon.
  DATA : lv_gname     TYPE seqg3-gname,
         lv_garg      TYPE seqg3-garg,
         enq          TYPE STANDARD TABLE OF seqg3,
         ls_enq       LIKE LINE OF enq,
         lv_mess(100),
         lv_subrc     TYPE sy-subrc.

  CLEAR : gv_guname, fc_icon.

  lv_gname       = 'ZGDMMT004Z'.
  lv_garg(3)     = sy-mandt.
  lv_garg+3(10)  = fu_zalno.
  lv_garg+13(10) = fu_submi.

  IF fu_lock IS NOT INITIAL.
    CALL FUNCTION 'ENQUEUE_READ'
      EXPORTING
        gname                 = lv_gname
        guname                = space
      TABLES
        enq                   = enq
      EXCEPTIONS
        communication_failure = 1
        system_failure        = 2
        OTHERS                = 3.

    IF enq[] IS INITIAL.
      CALL FUNCTION 'ENQUEUE_EZGDMMT004Z'
        EXPORTING
          zalno          = fu_zalno
          submi          = fu_submi
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
    ELSE.
      LOOP AT enq INTO ls_enq.
        IF ls_enq-garg(23) = lv_garg(23).
          fc_icon  = icon_locked.
          lv_subrc = '4'.
          PERFORM f_save_message USING fu_zalno lv_subrc ls_enq-guname.
          EXIT.
        ELSE.
          CALL FUNCTION 'ENQUEUE_EZGDMMT004Z'
            EXPORTING
              zalno          = fu_zalno
              submi          = fu_submi
            EXCEPTIONS
              foreign_lock   = 1
              system_failure = 2
              OTHERS         = 3.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_LOCK_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ATTACHMENT_NEW
*&---------------------------------------------------------------------*
FORM f_display_attachment_new  USING    fu_row fu_column fu_getoff.
  DATA : ls_out    LIKE LINE OF gt_out,
         ls_04z    LIKE LINE OF gt_04z,
         lt_form01 TYPE STANDARD TABLE OF itcoo,
         lt_form02 TYPE STANDARD TABLE OF itcoo,
         lt_form03 TYPE STANDARD TABLE OF itcoo,
         lt_form04 TYPE STANDARD TABLE OF itcoo.

  DATA : lt_otf     TYPE TABLE OF itcoo,
         lv_objlen  TYPE sood-objlen,
         lv_xstring TYPE xstring,
         lt_lines   TYPE TABLE OF tline,
         lt_objbin  TYPE TABLE OF solix.

  READ TABLE gt_out INTO ls_out INDEX fu_row.
  IF sy-subrc = 0.
    READ TABLE gt_04z INTO ls_04z
                      WITH KEY zalno = ls_out-zalno
                               submi = ls_out-submi.
    IF sy-subrc = 0.
      CALL FUNCTION 'ZHSMMM_FM002'
        EXPORTING
          pi_submi            = ls_04z-submi
          pi_zalno            = ls_04z-zalno
          pi_prgrp            = ls_04z-prgrp
          pi_getoff           = fu_getoff
          pi_tdnoprev         = space
          pi_preview          = space
          pi_nodialog         = 'X'
        TABLES
          pt_form01           = lt_form01
          pt_form02           = lt_form02
          pt_form03           = lt_form03
          pt_form04           = lt_form04
        EXCEPTIONS
          product_group_error = 1
          OTHERS              = 2.
    ENDIF.

    IF lt_form01[] IS NOT INITIAL.
      lt_otf[] = lt_form01[].
    ELSEIF lt_form02[] IS NOT INITIAL.
      lt_otf[] = lt_form02[].
    ELSEIF lt_form03[] IS NOT INITIAL.
      lt_otf[] = lt_form03[].
    ELSEIF lt_form04[] IS NOT INITIAL.
      lt_otf[] = lt_form04[].
    ENDIF.

    IF lt_otf[] IS NOT INITIAL.
      CALL FUNCTION 'CONVERT_OTF'
        EXPORTING
          format                = 'PDF'
          max_linewidth         = 132
        IMPORTING
          bin_filesize          = lv_objlen
          bin_file              = lv_xstring
        TABLES
          otf                   = lt_otf
          lines                 = lt_lines
        EXCEPTIONS
          err_max_linewidth     = 1
          err_format            = 2
          err_conv_not_possible = 3
          OTHERS                = 4.

      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          buffer     = lv_xstring
        TABLES
          binary_tab = gt_objbin[].

      PERFORM f_download_to_local USING ls_04z-zalno ls_04z-submi ls_04z-vrsio.

*      CALL SCREEN 102.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DISPLAY_ATTACHMENT_NEW

*&---------------------------------------------------------------------*
*&      Form  F_GET_NETPR_FROM_PIR
*&---------------------------------------------------------------------*
FORM f_get_netpr_from_pir  USING    fu_lifnr fu_ebeln fu_matnr
                           CHANGING fc_netpr.
  DATA : ls_eine  LIKE LINE OF gt_eine,
         ls_eina  LIKE LINE OF gt_eina,
         ls_xekpo LIKE LINE OF gt_xekpo,
         lv_netpr TYPE eine-netpr,
         lv_matnr TYPE mara-matnr.

  CLEAR ls_xekpo.
  READ TABLE gt_xekpo INTO ls_xekpo
                      WITH KEY ebeln = fu_ebeln
                               matnr = fu_matnr.
  IF ls_xekpo-idnlf IS INITIAL.
    lv_matnr = fu_matnr.
  ELSE.
    lv_matnr = ls_xekpo-idnlf.
  ENDIF.

  CLEAR ls_eina.
  READ TABLE gt_eina INTO ls_eina
                     WITH KEY lifnr = fu_lifnr
                              matnr = lv_matnr.
  IF sy-subrc = 0.
    CLEAR ls_eine.
    READ TABLE gt_eine INTO ls_eine
                       WITH KEY infnr = ls_eina-infnr.
    IF sy-subrc = 0.
      lv_netpr = ls_eine-netpr / ls_eine-peinh.
      IF ls_eine-waers <> 'IDR'.
        CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
          EXPORTING
            date             = sy-datum
            foreign_amount   = lv_netpr
            foreign_currency = ls_eine-waers
            local_currency   = 'IDR'
          IMPORTING
            local_amount     = fc_netpr.
      ELSE.
        fc_netpr = lv_netpr.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_NETPR_FROM_PIR

*&---------------------------------------------------------------------*
*&      Form  F_PBO
*&---------------------------------------------------------------------*
FORM f_pbo .
  DATA : lv_url(255),
         lt_data            TYPE STANDARD TABLE OF x255.

  CREATE OBJECT g_html_container
    EXPORTING
      container_name = 'CC_PDF'.

  CREATE OBJECT g_html_control
    EXPORTING
      parent = g_html_container.

  CALL METHOD g_html_control->load_data
    EXPORTING
      type                   = 'applictaion'
      subtype                = 'pdf'
    IMPORTING
      assigned_url           = lv_url
    CHANGING
      data_table             = gt_objbin
    EXCEPTIONS
      dp_invalid_parameter   = 1
      dp_error_general       = 2
      cntl_error             = 3
      html_syntax_notcorrect = 4
      OTHERS                 = 5.

  CALL METHOD g_html_control->show_url
    EXPORTING
      url                    = lv_url
      in_place               = 'X'
    EXCEPTIONS
      cntl_error             = 1
      cnht_error_not_allowed = 2
      cnht_error_parameter   = 3
      dp_error_general       = 4
      OTHERS                 = 5.
ENDFORM.                    " F_PBO

*&---------------------------------------------------------------------*
*&      Form  F_FREE_PDF_TEMP
*&---------------------------------------------------------------------*
FORM f_free_pdf_temp .
  DATA : path         TYPE string,
         ftab(200)    TYPE c OCCURS 0,
         ls_tab       LIKE LINE OF ftab,
         i            TYPE i,
         lv_filename  TYPE string,
         lv_extension TYPE string,
         rc           TYPE i.

  CALL METHOD cl_gui_frontend_services=>get_sapgui_workdir
    CHANGING
      sapworkdir            = path
    EXCEPTIONS
      get_sapworkdir_failed = 1
      cntl_error            = 2
      error_no_gui          = 3
      not_supported_by_gui  = 4
      OTHERS                = 5.

  CALL METHOD cl_gui_frontend_services=>directory_list_files
    EXPORTING
      directory                   = path
      filter                      = '*.*'
    CHANGING
      file_table                  = ftab
      count                       = i
    EXCEPTIONS
      cntl_error                  = 1
      directory_list_files_failed = 2
      wrong_parameter             = 3
      error_no_gui                = 4
      OTHERS                      = 5.

  LOOP AT ftab INTO ls_tab.
    SPLIT ls_tab AT '.' INTO lv_filename lv_extension.
    TRANSLATE lv_extension TO UPPER CASE.
    IF lv_extension = 'PDF'.
      lv_filename = ls_tab.
      CONCATENATE path '\' lv_filename INTO lv_filename.
      CALL METHOD cl_gui_frontend_services=>file_delete
        EXPORTING
          filename             = lv_filename
        CHANGING
          rc                   = rc
        EXCEPTIONS
          file_delete_failed   = 1
          cntl_error           = 2
          error_no_gui         = 3
          file_not_found       = 4
          access_denied        = 5
          unknown_error        = 6
          not_supported_by_gui = 7
          wrong_parameter      = 8.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_FREE_PDF_TEMP

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_TO_LOCAL
*&---------------------------------------------------------------------*
FORM f_download_to_local  USING    fu_zalno fu_submi fu_vrsio.
  DATA : directory   TYPE string,
         lv_filename TYPE string,
         document    TYPE string.

  CONCATENATE fu_zalno fu_submi fu_vrsio '.pdf' INTO lv_filename.

  CALL METHOD cl_gui_frontend_services=>get_sapgui_workdir
    CHANGING
      sapworkdir            = directory
    EXCEPTIONS
      get_sapworkdir_failed = 1
      cntl_error            = 2
      error_no_gui          = 3
      not_supported_by_gui  = 4
      OTHERS                = 5.

  IF sy-subrc = 0.
    CONCATENATE directory '\' lv_filename INTO document.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = document
        filetype                = 'BIN'
      CHANGING
        data_tab                = gt_objbin
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.

    IF sy-subrc = 0.
      CALL METHOD cl_gui_frontend_services=>execute
        EXPORTING
          document               = document
        EXCEPTIONS
          cntl_error             = 1
          error_no_gui           = 2
          bad_parameter          = 3
          file_not_found         = 4
          path_not_found         = 5
          file_extension_unknown = 6
          error_execute_failed   = 7
          synchronous_failed     = 8
          not_supported_by_gui   = 9
          OTHERS                 = 10.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DOWNLOAD_TO_LOCAL

*&---------------------------------------------------------------------*
*&      Form  F_GET_PIR_MPN
*&---------------------------------------------------------------------*
FORM f_get_pir_mpn .
  DATA : lt_x04x      TYPE STANDARD TABLE OF zgdmmt004x.

  lt_x04x[] = gt_04x[].
  SORT lt_x04x BY ebeln.
  DELETE ADJACENT DUPLICATES FROM lt_x04x COMPARING ebeln.
  IF lt_x04x[] IS NOT INITIAL.
    SELECT *
      FROM ekpo
      INTO CORRESPONDING FIELDS OF TABLE gt_xekpo
      FOR ALL ENTRIES IN lt_x04x
      WHERE ebeln = lt_x04x-ebeln.
  ENDIF.
ENDFORM.                    " F_GET_PIR_MPN

*&---------------------------------------------------------------------*
*&      Form  F_MERGE_DATA
*&---------------------------------------------------------------------*
FORM f_merge_data .
  TYPES : BEGIN OF ty_merge,
            zalno TYPE zgdmmt004z-zalno,
            zaldt TYPE zgdmmt004z-zaldt,
          END OF ty_merge.

  DATA : lt_xout     TYPE STANDARD TABLE OF ty_out,
         lt_celltab  TYPE lvc_t_styl WITH HEADER LINE,
         ls_out      LIKE LINE OF gt_out,
         ls_xout     LIKE LINE OF lt_xout,
         ls_04z      LIKE LINE OF gt_04z,
         lt_merge    TYPE STANDARD TABLE OF ty_merge,
         ls_merge    LIKE LINE OF lt_merge,
         es_selfield TYPE slis_selfield.

  DATA : lv_merno         TYPE zgdmmt004z-merno.

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE mark IS INITIAL.
  LOOP AT lt_xout INTO ls_xout.
    ls_merge-zalno  = ls_xout-zalno.
    CLEAR ls_04z.
    READ TABLE gt_04z INTO ls_04z
                      WITH KEY zalno = ls_xout-zalno.
    IF sy-subrc = 0.
      ls_merge-zaldt    = ls_04z-zaldt.
    ENDIF.
    APPEND ls_merge TO lt_merge.
    CLEAR ls_merge.
  ENDLOOP.

  IF lt_merge[] IS NOT INITIAL.
    CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
      EXPORTING
        i_title               = 'Merge Alokasi No.'
        i_selection           = 'X'
*       i_allow_no_selection  = 'X'
        i_zebra               = 'X'
        i_screen_start_column = 1
        i_screen_start_line   = 1
        i_screen_end_column   = 30
        i_screen_end_line     = 30
        i_tabname             = 'GT_MERGE'
        it_fieldcat           = gt_merge_fieldcat[]
      IMPORTING
        es_selfield           = es_selfield
      TABLES
        t_outtab              = lt_merge
      EXCEPTIONS
        program_error         = 1
        OTHERS                = 2.
    IF sy-subrc = 0.
      CLEAR : ls_merge, lv_merno.
      READ TABLE lt_merge INTO ls_merge
                          INDEX es_selfield-tabindex.
      IF sy-subrc = 0.
        lv_merno  = ls_merge-zalno.
      ENDIF.

      IF lv_merno IS NOT INITIAL.
        LOOP AT lt_xout INTO ls_xout.
          TRY .
              UPDATE zgdmmt004z SET merno   = lv_merno
                                WHERE zalno = ls_xout-zalno.
            CATCH cx_sy_open_sql_db.
          ENDTRY.

          CLEAR : lt_celltab[].
          lt_celltab-style     = cl_gui_alv_grid=>mc_style_disabled.
          lt_celltab-fieldname = 'MARK'.
          APPEND lt_celltab.
          INSERT LINES OF lt_celltab INTO TABLE ls_out-style.
          CLEAR : ls_out-mark.

          MODIFY gt_out FROM ls_out
                        TRANSPORTING mark style
                        WHERE zalno = ls_xout-zalno.
          CLEAR ls_out.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM f_alv_refresh USING 'X'.
  MESSAGE s000(zab) WITH 'Data already merged'.
ENDFORM.                    " F_MERGE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_UNMERGE_DATA
*&---------------------------------------------------------------------*
FORM f_unmerge_data .
  DATA : lt_xout    TYPE STANDARD TABLE OF ty_out,
         ls_xout    LIKE LINE OF lt_xout,
         lt_x04z    TYPE STANDARD TABLE OF zgdmmt004z,
         ls_x04z    LIKE LINE OF lt_x04z,
         ls_04z     LIKE LINE OF gt_04z,
         lt_celltab TYPE lvc_t_styl WITH HEADER LINE,
         ls_out     LIKE LINE OF gt_out.

  lt_x04z[] = gt_04z[].
  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE mark IS INITIAL.
  LOOP AT lt_xout INTO ls_xout.
    CLEAR ls_x04z.
    READ TABLE lt_x04z INTO ls_x04z
                       WITH KEY zalno = ls_xout-zalno.
    IF sy-subrc = 0.
      LOOP AT gt_04z INTO ls_04z WHERE merno = ls_x04z-merno.
        TRY .
            UPDATE zgdmmt004z SET merno   = space
                              WHERE zalno = ls_04z-zalno.
          CATCH cx_sy_open_sql_db.
        ENDTRY.

        CLEAR : lt_celltab[].
        lt_celltab-style     = cl_gui_alv_grid=>mc_style_disabled.
        lt_celltab-fieldname = 'MARK'.
        APPEND lt_celltab.
        INSERT LINES OF lt_celltab INTO TABLE ls_out-style.
        CLEAR : ls_out-mark.

        MODIFY gt_out FROM ls_out
                      TRANSPORTING mark style
                      WHERE zalno = ls_04z-zalno.
        CLEAR ls_out.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  PERFORM f_alv_refresh USING 'X'.
  MESSAGE s000(zab) WITH 'Data already unmerged'.
ENDFORM.                    " F_UNMERGE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CONFIRMATION
*&---------------------------------------------------------------------*
FORM f_confirmation  USING    fu_text
                     CHANGING fc_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = 'Confirmation'
      text_question  = fu_text
    IMPORTING
      answer         = fc_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
ENDFORM.                    " F_CONFIRMATION

*&---------------------------------------------------------------------*
*&      Form  F_MERGE_ALOKASI
*&---------------------------------------------------------------------*
FORM f_merge_alokasi  USING    fu_zalno
                      CHANGING fc_nomerge.
  TYPES : BEGIN OF ty_04z,
            zalno    TYPE zgdmmt004z-zalno,
            submi    TYPE zgdmmt004z-submi,
            zaldt    TYPE zgdmmt004z-zaldt,
            procstat TYPE zgdmmt004z-procstat,
            merno    TYPE zgdmmt004z-merno,
          END OF ty_04z.

  DATA : ls_04z      LIKE LINE OF gt_04z,
         ls_createpo LIKE LINE OF gt_createpo,
         lt_x04z     TYPE STANDARD TABLE OF ty_04z,
         ls_x04z     LIKE LINE OF lt_x04z.

  DATA : lv_subrc       TYPE sy-subrc.

  CLEAR : gt_createpo[], fc_nomerge.

  READ TABLE gt_04z INTO ls_04z
                    WITH KEY zalno  = fu_zalno.
  IF sy-subrc = 0.
    IF ls_04z-merno IS INITIAL.
      ls_createpo-zalno = fu_zalno.
      fc_nomerge  = 'X'.
    ELSE.
      SELECT zalno submi zaldt procstat merno
        FROM zgdmmt004z
        INTO TABLE lt_x04z
        WHERE merno = ls_04z-merno.

      LOOP AT lt_x04z INTO ls_x04z.
        ls_createpo-zalno = fu_zalno.
        ls_createpo-merno = ls_x04z-merno.
        IF ls_x04z-procstat = '05'.
          APPEND ls_createpo TO gt_createpo.
        ELSE.
          lv_subrc = 4.
        ENDIF.
      ENDLOOP.

      IF lv_subrc <> 0.
        CLEAR gt_createpo[].
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MERGE_ALOKASI

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_PO_MERGE
*&---------------------------------------------------------------------*
FORM f_create_po_merge .
  DATA : lt_xpo     TYPE STANDARD TABLE OF zgdmmt004z,
         lt_04x     TYPE STANDARD TABLE OF zgdmmt004x,
         lt_04p     TYPE STANDARD TABLE OF zgdmmt004p,
         lt_04z     TYPE STANDARD TABLE OF zgdmmt004z,
         lt_04y     TYPE STANDARD TABLE OF zgdmmt004y,
         lt_x04x    TYPE STANDARD TABLE OF zgdmmt004x,
         lt_x04z    TYPE STANDARD TABLE OF zgdmmt004z,
         lt_lfm1    TYPE STANDARD TABLE OF lfm1,
         lt_ekpo    TYPE STANDARD TABLE OF ekpo,
         lt_qinf    TYPE STANDARD TABLE OF qinf,
         lt_po      TYPE STANDARD TABLE OF zgdmmt004z,
         lt_ypo     TYPE STANDARD TABLE OF zgdmmt004z,
         ls_xpo     LIKE LINE OF lt_xpo,
         ls_ypo     LIKE LINE OF lt_ypo,
         ls_x04z    LIKE LINE OF lt_x04z,
         ls_po      LIKE LINE OF lt_po,
         ls_poemail LIKE LINE OF gt_poemail.

  DATA : lr_matnr TYPE RANGE OF matnr,
         ls_matnr LIKE LINE OF lr_matnr.

  DATA : lv_ebeln         TYPE ekko-ebeln.

  lt_xpo[] = gt_createpo[].
  SORT lt_xpo BY merno.
  DELETE ADJACENT DUPLICATES FROM lt_xpo COMPARING merno.
  IF lt_xpo[] IS NOT INITIAL.
    SELECT *
      FROM zgdmmt004z
      INTO CORRESPONDING FIELDS OF TABLE lt_04z
      FOR ALL ENTRIES IN lt_xpo
      WHERE merno = lt_xpo-merno.

    lt_x04z[] = lt_04z[].
    SORT lt_x04z BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_x04z COMPARING matnr.
    LOOP AT lt_x04z INTO ls_x04z.
      CONCATENATE ls_x04z-matnr '*' INTO ls_x04z-matnr.
      ls_matnr-low    = ls_x04z-matnr.
      ls_matnr-sign   = 'I'.
      ls_matnr-option = 'CP'.
      APPEND ls_matnr TO lr_matnr.
      CLEAR ls_matnr.
    ENDLOOP.

    IF lt_04z[] IS NOT INITIAL.
      SELECT *
        FROM zgdmmt004x
        INTO CORRESPONDING FIELDS OF TABLE lt_04x
        FOR ALL ENTRIES IN lt_04z
        WHERE zalno = lt_04z-zalno.

      lt_x04x[] = lt_04x[].
      SORT lt_x04x BY lifnr.
      DELETE ADJACENT DUPLICATES FROM lt_x04x COMPARING lifnr.
      IF lt_x04x[] IS NOT INITIAL.
        SELECT *
          FROM lfm1
          INTO CORRESPONDING FIELDS OF TABLE lt_lfm1
          FOR ALL ENTRIES IN lt_x04x
          WHERE lifnr = lt_x04x-lifnr
            AND ekorg = 'TNT'.

        SELECT *
          FROM qinf
          INTO CORRESPONDING FIELDS OF TABLE gt_qinf
          FOR ALL ENTRIES IN lt_x04x
          WHERE lieferant = lt_x04x-lifnr
            AND matnr     IN lr_matnr
            AND frei_dat  > sy-datum.
      ENDIF.

      lt_x04x[] = lt_04x[].
      SORT lt_x04x BY ebeln.
      DELETE ADJACENT DUPLICATES FROM lt_x04x COMPARING ebeln.
      IF lt_x04x[] IS NOT INITIAL.
        SELECT *
          FROM ekpo
          INTO CORRESPONDING FIELDS OF TABLE lt_ekpo
          FOR ALL ENTRIES IN lt_x04x
          WHERE ebeln = lt_x04x-ebeln.
      ENDIF.

      SELECT *
        FROM zgdmmt004y
        INTO CORRESPONDING FIELDS OF TABLE lt_04y
        FOR ALL ENTRIES IN lt_04z
        WHERE zalno = lt_04z-zalno
          AND bsmng <> 0.

      SELECT *
        FROM zgdmmt004p
        INTO CORRESPONDING FIELDS OF TABLE lt_04p
        FOR ALL ENTRIES IN lt_04z
        WHERE zalno = lt_04z-zalno
          AND menge <> 0.
    ENDIF.

    LOOP AT lt_xpo INTO ls_xpo.
      CALL FUNCTION 'ZHSMMM_FM003'
        EXPORTING
          pi_ekorg   = gv_ekorg
          pi_merno   = ls_xpo-merno
        IMPORTING
          pe_ebeln   = lv_ebeln
        TABLES
          pt_04p     = lt_04p
          pt_04x     = lt_04x
          pt_04y     = lt_04y
          pt_04z     = lt_04z
          pt_lfm1    = lt_lfm1
          pt_ekpo    = lt_ekpo
          pt_qinf    = lt_qinf
          pt_poemail = lt_po.

      lt_ypo[] = lt_po[].
      SORT lt_ypo BY ernam ekgrp.
      DELETE ADJACENT DUPLICATES FROM lt_ypo COMPARING ernam ekgrp.
      LOOP AT lt_ypo INTO ls_ypo.
        LOOP AT lt_po INTO ls_po WHERE ernam = ls_ypo-ernam
                                   AND ekgrp = ls_ypo-ekgrp.
          ls_poemail-ebeln   = ls_po-ebeln.
          ls_poemail-zalno   = ls_po-zalno.
          ls_poemail-ernam   = ls_po-ernam.
          COLLECT ls_poemail INTO gt_poemail.
          CLEAR ls_poemail.
        ENDLOOP.
        IF gt_poemail[] IS NOT INITIAL.
          PERFORM f_send_email USING '' '' '' '' ls_ypo-ernam
                                     ls_ypo-ekgrp.
        ENDIF.
        CLEAR : gt_poemail[].
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_CREATE_PO_MERGE

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FPKH
*&---------------------------------------------------------------------*
FORM f_print_fpkh  USING    fu_row fu_column.
  DATA : ls_out      LIKE LINE OF gt_out,
         ls_04z      LIKE LINE OF gt_04z,
         lv_time(10), lv_date(10),
         document    TYPE string.

  READ TABLE gt_out INTO ls_out INDEX fu_row.
  IF sy-subrc = 0.
    READ TABLE gt_04z INTO ls_04z
                      WITH KEY zalno = ls_out-zalno
                               submi = ls_out-submi.
    IF sy-subrc = 0.
      lv_time = sy-uzeit.
      lv_date = sy-datum.
      CONDENSE: lv_time, lv_date.
      CONCATENATE ls_04z-url '?V=' lv_date lv_time INTO ls_04z-url.
      document = ls_04z-url.

      CALL METHOD cl_gui_frontend_services=>execute
        EXPORTING
          document               = document
        EXCEPTIONS
          cntl_error             = 1
          error_no_gui           = 2
          bad_parameter          = 3
          file_not_found         = 4
          path_not_found         = 5
          file_extension_unknown = 6
          error_execute_failed   = 7
          synchronous_failed     = 8
          not_supported_by_gui   = 9
          OTHERS                 = 10.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PRINT_FPKH
*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FPKH
*&---------------------------------------------------------------------*
FORM f_print_lamp  USING    fu_row fu_column.
  DATA : ls_out      LIKE LINE OF gt_out,
         ls_04z      LIKE LINE OF gt_04z,
         lv_time(10), lv_date(10),
         ls_08       LIKE LINE OF gt_08,
         document    TYPE string.

  READ TABLE gt_out INTO ls_out INDEX fu_row.
  IF sy-subrc = 0.
    READ TABLE gt_04z INTO ls_04z
                      WITH KEY zalno = ls_out-zalno
                               submi = ls_out-submi.
    IF sy-subrc = 0 AND ls_04z-lampiran IS NOT INITIAL.

      SORT gt_08 BY uname.
      READ TABLE gt_08 INTO ls_08 WITH KEY uname = sy-uname BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_time = sy-uzeit.
        lv_date = sy-datum.
        CONDENSE: lv_time, lv_date.
        CONCATENATE ls_04z-lampiran '?V=' lv_date lv_time INTO ls_04z-url.
        document = ls_04z-lampiran.
        CALL METHOD cl_gui_frontend_services=>execute
          EXPORTING
            document               = document
          EXCEPTIONS
            cntl_error             = 1
            error_no_gui           = 2
            bad_parameter          = 3
            file_not_found         = 4
            path_not_found         = 5
            file_extension_unknown = 6
            error_execute_failed   = 7
            synchronous_failed     = 8
            not_supported_by_gui   = 9
            OTHERS                 = 10.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PRINT_FPKH

*&---------------------------------------------------------------------*
*&      Form  F_GET_SRNO
*&---------------------------------------------------------------------*
FORM f_get_srno  USING    fu_ucomm fu_srno1
                 CHANGING fc_srno1.
  IF fu_ucomm = '&APPR'.
    CASE 'X'.
      WHEN radio1.
        fc_srno1 = fu_srno1 + 1.
      WHEN radio2.
        fc_srno1 = fu_srno1 - 1.
    ENDCASE.
  ELSEIF fu_ucomm = '&RJCT'.
    fc_srno1 = fu_srno1 - 1.
  ENDIF.
ENDFORM.
