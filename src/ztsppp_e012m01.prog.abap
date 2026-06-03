*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E009M01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  PERFORM f_status.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  PERFORM f_pbo.
ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  CASE sy-dynnr.
    WHEN '0103'.
      gv_char = ''.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      CLEAR gv_others.
      n1 = 1.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
MODULE pai INPUT.
  PERFORM f_pai.
ENDMODULE.                 " PAI  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  PERFORM f_user_command.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4_LGORT  INPUT
*&---------------------------------------------------------------------*
MODULE f4_lgort INPUT.
  TYPES: BEGIN OF ty_lgort,
          werks   TYPE werks_d,
          lgort   TYPE lgort_d,
          lgobe   TYPE lgobe,
         END OF ty_lgort.

  DATA: lt_t001l        TYPE TABLE OF t001l WITH HEADER LINE,
        lt_lgort        TYPE TABLE OF ty_lgort WITH HEADER LINE,
        lv_dynprofield  TYPE help_info-dynprofld.

  SELECT werks lgort lgobe
    INTO CORRESPONDING FIELDS OF TABLE lt_lgort
    FROM t001l WHERE werks = gs_head-werks.

  lv_dynprofield = 'GS_HEAD-LGORT'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'LGORT'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = lv_dynprofield
      value_org   = 'S'
    TABLES
      value_tab   = lt_lgort.
ENDMODULE.                 " F4_LGORT  INPUT
