*&---------------------------------------------------------------------*
*& Report  ZS_CREATE_QUOTATION_B2B
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  zs_create_quotation_b2b NO STANDARD PAGE HEADING
                                LINE-SIZE 150
                                MESSAGE-ID zs.

TABLES : zsh_b2b,zsd_b2b,knvp,zserr_b2b,vbak.
TYPE-POOLS abap.
TYPES:   BEGIN OF t_bdc.
           INCLUDE STRUCTURE bdcdata.
         TYPES:   END OF t_bdc.
TYPES:   BEGIN OF t_messtab.
           INCLUDE STRUCTURE bdcmsgcoll.
         TYPES:   END OF t_messtab.
TYPES: BEGIN OF t_log_error,
         bukrs   LIKE bsis-bukrs,
         hkont   LIKE bsis-hkont,
         gjahr   LIKE bsis-gjahr,
         belnr   LIKE bsis-belnr,
         msg(80),
       END OF t_log_error.

TYPES : BEGIN OF ty_auart,
          doc_type_qt TYPE bapisdhd1-doc_type,
          doc_type_so TYPE bapisdhd1-doc_type,
        END OF ty_auart.

DATA: t_zplbc  LIKE zplbc OCCURS 0 WITH HEADER LINE.
DATA: t_zscust_control TYPE TABLE OF zscust_control  WITH HEADER LINE.

DATA: BEGIN OF t_zsh_b2b OCCURS 0.
        INCLUDE STRUCTURE zsh_b2b.
        DATA:   mahdt LIKE  vbak-mahdt,
        kvgr4 LIKE  knvv-kvgr4.
DATA : auart_qt TYPE bapisdhd1-doc_type,
       auart_so TYPE bapisdhd1-doc_type,
       xauart,
       END OF t_zsh_b2b.

DATA: BEGIN OF t_update_qt OCCURS 0.
        INCLUDE STRUCTURE zsh_b2b.
        DATA:   mahdt LIKE  vbak-mahdt,
        kvgr4 LIKE  knvv-kvgr4.
DATA : auart_qt TYPE bapisdhd1-doc_type,
       auart_so TYPE bapisdhd1-doc_type,
       xauart,
       END OF t_update_qt.

DATA: BEGIN OF t_create_so OCCURS 0.
        INCLUDE STRUCTURE zsh_b2b.
        DATA:   mahdt LIKE  vbak-mahdt,
        kvgr4 LIKE vbak-kvgr4.
DATA : auart_qt TYPE bapisdhd1-doc_type,
       auart_so TYPE bapisdhd1-doc_type,
       xauart,
       END OF t_create_so.

DATA: BEGIN OF t_vbap OCCURS 0,
        vbeln  LIKE vbap-vbeln,
        posnr  LIKE vbap-posnr,
        matnr  LIKE vbap-matnr,
        meins  LIKE vbap-meins,
        kwmeng LIKE vbap-kwmeng,
      END OF t_vbap.

DATA : BEGIN OF t_zsd_b2b OCCURS 0.
         INCLUDE STRUCTURE zsd_b2b.
       DATA : END OF t_zsd_b2b.

DATA: t_knvp      LIKE knvp OCCURS 0 WITH HEADER LINE,
      t_error_qt  LIKE zserr_b2b OCCURS 0 WITH HEADER LINE,
      t_error_qt1 LIKE zserr_b2b OCCURS 0 WITH HEADER LINE,
      t_update_so LIKE zsh_b2b OCCURS 0 WITH HEADER LINE,
      t_error_so  LIKE zserr_b2b OCCURS 0 WITH HEADER LINE,
      t_error_so1 LIKE zserr_b2b OCCURS 0 WITH HEADER LINE.

DATA: i_messtab    TYPE t_messtab OCCURS 0,
      wa_messtab   TYPE t_messtab,
      i_bdc        TYPE t_bdc OCCURS 0,
      wa_bdc       TYPE t_bdc,
      va_mode(1),
      i_log_error  TYPE t_log_error OCCURS 0,
      wa_log_error TYPE t_log_error.

DATA : gt_custcntrl TYPE STANDARD TABLE OF zscust_control INITIAL SIZE 0.
DATA: lock TYPE boolean.

SELECTION-SCREEN BEGIN OF BLOCK aaa WITH FRAME TITLE TEXT-001.
PARAMETERS: p_vkorg LIKE zsh_b2b-vkorg DEFAULT '8020' OBLIGATORY,
*                p_mjahr LIKE zsh_b2b-mjahr DEFAULT sy-datum(4) OBLIGATORY,
            p_parvw LIKE knvp-parvw DEFAULT 'SH' NO-DISPLAY,
            p_vtweg LIKE knvp-vtweg DEFAULT '10' NO-DISPLAY,
            p_spart LIKE knvp-spart DEFAULT '00' NO-DISPLAY.
SELECT-OPTIONS: s_vkbur FOR zsh_b2b-vkbur,
                s_kunnr FOR zsh_b2b-kunnr,
                s_znob2b FOR zsh_b2b-znob2b,
                s_ebeln FOR zsh_b2b-ebeln,
                s_bedat FOR zsh_b2b-bedat,
                s_aedat FOR zsh_b2b-aedat.
SELECTION-SCREEN SKIP.
PARAMETERS: test_run(1),
            p_force(1)  NO-DISPLAY,
            p_deter(1)  NO-DISPLAY,
            p_rejec(1)  NO-DISPLAY,
            p_chang(1)  NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK aaa.

INITIALIZATION.
  PERFORM f_check_lock_program.

START-OF-SELECTION.

**  PERFORM f_check_lock_program.
  PERFORM f_get_data.
  PERFORM f_process_data.

  IF p_rejec = 'X'.
    PERFORM f_reject_qt_po.
  ELSEIF p_chang = 'X'.
    PERFORM f_change_qt_po.
  ELSE.
    PERFORM f_create_quotation.
    PERFORM f_validation_so.
    PERFORM f_create_so.
    PERFORM f_write_report.
  ENDIF.

END-OF-SELECTION.

TOP-OF-PAGE.
  PERFORM f_header_page.

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data .
  DATA: ld_bnddt  LIKE sy-datum.
  ld_bnddt  = sy-datum - 10.

  IF s_vkbur[] IS INITIAL.
    SELECT werks
      FROM zplbc
      INTO CORRESPONDING FIELDS OF TABLE t_zplbc
      WHERE b2blive EQ 'X'.
    LOOP AT t_zplbc.
      s_vkbur-low      = t_zplbc-werks.
      s_vkbur-sign     = 'I'.
      s_vkbur-option   = 'EQ'.
      APPEND s_vkbur.
    ENDLOOP.
  ENDIF.

  SELECT * INTO TABLE t_zscust_control
    FROM zscust_control
    WHERE vkorg = p_vkorg
      AND cek = 'B2B'
      AND field_name = 'TB2'.

** Get New data
  SELECT * INTO CORRESPONDING FIELDS OF TABLE t_zsh_b2b
    FROM zsh_b2b
    WHERE bnddt GE ld_bnddt  AND
          vkorg = p_vkorg    AND
          vkbur  IN s_vkbur  AND
          kunnr  IN s_kunnr  AND
          znob2b IN s_znob2b AND
          ebeln  IN s_ebeln  AND
          bedat  IN s_bedat  AND
          aedat  IN s_aedat  AND
          z_uplod NE 'DL'    AND
          vbeln = space      AND
          netwr >= 0
    ORDER BY PRIMARY KEY.
  IF sy-subrc = 0.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE t_zsd_b2b
      FROM zsd_b2b
      FOR ALL ENTRIES IN t_zsh_b2b
      WHERE znob2b = t_zsh_b2b-znob2b
      ORDER BY PRIMARY KEY.

    PERFORM f_get_auart.
  ENDIF.

** Get Quotation Data
  SELECT * INTO CORRESPONDING FIELDS OF TABLE t_update_qt
    FROM zsh_b2b
    WHERE bnddt GE ld_bnddt  AND
          vkorg = p_vkorg    AND
          vkbur  IN s_vkbur  AND
          kunnr  IN s_kunnr  AND
          znob2b IN s_znob2b AND
          ebeln  IN s_ebeln  AND
          bedat  IN s_bedat  AND
          aedat  IN s_aedat  AND
          vbeln  NE space    AND
          z_uplod = 'QT'
    ORDER BY PRIMARY KEY.
  IF sy-subrc = 0.
    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE t_zsd_b2b
      FROM zsd_b2b
      FOR ALL ENTRIES IN t_update_qt
      WHERE znob2b = t_update_qt-znob2b
      ORDER BY PRIMARY KEY.
  ENDIF.

  IF t_zsh_b2b[] IS INITIAL AND t_update_qt[] IS INITIAL.
    MESSAGE i000(zs) WITH 'No data'.
    STOP.
  ENDIF.
ENDFORM.                    " f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data .

  DATA: ld_kdgrp LIKE knvv-kdgrp.
  DATA: lt_knvv  TYPE TABLE OF knvv WITH HEADER LINE.
  DATA: lt_zsh_b2b LIKE t_zsh_b2b OCCURS 0 WITH HEADER LINE.

  APPEND LINES OF t_zsh_b2b TO lt_zsh_b2b.
  APPEND LINES OF t_update_qt TO lt_zsh_b2b.

  SORT lt_zsh_b2b BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_zsh_b2b COMPARING kunnr.

  SELECT * INTO TABLE lt_knvv
    FROM knvv FOR ALL ENTRIES IN lt_zsh_b2b
    WHERE kunnr = lt_zsh_b2b-kunnr
      AND vkorg = p_vkorg
      AND vtweg = '10'
      AND spart = '00'.

  LOOP AT t_zsh_b2b.
*    SELECT SINGLE kdgrp INTO ld_kdgrp
*      FROM knvv
*      WHERE kunnr = t_zsh_b2b-kunnr AND
*            vkorg = t_zsh_b2b-vkorg AND
*            vtweg = '10'            AND
*            spart = '00'.
*    IF ld_kdgrp = '02' OR ld_kdgrp = '03' OR
*      ld_kdgrp = '06' OR ld_kdgrp = '08' OR
*      ld_kdgrp = '10'.
*      t_zsh_b2b-mahdt   = sy-datum + 30.
*    ELSE.
*      t_zsh_b2b-mahdt   = sy-datum + 21.
*    ENDIF.
    CLEAR lt_knvv.
    READ TABLE lt_knvv WITH KEY kunnr = t_zsh_b2b-kunnr.
    IF lt_knvv-kdgrp = '02' OR lt_knvv-kdgrp = '03' OR
       lt_knvv-kdgrp = '06' OR lt_knvv-kdgrp = '08' OR
       lt_knvv-kdgrp = '10'.
      t_zsh_b2b-mahdt   = sy-datum + 30.
    ELSE.
      t_zsh_b2b-mahdt   = sy-datum + 21.
    ENDIF.
    t_zsh_b2b-kvgr4 = lt_knvv-kvgr4.

    MODIFY t_zsh_b2b TRANSPORTING mahdt kvgr4.
    CLEAR: ld_kdgrp, t_zsh_b2b.
  ENDLOOP.

  LOOP AT t_update_qt.
    SELECT SINGLE mahdt INTO t_update_qt-mahdt
      FROM vbak
      WHERE vbeln = t_update_qt-vbeln.
    CLEAR lt_knvv.
    READ TABLE lt_knvv WITH KEY kunnr = t_update_qt-kunnr.
    t_update_qt-kvgr4 = lt_knvv-kvgr4.

    MODIFY t_update_qt TRANSPORTING mahdt kvgr4.
    CLEAR t_update_qt.
  ENDLOOP.

**** Proses Lock data for next proses.
  CLEAR: lt_zsh_b2b[].
  lt_zsh_b2b[] = t_update_qt[].
  CLEAR: t_update_qt[].
  LOOP AT lt_zsh_b2b.
    CALL FUNCTION 'ENQUEUE_EZSH_B2B'
      EXPORTING
        znob2b         = lt_zsh_b2b-znob2b
        mjahr          = lt_zsh_b2b-mjahr
        ebeln          = lt_zsh_b2b-ebeln
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc EQ 0.
      APPEND lt_zsh_b2b TO t_update_qt.
    ELSE.
      WRITE: / 'Gagal Lock data (SO) : ',   lt_zsh_b2b-znob2b, sy-vline, lt_zsh_b2b-mjahr, sy-vline, lt_zsh_b2b-ebeln.
    ENDIF.
  ENDLOOP.

  CLEAR: lt_zsh_b2b[].
  lt_zsh_b2b[] = t_zsh_b2b[].
  CLEAR: t_zsh_b2b[].
  LOOP AT lt_zsh_b2b.
    CALL FUNCTION 'ENQUEUE_EZSH_B2B'
      EXPORTING
        znob2b         = lt_zsh_b2b-znob2b
        mjahr          = lt_zsh_b2b-mjahr
        ebeln          = lt_zsh_b2b-ebeln
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc EQ 0.
      APPEND lt_zsh_b2b TO t_zsh_b2b.
    ELSE.
      WRITE: / 'Gagal Lock data (Quotation) : ',   lt_zsh_b2b-znob2b, sy-vline, lt_zsh_b2b-mjahr, sy-vline, lt_zsh_b2b-ebeln.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " f_process_data

*&---------------------------------------------------------------------*
*&      Form  f_create_quotation
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_quotation .

  DATA: order_header_in     LIKE bapisdhd1,
        order_items_in      LIKE bapisditm OCCURS 0 WITH HEADER LINE,
        order_partners      LIKE bapiparnr OCCURS 0 WITH HEADER LINE,
        order_schedules_in  LIKE bapischdl OCCURS 0 WITH HEADER LINE,
        order_conditions_in LIKE bapicond OCCURS 0 WITH HEADER LINE,
        ld_return           LIKE bapiret2  OCCURS 0 WITH HEADER LINE,
        ld_salesdocument    LIKE bapivbeln-vbeln,
        ld_menge1(15),
        ld_menge1a(15),
        ld_menge1b(15),
        ld_menge2           LIKE t_zsd_b2b-menge,
        ld_erzet            TYPE sy-uzeit,
        lv_datum            TYPE sy-datum,
        lv_datum1           TYPE i,
        lv_datum2           TYPE i,
        lv_stsed            TYPE int4,
        lv_stsdb            TYPE int4.

  DATA : lv_erdat   TYPE vbak-erdat.

  DATA : lt_zscust_control TYPE STANDARD TABLE OF zscust_control INITIAL SIZE 0,
         ls_zscust_control LIKE LINE OF lt_zscust_control,
         lt_holiday        LIKE iscal_day OCCURS 0,
         lv_subrc          TYPE sy-subrc.

  CONCATENATE sy-datum(6) '01' INTO lv_erdat.
  lv_erdat = lv_erdat - 1.
  DO 2 TIMES.
    CONCATENATE lv_erdat(6) '01' INTO lv_erdat.
    lv_erdat = lv_erdat - 1.
  ENDDO.
  CONCATENATE lv_erdat(6) '01' INTO lv_erdat.

  SELECT *
    FROM zscust_control
    INTO CORRESPONDING FIELDS OF TABLE lt_zscust_control
    WHERE vkorg       = p_vkorg
      AND cek         IN ('CMO', 'FAT')
      AND field_name  = 'KVGR4'
    ORDER BY PRIMARY KEY.

  SORT: t_zsh_b2b BY znob2b mjahr ebeln,
        t_zsd_b2b BY znob2b ebelp.

** Create Quotation
  LOOP AT t_zsh_b2b.

    CLEAR: order_header_in, order_items_in, order_partners, order_schedules_in,
           ld_salesdocument.
    REFRESH: order_items_in, order_partners, order_schedules_in.

    CLEAR : lv_datum1, lv_datum, lv_stsdb, lv_stsed.

* Validasi  Exp. Date
    IF t_zsh_b2b-bnddt <= sy-datum.
      IF test_run IS INITIAL.
        UPDATE zsh_b2b SET z_uplod = 'ED'
                       WHERE znob2b = t_zsh_b2b-znob2b
                         AND mjahr  = t_zsh_b2b-mjahr
                         AND ebeln  = t_zsh_b2b-ebeln.
        lv_stsed = 1.
      ENDIF.
    ENDIF.

* Validasi PO B2B <> VBAK-BSTNK
    SELECT SINGLE *
      FROM vbak
      WHERE vkbur = t_zsh_b2b-vkbur
        AND vkorg = t_zsh_b2b-vkorg
        AND bstnk = t_zsh_b2b-ebeln
        AND erdat >= lv_erdat.
    IF sy-subrc = 0.
      IF test_run IS INITIAL.
        UPDATE zsh_b2b SET z_uplod = 'DB'
                       WHERE znob2b = t_zsh_b2b-znob2b
                         AND mjahr  = t_zsh_b2b-mjahr
                         AND ebeln  = t_zsh_b2b-ebeln.
        lv_stsdb = 1.
      ENDIF.
    ENDIF.

    IF lv_stsed IS NOT INITIAL AND
      lv_stsdb IS NOT INITIAL.
      UPDATE zsh_b2b SET z_uplod = 'EB'
                     WHERE znob2b = t_zsh_b2b-znob2b
                       AND mjahr  = t_zsh_b2b-mjahr
                       AND ebeln  = t_zsh_b2b-ebeln.
      CONTINUE.
    ELSEIF lv_stsed IS NOT INITIAL.
      CONTINUE.
    ELSEIF lv_stsdb IS NOT INITIAL.
      CONTINUE.
    ENDIF.

    READ TABLE lt_zscust_control INTO ls_zscust_control
                                 WITH KEY vkorg       = t_zsh_b2b-vkorg
                                          field_value = t_zsh_b2b-kvgr4.
    IF sy-subrc = 0.
      lv_datum  = t_zsh_b2b-bnddt.

      DO ls_zscust_control-field_value2 TIMES.
        CLEAR lv_subrc.
        WHILE lv_subrc IS INITIAL.
          CALL FUNCTION 'HOLIDAY_GET'
            EXPORTING
              holiday_calendar           = 'ID'
              factory_calendar           = 'T1'
              date_from                  = lv_datum
              date_to                    = lv_datum
            TABLES
              holidays                   = lt_holiday
            EXCEPTIONS
              factory_calendar_not_found = 1
              holiday_calendar_not_found = 2
              date_has_invalid_format    = 3
              date_inconsistency         = 4
              OTHERS                     = 5.
          IF lt_holiday[] IS INITIAL.
            lv_subrc = 4.
            lv_datum  = lv_datum - 1.
          ELSE.
            lv_datum  = lv_datum - 1.
          ENDIF.
          CLEAR : lt_holiday[], lt_holiday.
        ENDWHILE.
      ENDDO.

      CLEAR lv_subrc.
      WHILE lv_subrc IS INITIAL.
        CALL FUNCTION 'HOLIDAY_GET'
          EXPORTING
            holiday_calendar           = 'ID'
            factory_calendar           = 'T1'
            date_from                  = lv_datum
            date_to                    = lv_datum
          TABLES
            holidays                   = lt_holiday
          EXCEPTIONS
            factory_calendar_not_found = 1
            holiday_calendar_not_found = 2
            date_has_invalid_format    = 3
            date_inconsistency         = 4
            OTHERS                     = 5.
        IF lt_holiday[] IS INITIAL.
          lv_subrc = 4.
        ELSE.
          lv_datum  = lv_datum - 1.
        ENDIF.
        CLEAR : lt_holiday[], lt_holiday.
      ENDWHILE.

      IF ls_zscust_control-cek = 'CMO'.
        lv_datum1  = t_zsh_b2b-bnddt - t_zsh_b2b-bedat.
        lv_datum2  = t_zsh_b2b-bnddt - sy-datum.
        IF lv_datum1 <= ls_zscust_control-field_value3
          AND lv_datum2 <= ls_zscust_control-field_value3.
          lv_datum  = t_zsh_b2b-bedat.
        ELSE.
          IF lv_datum <= sy-datum.
            lv_datum  = t_zsh_b2b-bnddt.
          ELSE.
            CONTINUE.
          ENDIF.
        ENDIF.
      ELSEIF ls_zscust_control-cek = 'FAT'.
*****        lv_datum1  = t_zsh_b2b-bnddt - t_zsh_b2b-bedat.
*****        lv_datum2  = t_zsh_b2b-bnddt - sy-datum.
*****        IF lv_datum1 <= ls_zscust_control-field_value3
*****          AND lv_datum2 <= ls_zscust_control-field_value3.
*****          lv_datum  = t_zsh_b2b-bedat.
*****        ELSE.
*****          IF lv_datum <= sy-datum.
*****            lv_datum  = t_zsh_b2b-bnddt.
*****          ELSE.
*****            CONTINUE.
*****          ENDIF.
*****        ENDIF.
        IF lv_datum <= sy-datum.
          lv_datum  = t_zsh_b2b-bedat.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDIF.
    ELSE.
      lv_datum  = sy-datum.
    ENDIF.

    IF t_zsh_b2b-xauart IS NOT INITIAL.
      PERFORM f_order_header_in USING order_header_in t_zsh_b2b-vkorg
                                      t_zsh_b2b-auart_qt t_zsh_b2b-ebeln t_zsh_b2b-bedat
                                      t_zsh_b2b-bnddt t_zsh_b2b-mahdt lv_datum
                                      '' '' '' '' ''.
      PERFORM f_order_partners TABLES order_partners
                               USING  t_zsh_b2b-kunnr.

      LOOP AT t_zsd_b2b WHERE znob2b = t_zsh_b2b-znob2b.
        PERFORM f_order_items_in TABLES order_items_in
                                 USING 'QT' '' t_zsd_b2b-ebelp t_zsd_b2b-matnr.
        PERFORM f_order_schedules_in TABLES order_schedules_in
                                     USING 'QT' t_zsd_b2b-ebelp t_zsd_b2b-menge
                                           t_zsd_b2b-meins.
      ENDLOOP.
    ELSE.
      order_header_in-sales_org  = t_zsh_b2b-vkorg.
      order_header_in-sales_off  = t_zsh_b2b-vkbur.
      order_header_in-doc_type   = t_zsh_b2b-auart_qt.
      order_header_in-distr_chan = '10'.
      order_header_in-division   = '00'.
      order_header_in-ord_reason = 'A12'.
      order_header_in-dlvschduse = 'M'.
*    order_header_in-date_type  = '1'.
      order_header_in-req_date_h = sy-datum.
      order_header_in-purch_date = t_zsh_b2b-bedat.
      order_header_in-purch_no_c = t_zsh_b2b-ebeln.
      order_header_in-qt_valid_t = t_zsh_b2b-bnddt.
      order_header_in-price_date = lv_datum.
      order_header_in-dun_date   = t_zsh_b2b-mahdt.
*    order_header_in-po_supplem = order_header-po_supplem.
*    order_header_in-ref_1      = order_header-ref_1.
*    order_header_in-name       = order_header-name.
*    order_header_in-po_method  = 'DFUE'.
*    order_header_in-alttax_cls = '1'.

      order_partners-partn_role     = p_parvw.
      order_partners-partn_numb     = t_zsh_b2b-kunnr.
      APPEND order_partners.

      LOOP AT t_zsd_b2b WHERE znob2b = t_zsh_b2b-znob2b.
        CLEAR: ld_menge1, ld_menge1a, ld_menge1b, ld_menge2.
*      order_items_in-itm_number     = t_zsd_b2b-ebelp.
        order_items_in-material       = t_zsd_b2b-matnr.
        order_items_in-plant          = order_header_in-sales_off.
        order_items_in-cust_mat22     = t_zsd_b2b-material.
*      order_items_in-target_qty     = t_zsd_b2b-menge.
        APPEND order_items_in. CLEAR order_items_in.

        order_schedules_in-itm_number = t_zsd_b2b-ebelp.
*      order_schedules_in-sched_line = t_zsd_b2b-ebelp.
** Revisi 14/04/2009
        WRITE t_zsd_b2b-menge TO ld_menge1.
        SPLIT ld_menge1 AT ',' INTO ld_menge1a ld_menge1b.
        REPLACE '.' WITH ' ' INTO ld_menge1a.
        REPLACE '.' WITH ' ' INTO ld_menge1a.
        REPLACE '.' WITH ' ' INTO ld_menge1a.
        CONDENSE ld_menge1a NO-GAPS.
        ld_menge2 = ld_menge1a.
*      order_schedules_in-req_qty    = t_zsd_b2b-menge.
        order_schedules_in-req_qty    = ld_menge2.
** Revisi 14/04/2009
        APPEND order_schedules_in. CLEAR order_schedules_in.
      ENDLOOP.
    ENDIF.

    CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
      EXPORTING
        order_header_in     = order_header_in
        convert             = 'X'
        testrun             = test_run
      IMPORTING
        salesdocument       = ld_salesdocument
      TABLES
        return              = ld_return
        order_items_in      = order_items_in
        order_partners      = order_partners
        order_schedules_in  = order_schedules_in
        order_conditions_in = order_conditions_in.

    IF ld_salesdocument IS NOT INITIAL.
      t_update_qt = t_zsh_b2b.
      t_update_qt-vbeln = ld_salesdocument.
      t_update_qt-z_uplod = 'QT'.
      MODIFY zsh_b2b FROM t_update_qt.
      APPEND t_update_qt. CLEAR t_update_qt.
      COMMIT WORK AND WAIT.

      MOVE-CORRESPONDING t_zsh_b2b TO t_error_qt1.
      APPEND t_error_qt1. CLEAR t_error_qt1.
    ELSE.
      MOVE-CORRESPONDING t_zsh_b2b TO t_error_qt.
      LOOP AT ld_return.
        MOVE-CORRESPONDING ld_return TO t_error_qt.
        t_error_qt-line = sy-tabix.
        APPEND t_error_qt.
      ENDLOOP.
      CLEAR t_error_qt.
    ENDIF.
  ENDLOOP.

** Modify table
  "  MODIFY zsh_b2b FROM TABLE t_update_qt.  --> dipindah ke atas update per record pas quotation terbentuk
  MODIFY zserr_b2b FROM TABLE t_error_qt.
  LOOP AT t_error_qt1.
    DELETE FROM zserr_b2b WHERE znob2b = t_error_qt1-znob2b AND
                                mjahr = t_error_qt1-mjahr.
  ENDLOOP.

ENDFORM.                    " f_create_quotation

*&---------------------------------------------------------------------*
*&      Form  f_validation_so
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validation_so .

  DATA: ld_selisih      LIKE vbap-kzwi5,
        ld_selisih1     LIKE vbap-kzwi5,
        ld_selisih2(10) TYPE c,
        ld_fvalue2      LIKE vbap-kzwi5,
        ld_fvalue3      LIKE vbap-kzwi5,
        l_value(10)     TYPE n.

  DATA: lv_vbeln LIKE vbuk-vbeln,
        lv_gbstk LIKE vbuk-gbstk.

  CLEAR: t_create_so.
  REFRESH: t_create_so.

  LOOP AT t_update_qt.
    CLEAR: lv_vbeln,lv_gbstk.
    SELECT SINGLE vbeln gbstk INTO (lv_vbeln,lv_gbstk)
      FROM vbuk WHERE vbeln = t_update_qt-vbeln
                  AND gbstk <> 'A'.
*                  AND gbstk = 'C'.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING t_update_qt TO t_error_qt.
      t_error_qt-type = 'E'.
      t_error_qt-message = 'SO sudah Complete'.
      APPEND t_error_qt. CLEAR t_error_qt.
      DELETE t_update_qt.
      CONTINUE.
    ENDIF.

    CLEAR: ld_selisih, t_update_qt-qtquo.
    SELECT SUM( kzwi5 ) INTO t_update_qt-qtquo
      FROM vbap
      WHERE vbeln = t_update_qt-vbeln.
    ld_selisih = ( t_update_qt-qtquo - t_update_qt-brtwr ) * 100.

    IF p_force = 'X'.
      ld_selisih1 = ld_selisih / 1000.
      WRITE ld_selisih1 TO ld_selisih2 DECIMALS 0.
      REPLACE '.' WITH ' ' INTO ld_selisih2.
      REPLACE '.' WITH ' ' INTO ld_selisih2.
      CONDENSE ld_selisih2 NO-GAPS.
      l_value = ld_selisih2.
      AUTHORITY-CHECK OBJECT 'ZB2B'
          ID 'ACTVT' FIELD '89'
          ID 'ZAMOUNT' FIELD l_value.
      IF sy-subrc = 0.
        IF t_update_qt-kvgr4 = '106'.
        ELSE.
          APPEND t_update_qt TO t_create_so.
        ENDIF.
      ENDIF.
    ELSE.
      CLEAR: ld_fvalue2,ld_fvalue3,t_zscust_control.
      READ TABLE t_zscust_control WITH KEY field_value = t_update_qt-kvgr4.
      IF sy-subrc = 0.
        ld_fvalue2 = t_zscust_control-field_value2.
        ld_fvalue3 = t_zscust_control-field_value3.
      ENDIF.
*      IF ld_selisih BETWEEN -2000 AND 2000.
      IF ld_selisih BETWEEN ld_fvalue2 AND ld_fvalue3.
        IF t_update_qt-kvgr4 = '106'.
        ELSE.
          APPEND t_update_qt TO t_create_so.
        ENDIF.
      ELSE.
        MOVE-CORRESPONDING t_update_qt TO t_error_qt.
        t_error_qt-type = 'E'.
        t_error_qt-message = 'Selisih diluar Toleransi per KAGroup'.
        APPEND t_error_qt. CLEAR t_error_qt.
        DELETE t_update_qt.
      ENDIF.
    ENDIF.

    MODIFY t_update_qt TRANSPORTING qtquo.
    MODIFY zsh_b2b FROM t_update_qt.
    COMMIT WORK AND WAIT.
  ENDLOOP.

  IF t_create_so[] IS NOT INITIAL.
    SELECT vbeln posnr matnr meins kwmeng
      INTO CORRESPONDING FIELDS OF TABLE t_vbap
      FROM vbap
      FOR ALL ENTRIES IN t_create_so
      WHERE vbeln = t_create_so-vbeln
      ORDER BY PRIMARY KEY.
  ENDIF.

** Modify table
**  MODIFY zsh_b2b FROM TABLE t_update_qt.
**  COMMIT WORK AND WAIT.

ENDFORM.                    " f_validation_so

*&---------------------------------------------------------------------*
*&      Form  f_create_so
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_so .

  DATA: order_header_in     LIKE bapisdhd1,
        order_items_in      LIKE bapisditm OCCURS 0 WITH HEADER LINE,
        order_partners      LIKE bapiparnr OCCURS 0 WITH HEADER LINE,
        order_schedules_in  LIKE bapischdl OCCURS 0 WITH HEADER LINE,
        order_conditions_in LIKE bapicond OCCURS 0 WITH HEADER LINE,
        ld_return           LIKE bapiret2  OCCURS 0 WITH HEADER LINE,
        ld_salesdocument    LIKE bapivbeln-vbeln,
        ld_menge1(15),
        ld_menge1a(15),
        ld_menge1b(15),
        ld_menge2           LIKE t_zsd_b2b-menge,
        ld_erzet            TYPE sy-uzeit.

  DATA : lt_zscust_control TYPE STANDARD TABLE OF zscust_control INITIAL SIZE 0,
         ls_zscust_control LIKE LINE OF lt_zscust_control,
         lv_datum          TYPE sy-datum,
         lt_holiday        LIKE iscal_day OCCURS 0,
         lv_subrc          TYPE sy-subrc,
         lv_datum1         TYPE i,
         lv_datum2         TYPE i.

  IF t_create_so[] IS NOT INITIAL.
    SELECT *
    FROM zscust_control
    INTO CORRESPONDING FIELDS OF TABLE lt_zscust_control
    WHERE vkorg       = p_vkorg
      AND cek         IN ('CMO', 'FAT')
      AND field_name  = 'KVGR4'.

    LOOP AT t_create_so.

      CLEAR: order_header_in, order_items_in, order_partners, order_schedules_in,
             ld_salesdocument.
      REFRESH: order_items_in, order_partners, order_schedules_in.

      READ TABLE lt_zscust_control INTO ls_zscust_control
                                   WITH KEY vkorg       = t_create_so-vkorg
                                            field_value = t_create_so-kvgr4.

      IF sy-subrc = 0.
        lv_datum  = t_zsh_b2b-bnddt.

        DO ls_zscust_control-field_value2 TIMES.
          CLEAR lv_subrc.
          WHILE lv_subrc IS INITIAL.
            CALL FUNCTION 'HOLIDAY_GET'
              EXPORTING
                holiday_calendar           = 'ID'
                factory_calendar           = 'T1'
                date_from                  = lv_datum
                date_to                    = lv_datum
              TABLES
                holidays                   = lt_holiday
              EXCEPTIONS
                factory_calendar_not_found = 1
                holiday_calendar_not_found = 2
                date_has_invalid_format    = 3
                date_inconsistency         = 4
                OTHERS                     = 5.
            IF lt_holiday[] IS INITIAL.
              lv_subrc = 4.
              lv_datum  = lv_datum - 1.
            ELSE.
              lv_datum  = lv_datum - 1.
            ENDIF.
            CLEAR : lt_holiday[], lt_holiday.
          ENDWHILE.
        ENDDO.

        CLEAR lv_subrc.
        WHILE lv_subrc IS INITIAL.
          CALL FUNCTION 'HOLIDAY_GET'
            EXPORTING
              holiday_calendar           = 'ID'
              factory_calendar           = 'T1'
              date_from                  = lv_datum
              date_to                    = lv_datum
            TABLES
              holidays                   = lt_holiday
            EXCEPTIONS
              factory_calendar_not_found = 1
              holiday_calendar_not_found = 2
              date_has_invalid_format    = 3
              date_inconsistency         = 4
              OTHERS                     = 5.
          IF lt_holiday[] IS INITIAL.
            lv_subrc = 4.
          ELSE.
            lv_datum  = lv_datum - 1.
          ENDIF.
          CLEAR : lt_holiday[], lt_holiday.
        ENDWHILE.

        IF ls_zscust_control-cek = 'CMO'.
          lv_datum1  = t_zsh_b2b-bnddt - t_zsh_b2b-bedat.
          lv_datum2  = t_zsh_b2b-bnddt - sy-datum.
          IF lv_datum1 <= ls_zscust_control-field_value3
            AND lv_datum2 <= ls_zscust_control-field_value3.
            lv_datum  = t_zsh_b2b-bedat.
          ELSE.
            IF lv_datum <= sy-datum.
              lv_datum  = t_zsh_b2b-bnddt.
            ELSE.
              CONTINUE.
            ENDIF.
          ENDIF.
        ELSEIF ls_zscust_control-cek = 'FAT'.
*****          lv_datum1  = t_zsh_b2b-bnddt - t_zsh_b2b-bedat.
*****          lv_datum2  = t_zsh_b2b-bnddt - sy-datum.
*****          IF lv_datum1 <= ls_zscust_control-field_value3
*****            AND lv_datum2 <= ls_zscust_control-field_value3.
*****            lv_datum  = t_zsh_b2b-bedat.
*****          ELSE.
*****            IF lv_datum <= sy-datum.
*****              lv_datum  = t_zsh_b2b-bnddt.
*****            ELSE.
*****              CONTINUE.
*****            ENDIF.
*****          ENDIF.
          IF lv_datum <= sy-datum.
            lv_datum  = t_zsh_b2b-bedat.
          ELSE.
            CONTINUE.
          ENDIF.
        ENDIF.
      ELSE.
        lv_datum  = sy-datum.
      ENDIF.

      IF t_create_so-xauart IS NOT INITIAL.
        PERFORM f_order_header_in USING order_header_in t_create_so-vkorg
                                        t_create_so-auart_so
                                        t_create_so-ebeln
                                        t_create_so-bedat t_create_so-bnddt
                                        t_create_so-mahdt lv_datum
                                        'C'
                                        t_create_so-auart_qt
                                        'C' t_create_so-vbeln
                                        sy-datum.
        PERFORM f_order_partners TABLES order_partners
                                 USING  t_create_so-kunnr.

        LOOP AT t_vbap WHERE vbeln = t_create_so-vbeln.
          PERFORM f_order_items_in TABLES order_items_in
                                   USING 'SO' t_vbap-vbeln t_vbap-posnr t_vbap-matnr.
          PERFORM f_order_schedules_in TABLES order_schedules_in
                                       USING 'SO' t_vbap-posnr t_vbap-kwmeng
                                             t_vbap-meins.
        ENDLOOP.
      ELSE.
        order_header_in-sales_org  = t_create_so-vkorg.
        order_header_in-sales_off  = t_create_so-vkbur.
        order_header_in-doc_type   = 'ZOT9'.
        order_header_in-distr_chan = '10'.
        order_header_in-division   = '00'.
        order_header_in-ord_reason = 'A12'.
        order_header_in-dlvschduse = 'M'.
        order_header_in-sd_doc_cat = 'C'.
        order_header_in-refdoctype = 'ZQN9'.
        order_header_in-refdoc_cat = 'C'.
        order_header_in-ref_doc    = t_create_so-vbeln.
        order_header_in-req_date_h = sy-datum.
        order_header_in-purch_date = t_create_so-bedat.
        order_header_in-purch_no_c = t_create_so-ebeln.
        order_header_in-qt_valid_t = t_create_so-bnddt.
        order_header_in-price_date = lv_datum. "sy-datum.
        order_header_in-dun_date   = t_create_so-mahdt.

        order_partners-partn_role     = p_parvw.
        order_partners-partn_numb     = t_create_so-kunnr.
        APPEND order_partners.

*    LOOP AT t_zsd_b2b WHERE znob2b = t_create_so-znob2b.
*
*      CLEAR: ld_menge1, ld_menge1a, ld_menge1b, ld_menge2.
*      order_items_in-ref_doc        = t_create_so-vbeln.
**      order_items_in-ref_doc_it     = t_zsd_b2b-ebelp.
*      order_items_in-ref_doc_ca     = 'C'.
**      order_items_in-itm_number     = t_zsd_b2b-ebelp.
*      order_items_in-material       = t_zsd_b2b-matnr.
*      order_items_in-plant          = order_header_in-sales_off.
*      order_items_in-cust_mat22     = t_zsd_b2b-material.
*      APPEND order_items_in.
*
**      order_schedules_in-itm_number = t_zsd_b2b-ebelp.
*      order_schedules_in-sched_line = t_zsd_b2b-ebelp.
*** Revisi 14/04/2009
*      WRITE t_zsd_b2b-menge TO ld_menge1.
*      SPLIT ld_menge1 AT ',' INTO ld_menge1a ld_menge1b.
*      REPLACE '.' WITH ' ' INTO ld_menge1a.
*      REPLACE '.' WITH ' ' INTO ld_menge1a.
*      REPLACE '.' WITH ' ' INTO ld_menge1a.
*      CONDENSE ld_menge1a NO-GAPS.
*      ld_menge2 = ld_menge1a.
**      order_schedules_in-req_qty    = t_zsd_b2b-menge.
*      order_schedules_in-req_qty    = ld_menge2.
*** Revisi 14/04/2009
*      APPEND order_schedules_in.
*
*    ENDLOOP.

        LOOP AT t_vbap WHERE vbeln = t_create_so-vbeln.

          CLEAR: ld_menge1, ld_menge1a, ld_menge1b, ld_menge2.
          order_items_in-ref_doc        = t_vbap-vbeln.
          order_items_in-ref_doc_it     = t_vbap-posnr.
          order_items_in-ref_doc_ca     = 'C'.
*      order_items_in-itm_number     = t_zsd_b2b-ebelp.
          order_items_in-material       = t_vbap-matnr.
          order_items_in-plant          = order_header_in-sales_off.
          order_items_in-cust_mat22     = t_vbap-matnr.
          APPEND order_items_in.

*      order_schedules_in-itm_number = t_zsd_b2b-ebelp.
          order_schedules_in-sched_line = t_vbap-posnr.
** Revisi 14/04/2009
          WRITE t_vbap-kwmeng TO ld_menge1.
          SPLIT ld_menge1 AT ',' INTO ld_menge1a ld_menge1b.
          REPLACE '.' WITH ' ' INTO ld_menge1a.
          REPLACE '.' WITH ' ' INTO ld_menge1a.
          REPLACE '.' WITH ' ' INTO ld_menge1a.
          CONDENSE ld_menge1a NO-GAPS.
          ld_menge2 = ld_menge1a.
*      order_schedules_in-req_qty    = t_zsd_b2b-menge.
          order_schedules_in-req_qty    = ld_menge2.
** Revisi 14/04/2009
          APPEND order_schedules_in.
        ENDLOOP.
      ENDIF.

      CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
        EXPORTING
          order_header_in    = order_header_in
          convert            = 'X'
          testrun            = test_run
        IMPORTING
          salesdocument      = ld_salesdocument
        TABLES
          return             = ld_return
          order_items_in     = order_items_in
          order_partners     = order_partners
          order_schedules_in = order_schedules_in.

      IF ld_salesdocument IS NOT INITIAL.
        t_update_so = t_create_so.
        t_update_so-vbeln = ld_salesdocument.
        t_update_so-z_uplod = 'SO'.
        MODIFY zsh_b2b FROM t_update_so.
        COMMIT WORK AND WAIT.
        APPEND t_update_so. CLEAR t_update_so.
        MOVE-CORRESPONDING t_create_so TO t_error_so1.
        APPEND t_error_so1. CLEAR t_error_so1.
      ELSE.
        MOVE-CORRESPONDING t_create_so TO t_error_so.
        LOOP AT ld_return.
          MOVE-CORRESPONDING ld_return TO t_error_so.
          t_error_so-line = sy-tabix.
          APPEND t_error_so.
        ENDLOOP.
        CLEAR t_error_so.
      ENDIF.

    ENDLOOP.

** Modify table
    "    MODIFY zsh_b2b FROM TABLE t_update_so. dipindahkan keatas proses update per record bukan per table
    MODIFY zserr_b2b FROM TABLE t_error_so.
    LOOP AT t_error_so1.
      DELETE FROM zserr_b2b WHERE znob2b = t_error_so1-znob2b AND
                                  mjahr = t_error_so1-mjahr.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_create_so

*&---------------------------------------------------------------------*
*&      Form  f_write_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_report .

  SORT t_update_qt BY znob2b mjahr ebeln.
  SORT t_update_so BY znob2b mjahr ebeln.
  SORT t_error_qt BY znob2b mjahr ebeln.
  SORT t_error_so BY znob2b mjahr ebeln.

** Quotation
  LOOP AT t_update_qt.
    CALL FUNCTION 'DEQUEUE_EZSH_B2B'
      EXPORTING
        znob2b         = t_update_qt-znob2b
        mjahr          = t_update_qt-mjahr
        ebeln          = t_update_qt-ebeln
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc NE 0.
      WRITE: / 'Gagal Proses Unlock (Quotation)'.
    ENDIF.
**    WRITE:/ t_update_qt-znob2b,
**            t_update_qt-mjahr,
**            t_update_qt-ebeln,
**            t_update_qt-vbeln,
**            t_update_qt-z_uplod.
  ENDLOOP.

** SO
  LOOP AT t_update_so.
    CALL FUNCTION 'DEQUEUE_EZSH_B2B'
      EXPORTING
        znob2b         = t_update_so-znob2b
        mjahr          = t_update_so-mjahr
        ebeln          = t_update_so-ebeln
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc NE 0.
      WRITE: / 'Gagal Proses Unlock (SO)'.
    ENDIF.
**    WRITE:/ t_update_so-znob2b,
**            t_update_so-mjahr,
**            t_update_so-ebeln,
**            t_update_so-vbeln,
**            t_update_so-z_uplod.
  ENDLOOP.

  NEW-PAGE.

** Quotation
  LOOP AT t_error_qt.
    CALL FUNCTION 'DEQUEUE_EZSH_B2B'
      EXPORTING
        znob2b         = t_error_qt-znob2b
        mjahr          = t_error_qt-mjahr
        ebeln          = t_error_qt-ebeln
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc NE 0.
      WRITE: / 'Gagal Proses Unlock (error Quotation)'.
    ENDIF.
    WRITE:/ t_error_qt-znob2b,
            t_error_qt-mjahr,
            t_error_qt-ebeln,
            t_error_qt-type,
           (100) t_error_qt-message.
    AT END OF znob2b.
      WRITE:/ sy-uline.
    ENDAT.
  ENDLOOP.

** SO
  LOOP AT t_error_so.
    CALL FUNCTION 'DEQUEUE_EZSH_B2B'
      EXPORTING
        znob2b         = t_error_so-znob2b
        mjahr          = t_error_so-mjahr
        ebeln          = t_error_so-ebeln
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc NE 0.
      WRITE: / 'Gagal Proses Unlock (error SO)'.
    ENDIF.
    WRITE:/ t_error_so-znob2b,
            t_error_so-mjahr,
            t_error_so-ebeln,
            t_error_so-type,
           (100) t_error_so-message.
    AT END OF znob2b.
      WRITE:/ sy-uline.
    ENDAT.
  ENDLOOP.

ENDFORM.                    " f_write_report

*&---------------------------------------------------------------------*
*&      Form  f_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0530   text
*      -->P_0531   text
*      -->P_0532   text
*----------------------------------------------------------------------*
FORM f_dynpro  USING dynbegin name value.
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
ENDFORM.                    " f_dynpro

*&---------------------------------------------------------------------*
*&      Form  f_header_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_header_page .
  WRITE:/ sy-uline.
  WRITE:/ 'Tees'.
  WRITE:/ sy-uline.
ENDFORM.                    " f_header_page

*&---------------------------------------------------------------------*
*&      Form  f_reject_qt_po
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_reject_qt_po .

  DATA: salesdocumentin  LIKE bapivbeln-vbeln,
        order_header_in  LIKE bapisdhd1,
        order_header_inx LIKE bapisdhd1x,
        order_partners   LIKE bapiparnr OCCURS 0 WITH HEADER LINE,
        ld_return        LIKE bapiret2  OCCURS 0 WITH HEADER LINE,
        ld_salesdocument LIKE bapivbeln-vbeln.

** Reject Quotation
  LOOP AT t_update_qt.

    CLEAR: ld_salesdocument,salesdocumentin,order_header_in,order_header_inx,order_partners.
    REFRESH: order_partners.

    salesdocumentin = t_update_qt-vbeln.

    order_header_in-sales_org  = t_update_qt-vkorg.
    order_header_in-sales_off  = t_update_qt-vkbur.
    order_header_in-doc_type   = t_update_qt-auart_qt.
    order_header_in-distr_chan = '10'.
    order_header_in-division   = '00'.
    order_header_in-ord_reason = 'A12'.
    order_header_in-dlvschduse = 'M'.
    order_header_in-purch_date = t_update_qt-bedat.
    order_header_in-purch_no_c = t_update_qt-ebeln.
    order_header_in-qt_valid_t = t_update_qt-bnddt.

    order_header_inx-updateflag = 'D'.

    order_partners-partn_role     = p_parvw.
    order_partners-partn_numb     = t_update_qt-kunnr.
    APPEND order_partners.

    CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
      EXPORTING
        salesdocumentin  = salesdocumentin
        order_header_in  = order_header_in
        order_header_inx = order_header_inx
        testrun          = test_run
      IMPORTING
        salesdocument    = ld_salesdocument
      TABLES
        return           = ld_return
        order_partners   = order_partners.

    IF sy-subrc = 0.
      t_update_qt-z_uplod = 'DL'.
      MODIFY t_update_qt TRANSPORTING z_uplod.
      MODIFY zsh_b2b FROM t_update_qt.
      COMMIT WORK AND WAIT.
      CLEAR t_update_qt.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDLOOP.

** Modify table
**  MODIFY zsh_b2b FROM TABLE t_update_qt.
**  COMMIT WORK AND WAIT.

** Reject PO
  LOOP AT t_zsh_b2b.
    t_zsh_b2b-z_uplod = 'DL'.
    MODIFY t_zsh_b2b TRANSPORTING z_uplod.
    MODIFY zsh_b2b FROM t_zsh_b2b.
    COMMIT WORK AND WAIT.
    CLEAR t_zsh_b2b.
  ENDLOOP.

** Modify table
**  MODIFY zsh_b2b FROM TABLE t_zsh_b2b.
**  COMMIT WORK AND WAIT.
ENDFORM.                    " f_reject_qt_po

*&---------------------------------------------------------------------*
*&      Form  f_change_qt_po
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_change_qt_po .

  DATA: salesdocumentin  LIKE bapivbeln-vbeln,
        order_header_in  LIKE bapisdhd1,
        order_header_inx LIKE bapisdhd1x,
        order_partners   LIKE bapiparnr OCCURS 0 WITH HEADER LINE,
        ld_return        LIKE bapiret2  OCCURS 0 WITH HEADER LINE,
        ld_salesdocument LIKE bapivbeln-vbeln.

** Reject Quotation
  LOOP AT t_update_qt.

    CLEAR: ld_salesdocument,salesdocumentin,order_header_in,order_header_inx,order_partners.
    REFRESH: order_partners.

    salesdocumentin = t_update_qt-vbeln.

    order_header_in-sales_org  = t_update_qt-vkorg.
    order_header_in-sales_off  = t_update_qt-vkbur.
    order_header_in-doc_type   = t_update_qt-auart_qt.
    order_header_in-distr_chan = '10'.
    order_header_in-division   = '00'.
    order_header_in-ord_reason = 'A12'.
    order_header_in-dlvschduse = 'M'.
    order_header_in-purch_date = t_update_qt-bedat.
    order_header_in-purch_no_c = t_update_qt-ebeln.
    order_header_in-qt_valid_t = t_update_qt-bnddt.

    order_header_inx-updateflag = 'D'.

    order_partners-partn_role     = p_parvw.
    order_partners-partn_numb     = t_update_qt-kunnr.
    APPEND order_partners.

    CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
      EXPORTING
        salesdocumentin  = salesdocumentin
        order_header_in  = order_header_in
        order_header_inx = order_header_inx
        testrun          = test_run
      IMPORTING
        salesdocument    = ld_salesdocument
      TABLES
        return           = ld_return
        order_partners   = order_partners.

    IF sy-subrc = 0.
      t_update_qt-z_uplod = 'DL'.
      MODIFY t_update_qt TRANSPORTING z_uplod.
      MODIFY zsh_b2b FROM t_update_qt.
      COMMIT WORK AND WAIT.
      CLEAR t_update_qt.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

  ENDLOOP.

** Modify table
**  MODIFY zsh_b2b FROM TABLE t_update_qt.


** Reject PO
  LOOP AT t_zsh_b2b.
    t_zsh_b2b-z_uplod = 'DL'.
    MODIFY t_zsh_b2b TRANSPORTING z_uplod.
    MODIFY zsh_b2b FROM t_zsh_b2b.
    COMMIT WORK AND WAIT.
    CLEAR t_zsh_b2b.
  ENDLOOP.

** Modify table
**  MODIFY zsh_b2b FROM TABLE t_zsh_b2b.
**  COMMIT WORK AND WAIT.
ENDFORM.                    " f_change_qt_po

*&---------------------------------------------------------------------*
*&      Form  F_GET_DOC_TYPE
*&---------------------------------------------------------------------*
FORM f_get_auart .
  DATA : lt_zsd_b2b   TYPE STANDARD TABLE OF zsd_b2b INITIAL SIZE 0,
         ls_custcntrl LIKE LINE OF gt_custcntrl,
         lt_mara      TYPE STANDARD TABLE OF mara,
         ls_mara      LIKE LINE OF lt_mara,
         lr_matkl     TYPE RANGE OF matkl,
         ls_matkl     LIKE LINE OF lr_matkl,
         lv_field     TYPE zscust_control-field_value,
         lt_auart     TYPE STANDARD TABLE OF ty_auart,
         ls_auart     LIKE LINE OF lt_auart,
         lv_lines     TYPE i,
         lv_xauart.

  lt_zsd_b2b[]  = t_zsd_b2b[].
  SORT lt_zsd_b2b BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_zsd_b2b COMPARING matnr.

  IF lt_zsd_b2b[] IS NOT INITIAL.
    SELECT matnr matkl
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE lt_mara
      FOR ALL ENTRIES IN lt_zsd_b2b
      WHERE matnr = lt_zsd_b2b-matnr.
  ENDIF.

  SELECT *
    FROM zscust_control
    INTO CORRESPONDING FIELDS OF TABLE gt_custcntrl
    WHERE vkorg      = p_vkorg
      AND cek        = 'B2B'
      AND field_name = 'MATKL'.

  LOOP AT gt_custcntrl INTO ls_custcntrl.
    ls_matkl-low    = ls_custcntrl-field_value.
    ls_matkl-sign   = 'I'.
    ls_matkl-option = 'EQ'.
    APPEND ls_matkl TO lr_matkl.
    CLEAR ls_matkl.
  ENDLOOP.

  LOOP AT t_zsh_b2b.
    LOOP AT t_zsd_b2b WHERE znob2b = t_zsh_b2b-znob2b.
      READ TABLE lt_mara INTO ls_mara WITH KEY matnr = t_zsd_b2b-matnr.
      IF sy-subrc = 0.
        IF ls_mara-matkl IN lr_matkl.
          lv_field  = ls_mara-matkl.
          READ TABLE gt_custcntrl INTO ls_custcntrl WITH KEY field_value = lv_field.
          IF sy-subrc = 0.
            ls_auart-doc_type_qt = ls_custcntrl-field_value2.
            ls_auart-doc_type_so = ls_custcntrl-field_value3.
            APPEND ls_auart TO lt_auart.

            lv_xauart = 'X'.
          ENDIF.
        ELSE.
          ls_auart-doc_type_qt = 'ZQN9'.
          APPEND ls_auart TO lt_auart.

          CLEAR : lv_xauart.
        ENDIF.
      ENDIF.
      CLEAR t_zsd_b2b.
    ENDLOOP.

    SORT lt_auart BY doc_type_qt.
    DELETE ADJACENT DUPLICATES FROM lt_auart COMPARING doc_type_qt.
    DESCRIBE TABLE lt_auart LINES lv_lines.
    IF lv_lines = 1.
      READ TABLE lt_auart INTO ls_auart INDEX 1.
      IF sy-subrc = 0.
        t_zsh_b2b-auart_qt  = ls_auart-doc_type_qt.
        t_zsh_b2b-auart_so  = ls_auart-doc_type_so.
      ENDIF.
      t_zsh_b2b-xauart  = lv_xauart.
      MODIFY t_zsh_b2b TRANSPORTING xauart auart_qt auart_so.
    ELSE.
      UPDATE zsh_b2b SET z_uplod = 'MX'
                     WHERE znob2b = t_zsh_b2b-znob2b
                       AND mjahr  = t_zsh_b2b-mjahr
                       AND ebeln  = t_zsh_b2b-ebeln.

      DELETE t_zsh_b2b.
      DELETE t_zsd_b2b WHERE znob2b = t_zsh_b2b-znob2b.
    ENDIF.
    CLEAR : lt_auart[], lt_auart, ls_auart, lv_xauart.
  ENDLOOP.
ENDFORM.                    " F_GET_AUART

*&---------------------------------------------------------------------*
*&      Form  F_ORDER_HEADER_IN
*&---------------------------------------------------------------------*
FORM f_order_header_in USING order_header_in LIKE bapisdhd1
                             fu_vkorg fu_auart fu_ebeln fu_bedat fu_bnddt
                             fu_mahdt fu_datum fu_vbtyp fu_auart_ref
                             fu_vbtyp_v fu_vbeln fu_datum_ref.
  order_header_in-sales_org     = fu_vkorg.
  order_header_in-distr_chan    = '10'.
  order_header_in-division      = '00'.
  order_header_in-doc_type      = fu_auart.

  order_header_in-purch_no_c    = fu_ebeln.
  order_header_in-purch_date    = fu_bedat.
  order_header_in-qt_valid_t    = fu_bnddt.
  order_header_in-price_date    = fu_datum.
  order_header_in-dun_date      = fu_mahdt.

  order_header_in-ord_reason    = 'A12'.
  order_header_in-dlvschduse    = 'M'.

  IF fu_vbtyp IS NOT INITIAL.
    order_header_in-sd_doc_cat = fu_vbtyp.
    order_header_in-refdoctype = fu_auart_ref.
    order_header_in-refdoc_cat = fu_vbtyp_v.
    order_header_in-ref_doc    = fu_vbeln.
    order_header_in-req_date_h = fu_datum_ref.
  ENDIF.
ENDFORM.                    " F_ORDER_HEADER_IN

*&---------------------------------------------------------------------*
*&      Form  F_ORDER_ITEMS_IN
*&---------------------------------------------------------------------*
FORM f_order_items_in TABLES order_items_in STRUCTURE bapisditm
                      USING  fu_proc fu_vbeln fu_ebelp fu_matnr.
  DATA : ls_item  LIKE LINE OF order_items_in.

  CASE fu_proc.
    WHEN 'QT'.
      ls_item-itm_number  = fu_ebelp.
    WHEN 'SO'.
      ls_item-ref_doc        = fu_vbeln.
      ls_item-ref_doc_it     = fu_ebelp.
      ls_item-ref_doc_ca     = 'C'.
  ENDCASE.
  ls_item-material    = fu_matnr.
  APPEND ls_item TO order_items_in.
ENDFORM.                    " F_ORDER_ITEMS_IN

*&---------------------------------------------------------------------*
*&      Form  F_ORDER_PARTNERS
*&---------------------------------------------------------------------*
FORM f_order_partners TABLES order_partners STRUCTURE bapiparnr
                      USING  fu_kunnr.
  DATA : ls_partners  LIKE LINE OF order_partners.

  ls_partners-partn_role  = p_parvw.
  ls_partners-partn_numb  = fu_kunnr.
  APPEND ls_partners TO order_partners.
ENDFORM.                    " F_ORDER_PARTNERS

*&---------------------------------------------------------------------*
*&      Form  F_ORDER_SCHEDULES_IN
*&---------------------------------------------------------------------*
FORM f_order_schedules_in TABLES order_schedules_in STRUCTURE bapischdl
                          USING  fu_proc fu_ebelp fu_menge fu_meins.
  DATA : ls_schedules_in LIKE LINE OF order_schedules_in,
         lv_menge(20).

  WRITE fu_menge TO lv_menge UNIT fu_meins.
  TRANSLATE lv_menge USING '. '.
  TRANSLATE lv_menge USING ',.'.
  CONDENSE lv_menge NO-GAPS.

  CASE fu_proc.
    WHEN 'QT'.
      ls_schedules_in-itm_number  = fu_ebelp.
    WHEN 'SO'.
      ls_schedules_in-sched_line = fu_ebelp.
  ENDCASE.
  ls_schedules_in-req_qty     = lv_menge.
  APPEND ls_schedules_in TO order_schedules_in.
ENDFORM.                    " F_ORDER_SCHEDULES_IN
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_LOCK_PROGRAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_lock_program .
  IF lock = abap_off.
    PERFORM enqueue_program.
  ELSE.
    PERFORM dequeue_program.
  ENDIF.
ENDFORM.                    " F_CHECK_LOCK_PROGRAM
*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_PROGRAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM enqueue_program .
  "  CALL FUNCTION 'ENQUEUE_E_DSVAS_TRDIR'
  CALL FUNCTION 'ENQUEUE_E_TRDIR'        "SOH: Shell Remediation Adjustment 20240401 KRS
    EXPORTING
      mode_trdir     = 'X'
      name           = sy-repid
      x_name         = ' '
      _scope         = '2'
      _wait          = ' '
      _collect       = ' '
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    lock = abap_on.
  ENDIF.
ENDFORM.                    " ENQUEUE_PROGRAM
*&---------------------------------------------------------------------*
*&      Form  DEQUEUE_PROGRAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM dequeue_program .
  lock = abap_off.

  "  CALL FUNCTION 'DEQUEUE_E_DSVAS_TRDIR'
  CALL FUNCTION 'DEQUEUE_E_TRDIR'        "SOH: Shell Remediation Adjustment 20240401 KRS
    EXPORTING
      mode_trdir = 'X'
      name       = sy-repid
      x_name     = ' '
      _scope     = '3'
      _synchron  = ' '
      _collect   = ' '.
ENDFORM.                    " DEQUEUE_PROGRAM
