*----------------------------------------------------------------------*
***INCLUDE ZFF_VAT_OUTPUT_PRINT_I12 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE SAVE_OK.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      IF VFLAG1 = 0.
        ZFVATNR-MANDT = SY-MANDT.
        ZFVATNR-VKORG = S2VKORG.
        ZFVATNR-VKBUR = S2VKBUR.
        ZFVATNR-VATNO = S2VATNO.
        ZFVATNR-VATFR = S2VATFR.
        ZFVATNR-VATTO = S2VATTO.
        ZFVATNR-VATPR = S2VATPR.
        ZFVATNR-VATDT = S2VATDT.
        ZFVATNR-GJAHR = S2GJAHR.
        MODIFY ZFVATNR.
      ELSE.
        UPDATE ZFVATNR SET
          VATNO = S2VATNO
          VATFR = S2VATFR
          VATTO = S2VATTO
          VATPR = S2VATPR
          VATDT = S2VATDT
          GJAHR = S2GJAHR
          WHERE VKORG = P_VKORG AND
                VKBUR = P_VKBUR.
      ENDIF.
      PERFORM RELEASE_LOCK.
      COMMIT WORK.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
