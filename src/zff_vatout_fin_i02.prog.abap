*----------------------------------------------------------------------*
***INCLUDE ZFF_VAT_OUTPUT_PRINT_I02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE SAVE_OK.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'DELETE'.
      LOOP AT I_VATALV INTO WA_VATALV.
        UPDATE ZFVATO SET FLAG1 = 'C'
          WHERE VKORG = WA_VATALV-VKORG AND
                VKBUR = WA_VATALV-VKBUR AND
                VBELN = WA_VATALV-VBELN AND
                VTART = 'FI'.
        COMMIT WORK..
      ENDLOOP.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
