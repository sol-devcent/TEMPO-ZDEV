*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_EX01M01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  PERFORM f_status.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  PERFORM f_exit.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TC_ORDER  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_tc_order OUTPUT.
  PERFORM f_fill_tc_order.
ENDMODULE.                 " FILL_TC_ORDER  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TC_ORDER  INPUT
*&---------------------------------------------------------------------*
MODULE read_tc_order INPUT.
  PERFORM f_read_tc_order.
ENDMODULE.                 " READ_TC_ORDER  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  PERFORM f_user_command_900.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  PERFORM f_pbo.
ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
MODULE pai INPUT.
  PERFORM f_pai.
ENDMODULE.                 " PAI  INPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TC_MATERIAL  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_tc_material OUTPUT.
  PERFORM f_fill_tc_material.
ENDMODULE.                 " FILL_TC_MATERIAL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TC_MATERIAL  INPUT
*&---------------------------------------------------------------------*
MODULE read_tc_material INPUT.
  PERFORM f_read_tc_material.
ENDMODULE.                 " READ_TC_MATERIAL  INPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TC_NOTES  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_tc_notes OUTPUT.
  PERFORM f_fill_tc_notes.
ENDMODULE.                 " FILL_TC_NOTES  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TC_NOTES  INPUT
*&---------------------------------------------------------------------*
MODULE read_tc_notes INPUT.
  PERFORM f_read_tc_notes.
ENDMODULE.                 " READ_TC_NOTES  INPUT
