REPORT zf_konfirmasi_tagihan MESSAGE-ID zf NO STANDARD PAGE HEADING
                                  LINE-COUNT 60
                                  LINE-SIZE  253.

*Declaration
TABLES: knvv,bsid,kna1,knb1,sscrfields.

DATA: BEGIN OF it_bsid OCCURS 0,
        bukrs LIKE bsid-bukrs,        " Company Code
        vkbur LIKE knvv-vkbur,        " Business Area
        kunnr LIKE bsid-kunnr,        " Cust code
        gtext LIKE tgsbt-gtext,
        name1 LIKE kna1-name1,        " Cust Name
        name2 LIKE kna1-name2,
        ort01 LIKE kna1-ort01,
        pstlz LIKE kna1-pstlz,
        gjahr LIKE bsid-gjahr,        " Fiscal Year
        belnr LIKE bsid-belnr,        " Document No
        budat LIKE bsid-budat,        " Posting Date
        augdt LIKE bsid-augdt,        " Clearing date.
        monat LIKE bsid-monat,        " Periode
        bschl LIKE bsid-bschl,        " Posting Key
        dmbtr LIKE bsid-dmbtr,        " Amount in local curr
        shkzg LIKE bsid-shkzg,        " Debit/Credit indicator.
        zfbdt LIKE bsid-zfbdt,        " Baseline Date
        zbd1t LIKE bsid-zbd1t,        " Term of payment
        blart LIKE bsid-blart,        " Document Type
        zuonr LIKE bsid-zuonr,        " Do Number
        xref1 LIKE bsid-xref1,        " Route List
        xref2 LIKE bsid-xref2,        " Salesman Code
        kdgrp LIKE knvv-kdgrp,        " Customer Group
        umskz LIKE bsid-umskz,        " Special G/L Indicator
        sortl LIKE kna1-sortl,
        slcode(6),
        zterm LIKE knb1-zterm,
        bldat LIKE bsid-bldat,
        sgtxt LIKE bsid-sgtxt,
        waers LIKE bsid-waers,
        augbl LIKE bsid-augbl,
        sknto LIKE bsid-sknto,
        skfbt LIKE bsid-skfbt,
        sspdt LIKE bsid-bldat,
        budat1 LIKE bsid-budat,        " Pay Date
        bldat1 LIKE bsid-bldat,
      END OF it_bsid.

DATA: BEGIN OF i_keycustomer OCCURS 0,
        bukrs LIKE bsid-bukrs,        " Company Code
        vkbur LIKE knvv-vkbur,        " Business Area
        kunnr LIKE bsid-kunnr,        " Cust code
      END OF i_keycustomer.

DATA: BEGIN OF i_customer OCCURS 0,
        kunnr LIKE kna1-kunnr,        " Cust code
        name1 LIKE kna1-name1,        " Cust Name
        name2 LIKE kna1-name2,
        ort01 LIKE kna1-ort01,
        pstlz LIKE kna1-pstlz,
        sortl LIKE kna1-sortl,
      END OF i_customer.

DATA: BEGIN OF i_tgsbt OCCURS 0,
        gsber LIKE tgsbt-gsber,
        gtext LIKE tgsbt-gtext,
      END OF i_tgsbt.

DATA: char4(4),
      char6(6),
      it_bsid_dz LIKE it_bsid OCCURS 0 WITH HEADER LINE,
      it_bsid_rv LIKE it_bsid OCCURS 0 WITH HEADER LINE,
      i_output LIKE it_bsid OCCURS 0 WITH HEADER LINE,
      i_header LIKE it_bsid OCCURS 0 WITH HEADER LINE,
      i_detail LIKE it_bsid OCCURS 0 WITH HEADER LINE.

*Include
INCLUDE zghmmalv001.        "ALV

*General Selection
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS:
  pa_bukrs LIKE bsid-bukrs DEFAULT '8020' OBLIGATORY.
SELECT-OPTIONS:
  so_vkbur FOR knvv-vkbur OBLIGATORY,
  so_budat FOR bsid-budat,
  so_kdgrp FOR knvv-kdgrp,
  so_xref1 FOR char4,
  so_xref2 FOR char6,
*  so_pernr FOR knb1-pernr,
  so_zuonr FOR bsid-zuonr,
  so_kunnr FOR bsid-kunnr,
  so_sspdt FOR bsid-budat OBLIGATORY.
*PARAMETERS:
*  pa_budat LIKE bsid-budat DEFAULT sy-datum OBLIGATORY.
SELECTION-SCREEN END OF BLOCK block1.

*Display Variant
SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE text-003.
PARAMETERS: x_norm LIKE itemset-xnorm AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS  x_shbv LIKE itemset-xshbv AS CHECKBOX.
SELECTION-SCREEN : COMMENT 4(24) text-014 FOR FIELD x_shbv.
SELECTION-SCREEN:  POSITION 30.
SELECT-OPTIONS: s_bschl FOR bsid-umskz NO INTERVALS.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block2.

*Display Variant
SELECTION-SCREEN BEGIN OF BLOCK block3 WITH FRAME TITLE text-004.
PARAMETERS: p_vari  LIKE disvariant-variant. " ALV Variant
SELECTION-SCREEN END OF BLOCK block3.

* AT s_bschl
AT SELECTION-SCREEN ON s_bschl.
  IF x_shbv = 'X' AND s_bschl IS INITIAL.
    s_bschl-low = 'T'.
    s_bschl-sign = 'I'.
    s_bschl-option = 'EQ'.
    APPEND s_bschl.
  ENDIF.

* for alv variant
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f_f4_for_variant_alv USING p_vari.

*Process Selection
START-OF-SELECTION.

  PERFORM f_cek_authority.
  PERFORM f_get_data.
  PERFORM f_process_data.

  IF it_bsid_dz[] IS INITIAL.
    MESSAGE s001(zf).
    STOP.
  ENDIF.

  i_header[] = it_bsid_dz[].
  i_detail[] = it_bsid_dz[].
  SORT i_header BY bukrs vkbur kunnr.
  SORT i_detail BY bukrs vkbur kunnr zuonr bldat DESCENDING.
  DELETE ADJACENT DUPLICATES FROM i_header COMPARING bukrs vkbur kunnr.
  DELETE ADJACENT DUPLICATES FROM i_detail COMPARING bukrs vkbur kunnr zuonr.
  CLEAR: it_bsid,it_bsid_dz,it_bsid_rv.
  REFRESH: it_bsid,it_bsid_dz,it_bsid_rv.

  PERFORM f_print_data.

*&---------------------------------------------------------------------*
*&      Form  f_f4_for_variant_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_VARI  text
*----------------------------------------------------------------------*
FORM f_f4_for_variant_alv USING fc_variant.

  DATA: ld_variant LIKE disvariant.
  DATA: ld_repid   LIKE sy-repid.
  ld_repid = sy-repid.
  ld_variant-report   = ld_repid.
  ld_variant-username = sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = ld_variant
      i_save     = 'A'
    IMPORTING
      es_variant = ld_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    fc_variant = ld_variant-variant.
  ENDIF.

ENDFORM.                    " f_f4_for_variant_alv

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.

  IF x_norm EQ 'X' AND x_shbv EQ 'X'.
    SELECT a~bukrs a~kunnr a~gjahr a~belnr a~budat a~monat a~bschl
           a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2
           a~umskz a~bldat a~xref1 a~sgtxt a~waers a~augbl a~sknto
           a~zterm a~skfbt b~vkbur b~kdgrp
    INTO CORRESPONDING FIELDS OF TABLE it_bsid
    FROM bsid AS a JOIN  knvv AS b ON b~kunnr EQ a~kunnr AND
                                      b~vkorg EQ a~bukrs AND
                                      b~vtweg EQ '10'    AND
                                      b~spart EQ '00'
    WHERE a~bukrs EQ pa_bukrs  AND
          a~blart IN ('DZ','RV') AND
          a~umskz EQ space     AND
          a~budat IN so_budat  AND
          a~kunnr IN so_kunnr  AND
          a~zuonr IN so_zuonr  AND
          b~vkbur IN so_vkbur  AND
          b~kdgrp IN so_kdgrp.

    SELECT a~bukrs a~kunnr a~gjahr a~belnr a~budat a~monat a~bschl
           a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2
           a~umskz a~bldat a~xref1 a~sgtxt a~waers a~augbl a~sknto
           a~zterm a~skfbt b~vkbur b~kdgrp
    APPENDING CORRESPONDING FIELDS OF TABLE it_bsid
    FROM bsad AS a JOIN  knvv AS b ON b~kunnr EQ a~kunnr AND
                                      b~vkorg EQ a~bukrs AND
                                      b~vtweg EQ '10'    AND
                                      b~spart EQ '00'
    WHERE a~bukrs EQ pa_bukrs  AND
          a~blart IN ('DZ','RV') AND
          a~umskz EQ space     AND
          a~budat IN so_budat  AND
          a~kunnr IN so_kunnr  AND
          a~zuonr IN so_zuonr  AND
          b~vkbur IN so_vkbur  AND
          b~kdgrp IN so_kdgrp.

    SELECT a~bukrs a~kunnr a~gjahr a~belnr a~budat a~monat a~bschl
           a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2
           a~umskz a~bldat a~xref1 a~sgtxt a~waers a~augbl a~sknto
           a~zterm a~skfbt b~vkbur b~kdgrp
    APPENDING CORRESPONDING FIELDS OF TABLE it_bsid
    FROM bsid AS a JOIN  knvv AS b ON b~kunnr EQ a~kunnr AND
                                      b~vkorg EQ a~bukrs AND
                                      b~vtweg EQ '10'    AND
                                      b~spart EQ '00'
    WHERE a~bukrs EQ pa_bukrs  AND
          a~blart IN ('DZ','RV') AND
          a~umskz IN s_bschl   AND
          a~budat IN so_budat  AND
          a~kunnr IN so_kunnr  AND
          a~zuonr IN so_zuonr  AND
          b~vkbur IN so_vkbur  AND
          b~kdgrp IN so_kdgrp.

    SELECT a~bukrs a~kunnr a~gjahr a~belnr a~budat a~monat a~bschl
           a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2
           a~umskz a~bldat a~xref1 a~sgtxt a~waers a~augbl a~sknto
           a~zterm a~skfbt b~vkbur b~kdgrp
    APPENDING CORRESPONDING FIELDS OF TABLE it_bsid
    FROM bsad AS a JOIN  knvv AS b ON b~kunnr EQ a~kunnr AND
                                      b~vkorg EQ a~bukrs AND
                                      b~vtweg EQ '10'    AND
                                      b~spart EQ '00'
    WHERE a~bukrs EQ pa_bukrs  AND
          a~blart IN ('DZ','RV') AND
          a~umskz IN s_bschl   AND
          a~budat IN so_budat  AND
          a~kunnr IN so_kunnr  AND
          a~zuonr IN so_zuonr  AND
          b~vkbur IN so_vkbur  AND
          b~kdgrp IN so_kdgrp.
  ENDIF.

  IF x_norm EQ 'X' AND x_shbv EQ space.
    SELECT a~bukrs a~kunnr a~gjahr a~belnr a~budat a~monat a~bschl
           a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2
           a~umskz a~bldat a~xref1 a~sgtxt a~waers a~augbl a~sknto
           a~zterm a~skfbt b~vkbur b~kdgrp
    INTO CORRESPONDING FIELDS OF TABLE it_bsid
    FROM bsid AS a JOIN  knvv AS b ON b~kunnr EQ a~kunnr AND
                                      b~vkorg EQ a~bukrs AND
                                      b~vtweg EQ '10'    AND
                                      b~spart EQ '00'
    WHERE a~bukrs EQ pa_bukrs  AND
          a~blart IN ('DZ','RV') AND
          a~umskz EQ space     AND
          a~budat IN so_budat  AND
          a~kunnr IN so_kunnr  AND
          a~zuonr IN so_zuonr  AND
          b~vkbur IN so_vkbur  AND
          b~kdgrp IN so_kdgrp.

    SELECT a~bukrs a~kunnr a~gjahr a~belnr a~budat a~monat a~bschl
           a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2
           a~umskz a~bldat a~xref1 a~sgtxt a~waers a~augbl a~sknto
           a~zterm a~skfbt b~vkbur b~kdgrp
    APPENDING CORRESPONDING FIELDS OF TABLE it_bsid
    FROM bsad AS a JOIN  knvv AS b ON b~kunnr EQ a~kunnr AND
                                      b~vkorg EQ a~bukrs AND
                                      b~vtweg EQ '10'    AND
                                      b~spart EQ '00'
    WHERE a~bukrs EQ pa_bukrs  AND
          a~blart IN ('DZ','RV') AND
          a~umskz EQ space     AND
          a~budat IN so_budat  AND
          a~kunnr IN so_kunnr  AND
          a~zuonr IN so_zuonr  AND
          b~vkbur IN so_vkbur  AND
          b~kdgrp IN so_kdgrp.
  ENDIF.

  IF x_norm EQ space AND x_shbv EQ 'X'.
    SELECT a~bukrs a~kunnr a~gjahr a~belnr a~budat a~monat a~bschl
           a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2
           a~umskz a~bldat a~xref1 a~sgtxt a~waers a~augbl a~sknto
           a~zterm a~skfbt b~vkbur b~kdgrp
    INTO CORRESPONDING FIELDS OF TABLE it_bsid
    FROM bsid AS a JOIN  knvv AS b ON b~kunnr EQ a~kunnr AND
                                      b~vkorg EQ a~bukrs AND
                                      b~vtweg EQ '10'    AND
                                      b~spart EQ '00'
    WHERE a~bukrs EQ pa_bukrs  AND
          a~blart IN ('DZ','RV') AND
          a~umskz IN s_bschl   AND
          a~budat IN so_budat  AND
          a~kunnr IN so_kunnr  AND
          a~zuonr IN so_zuonr  AND
          b~vkbur IN so_vkbur  AND
          b~kdgrp IN so_kdgrp.

    SELECT a~bukrs a~kunnr a~gjahr a~belnr a~budat a~monat a~bschl
           a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2
           a~umskz a~bldat a~xref1 a~sgtxt a~waers a~augbl a~sknto
           a~zterm a~skfbt b~vkbur b~kdgrp
    APPENDING CORRESPONDING FIELDS OF TABLE it_bsid
    FROM bsad AS a JOIN  knvv AS b ON b~kunnr EQ a~kunnr AND
                                      b~vkorg EQ a~bukrs AND
                                      b~vtweg EQ '10'    AND
                                      b~spart EQ '00'
    WHERE a~bukrs EQ pa_bukrs  AND
          a~blart IN ('DZ','RV') AND
          a~umskz IN s_bschl   AND
          a~budat IN so_budat  AND
          a~kunnr IN so_kunnr  AND
          a~zuonr IN so_zuonr  AND
          b~vkbur IN so_vkbur  AND
          b~kdgrp IN so_kdgrp.
  ENDIF.

  it_bsid_dz[] = it_bsid_rv[] = it_bsid[].
  DELETE it_bsid_dz WHERE blart NE 'DZ'.
  DELETE it_bsid_rv WHERE blart NE 'RV'.

  i_keycustomer[] = it_bsid_dz[].
  SORT i_keycustomer BY bukrs vkbur kunnr.
  DELETE ADJACENT DUPLICATES FROM i_keycustomer COMPARING bukrs vkbur kunnr.

  IF i_keycustomer[] IS INITIAL.
    MESSAGE s001(zf).
    STOP.
  ELSE.
    SELECT gsber gtext
      FROM tgsbt
      INTO CORRESPONDING FIELDS OF TABLE i_tgsbt
      WHERE spras = sy-langu AND
            gsber IN so_vkbur.

    SELECT kunnr name1 name2 ort01 pstlz sortl
      FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE i_customer
      FOR ALL ENTRIES IN i_keycustomer
      WHERE kunnr = i_keycustomer-kunnr.
  ENDIF.

ENDFORM.                    " f_get_data
*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.

  DATA : l_str TYPE i,
         l_count TYPE i,
         l_tmp(6) TYPE n,
         l_tmp1(4) TYPE n,
         l_live LIKE zplbc-live,
         lw_kna1 LIKE i_customer,
         lw_tgsbt LIKE i_tgsbt.

  SORT it_bsid_dz BY bukrs vkbur kunnr.
  SORT i_customer BY kunnr.
  SORT i_tgsbt BY gsber.

*Completed it_bsid_dz
  LOOP AT it_bsid_dz.

*    CALL FUNCTION 'Z_CALC_DATE'            "Hitung tanggal 1 bulan 7 hari
*      EXPORTING
*        date      = it_bsid_dz-bldat
*        days      = '07'
*        months    = '01'
*        sign      = '+'
*        years     = '00'
*      IMPORTING
*        calc_date = it_bsid_dz-sspdt.

    CALL FUNCTION 'CALCULATE_DATE'          "Hitung tanggal 7 bulan berikutnya
      EXPORTING
*        DAYS              = '0'
        MONTHS            = '1'
        START_DATE        = it_bsid_dz-bldat
      IMPORTING
        RESULT_DATE       = it_bsid_dz-sspdt.
    it_bsid_dz-sspdt+6(2) = '07'.

    IF NOT it_bsid_dz-sspdt IN so_sspdt.
      DELETE it_bsid_dz.
      CONTINUE.
    ENDIF.

    l_str = STRLEN( it_bsid_dz-xref2 ).
    IF l_str <= 6.
      l_tmp = it_bsid_dz-xref2.
      it_bsid_dz-xref2 = l_tmp.
    ELSE.
      l_count = l_str - 6.
      it_bsid_dz-xref2 = it_bsid_dz-xref2+l_count(6).
    ENDIF.
    l_str = STRLEN( it_bsid_dz-xref1 ).
    IF l_str <= 4.
      l_tmp1 = it_bsid_dz-xref1.
      it_bsid_dz-xref1 = l_tmp1.
    ELSE.
      l_count = l_str - 4.
      it_bsid_dz-xref1 = it_bsid_dz-xref1+l_count(4).
    ENDIF.
    it_bsid_dz-slcode = it_bsid_dz-xref2.

    IF NOT it_bsid_dz-xref1(4) IN so_xref1.
      DELETE it_bsid_dz.
      CONTINUE.
    ENDIF.

    IF NOT it_bsid_dz-slcode IN so_xref2.
      DELETE it_bsid_dz.
      CONTINUE.
    ENDIF.

    IF it_bsid_dz-vkbur EQ space.
      it_bsid_dz-vkbur = '0200'.
    ENDIF.

    IF it_bsid_dz-vkbur NE lw_tgsbt-gsber.
      CLEAR lw_tgsbt.
      READ TABLE i_tgsbt WITH KEY gsber = it_bsid_dz-vkbur INTO lw_tgsbt BINARY SEARCH.
      it_bsid_dz-gtext = lw_tgsbt-gtext.
    ELSE.
      it_bsid_dz-gtext = lw_tgsbt-gtext.
    ENDIF.

    IF it_bsid_dz-kunnr NE lw_kna1-kunnr.
      CLEAR lw_kna1.
      READ TABLE i_customer WITH KEY kunnr = it_bsid_dz-kunnr INTO lw_kna1.
      MOVE-CORRESPONDING lw_kna1 TO it_bsid_dz.
    ELSE.
      MOVE-CORRESPONDING lw_kna1 TO it_bsid_dz.
    ENDIF.

    SELECT SINGLE b~live
      FROM tvkol AS a JOIN zplbc AS b ON a~werks = b~werks AND
                                         a~lgort = b~lgort
      INTO l_live
      WHERE b~bukrs EQ pa_bukrs      AND
            a~vstel EQ it_bsid_dz-vkbur AND
            b~live  EQ space.
    IF sy-subrc EQ 0.
      it_bsid_dz-kunnr = it_bsid_dz-sortl.
    ENDIF.

    CLEAR it_bsid_rv.
    READ TABLE it_bsid_rv WITH KEY bukrs = it_bsid_dz-bukrs
                                   vkbur = it_bsid_dz-vkbur
                                   zuonr = it_bsid_dz-zuonr.
    IF sy-subrc = 0.
      it_bsid_dz-budat1 = it_bsid_rv-budat.
      it_bsid_dz-bldat1 = it_bsid_rv-bldat.
    ELSE.
      SELECT SINGLE budat bldat INTO (it_bsid_dz-budat1, it_bsid_dz-bldat1)
        FROM bsid
        WHERE bukrs = it_bsid_dz-bukrs AND
              blart = 'RV'             AND
              zuonr = it_bsid_dz-zuonr.
      IF sy-subrc NE 0.
        SELECT SINGLE budat bldat INTO (it_bsid_dz-budat1, it_bsid_dz-bldat1)
          FROM bsad
          WHERE bukrs = it_bsid_dz-bukrs AND
                blart = 'RV'             AND
                zuonr = it_bsid_dz-zuonr.
      ENDIF.
    ENDIF.

    MODIFY it_bsid_dz.

  ENDLOOP.

ENDFORM.                    " f_process_data

*&---------------------------------------------------------------------*
*&      Form  f_print_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_data.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  i_header i_detail.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_keyinfo     USING   d_alv_keyinfo.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
  PERFORM f_alv_variant_exist USING   p_vari
                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK              = ' '
      i_callback_program             = d_repid
      i_callback_pf_status_set       = 'F_SET_PF_STATUS'
      i_callback_user_command        = 'F_USER_COMMAND'
      is_layout                      = d_layout
      it_fieldcat                    = t_alv_fieldcat[]
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
      it_sort                        = t_alv_isort[]
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
*     I_SCREEN_START_COLUMN          = 0
*     I_SCREEN_START_LINE            = 0
*     I_SCREEN_END_COLUMN            = 0
*     I_SCREEN_END_LINE              = 0
      i_default                      = 'X'
      i_save                         = 'A'
*     IS_VARIANT                     =
      it_events                      = t_alv_event[]
*     IT_EVENT_EXIT                  =
      i_tabname_header               = 'I_HEADER'
      i_tabname_item                 = 'I_DETAIL'
*     I_STRUCTURE_NAME_HEADER        =
*     I_STRUCTURE_NAME_ITEM          =
      is_keyinfo                     = d_alv_keyinfo
*     IS_PRINT                       =
*     IS_REPREP_ID                   =
*     I_BUFFER_ACTIVE                =
*     I_BYPASSING_BUFFER             =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER        =
*     ES_EXIT_CAUSED_BY_USER         =
    TABLES
      t_outtab_header                = i_header
      t_outtab_item                  = i_detail
*   EXCEPTIONS
*     PROGRAM_ERROR                  = 1
*     OTHERS                         = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*  CASE sy-xcode.
*    WHEN '&F03'.
*      SUBMIT zm_propose_stock VIA SELECTION-SCREEN.
*    WHEN '&F15'.
*      SUBMIT zm_propose_stock VIA SELECTION-SCREEN.
*    WHEN '&F12'.
*      SUBMIT zm_propose_stock VIA SELECTION-SCREEN.
*  ENDCASE.

ENDFORM.                    " f_print_data

*&---------------------------------------------------------------------*
*&      Form  f_gui_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0319   text
*      -->P_0320   text
*----------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "f_gui_message

*&---------------------------------------------------------------------*
*&      Form  f_clear_alv_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_clear_alv_data.

  CLEAR:t_alv_fieldcat,
        t_alv_event,
        t_events,
        t_alv_isort,
        t_alv_filter,
        t_event_exit,
        d_alv_isort,
        d_alv_variant,
        d_alv_list_scroll,
        d_alv_sort_postn,
        d_alv_keyinfo,
        d_alv_fieldcat,
        d_alv_formname,
        d_alv_ucomm,
        d_alv_print,
        d_alv_repid,
        d_alv_tabix,
        d_alv_subrc,
        d_alv_screen_start_column,
        d_alv_screen_start_line,
        d_alv_screen_end_column,
        d_alv_screen_end_line,
        d_alv_layout,
        d_layout,
        d_repid,
        d_print.

  REFRESH: t_alv_fieldcat,
           t_alv_event,
           t_events,
           t_alv_isort,
           t_alv_filter,
           t_event_exit.

  d_repid = sy-repid.

ENDFORM.                    " f_clear_alv_data

*&---------------------------------------------------------------------*
*&      Form  f_build_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FT_REPORT  text
*----------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report1 ft_report2.

  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING 'I_HEADER':
   'KUNNR' '' '' '' '13' 'Customer' '' '' '' '' '' '' '' '' '' '' '' '',
   'NAME1' '' '' '' '35' 'Customer Name' '' '' '' '' '' '' '' '' '' '' '' '',
   'NAME2' '' '' '' '35' 'Customer address' '' '' '' '' '' '' '' '' '' '' '' '',
   'ZTERM' '' '' '' '4' 'Term' '' '' '' '' '' '' '' '' '' '' '' ''.

  PERFORM f_fieldcatg USING 'I_DETAIL':
   'ZUONR' '' '' '' '13' 'DO Number' '' '' '' '' '' '' '' '' '' '' '' '',
   'BLDAT1' '' '' '' '10' 'Doc. Date' '' '' '' '' '' '' '' '' '' '' '' '',
   'ZFBDT' '' '' '' '10' 'Due Date' '' '' '' '' '' '' '' '' '' '' '' '',
   'BUDAT1' '' '' '' '10' 'Bill Date' '' '' '' '' '' '' '' '' '' '' '' '',
   'BUDAT' '' '' '' '10' 'Pay Date' '' '' '' '' '' '' '' '' '' '' '' '',
   'SSPDT' '' '' '' '10' 'SSP Date' '' '' '' '' '' '' '' '' '' '' '' '',
   'DMBTR' '' '' '' '15' 'Amount' 'X' '' '' 'IDR' '' '' '' '' '' '' '' '',
   'SKNTO' '' '' 'X' '15' 'Disc Amount' '' '' '' '' '' '' '' '' '' '' '' '',
   'BLART' 'BSID' '' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
   'SGTXT' 'BSID' '' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
   'ZTERM' 'BSID' '' 'X' '' 'Term' '' '' '' '' '' '' '' '' '' '' '' '',
   'SKFBT' 'BSID' '' 'X' '15' 'Disc base' '' '' '' '' '' '' '' '' '' '' '' '',
   'BELNR' 'BSID' '' 'X' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
   'AUGBL' 'BSID' '' 'X' '10' 'Clear doc.' '' '' '' '' '' '' '' '' '' '' '' ''.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'I_HEADER'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM f_fieldcats                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_FNAME                                                      *
*  -->  FU_OUTLEN                                                     *
*  -->  FU_NOSIGN                                                     *
*  -->  FU_NOOUT                                                      *
*  -->  FU_TEXT                                                       *
*  -->  FU_REFTB                                                      *
*  -->  FU_REFFNAME                                                   *
*  -->  FU_DECIMALS                                                   *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    value(fu_types)
                          value(fu_fname)
                          value(fu_reftb)
                          value(fu_refld)
                          value(fu_noout)
                          value(fu_outln)
                          value(fu_fltxt)
                          value(fu_dosum)
                          value(fu_hotsp)
                          value(fu_dec)
                          value(fu_waers)
                          value(fu_meins)
                          value(fu_waers_f)
                          value(fu_meins_f)
                          value(fu_checkbox)
                          value(fu_key)
                          value(fu_input)
                          value(fu_no_zero)
                          value(fu_no_sign).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.
  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname       = fu_types.
  ld_fieldcat-fieldname     = fu_fname.
  ld_fieldcat-ref_tabname   = fu_reftb.
  ld_fieldcat-ref_fieldname = fu_refld.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-outputlen     = fu_outln.
  ld_fieldcat-seltext_l     = fu_fltxt.
  ld_fieldcat-seltext_m     = fu_fltxt.
  ld_fieldcat-seltext_s     = fu_fltxt.
  ld_fieldcat-reptext_ddic  = fu_fltxt.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-do_sum        = fu_dosum.
  ld_fieldcat-hotspot       = fu_hotsp.
  ld_fieldcat-decimals_out  = fu_dec.
  ld_fieldcat-currency      = fu_waers.
  ld_fieldcat-quantity      = fu_meins.
  ld_fieldcat-qfieldname    = fu_meins_f.
  ld_fieldcat-cfieldname    = fu_waers_f.
  ld_fieldcat-checkbox      = fu_checkbox.
  ld_fieldcat-key           = fu_key.
  ld_fieldcat-input         = fu_input.
  ld_fieldcat-no_zero       = fu_no_zero.
  ld_fieldcat-no_sign       = fu_no_sign.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.

ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-f2code             = '&ETA'.
*  fu_layout-box_fieldname      = 'FLAG'.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
*  fu_layout-info_fieldname     = 'ERRFL'.
*  fu_layout-box_fieldname      = 'FLAG'.

ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_keyinfo                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_KEYINFO                                                    *
*---------------------------------------------------------------------*
FORM f_build_keyinfo USING fu_keyinfo TYPE slis_keyinfo_alv.

  fu_keyinfo-header01 = 'VKBUR'.
  fu_keyinfo-item01   = 'VKBUR'.
  fu_keyinfo-header02 = 'KUNNR'.
  fu_keyinfo-item02   = 'KUNNR'.

ENDFORM.                    " f_build_keyinfo

*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'VKBUR'.
  ld_sort-up        = 'X'.
  ld_sort-group     = '*'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'KUNNR'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'ZUONR'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.


ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_build_event                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_EVENTS                                                     *
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.

  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_end_of_page.
*  ft_events-form = 'F_END_OF_PAGE'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_before_line_output.
*  ft_events-form = 'F_BEFORE_LINE_OUTPUT'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_after_line_output.
*  ft_events-form = 'F_AFTER_LINE_OUTPUT'.
*  APPEND ft_events.
*
*  CLEAR ft_events.
*  ft_events-name = slis_ev_subtotal_text.
*  ft_events-form = 'F_SUBTOTAL'.
*  APPEND ft_events.

ENDFORM.                    "f_build_event

*---------------------------------------------------------------------*
*       FORM f_build_event_exit                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

ENDFORM.                    "f_build_event_exit

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos = 'X'.
  fu_print-no_print_selinfos  = 'X'.
  fu_print-no_coverpage       = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "f_build_print

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_alv_variant_exist USING     fu_vari
                         CHANGING  fc_alv_variant STRUCTURE disvariant.

  IF NOT fu_vari IS INITIAL.
    MOVE fu_vari TO fc_alv_variant-variant.
    fc_alv_variant-report = d_repid.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save        = 'A'
      CHANGING
        cs_variant    = fc_alv_variant
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      IF NOT sy-msgid IS INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR fc_alv_variant.
    fc_alv_variant-report = sy-repid.
  ENDIF.


ENDFORM.                    " F_ALV_VARIANT_EXIST

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

  DATA: l_text(50).

  CONCATENATE 'Cabang:' i_header-vkbur '-' i_header-gtext
      INTO l_text SEPARATED BY space.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING l_text.
  PERFORM f_hdr_uline.

ENDFORM.                    "f_top_of_page

*&---------------------------------------------------------------------*
*&      Form  F_HDR_ULINE
*&---------------------------------------------------------------------*
*       Draw underline if flag set
*----------------------------------------------------------------------*
FORM f_hdr_uline.
  IF d_hdr_rpt_lines = 'X'.
    ULINE.
  ENDIF.
ENDFORM.                    " F_HDR_ULINE

*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE1
*&---------------------------------------------------------------------*
*       Header line with report, title and page
*----------------------------------------------------------------------*
FORM f_hdr_line1 USING fu_company.
  DATA:
    page_number(10) VALUE 'Page: nnnn',
    progname(42) VALUE 'Program: xx',
    ld_progname(20),
    page(4).

*--- Page number
  page = sy-pagno.
  REPLACE 'nnnn' WITH page INTO page_number.
  IF sy-cprog EQ sy-repid.
    REPLACE 'xx' WITH sy-repid INTO progname.
  ELSE.
    CONCATENATE sy-repid '(' sy-cprog ')' INTO ld_progname.
    REPLACE 'xx' WITH ld_progname INTO progname.
  ENDIF.

*--- Output line
  PERFORM f_hdr_pad_title USING progname fu_company page_number.
ENDFORM.                    " F_HDR_LINE1


*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE2
*&---------------------------------------------------------------------*
*       Client, User text 1, Date and time
*----------------------------------------------------------------------*
FORM f_hdr_line2 USING fu_title.
  DATA:
    ld_sysid(18) VALUE 'Client : XXX(YYY)',
*  ld_datum(18) value 'Date: AA/BB/CCCC'.
    ld_datum(10).

*--- system info
  REPLACE 'XXX' WITH sy-sysid(3) INTO ld_sysid.
  REPLACE 'YYY' WITH sy-mandt INTO ld_sysid.

*--- date
*  replace 'AA' with sy-datum+6(2) into ld_datum.
*  replace 'BB' with sy-datum+4(2) into ld_datum.
*  replace 'CCCC' with sy-datum+0(4) into ld_datum.
  WRITE sy-datum TO ld_datum.

*--- output line
  PERFORM f_hdr_pad_title USING ld_sysid fu_title ld_datum.
ENDFORM.                    " F_HDR_LINE2


*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE3
*&---------------------------------------------------------------------*
*       User name, text 2, time
*----------------------------------------------------------------------*
FORM f_hdr_line3 USING fu_title.
  DATA:
    ld_uzeit(5) VALUE 'hh:mm',
    ld_uname(21) VALUE 'User   : xx'.

*--- time
  REPLACE 'hh' WITH sy-uzeit(2) INTO ld_uzeit.     " hour
  REPLACE 'mm' WITH sy-uzeit+2(2) INTO ld_uzeit.   " minute

*--- user
  REPLACE 'xx' WITH sy-uname INTO ld_uname.

*--- output line
  PERFORM f_hdr_pad_title USING ld_uname fu_title ld_uzeit.

ENDFORM.                    " F_HDR_LINE3

*&---------------------------------------------------------------------*
*&      Form  F_HDR_PAD_TITLE
*&---------------------------------------------------------------------*
*       Prepare the variable with the title text spaced correctly
*----------------------------------------------------------------------*
FORM f_hdr_pad_title USING v_left_text v_middle_text v_right_text.

  DATA:
      page_width TYPE i,       " Width of page
      middle_length TYPE i,    " Length of title text
      left_length TYPE i,      " Length of left text
      right_length TYPE i,     " Length of right text
      left_start TYPE i,       " Position on line for start of left tex
      middle_start TYPE i,     " Position on line for start of middl tex
      right_start TYPE i.      " Position on line for start of right tex

*--- Start with a blank title
  CLEAR d_hdr_title.
  page_width = sy-linsz - 1.

*--- Compute space on either side of title allowing vertical border
  COMPUTE middle_length = STRLEN( v_middle_text ).
  COMPUTE left_length = STRLEN( v_left_text ).
  COMPUTE right_length = STRLEN( v_right_text ).

  COMPUTE middle_start = ( sy-linsz - middle_length ) / 2.

*--- Allow for vertical lines
  left_start = 0.
  IF d_hdr_rpt_lines = 'X'.
    d_hdr_title(1) = sy-vline.
    d_hdr_title+page_width(1) = sy-vline.
    left_start = 1.
  ENDIF.
  right_start = sy-linsz - left_start - right_length - 1.
  WRITE:/ sy-vline.
*--- Insert texts
  IF left_length <> 0.
*    d_hdr_title+left_start(left_length) = v_left_text.
    WRITE AT (left_length) v_left_text.
  ENDIF.
  IF middle_length <> 0.
    WRITE AT middle_start(middle_length) v_middle_text.
*    d_hdr_title+middle_start(middle_length) = v_middle_text.
  ENDIF.
  IF right_length <> 0.
    WRITE AT right_start(right_length) v_right_text.
*    d_hdr_title+right_start(right_length) = v_right_text.
  ENDIF.
  WRITE AT sy-linsz sy-vline.
ENDFORM.                    " F_HDR_PAD_TITLE

*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.

  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.

ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.

  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.
  REFRESH: lt_dynpread.

  CASE fu_ucomm.

    WHEN '&SAV'.

  ENDCASE.

ENDFORM.                    "f_user_command

*&---------------------------------------------------------------------*
*&      Form  f_cek_authority
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cek_authority.

  DATA: BEGIN OF lt_vkbur OCCURS 0,
          vkbur  LIKE  tvbur-vkbur,
        END OF lt_vkbur.

  SELECT vkbur INTO TABLE lt_vkbur FROM tvbur
    WHERE vkbur IN so_vkbur.

  LOOP AT lt_vkbur.
    AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
        ID 'GSBER' FIELD lt_vkbur-vkbur
        ID 'ACTVT' FIELD '01'.
    IF sy-subrc NE 0.
      MESSAGE i002(zz) WITH
      'You have no authorization for Sales Office' lt_vkbur-vkbur.
      STOP.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " f_cek_authority
