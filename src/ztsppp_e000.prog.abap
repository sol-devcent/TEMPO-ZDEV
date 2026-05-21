*&---------------------------------------------------------------------*
*& Report  ZTSPPP_E000
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztsppp_e000 NO STANDARD PAGE HEADING.

DATA : ok_code      TYPE sy-ucomm,
       gv_mess(100).

START-OF-SELECTION.

  CALL SCREEN 900.

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  DATA fcode TYPE TABLE OF sy-ucomm.

  APPEND 'BACK' TO fcode.
  APPEND 'EXIT' TO fcode.
  APPEND 'CANC' TO fcode.

  SET PF-STATUS 'PFSTATUS' EXCLUDING fcode.
  SET TITLEBAR 'TITLE'.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : lv_ucomm TYPE sy-ucomm,
         lv_subrc TYPE sy-subrc.

  lv_ucomm = ok_code.
  CASE lv_ucomm.
    WHEN '&BACK'.
      LEAVE TO SCREEN 0.
    WHEN '&CALON'.
      SUBMIT ztsppp_e005n AND RETURN.
    WHEN '&KALIBRASI'.
      SUBMIT ztsppp_e004 AND RETURN.
    WHEN '&FULL'.
      SUBMIT ztsppp_e002 AND RETURN.
    WHEN '&REPRINT'.
      SUBMIT ztsppp_e003 AND RETURN.
    WHEN '&WEIGHT'.
      SUBMIT ztsppp_e001 AND RETURN.
    WHEN '&RWEIGH'.
      PERFORM f_authorization_check USING lv_ucomm 'ZREPRT_W'
                                    CHANGING lv_subrc.
      IF lv_subrc = 0.
        SUBMIT ztsppp_e008 AND RETURN.
      ELSE.
        gv_mess = 'You are not authorized'.
      ENDIF.
    WHEN '&STAGING'.
      SUBMIT ztsppp_e006 AND RETURN.
    WHEN '&PGI'.
      PERFORM f_authorization_check USING lv_ucomm 'ZPGI_W'
                                    CHANGING lv_subrc.
      IF lv_subrc = 0.
        SUBMIT ztsppp_e007 AND RETURN.
      ELSE.
        gv_mess = 'You are not authorized'.
      ENDIF.
    WHEN '&BSTB'.
      SUBMIT ztsppp_e009 AND RETURN.
    WHEN '&TSS'.
      SUBMIT ztsppp_e012 AND RETURN.
    WHEN '&LOGOFF'.
      CALL 'SYST_LOGOFF'.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_AUTHORIZATION_CHECK
*&---------------------------------------------------------------------*
FORM f_authorization_check  USING    fu_ucomm fu_autho
                            CHANGING fu_subrc.
  AUTHORITY-CHECK OBJECT fu_autho
           ID 'ACTVT' FIELD '01'.
  lv_subrc = sy-subrc.
ENDFORM.                    " F_AUTHORIZATION_CHECK

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'BAC'.
      screen-active  = '0'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.
