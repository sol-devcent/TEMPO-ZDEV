REPORT ztest NO STANDARD PAGE HEADING
                                  LINE-SIZE  244.

TABLES: zsl_dsales, zsl_hsales, tgsbt, tvbur, tvkbt, t001w.
TYPES: BEGIN OF t_itab,
           vkorg LIKE zsl_hsales-vkorg,
           plant LIKE zsl_hsales-plant,
           vkbur LIKE zsl_hsales-vkbur,
           vbeln LIKE zsl_hsales-vbeln,
           vbtyp LIKE zsl_hsales-vbtyp,
           z_uplod LIKE zsl_hsales-z_uplod,
           fkdat LIKE zsl_hsales-fkdat,
           bldat LIKE zsl_hsales-bldat,
           fkart LIKE zsl_hsales-fkart,
           spdot LIKE zsl_hsales-spdot,
           account_no LIKE zsl_hsales-account_no,
           cogs_j LIKE zsl_hsales-cogs_j,
           staacc LIKE zsl_hsales-staacc,
           grswr  LIKE zsl_hsales-grswr,
           gino  LIKE zssutdt005-gino,
           kir   LIKE zssutdt005-kir,
       END OF t_itab.

TYPES: BEGIN OF t_itab1,
           vkorg LIKE zsl_hsales-vkorg,
           vkbur LIKE zsl_hsales-vkbur,
           spdo(22),
           h_dok_ok_gi TYPE i,
           h_dok_fail_gi TYPE i,
           h_dok_ok_cogs TYPE i,
           h_dok_fail_cogs TYPE i,
           h_dok_ok_sales TYPE i,
           h_dok_fail_sales TYPE i,
           d_dok_ok_gi TYPE i,
           d_dok_fail_gi TYPE i,
           d_dok_ok_cogs TYPE i,
           d_dok_fail_cogs TYPE i,
           d_dok_ok_sales TYPE i,
           d_dok_fail_sales TYPE i,
           g_dok_ok_cogs TYPE p,
           g_dok_fail_cogs TYPE p,
           g_dok_ok_sales TYPE p,
           g_dok_fail_sales TYPE p,
       END OF t_itab1.
DATA: i_itab TYPE t_itab OCCURS 0,
      wa_itab TYPE t_itab,
      i_result TYPE t_itab1 OCCURS 0,
      wa_result1 TYPE t_itab1,
      wa_result TYPE t_itab1,
      wa_subtotal TYPE t_itab1,
      wa_grandtotal TYPE t_itab1,
      va_nou TYPE i.
DATA:
       v_line_size TYPE i,
       v_line_size_sum TYPE i,
       c1    TYPE i,
       c2    TYPE i,
       c3    TYPE i,
       c4    TYPE i,  w0    TYPE i,
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


SELECTION-SCREEN BEGIN OF BLOCK aaa WITH FRAME TITLE text-aaa.
PARAMETERS    so_vkorg LIKE zsl_hsales-vkorg OBLIGATORY DEFAULT '8070'.
SELECT-OPTIONS : so_plant FOR t001w-werks,
                 so_vkbur FOR tvbur-vkbur,
                 so_fkdat FOR zsl_hsales-fkdat,
                 so_vbeln FOR zsl_hsales-vbeln,
                 so_bldat FOR zsl_hsales-bldat,
                 so_fkart FOR zsl_hsales-fkart,
                 so_spdot FOR zsl_hsales-spdot,
                 so_zup FOR zsl_hsales-z_uplod.
SELECTION-SCREEN SKIP.


SELECTION-SCREEN END OF BLOCK aaa.
************************************************************************
* PROGRAM                                                              *
************************************************************************
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
    so_vkorg  = lv_parva.
  ENDIF.

  PERFORM f_init_column.
************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.

  SELECT     a~vkorg
             a~plant
             a~vkbur
             a~vbeln
             a~vbtyp
             a~z_uplod
             a~fkdat
             a~bldat
             a~fkart
             a~spdot
             a~account_no
             a~cogs_j
             a~staacc
             a~grswr
             a~gino
             a~kir
             INTO CORRESPONDING FIELDS OF TABLE i_itab
             FROM zssutdt005 AS a JOIN zssutdt006 AS b
                   ON a~vbeln = b~vbeln AND
                      a~vbtyp = b~vbtyp AND
                      a~z_uplod = b~z_uplod AND
                      a~gjahr   =  b~gjahr
             WHERE a~vkorg      EQ so_vkorg      AND
                   a~plant      IN so_plant      AND
                   a~vkbur      IN so_vkbur      AND
                   a~fkdat      IN so_fkdat      AND
                   a~vbeln      IN so_vbeln      AND
                   a~bldat      IN so_bldat      AND
                   a~fkart      IN so_fkart      AND
                   a~spdot      IN so_spdot      AND
                   a~z_uplod    IN so_zup
             ORDER BY a~vkorg a~vkbur a~kir
                      a~vbeln a~vbtyp.

  IF sy-subrc NE 0.
    WRITE: / 'No Data'.
    EXIT.
  ENDIF.
  CLEAR: wa_itab, wa_result, wa_subtotal, wa_grandtotal, i_result.
*Sort i_itab

  LOOP AT i_itab INTO wa_itab.
    ON CHANGE OF wa_itab-vkorg OR
                 wa_itab-vkbur OR
                 wa_itab-kir.
      IF NOT wa_result IS INITIAL.
        APPEND wa_result TO i_result.
        CLEAR wa_result.
      ENDIF.
    ENDON.
    ON CHANGE OF wa_itab-vkorg OR
                 wa_itab-vkbur OR
                 wa_itab-kir   OR
                 wa_itab-vbeln OR
                 wa_itab-vbtyp.
      PERFORM f_calculate_header.
    ENDON.
    MOVE wa_itab-vkorg TO wa_result-vkorg.
    MOVE wa_itab-vkbur TO wa_result-vkbur.
*    CONCATENATE wa_itab-vkbur wa_itab-fkart wa_itab-spdot
*           INTO wa_result-spdo SEPARATED BY '-'.
    CONCATENATE wa_itab-vkbur wa_itab-kir
           INTO wa_result-spdo SEPARATED BY '-'.

    PERFORM f_calculate_detail.
  ENDLOOP.
  APPEND wa_result TO i_result.
  DATA: sw(1), va_text(30).
  c1 = 2.
  va_nou = 0.
  sw = 0.
  SORT i_result BY vkbur spdo.
  LOOP AT i_result INTO wa_result.
    AT NEW vkbur.
      SELECT SINGLE * FROM tvkbt WHERE vkbur EQ wa_result-vkbur AND
                            ( spras EQ 'EN' OR spras EQ 'E' ).

      CONCATENATE wa_result-vkbur tvkbt-bezei
      INTO va_text SEPARATED BY '-'.
      ADD 1 TO va_nou.
      WRITE: / sy-vline.
      c1 = 2.
      WRITE AT c1(w1) va_nou NO-GAP  .  c1 = c1 + w1.
      WRITE AT c1(1)  sy-vline NO-GAP. c1 = c1 + 1.

      WRITE AT c1(w2) va_text NO-GAP . c1 = c1 + w2.
      WRITE AT c1(1)  sy-vline NO-GAP. c1 = c1 + 1.
      sw = 1.
    ENDAT.
    IF sw NE 1.
      WRITE: / sy-vline.
      c1 = 2.
      c1 = c1 + w1.
      WRITE AT c1(1)  sy-vline NO-GAP. c1 = c1 + 1.

      c1 = c1 + w2.
      WRITE AT c1(1)  sy-vline NO-GAP. c1 = c1 + 1.
    ELSE.
      sw = 0.
    ENDIF.

    PERFORM f_write_line.
    ADD wa_result-h_dok_ok_gi TO wa_subtotal-h_dok_ok_gi.
    ADD wa_result-h_dok_fail_gi TO wa_subtotal-h_dok_fail_gi.
    ADD wa_result-h_dok_ok_cogs TO wa_subtotal-h_dok_ok_cogs.
    ADD wa_result-h_dok_fail_cogs TO wa_subtotal-h_dok_fail_cogs.
    ADD wa_result-h_dok_ok_sales TO wa_subtotal-h_dok_ok_sales.
    ADD wa_result-h_dok_fail_sales TO wa_subtotal-h_dok_fail_sales.
    ADD wa_result-d_dok_ok_gi TO wa_subtotal-d_dok_ok_gi.
    ADD wa_result-d_dok_fail_gi TO wa_subtotal-d_dok_fail_gi.
    ADD wa_result-d_dok_ok_cogs TO wa_subtotal-d_dok_ok_cogs.
    ADD wa_result-d_dok_fail_cogs TO wa_subtotal-d_dok_fail_cogs.
    ADD wa_result-d_dok_ok_sales TO wa_subtotal-d_dok_ok_sales.
    ADD wa_result-d_dok_fail_sales TO wa_subtotal-d_dok_fail_sales.
    ADD wa_result-g_dok_ok_cogs TO wa_subtotal-g_dok_ok_cogs.
    ADD wa_result-g_dok_fail_cogs TO wa_subtotal-g_dok_fail_cogs.
    ADD wa_result-g_dok_ok_sales TO wa_subtotal-g_dok_ok_sales.
    ADD wa_result-g_dok_fail_sales TO wa_subtotal-g_dok_fail_sales.

    ADD wa_result-h_dok_ok_gi TO wa_grandtotal-h_dok_ok_gi.
    ADD wa_result-h_dok_fail_gi TO wa_grandtotal-h_dok_fail_gi.
    ADD wa_result-h_dok_ok_cogs TO wa_grandtotal-h_dok_ok_cogs.
    ADD wa_result-h_dok_fail_cogs TO wa_grandtotal-h_dok_fail_cogs.
    ADD wa_result-h_dok_ok_sales TO wa_grandtotal-h_dok_ok_sales.
    ADD wa_result-h_dok_fail_sales TO wa_grandtotal-h_dok_fail_sales.
    ADD wa_result-d_dok_ok_gi TO wa_grandtotal-d_dok_ok_gi.
    ADD wa_result-d_dok_fail_gi TO wa_grandtotal-d_dok_fail_gi.
    ADD wa_result-d_dok_ok_cogs TO wa_grandtotal-d_dok_ok_cogs.
    ADD wa_result-d_dok_fail_cogs TO wa_grandtotal-d_dok_fail_cogs.
    ADD wa_result-d_dok_ok_sales TO wa_grandtotal-d_dok_ok_sales.
    ADD wa_result-d_dok_fail_sales TO wa_grandtotal-d_dok_fail_sales.
    ADD wa_result-g_dok_ok_cogs TO wa_grandtotal-g_dok_ok_cogs.
    ADD wa_result-g_dok_fail_cogs TO wa_grandtotal-g_dok_fail_cogs.
    ADD wa_result-g_dok_ok_sales TO wa_grandtotal-g_dok_ok_sales.
    ADD wa_result-g_dok_fail_sales TO wa_grandtotal-g_dok_fail_sales.
    AT END OF vkbur.
      WRITE: / sy-uline.
      MOVE-CORRESPONDING wa_subtotal TO wa_result.
      CLEAR wa_subtotal.
      WRITE: / sy-vline.
      c1 = 2.
      w0 = w1 + w2 + 1.
      CONCATENATE 'Sub Total' va_text INTO va_text
          SEPARATED BY space.
      WRITE AT c1(w0) va_text NO-GAP . c1 = c1 + w0.
      WRITE AT c1(1)  sy-vline NO-GAP. c1 = c1 + 1.
      CLEAR wa_result-spdo.
      PERFORM f_write_line.
      WRITE: / sy-uline.
    ENDAT.
  ENDLOOP.
  WRITE: / sy-uline.
  MOVE-CORRESPONDING wa_grandtotal TO wa_result.
  WRITE: / sy-vline.
  c1 = 2.
  w0 = w1 + w2 + 1.

  WRITE AT c1(w0) 'Grand Total ' NO-GAP . c1 = c1 + w0.
  WRITE AT c1(1)  sy-vline NO-GAP. c1 = c1 + 1.
  CLEAR wa_result-spdo.
  PERFORM f_write_line.
  WRITE: / sy-uline.

TOP-OF-PAGE.
  PERFORM f_write_header.

END-OF-PAGE.


************************************************************************
* AT LINE-SELECTION.
************************************************************************
AT LINE-SELECTION.
  DATA: va_value(20),
        va_fieldname(30),
        va_fkart LIKE zsl_hsales-fkart,
        va_vkbur LIKE zsl_hsales-vkbur,
        va_spdot LIKE zsl_hsales-spdot,
        va_kir   LIKE zssutdt005-kir.

  IF sy-lsind = 1.
    GET CURSOR FIELD va_fieldname VALUE va_value.
    CASE va_fieldname.
      WHEN 'WA_RESULT-SPDO'.
        va_vkbur = va_value(4).
*        va_fkart = va_value+5(4).
*        va_spdot = va_value+10(8).
        va_kir   = va_value+5(4).
*              Write: / va_vkbur, va_fkart, va_spdot.
*              write: / sy-LISEL.
        c1 = 2.
        WRITE: / sy-uline.
        WRITE: / sy-vline NO-GAP.
        WRITE AT c1(w6) 'Billing No' NO-GAP CENTERED. c1 = c1 + w6.

        WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w7)  'Account No' NO-GAP CENTERED. c1 = c1 + w7.

        WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w8)  'COGS No' NO-GAP CENTERED. c1 = c1 + w8.

        WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w9)  'Tgl Doc.' NO-GAP CENTERED. c1 = c1 + w9.

        WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w10) 'Nama Customer'   NO-GAP . c1 = c1 + w10.

        WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w10) 'No. Faktur Pajak' NO-GAP . c1 = c1 + w10.

        WRITE AT c1(1)    sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w11)  'Gross Sales' NO-GAP . c1 = c1 + w11.

        WRITE AT c1(1)    sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w11)  'Net Sales' NO-GAP . c1 = c1 + w11.

        WRITE AT c1(1)    sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w11)  'PPN ' NO-GAP . c1 = c1 + w11.

        WRITE AT c1(1)    sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w9)  'Tgl Proses' NO-GAP . c1 = c1 + w9.
        WRITE: / sy-uline.
        LOOP AT i_itab INTO wa_itab WHERE vkbur = va_vkbur AND
                                          kir   = va_kir.

          ON CHANGE OF wa_itab-vkorg OR
                       wa_itab-vkbur OR
*                       wa_itab-fkdat OR
                       wa_itab-kir   OR
                       wa_itab-vbeln OR
                       wa_itab-vbtyp.
            PERFORM f_write_detail.
          ENDON.
        ENDLOOP.
        WRITE: / sy-uline.

    ENDCASE.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  f_write_header
*&---------------------------------------------------------------------*
FORM f_write_header.
  DATA l_vtext LIKE tvkot-vtext.


  SELECT SINGLE vtext INTO l_vtext FROM tvkot
         WHERE  vkorg =  so_vkorg AND
                spras = 'EN'.

  FORMAT COLOR 5.
  WRITE: / 'Sales Organisation : ', so_vkorg, ' - ', l_vtext.
  IF so_fkdat IS INITIAL.
    WRITE: / 'All Periode'.
  ELSE.
    WRITE: / 'Periode : ', so_fkdat-low, ' - ', so_fkdat-high.
  ENDIF.
  WRITE: / 'User Id', sy-uname.
  FORMAT COLOR 3.
  c1 = 2.
  WRITE: / sy-uline.
  WRITE: / sy-vline.
  WRITE AT c1(w1)  'No' NO-GAP  CENTERED.  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w2)  'Cabang' NO-GAP  CENTERED.   c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w3)  'SPDO' NO-GAP  CENTERED.   c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  w0 = w4 * 6 + 5.
  WRITE AT c1(w0)  'Header' NO-GAP  CENTERED.   c1 = c1 + w0.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w0)  'Detail' NO-GAP  CENTERED.   c1 = c1 + w0.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  w0 = w5 * 4 + 3.
  WRITE AT c1(w0)  'Gross Sales' NO-GAP  CENTERED. c1 = c1 + w0.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = 2.

  WRITE: / sy-uline.
  WRITE: / sy-vline.
  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  w0 = w4 * 2 + 1.
  WRITE AT c1(w0)  'Proses GI' NO-GAP CENTERED. c1 = c1 + w0.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w0)  'Posting COGS' NO-GAP CENTERED. c1 = c1 + w0.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w0)  'Posting Sales' NO-GAP CENTERED. c1 = c1 + w0.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w0)  'Proses GI' NO-GAP CENTERED. c1 = c1 + w0.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w0)  'Posting COGS' NO-GAP CENTERED. c1 = c1 + w0.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w0)  'Posting Sales' NO-GAP CENTERED. c1 = c1 + w0.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  w0 = w5 * 2 + 1.
  WRITE AT c1(w0)  'Posting COGS' NO-GAP CENTERED. c1 = c1 + w0.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w0)  'Posting Sales' NO-GAP CENTERED. c1 = c1 + w0.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 2.

  WRITE: / sy-uline.
  WRITE: / sy-vline.
  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4)  'Dok Ok' NO-GAP  CENTERED.   c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4)  'Dok Fail' NO-GAP  CENTERED.   c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4)  'Dok Ok' NO-GAP  CENTERED.   c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4)  'Dok Fail' NO-GAP  CENTERED.   c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w4)  'Dok Ok' NO-GAP  CENTERED.   c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4)  'Dok Fail' NO-GAP  CENTERED.   c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w4)  'Dok Ok' NO-GAP  CENTERED.   c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4)  'Dok Fail' NO-GAP  CENTERED.   c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w4)  'Dok Ok' NO-GAP  CENTERED.   c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4)  'Dok Fail' NO-GAP  CENTERED.   c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w4)  'Dok Ok' NO-GAP  CENTERED.   c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4)  'Dok Fail' NO-GAP  CENTERED.   c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w5)  'Dok Ok' NO-GAP  CENTERED.   c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w5)  'Dok Fail' NO-GAP  CENTERED.   c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w5)  'Dok Ok' NO-GAP  CENTERED.   c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w5)  'Dok Fail' NO-GAP  CENTERED.   c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE: / sy-uline.
ENDFORM.                    " f_write_header
*&---------------------------------------------------------------------*
*&      Form  f_Write_line
*&---------------------------------------------------------------------*
FORM f_write_line.


  WRITE AT c1(w3) wa_result-spdo NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1)  sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4) wa_result-h_dok_ok_gi NO-GAP  CENTERED. c1 = c1 + w4.
  WRITE AT c1(1)  sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4) wa_result-h_dok_fail_gi NO-GAP CENTERED. c1 = c1 + w4
.
  WRITE AT c1(1)  sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4) wa_result-h_dok_ok_cogs NO-GAP CENTERED. c1 = c1 + w4
.
  WRITE AT c1(1)  sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4) wa_result-h_dok_fail_cogs NO-GAP CENTERED. c1 = c1 + w4
 .
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w4) wa_result-h_dok_ok_sales NO-GAP CENTERED. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4) wa_result-h_dok_fail_sales NO-GAP CENTERED. c1 = c1 + w4
  .
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w4)  wa_result-d_dok_ok_gi NO-GAP CENTERED. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4) wa_result-d_dok_fail_gi NO-GAP CENTERED. c1 = c1 + w4
.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w4) wa_result-d_dok_ok_cogs NO-GAP CENTERED. c1 = c1 + w4
.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4) wa_result-d_dok_fail_cogs NO-GAP CENTERED. c1 = c1 + w4
 .
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w4) wa_result-d_dok_ok_sales NO-GAP CENTERED. c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4) wa_result-d_dok_fail_sales NO-GAP CENTERED. c1 = c1 + w4
  .
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w5)  wa_result-g_dok_ok_cogs NO-GAP . c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w5) wa_result-g_dok_fail_cogs NO-GAP . c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w5) wa_result-g_dok_ok_sales NO-GAP . c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w5) wa_result-g_dok_fail_sales NO-GAP .  c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

*   write: / sy-uline.


ENDFORM.                    " f_Write_line
*&---------------------------------------------------------------------*
*&      Form  f_calculate
*&---------------------------------------------------------------------*
FORM f_calculate.
ENDFORM.                    " f_calculate
*&---------------------------------------------------------------------*
*&      Form  f_init_column
*&---------------------------------------------------------------------*
FORM f_init_column.
  w1   =   4.      w11 = 15.      w21 = 12.      w31 = 10.
  w2   =  25.      w12 = 15.      w22 = 10.      w32 = 12.
  w3   =  15.      w13 = 6.      w23 = 10.      w33 = 12.
  w4   =  10.      w14 = 15.      w24 = 12.      w34 = 10.
  w5   =  15.      w15 = 10.      w25 = 12.      w35 = 10.
  w6   =  18.      w16 = 12.      w26 = 10.
  w7   =  15.      w17 = 12.      w27 = 10.      w19a = 12.
  w8   =  15.      w18 = 10.      w28 = 12.
  w9   =  10.      w19 = 10.      w29 = 12.
  w10  =  20.      w20 = 12.      w30 = 10.

ENDFORM.                    " f_init_column
*&---------------------------------------------------------------------*
*&      Form  f_calculate_header
*&---------------------------------------------------------------------*
FORM f_calculate_header.
  IF wa_itab-vbtyp = 'O'.
    wa_itab-grswr = wa_itab-grswr * -100.
  ELSE.
    wa_itab-grswr = wa_itab-grswr * 100.
  ENDIF.
  IF wa_itab-gino IS NOT INITIAL.
    ADD 1 TO wa_result-h_dok_ok_gi.
  ELSE.
    ADD 1 TO wa_result-h_dok_fail_gi.
  ENDIF.
  IF wa_itab-account_no NE space.
    ADD 1 TO wa_result-h_dok_ok_sales.
    ADD wa_itab-grswr TO wa_result-g_dok_ok_sales.
  ELSE.
    ADD 1 TO wa_result-h_dok_fail_sales.
    ADD wa_itab-grswr TO wa_result-g_dok_fail_sales.
  ENDIF.
  IF wa_itab-cogs_j NE space.
    ADD 1 TO wa_result-h_dok_ok_cogs.
    ADD wa_itab-grswr TO wa_result-g_dok_ok_cogs.
  ELSE.
    ADD 1 TO wa_result-h_dok_fail_cogs.
    ADD wa_itab-grswr TO wa_result-g_dok_fail_cogs.
  ENDIF.

ENDFORM.                    " f_calculate_header
*&---------------------------------------------------------------------*
*&      Form  f_calculate_detail
*&---------------------------------------------------------------------*
FORM f_calculate_detail.
  IF wa_itab-gino IS NOT INITIAL.
    ADD 1 TO wa_result-d_dok_ok_gi.
  ELSE.
    ADD 1 TO wa_result-d_dok_fail_gi.
  ENDIF.
  IF wa_itab-account_no NE space.
    ADD 1 TO wa_result-d_dok_ok_sales.
  ELSE.
    ADD 1 TO wa_result-d_dok_fail_sales.
  ENDIF.
  IF wa_itab-cogs_j NE space.
    ADD 1 TO wa_result-d_dok_ok_cogs.
  ELSE.
    ADD 1 TO wa_result-d_dok_fail_cogs.
  ENDIF.

ENDFORM.                    " f_calculate_detail
*&---------------------------------------------------------------------*
*&      Form  f_write_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_detail.
  DATA: vatdt  LIKE zfvato-vatdt,
        erdat  LIKE zfvato-erdat,
        vatno  LIKE zfvato-vatno,
        tkwert LIKE zfvato-tkwert,
        netwr  LIKE zfvato-netwr,
        mwsbk  LIKE zfvato-mwsbk,
        name_co LIKE zfvato-name_co,
        va_vrtnr(20).

  CLEAR: erdat, vatdt, vatno, tkwert, netwr,  mwsbk,  name_co, va_vrtnr.
  SELECT SINGLE erdat vatdt vatno tkwert netwr  mwsbk  name_co
         INTO (erdat, vatdt, vatno, tkwert, netwr,  mwsbk,  name_co)
         FROM zfvato WHERE zuonr EQ wa_itab-vbeln.

  tkwert  = tkwert * 100.
  netwr   = netwr  * 100.
  mwsbk   = mwsbk  * 100.
  IF vatno NE 0.
    CONCATENATE 'CWBTO-011-' vatno INTO va_vrtnr.
  ENDIF.
  WRITE: / sy-vline.
  c1 = 2.
  WRITE AT c1(w6) wa_itab-vbeln NO-GAP CENTERED. c1 = c1 + w6.

  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w7)  wa_itab-account_no NO-GAP . c1 = c1 + w7.

  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w8)  wa_itab-cogs_j NO-GAP . c1 = c1 + w8.

  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w9)  wa_itab-bldat NO-GAP . c1 = c1 + w9.

  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w10) name_co   NO-GAP . c1 = c1 + w10.

  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w10) va_vrtnr NO-GAP . c1 = c1 + w10.

  WRITE AT c1(1)    sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w11)  tkwert NO-GAP . c1 = c1 + w11.

  WRITE AT c1(1)    sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w11)  netwr NO-GAP . c1 = c1 + w11.

  WRITE AT c1(1)    sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w11)  mwsbk NO-GAP . c1 = c1 + w11.

  WRITE AT c1(1)    sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w9)  erdat NO-GAP . c1 = c1 + w9.


ENDFORM.                    " f_write_detail
