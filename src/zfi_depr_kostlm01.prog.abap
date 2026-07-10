*&---------------------------------------------------------------------*
*&  Include           ZFI_DEPR_KOSTLM01
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
  IF pa_drill IS INITIAL.
    PERFORM f_docking_split_container.
  ELSE.
    PERFORM f_docking_split_container1.
  ENDIF.
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
*&      Module  TREE_ALV  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tree_alv OUTPUT.
  IF g_tree IS INITIAL.
    PERFORM f_build_header CHANGING g_header.
    PERFORM f_tree_alv.
    PERFORM f_register_event.
    PERFORM f_create_hierarchy.
  ENDIF.
ENDMODULE.                 " TREE_ALV  OUTPUT
