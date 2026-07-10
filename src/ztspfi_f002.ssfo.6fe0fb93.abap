DATA in_words TYPE spell.
DATA l_totamt TYPE ztotamt.

*CASE header-waers.
*  WHEN 'IDR'.
*    l_totamt = header-totamt / 100.
*  WHEN OTHERS.
*    l_totamt = header-totamt.
*ENDCASE.

CALL FUNCTION 'SPELL_AMOUNT'
 EXPORTING
   amount          = header-totamt  "l_totamt
   currency        = header-waers
*       FILLER          = ' '
   language        = 'i'
 IMPORTING
   in_words        = in_words
 EXCEPTIONS
   not_found       = 1
   too_large       = 2
   OTHERS          = 3.

IF sy-subrc = 0.
*  MOVE in_words-word TO gv_say.
*  CONDENSE gv_say.

  IF in_words-decword IS INITIAL OR
     in_words-decword = 'NOL'.
    CONCATENATE in_words-word header-waers INTO gv_say
      SEPARATED BY '  '.
  ELSE.
    CONCATENATE in_words-word 'KOMA' in_words-decword
      header-waers INTO gv_say SEPARATED BY '  '.
  ENDIF.
ENDIF.












