*&---------------------------------------------------------------------*
*&  Include           ZCOR031M01
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
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  PERFORM f_exit.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  PERFORM f_user_commannd.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  CONTAINER2_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE container2_alv OUTPUT.
  PERFORM f_container2_alv.
ENDMODULE.                 " CONTAINER2_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  CONTAINER3_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE container3_alv OUTPUT.
  PERFORM f_container3_alv.
ENDMODULE.                 " CONTAINER3_ALV  OUTPUT
