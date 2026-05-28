* 09/07/2004
REPORT zf_asset_alv NO STANDARD PAGE HEADING
                    LINE-SIZE 255.

TYPE-POOLS: slis.

TABLES: anla, anlb, anlc, anlz.

TYPES: BEGIN OF ta_itab,
         bukrs  LIKE anlc-bukrs,
         anln1  LIKE anlc-anln1,
         anln2  LIKE anlc-anln2,
         gjahr  LIKE anlc-gjahr,
         afabe  LIKE anlc-afabe,
         afblpe LIKE anlc-afblpe,
         kansw  LIKE anlc-kansw,
         knafa  LIKE anlc-knafa,
         nafap  LIKE anlc-nafap,
         nafag  LIKE anlc-nafag,
         answl  LIKE anlc-answl,
         nafav  LIKE anlc-nafav,
         nafal  LIKE anlc-nafal,
         ksafa  LIKE anlc-ksafa,
         safap  LIKE anlc-safap,
         safav  LIKE anlc-safav,
         safal  LIKE anlc-safal,
         afabg  LIKE anlb-afabg,
         ndjar  LIKE anlb-ndjar,
         ndper  LIKE anlb-ndper,
         ndabj  LIKE anlc-ndabj,
         ndabp  LIKE anlc-ndabp,
         afasl  LIKE anlb-afasl,
         anlkl  LIKE anla-anlkl,
         zujhr  LIKE anla-zujhr,
         zuper  LIKE anla-zuper,
         zugdt  LIKE anla-zugdt,
         aktiv  LIKE anla-aktiv,
         deakt  LIKE anla-deakt,
         lifnr  LIKE anla-lifnr,
         invnr  LIKE anla-invnr,
         vbund  LIKE anla-vbund,
         txt50  LIKE anla-txt50,
         txa50  LIKE anla-txa50,
         sernr  LIKE anla-sernr,
         ord41  LIKE anla-ord41,
         menge  LIKE anla-menge,
         meins  LIKE anla-meins,
         eaufn  LIKE anla-eaufn,
         ord42  LIKE anla-ord42,
         aibn1  LIKE anla-aibn1,
         aibn2  LIKE anla-aibn2,
         kostl  LIKE anlz-kostl,
         gsber  LIKE anlz-gsber,
         caufn  LIKE anlz-caufn,
       END OF ta_itab.


***** Tambahan Sukardi untuk dipakai untuk
***** perhitungan NAFAG (Sudah Posting)
TYPES: BEGIN OF t_anlp,
         bukrs  LIKE anlp-bukrs,
         gjahr  LIKE anlp-gjahr,
         anln1  LIKE anlp-anln1,
         anln2  LIKE anlp-anln2,
         afaber LIKE anlp-afaber,
         nafap  LIKE anlp-nafap,
         nafag  LIKE anlp-nafag,
         nafaz  LIKE anlp-nafaz,
       END OF  t_anlp.

DATA: i_anlp   TYPE t_anlp OCCURS 0,
      wa_anlp  TYPE t_anlp,
      i_anlp1  TYPE t_anlp OCCURS 0,
      wa_anlp1 TYPE t_anlp.

****************** End Tambahan Sukardi

DATA: BEGIN OF i_out OCCURS 0,
        bukrs    LIKE anlc-bukrs,
* display
        anln1    LIKE anlc-anln1,
        anln2    LIKE anlc-anln2,
        txt50    LIKE anla-txt50,
        txa50    LIKE anla-txa50,
        per01(8),
        acquv    TYPE p DECIMALS 0,
        perio(5),
        month(5),
        acdep    TYPE p DECIMALS 0,
        nafap    TYPE p DECIMALS 0,
        nafag    TYPE p DECIMALS 0,
        bookv    TYPE p DECIMALS 0,
* hidden
        gjahr    LIKE anlc-gjahr,
        afabe    LIKE anlc-afabe,
        kansw    LIKE anlc-kansw,
        knafa    TYPE p DECIMALS 0,
        answl    LIKE anlc-answl,
        nafav    LIKE anlc-nafav,
        nafal    LIKE anlc-nafal,
        ksafa    LIKE anlc-ksafa,
        safap    LIKE anlc-safap,
        safav    LIKE anlc-safav,
        safal    LIKE anlc-safal,
        kostl    LIKE anlz-kostl,
        gsber    LIKE anlz-gsber,
        afabg    LIKE anlb-afabg,
        ndjar    LIKE anlb-ndjar,
        ndper    LIKE anlb-ndper,
        afasl    LIKE anlb-afasl,
        anlkl    LIKE anla-anlkl,
        zugdt    LIKE anla-zugdt,
        aktiv    LIKE anla-aktiv,
        deakt    LIKE anla-deakt,
        lifnr    LIKE anla-lifnr,
        invnr    LIKE anla-invnr,
        vbund    LIKE anla-vbund,
        sernr    LIKE anla-sernr,
        ord41    LIKE anla-ord41,
        menge    LIKE anla-menge,
        meins    LIKE anla-meins,
        bwasl    LIKE anep-bwasl,
        jan      LIKE anlp-nafaz,
        feb      LIKE anlp-nafaz,
        mar      LIKE anlp-nafaz,
        apr      LIKE anlp-nafaz,
        mei      LIKE anlp-nafaz,
        jun      LIKE anlp-nafaz,
        jul      LIKE anlp-nafaz,
        aug      LIKE anlp-nafaz,
        sep      LIKE anlp-nafaz,
        okt      LIKE anlp-nafaz,
        nov      LIKE anlp-nafaz,
        des      LIKE anlp-nafaz,
        eaufn    LIKE anla-eaufn,
        ord42    LIKE anla-ord42,
        caufn    LIKE anlz-caufn,
        aibn1    LIKE anla-aibn1,
        aibn2    LIKE anla-aibn2,
        name1    LIKE lfa1-name1,
      END OF i_out.

TYPES: BEGIN OF ta_anep,
         bukrs LIKE anep-bukrs,
         anln1 LIKE anep-anln1,
         anln2 LIKE anep-anln2,
         gjahr LIKE anep-gjahr,
         afabe LIKE anep-afabe,
         bwasl LIKE anep-bwasl,
         bzdat LIKE anep-bzdat,
         anbtr LIKE anep-anbtr,
       END OF ta_anep.

TYPES: BEGIN OF ta_anlp2,
         bukrs  LIKE anlp-bukrs,
         gjahr  LIKE anlp-gjahr,
         peraf  LIKE anlp-peraf,
         anln1  LIKE anlp-anln1,
         anln2  LIKE anlp-anln2,
         afaber LIKE anlp-afaber,
         nafaz  LIKE anlp-nafaz,
       END OF ta_anlp2.

TYPES: BEGIN OF ta_anlp3,
         bukrs  LIKE anlp-bukrs,
         gjahr  LIKE anlp-gjahr,
         anln1  LIKE anlp-anln1,
         anln2  LIKE anlp-anln2,
         afaber LIKE anlp-afaber,
         nafaz  LIKE anlp-nafaz,
       END OF ta_anlp3.

TYPES: BEGIN OF ta_tabw,
         bwasl LIKE tabw-bwasl,
       END OF ta_tabw.

DATA: i_itab   TYPE ta_itab OCCURS 0,
      wa_itab  TYPE ta_itab,
      i_t247   TYPE t247 OCCURS 0,
      wa_t247  TYPE t247,
      i_tabw   TYPE ta_tabw OCCURS 0,
      wa_tabw  TYPE ta_tabw,
      i_anlp2  TYPE ta_anlp2 OCCURS 0 WITH HEADER LINE,
      wa_anlp2 TYPE ta_anlp2,
      i_anlp3  TYPE ta_anlp3 OCCURS 0 WITH HEADER LINE,
      wa_anlp3 TYPE ta_anlp3,
      i_anep   TYPE ta_anep OCCURS 0,
      wa_anep  TYPE ta_anep,
      i_anep1  TYPE ta_anep OCCURS 0,
      wa_anep1 TYPE ta_anep.

DATA: i_lfa1    TYPE TABLE OF lfa1 WITH HEADER LINE.

DATA: va_lines TYPE i,
      va_date  LIKE sy-datum.

* Data untuk ALV
DATA: i_fieldcat_alv  TYPE slis_t_fieldcat_alv,
      i_events        TYPE slis_t_event,
      i_list_comments TYPE slis_t_listheader.

DATA: ta_sort          TYPE slis_t_sortinfo_alv,
      w_variant        LIKE disvariant,
      w_repid          LIKE sy-repid,
      w_callback_ucomm TYPE slis_formname VALUE 'CALLBACK_UCOMM',
      w_print          TYPE slis_print_alv,
      w_layout         TYPE slis_layout_alv,
      w_fieldcat_alv   LIKE LINE OF i_fieldcat_alv,
      w_events         LIKE LINE OF i_events,
      w_list_comments  LIKE LINE OF i_list_comments.

RANGES:  ra_bwasl  FOR tabw-bwasl.

*&---------------------------------------------------------------------*
*& SELECTION SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS    :
  pa_bukrs LIKE anlc-bukrs OBLIGATORY DEFAULT '8020'.
SELECT-OPTIONS:
  so_gsber FOR anlz-gsber.
PARAMETERS    :
  pa_datum LIKE sy-datum OBLIGATORY DEFAULT sy-datum.
SELECT-OPTIONS:
  so_anlkl FOR anla-anlkl,
  so_anln1 FOR anla-anln1,
  so_anln2 FOR anla-anln2,
  so_kostl FOR anlz-kostl.
PARAMETERS    :
  pa_afabe LIKE anlb-afabe OBLIGATORY DEFAULT '01'.
SELECTION-SCREEN END OF BLOCK block1.

*&---------------------------------------------------------------------*
*&      Initialization
*&---------------------------------------------------------------------*
INITIALIZATION.
  w_repid = sy-repid.

  DATA lv_parva(40).

  CLEAR lv_parva.

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
    so_gsber-low  = lv_parva.
    APPEND so_gsber.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  IF NOT pa_datum IS INITIAL.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = pa_datum
      IMPORTING
        last_day_of_month = pa_datum.
  ENDIF.

*&---------------------------------------------------------------------*
*& START OF SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM get_data.
  DESCRIBE TABLE i_itab LINES va_lines.
  IF va_lines EQ 0.
    MESSAGE i000(zf) WITH 'No data selected'.
    EXIT.
  ENDIF.

  IF pa_afabe EQ '01'.
    PERFORM process_01.
  ELSE.
*    PERFORM process_01.
    PERFORM process_10.
  ENDIF.

  PERFORM fieldcat_build TABLES i_out.
  PERFORM event_build.
  PERFORM fill_sort.
  PERFORM layout_build.
  PERFORM display_data.
*  PERFORM alv_top_of_page.
END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data.
  DATA: lt_anlp TYPE TABLE OF anlp WITH HEADER LINE.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = pa_datum
    IMPORTING
      last_day_of_month = va_date.

*  if pa_afabe eq '01'.
  SELECT a~bukrs a~anln1 a~anln2 a~gjahr a~afabe a~afblpe a~kansw
         a~knafa a~nafap a~answl a~nafav a~nafal a~ksafa a~safap
         a~safav a~safal a~ndabj a~ndabp
         b~anlkl b~zujhr b~zuper b~zugdt b~aktiv b~deakt b~lifnr
         b~invnr b~vbund b~txt50 b~sernr b~ord41 b~menge b~meins
         b~eaufn b~ord42 b~aibn1 b~aibn2 b~txa50
         c~afabg c~ndjar c~ndper c~afasl
         d~gsber d~kostl d~caufn d~xstil
    INTO CORRESPONDING FIELDS OF TABLE i_itab
    FROM anlc AS a JOIN anla AS b ON a~bukrs EQ b~bukrs AND
                                     a~anln1 EQ b~anln1 AND
                                     a~anln2 EQ b~anln2
                   JOIN anlb AS c ON a~bukrs EQ c~bukrs AND
                                     a~anln1 EQ c~anln1 AND
                                     a~anln2 EQ c~anln2 AND
                                     c~afabe EQ pa_afabe
              LEFT JOIN anlz AS d ON a~bukrs EQ d~bukrs AND
                                     a~anln1 EQ d~anln1 AND
                                     a~anln2 EQ d~anln2 AND
                                     d~bdatu GE pa_datum
    WHERE a~bukrs EQ pa_bukrs    AND
          a~anln1 IN so_anln1    AND
          a~anln2 IN so_anln2    AND
          a~gjahr EQ pa_datum(4) AND
          a~afabe EQ pa_afabe    AND
          b~anlkl IN so_anlkl    AND
          ( b~deakt EQ '00000000'  OR
            b~deakt GT pa_datum ).

  PERFORM f_get_vendor_name.

  DELETE ADJACENT DUPLICATES FROM i_itab
    COMPARING bukrs anln1 anln2 gjahr.

*    elseif pa_afabe eq '10'.
*      SELECT a~bukrs a~anln1 a~anln2 a~gjahr a~afabe a~afblpe a~kansw
*             a~knafa a~nafap a~answl a~nafav a~nafal a~ksafa a~safap
*             a~safav a~safal a~ndabj a~ndabp
*             b~anlkl b~zujhr b~zuper b~zugdt b~aktiv b~deakt b~lifnr
*             b~invnr b~vbund b~txt50 b~sernr
*             c~afabg c~ndjar c~ndper c~afasl
*             d~gsber d~kostl
*        INTO CORRESPONDING FIELDS OF TABLE i_itab
*        FROM anlc AS a JOIN anla AS b ON a~bukrs EQ b~bukrs AND
*                                         a~anln1 EQ b~anln1 AND
*                                         a~anln2 EQ b~anln2
*                       JOIN anlb AS c ON a~bukrs EQ c~bukrs AND
*                                         a~anln1 EQ c~anln1 AND
*                                         a~anln2 EQ c~anln2 AND
*                                         c~afabe EQ pa_afabe
*                  LEFT JOIN anlz AS d ON a~bukrs EQ d~bukrs AND
*                                         a~anln1 EQ d~anln1 AND
*                                         a~anln2 EQ d~anln2
*        WHERE a~bukrs EQ pa_bukrs    AND
*              a~anln1 IN so_anln1    AND
*              a~anln2 IN so_anln2    AND
*              a~afabe EQ pa_afabe    AND
*              b~anlkl IN so_anlkl    AND
*            ( b~deakt EQ '00000000'  OR
*              b~deakt GT pa_datum ).
*
*      DELETE ADJACENT DUPLICATES FROM i_itab
*        COMPARING bukrs anln1 anln2.
*    endif.


  IF NOT ( so_kostl IS INITIAL ).
    DELETE i_itab WHERE NOT ( kostl IN so_kostl ).
  ENDIF.
  IF NOT ( so_gsber IS INITIAL ).
    DELETE i_itab WHERE NOT ( gsber IN so_gsber ).
  ENDIF.

  SELECT spras mnr ktx ltx
    FROM t247
    INTO CORRESPONDING FIELDS OF TABLE i_t247
    WHERE spras EQ sy-langu.

  IF pa_bukrs = '8010'.
    SELECT bukrs gjahr peraf afbnr anln1 anln2 afaber
           zujhr zucod nafap nafag nafaz aafaz
      INTO CORRESPONDING FIELDS OF TABLE lt_anlp
      FROM anlp WHERE bukrs  EQ pa_bukrs      AND
                      anln1  IN so_anln1      AND
                      anln2  IN so_anln2      AND
                      gjahr  EQ pa_datum(4)   AND
                      peraf  LE pa_datum+4(2) AND
                      afaber EQ pa_afabe.

    SORT lt_anlp BY bukrs gjahr anln1 anln2 afaber.
    LOOP AT lt_anlp.
      CLEAR wa_anlp.
      MOVE-CORRESPONDING lt_anlp TO wa_anlp.
*      IF lt_anlp-aafaz IS NOT INITIAL.
*        wa_anlp-nafaz = lt_anlp-aafaz.
*      ENDIF.
      ADD lt_anlp-aafaz TO wa_anlp-nafaz.
      COLLECT wa_anlp INTO i_anlp.
    ENDLOOP.
    SORT i_anlp BY bukrs gjahr anln1 anln2 afaber.

  ELSE.
*********************** Tambahan Sukardi
    SELECT  bukrs gjahr anln1 anln2 afaber
            SUM( nafap )
            SUM( nafag )
            SUM( nafaz )
            INTO TABLE i_anlp
            FROM anlp
            WHERE
            bukrs  EQ pa_bukrs    AND
            anln1  IN so_anln1    AND
            anln2  IN so_anln2    AND
            gjahr  EQ pa_datum(4)  AND
            peraf  LE pa_datum+4(2) AND
            afaber EQ pa_afabe
            GROUP BY bukrs gjahr anln1 anln2 afaber.
  ENDIF.

  SELECT  bukrs gjahr anln1 anln2 afaber
          SUM( nafap )
          SUM( nafag )
          SUM( nafaz )
          INTO TABLE i_anlp1
          FROM anlp
          WHERE
          bukrs  EQ pa_bukrs    AND
          anln1  IN so_anln1    AND
          anln2  IN so_anln2    AND
          gjahr  LT pa_datum(4) AND
          afaber EQ pa_afabe
          GROUP BY bukrs gjahr anln1 anln2 afaber.
********************** End Tambahan

  SELECT bwasl
    FROM tabw
    INTO CORRESPONDING FIELDS OF TABLE i_tabw.
  CLEAR: wa_tabw.
  LOOP AT i_tabw INTO wa_tabw.
    ra_bwasl-low    = wa_tabw-bwasl.
    ra_bwasl-sign   = 'I'.
    ra_bwasl-option = 'EQ'.
    APPEND ra_bwasl.
    CLEAR: wa_tabw.
  ENDLOOP.

  IF pa_bukrs = '8010'.
    CLEAR: lt_anlp,lt_anlp[].
    SELECT bukrs gjahr peraf afbnr anln1 anln2 afaber
           zujhr zucod nafap nafag nafaz aafaz
      INTO CORRESPONDING FIELDS OF TABLE lt_anlp
      FROM anlp WHERE bukrs  EQ pa_bukrs      AND
                      anln1  IN so_anln1      AND
                      anln2  IN so_anln2      AND
                      gjahr  EQ pa_datum(4)   AND
*                    peraf  LE pa_datum+4(2) AND
                      afaber EQ pa_afabe.

    SORT lt_anlp BY bukrs gjahr anln1 anln2 afaber.
    LOOP AT lt_anlp.
      CLEAR: wa_anlp2,wa_anlp3.
      MOVE-CORRESPONDING lt_anlp TO wa_anlp2.
      MOVE-CORRESPONDING lt_anlp TO wa_anlp3.
*      IF lt_anlp-aafaz IS NOT INITIAL.
*        wa_anlp2-nafaz = lt_anlp-aafaz.
*        wa_anlp3-nafaz = lt_anlp-aafaz.
*      ENDIF.
      ADD lt_anlp-aafaz TO wa_anlp2-nafaz.
      ADD lt_anlp-aafaz TO wa_anlp3-nafaz.
      MULTIPLY wa_anlp3-nafaz BY -1.
      COLLECT wa_anlp2 INTO i_anlp2.
      COLLECT wa_anlp3 INTO i_anlp3.
    ENDLOOP.
    SORT i_anlp2 BY bukrs gjahr peraf anln1 anln2 afaber.
    SORT i_anlp3 BY bukrs gjahr anln1 anln2 afaber.

  ELSE.
    SELECT bukrs gjahr peraf anln1 anln2 afaber
           SUM( nafaz )
      FROM anlp
      INTO TABLE i_anlp2
      WHERE bukrs  EQ pa_bukrs    AND
            anln1  IN so_anln1    AND
            anln2  IN so_anln2    AND
            gjahr  EQ pa_datum(4) AND
            afaber EQ pa_afabe
    GROUP BY bukrs gjahr peraf anln1 anln2 afaber.
  ENDIF.

  SELECT bukrs anln1 anln2 gjahr afabe bwasl bzdat
         SUM( anbtr )
    FROM anep
    INTO TABLE i_anep
    WHERE bukrs EQ pa_bukrs    AND
          anln1 IN so_anln1    AND
          anln2 IN so_anln2    AND
          gjahr EQ pa_datum(4) AND
          afabe EQ pa_afabe    AND
          bwasl IN ra_bwasl
    GROUP BY bukrs anln1 anln2 gjahr afabe bzdat bwasl.

  SELECT a~bukrs a~anln1 a~anln2 a~gjahr a~afabe a~bwasl a~bzdat
         SUM( a~anbtr )
    FROM anep AS a JOIN anek AS b ON a~bukrs EQ b~bukrs AND
                                     a~anln1 EQ b~anln1 AND
                                     a~anln2 EQ b~anln2 AND
                                     a~gjahr EQ b~gjahr AND
                                     a~lnran EQ b~lnran
    INTO TABLE i_anep1
    WHERE a~bukrs EQ pa_bukrs    AND
          a~anln1 IN so_anln1    AND
          a~anln2 IN so_anln2    AND
          a~gjahr EQ pa_datum(4) AND
          a~afabe EQ pa_afabe    AND
          a~bwasl IN ra_bwasl    AND
          b~budat GT va_date
    GROUP BY a~bukrs a~anln1 a~anln2 a~gjahr a~afabe a~bzdat a~bwasl.
ENDFORM.                    " get_data

*&---------------------------------------------------------------------*
*&      Form  process_01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_01.
  DATA: l_acquv(16) TYPE p DECIMALS 3,
        l_acdep(16) TYPE p DECIMALS 3,
        l_nafap(16) TYPE p DECIMALS 3,
        l_nafag(16) TYPE p DECIMALS 3,
        l_anbtr     LIKE anep-anbtr,
        l_month     TYPE i,
        l_year      TYPE i,
        l_count1    TYPE i,
        l_usfl      TYPE i,
        l_usfl1     TYPE i,
        l_exusfl    TYPE i,
        l_period    LIKE pc260-fpper,
        l_period1   LIKE pc260-fpper,
        l_bwasl     LIKE anep-bwasl,
        l_date1(6),
        l_date2(6),
        l_date3(6),
        l_date4(8),
        l_perio(5),
        l_sw(1),
        l_perio1    TYPE i.

  DATA: lf_spmon    LIKE s705-spmon,
        lf_spmon1   LIKE s705-spmon,
        lf_nmod     TYPE i,
        lf_mod      TYPE i,
        lf_ndiv     TYPE i,
        lf_div      TYPE i,
        lf_month(2) TYPE n,
        lf_year(4)  TYPE n.

  CLEAR: wa_itab.
  SORT i_itab BY bukrs gjahr anln1 anln2.
  SORT i_anlp2 BY bukrs gjahr anln1 anln2.
  LOOP AT i_itab INTO wa_itab.

    MOVE-CORRESPONDING wa_itab TO i_out.

    CLEAR i_lfa1.
    READ TABLE i_lfa1 WITH KEY lifnr = i_out-lifnr.
    i_out-name1 = i_lfa1-name1.

    l_acquv     = wa_itab-kansw + wa_itab-answl.
*    IF l_acquv EQ 0.
*      SORT i_anep BY bukrs anln1 anln2 gjahr.
*      READ TABLE i_anep INTO wa_anep
*        WITH KEY bukrs = pa_bukrs
*                 anln1 = wa_itab-anln1
*                 anln2 = wa_itab-anln2
*        BINARY SEARCH.
*      IF SY-SUBRC NE 0.
*        l_acquv = 0.
*        l_acdep = 0.
*        l_nafap = 0.
*        l_nafag = 0.
*      ELSE.
*        l_acquv = wa_anep-anbtr.
*        l_bwasl = wa_anep-bwasl.
*      ENDIF.
*    ENDIF.

*    READ table i_anep1 INTO wa_anep1
*      WITH KEY bukrs = pa_bukrs
*               anln1 = wa_itab-anln1
*               anln2 = wa_itab-anln2.
*    IF SY-SUBRC = 0.
*      l_acquv = l_acquv - wa_anep1-anbtr.
*    ENDIF.

    IF l_acquv EQ 0.
      CLEAR: wa_anep.
      LOOP AT i_anep INTO wa_anep
        WHERE bukrs EQ pa_bukrs      AND
              anln1 EQ wa_itab-anln1 AND
              anln2 EQ wa_itab-anln2 AND
              afabe EQ pa_afabe.
        ADD wa_anep-anbtr TO l_acquv.
        CLEAR: wa_anep.
      ENDLOOP.
    ENDIF.

    CLEAR: wa_anep1.
    LOOP AT i_anep1 INTO wa_anep1
      WHERE bukrs EQ pa_bukrs      AND
            anln1 EQ wa_itab-anln1 AND
            anln2 EQ wa_itab-anln2 AND
            afabe EQ pa_afabe.
      ADD wa_anep1-anbtr TO l_anbtr.
      CLEAR: wa_anep1.
    ENDLOOP.

    l_acquv = l_acquv - l_anbtr.
    CLEAR: l_anbtr.

    READ TABLE i_anlp2 INTO wa_anlp2
    WITH KEY bukrs = pa_bukrs
             gjahr = pa_datum(4)
             anln1 = wa_itab-anln1
             anln2 = wa_itab-anln2
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      CONCATENATE wa_anlp2-gjahr wa_anlp2-peraf+1(2) INTO l_date3.
    ENDIF.

**    i_out-perio = ( wa_itab-ndjar * 12 ) + wa_itab-ndper.
    l_usfl   = ( wa_itab-ndjar * 12 ) + wa_itab-ndper.
    l_exusfl = ( wa_itab-ndabj * 12 ) + wa_itab-ndabp.
    i_out-perio = l_usfl - l_exusfl.
    i_out-month = l_usfl.
    IF i_out-perio = 0.
      i_out-perio = 1.
    ENDIF.

    l_usfl = l_usfl - 1.
    l_period = wa_itab-afabg(6).
    CALL FUNCTION 'HR_CALC_MONTH'
      EXPORTING
        delta           = l_usfl
*       POINT           =
      CHANGING
        periode         = l_period
      EXCEPTIONS
        invalid_period  = 1
        undefined_point = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    IF i_out-perio EQ 0.
      l_nafag    = 0.
    ELSE.
      IF l_period LE pa_datum(6).
        l_nafag    = 0.
      ELSE.
        l_nafag    = l_acquv / i_out-perio.
      ENDIF.
    ENDIF.

    IF wa_itab-zujhr LT pa_datum(4).
      l_year  = pa_datum(4) - 1.
      l_month = 12.
      l_perio = ( ( l_year - wa_itab-zujhr ) * 12 ) + 1.
*      l_perio = l_perio + l_month - wa_itab-zuper+1(2).
**      l_perio = l_perio + l_month - wa_itab-aktiv+4(2).
      l_perio = l_perio + l_month - wa_itab-zugdt+4(2).

**  Tambah kondisi u/ ambil posted value
      READ TABLE i_anlp2 WITH KEY bukrs = pa_bukrs
                                  gjahr = pa_datum(4)
                                  peraf = pa_datum+4(2)
                                  anln1 = wa_itab-anln1
                                  anln2 = wa_itab-anln2.
      IF sy-subrc = 0.
        CLEAR l_perio.
        l_sw = 'X'.
      ENDIF.
**  End kondisi u/ ambil posted value

* Perhitungan usefull untuk depric month
      l_usfl1   = ( wa_itab-ndjar * 12 ) + wa_itab-ndper.
      lf_spmon = l_period + l_usfl1.

      IF lf_spmon+4(2) GT 12.
        lf_nmod = lf_spmon+4(2).
        lf_mod = lf_nmod MOD 12.
        lf_ndiv = lf_spmon+4(2).
        lf_div = lf_ndiv DIV 12.
        lf_div = lf_spmon(4) + lf_div.

        lf_year   = lf_div.
        lf_month  = lf_mod.
        CONCATENATE lf_year lf_month INTO lf_spmon1.
      ELSE.
        lf_spmon1 = lf_spmon.
      ENDIF.

*      IF l_perio GE i_out-perio.
      IF l_perio GE i_out-month.
        SORT i_anlp BY bukrs anln1 anln2.
        READ TABLE i_anlp INTO wa_anlp
          WITH KEY bukrs = pa_bukrs
                   anln1 = wa_itab-anln1
                   anln2 = wa_itab-anln2
          BINARY SEARCH.
        IF sy-subrc EQ 0.
          IF pa_datum+4(2) GT wa_itab-afblpe.
            l_acdep = wa_itab-knafa * -1.
            l_nafap = wa_itab-nafap * -1.
          ELSE.
            l_acdep = wa_itab-knafa * -1.
            l_nafap = wa_anlp-nafaz * -1.
          ENDIF.
        ELSE.
          IF pa_afabe EQ '10'.
            l_acdep = wa_itab-ksafa * -1.
            l_nafap = wa_itab-safap / -12 * pa_datum+4(2).
          ENDIF.
        ENDIF.
      ELSE.
        IF wa_itab-nafap = 0.
          l_acdep = 0.
          l_nafag = 0.
          IF pa_afabe EQ '10'.
            l_acdep = wa_itab-ksafa * -1.
            l_nafap = wa_itab-safap / -12 * pa_datum+4(2).
          ENDIF.
        ELSE.
          SORT i_anlp BY bukrs anln1 anln2.
          READ TABLE i_anlp INTO wa_anlp
            WITH KEY bukrs = pa_bukrs
                     anln1 = wa_itab-anln1
                     anln2 = wa_itab-anln2
            BINARY SEARCH.
          IF sy-subrc = 0.
            l_acdep = wa_itab-knafa * -1.
            l_nafap = wa_anlp-nafaz * -1.
            IF pa_datum+4(2) GT wa_itab-afblpe.
              l_perio1 = pa_datum+4(2) - wa_itab-afblpe.
              IF lf_spmon1 LT pa_datum(6).
                l_nafap  = l_nafap + ( wa_itab-nafap / -12 * l_perio1 ).
              ENDIF.
            ENDIF.
            PERFORM isi_month.
          ELSE.
            l_acdep = wa_itab-knafa * -1.
            l_nafap = wa_itab-nafap / -12 * pa_datum+4(2).
            PERFORM isi_month.
          ENDIF.

        ENDIF.
      ENDIF.
    ELSE.
      l_year  = pa_datum(4).
*      l_perio = pa_datum+4(2) - wa_itab-zuper+1(2) + 1.
**      l_perio = pa_datum+4(2) - wa_itab-aktiv+4(2) + 1.

* Perhitungan usefull untuk depric month
      l_usfl1   = ( wa_itab-ndjar * 12 ) + wa_itab-ndper.
      lf_spmon = l_period + l_usfl1.

      IF lf_spmon+4(2) GT 12.
        lf_nmod = lf_spmon+4(2).
        lf_mod = lf_nmod MOD 12.
        lf_ndiv = lf_spmon+4(2).
        lf_div = lf_ndiv DIV 12.
        lf_div = lf_spmon(4) + lf_div.

        lf_year   = lf_div.
        lf_month  = lf_mod.
        CONCATENATE lf_year lf_month INTO lf_spmon1.
      ELSE.
        lf_spmon1 = lf_spmon.
      ENDIF.

** Penambahan kondisi untuk Expirated depreciation
*        IF lf_spmon1 LT pa_datum(6) AND
*           l_sw IS INITIAL.
*          i_out-nafap = i_out-nafap - i_out-nafag.
*          i_out-nafag = 0.
*        ELSE.
*          i_out-nafag = 0.
*        ENDIF.
** end tambah

      l_perio = pa_datum+4(2) - wa_itab-zugdt+4(2) + 1.
      l_acdep = 0.
      SORT i_anlp BY bukrs gjahr anln1 anln2.
      READ TABLE i_anlp INTO wa_anlp
        WITH KEY bukrs = pa_bukrs
                 gjahr = l_year
                 anln1 = wa_itab-anln1
                 anln2 = wa_itab-anln2
        BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF pa_datum+4(2) GT wa_itab-afblpe.
          IF pa_afabe EQ '01'.
            IF lf_spmon1 EQ pa_datum(6).
              l_nafap = wa_itab-nafap * -1.
            ELSE.
              l_nafap  = l_nafag * l_perio.
            ENDIF.
          ELSE.
            l_nafap = wa_itab-safap / -12 * pa_datum+4(2).
          ENDIF.
        ELSE.
          l_nafap = wa_anlp-nafaz * -1.
        ENDIF.
        PERFORM isi_month.
      ELSE.
        IF i_out-perio EQ 0.
          l_nafap = wa_itab-nafap * -1.
        ELSE.
          IF pa_datum(6) GE l_date3.
            l_nafap = ( l_acquv / i_out-perio ) * l_perio.
          ELSE.
            l_nafap = 0.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    READ TABLE i_t247 INTO wa_t247
      WITH KEY spras = sy-langu
*               mnr   = wa_itab-zuper+1(2).
**               mnr   = wa_itab-aktiv+4(2).
               mnr   = wa_itab-zugdt+4(2).
    IF sy-subrc EQ 0.
      i_out-per01 = wa_t247-ktx.
    ELSE.
      i_out-per01 = space.
    ENDIF.

    CONCATENATE i_out-per01 wa_itab-zujhr INTO i_out-per01
      SEPARATED BY space.

    MOVE pa_datum(6) TO l_date1.
*    CONCATENATE wa_itab-zujhr wa_itab-zuper+1(2) INTO l_date2.

**    CONCATENATE wa_itab-aktiv(4) wa_itab-aktiv+4(2) INTO l_date2.
    CONCATENATE wa_itab-zugdt(4) wa_itab-zugdt+4(2) INTO l_date2.

    IF l_date2 LE l_date1.
      CLEAR: l_count1.
      IF i_out-jan EQ 0.
        l_count1 = 1.
        IF l_count1 LE pa_datum+4(2).
          IF pa_afabe EQ '01'.
            IF wa_itab-zujhr EQ pa_datum(4).
              IF l_perio EQ 0.
                i_out-jan = 0.
              ELSE.
                IF pa_datum(6) GE l_date3.
                  IF lf_spmon1 GT pa_datum(6).
                    i_out-jan = l_acquv / i_out-perio.
                  ELSE.
                    i_out-jan = 0.
                  ENDIF.
                ELSE.
                  i_out-jan = 0.
                ENDIF.

*                  i_out-jan = l_acquv / l_perio.
              ENDIF.
            ELSE.
*****              IF lf_spmon1 GT pa_datum(6).   "Comment 8010 24/04/2008
              IF l_period GT pa_datum(6).
                i_out-jan = wa_itab-nafap / 12.
              ELSE.
                i_out-jan = 0.
              ENDIF.
            ENDIF.
          ELSE.
            i_out-jan = l_nafag.
          ENDIF.
        ELSE.
          i_out-jan = 0.
        ENDIF.
      ENDIF.

      IF i_out-feb EQ 0.
        l_count1 = 2.
        IF l_count1 LE pa_datum+4(2).
          IF pa_afabe EQ '01'.
            IF wa_itab-zujhr EQ pa_datum(4).
              IF l_perio EQ 0.
                i_out-feb = 0.
              ELSE.
                IF pa_datum(6) GE l_date3.
                  IF lf_spmon1 GT pa_datum(6).
                    i_out-feb = l_acquv / i_out-perio.
                  ELSE.
                    i_out-feb = 0.
                  ENDIF.
                ELSE.
                  i_out-feb = 0.
                ENDIF.
*                  i_out-feb = l_acquv / l_perio.
              ENDIF.
            ELSE.
*****              IF lf_spmon1 GT pa_datum(6).   "Comment 8010 24/04/2008
              IF l_period GT pa_datum(6).
                i_out-feb = wa_itab-nafap / 12.
              ELSE.
                i_out-feb = 0.
              ENDIF.
            ENDIF.
          ELSE.
            i_out-feb = l_nafag.
          ENDIF.
        ELSE.
          i_out-feb = 0.
        ENDIF.
      ENDIF.

      IF i_out-mar EQ 0.
        l_count1 = 3.
        IF l_count1 LE pa_datum+4(2).
          IF pa_afabe EQ '01'.
            IF wa_itab-zujhr EQ pa_datum(4).
              IF l_perio EQ 0.
                i_out-mar = 0.
              ELSE.
                IF pa_datum(6) GE l_date3.
                  IF lf_spmon1 GT pa_datum(6).
                    i_out-mar = l_acquv / i_out-perio.
                  ELSE.
                    i_out-mar = 0.
                  ENDIF.
                ELSE.
                  i_out-mar = 0.
                ENDIF.
*                  i_out-mar = l_acquv / l_perio.
              ENDIF.
            ELSE.
*****              IF lf_spmon1 GT pa_datum(6).   "Comment 8010 24/04/2008
              IF l_period GT pa_datum(6).
                i_out-mar = wa_itab-nafap / 12.
              ELSE.
                i_out-mar = 0.
              ENDIF.
            ENDIF.
          ELSE.
            i_out-mar = l_nafag.
          ENDIF.
        ELSE.
          i_out-mar = 0.
        ENDIF.
      ENDIF.

      IF i_out-apr EQ 0.
        l_count1 = 4.
        IF l_count1 LE pa_datum+4(2).
          IF pa_afabe EQ '01'.
            IF wa_itab-zujhr EQ pa_datum(4).
              IF l_perio EQ 0.
                i_out-apr = 0.
              ELSE.
                IF pa_datum(6) GE l_date3.
                  IF lf_spmon1 GT pa_datum(6).
                    i_out-apr = l_acquv / i_out-perio.
                  ELSE.
                    i_out-apr = 0.
                  ENDIF.
                ELSE.
                  i_out-apr = 0.
                ENDIF.
*                  i_out-apr = l_acquv / l_perio.
              ENDIF.
            ELSE.
*****              IF lf_spmon1 GT pa_datum(6).   "Comment 8010 24/04/2008
              IF l_period GT pa_datum(6).
                i_out-apr = wa_itab-nafap / 12.
              ELSE.
                i_out-apr = 0.
              ENDIF.
            ENDIF.
          ELSE.
            i_out-apr = l_nafag.
          ENDIF.
        ELSE.
          i_out-apr = 0.
        ENDIF.
      ENDIF.

      IF i_out-mei EQ 0.
        l_count1 = 5.
        IF l_count1 LE pa_datum+4(2).
          IF pa_afabe EQ '01'.
            IF wa_itab-zujhr EQ pa_datum(4).
              IF l_perio EQ 0.
                i_out-mei = 0.
              ELSE.
                IF pa_datum(6) GE l_date3.
                  IF lf_spmon1 GT pa_datum(6).
                    i_out-mei = l_acquv / i_out-perio.
                  ELSE.
                    i_out-mei = 0.
                  ENDIF.
                ELSE.
                  i_out-mei = 0.
                ENDIF.
*                  i_out-mei = l_acquv / l_perio.
              ENDIF.
            ELSE.
*****              IF lf_spmon1 GT pa_datum(6).   "Comment 8010 24/04/2008
              IF l_period GT pa_datum(6).
                i_out-mei = wa_itab-nafap / 12.
              ELSE.
                i_out-mei = 0.
              ENDIF.
            ENDIF.
          ELSE.
            i_out-mei = l_nafag.
          ENDIF.
        ELSE.
          i_out-mei = 0.
        ENDIF.
      ENDIF.

      IF i_out-jun EQ 0.
        l_count1 = 6.
        IF l_count1 LE pa_datum+4(2).
          IF pa_afabe EQ '01'.
            IF wa_itab-zujhr EQ pa_datum(4).
              IF l_perio EQ 0.
                i_out-jun = 0.
              ELSE.
                IF pa_datum(6) GE l_date3.
                  IF lf_spmon1 GT pa_datum(6).
                    i_out-jun = l_acquv / i_out-perio.
                  ELSE.
                    i_out-jun = 0.
                  ENDIF.
                ELSE.
                  i_out-jun = 0.
                ENDIF.
*                  i_out-jun = l_acquv / l_perio.
              ENDIF.
            ELSE.
*****              IF lf_spmon1 GT pa_datum(6).   "Comment 8010 24/04/2008
              IF l_period GT pa_datum(6).
                i_out-jun = wa_itab-nafap / 12.
              ELSE.
                i_out-jun = 0.
              ENDIF.
            ENDIF.
          ELSE.
            i_out-jun = l_nafag.
          ENDIF.
        ELSE.
          i_out-jun = 0.
        ENDIF.
      ENDIF.

      IF i_out-jul EQ 0.
        l_count1 = 7.
        IF l_count1 LE pa_datum+4(2).
          IF pa_afabe EQ '01'.
            IF wa_itab-zujhr EQ pa_datum(4).
              IF l_perio EQ 0.
                i_out-jul = 0.
              ELSE.
                IF pa_datum(6) GE l_date3.
                  IF lf_spmon1 GT pa_datum(6).
                    i_out-jul = l_acquv / i_out-perio.
                  ELSE.
                    i_out-jul = 0.
                  ENDIF.
                ELSE.
                  i_out-jul = 0.
                ENDIF.
*                  i_out-jul = l_acquv / l_perio.
              ENDIF.
            ELSE.
*****              IF lf_spmon1 GT pa_datum(6).   "Comment 8010 24/04/2008
              IF l_period GT pa_datum(6).
                i_out-jul = wa_itab-nafap / 12.
              ELSE.
                i_out-jul = 0.
              ENDIF.
            ENDIF.
          ELSE.
            i_out-jul = l_nafag.
          ENDIF.
        ELSE.
          i_out-jul = 0.
        ENDIF.
      ENDIF.

      IF i_out-aug EQ 0.
        l_count1 = 8.
        IF l_count1 LE pa_datum+4(2).
          IF pa_afabe EQ '01'.
            IF wa_itab-zujhr EQ pa_datum(4).
              IF l_perio EQ 0.
                i_out-aug = 0.
              ELSE.
                IF pa_datum(6) GE l_date3.
                  IF lf_spmon1 GT pa_datum(6).
                    i_out-aug = l_acquv / i_out-perio.
                  ELSE.
                    i_out-aug = 0.
                  ENDIF.
                ELSE.
                  i_out-aug = 0.
                ENDIF.
*                  i_out-aug = l_acquv / l_perio.
              ENDIF.
            ELSE.
*****              IF lf_spmon1 GT pa_datum(6).   "Comment 8010 24/04/2008
              IF l_period GT pa_datum(6).
                i_out-aug = wa_itab-nafap / 12.
              ELSE.
                i_out-aug = 0.
              ENDIF.
            ENDIF.
          ELSE.
            i_out-aug = l_nafag.
          ENDIF.
        ELSE.
          i_out-aug = 0.
        ENDIF.
      ENDIF.

      IF i_out-sep EQ 0.
        l_count1 = 9.
        IF l_count1 LE pa_datum+4(2).
          IF pa_afabe EQ '01'.
            IF wa_itab-zujhr EQ pa_datum(4).
              IF l_perio EQ 0.
                i_out-sep = 0.
              ELSE.
                IF pa_datum(6) GE l_date3.
                  IF lf_spmon1 GT pa_datum(6).
                    i_out-sep = l_acquv / i_out-perio.
                  ELSE.
                    i_out-sep = 0.
                  ENDIF.
                ELSE.
                  i_out-sep = 0.
                ENDIF.
*                  i_out-sep = l_acquv / l_perio.
              ENDIF.
            ELSE.
*****              IF lf_spmon1 GT pa_datum(6).   "Comment 8010 24/04/2008
              IF l_period GT pa_datum(6).
                i_out-sep = wa_itab-nafap / 12.
              ELSE.
                i_out-sep = 0.
              ENDIF.
            ENDIF.
          ELSE.
            i_out-sep = l_nafag.
          ENDIF.
        ELSE.
          i_out-sep = 0.
        ENDIF.
      ENDIF.

      IF i_out-okt EQ 0.
        l_count1 = 10.
        IF l_count1 LE pa_datum+4(2).
          IF pa_afabe EQ '01'.
            IF wa_itab-zujhr EQ pa_datum(4).
              IF l_perio EQ 0.
                i_out-okt = 0.
              ELSE.
                IF pa_datum(6) GE l_date3.
                  IF lf_spmon1 GT pa_datum(6).
                    i_out-okt = l_acquv / i_out-perio.
                  ELSE.
                    i_out-okt = 0.
                  ENDIF.
                ELSE.
                  i_out-okt = 0.
                ENDIF.
*                  i_out-okt = l_acquv / l_perio.
              ENDIF.
            ELSE.
*****              IF lf_spmon1 GT pa_datum(6).   "Comment 8010 24/04/2008
              IF l_period GT pa_datum(6).
                i_out-okt = wa_itab-nafap / 12.
              ELSE.
                i_out-okt = 0.
              ENDIF.
            ENDIF.
          ELSE.
            i_out-okt = l_nafag.
          ENDIF.
        ELSE.
          i_out-okt = 0.
        ENDIF.
      ENDIF.

      IF i_out-nov EQ 0.
        l_count1 = 11.
        IF l_count1 LE pa_datum+4(2).
          IF pa_afabe EQ '01'.
            IF wa_itab-zujhr EQ pa_datum(4).
              IF l_perio EQ 0.
                i_out-nov = 0.
              ELSE.
                IF pa_datum(6) GE l_date3.
                  IF lf_spmon1 GT pa_datum(6).
                    i_out-nov = l_acquv / i_out-perio.
                  ELSE.
                    i_out-nov = 0.
                  ENDIF.
                ELSE.
                  i_out-nov = 0.
                ENDIF.
*                  i_out-nov = l_acquv / l_perio.
              ENDIF.
            ELSE.
*   koreksi untuk asset# 131600000018
*                i_out-nov = wa_itab-nafap / 12.
*   Sementara by budi
*****              IF lf_spmon1 GT pa_datum(6).   "Comment 8010 24/04/2008
              IF l_period GT pa_datum(6).
                i_out-nov = wa_itab-nafap / 12.
              ELSE.
                i_out-nov = 0.
              ENDIF.
            ENDIF.
          ELSE.
            i_out-nov = l_nafag.
          ENDIF.
        ELSE.
          i_out-nov = 0.
        ENDIF.
      ENDIF.

      IF i_out-des EQ 0.
        l_count1 = 12.
        IF l_count1 LE pa_datum+4(2).
          IF pa_afabe EQ '01'.
            IF wa_itab-zujhr EQ pa_datum(4).
              IF l_perio EQ 0.
                i_out-des = 0.
              ELSE.
                IF pa_datum(6) GE l_date3.
                  IF lf_spmon1 GT pa_datum(6).
                    i_out-des = l_acquv / i_out-perio.
                  ELSE.
                    i_out-des = 0.
                  ENDIF.
                ELSE.
                  i_out-des = 0.
                ENDIF.
*                  i_out-des = l_acquv / l_perio.
              ENDIF.
            ELSE.
*                i_out-des = wa_itab-nafap / 12.
*   Sementara by budi
*****              IF lf_spmon1 GT pa_datum(6).   "Comment 8010 24/04/2008
              IF l_period GT pa_datum(6).
                i_out-des = wa_itab-nafap / 12.
              ELSE.
                i_out-des = 0.
              ENDIF.
            ENDIF.
          ELSE.
            i_out-des = l_nafag.
          ENDIF.
        ELSE.
          i_out-des = 0.
        ENDIF.
      ENDIF.

* Penambahan kondisi jika Purch. Price & Acc. Depric eq 0
      IF l_acquv EQ 0.
        l_acquv = wa_itab-kansw.
      ENDIF.
      IF l_acdep EQ 0.
        IF wa_itab-nafav NE 0.
          l_acdep = ( wa_itab-nafav + wa_itab-nafal ) * -1.
        ELSE.
          IF wa_itab-answl NE 0 AND
            wa_itab-kansw EQ 0.
            l_acdep = ( wa_itab-nafav + wa_itab-nafal ) * -1.
** Koreksi by Paulus
*          ELSE.
*            IF wa_itab-knafa NE 0.
*              l_acdep = wa_itab-knafa * -1.
*            ENDIF.
** End koreksi
          ENDIF.
        ENDIF.
      ENDIF.
* End tambahan

*      i_out-acquv = l_acquv * 100.
      i_out-acquv = l_acquv.

      IF i_out-acquv EQ 0.
        i_out-acdep = 0.
        i_out-nafap = 0.
      ELSE.
*        i_out-acdep = l_acdep * 100.
*        i_out-nafap = l_nafap * 100.
        i_out-acdep = l_acdep.
        i_out-nafap = l_nafap.
      ENDIF.

      CASE pa_datum+4(2).
        WHEN 01.
          IF pa_afabe EQ '01'.
*            i_out-nafag = abs( i_out-jan * 100 ).
*          ELSE.
*            i_out-nafag = i_out-jan * 100.
            i_out-nafag = i_out-jan.
          ENDIF.
        WHEN 02.
          IF pa_afabe EQ '01'.
*            i_out-nafag = abs( i_out-feb * 100 ).
*          ELSE.
*            i_out-nafag = i_out-feb * 100.
            i_out-nafag = i_out-feb.
          ENDIF.
        WHEN 03.
          IF pa_afabe EQ '01'.
*            i_out-nafag = abs( i_out-mar * 100 ).
*          ELSE.
*            i_out-nafag = i_out-mar * 100.
            i_out-nafag = i_out-mar.
          ENDIF.
        WHEN 04.
          IF pa_afabe EQ '01'.
*            i_out-nafag = abs( i_out-apr * 100 ).
*          ELSE.
*           i_out-nafag = i_out-apr * 100.
            i_out-nafag = i_out-apr.
          ENDIF.
        WHEN 05.
          IF pa_afabe EQ '01'.
*            i_out-nafag = abs( i_out-mei * 100 ).
*          ELSE.
*            i_out-nafag = i_out-mei * 100.
            i_out-nafag = i_out-mei.
          ENDIF.
        WHEN 06.
          IF pa_afabe EQ '01'.
*            i_out-nafag = abs( i_out-jun * 100 ).
*          ELSE.
*            i_out-nafag = i_out-jun * 100.
            i_out-nafag = i_out-jun.
          ENDIF.
        WHEN 07.
          IF pa_afabe EQ '01'.
*            i_out-nafag = abs( i_out-jul * 100 ).
*          ELSE.
*            i_out-nafag = i_out-jul * 100.
            i_out-nafag = i_out-jul.
          ENDIF.
        WHEN 08.
          IF pa_afabe EQ '01'.
*            i_out-nafag = abs( i_out-aug * 100 ).
*          ELSE.
*            i_out-nafag = i_out-aug * 100.
            i_out-nafag = i_out-aug.
          ENDIF.
        WHEN 09.
          IF pa_afabe EQ '01'.
*            i_out-nafag = abs( i_out-sep * 100 ).
*          ELSE.
*            i_out-nafag = i_out-sep * 100.
            i_out-nafag = i_out-sep.
          ENDIF.
        WHEN 10.
          IF pa_afabe EQ '01'.
*            i_out-nafag = abs( i_out-okt * 100 ).
*          ELSE.
*            i_out-nafag = i_out-okt * 100.
            i_out-nafag = i_out-okt.
          ENDIF.
        WHEN 11.
          IF pa_afabe EQ '01'.
*            i_out-nafag = abs( i_out-nov * 100 ).
*          ELSE.
*            i_out-nafag = i_out-nov * 100.
            i_out-nafag = i_out-nov.
          ENDIF.
        WHEN 12.
          IF pa_afabe EQ '01'.
*            i_out-nafag = abs( i_out-des * 100 ).
*          ELSE.
*            i_out-nafag = i_out-des * 100.
            i_out-nafag = i_out-des.
          ENDIF.
      ENDCASE.

      IF pa_afabe EQ '01'.
        IF wa_itab-nafap = 0.
          i_out-acdep = i_out-acquv.
          i_out-nafap = 0.
          i_out-nafag = 0.
          i_out-knafa = 0.
        ENDIF.
      ELSE.
        IF i_out-acdep = 0.
*          i_out-acdep = ( wa_itab-safav + wa_itab-safal ) * -100.
          i_out-acdep = ( wa_itab-safav + wa_itab-safal ) * -1.
        ENDIF.
      ENDIF.

* Penambahan kondisi untuk No depreciation and no interest
      IF wa_itab-afasl EQ '0000' AND
         ( pa_bukrs NE '8010' AND pa_bukrs NE '8360' ).
        i_out-acdep = 0.
        i_out-nafap = 0.
      ENDIF.
* end tambah

      IF lf_spmon1 GT pa_datum(6).
        IF l_period LT pa_datum(6) AND
           l_sw IS INITIAL.
          i_out-nafap = i_out-nafap - i_out-nafag.
          i_out-nafag = 0.
        ENDIF.
      ELSE.
        i_out-nafag = 0.
      ENDIF.

      CLEAR: lf_spmon1.

      DATA: l_nafav  LIKE anlc-nafav,
            l_nafal  LIKE anlc-nafal,
            l_nafav1 TYPE p DECIMALS 0,
            l_nafal1 TYPE p DECIMALS 0.

      IF i_out-nafav NE 0 AND
        i_out-nafal NE 0.
        READ TABLE i_anep INTO wa_anep WITH KEY anln1 = i_out-anln1
                                                anln2 = i_out-anln2
                                                gjahr = pa_datum(4)
                                                afabe = pa_afabe
                                                bwasl = '300'.
        IF sy-subrc EQ 0.
          IF pa_datum(6) GE wa_anep-bzdat(6).
*            l_nafav = i_out-nafav * 100.
*            l_nafal = i_out-nafal * 100.
            l_nafav = i_out-nafav.
            l_nafal = i_out-nafal.
            l_nafav1 = l_nafav.
            l_nafal1 = l_nafal.
            i_out-nafap = i_out-nafap - ( l_nafav1 + l_nafal1 ).
          ENDIF.
        ENDIF.
      ENDIF.

      IF pa_bukrs = '8010'.
        CLEAR wa_anlp3.
        READ TABLE i_anlp3 INTO wa_anlp3
                            WITH KEY bukrs = pa_bukrs
                                     gjahr = pa_datum(4)
                                     anln1 = i_out-anln1
                                     anln2 = i_out-anln2
                                     BINARY SEARCH.
        i_out-nafap = wa_anlp3-nafaz.
      ENDIF.

      i_out-bwasl = l_bwasl.
      i_out-knafa = i_out-acdep + i_out-nafap.
      i_out-bookv = i_out-acquv - i_out-acdep - i_out-nafap.

      APPEND i_out.

      CLEAR: i_out-jan, i_out-feb, i_out-mar, i_out-apr, i_out-mei,
             i_out-jun, i_out-jul, i_out-aug, i_out-sep, i_out-okt,
             i_out-nov, i_out-des.
      CLEAR: i_out-perio, l_sw.
    ENDIF.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " process_01

*&---------------------------------------------------------------------*
*&      Form  fieldcat_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fieldcat_build TABLES ft_report.
  DATA: xfieldcat TYPE slis_fieldcat_alv.

  DATA: l_nafap(20),
        l_acdep(22),
        l_knafa(22),
        l_bookv(22),
        l_nafag(24),
        l_year(4),
        l_date(10),
        l_date_in   LIKE sy-datum,
        l_date_out  LIKE sy-datum.

  l_year = pa_datum(4) - 1.
  CONCATENATE '31/12/' l_year INTO l_acdep.
  CONCATENATE 'Acc.Depric.' l_acdep INTO l_acdep
    SEPARATED BY space.

  CONCATENATE pa_datum(4) pa_datum+4(2) '01' INTO l_date_in.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = l_date_in
    IMPORTING
      last_day_of_month = l_date_out.
  CONCATENATE l_date_out+6(2) l_date_out+4(2) l_date_out(4)
    INTO l_date
    SEPARATED BY '/'.
  CONCATENATE 'Acc.Depric.' l_date INTO l_knafa
    SEPARATED BY space.
  CONCATENATE 'Book Value' l_date INTO l_bookv
    SEPARATED BY space.
  CONCATENATE l_date+3(2) l_date+6(4) INTO l_nafag
    SEPARATED BY '-'.
  CONCATENATE 'Deprc. Mth :' l_nafag INTO l_nafag
    SEPARATED BY space.
  CONCATENATE 'Depric Year :' pa_datum(4) INTO l_nafap
    SEPARATED BY space.

  PERFORM f_fieldcatg USING ft_report:
    'ANLN1' 'ANLC' 'ANLN1' '' '' '' '' '' '' '' '' '' '' '' 'X',
    'ANLN2' 'ANLC' 'ANLN2' '' '' '' '' '' '' '' '' '' '' '' 'X',
    'TXT50' '' '' '' '' 'Name Fixed Asset' '' '' '' '' '' '' '' '' '',
    'TXA50' '' '' '' '' 'Additional Description' '' '' '' '' '' '' '' '' '',
    'PER01' '' '' '' '' 'Year of acq.' '' '' '' '' '' '' '' '' '',
    'ACQUV' '' '' '' '' 'Purch.Pric' 'X' '' '' '' '' '' '' '' '',
    'MONTH' '' '' '' '' 'Month' '' '' '' '' '' '' '' '' '',
    'ACDEP' '' '' '' '' l_acdep 'X' '' '' '' '' '' '' '' '',
    'NAFAP' '' '' '' '' l_nafap 'X' '' '' '' '' '' '' '' '',
    'NAFAG' '' '' '' '' l_nafag 'X' '' '' '' '' '' '' '' '',
    'BOOKV' '' '' '' '' l_bookv 'X' '' '' '' '' '' '' '' '',

    'ORD41' 'ANLA' 'ORD41' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'MENGE' 'ANLA' 'MENGE' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'MEINS' 'ANLA' 'MEINS' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'ORD42' 'ANLA' 'ORD42' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'EAUFN' 'ANLA' 'EAUFN' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'BUKRS' 'ANLC' 'BUKRS' 'X' '' '' '' '' '' '' '' '' '' '' 'X',
    'PERIO' '' '' 'X' '' 'Period' '' '' '' '' '' '' '' '' '',
    'GJAHR' 'ANLC' 'GJAHR' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'AFABE' 'ANLC' 'AFABE' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'KANSW' 'ANLC' 'KANSW' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'KNAFA' '' '' 'X' '' l_knafa '' '' '' '' '' '' '' '' '',
    'ANSWL' 'ANLC' 'ANSWL' 'X' '' '' 'X' '' '' 'IDR' '' '' '' '' '',
    'NAFAV' 'ANLC' 'NAFAV' 'X' '' '' 'X' '' '' 'IDR' '' '' '' '' '',
    'NAFAL' 'ANLC' 'NAFAL' 'X' '' '' 'X' '' '' 'IDR' '' '' '' '' '',
    'KSAFA' 'ANLC' 'KSAFA' 'X' '' '' 'X' '' '' 'IDR' '' '' '' '' '',
    'SAFAP' 'ANLC' 'SAFAP' 'X' '' '' 'X' '' '' 'IDR' '' '' '' '' '',
    'SAFAV' 'ANLC' 'SAFAV' 'X' '' '' 'X' '' '' 'IDR' '' '' '' '' '',
    'SAFAL' 'ANLC' 'SAFAL' 'X' '' '' 'X' '' '' 'IDR' '' '' '' '' '',
    'KOSTL' 'ANLZ' 'KOSTL' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'GSBER' 'ANLZ' 'GSBER' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'CAUFN' 'ANLZ' 'CAUFN' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'AFABG' 'ANLB' 'AFABG' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'NDJAR' 'ANLB' 'NDJAR' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'NDPER' 'ANLB' 'NDPER' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'AFASL' 'ANLB' 'AFASL' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'ANLKL' 'ANLA' 'ANLKL' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'ZUGDT' 'ANLA' 'ZUGDT' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'AKTIV' 'ANLA' 'AKTIV' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'DEAKT' 'ANLA' 'DEAKT' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'LIFNR' 'ANLA' 'LIFNR' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'LFA1' 'NAME1' 'X' '' 'Vendor Name' '' '' '' '' '' '' '' '' '',
    'INVNR' 'ANLA' 'INVNR' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'VBUND' 'ANLA' 'VBUND' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'SERNR' 'ANLA' 'SERNR' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'AIBN1' 'ANLA' 'AIBN1' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'AIBN2' 'ANLA' 'AIBN2' 'X' '' 'SNo OriAsset' '' '' '' '' '' '' '' '' '',
    'BWASL' 'ANEP' 'BWASL' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'JAN' 'ANLP' 'NAFAZ' 'X' '' 'Januari' 'X' '' '' 'IDR' '' '' '' '' '',
    'FEB' 'ANLP' 'NAFAZ' 'X' '' 'Februari' 'X' '' '' 'IDR' '' '' '' '' '',
    'MAR' 'ANLP' 'NAFAZ' 'X' '' 'Maret' 'X' '' '' 'IDR' '' '' '' '' '',
    'APR' 'ANLP' 'NAFAZ' 'X' '' 'April' 'X' '' '' 'IDR' '' '' '' '' '',
    'MEI' 'ANLP' 'NAFAZ' 'X' '' 'Mei' 'X' '' '' 'IDR' '' '' '' '' '',
    'JUN' 'ANLP' 'NAFAZ' 'X' '' 'Juni' 'X' '' '' 'IDR' '' '' '' '' '',
    'JUL' 'ANLP' 'NAFAZ' 'X' '' 'Juli' 'X' '' '' 'IDR' '' '' '' '' '',
    'AUG' 'ANLP' 'NAFAZ' 'X' '' 'Agustus' 'X' '' '' 'IDR' '' '' '' '' '',
    'SEP' 'ANLP' 'NAFAZ' 'X' '' 'September' 'X' '' '' 'IDR' '' '' '' '' '',
    'OKT' 'ANLP' 'NAFAZ' 'X' '' 'Oktober' 'X' '' '' 'IDR' '' '' '' '' '',
    'NOV' 'ANLP' 'NAFAZ' 'X' '' 'November' 'X' '' '' 'IDR' '' '' '' '' '',
    'DES' 'ANLP' 'NAFAZ' 'X' '' 'Desember' 'X' '' '' 'IDR' '' '' '' '' ''.
ENDFORM.                    " fieldcat_build

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    VALUE(fu_types)
                          VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_fltxt)
                          VALUE(fu_dosum)
                          VALUE(fu_hotsp)
                          VALUE(fu_dec)
                          VALUE(fu_waers)
                          VALUE(fu_meins)
                          VALUE(fu_waers_f)
                          VALUE(fu_meins_f)
                          VALUE(fu_checkbox)
                          VALUE(fu_key).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_tabname       = fu_reftb.
  ld_fieldcat-ref_fieldname     = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-seltext_l         = fu_fltxt.
  ld_fieldcat-seltext_m         = fu_fltxt.
  ld_fieldcat-seltext_s         = fu_fltxt.
  ld_fieldcat-reptext_ddic      = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_out      = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-key               = fu_key.
  APPEND ld_fieldcat TO i_fieldcat_alv.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

**&---------------------------------------------------------------------*
**&      Form  fieldcat_build
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*FORM fieldcat_build.
*  DATA: l_nafap(20),
*        l_acdep(22),
*        l_knafa(22),
*        l_bookv(22),
*        l_nafag(24),
*        l_year(4),
*        l_date(10),
*        l_date_in  LIKE sy-datum,
*        l_date_out LIKE sy-datum.
*
*  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
*    EXPORTING
*      i_program_name     = w_repid
*      i_internal_tabname = 'I_OUT'
*      i_inclname         = w_repid
*    CHANGING
*      ct_fieldcat        = i_fieldcat_alv.
*
*  l_year = pa_datum(4) - 1.
*  CONCATENATE '31/12/' l_year INTO l_acdep.
*  CONCATENATE 'Acc.Depric.' l_acdep INTO l_acdep
*    SEPARATED BY space.
*
*  CONCATENATE pa_datum(4) pa_datum+4(2) '01' INTO l_date_in.
*  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
*    EXPORTING
*      day_in            = l_date_in
*    IMPORTING
*      last_day_of_month = l_date_out.
*  CONCATENATE l_date_out+6(2) l_date_out+4(2) l_date_out(4)
*    INTO l_date
*    SEPARATED BY '/'.
*  CONCATENATE 'Acc.Depric.' l_date INTO l_knafa
*    SEPARATED BY space.
*  CONCATENATE 'Book Value' l_date INTO l_bookv
*    SEPARATED BY space.
*  CONCATENATE l_date+3(2) l_date+6(4) INTO l_nafag
*    SEPARATED BY '-'.
*  CONCATENATE 'Deprc. Mth :' l_nafag INTO l_nafag
*    SEPARATED BY space.
*
** Modify displayed fields
*  LOOP AT i_fieldcat_alv INTO w_fieldcat_alv.
*    CASE w_fieldcat_alv-fieldname.
*      WHEN 'ANLN1'.
*        w_fieldcat_alv-hotspot      = 'X'.
*        w_fieldcat_alv-reptext_ddic = 'No.Asset'.
*        w_fieldcat_alv-seltext_s    = 'No.Asset'.
*        w_fieldcat_alv-seltext_m    = 'No.Asset'.
*        w_fieldcat_alv-seltext_l    = 'No.Asset'.
*      WHEN 'ANLN2'.
*      WHEN 'TXT50'.
*        w_fieldcat_alv-reptext_ddic = 'Name Fixed Asset'.
*        w_fieldcat_alv-seltext_s    = 'Name Fixed Asset'.
*        w_fieldcat_alv-seltext_m    = 'Name Fixed Asset'.
*        w_fieldcat_alv-seltext_l    = 'Name Fixed Asset'.
*      WHEN 'PER01'.
*        w_fieldcat_alv-reptext_ddic = 'Year of acq.'.
*      WHEN 'ACQUV'.
*        w_fieldcat_alv-reptext_ddic = 'Purch.Pric'.
*        w_fieldcat_alv-seltext_s    = 'Purch.Pric'.
*        w_fieldcat_alv-seltext_m    = 'Purch.Pric'.
*        w_fieldcat_alv-seltext_l    = 'Purch.Pric'.
*        w_fieldcat_alv-do_sum       = 'X'.
**      WHEN 'PERIO'.
*      WHEN 'MONTH'.
*        w_fieldcat_alv-reptext_ddic = 'Month'.
*        w_fieldcat_alv-seltext_s    = 'Month'.
*        w_fieldcat_alv-seltext_m    = 'Month'.
*        w_fieldcat_alv-seltext_l    = 'Month'.
*      WHEN 'ACDEP'.
*        w_fieldcat_alv-seltext_l    = l_acdep.
*        w_fieldcat_alv-do_sum       = 'X'.
*      WHEN 'NAFAP'.
*        CONCATENATE 'Depric Year :' pa_datum(4) INTO l_nafap
*          SEPARATED BY space.
*        w_fieldcat_alv-seltext_l    = l_nafap.
*        w_fieldcat_alv-do_sum       = 'X'.
*      WHEN 'NAFAG'.
*        w_fieldcat_alv-seltext_l    = l_nafag.
*        w_fieldcat_alv-do_sum       = 'X'.
*      WHEN 'BOOKV'.
*        w_fieldcat_alv-seltext_l    = l_bookv.
*        w_fieldcat_alv-do_sum       = 'X'.
*      WHEN 'KNAFA'.
*        w_fieldcat_alv-seltext_l    = l_knafa.
*        w_fieldcat_alv-no_out       = 'X'.
*        w_fieldcat_alv-do_sum       = 'X'.
*      WHEN 'PERIO'.
*        w_fieldcat_alv-reptext_ddic = 'Period'.
*        w_fieldcat_alv-seltext_s    = 'Period'.
*        w_fieldcat_alv-seltext_m    = 'Period'.
*        w_fieldcat_alv-seltext_l    = 'Period'.
*        w_fieldcat_alv-no_out       = 'X'.
*      WHEN 'JAN'.
*        w_fieldcat_alv-reptext_ddic = 'Januari'.
*        w_fieldcat_alv-seltext_s    = 'Januari'.
*        w_fieldcat_alv-seltext_m    = 'Januari'.
*        w_fieldcat_alv-seltext_l    = 'Januari'.
*        w_fieldcat_alv-currency     = 'IDR'.
*        w_fieldcat_alv-no_out       = 'X'.
*      WHEN 'FEB'.
*        w_fieldcat_alv-reptext_ddic = 'Februari'.
*        w_fieldcat_alv-seltext_s    = 'Februari'.
*        w_fieldcat_alv-seltext_m    = 'Februari'.
*        w_fieldcat_alv-seltext_l    = 'Februari'.
*        w_fieldcat_alv-currency     = 'IDR'.
*        w_fieldcat_alv-no_out       = 'X'.
*      WHEN 'MAR'.
*        w_fieldcat_alv-reptext_ddic = 'Maret'.
*        w_fieldcat_alv-seltext_s    = 'Maret'.
*        w_fieldcat_alv-seltext_m    = 'Maret'.
*        w_fieldcat_alv-seltext_l    = 'Maret'.
*        w_fieldcat_alv-currency     = 'IDR'.
*        w_fieldcat_alv-no_out       = 'X'.
*      WHEN 'APR'.
*        w_fieldcat_alv-reptext_ddic = 'April'.
*        w_fieldcat_alv-seltext_s    = 'April'.
*        w_fieldcat_alv-seltext_m    = 'April'.
*        w_fieldcat_alv-seltext_l    = 'April'.
*        w_fieldcat_alv-currency     = 'IDR'.
*        w_fieldcat_alv-no_out       = 'X'.
*      WHEN 'MEI'.
*        w_fieldcat_alv-reptext_ddic = 'Mei'.
*        w_fieldcat_alv-seltext_s    = 'Mei'.
*        w_fieldcat_alv-seltext_m    = 'Mei'.
*        w_fieldcat_alv-seltext_l    = 'Mei'.
*        w_fieldcat_alv-currency     = 'IDR'.
*        w_fieldcat_alv-no_out       = 'X'.
*      WHEN 'JUN'.
*        w_fieldcat_alv-reptext_ddic = 'Juni'.
*        w_fieldcat_alv-seltext_s    = 'Juni'.
*        w_fieldcat_alv-seltext_m    = 'Juni'.
*        w_fieldcat_alv-seltext_l    = 'Juni'.
*        w_fieldcat_alv-currency     = 'IDR'.
*        w_fieldcat_alv-no_out       = 'X'.
*      WHEN 'JUL'.
*        w_fieldcat_alv-reptext_ddic = 'Juli'.
*        w_fieldcat_alv-seltext_s    = 'Juli'.
*        w_fieldcat_alv-seltext_m    = 'Juli'.
*        w_fieldcat_alv-seltext_l    = 'Juli'.
*        w_fieldcat_alv-currency     = 'IDR'.
*        w_fieldcat_alv-no_out       = 'X'.
*      WHEN 'AUG'.
*        w_fieldcat_alv-reptext_ddic = 'Agustus'.
*        w_fieldcat_alv-seltext_s    = 'Agustus'.
*        w_fieldcat_alv-seltext_m    = 'Agustus'.
*        w_fieldcat_alv-seltext_l    = 'Agustus'.
*        w_fieldcat_alv-currency     = 'IDR'.
*        w_fieldcat_alv-no_out       = 'X'.
*      WHEN 'SEP'.
*        w_fieldcat_alv-reptext_ddic = 'September'.
*        w_fieldcat_alv-seltext_s    = 'September'.
*        w_fieldcat_alv-seltext_m    = 'September'.
*        w_fieldcat_alv-seltext_l    = 'September'.
*        w_fieldcat_alv-currency     = 'IDR'.
*        w_fieldcat_alv-no_out       = 'X'.
*      WHEN 'OKT'.
*        w_fieldcat_alv-reptext_ddic = 'Oktober'.
*        w_fieldcat_alv-seltext_s    = 'Oktober'.
*        w_fieldcat_alv-seltext_m    = 'Oktober'.
*        w_fieldcat_alv-seltext_l    = 'Oktober'.
*        w_fieldcat_alv-currency     = 'IDR'.
*        w_fieldcat_alv-no_out       = 'X'.
*      WHEN 'NOV'.
*        w_fieldcat_alv-reptext_ddic = 'November'.
*        w_fieldcat_alv-seltext_s    = 'November'.
*        w_fieldcat_alv-seltext_m    = 'November'.
*        w_fieldcat_alv-seltext_l    = 'November'.
*        w_fieldcat_alv-currency     = 'IDR'.
*        w_fieldcat_alv-no_out       = 'X'.
*      WHEN 'DES'.
*        w_fieldcat_alv-reptext_ddic = 'Desember'.
*        w_fieldcat_alv-seltext_s    = 'Desember'.
*        w_fieldcat_alv-seltext_m    = 'Desember'.
*        w_fieldcat_alv-seltext_l    = 'Desember'.
*        w_fieldcat_alv-currency     = 'IDR'.
*        w_fieldcat_alv-no_out       = 'X'.
*      WHEN OTHERS.
*        w_fieldcat_alv-do_sum       = 'X'.
*        w_fieldcat_alv-no_out       = 'X'.
*        w_fieldcat_alv-currency     = 'IDR'.
*    ENDCASE.
*
*    MODIFY i_fieldcat_alv FROM w_fieldcat_alv.
*  ENDLOOP.
*ENDFORM.                    " fieldcat_build

*&---------------------------------------------------------------------*
*&      Form  event_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM event_build.
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = i_events.

  READ TABLE i_events WITH KEY name = slis_ev_top_of_page
    INTO w_events.
  IF sy-subrc = 0.
    MOVE 'ALV_TOP_OF_PAGE' TO w_events-form.
    MODIFY i_events FROM w_events INDEX sy-tabix.
  ENDIF.
ENDFORM.                    " event_build

*&---------------------------------------------------------------------*
*&      Form  layout_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM layout_build.
  w_layout-zebra                = 'X'.
  w_layout-colwidth_optimize    = 'X'.
  w_layout-detail_popup         = 'X'.
  w_layout-detail_initial_lines = 'X'.
  w_layout-detail_titlebar      = 'Detail Title Bar'.
ENDFORM.                    " layout_build

*&---------------------------------------------------------------------*
*&      Form  display_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_data.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_background_id         = 'ALV_BACKGROUND'
      i_callback_program      = w_repid
      i_callback_user_command = w_callback_ucomm
      is_layout               = w_layout
      is_print                = w_print
      i_save                  = 'A'
      is_variant              = w_variant
      it_events               = i_events[]
      it_fieldcat             = i_fieldcat_alv[]
      it_sort                 = ta_sort[]
    TABLES
      t_outtab                = i_out.
*    EXCEPTIONS
*      PROGRAM_ERROR = 1
*      OTHERS        = 2.
ENDFORM.                    " display_data

*---------------------------------------------------------------------*
*       FORM ALV_TOP_OF_PAGE                                          *
*---------------------------------------------------------------------*
FORM alv_top_of_page.
  DATA: l_date(15),
        l_time(15),
        l_peraf_low(10),
        l_anlkl_low(20),
        l_anlkl_high(20),
        l_kostl_low(20),
        l_kostl_high(20),
        report1(25),    "Company code
        report2(30),    "Business area
        report3(60),    "Period
        report4(60),    "Asset class
        report4a(60),   "Asset class
        report5(60),    "Cost center
        report5a(60),   "Cost center
        report6(60),    "Depriciation area
        report7(50).    "Process

  WRITE sy-datum TO l_date.
  WRITE sy-uzeit TO l_time.

* Company code
  SELECT SINGLE butxt
    FROM t001
    INTO report1
    WHERE bukrs EQ pa_bukrs.

* Business area
  IF so_gsber-low NE space.
    SELECT SINGLE gtext
      FROM tgsbt
      INTO report2
      WHERE spras EQ sy-langu AND
            gsber EQ so_gsber-low.
  ELSE.
    MOVE 'All Business Area' TO report2.
  ENDIF.

* Period
  READ TABLE i_t247 INTO wa_t247
    WITH KEY spras = sy-langu
             mnr   = pa_datum+4(2).
  IF sy-subrc EQ 0.
    l_peraf_low = wa_t247-ltx.
  ENDIF.
  CONCATENATE 'Daftar Asset Periode :' l_peraf_low pa_datum(4)
    INTO report3
    SEPARATED BY space.

* Asset Class
  IF so_anlkl-low NE space.
    SELECT SINGLE txk20
      FROM ankt
      INTO l_anlkl_low
      WHERE spras EQ sy-langu AND
            anlkl EQ so_anlkl-low.
    IF so_anlkl-high NE space.
      SELECT SINGLE txk20
        FROM ankt
        INTO l_anlkl_high
        WHERE spras EQ sy-langu AND
              anlkl EQ so_anlkl-high.
      CONCATENATE 'Asset class :' so_anlkl-low '-' l_anlkl_low '  TO'
        INTO report4
        SEPARATED BY space.
      CONCATENATE '                       ' so_anlkl-high '-'
                  l_anlkl_high
        INTO report4a
        SEPARATED BY space.
    ELSE.
      CONCATENATE 'Asset class :' so_anlkl-low '-' l_anlkl_low
        INTO report4
        SEPARATED BY space.
    ENDIF.
  ENDIF.

* Cost Center
  IF so_kostl-low NE space.
    SELECT SINGLE ktext
      FROM cskt
      INTO l_kostl_low
      WHERE spras EQ sy-langu AND
            kokrs EQ '8010'   AND
            kostl EQ so_kostl-low.
    IF so_kostl-high NE space.
      SELECT SINGLE ktext
        FROM cskt
        INTO l_kostl_high
        WHERE spras EQ sy-langu AND
              kokrs EQ '8010'   AND
              kostl EQ so_kostl-high.
      CONCATENATE 'Cost center :' so_kostl-low '-' l_kostl_low '  TO'
        INTO report5
        SEPARATED BY space.
      CONCATENATE '                       ' so_kostl-high '-'
                  l_kostl_high
        INTO report5a
        SEPARATED BY space.
    ELSE.
      CONCATENATE 'Cost center :' so_kostl-low '-' l_kostl_low
        INTO report5
        SEPARATED BY space.
    ENDIF.
  ENDIF.

* Depriciation Area
  SELECT SINGLE afbktx
    FROM t093t
    INTO report6
    WHERE spras  EQ sy-langu  AND
          afapl  EQ 'TSPC'    AND
          afaber EQ pa_afabe.
  CONCATENATE 'Depriciation area :' pa_afabe '-' report6
    INTO report6
    SEPARATED BY space.

* Tanggal Proses
  CONCATENATE 'Creation date :' l_date '-' l_time INTO report7
    SEPARATED BY space.

* List Header
  w_list_comments-typ  = 'H'.
  w_list_comments-info = report1.
  APPEND w_list_comments TO i_list_comments.

  w_list_comments-typ  = 'H'.
  w_list_comments-info = report2.
  APPEND w_list_comments TO i_list_comments.

  w_list_comments-typ  = 'H'.
  w_list_comments-info = report3.
  APPEND w_list_comments TO i_list_comments.

  IF report4 NE space.
    w_list_comments-typ  = 'S'.
    w_list_comments-info = report4.
    APPEND w_list_comments TO i_list_comments.
  ENDIF.

  IF report4a NE space.
    w_list_comments-typ  = 'S'.
    w_list_comments-info = report4a.
    APPEND w_list_comments TO i_list_comments.
  ENDIF.

  IF report5 NE space.
    w_list_comments-typ  = 'S'.
    w_list_comments-info = report5.
    APPEND w_list_comments TO i_list_comments.
  ENDIF.

  IF report5a NE space.
    w_list_comments-typ  = 'S'.
    w_list_comments-info = report5a.
    APPEND w_list_comments TO i_list_comments.
  ENDIF.

  w_list_comments-typ  = 'S'.
  w_list_comments-info = report6.
  APPEND w_list_comments TO i_list_comments.

  w_list_comments-typ  = 'A'.
  w_list_comments-info = report7.
  APPEND w_list_comments TO i_list_comments.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = i_list_comments.
  CLEAR i_list_comments.
ENDFORM.                    "alv_top_of_page

*---------------------------------------------------------------------*
*       FORM user_command                                             *
*---------------------------------------------------------------------*
FORM callback_ucomm  USING r_ucomm LIKE sy-ucomm
                           rs_selfield TYPE slis_selfield.

  DATA: l_anln1 LIKE anla-anln1,
        l_anln2 LIKE anla-anln2.

  rs_selfield-refresh = 'X'.
  CASE r_ucomm.
    WHEN  'FEHL' OR '&IC1'.
      READ TABLE i_out INDEX rs_selfield-tabindex.
      l_anln1 = i_out-anln1.
      l_anln2 = i_out-anln2.

      IF rs_selfield-tabindex NE 0.
        IF rs_selfield-fieldname EQ 'ANLN1'.
          SET PARAMETER ID 'BUK' FIELD pa_bukrs.
          SET PARAMETER ID 'AN1' FIELD i_out-anln1.
          SET PARAMETER ID 'AN2' FIELD i_out-anln2.
          CALL TRANSACTION 'AW01N' AND SKIP FIRST SCREEN.
        ENDIF.
      ELSE.
        MESSAGE e000(zf).
      ENDIF.
  ENDCASE.
ENDFORM.                    "callback_ucomm

*&---------------------------------------------------------------------*
*&      Form  fill_sort
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_sort.

ENDFORM.                    " fill_sort

*&---------------------------------------------------------------------*
*&      Form  isi_month
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM isi_month.
  DATA: l_count TYPE i.
  CLEAR: l_count.
  DO 12 TIMES.
    ADD 1 TO l_count.
    CASE l_count.
      WHEN 1.
        READ TABLE i_anlp2 INTO wa_anlp2
          WITH KEY bukrs = pa_bukrs
                   anln1 = wa_itab-anln1
                   anln2 = wa_itab-anln2
                   gjahr = pa_datum(4)
                   peraf = l_count.
        IF sy-subrc EQ 0.
          i_out-jan = wa_anlp2-nafaz.
        ENDIF.
      WHEN 2.
        READ TABLE i_anlp2 INTO wa_anlp2
          WITH KEY bukrs = pa_bukrs
                   anln1 = wa_itab-anln1
                   anln2 = wa_itab-anln2
                   gjahr = pa_datum(4)
                   peraf = l_count.
        IF sy-subrc EQ 0.
          i_out-feb = wa_anlp2-nafaz.
        ENDIF.
      WHEN 3.
        READ TABLE i_anlp2 INTO wa_anlp2
          WITH KEY bukrs = pa_bukrs
                   anln1 = wa_itab-anln1
                   anln2 = wa_itab-anln2
                   gjahr = pa_datum(4)
                   peraf = l_count.
        IF sy-subrc EQ 0.
          i_out-mar = wa_anlp2-nafaz.
        ENDIF.
      WHEN 4.
        READ TABLE i_anlp2 INTO wa_anlp2
          WITH KEY bukrs = pa_bukrs
                   anln1 = wa_itab-anln1
                   anln2 = wa_itab-anln2
                   gjahr = pa_datum(4)
                   peraf = l_count.
        IF sy-subrc EQ 0.
          i_out-apr = wa_anlp2-nafaz.
        ENDIF.
      WHEN 5.
        READ TABLE i_anlp2 INTO wa_anlp2
          WITH KEY bukrs = pa_bukrs
                   anln1 = wa_itab-anln1
                   anln2 = wa_itab-anln2
                   gjahr = pa_datum(4)
                   peraf = l_count.
        IF sy-subrc EQ 0.
          i_out-mei = wa_anlp2-nafaz.
        ENDIF.
      WHEN 6.
        READ TABLE i_anlp2 INTO wa_anlp2
          WITH KEY bukrs = pa_bukrs
                   anln1 = wa_itab-anln1
                   anln2 = wa_itab-anln2
                   gjahr = pa_datum(4)
                   peraf = l_count.
        IF sy-subrc EQ 0.
          i_out-jun = wa_anlp2-nafaz.
        ENDIF.
      WHEN 7.
        READ TABLE i_anlp2 INTO wa_anlp2
          WITH KEY bukrs = pa_bukrs
                   anln1 = wa_itab-anln1
                   anln2 = wa_itab-anln2
                   gjahr = pa_datum(4)
                   peraf = l_count.
        IF sy-subrc EQ 0.
          i_out-jul = wa_anlp2-nafaz.
        ENDIF.
      WHEN 8.
        READ TABLE i_anlp2 INTO wa_anlp2
          WITH KEY bukrs = pa_bukrs
                   anln1 = wa_itab-anln1
                   anln2 = wa_itab-anln2
                   gjahr = pa_datum(4)
                   peraf = l_count.
        IF sy-subrc EQ 0.
          i_out-aug = wa_anlp2-nafaz.
        ENDIF.
      WHEN 9.
        READ TABLE i_anlp2 INTO wa_anlp2
          WITH KEY bukrs = pa_bukrs
                   anln1 = wa_itab-anln1
                   anln2 = wa_itab-anln2
                   gjahr = pa_datum(4)
                   peraf = l_count.
        IF sy-subrc EQ 0.
          i_out-sep = wa_anlp2-nafaz.
        ENDIF.
      WHEN 10.
        READ TABLE i_anlp2 INTO wa_anlp2
          WITH KEY bukrs = pa_bukrs
                   anln1 = wa_itab-anln1
                   anln2 = wa_itab-anln2
                   gjahr = pa_datum(4)
                   peraf = l_count.
        IF sy-subrc EQ 0.
          i_out-okt = wa_anlp2-nafaz.
        ENDIF.
      WHEN 11.
        READ TABLE i_anlp2 INTO wa_anlp2
          WITH KEY bukrs = pa_bukrs
                   anln1 = wa_itab-anln1
                   anln2 = wa_itab-anln2
                   gjahr = pa_datum(4)
                   peraf = l_count.
        IF sy-subrc EQ 0.
          i_out-nov = wa_anlp2-nafaz.
        ENDIF.
      WHEN 12.
        READ TABLE i_anlp2 INTO wa_anlp2
          WITH KEY bukrs = pa_bukrs
                   anln1 = wa_itab-anln1
                   anln2 = wa_itab-anln2
                   gjahr = pa_datum(4)
                   peraf = l_count.
        IF sy-subrc EQ 0.
          i_out-des = wa_anlp2-nafaz.
        ENDIF.
    ENDCASE.
  ENDDO.
ENDFORM.                    " isi_month

*&---------------------------------------------------------------------*
*&      Form  process_10
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_10.
  DATA: l_acquv    TYPE p DECIMALS 5,
        l_acquv1   TYPE p DECIMALS 5,
        l_nafag    TYPE p DECIMALS 5,
        l_acdep    TYPE p DECIMALS 5,
        l_nafap    TYPE p DECIMALS 5,
        l_anbtr    LIKE anep-anbtr,
        l_usfl     TYPE i,
        l_perio(5),
        l_period   LIKE pc260-fpper,
        l_datum    TYPE i,
        l_count    TYPE i,
        l_year(4),
        l_date1(6),
        l_date2(6),
        l_month    TYPE i.

  CLEAR: wa_itab.
  SORT i_itab BY bukrs gjahr anln1 anln2.
  LOOP AT i_itab INTO wa_itab.

    MOVE-CORRESPONDING wa_itab TO i_out.
    MOVE pa_datum(6) TO l_date1.
    CONCATENATE wa_itab-aktiv(4) wa_itab-aktiv+4(2) INTO l_date2.
    SELECT SINGLE afabg
      FROM anlb
      INTO wa_itab-afabg
      WHERE bukrs EQ pa_bukrs      AND
            anln1 EQ wa_itab-anln1 AND
            anln2 EQ wa_itab-anln2 AND
            afabe EQ '01'.

    CLEAR i_lfa1.
    READ TABLE i_lfa1 WITH KEY lifnr = i_out-lifnr.
    i_out-name1 = i_lfa1-name1.

    l_date2 = wa_itab-afabg(6).

    l_acquv     = wa_itab-kansw + wa_itab-answl.

    IF l_acquv EQ 0.
      CLEAR: wa_anep.
      LOOP AT i_anep INTO wa_anep
        WHERE bukrs EQ pa_bukrs      AND
              anln1 EQ wa_itab-anln1 AND
              anln2 EQ wa_itab-anln2 AND
              afabe EQ pa_afabe.
        ADD wa_anep-anbtr TO l_acquv.
        CLEAR: wa_anep.
      ENDLOOP.
    ENDIF.

    CLEAR: wa_anep1.
    LOOP AT i_anep1 INTO wa_anep1
      WHERE bukrs EQ pa_bukrs      AND
            anln1 EQ wa_itab-anln1 AND
            anln2 EQ wa_itab-anln2 AND
            afabe EQ pa_afabe.
      ADD wa_anep1-anbtr TO l_anbtr.
      CLEAR: wa_anep1.
    ENDLOOP.

    l_acquv = l_acquv - l_anbtr.
    CLEAR: l_anbtr.

    l_acquv1    = l_acquv.

* Penambahan kondisi jika Purch. Price & Acc. Depric eq 0
    IF l_acquv EQ 0.
      l_acquv = wa_itab-kansw.
      l_acquv1 = l_acquv.
    ENDIF.
* End tambahan

    l_usfl   = ( wa_itab-ndjar * 12 ) + wa_itab-ndper.
    i_out-month = l_usfl.

* Penambahan kondisi untuk depreciation key
    IF wa_itab-afasl EQ 'ZT01'.
      l_acquv = l_acquv * 50 / 100.
    ENDIF.
* End tambahan

    READ TABLE i_t247 INTO wa_t247
      WITH KEY spras = sy-langu
               mnr   = wa_itab-afabg+4(2).

    IF sy-subrc EQ 0.
      i_out-per01 = wa_t247-ktx.
    ELSE.
      i_out-per01 = space.
    ENDIF.
    CONCATENATE i_out-per01 wa_itab-afabg(4) INTO i_out-per01
      SEPARATED BY space.

    i_out-perio = ( wa_itab-ndjar * 12 ) + wa_itab-ndper.

    IF i_out-perio NE 0.
      l_nafag = l_acquv / i_out-perio.
    ELSE.
      l_nafag = 0.
    ENDIF.

*    l_year  = pa_datum(4).
*    l_month = 12.
*    l_perio = ( ( l_year - wa_itab-afabg(4) ) * 12 ) + 1.
*    l_perio = l_perio + l_month - wa_itab-afabg+4(2).
*    IF l_perio LE i_out-perio.

    l_usfl = l_usfl - 1.
    l_period = wa_itab-afabg(6).
    CALL FUNCTION 'HR_CALC_MONTH'
      EXPORTING
        delta           = l_usfl
      CHANGING
        periode         = l_period
      EXCEPTIONS
        invalid_period  = 1
        undefined_point = 2
        OTHERS          = 3.

    IF pa_datum(6) LE l_period.
      IF wa_itab-afabg(4) LT pa_datum(4).
        l_year  = pa_datum(4) - 1.
        l_month = 12.
        l_perio = ( ( l_year - wa_itab-afabg(4) ) * 12 ) + 1.
        l_perio = l_perio + l_month - wa_itab-afabg+4(2).

        l_acdep = l_nafag * l_perio.
        l_nafap = l_nafag * pa_datum+4(2).
      ELSE.
        l_acdep = 0.
        l_month = 13.
        l_perio = l_month - wa_itab-afabg+4(2).

        IF l_date1 EQ l_date2.
          l_nafap = l_nafag.
        ELSE.
          IF wa_itab-afabg+4(2) LT pa_datum+4(2).
            l_datum = pa_datum+4(2) - wa_itab-afabg+4(2) + 1.
            l_nafap = l_nafag * l_datum.
          ELSE.
            l_nafap = l_nafag * pa_datum+4(2).
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      l_acdep = l_acquv.
      IF wa_itab-afabg(4) LT pa_datum(4).
        l_year  = pa_datum(4) - 1.
        l_month = 12.
        l_perio = ( ( l_year - wa_itab-afabg(4) ) * 12 ) + 1.
        l_perio = l_perio + l_month - wa_itab-afabg+4(2).
        IF l_perio GT i_out-perio.
          l_perio = i_out-perio.
        ENDIF.

        l_acdep = l_nafag * l_perio.
        l_nafap = l_nafag * l_period+4(2).
        IF pa_datum(4) GT l_period(4).
          l_nafap = 0.
        ENDIF.
      ELSE.
        l_acdep = 0.
        l_month = 13.
        l_perio = l_month - wa_itab-afabg+4(2).

        IF l_date1 EQ l_date2.
          l_nafap = l_nafag.
        ELSE.
          IF wa_itab-afabg+4(2) LT l_period+4(2).
            l_datum = l_period+4(2) - wa_itab-afabg+4(2) + 1.
            l_nafap = l_nafag * l_datum.
          ELSE.
            l_nafap = l_nafag * l_period+4(2).
          ENDIF.
        ENDIF.
      ENDIF.
      l_nafag = 0.
    ENDIF.

*    i_out-acquv = l_acquv1 * 100.
*    i_out-nafag = l_nafag * 100.
*    i_out-acdep = l_acdep * 100.
*    i_out-nafap = l_nafap * 100.
    i_out-acquv = l_acquv1.
    i_out-nafag = l_nafag.
    i_out-acdep = l_acdep.
    i_out-nafap = l_nafap.

    i_out-knafa = i_out-acdep + i_out-nafap.
    i_out-bookv = i_out-acquv - i_out-knafa.

    DO 12 TIMES.
      ADD 1 TO l_count.
      CASE l_count.
        WHEN 1.
          IF wa_itab-afabg(4) EQ pa_datum(4).
            IF l_count LT wa_itab-afabg+4(2).
              i_out-jan = 0.
            ELSE.
              i_out-jan = l_nafag.
            ENDIF.
          ELSE.
            i_out-jan = l_nafag.
          ENDIF.
        WHEN 2.
          IF wa_itab-afabg(4) EQ pa_datum(4).
            IF l_count LT wa_itab-afabg+4(2).
              i_out-feb = 0.
            ELSE.
              i_out-feb = l_nafag.
            ENDIF.
          ELSE.
            i_out-feb = l_nafag.
          ENDIF.
        WHEN 3.
          IF wa_itab-afabg(4) EQ pa_datum(4).
            IF l_count LT wa_itab-afabg+4(2).
              i_out-mar = 0.
            ELSE.
              i_out-mar = l_nafag.
            ENDIF.
          ELSE.
            i_out-mar = l_nafag.
          ENDIF.
        WHEN 4.
          IF wa_itab-afabg(4) EQ pa_datum(4).
            IF l_count LT wa_itab-afabg+4(2).
              i_out-apr = 0.
            ELSE.
              i_out-apr = l_nafag.
            ENDIF.
          ELSE.
            i_out-apr = l_nafag.
          ENDIF.
        WHEN 5.
          IF wa_itab-afabg(4) EQ pa_datum(4).
            IF l_count LT wa_itab-afabg+4(2).
              i_out-mei = 0.
            ELSE.
              i_out-mei = l_nafag.
            ENDIF.
          ELSE.
            i_out-mei = l_nafag.
          ENDIF.
        WHEN 6.
          IF wa_itab-afabg(4) EQ pa_datum(4).
            IF l_count LT wa_itab-afabg+4(2).
              i_out-jun = 0.
            ELSE.
              i_out-jun = l_nafag.
            ENDIF.
          ELSE.
            i_out-jun = l_nafag.
          ENDIF.
        WHEN 7.
          IF wa_itab-afabg(4) EQ pa_datum(4).
            IF l_count LT wa_itab-afabg+4(2).
              i_out-jul = 0.
            ELSE.
              i_out-jul = l_nafag.
            ENDIF.
          ELSE.
            i_out-jul = l_nafag.
          ENDIF.
        WHEN 8.
          IF wa_itab-afabg(4) EQ pa_datum(4).
            IF l_count LT wa_itab-afabg+4(2).
              i_out-aug = 0.
            ELSE.
              i_out-aug = l_nafag.
            ENDIF.
          ELSE.
            i_out-aug = l_nafag.
          ENDIF.
        WHEN 9.
          IF wa_itab-afabg(4) EQ pa_datum(4).
            IF l_count LT wa_itab-afabg+4(2).
              i_out-sep = 0.
            ELSE.
              i_out-sep = l_nafag.
            ENDIF.
          ELSE.
            i_out-sep = l_nafag.
          ENDIF.
        WHEN 10.
          IF wa_itab-afabg(4) EQ pa_datum(4).
            IF l_count LT wa_itab-afabg+4(2).
              i_out-okt = 0.
            ELSE.
              i_out-okt = l_nafag.
            ENDIF.
          ELSE.
            i_out-okt = l_nafag.
          ENDIF.
        WHEN 11.
          IF wa_itab-afabg(4) EQ pa_datum(4).
            IF l_count LT wa_itab-afabg+4(2).
              i_out-nov = 0.
            ELSE.
              i_out-nov = l_nafag.
            ENDIF.
          ELSE.
            i_out-nov = l_nafag.
          ENDIF.
        WHEN 12.
          IF wa_itab-afabg(4) EQ pa_datum(4).
            IF l_count LT wa_itab-afabg+4(2).
              i_out-des = 0.
            ELSE.
              i_out-des = l_nafag.
            ENDIF.
          ELSE.
            i_out-des = l_nafag.
          ENDIF.
      ENDCASE.
      IF l_count EQ pa_datum+4(2).
        EXIT.
      ENDIF.
    ENDDO.

    IF l_date2 LE l_date1.
      APPEND i_out.
      CLEAR: l_nafag, l_acquv, l_nafap, l_acdep.
    ENDIF.

    CLEAR: i_out-jan, i_out-feb, i_out-mar, i_out-apr, i_out-mei,
           i_out-jun, i_out-jul, i_out-aug, i_out-sep, i_out-okt,
           i_out-nov, i_out-des, l_count.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " process_10

*&---------------------------------------------------------------------*
*&      Form  F_GET_VENDOR_NAME
*&---------------------------------------------------------------------*
FORM f_get_vendor_name .
  DATA: li_itab TYPE ta_itab OCCURS 0.

  IF i_itab[] IS NOT INITIAL.
    li_itab[] = i_itab[].
    SORT li_itab BY lifnr.
    DELETE ADJACENT DUPLICATES FROM li_itab COMPARING lifnr.
    SELECT lifnr name1
      INTO CORRESPONDING FIELDS OF TABLE i_lfa1
      FROM lfa1 FOR ALL ENTRIES IN li_itab
      WHERE lifnr = li_itab-lifnr.
  ENDIF.
ENDFORM.                    " F_GET_VENDOR_NAME
