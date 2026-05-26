FUNCTION zftax_check .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_VALUE) TYPE  STRING OPTIONAL
*"     VALUE(PI_PATTERN) TYPE  STRING OPTIONAL
*"     VALUE(PI_LENGTH) TYPE  INT4 OPTIONAL
*"  EXPORTING
*"     VALUE(PE_VALUE) TYPE  STRING
*"     VALUE(PE_SUBRC) TYPE  SY-SUBRC
*"----------------------------------------------------------------------
  DATA : lv_value   TYPE c LENGTH 100,
         lv_string  TYPE string,
         lv_subrc   TYPE sy-subrc,
         lv_length  TYPE i,
         lv_pattern TYPE string,
         lv_count   TYPE i,
         lv_lines   TYPE i,
         result_tab TYPE match_result_tab,
         lv_leng16  TYPE i VALUE 16.

  pe_subrc   = 4.
  lv_string  = pi_value.
  CLEAR result_tab.
  FIND ALL OCCURRENCES OF '-' IN lv_string
       RESULTS result_tab.
  IF result_tab[] IS NOT INITIAL.
    DESCRIBE TABLE result_tab LINES lv_lines.
    ADD lv_lines TO lv_count.
  ENDIF.

  CLEAR result_tab.
  FIND ALL OCCURRENCES OF '.' IN lv_string
       RESULTS result_tab.
  IF result_tab[] IS NOT INITIAL.
    DESCRIBE TABLE result_tab LINES lv_lines.
    ADD lv_lines TO lv_count.
  ENDIF.

  TRANSLATE lv_string USING '- '.
  TRANSLATE lv_string USING '. '.
  CONDENSE lv_string NO-GAPS.

  lv_length = strlen( lv_string ).
  IF lv_length = pi_length.
    IF lv_string CO '0123456789'.
      ADD 1 TO lv_count.
    ENDIF.
  ELSEIF lv_length = lv_leng16.
    IF lv_string CO '0123456789'.
      ADD 1 TO lv_count.
    ENDIF.
  ENDIF.

  IF pi_pattern IS NOT INITIAL.
    IF lv_length = pi_length.
      lv_pattern = pi_pattern.
      TRANSLATE lv_pattern USING '+_'.
      WRITE lv_string TO lv_value USING EDIT MASK lv_pattern.
      pe_value = lv_value.
      IF lv_value CP pi_pattern.
        ADD 1 TO lv_count.
      ENDIF.
    ELSEIF lv_length = lv_leng16.
      ADD 1 TO lv_count.
    ENDIF.
  ENDIF.

  IF lv_count = 2.
    pe_subrc = 0.
  ENDIF.
ENDFUNCTION.
