REPORT ZF_DAY_SALES_OUTSTANDING message-id zf no standard page heading
                                    line-size  121.
*                                    LINE-COUNT 68.

************************************************************************
*                  REPORT  TARGET REMITTANCE                           *
*----------------------------------------------------------------------*
* ABAP Name   :  ZF_DAY_SALES_OUTSTANDING                              *
* Created by  :  Sukardi                                               *
* Created on  :  21 Oct 2002                                           *
* Version     :  46c                                                   *
*----------------------------------------------------------------------*
* Description :                                                        *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
* Date    Programmer  Correction  Description
*
*----------------------------------------------------------------------*
************************************************************************
* INCLUDES                                                             *
************************************************************************
include zsheader.
Tables: BKPF, BSEG, BSID, VBRK, VBRP, KNVV, VRKPA, MARA,
        KNVk, TGSB, tgsbt, kna1, T016, T016t,
        T151, T151t, pa0001, t001.

Types:  Begin of t_itab,
            bukrs like bsid-bukrs,
            gsber like bsid-gsber,
            budat like bsid-budat,
            bldat like bsid-bldat,
            gjahr like bsid-gjahr,
            belnr like bsid-belnr,
            kdgrp like knvv-kdgrp,
            brsch like kna1-brsch,
            kunnr like bsid-kunnr,
            blart like bsid-blart,
            shkzg like bsid-shkzg,
            ZBD1T like bsid-ZBD1T,
            zfbdt like bsid-zfbdt,
            zuonr like bsid-zuonr,
            dmbtr like bsid-dmbtr,
            xref1 like bsid-xref1,
            xref2 like bsid-xref2,
            Pernr like vbpa-pernr,
            vwerk like knvv-vwerk,
            name1 like kna1-name1,
            kunde like vrkpa-kunde,
            PARNR like knvk-PARNR,
            VRTNR like knvk-VRTNR,
            SNAME like pa0001-sname,
            ENAME like pa0001-ename,
        End of t_itab.
Types: Begin of t_result,
            bukrs like bsid-bukrs,
            gsber like bsid-gsber,
            kdgrp like knvv-kdgrp,
            brsch like kna1-brsch,
            kunnr like bsid-kunnr,
            kunde like vrkpa-kunde,
            name1 like kna1-name1,
            Pernr like vbpa-pernr,
            PARNR like knvk-PARNR,
            VRTNR like knvk-VRTNR,
            SNAME like pa0001-sname,
            ENAME like pa0001-ename,
            avrsales    type p,
            outstanding type p,
       End of t_result.


Data: i_itab type t_itab occurs 0,
      i_itab1 type t_itab occurs 0,
      i_itab2 type t_itab occurs 0,
      i_itab3 type t_itab occurs 0,
      i_itab_bsid type t_itab occurs 0,
      i_itab_bsad type t_itab occurs 0,
      wa_itab type t_itab,
      i_result type t_result occurs 0,
      i_result1 type t_result occurs 0,
      i_result11 type t_result occurs 0,
      i_result21 type t_result occurs 0,
      i_result31 type t_result occurs 0,
      i_result41 type t_result occurs 0,
      i_result51 type t_result occurs 0,
      i_result61 type t_result occurs 0,
      i_result12 type t_result occurs 0,
      i_result22 type t_result occurs 0,
      i_result32 type t_result occurs 0,
      i_result42 type t_result occurs 0,
      i_result52 type t_result occurs 0,
      i_result62 type t_result occurs 0,
      tmp_result52 type t_result occurs 0,
      tmp_result51 type t_result occurs 0,
      tmp_result42 type t_result occurs 0,
      tmp_result41 type t_result occurs 0,
      va_dmbtr type p,va_lines type i,
      wa_result type t_result,va_lines1 type i,
      wa_result1 type t_result,
      wa_subtotal type t_result,
      wa_total type t_result,
      Jml_hari type i,
      tmp_result22 type t_result occurs 0,
      tmp_result21 type t_result occurs 0,
      tmp_result32 type t_result occurs 0,
      tmp_result31 type t_result occurs 0,
      tmp_result62 type t_result occurs 0,
      tmp_result61 type t_result occurs 0,
      va_flag(1),
      va_flag1(1),
      va_flag2(1),
      va_flag3(1),
      va_flag4(1).


ranges: ra_budat for bsid-budat.
ranges: so_monat for bsid-monat.
data:  va_nou type i,
       va_line type i value 10,
       ctr    type i,
       va_page type i,
       va_PERNR like pa0001-PERNR,
       va_text(30),
       tot_dmbtr1   like regup-dmbtr,
       tot_dmbtr2   like regup-dmbtr,
       c1    type i,
       w0    type i,
       w1    type i,  w2    type i,  w3    type i,  w4    type i,
       w5    type i,  w6    type i,  w7    type i,  w8    type i.


****************************************************
*        Parameters                                *
****************************************************
SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-001.
  Parameters:  pa_bukrs like T001-bukrs obligatory default '8020',
               pa_gsber like bsid-gsber obligatory.
*  Select-options  so_gsber for bsid-gsber.
  Select-options:
*     so_monat for bsid-monat obligatory default sy-datum+4(2),
                  so_kdgrp for knvv-kdgrp, "no intervals,
                  so_brsch for kna1-brsch, "no intervals,
                  so_kunnr for bsid-kunnr,
                  so_UMSKZ for bsid-UMSKZ.
  Parameters   pa_date like sy-datum obligatory default sy-datum.
*  Parameters   pa_gjahr like bsid-gjahr obligatory default sy-datum(4).
SELECTION-SCREEN SKIP 1.

  Parameters   pa_DSO(2) default '03'.
SELECTION-SCREEN END OF BLOCK BLOCK1.

SELECTION-SCREEN SKIP 2.
SELECTION-SCREEN BEGIN OF BLOCK c WITH FRAME TITLE TEXT-002.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : Radio1 RADIOBUTTON GROUP GRP1 DEFAULT 'X'.
    SELECTION-SCREEN : COMMENT 5(45) TEXT-003 FOR FIELD RADIO1.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : Radio2 RADIOBUTTON GROUP GRP1.
    SELECTION-SCREEN : COMMENT 5(45) TEXT-004 FOR FIELD RADIO2.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : Radio3 RADIOBUTTON GROUP GRP1.
    SELECTION-SCREEN : COMMENT 5(45) TEXT-005 FOR FIELD RADIO3.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : Radio4 RADIOBUTTON GROUP GRP1.
    SELECTION-SCREEN : COMMENT 5(45) TEXT-006 FOR FIELD RADIO4.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : Radio5 RADIOBUTTON GROUP GRP1.
    SELECTION-SCREEN : COMMENT 5(45) TEXT-007 FOR FIELD RADIO5.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : Radio6 RADIOBUTTON GROUP GRP1.
    SELECTION-SCREEN : COMMENT 5(50) TEXT-008 FOR FIELD RADIO6.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK c.

************************************************************************
* PROGRAM                                                              *
************************************************************************
************************************************************************
* AT SELECTION-SCREEN
************************************************************************
at selection-screen on so_kunnr .
Select single * from kna1
       where kunnr in so_kunnr.
if sy-subrc ne 0.
    message e000(ZF) with 'Customer Number Not Found'.
Endif.

at selection-screen on so_KDGRP.
Select single * from T151
       where KDGRP in so_KDGRP.
if sy-subrc ne 0.
    message e000(ZF) with 'Customer Group Not Found'.
Endif.

at selection-screen on so_BRSCH.
Select single * from T016
       where BRSCH in so_BRSCH.
if sy-subrc ne 0.
    message e000(ZF) with 'Industry Code Not Found'.
Endif.

at selection-screen on pa_bukrs.
Select single butxt into V_TITLE1 from t001 where bukrs eq pa_bukrs.
if sy-subrc ne 0.
    message e000(ZF) with 'Company  Not Found'.
Endif.
if pa_bukrs eq '8020' or pa_bukrs eq '8030'.
else.
  message E000(ZS)
    with 'Company Code must be entry (8020, 8030)'.
endif.

at selection-screen on pa_gsber.
Select Single * from TGSB
       where gsber eq pa_gsber.
if sy-subrc ne 0.
    message e000(ZF) with 'Business Area Not Found'.
Endif.

************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.

************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.
  SET PF-STATUS '100'.
*  sy-pagno = 1.
  perform cek.

  V_REPID = 'Day Sales Outstanding'.
  PERFORM f_init_column.
  Perform f_get_data.
   DESCRIBE TABLE i_itab LINES c1.
   if c1 <= 0.
         write: / 'No Data'.
         Exit.
   endif.
   Write ra_budat-low to va_text.
   Write ra_budat-high to v_title3.
   Concatenate 'Periode ' va_text 'to' v_title3
       into v_title3 separated by space.
if radio1 = 'X'.
    Perform f_proses1.
Endif.
if radio2 = 'X'.
    Perform f_proses2.
Endif.
if radio3 = 'X'.
    Perform f_proses3.
Endif.
if radio4 = 'X'.
    Perform f_proses4.
Endif.
if radio5 = 'X'.
    Perform f_proses5.
Endif.
********* Req. By DIW (11 - 03 - 2004)
********* Change By sukardi (11 - 03 - 2004)
********* Add List by Customer Group Nasional
if radio6 = 'X'.
    Perform f_proses6.
Endif.
********* End Add
top-of-page.
*   Perform f_write_header.
*   Perform f_write_header_column.
end-of-page.
AT USER-COMMAND.
   sy-lsind = 0.
   CASE SY-UCOMM.
        when 'BRANCH'.
            Perform f_proses1.
        when 'CUSTOMER'.
            Perform f_proses4.
        when 'SALESMAN'.
            Perform f_proses3.
        when 'CUSTGROUP'.
            Perform f_proses2.
        when 'INDUSTRY'.
            Perform f_proses5.
        when 'GROUPNAS'.
            Perform f_proses6.
        when 'CANCEL'.
            Leave to screen 0.
        when 'EXIT'.
            leave  program.
   Endcase.

*&---------------------------------------------------------------------*
*&      Form  f_init_column
*&---------------------------------------------------------------------*
FORM f_init_column.
  w1   =   5.
  w2   =  50.
  w3   =  20.
  c1 = 0.
ENDFORM.                    " f_init_column
*&---------------------------------------------------------------------*
*&      Form  f_proses1
*&---------------------------------------------------------------------*
FORM f_proses1.
    if i_result11 is initial.
        Sort i_itab by bukrs gsber.
        clear: wa_itab, wa_result, i_result11.
        Loop at i_itab into wa_itab.
           on change of wa_itab-bukrs or
                        wa_itab-gsber.
              if wa_result-gsber ne space.
                 wa_result-avrsales = wa_result-avrsales / Jml_hari.
                 append wa_result to i_result11.
                 clear wa_result.
              Endif.
           endon.
           move wa_itab-bukrs to wa_result-bukrs.
           move wa_itab-gsber to wa_result-gsber.
           move wa_itab-kdgrp to wa_result-kdgrp.
           move wa_itab-kunnr to wa_result-kunnr.
           move wa_itab-name1 to wa_result-name1.
           perform f_hitung.
           clear wa_itab.
        Endloop.
        if wa_result-gsber ne space.
            wa_result-avrsales = wa_result-avrsales / Jml_hari.
            append wa_result to i_result11.
            clear wa_result.
        Endif.
        Sort i_itab3 by bukrs gsber.
        clear: wa_itab, wa_result, i_result12.
        Loop at i_itab3 into wa_itab.
           on change of wa_itab-bukrs or
                        wa_itab-gsber.
              if wa_result-gsber ne space.
                 wa_result-avrsales = wa_result-avrsales / Jml_hari.
                 append wa_result to i_result12.
                 clear wa_result.
              Endif.
           endon.
           move wa_itab-bukrs to wa_result-bukrs.
           move wa_itab-gsber to wa_result-gsber.
           move wa_itab-kdgrp to wa_result-kdgrp.
           move wa_itab-kunnr to wa_result-kunnr.
           move wa_itab-name1 to wa_result-name1.
           perform f_hitung.
           clear wa_itab.
        Endloop.
        if wa_result-gsber ne space.
             wa_result-avrsales = wa_result-avrsales / Jml_hari.
             append wa_result to i_result12.
             clear wa_result.
        Endif.
    Endif.
     v_title2 = 'Day Sales Outstanding Per Branch'.
     perform f_write_header.
     Perform f_write_header_column using 'Branch'.
     clear: va_nou, wa_total, wa_subtotal.
     v_current_page = 1.
     Clear: wa_result, wa_result1.
     Loop at i_result11 into wa_result.
        select single * from tgsbt where gsber eq wa_result-gsber and
                               ( spras eq 'EN' or spras eq 'E' ).
        concatenate wa_result-gsber tgsbt-gtext
                into va_text separated by ' - '.
        add 1 to va_nou.
        c1 = 1.
        write: /  sy-vline.
        c1 = c1 + 1.
        write at c1(w1) va_nou no-gap. c1 = c1 + w1.
        write at c1(1) sy-vline no-gap. c1 = c1 + 1.
        write at c1(w2) va_text no-gap. c1 = c1 + w2.
        write at c1(1) sy-vline no-gap. c1 = c1 + 1.
        Perform f_write_detail.
        clear wa_result1.
        Loop at i_result12 into wa_result1
             where gsber eq wa_result-gsber and
                   bukrs eq wa_result-bukrs.
*               Clear wa_result1.
        Endloop.
        Perform f_write_detail1.
        clear wa_result.
     Endloop.
     Perform f_write_total.
ENDFORM.                    " f_proses1
*&---------------------------------------------------------------------*
*&      Form  f_proses2
*&---------------------------------------------------------------------*
FORM f_proses2.
data: ltext(50).
    if i_result21 is initial.
        Sort i_itab by bukrs gsber kdgrp.
        clear: wa_itab, wa_result, i_result21.
        Loop at i_itab into wa_itab.
           on change of wa_itab-bukrs or
                        wa_itab-gsber or
                        wa_itab-kdgrp.
              if wa_result-kdgrp ne space.
                 wa_result-avrsales = wa_result-avrsales / Jml_hari.
                 append wa_result to i_result21.
                 clear wa_result.
              Endif.
           endon.
           move wa_itab-bukrs to wa_result-bukrs.
           move wa_itab-gsber to wa_result-gsber.
           move wa_itab-kdgrp to wa_result-kdgrp.
           move wa_itab-kunnr to wa_result-kunnr.
           move wa_itab-name1 to wa_result-name1.
           perform f_hitung.
           clear wa_itab.
        Endloop.
        if wa_result-kdgrp ne space.
            wa_result-avrsales = wa_result-avrsales / Jml_hari.
            append wa_result to i_result21.
            clear wa_result.
        Endif.
        Sort i_itab3 by bukrs gsber kdgrp.
        clear: wa_itab, wa_result, i_result22.

        Loop at i_itab3 into wa_itab.
           on change of wa_itab-bukrs or
                        wa_itab-gsber or
                        wa_itab-kdgrp.
              if wa_result-kdgrp ne space.
                 wa_result-avrsales = wa_result-avrsales / Jml_hari.
                 append wa_result to i_result22.
                 clear wa_result.
              Endif.
           endon.
           move wa_itab-bukrs to wa_result-bukrs.
           move wa_itab-gsber to wa_result-gsber.
           move wa_itab-kdgrp to wa_result-kdgrp.
           move wa_itab-kunnr to wa_result-kunnr.
           move wa_itab-name1 to wa_result-name1.
           perform f_hitung.
           clear wa_itab.
        Endloop.
        if wa_result-kdgrp ne space.
               wa_result-avrsales = wa_result-avrsales / Jml_hari.
               append wa_result to i_result22.
               clear wa_result.
        Endif.
    Endif.
     v_title2 = 'Day Sales Outstanding Per Customer Group'.
     perform f_write_header.
     Perform f_write_header_column using 'Customer Group'.
     clear: va_nou, wa_total, wa_subtotal.
     v_current_page = 1.

**** Add 23-01-2003 by ars
     DESCRIBE TABLE i_result21 LINES va_lines.
     DESCRIBE TABLE i_result22 LINES va_lines1.

     if va_lines < va_lines1.
        append lines of i_result21 to tmp_result21.
        append lines of i_result22 to tmp_result22.
        refresh : i_result21,i_result22.
        append lines of tmp_result21 to i_result22.
        append lines of tmp_result22 to i_result21.
        refresh :tmp_result21,tmp_result22.
        va_flag1 = 'X'.
     endif.
**** End

     Clear: wa_result, wa_result1.
     Loop at i_result21 into wa_result.
        at new gsber.
          select single * from tgsbt where gsber eq wa_result-gsber and
                                ( spras eq 'EN' or spras eq 'E' ).

            c1 = 1.
            write: /  sy-vline.
            c1 = c1 + 1.
            concatenate wa_result-gsber tgsbt-gtext
                into va_text separated by '-'.
            write at c1(w2) va_text no-gap. c1 = c1 + w2.
            c1 = c1 + 1. c1 = c1 + w1.
            write at c1(1) sy-vline no-gap. c1 = c1 + 1.
            PERFORM F_WRITE_KOSONG.

        endat.
        add 1 to va_nou.
        c1 = 1.
        write: /  sy-vline.
        c1 = c1 + 1.
        Select single * from t151t where kdgrp eq wa_result-kdgrp and
                                ( spras eq 'EN' or spras eq 'E' ).
        if sy-subrc ne 0.
             t151t-ktext = 'Othes'.
        endif.
        concatenate wa_result-kdgrp t151t-ktext
            into ltext separated by '-'.
        write at c1(w1) va_nou no-gap. c1 = c1 + w1.
        write at c1(1) sy-vline no-gap. c1 = c1 + 1.
        write at c1(w2) ltext no-gap. c1 = c1 + w2.
        write at c1(1) sy-vline no-gap. c1 = c1 + 1.

       if va_lines >= va_lines1 and va_flag1 eq space.
        Perform f_write_detail.
               Clear wa_result1.
        Loop at i_result22 into wa_result1
             where gsber eq wa_result-gsber and
                   bukrs eq wa_result-bukrs and
                   kdgrp eq wa_result-kdgrp.
        Endloop.
               Perform f_write_detail1.
       else.
             Clear wa_result1.
        Loop at i_result22 into wa_result1
             where gsber eq wa_result-gsber and
                   bukrs eq wa_result-bukrs and
                   kdgrp eq wa_result-kdgrp.
        Endloop.
               wa_result1-outstanding = wa_result-outstanding.
               wa_result-avrsales = wa_result1-avrsales.
               Perform f_write_detail.
               Perform f_write_detail1.

       endif.
        at end of gsber.
          concatenate 'Sub Total' va_text into ltext separated by space.
           Perform f_write_subtotal using ltext.
           clear: wa_subtotal, VA_NOU.
        endat.         clear wa_result.

     Endloop.
     Perform f_write_total.

ENDFORM.                    " f_proses2
*&---------------------------------------------------------------------*
*&      Form  f_proses3
*&---------------------------------------------------------------------*
FORM f_proses3.
data: ltext type text50.
    if i_result31 is initial.
        Sort i_itab by bukrs gsber pernr.
        clear: wa_itab, wa_result, i_result31.
        Loop at i_itab into wa_itab.
           on change of wa_itab-bukrs or
                        wa_itab-gsber or
                        wa_itab-pernr.
              if wa_result-pernr ne space.
                 wa_result-avrsales = wa_result-avrsales / Jml_hari.
                 append wa_result to i_result31.
                 clear wa_result.
              Endif.
           endon.
           move wa_itab-bukrs to wa_result-bukrs.
           move wa_itab-gsber to wa_result-gsber.
           move wa_itab-kdgrp to wa_result-kdgrp.
           move wa_itab-kunnr to wa_result-kunnr.
           move wa_itab-name1 to wa_result-name1.
           move wa_itab-pernr to wa_result-pernr.
           perform f_hitung.
           clear wa_itab.
        Endloop.
        if wa_result-pernr ne space.
            wa_result-avrsales = wa_result-avrsales / Jml_hari.
            append wa_result to i_result31.
            clear wa_result.
        Endif.
        Sort i_itab3 by bukrs gsber pernr.
        clear: wa_itab, wa_result, i_result32.
        Loop at i_itab3 into wa_itab.
           on change of wa_itab-bukrs or
                        wa_itab-gsber or
                        wa_itab-pernr.
              if wa_result-pernr ne space.
                 wa_result-avrsales = wa_result-avrsales / Jml_hari.
                 append wa_result to i_result32.
                 clear wa_result.
              Endif.
           endon.
           move wa_itab-bukrs to wa_result-bukrs.
           move wa_itab-gsber to wa_result-gsber.
           move wa_itab-kdgrp to wa_result-kdgrp.
           move wa_itab-kunnr to wa_result-kunnr.
           move wa_itab-name1 to wa_result-name1.
           move wa_itab-pernr to wa_result-pernr.
*           Select single
           perform f_hitung.
           clear wa_itab.
        Endloop.
        if wa_result-Pernr ne space.
           wa_result-avrsales = wa_result-avrsales / Jml_hari.
           append wa_result to i_result32.
           clear wa_result.
        Endif.
    Endif.
     v_title2 = 'Day Sales Outstanding Per Salesman'.
     perform f_write_header.
     Perform f_write_header_column using 'Salesman'.
     clear: va_nou, wa_total, wa_subtotal.
     v_current_page = 1.

**** Add 23-01-2003 by ars
     DESCRIBE TABLE i_result31 LINES va_lines.
     DESCRIBE TABLE i_result32 LINES va_lines1.

     if va_lines < va_lines1.
        append lines of i_result31 to tmp_result31.
        append lines of i_result32 to tmp_result32.
        refresh : i_result31,i_result32.
        append lines of tmp_result31 to i_result32.
        append lines of tmp_result32 to i_result31.
        refresh :tmp_result31,tmp_result32.
        va_flag2 = 'X'.
     endif.
**** End

     Clear: wa_result, wa_result1.
     Loop at i_result31 into wa_result.
        at new gsber.
          select single * from tgsbt where gsber eq wa_result-gsber and
                                ( spras eq 'EN' or spras eq 'E' ).

            c1 = 1.
            write: /  sy-vline.
            c1 = c1 + 1.
            concatenate wa_result-gsber tgsbt-gtext
                into va_text separated by '-'.
            write at c1(w2) va_text no-gap. c1 = c1 + w2.
            c1 = c1 + 1. c1 = c1 + w1.
            write at c1(1) sy-vline no-gap. c1 = c1 + 1.
            PERFORM F_WRITE_KOSONG.

        endat.
        add 1 to va_nou.
        c1 = 1.
        write: /  sy-vline.
        c1 = c1 + 1.
        Select single sname ename
                   into (wa_result-sname, wa_result-ename) from pa0001
                   where pernr eq wa_result-pernr.
        if sy-subrc ne 0.
             wa_result-sname = 'Others'.
             wa_result-ename = 'Others'.
        endif.
        clear ltext.
        concatenate wa_result-pernr wa_result-sname wa_result-ename
           into ltext separated by space.
        write at c1(w1) va_nou no-gap. c1 = c1 + w1.
        write at c1(1) sy-vline no-gap. c1 = c1 + 1.
        write at c1(w2) ltext no-gap. c1 = c1 + w2.
        write at c1(1) sy-vline no-gap. c1 = c1 + 1.

      if va_lines >= va_lines1 and va_flag2 eq space.

        Perform f_write_detail.
               Clear wa_result1.
        Loop at i_result32 into wa_result1
             where gsber eq wa_result-gsber and
                   bukrs eq wa_result-bukrs and
                   pernr eq wa_result-pernr.
        Endloop.
               Perform f_write_detail1.
       else.
               Clear wa_result1.
        Loop at i_result32 into wa_result1
             where gsber eq wa_result-gsber and
                   bukrs eq wa_result-bukrs and
                   pernr eq wa_result-pernr.
        Endloop.
               wa_result1-outstanding = wa_result-outstanding.
               wa_result-avrsales = wa_result1-avrsales.
               Perform f_write_detail.
               Perform f_write_detail1.

       endif.
        at end of gsber.
           concatenate 'Sub Total' va_text into ltext separated by space
.
           Perform f_write_subtotal using ltext.
           clear: wa_subtotal, VA_NOU.
        endat.         clear wa_result.

     Endloop.
     Perform f_write_total.
ENDFORM.                    " f_proses3

*&---------------------------------------------------------------------*
*&      Form  f_proses4
*&---------------------------------------------------------------------*
FORM f_proses4.
data: ltext(50).
    if i_result41 is initial.
        Sort i_itab by bukrs gsber kunnr.
        clear: wa_itab, wa_result, i_result41.
        Loop at i_itab into wa_itab.
           on change of wa_itab-bukrs or
                        wa_itab-gsber or
                        wa_itab-kunnr.
              if wa_result-kunnr ne space.
                 wa_result-avrsales = wa_result-avrsales / Jml_hari.
                 append wa_result to i_result41.
                 clear wa_result.
              Endif.
           endon.
           move wa_itab-bukrs to wa_result-bukrs.
           move wa_itab-gsber to wa_result-gsber.
           move wa_itab-kdgrp to wa_result-kdgrp.
           move wa_itab-kunnr to wa_result-kunnr.
           move wa_itab-name1 to wa_result-name1.
           perform f_hitung.
           clear wa_itab.
        Endloop.
        if wa_result-kunnr ne space.
            wa_result-avrsales = wa_result-avrsales / Jml_hari.
            append wa_result to i_result41.
            clear wa_result.
        Endif.
        Sort i_itab3 by bukrs gsber kunnr.
        clear: wa_itab, wa_result, i_result42.
        Loop at i_itab3 into wa_itab.
           on change of wa_itab-bukrs or
                        wa_itab-gsber or
                        wa_itab-kunnr.
              if wa_result-kunnr ne space.
                 wa_result-avrsales = wa_result-avrsales / Jml_hari.
                 append wa_result to i_result42.
                 clear wa_result.
              Endif.
           endon.
           move wa_itab-bukrs to wa_result-bukrs.
           move wa_itab-gsber to wa_result-gsber.
           move wa_itab-kdgrp to wa_result-kdgrp.
           move wa_itab-kunnr to wa_result-kunnr.
           move wa_itab-name1 to wa_result-name1.
           perform f_hitung.
           clear wa_itab.
        Endloop.
        if wa_result-kunnr ne space.
           wa_result-avrsales = wa_result-avrsales / Jml_hari.
           append wa_result to i_result42.
           clear wa_result.
        Endif.
    Endif.
     v_title2 = 'Day Sales Outstanding Per Customer'.
     perform f_write_header.
     Perform f_write_header_column using 'Customer'.
     clear: va_nou, wa_total, wa_subtotal.
     v_current_page = 1.

**** Add 23-01-2003 by ars
     DESCRIBE TABLE i_result41 LINES va_lines.
     DESCRIBE TABLE i_result42 LINES va_lines1.

     if va_lines < va_lines1.
        append lines of i_result41 to tmp_result41.
        append lines of i_result42 to tmp_result42.
        refresh : i_result41,i_result42.
        append lines of tmp_result41 to i_result42.
        append lines of tmp_result42 to i_result41.
        refresh :tmp_result41,tmp_result42.
        va_flag = 'X'.
     endif.
**** End
     Clear: wa_result, wa_result1.
     Loop at i_result41 into wa_result.
        at new gsber.
          select single * from tgsbt where gsber eq wa_result-gsber and
                                ( spras eq 'EN' or spras eq 'E' ).

            c1 = 1.
            write: /  sy-vline.
            c1 = c1 + 1.
            concatenate wa_result-gsber tgsbt-gtext
                into va_text separated by '-'.
            write at c1(w2) va_text no-gap. c1 = c1 + w2.
            c1 = c1 + 1. c1 = c1 + w1.
            write at c1(1) sy-vline no-gap. c1 = c1 + 1.
            PERFORM F_WRITE_KOSONG.

        endat.
        add 1 to va_nou.
        c1 = 1.
        write: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-KUNNR wa_result-name1
              INTO wa_result-name1 SEPARATED BY '-'.
        write at c1(w1) va_nou no-gap. c1 = c1 + w1.
        write at c1(1) sy-vline no-gap. c1 = c1 + 1.
        write at c1(w2) wa_result-name1 no-gap. c1 = c1 + w2.
        write at c1(1) sy-vline no-gap. c1 = c1 + 1.

**** Add 23-01-2003 by ars
        if va_lines >= va_lines1 and va_flag eq space.
****  End
        Perform f_write_detail.
               Clear wa_result1.
        Loop at i_result42 into wa_result1
             where gsber eq wa_result-gsber and
                   bukrs eq wa_result-bukrs and
                   kunnr eq wa_result-kunnr.
        Endloop.
               Perform f_write_detail1.

**** Add 23-01-2003 by ars
        else.
               Clear wa_result1.
        Loop at i_result42 into wa_result1
             where gsber eq wa_result-gsber and
                   bukrs eq wa_result-bukrs and
                   kunnr eq wa_result-kunnr.
        Endloop.
               wa_result1-outstanding = wa_result-outstanding.
               wa_result-avrsales = wa_result1-avrsales.

               Perform f_write_detail.
               Perform f_write_detail1.
        endif.
**** End
        at end of gsber.
           concatenate 'Sub Total' va_text
              into ltext separated by space.
           Perform f_write_subtotal using ltext.
           clear: wa_subtotal, VA_NOU.
        endat.         clear wa_result.

     Endloop.
     Perform f_write_total.
ENDFORM.                    " f_proses4

*&---------------------------------------------------------------------*
*&      Form  f_proses5
*&---------------------------------------------------------------------*
FORM f_proses5.
data: ltext(50).
    if i_result51 is initial.
        Sort i_itab by bukrs gsber brsch.
        clear: wa_itab, wa_result, i_result51.
        Loop at i_itab into wa_itab.
           on change of wa_itab-bukrs or
                        wa_itab-gsber or
                        wa_itab-brsch.
              if wa_result-brsch ne space.
                 wa_result-avrsales = wa_result-avrsales / Jml_hari.
                 append wa_result to i_result51.
                 clear wa_result.
              Endif.
           endon.
           move wa_itab-bukrs to wa_result-bukrs.
           move wa_itab-gsber to wa_result-gsber.
           move wa_itab-kdgrp to wa_result-kdgrp.
           move wa_itab-brsch to wa_result-brsch.
           move wa_itab-kunnr to wa_result-kunnr.
           move wa_itab-name1 to wa_result-name1.
           perform f_hitung.
           clear wa_itab.
        Endloop.
        if wa_result-brsch ne space.
            wa_result-avrsales = wa_result-avrsales / Jml_hari.
            append wa_result to i_result51.
            clear wa_result.
        Endif.
        Sort i_itab3 by bukrs gsber brsch.
        clear: wa_itab, wa_result, i_result52.

        Loop at i_itab3 into wa_itab.
           on change of wa_itab-bukrs or
                        wa_itab-gsber or
                        wa_itab-brsch.
              if wa_result-brsch ne space.
                 wa_result-avrsales = wa_result-avrsales / Jml_hari.
                 append wa_result to i_result52.
                 clear wa_result.
              Endif.
           endon.
           move wa_itab-bukrs to wa_result-bukrs.
           move wa_itab-gsber to wa_result-gsber.
           move wa_itab-kdgrp to wa_result-kdgrp.
           move wa_itab-brsch to wa_result-brsch.
           move wa_itab-kunnr to wa_result-kunnr.
           move wa_itab-name1 to wa_result-name1.
           perform f_hitung.
           clear wa_itab.
        Endloop.
        if wa_result-brsch ne space.
               wa_result-avrsales = wa_result-avrsales / Jml_hari.
               append wa_result to i_result52.
               clear wa_result.
        Endif.
    Endif.
     v_title2 = 'Day Sales Outstanding Per Industry Code'.
     perform f_write_header.
     Perform f_write_header_column using 'Industry Code'.
     clear: va_nou, wa_total, wa_subtotal.
     v_current_page = 1.

**** Add 23-01-2003 by ars
     DESCRIBE TABLE i_result51 LINES va_lines.
     DESCRIBE TABLE i_result52 LINES va_lines1.

     if va_lines < va_lines1.
        append lines of i_result51 to tmp_result51.
        append lines of i_result52 to tmp_result52.
        refresh : i_result51,i_result52.
        append lines of tmp_result51 to i_result52.
        append lines of tmp_result52 to i_result51.
        refresh :tmp_result51,tmp_result52.
        va_flag3 = 'X'.
     endif.
**** End

     Clear: wa_result, wa_result1.
     Loop at i_result51 into wa_result.
        at new gsber.
          select single * from tgsbt where gsber eq wa_result-gsber and
                                ( spras eq 'EN' or spras eq 'E' ).

            c1 = 1.
            write: /  sy-vline.
            c1 = c1 + 1.
            concatenate wa_result-gsber tgsbt-gtext
                into va_text separated by '-'.
            write at c1(w2) va_text no-gap. c1 = c1 + w2.
            c1 = c1 + 1. c1 = c1 + w1.
            write at c1(1) sy-vline no-gap. c1 = c1 + 1.
            PERFORM F_WRITE_KOSONG.

        endat.
        add 1 to va_nou.
        c1 = 1.
        write: /  sy-vline.
        c1 = c1 + 1.
        Select single * from t016t where brsch eq wa_result-brsch and
                                ( spras eq 'EN' or spras eq 'E' ).
        if sy-subrc ne 0.
             t016t-brtxt = 'Othes'.
        endif.
        concatenate wa_result-brsch t016t-brtxt
            into ltext separated by '-'.
        write at c1(w1) va_nou no-gap. c1 = c1 + w1.
        write at c1(1) sy-vline no-gap. c1 = c1 + 1.
        write at c1(w2) ltext no-gap. c1 = c1 + w2.
        write at c1(1) sy-vline no-gap. c1 = c1 + 1.

       if va_lines >= va_lines1 and va_flag3 eq space.
        Perform f_write_detail.
               Clear wa_result1.
        Loop at i_result52 into wa_result1
             where gsber eq wa_result-gsber and
                   bukrs eq wa_result-bukrs and
                   brsch eq wa_result-brsch.
        Endloop.
               Perform f_write_detail1.
       else.
             Clear wa_result1.
        Loop at i_result52 into wa_result1
             where gsber eq wa_result-gsber and
                   bukrs eq wa_result-bukrs and
                   brsch eq wa_result-brsch.
        Endloop.
               wa_result1-outstanding = wa_result-outstanding.
               wa_result-avrsales = wa_result1-avrsales.
               Perform f_write_detail.
               Perform f_write_detail1.

       endif.
        at end of gsber.
          concatenate 'Sub Total' va_text into ltext separated by space.
           Perform f_write_subtotal using ltext.
           clear: wa_subtotal, VA_NOU.
        endat.         clear wa_result.

     Endloop.
     Perform f_write_total.

ENDFORM.                    " f_proses5


FORM f_proses6.
data: ltext(50).
    if i_result61 is initial.
        Sort i_itab by bukrs kdgrp.
        clear: wa_itab, wa_result, i_result61.
        Loop at i_itab into wa_itab.
           on change of wa_itab-bukrs or
                        wa_itab-kdgrp.
              if wa_result-kdgrp ne space.
                 wa_result-avrsales = wa_result-avrsales / Jml_hari.
                 append wa_result to i_result61.
                 clear wa_result.
              Endif.
           endon.
           move wa_itab-bukrs to wa_result-bukrs.
           move wa_itab-gsber to wa_result-gsber.
           move wa_itab-kdgrp to wa_result-kdgrp.
           move wa_itab-kunnr to wa_result-kunnr.
           move wa_itab-name1 to wa_result-name1.
           perform f_hitung.
           clear wa_itab.
        Endloop.
        if wa_result-kdgrp ne space.
            wa_result-avrsales = wa_result-avrsales / Jml_hari.
            append wa_result to i_result61.
            clear wa_result.
        Endif.
        Sort i_itab3 by bukrs kdgrp.
        clear: wa_itab, wa_result, i_result62.

        Loop at i_itab3 into wa_itab.
           on change of wa_itab-bukrs or
                        wa_itab-kdgrp.
              if wa_result-kdgrp ne space.
                 wa_result-avrsales = wa_result-avrsales / Jml_hari.
                 append wa_result to i_result62.
                 clear wa_result.
              Endif.
           endon.
           move wa_itab-bukrs to wa_result-bukrs.
           move wa_itab-gsber to wa_result-gsber.
           move wa_itab-kdgrp to wa_result-kdgrp.
           move wa_itab-kunnr to wa_result-kunnr.
           move wa_itab-name1 to wa_result-name1.
           perform f_hitung.
           clear wa_itab.
        Endloop.
        if wa_result-kdgrp ne space.
               wa_result-avrsales = wa_result-avrsales / Jml_hari.
               append wa_result to i_result62.
               clear wa_result.
        Endif.
    Endif.
     v_title2 = 'Day Sales Outstanding Per Customer Group Nasional'.
     perform f_write_header.
     Perform f_write_header_column using 'Customer Group'.
     clear: va_nou, wa_total, wa_subtotal.
     v_current_page = 1.

**** Add 23-01-2003 by ars
     DESCRIBE TABLE i_result61 LINES va_lines.
     DESCRIBE TABLE i_result62 LINES va_lines1.

     if va_lines < va_lines1.
        append lines of i_result61 to tmp_result61.
        append lines of i_result62 to tmp_result62.
        refresh : i_result61,i_result62.
        append lines of tmp_result61 to i_result62.
        append lines of tmp_result62 to i_result61.
        refresh :tmp_result61,tmp_result62.
        va_flag4 = 'X'.
     endif.
**** End
     Sort i_result61 by bukrs kdgrp.
     Sort i_result62 by bukrs kdgrp.
     Clear: wa_result, wa_result1.
     Loop at i_result61 into wa_result.
        add 1 to va_nou.
        c1 = 1.
        write: /  sy-vline.
        c1 = c1 + 1.
        Select single * from t151t where kdgrp eq wa_result-kdgrp and
                                ( spras eq 'EN' or spras eq 'E' ).
        if sy-subrc ne 0.
             t151t-ktext = 'Othes'.
        endif.
        concatenate wa_result-kdgrp t151t-ktext
            into ltext separated by '-'.
        write at c1(w1) va_nou no-gap. c1 = c1 + w1.
        write at c1(1) sy-vline no-gap. c1 = c1 + 1.
        write at c1(w2) ltext no-gap. c1 = c1 + w2.
        write at c1(1) sy-vline no-gap. c1 = c1 + 1.
       if va_lines >= va_lines1 and va_flag4 eq space.
              Perform f_write_detail.
                     Clear wa_result1.
              Loop at i_result62 into wa_result1
                   where kdgrp eq wa_result-kdgrp and
                         bukrs eq wa_result-bukrs.
              Endloop.
              Perform f_write_detail1.
       else.
             Clear wa_result1.
             Loop at i_result62 into wa_result1
                   where kdgrp eq wa_result-kdgrp and
                         bukrs eq wa_result-bukrs.
             Endloop.
             wa_result1-outstanding = wa_result-outstanding.
             wa_result-avrsales = wa_result1-avrsales.
             Perform f_write_detail.
             Perform f_write_detail1.

       endif.
        clear wa_result.
     Endloop.
     Perform f_write_total.


ENDFORM.                    " f_proses6
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
FORM f_get_data.
data: month like bsid-monat, year like bsid-gjahr.
break tds_dev01.
Clear: wa_itab, i_itab, i_itab1, i_itab2.
if pa_Date is initial.
  ra_budat-high = sy-datum.
Else.
  ra_budat-high = pa_Date.
Endif.
if ra_budat-high+4(2) < pa_dso.
   month = ra_budat-high+4(2) + 12 - pa_dso + 1.
    year = ra_budat-high(4) - 1.
Else.
   month = ra_budat-high+4(2) - pa_dso + 1.
   year =  ra_budat-high(4).
Endif.
if month > ra_budat-high+4(2).
Else.
Endif.
concatenate year month '01' into ra_budat-low.
ra_budat-sign = 'I'.
ra_budat-option = 'BT'.
append ra_budat.

Jml_hari = ra_budat-high - ra_budat-low + 1.

*****Add 21-01-2003
if so_UMSKZ is initial.
   so_umskz-low = space.
   so_umskz-high = space.
   so_umskz-sign = 'I'.
   so_umskz-option = 'EQ'.
   append so_umskz.
endif.
      Select a~Bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart
             b~name1 b~brsch c~KDGRP c~vwerk d~pernr
             into CORRESPONDING FIELDS of table i_itab_bsid
             from bsid as a join kna1 as b on a~kunnr eq b~kunnr
                            join knvv as c on c~kunnr eq a~kunnr and
                                              c~vkorg eq a~bukrs and
                                              c~vtweg eq '10' and
                                              c~spart eq '00'
                       left join vbpa as d on  a~belnr eq d~vbeln and
                                               d~parvw eq 'ZP'
             where a~bukrs eq pa_bukrs and
                   a~hkont in ( select saknr from skat
                       where ( spras eq 'EN' or spras eq 'E'  ) and
                             KTOPL Eq 'TSPC' ) and
                   a~umsks eq space and
                   a~gjahr <= pa_date(4) and
                   a~budat <= pa_date and
                   a~kunnr in so_kunnr and
                   a~UMSKZ in so_UMSKZ and
                   c~vkorg eq pa_bukrs and
                   c~vwerk eq pa_gsber and
                   c~vtweg eq '10' and
                   c~spart eq '00'.


      Select a~Bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart
             b~name1 b~brsch c~KDGRP c~vwerk d~pernr
             into CORRESPONDING FIELDS of table i_itab_bsad
             from bsad as a join kna1 as b on a~kunnr eq b~kunnr
                        join knvv as c on c~kunnr eq a~kunnr and
                                              c~vkorg eq a~bukrs and
                                              c~vtweg eq '10' and
                                              c~spart eq '00'
                       left join vbpa as d on  a~belnr eq d~vbeln and
                                               d~parvw eq 'ZP'
             where a~bukrs eq pa_bukrs and
                   a~hkont in ( select saknr from skat
                       where ( spras eq 'EN' or spras eq 'E'  ) and
                             KTOPL Eq 'TSPC' ) and
                   a~umsks eq space and
                   a~gjahr <= pa_date(4) and
                   a~AUGDT > pa_date and
                   a~budat <= pa_date and
                   a~kunnr in so_kunnr and
                   a~UMSKZ in so_UMSKZ and
                   a~blart in ('RV','ZA','DR','DA','DZ') and
                   c~vkorg eq pa_bukrs and
                   c~vtweg eq '10' and
                   c~vwerk eq pa_gsber and
                   c~spart eq '00'.

*{   INSERT         P01K910345                                        1
*"Start SOH: Shell SCI Adjustment 20240222 KRS
  sort i_itab_bsad by bukrs gjahr budat belnr kunnr dmbtr shkzg.
  sort i_itab_bsid by bukrs gjahr budat belnr kunnr dmbtr shkzg.
"End SOH: Shell SCI Adjustment 20240222 KRS
*}   INSERT
       DELETE ADJACENT DUPLICATES FROM i_itab_bsad
            COMPARING bukrs gjahr budat belnr kunnr dmbtr shkzg.
       DELETE ADJACENT DUPLICATES FROM i_itab_bsid
            COMPARING bukrs gjahr budat belnr kunnr dmbtr shkzg.

       append lines of i_itab_bsid to i_itab3.
       append lines of i_itab_bsad to i_itab3.


       Delete i_itab3 where not ( kdgrp in so_kdgrp ).
       clear: va_dmbtr.
       if not ( '0200' eq pa_gsber ).
          Delete i_itab3 where not ( vwerk eq pa_gsber ).
       endif.
       Sort i_itab3 by bukrs vwerk kdgrp brsch kunnr pernr.
       clear: wa_itab.
       LOOP AT i_itab3 into wa_itab.
.
             if wa_itab-vwerk ne space.
                 wa_itab-gsber = wa_itab-vwerk.
             endif.
             if wa_itab-blart ne 'RV'.
                wa_itab-pernr = wa_itab-xref2.
             Endif.
             if wa_itab-KDGRP eq space.
                 wa_itab-KDGRP = 'OT'.
             endif.
             modify i_itab3 from wa_itab.
       endloop.
       Delete i_itab3 where not ( gsber eq pa_gsber ).
       if pa_bukrs eq '8020'.
             Delete i_itab3 where gsber eq '0200'.
       endif.

      Select a~Bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart
             b~name1 b~brsch c~KDGRP c~vwerk d~Pernr
             into CORRESPONDING FIELDS of table i_itab1
             from bsid as a join kna1 as b on a~kunnr eq b~kunnr
                            join knvv as c on c~kunnr eq a~kunnr and
                                              c~vkorg eq a~bukrs and
                                              c~vtweg eq '10' and
                                              c~spart eq '00'
                       left join vbpa as d on  a~belnr eq d~vbeln and
                                               d~parvw eq 'ZP'

             where a~bukrs eq pa_bukrs and
                   a~hkont in ( select saknr from skat
                       where ( spras eq 'EN' or spras eq 'E'  ) and
                             KTOPL Eq 'TSPC' ) and
                   a~umsks eq space and
                   a~gjahr <= pa_date(4) and
                   a~budat in ra_budat and
                   a~kunnr in so_kunnr and
                   a~UMSKZ in so_UMSKZ and
                   a~blart in ('RV','ZA','DR','DA') and
                   c~vkorg eq pa_bukrs and
                   c~vwerk eq pa_gsber and
                   c~vtweg eq '10' and
                   c~spart eq '00'.

      Select a~Bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart
             b~name1 b~brsch c~KDGRP c~vwerk d~Pernr
             into CORRESPONDING FIELDS of table i_itab2
             from bsad as a join kna1 as b on a~kunnr eq b~kunnr
                            join knvv as c on c~kunnr eq a~kunnr and
                                              c~vkorg eq a~bukrs and
                                              c~vtweg eq '10' and
                                              c~spart eq '00'
                       left join vbpa as d on  a~belnr eq d~vbeln and
                                               d~parvw eq 'ZP'
             where a~bukrs eq pa_bukrs and
                   a~hkont in ( select saknr from skat
                       where ( spras eq 'EN' or spras eq 'E'  ) and
                             KTOPL Eq 'TSPC' ) and
                   a~umsks eq space and
                   a~gjahr <= pa_date(4) and
                   a~budat in ra_budat and
                   a~kunnr in so_kunnr and
                   a~UMSKZ in so_UMSKZ and
                   a~blart in ('RV','ZA','DR','DA') and
                   c~vkorg eq pa_bukrs and
                   c~vtweg eq '10' and
                   c~vwerk eq pa_gsber and
                   c~spart eq '00'.


       append lines of i_itab1 to i_itab.
       append lines of i_itab2 to i_itab.

*{   INSERT         P01K910345                                        2
*   "SOH: Shell SCI Adjustment 20240222 KRS
      sort i_itab by bukrs gjahr budat belnr kunnr dmbtr shkzg.
*}   INSERT
       DELETE ADJACENT DUPLICATES FROM i_itab
            COMPARING bukrs gjahr budat belnr kunnr dmbtr shkzg.
       Delete i_itab where not ( kdgrp in so_kdgrp ).
       if not ( '0200' eq pa_gsber ).
          Delete i_itab where not ( vwerk eq pa_gsber ).
       endif.
       clear: va_dmbtr.
       Sort i_itab by bukrs vwerk kdgrp brsch kunnr pernr.
       clear: wa_itab.
       LOOP AT i_itab into wa_itab.
             if wa_itab-vwerk ne space.
                 wa_itab-gsber = wa_itab-vwerk.
             endif.
             if wa_itab-blart ne 'RV'.
                wa_itab-pernr = wa_itab-xref2.
             Endif.
             if wa_itab-KDGRP eq space.
                 wa_itab-KDGRP = 'OT'.
             endif.
             modify i_itab from wa_itab.
       endloop.
       Delete i_itab where not ( gsber eq pa_gsber ).
       if pa_bukrs eq '8020'.
           Delete i_itab where gsber eq '0200'.
       endif.
ENDFORM.                    " f_get_data
*&---------------------------------------------------------------------*
*&      Form  f_write_header_column
*&---------------------------------------------------------------------*
FORM f_write_header_column using ptext like kna1-name1.
data: l_text(20), l_text1(5).
 Write: jml_hari to l_text1.
 CONDENSE l_text1.
 Concatenate 'Average Sales (' l_text1 ')'
     into l_text separated by space..
write: / sy-uline.
  c1 = 1.
  write: /  sy-vline.
  c1 = c1 + 1.
  write at c1(w1) 'Nou' no-gap. c1 = c1 + w1.
  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
  write at c1(w2) ptext no-gap. c1 = c1 + w2.
  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
  write at c1(w3) L_TEXT centered no-gap. c1 = c1 + w3.
  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
  write at c1(w3) 'Outstanding' centered no-gap. c1 = c1 + w3.
  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
  write at c1(w3) 'DSO' centered no-gap. c1 = c1 + w3.
  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
  c1 = 0.
write: / sy-uline.




ENDFORM.                    " f_write_header_column
*&---------------------------------------------------------------------*
*&      Form  f_write_detail
*&---------------------------------------------------------------------*
FORM f_write_detail.
  write at c1(w3) wa_result-avrsales no-gap. c1 = c1 + w3.
  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
        add wa_result-avrsales to wa_total-avrsales.
        add wa_result-avrsales to wa_subtotal-avrsales.
ENDFORM.                    " f_write_detail
*&---------------------------------------------------------------------*
*&      Form  f_write_detail1
*&---------------------------------------------------------------------*
FORM f_write_detail1.
Data: l_dso like bsid-dmbtr.
  write at c1(w3) wa_result1-outstanding no-gap. c1 = c1 + w3.
  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
  clear l_dso.
*  if wa_result1-outstanding ne 0.
   if wa_result-avrsales ne 0.
      l_dso = wa_result1-outstanding / wa_result-avrsales.
  endif.
  write at c1(w3) l_dso decimals 2 no-gap. c1 = c1 + w3.
  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
        add wa_result1-outstanding to wa_total-outstanding.
        add wa_result1-outstanding to wa_subtotal-outstanding.
ENDFORM.                    " f_write_detail
*&---------------------------------------------------------------------*
*&      Form  f_write_kosong
*&---------------------------------------------------------------------*
FORM f_write_kosong.
  c1 = c1 + w3.
  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
  c1 = c1 + w3.
  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
  c1 = c1 + w3.
  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
*  c1 = c1 + w3.
*  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
*  c1 = c1 + w3.
*  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
*  c1 = c1 + w3.
*  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
*  c1 = c1 + w3.
*  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
*  c1 = c1 + w3.
*  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.
ENDFORM.                    " f_write_kosong

*&---------------------------------------------------------------------*
*&      Form  f_hitung
*&---------------------------------------------------------------------*
FORM f_hitung.
data: l_date like sy-datum,
      l_date1 like sy-datum,
      l_date2 like sy-datum.
      if wa_itab-shkzg = 'H'.
          wa_itab-dmbtr = wa_itab-dmbtr * -100.
      else.
          wa_itab-dmbtr = wa_itab-dmbtr * 100.
      endif.
       add wa_itab-dmbtr to wa_result-avrsales.
       add wa_itab-dmbtr to wa_result-outstanding.
ENDFORM.                    " f_hitung
*&---------------------------------------------------------------------*
*&      Form  f_write_total
*&---------------------------------------------------------------------*
FORM f_write_total.
Data: l_dso like bsid-dmbtr.
     write: / sy-uline.
     c1 = 1.
     write: /  sy-vline.
     c1 = c1 + 1.
     write at c1(w2) 'Grand Total ' no-gap. c1 = c1 + w2.
     c1 = c1 + w1.
     c1 = c1 + 1.
     write at c1(1) sy-vline no-gap. c1 = c1 + 1.

  clear l_dso.
*  if wa_result1-outstanding ne 0.
   if wa_total-avrsales ne 0.
      l_dso = wa_total-outstanding / wa_total-avrsales.
  endif.
  write at c1(w3) wa_total-avrsales no-gap. c1 = c1 + w3.
  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
  write at c1(w3) wa_total-outstanding no-gap. c1 = c1 + w3.
  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
  write at c1(w3) l_dso decimals 2 no-gap. c1 = c1 + w3.
  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.
     write: / sy-uline.
ENDFORM.                    " f_write_total
*&---------------------------------------------------------------------*
*&      Form  f_write_subtotal
*&---------------------------------------------------------------------*
FORM f_write_subtotal using ptext type text50.
Data: l_dso like bsid-dmbtr.
     write: / sy-uline.
     c1 = 1.
     write: /  sy-vline.
     c1 = c1 + 1.
     write at c1(w2) ptext no-gap. c1 = c1 + w2.
     c1 = c1 + w1.
     c1 = c1 + 1.
     write at c1(1) sy-vline no-gap. c1 = c1 + 1.

  clear l_dso.
  if wa_subtotal-avrsales ne 0.
      l_dso = wa_subtotal-outstanding / wa_subtotal-avrsales.
  endif.
  write at c1(w3) wa_subtotal-avrsales no-gap. c1 = c1 + w3.
  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
  write at c1(w3) wa_subtotal-outstanding no-gap. c1 = c1 + w3.
  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
  write at c1(w3) l_dso decimals 2 no-gap. c1 = c1 + w3.
  write at c1(1) sy-vline no-gap. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.
     write: / sy-uline.

ENDFORM.                    " f_write_subtotal
*&---------------------------------------------------------------------*
*&      Form  cek
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek.
DATA L_GSBER LIKE BSID-GSBER.

L_GSBER = pa_GSBER.

IF L_GSBER EQ SPACE.
   L_GSBER = '*'.
ELSEIF L_GSBER NE SPACE.
   L_GSBER = '*'.
ENDIF.

AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
    ID 'GSBER' FIELD L_GSBER
    ID 'ACTVT' FIELD '01'.
    IF SY-SUBRC NE 0.
       MESSAGE E002(ZZ) WITH
       'You have no authorization for Business Area' L_GSBER.
    ENDIF.

ENDFORM.                    " cek
