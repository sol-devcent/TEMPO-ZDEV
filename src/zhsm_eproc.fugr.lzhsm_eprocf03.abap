*----------------------------------------------------------------------*
***INCLUDE LZHSM_EPROCF03 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_MPN
*&---------------------------------------------------------------------*
FORM f_get_material_mpn  TABLES   ft_ekpo   STRUCTURE ekpo
                                  ft_qinf   STRUCTURE qinf
                         USING    fu_lifnr fu_werks fu_ebeln fu_matnr
                         CHANGING fc_matnr.
  DATA : lr_matnr         TYPE RANGE OF matnr,
         ls_matnr         LIKE LINE OF lr_matnr,
         ls_qinf          TYPE qinf,
         ls_ekpo          TYPE ekpo.

  CONCATENATE fu_matnr '*' INTO ls_matnr-low.
  ls_matnr-sign   = 'I'.
  ls_matnr-option = 'CP'.
  APPEND ls_matnr TO lr_matnr.
  CLEAR ls_matnr.

  fc_matnr = fu_matnr.

  IF ft_qinf[] IS INITIAL.
    CLEAR ls_ekpo.
    READ TABLE ft_ekpo INTO ls_ekpo
                       WITH KEY ebeln = fu_ebeln
                                matnr = fu_matnr.
    IF ls_ekpo-idnlf IS INITIAL.
      fc_matnr = fu_matnr.
    ELSE.
      fc_matnr = ls_ekpo-idnlf.
    ENDIF.
  ELSE.
    CLEAR ls_qinf.
    LOOP AT ft_qinf INTO ls_qinf WHERE lieferant = fu_lifnr
                                   AND werk      = fu_werks.
      IF ls_qinf-matnr IN lr_matnr.
        fc_matnr = ls_qinf-matnr.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_MATERIAL_MPN
