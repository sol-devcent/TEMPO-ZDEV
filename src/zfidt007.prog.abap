*&---------------------------------------------------------------------*
*& Report  ZFIDT007
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  zfidt007.

TABLES: zfidt007.

DATA lt_zfidt007 TYPE zfidt007.
DATA selections TYPE TABLE OF vimsellist.
DATA selection  TYPE vimsellist.
DATA: g_fieldname  TYPE vimsellist-viewfield.
DATA: gt_seltab    TYPE STANDARD TABLE OF vimsellist.

CONSTANTS: c_and   TYPE   char3   VALUE 'AND'.

PARAMETERS: p_bukrs LIKE zfidt007-bukrs DEFAULT '8020' OBLIGATORY.

*SELECT-OPTIONS: s_matnr FOR zfidt007-matnr.

START-OF-SELECTION.

  DEFINE addpar.
    IF &2 IS NOT INITIAL.
      CLEAR selection.
      selection-viewfield = &1.
      selection-value = &2.
      selection-and_or = 'AND'.
      selection-operator = 'EQ'.
      APPEND selection TO selections.
    ENDIF.
  END-OF-DEFINITION.

  addpar 'BUKRS'  p_bukrs.
*  addpar 'CUSTGRP' p_cusgrp.
*  addpar 'KUNNR'   p_kunnr.

*Add Order Type to selection criteria of Table maintenanace view
*  IF s_ordtyp[] IS NOT INITIAL.
*    g_fieldname = 'ORDTYP'.
*    CALL FUNCTION 'VIEW_RANGETAB_TO_SELLIST'
*      EXPORTING
*        fieldname          = g_fieldname
*        append_conjunction = c_and
*      TABLES
*        sellist            = gt_seltab
*        rangetab           = s_ordtyp.
*  ENDIF.

  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action                = 'U' "for Update
      view_name             = 'ZFIDT007'
      complex_selconds_used = 'X'
    TABLES
      dba_sellist           = selections
    EXCEPTIONS
      OTHERS                = 1.
  IF sy-subrc = 1.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
