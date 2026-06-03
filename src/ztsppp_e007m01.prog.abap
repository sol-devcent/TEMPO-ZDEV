*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E007M01
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
  PERFORM f_clear_data.
  PERFORM f_exit.
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
