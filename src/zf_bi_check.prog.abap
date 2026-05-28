REPORT zf_bi_check MESSAGE-ID zs NO STANDARD PAGE HEADING
                                  LINE-COUNT 65(3)
                                  LINE-SIZE  136.


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
*& DEVK935891     19.08.2013                  Modifikasi untuk SUT     *
*&                                            Project                  *
*----------------------------------------------------------------------*
****************************************************
*        Tables                                    *
****************************************************
TABLES: t001,
        zfbih,
        zfbid,
        bseg,
        kna1,
        sscrfields,
        zfbicheck,
        zfbic_sfa,
        zfbih_sfa,
        zfbierror.


************************************************************************
* STRUCTURES & INTERNAL TABLES                                         *
************************************************************************
TYPES : BEGIN OF t_itab1,
          bukrs LIKE zfbih-bukrs,
          bbeln LIKE zfbih-bbeln,
          gjahr LIKE zfbid-gjahr,
          bidat LIKE zfbih-bidat,
          parnr LIKE zfbih-parnr,
          waers LIKE zfbih-waers,
          vkbur LIKE zfbid-vkbur,
          ebelp LIKE zfbid-ebelp,
          vbeln LIKE zfbid-vbeln,
          buzei LIKE zfbid-buzei,
          gsber LIKE zfbid-gsber,
          fkdat LIKE zfbid-fkdat,
          kunnr LIKE zfbid-kunnr,
          parvw LIKE zfbid-parvw,
          slcod LIKE zfbid-slcod,
          zfbdt LIKE zfbid-zfbdt,
          wrbtr LIKE zfbid-wrbtr,
          pcash LIKE zfbid-pcash,
          pchek LIKE zfbid-pchek,
          pytot LIKE zfbid-pytot,
          resid LIKE zfbid-resid,
          pcnot LIKE zfbid-pcnot,
          jmlck LIKE zfbid-jmlck,
          xblnr LIKE zfbid-xblnr,
          hkont LIKE zfbid-hkont,
          usna1 LIKE zfbid-usna1,
          erdt1 LIKE zfbid-erdt1,
          usna2 LIKE zfbid-usna2,
          erdt2 LIKE zfbid-erdt2,
          bflag LIKE zfbid-bflag,
          pstat LIKE zfbid-pstat,
          ptype LIKE zfbid-ptype,
        END OF t_itab1.

TYPES:   BEGIN OF t_bdc.
           INCLUDE STRUCTURE bdcdata.
         TYPES:   END OF t_bdc.

TYPES:   BEGIN OF t_messtab.
           INCLUDE STRUCTURE bdcmsgcoll.
         TYPES:   END OF t_messtab.

TYPES: BEGIN OF t_log_error,
         bukrs   LIKE bsis-bukrs,
         gjahr   LIKE bsis-gjahr,
         belnr   LIKE bsis-belnr,
         msg(80),
       END OF t_log_error.

DATA : BEGIN OF itab OCCURS 10.
         INCLUDE STRUCTURE zfbicheck.
       DATA : END OF itab.

DATA : BEGIN OF itab4 OCCURS 10.
         INCLUDE STRUCTURE zfbicheck.
       DATA : END OF itab4.

DATA : BEGIN OF itab1 OCCURS 10,
         belnr LIKE zfbicheck-belnr,
         bukrs LIKE zfbicheck-bukrs,
         vkbur LIKE zfbicheck-vkbur,
         gjahr LIKE zfbicheck-gjahr,
         buzei LIKE zfbicheck-buzei,
         kunnr LIKE zfbicheck-kunnr,
         zfbdt LIKE zfbicheck-zfbdt,
         cekno LIKE zfbicheck-cekno,
         gsber LIKE zfbicheck-gsber,
         bbeln LIKE zfbicheck-bbeln,
         slcod LIKE zfbicheck-slcod,
         bname LIKE zfbicheck-bname,
         xblnr LIKE zfbicheck-xblnr,
         wrbtr LIKE zfbicheck-wrbtr,
         cchek LIKE zfbicheck-cchek,
         duedt LIKE zfbicheck-duedt,
         zuonr LIKE zfbicheck-zuonr,
         hkont LIKE zfbicheck-hkont,
         blnck LIKE zfbicheck-blnck,
         parvw LIKE zfbid-parvw,
       END OF itab1.

DATA : BEGIN OF itab2 OCCURS 10.
         INCLUDE STRUCTURE zfbicheck.
         DATA : tgl_bi  LIKE zfbid-erdt1,
         tgl_fak LIKE zfbid-fkdat,
         sfa(1),
       END OF itab2.

DATA : BEGIN OF itab2_sfa OCCURS 10.
         INCLUDE STRUCTURE zfbic_sfa.
         DATA : tgl_bi  LIKE zfbid-erdt1,
         tgl_fak LIKE zfbid-fkdat,
         sfa(1),
       END OF itab2_sfa.

DATA : BEGIN OF itab5 OCCURS 0,
         bbeln      LIKE zfbicheck-bbeln,
         cekno      LIKE zfbicheck-cekno,
         bname      LIKE zfbicheck-bname,
         duedt      LIKE zfbicheck-duedt,
         error(126),
       END OF itab5.

DATA:   BEGIN OF t_bdc OCCURS 0.
          INCLUDE STRUCTURE bdcdata.
        DATA:   END OF t_bdc.

DATA:   BEGIN OF messtab OCCURS 0.
          INCLUDE STRUCTURE bdcmsgcoll.
        DATA:   END OF messtab.

DATA:   BEGIN OF messtab1 OCCURS 0.
          INCLUDE STRUCTURE bdcmsgcoll.
        DATA:   END OF messtab1.

DATA: msg(80),
      i_log_error  TYPE t_log_error OCCURS 0,
      wa_log_error TYPE t_log_error.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
*constants :

************************************************************************
* VARIABLES                                                            *
************************************************************************
DATA:
  v_line_size     TYPE i,
  v_line_size_sum TYPE i,
  va_mark(1),srt(20),
  amountinv(12),
  amtinv          LIKE bseg-dmbtr,
  paytot          LIKE bseg-dmbtr,
  waers           LIKE bkpf-waers,
  tot             LIKE bseg-dmbtr,
  total4          LIKE bseg-dmbtr,
  tot1            LIKE bseg-dmbtr,
  totchek         LIKE bseg-dmbtr,
  v_cekno(12), "like zfbicheck-cekno,
  duedt           LIKE zfbicheck-duedt,
  bname           LIKE zfbicheck-bname,
  v_count         TYPE i,
  v_pytot         LIKE bseg-dmbtr,
  i_bdc           TYPE t_bdc OCCURS 0,
  wa_bdc          TYPE t_bdc,
  i_messtab       TYPE t_messtab OCCURS 0,
  wa_messtab      TYPE t_messtab,
  cvn             LIKE zfbid-xblnr,
  txt             LIKE bseg-sgtxt,
  tolak           LIKE zfbicheck-blnck,
  no(10),
  gt(6),
  tbatal          LIKE bseg-dmbtr,
  tcair           LIKE bseg-dmbtr,
  saldo           LIKE bseg-dmbtr,
  tsaldo          LIKE bseg-dmbtr,
  tsaldo_ar       LIKE bseg-dmbtr,
  tfaktur         LIKE bseg-dmbtr,
  tbatal1         LIKE bseg-dmbtr,
  v_gsber         LIKE bsid-gsber,
  poskey(2),
  jumlah(255),
  text1           LIKE spell,
  bidat(8),
  bldat(8),
  monat(2),
  date(8),
  cash(13),sw TYPE i,
  radio6(1),
  cek             LIKE zfbicheck-cekno,
  dued            LIKE zfbicheck-duedt,
  bank            LIKE zfbicheck-bname,
  item            LIKE zfbicheck-buzei,
  v_custno        LIKE kna1-kunnr,
  v_vbeln         LIKE zfbid-vbeln,
  va_nou          TYPE i,va_flag(1),
  c1              TYPE i,
  c2              TYPE i,
  c3              TYPE i,
  c4              TYPE i,
  w1              TYPE i,  w2    TYPE i,  w3    TYPE i,  w4    TYPE i,
  w5              TYPE i,  w6    TYPE i,  w7    TYPE i,  w8    TYPE i,
  w9              TYPE i,  w10   TYPE i,  w11   TYPE i,  w12   TYPE i,
  w13             TYPE i,  w14   TYPE i,  w15   TYPE i,  w16   TYPE i,
  w17             TYPE i,  w18   TYPE i,  w19   TYPE i,  w19a  TYPE i,
  w20             TYPE i,  w17a  TYPE i,
  w21             TYPE i,  w22   TYPE i,  w23   TYPE i,  w24   TYPE i,
  w25             TYPE i,  w26   TYPE i,  w27   TYPE i,  w28   TYPE i,
  w29             TYPE i,  w30   TYPE i,  w31   TYPE i,  w32   TYPE i,
  w33             TYPE i,  w34   TYPE i,  w35   TYPE i,
  l_name          LIKE kna1-name1.

DATA: i_itab1    TYPE t_itab1 OCCURS 0,
      i_itab2    TYPE t_itab1,                                " occurs 0,
      wa_itab1   TYPE t_itab1,
      pa_bbeln   LIKE zfbicheck-bbeln,
      bdcmode(1).
************************************************************************
* INCLUDES                                                             *
************************************************************************
INCLUDE <%_list>.
INCLUDE zsheader.

DATA: va_line(1024),
      va_linectr    TYPE i,
      va_list       TYPE slist_listline.
RANGES cekno FOR zfbicheck-cekno.
****************************************************
*        Parameters                                *
****************************************************
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS  pa_bukrs LIKE  t001-bukrs OBLIGATORY DEFAULT '8020'.
PARAMETERS  pa_vkbur LIKE zfbid-vkbur OBLIGATORY DEFAULT '0201'.
SELECT-OPTIONS custno  FOR  zfbid-kunnr MODIF ID ars .
SELECT-OPTIONS slcode  FOR  zfbid-slcod MODIF ID ars.
SELECT-OPTIONS duedt2  FOR  zfbicheck-duedt MODIF ID ssd.
PARAMETERS duedt1 LIKE zfbicheck-duedt OBLIGATORY DEFAULT sy-datum
MODIF ID ssa.
*SELECT-OPTIONS cekno   FOR  zfbicheck-cekno MODIF ID ars.
SELECT-OPTIONS b_check   FOR  zfbic_sfa-bank_check MODIF ID ars.
*     Parameters  pa_gjahr like zfbih-gjahr obligatory
*         default sy-datum+0(4) modif id ARS.
PARAMETERS pa_blchk LIKE zfbicheck-blnck.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio1 RADIOBUTTON GROUP grp1 USER-COMMAND ars
             DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(35) TEXT-003.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio7 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-016.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-004.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio8 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-017.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-005.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio31 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-051.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio9 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-018.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-006.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-007.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF SCREEN 500 AS WINDOW.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(28) TEXT-014.
SELECTION-SCREEN POSITION 30.
PARAMETER : total TYPE i. "like bsis-dmbtr.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(28) TEXT-015.
SELECTION-SCREEN POSITION 30.
PARAMETER : vcrn LIKE zfbicheck-xblnr.
SELECTION-SCREEN END OF LINE.


SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN COMMENT 1(28) TEXT-011.
SELECTION-SCREEN POSITION 30.
PARAMETER : hkont LIKE bseg-hkont OBLIGATORY. "default '0113102010'.
SELECTION-SCREEN POSITION 41.
PARAMETER text  LIKE skat-txt20 MODIF ID ssb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(28) TEXT-012.
SELECTION-SCREEN POSITION 30.
PARAMETER : budat LIKE sy-datum OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF SCREEN 500.

SELECTION-SCREEN BEGIN OF SCREEN 600 AS WINDOW.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(28) TEXT-014.
SELECTION-SCREEN POSITION 30.
PARAMETER : total1 LIKE bsis-dmbtr.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF SCREEN 600.

SELECTION-SCREEN BEGIN OF SCREEN 650 AS WINDOW.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(14) TEXT-044.
SELECTION-SCREEN POSITION 16.
PARAMETER : ocekno LIKE zfbicheck-cekno MODIF ID abc .
SELECTION-SCREEN COMMENT 34(14) TEXT-046.
SELECTION-SCREEN POSITION 50.
PARAMETER : obank LIKE zfbicheck-bname MODIF ID abc .
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(14) TEXT-045.
SELECTION-SCREEN POSITION 16.
PARAMETER : ncekno LIKE zfbicheck-cekno.
SELECTION-SCREEN COMMENT 34(14) TEXT-047.
SELECTION-SCREEN POSITION 50.
PARAMETER : nbank LIKE zfbicheck-bname .

SELECTION-SCREEN END OF LINE.
.


SELECTION-SCREEN END OF SCREEN 650.




************************************************************************
* PROGRAM                                                              *
************************************************************************
************************************************************************
* AT SELECTION-SCREEN
************************************************************************
*at selection-screen on .
************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.
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
  DATA lv_usrgrp(12).
  IF radio31 = 'X'.
    PERFORM f_auth_usrgrp CHANGING lv_usrgrp.
    IF lv_usrgrp IS INITIAL.
      MESSAGE 'You are not Authorize' TYPE 'S' DISPLAY LIKE 'E'.
      STOP.
    ENDIF.
  ENDIF.

  LOOP AT b_check.
    cekno =  b_check..
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = b_check-low
      IMPORTING
        output = cekno-low.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = b_check-high
      IMPORTING
        output = cekno-high.
    APPEND cekno.

  ENDLOOP.



  bdcmode = 'N'.
  PERFORM cek.
  IF radio1 = 'X'.
    SET PF-STATUS 'ZF_BI_CHECK'.
    PERFORM get_data.
    DESCRIBE TABLE itab2 LINES v_line_size.
    IF v_line_size > 0.
      CALL SELECTION-SCREEN 500 STARTING AT 10 10.
    ELSE.
      MESSAGE i000(26) WITH TEXT-010.
      STOP.
    ENDIF.

    IF total <> 0 AND hkont >= '0113101010' AND hkont <= '0113199999'.
      PERFORM cek_account.
      PERFORM header.
      SORT itab2 BY bname cekno.
      PERFORM detail.
    ELSE.
      MESSAGE i000(26) WITH 'GL Account number # Harus 113101010 s/d 113199999'.
    ENDIF.
  ENDIF.
  IF radio2 = 'X'.
    SET PF-STATUS 'ZF_BI_CHECK'.
    PERFORM get_data_tolak.
    DESCRIBE TABLE itab2 LINES v_line_size.
    IF v_line_size > 0.
      CALL SELECTION-SCREEN 600 STARTING AT 10 10.
    ELSE.
      MESSAGE i000(26) WITH TEXT-010.
      STOP.
    ENDIF.
    IF total1 <> 0.
      PERFORM header.
      PERFORM detail.

    ENDIF.
  ENDIF.
  IF radio3 = 'X' OR radio31 = 'X'.
    SET PF-STATUS 'ZF_BI_CHECK'.
    PERFORM get_data.
    DESCRIBE TABLE itab2 LINES v_line_size.
    IF radio3 = 'X'.
      IF v_line_size > 0.
        CALL SELECTION-SCREEN 600 STARTING AT 10 10.
      ELSE.
        MESSAGE i000(26) WITH TEXT-010.
        STOP.
      ENDIF.
      IF total1 <> 0.
        PERFORM header.
        PERFORM detail.
      ENDIF.
    ELSE.
      PERFORM header.
      PERFORM detail.
    ENDIF.
  ENDIF.
  IF radio4 = 'X'.
    PERFORM get_data_print.
    DESCRIBE TABLE itab2 LINES v_line_size.
    IF v_line_size > 0.
      PERFORM p_header.
      PERFORM p_detail.
      PERFORM p_footer.
    ELSE.
      MESSAGE i000(26) WITH TEXT-010.
      STOP.
    ENDIF.
  ENDIF.
  IF radio5 = 'X'.
    REFRESH: itab2_sfa, itab2.
    PERFORM get_data_report.
    DESCRIBE TABLE itab2 LINES v_line_size.
    IF v_line_size > 0.
      NEW-PAGE LINE-SIZE 235. "203.
      PERFORM r_header.
      PERFORM r_detail.
    ELSE.
      DESCRIBE TABLE itab2_sfa LINES v_line_size.
      IF v_line_size > 0.
        NEW-PAGE LINE-SIZE 235. "203.
        PERFORM r_header.
        PERFORM r_detail.
      ELSE.
        MESSAGE i000(26) WITH TEXT-010.
        STOP.
      ENDIF.
    ENDIF.

  ENDIF.
  IF radio6 = 'X'.
    SET PF-STATUS 'ZF_BI_CHECK'.
    PERFORM get_data.
    DESCRIBE TABLE itab2 LINES v_line_size.
    IF v_line_size > 0.
      PERFORM header.
      PERFORM detail_update.
    ENDIF.
  ENDIF.
  IF radio7 = 'X'.
    PERFORM get_data_reprint_cair.
    DESCRIBE TABLE itab1 LINES v_line_size.
    IF v_line_size > 0.
      PERFORM p_header_tb.
      PERFORM p_detail_tb1.
      PERFORM p_footer.
    ELSE.
      MESSAGE i000(26) WITH TEXT-010.
      STOP.
    ENDIF.
  ENDIF.

  IF radio8 = 'X'.
    PERFORM get_data_reprint_tolak.
    DESCRIBE TABLE itab1 LINES v_line_size.
    IF v_line_size > 0.
      PERFORM p_header_tb.
      PERFORM p_detail_tb1.
      PERFORM p_footer.
    ELSE.
      MESSAGE i000(26) WITH TEXT-010.
      STOP.
    ENDIF.
  ENDIF.

  IF radio9 = 'X'.
    PERFORM get_data_reprint_batal.
    DESCRIBE TABLE itab1 LINES v_line_size.
    IF v_line_size > 0.
      PERFORM p_header_tb.
      PERFORM p_detail_tb1.
      PERFORM p_footer.
    ELSE.
      MESSAGE i000(26) WITH TEXT-010.
      STOP.
    ENDIF.
  ENDIF.

END-OF-SELECTION.

TOP-OF-PAGE.

END-OF-PAGE.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    PERFORM text.
    IF screen-group1 = 'SSB'.
      screen-input = 0.
    ENDIF.

    IF screen-group1 = 'ABC'.
      screen-input = 0.
    ENDIF.

    IF screen-group1 = 'SSD'.
      screen-active = 0.
    ENDIF.
    IF radio7 = 'X' OR radio8 = 'X' OR radio9 = 'X'.
      IF screen-group1 = 'SSD'.
        screen-active = 0.
      ENDIF.
      IF screen-group1 = 'SSA'.
        screen-active = 0.
      ENDIF.
      IF screen-group1 = 'ARS'.
        screen-active = 0.
      ENDIF.

    ENDIF.
*         if radio1 = 'X'.
*            IF SCREEN-GROUP1 = 'SSA'.
*                  SCREEN-INPUT = 0.
*            ENDIF.
*         else.
*            IF SCREEN-GROUP1 = 'SSA'.
*                  SCREEN-INPUT = 1.
*            ENDIF.
*         endif.
    MODIFY SCREEN.

  ENDLOOP.


************************************************************************
* AT LINE-SELECTION.
************************************************************************
AT LINE-SELECTION.
  READ CURRENT LINE FIELD VALUE: itab2-bname,itab2-cekno,itab2-kunnr,
  itab2-duedt.
  DATA : ffield(20), fvalue(20).
  GET CURSOR FIELD ffield VALUE fvalue.
  CASE ffield.
    WHEN 'ITAB2-BNAME'.
      srt = 'BNAME'.
    WHEN 'ITAB2-CEKNO'.
      srt = 'CEKNO'.
    WHEN 'ITAB2-DUEDT'.
      srt = 'DUEDT'.
  ENDCASE.

************************************************************************
* AT USER-COMMAND.
************************************************************************
AT USER-COMMAND.

  CASE sy-ucomm.
    WHEN 'SAVE'.
      SET PF-STATUS 'ZF_BI_CHECK'.

      IF radio1 = 'X'.
        PERFORM read_chbox.

        IF total = total4.
          va_flag = space.
          PERFORM ext_detail.
          totchek = 0.
          cek = '0'.bank = 'A'.dued = sy-datum.
          LOOP AT itab5.
            v_count = 0.amtinv = 0.
            LOOP AT itab1 WHERE  cekno EQ itab5-cekno
                    AND bname EQ itab5-bname AND duedt EQ itab5-duedt
                    AND bbeln EQ itab5-bbeln.

              amtinv = amtinv + itab1-cchek.
** Added by Budi.P Req. by SJT 28/10/2009
*              poskey = '15'.
              IF itab1-cchek < 0.
                poskey = '05'.
              ELSE.
                poskey = '15'.
              ENDIF.
              itab1-cchek = abs( itab1-cchek ).
** End Added by Budi.P Req. by SJT 28/10/2009
              PERFORM gsber.
              IF v_count = 0.
                PERFORM post_header.
              ENDIF.
              IF v_count NE 0.
                PERFORM poskey.
              ENDIF.
              IF itab1-kunnr(2) = 'SL'.
                PERFORM onetime_cust.
              ENDIF.

              PERFORM post_detail.
              v_count = v_count + 1.
            ENDLOOP.
            poskey = '40'.
            itab1-kunnr = hkont.
            PERFORM poskey.
            WRITE amtinv TO cash  CURRENCY 'IDR' .
            pa_bbeln = itab5-bbeln.
            PERFORM save.
          ENDLOOP.

          LOOP AT itab1.
            pa_bbeln =  itab1-bbeln.
            PERFORM open_for-payment.
          ENDLOOP.
          PERFORM update_cair.
          PERFORM p_header_tb.
          PERFORM p_detail_tb.
          PERFORM p_footer.
          PERFORM release_lock.

        ELSE.
          REFRESH itab.

          MESSAGE e000(26) WITH TEXT-024.

        ENDIF.

      ENDIF.

      IF radio2 = 'X'.
        PERFORM read_chbox.
        IF total1 = total4.
          va_flag = 'C'.
          PERFORM ext_detail.
          SORT itab BY cekno bname duedt.

          LOOP AT itab5.
            v_count = 0.amtinv = 0.
            LOOP AT itab1 WHERE cekno EQ itab5-cekno
                     AND bname EQ itab5-bname AND duedt EQ itab5-duedt
                    AND bbeln EQ itab5-bbeln.

              amtinv = amtinv + itab1-cchek.
              PERFORM gsber.
              poskey = '05'.
              IF v_count = 0.
                PERFORM post_header.
              ENDIF.
              IF v_count NE 0.

                PERFORM poskey.
              ENDIF.
              IF itab1-kunnr(2) = 'SL'.
                PERFORM onetime_cust.
              ENDIF.

              PERFORM post_detail.
              v_count = v_count + 1.
              itab1-kunnr = itab1-hkont.
            ENDLOOP.
            poskey = '50'.
            PERFORM poskey.
            WRITE amtinv TO cash  CURRENCY 'IDR' .
            pa_bbeln = itab5-bbeln.
            PERFORM save.
          ENDLOOP.

          PERFORM update_tolak.

          PERFORM p_header_tb.
          PERFORM p_detail_tb.
          PERFORM p_footer.
          PERFORM release_lock.
        ELSE.
          MESSAGE e000(26) WITH TEXT-024.
        ENDIF.
      ENDIF.

      IF radio3 = 'X'.
        PERFORM read_chbox.
        IF total1 = total4.
          PERFORM update_tolak.
          PERFORM p_header_tb.
          PERFORM p_detail_tb1.
          PERFORM p_footer.
          PERFORM release_lock.
        ELSE.
          MESSAGE e000(26) WITH TEXT-024.
        ENDIF.
      ELSEIF radio31 = 'X'.
        PERFORM read_chbox.
        PERFORM update_tolak.
        PERFORM release_lock.
        MESSAGE 'Giro batal Approved' TYPE 'S'.
        LEAVE TO SCREEN 0.
      ENDIF.

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

    WHEN 'BCK'.
      PERFORM release_lock.
      LEAVE TO SCREEN 0.
    WHEN 'EXT'.
      PERFORM release_lock.
      LEAVE TO SCREEN 0.
    WHEN 'BACK'.
      PERFORM release_lock.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      PERFORM release_lock.
      LEAVE TO SCREEN 0.
    WHEN 'PRNT'.
      PERFORM print.
    WHEN 'SORTA'.
      IF srt EQ 'BNAME'.
        SORT itab2 BY bname.
      ELSEIF srt EQ 'CEKNO'.
        SORT itab2 BY cekno.
      ELSEIF srt EQ 'DUEDT'.
        SORT itab2 BY duedt.
      ENDIF.
      IF srt NE space.
        PERFORM header.
        PERFORM detail.
      ENDIF.
    WHEN 'SORTD'.
      IF srt EQ 'BNAME'.
        SORT itab2 BY bname DESCENDING.
      ELSEIF srt EQ 'CEKNO'.
        SORT itab2 BY cekno DESCENDING.
      ELSEIF srt EQ 'DUEDT'.
        SORT itab2 BY duedt DESCENDING.
      ENDIF.
      IF srt NE space.
        PERFORM header.
        PERFORM detail.
      ENDIF.

  ENDCASE.

  CASE sy-xcode.
    WHEN 'PRINT'.
      IF sy-subrc EQ 0.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.
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
ENDFORM.                    "F_DYNPRO

*&---------------------------------------------------------------------*
*&      Form  DELETE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM delete.
  PERFORM f_dynpro USING:
              'X'  'SAPMF05L'	 '0102',
              ' ' 'BDC_CURSOR'   'RF05L-GJAHR',
 	       ' ' 'BDC_OKCODE'	 '/00',
 	       ' ' 'RF05L-BELNR' zfbid-vbeln,
 	       ' ' 'RF05L-BUKRS' pa_bukrs,
 	       ' ' 'RF05L-GJAHR' zfbid-gjahr,
 	       ' ' 'RF05L-BUZEI' zfbid-buzei,
              'X' 'SAPMF05L' 	 '0301',
 	       ' ' 'BDC_CURSOR'	 'BSEG-ZLSPR',
 	       ' ' 'BDC_OKCODE'	 '=AE',
              ' ' 'BSEG-ZLSPR'   ' '.
  CALL TRANSACTION 'FB09' USING i_bdc MODE 'N' UPDATE 'S'
          MESSAGES INTO messtab.
  PERFORM error.
ENDFORM.                    "DELETE

*&---------------------------------------------------------------------*
*&      Form  OPEN_FOR-PAYMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM open_for-payment.
  DATA : BEGIN OF itab9 OCCURS 0,
           belnr LIKE bsid-belnr,
           buzei LIKE bsid-buzei,
           blart LIKE bsid-blart,
         END OF itab9.
  REFRESH itab9.CLEAR itab9.

  SELECT  belnr buzei blart INTO TABLE itab9 FROM bsid
  WHERE bukrs EQ pa_bukrs AND kunnr EQ itab1-kunnr AND
        zuonr EQ itab1-zuonr.
* Tahun
*      and gjahr eq itab1-gjahr.
  LOOP AT itab9.
    CLEAR i_bdc.
    PERFORM f_dynpro USING:
           'X' 'SAPMF05L'	 '0102',
           ' ' 'BDC_CURSOR'	 'RF05L-GJAHR',
         ' ' 'BDC_OKCODE'  '/00',
         ' ' 'RF05L-BELNR' itab9-belnr,
         ' ' 'RF05L-BUKRS' pa_bukrs,
         ' ' 'RF05L-GJAHR' itab1-gjahr,
           ' ' 'RF05L-BUZEI' itab9-buzei,
         ' ' 'RF05L-XKDEB' 'X'.
    IF wa_itab1-kunnr(2) EQ 'SL'.
      PERFORM f_dynpro USING:
          'X' 'SAPLFCPD'   '0100',
          ' ' 'BDC_CURSOR' 'BSEC-SPRAS',
          ' ' 'BDC_OKCODE' '/00'.
    ENDIF.
    PERFORM f_dynpro USING:
           'X' 'SAPMF05L'    '0301',
         ' ' 'BDC_CURSOR'  'BSEG-ZLSPR',
         ' ' 'BDC_OKCODE'  '=AE',
           ' ' 'BSEG-ZLSPR'	 'Z'.
    CALL TRANSACTION 'FB09' USING i_bdc MODE 'N' UPDATE 'S'
            MESSAGES INTO messtab.
    PERFORM error.
  ENDLOOP.
ENDFORM.                    "OPEN_FOR-PAYMENT



*&---------------------------------------------------------------------*
*&      Form  FULL_PAYMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM full_payment.
  CLEAR i_bdc.
  PERFORM f_dynpro USING:
            'X' 'SAPMF05A'   '0103',
            ' ' 'BDC_CURSOR'   'RF05A-XPOS1(06)',
         ' ' 'BDC_OKCODE'  '/00',
         ' ' 'BKPF-BLDAT'  bidat,
         ' ' 'BKPF-BLART'  'DZ',
         ' ' 'BKPF-BUKRS'  pa_bukrs,
         ' ' 'BKPF-BUDAT'  bidat,
            ' ' 'BKPF-MONAT'  monat,
            ' ' 'BKPF-WAERS'  waers,
            ' ' 'BKPF-XBLNR'  vcrn,
            ' ' 'RF05A-KONTO' hkont,
            ' ' 'BSEG-GSBER'  itab1-gsber,
            ' ' 'BSEG-WRBTR'  cash,
            ' ' 'BSEG-VALUT'  ' ',
            ' ' 'BSEG-SGTXT'  txt,
            ' ' 'RF05A-AGKON'  v_custno,
            ' ' 'RF05A-AGKOA' 'D',
            ' ' 'RF05A-XNOPS' 'X',
            ' ' 'RF05A-XPOS1(01)' '',
            ' ' 'RF05A-XPOS1(06)' 'X',
            'X' 'SAPMF05A'    '0608',
            ' ' 'BDC_CURSOR'  'RF05A-XPOS1(07)',
            ' ' 'BDC_OKCODE'   'ENTR',
            ' ' 'RF05S-XPOS1(01)' '',
            ' ' 'RF05S-XPOS1(10)' 'X',
            'X' 'SAPMF05A'    '0731',
            ' ' 'BDC_CURSOR'  'RF05A-SEL01(01)',
            ' ' 'BDC_OKCODE'  '=PA',
            ' ' 'RF05A-SEL01(01)' itab1-zuonr,
            'X' 'SAPDF05X'    '3100',
            ' ' 'BDC_OKCODE'  '=BU',
            ' ' 'BDC_SUBRC'   'SAPDF05X',
            ' ' 'BDC_CURSOR'  'DF05B-PSSKT(01)',
            ' ' 'RF05A-ABPOS' '1'.

  CALL TRANSACTION 'F-28' USING i_bdc MODE 'N' UPDATE 'S'
          MESSAGES INTO messtab.
  PERFORM error.
ENDFORM.                    "FULL_PAYMENT

*&---------------------------------------------------------------------*
*&      Form  PARTIAL_PAYMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM partial_payment.
  CLEAR i_bdc.
  PERFORM f_dynpro USING:
  'X' 'SAPMF05A' '0100',
  ' ' 'BDC_CURSOR' 'RF05A-NEWKO',
  ' ' 'BDC_OKCODE' '/00',
  ' ' 'BKPF-BLDAT' date,
  ' ' 'BKPF-BLART' 'DZ',
  ' ' 'BKPF-BUKRS' pa_bukrs,
  ' ' 'BKPF-BUDAT' date,
  ' ' 'BKPF-MONAT' monat,
  ' ' 'BKPF-WAERS' 'IDR',
  ' ' 'FS006-DOCID' '*',
  ' ' 'RF05A-NEWBS' '40',
  ' ' 'RF05A-NEWKO' hkont,
  'X' 'SAPMF05A' '0300',
  ' ' 'BDC_CURSOR' 'RF05A-NEWKO',
  ' ' 'BDC_OKCODE'  '/00',
  ' ' 'BSEG-WRBTR' cash,
  ' ' 'BSEG-VALUT' date,
  ' ' 'BSEG-SGTXT' txt,
  ' ' 'RF05A-NEWBS' '15',
  ' ' 'RF05A-NEWKO' v_custno,
  ' ' 'BDC_SUBSCR' 'SAPLKACB',
  'X' 'SAPLKACB' '0002',
  ' ' 'BDC_CURSOR' 'COBL-GSBER',
  ' ' 'BDC_OKCODE'  '=ENTE',
  ' ' 'COBL-GSBER' itab1-gsber,
  ' ' 'BDC_SUBSCR' 'SAPLKACB',
  'X' 'SAPMF05A' '0301',
  ' ' 'BDC_CURSOR' 'BSEG-ZUONR',
  ' ' 'BDC_OKCODE'  '=BU',
  ' ' 'BSEG-WRBTR' cash,
  ' ' 'BSEG-MWSKZ' '**',
  ' ' 'BSEG-GSBER' itab1-gsber,
  ' ' 'BSEG-ZFBDT' date,
  ' ' 'BSEG-REBZG' itab1-belnr,
  ' ' 'BSEG-ZUONR' itab1-zuonr,
  ' ' 'BSEG-SGTXT' txt.
  CALL TRANSACTION 'F-21' USING i_bdc MODE bdcmode UPDATE 'S'
               MESSAGES INTO messtab.
  PERFORM error.
ENDFORM.                    "PARTIAL_PAYMENT
*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data.
  CASE 'X'.
    WHEN radio3.
      SELECT cekno bname duedt kunnr SUM( cchek ) AS cchek
        INTO CORRESPONDING FIELDS OF TABLE itab2
          FROM zfbicheck
          WHERE bukrs EQ pa_bukrs AND
          vkbur EQ pa_vkbur AND
          kunnr IN custno   AND
          slcod IN slcode   AND
          duedt LE duedt1   AND
          cekno IN cekno    AND
*                gjahr eq pa_gjahr and
          pcair NOT IN ('T','B','C') AND
          blnck EQ '000000'
         GROUP BY kunnr cekno bname duedt .
    WHEN radio31.
      SELECT cekno bname duedt kunnr blnck SUM( cchek ) AS cchek
        INTO CORRESPONDING FIELDS OF TABLE itab2
          FROM zfbicheck
          WHERE bukrs EQ pa_bukrs AND
          vkbur EQ pa_vkbur AND
          kunnr IN custno   AND
          slcod IN slcode   AND
          duedt LE duedt1   AND
          cekno IN cekno    AND
          pcair EQ space AND
          blnck NE '000000'
         GROUP BY kunnr cekno bname duedt blnck.
    WHEN OTHERS.
      SELECT cekno bname duedt kunnr SUM( cchek ) INTO
          (itab2-cekno, itab2-bname, itab2-duedt, itab2-kunnr,
           itab2-cchek)
          FROM zfbicheck
          WHERE bukrs EQ pa_bukrs AND
          vkbur EQ pa_vkbur AND
          kunnr IN custno   AND
          slcod IN slcode   AND
          duedt LE duedt1   AND
          cekno IN cekno    AND
*                gjahr eq pa_gjahr and
          pcair NOT IN ('T','B','C')
         GROUP BY kunnr cekno bname duedt .
        APPEND itab2.
      ENDSELECT.
  ENDCASE.


ENDFORM.                    " get_data
*&---------------------------------------------------------------------*
*&      Form  header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header.
  IF radio1 = 'X'.
    WRITE :/ 'Amount Chek',total.
    WRITE :/ 'GL Account  ',hkont.
  ELSE.
    IF radio6 <> 'X' AND radio31 <> 'X'.
      WRITE :/ 'Amount Chek',total1.
    ENDIF.
  ENDIF.

  FORMAT COLOR 4.
  IF radio31 = 'X'.
    WRITE : /(118) sy-uline.
    WRITE :/ sy-vline NO-GAP,(10) 'Cust No.',sy-vline NO-GAP,(20)
             'Customer Name',sy-vline NO-GAP,
             (24) 'Bank Name',sy-vline NO-GAP,(12) 'Check No',sy-vline
             NO-GAP,
             (10) 'Due Date',sy-vline NO-GAP,
           (14) 'Check Paid',sy-vline NO-GAP,
            (8) 'No Batal' NO-GAP,sy-vline,
            (4) 'CBox' NO-GAP,sy-vline
  NO-GAP.
    WRITE : /(118) sy-uline.
  ELSE.
    WRITE : /(108) sy-uline.
    WRITE :/ sy-vline NO-GAP,(10) 'Cust No.',sy-vline NO-GAP,(20)
             'Customer Name',sy-vline NO-GAP,
             (24) 'Bank Name',sy-vline NO-GAP,(12) 'Check No',sy-vline
             NO-GAP,
             (10) 'Due Date',sy-vline NO-GAP,
           (14) 'Check Paid',sy-vline NO-GAP,
            (4) 'CBox' NO-GAP,sy-vline
  NO-GAP.
    WRITE : /(108) sy-uline.
  ENDIF.

ENDFORM.                    " header
*&---------------------------------------------------------------------*
*&      Form  detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM detail.
  DATA: l_name1 LIKE kna1-name1.
  v_count = 0.
  LOOP AT itab2.
    IF v_count = 1.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED OFF.
      v_count = 0.
    ELSE.
      FORMAT COLOR 1.
      FORMAT INTENSIFIED OFF.
      v_count = 1.
    ENDIF.
    SELECT SINGLE name1 INTO l_name1 FROM kna1
           WHERE kunnr EQ itab2-kunnr.

    IF radio31 = 'X'.
      WRITE :/ sy-vline NO-GAP,(10) itab2-kunnr,sy-vline NO-GAP,(20)
                l_name1,sy-vline NO-GAP,(24)
               itab2-bname HOTSPOT,sy-vline NO-GAP,(12)
               itab2-cekno HOTSPOT,sy-vline NO-GAP,
               (10) itab2-duedt HOTSPOT,
              sy-vline NO-GAP,(14) itab2-cchek CURRENCY 'IDR',sy-vline
              NO-GAP,(8) itab2-blnck NO-GAP,sy-vline NO-GAP.
      WRITE AT 115 va_mark AS CHECKBOX.
      WRITE AT 118 sy-vline NO-GAP.
    ELSE.
      WRITE :/ sy-vline NO-GAP,(10) itab2-kunnr,sy-vline NO-GAP,(20)
                l_name1,sy-vline NO-GAP,(24)
               itab2-bname HOTSPOT,sy-vline NO-GAP,(12)
               itab2-cekno HOTSPOT,sy-vline NO-GAP,
               (10) itab2-duedt HOTSPOT,
              sy-vline NO-GAP,(14) itab2-cchek CURRENCY 'IDR',sy-vline
              NO-GAP.
      WRITE AT 105 va_mark AS CHECKBOX.
      WRITE AT 108 sy-vline NO-GAP.
    ENDIF.
  ENDLOOP.

  IF radio31 = 'X'.
    WRITE : /(118) sy-uline.
  ELSE.
    WRITE : /(108) sy-uline.
  ENDIF.
ENDFORM.                    " detail


*&---------------------------------------------------------------------*
*&      Form  text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM text.
  SELECT SINGLE txt20 INTO text FROM skat
  WHERE ktopl = 'TSPC' AND spras = 'EN' AND saknr = hkont.
ENDFORM.                    "text
*&---------------------------------------------------------------------*
*&      Form  waers
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM waers.
  SELECT SINGLE waers INTO waers
     FROM zfbih AS a JOIN  zfbid AS b ON a~bukrs EQ b~bukrs AND
                                         a~bbeln EQ b~bbeln
*                                             a~gjahr eq b~gjahr
     WHERE a~bukrs EQ pa_bukrs AND
           a~vkbur EQ pa_vkbur AND
*               a~gjahr eq pa_gjahr and
           b~vbeln EQ itab1-belnr.
ENDFORM.                    " waers
*&---------------------------------------------------------------------*
*&      Form  gsber
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM gsber.
*         clear i_bdc.
  IF pa_bukrs EQ '8020' OR pa_bukrs EQ '8070'.
    SELECT SINGLE vwerk INTO v_gsber FROM knvv
    WHERE kunnr = v_custno AND
          vkorg = pa_bukrs.
*         and vkbur = pa_vkbur.
  ELSE.
    v_gsber = itab1-gsber.
  ENDIF.

  CASE pa_bukrs.
    WHEN '8020'.
      IF itab1-gsber EQ space.
        itab1-gsber = '0200'.
      ENDIF.
    WHEN '8070'.
      IF itab1-gsber EQ space.
        itab1-gsber = '0700'.
      ENDIF.
    WHEN OTHERS.
      IF itab1-gsber EQ space.
        itab1-gsber = '0200'.
      ENDIF.
  ENDCASE.

  WRITE itab1-cchek TO cash  CURRENCY 'IDR' .
  monat = budat+4(2).
  CONCATENATE sy-datum+6(2) sy-datum+4(2)
  sy-datum+0(4) INTO date.
  CONCATENATE budat+6(2) budat+4(2)
  budat+0(4) INTO bidat.
  CONCATENATE itab1-zfbdt+6(2) itab1-zfbdt+4(2) itab1-zfbdt(4)
  INTO bldat.
  IF radio2 = 'X'.
    SELECT MAX( blnck ) INTO tolak FROM zfbicheck
           WHERE pcair EQ 'T'.
    gt = tolak + 1.
    CONCATENATE 'GT No. ' gt 'untuk Cek No.' itab1-cekno
                itab1-bname INTO txt SEPARATED BY space.
  ELSE.
    CONCATENATE 'Pembayaran Cek No.' itab1-cekno itab1-bname
                INTO txt SEPARATED BY space.
  ENDIF.

  IF radio1 = 'X'.
    itab1-xblnr = vcrn.
  ENDIF.
ENDFORM.                    " gsber
*&---------------------------------------------------------------------*
*&      Form  read_chbox
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_chbox.
  REFRESH :  itab.
  DATA va_belnr LIKE bsid-belnr.
  DATA n TYPE int1.

  IF radio31 = 'X'.
    n = 114.
  ELSE.
    n = 104.
  ENDIF.

  LOOP AT %_list INTO va_list.
*    IF va_list-line+104(1) = 'X'.
    IF va_list-line+n(1) = 'X'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = va_list-line+1(10)
        IMPORTING
          output = v_custno.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = va_list-line+35(24)
        IMPORTING
          output = bname.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = va_list-line+61(12)
        IMPORTING
          output = v_cekno.

      READ TABLE itab2
      WITH KEY  kunnr = v_custno cekno = v_cekno bname = bname .
      IF sy-subrc EQ 0.
        PERFORM cek_lock.
        IF radio1 EQ 'X'.
          IF itab2-duedt > sy-datum.
            MESSAGE e000(26) WITH TEXT-050.
          ELSE.
            APPEND itab2 TO itab.
          ENDIF.
        ELSE.
          APPEND itab2 TO itab.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  total4 = 0.
  LOOP AT itab.
    total4 = total4 + itab-cchek.
  ENDLOOP.
  total4 = total4 * 100.

ENDFORM.                    " read_chbox
*&---------------------------------------------------------------------*
*&      Form  update_tolak
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_tolak.
  IF radio3 = 'X'.
    LOOP AT itab.
      SELECT * INTO CORRESPONDING FIELDS OF itab1 FROM zfbicheck
          WHERE kunnr = itab-kunnr AND
                cekno = itab-cekno AND
                bname = itab-bname AND
                duedt = itab-duedt AND
                pcair = space.
        APPEND itab1.
      ENDSELECT.
    ENDLOOP.
  ENDIF.

  IF radio2 = 'X'.
    READ TABLE itab5 WITH KEY error = space.
    IF sy-subrc EQ 0.
      SELECT MAX( blnck ) INTO tolak FROM zfbicheck
      WHERE pcair EQ 'T' AND bukrs EQ itab1-bukrs AND vkbur EQ
             itab1-vkbur. "and gjahr eq itab1-gjahr.
      IF sy-subrc EQ 0.
        ADD 1 TO tolak.
      ELSE.
        tolak = 1.
      ENDIF.
    ENDIF.
  ENDIF.

  IF radio3 = 'X'.
    SELECT MAX( blnck ) INTO tolak FROM zfbicheck
    WHERE ( pcair EQ 'B' OR pcair EQ ' ' ) AND bukrs EQ itab1-bukrs AND vkbur EQ
          itab1-vkbur. "and gjahr eq itab1-gjahr.
    IF sy-subrc EQ 0.
      ADD 1 TO tolak.
    ELSE.
      tolak = 1.
    ENDIF.
  ENDIF.

  IF radio31 = 'X'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE itab1
      FROM zfbicheck FOR ALL ENTRIES IN itab
        WHERE kunnr = itab-kunnr AND
              cekno = itab-cekno AND
              bname = itab-bname AND
              duedt = itab-duedt AND
              blnck = itab-blnck AND
              pcair = space.
  ENDIF.

  IF radio3 = 'X' OR radio31 = 'X'.
    LOOP AT itab1.
      CONCATENATE 'Pembayaran Cek No.' itab1-cekno itab1-bname
      INTO txt SEPARATED BY space.
      item = itab1-buzei.
      pa_bbeln = itab1-bbeln.

      IF radio31 = 'X'.
        tolak = itab1-blnck.
        PERFORM open_for-payment.
        UPDATE zfbicheck
             SET pcair = 'B' blnck = tolak usna2 = sy-uname erdt2 = sy-datum
             WHERE bukrs EQ itab1-bukrs AND vkbur EQ itab1-vkbur
             AND gjahr EQ itab1-gjahr AND cekno EQ itab1-cekno
             AND belnr EQ itab1-belnr AND bname EQ itab1-bname.
      ELSE.
        UPDATE zfbicheck
*           SET pcair = 'B' blnck = tolak usna2 = sy-uname erdt2 = sy-datum
             SET blnck = tolak usna2 = sy-uname erdt2 = sy-datum
             WHERE bukrs EQ itab1-bukrs AND vkbur EQ itab1-vkbur
             AND gjahr EQ itab1-gjahr AND cekno EQ itab1-cekno
             AND belnr EQ itab1-belnr AND bname EQ itab1-bname.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF radio2 = 'X'.
    LOOP AT itab5 WHERE error EQ space.
      LOOP AT itab1 WHERE  cekno EQ itab5-cekno
            AND bname EQ itab5-bname AND duedt EQ itab5-duedt
            AND bbeln EQ itab5-bbeln..
        UPDATE zfbicheck
             SET pcair = 'T' blnck = tolak usna2 = sy-uname erdt2 = sy-datum
             WHERE bukrs EQ itab1-bukrs AND vkbur EQ itab1-vkbur
             AND gjahr EQ itab1-gjahr AND kunnr EQ itab1-kunnr
             AND cekno EQ itab1-cekno
             AND belnr EQ itab1-belnr AND bname EQ itab1-bname.
      ENDLOOP.
    ENDLOOP.
  ENDIF.


ENDFORM.                    " update_tolak
*&---------------------------------------------------------------------*
*&      Form  ext_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ext_detail.
  DATA no LIKE zfbicheck-bbeln.

  REFRESH itab1.REFRESH itab5.
  LOOP AT itab.
    SELECT *
*          single bbeln into no
    APPENDING  CORRESPONDING FIELDS OF TABLE itab5
    FROM zfbicheck
    WHERE kunnr = itab-kunnr AND
        cekno = itab-cekno AND
        bname = itab-bname AND
        duedt = itab-duedt AND
        pcair = va_flag.
*           if sy-subrc eq 0.
*              itab5-bbeln = no.
*              itab5-cekno = itab-cekno.
*              itab5-bname = itab-bname.
*              itab5-duedt = itab-duedt.
*              append itab5.
*           endif.
  ENDLOOP.
  SORT itab5 BY bbeln cekno bname duedt.
  DELETE ADJACENT DUPLICATES FROM itab5.
  LOOP AT itab5.
    SELECT * INTO CORRESPONDING FIELDS OF itab1 FROM zfbicheck
        WHERE bbeln = itab5-bbeln AND
        cekno = itab5-cekno AND
        bname = itab5-bname AND
        duedt = itab5-duedt.
      SELECT SINGLE parvw INTO itab1-parvw FROM zfbid
      WHERE bukrs EQ itab1-bukrs AND vkbur EQ itab1-vkbur AND
* Tahun
*                gjahr eq itab1-gjahr and
            bbeln EQ itab1-bbeln AND
            zuonr EQ itab1-zuonr.
      APPEND itab1.
    ENDSELECT.
  ENDLOOP.

ENDFORM.                    " ext_detail
*&---------------------------------------------------------------------*
*&      Form  get_data_print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_print.
  SELECT * INTO TABLE itab2 FROM zfbicheck
      WHERE bukrs EQ pa_bukrs AND
            vkbur EQ pa_vkbur AND
            kunnr IN custno   AND
            slcod IN slcode   AND
            duedt EQ duedt1   AND
            cekno IN cekno    AND
*               gjahr eq pa_gjahr and
            pcair NOT IN ('T','B','C').

ENDFORM.                    " get_data_print
*&---------------------------------------------------------------------*
*&      Form  update_cair
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_cair.
  READ TABLE itab5 WITH KEY error = space.
  IF sy-subrc EQ 0.
    SELECT MAX( ncair ) INTO tolak FROM zfbicheck
        WHERE pcair EQ 'C' AND bukrs EQ itab1-bukrs AND vkbur EQ
              itab1-vkbur. "and gjahr eq itab1-gjahr.
    IF sy-subrc EQ 0.
      ADD 1 TO tolak.
    ELSE.
      tolak = 1.
    ENDIF.
  ENDIF.
  LOOP AT itab5 WHERE error EQ space.
    LOOP AT itab1 WHERE  cekno EQ itab5-cekno
             AND bname EQ itab5-bname AND duedt EQ itab5-duedt
             AND bbeln EQ itab5-bbeln..
      UPDATE zfbicheck
             SET pcair = 'C' xblnr = vcrn ncair = tolak
             hkont = hkont usna2 = sy-uname erdt2 = budat
             WHERE bukrs EQ pa_bukrs AND vkbur EQ pa_vkbur
             AND gjahr EQ itab1-gjahr AND kunnr EQ itab1-kunnr
             AND duedt EQ itab1-duedt AND bbeln EQ itab1-bbeln
             AND cekno EQ itab1-cekno AND bname EQ itab1-bname.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " update_cair
*&---------------------------------------------------------------------*
*&      Form  p_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p_header.
  DATA: l_vtext LIKE tvst-adrnr,
        street  LIKE adrc-street,
        city1   LIKE adrc-city1.

  SELECT SINGLE adrnr FROM tvst INTO l_vtext
  WHERE vstel = pa_vkbur.
  IF sy-subrc EQ 0.
    CLEAR: street,  city1.
    SELECT SINGLE street city1 FROM adrc
      INTO (street, city1)
      WHERE addrnumber = l_vtext.
  ENDIF.
  WRITE :/(136) 'DAFTAR GIRO JATUH TEMPO' CENTERED.
  WRITE AT /52 'Tgl Jatuh Tempo :'.
  WRITE AT 70 duedt1 CENTERED.

  IF pa_bukrs EQ '8020'.
    WRITE: / 'PT. TEMPO' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8030'.
    WRITE: / 'PT. EURINDO COMBINE' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8070'.
    WRITE: / 'PT. SUT' INTENSIFIED OFF.
  ENDIF.

  WRITE:/  street.
  WRITE :/ city1.
  WRITE :/ 'Cetak : ',sy-datum,sy-uzeit.
  FORMAT COLOR 4.
  FORMAT INTENSIFIED OFF.
  WRITE : /(136) sy-uline.
  WRITE :/ sy-vline NO-GAP,(3) 'N0.',sy-vline NO-GAP,(20) 'NAMA BANK',
           sy-vline NO-GAP,(12) 'NO. CHECK',sy-vline NO-GAP,
          (10) 'J. TEMPO',sy-vline NO-GAP,(18) 'NO. FAKTUR',sy-vline
          NO-GAP,(10) 'TGL FAKTUR',sy-vline NO-GAP,(10) 'KODE OUTLET',
          sy-vline NO-GAP,(20) 'NAMA OUTLET',sy-vline NO-GAP,(14)
          'NILAi (Rp.)',sy-vline NO-GAP.
  WRITE : /(136) sy-uline.
ENDFORM.                    " p_header
*&---------------------------------------------------------------------*
*&      Form  p_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p_detail.
  DATA: l_name1 LIKE kna1-name1.

  v_count = 1.tot1 = 0.va_nou = 0.
  LOOP AT itab2.
    IF va_nou = 1.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED OFF.
      va_nou = 0.
    ELSE.
      FORMAT COLOR 1.
      FORMAT INTENSIFIED OFF.
      va_nou = 1.
    ENDIF.

    WRITE :/ sy-vline NO-GAP,(3) v_count,sy-vline NO-GAP,(20)
             itab2-bname,sy-vline NO-GAP,(12) itab2-cekno,sy-vline
           NO-GAP,(10) itab2-duedt,sy-vline NO-GAP,(18) itab2-zuonr,
             sy-vline NO-GAP.
    SELECT SINGLE * FROM zfbid
    WHERE bukrs EQ itab2-bukrs AND vkbur EQ itab2-vkbur
          AND vbeln EQ itab2-belnr.
    SELECT SINGLE name1 INTO l_name1 FROM kna1
    WHERE kunnr EQ itab2-kunnr.
    WRITE : (10) zfbid-fkdat,sy-vline NO-GAP,itab2-kunnr,sy-vline
            NO-GAP,(20) l_name1,sy-vline NO-GAP,(14) itab2-cchek
            CURRENCY 'IDR',sy-vline NO-GAP.
    v_count = v_count + 1.
    tot1 = tot1 + itab2-cchek.
  ENDLOOP.
  FORMAT COLOR OFF.
  WRITE : /(136) sy-uline.
  WRITE AT  /107(10) 'TOTAL'.
  WRITE AT 120 sy-vline NO-GAP.
  WRITE AT 121(14) tot1 CURRENCY 'IDR'.
  WRITE AT 136 sy-vline NO-GAP.
  WRITE AT /120(17) sy-uline.

ENDFORM.                    " p_detail
*&---------------------------------------------------------------------*
*&      Form  p_footer
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p_footer.
  PERFORM jumlah.
  FORMAT COLOR OFF.
  WRITE /1(11) 'Terbilang : '.
  WRITE AT 13 jumlah.
  SKIP 1.
  WRITE AT /1(20) 'Seksi Inkaso'.
  WRITE AT 50(20) 'Kep. Keuangan'.
  WRITE AT 80(20) 'Kasir' CENTERED NO-GAP.
  SKIP 2.
  WRITE AT /1(20) '(...........)'.
  WRITE AT 50(20) '(...........)'.
  WRITE AT 80(20) '(...........)' CENTERED NO-GAP.
  SKIP 1.
  WRITE : / 'Printed By'.
  WRITE AT 12(20) sy-uname.
  IF radio7 = 'X' OR radio8 = 'X' OR radio9 = 'X'.
    WRITE AT 32(4) 'EX'.
  ENDIF.
ENDFORM.                    " p_footer
*&---------------------------------------------------------------------*
*&      Form  jumlah
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM jumlah.
  CALL FUNCTION 'SPELL_AMOUNT '
    EXPORTING
      amount                = tot1
      currency              = 'IDR'
      language              = 'i'
    IMPORTING
      in_words              = text1
    EXCEPTIONS
      records_not_found     = 1
      records_not_requested = 2
      OTHERS                = 3.
  CONCATENATE text1-word 'RUPIAH' INTO jumlah SEPARATED BY space.

ENDFORM.                    " jumlah
*&---------------------------------------------------------------------*
*&      Form  get_data_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_report.
*               gjahr eq pa_gjahr.
  SELECT * INTO TABLE itab2 FROM zfbicheck
        WHERE bukrs EQ pa_bukrs AND
              vkbur EQ pa_vkbur AND
              kunnr IN custno   AND
              slcod IN slcode   AND
              duedt <= duedt1   AND
              cekno IN cekno.    "and

  SELECT * INTO CORRESPONDING FIELDS OF TABLE itab2_sfa FROM zfbic_sfa
        WHERE bukrs EQ pa_bukrs AND
              vkbur EQ pa_vkbur AND
              kunnr IN custno   AND
              slscd IN slcode   AND
*              dudat <= duedt1   AND
              bank_dudat <= duedt1   AND
              bank_check IN b_check.    "and

ENDFORM.                    " get_data_report
*&---------------------------------------------------------------------*
*&      Form  r_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM r_header.
  DATA: l_vtext LIKE tvst-adrnr,
        street  LIKE adrc-street,
        city1   LIKE adrc-city1.

  SELECT SINGLE adrnr FROM tvst INTO l_vtext
  WHERE vstel = pa_vkbur.
  IF sy-subrc EQ 0.
    CLEAR: street,  city1.
    SELECT SINGLE street city1 FROM adrc
      INTO (street, city1)
      WHERE addrnumber = l_vtext.
  ENDIF.
  WRITE :/(198) 'DAFTAR GIRO TERBUKA' CENTERED.
  IF pa_bukrs EQ '8020'.
    WRITE: / 'PT. TEMPO' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8030'.
    WRITE: / 'PT. EURINDO COMBINE' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8070'.
    WRITE: / 'PT. SUT' INTENSIFIED OFF.
  ENDIF.

  WRITE:/  street.
  WRITE :/ city1.
  WRITE :/ 'Prepared by : ',sy-uname.
  WRITE :/ 'Cetak : ',sy-datum,sy-uzeit.
  FORMAT COLOR 4.
  FORMAT INTENSIFIED OFF.
  WRITE : /(233) sy-uline.
  WRITE :/ sy-vline NO-GAP,(3) 'N0.',sy-vline NO-GAP,(10) 'TGL ENTRY',
            sy-vline NO-GAP,(10) 'TGL BI',sy-vline NO-GAP,(14)
            'NO. VOUCHER',sy-vline NO-GAP,(10) 'KODE OUTLET',sy-vline
             NO-GAP,(20) 'NAMA OUTLET',sy-vline NO-GAP,(10)
             'NO. DO',sy-vline NO-GAP,(10) 'TGL FAKTUR',sy-vline
             NO-GAP, (20) 'NAMA BANK', sy-vline NO-GAP,(12) 'NO. CHECK'
             ,sy-vline NO-GAP, (14) 'NILAi (Rp.)',sy-vline NO-GAP,
             (14) 'GIRO CAIR' NO-GAP,sy-vline NO-GAP,(14) 'SALDO'
             NO-GAP,sy-vline NO-GAP,
             (14) 'SALDO AR' NO-GAP,sy-vline NO-GAP,
             (14) 'NILAI FAKTUR' NO-GAP,sy-vline NO-GAP,
             (10) 'J. TEMPO',sy-vline NO-GAP,(3) 'SFA',sy-vline NO-GAP.
  WRITE : /(233) sy-uline.

ENDFORM.                    " r_header
*&---------------------------------------------------------------------*
*&      Form  r_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM r_detail.
  DATA: l_name1  LIKE kna1-name1,
        tgl_bi   LIKE sy-datum,
        tgl_fak  LIKE sy-datum,
        stat(14).

  LOOP AT itab2.
    IF itab2-pcair NE space AND itab2-erdt2 NE duedt1.
      DELETE itab2.
    ELSE.
      SELECT SINGLE erdt1 fkdat INTO (itab2-tgl_bi, itab2-tgl_fak)
       FROM zfbid
        WHERE bukrs EQ itab2-bukrs AND vkbur EQ itab2-vkbur
        AND vbeln EQ itab2-belnr AND bbeln EQ itab2-bbeln.
      IF sy-subrc NE 0.
        itab2-tgl_fak = itab2-budat.
      ENDIF.
      MODIFY itab2.
    ENDIF.
  ENDLOOP.

* Begin - Get data Saldo AR & Nilai Faktur
  DATA(lr_kunnr) = VALUE rseloption( FOR wa_itab2 IN itab2
                   ( sign = 'I' option = 'EQ' low = wa_itab2-kunnr ) ).
  DATA(lr_zuonr) = VALUE rseloption( FOR wa_itab2 IN itab2
                   ( sign = 'I' option = 'EQ' low = wa_itab2-zuonr ) ).
  DATA(lr_kunnr2) = VALUE rseloption( FOR wa_itab2_sfa IN itab2_sfa
                   ( sign = 'I' option = 'EQ' low = wa_itab2_sfa-kunnr ) ).
  DATA(lr_zuonr2) = VALUE rseloption( FOR wa_itab2_sfa IN itab2_sfa
                   ( sign = 'I' option = 'EQ' low = wa_itab2_sfa-zuonr ) ).
  SORT: lr_kunnr BY low, lr_kunnr2 BY low.
  DELETE ADJACENT DUPLICATES FROM: lr_kunnr COMPARING low,
                                   lr_kunnr2 COMPARING low.

  SELECT kunnr AS kunnr, zuonr AS zuonr, blart AS blart, waers AS waers,
    CASE
      WHEN shkzg = 'H' THEN wrbtr * -1
      ELSE wrbtr * 1
    END AS wrbtr
    FROM bsid INTO TABLE @DATA(lt_bsid)
    WHERE bukrs = @pa_bukrs
      AND kunnr IN @lr_kunnr
      AND zuonr IN @lr_zuonr.
  IF lr_kunnr2[]  IS NOT INITIAL.
    SELECT kunnr AS kunnr, zuonr AS zuonr, blart AS blart, waers AS waers,
    CASE
      WHEN shkzg = 'H' THEN wrbtr * -1
      ELSE wrbtr * 1
    END AS wrbtr
    FROM bsid APPENDING TABLE @lt_bsid
    WHERE bukrs = @pa_bukrs
      AND kunnr IN @lr_kunnr2
      AND zuonr IN @lr_zuonr2.
  ENDIF.

  SELECT kunnr AS kunnr, zuonr AS zuonr, blart AS blart, waers AS waers,
    CASE
      WHEN shkzg = 'H' THEN wrbtr * -1
      ELSE wrbtr * 1
    END AS wrbtr
    FROM bsad INTO TABLE @DATA(lt_bsad)
    WHERE bukrs = @pa_bukrs
      AND kunnr IN @lr_kunnr
      AND zuonr IN @lr_zuonr.
  IF lr_kunnr2[]  IS NOT INITIAL.
    SELECT kunnr AS kunnr, zuonr AS zuonr, blart AS blart, waers AS waers,
    CASE
      WHEN shkzg = 'H' THEN wrbtr * -1
      ELSE wrbtr * 1
    END AS wrbtr
    FROM bsad APPENDING TABLE @lt_bsad
    WHERE bukrs = @pa_bukrs
      AND kunnr IN @lr_kunnr2
      AND zuonr IN @lr_zuonr2.
  ENDIF.
* Ending - Get data Saldo AR & Nilai Faktur

  v_count = 1.tot1 = 0.va_nou = 0.tcair = 0.saldo = 0.tsaldo = 0.
  tsaldo_ar = 0.tfaktur = 0.
  tbatal1 = 0.
  SORT itab2 BY duedt kunnr bname cekno.
  LOOP AT itab2.

    SELECT SINGLE name1 INTO l_name1 FROM kna1
           WHERE kunnr EQ itab2-kunnr.
    saldo = itab2-cchek.
    IF va_nou = 1.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED OFF.
      va_nou = 0.
    ELSE.
      FORMAT COLOR 1.
      FORMAT INTENSIFIED OFF.
      va_nou = 1.
    ENDIF.
    stat = space.
    IF itab2-pcair = 'B'.
      stat = 'Batal'.
      tbatal1 = tbatal1 + itab2-cchek.
      saldo = 0.
    ENDIF.

    IF itab2-pcair = 'C'.
      WRITE itab2-cchek TO stat CURRENCY 'IDR'.
      tcair = tcair + itab2-cchek.
      saldo = 0.
    ENDIF.

    IF itab2-pcair = 'T'.
      stat = 'Tolak'.
      saldo = 0.
    ENDIF.

* Begin - Get data Saldo AR & Nilai Faktur
    DATA(lv_saldo_ar) = REDUCE wrbtr( INIT i TYPE wrbtr FOR wa_bsid IN lt_bsid
                                      WHERE ( kunnr = itab2-kunnr AND
                                              zuonr = itab2-zuonr )
                                      NEXT i = i + wa_bsid-wrbtr ).
    DATA(lv_faktur)   = REDUCE wrbtr( INIT i TYPE wrbtr FOR wa_bsid IN lt_bsid
                                      WHERE ( kunnr = itab2-kunnr AND
                                              zuonr = itab2-zuonr AND
                                              blart = 'RV' )
                                      NEXT i = i + wa_bsid-wrbtr ).
    DATA(lv_saldo_ar2) = REDUCE wrbtr( INIT i TYPE wrbtr FOR wa_bsad IN lt_bsad
                                       WHERE ( kunnr = itab2-kunnr AND
                                               zuonr = itab2-zuonr )
                                       NEXT i = i + wa_bsad-wrbtr ).
    DATA(lv_faktur2)   = REDUCE wrbtr( INIT i TYPE wrbtr FOR wa_bsad IN lt_bsad
                                       WHERE ( kunnr = itab2-kunnr AND
                                               zuonr = itab2-zuonr AND
                                               blart = 'RV' )
                                       NEXT i = i + wa_bsad-wrbtr ).
    ADD: lv_saldo_ar2 TO lv_saldo_ar,
         lv_faktur2 TO lv_faktur.
* Ending - Get data Saldo AR & Nilai Faktur

    WRITE :/ sy-vline NO-GAP,(3) v_count,sy-vline NO-GAP,(10)
             itab2-tgl_bi, sy-vline NO-GAP,(10) itab2-tgl_bi,
             sy-vline
             NO-GAP,(14) itab2-xblnr,sy-vline NO-GAP,itab2-kunnr,
             sy-vline NO-GAP,(20) l_name1,sy-vline NO-GAP,(10)
             itab2-zuonr, sy-vline NO-GAP,(10) itab2-tgl_fak,
             sy-vline
             NO-GAP,(20) itab2-bname,sy-vline NO-GAP,(12)
             itab2-cekno,sy-vline NO-GAP,(14) itab2-cchek
             CURRENCY 'IDR',sy-vline NO-GAP,(14) stat CENTERED
            NO-GAP,sy-vline NO-GAP,(14) saldo CURRENCY 'IDR' NO-GAP,
            sy-vline NO-GAP,(14) lv_saldo_ar CURRENCY 'IDR' NO-GAP,
            sy-vline NO-GAP,(14) lv_faktur CURRENCY 'IDR' NO-GAP,
            sy-vline NO-GAP,(10) itab2-duedt,sy-vline NO-GAP,
            (3) itab2-sfa,sy-vline NO-GAP.
    v_count = v_count + 1.
    tot1 = tot1 + itab2-cchek.
    tsaldo = tsaldo + saldo.
    ADD: lv_saldo_ar  TO tsaldo_ar,
         lv_faktur    TO tfaktur.
  ENDLOOP.

  LOOP AT itab2_sfa.
    itab2_sfa-sfa = 'X'.
    saldo = itab2_sfa-bank_amt.
    IF va_nou = 1.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED OFF.
      va_nou = 0.
    ELSE.
      FORMAT COLOR 1.
      FORMAT INTENSIFIED OFF.
      va_nou = 1.
    ENDIF.

    SELECT SINGLE name1 INTO l_name1 FROM kna1
           WHERE kunnr EQ itab2_sfa-kunnr.

    SELECT SINGLE erdat_post bidat
      INTO (itab2_sfa-erdt2, itab2_sfa-tgl_bi)
      FROM zfbih_sfa
      WHERE bukrs EQ itab2_sfa-bukrs
        AND vkbur EQ itab2_sfa-vkbur
        AND bbeln EQ itab2_sfa-bbeln.

*ZFBDT
    SELECT SINGLE zfbdt INTO itab2_sfa-tgl_fak FROM zfbid_sfa
         WHERE bukrs EQ itab2_sfa-bukrs
           AND vkbur EQ itab2_sfa-vkbur
           AND bbeln EQ itab2_sfa-bbeln
           AND vbeln EQ itab2_sfa-vbeln.
    IF sy-subrc NE 0.
      itab2_sfa-tgl_fak = itab2_sfa-dndat.
    ENDIF.
*    itab2_sfa-erdt2 = itab2_sfa-tgl_bi.
    stat = space.
    IF itab2_sfa-erdt2 IS INITIAL.
      CONTINUE.
    ENDIF.

    IF itab2_sfa-pcair NE space AND
       itab2_sfa-bank_dudat(6) NE duedt1(6).
      CONTINUE.
    ENDIF.

*    IF itab2_sfa-pcair = space and itab2_sfa-erdt2 NE duedt1..
*      CONTINUE.
    IF  itab2_sfa-pcair = 'B'.
      stat = 'Batal'.
      tbatal1 = tbatal1 + itab2_sfa-bank_amt.
      saldo = 0.
    ELSEIF  itab2_sfa-pcair = 'C'.
      WRITE itab2_sfa-bank_amt TO stat CURRENCY 'IDR'.
      tcair = tcair + itab2_sfa-bank_amt.
      saldo = 0.
    ENDIF.

* Begin - Get data Saldo AR & Nilai Faktur
    CLEAR: lv_saldo_ar,lv_faktur.
    lv_saldo_ar = REDUCE wrbtr( INIT i TYPE wrbtr FOR wa_bsid IN lt_bsid
                                WHERE ( kunnr = itab2_sfa-kunnr AND
                                        zuonr = itab2_sfa-zuonr )
                                NEXT i = i + wa_bsid-wrbtr ).
    lv_faktur   = REDUCE wrbtr( INIT i TYPE wrbtr FOR wa_bsid IN lt_bsid
                                WHERE ( kunnr = itab2_sfa-kunnr AND
                                        zuonr = itab2_sfa-zuonr AND
                                        blart = 'RV' )
                                NEXT i = i + wa_bsid-wrbtr ).
    lv_saldo_ar2 = REDUCE wrbtr( INIT i TYPE wrbtr FOR wa_bsad IN lt_bsad
                                 WHERE ( kunnr = itab2_sfa-kunnr AND
                                         zuonr = itab2_sfa-zuonr )
                                 NEXT i = i + wa_bsad-wrbtr ).
    lv_faktur2   = REDUCE wrbtr( INIT i TYPE wrbtr FOR wa_bsad IN lt_bsad
                                 WHERE ( kunnr = itab2_sfa-kunnr AND
                                         zuonr = itab2_sfa-zuonr AND
                                         blart = 'RV' )
                                 NEXT i = i + wa_bsad-wrbtr ).
* Ending - Get data Saldo AR & Nilai Faktur

    WRITE :/ sy-vline NO-GAP,(3) v_count,sy-vline NO-GAP,(10)
             itab2_sfa-erdt2, sy-vline NO-GAP,(10) itab2_sfa-tgl_bi,
             sy-vline
             NO-GAP,(14) itab2_sfa-vchr_br,sy-vline NO-GAP,itab2_sfa-kunnr,
             sy-vline NO-GAP,(20) l_name1,sy-vline NO-GAP,(10)
             itab2_sfa-zuonr, sy-vline NO-GAP,(10) itab2_sfa-tgl_fak, "itab2_sfa-dndat,
             sy-vline
             NO-GAP,(20) itab2_sfa-bank_name,sy-vline NO-GAP,(12)
             itab2_sfa-bank_check,sy-vline NO-GAP,(14) itab2_sfa-bank_amt
             CURRENCY 'IDR',sy-vline NO-GAP,(14) stat CENTERED
            NO-GAP,sy-vline NO-GAP,(14) saldo CURRENCY 'IDR' NO-GAP,
            sy-vline NO-GAP,(14) lv_saldo_ar CURRENCY 'IDR' NO-GAP,
            sy-vline NO-GAP,(14) lv_faktur CURRENCY 'IDR' NO-GAP,
            sy-vline NO-GAP,(10) itab2_sfa-bank_dudat,sy-vline NO-GAP,
            (3) itab2_sfa-sfa CENTERED,sy-vline NO-GAP.
    v_count = v_count + 1.
    tot1 = tot1 + itab2_sfa-bank_amt.
    tsaldo = tsaldo + saldo.
    ADD: lv_saldo_ar TO tsaldo_ar,
         lv_faktur   TO tfaktur.

  ENDLOOP.
  FORMAT COLOR OFF.
  WRITE : /(233) sy-uline.
  IF tbatal1 <> 0.
    WRITE AT /30 'TOTAL BATAL '.
    WRITE AT 45(14) tbatal1 CURRENCY 'IDR'.
    WRITE AT  130(10) 'TOTAL'.
  ELSE.
    WRITE AT /130(10) 'TOTAL'.
  ENDIF.
  WRITE AT 140 sy-vline NO-GAP.
  WRITE AT 141(14) tot1 CURRENCY 'IDR'.
  WRITE AT 156 sy-vline NO-GAP.
  WRITE AT 157(14) tcair CURRENCY 'IDR'.
  WRITE AT 171 sy-vline NO-GAP.
  WRITE AT 172(14) tsaldo CURRENCY 'IDR'.
  WRITE AT 186 sy-vline NO-GAP.
*  WRITE AT 187(14) tsaldo_ar CURRENCY 'IDR'.
*  WRITE AT 201 sy-vline NO-GAP.
*  WRITE AT 202(14) tfaktur CURRENCY 'IDR'.
*  WRITE AT 216 sy-vline NO-GAP.
*  WRITE AT /140(77) sy-uline.
  WRITE AT /140(47) sy-uline.

ENDFORM.                    " r_detail
*&---------------------------------------------------------------------*
*&      Form  p_header_tb
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p_header_tb.
  DATA: ld_datum LIKE sy-datum.

  IF radio7 EQ space AND radio8 EQ space AND radio9 EQ space.
    SET PF-STATUS 'ZF_BI_PRINT'.
  ENDIF.

  DATA: l_vtext LIKE tvst-adrnr,
        street  LIKE adrc-street,
        city1   LIKE adrc-city1.

  SELECT SINGLE adrnr FROM tvst INTO l_vtext
  WHERE vstel = pa_vkbur.
  IF sy-subrc EQ 0.
    CLEAR: street,  city1.
    SELECT SINGLE street city1 FROM adrc
      INTO (street, city1)
      WHERE addrnumber = l_vtext.
  ENDIF.
  IF radio3 = 'X' OR radio9 = 'X'.
    WRITE /100(28) 'BUKTI PEMBATALAN GIRO'.
    WRITE AT /100 'No. P/G :'.
    IF radio3 = 'X' OR radio31 = 'X'.
      WRITE AT 110 tolak CENTERED.
    ELSE.
      WRITE AT 110 pa_blchk CENTERED.
    ENDIF.

  ENDIF.

  IF radio1 = 'X' OR radio7 = 'X'.
    WRITE /100(28) 'BUKTI GIRO CAIR'.
    WRITE AT /100 'No. Cair :'.
    IF radio7 NE 'X'.
      WRITE AT 110 tolak CENTERED.
    ELSE.
      WRITE AT 110 pa_blchk CENTERED.
    ENDIF.
  ENDIF.

  IF radio2 = 'X' OR radio8 = 'X'.
    WRITE /100(28) 'BUKTI GIRO TOLAKAN'.
    WRITE AT /100 'No. G/T :'.
    IF radio2 = 'X'.
      WRITE AT 110 tolak CENTERED.
    ELSE.
      WRITE AT 110 pa_blchk CENTERED.
    ENDIF.
  ENDIF.


  WRITE AT /100 'Tanggal :'.
  CASE 'X'.
    WHEN radio1.
      WRITE AT 110 budat.
    WHEN radio7.
      SELECT SINGLE erdt2
        FROM zfbicheck
        INTO ld_datum
        WHERE bukrs EQ pa_bukrs AND
              vkbur EQ pa_vkbur AND
              ncair EQ pa_blchk.
      IF sy-subrc EQ 0.
        WRITE AT 110 ld_datum.
      ELSE.
        WRITE AT 110 sy-datum.
      ENDIF.
    WHEN OTHERS.
      WRITE AT 110 sy-datum.
  ENDCASE.

  IF pa_bukrs EQ '8020'.
    WRITE: / 'PT. TEMPO' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8030'.
    WRITE: / 'PT. EURINDO COMBINED' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8070'.
    WRITE: / 'PT. SUT' INTENSIFIED OFF.
  ENDIF.

  WRITE:/  street.
  WRITE :/ city1.
  WRITE :/ 'GL Account Number : ',hkont.
  WRITE :/ 'Cetak : ',sy-datum,sy-uzeit.

  IF radio1 EQ 'X' OR radio2 EQ 'X'.
    sw = 0.
    LOOP AT messtab WHERE msgnr = '312'.
      IF sw = 0.
        WRITE AT 104(10)  'Doc. SAP : '.
        WRITE AT 116(10) messtab-msgv1.
        sw = 1.
      ELSE.
        WRITE :/ ' '.
        WRITE AT 116(10) messtab-msgv1.
      ENDIF.
    ENDLOOP.
  ENDIF.

  FORMAT COLOR 4.
  FORMAT INTENSIFIED OFF.
  WRITE : /(129) sy-uline.
  WRITE :/ sy-vline NO-GAP,(3) 'N0.',sy-vline NO-GAP,(20) 'NAMA BANK',
           sy-vline NO-GAP,(12) 'NO. CHECK',sy-vline NO-GAP,
          (10) 'J. TEMPO',sy-vline NO-GAP,(11) 'NO. DO',sy-vline
          NO-GAP,(10) 'TGL DO',sy-vline NO-GAP,(10) 'KODE OUTLET',
          sy-vline NO-GAP,(20) 'NAMA OUTLET',sy-vline NO-GAP,(14)
          'NILAi (Rp.)',sy-vline NO-GAP.
  WRITE : /(129) sy-uline.

ENDFORM.                    " p_header_tb
*&---------------------------------------------------------------------*
*&      Form  p_detail_tb
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p_detail_tb.
  DATA: l_name1 LIKE kna1-name1.

  v_count = 1.tot1 = 0.va_nou = 0.

  LOOP AT itab5 WHERE error EQ space.
    LOOP AT itab1 WHERE  cekno EQ itab5-cekno
                 AND bname EQ itab5-bname AND duedt EQ itab5-duedt
                 AND bbeln EQ itab5-bbeln..
      IF va_nou = 1.
        FORMAT COLOR 2.
        FORMAT INTENSIFIED OFF.
        va_nou = 0.
      ELSE.
        FORMAT COLOR 1.
        FORMAT INTENSIFIED OFF.
        va_nou = 1.
      ENDIF.

      WRITE :/ sy-vline NO-GAP,(3) v_count,sy-vline NO-GAP,(20)
               itab1-bname,sy-vline NO-GAP,(12) itab1-cekno,sy-vline
             NO-GAP,(10) itab1-duedt,sy-vline NO-GAP,(11) itab1-zuonr,
               sy-vline NO-GAP.
      SELECT SINGLE * FROM zfbid
      WHERE bukrs EQ itab1-bukrs AND vkbur EQ itab1-vkbur
            AND vbeln EQ itab1-belnr.
      SELECT SINGLE name1 INTO l_name1 FROM kna1
      WHERE kunnr EQ itab1-kunnr.
      WRITE : (10) zfbid-fkdat,sy-vline NO-GAP,itab1-kunnr,sy-vline
              NO-GAP,(20) l_name1,sy-vline NO-GAP,(14) itab1-cchek
              CURRENCY 'IDR',sy-vline NO-GAP.
      v_count = v_count + 1.
      tot1 = tot1 + itab1-cchek.
    ENDLOOP.
  ENDLOOP.

  LOOP AT itab5 WHERE error NE space.
    LOOP AT itab1 WHERE  cekno EQ itab5-cekno
                 AND bname EQ itab5-bname AND duedt EQ itab5-duedt
                 AND bbeln EQ itab5-bbeln..
      IF va_nou = 1.
        FORMAT COLOR 2.
        FORMAT INTENSIFIED OFF.
        va_nou = 0.
      ELSE.
        FORMAT COLOR 1.
        FORMAT INTENSIFIED OFF.
        va_nou = 1.
      ENDIF.

      WRITE :/ sy-vline NO-GAP,(3) v_count,sy-vline NO-GAP,(20)
               itab1-bname,sy-vline NO-GAP,(12) itab1-cekno,sy-vline
             NO-GAP,(10) itab1-duedt,sy-vline NO-GAP,(11) itab1-zuonr,
               sy-vline NO-GAP.
      SELECT SINGLE * FROM zfbid
      WHERE bukrs EQ itab1-bukrs AND vkbur EQ itab1-vkbur
            AND vbeln EQ itab1-belnr.
      SELECT SINGLE name1 INTO l_name1 FROM kna1
      WHERE kunnr EQ itab1-kunnr.
      WRITE : (10) zfbid-fkdat,sy-vline NO-GAP,itab1-kunnr,sy-vline
              NO-GAP,(20) l_name1,sy-vline NO-GAP,(14) itab1-cchek
              CURRENCY 'IDR',sy-vline NO-GAP.
      WRITE :/ sy-vline NO-GAP,(126) itab5-error NO-GAP CENTERED,
               sy-vline NO-GAP.
      v_count = v_count + 1.
*         tot1 = tot1 + itab1-cchek.
    ENDLOOP.
  ENDLOOP.

  FORMAT COLOR OFF.
  WRITE : /(129) sy-uline.
  WRITE AT  /100(10) 'TOTAL'.
  WRITE AT 113 sy-vline NO-GAP.
  WRITE AT 114(14) tot1 CURRENCY 'IDR'.
  WRITE AT 129 sy-vline NO-GAP.
  WRITE AT /113(17) sy-uline.

ENDFORM.                    " p_detail_tb
*&---------------------------------------------------------------------*
*&      Form  partial_payment_resid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM partial_payment_resid.
  CLEAR i_bdc.
  PERFORM f_dynpro USING:
  'X' 'SAPMF05A' '0100',
  ' ' 'BDC_CURSOR' 'RF05A-NEWKO',
  ' ' 'BDC_OKCODE' '/00',
  ' ' 'BKPF-BLDAT' bidat,
  ' ' 'BKPF-BLART' 'DZ',
  ' ' 'BKPF-BUKRS' pa_bukrs,
  ' ' 'BKPF-BUDAT' bidat,
  ' ' 'BKPF-MONAT' monat,
  ' ' 'BKPF-WAERS' 'IDR',
  ' ' 'BKPF-XBLNR' itab1-xblnr,
  ' ' 'FS006-DOCID' '*',
  ' ' 'RF05A-NEWBS' '40',
  ' ' 'RF05A-NEWKO' hkont,
  'X' 'SAPMF05A' '0300',
  ' ' 'BDC_CURSOR' 'RF05A-NEWKO',
  ' ' 'BDC_OKCODE'  '/00',
  ' ' 'BSEG-WRBTR' cash,
  ' ' 'BSEG-VALUT' date,
  ' ' 'BSEG-SGTXT' txt,
  ' ' 'RF05A-NEWBS' '15',
  ' ' 'RF05A-NEWKO' wa_itab1-kunnr,
  ' ' 'BDC_SUBSCR' 'SAPLKACB',
  'X' 'SAPLKACB' '0002',
  ' ' 'BDC_CURSOR' 'COBL-GSBER',
  ' ' 'BDC_OKCODE'  '=ENTE',
  ' ' 'COBL-GSBER' itab1-gsber,
  ' ' 'BDC_SUBSCR' 'SAPLKACB',
  'X' 'SAPMF05A' '0301',
  ' ' 'BDC_OKCODE'  '=ZK',
  ' ' 'BSEG-WRBTR' cash,
  ' ' 'BSEG-MWSKZ' '**',
  ' ' 'BSEG-GSBER' itab1-gsber,
  ' ' 'BSEG-ZFBDT' date,
  'X' 'SAPMF05A' '0331',
  ' ' 'BDC_CURSOR' 'BSEG-XREF3',
  ' ' 'BDC_OKCODE' '=BU',
  ' ' 'BSEG-XREF3' itab1-zuonr.

  CALL TRANSACTION 'F-21' USING i_bdc MODE bdcmode UPDATE 'S'
               MESSAGES INTO messtab.
  PERFORM error.
ENDFORM.                    " partial_payment_resid
*&---------------------------------------------------------------------*
*&      Form  cek_lock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek_lock.
*{   REPLACE        P01K910757                                        1
*\  CALL FUNCTION 'ENQUEUE_E0002'
*\      EXPORTING
*\         bukrs  = pa_bukrs
*\         vkbur = pa_vkbur
*\*       gjahr  = pa_gjahr
*\         kunnr  = itab2-kunnr
*\         cekno  = itab2-cekno
*\         bname  = itab2-bname
*\      EXCEPTIONS
*\          foreign_lock   = 4
*\          system_failure = 8.
*\  IF sy-subrc EQ 4.
*\    MESSAGE a000(26) WITH text-041.
*\  ENDIF.
  "Start SOH: Shell Remediation Adjustment 20240326 KRS
  CALL FUNCTION 'ENQUEUE_EZFBICHECK'
    EXPORTING
      bukrs          = pa_bukrs
      vkbur          = pa_vkbur
*     gjahr          = pa_gjahr
      kunnr          = itab2-kunnr
      cekno          = itab2-cekno
      bname          = itab2-bname
    EXCEPTIONS
      foreign_lock   = 4
      system_failure = 8.
  IF sy-subrc EQ 4.
    MESSAGE a000(26) WITH TEXT-041.
  ENDIF.
  "End SOH: Shell Remediation Adjustment 20240326 KRS
*}   REPLACE

ENDFORM.                    " cek_lock
*&---------------------------------------------------------------------*
*&      Form  release_lock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM release_lock.

*_Rem BY SAP_DEV06 03-04-2007.
*  call function 'ENQUEUE_E0002'
*      exporting
*         bukrs  = pa_bukrs
*         vkbur  = pa_vkbur
**       gjahr  = pa_gjahr
*         kunnr  = itab2-kunnr
*         cekno  = itab2-cekno
*         bname  = itab2-bname.
*_End Of Rem BY SAP_DEV06 03-04-2007.

*{   REPLACE        P01K910757                                        1
*\*___Added By SAP_DEV06 03-04-2007.
*\  CALL FUNCTION 'DEQUEUE_E0002'
*\    EXPORTING
*\      bukrs = pa_bukrs
*\      vkbur = pa_vkbur
*\      kunnr = itab2-kunnr
*\      cekno = itab2-cekno
*\      bname = itab2-bname.
*\*___End Of Added By SAP_DEV06 03-04-2007.
  "Start SOH: Shell Remediation Adjustment 20240326 KRS
  CALL FUNCTION 'DEQUEUE_EZFBICHECK'
    EXPORTING
      bukrs = pa_bukrs
      vkbur = pa_vkbur
      kunnr = itab2-kunnr
      cekno = itab2-cekno
      bname = itab2-bname.
  "End SOH: Shell Remediation Adjustment 20240326 KRS
*}   REPLACE

ENDFORM.                    " release_lock
*&---------------------------------------------------------------------*
*&      Form  post_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM post_header.
  CLEAR i_bdc.
  PERFORM f_dynpro USING:
      'X' 'SAPMF05A'    '0100',
      ' ' 'BDC_CURSOR'  'RF05A-NEWKO',
      ' ' 'BDC_OKCODE'  '/00',
      ' ' 'BKPF-BLDAT'  bidat,    "Date of doc.
      ' ' 'BKPF-BUDAT'  bidat,    "Post date in doc.
      ' ' 'BKPF-XBLNR'  itab1-xblnr,    "Reference doc. number
      ' ' 'BKPF-BLART'  'DZ',
      ' ' 'BKPF-BUKRS'  pa_bukrs,    "Company code
      ' ' 'BKPF-WAERS'  'IDR',       "Currency key
      ' ' 'FS006-DOCID' '*',
      ' ' 'RF05A-NEWBS' poskey ,    "Posting key for next line item
      ' ' 'RF05A-NEWKO' itab1-kunnr.    "Account for next line item

ENDFORM.                    " post_header
*&---------------------------------------------------------------------*
*&      Form  poskey
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM poskey.
  PERFORM f_dynpro USING:
      'X' 'SAPMF05A'    '0700',
      ' ' 'BDC_CURSOR'  'RF05A-NEWKO',
      ' ' 'BDC_OKCODE'  '/00',
      ' ' 'RF05A-NEWBS' poskey,"Posting key for next line item
      ' ' 'RF05A-NEWKO' itab1-kunnr."Account for next line item

ENDFORM.                    " poskey
*&---------------------------------------------------------------------*
*&      Form  post_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM post_detail.
  PERFORM f_dynpro USING :
      'X' 'SAPMF05A'    '0301',          "Customer account item
      ' ' 'BDC_CURSOR'  'RF05A-NEWKO',
      ' ' 'BDC_OKCODE'  '=ZK',
      ' ' 'BSEG-WRBTR'   cash,   "Amount in docu. currency
      ' ' 'BSEG-GSBER'   itab1-gsber,   "Business Area
      ' ' 'BSEG-ZFBDT'   bldat,
      ' ' 'BSEG-ZLSPR'   'Z',
      ' ' 'BSEG-ZUONR'   itab1-zuonr,   "Allocation number
      ' ' 'BSEG-SGTXT'   txt,   "Line item text
      'X' 'SAPMF05A' '0331',
      ' ' 'BDC_CURSOR' 'BSEG-XREF1',
      ' ' 'BDC_OKCODE'  '/14',
      ' ' 'BSEG-XREF1' itab1-parvw,
      ' ' 'BSEG-XREF2' itab1-slcod+4(6),
      ' ' 'BSEG-XREF3' itab1-zuonr.

ENDFORM.                    " post_detail
*&---------------------------------------------------------------------*
*&      Form  save
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save.
  REFRESH messtab1.
  PERFORM f_dynpro USING:
            'X' 'SAPMF05A'    '0300',
            ' ' 'BDC_CURSOR'  'RF05A-NEWKO',
            ' ' 'BDC_OKCODE'  '/00',
            ' ' 'BSEG-WRBTR'  cash,    "Amount in docu. currency
            ' ' 'BSEG-ZUONR'  itab1-zuonr,    "Allocation number
            ' ' 'BSEG-SGTXT' txt,    "Line item text
            ' ' 'BDC_OKCODE' '/14',
            'X' 'SAPLKACB'    '0002',
            ' ' 'BDC_CURSOR' 'COBL-GSBER',
            ' ' 'BDC_OKCODE' '=ENTE',
            ' ' 'COBL-GSBER' v_gsber,    "Business Area
            ' ' 'BDC_OKCODE' '/08',
            'X' 'SAPMF05A'    '0700',
            ' ' 'BDC_OKCODE' '=BU'.
  CLEAR: messtab1.
  REFRESH: messtab1.
  CALL TRANSACTION 'F-21' USING i_bdc MODE bdcmode UPDATE 'S'
               MESSAGES INTO messtab1.
  IF sy-subrc EQ 0.
    PERFORM error.
    APPEND LINES OF messtab1 TO messtab.
    COMMIT WORK.
  ELSE.
    LOOP AT messtab1 WHERE msgtyp = 'E'.
      READ TABLE messtab1 INDEX 1.
      CALL FUNCTION 'FORMAT_MESSAGE'
        EXPORTING
          id   = messtab1-msgid
          lang = messtab1-msgspra
          no   = messtab1-msgnr
          v1   = messtab1-msgv1
          v2   = messtab1-msgv2
          v3   = messtab1-msgv3
          v4   = messtab1-msgv4
        IMPORTING
          msg  = itab5-error.
      MODIFY itab5.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " save
*&---------------------------------------------------------------------*
*&      Form  get_data_tolak
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_tolak.
  SELECT cekno bname duedt kunnr SUM( cchek ) INTO
                  (itab2-cekno, itab2-bname, itab2-duedt, itab2-kunnr,
                   itab2-cchek)
                  FROM zfbicheck
                  WHERE bukrs EQ pa_bukrs AND
                  vkbur EQ pa_vkbur AND
                  kunnr IN custno   AND
                  slcod IN slcode   AND
                  duedt IN duedt2   AND
                  cekno IN cekno    AND
*                gjahr eq pa_gjahr and
                  pcair EQ  'C'
                 GROUP BY kunnr cekno bname duedt .
    APPEND itab2.
  ENDSELECT.


ENDFORM.                    " get_data_tolak
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
        vspld       LIKE  usr01-spld,
        ld_arparams LIKE arc_params.
  DATA: ld_layout LIKE sy-paart,     "Druck-Layout
        ld_valid.

* Standardlayout zum im Benutzerstamm eingetragenen Drucker setzen
  SELECT SINGLE spld INTO vspld FROM usr01 WHERE bname = sy-uname.

*__Rem By SAP_DEV06 04-04-2007
*  PERFORM SET_LAYOUT(SAPLSPRI) USING    VSPLD 1 SY-LINSZ
*                               CHANGING LD_LAYOUT.
*__End Of Rem By SAP_DEV06 04-04-2007

*_Added By SAP_DEV06 04-04-2007.
  PERFORM set_layout(saplspri) USING    vspld 1 sy-linsz 1 sy-linsz
                               CHANGING ld_layout.
*_End Of Added SAP_DEV06 04-04-2007


  CALL FUNCTION 'GET_PRINT_PARAMETERS'
    EXPORTING
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

    PERFORM p_header_tb.
    PERFORM p_detail_tb.
    PERFORM p_footer.

    LEAVE TO SCREEN 0.
  ENDIF.

  NEW-PAGE PRINT OFF.

ENDFORM.                    " print
*&---------------------------------------------------------------------*
*&      Form  detail_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM detail_update.
  DATA: l_name1 LIKE kna1-name1.
  v_count = 0.
  SORT itab2 BY bname cekno.
  LOOP AT itab2.
    IF v_count = 1.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED OFF.
      v_count = 0.
    ELSE.
      FORMAT COLOR 1.
      FORMAT INTENSIFIED OFF.
      v_count = 1.
    ENDIF.
    SELECT SINGLE name1 INTO l_name1 FROM kna1
           WHERE kunnr EQ itab2-kunnr.

    WRITE :/ sy-vline NO-GAP,(10) itab2-kunnr,sy-vline NO-GAP,(20)
              l_name1,sy-vline NO-GAP,(24)
             itab2-bname,sy-vline NO-GAP,(12)
             itab2-cekno,sy-vline NO-GAP,(10) itab2-duedt,
            sy-vline NO-GAP,(14) itab2-cchek CURRENCY 'IDR',sy-vline
            NO-GAP.
    WRITE AT 105 va_mark AS CHECKBOX.
    WRITE AT 108 sy-vline NO-GAP.
  ENDLOOP.
  WRITE : /(108) sy-uline.

ENDFORM.                    " detail_update
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
*&      Form  ONETIME_CUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM onetime_cust.
  SELECT SINGLE * FROM kna1 WHERE kunnr EQ itab1-kunnr.
  PERFORM f_dynpro USING :
     'X' 'SAPLFCPD'      '0100',
     ' ' 'BDC_CURSOR'    'BSEC-PSTLZ',
     ' ' 'BDC_OKCODE'    '/00',
     ' ' 'BSEC-ANRED'    kna1-anred,
     ' ' 'BSEC-SPRAS'    kna1-spras,
     ' ' 'BSEC-NAME1'    kna1-name1,
     ' ' 'BSEC-NAME2'    kna1-name2,
     ' ' 'BSEC-ORT01'    kna1-ort01,
     ' ' 'BSEC-PSTLZ'    kna1-pstlz.

ENDFORM.                    " ONETIME_CUST
*&---------------------------------------------------------------------*
*&      Form  get_data_reprint_cair
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_reprint_cair.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE itab1
                FROM zfbicheck
                WHERE bukrs EQ pa_bukrs AND
                vkbur EQ pa_vkbur AND
                kunnr IN custno   AND
*                gjahr eq pa_gjahr and
                ncair EQ pa_blchk AND
                pcair EQ 'C'.


ENDFORM.                    " get_data_reprint_cair
*&---------------------------------------------------------------------*
*&      Form  get_data_reprint_tolak
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_reprint_tolak.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE itab1
                  FROM zfbicheck
                  WHERE bukrs EQ pa_bukrs AND
                  vkbur EQ pa_vkbur AND
                  kunnr IN custno   AND
*                gjahr eq pa_gjahr and
                  blnck EQ pa_blchk AND
                  pcair EQ 'T'.

ENDFORM.                    " get_data_reprint_tolak
*&---------------------------------------------------------------------*
*&      Form  get_data_reprint_batal
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_reprint_batal.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE itab1
                  FROM zfbicheck
                  WHERE bukrs EQ pa_bukrs AND
                  vkbur EQ pa_vkbur AND
                  kunnr IN custno   AND
*                gjahr eq pa_gjahr and
                  blnck EQ pa_blchk AND
                  pcair EQ 'B'.

ENDFORM.                    " get_data_reprint_batal
*&---------------------------------------------------------------------*
*&      Form  cek_account
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek_account.
  DATA l_saknr LIKE skb1-saknr.

  SELECT SINGLE saknr INTO l_saknr FROM skb1
  WHERE bukrs EQ pa_bukrs AND saknr EQ hkont.
  IF sy-subrc NE 0.
    MESSAGE e000(26) WITH 'GL Account ini Tidak Ada di GL Account Bank'.
  ENDIF.
ENDFORM.                    " cek_account
*&---------------------------------------------------------------------*
*&      Form  p_detail_tb1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p_detail_tb1.
  DATA: l_name1 LIKE kna1-name1.

  v_count = 1.tot1 = 0.va_nou = 0.

  LOOP AT itab1.
    IF va_nou = 1.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED OFF.
      va_nou = 0.
    ELSE.
      FORMAT COLOR 1.
      FORMAT INTENSIFIED OFF.
      va_nou = 1.
    ENDIF.

    WRITE :/ sy-vline NO-GAP,(3) v_count,sy-vline NO-GAP,(20)
             itab1-bname,sy-vline NO-GAP,(12) itab1-cekno,sy-vline
            NO-GAP,(10) itab1-duedt,sy-vline NO-GAP,itab1-zuonr(11),
             sy-vline NO-GAP.
    SELECT SINGLE * FROM zfbid
    WHERE bukrs EQ itab1-bukrs AND vkbur EQ itab1-vkbur
          AND vbeln EQ itab1-belnr.
    SELECT SINGLE name1 INTO l_name1 FROM kna1
    WHERE kunnr EQ itab1-kunnr.
    WRITE : (10) zfbid-fkdat,sy-vline NO-GAP,itab1-kunnr,sy-vline
            NO-GAP,(20) l_name1,sy-vline NO-GAP,(14) itab1-cchek
            CURRENCY 'IDR',sy-vline NO-GAP.
    v_count = v_count + 1.
    tot1 = tot1 + itab1-cchek.
  ENDLOOP.
  FORMAT COLOR OFF.
  WRITE : /(129) sy-uline.
  WRITE AT  /100(10) 'TOTAL'.
  WRITE AT 113 sy-vline NO-GAP.
  WRITE AT 114(14) tot1 CURRENCY 'IDR'.
  WRITE AT 129 sy-vline NO-GAP.
  WRITE AT /113(17) sy-uline.

ENDFORM.                    " p_detail_tb1

*&---------------------------------------------------------------------*
*&      Form  error
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM error.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    READ TABLE i_messtab INTO wa_messtab INDEX 1.
    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        id   = wa_messtab-msgid
        lang = wa_messtab-msgspra
        no   = wa_messtab-msgnr
        v1   = wa_messtab-msgv1
        v2   = wa_messtab-msgv2
        v3   = wa_messtab-msgv3
        v4   = wa_messtab-msgv4
      IMPORTING
        msg  = msg.
    wa_log_error-bukrs = pa_bukrs.
    wa_log_error-gjahr = wa_itab1-gjahr.
    wa_log_error-belnr = wa_itab1-vbeln.
    APPEND wa_log_error TO i_log_error.

    zfbierror-bukrs = wa_log_error-bukrs.
    zfbierror-vkbur = pa_vkbur.
    zfbierror-gjahr = wa_itab1-gjahr.
    zfbierror-belnr = wa_itab1-vbeln.
    zfbierror-bbeln = pa_bbeln.
    zfbierror-tcode = wa_messtab-tcode.
    zfbierror-subrc = sy-subrc.
    zfbierror-uname = sy-uname.
    zfbierror-datum = sy-datum.
    zfbierror-uzeit = sy-uzeit.
    zfbierror-msg   = msg.
    MODIFY  zfbierror.


  ENDIF.
ENDFORM.                    " error

*&---------------------------------------------------------------------*
*&      Form  F_AUTH_USRGRP
*&---------------------------------------------------------------------*
FORM f_auth_usrgrp  CHANGING fc_usrgrp.
  DATA : return    TYPE STANDARD TABLE OF bapiret2,
         groups    TYPE STANDARD TABLE OF bapigroups,
         ls_groups LIKE LINE OF groups.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    TABLES
      return   = return
      groups   = groups.

  IF line_exists( groups[ usergroup = 'BOM' ] ).
    fc_usrgrp = VALUE #( groups[ usergroup = 'BOM' ]-usergroup OPTIONAL ).
  ELSEIF line_exists( groups[ usergroup = 'BOS' ] ).
    fc_usrgrp = VALUE #( groups[ usergroup = 'BOS' ]-usergroup OPTIONAL ).
  ELSEIF line_exists( groups[ usergroup = 'FAS' ] ).
    fc_usrgrp = VALUE #( groups[ usergroup = 'FAS' ]-usergroup OPTIONAL ).
  ELSE.
    CLEAR fc_usrgrp.
  ENDIF.
ENDFORM.
