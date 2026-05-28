*&---------------------------------------------------------------------*
*&  Include           ZHSMMM_E001M01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  PERFORM f_status.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  DOCKING_AND_SPLIT_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE docking_and_split_container OUTPUT.
  PERFORM f_docking_split_container.
ENDMODULE.                 " DOCKING_AND_SPLIT_CONTAINER  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MAIN_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE main_alv OUTPUT.
  PERFORM f_main_alv.
ENDMODULE.                 " MAIN_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  PERFORM f_exit.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  PERFORM f_user_command.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_PRGRP  INPUT
*&---------------------------------------------------------------------*
MODULE value_prgrp INPUT.
  PERFORM f_value_prgrp.
ENDMODULE.                 " VALUE_PRGRP  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_NRMIT  INPUT
*&---------------------------------------------------------------------*
MODULE value_nrmit INPUT.
  PERFORM f_value_nrmit.
ENDMODULE.                 " VALUE_NRMIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_SELECTION  INPUT
*&---------------------------------------------------------------------*
MODULE value_selection INPUT.
  PERFORM f_value_selection.
ENDMODULE.                 " VALUE_SELECTION  INPUT

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  IF gv_subrc IS INITIAL.
    PERFORM f_process_before_output.
    PERFORM f_cursor_position.
  ELSE.
    PERFORM f_layout_modify.
  ENDIF.
ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
MODULE pai INPUT.
  PERFORM f_process_after_input.
ENDMODULE.                 " PAI  INPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_table_control OUTPUT.
  PERFORM f_fill_table_control.
ENDMODULE.                 " FILL_TABLE_CONTROL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL  INPUT
*&---------------------------------------------------------------------*
MODULE read_table_control INPUT.
  PERFORM f_read_table_control.
ENDMODULE.                 " READ_TABLE_CONTROL  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_RFQ_TYPE  INPUT
*&---------------------------------------------------------------------*
MODULE value_rfq_type INPUT.
  PERFORM f_value_rfq_type.
ENDMODULE.                 " VALUE_RFQ_TYPE  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_PLANT  INPUT
*&---------------------------------------------------------------------*
MODULE value_plant INPUT.
  PERFORM f_value_plant.
ENDMODULE.                 " VALUE_PLANT  INPUT
