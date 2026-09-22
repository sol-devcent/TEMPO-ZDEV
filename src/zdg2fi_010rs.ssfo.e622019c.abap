DATA: d_langu TYPE sy-langu.

CALL FUNCTION 'CONVERSION_EXIT_ISOLA_INPUT'
  EXPORTING
    input            = 'ID'
  IMPORTING
    output           = d_langu
  EXCEPTIONS
    unknown_language = 1
    OTHERS           = 2.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

CLEAR s_spell.
DATA: ld_amount(30),ld_space(2).
ld_amount = d_pswbt.
SPLIT ld_amount AT '.' INTO ld_amount ld_space.
CALL FUNCTION 'SPELL_AMOUNT'
 EXPORTING
   amount          = D_STR_AMOUNT
   currency        = s_printed-pswsl
*     FILLER          = ' '
   language        = d_langu
 IMPORTING
   in_words        = s_spell
 EXCEPTIONS
   not_found       = 1
   too_large       = 2
   OTHERS          = 3
          .





















