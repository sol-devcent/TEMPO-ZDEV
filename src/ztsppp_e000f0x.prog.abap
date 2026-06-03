*----------------------------------------------------------------------*
***INCLUDE ZTSPPP_E000F0X .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PBO99
*&---------------------------------------------------------------------*
FORM f_pbo99 .
  IF gv_subrc IS INITIAL.
    CLEAR gv_message.
  ENDIF.
  IF gv_ocheck IS NOT INITIAL.
    PERFORM f_modify_screen USING : 'OPR' '' '0' '' ''.
  ENDIF.
  IF gv_wcheck IS NOT INITIAL.
    PERFORM f_modify_screen USING : 'AWS' '' '0' '' ''.
  ENDIF.

  IF gv_operator IS INITIAL.
    PERFORM f_cursor_position USING 'GV_OPERATOR' ''.
  ELSEIF gv_opass IS INITIAL.
    IF gv_subrc = 4.
      CLEAR gv_message.
    ENDIF.
    PERFORM f_cursor_position USING 'GV_OPASS' ''.
  ELSEIF gv_pengawas IS INITIAL.
    IF gv_subrc = 5.
      CLEAR gv_message.
    ENDIF.
    PERFORM f_cursor_position USING 'GV_PENGAWAS' ''.
  ELSEIF gv_wpass IS INITIAL.
    PERFORM f_cursor_position USING 'GV_WPASS' ''.
  ENDIF.

  CASE gv_subrc.
    WHEN 4.
      PERFORM f_cursor_position USING 'GV_OPASS' ''.
      CLEAR : gv_onrp, gv_opass.
    WHEN 5.
      PERFORM f_cursor_position USING 'GV_WPASS' ''.
      CLEAR : gv_wnrp, gv_wpass.
    WHEN OTHERS.
      IF gv_ocheck IS NOT INITIAL AND
        gv_wcheck IS NOT INITIAL.
        PERFORM f_cursor_position USING 'OK' ''.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_PBO99

*&---------------------------------------------------------------------*
*&      Form  F_NEXT99
*&---------------------------------------------------------------------*
FORM f_next99 .
  IF gv_ouser IS INITIAL.
    SEARCH gv_operator FOR ';'.
    IF sy-subrc = 0.
      gv_ouser  = gv_operator.
    ENDIF.
  ENDIF.

*  IF gv_wuser IS INITIAL.
  SEARCH gv_pengawas FOR ';'.
  IF sy-subrc = 0.
    gv_wuser  = gv_pengawas.
  ENDIF.
*  ENDIF.

  SPLIT gv_ouser AT ';' INTO gv_onrp gv_oname.
  SPLIT gv_wuser AT ';' INTO gv_wnrp gv_wname.

  IF gv_onrp IS NOT INITIAL.
    PERFORM f_password_check USING gv_onrp gv_opass 'Operator'
                             CHANGING gv_ocheck.
    SPLIT gv_oname AT space INTO gv_operator gv_oname.
  ELSE.
    PERFORM f_password_check USING gv_onrp gv_opass 'Operator'
                             CHANGING gv_ocheck.
  ENDIF.

  IF gv_wnrp IS NOT INITIAL.
    PERFORM f_password_check USING gv_wnrp gv_wpass 'Pengawas'
                             CHANGING gv_wcheck.
    SPLIT gv_wname AT space INTO gv_pengawas gv_wname.
  ELSE.
    PERFORM f_password_check USING gv_wnrp gv_wpass 'Pengawas'
                             CHANGING gv_wcheck.
  ENDIF.
ENDFORM.                    " F_NEXT99

*&---------------------------------------------------------------------*
*&      Form  F_OK99
*&---------------------------------------------------------------------*
FORM f_ok99 .
  IF gv_opass IS INITIAL.
    gv_subrc = 7.
    gv_message  = 'Password Operator harus diisi'.
  ELSE.
    PERFORM f_password_check USING gv_onrp gv_opass 'Operator'
                             CHANGING gv_ocheck.
  ENDIF.

  IF gv_subrc IS INITIAL.
    IF gv_wpass IS INITIAL.
      gv_subrc = 7.
      gv_message  = 'Password Pengawas harus diisi'.
    ELSE.
      PERFORM f_password_check USING gv_wnrp gv_wpass 'Pengawas'
                               CHANGING gv_wcheck.
    ENDIF.
  ENDIF.

  IF gv_subrc IS INITIAL.
    gv_pass = 'X'.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " F_OK99

*&---------------------------------------------------------------------*
*&      Form  F_PASSWORD_CHECK
*&---------------------------------------------------------------------*
FORM f_password_check  USING    fu_nrp fu_password fu_title
                       CHANGING fc_check.

  DATA : lv_encoded   TYPE dbcon_pwd,
         lv_title     TYPE ztitletx,
         ls_005       TYPE ztspppdt005.

  IF fu_title = 'Pengawas' AND fu_nrp IS NOT INITIAL.
    CLEAR gv_subrc.
    lv_title = fu_title.
    TRANSLATE lv_title TO UPPER CASE.
    SELECT SINGLE *
      FROM ztspppdt005
      INTO CORRESPONDING FIELDS OF ls_005
      WHERE znrp = fu_nrp
        AND ztitle = lv_title.
    IF sy-subrc = 0.
      CLEAR: gv_subrc,gv_message.
    ELSE.
      gv_subrc = 5.
      gv_message  = 'User bukan Pengawas'.
    ENDIF.
  ENDIF.

  IF fu_password IS NOT INITIAL AND gv_subrc IS INITIAL.
    CLEAR gv_subrc.
    SELECT SINGLE *
      FROM ztspppdt005
      INTO CORRESPONDING FIELDS OF ls_005
      WHERE znrp = fu_nrp.
    IF sy-subrc = 0.
      PERFORM f_encrypt_password USING fu_password
                                 CHANGING lv_encoded.
      IF lv_encoded <> ls_005-zpassword.
        CASE fu_title.
          WHEN 'Operator'.
            gv_subrc = 4.
          WHEN 'Pengawas'.
            gv_subrc = 5.
        ENDCASE.
      ENDIF.
    ELSE.
      CASE fu_title.
        WHEN 'Operator'.
          gv_subrc = 4.
        WHEN 'Pengawas'.
          gv_subrc = 5.
      ENDCASE.
    ENDIF.

    CASE gv_subrc.
      WHEN 4.
        gv_message  = 'User name/Password Operator tidak sesuai'.
      WHEN 5.
        gv_message  = 'User name/Password Pengawas tidak sesuai'.
      WHEN OTHERS.
        IF fu_password IS NOT INITIAL.
          fc_check = 'X'.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_PASSWORD_CHECK

*&---------------------------------------------------------------------*
*&      Form  F_ENCRYPT_PASSWORD
*&---------------------------------------------------------------------*
FORM f_encrypt_password  USING    fu_password
                         CHANGING fc_encoded.
  DATA : lv_password(30).

  lv_password = fu_password.

  CALL FUNCTION 'DB_CRYPTO_PASSWORD'
    EXPORTING
      clear_text_password          = lv_password
    IMPORTING
      encoded_password             = fc_encoded
    EXCEPTIONS
      crypt_output_buffer_to_small = 1
      crypt_internal_error         = 2
      crypt_truncation_error       = 3
      crypt_conversion_error       = 4
      internal_error               = 5
      OTHERS                       = 6.
ENDFORM.                    " F_ENCRYPT_PASSWORD
