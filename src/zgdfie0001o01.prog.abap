*----------------------------------------------------------------------*
*   INCLUDE ZGDFIE0001O01                                              *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  m_status_9010  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_status_9010 OUTPUT.

  SET PF-STATUS 'STAT9010'.
  SET TITLEBAR 'TITLE9010'.

ENDMODULE.                 " m_status_9010  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  m_display_billing  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_display_billing OUTPUT.

  t_9010 = t_9010.

ENDMODULE.                 " m_display_billing  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  m_check_billing  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_check_billing INPUT.

ENDMODULE.                 " m_check_billing  INPUT

*&---------------------------------------------------------------------*
*&      Module  m_status_9020  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_status_9020 OUTPUT.

  SET PF-STATUS 'STAT9020'.
  SET TITLEBAR 'TITLE9020'.

ENDMODULE.                 " m_status_9020  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  m_initiate_netwr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_initiate_netwr OUTPUT.

  IF d_netwr IS INITIAL.
    d_netwr = s911-netwr.
  ENDIF.

ENDMODULE.                 " m_initiate_netwr  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  m_initiate_kzwi1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_initiate_kzwi1 OUTPUT.

  IF d_kzwi1 IS INITIAL.
    d_kzwi1 = s911-kzwi1.
  ENDIF.

ENDMODULE.                 " m_initiate_kzwi1  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  m_disable_cor  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_disable_cor OUTPUT.

*  break bcrmd.
  IF t_9010-sts = 'COR'.
*    CLEAR tc_9010-line_selector.
    LOOP AT tc_9010-cols INTO wa_cols.
      IF wa_cols-screen-name = 'T_9010-SELECT'.
        wa_cols-screen-input = '0'.
        wa_cols-screen-active = '0'.
        MODIFY tc_9010-cols FROM wa_cols.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " m_disable_cor  OUTPUT

* OUTPUT MODULE FOR TABLECONTROL 'TC_9030':
* GET LINES OF TABLECONTROL
MODULE tc_9030_get_lines OUTPUT.
  g_tc_9030_lines = sy-loopc.

  SELECT SINGLE stras ort01
         INTO (d_stras, d_ort01)
         FROM kna1
         WHERE kunnr = t_fidt0003-kunnr.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_9030  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9030 OUTPUT.

  SET PF-STATUS 'STAT9030'.
  SET TITLEBAR 'TITLE9010'.

ENDMODULE.                 " STATUS_9030  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  m_status_9040  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_status_9040 OUTPUT.

  SET PF-STATUS 'STAT9040'.
  SET TITLEBAR 'TITLE9040'.

ENDMODULE.                 " m_status_9040  OUTPUT
