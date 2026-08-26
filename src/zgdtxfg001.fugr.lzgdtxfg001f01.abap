*----------------------------------------------------------------------*
*   INCLUDE LZGD_TXFGF01                                              *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_new_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_new_page USING fu_forex.


*-Tariff for current page

  IF d_itemno = c_max_item AND
     d_line > c_max_item AND
     d_itemcount <> d_line.
    ULINE.
    PERFORM f_footer_tgl.
    PERFORM f_footer_nama_jbt.

*---Page number increment
    CLEAR d_itemno.
    NEW-PAGE LINE-SIZE 100.

*-- Header
    PERFORM f_header_tax_pkp.
    PERFORM f_header_tax_pjkp.
    PERFORM f_header_main_table USING fu_forex.
  ENDIF.

ENDFORM.                    " f_new_page

*&---------------------------------------------------------------------*
*&      Form  f_negative_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_VBRK  text
*      <--P_LT_VBRK  text
*----------------------------------------------------------------------*
FORM f_negative_value USING    fu_vbrkin LIKE zgdtxst0007
                      CHANGING fc_vbrkout LIKE zgdtxst0007.

  fc_vbrkout-itamt = fu_vbrkin-itamt * ( -1 ).
  fc_vbrkout-itdisc = fu_vbrkin-itdisc * ( -1 ).
  fc_vbrkout-dpp = fu_vbrkin-dpp * ( -1 ).
  fc_vbrkout-ppn = fu_vbrkin-ppn * ( -1 ).
  fc_vbrkout-ppnbm = fu_vbrkin-ppnbm * ( -1 ).
  fc_vbrkout-xppnbm = fu_vbrkin-xppnbm * ( -1 ).
  fc_vbrkout-itoth = fu_vbrkin-itoth * ( -1 ).
  fc_vbrkout-itqty = fu_vbrkin-itqty * ( -1 ).
  fc_vbrkout-examt = fu_vbrkin-examt * ( -1 ).
  fc_vbrkout-inamt = fu_vbrkin-inamt * ( -1 ).
  fc_vbrkout-itdiscex = fu_vbrkin-itdiscex * ( -1 ).
  fc_vbrkout-itdiscin = fu_vbrkin-itdiscin * ( -1 ).
  fc_vbrkout-stnk = fu_vbrkin-stnk * ( -1 ).
  fc_vbrkout-pph22 = fu_vbrkin-pph22 * ( -1 ).
  fc_vbrkout-pph23 = fu_vbrkin-pph23 * ( -1 ).

ENDFORM.                    " f_negative_value
