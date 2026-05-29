************************************************************************
*                                                                      *
*  PROGRAM NAME  :  ZMR_PSIKOTROPIKA ( REPORT )                        *
*  PROGRAM DESC  :  PSIKOTROPIKA REPORT                                *
*  CREATED BY    :  DIDIK IMAWAN                                       *
*  CREATED ON    :  10/07/2002 (DD/MM/YY)                              *
*  VERSION       :  4.6C                                               *
*                                                                      *
************************************************************************
*                                                                      *
*  MODIFICATION LOG :                                                  *
*                                                                      *
*  DATE        PROGRAMMER       CORRECTION  DESCRIPTION                *
*  ----------  ---------------  ----------  -------------------------  *
*  09/10/2003  MAHENDRO K       XXXXXXXXXX  TUNE UP FOR PERFORMANCE    *
*                                                                      *
************************************************************************
REPORT zmr_psikotropika3_v1 MESSAGE-ID zs
                            LINE-COUNT 70
                            LINE-SIZE 204
                            NO STANDARD PAGE HEADING.

TABLES: s031.

TYPES: BEGIN OF ta_total,
         matnr      LIKE mara-matnr,
         totalm     LIKE mseg-menge,
         totalk     LIKE mseg-menge,
       END OF ta_total.

TYPES: BEGIN OF ta_header,
         werks      LIKE t001w-werks,
         addrnumber LIKE adrc-addrnumber,
         name1      LIKE adrc-name1,
         name2      LIKE adrc-name2,
         name3      LIKE adrc-name3,
         name4      LIKE adrc-name4,
         city1      LIKE adrc-city1,
         post_code1 LIKE adrc-post_code1,
         street     LIKE adrc-street,
         house_num1 LIKE adrc-house_num1,
         tel_number LIKE adrc-tel_number,
         fax_number LIKE adrc-fax_number,
         str_suppl3 LIKE adrc-str_suppl3,
         location   LIKE adrc-location,
       END OF ta_header.

TYPES : BEGIN OF ta_itab,
          werks LIKE mseg-werks,
          umwrk LIKE mseg-umwrk,
          mblnr LIKE mseg-mblnr,
          mjahr LIKE mseg-mjahr,
          zeile LIKE mseg-zeile,
          sgtxt LIKE mseg-sgtxt,
          smbln LIKE mseg-smbln,
          sjahr LIKE mseg-sjahr,
          smblp LIKE mseg-smblp,
          bwart LIKE mseg-bwart,
          menge LIKE mseg-menge,
          ebeln LIKE mseg-ebeln,
          lifnr LIKE mseg-lifnr,
          kunnr LIKE mseg-kunnr,
          matnr LIKE mseg-matnr,
          xblnr LIKE mkpf-xblnr,
          budat LIKE mkpf-budat,
          name1(25),
          stras(29),
          lgort LIKE s031-lgort,
          umlgo LIKE mseg-umlgo,
          shkzg LIKE mseg-shkzg,
        END OF ta_itab.

TYPES: BEGIN OF ta_all,
          matnr LIKE mseg-matnr,
          werks LIKE mseg-werks,
          mblnr LIKE mseg-mblnr,
          bwart LIKE mseg-bwart,
          menge LIKE mseg-menge,
          maktx LIKE makt-maktx,
          meins LIKE mara-meins,
          namem(35),
          alamatm(49),
          namek(35),
          alamatk(49),
          mzubb LIKE s031-mzubb,
          xblnr LIKE mkpf-xblnr,
          invom LIKE mseg-mblnr,
          invok LIKE mseg-mblnr,
          tangm LIKE mkpf-budat,
          tangk LIKE mkpf-budat,
          quanm LIKE mseg-menge,
          quank LIKE mseg-menge,
       END OF ta_all.

DATA:  wa_header  TYPE ta_header,
       i_itab     TYPE ta_itab OCCURS 0 WITH HEADER LINE,
       wa_itab    TYPE ta_itab,
       i_itab1    TYPE ta_itab OCCURS 0,
       wa_itab1   TYPE ta_itab,
       i_temp1    TYPE ta_itab OCCURS 0,
       wa_temp1   TYPE ta_itab,
       i_all      TYPE ta_all OCCURS 0,
       wa_all     TYPE ta_all,
       i_total    TYPE ta_total OCCURS 0,
       wa_total   TYPE ta_total.

DATA: total TYPE p DECIMALS 3,
      total1 TYPE p DECIMALS 3,
      bulan(10),
      year(4),
      address(50),
      city(25),
      telp(25),
      pbf(40),
      izin(40),
      izin1(40).

* Internal table untuk data material OKT
DATA  BEGIN OF t_okt OCCURS 1.
DATA:    matnr   LIKE mara-matnr,
         meins   LIKE mara-meins,
         ersda   LIKE mara-ersda,
         maktx   LIKE makt-maktx.
DATA  END   OF t_okt.

* Internal table untuk data stock material
DATA  BEGIN OF t_stock OCCURS 1.
DATA:    matnr   LIKE s032-matnr,
         mbwbest LIKE s032-mbwbest,
         end_st  LIKE s032-mbwbest.
DATA  END   OF t_stock.

DATA: l_menge1 LIKE mseg-menge,
      v_spmon LIKE s031-spmon,
      va_ort01(30),
      gv_bukrs  TYPE bukrs.

RANGES : ra_lgort FOR mseg-lgort,
         ra_umlgo FOR mseg-umlgo,
         ra_kunnr FOR mseg-kunnr.

DATA: BEGIN OF gt_s933 OCCURS 0,
        spmon   TYPE spmon,
        werks   TYPE werks_d,
        matnr   TYPE matnr,
        bwart   TYPE bwart,
        charg   TYPE charg_d,
        mblnr   TYPE mblnr,
        budat   TYPE budat,
        lgort   TYPE lgort_d,
        vrsio   TYPE vrsio,
        menge   TYPE mc_meng,
      END OF gt_s933.

DATA : gt_zmpsikor TYPE STANDARD TABLE OF zmpsikor,
       wa_zmpsikor TYPE zmpsikor.

* Input screen
SELECTION-SCREEN BEGIN OF BLOCK xbclk1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  so_spmon FOR s031-spmon OBLIGATORY NO INTERVALS
                          DEFAULT sy-datum(6).   " Period
PARAMETERS:
  p_werks  LIKE t001w-werks OBLIGATORY. " Plant
SELECTION-SCREEN SKIP 1.
PARAMETERS:
  p_nama(50) OBLIGATORY DEFAULT sy-uname,
  p_nosik(50) OBLIGATORY.
SELECTION-SCREEN END OF BLOCK xbclk1.

*PARAMETERS: p_incsut  AS CHECKBOX.

* Search help untuk period
INCLUDE rmcs0f0m.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_spmon-low.
  PERFORM monat_f4.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_SPMON-HIGH.
*  PERFORM MONAT_F4.

AT SELECTION-SCREEN.
  DATA: ld_datum  TYPE sy-datum,
        ld_cekdt  TYPE sy-datum.
  ld_datum  = sy-datum.
  CONCATENATE sy-datum(6) '05' INTO ld_cekdt.
  IF ld_datum LE ld_cekdt.
*    MESSAGE e000(zab) WITH 'Dijalankan setelah tanggal 5'.
  ENDIF.

************************************************************************
* TOP-OF-PAGE
************************************************************************
TOP-OF-PAGE.
  PERFORM top.

************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.

  SELECT SINGLE ort01
    FROM t001w
    INTO va_ort01
    WHERE werks EQ p_werks.

  RANGES ta_date FOR sy-datum.
  IF so_spmon-low NE space OR so_spmon-low NE 0.
    CONCATENATE so_spmon-low '01' INTO ta_date-low.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = ta_date-low
      IMPORTING
        last_day_of_month = ta_date-high.
    APPEND ta_date.
  ENDIF.

  IF so_spmon-high NE space OR so_spmon-high NE 0.
    CONCATENATE so_spmon-high '01' INTO ta_date-low.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = ta_date-low
      IMPORTING
        last_day_of_month = ta_date-high.
    CONCATENATE so_spmon-low '01' INTO ta_date-low.
    APPEND ta_date.
  ENDIF.

* For adjust beginning balance
  RANGES: ra_bwart FOR mseg-bwart,
          ra_slocs FOR mseg-lgort.

  ra_slocs-low     = 'S*'.
  ra_slocs-sign    = 'E'.
  ra_slocs-option  = 'CP'.
  APPEND ra_slocs.

  ra_bwart-low    = '7*'.
  ra_bwart-sign   = 'I'. ra_bwart-option = 'CP'.
  APPEND ra_bwart.

*ra_bwart-low    = '541'. ra_bwart-high   = '542'.
*ra_bwart-sign   = 'I'. ra_bwart-option = 'BT'.
*APPEND ra_bwart.

  IF so_spmon-low LT '200402'.

    ra_bwart-low    = '920'. ra_bwart-high   = '923'.
    ra_bwart-sign   = 'I'. ra_bwart-option = 'BT'.
    APPEND ra_bwart.

    ra_bwart-low    = '926'. ra_bwart-high   = '927'.
    ra_bwart-sign   = 'I'. ra_bwart-option = 'BT'.
    APPEND ra_bwart.

  ENDIF.

  ra_bwart-low    = '936'. ra_bwart-high   = '937'.
  ra_bwart-sign   = 'I'. ra_bwart-option = 'BT'.
  APPEND ra_bwart.

*-----------------------------------------------------*
* Get material OKT 09-10-2003 by MKO, OKT always ZPHA
*-----------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '10'
      text       = 'Data is being read...'.
*------------------------------------------------------*
  SELECT SINGLE bukrs
    FROM t001k
    INTO gv_bukrs
    WHERE bwkey EQ p_werks.

  DATA: BEGIN OF lt_datum OCCURS 0,
          date   TYPE sy-datum,
        END OF lt_datum.

  LOOP AT so_spmon.
    CONCATENATE so_spmon-low '01' INTO lt_datum-date.
    APPEND lt_datum.
  ENDLOOP.
  SORT lt_datum BY date.
  READ TABLE lt_datum INDEX 1.

  SELECT zmpsiko~matnr meins ersda maktx
  FROM zmpsiko INNER JOIN makt ON makt~matnr = zmpsiko~matnr
               JOIN mara ON zmpsiko~matnr = mara~matnr
  INTO CORRESPONDING FIELDS OF TABLE t_okt
  WHERE bukrs = gv_bukrs
    AND zmpsiko~datab LE lt_datum-date
    AND zmpsiko~datbi GE lt_datum-date.

* Tambahan untuk selisih stock opname
*  IF so_spmon-low EQ '201401'.
*  ELSE.
  PERFORM f_get_stock_opname.
*  ENDIF.

* Tambahan untuk proses stock point
  ra_lgort-low    = '1*'.
  ra_lgort-sign   = 'I'.
  ra_lgort-option = 'CP'.
  APPEND ra_lgort.

  IF p_werks EQ '0200'.
    ra_lgort-low    = '2*'.
    ra_lgort-sign   = 'I'.
    ra_lgort-option = 'CP'.
    APPEND ra_lgort.
  ENDIF.

  ra_umlgo-low    = '2*'.
  ra_umlgo-sign   = 'I'.
  ra_umlgo-option = 'CP'.
  APPEND ra_umlgo.

*  PERFORM f_init_sut.
  PERFORM begin_balance.
  PERFORM get_data.

* Proses data
  PERFORM receiving_data.
  PERFORM issuing_data.
  PERFORM all_data.
  PERFORM get_total.

* Display data
  PERFORM get_header_data.
  PERFORM cetak.

*&---------------------------------------------------------------------*
*&      Form  BEGIN_BALANCE
*&---------------------------------------------------------------------*
FORM begin_balance.
*------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '20'
      text       = 'Data is being read...'.
*------------------------------------------------------*
  DATA: l_spmon(6), n TYPE i.
* Internal table untuk data stock movement material
  DATA  BEGIN OF t_movement OCCURS 1.
  DATA:    matnr   LIKE s031-matnr,
           mzubb   LIKE s031-mzubb,
           magbb   LIKE s031-magbb.
  DATA  END   OF t_movement.

  MOVE so_spmon-low+0(6) TO l_spmon.

  RANGES ra_matnr FOR mseg-matnr.

* Isi table range material OKT, untuk input selection
  LOOP AT t_okt.
* Cek tanggal create material
    IF t_okt-ersda <= ta_date-high.
      ra_matnr-low    = t_okt-matnr.
      ra_matnr-sign   = 'I'.
      ra_matnr-option = 'EQ'.
      APPEND ra_matnr.
    ELSE.
* bila lebih besar dari input tidak perlu dibaca
      DELETE t_okt.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE t_okt LINES n.
  IF n = 0.
    MESSAGE a002(zz) WITH 'No data found'.
  ENDIF.

*-------------*
* Logic Mundur
*-------------*
* Baca ending saat ini dari S032
  SELECT matnr SUM( mbwbest ) FROM s032
  INTO TABLE t_stock
  WHERE ssour = ''      AND
        vrsio = '000'   AND
        werks = p_werks AND
        lgort NE space  AND
        lgort IN ra_lgort AND
*        lgort ne '1100' and
        matnr IN ra_matnr
  GROUP BY matnr.

* Baca movement qty dari bulan input sampai saat ini
  SELECT matnr SUM( mzubb ) SUM( magbb ) FROM s031
  INTO TABLE t_movement
  WHERE ssour = ''         AND
        vrsio = '000'      AND
        spmon GE l_spmon   AND
        sptag = '00000000' AND
        spwoc = '000000'   AND
        spbup = '000000'   AND
        werks = p_werks    AND
        lgort NE space     AND
        lgort IN ra_lgort  AND
*        lgort ne '1100'    and
        matnr IN ra_matnr
  GROUP BY matnr.
  REFRESH ra_matnr.

* Hitung ending stock
  CLEAR: wa_all.
  SORT t_stock BY matnr.
  SORT t_okt BY matnr.
  LOOP AT t_stock.
    CLEAR t_movement.
*{   INSERT         P01K910333                                        1
    "Start SOH: Shell SCI Adjustment 20240222 RZL
    SORT t_movement by matnr.
    "End SOH: Shell SCI Adjustment 20240222 RZL
*}   INSERT
    READ TABLE t_movement WITH KEY matnr = t_stock-matnr
                                   BINARY SEARCH.
    t_stock-end_st = t_stock-mbwbest -
                     t_movement-mzubb + t_movement-magbb.
    MODIFY t_stock.

*---------------------------------------------*
* TAMBAHAN UNTUK BEGGINING BALANCE 07-08-2003
*---------------------------------------------*
    MOVE p_werks TO wa_all-werks.
    MOVE t_stock-matnr TO wa_all-matnr.
    MOVE space TO wa_all-tangk.
    MOVE space TO wa_all-tangm.

    READ TABLE t_okt WITH KEY matnr = t_stock-matnr BINARY SEARCH.
    wa_all-meins = t_okt-meins.
    wa_all-maktx = t_okt-maktx.

*Masukkan ending stock ke MZUBB
    wa_all-mzubb = t_stock-end_st.
* Isi data ke table output
    APPEND wa_all TO i_all.
    CLEAR: wa_all.
  ENDLOOP.

  REFRESH t_movement.
ENDFORM.                    " BEGIN_BALANCE

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
FORM get_data.

*------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '40'
      text       = 'Data is being read...'.
*------------------------------------------------------*
  IF so_spmon-low GE '200402'.
    SELECT mseg~werks mseg~umwrk mseg~mblnr mseg~mjahr mseg~zeile
           mseg~sgtxt mseg~smbln mseg~sjahr mseg~smblp mseg~bwart
           mseg~menge mseg~ebeln mseg~lgort mseg~umlgo mseg~kunnr
           mseg~lifnr mseg~matnr mseg~shkzg
           mkpf~budat mkpf~xblnr
      FROM ( mseg INNER JOIN mkpf
        ON   mkpf~mblnr = mseg~mblnr AND
             mkpf~mjahr = mseg~mjahr )
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      FOR ALL ENTRIES IN t_okt
      WHERE mseg~matnr = t_okt-matnr AND
            mseg~werks EQ p_werks AND
            umwrk NE p_werks AND
            bwart NE '561'   AND
            bwart NE '562'   AND
            bwart NE '909'   AND
            bwart NE '910'   AND
            lgort NE space   AND
            lgort IN ra_lgort AND
            budat GE ta_date-low AND
            budat LE ta_date-high AND
            kunnr IN ra_kunnr.

* Tambah utk mtyp = '303', recv.plant = issu.plant
    SELECT mseg~werks mseg~umwrk mseg~mblnr mseg~mjahr mseg~zeile
           mseg~sgtxt mseg~smbln mseg~sjahr mseg~smblp mseg~bwart
           mseg~menge mseg~ebeln mseg~lgort mseg~umlgo mseg~kunnr
           mseg~lifnr mseg~matnr mseg~shkzg
           mkpf~budat mkpf~xblnr
      FROM ( mseg INNER JOIN mkpf
        ON   mkpf~mblnr = mseg~mblnr AND
             mkpf~mjahr = mseg~mjahr )
      APPENDING corresponding fields of table i_itab
      FOR ALL ENTRIES IN t_okt
      WHERE mseg~matnr = t_okt-matnr AND
            mseg~werks EQ p_werks AND
            umwrk EQ p_werks AND
            bwart EQ '303'   AND
            lgort NE space   AND
            lgort IN ra_lgort AND
            budat GE ta_date-low AND
            budat LE ta_date-high AND
            kunnr IN ra_kunnr.
  ELSE.
    SELECT mseg~werks mseg~umwrk mseg~mblnr mseg~mjahr mseg~zeile
           mseg~sgtxt mseg~smbln mseg~sjahr mseg~smblp mseg~bwart
           mseg~menge mseg~ebeln mseg~lgort mseg~umlgo mseg~kunnr
           mseg~lifnr mseg~matnr mseg~shkzg
           mkpf~budat mkpf~xblnr
      FROM ( mseg INNER JOIN mkpf
        ON   mkpf~mblnr = mseg~mblnr AND
             mkpf~mjahr = mseg~mjahr )
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      FOR ALL ENTRIES IN t_okt
      WHERE mseg~matnr = t_okt-matnr AND
            mseg~werks EQ p_werks AND
            umwrk NE p_werks AND
            bwart NE '561'   AND
            bwart NE '562'   AND
            bwart NE '920'   AND
            bwart NE '921'   AND
            bwart NE '922'   AND
            lgort NE space   AND
            lgort IN ra_lgort AND
            budat GE ta_date-low AND
            budat LE ta_date-high AND
            kunnr IN ra_kunnr.
  ENDIF.

* Tambahan untuk transfer ke stock point
  SELECT mseg~werks mseg~umwrk mseg~mblnr mseg~mjahr mseg~zeile
         mseg~sgtxt mseg~smbln mseg~sjahr mseg~smblp mseg~bwart
         mseg~menge mseg~ebeln mseg~lgort mseg~umlgo mseg~kunnr
         mseg~lifnr mseg~matnr mseg~shkzg
         mkpf~budat mkpf~xblnr
    FROM ( mseg INNER JOIN mkpf
      ON   mkpf~mblnr = mseg~mblnr AND
           mkpf~mjahr = mseg~mjahr )
    APPENDING corresponding fields of table i_itab
    FOR ALL ENTRIES IN t_okt
    WHERE mseg~matnr = t_okt-matnr AND
          mseg~werks EQ p_werks AND
*          UMWRK NE P_WERKS AND
          ( bwart EQ '311'   OR
          bwart EQ '312' )  AND
          lgort IN ra_lgort AND
          umlgo IN ra_umlgo AND
          budat GE ta_date-low AND
          budat LE ta_date-high AND
          kunnr IN ra_kunnr.

*------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '50'
      text       = 'Data is being read...'.
*------------------------------------------------------*

* movement stock opname tidak dimunculkan
* 06-08-2003
  IF so_spmon-low GE '200307'.
    DELETE i_itab WHERE bwart    = '936' OR
                        bwart    = '937'. "OR
*                        bwart(1) = '7'.
  ENDIF.

* Split data untuk receipt dan issue dan cek cancel utk issue
* I_ITAB untuk receving I_ITAB1 untuk issuing
  SORT i_itab BY shkzg mblnr mjahr zeile matnr.
  LOOP AT i_itab WHERE shkzg = 'H'.
    IF i_itab-smbln NE space.
* KONDISI BWART 303 UNTUK BULAN JANUARI 2003
      IF i_itab-bwart EQ '304' AND so_spmon-low EQ '200301'.
        APPEND i_itab TO i_itab1.
        DELETE i_itab.
      ELSE.
        DELETE i_itab WHERE mblnr = i_itab-smbln AND
                            mjahr = i_itab-sjahr AND
                            zeile = i_itab-smblp AND
                            matnr = i_itab-matnr AND
                            shkzg = 'S'.
        IF sy-subrc <> 0.
          APPEND i_itab TO i_itab1.
        ENDIF.
        DELETE i_itab.
      ENDIF.
    ELSE.
      APPEND i_itab TO i_itab1.
      DELETE i_itab.
    ENDIF.
  ENDLOOP.

* Delete 303 S (Receive)
  DELETE i_itab WHERE bwart = '303'.

*-----------------------------------*
* Start remove cancel untuk receipt
*-----------------------------------*
  SORT i_itab BY matnr bwart.
  SORT i_itab1 BY mblnr mjahr zeile matnr.
  LOOP AT i_itab WHERE smbln NE space.
    DELETE i_itab1 WHERE
    mblnr = i_itab-smbln AND
    mjahr = i_itab-sjahr AND
    zeile = i_itab-smblp AND
    matnr = i_itab-matnr.
    IF sy-subrc = 0.
      DELETE i_itab.
    ENDIF.
  ENDLOOP.

*-----------------------------------*
* Start remove cancel untuk beda bulan
*-----------------------------------*
  LOOP AT i_itab1 INTO wa_itab1.
    IF wa_itab1-smbln IS NOT INITIAL.
      DELETE i_itab1.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  RECEIVING_DATA
*&---------------------------------------------------------------------*
FORM receiving_data.
*------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '60'
      text       = 'Data is being read...'.
*------------------------------------------------------*
  DATA : l_reswk LIKE ekko-reswk,
         l_kunnr LIKE kna1-kunnr,
         l_alamat1(29),
         l_adrnr  LIKE kna1-adrnr,
         l_name3  LIKE adrc-name_co,
         l_street  LIKE adrc-street,
         l_city1   LIKE adrc-city1,
         l_postcode  LIKE adrc-post_code1.

  RANGES: lr_lgort  FOR mseg-lgort.
  lr_lgort-low    = '2*'.
  lr_lgort-sign   = 'I'.
  lr_lgort-option = 'CP'.
  APPEND lr_lgort.

  CLEAR: wa_itab, l_reswk.

* Baca 303 H (issue) untuk semua plant
  SELECT *
    FROM mseg INNER JOIN mkpf
    ON   mkpf~mblnr = mseg~mblnr AND
         mkpf~mjahr = mseg~mjahr
    INTO CORRESPONDING FIELDS OF TABLE i_temp1
    FOR ALL ENTRIES IN t_okt
    WHERE budat <= ta_date-high AND
          bwart = '303'       AND
          umwrk = p_werks     AND
          matnr = t_okt-matnr AND
          lgort NE space      AND
          lgort IN ra_lgort   AND
          shkzg EQ 'H'.

  SORT i_itab BY matnr mblnr.

  LOOP AT i_itab INTO wa_itab.
* Jika bukan Retur EC-PTT
    IF wa_itab-bwart NE '913'.
* Jika vendor tidak ada
      IF wa_itab-lifnr EQ space.
* Jika GR STO
        IF wa_itab-ebeln NE space.
          SELECT SINGLE name1 stras reswk
          FROM t001w INNER JOIN ekko
            ON ekko~reswk = t001w~werks
          INTO (wa_itab-name1, wa_itab-stras, l_reswk)
          WHERE ebeln EQ wa_itab-ebeln.
* Jika supplying plant adalah 0200
          IF l_reswk EQ '0200'.
            SELECT SINGLE lgobe
            FROM t001l
            INTO wa_itab-name1
            WHERE werks EQ l_reswk AND
                  lgort EQ wa_itab-lgort.
            MOVE space  TO wa_itab-stras.

            IF wa_itab-lgort EQ '1000'.
*              wa_itab-name1 = 'PT. TEMPO Gudang 2'.
              wa_itab-name1 = 'PT. TEMPO Pusat'.
            ENDIF.
          ENDIF.
* Jika bukan GR
        ELSE.
          IF wa_itab-bwart EQ '315'.
            CONTINUE.
          ENDIF.
*   Jika movement type 305
          IF wa_itab-bwart = '305'.
            CLEAR: wa_temp1.
            SORT i_temp1 BY mblnr.
*   Baca plant pengirim dari tabel 303 H
            READ TABLE i_temp1 INTO wa_temp1
            WITH KEY umwrk = wa_itab-werks
                     matnr = wa_itab-matnr
                     mblnr = wa_itab-sgtxt+0(10).
*   Jika ketemu baca nama dan alamat
            IF sy-subrc = 0.
              IF wa_temp1-lgort IN lr_lgort.
                SELECT SINGLE kunnr
                FROM t001l
                INTO l_kunnr
                WHERE werks EQ wa_temp1-werks AND
                      lgort EQ wa_temp1-lgort.
                IF sy-subrc EQ 0.
                  SELECT SINGLE name1 name2 stras adrnr
                  FROM kna1
                  INTO (wa_itab-name1, wa_itab-stras, l_alamat1, l_adrnr)
                  WHERE kunnr EQ l_kunnr.
                  IF sy-subrc EQ 0.
                    SELECT SINGLE name_co street city1 post_code1
                      FROM adrc
                      INTO (l_name3, l_street, l_city1, l_postcode)
                      WHERE addrnumber  EQ l_adrnr.
                    IF sy-subrc EQ 0.
                      wa_itab-name1  = l_name3.
                      CONCATENATE l_street l_city1 l_postcode INTO wa_itab-stras
                      SEPARATED BY space.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ELSE.
                SELECT SINGLE name1 stras
                  FROM t001w
                  INTO (wa_itab-name1, wa_itab-stras)
                  WHERE werks EQ wa_temp1-werks.

                IF wa_temp1-werks EQ '0201'.
*                wa_itab-name1 = 'PT. TEMPO Gudang 1'.
                ELSEIF wa_temp1-werks EQ '0200'.
*                wa_itab-name1 = 'PT. TEMPO Gudang 2'.
                  wa_itab-name1 = 'PT. TEMPO Pusat'.
                ENDIF.
              ENDIF.
            ENDIF.
*   Jika movement type 312
          ELSEIF wa_itab-bwart = '312'.
            SELECT SINGLE lgobe
            FROM t001l
            INTO wa_itab-name1
            WHERE werks EQ wa_itab-umwrk AND
                  lgort EQ wa_itab-umlgo.
            MOVE space  TO wa_itab-stras.

            IF wa_itab-umwrk EQ '0200' AND
              wa_itab-umlgo EQ '1000'.
*              wa_itab-name1 = 'PT. TEMPO Gudang 2'.
              wa_itab-name1 = 'PT. TEMPO Pusat'.
            ENDIF.
*   Jika bukan movement type 305 dan 312
          ELSE.
            SELECT SINGLE name1 stras
              FROM t001w
              INTO (wa_itab-name1, wa_itab-stras)
              WHERE werks EQ wa_itab-umwrk.
            IF sy-subrc <> 0.
              SELECT SINGLE btext
                FROM t156t
                INTO wa_itab-name1
                WHERE spras = 'EN'           AND
                      bwart EQ wa_itab-bwart AND
                      sobkz = ''.
            ELSE.
              IF wa_itab-umwrk EQ '0201'.
*                wa_itab-name1 = 'PT. TEMPO Gudang 1'.
              ELSEIF wa_itab-umwrk EQ '0200'.
*                wa_itab-name1 = 'PT. TEMPO Gudang 2'.
                wa_itab-name1 = 'PT. TEMPO Pusat'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
* Jika vendor ada
        SELECT SINGLE name1 stras
        FROM lfa1
        INTO (wa_itab-name1, wa_itab-stras)
        WHERE lifnr EQ wa_itab-lifnr.
      ENDIF.
    ENDIF.

    IF wa_itab-kunnr NE space.
      SELECT SINGLE name1 name2
      FROM kna1
      INTO (wa_itab-name1, wa_itab-stras)
      WHERE kunnr EQ wa_itab-kunnr.
    ENDIF.

    MODIFY i_itab FROM wa_itab.

*-----------------------------------------------*
* Isi table output
*-----------------------------------------------*
    IF wa_itab-bwart EQ '655' OR
       wa_itab-bwart EQ '653'.
      MOVE wa_itab-xblnr TO wa_all-invom.
    ELSE.
      MOVE wa_itab-mblnr TO wa_all-invom.
    ENDIF.

    IF wa_itab-bwart EQ '101'.
      MOVE wa_itab-xblnr TO wa_all-xblnr.
    ENDIF.

    ON CHANGE OF wa_itab-matnr OR
                 wa_itab-mblnr.

      MOVE wa_itab-matnr TO wa_all-matnr.
      MOVE wa_itab-mblnr TO wa_all-mblnr.
      MOVE wa_itab-bwart TO wa_all-bwart.
      MOVE wa_itab-werks TO wa_all-werks.
      MOVE wa_itab-menge TO wa_all-menge.
      IF wa_itab-bwart(1) EQ '7'.
        wa_all-namem = 'Lain-lain'.
      ELSE.
        MOVE wa_itab-name1 TO wa_all-namem.
      ENDIF.
      MOVE wa_itab-stras TO wa_all-alamatm.
      MOVE wa_itab-budat TO wa_all-tangm.
      MOVE space TO wa_all-namek.
      MOVE space TO wa_all-alamatk.
      MOVE space TO wa_all-invok.
      MOVE space TO wa_all-tangk.
      MOVE space TO wa_all-quank.

      READ TABLE t_okt WITH KEY matnr = wa_itab-matnr BINARY SEARCH.
      wa_all-meins = t_okt-meins.
      wa_all-maktx = t_okt-maktx.

* Masukkan ending stock ke MZUBB
      READ TABLE t_stock WITH KEY matnr = wa_itab-matnr BINARY SEARCH.
      wa_all-mzubb = t_stock-end_st.

      APPEND wa_all TO i_all.
    ENDON.
*-----------------------------------------------*

    CLEAR: wa_itab, wa_all-xblnr.
  ENDLOOP.
  FREE i_temp1.
ENDFORM.                    " RECEIVING_DATA

*&---------------------------------------------------------------------*
*&      Form  ISSUING_DATA
*&---------------------------------------------------------------------*
FORM issuing_data.
*------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '80'
      text       = 'Data is being read...'.
*------------------------------------------------------*
  DATA: l_alamat1(29),
        l_adrnr  LIKE kna1-adrnr,
        l_name3  LIKE adrc-name_co,
        l_street  LIKE adrc-street,
        l_city1   LIKE adrc-city1,
        l_postcode  LIKE adrc-post_code1.

  CLEAR: wa_itab1.

*  SORT i_itab1 BY matnr mblnr.
  SORT i_itab1 BY matnr mblnr bwart.
  LOOP AT i_itab1 INTO wa_itab1.
    IF wa_itab1-xblnr NE space.
* Modify posting date menjadi delivery date
      SELECT SINGLE erdat
      FROM vbfa
      INTO wa_itab1-budat
      WHERE vbelv EQ wa_itab1-xblnr AND
            vbtyp_n EQ 'R' AND
            vbtyp_v NE 'H'.
    ENDIF.

    IF wa_itab1-umwrk EQ space.
      IF wa_itab1-lifnr NE space.
        SELECT SINGLE name1 stras
        FROM lfa1
        INTO (wa_itab1-name1, wa_itab1-stras)
        WHERE lifnr EQ wa_itab1-lifnr.
      ELSE.
        SELECT SINGLE name1 name2 stras
        FROM kna1
        INTO (wa_itab1-name1, wa_itab1-stras, l_alamat1)
        WHERE kunnr EQ wa_itab1-kunnr.

        IF sy-subrc = '0' AND wa_itab1-kunnr+0(3) = 'TBA'.
          MOVE l_alamat1 TO wa_itab1-stras.
        ENDIF.
        IF sy-subrc <> 0.
          SELECT SINGLE btext
          FROM t156t
          INTO wa_itab1-name1
          WHERE spras = 'EN'           AND
                bwart EQ wa_itab1-bwart AND
                sobkz = ''.
        ENDIF.
      ENDIF.
    ELSEIF wa_itab1-umwrk NE space.
* Untuk cek apakah plant tujuan adalah 0200
      IF wa_itab1-umwrk = '0200'.
        SELECT SINGLE lgobe
          FROM t001l
          INTO wa_itab1-name1
          WHERE werks EQ wa_itab1-umwrk AND
                lgort EQ wa_itab1-umlgo.
        MOVE space  TO wa_itab1-stras.

        IF wa_itab1-umlgo EQ '1000'.
*          wa_itab1-name1 = 'PT. TEMPO Gudang 2'.
          wa_itab-name1 = 'PT. TEMPO Pusat'.
        ENDIF.
** Untuk cek apakah sloc tujuan adalah stock point
*      ELSEIF wa_itab1-bwart = '311'.
*        SELECT SINGLE lgobe
*          FROM t001l
*          INTO wa_itab1-name1
*          WHERE werks EQ wa_itab1-umwrk AND
*                lgort EQ wa_itab1-umlgo.
*        MOVE space  TO wa_itab1-stras.
*
*        IF wa_itab1-umwrk EQ '0200' AND
*          wa_itab1-umlgo EQ '1000'.
**          wa_itab1-name1 = 'PT. TEMPO Gudang 2'.
*          wa_itab-name1 = 'PT. TEMPO Pusat'.
*        ENDIF.
      ELSE.
        IF wa_itab1-kunnr EQ space.
          SELECT SINGLE name1 stras
            FROM t001w
            INTO (wa_itab1-name1, wa_itab1-stras)
            WHERE werks EQ wa_itab1-umwrk.

          IF wa_itab1-umwrk EQ '0201'.
*          wa_itab1-name1 = 'PT. TEMPO Gudang 1'.
          ELSEIF wa_itab1-umwrk EQ '0200'.
*          wa_itab1-name1 = 'PT. TEMPO Gudang 2'.
            wa_itab-name1 = 'PT. TEMPO Pusat'.
          ENDIF.
        ELSE.
          SELECT SINGLE name1 name2 stras adrnr
          FROM kna1
          INTO (wa_itab1-name1, wa_itab1-stras, l_alamat1, l_adrnr)
          WHERE kunnr EQ wa_itab1-kunnr.
          IF sy-subrc EQ 0.
            SELECT SINGLE name_co street city1 post_code1
              FROM adrc
              INTO (l_name3, l_street, l_city1, l_postcode)
              WHERE addrnumber  EQ l_adrnr.
            IF sy-subrc EQ 0.
              wa_itab1-name1  = l_name3.
              CONCATENATE l_street l_city1 l_postcode INTO wa_itab1-stras
              SEPARATED BY space.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY i_itab1 FROM wa_itab1.

*-----------------------------------------------*
* Isi table output
*-----------------------------------------------*
    IF wa_itab1-xblnr EQ space.
      MOVE wa_itab1-mblnr TO wa_all-invok.
    ELSE.
      IF wa_itab1-bwart EQ '303'.
        MOVE wa_itab1-mblnr TO wa_all-invok.
        wa_itab1-name1  = 'PT. TEMPO Pusat'.
      ELSE.
        MOVE wa_itab1-xblnr TO wa_all-invok.
      ENDIF.
    ENDIF.

*    ON CHANGE OF wa_itab1-matnr OR
*                 wa_itab1-mblnr.
    ON CHANGE OF wa_itab1-matnr OR
                 wa_itab1-mblnr OR
                 wa_itab1-bwart.
      MOVE wa_itab1-matnr TO wa_all-matnr.
      MOVE wa_itab1-mblnr TO wa_all-mblnr.
      MOVE wa_itab1-bwart TO wa_all-bwart.
      MOVE wa_itab1-werks TO wa_all-werks.
      MOVE wa_itab1-menge TO wa_all-menge.
      IF wa_itab1-bwart(1) EQ '7'.
        wa_all-namek  = 'Lain-lain'.
      ELSE.
        MOVE wa_itab1-name1 TO wa_all-namek.
      ENDIF.
      MOVE wa_itab1-stras TO wa_all-alamatk.
      MOVE wa_itab1-budat TO wa_all-tangk.
      MOVE space TO wa_all-namem.
      MOVE space TO wa_all-alamatm.
      MOVE space TO wa_all-invom.
      MOVE space TO wa_all-tangm.
      MOVE space TO wa_all-xblnr.
      MOVE space TO wa_all-quanm.

      READ TABLE t_okt WITH KEY matnr = wa_itab1-matnr BINARY SEARCH.
      wa_all-meins = t_okt-meins.
      wa_all-maktx = t_okt-maktx.

*Masukkan ending stock ke MZUBB
      READ TABLE t_stock WITH KEY matnr = wa_itab1-matnr BINARY SEARCH.
      wa_all-mzubb = t_stock-end_st.

      APPEND wa_all TO i_all.
    ENDON.
*-----------------------------------------------*
    CLEAR:wa_itab1.
  ENDLOOP.

ENDFORM.                    " ISSUING_DATA


*&---------------------------------------------------------------------*
*&      Form  ALL_DATA
*&---------------------------------------------------------------------*
FORM all_data.
*------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '100'
      text       = 'Data is being read...'.
*------------------------------------------------------*
  DATA : l_quan  LIKE wa_itab-menge.
  DATA : lt_koreksi TYPE STANDARD TABLE OF zmpsikor,
         lt_invo    TYPE STANDARD TABLE OF zmpsikor,
         wa_invo    TYPE zmpsikor.

  LOOP AT i_all INTO wa_all.
    wa_invo-mblnr = wa_all-mblnr.
    wa_invo-mjahr = so_spmon-low(4).
    APPEND wa_invo TO lt_koreksi.
    CLEAR wa_invo.
  ENDLOOP.

  IF lt_koreksi[] IS NOT INITIAL.
    SELECT *
      FROM zmpsikor
      INTO CORRESPONDING FIELDS OF TABLE lt_invo
      FOR ALL ENTRIES IN lt_koreksi
      WHERE mblnr EQ lt_koreksi-mblnr
        AND mjahr EQ lt_koreksi-mjahr.
  ENDIF.

  CLEAR: wa_all.
  SORT i_all BY matnr mblnr.
  LOOP AT i_all INTO wa_all.
    CLEAR: wa_itab.

    READ TABLE lt_invo INTO wa_invo WITH KEY mblnr = wa_all-mblnr.
    IF sy-subrc EQ 0.
      DELETE i_all.
      CONTINUE.
    ENDIF.

* Hitung total qty masuk
    SORT i_itab BY matnr mblnr.
    LOOP AT i_itab INTO wa_itab WHERE matnr EQ wa_all-matnr AND
                                      mblnr EQ wa_all-mblnr AND
                                      bwart EQ wa_all-bwart.
      ADD wa_itab-menge TO l_quan.
      CLEAR: wa_itab.
    ENDLOOP.
    MOVE l_quan TO wa_all-quanm.

    IF sy-subrc <> 0.
* Hitung total qty keluar
      SORT i_itab1 BY matnr mblnr.
      LOOP AT i_itab1 INTO wa_itab1 WHERE matnr EQ wa_all-matnr AND
                                          mblnr EQ wa_all-mblnr AND
* KOREKSI MATERIAL DOCUMENT SAMA 07-05-2003.
                                          bwart EQ wa_all-bwart.
        ADD wa_itab1-menge TO l_quan.
        CLEAR: wa_itab1.
      ENDLOOP.
      MOVE l_quan TO wa_all-quank.
    ENDIF.

    MODIFY i_all FROM wa_all.
    CLEAR: wa_all, l_quan.
  ENDLOOP.

* Free Memory
  FREE : i_itab, i_itab1, t_okt.
ENDFORM.                    " ALL_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_TOTAL
*&---------------------------------------------------------------------*
FORM get_total.
  CLEAR: wa_all.
  SORT i_all BY matnr.
  LOOP AT i_all INTO wa_all.
    ADD wa_all-quanm TO wa_total-totalm.
    ADD wa_all-quank TO wa_total-totalk.
    AT END OF matnr.
      MOVE wa_all-matnr TO wa_total-matnr.
      APPEND wa_total TO i_total.
      CLEAR: wa_total-totalm, wa_total-totalk.
    ENDAT.
    CLEAR: wa_all.
  ENDLOOP.
ENDFORM.                    " GET_TOTAL

*&---------------------------------------------------------------------*
*&      Form  GET_HEADER_DATA
*&---------------------------------------------------------------------*
FORM get_header_data.

  SELECT SINGLE a~adrnr a~werks b~addrnumber b~name1 b~name2 b~name3
                b~name4 b~city1 b~post_code1 b~street b~house_num1
                b~tel_number b~fax_number b~str_suppl3 b~location
  FROM twlad AS a JOIN adrc AS b
    ON a~adrnr EQ b~addrnumber
  INTO CORRESPONDING FIELDS OF wa_header
  WHERE werks EQ p_werks AND
  lgort EQ '1000'.

  IF sy-subrc NE 0.
    SELECT SINGLE a~adrnr a~werks b~addrnumber b~name1 b~name2 b~name3
                  b~name4 b~city1 b~post_code1 b~street b~house_num1
                  b~tel_number b~fax_number b~str_suppl3 b~location
    FROM t001w AS a JOIN adrc AS b
      ON a~adrnr EQ b~addrnumber
    INTO CORRESPONDING FIELDS OF wa_header
    WHERE werks EQ p_werks.
  ENDIF.
  IF p_werks = '0201'.
*    wa_header-name1 = 'PT. TEMPO Gudang 1'.
  ELSEIF p_werks = '0200'.
*    wa_header-name1 = 'PT. TEMPO Gudang 2'.
    wa_itab-name1 = 'PT. TEMPO Pusat'.
  ENDIF.
ENDFORM.                    " GET_HEADER_DATA

*&---------------------------------------------------------------------*
*&      Form  CETAK
*&---------------------------------------------------------------------*
FORM cetak.
  DATA: l_beg_bal       LIKE s031-mzubb,
        l_beg(10),
        l_end_bal       LIKE s031-mzubb,
        l_end(10),
        l_total_masuk   LIKE mseg-menge,
        l_total_keluar  LIKE mseg-menge,
        sw              TYPE i,
        sw1             TYPE i,
        sw2             TYPE i,
        sw_m            TYPE i,
        l_zero          TYPE i,
        no(3),
        quan_out(10),
        quan_out1(10),
        total_out(10),
        total_out1(10),
        l_datum(10),
        l_ort01(30).

  MOVE so_spmon-low+0(4) TO year.

  sw   = 0.
  sw1  = 0.
  sw2  = 0.
  sw_m = 0.
  no   = 1.

  CASE so_spmon-low+4(2).
    WHEN '01'.
      MOVE 'JANUARI' TO bulan.
    WHEN '02'.
      MOVE 'FEBRUARI' TO bulan.
    WHEN '03'.
      MOVE 'MARET' TO bulan.
    WHEN '04'.
      MOVE 'APRIL' TO bulan.
    WHEN '05'.
      MOVE 'MEI' TO bulan.
    WHEN '06'.
      MOVE 'JUNI' TO bulan.
    WHEN '07'.
      MOVE 'JULI' TO bulan.
    WHEN '08'.
      MOVE 'AGUSTUS' TO bulan.
    WHEN '09'.
      MOVE 'SEPTEMBER' TO bulan.
    WHEN '10'.
      MOVE 'OKTOBER' TO bulan.
    WHEN '11'.
      MOVE 'NOVEMBER' TO bulan.
    WHEN '12'.
      MOVE 'DESEMBER' TO bulan.
  ENDCASE.

  MOVE wa_header-name1 TO pbf.
  MOVE wa_header-location TO izin1.
  CONCATENATE wa_header-street wa_header-house_num1
    INTO address SEPARATED BY space.
  CONCATENATE wa_header-city1 '-' wa_header-post_code1
    INTO city SEPARATED BY space.
  CONCATENATE wa_header-tel_number '-' wa_header-fax_number
    INTO telp SEPARATED BY space.

  CLEAR: wa_all.
  SORT i_all BY matnr.
  LOOP AT i_all INTO wa_all.

    CLEAR: wa_total.
    SORT i_total BY matnr.
    READ TABLE i_total INTO wa_total WITH KEY matnr = wa_all-matnr
                                       BINARY SEARCH.

    IF sy-subrc = 0.
      l_total_masuk  = wa_total-totalm.
      l_total_keluar = wa_total-totalk.
    ELSE.
      l_total_masuk  = 0.
      l_total_keluar = 0.
    ENDIF.

    ON CHANGE OF wa_all-matnr.
      IF sw = 0.
        sw = 1.
      ELSE.
        IF sy-linno GE 55.
          ULINE.
          CLEAR l_ort01.
          CONCATENATE va_ort01 ',' INTO l_ort01.
          WRITE sy-datum TO l_datum DD/MM/YYYY.
          CONCATENATE l_ort01 l_datum INTO l_ort01 SEPARATED BY space.
          WRITE: /143 l_ort01.
          IF p_werks EQ '0200'.
*            WRITE:/143 'PENANGGUNG JAWAB PBF PT. TEMPO GUDANG 2'.
            WRITE:/143 'PENANGGUNG JAWAB PBF PT. TEMPO PUSAT'.
          ELSEIF p_werks EQ '0201'.
*            WRITE:/143 'PENANGGUNG JAWAB PBF PT. TEMPO GUDANG 1'.
            WRITE:/143 'PENANGGUNG JAWAB PBF', pbf.
          ELSE.
            WRITE:/143 'PENANGGUNG JAWAB PBF', pbf.
          ENDIF.
          SKIP 4.
          WRITE: /143 p_nama,
                 /143 sy-uline(20),
                 /143 'NO.SIKA :', p_nosik.
          sw2 = 1.
          NEW-PAGE.
        ENDIF.

        IF l_zero = 1.
          IF sw2 = 0.
            ULINE.
          ENDIF.

          WRITE: /    sy-vline,
                  108 sy-vline NO-GAP, total_out NO-GAP,
                      sy-vline,
                  171 sy-vline NO-GAP, total_out1 NO-GAP,
                  182 sy-vline,
                  193 sy-vline,
                  204 sy-vline.
          ULINE.
          ADD 1 TO no.
          sw2 = 0.
          CLEAR: total, total1, l_beg, l_beg_bal.
        ENDIF.
      ENDIF.
      sw1 = 0.
      CLEAR: l_zero.
    ENDON.

    ADD wa_all-quanm TO total.
    ADD wa_all-quank TO total1.
    WRITE wa_all-quanm TO quan_out  DECIMALS 0.
    WRITE wa_all-quank TO quan_out1 DECIMALS 0.
    WRITE total TO total_out DECIMALS 0.
    WRITE total1 TO total_out1 DECIMALS 0.

    IF sw1 = 0.
      PERFORM add_begbal.
      l_beg_bal = l_beg_bal + wa_all-mzubb - l_menge1.

*** command by email 26/02/2014
** Tambah stock opname
*      PERFORM f_hitung_stock_opname USING wa_all-matnr
*                                    CHANGING l_beg_bal.
***

*  Tambah Stock Awal u/ mat.doc no 4900713606 10/08/2003
*  Tdk di buat CN ( sudah write off )
* ETP
      IF wa_all-matnr = '015-20-00' AND
         wa_all-werks = '0202'      AND
         so_spmon-low = '200401'.
        l_beg_bal = l_beg_bal + 1.
      ENDIF.
*ETP
      l_end_bal = l_beg_bal + l_total_masuk - l_total_keluar.

      IF l_beg_bal NE 0 OR
        l_total_masuk NE 0 OR
        l_total_keluar NE 0.
        l_zero = 1.
        WRITE l_beg_bal TO l_beg DECIMALS 0.
        WRITE l_end_bal TO l_end DECIMALS 0.
        WRITE: /    sy-vline NO-GAP, no NO-GAP,
                5   sy-vline NO-GAP, wa_all-maktx,
                41  sy-vline NO-GAP, wa_all-meins NO-GAP,
                    sy-vline NO-GAP, l_beg NO-GAP,
                    sy-vline NO-GAP, wa_all-invom.
        IF wa_all-tangm NE space.
          WRITE:        wa_all-tangm NO-GAP.
        ENDIF.
        WRITE:  78  sy-vline NO-GAP, wa_all-namem.
        IF wa_all-quanm EQ 0.
          WRITE: 108  sy-vline.
        ELSE.
          WRITE: 108  sy-vline NO-GAP,
                      quan_out NO-GAP.
        ENDIF.
        WRITE: 119  sy-vline NO-GAP, wa_all-invok.
        IF wa_all-tangk NE space.
          WRITE:        wa_all-tangk NO-GAP.
        ENDIF.
        WRITE: 141  sy-vline NO-GAP, wa_all-namek.
        IF wa_all-quank EQ 0.
          WRITE  171  sy-vline.
        ELSE.
          WRITE: 171  sy-vline NO-GAP,
                      quan_out1 NO-GAP.
        ENDIF.
        WRITE: 182  sy-vline NO-GAP, l_end NO-GAP,
                    sy-vline,
               204  sy-vline.
        WRITE: /    sy-vline NO-GAP,
                 5  sy-vline NO-GAP,
                41  sy-vline NO-GAP,
                45  sy-vline NO-GAP,
                56  sy-vline NO-GAP, wa_all-xblnr,
                78  sy-vline NO-GAP, wa_all-alamatm NO-GAP,
                108 sy-vline NO-GAP,
                119 sy-vline NO-GAP,
                141 sy-vline NO-GAP, wa_all-alamatk NO-GAP,
                171 sy-vline NO-GAP,
                182 sy-vline NO-GAP,
                193 sy-vline NO-GAP,
                204 sy-vline.
        sw1 = 1.
      ENDIF.
    ELSE.
      WRITE: /    sy-vline,
              5   sy-vline,
              41  sy-vline,
              45  sy-vline,
              56  sy-vline NO-GAP, wa_all-invom.
      IF wa_all-tangm NE space.
        WRITE:       wa_all-tangm NO-GAP.
      ENDIF.
      WRITE:  78 sy-vline NO-GAP, wa_all-namem.
      IF wa_all-quanm EQ 0.
        WRITE: 108 sy-vline.
      ELSE.
        WRITE: 108 sy-vline NO-GAP,
                   quan_out NO-GAP.
      ENDIF.
      WRITE: 119 sy-vline NO-GAP, wa_all-invok.
      IF wa_all-tangk NE space.
        WRITE:       wa_all-tangk NO-GAP.
      ENDIF.
      WRITE: 141 sy-vline NO-GAP, wa_all-namek.
      IF wa_all-quank EQ 0.
        WRITE: 171 sy-vline.
      ELSE.
        WRITE: 171 sy-vline NO-GAP, quan_out1 NO-GAP.
      ENDIF.
      WRITE: 182 sy-vline,
             193 sy-vline,
             204 sy-vline.
      WRITE: /    sy-vline NO-GAP,
               5  sy-vline NO-GAP,
              41  sy-vline NO-GAP,
              45  sy-vline NO-GAP,
              56  sy-vline NO-GAP, wa_all-xblnr,
              78  sy-vline NO-GAP, wa_all-alamatm NO-GAP,
              108 sy-vline NO-GAP,
              119 sy-vline NO-GAP,
              141 sy-vline NO-GAP, wa_all-alamatk NO-GAP,
              171 sy-vline,
              182 sy-vline,
              193 sy-vline,
              204 sy-vline.
    ENDIF.

    IF sy-linno GE 58.
      ULINE.
      CLEAR l_ort01.
      CONCATENATE va_ort01 ',' INTO l_ort01.
      WRITE sy-datum TO l_datum DD/MM/YYYY.
      CONCATENATE l_ort01 l_datum INTO l_ort01 SEPARATED BY space.
      WRITE: /143 l_ort01.
      IF p_werks EQ '0200'.
*        WRITE:/143 'PENANGGUNG JAWAB PBF PT. TEMPO GUDANG 2'.
        WRITE:/143 'PENANGGUNG JAWAB PBF PT. TEMPO PUSAT'.
      ELSEIF p_werks EQ '0201'.
*        WRITE:/143 'PENANGGUNG JAWAB PBF PT. TEMPO GUDANG 1'.
        WRITE:/143 'PENANGGUNG JAWAB PBF', pbf.
      ELSE.
        WRITE:/143 'PENANGGUNG JAWAB PBF', pbf.
      ENDIF.
      SKIP 4.
      WRITE: /143 p_nama,
             /143 sy-uline(20),
             /143 'NO.SIKA:', p_nosik.
      NEW-PAGE.
    ENDIF.

    CLEAR: wa_all, l_total_masuk, l_total_keluar.
  ENDLOOP.

  IF l_zero = 1.
    ULINE.
    WRITE: /    sy-vline,
            108 sy-vline NO-GAP, total_out NO-GAP,
                sy-vline,
            171 sy-vline NO-GAP, total_out1 NO-GAP,
            182 sy-vline,
            193 sy-vline,
            204 sy-vline.
    ULINE.
  ENDIF.

  CLEAR l_ort01.
  CONCATENATE va_ort01 ',' INTO l_ort01.
  WRITE sy-datum TO l_datum DD/MM/YYYY.
  CONCATENATE l_ort01 l_datum INTO l_ort01 SEPARATED BY space.
  WRITE: /143 l_ort01.
  IF p_werks EQ '0200'.
*    WRITE:/143 'PENANGGUNG JAWAB PBF PT. TEMPO GUDANG 2'.
    WRITE:/143 'PENANGGUNG JAWAB PBF PT. TEMPO PUSAT'.
  ELSEIF p_werks EQ '0201'.
*    WRITE:/143 'PENANGGUNG JAWAB PBF PT. TEMPO GUDANG 1'.
    WRITE:/143 'PENANGGUNG JAWAB PBF', pbf.
  ELSE.
    WRITE:/143 'PENANGGUNG JAWAB PBF', pbf.
  ENDIF.
  SKIP 4.
  WRITE: /143 p_nama,
         /143 sy-uline(20),
         /143 'NO.SIKA.:', p_nosik.
  CLEAR: total.

* Free Memory
  FREE : i_all, i_total, t_stock, ra_bwart.
ENDFORM.                    " CETAK

*&---------------------------------------------------------------------*
*&      Form  ADD_BEGBAL
*&---------------------------------------------------------------------*
FORM add_begbal.
* PENAMBAHAN BEGINNING BALANCE DENGAN MOVEMENT
* (541,542,701-718,920-923,926,927,936,937)
  DATA: ta_date1-high LIKE s931-spmon,
        l_menge LIKE s931-menge.

  CLEAR l_menge1.
  IF so_spmon-low LT '200402'.
    IF so_spmon-low GE '200306'.
      ta_date1-high = '200306'.
      WHILE ( ta_date1-high < ta_date-low(6) ).
        SELECT SUM( menge ) FROM s931 INTO l_menge
        WHERE spmon = ta_date1-high(6)  AND
              werks = p_werks           AND
              lgort NE space            AND
              lgort EQ ra_slocs         AND
              matnr EQ wa_all-matnr     AND
            ( bwart IN ra_bwart OR
              bwart = '541' OR bwart = '542' ).
        ta_date1-high = ta_date1-high + 1.
        l_menge1 = l_menge1 + l_menge.
      ENDWHILE.
    ENDIF.

  ELSE.
* Exclude kompensasi begining stock karena pemutihan
    IF p_werks = '0200'.
      v_spmon = '200401'.
    ELSEIF p_werks = '0202'.
      v_spmon = '200309'.
    ELSE.
      v_spmon = '200306'.
    ENDIF.
    IF so_spmon-low GE v_spmon.
      ta_date1-high = v_spmon.
      WHILE ( ta_date1-high < ta_date-low(6) ).
        SELECT SUM( menge ) FROM s931 INTO l_menge
        WHERE spmon = ta_date1-high(6)  AND
              werks = p_werks           AND
              lgort NE space            AND
              lgort EQ ra_slocs         AND
              matnr EQ wa_all-matnr     AND
              bwart IN ra_bwart.
        ta_date1-high = ta_date1-high + 1.
        l_menge1 = l_menge1 + l_menge.
      ENDWHILE.
    ENDIF.
    IF so_spmon-low GE '200212'.
      ta_date1-high = '200212'.
      WHILE ( ta_date1-high < ta_date-low(6) ).
        SELECT SUM( menge ) FROM s931 INTO l_menge
        WHERE spmon = ta_date1-high(6)  AND
              werks = p_werks           AND
              lgort NE space            AND
              lgort EQ ra_slocs         AND
              matnr EQ wa_all-matnr     AND
            ( bwart = '541' OR bwart = '542' ).
        ta_date1-high = ta_date1-high + 1.
        l_menge1 = l_menge1 + l_menge.
      ENDWHILE.
    ENDIF.
  ENDIF.
ENDFORM.                    " ADD_BEGBAL

*&---------------------------------------------------------------------*
*&      Form  TOP
*&---------------------------------------------------------------------*
FORM top.
  DATA: l_pbfno LIKE zpbf-pbfno,
        l_vkbur LIKE zpbf-vkbur.

  l_vkbur = p_werks.
*  IF p_werks = '0200'.
*    l_vkbur = '0201'.
*  ENDIF.
  SELECT SINGLE pbfno INTO l_pbfno FROM zpbf
         WHERE vkbur = l_vkbur.

  izin = l_pbfno.

*  IF p_werks+0(2) = '02'.
**    IZIN = '31081/PBF/CAP-20/IX/96'.
*    izin = l_pbfno.
*  ELSE.
*    izin = '31108/PBF/III/1991'.
*  ENDIF.

  WRITE: /78 'LAPORAN PREKURSOR'.
  SKIP.
  WRITE: /    'NAMA P.B.F        :', pbf,
         /    'NOMOR IZIN        :', izin,
          110 'BULAN :', bulan,
         /    'NOMOR IZIN KHUSUS :', izin1,
         /    'ALAMAT & TELPON   :', address,
          110 'TAHUN :', year,
         /21  city,
         /21  'Telp :', telp.
  SKIP.
  ULINE.
  WRITE: /    sy-vline,
          5   sy-vline,
          41  sy-vline,
          45  sy-vline,
          56  sy-vline, 77 'P E M A S U K A N',
          119 sy-vline, 140 'P E N G E L U A R A N',
          182 sy-vline,
          193 sy-vline,
          204 sy-vline.

  WRITE: /    sy-vline,
          5   sy-vline,
          41  sy-vline,
          45  sy-vline NO-GAP, 'PERSEDIAAN',
          56  sy-vline,
          57  sy-uline(62),
          119 sy-vline,
          120 sy-uline(62),
          182 sy-vline NO-GAP, 'PERSEDIAAN',
          193 sy-vline,
          204 sy-vline.

  WRITE: /    sy-vline NO-GAP, 'NO' NO-GAP,
          5   sy-vline NO-GAP, 'NAMA PERSEDIAAN BARANG JADI ',
          41  sy-vline NO-GAP, 'SAT' NO-GAP,
          45  sy-vline NO-GAP, 'AWAL BULAN' NO-GAP,
          56  sy-vline NO-GAP, 'NO & TGL FAKTUR',
          78  sy-vline NO-GAP, 'DARI/ASAL',
          108 sy-vline NO-GAP, 'JUMLAH' NO-GAP,
          119 sy-vline NO-GAP, 'NO & TGL FAKTUR' NO-GAP,
          141 sy-vline NO-GAP, 'NAMA & ALAMAT PEMESAN' NO-GAP,
          171 sy-vline NO-GAP, 'JUMLAH' NO-GAP,
          182 sy-vline NO-GAP, 'AKHIR' NO-GAP,
          193 sy-vline NO-GAP, 'KETERANGAN' NO-GAP,
              sy-vline NO-GAP.
  ULINE.
ENDFORM.                    "TOP

*&---------------------------------------------------------------------*
*&      Form  F_GET_STOCK_OPNAME
*&---------------------------------------------------------------------*
FORM f_get_stock_opname .
  DATA: lv_datum  TYPE sy-datum,
        lv_spmon  TYPE spmon,
        lv_bwart  TYPE RANGE OF bwart,
        lv_lines  LIKE LINE OF lv_bwart,
        lt_s933   LIKE gt_s933 OCCURS 0 WITH HEADER LINE.

  CONCATENATE so_spmon-low '01' INTO lv_datum.
  lv_datum  = lv_datum - 1.
  lv_spmon  = lv_datum(6).

  lv_lines-low    = '7*'.
  lv_lines-sign   = 'I'.
  lv_lines-option = 'CP'.
  APPEND lv_lines TO lv_bwart.

  IF t_okt[] IS NOT INITIAL.
    SELECT spmon werks matnr bwart charg mblnr budat
           lgort vrsio menge
      FROM s933
      INTO TABLE lt_s933
      FOR ALL ENTRIES IN t_okt
      WHERE spmon EQ lv_spmon
        AND werks EQ p_werks
        AND matnr EQ t_okt-matnr
        AND bwart IN lv_bwart
        AND lgort NE space
        AND vrsio EQ '000'.
  ENDIF.

  SORT lt_s933 BY spmon werks matnr.
  LOOP AT lt_s933.
    gt_s933-werks = lt_s933-werks.
    gt_s933-matnr = lt_s933-matnr.
    gt_s933-menge = lt_s933-menge.
    COLLECT gt_s933.
  ENDLOOP.
ENDFORM.                    " F_GET_STOCK_OPNAME

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_STOCK_OPNAME
*&---------------------------------------------------------------------*
FORM f_hitung_stock_opname  USING    fu_matnr
                            CHANGING fc_begbal.

  READ TABLE gt_s933 WITH KEY werks = p_werks
                              matnr = fu_matnr.
  IF sy-subrc EQ 0.
    fc_begbal = fc_begbal - gt_s933-menge.
  ENDIF.
ENDFORM.                    " F_HITUNG_STOCK_OPNAME

*&---------------------------------------------------------------------*
*&      Form  F_INIT_SUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_sut .
*  IF p_incsut IS INITIAL.
*    ra_kunnr-sign = 'E'.
*    ra_kunnr-option = 'EQ'.
*    ra_kunnr-low = 'TSB8070'.
*    APPEND ra_kunnr.
*
*    ra_kunnr-low = 'TSB8071'.
*    APPEND ra_kunnr.
*    CLEAR ra_kunnr.
*
*    IF p_werks EQ '0201'.
*      ra_lgort-sign = 'E'.
*      ra_lgort-option = 'EQ'.
*      ra_lgort-low    = '1100'.
*      APPEND ra_lgort.
*      CLEAR ra_lgort.
*    ENDIF.
*  ENDIF.
ENDFORM.                    " F_INIT_SUT
