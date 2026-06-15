*&---------------------------------------------------------------------*
*& Report  ZDG2SDCT0033
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  zst_point.

TABLES: zst_point.

DATA lt_zst_point TYPE zst_point.
DATA selections TYPE TABLE OF vimsellist.
DATA selection  TYPE vimsellist.

PARAMETERS: p_werks TYPE zst_point-werks OBLIGATORY.
SELECT-OPTIONS: s_lgort FOR zst_point-lgort.
SELECT-OPTIONS: s_mjahr FOR zst_point-mjahr.


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

  addpar 'WERKS' p_werks.
  addsel 'LGORT' s_lgort.
  addsel 'MJAHR' s_mjahr.

  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action                = 'U' "for Update
      view_name             = 'ZST_POINT'
      complex_selconds_used = 'X'
    TABLES
      dba_sellist           = selections
    EXCEPTIONS
      OTHERS                = 1.
  IF sy-subrc = 1.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
