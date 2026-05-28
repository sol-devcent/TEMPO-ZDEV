*----------------------------------------------------------------------*
*   INCLUDE ZM_PURCH_GRPF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.

ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.

  CASE 'X'.
    WHEN pa_cret.
      SELECT ekorg ekgrp zhier zlvl zdesc zdesc1
        FROM zmmattnt
        INTO CORRESPONDING FIELDS OF TABLE gt_temp
        WHERE ekorg EQ pa_ekorg
          AND ekgrp EQ pa_ekgrp.

      DO 1000 TIMES.
        gt_zmmattnt-ekorg = pa_ekorg.
        gt_zmmattnt-ekgrp = pa_ekgrp.
        APPEND gt_zmmattnt.
      ENDDO.

      CALL SCREEN 500.

    WHEN pa_chng.
      SELECT ekorg ekgrp zhier zlvl zdesc zdesc1
        FROM zmmattnt
        INTO CORRESPONDING FIELDS OF TABLE gt_temp
        WHERE ekorg EQ pa_ekorg
          AND ekgrp EQ pa_ekgrp.

      SELECT ekorg ekgrp zhier zlvl zdesc zdesc1
        FROM zmmattnt
        INTO CORRESPONDING FIELDS OF TABLE gt_zmmattnt
        WHERE ekorg EQ pa_ekorg
          AND ekgrp EQ pa_ekgrp
          AND zhier IN so_zhier
          AND zlvl  IN so_zlvl.

      CALL SCREEN 500.

    WHEN pa_disp.
      SELECT ekorg ekgrp zhier zlvl zdesc zdesc1
        FROM zmmattnt
        INTO CORRESPONDING FIELDS OF TABLE gt_out
        WHERE ekorg EQ pa_ekorg
          AND ekgrp EQ pa_ekgrp
          AND zhier IN so_zhier.

    WHEN pa_copy.
      CALL SELECTION-SCREEN 9000.

      SELECT *
        FROM zmmattnt
        INTO CORRESPONDING FIELDS OF TABLE gt_fr
        WHERE ekorg EQ pa_freko
          AND ekgrp EQ pa_frekg.

      SELECT *
        FROM zmmattnt
        INTO CORRESPONDING FIELDS OF TABLE gt_to
        WHERE ekorg EQ pa_toeko
          AND ekgrp EQ pa_toekg.
  ENDCASE.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  PERFORM f_alv TABLES gt_out1.
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
*  PERFORM f_fieldcatg USING ft_report:
*    'ZHIER' 'ZMMATTNT' 'ZHIER' '' '' '' '' '' '' '' '' '' '' '' '' '',
*    'ZLVL' 'ZMMATTNT' 'ZLVL' '' '' '' '' '' '' '' '' '' '' '' '' '',
*    'ZDESC' 'ZMMATTNT' 'ZDESC' '' '' '' '' '' '' '' '' '' '' '' '' ''.
  PERFORM f_fieldcatg USING ft_report:
  'ZTEXT01' '' '' '' '50' 'Level 1' '' '' '' '' '' '' '' ''
  '' '',
  'ZTEXT02' '' '' '' '50' 'Level 2' '' '' '' '' '' '' '' ''
  '' '',
  'ZTEXT03' '' '' '' '50' 'Level 3' '' '' '' '' '' '' '' ''
  '' '',
  'ZTEXT04' '' '' '' '50' 'Level 4' '' '' '' '' '' '' '' ''
  '' '',
  'ZTEXT05' '' '' '' '50' 'Level 5' '' '' '' '' '' '' '' ''
   '' '',
  'ZDESC1' '' '' '' '50' 'Description' '' '' '' '' '' '' '' ''
   '' ''.
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
FORM f_fieldcatg USING    value(fu_types)
                          value(fu_fname)
                          value(fu_reftb)
                          value(fu_refld)
                          value(fu_noout)
                          value(fu_outln)
                          value(fu_fltxt)
                          value(fu_dosum)
                          value(fu_hotsp)
                          value(fu_dec)
                          value(fu_waers)
                          value(fu_meins)
                          value(fu_waers_f)
                          value(fu_meins_f)
                          value(fu_checkbox)
                          value(fu_input)
                          value(fu_emphasize).

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
*  ld_sort-fieldname = 'ZHIER'.
*  ld_sort-up        = 'X'.
*  APPEND ld_sort TO fu_sort.
*  CLEAR ld_sort.
*  ld_sort-fieldname = 'ZLVL'.
*  ld_sort-up        = 'X'.
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
  CLEAR: gt_out, gt_out[].
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
  SET PF-STATUS 'STANDARD'.
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
  DATA : wa_out LIKE LINE OF gt_out1,
         lt_out LIKE gt_out OCCURS 0 WITH HEADER LINE.

  lt_out[]  = gt_out[].

  CASE 'X'.
    WHEN pa_disp.
      SORT gt_out BY zhier zlvl.
      LOOP AT gt_out WHERE zlvl EQ '5'.
        PERFORM f_horizontal TABLES lt_out
                             USING gt_out-zhier(2)
                             CHANGING gt_out1-zhier01 gt_out1-zdesc01
                                      gt_out1-ztext01.
        PERFORM f_horizontal TABLES lt_out
                             USING gt_out-zhier(4)
                             CHANGING gt_out1-zhier02 gt_out1-zdesc02
                                      gt_out1-ztext02.
        PERFORM f_horizontal TABLES lt_out
                             USING gt_out-zhier(7)
                             CHANGING gt_out1-zhier03 gt_out1-zdesc03
                                      gt_out1-ztext03.
        PERFORM f_horizontal TABLES lt_out
                             USING gt_out-zhier(11)
                             CHANGING gt_out1-zhier04 gt_out1-zdesc04
                                      gt_out1-ztext04.
        gt_out1-zhier05 = gt_out-zhier.
        gt_out1-zdesc05 = gt_out-zdesc.
        CONCATENATE gt_out1-zhier05 '-' gt_out1-zdesc05
          INTO gt_out1-ztext05
          SEPARATED BY space.
        gt_out1-zdesc1  = gt_out-zdesc1.
        APPEND gt_out1.
      ENDLOOP.

    WHEN pa_copy.
      PERFORM f_delete_data.
      PERFORM f_insert_data.

  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries.

ENDFORM.                    " F_POST_ENTRIES

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
*&      Form  F_GET_PARAMETERS
*&---------------------------------------------------------------------*
FORM f_get_parameters  USING    fu_value
                       CHANGING fc_value.
  CALL FUNCTION 'ACC_USER_PARAMETER_GET'
    EXPORTING
      i_param_id    = fu_value
    IMPORTING
      e_param_value = fc_value.
ENDFORM.                    " F_GET_PARAMETERS

*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0500 OUTPUT.
  CASE 'X'.
    WHEN pa_cret.
      SET PF-STATUS 'STATUS100'.
      SET TITLEBAR 'TITLE100'.
    WHEN pa_chng.
      SET PF-STATUS 'STATUS101'.
      SET TITLEBAR 'TITLE101'.
  ENDCASE.
  DESCRIBE TABLE gt_zmmattnt LINES fill.
  tc_zmmattnt-lines = fill.
ENDMODULE.                 " STATUS_0500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_table_control OUTPUT.
  READ TABLE gt_zmmattnt INDEX tc_zmmattnt-current_line.

  CASE 'X'.
    WHEN pa_cret.
      IF gt_zmmattnt-zlvl IS NOT INITIAL.
        LOOP AT SCREEN.
          IF screen-name EQ 'GT_ZMMATTNT-ZHIER'.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.

    WHEN pa_chng.
      LOOP AT SCREEN.
        IF screen-name EQ 'GT_ZMMATTNT-ZHIER'.
          screen-input  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.
ENDMODULE.                 " FILL_TABLE_CONTROL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL  INPUT
*&---------------------------------------------------------------------*
MODULE read_table_control INPUT.
  DATA : answer.

  lines = sy-loopc.

  ok_code = sy-ucomm.

  CASE 'X'.
    WHEN pa_cret.
      CASE ok_code.
        WHEN 'CANC'.
          CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
            EXPORTING
              textline1      = 'Your changes will be lost'
              textline2      = 'Cancel?'
              titel          = 'Cancel Maintenance'
              cancel_display = space
            IMPORTING
              answer         = answer.
        WHEN OTHERS.
          PERFORM f_validate_data_cret.
          MODIFY gt_zmmattnt INDEX tc_zmmattnt-current_line.
      ENDCASE.
    WHEN pa_chng.
      MODIFY gt_zmmattnt INDEX tc_zmmattnt-current_line.
*      PERFORM f_validate_data_chng.
  ENDCASE.
ENDMODULE.                 " READ_TABLE_CONTROL  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA_CRET
*&---------------------------------------------------------------------*
FORM f_validate_data_cret .
  DATA : lv_length  TYPE int4,
         lv_error   TYPE sy-subrc.

  IF gt_zmmattnt-ekorg NE pa_ekorg.
    lv_error  = '3'.
  ENDIF.

  IF lv_error IS INITIAL.
    IF gt_zmmattnt-ekgrp NE pa_ekgrp.
      lv_error  = '4'.
    ENDIF.
  ENDIF.

  IF lv_error IS INITIAL.
    lv_length = STRLEN( gt_zmmattnt-zhier ).

    CASE lv_length.
      WHEN 2.
        PERFORM f_level_validate USING gt_zmmattnt-zhier '' '1'
                                 CHANGING gt_zmmattnt-zlvl lv_error.

      WHEN 4.
        PERFORM f_level_validate USING gt_zmmattnt-zhier gt_zmmattnt-zhier(2)
                                       '2'
                                 CHANGING gt_zmmattnt-zlvl lv_error.

      WHEN 7.
        PERFORM f_level_validate USING gt_zmmattnt-zhier gt_zmmattnt-zhier(4)
                                       '3'
                                 CHANGING gt_zmmattnt-zlvl lv_error.
      WHEN 11.
        PERFORM f_level_validate USING gt_zmmattnt-zhier gt_zmmattnt-zhier(7)
                                       '4'
                                 CHANGING gt_zmmattnt-zlvl lv_error.
      WHEN 15.
        PERFORM f_level_validate USING gt_zmmattnt-zhier gt_zmmattnt-zhier(11)
                                       '5'
                                 CHANGING gt_zmmattnt-zlvl lv_error.
      WHEN OTHERS.
        SET PF-STATUS 'STATUS102'.
        MESSAGE 'Error in hierarchy code' TYPE 'E'.
    ENDCASE.
  ENDIF.

  IF lv_error IS INITIAL.
    IF gt_zmmattnt-zhier IS NOT INITIAL.
      IF gt_zmmattnt-zdesc IS INITIAL.
        lv_error  = '5'.
      ENDIF.
    ENDIF.
  ENDIF.

  CASE lv_error.
    WHEN '0'.
      APPEND gt_zmmattnt TO gt_temp.
    WHEN '1'.
      SET PF-STATUS 'STATUS102'.
      MESSAGE 'An entry already exists with the same key' TYPE 'E'.
    WHEN '2'.
      SET PF-STATUS 'STATUS102'.
      MESSAGE 'Please create the preceding node first' TYPE 'E'.
    WHEN '3'.
      SET PF-STATUS 'STATUS102'.
      MESSAGE 'Error in Purch.Org.' TYPE 'E'.
    WHEN '4'.
      SET PF-STATUS 'STATUS102'.
      MESSAGE 'Error in Purch. Grp' TYPE 'E'.
    WHEN '5'.
      SET PF-STATUS 'STATUS102'.
      MESSAGE 'Description must be filled' TYPE 'E'.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_DATA_CRET

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0500 INPUT.

  ok_code = sy-ucomm.

  CASE ok_code.
    WHEN 'BACK' OR 'EXIT'.
      LEAVE TO SCREEN 0.

    WHEN 'SAVE'.
      PERFORM f_save_data.
      MESSAGE s000(zab) WITH 'Data already saved'.
      LEAVE TO SCREEN 0.

    WHEN '&DEL'.
      PERFORM f_code_delete_row USING 'TC_ZMMATTNT'
                                      'GT_ZMMATTNT'
                                      'MARK' 'ZHIER' 'ZLVL'.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0500  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_CODE_DELETE_ROW
*&---------------------------------------------------------------------*
FORM f_code_delete_row  USING    fu_tc_name  TYPE dynfnam
                                 fu_table_name
                                 fu_mark fu_zhier fu_zlvl.

  DATA : lv_zhier   TYPE zhier,
         lv_zlvl    TYPE zlvltnt,
         lv_error   TYPE sy-subrc,
         lv_tabix   TYPE sy-tabix.

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_table_name       LIKE feld-name.
  FIELD-SYMBOLS <tc>      TYPE cxtab_control.
  FIELD-SYMBOLS <table>   TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
  FIELD-SYMBOLS <zhier>.
  FIELD-SYMBOLS <zlvl>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (fu_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE fu_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* delete marked lines                                                  *
  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.
*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT fu_mark OF STRUCTURE <wa> TO <mark_field>.
    IF <mark_field> = 'X'.
      lv_tabix  = syst-tabix.
      ASSIGN COMPONENT fu_zhier OF STRUCTURE <wa> TO <zhier>.
      lv_zhier  = <zhier>.
      ASSIGN COMPONENT fu_zlvl OF STRUCTURE <wa> TO <zlvl>.
      lv_zlvl  = <zlvl>.

      PERFORM f_validate_data_chng USING lv_zhier lv_zlvl
                                   CHANGING lv_error.

      CHECK lv_error IS INITIAL.

      DELETE <table> INDEX lv_tabix.
      IF sy-subrc = 0.
        <tc>-lines = <tc>-lines - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data.

  DELETE gt_zmmattnt WHERE zhier IS INITIAL.

  CASE 'X'.
    WHEN pa_cret.
      LOOP AT gt_zmmattnt.
        gt_out-ekorg    = gt_zmmattnt-ekorg.
        gt_out-ekgrp    = gt_zmmattnt-ekgrp.
        gt_out-zhier    = gt_zmmattnt-zhier.
        gt_out-zlvl     = gt_zmmattnt-zlvl.
        gt_out-zdesc    = gt_zmmattnt-zdesc.
        APPEND gt_out.
        CLEAR gt_out.
      ENDLOOP.

      INSERT zmmattnt FROM TABLE gt_out.

      PERFORM f_modify_description.

    WHEN pa_chng.
      DELETE zmmattnt FROM TABLE gt_out.

      PERFORM f_modify_description.
  ENDCASE.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA_CHNG
*&---------------------------------------------------------------------*
FORM f_validate_data_chng USING     fu_zhier fu_zlvl
                          CHANGING  fc_error.
  CLEAR fc_error.
  CASE fu_zlvl.
    WHEN '1'.
      PERFORM f_level_validate USING fu_zhier '' '1'
                               CHANGING fu_zlvl fc_error.
    WHEN '2'.
      PERFORM f_level_validate USING fu_zhier '' '2'
                               CHANGING fu_zlvl fc_error.
    WHEN '3'.
      PERFORM f_level_validate USING fu_zhier '' '3'
                               CHANGING fu_zlvl fc_error.
    WHEN '4'.
      PERFORM f_level_validate USING fu_zhier '' '4'
                               CHANGING fu_zlvl fc_error.
    WHEN '5'.
      CLEAR fc_error.
  ENDCASE.

  CASE fc_error.
    WHEN '0'.
      gt_out-ekorg = pa_ekorg.
      gt_out-ekgrp = pa_ekgrp.
      gt_out-zhier = fu_zhier.
      APPEND gt_out.
    WHEN '1'.
      SET PF-STATUS 'STATUS102'.
      MESSAGE 'Please delete the succeeding node first' TYPE 'E'.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_DATA_CHNG

*&---------------------------------------------------------------------*
*&      Form  F_LEVEL_VALIDATE
*&---------------------------------------------------------------------*
FORM f_level_validate  USING    fu_zhier fu_zhier1 fu_zlvl
                       CHANGING fc_zlvl fc_error.

  DATA : lv_zmmattnt  LIKE gt_zmmattnt OCCURS 0 WITH HEADER LINE.

  CASE 'X'.
    WHEN pa_cret.
      IF fc_zlvl IS INITIAL.
        IF fu_zhier1 IS INITIAL.
          READ TABLE gt_temp WITH KEY zhier = fu_zhier.
          IF sy-subrc EQ 0.
            fc_error = '1'.
          ELSE.
            fc_zlvl  = fu_zlvl.
          ENDIF.
        ELSE.
          READ TABLE gt_temp WITH KEY zhier = fu_zhier.
          IF sy-subrc EQ 0.
            fc_error  = '1'.
          ELSE.
            READ TABLE gt_temp WITH KEY zhier = fu_zhier1.
            IF sy-subrc EQ 0.
              fc_zlvl  = fu_zlvl.
            ELSE.
              fc_error  = '2'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN pa_chng.
      LOOP AT gt_zmmattnt WHERE zlvl GT fu_zlvl.
        IF gt_zmmattnt-zhier CS fu_zhier.
          fc_error  = '1'.
          EXIT.
        ENDIF.
      ENDLOOP.

      CHECK fc_error IS INITIAL.

      LOOP AT gt_temp WHERE zlvl GT fu_zlvl.
        IF gt_temp-zhier CS fu_zhier.
          fc_error  = '1'.
          EXIT.
        ENDIF.
      ENDLOOP.

      CHECK fc_error IS INITIAL.

      DELETE gt_temp WHERE zhier EQ fu_zhier.
  ENDCASE.
ENDFORM.                    " F_LEVEL_VALIDATE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE 'X'.
    WHEN pa_cret.
      LOOP AT SCREEN.
        IF screen-group1 = 'HIE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'ZLV'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN pa_chng.
    WHEN pa_disp.
      LOOP AT SCREEN.
        IF screen-group1 = 'ZLV'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN pa_copy.
      LOOP AT SCREEN.
        IF screen-group1 = 'HIE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'ZLV'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'EKO'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'EKG'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  CASE 'X'.
    WHEN pa_copy.
    WHEN OTHERS.
      IF pa_ekorg IS INITIAL.
        PERFORM f_error_selection_screen USING 'EKO' '0'.
      ENDIF.
      IF pa_ekgrp IS INITIAL.
        PERFORM f_error_selection_screen USING 'EKG' '0'.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group fu_error.
  DATA: lv_mess(100).

  CASE fu_error.
    WHEN '0'.
      lv_mess = 'Fill in all required entry fields'.
  ENDCASE.

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

  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DESCRIPTION
*&---------------------------------------------------------------------*
FORM f_modify_description .
  DATA : lt_zmmattnt  LIKE zmmattnt OCCURS 0 WITH HEADER LINE,
         lt_temp      LIKE zmmattnt OCCURS 0 WITH HEADER LINE.

  SELECT ekorg ekgrp zhier zlvl zdesc
    FROM zmmattnt
    INTO CORRESPONDING FIELDS OF TABLE lt_zmmattnt
    WHERE ekorg EQ pa_ekorg
      AND ekgrp EQ pa_ekgrp.

  lt_temp[] = lt_zmmattnt[].

  LOOP AT lt_zmmattnt.
    CASE lt_zmmattnt-zlvl.
      WHEN '1'.
        lt_zmmattnt-zdesc1  = lt_zmmattnt-zdesc.
      WHEN '2'.
        PERFORM f_concatenate TABLES lt_zmmattnt
                              USING lt_zmmattnt-zhier(2) lt_zmmattnt-zdesc
                              CHANGING lt_zmmattnt-zdesc1.
      WHEN '3'.
        PERFORM f_concatenate TABLES lt_zmmattnt
                              USING lt_zmmattnt-zhier(4) lt_zmmattnt-zdesc
                              CHANGING lt_zmmattnt-zdesc1.
      WHEN '4'.
        PERFORM f_concatenate TABLES lt_zmmattnt
                              USING lt_zmmattnt-zhier(7) lt_zmmattnt-zdesc
                              CHANGING lt_zmmattnt-zdesc1.
      WHEN '5'.
        PERFORM f_concatenate TABLES lt_zmmattnt
                              USING lt_zmmattnt-zhier(11) lt_zmmattnt-zdesc
                              CHANGING lt_zmmattnt-zdesc1.

      WHEN OTHERS.
    ENDCASE.
    MODIFY lt_zmmattnt TRANSPORTING zdesc1.
  ENDLOOP.

  UPDATE zmmattnt FROM TABLE lt_zmmattnt.

ENDFORM.                    " F_MODIFY_DESCRIPTION

*&---------------------------------------------------------------------*
*&      Form  F_HORIZONTAL
*&---------------------------------------------------------------------*
FORM f_horizontal  TABLES   ft_out STRUCTURE gt_out
                   USING    fu_zhier
                   CHANGING fc_zhier fc_zdesc fc_ztext.

  fc_zhier = fu_zhier.
  READ TABLE ft_out WITH KEY zhier = fc_zhier.
  IF sy-subrc EQ 0.
    fc_zdesc = ft_out-zdesc.
  ENDIF.
  CONCATENATE fc_zhier '-' fc_zdesc
    INTO fc_ztext
    SEPARATED BY space.
ENDFORM.                    " F_HORIZONTAL

*&---------------------------------------------------------------------*
*&      Form  F_CONCATENATE
*&---------------------------------------------------------------------*
FORM f_concatenate  TABLES   ft_temp STRUCTURE zmmattnt
                    USING    fu_zhier01 fu_zdesc
                    CHANGING fc_zdesc1.

  DATA : lv_zdesc   TYPE zdesch_tnt.

  lv_zdesc  = fu_zdesc.

  IF fu_zhier01 IS NOT INITIAL.
    READ TABLE ft_temp WITH KEY zhier = fu_zhier01.
    IF sy-subrc EQ 0.
      CONCATENATE ft_temp-zdesc1 lv_zdesc
      INTO fc_zdesc1
      SEPARATED BY space.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CONCATENATE

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_DATA
*&---------------------------------------------------------------------*
FORM f_delete_data .
  DELETE zmmattnt FROM TABLE gt_to.
ENDFORM.                    " F_DELETE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_INSERT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_insert_data .
  LOOP AT gt_fr.
    gt_fr-ekorg   = pa_toeko.
    gt_fr-ekgrp   = pa_toekg.
    MODIFY gt_fr TRANSPORTING ekorg ekgrp.
  ENDLOOP.
  INSERT zmmattnt FROM TABLE gt_fr.
ENDFORM.                    " F_INSERT_DATA
