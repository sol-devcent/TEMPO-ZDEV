*&---------------------------------------------------------------------*
*&  Include           ZPM_BREAKDOWN_CHART
*&---------------------------------------------------------------------*
DATA: okcode       LIKE sy-ucomm,
      first_call   TYPE i,
      values TYPE  TABLE OF gprval WITH HEADER LINE,
      column_texts TYPE TABLE OF gprtxt WITH HEADER LINE.

TYPES:
   gfw_text TYPE text40.

CONSTANTS:
 co_gfw_prog_row1  TYPE gfw_text VALUE
                                       'Default % DT',                 "#EC NOTEXT
 co_gfw_prog_row2  TYPE gfw_text VALUE
                                       '% DT'.                "#EC NOTEXT
