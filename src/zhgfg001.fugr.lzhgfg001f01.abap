*----------------------------------------------------------------------*
***INCLUDE LZHGFG001F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION
*&---------------------------------------------------------------------*
FORM f_conversion  USING    fu_conv fu_value fu_meinh
                   CHANGING fc_value fc_meinh.
  DATA : lv_funcname       TYPE tdsfname.

  IF fu_meinh IS NOT INITIAL.
    IF fu_value IS NOT INITIAL.
      WRITE fu_value TO fc_value UNIT fu_meinh.
      TRANSLATE fc_value USING '. '.
      CONDENSE fc_value NO-GAPS.
    ENDIF.

    CONCATENATE 'CONVERSION_EXIT_CUNIT_' fu_conv INTO lv_funcname.

    CALL FUNCTION lv_funcname
      EXPORTING
        input          = fu_meinh
      IMPORTING
        output         = fc_meinh
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ALPHA_CONVERSION
*&---------------------------------------------------------------------*
FORM f_alpha_conversion  USING    fu_value
                         CHANGING fc_value.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_value
    IMPORTING
      output = fc_value.
ENDFORM.
