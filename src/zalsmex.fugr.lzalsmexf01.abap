*----------------------------------------------------------------------*
***INCLUDE LZALSMEXF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEPARATED_TO_INTERN_CONVERT_V2
*&---------------------------------------------------------------------*
FORM separated_to_intern_convert_v2  TABLES   i_tab     TYPE ty_t_sender
                                              i_intern  TYPE ty_t_itab_v2
                                     USING    i_separator.
  DATA: l_sic_tabix LIKE sy-tabix,
        l_sic_col   TYPE numc05.
  DATA: l_fdpos     LIKE sy-fdpos.

  REFRESH i_intern.

  LOOP AT i_tab.
    l_sic_tabix = sy-tabix.
    l_sic_col = 0.
    WHILE i_tab CA i_separator.
      l_fdpos = sy-fdpos.
      l_sic_col = l_sic_col + 1.
      PERFORM line_to_cell_separat_v2 TABLES i_intern
                                      USING  i_tab l_sic_tabix l_sic_col
                                             i_separator l_fdpos.
    ENDWHILE.
    IF i_tab <> space.
      CLEAR i_intern.
      i_intern-row = l_sic_tabix.
      i_intern-col = l_sic_col + 1.
      i_intern-value = i_tab.
      APPEND i_intern.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " SEPARATED_TO_INTERN_CONVERT_V2

*&---------------------------------------------------------------------*
*&      Form  LINE_TO_CELL_SEPARAT_V2
*&---------------------------------------------------------------------*
FORM line_to_cell_separat_v2  TABLES   i_intern    TYPE ty_t_itab_v2
                              USING    i_line
                                       i_row       LIKE sy-tabix
                                       ch_cell_col TYPE numc05
                                       i_separator TYPE c
                                       i_fdpos     LIKE sy-fdpos.
  DATA: l_string   TYPE ty_s_senderline.
  DATA  l_sic_int  TYPE i.

  CLEAR i_intern.
  l_sic_int = i_fdpos.
  i_intern-row = i_row.
  l_string = i_line.
  i_intern-col = ch_cell_col.
* csv Dateien mit separator in Zelle: --> ;"abc;cd";
  IF ( i_separator = ';' OR  i_separator = ',' ) AND
       l_string(1) = gc_esc.
      PERFORM line_to_cell_esc_sep USING l_string
                                         l_sic_int
                                         i_separator
                                         i_intern-value.
  ELSE.
    IF l_sic_int > 0.
      i_intern-value = i_line(l_sic_int).
    ENDIF.
  ENDIF.
  IF l_sic_int > 0.
    APPEND i_intern.
  ENDIF.
  l_sic_int = l_sic_int + 1.
  i_line = i_line+l_sic_int.
ENDFORM.                    " LINE_TO_CELL_SEPARAT_V2
