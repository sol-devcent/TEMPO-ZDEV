FUNCTION zqmmatnr_factor.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MATNR) TYPE  MATNR OPTIONAL
*"     VALUE(I_CHARG) TYPE  CHARG_D OPTIONAL
*"     VALUE(I_WERKS) TYPE  WERKS_D OPTIONAL
*"     VALUE(I_TEXT) TYPE  BAPI2045L2-TXT_OPER OPTIONAL
*"     VALUE(I_INSPOPER) TYPE  BAPI2045L2-INSPOPER OPTIONAL
*"  EXPORTING
*"     VALUE(E_MEAN_VALUE) TYPE  QMEAN_VAL
*"----------------------------------------------------------------------
  DATA : lt_qals  TYPE STANDARD TABLE OF qals,
         ls_qals  LIKE LINE OF lt_qals,
         lr_qherk TYPE RANGE OF qherk,
         ls_qherk LIKE LINE OF lr_qherk,
         lr_stat  TYPE RANGE OF j_status,
         ls_stat  LIKE LINE OF lr_stat,
         lt_jest  TYPE STANDARD TABLE OF jest,
         ls_jest  LIKE LINE OF lt_jest.

  DATA : inspoper_list     TYPE STANDARD TABLE OF bapi2045l2,
         ls_list           LIKE LINE OF inspoper_list,
         insppoints        TYPE STANDARD TABLE OF bapi2045l4,
         char_requirements TYPE STANDARD TABLE OF bapi2045d1,
         char_results      TYPE STANDARD TABLE OF bapi2045d2,
         sample_results    TYPE STANDARD TABLE OF bapi2045d3,
         single_results    TYPE STANDARD TABLE OF bapi2045d4.

  DATA : ls_results      LIKE LINE OF char_results,
         ls_requirements LIKE LINE OF char_requirements.

  DATA : lv_mstr_char TYPE bapi2045d1-mstr_char,
         lv_subrc     TYPE sy-subrc.

  ls_qherk-low    = '01'.
  ls_qherk-sign   = 'I'.
  ls_qherk-option = 'EQ'.
  APPEND ls_qherk TO lr_qherk.
  CLEAR ls_qherk.
  ls_qherk-low    = '09'.
  ls_qherk-sign   = 'I'.
  ls_qherk-option = 'EQ'.
  APPEND ls_qherk TO lr_qherk.
  CLEAR ls_qherk.

  ls_stat-low     = 'I0224'.
  ls_stat-sign    = 'I'.
  ls_stat-option  = 'EQ'.
  APPEND ls_stat TO lr_stat.
  CLEAR ls_stat.
  ls_stat-low     = 'I0043'.
  ls_stat-sign    = 'I'.
  ls_stat-option  = 'EQ'.
  APPEND ls_stat TO lr_stat.
  CLEAR ls_stat.

  SELECT *
    FROM qals
    INTO CORRESPONDING FIELDS OF TABLE lt_qals
    WHERE matnr    = i_matnr
      AND charg    = i_charg
      AND werk     = i_werks
      AND herkunft IN lr_qherk.

  IF lt_qals[] IS NOT INITIAL.
    SELECT *
      FROM jest
      INTO CORRESPONDING FIELDS OF TABLE lt_jest
      FOR ALL ENTRIES IN lt_qals
        WHERE objnr = lt_qals-objnr
          AND stat  IN lr_stat
          AND inact = space.
  ENDIF.

  LOOP AT lt_qals INTO ls_qals.
    READ TABLE lt_jest INTO ls_jest
                       WITH KEY objnr = ls_qals-objnr.
    IF sy-subrc = 0.
      DELETE TABLE lt_qals FROM ls_qals.
    ENDIF.
  ENDLOOP.

  SORT lt_qals BY herkunft enstehdat DESCENDING entstezeit DESCENDING.

*  IF i_inspoper = '0060'.
  IF i_text(10) = 'Berat Rata'.
    CLEAR ls_qals.
    READ TABLE lt_qals INTO ls_qals
                       WITH KEY herkunft = '01'.
    IF sy-subrc = 0.
      CLEAR : ls_jest.
      READ TABLE lt_jest INTO ls_jest
                         WITH KEY objnr = ls_qals-objnr.
    ELSE.
      CLEAR ls_qals.
    ENDIF.
  ELSE.
    CLEAR ls_qals.
    READ TABLE lt_qals INTO ls_qals
                       WITH KEY herkunft = '09'.
    IF sy-subrc = 0.
      CLEAR : ls_jest.
      READ TABLE lt_jest INTO ls_jest
                         WITH KEY objnr = ls_qals-objnr.
      IF sy-subrc = 0.
        CLEAR ls_qals.
        READ TABLE lt_qals INTO ls_qals
                           WITH KEY herkunft = '01'.
        IF sy-subrc = 0.
          CLEAR : ls_jest.
          READ TABLE lt_jest INTO ls_jest
                             WITH KEY objnr = ls_qals-objnr.
        ELSE.
          CLEAR ls_qals.
        ENDIF.
      ENDIF.
    ELSE.
      CLEAR ls_qals.
      READ TABLE lt_qals INTO ls_qals
                         WITH KEY herkunft = '01'.
      IF sy-subrc = 0.
        CLEAR : ls_jest.
        READ TABLE lt_jest INTO ls_jest
                           WITH KEY objnr = ls_qals-objnr.
      ELSE.
        CLEAR ls_qals.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ls_qals IS NOT INITIAL.
    CALL FUNCTION 'BAPI_INSPLOT_GETOPERATIONS'
      EXPORTING
        number        = ls_qals-prueflos
      TABLES
        inspoper_list = inspoper_list.

    CLEAR ls_list.
***    IF i_matnr = 'R0746'.
***      READ TABLE inspoper_list INTO ls_list
***                               WITH KEY inspoper = '0010'.
***    ELSE.
***      READ TABLE inspoper_list INTO ls_list
***                               WITH KEY txt_oper = 'Faktorisasi pada Kadar'.
***    ENDIF.

    IF i_text IS INITIAL.
      i_text  = 'Faktorisasi pada Kadar'.
    ENDIF.
    IF i_inspoper IS INITIAL.
      i_inspoper = '0010'.
    ENDIF.

    IF i_werks = '0901'.
      DATA(lv_text) = i_text.
      TRANSLATE lv_text TO UPPER CASE.
      CONDENSE lv_text NO-GAPS.
      i_text = lv_text.

      IF inspoper_list[] IS NOT INITIAL.
        LOOP AT inspoper_list ASSIGNING FIELD-SYMBOL(<fs_inspoper_list>).
          DATA(lv_txt_oper) = <fs_inspoper_list>-txt_oper.
          TRANSLATE lv_txt_oper TO UPPER CASE.
          CONDENSE lv_txt_oper NO-GAPS.
          IF lv_txt_oper = i_text.
            <fs_inspoper_list>-txt_oper = lv_txt_oper.
          ENDIF.
          CLEAR lv_txt_oper.
        ENDLOOP.
      ENDIF.
    ENDIF.

    READ TABLE inspoper_list INTO ls_list
                             WITH KEY txt_oper = i_text.
    lv_subrc = sy-subrc.
    IF sy-subrc <> 0.
      READ TABLE inspoper_list INTO ls_list
                               WITH KEY inspoper = i_inspoper.
      lv_subrc = sy-subrc.
    ENDIF.

    IF lv_subrc = 0.
      CALL FUNCTION 'BAPI_INSPOPER_GETDETAIL'
        EXPORTING
          insplot                = ls_qals-prueflos
          inspoper               = ls_list-inspoper
          read_char_results      = 'X'
          read_char_requirements = 'X'
        TABLES
          char_results           = char_results
          char_requirements      = char_requirements.

      IF sy-subrc = 0.
        CASE i_werks.
          WHEN '0101'.
            lv_mstr_char = 'QAL00412'.
          WHEN '0102'.
            lv_mstr_char = 'QAL00811'.
          WHEN '0901'.
            CASE sy-sysid.
              WHEN 'DEV'.
                lv_mstr_char = 'QAL00811'.
              WHEN 'P01'.
                lv_mstr_char = 'QAL00376'.
              WHEN OTHERS.
            ENDCASE.
        ENDCASE.

*        IF i_text = 'Berat Rata – Rata'.
        IF i_text(10) = 'Berat Rata'.
          CLEAR : lv_mstr_char.
        ENDIF.

        CLEAR ls_requirements.
        READ TABLE char_requirements INTO ls_requirements
                                     WITH KEY insplot   = ls_list-insplot
                                              inspoper  = ls_list-inspoper
                                              mstr_char = lv_mstr_char.
        IF sy-subrc = 0.
          CLEAR ls_results.
          READ TABLE char_results INTO ls_results
                                  WITH KEY insplot   = ls_list-insplot
                                           inspoper  = ls_list-inspoper
                                           inspchar  = ls_requirements-inspchar.
          IF sy-subrc = 0.
            IF ls_results-mean_value IS INITIAL.
              LOOP AT char_results INTO ls_results
                                   WHERE insplot   = ls_list-insplot
                                     AND inspoper  = ls_list-inspoper
                                     AND inspchar  NE ls_requirements-inspchar.
                IF ls_results-mean_value IS NOT INITIAL.
                  EXIT.
                ENDIF.
              ENDLOOP.
            ENDIF.
            e_mean_value = ls_results-mean_value.
            CONDENSE e_mean_value.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFUNCTION.
