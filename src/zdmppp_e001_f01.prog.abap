*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E00X_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  SET PF-STATUS 'PFSTATUS'.
  SET TITLEBAR 'TITLEBAR'.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  gv_info = icon_information.

  PERFORM f_modify_screen USING : 'PWD' '0' '' '' ''.
  PERFORM f_modify_screen USING : 'NEW' '0' '' '' ''.

  IF gv_werks IS INITIAL.
    PERFORM f_modify_screen USING : 'NRP' '0' '' '' ''.
    PERFORM f_modify_screen USING : 'TIT' '0' '' '' ''.
    PERFORM f_modify_screen USING : 'PWD' '0' '' '' ''.
  ELSE.
    PERFORM f_modify_screen USING : 'WRK' '' '0' '' ''.
  ENDIF.

  IF gv_nrp IS INITIAL.
    PERFORM f_cursor_position USING 'GV_NRP' ''.
  ELSEIF gv_title IS INITIAL.
    PERFORM f_cursor_position USING 'GV_TITLE' ''.
  ENDIF.
ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
MODULE pai INPUT.

ENDMODULE.                 " PAI  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  PERFORM f_user_command.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm   TYPE sy-ucomm.

  DATA : lv_nrp(30),
         lv_name(30).

  lv_ucomm = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&NEWPASS'.
      gv_new  = 'X'.

    WHEN '&NEXT'.
      PERFORM f_validate_data USING lv_ucomm.

    WHEN '&SAVE'.
      PERFORM f_validate_data USING lv_ucomm.
      PERFORM f_save_data.

    WHEN '&DELE'.
      PERFORM f_validate_data USING lv_ucomm.
      PERFORM f_delete_data.

    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_CURSOR_POSITION
*&---------------------------------------------------------------------*
FORM f_cursor_position  USING    fu_field fu_pos.
  SET CURSOR FIELD fu_field LINE fu_pos.
ENDFORM.                    " F_CURSOR_POSITION

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
*&      Form  F_ENCRYPT_PASSWORD
*&---------------------------------------------------------------------*
FORM f_encrypt_password USING fu_password.
  DATA : lv_password(30).

  lv_password = fu_password.

  CALL FUNCTION 'DB_CRYPTO_PASSWORD'
    EXPORTING
      clear_text_password          = lv_password
    IMPORTING
      encoded_password             = gv_encoded
    EXCEPTIONS
      crypt_output_buffer_to_small = 1
      crypt_internal_error         = 2
      crypt_truncation_error       = 3
      crypt_conversion_error       = 4
      internal_error               = 5
      OTHERS                       = 6.
ENDFORM.                    " F_ENCRYPT_PASSWORD

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
FORM f_validate_data USING fu_ucomm.
  CLEAR gv_subrc.

  IF gv_nrp IS NOT INITIAL AND gv_title IS NOT INITIAL.
    SELECT SINGLE * INTO @DATA(ls_zdmpppdt001)
      FROM zdmpppdt001 WHERE znrp = @gv_nrp
                         AND ztitle = @gv_title.
    IF sy-subrc = 0.
      IF fu_ucomm = '&NEXT' OR fu_ucomm = '&SAVE'.
        gv_subrc = 4.
        MESSAGE s000(zab) WITH 'NRP & Title already exists'
                          DISPLAY LIKE 'E'.
      ENDIF.
    ELSE.
      IF fu_ucomm = '&DELE'.
        gv_subrc = 4.
        MESSAGE s000(zab) WITH 'NRP & Title does not exists'
                          DISPLAY LIKE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data .
  DATA : ls_zdmpppdt001 TYPE zdmpppdt001.

  IF gv_subrc IS INITIAL.
    ls_zdmpppdt001-znrp   = gv_nrp.
    ls_zdmpppdt001-ztitle = gv_title.
    ls_zdmpppdt001-werks  = gv_werks.
    TRY .
        MODIFY zdmpppdt001 FROM ls_zdmpppdt001.
      CATCH cx_root.
    ENDTRY.

    MESSAGE s000(zab) WITH 'Data already saved'.
    CLEAR : gv_nrp, gv_title, gv_newpass, gv_repeat,
            gv_password, gv_new, gv_werks.
  ENDIF.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Module  GET_TITLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_title INPUT.
  DATA: BEGIN OF lt_title OCCURS 0,
          domvalue TYPE domvalue_l,
          ddtext   TYPE val_text,
        END OF lt_title.

  DATA: lt_idd07v      TYPE TABLE OF dd07v WITH HEADER LINE,
        lv_dynprofield TYPE help_info-dynprofld.

  CLEAR: lt_idd07v[],lt_title[].

  lv_dynprofield = 'GV_TITLE'.

  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname        = 'ZTITLETX'   "<-- Your Domain Here
      text           = 'X'
      langu          = sy-langu
    TABLES
      dd07v_tab      = lt_idd07v
    EXCEPTIONS
      wrong_textflag = 1
      OTHERS         = 2.

  LOOP AT lt_idd07v.
    lt_title-domvalue = lt_idd07v-domvalue_l.
    lt_title-ddtext   = lt_idd07v-ddtext.
    APPEND lt_title.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'DOMVALUE'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = lv_dynprofield
      value_org   = 'S'
    TABLES
      value_tab   = lt_title[].
ENDMODULE.                 " GET_TITLE  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_DATA
*&---------------------------------------------------------------------*
FORM f_delete_data .
  IF gv_subrc IS INITIAL.
    DELETE FROM zdmpppdt001 WHERE znrp   = gv_nrp
                              AND ztitle = gv_title
                              AND werks  = gv_werks.

    MESSAGE s000(zab) WITH 'Data deleted'.
    CLEAR : gv_nrp, gv_title, gv_newpass, gv_repeat,
            gv_password, gv_new, gv_werks.
  ENDIF.
ENDFORM.
