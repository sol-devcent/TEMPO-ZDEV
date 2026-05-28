*&---------------------------------------------------------------------*
*&  Include           ZDG2FI_R0007CL1
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*---------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function,
      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING
          row
          column.
ENDCLASS.                    "lcl_handle_events DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.
    IF sy-subrc = 0.
      PERFORM f_user_command USING e_salv_function.
    ENDIF.
  ENDMETHOD.                    "on_user_command

  METHOD on_double_click.
    PERFORM f_double_click USING row column.
  ENDMETHOD.
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION
