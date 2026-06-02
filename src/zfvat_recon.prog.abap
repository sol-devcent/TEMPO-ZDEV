REPORT zf_recon_tax MESSAGE-ID zf NO STANDARD PAGE HEADING
*                                  line-count 63(3).
                                  LINE-SIZE  200.


************************************************************************
*                  REPORT                                              *
*----------------------------------------------------------------------*
* ABAP Name   :  ZFVAT_RECON                                           *
* Created by  :  Sukardi                                               *
* Created on  :                                                        *
* Version     : 0.0                                                    *
*----------------------------------------------------------------------*
* Description :                                                        *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
*& CRNO#          DATE         AUTHOR         DESCRIPTION              *
*& DEVK935910     19.08.2013                  Modifikasi untuk SUT     *
*&                                            Project                  *
*
*----------------------------------------------------------------------*
TABLES: tgsb,
        lfa1,
        kna1,
        bsik,
        bsak,
        bsid,
        bsad,
        bsis,
        zfvato,
        zfvatb1_temp.

TYPES : BEGIN OF t_itab1,
          bukrs        LIKE bsis-bukrs,
          hkont        LIKE bsis-hkont,
          gjahr        LIKE bsis-gjahr,
          budat        LIKE bsis-budat,
          bldat        LIKE bsis-bldat,
          waers        LIKE bsis-waers,
          xblnr        LIKE bsis-xblnr,
          blart        LIKE bsis-blart,
          monat        LIKE bsis-monat,
          bschl        LIKE bsis-bschl,
          shkzg        LIKE bsis-shkzg,
          mwskz        LIKE bsis-mwskz,
          dmbtr        LIKE bsis-dmbtr,
          sgtxt        LIKE bsis-sgtxt,
          zfbdt        LIKE bsis-zfbdt,
          belnr        LIKE bsis-belnr,
          kunnr        LIKE bsid-kunnr,
          lifnr        LIKE bsik-lifnr,
          zuonr        LIKE bsik-zuonr,
          gsber        LIKE bsik-gsber,
          stcd1        LIKE lfa1-stcd1,
          stceg        LIKE lfa1-stceg,
          anred        LIKE lfa1-anred,
          name1        LIKE lfa1-name1,
          name2        LIKE lfa1-name2,
          bktxt        LIKE bkpf-bktxt,
          tcode        LIKE bkpf-tcode,
          gform        LIKE kna1-gform,
          va_gform(10),
          cityc        LIKE kna1-cityc,
          va_date(15),
          va_cityc(8),
          va_zuonr(25),
          va_title(80),
          va_gsber(10),
          xref3        LIKE bsis-xref3,   "permintaan patris
          stblg        LIKE rbkp-stblg,
          buzei        LIKE bsis-buzei,
          notaretur(8),
          vkbur        TYPE vkbur,
        END OF t_itab1,

        BEGIN OF t_itab2,
          bukrs	LIKE  bsis-bukrs,
          gjahr	LIKE  bsis-gjahr,
          belnr	LIKE  bsis-belnr,
          budat	LIKE  bsis-budat,
          blart	LIKE  bsis-blart,
          stblg	LIKE  rbkp-stblg,
          rebzg LIKE   bsik-rebzg,
        END OF t_itab2.
TYPES: BEGIN OF t_log_error,
         bukrs   LIKE bsis-bukrs,
         hkont   LIKE bsis-hkont,
         gjahr   LIKE bsis-gjahr,
         belnr   LIKE bsis-belnr,
         msg(80),
       END OF t_log_error.


TYPES:   BEGIN OF t_bdc.
           INCLUDE STRUCTURE bdcdata.
         TYPES:   END OF t_bdc.
TYPES:   BEGIN OF t_messtab.
           INCLUDE STRUCTURE bdcmsgcoll.
         TYPES:   END OF t_messtab.
TYPES: BEGIN OF t_zfvato,
         gform        LIKE kna1-gform,
         va_gform(10),
         va_cityc(8),
         va_date(15),
         va_zuonr(25),
         va_title(80),
         va_gsber(10),
         budat        LIKE zfvato-budat,
         cityc        LIKE zfvato-cityc,
         dudat        LIKE zfvato-dudat,
         fkdat        LIKE zfvato-fkdat,
*            GFORM     like zfvato-GFORM,
         gjahr        LIKE zfvato-gjahr,
         gsber        LIKE zfvato-gsber,
         kunrg        LIKE zfvato-kunrg,
         mwsbk        LIKE zfvato-mwsbk,
         name_co      LIKE zfvato-name_co,
         stceg        LIKE zfvato-stceg,
         vatno        LIKE zfvato-vatno,
         vatpr        LIKE zfvato-vatpr,
         vbeln        LIKE zfvato-vbeln,
         vkbur        LIKE zfvato-vkbur,
         vkorg        LIKE zfvato-vkorg,
         vtart        LIKE zfvato-vtart,
         zuonr        LIKE zfvato-zuonr,

*         INCLUDE STRUCTURE ZFVATO.
       END OF t_zfvato.

DATA:
  va_answer,
  BEGIN OF it_message OCCURS 5.
    INCLUDE STRUCTURE popuptext.
  DATA: END OF it_message.

DATA: va_tax_patern(18) VALUE '+++++-+++-++++++++'.

* add by Budi 11/01/2007
DATA: va_tax_patern1(19) VALUE '+++.+++-++.++++++++',
      va_vatpr(19).
* endadd by Budi 11/01/2007
DATA: va_tax_patern2 TYPE string VALUE '++.++.++.+++-++++++++'.


DATA: i_itab2      TYPE t_itab2 OCCURS 0,
      wa_itab2     TYPE t_itab2,
      i_itab1      TYPE t_itab1 OCCURS 0,
      i_itab3      TYPE t_itab1 OCCURS 0,
      i_itab4      TYPE t_itab1 OCCURS 0,
      i_itab5      TYPE t_itab1 OCCURS 0,
      wa_itab1     TYPE t_itab1,
      wa_zfvatvend LIKE zfvatvend,
      i_zfvato     TYPE t_zfvato OCCURS 0,
      i_zfvato_err TYPE t_zfvato OCCURS 0,
      wa_zfvato    TYPE t_zfvato,
      va_ctr       TYPE i,
      i_log_error  TYPE t_log_error OCCURS 0,
      wa_log_error TYPE t_log_error,
      msg(80),
      i_messtab    TYPE t_messtab OCCURS 0,
      wa_messtab   TYPE t_messtab,
      i_bdc        TYPE t_bdc OCCURS 0,
      wa_bdc       TYPE t_bdc,
      va_mode(1),
      va_xref3     LIKE bsis-xref3,
      va_hkont1    LIKE bsis-hkont,
      va_hkont2    LIKE bsis-hkont.
DATA: va_value         LIKE bsis-belnr,
      va_value1        LIKE lfa1-lifnr,
      va_fieldname(30).
DATA: check(6).
DATA: bulan(2).

DATA: BEGIN OF t_zfppnnrd OCCURS 0,
        bukrs   LIKE zfppnnrh-bukrs,
        kunnr   LIKE zfppnnrh-kunnr,
        monat   LIKE zfppnnrh-monat,
        gjahr   LIKE zfppnnrh-gjahr,
        vkbur   LIKE zfppnnrd-vkbur,
        belnr   LIKE zfppnnrd-belnr,
        nonr    LIKE zfppnnrd-nonr,
        zuonr   LIKE zfppnnrd-zuonr,
        nrdt    LIKE zfppnnrd-nrdt,
*        include structure zfppnnrd.
        belnrrc LIKE zfppnnrh-belnrrc,
      END OF t_zfppnnrd.
DATA: va_live LIKE zplbc-live.

RANGES: ta_date FOR zfvatb4-txdat.


DATA:
  c1   TYPE i,
  w1   TYPE i,  w2    TYPE i,  w3    TYPE i,  w3a   TYPE i,
  w4   TYPE i,  w5    TYPE i,  w6    TYPE i,  w7    TYPE i,
  w8   TYPE i,  w9    TYPE i,  w10   TYPE i,  w11   TYPE i,
  w12  TYPE i,  w13   TYPE i,  w14   TYPE i,  w15   TYPE i,
  w16  TYPE i,  w17   TYPE i,  w18   TYPE i,  w19   TYPE i,
  w19a TYPE i,  w20   TYPE i,  w17a  TYPE i,
  w21  TYPE i,  w22   TYPE i,  w23   TYPE i,  w24   TYPE i,
  w25  TYPE i,  w26   TYPE i,  w27   TYPE i,  w28   TYPE i,
  w29  TYPE i,  w30   TYPE i,  w31   TYPE i,  w32   TYPE i,
  w33  TYPE i,  w34   TYPE i,  w35   TYPE i.

DATA : gs_coretax   TYPE zproject.

****************************************************
*        Parameters                                *
****************************************************
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS : pa_bukrs LIKE bsis-bukrs OBLIGATORY, "default '8020'
             pa_gsber LIKE bsis-gsber  OBLIGATORY, "DEFAULT '0200'
             pa_monat LIKE ical_info-month_no DEFAULT sy-datum+4(2) OBLIGATORY,
             pa_gjahr LIKE bsis-gjahr DEFAULT sy-datum+0(4) OBLIGATORY.
* Parameters:  pa_flag(1).
SELECT-OPTIONS: so_belnr FOR bsis-belnr MODIF ID bel.

SELECTION-SCREEN END OF BLOCK block1.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad
             DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(35) TEXT-003 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-004 FOR FIELD radio2.
SELECTION-SCREEN END OF LINE.
*  SELECTION-SCREEN BEGIN OF LINE.
*    PARAMETERS : Radio5 RADIOBUTTON GROUP GRP1.
*    SELECTION-SCREEN : COMMENT 5(35) TEXT-010.
*  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-007 FOR FIELD radio3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-008 FOR FIELD radio4.
SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN SKIP 1.
*  SELECTION-SCREEN BEGIN OF LINE.
*    PARAMETERS : Radio3 RADIOBUTTON GROUP GRP1.
*    SELECTION-SCREEN : COMMENT 5(35) TEXT-007.
*  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
PARAMETERS: pa_test DEFAULT 'X' AS CHECKBOX .
SELECTION-SCREEN END OF BLOCK block2.

************************************************************************
* PROGRAM                                                              *
************************************************************************
************************************************************************
* AT SELECTION-SCREEN
************************************************************************
AT SELECTION-SCREEN ON pa_bukrs.
  IF pa_bukrs EQ '8020' OR pa_bukrs EQ '8010' OR
     pa_bukrs EQ '8030' OR pa_bukrs EQ '8070' OR
     pa_bukrs EQ '8380'.
  ELSE.
    MESSAGE e000(zf)
      WITH 'CoCd must be entry 8010, 8020, 8030, 8070, 8380'.
  ENDIF.

AT SELECTION-SCREEN ON pa_gsber.
  SELECT SINGLE * FROM tgsb
         WHERE gsber EQ pa_gsber.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Business Area Not Found'.
  ENDIF.

  IF pa_bukrs EQ '8020'.
    IF pa_gsber NE '0200' AND
      pa_gsber NE '02A1' AND
      pa_gsber NE '02A2' AND
      pa_gsber NE '02B1' AND
      pa_gsber NE '02TM' AND
      pa_gsber NE 'T220'.
      MESSAGE e000(zf) WITH 'Business Area must be entry 0200/02TM/T220'.
    ENDIF.
  ELSEIF pa_bukrs EQ '8030'.
    IF pa_gsber EQ 0 OR pa_gsber EQ space OR pa_gsber+0(2) NE '03'.
      MESSAGE e000(zf) WITH 'Business Area must be entry 03xx'.
    ENDIF.
  ELSEIF pa_bukrs EQ '8010'.
    IF pa_gsber NE '0101'.
      MESSAGE e000(zf) WITH 'Business Area must be entry 0101'.
    ENDIF.
  ELSEIF pa_bukrs EQ '8070'.
*    IF pa_gsber NE '0700'.
*      MESSAGE e000(zf) WITH 'Business Area must be entry 0700'.
*    ENDIF.
  ENDIF.
*AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
*        ID 'GSBER' FIELD pa_gsber
*        ID 'ACTVT' FIELD '01'.
*        IF SY-SUBRC NE 0.
*            MESSAGE E000(zf) WITH
*           'No Authorization For Bussiness Area'
*           pa_gsber.
*        ENDIF.


AT SELECTION-SCREEN ON pa_monat.
  IF pa_monat > 12.
    MESSAGE e000(zf) WITH 'Invalid Periode (01..12) '.
  ENDIF.
  IF pa_monat < 1.
    MESSAGE e000(zf) WITH 'Invalid Periode (01..12) '.
  ENDIF.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  CASE 'X'.
    WHEN radio1.
      LOOP AT SCREEN.
        IF screen-group1 = 'BEL'.
          screen-active  = 1.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN radio2.
      LOOP AT SCREEN.
        IF screen-group1 = 'BEL'.
          screen-active  = 1.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN OTHERS.
      LOOP AT SCREEN.
        IF screen-group1 = 'BEL'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.

************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.
  PERFORM  initialize_all.
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
          parid EQ 'GSB'.

  IF sy-subrc EQ 0.
    pa_gsber  = lv_parva.
  ENDIF.

************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.
* MODE       = 'N'.    "Running BackGroud
* MODE       = 'A'.    "Running Fore Groud

  PERFORM  initialize_all.

  SELECT SINGLE *
    FROM zproject
    INTO CORRESPONDING FIELDS OF gs_coretax
    WHERE name = 'CORETAX'.

  CLEAR va_xref3.
  IF pa_test = 'X'.
    va_mode = 'N'.
  ELSE.
    va_mode = 'A'.
  ENDIF.
  CLEAR it_message.
  IF radio1 = 'X'.
    PERFORM f_process_vatin.
  ENDIF.
  IF radio2 = 'X'.
    PERFORM f_proses_vatout_cn.
    PERFORM f_proses_vatout.
  ENDIF.
*if radio5 = 'X'.
*  Perform f_proses_vatout_cn.
*endif.

  DESCRIBE TABLE i_log_error LINES va_ctr.
  IF va_ctr > 0.
    LOOP AT i_log_error INTO wa_log_error.
      FORMAT COLOR 2.
      WRITE: / wa_log_error-bukrs, sy-vline,
               wa_log_error-hkont,  sy-vline,
               wa_log_error-gjahr,  sy-vline,
               wa_log_error-belnr,  sy-vline.
      NEW-LINE.
      FORMAT COLOR 6. FORMAT COLOR OFF.
      WRITE:AT 10 ' Error Log : ' INTENSIFIED OFF  COLOR 6,
              wa_log_error-msg INTENSIFIED ON   COLOR 6.
    ENDLOOP.
  ENDIF.

  IF radio3 = 'X' AND
     pa_bukrs  EQ '8010'.
*     Call transaction 'SM30'.
    CLEAR i_bdc.
    PERFORM f_dynpro USING:
       'X'  'SAPMSVMA'     '0100',
       ' '  'BDC_OKCODE'    '=UPD',
       ' '  'VIEWNAME'      'ZFRECON',
       ' '  'VIMDYNFLDS-LTD_DTA_NO'   ' ',
       ' '  'VIMDYNFLDS-LTD_DTA_AR'   'X',

       'X'  'SAPLSVIX'     '0210',
       ' '  'MARK_CHECKBOX(01)'   'X',

       'X'  'SAPLSVIX'     '0100',
       ' '  'BDC_OKCODE'   '=OKAY',
       ' '  'D0100_FIELD_TAB-LOWER_LIMIT(01)' pa_bukrs.

    CALL TRANSACTION 'YF01' USING i_bdc
                         MODE 'E'
                         UPDATE 'S'
                         MESSAGES INTO i_messtab.
  ENDIF.

  IF radio4 = 'X'.
*     Call transaction 'SM30'.
    CLEAR i_bdc.
    PERFORM f_dynpro USING:
       'X'  'SAPMSVMA'     '0100',
       ' '  'BDC_OKCODE'    '=UPD',
       ' '  'VIEWNAME'      'ZFVATVEND',
       ' '  'VIMDYNFLDS-LTD_DTA_NO'   ' ',
       ' '  'VIMDYNFLDS-LTD_DTA_AR'   'X',

       'X'  'SAPLSVIX'     '0210',
       ' '  'MARK_CHECKBOX(01)'   'X',
       ' '  'MARK_CHECKBOX(02)'   'X'.

    CALL TRANSACTION 'YF01' USING i_bdc
                         MODE 'E'
                         UPDATE 'S'
                         MESSAGES INTO i_messtab.
  ENDIF.

  PERFORM  initialize_all.

************************************************************************
* AT LINE-SELECTION.
************************************************************************
AT LINE-SELECTION.
  IF sy-lsind = 1.
    GET CURSOR FIELD va_fieldname VALUE va_value.
    CASE va_fieldname.
      WHEN 'WA_ITAB1-BELNR'.
        SET PARAMETER ID  'BLN' FIELD va_value.
        SET PARAMETER ID  'BUK' FIELD pa_bukrs.
        SET PARAMETER ID  'GJR' FIELD pa_gjahr.
        CALL TRANSACTION 'FB02' AND SKIP FIRST SCREEN.
      WHEN 'WA_ITAB1-LIFNR'.
        SET PARAMETER ID  'LIF' FIELD va_value.
        SET PARAMETER ID  'BUK' FIELD pa_bukrs.
        CALL TRANSACTION 'FK02' AND SKIP FIRST SCREEN.
      WHEN 'WA_ITAB1-KUNNR'.
        SET PARAMETER ID  'KUN' FIELD va_value.
        SET PARAMETER ID  'BUK' FIELD pa_bukrs.
        CALL TRANSACTION 'XD02' AND SKIP FIRST SCREEN.
      WHEN 'WA_ZFVATO-KUNRG'.
        SET PARAMETER ID  'KUN' FIELD va_value.
        SET PARAMETER ID  'BUK' FIELD pa_bukrs.
        CALL TRANSACTION 'XD02' AND SKIP FIRST SCREEN.
    ENDCASE.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  f_process_vatin
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_vatin.
  DATA: l_line1 TYPE i, l_line2 TYPE i.
  CLEAR: i_itab1, i_itab3, i_itab2, i_itab4, i_itab5,
         wa_itab1, wa_itab2.

  PERFORM f_clear_transaction.
  PERFORM f_collect_data_vatin.
  PERFORM f_post_clearing_vat_import.
  DESCRIBE TABLE i_itab1 LINES l_line1.
  DESCRIBE TABLE i_itab3 LINES l_line2.
  IF l_line1 > 0 OR l_line2 > 0.
    it_message-text = 'Koreksi Data'.
    APPEND it_message.
    it_message-text = 'Pilih Cancel untuk Kembali Menu awal'.
    APPEND it_message.
    it_message-text = 'Pilih Continue untuk Koreksi Data'.
    APPEND it_message.
    CALL FUNCTION 'DD_POPUP_WITH_INFOTEXT'
      EXPORTING
        titel        = 'Koreksi Data'
        start_column = 1
        start_row    = 1
        end_row      = 5
      IMPORTING
        answer       = va_answer
      TABLES
        lines        = it_message
      EXCEPTIONS
        OTHERS       = 1.
    IF va_answer NE 'Y'.
      EXIT.
    ENDIF.
    PERFORM f_koreksi_doc.
  ENDIF.
ENDFORM.                    " f_process_vatin

*&---------------------------------------------------------------------*
*&      Form  f_clear_transaction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_clear_transaction.
  DATA: l_value(15),
        l_date(10),
        l_monat(2).
  WRITE pa_monat TO l_monat.
  IF l_monat EQ 0.
    WRITE sy-datum+4(2) TO l_monat.
  ENDIF.
  SELECT a~bukrs a~gjahr a~belnr a~budat a~bldat
         b~stblg
         FROM bsis AS a JOIN rbkp AS b ON a~bukrs EQ b~bukrs AND
                                            a~belnr EQ b~belnr AND
                                            a~gjahr EQ b~gjahr
         INTO CORRESPONDING FIELDS OF   TABLE i_itab2
         WHERE a~bukrs EQ pa_bukrs AND
               a~monat EQ pa_monat AND
               a~hkont EQ '0142200200' AND
               a~belnr IN so_belnr AND
               a~blart EQ 'RC'     AND
               b~stblg NE space.
  LOOP AT i_itab2 INTO wa_itab2.
    WRITE wa_itab2-budat TO l_date.
    CLEAR i_bdc.
    PERFORM f_dynpro USING:
          'X'  'SAPMF05A'     '0131',
          ' '  'BDC_CURSOR'   'RF05A-XPOS1(02)',
          ' '  'BDC_OKCODE'   '=PA',
          ' '  'RF05A-AGKON'  '0142200200',
          ' '  'BKPF-BUDAT'   l_date,
          ' '  'BKPF-MONAT'   l_monat,
          ' '  'BKPF-BUKRS'   pa_bukrs,
          ' '  'BKPF-WAERS'   'IDR',
          ' '  'RF05A-XPOS1(01)'  ' ',
          ' '  'RF05A-XPOS1(02)'  'X',
          'X'  'SAPMF05A'      '0731',
          ' '  'BDC_CURSOR'    'RF05A-SEL01(02)',
          ' '  'BDC_OKCODE'    '=BU',
          ' '  'RF05A-SEL01(01)' wa_itab2-belnr,
          ' '  'RF05A-SEL01(02)' wa_itab2-stblg.
    CALL TRANSACTION 'F-03' USING i_bdc MODE va_mode UPDATE 'S'
                       MESSAGES INTO i_messtab.
    IF sy-subrc NE 0.
*       read table i_messtab into wa_messtab index 1.
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
          msg  = wa_log_error-msg.

      wa_log_error-hkont =    '0142200200'.
      wa_log_error-bukrs = pa_bukrs.
      wa_log_error-gjahr = wa_itab2-gjahr.
      wa_log_error-belnr = wa_itab2-belnr.
      APPEND wa_log_error TO i_log_error.
*           write: / 'Message Error : ', wa_log_error-MSG.
*           message e001(zs) with wa_log_error-MSG.
    ENDIF.
  ENDLOOP.


  CLEAR: i_itab2.
  SELECT a~bukrs a~gjahr a~belnr a~budat a~bldat
         c~rebzg
         FROM bsis AS a JOIN bkpf AS b ON   a~bukrs EQ b~bukrs AND
                                            a~belnr EQ b~belnr AND
                                            a~gjahr EQ b~gjahr AND
                                            a~monat EQ b~monat
              LEFT OUTER JOIN bsik AS c ON c~bukrs EQ a~bukrs AND
                                           c~belnr EQ a~belnr AND
                                           c~gjahr EQ a~gjahr AND
                                           c~monat EQ a~monat
         INTO CORRESPONDING FIELDS OF   TABLE i_itab2
         WHERE a~bukrs EQ pa_bukrs AND
               a~monat EQ pa_monat AND
               a~hkont EQ '0142200200' AND
               a~belnr IN so_belnr AND
               a~blart EQ 'KG'     AND
               b~tcode EQ 'MR8M'.
  CLEAR wa_itab2.
  LOOP AT i_itab2 INTO wa_itab2.
    IF wa_itab2-rebzg EQ space.
      SELECT SINGLE rebzg INTO wa_itab2-rebzg FROM bsak
             WHERE bukrs EQ pa_bukrs AND
                   monat EQ pa_monat AND
                   blart EQ 'KG' AND
                   belnr EQ wa_itab2-belnr.
    ENDIF.
    WRITE wa_itab2-budat TO l_date.
    CLEAR i_bdc.
    PERFORM f_dynpro USING:
          'X'  'SAPMF05A'     '0131',
          ' '  'BDC_CURSOR'   'RF05A-XPOS1(02)',
          ' '  'BDC_OKCODE'   '=PA',
          ' '  'RF05A-AGKON'  '0142200200',
          ' '  'BKPF-BUDAT'   l_date,
          ' '  'BKPF-MONAT'   l_monat,
          ' '  'BKPF-BUKRS'   pa_bukrs,
          ' '  'BKPF-WAERS'   'IDR',
          ' '  'RF05A-XPOS1(01)'  ' ',
          ' '  'RF05A-XPOS1(02)'  'X',
          'X'  'SAPMF05A'      '0731',
          ' '  'BDC_CURSOR'    'RF05A-SEL01(02)',
          ' '  'BDC_OKCODE'    '=BU',
          ' '  'RF05A-SEL01(01)' wa_itab2-belnr,
          ' '  'RF05A-SEL01(02)' wa_itab2-rebzg.
    CALL TRANSACTION 'F-03' USING i_bdc MODE va_mode UPDATE 'S'
                       MESSAGES INTO i_messtab.
    IF sy-subrc NE 0.
*       read table i_messtab into wa_messtab index 1.
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
          msg  = wa_log_error-msg.

      wa_log_error-hkont =    '0142200200'.
      wa_log_error-bukrs = pa_bukrs.
      wa_log_error-gjahr = wa_itab2-gjahr.
      wa_log_error-belnr = wa_itab2-belnr.
      APPEND wa_log_error TO i_log_error.
*           write: / 'Message Error : ', wa_log_error-MSG.
*           message e001(zs) with wa_log_error-MSG.
    ENDIF .
    CLEAR wa_itab2.
  ENDLOOP.

ENDFORM.                    " f_clear_transaction


*&---------------------------------------------------------------------*
*&      Form  f_collect_data_vatin
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_data_vatin.
  DATA: wa_sgtxt TYPE zfrecon-sgtxt,
        lv_reswk TYPE reswk.

  DATA: sw(1), l_lenght TYPE i, khusus(1),
  l_date LIKE sy-datum, l_date2 LIKE sy-datum,
  l_tax1(5), l_tax2(3), l_tax3(5).
  DATA: lv_length    TYPE i, lv_length_17 TYPE i VALUE 17.

  DATA: lv_subrc TYPE sy-subrc,
        lv_value TYPE string.

  va_ctr = 0.
  CLEAR: i_log_error.
  CONCATENATE pa_gjahr pa_monat '01' INTO l_date.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = l_date
    IMPORTING
      last_day_of_month = l_date2.

  SELECT SINGLE reswk
    FROM zplbc
    INTO lv_reswk
    WHERE bukrs EQ pa_bukrs AND
          werks EQ pa_gsber.

  SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat
         a~waers a~xblnr a~blart a~monat a~bschl a~shkzg
         a~mwskz a~dmbtr a~sgtxt a~zfbdt a~belnr
         b~bktxt b~tcode
         d~lifnr d~zuonr d~gsber a~xref3
         e~stblg a~buzei
         INTO CORRESPONDING FIELDS OF TABLE i_itab4
         FROM  bsis AS a JOIN bkpf AS b ON  a~bukrs EQ b~bukrs AND
                                            a~belnr EQ b~belnr AND
                                            a~gjahr EQ b~gjahr
               LEFT OUTER JOIN  rbkp  AS e ON a~bukrs EQ e~bukrs AND
                                          a~belnr EQ e~belnr AND
                                          a~gjahr EQ e~gjahr

               LEFT OUTER JOIN bsik AS d ON d~bukrs EQ a~bukrs AND
                                      d~belnr EQ a~belnr AND
                                      d~gjahr EQ a~gjahr
         WHERE a~hkont EQ '0142200200'  AND
               a~bukrs EQ pa_bukrs AND
               a~belnr IN so_belnr AND
* TAMBAHAN CHECKING BLART
               a~blart NE 'TR' AND a~blart NE 'NR' AND
               ( a~monat EQ pa_monat OR a~zfbdt < l_date2 ) AND
               a~gjahr <= pa_gjahr AND
* Tambahan Selection Budat
               a~budat <= l_date2.
*                  e~stblg eq space.
*b~stblg ne space
*{   INSERT         P01K910337                                        1
* "SOH: Shell SCI Adjustment 20240222 KRS
  SORT i_itab4 BY bukrs hkont gjahr belnr
                 buzei budat bldat waers dmbtr
                 sgtxt zfbdt.
*}   INSERT
  DELETE ADJACENT DUPLICATES FROM i_itab4
       COMPARING bukrs
                 hkont
                 gjahr
                 belnr
                 buzei
                 budat
                 bldat
                 waers
                 dmbtr
                 sgtxt
                 zfbdt.

  CLEAR wa_itab1.
  LOOP AT i_itab4 INTO wa_itab1.
    IF wa_itab1-stblg NE space.
      CONTINUE.
    ENDIF.
    IF wa_itab1-tcode = 'MR8M' OR wa_itab1-tcode = 'MIRO'
                               OR wa_itab1-tcode = 'MIR7'.
    ENDIF.

    IF wa_itab1-tcode = 'MIRO' OR wa_itab1-tcode = 'MIR7' .
      CONCATENATE wa_itab1-bktxt+6(4)
            wa_itab1-bktxt+3(2)
            wa_itab1-bktxt+0(2) INTO wa_itab1-zfbdt.
      IF wa_itab1-shkzg = 'H'.
        CONTINUE.
      ENDIF.
    ELSE.
      IF lv_reswk IS NOT INITIAL.
        CONCATENATE wa_itab1-bktxt+6(4)
              wa_itab1-bktxt+3(2)
              wa_itab1-bktxt+0(2) INTO wa_itab1-zfbdt.
        IF wa_itab1-shkzg = 'H'.
          CONTINUE.
        ENDIF.
      ENDIF.

      IF wa_itab1-bukrs = '8380'.
        IF wa_itab1-zfbdt IS INITIAL.
          CONCATENATE wa_itab1-bktxt+6(4)
                wa_itab1-bktxt+3(2)
                wa_itab1-bktxt+0(2) INTO wa_itab1-zfbdt.
          IF wa_itab1-shkzg = 'H'.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF wa_itab1-lifnr EQ space.
      SELECT SINGLE lifnr zuonr gsber
         INTO (wa_itab1-lifnr, wa_itab1-zuonr, wa_itab1-gsber)
         FROM bsak
         WHERE bukrs EQ wa_itab1-bukrs AND
               belnr EQ wa_itab1-belnr AND
               gjahr EQ wa_itab1-gjahr.
    ENDIF.

    IF wa_itab1-tcode NE 'MIRO' AND wa_itab1-tcode NE 'MIR7'.
* Tambahan oleh ars untuk get zuonr yang SA
      IF lv_reswk IS INITIAL.
        IF wa_itab1-blart EQ 'SA' OR wa_itab1-blart EQ 'KR'.
          SELECT SINGLE zuonr
             INTO wa_itab1-zuonr
             FROM  bsis
             WHERE hkont EQ '0142200200'  AND
                   bukrs EQ pa_bukrs AND
                   monat EQ wa_itab1-monat AND
*                       gjahr EQ pa_gjahr and
                   gjahr EQ wa_itab1-gjahr AND
                   belnr EQ wa_itab1-belnr AND
                   buzei EQ wa_itab1-buzei.
        ELSE.
          SELECT SINGLE zuonr
          INTO wa_itab1-zuonr
          FROM  bsis
          WHERE hkont EQ '0142200200'  AND
                bukrs EQ pa_bukrs AND
                monat EQ wa_itab1-monat AND
*                       gjahr EQ pa_gjahr and
                gjahr EQ wa_itab1-gjahr AND
                belnr EQ wa_itab1-belnr.

        ENDIF.
      ENDIF.
    ENDIF.

    IF wa_itab1-lifnr EQ space AND wa_itab1-blart EQ 'SA'.
      wa_itab1-name1  = wa_itab1-sgtxt.
      wa_itab1-stcd1  = ' '.
      wa_itab1-stceg  = wa_itab1-xref3.

*              if wa_itab1-tcode ne 'MIRO' and wa_itab1-tcode ne 'MIR7'.
*                  select Single zuonr
*                     into wa_itab1-zuonr
*                     from  bsis
*                     where hkont eq '0142200200'  and
*                           bukrs eq pa_bukrs and
*                           monat eq wa_itab1-monat and
*                           gjahr eq pa_gjahr and
*                           Belnr eq wa_itab1-belnr.
*              Endif.
*dibukapermintaanfunctional
*tambahan permintaan Functional 18-12-2002 untuk validasi BLART = SA
      IF wa_itab1-bukrs EQ '8030'.
        SELECT SINGLE gsber INTO wa_itab1-gsber FROM bsis
        WHERE  bukrs EQ wa_itab1-bukrs AND
               belnr EQ wa_itab1-belnr AND
               zuonr EQ wa_itab1-zuonr.
      ENDIF.
    ELSE.
      SELECT SINGLE stcd1 stceg anred name1 name2 INTO
             (wa_itab1-stcd1,  wa_itab1-stceg,  wa_itab1-anred,
              wa_itab1-name1,  wa_itab1-name2)
           FROM lfa1
           WHERE lifnr EQ wa_itab1-lifnr.
    ENDIF.


    IF wa_itab1-xblnr CP 'SAPF180*'.
      CONTINUE.
    ENDIF.
    CONCATENATE wa_itab1-blart '-' wa_itab1-belnr
              INTO wa_itab1-xblnr.
    CONCATENATE wa_itab1-name1 wa_itab1-name2
              INTO wa_itab1-sgtxt SEPARATED BY space.
    sw = '0'.
************ Validasi Date (1) ******************
    WRITE wa_itab1-zfbdt TO wa_itab1-va_date.
    IF wa_itab1-zfbdt EQ 0.
      CONCATENATE wa_itab1-va_date '*' INTO wa_itab1-va_date
           SEPARATED BY space.
      sw = '1'.
    ENDIF.

    IF wa_itab1-zuonr EQ space OR wa_itab1-zuonr EQ 'D15'.
      SELECT SINGLE zuonr gsber
         INTO (wa_itab1-zuonr, wa_itab1-gsber)
         FROM  bsis
         WHERE hkont EQ '0142200200'  AND
               bukrs EQ pa_bukrs AND
               monat EQ pa_monat AND
               gjahr EQ pa_gjahr AND
               belnr EQ wa_itab1-belnr AND
               zuonr EQ 'D15'.

    ENDIF.
************* Setting default for gsber
    IF pa_bukrs EQ '8010' OR pa_bukrs EQ '8020' OR
      pa_bukrs EQ '8070' OR pa_bukrs = '8380'.
      wa_itab1-gsber = pa_gsber.
    ENDIF.

    IF wa_itab1-gsber NE pa_gsber AND pa_bukrs EQ '8030'.
      CONTINUE.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_itab1-sgtxt
      IMPORTING
        output = wa_itab1-sgtxt.

    SELECT SINGLE sgtxt
      FROM zfrecon INTO wa_sgtxt
      WHERE bukrs EQ wa_itab1-bukrs AND
            sgtxt EQ wa_itab1-sgtxt.
    IF sy-subrc EQ 0.
      khusus = 1.
    ELSE.
      khusus = 0.
    ENDIF.

    IF wa_itab1-zuonr NE 'D15' AND wa_itab1-shkzg NE 'H'
                               AND  sy-subrc NE '0'.
************ Validasi Tax Id (3) ********************
* add by Budi 11/01/2007
      IF wa_itab1-zfbdt GE '20070101'.
        lv_length = strlen( wa_itab1-zuonr ).
        IF lv_length >= lv_length_17.
          "        IF wa_itab1-zfbdt >= gs_coretax-datab.
          lv_value = wa_itab1-zuonr.
          CALL FUNCTION 'ZFTAX_CHECK'
            EXPORTING
              pi_value   = lv_value
              pi_pattern = va_tax_patern2
              pi_length  = 17
            IMPORTING
              pe_subrc   = lv_subrc.
        ELSE.
          WRITE wa_itab1-zuonr TO va_vatpr
                USING EDIT MASK '___.___-__.________'.
          IF va_vatpr CP va_tax_patern1.
            CLEAR lv_subrc.
          ELSE.
            lv_subrc = 4.
          ENDIF.
        ENDIF.

        IF lv_subrc <> 0.
          CONCATENATE  wa_itab1-zuonr '***'
             INTO wa_itab1-va_zuonr  SEPARATED BY space.
          sw  = '1'.
        ENDIF.
        IF wa_itab1-zuonr(2) BETWEEN '01' AND '09'.
        ELSE.
          CONCATENATE  wa_itab1-zuonr '***'
             INTO wa_itab1-va_zuonr  SEPARATED BY space.
          sw  = '1'.
        ENDIF.
        IF wa_itab1-zuonr+2(14) CO '0123456789'.
        ELSE.
          CONCATENATE  wa_itab1-zuonr '***'
             INTO wa_itab1-va_zuonr  SEPARATED BY space.
          sw  = '1'.
        ENDIF.
      ELSE.
* endadd by Budi 11/01/2007
*       wa_itab1-sgtxt ne 'PERTAMINA'.
        CONCATENATE wa_itab1-stcd1 wa_itab1-zuonr
                  INTO wa_itab1-zuonr.
        IF wa_itab1-zuonr CP va_tax_patern.
          WRITE wa_itab1-zuonr+0(5)  TO l_tax1.
          WRITE wa_itab1-zuonr+6(3)  TO l_tax2.
          WRITE wa_itab1-zuonr+10(7) TO l_tax3.
          IF l_tax1 CO 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
          ELSE.
            CONCATENATE  wa_itab1-zuonr '***'
               INTO wa_itab1-va_zuonr  SEPARATED BY space.
            sw  = '1'.
          ENDIF.
          IF l_tax2 CO '0123456789'.
          ELSE.
            CONCATENATE  wa_itab1-zuonr '***'
               INTO wa_itab1-va_zuonr  SEPARATED BY space.
            sw = '1'.
          ENDIF.
          IF l_tax3 CO '0123456789'.
          ELSE.
            CONCATENATE  wa_itab1-zuonr '***'
               INTO wa_itab1-va_zuonr  SEPARATED BY space.
            sw = '1'.
          ENDIF.
        ELSE.
          CONCATENATE  wa_itab1-zuonr '***'
             INTO wa_itab1-va_zuonr  SEPARATED BY space.
          sw = '1'.
        ENDIF.
* add by Budi 11/01/2007
      ENDIF.
* endadd by Budi 11/01/2007
********************** Validasi NPWP (2) *********************
      IF wa_itab1-stceg EQ space.
        CONCATENATE wa_itab1-stceg '**'
            INTO wa_itab1-stceg SEPARATED BY space..
        sw = '1'.
      ENDIF.
*********************** Validasi GSBER (4) ****************
      wa_itab1-va_gsber = wa_itab1-gsber.
      IF wa_itab1-gsber EQ space.
        CONCATENATE wa_itab1-gsber '****' INTO wa_itab1-va_gsber
               SEPARATED BY space.
        sw = '1'.
      ENDIF.
********************** Validasi SGTXT(5)*************
      IF wa_itab1-sgtxt EQ space.
        CONCATENATE wa_itab1-sgtxt '*****'
            INTO wa_itab1-sgtxt SEPARATED BY space..
        sw = '1'.
      ENDIF.
    ENDIF.
    IF sw = '1'.
      ADD 1 TO va_ctr.
      APPEND wa_itab1 TO i_itab1.
    ELSE.
      va_hkont1 = '0142200210'.
      va_hkont2 = '0142200200'.
      IF wa_itab1-zuonr EQ 'D15'.
        va_xref3 = '47'.
      ELSE.

* 26 MAR 2003 (CHECK UNTUK PENGISIAN XREF3)
        CONCATENATE pa_gjahr pa_monat INTO check.
        IF wa_itab1-zfbdt+0(6) <  check.
*                  if wa_itab1-zfbdt+4(2) <  Wa_itab1-budat+4(2).
          va_xref3 = '43'.
        ELSE.
          va_xref3 = '44'.
        ENDIF.
        IF khusus = 1.
          IF va_xref3 = '43'.
            va_xref3 = '50'.
          ELSE.
            va_xref3 = '51'.
          ENDIF.
        ENDIF.
      ENDIF.
      PERFORM f_post_f04.
      CLEAR va_xref3.
      CONTINUE.
    ENDIF.
    CLEAR wa_itab1.
  ENDLOOP.

ENDFORM.                    " f_collect_data_vatin



*&---------------------------------------------------------------------*
*&      Form  f_post_clearing_vat_import
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_clearing_vat_import.
  DATA:  sw(1),l_lenght TYPE i,
  l_date LIKE sy-datum, l_date2 LIKE sy-datum,
  l_tax1(5), l_tax2(3), l_tax3(5).
  CONCATENATE pa_gjahr pa_monat '01' INTO l_date.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = l_date
    IMPORTING
      last_day_of_month = l_date2.

  va_ctr = 0.
  SELECT bukrs hkont gjahr belnr budat bldat xref3
          waers xblnr blart monat bschl shkzg
          mwskz dmbtr sgtxt zfbdt belnr gsber zuonr
          INTO CORRESPONDING FIELDS OF TABLE i_itab5
          FROM  bsis
          WHERE hkont EQ '0142200100'  AND
                bukrs EQ pa_bukrs AND
                belnr IN so_belnr AND
* TAMBAHAN CHECKING BLART
                blart NE 'TR' AND blart NE 'NR' AND
                ( monat EQ pa_monat OR zfbdt < l_date2 ) AND
                gjahr <= pa_gjahr AND
                gsber EQ pa_gsber.
  CLEAR wa_itab1.
  LOOP AT i_itab5 INTO wa_itab1.
    CONCATENATE wa_itab1-blart '-' wa_itab1-belnr
              INTO wa_itab1-xblnr.
    sw = '0'.
********************** Validasi Date (1) **********
    WRITE wa_itab1-zfbdt TO wa_itab1-va_date.
    IF wa_itab1-zfbdt EQ 0.
      CONCATENATE wa_itab1-va_date '*' INTO wa_itab1-va_date
           SEPARATED BY space.
      sw = '1'.
    ENDIF.
***************** Validasi GSBER (4) *****************
    wa_itab1-va_gsber = wa_itab1-gsber.
    IF wa_itab1-gsber EQ space.
      CONCATENATE wa_itab1-gsber '****' INTO wa_itab1-va_gsber
             SEPARATED BY space.
      sw = '1'.
    ENDIF.
*************** Validasi SGTXT (5) ****************
    IF wa_itab1-sgtxt EQ space.
      CONCATENATE wa_itab1-sgtxt '**'
          INTO wa_itab1-sgtxt SEPARATED BY space..
      sw = '1'.
    ENDIF.
************ Validasi Tax Id (3) ********************
    IF pa_bukrs NE '8010'.
      IF wa_itab1-zuonr NE space.
        WRITE wa_itab1-zuonr+0(5)  TO l_tax1.
        WRITE wa_itab1-zuonr+6(7)  TO l_tax2.

        IF l_tax1 EQ 'PIBNO'.
        ELSE.
          CONCATENATE  wa_itab1-zuonr '***'
             INTO wa_itab1-va_zuonr  SEPARATED BY space.
          sw  = '1'.
        ENDIF.
        IF l_tax2 CO '0123456789'.
        ELSE.
          CONCATENATE  wa_itab1-zuonr '***'
             INTO wa_itab1-va_zuonr  SEPARATED BY space.
          sw = '1'.
        ENDIF.
      ELSE.
        CONCATENATE  wa_itab1-zuonr '***'
           INTO wa_itab1-va_zuonr  SEPARATED BY space.
        sw = '1'.
      ENDIF.
    ELSE.
      IF wa_itab1-zuonr NE space.
        WRITE wa_itab1-zuonr+0(5)  TO l_tax1.
        WRITE wa_itab1-zuonr+6(7)  TO l_tax2.

*             if l_tax2 co '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
*             Else.
*                concatenate  wa_itab1-zuonr '***'
*                   into wa_itab1-va_zuonr  separated by space.
*                sw = '1'.
*             Endif.
      ELSE.
        CONCATENATE  wa_itab1-zuonr '***'
           INTO wa_itab1-va_zuonr  SEPARATED BY space.
        sw = '1'.
      ENDIF.
    ENDIF.

* MOVING XREF3 TO STCEG.
    MOVE wa_itab1-xref3 TO wa_itab1-stceg.

    IF sw = '1'.
      ADD 1 TO va_ctr.
      APPEND wa_itab1 TO i_itab3.
      CONTINUE.
    ELSE.
      va_hkont1 = '0142200210'.
      va_hkont2 = '0142200100'.

* 26 MAR 2003 (CHECK UNTUK PENGISIAN XREF3)
      CONCATENATE pa_gjahr pa_monat INTO check.
      IF wa_itab1-zfbdt+0(6) <  check.  "wa_itab1-budat+4(2).
*             if wa_itab1-zfbdt+4(2) <  PA_MONAT.  "wa_itab1-budat+4(2).
        va_xref3 = '41'.
      ELSE.
        va_xref3 = '42'.
      ENDIF.
      PERFORM f_post_f04.
    ENDIF.
    CLEAR wa_itab1.
  ENDLOOP.

ENDFORM.                    " f_post_clearing_vat_import


*&---------------------------------------------------------------------*
*&      Form  f_koreksi_doc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_koreksi_doc.
  DATA: l_title(80), sw(1).

  PERFORM f_init_column.
  DESCRIBE TABLE i_itab1 LINES va_ctr.
  IF va_ctr > 0.
    FORMAT COLOR 5.
    c1 =  w1 + w2 + w3 + w4 + w5 + w6 + w7 + w9 + w10 + 8.
    NEW-PAGE.
    l_title = 'Daftar Document VAT-In Acct. 0142200200  ' .
    CONCATENATE l_title 'yang harus diperbaiki'
       INTO l_title SEPARATED BY space.
    WRITE: AT 2(c1) l_title CENTERED.
    WRITE: / sy-uline.
    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    WRITE AT c1(w1) 'Company' NO-GAP CENTERED. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w2) 'Buss. Area' NO-GAP CENTERED. c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w3) 'Fiscal Year' NO-GAP CENTERED. c1 = c1 + w3.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w4) 'Document No.' NO-GAP CENTERED. c1 = c1 + w4.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w5) 'Vendor No' CENTERED NO-GAP. c1 = c1 + w5.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w6) 'Nama Vendor' CENTERED NO-GAP. c1 = c1 + w6.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w7) 'NPWP Vendor' CENTERED NO-GAP. c1 = c1 + w7.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w9) 'No. Faktur Pajak' CENTERED NO-GAP.
    c1 = c1 + w9.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w10) 'Due Date' CENTERED NO-GAP. c1 = c1 + w10.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    c1 = 1.
    WRITE: / sy-uline.
    va_ctr = 0.
    LOOP AT i_itab1 INTO wa_itab1.
      ADD 1 TO va_ctr.
      sw = va_ctr MOD 2.
      IF sw = 0.
        FORMAT COLOR 2.
        FORMAT INTENSIFIED OFF.
      ELSE.
        FORMAT COLOR 1.
        FORMAT INTENSIFIED OFF.
      ENDIF.

      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      WRITE AT c1(w1) wa_itab1-bukrs NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) wa_itab1-va_gsber NO-GAP. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w3) wa_itab1-gjahr NO-GAP. c1 = c1 + w3.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w4) wa_itab1-belnr NO-GAP. c1 = c1 + w4.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w5) wa_itab1-lifnr NO-GAP. c1 = c1 + w5.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w6) wa_itab1-sgtxt NO-GAP. c1 = c1 + w6.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w7) wa_itab1-stceg NO-GAP. c1 = c1 + w7.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w9) wa_itab1-va_zuonr NO-GAP. c1 = c1 + w9.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w10) wa_itab1-va_date NO-GAP. c1 = c1 + w10.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      HIDE: wa_itab1-belnr, wa_itab1-lifnr.
      c1 = 1.
      CLEAR: wa_itab1.
    ENDLOOP.
    WRITE: / sy-uline.
    SKIP 2.
    FORMAT COLOR OFF.
    NEW-LINE.
    WRITE:  AT 5 'Keterangan' INTENSIFIED ON COLOR 3.
    NEW-LINE.
    WRITE: AT 10(50) '     *      : Due Date tidak lengkap' COLOR 3.
    NEW-LINE.
    WRITE: AT 10(50) '     **     : NPWP    Tidak boleh kosong' COLOR 3.
    NEW-LINE.
    WRITE: AT 10(50)
       '     ***    : No. Faktur Pajak tidak lengkap' COLOR 3.
    NEW-LINE.
    WRITE: AT 10(50)
         '     ****   : Bussiness Area  Tidak boleh Kosong' COLOR 3.
    NEW-LINE.
    WRITE: AT 10(50)
         '     *****  : SGTXT   Tidak boleh Kosong' COLOR 3.
    SKIP 5.
  ENDIF.
  DESCRIBE TABLE i_itab3 LINES va_ctr.
  IF va_ctr > 0.
  ELSE.
    EXIT.
  ENDIF.
  FORMAT COLOR 5.
  SKIP 2.
  c1 =  w1 + w2 + w3 + w4 + w5 + w6 + w7 + w9 + w10 + 8.
  NEW-PAGE.
  l_title = 'Daftar Document VAT-In Acct. 0142200100  ' .
  CONCATENATE l_title 'yang harus diperbaiki'
     INTO l_title SEPARATED BY space.
  WRITE: AT 2(c1) l_title CENTERED.
  WRITE: / sy-uline.
  c1 = 1.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  WRITE AT c1(w1) 'Company' NO-GAP CENTERED. c1 = c1 + w1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w2) 'Buss. Area' NO-GAP CENTERED. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'Fiscal Year' NO-GAP CENTERED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w4) 'Document No.' NO-GAP CENTERED. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w9) 'No. Faktur Pajak' NO-GAP CENTERED.
  c1 = c1 + w9.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w10) 'Due Date' NO-GAP. c1 = c1 + w10.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 1.
  WRITE: / sy-uline.
  va_ctr = 0.
  LOOP AT i_itab3 INTO wa_itab1.
    ADD 1 TO va_ctr.
    sw = va_ctr MOD 2.
    IF sw = 0.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED OFF.
    ELSE.
      FORMAT COLOR 1.
      FORMAT INTENSIFIED OFF.
    ENDIF.
    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    WRITE AT c1(w1) wa_itab1-bukrs NO-GAP. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w2) wa_itab1-va_gsber NO-GAP. c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w3) wa_itab1-gjahr NO-GAP. c1 = c1 + w3.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w4) wa_itab1-belnr NO-GAP. c1 = c1 + w4.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w9) wa_itab1-va_zuonr NO-GAP. c1 = c1 + w9.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w10) wa_itab1-va_date NO-GAP. c1 = c1 + w10.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    HIDE: wa_itab1-belnr, wa_itab1-lifnr.
    c1 = 1.
    CLEAR: wa_itab1.
  ENDLOOP.

  FORMAT COLOR 3.
  WRITE: / sy-uline.
  SKIP 2.
  NEW-LINE.
  WRITE:  AT 5 'Keterangan' INTENSIFIED ON.
  NEW-LINE.
  WRITE: AT 10(50) '     *      : Due Date tidak lengkap' COLOR 3.
  NEW-LINE.
  WRITE: AT 10(50)
     '     ***    : No. Faktur Pajak tidak lengkap' COLOR 3.
  NEW-LINE.
  WRITE: AT 10(50)
       '     ****   : Bussiness Area  Tidak boleh Kosong' COLOR 3.
  NEW-LINE.
  WRITE: AT 10(50)
       '     *****  : SGTXT   Tidak boleh Kosong' COLOR 3.
  SKIP 5.
  CLEAR i_itab1.


ENDFORM.                    " f_koreksi_doc

*&---------------------------------------------------------------------*
*&      Form  f_proses_vatout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_vatout.
  DATA: l_line1 TYPE i, l_line2 TYPE i.
  CLEAR: i_itab1, i_itab2, i_itab3, i_itab4, i_itab5,
         wa_itab1, wa_itab2.
  IF pa_bukrs EQ '8010'.
    PERFORM f_get_data_vatout.
  ENDIF.
  IF pa_bukrs NE '8010'.
    PERFORM f_post_credit_memo.
    PERFORM f_post_zfvato.
  ENDIF.
  DESCRIBE TABLE i_itab1      LINES l_line1.
  DESCRIBE TABLE i_zfvato_err LINES l_line2.
  IF l_line1 > 0 OR l_line2 > 0.
    it_message-text = 'Koreksi Data'.
    APPEND it_message.
    it_message-text = 'Pilih Cancel untuk Kembali Menu awal'.
    APPEND it_message.
    it_message-text = 'Pilih Continue untuk Koreksi Data'.
    APPEND it_message.
    CALL FUNCTION 'DD_POPUP_WITH_INFOTEXT'
      EXPORTING
        titel        = 'Koreksi Data'
        start_column = 1
        start_row    = 1
        end_row      = 5
      IMPORTING
        answer       = va_answer
      TABLES
        lines        = it_message
      EXCEPTIONS
        OTHERS       = 1.
    IF va_answer NE 'Y'.
      EXIT.
    ENDIF.

    PERFORM f_koreksi_vatout.
  ENDIF.
ENDFORM.                    " f_proses_vatout

*&---------------------------------------------------------------------*
*&      Form  f_get_data_vatout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data_vatout.
  DATA: sw(1), l_lenght TYPE i,
  l_tax1(5), l_tax2(3), l_tax3(5).
  va_ctr = 0.
  SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat
         a~waers a~xblnr a~blart a~monat a~bschl a~shkzg
         a~mwskz a~dmbtr a~sgtxt a~zfbdt
         a~belnr b~bktxt
         d~kunnr d~zuonr d~gsber
         INTO CORRESPONDING FIELDS OF TABLE i_itab3
         FROM    ( bsis AS a JOIN bkpf AS b ON
                                            a~bukrs EQ b~bukrs AND
                                            a~belnr EQ b~belnr AND
                                            a~gjahr EQ b~gjahr )
               LEFT OUTER JOIN bsid AS d ON d~bukrs EQ a~bukrs AND
                                      d~belnr EQ a~belnr AND
                                      d~gjahr EQ a~gjahr
         WHERE a~hkont EQ '0315300100'  AND
               a~bukrs EQ pa_bukrs AND
* TAMBAHAN CHECKING BLART
               a~blart NE 'TR' AND
               ( a~monat EQ pa_monat OR a~zfbdt < sy-datum ) AND
               a~gjahr EQ pa_gjahr.

  CLEAR wa_itab1.
  LOOP AT i_itab3 INTO wa_itab1.
    IF wa_itab1-kunnr EQ space.
      SELECT SINGLE kunnr zuonr gsber
         INTO (wa_itab1-kunnr, wa_itab1-zuonr, wa_itab1-gsber)
         FROM bsad
         WHERE bukrs EQ wa_itab1-bukrs AND
               belnr EQ wa_itab1-belnr AND
               gjahr EQ wa_itab1-gjahr.
    ENDIF.
    SELECT SINGLE stcd1 stceg anred name1 name2 gform cityc INTO
             (wa_itab1-stcd1,  wa_itab1-stceg,  wa_itab1-anred,
              wa_itab1-name1,  wa_itab1-name2, wa_itab1-gform,
              wa_itab1-cityc)
           FROM kna1
           WHERE kunnr EQ wa_itab1-kunnr.

******** Validasi for Pemakaian Sendiri by Patris 201202 change by Didik
    IF wa_itab1-blart EQ 'SA'.
      wa_itab1-gform = 'A1'.
      wa_itab1-cityc = 'T2'.
      wa_itab1-stcd1 = space.
      SELECT SINGLE zuonr sgtxt xref3 gsber
        INTO (wa_itab1-zuonr, wa_itab1-name1, wa_itab1-stceg,
              wa_itab1-gsber)
        FROM bsis
        WHERE bukrs EQ pa_bukrs AND
              belnr EQ wa_itab1-belnr AND
              gjahr EQ pa_gjahr AND
              hkont EQ '0315300100'.
    ENDIF.

*          if wa_itab1-gsber ne pa_gsber.
*             continue.
*          Endif.
    sw = '0'.
***************** Validasi FORM A1 / A3 (7) ************************
*          if wa_itab1-gform ne 'A1' and wa_itab1-gform ne 'A3'.
    IF wa_zfvato-gform EQ 'A5'.
      CONCATENATE wa_itab1-gform '*******'
         INTO wa_itab1-va_gform  SEPARATED BY space.
      sw = '1'.
    ENDIF.
***************** Validasi FORM T1 /T0 (5) ****************************
    wa_itab1-va_cityc = wa_itab1-cityc.
    IF wa_itab1-cityc NE 'T0' AND
       wa_itab1-cityc NE 'T1' AND
       wa_itab1-cityc NE 'T2' AND
       wa_itab1-cityc NE 'T3'.
      CONCATENATE wa_itab1-cityc '*****'
         INTO wa_itab1-va_cityc  SEPARATED BY space.
      sw = '1'.
    ENDIF.

    CONCATENATE wa_itab1-blart '-' wa_itab1-belnr
              INTO wa_itab1-xblnr.
    MOVE wa_itab1-name1 TO wa_itab1-sgtxt.
    CONCATENATE wa_itab1-stcd1 wa_itab1-zuonr
              INTO wa_itab1-zuonr.

*********************** Validasi NPWP STCEG (2) ************************
    IF wa_itab1-stceg EQ space AND wa_itab1-cityc NE 'T0'.
      CONCATENATE wa_itab1-stceg '**'
          INTO wa_itab1-stceg SEPARATED BY space..
      sw = '1'.
    ENDIF.

** Validasi for Company 8010, Customer SL0000001 ************
** by Patris 201202 change by Didik
    IF wa_itab1-kunnr EQ 'SL00000001'.
      wa_itab1-gform = 'A1'.
      wa_itab1-cityc = 'T0'.
      sw = '0'.
      SELECT SINGLE name1
        FROM bsec
        INTO wa_itab1-name1
        WHERE bukrs EQ pa_bukrs AND
              belnr EQ wa_itab1-belnr AND
              gjahr EQ pa_gjahr.

      SELECT SINGLE zuonr
        INTO wa_itab1-zuonr
        FROM bsis
        WHERE bukrs EQ pa_bukrs AND
              belnr EQ wa_itab1-belnr AND
              gjahr EQ pa_gjahr AND
              hkont EQ '0315300100'.
    ENDIF.


*********************** Validasi Date ZFBDT (1) ************************
    WRITE wa_itab1-zfbdt TO wa_itab1-va_date.
    IF wa_itab1-zfbdt EQ 0.
      CONCATENATE wa_itab1-va_date '*' INTO wa_itab1-va_date
           SEPARATED BY space.
      sw = '1'.
    ENDIF.
*********************** Validasi VAT-No ZUONR (3) **********************
    IF wa_itab1-zuonr  EQ space.
      CONCATENATE  wa_itab1-zuonr '***'
            INTO wa_itab1-va_zuonr  SEPARATED BY space.
      sw = '1'.
    ENDIF.
******************** Validasi Bussniss Area GSBER (4) ******************
    wa_itab1-va_gsber = wa_itab1-gsber.
    IF wa_itab1-gsber EQ space.
      CONCATENATE wa_itab1-gsber '****' INTO wa_itab1-va_gsber
             SEPARATED BY space.
      sw = '1'.
    ENDIF.
    IF wa_itab1-sgtxt EQ space.
      sw = '1'.
    ENDIF.
    IF sw = '1'.
      ADD 1 TO va_ctr.
      APPEND wa_itab1 TO i_itab1.
    ELSE.
      MOVE wa_itab1-zfbdt+4(2) TO bulan.
      IF pa_bukrs EQ '8070'.
        CONCATENATE wa_itab1-cityc wa_itab1-gform bulan pa_gsber
            INTO va_xref3 SEPARATED BY '|'.
      ELSE.
        CONCATENATE wa_itab1-cityc wa_itab1-gform bulan
            INTO va_xref3 SEPARATED BY '|'.
      ENDIF.
      va_hkont1 = '0315300200'.
      va_hkont2 = '0315300100'.
      wa_itab1-gsber = pa_gsber.
*               va_xref3  = '
      PERFORM f_post_f04.
    ENDIF.

    CLEAR wa_itab1.
  ENDLOOP.
ENDFORM.                    " f_get_data_vatout
*&---------------------------------------------------------------------*
*&      Form  f_post_zfvato
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_zfvato.
  DATA: l_value(15),
        l_date(10),
        l_date1(10),
        l_mess(50),
        l_monat(2),
        l_year(4),
        sw(1),
        l_tax1(5), l_tax2(3), l_tax3(5).

  DATA: va_adrnr LIKE kna1-adrnr.

  DATA: lv_subrc     TYPE sy-subrc,
        lv_value     TYPE string,
        lv_notax(20).
  DATA: lv_length    TYPE i, lv_length_17 TYPE i VALUE 17.

* Koreksi selection for FKDAT (01-04-2003).
  CONCATENATE pa_gjahr pa_monat '01' INTO ta_date-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ta_date-low
    IMPORTING
      last_day_of_month = ta_date-high.
  ta_date-high = ta_date-high + 1.
  APPEND ta_date.

  CLEAR: i_zfvato_err, i_zfvato, wa_zfvato.
  IF pa_bukrs EQ '8020' OR pa_bukrs = '8380'.
    SELECT budat cityc dudat fkdat gjahr gsber gsber zuonr
           kunrg mwsbk name_co stceg vatno vatpr vbeln vkbur
           vkorg vtart
       INTO CORRESPONDING FIELDS OF TABLE i_zfvato
       FROM zfvato
       WHERE vkorg EQ pa_bukrs AND
             vbeln IN so_belnr AND
             ( duemm EQ pa_monat OR fkdat < ta_date-high ) AND
*                ( duemm eq pa_monat or FKDAT < sy-datum ) and
*                ( FLAG1 eq space or FLAG1 eq 'L' ).
             ( st_post EQ space ) AND
             fl_cancel EQ space.
  ELSEIF pa_bukrs EQ '8070'.
    SELECT budat cityc dudat fkdat gjahr gsber gsber zuonr
           kunrg mwsbk name_co stceg vatno vatpr vbeln vkbur
           vkorg vtart vkbur
       INTO CORRESPONDING FIELDS OF TABLE i_zfvato
       FROM zfvato
       WHERE vkorg EQ pa_bukrs AND
             vkbur EQ pa_gsber AND
             vbeln IN so_belnr AND
             ( duemm EQ pa_monat OR fkdat < ta_date-high ) AND
*                ( duemm eq pa_monat or FKDAT < sy-datum ) and
*                ( FLAG1 eq space or FLAG1 eq 'L' ).
             ( st_post EQ space ) AND
             fl_cancel EQ space.
  ELSE.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE i_zfvato
       FROM zfvato
       WHERE vkorg EQ pa_bukrs AND
             vkbur EQ pa_gsber AND
             vbeln IN so_belnr AND
             ( duemm EQ pa_monat OR fkdat < ta_date-high ) AND
*                ( duemm eq pa_monat or FKDAT < sy-datum ) and
             ( st_post EQ space ) AND
             fl_cancel EQ space.
  ENDIF.
  CLEAR wa_zfvato.
  LOOP AT i_zfvato INTO wa_zfvato.
* DELETING KNA1
    SELECT SINGLE gform INTO wa_zfvato-gform
           FROM kna1 WHERE kunnr EQ wa_zfvato-kunrg.
* END DELETING

* INSERT 16-04-2003
*        select single gform ADRNR
*        into (wa_zfvato-gform, VA_ADRNR)
*               from kna1 where kunnr eq wa_zfvato-kunrg.
*        SELECT SINGLE NAME_CO FROM ADRC
*          INTO WA_ZFVATO-NAME_CO
*          WHERE ADDRNUMBER EQ VA_ADRNR.
* END INSERT

    WRITE pa_monat TO l_monat.
    IF l_monat EQ 0.
      WRITE sy-datum+4(2) TO l_monat.
    ENDIF.

    WRITE wa_zfvato-dudat TO l_date.
    WRITE wa_zfvato-fkdat TO l_date1.
    l_value = wa_zfvato-mwsbk * 100.
    sw = 0.
***************** Validasi FORM T1 /T0 (5) ****************************
    wa_zfvato-va_cityc = wa_zfvato-cityc.
    IF wa_zfvato-cityc NE 'T0' AND wa_zfvato-cityc NE 'T1' AND
       wa_zfvato-cityc NE 'T2' AND wa_zfvato-cityc NE 'T3'.
      CONCATENATE wa_zfvato-cityc '*****'
         INTO wa_zfvato-va_cityc  SEPARATED BY space.
      sw = '1'.
    ENDIF.
***************** Validasi FORM A1 / A3 (7) ****************************
*          if wa_zfvato-gform ne 'A1' and wa_zfvato-gform ne 'A3'
*                                     and wa_zfvato-gform ne 'A2'.
    IF wa_zfvato-gform EQ 'A5'.
      CONCATENATE wa_zfvato-gform '*******'
         INTO wa_zfvato-va_gform  SEPARATED BY space.
      sw = '1'.
    ENDIF.
***************** Validasi Date DUDAT (1) ************************
    WRITE wa_zfvato-dudat TO wa_zfvato-va_date.
    IF wa_zfvato-dudat EQ 0.
      CONCATENATE wa_zfvato-va_date '*' INTO wa_zfvato-va_date
           SEPARATED BY space.
      sw = '1'.
    ENDIF.
***************** Validasi Buss. Area GSBER (4) ************************
    IF pa_bukrs EQ '8070'.
      IF wa_zfvato-gsber IS INITIAL.
        wa_zfvato-gsber = wa_zfvato-vkbur.
      ENDIF.
    ELSEIF pa_bukrs EQ '8020' OR pa_bukrs = '8380'.
      wa_zfvato-va_gsber = wa_itab1-gsber.
    ENDIF.
    IF wa_zfvato-gsber EQ space.
      CONCATENATE wa_zfvato-gsber '****' INTO wa_zfvato-va_gsber
             SEPARATED BY space.
      sw = '1'.
    ENDIF.
***************** Validasi NPWP STCEG (2) ************************
    IF wa_zfvato-stceg EQ space AND wa_zfvato-cityc NE 'T0'.
      CONCATENATE wa_zfvato-stceg '**'
          INTO wa_zfvato-stceg SEPARATED BY space..
      sw = '1'.
    ENDIF.
***************** Validasi Nama Customer Name1 (6) *********************
    IF wa_zfvato-name_co EQ space.
      CONCATENATE wa_zfvato-name_co '******'
          INTO wa_zfvato-name_co SEPARATED BY space.
      sw = '1'.
    ENDIF.
**************** Validasi Nama Customer Tax Id (3) *********************
* Revisi by Budi 05/05/2010
*       if wa_zfvato-cityc ne 'T0'.
    IF wa_zfvato-cityc EQ 'T0' OR wa_zfvato-cityc EQ 'T1' OR
       wa_zfvato-cityc EQ 'T2' OR wa_zfvato-cityc EQ 'T3'.
* End Revisi by Budi 05/05/2010
* add by Budi 11/01/2007
      lv_value = wa_zfvato-vatpr.
      TRANSLATE lv_value USING '- '.
      TRANSLATE lv_value USING '. '.
      CONDENSE lv_value NO-GAPS.
      lv_length = strlen( lv_value ).
      IF wa_zfvato-dudat GE '20070101'.
        IF lv_length >= lv_length_17.
          "        IF wa_zfvato-dudat >= gs_coretax-datab.
          lv_value = wa_zfvato-vatpr.
          CALL FUNCTION 'ZFTAX_CHECK'
            EXPORTING
              pi_value   = lv_value
              pi_pattern = va_tax_patern2
              pi_length  = 17
            IMPORTING
              pe_subrc   = lv_subrc.
          IF lv_subrc <> 0.
            CONCATENATE  wa_zfvato-vatpr '***'
              INTO wa_zfvato-va_zuonr  SEPARATED BY space.
            sw  = '1'.
          ENDIF.
        ELSE.
          IF wa_zfvato-vatpr CP va_tax_patern1.
            REPLACE '.' WITH ' ' INTO wa_zfvato-vatpr.
            REPLACE '-' WITH ' ' INTO wa_zfvato-vatpr.
            REPLACE '.' WITH ' ' INTO wa_zfvato-vatpr.
            CONDENSE wa_zfvato-vatpr NO-GAPS.
          ELSE.
            CONCATENATE  wa_zfvato-vatpr '***' INTO wa_zfvato-va_zuonr
                   SEPARATED BY space.
            sw = '1'.
          ENDIF.
        ENDIF.
      ELSE.
* endadd by Budi 11/01/2007
        CONCATENATE wa_zfvato-vatpr+0(10) wa_zfvato-vatpr+11(7)
          INTO wa_zfvato-vatpr.

        IF wa_zfvato-vatpr CP va_tax_patern.
          WRITE wa_zfvato-vatpr+0(5)  TO l_tax1.
          WRITE wa_zfvato-vatpr+6(3)  TO l_tax2.
          WRITE wa_zfvato-vatpr+10(7) TO l_tax3.
          IF l_tax1 CO 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
          ELSE.
            CONCATENATE  wa_zfvato-vatpr '***'
              INTO wa_zfvato-va_zuonr  SEPARATED BY space.
            sw  = '1'.
          ENDIF.
          IF l_tax2 CO '0123456789'.
          ELSE.
            CONCATENATE  wa_zfvato-vatpr '***'
              INTO wa_zfvato-va_zuonr  SEPARATED BY space.
            sw = '1'.
          ENDIF.
          IF l_tax3 CO '0123456789'.
          ELSE.
            CONCATENATE  wa_zfvato-vatpr '***'
              INTO wa_zfvato-va_zuonr  SEPARATED BY space.
            sw = '1'.
          ENDIF.
        ELSE.
          CONCATENATE  wa_zfvato-vatpr '***' INTO wa_zfvato-va_zuonr
                 SEPARATED BY space.
          sw = '1'.
        ENDIF.
* add by Budi 11/01/2007
      ENDIF.
* endadd by Budi 11/01/2007
    ENDIF.
    IF sw EQ '1'.
      ADD 1 TO va_ctr.
      APPEND wa_zfvato TO i_zfvato_err.
      CONTINUE.
    ENDIF.
    CLEAR i_bdc.
*        if wa_zfvato-VTART = 'FI'.
*            wa_zfvato-ZUONR = wa_zfvato-VBELN.
*        Endif.
*        if pa_bukrs eq '8020'.
*           wa_zfvato-gform = 'A1'.
*        endif.
    wa_zfvato-budat = sy-datum.
    MOVE l_date+3(2) TO bulan.
    IF pa_bukrs EQ '8020' OR pa_bukrs = '8380'.
      IF wa_zfvato-gform EQ 'A3' OR
        wa_zfvato-gform EQ 'A4'.
        CONCATENATE wa_zfvato-cityc 'A1' bulan
        INTO va_xref3 SEPARATED BY '|'.
      ELSE.
        CONCATENATE wa_zfvato-cityc wa_zfvato-gform bulan
        INTO va_xref3 SEPARATED BY '|'.
      ENDIF.
*          concatenate wa_zfvato-cityc wa_zfvato-gform bulan
*               into va_xref3 separated by '|'.
    ELSEIF pa_bukrs EQ '8070'.
      IF wa_zfvato-gform EQ 'A3' OR
        wa_zfvato-gform EQ 'A4'.
        CONCATENATE wa_zfvato-cityc 'A1' bulan pa_gsber
        INTO va_xref3 SEPARATED BY '|'.
      ELSE.
        CONCATENATE wa_zfvato-cityc wa_zfvato-gform bulan pa_gsber
        INTO va_xref3 SEPARATED BY '|'.
      ENDIF.
    ELSEIF pa_bukrs EQ '8030'.
      CONCATENATE wa_zfvato-cityc wa_zfvato-gform bulan pa_gsber
           INTO va_xref3 SEPARATED BY '|'.
    ENDIF.

    PERFORM f_dynpro USING:
         'X'  'SAPMF05A'     '0122',
         ' '  'BDC_OKCODE'    '=SL',
         ' '  'BKPF-BLDAT'   l_date,
         ' '  'BKPF-BUDAT'   l_date1.
    IF wa_zfvato-vtart = 'FI'.
      PERFORM f_dynpro USING:
           ' '  'BKPF-XBLNR'   wa_zfvato-vbeln.
    ELSE.
      PERFORM f_dynpro USING:
           ' '  'BKPF-XBLNR'   wa_zfvato-zuonr.
    ENDIF.
    PERFORM f_dynpro USING:
         ' '  'BKPF-BLART'   'TR',
         ' '  'BKPF-BUKRS'   pa_bukrs,
         ' '  'BKPF-MONAT'    l_monat,
         ' '  'BKPF-WAERS'   'IDR',
         ' '  'BKPF-BKTXT'   wa_zfvato-stceg,
         ' '  'RF05A-NEWBS'   '50',
         ' '  'RF05A-NEWKO'  '0315300200',
         ' '  'RF05A-XPOS1(02)' ' ',
         ' '  'RF05A-XPOS1(04)' 'X',

         'X'  'SAPMF05A'     '0300',
         ' '  'BDC_OKCODE'    '=SL',
         ' '  'BSEG-WRBTR'   l_value,
*             ' '  'BSEG-ZFBDT'   l_date,
         ' '  'BSEG-ZUONR'   wa_zfvato-vatpr,
         ' '  'BSEG-SGTXT'   wa_zfvato-name_co,
         ' '  'BDC_OKCODE'   '=ZK',

         'X'  'SAPLKACB'     '0002',
         ' '  'BDC_OKCODE'   '=ENTE',
         ' '  'COBL-GSBER'   wa_zfvato-gsber,

         'X'  'SAPMF05A'     '0330',
         ' '  'BDC_OKCODE'   '/00',
         ' '  'BSEG-XREF3'   va_xref3,
         ' '  'BDC_OKCODE'   '=PA',

         'X'  'SAPMF05A'     '0710',
         ' '  'BDC_OKCODE'   '/5',
         ' '  'RF05A-AGBUK'  pa_bukrs,
         ' '  'RF05A-AGKON'  '0315300100',
         ' '  'RF05A-AGKOA'     'S',
         ' '  'RF05A-XAUTS'     'X',

         'X'  'SAPMF05A'       '0733',
         ' '  'RF05A-FELDN(1)' 'BELNR',
         ' '  'RF05A-SEL01(1)' wa_zfvato-vbeln,
         ' '  'BDC_OKCODE'     '=BU'.
    CALL TRANSACTION 'F-04' USING i_bdc MODE va_mode UPDATE 'S'
                  MESSAGES INTO i_messtab.

    IF sy-subrc NE 0.
*DELETE MESSAGE 17/04/2003
*           Loop at i_messtab into wa_messtab.
*             if wa_messtab-MSGTYP = 'E'.
**              read table i_messtab into wa_messtab index 1.
*               CALL FUNCTION 'FORMAT_MESSAGE'
*                  EXPORTING
*                     ID       = wa_MESSTAB-MSGID
*                     LANG     = wa_MESSTAB-MSGSPRA
*                     NO       = wa_MESSTAB-MSGNR
*                     V1       = wa_MESSTAB-MSGV1
*                     V2       = wa_MESSTAB-MSGV2
*                     V3       = wa_MESSTAB-MSGV3
*                     V4       = wa_MESSTAB-MSGV4
*                  IMPORTING
*                     MSG      = wa_log_error-MSG.
*
*                wa_log_error-hkont =    '0315300100'.
*                wa_log_error-bukrs = pa_bukrs.
*                wa_log_error-gjahr = pa_gjahr.
*                wa_log_error-belnr = wa_zfvato-VBELN.
*                append wa_log_error to i_log_error.
*              endif.
*            endloop.
*END DELETE

*INSERT NEW MESSAGE.
      wa_log_error-bukrs = pa_bukrs.
      wa_log_error-gjahr = pa_gjahr.
      wa_log_error-belnr = wa_zfvato-vbeln.
      wa_log_error-msg =
     'Recon tidak sukses, Check amount tax atau status posting di ZFVATO'.
      APPEND wa_log_error TO i_log_error.

*END INSERT.
*            write: / 'Message Error : ', wa_log_error-MSG.
*            message e001(zs) with wa_log_error-MSG.
    ELSE.
      UPDATE zfvato SET st_post = 'X'
                WHERE vkorg EQ wa_zfvato-vkorg AND
                      vkbur EQ wa_zfvato-vkbur AND
                      vatno EQ wa_zfvato-vatno AND
                      vbeln EQ wa_zfvato-vbeln AND
                      zuonr EQ wa_zfvato-zuonr.
    ENDIF.
    CLEAR wa_zfvato.
  ENDLOOP.
ENDFORM.                    " f_post_zfvato
*&---------------------------------------------------------------------*
*&      Form  f_post_credit_memo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_credit_memo.
  DATA:l_adrnr LIKE kna1-adrnr.
  DATA: sw(1), l_lenght TYPE i,
  l_tax1(5), l_tax2(3), l_tax3(5).
  va_ctr = 0.
  CLEAR i_itab1.

  SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat
         a~waers a~xblnr a~blart a~monat a~bschl a~shkzg
         a~mwskz a~dmbtr a~sgtxt a~zfbdt
         a~belnr b~bktxt
         d~kunnr d~zuonr d~gsber
         INTO CORRESPONDING FIELDS OF TABLE i_itab3
         FROM    ( bsis AS a JOIN bkpf AS b ON
                                            a~bukrs EQ b~bukrs AND
                                            a~belnr EQ b~belnr AND
                                            a~gjahr EQ b~gjahr )
               LEFT OUTER JOIN bsad AS d ON d~bukrs EQ a~bukrs AND
                                      d~belnr EQ a~belnr AND
                                      d~gjahr EQ a~gjahr
         WHERE a~hkont EQ '0315300100'  AND
               a~bukrs EQ pa_bukrs AND
* TAMBAHAN CHECKING BLART
               a~blart NE 'TR' AND
               ( a~monat EQ pa_monat OR a~zfbdt < sy-datum ) AND
               a~gjahr EQ pa_gjahr AND
               a~shkzg EQ 'S'      AND
               a~belnr IN so_belnr.

  CLEAR wa_itab1.
  LOOP AT i_itab3 INTO wa_itab1.

    IF wa_itab1-kunnr EQ space.
      SELECT SINGLE kunnr zuonr gsber
         INTO (wa_itab1-kunnr, wa_itab1-zuonr, wa_itab1-gsber)
         FROM bsid
         WHERE bukrs EQ wa_itab1-bukrs AND
               belnr EQ wa_itab1-belnr AND
               gjahr EQ wa_itab1-gjahr.
    ENDIF.
    wa_itab1-zfbdt = wa_itab1-budat.
    SELECT SINGLE stcd1 stceg anred gform cityc adrnr "name1 name2
         INTO (wa_itab1-stcd1,  wa_itab1-stceg,  wa_itab1-anred,
              wa_itab1-gform, wa_itab1-cityc, l_adrnr)
*                   wa_itab1-name1,  wa_itab1-name2,
           FROM kna1
           WHERE kunnr EQ wa_itab1-kunnr.

    SELECT SINGLE name_co
      FROM adrc
      INTO wa_itab1-name1
      WHERE addrnumber = l_adrnr.

    IF wa_itab1-gsber NE pa_gsber.
      CONTINUE.
    ENDIF.
    IF wa_itab1-xblnr CP 'SAPF180*'.
      CONTINUE.
    ENDIF.
    CONCATENATE wa_itab1-blart '-' wa_itab1-belnr
              INTO wa_itab1-xblnr.
    MOVE wa_itab1-name1 "wa_itab1-name2
              TO wa_itab1-sgtxt. " separated by space.
    CONCATENATE 'CN' wa_itab1-zuonr
              INTO wa_itab1-zuonr.
    sw = '0'.
***************** Validasi FORM T1 /T0 (5) ****************************
    wa_itab1-va_cityc = wa_itab1-cityc.
    IF wa_itab1-cityc NE 'T0' AND wa_itab1-cityc NE 'T1' AND
       wa_itab1-cityc NE 'T2' AND wa_itab1-cityc NE 'T3'.
      CONCATENATE wa_itab1-cityc '*****'
         INTO wa_itab1-va_cityc  SEPARATED BY space.
      sw = '1'.
    ENDIF.
***************** Validasi FORM A1 / A3 (7) ****************************
*          if wa_itab1-gform ne 'A1' and wa_itab1-gform ne 'A3'
*                                    and wa_itab1-gform ne 'A2'.
    IF wa_zfvato-gform EQ 'A5'.
      CONCATENATE wa_itab1-gform '*******'
         INTO wa_itab1-va_gform  SEPARATED BY space.
      sw = '1'.
    ENDIF.
******************* Validasi ZFBDT (1) *******************
    WRITE wa_itab1-zfbdt TO wa_itab1-va_date.
    IF wa_itab1-zfbdt EQ 0.
      CONCATENATE wa_itab1-va_date '*' INTO wa_itab1-va_date
           SEPARATED BY space.
      sw = '1'.
    ENDIF.
******************* Validasi NPWP (2) ***************************
    IF wa_itab1-stceg EQ space AND wa_itab1-cityc NE 'T0'.
      CONCATENATE wa_itab1-stceg '**'
          INTO wa_itab1-stceg SEPARATED BY space..
      sw = '1'.
    ENDIF.
********************** Validasi GSBER (4) ******************
    wa_itab1-zuonr = wa_itab1-belnr.
    wa_itab1-va_gsber = wa_itab1-gsber.
    IF wa_itab1-gsber EQ space.
      CONCATENATE wa_itab1-gsber '****' INTO wa_itab1-va_gsber
             SEPARATED BY space.
      sw = '1'.
    ENDIF.
********************** Validasi SGTXT (5) ******************
    IF wa_itab1-sgtxt EQ space.
      CONCATENATE wa_itab1-sgtxt '*****' INTO wa_itab1-sgtxt
             SEPARATED BY space.
      sw = '1'.
    ENDIF.

    IF sw = '1'.
      ADD 1 TO va_ctr.
      APPEND wa_itab1 TO i_itab1.
    ELSE.
      MOVE wa_itab1-zfbdt+4(2) TO bulan.
      IF pa_bukrs EQ '8020' OR pa_bukrs = '8380'.
*                if wa_itab1-gform eq 'A3' or
*                  wa_itab1-gform eq 'A4'.
*                  concatenate wa_itab1-cityc 'A1' bulan
*                  into va_xref3 separated by '|'.
*                else.
*                  concatenate wa_itab1-cityc wa_itab1-gform bulan
*                  into va_xref3 separated by '|'.
*                endif.
* penambahan untuk nota retur
        CONCATENATE 'XX' bulan pa_gjahr
        INTO va_xref3 SEPARATED BY '|'.
* end  penambahan
*                concatenate wa_itab1-cityc wa_itab1-gform bulan
*                     into va_xref3 separated by '|'.
      ELSEIF pa_bukrs EQ '8070'.
        CONCATENATE 'XX' bulan pa_gjahr pa_gsber
        INTO va_xref3 SEPARATED BY '|'.
      ELSEIF pa_bukrs EQ '8030'.
        CONCATENATE wa_itab1-cityc wa_itab1-gform bulan pa_gsber
             INTO va_xref3 SEPARATED BY '|'.
      ENDIF.
      va_hkont1 = '0315300200'.
      va_hkont2 = '0315300100'.

      PERFORM f_post_f04.
    ENDIF.
    CLEAR wa_itab1.
  ENDLOOP.
ENDFORM.                    " f_get_data_credit_memo

*&---------------------------------------------------------------------*
*&      Form  f_post_f04
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_f04.
  DATA: l_value(15),
        l_date(10),
        l_date1(10),
        l_mess(50),
        l_monat(2),
        l_year(4).

  DATA: v_len       TYPE i,
        l_belnr(10).

  WRITE pa_monat TO l_monat.
  IF l_monat EQ 0.
    WRITE sy-datum+4(2) TO l_monat.
  ENDIF.
  WRITE wa_itab1-zfbdt TO l_date.
  WRITE wa_itab1-budat TO l_date1.
  l_value = wa_itab1-dmbtr * 100.

  CLEAR i_bdc.
  PERFORM f_dynpro USING:
        'X'  'SAPMF05A'     '0122',
        ' '  'BDC_OKCODE'    '=SL',
        ' '  'BKPF-BLDAT'   l_date,
        ' '  'BKPF-BUDAT'   l_date1,
        ' '  'BKPF-XBLNR'   wa_itab1-belnr,
        ' '  'BKPF-BLART'   'TR',
        ' '  'BKPF-MONAT'    l_monat,
        ' '  'BKPF-BUKRS'   pa_bukrs,
        ' '  'BKPF-WAERS'   'IDR',
        ' '  'BKPF-BKTXT'   wa_itab1-stceg,
        ' '  'RF05A-AUGTX'   'VAT - Reconciliation',
        ' '  'RF05A-NEWBS'  wa_itab1-bschl,
        ' '  'RF05A-NEWKO'  va_hkont1,   " '0142200210',

        'X'  'SAPMF05A'     '0300',
        ' '  'BDC_OKCODE'    '=SL',
        ' '  'BSEG-WRBTR'   l_value,
        ' '  'BSEG-ZFBDT'   l_date,
        ' '  'BSEG-ZUONR'   wa_itab1-zuonr,
        ' '  'BSEG-SGTXT'   wa_itab1-sgtxt,
        ' '  'BDC_OKCODE'   '=ZK',

        'X'  'SAPLKACB'     '0002',
        ' '  'BDC_OKCODE'   '=ENTE',
        ' '  'COBL-GSBER'   wa_itab1-gsber,

        'X'  'SAPMF05A'     '0330',
        ' '  'BDC_OKCODE'   '/00',
        ' '  'BSEG-XREF3'   va_xref3,
        ' '  'BDC_OKCODE'   '=PA',

        'X'  'SAPMF05A'     '0710',
        ' '  'BDC_OKCODE'   '/5',
        ' '  'RF05A-AGBUK'  pa_bukrs,
        ' '  'RF05A-AGKON'  va_hkont2,  "'0142200200',
        ' '  'RF05A-AGKOA'     'S',
        ' '  'RF05A-XAUTS'     'X',

        'X'  'SAPMF05A'       '0733',
        ' '  'RF05A-FELDN(1)' 'BELNR',
        ' '  'RF05A-SEL01(1)' wa_itab1-belnr,
        ' '  'BDC_OKCODE'     '=BU'.

  CALL TRANSACTION 'F-04' USING i_bdc MODE va_mode UPDATE 'S'
                     MESSAGES INTO i_messtab.
  IF sy-subrc NE 0.
    LOOP AT i_messtab INTO wa_messtab.
      IF wa_messtab-msgtyp = 'E'.
*       read table i_messtab into wa_messtab index 1.
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
            msg  = wa_log_error-msg.

        wa_log_error-hkont =   va_hkont2.
        wa_log_error-bukrs = pa_bukrs.
        wa_log_error-gjahr = wa_itab1-gjahr.
        wa_log_error-belnr = wa_itab1-belnr.
        APPEND wa_log_error TO i_log_error.
      ENDIF.
    ENDLOOP.
*           write: / 'Message Error : ', wa_log_error-MSG.
*           message e001(zs) with wa_log_error-MSG.

* ----- TAMBAHAN UNTUK VENDOR GABUNGAN
  ELSE.
    SELECT SINGLE lifnr
      FROM zfvatvend
      INTO wa_zfvatvend
      WHERE bukrs EQ pa_bukrs AND
            gsber EQ pa_gsber AND
            lifnr EQ wa_itab1-lifnr.
    IF sy-subrc EQ 0.
      LOOP AT i_messtab INTO wa_messtab.
        IF wa_messtab-msgtyp = 'S' AND
           wa_messtab-msgnr  = '312'.
          v_len = strlen( wa_messtab-msgv1 ).
          IF v_len < 10.
            CONCATENATE '0' wa_messtab-msgv1
              INTO l_belnr.
          ELSE.
            MOVE wa_messtab-msgv1 TO l_belnr.
          ENDIF.
        ENDIF.
      ENDLOOP.

      MOVE pa_bukrs       TO zfvatb1_temp-bukrs.
      MOVE pa_gsber       TO zfvatb1_temp-gsber.
      MOVE l_date1+6(4)   TO zfvatb1_temp-gjahr.
      MOVE l_date+6(4)    TO zfvatb1_temp-gjahr1.
      MOVE l_date+3(2)    TO zfvatb1_temp-monat.
      MOVE wa_itab1-lifnr TO zfvatb1_temp-lifnr.
      MOVE l_belnr        TO zfvatb1_temp-belnr.
      MOVE wa_itab1-zfbdt TO zfvatb1_temp-bldat.
      MOVE wa_itab1-zuonr TO zfvatb1_temp-zuonr.
      INSERT zfvatb1_temp.
    ENDIF.
  ENDIF.

ENDFORM.                    " f_post_clearing_vatin



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
  w2   =  10.      w12 = 15.      w22 = 10.      w32 = 12.
  w3   =   5.      w13 = 12.      w23 = 10.      w33 = 12.
  w4   =  12.      w14 = 10.      w24 = 12.      w34 = 10.
  w5   =  12.      w15 = 10.      w25 = 12.      w35 = 10.
  w6   =  30.      w16 = 12.      w26 = 10.      w3a = 10.
  w7   =  20.      w17 = 12.      w27 = 10.      w19a = 12.
  w8   =  16.      w18 = 10.      w28 = 12.
  w9   =  25.      w19 = 10.      w29 = 12.
  w10  =  15.      w20 = 12.      w30 = 10.
  c1 = 0.

ENDFORM.                    " f_init_column



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
*&      Form  f_koreksi_vatout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_koreksi_vatout.
  DATA: l_title(80), sw(1).

  PERFORM f_init_column.
  DESCRIBE TABLE i_itab1 LINES va_ctr.
  IF va_ctr > 0.
    FORMAT COLOR 5.
    c1 =  w1 + w2 + w3 + w4 + w5 + w6 +
          w7 + w8  + w9 + w10 +  w11 + 10.
    NEW-PAGE.
    l_title = 'Daftar Document VAT-Out Acct. 0315300200  ' .
    CONCATENATE l_title 'yang harus diperbaiki'
       INTO l_title SEPARATED BY space.
    WRITE: AT 2(c1) l_title CENTERED.
    WRITE: / sy-uline.
    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    WRITE AT c1(w1) 'Company' NO-GAP CENTERED. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w2) 'Buss. Area' NO-GAP CENTERED. c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w3) 'Fiscal Year' NO-GAP CENTERED. c1 = c1 + w3.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w3a) 'Nomor DO' NO-GAP CENTERED. c1 = c1 + w3a.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w4) 'Document No.' NO-GAP CENTERED. c1 = c1 + w4.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w5) 'Customer No' CENTERED NO-GAP. c1 = c1 + w5.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w6) 'Nama Customer' NO-GAP. c1 = c1 + w6.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w7) 'NPWP Customer' NO-GAP. c1 = c1 + w7.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w8) 'Form Tax A1 / A3' NO-GAP. c1 = c1 + w8.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w9) 'No. Faktur Pajak' NO-GAP. c1 = c1 + w9.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w10) 'Due Date' NO-GAP. c1 = c1 + w10.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w11) 'Tax T0 / T1' NO-GAP. c1 = c1 + w10.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w11) 'Nota Retur' NO-GAP. c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    c1 = 1.
    WRITE: / sy-uline.
    va_ctr = 0.
    LOOP AT i_itab1 INTO wa_itab1.
      ADD 1 TO va_ctr.
      sw = va_ctr MOD 2.
      IF sw = 0.
        FORMAT COLOR 2.
        FORMAT INTENSIFIED OFF.
      ELSE.
        FORMAT COLOR 1.
        FORMAT INTENSIFIED OFF.
      ENDIF.

      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      WRITE AT c1(w1) wa_itab1-bukrs NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) wa_itab1-va_gsber NO-GAP. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w3) wa_itab1-gjahr NO-GAP. c1 = c1 + w3.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w3a) wa_itab1-zuonr NO-GAP. c1 = c1 + w3a.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w4) wa_itab1-belnr NO-GAP. c1 = c1 + w4.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w5) wa_itab1-kunnr NO-GAP. c1 = c1 + w5.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w6) wa_itab1-sgtxt NO-GAP. c1 = c1 + w6.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w7) wa_itab1-stceg NO-GAP. c1 = c1 + w7.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w8) wa_itab1-va_gform NO-GAP. c1 = c1 + w8.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w9) wa_itab1-va_zuonr NO-GAP. c1 = c1 + w9.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w10) wa_itab1-va_date NO-GAP. c1 = c1 + w10.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w11) wa_itab1-va_cityc NO-GAP. c1 = c1 + w10.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w11) wa_itab1-notaretur NO-GAP. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      HIDE: wa_itab1-belnr, wa_itab1-kunnr.
      c1 = 1.
      CLEAR: wa_itab1.
    ENDLOOP.
    FORMAT COLOR 3.
    WRITE: / sy-uline.
    SKIP 2.
    NEW-LINE.
    WRITE:  AT 5 'Keterangan' INTENSIFIED ON.
    NEW-LINE.
    WRITE: AT 10(60) '     *       : Tanggal Tidak boleh kosong'.
    NEW-LINE.
    WRITE: AT 10(60) '     **      : NPWP    Tidak boleh kosong'.
    NEW-LINE.
    WRITE: AT 10(60) '     ***     : No. Faktur Pajak tidak lengkap'.
    NEW-LINE.
    WRITE: AT 10(60)
      '     ****    : Bussiness Area  Tidak boleh Kosong'.
    NEW-LINE.
    WRITE: AT 10(60)
      '     *****   : Koreksi Tax Sederhana (T0) / Standart (T1)'.
    NEW-LINE.
    WRITE: AT 10(60) '     ******  : Nama Customer '.
    NEW-LINE.
    WRITE: AT 10(60) '     ******* : Koreksi Form A1 / A3 '.
    NEW-LINE.
    WRITE: AT 10(60) '     ********: Belum ada nota retur '.
    SKIP 5.
  ENDIF.
  DESCRIBE TABLE i_zfvato_err LINES va_ctr.
  IF va_ctr > 0.
    FORMAT COLOR 5.
    c1 =  w1 + w2 + w3 + w4 + w5 + w6 +
          w7 + w8  + w9 + w10 +  w11 + 10.
    NEW-PAGE.
    l_title = 'Daftar Document VAT-Out Acct. 0315300200  ' .
    CONCATENATE l_title 'yang harus diperbaiki'
       INTO l_title SEPARATED BY space.
    WRITE: AT 2(c1) l_title CENTERED.
    WRITE: / sy-uline.
    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    WRITE AT c1(w1) 'Company' NO-GAP CENTERED. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w2) 'Buss. Area' NO-GAP CENTERED. c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w3) 'Fiscal Year' NO-GAP CENTERED. c1 = c1 + w3.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w3a) 'Nomor DO' NO-GAP CENTERED. c1 = c1 + w3a.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w4) 'Document No.' NO-GAP CENTERED. c1 = c1 + w4.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w5) 'Customer No' CENTERED NO-GAP. c1 = c1 + w5.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w6) 'Nama Customer' NO-GAP. c1 = c1 + w6.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w7) 'NPWP Customer' NO-GAP. c1 = c1 + w7.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w8) 'Form Tax A1 / A3' NO-GAP. c1 = c1 + w8.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w9) 'No. Faktur Pajak' NO-GAP. c1 = c1 + w9.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w10) 'Due Date' NO-GAP. c1 = c1 + w10.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w11) 'Tax T0 / T1' NO-GAP. c1 = c1 + w10.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    c1 = 1.
    WRITE: / sy-uline.
    va_ctr = 0.
    LOOP AT i_zfvato_err INTO wa_zfvato.
      ADD 1 TO va_ctr.
      sw = va_ctr MOD 2.
      IF sw = 0.
        FORMAT COLOR 2.
        FORMAT INTENSIFIED OFF.
      ELSE.
        FORMAT COLOR 1.
        FORMAT INTENSIFIED OFF.
      ENDIF.

      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      WRITE AT c1(w1) wa_zfvato-vkorg NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) wa_zfvato-va_gsber NO-GAP. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w3) wa_zfvato-gjahr NO-GAP. c1 = c1 + w3.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w3a) wa_zfvato-zuonr NO-GAP. c1 = c1 + w3a.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w4) wa_zfvato-vbeln NO-GAP. c1 = c1 + w4.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w5) wa_zfvato-kunrg NO-GAP. c1 = c1 + w5.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w6) wa_zfvato-name_co NO-GAP. c1 = c1 + w6.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w7) wa_zfvato-stceg NO-GAP. c1 = c1 + w7.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w8) wa_zfvato-va_gform NO-GAP. c1 = c1 + w8.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w9) wa_zfvato-va_zuonr NO-GAP. c1 = c1 + w9.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w10) wa_zfvato-va_date NO-GAP. c1 = c1 + w10.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w11) wa_zfvato-va_cityc NO-GAP. c1 = c1 + w10.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      HIDE: wa_itab1-belnr, wa_itab1-kunnr.
      c1 = 1.
      CLEAR: wa_itab1.
    ENDLOOP.
    FORMAT COLOR 3.
    WRITE: / sy-uline.
    SKIP 2.
    NEW-LINE.
    WRITE:  AT 5 'Keterangan' INTENSIFIED ON.
    NEW-LINE.
    WRITE: AT 10(50) '     *      : Tanggal Tidak boleh kosong'.
    NEW-LINE.
    WRITE: AT 10(50) '     **     : NPWP    Tidak boleh kosong'.
    NEW-LINE.
    WRITE: AT 10(50) '     ***    : No. Faktur Pajak tidak lengkap'.
    NEW-LINE.
    WRITE: AT 10(50)
          '     ****   : Bussiness Area  Tidak boleh Kosong'.
    NEW-LINE.
    WRITE: AT 10(50)
          '     *****  : Koreksi Tax Sederhana (T0) / Standart (T1)'.
    NEW-LINE.
    WRITE: AT 10(50) '     ****** : Nama Customer '.
    NEW-LINE.
    WRITE: AT 10(50) '     *******: Koreksi Form A1 / A3 '.
    SKIP 5.
  ENDIF.

ENDFORM.                    " f_koreksi_vatout
*&---------------------------------------------------------------------*
*&      Form  initialize_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initialize_all.
  REFRESH: i_itab2, i_itab1, i_itab3, i_itab4, i_itab5, i_zfvato,
      i_zfvato_err, i_log_error, i_messtab, i_bdc, t_zfppnnrd, it_message.
  CLEAR:   i_itab2, i_itab1, i_itab3, i_itab4, i_itab5, i_zfvato,
      i_zfvato_err, i_log_error, i_messtab, i_bdc, t_zfppnnrd, it_message.

ENDFORM.                    " initialize_all

*&---------------------------------------------------------------------*
*&      Form  f_post_f04_nr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_f04_nr.
  DATA: l_value(15),
        l_date(10),
        l_date1(10),
        l_mess(50),
        l_monat(2),
        l_year(4),
        l_xblnr LIKE bkpf-xblnr.

  DATA: ld_sgtxt LIKE bsis-sgtxt.

  WRITE pa_monat TO l_monat.
  IF l_monat EQ 0.
    WRITE sy-datum+4(2) TO l_monat.
  ENDIF.
  WRITE wa_itab1-zfbdt TO l_date.
  WRITE wa_itab1-budat TO l_date1.
  l_value = wa_itab1-dmbtr * 100.

  CONCATENATE t_zfppnnrd-kunnr t_zfppnnrd-nonr t_zfppnnrd-nrdt
    INTO ld_sgtxt
    SEPARATED BY '/'.

  IF va_live IS INITIAL.
    l_xblnr = t_zfppnnrd-belnr.
  ELSE.
    l_xblnr = t_zfppnnrd-zuonr.
  ENDIF.

  CLEAR i_bdc.
  PERFORM f_dynpro USING:
        'X'  'SAPMF05A'     '0122',
        ' '  'BDC_OKCODE'    '=SL',
        ' '  'BKPF-BLDAT'   l_date,
        ' '  'BKPF-BUDAT'   l_date1,
        ' '  'BKPF-XBLNR'   l_xblnr,
        ' '  'BKPF-BLART'   'TR',
        ' '  'BKPF-BUKRS'   pa_bukrs,
        ' '  'BKPF-MONAT'    l_monat,
        ' '  'BKPF-WAERS'   'IDR',
        ' '  'BKPF-BKTXT'   'Recon Nota Retur',
        ' '  'RF05A-NEWBS'  wa_itab1-bschl,
        ' '  'RF05A-NEWKO'  va_hkont1,   " '0142200210',

        'X'  'SAPMF05A'     '0300',
        ' '  'BDC_OKCODE'    '=SL',
        ' '  'BSEG-WRBTR'   l_value,
        ' '  'BSEG-ZUONR'   t_zfppnnrd-nonr,
        ' '  'BSEG-SGTXT'   ld_sgtxt,
        ' '  'BDC_OKCODE'   '=ZK',

        'X'  'SAPLKACB'     '0002',
        ' '  'BDC_OKCODE'   '=ENTE',
        ' '  'COBL-GSBER'   pa_gsber,

        'X'  'SAPMF05A'     '0330',
        ' '  'BDC_OKCODE'   '/00',
        ' '  'BSEG-XREF3'   va_xref3,
        ' '  'BDC_OKCODE'   '=PA',

        'X'  'SAPMF05A'     '0710',
        ' '  'BDC_OKCODE'   '/5',
        ' '  'RF05A-AGBUK'  pa_bukrs,
        ' '  'RF05A-AGKON'  va_hkont2,  "'0142200200',
        ' '  'RF05A-AGKOA'     'S',
        ' '  'RF05A-XAUTS'     'X',

        'X'  'SAPMF05A'       '0733',
        ' '  'RF05A-FELDN(1)' 'BELNR',
        ' '  'RF05A-SEL01(1)' t_zfppnnrd-belnr,
        ' '  'BDC_OKCODE'     '=BU'.
  CALL TRANSACTION 'F-04' USING i_bdc MODE va_mode UPDATE 'S'
                     MESSAGES INTO i_messtab.
  IF sy-subrc NE 0.
    LOOP AT i_messtab INTO wa_messtab.
      IF wa_messtab-msgtyp = 'E'.
*       read table i_messtab into wa_messtab index 1.
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
            msg  = wa_log_error-msg.

        wa_log_error-hkont =   va_hkont2.
        wa_log_error-bukrs = pa_bukrs.
        wa_log_error-gjahr = wa_itab1-gjahr.
        wa_log_error-belnr = wa_itab1-belnr.
        APPEND wa_log_error TO i_log_error.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_post_f04_nr

*&---------------------------------------------------------------------*
*&      Form  f_proses_vatout_cn
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_vatout_cn.
  SELECT SINGLE live
    FROM zplbc
    INTO va_live
    WHERE bukrs EQ pa_bukrs AND
          werks EQ pa_gsber.

  CASE pa_bukrs.
    WHEN '8070'.
      SELECT a~bukrs a~kunnr a~monat a~gjahr vkbur a~nonr belnr  zuonr a~nrdt belnrrc
        FROM zfppnnrh AS a JOIN zfppnnrd AS b ON a~bukrs EQ b~bukrs AND
                                                 a~kunnr EQ b~kunnr AND
                                                 a~monat EQ b~monat AND
                                                 a~gjahr EQ b~gjahr AND
                                                 a~nonr  EQ b~nonr
        INTO CORRESPONDING FIELDS OF TABLE t_zfppnnrd
        WHERE a~monat   EQ pa_monat AND
              a~bukrs   EQ pa_bukrs AND
              a~gjahr   EQ pa_gjahr AND
              b~vkbur   EQ pa_gsber AND
              b~zuonr   IN so_belnr.
    WHEN OTHERS.
      SELECT a~bukrs a~kunnr a~monat a~gjahr vkbur a~nonr belnr  zuonr a~nrdt belnrrc
        FROM zfppnnrh AS a JOIN zfppnnrd AS b ON a~bukrs EQ b~bukrs AND
                                                 a~kunnr EQ b~kunnr AND
                                                 a~monat EQ b~monat AND
                                                 a~gjahr EQ b~gjahr AND
                                                 a~nonr  EQ b~nonr
        INTO CORRESPONDING FIELDS OF TABLE t_zfppnnrd
        WHERE a~monat   EQ pa_monat AND
              a~bukrs   EQ pa_bukrs AND
              a~gjahr   EQ pa_gjahr AND
              b~zuonr   IN so_belnr.
  ENDCASE.

  IF NOT t_zfppnnrd[] IS INITIAL.
    SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat a~bldat
           a~waers a~xblnr a~blart a~monat a~bschl a~shkzg
           a~mwskz a~dmbtr a~sgtxt a~zfbdt a~zuonr a~gsber
           a~belnr b~bktxt
           INTO CORRESPONDING FIELDS OF TABLE i_itab3
           FROM bsis AS a JOIN bkpf AS b ON a~bukrs EQ b~bukrs AND
                                              a~belnr EQ b~belnr AND
                                              a~gjahr EQ b~gjahr
           FOR ALL ENTRIES IN t_zfppnnrd
           WHERE a~hkont EQ '0315300100'  AND
                 a~blart NE 'TR'     AND
                 a~shkzg EQ 'S'      AND
                 a~bukrs EQ t_zfppnnrd-bukrs AND
                 a~belnr EQ t_zfppnnrd-belnr AND
                 a~gjahr EQ t_zfppnnrd-gjahr.
  ENDIF.

  IF NOT i_itab3[] IS INITIAL.
    SORT i_itab3 BY belnr.
    SORT t_zfppnnrd BY belnr.
    LOOP AT i_itab3 INTO wa_itab1.
      wa_itab1-zfbdt = wa_itab1-budat.
      va_hkont1 = '0315300200'.
      va_hkont2 = '0315300100'.
      READ TABLE t_zfppnnrd WITH KEY belnr = wa_itab1-belnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        CLEAR: va_xref3.
        SELECT SINGLE gform cityc
               INTO (wa_itab1-gform, wa_itab1-cityc)
               FROM kna1 WHERE kunnr EQ t_zfppnnrd-kunnr.

        MOVE wa_itab1-zfbdt+4(2) TO bulan.

        IF pa_bukrs EQ '8070'.
          IF wa_itab1-gform EQ 'A3' OR
            wa_itab1-gform EQ 'A4'.
            CONCATENATE wa_itab1-cityc 'A1' bulan pa_gsber
            INTO va_xref3 SEPARATED BY '|'.
          ELSE.
            CONCATENATE wa_itab1-cityc wa_itab1-gform bulan pa_gsber
            INTO va_xref3 SEPARATED BY '|'.
          ENDIF.
        ELSE.
          IF wa_itab1-gform EQ 'A3' OR
            wa_itab1-gform EQ 'A4'.
            CONCATENATE wa_itab1-cityc 'A1' bulan
            INTO va_xref3 SEPARATED BY '|'.
          ELSE.
            CONCATENATE wa_itab1-cityc wa_itab1-gform bulan
            INTO va_xref3 SEPARATED BY '|'.
          ENDIF.
        ENDIF.

        PERFORM f_post_f04_nr.
      ENDIF.
    ENDLOOP.
  ELSE.
    MESSAGE s000(zab) WITH 'Data not found'.
  ENDIF.

  CLEAR: t_zfppnnrd.
  REFRESH: t_zfppnnrd.
ENDFORM.                    " f_proses_vatout_cn
