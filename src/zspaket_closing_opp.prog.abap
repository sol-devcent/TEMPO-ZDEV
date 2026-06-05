REPORT zspaket_closing_opp MESSAGE-ID zs
                           LINE-SIZE 255
                           NO STANDARD PAGE HEADING.

INCLUDE <%_list>.

TYPE-POOLS: p99sg.

TABLES: tvkol,makt,s700,zsclassopp, zscust_opp, konp, a510, kna1,
        a603 , zstarget.

************************************************************************
* STRUCTURES & INTERNAL TABLES                                         *
************************************************************************
TYPES:   BEGIN OF t_bdc.
           INCLUDE STRUCTURE bdcdata.
         TYPES:   END OF t_bdc.

TYPES:   BEGIN OF t_messtab.
           INCLUDE STRUCTURE bdcmsgcoll.
         TYPES:   END OF t_messtab.

TYPES: BEGIN OF t_s700.
         INCLUDE STRUCTURE s700.
       TYPES: END OF t_s700.
TYPES: BEGIN OF t_zscust_opp.
         INCLUDE STRUCTURE zscust_opp.
       TYPES: END OF t_zscust_opp.
TYPES: BEGIN OF t_zstarget.
         INCLUDE STRUCTURE zstarget.
       TYPES: END OF t_zstarget.
TYPES: BEGIN OF t_vk11,
         pkunwe LIKE s700-pkunwe,
         opnbal LIKE s700-opnbal,
       END OF t_vk11.
TYPES: BEGIN OF t_mvke.
         INCLUDE STRUCTURE mvke.
         TYPES: konda TYPE a603-konda.
TYPES: END OF t_mvke.

TYPES : BEGIN OF ty_kna1,
          kunnr  TYPE kna1-kunnr,
          name1  TYPE kna1-name1,
          katr2  TYPE kna1-katr1,
          katr3  TYPE kna1-katr2,
          katr4  TYPE kna1-katr3,
          katr5  TYPE kna1-katr4,
          katr6  TYPE kna1-katr6,
          katr10 TYPE kna1-katr10,
          ktokd  TYPE kna1-ktokd,
          kdgrp  TYPE knvv-kdgrp,
          konda  TYPE knvv-konda,
          vkbur  TYPE knvv-vkbur,
          kvgr3  TYPE knvv-kvgr3,
        END OF ty_kna1.

DATA: i_vk11  TYPE t_vk11 OCCURS 0 WITH HEADER LINE,
      i_vk113 TYPE t_vk11 OCCURS 0 WITH HEADER LINE,
      wa_vk11 TYPE t_vk11.

DATA: i_s700        TYPE t_s700 OCCURS 0,
      i_s700key     TYPE t_s700 OCCURS 0 WITH HEADER LINE,
      wa_s700       TYPE t_s700,
      i_mvke        TYPE t_mvke OCCURS 0 WITH HEADER LINE,
      wa_mvke       TYPE t_mvke,
      i_zscust_opp  TYPE t_zscust_opp OCCURS 0,
      wa_zscust_opp TYPE t_zscust_opp,
      i_zstarget    TYPE t_zstarget OCCURS 0,
      wa_zstarget   TYPE t_zstarget,
      i_zstargetsum TYPE t_zstarget OCCURS 0 WITH HEADER LINE,
      i_s7001       TYPE t_s700 OCCURS 0,
      i_s7002       TYPE t_s700 OCCURS 0,
      i_s7002_sum   TYPE t_s700 OCCURS 0,
      wa_s700_sum   TYPE t_s700,
      pkunwe        LIKE wa_s700-pkunwe,
      opnbal        LIKE wa_s700-opnbal.

DATA: va_mark(1), va_mode(1), va_live(1),
      sw(1).

DATA: va_msg(100),
      i_bdc       TYPE t_bdc OCCURS 0,
      wa_bdc      TYPE t_bdc,
      i_messtab   TYPE t_messtab OCCURS 0,
      wa_messtab  TYPE t_messtab.

RANGES : r_matnr FOR mvke-matnr.
DATA: p_date   LIKE sy-datum,
      v_spmon  LIKE s700-spmon,
      v_spmon1 LIKE s700-spmon,
      v_date1  LIKE sy-datum,
      v_date2  LIKE sy-datum,
      v_date22 LIKE sy-datum,
      p_mm(2),
      p_yy(4).
CONSTANTS : c_limit TYPE i VALUE 5.

DATA: va_datab LIKE zproject-datab,
      va_flag  LIKE zproject-flag,
      va_datum TYPE sy-datum.

DATA : ld_month TYPE fcmnr,
       ld_year  TYPE gjahr,
       ld_date1 LIKE sy-datum,
       ld_date2 LIKE sy-datum.

DATA : gv_flag  TYPE flag,
       gv_vstel TYPE tvkol-vstel.

DATA : gt_kna1          TYPE STANDARD TABLE OF ty_kna1.

INCLUDE zspaket_closing_opptop.

****************************************************
*        Parameters                                *
****************************************************
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
*     Select-options s_spmon for s700-spmon. "
PARAMETERS: p_paket LIKE zsparameter-paket DEFAULT 'OPP' MODIF ID pe0.
PARAMETERS: p_spmon LIKE s700-spmon DEFAULT sy-datum(6) OBLIGATORY.
PARAMETERS: p_vkorg LIKE tvko-vkorg DEFAULT '8020' OBLIGATORY,
            p_vtweg LIKE zscust_opp-vtweg DEFAULT '10' OBLIGATORY,
            p_vstel LIKE tvkol-vstel OBLIGATORY DEFAULT '0290'.
SELECT-OPTIONS: s_kunnr FOR s700-pkunwe.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_vstel1  LIKE tvkol-vstel.
PARAMETERS: p_vst700  LIKE tvkol-vstel.

*SELECTION-SCREEN SKIP 1.
PARAMETERS: persen  LIKE zsclassopp-zpersenwb MODIF ID pe0 NO-DISPLAY,
            persen1 LIKE zsclassopp-zpersenwb MODIF ID pe0 NO-DISPLAY,
            persen2 LIKE zsclassopp-zpersenwb MODIF ID pe0 NO-DISPLAY,
            persen3 LIKE zsclassopp-zpersenwb MODIF ID pe0 NO-DISPLAY,
            persen4 LIKE zsclassopp-zpersenwb MODIF ID pe0 NO-DISPLAY,
            persen5 LIKE zsclassopp-zpersenwb MODIF ID pe0 NO-DISPLAY.
SELECTION-SCREEN SKIP 1.
PARAMETERS p_updvk AS CHECKBOX DEFAULT 'X' MODIF ID pe3.
PARAMETERS p_pexwb AS CHECKBOX MODIF ID pe4.
PARAMETERS p_wbmat AS CHECKBOX.
*PARAMETERS: p_strike AS CHECKBOX DEFAULT 'X'.
*PARAMETERS: p_backg AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN SKIP 1.

************************************************************************
* PROGRAM                                                              *
************************************************************************
* AT SELECTION-SCREEN
************************************************************************

AT SELECTION-SCREEN ON p_spmon.
  p_date = sy-datum.
  IF p_spmon > p_date(6). " sy-datum(6).
    MESSAGE e000(zs)
    WITH 'Periode tidak boleh lebih besar dari tgl system'.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen USING : 'PE3' '0' ''.

AT SELECTION-SCREEN.

************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.
  va_mode = 'N'.
  PERFORM f_init_vkorg.


************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.

  DATA : p_konda  TYPE knvv-konda,
         p_all(1),
         ls_user  LIKE LINE OF gt_user.

  SELECT *
    FROM usgrp_user
    INTO CORRESPONDING FIELDS OF TABLE gt_user
    WHERE bname = sy-uname.

  READ TABLE gt_user INTO ls_user WITH KEY usergroup(3) = 'TDS'.
  IF sy-subrc <> 0.
    PERFORM f_check_auth.
  ENDIF.

  PERFORM f_init_percen CHANGING va_datum.
  PERFORM f_get_mvgr2.
  PERFORM f_get_paket_type.

* Get lve & non live SAP
  SELECT SINGLE b~live
    INTO va_live
    FROM tvkol AS a JOIN zplbc AS b ON a~werks = b~werks AND
                                       a~lgort = b~lgort
    WHERE a~vstel = p_vstel.

  IF s_kunnr IS INITIAL.
    p_all = 'X'.
  ENDIF.

***  validasi hanya untuk customer OPP saja yang diproses
*    data target diambil yang status = A : approve

  IF p_vst700 IS NOT INITIAL.
    gv_vstel = p_vst700.
  ELSE.
    gv_vstel = p_vstel.
  ENDIF.

  SELECT * INTO TABLE i_zstarget
        FROM zstarget
        WHERE vkorg EQ p_vkorg AND
              vtweg EQ '10'    AND
              spmon EQ p_spmon AND
              vkbur EQ p_vstel AND
              kunnr IN s_kunnr AND
              mvgr2 IN r_mvgr2 AND
              zsts  IN ('A', 'N').

* Jika tidak ada data, keluar
  IF sy-subrc <> 0.
    MESSAGE s000(zab) WITH 'Data Target tidak ada'.
    WRITE :/ 'Data Target tidak ada'.
    LEAVE LIST-PROCESSING.
  ELSE.
    IF s_kunnr IS NOT INITIAL.
      CLEAR : s_kunnr.
      REFRESH : s_kunnr.
    ENDIF.

    s_kunnr-sign = 'I'.
    s_kunnr-option = 'EQ'.
    LOOP AT i_zstarget INTO wa_zstarget.
      s_kunnr-low = wa_zstarget-kunnr.
      APPEND s_kunnr.

** Summary by kunnr mvgr2
      i_zstargetsum-vkorg = wa_zstarget-vkorg.
      i_zstargetsum-vtweg = wa_zstarget-vtweg.
      i_zstargetsum-gjahr = wa_zstarget-gjahr.
      i_zstargetsum-spmon = wa_zstarget-spmon.
      i_zstargetsum-vkbur = wa_zstarget-vkbur.
      i_zstargetsum-kunnr = wa_zstarget-kunnr.
      i_zstargetsum-mvgr2 = wa_zstarget-mvgr2.
      i_zstargetsum-zvaltgt = wa_zstarget-zvaltgt.
      i_zstargetsum-zvaltgt_x = wa_zstarget-zvaltgt_x.
      COLLECT i_zstargetsum. CLEAR i_zstargetsum.
    ENDLOOP.

    SORT s_kunnr BY low.
    DELETE ADJACENT DUPLICATES FROM s_kunnr COMPARING low.
  ENDIF.

  SELECT SINGLE flag
    FROM zproject
    INTO gv_flag
    WHERE name EQ 'NEW_OPP'.

*-------------------------------------------*
* Proses untuk menghitung pembebanan WB
*-------------------------------------------*
  IF p_pexwb IS INITIAL.
    PERFORM f_get_data.
    PERFORM f_process_data.
    PERFORM f_sort_data.
    PERFORM f_modify.
  ENDIF.

  v_spmon = p_spmon.
  CONCATENATE v_spmon '01' INTO v_date1.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = v_date1
    IMPORTING
      last_day_of_month = v_date1
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  v_date1 = v_date1 + 1.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = v_date1
    IMPORTING
      last_day_of_month = v_date2
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  v_spmon = v_date1(6).

*--------------------------------------------------*
* Proses untuk menghitung WB in, WB out, Ending WB
*--------------------------------------------------*
  PERFORM get_data USING va_datum.
  PERFORM f_key_itab_s700.
*  IF sy-subrc NE 0.
  IF lt_parameter[] IS INITIAL OR
     i_mvke[] IS INITIAL OR
     i_s700[] IS INITIAL OR
     i_zstarget[] IS INITIAL.
    WRITE: / 'No Data'.
    EXIT.
  ELSE.
    IF p_pexwb IS INITIAL.
      IF va_live = 'X'.
        PERFORM f_summary_s626.

        CASE gv_strikewb1.
          WHEN '0'.
            PERFORM proses_data.      "PTT
          WHEN '1'.
            IF gv_flag IS INITIAL.
              PERFORM proses_data_sut.  "SUT
            ELSE.
* OPP 2018
*              PERFORM proses_data_sut1.  "SUT
*              PERFORM proses_data_sut2.  "SUT

* untuk OPP 2 periode, periode 1 dan periode 2 (< 04.2020)
*              PERFORM proses_data_sut3.                     "SUT 2019

* untuk OPP baru per >=04.2020, per class dan tidak ada 2 periode
              PERFORM f_get_paket_control TABLES gt_gtcp
                            USING 'KDGRP' '' ''.
              PERFORM f_get_paket_control TABLES gt_mintgt
                            USING 'MINTGT' '' ''.
              PERFORM f_get_paket_control TABLES gt_param
                            USING 'PARAM' '' ''.
              PERFORM f_get_paket_control TABLES gt_mvgr2slvr
                            USING 'MVGR2SLVR' '' ''.
              PERFORM f_get_paket_control TABLES gt_clspkt
                            USING 'CLSPKT' '' ''.

              PERFORM proses_data_sut4.   " OPP 042020
            ENDIF.
          WHEN OTHERS.
        ENDCASE.
      ELSE.
        i_s7002[] = i_s700.
      ENDIF.

* penambahan validasi untuk konda 05
*                           mvgr2 01 02 03 04
*                           mvgr3 09 10 11 harus ada untuk
* modify itab gt_sum_3
      PERFORM f_modify_strike.

      PERFORM f_summary_target.

      PERFORM update_s700.
    ELSE.

* untuk OPP 2 periode, periode 1 dan periode 2 (< 04.2020)
****      PERFORM update_s700_quarter.

* untuk OPP EWB baru per Q2.2020, untuk class G, P, Q, B
      PERFORM f_get_paket_control TABLES gt_gtcp
                                  USING 'KDGRP' '' ''.

      PERFORM f_get_paket_control TABLES gt_clsewb
                                  USING 'CLASSEWB' '' ''.
      PERFORM f_get_paket_control TABLES gt_scaleewb
                                  USING 'SCALEEWB' '' ''.

      CLEAR : gt_kna1[].
      PERFORM f_get_customer TABLES gt_gtcp gt_clsewb
                             USING  '4'.

      PERFORM update_s700_quarter1.
    ENDIF.
  ENDIF.

*  PERFORM f_update_target.

  INCLUDE zspaket_closing_oppf01.

TOP-OF-PAGE.
*  Perform Cetak_judul.
*  set left scroll-boundary column  93.

*&---------------------------------------------------------------------*
*&      Form  Get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data USING fu_datum.

  DATA: ld_date3 LIKE sy-datum,
        ld_date4 LIKE sy-datum.

* Req. by FJR 02/08/2012
  DATA : ld_sptag1 LIKE s626-sptag,
         ld_sptag2 LIKE s626-sptag.

  DATA : ld_sptag3 LIKE s626-sptag,
         ld_sptag4 LIKE s626-sptag.

  CLEAR : ld_month, ld_year.

* Get tanggal awal dan akhir bulan next month
  ld_date3 = fu_datum + 1.
  ld_month = ld_date3+4(2).
  ld_year = ld_date3(4).
  CALL FUNCTION 'OIL_MONTH_GET_FIRST_LAST'
    EXPORTING
      i_month     = ld_month
      i_year      = ld_year
    IMPORTING
      e_first_day = ld_date3
      e_last_day  = ld_date4
    EXCEPTIONS
      wrong_date  = 1
      OTHERS      = 2.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE i_mvke
  FROM a603
  WHERE kappl = 'V'       AND
        kschl = 'ZPKT'    AND
        vkorg = p_vkorg   AND
*        konda = p_konda   AND
        konda IN r_konda   AND
        auart_sd = space  AND
        matnr NE space    AND
      ( datab LE ld_date1 OR datab LE ld_date2 ) AND
        datbi GE ld_date2 AND
        mvgr2 IN r_mvgr2.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE i_s700
    FROM s700 AS a "left join zsclassopp as c on c~mvgr3 eq a~mvgr3 and
                   "                        c~mvgr2 eq a~mvgr2
    WHERE ssour  EQ space
      AND vrsio  EQ '000'
      AND spmon  EQ p_spmon
      AND sptag  EQ '00000000'
      AND spwoc  EQ '000000'
      AND spbup  EQ '000000'
      AND pkunwe IN s_kunnr
      AND vkbur  EQ gv_vstel
      AND mvgr2  IN r_rptmvgr2.

  IF i_zstarget[] IS NOT INITIAL.
    SELECT kunnr vkorg vtweg kdgrp vkbur kvgr3
      FROM knvv
      INTO TABLE gt_knvv
      FOR ALL ENTRIES IN i_zstarget
            WHERE kunnr EQ i_zstarget-kunnr AND
                  vkorg EQ i_zstarget-vkorg AND
                  vtweg EQ i_zstarget-vtweg AND
                  spart EQ '00'.
  ENDIF.

  SORT i_s700 BY vrsio spmon vkbur matnr pkunwe.
* Untuk update data dari tabel dengan target dari tabel ZSTARGET
  PERFORM f_insert_s700.

*--------------------------------------------------------------------*
* Req. by FJR 02/08/2012
* Get data S626
*--------------------------------------------------------------------*

  READ TABLE gt_cntrl WITH KEY vkorg = p_vkorg
                               paket = p_paket
                               field_name = 'TW1'.

  CONCATENATE p_spmon gt_cntrl-field_value INTO ld_sptag1.
  CONCATENATE p_spmon gt_cntrl-field_value2 INTO ld_sptag2.

*  SELECT sptag vkbur fkart vbeln pkunwe kdgrp kvgr3
*         prodh1 matkl matnr umkzwi1 gukzwi1 ummenge gumenge
*    INTO CORRESPONDING FIELDS OF TABLE i_s626
*    FROM s626
*    WHERE ssour EQ space
*      AND vrsio EQ '000'
*      AND spmon EQ '000000'
*      AND sptag BETWEEN ld_sptag1 AND ld_sptag2
*      AND spwoc EQ '000000'
*      AND spbup EQ '000000'
*      AND vkbur = p_vstel
*      AND pkunwe IN s_kunnr.

* i_mvke = a603
  IF gv_strikewb1 EQ '1'.
    ld_sptag3 = ld_sptag2 + 1.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = ld_sptag1
      IMPORTING
        last_day_of_month = ld_sptag4
      EXCEPTIONS
        day_in_no_date    = 1
        OTHERS            = 2.

*    SELECT sptag vkbur fkart vbeln pkunwe kdgrp kvgr3
*           prodh1 matkl matnr umkzwi1 gukzwi1 ummenge gumenge
*      INTO CORRESPONDING FIELDS OF TABLE i_s626_2
*      FROM s626
*      WHERE ssour EQ space
*        AND vrsio EQ '000'
*        AND spmon EQ '000000'
*        AND sptag BETWEEN ld_sptag3 AND ld_sptag4
*        AND spwoc EQ '000000'
*        AND spbup EQ '000000'
*        AND vkbur = p_vstel
*        AND pkunwe IN s_kunnr.
  ENDIF.

  PERFORM f_get_s626 USING ld_sptag1 ld_sptag2 ld_sptag3 ld_sptag4.

ENDFORM.                    " Get_data

*&---------------------------------------------------------------------*
*&      Form  Proses_data_sut
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proses_data_sut.
  DATA: li_s700       TYPE t_s700 OCCURS 0,
        lwa_s700      TYPE t_s700,
        l_pkunwe      LIKE wa_s700-pkunwe,
        l_mvgr2       LIKE wa_s700-mvgr2,
        l_mvgr3       LIKE wa_s700-mvgr3,
        l_ctr         TYPE i,
        l_ctr2        TYPE i,
        l_toleransi   LIKE wa_s700-opnbal,
*        l_achieve   LIKE wa_s700-opnbal,
        l_achieve(15) TYPE p DECIMALS 5,
        l_zvaltgt     LIKE wa_s700-valtgt,
        l_zxx         LIKE wa_s700-netsales,
        l_zqty        LIKE wa_s700-qty,
        l_sw(1).

  DATA: BEGIN OF lt_zsclassopp OCCURS 0.
          INCLUDE STRUCTURE zsclassopp.
        DATA: END OF lt_zsclassopp.

  DATA: l_zpersenach LIKE zsclassopp-zpersenach.

  DATA : d_datab LIKE zproject-datab.
***      d_flag  LIKE zproject-flag.

  SORT i_s700 BY pkunwe mvgr2 mvgr3 matnr.
  SORT i_zstargetsum BY kunnr mvgr2.
  REFRESH: li_s700.
  CLEAR: l_ctr,l_ctr2, li_s700, lwa_s700, l_mvgr3, wa_s700, l_sw.
  CLEAR: l_zvaltgt, l_zxx, l_zqty.
  l_sw = 0.

  SELECT * FROM zsclassopp
    INTO CORRESPONDING FIELDS OF TABLE lt_zsclassopp
    WHERE mvgr2 IN r_mvgr2
      AND class EQ 'A'
      AND ( datab LE ld_date1 OR datab LE ld_date2 )
      AND datbi GE ld_date2.

*  DELETE lt_zsclassopp WHERE class NE 'A'.

  SORT lt_zsclassopp BY mvgr2 mvgr3 class.
  SORT i_s626_sum BY pkunwe mvgr2.
  SORT i_s626_matnr BY pkunwe mvgr2 matnr.

*-----------------------------------------------------------------*
* Untuk formula strike baru
*-----------------------------------------------------------------*
***  IF p_spmon >= '200804'.
***    d_flag = 'X'.
***  ENDIF.

*========================================================================*
* Proses menghitung WB in
*========================================================================*
* WB in dihitung per customer per paket
* WB in didapat bila nilai sales customer >= target &
*                    nilai sales customer >= target minimum di zsclassopp &
*                    mencapai strike per paket
* Strike dihitung untuk yang total transaksi nya (+) atau DO
* Bila (-) atau CN tidak dihitung sebagai strike
*------------------------------------------------------------------------*
* i_s700  : itab hasil select dari tabel S700
* i_s7001 : itab untuk menampung hasil perhitungan WB in per customer
* i_s7002 : itab untuk menampung hasil akhir untuk update tabel ke S700
* pkunwe  : customer
* mvgr2   : paket
* l_ctr   : data strike per paket per customer
* lt_zsclassopp-zitem : data minimum strike berdasarkan tabel
*------------------------------------------------------------------------*
  LOOP AT i_s700 INTO wa_s700.

    ON CHANGE OF wa_s700-pkunwe OR
                 wa_s700-mvgr2.
      IF l_sw <> 0.
***    IF d_flag = 'X'.
*---------------------------------------------------------------------------*
* NEW Strike formula
*---------------------------------------------------------------------------*
* mirip formula lama, tapi ditambah cek qty harus > dari min qty class A
*---------------------------------------------------------------------------*
*        CLEAR : lt_zsclassopp.
*        READ TABLE lt_zsclassopp WITH KEY mvgr2 = l_mvgr2
*                                          mvgr3 = l_mvgr3
*                                          class = 'A'
*        BINARY SEARCH.
*        IF sy-subrc EQ 0.
        CLEAR l_zqty.
        LOOP AT gt_sum WHERE pkunwe = l_pkunwe AND
                             mvgr2 = l_mvgr2."   AND
*                               mvgr3 = l_mvgr3.
*            ADD gt_sum-qty TO l_zqty.
          READ TABLE lt_zsclassopp WITH KEY mvgr2 = gt_sum-mvgr2
                                            mvgr3 = gt_sum-mvgr3
                                            class = 'A'
                                            BINARY SEARCH.
          IF sy-subrc EQ 0.
            IF gt_sum-qty >= lt_zsclassopp-minqty.
              ADD 1 TO l_ctr.
            ENDIF.
          ENDIF.
        ENDLOOP.
*          IF l_zqty >= lt_zsclassopp-minqty.
*            ADD 1 TO l_ctr.
*          ENDIF.

        CLEAR l_zqty.
        LOOP AT gt_sum_2 WHERE pkunwe = l_pkunwe AND
                               mvgr2 = l_mvgr2."   AND
*                                 mvgr3 = l_mvgr3.
*            ADD gt_sum_2-qty TO l_zqty.
          READ TABLE lt_zsclassopp WITH KEY mvgr2 = gt_sum_2-mvgr2
                                            mvgr3 = gt_sum_2-mvgr3
                                            class = 'A'
                                            BINARY SEARCH.
          IF sy-subrc EQ 0.
            IF gt_sum_2-qty >= lt_zsclassopp-minqty.
              ADD 1 TO l_ctr2.
            ENDIF.
          ENDIF.
        ENDLOOP.
*          IF l_zqty >= lt_zsclassopp-minqty.
*            ADD 1 TO l_ctr2.
*          ENDIF.
*        ENDIF.
***     ENDIF.

        IF wa_s700-netsales NE 0.
* proses WB period I
          PERFORM f_hitung_extrawb USING wa_s700-pkunwe
                                         wa_s700-mvgr2
                                         wa_s700-matnr
                                         wa_s700-netsales
                                         wa_s700-valtgt
                                   CHANGING wa_s700-oppext
                                            wa_s700-netsales.
        ENDIF.

*------------------------------------------------------------------------*
* Data minimum strike item diletakkan di tabel zsclassopp
* untuk tiap paket di item 1 (mvgr3 = 01) class A
*------------------------------------------------------------------------*
        CLEAR : lt_parameter.
        READ TABLE lt_parameter WITH KEY type = l_mvgr2+1(1).
        IF sy-subrc EQ 0.
          l_zpersenach = lt_parameter-achive.
        ENDIF.
* Jika strike-1 >= strike minimum per paket
        IF l_ctr >= lt_parameter-strike.

          l_toleransi =  l_zpersenach / 100.
          IF l_zvaltgt NE 0.
            l_achieve =  l_zxx / l_zvaltgt.
          ELSE.
            l_achieve =  0.
          ENDIF.
          IF l_achieve  < l_toleransi.
            LOOP AT i_s7001 INTO lwa_s700.
              lwa_s700-oppin = 0.
              MODIFY i_s7001 FROM lwa_s700.
            ENDLOOP.
          ENDIF.
*          APPEND LINES OF i_s7001 TO i_s7002.
        ELSE.
          LOOP AT i_s7001 INTO lwa_s700.
*            lwa_s700-oppin = 0.
            lwa_s700-oppext = 0.
            MODIFY i_s7001 FROM lwa_s700.
          ENDLOOP.
*          APPEND LINES OF i_s7001 TO i_s7002.
        ENDIF.
* Jika strike-2 >= strike minimum per paket
        IF l_ctr2 >= lt_parameter-strike.

          l_toleransi =  l_zpersenach / 100.
          IF l_zvaltgt NE 0.
            l_achieve =  l_zxx / l_zvaltgt.
          ELSE.
            l_achieve =  0.
          ENDIF.
          IF l_achieve  < l_toleransi.
            LOOP AT i_s7001 INTO lwa_s700.
              lwa_s700-oppin = 0.
              MODIFY i_s7001 FROM lwa_s700.
            ENDLOOP.
          ENDIF.
*          APPEND LINES OF i_s7001 TO i_s7002.

*proses WB period II
          IF wa_s700-netsales NE 0.
            DATA: lv_sales LIKE wa_s700-valper2.

            IF wa_s700-oppext > 0.
              lv_sales = wa_s700-valper2.
            ELSE.
              lv_sales = wa_s700-netsales.
            ENDIF.

            IF wa_s700-mvgr2 EQ '01'.
              wa_s700-oppin =  persen / 100 * lv_sales.
            ELSEIF wa_s700-mvgr2 EQ '02'.
              wa_s700-oppin =  persen1 / 100 * lv_sales.
            ELSEIF wa_s700-mvgr2 EQ '03'.
              wa_s700-oppin =  persen2 / 100 * lv_sales.
            ELSEIF wa_s700-mvgr2 EQ '04'.
              wa_s700-oppin =  persen3 / 100 * lv_sales.
            ENDIF.
          ENDIF.


        ELSE.
          LOOP AT i_s7001 INTO lwa_s700.
            lwa_s700-oppin = 0.
*            lwa_s700-oppext = 0.
            MODIFY i_s7001 FROM lwa_s700.
          ENDLOOP.
*          APPEND LINES OF i_s7001 TO i_s7002.
        ENDIF.
        APPEND LINES OF i_s7001 TO i_s7002.
      ENDIF.
      REFRESH: i_s7001.
      CLEAR: l_ctr,l_ctr2, lwa_s700, i_s7001, l_achieve, l_toleransi.
      CLEAR: l_zvaltgt, l_zxx, l_mvgr2, l_mvgr3, l_pkunwe.
    ENDON.
*     move-corresponding wa_s700 to lwa_s700.
    CLEAR: wa_s700-oppin.
    l_zvaltgt = l_zvaltgt + wa_s700-valtgt.

    l_zxx = l_zxx + wa_s700-netsales.

*    IF wa_s700-netsales NE 0.
*
** proses WB period I
*      PERFORM f_hitung_extrawb USING wa_s700-pkunwe
*                                     wa_s700-mvgr2
*                                     wa_s700-matnr
*                                     wa_s700-netsales
*                                     wa_s700-valtgt
*                               CHANGING wa_s700-oppext
*                                        wa_s700-netsales.
*
*
**proses WB period II
*      DATA: lv_sales LIKE wa_s700-valper2.
*
*      IF wa_s700-oppext > 0.
*        lv_sales = wa_s700-valper2.
*      ELSE.
*        lv_sales = wa_s700-netsales.
*      ENDIF.
*
*      IF wa_s700-mvgr2 EQ '01'.
*        wa_s700-oppin =  persen / 100 * lv_sales.
*      ELSEIF wa_s700-mvgr2 EQ '02'.
*        wa_s700-oppin =  persen1 / 100 * lv_sales.
*      ELSEIF wa_s700-mvgr2 EQ '03'.
*        wa_s700-oppin =  persen2 / 100 * lv_sales.
*      ELSEIF wa_s700-mvgr2 EQ '04'.
*        wa_s700-oppin =  persen3 / 100 * lv_sales.
*      ENDIF.
*
**      IF wa_s700-mvgr2 EQ '01'.
**        wa_s700-oppin =  persen / 100 * wa_s700-valper2.
**      ELSEIF wa_s700-mvgr2 EQ '02'.
**        wa_s700-oppin =  persen1 / 100 * wa_s700-valper2.
**      ELSEIF wa_s700-mvgr2 EQ '03'.
**        wa_s700-oppin =  persen2 / 100 * wa_s700-valper2.
**      ELSEIF wa_s700-mvgr2 EQ '04'.
**        wa_s700-oppin =  persen3 / 100 * wa_s700-valper2.
**      ENDIF.
*    ENDIF.

***    IF d_flag = ' '.
*---------------------------------------------------------------------------*
* OLD Strike formula
*---------------------------------------------------------------------------*
* Calculate strike dalam 1 paket, beda MVGR3 & DO value (+) dapat 1 strike
*---------------------------------------------------------------------------*
***   IF wa_s700-mvgr3 <> l_mvgr3 AND wa_s700-netsales GT 0.
***        ADD 1 TO l_ctr.
***        MOVE wa_s700-mvgr2 TO l_mvgr2.
***        MOVE wa_s700-mvgr3 TO l_mvgr3.
***   ENDIF.

*** ELSEIF d_flag = 'X'.
*---------------------------------------------------------------------------*
* NEW Strike formula
*---------------------------------------------------------------------------*
* mirip formula lama, tapi ditambah cek qty harus > dari min qty class A
*---------------------------------------------------------------------------*
**    IF wa_s700-mvgr3 = l_mvgr3 AND wa_s700-qty GT 0.
**      l_zqty = l_zqty + wa_s700-qty.
**    ELSEIF wa_s700-mvgr3 <> l_mvgr3.
**      CLEAR : lt_zsclassopp.
**      READ TABLE lt_zsclassopp WITH KEY mvgr2 = wa_s700-mvgr2
**                                        mvgr3 = l_mvgr3
**                                        class = 'A'
**      BINARY SEARCH.
**      IF sy-subrc EQ 0.
**********        CLEAR l_zqty.
**********        LOOP AT gt_sum WHERE pkunwe = l_pkunwe AND
**********                             mvgr2 = l_mvgr2   AND
**********                             mvgr3 = l_mvgr3.
**********          ADD gt_sum-qty TO l_zqty.
**********        ENDLOOP.
**        IF l_zqty >= lt_zsclassopp-minqty.
**          ADD 1 TO l_ctr.
**        ENDIF.
**      ENDIF.
**      l_zqty = wa_s700-qty.
**      MOVE wa_s700-pkunwe TO l_pkunwe.
**      MOVE wa_s700-mvgr2 TO l_mvgr2.
**      MOVE wa_s700-mvgr3 TO l_mvgr3.
**    ENDIF.
***    ENDIF.

    IF wa_s700-mvgr3 <> l_mvgr3.
      MOVE wa_s700-pkunwe TO l_pkunwe.
      MOVE wa_s700-mvgr2 TO l_mvgr2.
      MOVE wa_s700-mvgr3 TO l_mvgr3.
    ENDIF.

    l_sw = 1.
    APPEND wa_s700 TO i_s7001.
    CLEAR: wa_s700.
  ENDLOOP.

  IF l_sw <> 0.
*** IF d_flag = 'X'.
*  ---------------------------------------------------------------------------*
*  NEW Strike formula
*  ---------------------------------------------------------------------------*
*  mirip formula lama, tapi ditambah cek qty harus > dari min qty class A
*  ---------------------------------------------------------------------------*
    CLEAR : lt_zsclassopp.
    READ TABLE lt_zsclassopp WITH KEY mvgr2 = l_mvgr2 "waktu keluar loop wa_s700 sudah clear
                                      mvgr3 = l_mvgr3
                                      class = 'A'
    BINARY SEARCH.
    IF sy-subrc EQ 0.
********      CLEAR l_zqty.
********      LOOP AT gt_sum WHERE pkunwe = l_pkunwe AND
********                           mvgr2 = l_mvgr2   AND
********                           mvgr3 = l_mvgr3.
********        ADD gt_sum-qty TO l_zqty.
********      ENDLOOP.
      IF l_zqty >= lt_zsclassopp-minqty.
        ADD 1 TO l_ctr.
      ENDIF.
    ENDIF.
*** ENDIF.

*------------------------------------------------------------------------*
* Data minimum strike item diletakkan di tabel zsclassopp
* untuk tiap paket di item 1 (mvgr3 = 01) class A
*------------------------------------------------------------------------*
    CLEAR : lt_parameter.
    READ TABLE lt_parameter WITH KEY type = l_mvgr2+1(1).
    IF sy-subrc EQ 0.
      l_zpersenach = lt_zsclassopp-zpersenach.
    ENDIF.

* Jika strike-1 >= strike minimum per paket
    IF l_ctr >= lt_parameter-strike.
      l_toleransi =  l_zpersenach / 100.
      IF l_zvaltgt NE 0.
        l_achieve =  l_zxx / l_zvaltgt.
      ELSE.
        l_achieve =  0.
      ENDIF.
      IF l_achieve  < l_toleransi.
        LOOP AT i_s7001 INTO lwa_s700.
          lwa_s700-oppin = 0.
          MODIFY i_s7001 FROM lwa_s700.
        ENDLOOP.
      ENDIF.
*      APPEND LINES OF i_s7001 TO i_s7002.
    ELSE.
      LOOP AT i_s7001 INTO lwa_s700.
*        lwa_s700-oppin = 0.
        lwa_s700-oppext = 0.
        MODIFY i_s7001 FROM lwa_s700.
      ENDLOOP.
*      APPEND LINES OF i_s7001 TO i_s7002.
    ENDIF.
* Jika strike-2 >= strike minimum per paket
    IF l_ctr2 >= lt_parameter-strike.
      l_toleransi =  l_zpersenach / 100.
      IF l_zvaltgt NE 0.
        l_achieve =  l_zxx / l_zvaltgt.
      ELSE.
        l_achieve =  0.
      ENDIF.
      IF l_achieve  < l_toleransi.
        LOOP AT i_s7001 INTO lwa_s700.
          lwa_s700-oppin = 0.
          MODIFY i_s7001 FROM lwa_s700.
        ENDLOOP.
      ENDIF.
*      APPEND LINES OF i_s7001 TO i_s7002.
    ELSE.
      LOOP AT i_s7001 INTO lwa_s700.
        lwa_s700-oppin = 0.
*        lwa_s700-oppext = 0.
        MODIFY i_s7001 FROM lwa_s700.
      ENDLOOP.
*      APPEND LINES OF i_s7001 TO i_s7002.
    ENDIF.
    APPEND LINES OF i_s7001 TO i_s7002.
  ENDIF.

  REFRESH: i_s7001.
  CLEAR: l_ctr,l_ctr2, lwa_s700, i_s7001.
ENDFORM.                    " Proses_data_sut

*&---------------------------------------------------------------------*
*&      Form  Proses_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proses_data.
  DATA: li_s700       TYPE t_s700 OCCURS 0,
        lwa_s700      TYPE t_s700,
        l_pkunwe      LIKE wa_s700-pkunwe,
        l_mvgr2       LIKE wa_s700-mvgr2,
        l_mvgr3       LIKE wa_s700-mvgr3,
        l_ctr         TYPE i,
        l_toleransi   LIKE wa_s700-opnbal,
*        l_achieve   LIKE wa_s700-opnbal,
        l_achieve(15) TYPE p DECIMALS 5,
        l_zvaltgt     LIKE wa_s700-valtgt,
        l_zxx         LIKE wa_s700-netsales,
        l_zqty        LIKE wa_s700-qty,
        l_sw(1).

  DATA: BEGIN OF lt_zsclassopp OCCURS 0.
          INCLUDE STRUCTURE zsclassopp.
        DATA: END OF lt_zsclassopp.

  DATA: l_zpersenach LIKE zsclassopp-zpersenach.

  DATA : d_datab LIKE zproject-datab.
***      d_flag  LIKE zproject-flag.

  SORT i_s700 BY pkunwe mvgr2 mvgr3 matnr.
  SORT i_zstargetsum BY kunnr mvgr2.
  REFRESH: li_s700.
  CLEAR: l_ctr, li_s700, lwa_s700, l_mvgr3, wa_s700, l_sw.
  CLEAR: l_zvaltgt, l_zxx, l_zqty.
  l_sw = 0.

  SELECT * FROM zsclassopp
    INTO CORRESPONDING FIELDS OF TABLE lt_zsclassopp
    WHERE mvgr2 IN r_mvgr2
      AND class EQ 'A'
      AND ( datab LE ld_date1 OR datab LE ld_date2 )
      AND datbi GE ld_date2.

*  DELETE lt_zsclassopp WHERE class NE 'A'.

  SORT lt_zsclassopp BY mvgr2 mvgr3 class.
  SORT i_s626_sum BY pkunwe mvgr2.
  SORT i_s626_matnr BY pkunwe mvgr2 matnr.

*-----------------------------------------------------------------*
* Untuk formula strike baru
*-----------------------------------------------------------------*
***  IF p_spmon >= '200804'.
***    d_flag = 'X'.
***  ENDIF.

*========================================================================*
* Proses menghitung WB in
*========================================================================*
* WB in dihitung per customer per paket
* WB in didapat bila nilai sales customer >= target &
*                    nilai sales customer >= target minimum di zsclassopp &
*                    mencapai strike per paket
* Strike dihitung untuk yang total transaksi nya (+) atau DO
* Bila (-) atau CN tidak dihitung sebagai strike
*------------------------------------------------------------------------*
* i_s700  : itab hasil select dari tabel S700
* i_s7001 : itab untuk menampung hasil perhitungan WB in per customer
* i_s7002 : itab untuk menampung hasil akhir untuk update tabel ke S700
* pkunwe  : customer
* mvgr2   : paket
* l_ctr   : data strike per paket per customer
* lt_zsclassopp-zitem : data minimum strike berdasarkan tabel
*------------------------------------------------------------------------*
  LOOP AT i_s700 INTO wa_s700.

    ON CHANGE OF wa_s700-pkunwe OR
                 wa_s700-mvgr2.
      IF l_sw <> 0.
***    IF d_flag = 'X'.
*---------------------------------------------------------------------------*
* NEW Strike formula
*---------------------------------------------------------------------------*
* mirip formula lama, tapi ditambah cek qty harus > dari min qty class A
*---------------------------------------------------------------------------*
        CLEAR : lt_zsclassopp.
        READ TABLE lt_zsclassopp WITH KEY mvgr2 = l_mvgr2
                                          mvgr3 = l_mvgr3
                                          class = 'A'
        BINARY SEARCH.
        IF sy-subrc EQ 0.
*******          CLEAR l_zqty.
*******          LOOP AT gt_sum WHERE pkunwe = l_pkunwe AND
*******                               mvgr2 = l_mvgr2   AND
*******                               mvgr3 = l_mvgr3.
*******            ADD gt_sum-qty TO l_zqty.
*******          ENDLOOP.
          IF l_zqty >= lt_zsclassopp-minqty.
            ADD 1 TO l_ctr.
          ENDIF.
        ENDIF.
***     ENDIF.

*------------------------------------------------------------------------*
* Data minimum strike item diletakkan di tabel zsclassopp
* untuk tiap paket di item 1 (mvgr3 = 01) class A
*------------------------------------------------------------------------*
        CLEAR : lt_parameter.
        READ TABLE lt_parameter WITH KEY type = l_mvgr2+1(1).
        IF sy-subrc EQ 0.
          l_zpersenach = lt_parameter-achive.
        ENDIF.
* Jika strike >= strike minimum per paket
        IF l_ctr >= lt_parameter-strike.

          l_toleransi =  l_zpersenach / 100.
          IF l_zvaltgt NE 0.
            l_achieve =  l_zxx / l_zvaltgt.
          ELSE.
            l_achieve =  0.
          ENDIF.
          IF l_achieve  < l_toleransi.
            LOOP AT i_s7001 INTO lwa_s700.
              lwa_s700-oppin = 0.
              MODIFY i_s7001 FROM lwa_s700.
            ENDLOOP.
          ENDIF.
          APPEND LINES OF i_s7001 TO i_s7002.
        ELSE.
          LOOP AT i_s7001 INTO lwa_s700.
            lwa_s700-oppin = 0.
            lwa_s700-oppext = 0.
            MODIFY i_s7001 FROM lwa_s700.
          ENDLOOP.
          APPEND LINES OF i_s7001 TO i_s7002.
        ENDIF.
      ENDIF.
      REFRESH: i_s7001.
      CLEAR: l_ctr, lwa_s700, i_s7001, l_achieve, l_toleransi.
      CLEAR: l_zvaltgt, l_zxx, l_mvgr2, l_mvgr3, l_pkunwe.
    ENDON.
*     move-corresponding wa_s700 to lwa_s700.
    CLEAR: wa_s700-oppin.
    l_zvaltgt = l_zvaltgt + wa_s700-valtgt.

    l_zxx = l_zxx + wa_s700-netsales.

    IF wa_s700-netsales NE 0.

* proses WB period I
      PERFORM f_hitung_extrawb USING wa_s700-pkunwe
                                     wa_s700-mvgr2
                                     wa_s700-matnr
                                     wa_s700-netsales
                                     wa_s700-valtgt
                               CHANGING wa_s700-oppext
                                        wa_s700-netsales.

* proses WB period II
      DATA: lv_sales LIKE wa_s700-valper2.

      IF wa_s700-oppext > 0.
        lv_sales = wa_s700-valper2.
      ELSE.
        lv_sales = wa_s700-netsales.
      ENDIF.

      IF wa_s700-mvgr2 EQ '01'.
        wa_s700-oppin =  persen / 100 * lv_sales.
      ELSEIF wa_s700-mvgr2 EQ '02'.
        wa_s700-oppin =  persen1 / 100 * lv_sales.
      ELSEIF wa_s700-mvgr2 EQ '03'.
        wa_s700-oppin =  persen2 / 100 * lv_sales.
      ELSEIF wa_s700-mvgr2 EQ '04'.
        wa_s700-oppin =  persen3 / 100 * lv_sales.
      ENDIF.

*      IF wa_s700-mvgr2 EQ '01'.
*        wa_s700-oppin =  persen / 100 * wa_s700-valper2.
*      ELSEIF wa_s700-mvgr2 EQ '02'.
*        wa_s700-oppin =  persen1 / 100 * wa_s700-valper2.
*      ELSEIF wa_s700-mvgr2 EQ '03'.
*        wa_s700-oppin =  persen2 / 100 * wa_s700-valper2.
*      ELSEIF wa_s700-mvgr2 EQ '04'.
*        wa_s700-oppin =  persen3 / 100 * wa_s700-valper2.
*      ENDIF.
    ENDIF.

***    IF d_flag = ' '.
*---------------------------------------------------------------------------*
* OLD Strike formula
*---------------------------------------------------------------------------*
* Calculate strike dalam 1 paket, beda MVGR3 & DO value (+) dapat 1 strike
*---------------------------------------------------------------------------*
***   IF wa_s700-mvgr3 <> l_mvgr3 AND wa_s700-netsales GT 0.
***        ADD 1 TO l_ctr.
***        MOVE wa_s700-mvgr2 TO l_mvgr2.
***        MOVE wa_s700-mvgr3 TO l_mvgr3.
***   ENDIF.

*** ELSEIF d_flag = 'X'.
*---------------------------------------------------------------------------*
* NEW Strike formula
*---------------------------------------------------------------------------*
* mirip formula lama, tapi ditambah cek qty harus > dari min qty class A
*---------------------------------------------------------------------------*
    IF wa_s700-mvgr3 = l_mvgr3 AND wa_s700-qty GT 0.
      l_zqty = l_zqty + wa_s700-qty.
    ELSEIF wa_s700-mvgr3 <> l_mvgr3.
      CLEAR : lt_zsclassopp.
      READ TABLE lt_zsclassopp WITH KEY mvgr2 = wa_s700-mvgr2
                                        mvgr3 = l_mvgr3
                                        class = 'A'
      BINARY SEARCH.
      IF sy-subrc EQ 0.
********        CLEAR l_zqty.
********        LOOP AT gt_sum WHERE pkunwe = l_pkunwe AND
********                             mvgr2 = l_mvgr2   AND
********                             mvgr3 = l_mvgr3.
********          ADD gt_sum-qty TO l_zqty.
********        ENDLOOP.
        IF l_zqty >= lt_zsclassopp-minqty.
          ADD 1 TO l_ctr.
        ENDIF.
      ENDIF.
      l_zqty = wa_s700-qty.
      MOVE wa_s700-pkunwe TO l_pkunwe.
      MOVE wa_s700-mvgr2 TO l_mvgr2.
      MOVE wa_s700-mvgr3 TO l_mvgr3.
    ENDIF.
***    ENDIF.

    l_sw = 1.
    APPEND wa_s700 TO i_s7001.
    CLEAR: wa_s700.
  ENDLOOP.

  IF l_sw <> 0.
*** IF d_flag = 'X'.
*  ---------------------------------------------------------------------------*
*  NEW Strike formula
*  ---------------------------------------------------------------------------*
*  mirip formula lama, tapi ditambah cek qty harus > dari min qty class A
*  ---------------------------------------------------------------------------*
    CLEAR : lt_zsclassopp.
    READ TABLE lt_zsclassopp WITH KEY mvgr2 = l_mvgr2 "waktu keluar loop wa_s700 sudah clear
                                      mvgr3 = l_mvgr3
                                      class = 'A'
    BINARY SEARCH.
    IF sy-subrc EQ 0.
********      CLEAR l_zqty.
********      LOOP AT gt_sum WHERE pkunwe = l_pkunwe AND
********                           mvgr2 = l_mvgr2   AND
********                           mvgr3 = l_mvgr3.
********        ADD gt_sum-qty TO l_zqty.
********      ENDLOOP.
      IF l_zqty >= lt_zsclassopp-minqty.
        ADD 1 TO l_ctr.
      ENDIF.
    ENDIF.
*** ENDIF.

*------------------------------------------------------------------------*
* Data minimum strike item diletakkan di tabel zsclassopp
* untuk tiap paket di item 1 (mvgr3 = 01) class A
*------------------------------------------------------------------------*
    CLEAR : lt_parameter.
    READ TABLE lt_parameter WITH KEY type = l_mvgr2+1(1).
    IF sy-subrc EQ 0.
      l_zpersenach = lt_zsclassopp-zpersenach.
    ENDIF.

* Jika strike >= strike minimum per paket
    IF l_ctr >= lt_parameter-strike.
      l_toleransi =  l_zpersenach / 100.
      IF l_zvaltgt NE 0.
        l_achieve =  l_zxx / l_zvaltgt.
      ELSE.
        l_achieve =  0.
      ENDIF.
      IF l_achieve  < l_toleransi.
        LOOP AT i_s7001 INTO lwa_s700.
          lwa_s700-oppin = 0.
          MODIFY i_s7001 FROM lwa_s700.
        ENDLOOP.
      ENDIF.
      APPEND LINES OF i_s7001 TO i_s7002.
    ELSE.
      LOOP AT i_s7001 INTO lwa_s700.
        lwa_s700-oppin = 0.
        lwa_s700-oppext = 0.
        MODIFY i_s7001 FROM lwa_s700.
      ENDLOOP.
      APPEND LINES OF i_s7001 TO i_s7002.
    ENDIF.
  ENDIF.

  REFRESH: i_s7001.
  CLEAR: l_ctr, lwa_s700, i_s7001.
ENDFORM.                    " Proses_data

*&---------------------------------------------------------------------*
*&      Form  Update_s700
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_s700.
  DATA : d_datab  LIKE zproject-datab,
***      d_flag  LIKE zproject-flag,
         d_kunwe  LIKE a631-kunwe,
         wa_s7002 LIKE s700,
         lwa_s700 LIKE s700.

*Data:       l_OPNBAL   like wa_s700-OPNBAL.
***** Update WB IN & WB End
  CLEAR: opnbal, pkunwe, i_vk11, wa_vk11.
  REFRESH: i_bdc, i_messtab, i_vk11.
  CLEAR: i_bdc, i_messtab, wa_bdc, wa_messtab.
  SORT i_s7002 BY pkunwe mvgr2 mvgr3 matnr.
  SORT i_s7002_sum BY pkunwe mvgr2.
  SORT i_s626_sum BY pkunwe mvgr2.

  DATA: ld_count  TYPE i,
        ld_pkunwe LIKE s700-pkunwe,
        ld_mvgr2  LIKE s700-mvgr2.

  DATA: BEGIN OF lt_s700 OCCURS 0.
          INCLUDE STRUCTURE s700.
        DATA: END OF lt_s700.

  DATA : lt_s7002 TYPE t_s700 OCCURS 0,
         lt_s7001 TYPE t_s700 OCCURS 0,
         lt_s7003 TYPE t_s700 OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_mara OCCURS 0,
           matnr TYPE matnr,
           meins TYPE meins,
           matkl TYPE matkl,
         END OF lt_mara.

** Baca data bulan depan, bila sudah ada transaksi tidak boleh hilang
*  SELECT * INTO TABLE lt_s700
*    FROM s700
*    FOR ALL ENTRIES IN i_s7002
*    WHERE ssour EQ ''      AND
*          vrsio EQ '000'   AND
*          spmon EQ v_spmon     AND
*          sptag EQ '00000000'  AND
*          spwoc EQ '000000'    AND
*          spbup EQ '000000'    AND
*          vkbur EQ i_s7002-vkbur   AND
*          kdgrp EQ i_s7002-kdgrp   AND
*          pkunwe EQ i_s7002-pkunwe AND
**yang dicek paket OPP saja karena isi paket bulan depan bisa berubah
**          mvgr2 IN r_mvgr2.
*          mvgr2 IN r_rptmvgr2.

  SORT lt_s700 BY pkunwe kdgrp matnr.
* End Revise by budi 13/03/2007

  lt_s7002[] = i_s7002[].
  SORT lt_s7002 BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_s7002 COMPARING matnr.
  IF lt_s7002[] IS NOT INITIAL.
    SELECT matnr meins matkl
      FROM mara
      INTO TABLE lt_mara
      FOR ALL ENTRIES IN lt_s7002
      WHERE matnr EQ lt_s7002-matnr.
  ENDIF.

  lt_s7001[] = i_s7001[].
  SORT lt_s7001 BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_s7001 COMPARING matnr.
  IF lt_s7001[] IS NOT INITIAL.
    SELECT matnr meins matkl
      FROM mara
      APPENDING TABLE lt_mara
      FOR ALL ENTRIES IN lt_s7001
      WHERE matnr EQ lt_s7001-matnr.
  ENDIF.
* Tabel i_s7002 berisi data yang akan diupdate ke S700
  CLEAR: ld_count, ld_pkunwe.
  SORT i_s7002 BY pkunwe mvgr2 mvgr3 matnr.
  LOOP AT i_s7002 INTO wa_s700.
*------------------------------------------------------------------*
* Cek apakah sudah mencapai target minimum,
* jika belum WB in akan dihilangkan
*------------------------------------------------------------------*

    wa_s700-vkorg = p_vkorg.
    wa_s700-waerk = 'IDR'.

    READ TABLE i_s700key WITH KEY matnr = wa_s700-matnr.
    IF sy-subrc = 0.
      wa_s700-vrkme = i_s700key-vrkme.
      wa_s700-prodh1 = i_s700key-prodh1.
      wa_s700-prodh2 = i_s700key-prodh2.
      wa_s700-prodh3 = i_s700key-prodh3.
    ELSE.
      READ TABLE lt_mara WITH KEY matnr = wa_s700-matnr.
      IF sy-subrc EQ 0.
        wa_s700-vrkme = lt_mara-meins.
        wa_s700-prodh1 = lt_mara-matkl(3).
        wa_s700-prodh2 = lt_mara-matkl+3(3).
        wa_s700-prodh3 = lt_mara-matkl+6(3).
      ENDIF.
    ENDIF.

    READ TABLE i_s700key WITH KEY pkunwe = wa_s700-pkunwe.
    IF sy-subrc = 0.
      wa_s700-kvgr3 = i_s700key-kvgr3.
      wa_s700-routel = i_s700key-routel.
    ELSE.
      READ TABLE gt_knvv WITH KEY kunnr = wa_s700-pkunwe.
      IF sy-subrc EQ 0.
        wa_s700-kvgr3 = gt_knvv-kvgr3.
      ENDIF.
    ENDIF.

*    PERFORM f_modify_zoppin USING wa_s700-pkunwe
*                                  wa_s700-mvgr2
*                                  CHANGING wa_s700-oppin
*                                           wa_s700-oppext.

*    IF wa_s700-pkunwe <> ld_pkunwe OR wa_s700-mvgr2 <> ld_mvgr2.
*      ld_pkunwe = wa_s700-pkunwe.
*      ld_mvgr2  = wa_s700-mvgr2.
*      CLEAR: ld_count.
*    ENDIF.
*
*    IF ld_count IS INITIAL.
*      IF wa_s700-oppin IS NOT INITIAL OR wa_s700-oppext IS NOT INITIAL.
*        ld_count = 1.
*      ENDIF.
*      IF wa_s700-oppin IS NOT INITIAL.
*        IF wa_s700-oppext IS NOT INITIAL.
*          wa_s700-point = 2.
*        ELSE.
*          wa_s700-point = 1.
*        ENDIF.
*      ELSE.
*        IF wa_s700-oppext IS NOT INITIAL.
*          wa_s700-point = 1.
*        ENDIF.
*      ENDIF.
*    ENDIF.
    lt_s7003-pkunwe = wa_s700-pkunwe.
    lt_s7003-mvgr2  = wa_s700-mvgr2.
    lt_s7003-oppin  = wa_s700-oppin.
    lt_s7003-oppext = wa_s700-oppext.
    COLLECT lt_s7003. CLEAR lt_s7003.

    IF wa_s700-vrkme IS INITIAL OR wa_s700-prodh1 IS INITIAL OR
       wa_s700-prodh2 IS INITIAL OR wa_s700-prodh3 IS INITIAL.
      READ TABLE lt_mara WITH KEY matnr = wa_s700-matnr.
      IF sy-subrc EQ 0.
        wa_s700-vrkme = lt_mara-meins.
        wa_s700-prodh1 = lt_mara-matkl(3).
        wa_s700-prodh2 = lt_mara-matkl+3(3).
        wa_s700-prodh3 = lt_mara-matkl+6(3).
      ENDIF.
    ENDIF.

*--------------------------------------------------------------------*

*    wa_s700-oppend = wa_s700-oppend + wa_s700-oppin +
*                     wa_s700-oppout + wa_s700-oppadj + wa_s700-oppext.
    wa_s700-oppend = wa_s700-opnbal + wa_s700-oppin +
                     wa_s700-oppout + wa_s700-oppadj + wa_s700-oppext.
*------------------------------------------------------------------*
* Update target, WB in, Ending WB dan Point untuk bulan yang close
*------------------------------------------------------------------*
*    UPDATE s700 SET vkorg  = wa_s700-vkorg
*                    waerk  = wa_s700-waerk
*                    vrkme  = wa_s700-vrkme
*                    prodh1 = wa_s700-prodh1
*                    prodh2 = wa_s700-prodh2
*                    prodh3 = wa_s700-prodh3
*                    kvgr3  = wa_s700-kvgr3
*                    valtgt = wa_s700-valtgt
*                    qtx    = wa_s700-qtx
*                    oppin  = wa_s700-oppin
*                    oppend = wa_s700-oppend
*                    point  = wa_s700-point
*                    totweek = wa_s700-totweek
** Req. by FJR 02/08/2012
*                    oppext = wa_s700-oppext
** End Req. by FJR 02/08/2012
*        WHERE  spmon EQ wa_s700-spmon   AND
*               vkbur EQ wa_s700-vkbur   AND
*               kdgrp EQ wa_s700-kdgrp   AND
*               pkunwe EQ wa_s700-pkunwe AND
*               mvgr2 EQ wa_s700-mvgr2   AND
*               matnr EQ wa_s700-matnr   AND
*               mvgr3 EQ wa_s700-mvgr3   AND
*               vrsio EQ wa_s700-vrsio   AND
*               sptag EQ wa_s700-sptag   AND
*               spwoc EQ wa_s700-spwoc   AND
*               spbup EQ wa_s700-spbup   AND
*               ssour EQ wa_s700-ssour.

    MODIFY i_s7002 FROM wa_s700 TRANSPORTING vkorg waerk vrkme
                                             prodh1 prodh2 prodh3
                                             kvgr3 valtgt qtx
                                             oppin oppend
                                             totweek oppext.

    opnbal = opnbal +  wa_s700-oppend.

    i_vk11-pkunwe = wa_s700-pkunwe.
    i_vk11-opnbal = wa_s700-oppend * -1.
    COLLECT i_vk11. CLEAR i_vk11.

    CLEAR:  wa_s700-qty,  wa_s700-netsales, wa_s700-point,
            wa_s700-opnbal, wa_s700-oppext, wa_s700-totweek,
            wa_s700-oppout, wa_s700-oppin, wa_s700-oppadj,
            wa_s700-qtyw1, wa_s700-qtyw2,
            wa_s700-qtyw3, wa_s700-qtyw4,
            wa_s700-qtyw5, wa_s700-week1,
            wa_s700-week2, wa_s700-week3,
            wa_s700-week4, wa_s700-week5,
            wa_s700-qtx,   wa_s700-valtgt.

*---------------------------------------------------------*
* Start proses untuk append ke bulan depan
*---------------------------------------------------------*
    wa_s700-spmon  = v_spmon.
    wa_s700-opnbal = wa_s700-oppend.

    READ TABLE i_mvke INTO wa_mvke
    WITH KEY vkorg = p_vkorg
             matnr = wa_s700-matnr
    BINARY SEARCH.

* Kalau material sudah tidak jadi peserta paket
    IF sy-subrc NE 0.
* Jika sudah tidak ada ending WB, tidak usah carry over
      IF wa_s700-opnbal = 0 AND lt_s700-oppout = 0 AND
         lt_s700-netsales = 0.
        CONTINUE.
* Jika masih ada sisa WB, transfer WB ke item 1 paket 1
      ELSEIF wa_s700-opnbal <> 0.
        wa_s700-mvgr2 = '01'.
        wa_s700-mvgr3 = '01'.
* Baca data bulan depan yang sudah ada dari itab untuk item 1 paket 1
        CLEAR lt_s700.
        READ TABLE lt_s700 WITH KEY pkunwe = wa_s700-pkunwe
                                    kdgrp  = wa_s700-kdgrp
                                    matnr  = wa_s700-matnr
                          BINARY SEARCH.
        IF sy-subrc = 0.
          wa_s700-kdgrp = lt_s700-kdgrp.
          wa_s700-vrkme = lt_s700-vrkme.
          wa_s700-waerk = lt_s700-waerk.
          wa_s700-freq  = lt_s700-freq.
          wa_s700-class = lt_s700-class.
        ELSE.
          SORT i_s7001 BY pkunwe kdgrp matnr.
          READ TABLE i_s7001 INTO lt_s700
                        WITH KEY pkunwe = wa_s700-pkunwe
                                 kdgrp  = wa_s700-kdgrp
                                 matnr  = wa_s700-matnr
                       BINARY SEARCH.
          IF sy-subrc = 0.
            wa_s700-kdgrp = lt_s700-kdgrp.
            wa_s700-vrkme = lt_s700-vrkme.
            wa_s700-waerk = lt_s700-waerk.
            wa_s700-freq  = lt_s700-freq.
            wa_s700-class = lt_s700-class.
          ENDIF.
        ENDIF.
        COLLECT wa_s700 INTO i_s7001.
        CONTINUE.
      ENDIF.
    ENDIF.

    CLEAR lt_s700.
*Baca data bulan depan yang sudah ada dari itab
*yang dicek material number nya saja karena paket bulan depan bisa berubah
    READ TABLE lt_s700 WITH KEY pkunwe = wa_s700-pkunwe
                                kdgrp = wa_s700-kdgrp
                                matnr = wa_s700-matnr
                       BINARY SEARCH.

* Jika ada data bulan depan, calculate ending WB, jika belum tambahkan record
    IF lt_s700 IS NOT INITIAL AND
       wa_s700-mvgr2 IS NOT INITIAL AND
       wa_s700-mvgr3 IS NOT INITIAL.
      wa_s700-kdgrp = lt_s700-kdgrp.
      wa_s700-vrkme = lt_s700-vrkme.
      wa_s700-waerk = lt_s700-waerk.
      wa_s700-freq  = lt_s700-freq.
      wa_s700-class = lt_s700-class.
      wa_s700-netsales = lt_s700-netsales.
      wa_s700-qty    = lt_s700-qty.
      wa_s700-oppout = wa_s700-totweek = lt_s700-oppout.
      wa_s700-qtyw1  = lt_s700-qtyw1.
      wa_s700-qtyw2  = lt_s700-qtyw2.
      wa_s700-qtyw3  = lt_s700-qtyw3.
      wa_s700-qtyw4  = lt_s700-qtyw4.
      wa_s700-qtyw5  = lt_s700-qtyw5.
      wa_s700-week1  = lt_s700-week1.
      wa_s700-week2  = lt_s700-week2.
      wa_s700-week3  = lt_s700-week3.
      wa_s700-week4  = lt_s700-week4.
      wa_s700-week5  = lt_s700-week5.
* Ending WB = Open WB + WB adj + Extra WB + WB out + WB in
      wa_s700-oppend = wa_s700-oppend + lt_s700-oppadj +
                       lt_s700-oppext + lt_s700-oppout + lt_s700-oppin.
    ENDIF.

    IF wa_s700-vrkme IS INITIAL OR wa_s700-prodh1 IS INITIAL OR
       wa_s700-prodh2 IS INITIAL OR wa_s700-prodh3 IS INITIAL.
      READ TABLE lt_mara WITH KEY matnr = wa_s700-matnr.
      IF sy-subrc EQ 0.
        wa_s700-vrkme = lt_mara-meins.
        wa_s700-prodh1 = lt_mara-matkl(3).
        wa_s700-prodh2 = lt_mara-matkl+3(3).
        wa_s700-prodh3 = lt_mara-matkl+6(3).
      ENDIF.
    ENDIF.

* Tampung data bulan depan di tabel i_s7001
    APPEND wa_s700 TO i_s7001.

    pkunwe = wa_s700-pkunwe.
*    AT END OF pkunwe.
*      IF opnbal GT 0.
*        opnbal = opnbal * -1.
*        wa_vk11-pkunwe = pkunwe.
*        wa_vk11-opnbal = opnbal.
*        APPEND wa_vk11 TO i_vk11.
*      ENDIF.
*      WRITE: / 'Customer Code : ', pkunwe, sy-vline,
*         'WB Opening : ', opnbal.
*      CLEAR: opnbal, pkunwe.
*    ENDAT.

*    i_vk11-pkunwe = wa_s700-pkunwe.
*    i_vk11-opnbal = wa_s700-oppend * -1.
*    COLLECT i_vk11. CLEAR i_vk11.

    CLEAR: wa_s700,i_vk11.
  ENDLOOP.

*  IF i_s7002[] IS NOT INITIAL.
*    IF opnbal GT 0.
*      opnbal = opnbal * -1.
*      wa_vk11-pkunwe = pkunwe.
*      wa_vk11-opnbal = opnbal.
*      APPEND wa_vk11 TO i_vk11.
*    ENDIF.
*    WRITE: / 'Customer Code : ', pkunwe, sy-vline,
*             'WB Opening : ', opnbal.
*    CLEAR: opnbal, pkunwe.
*  ENDIF.

* Update tabel S700 untuk data bulan ini
  SORT i_s7002 BY pkunwe mvgr2 matnr.
  SORT lt_s7003 BY pkunwe mvgr2 matnr.
  SORT i_s700 BY pkunwe mvgr2 matnr.

  LOOP AT i_s7002 INTO wa_s700.
    IF wa_s700-pkunwe <> ld_pkunwe OR wa_s700-mvgr2 <> ld_mvgr2.
      ld_pkunwe = wa_s700-pkunwe.
      ld_mvgr2  = wa_s700-mvgr2.
      CLEAR: ld_count.
    ENDIF.

    READ TABLE i_s700 INTO lwa_s700 WITH KEY pkunwe  = wa_s700-pkunwe
                                             mvgr2   = wa_s700-mvgr2
                                             matnr   = wa_s700-matnr
                                    BINARY SEARCH.
    IF sy-subrc EQ 0.
      wa_s700-netsales  = lwa_s700-netsales.
    ENDIF.

    IF ld_count IS INITIAL.
      ld_count = 1.
      CLEAR lt_s7003.
      READ TABLE lt_s7003 WITH KEY pkunwe = wa_s700-pkunwe
                                   mvgr2  = wa_s700-mvgr2 BINARY SEARCH.
      IF lt_s7003-oppin IS NOT INITIAL.
        IF lt_s7003-oppext IS NOT INITIAL.
          wa_s700-point = 2.
        ELSE.
          wa_s700-point = 1.
        ENDIF.
      ELSE.
        IF lt_s7003-oppext IS NOT INITIAL.
          wa_s700-point = 1.
        ENDIF.
      ENDIF.
      MODIFY i_s7002 FROM wa_s700 TRANSPORTING point.
    ENDIF.
    MODIFY i_s7002 FROM wa_s700 TRANSPORTING netsales.
  ENDLOOP.

  MODIFY s700 FROM TABLE i_s7002.

* Update tabel S700 untuk data bulan depan
*  MODIFY s700 FROM TABLE i_s7001.

*--------------------------*
* Update Condition Master
*--------------------------*
*  CLEAR: opnbal, pkunwe.         "Pindah setelah update target
*  IF p_updvk = 'X'.
*    PERFORM f_bapi_pricing.
*  ENDIF.
ENDFORM.                    " Update_s700

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
*&      Form  f_insert_s700
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_insert_s700.
  DATA : lt_s700 TYPE STANDARD TABLE OF s700,
         ls_s700 LIKE LINE OF lt_s700.

  CLEAR: wa_zstarget.
  SORT i_mvke BY vkorg matnr konda.
* Untuk mengupdate data S700 agar menampilkan customer OPP yang tidak ada transaksinya
  LOOP AT i_zstarget INTO wa_zstarget.
* Cek ke S700, apakah ada transaksi
    READ TABLE i_s700 INTO wa_s700 WITH KEY
           vrsio = '000'
           spmon = p_spmon
           vkbur = gv_vstel
           matnr = wa_zstarget-matnr
           pkunwe = wa_zstarget-kunnr
    BINARY SEARCH.
* Jika tidak ada transaksi, maka tambahkan ke S700
    IF sy-subrc NE 0.
      CLEAR: wa_s700.
*-------------------------------------------------------------------------------------*
* MANDT MUTLAK ditambahkan karena kita mengambil structure yang identik dengan S700
      wa_s700-mandt = sy-mandt.
*-------------------------------------------------------------------------------------*
      wa_s700-vrsio  = '000'.
      wa_s700-spmon  = p_spmon.
      wa_s700-vkbur  = gv_vstel. " wa_ZSTARGET-VKBUR.
      wa_s700-vkorg  = p_vkorg.
      wa_s700-pkunwe = wa_zstarget-kunnr.
      wa_s700-matnr  = wa_zstarget-matnr.
      wa_s700-waerk  = 'IDR'.
      wa_s700-qtx    = wa_zstarget-tgt_qty.
      wa_s700-valtgt = wa_zstarget-zvaltgt.
      wa_s700-freq   = wa_zstarget-freq.

      CLEAR wa_mvke.
      READ TABLE i_mvke INTO wa_mvke
                        WITH KEY vkorg = wa_zstarget-vkorg
                                 matnr = wa_zstarget-matnr
                                 konda = wa_zstarget-konda.
      wa_s700-mvgr2 = wa_mvke-mvgr2.
      wa_s700-mvgr3 = wa_mvke-mvgr3.

      IF sy-subrc NE 0 AND p_vkorg = '8070'.
        wa_s700-mvgr2 = '99'.
        wa_s700-mvgr3 = wa_mvke-mvgr3.
      ENDIF.

      READ TABLE gt_knvv WITH KEY kunnr = wa_zstarget-kunnr
                                  vkorg = wa_zstarget-vkorg
                                  vtweg = wa_zstarget-vtweg.
      IF sy-subrc EQ 0.
        wa_s700-kdgrp = gt_knvv-kdgrp.
        wa_s700-vkbur = gt_knvv-vkbur.
      ENDIF.

      APPEND wa_s700 TO i_s700.
* Harus sort agar read di atas benar
      SORT i_s700 BY vrsio spmon vkbur matnr pkunwe.
    ELSE.
* Jika ada transaksi, maka update target qty dan value
      wa_s700-qtx    = wa_zstarget-tgt_qty.
      wa_s700-valtgt = wa_zstarget-zvaltgt.
      MODIFY i_s700 FROM wa_s700 TRANSPORTING qtx valtgt
          WHERE  spmon EQ wa_s700-spmon   AND
                 vkbur EQ wa_s700-vkbur   AND
                 kdgrp EQ wa_s700-kdgrp   AND
                 pkunwe EQ wa_s700-pkunwe AND
                 mvgr2 EQ wa_s700-mvgr2   AND
                 matnr EQ wa_s700-matnr   AND
                 mvgr3 EQ wa_s700-mvgr3   AND
                 vrsio EQ wa_s700-vrsio   AND
                 sptag EQ wa_s700-sptag   AND
                 spwoc EQ wa_s700-spwoc   AND
                 spbup EQ wa_s700-spbup   AND
                 ssour EQ wa_s700-ssour.

    ENDIF.
    CLEAR: wa_zstarget.
  ENDLOOP.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_s700
    FROM s700
    WHERE ssour  EQ space
      AND vrsio  EQ '000'
      AND spmon  EQ p_spmon
      AND sptag  EQ '00000000'
      AND spwoc  EQ '000000'
      AND spbup  EQ '000000'
      AND pkunwe IN s_kunnr
      AND vkbur  EQ gv_vstel
      AND mvgr2  = space
      AND mvgr3  = space.

  CLEAR ls_s700.
  LOOP AT lt_s700 INTO ls_s700.
    READ TABLE i_mvke INTO wa_mvke
                      WITH KEY vkorg = ls_s700-vkorg
                               matnr = ls_s700-matnr.
    IF sy-subrc = 0.
      ls_s700-mvgr2 = wa_mvke-mvgr2.
      ls_s700-mvgr3 = wa_mvke-mvgr3.
    ELSE.
      ls_s700-mvgr2 = '99'.
      ls_s700-mvgr3 = wa_mvke-mvgr3.
    ENDIF.
    APPEND ls_s700 TO i_s700.
    CLEAR ls_s700.
  ENDLOOP.
ENDFORM.                    " f_insert_s700


*&---------------------------------------------------------------------*
*&      Form  f_bdc_vk12
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_bdc_vk12.
  DATA: l_value(18),
        l_date      LIKE sy-datum,
        l_date1(10),
        l_date2(10).

  WRITE: opnbal TO l_value DECIMALS 0 CURRENCY 'IDR'.
  WRITE: v_date1 TO l_date1.
  IF opnbal = -1.
    WRITE: v_date1 TO l_date2.
  ELSE.
    WRITE: v_date2 TO l_date2.
  ENDIF.

  PERFORM f_dynpro USING:  'X'  'SAPMV13A' '0100',
                           ' '  'BDC_OKCODE' '/00',
                           ' '  'RV13A-KSCHL' 'ZC01',
                           'X'  'SAPLV14A' '0100',
                           ' '  'BDC_OKCODE' '=WEIT',
                           ' '  'BDC_CURSOR' 'RV130-SELKZ(01)',
                           'X'  'RV13A631' '1000',
                           ' '  'BDC_OKCODE' '=ONLI',
*                           ' '  'F001' '8020',
                           ' '  'F001' p_vkorg,
                           ' '  'F002' '02',
                           ' '  'F003' '0',
                           ' '  'F004-LOW' pkunwe,
                           ' '  'SEL_DATE' l_date1,
                           'X'  'SAPMV13A' '1631' ,
                           ' '  'BDC_OKCODE' '=PDZV',
                           ' '  'RV130-SELKZ(01)'  'X',
                           'X'  'SAPMV13A' '0305',
                           ' '  'BDC_OKCODE' '/00',
                           ' '  'RV13A-DATAB' l_date1,
                           ' '  'RV13A-DATBI' l_date2,
                           ' '  'KONP-KOMXWRT' l_value,
                           'X'  'SAPMV13A' '0305',
                           ' '  'BDC_OKCODE'  '=SICH',
                           ' '  'RV13A-DATAB' l_date1,
                           ' '  'RV13A-DATBI' l_date2,
                           ' '  'KONP-KOMXWRT' l_value.

  CALL TRANSACTION 'VK12' USING i_bdc MODE va_mode UPDATE 'S'
            MESSAGES INTO i_messtab.
  IF sy-subrc NE 0.
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
        msg  = va_msg.
    WRITE: / 'Message Error : ', va_msg,
            '( ', pkunwe, ' )'.
  ENDIF.
ENDFORM.                    " f_bdc_vk12
