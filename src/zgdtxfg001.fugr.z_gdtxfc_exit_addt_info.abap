FUNCTION z_gdtxfc_exit_addt_info.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(FI_VBRK) LIKE  ZGDTXST0007 STRUCTURE  ZGDTXST0007
*"  EXPORTING
*"     VALUE(FE_VBRK) LIKE  ZGDTXST0007 STRUCTURE  ZGDTXST0007
*"  TABLES
*"      FT_VBPA STRUCTURE  VBPA OPTIONAL
*"----------------------------------------------------------------------

  DATA ld_aubel LIKE vbrp-aubel.
  DATA ld_vgbel LIKE vbrp-vgbel.
  DATA ld_ebeln LIKE ekko-ebeln.
  DATA ld_vbeln LIKE likp-vbeln.

  fe_vbrk = fi_vbrk.

*----------------------------------------------------------------------*
*  Please put company specific additional information for tax system   *
*  down here. Make sure that the fields for the additional info are    *
*  already in ZGDTXST0007 structure                                    *
*----------------------------------------------------------------------*
**Tempo User exit
**Get Delivery info & SO info from VBFA
  DATA: BEGIN OF lt_vbfa OCCURS 10000,
          vbelv LIKE vbfa-vbelv,
          vbtyp_v LIKE vbfa-vbtyp_v,
        END OF lt_vbfa.

  CLEAR lt_vbfa.
**** Koreksi by Sukardi 01/09/2005 Req. Via Email By Tavip
*** Delete
*  IF fi_vbrk-fkart = 'ZI02'.           "Interco Billing
*** EndDelete
***  Insert
  IF fi_vbrk-fkart = 'ZI02' OR fi_vbrk-fkart = 'ZI05' OR
    fi_vbrk-fkart = 'ZA02'.
    "Interco Billing
***  EndInsert
******** End Koreksi By sukardi
    SELECT SINGLE vgbel aubel INTO (ld_vgbel, ld_aubel)
                              FROM vbrp
                              WHERE vbeln = fi_vbrk-vbeln.
    IF sy-subrc = 0.
*-----PO
      fe_vbrk-bstkd = ld_aubel.
      ld_ebeln = ld_aubel.
      IF fi_vbrk-fkart EQ 'ZA02'.
        SELECT SINGLE bstkd bstdk INTO (fe_vbrk-bstkd, fe_vbrk-bstdk)
                                  FROM vbkd
                                  WHERE vbeln = fe_vbrk-bstkd.
        fe_vbrk-deliv = space.
      ELSE.
        SELECT SINGLE bedat INTO fe_vbrk-bstdk FROM ekko
               WHERE ebeln = ld_ebeln.
        fe_vbrk-deliv = ld_vgbel.
      ENDIF.
*-----Delivery
      ld_vbeln = ld_vgbel.
      SELECT SINGLE wadat_ist FROM likp
                          INTO fe_vbrk-lfdat
                          WHERE vbeln = ld_vbeln.
    ENDIF.
  ELSE.
    SELECT vbelv vbtyp_v INTO TABLE lt_vbfa
                         FROM vbfa
                         WHERE vbeln   = fi_vbrk-vbeln AND
                               vbtyp_n = 'M' AND
                               vbtyp_v IN ('C','J').
    IF sy-subrc = 0.
      SORT lt_vbfa BY vbtyp_v.
****Get DO info
      READ TABLE lt_vbfa WITH KEY vbtyp_v = 'J' BINARY SEARCH.
      IF sy-subrc = 0.
        fe_vbrk-deliv = lt_vbfa-vbelv.
        SELECT SINGLE wadat_ist FROM likp
                            INTO fe_vbrk-lfdat
                            WHERE vbeln = lt_vbfa-vbelv.
      ENDIF.
****Get SO info to get Customer PO
      READ TABLE lt_vbfa WITH KEY vbtyp_v = 'C' BINARY SEARCH.
      IF sy-subrc = 0.
        SELECT SINGLE bstkd bstdk INTO (fe_vbrk-bstkd, fe_vbrk-bstdk)
                                  FROM vbkd
                                  WHERE vbeln = lt_vbfa-vbelv.
      ENDIF.
    ENDIF.
  ENDIF.

**Get Sold to party
  READ TABLE ft_vbpa WITH KEY vbeln = fi_vbrk-vbeln
                              parvw = 'AG' BINARY SEARCH.
  fe_vbrk-kunag = ft_vbpa-kunnr.

**Get Ship to party
  READ TABLE ft_vbpa WITH KEY vbeln = fi_vbrk-vbeln
                              parvw = 'WE' BINARY SEARCH.
  fe_vbrk-kunwe = ft_vbpa-kunnr.


ENDFUNCTION.
