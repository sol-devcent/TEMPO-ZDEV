*&---------------------------------------------------------------------*
*& Report  ZTSPMDHAZCOM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  ztspmdhazcom.

DATA lt_ztspmdhazcom TYPE ztspmdhazcom.
DATA selections TYPE TABLE OF vimsellist.
DATA selection  TYPE vimsellist.

PARAMETERS: werks TYPE ztspmdhazcom-werks OBLIGATORY.
SELECT-OPTIONS: matnr FOR lt_ztspmdhazcom-matnr.


START-OF-SELECTION.

  DEFINE addsel.
    call function 'VIEW_RANGETAB_TO_SELLIST'
      exporting
        fieldname          = &1
        append_conjunction = 'AND'
      tables
        sellist            = selections
        rangetab           = &2[].
  END-OF-DEFINITION.

  DEFINE addpar.
    if &2 is not initial.
      clear selection.
      selection-viewfield = &1.
      selection-value = &2.
      selection-and_or = 'AND'.
      selection-operator = 'EQ'.
      append selection to selections.
    endif.
  END-OF-DEFINITION.

  addpar 'WERKS' werks.
  addsel 'MATNR' matnr.

  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action                = 'S' "for Display
      view_name             = 'ZTSPMDHAZCOM'
      complex_selconds_used = 'X'
    TABLES
      dba_sellist           = selections
    EXCEPTIONS
      OTHERS                = 1.
  IF sy-subrc = 1.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
