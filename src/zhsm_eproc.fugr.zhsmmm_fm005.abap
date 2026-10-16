FUNCTION zhsmmm_fm005.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PLANT) TYPE  WERKS_D
*"     VALUE(MATNR) TYPE  MATNR
*"     REFERENCE(TENDER) TYPE  SUBMI OPTIONAL
*"     REFERENCE(MANUAL) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(HEADER) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(DATAPR) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(DATAVENDOR) TYPE  CHAR1 OPTIONAL
*"  EXPORTING
*"     REFERENCE(DATA_FPKH) TYPE  STRING
*"     REFERENCE(FPKH_HEADER) TYPE  ZHSMMMST005
*"     REFERENCE(P_TYPE) TYPE  CHAR1
*"     REFERENCE(P_MESSAGE) TYPE  STRING
*"  TABLES
*"      DATA_PR STRUCTURE  ZHSMMMST007 OPTIONAL
*"      DATA_VENDOR STRUCTURE  ZHSMMMST008 OPTIONAL
*"----------------------------------------------------------------------
  IF header = 'X'.
    PERFORM f_get_header USING plant matnr CHANGING fpkh_header p_type p_message.
  ENDIF.
  IF datapr = 'X'.
    PERFORM f_get_datapr TABLES data_pr
                         USING plant matnr
                         CHANGING p_type p_message.
  ENDIF.
  IF datavendor = 'X'.
    PERFORM f_get_datavendor TABLES data_vendor
                         USING plant matnr
                         CHANGING p_type p_message.
  ENDIF.
ENDFUNCTION.
