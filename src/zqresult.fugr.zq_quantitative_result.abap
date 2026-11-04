FUNCTION zq_quantitative_result.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(PRUEFLOS) TYPE  QAMV-PRUEFLOS
*"     REFERENCE(VORGLFNR) TYPE  QAMV-VORGLFNR
*"     REFERENCE(MERKNR) TYPE  QAMV-MERKNR
*"     REFERENCE(STELLEN) TYPE  QAMV-STELLEN
*"     REFERENCE(CASE) TYPE  I
*"  EXPORTING
*"     REFERENCE(RESULT) TYPE  CHAR50
*"  TABLES
*"      T_QAMR STRUCTURE  QAMR
*"      T_QASE STRUCTURE  QASE
*"      T_QASR STRUCTURE  QASR
*"      T_QAPP STRUCTURE  QAPP
*"----------------------------------------------------------------------
  DATA: BEGIN OF lt_messwert OCCURS 0.
  DATA: prueflos   LIKE qase-prueflos,
        vorglfnr   LIKE qase-vorglfnr,
        merknr     LIKE qase-merknr,
        detailerg  LIKE qase-detailerg,
        messwert   LIKE qase-messwert,
        mbewertg   LIKE qase-mbewertg.
  DATA: END OF lt_messwert.

  DATA: BEGIN OF lt_minwert OCCURS 0.
  DATA: prueflos   LIKE qasr-prueflos,
        vorglfnr   LIKE qasr-vorglfnr,
        merknr     LIKE qasr-merknr,
        minwert    LIKE qasr-minwert,
        mbewertg   LIKE qasr-mbewertg.
  DATA: END OF lt_minwert.

  DATA: BEGIN OF lt_maxwert OCCURS 0.
  DATA: prueflos   LIKE qasr-prueflos,
        vorglfnr   LIKE qasr-vorglfnr,
        merknr     LIKE qasr-merknr,
        maxwert    LIKE qasr-maxwert,
        mbewertg   LIKE qasr-mbewertg.
  DATA: END OF lt_maxwert.

  DATA: BEGIN OF lt_mittelwert OCCURS 0.
  DATA: prueflos   LIKE qasr-prueflos,
        vorglfnr   LIKE qasr-vorglfnr,
        merknr     LIKE qasr-merknr,
        mittelwert LIKE qasr-mittelwert,
        mbewertg   LIKE qasr-mbewertg.
  DATA: END OF lt_mittelwert.

  DATA: fd_result(22),
        fd_result_min(22),
        fd_result_max(22),
        fd_minwert(22),
        fd_maxwert(22),
        fd_mittelwert(22),
        fd_min_mittelwert(22),
        fd_max_mittelwert(22),
        fd_record  TYPE i,
        fd_count   TYPE i.

  LOOP AT t_qase WHERE prueflos EQ prueflos AND
                       vorglfnr EQ vorglfnr AND
                       merknr   EQ merknr.
    ADD 1 TO fd_count.
    lt_messwert-prueflos   = t_qase-prueflos.
    lt_messwert-vorglfnr   = t_qase-vorglfnr.
    lt_messwert-merknr     = t_qase-merknr.
    lt_messwert-detailerg  = t_qase-detailerg.
    lt_messwert-messwert   = t_qase-messwert.
    lt_messwert-mbewertg   = t_qase-mbewertg.
    APPEND lt_messwert.
  ENDLOOP.
  IF sy-subrc EQ 0.
    IF fd_count EQ 1.
      READ TABLE lt_messwert INDEX 1.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = lt_messwert-messwert
            ivalu = 'X'
            decim = stellen
          IMPORTING
            flstr = fd_result.
        IF sy-subrc EQ 0.
          SHIFT fd_result LEFT DELETING LEADING space.
          result = fd_result.
        ENDIF.
      ENDIF.
    ELSE.
      SORT lt_messwert BY messwert.
      DESCRIBE TABLE lt_messwert LINES fd_record.
      READ TABLE lt_messwert INDEX 1.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = lt_messwert-messwert
            ivalu = 'X'
            decim = stellen
          IMPORTING
            flstr = fd_result_min.
        IF sy-subrc EQ 0.
          SHIFT fd_result_min LEFT DELETING LEADING space.
        ENDIF.
      ENDIF.
      READ TABLE lt_messwert INDEX fd_record.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = lt_messwert-messwert
            ivalu = 'X'
            decim = stellen
          IMPORTING
            flstr = fd_result_max.
        IF sy-subrc EQ 0.
          SHIFT fd_result_max LEFT DELETING LEADING space.
        ENDIF.
      ENDIF.
      IF fd_result_min EQ fd_result_max.
        result = fd_result_min.
      ELSE.
        IF fd_result_min IS INITIAL.
          result = fd_result_max.
        ELSE.
          CONCATENATE fd_result_min '-' fd_result_max INTO result
          SEPARATED BY space.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    LOOP AT t_qasr WHERE prueflos EQ prueflos AND
                         vorglfnr EQ vorglfnr AND
                         merknr   EQ merknr.

      ADD 1 TO fd_count.

      lt_minwert-prueflos   = t_qasr-prueflos.
      lt_minwert-vorglfnr   = t_qasr-vorglfnr.
      lt_minwert-merknr     = t_qasr-merknr.
      lt_minwert-minwert    = t_qasr-minwert.
      lt_minwert-mbewertg   = t_qasr-mbewertg.
      APPEND lt_minwert.

      lt_maxwert-prueflos   = t_qasr-prueflos.
      lt_maxwert-vorglfnr   = t_qasr-vorglfnr.
      lt_maxwert-merknr     = t_qasr-merknr.
      lt_maxwert-maxwert    = t_qasr-maxwert.
      lt_maxwert-mbewertg   = t_qasr-mbewertg.
      APPEND lt_maxwert.

      lt_mittelwert-prueflos   = t_qasr-prueflos.
      lt_mittelwert-vorglfnr   = t_qasr-vorglfnr.
      lt_mittelwert-merknr     = t_qasr-merknr.
      lt_mittelwert-mittelwert = t_qasr-mittelwert.
      lt_mittelwert-mbewertg   = t_qasr-mbewertg.
      APPEND lt_mittelwert.
    ENDLOOP.
    IF sy-subrc EQ 0.
      SORT lt_minwert BY minwert.
      SORT lt_maxwert BY maxwert DESCENDING.
      SORT lt_mittelwert BY mittelwert.

* Get MINWERT
      READ TABLE lt_minwert INDEX 1.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = lt_minwert-minwert
            ivalu = 'X'
            decim = stellen
          IMPORTING
            flstr = fd_minwert.
        IF sy-subrc EQ 0.
          SHIFT fd_minwert LEFT DELETING LEADING space.
        ENDIF.
      ENDIF.

* Get MAXWERT
      READ TABLE lt_maxwert INDEX 1.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = lt_maxwert-maxwert
            ivalu = 'X'
            decim = stellen
          IMPORTING
            flstr = fd_maxwert.
        IF sy-subrc EQ 0.
          SHIFT fd_maxwert LEFT DELETING LEADING space.
        ENDIF.
      ENDIF.

* Get MITTELWERT
      READ TABLE lt_mittelwert INDEX 1.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = lt_mittelwert-mittelwert
            ivalu = 'X'
            decim = stellen
          IMPORTING
            flstr = fd_min_mittelwert.
        IF sy-subrc EQ 0.
          SHIFT fd_min_mittelwert LEFT DELETING LEADING space.
        ENDIF.
      ENDIF.
      READ TABLE lt_mittelwert INDEX fd_count.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = lt_mittelwert-mittelwert
            ivalu = 'X'
            decim = stellen
          IMPORTING
            flstr = fd_max_mittelwert.
        IF sy-subrc EQ 0.
          SHIFT fd_max_mittelwert LEFT DELETING LEADING space.
        ENDIF.
      ENDIF.

      IF fd_minwert EQ fd_maxwert.
        IF fd_min_mittelwert EQ fd_max_mittelwert.
          result = fd_min_mittelwert.
        ELSE.
          CONCATENATE fd_min_mittelwert '-' fd_max_mittelwert INTO result
          SEPARATED BY space.
        ENDIF.
      ELSE.
        CONCATENATE fd_minwert '-' fd_maxwert INTO result
        SEPARATED BY space.
      ENDIF.
    ELSE.
      READ TABLE t_qamr WITH KEY prueflos = prueflos
                                 vorglfnr = vorglfnr
                                 merknr   = merknr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = t_qamr-minwert
            ivalu = 'X'
            decim = stellen
          IMPORTING
            flstr = fd_minwert.
        IF sy-subrc EQ 0.
          SHIFT fd_minwert LEFT DELETING LEADING space.
        ENDIF.
        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = t_qamr-maxwert
            ivalu = 'X'
            decim = stellen
          IMPORTING
            flstr = fd_maxwert.
        IF sy-subrc EQ 0.
          SHIFT fd_maxwert LEFT DELETING LEADING space.
        ENDIF.
        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = t_qamr-mittelwert
            ivalu = 'X'
            decim = stellen
          IMPORTING
            flstr = fd_mittelwert.
        IF sy-subrc EQ 0.
          SHIFT fd_mittelwert LEFT DELETING LEADING space.
        ENDIF.

        IF fd_minwert EQ fd_maxwert.
          result = fd_mittelwert.
        ELSE.
          CONCATENATE fd_minwert '-' fd_maxwert INTO result
          SEPARATED BY space.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFUNCTION.
