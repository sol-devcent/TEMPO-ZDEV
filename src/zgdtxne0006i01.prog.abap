*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE0006I01                                           *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  CASE sy-ucomm.
    WHEN 'OK' OR 'CRET'.
      PERFORM f_screen_oke.
      IF d_error = 0.
        SET SCREEN 0.
        LEAVE SCREEN.
      ENDIF.

    WHEN 'CANCEL' OR 'CCAN'.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_9000  INPUT
