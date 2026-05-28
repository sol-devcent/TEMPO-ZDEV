*&---------------------------------------------------------------------*
*&  Include           ZTSPMM_E002M01
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
  PERFORM f_validate_data USING ''.
  PERFORM f_pbo.
ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TC_ITEMS  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_tc_items OUTPUT.
  PERFORM f_fill_tc_items.
ENDMODULE.                 " FILL_TC_ITEMS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
MODULE pai INPUT.
  PERFORM f_pai.
ENDMODULE.                 " PAI  INPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TC_ITEMS  INPUT
*&---------------------------------------------------------------------*
MODULE read_tc_items INPUT.
  PERFORM f_read_tc_items.
ENDMODULE.                 " READ_TC_ITEMS  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  PERFORM f_user_command.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4_STORAGE_LOCATION  INPUT
*&---------------------------------------------------------------------*
MODULE f4_storage_location INPUT.
  PERFORM f_f4_storage_location.
ENDMODULE.                 " F4_STORAGE_LOCATION  INPUT

*&---------------------------------------------------------------------*
*&      Module  FT_BATCH  INPUT
*&---------------------------------------------------------------------*
MODULE ft_batch INPUT.
  PERFORM f_f4_batch.
ENDMODULE.                 " FT_BATCH  INPUT
