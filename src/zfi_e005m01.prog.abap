*&---------------------------------------------------------------------*
*&  Include           ZFI_E005M01
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
*&      Module  VALUE_CUSTOMER  INPUT
*&---------------------------------------------------------------------*
MODULE value_customer INPUT.
  PERFORM f_value_customer.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  F4_BANK1  INPUT
*&---------------------------------------------------------------------*
MODULE f4_bank1 INPUT.
  PERFORM f_f4_bank USING 'GS_BPV-ZBANK1' 'GS_BPV-BUKRS' 'ZBANK'
                          'GS_BPV-ZNOREK1'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  F4_BANK2  INPUT
*&---------------------------------------------------------------------*
MODULE f4_bank2 INPUT.
  PERFORM f_f4_bank USING 'GS_BPVD-ZBANK2' 'GS_BPV-BUKRS' 'ZBANK'
                          'GS_BPVD-ZNOREK2'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  PERFORM f_pbo.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
MODULE pai INPUT.
  PERFORM f_pai.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  F4_NOREK1  INPUT
*&---------------------------------------------------------------------*
MODULE f4_norek1 INPUT.
  PERFORM f_f4_norek USING 'GS_BPV-ZNOREK1' 'GS_BPV-BUKRS' 'ZNOREK'
                           'GS_BPV-ZBANK1' 'PA_WAERS'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  F4_NOREK2  INPUT
*&---------------------------------------------------------------------*
MODULE f4_norek2 INPUT.
  PERFORM f_f4_norek USING 'GS_BPVD-ZNOREK2' 'GS_BPV-BUKRS' 'ZNOREK'
                           'GS_BPVD-ZBANK2' 'PA_WAERS'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_table_control OUTPUT.
  PERFORM f_fill_table_control.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL  INPUT
*&---------------------------------------------------------------------*
MODULE read_table_control INPUT.
  PERFORM f_read_table_control.
ENDMODULE.
