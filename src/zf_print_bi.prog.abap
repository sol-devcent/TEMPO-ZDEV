REPORT zf_print_bi MESSAGE-ID zs NO STANDARD PAGE HEADING
                                  LINE-COUNT 90
                                  LINE-SIZE  210.


************************************************************************
*                  REPORT                                              *
*----------------------------------------------------------------------*
* ABAP Name   :                                                        *
* Created by  :                                                        *
* Created on  :                                                        *
* Version     : 0.0                                                    *
* Include     :                                                        *
*----------------------------------------------------------------------*
* Description :                                                        *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
*& CRNO#          DATE         AUTHOR         DESCRIPTION              *
*& DEVK935887     19.08.2013                  Modifikasi untuk SUT     *
*&                                            Project                  *
*----------------------------------------------------------------------*
****************************************************
*        Tables                                    *
****************************************************
TABLES: bsid,
        knvv,
        knvp,
        vrkpa,
        kna1,
        knb1,
        tsab,
        tvstt,
        pa0001,
        zfbih,
        zfbid.


************************************************************************
* STRUCTURES & INTERNAL TABLES                                         *
************************************************************************
TYPES : BEGIN OF t_itab1,
                kunnr   LIKE   bsid-kunnr,
                zuonr   LIKE   bseg-zuonr,
                bukrs	LIKE   bsid-bukrs,
                hkont	LIKE 	bsid-kunnr,
                gjahr	LIKE 	bsid-gjahr,
                belnr	LIKE 	bsid-belnr,
                budat	LIKE 	bsid-budat,
                bldat	LIKE 	bsid-bldat,
                waers	LIKE 	bsid-waers,
                xblnr	LIKE 	bsid-xblnr,
                blart	LIKE 	bsid-blart,
                monat	LIKE 	bsid-monat,
                shkzg	LIKE 	bsid-shkzg,
                wrbtr	LIKE 	bsid-wrbtr,
                zfbdt	LIKE   bsid-zfbdt,
                zbd1t   LIKE   bsid-zbd1t,
                buzei   LIKE   bsid-buzei,
                gsber   LIKE   bsid-gsber,
                zlspr   LIKE bsid-zlspr,
                vkbur	LIKE 	knvv-vkbur,
                spart	LIKE 	knvv-spart,
                parvw	LIKE 	vrkpa-parvw,
                kunde	LIKE 	vrkpa-kunde,
                namev   LIKE   knvk-namev,
                name1   LIKE   knvk-name1,
                pernr   LIKE   knb1-pernr,
                vbeln   LIKE zfbid-vbeln,
                fkdat   LIKE zfbid-fkdat,
                zuonr1  LIKE zfbid-slcod,
                wrbtr1 LIKE   bsid-wrbtr,
                xref1 LIKE bsid-xref1,
                xref2 LIKE bsid-xref2,
                xref3 LIKE bsid-xref3,
                bbeln LIKE zfbid-bbeln,
                ebelp  LIKE zfbid-ebelp,
                pstat LIKE zfbid-pstat,
                vbund LIKE bsid-vbund,
                erdt2 LIKE zfbid-erdt2,
        END OF t_itab1,
        BEGIN OF t_itab2,
                belnr	LIKE 	bsid-belnr,
        END OF t_itab2.

TYPES:   BEGIN OF t_bdc.
        INCLUDE STRUCTURE bdcdata.
TYPES:   END OF t_bdc.

TYPES:   BEGIN OF t_messtab.
        INCLUDE STRUCTURE bdcmsgcoll.
TYPES:   END OF t_messtab.

TYPES: BEGIN OF t_log_error,
            bukrs     LIKE bsis-bukrs,
            gjahr     LIKE bsis-gjahr,
            belnr     LIKE bsis-belnr,
            msg(80),
       END OF t_log_error.


DATA: v_title1(95),                            "title line 1
      v_title2(95),                            "title line 2
      v_title3(95),                            "title line 3
      v_title4(95),                            "extranous title line
      v_title5(95),                            "extranous title line
      v_current_page(10),                      "current page

      v_left_header_len    TYPE i VALUE 18,   "space for report id
      v_right_header_len   TYPE i VALUE 17,   "space for date stamp
      v_between_header_len TYPE i,            "space in between
      v_repid(30)          TYPE c,            "report id
      v_right              TYPE i.            "position for date field

CONSTANTS:
      c_report(9)   TYPE c VALUE 'Report  :',
      c_clisys(9)   TYPE c VALUE 'Cli/Sys :',
      c_userid(9)   TYPE c VALUE 'UserID  :',
      c_date(6)     TYPE c VALUE 'Date :',
      c_time(6)     TYPE c VALUE 'Time :',
      c_page(6)     TYPE c VALUE 'Page :'.


************************************************************************
* CONSTANTS                                                            *
************************************************************************
*constants :

************************************************************************
* VARIABLES                                                            *
************************************************************************
DATA:
       v_line_size TYPE i,
       v_line_size_sum TYPE i,
       va_mark(1),
       c1    TYPE i,
       c2    TYPE i,
       c3    TYPE i,
       c4    TYPE i,
       lkunde LIKE vbpa-kunnr,
       flock(1),
       rcode        LIKE sy-subrc,
       w1    TYPE i,  w2    TYPE i,  w3    TYPE i,  w4    TYPE i,
       w5    TYPE i,  w6    TYPE i,  w7    TYPE i,  w8    TYPE i,
       w9    TYPE i,  w10   TYPE i,  w11   TYPE i,  w12   TYPE i,
       w13   TYPE i,  w14   TYPE i,  w15   TYPE i,  w16   TYPE i,
       w17   TYPE i,  w18   TYPE i,  w19   TYPE i,  w19a  TYPE i,
       w20   TYPE i,  w17a  TYPE i,
       w21   TYPE i,  w22   TYPE i,  w23   TYPE i,  w24   TYPE i,
       w25   TYPE i,  w26   TYPE i,  w27   TYPE i,  w28   TYPE i,
       w29   TYPE i,  w30   TYPE i,  w31   TYPE i,  w32   TYPE i,
       w33   TYPE i,  w34   TYPE i,  w35   TYPE i.

DATA: i_itab1 TYPE t_itab1 OCCURS 100 WITH HEADER LINE,
      wa_itab1 TYPE t_itab1,
      i_itab2 TYPE t_itab1 OCCURS 0,
      i_itab3 TYPE t_itab1 OCCURS 100 WITH HEADER LINE,
      i_itab6 TYPE t_itab1 OCCURS 100 WITH HEADER LINE,
      i_itab7 TYPE t_itab1 OCCURS 100 WITH HEADER LINE,
      wa_itab2 TYPE t_itab2,
      i_itab4 TYPE t_itab1 OCCURS 0,
      wa_itab3 TYPE t_itab1,
      i_bdc TYPE t_bdc OCCURS 0,
      i_itab5 TYPE t_itab1 OCCURS 0,
      wa_bdc TYPE t_bdc,
      i_messtab TYPE t_messtab OCCURS 0,
      wa_messtab TYPE t_messtab,
      i_log_error TYPE t_log_error OCCURS 0,
      wa_log_error TYPE t_log_error,
      nilai LIKE bsid-wrbtr,
      nilai_sfa LIKE bsid-wrbtr,
      msg(80),va_vbund LIKE bsid-vbund,
      flag(1),
      v_zbd1t LIKE bsid-zbd1t,
*      rt TYPE i,   " replace for SUT
      rt(10),
      v_zuonr(11),va_nou1 TYPE i,
      va_bbeln TYPE zbbeln, " zfbih-bbeln,
      va_ebelp LIKE zfbid-ebelp,
      va_sw TYPE i.

DATA: BEGIN OF t_zfh_kr1at OCCURS 0.
        INCLUDE STRUCTURE zfh_kr1at.
DATA: END OF t_zfh_kr1at.

DATA:   BEGIN OF t_bdc OCCURS 0.
        INCLUDE STRUCTURE bdcdata.
DATA:   END OF t_bdc.

DATA:   BEGIN OF messtab OCCURS 0.
        INCLUDE STRUCTURE bdcmsgcoll.
DATA:   END OF messtab.

DATA : BEGIN OF itab OCCURS 0,
       belnr LIKE bsid-belnr,
       buzei LIKE bsid-buzei,
    END OF itab.

DATA:   BEGIN OF t_zfbid OCCURS 0.
        INCLUDE STRUCTURE zfbid.
DATA:   END OF t_zfbid.

DATA: BEGIN OF t_error OCCURS 0.
        INCLUDE STRUCTURE t_zfh_kr1at.
DATA: END OF t_error.

DATA: gt_zfbid_sfa TYPE TABLE OF zfbid_sfa WITH HEADER LINE.

************************************************************************
* INCLUDES                                                             *
************************************************************************
*INCLUDE ZSHEADER.
INCLUDE <%_list>.

DATA:     va_line(1024),
          va_linectr TYPE i,
          pa_kunde LIKE vrkpa-kunde,
          va_parvw LIKE vrkpa-parvw,
          va_nou   TYPE i,
          va_namev LIKE knvk-namev,
          va_name1 LIKE knvk-name1,
          va_collector(30),
          tot_wrbtr LIKE wa_itab1-wrbtr,
          sw(1),pa_vtweg(2) VALUE '10',
          va_list TYPE slist_listline.

DATA: va_count TYPE i.

DATA gt_fcode TYPE TABLE OF sy-ucomm.

****************************************************
*        Parameters                                *
****************************************************
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS pa_bukrs LIKE t001-bukrs DEFAULT '8020' OBLIGATORY.
PARAMETERS pa_vkbur LIKE knvv-vkbur DEFAULT '0201' OBLIGATORY.
PARAMETERS val LIKE bsid-dmbtr.
SELECT-OPTIONS so_parnr FOR  knb1-pernr  NO INTERVALS.
PARAMETERS pa_route LIKE vbpa-kunnr.
SELECT-OPTIONS so_kunnr FOR  kna1-kunnr.
SELECT-OPTIONS so_duedt FOR bsid-zfbdt.
SELECT-OPTIONS so_belnr FOR  zfbid-bbeln  MODIF ID aab.
SELECT-OPTIONS do_no FOR bsid-zuonr NO INTERVALS.
PARAMETER belnr LIKE zfbid-bbeln OBLIGATORY MODIF ID aac.
*     PARAMETER PA_GJAHR(4) DEFAULT SY-DATUM(4) MODIF ID AAD.
PARAMETERS pa_name(20) OBLIGATORY.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS print RADIOBUTTON GROUP grp1 USER-COMMAND ars.
SELECTION-SCREEN : COMMENT 5(35) text-006 FOR FIELD print.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS koreksi RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) text-005 FOR FIELD koreksi.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS v_del RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) text-007 FOR FIELD v_del.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS reprint RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) text-004 FOR FIELD reprint.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK block1.
************************************************************************
* PROGRAM                                                              *
************************************************************************
************************************************************************
* AT SELECTION-SCREEN
************************************************************************
AT SELECTION-SCREEN ON pa_bukrs.
  IF pa_bukrs EQ '8020' OR pa_bukrs EQ '8010' OR
     pa_bukrs EQ '8030' OR pa_bukrs EQ '8070'.
  ELSE.
    MESSAGE e000(zs)
      WITH 'CoCode must be entry (8010, 8020, 8030, 8070)'.
  ENDIF.


AT SELECTION-SCREEN ON pa_vkbur.
  IF pa_bukrs EQ '8020'.
    IF pa_vkbur EQ '0' OR pa_vkbur EQ space OR
      ( pa_vkbur+0(2) NE '02' AND pa_vkbur+0(2) NE 'T2').
      MESSAGE e000(zs) WITH 'Business Area must be entry 02xx/T2xx'.
    ENDIF.
  ELSEIF pa_bukrs EQ '8030'.
    IF pa_vkbur EQ 0 OR pa_vkbur EQ space OR pa_vkbur+0(2) NE '03'.
      MESSAGE e000(zs) WITH 'Business Area must be entry 03xx'.
    ENDIF.
  ELSEIF pa_bukrs EQ '8010'.
    IF pa_vkbur EQ 0 OR pa_vkbur EQ space OR pa_vkbur+0(2) NE '01'.
      MESSAGE e000(zs) WITH 'Business Area must be entry 01xx'.
    ENDIF.
  ELSEIF pa_bukrs EQ '8070'.
    IF pa_vkbur EQ 0 OR pa_vkbur EQ space OR pa_vkbur+0(2) NE '07'.
      MESSAGE e000(zs) WITH 'Business Area must be entry 07xx'.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON so_parnr.
  IF NOT ( so_parnr IS INITIAL ).
    SELECT SINGLE * FROM knb1
           WHERE bukrs EQ pa_bukrs AND
                 pernr IN so_parnr.
    IF sy-subrc NE 0.
      MESSAGE e000(zs) WITH 'No Data Borderel Inkaso Number'.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON RADIOBUTTON GROUP grp1.
  IF reprint = 'X'.
    IF so_belnr[] IS INITIAL.
      MESSAGE e000(zs) WITH 'BI Number must entry'.
    ENDIF.
  ENDIF.

TOP-OF-PAGE.
  IF print EQ 'X'.
    IF sy-ucomm NE '&LOG'.
      PERFORM f_write_header.
      FORMAT COLOR 4.
      PERFORM f_write_column_header.
    ENDIF.
  ENDIF.

  IF reprint EQ 'X'.
    IF sy-ucomm NE '&LOG'.
      PERFORM f_init_print.
      PERFORM f_write_print_header.
    ENDIF.
  ENDIF.

  IF koreksi EQ 'X'.
    IF sy-ucomm NE '&LOG'.
      PERFORM f_write_header.
      FORMAT COLOR 4.
      PERFORM f_write_column_header.
    ENDIF.
  ENDIF.

  IF v_del EQ 'X'.
    IF sy-ucomm NE '&LOG'.
      PERFORM f_write_header.
      FORMAT COLOR 4.
      PERFORM f_write_column_header.
    ENDIF.
  ENDIF.

TOP-OF-PAGE DURING LINE-SELECTION.
  IF print EQ 'X'.
    IF sy-ucomm NE '&LOG'.
      SET PF-STATUS '400'.
      PERFORM f_init_print.
      PERFORM f_write_print_header.
    ENDIF.
  ENDIF.

  IF koreksi EQ 'X'.
    IF sy-ucomm NE '&LOG'.
      PERFORM f_init_print.
      PERFORM f_write_print_header.
    ENDIF.
  ENDIF.

************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.
  PERFORM f_init_column.

  DATA: lv_parva(40).

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'BUK'.

  IF sy-subrc EQ 0.
    pa_bukrs  = lv_parva.
  ENDIF.

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'VKB'.

  IF sy-subrc EQ 0.
    pa_vkbur  = lv_parva.
  ENDIF.

************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.

  PERFORM cek.
  IF print = 'X' OR koreksi = 'X'.
    APPEND '&PRNT' TO gt_fcode.

    SET PF-STATUS '100' EXCLUDING gt_fcode.
    va_parvw = 'ZS'.
    va_collector = pa_name.
    IF print = 'X'.
      IF val IS INITIAL.
        PERFORM f_get_data.
      ELSE.
        val = val / 100.
        PERFORM f_get_min.
      ENDIF.
      DESCRIBE TABLE i_itab1 LINES va_nou.
    ELSE.
      PERFORM lock_zfbih.
      SELECT SINGLE * FROM zfbid
      WHERE bbeln = belnr AND bflag NOT IN ('E','D','P').
      IF sy-subrc EQ 0.
        PERFORM f_get_data_add.
        DESCRIBE TABLE i_itab1 LINES va_nou.
      ENDIF.
    ENDIF.
    PERFORM route_list.
    PERFORM do_no.
    IF va_nou <= 0.
      MESSAGE i001(26) WITH 'Tidak ada data'.
      EXIT.
    ENDIF.
    CLEAR wa_itab1.
    va_nou = 0.
    tot_wrbtr = 0.
    SORT i_itab1 BY kunnr zuonr.
    LOOP AT i_itab1 INTO wa_itab1.
      IF wa_itab1-zlspr NE 'B'.  "or flag eq 'X'.

        wa_itab1-zfbdt = wa_itab1-zfbdt + wa_itab1-zbd1t.
        wa_itab1-wrbtr = wa_itab1-wrbtr * 100.
        wa_itab1-zuonr1 = wa_itab1-zuonr.
***untuk CN
        IF wa_itab1-shkzg EQ 'H'.
          wa_itab1-wrbtr = wa_itab1-wrbtr * -1.
        ENDIF.
***
        nilai = 0. nilai_sfa = 0.
*            IF VAL IS INITIAL.
        LOOP AT i_itab3 INTO wa_itab3 WHERE kunnr = wa_itab1-kunnr
AND zuonr = wa_itab1-zuonr.
          wa_itab3-wrbtr = wa_itab3-wrbtr * 100.
          nilai = nilai + wa_itab3-wrbtr.
          CLEAR wa_itab3.
          DELETE i_itab3.
*          wa_itab1-pstat = 'P'.
          wa_itab1-pstat = 'F'.
        ENDLOOP.

        IF val IS INITIAL.
          wa_itab1-wrbtr = wa_itab1-wrbtr + nilai.

          SELECT SUM( cchek ) INTO nilai FROM zfbicheck
          WHERE bukrs EQ wa_itab1-bukrs AND vkbur EQ wa_itab1-vkbur
          AND gjahr EQ wa_itab1-gjahr AND zuonr EQ wa_itab1-zuonr
          AND pcair EQ space.

          SELECT SUM( bank_amt ) INTO nilai_sfa FROM zfbic_sfa
          WHERE bukrs EQ wa_itab1-bukrs AND vkbur EQ wa_itab1-vkbur
          AND zuonr EQ wa_itab1-zuonr
          AND pcair EQ space.

*          IF sy-subrc EQ 0.
          IF nilai NE 0 OR nilai_sfa NE 0.
            nilai = nilai + nilai_sfa.
            wa_itab1-wrbtr = wa_itab1-wrbtr - nilai * 100.
          ENDIF.
        ELSE.
          IF wa_itab1-xref3 NE space.
            wa_itab1-zuonr = wa_itab1-xref3.
          ENDIF.
        ENDIF.


*        IF wa_itab1-pstat <> 'P'.
*          wa_itab1-pstat = 'F'.
*        ENDIF.
        IF wa_itab1-pstat <> 'F'.
*          wa_itab1-pstat = 'P'.
          wa_itab1-pstat = 'F'.
        ENDIF.

        MODIFY i_itab1 FROM wa_itab1.
      ENDIF.
      IF wa_itab1-zlspr EQ 'B'.
        LOOP AT i_itab3 INTO wa_itab3 WHERE zuonr = wa_itab1-zuonr.
          DELETE i_itab3.

        ENDLOOP.
      ENDIF.
      CLEAR wa_itab1.
    ENDLOOP.
*    WRITE: /(112) sy-uline.
    IF val IS INITIAL.

      LOOP AT i_itab3 INTO wa_itab1.

        wa_itab1-wrbtr = wa_itab1-wrbtr * 100.
        IF wa_itab1-shkzg = 'H'.
          wa_itab1-wrbtr = wa_itab1-wrbtr * -1.
        ENDIF.
        i_itab1-bukrs = wa_itab1-bukrs.
        MOVE wa_itab1-vkbur TO i_itab1-vkbur.
        MOVE wa_itab1-gjahr TO i_itab1-gjahr.
        MOVE wa_itab1-ebelp TO i_itab1-ebelp.
        MOVE wa_itab1-belnr TO i_itab1-belnr.
        MOVE wa_itab1-gsber TO i_itab1-gsber.
        MOVE wa_itab1-zuonr TO i_itab1-zuonr.
        MOVE wa_itab1-buzei TO i_itab1-buzei.
        MOVE wa_itab1-budat TO i_itab1-budat.
        MOVE wa_itab1-kunnr TO i_itab1-kunnr.
        MOVE wa_itab1-zfbdt TO i_itab1-zfbdt.
        MOVE wa_itab1-wrbtr TO i_itab1-wrbtr.
        MOVE wa_itab1-zuonr TO i_itab1-zuonr1.
        MOVE wa_itab1-vbund TO i_itab1-vbund.
        MOVE wa_itab1-zlspr TO i_itab1-zlspr.

        IF do_no IS INITIAL.
          APPEND  i_itab1.
        ELSE.
          IF  wa_itab1-zuonr IN do_no.
            APPEND  i_itab1.
          ENDIF.
        ENDIF.
        CLEAR wa_itab1.
      ENDLOOP.
    ELSE.
      LOOP AT i_itab1 INTO wa_itab1 WHERE zuonr EQ space.
        IF wa_itab1-xref3 NE space.
          wa_itab1-zuonr = wa_itab1-xref3.
          wa_itab1-zuonr1 = wa_itab1-zuonr.
          MODIFY i_itab1.
*       ELSE.
*         DELETE I_ITAB1.
        ENDIF.
      ENDLOOP.
    ENDIF.

    PERFORM f_get_zfbid_sfa.

    SORT i_itab1 BY kunnr zuonr.
    LOOP AT i_itab1. "WHERE wrbtr EQ 0.
      IF i_itab1-wrbtr EQ 0.
        DELETE i_itab1. CONTINUE.
      ENDIF.
      READ TABLE gt_zfbid_sfa WITH KEY bukrs = i_itab1-bukrs
                                       vkbur = i_itab1-vkbur
                                       gjahr = i_itab1-gjahr
                                       zuonr = i_itab1-zuonr
                                       bflag = space
                                       pstat = 'F'.
      IF sy-subrc = 0.
        DELETE i_itab1. CONTINUE.
      ELSE.
        READ TABLE gt_zfbid_sfa WITH KEY bukrs = i_itab1-bukrs
                                         vkbur = i_itab1-vkbur
                                         gjahr = i_itab1-gjahr
                                         zuonr = i_itab1-zuonr
                                         bflag = space
                                         pstat = space.
        IF sy-subrc = 0.
          DELETE i_itab1. CONTINUE.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF  so_duedt IS INITIAL.
      LOOP AT i_itab1 INTO wa_itab1.
        IF wa_itab1-zlspr NE 'B'.

          sw = va_nou MOD 2.
          IF sw = 0.
            FORMAT COLOR 2.
            FORMAT INTENSIFIED OFF.
          ELSE.
            FORMAT COLOR 1.
            FORMAT INTENSIFIED OFF.
          ENDIF.
          ADD wa_itab1-wrbtr TO tot_wrbtr.

          IF wa_itab1-wrbtr <> 0.
            ADD 1 TO va_nou.
            PERFORM f_write_detail.
          ENDIF.
*          IF va_nou = 52.
*            WRITE: /(118) sy-uline.
*          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSE.
      LOOP AT i_itab1 INTO wa_itab1  WHERE zfbdt IN so_duedt.

        IF wa_itab1-zlspr NE 'B'.

          sw = va_nou MOD 2.
          IF sw = 0.
            FORMAT COLOR 2.
            FORMAT INTENSIFIED OFF.
          ELSE.
            FORMAT COLOR 1.
            FORMAT INTENSIFIED OFF.
          ENDIF.
          ADD wa_itab1-wrbtr TO tot_wrbtr.

          IF wa_itab1-wrbtr <> 0.
            ADD 1 TO va_nou.
            PERFORM f_write_detail.
          ENDIF.
*          IF va_nou = 52.
*            WRITE: /(118) sy-uline.
*          ENDIF.
        ENDIF.
      ENDLOOP.

    ENDIF.
    WRITE: /(118) sy-uline.
    PERFORM f_write_total.
  ENDIF.
  IF reprint = 'X'.
    PERFORM get_r_print.
    NEW-PAGE LINE-SIZE 204.
    PERFORM f_init_print.
*    PERFORM f_write_print_header.
    va_nou = 0.tot_wrbtr = 0.va_nou1 = 0.
    CLEAR: va_sw.
    SORT i_itab1 BY kunnr zuonr.
    LOOP AT i_itab1 INTO wa_itab1.
      ADD 1 TO va_nou.ADD 1 TO va_nou1.
      tot_wrbtr = wa_itab1-wrbtr + tot_wrbtr.
      ADD 1 TO va_sw.
*      va_count = va_nou MOD 34.
*      IF va_count EQ 0.
*        WRITE: / sy-uline.
*        NEW-PAGE.
*      ENDIF.
      IF va_sw EQ 31.
        CLEAR: va_sw.
        WRITE: / sy-uline.
        NEW-PAGE.
      ENDIF.

      PERFORM f_print_detail.
    ENDLOOP.
    WRITE: /(204) sy-uline.
    PERFORM f_print_total.
  ENDIF.

  IF v_del = 'X'.
    SET PF-STATUS '100'.
    PERFORM lock_zfbih.
    PERFORM get_delete.
    DESCRIBE TABLE i_itab1 LINES va_nou.
    IF va_nou <= 0.
      MESSAGE i001(26) WITH 'Tidak ada data'.
      EXIT.
    ENDIF.
    NEW-PAGE LINE-SIZE 120.
*    PERFORM f_write_header.
    FORMAT COLOR 4.
*    PERFORM f_write_column_header.
    sw = 0.va_nou = 0.
    SORT i_itab1 BY erdt2.
    LOOP AT i_itab1 INTO wa_itab1.
      wa_itab1-budat = wa_itab1-fkdat.
      wa_itab1-wrbtr = wa_itab1-wrbtr * 100.
      sw = va_nou MOD 2.
      IF sw = 0.
        FORMAT COLOR 2.
        FORMAT INTENSIFIED OFF.
      ELSE.
        FORMAT COLOR 1.
        FORMAT INTENSIFIED OFF.
      ENDIF.
      ADD wa_itab1-wrbtr TO tot_wrbtr.
      IF wa_itab1-wrbtr <> 0.
        ADD 1 TO va_nou.
        PERFORM f_write_detail.
      ENDIF.
      IF va_nou = 53.
        WRITE: / sy-uline.
      ENDIF.

    ENDLOOP.
    WRITE: / sy-uline.
    PERFORM f_write_total.
  ENDIF.

END-OF-SELECTION.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.

    IF screen-group1 = 'AAC'.
      screen-active = 0.
    ENDIF.
    IF screen-group1 = 'AAD'.
      screen-active = 0.
    ENDIF.

    IF koreksi = 'X' OR v_del = 'X'.
      .
      IF screen-group1 = 'AAC'.
        screen-active = 1.
      ENDIF.
*           IF SCREEN-GROUP1 = 'AAD'.
*             SCREEN-ACTIVE = 1.
*           ENDIF.
      IF screen-group1 = 'AAB'.
        screen-active = 0.
      ENDIF.

    ENDIF.
    MODIFY SCREEN.

  ENDLOOP.

************************************************************************
* AT USER-COMMAND.
************************************************************************
AT USER-COMMAND.
  CASE sy-ucomm.
    WHEN '&LOG'.
      CALL SCREEN 501 STARTING AT 10 10 ENDING AT 130 22.

    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'SELECT'.
      DO.
        READ LINE sy-index.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
        MODIFY CURRENT LINE FIELD VALUE va_mark FROM 'X'.
      ENDDO.
    WHEN 'DESELECT'.
      DO.
        READ LINE sy-index.
        IF sy-subrc NE 0. EXIT. ENDIF.
        MODIFY CURRENT LINE FIELD VALUE va_mark FROM space.
      ENDDO.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCL'.
      LEAVE PROGRAM.
    WHEN 'PRNT'.
      CLEAR : i_itab1,i_itab2,i_itab2,i_itab3,i_itab6,i_itab7,
              i_itab4.
      REFRESH : i_itab1,i_itab2,i_itab2,i_itab3,i_itab6,i_itab7,
                i_itab4.
      PERFORM print.
  ENDCASE.


************************************************************************
* AT LINE-SELECTION.
************************************************************************
AT LINE-SELECTION.
  DATA: va_belnr(11), va_belnr1(18).
  SET PF-STATUS '200'.

  IF sy-lilli > 6.
    sw = 0.
    IF koreksi EQ 'X'.
      PERFORM get_vbund.
    ENDIF.
    CLEAR: wa_itab2, i_itab2.
    LOOP AT %_list INTO va_list.
      IF va_list-line+114(1) = 'X'.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = va_list-line+46(11)
          IMPORTING
            output = va_belnr.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = va_list-line+46(18)
          IMPORTING
            output = va_belnr1.

        CLEAR wa_itab1.
        READ TABLE i_itab1 INTO wa_itab1
        WITH KEY  zuonr1 = va_belnr. "BINARY SEARCH.
        IF va_belnr+10(1) = 'R' OR va_belnr+9(1) = 'R'.
          sy-subrc = 4.
        ENDIF.
        IF sy-subrc EQ 0.
          IF sw = 0.
            va_vbund = wa_itab1-vbund.
            sw = 1.
          ELSE.
            IF va_vbund NE wa_itab1-vbund AND
               va_vbund NE space.
              MESSAGE e000(zs) WITH
              'Ada Trading Partner tidak sama'.
            ENDIF.
          ENDIF.
          APPEND wa_itab1 TO i_itab2.
        ELSE.
          CLEAR wa_itab1.
          READ TABLE i_itab1 INTO wa_itab1
          WITH KEY  zuonr = va_belnr1.
          IF sy-subrc EQ 0.
            IF sw = 0.
              va_vbund = wa_itab1-vbund.
              sw = 1.
            ELSE.
              IF va_vbund NE wa_itab1-vbund AND
                 va_vbund NE space.
                MESSAGE e000(zs) WITH
                'Ada Trading Partner tidak sama'.
              ENDIF.
            ENDIF.
            APPEND wa_itab1 TO i_itab2.
          ENDIF.
        ENDIF.
        sw = 1.
      ENDIF.
    ENDLOOP.
  ENDIF.

  DESCRIBE TABLE i_itab2 LINES va_nou.
  IF va_nou > 0.
* Validasi untuk FORM 3
    PERFORM f_get_zfhkr1at.

    IF t_zfh_kr1at[] IS INITIAL.
      IF print = 'X' OR koreksi = 'X'.
        va_ebelp = 0.
        tot_wrbtr = 0.
        va_nou = 0.

        LOOP AT i_itab2 INTO wa_itab1.
          wa_itab1-wrbtr = wa_itab1-wrbtr.                  "* 100.

          ADD wa_itab1-wrbtr TO tot_wrbtr.
          ADD 1 TO va_nou.
          PERFORM cek_lock.
          CLEAR i_bdc.
          IF flock EQ 'X'.
            SELECT SINGLE zlspr INTO flag FROM bseg
                 WHERE belnr EQ wa_itab1-belnr
                   AND bukrs EQ pa_bukrs
                   AND gjahr EQ wa_itab1-gjahr
                   AND buzei EQ wa_itab1-buzei.
            IF flag EQ 'B'.
              CONTINUE.
            ENDIF.
            IF wa_itab1-kunnr(2) = 'SL'.
              PERFORM bloksl.
            ELSE.
              PERFORM blok.
            ENDIF.

            IF sy-subrc <> 0.
              READ TABLE messtab INDEX 1.
              CALL FUNCTION 'FORMAT_MESSAGE'
                EXPORTING
                  id   = messtab-msgid
                  lang = messtab-msgspra
                  no   = messtab-msgnr
                  v1   = messtab-msgv1
                  v2   = messtab-msgv2
                  v3   = messtab-msgv3
                  v4   = messtab-msgv4
                IMPORTING
                  msg  = msg.
              wa_log_error-bukrs = pa_bukrs.
              wa_log_error-gjahr = sy-datum+0(4).
              wa_log_error-belnr = wa_itab1-belnr.
              APPEND wa_log_error TO i_log_error.
            ELSE.
              COMMIT WORK AND WAIT.
              ADD 10 TO va_ebelp.
              MOVE va_bbeln       TO wa_itab1-bbeln.
              MOVE va_ebelp       TO wa_itab1-ebelp.
              APPEND wa_itab1 TO i_itab5.
            ENDIF.
          ELSE.
            CONTINUE.
          ENDIF.
          CLEAR wa_itab1.
        ENDLOOP.

        PERFORM write_tabel_header.
        va_nou = 0.tot_wrbtr = 0.
        CLEAR: va_sw.
        SORT i_itab5 BY kunnr zuonr.
        LOOP AT i_itab5 INTO wa_itab1.
          ADD 1 TO va_nou.
          ADD 1 TO va_nou1.
          MOVE wa_itab1-bukrs TO zfbid-bukrs.
          MOVE wa_itab1-vkbur TO zfbid-vkbur.

          MOVE wa_itab1-gjahr TO zfbid-gjahr.
          MOVE va_bbeln       TO zfbid-bbeln.
          MOVE wa_itab1-ebelp TO zfbid-ebelp.
          MOVE wa_itab1-belnr TO zfbid-vbeln.
          MOVE wa_itab1-gsber TO zfbid-gsber.
          MOVE wa_itab1-zuonr TO zfbid-zuonr.
          MOVE wa_itab1-buzei TO zfbid-buzei.
          MOVE wa_itab1-budat TO zfbid-fkdat.
          MOVE wa_itab1-kunnr TO zfbid-kunnr.
          MOVE wa_itab1-zfbdt TO zfbid-zfbdt.
          MOVE wa_itab1-pstat TO zfbid-pstat.
          MOVE sy-datum TO zfbid-erdt2.
          tot_wrbtr = tot_wrbtr + wa_itab1-wrbtr.
          zfbid-wrbtr = wa_itab1-wrbtr / 100.

* Modify counter new-page
*          va_count = va_nou MOD 34.
*          IF va_count EQ 0.
*            WRITE: / sy-uline.
*            NEW-PAGE.
*          ENDIF.
          ADD 1 TO va_sw.
          IF va_sw EQ 31.
            CLEAR: va_sw.
            WRITE: / sy-uline.
            NEW-PAGE.
          ENDIF.

          PERFORM f_print_detail.
          IF koreksi EQ 'X'.
            PERFORM get_zfbid.
            READ TABLE t_zfbid
            WITH KEY  zuonr = wa_itab1-zuonr.
            IF sy-subrc EQ 0.
              UPDATE zfbid
                SET bflag = space wrbtr = zfbid-wrbtr
                WHERE bukrs = pa_bukrs AND vkbur = pa_vkbur
                      AND gjahr = wa_itab1-gjahr AND bbeln =
                      belnr AND vbeln EQ wa_itab1-belnr.
            ELSE.
              MODIFY zfbid.
            ENDIF.
          ELSE.
            MODIFY zfbid.
          ENDIF.
        ENDLOOP.
        WRITE: /(204) sy-uline.
        PERFORM f_print_total.
      ENDIF.
    ELSE.
      t_error[]     = t_zfh_kr1at[].
      MESSAGE i000(zab) WITH 'Ada error waktu proses BI lihat di Error log'.
    ENDIF.
  ENDIF.

  IF v_del = 'X'.
    LOOP AT i_itab2 INTO wa_itab1.
      PERFORM open_blok.
      UPDATE zfbid
         SET bflag = 'D'
         WHERE bukrs = pa_bukrs AND vkbur = pa_vkbur
* Tahun
*                        AND GJAHR = WA_ITAB1-GJAHR
               AND bbeln = wa_itab1-bbeln
               AND vbeln EQ wa_itab1-vbeln.



    ENDLOOP.
    LEAVE TO SCREEN 0.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA: l_kunnr LIKE knvp-kunnr.

  IF pa_vkbur(2) = 'T2'.
    pa_vtweg = '20'.
  ENDIF.

  SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat a~kunnr
         a~waers a~xblnr a~bldat a~monat a~shkzg a~wrbtr a~zfbdt
         a~zbd1t a~buzei a~gsber a~zlspr b~vkbur b~spart a~zuonr
         d~pernr a~xref1 a~xref2 a~xref3 a~vbund
      INTO CORRESPONDING FIELDS OF TABLE i_itab7
      FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr
           JOIN knb1 AS d ON d~kunnr EQ a~kunnr AND
                             d~bukrs EQ a~bukrs
      WHERE a~bukrs EQ pa_bukrs AND
            a~belnr IN so_belnr AND
            a~zlspr IN (space,'Z','B')    AND
* PENAMBAHAN BLART 'DA' REQUEST BY 'LLL' ( DEVK909413 )
* BEGIN DELETE
*               A~BLART IN ('RV','DR','DG', 'ZA')   AND
* END DELETE
* BEGIN INSERT
            a~blart IN ('DA', 'RV','DR','DG', 'ZA')   AND
* END INSERT
            a~umskz EQ space AND
            a~kunnr IN so_kunnr AND
            b~vkbur EQ pa_vkbur AND
            b~vkorg EQ pa_bukrs AND
            b~vtweg EQ pa_vtweg AND
            d~pernr IN so_parnr
            ORDER BY a~zuonr.

  SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat a~kunnr
              a~waers a~xblnr a~bldat a~monat a~shkzg a~wrbtr a~zfbdt
              a~zbd1t a~buzei a~gsber a~zlspr b~vkbur b~spart a~zuonr
              d~pernr a~xref1 a~xref2 a~vbund
           INTO CORRESPONDING FIELDS OF TABLE i_itab6
           FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr
                JOIN knb1 AS d ON d~kunnr EQ a~kunnr AND
                                  d~bukrs EQ a~bukrs
           WHERE a~bukrs EQ pa_bukrs AND
                 a~belnr IN so_belnr AND
                 a~zlspr IN (space,'Z')    AND
                 a~blart EQ 'DZ'     AND
                 a~umskz EQ space AND
                 a~kunnr IN so_kunnr AND
                 b~vkbur EQ pa_vkbur AND
                 b~vkorg EQ pa_bukrs AND
                 b~vtweg EQ pa_vtweg AND
                 d~pernr IN so_parnr
                 ORDER BY a~zuonr.


  SORT i_itab6 BY kunnr zuonr.
  LOOP AT i_itab6.
    MOVE-CORRESPONDING i_itab6 TO wa_itab1.
    MOVE-CORRESPONDING wa_itab1 TO i_itab3.
    IF i_itab6-shkzg = 'H'.
      i_itab6-wrbtr = i_itab6-wrbtr * -1.
    ENDIF.
    MODIFY i_itab6.
    IF wa_itab1-kunnr EQ i_itab6-kunnr.
      AT END OF zuonr.
        SUM.
        i_itab3-shkzg = 'S'.
        i_itab3-wrbtr = i_itab6-wrbtr.
        APPEND i_itab3.
      ENDAT.
    ENDIF.
    CLEAR wa_itab1.
  ENDLOOP.

  SORT i_itab7 BY kunnr zuonr.
  LOOP AT i_itab7.
    MOVE-CORRESPONDING i_itab7 TO wa_itab1.
    MOVE-CORRESPONDING wa_itab1 TO i_itab1.
    IF i_itab7-shkzg = 'H'.
      i_itab7-wrbtr = i_itab7-wrbtr * -1.
    ENDIF.
    v_zbd1t = i_itab7-zbd1t.
    i_itab7-zbd1t = 0.
    MODIFY i_itab7.
    IF wa_itab1-kunnr EQ i_itab7-kunnr.
      AT END OF zuonr.
        SUM.
        i_itab1-shkzg = 'S'.
        i_itab1-wrbtr = i_itab7-wrbtr.
        i_itab1-zbd1t = v_zbd1t.
        APPEND i_itab1.
      ENDAT.
    ENDIF.
    CLEAR wa_itab1.
  ENDLOOP.
ENDFORM.                    " f_get_data

*---------------------------------------------------------------------*
*       FORM F_WRITE_TOTAL                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_write_total.
  DATA: l_name1 LIKE kna1-name1.
  c1 = 1.
  FORMAT COLOR OFF INTENSIFIED OFF.
  WRITE: / ' '.
  c1 = c1 + 1.
  c1 = c1 + w1.
  c1 = c1 + 1.

  c1 = c1 + w2.
  c1 = c1 + 1.

  c1 = c1 + w3.
  c1 = c1 + 1.
  c1 = c1 + w4.
  c1 = c1 + 1.

  c1 = c1 + w5.
  WRITE AT c1(1) sy-vline NO-GAP.
  c1 = c1 + 1.
  FORMAT COLOR 3.
  WRITE AT c1(w6)  'Total ' NO-GAP.
  c1 = c1 + w6.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w7)  tot_wrbtr NO-GAP DECIMALS 0.
  c1 = c1 + w7.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w8.
  FORMAT COLOR OFF INTENSIFIED OFF.
  c1 = 1.
  WRITE: / ' '.
  c1 = c1 + 1.
  c1 = c1 + w1.
  c1 = c1 + 1.

  c1 = c1 + w2.
  c1 = c1 + 1.

  c1 = c1 + w3.
  c1 = c1 + 1.
  c1 = c1 + w4.
  c1 = c1 + 1.

  c1 = c1 + w5.
  WRITE AT c1(1) sy-vline NO-GAP.
  c1 = c1 + 1.
  c2 = w6 + w7 + 1.
  WRITE AT c1(c2)  sy-uline  NO-GAP.
  c1 = c1 + c2.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w8.
  c1 = 1.
ENDFORM.                    " f_write_detail

*&---------------------------------------------------------------------*
*&      Form  f_write_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_detail.
  DATA: l_name1 LIKE kna1-name1.
  c1 = 1.
  WRITE: / sy-vline.
  c1 = c1 + 1.
  WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w3) wa_itab1-kunnr NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  CLEAR l_name1.
  SELECT SINGLE name1 INTO l_name1 FROM kna1
     WHERE kunnr EQ wa_itab1-kunnr.

  WRITE AT c1(w4) l_name1 NO-GAP. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w2) wa_itab1-zuonr NO-GAP.   c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

*  WRITE AT c1(w5) wa_itab1-budat NO-GAP CENTERED. c1 = c1 + w5.
  WRITE AT c1(w5) wa_itab1-bldat NO-GAP CENTERED. c1 = c1 + w5.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w6) wa_itab1-zfbdt NO-GAP. c1 = c1 + w6.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w7)  wa_itab1-wrbtr NO-GAP DECIMALS 0.
  c1 = c1 + w7.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 3.

  WRITE AT c1   va_mark AS CHECKBOX NO-GAP CENTERED.
  c1 = c1 + w8 - 2.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 1.
ENDFORM.                    " f_write_detail
*&---------------------------------------------------------------------*
*&      Form  f_write_column_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_column_header.
  c1 = 1.
  WRITE: /(118) sy-uline.
  WRITE: / sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1)  'No.' NO-GAP  CENTERED.  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w3) 'Customer No.' NO-GAP  CENTERED.   c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4)  'Customer Name' NO-GAP  CENTERED. c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w2) 'Delivery No.' NO-GAP  CENTERED.   c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

*  WRITE AT c1(w5)  'Billing Date.' NO-GAP  CENTERED. c1 = c1 + w5.
  WRITE AT c1(w5)  'DN Date.' NO-GAP  CENTERED. c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w6)  'Due. Date' NO-GAP CENTERED. c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w7)  'Amount' NO-GAP  CENTERED. c1 = c1 + w7.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w8)  'CBox'  CENTERED NO-GAP. c1 = c1 + w8.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE: /(118) sy-uline.
  c1 = 1.
ENDFORM.                    " f_write_column_header

*&---------------------------------------------------------------------*
*&      Form  f_init_column
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_column.

  w1   =   5.      w11 = 15.      w21 = 12.      w31 = 10.
  w2   =  18.      w12 = 13.      w22 = 10.      w32 = 12.
  w3   =  12.      w13 = 12.      w23 = 10.      w33 = 12.
  w4   =  25.      w14 = 10.      w24 = 12.      w34 = 10.
  w5   =  12.      w15 = 10.      w25 = 12.      w35 = 10.
  w6   =  12.      w16 = 12.      w26 = 10.
  w7   =  20.      w17 = 12.      w27 = 10.      w19a = 12.
  w8   =  5.      w18 = 10.      w28 = 12.
  w9   =  15.      w19 = 10.      w29 = 12.
  w10  =  15.      w20 = 12.      w30 = 10.
  c1 = 0.

  DATA: lv_parva(40).

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'BUK'.

  IF sy-subrc EQ 0.
    pa_bukrs  = lv_parva.
  ENDIF.

ENDFORM.                    " f_init_column

*---------------------------------------------------------------------*
*       FORM F_PRINT_DETAIL                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_detail.
  DATA: l_name1 LIKE kna1-name1,
        l_kunde LIKE vbpa-kunnr,
        l_vrtnr LIKE vbpa-parnr,
        l_text(30),
        l_kunde1  TYPE i.

  DATA : lwa_itab TYPE t_itab1.

  c1 = 1.
  WRITE: /(118)  sy-vline.
  c1 = c1 + 1.
  WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w2) wa_itab1-kunnr NO-GAP. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  CLEAR l_name1.
  SELECT SINGLE name1 INTO l_name1 FROM kna1
     WHERE kunnr EQ wa_itab1-kunnr.

  CLEAR l_text.
  SELECT SINGLE kunnr INTO l_kunde FROM vbpa
         WHERE vbeln EQ wa_itab1-belnr AND
               parvw EQ 'ZC'.
  SELECT SINGLE pernr INTO l_vrtnr FROM vbpa
         WHERE vbeln EQ wa_itab1-belnr AND
               parvw EQ 'ZP'.
  IF reprint = 'X'.
    v_zuonr = wa_itab1-zuonr.
    CONCATENATE v_zuonr  l_vrtnr+6(4)
         INTO l_text SEPARATED BY space.
  ELSE.
    IF wa_itab1-xref1 NE space.
      MOVE wa_itab1-xref1 TO zfbid-parvw.
    ENDIF.
    IF wa_itab1-xref2 NE space.
      l_vrtnr = wa_itab1-xref2.
    ENDIF.
    v_zuonr = wa_itab1-zuonr.
    CONCATENATE v_zuonr  l_vrtnr+6(4)
         INTO l_text SEPARATED BY space.
  ENDIF.

  IF wa_itab1-xref1 EQ space.
    rt = l_kunde.
    IF l_kunde IS INITIAL.
      CLEAR lwa_itab.
      READ TABLE i_itab6 INTO lwa_itab WITH KEY kunnr = wa_itab1-kunnr
                                                belnr = wa_itab1-belnr.
      IF sy-subrc EQ 0.
        rt = lwa_itab-xref1.
      ENDIF.
    ENDIF.
  ENDIF.

  IF rt NE space .
* command for SUT
*    IF rt > 9999.
*      rt = 0.
*    ENDIF.
    IF wa_itab1-xref1 EQ space.
      MOVE rt TO zfbid-parvw.
    ENDIF.
    MOVE l_vrtnr TO zfbid-slcod.
  ELSE.
    SELECT SINGLE parvw slcod INTO (l_kunde, l_vrtnr) FROM zfbid
    WHERE bukrs EQ pa_bukrs AND vkbur EQ pa_vkbur
          AND zuonr EQ wa_itab1-zuonr AND parvw NE 0.

* kondisi untuk parvw tdk numerik
    CONDENSE l_kunde NO-GAPS.
    l_kunde1  = STRLEN( l_kunde ).

    IF pa_bukrs EQ '8020'.
      IF l_kunde CO '0123456789'.
        rt = l_kunde.
      ELSE.
        rt = 0.
      ENDIF.
    ELSE.
      rt = l_kunde.
    ENDIF.

    IF sy-fdpos = l_kunde1.
      rt = l_kunde.
    ENDIF.
*------------------------------------
*               RT = L_KUNDE.
    MOVE rt TO zfbid-parvw.
    MOVE l_vrtnr TO zfbid-slcod.
    CONCATENATE v_zuonr  l_vrtnr+6(4)
    INTO l_text SEPARATED BY space.
  ENDIF.

  WRITE AT c1(w3) l_name1 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.


  IF reprint = 'X'.
*    WRITE AT c1(w4) wa_itab1-parvw NO-GAP. c1 = c1 + w4.
    WRITE AT c1(w4) rt NO-GAP. c1 = c1 + w4.
  ELSE.
    WRITE AT c1(w4) rt NO-GAP. c1 = c1 + w4.
  ENDIF.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  IF reprint = 'X'.

    WRITE AT c1(w5) wa_itab1-fkdat NO-GAP. c1 = c1 + w5.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  ELSE.
    WRITE AT c1(w5) wa_itab1-budat NO-GAP. c1 = c1 + w5.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  ENDIF.
  WRITE AT c1(w6) wa_itab1-zfbdt NO-GAP. c1 = c1 + w6.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.


  WRITE AT c1(w7)  l_text NO-GAP DECIMALS 0.
  c1 = c1 + w7.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w8)   wa_itab1-wrbtr NO-GAP DECIMALS 0.
  IF reprint = 'X'.
    WRITE AT c1(w8)   wa_itab1-wrbtr CURRENCY 'IDR' NO-GAP
    DECIMALS 0.
  ENDIF.
  c1 = c1 + w8.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w9.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w11.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w12.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w13.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w14.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

*  c1 = c1 + w16.
*  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = 1.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  c1 = c1 + w1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w4.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w5.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w6.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w7.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w8.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w9.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w11.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w12.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w13.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w14.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

*  c1 = c1 + w16.
*  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = 1.

ENDFORM.                    " f_write_detail


*---------------------------------------------------------------------*
*       FORM F_PRINT_TOTAL                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_total.
  c1 = 1.
  c1 = c1 + 1.
  WRITE AT /1(6) 'Opr : '.
  WRITE AT 8(10)  sy-uname.
  IF reprint = 'X'.
    WRITE AT 20 'EX'.
  ENDIF.
  c1 = c1 + w1.
  c1 = c1 + 1.
  c1 = c1 + w2.
  c1 = c1 + 1.
  c1 = c1 + w3.
  c1 = c1 + 1.
  c1 = c1 + w4.
  c1 = c1 + 1.
  c1 = c1 + w5.
  c1 = c1 + 1.
  c1 = c1 + w6.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w7) 'Jumlah Total ' CENTERED NO-GAP DECIMALS 0.
  c1 = c1 + w7.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w8)   tot_wrbtr NO-GAP DECIMALS 0.
  IF reprint = 'X'.
    WRITE AT c1(w8)   tot_wrbtr CURRENCY 'IDR' NO-GAP DECIMALS 0.
  ENDIF.
  c1 = c1 + w8.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w9.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w11.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w12.
  c1 = c1 + 1.
  c1 = c1 + w13.
  c1 = c1 + 1.
  c1 = c1 + w14.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
*  c1 = c1 + w16.
*  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = 1.
  WRITE: / '  ' .
  c1 = c1 + 1.
  c1 = c1 + w1.
  c1 = c1 + 1.
  c1 = c1 + w2.
  c1 = c1 + 1.
  c1 = c1 + w3.
  c1 = c1 + 1.
  c1 = c1 + w4.
  c1 = c1 + 1.
  c1 = c1 + w5.
  c1 = c1 + 1.
  c1 = c1 + w6.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c2 = w7 + w8 + w9 + w10 + w10 + w11 + 5.
  WRITE AT c1(c2) sy-uline NO-GAP.
  c1 = c1 + c2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w12.
  c1 = c1 + 1.
  c1 = c1 + w13.
  c1 = c1 + 1.
  c1 = c1 + w14.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
*  c2 = w15 + w16 + 1.
  c2 = w15.
  WRITE AT c1(c2) sy-uline NO-GAP.
  c1 = c1 + c2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c2 = w15.
  WRITE AT c1(c2) sy-uline NO-GAP.
  c1 = c1 + c2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = 1.
  WRITE: / 'Diserahkan Tgl  :  .../.../....' .
  c1 = c1 + w1 + w2 + w3 + w4 +  6.
  c2 = w7 + w8 + w9 + w10 + w11.
  WRITE AT c1 'Terima Kembali Tgl : .../.../....'.
  c1 = c1 + w7 + w8 + 12 + w9.
  c2 = w12 + w13 + w14 + w15 + w16.
  WRITE AT c1(c2) 'Jumlah Rp : .....................'.
  c1 = 1.
  WRITE: / '(......) Lbr. Faktur / Kwitansi' .
  c1 = c1 + w1 + w2 + w3 + w4  +  6.
  c2 = w7 + w8 + w9 + w10 + w11.
  WRITE AT c1 '(......) Lbr. Faktur / Kwitansi' .
  c1 = c1 + w7 + w8 + w9 + w10 + w11 + 4.
  c2 = w12 + w13 + w14 + w15 + w16.
  c1 = 1.
  WRITE: / 'Tanda terima penagih' .
  c1 = c1 + w1 + w2 + w3 + w4  +  6.
  c2 = w7 + w8 + w9 + w10 + w11.
  WRITE AT c1 'Seksi Inkaso' .
  c1 = c1 + w7 + w8 +  12 + w9.
  c2 = w10 + w12 + w13 + w14 + w15 + w16.
  WRITE AT c1(c2) 'Mengetahui Kep. Keuangan.'.
  c1 = c1 + c2 + 20 - 13.
  c2 = w12 + w13 + w14 + w15 + w16.
  WRITE AT c1(c2) 'Kasir'.

  SKIP 5.
  c1 = 1.
  WRITE: / '(..............................)' .
  c1 = c1 + w1 + w2 + w3 + w4  + 6.
  c2 = w7 + w8 + w9 + w10 + w11.
  WRITE AT c1 '(..............................)' .
  c1 = c1 + w7 + w8 +  12 + w9.
  c2 = w10 + w12 + w13 + w14 + w15 + w16.
  WRITE AT c1(c2) '(..............................)'.
  c1 = c1 + c2 + 8 - 13.
  c2 = w12 + w13 + w14 + w15 + w16.
  WRITE AT c1(c2) '(..............................)'.
  SKIP 3.
ENDFORM.                    " f_write_detail


*---------------------------------------------------------------------*
*       FORM F_WRITE_PRINT_HEADER                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_write_print_header.
  DATA: c2 TYPE i.
  PERFORM f_print_header.

  c1 = 1.
  WRITE: /(204) sy-uline.
  WRITE: / sy-vline. c1 = c1 + 1.
  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w7.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w8.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c2 = w9 + w10 + w10 + w11 + w12 + w13 + w14 + 6.
  WRITE AT c1(c2)  'P E M B A Y A R A N'  CENTERED NO-GAP.
  c1 = c1 + c2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
*  c1 = c1 + w16.
*  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 1.
  WRITE: / sy-vline. c1 = c1 + 1.
  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w7.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w8.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c2 = w9 + w10 + w10 + w11 + w12 + w13 + w14 + 6.
  WRITE AT c1(c2)  sy-uline  CENTERED NO-GAP.
  c1 = c2 + c1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
*  c1 = c1 + w16.
*  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 1.

  WRITE: / sy-vline. c1 = c1 + 1.
  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w7.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w8.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w9.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c2 = w11 + w12 + w13 + w14.
  WRITE AT c1(c2)  'Cek / Giro'  CENTERED NO-GAP.
  c1 = c1 + w11 + w12 + 1 + w13 + 1 + w14 + 1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
*  c1 = c1 + w16.
*  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 1.
  WRITE: / sy-vline. c1 = c1 + 1.
  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w5)  sy-uline(w5) NO-GAP  CENTERED.
  c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w6)  sy-uline(w6) NO-GAP CENTERED.
  c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w7)  sy-uline(w7) NO-GAP  CENTERED.
  c1 = c1 + w7.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w8)  sy-uline(w8)  CENTERED NO-GAP.
  c1 = c1 + w8.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w9.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w11)  sy-uline(w11)  CENTERED NO-GAP.
  c1 = c1 + w11.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w12)  sy-uline(w12)  CENTERED NO-GAP.
  c1 = c1 + w12.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w13)  sy-uline(w13)  CENTERED NO-GAP.
  c1 = c1 + w13.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w14)  sy-uline(w14)  CENTERED NO-GAP.
  c1 = c1 + w14.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

*  c1 = c1 + w16.
*  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = 1.
  c1 = 1.
  WRITE: / sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1)  'No' NO-GAP  CENTERED.  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w2) 'Kode' NO-GAP  CENTERED.   c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4)  'Rute' NO-GAP  CENTERED. c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w7.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w8.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w9.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w11.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w12.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w13.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w14.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w15)  'C/N'  CENTERED NO-GAP.
  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w15)  'C/N'  CENTERED NO-GAP.
  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

*  WRITE AT c1(w16)  'Rupiah'  CENTERED NO-GAP.
*  c1 = c1 + w16.
*  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = 1.

  WRITE: / sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1)  'Urut' NO-GAP  CENTERED.  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w2) 'Outlet' NO-GAP  CENTERED.   c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w3) 'D E B I T U R' NO-GAP  CENTERED.   c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4)  'List' NO-GAP  CENTERED. c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w5)  'Tgl.Dok' NO-GAP  CENTERED. c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w6)  'Due. Date' NO-GAP CENTERED. c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w7)  'Bill No. Slm Co.' NO-GAP  CENTERED.
  c1 = c1 + w7.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w8)  'Rupiah'  CENTERED NO-GAP. c1 = c1 + w8.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w9)  'Jumlah'  CENTERED NO-GAP. c1 = c1 + w9.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w10)  'Tunai'  CENTERED NO-GAP. c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w10)  'Transfer'  CENTERED NO-GAP. c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w11)  'Rupiah'  CENTERED NO-GAP. c1 = c1 + w11.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w12)  'Bank'  CENTERED NO-GAP. c1 = c1 + w12.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w13)  'Nomor'  CENTERED NO-GAP. c1 = c1 + w13.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w14)  'J.Tempo'  CENTERED NO-GAP. c1 = c1 + w14.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w15)  'Tunai'  CENTERED NO-GAP. c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w15)  'Transfer'  CENTERED NO-GAP. c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

*  WRITE AT c1(w16)  'S/F'  CENTERED NO-GAP. c1 = c1 + w16.
*  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE: /(204) sy-uline.
  c1 = 1.
ENDFORM.                    " f_write_column_header


*---------------------------------------------------------------------*
*       FORM F_INIT_PRINT                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_print.
  w1   =   4.      w11 = 10.      w21 = 12.      w31 = 10.
  w2   =  10.      w12 =  9.      w22 = 10.      w32 = 12.
  w3   =  30.      w13 =  9.      w23 = 10.      w33 = 12.
  w4   =   4.      w14 =  9.      w24 = 12.      w34 = 10.
  w5   =  10.      w15 = 10.      w25 = 12.      w35 = 10.
  w6   =  10.      w16 = 10.      w26 = 10.
  w7   =  15.      w17 = 10.      w27 = 10.      w19a = 12.
  w8   =  16.      w18 = 10.      w28 = 12.
  w9   =  10.      w19 = 10.      w29 = 12.
  w10  =  10.      w20 = 12.      w30 = 10.
  c1 = 0.
ENDFORM.                    " f_init_column

*---------------------------------------------------------------------*
*       FORM F_PRINT_HEADER                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_header.
  DATA: l_vtext LIKE tvstt-vtext,
        v_date LIKE zfbih-bidat,
        street LIKE adrc-street,
        city1 LIKE adrc-city1.

  SELECT SINGLE adrnr FROM tvst INTO l_vtext
  WHERE vstel = pa_vkbur.
  IF sy-subrc EQ 0.
    CLEAR: street,  city1.
    SELECT SINGLE street city1 FROM adrc
      INTO (street, city1)
      WHERE addrnumber = l_vtext.
  ENDIF.

  WRITE sy-pagno TO v_current_page.
  SHIFT v_current_page LEFT DELETING LEADING space.
  v_title1 = 'B O R D E R E L   I N K A S O'.

  IF print = 'X' OR koreksi = 'X'.
    v_between_header_len =
      204 - v_left_header_len - v_right_header_len - 10.
    v_right = 204 - v_right_header_len - 15.
  ELSE.
    v_between_header_len =
      sy-linsz - v_left_header_len - v_right_header_len - 10.
    v_right = sy-linsz - v_right_header_len - 15.
  ENDIF.

  FORMAT COLOR OFF INTENSIFIED ON.
  IF pa_bukrs EQ '8020'.
    WRITE: / 'PT. TEMPO' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8030'.
    WRITE: / 'PT. EURINDO COMBINED' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8070'.
    WRITE: / 'PT. SUT' INTENSIFIED OFF.
  ENDIF.
  WRITE AT: 20(v_between_header_len) v_title1 CENTERED.
  v_date = sy-datum.
  IF reprint = 'X'.
    va_bbeln = so_belnr-low.
    SELECT SINGLE * FROM zfbih
* TAMBAHAN SELECTION UNTUK PENGAMBILAN TANGGAL BI
    WHERE bukrs EQ pa_bukrs AND
          vkbur EQ pa_vkbur AND
          bbeln EQ va_bbeln.
    v_date = zfbih-bidat.
    va_collector = pa_name.
  ENDIF.

  IF koreksi = 'X' OR v_del = 'X'.
    va_bbeln = belnr.
    SELECT SINGLE * FROM zfbih
* TAMBAHAN SELECTION UNTUK PENGAMBILAN TANGGAL BI
    WHERE bukrs EQ pa_bukrs AND
          vkbur EQ pa_vkbur AND
          bbeln EQ va_bbeln.
    v_date = zfbih-bidat.
    va_collector = pa_name.
  ENDIF.

  POSITION v_right.
  WRITE: 'No.  : '   INTENSIFIED OFF,
           va_bbeln LEFT-JUSTIFIED.

  WRITE:/ street. "L_VTEXT INTENSIFIED OFF.
  POSITION v_right.
  WRITE: 'Date : ' INTENSIFIED OFF,
          v_date DD/MM/YYYY LEFT-JUSTIFIED.
  WRITE:/  'Proses : ' INTENSIFIED OFF,
           sy-datum INTENSIFIED ON,
           sy-uzeit INTENSIFIED ON.

  POSITION v_right.
  WRITE:  c_page  INTENSIFIED OFF,
          v_current_page LEFT-JUSTIFIED.
  CONCATENATE 'Nama Penagih : ' va_collector INTO v_title4.
  IF NOT v_title4 IS INITIAL.
    WRITE AT: (sy-linsz) v_title4 CENTERED.
  ENDIF.

  IF NOT v_title5 IS INITIAL.
    WRITE AT: (sy-linsz) v_title5 CENTERED.
  ENDIF.
ENDFORM.                    " F_WRITE_HEADER


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
*&      Form  f_call_fb09
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_call_fb09.
  PERFORM f_dynpro USING:           "recording RECMI11
      'X'  'SAPMF05L'	'0102',
  ' ' 'BDC_CURSOR'  'RF05L-GJAHR',
  ' ' 'BDC_OKCODE'  '/00',
  ' ' 'RF05L-BELNR' wa_itab1-belnr,
  ' ' 'RF05L-BUKRS' pa_bukrs,
  ' ' 'RF05L-GJAHR' sy-datum+0(4),
  ' ' 'RF05L-BUZEI' wa_itab1-buzei,
       'X' 'SAPMF05L'   '0301',
  ' ' 'BDC_CURSOR'  'BSEG-ZLSPR',
  ' ' 'BDC_OKCODE'  '=AE',
  ' ' 'BSEG-ZLSPR'  'Z'.


ENDFORM.                    " f_call_fb09
*&---------------------------------------------------------------------*
*&      Form  get_r_print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_r_print.
  SELECT *
           INTO CORRESPONDING FIELDS OF TABLE i_itab1
           FROM zfbid
           WHERE vkbur EQ pa_vkbur AND
                 bukrs EQ pa_bukrs AND
                 bbeln IN so_belnr AND bflag NE 'D'.


ENDFORM.                    " get_r_print
*&---------------------------------------------------------------------*
*&      Form  f_get_min
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_min.
  DATA : v_val LIKE bsid-dmbtr.
  REFRESH i_itab6.

  SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat a~kunnr
              a~waers a~xblnr a~bldat a~monat a~shkzg a~wrbtr a~zfbdt
              a~zbd1t a~buzei a~gsber a~zlspr b~vkbur b~spart a~xref3
              d~pernr a~zuonr a~xref1 a~xref2
           INTO CORRESPONDING FIELDS OF TABLE i_itab6
           FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr
                JOIN knb1 AS d ON d~kunnr EQ a~kunnr AND
                                  d~bukrs EQ a~bukrs
           WHERE a~bukrs EQ pa_bukrs AND
                 a~belnr IN so_belnr AND
                 a~zlspr IN (space,'Z') AND
                 a~blart EQ 'DZ'     AND
                 a~umskz EQ space AND
                 a~kunnr IN so_kunnr AND
                 b~vkbur EQ pa_vkbur AND
                 b~vkorg EQ pa_bukrs AND
                 b~vtweg EQ pa_vtweg AND
                 d~pernr IN so_parnr AND
                 a~wrbtr <= val
                 ORDER BY a~zuonr.

  SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat a~kunnr
         a~waers a~xblnr a~bldat a~monat a~shkzg a~wrbtr a~zfbdt
         a~zbd1t a~buzei a~gsber a~zlspr b~vkbur b~spart a~zuonr
         d~pernr a~xref1 a~xref2
      INTO CORRESPONDING FIELDS OF TABLE i_itab4
      FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr
           JOIN knb1 AS d ON d~kunnr EQ a~kunnr AND
                             d~bukrs EQ a~bukrs
      WHERE a~bukrs EQ pa_bukrs AND
            a~belnr IN so_belnr AND
            a~zlspr IN (space,'Z') AND
* PENAMBAHAN BLART 'DA' REQUEST BY 'LLL' ( DEVK909413 )
* BEGIN DELETE
*               A~BLART IN ('RV','DR','DG', 'ZA')   AND
* END DELETE
* BEGIN INSERT
            a~blart IN ('DA', 'RV','DR','DG', 'ZA')   AND
* END INSERT
            a~umskz EQ space AND
            a~kunnr IN so_kunnr AND
            b~vkbur EQ pa_vkbur AND
            b~vkorg EQ pa_bukrs AND
            b~vtweg EQ pa_vtweg AND
            d~pernr IN so_parnr
*               AND A~WRBTR <= VAL
            ORDER BY a~zuonr.

  SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat a~kunnr
              a~waers a~xblnr a~bldat a~monat a~shkzg a~wrbtr a~zfbdt
              a~zbd1t a~buzei a~gsber a~zlspr b~vkbur b~spart a~zuonr
              d~pernr a~xref1 a~xref2
           INTO CORRESPONDING FIELDS OF TABLE i_itab3
           FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr
                JOIN knb1 AS d ON d~kunnr EQ a~kunnr AND
                                  d~bukrs EQ a~bukrs
           WHERE a~bukrs EQ pa_bukrs AND
                 a~belnr IN so_belnr AND
                 a~zlspr IN (space,'Z') AND
                 a~blart EQ 'DZ'     AND
                 a~umskz EQ space AND
                 a~kunnr IN so_kunnr AND
                 b~vkbur EQ pa_vkbur AND
                 b~vkorg EQ pa_bukrs AND
                 b~vtweg EQ pa_vtweg AND
                 d~pernr IN so_parnr
*               AND  A~WRBTR <= VAL
                 ORDER BY a~zuonr.

  LOOP AT i_itab4 INTO wa_itab1.
    IF wa_itab1-zlspr NE 'B'.

      wa_itab1-wrbtr = wa_itab1-wrbtr * 100.

      nilai = 0. nilai_sfa = 0.
      LOOP AT i_itab3 INTO wa_itab3 WHERE kunnr = wa_itab1-kunnr
AND zuonr = wa_itab1-zuonr.
        IF wa_itab3-shkzg = 'H'.
          wa_itab3-wrbtr = wa_itab3-wrbtr * -1.
        ENDIF.

        nilai = nilai + wa_itab3-wrbtr.
        CLEAR wa_itab3.
        DELETE i_itab3.
      ENDLOOP.
      wa_itab1-wrbtr = wa_itab1-wrbtr +  ( nilai * 100 ).

      SELECT SUM( cchek ) INTO nilai FROM zfbicheck
      WHERE bukrs EQ wa_itab1-bukrs AND vkbur EQ wa_itab1-vkbur
      AND gjahr EQ wa_itab1-gjahr AND zuonr EQ wa_itab1-zuonr
      AND pcair EQ space.

      SELECT SUM( bank_amt ) INTO nilai_sfa FROM zfbic_sfa
      WHERE bukrs EQ wa_itab1-bukrs AND vkbur EQ wa_itab1-vkbur
      AND zuonr EQ wa_itab1-zuonr
      AND pcair EQ space.

*      IF sy-subrc EQ 0.
      IF nilai NE 0 OR nilai_sfa NE 0.
        nilai = nilai + nilai_sfa.
        wa_itab1-wrbtr = wa_itab1-wrbtr - nilai * 100.
      ENDIF.

      wa_itab1-wrbtr = wa_itab1-wrbtr / 100.
      v_val = ABS( wa_itab1-wrbtr ).
      IF  v_val <= val.
        APPEND wa_itab1 TO i_itab1.
      ENDIF.

    ENDIF.
    CLEAR wa_itab1.
  ENDLOOP.

  SORT i_itab3 BY kunnr zuonr.
  LOOP AT i_itab3.
    MOVE-CORRESPONDING i_itab3 TO wa_itab1.
    MOVE-CORRESPONDING wa_itab1 TO i_itab1.
    IF i_itab3-shkzg = 'H'.
      i_itab3-wrbtr = i_itab3-wrbtr * -1.
    ENDIF.
    MODIFY i_itab3.
    IF wa_itab1-kunnr EQ i_itab3-kunnr.
      AT END OF zuonr.
        SUM.
        i_itab1-shkzg = 'S'.
        i_itab1-wrbtr = i_itab3-wrbtr.
        v_val = ABS( i_itab1-wrbtr ).
        IF  v_val <= val.
          APPEND i_itab1.
        ENDIF.
      ENDAT.
    ENDIF.
    CLEAR wa_itab1.
  ENDLOOP.


*SORT I_ITAB6 BY KUNNR ZUONR.
*LOOP AT I_ITAB6.
*   MOVE-CORRESPONDING I_ITAB6 TO WA_ITAB1.
*   MOVE-CORRESPONDING WA_ITAB1 TO I_ITAB1.
*    IF I_ITAB6-SHKZG = 'H'.
*       I_ITAB6-WRBTR = I_ITAB6-WRBTR * -1.
*    ENDIF.
*   MODIFY I_ITAB6.
*  IF WA_ITAB1-KUNNR EQ I_ITAB6-KUNNR.
*     AT END OF ZUONR.
*        SUM.
*        I_ITAB1-SHKZG = 'S'.
*        I_ITAB1-WRBTR = I_ITAB6-WRBTR.
*        V_VAL = ABS( I_ITAB1-WRBTR ).
*        IF  V_VAL <= VAL.
*           APPEND I_ITAB1.
*        ENDIF.
*     ENDAT.
*  ENDIF.
*   CLEAR WA_ITAB1.
*ENDLOOP.

ENDFORM.                    " f_get_min
*&---------------------------------------------------------------------*
*&      Form  cek_flag
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek_flag.
  SELECT SINGLE zlspr INTO flag FROM bseg
  WHERE belnr EQ wa_itab1-belnr AND bukrs EQ pa_bukrs
        AND gjahr EQ sy-datum+0(4)
        AND buzei EQ wa_itab1-buzei.
  IF flag EQ 'B'.
    ROLLBACK WORK.
    MESSAGE a000(26) WITH text-010.
  ENDIF.
ENDFORM.                    " cek_flag
*&---------------------------------------------------------------------*
*&      Form  write_error
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_error.
  DESCRIBE TABLE i_log_error LINES v_line_size.
  IF v_line_size > 0.
    LOOP AT i_log_error INTO wa_log_error.
      FORMAT COLOR 2.
      WRITE: / wa_log_error-bukrs, sy-vline,
               wa_log_error-gjahr,  sy-vline,
               wa_log_error-belnr,  sy-vline.
      NEW-LINE.
      FORMAT COLOR 6. FORMAT COLOR OFF.
      WRITE:AT 10 ' Error Log : ' INTENSIFIED OFF  COLOR 6,
              wa_log_error-msg INTENSIFIED ON   COLOR 6.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " write_error
*&---------------------------------------------------------------------*
*&      Form  cek_lock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek_lock.
  PERFORM belegnummer_sperren_rc(sapff001)
  USING wa_itab1-bukrs wa_itab1-belnr wa_itab1-gjahr rcode.
  IF rcode NE 0.
    flock = space.

  ELSE.                                                     "ALRK222406
    PERFORM belegnummer_entsperren(sapff001)                "ALRK222406
   USING wa_itab1-bukrs wa_itab1-belnr wa_itab1-gjahr.      "ALRK222406
    flock = 'X'.
  ENDIF.

ENDFORM.                    " cek_lock
*&---------------------------------------------------------------------*
*&      Form  write_tabel_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_tabel_header.
*    DESCRIBE TABLE I_ITAB5 LINES VA_NOU.
  CLEAR: va_nou.
  LOOP AT i_itab5 INTO wa_itab1.
    ADD 1 TO va_nou.
*        ZFBIH-GJAHR = wa_itab1-gjahr.
    IF va_nou > 0.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF va_nou <= 0.
    EXIT.
  ENDIF.
  CLEAR: va_bbeln.
  SELECT  MAX( bbeln ) INTO va_bbeln FROM zfbih
  WHERE bukrs EQ pa_bukrs AND vkbur EQ pa_vkbur.
*             AND GJAHR EQ SY-DATUM(4).
  IF sy-subrc EQ 0.
    ADD 1 TO va_bbeln.
  ELSE.
    va_bbeln = 1.
  ENDIF.
  IF koreksi = 'X'.
    va_bbeln = belnr.
  ENDIF.

  MOVE pa_bukrs      TO zfbih-bukrs.
  MOVE pa_vkbur      TO zfbih-vkbur.
  MOVE va_bbeln      TO zfbih-bbeln.
*         MOVE SY-DATUM+0(4) TO ZFBIH-GJAHR.
  MOVE sy-datum      TO zfbih-bidat.
  MOVE 'IDR'         TO zfbih-waers.
  MOVE sy-uname      TO zfbih-usna1.
  MOVE sy-uzeit      TO zfbih-erzet.
  MOVE sy-datum      TO zfbih-erdt1.

  MODIFY zfbih.

ENDFORM.                    " write_tabel_header
*&---------------------------------------------------------------------*
*&      Form  get_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_delete.
  SELECT bukrs gjahr vbeln bbeln fkdat kunnr wrbtr zuonr zfbdt buzei erdt2
                               INTO CORRESPONDING FIELDS OF TABLE i_itab1
                                                               FROM zfbid
                            WHERE bukrs EQ pa_bukrs AND vkbur EQ pa_vkbur
                                    AND bbeln EQ belnr AND bflag EQ space.

  LOOP AT i_itab1.
    i_itab1-zuonr1 = i_itab1-zuonr.
    MODIFY i_itab1.
  ENDLOOP.
ENDFORM.                    " get_delete
*&---------------------------------------------------------------------*
*&      Form  print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print.
  DATA: ld_params   LIKE pri_params,
         vspld LIKE  usr01-spld,
         ld_arparams LIKE arc_params.
  DATA: ld_layout   LIKE sy-paart,     "Druck-Layout
        ld_valid.

* Standardlayout zum im Benutzerstamm eingetragenen Drucker setzen
  SELECT SINGLE spld INTO vspld FROM usr01 WHERE bname = sy-uname.
*{   REPLACE        P01K900131                                        1
*\  PERFORM set_layout(saplspri) USING    vspld 1 sy-linsz
  PERFORM set_layout(saplspri) USING    vspld 1 sy-linsz 1 sy-linsz "by sap_dev04 04/04/07
*}   REPLACE
                               CHANGING ld_layout.

  ld_layout = 'Z_KB'.

  CALL FUNCTION 'GET_PRINT_PARAMETERS'
       EXPORTING
*            IMMEDIATELY            = 'X'
            cover_page             = space
            sap_cover_page         = space
*            RELEASE                = 'X'
*            NEW_LIST_ID            = SPACE
            host_cover_page        = space
            line_size              = sy-linsz
            layout                 = ld_layout
       IMPORTING
            out_parameters         = ld_params
            out_archive_parameters = ld_arparams
            valid                  = ld_valid.

  IF ld_valid EQ 'X'.
    NEW-PAGE PRINT ON PARAMETERS ld_params
                      ARCHIVE PARAMETERS ld_arparams
                      NEW-SECTION NO DIALOG.

    va_nou = 0.
    CLEAR: va_sw.
    LOOP AT i_itab5 INTO wa_itab1.
      ADD 1 TO va_nou.
*      va_count = va_nou MOD 34.
*      IF va_count EQ 0.
*        WRITE: / sy-uline.
*        NEW-PAGE.
*      ENDIF.
      ADD 1 TO va_sw.
      IF va_sw EQ 31.
        CLEAR: va_sw.
        WRITE: / sy-uline.
        NEW-PAGE.
      ENDIF.

      PERFORM f_print_detail.
    ENDLOOP.

    WRITE: /(204) sy-uline.
    PERFORM f_print_total.
    LEAVE TO SCREEN 0.
  ENDIF.

  NEW-PAGE PRINT OFF.

ENDFORM.                    " print
*&---------------------------------------------------------------------*
*&      Form  route_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM route_list.
  IF pa_route  IS INITIAL.
  ELSE.
    CLEAR wa_itab1.
    LOOP AT i_itab1 INTO wa_itab1.
      SELECT SINGLE kunnr INTO lkunde FROM vbpa
          WHERE vbeln EQ wa_itab1-belnr AND
                parvw EQ 'ZC'.

      IF lkunde <> pa_route.
        CLEAR wa_itab3.
        LOOP AT i_itab3 INTO wa_itab3 WHERE
                  zuonr <> wa_itab1-zuonr.
          DELETE i_itab3.
        ENDLOOP.

        DELETE i_itab1.
      ENDIF.
    ENDLOOP.
    DESCRIBE TABLE i_itab1 LINES va_nou.
  ENDIF.

ENDFORM.                    " route_list
*&---------------------------------------------------------------------*
*&      Form  do_no
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM do_no.
  IF do_no  IS INITIAL.
  ELSE.
    CLEAR wa_itab1.
    LOOP AT i_itab1 INTO wa_itab1.
      IF wa_itab1-zuonr IN do_no.
      ELSE.
        DELETE i_itab1.
      ENDIF.
    ENDLOOP.
    DESCRIBE TABLE i_itab1 LINES va_nou.
  ENDIF.

ENDFORM.                    " do_no
*&---------------------------------------------------------------------*
*&      Form  bloksl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bloksl.
  DATA belnr LIKE bsid-belnr.
  SELECT  belnr buzei INTO TABLE itab FROM bsid
  WHERE bukrs EQ pa_bukrs AND kunnr EQ wa_itab1-kunnr AND
        zuonr EQ wa_itab1-zuonr AND gjahr EQ wa_itab1-gjahr.
  LOOP AT itab.
    CLEAR i_bdc.
    PERFORM f_dynpro USING:
             'X'  'SAPMF05L'   '0102',
             ' ' 'BDC_CURSOR'	 'RF05L-GJAHR',
           ' ' 'BDC_OKCODE'  '/00',
           ' ' 'RF05L-BELNR' itab-belnr,
           ' ' 'RF05L-BUKRS' pa_bukrs,
           ' ' 'RF05L-GJAHR' wa_itab1-gjahr,
*	         ' ' 'RF05L-XKDEB' 'X',
             ' ' 'RF05L-BUZEI' itab-buzei,
             'X' 'SAPLFCPD'   '0100',
             ' ' 'BDC_CURSOR' 'BSEC-SPRAS',
             ' ' 'BDC_OKCODE' '/00',
             'X' 'SAPMF05L'    '0301',
           ' ' 'BDC_CURSOR'  'BSEG-ZLSPR',
           ' ' 'BDC_OKCODE'  '=AE',
             ' ' 'BSEG-ZLSPR'	 'B'.
    CALL TRANSACTION 'FB09' USING i_bdc MODE 'N' UPDATE 'S'
            MESSAGES INTO messtab.

  ENDLOOP.
ENDFORM.                    " bloksl
*&---------------------------------------------------------------------*
*&      Form  blok
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM blok.
  DATA : belnr LIKE bsid-belnr,
         l_zuonr(11).

  SELECT  belnr buzei INTO TABLE itab FROM bsid
  WHERE bukrs EQ pa_bukrs AND kunnr EQ wa_itab1-kunnr AND
        zuonr EQ wa_itab1-zuonr AND gjahr EQ wa_itab1-gjahr.
  IF sy-subrc NE 0.
    CONCATENATE wa_itab1-zuonr 'R' INTO l_zuonr.
    SELECT  belnr buzei INTO TABLE itab FROM bsid
    WHERE bukrs EQ pa_bukrs AND kunnr EQ wa_itab1-kunnr AND
        zuonr EQ l_zuonr AND gjahr EQ wa_itab1-gjahr.
  ENDIF.
  LOOP AT itab.
    CLEAR i_bdc.
    PERFORM f_dynpro USING:
             'X'  'SAPMF05L'   '0102',
             ' ' 'BDC_CURSOR'	 'RF05L-GJAHR',
           ' ' 'BDC_OKCODE'  '/00',
           ' ' 'RF05L-BELNR' itab-belnr,
           ' ' 'RF05L-BUKRS' pa_bukrs,
           ' ' 'RF05L-GJAHR' wa_itab1-gjahr,
*               ' ' 'RF05L-XKDEB' 'X',
           ' ' 'RF05L-BUZEI' itab-buzei,
             'X' 'SAPMF05L'    '0301',
           ' ' 'BDC_CURSOR'  'BSEG-ZLSPR',
           ' ' 'BDC_OKCODE'  '=AE',
             ' ' 'BSEG-ZLSPR'	 'B'.
    CALL TRANSACTION 'FB09' USING i_bdc MODE 'N' UPDATE 'S'
                MESSAGES INTO messtab.

  ENDLOOP.
ENDFORM.                    " blok
*&---------------------------------------------------------------------*
*&      Form  open_blok
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM open_blok.
  DATA belnr LIKE bsid-belnr.
  SELECT  belnr buzei INTO TABLE itab FROM bsid
  WHERE bukrs EQ pa_bukrs AND kunnr EQ wa_itab1-kunnr AND
        zuonr EQ wa_itab1-zuonr.
* Tahun
*      AND GJAHR EQ WA_ITAB1-GJAHR.
  LOOP AT itab.
    CLEAR i_bdc.
    PERFORM f_dynpro USING:
             'X'  'SAPMF05L'   '0102',
             ' ' 'BDC_CURSOR'	 'RF05L-GJAHR',
           ' ' 'BDC_OKCODE'  '/00',
           ' ' 'RF05L-BELNR' itab-belnr,
           ' ' 'RF05L-BUKRS' pa_bukrs,
           ' ' 'RF05L-GJAHR' wa_itab1-gjahr,
           ' ' 'RF05L-BUZEI' itab-buzei,
             'X' 'SAPMF05L'    '0301',
           ' ' 'BDC_CURSOR'  'BSEG-ZLSPR',
           ' ' 'BDC_OKCODE'  '=AE',
             ' ' 'BSEG-ZLSPR'	 'Z'.
    CALL TRANSACTION 'FB09' USING i_bdc MODE 'N' UPDATE 'S'
                MESSAGES INTO messtab.

  ENDLOOP.

ENDFORM.                    " open_blok

*---------------------------------------------------------------------*
*       FORM F_WRITE_HEADER                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_write_header.

  WRITE sy-pagno TO v_current_page.
  SHIFT v_current_page LEFT DELETING LEADING space.
  IF v_title1 EQ space.
    v_title1 = sy-title.
  ENDIF.

  v_between_header_len =
    110 - v_left_header_len - v_right_header_len - 4.
  v_right = 110 - v_right_header_len + 1.

  FORMAT COLOR OFF INTENSIFIED ON.
  WRITE AT: /20(v_between_header_len) v_title1 CENTERED.
  WRITE: 1 c_report INTENSIFIED OFF, 'Print Borderel Inkaso'.

  POSITION v_right.
  WRITE:  c_date   INTENSIFIED OFF,
          sy-datum DD/MM/YYYY LEFT-JUSTIFIED.
  WRITE:/ c_clisys INTENSIFIED OFF.
  WRITE:   sy-mandt NO-GAP, '/' NO-GAP, sy-sysid.
  WRITE AT: 20(v_between_header_len) v_title2 CENTERED.

  POSITION v_right.
  WRITE:  c_time      INTENSIFIED OFF,
          sy-uzeit LEFT-JUSTIFIED.
  WRITE:/ c_userid    INTENSIFIED OFF,  sy-uname.
  WRITE AT: 20(v_between_header_len) v_title3 CENTERED.

  POSITION v_right.
  WRITE:  c_page  INTENSIFIED OFF,
          v_current_page LEFT-JUSTIFIED.
  IF NOT v_title4 IS INITIAL.
    WRITE AT: (sy-linsz) v_title4 CENTERED.
  ENDIF.

  IF NOT v_title5 IS INITIAL.
    WRITE AT: (sy-linsz) v_title5 CENTERED.
  ENDIF.
ENDFORM.                    " F_WRITE_HEADER
*&---------------------------------------------------------------------*
*&      Form  CEK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek.
  AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
          ID 'GSBER' FIELD pa_vkbur
          ID 'ACTVT' FIELD '01'.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH
   'You have no authorization for Sales Office' pa_vkbur.
  ENDIF.

ENDFORM.                    " CEK
*&---------------------------------------------------------------------*
*&      Form  LOCK_ZFBIH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lock_zfbih.
*{   REPLACE        P01K910757                                        1
*\  CALL FUNCTION 'ENQUEUE_E0001'
*\      EXPORTING
*\         bukrs  = pa_bukrs
*\         vkbur = pa_vkbur
*\         bbeln = pa_bbeln
*\*       GJAHR = PA_GJAHR
*\      EXCEPTIONS
*\          foreign_lock   = 4
*\          system_failure = 8.
*\  IF sy-subrc EQ 4.
*\    MESSAGE a000(26) WITH text-041.
*\  ENDIF.
  "Start SOH: Shell Remediation Adjustment 20240325 KRS
  CALL FUNCTION 'ENQUEUE_EZFBIH'
      EXPORTING
        bukrs  = pa_bukrs
         vkbur = pa_vkbur
         bbeln = belnr
*       GJAHR = ZFBIH-GJAHR
      EXCEPTIONS
          foreign_lock   = 4
          system_failure = 8.
  IF sy-subrc EQ 4.
    MESSAGE a000(26) WITH text-041.
  ENDIF.
  "End SOH: Shell Remediation Adjustment 20240325 KRS
*}   REPLACE


ENDFORM.                    " LOCK_ZFBIH
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_ADD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data_add.
  DATA: l_kunnr LIKE knvp-kunnr.

  SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat a~kunnr
         a~waers a~xblnr a~bldat a~monat a~shkzg a~wrbtr a~zfbdt
         a~zbd1t a~buzei a~gsber a~zlspr b~vkbur b~spart a~zuonr
         d~pernr a~xref1 a~xref2 a~xref3 a~vbund
      INTO CORRESPONDING FIELDS OF TABLE i_itab7
      FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr
           JOIN knb1 AS d ON d~kunnr EQ a~kunnr AND
                             d~bukrs EQ a~bukrs
      WHERE a~bukrs EQ pa_bukrs AND
            a~zlspr IN (space,'Z','B')    AND
* PENAMBAHAN BLART 'DA' REQUEST BY 'LLL' ( DEVK909413 )
* BEGIN DELETE
*               A~BLART IN ('RV','DR','DG', 'ZA')   AND
* END DELETE
* BEGIN INSERT
            a~blart IN ('DA', 'RV','DR','DG', 'ZA')   AND
* END INSERT
            a~umskz EQ space AND
            a~kunnr IN so_kunnr AND
            b~vkbur EQ pa_vkbur AND
            b~vkorg EQ pa_bukrs AND
            b~vtweg EQ pa_vtweg AND
            d~pernr IN so_parnr
            ORDER BY a~zuonr.

  SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat a~kunnr
              a~waers a~xblnr a~bldat a~monat a~shkzg a~wrbtr a~zfbdt
              a~zbd1t a~buzei a~gsber a~zlspr b~vkbur b~spart a~zuonr
              d~pernr a~xref1 a~xref2 a~vbund
           INTO CORRESPONDING FIELDS OF TABLE i_itab6
           FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr
                JOIN knb1 AS d ON d~kunnr EQ a~kunnr AND
                                  d~bukrs EQ a~bukrs
           WHERE a~bukrs EQ pa_bukrs AND
                 a~zlspr IN (space,'Z')    AND
                 a~blart EQ 'DZ'     AND
                 a~umskz EQ space AND
                 a~kunnr IN so_kunnr AND
                 b~vkbur EQ pa_vkbur AND
                 b~vkorg EQ pa_bukrs AND
                 b~vtweg EQ pa_vtweg AND
                 d~pernr IN so_parnr
                 ORDER BY a~zuonr.


  SORT i_itab6 BY kunnr zuonr.
  LOOP AT i_itab6.
    MOVE-CORRESPONDING i_itab6 TO wa_itab1.
    MOVE-CORRESPONDING wa_itab1 TO i_itab3.
    IF i_itab6-shkzg = 'H'.
      i_itab6-wrbtr = i_itab6-wrbtr * -1.
    ENDIF.
    MODIFY i_itab6.
    IF wa_itab1-kunnr EQ i_itab6-kunnr.
      AT END OF zuonr.
        SUM.
        i_itab3-shkzg = 'S'.
        i_itab3-wrbtr = i_itab6-wrbtr.
        APPEND i_itab3.
      ENDAT.
    ENDIF.
    CLEAR wa_itab1.
  ENDLOOP.

  SORT i_itab7 BY kunnr zuonr.
  LOOP AT i_itab7.
    MOVE-CORRESPONDING i_itab7 TO wa_itab1.
    MOVE-CORRESPONDING wa_itab1 TO i_itab1.
    IF i_itab7-shkzg = 'H'.
      i_itab7-wrbtr = i_itab7-wrbtr * -1.
    ENDIF.
    v_zbd1t = i_itab7-zbd1t.
    i_itab7-zbd1t = 0.
    MODIFY i_itab7.
    IF wa_itab1-kunnr EQ i_itab7-kunnr.
      AT END OF zuonr.
        SUM.
        i_itab1-shkzg = 'S'.
        i_itab1-wrbtr = i_itab7-wrbtr.
        i_itab1-zbd1t = v_zbd1t.
        APPEND i_itab1.
      ENDAT.
    ENDIF.
    CLEAR wa_itab1.
  ENDLOOP.

ENDFORM.                    " F_GET_DATA_ADD
*&---------------------------------------------------------------------*
*&      Form  GET_ZFBID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_zfbid.
  SELECT bukrs gjahr vbeln bbeln fkdat kunnr wrbtr zuonr zfbdt buzei erdt2
                               INTO CORRESPONDING FIELDS OF TABLE t_zfbid
                                                               FROM zfbid
                            WHERE bukrs EQ pa_bukrs AND vkbur EQ pa_vkbur
                                                       AND bbeln EQ belnr.


ENDFORM.                    " GET_ZFBID
*&---------------------------------------------------------------------*
*&      Form  get_vbund
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_vbund.
  DATA : l_kunnr LIKE zfbid-kunnr,
         l_belnr LIKE bsid-belnr,
         l_gjahr LIKE bsid-gjahr.

  SELECT SINGLE kunnr vbeln gjahr INTO (l_kunnr, l_belnr, l_gjahr)
  FROM zfbid WHERE bukrs EQ pa_bukrs AND vkbur EQ pa_vkbur AND
                   bbeln EQ belnr.
  IF sy-subrc EQ 0.
    SELECT SINGLE vbund INTO va_vbund FROM bsid
    WHERE bukrs EQ pa_bukrs AND kunnr EQ l_kunnr AND
          belnr EQ l_belnr AND gjahr EQ l_gjahr.
    sw = 1.
  ENDIF.
ENDFORM.                    " get_vbund

*&---------------------------------------------------------------------*
*&      Form  f_get_zfhkr1at
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_zfhkr1at .
  SELECT *
    FROM zfh_kr1at
    INTO CORRESPONDING FIELDS OF TABLE t_zfh_kr1at
    FOR ALL ENTRIES IN i_itab2
    WHERE bukrs     EQ pa_bukrs      AND
          gsber     EQ '0200'        AND
          vkbur     EQ pa_vkbur      AND
          zuonr     EQ i_itab2-zuonr AND
          kunnr     EQ i_itab2-kunnr AND
          belnrpos2 EQ space.
ENDFORM.                    " f_get_zfhkr1at

*&---------------------------------------------------------------------*
*&      Module  status_0501  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0501 OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " status_0501  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  list_processing_0501  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE list_processing_0501 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_error_list.
ENDMODULE.                 " list_processing_0501  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  f_error_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_error_list .
  IF t_error[] IS INITIAL.
    WRITE: /13 'No error occurs'.
  ELSE.
    ULINE AT /(89).
    WRITE: /  sy-vline NO-GAP, (5) 'SOff' NO-GAP,
              sy-vline NO-GAP, (15) 'Kode Outlet' NO-GAP,
              sy-vline NO-GAP, (18) 'Nomor DO' NO-GAP,
              sy-vline NO-GAP, (15) 'Nomor FORM 3' NO-GAP,
              sy-vline NO-GAP, (30) 'Message' NO-GAP,
              sy-vline.
    ULINE AT /(89).
    LOOP AT t_error.
      WRITE: /  sy-vline NO-GAP, (5) t_error-vkbur NO-GAP,
                sy-vline NO-GAP, (15) t_error-kunnr NO-GAP,
                sy-vline NO-GAP, t_error-zuonr NO-GAP,
                sy-vline NO-GAP, (15) t_error-noform NO-GAP,
                sy-vline NO-GAP, (30) 'No DO sudah ada di FORM 3' NO-GAP,
                sy-vline NO-GAP.
    ENDLOOP.
    ULINE AT /(89).
  ENDIF.
ENDFORM.                    " f_error_list

*&---------------------------------------------------------------------*
*&      Form  F_GET_ZFBID_SFA
*&---------------------------------------------------------------------*
FORM f_get_zfbid_sfa .
  SELECT * INTO TABLE gt_zfbid_sfa
    FROM zfbid_sfa FOR ALL ENTRIES IN i_itab1
    WHERE bukrs = i_itab1-bukrs
      AND vkbur = i_itab1-vkbur
      AND gjahr = i_itab1-gjahr
      AND zuonr = i_itab1-zuonr.
ENDFORM.                    " F_GET_ZFBID_SFA
