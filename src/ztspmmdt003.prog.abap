*&---------------------------------------------------------------------*
*& Report  ZTSPMMDT003
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  ztspmmdt003.

TABLES: ztspmmdt003.

DATA lt_ztspmmdt003 TYPE ztspmmdt003.
DATA selections TYPE TABLE OF vimsellist.
DATA selection  TYPE vimsellist.
DATA: g_fieldname  TYPE vimsellist-viewfield.
DATA: gt_seltab    TYPE STANDARD TABLE OF vimsellist.

CONSTANTS: c_and   TYPE   char3   VALUE 'AND'.

*SELECT-OPTIONS: s_ordtyp FOR zdg2sddt0019-ordtyp,
*                s_cusgrp FOR zdg2sddt0019-custgrp,
*                s_grsnet FOR zdg2sddt0019-grsnet_id.

START-OF-SELECTION.

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

  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action                = 'U' "for Update
      view_name             = 'ZTSPMMDT003'
*      complex_selconds_used = 'X'
    TABLES
      dba_sellist           = gt_seltab
    EXCEPTIONS
      OTHERS                = 1.
  IF sy-subrc = 1.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
