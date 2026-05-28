*&---------------------------------------------------------------------*
*&  Include           ZTSPMM_E003M01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  PERFORM f_status.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  PERFORM f_process_before_output.
ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  PERFORM f_clear_data USING 'X'.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
MODULE pai INPUT.
  PERFORM f_process_after_input.
ENDMODULE.                 " PAI  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  PERFORM f_user_command.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command102 INPUT.
  PERFORM f_user_command102.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  GENERATE_TABLE  OUTPUT
*&---------------------------------------------------------------------*
MODULE generate_table OUTPUT.
  PERFORM f_generate_table.
ENDMODULE.                 " GENERATE_TABLE  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MODIFY_TABLE  INPUT
*&---------------------------------------------------------------------*
MODULE modify_table INPUT.
  PERFORM f_modify_table.
ENDMODULE.                 " MODIFY_TABLE  INPUT

*&---------------------------------------------------------------------*
*&      Module  MODIFY_TABLE  INPUT
*&---------------------------------------------------------------------*
MODULE modify_table102 INPUT.
  PERFORM f_modify_table102.
ENDMODULE.                 " MODIFY_TABLE  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4STKTYP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4stktyp INPUT.
  PERFORM f_f4_stktyp.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  GENERATE_TABLE102  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE generate_table102 OUTPUT.
  PERFORM f_generate_table102.
ENDMODULE.
