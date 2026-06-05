*----------------------------------------------------------------------*
***INCLUDE LZ_PPN11F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CALC_OLD
*&---------------------------------------------------------------------*
FORM f_calc_old  USING    fu_calty fu_datab fu_wrbtr fu_char1 fu_char2 fu_char3
                 CHANGING fc_wrbtr fc_mwskz fc_ppntx fc_ppn.
  DATA: ld_tax(3).
  CASE fu_calty.
    WHEN 'A'.
      fc_wrbtr = ( fu_wrbtr * 100 ) / ( 110 / 100 ).
    WHEN 'B'.
      fc_wrbtr = fu_wrbtr * 110 / 100.
    WHEN 'C'.
      fc_wrbtr = fu_wrbtr * 10 / 11.
    WHEN 'D'.
      fc_wrbtr = fu_wrbtr / 11.
    WHEN 'E'.
      fc_wrbtr = ( 10 / 100 ) * fu_wrbtr.
    WHEN 'F'.
      fc_wrbtr = fu_wrbtr * 10 / 100.
    WHEN 'G'.
      fc_wrbtr = ( fu_wrbtr / 11 ) * 10 .
    WHEN 'H'.
      fc_wrbtr = fu_wrbtr * ( 10 / 110 ).
    WHEN 'I'.
      fc_wrbtr = fu_wrbtr * ( 100 / 110 ).
    WHEN 'J'.
      fc_wrbtr = fu_wrbtr / ( 10 / 100 ).
    WHEN 'K'.    " Untuk Interface Sales Order dari legacy PTT khusus posting SALES
      CONDENSE: fu_char1, fu_char3.
      fc_wrbtr = fu_wrbtr *  ( fu_char1 / fu_char3 ).
    WHEN 'L'.    " Untuk Interface Sales Order dari legacy PTT
      CONDENSE fu_char3.
      ld_tax = fu_char3 - 100.
      fc_wrbtr = fu_wrbtr *  ( ld_tax / fu_char3 ).
    WHEN 'B1'.
      fc_mwskz = 'B1'.
    WHEN 'S1'.
      fc_wrbtr = fu_wrbtr * ( 10 / 1100 ).   "Untuk T-code ZS01
    WHEN 'S2'.
      fc_wrbtr = fu_wrbtr * ( 1100 / 10 ).   "Untuk T-code ZS01
    WHEN 'TC1'.
      fc_mwskz = 'K2'.
    WHEN 'TEXT'.
      fc_ppntx = '10/100'.
    WHEN 'F1'.
      fc_ppn   = '10'.
  ENDCASE.
ENDFORM.                    " F_CALC_OLD

*&---------------------------------------------------------------------*
*&      Form  F_CALC_WITH_FM
*&---------------------------------------------------------------------*
FORM f_calc_with_fm  USING    fu_bukrs fu_mwskz fu_wrbtr
                     CHANGING fc_wrbtr.

  DATA : tax_item_in  TYPE STANDARD TABLE OF rtax1u38,
         ls_in        LIKE LINE OF tax_item_in,
         tax_item_out TYPE STANDARD TABLE OF rtax1u38,
         ls_out       LIKE LINE OF tax_item_out.

  ls_in-bukrs   = fu_bukrs.
  ls_in-mwskz   = fu_mwskz.
  ls_in-waers   = 'IDR'.
  ls_in-wrbtr   = fu_wrbtr * 10.
  APPEND ls_in TO tax_item_in.

  CALL FUNCTION 'CALCULATE_TAXES_GROSS'
    TABLES
      tax_item_in             = tax_item_in
      tax_item_out            = tax_item_out
    EXCEPTIONS
      bukrs_not_found         = 1
      mwskz_not_defined       = 2
      mwskz_not_valid         = 3
      kalsm_not_found         = 4
      account_not_found       = 5
      country_not_found       = 6
      different_discount_base = 7
      different_tax_base      = 8
      txjcd_not_valid         = 9
      kalsm_not_valid         = 10
      other_error             = 11
      ktosl_not_found         = 12
      kschl_not_found         = 13
      knumh_not_found         = 14
      OTHERS                  = 15.

  READ TABLE tax_item_out INTO ls_out INDEX 1.
ENDFORM.                    " F_CALC_WITH_FM

*&---------------------------------------------------------------------*
*&      Form  F_CALC_NEW11
*&---------------------------------------------------------------------*
FORM f_calc_new11  USING    fu_calty fu_datab fu_wrbtr fu_char1 fu_char2 fu_char3
                   CHANGING fc_wrbtr fc_mwskz fc_ppntx fc_ppn.
  DATA: ld_tax(3).
  CASE fu_calty.
    WHEN 'A'.
      fc_wrbtr = ( fu_wrbtr * 100 ) / ( fu_char2 / fu_char1 ).
    WHEN 'B'.
      fc_wrbtr = fu_wrbtr * fu_char2 / fu_char1.
    WHEN 'C'.
      fc_wrbtr = fu_wrbtr * fu_char1 / fu_char2.
    WHEN 'D'.
      fc_wrbtr = ( fu_wrbtr * 10 ) / fu_char2.
    WHEN 'E'.
      fc_wrbtr = ( 11 / 100 ) * fu_wrbtr.
    WHEN 'F'.
      fc_wrbtr = fu_wrbtr * 11 / 100.
    WHEN 'G'.
      fc_wrbtr = ( fu_wrbtr / fu_char2 ) * fu_char1.
    WHEN 'H'.
      fc_wrbtr = fu_wrbtr * ( 10 / fu_char2 ).
    WHEN 'I'.
      fc_wrbtr = fu_wrbtr * ( 100 / fu_char2 ).
    WHEN 'J'.
      fc_wrbtr = fu_wrbtr / ( 11 / fu_char1 ).
    WHEN 'K'.    " Untuk Interface Sales Order dari legacy PTT khusus posting SALES
      CONDENSE: fu_char1, fu_char2.
      fc_wrbtr = fu_wrbtr *  ( fu_char1 / fu_char2 ).
    WHEN 'L'.    " Untuk Interface Sales Order dari legacy PTT
      CONDENSE fu_char2.
      ld_tax = fu_char2 - 100.
      fc_wrbtr = fu_wrbtr *  ( ld_tax / fu_char2 ).
    WHEN 'B1'.
      fc_mwskz = 'B5'.
    WHEN 'S1'.
      fc_wrbtr = fu_wrbtr * ( 10 / 1110 ).   "Untuk T-code ZS01
    WHEN 'S2'.
      fc_wrbtr = fu_wrbtr * ( 1110 / 10 ).   "Untuk T-code ZS01
    WHEN 'TC1'.
      fc_mwskz = 'K5'.
    WHEN 'TEXT'.
      fc_ppntx = '11/100'.
    WHEN 'F1'.
      fc_ppn   = '11'.
  ENDCASE.
ENDFORM.                    " F_CALC_NEW11

*&---------------------------------------------------------------------*
*&      Form  F_CALC_NEW_12
*&---------------------------------------------------------------------*
FORM f_calc_new_12  USING    fu_calty fu_datab fu_wrbtr fu_char1 fu_char2 fu_char3
                    CHANGING fc_wrbtr fc_mwskz fc_ppntx fc_ppn.
  DATA: ld_tax(3).
  DATA: lv_wrbtr    TYPE p DECIMALS 5.

  CASE fu_calty.
    WHEN 'A'.
      fc_wrbtr = ( fu_wrbtr * 100 ) / ( fu_char2 / fu_char1 ).
    WHEN 'B'.
      fc_wrbtr = fu_wrbtr * fu_char2 / fu_char1.
    WHEN 'C'.
      fc_wrbtr = fu_wrbtr * fu_char1 / fu_char2.
*      PERFORM f_round USING '-' lv_wrbtr
*                      CHANGING fc_wrbtr.
    WHEN 'D'.
      fc_wrbtr = ( fu_wrbtr * 10 ) / fu_char2.
    WHEN 'E'.
      fc_wrbtr = ( 12 / 100 ) * fu_wrbtr.
    WHEN 'F'.
      lv_wrbtr = fu_wrbtr * 12 / 100.
      PERFORM f_round USING '-' lv_wrbtr
                      CHANGING fc_wrbtr.
    WHEN 'G'.
      fc_wrbtr = ( fu_wrbtr / fu_char2 ) * fu_char1.
    WHEN 'H'.
      fc_wrbtr = fu_wrbtr * ( 10 / fu_char2 ).
    WHEN 'I'.
      fc_wrbtr = fu_wrbtr * ( 100 / fu_char2 ).
    WHEN 'J'.
      fc_wrbtr = fu_wrbtr / ( 12 / fu_char1 ).
    WHEN 'K'.    " Untuk Interface Sales Order dari legacy PTT khusus posting SALES
      CONDENSE: fu_char1, fu_char2.
      fc_wrbtr = fu_wrbtr *  ( fu_char1 / fu_char2 ).
    WHEN 'L'.    " Untuk Interface Sales Order dari legacy PTT
      CONDENSE fu_char2.
      ld_tax = fu_char2 - 100.
      fc_wrbtr = fu_wrbtr *  ( ld_tax / fu_char2 ).
    WHEN 'B1'.
      fc_mwskz = 'B2'.
    WHEN 'S1'.
      fc_wrbtr = fu_wrbtr * ( 10 / 1120 ).   "Untuk T-code ZS01
    WHEN 'S2'.
      fc_wrbtr = fu_wrbtr * ( 1120 / 10 ).   "Untuk T-code ZS01
    WHEN 'TC1'.
      fc_mwskz = 'K8'.
    WHEN 'TEXT'.
      fc_ppntx = '12/100'.
    WHEN 'F1'.
      fc_ppn   = '12'.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ROUND
*&---------------------------------------------------------------------*
FORM f_round  USING    fu_sign fu_wrbtr
              CHANGING fc_wrbtr.
  CALL FUNCTION 'ROUND'
    EXPORTING
      decimals      = 2
      input         = fu_wrbtr
      sign          = fu_sign
    IMPORTING
      output        = fc_wrbtr
    EXCEPTIONS
      input_invalid = 1
      overflow      = 2
      type_invalid  = 3
      OTHERS        = 4.
ENDFORM.
