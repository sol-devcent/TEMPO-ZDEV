************************************************************************
*                                                                      *
*  PROGRAM NAME  :   ZMR_INVENTORY_MOVEMENT                            *
*  PROGRAM DESC  :   INVENTORY MOVEMENT REPORT                         *
*  CREATED BY    :   WONG LOK JI                                       *
*  CREATED ON    :   10 OCT 2002                                       *
*  VERSION       :   4.6C                                              *
*                                                                      *
************************************************************************
*                                                                      *
*  MODIFICATION LOG :                                                  *
*                                                                      *
*  DATE        PROGRAMMER       CORRECTION  DESCRIPTION                *
*  ----------  ---------------  ----------  -------------------------- *
*  26/11/2002  ABAPper                      regroup movement type      *
*  09/12/2002  ABAPper                      add mvt 653, 654, 932, 933 *
*  17/04/2003  Budi. P          B0001       break by plant             *
*  12/08/2005  Budi. P          B0002       National baca MARC u/ cek
*                                           Material PTT               *
*  16/10/2018  Mahendro K                   Performance optimization   *
*                                           (After 16 years)           *
************************************************************************
REPORT zmr_inventory_movement MESSAGE-ID zm
                              LINE-COUNT 62
                              LINE-SIZE 255
                              NO STANDARD PAGE HEADING.

* define data & variables
TABLES: mara, marc, mard, mkpf, mseg, s031.

TYPES: BEGIN OF ta_itab1,
         matnr LIKE marc-matnr,
         werks LIKE marc-werks,
         matkl LIKE mara-matkl,
         meins LIKE mara-meins.
TYPES: END OF ta_itab1.

TYPES: BEGIN OF ta_itab2,
         matnr LIKE marc-matnr,
         werks LIKE marc-werks,
         matkl LIKE mara-matkl,
         meins LIKE mara-meins.
TYPES: END OF ta_itab2.

DATA: i_itab1   TYPE ta_itab1 OCCURS 0,
      wa_itab1  TYPE ta_itab1,
      i_itab2   TYPE ta_itab2 OCCURS 0,
      wa_itab2  TYPE ta_itab2,
      v_flag(1),
      v_flag_matnr(1).

DATA: l_matnr(12),
      l_matds(30),
      l_matgr(14),
      l_meins LIKE mara-meins,
      l_plant(4),
      l_lplant(4),
      l_hplant(4),
      l_slocd(12),
      l_opqty LIKE mseg-menge,
      l_iqty1 LIKE mseg-menge,
      l_ival1(16) TYPE p DECIMALS 2,
      l_iqty2 LIKE mseg-menge,
      l_ival2(16) TYPE p DECIMALS 2,
      l_iqty3 LIKE mseg-menge,
      l_ival3(16) TYPE p DECIMALS 2,
      l_iqty4 LIKE mseg-menge,
      l_ival4(16) TYPE p DECIMALS 2,
      l_oqty1 LIKE mseg-menge,
      l_oval1 LIKE mseg-dmbtr,
      l_oqty2 LIKE mseg-menge,
      l_oval2 LIKE mseg-dmbtr,
      l_oqty3 LIKE mseg-menge,
      l_oval3 LIKE mseg-dmbtr,
      l_oqty4 LIKE mseg-menge,
      l_oval4 LIKE mseg-dmbtr,
      l_enqty LIKE mseg-menge.

DATA: l_topqty(14) TYPE p DECIMALS 3,
      l_topbal(14) TYPE p DECIMALS 2,
      l_tiqty1(14) TYPE p DECIMALS 3,
      l_tival1(14) TYPE p DECIMALS 2,
      l_tiqty2(14) TYPE p DECIMALS 3,
      l_tival2(14) TYPE p DECIMALS 2,
      l_tiqty3(14) TYPE p DECIMALS 3,
      l_tival3(14) TYPE p DECIMALS 2,
      l_tiqty4(14) TYPE p DECIMALS 3,
      l_tival4(14) TYPE p DECIMALS 2,
      l_toqty1(14) TYPE p DECIMALS 3,
      l_toval1(14) TYPE p DECIMALS 2,
      l_toqty2(14) TYPE p DECIMALS 3,
      l_toval2(14) TYPE p DECIMALS 2,
      l_toqty3(14) TYPE p DECIMALS 3,
      l_toval3(14) TYPE p DECIMALS 2,
      l_toqty4(14) TYPE p DECIMALS 3,
      l_toval4(14) TYPE p DECIMALS 2,
      l_tenqty(14) TYPE p DECIMALS 3,
      l_tcrinv(15) TYPE p DECIMALS 2,
      l_tdbinv(15) TYPE p DECIMALS 2,
      l_tdbacc LIKE bseg-pswbt,
      l_tcracc LIKE bseg-pswbt,
      l_tdbpsw LIKE bseg-pswbt,
      l_tcrpsw LIKE bseg-pswbt,
      l_tother LIKE bseg-pswbt,
      l_tsalk3 LIKE mbew-salk3,
      l_tenbal(15) TYPE p DECIMALS 2.

DATA: l_gopbal(15) TYPE p DECIMALS 2,
      l_gival1(15) TYPE p DECIMALS 2,
      l_gival2(15) TYPE p DECIMALS 2,
      l_gival3(15) TYPE p DECIMALS 2,
      l_gival4(15) TYPE p DECIMALS 2,
      l_goval1(15) TYPE p DECIMALS 2,
      l_goval2(15) TYPE p DECIMALS 2,
      l_goval3(15) TYPE p DECIMALS 2,
      l_goval4(15) TYPE p DECIMALS 2,
      l_gcrinv(16) TYPE p DECIMALS 2,
      l_gdbinv(16) TYPE p DECIMALS 2,
      l_gdbacc(16) TYPE p DECIMALS 2,
      l_gcracc(16) TYPE p DECIMALS 2,
      l_gother(16) TYPE p DECIMALS 2,
      l_genbal(16) TYPE p DECIMALS 2.

DATA: l_crstk(15) TYPE p DECIMALS 2, "l_crstk(13)
      l_crprd  LIKE s031-spmon,
      l_torec  LIKE s031-mzubb,
      l_toiss  LIKE s031-magbb,
      l_labst  LIKE mard-labst,
      l_umlme  LIKE mard-umlme,
      l_insme  LIKE mard-insme,
      l_speme  LIKE mard-speme,
      l_umlmc  LIKE marc-umlmc,
      l_trame  LIKE marc-trame,
      l_recv1  LIKE mseg-menge,
      l_recv2  LIKE mseg-menge,
      l_rval1  LIKE mseg-dmbtr,
      l_rval2  LIKE mseg-dmbtr,
      l_issu1  LIKE mseg-menge,
      l_issu2  LIKE mseg-menge,
      l_isva1  LIKE mseg-dmbtr,
      l_isva2  LIKE mseg-dmbtr,
      l_lblab  LIKE mslb-lblab.

DATA: l_ctl TYPE i,
      l_lprd LIKE mkpf-budat,
      l_hprd LIKE mkpf-budat,
      l_perd LIKE s031-spmon,
      l_year TYPE i,
      l_lyear TYPE i,
      l_hyear TYPE i,
      l_month TYPE i,
      l_divr,
      l_nxpag(4),
      l_pgcnt(2).

DATA: BEGIN OF itab_lgort OCCURS 0,
        matnr TYPE mard-matnr,
        werks TYPE mard-werks,
        lgort TYPE mard-lgort,
      END OF itab_lgort,

      BEGIN OF itab_mard OCCURS 0,
        matnr TYPE mard-matnr,
        werks TYPE mard-werks,
        lgort TYPE mard-lgort,
        labst TYPE mard-labst,
        umlme TYPE mard-umlme,
        insme TYPE mard-insme,
        speme TYPE mard-speme,
      END OF itab_mard,

      BEGIN OF itab_s031 OCCURS 0,
        matnr TYPE s031-matnr,
        werks TYPE s031-werks,
        lgort TYPE s031-lgort,
        spmon TYPE s031-spmon,
        mzubb TYPE s031-mzubb,
        magbb TYPE s031-magbb,
      END OF itab_s031,

      BEGIN OF itab_mseg OCCURS 0,
        matnr TYPE mseg-matnr,
        werks TYPE mseg-werks,
        lgort TYPE mseg-lgort,
        bwart TYPE mseg-bwart,
        shkzg TYPE mseg-shkzg,
        budat TYPE mkpf-budat,
        lifnr TYPE mseg-lifnr,
        menge TYPE mseg-menge,
        dmbtr TYPE mseg-dmbtr,
      END OF itab_mseg,

      BEGIN OF itab_mbew OCCURS 0,
        matnr TYPE mbew-matnr,
        bwkey TYPE mbew-bwkey,
        salk3 TYPE mbew-salk3,
      END OF itab_mbew,

      BEGIN OF itab_bsim OCCURS 0,
        matnr TYPE bsim-matnr,
        bwkey TYPE bsim-bwkey,
        budat TYPE bsim-budat,
        gjahr TYPE bsim-gjahr,
        belnr TYPE bsim-belnr,
        buzei TYPE bsim-buzei,
        shkzg TYPE bsim-shkzg,
        dmbtr TYPE bsim-dmbtr,
      END OF itab_bsim,

      BEGIN OF itab_marc OCCURS 0,
        matnr TYPE marc-matnr,
        werks TYPE marc-werks,
        umlmc TYPE marc-umlmc,
        trame TYPE marc-trame,
      END OF itab_marc,

      BEGIN OF itab_mslb OCCURS 0,
        matnr TYPE mslb-matnr,
        werks TYPE mslb-werks,
        lblab TYPE mslb-lblab,
        sobkz TYPE mslb-sobkz,
      END OF itab_mslb,

      BEGIN OF itab_bwart OCCURS 0,
        lgort TYPE zmgrpbwart-lgort,
        grp   TYPE zmgrpbwart-grp,
        bwart TYPE zmgrpbwart-bwart,
      END OF itab_bwart.

RANGES : r_lgort   FOR zmgrpbwart-lgort,
         r_bwart1a1 FOR mseg-bwart,
         r_bwart1a2 FOR mseg-bwart,
         r_bwart1a3 FOR mseg-bwart,
         r_bwart1a4 FOR mseg-bwart,
         r_bwart1a5 FOR mseg-bwart,
         r_bwart1a6 FOR mseg-bwart,
         r_bwart1a7 FOR mseg-bwart,
         r_bwart1a8 FOR mseg-bwart,

         r_bwart1c1 FOR mseg-bwart,
         r_bwart1c2 FOR mseg-bwart,
         r_bwart1c3 FOR mseg-bwart,
         r_bwart1c4 FOR mseg-bwart,
         r_bwart1c5 FOR mseg-bwart,
         r_bwart1c6 FOR mseg-bwart,
         r_bwart1c7 FOR mseg-bwart,
         r_bwart1c8 FOR mseg-bwart,

         r_bwart1d1 FOR mseg-bwart,
         r_bwart1d2 FOR mseg-bwart,
         r_bwart1d21 FOR mseg-bwart,
         r_bwart1d22 FOR mseg-bwart,
         r_bwart1d23 FOR mseg-bwart,
         r_bwart1d24 FOR mseg-bwart,
         r_bwart1d3 FOR mseg-bwart,
         r_bwart1d4 FOR mseg-bwart,
         r_bwart1d5 FOR mseg-bwart,
         r_bwart1d6 FOR mseg-bwart,
         r_bwart1d71 FOR mseg-bwart,
         r_bwart1d72 FOR mseg-bwart,
         r_bwart1d73 FOR mseg-bwart,
         r_bwart1d74 FOR mseg-bwart,
         r_bwart1d8 FOR mseg-bwart,

         r_bwart1e1 FOR mseg-bwart,
         r_bwart1e2 FOR mseg-bwart,
         r_bwart1e3 FOR mseg-bwart,
         r_bwart1e41 FOR mseg-bwart,
         r_bwart1e42 FOR mseg-bwart,
         r_bwart1e5 FOR mseg-bwart,
         r_bwart1e6 FOR mseg-bwart,
         r_bwart1e71 FOR mseg-bwart,
         r_bwart1e72 FOR mseg-bwart,
         r_bwart1e8 FOR mseg-bwart.

DATA : i TYPE i VALUE 1,
       j TYPE i VALUE 1,
       k TYPE i VALUE 1,

       l TYPE i VALUE 1,
       m TYPE i VALUE 1,
       n TYPE i VALUE 1,

       o TYPE i VALUE 1,
       p TYPE i VALUE 1,
       q TYPE i VALUE 1,

       r TYPE i VALUE 1,
       s TYPE i VALUE 1,
       t TYPE i VALUE 1,

       u TYPE i VALUE 1,
       v TYPE i VALUE 1,
       w TYPE i VALUE 1,

       x TYPE i VALUE 1,
       y TYPE i VALUE 1,
       z TYPE i VALUE 1,

       a TYPE i VALUE 1,
       b TYPE i VALUE 1,
       c TYPE i VALUE 1,

       d TYPE i VALUE 1,
       e TYPE i VALUE 1.

RANGES: r_matnr FOR marc-matnr.
DATA  sw(1).

DATA : gt_mbewh LIKE mbewh OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF gt_s039 OCCURS 0,
         ssour    TYPE ssour,
         vrsio    TYPE vrsio,
         spmon    TYPE spmon,
         sptag    TYPE sptag,
         spwoc    TYPE spwoc,
         spbup    TYPE spbup,
         werks    TYPE werks_d,
         matnr    TYPE matnr,
         lgort    TYPE lgort_d,
         dispo    TYPE dispo,
         dismm    TYPE dismm,
         mtart    TYPE mtart,
         matkl    TYPE matkl,
         gsber    TYPE gsber,
         spart    TYPE spart,
         wbwbest  TYPE wbwbest,
       END OF gt_s039.

************************************************************************
* Define Selection Screen.
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK xbclk1 WITH FRAME TITLE text-001.

PARAMETERS:
  p_bukrs LIKE bkpf-bukrs OBLIGATORY DEFAULT '8020'.

SELECT-OPTIONS:
* S_PERD = Periode on which the inventory movement happen.
  s_perd FOR s031-spmon OBLIGATORY NO-EXTENSION DEFAULT sy-datum(6),

* S_WERKS = plant
  s_werks FOR mseg-werks OBLIGATORY,

* S_MATNR = material number
  s_matnr FOR mseg-matnr,

* S_MATKL = material group
  s_matkl FOR mara-matkl.

PARAMETERS:
  p_natio AS CHECKBOX.

SELECTION-SCREEN END OF BLOCK xbclk1.

AT SELECTION-SCREEN.
*  IF p_bukrs = '8020' AND
*    p_natio = 'X'.
*    CLEAR : s_werks[], s_werks.
*    s_werks-low     = '0200'.
*    s_werks-sign    = 'E'.
*    s_werks-option  = 'EQ'.
*    APPEND s_werks.
*    CLEAR s_werks.
*    s_werks-low     = '02*'.
*    s_werks-sign    = 'I'.
*    s_werks-option  = 'CP'.
*    APPEND s_werks.
*    CLEAR s_werks.
*  ENDIF.

************************************************************************
* Start Selection Screen.
************************************************************************
START-OF-SELECTION.

************************************************************************
* Main Procedure
************************************************************************

  PERFORM set_constant.

  PERFORM set_data_ranges.

  IF p_natio = space.
*    PERFORM get_data_non_national.
    PERFORM get_data_non_national_v1.
    PERFORM f_get_material_valuation USING 'NON'.
    PERFORM pr_recs_non_national.
  ELSE.
    PERFORM get_data_national.
    PERFORM f_get_material_valuation USING ''.
    PERFORM pr_recs_national.
  ENDIF.

  PERFORM print_grand_total.

* add by MKO to minimize memory used, 17-10-2003
  FREE: i_itab1,
        i_itab2,
        itab_lgort,
        itab_mard,
        itab_s031,
        itab_mseg,
        itab_mbew,
        itab_bsim,
        itab_marc,
        itab_mslb,
        itab_bwart.

* PERFORM CETAK_FOOTER.

TOP-OF-PAGE.
  ADD 10 TO l_ctl.
  PERFORM print_header.

END-OF-PAGE.
  PERFORM print_footer.

************************************************************************
* FORM SET CONSTANT
************************************************************************
FORM set_constant.
  l_crprd = sy-datum+0(6).

  CONCATENATE s_perd-low+0(6) '01' INTO l_lprd.

  l_lyear = s_perd-low+0(4).

  IF s_perd-high = '000000'.
    l_month = s_perd-low+4(2).
    l_perd = s_perd-low.
    l_hyear = l_lyear.
  ELSE.
    l_month = s_perd-high+4(2).
    l_perd = s_perd-high.
    l_hyear = s_perd-high+0(4).
  ENDIF.

  CASE l_month.
    WHEN '01' OR '03' OR '05' OR '07' OR '08' OR '10' OR '12'.
      CONCATENATE l_perd+0(6) '31' INTO l_hprd.
    WHEN '04' OR '06' OR '09' OR '11'.
      CONCATENATE l_perd+0(6) '30' INTO l_hprd.
    WHEN '02'.
      l_year = l_perd+0(4).
      l_divr = l_year MOD 4.
      IF l_divr = 0.
        CONCATENATE l_perd+0(6) '29' INTO l_hprd.
      ELSE.
        CONCATENATE l_perd+0(6) '28' INTO l_hprd.
      ENDIF.
  ENDCASE.

ENDFORM.                    "set_constant

************************************************************************
* FORM GET DATA FOR NON NATIONAL (PLANT)
************************************************************************
FORM get_data_non_national.
  IF s_werks-low = space AND s_werks-high = space.
    CONCATENATE p_bukrs+1(2) '00' INTO s_werks-low.
    CONCATENATE p_bukrs+1(2) '99' INTO s_werks-high.
  ENDIF.

  SELECT c~werks c~matnr a~matkl a~meins
    INTO CORRESPONDING FIELDS OF TABLE i_itab1
    FROM marc AS c JOIN mara AS a
      ON a~matnr = c~matnr
   WHERE c~werks IN s_werks AND
*         c~lvorm = '' and
         c~matnr IN s_matnr AND
         a~matkl IN s_matkl "and
*         c~lvorm = space
   ORDER BY c~werks c~matnr.

  SORT i_itab1 BY matnr.
  LOOP AT i_itab1 INTO wa_itab1.
    ON CHANGE OF wa_itab1-matnr.
      r_matnr-sign = 'I'.
      r_matnr-option = 'EQ'.
      r_matnr-low = wa_itab1-matnr.
      APPEND r_matnr.
    ENDON.
  ENDLOOP.

  SELECT matnr werks lgort
  INTO CORRESPONDING FIELDS OF TABLE itab_lgort
  FROM mard
  WHERE werks IN s_werks AND
        matnr IN r_matnr
  ORDER BY werks matnr lgort.

  SELECT matnr werks lgort labst umlme insme speme
    INTO CORRESPONDING FIELDS OF TABLE itab_mard
    FROM mard
    WHERE werks IN s_werks AND
          matnr IN r_matnr
  ORDER BY werks matnr lgort.

  DATA: ld_crprd  LIKE s031-spmon.
  ld_crprd = s_perd-low.
  REFRESH itab_s031.
  WHILE ld_crprd <= l_crprd.
    "Do not use for all entries for huge record in itab (>100000 record)
    SELECT matnr werks lgort spmon mzubb magbb
       APPENDING CORRESPONDING FIELDS OF TABLE itab_s031
       FROM s031
       WHERE ssour = ''
         AND vrsio = '000'
         AND spmon = ld_crprd
         AND sptag = '00000000'
         AND spwoc = '000000'
         AND spbup = '000000'
         AND werks IN s_werks
         AND matnr IN s_matnr.

    ld_crprd = ld_crprd + 1.
    IF ld_crprd+4(2) = '13'.
      ld_crprd(4)   = ld_crprd(4) + 1.
      ld_crprd+4(2) = '01'.
    ENDIF.
  ENDWHILE.
  SORT itab_s031 BY matnr werks lgort.

*  SELECT matnr werks lgort spmon mzubb magbb
*     INTO CORRESPONDING FIELDS OF TABLE itab_s031
*     FROM s031
*     WHERE werks IN s_werks AND
*           matnr IN r_matnr
*           AND spmon BETWEEN s_perd-low AND l_crprd
*  ORDER BY werks matnr lgort spmon.

  SELECT  matnr werks lgort bwart shkzg
                  budat lifnr menge dmbtr sobkz
  INTO CORRESPONDING FIELDS OF TABLE itab_mseg
  FROM mseg INNER JOIN mkpf ON mseg~mblnr EQ mkpf~mblnr
                           AND mseg~mjahr EQ mkpf~mjahr
  WHERE werks IN s_werks AND
        matnr IN r_matnr
        AND budat BETWEEN l_lprd AND sy-datum
  ORDER BY werks matnr lgort.

  SELECT matnr bwkey salk3
  INTO CORRESPONDING FIELDS OF TABLE itab_mbew
  FROM mbew
  WHERE bwkey IN s_werks AND
        matnr IN r_matnr
  ORDER BY bwkey matnr.

  SELECT matnr werks umlmc trame
  INTO CORRESPONDING FIELDS OF TABLE itab_marc
  FROM marc
  WHERE werks IN s_werks AND
        matnr IN r_matnr
  ORDER BY werks matnr.

  SELECT matnr werks sobkz lblab
  INTO CORRESPONDING FIELDS OF TABLE itab_mslb
  FROM mslb
  WHERE werks IN s_werks AND
        matnr IN r_matnr AND
        sobkz = 'O'
  ORDER BY werks matnr.

  SELECT matnr bwkey budat gjahr belnr buzei shkzg dmbtr
  INTO CORRESPONDING FIELDS OF TABLE itab_bsim
  FROM bsim
  WHERE bwkey IN s_werks AND
        matnr IN r_matnr
        AND budat BETWEEN l_lprd AND sy-datum
*        and gjahr between l_lyear and l_hyear
  ORDER BY bwkey matnr.


ENDFORM.                    "get_data_non_national

************************************************************************
* FORM GET DATA FOR NATIONAL
************************************************************************
FORM get_data_national.
  DATA: i_itab2t   TYPE ta_itab2 OCCURS 0,
        BEGIN OF itab_mkpf OCCURS 0,
          mblnr TYPE mkpf-mblnr,
          mjahr TYPE mkpf-mjahr,
        END OF itab_mkpf,
        ld_lyear TYPE i,
        ld_hyear TYPE i.

*** B0002    Begin
  SELECT mara~matnr matkl meins werks
    INTO CORRESPONDING FIELDS OF TABLE i_itab2
    FROM mara JOIN marc ON mara~matnr = marc~matnr
   WHERE mara~matnr IN s_matnr
     AND matkl IN s_matkl
     AND werks IN s_werks. "and
*         lvorm = space
  SORT i_itab2 BY matnr werks.
  i_itab2t[] = i_itab2[].
  DELETE ADJACENT DUPLICATES FROM i_itab2t COMPARING matnr.
*  order by matnr.

*  SELECT a~matnr a~matkl a~meins
*    INTO CORRESPONDING FIELDS OF TABLE i_itab2
*    FROM mara AS a JOIN marc AS b ON a~matnr = b~matnr
*    WHERE b~werks IN s_werks AND
*          b~matnr IN s_matnr AND
*          a~matkl IN s_matkl "and
**         lvorm = space
*   ORDER BY a~matnr.
*** B0002      End

**  SORT i_itab2 BY matnr.
**  LOOP AT i_itab2 INTO wa_itab2.
**    ON CHANGE OF wa_itab2-matnr.
**      r_matnr-sign = 'I'.
**      r_matnr-option = 'EQ'.
**      r_matnr-low = wa_itab2-matnr.
**      APPEND r_matnr.
**    ENDON.
**  ENDLOOP.

  IF i_itab2[] IS NOT INITIAL.
    SELECT matnr werks lgort
      INTO CORRESPONDING FIELDS OF TABLE itab_lgort
      FROM mard
      FOR ALL ENTRIES IN i_itab2t
      WHERE matnr = i_itab2t-matnr.
*  ORDER BY matnr lgort.
    SORT itab_lgort BY matnr lgort.

    SELECT matnr werks lgort labst umlme insme speme
      INTO CORRESPONDING FIELDS OF TABLE itab_mard
      FROM mard
      FOR ALL ENTRIES IN i_itab2t
      WHERE matnr = i_itab2t-matnr.
    SORT itab_mard BY matnr werks lgort.

    DATA: ld_crprd  LIKE s031-spmon.
    ld_crprd = s_perd-low.
    REFRESH itab_s031.
    WHILE ld_crprd <= l_crprd.
      "Do not use for all entries for huge record in itab (>100000 record)
      SELECT matnr werks lgort spmon mzubb magbb
         APPENDING CORRESPONDING FIELDS OF TABLE itab_s031
         FROM s031
         WHERE ssour = ''
           AND vrsio = '000'
           AND spmon = ld_crprd
           AND sptag = '00000000'
           AND spwoc = '000000'
           AND spbup = '000000'
           AND werks IN s_werks
           AND matnr IN s_matnr.

      ld_crprd = ld_crprd + 1.
      IF ld_crprd+4(2) = '13'.
        ld_crprd(4)   = ld_crprd(4) + 1.
        ld_crprd+4(2) = '01'.
      ENDIF.
    ENDWHILE.
    SORT itab_s031 BY matnr werks lgort.
    break mmfm.
*    REFRESH itab_mkpf.
*    SELECT mblnr mjahr
*      INTO CORRESPONDING FIELDS OF TABLE itab_mkpf
*      FROM MKPF
*      WHERE budat BETWEEN l_lprd AND sy-datum.
*
*    SELECT matnr werks lgort bwart shkzg
*           budat lifnr menge dmbtr sobkz
*      INTO CORRESPONDING FIELDS OF TABLE itab_mseg
*      FROM mseg INNER JOIN mkpf ON mseg~mblnr EQ mkpf~mblnr
*                               AND mseg~mjahr EQ mkpf~mjahr
*      FOR ALL ENTRIES IN itab_mkpf
*      WHERE mkpf~mblnr = itab_mkpf-mblnr
*        AND mkpf~mjahr = itab_mkpf-mjahr
*        AND matnr in s_matnr
*        AND werks in s_werks.
**        AND budat BETWEEN l_lprd AND sy-datum.

    SELECT  matnr werks lgort bwart shkzg
                    budat lifnr menge dmbtr sobkz
    INTO CORRESPONDING FIELDS OF TABLE itab_mseg
    FROM mseg INNER JOIN mkpf ON mseg~mblnr EQ mkpf~mblnr
                             AND mseg~mjahr EQ mkpf~mjahr
    WHERE werks IN s_werks AND
          matnr IN s_matnr
          AND budat BETWEEN l_lprd AND sy-datum.

    SORT itab_mseg BY matnr werks lgort.

    SELECT matnr bwkey salk3
      INTO CORRESPONDING FIELDS OF TABLE itab_mbew
      FROM mbew
      FOR ALL ENTRIES IN i_itab2
      WHERE matnr = i_itab2-matnr.
    SORT itab_mbew BY matnr bwkey.

    SELECT matnr werks umlmc trame
      INTO CORRESPONDING FIELDS OF TABLE itab_marc
      FROM marc
      FOR ALL ENTRIES IN i_itab2t
      WHERE matnr = i_itab2t-matnr.
    SORT itab_marc BY matnr werks.

    SELECT matnr werks sobkz lblab
      INTO CORRESPONDING FIELDS OF TABLE itab_mslb
      FROM mslb
      FOR ALL ENTRIES IN i_itab2t
      WHERE matnr = i_itab2t-matnr
        AND sobkz = 'O'.
    SORT itab_mslb BY matnr werks.

    ld_lyear = l_lprd(4).
    ld_hyear = sy-datum(4).
    SELECT matnr bwkey budat gjahr belnr buzei shkzg dmbtr
      INTO CORRESPONDING FIELDS OF TABLE itab_bsim
      FROM bsim
*      FOR ALL ENTRIES IN i_itab2t
      WHERE matnr IN s_matnr
        AND bwkey IN s_werks
        AND budat BETWEEN l_lprd AND sy-datum
        AND gjahr BETWEEN ld_lyear AND ld_hyear.
    SORT itab_bsim BY matnr bwkey.
  ENDIF.
ENDFORM.                    "get_data_national


************************************************************************
* FORM PROCESS RECORDS (FOR NON NATIONAL)
************************************************************************
FORM pr_recs_non_national.
  DATA : v_slocd LIKE l_slocd,
         v_flag_cvrs(1).
  CLEAR: wa_itab1.

  SORT i_itab1 BY matnr werks.
  SORT itab_lgort BY matnr werks.
  SORT itab_mard BY matnr werks.
  SORT itab_s031 BY matnr werks.
  SORT itab_mseg BY matnr werks.
  SORT itab_marc BY matnr werks.
  SORT itab_mslb BY matnr werks.
  SORT itab_mbew BY matnr bwkey.
  SORT itab_bsim BY matnr bwkey.

  LOOP AT i_itab1 INTO wa_itab1.

    l_matnr = wa_itab1-matnr.

    SELECT SINGLE maktx FROM makt INTO l_matds
      WHERE matnr = l_matnr.

*    select single matkl from mara into l_matgr
*      where matnr = l_matnr.

    l_matgr = wa_itab1-matkl.
    l_meins = wa_itab1-meins.
    l_plant = wa_itab1-werks.
    l_lplant = l_plant.
    l_hplant = l_plant.

* CLEAR VARIABLES FOR TOTAL
    CLEAR: l_topqty, l_topbal, l_tiqty1, l_tival1, l_tiqty2, l_tival2,
           l_tiqty3, l_tival3, l_tiqty4, l_tival4, l_toqty1, l_toval1,
           l_toqty2, l_toval2, l_toqty3, l_toval3, l_toqty4, l_toval4,
           l_tenqty, l_tenbal.

    CLEAR: v_flag_matnr,
            v_flag,
            v_flag_cvrs,
            v_slocd.
    RESERVE 9 LINES.
*    READ TABLE itab_lgort WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_lgort WITH KEY matnr = l_matnr werks = l_plant
                                   BINARY SEARCH.
    d = sy-tabix.
    LOOP AT itab_lgort FROM d.
      IF itab_lgort-werks = l_plant AND
         itab_lgort-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.

*    loop at itab_lgort where matnr = wa_itab1-matnr and      "B0001
*                             werks = wa_itab1-werks.         "B0001
      l_slocd = itab_lgort-lgort.

      IF l_slocd = '1000' .
        PERFORM get_stock_in_sloc1a.
      ELSEIF l_slocd = '10U0'.
        PERFORM get_stock_in_sloc1u.
      ELSEIF l_slocd <> space AND l_slocd <> '1000' AND
             l_slocd <> '10U0' AND l_slocd <> '10D0'.
        l_slocd = 'CV+RS'.
        PERFORM get_stock_in_sloc1b.
      ELSEIF l_slocd = '10D0'.
        PERFORM get_stock_in_sloc1c.
      ENDIF.

      IF v_slocd <> l_slocd.
        IF l_slocd = 'CV+RS'.
          IF v_flag_cvrs NE 'X'.
            CLEAR v_flag_matnr.
            MOVE l_slocd TO v_slocd.
          ELSE.
            MOVE 'X' TO v_flag_matnr.
          ENDIF.
        ELSE.
          CLEAR v_flag_matnr.
          MOVE l_slocd TO v_slocd.
        ENDIF.
      ELSE.
        MOVE 'X' TO v_flag_matnr.
      ENDIF.

      IF v_slocd = 'CV+RS'.
        MOVE 'X' TO v_flag_cvrs.
      ENDIF.
      IF v_flag_matnr <> 'X'.
        PERFORM add_total.
        PERFORM print_detail.
      ENDIF.

    ENDLOOP.

    PERFORM get_stock_in_sloc1d.
    PERFORM get_stock_in_sloc1e.
    PERFORM print_total USING wa_itab1-matnr wa_itab1-werks.

    CLEAR: wa_itab1.
  ENDLOOP.

ENDFORM.                    "pr_recs_non_national

************************************************************************
* FORM PROCESS RECORDS (FOR NATIONAL)
************************************************************************
FORM pr_recs_national.
  DATA : v_slocd LIKE l_slocd,
         v_flag_cvrs(1).
  CLEAR: wa_itab2.
  DELETE ADJACENT DUPLICATES FROM i_itab2 COMPARING matnr.

  SORT i_itab2 BY matnr werks.
  SORT itab_lgort BY matnr lgort.
  SORT itab_mard BY matnr lgort.
  SORT itab_s031 BY matnr lgort.
  SORT itab_mseg BY matnr lgort.
  SORT itab_marc BY matnr werks.
  SORT itab_mslb BY matnr werks.
  SORT itab_mbew BY matnr bwkey.
  SORT itab_bsim BY matnr bwkey.

  LOOP AT i_itab2 INTO wa_itab2.
    l_matnr = wa_itab2-matnr.

    SELECT SINGLE maktx FROM makt INTO l_matds
      WHERE matnr = l_matnr.

*    select single matkl from mara into l_matgr
*      where matnr = l_matnr.

    l_matgr = wa_itab2-matkl.
    l_meins = wa_itab2-meins.
    l_plant = space.

    IF wa_itab2-werks(1) = 'T'.
      CONCATENATE wa_itab2-werks(1) p_bukrs+2(1) '00' INTO l_lplant.
      CONCATENATE wa_itab2-werks(1) p_bukrs+2(1) '99' INTO l_hplant.
    ELSE.
      CONCATENATE p_bukrs+1(2) '00' INTO l_lplant.
      CONCATENATE p_bukrs+1(2) '99' INTO l_hplant.
    ENDIF.

* CLEAR VARIABLES FOR TOTAL
    CLEAR: l_topqty, l_topbal, l_tiqty1, l_tival1, l_tiqty2, l_tival2,
           l_tiqty3, l_tival3, l_tiqty4, l_tival4, l_toqty1, l_toval1,
           l_toqty2, l_toval2, l_toqty3, l_toval3, l_toqty4, l_toval4,
           l_tenqty, l_tenbal.

    CLEAR: v_flag_matnr,
           v_flag,
           v_flag_cvrs,
           v_slocd.
    RESERVE 8 LINES.

    DELETE ADJACENT DUPLICATES FROM itab_lgort COMPARING matnr lgort.

    READ TABLE itab_lgort WITH KEY matnr = l_matnr BINARY SEARCH.
    e = sy-tabix.
    LOOP AT itab_lgort FROM e.
      IF itab_lgort-matnr <> l_matnr.
        EXIT.
      ENDIF.

*    loop at itab_lgort where matnr = l_matnr.
      l_slocd = itab_lgort-lgort.


      IF l_slocd = '1000' .
        PERFORM get_stock_in_sloc1a.
      ELSEIF l_slocd = '10U0'.
        PERFORM get_stock_in_sloc1u.
      ELSEIF l_slocd <> space AND l_slocd <> '1000' AND
            l_slocd <> '10U0' AND l_slocd <> '10D0'.
        l_slocd = 'CV+RS'.
        PERFORM get_stock_in_sloc1b.
      ELSEIF l_slocd = '10D0'.
        PERFORM get_stock_in_sloc1c.
      ENDIF.

      IF v_slocd <> l_slocd.
        IF l_slocd = 'CV+RS'.
          IF v_flag_cvrs NE 'X'.
            CLEAR v_flag_matnr.
            MOVE l_slocd TO v_slocd.
          ELSE.
            MOVE 'X' TO v_flag_matnr.
          ENDIF.
        ELSE.
          CLEAR v_flag_matnr.
          MOVE l_slocd TO v_slocd.
        ENDIF.
      ELSE.
        MOVE 'X' TO v_flag_matnr.
      ENDIF.

      IF v_slocd = 'CV+RS'.
        MOVE 'X' TO v_flag_cvrs.
      ENDIF.

      IF v_flag_matnr <> 'X'.
        PERFORM add_total.
        PERFORM print_detail.
      ENDIF.
    ENDLOOP.
    PERFORM get_stock_in_sloc1d.
    PERFORM get_stock_in_sloc1e.
    PERFORM print_total USING wa_itab2-matnr ''.

    CLEAR: wa_itab2.
  ENDLOOP.

ENDFORM.                    "pr_recs_national

************************************************************************
* FORM GET STOCK DATA IN STORAGE LOCATION 1000 (MAIN STORAGE LOCATION)
************************************************************************
FORM get_stock_in_sloc1a.

  PERFORM clear_var_details.

  IF p_natio = space.                                       "B0001

* get Opening Stock
*    READ TABLE itab_mard WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_mard WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    i = sy-tabix.
    LOOP AT itab_mard FROM i.
      IF itab_mard-werks = l_plant AND
         itab_mard-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
*  loop at itab_mard where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF itab_mard-werks BETWEEN l_lplant AND l_hplant  AND
         itab_mard-lgort = l_slocd.
        l_labst = itab_mard-labst + l_labst.
        l_speme = itab_mard-speme + l_speme.
        l_insme = itab_mard-insme + l_insme.
*        l_umlme = itab_mard-umlme + l_umlme.

        " delete ITAB_MARD.
      ENDIF.
    ENDLOOP.

*    READ TABLE itab_s031 WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_s031 WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    j = sy-tabix.
    LOOP AT itab_s031 FROM j.
      IF itab_s031-werks = l_plant AND
         itab_s031-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
*  loop at itab_s031 where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF itab_s031-werks BETWEEN l_lplant AND l_hplant  AND
         itab_s031-lgort = l_slocd AND
         itab_s031-spmon <= l_crprd AND itab_s031-spmon >= s_perd-low.
        l_torec = itab_s031-mzubb + l_torec.
        l_toiss = itab_s031-magbb + l_toiss.

        " delete ITAB_S031.
      ENDIF.
    ENDLOOP.

    l_crstk = l_labst + l_insme + l_speme + l_umlme.
    l_opqty = l_crstk - l_torec + l_toiss.

* get In-GR PO
*    READ TABLE itab_mseg WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_mseg WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    k = sy-tabix.
    LOOP AT itab_mseg FROM k.
      IF itab_mseg-werks = l_plant AND
         itab_mseg-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF itab_mseg-werks BETWEEN l_lplant AND l_hplant AND
         itab_mseg-lgort = l_slocd AND
         itab_mseg-budat BETWEEN l_lprd AND l_hprd.

*  if ( itab_mseg-bwart = '101' or itab_mseg-bwart = '123' or
*     itab_mseg-bwart = '162' ) and itab_mseg-lifnr ne space
*     and itab_mseg-shkzg = 'S'.
        IF  itab_mseg-bwart IN r_bwart1a1 AND itab_mseg-lifnr NE space
            AND itab_mseg-shkzg = 'S'.

          l_iqty1 = itab_mseg-menge + l_iqty1.
          l_ival1 = itab_mseg-dmbtr + l_ival1.
          sw = 1.
        ENDIF.

** get In-Allocation
*  if ( itab_mseg-bwart = '101' or itab_mseg-bwart = '642' or
*     itab_mseg-bwart = '301' or itab_mseg-bwart = '302' or
*     itab_mseg-bwart = '304' or itab_mseg-bwart = '305' ) and
*     itab_mseg-lifnr eq space and itab_mseg-shkzg = 'S'.
        IF  itab_mseg-bwart IN r_bwart1a2 AND
            itab_mseg-lifnr EQ space AND itab_mseg-shkzg = 'S'.

          l_iqty2 = itab_mseg-menge + l_iqty2.
          l_ival2 = itab_mseg-dmbtr + l_ival2.
          sw = 1.
        ENDIF.

** get In-Sales Return
*  if ( itab_mseg-bwart = '602' or itab_mseg-bwart = '653' or
*     itab_mseg-bwart = '655' or itab_mseg-bwart = '902' or
*     itab_mseg-bwart = '908' or itab_mseg-bwart = '910' or
*     itab_mseg-bwart = '911' or itab_mseg-bwart = '913' or
*     itab_mseg-bwart = '929' or itab_mseg-bwart = '930' or
*     itab_mseg-bwart = '933' ) and  itab_mseg-shkzg = 'S' .
*        IF itab_mseg-bwart IN r_bwart1a3 AND  itab_mseg-shkzg = 'S' .
        IF itab_mseg-bwart IN r_bwart1a3.
          IF itab_mseg-shkzg = 'S'.
            l_iqty3 = itab_mseg-menge + l_iqty3.
            l_ival3 = itab_mseg-dmbtr + l_ival3.
            sw = 1.
          ELSEIF itab_mseg-shkzg = 'H' .
            l_iqty3 = l_iqty3 - itab_mseg-menge.
            l_ival3 = l_ival3 - itab_mseg-dmbtr.
            sw = 1.
          ENDIF.
        ENDIF.

** get In-Other
*  if ( itab_mseg-bwart = '309' or itab_mseg-bwart = '310' or
*     itab_mseg-bwart = '311' or itab_mseg-bwart = '312' or
*     itab_mseg-bwart = '321' or itab_mseg-bwart = '322' or
*     itab_mseg-bwart = '343' or itab_mseg-bwart = '344' or
*     itab_mseg-bwart = '349' or itab_mseg-bwart = '350' or
*     itab_mseg-bwart = '541' or itab_mseg-bwart = '542' or
*     itab_mseg-bwart = '556' or itab_mseg-bwart = '561' or
*     itab_mseg-bwart = '565' or itab_mseg-bwart = '904' or
*     itab_mseg-bwart = '906' or itab_mseg-bwart = '921' or
*     itab_mseg-bwart = '923' or itab_mseg-bwart = '927' or
*     itab_mseg-bwart = '924' or itab_mseg-bwart = '925' ) and
        IF itab_mseg-bwart IN r_bwart1a4 AND
           itab_mseg-shkzg = 'S'.
          l_iqty4 = itab_mseg-menge + l_iqty4.
          l_ival4 = itab_mseg-dmbtr + l_ival4.
          sw = 1.
        ENDIF.

** get Out-Allocation
*  if ( itab_mseg-bwart = '102' or itab_mseg-bwart = '641' or
*     itab_mseg-bwart = '301' or itab_mseg-bwart = '302' or
*     itab_mseg-bwart = '303' or itab_mseg-bwart = '306' ) and
*     itab_mseg-shkzg = 'H' and itab_mseg-lifnr eq space.
        IF itab_mseg-bwart IN r_bwart1a5 AND
           itab_mseg-shkzg = 'H' AND itab_mseg-lifnr EQ space.
          l_oqty1 = itab_mseg-menge + l_oqty1.
          l_oval1 = itab_mseg-dmbtr + l_oval1.
          sw = 1.
        ENDIF.

** get Out-Sales
*  if ( itab_mseg-bwart = '601' or itab_mseg-bwart = '654' or
*     itab_mseg-bwart = '656' or itab_mseg-bwart = '901' or
*     itab_mseg-bwart = '907' or itab_mseg-bwart = '909' or
*     itab_mseg-bwart = '912' or itab_mseg-bwart = '914' or
*     itab_mseg-bwart = '928' or itab_mseg-bwart = '931' or
*     itab_mseg-bwart = '932' ) and itab_mseg-shkzg = 'H'.
*        IF itab_mseg-bwart IN r_bwart1a6 AND itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1a6.
          IF itab_mseg-shkzg = 'H'.
            l_oqty2 = itab_mseg-menge + l_oqty2.
            l_oval2 = itab_mseg-dmbtr + l_oval2.
            sw = 1.
          ELSEIF itab_mseg-shkzg = 'S'.
            l_oqty2 =  l_oqty2 - itab_mseg-menge.
            l_oval2 =  l_oval2 - itab_mseg-dmbtr.
            sw = 1.
          ENDIF.
        ENDIF.

** get Out-Return to Principal
*  if ( itab_mseg-bwart = '102' or itab_mseg-bwart = '122' or
*      itab_mseg-bwart = '161' ) and itab_mseg-shkzg = 'H' and
*      itab_mseg-lifnr ne space.
        IF  itab_mseg-bwart IN r_bwart1a7 AND itab_mseg-shkzg = 'H' AND
            itab_mseg-lifnr NE space.
          l_oqty3 = itab_mseg-menge + l_oqty3.
          l_oval3 = itab_mseg-dmbtr + l_oval3.
          sw = 1.
        ENDIF.

** get Out-Other
*  if ( itab_mseg-bwart = '309' or itab_mseg-bwart = '310' or
*     itab_mseg-bwart = '311' or itab_mseg-bwart = '312' or
*     itab_mseg-bwart = '321' or itab_mseg-bwart = '322' or
*     itab_mseg-bwart = '343' or itab_mseg-bwart = '344' or
*     itab_mseg-bwart = '349' or itab_mseg-bwart = '350' or
*     itab_mseg-bwart = '541' or itab_mseg-bwart = '542' or
*     itab_mseg-bwart = '551' or itab_mseg-bwart = '555' or
*     itab_mseg-bwart = '562' or itab_mseg-bwart = '566' or
*     itab_mseg-bwart = '903' or itab_mseg-bwart = '905' or
*     itab_mseg-bwart = '920' or itab_mseg-bwart = '922' or
*     itab_mseg-bwart = '924' or itab_mseg-bwart = '925' or
*     itab_mseg-bwart = '926' ) and itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1a8 AND itab_mseg-shkzg = 'H'.
          l_oqty4 = itab_mseg-menge + l_oqty4.
          l_oval4 = itab_mseg-dmbtr + l_oval4.
          sw = 1.
        ENDIF.
      ENDIF.
      IF sw = 1.
        " delete ITAB_MSEG.
      ENDIF.
    ENDLOOP.

** get Ending Stock
    l_enqty = l_opqty + l_iqty1 + l_iqty2 + l_iqty3 + l_iqty4 -
                        l_oqty1 - l_oqty2 - l_oqty3 - l_oqty4.

*  perform add_total.

* B0001
  ELSE.

* get Opening Stock
    READ TABLE itab_mard WITH KEY matnr = l_matnr BINARY SEARCH.
    i = sy-tabix.
    LOOP AT itab_mard FROM i.
      IF itab_mard-matnr <> l_matnr.
        EXIT.
      ENDIF.
*  loop at itab_mard where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF itab_mard-werks BETWEEN l_lplant AND l_hplant  AND
         itab_mard-lgort = l_slocd.
        l_labst = itab_mard-labst + l_labst.
        l_speme = itab_mard-speme + l_speme.
        l_insme = itab_mard-insme + l_insme.
        l_umlme = itab_mard-umlme + l_umlme.

        " delete ITAB_MARD.
      ENDIF.
    ENDLOOP.

    READ TABLE itab_s031 WITH KEY matnr = l_matnr BINARY SEARCH.
    j = sy-tabix.
    LOOP AT itab_s031 FROM j.
      IF itab_s031-matnr <> l_matnr.
        EXIT.
      ENDIF.
*  loop at itab_s031 where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF itab_s031-werks BETWEEN l_lplant AND l_hplant  AND
         itab_s031-lgort = l_slocd AND
         itab_s031-spmon <= l_crprd AND itab_s031-spmon >= s_perd-low.
        l_torec = itab_s031-mzubb + l_torec.
        l_toiss = itab_s031-magbb + l_toiss.

        " delete ITAB_S031.
      ENDIF.
    ENDLOOP.

    l_crstk = l_labst + l_insme + l_speme + l_umlme.
    l_opqty = l_crstk - l_torec + l_toiss.

* get In-GR PO
    READ TABLE itab_mseg WITH KEY matnr = l_matnr BINARY SEARCH.
    k = sy-tabix.
    LOOP AT itab_mseg FROM k.
      IF itab_mseg-matnr <> l_matnr.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF itab_mseg-werks BETWEEN l_lplant AND l_hplant AND
         itab_mseg-lgort = l_slocd AND
         itab_mseg-budat BETWEEN l_lprd AND l_hprd.

*  if ( itab_mseg-bwart = '101' or itab_mseg-bwart = '123' or
*     itab_mseg-bwart = '162' ) and itab_mseg-lifnr ne space
*     and itab_mseg-shkzg = 'S'.
        IF  itab_mseg-bwart IN r_bwart1a1 AND itab_mseg-lifnr NE space
            AND itab_mseg-shkzg = 'S'.

          l_iqty1 = itab_mseg-menge + l_iqty1.
          l_ival1 = itab_mseg-dmbtr + l_ival1.
          sw = 1.
        ENDIF.

** get In-Allocation
*  if ( itab_mseg-bwart = '101' or itab_mseg-bwart = '642' or
*     itab_mseg-bwart = '301' or itab_mseg-bwart = '302' or
*     itab_mseg-bwart = '304' or itab_mseg-bwart = '305' ) and
*     itab_mseg-lifnr eq space and itab_mseg-shkzg = 'S'.
        IF  itab_mseg-bwart IN r_bwart1a2 AND
            itab_mseg-lifnr EQ space AND itab_mseg-shkzg = 'S'.

          l_iqty2 = itab_mseg-menge + l_iqty2.
          l_ival2 = itab_mseg-dmbtr + l_ival2.
          sw = 1.
        ENDIF.

** get In-Sales Return
*  if ( itab_mseg-bwart = '602' or itab_mseg-bwart = '653' or
*     itab_mseg-bwart = '655' or itab_mseg-bwart = '902' or
*     itab_mseg-bwart = '908' or itab_mseg-bwart = '910' or
*     itab_mseg-bwart = '911' or itab_mseg-bwart = '913' or
*     itab_mseg-bwart = '929' or itab_mseg-bwart = '930' or
*     itab_mseg-bwart = '933' ) and  itab_mseg-shkzg = 'S' .
*        IF itab_mseg-bwart IN r_bwart1a3 AND  itab_mseg-shkzg = 'S' .
        IF itab_mseg-bwart IN r_bwart1a3.
          IF itab_mseg-shkzg = 'S'.
            l_iqty3 = itab_mseg-menge + l_iqty3.
            l_ival3 = itab_mseg-dmbtr + l_ival3.
            sw = 1.
          ELSEIF itab_mseg-shkzg = 'H' .
            l_iqty3 = l_iqty3 - itab_mseg-menge.
            l_ival3 = l_ival3 - itab_mseg-dmbtr.
            sw = 1.
          ENDIF.
        ENDIF.

** get In-Other
*  if ( itab_mseg-bwart = '309' or itab_mseg-bwart = '310' or
*     itab_mseg-bwart = '311' or itab_mseg-bwart = '312' or
*     itab_mseg-bwart = '321' or itab_mseg-bwart = '322' or
*     itab_mseg-bwart = '343' or itab_mseg-bwart = '344' or
*     itab_mseg-bwart = '349' or itab_mseg-bwart = '350' or
*     itab_mseg-bwart = '541' or itab_mseg-bwart = '542' or
*     itab_mseg-bwart = '556' or itab_mseg-bwart = '561' or
*     itab_mseg-bwart = '565' or itab_mseg-bwart = '904' or
*     itab_mseg-bwart = '906' or itab_mseg-bwart = '921' or
*     itab_mseg-bwart = '923' or itab_mseg-bwart = '927' or
*     itab_mseg-bwart = '924' or itab_mseg-bwart = '925' ) and
        IF itab_mseg-bwart IN r_bwart1a4 AND
           itab_mseg-shkzg = 'S'.
          l_iqty4 = itab_mseg-menge + l_iqty4.
          l_ival4 = itab_mseg-dmbtr + l_ival4.
          sw = 1.
        ENDIF.

** get Out-Allocation
*  if ( itab_mseg-bwart = '102' or itab_mseg-bwart = '641' or
*     itab_mseg-bwart = '301' or itab_mseg-bwart = '302' or
*     itab_mseg-bwart = '303' or itab_mseg-bwart = '306' ) and
*     itab_mseg-shkzg = 'H' and itab_mseg-lifnr eq space.
        IF itab_mseg-bwart IN r_bwart1a5 AND
           itab_mseg-shkzg = 'H' AND itab_mseg-lifnr EQ space.
          l_oqty1 = itab_mseg-menge + l_oqty1.
          l_oval1 = itab_mseg-dmbtr + l_oval1.
          sw = 1.
        ENDIF.

** get Out-Sales
*  if ( itab_mseg-bwart = '601' or itab_mseg-bwart = '654' or
*     itab_mseg-bwart = '656' or itab_mseg-bwart = '901' or
*     itab_mseg-bwart = '907' or itab_mseg-bwart = '909' or
*     itab_mseg-bwart = '912' or itab_mseg-bwart = '914' or
*     itab_mseg-bwart = '928' or itab_mseg-bwart = '931' or
*     itab_mseg-bwart = '932' ) and itab_mseg-shkzg = 'H'.
*        IF itab_mseg-bwart IN r_bwart1a6 AND itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1a6.
          IF itab_mseg-shkzg = 'H'.
            l_oqty2 = itab_mseg-menge + l_oqty2.
            l_oval2 = itab_mseg-dmbtr + l_oval2.
            sw = 1.
          ELSEIF itab_mseg-shkzg = 'S'.
            l_oqty2 =  l_oqty2 - itab_mseg-menge.
            l_oval2 =  l_oval2 - itab_mseg-dmbtr.
            sw = 1.
          ENDIF.
        ENDIF.

** get Out-Return to Principal
*  if ( itab_mseg-bwart = '102' or itab_mseg-bwart = '122' or
*      itab_mseg-bwart = '161' ) and itab_mseg-shkzg = 'H' and
*      itab_mseg-lifnr ne space.
        IF  itab_mseg-bwart IN r_bwart1a7 AND itab_mseg-shkzg = 'H' AND
            itab_mseg-lifnr NE space.
          l_oqty3 = itab_mseg-menge + l_oqty3.
          l_oval3 = itab_mseg-dmbtr + l_oval3.
          sw = 1.
        ENDIF.

** get Out-Other
*  if ( itab_mseg-bwart = '309' or itab_mseg-bwart = '310' or
*     itab_mseg-bwart = '311' or itab_mseg-bwart = '312' or
*     itab_mseg-bwart = '321' or itab_mseg-bwart = '322' or
*     itab_mseg-bwart = '343' or itab_mseg-bwart = '344' or
*     itab_mseg-bwart = '349' or itab_mseg-bwart = '350' or
*     itab_mseg-bwart = '541' or itab_mseg-bwart = '542' or
*     itab_mseg-bwart = '551' or itab_mseg-bwart = '555' or
*     itab_mseg-bwart = '562' or itab_mseg-bwart = '566' or
*     itab_mseg-bwart = '903' or itab_mseg-bwart = '905' or
*     itab_mseg-bwart = '920' or itab_mseg-bwart = '922' or
*     itab_mseg-bwart = '924' or itab_mseg-bwart = '925' or
*     itab_mseg-bwart = '926' ) and itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1a8 AND itab_mseg-shkzg = 'H'.
          l_oqty4 = itab_mseg-menge + l_oqty4.
          l_oval4 = itab_mseg-dmbtr + l_oval4.
          sw = 1.
        ENDIF.
      ENDIF.
      IF sw = 1.
        " delete ITAB_MSEG.
      ENDIF.
    ENDLOOP.

** get Ending Stock
    l_enqty = l_opqty + l_iqty1 + l_iqty2 + l_iqty3 + l_iqty4 -
                        l_oqty1 - l_oqty2 - l_oqty3 - l_oqty4.

  ENDIF.

ENDFORM.                    "get_stock_in_sloc1a


************************************************************************
* FORM GET STOCK DATA IN STORAGE LOCATION 10U0 (UNSALEABLE)
************************************************************************
FORM get_stock_in_sloc1b.
  PERFORM clear_var_details.

  IF p_natio = space.                                       "B0001

* get Opening Stock
*    READ TABLE itab_mard WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_mard WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    l = sy-tabix.
    LOOP AT itab_mard FROM l.
      IF itab_mard-werks = l_plant AND
         itab_mard-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
*  loop at itab_mard where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mard-werks BETWEEN l_lplant AND l_hplant ) AND
         itab_mard-lgort <> ' ' AND itab_mard-lgort <> '1000' AND
         itab_mard-lgort <> '10U0' AND itab_mard-lgort <> '10D0'.
        l_labst = itab_mard-labst + l_labst.
        l_speme = itab_mard-speme + l_speme.
        l_insme = itab_mard-insme + l_insme.
*        l_umlme = itab_mard-umlme + l_umlme.

        " delete ITAB_MARD.
      ENDIF.
    ENDLOOP.

*    READ TABLE itab_s031 WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_s031 WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    m = sy-tabix.
    LOOP AT itab_s031 FROM m.
      IF itab_s031-werks = l_plant AND
         itab_s031-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
*  loop at itab_s031 where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_s031-werks BETWEEN l_lplant AND l_hplant ) AND
         itab_s031-lgort <> ' ' AND itab_s031-lgort <> '1000' AND
         itab_s031-lgort <> '10U0' AND itab_s031-lgort <> '10D0' AND
         ( itab_s031-spmon <= l_crprd AND itab_s031-spmon >= s_perd-low ).
        l_torec = itab_s031-mzubb + l_torec.
        l_toiss = itab_s031-magbb + l_toiss.

        " delete ITAB_S031.
      ENDIF.
    ENDLOOP.

    l_crstk = l_labst + l_insme + l_speme + l_umlme.
    l_opqty = l_crstk - l_torec + l_toiss.

** get In-GR PO
*    READ TABLE itab_mseg WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_mseg WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    n = sy-tabix.
    LOOP AT itab_mseg FROM n.
      IF itab_mseg-werks = l_plant AND
         itab_mseg-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mseg-werks BETWEEN l_lplant AND l_hplant ) AND
         itab_mseg-lgort <> ' ' AND itab_mseg-lgort <> '1000' AND
         itab_mseg-lgort <> '10U0' AND itab_mseg-lgort <> '10D0' AND
         ( itab_mseg-budat BETWEEN l_lprd AND l_hprd ).

*  if ( itab_mseg-bwart = '101' or itab_mseg-bwart = '123' or
*     itab_mseg-bwart = '162' ) and itab_mseg-lifnr ne space
*     and itab_mseg-shkzg = 'S'.
        IF itab_mseg-bwart IN r_bwart1a1 AND itab_mseg-lifnr NE space
           AND itab_mseg-shkzg = 'S'.
          l_iqty1 = itab_mseg-menge + l_iqty1.
          l_ival1 = itab_mseg-dmbtr + l_ival1.

          sw = 1.
        ENDIF.

** get In-Allocation
*  if ( itab_mseg-bwart = '101' or itab_mseg-bwart = '642' or
*     itab_mseg-bwart = '301' or itab_mseg-bwart = '302' or
*     itab_mseg-bwart = '304' or itab_mseg-bwart = '305' ) and
*     itab_mseg-lifnr eq space and itab_mseg-shkzg = 'S'.
        IF itab_mseg-bwart IN r_bwart1a2 AND
           itab_mseg-lifnr EQ space AND itab_mseg-shkzg = 'S'.

          l_iqty2 = itab_mseg-menge + l_iqty2.
          l_ival2 = itab_mseg-dmbtr + l_ival2.

          sw = 1.
        ENDIF.

** get In-Sales Return
*  if ( itab_mseg-bwart = '602' or itab_mseg-bwart = '653' or
*     itab_mseg-bwart = '655' or itab_mseg-bwart = '902' or
*     itab_mseg-bwart = '908' or itab_mseg-bwart = '910' or
*     itab_mseg-bwart = '911' or itab_mseg-bwart = '913' or
*     itab_mseg-bwart = '929' or itab_mseg-bwart = '930' or
*     itab_mseg-bwart = '933' ) and  itab_mseg-shkzg = 'S' .
*        IF itab_mseg-bwart IN r_bwart1a3 AND  itab_mseg-shkzg = 'S' .
        IF itab_mseg-bwart IN r_bwart1a3.
          IF itab_mseg-shkzg = 'S'.
            l_iqty3 = itab_mseg-menge + l_iqty3.
            l_ival3 = itab_mseg-dmbtr + l_ival3.
            sw = 1.
          ELSEIF itab_mseg-shkzg = 'H' .
            l_iqty3 = l_iqty3 - itab_mseg-menge.
            l_ival3 = l_ival3 - itab_mseg-dmbtr.
            sw = 1.
          ENDIF.
        ENDIF.

** get In-Other
*  if ( itab_mseg-bwart = '309' or itab_mseg-bwart = '310' or
*     itab_mseg-bwart = '311' or itab_mseg-bwart = '312' or
*     itab_mseg-bwart = '321' or itab_mseg-bwart = '322' or
*     itab_mseg-bwart = '343' or itab_mseg-bwart = '344' or
*     itab_mseg-bwart = '349' or itab_mseg-bwart = '350' or
*     itab_mseg-bwart = '541' or itab_mseg-bwart = '542' or
*     itab_mseg-bwart = '556' or itab_mseg-bwart = '561' or
*     itab_mseg-bwart = '565' or itab_mseg-bwart = '904' or
*     itab_mseg-bwart = '906' or itab_mseg-bwart = '921' or
*     itab_mseg-bwart = '923' or itab_mseg-bwart = '927' or
*     itab_mseg-bwart = '924' or itab_mseg-bwart = '925' ) and
*     itab_mseg-shkzg = 'S'.
        IF itab_mseg-bwart IN r_bwart1a4 AND
           itab_mseg-shkzg = 'S'.
          l_iqty4 = itab_mseg-menge + l_iqty4.
          l_ival4 = itab_mseg-dmbtr + l_ival4.

          sw = 1.
        ENDIF.

** get Out-Allocation
*  if ( itab_mseg-bwart = '102' or itab_mseg-bwart = '641' or
*     itab_mseg-bwart = '301' or itab_mseg-bwart = '302' or
*     itab_mseg-bwart = '303' or itab_mseg-bwart = '306' ) and
*     itab_mseg-shkzg = 'H' and itab_mseg-lifnr eq space.
        IF itab_mseg-bwart IN r_bwart1a5 AND
           itab_mseg-shkzg = 'H' AND itab_mseg-lifnr EQ space.
          l_oqty1 = itab_mseg-menge + l_oqty1.
          l_oval1 = itab_mseg-dmbtr + l_oval1.

          sw = 1.
        ENDIF.

** get Out-Sales
*  if ( itab_mseg-bwart = '601' or itab_mseg-bwart = '654' or
*     itab_mseg-bwart = '656' or itab_mseg-bwart = '901' or
*     itab_mseg-bwart = '907' or itab_mseg-bwart = '909' or
*     itab_mseg-bwart = '912' or itab_mseg-bwart = '914' or
*     itab_mseg-bwart = '928' or itab_mseg-bwart = '931' or
*     itab_mseg-bwart = '932' ) and itab_mseg-shkzg = 'H'.
*        IF  itab_mseg-bwart IN r_bwart1a6 AND itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1a6.
          IF itab_mseg-shkzg = 'H'.
            l_oqty2 = itab_mseg-menge + l_oqty2.
            l_oval2 = itab_mseg-dmbtr + l_oval2.
            sw = 1.
          ELSEIF itab_mseg-shkzg = 'S'.
            l_oqty2 =  l_oqty2 - itab_mseg-menge.
            l_oval2 =  l_oval2 - itab_mseg-dmbtr.
            sw = 1.
          ENDIF.
        ENDIF.

** get Out-Return to Principal
*  if ( itab_mseg-bwart = '102' or itab_mseg-bwart = '122' or
*      itab_mseg-bwart = '161' ) and itab_mseg-shkzg = 'H' and
*      itab_mseg-lifnr ne space.
        IF  itab_mseg-bwart IN r_bwart1a7 AND itab_mseg-shkzg = 'H' AND
            itab_mseg-lifnr NE space.
          l_oqty3 = itab_mseg-menge + l_oqty3.
          l_oval3 = itab_mseg-dmbtr + l_oval3.

          sw = 1.
        ENDIF.

** get Out-Other
*  if ( itab_mseg-bwart = '309' or itab_mseg-bwart = '310' or
*     itab_mseg-bwart = '311' or itab_mseg-bwart = '312' or
*     itab_mseg-bwart = '321' or itab_mseg-bwart = '322' or
*     itab_mseg-bwart = '343' or itab_mseg-bwart = '344' or
*     itab_mseg-bwart = '349' or itab_mseg-bwart = '350' or
*     itab_mseg-bwart = '541' or itab_mseg-bwart = '542' or
*     itab_mseg-bwart = '551' or itab_mseg-bwart = '555' or
*     itab_mseg-bwart = '562' or itab_mseg-bwart = '566' or
*     itab_mseg-bwart = '903' or itab_mseg-bwart = '905' or
*     itab_mseg-bwart = '920' or itab_mseg-bwart = '922' or
*     itab_mseg-bwart = '924' or itab_mseg-bwart = '925' or
*     itab_mseg-bwart = '926' ) and itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1a8 AND itab_mseg-shkzg = 'H'.
          l_oqty4 = itab_mseg-menge + l_oqty4.
          l_oval4 = itab_mseg-dmbtr + l_oval4.

          sw = 1.
        ENDIF.
        IF sw = 1.
          " delete ITAB_MSEG.
        ENDIF.
      ENDIF.
    ENDLOOP.

    l_enqty = l_opqty + l_iqty1 + l_iqty2 + l_iqty3 + l_iqty4 -
                        l_oqty1 - l_oqty2 - l_oqty3 - l_oqty4.

* B0001
  ELSE.

* get Opening Stock
    READ TABLE itab_mard WITH KEY matnr = l_matnr BINARY SEARCH.
    l = sy-tabix.
    LOOP AT itab_mard FROM l.
      IF itab_mard-matnr <> l_matnr.
        EXIT.
      ENDIF.
*  loop at itab_mard where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mard-werks BETWEEN l_lplant AND l_hplant ) AND
         itab_mard-lgort <> ' ' AND itab_mard-lgort <> '1000' AND
         itab_mard-lgort <> '10U0' AND itab_mard-lgort <> '10D0'.
        l_labst = itab_mard-labst + l_labst.
        l_speme = itab_mard-speme + l_speme.
        l_insme = itab_mard-insme + l_insme.
        l_umlme = itab_mard-umlme + l_umlme.

        " delete ITAB_MARD.
      ENDIF.
    ENDLOOP.

    READ TABLE itab_s031 WITH KEY matnr = l_matnr BINARY SEARCH.
    m = sy-tabix.
    LOOP AT itab_s031 FROM m.
      IF itab_s031-matnr <> l_matnr.
        EXIT.
      ENDIF.
*  loop at itab_s031 where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_s031-werks BETWEEN l_lplant AND l_hplant ) AND
         itab_s031-lgort <> ' ' AND itab_s031-lgort <> '1000' AND
         itab_s031-lgort <> '10U0' AND itab_s031-lgort <> '10D0' AND
         ( itab_s031-spmon <= l_crprd AND itab_s031-spmon >= s_perd-low ).
        l_torec = itab_s031-mzubb + l_torec.
        l_toiss = itab_s031-magbb + l_toiss.

        " delete ITAB_S031.
      ENDIF.
    ENDLOOP.

    l_crstk = l_labst + l_insme + l_speme + l_umlme.
    l_opqty = l_crstk - l_torec + l_toiss.

** get In-GR PO
    READ TABLE itab_mseg WITH KEY matnr = l_matnr BINARY SEARCH.
    n = sy-tabix.
    LOOP AT itab_mseg FROM n.
      IF itab_mseg-matnr <> l_matnr.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mseg-werks BETWEEN l_lplant AND l_hplant ) AND
         itab_mseg-lgort <> ' ' AND itab_mseg-lgort <> '1000' AND
         itab_mseg-lgort <> '10U0' AND itab_mseg-lgort <> '10D0' AND
         ( itab_mseg-budat BETWEEN l_lprd AND l_hprd ).

*  if ( itab_mseg-bwart = '101' or itab_mseg-bwart = '123' or
*     itab_mseg-bwart = '162' ) and itab_mseg-lifnr ne space
*     and itab_mseg-shkzg = 'S'.
        IF itab_mseg-bwart IN r_bwart1a1 AND itab_mseg-lifnr NE space
           AND itab_mseg-shkzg = 'S'.
          l_iqty1 = itab_mseg-menge + l_iqty1.
          l_ival1 = itab_mseg-dmbtr + l_ival1.

          sw = 1.
        ENDIF.

** get In-Allocation
*  if ( itab_mseg-bwart = '101' or itab_mseg-bwart = '642' or
*     itab_mseg-bwart = '301' or itab_mseg-bwart = '302' or
*     itab_mseg-bwart = '304' or itab_mseg-bwart = '305' ) and
*     itab_mseg-lifnr eq space and itab_mseg-shkzg = 'S'.
        IF itab_mseg-bwart IN r_bwart1a2 AND
           itab_mseg-lifnr EQ space AND itab_mseg-shkzg = 'S'.

          l_iqty2 = itab_mseg-menge + l_iqty2.
          l_ival2 = itab_mseg-dmbtr + l_ival2.

          sw = 1.
        ENDIF.

** get In-Sales Return
*  if ( itab_mseg-bwart = '602' or itab_mseg-bwart = '653' or
*     itab_mseg-bwart = '655' or itab_mseg-bwart = '902' or
*     itab_mseg-bwart = '908' or itab_mseg-bwart = '910' or
*     itab_mseg-bwart = '911' or itab_mseg-bwart = '913' or
*     itab_mseg-bwart = '929' or itab_mseg-bwart = '930' or
*     itab_mseg-bwart = '933' ) and  itab_mseg-shkzg = 'S' .
*        IF itab_mseg-bwart IN r_bwart1a3 AND  itab_mseg-shkzg = 'S' .
        IF itab_mseg-bwart IN r_bwart1a3.
          IF itab_mseg-shkzg = 'S'.
            l_iqty3 = itab_mseg-menge + l_iqty3.
            l_ival3 = itab_mseg-dmbtr + l_ival3.
            sw = 1.
          ELSEIF itab_mseg-shkzg = 'H' .
            l_iqty3 = l_iqty3 - itab_mseg-menge.
            l_ival3 = l_ival3 - itab_mseg-dmbtr.
            sw = 1.
          ENDIF.
        ENDIF.

** get In-Other
*  if ( itab_mseg-bwart = '309' or itab_mseg-bwart = '310' or
*     itab_mseg-bwart = '311' or itab_mseg-bwart = '312' or
*     itab_mseg-bwart = '321' or itab_mseg-bwart = '322' or
*     itab_mseg-bwart = '343' or itab_mseg-bwart = '344' or
*     itab_mseg-bwart = '349' or itab_mseg-bwart = '350' or
*     itab_mseg-bwart = '541' or itab_mseg-bwart = '542' or
*     itab_mseg-bwart = '556' or itab_mseg-bwart = '561' or
*     itab_mseg-bwart = '565' or itab_mseg-bwart = '904' or
*     itab_mseg-bwart = '906' or itab_mseg-bwart = '921' or
*     itab_mseg-bwart = '923' or itab_mseg-bwart = '927' or
*     itab_mseg-bwart = '924' or itab_mseg-bwart = '925' ) and
*     itab_mseg-shkzg = 'S'.
        IF itab_mseg-bwart IN r_bwart1a4 AND
           itab_mseg-shkzg = 'S'.
          l_iqty4 = itab_mseg-menge + l_iqty4.
          l_ival4 = itab_mseg-dmbtr + l_ival4.

          sw = 1.
        ENDIF.

** get Out-Allocation
*  if ( itab_mseg-bwart = '102' or itab_mseg-bwart = '641' or
*     itab_mseg-bwart = '301' or itab_mseg-bwart = '302' or
*     itab_mseg-bwart = '303' or itab_mseg-bwart = '306' ) and
*     itab_mseg-shkzg = 'H' and itab_mseg-lifnr eq space.
        IF itab_mseg-bwart IN r_bwart1a5 AND
           itab_mseg-shkzg = 'H' AND itab_mseg-lifnr EQ space.
          l_oqty1 = itab_mseg-menge + l_oqty1.
          l_oval1 = itab_mseg-dmbtr + l_oval1.

          sw = 1.
        ENDIF.

** get Out-Sales
*  if ( itab_mseg-bwart = '601' or itab_mseg-bwart = '654' or
*     itab_mseg-bwart = '656' or itab_mseg-bwart = '901' or
*     itab_mseg-bwart = '907' or itab_mseg-bwart = '909' or
*     itab_mseg-bwart = '912' or itab_mseg-bwart = '914' or
*     itab_mseg-bwart = '928' or itab_mseg-bwart = '931' or
*     itab_mseg-bwart = '932' ) and itab_mseg-shkzg = 'H'.
*        IF  itab_mseg-bwart IN r_bwart1a6 AND itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1a6.
          IF itab_mseg-shkzg = 'H'.
            l_oqty2 = itab_mseg-menge + l_oqty2.
            l_oval2 = itab_mseg-dmbtr + l_oval2.
            sw = 1.
          ELSEIF itab_mseg-shkzg = 'S'.
            l_oqty2 =  l_oqty2 - itab_mseg-menge.
            l_oval2 =  l_oval2 - itab_mseg-dmbtr.
            sw = 1.
          ENDIF.
        ENDIF.

** get Out-Return to Principal
*  if ( itab_mseg-bwart = '102' or itab_mseg-bwart = '122' or
*      itab_mseg-bwart = '161' ) and itab_mseg-shkzg = 'H' and
*      itab_mseg-lifnr ne space.
        IF  itab_mseg-bwart IN r_bwart1a7 AND itab_mseg-shkzg = 'H' AND
            itab_mseg-lifnr NE space.
          l_oqty3 = itab_mseg-menge + l_oqty3.
          l_oval3 = itab_mseg-dmbtr + l_oval3.

          sw = 1.
        ENDIF.

** get Out-Other
*  if ( itab_mseg-bwart = '309' or itab_mseg-bwart = '310' or
*     itab_mseg-bwart = '311' or itab_mseg-bwart = '312' or
*     itab_mseg-bwart = '321' or itab_mseg-bwart = '322' or
*     itab_mseg-bwart = '343' or itab_mseg-bwart = '344' or
*     itab_mseg-bwart = '349' or itab_mseg-bwart = '350' or
*     itab_mseg-bwart = '541' or itab_mseg-bwart = '542' or
*     itab_mseg-bwart = '551' or itab_mseg-bwart = '555' or
*     itab_mseg-bwart = '562' or itab_mseg-bwart = '566' or
*     itab_mseg-bwart = '903' or itab_mseg-bwart = '905' or
*     itab_mseg-bwart = '920' or itab_mseg-bwart = '922' or
*     itab_mseg-bwart = '924' or itab_mseg-bwart = '925' or
*     itab_mseg-bwart = '926' ) and itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1a8 AND itab_mseg-shkzg = 'H'.
          l_oqty4 = itab_mseg-menge + l_oqty4.
          l_oval4 = itab_mseg-dmbtr + l_oval4.

          sw = 1.
        ENDIF.
      ENDIF.
      IF sw = 1.
        " delete ITAB_MSEG.
      ENDIF.

    ENDLOOP.

    l_enqty = l_opqty + l_iqty1 + l_iqty2 + l_iqty3 + l_iqty4 -
                        l_oqty1 - l_oqty2 - l_oqty3 - l_oqty4.

  ENDIF.

ENDFORM.                    " get_stock_in_sloc1b


************************************************************************
* FORM GET STOCK DATA IN STORAGE LOCATION CANVAS & HOSPITAL
************************************************************************
FORM get_stock_in_sloc1c.
  PERFORM clear_var_details.

  IF p_natio = space.                                       "B0001

* get Opening Stock
*    READ TABLE itab_mard WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_mard WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    r = sy-tabix.
    LOOP AT itab_mard FROM r.
      IF itab_mard-werks = l_plant AND
         itab_mard-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
*  loop at itab_mard where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mard-werks BETWEEN l_lplant AND l_hplant ) AND
         itab_mard-lgort = l_slocd.

        l_labst = itab_mard-labst + l_labst.
        l_speme = itab_mard-speme + l_speme.
        l_insme = itab_mard-insme + l_insme.
*        l_umlme = itab_mard-umlme + l_umlme.

        " delete ITAB_MARD.
      ENDIF.
    ENDLOOP.

*    READ TABLE itab_s031 WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_s031 WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    s = sy-tabix.
    LOOP AT itab_s031 FROM s.
      IF itab_s031-werks = l_plant AND
         itab_s031-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
*  loop at itab_s031 where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_s031-werks BETWEEN l_lplant AND l_hplant ) AND
         itab_s031-lgort = l_slocd AND
         ( itab_s031-spmon <= l_crprd AND itab_s031-spmon >= s_perd-low ).

        l_torec = itab_s031-mzubb + l_torec.
        l_toiss = itab_s031-magbb + l_toiss.

        " delete ITAB_S031.
      ENDIF.
    ENDLOOP.

    l_crstk = l_labst + l_insme + l_speme + l_umlme.
    l_opqty = l_crstk - l_torec + l_toiss.

*    READ TABLE itab_mseg WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_mseg WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    t = sy-tabix.
    LOOP AT itab_mseg FROM t.
      IF itab_mseg-werks = l_plant AND
         itab_mseg-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001

      IF itab_mseg-werks >= l_lplant AND itab_mseg-werks <= l_hplant AND
          itab_mseg-lgort  = l_slocd AND
          itab_mseg-budat >= l_lprd AND
          itab_mseg-budat <= l_hprd.

******** tambahan skd untuk sloc 10D0 and bwart 101
        IF itab_mseg-bwart IN r_bwart1c1 AND
           itab_mseg-shkzg = 'S'.

          l_iqty1 = itab_mseg-menge + l_iqty1.
          l_ival1 = itab_mseg-dmbtr + l_ival1.

          sw = 1.
        ENDIF.
** get In-Allocation
        IF itab_mseg-bwart IN r_bwart1c2 AND
           itab_mseg-lifnr EQ space AND itab_mseg-shkzg = 'S'.

          l_iqty2 = itab_mseg-menge + l_iqty2.
          l_ival2 = itab_mseg-dmbtr + l_ival2.

          sw = 1.
        ENDIF.

** get In-Sales Return
*  if ( itab_mseg-bwart = '602' or itab_mseg-bwart = '653' or
*     itab_mseg-bwart = '655' or itab_mseg-bwart = '902' or
*     itab_mseg-bwart = '908' or itab_mseg-bwart = '910' or
*     itab_mseg-bwart = '911' or itab_mseg-bwart = '913' or
*     itab_mseg-bwart = '929' or itab_mseg-bwart = '930' or
*     itab_mseg-bwart = '933' ) and  itab_mseg-shkzg = 'S' .
        IF itab_mseg-bwart IN r_bwart1c3 AND  itab_mseg-shkzg = 'S' .
          l_iqty3 = itab_mseg-menge + l_iqty3.
          l_ival3 = itab_mseg-dmbtr + l_ival3.

          sw = 1.
        ENDIF.

** get In-Other
*  if ( itab_mseg-bwart = '924' or itab_mseg-bwart = '925' ) and
*     itab_mseg-shkzg = 'S'.
        IF itab_mseg-bwart IN r_bwart1c4 AND
          itab_mseg-shkzg = 'S'.

          l_iqty4 = itab_mseg-menge + l_iqty4.
          l_ival4 = itab_mseg-dmbtr + l_ival4.

          sw = 1.
        ENDIF.

** get Out-Allocation
        IF itab_mseg-bwart IN r_bwart1c5 AND
           itab_mseg-shkzg = 'H' AND itab_mseg-lifnr EQ space.
          l_oqty1 = itab_mseg-menge + l_oqty1.
          l_oval1 = itab_mseg-dmbtr + l_oval1.

          sw = 1.
        ENDIF.

** get Out-Sales
*  if ( itab_mseg-bwart = '601' or itab_mseg-bwart = '654' or
*     itab_mseg-bwart = '656' or itab_mseg-bwart = '901' or
*     itab_mseg-bwart = '907' or itab_mseg-bwart = '909' or
*     itab_mseg-bwart = '912' or itab_mseg-bwart = '914' or
*     itab_mseg-bwart = '928' or itab_mseg-bwart = '931' or
*     itab_mseg-bwart = '932' ) and itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1c6 AND itab_mseg-shkzg = 'H'.
          l_oqty2 = itab_mseg-menge + l_oqty2.
          l_oval2 = itab_mseg-dmbtr + l_oval2.

          sw = 1.
        ENDIF.


** get Out-Other
*  if ( itab_mseg-bwart = '924' or itab_mseg-bwart = '925' ) and
*     itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1c8 AND
           itab_mseg-shkzg = 'H'.
          l_oqty4 = itab_mseg-menge + l_oqty4.
          l_oval4 = itab_mseg-dmbtr + l_oval4.

          sw = 1.
        ENDIF.
      ENDIF.
      IF sw = 0.
        " delete ITAB_MSEG.
      ENDIF.
    ENDLOOP.

    l_enqty = l_opqty + l_iqty1 + l_iqty2 + l_iqty3 + l_iqty4 -
                        l_oqty1 - l_oqty2 - l_oqty3 - l_oqty4.

* B0001
  ELSE.

* get Opening Stock
    READ TABLE itab_mard WITH KEY matnr = l_matnr BINARY SEARCH.
    r = sy-tabix.
    LOOP AT itab_mard FROM r.
      IF itab_mard-matnr <> l_matnr.
        EXIT.
      ENDIF.
*  loop at itab_mard where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mard-werks BETWEEN l_lplant AND l_hplant ) AND
         itab_mard-lgort = l_slocd.

        l_labst = itab_mard-labst + l_labst + l_umlme.
        l_speme = itab_mard-speme + l_speme.
        l_insme = itab_mard-insme + l_insme.

        " delete ITAB_MARD.
      ENDIF.
    ENDLOOP.

    READ TABLE itab_s031 WITH KEY matnr = l_matnr BINARY SEARCH.
    s = sy-tabix.
    LOOP AT itab_s031 FROM s.
      IF itab_s031-matnr <> l_matnr.
        EXIT.
      ENDIF.
*  loop at itab_s031 where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_s031-werks BETWEEN l_lplant AND l_hplant ) AND
         itab_s031-lgort = l_slocd AND
         ( itab_s031-spmon <= l_crprd AND itab_s031-spmon >= s_perd-low ).

        l_torec = itab_s031-mzubb + l_torec.
        l_toiss = itab_s031-magbb + l_toiss.

        " delete ITAB_S031.
      ENDIF.
    ENDLOOP.

    l_crstk = l_labst + l_insme + l_speme + l_umlme.
    l_opqty = l_crstk - l_torec + l_toiss.

    READ TABLE itab_mseg WITH KEY matnr = l_matnr BINARY SEARCH.
    t = sy-tabix.
    LOOP AT itab_mseg FROM t.
      IF itab_mseg-matnr <> l_matnr.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001

      IF itab_mseg-werks >= l_lplant AND itab_mseg-werks <= l_hplant AND
          itab_mseg-lgort  = l_slocd AND
          itab_mseg-budat >= l_lprd AND
          itab_mseg-budat <= l_hprd.

******** tambahan skd untuk sloc 10D0 and bwart 101
        IF itab_mseg-bwart IN r_bwart1c1 AND
           itab_mseg-shkzg = 'S'.
          l_iqty1 = itab_mseg-menge + l_iqty1.
          l_ival1 = itab_mseg-dmbtr + l_ival1.

          sw = 1.
        ENDIF.
** get In-Sales Return
*  if ( itab_mseg-bwart = '602' or itab_mseg-bwart = '653' or
*     itab_mseg-bwart = '655' or itab_mseg-bwart = '902' or
*     itab_mseg-bwart = '908' or itab_mseg-bwart = '910' or
*     itab_mseg-bwart = '911' or itab_mseg-bwart = '913' or
*     itab_mseg-bwart = '929' or itab_mseg-bwart = '930' or
*     itab_mseg-bwart = '933' ) and  itab_mseg-shkzg = 'S' .
        IF itab_mseg-bwart IN r_bwart1c3 AND  itab_mseg-shkzg = 'S' .
          l_iqty3 = itab_mseg-menge + l_iqty3.
          l_ival3 = itab_mseg-dmbtr + l_ival3.

          sw = 1.
        ENDIF.

** get In-Other
*  if ( itab_mseg-bwart = '924' or itab_mseg-bwart = '925' ) and
*     itab_mseg-shkzg = 'S'.
        IF itab_mseg-bwart IN r_bwart1c4 AND
          itab_mseg-shkzg = 'S'.

          l_iqty4 = itab_mseg-menge + l_iqty4.
          l_ival4 = itab_mseg-dmbtr + l_ival4.

          sw = 1.
        ENDIF.

** get Out-Allocation
        IF itab_mseg-bwart IN r_bwart1c5 AND
           itab_mseg-shkzg = 'H' AND itab_mseg-lifnr EQ space.
          l_oqty1 = itab_mseg-menge + l_oqty1.
          l_oval1 = itab_mseg-dmbtr + l_oval1.

          sw = 1.
        ENDIF.

** get Out-Sales
*  if ( itab_mseg-bwart = '601' or itab_mseg-bwart = '654' or
*     itab_mseg-bwart = '656' or itab_mseg-bwart = '901' or
*     itab_mseg-bwart = '907' or itab_mseg-bwart = '909' or
*     itab_mseg-bwart = '912' or itab_mseg-bwart = '914' or
*     itab_mseg-bwart = '928' or itab_mseg-bwart = '931' or
*     itab_mseg-bwart = '932' ) and itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1c6 AND itab_mseg-shkzg = 'H'.
          l_oqty2 = itab_mseg-menge + l_oqty2.
          l_oval2 = itab_mseg-dmbtr + l_oval2.

          sw = 1.
        ENDIF.


** get Out-Other
*  if ( itab_mseg-bwart = '924' or itab_mseg-bwart = '925' ) and
*     itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1c8 AND
           itab_mseg-shkzg = 'H'.
          l_oqty4 = itab_mseg-menge + l_oqty4.
          l_oval4 = itab_mseg-dmbtr + l_oval4.

          sw = 1.
        ENDIF.
      ENDIF.
      IF sw = 1.
        " delete ITAB_MSEG.
      ENDIF.
    ENDLOOP.

    l_enqty = l_opqty + l_iqty1 + l_iqty2 + l_iqty3 + l_iqty4 -
                        l_oqty1 - l_oqty2 - l_oqty3 - l_oqty4.

  ENDIF.

ENDFORM.                    " get_stock_in_sloc1c

************************************************************************
* FORM GET STOCK DATA IN STORAGE LOCATION INTRANSIT
************************************************************************
FORM get_stock_in_sloc1d.
  PERFORM clear_var_details.
  CLEAR : l_umlmc, l_trame, l_recv1, l_recv2, l_issu1, l_issu2.
  l_slocd = 'INTRS'.

  IF p_natio = space.                                       "B0001

* GET OPENING STOCK
*    READ TABLE itab_marc WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_marc WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    u = sy-tabix.
    LOOP AT itab_marc FROM u.
      IF itab_marc-werks = l_plant AND
         itab_marc-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
*  loop at itab_marc where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF itab_marc-werks BETWEEN l_lplant AND l_hplant.
        l_umlmc = itab_marc-umlmc + l_umlmc.
        l_trame = itab_marc-trame + l_trame.

        " delete ITAB_MARC.
      ENDIF.
    ENDLOOP.
*GET IN - ALLOCATION
*    READ TABLE itab_mseg WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_mseg WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    v = sy-tabix.
    LOOP AT itab_mseg FROM v.
      IF itab_mseg-werks = l_plant AND
         itab_mseg-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mseg-werks BETWEEN l_lplant AND l_hplant ) AND
         ( itab_mseg-budat BETWEEN l_lprd AND sy-datum ).

*        if itab_mseg-shkzg = 'S' and
*           ( itab_mseg-bwart = '303' or itab_mseg-bwart = '641' ).
        IF itab_mseg-shkzg = 'S' AND
           itab_mseg-bwart IN r_bwart1d21.

          l_recv1 = itab_mseg-menge + l_recv1.

          sw = 1.
        ENDIF.

        IF itab_mseg-lifnr = space AND
*           ( itab_mseg-bwart = '306' or itab_mseg-bwart = '102' ).
           itab_mseg-bwart IN r_bwart1d22.

          l_recv2 = itab_mseg-menge + l_recv2.

          sw = 1.
        ENDIF.

        IF itab_mseg-shkzg = 'H' AND
*           ( itab_mseg-bwart = '304' or itab_mseg-bwart = '642' ).
           itab_mseg-bwart IN r_bwart1d23.
          l_issu1 = itab_mseg-menge + l_issu1.

          sw = 1.
        ENDIF.

        IF itab_mseg-lifnr = space AND
*           ( itab_mseg-bwart = '305' or itab_mseg-bwart = '101' ).
           itab_mseg-bwart IN r_bwart1d24.
          l_issu2 = itab_mseg-menge + l_issu2.

          sw = 1.
        ENDIF.
        IF sw = 1.
          " delete ITAB_MSEG.
        ENDIF.
      ENDIF.
    ENDLOOP.

    l_crstk = l_umlmc + l_trame.
    l_opqty = l_crstk + l_issu1 + l_issu2 - l_recv1 - l_recv2.

*GET IN - ALLOCATION
    CLEAR : l_recv1, l_recv2, l_rval1, l_rval2.

*    READ TABLE itab_mseg WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_mseg WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    w = sy-tabix.

    LOOP AT itab_mseg FROM w.
      IF itab_mseg-werks = l_plant AND
         itab_mseg-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mseg-werks BETWEEN l_lplant AND l_hplant ) AND
         ( itab_mseg-budat BETWEEN l_lprd AND l_hprd ).

*        if itab_mseg-shkzg = 'S' and
*           ( itab_mseg-bwart = '641' or itab_mseg-bwart = '303' ).
        IF itab_mseg-shkzg = 'S' AND
           itab_mseg-bwart IN r_bwart1d21.

          l_recv1 = itab_mseg-menge + l_recv1.

          sw = 1.
        ENDIF.

        IF itab_mseg-lifnr = space AND
*           ( itab_mseg-bwart = '306' or itab_mseg-bwart = '102' ).
           itab_mseg-bwart IN r_bwart1d22.
          l_recv2 = itab_mseg-menge + l_recv2.

          sw = 1.
        ENDIF.
        l_iqty2 = l_recv1 + l_recv2.


        IF itab_mseg-shkzg = 'S' AND
*           ( itab_mseg-bwart = '641' or itab_mseg-bwart = '303' ).
           itab_mseg-bwart IN r_bwart1d21.
          l_rval1 = itab_mseg-dmbtr + l_rval1.

          sw = 1.
        ENDIF.

        IF itab_mseg-lifnr = space AND
*           ( itab_mseg-bwart = '306' or itab_mseg-bwart = '102' ).
           itab_mseg-bwart IN r_bwart1d22.
          l_rval2 = itab_mseg-dmbtr + l_rval2.

          sw = 1.
        ENDIF.
      ENDIF.

      l_ival2 = l_rval1 + l_rval2.
      IF sw = 1.
        " delete ITAB_MSEG.
      ENDIF.

    ENDLOOP.

* GET OUT - ALLOCATION
    CLEAR : l_issu1, l_issu2, l_isva1, l_isva2.
*    READ TABLE itab_mseg WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_mseg WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    c = sy-tabix.
    LOOP AT itab_mseg FROM c.
      IF itab_mseg-werks = l_plant AND
         itab_mseg-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mseg-werks BETWEEN l_lplant AND l_hplant ) AND
         ( itab_mseg-budat BETWEEN l_lprd AND l_hprd ).

        IF itab_mseg-shkzg = 'H' AND
*           ( itab_mseg-bwart = '642' or itab_mseg-bwart = '304' ).
          itab_mseg-bwart IN r_bwart1d71.
          l_issu1 = itab_mseg-menge + l_issu1.

          sw = 1.
        ENDIF.

        IF itab_mseg-lifnr = space AND
*           ( itab_mseg-bwart = '305' or itab_mseg-bwart = '101' ).
          itab_mseg-bwart IN r_bwart1d72.
          l_issu2 = itab_mseg-menge + l_issu2.

          sw = 1.
        ENDIF.

        l_oqty1 = l_issu1 + l_issu2.

        IF itab_mseg-shkzg = 'H' AND
*           ( itab_mseg-bwart = '642' or itab_mseg-bwart = '304' ).
          itab_mseg-bwart IN r_bwart1d73.
          l_isva1 = itab_mseg-dmbtr + l_isva1.

          sw = 1.
        ENDIF.

        IF itab_mseg-lifnr = space AND
*           ( itab_mseg-bwart = '305' or itab_mseg-bwart = '101' ).
          itab_mseg-bwart IN r_bwart1d74.
          l_isva2 = itab_mseg-dmbtr + l_isva2.

          sw = 1.
        ENDIF.
      ENDIF.

      l_oval1 = l_isva1 + l_isva2.
      IF sw = 1.
        " delete ITAB_MSEG.
      ENDIF.
    ENDLOOP.

** get Ending Stock
    l_enqty = l_opqty + l_iqty1 + l_iqty2 + l_iqty3 + l_iqty4 -
              l_oqty1 - l_oqty2 - l_oqty3 - l_oqty4.
    PERFORM add_total.

    PERFORM print_detail.

* B0001
  ELSE.

* GET OPENING STOCK
    READ TABLE itab_marc WITH KEY matnr = l_matnr BINARY SEARCH.
    u = sy-tabix.
    LOOP AT itab_marc FROM u.
      IF itab_marc-matnr <> l_matnr.
        EXIT.
      ENDIF.
*  loop at itab_marc where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF itab_marc-werks BETWEEN l_lplant AND l_hplant.
        l_umlmc = itab_marc-umlmc + l_umlmc.
        l_trame = itab_marc-trame + l_trame.

        " delete ITAB_MARC.
      ENDIF.
    ENDLOOP.
*GET IN - ALLOCATION
    READ TABLE itab_mseg WITH KEY matnr = l_matnr BINARY SEARCH.
    v = sy-tabix.
    LOOP AT itab_mseg FROM v.
      IF itab_mseg-matnr <> l_matnr.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mseg-werks BETWEEN l_lplant AND l_hplant ) AND
         ( itab_mseg-budat BETWEEN l_lprd AND sy-datum ).

*        if itab_mseg-shkzg = 'S' and
*           ( itab_mseg-bwart = '303' or itab_mseg-bwart = '641' ).
        IF itab_mseg-shkzg = 'S' AND
           itab_mseg-bwart IN r_bwart1d21.

          l_recv1 = itab_mseg-menge + l_recv1.

          sw = 1.
        ENDIF.

        IF itab_mseg-lifnr = space AND
*           ( itab_mseg-bwart = '306' or itab_mseg-bwart = '102' ).
           itab_mseg-bwart IN r_bwart1d22.

          l_recv2 = itab_mseg-menge + l_recv2.

          sw = 1.
        ENDIF.

        IF itab_mseg-shkzg = 'H' AND
*           ( itab_mseg-bwart = '304' or itab_mseg-bwart = '642' ).
           itab_mseg-bwart IN r_bwart1d23.
          l_issu1 = itab_mseg-menge + l_issu1.

          sw = 1.
        ENDIF.

        IF itab_mseg-lifnr = space AND
*           ( itab_mseg-bwart = '305' or itab_mseg-bwart = '101' ).
           itab_mseg-bwart IN r_bwart1d24.
          l_issu2 = itab_mseg-menge + l_issu2.

          sw = 1.
        ENDIF.
      ENDIF.

      l_crstk = l_umlmc + l_trame.
      l_opqty = l_crstk + l_issu1 + l_issu2 - l_recv1 - l_recv2.
      IF sw = 1.
        " delete ITAB_MSEG.
      ENDIF.
    ENDLOOP.

*GET IN - ALLOCATION
    CLEAR : l_recv1, l_recv2, l_rval1, l_rval2.

    READ TABLE itab_mseg WITH KEY matnr = l_matnr BINARY SEARCH.
    w = sy-tabix.

    LOOP AT itab_mseg FROM w.
      IF itab_mseg-matnr <> l_matnr.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mseg-werks BETWEEN l_lplant AND l_hplant ) AND
         ( itab_mseg-budat BETWEEN l_lprd AND l_hprd ).

*        if itab_mseg-shkzg = 'S' and
*           ( itab_mseg-bwart = '641' or itab_mseg-bwart = '303' ).
        IF itab_mseg-shkzg = 'S' AND
           itab_mseg-bwart IN r_bwart1d21.

          l_recv1 = itab_mseg-menge + l_recv1.

          sw = 1.
        ENDIF.

        IF itab_mseg-lifnr = space AND
*           ( itab_mseg-bwart = '306' or itab_mseg-bwart = '102' ).
           itab_mseg-bwart IN r_bwart1d22.
          l_recv2 = itab_mseg-menge + l_recv2.

          sw = 1.
        ENDIF.
        l_iqty2 = l_recv1 + l_recv2.


        IF itab_mseg-shkzg = 'S' AND
*           ( itab_mseg-bwart = '641' or itab_mseg-bwart = '303' ).
           itab_mseg-bwart IN r_bwart1d21.
          l_rval1 = itab_mseg-dmbtr + l_rval1.

          sw = 1.
        ENDIF.

        IF itab_mseg-lifnr = space AND
*           ( itab_mseg-bwart = '306' or itab_mseg-bwart = '102' ).
           itab_mseg-bwart IN r_bwart1d22.
          l_rval2 = itab_mseg-dmbtr + l_rval2.

          sw = 1.
        ENDIF.
      ENDIF.

      l_ival2 = l_rval1 + l_rval2.

      IF sw = 1.
        " delete ITAB_MSEG.
      ENDIF.
    ENDLOOP.

* GET OUT - ALLOCATION
    CLEAR : l_issu1, l_issu2, l_isva1, l_isva2.
    READ TABLE itab_mseg WITH KEY matnr = l_matnr BINARY SEARCH.
    c = sy-tabix.
    LOOP AT itab_mseg FROM c.
      IF itab_mseg-matnr <> l_matnr.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mseg-werks BETWEEN l_lplant AND l_hplant ) AND
         ( itab_mseg-budat BETWEEN l_lprd AND l_hprd ).

        IF itab_mseg-shkzg = 'H' AND
*           ( itab_mseg-bwart = '642' or itab_mseg-bwart = '304' ).
          itab_mseg-bwart IN r_bwart1d71.
          l_issu1 = itab_mseg-menge + l_issu1.

          sw = 1.
        ENDIF.

        IF itab_mseg-lifnr = space AND
*           ( itab_mseg-bwart = '305' or itab_mseg-bwart = '101' ).
          itab_mseg-bwart IN r_bwart1d72.
          l_issu2 = itab_mseg-menge + l_issu2.

          sw = 1.
        ENDIF.

        l_oqty1 = l_issu1 + l_issu2.

        IF itab_mseg-shkzg = 'H' AND
*           ( itab_mseg-bwart = '642' or itab_mseg-bwart = '304' ).
          itab_mseg-bwart IN r_bwart1d73.
          l_isva1 = itab_mseg-dmbtr + l_isva1.

          sw = 1.
        ENDIF.

        IF itab_mseg-lifnr = space AND
*           ( itab_mseg-bwart = '305' or itab_mseg-bwart = '101' ).
          itab_mseg-bwart IN r_bwart1d74.
          l_isva2 = itab_mseg-dmbtr + l_isva2.

          sw = 1.
        ENDIF.
      ENDIF.

      l_oval1 = l_isva1 + l_isva2.
      IF sw = 1.
        " delete ITAB_MSEG.
      ENDIF.
    ENDLOOP.

** get Ending Stock
    l_enqty = l_opqty + l_iqty1 + l_iqty2 + l_iqty3 + l_iqty4 -
              l_oqty1 - l_oqty2 - l_oqty3 - l_oqty4.
    PERFORM add_total.

    PERFORM print_detail.

  ENDIF.

ENDFORM.                    " get_stock_in_sloc1d


************************************************************************
* FORM GET STOCK DATA IN SUBCONTRACTOR (PROVIDE TO VENDOR)
************************************************************************
FORM get_stock_in_sloc1e.
  PERFORM clear_var_details.
  CLEAR : l_recv1, l_recv2, l_issu1, l_lblab.
  l_slocd = 'PRINC'.

  IF p_natio = space.                                       "B0001

*GET OPENING STOCK
*    READ TABLE itab_mslb WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_mslb WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    x = sy-tabix.
    LOOP AT itab_mslb FROM x.
      IF itab_mslb-werks = l_plant AND
         itab_mslb-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
*  loop at itab_mslb where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mslb-werks BETWEEN l_lplant AND l_hplant ) AND
           itab_mslb-sobkz = 'O'.
        l_lblab = itab_mslb-lblab + l_lblab.

        " delete ITAB_MSLB.
      ENDIF.
    ENDLOOP.

* GET IN - OTHER
*    READ TABLE itab_mseg WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_mseg WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    y = sy-tabix.
    LOOP AT itab_mseg FROM y.
      IF itab_mseg-werks = l_plant AND
         itab_mseg-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mseg-werks BETWEEN l_lplant AND l_hplant ) AND
         ( itab_mseg-budat BETWEEN l_lprd AND sy-datum ).
*    if itab_mseg-bwart = '541' and itab_mseg-shkzg = 'S'.
        IF itab_mseg-bwart IN r_bwart1e41 AND itab_mseg-shkzg = 'S'.
          l_recv1 = itab_mseg-menge + l_recv1.

          sw = 1.
        ENDIF.

*    if itab_mseg-bwart = '542' and itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1e42 AND itab_mseg-shkzg = 'H'.
          l_issu1 = itab_mseg-menge + l_issu1.

          sw = 1.
        ENDIF.
      ENDIF.

      l_crstk = l_lblab.
      l_opqty = l_crstk + l_issu1 - l_recv1.

      IF sw = 1.
        " delete ITAB_MSEG.
      ENDIF.
    ENDLOOP.


* GET OUT - ALLOCATION
*    READ TABLE itab_mseg WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_mseg WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    z = sy-tabix.

    LOOP AT itab_mseg FROM z.

      IF itab_mseg-werks = l_plant AND
         itab_mseg-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mseg-werks BETWEEN l_lplant AND l_hplant ) AND
         ( itab_mseg-budat BETWEEN l_lprd AND l_hprd ).

*    if itab_mseg-shkzg = 'S' and itab_mseg-bwart = '541'.
        IF itab_mseg-shkzg = 'S' AND itab_mseg-bwart IN r_bwart1e71.

          l_iqty4 = itab_mseg-menge + l_iqty4.
          l_ival4 = itab_mseg-dmbtr + l_ival4.

          sw = 1.
        ENDIF.

*    if itab_mseg-shkzg = 'H' and itab_mseg-bwart = '542'.
        IF itab_mseg-shkzg = 'H' AND itab_mseg-bwart IN r_bwart1e72.
          l_oqty4 = itab_mseg-menge + l_oqty4.
          l_oval4 = itab_mseg-dmbtr + l_oval4.

          sw = 1.
        ENDIF.
        IF sw = 1.
          " delete ITAB_MSEG.
        ENDIF.
      ENDIF.
    ENDLOOP.

* get Ending Stock
    l_enqty = l_opqty + l_iqty1 + l_iqty2 + l_iqty3 + l_iqty4 -
                        l_oqty1 - l_oqty2 - l_oqty3 - l_oqty4 .

    PERFORM add_total.
    PERFORM print_detail.

* B0001
  ELSE.

*GET OPENING STOCK
    READ TABLE itab_mslb WITH KEY matnr = l_matnr BINARY SEARCH.
    x = sy-tabix.
    LOOP AT itab_mslb FROM x.
      IF itab_mslb-matnr <> l_matnr.
        EXIT.
      ENDIF.
*  loop at itab_mslb where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mslb-werks BETWEEN l_lplant AND l_hplant ) AND
           itab_mslb-sobkz = 'O'.
        l_lblab = itab_mslb-lblab + l_lblab.

        " delete ITAB_MSLB.
      ENDIF.
    ENDLOOP.

* GET IN - OTHER
    READ TABLE itab_mseg WITH KEY matnr = l_matnr BINARY SEARCH.
    y = sy-tabix.
    LOOP AT itab_mseg FROM y.
      IF itab_mseg-matnr <> l_matnr.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mseg-werks BETWEEN l_lplant AND l_hplant ) AND
         ( itab_mseg-budat BETWEEN l_lprd AND sy-datum ).
*    if itab_mseg-bwart = '541' and itab_mseg-shkzg = 'S'.
        IF itab_mseg-bwart IN r_bwart1e41 AND itab_mseg-shkzg = 'S'.
          l_recv1 = itab_mseg-menge + l_recv1.

          sw = 1.
        ENDIF.

*    if itab_mseg-bwart = '542' and itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1e42 AND itab_mseg-shkzg = 'H'.
          l_issu1 = itab_mseg-menge + l_issu1.

          sw = 1.
        ENDIF.
      ENDIF.

      l_crstk = l_lblab.
      l_opqty = l_crstk + l_issu1 - l_recv1.
      IF sw = 1.
        " delete ITAB_MSEG.
      ENDIF.
    ENDLOOP.


* GET OUT - ALLOCATION
    READ TABLE itab_mseg WITH KEY matnr = l_matnr BINARY SEARCH.
    z = sy-tabix.

    LOOP AT itab_mseg FROM z.

      IF itab_mseg-matnr <> l_matnr.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mseg-werks BETWEEN l_lplant AND l_hplant ) AND
         ( itab_mseg-budat BETWEEN l_lprd AND l_hprd ).

*    if itab_mseg-shkzg = 'S' and itab_mseg-bwart = '541'.
        IF itab_mseg-shkzg = 'S' AND itab_mseg-bwart IN r_bwart1e71.

          l_iqty4 = itab_mseg-menge + l_iqty4.
          l_ival4 = itab_mseg-dmbtr + l_ival4.

          sw = 1.
        ENDIF.

*    if itab_mseg-shkzg = 'H' and itab_mseg-bwart = '542'.
        IF itab_mseg-shkzg = 'H' AND itab_mseg-bwart IN r_bwart1e72.
          l_oqty4 = itab_mseg-menge + l_oqty4.
          l_oval4 = itab_mseg-dmbtr + l_oval4.

          sw = 1.
        ENDIF.
      ENDIF.
      IF sw = 1.
        " delete ITAB_MSEG.
      ENDIF.
    ENDLOOP.

* get Ending Stock
    l_enqty = l_opqty + l_iqty1 + l_iqty2 + l_iqty3 + l_iqty4 -
                        l_oqty1 - l_oqty2 - l_oqty3 - l_oqty4 .

    PERFORM add_total.
    PERFORM print_detail.

  ENDIF.

ENDFORM.                    " get_stock_in_sloc1e

*&---------------------------------------------------------------------*
*&      Form  get_stock_in_sloc1u
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_stock_in_sloc1u.

  PERFORM clear_var_details.

  IF p_natio = space.                                       "B0001

* get Opening Stock
*    READ TABLE itab_mard WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_mard WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    o = sy-tabix.
    LOOP AT itab_mard FROM o.
      IF itab_mard-werks = l_plant AND
         itab_mard-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
*  loop at itab_mard where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF itab_mard-werks BETWEEN l_lplant AND l_hplant AND
         itab_mard-lgort = l_slocd.
        l_labst = itab_mard-labst + l_labst.
        l_speme = itab_mard-speme + l_speme.
        l_insme = itab_mard-insme + l_insme.
*        l_umlme = itab_mard-umlme + l_umlme.

        " delete ITAB_MARD.
      ENDIF.
    ENDLOOP.

*    READ TABLE itab_s031 WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_s031 WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    p = sy-tabix.
    LOOP AT itab_s031 FROM p.
      IF itab_s031-werks = l_plant AND
         itab_s031-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
*  loop at itab_s031 where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF itab_s031-werks BETWEEN l_lplant AND l_hplant AND
         itab_s031-lgort = l_slocd AND
         itab_s031-spmon <= l_crprd AND itab_s031-spmon >= s_perd-low.
        l_torec = itab_s031-mzubb + l_torec.
        l_toiss = itab_s031-magbb + l_toiss.

        " delete ITAB_S031.
      ENDIF.
    ENDLOOP.

    l_crstk = l_labst + l_insme + l_speme + l_umlme.
    l_opqty = l_crstk - l_torec + l_toiss.

** get In-GR PO
*    READ TABLE itab_mseg WITH KEY werks = l_plant matnr = l_matnr
    READ TABLE itab_mseg WITH KEY matnr = l_matnr werks = l_plant
                                  BINARY SEARCH.
    q = sy-tabix.
    LOOP AT itab_mseg FROM q.
      IF itab_mseg-werks = l_plant AND
         itab_mseg-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mseg-werks BETWEEN l_lplant AND l_hplant ) AND
         itab_mseg-lgort = l_slocd AND
         ( itab_mseg-budat BETWEEN l_lprd AND l_hprd ).

*  if ( itab_mseg-bwart = '101' or itab_mseg-bwart = '123' or
*     itab_mseg-bwart = '162' ) and itab_mseg-lifnr ne space
*     and itab_mseg-shkzg = 'S'.
        IF  itab_mseg-bwart IN r_bwart1a1 AND itab_mseg-lifnr NE space
            AND itab_mseg-shkzg = 'S'.

          l_iqty1 = itab_mseg-menge + l_iqty1.
          l_ival1 = itab_mseg-dmbtr + l_ival1.
          sw = 1.
        ENDIF.

** get In-Allocation
*  if ( itab_mseg-bwart = '101' or itab_mseg-bwart = '642' or
*     itab_mseg-bwart = '301' or itab_mseg-bwart = '302' or
*     itab_mseg-bwart = '304' or itab_mseg-bwart = '305' ) and
*     itab_mseg-lifnr eq space and itab_mseg-shkzg = 'S'.
        IF  itab_mseg-bwart IN r_bwart1a2 AND
            itab_mseg-lifnr EQ space AND itab_mseg-shkzg = 'S'.

          l_iqty2 = itab_mseg-menge + l_iqty2.
          l_ival2 = itab_mseg-dmbtr + l_ival2.
          sw = 1.
        ENDIF.

** get In-Sales Return
*  if ( itab_mseg-bwart = '602' or itab_mseg-bwart = '653' or
*     itab_mseg-bwart = '655' or itab_mseg-bwart = '902' or
*     itab_mseg-bwart = '908' or itab_mseg-bwart = '910' or
*     itab_mseg-bwart = '911' or itab_mseg-bwart = '913' or
*     itab_mseg-bwart = '929' or itab_mseg-bwart = '930' or
*     itab_mseg-bwart = '933' ) and  itab_mseg-shkzg = 'S' .
*        IF itab_mseg-bwart IN r_bwart1a3 AND  itab_mseg-shkzg = 'S' .

        IF itab_mseg-bwart IN r_bwart1a3.
          IF itab_mseg-shkzg = 'S'.
            l_iqty3 = itab_mseg-menge + l_iqty3.
            l_ival3 = itab_mseg-dmbtr + l_ival3.
            sw = 1.
          ELSEIF itab_mseg-shkzg = 'H' .
            l_iqty3 = l_iqty3 - itab_mseg-menge.
            l_ival3 = l_ival3 - itab_mseg-dmbtr.
            sw = 1.
          ENDIF.
        ENDIF.

** get In-Other
*  if ( itab_mseg-bwart = '309' or itab_mseg-bwart = '310' or
*     itab_mseg-bwart = '311' or itab_mseg-bwart = '312' or
*     itab_mseg-bwart = '321' or itab_mseg-bwart = '322' or
*     itab_mseg-bwart = '343' or itab_mseg-bwart = '344' or
*     itab_mseg-bwart = '349' or itab_mseg-bwart = '350' or
*     itab_mseg-bwart = '541' or itab_mseg-bwart = '542' or
*     itab_mseg-bwart = '556' or itab_mseg-bwart = '561' or
*     itab_mseg-bwart = '565' or itab_mseg-bwart = '904' or
*     itab_mseg-bwart = '906' or itab_mseg-bwart = '921' or
*     itab_mseg-bwart = '923' or itab_mseg-bwart = '927' or
*     itab_mseg-bwart = '924' or itab_mseg-bwart = '925' ) and
        IF itab_mseg-bwart IN r_bwart1a4 AND
           itab_mseg-shkzg = 'S'.
          l_iqty4 = itab_mseg-menge + l_iqty4.
          l_ival4 = itab_mseg-dmbtr + l_ival4.
          sw = 1.
        ENDIF.

** get Out-Allocation
*  if ( itab_mseg-bwart = '102' or itab_mseg-bwart = '641' or
*     itab_mseg-bwart = '301' or itab_mseg-bwart = '302' or
*     itab_mseg-bwart = '303' or itab_mseg-bwart = '306' ) and
*     itab_mseg-shkzg = 'H' and itab_mseg-lifnr eq space.
        IF itab_mseg-bwart IN r_bwart1a5 AND
           itab_mseg-shkzg = 'H' AND itab_mseg-lifnr EQ space.
          l_oqty1 = itab_mseg-menge + l_oqty1.
          l_oval1 = itab_mseg-dmbtr + l_oval1.
          sw = 1.
        ENDIF.

** get Out-Sales
*  if ( itab_mseg-bwart = '601' or itab_mseg-bwart = '654' or
*     itab_mseg-bwart = '656' or itab_mseg-bwart = '901' or
*     itab_mseg-bwart = '907' or itab_mseg-bwart = '909' or
*     itab_mseg-bwart = '912' or itab_mseg-bwart = '914' or
*     itab_mseg-bwart = '928' or itab_mseg-bwart = '931' or
*     itab_mseg-bwart = '932' ) and itab_mseg-shkzg = 'H'.
*        IF itab_mseg-bwart IN r_bwart1a6 AND itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1a6.
          IF itab_mseg-shkzg = 'H'.
            l_oqty2 = itab_mseg-menge + l_oqty2.
            l_oval2 = itab_mseg-dmbtr + l_oval2.
            sw = 1.
          ELSEIF itab_mseg-shkzg = 'S'.
            l_oqty2 =  l_oqty2 - itab_mseg-menge.
            l_oval2 =  l_oval2 - itab_mseg-dmbtr.
            sw = 1.
          ENDIF.
        ENDIF.

** get Out-Return to Principal
*  if ( itab_mseg-bwart = '102' or itab_mseg-bwart = '122' or
*      itab_mseg-bwart = '161' ) and itab_mseg-shkzg = 'H' and
*      itab_mseg-lifnr ne space.
        IF  itab_mseg-bwart IN r_bwart1a7 AND itab_mseg-shkzg = 'H' AND
            itab_mseg-lifnr NE space.
          l_oqty3 = itab_mseg-menge + l_oqty3.
          l_oval3 = itab_mseg-dmbtr + l_oval3.
          sw = 1.
        ENDIF.

** get Out-Other
*  if ( itab_mseg-bwart = '309' or itab_mseg-bwart = '310' or
*     itab_mseg-bwart = '311' or itab_mseg-bwart = '312' or
*     itab_mseg-bwart = '321' or itab_mseg-bwart = '322' or
*     itab_mseg-bwart = '343' or itab_mseg-bwart = '344' or
*     itab_mseg-bwart = '349' or itab_mseg-bwart = '350' or
*     itab_mseg-bwart = '541' or itab_mseg-bwart = '542' or
*     itab_mseg-bwart = '551' or itab_mseg-bwart = '555' or
*     itab_mseg-bwart = '562' or itab_mseg-bwart = '566' or
*     itab_mseg-bwart = '903' or itab_mseg-bwart = '905' or
*     itab_mseg-bwart = '920' or itab_mseg-bwart = '922' or
*     itab_mseg-bwart = '924' or itab_mseg-bwart = '925' or
*     itab_mseg-bwart = '926' ) and itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1a8 AND itab_mseg-shkzg = 'H'.
          l_oqty4 = itab_mseg-menge + l_oqty4.
          l_oval4 = itab_mseg-dmbtr + l_oval4.
          sw = 1.
        ENDIF.
        IF sw = 1.
          " delete ITAB_MSEG.
        ENDIF.
      ENDIF.
    ENDLOOP.

** get Ending Stock
    l_enqty = l_opqty + l_iqty1 + l_iqty2 + l_iqty3 + l_iqty4 -
                        l_oqty1 - l_oqty2 - l_oqty3 - l_oqty4.

*  perform add_total.

* B0001
  ELSE.

* get Opening Stock
    READ TABLE itab_mard WITH KEY matnr = l_matnr BINARY SEARCH.
    o = sy-tabix.
    LOOP AT itab_mard FROM o.
      IF itab_mard-matnr <> l_matnr.
        EXIT.
      ENDIF.
*  loop at itab_mard where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF itab_mard-werks BETWEEN l_lplant AND l_hplant AND
         itab_mard-lgort = l_slocd.
        l_labst = itab_mard-labst + l_labst.
        l_speme = itab_mard-speme + l_speme.
        l_insme = itab_mard-insme + l_insme.
        l_umlme = itab_mard-umlme + l_umlme.

        " delete ITAB_MARD.
      ENDIF.
    ENDLOOP.

    READ TABLE itab_s031 WITH KEY matnr = l_matnr BINARY SEARCH.
    p = sy-tabix.
    LOOP AT itab_s031 FROM p.
      IF itab_s031-matnr <> l_matnr.
        EXIT.
      ENDIF.
*  loop at itab_s031 where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF itab_s031-werks BETWEEN l_lplant AND l_hplant AND
         itab_s031-lgort = l_slocd AND
         itab_s031-spmon <= l_crprd AND itab_s031-spmon >= s_perd-low.
        l_torec = itab_s031-mzubb + l_torec.
        l_toiss = itab_s031-magbb + l_toiss.

        " delete ITAB_S031.
      ENDIF.
    ENDLOOP.

    l_crstk = l_labst + l_insme + l_speme + l_umlme.
    l_opqty = l_crstk - l_torec + l_toiss.

** get In-GR PO
    READ TABLE itab_mseg WITH KEY matnr = l_matnr BINARY SEARCH.
    q = sy-tabix.
    LOOP AT itab_mseg FROM q.
      IF itab_mseg-matnr <> l_matnr.
        EXIT.
      ENDIF.
      sw = 0.
*  loop at itab_mseg where matnr = l_matnr and
*                          werks = l_plant.                       "B0001
      IF ( itab_mseg-werks BETWEEN l_lplant AND l_hplant ) AND
         itab_mseg-lgort = l_slocd AND
         ( itab_mseg-budat BETWEEN l_lprd AND l_hprd ).

*  if ( itab_mseg-bwart = '101' or itab_mseg-bwart = '123' or
*     itab_mseg-bwart = '162' ) and itab_mseg-lifnr ne space
*     and itab_mseg-shkzg = 'S'.
        IF  itab_mseg-bwart IN r_bwart1a1 AND itab_mseg-lifnr NE space
            AND itab_mseg-shkzg = 'S'.

          l_iqty1 = itab_mseg-menge + l_iqty1.
          l_ival1 = itab_mseg-dmbtr + l_ival1.

          sw = 1.
        ENDIF.

** get In-Allocation
*  if ( itab_mseg-bwart = '101' or itab_mseg-bwart = '642' or
*     itab_mseg-bwart = '301' or itab_mseg-bwart = '302' or
*     itab_mseg-bwart = '304' or itab_mseg-bwart = '305' ) and
*     itab_mseg-lifnr eq space and itab_mseg-shkzg = 'S'.
        IF  itab_mseg-bwart IN r_bwart1a2 AND
            itab_mseg-lifnr EQ space AND itab_mseg-shkzg = 'S'.

          l_iqty2 = itab_mseg-menge + l_iqty2.
          l_ival2 = itab_mseg-dmbtr + l_ival2.

          sw = 1.
        ENDIF.

** get In-Sales Return
*  if ( itab_mseg-bwart = '602' or itab_mseg-bwart = '653' or
*     itab_mseg-bwart = '655' or itab_mseg-bwart = '902' or
*     itab_mseg-bwart = '908' or itab_mseg-bwart = '910' or
*     itab_mseg-bwart = '911' or itab_mseg-bwart = '913' or
*     itab_mseg-bwart = '929' or itab_mseg-bwart = '930' or
*     itab_mseg-bwart = '933' ) and  itab_mseg-shkzg = 'S' .
*        IF itab_mseg-bwart IN r_bwart1a3 AND  itab_mseg-shkzg = 'S' .

        IF itab_mseg-bwart IN r_bwart1a3.
          IF itab_mseg-shkzg = 'S'.
            l_iqty3 = itab_mseg-menge + l_iqty3.
            l_ival3 = itab_mseg-dmbtr + l_ival3.
            sw = 1.
          ELSEIF itab_mseg-shkzg = 'H' .
            l_iqty3 = l_iqty3 - itab_mseg-menge.
            l_ival3 = l_ival3 - itab_mseg-dmbtr.
            sw = 1.
          ENDIF.
        ENDIF.

** get In-Other
*  if ( itab_mseg-bwart = '309' or itab_mseg-bwart = '310' or
*     itab_mseg-bwart = '311' or itab_mseg-bwart = '312' or
*     itab_mseg-bwart = '321' or itab_mseg-bwart = '322' or
*     itab_mseg-bwart = '343' or itab_mseg-bwart = '344' or
*     itab_mseg-bwart = '349' or itab_mseg-bwart = '350' or
*     itab_mseg-bwart = '541' or itab_mseg-bwart = '542' or
*     itab_mseg-bwart = '556' or itab_mseg-bwart = '561' or
*     itab_mseg-bwart = '565' or itab_mseg-bwart = '904' or
*     itab_mseg-bwart = '906' or itab_mseg-bwart = '921' or
*     itab_mseg-bwart = '923' or itab_mseg-bwart = '927' or
*     itab_mseg-bwart = '924' or itab_mseg-bwart = '925' ) and
        IF itab_mseg-bwart IN r_bwart1a4 AND
           itab_mseg-shkzg = 'S'.
          l_iqty4 = itab_mseg-menge + l_iqty4.
          l_ival4 = itab_mseg-dmbtr + l_ival4.

          sw = 1.
        ENDIF.

** get Out-Allocation
*  if ( itab_mseg-bwart = '102' or itab_mseg-bwart = '641' or
*     itab_mseg-bwart = '301' or itab_mseg-bwart = '302' or
*     itab_mseg-bwart = '303' or itab_mseg-bwart = '306' ) and
*     itab_mseg-shkzg = 'H' and itab_mseg-lifnr eq space.
        IF itab_mseg-bwart IN r_bwart1a5 AND
           itab_mseg-shkzg = 'H' AND itab_mseg-lifnr EQ space.
          l_oqty1 = itab_mseg-menge + l_oqty1.
          l_oval1 = itab_mseg-dmbtr + l_oval1.

          sw = 1.
        ENDIF.

** get Out-Sales
*  if ( itab_mseg-bwart = '601' or itab_mseg-bwart = '654' or
*     itab_mseg-bwart = '656' or itab_mseg-bwart = '901' or
*     itab_mseg-bwart = '907' or itab_mseg-bwart = '909' or
*     itab_mseg-bwart = '912' or itab_mseg-bwart = '914' or
*     itab_mseg-bwart = '928' or itab_mseg-bwart = '931' or
*     itab_mseg-bwart = '932' ) and itab_mseg-shkzg = 'H'.
*        IF itab_mseg-bwart IN r_bwart1a6 AND itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1a6.
          IF itab_mseg-shkzg = 'H'.
            l_oqty2 = itab_mseg-menge + l_oqty2.
            l_oval2 = itab_mseg-dmbtr + l_oval2.
            sw = 1.
          ELSEIF itab_mseg-shkzg = 'S'.
            l_oqty2 =  l_oqty2 - itab_mseg-menge.
            l_oval2 =  l_oval2 - itab_mseg-dmbtr.
            sw = 1.
          ENDIF.
        ENDIF.

** get Out-Return to Principal
*  if ( itab_mseg-bwart = '102' or itab_mseg-bwart = '122' or
*      itab_mseg-bwart = '161' ) and itab_mseg-shkzg = 'H' and
*      itab_mseg-lifnr ne space.
        IF  itab_mseg-bwart IN r_bwart1a7 AND itab_mseg-shkzg = 'H' AND
            itab_mseg-lifnr NE space.
          l_oqty3 = itab_mseg-menge + l_oqty3.
          l_oval3 = itab_mseg-dmbtr + l_oval3.

          sw = 1.
        ENDIF.

** get Out-Other
*  if ( itab_mseg-bwart = '309' or itab_mseg-bwart = '310' or
*     itab_mseg-bwart = '311' or itab_mseg-bwart = '312' or
*     itab_mseg-bwart = '321' or itab_mseg-bwart = '322' or
*     itab_mseg-bwart = '343' or itab_mseg-bwart = '344' or
*     itab_mseg-bwart = '349' or itab_mseg-bwart = '350' or
*     itab_mseg-bwart = '541' or itab_mseg-bwart = '542' or
*     itab_mseg-bwart = '551' or itab_mseg-bwart = '555' or
*     itab_mseg-bwart = '562' or itab_mseg-bwart = '566' or
*     itab_mseg-bwart = '903' or itab_mseg-bwart = '905' or
*     itab_mseg-bwart = '920' or itab_mseg-bwart = '922' or
*     itab_mseg-bwart = '924' or itab_mseg-bwart = '925' or
*     itab_mseg-bwart = '926' ) and itab_mseg-shkzg = 'H'.
        IF itab_mseg-bwart IN r_bwart1a8 AND itab_mseg-shkzg = 'H'.
          l_oqty4 = itab_mseg-menge + l_oqty4.
          l_oval4 = itab_mseg-dmbtr + l_oval4.

          sw = 1.
        ENDIF.
        IF sw = 1.
          " delete ITAB_MSEG.
        ENDIF.
      ENDIF.
    ENDLOOP.

** get Ending Stock
    l_enqty = l_opqty + l_iqty1 + l_iqty2 + l_iqty3 + l_iqty4 -
                        l_oqty1 - l_oqty2 - l_oqty3 - l_oqty4.

*  perform add_total.

  ENDIF.

ENDFORM.                    " get_stock_in_sloc1u

************************************************************************
* Form Print Detail
************************************************************************
FORM print_detail.
********* Checking no transaksi tidak dicetak *******
**** By Sukardi *****
**** Req By MKO  (10-03-2005) ******
  IF l_opqty = 0 AND
     l_iqty1 = 0 AND
     l_ival1 = 0 AND
     l_iqty2 = 0 AND
     l_ival2 = 0 AND
     l_iqty3 = 0 AND
     l_ival3 = 0 AND
     l_iqty4 = 0 AND
     l_ival4 = 0 AND
     l_oqty1 = 0 AND
     l_oval1 = 0 AND
     l_oqty2 = 0 AND
     l_oval2 = 0 AND
     l_oqty3 = 0 AND
     l_oval3 = 0 AND
     l_oqty4 = 0 AND
     l_oval4 = 0 AND
     l_enqty = 0.
    EXIT.
  ENDIF.

**** End Check ******


  FORMAT COLOR OFF.
  IF v_flag <> 'X'.
    WRITE: l_matnr,
           20 l_matds,
           61 l_matgr,
           l_meins.
    MOVE 'X' TO v_flag.
  ENDIF.
  CASE l_slocd.
    WHEN '1000'.
      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
      WRITE: /21 l_slocd.
    WHEN '10U0'.
      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
      WRITE: /21 l_slocd.
    WHEN 'CV+RS'.
      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
      WRITE: /21 l_slocd.
    WHEN '10D0'.
      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
      WRITE: /21 l_slocd.
    WHEN 'INTRS'.
      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
      WRITE: / l_plant,
              21   l_slocd.
    WHEN OTHERS.
      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
      WRITE: /21   l_slocd.
  ENDCASE.

*  l_ival1 = l_ival1 * 100.
*  l_ival2 = l_ival2 * 100.
*  l_ival3 = l_ival3 * 100.
*  l_ival4 = l_ival4 * 100.
*  l_oval1 = l_oval1 * 100.
*  l_oval2 = l_oval2 * 100.
*  l_oval3 = l_oval3 * 100.
*  l_oval4 = l_oval4 * 100.

  WRITE:      27(11) l_opqty DECIMALS 2,
              38(11) l_iqty1 DECIMALS 2,
              49(14) l_ival1 CURRENCY 'IDR',
              63(11) l_iqty2 DECIMALS 2,
              74(14) l_ival2 CURRENCY 'IDR',
              88(11) l_iqty3 DECIMALS 2,
              99(14) l_ival3 CURRENCY 'IDR',
             113(11) l_iqty4 DECIMALS 2,
             124(14) l_ival4 CURRENCY 'IDR',
             138(11) l_oqty1 DECIMALS 2,
             149(14) l_oval1 CURRENCY 'IDR',
             163(11) l_oqty2 DECIMALS 2,
             174(14) l_oval2 CURRENCY 'IDR',
             188(11) l_oqty3 DECIMALS 2,
             199(14) l_oval3 CURRENCY 'IDR',
             213(11) l_oqty4 DECIMALS 2,
             224(14) l_oval4 CURRENCY 'IDR',
             238(11) l_enqty DECIMALS 2.

ENDFORM.                    "print_detail

************************************************************************
* Form ADD TO TOTAL & GRAND TOTAL
************************************************************************
FORM add_total.

* ADD TO TOTAL
  ADD l_opqty TO l_topqty.
  ADD l_iqty1 TO l_tiqty1.
  ADD l_ival1 TO l_tival1.
  ADD l_iqty2 TO l_tiqty2.
  ADD l_ival2 TO l_tival2.
  ADD l_iqty3 TO l_tiqty3.
  ADD l_ival3 TO l_tival3.
  ADD l_iqty4 TO l_tiqty4.
  ADD l_ival4 TO l_tival4.
  ADD l_oqty1 TO l_toqty1.
  ADD l_oval1 TO l_toval1.
  ADD l_oqty2 TO l_toqty2.
  ADD l_oval2 TO l_toval2.
  ADD l_oqty3 TO l_toqty3.
  ADD l_oval3 TO l_toval3.
  ADD l_oqty4 TO l_toqty4.
  ADD l_oval4 TO l_toval4.
  ADD l_enqty TO l_tenqty.

* ADD TO GRAND TOTAL
  ADD l_ival1 TO l_gival1.
  ADD l_ival2 TO l_gival2.
  ADD l_ival3 TO l_gival3.
  ADD l_ival4 TO l_gival4.
  ADD l_oval1 TO l_goval1.
  ADD l_oval2 TO l_goval2.
  ADD l_oval3 TO l_goval3.
  ADD l_oval4 TO l_goval4.

ENDFORM.                    "add_total

************************************************************************
* Form Print Total
************************************************************************
FORM print_total USING fu_matnr fu_werks.
* GET SUMMARY STOCK VALUE IN & OUT REFER TO MATERIAL DOCUMENT DOC
  l_tcrinv = l_toval1 + l_toval2 + l_toval3 + l_toval4 .
  l_tdbinv = l_tival1 + l_tival2 + l_tival3 + l_tival4.


  IF p_natio = space.                                       "B0001

* GET CURRENT STOCK VALUE

    CLEAR: l_tcracc, l_tdbacc, l_tcrpsw, l_tdbpsw, l_tsalk3.
    l_tsalk3 = 0.
*    READ TABLE itab_mbew WITH KEY bwkey = l_plant matnr = l_matnr
    READ TABLE itab_mbew WITH KEY matnr = l_matnr bwkey = l_plant
                                  BINARY SEARCH.
    a = sy-tabix.
    LOOP AT itab_mbew FROM a.
      IF itab_mbew-bwkey = l_plant AND
         itab_mbew-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
*  loop at itab_mbew where matnr = l_matnr.                       "B0001
      IF itab_mbew-bwkey BETWEEN l_lplant AND l_hplant.
        l_tsalk3 = itab_mbew-salk3 + l_tsalk3.
      ENDIF.
    ENDLOOP.

*    READ TABLE itab_bsim WITH KEY bwkey = l_plant matnr = l_matnr
    READ TABLE itab_bsim WITH KEY matnr = l_matnr bwkey = l_plant
                                  BINARY SEARCH.
    b = sy-tabix.

    LOOP AT itab_bsim FROM b.
      IF itab_bsim-bwkey = l_plant AND
         itab_bsim-matnr = l_matnr.
      ELSE.
        EXIT.
      ENDIF.
*  loop at itab_bsim where matnr = l_matnr.                       "B0001

      IF itab_bsim-bwkey BETWEEN l_lplant AND l_hplant.
        IF itab_bsim-budat >= l_lprd AND itab_bsim-budat <= l_hprd AND
           itab_bsim-gjahr >= l_lyear AND itab_bsim-gjahr <= l_hyear.
          IF  itab_bsim-shkzg = 'H'.
            l_tcracc = itab_bsim-dmbtr + l_tcracc.
          ELSEIF itab_bsim-shkzg = 'S'.
            l_tdbacc = itab_bsim-dmbtr + l_tdbacc.
          ENDIF.
        ENDIF.

* GET SUMMARY STOCK VAL IN & OUT REFER TO ACCT. DOC WITHIN CURRENT
* PERIOD TO BEGINNING PERIOD.

        IF itab_bsim-budat >= l_lprd AND itab_bsim-budat <= sy-datum AND
          itab_bsim-gjahr >= l_lyear AND itab_bsim-gjahr <= sy-datum+0(4).
          IF itab_bsim-shkzg = 'H'.
            l_tcrpsw = itab_bsim-dmbtr + l_tcrpsw.
          ELSEIF itab_bsim-shkzg = 'S'.
            l_tdbpsw = itab_bsim-dmbtr + l_tdbpsw.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

* B0001
  ELSE.

* GET CURRENT STOCK VALUE

    CLEAR: l_tcracc, l_tdbacc, l_tcrpsw, l_tdbpsw, l_tsalk3.
    l_tsalk3 = 0.
    READ TABLE itab_mbew WITH KEY matnr = l_matnr BINARY SEARCH.
    a = sy-tabix.
    LOOP AT itab_mbew FROM a.
      IF itab_mbew-matnr <> l_matnr.
        EXIT.
      ENDIF.
*  loop at itab_mbew where matnr = l_matnr.                       "B0001
      IF itab_mbew-bwkey BETWEEN l_lplant AND l_hplant.
        l_tsalk3 = itab_mbew-salk3 + l_tsalk3.
      ENDIF.
    ENDLOOP.

    READ TABLE itab_bsim WITH KEY matnr = l_matnr BINARY SEARCH.
    b = sy-tabix.
    LOOP AT itab_bsim FROM b.
      IF itab_bsim-matnr <> l_matnr.
        EXIT.
      ENDIF.
*  loop at itab_bsim where matnr = l_matnr.                       "B0001

      IF itab_bsim-bwkey BETWEEN l_lplant AND l_hplant.
        IF itab_bsim-budat >= l_lprd AND itab_bsim-budat <= l_hprd AND
           itab_bsim-gjahr >= l_lyear AND itab_bsim-gjahr <= l_hyear.
          IF  itab_bsim-shkzg = 'H'.
            l_tcracc = itab_bsim-dmbtr + l_tcracc.
          ELSEIF itab_bsim-shkzg = 'S'.
            l_tdbacc = itab_bsim-dmbtr + l_tdbacc.
          ENDIF.
        ENDIF.

* GET SUMMARY STOCK VAL IN & OUT REFER TO ACCT. DOC WITHIN CURRENT
* PERIOD TO BEGINNING PERIOD.

        IF itab_bsim-budat >= l_lprd AND itab_bsim-budat <= sy-datum AND
          itab_bsim-gjahr >= l_lyear AND itab_bsim-gjahr <= sy-datum+0(4).
          IF itab_bsim-shkzg = 'H'.
            l_tcrpsw = itab_bsim-dmbtr + l_tcrpsw.
          ELSEIF itab_bsim-shkzg = 'S'.
            l_tdbpsw = itab_bsim-dmbtr + l_tdbpsw.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.

* GET OPENING STOCK VALUE
  l_topbal = l_tsalk3 + l_tcrpsw - l_tdbpsw.

  IF fu_werks IS NOT INITIAL.
*    CLEAR l_topbal.
*    READ TABLE gt_mbewh WITH KEY matnr = fu_matnr
*                                 bwkey = fu_werks.
*    IF sy-subrc EQ 0.
*      l_topbal  =  gt_mbewh-salk3.
*    ENDIF.
*    IF l_topbal IS INITIAL.
    READ TABLE gt_s039 WITH KEY matnr = fu_matnr
                                werks = fu_werks.
    IF sy-subrc EQ 0.
      CLEAR l_topbal.
      l_topbal  =  gt_s039-wbwbest.
    ENDIF.
*    ENDIF.
  ELSE.
*    CLEAR l_topbal.
*    READ TABLE gt_mbewh WITH KEY matnr = fu_matnr.
*    IF sy-subrc EQ 0.
*      l_topbal  =  gt_mbewh-salk3.
*    ENDIF.
*    IF l_topbal IS INITIAL.
    READ TABLE gt_s039 WITH KEY matnr = fu_matnr.
    IF sy-subrc EQ 0.
      CLEAR l_topbal.
      l_topbal  =  gt_s039-wbwbest.
    ENDIF.
*    ENDIF.
  ENDIF.

*  IF l_topbal < 0.
*    CLEAR l_topbal.
*  ENDIF.

* GET ENDING STOCK VALUE
  l_tenbal = l_topbal + l_tdbacc - l_tcracc.

* GET VALUE OF OTHER
  l_tother = l_tdbacc - l_tcracc - l_tdbinv + l_tcrinv.

* ADD TO GRAND TOTAL
  l_gopbal = l_gopbal + l_topbal.
  l_gdbinv = l_gdbinv + l_tdbinv.
  l_gdbacc = l_gdbacc + l_tdbacc.
  l_gcrinv = l_gcrinv + l_tcrinv.
  l_gcracc = l_gcracc + l_tcracc.
  l_gother = l_gother + l_tother.
  l_genbal = l_genbal + l_tenbal.

* PRINT
*  l_tival1 = l_tival1 * 100.
*  l_tival2 = l_tival2 * 100.
*  l_tival3 = l_tival3 * 100.
*  l_tival4 = l_tival4 * 100.
*  l_toval1 = l_toval1 * 100.
*  l_toval2 = l_toval2 * 100.
*  l_toval3 = l_toval3 * 100.
*  l_toval4 = l_toval4 * 100.


********* Checking no transaksi tidak dicetak *******
**** By Sukardi *****
**** Req By MKO  (10-03-2005) ******
  IF l_topqty = 0 AND
     l_tiqty1 = 0 AND
     l_tival1 = 0 AND
     l_tiqty2 = 0 AND
     l_tival2 = 0 AND
     l_tiqty3 = 0 AND
     l_tival3 = 0 AND
     l_tiqty4 = 0 AND
     l_tival4 = 0 AND
     l_toqty1 = 0 AND
     l_toval1 = 0 AND
     l_toqty2 = 0 AND
     l_toval2 = 0 AND
     l_toqty3 = 0 AND
     l_toval3 = 0 AND
     l_toqty4 = 0 AND
     l_toval4 = 0 AND
     l_tenqty = 0.
    EXIT.
  ENDIF.

**** End Check ******




  FORMAT COLOR OFF.
  WRITE: /21 'TOTAL',
          27(11) l_topqty DECIMALS 2,
          38(11) l_tiqty1 DECIMALS 2,
          49(14) l_tival1 CURRENCY 'IDR',
          63(11) l_tiqty2 DECIMALS 2,
          74(14) l_tival2 CURRENCY 'IDR',
          88(11) l_tiqty3 DECIMALS 2,
          99(14) l_tival3 CURRENCY 'IDR',
         113(11) l_tiqty4 DECIMALS 2,
         124(14) l_tival4 CURRENCY 'IDR',
         138(11) l_toqty1 DECIMALS 2,
         149(14) l_toval1 CURRENCY 'IDR',
         163(11) l_toqty2 DECIMALS 2,
         174(14) l_toval2 CURRENCY 'IDR',
         188(11) l_toqty3 DECIMALS 2,
         199(14) l_toval3 CURRENCY 'IDR',
         213(11) l_toqty4 DECIMALS 2,
         224(14) l_toval4 CURRENCY 'IDR',
         238(11) l_tenqty DECIMALS 2.

*  l_topbal = l_topbal * 100.
*  l_tdbinv = l_tdbinv * 100.
*  l_tcrinv = l_tcrinv * 100.
*  l_tother = l_tother * 100.
*  l_tenbal = l_tenbal * 100.

  FORMAT COLOR COL_NORMAL INTENSIFIED ON.
  WRITE: /15 'OPEN : ', (15) l_topbal CURRENCY 'IDR',
          65 'IN   : ', (15) l_tdbinv CURRENCY 'IDR',
         115 'OUT  : ', (15) l_tcrinv CURRENCY 'IDR',
         165 'OTHER: ', (15) l_tother CURRENCY 'IDR',
         227 'END  :', (15) l_tenbal CURRENCY 'IDR'.

  FORMAT COLOR OFF.
  WRITE: /(19) sy-uline,
           AT  21(5)  sy-uline,
           AT  27(10) sy-uline,
           AT  38(24) sy-uline,
           AT  63(24) sy-uline,
           AT  88(24) sy-uline,
           AT 113(24) sy-uline,
           AT 138(24) sy-uline,
           AT 163(24) sy-uline,
           AT 188(24) sy-uline,
           AT 213(24) sy-uline,
           AT 238(10) sy-uline.

ENDFORM.                    "print_total

************************************************************************
* Form Print Grand Total
************************************************************************
FORM print_grand_total.
********* Checking no transaksi tidak dicetak *******
**** By Sukardi *****
**** Req By MKO  (10-03-2005) ******
  IF l_gival1 = 0 AND
     l_gival2 = 0 AND
     l_gival3 = 0 AND
     l_gival4 = 0 AND
     l_goval1 = 0 AND
     l_goval2 = 0 AND
     l_goval3 = 0 AND
     l_goval4 = 0.
    EXIT.
  ENDIF.

**** End Check ******

*  l_gival1 = l_gival1 * 100.
*  l_gival2 = l_gival2 * 100.
*  l_gival3 = l_gival3 * 100.
*  l_gival4 = l_gival4 * 100.
*  l_goval1 = l_goval1 * 100.
*  l_goval2 = l_goval2 * 100.
*  l_goval3 = l_goval3 * 100.
*  l_goval4 = l_goval4 * 100.


  WRITE: /20 'GTOTAL',
          49(14) l_gival1 CURRENCY 'IDR',
          74(14) l_gival2 CURRENCY 'IDR',
          99(14) l_gival3 CURRENCY 'IDR',
         124(14) l_gival4 CURRENCY 'IDR',
         149(14) l_goval1 CURRENCY 'IDR',
         174(14) l_goval2 CURRENCY 'IDR',
         199(14) l_goval3 CURRENCY 'IDR',
         224(14) l_goval4 CURRENCY 'IDR'.

*  l_gopbal = l_gopbal * 100.
*  l_gdbinv = l_gdbinv * 100.
*  l_gcrinv = l_gcrinv * 100.
*  l_gother = l_gother * 100.
*  l_genbal = l_genbal * 100.

  FORMAT COLOR COL_NORMAL INTENSIFIED ON.
  WRITE: /15 'OPEN : ', (15) l_gopbal CURRENCY 'IDR',
          65 'IN   : ', (15) l_gdbinv CURRENCY 'IDR',
         115 'OUT  : ', (15) l_gcrinv CURRENCY 'IDR',
         165 'OTHER: ', (15) l_gother CURRENCY 'IDR',
         227 'END  :', (15) l_genbal CURRENCY 'IDR'.

ENDFORM.                    "print_grand_total

************************************************************************
* Form Print Header
************************************************************************
FORM print_header.

  WRITE: /     'INVENTORY MOVEMENT REPORT',
           214 'FORM: RIM0200001',
           234 'PAGE:', (4) sy-pagno,
         /     'PERIODE: ', s_perd-low, '-', s_perd-high,
           214 'DATE:', sy-datum,
           234 'TIME:', sy-uzeit.

  SKIP 2.

  WRITE: /(19) sy-uline,
           AT  21(5)  sy-uline,
           AT  27(10) sy-uline,
           AT  38(24) sy-uline,
           AT  63(24) sy-uline,
           AT  88(24) sy-uline,
           AT 113(24) sy-uline,
           AT 138(24) sy-uline,
           AT 163(24) sy-uline,
           AT 188(24) sy-uline,
           AT 213(24) sy-uline,
           AT 238(10) sy-uline.

  WRITE: /   'Material No',
          20 'Material Description',
          61 'Material Grp',
         /88 'IN                    ',
         116 '                     |',
         188 'OUT                   '.

  WRITE: /38(24) sy-uline,
      AT  63(24) sy-uline,
      AT  88(24) sy-uline,
      AT 113(24) sy-uline,
      AT 138(24) sy-uline,
      AT 163(24) sy-uline,
      AT 188(24) sy-uline,
      AT 213(24) sy-uline.

  WRITE: /   'PLANT',
          38 'GR PURCHASING',
          63 'ALLOCATION',
          88 'SALES RETURN',
         113 'OTHER',
         138 'ALLOCATION',
         163 'SALES',
         188 'RETURN TO PRINC',
         213 'OTHERS'.

  WRITE:AT  /38(24) sy-uline,
      AT  63(24) sy-uline,
      AT  88(24) sy-uline,
      AT 113(24) sy-uline,
      AT 138(24) sy-uline,
      AT 163(24) sy-uline,
      AT 188(24) sy-uline,
      AT 213(24) sy-uline.

  WRITE:  /21 'S.LOC',
          27 'OPEN STOCK',
          38 '       QTY    VALUE(HJP)',
          63 '       QTY    VALUE(MAP)',
          88 '       QTY    VALUE(MAP)',
         113 '       QTY    VALUE(MAP)',
         138 '       QTY    VALUE(MAP)',
         163 '       QTY    VALUE(MAP)',
         188 '       QTY    VALUE(HJP)',
         213 '       QTY    VALUE(MAP)',
         238 'END  STOCK'.

  WRITE: (19) sy-uline,
      AT  21(5)  sy-uline,
      AT  27(10) sy-uline,
      AT  38(24) sy-uline,
      AT  63(24) sy-uline,
      AT  88(24) sy-uline,
      AT 113(24) sy-uline,
      AT 138(24) sy-uline,
      AT 163(24) sy-uline,
      AT 188(24) sy-uline,
      AT 213(24) sy-uline,
      AT 238(10) sy-uline.

ENDFORM.                    " CETAK_HEADER


************************************************************************
* Form Print Footer
************************************************************************
FORM print_footer.

  l_nxpag = sy-pagno + 1.
  WRITE: /214 'CONTINUE TO PAGE :', l_nxpag.

ENDFORM.                    "print_footer

************************************************************************
* Form Clear Variables for Details
************************************************************************
FORM clear_var_details.

  CLEAR: l_labst, l_umlme, l_insme, l_speme, l_crstk, l_torec, l_toiss.
  CLEAR: l_opqty, l_iqty1, l_ival1, l_iqty2, l_ival2,
         l_iqty3, l_ival3, l_iqty4, l_ival4, l_oqty1, l_oval1,
         l_oqty2, l_oval2, l_oqty3, l_oval3, l_oqty4, l_oval4,
         l_enqty.

ENDFORM.                    "clear_var_details


*-------------------- Initialisation ---------------------------------*
INITIALIZATION.
  r_lgort-sign   = 'I'.
  r_lgort-option = 'EQ'.
  r_lgort-low    = '1000'.
  APPEND r_lgort. CLEAR r_lgort.

  r_lgort-sign   = 'I'.
  r_lgort-option = 'EQ'.
  r_lgort-low    = '10D0'.
  APPEND r_lgort. CLEAR r_lgort.

  r_lgort-sign   = 'I'.
  r_lgort-option = 'EQ'.
  r_lgort-low    = 'INTRS'.
  APPEND r_lgort. CLEAR r_lgort.

  r_lgort-sign   = 'I'.
  r_lgort-option = 'EQ'.
  r_lgort-low    = 'PRINC'.
  APPEND r_lgort. CLEAR r_lgort.
*&---------------------------------------------------------------------*
*&      Form  set_data_ranges
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_data_ranges.

  SELECT DISTINCT * INTO CORRESPONDING FIELDS OF TABLE itab_bwart
  FROM zmgrpbwart
  WHERE lgort IN r_lgort
    ORDER BY PRIMARY KEY.


  LOOP AT itab_bwart.
    IF ( itab_bwart-lgort = '1000' OR
         itab_bwart-lgort = '10U0' OR
         itab_bwart-lgort = 'CV+RS' ).
      IF itab_bwart-grp   = '01'.
        r_bwart1a1-sign   = 'I'.
        r_bwart1a1-option = 'EQ'.
        r_bwart1a1-low    = itab_bwart-bwart.
        APPEND r_bwart1a1. CLEAR r_bwart1a1.
      ELSEIF itab_bwart-grp = '02'.
        r_bwart1a2-sign   = 'I'.
        r_bwart1a2-option = 'EQ'.
        r_bwart1a2-low    = itab_bwart-bwart.
        APPEND r_bwart1a2. CLEAR r_bwart1a2.
      ELSEIF itab_bwart-grp = '03'.
        r_bwart1a3-sign   = 'I'.
        r_bwart1a3-option = 'EQ'.
        r_bwart1a3-low    = itab_bwart-bwart.
        APPEND r_bwart1a3. CLEAR r_bwart1a3.
      ELSEIF itab_bwart-grp = '04'.
        r_bwart1a4-sign   = 'I'.
        r_bwart1a4-option = 'EQ'.
        r_bwart1a4-low    = itab_bwart-bwart.
        APPEND r_bwart1a4. CLEAR r_bwart1a4.
      ELSEIF itab_bwart-grp = '05'.
        r_bwart1a5-sign   = 'I'.
        r_bwart1a5-option = 'EQ'.
        r_bwart1a5-low    = itab_bwart-bwart.
        APPEND r_bwart1a5. CLEAR r_bwart1a5.
      ELSEIF itab_bwart-grp = '06'.
        r_bwart1a6-sign   = 'I'.
        r_bwart1a6-option = 'EQ'.
        r_bwart1a6-low    = itab_bwart-bwart.
        APPEND r_bwart1a6. CLEAR r_bwart1a6.
      ELSEIF itab_bwart-grp = '07'.
        r_bwart1a7-sign   = 'I'.
        r_bwart1a7-option = 'EQ'.
        r_bwart1a7-low    = itab_bwart-bwart.
        APPEND r_bwart1a7. CLEAR r_bwart1a7.
      ELSEIF itab_bwart-grp = '08'.
        r_bwart1a8-sign   = 'I'.
        r_bwart1a8-option = 'EQ'.
        r_bwart1a8-low    = itab_bwart-bwart.
        APPEND r_bwart1a8. CLEAR r_bwart1a8.
      ENDIF.

    ELSEIF itab_bwart-lgort = '10D0'.
      IF itab_bwart-grp   = '01'.
        r_bwart1c1-sign   = 'I'.
        r_bwart1c1-option = 'EQ'.
        r_bwart1c1-low    = itab_bwart-bwart.
        APPEND r_bwart1c1. CLEAR r_bwart1c1.
      ELSEIF itab_bwart-grp = '02'.
        r_bwart1c2-sign   = 'I'.
        r_bwart1c2-option = 'EQ'.
        r_bwart1c2-low    = itab_bwart-bwart.
        APPEND r_bwart1c2. CLEAR r_bwart1c2.
      ELSEIF itab_bwart-grp = '03'.
        r_bwart1c3-sign   = 'I'.
        r_bwart1c3-option = 'EQ'.
        r_bwart1c3-low    = itab_bwart-bwart.
        APPEND r_bwart1c3. CLEAR r_bwart1c3.
      ELSEIF itab_bwart-grp = '04'.
        r_bwart1c4-sign   = 'I'.
        r_bwart1c4-option = 'EQ'.
        r_bwart1c4-low    = itab_bwart-bwart.
        APPEND r_bwart1c4. CLEAR r_bwart1c4.
      ELSEIF itab_bwart-grp = '05'.
        r_bwart1c5-sign   = 'I'.
        r_bwart1c5-option = 'EQ'.
        r_bwart1c5-low    = itab_bwart-bwart.
        APPEND r_bwart1c5. CLEAR r_bwart1c5.
      ELSEIF itab_bwart-grp = '06'.
        r_bwart1c6-sign   = 'I'.
        r_bwart1c6-option = 'EQ'.
        r_bwart1c6-low    = itab_bwart-bwart.
        APPEND r_bwart1c6. CLEAR r_bwart1c6.
      ELSEIF itab_bwart-grp = '07'.
        r_bwart1c7-sign   = 'I'.
        r_bwart1c7-option = 'EQ'.
        r_bwart1c7-low    = itab_bwart-bwart.
        APPEND r_bwart1c7. CLEAR r_bwart1c7.
      ELSEIF itab_bwart-grp = '08'.
        r_bwart1c8-sign   = 'I'.
        r_bwart1c8-option = 'EQ'.
        r_bwart1c8-low    = itab_bwart-bwart.
        APPEND r_bwart1c8. CLEAR r_bwart1c8.
      ENDIF.

    ELSEIF itab_bwart-lgort = 'INTRS'.
      IF itab_bwart-grp   = '01'.
        r_bwart1d1-sign   = 'I'.
        r_bwart1d1-option = 'EQ'.
        r_bwart1d1-low    = itab_bwart-bwart.
        APPEND r_bwart1d1. CLEAR r_bwart1d1.
      ELSEIF itab_bwart-grp = '21'.
        r_bwart1d21-sign   = 'I'.
        r_bwart1d21-option = 'EQ'.
        r_bwart1d21-low    = itab_bwart-bwart.
        APPEND r_bwart1d21. CLEAR r_bwart1d21.
      ELSEIF itab_bwart-grp = '22'.
        r_bwart1d22-sign   = 'I'.
        r_bwart1d22-option = 'EQ'.
        r_bwart1d22-low    = itab_bwart-bwart.
        APPEND r_bwart1d22. CLEAR r_bwart1d22.
      ELSEIF itab_bwart-grp = '23'.
        r_bwart1d23-sign   = 'I'.
        r_bwart1d23-option = 'EQ'.
        r_bwart1d23-low    = itab_bwart-bwart.
        APPEND r_bwart1d23. CLEAR r_bwart1d23.
      ELSEIF itab_bwart-grp = '24'.
        r_bwart1d24-sign   = 'I'.
        r_bwart1d24-option = 'EQ'.
        r_bwart1d24-low    = itab_bwart-bwart.
        APPEND r_bwart1d24. CLEAR r_bwart1d24.

      ELSEIF itab_bwart-grp = '03'.
        r_bwart1d3-sign   = 'I'.
        r_bwart1d3-option = 'EQ'.
        r_bwart1d3-low    = itab_bwart-bwart.
        APPEND r_bwart1d3. CLEAR r_bwart1d3.
      ELSEIF itab_bwart-grp = '04'.
        r_bwart1d4-sign   = 'I'.
        r_bwart1d4-option = 'EQ'.
        r_bwart1d4-low    = itab_bwart-bwart.
        APPEND r_bwart1d4. CLEAR r_bwart1d4.
      ELSEIF itab_bwart-grp = '05'.
        r_bwart1d5-sign   = 'I'.
        r_bwart1d5-option = 'EQ'.
        r_bwart1d5-low    = itab_bwart-bwart.
        APPEND r_bwart1d5. CLEAR r_bwart1d5.
      ELSEIF itab_bwart-grp = '06'.
        r_bwart1d6-sign   = 'I'.
        r_bwart1d6-option = 'EQ'.
        r_bwart1d6-low    = itab_bwart-bwart.
        APPEND r_bwart1d6. CLEAR r_bwart1d6.
      ELSEIF itab_bwart-grp = '71'.
        r_bwart1d71-sign   = 'I'.
        r_bwart1d71-option = 'EQ'.
        r_bwart1d71-low    = itab_bwart-bwart.
        APPEND r_bwart1d71. CLEAR r_bwart1d71.
      ELSEIF itab_bwart-grp = '72'.
        r_bwart1d72-sign   = 'I'.
        r_bwart1d72-option = 'EQ'.
        r_bwart1d72-low    = itab_bwart-bwart.
        APPEND r_bwart1d72. CLEAR r_bwart1d72.
      ELSEIF itab_bwart-grp = '73'.
        r_bwart1d73-sign   = 'I'.
        r_bwart1d73-option = 'EQ'.
        r_bwart1d73-low    = itab_bwart-bwart.
        APPEND r_bwart1d73. CLEAR r_bwart1d73.
      ELSEIF itab_bwart-grp = '74'.
        r_bwart1d74-sign   = 'I'.
        r_bwart1d74-option = 'EQ'.
        r_bwart1d74-low    = itab_bwart-bwart.
        APPEND r_bwart1d74. CLEAR r_bwart1d74.
      ELSEIF itab_bwart-grp = '08'.
        r_bwart1d8-sign   = 'I'.
        r_bwart1d8-option = 'EQ'.
        r_bwart1d8-low    = itab_bwart-bwart.
        APPEND r_bwart1d8. CLEAR r_bwart1d8.
      ENDIF.
    ELSEIF itab_bwart-lgort = 'PRINC'.
      IF itab_bwart-grp   = '01'.
        r_bwart1e1-sign   = 'I'.
        r_bwart1e1-option = 'EQ'.
        r_bwart1e1-low    = itab_bwart-bwart.
        APPEND r_bwart1e1. CLEAR r_bwart1e1.
      ELSEIF itab_bwart-grp = '02'.
        r_bwart1e2-sign   = 'I'.
        r_bwart1e2-option = 'EQ'.
        r_bwart1e2-low    = itab_bwart-bwart.
        APPEND r_bwart1e2. CLEAR r_bwart1e2.
      ELSEIF itab_bwart-grp = '03'.
        r_bwart1e3-sign   = 'I'.
        r_bwart1e3-option = 'EQ'.
        r_bwart1e3-low    = itab_bwart-bwart.
        APPEND r_bwart1e3. CLEAR r_bwart1e3.
      ELSEIF itab_bwart-grp = '41'.
        r_bwart1e41-sign   = 'I'.
        r_bwart1e41-option = 'EQ'.
        r_bwart1e41-low    = itab_bwart-bwart.
        APPEND r_bwart1e41. CLEAR r_bwart1e41.
      ELSEIF itab_bwart-grp = '42'.
        r_bwart1e42-sign   = 'I'.
        r_bwart1e42-option = 'EQ'.
        r_bwart1e42-low    = itab_bwart-bwart.
        APPEND r_bwart1e42. CLEAR r_bwart1e42.

      ELSEIF itab_bwart-grp = '05'.
        r_bwart1e5-sign   = 'I'.
        r_bwart1e5-option = 'EQ'.
        r_bwart1e5-low    = itab_bwart-bwart.
        APPEND r_bwart1e5. CLEAR r_bwart1e5.
      ELSEIF itab_bwart-grp = '06'.
        r_bwart1e6-sign   = 'I'.
        r_bwart1e6-option = 'EQ'.
        r_bwart1e6-low    = itab_bwart-bwart.
        APPEND r_bwart1e6. CLEAR r_bwart1e6.
      ELSEIF itab_bwart-grp = '71'.
        r_bwart1e71-sign   = 'I'.
        r_bwart1e71-option = 'EQ'.
        r_bwart1e71-low    = itab_bwart-bwart.
        APPEND r_bwart1e71. CLEAR r_bwart1e71.
      ELSEIF itab_bwart-grp = '72'.
        r_bwart1e72-sign   = 'I'.
        r_bwart1e72-option = 'EQ'.
        r_bwart1e72-low    = itab_bwart-bwart.
        APPEND r_bwart1e72. CLEAR r_bwart1e72.

      ELSEIF itab_bwart-grp = '08'.
        r_bwart1e8-sign   = 'I'.
        r_bwart1e8-option = 'EQ'.
        r_bwart1e8-low    = itab_bwart-bwart.
        APPEND r_bwart1e8. CLEAR r_bwart1e8.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " get_data_value

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_VALUATION
*&---------------------------------------------------------------------*
FORM f_get_material_valuation  USING    fu_value.
  DATA : lt_mbewh        LIKE mbewh OCCURS 0 WITH HEADER LINE,
         lt_s039         LIKE mbewh OCCURS 0 WITH HEADER LINE,
         lt_mbewh_temp   LIKE mbewh OCCURS 0 WITH HEADER LINE,
         lv_datum        TYPE sy-datum,
         lt_s039_temp    LIKE gt_s039 OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF lt_t001k OCCURS 0,
           bwkey  TYPE bwkey,
           bukrs  TYPE bukrs,
         END OF lt_t001k.

  CONCATENATE s_perd-low '01' INTO lv_datum.
  lv_datum  = lv_datum - 1.

  CASE fu_value.
    WHEN 'NON'.
      LOOP AT i_itab1 INTO wa_itab1.
        lt_mbewh-matnr  = wa_itab1-matnr.
        lt_mbewh-bwkey  = wa_itab1-werks.
        APPEND lt_mbewh.
      ENDLOOP.
    WHEN OTHERS.
      SELECT bwkey bukrs
        FROM t001k
        INTO TABLE lt_t001k
        WHERE bukrs EQ p_bukrs
          AND bwkey IN s_werks.

      LOOP AT i_itab2 INTO wa_itab2.
        lt_mbewh-matnr  = wa_itab2-matnr.
        LOOP AT lt_t001k.
          lt_mbewh-bwkey  = lt_t001k-bwkey.
          COLLECT lt_mbewh.
        ENDLOOP.
        CLEAR lt_mbewh.
      ENDLOOP.
  ENDCASE.

  SORT lt_mbewh BY matnr bwkey.
  DELETE ADJACENT DUPLICATES FROM lt_mbewh COMPARING matnr bwkey.
  lt_s039[] = lt_mbewh[].
  LOOP AT lt_mbewh.
    lt_mbewh-lfgja = lv_datum(4).
    lt_mbewh-lfmon = lv_datum+4(2).
    MODIFY lt_mbewh TRANSPORTING lfgja lfmon.
  ENDLOOP.

  CHECK lt_mbewh[] IS NOT INITIAL.

  SELECT ssour vrsio spmon sptag spwoc spbup werks matnr
    lgort dispo dismm mtart matkl gsber spart wbwbest
    FROM s039
    INTO TABLE lt_s039_temp
    FOR ALL ENTRIES IN lt_s039
    WHERE ssour EQ space
      AND vrsio EQ '000'
      AND spmon EQ lv_datum(6)
      AND sptag EQ '00000000'
      AND spwoc EQ '000000'
      AND spbup EQ '000000'
      AND werks EQ lt_s039-bwkey
      AND matnr EQ lt_s039-matnr.

  CASE fu_value.
    WHEN 'NON'.
*      SELECT matnr bwkey bwtar lfgja lfmon salk3
*        FROM mbewh
*        INTO CORRESPONDING FIELDS OF TABLE gt_mbewh
*        FOR ALL ENTRIES IN lt_mbewh
*        WHERE matnr EQ lt_mbewh-matnr
*          AND bwkey EQ lt_mbewh-bwkey
*          AND lfgja EQ lt_mbewh-lfgja
*          AND lfmon EQ lt_mbewh-lfmon.

      LOOP AT lt_s039_temp.
        gt_s039-werks   = lt_s039_temp-werks.
        gt_s039-matnr   = lt_s039_temp-matnr.
        gt_s039-wbwbest = lt_s039_temp-wbwbest.
        COLLECT gt_s039.
        CLEAR gt_s039.
      ENDLOOP.

    WHEN OTHERS.
*      SELECT matnr bwkey bwtar lfgja lfmon salk3
*        FROM mbewh
*        INTO CORRESPONDING FIELDS OF TABLE lt_mbewh_temp
*        FOR ALL ENTRIES IN lt_mbewh
*        WHERE matnr EQ lt_mbewh-matnr
*          AND bwkey EQ lt_mbewh-bwkey
*          AND lfgja EQ lt_mbewh-lfgja
*          AND lfmon EQ lt_mbewh-lfmon.
*
*      LOOP AT lt_mbewh_temp.
*        gt_mbewh  = lt_mbewh_temp.
*        CLEAR gt_mbewh-bwkey.
*        COLLECT gt_mbewh.
*        CLEAR gt_mbewh.
*      ENDLOOP.

      LOOP AT lt_s039_temp.
        gt_s039-matnr   = lt_s039_temp-matnr.
        gt_s039-wbwbest = lt_s039_temp-wbwbest.
        COLLECT gt_s039.
        CLEAR gt_s039.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_GET_MATERIAL_VALUATION

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_NON_NATIONAL_V1
*&---------------------------------------------------------------------*
FORM get_data_non_national_v1 .
  DATA : lt_itab1     TYPE STANDARD TABLE OF ta_itab1.

  IF s_werks-low = space AND s_werks-high = space.
    CONCATENATE p_bukrs+1(2) '00' INTO s_werks-low.
    CONCATENATE p_bukrs+1(2) '99' INTO s_werks-high.
  ENDIF.

  SELECT c~werks c~matnr a~matkl a~meins
    INTO CORRESPONDING FIELDS OF TABLE i_itab1
    FROM marc AS c JOIN mara AS a
      ON a~matnr = c~matnr
   WHERE c~werks IN s_werks AND
*         c~lvorm = '' and
         c~matnr IN s_matnr AND
         a~matkl IN s_matkl "and
*         c~lvorm = space
   ORDER BY c~werks c~matnr.

  lt_itab1[] = i_itab1[].
  SORT lt_itab1 BY werks matnr.
  DELETE ADJACENT DUPLICATES FROM lt_itab1 COMPARING werks matnr.

  IF lt_itab1[] IS NOT INITIAL.
    SELECT matnr werks lgort
      INTO CORRESPONDING FIELDS OF TABLE itab_lgort
      FROM mard
      FOR ALL ENTRIES IN lt_itab1
      WHERE werks = lt_itab1-werks
        AND matnr = lt_itab1-matnr.
    SORT itab_lgort BY werks matnr lgort.

    SELECT matnr werks lgort labst umlme insme speme
      INTO CORRESPONDING FIELDS OF TABLE itab_mard
      FROM mard
      FOR ALL ENTRIES IN lt_itab1
      WHERE werks = lt_itab1-werks
        AND matnr = lt_itab1-matnr.
    SORT itab_mard BY werks matnr lgort.
  ENDIF.

  DATA: ld_crprd  LIKE s031-spmon.
  ld_crprd = s_perd-low.
  REFRESH itab_s031.
  WHILE ld_crprd <= l_crprd.
    "Do not use for all entries for huge record in itab (>100000 record)
    IF lt_itab1[] IS NOT INITIAL.
      SELECT matnr werks lgort spmon mzubb magbb
         APPENDING CORRESPONDING FIELDS OF TABLE itab_s031
         FROM s031
         FOR ALL ENTRIES IN lt_itab1
         WHERE ssour = ''
           AND vrsio = '000'
           AND spmon = ld_crprd
           AND sptag = '00000000'
           AND spwoc = '000000'
           AND spbup = '000000'
           AND werks = lt_itab1-werks
           AND matnr = lt_itab1-matnr.
    ENDIF.

    ld_crprd = ld_crprd + 1.
    IF ld_crprd+4(2) = '13'.
      ld_crprd(4)   = ld_crprd(4) + 1.
      ld_crprd+4(2) = '01'.
    ENDIF.
  ENDWHILE.
  SORT itab_s031 BY matnr werks lgort.

*  SELECT matnr werks lgort spmon mzubb magbb
*     INTO CORRESPONDING FIELDS OF TABLE itab_s031
*     FROM s031
*     WHERE werks IN s_werks AND
*           matnr IN r_matnr
*           AND spmon BETWEEN s_perd-low AND l_crprd
*  ORDER BY werks matnr lgort spmon.

  IF lt_itab1[] IS NOT INITIAL.
    SELECT  matnr werks lgort bwart shkzg
            budat lifnr menge dmbtr sobkz
      INTO CORRESPONDING FIELDS OF TABLE itab_mseg
      FROM mseg INNER JOIN mkpf ON mseg~mblnr EQ mkpf~mblnr
                               AND mseg~mjahr EQ mkpf~mjahr
      FOR ALL entries IN lt_itab1
      WHERE werks = lt_itab1-werks
        AND matnr = lt_itab1-matnr
        AND budat BETWEEN l_lprd AND sy-datum.
    SORT itab_mseg BY werks matnr lgort.

    SELECT matnr bwkey salk3
      INTO CORRESPONDING FIELDS OF TABLE itab_mbew
      FROM mbew
      FOR ALL ENTRIES IN lt_itab1
      WHERE bwkey = lt_itab1-werks
        AND matnr = lt_itab1-matnr.
    SORT itab_mbew BY bwkey matnr.

    SELECT matnr werks umlmc trame
      INTO CORRESPONDING FIELDS OF TABLE itab_marc
      FROM marc
      FOR ALL ENTRIES IN lt_itab1
      WHERE werks = lt_itab1-werks
        AND matnr = lt_itab1-matnr.
    SORT itab_marc BY werks matnr.

    SELECT matnr werks sobkz lblab
    INTO CORRESPONDING FIELDS OF TABLE itab_mslb
    FROM mslb
    FOR ALL ENTRIES IN lt_itab1
    WHERE werks = lt_itab1-werks
      AND matnr = lt_itab1-matnr
      AND sobkz = 'O'.
    SORT itab_mslb BY werks matnr.

    SELECT matnr bwkey budat gjahr belnr buzei shkzg dmbtr
    INTO CORRESPONDING FIELDS OF TABLE itab_bsim
    FROM bsim
    FOR ALL ENTRIES IN lt_itab1
    WHERE bwkey = lt_itab1-werks
      AND matnr = lt_itab1-matnr
      AND budat BETWEEN l_lprd AND sy-datum.
    SORT itab_bsim BY bwkey matnr.
  ENDIF.
ENDFORM.                    " GET_DATA_NON_NATIONAL_V1
