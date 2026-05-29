REPORT zs_buying_versi_sac7_v1 MESSAGE-ID zs.

DATA : BEGIN OF i_dwn_field OCCURS 0,
         txt_field(10),
       END OF i_dwn_field.

TABLES : vbrk, vbrp, mara, konv.

DATA : BEGIN OF t_vbrp,
         vbeln      LIKE vbrk-vbeln,
         fkart      LIKE vbrk-fkart,
         vkorg      LIKE vbrk-vkorg,
         vtweg      LIKE vbrk-vtweg,
         fkdat      LIKE vbrk-fkdat,
         werks      LIKE vbrp-werks,
         matnr      LIKE vbrp-matnr,
         xblnr      LIKE vbrk-xblnr,
         spart      LIKE vbrk-spart,
         fkimg      LIKE vbrp-fkimg,
         fklmg      LIKE vbrp-fklmg,
         vrkme      LIKE vbrp-vrkme,
         posnr      LIKE vbrp-posnr,
         knumv      LIKE vbrk-knumv,
         uepos      LIKE vbrp-uepos,
         pstyv      LIKE vbrp-pstyv,
         kunrg      LIKE vbrk-kunrg,
         vgbel      LIKE vbrp-vgbel,
         augru_auft TYPE augru,
         extwg      LIKE mara-extwg,
         prdha      LIKE mara-prdha,
         maktx      like makt-maktx,
         kdgrp      type kna1vv-kdgrp,
         brsch      like kna1vv-brsch,
         sortl      like kna1vv-sortl,
         name1      like adrc-name1,
         name2      like adrc-name2,
         name3      like adrc-name3,
         name4      like adrc-name4,
         city1      like adrc-city1,
         post_code1 like adrc-post_code1,
         ktgrm      like mvke-ktgrm,
       END OF t_vbrp.

DATA : BEGIN OF t_dsales,
         vbeln  LIKE zsl_hsales-vbeln,
         fkart  LIKE zsl_hsales-fkart,
         vbtyp  LIKE zsl_hsales-vbtyp,
         vkorg  LIKE zsl_hsales-vkorg,
         fkdat  LIKE zsl_hsales-fkdat,
         extwg  LIKE mara-extwg,
         prdha  LIKE mara-prdha,
         matnr  LIKE zsl_dsales-matnr,
         plant  LIKE zsl_hsales-plant,
         vkbur  LIKE zsl_hsales-vkbur,
         kunnr  LIKE zsl_hsales-kunnr,
         bldat  LIKE zsl_hsales-bldat,
         nsp    LIKE zsl_dsales-nsp,
         fkimg  LIKE zsl_dsales-fkimg,
         meins  LIKE mara-meins,
         disa   LIKE zsl_dsales-disa,
         disb   LIKE zsl_dsales-disb,
         disd   LIKE zsl_dsales-disd,
         dissp  LIKE zsl_dsales-dissp,
         disdc  LIKE zsl_dsales-disdc,
         disf   LIKE zsl_dsales-disf,
         disc   LIKE zsl_dsales-disc,
         dise   LIKE zsl_dsales-dise,
         disf3  LIKE zsl_dsales-disf,
         disvol LIKE zsl_dsales-disvol,
       END OF t_dsales.

TYPES: BEGIN OF  t_itab,
         vbeln(10),
         fkart(4),
         vbtyp(1),
         vkorg(4),
         fkdat             LIKE sy-datum,
         program(2),
         extwg(18),
         prdha(18),
         sal_off(4),
         industri(4),
         search(10),
         customer(10),
         cust_name(40),
         address(120),
         material_code(18),
         mat_descrp(40),
         do_date           LIKE sy-datum,
         do_number(10),
         gross(25),
         qty(20),
         dis_a(25),
         dis_b(25),
         dis_c(25),
         dis_d(25),
         dis_e(25),
         dis_f(25),
         final(1),
         lifnr(10),
         cgrp(2),
         dis_f3(25),
         dis_vol(25),
         augru_auft(3),
       END OF t_itab.

DATA : i_vbrp    LIKE t_vbrp OCCURS 0 WITH HEADER LINE,
       wa_vbrp   LIKE t_vbrp,
       i_dsales  LIKE t_dsales OCCURS 0 WITH HEADER LINE,
       wa_dsales LIKE t_dsales.

DATA : lt_vbrp  LIKE t_vbrp OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF i_eord OCCURS 0,
         matnr LIKE  eord-matnr,
         werks LIKE  eord-werks,
         zeord LIKE  eord-zeord,
         lifnr LIKE  eord-lifnr,
       END OF i_eord.
DATA : lt_eord LIKE i_eord OCCURS 0 WITH HEADER LINE.

DATA : wa_eord LIKE i_eord.

DATA : BEGIN OF lt_mara OCCURS 0,
         matnr TYPE matnr,
         extwg TYPE extwg,
         prdha TYPE prodh_d,
         maktx TYPE maktx,
       END OF lt_mara.

DATA : BEGIN OF ta_detail OCCURS 0,
         vbeln(10),
         fkart(4),
         vbtyp(1),
         vkorg(4),
         fkdat             LIKE sy-datum,
         program(2),
         extwg(18),
         prdha(18),
         sal_off(4),
         industri(4),
         search(10),
         customer(10),
         cust_name(40),
         address(120),
         material_code(18),
         mat_descrp(40),
         do_date           LIKE sy-datum,
         do_number(10),
         gross(25),
         qty(20),
         dis_a(25),
         dis_b(25),
         dis_c(25),
         dis_d(25),
         dis_e(25),
         dis_f(25),
         final(1),
         lifnr(10),
         cgrp(2),
         dis_f3(25),
         dis_vol(25),
         augru_auft(3),
       END OF ta_detail.

DATA : tmp_kwert0     LIKE konv-kwert,
       tmp_kbetr1     LIKE konv-kwert,
       tmp_kbetr2     LIKE konv-kwert,
       tmp_kbetr3     LIKE konv-kwert,
       tmp_kbetr4     LIKE konv-kwert,
       tmp_kbetr5     LIKE konv-kwert,
       tmp_kbetr6     LIKE konv-kwert,
       tmp_kbetr7     LIKE konv-kwert,
       tmp_kbetr8     LIKE konv-kwert,
       tmp_kbetr1t    LIKE konv-kwert,
       tmp_kbetr2t    LIKE konv-kwert,
       tmp_kbetr3t    LIKE konv-kwert,
       tmp_kbetr4t    LIKE konv-kwert,
       tmp_kbetr5t    LIKE konv-kwert,
       tmp_kbetr6t    LIKE konv-kwert,
       tmp_kbetr7t    LIKE konv-kwert,
       tmp_kbetr8t    LIKE konv-kwert,
       tmp_disd_dc    LIKE zsl_dsales-disd,
       v_record       LIKE sy-tabix,
       v_date1        LIKE sy-datum,
       v_date2        LIKE sy-datum,
       l_day          TYPE p,
       l_day1(2)      TYPE n,
       va_qty         LIKE zsac7_tmp-netsqty,
       va_gross       LIKE zsac7_tmp-netsamt,
       va_dnqty       LIKE zsac7_tmp-netsqty,
       va_dnval       LIKE zsac7_tmp-netsamt,
       va_record      TYPE i,
       va_qty2        LIKE zsac7_tmp-netsqty,
       va_gross2      LIKE zsac7_tmp-netsamt,
       va_dnqty2      LIKE zsac7_tmp-netsqty,
       va_dnval2      LIKE zsac7_tmp-netsamt,
       va_record2     TYPE i,
       va_dataset(70) TYPE c.

RANGES : r_noncon FOR kna1-kunnr,
         r_stunr FOR konv-stunr.

TYPES : BEGIN OF t_line,
          v_text(1500) TYPE c,
        END OF t_line.
TYPES : t_iline TYPE t_line OCCURS 10.

DATA : itabline    TYPE t_iline,
       wa_itabline TYPE t_line.

DATA: lv_ktgrm  TYPE mvke-ktgrm.

INCLUDE zs_buying_versi_sac7_v1top.

SELECTION-SCREEN BEGIN OF BLOCK a WITH FRAME TITLE TEXT-001.
PARAMETERS : p_spmon LIKE s603-spmon OBLIGATORY DEFAULT sy-datum(6).
SELECT-OPTIONS : so_vkorg FOR vbrk-vkorg OBLIGATORY DEFAULT '8020',
                 so_werks FOR vbrp-werks,
                 so_fkdat FOR vbrk-fkdat,
                 so_vbeln FOR vbrk-vbeln.
SELECTION-SCREEN END OF BLOCK a.

SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_pros1 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(11) TEXT-011 FOR FIELD p_pros1.
SELECTION-SCREEN POSITION 30.
SELECTION-SCREEN COMMENT 31(12) TEXT-013.
SELECTION-SCREEN POSITION 45.
PARAMETERS : p_file(70) LOWER CASE.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_pros2 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(11) TEXT-012 FOR FIELD p_pros2.
SELECTION-SCREEN POSITION 30.
SELECTION-SCREEN COMMENT 31(12) TEXT-013.
SELECTION-SCREEN POSITION 45.
PARAMETERS : p_file1(70) LOWER CASE.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_pros3 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(11) TEXT-014 FOR FIELD p_pros3.
SELECTION-SCREEN POSITION 30.
SELECTION-SCREEN COMMENT 31(12) TEXT-013.
SELECTION-SCREEN POSITION 45.
PARAMETERS : p_file2(70) LOWER CASE.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b.

PARAMETERS : p_final AS CHECKBOX.


AT SELECTION-SCREEN ON so_fkdat.
  IF p_spmon EQ sy-datum(6).
    IF so_fkdat-low(6) NE p_spmon OR
       so_fkdat-high(6) NE p_spmon.
      MESSAGE e000(zs) WITH 'Invalid Period'.
    ENDIF.
  ELSE.
    CLEAR so_fkdat. FREE so_fkdat.
    CONCATENATE p_spmon '01' INTO so_fkdat-low.
    CALL FUNCTION 'HR_E_NUM_OF_DAYS_OF_MONTH'
      EXPORTING
        p_fecha        = so_fkdat-low
      IMPORTING
        number_of_days = l_day.
    l_day1 = l_day.
    CONCATENATE p_spmon l_day1 INTO so_fkdat-high.
    so_fkdat-sign   = 'I'.
    so_fkdat-option = 'BT'.
    APPEND so_fkdat.
  ENDIF.

INITIALIZATION.
*{   REPLACE        P01K910823                                        1
*\  IF sy-opsys = 'AIX'.
  IF sy-opsys = 'AIX' OR sy-opsys = 'Linux' OR sy-opsys = 'LINUX'.    "SOH: Shell Remediation Adjustment 20240415 KRS
*}   REPLACE
    p_file = '/interface/Buying/'.
    p_file1 = '/interface/Buying/bnb/'.
    p_file2 = '/interface/Buying/rch/'.
  ELSE.
    p_file = '\\tdsdev01\interface\buying\'.
    p_file1 = '\\tdsdev01\interface\buying\bnb\'.
    p_file2 = '\\tdsdev01\interface\buying\rch\'.
  ENDIF.
  CONCATENATE p_spmon '01' INTO so_fkdat-low.
  CALL FUNCTION 'HR_E_NUM_OF_DAYS_OF_MONTH'
    EXPORTING
      p_fecha        = so_fkdat-low
    IMPORTING
      number_of_days = l_day.
  l_day1 = l_day.
  CONCATENATE p_spmon l_day1 INTO so_fkdat-high.
  so_fkdat-sign   = 'I'.
  so_fkdat-option = 'BT'.
  APPEND so_fkdat.

START-OF-SELECTION.
  CLEAR: va_gross, va_qty, va_record.

  IF p_final = 'X'.
    p_final = 'F'.
  ELSE.
    p_final = 'X'.
  ENDIF.

  PERFORM f_cust_nonconsol.
  PERFORM stunr_range.

  CONCATENATE p_spmon '01' INTO v_date1.
  CONCATENATE p_spmon '31' INTO v_date2.

  PERFORM f_get_data USING 'VBRP'.
  SKIP 2.
  PERFORM f_process_data_vbrp.
  SKIP 2.
  " Roche
  PERFORM f_proses_roche.

*  PERFORM f_get_data USING 'DSALES'.

*  PERFORM f_process_data_dsales.

  SORT ta_detail BY extwg do_number material_code.
  v_record = sy-tabix.

  IF p_pros1 IS NOT INITIAL.
    PERFORM f_proses_file USING p_file.
  ENDIF.
  SKIP 2.
** Proses Billing & Non Billing
  IF ta_detail[] IS NOT INITIAL AND p_pros2 IS NOT INITIAL.
    CLEAR: va_gross,va_qty,va_dnqty,va_dnval,va_record.
    PERFORM f_proses_bill_nonbill.
    SKIP 2.
    PERFORM f_proses_file1 USING p_file1.
  ENDIF.

  " Roche
  IF p_pros3 IS NOT INITIAL. "AND ta_detailrch[] IS NOT INITIAL.
    PERFORM f_proses_file2 USING p_file2.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  format_minus
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TA_FILE_CNSP  text
*----------------------------------------------------------------------*
FORM format_minus USING    p_amount.
  IF p_amount+24(1) = '-'.
    SHIFT p_amount RIGHT DELETING TRAILING '-'.
    SHIFT p_amount LEFT DELETING LEADING space.
    CONCATENATE '-' p_amount INTO p_amount.
    CONDENSE p_amount.
    SHIFT p_amount RIGHT DELETING TRAILING space.
  ELSE.
    SHIFT p_amount RIGHT DELETING TRAILING space.
  ENDIF.
ENDFORM.                    " format_minus
*&---------------------------------------------------------------------*
*&      Form  format_minus1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TA_FILE_CNSP  text
*----------------------------------------------------------------------*
FORM format_minus1 USING    p_amount.
  IF p_amount+19(1) = '-'.
    SHIFT p_amount RIGHT DELETING TRAILING '-'.
    SHIFT p_amount LEFT DELETING LEADING space.
    CONCATENATE '-' p_amount INTO p_amount.
    CONDENSE p_amount.
    SHIFT p_amount RIGHT DELETING TRAILING space.
  ENDIF.
ENDFORM.                    " format_minus

*&---------------------------------------------------------------------*
*&      Form  stunr_range
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM stunr_range.

  r_stunr-sign   = 'I'.
  r_stunr-option = 'EQ'.
  r_stunr-low    = '001'.
  APPEND r_stunr.

  r_stunr-sign   = 'I'.
  r_stunr-option = 'EQ'.
  r_stunr-low    = '002'.
  APPEND r_stunr.

  r_stunr-sign   = 'I'.
  r_stunr-option = 'EQ'.
  r_stunr-low    = '050'.
  APPEND r_stunr.

  r_stunr-sign   = 'I'.
  r_stunr-option = 'EQ'.
  r_stunr-low    = '111'.
  APPEND r_stunr.

  r_stunr-sign   = 'I'.
  r_stunr-option = 'EQ'.
  r_stunr-low    = '115'.
  APPEND r_stunr.

  r_stunr-sign   = 'I'.
  r_stunr-option = 'EQ'.
  r_stunr-low    = '116'.
  APPEND r_stunr.

  r_stunr-sign   = 'I'.
  r_stunr-option = 'EQ'.
  r_stunr-low    = '120'.
  APPEND r_stunr.

  r_stunr-sign   = 'I'.
  r_stunr-option = 'EQ'.
  r_stunr-low    = '122'.
  APPEND r_stunr.

  r_stunr-sign   = 'I'.
  r_stunr-option = 'EQ'.
  r_stunr-low    = '125'.
  APPEND r_stunr.

  r_stunr-sign   = 'I'.
  r_stunr-option = 'EQ'.
  r_stunr-low    = '126'.
  APPEND r_stunr.

  r_stunr-sign   = 'I'.
  r_stunr-option = 'EQ'.
  r_stunr-low    = '130'.
  APPEND r_stunr.

  r_stunr-sign   = 'I'.
  r_stunr-option = 'EQ'.
  r_stunr-low    = '135'.
  APPEND r_stunr.

ENDFORM.                    " stunr_range

*&---------------------------------------------------------------------*
*&      Form  move_file_to_itab
*&---------------------------------------------------------------------*
FORM move_file_to_itab  TABLES   p_itab STRUCTURE ta_detail
                        USING    p_dataset LIKE va_dataset.
  DATA:  lwa_itab LIKE ta_detail.
  REFRESH: p_itab, itabline.
  CLEAR: p_itab, lwa_itab.
  DO.
    READ DATASET p_dataset INTO wa_itabline .
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    APPEND wa_itabline TO itabline.
    CLEAR: wa_itabline.
  ENDDO.

  LOOP AT itabline INTO wa_itabline.
    ta_detail = wa_itabline.
*      PERFORM f_cek_aix.
    MOVE-CORRESPONDING ta_detail TO lwa_itab.
    APPEND lwa_itab TO p_itab.
    CLEAR lwa_itab.
  ENDLOOP.
ENDFORM.                    " move_file_to_itab
*&---------------------------------------------------------------------*
*&      Form  move_file_to_itab1
*&---------------------------------------------------------------------*
FORM move_file_to_itab1  TABLES   p_itab STRUCTURE ta_detailbnb
                         USING    p_dataset LIKE va_dataset.
  DATA:  lwa_itab LIKE ta_detailbnb.
  REFRESH: p_itab, itabline.
  CLEAR: p_itab, lwa_itab.
  DO.
    READ DATASET p_dataset INTO wa_itabline .
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    APPEND wa_itabline TO itabline.
    CLEAR: wa_itabline.
  ENDDO.

  LOOP AT itabline INTO wa_itabline.
    lwa_itab = wa_itabline.
*      PERFORM f_cek_aix.
*    MOVE-CORRESPONDING ta_detail TO lwa_itab.
    APPEND lwa_itab TO p_itab.
    CLEAR lwa_itab.
  ENDLOOP.
ENDFORM.                    " move_file_to_itab1

*&---------------------------------------------------------------------*
*&      Form  f_proses_file
*&---------------------------------------------------------------------*
FORM f_proses_file USING fu_file.
  DATA: p_return(1).
*  PERFORM f_download_with_dataset.
  PERFORM f_format_file USING fu_file.
  PERFORM f_open_file USING fu_file
                      CHANGING p_return.
  PERFORM f_write_file TABLES ta_detail USING fu_file.
  PERFORM f_close_file USING fu_file.
  PERFORM f_mode_777 USING fu_file.
  PERFORM f_compare_file USING fu_file p_return.
  IF p_return = '1' OR p_return = '2'.
    PERFORM f_open_file USING fu_file
                        CHANGING p_return.
    PERFORM f_write_file TABLES ta_detail USING fu_file.
    PERFORM f_close_file USING fu_file.
    PERFORM f_mode_777 USING fu_file.
    PERFORM f_compare_file USING fu_file p_return.
    IF p_return = '1' OR p_return = '2'.
      OPEN DATASET fu_file FOR INPUT IN TEXT MODE ENCODING DEFAULT.
      IF sy-subrc = 0.
        DELETE DATASET fu_file.
      ENDIF.
      CLOSE DATASET fu_file.
      WRITE: / 'WARNING...WARNING...WARNING...'.
      WRITE: / 'WARNING...WARNING...WARNING...'.
      WRITE: / 'Proses Buying Outlet hari ini gagal mohon hub. team Functional untuk proses ulang'.
      WRITE: / 'WARNING...WARNING...WARNING...'.
      WRITE: / 'WARNING...WARNING...WARNING...'.
      WRITE: / 'Dikerjakan oleh : _______________'.
    ELSE.
      PERFORM tulis_log USING fu_file.

    ENDIF.
  ELSE.
    PERFORM tulis_log USING fu_file.

  ENDIF.
ENDFORM.                    " f_proses_file
*&---------------------------------------------------------------------*
*&      Form  f_format_file
*&---------------------------------------------------------------------*
FORM f_format_file  USING p_dataset LIKE va_dataset .
  IF sy-datum LT so_fkdat-high.
    CONCATENATE p_dataset 'B' sy-datum '.TXT' INTO p_file.
  ELSE.
    CONCATENATE p_dataset 'B' so_fkdat-high '.TXT' INTO p_file.
  ENDIF.
ENDFORM.                    " f_format_file

*&---------------------------------------------------------------------*
*&      Form  f_format_file1
*&---------------------------------------------------------------------*
FORM f_format_file1  USING p_dataset LIKE va_dataset .
  IF sy-datum LT so_fkdat-high.
    CONCATENATE p_dataset 'B' sy-datum '.TXT' INTO p_file1.
  ELSE.
    CONCATENATE p_dataset 'B' so_fkdat-high '.TXT' INTO p_file1.
  ENDIF.
ENDFORM.                    " f_format_file

*&---------------------------------------------------------------------*
*&      Form  f_open_file
*&---------------------------------------------------------------------*
FORM f_open_file  USING p_dataset LIKE va_dataset
                  CHANGING p_return.
* Open Dataset
  OPEN DATASET p_dataset FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc = 0.
    DELETE DATASET p_dataset.
    OPEN DATASET p_dataset FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
  ELSE.
    OPEN DATASET p_dataset FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
  ENDIF.
  p_return = sy-subrc.
ENDFORM.                    " f_name_file

*&---------------------------------------------------------------------*
*&      Form  f_write_file
*&---------------------------------------------------------------------*
FORM f_write_file  TABLES   p_itab STRUCTURE ta_detail
                   USING    p_dataset LIKE va_dataset.
  DATA: l_minus(1), va_text(30).
  DATA: l_qty   LIKE zsac7_tmp-netsqty,
        l_gross LIKE zsac7_tmp-netsamt.
*   Write Dataset
  l_minus = '-'.
  LOOP AT p_itab.
*       MOVE-CORRESPONDING i_outpl to  i_dataset.
    TRANSFER p_itab TO p_dataset.
    IF l_minus CO p_itab-gross.
      CLEAR: va_text.
      va_text = p_itab-gross.
      CONDENSE va_text.
      SHIFT va_text LEFT DELETING LEADING l_minus.
      l_gross = va_text.
      ADD l_gross TO va_gross.
    ENDIF.
    IF l_minus CO p_itab-qty.
      CLEAR: va_text.
      va_text = p_itab-qty.
      CONDENSE va_text.
      SHIFT va_text LEFT DELETING LEADING l_minus.
      REPLACE ',' WITH '.' INTO va_text.
      l_qty = va_text.
      ADD l_qty TO va_qty.
    ENDIF.
    ADD 1 TO va_record.
  ENDLOOP.
ENDFORM.                    " f_write_file

*&---------------------------------------------------------------------*
*&      Form  f_write_file1
*&---------------------------------------------------------------------*
FORM f_write_file1 TABLES   p_itab STRUCTURE ta_detailbnb
                   USING    p_dataset LIKE va_dataset.
  DATA: l_minus(1), va_text(30).
  DATA: l_qty   LIKE zsac7_tmp-netsqty,
        l_gross LIKE zsac7_tmp-netsamt.
  DATA: l_dnqty LIKE zsac7_tmp-netsqty,
        l_dnval LIKE zsac7_tmp-netsamt.
*   Write Dataset
  l_minus = '-'.
  CLEAR: va_record,va_gross.
  LOOP AT p_itab.
*       MOVE-CORRESPONDING i_outpl to  i_dataset.
    TRANSFER p_itab TO p_dataset.
    IF l_minus CO p_itab-gross.
      CLEAR: va_text.
      va_text = p_itab-gross.
      CONDENSE va_text.
      SHIFT va_text LEFT DELETING LEADING l_minus.
      l_gross = va_text.
      ADD l_gross TO va_gross.
    ENDIF.
    IF l_minus CO p_itab-qty.
      CLEAR: va_text.
      va_text = p_itab-qty.
      CONDENSE va_text.
      SHIFT va_text LEFT DELETING LEADING l_minus.
      REPLACE ',' WITH '.' INTO va_text.
      l_qty = va_text.
      ADD l_qty TO va_qty.
    ENDIF.
    IF l_minus CO p_itab-dnqty.
      CLEAR: va_text.
      va_text = p_itab-dnqty.
      CONDENSE va_text.
      SHIFT va_text LEFT DELETING LEADING l_minus.
      REPLACE ',' WITH '.' INTO va_text.
      l_dnqty = va_text.
      ADD l_dnqty TO va_dnqty.
    ENDIF.
    IF l_minus CO p_itab-dnval.
      CLEAR: va_text.
      va_text = p_itab-dnval.
      CONDENSE va_text.
      SHIFT va_text LEFT DELETING LEADING l_minus.
      REPLACE ',' WITH '.' INTO va_text.
      l_dnval = va_text.
      ADD l_dnval TO va_dnval.
    ENDIF.
    ADD 1 TO va_record.
  ENDLOOP.
ENDFORM.                    " f_write_file1

*&---------------------------------------------------------------------*
*&      Form  f_close_file
*&---------------------------------------------------------------------*
FORM f_close_file  USING p_dataset LIKE va_dataset.
  CLOSE DATASET p_dataset.

ENDFORM.                    " f_close_file
*&---------------------------------------------------------------------*
*&      Form  f_mode_777
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_FILE  text
*----------------------------------------------------------------------*
FORM f_mode_777  USING p_dataset LIKE va_dataset.
  DATA : BEGIN OF tabl OCCURS 10,
           line(200),
         END OF tabl.
  DATA : l_command(125) TYPE c, l_sw(1).


* Change Mode 777
  l_sw = '0'.
  CONCATENATE 'chmod 777' p_dataset INTO l_command SEPARATED BY ' '.
  CALL 'SYSTEM' ID 'COMMAND' FIELD l_command
                ID 'TAB' FIELD tabl-*sys*.

ENDFORM.                    " f_mode_777
*&---------------------------------------------------------------------*
*&      Form  f_cek_file
*&---------------------------------------------------------------------*
FORM f_compare_file  USING  p_dataset LIKE va_dataset
                        p_return.
  DATA: l_itab      TYPE t_itab OCCURS 0,
        lwa_itab    TYPE t_itab,
        l_record    TYPE i, l_minus(1), va_text(30)..
  DATA: l_qty1   LIKE zsac7_tmp-netsqty,
        l_gross1 LIKE zsac7_tmp-netsamt.
  DATA: l_qty   LIKE zsac7_tmp-netsqty,
        l_gross LIKE zsac7_tmp-netsamt.
*   Write Dataset
  l_minus = '-'.

  PERFORM f_open_file1 USING p_dataset
                       CHANGING p_return.
  IF p_return = 0.
    PERFORM move_file_to_itab TABLES l_itab USING p_dataset.
    PERFORM f_close_file USING p_dataset.
    CLEAR: l_gross, l_qty, l_record.
    LOOP AT l_itab INTO lwa_itab.
      IF l_minus CO lwa_itab-gross .
        CLEAR: va_text.
        va_text = lwa_itab-gross .
        CONDENSE va_text.
        SHIFT va_text LEFT DELETING LEADING l_minus.
        l_gross1 = va_text.
        ADD l_gross1 TO l_gross.
      ENDIF.
      IF l_minus CO lwa_itab-qty.
        CLEAR: va_text.
        va_text = lwa_itab-qty.
        CONDENSE va_text.
        SHIFT va_text LEFT DELETING LEADING l_minus.
        REPLACE ',' WITH '.' INTO va_text.
        l_qty1 = va_text.
        ADD l_qty1 TO l_qty.
      ENDIF.
      ADD 1 TO l_record.
      CLEAR: lwa_itab.
    ENDLOOP.

    IF l_gross <> va_gross.
      p_return = '2'.
    ENDIF.
    IF l_qty <> va_qty.
      p_return = '2'.
    ENDIF.
    IF l_record <> va_record.
      p_return = '2'.
    ENDIF.
  ELSE.
    p_return = '1'.
  ENDIF.
ENDFORM.                    " f_cek_file
*&---------------------------------------------------------------------*
*&      Form  f_cek_file
*&---------------------------------------------------------------------*
FORM f_compare_file1  TABLES p_itab STRUCTURE ta_detailbnb
                      USING  p_dataset LIKE va_dataset
                             p_return
                             p_error.
  DATA: l_itab      LIKE ta_detailbnb OCCURS 0,
        lwa_itab    LIKE ta_detailbnb,
        l_record    TYPE i, l_minus(1), va_text(30)..
  DATA: l_qty1   LIKE zsac7_tmp-netsqty,
        l_gross1 LIKE zsac7_tmp-netsamt.
  DATA: l_qty   LIKE zsac7_tmp-netsqty,
        l_gross LIKE zsac7_tmp-netsamt.
  DATA: l_dnqty LIKE zsac7_tmp-netsqty,
        l_dnval LIKE zsac7_tmp-netsamt.
*   Write Dataset
  l_minus = '-'.

  PERFORM f_open_file1 USING p_dataset
                       CHANGING p_return.
  IF p_return = 0.
    PERFORM move_file_to_itab1 TABLES l_itab USING p_dataset.
    PERFORM f_close_file USING p_dataset.
    CLEAR: l_gross, l_qty, l_record.
    LOOP AT l_itab INTO lwa_itab.
      IF l_minus CO lwa_itab-gross .
        CLEAR: va_text.
        va_text = lwa_itab-gross .
        CONDENSE va_text.
        SHIFT va_text LEFT DELETING LEADING l_minus.
        l_gross1 = va_text.
        ADD l_gross1 TO l_gross.
      ENDIF.
      IF l_minus CO lwa_itab-qty.
        CLEAR: va_text.
        va_text = lwa_itab-qty.
        CONDENSE va_text.
        SHIFT va_text LEFT DELETING LEADING l_minus.
        REPLACE ',' WITH '.' INTO va_text.
        l_qty1 = va_text.
        ADD l_qty1 TO l_qty.
      ENDIF.
      IF l_minus CO lwa_itab-dnqty.
        CLEAR: va_text.
        va_text = lwa_itab-dnqty.
        CONDENSE va_text.
        SHIFT va_text LEFT DELETING LEADING l_minus.
        REPLACE ',' WITH '.' INTO va_text.
        l_qty1 = va_text.
        ADD l_qty1 TO l_dnqty.
      ENDIF.
      IF l_minus CO lwa_itab-dnval.
        CLEAR: va_text.
        va_text = lwa_itab-dnval.
        CONDENSE va_text.
        SHIFT va_text LEFT DELETING LEADING l_minus.
        REPLACE ',' WITH '.' INTO va_text.
        l_gross1 = va_text.
        ADD l_gross1 TO l_dnval.
      ENDIF.
      ADD 1 TO l_record.
      CLEAR: lwa_itab.
    ENDLOOP.

    IF l_gross <> va_gross.
      p_return = '2'.
      p_error = '1'.
      va_gross2 = l_gross.
    ENDIF.
    IF l_qty <> va_qty.
      p_return = '2'.
      p_error = '2'.
      va_qty2 = l_qty.
    ENDIF.
    IF l_dnqty <> va_dnqty.
      p_return = '2'.
      p_error = '3'.
      va_dnqty2 = l_dnqty.
    ENDIF.
    IF l_dnval <> va_dnval.
      p_return = '2'.
      p_error = '4'.
      va_dnval2 = l_dnval.
    ENDIF.
    IF l_record <> va_record.
      p_return = '2'.
      p_error = '5'.
      va_record2 = l_record.
    ENDIF.
  ELSE.
    p_return = '1'.
  ENDIF.
ENDFORM.                    " f_cek_file

*&---------------------------------------------------------------------*
*&      Form  Tulis_log
*&---------------------------------------------------------------------*
FORM tulis_log USING p_dataset LIKE va_dataset.
  SKIP 10.
  WRITE: / 'Log File Proses Sales by Outlet/Buying Oulet untuk dibandingkan dengan www.pttempo.com'.
  WRITE: / 'File : ',  p_dataset.
  WRITE: / '       Jumlah Record : ', va_record.
  WRITE: / '       Total Qty     : ', va_qty.
  WRITE: / '       Total Amount  : ', va_gross.
  WRITE: / 'Bandingkan hasil diatas dengan data di www.pttempo.com'.
  WRITE: / 'Data dari website untuk SAC7'.
  SKIP 1.
  WRITE: / '    Total Qty    : ____________________'.
  SKIP 1.
  WRITE: / '    Total Amount : _______________________________'.
  SKIP 1.
  WRITE: / 'Dikerjakan oleh : __________________________'.
  SKIP 1.
ENDFORM.                    " Tulis_log

*&---------------------------------------------------------------------*
*&      Form  f_open_file1
*&---------------------------------------------------------------------*
FORM f_open_file1  USING p_dataset LIKE va_dataset
                   CHANGING p_return.
* Open Dataset
  OPEN DATASET p_dataset FOR INPUT IN TEXT MODE ENCODING DEFAULT.
*  IF sy-subrc = 0.
*    OPEN DATASET p_dataset FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
*  ELSE.
*    p_return = sy-subrc.
*  ENDIF.
  p_return = sy-subrc.
ENDFORM.                    " f_open_file1

INCLUDE zs_buying_versi_sac7_v1f01.
