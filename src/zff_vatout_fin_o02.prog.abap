*----------------------------------------------------------------------*
***INCLUDE ZFF_VAT_OUTPUT_PRINT_O02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CREATE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_CONTROL OUTPUT.

  IF CONTAINER_R IS INITIAL.
    CREATE OBJECT CONTAINER_R
           EXPORTING CONTAINER_NAME = 'CONTAINER_1'.

    CREATE OBJECT GRID_R
            EXPORTING  I_PARENT =  CONTAINER_R.

    CALL METHOD    grid_r->set_table_for_first_display
         EXPORTING I_STRUCTURE_NAME = 'ZFVAT_ALVGRID'
         CHANGING  IT_OUTTAB        = I_VATALV.
  ELSE.
    CALL METHOD grid_r->refresh_table_display
         EXPORTING I_SOFT_REFRESH = 'X'.
  ENDIF.

ENDMODULE.                 " CREATE_CONTROL  OUTPUT
