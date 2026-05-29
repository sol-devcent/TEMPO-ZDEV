*&---------------------------------------------------------------------*
*&  Include           ZWM_R001M01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  PERFORM f_status.
  PERFORM f_excluding_toolbar.
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
  IF g_tabgrid IS INITIAL.
    PERFORM f_main_alv.
  ENDIF.
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
  PERFORM f_user_command.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  TREE_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE tree_alv OUTPUT.
  IF g_tree IS INITIAL.
    PERFORM f_build_header CHANGING g_header.
    PERFORM f_tree_alv.
    PERFORM f_register_event.
    PERFORM f_create_hierarchy.
  ENDIF.
ENDMODULE.                 " TREE_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  HEADER_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE header_alv OUTPUT.
  PERFORM f_header_alv.
ENDMODULE.                 " HEADER_ALV  OUTPUT
