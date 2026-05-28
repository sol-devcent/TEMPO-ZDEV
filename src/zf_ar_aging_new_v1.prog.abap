REPORT zf_ar_aging MESSAGE-ID zs NO STANDARD PAGE HEADING
*                                  LINE-COUNT 80
                                  LINE-COUNT 65
                                  LINE-SIZE  240.

TABLES : bsid,tgsb,t001, tvbur,knvv,kna1.

TYPES : BEGIN OF ty_kna1,
          kunnr   TYPE knvv-kunnr,
          vkbur   TYPE knvv-vkbur,
          kdgrp   TYPE knvv-kdgrp,
          kvgr3   TYPE knvv-kvgr3,
          brsch   TYPE kna1-brsch,
          sortl   TYPE kna1-sortl,
        END OF ty_kna1.

DATA : gt_kna1      TYPE STANDARD TABLE OF ty_kna1 INITIAL SIZE 0,
       gt_kna1_add  TYPE STANDARD TABLE OF ty_kna1 INITIAL SIZE 0.

DATA: BEGIN OF it_bsid OCCURS 0,
         bukrs LIKE bsid-bukrs,        " Company Code
         vkbur LIKE knvv-vkbur,        " Business Area
         kunnr LIKE bsid-kunnr,        " Cust code
         gjahr LIKE bsid-gjahr,        " Fiscal Year
         belnr LIKE bsid-belnr,        " Document No
         buzei LIKE bsid-buzei,
         budat LIKE bsid-budat,        " Posting Date
         augdt LIKE bsid-augdt,        " Clearing date.
         monat LIKE bsid-monat,        " Periode
         dmbtr LIKE bsid-dmbtr,        " Amount in local curr
         shkzg LIKE bsid-shkzg,        " Debit/Credit indicator.
         zfbdt LIKE bsid-zfbdt,        " Baseline Date
         zbd1t LIKE bsid-zbd1t,        " Term of payment
         blart LIKE bsid-blart,        " Document Type
         xref1 LIKE bsid-xref1,        " Route List
         xref2 LIKE bsid-xref2,        " Salesman Code
         kdgrp LIKE knvv-kdgrp,        " Customer Group
         klime LIKE knka-klime,        " Credit Limit
         brsch LIKE kna1-brsch,
         channel LIKE zfchanel-channel,
         sortl LIKE kna1-sortl,
         zuonr LIKE bsid-zuonr,
         kunnr1 LIKE bsid-kunnr,
         zterm  LIKE bsid-zterm,
         duedt  LIKE bsid-zfbdt,
         cpudt  LIKE bsid-cpudt,
         kidno  LIKE bsid-kidno,
         bschl  LIKE bsid-bschl,
         kvgr3  TYPE kvgr3,
         umskz  LIKE bsid-umskz,
         anln1  LIKE bsid-anln1,
         sgtxt  LIKE bsid-sgtxt,
     END OF it_bsid.

DATA: BEGIN OF t_bsid_temp OCCURS 0.
        INCLUDE STRUCTURE it_bsid.
DATA: END OF t_bsid_temp.

DATA: BEGIN OF t_bsid_add OCCURS 0.
        INCLUDE STRUCTURE it_bsid.
DATA: END OF t_bsid_add.

DATA: BEGIN OF i_tvkol OCCURS 0,
         vstel LIKE tvkol-vstel,
         live LIKE zplbc-live,
         mixlive  LIKE zplbc-mixlive,
         werks LIKE tvkol-werks,
         lgort LIKE tvkol-lgort,
      END OF i_tvkol.

DATA: BEGIN OF t_salesman OCCURS 0.
        INCLUDE STRUCTURE knvp.
DATA: END OF t_salesman.
DATA: BEGIN OF t_routelist OCCURS 0.
        INCLUDE STRUCTURE knvp.
DATA: END OF t_routelist.

DATA: BEGIN OF it_gsber OCCURS 0,
      gsber LIKE bsid-gsber,
      END OF it_gsber.

DATA: BEGIN OF it_channel OCCURS 0,
      gsber LIKE bsid-gsber,
      channel LIKE zfchanel-channel,
      kdgrp LIKE knvv-kdgrp,
      brsch LIKE kna1-brsch,
      END OF it_channel.

DATA: BEGIN OF it_choose OCCURS 0,
      gsber LIKE bsid-gsber,
      kunnr LIKE bsid-kunnr,
      kdgrp LIKE knvv-kdgrp,
      xref2 LIKE bsid-xref2,
      xref1 LIKE bsid-xref1,
      brsch LIKE kna1-brsch,
      kvgr3 LIKE knvv-kvgr3,
      channel LIKE zfchanel-channel,
      anln1 LIKE bsid-anln1,
      END OF it_choose.

DATA: BEGIN OF t_hotspot OCCURS 0,
      kunnr LIKE bsid-kunnr,
      zuonr LIKE bsid-zuonr,
      budat LIKE bsid-budat,
      zfbdt LIKE bsid-zfbdt,
      zbd1t TYPE i,
      duedt LIKE bsid-zfbdt,
      begin LIKE bsid-dmbtr,
      sales LIKE bsid-dmbtr,
      payment LIKE bsid-dmbtr,
      ending LIKE bsid-dmbtr,
      giro  LIKE bsid-dmbtr,
      limit LIKE knkk-klimk,
      due1 LIKE bsid-dmbtr,
      due2 LIKE bsid-dmbtr,
      due3 LIKE bsid-dmbtr,
      due4 LIKE bsid-dmbtr,
      due5 LIKE bsid-dmbtr.
DATA: age  TYPE i.
DATA: umskz  LIKE bsid-umskz.
DATA: END OF t_hotspot.

DATA: BEGIN OF itab OCCURS 0,
      gsber LIKE bsid-gsber,
      kunnr TYPE char10,
      anln1 TYPE bsid-anln1,
      gjahr LIKE bsid-gjahr,
      begin LIKE bsid-dmbtr,
      sales LIKE bsid-dmbtr,
      payment LIKE bsid-dmbtr,
      ending LIKE bsid-dmbtr,
      giro  LIKE bsid-dmbtr,
      limit LIKE knkk-klimk,
      due1 LIKE bsid-dmbtr,
      due2 LIKE bsid-dmbtr,
      due3 LIKE bsid-dmbtr,
      due4 LIKE bsid-dmbtr,
      due5 LIKE bsid-dmbtr,
      sortl LIKE kna1-sortl,
      kunnr1 LIKE bsid-kunnr,
      END OF itab.
DATA: itab_1 LIKE itab OCCURS 0,
      itab_2 LIKE itab OCCURS 0,
      itab_3 LIKE itab OCCURS 0,
      itab_4 LIKE itab OCCURS 0,
      itab_5 LIKE itab OCCURS 0.

DATA: BEGIN OF itab1 OCCURS 0,
      gsber LIKE bsid-gsber,
      gjahr LIKE bsid-gjahr,
      begin LIKE bsid-dmbtr,
      sales LIKE bsid-dmbtr,
      payment LIKE bsid-dmbtr,
      ending LIKE bsid-dmbtr,
      giro  LIKE bsid-dmbtr,
      limit LIKE bsid-dmbtr,
      due1 LIKE bsid-dmbtr,
      due2 LIKE bsid-dmbtr,
      due3 LIKE bsid-dmbtr,
      due4 LIKE bsid-dmbtr,
      due5 LIKE bsid-dmbtr,
      END OF itab1.
DATA: itab1_1 LIKE itab1 OCCURS 0,
      itab1_2 LIKE itab1 OCCURS 0,
      itab1_3 LIKE itab1 OCCURS 0,
      itab1_4 LIKE itab1 OCCURS 0,
      itab1_5 LIKE itab1 OCCURS 0.

DATA: BEGIN OF itab2 OCCURS 0,
      gsber LIKE bsid-gsber,
      kdgrp LIKE knvv-kdgrp,
      gjahr LIKE bsid-gjahr,
      begin LIKE bsid-dmbtr,
      sales LIKE bsid-dmbtr,
      payment LIKE bsid-dmbtr,
      ending LIKE bsid-dmbtr,
      giro  LIKE bsid-dmbtr,
      limit LIKE bsid-dmbtr,
      due1 LIKE bsid-dmbtr,
      due2 LIKE bsid-dmbtr,
      due3 LIKE bsid-dmbtr,
      due4 LIKE bsid-dmbtr,
      due5 LIKE bsid-dmbtr,
      END OF itab2.
DATA: itab2_1 LIKE itab2 OCCURS 0,
      itab2_2 LIKE itab2 OCCURS 0,
      itab2_3 LIKE itab2 OCCURS 0,
      itab2_4 LIKE itab2 OCCURS 0,
      itab2_5 LIKE itab2 OCCURS 0.

DATA: BEGIN OF itab3 OCCURS 0,
      gsber LIKE bsid-gsber,
      xref2 LIKE bsid-xref2,
      gjahr LIKE bsid-gjahr,
      begin LIKE bsid-dmbtr,
      sales LIKE bsid-dmbtr,
      payment LIKE bsid-dmbtr,
      ending LIKE bsid-dmbtr,
      giro  LIKE bsid-dmbtr,
      limit LIKE bsid-dmbtr,
      due1 LIKE bsid-dmbtr,
      due2 LIKE bsid-dmbtr,
      due3 LIKE bsid-dmbtr,
      due4 LIKE bsid-dmbtr,
      due5 LIKE bsid-dmbtr,
      END OF itab3.
DATA: itab3_1 LIKE itab3 OCCURS 0,
      itab3_2 LIKE itab3 OCCURS 0,
      itab3_3 LIKE itab3 OCCURS 0,
      itab3_4 LIKE itab3 OCCURS 0,
      itab3_5 LIKE itab3 OCCURS 0.

DATA: BEGIN OF itab4 OCCURS 0,
      gsber LIKE bsid-gsber,
      xref1 LIKE bsid-xref1,
      gjahr LIKE bsid-gjahr,
      begin LIKE bsid-dmbtr,
      sales LIKE bsid-dmbtr,
      payment LIKE bsid-dmbtr,
      ending LIKE bsid-dmbtr,
      giro  LIKE bsid-dmbtr,
      limit LIKE bsid-dmbtr,
      due1 LIKE bsid-dmbtr,
      due2 LIKE bsid-dmbtr,
      due3 LIKE bsid-dmbtr,
      due4 LIKE bsid-dmbtr,
      due5 LIKE bsid-dmbtr,
      END OF itab4.
DATA: itab4_1 LIKE itab4 OCCURS 0,
      itab4_2 LIKE itab4 OCCURS 0,
      itab4_3 LIKE itab4 OCCURS 0,
      itab4_4 LIKE itab4 OCCURS 0,
      itab4_5 LIKE itab4 OCCURS 0.

DATA: BEGIN OF itab5 OCCURS 0,
      gsber LIKE bsid-gsber,
      brsch LIKE kna1-brsch,
      gjahr LIKE bsid-gjahr,
      begin LIKE bsid-dmbtr,
      sales LIKE bsid-dmbtr,
      payment LIKE bsid-dmbtr,
      ending LIKE bsid-dmbtr,
      giro  LIKE bsid-dmbtr,
      limit LIKE bsid-dmbtr,
      due1 LIKE bsid-dmbtr,
      due2 LIKE bsid-dmbtr,
      due3 LIKE bsid-dmbtr,
      due4 LIKE bsid-dmbtr,
      due5 LIKE bsid-dmbtr,
      END OF itab5.
DATA: itab5_1 LIKE itab5 OCCURS 0,
      itab5_2 LIKE itab5 OCCURS 0,
      itab5_3 LIKE itab5 OCCURS 0,
      itab5_4 LIKE itab5 OCCURS 0,
      itab5_5 LIKE itab5 OCCURS 0.

DATA: BEGIN OF itab6 OCCURS 0,
      gsber LIKE bsid-gsber,
      channel LIKE zfchanel-channel,
      kdgrp LIKE knvv-kdgrp,
      brsch LIKE kna1-brsch,
      gjahr LIKE bsid-gjahr,
      begin LIKE bsid-dmbtr,
      sales LIKE bsid-dmbtr,
      payment LIKE bsid-dmbtr,
      ending LIKE bsid-dmbtr,
      giro  LIKE bsid-dmbtr,
      limit LIKE bsid-dmbtr,
      due1 LIKE bsid-dmbtr,
      due2 LIKE bsid-dmbtr,
      due3 LIKE bsid-dmbtr,
      due4 LIKE bsid-dmbtr,
      due5 LIKE bsid-dmbtr,
      END OF itab6.
DATA: itab6_1 LIKE itab6 OCCURS 0,
      itab6_2 LIKE itab6 OCCURS 0,
      itab6_3 LIKE itab6 OCCURS 0,
      itab6_4 LIKE itab6 OCCURS 0,
      itab6_5 LIKE itab6 OCCURS 0.

DATA: BEGIN OF itab7 OCCURS 0,
      gsber LIKE bsid-gsber,
      kvgr3 LIKE knvv-kvgr3,
      gjahr LIKE bsid-gjahr,
      begin LIKE bsid-dmbtr,
      sales LIKE bsid-dmbtr,
      payment LIKE bsid-dmbtr,
      ending LIKE bsid-dmbtr,
      giro  LIKE bsid-dmbtr,
      limit LIKE bsid-dmbtr,
      due1 LIKE bsid-dmbtr,
      due2 LIKE bsid-dmbtr,
      due3 LIKE bsid-dmbtr,
      due4 LIKE bsid-dmbtr,
      due5 LIKE bsid-dmbtr,
      END OF itab7.
DATA: itab7_1 LIKE itab7 OCCURS 0,
      itab7_2 LIKE itab7 OCCURS 0,
      itab7_3 LIKE itab7 OCCURS 0,
      itab7_4 LIKE itab7 OCCURS 0,
      itab7_5 LIKE itab7 OCCURS 0.

DATA: BEGIN OF itab9 OCCURS 0,
      gsber LIKE bsid-gsber,
      kunnr TYPE char10,
      anln1 TYPE bsid-anln1,
      gjahr LIKE bsid-gjahr,
      begin LIKE bsid-dmbtr,
      sales LIKE bsid-dmbtr,
      payment LIKE bsid-dmbtr,
      ending LIKE bsid-dmbtr,
      giro  LIKE bsid-dmbtr,
      limit LIKE knkk-klimk,
      due1 LIKE bsid-dmbtr,
      due2 LIKE bsid-dmbtr,
      due3 LIKE bsid-dmbtr,
      due4 LIKE bsid-dmbtr,
      due5 LIKE bsid-dmbtr,
      sortl LIKE kna1-sortl,
      kunnr1 LIKE bsid-kunnr,
      END OF itab9.
DATA: itab9_1 LIKE itab9 OCCURS 0,
      itab9_2 LIKE itab9 OCCURS 0,
      itab9_3 LIKE itab9 OCCURS 0,
      itab9_4 LIKE itab9 OCCURS 0,
      itab9_5 LIKE itab9 OCCURS 0.

DATA: BEGIN OF i_giro OCCURS 0.
        INCLUDE STRUCTURE zfbicheck.
DATA: kdgrp LIKE knvv-kdgrp,
      brsch LIKE kna1-brsch,
      xref1 LIKE bsid-xref1,
      xref2 LIKE bsid-xref2,
      channel LIKE zfchanel-channel,
      kvgr3 LIKE knvv-kvgr3,
      anln1 LIKE bsid-anln1,
      flag(1),
      END OF i_giro.

DATA: BEGIN OF i_giro_sfa OCCURS 0.
        INCLUDE STRUCTURE zfbic_sfa.
DATA: kdgrp LIKE knvv-kdgrp,
      brsch LIKE kna1-brsch,
      xref1 LIKE bsid-xref1,
      xref2 LIKE bsid-xref2,
      channel LIKE zfchanel-channel,
      kvgr3 LIKE knvv-kvgr3,
      anln1 LIKE bsid-anln1,
*      flag(1),
      END OF i_giro_sfa.

DATA: BEGIN OF t_knvp OCCURS 0,
        kunnr  LIKE knvp-kunnr,
        kunn2  LIKE knvp-kunn2.
DATA: END OF t_knvp.

DATA : w1    TYPE i,  w2    TYPE i,  w3    TYPE i,  w4    TYPE i,
       w5    TYPE i,  w6    TYPE i,  w7    TYPE i,  w8    TYPE i,
       w9    TYPE i,  w10   TYPE i,  w11   TYPE i,  w12   TYPE i,
       w13   TYPE i,  w14   TYPE i,  w15   TYPE i,  w16   TYPE i,
       c1    TYPE i,  no    TYPE i,n_lines TYPE i.

DATA: plant LIKE bsid-gsber,
      v_begin LIKE bsid-dmbtr,
      v_sales LIKE bsid-dmbtr,
      v_payment LIKE bsid-dmbtr,
      v_ending LIKE bsid-dmbtr,
      v_giro  LIKE bsid-dmbtr,
      v_limit LIKE knkk-klimk,
      v_due1 LIKE bsid-dmbtr,
      v_due2 LIKE bsid-dmbtr,
      v_due3 LIKE bsid-dmbtr,
      v_due4 LIKE bsid-dmbtr,
      cab LIKE tgsbt-gtext,count TYPE i,header TYPE i,
      bulan(30),txt(20),v_line TYPE i,
      v_due5 LIKE bsid-dmbtr,page TYPE i,
      i_zfchanel LIKE zfchanel OCCURS 0 WITH HEADER LINE,
      it_choosekey LIKE it_choose OCCURS 0 WITH HEADER LINE,
      it_choosecust LIKE itab OCCURS 0 WITH HEADER LINE.

DATA: gtext(60)    TYPE c,
      igui         TYPE i,
      va_flag(1),
      wa_it_bsid  LIKE it_bsid,
      l_gerdat1(8),
      l_gerdat2(8),
      l_monat1(2) TYPE n,
      l_monat2(2) TYPE n,
      char4(4),
      char6(6),
      sw_choose(1).

DATA: va_total LIKE bsid-dmbtr.

DATA: BEGIN OF t_zfarsoff_dele OCCURS 0.
        INCLUDE STRUCTURE zfarsoff.
DATA: END OF t_zfarsoff_dele.
DATA: BEGIN OF t_zfarsoff_add OCCURS 0.
        INCLUDE STRUCTURE zfarsoff.
DATA: END OF t_zfarsoff_add.

DATA: gr_bschl  TYPE RANGE OF bschl.

SELECTION-SCREEN: BEGIN OF BLOCK block1 WITH FRAME TITLE text-002.
PARAMETERS    : p_bukrs LIKE bkpf-bukrs OBLIGATORY.
SELECT-OPTIONS:
                s_gsber FOR tvbur-vkbur.
SELECT-OPTIONS: p_kdgrp FOR knvv-kdgrp,
                p_kvgr3 FOR knvv-kvgr3 MODIF ID pk3,
                p_brsch FOR kna1-brsch,
                p_route FOR kna1-kunnr,
                p_slcode FOR char6.
SELECT-OPTIONS:
                s_kunnr FOR bsid-kunnr,
                s_do    FOR bsid-zuonr,
                s_blart FOR bsid-blart NO-DISPLAY.
*PARAMETERS    : p_hist AS CHECKBOX USER-COMMAND grp3.
PARAMETERS    : p_gerdat LIKE bsid-budat OBLIGATORY DEFAULT sy-datum MODIF ID gdt.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN: BEGIN OF BLOCK block2 WITH FRAME TITLE text-003.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN:  POSITION 34.
PARAMETERS: int1 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN:  POSITION 38.
PARAMETERS: int2 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN:  POSITION 42.
PARAMETERS: int3 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN:  POSITION 46.
PARAMETERS: int4 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN:  POSITION 50.
PARAMETERS: int5 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : top RADIOBUTTON GROUP grp1 DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(10) text-004 FOR FIELD top.

SELECTION-SCREEN:  POSITION 33.
PARAMETERS:int1low(3)  DEFAULT 30 MODIF ID aab,
           int2low(3)  DEFAULT 60 MODIF ID aab,
           int3low(3)  DEFAULT 90 MODIF ID aab,
           int4low(3)  DEFAULT 120 MODIF ID aab,
           int5low(3)  DEFAULT ' > ' MODIF ID aac.

SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : aging RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(10) text-005 FOR FIELD aging.
SELECTION-SCREEN END OF LINE.

PARAMETERS: x_norm LIKE itemset-xnorm AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS  x_shbv LIKE itemset-xshbv AS CHECKBOX.
SELECTION-SCREEN : COMMENT 4(24) text-014 FOR FIELD x_shbv.
SELECTION-SCREEN:  POSITION 30.
SELECT-OPTIONS: s_bschl FOR bsid-umskz NO INTERVALS.
SELECTION-SCREEN END OF LINE.

PARAMETERS x_opdr AS CHECKBOX.

SELECTION-SCREEN END OF BLOCK block2.
SELECTION-SCREEN: BEGIN OF BLOCK block3 WITH FRAME TITLE text-006.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio1 RADIOBUTTON GROUP grp2 DEFAULT 'X' USER-COMMAND usr.
SELECTION-SCREEN : COMMENT 5(50) text-007 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio2 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(50) text-008 FOR FIELD radio2.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio3 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(50) text-009 FOR FIELD radio3.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio4 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(50) text-010 FOR FIELD radio4.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio5 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(50) text-011 FOR FIELD radio5.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio6 RADIOBUTTON GROUP grp2 MODIF ID ptt.
SELECTION-SCREEN : COMMENT 5(50) text-013 FOR FIELD radio6.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio7 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(50) text-015 FOR FIELD radio7.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio9 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(50) text-017 FOR FIELD radio9.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio8 RADIOBUTTON GROUP grp2 MODIF ID sut.
SELECTION-SCREEN : COMMENT 5(50) text-016 FOR FIELD radio8.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK block3.

AT SELECTION-SCREEN OUTPUT.
  IF p_bukrs EQ '8070'.
    LOOP AT SCREEN.
      IF screen-group1 = 'PTT'.
        screen-active  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'SUT'.
        screen-active  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  LOOP AT SCREEN.
    IF screen-group1 = 'AAC'.
      screen-input  = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  CASE 'X'.
    WHEN radio9.
      p_kvgr3-low = '05T'.
      p_kvgr3-sign = 'I'.
      p_kvgr3-option = 'EQ'.
      APPEND p_kvgr3.

      LOOP AT SCREEN.
        IF screen-group1 = 'PK3'.
          screen-input  = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN OTHERS.
      CLEAR p_kvgr3[].
  ENDCASE.
*  LOOP AT SCREEN.
*    IF p_hist IS INITIAL.
*      IF screen-group1 = 'GDT'.
*        screen-input = '0'.
*        MODIFY SCREEN.
*      ENDIF.
*    ELSE.
*      IF screen-group1 = 'GDT'.
*        screen-input = '1'.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.

AT SELECTION-SCREEN ON s_bschl.
  IF x_shbv = 'X' AND s_bschl IS INITIAL.
    s_bschl-low = 'T'.
    s_bschl-sign = 'I'.
    s_bschl-option = 'EQ'.
    APPEND s_bschl.

    s_bschl-low = 'V'.
    s_bschl-sign = 'I'.
    s_bschl-option = 'EQ'.
    APPEND s_bschl.

    s_bschl-low = 'U'.
    s_bschl-sign = 'I'.
    s_bschl-option = 'EQ'.
    APPEND s_bschl.
  ENDIF.

AT SELECTION-SCREEN ON p_bukrs.
  SELECT SINGLE * FROM t001 WHERE bukrs EQ p_bukrs.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Company Not Found'.
  ENDIF.

AT SELECTION-SCREEN ON s_gsber.
  SELECT SINGLE * FROM tvbur
         WHERE vkbur IN s_gsber.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Business area Not Found'.
  ENDIF.

INITIALIZATION.
  s_blart-low = 'RV'.
  s_blart-sign = 'I'.
  s_blart-option = 'EQ'.
  APPEND s_blart.
  s_blart-low = 'DR'.
  s_blart-sign = 'I'.
  s_blart-option = 'EQ'.
  APPEND s_blart.
  s_blart-low = 'ZA'.
  s_blart-sign = 'I'.
  s_blart-option = 'EQ'.
  APPEND s_blart.
  s_blart-low = 'DA'.
  s_blart-sign = 'I'.
  s_blart-option = 'EQ'.
  APPEND s_blart.
  s_blart-low = 'DZ'.
  s_blart-sign = 'I'.
  s_blart-option = 'EQ'.
  APPEND s_blart.
  s_blart-low = 'AB'.
  s_blart-sign = 'I'.
  s_blart-option = 'EQ'.
  APPEND s_blart.

  DATA lv_parva(40).

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'BUK'.

  IF sy-subrc EQ 0.
    p_bukrs  = lv_parva.
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

  IF sy-tcode IS INITIAL.
    sy-tcode = 'ZF26N'.
  ENDIF.

  IF p_bukrs EQ '8070'.
    SET PF-STATUS '101'.
  ELSE.
    SET PF-STATUS '100'.
  ENDIF.

  PERFORM cek.
  PERFORM f_mapping_soff.
  PERFORM get_data.
  PERFORM f_hapus_kunnr.
  PERFORM f_tambah_kunnr.

  PERFORM f_reclas.

  DESCRIBE TABLE it_bsid LINES n_lines.
  IF n_lines LE 0.
    MESSAGE s000(26) WITH 'No items selected'.
    EXIT.
  ENDIF.

  PERFORM process_data.
  PERFORM process_sum.
  PERFORM f_modify_it_bsid.
  PERFORM init_print.

  IF radio1 EQ 'X'.
    PERFORM sum_gsber.
    IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
       int4 NE 'X' OR int5 NE 'X'.
      PERFORM itab1.
    ENDIF.
    PERFORM write_gsber.
  ENDIF.

  IF radio2 EQ 'X'.
    PERFORM sum_brcust.
    IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
       int4 NE 'X' OR int5 NE 'X'.
      PERFORM itab.
    ENDIF.
    PERFORM write_brcust.
  ENDIF.

  IF radio3 EQ 'X'.
    PERFORM sum_brcustgr.
    IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
       int4 NE 'X' OR int5 NE 'X'.
      PERFORM itab2.
    ENDIF.
    PERFORM write_brcustgr.
  ENDIF.

  IF radio4 EQ 'X'.
    PERFORM sum_brsales.
    IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
       int4 NE 'X' OR int5 NE 'X'.
      PERFORM itab3.
    ENDIF.
    PERFORM write_brsales.
  ENDIF.

  IF radio5 EQ 'X'.
    PERFORM sum_brroute.
    IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
       int4 NE 'X' OR int5 NE 'X'.
      PERFORM itab4.
    ENDIF.
    PERFORM write_brroute.
  ENDIF.

  IF radio6 EQ 'X'.
    PERFORM sum_industry.
    IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
       int4 NE 'X' OR int5 NE 'X'.
      PERFORM itab5.
    ENDIF.
    PERFORM write_industry.
  ENDIF.

  IF radio7 EQ 'X'.
    PERFORM sum_channel.
    IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
       int4 NE 'X' OR int5 NE 'X'.
      PERFORM itab6.
    ENDIF.
    PERFORM write_channel.
  ENDIF.

  IF radio8 EQ 'X'.
    PERFORM sum_brsubcustgr.
    IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
       int4 NE 'X' OR int5 NE 'X'.
      PERFORM itab7.
    ENDIF.
    PERFORM write_brsubcustgr.
  ENDIF.

  IF radio9 EQ 'X'.
    PERFORM sum_05t.
    IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
       int4 NE 'X' OR int5 NE 'X'.
      PERFORM itab9.
    ENDIF.
    PERFORM write_05t.
  ENDIF.

AT USER-COMMAND.
  sy-lsind = 0.
  CASE sy-ucomm.
    WHEN 'BRANCH'.
      CLEAR sw_choose.
      radio1 = 'X'.radio2 = space.radio3 = space.
      radio4 = space.radio5 = space.radio6 = space.
      radio7 = space.radio8 = space.radio9 = space.
      DESCRIBE TABLE itab1 LINES v_line.
      IF v_line LE 0.
        PERFORM sum_gsber.
      ENDIF.
      IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
         int4 NE 'X' OR int5 NE 'X'.
        PERFORM itab1.
      ENDIF.
      PERFORM write_gsber.
    WHEN 'CUSTOMER'.
      CLEAR sw_choose.
      radio1 = space.radio2 = 'X'.radio3 = space.
      radio4 = space.radio5 = space.radio6 = space.radio7 = space.
      radio8 = space.radio9 = space.
      DESCRIBE TABLE itab LINES v_line.
      IF v_line LE 0.
        PERFORM sum_brcust.
      ENDIF.
      IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
         int4 NE 'X' OR int5 NE 'X'.
        PERFORM itab.
      ENDIF.
      PERFORM write_brcust.
    WHEN 'CUSTGROUP'.
      CLEAR sw_choose.
      radio1 = space.radio2 = space.radio3 = 'X'.
      radio4 = space.radio5 = space.radio6 = space.
      radio7 = space.radio9 = space.
      DESCRIBE TABLE itab2 LINES v_line.
      IF v_line LE 0.
        PERFORM sum_brcustgr.
      ENDIF.
      IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
         int4 NE 'X' OR int5 NE 'X'.
        PERFORM itab2.
      ENDIF.
      PERFORM write_brcustgr.
    WHEN 'SALESMAN'.
      CLEAR sw_choose.
      radio1 = space.radio2 = space.radio3 = space.
      radio4 = 'X'.radio5 = space.radio6 = space.
      radio7 = space.radio8 = space.radio9 = space.
      DESCRIBE TABLE itab3 LINES v_line.
      IF v_line LE 0.
        PERFORM sum_brsales.
      ENDIF.
      IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
         int4 NE 'X' OR int5 NE 'X'.
        PERFORM itab3.
      ENDIF.
      PERFORM write_brsales.
    WHEN 'ROUTELIST'.
      CLEAR sw_choose.
      radio1 = space.radio2 = space.radio3 = space.
      radio4 = space.radio5 = 'X'.radio6 = space.
      radio7 = space.radio8 = space.radio9 = space.
      DESCRIBE TABLE itab4 LINES v_line.
      IF v_line LE 0.
        PERFORM sum_brroute.
      ENDIF.
      IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
         int4 NE 'X' OR int5 NE 'X'.
        PERFORM itab4.
      ENDIF.
      PERFORM write_brroute.
    WHEN 'INDUSTRY'.
      CLEAR sw_choose.
      radio1 = space.radio3 = space.radio2 = space.
      radio4 = space.radio5 = space.radio6 = 'X'.
      radio7 = space.radio8 = space.radio9 = space.
      DESCRIBE TABLE itab5 LINES v_line.
      IF v_line LE 0.
        PERFORM sum_industry.
      ENDIF.
      IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
         int4 NE 'X' OR int5 NE 'X'.
        PERFORM itab5.
      ENDIF.
      PERFORM write_industry.
    WHEN 'CHANNEL'.
      CLEAR sw_choose.
      radio1 = space.radio3 = space.radio2 = space.
      radio4 = space.radio5 = space.radio6 = space.
      radio7 = 'X'.radio8 = space.radio9 = space.
      DESCRIBE TABLE itab6 LINES v_line.
      IF v_line LE 0.
        PERFORM sum_channel.
      ENDIF.
      IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
         int4 NE 'X' OR int5 NE 'X'.
        PERFORM itab6.
      ENDIF.
      PERFORM write_channel.
    WHEN 'SUBCUSTGRP'.
      CLEAR sw_choose.
      radio1 = space.radio2 = space.radio3 = space.
      radio4 = space.radio5 = space.radio6 = space.
      radio7 = space.radio9 = space.
      radio8 = 'X'.
      DESCRIBE TABLE itab7 LINES v_line.
      IF v_line LE 0.
        PERFORM sum_brsubcustgr.
      ENDIF.
      IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
         int4 NE 'X' OR int5 NE 'X'.
        PERFORM itab7.
      ENDIF.
      PERFORM write_brsubcustgr.
    WHEN '05T'.
      CLEAR sw_choose.
      radio1 = space.radio2 = space.radio3 = space.
      radio4 = space.radio5 = space.radio6 = space.
      radio7 = space.radio9 = 'X'.
      DESCRIBE TABLE itab9 LINES v_line.
      IF v_line LE 0.
        PERFORM sum_05t.
      ENDIF.
      IF int1 NE 'X' OR int2 NE 'X' OR int3 NE 'X' OR
         int4 NE 'X' OR int5 NE 'X'.
        PERFORM itab9.
      ENDIF.
      PERFORM write_05t.
    WHEN 'CHOOSE'.
      sw_choose = '1'.
      PERFORM f_choose.
    WHEN 'CANCL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE  PROGRAM.
    WHEN 'BACK1'.
      IF sw_choose IS INITIAL.
        LEAVE TO SCREEN 0.
      ELSE.
        CLEAR sw_choose.
        CASE 'X'.
          WHEN radio1.
            PERFORM write_gsber.      "Branch
          WHEN radio2.
            IF itab[] IS INITIAL.
              PERFORM sum_brcust.
            ENDIF.
            PERFORM write_brcust.     "Customer
          WHEN radio3.
            PERFORM write_brcustgr.   "Customer Group
          WHEN radio4.
            PERFORM write_brsales.    "Salesman
          WHEN radio5.
            PERFORM write_brroute.    "Route list
          WHEN radio6.
            PERFORM write_industry.   "Industry
          WHEN radio8.
            PERFORM write_brsubcustgr.   "Sub Customer Group
          WHEN radio9.
            PERFORM write_05t.   "Sub Customer Group
        ENDCASE.
      ENDIF.
  ENDCASE.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data.
  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  DATA : ls_bschl  LIKE LINE OF gr_bschl,
         lv_bschl  TYPE bschl,
         lv_gerdat TYPE sy-datum.

  LOOP AT s_bschl INTO ls_bschl.
    IF ls_bschl-low  = 'V'.
      lv_bschl  = 'V'.
    ELSE.
      APPEND ls_bschl TO gr_bschl.
      CLEAR ls_bschl.
    ENDIF.
  ENDLOOP.

  l_monat1 = p_gerdat+4(2).
  l_monat2 = p_gerdat+4(2) + 1.

  CONCATENATE p_gerdat(4) l_monat1 '01' INTO l_gerdat1.
  CONCATENATE p_gerdat(4) l_monat2 '01' INTO l_gerdat2.

  CONCATENATE p_gerdat(6) '01' INTO lv_gerdat.
  lv_gerdat = lv_gerdat - 1.
  CONCATENATE lv_gerdat(6) '01' INTO lv_gerdat.

  PERFORM f_get_customer USING ''.

  IF gt_kna1[] IS NOT INITIAL.
    IF x_norm EQ 'X' AND x_shbv EQ 'X'.
      IF x_opdr IS INITIAL.
        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr shkzg zfbdt zbd1t
               blart xref2 zuonr xref1 zterm cpudt kidno bschl umskz anln1
          INTO CORRESPONDING FIELDS OF TABLE it_bsid
          FROM bsid
          FOR ALL ENTRIES IN gt_kna1
          WHERE kunnr = gt_kna1-kunnr
            AND bukrs = p_bukrs
            AND budat LE p_gerdat
            AND umskz = space
            AND blart IN s_blart
            AND zuonr IN s_do.
      ELSE.
        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr a~shkzg zfbdt zbd1t
               blart xref2 zuonr xref1 zterm cpudt kidno bschl umskz a~anln1
               b~vkbur
          INTO CORRESPONDING FIELDS OF TABLE it_bsid
          FROM bsid AS a JOIN vbrp AS b ON b~vbeln = a~vbeln AND
                                           b~posnr = '000010'
          WHERE b~vkbur IN s_gsber
            AND bukrs = p_bukrs
            AND budat LE p_gerdat
            AND umskz = space
            AND blart IN s_blart
            AND zuonr IN s_do.
      ENDIF.

      PERFORM f_get_from_bsad USING lv_gerdat ''.

      IF gr_bschl[] IS NOT INITIAL.
        IF x_opdr IS INITIAL.
          SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr shkzg zfbdt zbd1t
                 blart xref2 zuonr xref1 zterm cpudt kidno bschl umskz anln1
            APPENDING CORRESPONDING FIELDS OF TABLE it_bsid
            FROM bsid
            FOR ALL ENTRIES IN gt_kna1
            WHERE kunnr = gt_kna1-kunnr
              AND bukrs = p_bukrs
              AND budat LE p_gerdat
              AND umskz IN gr_bschl
              AND blart IN s_blart
              AND zuonr IN s_do.
        ELSE.
          SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr a~shkzg zfbdt zbd1t
                 blart xref2 zuonr xref1 zterm cpudt kidno bschl umskz a~anln1
                 b~vkbur
            APPENDING CORRESPONDING FIELDS OF TABLE it_bsid
            FROM bsid AS a JOIN vbrp AS b ON b~vbeln = a~vbeln AND
                                             b~posnr = '000010'
            WHERE vkbur IN s_gsber
              AND bukrs = p_bukrs
              AND budat LE p_gerdat
              AND umskz IN gr_bschl
              AND blart IN s_blart
              AND zuonr IN s_do.
        ENDIF.

        PERFORM f_get_from_bsad USING lv_gerdat '0'.
      ENDIF.

      IF lv_bschl IS NOT INITIAL.
        IF x_opdr IS INITIAL.
          SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr shkzg zfbdt zbd1t
                 blart xref2 zuonr xref1 zterm cpudt kidno bschl umskz anln1
                 sgtxt
            APPENDING CORRESPONDING FIELDS OF TABLE it_bsid
            FROM bsid
            FOR ALL ENTRIES IN gt_kna1
            WHERE kunnr = gt_kna1-kunnr
              AND bukrs = p_bukrs
              AND budat LE p_gerdat
              AND umskz = lv_bschl
              AND blart IN s_blart
              AND zuonr IN s_do.
        ELSE.
          SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr a~shkzg zfbdt zbd1t
                 blart xref2 zuonr xref1 zterm cpudt kidno bschl umskz a~anln1
                 a~sgtxt b~vkbur
            APPENDING CORRESPONDING FIELDS OF TABLE it_bsid
            FROM bsid AS a JOIN vbrp AS b ON b~vbeln = a~vbeln AND
                                             b~posnr = '000010'
            WHERE vkbur IN s_gsber
              AND bukrs = p_bukrs
              AND budat LE p_gerdat
              AND umskz = lv_bschl
              AND blart IN s_blart
              AND zuonr IN s_do.
        ENDIF.

        PERFORM f_get_from_bsad USING lv_gerdat lv_bschl.
      ENDIF.
    ENDIF.

    IF x_norm EQ 'X' AND x_shbv EQ space.
      IF x_opdr IS INITIAL.
        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr shkzg zfbdt zbd1t
               blart xref2 zuonr xref1 zterm cpudt kidno bschl umskz anln1
          INTO CORRESPONDING FIELDS OF TABLE it_bsid
          FROM bsid
          FOR ALL ENTRIES IN gt_kna1
          WHERE kunnr = gt_kna1-kunnr
            AND bukrs = p_bukrs
            AND budat LE p_gerdat
            AND umskz = space
            AND blart IN s_blart
            AND zuonr IN s_do.
      ELSE.
        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr a~shkzg zfbdt zbd1t
               blart xref2 zuonr xref1 zterm cpudt kidno bschl umskz a~anln1
               b~vkbur
          INTO CORRESPONDING FIELDS OF TABLE it_bsid
          FROM bsid AS a JOIN vbrp AS b ON b~vbeln = a~vbeln AND
                                           b~posnr = '000010'
          WHERE vkbur IN s_gsber
            AND bukrs = p_bukrs
            AND budat LE p_gerdat
            AND umskz = space
            AND blart IN s_blart
            AND zuonr IN s_do.
      ENDIF.

      PERFORM f_get_from_bsad USING lv_gerdat ''.
    ENDIF.

    IF x_norm EQ space AND x_shbv EQ 'X'.
      IF gr_bschl[] IS NOT INITIAL.
        IF x_opdr IS INITIAL.
          SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr shkzg zfbdt zbd1t
                 blart xref2 zuonr xref1 zterm cpudt kidno bschl umskz anln1
            INTO CORRESPONDING FIELDS OF TABLE it_bsid
            FROM bsid
            FOR ALL ENTRIES IN gt_kna1
            WHERE kunnr = gt_kna1-kunnr
              AND bukrs = p_bukrs
              AND budat LE p_gerdat
              AND umskz IN gr_bschl
              AND blart IN s_blart
              AND zuonr IN s_do.
        ELSE.
          SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr a~shkzg zfbdt zbd1t
                 blart xref2 zuonr xref1 zterm cpudt kidno bschl umskz a~anln1
                 b~vkbur
            INTO CORRESPONDING FIELDS OF TABLE it_bsid
            FROM bsid AS a JOIN vbrp AS b ON b~vbeln = a~vbeln AND
                                             b~posnr = '000010'
            WHERE vkbur IN s_gsber
              AND bukrs = p_bukrs
              AND budat LE p_gerdat
              AND umskz IN gr_bschl
              AND blart IN s_blart
              AND zuonr IN s_do.
        ENDIF.

        PERFORM f_get_from_bsad USING lv_gerdat '0'.
      ENDIF.

      IF lv_bschl IS NOT INITIAL.
        IF x_opdr IS INITIAL.
          SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr shkzg zfbdt zbd1t
                 blart xref2 zuonr xref1 zterm cpudt kidno bschl umskz anln1
                 sgtxt
            INTO CORRESPONDING FIELDS OF TABLE it_bsid
            FROM bsid
            FOR ALL ENTRIES IN gt_kna1
            WHERE kunnr = gt_kna1-kunnr
              AND bukrs = p_bukrs
              AND budat LE p_gerdat
              AND umskz = lv_bschl
              AND blart IN s_blart
              AND zuonr IN s_do.
        ELSE.
          SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr a~shkzg zfbdt zbd1t
                 blart xref2 zuonr xref1 zterm cpudt kidno bschl umskz a~anln1
                 a~sgtxt
                 b~vkbur
            INTO CORRESPONDING FIELDS OF TABLE it_bsid
            FROM bsid AS a JOIN vbrp AS b ON b~vbeln = a~vbeln AND
                                             b~posnr = '000010'
            WHERE vkbur IN s_gsber
              AND bukrs = p_bukrs
              AND budat LE p_gerdat
              AND umskz = lv_bschl
              AND blart IN s_blart
              AND zuonr IN s_do.
        ENDIF.

        PERFORM f_get_from_bsad USING lv_gerdat lv_bschl.
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM f_join_bsid_kna1.

ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data.
  DATA : l_kunnr LIKE vbpa-kunnr,
         l_str TYPE i,
         l_count TYPE i,
         l_tmp(6) TYPE n,
         l_tmp1(10) TYPE n,
         l_selisih(3)  TYPE n,
         l_mahdt LIKE vbak-mahdt,
         l_audat LIKE vbak-audat,
         l_pernr LIKE vbpa-pernr,
         lw_bsid LIKE it_bsid,
         ld_ztag1 LIKE t052-ztag1,
         ld_char(12) VALUE '0000000000',
         ld_char1(50),
         ld_subrc LIKE sy-subrc,
         ld_len   TYPE i.

  DATA : lt_itab  LIKE it_bsid OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_t052 OCCURS 0,
           zterm  TYPE dzterm,
           ztag1  TYPE dztage,
         END OF lt_t052.

  SORT it_bsid BY zuonr.
  SORT t_bsid_temp BY zuonr cpudt DESCENDING belnr DESCENDING.

  lt_itab[] = it_bsid[].
  SORT lt_itab BY zterm.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING zterm.
  IF lt_itab[] IS NOT INITIAL.
    SELECT zterm ztag1
      FROM t052
      INTO TABLE lt_t052
      FOR ALL ENTRIES IN lt_itab
      WHERE zterm EQ lt_itab-zterm.
  ENDIF.

  LOOP AT it_bsid.
    READ TABLE i_tvkol WITH KEY vstel = it_bsid-vkbur.
    IF sy-subrc EQ 0.
      IF i_tvkol-mixlive IS INITIAL.
        IF i_tvkol-live EQ 'X'.
          PERFORM f_read_temp USING 'RV'
                              CHANGING ld_subrc.
        ELSE.
          PERFORM f_read_temp USING 'ZA'
                              CHANGING ld_subrc.
        ENDIF.
      ELSE.
        PERFORM f_read_temp USING 'ZA'
                            CHANGING ld_subrc.
        IF ld_subrc NE 0.
          PERFORM f_read_temp USING 'RV'
                              CHANGING ld_subrc.
        ENDIF.
      ENDIF.
      IF ld_subrc NE 0.
        READ TABLE t_bsid_temp WITH KEY zuonr = it_bsid-zuonr.
        IF sy-subrc EQ 0.
          it_bsid-bschl    = t_bsid_temp-bschl.
          it_bsid-zbd1t    = t_bsid_temp-zbd1t.
          it_bsid-zfbdt    = t_bsid_temp-zfbdt.
          it_bsid-zterm    = t_bsid_temp-zterm.
          it_bsid-duedt    = t_bsid_temp-duedt.
        ENDIF.
      ENDIF.
    ENDIF.

    CLEAR: ld_ztag1.
    IF it_bsid-bschl EQ '01'.
      CLEAR lt_t052.
      READ TABLE lt_t052 WITH KEY zterm = it_bsid-zterm.
      IF sy-subrc EQ 0.
        ld_ztag1 = lt_t052-ztag1.
      ENDIF.

*      IF it_bsid-zuonr(1) = 'C'.
*        it_bsid-duedt  = it_bsid-budat + ld_ztag1.
*      ELSE.
      it_bsid-duedt  = it_bsid-zfbdt + ld_ztag1.
*      ENDIF.
    ELSE.
      it_bsid-duedt  = it_bsid-zfbdt.
    ENDIF.

    "Kondisi untuk AR potongan
    IF it_bsid-umskz = 'V'.
      it_bsid-duedt  = it_bsid-budat.
      it_bsid-zfbdt  = it_bsid-budat.
    ENDIF.

    READ TABLE t_routelist WITH KEY kunnr = it_bsid-kunnr
                                    parvw = 'ZC'.
    IF sy-subrc EQ 0.
      CONCATENATE ld_char t_routelist-kunn2 INTO ld_char1.
      ld_len = STRLEN( ld_char1 ).
      ld_len = ld_len - 10.
      it_bsid-xref1  = ld_char1+ld_len(10).
      READ TABLE t_salesman WITH KEY kunnr = t_routelist-kunn2
                                     parvw = 'ZP'.
      IF sy-subrc EQ 0.
        CONCATENATE ld_char t_salesman-pernr INTO ld_char1.
        ld_len = STRLEN( ld_char1 ).
        ld_len = ld_len - 6.
        it_bsid-xref2  = ld_char1+ld_len(6).
      ELSE.
        CLEAR: it_bsid-xref2.
      ENDIF.
    ELSE.
      CLEAR: it_bsid-xref1, it_bsid-xref2.
    ENDIF.

    CLEAR i_zfchanel.
    IF va_flag IS INITIAL.
      READ TABLE i_zfchanel WITH KEY bukrs = it_bsid-bukrs
                                     vkbur = it_bsid-vkbur
                                     kdgrp = it_bsid-kdgrp.
      it_bsid-channel = i_zfchanel-channel.
    ELSE.
      READ TABLE i_zfchanel WITH KEY bukrs = it_bsid-bukrs
                                     vkbur = it_bsid-vkbur
                                     brsch = it_bsid-brsch.
      it_bsid-channel = i_zfchanel-channel.
    ENDIF.

    MODIFY it_bsid.

    IF p_bukrs EQ '8020'.
      IF it_bsid-vkbur EQ space.
        it_bsid-vkbur = '0200'.
        MODIFY it_bsid.
      ENDIF.
    ENDIF.

    IF NOT p_route IS INITIAL.
      IF NOT it_bsid-xref1 IN p_route.
        DELETE it_bsid.
        CONTINUE.
      ELSE.
        IF NOT p_slcode IS INITIAL.
          IF NOT it_bsid-xref2 IN p_slcode.
            DELETE it_bsid.
            CONTINUE.
          ELSE.
            PERFORM gui_progress.
            PERFORM append.
          ENDIF.
        ELSE.
          PERFORM gui_progress.
          PERFORM append.
        ENDIF.
      ENDIF.
    ENDIF.

    IF NOT p_slcode IS INITIAL.
      IF NOT it_bsid-xref2 IN p_slcode.
        DELETE it_bsid.
        CONTINUE.
      ELSE.
        PERFORM gui_progress.
        PERFORM append.
      ENDIF.
    ENDIF.

    IF p_route IS INITIAL AND p_slcode IS INITIAL.
      PERFORM append.
      PERFORM gui_progress.
    ENDIF.
  ENDLOOP.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text = text-012.

  PERFORM delete_adj.
  DESCRIBE TABLE it_gsber LINES count.
ENDFORM.                    " PROCESS_DATA
*&---------------------------------------------------------------------*
*&      Form  APPEND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append.
  DATA l_live LIKE zplbc-live.

  MOVE it_bsid-vkbur TO it_gsber-gsber.
  APPEND it_gsber.

*  MOVE it_bsid-kunnr TO it_brcust-kunnr.
*  MOVE it_bsid-vkbur TO it_brcust-gsber.
*  APPEND it_brcust.
*
*  MOVE it_bsid-vkbur TO it_brcustgr-gsber.
*  MOVE it_bsid-kdgrp TO it_brcustgr-kdgrp.
*  APPEND it_brcustgr.
*
*  MOVE it_bsid-vkbur TO it_brsales-gsber.
*  MOVE it_bsid-xref2 TO it_brsales-xref2.
*  APPEND it_brsales.
*
*  MOVE it_bsid-vkbur TO it_brroute-gsber.
*  MOVE it_bsid-xref1 TO it_brroute-xref1.
*  APPEND it_brroute.
*
*  MOVE it_bsid-vkbur TO it_brroute1-gsber.
*  MOVE it_bsid-xref1 TO it_brroute1-xref1.
*  MOVE it_bsid-kunnr TO it_brroute1-kunnr.
*  APPEND it_brroute1.
*
*  MOVE it_bsid-vkbur TO it_industry-gsber.
*  MOVE it_bsid-brsch TO it_industry-brsch.
*  APPEND it_industry.

  MOVE it_bsid-vkbur TO it_channel-gsber.
  MOVE it_bsid-channel TO it_channel-channel.
  IF va_flag IS INITIAL.
    MOVE it_bsid-kdgrp TO it_channel-kdgrp.
  ELSE.
    MOVE it_bsid-brsch TO it_channel-brsch.
  ENDIF.
  APPEND it_channel.

  MOVE it_bsid-vkbur TO it_choose-gsber.
  MOVE it_bsid-kunnr TO it_choose-kunnr.
  MOVE it_bsid-kdgrp TO it_choose-kdgrp.
  MOVE it_bsid-xref2 TO it_choose-xref2.
  MOVE it_bsid-xref1 TO it_choose-xref1.
  MOVE it_bsid-brsch TO it_choose-brsch.
  MOVE it_bsid-channel TO it_choose-channel.
  MOVE it_bsid-kvgr3 TO it_choose-kvgr3.
  MOVE it_bsid-anln1 TO it_choose-anln1.
  APPEND it_choose.

ENDFORM.                    " APPEND
*&---------------------------------------------------------------------*
*&      Form  DELETE_ADJ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_adj.
  SORT it_gsber BY gsber.
  DELETE ADJACENT DUPLICATES FROM it_gsber.
*  SORT it_brcust BY gsber kunnr.
*  DELETE ADJACENT DUPLICATES FROM it_brcust.
*  SORT it_brcustgr BY gsber kdgrp.
*  DELETE ADJACENT DUPLICATES FROM it_brcustgr.
*  SORT it_brsales BY gsber xref2.
*  DELETE ADJACENT DUPLICATES FROM it_brsales.
*  SORT it_brroute BY gsber xref1.
*  DELETE ADJACENT DUPLICATES FROM it_brroute.
*  SORT it_brroute1 BY gsber kunnr xref1.
*  DELETE ADJACENT DUPLICATES FROM it_brroute1.
*  SORT it_industry BY gsber brsch.
*  DELETE ADJACENT DUPLICATES FROM it_industry.
  IF va_flag IS INITIAL.
    SORT it_channel BY gsber channel kdgrp.
    DELETE ADJACENT DUPLICATES FROM it_channel.
  ELSE.
    SORT it_channel BY gsber channel brsch.
    DELETE ADJACENT DUPLICATES FROM it_channel.
  ENDIF.
  SORT it_choose BY gsber kunnr kdgrp xref2 xref1 brsch channel.
  DELETE ADJACENT DUPLICATES FROM it_choose.
ENDFORM.                    " DELETE_ADJ
*&---------------------------------------------------------------------*
*&      Form  PROCESS_SUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_sum.
  PERFORM get_giro.
*  PERFORM SUM_BRCUST.
*  PERFORM SUM_GSBER.
*  PERFORM SUM_BRCUSTGR.
*  PERFORM SUM_BRSALES.
*  PERFORM SUM_BRROUTE.

ENDFORM.                    " PROCESS_SUM
*&---------------------------------------------------------------------*
*&      Form  WRITE_BRCUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_brcust.
  DATA: l_plant LIKE bsid-gsber,
        l_lines TYPE i.
  DATA : l_limit TYPE p.

  DATA : lt_itab  LIKE itab OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_knkk OCCURS 0,
           kunnr  TYPE kunnr,
           klimk  TYPE klimk,
         END OF lt_knkk.
  DATA : BEGIN OF lt_kna1 OCCURS 0,
           kunnr  TYPE kunnr,
           name1  TYPE name1_gp,
         END OF lt_kna1.
  DATA : BEGIN OF lt_zplbc OCCURS 0,
           bukrs  TYPE bukrs,
           vstel  TYPE vstel,
           live   TYPE zlive_indicator,
         END OF lt_zplbc.
  DATA : lv_subrc TYPE sy-subrc.

  DESCRIBE TABLE itab LINES l_lines.

  CLEAR: header.
  no = 0.w16 = 0.
  IF count EQ 1.
** Added by Budi.P Bug program.
    CLEAR itab.
    READ TABLE itab INDEX 1.
** End added by Budi.P Bug program.
    plant = itab-gsber.
    page = 1.
    PERFORM write_header.
  ENDIF.

  CLEAR : v_begin,v_sales,v_payment,v_ending,v_giro,v_limit,v_due1,
          v_due2, v_due3,v_due4,v_due5.

  lt_itab[] = itab[].
  SORT lt_itab BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING kunnr.
  IF lt_itab[] IS NOT INITIAL.
    SELECT kunnr klimk
      FROM knkk
      INTO TABLE lt_knkk
      FOR ALL ENTRIES IN lt_itab
      WHERE kunnr EQ lt_itab-kunnr.

    SELECT kunnr name1
      FROM kna1
      INTO TABLE lt_kna1
      FOR ALL ENTRIES IN lt_itab
      WHERE kunnr EQ lt_itab-kunnr.
  ENDIF.

  CLEAR : lt_itab[], lt_itab.
  lt_itab[] = itab[].
  SORT lt_itab BY gsber.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING gsber.
  IF lt_itab[] IS NOT INITIAL.
    SELECT b~bukrs a~vstel b~live
    FROM tvkol AS a JOIN zplbc AS b ON a~werks = b~werks AND
                                       a~lgort = b~lgort
    INTO TABLE lt_zplbc
    FOR ALL ENTRIES IN lt_itab
    WHERE b~bukrs EQ p_bukrs
      AND a~vstel EQ lt_itab-gsber
      AND b~live  EQ space.
  ENDIF.

  SORT itab BY gsber kunnr gjahr.
  LOOP AT itab.
    PERFORM f_check_write USING itab-begin itab-sales
                                itab-payment itab-ending
                                itab-giro
                          CHANGING lv_subrc.
    IF lv_subrc IS INITIAL.
      IF count NE 1.
        ON CHANGE OF itab-gsber.
*      AT NEW gsber.
          FORMAT COLOR OFF.
          plant = itab-gsber.
          page = 1.
          PERFORM write_header.
*      ENDAT.
        ENDON.
      ENDIF.

      IF header IS INITIAL.
        page = 1.
        PERFORM write_header.
      ENDIF.

      PERFORM zebra.
      no = no + 1.

      CLEAR: itab-limit, itab-giro.

      READ TABLE lt_knkk WITH KEY kunnr = itab-kunnr.
      IF sy-subrc EQ 0.
        itab-limit  = lt_knkk-klimk.
      ENDIF.

      l_limit = itab-limit * 100.
      IF l_limit >= 99999999999999.
        itab-limit = 0.
      ENDIF.

      IF radio9 IS NOT INITIAL.
        LOOP AT i_giro WHERE vkbur EQ itab-gsber AND
                             kunnr EQ itab-kunnr AND
                             anln1 EQ itab-anln1.
          itab-giro = itab-giro + i_giro-cchek.
        ENDLOOP.
        LOOP AT i_giro_sfa WHERE vkbur EQ itab-gsber AND
                                 kunnr EQ itab-kunnr AND
                                 anln1 EQ itab-anln1.
          itab-giro = itab-giro + i_giro_sfa-bank_amt.
        ENDLOOP.
      ELSE.
        LOOP AT i_giro WHERE vkbur EQ itab-gsber AND
                             kunnr EQ itab-kunnr.
          itab-giro = itab-giro + i_giro-cchek.
        ENDLOOP.
        LOOP AT i_giro_sfa WHERE vkbur EQ itab-gsber AND
                                 kunnr EQ itab-kunnr.
          itab-giro = itab-giro + i_giro_sfa-bank_amt.
        ENDLOOP.
      ENDIF.

      MODIFY itab TRANSPORTING limit giro.

      CLEAR lt_kna1.
      READ TABLE lt_kna1 WITH KEY kunnr = itab-kunnr.
      CLEAR: lt_zplbc, lv_subrc.
      READ TABLE lt_zplbc WITH KEY vstel = itab-gsber.
      lv_subrc  = sy-subrc.
      PERFORM write_detail_brcust USING lt_kna1-name1 lv_subrc.
      PERFORM get_amount.

*IF NO EQ 70.
      IF no EQ 55.
        SKIP 1.
        no = 0.
        txt = 'Sub Total'.
        PERFORM move_amount.
        PERFORM subtotal.
        FORMAT COLOR OFF.
        plant = itab-gsber.
        NEW-PAGE.
        page = page + 1.
        PERFORM write_header.
      ENDIF.

      AT END OF gsber.
        SKIP 1.
        no = 0.
        txt = 'Sub Total'.
        PERFORM move_amount.
        PERFORM subtotal.

        CLEAR itab-limit.
        SUM.
        SKIP 1.
        txt = 'TOTAL'.
        PERFORM subtotal.

        IF sy-tabix GE l_lines.
          PERFORM write_bottom.
        ELSE.
          no = 0.
          NEW-PAGE.
        ENDIF.
      ENDAT.
    ENDIF.
  ENDLOOP.
  CLEAR itab.
ENDFORM.                    " WRITE_BRCUST

*&---------------------------------------------------------------------*
*&      Form  WRITE_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_header.
  DATA : due1(14),
         due2(14),
         due3(14),
         due4(14),
         due5(14),
         n1 TYPE i,
         n2 TYPE i,
         l_cab(50),
         l_butxt LIKE t001-butxt.
  header = 1.
  FORMAT COLOR 1.
  IF top = 'X'.
    CONCATENATE '1-' int1low ' HARI' INTO due1.
    CONCATENATE int1low '-' int2low ' HARI' INTO due2.
    CONCATENATE int2low '-' int3low ' HARI' INTO due3.
    CONCATENATE int3low '-' int4low ' HARI' INTO due4.
    CONCATENATE '>' int4low ' HARI' INTO due5.
  ELSE.
    CONCATENATE 'NOT' ' DUE' INTO due1.
    CONCATENATE  '1-' int1low ' HARI' INTO due2.
    CONCATENATE int1low '-' int2low ' HARI' INTO due3.
    CONCATENATE int2low '-' int3low ' HARI' INTO due4.
    CONCATENATE '>' int3low ' HARI' INTO due5.
  ENDIF.
  c1 = 0.

  IF radio2 EQ 'X' OR sy-ucomm = 'CHOOSE'.
    n1 = 127.
    n2 = 118.
  ELSEIF radio5 EQ 'X'.
    n1 = 114.
    n2 = 104.
  ELSEIF radio9 EQ 'X'.
    n1 = 165.
    n2 = 155.
  ELSE.
    n1 = 101.
    n2 = 91.
  ENDIF.

  PERFORM bulan.
  SELECT SINGLE butxt INTO l_butxt FROM t001 WHERE bukrs EQ p_bukrs.
  IF top EQ 'X'.
    WRITE :/ l_butxt.
    WRITE AT 80(n1) 'DAFTAR PIUTANG, PLAFOND & TOP'.
  ELSE.
    WRITE :/ l_butxt.
    WRITE AT 80(n1) 'DAFTAR PIUTANG, PLAFOND & AGING'.
  ENDIF.

  IF radio2 EQ 'X' OR sy-ucomm = 'CHOOSE'.
    WRITE AT /80(10) 'CABANG : '.
    SELECT SINGLE bezei INTO cab FROM tvkbt
    WHERE spras EQ 'E' AND vkbur EQ plant.
    CONCATENATE plant '-' cab INTO l_cab.
    WRITE AT 90(n2) l_cab.
    WRITE :/'UserID : ', sy-uname, '/', sy-tcode,
             80(10) 'BULAN  : '.
    WRITE AT 90(n2) bulan.
    WRITE :/(10) 'CETAK : '.
    WRITE AT 10(10) sy-datum.
    WRITE AT 21(10) sy-uzeit.
    WRITE AT 80(10) 'PROSES : '.
    WRITE AT 90(n2) p_gerdat MM/DD/YYYY.
    WRITE AT 190(8) 'Page : '.
    WRITE AT 199(4) page.
  ELSE.
    IF radio1 NE 'X'.
      WRITE AT /80(10) 'CABANG : '.
      SELECT SINGLE bezei INTO cab FROM tvkbt
      WHERE spras EQ 'E' AND vkbur EQ plant.
      CONCATENATE plant '-' cab INTO l_cab.
      WRITE AT 90(n2) l_cab.
    ENDIF.
    WRITE :/'UserID : ', sy-uname, '/', sy-tcode,
             80(10) 'BULAN  : '.
    WRITE AT 90(n2) bulan.
    WRITE :/(10) 'CETAK : '.
    WRITE AT 10(10) sy-datum.
    WRITE AT 21(10) sy-uzeit.
    WRITE AT 80(10) 'PROSES : '.
    WRITE AT 90(n2) p_gerdat MM/DD/YYYY.
    WRITE AT 168(8) 'Page : '.
    WRITE AT 176(4) page.
  ENDIF.
  SKIP 1.
  IF radio2 EQ 'X' OR sy-ucomm = 'CHOOSE'.
    WRITE AT /(w1) 'NO'.c1 = w1 + 2.
    WRITE AT c1(w2) 'CUSTOMER NAME'  NO-GAP.c1 = c1 + w2 + 1. " + W14.
    w9 = 14.
    SET LEFT SCROLL-BOUNDARY.
  ELSEIF radio1 EQ 'X'.
    WRITE AT /(w2) 'BRANCH'.c1 = c1 + w2.                   " + W14.
    w9 = 16.
    SET LEFT SCROLL-BOUNDARY.
  ELSEIF radio3 EQ 'X'.
    WRITE AT /(w2) 'CUSTOMER GROUP'.c1 = c1 + w2.           " + W14.
    w9 = 16.
    SET LEFT SCROLL-BOUNDARY.
  ELSEIF radio4 EQ 'X'.
    WRITE AT /(w2) 'SALESMAN '.c1 = c1 + w2.                " + W14.
    w9 = 16.
    SET LEFT SCROLL-BOUNDARY.
  ELSEIF radio5 EQ 'X'.
    WRITE AT /(37) 'ROUTE LIST'.c1 = c1 + 37.               " + W14.
    w9 = 16.
    SET LEFT SCROLL-BOUNDARY.
  ELSEIF radio6 EQ 'X'.
    WRITE AT /(w2) 'INDUSTRY CODE'.c1 = c1 + w2.            "+ W14.
    w9 = 16.
    SET LEFT SCROLL-BOUNDARY.
  ELSEIF radio7 EQ 'X'.
    WRITE AT /(w2) 'CHANNEL'.c1 = c1 + w2.                  "+ W14.
    w9 = 16.
    SET LEFT SCROLL-BOUNDARY.
  ELSEIF radio8 EQ 'X'.
    WRITE AT /(w2) 'SUB CUSTOMER GROUP'.c1 = c1 + w2.       " + W14.
    w9 = 16.
    SET LEFT SCROLL-BOUNDARY.
  ELSEIF radio9 EQ 'X'.
    WRITE AT /(w1) 'NO'.c1 = w1 + 2.
    WRITE AT c1(w2) 'CUSTOMER NAME'  NO-GAP.c1 = c1 + w2 + 1. " + W14.
    WRITE AT c1(w2) 'DN PRINCIPAL'  NO-GAP.c1 = c1 + w2 + 1. " + W14.
    w9 = 20.
    SET LEFT SCROLL-BOUNDARY.

  ENDIF.

*WRITE AT C1(W14) 'FISCAL'.C1 = C1 + W14 + 1.
  WRITE AT c1(w3) 'SALDO AWAL' RIGHT-JUSTIFIED.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) 'NET SALES' RIGHT-JUSTIFIED.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) 'PAYMENT' RIGHT-JUSTIFIED.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) 'SALDO AKHIR' RIGHT-JUSTIFIED.c1 = c1 + w6 + 1.
  WRITE AT c1(w7) 'JUMLAH GIRO' RIGHT-JUSTIFIED.c1 = c1 + w7 + 1.
  IF radio2 EQ 'X' OR sy-ucomm = 'CHOOSE'.
    WRITE AT c1(w8) 'LIMIT/PLAFOND' RIGHT-JUSTIFIED.c1 = c1 + w8 + 1.
  ELSEIF radio9 IS NOT INITIAL.
    WRITE AT c1(w8) 'LIMIT/PLAFOND' RIGHT-JUSTIFIED.c1 = c1 + w8 + 1.
  ENDIF.
  WRITE AT c1(w9) due1 RIGHT-JUSTIFIED.c1 = c1 + w9 + 1.
  WRITE AT c1(w10) due2 RIGHT-JUSTIFIED.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) due3 RIGHT-JUSTIFIED.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) due4 RIGHT-JUSTIFIED.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) due5 RIGHT-JUSTIFIED.
  SKIP 1.

ENDFORM.                    " WRITE_HEADER
*&---------------------------------------------------------------------*
*&      Form  INIT_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_print.
  w1   =  12.      w11 = 14.
  w2   =  24.      w12 = 14.
  w3   =  16.      w13 = 16.
  w4   =  14.      w14 = 4.
  w5   =  14.      w15 = 8.
  w6   =  16.
  w7   =  14.
  w8   =  16.
  w9   =  14.
  w10  =  14.
  c1 = 0.

ENDFORM.                    " INIT_PRINT
*&---------------------------------------------------------------------*
*&      Form  SUBTOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM subtotal.
  DATA text(40).
  c1 = 0.
  c1 = w1 + 1.
  CONCATENATE txt cab INTO text SEPARATED BY space.
  PERFORM format_total.
  WRITE AT /c1(w2) text.c1 = c1 + w2 + 2.
  WRITE AT c1(w3) itab-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) itab-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) itab-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
*WRITE AT C1(W8) ITAB-LIMIT CURRENCY 'IDR'.
  c1 = c1 + w8 + 1.
  WRITE AT c1(w9)  itab-due1 CURRENCY 'IDR'.c1 = c1 + w9 + 1.
  WRITE AT c1(w10) itab-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) itab-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) itab-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) itab-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.

ENDFORM.                    " SUBTOTAL
*&---------------------------------------------------------------------*
*&      Form  DUE_BRANCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM due_branch TABLES  ft_bsid STRUCTURE it_bsid.
  DATA age TYPE i.

  PERFORM get_date_dz.

  PERFORM f_age_calculate TABLES ft_bsid
                          USING it_bsid-bukrs it_bsid-vkbur
                                it_bsid-kunnr it_bsid-zuonr
                                'V' it_bsid-zfbdt it_bsid-zbd1t
                          CHANGING age.

  IF top EQ 'X'.
    "Kondisi utk AR potongan
*    age = p_gerdat - it_bsid-zfbdt.
*    IF it_bsid-umskz = 'V'.
*      age = p_gerdat - it_bsid-budat.
*    ELSE.
*      age = p_gerdat - it_bsid-zfbdt.
*    ENDIF.
    IF age LE int1low.
      itab-due1 = itab-due1 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab-due2 = itab-due2 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab-due3 = itab-due3 + it_bsid-dmbtr.
    ELSEIF age GT int3low AND age LE int4low.
      itab-due4 = itab-due4 + it_bsid-dmbtr.
    ELSEIF age GT int4low.
      itab-due5 = itab-due5 + it_bsid-dmbtr.
    ENDIF.
  ELSE.
    IF age LE 0.
      itab-due1 = itab-due1 + it_bsid-dmbtr.
    ELSEIF age GE 1 AND age LE int1low.
      itab-due2 = itab-due2 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab-due3 = itab-due3 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab-due4 = itab-due4 + it_bsid-dmbtr.
    ELSEIF age GT int3low.
      itab-due5 = itab-due5 + it_bsid-dmbtr.
    ENDIF.
  ENDIF.
ENDFORM.                    " DUE_BRANCH
*&---------------------------------------------------------------------*
*&      Form  DUE_BRANCH_HOT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM due_branch_hot TABLES ft_bsid.
  DATA age TYPE i.

  PERFORM get_date_dz.

  PERFORM f_age_calculate TABLES ft_bsid
                          USING it_bsid-bukrs it_bsid-vkbur
                                it_bsid-kunnr it_bsid-zuonr
                                'V' it_bsid-zfbdt it_bsid-zbd1t
                          CHANGING age.

  IF top EQ 'X'.
    "Kondisi utk AR potongan
*    age = p_gerdat - it_bsid-zfbdt.
*    IF it_bsid-umskz = 'V'.
*      age = p_gerdat - it_bsid-budat.
*    ELSE.
*      age = p_gerdat - it_bsid-zfbdt.
*    ENDIF.
    IF age LE int1low.
      t_hotspot-due1 = t_hotspot-due1 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      t_hotspot-due2 = t_hotspot-due2 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      t_hotspot-due3 = t_hotspot-due3 + it_bsid-dmbtr.
    ELSEIF age GT int3low AND age LE int4low.
      t_hotspot-due4 = t_hotspot-due4 + it_bsid-dmbtr.
    ELSEIF age GT int4low.
      t_hotspot-due5 = t_hotspot-due5 + it_bsid-dmbtr.
    ENDIF.
  ELSE.
    IF age LE 0.
      t_hotspot-due1 = t_hotspot-due1 + it_bsid-dmbtr.
    ELSEIF age GE 1 AND age LE int1low.
      t_hotspot-due2 = t_hotspot-due2 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      t_hotspot-due3 = t_hotspot-due3 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      t_hotspot-due4 = t_hotspot-due4 + it_bsid-dmbtr.
    ELSEIF age GT int3low.
      t_hotspot-due5 = t_hotspot-due5 + it_bsid-dmbtr.
    ENDIF.
  ENDIF.
ENDFORM.                    " DUE_BRANCH_HOT
*&---------------------------------------------------------------------*
*&      Form  DUE_BRANCH1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM due_branch1 TABLES   ft_bsid STRUCTURE it_bsid.
  DATA age TYPE i.

  PERFORM get_date_dz.

  PERFORM f_age_calculate TABLES ft_bsid
                          USING it_bsid-bukrs it_bsid-vkbur
                                it_bsid-kunnr it_bsid-zuonr
                                'V' it_bsid-zfbdt it_bsid-zbd1t
                          CHANGING age.

  IF top EQ 'X'.
    "Kondisi utk AR potongan
*    age = p_gerdat - it_bsid-zfbdt.

*    IF it_bsid-umskz = 'V'.
*      age = p_gerdat - it_bsid-budat.
*    ELSE.
*      age = p_gerdat - it_bsid-zfbdt.
*    ENDIF.
    IF age LE int1low.
      itab1-due1 = itab1-due1 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab1-due2 = itab1-due2 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab1-due3 = itab1-due3 + it_bsid-dmbtr.
    ELSEIF age GT int3low AND age LE int4low.
      itab1-due4 = itab1-due4 + it_bsid-dmbtr.
    ELSEIF age GT int4low.
      itab1-due5 = itab1-due5 + it_bsid-dmbtr.
    ENDIF.
  ELSE.
    IF age LE 0.
      itab1-due1 = itab1-due1 + it_bsid-dmbtr.
    ELSEIF age GE 1 AND age LE int1low.
      itab1-due2 = itab1-due2 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab1-due3 = itab1-due3 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab1-due4 = itab1-due4 + it_bsid-dmbtr.
    ELSEIF age GT int3low.
      itab1-due5 = itab1-due5 + it_bsid-dmbtr.
    ENDIF.
  ENDIF.

ENDFORM.                    " DUE_BRANCH1
*&---------------------------------------------------------------------*
*&      Form  WRITE_GSBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_gsber.
  DATA : lt_itab  LIKE itab1 OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_tvkbt OCCURS 0,
           vkbur  TYPE vkbur,
           bezei  TYPE bezei20,
         END OF lt_tvkbt.
  DATA : lv_subrc  TYPE sy-subrc.

  no = 0.
  page = 1.
  PERFORM write_header.
  CLEAR : v_begin,v_sales,v_payment,v_ending,v_giro,v_due1,v_due2,v_due3,
          v_due4,v_due5,w16.

  lt_itab[] = itab1[].
  SORT lt_itab BY gsber.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING gsber.
  IF lt_itab[] IS NOT INITIAL.
    SELECT vkbur bezei
      FROM tvkbt
      INTO TABLE lt_tvkbt
      FOR ALL ENTRIES IN lt_itab
      WHERE spras EQ sy-langu
        AND vkbur EQ lt_itab-gsber.
  ENDIF.

  SORT itab1 BY gsber gjahr.
  LOOP AT itab1.
    PERFORM f_check_write USING itab1-begin itab1-sales
                                itab1-payment itab1-ending
                                itab1-giro
                          CHANGING lv_subrc.
    IF lv_subrc IS INITIAL.
      PERFORM zebra.
      plant = itab1-gsber.
      no = no + 1.

      CLEAR lt_tvkbt.
      READ TABLE lt_tvkbt WITH KEY vkbur = itab1-gsber.
      PERFORM write_detail_gsber USING lt_tvkbt-bezei.

      v_begin = v_begin + itab1-begin.
      v_sales = v_sales + itab1-sales.
      v_payment = v_payment + itab1-payment.
      v_ending = v_ending + itab1-ending.
      v_giro  = v_giro + itab1-giro.
      v_due1 = v_due1 + itab1-due1.
      v_due2 = v_due2 + itab1-due2.
      v_due3 = v_due3 + itab1-due3.
      v_due4 = v_due4 + itab1-due4.
      v_due5 = v_due5 + itab1-due5.
    ENDIF.
  ENDLOOP.
  PERFORM grand_gsber.
  PERFORM write_bottom.
ENDFORM.                    " WRITE_GSBER
*&---------------------------------------------------------------------*
*&      Form  WRITE_DETAIL_BRCUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_detail_brcust USING fu_name1 fu_subrc.
  DATA : name1 LIKE kna1-name1,
         l_live LIKE zplbc-live.

  c1 = 0.
  name1 = fu_name1.

  MOVE itab-kunnr TO itab-kunnr1.
  IF fu_subrc EQ 0.
    MOVE itab-sortl TO itab-kunnr.
  ENDIF.

  WRITE AT /(w1) itab-kunnr HOTSPOT.c1 = w1 + 2.
  HIDE: itab-gsber, itab-kunnr.
  WRITE AT c1(w2) name1.c1 = c1 + w2 + 1.
*WRITE AT C1(W14) ITAB-GJAHR.C1 = C1 + W14.
  WRITE AT c1(w3) itab-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) itab-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) itab-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
  WRITE AT c1(w8) itab-limit CURRENCY 'IDR'.c1 = c1 + w8 + 1.
  WRITE AT c1(w9)  itab-due1 CURRENCY 'IDR'.c1 = c1 + w9 + 1.
  WRITE AT c1(w10) itab-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) itab-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) itab-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) itab-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.

ENDFORM.                    " WRITE_DETAIL_BRCUST
*&---------------------------------------------------------------------*
*&      Form  WRITE_DETAIL_GSBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_detail_gsber USING fu_bezei.
  DATA cab LIKE tgsbt-gtext.

  cab = fu_bezei.
  CONCATENATE plant '-' cab INTO cab.
  c1 = 0.
  WRITE AT /(w2) cab HOTSPOT.c1 = c1 + w2 + 1.
  HIDE itab1-gsber.
*WRITE AT C1(W14) ITAB1-GJAHR.C1 = C1 + W14 + 1.
  WRITE AT c1(w3) itab1-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) itab1-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) itab1-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab1-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab1-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
*WRITE AT C1(W8) ITAB1-LIMIT CURRENCY 'IDR'.C1 = C1 + W8 + 1.
  WRITE AT c1(w13)  itab1-due1 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
  WRITE AT c1(w10) itab1-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) itab1-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) itab1-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) itab1-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
ENDFORM.                    " WRITE_DETAIL_GSBER

*&---------------------------------------------------------------------*
*&      Form  SUM_BRCUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sum_brcust.
  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  lt_bsid[] = it_bsid[].

  SORT it_bsid BY bukrs vkbur kunnr zuonr.
  SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

  CLEAR: it_bsid.
  LOOP AT it_bsid.
    CLEAR itab.
    MOVE it_bsid-vkbur TO itab-gsber.
    MOVE it_bsid-kunnr TO itab-kunnr.
    MOVE p_gerdat(4) TO itab-gjahr.

    IF it_bsid-shkzg EQ 'H'.
      it_bsid-dmbtr = it_bsid-dmbtr * -1.
      IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
        it_bsid-zbd1t = 0.
      ENDIF.
    ENDIF.
    IF it_bsid-budat(6) LT p_gerdat(6).
      itab-begin = itab-begin + it_bsid-dmbtr.
    ENDIF.

** Koreksi by budi 07/09/2006 req. by SJT
    IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
       it_bsid-blart NE 'DR'.
** End koreksi by budi 07/09/2006 req. by SJT
      IF it_bsid-budat GE l_gerdat1 AND
         it_bsid-budat LT l_gerdat2.
        itab-sales = itab-sales + it_bsid-dmbtr.
      ENDIF.
    ELSE.
      IF it_bsid-budat GE l_gerdat1 AND
         it_bsid-budat LT l_gerdat2.
        itab-payment = itab-payment + it_bsid-dmbtr.
      ENDIF.
    ENDIF.

    PERFORM due_branch  TABLES lt_bsid.

    MOVE it_bsid-sortl TO itab-sortl.

    itab-payment = itab-payment.
    itab-sales =  itab-sales.
    itab-ending = itab-begin + itab-sales + ( itab-payment ).
    COLLECT itab.
  ENDLOOP.
ENDFORM.                    " SUM_BRCUST

*&---------------------------------------------------------------------*
*&      Form  SUM_GSBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sum_gsber.
  DATA : l_cchek LIKE zfbicheck-cchek.

  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  lt_bsid[] = it_bsid[].

  SORT it_bsid BY bukrs vkbur kunnr zuonr.
  SORT i_giro BY bukrs vkbur kunnr.
  SORT i_giro_sfa BY bukrs vkbur kunnr.
  SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

  LOOP AT it_bsid.
    CLEAR itab1.
    MOVE it_bsid-vkbur TO itab1-gsber.
    MOVE p_gerdat(4) TO itab1-gjahr.

    ON CHANGE OF it_bsid-kunnr.
      LOOP AT i_giro WHERE vkbur EQ it_bsid-vkbur AND
                           kunnr EQ it_bsid-kunnr.
        itab1-giro = itab1-giro + i_giro-cchek.
      ENDLOOP.
      LOOP AT i_giro_sfa WHERE vkbur EQ it_bsid-vkbur AND
                               kunnr EQ it_bsid-kunnr.
        itab1-giro = itab1-giro + i_giro_sfa-bank_amt.
      ENDLOOP.
    ENDON.

    IF it_bsid-shkzg EQ 'H'.
      it_bsid-dmbtr = it_bsid-dmbtr * -1.
      IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
        it_bsid-zbd1t = 0.
      ENDIF.
    ENDIF.
    IF it_bsid-budat(6) LT p_gerdat(6).
      itab1-begin = itab1-begin + it_bsid-dmbtr.
    ENDIF.

** Koreksi by budi 07/09/2006 req. by SJT
*      IF it_bsid-blart NE 'DZ'.
    IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
       it_bsid-blart NE 'DR'.
** End koreksi by budi 07/09/2006 req. by SJT
      IF it_bsid-budat GE l_gerdat1 AND
         it_bsid-budat LT l_gerdat2.
        itab1-sales = itab1-sales + it_bsid-dmbtr.
      ENDIF.
    ELSE.
      IF it_bsid-budat GE l_gerdat1 AND
         it_bsid-budat LT l_gerdat2.
        itab1-payment = itab1-payment + it_bsid-dmbtr.
      ENDIF.
    ENDIF.
*      ENDIF.
    PERFORM due_branch1 TABLES lt_bsid.

    itab1-payment = itab1-payment.
    itab1-sales = itab1-sales.
    itab1-ending = itab1-begin + itab1-sales + ( itab1-payment ).
    COLLECT itab1.
  ENDLOOP.
ENDFORM.                    " SUM_GSBER

*&---------------------------------------------------------------------*
*&      Form  SUM_BRCUSTGR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sum_brcustgr.
  DATA : l_cchek LIKE zfbicheck-cchek.
  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  lt_bsid[] = it_bsid[].
  SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

  SORT it_bsid BY bukrs vkbur kunnr kdgrp.
  SORT i_giro BY bukrs vkbur kunnr kdgrp.
  SORT i_giro_sfa BY bukrs vkbur kunnr kdgrp.

  LOOP AT it_bsid.
    CLEAR itab2.
    MOVE it_bsid-vkbur TO itab2-gsber.
    MOVE it_bsid-kdgrp TO itab2-kdgrp.
    MOVE p_gerdat(4) TO itab2-gjahr.

    ON CHANGE OF it_bsid-kunnr.
      LOOP AT i_giro WHERE vkbur EQ it_bsid-vkbur AND
                           kunnr EQ it_bsid-kunnr AND
                           kdgrp EQ it_bsid-kdgrp.
        itab2-giro = itab2-giro + i_giro-cchek.
      ENDLOOP.
      LOOP AT i_giro_sfa WHERE vkbur EQ it_bsid-vkbur AND
                               kunnr EQ it_bsid-kunnr AND
                               kdgrp EQ it_bsid-kdgrp.
        itab2-giro = itab2-giro + i_giro_sfa-bank_amt.
      ENDLOOP.
    ENDON.

    IF it_bsid-shkzg EQ 'H'.
      it_bsid-dmbtr = it_bsid-dmbtr * -1.
      IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
        it_bsid-zbd1t = 0.
      ENDIF.
    ENDIF.
    IF it_bsid-budat(6) LT p_gerdat(6).
      itab2-begin = itab2-begin + it_bsid-dmbtr.
    ENDIF.

** Koreksi by budi 07/09/2006 req. by SJT
*      IF it_bsid-blart NE 'DZ'.
    IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
       it_bsid-blart NE 'DR'.
** End koreksi by budi 07/09/2006 req. by SJT
      IF it_bsid-budat GE l_gerdat1 AND
         it_bsid-budat LT l_gerdat2.
        itab2-sales = itab2-sales + it_bsid-dmbtr.
      ENDIF.
    ELSE.
      IF it_bsid-budat GE l_gerdat1 AND
         it_bsid-budat LT l_gerdat2.
        itab2-payment = itab2-payment + it_bsid-dmbtr.
      ENDIF.
    ENDIF.
*      ENDIF.
    PERFORM due_bracustgr TABLES lt_bsid.

    itab2-payment = itab2-payment.
    itab2-sales = itab2-sales.
    itab2-ending = itab2-begin + itab2-sales + ( itab2-payment ).
*   IF ITAB2-BEGIN NE 0 OR ITAB2-ENDING NE 0.
    COLLECT itab2.
  ENDLOOP.
ENDFORM.                    " SUM_BRCUSTGR

*&---------------------------------------------------------------------*
*&      Form  WRITE_BRCUSTGR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_brcustgr.
  DATA : l_lines TYPE i.

  DATA : lt_itab  LIKE itab2 OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_t151t OCCURS 0,
           kdgrp  TYPE kdgrp,
           ktext  TYPE vtxtk,
         END OF lt_t151t.

  DATA : lv_subrc   TYPE sy-subrc.

  DESCRIBE TABLE itab2 LINES l_lines.

  no = 0.
  IF count EQ 1.
** Added by Budi.P Bug program.
    CLEAR itab2.
    READ TABLE itab2 INDEX 1.
** End added by Budi.P Bug program.
    plant = itab2-gsber.
    page = 1.
    PERFORM write_header.
  ENDIF.

  lt_itab[] = itab2[].
  SORT lt_itab BY kdgrp.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING kdgrp.
  IF lt_itab[] IS NOT INITIAL.
    SELECT kdgrp ktext
      FROM t151t
      INTO TABLE lt_t151t
      FOR ALL ENTRIES IN lt_itab
      WHERE spras EQ sy-langu
        AND kdgrp EQ lt_itab-kdgrp.
  ENDIF.

  SORT itab2 BY gsber kdgrp gjahr.
  LOOP AT itab2.
    PERFORM f_check_write USING itab2-begin itab2-sales
                                itab2-payment itab2-ending
                                itab2-giro
                          CHANGING lv_subrc.
    IF lv_subrc IS INITIAL.
      IF count NE 1.
        ON CHANGE OF itab2-gsber.
          FORMAT COLOR OFF.
          plant = itab2-gsber.
          page = 1.
          PERFORM write_header.
        ENDON.
      ENDIF.
      PERFORM zebra.
      no = no + 1.

      CLEAR lt_t151t.
      READ TABLE lt_t151t WITH KEY kdgrp = itab2-kdgrp.
      PERFORM write_detail_brcustgr USING lt_t151t-ktext.

      AT END OF gsber.
        SUM.
        SKIP 1.
        PERFORM subtotal1.
        IF sy-tabix GE l_lines.
          PERFORM write_bottom.
        ELSE.
          NEW-PAGE.
        ENDIF.
      ENDAT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " WRITE_BRCUSTGR

*&---------------------------------------------------------------------*
*&      Form  WRITE_DETAIL_BRCUSTGR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_detail_brcustgr USING fu_ktext.
  DATA ktext LIKE t151t-ktext.
  c1 = 0.

  ktext = fu_ktext.

  WRITE AT /c1(w2) ktext HOTSPOT.c1 = c1 + w2 + 1.
  HIDE: itab2-gsber, itab2-kdgrp.
*WRITE AT C1(W14) ITAB2-GJAHR.C1 = C1 + W14 + 1.
  WRITE AT c1(w3) itab2-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) itab2-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) itab2-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab2-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab2-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
*WRITE AT C1(W8) ITAB-LIMIT CURRENCY 'IDR'.C1 = C1 + W8 + 1.
  WRITE AT c1(w13) itab2-due1 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
  WRITE AT c1(w10) itab2-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) itab2-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) itab2-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) itab2-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
ENDFORM.                    " WRITE_DETAIL_BRCUSTGR

*&---------------------------------------------------------------------*
*&      Form  SUBTOTAL1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM subtotal1.
  DATA text(40).
  c1 = 0.
  c1 = 4.
  CONCATENATE 'TOTAL' cab INTO text SEPARATED BY space.
  PERFORM format_total.
  WRITE AT /c1(w2) text.c1 = c1 + w2 - 3.
  WRITE AT c1(w3) itab2-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) itab2-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) itab2-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab2-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab2-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
*WRITE AT C1(W8) ITAB2-LIMIT CURRENCY 'IDR'.C1 = C1 + W8 + 1.
  WRITE AT c1(w13)  itab2-due1 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
  WRITE AT c1(w10) itab2-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) itab2-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) itab2-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) itab2-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.

ENDFORM.                                                    " SUBTOTAL1
*&---------------------------------------------------------------------*
*&      Form  DUE_BRACUSTGR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM due_bracustgr  TABLES ft_bsid STRUCTURE it_bsid.
  DATA age TYPE i.

  PERFORM get_date_dz.

  PERFORM f_age_calculate TABLES ft_bsid
                          USING it_bsid-bukrs it_bsid-vkbur
                                it_bsid-kunnr it_bsid-zuonr
                                'V' it_bsid-zfbdt it_bsid-zbd1t
                          CHANGING age.

  IF top EQ 'X'.
*    age = p_gerdat - it_bsid-zfbdt.
    IF age LE int1low.
      itab2-due1 = itab2-due1 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab2-due2 = itab2-due2 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab2-due3 = itab2-due3 + it_bsid-dmbtr.
    ELSEIF age GT int3low AND age LE int4low.
      itab2-due4 = itab2-due4 + it_bsid-dmbtr.
    ELSEIF age GT int4low.
      itab2-due5 = itab2-due5 + it_bsid-dmbtr.
    ENDIF.
  ELSE.
    IF age LE 0.
      itab2-due1 = itab2-due1 + it_bsid-dmbtr.
    ELSEIF age GE 1 AND age LE int1low.
      itab2-due2 = itab2-due2 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab2-due3 = itab2-due3 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab2-due4 = itab2-due4 + it_bsid-dmbtr.
    ELSEIF age GT int3low.
      itab2-due5 = itab2-due5 + it_bsid-dmbtr.
    ENDIF.
  ENDIF.

ENDFORM.                    " DUE_BRACUSTGR
*&---------------------------------------------------------------------*
*&      Form  GUI_PROGRESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM gui_progress.
  igui = sy-tabix MOD 100.
  IF igui = 0.
    WRITE sy-tabix TO gtext+0.
    CONDENSE gtext.
    WRITE text-001 TO gtext+20.
    CONDENSE gtext.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text = gtext.
  ENDIF.
ENDFORM.                    " GUI_PROGRESS
*&---------------------------------------------------------------------*
*&      Form  SUM_BRSALES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sum_brsales.
  DATA : l_cchek LIKE zfbicheck-cchek,
         l_xref2 LIKE bsid-xref2.

  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  lt_bsid[] = it_bsid[].
  SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

  SORT it_bsid BY bukrs vkbur kunnr xref2.
  SORT i_giro BY bukrs vkbur kunnr xref2.
  SORT i_giro_sfa BY bukrs vkbur kunnr xref2.

  LOOP AT it_bsid.
    CLEAR itab3.
    MOVE it_bsid-vkbur TO itab3-gsber.
    MOVE it_bsid-xref2 TO itab3-xref2.
    MOVE p_gerdat(4) TO itab3-gjahr.

    ON CHANGE OF it_bsid-kunnr.
      LOOP AT i_giro WHERE vkbur EQ it_bsid-vkbur AND
                           kunnr EQ it_bsid-kunnr AND
                           xref2 EQ it_bsid-xref2.
        itab3-giro = itab3-giro + i_giro-cchek.
      ENDLOOP.
      LOOP AT i_giro_sfa WHERE vkbur EQ it_bsid-vkbur AND
                               kunnr EQ it_bsid-kunnr AND
                               xref2 EQ it_bsid-xref2.
        itab3-giro = itab3-giro + i_giro_sfa-bank_amt.
      ENDLOOP.
    ENDON.

    IF it_bsid-shkzg EQ 'H'.
      it_bsid-dmbtr = it_bsid-dmbtr * -1.
      IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
        it_bsid-zbd1t = 0.
      ENDIF.
    ENDIF.
    IF it_bsid-budat(6) LT p_gerdat(6).
      itab3-begin = itab3-begin + it_bsid-dmbtr.
    ENDIF.

** Koreksi by budi 07/09/2006 req. by SJT
*      IF it_bsid-blart NE 'DZ'.
    IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
       it_bsid-blart NE 'DR'.
** End koreksi by budi 07/09/2006 req. by SJT
      IF  it_bsid-budat GE l_gerdat1 AND
          it_bsid-budat LT l_gerdat2.
        itab3-sales = itab3-sales + it_bsid-dmbtr.
      ENDIF.
    ELSE.
      IF it_bsid-budat GE l_gerdat1 AND
      it_bsid-budat LT l_gerdat2.
        itab3-payment = itab3-payment + it_bsid-dmbtr.
      ENDIF.
    ENDIF.
*      ENDIF.
    PERFORM due_brsales   TABLES lt_bsid.

    itab3-payment = itab3-payment.
    itab3-sales = itab3-sales.
    itab3-ending = itab3-begin + itab3-sales + ( itab3-payment ).
*   IF ITAB3-BEGIN NE 0 OR ITAB3-ENDING NE 0.
    COLLECT itab3. CLEAR itab3.
  ENDLOOP.
ENDFORM.                    " SUM_BRSALES

*&---------------------------------------------------------------------*
*&      Form  DUE_BRSALES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM due_brsales  TABLES ft_bsid  STRUCTURE it_bsid.
  DATA age TYPE i.

  PERFORM get_date_dz.

  PERFORM f_age_calculate TABLES ft_bsid
                          USING it_bsid-bukrs it_bsid-vkbur
                                it_bsid-kunnr it_bsid-zuonr
                                'V' it_bsid-zfbdt it_bsid-zbd1t
                          CHANGING age.

  IF top EQ 'X'.
*    age = p_gerdat - it_bsid-zfbdt.
    IF age LE int1low.
      itab3-due1 = itab3-due1 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab3-due2 = itab3-due2 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab3-due3 = itab3-due3 + it_bsid-dmbtr.
    ELSEIF age GT int3low AND age LE int4low.
      itab3-due4 = itab3-due4 + it_bsid-dmbtr.
    ELSEIF age GT int4low.
      itab3-due5 = itab3-due5 + it_bsid-dmbtr.
    ENDIF.
  ELSE.
    IF age LE 0.
      itab3-due1 = itab3-due1 + it_bsid-dmbtr.
    ELSEIF age GE 1 AND age LE int1low.
      itab3-due2 = itab3-due2 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab3-due3 = itab3-due3 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab3-due4 = itab3-due4 + it_bsid-dmbtr.
    ELSEIF age GT int3low.
      itab3-due5 = itab3-due5 + it_bsid-dmbtr.
    ENDIF.
  ENDIF.

ENDFORM.                    " DUE_BRSALES
*&---------------------------------------------------------------------*
*&      Form  WRITE_BRSALES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_brsales.
  DATA : l_lines TYPE i.
  DATA : lt_itab  LIKE itab3 OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_itab3 OCCURS 0.
          INCLUDE STRUCTURE itab3.
  DATA :   pernr  TYPE persno,
         END OF lt_itab3.
  DATA : BEGIN OF lt_pa0001 OCCURS 0,
           pernr  TYPE persno,
           ename  TYPE emnam,
         END OF lt_pa0001.
  DATA : lv_pernr TYPE persno.
  DATA : lv_subrc  TYPE sy-subrc.

  DESCRIBE TABLE itab3 LINES l_lines.

  no = 0.
  IF count EQ 1.
** Added by Budi.P Bug program.
    CLEAR itab3.
    READ TABLE itab3 INDEX 1.
** End added by Budi.P Bug program.
    plant = itab3-gsber.
    page = 1.
    PERFORM write_header.
  ENDIF.

  lt_itab[] = itab3[].
  SORT lt_itab BY xref2.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING xref2.
  LOOP AT lt_itab.
    MOVE-CORRESPONDING lt_itab TO lt_itab3.
    lt_itab3-pernr  = lt_itab-xref2.
    APPEND lt_itab3.
    CLEAR lt_itab3.
  ENDLOOP.
  IF lt_itab3[] IS NOT INITIAL.
    SELECT pernr ename
      FROM pa0001
      INTO TABLE lt_pa0001
      FOR ALL ENTRIES IN lt_itab3
      WHERE pernr EQ lt_itab3-pernr.
  ENDIF.

  SORT itab3 BY gsber xref2 gjahr.
  LOOP AT itab3.
    PERFORM f_check_write USING itab3-begin itab3-sales
                                itab3-payment itab3-ending
                                itab3-giro
                          CHANGING lv_subrc.
    IF lv_subrc IS INITIAL.
      IF count NE 1.
        ON CHANGE OF itab3-gsber.
          FORMAT COLOR OFF.
          plant = itab3-gsber.
          page = 1.
          PERFORM write_header.
        ENDON.
      ENDIF.
      PERFORM zebra.
      no = no + 1.

      CLEAR : lt_pa0001, lv_pernr.
      lv_pernr  = itab3-xref2.
      READ TABLE lt_pa0001 WITH KEY pernr = lv_pernr.
      PERFORM write_detail_brsales USING lt_pa0001-ename.

      AT END OF gsber.
        SUM.
        SKIP 1.
        PERFORM subtotal2.
        IF sy-tabix GE l_lines.
          PERFORM write_bottom.
        ELSE.
          SKIP 2.
        ENDIF.
      ENDAT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " WRITE_BRSALES

*&---------------------------------------------------------------------*
*&      Form  WRITE_DETAIL_BRSALES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_detail_brsales USING fu_ename.
  DATA : sales(20).

  CONCATENATE itab3-xref2 fu_ename INTO sales SEPARATED BY space.
  c1 = 0.
  WRITE AT /c1(w2) sales HOTSPOT.c1 = c1 + w2 + 1.
  HIDE: itab3-gsber, itab3-xref2. "ITAB3-XREF2
*WRITE AT C1(W14) ITAB3-GJAHR.C1 = C1 + W14 + 1.
  WRITE AT c1(w3) itab3-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) itab3-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) itab3-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab3-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab3-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
*WRITE AT C1(W8) ITAB-LIMIT CURRENCY 'IDR'.C1 = C1 + W8 + 1.
  WRITE AT c1(w13)  itab3-due1 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
  WRITE AT c1(w10) itab3-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) itab3-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) itab3-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) itab3-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.

ENDFORM.                    " WRITE_DETAIL_BRSALES
*&---------------------------------------------------------------------*
*&      Form  SUBTOTAL2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM subtotal2.
  DATA text(40).
  c1 = 0.
  c1 = 4.
  CONCATENATE 'TOTAL' cab INTO text SEPARATED BY space.
  PERFORM format_total.
  WRITE AT /c1(w2) text.c1 = c1 + w2 - 3.
  WRITE AT c1(w3) itab3-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) itab3-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) itab3-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab3-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab3-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
*WRITE AT C1(W8) ITAB2-LIMIT CURRENCY 'IDR'.C1 = C1 + W8 + 1.
  WRITE AT c1(w13)  itab3-due1 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
  WRITE AT c1(w10) itab3-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) itab3-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) itab3-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) itab3-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.

ENDFORM.                                                    " SUBTOTAL2
*&---------------------------------------------------------------------*
*&      Form  SUM_BRROUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sum_brroute.
  DATA : l_cchek LIKE zfbicheck-cchek,
         ld_kunn2  LIKE knvp-kunn2,
         ld_xref1  LIKE bsid-xref1.

  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  lt_bsid[] = it_bsid[].
  SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

  SORT t_knvp BY kunnr.
  SORT it_bsid BY bukrs vkbur kunnr xref1.
  SORT i_giro BY bukrs vkbur kunnr xref1.
  SORT i_giro_sfa BY bukrs vkbur kunnr xref1.

  LOOP AT it_bsid.
    CLEAR itab4.
    MOVE it_bsid-vkbur TO itab4-gsber.
    MOVE it_bsid-xref1 TO itab4-xref1.
    MOVE p_gerdat(4) TO itab4-gjahr.

    ON CHANGE OF it_bsid-kunnr.
      LOOP AT i_giro WHERE vkbur EQ it_bsid-vkbur AND
                           kunnr EQ it_bsid-kunnr AND
                           xref1 EQ it_bsid-xref1.
        itab4-giro = itab4-giro + i_giro-cchek.
      ENDLOOP.
      LOOP AT i_giro_sfa WHERE vkbur EQ it_bsid-vkbur AND
                               kunnr EQ it_bsid-kunnr AND
                               xref1 EQ it_bsid-xref1.
        itab4-giro = itab4-giro + i_giro_sfa-bank_amt.
      ENDLOOP.
    ENDON.

    IF it_bsid-shkzg EQ 'H'.
      it_bsid-dmbtr = it_bsid-dmbtr * -1.
      IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
        it_bsid-zbd1t = 0.
      ENDIF.
    ENDIF.
    IF it_bsid-budat(6) LT p_gerdat(6).
      itab4-begin = itab4-begin + it_bsid-dmbtr.
    ENDIF.

** Koreksi by budi 07/09/2006 req. by SJT
*      IF it_bsid-blart NE 'DZ'.
    IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
       it_bsid-blart NE 'DR'.
** End koreksi by budi 07/09/2006 req. by SJT
      IF it_bsid-budat GE l_gerdat1 AND
         it_bsid-budat LT l_gerdat2.
        itab4-sales = itab4-sales + it_bsid-dmbtr.
      ENDIF.
    ELSE.
      IF it_bsid-budat GE l_gerdat1 AND
         it_bsid-budat LT l_gerdat2.
        itab4-payment = itab4-payment + it_bsid-dmbtr.
      ENDIF.
    ENDIF.
*      ENDIF.
    PERFORM due_brroute   TABLES lt_bsid.

    itab4-payment = itab4-payment.
    itab4-sales = itab4-sales .
    itab4-ending = itab4-begin + itab4-sales + ( itab4-payment ).
*   IF ITAB4-BEGIN NE 0 OR ITAB4-ENDING NE 0.
    COLLECT itab4.
  ENDLOOP.
ENDFORM.                    " SUM_BRROUTE

*&---------------------------------------------------------------------*
*&      Form  WRITE_BRROUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_brroute.
  DATA : l_lines TYPE i.

  DATA : lt_itab  LIKE itab4 OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_itab4 OCCURS 0.
          INCLUDE STRUCTURE itab4.
  DATA :   kunnr TYPE kunnr,
         END OF lt_itab4.
  DATA : BEGIN OF lt_kna1 OCCURS 0,
           kunnr  TYPE kunnr,
           name1  TYPE name1_gp,
         END OF lt_kna1.
  DATA : lv_kunnr  TYPE kunnr.
  DATA : lv_subrc  TYPE sy-subrc.

  lt_itab[] = itab4[].
  SORT lt_itab BY xref1.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING xref1.
  LOOP AT lt_itab.
    MOVE-CORRESPONDING lt_itab TO lt_itab4.
    lt_itab4-kunnr = lt_itab-xref1.
    APPEND lt_itab4.
  ENDLOOP.
  IF lt_itab4[] IS NOT INITIAL.
    SELECT kunnr name1
      FROM kna1
      INTO TABLE lt_kna1
      FOR ALL ENTRIES IN lt_itab4
      WHERE kunnr EQ lt_itab4-kunnr.
  ENDIF.

  DESCRIBE TABLE itab4 LINES l_lines.

  no = 0.
  IF count EQ 1.
** Added by Budi.P Bug program.
    CLEAR itab4.
    READ TABLE itab4 INDEX 1.
** End added by Budi.P Bug program.
    plant = itab4-gsber.
    page = 1.
    PERFORM write_header.
  ENDIF.

  SORT itab4 BY gsber xref1 gjahr.
  LOOP AT itab4.
    PERFORM f_check_write USING itab4-begin itab4-sales
                                itab4-payment itab4-ending
                                itab4-giro
                          CHANGING lv_subrc.
    IF lv_subrc IS INITIAL.
      IF count NE 1.
        ON CHANGE OF itab4-gsber.
          FORMAT COLOR OFF.
          plant = itab4-gsber.
          page = 1.
          PERFORM write_header.
        ENDON.
      ENDIF.
      PERFORM zebra.
      no = no + 1.

      CLEAR : lt_kna1, lv_kunnr.
      lv_kunnr  = itab4-xref1.
      READ TABLE lt_kna1 WITH KEY kunnr = lv_kunnr.
      PERFORM write_detail_brroute USING lt_kna1-name1.

      AT END OF gsber.
        SUM.
        SKIP 1.
        PERFORM subtotal3.
        IF sy-tabix GE l_lines.
          PERFORM write_bottom.
        ELSE.
          NEW-PAGE.
        ENDIF.
      ENDAT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " WRITE_BRROUTE

*&---------------------------------------------------------------------*
*&      Form  WRITE_DETAIL_BRROUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_detail_brroute USING fu_name1.
  c1 = 0.

  WRITE AT /(w1) itab4-xref1 HOTSPOT.c1 = c1 + w1 + 1.
  HIDE: itab4-gsber, itab4-xref1.
  WRITE AT c1(w2) fu_name1.c1 = c1 + w2 + 1.
*WRITE AT C1(W14) ITAB4-GJAHR.C1 = C1 + W14 + 1.
  WRITE AT c1(w3) itab4-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) itab4-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) itab4-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab4-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab4-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
*WRITE AT C1(W8) ITAB-LIMIT CURRENCY 'IDR'.C1 = C1 + W8 + 1.
  WRITE AT c1(w13)  itab4-due1 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
  WRITE AT c1(w10) itab4-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) itab4-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) itab4-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) itab4-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
ENDFORM.                    " WRITE_DETAIL_BRROUTE
*&---------------------------------------------------------------------*
*&      Form  SUBTOTAL3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM subtotal3.
  DATA text(40).
  c1 = 0.
  c1 = w1 + 1.
  CONCATENATE 'TOTAL' cab INTO text SEPARATED BY space.
  PERFORM format_total.
  WRITE AT /c1(w2) text.c1 = c1 + w2 + 1.
  WRITE AT c1(w3) itab4-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) itab4-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) itab4-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab4-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab4-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
*WRITE AT C1(W8) ITAB2-LIMIT CURRENCY 'IDR'.C1 = C1 + W8 + 1.
  WRITE AT c1(w13)  itab4-due1 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
  WRITE AT c1(w10) itab4-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) itab4-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) itab4-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) itab4-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.

ENDFORM.                                                    " SUBTOTAL3
*&---------------------------------------------------------------------*
*&      Form  GRAND_GSBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM grand_gsber.
  c1 = 4.
  SKIP 1.
  PERFORM format_total.
  WRITE AT /c1(w2) 'GRAND TOTAL'.c1 = c1 + w2 - 3.
  WRITE AT c1(w3) v_begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) v_sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) v_payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) v_ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) v_giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
*WRITE AT C1(W8) ITAB-LIMIT CURRENCY 'IDR'.C1 = C1 + W8 + 1.
  WRITE AT c1(w13)  v_due1 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
  WRITE AT c1(w10) v_due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) v_due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) v_due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) v_due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.

ENDFORM.                    " GRAND_GSBER
*&---------------------------------------------------------------------*
*&      Form  ZEBRA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM zebra.
  IF w16 = 1.
    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    w16 = 0.
  ELSE.
    FORMAT COLOR COL_NORMAL INTENSIFIED ON.
    w16 = 1.
  ENDIF.

ENDFORM.                    " ZEBRA
*&---------------------------------------------------------------------*
*&      Form  FORMAT_TOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM format_total.
  FORMAT COLOR COL_NORMAL INTENSIFIED ON.
  FORMAT COLOR OFF.
ENDFORM.                    " FORMAT_TOTAL
*&---------------------------------------------------------------------*
*&      Form  BULAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bulan.
  IF p_gerdat+4(2) EQ '01'.
    CONCATENATE 'JANUARI' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '02'.
    CONCATENATE 'FEBRUARI' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '03'.
    CONCATENATE 'MARET' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '04'.
    CONCATENATE 'APRIL' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '05'.
    CONCATENATE 'MEI' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '06'.
    CONCATENATE 'JUNI' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '07'.
    CONCATENATE 'JULI' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '08'.
    CONCATENATE 'AGUSTUS' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '09'.
    CONCATENATE 'SEPTEMBER' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '10'.
    CONCATENATE 'OKTOBER' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '11'.
    CONCATENATE 'NOVEMBER' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '12'.
    CONCATENATE 'DESEMBER' p_gerdat(4) INTO bulan SEPARATED BY space.
  ENDIF.
ENDFORM.                    " BULAN
*&---------------------------------------------------------------------*
*&      Form  DUE_BRROUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM due_brroute TABLES   ft_bsid STRUCTURE it_bsid.
  DATA age TYPE i.

  PERFORM get_date_dz.

  PERFORM f_age_calculate TABLES ft_bsid
                          USING it_bsid-bukrs it_bsid-vkbur
                                it_bsid-kunnr it_bsid-zuonr
                                'V' it_bsid-zfbdt it_bsid-zbd1t
                          CHANGING age.

  IF top EQ 'X'.
*    age = p_gerdat - it_bsid-zfbdt.
    IF age LE int1low.
      itab4-due1 = itab4-due1 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab4-due2 = itab4-due2 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab4-due3 = itab4-due3 + it_bsid-dmbtr.
    ELSEIF age GT int3low AND age LE int4low.
      itab4-due4 = itab4-due4 + it_bsid-dmbtr.
    ELSEIF age GT int4low.
      itab4-due5 = itab4-due5 + it_bsid-dmbtr.
    ENDIF.
  ELSE.
    IF age LE 0.
      itab4-due1 = itab4-due1 + it_bsid-dmbtr.
    ELSEIF age GE 1 AND age LE int1low.
      itab4-due2 = itab4-due2 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab4-due3 = itab4-due3 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab4-due4 = itab4-due4 + it_bsid-dmbtr.
    ELSEIF age GT int3low.
      itab4-due5 = itab4-due5 + it_bsid-dmbtr.
    ENDIF.
  ENDIF.
ENDFORM.                    " DUE_BRROUTE
*&---------------------------------------------------------------------*
*&      Form  CEK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek.
  DATA l_gsber LIKE bsid-gsber.

  l_gsber = s_gsber-low.

  IF l_gsber EQ space AND s_gsber-high EQ space.
    l_gsber = '*'.
  ELSEIF l_gsber NE space AND s_gsber-high NE space.
    l_gsber = '*'.
  ENDIF.

  AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
      ID 'GSBER' FIELD l_gsber
      ID 'ACTVT' FIELD '01'.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH
    'You have no authorization for Sales Office' l_gsber.
  ENDIF.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE i_zfchanel
    FROM zfchanel
    WHERE bukrs = p_bukrs AND
          vkbur IN s_gsber.

  READ TABLE i_zfchanel WITH KEY flag = 'X'.
  IF sy-subrc = 0.
    va_flag = i_zfchanel-flag.
  ENDIF.

ENDFORM.                    " CEK
*&---------------------------------------------------------------------*
*&      Form  GET_DATE_DZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_date_dz.
  IF it_bsid-blart EQ 'DZ' OR it_bsid-blart EQ 'DA' AND
     it_bsid-blart EQ 'DR'.
    READ TABLE it_bsid INTO wa_it_bsid
    WITH KEY zuonr = it_bsid-zuonr blart = 'RV'.
    IF sy-subrc EQ 0.
      it_bsid-zfbdt = wa_it_bsid-zfbdt.
      it_bsid-zbd1t = wa_it_bsid-zbd1t.
    ELSE.
      READ TABLE it_bsid INTO wa_it_bsid
      WITH KEY zuonr = it_bsid-zuonr blart = 'DR'.
      IF sy-subrc EQ 0.
        it_bsid-zfbdt = wa_it_bsid-zfbdt.
        it_bsid-zbd1t = wa_it_bsid-zbd1t.
      ELSE.
        READ TABLE it_bsid INTO wa_it_bsid
        WITH KEY zuonr = it_bsid-zuonr blart = 'DA'.
        IF sy-subrc EQ 0.
          it_bsid-zfbdt = wa_it_bsid-zfbdt.
          it_bsid-zbd1t = wa_it_bsid-zbd1t.
        ELSE.
          READ TABLE it_bsid INTO wa_it_bsid
          WITH KEY zuonr = it_bsid-zuonr blart = 'ZA'.
          IF sy-subrc EQ 0.
            it_bsid-zfbdt = wa_it_bsid-zfbdt.
            it_bsid-zbd1t = wa_it_bsid-zbd1t.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_DATE_DZ
*&---------------------------------------------------------------------*
*&      Form  GET_GIRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_giro.
  DATA: BEGIN OF lt_kunnr OCCURS 0,
        kunnr  LIKE kna1-kunnr.
  DATA: END OF lt_kunnr.
  DATA: BEGIN OF lt_salesman OCCURS 0.
          INCLUDE STRUCTURE knvp.
  DATA: END OF lt_salesman.
  DATA: BEGIN OF lt_routelist OCCURS 0.
          INCLUDE STRUCTURE knvp.
  DATA: END OF lt_routelist.

  DATA: ld_char(12) VALUE '0000000000',
        ld_char1(50),
        ld_subrc LIKE sy-subrc,
        ld_len   TYPE i.

  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE i_giro
  FROM zfbicheck AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr
                      JOIN kna1 AS c ON a~kunnr EQ c~kunnr
   WHERE a~bukrs EQ p_bukrs AND
         b~vkbur IN s_gsber AND
         pcair EQ space     AND
         a~kunnr IN s_kunnr.

  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE i_giro_sfa
  FROM zfbic_sfa AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr
                      JOIN kna1 AS c ON a~kunnr EQ c~kunnr
   WHERE a~bukrs EQ p_bukrs AND
         b~vkbur IN s_gsber AND
         pcair EQ space     AND
         a~kunnr IN s_kunnr.

  SORT i_giro BY kunnr.
  LOOP AT i_giro.
    lt_kunnr-kunnr = i_giro-kunnr.
    COLLECT lt_kunnr.
  ENDLOOP.

  SORT i_giro_sfa BY kunnr.
  LOOP AT i_giro_sfa.
    lt_kunnr-kunnr = i_giro_sfa-kunnr.
    COLLECT lt_kunnr.
  ENDLOOP.

  SORT lt_kunnr BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_kunnr COMPARING kunnr.

  IF lt_kunnr[] IS NOT INITIAL.
    SELECT kunnr vkorg vtweg spart parvw kunn2 pernr
    FROM knvp
    INTO CORRESPONDING FIELDS OF TABLE lt_routelist
    FOR ALL ENTRIES IN lt_kunnr
    WHERE kunnr EQ lt_kunnr-kunnr AND
          parvw EQ 'ZC'.
    IF sy-subrc EQ 0.
      SELECT kunnr vkorg vtweg spart parvw kunn2 pernr
      FROM knvp
      INTO CORRESPONDING FIELDS OF TABLE lt_salesman
      FOR ALL ENTRIES IN t_routelist
      WHERE kunnr EQ t_routelist-kunn2 AND
            parvw EQ 'ZP'.
    ENDIF.
  ENDIF.

  LOOP AT i_giro.
    CLEAR i_zfchanel.
    IF va_flag IS INITIAL.
      READ TABLE i_zfchanel WITH KEY bukrs = i_giro-bukrs
                                     vkbur = i_giro-vkbur
                                     kdgrp = i_giro-kdgrp.
      i_giro-channel = i_zfchanel-channel.
    ELSE.
      READ TABLE i_zfchanel WITH KEY bukrs = i_giro-bukrs
                                     vkbur = i_giro-vkbur
                                     brsch = i_giro-brsch.
      i_giro-channel = i_zfchanel-channel.
    ENDIF.

    READ TABLE lt_routelist WITH KEY kunnr = i_giro-kunnr
                                     parvw = 'ZC'.
    IF sy-subrc EQ 0.
      CONCATENATE ld_char lt_routelist-kunn2 INTO ld_char1.
      ld_len = STRLEN( ld_char1 ).
      ld_len = ld_len - 10.
      i_giro-xref1  = ld_char1+ld_len(10).
      READ TABLE lt_salesman WITH KEY kunnr = lt_routelist-kunn2
                                      parvw = 'ZP'.
      IF sy-subrc EQ 0.
        CONCATENATE ld_char lt_salesman-pernr INTO ld_char1.
        ld_len = STRLEN( ld_char1 ).
        ld_len = ld_len - 6.
        i_giro-xref2  = ld_char1+ld_len(6).
      ELSE.
        CLEAR: i_giro-xref2.
      ENDIF.
    ELSE.
      CLEAR: i_giro-xref1, i_giro-xref2.
    ENDIF.

    READ TABLE it_bsid WITH KEY bukrs = i_giro-bukrs
                                gjahr = i_giro-gjahr
                                belnr = i_giro-belnr.
    IF sy-subrc = 0.
      i_giro-anln1 = it_bsid-anln1.
    ELSE.
      CLEAR i_giro-anln1.
    ENDIF.
    MODIFY i_giro TRANSPORTING xref1 xref2 channel anln1.
  ENDLOOP.

  LOOP AT i_giro_sfa.
    CLEAR i_zfchanel.
    IF va_flag IS INITIAL.
      READ TABLE i_zfchanel WITH KEY bukrs = i_giro_sfa-bukrs
                                     vkbur = i_giro_sfa-vkbur
                                     kdgrp = i_giro_sfa-kdgrp.
      i_giro_sfa-channel = i_zfchanel-channel.
    ELSE.
      READ TABLE i_zfchanel WITH KEY bukrs = i_giro_sfa-bukrs
                                     vkbur = i_giro_sfa-vkbur
                                     brsch = i_giro_sfa-brsch.
      i_giro_sfa-channel = i_zfchanel-channel.
    ENDIF.

    READ TABLE lt_routelist WITH KEY kunnr = i_giro_sfa-kunnr
                                     parvw = 'ZC'.
    IF sy-subrc EQ 0.
      CONCATENATE ld_char lt_routelist-kunn2 INTO ld_char1.
      ld_len = STRLEN( ld_char1 ).
      ld_len = ld_len - 10.
      i_giro_sfa-xref1  = ld_char1+ld_len(10).
      READ TABLE lt_salesman WITH KEY kunnr = lt_routelist-kunn2
                                      parvw = 'ZP'.
      IF sy-subrc EQ 0.
        CONCATENATE ld_char lt_salesman-pernr INTO ld_char1.
        ld_len = STRLEN( ld_char1 ).
        ld_len = ld_len - 6.
        i_giro_sfa-xref2  = ld_char1+ld_len(6).
      ELSE.
        CLEAR: i_giro_sfa-xref2.
      ENDIF.
    ELSE.
      CLEAR: i_giro_sfa-xref1, i_giro_sfa-xref2.
    ENDIF.

    MODIFY i_giro_sfa TRANSPORTING xref1 xref2 channel anln1.
  ENDLOOP.
ENDFORM.                    " GET_GIRO

*&---------------------------------------------------------------------*
*&      Form  GET_AMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_amount.
  v_begin = v_begin + itab-begin.
  v_sales = v_sales + itab-sales.
  v_payment = v_payment + itab-payment.
  v_ending = v_ending + itab-ending.
  v_giro  = v_giro + itab-giro.
  v_due1 = v_due1 + itab-due1.
  v_due2 = v_due2 + itab-due2.
  v_due3 = v_due3 + itab-due3.
  v_due4 = v_due4 + itab-due4.
  v_due5 = v_due5 + itab-due5.

ENDFORM.                    " GET_AMOUNT
*&---------------------------------------------------------------------*
*&      Form  MOVE_AMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move_amount.
  itab-begin = v_begin.
  itab-sales = v_sales.
  itab-payment = v_payment.
  itab-ending = v_ending.
  itab-giro = v_giro.
  itab-limit = v_limit.
  itab-due1 = v_due1.
  itab-due2 = v_due2.
  itab-due3 = v_due3.
  itab-due4 = v_due4.
  itab-due5 = v_due5.
  CLEAR : v_begin,v_sales,v_payment,v_ending,v_giro,v_limit,v_due1,v_due2,
          v_due3,v_due4,v_due5.
ENDFORM.                    " MOVE_AMOUNT

*&---------------------------------------------------------------------*
*&      Form  SUM_INDUSTRY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sum_industry.

  DATA : l_cchek LIKE zfbicheck-cchek.
  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  lt_bsid[] = it_bsid[].
  SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

  SORT it_bsid BY bukrs vkbur kunnr brsch.
  SORT i_giro BY bukrs vkbur kunnr brsch.
  SORT i_giro_sfa BY bukrs vkbur kunnr brsch.

  LOOP AT it_bsid.
    CLEAR itab5.
    MOVE it_bsid-vkbur TO itab5-gsber.
    MOVE it_bsid-brsch TO itab5-brsch.
    MOVE p_gerdat(4) TO itab5-gjahr.

    ON CHANGE OF it_bsid-kunnr.
      LOOP AT i_giro WHERE vkbur EQ it_bsid-vkbur AND
                           kunnr EQ it_bsid-kunnr AND
                           brsch EQ it_bsid-brsch.
        itab5-giro = itab5-giro + i_giro-cchek.
      ENDLOOP.
      LOOP AT i_giro_sfa WHERE vkbur EQ it_bsid-vkbur AND
                               kunnr EQ it_bsid-kunnr AND
                               brsch EQ it_bsid-brsch.
        itab5-giro = itab5-giro + i_giro_sfa-bank_amt.
      ENDLOOP.
    ENDON.

    IF it_bsid-shkzg EQ 'H'.
      it_bsid-dmbtr = it_bsid-dmbtr * -1.
      IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
        it_bsid-zbd1t = 0.
      ENDIF.
    ENDIF.
    IF it_bsid-budat(6) LT p_gerdat(6).
      itab5-begin = itab5-begin + it_bsid-dmbtr.
    ENDIF.

** Koreksi by budi 07/09/2006 req. by SJT
*      IF it_bsid-blart NE 'DZ'.
    IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
       it_bsid-blart NE 'DR'.
** End koreksi by budi 07/09/2006 req. by SJT
      IF it_bsid-budat GE l_gerdat1 AND
         it_bsid-budat LT l_gerdat2.
        itab5-sales = itab5-sales + it_bsid-dmbtr.
      ENDIF.
    ELSE.
      IF it_bsid-budat GE l_gerdat1 AND
         it_bsid-budat LT l_gerdat2.
        itab5-payment = itab5-payment + it_bsid-dmbtr.
      ENDIF.
    ENDIF.
*      ENDIF.
    PERFORM due_industry TABLES lt_bsid.

    itab5-payment = itab5-payment.
    itab5-sales = itab5-sales.
    itab5-ending = itab5-begin + itab5-sales + ( itab5-payment ).
*   IF ITAB5-BEGIN NE 0 OR ITAB5-ENDING NE 0.
    COLLECT itab5.
  ENDLOOP.
ENDFORM.                    " SUM_INDUSTRY

*&---------------------------------------------------------------------*
*&      Form  WRITE_INDUSTRY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_industry.

  DATA : l_lines TYPE i.

  DATA : lt_itab  LIKE itab5 OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_t016t OCCURS 0,
           brsch  TYPE brsch,
           brtxt  TYPE text1_016t,
         END OF lt_t016t.

  DATA : lv_subrc   TYPE sy-subrc.

  lt_itab[] = itab5[].
  SORT lt_itab BY brsch.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING brsch.

  DESCRIBE TABLE itab5 LINES l_lines.

  no = 0.
  IF count EQ 1.
** Added by Budi.P Bug program.
    CLEAR itab5.
    READ TABLE itab5 INDEX 1.
** End added by Budi.P Bug program.
    plant = itab5-gsber.
    page = 1.
    PERFORM write_header.
  ENDIF.

  IF lt_itab[] IS NOT INITIAL.
    SELECT brsch brtxt
      FROM t016t
      INTO TABLE lt_t016t
      FOR ALL ENTRIES IN lt_itab
      WHERE spras EQ sy-langu
        AND brsch EQ lt_itab-brsch.
  ENDIF.

  SORT itab5 BY gsber brsch gjahr.
  LOOP AT itab5.
    PERFORM f_check_write USING itab5-begin itab5-sales
                                itab5-payment itab5-ending
                                itab5-giro
                          CHANGING lv_subrc.
    IF lv_subrc IS INITIAL.
      IF count NE 1.
        ON CHANGE OF itab5-gsber.
          FORMAT COLOR OFF.
          plant = itab5-gsber.
          page = 1.
          PERFORM write_header.
        ENDON.
      ENDIF.
      PERFORM zebra.
      no = no + 1.

      CLEAR lt_t016t.
      READ TABLE lt_t016t WITH KEY brsch = itab5-brsch.
      PERFORM write_detail_industry USING lt_t016t-brtxt.

      AT END OF gsber.
        SUM.
        SKIP 1.
        PERFORM subtotal4.
        IF sy-tabix GE l_lines.
          PERFORM write_bottom.
        ELSE.
          NEW-PAGE.
        ENDIF.
      ENDAT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " WRITE_INDUSTRY

*&---------------------------------------------------------------------*
*&      Form  DUE_INDUSTRY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM due_industry TABLES ft_bsid  STRUCTURE it_bsid.

  DATA age TYPE i.

  PERFORM get_date_dz.

  PERFORM f_age_calculate TABLES ft_bsid
                          USING it_bsid-bukrs it_bsid-vkbur
                                it_bsid-kunnr it_bsid-zuonr
                                'V' it_bsid-zfbdt it_bsid-zbd1t
                          CHANGING age.

  IF top EQ 'X'.
*    age = p_gerdat - it_bsid-zfbdt.
    IF age LE int1low.
      itab5-due1 = itab5-due1 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab5-due2 = itab5-due2 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab5-due3 = itab5-due3 + it_bsid-dmbtr.
    ELSEIF age GT int3low AND age LE int4low.
      itab5-due4 = itab5-due4 + it_bsid-dmbtr.
    ELSEIF age GT int4low.
      itab5-due5 = itab5-due5 + it_bsid-dmbtr.
    ENDIF.
  ELSE.
    IF age LE 0.
      itab5-due1 = itab5-due1 + it_bsid-dmbtr.
    ELSEIF age GE 1 AND age LE int1low.
      itab5-due2 = itab5-due2 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab5-due3 = itab5-due3 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab5-due4 = itab5-due4 + it_bsid-dmbtr.
    ELSEIF age GT int3low.
      itab5-due5 = itab5-due5 + it_bsid-dmbtr.
    ENDIF.
  ENDIF.

ENDFORM.                    " DUE_INDUSTRY

*&---------------------------------------------------------------------*
*&      Form  WRITE_DETAIL_INDUSTRY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_detail_industry USING fu_brtxt.

  DATA brtxt LIKE t016t-brtxt.
  c1 = 0.

  brtxt = fu_brtxt.

  WRITE AT /c1(w2) brtxt HOTSPOT.c1 = c1 + w2 + 1.
  HIDE: itab5-gsber, itab5-brsch.
*WRITE AT C1(W14) ITAB2-GJAHR.C1 = C1 + W14 + 1.
  WRITE AT c1(w3) itab5-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) itab5-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) itab5-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab5-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab5-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
*WRITE AT C1(W8) ITAB-LIMIT CURRENCY 'IDR'.C1 = C1 + W8 + 1.
  WRITE AT c1(w13)  itab5-due1 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
  WRITE AT c1(w10) itab5-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) itab5-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) itab5-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) itab5-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
ENDFORM.                    " WRITE_DETAIL_INDUSTRY

*&---------------------------------------------------------------------*
*&      Form  SUBTOTAL4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM subtotal4.

  DATA text(40).
  c1 = 0.
  c1 = 4.
  CONCATENATE 'TOTAL' cab INTO text SEPARATED BY space.
  PERFORM format_total.
  WRITE AT /c1(w2) text.c1 = c1 + w2 - 3.
  WRITE AT c1(w3) itab5-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) itab5-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) itab5-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab5-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab5-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
*WRITE AT C1(W8) ITAB5-LIMIT CURRENCY 'IDR'.C1 = C1 + W8 + 1.
  WRITE AT c1(w13)  itab5-due1 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
  WRITE AT c1(w10) itab5-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) itab5-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) itab5-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) itab5-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.

ENDFORM.                                                    " SUBTOTAL4

*&---------------------------------------------------------------------*
*&      Form  WRITE_BOTTOM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_bottom.
  SKIP 2.
  WRITE : / 'REMARKS :'.
  IF x_norm = 'X'.
    WRITE : / ' X  Normal Item'.
  ENDIF.
  IF x_shbv = 'X'.
    WRITE : / ' X  Special G/L Transaction :'.
    LOOP AT s_bschl.
      WRITE : s_bschl-low, space .
    ENDLOOP.
  ENDIF.
ENDFORM.                    " WRITE_BOTTOM

*&---------------------------------------------------------------------*
*&      Form  SUM_CHANNEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sum_channel.

  DATA : l_cchek LIKE zfbicheck-cchek.
  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  IF va_flag IS INITIAL.
    READ TABLE i_zfchanel WITH KEY bukrs = it_bsid-bukrs
                                   vkbur = it_bsid-vkbur
                                   kdgrp = it_bsid-kdgrp.
    it_bsid-channel = i_zfchanel-channel.
  ELSE.
    READ TABLE i_zfchanel WITH KEY bukrs = it_bsid-bukrs
                                   vkbur = it_bsid-vkbur
                                   brsch = it_bsid-brsch.
    it_bsid-channel = i_zfchanel-channel.
  ENDIF.

  lt_bsid[] = it_bsid[].
  SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

  IF va_flag IS INITIAL.
    SORT it_bsid BY bukrs vkbur kunnr kdgrp channel.
    SORT i_giro BY bukrs vkbur kunnr kdgrp channel.
    SORT i_giro_sfa BY bukrs vkbur kunnr kdgrp channel.

    LOOP AT it_bsid.
      CLEAR itab6.
      MOVE it_bsid-vkbur TO itab6-gsber.
      MOVE it_bsid-channel TO itab6-channel.
      MOVE it_bsid-kdgrp TO itab6-kdgrp.
      MOVE p_gerdat(4) TO itab6-gjahr.

      ON CHANGE OF it_bsid-kunnr.
        LOOP AT i_giro WHERE vkbur EQ it_bsid-vkbur AND
                             kunnr EQ it_bsid-kunnr AND
                             kdgrp EQ it_bsid-kdgrp AND
                             channel EQ it_bsid-channel.
          itab6-giro = itab6-giro + i_giro-cchek.
        ENDLOOP.
        LOOP AT i_giro_sfa WHERE vkbur EQ it_bsid-vkbur AND
                                 kunnr EQ it_bsid-kunnr AND
                                 kdgrp EQ it_bsid-kdgrp AND
                                 channel EQ it_bsid-channel.
          itab6-giro = itab6-giro + i_giro_sfa-bank_amt.
        ENDLOOP.
      ENDON.

      IF it_bsid-shkzg EQ 'H'.
        it_bsid-dmbtr = it_bsid-dmbtr * -1.
        IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
          it_bsid-zbd1t = 0.
        ENDIF.
      ENDIF.
      IF it_bsid-budat(6) LT p_gerdat(6).
        itab6-begin = itab6-begin + it_bsid-dmbtr.
      ENDIF.

*  * Koreksi by budi 07/09/2006 req. by SJT
*        IF it_bsid-blart NE 'DZ'.
      IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
         it_bsid-blart NE 'DR'.
*  * End koreksi by budi 07/09/2006 req. by SJT
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab6-sales = itab6-sales + it_bsid-dmbtr.
        ENDIF.
      ELSE.
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab6-payment = itab6-payment + it_bsid-dmbtr.
        ENDIF.
      ENDIF.
*        ENDIF.
      PERFORM due_channel TABLES lt_bsid.

      itab6-payment = itab6-payment.
      itab6-sales = itab6-sales.
      itab6-ending = itab6-begin + itab6-sales + ( itab6-payment ).
*     IF ITAB5-BEGIN NE 0 OR ITAB5-ENDING NE 0.
      COLLECT itab6.
    ENDLOOP.
  ELSE.
    SORT it_bsid BY bukrs vkbur kunnr channel brsch.
    SORT i_giro BY bukrs vkbur kunnr channel brsch.
    SORT i_giro_sfa BY bukrs vkbur kunnr channel brsch.

    LOOP AT it_bsid.
      CLEAR itab6.
      MOVE it_bsid-vkbur TO itab6-gsber.
      MOVE it_bsid-channel TO itab6-channel.
      MOVE it_bsid-brsch TO itab6-brsch.
      MOVE p_gerdat(4) TO itab6-gjahr.

      ON CHANGE OF it_bsid-kunnr.
        LOOP AT i_giro WHERE vkbur EQ it_bsid-vkbur AND
                             kunnr EQ it_bsid-kunnr AND
                             channel EQ it_bsid-channel AND
                             brsch EQ it_bsid-brsch.
          itab6-giro = itab6-giro + i_giro-cchek.
        ENDLOOP.
        LOOP AT i_giro_sfa WHERE vkbur EQ it_bsid-vkbur AND
                                 kunnr EQ it_bsid-kunnr AND
                                 channel EQ it_bsid-channel AND
                                 brsch EQ it_bsid-brsch.
          itab6-giro = itab6-giro + i_giro_sfa-bank_amt.
        ENDLOOP.
      ENDON.

      IF it_bsid-shkzg EQ 'H'.
        it_bsid-dmbtr = it_bsid-dmbtr * -1.
        IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
          it_bsid-zbd1t = 0.
        ENDIF.
      ENDIF.
      IF it_bsid-budat(6) LT p_gerdat(6).
        itab6-begin = itab6-begin + it_bsid-dmbtr.
      ENDIF.

*  * Koreksi by budi 07/09/2006 req. by SJT
*        IF it_bsid-blart NE 'DZ'.
      IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
         it_bsid-blart NE 'DR'.
*  * End koreksi by budi 07/09/2006 req. by SJT
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab6-sales = itab6-sales + it_bsid-dmbtr.
        ENDIF.
      ELSE.
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab6-payment = itab6-payment + it_bsid-dmbtr.
        ENDIF.
      ENDIF.
*        ENDIF.
      PERFORM due_channel TABLES lt_bsid.

      itab6-payment = itab6-payment.
      itab6-sales = itab6-sales.
      itab6-ending = itab6-begin + itab6-sales + ( itab6-payment ).
*     IF ITAB5-BEGIN NE 0 OR ITAB5-ENDING NE 0.
      COLLECT itab6.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " SUM_CHANNEL

*&---------------------------------------------------------------------*
*&      Form  WRITE_CHANNEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_channel.

  DATA : l_lines TYPE i.

  DATA : lt_itab  LIKE itab6 OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_t151t OCCURS 0,
           kdgrp  TYPE kdgrp,
           ktext  TYPE vtxtk,
         END OF lt_t151t.
  DATA : BEGIN OF lt_t016t OCCURS 0,
           brsch  TYPE brsch,
           brtxt  TYPE text1_016t,
         END OF lt_t016t.

  DATA : lv_subrc   TYPE sy-subrc.

  DESCRIBE TABLE itab6 LINES l_lines.

  no = 0.
  IF count EQ 1.
** Added by Budi.P Bug program.
    CLEAR itab6.
    READ TABLE itab6 INDEX 1.
** End added by Budi.P Bug program.
    plant = itab6-gsber.
    page = 1.
    PERFORM write_header.
  ENDIF.

  IF va_flag IS INITIAL.
    lt_itab[] = itab6[].
    SORT lt_itab BY kdgrp.
    DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING kdgrp.

    IF lt_itab[] IS NOT INITIAL.
      SELECT kdgrp ktext
        FROM t151t
        INTO TABLE lt_t151t
        FOR ALL ENTRIES IN lt_itab
        WHERE kdgrp EQ lt_itab-kdgrp AND
              spras EQ sy-langu.
    ENDIF.

    SORT itab6 BY gsber channel kdgrp gjahr.
    LOOP AT itab6.
      PERFORM f_check_write USING itab6-begin itab6-sales
                                  itab6-payment itab6-ending
                                  itab6-giro
                            CHANGING lv_subrc.
      IF lv_subrc IS INITIAL.
        IF count NE 1.
          ON CHANGE OF itab6-gsber.
            FORMAT COLOR OFF.
            plant = itab6-gsber.
            page = 1.
            PERFORM write_header.
          ENDON.
        ENDIF.
        PERFORM zebra.
        no = no + 1.

        CLEAR lt_t151t.
        READ TABLE lt_t151t WITH KEY kdgrp = itab6-kdgrp.

        PERFORM write_detail_channel USING lt_t151t-ktext ''.

        AT END OF channel.
          SUM.
          SKIP 1.
          PERFORM subtotal51.
          SKIP 1.
        ENDAT.

        AT END OF gsber.
          SUM.
          SKIP 1.
          PERFORM subtotal5.
          IF sy-tabix GE l_lines.
            PERFORM write_bottom.
          ELSE.
            NEW-PAGE.
          ENDIF.
        ENDAT.
      ENDIF.
    ENDLOOP.
  ELSE.
    lt_itab[] = itab6[].
    SORT lt_itab BY brsch.
    DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING brsch.

    IF lt_itab[] IS NOT INITIAL.
      SELECT brsch brtxt
        FROM t016t
        INTO TABLE lt_t016t
        FOR ALL ENTRIES IN lt_itab
        WHERE brsch EQ lt_itab-brsch AND
              spras EQ sy-langu.
    ENDIF.

    SORT itab6 BY gsber channel brsch gjahr.
    LOOP AT itab6.
      PERFORM f_check_write USING itab6-begin itab6-sales
                                  itab6-payment itab6-ending
                                  itab6-giro
                            CHANGING lv_subrc.
      IF lv_subrc IS INITIAL.
        IF count NE 1.
          ON CHANGE OF itab6-gsber.
            FORMAT COLOR OFF.
            plant = itab6-gsber.
            page = 1.
            PERFORM write_header.
          ENDON.
        ENDIF.
        PERFORM zebra.
        no = no + 1.

        CLEAR lt_t016t.
        READ TABLE lt_t016t WITH KEY brsch = itab6-brsch.

        PERFORM write_detail_channel USING '' lt_t016t-brtxt.

        AT END OF channel.
          SUM.
          SKIP 1.
          PERFORM subtotal51.
          SKIP 1.
        ENDAT.

        AT END OF gsber.
          SUM.
          SKIP 1.
          PERFORM subtotal5.
          IF sy-tabix GE l_lines.
            PERFORM write_bottom.
          ELSE.
            NEW-PAGE.
          ENDIF.
        ENDAT.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " WRITE_CHANNEL

*&---------------------------------------------------------------------*
*&      Form  DUE_CHANNEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM due_channel  TABLES ft_bsid  STRUCTURE it_bsid.

  DATA age TYPE i.

  PERFORM get_date_dz.

  PERFORM f_age_calculate TABLES ft_bsid
                          USING it_bsid-bukrs it_bsid-vkbur
                                it_bsid-kunnr it_bsid-zuonr
                                'V' it_bsid-zfbdt it_bsid-zbd1t
                          CHANGING age.

  IF top EQ 'X'.
*    age = p_gerdat - it_bsid-zfbdt.
    IF age LE int1low.
      itab6-due1 = itab6-due1 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab6-due2 = itab6-due2 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab6-due3 = itab6-due3 + it_bsid-dmbtr.
    ELSEIF age GT int3low AND age LE int4low.
      itab6-due4 = itab6-due4 + it_bsid-dmbtr.
    ELSEIF age GT int4low.
      itab6-due5 = itab6-due5 + it_bsid-dmbtr.
    ENDIF.
  ELSE.
    IF age LE 0.
      itab6-due1 = itab6-due1 + it_bsid-dmbtr.
    ELSEIF age GE 1 AND age LE int1low.
      itab6-due2 = itab6-due2 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab6-due3 = itab6-due3 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab6-due4 = itab6-due4 + it_bsid-dmbtr.
    ELSEIF age GT int3low.
      itab6-due5 = itab6-due5 + it_bsid-dmbtr.
    ENDIF.
  ENDIF.

ENDFORM.                    " DUE_CHANNEL

*&---------------------------------------------------------------------*
*&      Form  WRITE_DETAIL_CHANNEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_detail_channel USING fu_ktext fu_brtxt.

  DATA: BEGIN OF l_channel,
          data1(5),
          data2(1),
          data3(2),
          data4(1),
          data5(20),
        END OF l_channel.

  DATA: BEGIN OF l_channel1,
          data1(5),
          data2(1),
          data3(4),
          data4(1),
          data5(20),
        END OF l_channel1.

  c1 = 0.
  IF va_flag IS INITIAL.
    l_channel-data1 = itab6-channel.
    l_channel-data2 = ' '.
    l_channel-data3 = itab6-kdgrp.
    l_channel-data4 = '.'.
    l_channel-data5 = fu_ktext.
    WRITE AT /c1(w2) l_channel HOTSPOT.c1 = c1 + w2 + 1.
  ELSE.
    l_channel1-data1 = itab6-channel.
    l_channel1-data2 = ' '.
    l_channel1-data3 = itab6-brsch.
    l_channel1-data4 = '.'.
    l_channel1-data5 = fu_brtxt.
    WRITE AT /c1(w2) l_channel1 HOTSPOT.c1 = c1 + w2 + 1.
  ENDIF.

  HIDE: itab6-gsber, itab6-channel, itab6-kdgrp, itab6-brsch.
*WRITE AT C1(W14) ITAB2-GJAHR.C1 = C1 + W14 + 1.
  WRITE AT c1(w3) itab6-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) itab6-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) itab6-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab6-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab6-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
*WRITE AT C1(W8) ITAB-LIMIT CURRENCY 'IDR'.C1 = C1 + W8 + 1.
  WRITE AT c1(w13)  itab6-due1 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
  WRITE AT c1(w10) itab6-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) itab6-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) itab6-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) itab6-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
ENDFORM.                    " WRITE_DETAIL_CHANNEL

*&---------------------------------------------------------------------*
*&      Form  SUBTOTAL5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM subtotal5.

  DATA text(40).
  c1 = 0.
  c1 = 4.
  CONCATENATE 'TOTAL' cab INTO text SEPARATED BY space.
  PERFORM format_total.
  WRITE AT /c1(w2) text.c1 = c1 + w2 - 3.
  WRITE AT c1(w3) itab6-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) itab6-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) itab6-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab6-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab6-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
*WRITE AT C1(W8) ITAB6-LIMIT CURRENCY 'IDR'.C1 = C1 + W8 + 1.
  WRITE AT c1(w13)  itab6-due1 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
  WRITE AT c1(w10) itab6-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) itab6-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) itab6-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) itab6-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.

ENDFORM.                                                    " SUBTOTAL5

*&---------------------------------------------------------------------*
*&      Form  SUBTOTAL51
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM subtotal51.

  DATA text(40).
  c1 = 0.
  c1 = 4.
  CONCATENATE 'TOTAL' itab6-channel INTO text SEPARATED BY space.
  PERFORM format_total.
  WRITE AT /c1(w2) text.c1 = c1 + w2 - 3.
  WRITE AT c1(w3) itab6-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) itab6-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) itab6-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab6-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab6-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
*WRITE AT C1(W8) ITAB6-LIMIT CURRENCY 'IDR'.C1 = C1 + W8 + 1.
  WRITE AT c1(w13)  itab6-due1 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
  WRITE AT c1(w10) itab6-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) itab6-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) itab6-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) itab6-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.

ENDFORM.                                                    " SUBTOTAL51

*&---------------------------------------------------------------------*
*&      Form  f_choose
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_choose.
  DATA : ffield(20),
         fvalue(40),
         fcust(10),
         chr TYPE i,
         l_live(1).

  CLEAR: it_choosekey,
         it_choosecust.
  REFRESH: it_choosekey, it_choosecust, itab.

  GET CURSOR FIELD ffield VALUE fvalue.
  IF ffield EQ 'ITAB-KUNNR'.
    READ CURRENT LINE FIELD VALUE: itab-gsber.
    SELECT SINGLE b~live
    FROM tvkol AS a JOIN zplbc AS b ON a~werks = b~werks AND
                                       a~lgort = b~lgort
    INTO l_live
    WHERE b~bukrs EQ p_bukrs    AND
          a~vstel EQ itab-gsber AND
          b~live  EQ space.
    IF sy-subrc EQ 0.
      SELECT SINGLE kunnr
      FROM kna1
      INTO fvalue
      WHERE sortl  EQ fvalue.
    ENDIF.
    PERFORM f_detail_kunnr USING fvalue.
  ELSE.
    CASE 'X'.
      WHEN radio1.
        PERFORM f_choose1.      "Branch
      WHEN radio2.
        PERFORM f_choose2.      "Customer
      WHEN radio3.
        PERFORM f_choose3.      "Customer Group
      WHEN radio4.
        PERFORM f_choose4.      "Salesman
      WHEN radio5.
        PERFORM f_choose5.      "Route list
      WHEN radio6.
        PERFORM f_choose6.      "Industry
      WHEN radio7.
        PERFORM f_choose7.      "Channel
      WHEN radio8.
        PERFORM f_choose8.      "Sub Customer Group
      WHEN radio9.
        PERFORM f_choose9.
    ENDCASE.

    PERFORM write_brcust.
  ENDIF.

  CLEAR: itab, it_choosekey, it_choosecust.
  REFRESH: itab, it_choosekey, it_choosecust.

ENDFORM.                    " f_choose

*&---------------------------------------------------------------------*
*&      Form  f_choose1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_choose1.

  DATA : l_cchek LIKE zfbicheck-cchek,
         l_limit TYPE p.

  DATA : lt_itab  LIKE it_choosekey OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_knkk OCCURS 0,
           kunnr  TYPE kunnr,
           klimk  TYPE klimk,
         END OF lt_knkk.

  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  it_choosekey[] = it_choose[].
  DELETE it_choosekey WHERE gsber NE itab1-gsber.
  DELETE ADJACENT DUPLICATES FROM it_choosekey
         COMPARING gsber kunnr.

  lt_itab[] = it_choosekey[].
  SORT lt_itab BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING kunnr.
  IF lt_itab[] IS NOT INITIAL.
    SELECT kunnr klimk
      FROM knkk
      INTO TABLE lt_knkk
      FOR ALL ENTRIES IN lt_itab
      WHERE kunnr EQ lt_itab-kunnr.
  ENDIF.

  LOOP AT it_choosekey.
    CLEAR itab.
    MOVE it_choosekey-gsber TO itab-gsber.
    MOVE it_choosekey-kunnr TO itab-kunnr.
    MOVE p_gerdat(4) TO itab-gjahr.

    READ TABLE lt_knkk WITH KEY kunnr = it_choosekey-kunnr.
    IF sy-subrc EQ 0.
      itab-limit  = lt_knkk-klimk.
    ENDIF.

    l_limit = itab-limit * 100.
    IF l_limit >= 99999999999999.
      itab-limit = 0.
    ENDIF.

    LOOP AT i_giro WHERE kunnr EQ it_choosekey-kunnr AND
                         vkbur EQ it_choosekey-gsber.
      itab-giro = itab-giro + i_giro-cchek.
    ENDLOOP.

    LOOP AT i_giro_sfa WHERE kunnr EQ it_choosekey-kunnr AND
                             vkbur EQ it_choosekey-gsber.
      itab-giro = itab-giro + i_giro_sfa-bank_amt.
    ENDLOOP.

    lt_bsid[] = it_bsid[].
    SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

    LOOP AT it_bsid WHERE vkbur EQ it_choosekey-gsber AND
                          kunnr EQ it_choosekey-kunnr.

      IF it_bsid-shkzg EQ 'H'.
        it_bsid-dmbtr = it_bsid-dmbtr * -1.
        IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
          it_bsid-zbd1t = 0.
        ENDIF.
      ENDIF.
      IF it_bsid-budat(6) LT p_gerdat(6).
        itab-begin = itab-begin + it_bsid-dmbtr.
      ENDIF.

** Koreksi by budi 07/09/2006 req. by SJT
*      IF it_bsid-blart NE 'DZ'.
      IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
         it_bsid-blart NE 'DR'.
** End koreksi by budi 07/09/2006 req. by SJT
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab-sales = itab-sales + it_bsid-dmbtr.
        ENDIF.
      ELSE.
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab-payment = itab-payment + it_bsid-dmbtr.
        ENDIF.
      ENDIF.
*      ENDIF.

      PERFORM due_branch TABLES lt_bsid.

      MOVE it_bsid-sortl TO itab-sortl.
    ENDLOOP.

    itab-payment = itab-payment.
    itab-sales =  itab-sales.
    itab-ending = itab-begin + itab-sales + ( itab-payment ).
*   IF ITAB-BEGIN NE 0 OR ITAB-ENDING NE 0.
    IF itab-begin NE 0 OR itab-ending NE 0 OR
       itab-sales NE 0 OR itab-payment NE 0.
      APPEND itab.
    ENDIF.
  ENDLOOP.
ENDFORM.                                                    " f_choose1

*&---------------------------------------------------------------------*
*&      Form  f_choose2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_choose2.

  DATA : l_cchek LIKE zfbicheck-cchek,
         l_limit TYPE p.

  DATA : lt_itab  LIKE it_choosekey OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_knkk OCCURS 0,
           kunnr  TYPE kunnr,
           klimk  TYPE klimk,
         END OF lt_knkk.

  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  it_choosekey[] = it_choose[].
  DELETE it_choosekey WHERE kunnr NE itab-kunnr.
  DELETE it_choosekey WHERE gsber NE itab-gsber.
  DELETE ADJACENT DUPLICATES FROM it_choosekey
         COMPARING gsber kunnr.

  lt_itab[] = it_choosekey[].
  SORT lt_itab BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING kunnr.
  IF lt_itab[] IS NOT INITIAL.
    SELECT kunnr klimk
      FROM knkk
      INTO TABLE lt_knkk
      FOR ALL ENTRIES IN lt_itab
      WHERE kunnr EQ lt_itab-kunnr.
  ENDIF.

  LOOP AT it_choosekey.
    CLEAR itab.
    MOVE it_choosekey-gsber TO itab-gsber.
    MOVE it_choosekey-kunnr TO itab-kunnr.
    MOVE p_gerdat(4) TO itab-gjahr.

    READ TABLE lt_knkk WITH KEY kunnr = it_choosekey-kunnr.
    IF sy-subrc EQ 0.
      itab-limit  = lt_knkk-klimk.
    ENDIF.

    l_limit = itab-limit * 100.
    IF l_limit >= 99999999999999.
      itab-limit = 0.
    ENDIF.

    LOOP AT i_giro WHERE kunnr EQ it_choosekey-kunnr AND
                         vkbur EQ it_choosekey-gsber.
      itab-giro = itab-giro + i_giro-cchek.
    ENDLOOP.

    LOOP AT i_giro_sfa WHERE kunnr EQ it_choosekey-kunnr AND
                             vkbur EQ it_choosekey-gsber.
      itab-giro = itab-giro + i_giro_sfa-bank_amt.
    ENDLOOP.

    lt_bsid[] = it_bsid[].
    SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

    LOOP AT it_bsid WHERE vkbur EQ it_choosekey-gsber AND
                          kunnr EQ it_choosekey-kunnr.

      IF it_bsid-shkzg EQ 'H'.
        it_bsid-dmbtr = it_bsid-dmbtr * -1.
        IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
          it_bsid-zbd1t = 0.
        ENDIF.
      ENDIF.
      IF it_bsid-budat(6) LT p_gerdat(6).
        itab-begin = itab-begin + it_bsid-dmbtr.
      ENDIF.

** Koreksi by budi 07/09/2006 req. by SJT
*      IF it_bsid-blart NE 'DZ'.
      IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
         it_bsid-blart NE 'DR'.
** End koreksi by budi 07/09/2006 req. by SJT
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab-sales = itab-sales + it_bsid-dmbtr.
        ENDIF.
      ELSE.
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab-payment = itab-payment + it_bsid-dmbtr.
        ENDIF.
      ENDIF.
*      ENDIF.

      PERFORM due_branch  TABLES lt_bsid.

      MOVE it_bsid-sortl TO itab-sortl.
    ENDLOOP.

    itab-payment = itab-payment.
    itab-sales =  itab-sales.
    itab-ending = itab-begin + itab-sales + ( itab-payment ).
*   IF ITAB-BEGIN NE 0 OR ITAB-ENDING NE 0.
    IF itab-begin NE 0 OR itab-ending NE 0 OR
       itab-sales NE 0 OR itab-payment NE 0.
      APPEND itab.
    ENDIF.
  ENDLOOP.
ENDFORM.                                                    " f_choose2

*&---------------------------------------------------------------------*
*&      Form  f_choose3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_choose3.

  DATA : l_cchek LIKE zfbicheck-cchek,
         l_limit TYPE p.

  DATA : lt_itab  LIKE it_choosekey OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_knkk OCCURS 0,
           kunnr  TYPE kunnr,
           klimk  TYPE klimk,
         END OF lt_knkk.

  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  it_choosekey[] = it_choose[].
  DELETE it_choosekey WHERE kdgrp NE itab2-kdgrp.
  DELETE it_choosekey WHERE gsber NE itab2-gsber.
  DELETE ADJACENT DUPLICATES FROM it_choosekey
         COMPARING gsber kunnr kdgrp.

  lt_itab[] = it_choosekey[].
  SORT lt_itab BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING kunnr.
  IF lt_itab[] IS NOT INITIAL.
    SELECT kunnr klimk
      FROM knkk
      INTO TABLE lt_knkk
      FOR ALL ENTRIES IN lt_itab
      WHERE kunnr EQ lt_itab-kunnr.
  ENDIF.

  LOOP AT it_choosekey.
    CLEAR itab.
    MOVE it_choosekey-gsber TO itab-gsber.
    MOVE it_choosekey-kunnr TO itab-kunnr.
    MOVE p_gerdat(4) TO itab-gjahr.

    READ TABLE lt_knkk WITH KEY kunnr = it_choosekey-kunnr.
    IF sy-subrc EQ 0.
      itab-limit  = lt_knkk-klimk.
    ENDIF.

    l_limit = itab-limit * 100.
    IF l_limit >= 99999999999999.
      itab-limit = 0.
    ENDIF.

    LOOP AT i_giro WHERE kunnr EQ it_choosekey-kunnr AND
                         vkbur EQ it_choosekey-gsber AND
                         kdgrp EQ it_choosekey-kdgrp.
      itab-giro = itab-giro + i_giro-cchek.
    ENDLOOP.

    LOOP AT i_giro_sfa WHERE kunnr EQ it_choosekey-kunnr AND
                             vkbur EQ it_choosekey-gsber AND
                             kdgrp EQ it_choosekey-kdgrp.
      itab-giro = itab-giro + i_giro_sfa-bank_amt.
    ENDLOOP.

    lt_bsid[] = it_bsid[].
    SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

    LOOP AT it_bsid WHERE vkbur EQ it_choosekey-gsber AND
                          kunnr EQ it_choosekey-kunnr AND
                          kdgrp EQ it_choosekey-kdgrp.

      IF it_bsid-shkzg EQ 'H'.
        it_bsid-dmbtr = it_bsid-dmbtr * -1.
        IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
          it_bsid-zbd1t = 0.
        ENDIF.
      ENDIF.
      IF it_bsid-budat(6) LT p_gerdat(6).
        itab-begin = itab-begin + it_bsid-dmbtr.
      ENDIF.

** Koreksi by budi 07/09/2006 req. by SJT
*      IF it_bsid-blart NE 'DZ'.
      IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
         it_bsid-blart NE 'DR'.
** End koreksi by budi 07/09/2006 req. by SJT
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab-sales = itab-sales + it_bsid-dmbtr.
        ENDIF.
      ELSE.
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab-payment = itab-payment + it_bsid-dmbtr.
        ENDIF.
      ENDIF.
*      ENDIF.

      PERFORM due_branch TABLES lt_bsid.

      MOVE it_bsid-sortl TO itab-sortl.
    ENDLOOP.

    itab-payment = itab-payment.
    itab-sales =  itab-sales.
    itab-ending = itab-begin + itab-sales + ( itab-payment ).
*   IF ITAB-BEGIN NE 0 OR ITAB-ENDING NE 0.
    IF itab-begin NE 0 OR itab-ending NE 0 OR
       itab-sales NE 0 OR itab-payment NE 0.
      APPEND itab.
    ENDIF.
  ENDLOOP.
ENDFORM.                                                    " f_choose3

*&---------------------------------------------------------------------*
*&      Form  f_choose4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_choose4.

  DATA : l_cchek LIKE zfbicheck-cchek,
         l_limit TYPE p.

  DATA : lt_itab  LIKE it_choosekey OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_knkk OCCURS 0,
           kunnr  TYPE kunnr,
           klimk  TYPE klimk,
         END OF lt_knkk.

  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  it_choosekey[] = it_choose[].
  DELETE it_choosekey WHERE xref2 NE itab3-xref2.
  DELETE it_choosekey WHERE gsber NE itab3-gsber.
  DELETE ADJACENT DUPLICATES FROM it_choosekey
         COMPARING gsber kunnr xref2.

  lt_itab[] = it_choosekey[].
  SORT lt_itab BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING kunnr.
  IF lt_itab[] IS NOT INITIAL.
    SELECT kunnr klimk
      FROM knkk
      INTO TABLE lt_knkk
      FOR ALL ENTRIES IN lt_itab
      WHERE kunnr EQ lt_itab-kunnr.
  ENDIF.

  LOOP AT it_choosekey.
    CLEAR itab.
    MOVE it_choosekey-gsber TO itab-gsber.
    MOVE it_choosekey-kunnr TO itab-kunnr.
    MOVE p_gerdat(4) TO itab-gjahr.

    READ TABLE lt_knkk WITH KEY kunnr = it_choosekey-kunnr.
    IF sy-subrc EQ 0.
      itab-limit  = lt_knkk-klimk.
    ENDIF.

    l_limit = itab-limit * 100.
    IF l_limit >= 99999999999999.
      itab-limit = 0.
    ENDIF.

    LOOP AT i_giro WHERE kunnr EQ it_choosekey-kunnr AND
                         vkbur EQ it_choosekey-gsber.
      IF i_giro-slcod+4(6) = it_choosekey-xref2.
        itab-giro = itab-giro + i_giro-cchek.
      ENDIF.
    ENDLOOP.

    LOOP AT i_giro_sfa WHERE kunnr EQ it_choosekey-kunnr AND
                             vkbur EQ it_choosekey-gsber.
      IF i_giro_sfa-slscd+4(6) = it_choosekey-xref2.
        itab-giro = itab-giro + i_giro_sfa-bank_amt.
      ENDIF.
    ENDLOOP.

    lt_bsid[] = it_bsid[].
    SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

    LOOP AT it_bsid WHERE vkbur EQ it_choosekey-gsber AND
                          kunnr EQ it_choosekey-kunnr AND
                          xref2 EQ it_choosekey-xref2.

      IF it_bsid-shkzg EQ 'H'.
        it_bsid-dmbtr = it_bsid-dmbtr * -1.
        IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
          it_bsid-zbd1t = 0.
        ENDIF.
      ENDIF.
      IF it_bsid-budat(6) LT p_gerdat(6).
        itab-begin = itab-begin + it_bsid-dmbtr.
      ENDIF.

** Koreksi by budi 07/09/2006 req. by SJT
*      IF it_bsid-blart NE 'DZ'.
      IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
         it_bsid-blart NE 'DR'.
** End koreksi by budi 07/09/2006 req. by SJT
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab-sales = itab-sales + it_bsid-dmbtr.
        ENDIF.
      ELSE.
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab-payment = itab-payment + it_bsid-dmbtr.
        ENDIF.
      ENDIF.
*      ENDIF.

      PERFORM due_branch  TABLES lt_bsid.

      MOVE it_bsid-sortl TO itab-sortl.
    ENDLOOP.

    itab-payment = itab-payment.
    itab-sales =  itab-sales.
    itab-ending = itab-begin + itab-sales + ( itab-payment ).
*   IF ITAB-BEGIN NE 0 OR ITAB-ENDING NE 0.
    IF itab-begin NE 0 OR itab-ending NE 0 OR
       itab-sales NE 0 OR itab-payment NE 0.
      APPEND itab.
    ENDIF.

  ENDLOOP.

ENDFORM.                                                    " f_choose4

*&---------------------------------------------------------------------*
*&      Form  f_choose5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_choose5.

  DATA : l_cchek LIKE zfbicheck-cchek,
         l_limit TYPE p.

  DATA : lt_itab  LIKE it_choosekey OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_knkk OCCURS 0,
           kunnr  TYPE kunnr,
           klimk  TYPE klimk,
         END OF lt_knkk.

  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  it_choosekey[] = it_choose[].
  DELETE it_choosekey WHERE xref1 NE itab4-xref1.
  DELETE it_choosekey WHERE gsber NE itab4-gsber.
  DELETE ADJACENT DUPLICATES FROM it_choosekey
         COMPARING gsber kunnr xref1.

  lt_itab[] = it_choosekey[].
  SORT lt_itab BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING kunnr.
  IF lt_itab[] IS NOT INITIAL.
    SELECT kunnr klimk
      FROM knkk
      INTO TABLE lt_knkk
      FOR ALL ENTRIES IN lt_itab
      WHERE kunnr EQ lt_itab-kunnr.
  ENDIF.

  LOOP AT it_choosekey.
    CLEAR itab.
    MOVE it_choosekey-gsber TO itab-gsber.
    MOVE it_choosekey-kunnr TO itab-kunnr.
    MOVE p_gerdat(4) TO itab-gjahr.

    READ TABLE lt_knkk WITH KEY kunnr = it_choosekey-kunnr.
    IF sy-subrc EQ 0.
      itab-limit  = lt_knkk-klimk.
    ENDIF.

    l_limit = itab-limit * 100.
    IF l_limit >= 99999999999999.
      itab-limit = 0.
    ENDIF.

    LOOP AT i_giro WHERE kunnr EQ it_choosekey-kunnr AND
                         vkbur EQ it_choosekey-gsber.
      itab-giro = itab-giro + i_giro-cchek.
    ENDLOOP.

    LOOP AT i_giro_sfa WHERE kunnr EQ it_choosekey-kunnr AND
                             vkbur EQ it_choosekey-gsber.
      itab-giro = itab-giro + i_giro_sfa-bank_amt.
    ENDLOOP.

    lt_bsid[] = it_bsid[].
    SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

    LOOP AT it_bsid WHERE vkbur EQ it_choosekey-gsber AND
                          kunnr EQ it_choosekey-kunnr AND
                          xref1 EQ it_choosekey-xref1.

      IF it_bsid-shkzg EQ 'H'.
        it_bsid-dmbtr = it_bsid-dmbtr * -1.
        IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
          it_bsid-zbd1t = 0.
        ENDIF.
      ENDIF.
      IF it_bsid-budat(6) LT p_gerdat(6).
        itab-begin = itab-begin + it_bsid-dmbtr.
      ENDIF.

** Koreksi by budi 07/09/2006 req. by SJT
*      IF it_bsid-blart NE 'DZ'.
      IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
         it_bsid-blart NE 'DR'.
** End koreksi by budi 07/09/2006 req. by SJT
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab-sales = itab-sales + it_bsid-dmbtr.
        ENDIF.
      ELSE.
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab-payment = itab-payment + it_bsid-dmbtr.
        ENDIF.
      ENDIF.
*      ENDIF.

      PERFORM due_branch  TABLES lt_bsid.

      MOVE it_bsid-sortl TO itab-sortl.
    ENDLOOP.

    itab-payment = itab-payment.
    itab-sales =  itab-sales.
    itab-ending = itab-begin + itab-sales + ( itab-payment ).
*   IF ITAB-BEGIN NE 0 OR ITAB-ENDING NE 0.
    IF itab-begin NE 0 OR itab-ending NE 0 OR
       itab-sales NE 0 OR itab-payment NE 0.
      APPEND itab.
    ENDIF.

  ENDLOOP.

ENDFORM.                                                    " f_choose5

*&---------------------------------------------------------------------*
*&      Form  f_choose6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_choose6.

  DATA : l_cchek LIKE zfbicheck-cchek,
         l_limit TYPE p.

  DATA : lt_itab  LIKE it_choosekey OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_knkk OCCURS 0,
           kunnr  TYPE kunnr,
           klimk  TYPE klimk,
         END OF lt_knkk.
  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  it_choosekey[] = it_choose[].
  DELETE it_choosekey WHERE brsch NE itab5-brsch.
  DELETE it_choosekey WHERE gsber NE itab5-gsber.
  DELETE ADJACENT DUPLICATES FROM it_choosekey
         COMPARING gsber kunnr brsch.

  lt_itab[] = it_choosekey[].
  SORT lt_itab BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING kunnr.
  IF lt_itab[] IS NOT INITIAL.
    SELECT kunnr klimk
      FROM knkk
      INTO TABLE lt_knkk
      FOR ALL ENTRIES IN lt_itab
      WHERE kunnr EQ lt_itab-kunnr.
  ENDIF.

  LOOP AT it_choosekey.
    CLEAR itab.
    MOVE it_choosekey-gsber TO itab-gsber.
    MOVE it_choosekey-kunnr TO itab-kunnr.
    MOVE p_gerdat(4) TO itab-gjahr.

    READ TABLE lt_knkk WITH KEY kunnr = it_choosekey-kunnr.
    IF sy-subrc EQ 0.
      itab-limit  = lt_knkk-klimk.
    ENDIF.

    l_limit = itab-limit * 100.
    IF l_limit >= 99999999999999.
      itab-limit = 0.
    ENDIF.

    LOOP AT i_giro WHERE kunnr EQ it_choosekey-kunnr AND
                         vkbur EQ it_choosekey-gsber AND
                         brsch EQ it_choosekey-brsch.
      itab-giro = itab-giro + i_giro-cchek.
    ENDLOOP.

    LOOP AT i_giro_sfa WHERE kunnr EQ it_choosekey-kunnr AND
                             vkbur EQ it_choosekey-gsber AND
                             brsch EQ it_choosekey-brsch.
      itab-giro = itab-giro + i_giro_sfa-bank_amt.
    ENDLOOP.

    lt_bsid[] = it_bsid[].
    SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

    LOOP AT it_bsid WHERE vkbur EQ it_choosekey-gsber AND
                          kunnr EQ it_choosekey-kunnr AND
                          brsch EQ it_choosekey-brsch.

      IF it_bsid-shkzg EQ 'H'.
        it_bsid-dmbtr = it_bsid-dmbtr * -1.
        IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
          it_bsid-zbd1t = 0.
        ENDIF.
      ENDIF.
      IF it_bsid-budat(6) LT p_gerdat(6).
        itab-begin = itab-begin + it_bsid-dmbtr.
      ENDIF.

** Koreksi by budi 07/09/2006 req. by SJT
*      IF it_bsid-blart NE 'DZ'.
      IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
         it_bsid-blart NE 'DR'.
** End koreksi by budi 07/09/2006 req. by SJT
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab-sales = itab-sales + it_bsid-dmbtr.
        ENDIF.
      ELSE.
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab-payment = itab-payment + it_bsid-dmbtr.
        ENDIF.
      ENDIF.
*      ENDIF.

      PERFORM due_branch  TABLES lt_bsid.

      MOVE it_bsid-sortl TO itab-sortl.
    ENDLOOP.

    itab-payment = itab-payment.
    itab-sales =  itab-sales.
    itab-ending = itab-begin + itab-sales + ( itab-payment ).
*   IF ITAB-BEGIN NE 0 OR ITAB-ENDING NE 0.
    IF itab-begin NE 0 OR itab-ending NE 0 OR
       itab-sales NE 0 OR itab-payment NE 0.
      APPEND itab.
    ENDIF.

  ENDLOOP.

ENDFORM.                                                    " f_choose6

*&---------------------------------------------------------------------*
*&      Form  itab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM itab.
  APPEND LINES OF itab TO itab_1.
  DELETE itab_1 WHERE due1 EQ 0.
  APPEND LINES OF itab TO itab_2.
  DELETE itab_2 WHERE due2 EQ 0.
  APPEND LINES OF itab TO itab_3.
  DELETE itab_3 WHERE due3 EQ 0.
  APPEND LINES OF itab TO itab_4.
  DELETE itab_4 WHERE due4 EQ 0.
  APPEND LINES OF itab TO itab_5.
  DELETE itab_5 WHERE due5 EQ 0.

  REFRESH itab. CLEAR itab.

  IF int1 EQ 'X'.
    APPEND LINES OF itab_1 TO itab.
  ENDIF.
  IF int2 EQ 'X'.
    APPEND LINES OF itab_2 TO itab.
  ENDIF.
  IF int3 EQ 'X'.
    APPEND LINES OF itab_3 TO itab.
  ENDIF.
  IF int4 EQ 'X'.
    APPEND LINES OF itab_4 TO itab.
  ENDIF.
  IF int5 EQ 'X'.
    APPEND LINES OF itab_5 TO itab.
  ENDIF.

  SORT itab.
  DELETE ADJACENT DUPLICATES FROM itab COMPARING ALL FIELDS.
  REFRESH: itab_1, itab_2, itab_3, itab_4, itab_5.
  CLEAR: itab_1, itab_2, itab_3, itab_4, itab_5.

  SORT it_bsid BY kunnr.
  SORT itab BY kunnr.
  LOOP AT it_bsid.
    READ TABLE itab WITH KEY kunnr = it_bsid-kunnr
    BINARY SEARCH.
    IF sy-subrc NE 0.
      DELETE it_bsid.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " itab

*&---------------------------------------------------------------------*
*&      Form  itab1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM itab1.
  APPEND LINES OF itab1 TO itab1_1.
  DELETE itab1_1 WHERE due1 EQ 0.
  APPEND LINES OF itab1 TO itab1_2.
  DELETE itab1_2 WHERE due2 EQ 0.
  APPEND LINES OF itab1 TO itab1_3.
  DELETE itab1_3 WHERE due3 EQ 0.
  APPEND LINES OF itab1 TO itab1_4.
  DELETE itab1_4 WHERE due4 EQ 0.
  APPEND LINES OF itab1 TO itab1_5.
  DELETE itab1_5 WHERE due5 EQ 0.

  REFRESH itab1. CLEAR itab1.

  IF int1 EQ 'X'.
    APPEND LINES OF itab1_1 TO itab1.
  ENDIF.
  IF int2 EQ 'X'.
    APPEND LINES OF itab1_2 TO itab1.
  ENDIF.
  IF int3 EQ 'X'.
    APPEND LINES OF itab1_3 TO itab1.
  ENDIF.
  IF int4 EQ 'X'.
    APPEND LINES OF itab1_4 TO itab1.
  ENDIF.
  IF int5 EQ 'X'.
    APPEND LINES OF itab1_5 TO itab1.
  ENDIF.

  SORT itab1.
  DELETE ADJACENT DUPLICATES FROM itab1 COMPARING ALL FIELDS.
  REFRESH: itab1_1, itab1_2, itab1_3, itab1_4, itab1_5.
  CLEAR: itab1_1, itab1_2, itab1_3, itab1_4, itab1_5.
ENDFORM.                                                    " itab1

*&---------------------------------------------------------------------*
*&      Form  itab2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM itab2.
  APPEND LINES OF itab2 TO itab2_1.
  DELETE itab2_1 WHERE due1 EQ 0.
  APPEND LINES OF itab2 TO itab2_2.
  DELETE itab2_2 WHERE due2 EQ 0.
  APPEND LINES OF itab2 TO itab2_3.
  DELETE itab2_3 WHERE due3 EQ 0.
  APPEND LINES OF itab2 TO itab2_4.
  DELETE itab2_4 WHERE due4 EQ 0.
  APPEND LINES OF itab2 TO itab2_5.
  DELETE itab2_5 WHERE due5 EQ 0.

  IF int1 = space.
    DELETE itab2 WHERE due1 EQ 0.
  ELSEIF int2 = space.
    DELETE itab2 WHERE due2 EQ 0.
  ELSEIF int3 = space.
    DELETE itab2 WHERE due3 EQ 0.
  ELSEIF int4 = space.
    DELETE itab2 WHERE due4 EQ 0.
  ELSEIF int5 = space.
    DELETE itab2 WHERE due5 EQ 0.
  ENDIF.
  REFRESH itab2. CLEAR itab2.

  IF int1 EQ 'X'.
    APPEND LINES OF itab2_1 TO itab2.
  ENDIF.
  IF int2 EQ 'X'.
    APPEND LINES OF itab2_2 TO itab2.
  ENDIF.
  IF int3 EQ 'X'.
    APPEND LINES OF itab2_3 TO itab2.
  ENDIF.
  IF int4 EQ 'X'.
    APPEND LINES OF itab2_4 TO itab2.
  ENDIF.
  IF int5 EQ 'X'.
    APPEND LINES OF itab2_5 TO itab2.
  ENDIF.
  SORT itab2.
  DELETE ADJACENT DUPLICATES FROM itab2 COMPARING ALL FIELDS.
  REFRESH: itab2_1, itab2_2, itab2_3, itab2_4, itab2_5.
  CLEAR: itab2_1, itab2_2, itab2_3, itab2_4, itab2_5.
ENDFORM.                                                    " itab2

*&---------------------------------------------------------------------*
*&      Form  itab3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM itab3.
  APPEND LINES OF itab3 TO itab3_1.
  DELETE itab3_1 WHERE due1 EQ 0.
  APPEND LINES OF itab3 TO itab3_2.
  DELETE itab3_2 WHERE due2 EQ 0.
  APPEND LINES OF itab3 TO itab3_3.
  DELETE itab3_3 WHERE due3 EQ 0.
  APPEND LINES OF itab3 TO itab3_4.
  DELETE itab3_4 WHERE due4 EQ 0.
  APPEND LINES OF itab3 TO itab3_5.
  DELETE itab3_5 WHERE due5 EQ 0.
  REFRESH itab3. CLEAR itab3.
  IF int1 EQ 'X'.
    APPEND LINES OF itab3_1 TO itab3.
  ENDIF.
  IF int2 EQ 'X'.
    APPEND LINES OF itab3_2 TO itab3.
  ENDIF.
  IF int3 EQ 'X'.
    APPEND LINES OF itab3_3 TO itab3.
  ENDIF.
  IF int4 EQ 'X'.
    APPEND LINES OF itab3_4 TO itab3.
  ENDIF.
  IF int5 EQ 'X'.
    APPEND LINES OF itab3_5 TO itab3.
  ENDIF.
  SORT itab3.
  DELETE ADJACENT DUPLICATES FROM itab3 COMPARING ALL FIELDS.
  REFRESH: itab3_1, itab3_2, itab3_3, itab3_4, itab3_5.
  CLEAR: itab3_1, itab3_2, itab3_3, itab3_4, itab3_5.
ENDFORM.                                                    " itab3

*&---------------------------------------------------------------------*
*&      Form  itab4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM itab4.
  APPEND LINES OF itab4 TO itab4_1.
  DELETE itab4_1 WHERE due1 EQ 0.
  APPEND LINES OF itab4 TO itab4_2.
  DELETE itab4_2 WHERE due2 EQ 0.
  APPEND LINES OF itab4 TO itab4_3.
  DELETE itab4_3 WHERE due3 EQ 0.
  APPEND LINES OF itab4 TO itab4_4.
  DELETE itab4_4 WHERE due4 EQ 0.
  APPEND LINES OF itab4 TO itab4_5.
  DELETE itab4_5 WHERE due5 EQ 0.
  REFRESH itab4. CLEAR itab4.
  IF int1 EQ 'X'.
    APPEND LINES OF itab4_1 TO itab4.
  ENDIF.
  IF int2 EQ 'X'.
    APPEND LINES OF itab4_2 TO itab4.
  ENDIF.
  IF int3 EQ 'X'.
    APPEND LINES OF itab4_3 TO itab4.
  ENDIF.
  IF int4 EQ 'X'.
    APPEND LINES OF itab4_4 TO itab4.
  ENDIF.
  IF int5 EQ 'X'.
    APPEND LINES OF itab4_5 TO itab4.
  ENDIF.
  SORT itab4.
  DELETE ADJACENT DUPLICATES FROM itab4 COMPARING ALL FIELDS.
  REFRESH: itab4_1, itab4_2, itab4_3, itab4_4, itab4_5.
  CLEAR: itab4_1, itab4_2, itab4_3, itab4_4, itab4_5.
ENDFORM.                                                    " itab4

*&---------------------------------------------------------------------*
*&      Form  itab5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM itab5.
  APPEND LINES OF itab5 TO itab5_1.
  DELETE itab5_1 WHERE due1 EQ 0.
  APPEND LINES OF itab5 TO itab5_2.
  DELETE itab5_2 WHERE due2 EQ 0.
  APPEND LINES OF itab5 TO itab5_3.
  DELETE itab5_3 WHERE due3 EQ 0.
  APPEND LINES OF itab5 TO itab5_4.
  DELETE itab5_4 WHERE due4 EQ 0.
  APPEND LINES OF itab5 TO itab5_5.
  DELETE itab5_5 WHERE due5 EQ 0.
  REFRESH itab5. CLEAR itab5.
  IF int1 EQ 'X'.
    APPEND LINES OF itab5_1 TO itab5.
  ENDIF.
  IF int2 EQ 'X'.
    APPEND LINES OF itab5_2 TO itab5.
  ENDIF.
  IF int3 EQ 'X'.
    APPEND LINES OF itab5_3 TO itab5.
  ENDIF.
  IF int4 EQ 'X'.
    APPEND LINES OF itab5_4 TO itab5.
  ENDIF.
  IF int5 EQ 'X'.
    APPEND LINES OF itab5_5 TO itab5.
  ENDIF.
  SORT itab5.
  DELETE ADJACENT DUPLICATES FROM itab5 COMPARING ALL FIELDS.
  REFRESH: itab5_1, itab5_2, itab5_3, itab5_4, itab5_5.
  CLEAR: itab5_1, itab5_2, itab5_3, itab5_4, itab5_5.
ENDFORM.                                                    " itab5

*&---------------------------------------------------------------------*
*&      Form  itab6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM itab6.
  APPEND LINES OF itab6 TO itab6_1.
  DELETE itab6_1 WHERE due1 EQ 0.
  APPEND LINES OF itab6 TO itab6_2.
  DELETE itab6_2 WHERE due2 EQ 0.
  APPEND LINES OF itab6 TO itab6_3.
  DELETE itab6_3 WHERE due3 EQ 0.
  APPEND LINES OF itab6 TO itab6_4.
  DELETE itab6_4 WHERE due4 EQ 0.
  APPEND LINES OF itab6 TO itab6_5.
  DELETE itab6_5 WHERE due5 EQ 0.
  REFRESH itab6. CLEAR itab6.
  IF int1 EQ 'X'.
    APPEND LINES OF itab6_1 TO itab6.
  ENDIF.
  IF int2 EQ 'X'.
    APPEND LINES OF itab6_2 TO itab6.
  ENDIF.
  IF int3 EQ 'X'.
    APPEND LINES OF itab6_3 TO itab6.
  ENDIF.
  IF int4 EQ 'X'.
    APPEND LINES OF itab6_4 TO itab6.
  ENDIF.
  IF int5 EQ 'X'.
    APPEND LINES OF itab6_5 TO itab6.
  ENDIF.
  SORT itab6.
  DELETE ADJACENT DUPLICATES FROM itab6 COMPARING ALL FIELDS.
  REFRESH: itab6_1, itab6_2, itab6_3, itab6_4, itab6_5.
  CLEAR: itab6_1, itab6_2, itab6_3, itab6_4, itab6_5.
ENDFORM.                                                    " itab6

*&---------------------------------------------------------------------*
*&      Form  f_call_zf27n
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_call_zf27n USING fc_fvalue fc_gsber.
  DATA: BEGIN OF rspar OCCURS 0.
          INCLUDE STRUCTURE rsparams.
  DATA: END OF rspar.


  CLEAR: rspar.
  REFRESH: rspar.
  rspar-selname  = 'P_BUKRS'.
  rspar-kind     = 'P'.
  rspar-sign     = 'I'.
  rspar-option   = 'EQ'.
  rspar-low      = p_bukrs.
  APPEND rspar.

  rspar-selname  = 'S_GSBER'.
  rspar-kind     = 'S'.
  rspar-sign     = 'I'.
  rspar-option   = 'BT'.
  rspar-low      = fc_gsber.
  APPEND rspar.

  rspar-selname  = 'S_KUNNR'.
  rspar-kind     = 'S'.
  rspar-sign     = 'I'.
  rspar-option   = 'BT'.
  rspar-low      = fc_fvalue.
  APPEND rspar.

  rspar-selname  = 'P_GERDAT'.
  rspar-kind     = 'P'.
  rspar-sign     = 'I'.
  rspar-option   = 'EQ'.
  rspar-low      = p_gerdat.
  APPEND rspar.

  LOOP AT it_bsid WHERE kunnr EQ fc_fvalue.
    rspar-selname  = 'S_DO'.
    rspar-kind     = 'S'.
    rspar-sign     = 'I'.
    rspar-option   = 'EQ'.
    rspar-low      = it_bsid-zuonr.
    APPEND rspar.
  ENDLOOP.

  IF x_norm IS NOT INITIAL.
    rspar-selname  = 'X_NORM'.
    rspar-kind     = 'P'.
    rspar-sign     = 'I'.
    rspar-option   = 'EQ'.
    rspar-low      = 'X'.
    APPEND rspar.
  ENDIF.

  IF x_shbv IS NOT INITIAL.
    rspar-selname  = 'X_SHBV'.
    rspar-kind     = 'P'.
    rspar-sign     = 'I'.
    rspar-option   = 'EQ'.
    rspar-low      = 'X'.
    APPEND rspar.
  ENDIF.

  SUBMIT zf_ar_open_items_new WITH SELECTION-TABLE rspar AND RETURN.
ENDFORM.                                                    " f_call_zf27n

*&---------------------------------------------------------------------*
*&      Form  f_modify_it_bsid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_it_bsid .
  DATA: ld_check1(5),
        ld_check2(5),
        ld_int1(1),
        ld_int2(1),
        ld_int3(1),
        ld_int4(1),
        ld_int5(1),
        ld_count  TYPE i,
        ld_len1(1),
        ld_len2(1),
        ld_delete(1),
        ld_flag(1).

  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  IF int1 IS INITIAL.
    int1 = '*'.
  ENDIF.
  IF int2 IS INITIAL.
    int2 = '*'.
  ENDIF.
  IF int3 IS INITIAL.
    int3 = '*'.
  ENDIF.
  IF int4 IS INITIAL.
    int4 = '*'.
  ENDIF.
  IF int5 IS INITIAL.
    int5 = '*'.
  ENDIF.
  CONCATENATE int1 int2 int3 int4 int5 INTO ld_check1.

** tambahan untuk SUT
*  LOOP AT i_giro.
*    READ TABLE it_bsid WITH KEY vkbur = i_giro-vkbur
*                                kunnr = i_giro-kunnr.
*    IF sy-subrc EQ 0.
*      CONTINUE.
*    ELSE.
*      it_bsid-vkbur    = i_giro-vkbur.
*      it_bsid-kunnr    = i_giro-kunnr.
*      it_bsid-kdgrp    = i_giro-kdgrp.
*      it_bsid-xref2    = i_giro-xref2.
*      it_bsid-xref1    = i_giro-xref1.
*      it_bsid-brsch    = i_giro-brsch.
*      it_bsid-channel  = i_giro-channel.
*      it_bsid-zuonr    = i_giro-zuonr.
*      APPEND it_bsid.
*    ENDIF.
*  ENDLOOP.

  lt_bsid[] = it_bsid[].
  SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

  SORT it_bsid BY bukrs vkbur kunnr.
  LOOP AT it_bsid.
    IF it_bsid-shkzg EQ 'H'.
      it_bsid-dmbtr = it_bsid-dmbtr * -1.
      IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
        it_bsid-zbd1t = 0.
      ENDIF.
    ENDIF.
    IF it_bsid-budat(6) LT p_gerdat(6).
      itab-begin = itab-begin + it_bsid-dmbtr.
    ENDIF.

    IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
       it_bsid-blart NE 'DR'.
      IF it_bsid-budat GE l_gerdat1 AND
         it_bsid-budat LT l_gerdat2.
        itab-sales = itab-sales + it_bsid-dmbtr.
      ENDIF.
    ELSE.
      IF it_bsid-budat GE l_gerdat1 AND
         it_bsid-budat LT l_gerdat2.
        itab-payment = itab-payment + it_bsid-dmbtr.
      ENDIF.
    ENDIF.

    PERFORM due_branch  TABLES lt_bsid.

    IF itab-due1 IS INITIAL.
      ld_int1 = '*'.
    ELSE.
      ld_int1 = 'X'.
    ENDIF.
    IF itab-due2 IS INITIAL.
      ld_int2 = '*'.
    ELSE.
      ld_int2 = 'X'.
    ENDIF.
    IF itab-due3 IS INITIAL.
      ld_int3 = '*'.
    ELSE.
      ld_int3 = 'X'.
    ENDIF.
    IF itab-due4 IS INITIAL.
      ld_int4 = '*'.
    ELSE.
      ld_int4 = 'X'.
    ENDIF.
    IF itab-due5 IS INITIAL.
      ld_int5 = '*'.
    ELSE.
      ld_int5 = 'X'.
    ENDIF.

    CONCATENATE ld_int1 ld_int2 ld_int3 ld_int4 ld_int5 INTO ld_check2.
    DO 5 TIMES.
      ld_len2 = ld_check2+ld_count(1).
      IF ld_len2 EQ 'X'.
        ld_len1 = ld_check1+ld_count(1).
        IF ld_len1 NE 'X'.
          DELETE it_bsid.
        ENDIF.
      ENDIF.
      ADD 1 TO ld_count.
    ENDDO.
    CLEAR: ld_check2, itab, ld_count.
  ENDLOOP.
ENDFORM.                    " f_modify_it_bsid

*&---------------------------------------------------------------------*
*&      Form  f_detail_kunnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_detail_kunnr USING fu_kunnr.
  DATA: l_budat LIKE it_bsid-budat,
        l_zfbdt LIKE it_bsid-zfbdt,
        l_zbd1t LIKE it_bsid-zbd1t,
        l_duedt LIKE it_bsid-duedt.

  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.
  DATA : lv_subrc   TYPE sy-subrc.

  lt_bsid[] = it_bsid[].
  SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.
  SORT it_bsid BY zuonr belnr.
  CLEAR: t_hotspot.
  REFRESH: t_hotspot.
  LOOP AT it_bsid WHERE kunnr EQ fu_kunnr.
    ON CHANGE OF it_bsid-zuonr.
      CLEAR: l_budat, l_zfbdt, l_zbd1t.
      l_budat = it_bsid-budat.
      l_zfbdt = it_bsid-zfbdt.
      l_zbd1t = it_bsid-zbd1t.
      l_duedt = it_bsid-duedt.
    ENDON.

    t_hotspot-budat = l_budat.
    t_hotspot-zfbdt = l_zfbdt.
    t_hotspot-zbd1t = l_zbd1t.
    t_hotspot-duedt = l_duedt.
    t_hotspot-kunnr = it_bsid-kunnr.
    t_hotspot-zuonr = it_bsid-zuonr.

    IF it_bsid-shkzg EQ 'H'.
      it_bsid-dmbtr = it_bsid-dmbtr * -1.
      IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
        it_bsid-zbd1t = 0.
      ENDIF.
    ENDIF.
    IF it_bsid-budat(6) LT p_gerdat(6).
      t_hotspot-begin = it_bsid-dmbtr.
    ENDIF.

    IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
       it_bsid-blart NE 'DR'.
      IF it_bsid-budat GE l_gerdat1 AND
         it_bsid-budat LT l_gerdat2.
        t_hotspot-sales = it_bsid-dmbtr.
      ENDIF.
    ELSE.
      IF it_bsid-budat GE l_gerdat1 AND
         it_bsid-budat LT l_gerdat2.
        t_hotspot-payment = it_bsid-dmbtr.
      ENDIF.
    ENDIF.
    PERFORM due_branch_hot TABLES lt_bsid.
    COLLECT t_hotspot.
    CLEAR: t_hotspot.
  ENDLOOP.

  PERFORM write_header_choose.

  SORT lt_bsid BY kunnr zuonr budat.

  LOOP AT t_hotspot.
    LOOP AT i_giro WHERE kunnr EQ t_hotspot-kunnr AND
                         zuonr EQ t_hotspot-zuonr.
      t_hotspot-giro = t_hotspot-giro + i_giro-cchek.
    ENDLOOP.

    LOOP AT i_giro_sfa WHERE kunnr EQ t_hotspot-kunnr AND
                             zuonr EQ t_hotspot-zuonr.
      t_hotspot-giro = t_hotspot-giro + i_giro_sfa-bank_amt.
    ENDLOOP.

    t_hotspot-ending = t_hotspot-begin + t_hotspot-sales + ( t_hotspot-payment ).

    MODIFY t_hotspot TRANSPORTING giro ending age.

    READ TABLE lt_bsid WITH KEY kunnr = t_hotspot-kunnr
                                zuonr = t_hotspot-zuonr
                                umskz = 'V'
                       TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      READ TABLE lt_bsid WITH KEY kunnr = t_hotspot-kunnr
                                  zuonr = t_hotspot-zuonr.
      IF sy-subrc = 0.
        t_hotspot-zfbdt = lt_bsid-budat.
        t_hotspot-duedt = lt_bsid-budat.
      ENDIF.
    ENDIF.

    PERFORM f_check_write USING t_hotspot-begin t_hotspot-sales
                                t_hotspot-payment t_hotspot-ending
                                t_hotspot-giro
                          CHANGING lv_subrc.
    IF lv_subrc IS INITIAL.
      PERFORM zebra.
      c1 = 0.
      WRITE AT /c1(w11) t_hotspot-zuonr.c1 = c1 + w11 + 1.
      WRITE AT c1(w1) t_hotspot-zfbdt.c1 = c1 + w1 + 1.
      WRITE AT c1(w1) t_hotspot-duedt.c1 = c1 + w1 + 1.
      WRITE AT c1(w3) t_hotspot-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
      WRITE AT c1(w4) t_hotspot-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
      WRITE AT c1(w5) t_hotspot-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
      WRITE AT c1(w6) t_hotspot-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
      WRITE AT c1(w7) t_hotspot-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
      WRITE AT c1(w13) t_hotspot-due1 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
      WRITE AT c1(w10) t_hotspot-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
      WRITE AT c1(w11) t_hotspot-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
      WRITE AT c1(w12) t_hotspot-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
      WRITE AT c1(w13) t_hotspot-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
      AT END OF kunnr.
        SUM.
        PERFORM subtotal_hot.
      ENDAT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " f_detail_kunnr

*&---------------------------------------------------------------------*
*&      Form  write_header_choose
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_header_choose .
  DATA : due1(14),
         due2(14),
         due3(14),
         due4(14),
         due5(14),
         n1 TYPE i,
         n2 TYPE i,
         l_cab(50),
         l_butxt LIKE t001-butxt.
  FORMAT COLOR 1.
  IF top = 'X'.
    CONCATENATE '1-' int1low ' HARI' INTO due1.
    CONCATENATE int1low '-' int2low ' HARI' INTO due2.
    CONCATENATE int2low '-' int3low ' HARI' INTO due3.
    CONCATENATE int3low '-' int4low ' HARI' INTO due4.
    CONCATENATE '>' int4low ' HARI' INTO due5.
  ELSE.
    CONCATENATE 'NOT' ' DUE' INTO due1.
    CONCATENATE  '1-' int1low ' HARI' INTO due2.
    CONCATENATE int1low '-' int2low ' HARI' INTO due3.
    CONCATENATE int2low '-' int3low ' HARI' INTO due4.
    CONCATENATE '>' int3low ' HARI' INTO due5.
  ENDIF.
  c1 = 0.

  n1 = 127.
  n2 = 118.
  PERFORM bulan.
  SELECT SINGLE butxt INTO l_butxt FROM t001 WHERE bukrs EQ p_bukrs.
  IF top EQ 'X'.
    WRITE :/ l_butxt.
    WRITE AT 80(n1) 'DAFTAR PIUTANG, PLAFOND & TOP'.
  ELSE.
    WRITE :/ l_butxt.
    WRITE AT 80(n1) 'DAFTAR PIUTANG, PLAFOND & AGING'.
  ENDIF.

  WRITE AT /80(10) 'CABANG : '.
  SELECT SINGLE bezei INTO cab FROM tvkbt
  WHERE spras EQ 'E' AND vkbur EQ plant.
  CONCATENATE plant '-' cab INTO l_cab.
  WRITE AT 90(n2) l_cab.
  WRITE :/'UserID : ', sy-uname, '/', sy-tcode,
           80(10) 'BULAN  : '.
  WRITE AT 90(n2) bulan.
  WRITE :/(10) 'CETAK : '.
  WRITE AT 10(10) sy-datum.
  WRITE AT 21(10) sy-uzeit.
  WRITE AT 80(10) 'PROSES : '.
  WRITE AT 90(n2) p_gerdat MM/DD/YYYY.
  WRITE AT 190(8) 'Page : '.
  WRITE AT 199(4) page.
  SKIP 1.
  WRITE AT /(w11) 'NO DO'.c1 = w11 + 2.
  WRITE AT c1(w1) 'DN DATE'  NO-GAP.c1 = c1 + w1 + 1.       " + W14.
  WRITE AT c1(w1) 'DUE DATE'  NO-GAP.c1 = c1 + w1 + 1.      " + W14.
  w9 = 14.
  SET LEFT SCROLL-BOUNDARY.
  WRITE AT c1(w3) 'SALDO AWAL' RIGHT-JUSTIFIED.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) 'NET SALES' RIGHT-JUSTIFIED.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) 'PAYMENT' RIGHT-JUSTIFIED.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) 'SALDO AKHIR' RIGHT-JUSTIFIED.c1 = c1 + w6 + 1.
  WRITE AT c1(w7) 'JUMLAH GIRO' RIGHT-JUSTIFIED.c1 = c1 + w7 + 1.
  WRITE AT c1(w9) due1 RIGHT-JUSTIFIED.c1 = c1 + w9 + 1.
  WRITE AT c1(w10) due2 RIGHT-JUSTIFIED.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) due3 RIGHT-JUSTIFIED.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) due4 RIGHT-JUSTIFIED.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) due5 RIGHT-JUSTIFIED.
  SKIP 1.
ENDFORM.                    " write_header_choose

*&---------------------------------------------------------------------*
*&      Form  f_choose7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_choose7 .

  DATA : l_cchek LIKE zfbicheck-cchek,
         l_limit TYPE p.

  DATA : lt_itab  LIKE it_choosekey OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_knkk OCCURS 0,
           kunnr  TYPE kunnr,
           klimk  TYPE klimk,
         END OF lt_knkk.

  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  it_choosekey[] = it_choose[].
  IF va_flag IS INITIAL.
    DELETE it_choosekey WHERE kdgrp NE itab6-kdgrp.
    DELETE it_choosekey WHERE channel NE itab6-channel.
    DELETE it_choosekey WHERE gsber NE itab6-gsber.
    DELETE ADJACENT DUPLICATES FROM it_choosekey
           COMPARING gsber kunnr channel kdgrp.

    lt_itab[] = it_choosekey[].
    SORT lt_itab BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING kunnr.
    IF lt_itab[] IS NOT INITIAL.
      SELECT kunnr klimk
        FROM knkk
        INTO TABLE lt_knkk
        FOR ALL ENTRIES IN lt_itab
        WHERE kunnr EQ lt_itab-kunnr.
    ENDIF.

    LOOP AT it_choosekey.
      CLEAR itab.
      MOVE it_choosekey-gsber TO itab-gsber.
      MOVE it_choosekey-kunnr TO itab-kunnr.
      MOVE p_gerdat(4) TO itab-gjahr.

      READ TABLE lt_knkk WITH KEY kunnr = it_choosekey-kunnr.
      IF sy-subrc EQ 0.
        itab-limit  = lt_knkk-klimk.
      ENDIF.

      l_limit = itab-limit * 100.
      IF l_limit >= 99999999999999.
        itab-limit = 0.
      ENDIF.

      LOOP AT i_giro WHERE kunnr EQ it_choosekey-kunnr AND
                           vkbur EQ it_choosekey-gsber AND
                           channel EQ it_choosekey-channel AND
                           kdgrp EQ it_choosekey-kdgrp.
        itab-giro = itab-giro + i_giro-cchek.
      ENDLOOP.

      LOOP AT i_giro_sfa WHERE kunnr EQ it_choosekey-kunnr AND
                               vkbur EQ it_choosekey-gsber AND
                               channel EQ it_choosekey-channel AND
                               kdgrp EQ it_choosekey-kdgrp.
        itab-giro = itab-giro + i_giro_sfa-bank_amt.
      ENDLOOP.

      lt_bsid[] = it_bsid[].
      SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

      LOOP AT it_bsid WHERE vkbur EQ it_choosekey-gsber AND
                            kunnr EQ it_choosekey-kunnr AND
                            channel EQ it_choosekey-channel AND
                            kdgrp EQ it_choosekey-kdgrp.

        IF it_bsid-shkzg EQ 'H'.
          it_bsid-dmbtr = it_bsid-dmbtr * -1.
          IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
            it_bsid-zbd1t = 0.
          ENDIF.
        ENDIF.
        IF it_bsid-budat(6) LT p_gerdat(6).
          itab-begin = itab-begin + it_bsid-dmbtr.
        ENDIF.

** Koreksi by budi 07/09/2006 req. by SJT
*      IF it_bsid-blart NE 'DZ'.
        IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
           it_bsid-blart NE 'DR'.
** End koreksi by budi 07/09/2006 req. by SJT
          IF it_bsid-budat GE l_gerdat1 AND
             it_bsid-budat LT l_gerdat2.
            itab-sales = itab-sales + it_bsid-dmbtr.
          ENDIF.
        ELSE.
          IF it_bsid-budat GE l_gerdat1 AND
             it_bsid-budat LT l_gerdat2.
            itab-payment = itab-payment + it_bsid-dmbtr.
          ENDIF.
        ENDIF.
*      ENDIF.

        PERFORM due_branch  TABLES lt_bsid.

        MOVE it_bsid-sortl TO itab-sortl.
      ENDLOOP.

      itab-payment = itab-payment.
      itab-sales =  itab-sales.
      itab-ending = itab-begin + itab-sales + ( itab-payment ).
*   IF ITAB-BEGIN NE 0 OR ITAB-ENDING NE 0.
      IF itab-begin NE 0 OR itab-ending NE 0 OR
         itab-sales NE 0 OR itab-payment NE 0.
        APPEND itab.
      ENDIF.

    ENDLOOP.

  ELSE.
    DELETE it_choosekey WHERE kdgrp NE itab6-brsch.
    DELETE it_choosekey WHERE channel NE itab6-channel.
    DELETE it_choosekey WHERE gsber NE itab6-gsber.
    DELETE ADJACENT DUPLICATES FROM it_choosekey
           COMPARING gsber kunnr channel brsch.

    lt_itab[] = it_choosekey[].
    SORT lt_itab BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING kunnr.
    IF lt_itab[] IS NOT INITIAL.
      SELECT kunnr klimk
        FROM knkk
        INTO TABLE lt_knkk
        FOR ALL ENTRIES IN lt_itab
        WHERE kunnr EQ lt_itab-kunnr.
    ENDIF.

    LOOP AT it_choosekey.
      CLEAR itab.
      MOVE it_choosekey-gsber TO itab-gsber.
      MOVE it_choosekey-kunnr TO itab-kunnr.
      MOVE p_gerdat(4) TO itab-gjahr.

      READ TABLE lt_knkk WITH KEY kunnr = it_choosekey-kunnr.
      IF sy-subrc EQ 0.
        itab-limit  = lt_knkk-klimk.
      ENDIF.

      l_limit = itab-limit * 100.
      IF l_limit >= 99999999999999.
        itab-limit = 0.
      ENDIF.

      LOOP AT i_giro WHERE kunnr EQ it_choosekey-kunnr AND
                           vkbur EQ it_choosekey-gsber AND
                           channel EQ it_choosekey-channel AND
                           brsch EQ it_choosekey-brsch.
        itab-giro = itab-giro + i_giro-cchek.
      ENDLOOP.

      LOOP AT i_giro_sfa WHERE kunnr EQ it_choosekey-kunnr AND
                               vkbur EQ it_choosekey-gsber AND
                               channel EQ it_choosekey-channel AND
                               brsch EQ it_choosekey-brsch.
        itab-giro = itab-giro + i_giro_sfa-bank_amt.
      ENDLOOP.

      lt_bsid[] = it_bsid[].
      SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

      LOOP AT it_bsid WHERE vkbur EQ it_choosekey-gsber AND
                            kunnr EQ it_choosekey-kunnr AND
                            channel EQ it_choosekey-channel AND
                            brsch EQ it_choosekey-brsch.

        IF it_bsid-shkzg EQ 'H'.
          it_bsid-dmbtr = it_bsid-dmbtr * -1.
          IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
            it_bsid-zbd1t = 0.
          ENDIF.
        ENDIF.
        IF it_bsid-budat(6) LT p_gerdat(6).
          itab-begin = itab-begin + it_bsid-dmbtr.
        ENDIF.

** Koreksi by budi 07/09/2006 req. by SJT
*      IF it_bsid-blart NE 'DZ'.
        IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
           it_bsid-blart NE 'DR'.
** End koreksi by budi 07/09/2006 req. by SJT
          IF it_bsid-budat GE l_gerdat1 AND
             it_bsid-budat LT l_gerdat2.
            itab-sales = itab-sales + it_bsid-dmbtr.
          ENDIF.
        ELSE.
          IF it_bsid-budat GE l_gerdat1 AND
             it_bsid-budat LT l_gerdat2.
            itab-payment = itab-payment + it_bsid-dmbtr.
          ENDIF.
        ENDIF.
*      ENDIF.

        PERFORM due_branch  TABLES lt_bsid.

        MOVE it_bsid-sortl TO itab-sortl.
      ENDLOOP.

      itab-payment = itab-payment.
      itab-sales =  itab-sales.
      itab-ending = itab-begin + itab-sales + ( itab-payment ).
*   IF ITAB-BEGIN NE 0 OR ITAB-ENDING NE 0.
      IF itab-begin NE 0 OR itab-ending NE 0 OR
         itab-sales NE 0 OR itab-payment NE 0.
        APPEND itab.
      ENDIF.

    ENDLOOP.
  ENDIF.

ENDFORM.                                                    " f_choose7

*&---------------------------------------------------------------------*
*&      Form  subtotal_hot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM subtotal_hot .
  PERFORM zebra.
  SKIP 1.
  c1 = 0.
  WRITE AT /c1(w11) 'TOTAL'.c1 = c1 + w11 + 1.c1 = c1 + w1 + 1.c1 = c1 + w1 + 1.
  WRITE AT c1(w3) t_hotspot-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) t_hotspot-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) t_hotspot-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) t_hotspot-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) t_hotspot-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
  WRITE AT c1(w13) t_hotspot-due1 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
  WRITE AT c1(w10) t_hotspot-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) t_hotspot-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) t_hotspot-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) t_hotspot-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
ENDFORM.                    " subtotal_hot

*&---------------------------------------------------------------------*
*&      Form  f_tambah_kunnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_tambah_kunnr .
  DATA : ls_kna1  TYPE ty_kna1.

  IF t_zfarsoff_add[] IS NOT INITIAL.
    l_monat1 = p_gerdat+4(2).
    l_monat2 = p_gerdat+4(2) + 1.

    CONCATENATE p_gerdat(4) l_monat1 '01' INTO l_gerdat1.
    CONCATENATE p_gerdat(4) l_monat2 '01' INTO l_gerdat2.

    PERFORM f_get_customer USING '1'.

    IF gt_kna1_add[] IS NOT INITIAL.
      IF x_norm EQ 'X' AND x_shbv EQ 'X'.
        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr shkzg zfbdt zbd1t
               blart xref2 zuonr xref1 zterm cpudt kidno bschl umskz
          FROM bsid
          INTO CORRESPONDING FIELDS OF TABLE t_bsid_add
          FOR ALL ENTRIES IN gt_kna1_add
          WHERE kunnr = gt_kna1_add-kunnr
            AND bukrs = p_bukrs
            AND budat LE p_gerdat
            AND umskz = space
            AND blart IN s_blart
            AND zuonr IN s_do.

*      IF p_hist IS NOT INITIAL.
        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr shkzg zfbdt zbd1t
               blart xref2 zuonr augdt xref1 zterm cpudt kidno bschl umskz
          FROM bsad
          APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add
          FOR ALL ENTRIES IN gt_kna1_add
          WHERE kunnr = gt_kna1_add-kunnr
            AND bukrs = p_bukrs
            AND budat LE p_gerdat
            AND augdt GE l_gerdat1
            AND umskz = space
            AND blart IN s_blart
            AND zuonr IN s_do.
*      ENDIF.

        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr shkzg zfbdt zbd1t
               blart xref2 zuonr xref1 zterm cpudt kidno bschl umskz
          FROM bsid
          APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add
          FOR ALL ENTRIES IN gt_kna1_add
          WHERE kunnr = gt_kna1_add-kunnr
            AND bukrs = p_bukrs
            AND budat LE p_gerdat
            AND umskz IN s_bschl
            AND blart IN s_blart
            AND zuonr IN s_do.

*      IF p_hist IS NOT INITIAL.
        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr shkzg zfbdt zbd1t
               blart xref2 zuonr augdt xref1 zterm cpudt kidno bschl umskz
          FROM bsad
          APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add
          FOR ALL ENTRIES IN gt_kna1_add
          WHERE kunnr = gt_kna1_add-kunnr
            AND bukrs = p_bukrs
            AND budat LE p_gerdat
            AND augdt GE l_gerdat1
            AND umskz IN s_bschl
            AND blart IN s_blart
            AND zuonr IN s_do.
*      ENDIF.
      ENDIF.

      IF x_norm EQ 'X' AND x_shbv EQ space.
        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr shkzg zfbdt zbd1t
               blart xref2 zuonr xref1 zterm cpudt kidno bschl umskz
          FROM bsid
          INTO CORRESPONDING FIELDS OF TABLE t_bsid_add
          FOR ALL ENTRIES IN gt_kna1_add
          WHERE kunnr EQ gt_kna1_add-kunnr
            AND bukrs EQ p_bukrs
            AND budat LE p_gerdat
            AND umskz EQ space
            AND blart IN s_blart
            AND zuonr IN s_do.

*      IF p_hist IS NOT INITIAL.
        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr shkzg zfbdt zbd1t
               blart xref2 zuonr augdt xref1 zterm cpudt kidno bschl umskz
          FROM bsad
          APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add
          FOR ALL ENTRIES IN gt_kna1_add
          WHERE kunnr = gt_kna1_add-kunnr
            AND bukrs = p_bukrs
            AND budat LE p_gerdat
            AND augdt GE l_gerdat1
            AND umskz = space
            AND blart IN s_blart
            AND zuonr IN s_do.
*      ENDIF.
      ENDIF.

      IF x_norm EQ space AND x_shbv EQ 'X'.
        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr shkzg zfbdt zbd1t
               blart xref2 zuonr xref1 zterm cpudt kidno bschl umskz
          FROM bsid
          INTO CORRESPONDING FIELDS OF TABLE t_bsid_add
          FOR ALL ENTRIES IN gt_kna1_add
          WHERE kunnr = gt_kna1_add-kunnr
            AND bukrs = p_bukrs
            AND budat LE p_gerdat
            AND umskz IN s_bschl
            AND blart IN s_blart
            AND zuonr IN s_do.

*      IF p_hist IS NOT INITIAL.
        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr shkzg zfbdt zbd1t
               blart xref2 zuonr augdt xref1 zterm cpudt kidno bschl umskz
          FROM bsad
          APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add
          FOR ALL ENTRIES IN gt_kna1_add
          WHERE kunnr EQ gt_kna1_add-kunnr
            AND bukrs EQ p_bukrs
            AND budat LE p_gerdat
            AND augdt GE l_gerdat1
            AND umskz IN s_bschl
            AND blart IN s_blart
            AND zuonr IN s_do.
*      ENDIF.
      ENDIF.

      SORT t_bsid_add BY kunnr.
      SORT t_zfarsoff_add BY kunnr.
      SORT gt_kna1_add BY kunnr.

      LOOP AT t_bsid_add.
        READ TABLE gt_kna1_add INTO ls_kna1
                               WITH KEY kunnr = t_bsid_add-kunnr
                               BINARY SEARCH.
        IF sy-subrc = 0.
          t_bsid_add-kdgrp   = ls_kna1-kdgrp.
          t_bsid_add-kvgr3   = ls_kna1-kvgr3.
          t_bsid_add-brsch   = ls_kna1-brsch.
          t_bsid_add-sortl   = ls_kna1-sortl.
          MODIFY t_bsid_add TRANSPORTING kdgrp kvgr3 brsch sortl.

          READ TABLE t_zfarsoff_add WITH KEY kunnr = t_bsid_add-kunnr
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            IF p_gerdat LT t_zfarsoff_add-budat.
              IF t_zfarsoff_add-zvkbur IN s_gsber.
                t_bsid_add-vkbur = t_zfarsoff_add-zvkbur.
                MODIFY t_bsid_add TRANSPORTING vkbur.
                it_bsid = t_bsid_add.
                APPEND it_bsid.
              ENDIF.
            ELSE.
              IF t_zfarsoff_add-zvkbur1 IN s_gsber.
                t_bsid_add-vkbur = t_zfarsoff_add-zvkbur.
                MODIFY t_bsid_add TRANSPORTING vkbur.
                it_bsid = t_bsid_add.
                APPEND it_bsid.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          DELETE t_bsid_add.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_tambah_kunnr

*&---------------------------------------------------------------------*
*&      Form  f_mapping_soff
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_mapping_soff .
  IF s_kunnr IS NOT INITIAL.
    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_dele
      WHERE kunnr    IN s_kunnr AND
            zvkbur1  IN s_gsber AND
            budat    GE p_gerdat.

    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_add
      WHERE kunnr  IN s_kunnr AND
            budat  GE p_gerdat.
  ELSE.
    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_dele
      WHERE zvkbur1  IN s_gsber AND
            budat    GE p_gerdat.

    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_add
      WHERE budat  GE p_gerdat.
  ENDIF.
ENDFORM.                    " f_mapping_soff

*&---------------------------------------------------------------------*
*&      Form  f_hapus_kunnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hapus_kunnr.
  IF t_zfarsoff_dele[] IS NOT INITIAL.
    SORT it_bsid BY kunnr.
    SORT t_zfarsoff_dele BY kunnr.
    LOOP AT it_bsid.
      READ TABLE t_zfarsoff_dele WITH KEY kunnr = it_bsid-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        DELETE it_bsid.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_hapus_kunnr

*&---------------------------------------------------------------------*
*&      Form  f_reclas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_reclas .
  DATA: BEGIN OF lt_kunnr OCCURS 0,
          kunnr  LIKE bsid-kunnr.
  DATA: END OF lt_kunnr.
  DATA: l_length TYPE i.

  SELECT a~vstel a~werks a~lgort
         b~live b~mixlive
    FROM tvkol AS a JOIN zplbc AS b ON b~werks EQ a~werks AND
                                       b~lgort EQ a~lgort
    INTO TABLE i_tvkol
    WHERE vstel IN s_gsber.

  IF p_bukrs EQ '8020'.
    LOOP AT i_tvkol.
      IF i_tvkol-vstel = '0200'.
        DELETE i_tvkol.
      ENDIF.
      IF i_tvkol-vstel(2) <> '02'.
        IF i_tvkol-vstel = 'T220'.
          CONTINUE.
        ENDIF.
        DELETE i_tvkol.
      ENDIF.
    ENDLOOP.
*    DELETE i_tvkol WHERE  vstel(2) NE '02'.
*    DELETE i_tvkol WHERE  vstel    EQ '0200'.
  ELSEIF p_bukrs EQ '8070'.
    DELETE i_tvkol WHERE  vstel(2) NE '07'.
  ENDIF.

  SORT it_bsid BY zuonr.
  LOOP AT it_bsid.
    lt_kunnr-kunnr  = it_bsid-kunnr.
    APPEND lt_kunnr.

    IF it_bsid-zuonr IS NOT INITIAL.
      l_length = STRLEN( it_bsid-zuonr ).
      l_length = l_length - 1.
      IF it_bsid-zuonr+l_length(1) EQ 'R'.
        it_bsid-zuonr  = it_bsid-zuonr(l_length).
      ENDIF.
    ENDIF.

    t_bsid_temp    = it_bsid.
    APPEND t_bsid_temp.
    MODIFY it_bsid TRANSPORTING zuonr.
  ENDLOOP.

  SORT lt_kunnr BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_kunnr COMPARING kunnr.

  IF lt_kunnr[] IS NOT INITIAL.
    SELECT kunnr vkorg vtweg spart parvw kunn2 pernr
    FROM knvp
    INTO CORRESPONDING FIELDS OF TABLE t_routelist
    FOR ALL ENTRIES IN lt_kunnr
    WHERE kunnr EQ lt_kunnr-kunnr AND
          parvw EQ 'ZC'.
    IF sy-subrc EQ 0.
      SELECT kunnr vkorg vtweg spart parvw kunn2 pernr
      FROM knvp
      INTO CORRESPONDING FIELDS OF TABLE t_salesman
      FOR ALL ENTRIES IN t_routelist
      WHERE kunnr EQ t_routelist-kunn2 AND
            parvw EQ 'ZP'.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_reclas

*&---------------------------------------------------------------------*
*&      Form  f_read_temp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_7583   text
*----------------------------------------------------------------------*
FORM f_read_temp  USING    fu_blart
                  CHANGING fc_subrc.
  READ TABLE t_bsid_temp WITH KEY zuonr = it_bsid-zuonr
                                  blart = fu_blart
  BINARY SEARCH.
  IF sy-subrc EQ 0.
    fc_subrc = 0.
    it_bsid-bschl    = t_bsid_temp-bschl.
    it_bsid-zbd1t    = t_bsid_temp-zbd1t.
    it_bsid-zfbdt    = t_bsid_temp-zfbdt.
    it_bsid-zterm    = t_bsid_temp-zterm.
    it_bsid-duedt    = t_bsid_temp-duedt.
  ELSE.
    fc_subrc = 1.
  ENDIF.
  MODIFY it_bsid TRANSPORTING budat zfbdt zbd1t zterm duedt.
ENDFORM.                    " f_read_temp

*&---------------------------------------------------------------------*
*&      Form  F_CHOOSE8
*&---------------------------------------------------------------------*
FORM f_choose8 .

  DATA : l_cchek LIKE zfbicheck-cchek,
         l_limit TYPE p.

  DATA : lt_itab  LIKE it_choosekey OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_knkk OCCURS 0,
           kunnr  TYPE kunnr,
           klimk  TYPE klimk,
         END OF lt_knkk.

  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  it_choosekey[] = it_choose[].
  DELETE it_choosekey WHERE kvgr3 NE itab7-kvgr3.
  DELETE it_choosekey WHERE gsber NE itab7-gsber.
  DELETE ADJACENT DUPLICATES FROM it_choosekey
         COMPARING gsber kunnr kvgr3.

  lt_itab[] = it_choosekey[].
  SORT lt_itab BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING kunnr.
  IF lt_itab[] IS NOT INITIAL.
    SELECT kunnr klimk
      FROM knkk
      INTO TABLE lt_knkk
      FOR ALL ENTRIES IN lt_itab
      WHERE kunnr EQ lt_itab-kunnr.
  ENDIF.

  LOOP AT it_choosekey.
    CLEAR itab.
    MOVE it_choosekey-gsber TO itab-gsber.
    MOVE it_choosekey-kunnr TO itab-kunnr.
    MOVE p_gerdat(4) TO itab-gjahr.

    READ TABLE lt_knkk WITH KEY kunnr = it_choosekey-kunnr.
    IF sy-subrc EQ 0.
      itab-limit  = lt_knkk-klimk.
    ENDIF.

    l_limit = itab-limit * 100.
    IF l_limit >= 99999999999999.
      itab-limit = 0.
    ENDIF.

    LOOP AT i_giro WHERE kunnr EQ it_choosekey-kunnr AND
                         vkbur EQ it_choosekey-gsber AND
                         kvgr3 EQ it_choosekey-kvgr3.
      itab-giro = itab-giro + i_giro-cchek.
    ENDLOOP.

    LOOP AT i_giro_sfa WHERE kunnr EQ it_choosekey-kunnr AND
                             vkbur EQ it_choosekey-gsber AND
                             kvgr3 EQ it_choosekey-kvgr3.
      itab-giro = itab-giro + i_giro_sfa-bank_amt.
    ENDLOOP.

    lt_bsid[] = it_bsid[].
    SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

    LOOP AT it_bsid WHERE vkbur EQ it_choosekey-gsber AND
                          kunnr EQ it_choosekey-kunnr AND
                          kvgr3 EQ it_choosekey-kvgr3.

      IF it_bsid-shkzg EQ 'H'.
        it_bsid-dmbtr = it_bsid-dmbtr * -1.
        IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
          it_bsid-zbd1t = 0.
        ENDIF.
      ENDIF.
      IF it_bsid-budat(6) LT p_gerdat(6).
        itab-begin = itab-begin + it_bsid-dmbtr.
      ENDIF.

** Koreksi by budi 07/09/2006 req. by SJT
*      IF it_bsid-blart NE 'DZ'.
      IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
         it_bsid-blart NE 'DR'.
** End koreksi by budi 07/09/2006 req. by SJT
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab-sales = itab-sales + it_bsid-dmbtr.
        ENDIF.
      ELSE.
        IF it_bsid-budat GE l_gerdat1 AND
           it_bsid-budat LT l_gerdat2.
          itab-payment = itab-payment + it_bsid-dmbtr.
        ENDIF.
      ENDIF.
*      ENDIF.

      PERFORM due_branch  TABLES lt_bsid.

      MOVE it_bsid-sortl TO itab-sortl.
    ENDLOOP.

    itab-payment = itab-payment.
    itab-sales =  itab-sales.
    itab-ending = itab-begin + itab-sales + ( itab-payment ).
*   IF ITAB-BEGIN NE 0 OR ITAB-ENDING NE 0.
    IF itab-begin NE 0 OR itab-ending NE 0 OR
       itab-sales NE 0 OR itab-payment NE 0.
      APPEND itab.
    ENDIF.
  ENDLOOP.
ENDFORM.                                                    " F_CHOOSE8

*&---------------------------------------------------------------------*
*&      Form  SUM_BRSUBCUSTGR
*&---------------------------------------------------------------------*
FORM sum_brsubcustgr .
  DATA : l_cchek LIKE zfbicheck-cchek.
  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  lt_bsid[] = it_bsid[].
  SORT lt_bsid BY bukrs vkbur kunnr zuonr budat.

  SORT it_bsid BY bukrs vkbur kunnr kvgr3.
  SORT i_giro BY bukrs vkbur kunnr kvgr3.
  SORT i_giro_sfa BY bukrs vkbur kunnr kvgr3.

  LOOP AT it_bsid.
    CLEAR itab7.
    MOVE it_bsid-vkbur TO itab7-gsber.
    MOVE it_bsid-kvgr3 TO itab7-kvgr3.
    MOVE p_gerdat(4) TO itab7-gjahr.

    ON CHANGE OF it_bsid-kunnr.
      LOOP AT i_giro WHERE vkbur EQ it_bsid-vkbur AND
                           kunnr EQ it_bsid-kunnr AND
                           kvgr3 EQ it_bsid-kvgr3.
        itab7-giro = itab7-giro + i_giro-cchek.
      ENDLOOP.
      LOOP AT i_giro_sfa WHERE vkbur EQ it_bsid-vkbur AND
                               kunnr EQ it_bsid-kunnr AND
                               kvgr3 EQ it_bsid-kvgr3.
        itab7-giro = itab7-giro + i_giro_sfa-bank_amt.
      ENDLOOP.
    ENDON.

    IF it_bsid-shkzg EQ 'H'.
      it_bsid-dmbtr = it_bsid-dmbtr * -1.
      IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
        it_bsid-zbd1t = 0.
      ENDIF.
    ENDIF.
    IF it_bsid-budat(6) LT p_gerdat(6).
      itab7-begin = itab7-begin + it_bsid-dmbtr.
    ENDIF.

    IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA' AND
       it_bsid-blart NE 'DR'.
      IF it_bsid-budat GE l_gerdat1 AND
         it_bsid-budat LT l_gerdat2.
        itab7-sales = itab7-sales + it_bsid-dmbtr.
      ENDIF.
    ELSE.
      IF it_bsid-budat GE l_gerdat1 AND
         it_bsid-budat LT l_gerdat2.
        itab7-payment = itab7-payment + it_bsid-dmbtr.
      ENDIF.
    ENDIF.

    PERFORM due_brasubcustgr  TABLES lt_bsid.

    itab7-payment = itab7-payment.
    itab7-sales = itab7-sales.
    itab7-ending = itab7-begin + itab7-sales + ( itab7-payment ).
    COLLECT itab7.
  ENDLOOP.
ENDFORM.                    " SUM_BRSUBCUSTGR

*&---------------------------------------------------------------------*
*&      Form  ITAB7
*&---------------------------------------------------------------------*
FORM itab7 .
  APPEND LINES OF itab7 TO itab7_1.
  DELETE itab7_1 WHERE due1 EQ 0.
  APPEND LINES OF itab7 TO itab7_2.
  DELETE itab7_2 WHERE due2 EQ 0.
  APPEND LINES OF itab7 TO itab7_3.
  DELETE itab7_3 WHERE due3 EQ 0.
  APPEND LINES OF itab7 TO itab7_4.
  DELETE itab7_4 WHERE due4 EQ 0.
  APPEND LINES OF itab7 TO itab7_5.
  DELETE itab7_5 WHERE due5 EQ 0.

  IF int1 = space.
    DELETE itab7 WHERE due1 EQ 0.
  ELSEIF int2 = space.
    DELETE itab7 WHERE due2 EQ 0.
  ELSEIF int3 = space.
    DELETE itab7 WHERE due3 EQ 0.
  ELSEIF int4 = space.
    DELETE itab7 WHERE due4 EQ 0.
  ELSEIF int5 = space.
    DELETE itab7 WHERE due5 EQ 0.
  ENDIF.
  REFRESH itab7. CLEAR itab7.

  IF int1 EQ 'X'.
    APPEND LINES OF itab7_1 TO itab7.
  ENDIF.
  IF int2 EQ 'X'.
    APPEND LINES OF itab7_2 TO itab7.
  ENDIF.
  IF int3 EQ 'X'.
    APPEND LINES OF itab7_3 TO itab7.
  ENDIF.
  IF int4 EQ 'X'.
    APPEND LINES OF itab7_4 TO itab7.
  ENDIF.
  IF int5 EQ 'X'.
    APPEND LINES OF itab7_5 TO itab7.
  ENDIF.
  SORT itab7.
  DELETE ADJACENT DUPLICATES FROM itab7 COMPARING ALL FIELDS.
  REFRESH: itab7_1, itab7_2, itab7_3, itab7_4, itab7_5.
  CLEAR: itab7_1, itab7_2, itab7_3, itab7_4, itab7_5.
ENDFORM.                                                    " ITAB7

*&---------------------------------------------------------------------*
*&      Form  WRITE_BRSUBCUSTGR
*&---------------------------------------------------------------------*
FORM write_brsubcustgr .
  DATA : l_lines TYPE i.

  DATA : lt_itab  LIKE itab7 OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_tvv3t OCCURS 0,
           kvgr3  TYPE kvgr3,
           bezei  TYPE bezei20,
         END OF lt_tvv3t.

  DATA : lv_subrc   TYPE sy-subrc.

  DESCRIBE TABLE itab7 LINES l_lines.

  no = 0.
  IF count EQ 1.
    CLEAR itab7.
    READ TABLE itab7 INDEX 1.
    plant = itab7-gsber.
    page = 1.
    PERFORM write_header.
  ENDIF.

  lt_itab[] = itab7[].
  SORT lt_itab BY kvgr3.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING kvgr3.
  IF lt_itab[] IS NOT INITIAL.
    SELECT kvgr3 bezei
      FROM tvv3t
      INTO TABLE lt_tvv3t
      FOR ALL ENTRIES IN lt_itab
      WHERE spras EQ sy-langu
        AND kvgr3 EQ lt_itab-kvgr3.
  ENDIF.

  SORT itab7 BY gsber kvgr3 gjahr.
  LOOP AT itab7.
    PERFORM f_check_write USING itab7-begin itab7-sales
                                itab7-payment itab7-ending
                                itab7-giro
                          CHANGING lv_subrc.
    IF lv_subrc IS INITIAL.
      IF count NE 1.
        ON CHANGE OF itab7-gsber.
          FORMAT COLOR OFF.
          plant = itab7-gsber.
          page = 1.
          PERFORM write_header.
        ENDON.
      ENDIF.
      PERFORM zebra.
      no = no + 1.

      CLEAR lt_tvv3t.
      READ TABLE lt_tvv3t WITH KEY kvgr3 = itab7-kvgr3.
      PERFORM write_detail_brsubcustgr USING lt_tvv3t-bezei.

      AT END OF gsber.
        SUM.
        SKIP 1.
        PERFORM subtotal7.
        IF sy-tabix GE l_lines.
          PERFORM write_bottom.
        ELSE.
          NEW-PAGE.
        ENDIF.
      ENDAT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " WRITE_BRSUBCUSTGR

*&---------------------------------------------------------------------*
*&      Form  DUE_BRASUBCUSTGR
*&---------------------------------------------------------------------*
FORM due_brasubcustgr TABLES ft_bsid  STRUCTURE it_bsid.
  DATA age TYPE i.

  PERFORM get_date_dz.

  PERFORM f_age_calculate TABLES ft_bsid
                          USING it_bsid-bukrs it_bsid-vkbur
                                it_bsid-kunnr it_bsid-zuonr
                                'V' it_bsid-zfbdt it_bsid-zbd1t
                          CHANGING age.

  IF top EQ 'X'.
*    age = p_gerdat - it_bsid-zfbdt.
    IF age LE int1low.
      itab7-due1 = itab7-due1 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab7-due2 = itab7-due2 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab7-due3 = itab7-due3 + it_bsid-dmbtr.
    ELSEIF age GT int3low AND age LE int4low.
      itab7-due4 = itab7-due4 + it_bsid-dmbtr.
    ELSEIF age GT int4low.
      itab7-due5 = itab7-due5 + it_bsid-dmbtr.
    ENDIF.
  ELSE.
    IF age LE 0.
      itab7-due1 = itab7-due1 + it_bsid-dmbtr.
    ELSEIF age GE 1 AND age LE int1low.
      itab7-due2 = itab7-due2 + it_bsid-dmbtr.
    ELSEIF age GT int1low AND age LE int2low.
      itab7-due3 = itab7-due3 + it_bsid-dmbtr.
    ELSEIF age GT int2low AND age LE int3low.
      itab7-due4 = itab7-due4 + it_bsid-dmbtr.
    ELSEIF age GT int3low.
      itab7-due5 = itab7-due5 + it_bsid-dmbtr.
    ENDIF.
  ENDIF.
ENDFORM.                    " DUE_BRASUBCUSTGR

*&---------------------------------------------------------------------*
*&      Form  WRITE_DETAIL_BRSUBCUSTGR
*&---------------------------------------------------------------------*
FORM write_detail_brsubcustgr USING fu_bezei.
  DATA bezei LIKE tvv3t-bezei.
  c1 = 0.

  bezei = fu_bezei.

  WRITE AT /c1(w2) bezei HOTSPOT.c1 = c1 + w2 + 1.
  HIDE: itab7-gsber, itab7-kvgr3.
*WRITE AT C1(W14) ITAB2-GJAHR.C1 = C1 + W14 + 1.
  WRITE AT c1(w3) itab7-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) itab7-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) itab7-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab7-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab7-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
*WRITE AT C1(W8) ITAB-LIMIT CURRENCY 'IDR'.C1 = C1 + W8 + 1.
  WRITE AT c1(w13) itab7-due1 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
  WRITE AT c1(w10) itab7-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) itab7-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) itab7-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) itab7-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
ENDFORM.                    " WRITE_DETAIL_BRSUBCUSTGR

*&---------------------------------------------------------------------*
*&      Form  SUBTOTAL7
*&---------------------------------------------------------------------*
FORM subtotal7 .
  DATA text(40).
  c1 = 0.
  c1 = 4.
  CONCATENATE 'TOTAL' cab INTO text SEPARATED BY space.
  PERFORM format_total.
  WRITE AT /c1(w2) text.c1 = c1 + w2 - 3.
  WRITE AT c1(w3) itab7-begin CURRENCY 'IDR'.c1 = c1 + w3 + 1.
  WRITE AT c1(w4) itab7-sales CURRENCY 'IDR'.c1 = c1 + w4 + 1.
  WRITE AT c1(w5) itab7-payment CURRENCY 'IDR'.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab7-ending CURRENCY 'IDR' .c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab7-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
  WRITE AT c1(w13)  itab7-due1 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
  WRITE AT c1(w10) itab7-due2 CURRENCY 'IDR'.c1 = c1 + w10 + 1.
  WRITE AT c1(w11) itab7-due3 CURRENCY 'IDR'.c1 = c1 + w11 + 1.
  WRITE AT c1(w12) itab7-due4 CURRENCY 'IDR'.c1 = c1 + w12 + 1.
  WRITE AT c1(w13) itab7-due5 CURRENCY 'IDR'.c1 = c1 + w13 + 1.
ENDFORM.                                                    " SUBTOTAL7

*&---------------------------------------------------------------------*
*&      Form  F_AGE_CALCULATE
*&---------------------------------------------------------------------*
FORM f_age_calculate  TABLES   ft_bsid STRUCTURE it_bsid
                      USING    fu_bukrs fu_vkbur fu_kunnr fu_zuonr fu_umskz
                               fu_zfbdt fu_zbd1t
                      CHANGING fc_age.

  READ TABLE ft_bsid WITH KEY bukrs = fu_bukrs
                              vkbur = fu_vkbur
                              kunnr = fu_kunnr
                              zuonr = fu_zuonr
                              umskz = fu_umskz
                     TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    READ TABLE ft_bsid WITH KEY bukrs = fu_bukrs
                                vkbur = fu_vkbur
                                kunnr = fu_kunnr
                                zuonr = fu_zuonr.
    IF sy-subrc = 0.
      fc_age = p_gerdat - ft_bsid-budat.
    ELSE.
      IF top IS NOT INITIAL.
        fc_age = p_gerdat - fu_zfbdt.
      ELSE.
        fc_age = p_gerdat - ( fu_zfbdt + fu_zbd1t ).
      ENDIF.
    ENDIF.
  ELSE.
    IF top IS NOT INITIAL.
      fc_age = p_gerdat - fu_zfbdt.
    ELSE.
      fc_age = p_gerdat - ( fu_zfbdt + fu_zbd1t ).
    ENDIF.
  ENDIF.
ENDFORM.                    " F_AGE_CALCULATE

*&---------------------------------------------------------------------*
*&      Form  F_GET_FROM_BSAD
*&---------------------------------------------------------------------*
FORM f_get_from_bsad  USING    fu_gerdat fu_umskz.
  CASE fu_umskz.
    WHEN 'V'.
      IF x_opdr IS INITIAL.
        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr shkzg zfbdt zbd1t
               blart xref2 zuonr augdt xref1 zterm cpudt kidno bschl umskz
               anln1 sgtxt
          APPENDING CORRESPONDING FIELDS OF TABLE it_bsid
          FROM bsad
          FOR ALL ENTRIES IN gt_kna1
          WHERE kunnr = gt_kna1-kunnr
            AND bukrs = p_bukrs
            AND budat LE p_gerdat
            AND augdt GT fu_gerdat
            AND umskz = fu_umskz
            AND blart IN s_blart
            AND zuonr IN s_do.
      ELSE.
        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr a~shkzg zfbdt zbd1t
               blart xref2 zuonr augdt xref1 zterm cpudt kidno bschl umskz
               a~anln1 a~sgtxt b~vkbur
          APPENDING CORRESPONDING FIELDS OF TABLE it_bsid
          FROM bsad AS a JOIN vbrp AS b ON b~vbeln = a~vbeln AND
                                           b~posnr = '000010'
          WHERE b~vkbur IN s_gsber
            AND bukrs = p_bukrs
            AND budat LE p_gerdat
            AND augdt GT fu_gerdat
            AND umskz = fu_umskz
            AND blart IN s_blart
            AND zuonr IN s_do.
      ENDIF.

    WHEN space.
      IF x_opdr IS INITIAL.
        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr shkzg zfbdt zbd1t
               blart xref2 zuonr augdt xref1 zterm cpudt kidno bschl umskz
               anln1
          APPENDING CORRESPONDING FIELDS OF TABLE it_bsid
          FROM bsad
          FOR ALL ENTRIES IN gt_kna1
          WHERE kunnr = gt_kna1-kunnr
            AND bukrs = p_bukrs
            AND budat LE p_gerdat
            AND augdt GT fu_gerdat
            AND umskz = fu_umskz
            AND blart IN s_blart
            AND zuonr IN s_do.
      ELSE.
        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr a~shkzg zfbdt zbd1t
               blart xref2 zuonr augdt xref1 zterm cpudt kidno bschl umskz
               a~anln1 b~vkbur
          APPENDING CORRESPONDING FIELDS OF TABLE it_bsid
          FROM bsad AS a JOIN vbrp AS b ON b~vbeln = a~vbeln AND
                                           b~posnr = '000010'
          WHERE b~vkbur IN s_gsber
            AND bukrs = p_bukrs
            AND budat LE p_gerdat
            AND augdt GT fu_gerdat
            AND umskz = fu_umskz
            AND blart IN s_blart
            AND zuonr IN s_do.
      ENDIF.

    WHEN OTHERS.
      IF x_opdr IS INITIAL.
        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr shkzg zfbdt zbd1t
               blart xref2 zuonr augdt xref1 zterm cpudt kidno bschl umskz
               anln1
          APPENDING CORRESPONDING FIELDS OF TABLE it_bsid
          FROM bsad
          FOR ALL ENTRIES IN gt_kna1
          WHERE kunnr = gt_kna1-kunnr
            AND bukrs = p_bukrs
            AND budat LE p_gerdat
            AND augdt GT fu_gerdat
            AND umskz IN gr_bschl
            AND blart IN s_blart
            AND zuonr IN s_do.
      ELSE.
        SELECT bukrs kunnr gjahr belnr buzei budat monat dmbtr a~shkzg zfbdt zbd1t
               blart xref2 zuonr augdt xref1 zterm cpudt kidno bschl umskz
               a~anln1 b~vkbur
          APPENDING CORRESPONDING FIELDS OF TABLE it_bsid
          FROM bsad AS a JOIN vbrp AS b ON b~vbeln = a~vbeln AND
                                           b~posnr = '000010'
          WHERE vkbur IN s_gsber
            AND bukrs = p_bukrs
            AND budat LE p_gerdat
            AND augdt GT fu_gerdat
            AND umskz IN gr_bschl
            AND blart IN s_blart
            AND zuonr IN s_do.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_FROM_BSAD

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_WRITE
*&---------------------------------------------------------------------*
FORM f_check_write  USING    fu_begin fu_sales fu_payment fu_ending
                             fu_giro
                    CHANGING fc_subrc.

  fc_subrc = 4.

  IF fu_begin IS NOT INITIAL OR
    fu_sales IS NOT INITIAL OR
    fu_payment IS NOT INITIAL OR
    fu_ending IS NOT INITIAL OR
    fu_giro IS NOT INITIAL.
    CLEAR fc_subrc.
  ENDIF.
ENDFORM.                    " F_CHECK_WRITE

*&---------------------------------------------------------------------*
*&      Form  F_GET_CUSTOMER
*&---------------------------------------------------------------------*
FORM f_get_customer USING fu_proc.
  DATA : lr_vkbur   TYPE RANGE OF vkbur,
         ls_vkbur   LIKE LINE OF lr_vkbur.

  CLEAR ls_vkbur.
  ls_vkbur-low    = '0200'.
  ls_vkbur-high   = '0299'.
  ls_vkbur-sign   = 'I'.
  ls_vkbur-option = 'BT'.
  APPEND ls_vkbur TO lr_vkbur.
  CLEAR ls_vkbur.
  ls_vkbur-low    = 'T220'.
  ls_vkbur-sign   = 'I'.
  ls_vkbur-option = 'EQ'.
  APPEND ls_vkbur TO lr_vkbur.
  CLEAR ls_vkbur.

  IF fu_proc IS INITIAL.
    IF x_opdr IS INITIAL.
      SELECT knvv~kunnr knvv~vkbur knvv~kdgrp knvv~kvgr3 kna1~brsch
        kna1~sortl
        FROM knvv JOIN kna1 ON knvv~kunnr = kna1~kunnr
        INTO CORRESPONDING FIELDS OF TABLE gt_kna1
        WHERE knvv~vkorg = p_bukrs
          AND knvv~kunnr IN s_kunnr
          AND knvv~vkbur IN s_gsber
          AND ( knvv~vtweg = '10' OR knvv~vtweg = '20' )
          AND knvv~kdgrp IN p_kdgrp
          AND knvv~kvgr3 IN p_kvgr3
          AND kna1~brsch IN p_brsch.
    ELSE.
      SELECT knvv~kunnr knvv~vkbur knvv~kdgrp knvv~kvgr3 kna1~brsch
        kna1~sortl
        FROM knvv JOIN kna1 ON knvv~kunnr = kna1~kunnr
        INTO CORRESPONDING FIELDS OF TABLE gt_kna1
        WHERE knvv~vkorg = p_bukrs
          AND knvv~kunnr IN s_kunnr
          AND knvv~vkbur IN lr_vkbur
          AND ( knvv~vtweg = '10' OR knvv~vtweg = '20' )
          AND knvv~kdgrp IN p_kdgrp
          AND knvv~kvgr3 IN p_kvgr3
          AND kna1~brsch IN p_brsch.
    ENDIF.
  ELSE.
    IF t_zfarsoff_add[] IS NOT INITIAL.
      IF x_opdr IS INITIAL.
        SELECT knvv~kunnr knvv~vkbur knvv~kdgrp knvv~kvgr3 kna1~brsch
          kna1~sortl
          FROM knvv JOIN kna1 ON knvv~kunnr = kna1~kunnr
          INTO CORRESPONDING FIELDS OF TABLE gt_kna1_add
          FOR ALL ENTRIES IN t_zfarsoff_add
          WHERE knvv~vkorg = p_bukrs
            AND knvv~kunnr = t_zfarsoff_add-kunnr
            AND knvv~vkbur = t_zfarsoff_add-zvkbur1
            AND ( knvv~vtweg = '10' OR knvv~vtweg = '20' )
            AND knvv~kdgrp IN p_kdgrp
            AND knvv~kvgr3 IN p_kvgr3
            AND kna1~brsch IN p_brsch.
      ELSE.
        SELECT knvv~kunnr knvv~vkbur knvv~kdgrp knvv~kvgr3 kna1~brsch
          kna1~sortl
          FROM knvv JOIN kna1 ON knvv~kunnr = kna1~kunnr
          INTO CORRESPONDING FIELDS OF TABLE gt_kna1_add
          FOR ALL ENTRIES IN t_zfarsoff_add
          WHERE knvv~vkorg = p_bukrs
            AND knvv~kunnr = t_zfarsoff_add-kunnr
            AND knvv~vkbur = t_zfarsoff_add-zvkbur1
            AND ( knvv~vtweg = '10' OR knvv~vtweg = '20' )
            AND knvv~kdgrp IN p_kdgrp
            AND knvv~kvgr3 IN p_kvgr3
            AND kna1~brsch IN p_brsch.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_CUSTOMER

*&---------------------------------------------------------------------*
*&      Form  F_JOIN_BSID_KNA1
*&---------------------------------------------------------------------*
FORM f_join_bsid_kna1 .
  DATA : ls_kna1  TYPE ty_kna1.

  SORT it_bsid BY kunnr.
  SORT gt_kna1 BY kunnr.

  LOOP AT it_bsid.
    CLEAR ls_kna1.
    READ TABLE gt_kna1 INTO ls_kna1
                       WITH KEY kunnr = it_bsid-kunnr
                       BINARY SEARCH.
    IF sy-subrc = 0.
      IF x_opdr IS INITIAL.
        it_bsid-vkbur   = ls_kna1-vkbur.
      ENDIF.
      it_bsid-kdgrp   = ls_kna1-kdgrp.
      it_bsid-kvgr3   = ls_kna1-kvgr3.
      it_bsid-brsch   = ls_kna1-brsch.
      it_bsid-sortl   = ls_kna1-sortl.
      MODIFY it_bsid TRANSPORTING vkbur kdgrp kvgr3 brsch sortl.
    ELSE.
      DELETE it_bsid.
    ENDIF.
    CLEAR it_bsid.
  ENDLOOP.
ENDFORM.                    " F_JOIN_BSID_KNA1

INCLUDE zf_ar_aging_new_v1f01.
