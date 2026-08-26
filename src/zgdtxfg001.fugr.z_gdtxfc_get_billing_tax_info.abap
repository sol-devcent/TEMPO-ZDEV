FUNCTION z_gdtxfc_get_billing_tax_info.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  TABLES
*"      FT_TX02IN STRUCTURE  ZGDTXDT0002
*"      FT_TX02OUT STRUCTURE  ZGDTXDT0002
*"----------------------------------------------------------------------

  DATA lt_vbrk LIKE zgdtxst0007 OCCURS 1 WITH HEADER LINE.
  DATA:   ld_tax    LIKE konv-kwert,
          ld_vatout   LIKE konv-kwert.

  SORT ft_tx02in BY vbeln.

*-Get Billing type
  PERFORM f_get_billing_type.

*-Get billing detail
  SELECT k~vbeln k~fkart k~waerk k~vkorg k~spart k~fkdat k~erdat
         k~kunrg k~stceg k~bukrs k~knumv k~kalsm k~kunrg k~xblnr
         k~sfakn k~fksto k~kurrf
         p~posnr p~matnr p~gsber p~aubel p~ean11 p~mwsbp p~arktx
         p~fkimg p~prctr p~pstyv p~bemot p~werks p~vrkme
         INTO CORRESPONDING FIELDS OF TABLE lt_vbrk
         FROM vbrk AS k INNER JOIN vbrp AS p ON k~vbeln = p~vbeln
         FOR ALL ENTRIES IN ft_tx02in
         WHERE   k~vbeln = ft_tx02in-vbeln.

  SORT lt_vbrk BY vbeln matnr fkdat.

*-Get Prices
  PERFORM f_get_price TABLES lt_vbrk
                             t_priceall.

*-Calculate all the prices
  LOOP AT lt_vbrk.

*---Get Tax / VAT out
    PERFORM f_get_vat_out USING    lt_vbrk-vbeln lt_vbrk-posnr
                          CHANGING ld_tax        ld_vatout.

    PERFORM f_amounts USING    lt_vbrk
                               ld_tax
                      CHANGING lt_vbrk-itamt    lt_vbrk-itdisc
                               lt_vbrk-dpp      lt_vbrk-ppn
                               lt_vbrk-ppnbm    lt_vbrk-xppnbm
                               lt_vbrk-itoth    lt_vbrk-itqty
                               lt_vbrk-examt    lt_vbrk-inamt
                               lt_vbrk-itdiscex lt_vbrk-itdiscin
                               lt_vbrk-stnk
                               lt_vbrk-pph22
                               lt_vbrk-pph23.

    IF lt_vbrk-fkart IN r_fkartr OR
       lt_vbrk-fkart IN r_fkartc.
      PERFORM f_negative_value USING lt_vbrk
                               CHANGING lt_vbrk.
    ENDIF.

    IF lt_vbrk-fkart IN r_fkartp.
      PERFORM f_price_adjustment    USING lt_vbrk
                                          ld_tax
                                 CHANGING lt_vbrk-itamt
                                          lt_vbrk-itdisc
                                          lt_vbrk-itoth
                                          lt_vbrk-ppn
                                          lt_vbrk-examt
                                          lt_vbrk-inamt
                                          lt_vbrk-itdiscex
                                          lt_vbrk-itdiscin
                                          lt_vbrk-pph22
                                          lt_vbrk-pph23.
    ENDIF.

    lt_vbrk-itamtlast    = lt_vbrk-itamt.
    lt_vbrk-itdisclast   = lt_vbrk-itdisc.
    lt_vbrk-dpplast      = lt_vbrk-dpp.
    lt_vbrk-ppnlast      = lt_vbrk-ppn.
    lt_vbrk-ppnbmlast    = lt_vbrk-ppnbm.
    lt_vbrk-xppnbmlast   = lt_vbrk-xppnbm.
    lt_vbrk-itothlast    = lt_vbrk-itoth.
    lt_vbrk-itqtylast    = lt_vbrk-itqty.
    lt_vbrk-examtlast    = lt_vbrk-examt.
    lt_vbrk-inamtlast    = lt_vbrk-inamt.
    lt_vbrk-itdiscexlast = lt_vbrk-itdiscex.
    lt_vbrk-itdiscinlast = lt_vbrk-itdiscin.
    lt_vbrk-stnklast     = lt_vbrk-stnk.

    MOVE-CORRESPONDING lt_vbrk TO ft_tx02out.
    ft_tx02out-item     = lt_vbrk-arktx.

    CLEAR ft_tx02in.
    READ TABLE ft_tx02in WITH KEY vbeln = lt_vbrk-vbeln.
    IF sy-subrc = 0.
*      MOVE-CORRESPONDING ft_tx02in TO ft_tx02out.
      ft_tx02out-fakturno = ft_tx02in-fakturno.
      ft_tx02out-itcurr = ft_tx02in-itcurr.
    ENDIF.

    APPEND ft_tx02out.

  ENDLOOP.






ENDFUNCTION.
