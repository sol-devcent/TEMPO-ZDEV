*&---------------------------------------------------------------------*
*&  Include           ZCO_NDCCCL1
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&       Class lcl_application
*&---------------------------------------------------------------------*
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

      handle_data_changed
      FOR EVENT data_changed
                  OF cl_gui_alv_grid
        IMPORTING er_data_changed e_ucomm.
ENDCLASS.               "lcl_application

*&---------------------------------------------------------------------*
*&       Class (Implementation)  lcl_application
*&---------------------------------------------------------------------*
CLASS lcl_application IMPLEMENTATION.
  METHOD handle_toolbar.
    DATA: ls_toolbar  TYPE stb_button.

* append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.

* append an icon Posting
    CLEAR ls_toolbar.
    MOVE 'ALL' TO ls_toolbar-function.
    MOVE icon_select_all TO ls_toolbar-icon.
    MOVE 'Select All'(111) TO ls_toolbar-quickinfo.
*    MOVE 'Posting'(112) TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.
    APPEND ls_toolbar TO e_object->mt_toolbar.

* append an icon Reverse
    CLEAR ls_toolbar.
    MOVE 'SAL' TO ls_toolbar-function.
    MOVE icon_deselect_all TO ls_toolbar-icon.
    MOVE 'Deselect All'(111) TO ls_toolbar-quickinfo.
*    MOVE 'Reverse'(112) TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.
    APPEND ls_toolbar TO e_object->mt_toolbar.

* append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CASE 'X'.
      WHEN p_post.
* append an icon Posting
        CLEAR ls_toolbar.
        MOVE 'POSTING' TO ls_toolbar-function.
        MOVE icon_execute_object TO ls_toolbar-icon.
        MOVE 'Posting'(111) TO ls_toolbar-quickinfo.
        MOVE 'Posting'(112) TO ls_toolbar-text.
        MOVE ' ' TO ls_toolbar-disabled.
        APPEND ls_toolbar TO e_object->mt_toolbar.
      WHEN p_revs.
* append an icon Reverse
        CLEAR ls_toolbar.
        MOVE 'REVERSE' TO ls_toolbar-function.
        MOVE icon_execute_object TO ls_toolbar-icon.
        MOVE 'Reverse'(111) TO ls_toolbar-quickinfo.
        MOVE 'Reverse'(112) TO ls_toolbar-text.
        MOVE ' ' TO ls_toolbar-disabled.
        APPEND ls_toolbar TO e_object->mt_toolbar.
    ENDCASE.

  ENDMETHOD.                    "handle_toolbar

  METHOD handle_menu_button.

  ENDMETHOD.                    "handle_menu_button

  METHOD handle_user_command.
    DATA: lt_rows TYPE lvc_t_row.

    CASE e_ucomm.
      WHEN 'ALL'.
        LOOP AT gt_out ASSIGNING FIELD-SYMBOL(<fs_out>).
          IF <fs_out>-celltab[] IS INITIAL.
            <fs_out>-chkbox = 'X'.
          ENDIF.
        ENDLOOP.
      WHEN 'SAL'.
        LOOP AT gt_out ASSIGNING <fs_out>.
          IF <fs_out>-celltab[] IS INITIAL.
            <fs_out>-chkbox = ' '.
          ENDIF.
        ENDLOOP.
      WHEN 'POSTING'.
        gv_status = 'POST'.
        PERFORM f_posting USING gv_status.
      WHEN 'REVERSE'.
        gv_status = 'REVS'.
        PERFORM f_posting USING gv_status.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "handle_user_command

  METHOD handle_data_changed.

  ENDMETHOD.                    "handle_data_changed
ENDCLASS.               "lcl_application
