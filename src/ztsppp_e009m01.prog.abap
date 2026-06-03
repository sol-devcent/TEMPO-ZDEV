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
      CLEAR: gv_others,gv_minmax,gv_rework,gv_ibupro,gs_head-message.
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
*&      Module  VALIDATE_AUFNR  INPUT
*&---------------------------------------------------------------------*
MODULE validate_aufnr INPUT.
  PERFORM f_validate_aufnr.
ENDMODULE.                 " VALIDATE_AUFNR  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_TARA  INPUT
*&---------------------------------------------------------------------*
MODULE get_tara INPUT.
  PERFORM f_get_tara.
ENDMODULE.                 " GET_TARA  INPUT

*&---------------------------------------------------------------------*
*&      Module  M_VALUE_VORNR  INPUT
*&---------------------------------------------------------------------*
MODULE m_value_vornr INPUT.
  TYPES: BEGIN OF ty_vornr,
          aufnr   TYPE resb-aufnr,
          vornr   TYPE resb-vornr,
         END OF ty_vornr.

  DATA: lv_dynprofield TYPE help_info-dynprofld,
        lt_vornr       TYPE TABLE OF ty_vornr.        " Internal table to store search data

  IF gs_head-aufnr IS NOT INITIAL.
    SELECT DISTINCT aufnr vornr FROM resb INTO TABLE lt_vornr
      WHERE aufnr = gs_head-aufnr ORDER BY aufnr vornr.

    IF sy-subrc EQ 0.
      lv_dynprofield = 'GS_HEAD-VORNR'.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield          = 'VORNR'
          dynpprog          = sy-repid                   " Current program name
          dynpnr            = sy-dynnr                   " Current screen number
          dynprofield       = lv_dynprofield             " Name of the screen field
          value_org         = 'S'                        " Value origin (S=Structure, C=Column)
        TABLES
          value_tab         = lt_vornr                 " Internal table with data
        EXCEPTIONS
          field_not_found   = 1
          no_help_for_field = 2
          inconsistent_help = 3
          no_values_found   = 4
          OTHERS            = 5.
    ENDIF.
  ENDIF.
ENDMODULE.
