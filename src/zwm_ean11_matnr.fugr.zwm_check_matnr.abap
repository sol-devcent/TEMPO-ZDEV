FUNCTION zwm_check_matnr.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_CHUMAT) TYPE  RLMOB-CHUMAT
*"     VALUE(PI_MATNR) TYPE  MARA-MATNR OPTIONAL
*"  EXPORTING
*"     VALUE(PE_MATNR) TYPE  MARA-MATNR
*"     VALUE(PE_CHARG) TYPE  MCH1-CHARG
*"     VALUE(PE_BATCH) TYPE  CHAR1
*"----------------------------------------------------------------------

  DATA : lv_matnr     TYPE mara-matnr,
         lv_charg     TYPE mch1-charg.

  DATA : lt_mara      TYPE STANDARD TABLE OF mara,
         ls_mara      LIKE LINE OF lt_mara,
         lt_mean      TYPE STANDARD TABLE OF mean,
         ls_mean      LIKE LINE OF lt_mean.

  DATA : lr_matnr     TYPE RANGE OF matnr,
         ls_matnr     LIKE LINE OF lr_matnr.

  FIND REGEX ';' IN pi_chumat.

  IF sy-subrc = 0.
    SPLIT pi_chumat AT ';' INTO lv_matnr lv_charg.
    pe_charg = lv_charg.
    pe_batch = 'X'.
  ELSE.
    lv_matnr = pi_chumat.
  ENDIF.

  CONCATENATE lv_matnr '*' INTO ls_matnr-low.
  ls_matnr-sign   = 'I'.
  ls_matnr-option = 'CP'.
  APPEND ls_matnr TO lr_matnr.

  SELECT *
    FROM mara
    INTO CORRESPONDING FIELDS OF TABLE lt_mara
    WHERE ean11 IN lr_matnr.
  IF sy-subrc = 0.
    CLEAR ls_mara.
    READ TABLE lt_mara INTO ls_mara
                       WITH KEY matnr = pi_matnr.
    IF sy-subrc = 0.
      pe_matnr = ls_mara-matnr.
    ELSE.
      CLEAR ls_mara.
      READ TABLE lt_mara INTO ls_mara INDEX 1.
      IF sy-subrc = 0.
        pe_matnr = ls_mara-matnr.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pe_matnr IS INITIAL.
    SELECT *
      FROM mean
      INTO CORRESPONDING FIELDS OF TABLE lt_mean
      WHERE ean11 IN lr_matnr.
    IF sy-subrc = 0.
      CLEAR ls_mean.
      READ TABLE lt_mean INTO ls_mean
                         WITH KEY matnr = pi_matnr.
      IF sy-subrc = 0.
        pe_matnr = ls_mean-matnr.
      ELSE.
        CLEAR ls_mean.
        READ TABLE lt_mean INTO ls_mean INDEX 1.
        IF sy-subrc = 0.
          pe_matnr = ls_mean-matnr.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pe_matnr IS INITIAL.
    CONCATENATE 'J' lv_matnr '*' INTO ls_matnr-low.
    ls_matnr-sign   = 'I'.
    ls_matnr-option = 'CP'.
    APPEND ls_matnr TO lr_matnr.
    CONCATENATE 'J0' lv_matnr '*' INTO ls_matnr-low.
    ls_matnr-sign   = 'I'.
    ls_matnr-option = 'CP'.
    APPEND ls_matnr TO lr_matnr.
    CONCATENATE 'JZ' lv_matnr '*' INTO ls_matnr-low.
    ls_matnr-sign   = 'I'.
    ls_matnr-option = 'CP'.
    APPEND ls_matnr TO lr_matnr.

    SELECT *
      FROM mean
      INTO CORRESPONDING FIELDS OF TABLE lt_mean
      WHERE ean11 IN lr_matnr.
    IF sy-subrc = 0.
      CLEAR ls_mean.
      READ TABLE lt_mean INTO ls_mean
                         WITH KEY matnr = pi_matnr.
      IF sy-subrc = 0.
        pe_matnr = ls_mean-matnr.
      ELSE.
        CLEAR ls_mean.
        READ TABLE lt_mean INTO ls_mean INDEX 1.
        IF sy-subrc = 0.
          pe_matnr = ls_mean-matnr.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pe_matnr IS INITIAL.
    pe_matnr   = lv_matnr.
  ENDIF.
ENDFUNCTION.
