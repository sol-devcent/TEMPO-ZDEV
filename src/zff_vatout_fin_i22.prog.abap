*----------------------------------------------------------------------*
***INCLUDE ZFF_VAT_OUTPUT_PRINT_I22 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CASE SAVE_OK.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      IF S3VATNM NE SPACE OR S3VATTL NE SPACE.
        ZFVATNM-MANDT = SY-MANDT.
        ZFVATNM-VKORG = S3VKORG.
        ZFVATNM-VKBUR = S3VKBUR.
        ZFVATNM-VTART = 'FI'.
        ZFVATNM-VATNM = S3VATNM.
        ZFVATNM-VATTL = S3VATTL.
        ZFVATNM-OBJECT1 = S3OBJECT.
        MODIFY ZFVATNM.
      ELSE.
        MESSAGE I002.
      ENDIF.
      COMMIT WORK.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT
