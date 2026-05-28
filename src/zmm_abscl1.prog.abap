*&---------------------------------------------------------------------*
*&  Include           ZMM_ABSCL1
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       Class (Definition)  lcl_application
*---------------------------------------------------------------------*
CLASS lcl_application DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_toolbar
          FOR EVENT toolbar
          OF cl_gui_alv_grid
          IMPORTING e_object e_interactive,

      handle_menu_button
          FOR EVENT menu_button
          OF cl_gui_alv_grid
          IMPORTING e_object e_ucomm,

      handle_user_command
          FOR EVENT user_command
          OF cl_gui_alv_grid
          IMPORTING e_ucomm,

      handle_on_f4
          FOR EVENT onf4
          OF cl_gui_alv_grid
          IMPORTING e_fieldname
                    es_row_no
                    er_event_data
                    et_bad_cells
                    e_display.

ENDCLASS.                    "lcl_application DEFINITION

*&---------------------------------------------------------------------*
*&       Class (Implementation)  lcl_application
*&---------------------------------------------------------------------*
CLASS lcl_application IMPLEMENTATION.
  METHOD handle_toolbar.
    IF pa_mc IS INITIAL.
      CLEAR gs_toolbar.
      gs_toolbar-function   = '&SALL'.
      gs_toolbar-butn_type  = 0.
      gs_toolbar-icon       = icon_select_all.
      gs_toolbar-disabled   = space.
      gs_toolbar-quickinfo  = 'Select all'.
      APPEND gs_toolbar TO e_object->mt_toolbar.

      CLEAR gs_toolbar.
      gs_toolbar-function   = '&DALL'.
      gs_toolbar-butn_type  = 0.
      gs_toolbar-icon       = icon_deselect_all.
      gs_toolbar-disabled   = space.
      gs_toolbar-quickinfo  = 'Deselect all'.
      APPEND gs_toolbar TO e_object->mt_toolbar.

      CLEAR gs_toolbar.
      gs_toolbar-butn_type  = 3.
      gs_toolbar-disabled   = space.
      APPEND gs_toolbar TO e_object->mt_toolbar.
    ENDIF.

    CASE 'X'.
      WHEN pa_abs.
        IF pa_bukrs = '8210'.
          CLEAR gs_toolbar.
          gs_toolbar-function   = '&CLAIM'.
          gs_toolbar-butn_type  = 0.
          gs_toolbar-text       = 'Create Claim'.
          gs_toolbar-disabled   = space.
          gs_toolbar-quickinfo  = 'Create Claim'.
          APPEND gs_toolbar TO e_object->mt_toolbar.
        ELSE.
          CLEAR gs_toolbar.
          gs_toolbar-function   = '&CRUP'.
          gs_toolbar-butn_type  = 0.
          gs_toolbar-text       = 'Create UP'.
          gs_toolbar-disabled   = space.
          gs_toolbar-quickinfo  = 'Create UP'.
          APPEND gs_toolbar TO e_object->mt_toolbar.
        ENDIF.

        CLEAR gs_toolbar.
        gs_toolbar-function   = '&ADDR'.
        gs_toolbar-butn_type  = 0.
        gs_toolbar-text       = 'Add to Request'.
        gs_toolbar-disabled   = space.
        gs_toolbar-quickinfo  = 'Add to Request'.
        APPEND gs_toolbar TO e_object->mt_toolbar.

      WHEN pa_crp.
        CLEAR gs_toolbar.
        gs_toolbar-function   = '&DELS'.
        gs_toolbar-butn_type  = 0.
        gs_toolbar-disabled   = space.
        gs_toolbar-quickinfo  = 'Delete Selected'.
        gs_toolbar-icon       = icon_delete.
        APPEND gs_toolbar TO e_object->mt_toolbar.

        CLEAR gs_toolbar.
        gs_toolbar-function   = '&UDES'.
        gs_toolbar-butn_type  = 0.
        gs_toolbar-text       = 'Un-Delete'.
        gs_toolbar-disabled   = space.
        gs_toolbar-quickinfo  = 'Un-Delete'.
        APPEND gs_toolbar TO e_object->mt_toolbar.

        CLEAR gs_toolbar.
        gs_toolbar-butn_type  = 3.
        gs_toolbar-disabled   = space.
        APPEND gs_toolbar TO e_object->mt_toolbar.

        CLEAR gs_toolbar.
        gs_toolbar-function   = '&DELR'.
        gs_toolbar-butn_type  = 0.
        gs_toolbar-disabled   = space.
        gs_toolbar-quickinfo  = 'Delete Request'.
        gs_toolbar-icon       = icon_locked.
        APPEND gs_toolbar TO e_object->mt_toolbar.

        CLEAR gs_toolbar.
        gs_toolbar-function   = '&UDER'.
        gs_toolbar-butn_type  = 0.
        gs_toolbar-disabled   = space.
        gs_toolbar-quickinfo  = 'Un-Delete Request'.
        gs_toolbar-icon       = icon_unlocked.
        APPEND gs_toolbar TO e_object->mt_toolbar.

      WHEN pa_prp.
        CLEAR gs_toolbar.
        gs_toolbar-function   = '&PRNT'.
        gs_toolbar-butn_type  = 0.
        gs_toolbar-text       = 'Cetak Form'.
        gs_toolbar-disabled   = space.
        gs_toolbar-quickinfo  = 'Cetak Form'.
        gs_toolbar-icon       = icon_print.
        APPEND gs_toolbar TO e_object->mt_toolbar.

      WHEN pa_apr.
        CLEAR gs_toolbar.
        gs_toolbar-function   = '&APRL'.
        gs_toolbar-butn_type  = 0.
        gs_toolbar-text       = 'UP Approval'.
        gs_toolbar-disabled   = space.
        gs_toolbar-quickinfo  = 'UP Approval'.
        APPEND gs_toolbar TO e_object->mt_toolbar.

        CLEAR gs_toolbar.
        gs_toolbar-function   = '&CAPRL'.
        gs_toolbar-butn_type  = 0.
        gs_toolbar-text       = 'Cancel Approval'.
        gs_toolbar-disabled   = space.
        gs_toolbar-quickinfo  = 'Cancel Approval'.
        APPEND gs_toolbar TO e_object->mt_toolbar.

      WHEN pa_bbk.
        CLEAR gs_toolbar.
        gs_toolbar-function   = '&PREV'.
        gs_toolbar-butn_type  = 0.
        gs_toolbar-text       = 'Preview BBK'.
        gs_toolbar-disabled   = space.
        gs_toolbar-quickinfo  = 'Preview BBK'.
        APPEND gs_toolbar TO e_object->mt_toolbar.

        CLEAR gs_toolbar.
        gs_toolbar-function   = '&CBBK'.
        gs_toolbar-butn_type  = 0.
        gs_toolbar-text       = 'Create BBK'.
        gs_toolbar-disabled   = space.
        gs_toolbar-quickinfo  = 'Create BBK'.
        APPEND gs_toolbar TO e_object->mt_toolbar.

      WHEN pa_bbk2.
        CLEAR gs_toolbar.
        gs_toolbar-function   = '&PREV'.
        gs_toolbar-butn_type  = 0.
        gs_toolbar-text       = 'Preview BBK'.
        gs_toolbar-disabled   = space.
        gs_toolbar-quickinfo  = 'Preview BBK'.
        APPEND gs_toolbar TO e_object->mt_toolbar.

      WHEN pa_cp.
        CLEAR gs_toolbar.
        gs_toolbar-function   = '&POST'.
        gs_toolbar-butn_type  = 0.
        gs_toolbar-text       = 'Create Pemusnahan'.
        gs_toolbar-disabled   = space.
        gs_toolbar-quickinfo  = 'Create Pemusnahan'.
        APPEND gs_toolbar TO e_object->mt_toolbar.

      WHEN pa_mc.
        CLEAR gs_toolbar.
        gs_toolbar-function   = '&APPRV'.
        gs_toolbar-butn_type  = 0.
        gs_toolbar-text       = 'Approve'.
        gs_toolbar-disabled   = space.
        gs_toolbar-quickinfo  = 'Approve'.
        APPEND gs_toolbar TO e_object->mt_toolbar.

        CLEAR gs_toolbar.
        gs_toolbar-function   = '&REJEC'.
        gs_toolbar-butn_type  = 0.
        gs_toolbar-text       = 'Reject'.
        gs_toolbar-disabled   = space.
        gs_toolbar-quickinfo  = 'Reject'.
        APPEND gs_toolbar TO e_object->mt_toolbar.
    ENDCASE.
  ENDMETHOD.                    "handle_toolbar

  METHOD handle_menu_button.
    CASE e_ucomm.
      WHEN '&SALL'.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode = '&SALL'
            text  = text-101.
      WHEN '&DALL'.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode = '&DALL'
            text  = text-102.
    ENDCASE.
  ENDMETHOD.                    "handle_menu_button

  METHOD handle_user_command.
    DATA : lv_valid   TYPE c,
           lv_answer  TYPE c,
           lt_rows    TYPE lvc_t_row.
    DATA : lv_subrc   TYPE sy-subrc.

    CALL METHOD g_outgrid->get_selected_rows
      IMPORTING
        et_index_rows = lt_rows.

    CALL METHOD cl_gui_cfw=>flush.

    CLEAR gv_text.

    CASE e_ucomm.
      WHEN '&SALL'.
        CALL METHOD g_outgrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          PERFORM f_select USING 'X' ''.
        ENDIF.

      WHEN '&DALL'.
        CALL METHOD g_outgrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          PERFORM f_select USING '' ''.
        ENDIF.

      WHEN '&CRUP'.
        CALL METHOD g_outgrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          PERFORM f_validasi_data USING lv_subrc.
          IF lv_subrc = 0.
            CALL SELECTION-SCREEN 200 STARTING AT 10 10.
            IF sy-subrc = 0.
              IF pa_zrecd IS INITIAL.
                MESSAGE s000(zab) WITH 'Fill in all required entry fields'
                DISPLAY LIKE 'E'.
              ELSE.
                PERFORM f_create_up USING e_ucomm.
              ENDIF.
            ENDIF.
          ELSE.
            MESSAGE s000(zab) WITH 'Data with UP selected, please check selection'
            DISPLAY LIKE 'E'.
          ENDIF.
        ENDIF.

      WHEN '&PREV'.
        CALL METHOD g_outgrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          PERFORM f_create_bbk USING 'PREV'.
        ENDIF.

      WHEN '&APRL'.
        CALL METHOD g_outgrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          PERFORM f_up_approval USING selected.
        ENDIF.

      WHEN '&CAPRL'.
        CALL METHOD g_outgrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          PERFORM f_up_approval USING ''.
        ENDIF.

      WHEN '&CBBK'.
        CALL METHOD g_outgrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          PERFORM f_create_bbk USING 'POST'.
*          LEAVE TO SCREEN 0.
        ENDIF.

      WHEN '&ADDR'.
        CALL METHOD g_outgrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          CLEAR: gv_text,gv_ucomm.
          gv_text = 'Nomor Request'.
          gv_ucomm = e_ucomm.
          PERFORM f_f4_request USING e_ucomm.
        ENDIF.

      WHEN '&DELS'.
        CALL METHOD g_outgrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          PERFORM f_delete USING 'X'.
        ENDIF.

      WHEN '&UDES'.
        CALL METHOD g_outgrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          PERFORM f_undelete USING 'X'.
        ENDIF.

      WHEN '&DELR'.
        CALL METHOD g_outgrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          PERFORM f_delete USING ''.
        ENDIF.

      WHEN '&UDER'.
        CALL METHOD g_outgrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          PERFORM f_undelete USING ''.
        ENDIF.

      WHEN '&PRNT'.
        PERFORM f_cetak_form.

      WHEN '&POST'.
        CALL METHOD g_outgrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          PERFORM f_mvttyp_choice.
        ENDIF.

      WHEN '&CLAIM'.
        CALL METHOD g_outgrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          CLEAR: gv_text,gv_ucomm.
          gv_text = 'Nomor Claim'.
          gv_ucomm = e_ucomm.
          PERFORM f_f4_request USING e_ucomm.
*          PERFORM f_create_up USING e_ucomm.
        ENDIF.

      WHEN '&APPRV'.
        CALL METHOD g_outgrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          CLEAR lv_answer.
          PERFORM f_confirm_message USING 'APPROVE' lv_answer.
          IF lv_answer = '1'.
            PERFORM f_status USING 'APPROVED'.
            MESSAGE 'Document APPROVED' TYPE 'S'.
            LEAVE TO SCREEN 0.
          ENDIF.
        ENDIF.

      WHEN '&REJEC'.
        CALL METHOD g_outgrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          CLEAR lv_answer.
          PERFORM f_confirm_message USING 'REJECT' lv_answer.
          IF lv_answer = '1'.
            PERFORM f_status USING 'REJECTED'.
            MESSAGE 'Document REJECTED' TYPE 'S'.
            LEAVE TO SCREEN 0.
          ENDIF.
        ENDIF.

    ENDCASE.
  ENDMETHOD.                    "handle_user_command

  METHOD handle_on_f4.
    DATA : lv_valid   TYPE c.

    PERFORM f_on_f4_help USING e_fieldname
                               es_row_no-row_id
                               er_event_data
                               et_bad_cells
                               e_display.

    er_event_data->m_event_handled = 'X'.
  ENDMETHOD.                    "handle_on_f4
ENDCLASS.               "lcl_application
