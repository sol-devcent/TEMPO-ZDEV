REPORT zf_efaktur .

START-OF-SELECTION.
  CALL SCREEN  100.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '100'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'INT01'.
      SUBMIT zfefaktur_lt VIA SELECTION-SCREEN
         AND RETURN .
    WHEN 'INT02'.
      SUBMIT zfefaktur_bj VIA SELECTION-SCREEN
         AND RETURN .
    WHEN 'INT03'.
*      SUBMIT zfefaktur_fk VIA SELECTION-SCREEN
      SUBMIT zf_fk_v01 VIA SELECTION-SCREEN
         AND RETURN .
    WHEN 'INT04'.
      SUBMIT zfefaktur_rk VIA SELECTION-SCREEN
         AND RETURN .
    WHEN 'INT05'.
      SUBMIT zfefaktur_fm VIA SELECTION-SCREEN
         AND RETURN .
    WHEN 'INT06'.
      SUBMIT zfefaktur_rm VIA SELECTION-SCREEN
         AND RETURN .
    WHEN 'INT07'.
      LEAVE TO SCREEN 0.
*      SUBMIT zfefaktur_dk VIA SELECTION-SCREEN
*         AND RETURN .
    WHEN 'INT08'.
      SUBMIT zfefaktur_rdk VIA SELECTION-SCREEN
         AND RETURN .
    WHEN 'INT09'.
      SUBMIT zfefaktur_dm VIA SELECTION-SCREEN
         AND RETURN .
    WHEN 'INT10'.
      SUBMIT zfefaktur_rdm VIA SELECTION-SCREEN
         AND RETURN .
    WHEN 'CSV01'.
      SUBMIT zf_manupl_efaktur VIA SELECTION-SCREEN
         AND RETURN .
    WHEN 'EXIT' OR 'BACK' OR 'CANCL'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
