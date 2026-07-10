REPORT zf_cash_flow_ytd_detail NO STANDARD PAGE HEADING LINE-SIZE 265.

TABLES : fmfpo,fmep,fmsu,zficf,zficft.

DATA : BEGIN OF i_fmsu OCCURS 0,
         fipos LIKE fmfpo-fipos.
        INCLUDE STRUCTURE fmsu.
DATA : END OF i_fmsu.

DATA : BEGIN OF i_fmfpo OCCURS 0,
         posit LIKE fmfpo-posit,
       END OF i_fmfpo.

DATA : BEGIN OF i_fmep OCCURS 0,
         objnr LIKE fmep-objnr,
         posit LIKE fmep-posit,
         twaer LIKE fmep-twaer,
         wrttp LIKE fmep-wrttp,
         gsber LIKE fmep-gsber,
         vgzei LIKE fmep-vgzei,
         kunnr LIKE fmep-kunnr,
         lifnr LIKE fmep-lifnr,
         lo_account LIKE fmep-lo_account,
         kozfi LIKE fmep-kozfi,
         budat LIKE fmep-budat,
         ldbtr LIKE fmep-ldbtr.
DATA : END OF i_fmep.

DATA : BEGIN OF i_zficft OCCURS 0,
         item LIKE zficft-item,
         text LIKE zficft-text,
       END OF i_zficft.

DATA : BEGIN OF i_fmfpot OCCURS 0,
         fipos LIKE fmfpot-fipos,
         bezeich LIKE fmfpot-bezeich,
       END OF i_fmfpot.

DATA : BEGIN OF i_fmcit OCCURS 0,
         fipex LIKE fmcit-fipex,
         bezei LIKE fmcit-bezei,
       END OF i_fmcit.

DATA : BEGIN OF i_kna1 OCCURS 0,
         kunnr LIKE kna1-kunnr,
         vbund LIKE kna1-vbund,
       END OF i_kna1.

DATA : BEGIN OF i_lfa1 OCCURS 0,
         lifnr LIKE lfa1-lifnr,
         vbund LIKE lfa1-vbund,
       END OF i_lfa1.

DATA : BEGIN OF i_ska1 OCCURS 0,
         saknr LIKE ska1-saknr,
         vbund LIKE ska1-vbund,
       END OF i_ska1.

DATA : BEGIN OF i_t880 OCCURS 0,
         rcomp LIKE t880-rcomp,
         name1 LIKE t880-name1,
       END OF i_t880.

DATA : BEGIN OF i_skat OCCURS 0,
         saknr LIKE skat-saknr,
         txt20 LIKE skat-txt20,
       END OF i_skat.

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
*         text LIKE zficft-text,
         text(60),
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
         bezeich LIKE fmfpot-bezeich,
         account LIKE fmep-lo_account,
         vbund LIKE kna1-vbund,
         fipos LIKE fmfpot-fipos,
         fipex LIKE fmcit-fipex,
       END OF itab_fl.

DATA: itab4 LIKE itab_fl OCCURS 0 WITH HEADER LINE,
      itab41 LIKE itab_fl OCCURS 0 WITH HEADER LINE,
      itab42 LIKE itab_fl OCCURS 0 WITH HEADER LINE,
      itab43 LIKE itab_fl OCCURS 0 WITH HEADER LINE,
      itab44 LIKE itab_fl OCCURS 0 WITH HEADER LINE,
      itab45 LIKE itab_fl OCCURS 0 WITH HEADER LINE.

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

* block 3
SELECTION-SCREEN BEGIN OF BLOCK 3 WITH FRAME TITLE text-403.
PARAMETERS:
           s_bukrs     LIKE  fmep-bukrs OBLIGATORY.
SELECT-OPTIONS:
           s_gsber     FOR  fmep-gsber NO INTERVALS.
SELECTION-SCREEN END OF BLOCK 3.
SELECTION-SCREEN SKIP.

* block 4
SELECTION-SCREEN BEGIN OF BLOCK 4 WITH FRAME TITLE text-404.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_rad10 RADIOBUTTON GROUP grp1 USER-COMMAND us1.
SELECTION-SCREEN : COMMENT 5(40) text-110  FOR FIELD p_rad10.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_rad20 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(40) text-120  FOR FIELD p_rad20.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_rad30 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(40) text-130  FOR FIELD p_rad30.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_rad40 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(40) text-140  FOR FIELD p_rad40.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_rad50 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(40) text-150  FOR FIELD p_rad50.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK 4.

AT SELECTION-SCREEN ON s_gsber.
  IF s_bukrs EQ '8020'.
    IF  s_gsber NE space AND s_gsber-low+0(2) NE '02'.
      MESSAGE e000(zs) WITH 'Bussniss Area must be entry 02xx'.
    ENDIF.
  ELSEIF s_bukrs EQ '8030'.
    IF s_gsber NE space AND s_gsber-low+0(2) NE '03'.
      MESSAGE e000(zs) WITH 'Bussiness Area must be entry 03xx'.
    ENDIF.
  ELSEIF s_bukrs EQ '8010'.
    IF s_gsber NE space AND s_gsber-low+0(2) NE '01'.
      MESSAGE e000(zs) WITH 'Bussiness Area must be entry 01xx'.
    ENDIF.
  ELSEIF s_bukrs EQ '8070'.
    IF s_gsber NE space AND s_gsber-low+0(2) NE '07'.
      MESSAGE e000(zs) WITH 'Bussiness Area must be entry 07xx'.
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

  SET PF-STATUS '100'.
  PERFORM get_data.
  PERFORM process_data.

AT USER-COMMAND.
  sy-lsind = 0.
  CASE sy-ucomm.
    WHEN 'LIST1'.
      p_rad10 = 'X'.
      CLEAR: p_rad20,p_rad30,p_rad40,p_rad50.
      PERFORM write_detail.
    WHEN 'LIST2'.
      p_rad20 = 'X'.
      CLEAR: p_rad10,p_rad30,p_rad40,p_rad50.
      PERFORM write_detail.
    WHEN 'LIST3'.
      p_rad30 = 'X'.
      CLEAR: p_rad10,p_rad20,p_rad40,p_rad50.
      PERFORM write_detail.
    WHEN 'LIST4'.
      p_rad40 = 'X'.
      CLEAR: p_rad10,p_rad20,p_rad30,p_rad50.
      PERFORM write_detail.
    WHEN 'LIST5'.
      p_rad50 = 'X'.
      CLEAR: p_rad10,p_rad20,p_rad30,p_rad40.
      PERFORM write_detail.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE  PROGRAM.
    WHEN 'CHOOSE'.
      PERFORM choose.
  ENDCASE.

AT LINE-SELECTION.
  PERFORM choose.

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
         total LIKE fmsu-btr001,
         li_fmsu LIKE i_fmsu OCCURS 0 WITH HEADER LINE,
         li_fmep LIKE i_fmep OCCURS 0 WITH HEADER LINE,
         li_itab_fl LIKE itab_fl OCCURS 0 WITH HEADER LINE.

  CONCATENATE 'FK' p_fikrs INTO objnr.

  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE i_fmsu
  FROM fmsu AS a JOIN fmfpo AS b ON a~objnr EQ b~fma_objnr AND
                                    a~posit EQ b~posit
  WHERE a~objnr EQ objnr   AND
        a~gjahr EQ p_gjahr AND
        a~bukrs EQ s_bukrs AND
        a~gsber IN s_gsber AND
        a~wrttp IN ('57','61','64').

  SELECT fipos btrvt a~posit a~objnr
  APPENDING CORRESPONDING FIELDS OF TABLE i_fmsu
  FROM fmsu AS a JOIN fmfpo AS b ON a~objnr EQ b~fma_objnr AND
                                    a~posit EQ b~posit
  WHERE a~objnr EQ objnr   AND
        a~gjahr EQ p_gjahr AND
        a~bukrs EQ s_bukrs AND
        a~gsber IN s_gsber AND
        a~wrttp EQ '04'.

* Get from FMEP
  li_fmsu[] = i_fmsu[].
  SORT li_fmsu BY posit.
  DELETE ADJACENT DUPLICATES FROM li_fmsu COMPARING posit.
  SELECT objnr posit gsber wrttp vgzei kunnr lo_account kozfi
         budat ldbtr twaer
  INTO CORRESPONDING FIELDS OF TABLE i_fmep
  FROM fmep
  FOR ALL ENTRIES IN li_fmsu
  WHERE posit = li_fmsu-posit AND
        objnr = objnr         AND
        bukrs = s_bukrs       AND
        gsber IN s_gsber      AND
        gjahr = p_gjahr.

  IF i_fmep[] IS NOT INITIAL.
* Get VBUND from KNA1
    CLEAR li_fmep. REFRESH li_fmep.
    li_fmep[] = i_fmep[].
    SORT li_fmep BY kunnr.
    DELETE ADJACENT DUPLICATES FROM li_fmep COMPARING kunnr.
    SELECT kunnr vbund
      INTO CORRESPONDING FIELDS OF TABLE i_kna1
      FROM kna1
      FOR ALL ENTRIES IN li_fmep
      WHERE kunnr = li_fmep-kunnr.
* Get VBUND from LFA1
    CLEAR li_fmep. REFRESH li_fmep.
    li_fmep[] = i_fmep[].
    SORT li_fmep BY lifnr.
    DELETE ADJACENT DUPLICATES FROM li_fmep COMPARING lifnr.
    SELECT lifnr vbund
      INTO CORRESPONDING FIELDS OF TABLE i_lfa1
      FROM lfa1
      FOR ALL ENTRIES IN li_fmep
      WHERE lifnr = li_fmep-lifnr.
* Get VBUND from SKA1
    CLEAR li_fmep. REFRESH li_fmep.
    li_fmep[] = i_fmep[].
    SORT li_fmep BY lo_account.
    DELETE ADJACENT DUPLICATES FROM li_fmep COMPARING lo_account.
    SELECT saknr vbund
      INTO CORRESPONDING FIELDS OF TABLE i_ska1
      FROM ska1
      FOR ALL ENTRIES IN li_fmep
      WHERE ktopl = 'TSPC' AND
            saknr = li_fmep-lo_account.
  ENDIF.

* Get VBUND from ZFICF
  IF s_bukrs = '8010' OR
     s_bukrs = '8090' OR
     s_bukrs = '8160'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE itab_fl FROM zficf
    WHERE item NOT IN ('1280','1380').
  ELSE.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE itab_fl FROM zficf
    WHERE item NE '1290'.
  ENDIF.

  IF itab_fl[] IS NOT INITIAL.
    LOOP AT itab_fl.
      itab_fl-fipos = itab_fl-zfipos1.
      itab_fl-fipex = itab_fl-zfipos1.
      MODIFY itab_fl TRANSPORTING fipos fipex.
    ENDLOOP.
* Get Item Text
    CLEAR li_itab_fl.
    REFRESH li_itab_fl.
    li_itab_fl[] = itab_fl[].
    SORT li_itab_fl BY item.
    DELETE ADJACENT DUPLICATES FROM li_itab_fl COMPARING item.
    SELECT item text
      INTO CORRESPONDING FIELDS OF TABLE i_zficft
      FROM zficft
      FOR ALL ENTRIES IN li_itab_fl
      WHERE item = li_itab_fl-item.
* Get Trading Partner Text
    CLEAR li_itab_fl. REFRESH li_itab_fl.
    li_itab_fl[] = itab_fl[].
    SORT li_itab_fl BY zfipos1.
    DELETE ADJACENT DUPLICATES FROM li_itab_fl COMPARING zfipos1.
*    SELECT fipos bezeich
*      INTO CORRESPONDING FIELDS OF TABLE i_fmfpot
*      FROM fmfpot
*      FOR ALL ENTRIES IN li_itab_fl
*      WHERE fikrs = p_fikrs AND
*            fipos = li_itab_fl-fipos.
    SELECT fipex bezei
      INTO CORRESPONDING FIELDS OF TABLE i_fmcit
      FROM fmcit
      FOR ALL ENTRIES IN li_itab_fl
      WHERE spras = sy-langu AND
            fikrs = p_fikrs  AND
            gjahr = '0000'   AND
            fipex = li_itab_fl-fipex.
  ENDIF.

* Get from SKAT
  SELECT saknr txt20
    INTO CORRESPONDING FIELDS OF TABLE i_skat
    FROM skat
    WHERE spras = sy-langu AND
          ktopl = 'TSPC'.

* Get from T880
  SELECT rcomp name1
    INTO CORRESPONDING FIELDS OF TABLE i_t880
    FROM t880.
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
*  WRITE AT c1(w1) 'DESCRIPTION ' CENTERED NO-GAP.c1 = c1 + w1.
  WRITE AT c1(w1a) 'DESCRIPTION ' CENTERED NO-GAP.c1 = c1 + w1a + 1.
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
      ENDLOOP.
    ENDIF.
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
    itab_fl-fipos = itab_fl-zfipos1.

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
  DATA: ld_text LIKE itab4-text.
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
  ELSE.
*    CASE 'X'.
*      WHEN p_rad10.
    READ CURRENT LINE FIELD VALUE itab4-text INTO ld_text.
    zfipos1-high = zfipos1-low = ld_text(5).
    zfipos1-sign = 'I'.
    zfipos1-option = 'EQ'.
    APPEND zfipos1.

*      WHEN p_rad20.
*        READ CURRENT LINE FIELD VALUE itab4-text INTO ld_text.
*
*      WHEN p_rad30.
*
*      WHEN p_rad40.
*
*      WHEN p_rad50.
*
*      WHEN OTHERS.
*    ENDCASE.
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
  PERFORM collect_itab4.
  PERFORM collect_itab41.
  PERFORM collect_itab42.
  PERFORM collect_itab43.
  PERFORM collect_itab44.
  PERFORM collect_itab45.

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
      CASE 'X'.
        WHEN p_rad10.
          PERFORM write_detail2.
        WHEN p_rad20.
          PERFORM write_detail3.
        WHEN p_rad30.
          PERFORM write_detail4.
        WHEN p_rad40.
          PERFORM write_detail5.
        WHEN p_rad50.
          PERFORM write_detail6.
      ENDCASE.
    ENDIF.
  ENDLOOP.
  WRITE AT /1(c2) sy-uline.
  count = 0.
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
  w7   =  16.      w17 = 16.      w27 = 10.      w1a = 40.
  w8   =  16.      w18 = 16.      w28 = 12.
  w9   =  16.      w19 = 10.      w29 = 12.
  w10  =  16.      w20 = 12.      w30 = 10.
  c1 = 0.c2 = 0.

  IF p_perio EQ 1.
    c2 = w1a + w2 + w14 + 5 .
  ENDIF.

  IF p_perio EQ 2.
    c2 = w1a + w2 + w3 + w14 + 6 .
  ENDIF.

  IF p_perio EQ 3.
    c2 = w1a + w2 + w3 + w4 + w14 + 7.
  ENDIF.

  IF p_perio EQ 4.
    c2 = w1a + w2 + w3 + w4 + w5 + w14 + 8.
  ENDIF.

  IF p_perio EQ 5.
    c2 = w1a + w2 + w3 + w4 + w5 + w6 + w14 + 9.
  ENDIF.

  IF p_perio EQ 6.
    c2 = w1a + w2 + w3 + w4 + w5 + w6 + w7 + w14 + 10.
  ENDIF.

  IF p_perio EQ 7.
    c2 = w1a + w2 + w3 + w4 + w5 + w6 + w7 + w8 + w14 + 11.
  ENDIF.

  IF p_perio EQ 8.
    c2 = w1a + w2 + w3 + w4 + w5 + w6 + w7 + w8 + w9 + w14 + 12.
  ENDIF.

  IF p_perio EQ 9.
    c2 = w1a + w2 + w3 + w4 + w5 + w6 + w7 + w8 + w9 + w10 + w14 + 13.
  ENDIF.

  IF p_perio EQ 10.
    c2 = w1a + w2 + w3 + w4 + w5 + w6 + w7 + w8 + w9 + w10 + w11 +
         w14 + 14.
  ENDIF.

  IF p_perio EQ 11.
    c2 = w1a + w2 + w3 + w4 + w5 + w6 + w7 + w8 + w9 + w10 + w11 +
         w12 + w12 + 15.
  ENDIF.

  IF p_perio EQ 12.
    c2 = w1a + w2 + w3 + w4 + w5 + w6 + w7 + w8 + w9 + w10 + w11 +
         w12 + w13 + w14 + 16.
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
*  WRITE AT c1(w1) text NO-GAP.c1 = c1 + w1.
  WRITE AT c1(w1a) text NO-GAP.c1 = c1 + w1a + 1.
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
*  c1 = c1 + w1.
  c1 = c1 + w1a + 1.

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
*&      Form  WRITE_DETAIL2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_detail2.
  DATA: l_c1 TYPE i.
  LOOP AT itab41 WHERE item = itab4-item       AND
*                       zfipos1 = itab4-zfipos1 AND
                       zgroup = itab4-zgroup   AND
                       in_out = itab4-in_out.
    CLEAR itab4.
    itab4 = itab41.
    PERFORM zebra.
    c1 = 1.
    WRITE :/(1) sy-vline NO-GAP. l_c1 = c1 + 3. c1 = c1 + 2.
    WRITE AT l_c1(w1a) itab4-text NO-GAP.c1 = c1 + w1a.
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
  ENDLOOP.
ENDFORM.                    " WRITE_DETAIL2

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
*&      Form  F_APPEND_ITAB42
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_append_itab42 .
  IF itab42[] IS INITIAL OR itab43[] IS INITIAL OR
     itab44[] IS INITIAL OR itab45[] IS INITIAL.

    SORT i_fmsu BY fipos posit gsber wrttp.
    SORT i_fmep BY posit gsber wrttp.
    SORT i_kna1 BY kunnr.
    SORT i_lfa1 BY lifnr.
    SORT i_ska1 BY saknr.

    CLEAR: itab42-text,itab43-text,itab44-text,itab45-text.
    itab42-zfipos1 = itab43-zfipos1 = itab44-zfipos1 = itab45-zfipos1 = itab_fl-zfipos1.
    itab42-zgroup  = itab43-zgroup  = itab44-zgroup  = itab45-zgroup  = itab_fl-zgroup.
    itab42-in_out  = itab43-in_out  = itab44-in_out  = itab45-in_out  = itab_fl-in_out.
    itab42-item    = itab43-item    = itab44-item    = itab45-item    = itab_fl-item.

    LOOP AT i_fmsu WHERE fipos EQ itab42-zfipos1.
      LOOP AT i_fmep WHERE posit = i_fmsu-posit AND
                           gsber = i_fmsu-gsber AND
                           wrttp = i_fmsu-wrttp.
        IF i_fmep-kunnr IS NOT INITIAL.
          CLEAR i_kna1.
          READ TABLE i_kna1 WITH KEY kunnr = i_fmep-kunnr.
          itab43-vbund = itab44-vbund = itab45-vbund = i_kna1-vbund.
        ELSEIF i_fmep-lifnr IS NOT INITIAL.
          CLEAR i_lfa1.
          READ TABLE i_lfa1 WITH KEY lifnr = i_fmep-lifnr.
          itab43-vbund = itab44-vbund = itab45-vbund = i_lfa1-vbund.
        ELSEIF i_fmep-lo_account IS NOT INITIAL.
          CLEAR i_ska1.
          READ TABLE i_ska1 WITH KEY saknr = i_fmep-lo_account.
          itab43-vbund = itab44-vbund = itab45-vbund = i_ska1-vbund.
        ENDIF.

        IF p_rad20 = 'X' AND itab42[] IS INITIAL.
          PERFORM f_collect_itab42.
        ELSEIF p_rad30 = 'X' AND itab43[] IS INITIAL.
          PERFORM f_collect_itab43.
        ELSEIF p_rad40 = 'X' AND itab44[] IS INITIAL.
          PERFORM f_collect_itab44.
        ELSEIF p_rad50 = 'X' AND itab45[] IS INITIAL.
          PERFORM f_collect_itab45.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_APPEND_ITAB42

*&---------------------------------------------------------------------*
*&      Form  WRITE_DETAIL3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_detail3 .
  DATA: l_c1 TYPE i.
  DATA: ld_txt20 LIKE skat-txt20.

  LOOP AT itab42 WHERE item = itab4-item       AND
*                       zfipos1 = itab4-zfipos1 AND
                       zgroup = itab4-zgroup   AND
                       in_out = itab4-in_out.
*    SELECT SINGLE txt20
*      INTO ld_txt20
*      FROM skat
*      WHERE spras = sy-langu AND
*            ktopl = 'TSPC'   AND
*            saknr = itab42-text.
*    CONCATENATE itab42-text ld_txt20 INTO itab42-text SEPARATED BY '-'.
    CLEAR i_skat.
    READ TABLE i_skat WITH KEY saknr = itab42-text.
    CONCATENATE itab42-text i_skat-txt20 INTO itab42-text SEPARATED BY '-'.

    CLEAR itab4.
    itab4 = itab42.
    PERFORM zebra.
    c1 = 1.
    WRITE :/(1) sy-vline NO-GAP. l_c1 = c1 + 3. c1 = c1 + 2.
    WRITE AT l_c1(w1a) itab4-text NO-GAP.c1 = c1 + w1a.
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
  ENDLOOP.
ENDFORM.                    " WRITE_DETAIL3

*&---------------------------------------------------------------------*
*&      Form  WRITE_DETAIL4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_detail4 .
  DATA: l_c1 TYPE i,
        l_c2 TYPE i,
        l_name1 LIKE t880-name1.

  LOOP AT itab41 WHERE item = itab4-item       AND
*                       zfipos1 = itab4-zfipos1 AND
                       zgroup = itab4-zgroup   AND
                       in_out = itab4-in_out.
    CLEAR itab4.
    itab4 = itab41.
    PERFORM zebra.
    c1 = 1.
    WRITE :/(1) sy-vline NO-GAP. l_c1 = c1 + 3. c1 = c1 + 2.
    WRITE AT l_c1(w1a) itab4-text NO-GAP.c1 = c1 + w1a.
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

    LOOP AT itab43 WHERE item = itab4-item       AND
                         zfipos1 = itab4-zfipos1 AND
                         zgroup = itab4-zgroup   AND
                         in_out = itab4-in_out.
*      SELECT SINGLE name1
*        INTO l_name1
*        FROM t880
*        WHERE rcomp = itab43-vbund.
*      CONCATENATE itab43-text l_name1 INTO itab43-text SEPARATED BY '-'.
      CLEAR i_t880.
      READ TABLE i_t880 WITH KEY rcomp = itab43-vbund.
      CONCATENATE itab43-text i_t880-name1 INTO itab43-text SEPARATED BY '-'.

      CLEAR itab4.
      itab4 = itab43.
      PERFORM zebra.
      c1 = 1.
      WRITE :/(1) sy-vline NO-GAP. l_c2 = c1 + 4. c1 = c1 + 2.
      WRITE AT l_c2(w1a) itab4-text NO-GAP.c1 = c1 + w1a.
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
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " WRITE_DETAIL4

*&---------------------------------------------------------------------*
*&      Form  WRITE_DETAIL5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_detail5 .
  DATA: l_c1 TYPE i,
        l_c2 TYPE i,
        l_name1 LIKE t880-name1.
  DATA: ld_txt20 LIKE skat-txt20.

  LOOP AT itab42 WHERE item = itab4-item       AND
*                       zfipos1 = itab4-zfipos1 AND
                       zgroup = itab4-zgroup   AND
                       in_out = itab4-in_out.
*    SELECT SINGLE txt20
*      INTO ld_txt20
*      FROM skat
*      WHERE spras = sy-langu AND
*            ktopl = 'TSPC'   AND
*            saknr = itab42-text.
*    CONCATENATE itab42-text ld_txt20 INTO itab42-text SEPARATED BY '-'.
    CLEAR i_skat.
    READ TABLE i_skat WITH KEY saknr = itab42-text.
    CONCATENATE itab42-text i_skat-txt20 INTO itab42-text SEPARATED BY '-'.

    CLEAR itab4.
    itab4 = itab42.
    PERFORM zebra.
    c1 = 1.
    WRITE :/(1) sy-vline NO-GAP. l_c1 = c1 + 3. c1 = c1 + 2.
    WRITE AT l_c1(w1a) itab4-text NO-GAP.c1 = c1 + w1a.
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

    LOOP AT itab44 WHERE item = itab4-item       AND
                         zfipos1 = itab4-zfipos1 AND
                         zgroup = itab4-zgroup   AND
                         in_out = itab4-in_out   AND
                         account = itab4-account.
*      SELECT SINGLE name1
*        INTO l_name1
*        FROM t880
*        WHERE rcomp = itab44-vbund.
*      CONCATENATE itab44-text l_name1 INTO itab44-text SEPARATED BY '-'.
      CLEAR i_t880.
      READ TABLE i_t880 WITH KEY rcomp = itab44-vbund.
      CONCATENATE itab44-text i_t880-name1 INTO itab44-text SEPARATED BY '-'.

      CLEAR itab4.
      itab4 = itab44.
      PERFORM zebra.
      c1 = 1.
      WRITE :/(1) sy-vline NO-GAP. l_c2 = c1 + 4. c1 = c1 + 2.
      WRITE AT l_c2(w1a) itab4-text NO-GAP.c1 = c1 + w1a.
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
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " WRITE_DETAIL5

*&---------------------------------------------------------------------*
*&      Form  WRITE_DETAIL6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_detail6 .
  DATA: l_c1 TYPE i,
        l_name1 LIKE t880-name1.

  LOOP AT itab45 WHERE item = itab4-item       AND
*                       zfipos1 = itab4-zfipos1 AND
                       zgroup = itab4-zgroup   AND
                       in_out = itab4-in_out.
*    SELECT SINGLE name1
*      INTO l_name1
*      FROM t880
*      WHERE rcomp = itab45-vbund.
*    CONCATENATE itab45-text l_name1 INTO itab45-text SEPARATED BY '-'.
    CLEAR i_t880.
    READ TABLE i_t880 WITH KEY rcomp = itab45-vbund.
    CONCATENATE itab45-text i_t880-name1 INTO itab45-text SEPARATED BY '-'.

    CLEAR itab4.
    itab4 = itab45.
    PERFORM zebra.
    c1 = 1.
    WRITE :/(1) sy-vline NO-GAP. l_c1 = c1 + 3. c1 = c1 + 2.
    WRITE AT l_c1(w1a) itab4-text NO-GAP.c1 = c1 + w1a.
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
  ENDLOOP.
ENDFORM.                    " WRITE_DETAIL6

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_ITAB42
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_itab42 .
  itab42-text = i_fmep-lo_account.
  itab42-account = i_fmep-lo_account.
  CASE i_fmep-budat+4(2).
    WHEN '01'.
      itab42-value1 = i_fmep-ldbtr.
    WHEN '02'.
      itab42-value2 = i_fmep-ldbtr.
    WHEN '03'.
      itab42-value3 = i_fmep-ldbtr.
    WHEN '04'.
      itab42-value4 = i_fmep-ldbtr.
    WHEN '05'.
      itab42-value5 = i_fmep-ldbtr.
    WHEN '06'.
      itab42-value6 = i_fmep-ldbtr.
    WHEN '07'.
      itab42-value7 = i_fmep-ldbtr.
    WHEN '08'.
      itab42-value8 = i_fmep-ldbtr.
    WHEN '09'.
      itab42-value9 = i_fmep-ldbtr.
    WHEN '10'.
      itab42-value10 = i_fmep-ldbtr.
    WHEN '11'.
      itab42-value11 = i_fmep-ldbtr.
    WHEN '12'.
      itab42-value12 = i_fmep-ldbtr.
    WHEN OTHERS.
  ENDCASE.
  COLLECT itab42.
  CLEAR: itab42-value,itab42-value1,itab42-value2,itab42-value3,itab42-value4,itab42-value5,
         itab42-value6,itab42-value7,itab42-value8,itab42-value9,itab42-value10,itab42-value11,
         itab42-value12.
ENDFORM.                    " F_COLLECT_ITAB42

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_ITAB43
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_itab43 .
  itab43-text = itab43-vbund.
  CASE i_fmep-budat+4(2).
    WHEN '01'.
      itab43-value1 = i_fmep-ldbtr.
    WHEN '02'.
      itab43-value2 = i_fmep-ldbtr.
    WHEN '03'.
      itab43-value3 = i_fmep-ldbtr.
    WHEN '04'.
      itab43-value4 = i_fmep-ldbtr.
    WHEN '05'.
      itab43-value5 = i_fmep-ldbtr.
    WHEN '06'.
      itab43-value6 = i_fmep-ldbtr.
    WHEN '07'.
      itab43-value7 = i_fmep-ldbtr.
    WHEN '08'.
      itab43-value8 = i_fmep-ldbtr.
    WHEN '09'.
      itab43-value9 = i_fmep-ldbtr.
    WHEN '10'.
      itab43-value10 = i_fmep-ldbtr.
    WHEN '11'.
      itab43-value11 = i_fmep-ldbtr.
    WHEN '12'.
      itab43-value12 = i_fmep-ldbtr.
    WHEN OTHERS.
  ENDCASE.
  COLLECT itab43.
  CLEAR: itab43-value,itab43-value1,itab43-value2,itab43-value3,itab43-value4,itab43-value5,
         itab43-value6,itab43-value7,itab43-value8,itab43-value9,itab43-value10,itab43-value11,
         itab43-value12.
ENDFORM.                    " F_COLLECT_ITAB43

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_ITAB44
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_itab44 .
  itab44-text = itab44-vbund.
  itab44-account = i_fmep-lo_account.
  CASE i_fmep-budat+4(2).
    WHEN '01'.
      itab44-value1 = i_fmep-ldbtr.
    WHEN '02'.
      itab44-value2 = i_fmep-ldbtr.
    WHEN '03'.
      itab44-value3 = i_fmep-ldbtr.
    WHEN '04'.
      itab44-value4 = i_fmep-ldbtr.
    WHEN '05'.
      itab44-value5 = i_fmep-ldbtr.
    WHEN '06'.
      itab44-value6 = i_fmep-ldbtr.
    WHEN '07'.
      itab44-value7 = i_fmep-ldbtr.
    WHEN '08'.
      itab44-value8 = i_fmep-ldbtr.
    WHEN '09'.
      itab44-value9 = i_fmep-ldbtr.
    WHEN '10'.
      itab44-value10 = i_fmep-ldbtr.
    WHEN '11'.
      itab44-value11 = i_fmep-ldbtr.
    WHEN '12'.
      itab44-value12 = i_fmep-ldbtr.
    WHEN OTHERS.
  ENDCASE.
  COLLECT itab44.
  CLEAR: itab44-value,itab44-value1,itab44-value2,itab44-value3,itab44-value4,itab44-value5,
         itab44-value6,itab44-value7,itab44-value8,itab44-value9,itab44-value10,itab44-value11,
         itab44-value12.
ENDFORM.                    " F_COLLECT_ITAB44

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_ITAB45
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_itab45 .
  itab45-text = itab45-vbund.
  CASE i_fmep-budat+4(2).
    WHEN '01'.
      itab45-value1 = i_fmep-ldbtr.
    WHEN '02'.
      itab45-value2 = i_fmep-ldbtr.
    WHEN '03'.
      itab45-value3 = i_fmep-ldbtr.
    WHEN '04'.
      itab45-value4 = i_fmep-ldbtr.
    WHEN '05'.
      itab45-value5 = i_fmep-ldbtr.
    WHEN '06'.
      itab45-value6 = i_fmep-ldbtr.
    WHEN '07'.
      itab45-value7 = i_fmep-ldbtr.
    WHEN '08'.
      itab45-value8 = i_fmep-ldbtr.
    WHEN '09'.
      itab45-value9 = i_fmep-ldbtr.
    WHEN '10'.
      itab45-value10 = i_fmep-ldbtr.
    WHEN '11'.
      itab45-value11 = i_fmep-ldbtr.
    WHEN '12'.
      itab45-value12 = i_fmep-ldbtr.
    WHEN OTHERS.
  ENDCASE.
  COLLECT itab45.
  CLEAR: itab45-value,itab45-value1,itab45-value2,itab45-value3,itab45-value4,itab45-value5,
         itab45-value6,itab45-value7,itab45-value8,itab45-value9,itab45-value10,itab45-value11,
         itab45-value12.
ENDFORM.                    " F_COLLECT_ITAB45

*&---------------------------------------------------------------------*
*&      Form  COLLECT_ITAB4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM collect_itab4 .
  IF itab4[] IS INITIAL.
    SORT itab_fl BY item zgroup in_out zfipos1.
    LOOP AT itab_fl.
*      itab4-zfipos1 = itab_fl-zfipos1.
      itab4-zgroup = itab_fl-zgroup.
      itab4-in_out = itab_fl-in_out.
      itab4-item = itab_fl-item.
      AT END OF item.
        CLEAR: itab4-text,i_zficft.
        READ TABLE i_zficft WITH KEY item = itab_fl-item.
        itab4-text = i_zficft-text.
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
        APPEND itab4. CLEAR itab4.
      ENDAT.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " COLLECT_ITAB4

*&---------------------------------------------------------------------*
*&      Form  COLLECT_ITAB41
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM collect_itab41 .
  IF p_rad10 = 'X' OR p_rad30 = 'X'.
    IF itab41[] IS INITIAL.
      SORT itab_fl BY item zgroup in_out zfipos1.
      LOOP AT itab_fl.
        CLEAR: itab41-text,i_fmcit.
        itab41-zfipos1 = itab_fl-zfipos1.
        itab41-zgroup  = itab_fl-zgroup.
        itab41-in_out  = itab_fl-in_out.
        itab41-item    = itab_fl-item.
        READ TABLE i_fmcit WITH KEY fipex = itab_fl-fipex.
        itab41-text = i_fmcit-bezei.
        itab41-value = itab_fl-value.
        itab41-value1 = itab_fl-value1.
        itab41-value2 = itab_fl-value2.
        itab41-value3 = itab_fl-value3.
        itab41-value4 = itab_fl-value4.
        itab41-value5 = itab_fl-value5.
        itab41-value6 = itab_fl-value6.
        itab41-value7 = itab_fl-value7.
        itab41-value8 = itab_fl-value8.
        itab41-value9 = itab_fl-value9.
        itab41-value10 = itab_fl-value10.
        itab41-value11 = itab_fl-value11.
        itab41-value12 = itab_fl-value12.
        CONCATENATE itab_fl-zfipos1 itab41-text INTO itab41-text
                                                SEPARATED BY '-'.
        COLLECT itab41. CLEAR itab41.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " COLLECT_ITAB41

*&---------------------------------------------------------------------*
*&      Form  COLLECT_ITAB42
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM collect_itab42 .
  IF p_rad20 = 'X' OR p_rad40 = 'X'.
    IF itab42[] IS INITIAL.
      SORT i_fmsu BY fipos posit gsber wrttp.
      SORT i_fmep BY posit gsber wrttp lo_account.
      SORT i_kna1 BY kunnr.
      SORT i_lfa1 BY lifnr.
      SORT i_ska1 BY saknr.
      SORT itab_fl BY item zgroup in_out zfipos1.

      LOOP AT itab_fl.
        CLEAR: itab42-text.
        itab42-zfipos1 = itab_fl-zfipos1.
        itab42-zgroup  = itab_fl-zgroup.
        itab42-in_out  = itab_fl-in_out.
        itab42-item    = itab_fl-item.
        LOOP AT i_fmsu WHERE fipos EQ itab42-zfipos1.
          LOOP AT i_fmep WHERE posit = i_fmsu-posit AND
                               twaer = i_fmsu-twaer AND
                               gsber = i_fmsu-gsber AND
                               wrttp = i_fmsu-wrttp.
            PERFORM f_collect_itab42.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " COLLECT_ITAB42

*&---------------------------------------------------------------------*
*&      Form  COLLECT_ITAB43
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM collect_itab43 .
  IF itab43[] IS INITIAL AND p_rad30 = 'X'.
    SORT i_fmsu BY fipos posit gsber wrttp.
    SORT i_fmep BY posit gsber wrttp.
    SORT i_kna1 BY kunnr.
    SORT i_lfa1 BY lifnr.
    SORT i_ska1 BY saknr.
    SORT itab_fl BY item zgroup in_out zfipos1.

    LOOP AT itab_fl.
      CLEAR: itab43-text.
      itab43-zfipos1 = itab_fl-zfipos1.
      itab43-zgroup  = itab_fl-zgroup.
      itab43-in_out  = itab_fl-in_out.
      itab43-item    = itab_fl-item.
      LOOP AT i_fmsu WHERE fipos EQ itab43-zfipos1.
        LOOP AT i_fmep WHERE posit = i_fmsu-posit AND
                             twaer = i_fmsu-twaer AND
                             gsber = i_fmsu-gsber AND
                             wrttp = i_fmsu-wrttp.
          IF i_fmep-kunnr IS NOT INITIAL.
            CLEAR i_kna1.
            READ TABLE i_kna1 WITH KEY kunnr = i_fmep-kunnr.
            itab43-vbund = i_kna1-vbund.
          ELSEIF i_fmep-lifnr IS NOT INITIAL.
            CLEAR i_lfa1.
            READ TABLE i_lfa1 WITH KEY lifnr = i_fmep-lifnr.
            itab43-vbund = i_lfa1-vbund.
          ELSEIF i_fmep-lo_account IS NOT INITIAL.
            CLEAR i_ska1.
            READ TABLE i_ska1 WITH KEY saknr = i_fmep-lo_account.
            itab43-vbund = i_ska1-vbund.
          ENDIF.
          PERFORM f_collect_itab43.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " COLLECT_ITAB43

*&---------------------------------------------------------------------*
*&      Form  COLLECT_ITAB44
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM collect_itab44 .
  IF itab44[] IS INITIAL AND p_rad40 = 'X'.
    SORT i_fmsu BY fipos posit gsber wrttp.
    SORT i_fmep BY posit gsber wrttp lo_account.
    SORT i_kna1 BY kunnr.
    SORT i_lfa1 BY lifnr.
    SORT i_ska1 BY saknr.
    SORT itab_fl BY item zgroup in_out zfipos1.

    LOOP AT itab_fl.
      CLEAR: itab44-text.
      itab44-zfipos1 = itab_fl-zfipos1.
      itab44-zgroup  = itab_fl-zgroup.
      itab44-in_out  = itab_fl-in_out.
      itab44-item    = itab_fl-item.
      LOOP AT i_fmsu WHERE fipos EQ itab44-zfipos1.
        LOOP AT i_fmep WHERE posit = i_fmsu-posit AND
                             twaer = i_fmsu-twaer AND
                             gsber = i_fmsu-gsber AND
                             wrttp = i_fmsu-wrttp.
          IF i_fmep-kunnr IS NOT INITIAL.
            CLEAR i_kna1.
            READ TABLE i_kna1 WITH KEY kunnr = i_fmep-kunnr.
            itab44-vbund = i_kna1-vbund.
          ELSEIF i_fmep-lifnr IS NOT INITIAL.
            CLEAR i_lfa1.
            READ TABLE i_lfa1 WITH KEY lifnr = i_fmep-lifnr.
            itab44-vbund = i_lfa1-vbund.
          ELSEIF i_fmep-lo_account IS NOT INITIAL.
            CLEAR i_ska1.
            READ TABLE i_ska1 WITH KEY saknr = i_fmep-lo_account.
            itab44-vbund = i_ska1-vbund.
          ENDIF.
          PERFORM f_collect_itab44.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " COLLECT_ITAB44

*&---------------------------------------------------------------------*
*&      Form  COLLECT_ITAB45
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM collect_itab45 .
  IF itab45[] IS INITIAL AND p_rad50 = 'X'.
    SORT i_fmsu BY fipos posit gsber wrttp.
    SORT i_fmep BY posit gsber wrttp.
    SORT i_kna1 BY kunnr.
    SORT i_lfa1 BY lifnr.
    SORT i_ska1 BY saknr.
    SORT itab_fl BY item zgroup in_out zfipos1.
    LOOP AT itab_fl.
      CLEAR: itab45-text.
      itab45-zfipos1 = itab_fl-zfipos1.
      itab45-zgroup  = itab_fl-zgroup.
      itab45-in_out  = itab_fl-in_out.
      itab45-item    = itab_fl-item.
      LOOP AT i_fmsu WHERE fipos EQ itab_fl-zfipos1.
        LOOP AT i_fmep WHERE posit = i_fmsu-posit AND
                             twaer = i_fmsu-twaer AND
                             gsber = i_fmsu-gsber AND
                             wrttp = i_fmsu-wrttp.
          IF i_fmep-kunnr IS NOT INITIAL.
            CLEAR i_kna1.
            READ TABLE i_kna1 WITH KEY kunnr = i_fmep-kunnr.
            itab45-vbund = i_kna1-vbund.
          ELSEIF i_fmep-lifnr IS NOT INITIAL.
            CLEAR i_lfa1.
            READ TABLE i_lfa1 WITH KEY lifnr = i_fmep-lifnr.
            itab45-vbund = i_lfa1-vbund.
          ELSEIF i_fmep-lo_account IS NOT INITIAL.
            CLEAR i_ska1.
            READ TABLE i_ska1 WITH KEY saknr = i_fmep-lo_account.
            itab45-vbund = i_ska1-vbund.
          ENDIF.
          PERFORM f_collect_itab45.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " COLLECT_ITAB45

*&---------------------------------------------------------------------*
*&      Form  CHOOSE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM choose .
  READ CURRENT LINE FIELD VALUE: itab2-fipos,itab2-bukrs,itab2-gsber,
                                 itab4-text,itab4-item,txt,v_fipos.

  DATA : ffield(20), fvalue(20),v_twaer LIKE fmep-twaer.
  GET CURSOR FIELD ffield VALUE fvalue.
  CASE ffield.

    WHEN 'ITAB4-VALUE1'.
      l_perio = 1.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      PERFORM submit.
    WHEN 'ITAB4-VALUE2'.
      l_perio = 2.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      PERFORM submit.

    WHEN 'ITAB4-VALUE3'.
      l_perio = 3.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      PERFORM submit.

    WHEN 'ITAB4-VALUE4'.
      l_perio = 4.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      PERFORM submit.

    WHEN 'ITAB4-VALUE5'.
      l_perio = 5.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      PERFORM submit.

    WHEN 'ITAB4-VALUE6'.
      l_perio = 6.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      PERFORM submit.

    WHEN 'ITAB4-VALUE7'.
      l_perio = 7.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      PERFORM submit.

    WHEN 'ITAB4-VALUE8'.
      l_perio = 8.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      PERFORM submit.

    WHEN 'ITAB4-VALUE9'.
      l_perio = 9.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      PERFORM submit.

    WHEN 'ITAB4-VALUE10'.
      l_perio = 10.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      PERFORM submit.

    WHEN 'ITAB4-VALUE11'.
      l_perio = 11.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      PERFORM submit.

    WHEN 'ITAB4-VALUE12'.
      l_perio = 12.l_perio1 = l_perio.
      PERFORM detail_item.
      PERFORM gsber.
      PERFORM submit.

    WHEN 'ITAB4-VALUE'.
      l_perio = 1.l_perio1 = p_perio.
      PERFORM detail_item.
      PERFORM gsber.
      PERFORM submit.

  ENDCASE.
  CLEAR : itab4-text.
ENDFORM.                    " CHOOSE
