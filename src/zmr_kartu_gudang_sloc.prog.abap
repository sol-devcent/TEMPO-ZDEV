************************************************************************
*                  REPORT                                              *
*----------------------------------------------------------------------*
* ABAP Name   : ZMR_KARTU GUDANG                                       *
* Created by  : Didik Imawan                                           *
* Created on  : 28/05/2003                                             *
*----------------------------------------------------------------------*
* Description :                                                        *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
* Date    Programmer  Correction  Description                   *
*                                                                      *
************************************************************************
REPORT zmr_kartu_gudang MESSAGE-ID zm
                        LINE-SIZE  204
                        LINE-COUNT 60
                        NO STANDARD PAGE HEADING.

INCLUDE zmr_kartu_gudang_top_sloc.

SELECTION-SCREEN BEGIN OF BLOCK xbclk1 WITH FRAME TITLE text-001.
PARAMETERS:
  pa_werks LIKE t001w-werks OBLIGATORY."default '0201'.       "Plant
SELECT-OPTIONS:
  so_spmon FOR s031-spmon OBLIGATORY DEFAULT sy-datum(6),   "'200301',
  so_lgort FOR mseg-lgort,
  so_matkl FOR mara-matkl,
*      SO_MTART FOR MARA-MTART,
  so_matnr FOR mara-matnr,
  so_profl FOR mara-profl.
SELECTION-SCREEN END OF BLOCK xbclk1.

*&---------------------------------------------------------------------*
*&        AT LINE-SELECTION
*&---------------------------------------------------------------------*
AT LINE-SELECTION.
  READ CURRENT LINE FIELD VALUE: wa_itab-xblnr.

  DATA : ffield(20), fvalue(50).
  GET CURSOR FIELD ffield VALUE fvalue.
  CASE ffield.
    WHEN 'WA_ITAB-XBLNR'.
      IF wa_itab-xblnr(2) = '10'.
        SET PARAMETER ID 'VL' FIELD wa_itab-xblnr.
        CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
      ELSE.
        SET PARAMETER ID 'MBN' FIELD wa_itab-xblnr.
        SET PARAMETER ID 'MJA' FIELD wa_itab-mjahr.
        CALL TRANSACTION 'MB03' AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.

*&---------------------------------------------------------------------*
*&      START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  va_month = sy-datum+4(2) - 1.
  va_spmon = sy-datum(6).
  ra_spmon-low = so_spmon-low.
  ra_spmon-high = va_spmon.
  ra_spmon-sign = 'I'.
  ra_spmon-option = 'BT'.
  APPEND ra_spmon.

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

  zebra = 0.

  PERFORM f_profl.
  PERFORM f_get_data.
  PERFORM f_proses_marc.
  PERFORM f_proses_data.
  PERFORM f_cetak_data.

TOP-OF-PAGE.
  PERFORM f_cetak_header.

*&---------------------------------------------------------------------*
*&      Form  f_profl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_profl.
  SELECT *
    FROM mara AS a
              JOIN makt AS c ON a~matnr EQ c~matnr AND
                            c~spras EQ sy-langu
    INTO CORRESPONDING FIELDS OF TABLE ta_profl
    WHERE a~matnr IN so_matnr AND
          matkl IN so_matkl AND
          profl IN so_profl.
ENDFORM.                    " f_profl

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA : pa_spmon LIKE s039-spmon.

* Internal table untuk data stock movement material
  DATA  BEGIN OF t_movement OCCURS 0.
  DATA:    matnr   LIKE s031-matnr,
           mzubb   LIKE s031-mzubb,
           magbb   LIKE s031-magbb.
  DATA  END   OF t_movement.

  DATA  BEGIN OF t_mkpf OCCURS 0.
  DATA:    mblnr   LIKE mkpf-mblnr,
           mjahr   LIKE mkpf-mjahr,
           budat   LIKE mkpf-budat,
           xblnr   LIKE mkpf-xblnr.
  DATA  END   OF t_mkpf.

  RANGES ra_mblnr FOR mkpf-mblnr.

  IF ta_profl[] IS NOT INITIAL.
*    Select mblnr mjahr budat xblnr from mkpf
*    into table t_mkpf
*    where budat GE TA_DATE-LOW    AND
*          budat LE TA_DATE-HIGH.

    SORT ta_profl BY matnr.
*SORT t_mkpf by mblnr mjahr.
*    Loop at  t_mkpf.
*      ra_mblnr-sign   = 'I'.
*      ra_mblnr-option = 'EQ'.
*      ra_mblnr-low = t_mkpf-mblnr.
*      append ra_mblnr.
*    Endloop.

    SELECT a~werks a~matnr a~menge a~shkzg a~mblnr a~kunnr a~lifnr a~lgort
           a~bwart a~gjahr a~sgtxt a~smbln a~ebeln a~ebelp a~umwrk a~gsber
           a~charg a~zeile a~vfdat
*           B~MTART B~MEINS
*           C~MAKTX
           d~budat d~xblnr
      FROM mseg AS a
*                    JOIN MARA AS B ON A~MATNR EQ B~MATNR
*                    JOIN MAKT AS C ON A~MATNR EQ C~MATNR and
*                                      c~spras eq sy-langu
                     JOIN mkpf AS d ON a~mblnr EQ d~mblnr AND
                                       a~mjahr EQ d~mjahr
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      FOR ALL ENTRIES IN ta_profl
      WHERE a~werks EQ pa_werks       AND
            a~matnr EQ ta_profl-matnr AND
            a~bwart NE '561'          AND
            a~lgort NE space          AND
            a~lgort IN so_lgort       AND
*            A~MBLNR IN ra_mblnr.
            d~budat GE ta_date-low    AND
            d~budat LE ta_date-high.
*            B~MATKL IN SO_MATKL.

    LOOP AT i_itab INTO wa_itab.
*  READ TABLE t_mkpf with key mblnr = wa_itab-mblnr
*  BINARY SEARCH.
*  IF SY-SUBRC = 0.
*  WA_ITAB-budat = t_mkpf-budat.
*  WA_ITAB-xblnr = t_mkpf-xblnr.
*  ENDIF.

      READ TABLE ta_profl WITH KEY matnr = wa_itab-mblnr
      BINARY SEARCH.
      IF sy-subrc = 0.
        wa_itab-meins = ta_profl-meins.
        wa_itab-maktx = ta_profl-maktx.
      ENDIF.

      MODIFY i_itab FROM wa_itab.
    ENDLOOP.

*-------------*
* Logic Mundur
*-------------*
* Baca ending saat ini dari S032
    SELECT matnr SUM( mbwbest ) FROM s032
    INTO TABLE ta_stock
    WHERE ssour = ''      AND
          vrsio = '000'   AND
          werks = pa_werks AND
          lgort NE space  AND
          lgort IN so_lgort AND
*        lgort ne '1100' and
          matnr IN so_matnr
    GROUP BY matnr.

* Baca movement qty dari bulan input sampai saat ini
    SELECT matnr SUM( mzubb ) SUM( magbb ) FROM s031
    INTO TABLE t_movement
    WHERE ssour = ''         AND
          vrsio = '000'      AND
          spmon GE so_spmon-low   AND
          sptag = '00000000' AND
          spwoc = '000000'   AND
          spbup = '000000'   AND
          werks = pa_werks    AND
          lgort NE space     AND
          lgort IN so_lgort  AND
*        lgort ne '1100'    and
          matnr IN so_matnr
    GROUP BY matnr.

* Hitung ending stock
    SORT ta_stock BY matnr.
    LOOP AT ta_stock.
      CLEAR t_movement.
*{   INSERT         P01K910323                                        1
      "Start SOH: Shell SCI Adjustment 20240222 RZL
      SORT t_movement by matnr.
      "End SOH: Shell SCI Adjustment 20240222 RZL
*}   INSERT
      READ TABLE t_movement WITH KEY matnr = ta_stock-matnr
                                     BINARY SEARCH.
      ta_stock-beg_st = ta_stock-mbwbest -
                       t_movement-mzubb + t_movement-magbb.
      MODIFY ta_stock.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_proses_marc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_marc.
  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab.
    SELECT SINGLE lvorm
      FROM marc
      INTO va_lvorm
      WHERE matnr EQ wa_itab-matnr
        AND werks EQ pa_werks.

    IF va_lvorm EQ 'X'.
      DELETE i_itab WHERE matnr EQ wa_itab-matnr.
    ENDIF.
    CLEAR: wa_itab.
  ENDLOOP.

  LOOP AT ta_stock.
    SELECT SINGLE lvorm
      FROM marc
      INTO va_lvorm
      WHERE matnr EQ ta_stock-matnr.

    IF va_lvorm EQ 'X'.
      DELETE ta_stock WHERE matnr EQ ta_stock-matnr.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " f_proses_marc

*&---------------------------------------------------------------------*
*&      Form  f_proses_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_data.

  IF so_lgort EQ space.
    DELETE i_itab WHERE bwart EQ '311' OR
                        bwart EQ '312' OR
                        bwart EQ '321' OR
                        bwart EQ '322' OR
                        bwart EQ '343' OR
                        bwart EQ '344'.
  ENDIF.

  CLEAR: wa_itab.
  SORT i_itab BY matnr.
  LOOP AT i_itab INTO wa_itab.
    SELECT SINGLE maktx
      FROM makt
      INTO wa_itab-maktx
      WHERE matnr EQ wa_itab-matnr AND
            spras EQ 'EN'.

    SELECT SINGLE btext
      FROM t156t
      INTO wa_itab-btext
      WHERE bwart EQ wa_itab-bwart AND
            spras EQ 'EN'.

    IF wa_itab-shkzg EQ 'S'.
      MOVE wa_itab-menge TO wa_itab-masuk.
      wa_itab-charg_m = wa_itab-charg.
      wa_itab-vfdat_m = wa_itab-vfdat.
      CLEAR: wa_itab-charg_k, wa_itab-vfdat_k.

      IF wa_itab-bwart NE '913'.
        SELECT SINGLE lifnr reswk
          FROM ekko
          INTO (wa_itab-lifnr, wa_itab-reswk)
          WHERE ebeln EQ wa_itab-ebeln.

        IF sy-subrc EQ 0.
          SELECT SINGLE belnr
            FROM ekbe
            INTO wa_itab-xblnr
            WHERE ebeln EQ wa_itab-ebeln AND
*                    EBELP EQ WA_ITAB-EBELP AND
                  bewtp EQ 'E'           AND
                  bwart EQ wa_itab-bwart AND
                  belnr EQ wa_itab-mblnr.
          IF sy-subrc NE 0.
            MOVE wa_itab-mblnr TO wa_itab-xblnr.
          ENDIF.
        ELSE.
          IF wa_itab-bwart NE '655' AND
             wa_itab-bwart NE '653'.
            MOVE wa_itab-mblnr TO wa_itab-xblnr.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      MOVE wa_itab-menge TO wa_itab-keluar.
      wa_itab-charg_k = wa_itab-charg.
      wa_itab-vfdat_k = wa_itab-vfdat.
      CLEAR: wa_itab-charg_m, wa_itab-vfdat_m.
    ENDIF.

    IF wa_itab-kunnr NE space.
      SELECT SINGLE name1 name3
        FROM kna1
        INTO (wa_itab-name2, wa_itab-name3)
        WHERE kunnr EQ wa_itab-kunnr.

      IF wa_itab-werks = '0200'.
        CONCATENATE wa_itab-name2 wa_itab-name3
        INTO wa_itab-name2
        SEPARATED BY space.
      ENDIF.
    ENDIF.

    IF wa_itab-lifnr NE space.
      SELECT SINGLE name1
        FROM lfa1
        INTO wa_itab-name2
        WHERE lifnr EQ wa_itab-lifnr.
      MOVE wa_itab-lifnr TO wa_itab-kunnr.
    ENDIF.

    IF wa_itab-reswk EQ '0200'.
      SELECT SINGLE lgobe
        FROM t001l
        INTO wa_itab-name2
        WHERE werks EQ wa_itab-reswk AND
              lgort EQ wa_itab-lgort.
      MOVE wa_itab-reswk TO wa_itab-kunnr.
    ENDIF.

    IF wa_itab-kunnr EQ space.
      SELECT SINGLE werks
        FROM mseg
        INTO wa_itab-kunnr
        WHERE mblnr EQ wa_itab-mblnr AND
              matnr EQ wa_itab-matnr AND
              umwrk EQ pa_werks.
      IF sy-subrc EQ '0'.
        SELECT SINGLE name1
          FROM t001w
          INTO wa_itab-name2
          WHERE werks EQ wa_itab-kunnr.
      ENDIF.
    ENDIF.

    IF wa_itab-xblnr EQ space.
      MOVE wa_itab-mblnr TO wa_itab-xblnr.
    ENDIF.

    MODIFY i_itab FROM wa_itab.
    MOVE-CORRESPONDING wa_itab TO wa_itab2.
    APPEND wa_itab2 TO i_itab2.
    CLEAR: wa_itab.
  ENDLOOP.

*  CLEAR: WA_ITAB1.
*  SORT I_ITAB1 BY MATNR SPMON.
*  LOOP AT I_ITAB1 INTO WA_ITAB1.
*      MOVE WA_ITAB1-WERKS TO VA_WERKS.
*      ADD WA_ITAB1-MZUBB TO WA_BEGIN-BEGSTC.
*      WA_BEGIN-BEGSTC = WA_BEGIN-BEGSTC - WA_ITAB1-MAGBB.
*      AT END OF MATNR.
*        MOVE WA_ITAB1-MATNR TO WA_BEGIN-MATNR.
*        MOVE VA_WERKS       TO WA_BEGIN-WERKS.
*        APPEND WA_BEGIN TO I_BEGIN.
*        CLEAR: WA_BEGIN-BEGSTC.
*      ENDAT.
*    CLEAR: WA_ITAB1.
*  ENDLOOP.

  SORT ta_stock BY matnr.
  LOOP AT ta_stock.
    MOVE pa_werks TO va_werks.
    ADD ta_stock-beg_st TO wa_begin-begstc.
    AT END OF matnr.
      MOVE ta_stock-matnr TO wa_begin-matnr.
      MOVE va_werks       TO wa_begin-werks.
      APPEND wa_begin TO i_begin.
      CLEAR: wa_begin-begstc.
    ENDAT.
  ENDLOOP.

  CLEAR: wa_itab.
  SORT i_itab BY bwart xblnr.
  LOOP AT i_itab INTO wa_itab.
    CASE wa_itab-bwart.
      WHEN '102'.
        DELETE i_itab WHERE mblnr EQ wa_itab-smbln AND
                            matnr EQ wa_itab-matnr AND
                            bwart EQ '101'.
        IF sy-subrc EQ '0'.
          DELETE i_itab WHERE mblnr EQ wa_itab-mblnr AND
                              matnr EQ wa_itab-matnr AND
                              bwart EQ '102'.
        ENDIF.
        CONTINUE.

      WHEN '303'.
        DELETE i_itab WHERE mblnr EQ wa_itab-smbln AND
                            matnr EQ wa_itab-matnr AND
                            bwart EQ '305'.
        IF sy-subrc EQ '0'.
          DELETE i_itab WHERE mblnr EQ wa_itab-mblnr AND
                              matnr EQ wa_itab-matnr AND
                              bwart EQ '303'.
        ENDIF.
        CONTINUE.

      WHEN '313'.
        DELETE i_itab WHERE mblnr EQ wa_itab-smbln AND
                            matnr EQ wa_itab-matnr AND
                            bwart EQ '315'.
        IF sy-subrc EQ '0'.
          DELETE i_itab WHERE mblnr EQ wa_itab-mblnr AND
                              matnr EQ wa_itab-matnr AND
                              bwart EQ '313'.
        ENDIF.
        CONTINUE.

      WHEN '304'.
        DELETE i_itab WHERE mblnr EQ wa_itab-smbln AND
                            matnr EQ wa_itab-matnr AND
                            bwart EQ '303'.
        IF sy-subrc EQ '0'.
          DELETE i_itab WHERE mblnr EQ wa_itab-mblnr AND
                              matnr EQ wa_itab-matnr AND
                              bwart EQ '304'.
        ENDIF.
        CONTINUE.

      WHEN '306'.
        DELETE i_itab WHERE mblnr EQ wa_itab-smbln AND
                            matnr EQ wa_itab-matnr AND
                            bwart EQ '305'.
        IF sy-subrc EQ '0'.
          DELETE i_itab WHERE mblnr EQ wa_itab-mblnr AND
                              matnr EQ wa_itab-matnr AND
                              bwart EQ '306'.
        ENDIF.
        CONTINUE.

      WHEN '311'.
        IF wa_itab-xblnr EQ va_xblnr AND
           wa_itab-lgort EQ va_lgort AND
           wa_itab-charg EQ va_charg AND
           wa_itab-shkzg EQ va_shkzg AND
           wa_itab-menge EQ va_menge.
          DELETE i_itab WHERE xblnr EQ va_xblnr AND
                              lgort EQ va_lgort AND
                              charg EQ va_charg AND
                              shkzg EQ va_shkzg AND
                              menge EQ va_menge AND
                              bwart EQ '311'.
        ENDIF.
        CONTINUE.

      WHEN '312'.
        IF wa_itab-xblnr EQ va_xblnr AND
           wa_itab-lgort EQ va_lgort.
          DELETE i_itab WHERE xblnr EQ va_xblnr AND
                              lgort EQ va_lgort AND
                              bwart EQ '312'.
        ENDIF.
        CONTINUE.

      WHEN '321'.
        IF wa_itab-xblnr EQ va_xblnr AND
           wa_itab-lgort EQ va_lgort.
          DELETE i_itab WHERE xblnr EQ va_xblnr AND
                              lgort EQ va_lgort AND
                              bwart EQ '321'.
        ENDIF.
        CONTINUE.

      WHEN '322'.
        IF wa_itab-xblnr EQ va_xblnr AND
           wa_itab-lgort EQ va_lgort.
          DELETE i_itab WHERE xblnr EQ va_xblnr AND
                              lgort EQ va_lgort AND
                              bwart EQ '322'.
        ENDIF.
        CONTINUE.

      WHEN '343'.
        IF wa_itab-xblnr EQ va_xblnr AND
           wa_itab-lgort EQ va_lgort.
          DELETE i_itab WHERE xblnr EQ va_xblnr AND
                              lgort EQ va_lgort AND
                              bwart EQ '343'.
        ENDIF.
        CONTINUE.

      WHEN '344'.
        IF wa_itab-xblnr EQ va_xblnr AND
           wa_itab-lgort EQ va_lgort.
          DELETE i_itab WHERE xblnr EQ va_xblnr AND
                              lgort EQ va_lgort AND
                              bwart EQ '344'.
        ENDIF.
        CONTINUE.

      WHEN '556'.
        DELETE i_itab WHERE mblnr EQ wa_itab-smbln AND
                            matnr EQ wa_itab-matnr AND
                            bwart EQ '555'.
        IF sy-subrc EQ '0'.
          DELETE i_itab WHERE mblnr EQ wa_itab-mblnr AND
                              matnr EQ wa_itab-matnr AND
                              bwart EQ '556'.
        ENDIF.
        CONTINUE.

      WHEN '602'.
        DELETE i_itab WHERE mblnr EQ wa_itab-smbln AND
                            matnr EQ wa_itab-matnr AND
                            bwart EQ '601'.
        IF sy-subrc EQ '0'.
          DELETE i_itab WHERE mblnr EQ wa_itab-mblnr AND
                              matnr EQ wa_itab-matnr AND
                              bwart EQ '602'.
        ELSE.
          DELETE i_itab WHERE mblnr EQ wa_itab-mblnr AND
                              matnr EQ wa_itab-matnr AND
                              bwart EQ '602'.
        ENDIF.
        CONTINUE.

      WHEN '642'.
        DELETE i_itab WHERE mblnr EQ wa_itab-smbln AND
                            matnr EQ wa_itab-matnr AND
                            bwart EQ '641'.
        IF sy-subrc EQ '0'.
          DELETE i_itab WHERE mblnr EQ wa_itab-mblnr AND
                              matnr EQ wa_itab-matnr AND
                              bwart EQ '642'.
        ENDIF.
        CONTINUE.

      WHEN '654'.
        DELETE i_itab WHERE mblnr EQ wa_itab-smbln AND
                            matnr EQ wa_itab-matnr AND
                            bwart EQ '653'.
        IF sy-subrc EQ '0'.
          DELETE i_itab WHERE mblnr EQ wa_itab-mblnr AND
                              matnr EQ wa_itab-matnr AND
                              bwart EQ '654'.
        ENDIF.
        CONTINUE.

      WHEN '656'.
        DELETE i_itab WHERE mblnr EQ wa_itab-smbln AND
                            matnr EQ wa_itab-matnr AND
                            bwart EQ '655'.
        IF sy-subrc EQ '0'.
          DELETE i_itab WHERE mblnr EQ wa_itab-mblnr AND
                              matnr EQ wa_itab-matnr AND
                              bwart EQ '656'.
        ENDIF.
        CONTINUE.

      WHEN '902'.
        DELETE i_itab WHERE mblnr EQ wa_itab-smbln AND
                            matnr EQ wa_itab-matnr AND
                            bwart EQ '901'.
        IF sy-subrc EQ '0'.
          DELETE i_itab WHERE mblnr EQ wa_itab-mblnr AND
                              matnr EQ wa_itab-matnr AND
                              bwart EQ '902'.
        ENDIF.
        CONTINUE.

      WHEN '908'.
        DELETE i_itab WHERE mblnr EQ wa_itab-smbln AND
                            matnr EQ wa_itab-matnr AND
                            bwart EQ '907'.
        IF sy-subrc EQ '0'.
          DELETE i_itab WHERE mblnr EQ wa_itab-mblnr AND
                              matnr EQ wa_itab-matnr AND
                              bwart EQ '908'.
        ENDIF.
        CONTINUE.

      WHEN '919'. "OR '920' OR '921' OR '922'.
        DELETE i_itab.
        CONTINUE.

    ENDCASE.

    IF wa_itab-bwart EQ '311' OR
       wa_itab-bwart EQ '312'.
      MOVE wa_itab-xblnr TO va_xblnr.
      MOVE wa_itab-lgort TO va_lgort.
      MOVE wa_itab-charg TO va_charg.
      MOVE wa_itab-shkzg TO va_shkzg.
      MOVE wa_itab-menge TO va_menge.
    ENDIF.

    IF wa_itab-kunnr EQ space.
      SELECT SINGLE name1
        FROM t001w
        INTO wa_itab-name2
        WHERE werks EQ wa_itab-gsber.
      MOVE wa_itab-gsber TO wa_itab-kunnr.
      MODIFY i_itab FROM wa_itab.
    ENDIF.

    CLEAR: wa_itab.
  ENDLOOP.

  DELETE i_itab WHERE bwart EQ '303' AND
                      shkzg EQ 'S'.

  DELETE i_itab WHERE bwart EQ '313' AND
                      shkzg EQ 'S'.
ENDFORM.                    " f_proses_data

*&---------------------------------------------------------------------*
*&      Form  f_cetak_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cetak_data.
  CLEAR: wa_itab.
  SORT i_itab BY matnr budat mblnr.
  LOOP AT i_itab INTO wa_itab.

    MOVE wa_itab-maktx TO va_maktx.
    MOVE wa_itab-meins TO va_meins.
    MOVE wa_itab-werks TO va_werks.
    MOVE wa_itab-kunnr TO va_kunnr.

    IF wa_itab-bwart NE '561'.
      ADD  wa_itab-masuk TO total_masuk.
      ADD  wa_itab-keluar TO total_keluar.
    ENDIF.

    AT NEW matnr.
      CLEAR: wa_begin.
      LOOP AT i_begin INTO wa_begin
        WHERE matnr EQ wa_itab-matnr AND
              werks EQ va_werks.
        MOVE wa_begin-begstc TO va_begstc.
        CLEAR: wa_begin.
      ENDLOOP.

      IF sy-subrc NE '0'.
        MOVE 0 TO va_begstc.
      ENDIF.

      DELETE i_begin WHERE matnr EQ wa_itab-matnr AND
                           werks EQ va_werks.

      CONCATENATE wa_itab-matnr '-' va_maktx INTO va_maktx
        SEPARATED BY space.
      WRITE: /    'Material : ', va_maktx,
             /    'UM       : ', va_meins.
      ULINE.
      FORMAT COLOR 1.
* header line 1
      WRITE: /     sy-vline, (9) space NO-GAP,
                   sy-vline NO-GAP, (4) space NO-GAP,
                   sy-vline, (3) space,
                   sy-vline, (12) space,
               44  sy-vline, space NO-GAP,
               59  sy-vline, (9) space NO-GAP,
                   sy-vline NO-GAP, (10) space NO-GAP,
                   sy-vline, (30) space,
               118  sy-vline, (40) 'Receiving' CENTERED,
                    sy-vline, (40) 'Issuing' CENTERED,
                    sy-vline.
* header line 2
      WRITE: /    sy-vline, 'Pstg date' NO-GAP,
                  sy-vline NO-GAP, 'SLoc' NO-GAP,
                  sy-vline, 'MvT',
                  sy-vline, 'MvT Description',
              44  sy-vline, 'Doc. Number' NO-GAP,
              59  sy-vline, 'DN Number' NO-GAP,
                  sy-vline NO-GAP, 'Cust. Code' NO-GAP,
                  sy-vline, 'From / To',
              118 sy-vline NO-GAP, (42) sy-uline NO-GAP,
                  sy-vline NO-GAP, (42) sy-uline NO-GAP,
                  sy-vline.
* header line 3
      WRITE: /    sy-vline, (9) space NO-GAP,
                  sy-vline NO-GAP, (4) space NO-GAP,
                  sy-vline, (3) space,
                  sy-vline, (12) space,
              44  sy-vline, space NO-GAP,
              59  sy-vline, (9) space NO-GAP,
                  sy-vline NO-GAP, (10) space NO-GAP,
                  sy-vline, (30) space,
              118  sy-vline, (18) 'Quantity' CENTERED,
                   sy-vline NO-GAP, (10) 'Batch' CENTERED NO-GAP,
                   sy-vline NO-GAP, (10) 'ExpDate' CENTERED NO-GAP,
                   sy-vline, (18) 'Quantity' CENTERED,
                   sy-vline NO-GAP, (10) 'Batch' CENTERED NO-GAP,
                   sy-vline NO-GAP, (10) 'ExpDate' CENTERED NO-GAP,
                   sy-vline.
      ULINE.
      FORMAT INTENSIFIED ON.
      FORMAT COLOR 3.
      WRITE: /    sy-vline, 'Beginning Stock',
              184 va_begstc NO-GAP DECIMALS 2,
                  sy-vline.
      ULINE.
      FORMAT COLOR OFF.
      FORMAT INTENSIFIED OFF.
      zebra = 0.
    ENDAT.

    IF wa_itab-bwart NE '561'.
      IF zebra = 0.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR 2.
        zebra = 1.
      ELSE.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR 1.
        zebra = 0.
      ENDIF.

      WRITE: /   sy-vline NO-GAP, wa_itab-budat NO-GAP,
                 sy-vline NO-GAP, wa_itab-lgort NO-GAP,
                 sy-vline, wa_itab-bwart,
                 sy-vline NO-GAP, wa_itab-btext NO-GAP,
                 sy-vline NO-GAP, (14) wa_itab-xblnr HOTSPOT NO-GAP,
                 sy-vline NO-GAP, wa_itab-ebeln NO-GAP,
                 sy-vline NO-GAP, va_kunnr NO-GAP,
                 sy-vline NO-GAP, (36) wa_itab-name2 NO-GAP,
                 sy-vline NO-GAP, (20) wa_itab-masuk NO-GAP DECIMALS 2,
                 sy-vline NO-GAP, (10) wa_itab-charg_m NO-GAP.
      IF wa_itab-vfdat_m IS INITIAL.
        WRITE: sy-vline NO-GAP, (10) space NO-GAP.
      ELSE.
        WRITE: sy-vline NO-GAP, (10) wa_itab-vfdat_m NO-GAP.
      ENDIF.
      WRITE:     sy-vline NO-GAP, (20) wa_itab-keluar NO-GAP DECIMALS 2,
                 sy-vline NO-GAP, (10) wa_itab-charg_k NO-GAP.
      IF wa_itab-vfdat_k IS INITIAL.
        WRITE: sy-vline NO-GAP, (10) space NO-GAP.
      ELSE.
        WRITE: sy-vline NO-GAP, (10) wa_itab-vfdat_k NO-GAP.
      ENDIF.
      WRITE:     sy-vline.

      HIDE: wa_itab-mjahr.
    ENDIF.

    AT END OF matnr.
      va_endstc = va_begstc + total_masuk - total_keluar.
      FORMAT INTENSIFIED ON.
      FORMAT COLOR 3.
      ULINE.
      WRITE: /    sy-vline, 'Total',
              118 sy-vline NO-GAP, (20) total_masuk  NO-GAP DECIMALS 2,
                  sy-vline NO-GAP, (10) space NO-GAP,
                  sy-vline NO-GAP, (10) space NO-GAP,
                  sy-vline NO-GAP, (20) total_keluar NO-GAP DECIMALS 2,
                  sy-vline NO-GAP, (10) space NO-GAP,
                  sy-vline NO-GAP, (10) space NO-GAP,
                  sy-vline.
      ULINE.
      WRITE: /    sy-vline, 'Ending Stock',
              184 va_endstc NO-GAP DECIMALS 2,
                  sy-vline.
      ULINE.
      SKIP 1.
      CLEAR: total_masuk, total_keluar.
      FORMAT COLOR OFF.
    ENDAT.
    CLEAR: wa_itab.
  ENDLOOP.

* Only Beginning Balance
  CLEAR: wa_begin.
  LOOP AT i_begin INTO wa_begin.
    SELECT SINGLE maktx
      FROM makt
      INTO va_maktx
      WHERE matnr EQ wa_begin-matnr.

    SELECT SINGLE meins
      FROM mara
      INTO va_meins
      WHERE matnr EQ wa_begin-matnr.

    CONCATENATE wa_begin-matnr '-' va_maktx INTO va_maktx
      SEPARATED BY space.
    WRITE: /    'Material : ', va_maktx,
           /    'UM       : ', va_meins.
    ULINE.
    FORMAT COLOR 1.
* header line 1
    WRITE: /     sy-vline, (9) space NO-GAP,
                 sy-vline NO-GAP, (4) space NO-GAP,
                 sy-vline, (3) space,
                 sy-vline, (12) space,
             44  sy-vline, space NO-GAP,
             59  sy-vline, (9) space NO-GAP,
                 sy-vline NO-GAP, (10) space NO-GAP,
                 sy-vline, (30) space,
             118  sy-vline, (40) 'Receiving' CENTERED,
                  sy-vline, (40) 'Issuing' CENTERED,
                  sy-vline.
* header line 2
    WRITE: /    sy-vline, 'Pstg date' NO-GAP,
                sy-vline NO-GAP, 'SLoc' NO-GAP,
                sy-vline, 'MvT',
                sy-vline, 'MvT Description',
            44  sy-vline, 'Doc. Number' NO-GAP,
            59  sy-vline, 'DN Number' NO-GAP,
                sy-vline NO-GAP, 'Cust. Code' NO-GAP,
                sy-vline, 'From / To',
            118 sy-vline NO-GAP, (42) sy-uline NO-GAP,
                sy-vline NO-GAP, (42) sy-uline NO-GAP,
                sy-vline.
* header line 3
    WRITE: /    sy-vline, (9) space NO-GAP,
                sy-vline NO-GAP, (4) space NO-GAP,
                sy-vline, (3) space,
                sy-vline, (12) space,
            44  sy-vline, space NO-GAP,
            59  sy-vline, (9) space NO-GAP,
                sy-vline NO-GAP, (10) space NO-GAP,
                sy-vline, (30) space,
            118  sy-vline, (18) 'Quantity' CENTERED,
                 sy-vline NO-GAP, (10) 'Batch' CENTERED NO-GAP,
                 sy-vline NO-GAP, (10) 'ExpDate' CENTERED NO-GAP,
                 sy-vline, (18) 'Quantity' CENTERED,
                 sy-vline NO-GAP, (10) 'Batch' CENTERED NO-GAP,
                 sy-vline NO-GAP, (10) 'ExpDate' CENTERED NO-GAP,
                 sy-vline.
    ULINE.
    FORMAT INTENSIFIED ON.
    FORMAT COLOR 3.
    WRITE: /    sy-vline, 'Beginning Stock',
            184 wa_begin-begstc NO-GAP DECIMALS 2,
                sy-vline.
    ULINE.
    FORMAT COLOR OFF.
    FORMAT INTENSIFIED OFF.
    zebra = 0.
    va_endstc = wa_begin-begstc.
    total_masuk = 0.
    total_keluar = 0.
    FORMAT INTENSIFIED ON.
    FORMAT COLOR 3.
    ULINE.
    WRITE: /    sy-vline, 'Total',
            118 sy-vline NO-GAP, (20) total_masuk  NO-GAP DECIMALS 2,
                sy-vline NO-GAP, (10) space NO-GAP,
                sy-vline NO-GAP, (10) space NO-GAP,
                sy-vline NO-GAP, (20) total_keluar NO-GAP DECIMALS 2,
                sy-vline NO-GAP, (10) space NO-GAP,
                sy-vline NO-GAP, (10) space NO-GAP,
                sy-vline.
    ULINE.
    WRITE: /    sy-vline, 'Ending Stock',
            184 va_endstc NO-GAP DECIMALS 2,
                sy-vline.
    ULINE.
    SKIP 1.
    CLEAR: total_masuk, total_keluar.
    FORMAT COLOR OFF.
    CLEAR: wa_begin.
  ENDLOOP.
ENDFORM.                    " f_cetak_data

*&---------------------------------------------------------------------*
*&      Form  f_cetak_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cetak_header.
  SELECT SINGLE name1
    FROM t001w
    INTO va_name1
    WHERE werks EQ pa_werks.

  MOVE so_spmon-low+4(2) TO bulan.
  PERFORM bulan.

  WRITE: /    'KARTU GUDANG',
         /    'Plant            : ', pa_werks, '-', va_name1,
         /    'Period           : ', va_period.
  SKIP 1.
ENDFORM.                    " f_cetak_header

*&---------------------------------------------------------------------*
*&      Form  BULAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bulan.
  CASE bulan.
    WHEN '01'.
      CONCATENATE 'January' so_spmon-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '02'.
      CONCATENATE 'February' so_spmon-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '03'.
      CONCATENATE 'March' so_spmon-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '04'.
      CONCATENATE 'April' so_spmon-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '05'.
      CONCATENATE 'May' so_spmon-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '06'.
      CONCATENATE 'June' so_spmon-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '07'.
      CONCATENATE 'July' so_spmon-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '08'.
      CONCATENATE 'August' so_spmon-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '09'.
      CONCATENATE 'September' so_spmon-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '10'.
      CONCATENATE 'October' so_spmon-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '11'.
      CONCATENATE 'November' so_spmon-low+0(4) INTO va_period
        SEPARATED BY space.
    WHEN '12'.
      CONCATENATE 'December' so_spmon-low+0(4) INTO va_period
        SEPARATED BY space.
  ENDCASE.
ENDFORM.                    " BULAN
