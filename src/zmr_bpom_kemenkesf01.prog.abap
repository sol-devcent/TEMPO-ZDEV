*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
*  CLEAR: s_bwart,s_bwart[].
*  APPEND LINES OF gr_in    TO s_bwart.
*  APPEND LINES OF gr_out   TO s_bwart.

  PERFORM f_init_quarter USING '2'.
  PERFORM f_init_period.
  PERFORM f_init_header.
  PERFORM f_filter_material.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: lt_ztspmmdt002 TYPE TABLE OF ztspmmdt002 WITH HEADER LINE.

  SELECT * INTO TABLE gt_ztspmmdt005
    FROM ztspmmdt005 WHERE seqno BETWEEN '10' AND '29'.

* Get satuan terkecil material
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_marm
*    FROM marm AS a JOIN t006 AS b ON a~meinh = b~msehi
*                   JOIN t006d AS c ON b~dimid = c~dimid
*    WHERE a~matnr IN s_matnr
*      AND c~mssie EQ space
*    ORDER BY matnr umren DESCENDING.
*  DELETE ADJACENT DUPLICATES FROM gt_marm COMPARING matnr.

* Get material komposisi
  SELECT * INTO TABLE gt_ztspmmdt002
    FROM ztspmmdt002 WHERE werks = '0200'
                       AND matnr IN s_matnr.

* Get SLoc list
*  SELECT * INTO TABLE gt_t001l
*    FROM t001l WHERE werks EQ p_werks
*                 AND lgort IN s_lgort.

* Get Material Description
  SELECT a~matnr maktx meins normt INTO TABLE gt_makt
    FROM makt AS a JOIN mara AS b ON a~matnr = b~matnr
    WHERE a~matnr IN s_matnr
*      AND a~spras = sy-langu.
      AND a~spras = 'i'.

* Get Produsen
  lt_ztspmmdt002[] = gt_ztspmmdt002[].
  DELETE lt_ztspmmdt002 WHERE lifnr IS INITIAL.
  IF lt_ztspmmdt002[] IS NOT INITIAL.
    SELECT lifnr name1 adrnr
      INTO CORRESPONDING FIELDS OF TABLE gt_lfa1
      FROM lfa1 FOR ALL ENTRIES IN lt_ztspmmdt002
      WHERE lifnr = lt_ztspmmdt002-lifnr.
  ENDIF.

* Get HJP
  PERFORM f_get_hjp.

* Get Opening Stock
  PERFORM f_get_opening_stock.

* Get Transaction
  PERFORM f_get_transaction.

ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  CASE 'X'.
    WHEN p_bpom.
*      PERFORM f_print_list_bpom.
      PERFORM f_get_data_excel_bpom.
      PERFORM f_list_data_excel_bpom.
    WHEN p_depkes.
*      PERFORM f_print_list_kemenkes.
      PERFORM f_get_data_excel_kemenkes.
      PERFORM f_list_data_excel_kemenkes.
  ENDCASE.
ENDFORM.                    "F_PRINT_DATA

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM f_top_of_page.
  DATA: page_number(10) VALUE 'Page: nnnn',
        page(4),
        lv_datum(10),
        lv_uzeit(5)     VALUE 'hh:mm'.

  DATA: lv_header1 TYPE char100,
        lv_header2 TYPE char100,
        lv_header3 TYPE char100,
        lv_header4 TYPE char100,
        lv_header5 TYPE char100,
        lv_header6 TYPE char100,
        lv_opnstk  TYPE char15,
        lv_endstk  TYPE char15,
        lv_datlow  TYPE char10,
        lv_dathigh TYPE char10.

*--- Page number
  page = sy-pagno.
  REPLACE 'nnnn' WITH page INTO page_number.

*--- date
  WRITE sy-datum TO lv_datum.

*--- time
  REPLACE 'hh' WITH sy-uzeit(2) INTO lv_uzeit.     " hour
  REPLACE 'mm' WITH sy-uzeit+2(2) INTO lv_uzeit.   " minute

*--- Judul
*  lv_header1 = 'Form POM-9a'.
  lv_header2 = 'LAPORAN DISTRIBUSI OBAT PBF PT. TEMPO CABANG BEKASI'.
  CONCATENATE 'Nama Industri Farmasi  :' gw_header-butxt INTO lv_header3 SEPARATED BY space.
  CONCATENATE 'Alamat                 :' gw_header-name3 INTO lv_header4 SEPARATED BY space.
  CONCATENATE 'Tahun Pelaporan        :' gw_header-gjahr INTO lv_header5 SEPARATED BY space.
  CONCATENATE 'Triwulan               :' gw_header-quart INTO lv_header6 SEPARATED BY space.

  CASE 'X'.
    WHEN p_bpom.
*      PERFORM f_hdr_uline.
      WRITE (420)sy-uline.
*      PERFORM f_hdr_pad_title2 USING lv_header1 '' ''.
      PERFORM f_hdr_pad_title2 USING lv_header2 '' '' '420'.
      PERFORM f_hdr_pad_title2 USING '' '' '' '420'.
      PERFORM f_hdr_pad_title2 USING lv_header3 '' '' '420'.
      PERFORM f_hdr_pad_title2 USING lv_header4 '' lv_datum '420'.
      PERFORM f_hdr_pad_title2 USING lv_header5 '' lv_uzeit '420'.
      PERFORM f_hdr_pad_title2 USING lv_header6 '' page_number '420'.
*      PERFORM f_hdr_uline.
      WRITE (420)sy-uline.

    WHEN p_depkes.
*      PERFORM f_hdr_uline.
      WRITE (463)sy-uline.
*      PERFORM f_hdr_pad_title2 USING lv_header1 '' ''.
      PERFORM f_hdr_pad_title2 USING lv_header2 '' '' '463'.
      PERFORM f_hdr_pad_title2 USING '' '' '' '463'.
      PERFORM f_hdr_pad_title2 USING lv_header3 '' '' '463'.
      PERFORM f_hdr_pad_title2 USING lv_header4 '' lv_datum '463'.
      PERFORM f_hdr_pad_title2 USING lv_header5 '' lv_uzeit '463'.
      PERFORM f_hdr_pad_title2 USING lv_header6 '' page_number '463'.
*      PERFORM f_hdr_uline.
      WRITE (463)sy-uline.
  ENDCASE.
ENDFORM.                    "F_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_HDR_PAD_TITLE
*&---------------------------------------------------------------------*
*       Prepare the variable with the title text spaced correctly
*----------------------------------------------------------------------*
FORM f_hdr_pad_title2 USING v_left_text v_middle_text v_right_text v_linsz.

  DATA:
    page_width    TYPE i,       " Width of page
    middle_length TYPE i,    " Length of title text
    left_length   TYPE i,      " Length of left text
    right_length  TYPE i,     " Length of right text
    left_start    TYPE i,       " Position on line for start of left tex
    middle_start  TYPE i,     " Position on line for start of middl tex
    right_start   TYPE i.      " Position on line for start of right tex

*--- Start with a blank title
  CLEAR d_hdr_title.
  page_width = v_linsz - 1.

*--- Compute space on either side of title allowing vertical border
  COMPUTE middle_length = strlen( v_middle_text ).
  COMPUTE left_length = strlen( v_left_text ).
  COMPUTE right_length = strlen( v_right_text ).

  COMPUTE middle_start = ( v_linsz - middle_length ) / 2.

*--- Allow for vertical lines
  left_start = 0.
  IF d_hdr_rpt_lines = 'X'.
    d_hdr_title(1) = sy-vline.
    d_hdr_title+page_width(1) = sy-vline.
    left_start = 1.
  ENDIF.
  right_start = v_linsz - left_start - right_length - 1.
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
  WRITE AT v_linsz sy-vline.
ENDFORM.                    " F_HDR_PAD_TITLE2

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory.
* here free all the internal table used in the program.
  CLEAR: gt_opnstk,gt_opnstk[],gt_bpom,gt_bpom[].
ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data.
  CASE 'X'.
    WHEN p_bpom.
      PERFORM f_process_data_bpom.
    WHEN p_depkes.
      PERFORM f_process_data_kemenkes.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
FORM f_f4_for_variant_alv CHANGING fc_variant.
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
ENDFORM.                    " F_F4_FOR_VARIANT_ALV

*&---------------------------------------------------------------------*
*&      Form  F_INIT_PERIOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_period .
  CLEAR: s_budat,s_budat[].
  s_budat-sign = 'I'.
  s_budat-option = 'BT'.
  s_budat-low = gw_quarter-begda.
  s_budat-high = gw_quarter-endda.
  APPEND s_budat.
ENDFORM.                    " F_INIT_PERIOD

*&---------------------------------------------------------------------*
*&      Form  F_INIT_BWART
*&---------------------------------------------------------------------*
FORM f_init_bwart .
  SELECT * INTO TABLE gt_ztspmmdt003
    FROM ztspmmdt003 WHERE seqno LIKE '1%'
                        OR seqno LIKE '2%'.

  CLEAR: gr_in,gr_out.

  LOOP AT gt_ztspmmdt003.
    CASE gt_ztspmmdt003-seqno(1).
      WHEN '1'.
        gr_in-sign = 'I'.
        gr_in-option = 'EQ'.
        gr_in-low = gt_ztspmmdt003-bwart.
        APPEND gr_in.
      WHEN '2'.
        gr_out-sign = 'I'.
        gr_out-option = 'EQ'.
        gr_out-low = gt_ztspmmdt003-bwart.
        APPEND gr_out.
    ENDCASE.

    CASE gt_ztspmmdt003-seqno.
      WHEN '10'.
        gr_in0-sign = 'I'.
        gr_in0-option = 'EQ'.
        gr_in0-low = gt_ztspmmdt003-bwart.
        APPEND gr_in0.
      WHEN '11'.
        gr_in1-sign = 'I'.
        gr_in1-option = 'EQ'.
        gr_in1-low = gt_ztspmmdt003-bwart.
        APPEND gr_in1.
      WHEN '12'.
        gr_in2-sign = 'I'.
        gr_in2-option = 'EQ'.
        gr_in2-low = gt_ztspmmdt003-bwart.
        APPEND gr_in2.
      WHEN '20'.
        gr_out0-sign = 'I'.
        gr_out0-option = 'EQ'.
        gr_out0-low = gt_ztspmmdt003-bwart.
        APPEND gr_out0.
      WHEN '21'.
        gr_out1-sign = 'I'.
        gr_out1-option = 'EQ'.
        gr_out1-low = gt_ztspmmdt003-bwart.
        APPEND gr_out1.
      WHEN '22'.
        gr_out2-sign = 'I'.
        gr_out2-option = 'EQ'.
        gr_out2-low = gt_ztspmmdt003-bwart.
        APPEND gr_out2.
      WHEN '23'.
        gr_out3-sign = 'I'.
        gr_out3-option = 'EQ'.
        gr_out3-low = gt_ztspmmdt003-bwart.
        APPEND gr_out3.
      WHEN '24'.
        gr_out4-sign = 'I'.
        gr_out4-option = 'EQ'.
        gr_out4-low = gt_ztspmmdt003-bwart.
        APPEND gr_out4.
      WHEN '25'.
        gr_out5-sign = 'I'.
        gr_out5-option = 'EQ'.
        gr_out5-low = gt_ztspmmdt003-bwart.
        APPEND gr_out5.
      WHEN '26'.
        gr_out6-sign = 'I'.
        gr_out6-option = 'EQ'.
        gr_out6-low = gt_ztspmmdt003-bwart.
        APPEND gr_out6.
      WHEN '27'.
        gr_out7-sign = 'I'.
        gr_out7-option = 'EQ'.
        gr_out7-low = gt_ztspmmdt003-bwart.
        APPEND gr_out7.
      WHEN OTHERS.
        gr_out9-sign = 'I'.
        gr_out9-option = 'EQ'.
        gr_out9-low = gt_ztspmmdt003-bwart.
        APPEND gr_out9.
    ENDCASE.
  ENDLOOP.

  APPEND LINES OF gr_in    TO s_bwart.
  APPEND LINES OF gr_out   TO s_bwart.

  SORT s_bwart BY low.
  DELETE ADJACENT DUPLICATES FROM s_bwart COMPARING low.
ENDFORM.                    " F_INIT_BWART

*&---------------------------------------------------------------------*
*&      Form  F_INIT_QUARTER
*&---------------------------------------------------------------------*
FORM f_init_quarter USING fu_flag.
  DATA: ld_begda(10),
        ld_endda(10).

  CLEAR gw_quarter.
  CASE fu_flag.
    WHEN '1'.
      CALL FUNCTION 'HR_99S_GET_QUARTER'
        EXPORTING
          im_date    = sy-datum
        IMPORTING
          ex_quarter = gw_quarter.
      p_quart = gw_quarter-q.
      WRITE gw_quarter-begda TO ld_begda.
      WRITE gw_quarter-endda TO ld_endda.
      CONCATENATE ld_begda+3(7) ld_endda+3(7) INTO p_month SEPARATED BY ' to '.

    WHEN '2'.
      gw_quarter-year = p_gjahr.
      gw_quarter-q = p_quart.
      CALL FUNCTION 'HR_99S_GET_DATES_QUARTER'
        EXPORTING
          im_quarter = gw_quarter-q
          im_year    = gw_quarter-year
        IMPORTING
          ex_begda   = gw_quarter-begda
          ex_endda   = gw_quarter-endda.
      WRITE gw_quarter-begda TO ld_begda.
      WRITE gw_quarter-endda TO ld_endda.
      CONCATENATE ld_begda+3(7) ld_endda+3(7) INTO p_month SEPARATED BY ' to '.
  ENDCASE.
ENDFORM.                    " F_INIT_QUARTER

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_LIST_BPOM
*&---------------------------------------------------------------------*
FORM f_print_list_bpom .
  DATA: lv_norut TYPE numc2,
        lv_flag  TYPE char1,
        lv_matnr TYPE matnr,
        lt_bpom  LIKE gt_bpom OCCURS 0 WITH HEADER LINE.

  IF gt_bpom[] IS INITIAL.
    WRITE:  / '|',
              '*Null',
          214 '|'.
  ELSE.
    lt_bpom[] = gt_bpom[].
    SORT lt_bpom BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_bpom COMPARING matnr.

*    SORT gt_total BY matnr.

    LOOP AT lt_bpom.
      CLEAR lv_flag.
      ADD 1 TO lv_norut.

*      CLEAR gt_total.
*      READ TABLE gt_total WITH KEY matnr = lt_bpom-matnr.

      LOOP AT gt_bpom WHERE matnr = lt_bpom-matnr.
        gt_bpom-norut = lv_norut.
*        IF lv_flag IS NOT INITIAL.
*          CLEAR: gt_bpom-norut,gt_bpom-maktx,gt_bpom-kekuatan_sedia,
*                 gt_bpom-btk_sedia,gt_bpom-kemasan,gt_total.
*        ENDIF.
*        lv_flag = 'X'.

*        IF gt_bpom-matnr = lv_matnr.
*          CLEAR gt_bpom-matnr.
*        ELSE.
*          lv_matnr = gt_bpom-matnr.
*        ENDIF.

* Recalc. saldo akhir
*        gt_total-sak_jumlah = gt_total-saw_jumlah + gt_total-in_jumlah -
*                              gt_total-out_jumlah.

        WRITE: / '|' NO-GAP, gt_bpom-norut NO-ZERO NO-GAP, '|' NO-GAP,
                 gt_bpom-komposisi NO-GAP, '|' NO-GAP,
             (10)gt_bpom-matnr NO-GAP, '|' NO-GAP,
                 gt_bpom-maktx NO-GAP, '|' NO-GAP,
             (20)gt_bpom-btk_sedia NO-GAP, '|'  NO-GAP ,
             (40)gt_bpom-kekuatan_sedia NO-ZERO NO-GAP, '|' NO-GAP,
             (40)gt_bpom-kemasan NO-GAP, '|' NO-GAP,
                 gt_bpom-bets NO-GAP, '|' NO-GAP,
             (11)gt_bpom-vfdat NO-GAP, '|' NO-GAP,
                 gt_bpom-name1 NO-GAP, '|' NO-GAP,
                 gt_bpom-saw_jumlah UNIT gt_bpom-meins NO-GAP, '|' NO-GAP,
*                 gt_total-saw_jumlah UNIT gt_bpom-meins NO-ZERO, '|',
                 gt_bpom-in_name1 NO-GAP, '|' NO-GAP,
                 gt_bpom-in_jumlah UNIT gt_bpom-meins NO-ZERO NO-GAP, '|' NO-GAP,
                 gt_bpom-out_jumlah UNIT gt_bpom-meins NO-ZERO NO-GAP, '|' NO-GAP,
                 gt_bpom-out_name1 NO-GAP, '|' NO-GAP,
                 gt_bpom-sak_jumlah UNIT gt_bpom-meins NO-GAP, '|' NO-GAP,
             (30)' ' CENTERED NO-GAP, '|' NO-GAP.
      ENDLOOP.
*      PERFORM f_hdr_uline.
      WRITE (420)sy-uline.
    ENDLOOP.
  ENDIF.

*  PERFORM f_write_footer.
ENDFORM.                    " F_PRINT_LIST_BPOM

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_LIST_KEMENKES
*&---------------------------------------------------------------------*
FORM f_print_list_kemenkes .
  DATA: lv_norut    TYPE numc2,
        lv_flag     TYPE char1,
        lv_matnr    TYPE matnr,
        lt_kemenkes LIKE gt_kemenkes OCCURS 0 WITH HEADER LINE.

  IF gt_kemenkes[] IS INITIAL.
    WRITE:  / '|',
              '*Null',
          214 '|'.
  ELSE.
    lt_kemenkes[] = gt_kemenkes[].
    SORT lt_kemenkes BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_kemenkes COMPARING matnr.

    LOOP AT lt_kemenkes.
      CLEAR lv_flag.
      ADD 1 TO lv_norut.

      LOOP AT gt_kemenkes WHERE matnr = lt_kemenkes-matnr.
        gt_kemenkes-norut = lv_norut.
*        IF lv_flag IS NOT INITIAL.
*          CLEAR: gt_kemenkes-norut,gt_kemenkes-maktx,gt_kemenkes-nie,
*                 gt_kemenkes-meins.
*        ENDIF.
*        lv_flag = 'X'.

*        IF gt_kemenkes-matnr = lv_matnr.
*          CLEAR gt_kemenkes-matnr.
*        ELSE.
*          lv_matnr = gt_kemenkes-matnr.
*        ENDIF.

        WRITE: / '|' NO-GAP, gt_kemenkes-norut NO-ZERO NO-GAP, '|' NO-GAP,
             (10)gt_kemenkes-matnr NO-GAP, '|' NO-GAP,
             (20)gt_kemenkes-nie NO-GAP, '|' NO-GAP,
                 gt_kemenkes-maktx NO-GAP, '|' NO-GAP,
              (7)gt_kemenkes-meins CENTERED NO-GAP, '|'  NO-GAP ,
                 gt_kemenkes-saw_jumlah UNIT gt_kemenkes-meins NO-GAP, '|' NO-GAP,
                 gt_kemenkes-bets NO-GAP, '|' NO-GAP,
             (11)gt_kemenkes-vfdat NO-GAP, '|' NO-GAP,
             (30)gt_kemenkes-in_name1 NO-GAP, '|' NO-GAP,
             (20)gt_kemenkes-in_ket NO-GAP, '|' NO-GAP,
                 gt_kemenkes-in_pabrik UNIT gt_kemenkes-meins NO-ZERO NO-GAP, '|' NO-GAP,
                 gt_kemenkes-in_pbf UNIT gt_kemenkes-meins NO-ZERO NO-GAP, '|' NO-GAP,
                 gt_kemenkes-in_retur UNIT gt_kemenkes-meins NO-ZERO NO-GAP, '|' NO-GAP,
                 gt_kemenkes-in_other UNIT gt_kemenkes-meins NO-ZERO NO-GAP, '|' NO-GAP,
                 gt_kemenkes-out_rs UNIT gt_kemenkes-meins NO-ZERO NO-GAP, '|' NO-GAP,
                 gt_kemenkes-out_apotek UNIT gt_kemenkes-meins NO-ZERO NO-GAP, '|' NO-GAP,
                 gt_kemenkes-out_pbf UNIT gt_kemenkes-meins NO-ZERO NO-GAP, '|' NO-GAP,
                 gt_kemenkes-out_dinkes UNIT gt_kemenkes-meins NO-ZERO NO-GAP, '|' NO-GAP,
                 gt_kemenkes-out_puskesmas UNIT gt_kemenkes-meins NO-ZERO NO-GAP, '|' NO-GAP,
                 gt_kemenkes-out_klinik UNIT gt_kemenkes-meins NO-ZERO NO-GAP, '|' NO-GAP,
                 gt_kemenkes-out_tobat UNIT gt_kemenkes-meins NO-ZERO NO-GAP, '|' NO-GAP,
                 gt_kemenkes-out_name1 NO-GAP, '|' NO-GAP,
             (20)gt_kemenkes-out_ket NO-GAP, '|' NO-GAP,
                 gt_kemenkes-nilai CURRENCY 'IDR' NO-ZERO NO-GAP, '|' NO-GAP,
                 gt_kemenkes-sak_jumlah UNIT gt_kemenkes-meins NO-GAP, '|' NO-GAP.
      ENDLOOP.
*      PERFORM f_hdr_uline.
      WRITE (463)sy-uline.
    ENDLOOP.
  ENDIF.

*  PERFORM f_write_footer.
ENDFORM.                    " F_PRINT_LIST_KEMENKES

*&---------------------------------------------------------------------*
*&      Form  F_SUB_HEADER
*&---------------------------------------------------------------------*
FORM f_sub_header .
  CASE 'X'.
    WHEN p_bpom.
      PERFORM f_sub_header_bpom.
    WHEN p_depkes.
      PERFORM f_sub_header_kemenkes.
  ENDCASE.
ENDFORM.                    " F_SUB_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_INIT_HEADER
*&---------------------------------------------------------------------*
FORM f_init_header .
  SELECT SINGLE bukrs butxt INTO (gw_header-bukrs,gw_header-butxt)
    FROM t001 WHERE bukrs = p_bukrs.

  SELECT SINGLE werks name1 adrnr
    INTO (gw_header-werks,gw_header-name1,gw_header-adrnr)
    FROM t001w WHERE werks = p_werks.

  SELECT SINGLE name3 INTO gw_header-name3
    FROM adrc WHERE addrnumber = gw_header-adrnr.

  CASE p_quart.
    WHEN 1.
      CONCATENATE '1 (PERTAMA) - BULAN' p_month INTO gw_header-quart SEPARATED BY space.
    WHEN 2.
      CONCATENATE '2 (KEDUA) - BULAN' p_month INTO gw_header-quart SEPARATED BY space.
    WHEN 3.
      CONCATENATE '3 (KETIGA) - BULAN' p_month INTO gw_header-quart SEPARATED BY space.
    WHEN 4.
      CONCATENATE '4 (KEEMPAT) - BULAN' p_month INTO gw_header-quart SEPARATED BY space.
  ENDCASE.

  gw_header-gjahr = p_gjahr.
ENDFORM.                    " F_INIT_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_FOOTER
*&---------------------------------------------------------------------*
FORM f_write_footer .
  DATA: lv_date TYPE char100,
        lv_ltx  TYPE fcltx.

  SELECT SINGLE ltx INTO lv_ltx
    FROM t247 WHERE spras EQ 'i'
                AND mnr EQ sy-datum+4(2).

  CONCATENATE 'Cikarang /' sy-datum+6(2) lv_ltx sy-datum(4)
    INTO lv_date SEPARATED BY space.
*  PERFORM f_hdr_uline.
  SKIP 2.
  WRITE AT /300(30) lv_date CENTERED.
  WRITE AT /300(30) 'Pelapor' CENTERED.
  SKIP 3.
  WRITE AT /300(30) p_sign CENTERED.
  WRITE AT /300(30) p_sik CENTERED.
ENDFORM.                    " F_WRITE_FOOTER

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERSION
*&---------------------------------------------------------------------*
FORM f_unit_conversion  USING    fu_matnr fu_value fu_meins fu_meinh
                        CHANGING fc_value.

  IF fu_value IS NOT INITIAL.
    CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
      EXPORTING
        input                = fu_value
        matnr                = fu_matnr
        meinh                = fu_meinh
        meins                = fu_meins
      IMPORTING
        output               = fc_value
      EXCEPTIONS
        conversion_not_found = 1
        input_invalid        = 2
        material_not_found   = 3
        meinh_not_found      = 4
        meins_missing        = 5
        no_meinh             = 6
        output_invalid       = 7
        overflow             = 8
        OTHERS               = 9.

    IF sy-subrc <> 0.
      fc_value = fu_value.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_UNIT_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_GET_OPENING_STOCK
*&---------------------------------------------------------------------*
FORM f_get_opening_stock .
  DATA: lt_s035 TYPE TABLE OF s035 WITH HEADER LINE,
        lt_s034 TYPE TABLE OF s034 WITH HEADER LINE.

  SELECT * INTO TABLE lt_s035 FROM s035
    WHERE ssour = space
      AND vrsio = '000'
      AND matnr IN s_matnr
      AND werks = p_werks
      AND lgort NE space
      AND lgort IN s_lgort.

  SELECT * INTO TABLE lt_s034 FROM s034
    WHERE ssour = space
      AND vrsio = '000'
      AND spmon GE s_budat-low(6)
      AND sptag = '00000000'
      AND spwoc = space
      AND spbup = space
      AND werks = p_werks
      AND lgort NE space
      AND lgort IN s_lgort
      AND matnr IN s_matnr.

  SORT: lt_s035 BY matnr werks charg,
        lt_s034 BY matnr werks charg.

  LOOP AT lt_s035.
    gw_opnstk-matnr = lt_s035-matnr.
    gw_opnstk-werks = lt_s035-werks.
*    gw_opnstk-LGORT = lt_s035-lgort.
    gw_opnstk-charg = lt_s035-charg.
    gw_opnstk-labst = lt_s035-cmbwbest.
    LOOP AT lt_s034 WHERE matnr = lt_s035-matnr
                      AND werks = lt_s035-werks
                      AND charg = lt_s035-charg.
      gw_opnstk-labst = gw_opnstk-labst + lt_s034-cmagbb - lt_s034-cmzubb.
      DELETE lt_s034.
    ENDLOOP.
    COLLECT gw_opnstk INTO gt_opnstk.
    CLEAR gw_opnstk.
  ENDLOOP.

  LOOP AT lt_s034.
    gw_opnstk-matnr = lt_s034-matnr.
    gw_opnstk-werks = lt_s034-werks.
*    gw_opnstk-LGORT = lt_s034-lgort.
    gw_opnstk-charg = lt_s034-charg.
    gw_opnstk-labst = lt_s034-cmagbb - lt_s034-cmzubb.
    COLLECT gw_opnstk INTO gt_opnstk.
    CLEAR gw_opnstk.
  ENDLOOP.
ENDFORM.                    " F_GET_OPENING_STOCK

*&---------------------------------------------------------------------*
*&      Form  F_GET_TRANSACTION
*&---------------------------------------------------------------------*
FORM f_get_transaction .
  DATA: lt_mseg_revers LIKE gt_mseg OCCURS 0 WITH HEADER LINE,
        lv_numc2       TYPE numc2,
        lv_bwart       TYPE bwart.

  SELECT a~mblnr a~mjahr a~budat line_id parent_id
         zeile bwart xauto matnr werks lgort charg lifnr kunnr menge meins
         ebeln ebelp sjahr smbln smblp elikz sgtxt shkzg budat xblnr wempf
         grund umwrk umlgo
    INTO CORRESPONDING FIELDS OF TABLE gt_mseg
    FROM mkpf AS a JOIN mseg AS b ON b~mblnr = a~mblnr AND
                                     b~mjahr = a~mjahr
    WHERE budat IN s_budat
      AND bwart IN s_bwart
      AND matnr IN s_matnr
      AND werks = p_werks
      AND lgort IN s_lgort
      AND bukrs = p_bukrs
      AND sobkz = space.

  IF gt_mseg[] IS NOT INITIAL.
    PERFORM f_get_sumber.
  ENDIF.

  lt_mseg_revers[] = gt_mseg[].
  DELETE gt_mseg WHERE smbln NE space.
  DELETE lt_mseg_revers WHERE smbln EQ space.

  SORT: gt_mseg BY mblnr mjahr zeile,
        lt_mseg_revers BY smbln sjahr smblp.

** Cek dokumen reversal
*  LOOP AT gt_mseg.
*    CLEAR: lv_numc2,lv_bwart.
*    lv_numc2 = gt_mseg-bwart+1(2).
*    ADD 1 TO lv_numc2.
*    CONCATENATE gt_mseg-bwart(1) lv_numc2 INTO lv_bwart.
*
*    READ TABLE lt_mseg_revers WITH KEY bwart = lv_bwart
*                                       smbln = gt_mseg-mblnr
*                                       sjahr = gt_mseg-mjahr
*                                       smblp = gt_mseg-zeile
*                                       BINARY SEARCH.
*    IF sy-subrc = 0.
*      DELETE gt_mseg.
*    ENDIF.
*  ENDLOOP.

*  LOOP AT lt_mseg_revers.
*    READ TABLE gt_mseg WITH KEY mblnr = lt_mseg_revers-smbln
*                                mjahr = lt_mseg_revers-sjahr
*                                zeile = lt_mseg_revers-smblp
*                                BINARY SEARCH.
*    IF sy-subrc = 0.
*      DELETE gt_mseg INDEX sy-tabix.
*    ENDIF.
*  ENDLOOP.

  LOOP AT lt_mseg_revers.
    READ TABLE gt_mseg WITH KEY mblnr = lt_mseg_revers-smbln
                                mjahr = lt_mseg_revers-sjahr
                                zeile = lt_mseg_revers-smblp
                                BINARY SEARCH.
    IF sy-subrc = 0.
      DELETE gt_mseg INDEX sy-tabix.
    ELSE.
      SORT: gt_mseg BY mblnr mjahr zeile.
      READ TABLE gt_mseg WITH KEY mblnr = lt_mseg_revers-smbln
                                  mjahr = lt_mseg_revers-sjahr
                                  zeile = lt_mseg_revers-smblp
                                  BINARY SEARCH.
      IF sy-subrc = 0.
        DELETE gt_mseg INDEX sy-tabix.
      ELSE.
        APPEND lt_mseg_revers TO gt_mseg.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_TRANSACTION

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_INIT_LINES
*&---------------------------------------------------------------------*
FORM f_append_init_lines  USING    fu_matnr.
  CLEAR: gt_ztspmmdt002,gt_makt,gt_lfa1.
  READ TABLE gt_ztspmmdt002 WITH KEY matnr = fu_matnr.
  READ TABLE gt_makt WITH KEY matnr = fu_matnr.
  READ TABLE gt_lfa1 WITH KEY lifnr = gt_ztspmmdt002-lifnr.
  APPEND INITIAL LINE TO gt_bpom ASSIGNING <fs_bpom>.
  <fs_bpom>-komposisi	     = gt_ztspmmdt002-komposisi.
  <fs_bpom>-matnr          = fu_matnr.
  <fs_bpom>-maktx          = gt_makt-maktx.
  <fs_bpom>-btk_sedia      = gt_ztspmmdt002-btk_sedia.
  <fs_bpom>-kekuatan_sedia = gt_ztspmmdt002-kekuatan_sedia.
  <fs_bpom>-kemasan        = gt_ztspmmdt002-kemasan.
  <fs_bpom>-name1          = gt_lfa1-name1.
  <fs_bpom>-meins          = gt_makt-meins.
ENDFORM.                    " F_APPEND_INIT_LINES

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_INIT_LINES2
*&---------------------------------------------------------------------*
FORM f_append_init_lines2  USING    fu_matnr.
  CLEAR: gt_ztspmmdt002,gt_makt,gt_lfa1.
  READ TABLE gt_ztspmmdt002 WITH KEY matnr = fu_matnr.
  READ TABLE gt_makt WITH KEY matnr = fu_matnr.
*  READ TABLE gt_lfa1 WITH KEY lifnr = gt_ztspmmdt002-lifnr.
  APPEND INITIAL LINE TO gt_kemenkes ASSIGNING <fs_kemenkes>.
  <fs_kemenkes>-nie            = gt_ztspmmdt002-nie.
  <fs_kemenkes>-matnr          = fu_matnr.
  <fs_kemenkes>-maktx          = gt_makt-maktx.
  <fs_kemenkes>-meins          = gt_makt-meins.
  <fs_kemenkes>-kemasan        = gt_ztspmmdt002-kemasan.
ENDFORM.                    " F_APPEND_INIT_LINES2

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_BPOM
*&---------------------------------------------------------------------*
FORM f_process_data_bpom .
  DATA: lt_mch1   TYPE TABLE OF mch1 WITH HEADER LINE,
        lv_mblnr  TYPE mblnr,
        lv_mjahr  TYPE mjahr,
        lv_norut2 TYPE numc3,
        lv_norut3 TYPE numc3,
        lv_code   TYPE char10,
        lv_adrnr  TYPE adrnr,
        lv_ket    TYPE char30,
        lv_name1  TYPE name1.

  SORT: gt_ztspmmdt002 BY matnr,
        gt_makt        BY matnr,
        gt_opnstk      BY matnr charg,
        gt_mseg        BY matnr charg bwart budat.

  LOOP AT gt_opnstk INTO gw_opnstk.
    PERFORM f_append_init_lines USING gw_opnstk-matnr.
    <fs_bpom>-bets       = gw_opnstk-charg.
    <fs_bpom>-saw_jumlah = gw_opnstk-labst.
    <fs_bpom>-norut      = '100'.
  ENDLOOP.

  LOOP AT gt_mseg.
    IF lv_norut2 IS INITIAL.
      lv_norut2 = '200'.
    ENDIF.
    IF lv_norut3 IS INITIAL.
      lv_norut3 = '300'.
    ENDIF.

** Pemasukan
    IF gt_mseg-bwart IN gr_in. "AND
*       gt_mseg-shkzg EQ 'S'.

      IF ( gt_mseg-bwart = '311' OR gt_mseg-bwart = '919' ) AND
         gt_mseg-shkzg = 'H'.
      ELSEIF ( gt_mseg-bwart NE '311' AND gt_mseg-bwart NE '919' ) AND
               gt_mseg-xauto = 'X'.
      ELSE.

        CLEAR: lv_code,lv_name1.
        CASE gt_mseg-bwart.
          WHEN '101' OR '102'.
            CLEAR: gt_ekko,gt_lfa1_101,gt_t001w.
            READ TABLE gt_ekko WITH KEY ebeln = gt_mseg-ebeln.

            IF gt_ekko-bsart = 'CVSR'.
              CONTINUE.
            ENDIF.

            IF gt_ekko-lifnr IS NOT INITIAL.
              lv_code = gt_ekko-lifnr.
              READ TABLE gt_lfa1_101 WITH KEY lifnr = lv_code.
              lv_name1 = gt_lfa1_101-name1.
            ELSEIF gt_ekko-reswk IS NOT INITIAL.
              lv_code = gt_ekko-reswk.
              READ TABLE gt_t001w WITH KEY werks = lv_code(4).
              lv_name1 = gt_t001w-name1.
              SELECT SINGLE name3 INTO lv_name1
                FROM adrc WHERE addrnumber = gt_t001w-adrnr.
            ENDIF.

          WHEN '305' OR '306'.
            CLEAR: lv_mblnr,lv_mjahr,gt_mseg_305,gt_t001w.
            SPLIT gt_mseg-sgtxt AT '/' INTO lv_mblnr lv_mjahr.
            READ TABLE gt_mseg_305 WITH KEY mblnr = lv_mblnr
                                            mjahr = lv_mjahr
                                            matnr = gt_mseg-matnr
                                            charg = gt_mseg-charg.
            lv_code = gt_mseg_305-werks.
            READ TABLE gt_t001w WITH KEY werks = lv_code(4).
            lv_name1 = gt_t001w-name1.
            SELECT SINGLE name3 INTO lv_name1
              FROM adrc WHERE addrnumber = gt_t001w-adrnr.

          WHEN '311'.
            IF gt_mseg-umlgo(1) = '1' AND gt_mseg-lgort(1) = '1'.
              CONTINUE.
            ELSEIF gt_mseg-umlgo(1) = '2' AND gt_mseg-lgort(1) = '2'.
              IF gt_mseg-umlgo(2) = gt_mseg-lgort(2).
                CONTINUE.
              ENDIF.
            ENDIF.

            CLEAR: lv_adrnr,lv_name1,lv_ket.
            lv_code = gt_mseg-umwrk.

            SELECT SINGLE adrnr INTO lv_adrnr
              FROM twlad WHERE werks = gt_mseg-umwrk
                           AND lgort = gt_mseg-umlgo.
            IF sy-subrc NE 0.
              SELECT SINGLE adrnr INTO lv_adrnr
                FROM t001w WHERE werks = gt_mseg-umwrk.
            ENDIF.

            SELECT SINGLE name3 INTO lv_name1
              FROM adrc WHERE addrnumber = lv_adrnr.


          WHEN '653' OR '655' OR 'Z13' OR '913' OR
               '654' OR '656' OR 'Z14' OR '914'.
            CLEAR: gt_kna1_655.
            lv_code = gt_mseg-wempf.
            READ TABLE gt_kna1_655 WITH KEY kunnr = lv_code.
            lv_name1 = gt_kna1_655-name1.

          WHEN '675' OR '676'.
            CLEAR: gt_mseg_641,gt_t001w.
            READ TABLE gt_mseg_641 WITH KEY mblnr = gt_mseg-mblnr
                                            mjahr = gt_mseg-mjahr
                                            parent_id = gt_mseg-line_id.
*                                          matnr = gt_mseg-matnr
*                                          charg = gt_mseg-charg.
            lv_code = gt_mseg_641-werks.
            READ TABLE gt_t001w WITH KEY werks = lv_code(4).
            lv_name1 = gt_t001w-name1.
            SELECT SINGLE name3 INTO lv_name1
              FROM adrc WHERE addrnumber = gt_t001w-adrnr.

          WHEN '919' OR '701' OR '703' OR '707' OR
               '712' OR '714' OR '716' OR '718'.
            lv_code  = '88'.
            lv_name1 = 'Stock Opname'.
        ENDCASE.

        IF gt_mseg-shkzg = 'H'.
          MULTIPLY gt_mseg-menge BY -1.
        ENDIF.

        ADD 1 TO lv_norut2.

        READ TABLE gt_bpom ASSIGNING <fs_bpom> WITH KEY matnr = gt_mseg-matnr
                                                        bets = gt_mseg-charg
                                                        in_code = lv_code.
        IF sy-subrc = 0.
          <fs_bpom>-in_jumlah = <fs_bpom>-in_jumlah + gt_mseg-menge.
        ELSE.
          PERFORM f_append_init_lines USING gt_mseg-matnr.
          <fs_bpom>-bets      = gt_mseg-charg.
          <fs_bpom>-in_jumlah = gt_mseg-menge.
          <fs_bpom>-in_code   = lv_code.
          <fs_bpom>-in_name1  = lv_name1.
          <fs_bpom>-norut     = lv_norut2.
        ENDIF.
      ENDIF.
    ENDIF.

** Pengeluaran
    IF gt_mseg-bwart IN gr_out. "AND
*       gt_mseg-shkzg EQ 'H'.

      IF ( gt_mseg-bwart = '311' OR gt_mseg-bwart = '919' ) AND
         gt_mseg-shkzg = 'S'.
      ELSEIF ( gt_mseg-bwart NE '311' AND gt_mseg-bwart NE '919' ) AND
               gt_mseg-xauto = 'X'.
      ELSE.

        CLEAR: lv_code,lv_name1.
        CASE gt_mseg-bwart.
          WHEN '161' OR '162'.
            CLEAR: gt_ekko,gt_lfa1_101.
            READ TABLE gt_ekko WITH KEY ebeln = gt_mseg-ebeln.
            lv_code = gt_ekko-lifnr.
            READ TABLE gt_lfa1_101 WITH KEY lifnr = lv_code.
            lv_name1 = gt_lfa1_101-name1.

          WHEN '303' OR '641' OR '645' OR
               '304' OR '642' OR '646'.
            CLEAR: gt_mseg_641,gt_t001w.
            READ TABLE gt_mseg_641 WITH KEY mblnr = gt_mseg-mblnr
                                            mjahr = gt_mseg-mjahr
                                            parent_id = gt_mseg-line_id.
*                                          matnr = gt_mseg-matnr
*                                          charg = gt_mseg-charg.
            lv_code = gt_mseg_641-werks.
            READ TABLE gt_t001w WITH KEY werks = lv_code(4).
            lv_name1 = gt_t001w-name1.
            SELECT SINGLE name3 INTO lv_name1
              FROM adrc WHERE addrnumber = gt_t001w-adrnr.

            PERFORM f_tujuan_for_641 USING    gt_mseg_641 'BPOM'
                                     CHANGING lv_code lv_ket lv_name1.

          WHEN '601' OR 'Z07' OR '602' OR 'Z08'.
            CLEAR: gt_kna1_655.
            lv_code = gt_mseg-wempf.
            READ TABLE gt_kna1_655 WITH KEY kunnr = lv_code.
            lv_name1 = gt_kna1_655-name1.

          WHEN '311'.
            IF gt_mseg-umlgo(1) = '1' AND gt_mseg-lgort(1) = '1'.
              CONTINUE.
            ELSEIF gt_mseg-umlgo(1) = '2' AND gt_mseg-lgort(1) = '2'.
              IF gt_mseg-umlgo(2) = gt_mseg-lgort(2).
                CONTINUE.
              ENDIF.
            ENDIF.

            CLEAR: lv_adrnr,lv_name1,lv_ket.
            lv_code = gt_mseg-umwrk.

            SELECT SINGLE adrnr INTO lv_adrnr
              FROM twlad WHERE werks = gt_mseg-umwrk
                           AND lgort = gt_mseg-umlgo.
            IF sy-subrc NE 0.
              SELECT SINGLE adrnr INTO lv_adrnr
                FROM t001w WHERE werks = gt_mseg-umwrk.
            ENDIF.

            SELECT SINGLE name3 INTO lv_name1
              FROM adrc WHERE addrnumber = lv_adrnr.

          WHEN '351'.
            CLEAR: lv_adrnr,lv_name1,lv_ket.
            lv_code = gt_mseg-umwrk.

            SELECT SINGLE adrnr INTO lv_adrnr
              FROM t001w WHERE werks = gt_mseg-umwrk.

            SELECT SINGLE name3 INTO lv_name1
              FROM adrc WHERE addrnumber = lv_adrnr.

          WHEN '555' OR '920' OR '922' OR '926' OR
               '556' OR '921' OR '923' OR '927'.
            CLEAR: gt_t001w.
            lv_code = gt_mseg-werks.
            READ TABLE gt_t001w WITH KEY werks = lv_code(4).
            lv_name1 = gt_t001w-name1.
            SELECT SINGLE name3 INTO lv_name1
              FROM adrc WHERE addrnumber = gt_t001w-adrnr.

          WHEN '919' OR '702' OR '704' OR '708' OR
               '711' OR '713' OR '715' OR '717'.
            lv_code  = '88'.
            lv_name1 = 'Stock Opname'.
        ENDCASE.

        IF gt_mseg-shkzg = 'S'.
          MULTIPLY gt_mseg-menge BY -1.
        ENDIF.

        ADD 1 TO lv_norut3.

        READ TABLE gt_bpom ASSIGNING <fs_bpom> WITH KEY matnr = gt_mseg-matnr
                                                        bets = gt_mseg-charg
                                                        out_code = lv_code.
        IF sy-subrc = 0.
          <fs_bpom>-out_jumlah = <fs_bpom>-out_jumlah + gt_mseg-menge.
        ELSE.
          PERFORM f_append_init_lines USING gt_mseg-matnr.
          <fs_bpom>-bets       = gt_mseg-charg.
          <fs_bpom>-out_jumlah = gt_mseg-menge.
          <fs_bpom>-out_code   = lv_code.
          <fs_bpom>-out_name1  = lv_name1.
          <fs_bpom>-norut      = lv_norut3.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF gt_bpom[] IS NOT INITIAL.
    SELECT matnr charg vfdat hsdat
      INTO CORRESPONDING FIELDS OF TABLE lt_mch1
      FROM mch1 FOR ALL ENTRIES IN gt_bpom
      WHERE matnr = gt_bpom-matnr
        AND charg = gt_bpom-bets.

    SORT gt_bpom BY matnr bets norut.
    LOOP AT gt_bpom.
      CLEAR: lt_mch1.
      READ TABLE lt_mch1 WITH KEY matnr = gt_bpom-matnr
                                  charg = gt_bpom-bets.
      gt_bpom-vfdat = lt_mch1-vfdat.
      MODIFY gt_bpom TRANSPORTING vfdat.

      AT END OF bets.
        SUM.
        gt_bpom-sak_jumlah = gt_bpom-saw_jumlah +
                             gt_bpom-in_jumlah -
                             gt_bpom-out_jumlah.
        MODIFY gt_bpom TRANSPORTING sak_jumlah.
      ENDAT.
    ENDLOOP.

    DELETE gt_bpom WHERE saw_jumlah IS INITIAL
                     AND in_jumlah IS INITIAL
                     AND out_jumlah IS INITIAL
                     AND sak_jumlah IS INITIAL.
  ENDIF.
ENDFORM.                    " F_PROCESS_DATA_BPOM

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_KEMENKES
*&---------------------------------------------------------------------*
FORM f_process_data_kemenkes .
  DATA: lt_mch1   TYPE TABLE OF mch1 WITH HEADER LINE,
        lv_mblnr  TYPE mblnr,
        lv_mjahr  TYPE mjahr,
        lv_norut2 TYPE numc3,
        lv_norut3 TYPE numc3,
        lv_adrnr  TYPE adrnr,
        lv_code   TYPE char10,
        lv_name1  TYPE name1,
        lv_ket    TYPE char30,
        lv_seqno  TYPE numc2,
        lv_ok     TYPE flag.

  SORT: gt_ztspmmdt002 BY matnr,
        gt_makt        BY matnr,
        gt_opnstk      BY matnr charg,
        gt_mseg        BY matnr charg bwart.

  LOOP AT gt_opnstk INTO gw_opnstk.
    PERFORM f_append_init_lines2 USING gw_opnstk-matnr.
    <fs_kemenkes>-bets           = gw_opnstk-charg.
    <fs_kemenkes>-saw_jumlah     = gw_opnstk-labst.
    <fs_kemenkes>-norut      = '100'.
  ENDLOOP.

  LOOP AT gt_mseg.
    IF lv_norut2 IS INITIAL.
      lv_norut2 = '200'.
    ENDIF.
    IF lv_norut3 IS INITIAL.
      lv_norut3 = '300'.
    ENDIF.

** Pemasukan
    IF gt_mseg-bwart IN gr_in. "AND
*       gt_mseg-shkzg EQ 'S'.

      IF ( gt_mseg-bwart = '311' OR gt_mseg-bwart = '919' ) AND
         gt_mseg-shkzg = 'H'.
      ELSEIF ( gt_mseg-bwart NE '311' AND gt_mseg-bwart NE '919' ) AND
               gt_mseg-xauto = 'X'.
      ELSE.

        CLEAR: lv_seqno,lv_ok.
        PERFORM f_cek_custgrp USING gt_mseg-bwart gt_mseg-wempf '1'
                              CHANGING lv_ok lv_seqno.

        CLEAR: lv_code,lv_name1,lv_ket.
        CASE gt_mseg-bwart.
          WHEN '101' OR '102'.
            CLEAR: gt_ekko,gt_lfa1_101,gt_t001w.
            READ TABLE gt_ekko WITH KEY ebeln = gt_mseg-ebeln.

            IF gt_ekko-bsart = 'CVSR'.
              CONTINUE.
            ENDIF.

            IF gt_ekko-lifnr IS NOT INITIAL.
              lv_code = gt_ekko-lifnr.
              READ TABLE gt_lfa1_101 WITH KEY lifnr = lv_code.
*            lv_name1 = gt_lfa1_101-name1.
              SELECT SINGLE remark INTO lv_name1
                FROM adrct WHERE addrnumber = gt_lfa1_101-adrnr
                             AND langu = sy-langu.
              IF sy-subrc NE 0 OR lv_name1 IS INITIAL.
                lv_ket = gt_lfa1_101-name1.
              ENDIF.
            ELSEIF gt_ekko-reswk IS NOT INITIAL.
              lv_code = gt_ekko-reswk.
              READ TABLE gt_t001w WITH KEY werks = lv_code(4).
*            lv_name1 = gt_t001w-name1.
              SELECT SINGLE remark INTO lv_name1
                FROM adrct WHERE addrnumber = gt_t001w-adrnr
                             AND langu = sy-langu.
              IF sy-subrc NE 0 OR lv_name1 IS INITIAL.
                lv_ket = gt_t001w-name1.
                SELECT SINGLE name3 INTO lv_ket
                  FROM adrc WHERE addrnumber = gt_t001w-adrnr.
              ENDIF.
            ENDIF.

          WHEN '305' OR '306'.
            CLEAR: lv_mblnr,lv_mjahr,gt_mseg_305,gt_t001w.
            SPLIT gt_mseg-sgtxt AT '/' INTO lv_mblnr lv_mjahr.
            READ TABLE gt_mseg_305 WITH KEY mblnr = lv_mblnr
                                            mjahr = lv_mjahr
                                            matnr = gt_mseg-matnr
                                            charg = gt_mseg-charg.
            lv_code = gt_mseg_305-werks.
            READ TABLE gt_t001w WITH KEY werks = lv_code(4).
*          lv_name1 = gt_t001w-name1.
            SELECT SINGLE remark INTO lv_name1
              FROM adrct WHERE addrnumber = gt_t001w-adrnr
                           AND langu = sy-langu.
            IF sy-subrc NE 0 OR lv_name1 IS INITIAL.
              lv_ket = gt_t001w-name1.
              SELECT SINGLE name3 INTO lv_ket
                FROM adrc WHERE addrnumber = gt_t001w-adrnr.
            ENDIF.

          WHEN '311'.
            IF gt_mseg-umlgo(1) = '1' AND gt_mseg-lgort(1) = '1'.
              CONTINUE.
            ELSEIF gt_mseg-umlgo(1) = '2' AND gt_mseg-lgort(1) = '2'.
              IF gt_mseg-umlgo(2) = gt_mseg-lgort(2).
                CONTINUE.
              ENDIF.
            ENDIF.

            CLEAR: lv_adrnr,lv_name1,lv_ket.
            lv_code = gt_mseg-umwrk.

            SELECT SINGLE adrnr INTO lv_adrnr
              FROM twlad WHERE werks = gt_mseg-umwrk
                           AND lgort = gt_mseg-umlgo.
            IF sy-subrc NE 0.
              SELECT SINGLE adrnr INTO lv_adrnr
                FROM t001w WHERE werks = gt_mseg-umwrk.
            ENDIF.

            SELECT SINGLE remark INTO lv_name1
              FROM adrct WHERE addrnumber = lv_adrnr.
            IF sy-subrc NE 0.
              SELECT SINGLE name3 INTO lv_ket
                FROM adrc WHERE addrnumber = lv_adrnr.
            ENDIF.

          WHEN '653' OR '655' OR 'Z13' OR '913' OR
               '654' OR '656' OR 'Z14' OR '914'.
            CLEAR: gt_kna1_655.
            lv_code = gt_mseg-wempf.
            READ TABLE gt_kna1_655 WITH KEY kunnr = lv_code.
*          lv_name1 = gt_kna1_655-name1.
            SELECT SINGLE remark INTO lv_name1
              FROM adrct WHERE addrnumber = gt_kna1_655-adrnr
                           AND langu = sy-langu.
            IF sy-subrc NE 0 OR lv_name1 IS INITIAL.
              lv_ket = gt_kna1_655-name1.
            ENDIF.

          WHEN '675' OR '676'.
            CLEAR: gt_mseg_641,gt_t001w.
            READ TABLE gt_mseg_641 WITH KEY mblnr = gt_mseg-mblnr
                                            mjahr = gt_mseg-mjahr
                                            parent_id = gt_mseg-line_id.
*                                          matnr = gt_mseg-matnr
*                                          charg = gt_mseg-charg.
            lv_code = gt_mseg_641-werks.
            READ TABLE gt_t001w WITH KEY werks = lv_code(4).
*          lv_name1 = gt_t001w-name1.
            SELECT SINGLE remark INTO lv_name1
              FROM adrct WHERE addrnumber = gt_t001w-adrnr
                           AND langu = sy-langu.
            IF sy-subrc NE 0 OR lv_name1 IS INITIAL.
              lv_ket = gt_t001w-name1.
              SELECT SINGLE name3 INTO lv_ket
               FROM adrc WHERE addrnumber = gt_t001w-adrnr.
            ENDIF.

          WHEN '919' OR '701' OR '703' OR '707' OR
               '712' OR '714' OR '716' OR '718'.
            lv_code  = '88'.
            lv_ket   = 'Stock Opname'.
            CLEAR gt_t001w.
            READ TABLE gt_t001w WITH KEY werks = gt_mseg-werks.
            SELECT SINGLE remark INTO lv_name1
              FROM adrct WHERE addrnumber = gt_t001w-adrnr
                           AND langu = sy-langu.
        ENDCASE.

        IF gt_mseg-shkzg = 'H'.
          MULTIPLY gt_mseg-menge BY -1.
        ENDIF.

        ADD 1 TO lv_norut2.

        READ TABLE gt_kemenkes ASSIGNING <fs_kemenkes>
                               WITH KEY matnr = gt_mseg-matnr
                                        bets = gt_mseg-charg
                                        in_code = lv_code.
        IF sy-subrc = 0.
          PERFORM f_update_line USING lv_code lv_seqno.
        ELSE.
          PERFORM f_append_init_lines2 USING gt_mseg-matnr.
          PERFORM f_update_line USING lv_code lv_seqno.
          <fs_kemenkes>-bets      = gt_mseg-charg.
          <fs_kemenkes>-in_code   = lv_code.
          <fs_kemenkes>-in_name1  = lv_name1.
          <fs_kemenkes>-in_ket    = lv_ket.
          <fs_kemenkes>-norut     = lv_norut2.
        ENDIF.
      ENDIF.
    ENDIF.

** Pengeluaran
    IF gt_mseg-bwart IN gr_out. "AND
*       gt_mseg-shkzg EQ 'H'.

      IF ( gt_mseg-bwart = '311' OR gt_mseg-bwart = '919' ) AND
         gt_mseg-shkzg = 'S'.
      ELSEIF ( gt_mseg-bwart NE '311' AND gt_mseg-bwart NE '919' ) AND
               gt_mseg-xauto = 'X'.
      ELSE.

        CLEAR: lv_seqno,lv_ok.
        PERFORM f_cek_custgrp USING gt_mseg-bwart gt_mseg-wempf '2'
                              CHANGING lv_ok lv_seqno.

        IF lv_ok = 'X'.
          CLEAR: lv_code,lv_name1,lv_ket.
          CASE gt_mseg-bwart.
            WHEN '161' OR '162'.
              CLEAR: gt_ekko,gt_lfa1_101.
              READ TABLE gt_ekko WITH KEY ebeln = gt_mseg-ebeln.
              lv_code = gt_ekko-lifnr.
              READ TABLE gt_lfa1_101 WITH KEY lifnr = lv_code.
*          lv_name1 = gt_lfa1_101-name1.
              lv_ket = 'Retur'.
              SELECT SINGLE remark INTO lv_name1
                FROM adrct WHERE addrnumber = gt_lfa1_101-adrnr
                             AND langu = sy-langu.
*            IF sy-subrc NE 0.
*              lv_ket = gt_lfa1_101-name1.
*            ENDIF.

            WHEN '303' OR '641' OR '645' OR
                 '304' OR '642' OR '646'.
              CLEAR: gt_mseg_641,gt_t001w.
              READ TABLE gt_mseg_641 WITH KEY mblnr = gt_mseg-mblnr
                                              mjahr = gt_mseg-mjahr
                                              parent_id = gt_mseg-line_id.
*                                          matnr = gt_mseg-matnr
*                                          charg = gt_mseg-charg.
              lv_code = gt_mseg_641-werks.
              READ TABLE gt_t001w WITH KEY werks = lv_code(4).
*          lv_name1 = gt_t001w-name1.
              SELECT SINGLE remark INTO lv_name1
                FROM adrct WHERE addrnumber = gt_t001w-adrnr
                             AND langu = sy-langu.
              IF sy-subrc NE 0 OR lv_name1 IS INITIAL.
                lv_ket = gt_t001w-name1.
                SELECT SINGLE name3 INTO lv_ket
                  FROM adrc WHERE addrnumber = gt_t001w-adrnr.
              ENDIF.

              PERFORM f_tujuan_for_641 USING    gt_mseg_641 'KEMENKES'
                                       CHANGING lv_code lv_ket lv_name1.

            WHEN '601' OR 'Z07' OR '602' OR 'Z08'.
              CLEAR: gt_kna1_655.
              lv_code = gt_mseg-wempf.
              READ TABLE gt_kna1_655 WITH KEY kunnr = lv_code.
*          lv_name1 = gt_kna1_655-name1.
              SELECT SINGLE remark INTO lv_name1
                FROM adrct WHERE addrnumber = gt_kna1_655-adrnr
                             AND langu = sy-langu.
              IF sy-subrc NE 0 OR lv_name1 IS INITIAL.
                lv_ket = gt_kna1_655-name1.
              ENDIF.

            WHEN '311'.
              IF gt_mseg-umlgo(1) = '1' AND gt_mseg-lgort(1) = '1'.
                CONTINUE.
              ELSEIF gt_mseg-umlgo(1) = '2' AND gt_mseg-lgort(1) = '2'.
                IF gt_mseg-umlgo(2) = gt_mseg-lgort(2).
                  CONTINUE.
                ENDIF.
              ENDIF.

              CLEAR: lv_adrnr,lv_name1,lv_ket.
              lv_code = gt_mseg-umwrk.

              SELECT SINGLE adrnr INTO lv_adrnr
                FROM twlad WHERE werks = gt_mseg-umwrk
                             AND lgort = gt_mseg-umlgo.
              IF sy-subrc NE 0.
                SELECT SINGLE adrnr INTO lv_adrnr
                  FROM t001w WHERE werks = gt_mseg-umwrk.
              ENDIF.

              SELECT SINGLE remark INTO lv_name1
                FROM adrct WHERE addrnumber = lv_adrnr.
              IF sy-subrc NE 0.
                SELECT SINGLE name3 INTO lv_ket
                  FROM adrc WHERE addrnumber = lv_adrnr.
              ENDIF.

            WHEN '351'.
              CLEAR: lv_adrnr,lv_name1,lv_ket.
              lv_code = gt_mseg-umwrk.

              SELECT SINGLE adrnr INTO lv_adrnr
                FROM t001w WHERE werks = gt_mseg-umwrk.

*              SELECT SINGLE remark INTO lv_name1
*                FROM adrct WHERE addrnumber = lv_adrnr.
*              IF sy-subrc NE 0.
              SELECT SINGLE name3 INTO lv_name1 "lv_ket
                FROM adrc WHERE addrnumber = lv_adrnr.
*              ENDIF.

            WHEN '555' OR '920' OR '922' OR '926' OR
                 '556' OR '921' OR '923' OR '927'.
              CLEAR: gt_t001w.
              lv_code = gt_mseg-werks.
              READ TABLE gt_t001w WITH KEY werks = lv_code(4).
*          lv_name1 = gt_t001w-name1.
              lv_ket = 'Pemusnahan'.
              SELECT SINGLE remark INTO lv_name1
                FROM adrct WHERE addrnumber = gt_t001w-adrnr
                             AND langu = sy-langu.
*          IF sy-subrc NE 0.
*            lv_ket = gt_t001w-name1.
*          ENDIF.

            WHEN '919' OR '702' OR '704' OR '708' OR
                 '711' OR '713' OR '715' OR '717'.
              lv_code  = '88'.
              lv_ket   = 'Stock Opname'.
              CLEAR gt_t001w.
              READ TABLE gt_t001w WITH KEY werks = gt_mseg-werks.
              SELECT SINGLE remark INTO lv_name1
                FROM adrct WHERE addrnumber = gt_t001w-adrnr
                             AND langu = sy-langu.
          ENDCASE.

          IF gt_mseg-shkzg = 'S'.
            MULTIPLY gt_mseg-menge BY -1.
          ENDIF.

          ADD 1 TO lv_norut3.

          READ TABLE gt_kemenkes ASSIGNING <fs_kemenkes>
                                 WITH KEY matnr = gt_mseg-matnr
                                          bets = gt_mseg-charg
                                          out_code = lv_code.
          IF sy-subrc = 0.
            PERFORM f_update_line2 USING lv_seqno.
          ELSE.
            PERFORM f_append_init_lines2 USING gt_mseg-matnr.
            PERFORM f_update_line2 USING lv_seqno.
            <fs_kemenkes>-bets       = gt_mseg-charg.
            <fs_kemenkes>-out_code   = lv_code.
            <fs_kemenkes>-out_name1  = lv_name1.
            <fs_kemenkes>-out_ket    = lv_ket.
            <fs_kemenkes>-norut      = lv_norut3.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF gt_kemenkes[] IS NOT INITIAL.
    SELECT matnr charg vfdat hsdat
      INTO CORRESPONDING FIELDS OF TABLE lt_mch1
      FROM mch1 FOR ALL ENTRIES IN gt_kemenkes
      WHERE matnr = gt_kemenkes-matnr
        AND charg = gt_kemenkes-bets.

    SORT gt_kemenkes BY matnr bets norut.
    LOOP AT gt_kemenkes.
      CLEAR: lt_mch1,gt_a510,gt_konp.
      READ TABLE lt_mch1 WITH KEY matnr = gt_kemenkes-matnr
                                  charg = gt_kemenkes-bets.
      gt_kemenkes-vfdat = lt_mch1-vfdat.

      READ TABLE gt_a510 WITH KEY matnr = gt_kemenkes-matnr.
      READ TABLE gt_konp WITH KEY knumh = gt_a510-knumh.
      gt_kemenkes-nilai = gt_konp-kbetr.
      MODIFY gt_kemenkes TRANSPORTING vfdat nilai.


      AT END OF bets.
        SUM.
        gt_kemenkes-sak_jumlah = gt_kemenkes-saw_jumlah +
                                 ( gt_kemenkes-in_pabrik  +
                                 gt_kemenkes-in_pbf     +
                                 gt_kemenkes-in_retur   +
                                 gt_kemenkes-in_other ) -
                                 ( gt_kemenkes-out_rs     +
                                 gt_kemenkes-out_apotek +
                                 gt_kemenkes-out_pbf     +
                                 gt_kemenkes-out_dinkes +
                                 gt_kemenkes-out_puskesmas +
                                 gt_kemenkes-out_klinik +
                                 gt_kemenkes-out_tobat +
                                 gt_kemenkes-out_retur +
                                 gt_kemenkes-out_other ).
        MODIFY gt_kemenkes TRANSPORTING sak_jumlah.
      ENDAT.
    ENDLOOP.

    DELETE gt_kemenkes WHERE sak_jumlah = 0 AND
                             saw_jumlah = 0 AND
                             in_pabrik  = 0 AND
                             in_pbf     = 0 AND
                             in_retur   = 0 AND
                             in_other   = 0 AND
                             out_rs     = 0 AND
                             out_apotek = 0 AND
                             out_pbf    = 0 AND
                             out_dinkes = 0 AND
                             out_puskesmas = 0 AND
                             out_klinik = 0 AND
                             out_tobat  = 0 AND
                             out_retur  = 0 AND
                             out_other  = 0.
  ENDIF.
ENDFORM.                    " F_PROCESS_DATA_KEMENKES

*&---------------------------------------------------------------------*
*&      Form  F_SUB_HEADER_BPOM
*&---------------------------------------------------------------------*
FORM f_sub_header_bpom .
  WRITE: / '|' NO-GAP,
   (3)' ' CENTERED NO-GAP, '|' NO-GAP,
  (40)' ' CENTERED NO-GAP, '|' NO-GAP,
  (10)' ' CENTERED NO-GAP, '|' NO-GAP,
 (197)'Informasi Produk' CENTERED NO-GAP, '|' NO-GAP,
  (17)' ' CENTERED NO-GAP, '|' NO-GAP,
  (48)'Pemasukan' CENTERED NO-GAP, '|' NO-GAP,
  (48)'Pengeluaran' CENTERED NO-GAP, '|' NO-GAP,
  (17)' ' CENTERED NO-GAP, '|' NO-GAP,
  (30)' ' CENTERED NO-GAP, '|' NO-GAP.


  WRITE: / '|' NO-GAP,
   (3)'No' CENTERED NO-GAP, '|' NO-GAP,
  (40)'Zat Aktif' CENTERED NO-GAP, '|' NO-GAP,
  (10)'Kode' CENTERED NO-GAP, '|' NO-GAP,
  (41)sy-uline CENTERED NO-GAP,
  (21)sy-uline CENTERED NO-GAP,
  (41)sy-uline CENTERED NO-GAP,
  (41)sy-uline CENTERED NO-GAP,
  (11)sy-uline CENTERED NO-GAP,
  (12)sy-uline CENTERED NO-GAP,
  (30)sy-uline CENTERED NO-GAP, '|' NO-GAP,
  (17)'Stok Awal' CENTERED NO-GAP, '|' NO-GAP,
  (31)sy-uline NO-GAP,
  (17)sy-uline CENTERED NO-GAP, '|' NO-GAP,
  (18)sy-uline NO-GAP,
  (30)sy-uline NO-GAP, '|' NO-GAP,
  (17)'Stok Akhir' CENTERED NO-GAP, '|' NO-GAP,
  (30)'Keterangan' CENTERED NO-GAP, '|' NO-GAP.

  WRITE: / '|' NO-GAP,
   (3)' ' CENTERED NO-GAP, '|' NO-GAP,
  (40)' ' CENTERED NO-GAP, '|' NO-GAP,
  (10)'Produk' CENTERED NO-GAP, '|' NO-GAP,
  (40)'Nama Produk' CENTERED NO-GAP, '|' NO-GAP,
  (20)'Bentuk Sediaan' CENTERED NO-GAP, '|' NO-GAP,
  (40)'Kekuatan' CENTERED NO-GAP, '|' NO-GAP,
  (40)'Kemasan' CENTERED NO-GAP, '|' NO-GAP,
  (10)'Bets' CENTERED NO-GAP, '|' NO-GAP,
  (11)'Tanggal ED' CENTERED NO-GAP, '|' NO-GAP,
  (30)'Produsen' CENTERED NO-GAP, '|' NO-GAP,
  (17)'(box/botol)*' CENTERED NO-GAP, '|' NO-GAP,
  (30)'Sumber' CENTERED NO-GAP, '|' NO-GAP,
  (17)'Jumlah' CENTERED NO-GAP, '|' NO-GAP,
  (17)'Jumlah' CENTERED NO-GAP, '|' NO-GAP,
  (30)'Tujuan/sarana' CENTERED NO-GAP, '|' NO-GAP,
  (17)'(box/botol)*' CENTERED NO-GAP, '|' NO-GAP,
  (30)' ' CENTERED NO-GAP, '|' NO-GAP.

*  PERFORM f_hdr_uline.
  WRITE (420)sy-uline.
ENDFORM.                    " F_SUB_HEADER_BPOM

*&---------------------------------------------------------------------*
*&      Form  F_SUB_HEADER_KEMENKES
*&---------------------------------------------------------------------*
FORM f_sub_header_kemenkes .

  WRITE: / '|' NO-GAP,
   (3)' ' CENTERED NO-GAP, '|' NO-GAP,
  (10)' ' CENTERED NO-GAP, '|' NO-GAP,
  (20)' ' CENTERED NO-GAP, '|' NO-GAP,
  (40)' ' CENTERED NO-GAP, '|' NO-GAP,
   (7)' ' CENTERED NO-GAP, '|' NO-GAP,
  (17)' ' CENTERED NO-GAP, '|' NO-GAP,
  (10)' ' CENTERED NO-GAP, '|' NO-GAP,
  (11)' ' CENTERED NO-GAP, '|' NO-GAP,
  (30)' ' CENTERED NO-GAP, '|' NO-GAP,
  (20)' ' CENTERED NO-GAP, '|' NO-GAP,
  (71)'Jumlah Pemasukan ' CENTERED NO-GAP, '|' NO-GAP,
 (125)'Jumlah Pengeluaran' CENTERED NO-GAP, '|' NO-GAP,
  (30)' ' CENTERED NO-GAP, '|' NO-GAP,
  (20)' ' CENTERED NO-GAP, '|' NO-GAP,
  (15)' ' CENTERED NO-GAP, '|' NO-GAP,
  (17)' ' CENTERED NO-GAP, '|' NO-GAP.

  WRITE: / '|' NO-GAP,
   (3)'No' CENTERED NO-GAP, '|' NO-GAP,
  (10)'Kode' CENTERED NO-GAP, '|' NO-GAP,
  (20)'NIE' CENTERED NO-GAP, '|' NO-GAP,
  (40)'Nama' CENTERED NO-GAP, '|' NO-GAP,
   (7)'Kemasan' CENTERED NO-GAP, '|' NO-GAP,
  (17)'Stok' CENTERED NO-GAP, '|' NO-GAP,
  (10)'Bets' CENTERED NO-GAP, '|' NO-GAP,
  (11)'Tanggal' CENTERED NO-GAP, '|' NO-GAP,
  (30)'Sumber' CENTERED NO-GAP, '|' NO-GAP,
  (20)'Keterangan' CENTERED NO-GAP, '|' NO-GAP,
  (18)sy-uline CENTERED NO-GAP,
  (18)sy-uline CENTERED NO-GAP,
  (18)sy-uline CENTERED NO-GAP,
  (17)sy-uline CENTERED NO-GAP, '|' NO-GAP,
  (18)sy-uline CENTERED NO-GAP,
  (18)sy-uline CENTERED NO-GAP,
  (18)sy-uline CENTERED NO-GAP,
  (18)sy-uline CENTERED NO-GAP,
  (18)sy-uline CENTERED NO-GAP,
  (18)sy-uline CENTERED NO-GAP,
  (17)sy-uline CENTERED NO-GAP, '|' NO-GAP,
  (30)'Tujuan' CENTERED NO-GAP, '|' NO-GAP,
  (20)'Keterangan' CENTERED NO-GAP, '|' NO-GAP,
  (15)'HJD' CENTERED NO-GAP, '|' NO-GAP,
  (17)'Stok' CENTERED NO-GAP, '|' NO-GAP.

  WRITE: / '|' NO-GAP,
   (3)' ' CENTERED NO-GAP, '|' NO-GAP,
  (10)'Produk' CENTERED NO-GAP, '|' NO-GAP,
  (20)' ' CENTERED NO-GAP, '|' NO-GAP,
  (40)'Produk' CENTERED NO-GAP, '|' NO-GAP,
   (7)' ' CENTERED NO-GAP, '|' NO-GAP,
  (17)'Awal' CENTERED NO-GAP, '|' NO-GAP,
  (10)' ' CENTERED NO-GAP, '|' NO-GAP,
  (11)'Kadaluarsa' CENTERED NO-GAP, '|' NO-GAP,
  (30)'Pemasukan' CENTERED NO-GAP, '|' NO-GAP,
  (20)' ' CENTERED NO-GAP, '|' NO-GAP,
  (17)'Pabrik' CENTERED NO-GAP, '|' NO-GAP,
  (17)'PBF' CENTERED NO-GAP, '|' NO-GAP,
  (17)'Retur' CENTERED NO-GAP, '|' NO-GAP,
  (17)'Lainnya' CENTERED NO-GAP, '|' NO-GAP,
  (17)'RS' CENTERED NO-GAP, '|' NO-GAP,
  (17)'Apotek' CENTERED NO-GAP, '|' NO-GAP,
  (17)'PBF' CENTERED NO-GAP, '|' NO-GAP,
  (17)'Dinas Kesehatan' CENTERED NO-GAP, '|' NO-GAP,
  (17)'Puskesmas' CENTERED NO-GAP, '|' NO-GAP,
  (17)'Klinik' CENTERED NO-GAP, '|' NO-GAP,
  (17)'Toko Obat' CENTERED NO-GAP, '|' NO-GAP,
  (30)'Pengeluaran' CENTERED NO-GAP, '|' NO-GAP,
  (20)'' CENTERED NO-GAP, '|' NO-GAP,
  (15)' ' CENTERED NO-GAP, '|' NO-GAP,
  (17)'Akhir' CENTERED NO-GAP, '|' NO-GAP.

*  PERFORM f_hdr_uline.
  WRITE (463)sy-uline.
ENDFORM.                    " F_SUB_HEADER_KEMENKES

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_LINE
*&---------------------------------------------------------------------*
FORM f_update_line USING fu_code fc_seqno.
  DATA: lv_adrnr  LIKE lfa1-adrnr,
        lv_remark LIKE adrct-remark.

  IF gt_mseg-bwart IN gr_in0.
    IF gt_mseg-bwart = '101' OR gt_mseg-bwart = '102'.
      IF fu_code(4) = '0200'.
        <fs_kemenkes>-in_pbf = <fs_kemenkes>-in_pbf + gt_mseg-menge.
      ELSE.
        CLEAR: lv_adrnr,lv_remark.
        SELECT SINGLE adrnr INTO lv_adrnr FROM lfa1 WHERE lifnr = gt_mseg-lifnr.
        SELECT SINGLE remark INTO lv_remark FROM adrct WHERE addrnumber = lv_adrnr.
        IF lv_remark(1) = 'P'.
          <fs_kemenkes>-in_pbf = <fs_kemenkes>-in_pbf + gt_mseg-menge.
        ELSE.
          <fs_kemenkes>-in_pabrik = <fs_kemenkes>-in_pabrik + gt_mseg-menge.
        ENDIF.
      ENDIF.
    ELSE.
      <fs_kemenkes>-in_pabrik = <fs_kemenkes>-in_pabrik + gt_mseg-menge.
    ENDIF.
  ELSEIF gt_mseg-bwart IN gr_in1.
    IF gt_mseg-bwart = '101' OR gt_mseg-bwart = '102'.
      IF fu_code(4) = '0200'.
        <fs_kemenkes>-in_pbf = <fs_kemenkes>-in_pbf + gt_mseg-menge.
      ELSE.
        CLEAR: lv_adrnr,lv_remark.
        SELECT SINGLE adrnr INTO lv_adrnr FROM lfa1 WHERE lifnr = gt_mseg-lifnr.
        SELECT SINGLE remark INTO lv_remark FROM adrct WHERE addrnumber = lv_adrnr.
        IF lv_remark(1) = 'P'.
          <fs_kemenkes>-in_pbf = <fs_kemenkes>-in_pbf + gt_mseg-menge.
        ELSE.
          <fs_kemenkes>-in_pabrik = <fs_kemenkes>-in_pabrik + gt_mseg-menge.
        ENDIF.
      ENDIF.
    ELSEIF ( gt_mseg-bwart = '305' AND gt_mseg_305-grund NE '10' ) OR
           ( gt_mseg-bwart = '306' AND gt_mseg_305-grund NE '10' ).
      <fs_kemenkes>-in_retur = <fs_kemenkes>-in_retur + gt_mseg-menge.
    ELSEIF gt_mseg-bwart = '311'.
      <fs_kemenkes>-in_pbf = <fs_kemenkes>-in_pbf + gt_mseg-menge.
    ELSE.
      <fs_kemenkes>-in_pbf = <fs_kemenkes>-in_pbf + gt_mseg-menge.
    ENDIF.
  ELSEIF gt_mseg-bwart IN gr_in2.
    <fs_kemenkes>-in_retur = <fs_kemenkes>-in_retur + gt_mseg-menge.
  ELSE.
    CASE fc_seqno.
      WHEN '10'.
        <fs_kemenkes>-in_pabrik = <fs_kemenkes>-in_pabrik + gt_mseg-menge.
      WHEN '11'.
        IF ( gt_mseg-bwart = '305' AND gt_mseg_305-grund NE '10' ) OR
           ( gt_mseg-bwart = '306' AND gt_mseg_305-grund NE '10' ).
          <fs_kemenkes>-in_retur = <fs_kemenkes>-in_retur + gt_mseg-menge.
        ELSEIF gt_mseg-bwart = '311'.
          <fs_kemenkes>-in_pbf = <fs_kemenkes>-in_pbf + gt_mseg-menge.
        ELSE.
          <fs_kemenkes>-in_pbf = <fs_kemenkes>-in_pbf + gt_mseg-menge.
        ENDIF.
      WHEN '12'.
        <fs_kemenkes>-in_retur = <fs_kemenkes>-in_retur + gt_mseg-menge.
      WHEN '13'.
        <fs_kemenkes>-in_other = <fs_kemenkes>-in_other + gt_mseg-menge.
      WHEN OTHERS.
        <fs_kemenkes>-in_other = <fs_kemenkes>-in_other + gt_mseg-menge.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_UPDATE_LINE

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_LINE2
*&---------------------------------------------------------------------*
FORM f_update_line2 USING fc_seqno.
  IF fc_seqno IS INITIAL.
    IF gt_mseg-bwart IN gr_out0.
      <fs_kemenkes>-out_rs = <fs_kemenkes>-out_rs + gt_mseg-menge.
    ELSEIF gt_mseg-bwart IN gr_out1.
      <fs_kemenkes>-out_apotek = <fs_kemenkes>-out_apotek + gt_mseg-menge.
    ELSEIF gt_mseg-bwart IN gr_out2.
      <fs_kemenkes>-out_pbf = <fs_kemenkes>-out_pbf + gt_mseg-menge.
    ELSEIF gt_mseg-bwart IN gr_out3.
      <fs_kemenkes>-out_dinkes = <fs_kemenkes>-out_dinkes + gt_mseg-menge.
    ELSEIF gt_mseg-bwart IN gr_out4.
      <fs_kemenkes>-out_puskesmas = <fs_kemenkes>-out_puskesmas + gt_mseg-menge.
    ELSEIF gt_mseg-bwart IN gr_out5.
      <fs_kemenkes>-out_klinik = <fs_kemenkes>-out_klinik + gt_mseg-menge.
    ELSEIF gt_mseg-bwart IN gr_out6.
      <fs_kemenkes>-out_tobat = <fs_kemenkes>-out_tobat + gt_mseg-menge.
    ELSEIF gt_mseg-bwart IN gr_out7.
      <fs_kemenkes>-out_retur = <fs_kemenkes>-out_retur + gt_mseg-menge.
    ELSE.
      <fs_kemenkes>-out_other = <fs_kemenkes>-out_other + gt_mseg-menge.
    ENDIF.
  ELSE.
    CASE fc_seqno.
      WHEN '20'.
        <fs_kemenkes>-out_rs = <fs_kemenkes>-out_rs + gt_mseg-menge.
      WHEN '21'.
        <fs_kemenkes>-out_apotek = <fs_kemenkes>-out_apotek + gt_mseg-menge.
      WHEN '22'.
        IF ( gt_mseg-bwart = '303' AND gt_mseg-grund NE '10') OR
           ( gt_mseg-bwart = '304' AND gt_mseg-grund NE '10').
          <fs_kemenkes>-out_retur = <fs_kemenkes>-out_retur + gt_mseg-menge.
        ELSEIF gt_mseg-bwart = '311'.
          <fs_kemenkes>-out_pbf = <fs_kemenkes>-out_pbf + gt_mseg-menge.
        ELSE.
          <fs_kemenkes>-out_pbf = <fs_kemenkes>-out_pbf + gt_mseg-menge.
        ENDIF.
      WHEN '23'.
        <fs_kemenkes>-out_dinkes = <fs_kemenkes>-out_dinkes + gt_mseg-menge.
      WHEN '24'.
        <fs_kemenkes>-out_puskesmas = <fs_kemenkes>-out_puskesmas + gt_mseg-menge.
      WHEN '25'.
        <fs_kemenkes>-out_klinik = <fs_kemenkes>-out_klinik + gt_mseg-menge.
      WHEN '26'.
        <fs_kemenkes>-out_tobat = <fs_kemenkes>-out_tobat + gt_mseg-menge.
      WHEN '27'.
        <fs_kemenkes>-out_retur = <fs_kemenkes>-out_retur + gt_mseg-menge.
      WHEN OTHERS.
        <fs_kemenkes>-out_other = <fs_kemenkes>-out_other + gt_mseg-menge.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_UPDATE_LINE2

*&---------------------------------------------------------------------*
*&      Form  F_GET_SUMBER
*&---------------------------------------------------------------------*
FORM f_get_sumber .
  DATA: lt_mseg_temp LIKE gt_mseg OCCURS 0 WITH HEADER LINE,
        lt_ekko_temp TYPE TABLE OF ekko WITH HEADER LINE,
        lv_gjahr     TYPE gjahr.

  SELECT * INTO TABLE gt_t001w
    FROM t001w.

** 101
  CLEAR lt_mseg_temp[].
  lt_mseg_temp[] = gt_mseg[].
  DELETE lt_mseg_temp WHERE bwart NE '101'
                        AND bwart NE '102'
                        AND bwart NE '161'
                        AND bwart NE '162'.

  IF lt_mseg_temp[] IS NOT INITIAL.
    SELECT ebeln lifnr reswk bsart
      INTO CORRESPONDING FIELDS OF TABLE gt_ekko
      FROM ekko FOR ALL ENTRIES IN lt_mseg_temp
      WHERE ebeln = lt_mseg_temp-ebeln.

    IF sy-subrc = 0.
      CLEAR lt_ekko_temp[].
      lt_ekko_temp[] = gt_ekko[].
      DELETE lt_ekko_temp WHERE lifnr EQ space.
      IF lt_ekko_temp[] IS NOT INITIAL.
        SELECT lifnr name1 adrnr
          INTO CORRESPONDING FIELDS OF TABLE gt_lfa1_101
          FROM lfa1 FOR ALL ENTRIES IN lt_ekko_temp
          WHERE lifnr = lt_ekko_temp-lifnr.
      ENDIF.
    ENDIF.
  ENDIF.

** 305
  CLEAR: lv_gjahr,lt_mseg_temp[].
  lv_gjahr = p_gjahr - 1.
  lt_mseg_temp[] = gt_mseg[].
  DELETE lt_mseg_temp WHERE bwart NE '305'
                        AND bwart NE '306'.
  SORT lt_mseg_temp BY sgtxt.
  DELETE ADJACENT DUPLICATES FROM lt_mseg_temp COMPARING sgtxt.

  IF lt_mseg_temp[] IS NOT INITIAL.
    SELECT mblnr mjahr zeile bwart xauto matnr werks lgort
           charg shkzg grund
      INTO CORRESPONDING FIELDS OF TABLE gt_mseg_305
      FROM mseg FOR ALL ENTRIES IN lt_mseg_temp
      WHERE mblnr = lt_mseg_temp-sgtxt(10)
        AND mjahr BETWEEN lv_gjahr AND p_gjahr
        AND bwart IN ('303','304')
        AND xauto = space.
  ENDIF.

** 303, 641, 645
  CLEAR: lt_mseg_temp[].
  lt_mseg_temp[] = gt_mseg[].
  DELETE lt_mseg_temp WHERE bwart NE '303'
                        AND bwart NE '304'
                        AND bwart NE '641'
                        AND bwart NE '642'
                        AND bwart NE '645'
                        AND bwart NE '646'
                        AND bwart NE '675'
                        AND bwart NE '676'.
*  SORT lt_mseg_temp BY mblnr mjahr.
*  DELETE ADJACENT DUPLICATES FROM lt_mseg_temp COMPARING mblnr mjahr.

  IF lt_mseg_temp[] IS NOT INITIAL.
    SELECT mblnr mjahr zeile line_id parent_id bwart xauto
           matnr werks lgort charg shkzg kunnr
      INTO CORRESPONDING FIELDS OF TABLE gt_mseg_641
      FROM mseg FOR ALL ENTRIES IN lt_mseg_temp
      WHERE mblnr = lt_mseg_temp-mblnr
        AND mjahr = lt_mseg_temp-mjahr
        AND parent_id = lt_mseg_temp-line_id.
*        AND bwart IN ('303','641')
*        AND xauto = 'X'.
  ENDIF.

** 655, 653, 601, Z07
  CLEAR lt_mseg_temp[].
  lt_mseg_temp[] = gt_mseg[].
  DELETE lt_mseg_temp WHERE bwart NE '655'
                        AND bwart NE '656'
                        AND bwart NE '653'
                        AND bwart NE '654'
                        AND bwart NE '601'
                        AND bwart NE '602'
                        AND bwart NE '641'
                        AND bwart NE '642'
                        AND bwart NE '645'
                        AND bwart NE '646'
                        AND bwart NE '675'
                        AND bwart NE '676'
                        AND bwart NE 'Z07'
                        AND bwart NE 'Z08'
                        AND bwart NE 'Z13'
                        AND bwart NE 'Z14'
                        AND bwart NE '913'
                        AND bwart NE '914'.

  IF lt_mseg_temp[] IS NOT INITIAL.
    SELECT kunnr name1 adrnr
      INTO CORRESPONDING FIELDS OF TABLE gt_kna1_655
      FROM kna1 FOR ALL ENTRIES IN lt_mseg_temp
      WHERE kunnr = lt_mseg_temp-wempf(10).
  ENDIF.

** 675
*  CLEAR lt_mseg_temp[].
*  lt_mseg_temp[] = gt_mseg[].
*  DELETE lt_mseg_temp WHERE bwart NE '675'.
*
*  IF lt_mseg_temp[] IS NOT INITIAL.
*    SELECT mblnr mjahr zeile line_id parent_id bwart xauto matnr
*           werks lgort charg shkzg
*      INTO CORRESPONDING FIELDS OF TABLE gt_mseg_675
*      FROM mseg FOR ALL ENTRIES IN lt_mseg_temp
*      WHERE mblnr = lt_mseg_temp-mblnr
*        AND mjahr = lt_mseg_temp-mjahr
*        AND parent_id = lt_mseg_temp-line_id
*        AND bwart = '161'.
*  ENDIF.
ENDFORM.                    " F_GET_SUMBER

*&---------------------------------------------------------------------*
*&      Form  F_GET_HJP
*&---------------------------------------------------------------------*
FORM f_get_hjp .
  SELECT matnr MAX( knumh )
    INTO TABLE gt_a510
    FROM a510 WHERE kappl = 'V'
                AND kschl = 'ZN01'
                AND matnr IN s_matnr
                AND datbi GE s_budat-high
                AND datab LE s_budat-high
    GROUP BY matnr.

  IF gt_a510[] IS NOT INITIAL.
    SELECT * INTO TABLE gt_konp
      FROM konp FOR ALL ENTRIES IN gt_a510
      WHERE knumh = gt_a510-knumh.
  ENDIF.
ENDFORM.                    " F_GET_HJP

*&---------------------------------------------------------------------*
*&      Form  F_FILTER_MATERIAL
*&---------------------------------------------------------------------*
FORM f_filter_material .
  DATA: lt_mara TYPE TABLE OF mara WITH HEADER LINE.

  SELECT matnr INTO CORRESPONDING FIELDS OF TABLE lt_mara
    FROM mara AS a JOIN tdg41 AS b ON b~profl = a~profl
    WHERE matnr IN s_matnr
      AND idago EQ 'X'.

  IF sy-subrc = 0.
    CLEAR s_matnr[].
    LOOP AT lt_mara.
      CLEAR s_matnr.
      s_matnr-sign    = 'I'.
      s_matnr-option  = 'EQ'.
      s_matnr-low     = lt_mara-matnr.
      APPEND s_matnr.
    ENDLOOP.
  ELSE.
    MESSAGE 'No Phamacy Material' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.
ENDFORM.                    " F_FILTER_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_EXCEL_BPOM
*&---------------------------------------------------------------------*
FORM f_get_data_excel_bpom .
  LOOP AT gt_bpom.
    CLEAR gs_zmmst_bpom.
    gs_zmmst_bpom-zat_aktif           = gt_bpom-komposisi.
    gs_zmmst_bpom-kode_produk         = gt_bpom-matnr.
    gs_zmmst_bpom-nama_produk         = gt_bpom-maktx.
    gs_zmmst_bpom-bentuk_sediaan      = gt_bpom-btk_sedia.
    gs_zmmst_bpom-kekuatan            = gt_bpom-kekuatan_sedia.
    gs_zmmst_bpom-kemasan             = gt_bpom-kemasan.
    gs_zmmst_bpom-bets                = gt_bpom-bets.
    gs_zmmst_bpom-produsen            = gt_bpom-name1.
    gs_zmmst_bpom-sumber_pemasukan    = gt_bpom-in_name1.
    gs_zmmst_bpom-tujuan_sarana       = gt_bpom-out_name1.
    WRITE gt_bpom-vfdat TO gs_zmmst_bpom-tanggal_kedaluwarsa.
    WRITE gt_bpom-saw_jumlah TO gs_zmmst_bpom-stock_awal UNIT gt_bpom-meins.
    WRITE gt_bpom-in_jumlah TO gs_zmmst_bpom-jumlah_pemasukan UNIT gt_bpom-meins.
    WRITE gt_bpom-out_jumlah TO gs_zmmst_bpom-jumlah_pengeluaran UNIT gt_bpom-meins.
    WRITE gt_bpom-sak_jumlah TO gs_zmmst_bpom-stock_akhir UNIT gt_bpom-meins.
*    gs_ZMMST_BPOM-KETERANGAN

    CONDENSE: gs_zmmst_bpom-stock_awal,
              gs_zmmst_bpom-jumlah_pemasukan,
              gs_zmmst_bpom-jumlah_pengeluaran,
              gs_zmmst_bpom-stock_akhir.

    WRITE: gs_zmmst_bpom-stock_awal TO gs_zmmst_bpom-stock_awal RIGHT-JUSTIFIED.

    APPEND gs_zmmst_bpom TO gt_zmmst_bpom.
  ENDLOOP.
ENDFORM.                    " F_GET_DATA_EXCEL_BPOM

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DATA_EXCEL_BPOM
*&---------------------------------------------------------------------*
FORM f_list_data_excel_bpom .
  DATA: highest_column TYPE zexcel_cell_column,
        count          TYPE int4,
        col_alpha      TYPE zexcel_cell_column_alpha,
        row            TYPE zexcel_cell_row.

  CREATE OBJECT lo_excel.

  lo_worksheet = lo_excel->get_active_worksheet( ).
  lo_worksheet->set_title( ip_title = 'BPOM').

  lo_style_right = lo_excel->add_new_style( ).
  lo_style_right->alignment->horizontal = zcl_excel_style_alignment=>c_horizontal_right.
  lv_style_right_guid = lo_style_right->get_guid( ).

  ls_table_settings-table_style       = zcl_excel_table=>builtinstyle_medium2.
  ls_table_settings-show_row_stripes  = abap_true.
  ls_table_settings-nofilters         = abap_true.

  lo_worksheet->bind_table( ip_table          = gt_zmmst_bpom
                            is_table_settings = ls_table_settings ).

  LOOP AT gt_zmmst_bpom INTO gs_zmmst_bpom.
    row = sy-tabix + 3.
    lo_worksheet->set_cell_style( ip_column = 'L' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'N' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'O' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'Q' ip_row = row ip_style = lv_style_right_guid ).

    column_dimension = lo_worksheet->get_column_dimension( ip_column = 'ZZ' ).
    column_dimension->set_visible( ip_visible = abap_false ).
  ENDLOOP.

  lo_worksheet->freeze_panes( ip_num_rows = 3 ).

  highest_column = lo_worksheet->get_highest_column( ).
  count = 1.
  WHILE count <= highest_column.
    col_alpha = zcl_excel_common=>convert_column2alpha( ip_column = count ).
    column_dimension = lo_worksheet->get_column_dimension( ip_column = col_alpha ).
    column_dimension->set_auto_size( ip_auto_size = abap_true ).
    count = count + 1.
  ENDWHILE.

  lo_excel->set_active_sheet_index_by_name('BPOM').

*** Create output
  lcl_output=>output( lo_excel ).
ENDFORM.                    " F_LIST_DATA_EXCEL_BPOM

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_EXCEL_KEMENKES
*&---------------------------------------------------------------------*
FORM f_get_data_excel_kemenkes .
  LOOP AT gt_kemenkes.
    CLEAR gs_zmmst_kemenkes.
    gs_zmmst_kemenkes-kode_produk           = gt_kemenkes-matnr.
    gs_zmmst_kemenkes-kode_nie              = gt_kemenkes-nie.
    gs_zmmst_kemenkes-nama_produk           = gt_kemenkes-maktx.
*    gs_zmmst_kemenkes-kemasan               = gt_kemenkes-meins.
    gs_zmmst_kemenkes-kemasan               = gt_kemenkes-kemasan.
    gs_zmmst_kemenkes-bets                  = gt_kemenkes-bets.
    gs_zmmst_kemenkes-sumber_pemasukan      = gt_kemenkes-in_name1.
    gs_zmmst_kemenkes-keterangan_pemasukan  = gt_kemenkes-in_ket.
    gs_zmmst_kemenkes-tujuan_keluar         = gt_kemenkes-out_name1.
    gs_zmmst_kemenkes-keterangan_keluar     = gt_kemenkes-out_ket.

    WRITE gt_kemenkes-vfdat TO gs_zmmst_kemenkes-tanggal_kedaluwarsa.
    WRITE gt_kemenkes-saw_jumlah TO gs_zmmst_kemenkes-stock_awal UNIT gt_kemenkes-meins.
    WRITE gt_kemenkes-in_pabrik TO gs_zmmst_kemenkes-masuk_pabrik UNIT gt_kemenkes-meins.
    WRITE gt_kemenkes-in_pbf TO gs_zmmst_kemenkes-masuk_pbf UNIT gt_kemenkes-meins.
    WRITE gt_kemenkes-in_retur TO gs_zmmst_kemenkes-masuk_retur UNIT gt_kemenkes-meins.
    WRITE gt_kemenkes-in_other TO gs_zmmst_kemenkes-masuk_lain UNIT gt_kemenkes-meins.
    WRITE gt_kemenkes-out_rs TO gs_zmmst_kemenkes-keluar_rs UNIT gt_kemenkes-meins.
    WRITE gt_kemenkes-out_apotek TO gs_zmmst_kemenkes-keluar_apotek UNIT gt_kemenkes-meins.
    WRITE gt_kemenkes-out_pbf TO gs_zmmst_kemenkes-keluar_pbf UNIT gt_kemenkes-meins.
    WRITE gt_kemenkes-out_dinkes TO gs_zmmst_kemenkes-keluar_dinkes UNIT gt_kemenkes-meins.
    WRITE gt_kemenkes-out_puskesmas TO gs_zmmst_kemenkes-keluar_puskesmas UNIT gt_kemenkes-meins.
    WRITE gt_kemenkes-out_klinik TO gs_zmmst_kemenkes-keluar_klinik UNIT gt_kemenkes-meins.
    WRITE gt_kemenkes-out_tobat TO gs_zmmst_kemenkes-keluar_tobat UNIT gt_kemenkes-meins.
    WRITE gt_kemenkes-out_retur TO gs_zmmst_kemenkes-keluar_retur UNIT gt_kemenkes-meins.
    WRITE gt_kemenkes-out_other TO gs_zmmst_kemenkes-keluar_other UNIT gt_kemenkes-meins.
    WRITE gt_kemenkes-nilai TO gs_zmmst_kemenkes-hjd CURRENCY 'IDR'.
    WRITE gt_kemenkes-sak_jumlah TO gs_zmmst_kemenkes-stock_akhir UNIT gt_kemenkes-meins.

    CONDENSE: gs_zmmst_kemenkes-stock_awal,
              gs_zmmst_kemenkes-masuk_pabrik,
              gs_zmmst_kemenkes-masuk_pbf,
              gs_zmmst_kemenkes-masuk_retur,
              gs_zmmst_kemenkes-masuk_lain,
              gs_zmmst_kemenkes-keluar_rs,
              gs_zmmst_kemenkes-keluar_apotek,
              gs_zmmst_kemenkes-keluar_pbf,
              gs_zmmst_kemenkes-keluar_dinkes,
              gs_zmmst_kemenkes-keluar_puskesmas,
              gs_zmmst_kemenkes-keluar_klinik,
              gs_zmmst_kemenkes-keluar_tobat,
              gs_zmmst_kemenkes-keluar_retur,
              gs_zmmst_kemenkes-keluar_other,
              gs_zmmst_kemenkes-hjd,
              gs_zmmst_kemenkes-stock_akhir.

    WRITE: gs_zmmst_kemenkes-stock_awal TO gs_zmmst_kemenkes-stock_awal RIGHT-JUSTIFIED.

    APPEND gs_zmmst_kemenkes TO gt_zmmst_kemenkes.
  ENDLOOP.
ENDFORM.                    " F_GET_DATA_EXCEL_KEMENKES

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DATA_EXCEL_KEMENKES
*&---------------------------------------------------------------------*
FORM f_list_data_excel_kemenkes .
  DATA: highest_column TYPE zexcel_cell_column,
        count          TYPE int4,
        col_alpha      TYPE zexcel_cell_column_alpha,
        row            TYPE zexcel_cell_row.

  CREATE OBJECT lo_excel.

  lo_worksheet = lo_excel->get_active_worksheet( ).
  lo_worksheet->set_title( ip_title = 'KEMENKES').

  lo_style_right = lo_excel->add_new_style( ).
  lo_style_right->alignment->horizontal = zcl_excel_style_alignment=>c_horizontal_right.
  lv_style_right_guid = lo_style_right->get_guid( ).

  ls_table_settings-table_style       = zcl_excel_table=>builtinstyle_medium2.
  ls_table_settings-show_row_stripes  = abap_true.
  ls_table_settings-nofilters         = abap_true.

  lo_worksheet->bind_table( ip_table          = gt_zmmst_kemenkes
                            is_table_settings = ls_table_settings ).

  LOOP AT gt_zmmst_kemenkes INTO gs_zmmst_kemenkes.
    row = sy-tabix + 3.
    lo_worksheet->set_cell_style( ip_column = 'G' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'L' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'M' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'N' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'O' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'P' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'Q' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'R' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'S' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'T' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'U' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'V' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'W' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'X' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'AB' ip_row = row ip_style = lv_style_right_guid ).

    column_dimension = lo_worksheet->get_column_dimension( ip_column = 'ZZ' ).
    column_dimension->set_visible( ip_visible = abap_false ).
  ENDLOOP.

  lo_worksheet->freeze_panes( ip_num_rows = 3 ).

  highest_column = lo_worksheet->get_highest_column( ).
  count = 1.
  WHILE count <= highest_column.
    col_alpha = zcl_excel_common=>convert_column2alpha( ip_column = count ).
    column_dimension = lo_worksheet->get_column_dimension( ip_column = col_alpha ).
    column_dimension->set_auto_size( ip_auto_size = abap_true ).
    count = count + 1.
  ENDWHILE.

  lo_excel->set_active_sheet_index_by_name('KEMENKES').

*** Create output
  lcl_output=>output( lo_excel ).
ENDFORM.                    " F_LIST_DATA_EXCEL_KEMENKES

*&---------------------------------------------------------------------*
*&      Form  F_CEK_CUSTGRP
*&---------------------------------------------------------------------*
FORM f_cek_custgrp  USING    fu_bwart fu_wempf fu_segno
                    CHANGING fc_ok fc_seqno.
  DATA: lv_kdgrp TYPE kdgrp,
        lv_kvgr3 TYPE kvgr3.

  IF fu_bwart = '601' OR fu_bwart = '602' OR
     fu_bwart = 'Z07' OR fu_bwart = 'Z08'.
    SELECT SINGLE kdgrp kvgr3
      INTO (lv_kdgrp,lv_kvgr3)
      FROM knvv WHERE kunnr = fu_wempf(10)
                  AND vkorg = p_bukrs
                  AND vtweg = '10'
                  AND spart = '00'.

    CLEAR: gt_ztspmmdt003,gt_ztspmmdt005.
    READ TABLE gt_ztspmmdt003 WITH KEY bwart = gt_mseg-bwart
                                       seqno(1) = fu_segno.
    READ TABLE gt_ztspmmdt005 WITH KEY seqno = gt_ztspmmdt003-seqno.

    IF sy-subrc = 0.
      READ TABLE gt_ztspmmdt005 WITH KEY kvgr3 = lv_kvgr3.
      IF sy-subrc = 0.
        fc_ok = 'X'.
        fc_seqno = gt_ztspmmdt005-seqno.
      ELSE.
        READ TABLE gt_ztspmmdt005 WITH KEY kdgrp = lv_kdgrp.
        IF sy-subrc = 0.
          fc_ok = 'X'.
          fc_seqno = gt_ztspmmdt005-seqno.
        ENDIF.
      ENDIF.
    ELSE.
      fc_ok = 'X'.
    ENDIF.
  ELSE.
    CLEAR: gt_ztspmmdt003.
    READ TABLE gt_ztspmmdt003 WITH KEY bwart = gt_mseg-bwart
                                       seqno(1) = fu_segno.
    fc_seqno = gt_ztspmmdt003-seqno.
    fc_ok = 'X'.
  ENDIF.
ENDFORM.                    " F_CEK_CUSTGRP

*&---------------------------------------------------------------------*
*&      Form  F_TUJUAN_FOR_641
*&---------------------------------------------------------------------*
FORM f_tujuan_for_641  USING    fu_mseg STRUCTURE mseg
                                fu_type
                       CHANGING fc_code
                                fc_ket
                                fc_name1.
  DATA: ls_t001l LIKE t001l,
        ls_twlad LIKE twlad,
        ls_adrct LIKE adrct,
        ls_adrc  LIKE adrc.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF ls_t001l
    FROM t001l WHERE kunnr = fu_mseg-kunnr.

  IF sy-subrc = 0.
    SELECT SINGLE werks lgort adrnr
      INTO CORRESPONDING FIELDS OF ls_twlad
      FROM twlad WHERE werks = ls_t001l-werks
                   AND lgort = ls_t001l-lgort.
    IF sy-subrc = 0.
      CASE fu_type.
        WHEN 'BPOM'.
          SELECT SINGLE addrnumber name3
            INTO CORRESPONDING FIELDS OF ls_adrc
            FROM adrc WHERE addrnumber = ls_twlad-adrnr.
          IF sy-subrc = 0.
            CLEAR fc_name1.
            fc_code  = ls_t001l-vstel.
            fc_name1 = ls_adrc-name3.
          ENDIF.

        WHEN 'KEMENKES'.
          SELECT SINGLE addrnumber remark
            INTO CORRESPONDING FIELDS OF ls_adrct
            FROM adrct WHERE addrnumber = ls_twlad-adrnr.
          IF sy-subrc = 0.
            CLEAR fc_ket.
            fc_code = ls_t001l-vstel.
            fc_name1  = ls_adrct-remark.
          ELSE.
            SELECT SINGLE addrnumber name3
              INTO CORRESPONDING FIELDS OF ls_adrc
              FROM adrc WHERE addrnumber = ls_twlad-adrnr.
            IF sy-subrc = 0.
              CLEAR fc_name1.
              fc_code = ls_t001l-vstel.
              fc_ket  = ls_adrc-name3.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_TUJUAN_FOR_641
