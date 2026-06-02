REPORT zf_vatout_process_dn MESSAGE-ID zf NO STANDARD PAGE HEADING
                                          LINE-COUNT 60
                                          LINE-SIZE  254.

INCLUDE zf_vatout_process_top.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_vkorg  LIKE tvko-vkorg OBLIGATORY DEFAULT '8020',
            p_vkburf LIKE tvbur-vkbur OBLIGATORY MEMORY ID fvk,
            p_vkburt LIKE tvbur-vkbur OBLIGATORY MEMORY ID tvk.
*SELECT-OPTIONS: s_erdat FOR vbfa-erdat OBLIGATORY,
*                s_vbelv FOR vbfa-vbelv.
SELECT-OPTIONS so_erdat FOR vttk-erdat OBLIGATORY
                                       NO-EXTENSION
                                       MODIF ID erd.
SELECT-OPTIONS so_tknum FOR vttk-tknum MODIF ID stk.
*PARAMETERS:     p_vatdt LIKE zfvato-vatdt OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN SKIP.
PARAMETERS:     p_prev AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK block1.

AT SELECTION-SCREEN.
  IF so_erdat-high IS NOT INITIAL.
    IF so_erdat-low(4) <> so_erdat-high(4).
      LOOP AT SCREEN.
        IF screen-group1 = 'ERD'.
          screen-input  = 1.
        ELSE.
          screen-input  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
      MESSAGE e000(zab) WITH 'Year difference in shipping dates'.
    ENDIF.
  ENDIF.

* INITIALIZATION
INITIALIZATION.

*START-OF-SELECTION.
START-OF-SELECTION.
  va_mode = 'N'. "p_mode. "'N'.

  PERFORM cek_lock.
  PERFORM f_get_fr_shipment.
  IF gt_vttp[] IS NOT INITIAL.
    PERFORM process_vat.
    PERFORM write_table.
  ENDIF.

TOP-OF-PAGE.
  PERFORM write_header.

*&---------------------------------------------------------------------*
*&      Form  CEK_LOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek_lock.
  CALL FUNCTION 'ENQUEUE_EZ0005'
    EXPORTING
      vkorg          = p_vkorg
*     VKBUR          = P_VKBUR
    EXCEPTIONS
      foreign_lock   = 4
      system_failure = 8.
  IF sy-subrc EQ 4.
    MESSAGE a000(zf) WITH 'Transaction current process by another W-S'.
  ENDIF.

ENDFORM.                    " CEK_LOCK

*&---------------------------------------------------------------------*
*&      Form  RELEASE_LOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM release_lock.
  CALL FUNCTION 'DEQUEUE_EZ0005'
    EXPORTING
      vkorg = p_vkorg.
*       VKBUR = P_VKBUR

ENDFORM.                    " RELEASE_LOCK

*&---------------------------------------------------------------------*
*&      Form  process_vat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_vat.
  DATA : lt_main  LIKE i_main OCCURS 0 WITH HEADER LINE.

  DATA : r_dudat  TYPE STANDARD TABLE OF bapidlv_range_bldat.
  DATA : lt_zfvatnr_dtl TYPE STANDARD TABLE OF zfvatnr_dtl,
         wa_vat         LIKE zfvatnr_dtl,
         lt_zfvatnr     LIKE zfvatnr,
         lv_posnr       TYPE posnr,
         lr_datum       TYPE RANGE OF datum,
         wa_datum       LIKE LINE OF lr_datum.

  DATA : BEGIN OF lt_konv OCCURS 0,
           knumv LIKE konv-knumv,
           kbetr LIKE konv-kbetr,
           kwert LIKE konv-kwert,
         END OF lt_konv.

  DATA: lt_leg      LIKE i_live OCCURS 0 WITH HEADER LINE,
        lt_sap      LIKE i_live OCCURS 0 WITH HEADER LINE,
        lt_konvsum  LIKE lt_konv OCCURS 0 WITH HEADER LINE,
        ld_auart    LIKE vbak-auart,
        l_term      LIKE t052-ztag1,
        l_kdgrp     LIKE knvv-kdgrp,
        l_month     TYPE i,
        l_year      TYPE i,
        l_zfbdt     LIKE bsid-zfbdt,
        l_zbd1t     LIKE bsid-zbd1t,
        l_vbelv     LIKE vbfa-vbelv,
        l_vbeln     LIKE vbfa-vbeln,
        l_flag1     LIKE zfvato-flag1,
        l_vatpr     LIKE zfvato-vatpr,
        l_vatno     LIKE zfvato-vatno,
        l_vbeln_ref LIKE zfvato-vbeln_ref,
        l_zuonr_ref LIKE zfvato-zuonr_ref,
        l_dueyr_ref LIKE zfvato-dueyr_ref,
        li_vbfa     LIKE i_vbfa OCCURS 0 WITH HEADER LINE.

  RANGES: r_vkbur_sap FOR knvv-vkbur,
          r_vkbur_leg FOR knvv-vkbur.

  DATA : lt_mseg    LIKE i_mseg OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF lt_mseg2 OCCURS 0,
           mblnr TYPE mblnr,
           mjahr TYPE mjahr,
           zeile TYPE mblpo,
           smbln TYPE mblnr,
           sjahr TYPE mjahr,
           smblp TYPE mblpo,
         END OF lt_mseg2.

  DATA : lt_vbfa  LIKE i_vbfa OCCURS 0 WITH HEADER LINE.

  DATA : lv_tknum    LIKE vttk-tknum,
         lv_dmbtr    LIKE mseg-dmbtr,
         lv_dmbt1    TYPE p DECIMALS 0,
         lv_pdmbt    TYPE p DECIMALS 4,
         lv_mwsbk    TYPE p DECIMALS 4,
         lv_netwr2   TYPE p DECIMALS 4,
         lv_selisih  LIKE mseg-dmbtr,
         lv_selisih2 LIKE mseg-dmbtr,
         lv_selisih3 LIKE mseg-dmbtr,
         lv_wrbt1    TYPE p DECIMALS 4,
         lv_netwr3   LIKE zfvato-netwr.

  DATA : ls_a934 LIKE LINE OF gt_a934,
         ls_a017 LIKE LINE OF gt_a017,
         ls_konp LIKE LINE OF gt_konp,
         ls_mkpf LIKE LINE OF gt_mkpf,
         ls_vttp LIKE LINE OF gt_vttp,
         ls_vttk LIKE LINE OF gt_vttk,
         ls_vbfa LIKE LINE OF gt_vbfa.

  DATA : lv_dmbtrsum LIKE mseg-dmbtr,
         lv_netwrsum LIKE zfvato-netwr.

* Get VAT Out Number
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE i_zfvatnr
    FROM zfvatnr
    WHERE vkorg = p_vkorg.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Please Maintenance VAT Number'.
    STOP.
  ENDIF.

* Get Trn Code
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE i_zfvattrn
    FROM zfvattrn
    WHERE vkorg = p_vkorg AND
          vkbur = p_vkburf.

* Get TOP
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE i_zfvattop
    FROM zfvattop
    WHERE vkorg = p_vkorg.

* Get FTZ
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE i_zfvatftz
    FROM zfvatftz
    WHERE bukrs = p_vkorg AND
          vkbur = p_vkburf.

  PERFORM release_lock.

  SELECT a~vbelv a~posnv a~vbeln a~posnn a~vbtyp_n a~erdat a~erzet a~bwart
         c~budat
    INTO CORRESPONDING FIELDS OF TABLE i_vbfa
    FROM vbfa AS a JOIN mseg AS b ON a~vbeln = b~mblnr
                   JOIN mkpf AS c ON b~mblnr = c~mblnr
    FOR ALL ENTRIES IN gt_vttp
    WHERE a~vbelv = gt_vttp-vbeln
      AND a~vbtyp_n IN ('R','h')
      AND a~bwart = '641'
      AND b~bukrs = p_vkorg
      AND b~umwrk = p_vkburt
      AND b~werks = p_vkburf.

  SORT i_vbfa BY vbeln.
  DELETE ADJACENT DUPLICATES FROM i_vbfa COMPARING vbeln.

  IF i_vbfa[] IS NOT INITIAL.
    SELECT *
      FROM vbfa
      INTO CORRESPONDING FIELDS OF TABLE gt_vbfa
      FOR ALL ENTRIES IN i_vbfa
      WHERE vbelv = i_vbfa-vbelv
        AND vbtyp_n = '8'.

    IF p_vkorg = '8220'.
      SELECT mblnr mjahr zeile bukrs kunnr umwrk matnr menge meins dmbtr waers
             shkzg werks sjahr smbln smblp
        INTO CORRESPONDING FIELDS OF TABLE i_mseg
        FROM mseg
        FOR ALL ENTRIES IN i_vbfa
        WHERE mblnr = i_vbfa-vbeln
          AND bukrs = p_vkorg
          AND umwrk = p_vkburt
          AND werks = p_vkburf
          AND xauto = 'X'.

      lt_mseg[] = i_mseg[].
      SORT lt_mseg BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_mseg COMPARING matnr.
      IF lt_mseg[] IS NOT INITIAL.
        SELECT *
          FROM a934
          INTO CORRESPONDING FIELDS OF TABLE gt_a934
          FOR ALL ENTRIES IN lt_mseg
          WHERE kappl = 'V'
            AND kschl = 'ZHET'
            AND matnr = lt_mseg-matnr.

        IF gt_a934[] IS NOT INITIAL.
          SELECT *
            FROM konp
            INTO CORRESPONDING FIELDS OF TABLE gt_konp
            FOR ALL ENTRIES IN gt_a934
            WHERE knumh = gt_a934-knumh.
        ENDIF.
      ENDIF.
    ELSE.
      SELECT mblnr mjahr zeile bukrs kunnr umwrk matnr menge meins dmbtr waers
             shkzg werks sjahr smbln smblp
        INTO CORRESPONDING FIELDS OF TABLE i_mseg
        FROM mseg
        FOR ALL ENTRIES IN i_vbfa
        WHERE mblnr = i_vbfa-vbeln
          AND bukrs = p_vkorg
          AND umwrk = p_vkburt
          AND werks = p_vkburf.

      IF p_vkorg = '8020'.
        IF i_mseg[] IS NOT INITIAL.
          SELECT *
            FROM mkpf
            INTO CORRESPONDING FIELDS OF TABLE gt_mkpf
            FOR ALL ENTRIES IN i_mseg
            WHERE mblnr = i_mseg-mblnr
              AND mjahr = i_mseg-mjahr.
        ENDIF.

        lt_mseg[] = i_mseg[].
        SORT lt_mseg BY matnr.
        DELETE ADJACENT DUPLICATES FROM lt_mseg COMPARING matnr.
        IF lt_mseg[] IS NOT INITIAL.
          SELECT *
            FROM zcdsmm_004
            INTO CORRESPONDING FIELDS OF TABLE gt_a017
            FOR ALL ENTRIES IN lt_mseg
            WHERE matnr = lt_mseg-matnr.

*          SELECT *
*            FROM a017 JOIN eord ON a017~matnr = eord~matnr
*                                AND a017~werks = eord~werks
*                                AND a017~lifnr = eord~lifnr
*                      JOIN eina ON a017~matnr = eina~matnr
*                                AND a017~lifnr = eina~lifnr
*                      JOIN eine ON eina~infnr = eine~infnr
*                                AND a017~ekorg = eine~ekorg
*                                AND a017~werks = eine~werks
*            INTO CORRESPONDING FIELDS OF TABLE gt_a017
*            FOR ALL ENTRIES IN lt_mseg
*            WHERE a017~kappl = 'M'
*              AND a017~kschl = 'ZHJP'
*              AND a017~matnr = lt_mseg-matnr
*              AND a017~ekorg = 'SOM'
*              AND a017~werks = '0200'
*              AND a017~esokz = '0'
*              AND eord~notkz = space
*              AND eord~autet = '1'
*              AND eina~loekz = space
*              AND eine~loekz = space.

          IF gt_a017[] IS NOT INITIAL.
            SELECT *
              FROM konp
              INTO CORRESPONDING FIELDS OF TABLE gt_konp
              FOR ALL ENTRIES IN gt_a017
              WHERE knumh = gt_a017-knumh.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    CLEAR : lt_mseg[], lt_mseg.
    LOOP AT i_mseg.
      lt_mseg-mblnr = i_mseg-mblnr.
      lt_mseg-mjahr = i_mseg-mjahr.
      lt_mseg-zeile = i_mseg-zeile.
      APPEND lt_mseg.
    ENDLOOP.

    lt_vbfa[] = i_vbfa[].
    SORT lt_vbfa BY vbelv.
    DELETE ADJACENT DUPLICATES FROM lt_vbfa COMPARING vbelv.
    IF lt_vbfa[] IS NOT INITIAL.
      SELECT vbeln wadat_ist
        FROM likp
        INTO TABLE gt_likp
        FOR ALL ENTRIES IN lt_vbfa
        WHERE vbeln = lt_vbfa-vbelv.

      SELECT vbeln posnr matnr lfimg meins
        FROM lips
        INTO TABLE gt_lips
        FOR ALL ENTRIES IN lt_vbfa
        WHERE vbeln = lt_vbfa-vbelv.
    ENDIF.
  ENDIF.

  IF lt_mseg[] IS NOT INITIAL.
    SELECT mblnr mjahr zeile smbln sjahr smblp
      FROM mseg
      INTO TABLE lt_mseg2
      FOR ALL ENTRIES IN lt_mseg
      WHERE smbln EQ lt_mseg-mblnr
        AND sjahr EQ lt_mseg-mjahr
        AND smblp EQ lt_mseg-zeile.
  ENDIF.

  LOOP AT i_vbfa.
    READ TABLE lt_mseg2 WITH KEY smbln = i_vbfa-vbeln.
    IF sy-subrc EQ 0.
      DELETE i_vbfa.
    ENDIF.
  ENDLOOP.

  CLEAR : lv_wrbt1, lv_netwr3.

  SORT i_vbfa BY vbeln.
  SORT i_mseg BY mblnr.
  LOOP AT i_vbfa.
    LOOP AT i_mseg WHERE mblnr = i_vbfa-vbeln.
      IF i_mseg-smbln IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      i_main-vkorg = i_mseg-bukrs.
      i_main-vkbur = i_mseg-werks.

      IF i_mseg-dmbtr IS INITIAL OR
       ( i_mseg-dmbtr LT 0 AND p_vkorg = '8220' ).
        CLEAR lv_dmbtr.
        LOOP AT gt_a934 INTO ls_a934 WHERE matnr = i_mseg-matnr.
          IF ls_a934-datab <= i_vbfa-budat AND
            ls_a934-datbi >= i_vbfa-budat.
            READ TABLE gt_konp INTO ls_konp
                               WITH KEY knumh = ls_a934-knumh.
            IF sy-subrc = 0.
*              i_mseg-dmbtr = i_mseg-menge * ( ls_konp-kbetr / ls_konp-kpein ).
*              lv_dmbtr = i_mseg-dmbtr.
*              i_mseg-dmbtr = ( i_mseg-dmbtr / 11 ) * 10 .

              lv_pdmbt = i_mseg-menge * ( ls_konp-kbetr / ls_konp-kpein ).
              lv_dmbtr = lv_pdmbt.

              PERFORM f_tax_calc USING i_vbfa-budat lv_pdmbt 'G'
                                 CHANGING lv_pdmbt.

*              lv_pdmbt = ( lv_pdmbt / 11 ) * 10 .

              CALL FUNCTION 'ROUND'
                EXPORTING
                  decimals      = 2
                  input         = lv_pdmbt
                  sign          = '+'
                IMPORTING
                  output        = i_mseg-dmbtr
                EXCEPTIONS
                  input_invalid = 1
                  overflow      = 2
                  type_invalid  = 3
                  OTHERS        = 4.

              EXIT.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ELSEIF p_vkorg = '8020'.
        CLEAR lv_dmbtr.
        SORT gt_a017 BY matnr vdatu DESCENDING.
        LOOP AT gt_a017 INTO ls_a017 WHERE matnr = i_mseg-matnr.
          CLEAR ls_mkpf.
          READ TABLE gt_mkpf INTO ls_mkpf
                             WITH KEY mblnr = i_mseg-mblnr
                                      mjahr = i_mseg-mjahr.
          IF sy-subrc = 0.
            CLEAR ls_vbfa.
            READ TABLE gt_vbfa INTO ls_vbfa
                               WITH KEY vbelv = ls_mkpf-xblnr.
            IF sy-subrc = 0.
              CLEAR ls_vttk.
              READ TABLE gt_vttk INTO ls_vttk
                                 WITH KEY tknum = ls_vbfa-vbeln. "so_tknum-low.
              IF sy-subrc = 0.
                IF ls_a017-datab <= ls_vttk-datbg AND
                  ls_a017-datbi >= ls_vttk-datbg.
                  READ TABLE gt_konp INTO ls_konp
                                     WITH KEY knumh = ls_a017-knumh.
                  IF sy-subrc = 0.
*                    lv_dmbt1 = ( ls_konp-kbetr / ls_konp-kpein ) * 100.
*                    i_mseg-dmbtr = ( i_mseg-menge * lv_dmbt1 ) / 100.
                    lv_dmbtr = i_mseg-menge * ( ls_konp-kbetr / ls_konp-kpein ).
                    i_mseg-dmbtr = lv_dmbtr.
                    EXIT.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.

      ADD i_mseg-dmbtr TO i_main-tkwert.
      ADD i_mseg-dmbtr TO i_main-netwr.
      ADD i_mseg-dmbtr TO i_main-wrbtr.
      ADD lv_dmbtr TO i_main-wrbt1.

      i_main-kunrg = i_mseg-kunnr.
      i_main-prodt = sy-datum.
      i_main-protm = sy-uzeit.
      i_main-prous = sy-uname.
      i_main-waerk = i_mseg-waers.
      i_main-gsber = '0200'.
      MODIFY i_mseg TRANSPORTING dmbtr.
    ENDLOOP.

    i_main-vbeln = i_vbfa-vbeln.
    READ TABLE gt_vttp WITH KEY vbeln = i_vbfa-vbelv.
    IF sy-subrc = 0.
      i_main-zuonr = gt_vttp-tknum.
      i_main-budat = gt_vttk-erdat.
      READ TABLE gt_vttk WITH KEY tknum = gt_vttp-tknum.
      IF sy-subrc = 0.
        i_main-zuodt = gt_vttk-erdat.
      ENDIF.
    ENDIF.
    i_main-dueyr = i_vbfa-erdat(4).
    i_main-vtart = 'DN'.
    i_main-erdat = i_vbfa-erdat.
    i_main-dudat = i_vbfa-budat.
    i_main-vbelv = i_vbfa-vbelv.
    i_main-gjahr = i_vbfa-erdat(4).
    i_main-bldat = i_vbfa-erdat.
    i_main-fkdat = i_vbfa-budat.
    IF p_vkorg = '8220'.
      PERFORM f_tax_calc USING i_vbfa-budat i_main-wrbt1 'G'
                         CHANGING lv_netwr2.

*      lv_netwr2 = ( i_main-wrbt1 / 11 ) * 10.

      CALL FUNCTION 'ROUND'
        EXPORTING
          decimals      = 2
          input         = lv_netwr2
          sign          = '+'
        IMPORTING
          output        = lv_netwr2
        EXCEPTIONS
          input_invalid = 1
          overflow      = 2
          type_invalid  = 3
          OTHERS        = 4.

      i_main-netwr  = lv_netwr2.
      i_main-mwsbk  = i_main-wrbt1 - lv_netwr2.
      lv_selisih    = i_main-wrbtr - i_main-netwr.

      SORT i_mseg BY matnr DESCENDING.
      READ TABLE i_mseg INDEX 1.
      IF sy-subrc = 0.
        i_mseg-dmbtr = i_mseg-dmbtr - lv_selisih.
        MODIFY i_mseg INDEX 1 TRANSPORTING dmbtr.
      ENDIF.
    ELSE.
      PERFORM f_tax_calc USING i_vbfa-budat i_main-netwr 'F'
                         CHANGING i_main-mwsbk.

*      i_main-mwsbk = i_main-netwr * 10 / 100.

      i_main-duemm = i_vbfa-erdat+4(2).
    ENDIF.

    ADD i_main-wrbt1 TO lv_wrbt1.
    ADD i_main-netwr TO lv_netwr3.

    APPEND i_main. CLEAR i_main.
  ENDLOOP.

  IF p_vkorg = '8220'.
    READ TABLE i_main INDEX 1.
    PERFORM f_tax_calc USING i_main-fkdat lv_wrbt1 'G'
                       CHANGING lv_wrbt1.

*    lv_wrbt1  = ( lv_wrbt1 / 11 ) * 10.

    CALL FUNCTION 'ROUND'
      EXPORTING
        decimals      = 2
        input         = lv_wrbt1
        sign          = '+'
      IMPORTING
        output        = lv_wrbt1
      EXCEPTIONS
        input_invalid = 1
        overflow      = 2
        type_invalid  = 3
        OTHERS        = 4.

    lv_selisih2 = lv_wrbt1 - lv_netwr3.

    SORT i_mseg BY matnr DESCENDING.
    READ TABLE i_mseg INDEX 1.
    IF sy-subrc = 0.
      i_mseg-dmbtr = i_mseg-dmbtr + lv_selisih2.
      MODIFY i_mseg INDEX 1 TRANSPORTING dmbtr.
    ENDIF.

    READ TABLE i_main INDEX 1.
    IF sy-subrc = 0.
      i_main-netwr = i_main-netwr + lv_selisih2.
      i_main-mwsbk = i_main-mwsbk - lv_selisih2.
      MODIFY i_main INDEX 1 TRANSPORTING netwr mwsbk.
    ENDIF.

    CLEAR : lv_dmbtrsum, lv_netwrsum, lv_selisih3.
    LOOP AT i_mseg.
      ADD i_mseg-dmbtr TO lv_dmbtrsum.
    ENDLOOP.
    LOOP AT i_main.
      ADD i_main-netwr TO lv_netwrsum.
    ENDLOOP.
    lv_selisih3 = lv_dmbtrsum - lv_netwrsum.

    READ TABLE i_mseg INDEX 1.
    IF sy-subrc = 0.
      i_mseg-dmbtr = i_mseg-dmbtr - lv_selisih3.
      MODIFY i_mseg INDEX 1 TRANSPORTING dmbtr.
    ENDIF.
  ENDIF.

  IF i_main[] IS NOT INITIAL.
* Get Data Customer
    SELECT kunnr adrnr stras ort01 pstlz cityc stceg gform
           name_co str_suppl1 str_suppl2 str_suppl3
      INTO CORRESPONDING FIELDS OF TABLE i_cust
      FROM kna1 AS a JOIN adrc AS b ON a~adrnr = b~addrnumber
      FOR ALL ENTRIES IN i_main
      WHERE kunnr = i_main-kunrg.
* Get Data VAT Out
    SELECT *
      FROM zfvato
      INTO CORRESPONDING FIELDS OF TABLE i_zfvato
      FOR ALL ENTRIES IN i_main
      WHERE vkorg = i_main-vkorg
        AND vkbur = i_main-vkbur
        AND zuonr = i_main-zuonr.
*        AND vbeln = i_main-vbeln
*        AND vbelv = i_main-vbelv.
  ENDIF.

* Check VAT date
  SELECT SINGLE *
    FROM zfvatnr
    INTO lt_zfvatnr
    WHERE vkorg EQ p_vkorg
      AND gjahr EQ so_erdat-low(4).

  IF sy-subrc = 0.
    lv_posnr  = lt_zfvatnr-posnr.
    IF lt_zfvatnr-vatno >= lt_zfvatnr-vatto.
      lv_posnr = lv_posnr + 10.
    ENDIF.
  ENDIF.

  SELECT *
    FROM zfvatnr_dtl
    INTO CORRESPONDING FIELDS OF TABLE lt_zfvatnr_dtl
    WHERE vkorg EQ p_vkorg.
  LOOP AT lt_zfvatnr_dtl INTO wa_vat
                         WHERE vkorg EQ p_vkorg
                           AND gjahr EQ so_erdat-low(4)
                           AND posnr EQ lv_posnr.
    IF wa_vat-validfr IS NOT INITIAL AND
      wa_vat-validto IS NOT INITIAL.
      wa_datum-low      = wa_vat-validfr.
      wa_datum-high     = wa_vat-validto.
      wa_datum-sign     = 'I'.
      wa_datum-option   = 'BT'.
      APPEND wa_datum TO lr_datum.
    ENDIF.
  ENDLOOP.

  IF p_vkorg = '8220'.
    SORT i_main BY zuonr.
    lt_main[] = i_main[].
    SORT lt_main BY zuonr.
    DELETE ADJACENT DUPLICATES FROM lt_main COMPARING zuonr.
  ELSE.
    SORT i_main BY zuonr kunrg.
    lt_main[] = i_main[].
    SORT lt_main BY zuonr kunrg.
    DELETE ADJACENT DUPLICATES FROM lt_main COMPARING zuonr kunrg.
  ENDIF.

  LOOP AT lt_main.
    CLEAR: v_vatto, v_vatno, v_vatpr, v_vatbr, v_coretax.
* Get Customer
    IF p_vkorg = '8220'.
      PERFORM f_get_vat_number USING    lt_main-zuonr
                                        lt_main-zuodt
                                        lt_main-vkbur
                                        lt_main-fkdat
                                        i_cust-gform
                               CHANGING v_vatto
                                        v_vatno
                                        v_vatpr
                                        v_vatbr
                                        v_coretax.
    ELSE.
      CLEAR i_cust.
*{   INSERT         P01K910218                                        1
      "Start SOH: Shell SCI Adjustment 20240221 RZL
      SORT i_cust BY kunnr.
      "End SOH: Shell SCI Adjustment 20240221 RZL
*}   INSERT
      READ TABLE i_cust WITH KEY kunnr = lt_main-kunrg
                        BINARY SEARCH.
      IF sy-subrc = 0.
        IF i_cust-cityc = 'T1'.
          PERFORM f_get_vat_number USING    lt_main-zuonr
                                            lt_main-zuodt
                                            lt_main-vkbur
                                            lt_main-fkdat
                                            i_cust-gform
                                   CHANGING v_vatto
                                            v_vatno
                                            v_vatpr
                                            v_vatbr
                                            v_coretax.
        ENDIF.
      ENDIF.
    ENDIF.

    LOOP AT i_main WHERE zuonr = lt_main-zuonr.
* Check VAT date
*    IF i_main-dudat IN lr_datum.
      IF i_main-zuodt IN lr_datum.
      ELSE.
        DELETE i_main.
        CONTINUE.
      ENDIF.

* Check Double
      READ TABLE i_zfvato WITH KEY vkorg = i_main-vkorg
                                   vkbur = i_main-vkbur
                                   zuonr = i_main-zuonr.
      IF sy-subrc = 0.
        DELETE i_main. CONTINUE.
      ENDIF.

      MOVE-CORRESPONDING i_cust TO i_main.

* Get VAT Number
      IF p_vkorg = '8220'.
        CLEAR : i_main-kunrg.
        i_main-str_suppl1   = 'KOMPLEK LOBINDO JL YOS SUDARSO NO 01 '.
        i_main-str_suppl2   = 'KAMPUNG SERAYA BATU AMPAR KOTA BATAM '.
        i_main-stras        = 'KEPULAUAN RIAU'.
        i_main-stceg        = '01.341.775.3-215.001'.
        i_main-name_co      = 'PT ERES REVCO'.

        i_main-vatbr  = v_vatbr.
        IF v_coretax IS INITIAL.
          IF v_vatno GE v_vatto.
            DELETE i_main. CONTINUE.
          ENDIF.
        ENDIF.
        IF i_main-flag1 = 'G' OR i_main-flag1 = 'K'.
          v_vatpr+2(1) = '7'.
        ENDIF.
        i_main-vatno = v_vatno.
        i_main-vatpr = v_vatpr.
        i_zfvatnr-vatno = i_main-vatno.

        IF v_coretax IS INITIAL.
          IF i_main-vatbr IS INITIAL.
            DELETE i_main. CONTINUE.
          ENDIF.
        ENDIF.
        MODIFY i_zfvatnr TRANSPORTING vatno
                         WHERE vkorg = p_vkorg
                           AND vkbur = i_main-vatbr
                           AND gjahr = i_main-zuodt(4).
      ELSE.
        IF i_main-cityc = 'T1'.
          i_main-vatbr  = v_vatbr.
          IF v_coretax IS INITIAL.
            IF v_vatno GE v_vatto.
              DELETE i_main. CONTINUE.
            ENDIF.
          ENDIF.
          IF i_main-flag1 = 'G' OR i_main-flag1 = 'K'.
            v_vatpr+2(1) = '7'.
          ENDIF.
          i_main-vatno = v_vatno.
          i_main-vatpr = v_vatpr.
          i_zfvatnr-vatno = i_main-vatno.

          IF i_main-zuodt GE '20070101'.
            IF v_coretax IS INITIAL.
              IF i_main-vatbr IS INITIAL.
                DELETE i_main. CONTINUE.
              ENDIF.
            ENDIF.
            MODIFY i_zfvatnr TRANSPORTING vatno
                             WHERE vkorg = p_vkorg
                               AND vkbur = i_main-vatbr
                               AND gjahr = i_main-zuodt(4).
          ELSE.
            MODIFY i_zfvatnr TRANSPORTING vatno
                             WHERE vkorg = p_vkorg
                               AND vkbur = '0200'.
          ENDIF.
        ENDIF.
      ENDIF.

      MODIFY i_main TRANSPORTING kunrg adrnr stras ort01 pstlz cityc gform
                                 stceg name_co str_suppl1 str_suppl2
                                 vatno vatpr dudat.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " process_vat

*&---------------------------------------------------------------------*
*&      Form  write_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_table.

  DATA: l_record      TYPE i,
        l_text(40),
        lt_zfvato     LIKE zfvato OCCURS 0 WITH HEADER LINE,
        lt_zsl_hsales LIKE zsl_hsales OCCURS 0 WITH HEADER LINE.

  DATA : lv_subrc     TYPE sy-subrc,
         lv_message   TYPE bapi_msg,
         lv_vatpr(50).

  DATA : lt_main  LIKE i_main OCCURS 0 WITH HEADER LINE.

* Check data ada atau tidak
  DESCRIBE TABLE i_main LINES l_record.
  IF l_record IS INITIAL.
    MESSAGE s000(zf) WITH 'No Data'.
    STOP.
  ENDIF.

* Check Preview.
  IF p_prev IS INITIAL.

*    IF sy-subrc = 0 AND NOT i_main[] IS INITIAL.
    IF i_main[] IS NOT INITIAL.

* Runing BDC F-02
      PERFORM run_bdc CHANGING lv_subrc
                               lv_message.

      IF lv_subrc IS INITIAL.
* Write ZFVATO
        PERFORM f_modify_zfvato TABLES lt_zfvato.

        MODIFY zfvato FROM TABLE lt_zfvato.

* Update VAT No
        LOOP AT i_zfvatnr.
          UPDATE zfvatnr SET vatno = i_zfvatnr-vatno
            WHERE vkorg = i_zfvatnr-vkorg AND
                  vkbur = i_zfvatnr-vkbur AND
                  gjahr = i_zfvatnr-gjahr.
        ENDLOOP.

* Update ZFVATO ( Koreksi / Pengganti )
*      IF i_koreksi[] IS NOT INITIAL.
*        CLEAR lt_zfvato. REFRESH lt_zfvato.
*        lt_zfvato[] = i_koreksi[].
*        MODIFY zfvato FROM TABLE lt_zfvato.
*      ENDIF.

* Realese lock
        PERFORM release_lock.
      ELSE.
        MESSAGE e000(zab) WITH lv_message.
      ENDIF.
    ENDIF.
  ENDIF.

* Write List
  LOOP AT i_main.
    lt_main-vkbur   = i_main-vkbur.
    lt_main-zuonr   = i_main-zuonr.
    lt_main-zuodt   = i_main-zuodt.
    lt_main-kunrg   = i_main-kunrg.
    lt_main-name_co = i_main-name_co.
    lt_main-stceg   = i_main-stceg.
    lt_main-vatpr   = i_main-vatpr.
    lt_main-netwr   = i_main-netwr.
    lt_main-mwsbk   = i_main-mwsbk.
    lt_main-xblnr   = i_main-xblnr.
    lt_main-sgtxt   = i_main-sgtxt.
    COLLECT lt_main.
    CLEAR lt_main.
  ENDLOOP.

  CLEAR l_record.
  LOOP AT lt_main.
    CLEAR lv_vatpr.
    WRITE lt_main-vatpr TO lv_vatpr USING EDIT MASK '__.__.__.____-________'.
    ADD 1 TO l_record.
    WRITE: /     '|',
             (5) lt_main-vkbur, '|',
            (10) lt_main-zuonr, '|',
                 lt_main-zuodt, '|',
*            (10) i_main-vbelv, '|',
*                 i_main-fkdat, '|',
*                 i_main-erdat, '|',
                 lt_main-kunrg, '|',
            (40) lt_main-name_co, '|',
            (20) lt_main-stceg, '|',
            (21) lv_vatpr, '|',
                 lt_main-zuodt, '|',
*              (15) i_main-dpp DECIMALS 0, '|',
*            (15) i_main-tkwert CURRENCY 'IDR', '|',
            (15) lt_main-netwr CURRENCY 'IDR', '|',
            (15) lt_main-mwsbk CURRENCY 'IDR', '|',
             (8) lt_main-xblnr CENTERED , '|',
            (10) lt_main-sgtxt CENTERED , '|',
            (40) l_text, '|'.
  ENDLOOP.

*  WRITE sy-uline(253).
  WRITE sy-uline.

  MESSAGE s000(zf) WITH l_record 'Processed'.

ENDFORM.                    " write_table

*&---------------------------------------------------------------------*
*&      Form  write_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_header.

  DATA: l_period(35),
        l_date1(10),
        l_date2(10),
        l_prev(7).

  WRITE: so_erdat-low TO l_date1,
         so_erdat-high TO l_date2.
  CONCATENATE 'Period' l_date1 'To' l_date2 INTO l_period
        SEPARATED BY space.
  IF NOT p_prev IS INITIAL.
    l_prev = 'Preview'.
  ENDIF.

  WRITE : / 'Date :', sy-datum,
            20(176) 'VAT Out Process PT. Tempo' CENTERED,
            'User :', sy-uname.
  WRITE : / 'Time :', sy-uzeit,
            20(176) l_period CENTERED,
            'Page :', sy-pagno.
  WRITE : /20(176) l_prev CENTERED.

*  WRITE sy-uline(253).
  WRITE sy-uline.
  WRITE: /     '|',
           (5) 'SlOff', '|',
          (10) 'Ship.No.' CENTERED, '|',
          (10) 'Ship.Date' CENTERED, '|',
*          (10) 'DO No.' CENTERED, '|',
*          (10) 'DO Date' CENTERED, '|',
*          (10) 'Bill Date' CENTERED, '|',
          (10) 'Customer' CENTERED, '|',
          (40) 'Customer Name' CENTERED, '|',
          (20) 'NPWP No.', '|',
          (21) 'VAT Out No.' CENTERED, '|',
          (10) 'VAT Date.' CENTERED, '|',
*          (15) 'A/R Value' RIGHT-JUSTIFIED, '|',
          (15) 'DPP Value' RIGHT-JUSTIFIED, '|',
          (15) 'PPN Value' RIGHT-JUSTIFIED, '|',
           (8) 'No Kirim' CENTERED, '|',
          (10) 'Posting No' CENTERED, '|',
          (40) 'Keterangan' CENTERED, '|'.
*  WRITE sy-uline(253).
  WRITE sy-uline.

ENDFORM.                    " write_header

*&---------------------------------------------------------------------*
*&      Form  f_get_vat_number
*&---------------------------------------------------------------------*
FORM f_get_vat_number USING    p_i_main_zuonr
                               p_i_main_dudat
                               p_i_main_vkbur
                               p_i_main-fkdat
                               p_i_main_gform
                      CHANGING p_v_vatto
                               p_v_vatno
                               p_v_vatpr
                               p_i_main_vatbr
                               fc_coretax.

  DATA: ls_005    LIKE LINE OF gt_005.
  DATA: lt_vatpr(20),
        lv_length TYPE i.

  CLEAR: i_zfvatnr, i_zfvattrn.
  IF p_i_main-fkdat >= gs_coretax-datab.
    CLEAR ls_005.
    READ TABLE gt_005 INTO ls_005
                      WITH KEY belnr = p_i_main_zuonr.
    IF sy-subrc = 0.
      fc_coretax = 'X'.
      lv_length = strlen( ls_005-fakturno ).
      lv_length = lv_length - 8.
      IF lv_length > 0.
        p_v_vatno       = ls_005-fakturno+lv_length(8).
      ELSEIF lv_length = 0.
        p_v_vatno       = ls_005-fakturno.
      ENDIF.
      p_v_vatpr       = ls_005-fakturno.
      CLEAR : p_v_vatto, p_i_main_vatbr.
    ENDIF.
  ELSE.
    IF p_i_main_dudat GE '20070101'.
      READ TABLE i_zfvattrn WITH KEY vkorg = p_vkorg
                                     vkbur = p_i_main_vkbur
                                     gform = p_i_main_gform.
      READ TABLE i_zfvatnr WITH KEY vkorg = p_vkorg
                                    vkbur = i_zfvattrn-vatbr
                                    gjahr = p_i_main_dudat(4).
      p_i_main_vatbr = i_zfvattrn-vatbr.
      p_v_vatto = i_zfvatnr-vatto.
      p_v_vatno = i_zfvatnr-vatno + 1.
      CONCATENATE '070' i_zfvatnr-vatcd
                  p_i_main_dudat+2(2) p_v_vatno INTO lt_vatpr.
      WRITE lt_vatpr TO p_v_vatpr USING EDIT MASK '___.___-__.________'.
    ELSE.
      READ TABLE i_zfvatnr WITH KEY vkorg = p_vkorg
                                    vkbur = '0200'.
      p_v_vatto = i_zfvatnr-vatto.
      p_v_vatno = i_zfvatnr-vatno + 1.
      CONCATENATE i_zfvatnr-vatpr p_v_vatno INTO lt_vatpr.
      WRITE lt_vatpr TO p_v_vatpr.
    ENDIF.
  ENDIF.

ENDFORM.                    " f_get_vat_number

*&---------------------------------------------------------------------*
*&      Form  run_bdc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM run_bdc CHANGING fc_subrc fc_message.

  DATA: BEGIN OF lt_post OCCURS 0,
          vkorg LIKE zfvato-vkorg,
          vkbur LIKE zfvato-vkbur,
          zuonr LIKE zfvato-zuonr,
          zuodt LIKE zfvato-vatdt,
          vatpr LIKE zfvato-vatpr,
          mwsbk LIKE zfvato-mwsbk,
        END OF lt_post.

  DATA: ld_text(50),
        ld_int       TYPE int4,
        ld_hkont1    LIKE zfvatftz-hkont,
        ld_hkont2    LIKE zfvatftz-hkont,
        ld_zuodt(10),
        ld_text1(18),
        ld_mwsbk(15).

  DATA : lwa_bapireturn TYPE bapireturn1,
         p_msgno        TYPE syst-msgno.

  DATA : lv_subrc         TYPE sy-subrc.

  LOOP AT i_main.
    lt_post-vkorg   = i_main-vkorg.
    lt_post-vkbur   = i_main-vkbur.
    lt_post-zuonr   = i_main-zuonr.
    lt_post-zuodt   = i_main-zuodt.
    lt_post-vatpr   = i_main-vatpr.
    lt_post-mwsbk   = i_main-mwsbk.
    COLLECT lt_post.
    CLEAR lt_post.
  ENDLOOP.

  LOOP AT lt_post.
    CLEAR: i_bdc, ld_hkont1, ld_hkont2, ld_text.

    CONCATENATE 'Periode Pajak: '  lt_post-zuodt+4(2) lt_post-zuodt(4)
    INTO ld_text.

    READ TABLE i_zfvatftz WITH KEY bukrs = lt_post-vkorg
                                   vkbur = lt_post-vkbur
                                   jenis = '40'.
    ld_hkont1 = i_zfvatftz-hkont.

    READ TABLE i_zfvatftz WITH KEY bukrs = lt_post-vkorg
                                   vkbur = lt_post-vkbur
                                   jenis = '50'.
    ld_hkont2 = i_zfvatftz-hkont.
    CONDENSE ld_hkont2.

    CONCATENATE lt_post-vatpr(3) lt_post-vatpr+4(3) lt_post-vatpr+8(2)
      lt_post-vatpr+11(9) INTO ld_text1.

    WRITE lt_post-zuodt TO ld_zuodt.
    WRITE lt_post-mwsbk TO ld_mwsbk CURRENCY 'IDR' RIGHT-JUSTIFIED.

    PERFORM f_dynpro USING:
       'X'  'SAPMF05A'                '0100',
       ' '  'BDC_CURSOR'              'RF05A-NEWKO',
       ' '  'BDC_OKCODE'              '/00',
       ' '  'BKPF-BLDAT'              ld_zuodt,
       ' '  'BKPF-BLART'              'SA',
       ' '  'BKPF-BUKRS'              lt_post-vkorg,
       ' '  'BKPF-BUDAT'              ld_zuodt,
       ' '  'BKPF-MONAT'              ld_zuodt+3(2),
       ' '  'BKPF-WAERS'              'IDR',
       ' '  'FS006-DOCID'             '*',
       ' '  'RF05A-NEWBS'             '40',
       ' '  'RF05A-NEWKO'             ld_hkont1,

       'X'  'SAPMF05A'                '0300',
       ' '  'BDC_CURSOR'              'BSEG-ZFBDT',
       ' '  'BDC_OKCODE'              '=ZK',
       ' '  'BSEG-WRBTR'              ld_mwsbk,
       ' '  'BSEG-ZFBDT'              ld_zuodt,
       ' '  'BSEG-ZUONR'              ld_text1, "i_main-vatpr,
       ' '  'BSEG-SGTXT'              ld_text,
*       ' '  'DKACB-FMORE'             'X',

       'X'  'SAPLKACB'                '0002',
       ' '  'BDC_CURSOR'              'COBL-GSBER',
       ' '  'BDC_OKCODE'              '=ENTE',
       ' '  'COBL-GSBER'              p_vkburt,

       'X'  'SAPMF05A'                '0330',
       ' '  'BDC_CURSOR'              'RF05A-NEWKO',
       ' '  'BDC_OKCODE'              '/00',
       ' '  'BSEG-VBUND'              'OTHERS',
*       ' '  'BSEG-XREF3'              i_main-zuonr,
       ' '  'RF05A-NEWBS'             '50',
       ' '  'RF05A-NEWKO'             ld_hkont2,

       'X'  'SAPMF05A'                '0300',
       ' '  'BDC_CURSOR'              'BSEG-ZFBDT',
       ' '  'BDC_OKCODE'              '=ZK',
       ' '  'BSEG-WRBTR'              ld_mwsbk,
       ' '  'BSEG-ZFBDT'              ld_zuodt,
       ' '  'BSEG-ZUONR'              ld_text1, "i_main-vatno,
       ' '  'BSEG-SGTXT'              ld_text,
       ' '  'DKACB-FMORE'             'X',

       'X'  'SAPLKACB'                '0002',
       ' '  'BDC_CURSOR'              'COBL-GSBER',
       ' '  'BDC_OKCODE'              '=ENTE',
       ' '  'COBL-GSBER'              p_vkburf,

       'X'  'SAPMF05A'                '0330',
       ' '  'BDC_CURSOR'              'BSEG-XREF3',
       ' '  'BDC_OKCODE'              '=BU',
       ' '  'BSEG-VBUND'              'OTHERS',
       ' '  'BSEG-XREF3'              lt_post-zuonr.

    IF p_vkorg = '8220'.
      lv_subrc = 4.
    ELSE.
      CALL TRANSACTION 'F-02' USING i_bdc
                              MODE va_mode
                              UPDATE 'S'
                              MESSAGES INTO i_messtab.

      READ TABLE i_messtab INTO wa_messtab WITH KEY msgtyp = 'E'.
      lv_subrc = sy-subrc.
    ENDIF.

    IF lv_subrc EQ 0.
      p_msgno   = wa_messtab-msgnr.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = wa_messtab-msgid
          msgnr               = p_msgno
          msgv1               = wa_messtab-msgv1
          msgv2               = wa_messtab-msgv2
          msgv3               = wa_messtab-msgv3
          msgv4               = wa_messtab-msgv4
        IMPORTING
          message_text_output = fc_message.

      fc_subrc   = 4.
      ROLLBACK WORK.
      EXIT.
    ELSE.
      fc_subrc = 0.
      LOOP AT i_messtab INTO wa_messtab WHERE msgv1 IS NOT INITIAL.
        i_main-sgtxt = wa_messtab-msgv1.
      ENDLOOP.

      MODIFY i_main TRANSPORTING sgtxt
                    WHERE zuonr = lt_post-zuonr.

      PERFORM f_save_to_zfvatshipbtm USING wa_messtab-msgv1
                                           lt_post-zuodt
                                           lt_post-vkorg
                                           lt_post-vkbur
                                           lt_post-zuonr.
      CLEAR i_main.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " run_bdc

*************************************************************
FORM f_dynpro USING dynbegin name value.
*************************************************************
  IF dynbegin =  'X'.
    CLEAR:  wa_bdc.
    MOVE: name  TO wa_bdc-program,
          value TO wa_bdc-dynpro ,
          'X'   TO wa_bdc-dynbegin.
    APPEND wa_bdc TO i_bdc.
  ELSE.
    CLEAR:  wa_bdc.
    MOVE: name    TO wa_bdc-fnam,
          value   TO wa_bdc-fval.
    APPEND wa_bdc TO i_bdc.
  ENDIF.
ENDFORM.                               " F_DYNPRO

*&---------------------------------------------------------------------*
*&      Form  F_GET_FR_SHIPMENT
*&---------------------------------------------------------------------*
FORM f_get_fr_shipment .
  DATA : lv_lines TYPE int4,
         lv_subrc TYPE sy-subrc.

  SELECT SINGLE *
    FROM zproject
    INTO CORRESPONDING FIELDS OF gs_coretax
    WHERE name = 'CORETAX'.

  IF p_vkorg = '8020'.
    SELECT tknum datbg erdat
      FROM vttk
      INTO TABLE gt_vttk
      WHERE tknum IN so_tknum
        AND datbg IN so_erdat.
  ELSE.
    SELECT tknum erdat
      FROM vttk
      INTO TABLE gt_vttk
      WHERE tknum IN so_tknum
        AND erdat IN so_erdat.
  ENDIF.

  IF p_vkorg = '8220'.
    DESCRIBE TABLE gt_vttk LINES lv_lines.
    IF lv_lines > 1.
      lv_subrc = 4.
      MESSAGE s000(zab) WITH 'Proses hanya untuk 1 Shipment'
                        DISPLAY LIKE 'E'.
    ENDIF.
  ELSE.
    lv_subrc = 0.
  ENDIF.

  IF lv_subrc IS INITIAL.
    IF gt_vttk[] IS NOT INITIAL.
      SELECT tknum tpnum vbeln erdat
        FROM vttp
        INTO TABLE gt_vttp
        FOR ALL ENTRIES IN gt_vttk
        WHERE tknum = gt_vttk-tknum.
    ENDIF.
  ENDIF.

  IF gt_vttk[] IS NOT INITIAL.
    SELECT *
      FROM zcoretax0005
      INTO CORRESPONDING FIELDS OF TABLE gt_005
      FOR ALL ENTRIES IN gt_vttk
      WHERE belnr = gt_vttk-tknum.
  ENDIF.
ENDFORM.                    " F_GET_FR_SHIPMENT

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TO_ZFVATSHIPBTM
*&---------------------------------------------------------------------*
FORM f_save_to_zfvatshipbtm  USING    fu_belnr fu_bldat fu_vkorg fu_vkbur
                                      fu_zuonr.
  DATA : lt_zfvatshipbtm TYPE zfvatshipbtm OCCURS 0,
         ls_zfvatshipbtm TYPE zfvatshipbtm,
         lv_tknum        LIKE vttp-tknum.

  DATA : lt_mseg LIKE i_mseg OCCURS 0,
         ls_mseg LIKE i_mseg.

  SORT i_mseg BY mblnr.
  LOOP AT i_mseg.
    ls_mseg-mblnr   = i_mseg-mblnr.
    ls_mseg-mjahr   = i_mseg-mjahr.
    ls_mseg-matnr   = i_mseg-matnr.
    ls_mseg-waers   = i_mseg-waers.
    ls_mseg-dmbtr   = i_mseg-dmbtr.
    ls_mseg-menge   = i_mseg-menge.
    ls_mseg-meins   = i_mseg-meins.
    COLLECT ls_mseg INTO lt_mseg.
    CLEAR ls_mseg.
  ENDLOOP.

  LOOP AT i_main WHERE zuonr  = fu_zuonr.
    CLEAR lv_tknum.
    lv_tknum  =  i_main-zuonr.
    READ TABLE gt_vttp WITH KEY tknum = lv_tknum.
    IF sy-subrc = 0.
      ls_zfvatshipbtm-tknum   = gt_vttp-tknum.
      ls_zfvatshipbtm-erdat   = gt_vttp-erdat.
    ENDIF.

    ls_zfvatshipbtm-belnr   = fu_belnr.
    ls_zfvatshipbtm-bldat   = fu_bldat.
    ls_zfvatshipbtm-erdat1  = i_main-erdat.

    ls_zfvatshipbtm-vbeln   = i_main-vbelv.
    READ TABLE gt_likp WITH KEY vbeln = i_main-vbelv.
    IF sy-subrc = 0.
      ls_zfvatshipbtm-wadat_ist   = gt_likp-wadat_ist.
    ENDIF.

    LOOP AT lt_mseg INTO ls_mseg WHERE mblnr = i_main-vbeln.
      ls_zfvatshipbtm-mblnr   = ls_mseg-mblnr.
      ls_zfvatshipbtm-mjahr   = ls_mseg-mjahr.
      ls_zfvatshipbtm-matnr   = ls_mseg-matnr.
      ls_zfvatshipbtm-waers   = ls_mseg-waers.
      ls_zfvatshipbtm-dmbtr   = ls_mseg-dmbtr.
      ls_zfvatshipbtm-lfimg   = ls_mseg-menge.
      ls_zfvatshipbtm-meins   = ls_mseg-meins.
*      READ TABLE gt_lips WITH KEY vbeln = i_main-vbelv
*                                  matnr = ls_zfvatshipbtm-matnr.
*      IF sy-subrc = 0.
*        ls_zfvatshipbtm-lfimg = gt_lips-lfimg.
*        ls_zfvatshipbtm-meins = gt_lips-meins.
*      ENDIF.
      APPEND ls_zfvatshipbtm TO lt_zfvatshipbtm.
    ENDLOOP.
    CLEAR ls_zfvatshipbtm.
  ENDLOOP.

  TRY .
      INSERT zfvatshipbtm FROM TABLE lt_zfvatshipbtm.
    CATCH cx_sy_open_sql_db.
      ROLLBACK WORK.
      EXIT.
  ENDTRY.
ENDFORM.                    " F_SAVE_TO_ZFVATSHIPBTM

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ZFVATO
*&---------------------------------------------------------------------*
FORM f_modify_zfvato TABLES   ft_zfvato STRUCTURE zfvato.
  CLEAR : ft_zfvato[], ft_zfvato.

  LOOP AT i_main.
    ft_zfvato = i_main.
    IF p_vkorg = '8220'.
      ft_zfvato-gsber = '2200'.
    ENDIF.
    ft_zfvato-vbeln   = i_main-zuonr.
    ft_zfvato-fkdat   = i_main-zuodt.
    ft_zfvato-dudat   = i_main-zuodt.
    ft_zfvato-vbelv   = i_main-zuonr.
    ft_zfvato-budat   = i_main-zuodt.
    ft_zfvato-bldat   = i_main-zuodt.
    ft_zfvato-erdat   = i_main-zuodt.
    COLLECT ft_zfvato.
    CLEAR ft_zfvato.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_ZFVATO

*&---------------------------------------------------------------------*
*&      Form  F_TAX_CALC
*&---------------------------------------------------------------------*
FORM f_tax_calc  USING    fu_datum fu_wrbtr fu_calty
                 CHANGING fc_wrbtr.
  DATA : lv_wrbtr   TYPE netwr_ak.

  lv_wrbtr  = fu_wrbtr.

  CALL FUNCTION 'Z_PPN11'
    EXPORTING
      pi_wrbtr = lv_wrbtr
      pi_calty = fu_calty
      pi_datum = fu_datum
    IMPORTING
      po_wrbtr = lv_wrbtr.

  fc_wrbtr  = lv_wrbtr.
ENDFORM.                    " F_TAX_CALC
