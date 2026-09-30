FUNCTION zwmfm010.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_SETNAME) TYPE  STRING
*"     VALUE(PI_LGNUM) TYPE  LTAK-LGNUM
*"     VALUE(PI_LZNUM) TYPE  LTAK-LZNUM
*"     VALUE(PI_USERNAME) TYPE  LRF_WKQU-BNAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(PE_ENTITY) TYPE  ZWMST009
*"     REFERENCE(PE_SUBRC) TYPE  SY-SUBRC
*"  TABLES
*"      PT_ENTITY STRUCTURE  ZWMST009 OPTIONAL
*"----------------------------------------------------------------------
  DATA : ls_lrf_wkqu TYPE lrf_wkqu,
         lr_queue    TYPE RANGE OF queue,
         ls_queue    LIKE LINE OF lr_queue.

  DATA : lv_length    TYPE i.

  lv_length = strlen( pi_lznum ).
  IF lv_length = 10.
    PERFORM f_get_check_single TABLES pt_entity
                               USING pi_setname pi_lgnum pi_lznum pi_username ''
                               CHANGING pe_entity pe_subrc.
  ELSEIF lv_length = 0.
    SELECT SINGLE *
      FROM lrf_wkqu
      INTO CORRESPONDING FIELDS OF ls_lrf_wkqu
      WHERE bname = pi_username
        AND statu = 'X'.

    ls_queue-low    = '*CL'.
    ls_queue-sign   = 'I'.
    ls_queue-option = 'CP'.
    APPEND ls_queue TO lr_queue.
    ls_queue-low    = '*AC'.
    APPEND ls_queue TO lr_queue.

    IF ls_lrf_wkqu-queue CP '*CHECKER*'.
      IF ls_lrf_wkqu-queue IN lr_queue.
        PERFORM f_get_check_group  TABLES pt_entity
                                   USING pi_setname ls_lrf_wkqu-lgnum '' pi_username
                                         ls_lrf_wkqu-queue
                                   CHANGING pe_entity pe_subrc.
      ELSE.
        PERFORM f_get_check_single TABLES pt_entity
                                   USING pi_setname ls_lrf_wkqu-lgnum '' pi_username
                                         ls_lrf_wkqu-queue
                                   CHANGING pe_entity pe_subrc.
      ENDIF.
    ENDIF.
  ELSEIF lv_length = 15.
    PERFORM f_get_check_group  TABLES pt_entity
                               USING pi_setname pi_lgnum pi_lznum pi_username ''
                               CHANGING pe_entity pe_subrc.
  ENDIF.
ENDFUNCTION.
