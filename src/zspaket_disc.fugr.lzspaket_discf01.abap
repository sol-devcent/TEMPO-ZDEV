*----------------------------------------------------------------------*
***INCLUDE LZSPAKET_DISCF01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FETCH_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_value .
  DATA: ld_zspaket_disc LIKE zspaket_disc OCCURS 0 WITH HEADER LINE,
        ld_dd07v_tab    LIKE dd07v OCCURS 0 WITH HEADER LINE,
        ld_valpos       LIKE ld_dd07v_tab-valpos.

  SELECT * INTO TABLE ld_zspaket_disc
    FROM zspaket_disc
    WHERE ( datab LE sy-datum AND datbi GE sy-datum ).

  LOOP AT ld_zspaket_disc.
    ld_dd07v_tab-domname = 'ZPAKET'.
    ld_dd07v_tab-ddlanguage = sy-langu.
    ld_dd07v_tab-ddtext = ld_zspaket_disc-descr.

*    IF ld_zspaket_disc-kschl BETWEEN 'ZE02' AND 'ZE10'.
*      ld_dd07v_tab-domvalue_l = ld_zspaket_disc-kschl+1(3).
*    ELSEIF ld_zspaket_disc-kschl(2) = 'ZC' OR
*           ld_zspaket_disc-kschl = 'ZE01'.
      ld_dd07v_tab-domvalue_l = ld_zspaket_disc-paket.
*    ENDIF.

    COLLECT ld_dd07v_tab.
  ENDLOOP.

  SORT ld_dd07v_tab BY domvalue_l.
  DELETE ADJACENT DUPLICATES FROM ld_dd07v_tab COMPARING domvalue_l.

  SORT ld_dd07v_tab BY domvalue_l.
  LOOP AT ld_dd07v_tab.
    ADD 1 TO ld_valpos.
    ld_dd07v_tab-valpos = ld_valpos.
    MODIFY ld_dd07v_tab TRANSPORTING valpos.
  ENDLOOP.

  CALL FUNCTION 'DDIF_DOMA_PUT'
    EXPORTING
      name      = 'ZPAKET'
    TABLES
      dd07v_tab = ld_dd07v_tab.
  IF sy-subrc = 0.
    CALL FUNCTION 'DDIF_DOMA_ACTIVATE'
      EXPORTING
        name = 'ZPAKET'.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDFORM.                    " FETCH_VALUE
