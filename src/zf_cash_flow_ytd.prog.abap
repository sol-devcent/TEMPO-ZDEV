REPORT zf_cash_flow NO STANDARD PAGE HEADING LINE-SIZE 255.
TABLES : fmfpo,fmep,fmsu,zficf,zficft.

DATA : BEGIN OF i_fmsu OCCURS 0,
       fipos LIKE fmfpo-fipos.
        INCLUDE STRUCTURE fmsu.
DATA : END OF i_fmsu.

DATA : BEGIN OF i_fmfpo OCCURS 0,
       posit LIKE fmfpo-posit,
       END OF i_fmfpo.
DATA : total1 LIKE fmsu-btr001.

DATA : BEGIN OF itab OCCURS 0,
       posit LIKE fmep-posit,
       zapos LIKE fmep-zapos,
       ldbtro LIKE fmep-ldbtro,
       bukrs LIKE fmep-bukrs,
       gsber LIKE fmep-gsber,
       fipos LIKE fmfpo-fipos,
       flag(1),
       END OF itab.
DATA : BEGIN OF itab2 OCCURS 0,
       fipos LIKE fmfpo-fipos,
       posit LIKE fmep-posit,
       bukrs LIKE fmsu-bukrs,
       gsber LIKE fmsu-gsber,
       jan   LIKE fmsu-btr002,
       feb   LIKE fmsu-btr002,
       mar   LIKE fmsu-btr002,
       apr   LIKE fmsu-btr002,
       mei   LIKE fmsu-btr002,
       jun   LIKE fmsu-btr002,
       jul   LIKE fmsu-btr002,
       agt   LIKE fmsu-btr002,
       sep   LIKE fmsu-btr002,
       okt   LIKE fmsu-btr002,
       nov   LIKE fmsu-btr002,
       des   LIKE fmsu-btr002,
       tot   LIKE fmsu-btr002,
       beg_td LIKE fmsu-btr002,
       beg_cm LIKE fmsu-btr002,
       ending LIKE fmsu-btr002,
       END OF itab2.

DATA : BEGIN OF itab6 OCCURS 0,
       fipos LIKE fmfpo-fipos,
       bukrs LIKE fmsu-bukrs,
       gsber LIKE fmsu-gsber,
       END OF itab6.

DATA : txt LIKE fmfpot-bezeich,total LIKE fmsu-btr002,
       s_perio(2),fipos LIKE fmfpo-fipos,
       v_posit LIKE fmep-posit,
       v_fipos(1),
       sub1a LIKE fmsu-btr002,
       sub2a LIKE fmsu-btr002,
       sub3a LIKE fmsu-btr002,
       sub4a LIKE fmsu-btr002,
       sub5a LIKE fmsu-btr002,
       sub6a LIKE fmsu-btr002,
       sub7a LIKE fmsu-btr002,
       tot1a LIKE fmsu-btr002 ,
       count TYPE i,sw TYPE i,
       tot2 LIKE fmsu-btr002,
       tot3 LIKE fmsu-btr002,
       sub01 LIKE fmsu-btr002,
       sub02 LIKE fmsu-btr002,
       sub03 LIKE fmsu-btr002,
       sub04 LIKE fmsu-btr002,
       sub05 LIKE fmsu-btr002,
       sub06 LIKE fmsu-btr002,
       sub07 LIKE fmsu-btr002,
       tot01 LIKE fmsu-btr002 ,
       tot02 LIKE fmsu-btr002,
       v_butxt LIKE t001-butxt,
       v_gtext LIKE tgsbt-gtext,
       v_company LIKE fmsu-bukrs,
       tot03 LIKE fmsu-btr002,
       zitem LIKE zficf-item,
       tot LIKE fmsu-btr002,
       beg_jan   LIKE fmsu-btr002,
       beg_feb   LIKE fmsu-btr002,
       beg_mar   LIKE fmsu-btr002,
       beg_apr   LIKE fmsu-btr002,
       beg_mei   LIKE fmsu-btr002,
       beg_jun   LIKE fmsu-btr002,
       beg_jul   LIKE fmsu-btr002,
       beg_agt   LIKE fmsu-btr002,
       beg_sep   LIKE fmsu-btr002,
       beg_okt   LIKE fmsu-btr002,
       beg_nov   LIKE fmsu-btr002,
       beg_des   LIKE fmsu-btr002,
       beg_tot   LIKE fmsu-btr002,
       end_jan   LIKE fmsu-btr002,
       end_feb   LIKE fmsu-btr002,
       end_mar   LIKE fmsu-btr002,
       end_apr   LIKE fmsu-btr002,
       end_mei   LIKE fmsu-btr002,
       end_jun   LIKE fmsu-btr002,
       end_jul   LIKE fmsu-btr002,
       end_agt   LIKE fmsu-btr002,
       end_sep   LIKE fmsu-btr002,
       end_okt   LIKE fmsu-btr002,
       end_nov   LIKE fmsu-btr002,
       end_des   LIKE fmsu-btr002,
       jan   LIKE fmsu-btr002,
       feb   LIKE fmsu-btr002,
       mar   LIKE fmsu-btr002,
       apr   LIKE fmsu-btr002,
       mei   LIKE fmsu-btr002,
       jun   LIKE fmsu-btr002,
       jul   LIKE fmsu-btr002,
       agt   LIKE fmsu-btr002,
       sep   LIKE fmsu-btr002,
       okt   LIKE fmsu-btr002,
       nov   LIKE fmsu-btr002,
       des   LIKE fmsu-btr002,
       beg_jan1   LIKE fmsu-btr002,
       beg_feb1   LIKE fmsu-btr002,
       beg_mar1   LIKE fmsu-btr002,
       beg_apr1   LIKE fmsu-btr002,
       beg_mei1   LIKE fmsu-btr002,
       beg_jun1   LIKE fmsu-btr002,
       beg_jul1   LIKE fmsu-btr002,
       beg_agt1   LIKE fmsu-btr002,
       beg_sep1   LIKE fmsu-btr002,
       beg_okt1   LIKE fmsu-btr002,
       beg_nov1   LIKE fmsu-btr002,
       beg_des1   LIKE fmsu-btr002.
RANGES : zitem1 FOR zficf-item,
         zfikrs FOR t001-fikrs,
         zbukrs FOR fmmp-bukrs,
         zapos FOR fmep-zapos,
         v_perio FOR fmep-perio,
         v_gjahr FOR fmep-gjahr,
         v_gsber FOR fmmp-gsber,
         zfipos1 FOR zficf-zfipos1.
DATA : test TYPE TABLE OF rsparams,
       wa_test LIKE LINE OF test.


DATA : itab1 LIKE itab OCCURS 0 WITH HEADER LINE,
       itab8  LIKE itab OCCURS 0 WITH HEADER LINE,
       itab3 LIKE itab2 OCCURS 0 WITH HEADER LINE,
       itab5 LIKE itab OCCURS 0 WITH HEADER LINE,
       i_fmsu1 LIKE i_fmsu OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF itab_fl OCCURS 0,
       item LIKE zficf-item,
       zfipos1 LIKE zficf-zfipos1,
       zgroup LIKE zficf-zgroup,
       in_out LIKE zficf-in_out,
       text LIKE zficft-text,
       value LIKE fmsu-btr002,
       value1 LIKE fmsu-btr002,
       value2 LIKE fmsu-btr002,
       value3 LIKE fmsu-btr002,
       value4 LIKE fmsu-btr002,
       value5 LIKE fmsu-btr002,
       value6 LIKE fmsu-btr002,
       value7 LIKE fmsu-btr002,
       value8 LIKE fmsu-btr002,
       value9 LIKE fmsu-btr002,
       value10 LIKE fmsu-btr002,
       value11 LIKE fmsu-btr002,
       value12 LIKE fmsu-btr002,

       END OF itab_fl.

DATA itab4 LIKE itab_fl OCCURS 0 WITH HEADER LINE.

DATA : w1    TYPE i,  w2    TYPE i,  w3    TYPE i,  w4    TYPE i,
       w5    TYPE i,  w6    TYPE i,  w7    TYPE i,  w8    TYPE i,
       w9    TYPE i,  w10   TYPE i,  w11   TYPE i,  w12   TYPE i,
       w13   TYPE i,  w14   TYPE i,  w15   TYPE i,  w16   TYPE i,
       w17   TYPE i,  w18   TYPE i,  w19   TYPE i,  w1a  TYPE i,
       w20   TYPE i,  w17a  TYPE i,  c1    TYPE i,  c2   TYPE i,
       w21   TYPE i,  w22   TYPE i,  w23   TYPE i,  w24   TYPE i,
       w25   TYPE i,  w26   TYPE i,  w27   TYPE i,  w28   TYPE i,
       w29   TYPE i,  w30   TYPE i,  w31   TYPE i,  w32   TYPE i,
       w33   TYPE i,  w34   TYPE i,  w35   TYPE i,text(32),
       l_perio LIKE fmep-perio,l_perio1 LIKE fmep-perio.


SELECTION-SCREEN BEGIN OF BLOCK 1 WITH FRAME TITLE text-401.
PARAMETERS:
           p_fikrs LIKE t001-fikrs MATCHCODE OBJECT fikr
                                   MEMORY ID fik
                                   OBLIGATORY.
SELECTION-SCREEN END OF BLOCK 1.
SELECTION-SCREEN SKIP.

* block 2
*selection-screen begin of block 20 with frame title text-402.
SELECTION-SCREEN BEGIN OF BLOCK 21 WITH FRAME TITLE text-402.
PARAMETERS:
           p_perio  LIKE fmep-perio OBLIGATORY,
           p_gjahr  LIKE fmep-gjahr MEMORY ID gjr OBLIGATORY.
SELECTION-SCREEN END OF BLOCK 21.
SELECTION-SCREEN SKIP.

* block 4
*SELECTION-SCREEN BEGIN OF BLOCK 4 WITH FRAME TITLE TEXT-404.
*SELECT-OPTIONS:
*   S_FIPOS     FOR  FMFPO-FIPOS.
*SELECTION-SCREEN END OF BLOCK 4.
*SELECTION-SCREEN SKIP.

* block 3
SELECTION-SCREEN BEGIN OF BLOCK 3 WITH FRAME TITLE text-403.
PARAMETERS:
           s_bukrs     LIKE  fmep-bukrs OBLIGATORY.
SELECT-OPTIONS:
           s_gsber     FOR  fmep-gsber NO INTERVALS.
SELECTION-SCREEN END OF BLOCK 3.

AT SELECTION-SCREEN ON s_gsber.
  IF s_bukrs EQ '8020'.
    IF  s_gsber NE space AND s_gsber-low+0(2) NE '02'.
      MESSAGE e000(zs) WITH 'Business Area must be entry 02xx'.
    ENDIF.
  ELSEIF s_bukrs EQ '8030'.
    IF s_gsber NE space AND s_gsber-low+0(2) NE '03'.
      MESSAGE e000(zs) WITH 'Business Area must be entry 03xx'.
    ENDIF.
  ELSEIF s_bukrs EQ '8010'.
    IF s_gsber NE space AND s_gsber-low+0(2) NE '01'.
      MESSAGE e000(zs) WITH 'Business Area must be entry 01xx'.
    ENDIF.
  ELSEIF s_bukrs EQ '8070'.
    IF s_gsber NE space AND s_gsber-low+0(2) NE '07'.
      MESSAGE e000(zs) WITH 'Business Area must be entry 07xx'.
    ENDIF.
  ENDIF.

INITIALIZATION.
  DATA lv_parva(40).

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'BUK'.

  IF sy-subrc EQ 0.
    s_bukrs  = lv_parva.
  ENDIF.

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'GSB'.

  IF sy-subrc EQ 0.
    s_gsber-low  = lv_parva.
    APPEND s_gsber.
  ENDIF.

START-OF-SELECTION.

  PERFORM get_data.
  PERFORM process_data.

AT LINE-SELECTION.
  READ CURRENT LINE FIELD VALUE: itab2-fipos,itab2-bukrs,itab2-gsber,
                                 itab4-text,itab4-item,txt,v_fipos.

  DATA : ffield(20), fvalue(20),v_twaer LIKE fmep-twaer.
  GET CURSOR FIELD ffield VALUE fvalue.
  CASE ffield.

    WHEN 'ITAB4-VALUE1'.
      l_perio = 1.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      IF zitem NE space.
        PERFORM submit.
      ENDIF.
    WHEN 'ITAB4-VALUE2'.
      l_perio = 2.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      PERFORM submit.

    WHEN 'ITAB4-VALUE3'.
      l_perio = 3.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      IF zitem NE space.
        PERFORM submit.
      ENDIF.

    WHEN 'ITAB4-VALUE4'.
      l_perio = 4.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      IF zitem NE space.
        PERFORM submit.
      ENDIF.

    WHEN 'ITAB4-VALUE5'.
      l_perio = 5.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      IF zitem NE space.
        PERFORM submit.
      ENDIF.

    WHEN 'ITAB4-VALUE6'.
      l_perio = 6.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      IF zitem NE space.
        PERFORM submit.
      ENDIF.

    WHEN 'ITAB4-VALUE7'.
      l_perio = 7.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      IF zitem NE space.
        PERFORM submit.
      ENDIF.

    WHEN 'ITAB4-VALUE8'.
      l_perio = 8.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      IF zitem NE space.
        PERFORM submit.
      ENDIF.

    WHEN 'ITAB4-VALUE9'.
      l_perio = 9.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      IF zitem NE space.
        PERFORM submit.
      ENDIF.

    WHEN 'ITAB4-VALUE10'.
      l_perio = 10.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      PERFORM submit.

    WHEN 'ITAB4-VALUE11'.
      l_perio = 11.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      IF zitem NE space.
        PERFORM submit.
      ENDIF.

    WHEN 'ITAB4-VALUE12'.
      l_perio = 12.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      IF zitem NE space.
        PERFORM submit.
      ENDIF.

    WHEN 'ITAB4-VALUE'.
      l_perio = 1.l_perio1 = p_perio.
      PERFORM detail_item.
      PERFORM gsber.
      IF zitem NE space.
        PERFORM submit.
      ENDIF.

  ENDCASE.
  CLEAR : itab4-text.
*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data.
  DATA : objnr LIKE fmsu-objnr,
         text LIKE fmfpot-bezeich,
         v_bukrs LIKE fmsu-bukrs,
         v_gsber LIKE fmsu-gsber,
         va_perio LIKE p_perio,
         v_tgl(2) TYPE n,
         total LIKE fmsu-btr001.
  CONCATENATE 'FK' p_fikrs INTO objnr.

  SELECT *
  INTO
  CORRESPONDING FIELDS OF TABLE i_fmsu
  FROM fmsu AS a JOIN fmfpo AS b ON a~objnr EQ b~fma_objnr AND
                                    a~posit EQ b~posit
  WHERE a~objnr EQ objnr AND
  a~gjahr EQ p_gjahr  AND a~bukrs EQ s_bukrs AND
  a~gsber IN s_gsber AND wrttp IN ('57','61','64').

  PERFORM f_add_data_fr_fmci USING objnr.

  SELECT fipos btrvt   APPENDING
  CORRESPONDING FIELDS OF TABLE i_fmsu
  FROM fmsu AS a JOIN fmfpo AS b ON a~objnr EQ b~fma_objnr AND
                                    a~posit EQ b~posit
  WHERE a~objnr EQ objnr AND
  a~gjahr EQ p_gjahr  AND a~bukrs EQ s_bukrs AND
  a~gsber IN s_gsber AND wrttp EQ '04'.

ENDFORM.                    " get_data
*&---------------------------------------------------------------------*
*&      Form  process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data.
  DATA : objnr LIKE fmsu-objnr,
         text LIKE fmfpot-bezeich,
         v_bukrs LIKE fmsu-bukrs,
         v_gsber LIKE fmsu-gsber.
*       TOTAL LIKE FMSU-BTR001.
  CONCATENATE 'FK' p_fikrs INTO objnr.

  IF s_perio = '0'.
    s_perio = '01'.
  ENDIF.
  PERFORM get_detail.
  SELECT SINGLE butxt INTO v_butxt FROM t001
      WHERE bukrs EQ s_bukrs.
  SELECT SINGLE gtext INTO v_gtext FROM tgsbt
  WHERE spras EQ 'E' AND gsber EQ s_gsber-low.
  IF sy-subrc NE 0.
    v_gtext = 'COMBINED'.
  ENDIF.
  PERFORM write_detail.
  CLEAR zapos.REFRESH zapos.
ENDFORM.                    " process_data

*&---------------------------------------------------------------------*
*&      Form  HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header.
  DATA : dt1(10),
         dt2(10),
         dt3(50).
*       WRITE P_PERIO-LOW TO DT1 DD/MM/YYYY.
*       WRITE P_PERIO-HIGH TO DT2 DD/MM/YYYY.
*       CONCATENATE DT1 's/d' DT2 INTO DT3 SEPARATED BY SPACE.

  WRITE : / v_butxt.
  WRITE AT 29 v_gtext.

*      'PT. TEMPO                 HEAD OFFICE'.
  WRITE : / 'CASH FLOW'.
  WRITE AT 12 '-'.
  WRITE AT 15 p_gjahr.
*      WRITE : /(C2) DT3 CENTERED.
  WRITE AT /1(c2) sy-uline.
  FORMAT COLOR COL_HEADING.
  c1 = 1.
  WRITE :/(1) sy-vline NO-GAP.c1 = c1 + 1.
  WRITE AT c1(w1) 'DESCRIPTION ' CENTERED NO-GAP.c1 = c1 + w1.
  WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  SET LEFT SCROLL-BOUNDARY.
  IF p_perio GE 1.
    WRITE AT c1(w2) 'JANUARY' CENTERED NO-GAP.c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 2.
    WRITE AT c1(w3) 'FEBRUARY' CENTERED NO-GAP.c1 = c1 + w3.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 3.
    WRITE AT c1(w4) 'MARCH' CENTERED NO-GAP.c1 = c1 + w4.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 4.
    WRITE AT c1(w5) 'APRIL' CENTERED NO-GAP.c1 = c1 + w5.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 5.
    WRITE AT c1(w6) 'MAY' CENTERED NO-GAP.c1 = c1 + w6.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 6.
    WRITE AT c1(w7) 'JUNE' CENTERED NO-GAP.c1 = c1 + w7.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 7.
    WRITE AT c1(w8) 'JULY' CENTERED NO-GAP.c1 = c1 + w8.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 8.
    WRITE AT c1(w9) 'AUGUST' CENTERED NO-GAP.c1 = c1 + w9.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 9.
    WRITE AT c1(w10) 'SEPTEMBER' CENTERED NO-GAP.c1 = c1 + w10.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 10.
    WRITE AT c1(w11) 'OCTOBER' CENTERED NO-GAP.c1 = c1 + w11.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 11.
    WRITE AT c1(w12) 'NOVEMBER' CENTERED NO-GAP.c1 = c1 + w12.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 12.
    WRITE AT c1(w13) 'DECEMBER' CENTERED NO-GAP.c1 = c1 + w13.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  WRITE AT c1(w14) 'YEAR TO DATE' CENTERED NO-GAP.c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.

  WRITE  AT /1(c2) sy-uline.
  FORMAT COLOR COL_TOTAL.
  MOVE 'BEGINNING BALANCE' TO itab4-text.
  itab4-value1 = beg_jan.itab4-value2 = beg_feb.
  itab4-value3 = beg_mar.itab4-value4 = beg_apr.
  itab4-value5 = beg_mei.itab4-value6 = beg_jun.
  itab4-value7 = beg_jul.itab4-value8 = beg_agt.
  itab4-value9 = beg_sep.itab4-value10 = beg_okt.
  itab4-value11 = beg_nov.itab4-value12 = beg_des.
  itab4-value = beg_jan.
  PERFORM write_beg.
  end_des = itab4-value.
  WRITE AT /1(c2) sy-uline.

ENDFORM.                    " HEADER
*&---------------------------------------------------------------------*
*&      Form  ENDAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM endat.
  DATA v_perio(2) TYPE n.
  v_perio = p_perio.
  REFRESH itab.CLEAR itab.REFRESH itab4.CLEAR itab4.
  IF s_bukrs = '8010' OR
     s_bukrs = '8090' OR
     s_bukrs = '8160'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE itab_fl FROM zficf
    WHERE item NOT IN ('1280','1380').
  ELSE.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE itab_fl FROM zficf
    WHERE item NE '1290'.
  ENDIF.
  LOOP AT itab6.
    total = 0.
    IF s_gsber IS INITIAL.
      LOOP AT i_fmsu WHERE bukrs EQ itab6-bukrs AND fipos EQ itab6-fipos.
        PERFORM gsber_initial.
        MOVE '*' TO itab2-gsber.
      ENDLOOP.
    ELSE.
      LOOP AT i_fmsu WHERE bukrs EQ itab6-bukrs AND fipos EQ itab6-fipos
                           AND gsber EQ itab6-gsber.
        PERFORM gsber_initial.
*     MOVE I_FMSU-GSBER TO ITAB2-GSBER.
      ENDLOOP.
    ENDIF.
*        MOVE I_FMSU-FIPOS TO ITAB2-FIPOS.
*        MOVE TOTAL TO ITAB2-BEG_TD.
*        MOVE TOTAL TO ITAB2-BEG_CM.
*        MOVE TOTAL TO ITAB2-ENDING.
*        APPEND ITAB2.clear itab2.
  ENDLOOP.
ENDFORM.                    " ENDAT
*&---------------------------------------------------------------------*
*&      Form  GET_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_detail.
  LOOP AT i_fmsu.
    MOVE i_fmsu-fipos TO itab6-fipos.
    MOVE i_fmsu-bukrs TO itab6-bukrs.
    IF NOT s_gsber IS INITIAL.
      MOVE i_fmsu-gsber TO itab6-gsber.
    ELSE.
      itab6-gsber = space.
    ENDIF.

    APPEND itab6.
  ENDLOOP.
  SORT itab6 BY  bukrs gsber fipos.
  DELETE ADJACENT DUPLICATES FROM itab6.
  PERFORM endat.
ENDFORM.                    " GET_DETAIL
*&---------------------------------------------------------------------*
*&      Form  GSBER_INITIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM gsber_initial.
  DATA v_perio(2) TYPE n.
  LOOP AT itab_fl WHERE zfipos1 EQ i_fmsu-fipos.
    itab_fl-value1 = itab_fl-value1 + i_fmsu-btr001.
    itab_fl-value2 = itab_fl-value2 + i_fmsu-btr002.
    itab_fl-value3 = itab_fl-value3 + i_fmsu-btr003.
    itab_fl-value4 = itab_fl-value4 + i_fmsu-btr004.
    itab_fl-value5 = itab_fl-value5 + i_fmsu-btr005.
    itab_fl-value6 = itab_fl-value6 + i_fmsu-btr006.
    itab_fl-value7 = itab_fl-value7 + i_fmsu-btr007.
    itab_fl-value8 = itab_fl-value8 + i_fmsu-btr008.
    itab_fl-value9 = itab_fl-value9 + i_fmsu-btr009.
    itab_fl-value10 = itab_fl-value10 + i_fmsu-btr010.
    itab_fl-value11 = itab_fl-value11 + i_fmsu-btr011.
    itab_fl-value12 = itab_fl-value12 + i_fmsu-btr012.
    itab_fl-value = itab_fl-value + i_fmsu-btrvt.
    beg_jan = beg_jan + i_fmsu-btrvt.
    beg_feb = beg_feb + i_fmsu-btrvt + i_fmsu-btr001.
    beg_mar = beg_mar + i_fmsu-btrvt + i_fmsu-btr001 + i_fmsu-btr002.
    beg_apr = beg_apr + i_fmsu-btrvt + i_fmsu-btr001 + i_fmsu-btr002 +
              i_fmsu-btr003.
    beg_mei = beg_mei + i_fmsu-btrvt + i_fmsu-btr001 + i_fmsu-btr002 +
              i_fmsu-btr003 + i_fmsu-btr004.
    beg_jun = beg_jun + i_fmsu-btrvt + i_fmsu-btr001 + i_fmsu-btr002 +
              i_fmsu-btr003 + i_fmsu-btr004 + i_fmsu-btr005.
    beg_jul = beg_jul + i_fmsu-btrvt + i_fmsu-btr001 + i_fmsu-btr002 +
              i_fmsu-btr003 + i_fmsu-btr004 + i_fmsu-btr005 +
              i_fmsu-btr006.
    beg_agt = beg_agt + i_fmsu-btrvt + i_fmsu-btr001 + i_fmsu-btr002 +
              i_fmsu-btr003 + i_fmsu-btr004 + i_fmsu-btr005 +
              i_fmsu-btr006 + i_fmsu-btr007.

    beg_sep = beg_sep + i_fmsu-btrvt + i_fmsu-btr001 + i_fmsu-btr002 +
              i_fmsu-btr003 + i_fmsu-btr004 + i_fmsu-btr005 +
              i_fmsu-btr006 + i_fmsu-btr007 + i_fmsu-btr008.

    beg_okt = beg_okt + i_fmsu-btrvt + i_fmsu-btr001 + i_fmsu-btr002 +
              i_fmsu-btr003 + i_fmsu-btr004 + i_fmsu-btr005 +
              i_fmsu-btr006 + i_fmsu-btr007 + i_fmsu-btr008 +
              i_fmsu-btr009.

    beg_nov = beg_nov + i_fmsu-btrvt + i_fmsu-btr001 + i_fmsu-btr002 +
              i_fmsu-btr003 + i_fmsu-btr004 + i_fmsu-btr005 +
              i_fmsu-btr006 + i_fmsu-btr007 + i_fmsu-btr008 +
              i_fmsu-btr009 + i_fmsu-btr010.

    beg_des = beg_des + i_fmsu-btrvt + i_fmsu-btr001 + i_fmsu-btr002 +
              i_fmsu-btr003 + i_fmsu-btr004 + i_fmsu-btr005 +
              i_fmsu-btr006 + i_fmsu-btr007 + i_fmsu-btr008 +
              i_fmsu-btr009 + i_fmsu-btr010 + i_fmsu-btr011.

    beg_tot = beg_tot + i_fmsu-btrvt + i_fmsu-btr001 + i_fmsu-btr002 +
              i_fmsu-btr003 + i_fmsu-btr004 + i_fmsu-btr005 +
              i_fmsu-btr006 + i_fmsu-btr007 + i_fmsu-btr008 +
              i_fmsu-btr009 + i_fmsu-btr010 + i_fmsu-btr011 +
              i_fmsu-btr012.


    MODIFY itab_fl.
  ENDLOOP.


ENDFORM.                    " GSBER_INITIAL
*&---------------------------------------------------------------------*
*&      Form  detail_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM detail_item.
  CLEAR zfipos1.REFRESH zfipos1.CLEAR zitem.
  SELECT SINGLE item INTO zitem FROM zficft
        WHERE text EQ itab4-text.

  IF sy-subrc EQ 0.
    CLEAR zfipos1.REFRESH zfipos1.
    SELECT zfipos1 INTO zfipos1-low FROM zficf
    WHERE item EQ zitem.
      zfipos1-high = zfipos1-low.
      zfipos1-sign = 'I'.
      zfipos1-option = 'EQ'.
      APPEND zfipos1.
    ENDSELECT.
  ENDIF.
  CLEAR zfikrs.REFRESH zfikrs.
  zfikrs-low  = '8899'.
  zfikrs-high = '8899'.
  zfikrs-sign = 'I'.
  zfikrs-option = 'EQ'.
  APPEND zfikrs.
  CLEAR zbukrs.REFRESH zbukrs.
  zbukrs-low  = s_bukrs.
  zbukrs-high = s_bukrs.
  zbukrs-sign = 'I'.
  zbukrs-option = 'EQ'.
  APPEND zbukrs.

  CLEAR zapos.REFRESH zapos.
  zapos-low  = '90000'.
  zapos-high = '90300'.
  zapos-sign = 'I'.
  zapos-option = 'BT'.
  APPEND zapos.

  CLEAR v_perio.REFRESH v_perio.
  v_perio-low  = l_perio.
  v_perio-high = l_perio1.
  v_perio-sign = 'I'.
  v_perio-option = 'EQ'.
  APPEND v_perio.

  CLEAR v_gjahr.REFRESH v_gjahr.
  v_gjahr-low  = p_gjahr.
  v_gjahr-high = p_gjahr.
  v_gjahr-sign = 'I'.
  v_gjahr-option = 'EQ'.
  APPEND v_gjahr.

ENDFORM.                    " detail_item
*&---------------------------------------------------------------------*
*&      Form  subtotal
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM subtotal.
  IF itab4-zgroup EQ '1' AND itab4-in_out EQ '2'.
    IF count = 0. "ON CHANGE OF ITAB4-IN_OUT.
      MOVE 'RECEIPTS' TO text.
      PERFORM write_sub1.
      count = 1.
    ENDIF.
    PERFORM tot_sub1.
  ENDIF.
  IF itab4-zgroup EQ '1' AND itab4-in_out EQ '3'.

    IF count = 1.  "ON CHANGE OF ITAB4-IN_OUT.

      PERFORM write_sub2.

      FORMAT COLOR COL_NORMAL INTENSIFIED ON.
      FORMAT COLOR COL_GROUP.
      text = itab4-text.
      MOVE '     RECEIPT FROM OPERATION' TO itab4-text.
      PERFORM get_value.
      PERFORM tot_sub2.
      PERFORM write_detail1.
      PERFORM back_value.
      itab4-text = text.
      MOVE 'DISBURSEMENTS' TO text.
      PERFORM write_sub1.

      count = 0.
    ENDIF.
    PERFORM tot_sub3.
  ENDIF.

  IF itab4-zgroup EQ '2' AND itab4-in_out EQ '2'.

    IF count = 0. "ON CHANGE OF ITAB4-IN_OUT.
      PERFORM write_sub2.

      FORMAT COLOR COL_NORMAL INTENSIFIED ON.
      FORMAT COLOR COL_GROUP.
      text = itab4-text.
      MOVE '      DISB FROM OPERATION' TO itab4-text.
      PERFORM get_value.
      PERFORM tot_sub4.
      PERFORM write_detail1.
      PERFORM back_value.
      itab4-text = text.
      WRITE AT /1(c2) sy-uline.
      FORMAT COLOR COL_NORMAL INTENSIFIED ON.
      FORMAT COLOR COL_TOTAL.
      text = itab4-text.
      MOVE 'NET CASH FLOW FROM OPERATION' TO itab4-text.
      PERFORM get_value.
      PERFORM tot_sub5.
      PERFORM write_detail1.
      PERFORM back_value.
      itab4-text = text.
      FORMAT COLOR OFF.
      WRITE AT /1(c2) sy-uline.
      count = 1.
      PERFORM clear.
    ENDIF.
    PERFORM tot_sub1.

  ENDIF.

  IF itab4-zgroup EQ '2' AND itab4-in_out EQ '3'.

    IF count = 1. "ON CHANGE OF ITAB4-IN_OUT.
      PERFORM write_sub2.
      FORMAT COLOR COL_NORMAL INTENSIFIED ON.
      FORMAT COLOR COL_GROUP.
      text = itab4-text.
      MOVE '      RECEIPT FROM INVESTMENT' TO itab4-text.
      PERFORM get_value.
      PERFORM tot_sub2.
      PERFORM write_detail1.
      PERFORM back_value.
      itab4-text = text.

      FORMAT COLOR OFF.
      count = 0.
    ENDIF.
    PERFORM tot_sub3.
  ENDIF.

  IF itab4-zgroup EQ '3' AND itab4-in_out EQ '2'.

    IF count = 0. "ON CHANGE OF ITAB4-IN_OUT.
      tot2 = sub3a + sub4a.
      tot02 = sub03 + sub04.
      PERFORM write_sub2.
      FORMAT COLOR COL_NORMAL INTENSIFIED ON.
      FORMAT COLOR COL_GROUP.
      text = itab4-text.

      MOVE '      DISB FROM INVESTMENT' TO itab4-text.
      PERFORM get_value.
      PERFORM tot_sub4.
      PERFORM write_detail1.
      PERFORM back_value.

      WRITE AT /1(c2) sy-uline.
      FORMAT COLOR COL_TOTAL.
*           TEXT = ITAB4-TEXT.

      MOVE 'NET CASH FLOW FROM INVESTMENTS' TO itab4-text.
      PERFORM get_value.
      PERFORM tot_sub5.
      PERFORM write_detail1.
      PERFORM back_value.
      itab4-text = text.
      FORMAT COLOR OFF.
      WRITE AT /1(c2) sy-uline.
      MOVE 'RECEIPTS' TO text.
      PERFORM write_sub1.
      PERFORM clear.
      count = 1.
    ENDIF.
    sub5a = sub5a + itab4-value5.
    sub05 = sub05 + itab4-value.
    PERFORM tot_sub1.
  ENDIF.

  IF itab4-zgroup EQ '3' AND itab4-in_out EQ '3'.

    IF count = 1. "ON CHANGE OF ITAB4-IN_OUT.
      PERFORM write_sub2.

      FORMAT COLOR COL_NORMAL INTENSIFIED ON.
      FORMAT COLOR COL_GROUP.
      text = itab4-text.
      MOVE '     RECEIPT FROM FINANCING' TO itab4-text.
      PERFORM get_value.
      PERFORM tot_sub2.
      PERFORM write_detail1.
      PERFORM back_value.
      itab4-text = text.
      MOVE 'DISBURSEMENTS' TO text.
      PERFORM write_sub1.

      count = 0.
    ENDIF.
    sub6a = sub6a + itab4-value6.
    sub06 = sub06 + itab4-value.
    PERFORM tot_sub3.
  ENDIF.

  IF itab4-zgroup EQ '4' AND itab4-in_out EQ '0'.
    tot3 = sub5a + sub6a.
    tot03 = sub05 + sub06.
    IF count = 0. "ON CHANGE OF ITAB4-IN_OUT.
      PERFORM write_sub2.

      FORMAT COLOR COL_NORMAL INTENSIFIED ON.
      FORMAT COLOR COL_GROUP.
      text = itab4-text.
      MOVE '     DISB FROM FINANCING' TO itab4-text.
      PERFORM get_value.
      PERFORM tot_sub4.
      PERFORM write_detail1.
      PERFORM back_value.
      itab4-text = text.
      WRITE AT /1(c2) sy-uline.
      FORMAT COLOR COL_TOTAL.
      text = itab4-text.
      MOVE 'NET CASH FLOW-FINANCING' TO itab4-text.
      PERFORM get_value.
      PERFORM tot_sub5.
      PERFORM write_detail1.
      PERFORM back_value.
      itab4-text = text.
      FORMAT COLOR OFF.
      WRITE AT /1(c2) sy-uline.
      count = 1.
    ENDIF.
  ENDIF.
  IF itab4-zgroup EQ '4' AND itab4-in_out EQ '0'.
    sub7a = sub7a + itab4-value7.
    sub07 = sub07 + itab4-value.
  ENDIF.

  IF itab4-zgroup EQ '0' AND itab4-in_out EQ '1'.
    itab4-value1 = beg_feb.
    itab4-value2 = beg_mar.itab4-value3 = beg_apr.
    itab4-value4 = beg_mei.itab4-value5 = beg_jun.
    itab4-value6 = beg_jul.itab4-value7 = beg_agt.
    itab4-value8 = beg_sep.itab4-value9 = beg_okt.
    itab4-value10 = beg_nov.itab4-value11 = beg_des.
    itab4-value12 = beg_tot.
    WRITE AT /1(c2) sy-uline.

  ENDIF.
ENDFORM.                    " subtotal
*&---------------------------------------------------------------------*
*&      Form  GSBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM gsber.
  CLEAR v_gsber.REFRESH v_gsber.
  IF NOT s_gsber IS INITIAL.
    v_gsber-low  = s_gsber-low.
    v_gsber-high = s_gsber-high.
    v_gsber-sign = 'I'.
    v_gsber-option = 'EQ'.
  ELSE.
    v_gsber-low  = space.
    v_gsber-high = space.
    v_gsber-sign = 'E'.
    v_gsber-option = 'EQ'.
  ENDIF.
  APPEND v_gsber.
ENDFORM.                    " GSBER
*&---------------------------------------------------------------------*
*&      Form  TOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM total.
  v_fipos = '*'.
  CONCATENATE 'TOTAL' v_company INTO txt SEPARATED BY space.
  WRITE :/ sy-vline NO-GAP,(10) v_fipos CENTERED HOTSPOT,
          sy-vline NO-GAP,(20) txt,sy-vline NO-GAP,(8) ' ',
          sy-vline NO-GAP,(8) '*' ,
           sy-vline NO-GAP,(16) total CURRENCY 'IDR', sy-vline NO-GAP.
  total = 0.
ENDFORM.                    " TOTAL
*&---------------------------------------------------------------------*
*&      Form  ZEBRA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM zebra.
  IF sw = 0.
    FORMAT COLOR COL_NORMAL INTENSIFIED ON.
    sw = 1.
  ELSE.
    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    sw = 0.
  ENDIF.
ENDFORM.                    " ZEBRA
*&---------------------------------------------------------------------*
*&      Form  HEADER1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header1.
  FORMAT COLOR COL_HEADING.
  WRITE :/(73) 'CASH FLOW' CENTERED.
  WRITE :/(73) 'ENDING BALANCE' CENTERED.
  SKIP 1.
  WRITE :/(73) sy-uline.
  FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
  WRITE :/ sy-vline NO-GAP,(10) 'Cash Item' CENTERED,
           sy-vline NO-GAP,(20)
          'Keterangan' CENTERED, sy-vline NO-GAP,(8) 'Company',
           sy-vline NO-GAP,(8) 'BA' CENTERED,sy-vline NO-GAP,
           (16) 'Balance' CENTERED,sy-vline NO-GAP.
*            (16) 'Balance',SY-VLINE NO-GAP.
  WRITE :/(73) sy-uline.
ENDFORM.                                                    " HEADER1
*&---------------------------------------------------------------------*
*&      Form  WRITE_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_detail.
  SORT itab_fl BY item zgroup in_out.
  LOOP AT itab_fl.
    itab4-zfipos1 = itab_fl-zfipos1.
    itab4-zgroup = itab_fl-zgroup.
    itab4-in_out = itab_fl-in_out.
    itab4-item = itab_fl-item.
    CLEAR : itab_fl-value,itab_fl-value.
    AT END OF item.
      CLEAR itab_fl-text.
      SELECT SINGLE text INTO itab4-text FROM zficft
      WHERE item EQ itab_fl-item.
      SUM.
      itab4-value = itab_fl-value.
      itab4-value1 = itab_fl-value1.
      itab4-value2 = itab_fl-value2.
      itab4-value3 = itab_fl-value3.
      itab4-value4 = itab_fl-value4.
      itab4-value5 = itab_fl-value5.
      itab4-value6 = itab_fl-value6.
      itab4-value7 = itab_fl-value7.
      itab4-value8 = itab_fl-value8.
      itab4-value9 = itab_fl-value9.
      itab4-value10 = itab_fl-value10.
      itab4-value11 = itab_fl-value11.
      itab4-value12 = itab_fl-value12.

      APPEND itab4.
    ENDAT.
  ENDLOOP.
  PERFORM f_init_print.
  PERFORM header.
  PERFORM clear.

  LOOP AT itab4.
    PERFORM subtotal.
    PERFORM zebra.
    IF itab4-zgroup EQ '0' AND itab4-in_out EQ '1'.
      FORMAT COLOR COL_NORMAL INTENSIFIED ON.
      FORMAT COLOR COL_TOTAL.
      PERFORM write_end.
    ELSE.
      PERFORM write_detail1.

    ENDIF.
  ENDLOOP.
  WRITE AT /1(c2) sy-uline.
ENDFORM.                    " WRITE_DETAIL
*&---------------------------------------------------------------------*
*&      Form  F_INIT_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_print.
  w1   =  31.      w11 = 16.      w21 = 12.      w31 = 10.
  w2   =  16.      w12 = 16.      w22 = 10.      w32 = 12.
  w3   =  16.      w13 = 16.      w23 = 10.      w33 = 12.
  w4   =  16.      w14 = 16.      w24 = 12.      w34 = 10.
  w5   =  16.      w15 = 16.      w25 = 12.      w35 = 10.
  w6   =  16.      w16 = 8.       w26 = 10.
  w7   =  16.      w17 = 16.      w27 = 10.      w1a = 30.
  w8   =  16.      w18 = 16.      w28 = 12.
  w9   =  16.      w19 = 10.      w29 = 12.
  w10  =  16.      w20 = 12.      w30 = 10.
  c1 = 0.c2 = 0.

  IF p_perio EQ 1.
    c2 = w1 + w2 + w14 + 4 .
  ENDIF.

  IF p_perio EQ 2.
    c2 = w1 + w2 + w3 + w14 + 5 .
  ENDIF.

  IF p_perio EQ 3.
    c2 = w1 + w2 + w3 + w4 + w14 + 6.
  ENDIF.

  IF p_perio EQ 4.
    c2 = w1 + w2 + w3 + w4 + w5 + w14 + 7.
  ENDIF.

  IF p_perio EQ 5.
    c2 = w1 + w2 + w3 + w4 + w5 + w6 + w14 + 8.
  ENDIF.

  IF p_perio EQ 6.
    c2 = w1 + w2 + w3 + w4 + w5 + w6 + w7 + w14 + 9.
  ENDIF.

  IF p_perio EQ 7.
    c2 = w1 + w2 + w3 + w4 + w5 + w6 + w7 + w8 + w14 + 10.
  ENDIF.

  IF p_perio EQ 8.
    c2 = w1 + w2 + w3 + w4 + w5 + w6 + w7 + w8 + w9 + w14 + 11.
  ENDIF.

  IF p_perio EQ 9.
    c2 = w1 + w2 + w3 + w4 + w5 + w6 + w7 + w8 + w9 + w10 + w14 + 12.
  ENDIF.

  IF p_perio EQ 10.
    c2 = w1 + w2 + w3 + w4 + w5 + w6 + w7 + w8 + w9 + w10 + w11 +
         w14 + 13.
  ENDIF.

  IF p_perio EQ 11.
    c2 = w1 + w2 + w3 + w4 + w5 + w6 + w7 + w8 + w9 + w10 + w11 +
         w12 + w12 + 14.
  ENDIF.

  IF p_perio EQ 12.
    c2 = w1 + w2 + w3 + w4 + w5 + w6 + w7 + w8 + w9 + w10 + w11 +
         w12 + w13 + w14 + 15.
  ENDIF.

ENDFORM.                    " F_INIT_PRINT
*&---------------------------------------------------------------------*
*&      Form  WRITE_SUB1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_sub1.

  c1 = 1.
  WRITE :/(1) sy-vline NO-GAP.c1 = c1 + 1.
  FORMAT COLOR COL_HEADING.
  WRITE AT c1(w1) text NO-GAP.c1 = c1 + w1.
  FORMAT COLOR OFF.
  WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  IF p_perio GE 1.
    c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 2.
    c1 = c1 + w3.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 3.
    c1 = c1 + w4.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 4.
    c1 = c1 + w5.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 5.
    c1 = c1 + w6.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 6.
    c1 = c1 + w7.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 7.
    c1 = c1 + w8.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 8.
    c1 = c1 + w9.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 9.
    c1 = c1 + w10.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 10.
    c1 = c1 + w11.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 11.
    c1 = c1 + w12.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 12.
    c1 = c1 + w13.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.

ENDFORM.                    " WRITE_SUB1
*&---------------------------------------------------------------------*
*&      Form  WRITE_SUB2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_sub2.
  c1 = 1.
  WRITE :/(1) sy-vline NO-GAP.c1 = c1 + 1.
  c1 = c1 + w1.

  WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  IF p_perio GE 1.
    WRITE AT c1(w2) sy-uline.c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 2.
    WRITE AT c1(w2) sy-uline.c1 = c1 + w3.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 3.
    WRITE AT c1(w2) sy-uline.c1 = c1 + w4.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 4.
    WRITE AT c1(w2) sy-uline.c1 = c1 + w5.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 5.
    WRITE AT c1(w2) sy-uline.c1 = c1 + w6.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 6.
    WRITE AT c1(w2) sy-uline.c1 = c1 + w7.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 7.
    WRITE AT c1(w2) sy-uline.c1 = c1 + w8.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 8.
    WRITE AT c1(w2) sy-uline.c1 = c1 + w9.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 9.
    WRITE AT c1(w10) sy-uline.c1 = c1 + w10.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 10.
    WRITE AT c1(w11) sy-uline.c1 = c1 + w11.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 11.
    WRITE AT c1(w12) sy-uline.c1 = c1 + w12.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 12.
    WRITE AT c1(w13) sy-uline.c1 = c1 + w13.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  WRITE AT c1(w14) sy-uline.c1 = c1 + w14.
  WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.

ENDFORM.                    " WRITE_SUB2
*&---------------------------------------------------------------------*
*&      Form  WRITE_DETAIL1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_detail1.
  c1 = 1.
  WRITE :/(1) sy-vline NO-GAP.c1 = c1 + 2.
  WRITE AT c1(w1a) itab4-text NO-GAP.c1 = c1 + w1a.
  WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  IF p_perio GE 1.
    WRITE AT c1(w2) itab4-value1 CURRENCY 'IDR' NO-GAP HOTSPOT.
    c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value + itab4-value1.
  ENDIF.
  IF p_perio GE 2.
    WRITE AT c1(w3) itab4-value2 CURRENCY 'IDR' NO-GAP HOTSPOT.
    c1 = c1 + w3.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value + itab4-value2.
  ENDIF.
  IF p_perio GE 3.
    WRITE AT c1(w4) itab4-value3 CURRENCY 'IDR' NO-GAP HOTSPOT.
    c1 = c1 + w4.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value + itab4-value3.
  ENDIF.
  IF p_perio GE 4.
    WRITE AT c1(w5) itab4-value4 CURRENCY 'IDR' NO-GAP HOTSPOT.
    c1 = c1 + w5.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value + itab4-value4.
  ENDIF.
  IF p_perio GE 5.
    WRITE AT c1(w6) itab4-value5 CURRENCY 'IDR' NO-GAP HOTSPOT.
    c1 = c1 + w6.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value + itab4-value5.
  ENDIF.
  IF p_perio GE 6.
    WRITE AT c1(w7) itab4-value6 CURRENCY 'IDR' NO-GAP HOTSPOT.
    c1 = c1 + w7.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value + itab4-value6.
  ENDIF.
  IF p_perio GE 7.
    WRITE AT c1(w8) itab4-value7 CURRENCY 'IDR' NO-GAP HOTSPOT.
    c1 = c1 + w8.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value + itab4-value7.
  ENDIF.
  IF p_perio GE 8.
    WRITE AT c1(w9) itab4-value8 CURRENCY 'IDR' NO-GAP HOTSPOT.
    c1 = c1 + w9.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value + itab4-value8.
  ENDIF.
  IF p_perio GE 9.
    WRITE AT c1(w10) itab4-value9 CURRENCY 'IDR' NO-GAP HOTSPOT.
    c1 = c1 + w10.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value + itab4-value9.
  ENDIF.
  IF p_perio GE 10.
    WRITE AT c1(w11) itab4-value10 CURRENCY 'IDR' NO-GAP HOTSPOT.
    c1 = c1 + w11.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value + itab4-value10.
  ENDIF.
  IF p_perio GE 11.
    WRITE AT c1(w12) itab4-value11 CURRENCY 'IDR' NO-GAP HOTSPOT.
    c1 = c1 + w12.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value + itab4-value11.
  ENDIF.
  IF p_perio GE 12.
    WRITE AT c1(w13) itab4-value12 CURRENCY 'IDR' NO-GAP HOTSPOT.
    c1 = c1 + w13.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value + itab4-value12.
  ENDIF.
  WRITE AT c1(w14) itab4-value CURRENCY 'IDR' NO-GAP HOTSPOT.
  c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  itab4-value = 0.
ENDFORM.                    " WRITE_DETAIL1
*&---------------------------------------------------------------------*
*&      Form  SUBMIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM submit.
  SUBMIT aqzzzfi=========cf_01=========
        USING SELECTION-SET 'STANDARD'
        WITH s_fikrs  IN zfikrs
        WITH s_fipos IN zfipos1
*      WITH S_ZHLDT IN P_PERIO
        WITH s_buk_mp IN zbukrs
        WITH s_gsb_mp IN v_gsber
        WITH sp$00001 IN v_perio
        WITH s_vgjahr IN v_gjahr
        WITH zapos IN zapos
        AND RETURN.
ENDFORM.                    " SUBMIT
*&---------------------------------------------------------------------*
*&      Form  WRITE_BEG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_beg.
  c1 = 1.
  WRITE :/(1) sy-vline NO-GAP.c1 = c1 + 2.
  WRITE AT c1(w1a) itab4-text NO-GAP.c1 = c1 + w1a.
  WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  IF p_perio GE 1.
    WRITE AT c1(w2) itab4-value1 CURRENCY 'IDR' NO-GAP.c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 2.
    WRITE AT c1(w3) itab4-value2 CURRENCY 'IDR' NO-GAP.c1 = c1 + w3.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 3.
    WRITE AT c1(w4) itab4-value3 CURRENCY 'IDR' NO-GAP.c1 = c1 + w4.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 4.
    WRITE AT c1(w5) itab4-value4 CURRENCY 'IDR' NO-GAP.c1 = c1 + w5.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 5.
    WRITE AT c1(w6) itab4-value5 CURRENCY 'IDR' NO-GAP.c1 = c1 + w6.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 6.
    WRITE AT c1(w7) itab4-value6 CURRENCY 'IDR' NO-GAP.c1 = c1 + w7.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 7.
    WRITE AT c1(w8) itab4-value7 CURRENCY 'IDR' NO-GAP.c1 = c1 + w8.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 8.
    WRITE AT c1(w9) itab4-value8 CURRENCY 'IDR' NO-GAP.c1 = c1 + w9.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 9.
    WRITE AT c1(w10) itab4-value9 CURRENCY 'IDR' NO-GAP.c1 = c1 + w10.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 10.
    WRITE AT c1(w11) itab4-value10 CURRENCY 'IDR' NO-GAP.c1 = c1 + w11.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 11.
    WRITE AT c1(w12) itab4-value11 CURRENCY 'IDR' NO-GAP.c1 = c1 + w12.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  IF p_perio GE 12.
    WRITE AT c1(w13) itab4-value12 CURRENCY 'IDR' NO-GAP.c1 = c1 + w13.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  ENDIF.
  WRITE AT c1(w14) itab4-value CURRENCY 'IDR' NO-GAP.c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  itab4-value = 0.

ENDFORM.                    " WRITE_BEG
*&---------------------------------------------------------------------*
*&      Form  WRITE_END
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_end.
  c1 = 1.
  WRITE :/(1) sy-vline NO-GAP.c1 = c1 + 2.
  WRITE AT c1(w1a) itab4-text NO-GAP.c1 = c1 + w1a.
  WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  IF p_perio GE 1.
    WRITE AT c1(w2) itab4-value1 CURRENCY 'IDR' NO-GAP.c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value =  itab4-value1.
  ENDIF.
  IF p_perio GE 2.
    WRITE AT c1(w3) itab4-value2 CURRENCY 'IDR' NO-GAP.c1 = c1 + w3.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value2.
  ENDIF.
  IF p_perio GE 3.
    WRITE AT c1(w4) itab4-value3 CURRENCY 'IDR' NO-GAP.c1 = c1 + w4.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value3.
  ENDIF.
  IF p_perio GE 4.
    WRITE AT c1(w5) itab4-value4 CURRENCY 'IDR' NO-GAP.c1 = c1 + w5.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value4.
  ENDIF.
  IF p_perio GE 5.
    WRITE AT c1(w6) itab4-value5 CURRENCY 'IDR' NO-GAP.c1 = c1 + w6.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value5.
  ENDIF.
  IF p_perio GE 6.
    WRITE AT c1(w7) itab4-value6 CURRENCY 'IDR' NO-GAP.c1 = c1 + w7.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value6.
  ENDIF.
  IF p_perio GE 7.
    WRITE AT c1(w8) itab4-value7 CURRENCY 'IDR' NO-GAP.c1 = c1 + w8.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value7.
  ENDIF.
  IF p_perio GE 8.
    WRITE AT c1(w9) itab4-value8 CURRENCY 'IDR' NO-GAP.c1 = c1 + w9.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value8.
  ENDIF.
  IF p_perio GE 9.
    WRITE AT c1(w10) itab4-value9 CURRENCY 'IDR' NO-GAP.c1 = c1 + w10.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value9.
  ENDIF.
  IF p_perio GE 10.
    WRITE AT c1(w11) itab4-value10 CURRENCY 'IDR' NO-GAP.c1 = c1 + w11.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value10.
  ENDIF.
  IF p_perio GE 11.
    WRITE AT c1(w12) itab4-value11 CURRENCY 'IDR' NO-GAP.c1 = c1 + w12.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value11.
  ENDIF.
  IF p_perio GE 12.
    WRITE AT c1(w13) itab4-value12 CURRENCY 'IDR' NO-GAP.c1 = c1 + w13.
    WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
    itab4-value = itab4-value12.
  ENDIF.
  WRITE AT c1(w14) itab4-value CURRENCY 'IDR' NO-GAP.c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP.c1 = c1 + 1.
  itab4-value = 0.

ENDFORM.                    " WRITE_END
*&---------------------------------------------------------------------*
*&      Form  TOT_SUB1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tot_sub1.
  beg_jan1 = beg_jan1 + itab4-value1.
  beg_feb1 = beg_feb1 + itab4-value2.
  beg_mar1 = beg_mar1 + itab4-value3.
  beg_apr1 = beg_apr1 + itab4-value4.
  beg_mei1 = beg_mei1 + itab4-value5.
  beg_jun1 = beg_jun1 + itab4-value6.
  beg_jul1 = beg_jul1 + itab4-value7.
  beg_agt1 = beg_agt1 + itab4-value8.
  beg_sep1 = beg_sep1 + itab4-value9.
  beg_okt1 = beg_okt1 + itab4-value10.
  beg_nov1 = beg_nov1 + itab4-value11.
  beg_des1 = beg_des1 + itab4-value12.

ENDFORM.                                                    " TOT_SUB1
*&---------------------------------------------------------------------*
*&      Form  TOT_SUB2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tot_sub2.
  itab4-value1 = beg_jan1.
  itab4-value2 = beg_feb1.
  itab4-value3 = beg_mar1.
  itab4-value4 = beg_apr1.
  itab4-value5 = beg_mei1.
  itab4-value6 = beg_jun1.
  itab4-value7 = beg_jul1.
  itab4-value8 = beg_agt1.
  itab4-value9 = beg_sep1.
  itab4-value10 = beg_okt1.
  itab4-value11 = beg_nov1.
  itab4-value12 = beg_des1.

ENDFORM.                                                    " TOT_SUB2
*&---------------------------------------------------------------------*
*&      Form  TOT_SUB3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tot_sub3.
  end_jan = end_jan + itab4-value1.
  end_feb = end_feb + itab4-value2.
  end_mar = end_mar + itab4-value3.
  end_apr = end_apr + itab4-value4.
  end_mei = end_mei + itab4-value5.
  end_jun = end_jun + itab4-value6.
  end_jul = end_jul + itab4-value7.
  end_agt = end_agt + itab4-value8.
  end_sep = end_sep + itab4-value9.
  end_okt = end_okt + itab4-value10.
  end_nov = end_nov + itab4-value11.
  end_des = end_des + itab4-value12.

ENDFORM.                                                    " TOT_SUB3
*&---------------------------------------------------------------------*
*&      Form  TOT_SUB4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tot_sub4.
  itab4-value1 = end_jan.
  itab4-value2 = end_feb .
  itab4-value3 = end_mar.
  itab4-value4 = end_apr.
  itab4-value5 = end_mei.
  itab4-value6 = end_jun.
  itab4-value7 = end_jul.
  itab4-value8 = end_agt.
  itab4-value9 = end_sep.
  itab4-value10 = end_okt.
  itab4-value11 = end_nov.
  itab4-value12 = end_des.

ENDFORM.                                                    " TOT_SUB4
*&---------------------------------------------------------------------*
*&      Form  TOT_SUB5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tot_sub5.
  itab4-value1 = end_jan + beg_jan1.
  itab4-value2 = end_feb + beg_feb1.
  itab4-value3 = end_mar + beg_mar1.
  itab4-value4 = end_apr + beg_apr1.
  itab4-value5 = end_mei + beg_mei1.
  itab4-value6 = end_jun + beg_jun1.
  itab4-value7 = end_jul + beg_jul1.
  itab4-value8 = end_agt + beg_agt1.
  itab4-value9 = end_sep + beg_sep1.
  itab4-value10 = end_okt + beg_okt1.
  itab4-value11 = end_nov + beg_nov1.
  itab4-value12 = end_des + beg_des1.

ENDFORM.                                                    " TOT_SUB5
*&---------------------------------------------------------------------*
*&      Form  BACK_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM back_value.
  itab4-value1 = jan.
  itab4-value2 = feb.
  itab4-value3 = mar.
  itab4-value4 = apr.
  itab4-value5 = mei.
  itab4-value6 = jun.
  itab4-value7 = jul.
  itab4-value8 = agt.
  itab4-value9 = sep.
  itab4-value10 = okt.
  itab4-value11 = nov.
  itab4-value12 = des.
ENDFORM.                    " BACK_VALUE
*&---------------------------------------------------------------------*
*&      Form  GET_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_value.
  jan = itab4-value1.
  feb = itab4-value2.
  mar = itab4-value3.
  apr = itab4-value4.
  mei = itab4-value5.
  jun = itab4-value6.
  jul = itab4-value7.
  agt = itab4-value8.
  sep = itab4-value9.
  okt = itab4-value10.
  nov = itab4-value11.
  des = itab4-value12.

ENDFORM.                    " GET_VALUE
*&---------------------------------------------------------------------*
*&      Form  CLEAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear.
  CLEAR : beg_jan1,beg_feb1,beg_mar1,beg_apr1,beg_mei1,beg_jun1,beg_jul1,
                beg_agt1,beg_sep1,beg_okt1,beg_des1,beg_nov1.
  CLEAR : end_jan,end_feb,end_mar,end_apr,end_mei,end_jun,end_jul,
                end_agt,end_sep,end_okt,end_des,sw,end_nov.
ENDFORM.                    " CLEAR

*&---------------------------------------------------------------------*
*&      Form  F_ADD_DATA_FR_FMCI
*&---------------------------------------------------------------------*
FORM f_add_data_fr_fmci USING  fu_objnr.
  DATA : lt_fmci  TYPE STANDARD TABLE OF fmci,
         ls_fmci  TYPE fmci,
         lt_fmsu  LIKE i_fmsu OCCURS 0 WITH HEADER LINE.

  SELECT *
    FROM fmci
    INTO CORRESPONDING FIELDS OF TABLE lt_fmci
    WHERE fikrs = p_fikrs.

  IF lt_fmci[] IS NOT INITIAL.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE lt_fmsu
      FROM fmsu
      FOR ALL ENTRIES IN lt_fmci
      WHERE objnr = fu_objnr
        AND gjahr = p_gjahr
        AND wrttp IN ('57','61','64')
        AND posit = lt_fmci-posit
        AND bukrs = s_bukrs
        AND gsber IN s_gsber.

    LOOP AT lt_fmsu.
      READ TABLE lt_fmci INTO ls_fmci WITH KEY posit = lt_fmsu-posit.
      IF sy-subrc = 0.
        READ TABLE i_fmsu WITH KEY fipos = ls_fmci-fipex.
        IF sy-subrc <> 0.
          i_fmsu  = lt_fmsu.
          i_fmsu-fipos  = ls_fmci-fipex.
          APPEND i_fmsu.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_ADD_DATA_FR_FMCI
