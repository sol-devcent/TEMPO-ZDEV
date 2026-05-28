*&---------------------------------------------------------------------*
*&  Include           ZFPAYROLLC01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&       Class lcl_application
*&---------------------------------------------------------------------*
CLASS lcl_application DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function,
      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.               "lcl_application

*&---------------------------------------------------------------------*
*&       Class (Implementation)  lcl_application
*&---------------------------------------------------------------------*
CLASS lcl_application IMPLEMENTATION.
  METHOD on_user_command.
    PERFORM f_on_user_command USING e_salv_function.
  ENDMETHOD.                    "on_user_command
  METHOD on_double_click.
    PERFORM f_on_double_click USING row column.
  ENDMETHOD.                    "on_double_click
ENDCLASS.               "lcl_application
