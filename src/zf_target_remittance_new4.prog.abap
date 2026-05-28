REPORT zf_target_remittance MESSAGE-ID zf NO STANDARD PAGE HEADING
                            LINE-SIZE 262.

************************************************************************
*                  REPORT  TARGET REMITTANCE                           *
*----------------------------------------------------------------------*
* ABAP Name   :  ZF_TARGET_REMITTANCE                                  *
* Created on  :  16 Oct 2002                                           *
* Version     :  1.0                                                   *
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
INCLUDE zsheader.
TYPE-POOLS: slis.                     "for 'REUSE_ALV...list&grids'

TABLES: knvv, bsid, knvk, vrkpa, tgsb, tgsbt, kna1, vbpa, tvkol,
        t151, t151t, pa0001, t001, tvbur, tvkbt, ztgtsls, zproject.

TYPES:  BEGIN OF t_itab,
            bukrs LIKE bsid-bukrs,
            vkbur LIKE tvbur-vkbur,
            zuonr LIKE bsid-zuonr,
            gsber LIKE bsid-gsber,
            budat LIKE bsid-budat,
            bldat LIKE bsid-bldat,
            augdt LIKE bsid-augdt,
            gjahr LIKE bsid-gjahr,
            belnr LIKE bsid-belnr,
            kdgrp LIKE knvv-kdgrp,
            kvgr3 LIKE knvv-kvgr3,
            kunnr LIKE bsid-kunnr,
            blart LIKE bsid-blart,
            xref1 LIKE bsid-xref1,
            xref2 LIKE bsid-xref2,
            anln1 LIKE bsid-anln1,
* added by idub 20050922 (1 row below)
            brsch LIKE kna1-brsch,
            channel LIKE zfchanel-channel,
            shkzg LIKE bsid-shkzg,
            zbd1t TYPE dec5_2, "LIKE bsid-zbd1t,
            zfbdt LIKE bsid-zfbdt,
            zterm LIKE knvv-zterm,
            dmbtr LIKE ztgtsls-value,
            vwerk LIKE knvv-vwerk,
            name1 LIKE kna1-name1,
            routel LIKE vbpa-kunnr,
            pernr  LIKE knvp-pernr,
            kunde LIKE vrkpa-kunde,
            parnr LIKE knvk-parnr,
            vrtnr LIKE knvk-vrtnr,
            sname LIKE pa0001-sname,
            ename LIKE pa0001-ename,
            spmon   LIKE ztgtsls-spmon,
            pkunwe  LIKE ztgtsls-pkunwe,
            kvgr2   LIKE ztgtsls-kvgr2,
*            KDGRP   like ztgtsls-KDGRP,
*            VKBUR   like ztgtsls-VKBUR,
            waerk   LIKE ztgtsls-waerk,
            value   LIKE ztgtsls-value,
            ztop    LIKE ztgtsls-ztop,
            kunn2  LIKE knvp-kunn2,
            umskz   LIKE bsid-umskz,
        END OF t_itab.

TYPES: BEGIN OF t_result,
            bukrs LIKE bsid-bukrs,
            vkbur LIKE tvbur-vkbur,
            channel LIKE zfchanel-channel,
            gsber LIKE bsid-gsber,
            kdgrp LIKE knvv-kdgrp,
            kvgr3 LIKE knvv-kvgr3,
            kunnr LIKE bsid-kunnr,
            zuonr LIKE bsid-zuonr,
* added by idub 20050922 (1 row below)
            brsch LIKE kna1-brsch,
            shkzg LIKE bsid-shkzg,
            dmbtr LIKE bsid-dmbtr,
            kunde LIKE vrkpa-kunde,
            routel LIKE vbpa-kunnr,
            pernr  LIKE vbpa-pernr,
            xref1  LIKE bsid-xref1,
            name1 LIKE kna1-name1,
            parnr LIKE knvk-parnr,
            vrtnr LIKE knvk-vrtnr,
            sname LIKE pa0001-sname,
            ename LIKE pa0001-ename,
            anln1 LIKE bsid-anln1,
            outstanding TYPE p,
            overduedo   TYPE p,
            overduecn   TYPE p,
            current     TYPE p,
            extended    TYPE p,
            collect     TYPE p,
            week1       TYPE p,
            week2       TYPE p,
            week3       TYPE p,
            week4       TYPE p,
            week5       TYPE p,
            total_r     TYPE p,
            notdue       TYPE p,
            sales1      TYPE p,
            total       TYPE p,
            cn          TYPE p,
       END OF t_result.

DATA:  BEGIN OF i_itabtc OCCURS 0,
            bukrs LIKE bsid-bukrs,
            vkbur LIKE tvbur-vkbur,
            zuonr LIKE bsid-zuonr,
            gsber LIKE bsid-gsber,
            budat LIKE bsid-budat,
            bldat LIKE bsid-bldat,
            augdt LIKE bsid-augdt,
            gjahr LIKE bsid-gjahr,
            belnr LIKE bsid-belnr,
            kdgrp LIKE knvv-kdgrp,
            kvgr3 LIKE knvv-kvgr3,
            kunnr LIKE bsid-kunnr,
            blart LIKE bsid-blart,
            xref1 LIKE bsid-xref1,
            xref2 LIKE bsid-xref2,
            anln1 LIKE bsid-anln1,
* added by idub 20050922 (1 row below)
            brsch LIKE kna1-brsch,
            channel LIKE zfchanel-channel,
            shkzg LIKE bsid-shkzg,
            zbd1t TYPE dec5_2, "LIKE bsid-zbd1t,
            zfbdt LIKE bsid-zfbdt,
            zterm LIKE knvv-zterm,
            dmbtr LIKE ztgtsls-value,
            vwerk LIKE knvv-vwerk,
            name1 LIKE kna1-name1,
            routel LIKE vbpa-kunnr,
            pernr  LIKE knvp-pernr,
            kunde LIKE vrkpa-kunde,
            parnr LIKE knvk-parnr,
            vrtnr LIKE knvk-vrtnr,
            sname LIKE pa0001-sname,
            ename LIKE pa0001-ename,
            spmon   LIKE ztgtsls-spmon,
            pkunwe  LIKE ztgtsls-pkunwe,
            kvgr2   LIKE ztgtsls-kvgr2,
*            KDGRP   like ztgtsls-KDGRP,
*            VKBUR   like ztgtsls-VKBUR,
            waerk   LIKE ztgtsls-waerk,
            value   LIKE ztgtsls-value,
            ztop    LIKE ztgtsls-ztop,
            kunn2  LIKE knvp-kunn2,
            umskz   LIKE bsid-umskz,
        END OF i_itabtc.

DATA:  BEGIN OF i_itabtc_real OCCURS 0,
            bukrs LIKE bsid-bukrs,
            vkbur LIKE tvbur-vkbur,
            zuonr LIKE bsid-zuonr,
            gsber LIKE bsid-gsber,
            budat LIKE bsid-budat,
            bldat LIKE bsid-bldat,
            augdt LIKE bsid-augdt,
            gjahr LIKE bsid-gjahr,
            belnr LIKE bsid-belnr,
            kdgrp LIKE knvv-kdgrp,
            kvgr3 LIKE knvv-kvgr3,
            kunnr LIKE bsid-kunnr,
            blart LIKE bsid-blart,
            xref1 LIKE bsid-xref1,
            xref2 LIKE bsid-xref2,
            anln1 LIKE bsid-anln1,
* added by idub 20050922 (1 row below)
            brsch LIKE kna1-brsch,
            channel LIKE zfchanel-channel,
            shkzg LIKE bsid-shkzg,
            zbd1t TYPE dec5_2, "LIKE bsid-zbd1t,
            zfbdt LIKE bsid-zfbdt,
            zterm LIKE knvv-zterm,
            dmbtr LIKE ztgtsls-value,
            vwerk LIKE knvv-vwerk,
            name1 LIKE kna1-name1,
            routel LIKE vbpa-kunnr,
            pernr  LIKE knvp-pernr,
            kunde LIKE vrkpa-kunde,
            parnr LIKE knvk-parnr,
            vrtnr LIKE knvk-vrtnr,
            sname LIKE pa0001-sname,
            ename LIKE pa0001-ename,
            spmon   LIKE ztgtsls-spmon,
            pkunwe  LIKE ztgtsls-pkunwe,
            kvgr2   LIKE ztgtsls-kvgr2,
*            KDGRP   like ztgtsls-KDGRP,
*            VKBUR   like ztgtsls-VKBUR,
            waerk   LIKE ztgtsls-waerk,
            value   LIKE ztgtsls-value,
            ztop    LIKE ztgtsls-ztop,
            kunn2  LIKE knvp-kunn2,
            umskz   LIKE bsid-umskz,
        END OF i_itabtc_real.

DATA: BEGIN OF i_result71 OCCURS 0,
        bukrs LIKE bsid-bukrs,
        vkbur LIKE tvbur-vkbur,
        channel LIKE zfchanel-channel,
        kdgrp LIKE knvv-kdgrp,
        brsch LIKE kna1-brsch,
        kunnr LIKE bsid-kunnr,
        target TYPE p,
        actual TYPE p,
        persen TYPE p,
      END OF i_result71.
DATA: BEGIN OF i_target OCCURS 0,
   spmon   LIKE ztgtsls-spmon,
   pkunwe  LIKE ztgtsls-pkunwe,
   kvgr2   LIKE ztgtsls-kvgr2,
   kdgrp   LIKE ztgtsls-kdgrp,
   vkbur   LIKE ztgtsls-vkbur,
   waerk   LIKE ztgtsls-waerk,
   value   LIKE ztgtsls-value,
   ztop    LIKE ztgtsls-ztop,
   name1   LIKE kna1-name1,
   brsch LIKE kna1-brsch,
   kunn2  LIKE knvp-kunn2,
END OF i_target.
DATA: BEGIN OF i_tvkol OCCURS 0,
         vstel LIKE tvkol-vstel,
         live LIKE zplbc-live,
         werks LIKE tvkol-werks,
         lgort LIKE tvkol-lgort,
      END OF i_tvkol.

DATA: i_itab TYPE t_itab OCCURS 0,
      i_itab_temp TYPE t_itab OCCURS 0,
      i_itab_sap TYPE t_itab OCCURS 0,
      i_itab_leg TYPE t_itab OCCURS 0,
      i_itab_real TYPE t_itab OCCURS 0,
      i_itab_real_temp TYPE t_itab OCCURS 0,
      i_itab_bsid TYPE t_itab OCCURS 0,
      i_itab_bsad TYPE t_itab OCCURS 0,
      i_itab_bsid_real TYPE t_itab OCCURS 0,
      i_itab_bsad_real TYPE t_itab OCCURS 0,
      wa_itab TYPE t_itab,
      wa_itab_real TYPE t_itab,
      i_result TYPE t_result OCCURS 0,
      i_result1 TYPE t_result OCCURS 0,
      i_result2 TYPE t_result OCCURS 0,
      i_result2_cus TYPE t_result OCCURS 0,
      i_result2_05t TYPE t_result OCCURS 0,
      i_result3 TYPE t_result OCCURS 0,
      i_result4 TYPE t_result OCCURS 0,
      i_result5 TYPE t_result OCCURS 0,
* added by idub 20050922
      i_result6 TYPE t_result OCCURS 0,
      i_result7 TYPE t_result OCCURS 0,
      i_result8 TYPE t_result OCCURS 0,
      i_result_salesman TYPE t_result OCCURS 0,
      i_result_real TYPE t_result OCCURS 0,
      i_result1_real TYPE t_result OCCURS 0,
      i_result2_real TYPE t_result OCCURS 0,
      i_result2_real_cus TYPE t_result OCCURS 0,
      i_result2_real_05t TYPE t_result OCCURS 0,
      i_result3_real TYPE t_result OCCURS 0,
      i_result4_real TYPE t_result OCCURS 0,
      i_result5_real TYPE t_result OCCURS 0,
* added by idub 20050922
      i_result6_real TYPE t_result OCCURS 0,
      i_result72 LIKE i_result71 OCCURS 0 WITH HEADER LINE,
      i_result72tc LIKE i_result71 OCCURS 0 WITH HEADER LINE,
      i_result7_real TYPE t_result OCCURS 0,
      i_result8_real TYPE t_result OCCURS 0,
*
      i_result_real_salesman TYPE t_result OCCURS 0,
*
      i_delete TYPE t_result OCCURS 0 WITH HEADER LINE,
      i_zfchanel LIKE zfchanel OCCURS 0 WITH HEADER LINE,

      filesize TYPE i,
      va_dmbtr TYPE p DECIMALS 2,
      va_value TYPE p DECIMALS 2,
      va_date LIKE sy-datum,
      va_date1 LIKE sy-datum,
      va_sunday LIKE sy-datum,
      wa_result TYPE t_result,
      wa_result_real TYPE t_result,
      wa_subtotal TYPE t_result,
      wa_sub_real TYPE t_result,
      wa_subtotal1 TYPE t_result,
      wa_sub_real1 TYPE t_result,
      wa_total TYPE t_result,
      wa_total_real TYPE t_result.

DATA:  va_nou TYPE i,
       va_line TYPE i VALUE 10,
       ctr    TYPE i,
       va_page TYPE i,
       va_text(30),
       va_texttotal1(30),
       va_texttotal2(30),
       char4(4),
       char8(8),
       va_flag(1),
       va_project(1)  ,
       l1_text(50),
       l2_text(50),
       l3_text(50),
       l4_text(50),
       l5_text(50),
       l6_text(50),
       l7_text(50),
       l8_text(50),
       l1_text_real(50),
       l9_text_real(100),
       l2_text_real(50),
       l3_text_real(50),
       l4_text_real(50),
       l5_text_real(50),
       l6_text_real(50),
       tot_dmbtr1   LIKE regup-dmbtr,
       tot_dmbtr2   LIKE regup-dmbtr,
       va_pernr LIKE pa0001-pernr,
       c1    TYPE i,
       d1    TYPE i,
       w0    TYPE i,
       w1    TYPE i,  w2    TYPE i,  w3    TYPE i,  w4    TYPE i,
       w5    TYPE i,  w6    TYPE i,  w7    TYPE i,  w8    TYPE i,
       u1    TYPE i,  u2    TYPE i,  h1    TYPE i,  h2    TYPE i.

DATA: va_tanggal  TYPE  sy-datum,
      va_tanggal1 TYPE  sy-datum,
      va_pos(22),
*      va_spmon   like ztgtsls-spmon,
      va_top(40).

DATA: va_round TYPE i,
      ls TYPE i.

DATA: BEGIN OF v_channel,
        data1(5),
        data2(1),
        data3(2),
        data4(1),
        data5(20),
      END OF v_channel.

DATA: BEGIN OF v_channelr,
        data0(6),
        data1(5),
        data2(1),
        data3(2),
        data4(1),
        data5(20),
      END OF v_channelr.

RANGES: ra_date FOR bsid-budat.

* data-statements that are necessary for the use of the ALV-grid
DATA:  gt_xevents     TYPE slis_t_event.
DATA:  xs_event       TYPE slis_alv_event.
DATA:  repid          TYPE sy-repid.
DATA:  zta_print      TYPE slis_t_fieldcat_alv WITH HEADER LINE.
DATA:  lo_layout      TYPE slis_layout_alv.
DATA:  lo_itabname    TYPE slis_tabname.
DATA:  ls_variant     TYPE disvariant.
DATA:  ihead          TYPE slis_t_listheader.
DATA:  ihead_ln       TYPE slis_listheader.
DATA:  va_data.

** Revise by budi 26/06/2006
DATA: BEGIN OF i_knvv  OCCURS 0,
        vkorg LIKE knvv-vkorg,
        vkbur LIKE knvv-vkbur,
        kunnr LIKE knvv-kunnr,
        zterm LIKE knvv-zterm,
      END OF i_knvv.
CONSTANTS: va_cutdate LIKE sy-datum VALUE '20060701'.
** End Revise by budi 26/06/2006

DATA: BEGIN OF t_zftop OCCURS 0.
        INCLUDE STRUCTURE zftop.
DATA: END OF t_zftop.

DATA: BEGIN OF t_zfarsoff_dele OCCURS 0.
        INCLUDE STRUCTURE zfarsoff.
DATA: END OF t_zfarsoff_dele.
DATA: BEGIN OF t_zfarsoff_add OCCURS 0.
        INCLUDE STRUCTURE zfarsoff.
DATA: END OF t_zfarsoff_add.
DATA: BEGIN OF t_zfarsoff,
       bukrs LIKE bsad-bukrs,
       zvkbur LIKE zfarsoff-zvkbur,
       kunnr LIKE zfarsoff-kunnr,
*       ZVKBUR1 like zfarsoff-ZVKBUR,
      END OF t_zfarsoff.

DATA: t_bsid_add TYPE t_itab OCCURS 0,
      t_bsad_add TYPE t_itab OCCURS 0,
      t_bsid_add_real TYPE t_itab OCCURS 0,
      t_bsad_add_real TYPE t_itab OCCURS 0,
      wa_zfarsoff LIKE t_zfarsoff_add,
      i_zfarsoff_add_sap LIKE t_zfarsoff OCCURS 0 WITH HEADER LINE,
      i_zfarsoff_add_leg LIKE t_zfarsoff OCCURS 0 WITH HEADER LINE.

DATA: va_hotspot  TYPE i,
      pa_act(4),
      va_xref1    LIKE bsid-xref1,
      va_pernr1   LIKE vbpa-pernr,
      va_kdgrp    LIKE knvv-kdgrp,
      va_kvgr3    LIKE knvv-kvgr3,
      va_brsch    LIKE kna1-brsch,
      va_act      LIKE zftop-actual.

RANGES: r_vksap FOR tvbur-vkbur,
        r_vkleg FOR tvbur-vkbur.

RANGES: ra_headw1 FOR sy-datum,
        ra_headw2 FOR sy-datum,
        ra_headw3 FOR sy-datum,
        ra_headw4 FOR sy-datum,
        ra_headw5 FOR sy-datum.

DATA: gv_kvgr3 TYPE kvgr3.

****************************************************
*        Parameters                                *
****************************************************
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS   pa_bukrs LIKE t001-bukrs OBLIGATORY DEFAULT '8020'.
SELECT-OPTIONS: so_gsber FOR tvbur-vkbur,
                so_kdgrp FOR knvv-kdgrp,   "no intervals,
                so_kvgr3 FOR knvv-kvgr3 MODIF ID kv3,
                so_kunnr FOR bsid-kunnr,
                so_brsch FOR kna1-brsch,
                p_route  FOR kna1-kunnr,
*                p_route FOR char4,
                p_slcode FOR char8,
* Sementara NO-DISPLAY karena permintaan SJT 12/12/2005
                s_blart FOR bsid-blart NO-DISPLAY.
PARAMETERS   pa_date LIKE sy-datum OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : rad1 RADIOBUTTON GROUP grp2 DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(10) text-008 FOR FIELD rad1.
SELECTION-SCREEN POSITION 22.
SELECTION-SCREEN : COMMENT 25(12) text-012.
PARAMETERS : pa_day(2)  DEFAULT '6' OBLIGATORY.
SELECTION-SCREEN : COMMENT 42(5) text-013.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : rad2 RADIOBUTTON GROUP grp2 MODIF ID rad.
SELECTION-SCREEN : COMMENT 5(10) text-007 FOR FIELD rad2.

SELECTION-SCREEN POSITION 22.
*SELECTION-SCREEN : COMMENT 25(12) text-015.
PARAMETERS : p_act LIKE pa_act  DEFAULT '75' MODIF ID act NO-DISPLAY.
*SELECTION-SCREEN : COMMENT 42(5) text-016.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
PARAMETERS: x_norm LIKE itemset-xnorm AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS  x_shbv LIKE itemset-xshbv AS CHECKBOX.
SELECTION-SCREEN : COMMENT 4(24) text-014 FOR FIELD x_shbv.
SELECTION-SCREEN POSITION 30.
SELECT-OPTIONS s_bschl FOR bsid-umskz NO INTERVALS.
SELECTION-SCREEN END OF LINE.

PARAMETERS x_opdr AS CHECKBOX.

SELECTION-SCREEN END OF BLOCK b.

SELECTION-SCREEN BEGIN OF BLOCK d WITH FRAME TITLE text-010.
PARAMETERS: pa_targe AS CHECKBOX DEFAULT 'X',
            pa_real AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK d.

SELECTION-SCREEN BEGIN OF BLOCK c WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio1 RADIOBUTTON GROUP grp1 USER-COMMAND grp1 DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(45) text-003  FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(45) text-004 FOR FIELD radio2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(45) text-005 FOR FIELD radio3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(45) text-006 FOR FIELD radio4.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(45) text-009 FOR FIELD radio5.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio16 RADIOBUTTON GROUP grp1 MODIF ID ptt.
SELECTION-SCREEN : COMMENT 5(45) text-100 FOR FIELD radio16.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio17 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(45) text-101 FOR FIELD radio17.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio19 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(79) text-104 FOR FIELD radio19.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio18 RADIOBUTTON GROUP grp1 MODIF ID sut.
SELECTION-SCREEN : COMMENT 5(45) text-103 FOR FIELD radio18.
SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS : radio18 RADIOBUTTON GROUP grp1.
*SELECTION-SCREEN COMMENT 5(9) text-501.
*SELECTION-SCREEN POSITION 14.
*PARAMETER : p_file LIKE rlgrap-filename DEFAULT 'C:\Target.txt' MEMORY ID DIR.
*SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN BEGIN OF LINE.
**PARAMETERS : radio18 RADIOBUTTON GROUP grp1.
*SELECTION-SCREEN COMMENT 5(9) text-502.
*SELECTION-SCREEN POSITION 14.
*PARAMETER : p_file1 LIKE rlgrap-filename DEFAULT 'C:\Real.txt' MEMORY ID DIR.
*SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK c.

*SELECTION-SCREEN BEGIN OF BLOCK block5 WITH FRAME TITLE text-102.
**SELECTION-SCREEN BEGIN OF SCREEN 500 AS WINDOW TITLE text-500.
*SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS : radio18 RADIOBUTTON GROUP grp1.
*SELECTION-SCREEN COMMENT 4(9) text-501.
*SELECTION-SCREEN POSITION 14.
*PARAMETER : p_file LIKE rlgrap-filename DEFAULT 'C:\Target.XLS'.
*SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN END OF BLOCK block5.
**SELECTION-SCREEN END OF SCREEN 500.

SELECTION-SCREEN BEGIN OF BLOCK block4 WITH FRAME TITLE text-099.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio10 RADIOBUTTON GROUP grp3 DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(22) text-098 FOR FIELD radio10.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio11 RADIOBUTTON GROUP grp3.
SELECTION-SCREEN : COMMENT 5(22) text-097 FOR FIELD radio11.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio12 RADIOBUTTON GROUP grp3.
SELECTION-SCREEN : COMMENT 5(22) text-096 FOR FIELD radio12.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio13 RADIOBUTTON GROUP grp3.
SELECTION-SCREEN : COMMENT 5(22) text-095 FOR FIELD radio13.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio14 RADIOBUTTON GROUP grp3.
SELECTION-SCREEN : COMMENT 5(22) text-094 FOR FIELD radio14.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio15 RADIOBUTTON GROUP grp3.
SELECTION-SCREEN : COMMENT 5(22) text-093 FOR FIELD radio15.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block4.

************************************************************************
* PROGRAM                                                              *
************************************************************************
************************************************************************
* AT SELECTION-SCREEN
************************************************************************
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
*     CALL FUNCTION 'WS_FILENAME_GET'
*       EXPORTING
*            DEF_FILENAME     = ' '
*            DEF_PATH         = 'C:\'
*            MASK             = ',*.*,*.*.'
*            MODE             = 'O'
*            TITLE            = TEXT-011
*       IMPORTING
*            FILENAME         = p_file
*       EXCEPTIONS
*            INV_WINSYS       = 01
*            NO_BATCH         = 02
*            SELECTION_CANCEL = 03
*            SELECTION_ERROR  = 04.

*CALL FUNCTION 'F4_FILENAME'
*  EXPORTING
*    PROGRAM_NAME        = SYST-CPROG
*    DYNPRO_NUMBER       = SYST-DYNNR
*    FIELD_NAME          = 'PATH'
*  IMPORTING
*    FILE_NAME           = P_FILE.



*  CALL FUNCTION 'WS_FILENAME_GET'
*    EXPORTING
*      def_filename     = ' '
**      def_path         = 'C:\BANKGRS\'
*      def_path         = 'C:\    .xls'
*      mask             = ',*.*,*.*.'
*      mode             = 'O'
*      title            = text-011
*    IMPORTING
*      filename         = p_file
*    EXCEPTIONS
*      inv_winsys       = 01
*      no_batch         = 02
*      selection_cancel = 03
*      selection_error  = 04.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file1.
*     CALL FUNCTION 'WS_FILENAME_GET'
*       EXPORTING
*            DEF_FILENAME     = ' '
*            DEF_PATH         = 'C:\'
*            MASK             = ',*.*,*.*.'
*            MODE             = 'O'
*            TITLE            = TEXT-011
*       IMPORTING
*            FILENAME         = p_file1
*       EXCEPTIONS
*            INV_WINSYS       = 01
*            NO_BATCH         = 02
*            SELECTION_CANCEL = 03
*            SELECTION_ERROR  = 04.

*CALL FUNCTION 'F4_FILENAME'
*  EXPORTING
*    PROGRAM_NAME        = SYST-CPROG
*    DYNPRO_NUMBER       = SYST-DYNNR
*    FIELD_NAME          = 'PATH'
*  IMPORTING
*    FILE_NAME           = P_FILE1.

*  CALL FUNCTION 'WS_FILENAME_GET'
*    EXPORTING
*      def_filename     = ' '
**      def_path         = 'C:\BANKGRS\'
*      def_path         = 'C:\    .xls'
*      mask             = ',*.*,*.*.'
*      mode             = 'O'
*      title            = text-011
*    IMPORTING
*      filename         = p_file1
*    EXCEPTIONS
*      inv_winsys       = 01
*      no_batch         = 02
*      selection_cancel = 03
*      selection_error  = 04.

AT SELECTION-SCREEN ON so_kunnr .
  SELECT SINGLE * FROM kna1
         WHERE kunnr IN so_kunnr.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Customer Number Not Found'.
  ENDIF.


AT SELECTION-SCREEN ON so_kdgrp.
  SELECT SINGLE * FROM t151
         WHERE kdgrp IN so_kdgrp.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Customer Group Not Found'.
  ENDIF.

AT SELECTION-SCREEN ON so_kvgr3.
  SELECT SINGLE kvgr3 INTO gv_kvgr3 FROM tvv3
         WHERE kvgr3 IN so_kvgr3.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Sub Customer Group Not Found'.
  ENDIF.

AT SELECTION-SCREEN ON pa_bukrs.
  SELECT SINGLE butxt INTO v_title1 FROM t001 WHERE bukrs EQ pa_bukrs.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Company not found'.
  ENDIF.
  IF pa_bukrs EQ '8020' OR pa_bukrs EQ '8030' OR
    pa_bukrs EQ '8070' OR pa_bukrs EQ '8380'.
  ELSE.
    MESSAGE e000(zs)
      WITH 'CoCd must be entry (8020, 8030, 8070, 8380)'.
  ENDIF.

AT SELECTION-SCREEN ON so_gsber.
  SELECT SINGLE * FROM tvbur
         WHERE vkbur IN so_gsber.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Business Area Not Found'.
  ENDIF.

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

*    s_bschl-low = 'U'.
*    s_bschl-sign = 'I'.
*    s_bschl-option = 'EQ'.
*    APPEND s_bschl.

*   MESSAGE E000(ZS) WITH 'Special G/L Indicator harus diisi'.
  ENDIF.

* added by idub 20050922
AT SELECTION-SCREEN ON so_brsch.
  SELECT SINGLE * FROM kna1
         WHERE brsch IN so_brsch.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Industry Key Not Found'.
  ENDIF.

AT SELECTION-SCREEN ON RADIOBUTTON GROUP grp1.
  IF radio17 = 'X'.
    pa_targe = 'X'. pa_real = 'X'.
  ENDIF.

  CASE 'X'.
    WHEN radio19.
      PERFORM f_init_kvgr3.
    WHEN OTHERS.
      CLEAR: so_kvgr3,so_kvgr3[].
  ENDCASE.

*AT SELECTION-SCREEN ON p_act.


AT SELECTION-SCREEN OUTPUT.
  CASE 'X'.
    WHEN radio19.
      LOOP AT SCREEN.
        IF screen-group1 = 'KV3'.
          screen-input  = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN OTHERS.
      LOOP AT SCREEN.
        IF screen-group1 = 'KV3'.
          screen-input  = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
  ENDCASE.

  IF pa_bukrs EQ '8070'.
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

  va_tanggal  = pa_date + pa_day.
  CLEAR: va_project.

  CONCATENATE va_tanggal(6) '01' INTO va_tanggal1.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = va_tanggal1
    IMPORTING
      last_day_of_month = va_tanggal1.

  LOOP AT SCREEN.
    IF screen-group1 = 'RAD'.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

*  SELECT SINGLE flag char1 INTO (va_project, p_act) FROM zproject
*         WHERE name = 'ZF22N' AND
*               datab <= pa_date.
*  IF sy-subrc EQ 0.
*  ELSE.
*    CLEAR: va_project.
*    p_act = '75'.
*  ENDIF.
*  LOOP AT SCREEN.
*    IF screen-group1 = 'ACT'.
*      screen-input = 0.
*      MODIFY SCREEN.
*    ENDIF.
*  ENDLOOP.
************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.
  REFRESH: i_result, i_result1, i_result2, i_result3, i_result4,
         i_result5, i_result6, i_result8, i_target, i_itab.
  CLEAR: i_result, i_result1, i_result2, i_result3, i_result4,
         i_result5, i_result6, i_result8, i_target, i_itab.

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
*  va_tanggal  = pa_date + pa_day.
*  Clear: va_project.
*  Select single flag CHAR1 into (va_project, p_act) from zproject
*         where name = 'ZF22N' and
*               DATAB <= pa_date.
*   if sy-subrc eq 0.
*   Else.
*      Clear: va_project.
*   endif.

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

  IF pa_bukrs = '8070'.
    pa_day = '16'.
  ENDIF.

************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.

  PERFORM f_get_header_week.
  PERFORM cek.
  va_tanggal  = pa_date + pa_day.
  CLEAR: va_project.
*  SELECT SINGLE flag char1 INTO (va_project, p_act) FROM zproject
*         WHERE name = 'ZF22N' AND
*               datab <= pa_date.
*  IF sy-subrc EQ 0.
*  ELSE.
*    CLEAR: va_project.
*    p_act = '75'.
*  ENDIF.

  REFRESH: i_result, i_result1, i_result2, i_result3, i_result4,
         i_result5, i_result6, i_result8, i_target, i_itab.

  CLEAR: i_result1, i_result2, i_result3, i_result4,
         i_result5, i_result6, i_result7, i_result8, i_target.

  IF pa_bukrs EQ '8070'.
    SET PF-STATUS '101'.
  ELSE.
    SET PF-STATUS '100'.
  ENDIF.

  PERFORM round.

*  v_title3 = 'Test'.
  PERFORM f_init_column.
  PERFORM f_mapping_soff.

  IF pa_targe EQ 'X'.
    PERFORM f_get_data.
    PERFORM f_proses_route.
  ENDIF.

  IF pa_real EQ 'X'.
    PERFORM f_get_data_real.
    PERFORM f_proses_route_real.
  ENDIF.

  IF pa_targe EQ 'X' AND
    pa_real EQ space.
    DESCRIBE TABLE i_itab LINES c1.
    IF c1 <= 0.
      MESSAGE i000(zf) WITH 'Data not found'.
      EXIT.
    ENDIF.
  ENDIF.

  IF pa_real EQ 'X' AND
    pa_targe EQ space.
    DESCRIBE TABLE i_itab_real LINES d1.
    IF d1 <= 0.
      MESSAGE i000(zf) WITH 'Data not found'.
      EXIT.
    ENDIF.
  ENDIF.

  IF pa_targe EQ 'X' AND
    pa_real EQ 'X'.
    DESCRIBE TABLE i_itab LINES c1.
    DESCRIBE TABLE i_itab_real LINES d1.
    IF c1 <= 0 AND
      d1 <= 0.
      MESSAGE i000(zf) WITH 'Data not found'.
      EXIT.
    ENDIF.
  ENDIF.

**** perform selanjutnya
  PERFORM check_sales_routlist.

*Perform f_cek_itab.

  v_repid = 'A/R Target Remittance'.
  WRITE pa_date TO v_title3.
  CONCATENATE 'As of ' v_title3 INTO v_title3 SEPARATED BY space.
  IF rad2 = 'X'.
    CONCATENATE   v_title3 text-007 INTO v_title3 SEPARATED BY '      '.
  ELSE.
    IF va_project = 'X'.
      IF va_data = 'X'.
        CONCATENATE 'Actual Sales' p_act '% (Target Sales 0)' INTO va_top SEPARATED BY space.
      ELSE.
        CONCATENATE 'Actual Sales' p_act '% ' INTO va_top SEPARATED BY space.
      ENDIF.
    ELSE.
      CONCATENATE text-008 pa_day INTO va_top SEPARATED BY space.
    ENDIF.
    CONCATENATE   v_title3 va_top INTO v_title3 SEPARATED BY '  '.
  ENDIF.

* Perform untuk penggabungan transaksi
*  PERFORM f_modify_itab.

  IF radio1 = 'X'.
    PERFORM f_proses1.
  ENDIF.
  IF radio2 = 'X'.
    PERFORM f_proses2.
  ENDIF.
  IF radio3 = 'X'.
    PERFORM f_proses3.
  ENDIF.
  IF radio4 = 'X'.
    PERFORM f_proses4.
  ENDIF.
  IF radio5 = 'X'.
*    Perform f_proses_route.
    PERFORM f_proses5.
  ENDIF.
  IF radio16 = 'X'.
*    Perform f_proses_route.
    PERFORM f_proses6.
  ENDIF.
  IF radio17 = 'X'.
*    Perform f_proses_route.
*    PERFORM f_proses7.
    PERFORM f_proses71.
  ENDIF.
  IF radio18 = 'X'.
    PERFORM f_proses8.
  ENDIF.
  IF radio19 = 'X'.
    NEW-PAGE LINE-SIZE 283.
    PERFORM f_proses2.
  ENDIF.

AT USER-COMMAND.
  IF i_result1 IS INITIAL OR
     i_result2 IS INITIAL OR
     i_result3 IS INITIAL OR
     i_result4 IS INITIAL OR
     i_result5 IS INITIAL OR
     i_result6 IS INITIAL OR
     i_result7 IS INITIAL OR
     i_result8 IS INITIAL.
  ELSE.
    IF i_itab IS INITIAL.
    ELSE.
*           Clear: i_itab.
    ENDIF.
  ENDIF.

  sy-lsind = 0.
  CASE sy-ucomm.
    WHEN 'BRANCH'.
      PERFORM f_proses1.
    WHEN 'CUSTOMER'.
      radio2 = 'X'.
      CLEAR radio19.
      PERFORM f_proses2.
    WHEN 'SALESMAN'.
      PERFORM f_proses3.
    WHEN 'CUSTGROUP'.
      PERFORM f_proses4.
    WHEN 'ROUTE'.
      PERFORM f_proses_route.
      PERFORM f_proses5.
    WHEN 'INDUSTRY'.
      PERFORM f_proses6.
    WHEN 'CHANNEL'.
      PERFORM f_proses71.
    WHEN 'SUBCUSTGRP'.
      PERFORM f_proses8.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE  PROGRAM.
    WHEN 'CHOOSE'.
      PERFORM f_choose.
    WHEN '05T'.
      CLEAR radio2.
      radio19 = 'X'.
      NEW-PAGE LINE-SIZE 283.
      PERFORM f_proses2.
  ENDCASE.

TOP-OF-PAGE.
  IF radio1 = 'X' AND sy-ucomm = space.
    v_title2 = 'A/R Target Remittance Per Branch'.
    PERFORM f_write_header1.
    PERFORM f_write_header_column USING 'Branch'.
  ENDIF.

  IF ( radio2 = 'X' OR radio19 = 'X' ) AND sy-ucomm = space.
    IF radio19 = 'X'.
      v_title2 = 'A/R Target Remittance Per Customer - Tempo Trading'.
    ELSE.
      v_title2 = 'A/R Target Remittance Per Customer'.
    ENDIF.
    PERFORM f_write_header1.
    PERFORM f_write_header_column USING 'Customer'.
  ENDIF.

  IF radio3 = 'X' AND sy-ucomm = space.
    v_title2 = 'A/R Target Remittance Per Salesman'.
    PERFORM f_write_header1.
    PERFORM f_write_header_column USING 'Salesman'.
  ENDIF.

  IF radio4 = 'X' AND sy-ucomm = space.
    v_title2 = 'A/R Target Remittance Per Customer Group'.
    PERFORM f_write_header1.
    PERFORM f_write_header_column USING 'Customer Group'.
  ENDIF.

  IF radio5 = 'X' AND sy-ucomm = space.
    v_title2 = 'A/R Target Remittance Per Route List'.
    PERFORM f_write_header1.
    PERFORM f_write_header_column USING 'Route List'.
  ENDIF.

*added by idub 20050920
  IF radio16 = 'X' AND sy-ucomm = space.
    v_title2 = 'A/R Target Remittance Per Branch and Industry'.
    PERFORM f_write_header1.
    PERFORM f_write_header_column USING 'Branch and Industry'.
  ENDIF.

  IF radio17 = 'X' AND sy-ucomm = space.
    v_title2 = 'A/R Target Remittance Per Branch and Channel'.
    PERFORM f_write_header11.
    PERFORM f_write_header_column1.
  ENDIF.

  IF radio18 = 'X' AND sy-ucomm = space.
    v_title2 = 'A/R Target Remittance Per Sub Customer Group'.
    PERFORM f_write_header1.
    PERFORM f_write_header_column USING 'Sub Customer Group'.
  ENDIF.

TOP-OF-PAGE DURING LINE-SELECTION.
  IF sy-ucomm = 'BRANCH'.
    v_title2 = 'A/R Target Remittance Per Branch'.
    PERFORM f_write_header1.
    PERFORM f_write_header_column USING 'Branch'.
  ENDIF.

  IF sy-ucomm = 'CUSTOMER'.
    v_title2 = 'A/R Target Remittance Per Customer'.
    PERFORM f_write_header1.
    PERFORM f_write_header_column USING 'Customer'.
  ENDIF.

  IF sy-ucomm = 'SALESMAN'.
    v_title2 = 'A/R Target Remittance Per Salesman'.
    PERFORM f_write_header1.
    PERFORM f_write_header_column USING 'Salesman'.
  ENDIF.

  IF sy-ucomm = 'CUSTGROUP'.
    v_title2 = 'A/R Target Remittance Per Customer Group'.
    PERFORM f_write_header1.
    PERFORM f_write_header_column USING 'Customer Group'.
  ENDIF.

  IF sy-ucomm = 'ROUTE'.
    v_title2 = 'A/R Target Remittance Per Route List'.
    PERFORM f_write_header1.
    PERFORM f_write_header_column USING 'Route List'.
  ENDIF.

  IF sy-ucomm = 'INDUSTRY'.
    v_title2 = 'A/R Target Remittance Per Branch and Industry'.
    PERFORM f_write_header1.
    PERFORM f_write_header_column USING 'Branch and Industry'.
  ENDIF.

  IF sy-ucomm = 'CHANNEL'.
    v_title2 = 'A/R Target Remittance Per Branch and Channel'.
    PERFORM f_write_header11.
    PERFORM f_write_header_column1.
  ENDIF.

  IF sy-ucomm = 'SUBCUSTGRP'.
    v_title2 = 'A/R Target Remittance Per Sub Customer Group'.
    PERFORM f_write_header1.
    PERFORM f_write_header_column USING 'Sub Customer Group'.
  ENDIF.

  IF sy-ucomm = '05T'.
    v_title2 = 'A/R Target Remittance Per Customer - Tempo Trading'.
    PERFORM f_write_header1.
    PERFORM f_write_header_column USING 'Customer'.
  ENDIF.


*&---------------------------------------------------------------------*
*&      Form  f_init_column
*&---------------------------------------------------------------------*
FORM f_init_column.
  w1   =   5.
  w2   =  30.
  w5   =  20.
*  w3   =  15.
  IF radio10 EQ 'X'.
    w3   =  15.
    u1   =  31.
    ls   =  205.
  ELSEIF radio11 EQ 'X'.
    w3   =  14.
    u1   =  29.
    u2   =  248.
    ls   =  191.
  ELSEIF radio12 EQ 'X'.
    w3   =  13.
    u1   =  27.
    u2   =  234.
    ls   =  177.
  ELSEIF radio13 EQ 'X'.
    w3   =  12.
    u1   =  25.
    u2   =  220.
    ls   =  163.
  ELSEIF radio14 EQ 'X'.
    w3   =  11.
    u1   =  23.
    u2   =  206.
    ls   =  149.
  ELSEIF radio15 EQ 'X'.
    w3   =  10.
    u1   =  21.
    u2   =  192.
    ls   =  135.
  ENDIF.
  c1 = 0.

  h1 = 11.
  h2 = 25.
ENDFORM.                    " f_init_column

*&---------------------------------------------------------------------*
*&      Form  f_proses1
*&---------------------------------------------------------------------*
FORM f_proses1.
  CLEAR: i_delete. REFRESH: i_delete.
  IF pa_targe EQ 'X'.
    IF i_result1 IS INITIAL.
      SORT i_itab BY bukrs vkbur.
      CLEAR: wa_itab, wa_result, i_result1.
      LOOP AT i_itab INTO wa_itab.
        ON CHANGE OF wa_itab-bukrs OR
                     wa_itab-vkbur.
          IF wa_result-vkbur NE space.
            wa_result-collect = wa_result-outstanding.
            wa_result-total_r = wa_result-week1 + wa_result-week2 +
                                wa_result-week3 + wa_result-week4 +
                                wa_result-week5 + wa_result-sales1.
            APPEND wa_result TO i_result1.
            CLEAR wa_result.
          ENDIF.
        ENDON.
        MOVE wa_itab-bukrs TO wa_result-bukrs.
        MOVE wa_itab-vkbur TO wa_result-vkbur.
        PERFORM f_hitung.
        CLEAR wa_itab.
      ENDLOOP.

      IF wa_result-vkbur NE space.
        wa_result-collect = wa_result-outstanding.
        wa_result-total_r = wa_result-week1 + wa_result-week2 +
                            wa_result-week3 + wa_result-week4 +
                            wa_result-week5 + wa_result-sales1.
        APPEND wa_result TO i_result1.
        CLEAR wa_result.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pa_real EQ 'X'.
    IF i_result1_real IS INITIAL.
      SORT i_itab_real BY bukrs vkbur.
      CLEAR: wa_itab_real, wa_result_real, i_result1_real.
      LOOP AT i_itab_real INTO wa_itab_real.
        ON CHANGE OF wa_itab_real-bukrs OR
                     wa_itab_real-vkbur.
          IF wa_result_real-vkbur NE space.
            wa_result_real-collect = wa_result_real-outstanding.
            wa_result_real-total_r = wa_result_real-week1 +
                                     wa_result_real-week2 +
                                     wa_result_real-week3 +
                                     wa_result_real-week4 +
                                     wa_result_real-week5 +
                                     wa_result_real-sales1.
            APPEND wa_result_real TO i_result1_real.
            CLEAR wa_result_real.
          ENDIF.
        ENDON.
        MOVE wa_itab_real-bukrs TO wa_result_real-bukrs.
        MOVE wa_itab_real-vkbur TO wa_result_real-vkbur.
        PERFORM f_hitung_real.
        CLEAR wa_itab_real.
      ENDLOOP.

      IF wa_result_real-vkbur NE space.
        wa_result_real-collect = wa_result_real-outstanding.
        wa_result_real-total_r = wa_result_real-week1 +
                                 wa_result_real-week2 +
                                 wa_result_real-week3 +
                                 wa_result_real-week4 +
                                 wa_result_real-week5 +
                                 wa_result_real-sales1.
        APPEND wa_result_real TO i_result1_real.
        CLEAR wa_result_real.
      ENDIF.
    ENDIF.
    i_delete[] = i_result1_real[].
  ENDIF.

* cetak
  CLEAR: va_nou, wa_total, wa_subtotal, wa_sub_real, wa_total_real.
  v_current_page = 1.
  IF pa_real EQ 'X' AND
    pa_targe EQ space.
    LOOP AT i_result1_real INTO wa_result.
      SELECT SINGLE *
        FROM tvkbt
        WHERE vkbur EQ wa_result-vkbur AND
            ( spras EQ 'EN' OR spras EQ 'E' ).
      CONCATENATE 'Real :' tvkbt-bezei
           INTO va_text SEPARATED BY space.
      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) va_text NO-GAP  HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail_real.
      CLEAR wa_result.
    ENDLOOP.
  ELSE.
    LOOP AT i_result1 INTO wa_result.
      SELECT SINGLE *
        FROM tvkbt
        WHERE vkbur EQ wa_result-vkbur AND
            ( spras EQ 'EN' OR spras EQ 'E' ).
      CONCATENATE wa_result-vkbur tvkbt-bezei
           INTO va_text SEPARATED BY '-'.
      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) va_text NO-GAP HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail.

      IF pa_real EQ 'X'.
        READ TABLE i_result1_real INTO wa_result
          WITH KEY vkbur = wa_result-vkbur BINARY SEARCH.

        IF sy-subrc EQ 0.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
          CONCATENATE '     Real :' tvkbt-bezei
            INTO va_text SEPARATED BY space.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) va_text NO-GAP  HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_real.
          DELETE i_delete WHERE vkbur EQ wa_result-vkbur.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ELSE.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
          CONCATENATE '     Real :' tvkbt-bezei
            INTO va_text SEPARATED BY space.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) va_text NO-GAP  HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_kosong.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ENDIF.
      ENDIF.
      CLEAR wa_result.
    ENDLOOP.
    IF i_delete[] IS NOT INITIAL.
      PERFORM f_add_realization TABLES i_delete.
    ENDIF.
  ENDIF.
  PERFORM f_write_total.
  IF pa_real EQ 'X'.
    PERFORM f_write_total_real.
  ENDIF.
  PERFORM footer.
ENDFORM.                                                    " f_proses1

*&---------------------------------------------------------------------*
*&      Form  f_proses2
*&---------------------------------------------------------------------*
FORM f_proses2.
  CLEAR: i_result2,i_result2_real.
  CASE 'X'.
    WHEN radio2.
      i_result2[] = i_result2_cus[].
      i_result2_real[] = i_result2_real_cus[].
    WHEN radio19.
      i_result2[] = i_result2_05t[].
      i_result2_real[] = i_result2_real_05t[].
  ENDCASE.

  CLEAR: i_delete. REFRESH: i_delete.
  CLEAR l1_text.
  IF i_result2 IS INITIAL.
    SORT i_itab BY bukrs vkbur kdgrp kunnr anln1.
    CLEAR: wa_itab, wa_result, i_result2.
    LOOP AT i_itab INTO wa_itab.
      CASE 'X'.
        WHEN radio19.
          ON CHANGE OF wa_itab-bukrs OR
                       wa_itab-kdgrp OR
                       wa_itab-kunnr OR
                       wa_itab-anln1.
            IF wa_result-kunnr NE space.
              wa_result-collect = wa_result-outstanding.
              wa_result-total_r = wa_result-week1 + wa_result-week2 +
                                  wa_result-week3 + wa_result-week4 +
                                  wa_result-week5 + wa_result-sales1.
              APPEND wa_result TO i_result2.
              CLEAR wa_result.
            ENDIF.
          ENDON.
        WHEN OTHERS.
          ON CHANGE OF wa_itab-bukrs OR
                       wa_itab-kdgrp OR
                       wa_itab-kunnr.
            IF wa_result-kunnr NE space.
              wa_result-collect = wa_result-outstanding.
              wa_result-total_r = wa_result-week1 + wa_result-week2 +
                                  wa_result-week3 + wa_result-week4 +
                                  wa_result-week5 + wa_result-sales1.
              APPEND wa_result TO i_result2.
              CLEAR wa_result.
            ENDIF.
          ENDON.
      ENDCASE.

      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      MOVE wa_itab-anln1 TO wa_result-anln1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.

    IF wa_result-kunnr NE space.
      wa_result-collect = wa_result-outstanding.
      wa_result-total_r = wa_result-week1 + wa_result-week2 +
                          wa_result-week3 + wa_result-week4 +
                          wa_result-week5 + wa_result-sales1.
      APPEND wa_result TO i_result2.
      CLEAR wa_result.
    ENDIF.
  ENDIF.

  IF pa_real EQ 'X'.
    IF i_result2_real IS INITIAL.
      SORT i_itab_real BY bukrs vkbur kdgrp kunnr anln1.
      CLEAR: wa_itab_real, wa_result_real, i_result2_real.
      LOOP AT i_itab_real INTO wa_itab_real.
        CASE 'X'.
          WHEN radio19.
            ON CHANGE OF wa_itab_real-bukrs OR
                         wa_itab_real-kdgrp OR
                         wa_itab_real-kunnr OR
                         wa_itab_real-anln1.
              IF wa_result_real-kunnr NE space.
                wa_result_real-collect = wa_result_real-outstanding.
                wa_result_real-total_r = wa_result_real-week1 +
                                         wa_result_real-week2 +
                                         wa_result_real-week3 +
                                         wa_result_real-week4 +
                                         wa_result_real-week5 +
                                         wa_result_real-sales1.
                APPEND wa_result_real TO i_result2_real.
                CLEAR wa_result_real.
              ENDIF.
            ENDON.
          WHEN OTHERS.
            ON CHANGE OF wa_itab_real-bukrs OR
                         wa_itab_real-kdgrp OR
                         wa_itab_real-kunnr.
              IF wa_result_real-kunnr NE space.
                wa_result_real-collect = wa_result_real-outstanding.
                wa_result_real-total_r = wa_result_real-week1 +
                                         wa_result_real-week2 +
                                         wa_result_real-week3 +
                                         wa_result_real-week4 +
                                         wa_result_real-week5 +
                                         wa_result_real-sales1.
                APPEND wa_result_real TO i_result2_real.
                CLEAR wa_result_real.
              ENDIF.
            ENDON.
        ENDCASE.

        MOVE wa_itab_real-bukrs TO wa_result_real-bukrs.
        MOVE wa_itab_real-vkbur TO wa_result_real-vkbur.
        MOVE wa_itab_real-kunnr TO wa_result_real-kunnr.
        MOVE wa_itab_real-name1 TO wa_result_real-name1.
        MOVE wa_itab_real-anln1 TO wa_result_real-anln1.
        PERFORM f_hitung_real.
        CLEAR wa_itab_real.
      ENDLOOP.

      IF wa_result_real-kunnr NE space.
        wa_result_real-collect = wa_result_real-outstanding.
        wa_result_real-total_r = wa_result_real-week1 +
                                 wa_result_real-week2 +
                                 wa_result_real-week3 +
                                 wa_result_real-week4 +
                                 wa_result_real-week5 +
                                 wa_result_real-sales1.
        APPEND wa_result_real TO i_result2_real.
        CLEAR wa_result_real.
      ENDIF.
    ENDIF.
    i_delete[] = i_result2_real[].
  ENDIF.

  CASE 'X'.
    WHEN radio2.
      i_result2_cus[] = i_result2[].
      i_result2_real_cus[] = i_result2_real[].
    WHEN radio19.
      i_result2_05t[] = i_result2[].
      i_result2_real_05t[] = i_result2_real[].
  ENDCASE.

* cetak
  CLEAR: va_nou, wa_total, wa_subtotal, wa_sub_real, wa_total_real.
  v_current_page = 1.

  IF pa_real EQ 'X' AND
    pa_targe EQ space.
    SORT i_result2_real BY bukrs vkbur kunnr anln1.
    LOOP AT i_result2_real INTO wa_result.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-vkbur tvkbt-bezei
          INTO va_text SEPARATED BY '-'.
        WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
        c1 = c1 + 1. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

        IF radio19 = 'X'.
          c1 = c1 + w5.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        ENDIF.

        PERFORM f_write_kosong.
      ENDAT.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      CONCATENATE wa_result-kunnr wa_result-name1 INTO l1_text
        SEPARATED BY '-'.
      CONCATENATE '     Real :' l1_text
            INTO l1_text SEPARATED BY space.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) l1_text NO-GAP  HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

      IF radio19 = 'X'.
        WRITE AT c1(w5) wa_result-anln1 NO-GAP. c1 = c1 + w5.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      ENDIF.

      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail_real.

      AT END OF vkbur.
        CONCATENATE 'Sub Total' va_text INTO l1_text
          SEPARATED BY space.
        PERFORM f_write_subtotal_real USING l1_text.
        CLEAR: wa_subtotal, va_nou.
      ENDAT.
      CLEAR wa_result.
    ENDLOOP.

  ELSE.
    SORT i_result2 BY bukrs vkbur kunnr anln1.
    SORT i_result2_real BY bukrs vkbur kunnr anln1.
    LOOP AT i_result2 INTO wa_result.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-vkbur tvkbt-bezei
          INTO va_text SEPARATED BY '-'.
        WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
        c1 = c1 + 1. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

        IF radio19 = 'X'.
          c1 = c1 + w5.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        ENDIF.

        PERFORM f_write_kosong.
      ENDAT.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      CONCATENATE wa_result-kunnr wa_result-name1
            INTO l1_text SEPARATED BY '-'.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) l1_text NO-GAP HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

      IF radio19 = 'X'.
        WRITE AT c1(w5) wa_result-anln1 NO-GAP HOTSPOT. c1 = c1 + w5.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      ENDIF.

      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail.

      IF pa_real EQ 'X'.
        IF radio19 = 'X'.
          READ TABLE i_result2_real INTO wa_result
            WITH KEY vkbur = wa_result-vkbur
                     kunnr = wa_result-kunnr
                     anln1 = wa_result-anln1
          BINARY SEARCH.
        ELSE.
          READ TABLE i_result2_real INTO wa_result
            WITH KEY vkbur = wa_result-vkbur
                     kunnr = wa_result-kunnr
            BINARY SEARCH.
        ENDIF.

        IF sy-subrc EQ 0.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
          CONCATENATE wa_result-kunnr wa_result-name1 INTO l1_text
            SEPARATED BY '-'.
          CONCATENATE '     Real :' l1_text
                INTO l1_text SEPARATED BY space.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) l1_text NO-GAP HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

          IF radio19 = 'X'.
            WRITE AT c1(w5) wa_result-anln1 NO-GAP HOTSPOT. c1 = c1 + w5.
            WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          ENDIF.

          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_real.
          DELETE i_delete WHERE vkbur EQ wa_result-vkbur AND
                                kunnr EQ wa_result-kunnr.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ELSE.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
          CONCATENATE wa_result-kunnr wa_result-name1 INTO l1_text
            SEPARATED BY '-'.
          CONCATENATE '     Real :' l1_text
            INTO l1_text SEPARATED BY space.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) l1_text NO-GAP HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

          IF radio19 = 'X'.
            WRITE AT c1(w5) wa_result-anln1 NO-GAP HOTSPOT. c1 = c1 + w5.
            WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          ENDIF.

          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_kosong.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ENDIF.
      ENDIF.

      AT END OF vkbur.
        IF i_delete[] IS NOT INITIAL.
          PERFORM f_add_realization TABLES i_delete.
        ENDIF.
        CONCATENATE 'Sub Total' va_text INTO l1_text
          SEPARATED BY space.
        CONCATENATE 'Sub Total Real' va_text INTO l1_text_real
          SEPARATED BY space.
        PERFORM f_write_subtotal USING l1_text.
        IF pa_real EQ 'X'.
          PERFORM f_write_subtotal_real USING l1_text_real.
        ELSE.
          WRITE: / sy-uline.
        ENDIF.
        CLEAR: wa_subtotal, wa_sub_real, va_nou.
      ENDAT.
      CLEAR wa_result.
    ENDLOOP.
  ENDIF.
  PERFORM f_write_total.
  IF pa_real EQ 'X'.
    PERFORM f_write_total_real.
  ENDIF.
  PERFORM footer.
ENDFORM.                                                    " f_proses2

*&---------------------------------------------------------------------*
*&      Form  f_proses3
*&---------------------------------------------------------------------*
FORM f_proses3.
  DATA: l_sname LIKE pa0001-sname,
        l_ename LIKE pa0001-ename.

  REFRESH: i_delete. CLEAR: i_delete.
  CLEAR l2_text.
  IF i_result3 IS INITIAL.
    SORT i_itab BY bukrs vkbur pernr.
    CLEAR: wa_itab, wa_result, i_result3.
    LOOP AT i_itab INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-vkbur OR
                   wa_itab-pernr.
        IF wa_result-pernr NE space OR
           wa_result-outstanding NE 0.
          wa_result-collect = wa_result-outstanding.
          wa_result-total_r = wa_result-week1 + wa_result-week2 +
                              wa_result-week3 + wa_result-week4 +
                              wa_result-week5 + wa_result-sales1.
          APPEND wa_result TO i_result3.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-pernr TO wa_result-pernr.
      MOVE wa_itab-sname TO wa_result-sname.
      MOVE wa_itab-ename TO wa_result-ename.
      MOVE wa_itab-name1 TO wa_result-name1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.

    IF wa_result-pernr NE space.
      wa_result-collect = wa_result-outstanding.
      wa_result-total_r = wa_result-week1 + wa_result-week2 +
                          wa_result-week3 + wa_result-week4 +
                          wa_result-week5 + wa_result-sales1.
      APPEND wa_result TO i_result3.
      CLEAR wa_result.
    ENDIF.
  ENDIF.

  IF pa_real EQ 'X'.
    IF i_result3_real IS INITIAL.
      SORT i_itab_real BY bukrs vkbur pernr.
      CLEAR: wa_itab_real, wa_result_real, i_result3_real.
      LOOP AT i_itab_real INTO wa_itab_real.
        ON CHANGE OF wa_itab_real-bukrs OR
                     wa_itab_real-vkbur OR
                     wa_itab_real-pernr.
          IF wa_result_real-pernr NE space.
            wa_result_real-collect = wa_result_real-outstanding.
            wa_result_real-total_r = wa_result_real-week1 +
                                     wa_result_real-week2 +
                                     wa_result_real-week3 +
                                     wa_result_real-week4 +
                                     wa_result_real-week5 +
                                     wa_result_real-sales1.
            APPEND wa_result_real TO i_result3_real.
            CLEAR wa_result_real.
          ENDIF.
        ENDON.
        MOVE wa_itab_real-vkbur TO wa_result_real-vkbur.
        MOVE wa_itab_real-bukrs TO wa_result_real-bukrs.
        MOVE wa_itab_real-pernr TO wa_result_real-pernr.
        MOVE wa_itab_real-sname TO wa_result_real-sname.
        MOVE wa_itab_real-ename TO wa_result_real-ename.
        MOVE wa_itab_real-name1 TO wa_result_real-name1.
        PERFORM f_hitung_real.
        CLEAR wa_itab_real.
      ENDLOOP.

      IF wa_result_real-pernr NE space.
        wa_result_real-collect = wa_result_real-outstanding.
        wa_result_real-total_r = wa_result_real-week1 +
                                 wa_result_real-week2 +
                                 wa_result_real-week3 +
                                 wa_result_real-week4 +
                                 wa_result_real-week5 +
                                 wa_result_real-sales1.
        APPEND wa_result_real TO i_result3_real.
        CLEAR wa_result_real.
      ENDIF.
    ENDIF.
    i_delete[] = i_result3_real[].
  ENDIF.

* Cetak
  CLEAR: va_nou, wa_total, wa_subtotal, wa_sub_real, wa_total_real.
  v_current_page = 1.
  IF pa_real EQ 'X' AND
    pa_targe EQ space.
    SORT i_result3_real BY bukrs vkbur pernr.
    LOOP AT i_result3_real INTO wa_result.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-vkbur tvkbt-bezei
          INTO va_text SEPARATED BY '-'.
        WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
        c1 = c1 + 1. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        PERFORM f_write_kosong.
      ENDAT.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      SELECT SINGLE sname ename
        INTO (wa_result-sname, wa_result-ename)
        FROM pa0001
        WHERE pernr EQ wa_result-pernr.
      IF sy-subrc NE 0.
        wa_result-sname = 'Others'.
        wa_result-ename = 'Others'.
      ENDIF.
      CLEAR l2_text.
      CONCATENATE '     Real :' wa_result-pernr wa_result-sname
                  wa_result-ename
        INTO l2_text SEPARATED BY space.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) l2_text NO-GAP HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail_real.
      AT END OF vkbur.
        CONCATENATE 'Sub Total'  va_text INTO l2_text
          SEPARATED BY space.
        PERFORM f_write_subtotal_real USING l2_text.
        CLEAR: wa_subtotal, va_nou.
      ENDAT.
      CLEAR wa_result.
    ENDLOOP.
  ELSE.
    SORT i_result3 BY bukrs vkbur pernr.
    SORT i_result3_real BY bukrs vkbur pernr.
    LOOP AT i_result3 INTO wa_result.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-vkbur tvkbt-bezei
          INTO va_text SEPARATED BY '-'.
        WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
        c1 = c1 + 1. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        PERFORM f_write_kosong.
      ENDAT.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      SELECT SINGLE sname ename
        INTO (l_sname, l_ename)
        FROM pa0001
        WHERE pernr EQ wa_result-pernr.
      IF sy-subrc NE 0.
        l_sname = 'Others'.
        l_ename = 'Others'.
      ENDIF.
      CLEAR l2_text.
      CONCATENATE wa_result-pernr l_sname l_ename
        INTO l2_text SEPARATED BY space.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) l2_text NO-GAP HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail.

      IF pa_real EQ 'X'.
        READ TABLE i_result3_real INTO wa_result
          WITH KEY vkbur = wa_result-vkbur
                   pernr = wa_result-pernr
          BINARY SEARCH.

        IF sy-subrc EQ 0.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
          CONCATENATE '     Real :' wa_result-pernr l_sname l_ename
            INTO l2_text SEPARATED BY space.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) l2_text NO-GAP HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_real.
          DELETE i_delete WHERE vkbur EQ wa_result-vkbur AND
                                pernr EQ wa_result-pernr.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ELSE.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
          CONCATENATE '     Real :' wa_result-pernr l_sname l_ename
            INTO l2_text SEPARATED BY space.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) l2_text NO-GAP HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_kosong.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ENDIF.
      ENDIF.

      AT END OF vkbur.
        IF i_delete[] IS NOT INITIAL.
          PERFORM f_add_realization TABLES i_delete.
        ENDIF.

        CONCATENATE 'Sub Total'  va_text INTO l2_text
          SEPARATED BY space.
        CONCATENATE 'Sub Total Real' va_text INTO l2_text_real
          SEPARATED BY space.
        PERFORM f_write_subtotal USING l2_text.
        IF pa_real EQ 'X'.
          PERFORM f_write_subtotal_real USING l2_text_real.
        ELSE.
          WRITE: / sy-uline.
        ENDIF.
        CLEAR: wa_subtotal, wa_sub_real, va_nou.
      ENDAT.
      CLEAR wa_result.
    ENDLOOP.
  ENDIF.
  PERFORM f_write_total.
  IF pa_real EQ 'X'.
    PERFORM f_write_total_real.
  ENDIF.
  PERFORM footer.
ENDFORM.                                                    " f_proses3

*&---------------------------------------------------------------------*
*&      Form  f_proses4
*&---------------------------------------------------------------------*
FORM f_proses4.
  DATA: l_vkbur LIKE i_delete-vkbur.
  CLEAR: i_delete. REFRESH: i_delete.
  CLEAR l3_text.
  IF i_result4 IS INITIAL.
    SORT i_itab BY bukrs vkbur kdgrp kunnr.
    CLEAR: wa_itab, wa_result, i_result4.
    LOOP AT i_itab INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-vkbur OR
                   wa_itab-kdgrp.
        IF wa_result-kdgrp NE space.
          wa_result-collect = wa_result-outstanding.
          wa_result-total_r = wa_result-week1 + wa_result-week2 +
                              wa_result-week3 + wa_result-week4 +
                              wa_result-week5 + wa_result-sales1.
          APPEND wa_result TO i_result4.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-kdgrp TO wa_result-kdgrp.
      MOVE wa_itab-name1 TO wa_result-name1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.
    IF wa_result-kdgrp NE space.
      wa_result-collect = wa_result-outstanding.
      wa_result-total_r = wa_result-week1 + wa_result-week2 +
                          wa_result-week3 + wa_result-week4 +
                          wa_result-week5 + wa_result-sales1.
      APPEND wa_result TO i_result4.
      CLEAR wa_result.
    ENDIF.
  ENDIF.

  IF pa_real EQ 'X'.
    IF i_result4_real IS INITIAL.
      SORT i_itab_real BY bukrs vkbur kdgrp kunnr.
      CLEAR: wa_itab_real, wa_result_real, i_result4_real.
      LOOP AT i_itab_real INTO wa_itab_real.
        ON CHANGE OF wa_itab_real-bukrs OR
                     wa_itab_real-vkbur OR
                     wa_itab_real-kdgrp.
          IF wa_result_real-kdgrp NE space.
            wa_result_real-collect = wa_result_real-outstanding.
            wa_result_real-total_r = wa_result_real-week1 +
                                     wa_result_real-week2 +
                                     wa_result_real-week3 +
                                     wa_result_real-week4 +
                                     wa_result_real-week5 +
                                     wa_result_real-sales1.
            APPEND wa_result_real TO i_result4_real.
            CLEAR wa_result_real.
          ENDIF.
        ENDON.
        MOVE wa_itab_real-bukrs TO wa_result_real-bukrs.
        MOVE wa_itab_real-vkbur TO wa_result_real-vkbur.
        MOVE wa_itab_real-kunnr TO wa_result_real-kunnr.
        MOVE wa_itab_real-kdgrp TO wa_result_real-kdgrp.
        MOVE wa_itab_real-name1 TO wa_result_real-name1.
        PERFORM f_hitung_real.
        CLEAR wa_itab_real.
      ENDLOOP.
      IF wa_result_real-kdgrp NE space.
        wa_result_real-collect = wa_result_real-outstanding.
        wa_result_real-total_r = wa_result_real-week1 +
                                 wa_result_real-week2 +
                                 wa_result_real-week3 +
                                 wa_result_real-week4 +
                                 wa_result_real-week5 +
                                 wa_result_real-sales1.
        APPEND wa_result_real TO i_result4_real.
        CLEAR wa_result_real.
      ENDIF.
    ENDIF.
    i_delete[] = i_result4_real[].
  ENDIF.

* cetak
  CLEAR: va_nou, wa_total, wa_subtotal, wa_sub_real, wa_total_real.
  v_current_page = 1.

  IF pa_real EQ 'X' AND
    pa_targe EQ space.
    SORT i_result4_real BY bukrs vkbur kdgrp.
    LOOP AT i_result4_real INTO wa_result.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-vkbur tvkbt-bezei
            INTO va_text SEPARATED BY '-'.
        WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
        c1 = c1 + 1. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        PERFORM f_write_kosong.
      ENDAT.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      SELECT SINGLE *
        FROM t151t
        WHERE kdgrp EQ wa_result-kdgrp AND
            ( spras EQ 'EN' OR spras EQ 'E' ).
      CONCATENATE wa_result-kdgrp t151t-ktext
          INTO l3_text SEPARATED BY '-'.
      CONCATENATE 'Real :' l3_text
          INTO l3_text SEPARATED BY space.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) l3_text NO-GAP HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail_real.

      AT END OF vkbur.
        CONCATENATE 'Sub Total' va_text INTO l3_text
          SEPARATED BY space.
        PERFORM f_write_subtotal_real USING l3_text.
        CLEAR: wa_subtotal, va_nou.
      ENDAT.
      CLEAR wa_result.
    ENDLOOP.
  ELSE.
    SORT i_result4 BY bukrs vkbur kdgrp.
    SORT i_result4_real BY bukrs vkbur kdgrp.
    SORT i_delete BY bukrs vkbur kdgrp.
    LOOP AT i_result4 INTO wa_result.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-vkbur tvkbt-bezei
            INTO va_text SEPARATED BY '-'.
        WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
        c1 = c1 + 1. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        PERFORM f_write_kosong.
        l_vkbur = wa_result-vkbur.
      ENDAT.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      SELECT SINGLE *
        FROM t151t
        WHERE kdgrp EQ wa_result-kdgrp AND
            ( spras EQ 'EN' OR spras EQ 'E' ).
      CONCATENATE wa_result-kdgrp t151t-ktext
          INTO l3_text SEPARATED BY '-'.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) l3_text NO-GAP HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail.

      IF pa_real EQ 'X'.
        READ TABLE i_result4_real INTO wa_result
          WITH KEY vkbur = wa_result-vkbur
                   kdgrp = wa_result-kdgrp
          BINARY SEARCH.

        IF sy-subrc EQ 0.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
          CONCATENATE wa_result-kdgrp t151t-ktext
            INTO l3_text SEPARATED BY '-'.
          CONCATENATE '     Real :' l3_text
            INTO l3_text SEPARATED BY space.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) l3_text NO-GAP HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_real.
          DELETE i_delete WHERE vkbur EQ wa_result-vkbur AND
                                kdgrp EQ wa_result-kdgrp.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ELSE.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
          CONCATENATE wa_result-kdgrp t151t-ktext
            INTO l3_text SEPARATED BY '-'.
          CONCATENATE '     Real :' l3_text
            INTO l3_text SEPARATED BY space.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) l3_text NO-GAP HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_kosong.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ENDIF.
      ENDIF.

      AT END OF vkbur.
        IF i_delete[] IS NOT INITIAL.
*          PERFORM f_add_realization TABLES i_delete.
          READ TABLE i_delete WITH KEY vkbur = wa_result-vkbur
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            PERFORM f_add_realization TABLES i_delete.
          ENDIF.
        ENDIF.
        CONCATENATE 'Sub Total' va_text INTO l3_text
          SEPARATED BY space.
        CONCATENATE 'Sub Total Real' va_text INTO l3_text_real
          SEPARATED BY space.
        PERFORM f_write_subtotal USING l3_text.
        IF pa_real EQ 'X'.
          PERFORM f_write_subtotal_real USING l3_text_real.
        ELSE.
          WRITE: / sy-uline.
        ENDIF.
        CLEAR: wa_subtotal, wa_sub_real, va_nou.
      ENDAT.
      CLEAR wa_result.
    ENDLOOP.
  ENDIF.
  PERFORM f_write_total.
  IF pa_real EQ 'X'.
    PERFORM f_write_total_real.
  ENDIF.
  PERFORM footer.
ENDFORM.                                                    " f_proses4

*&---------------------------------------------------------------------*
*&      Form  f_proses_route
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_route.
  DATA : l_kunnr LIKE vbpa-kunnr,
         l_pernr LIKE vbpa-pernr,
         l_str TYPE i,
         l_count TYPE i,
         l_tmp(6) TYPE n,
*         l_tmp1(4) TYPE n.
         l_tmp1(10) TYPE n.

  LOOP AT i_itab INTO wa_itab.
*    IF wa_itab-blart EQ 'RV'.
*      SELECT SINGLE kunnr INTO l_kunnr FROM vbpa
*                WHERE vbeln EQ wa_itab-belnr AND
*                      parvw EQ 'ZC'.
*      IF sy-subrc EQ 0.
**        wa_itab-xref1 = l_kunnr+6(4).
*        wa_itab-xref1 = l_kunnr.
*      ENDIF.
*      SELECT SINGLE pernr INTO l_pernr FROM vbpa
*               WHERE vbeln EQ wa_itab-belnr AND
*                     parvw EQ 'ZP'.
*      IF sy-subrc EQ 0.
*        wa_itab-xref2 = l_pernr+2(6).
*      ENDIF.
*    ELSE.
*      l_str = STRLEN( wa_itab-xref2 ).
*      IF l_str <= 6.
*        l_tmp = wa_itab-xref2.
*        wa_itab-xref2 = l_tmp.
*      ELSE.
*        l_count = l_str - 6.
*        wa_itab-xref2 = wa_itab-xref2+l_count(6).
*      ENDIF.
*      l_str = STRLEN( wa_itab-xref1 ).
*      IF l_str <= 4.
*        l_tmp1 = wa_itab-xref1.
*        wa_itab-xref1 = l_tmp1.
*      ELSE.
*        l_count = l_str - 4.
*        wa_itab-xref1 = wa_itab-xref1+l_count(4).
*      ENDIF.
*    ENDIF.

    CLEAR i_zfchanel.
    IF va_flag IS INITIAL.
      READ TABLE i_zfchanel WITH KEY bukrs = wa_itab-bukrs
                                     vkbur = wa_itab-vkbur
                                     kdgrp = wa_itab-kdgrp.
      wa_itab-channel = i_zfchanel-channel.
    ELSE.
      READ TABLE i_zfchanel WITH KEY bukrs = wa_itab-bukrs
                                     vkbur = wa_itab-vkbur
                                     brsch = wa_itab-brsch.
      wa_itab-channel = i_zfchanel-channel.
    ENDIF.

    MODIFY i_itab FROM wa_itab.
  ENDLOOP.
ENDFORM.                    " f_proses_route

*&---------------------------------------------------------------------*
*&      Form  f_proses5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses5.
  DATA: l_kunnr(12),
        l_name1 LIKE kna1-name1.

  CLEAR: i_delete. REFRESH: i_delete.
  CLEAR l4_text.

  IF i_result5 IS INITIAL.
    SORT i_itab BY bukrs vkbur xref1.
    CLEAR: wa_itab, wa_result, i_result5.
    LOOP AT i_itab INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-vkbur OR
                   wa_itab-xref1.
*        IF wa_result-xref1 NE space.
        IF wa_result-bukrs NE space OR
           wa_result-vkbur NE space.
          wa_result-collect = wa_result-outstanding.
          wa_result-total_r = wa_result-week1 + wa_result-week2 +
                              wa_result-week3 + wa_result-week4 +
                              wa_result-week5 + wa_result-sales1.
          APPEND wa_result TO i_result5.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-xref1 TO wa_result-xref1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.
*    IF wa_result-xref1 NE space.
    IF wa_result-bukrs NE space OR
       wa_result-vkbur NE space.
      wa_result-collect = wa_result-outstanding.
      wa_result-total_r = wa_result-week1 + wa_result-week2 +
                          wa_result-week3 + wa_result-week4 +
                          wa_result-week5 + wa_result-sales1.
      APPEND wa_result TO i_result5.
      CLEAR wa_result.
    ENDIF.
  ENDIF.

  IF pa_real EQ 'X'.
    IF i_result5_real IS INITIAL.
      SORT i_itab_real BY bukrs vkbur xref1.
      CLEAR: wa_itab_real, wa_result_real, i_result5_real.
      LOOP AT i_itab_real INTO wa_itab_real.
        ON CHANGE OF wa_itab_real-bukrs OR
                     wa_itab_real-vkbur OR
                     wa_itab_real-xref1.
*          IF wa_result_real-xref1 NE space.
          IF wa_result_real-bukrs NE space OR
             wa_result_real-vkbur NE space.
            wa_result_real-collect = wa_result_real-outstanding.
            wa_result_real-total_r = wa_result_real-week1 +
                                     wa_result_real-week2 +
                                     wa_result_real-week3 +
                                     wa_result_real-week4 +
                                     wa_result_real-week5 +
                                     wa_result_real-sales1.
            APPEND wa_result_real TO i_result5_real.
            CLEAR wa_result_real.
          ENDIF.
        ENDON.
        MOVE wa_itab_real-vkbur TO wa_result_real-vkbur.
        MOVE wa_itab_real-bukrs TO wa_result_real-bukrs.
        MOVE wa_itab_real-xref1 TO wa_result_real-xref1.
        PERFORM f_hitung_real.
        CLEAR wa_itab_real.
      ENDLOOP.
*      IF wa_result_real-xref1 NE space.
      IF wa_result_real-bukrs NE space OR
         wa_result_real-vkbur NE space.
        wa_result_real-collect = wa_result_real-outstanding.
        wa_result_real-total_r = wa_result_real-week1 +
                                 wa_result_real-week2 +
                                 wa_result_real-week3 +
                                 wa_result_real-week4 +
                                 wa_result_real-week5 +
                                 wa_result_real-sales1.
        APPEND wa_result_real TO i_result5_real.
        CLEAR wa_result_real.
      ENDIF.
    ENDIF.
    i_delete[] = i_result5_real[].
  ENDIF.

* cetak
  CLEAR: va_nou, wa_total, wa_subtotal, wa_sub_real, wa_total_real.
  v_current_page = 1.

  IF pa_real EQ 'X' AND
    pa_targe EQ space.
    SORT i_result5_real BY bukrs vkbur xref1.
    LOOP AT i_result5_real INTO wa_result.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-vkbur tvkbt-bezei
          INTO va_text SEPARATED BY '-'.
        WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
        c1 = c1 + 1. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        PERFORM f_write_kosong.
      ENDAT.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      CLEAR l4_text.
*      CONCATENATE '000000' wa_result-xref1 INTO l_kunnr.
      l_kunnr = wa_result-xref1.

      SELECT SINGLE name1
        FROM kna1
        INTO wa_result-name1
        WHERE kunnr EQ l_kunnr.
      IF sy-subrc NE 0.
        CLEAR: wa_result-name1.
      ENDIF.

      CONCATENATE 'Real :' wa_result-xref1 wa_result-name1
        INTO l4_text
        SEPARATED BY space.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) l4_text NO-GAP HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail_real.

      AT END OF vkbur.
        CONCATENATE 'Sub Total'  va_text INTO l4_text
          SEPARATED BY space.
        PERFORM f_write_subtotal_real USING l4_text.
        CLEAR: wa_subtotal, va_nou.
      ENDAT.
      CLEAR wa_result.
    ENDLOOP.
  ELSE.
    SORT i_result5 BY bukrs vkbur xref1.
    SORT i_result5_real BY bukrs vkbur xref1.
    LOOP AT i_result5 INTO wa_result.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-vkbur tvkbt-bezei
          INTO va_text SEPARATED BY '-'.
        WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
        c1 = c1 + 1. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        PERFORM f_write_kosong.
      ENDAT.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      CLEAR l4_text.
*      CONCATENATE '000000' wa_result-xref1 INTO l_kunnr.
      l_kunnr = wa_result-xref1.

      SELECT SINGLE name1
        FROM kna1
        INTO l_name1
        WHERE kunnr EQ l_kunnr.
      IF sy-subrc NE 0.
        CLEAR: l_name1.
      ENDIF.

      CONCATENATE wa_result-xref1 l_name1 INTO l4_text
        SEPARATED BY space.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) l4_text NO-GAP HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail.

      IF pa_real EQ 'X'.
        READ TABLE i_result5_real INTO wa_result
          WITH KEY vkbur = wa_result-vkbur
                   xref1 = wa_result-xref1
          BINARY SEARCH.

        IF sy-subrc EQ 0.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
          CONCATENATE '     Real :' wa_result-xref1 l_name1
            INTO l4_text SEPARATED BY space.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) l4_text NO-GAP HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_real.
          DELETE i_delete WHERE vkbur EQ wa_result-vkbur AND
                                xref1 EQ wa_result-xref1.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ELSE.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
          CONCATENATE '     Real :' wa_result-xref1 l_name1
            INTO l4_text SEPARATED BY space.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) l4_text NO-GAP HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_kosong.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ENDIF.
      ENDIF.

      AT END OF vkbur.
        IF i_delete[] IS NOT INITIAL.
          PERFORM f_add_realization TABLES i_delete.
        ENDIF.
        CONCATENATE 'Sub Total'  va_text INTO l4_text
          SEPARATED BY space.
        CONCATENATE 'Sub Total Real' va_text INTO l4_text_real
          SEPARATED BY space.
        PERFORM f_write_subtotal USING l4_text.
        IF pa_real EQ 'X'.
          PERFORM f_write_subtotal_real USING l4_text_real.
        ELSE.
          WRITE: / sy-uline.
        ENDIF.
        CLEAR: wa_subtotal, wa_sub_real, va_nou.
      ENDAT.
      CLEAR wa_result.
    ENDLOOP.
  ENDIF.
  PERFORM f_write_total.
  IF pa_real EQ 'X'.
    PERFORM f_write_total_real.
  ENDIF.
  PERFORM footer.
ENDFORM.                                                    " f_proses5



* added by idub 20050922
*&---------------------------------------------------------------------*
*&      Form  f_proses5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses6.
  DATA: l_kunnr(10),
        l_name1 LIKE kna1-name1.

  CLEAR: i_delete. REFRESH: i_delete.
  CLEAR l5_text.

  IF i_result6 IS INITIAL.
    SORT i_itab BY bukrs vkbur brsch.
    CLEAR: wa_itab, wa_result, i_result6.
    LOOP AT i_itab INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-vkbur OR
                   wa_itab-brsch.
        IF wa_result-brsch NE space.
          wa_result-collect = wa_result-outstanding.
          wa_result-total_r = wa_result-week1 + wa_result-week2 +
                              wa_result-week3 + wa_result-week4 +
                              wa_result-week5 + wa_result-sales1.
          APPEND wa_result TO i_result6.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-brsch TO wa_result-brsch.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.
    IF wa_result-brsch NE space.
      wa_result-collect = wa_result-outstanding.
      wa_result-total_r = wa_result-week1 + wa_result-week2 +
                          wa_result-week3 + wa_result-week4 +
                          wa_result-week5 + wa_result-sales1.
      APPEND wa_result TO i_result6.
      CLEAR wa_result.
    ENDIF.
  ENDIF.

  IF pa_real EQ 'X'.
    IF i_result6_real IS INITIAL.
      SORT i_itab_real BY bukrs vkbur brsch.
      CLEAR: wa_itab_real, wa_result_real, i_result6_real.
      LOOP AT i_itab_real INTO wa_itab_real.
        ON CHANGE OF wa_itab_real-bukrs OR
                     wa_itab_real-vkbur OR
                     wa_itab_real-brsch.
          IF wa_result_real-brsch NE space.
            wa_result_real-collect = wa_result_real-outstanding.
            wa_result_real-total_r = wa_result_real-week1 +
                                     wa_result_real-week2 +
                                     wa_result_real-week3 +
                                     wa_result_real-week4 +
                                     wa_result_real-week5 +
                                     wa_result_real-sales1.
            APPEND wa_result_real TO i_result6_real.
            CLEAR wa_result_real.
          ENDIF.
        ENDON.
        MOVE wa_itab_real-vkbur TO wa_result_real-vkbur.
        MOVE wa_itab_real-bukrs TO wa_result_real-bukrs.
        MOVE wa_itab_real-brsch TO wa_result_real-brsch.
        PERFORM f_hitung_real.
        CLEAR wa_itab_real.
      ENDLOOP.
      IF wa_result_real-brsch NE space.
        wa_result_real-collect = wa_result_real-outstanding.
        wa_result_real-total_r = wa_result_real-week1 +
                                 wa_result_real-week2 +
                                 wa_result_real-week3 +
                                 wa_result_real-week4 +
                                 wa_result_real-week5 +
                                 wa_result_real-sales1.
        APPEND wa_result_real TO i_result6_real.
        CLEAR wa_result_real.
      ENDIF.
    ENDIF.
    i_delete[] = i_result6_real[].
  ENDIF.

* cetak
  CLEAR: va_nou, wa_total, wa_subtotal, wa_sub_real, wa_total_real.
  v_current_page = 1.

  IF pa_real EQ 'X' AND
    pa_targe EQ space.
    SORT i_result6_real BY bukrs vkbur brsch.
    LOOP AT i_result6_real INTO wa_result.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-vkbur tvkbt-bezei
          INTO va_text SEPARATED BY '-'.
        WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
        c1 = c1 + 1. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        PERFORM f_write_kosong.
      ENDAT.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      CLEAR l5_text.
      SELECT SINGLE brtxt
        FROM t016t
        INTO wa_result-name1
        WHERE brsch EQ wa_result-brsch AND
              spras EQ sy-langu.

      CONCATENATE 'Real :' wa_result-brsch wa_result-name1
        INTO l5_text
        SEPARATED BY space.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) l5_text NO-GAP HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail_real.

      AT END OF vkbur.
        CONCATENATE 'Sub Total'  va_text INTO l5_text
          SEPARATED BY space.
        PERFORM f_write_subtotal_real USING l5_text.
        CLEAR: wa_subtotal, va_nou.
      ENDAT.
      CLEAR wa_result.
    ENDLOOP.
  ELSE.
    SORT i_result6 BY bukrs vkbur brsch.
    SORT i_result6_real BY bukrs vkbur brsch.
    LOOP AT i_result6 INTO wa_result.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-vkbur tvkbt-bezei
          INTO va_text SEPARATED BY '-'.
        WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
        c1 = c1 + 1. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        PERFORM f_write_kosong.
      ENDAT.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      CLEAR l5_text.
      CONCATENATE '000000' wa_result-brsch INTO l_kunnr.

      SELECT SINGLE brtxt
        FROM t016t
        INTO l_name1
        WHERE brsch EQ wa_result-brsch AND
              spras EQ sy-langu.

*      SELECT SINGLE name1
*        FROM kna1
*        INTO l_name1
*        WHERE kunnr EQ l_kunnr.

      CONCATENATE wa_result-brsch l_name1 INTO l5_text
        SEPARATED BY space.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) l5_text NO-GAP HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail.

      IF pa_real EQ 'X'.
        READ TABLE i_result6_real INTO wa_result
          WITH KEY vkbur = wa_result-vkbur
                   brsch = wa_result-brsch
          BINARY SEARCH.

        IF sy-subrc EQ 0.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
          CONCATENATE '     Real :' wa_result-brsch l_name1
            INTO l5_text SEPARATED BY space.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) l5_text NO-GAP HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_real.
          DELETE i_delete WHERE vkbur EQ wa_result-vkbur AND
                                brsch EQ wa_result-brsch.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ELSE.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
          CONCATENATE '     Real :' wa_result-brsch l_name1
            INTO l5_text SEPARATED BY space.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) l5_text NO-GAP HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_kosong.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ENDIF.
      ENDIF.

      AT END OF vkbur.
        IF i_delete[] IS NOT INITIAL.
          PERFORM f_add_realization TABLES i_delete.
        ENDIF.
        CONCATENATE 'Sub Total'  va_text INTO l5_text
          SEPARATED BY space.
        CONCATENATE 'Sub Total Real' va_text INTO l5_text_real
          SEPARATED BY space.
        PERFORM f_write_subtotal USING l5_text.
        IF pa_real EQ 'X'.
          PERFORM f_write_subtotal_real USING l5_text_real.
        ELSE.
          WRITE: / sy-uline.
        ENDIF.
        CLEAR: wa_subtotal, wa_sub_real, va_nou.
      ENDAT.
      CLEAR wa_result.
    ENDLOOP.
  ENDIF.
  PERFORM f_write_total.
  IF pa_real EQ 'X'.
    PERFORM f_write_total_real.
  ENDIF.
  PERFORM footer.
ENDFORM.                                                    "f_proses6


*&---------------------------------------------------------------------*
*&      Form  f_proses7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses7.
  DATA: l_kunnr(10),
        l_name1 LIKE kna1-name1.

  CLEAR: i_delete. REFRESH: i_delete.
  CLEAR l6_text.

  IF i_result7 IS INITIAL.
    SORT i_itab BY bukrs vkbur channel kdgrp.
    CLEAR: wa_itab, wa_result, i_result7.
    LOOP AT i_itab INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-vkbur OR
                   wa_itab-channel OR
                   wa_itab-kdgrp.
        IF wa_result-channel NE space.
          wa_result-collect = wa_result-outstanding.
          wa_result-total_r = wa_result-week1 + wa_result-week2 +
                              wa_result-week3 + wa_result-week4 +
                              wa_result-week5 + wa_result-sales1.
          APPEND wa_result TO i_result7.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-kdgrp TO wa_result-kdgrp.
      MOVE wa_itab-channel TO wa_result-channel.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.
    IF wa_result-channel NE space.
      wa_result-collect = wa_result-outstanding.
      wa_result-total_r = wa_result-week1 + wa_result-week2 +
                          wa_result-week3 + wa_result-week4 +
                          wa_result-week5 + wa_result-sales1.
      APPEND wa_result TO i_result7.
      CLEAR wa_result.
    ENDIF.
  ENDIF.

  IF pa_real EQ 'X'.
    IF i_result7_real IS INITIAL.
      SORT i_itab_real BY bukrs vkbur channel kdgrp.
      CLEAR: wa_itab_real, wa_result_real, i_result7_real.
      LOOP AT i_itab_real INTO wa_itab_real.
        ON CHANGE OF wa_itab_real-bukrs OR
                     wa_itab_real-vkbur OR
                     wa_itab_real-channel OR
                     wa_itab_real-kdgrp.
          IF wa_result_real-channel NE space.
            wa_result_real-collect = wa_result_real-outstanding.
            wa_result_real-total_r = wa_result_real-week1 +
                                     wa_result_real-week2 +
                                     wa_result_real-week3 +
                                     wa_result_real-week4 +
                                     wa_result_real-week5 +
                                     wa_result_real-sales1.
            APPEND wa_result_real TO i_result7_real.
            CLEAR wa_result_real.
          ENDIF.
        ENDON.
        MOVE wa_itab_real-vkbur TO wa_result_real-vkbur.
        MOVE wa_itab_real-bukrs TO wa_result_real-bukrs.
        MOVE wa_itab_real-channel TO wa_result_real-channel.
        MOVE wa_itab_real-kdgrp TO wa_result_real-kdgrp.
        PERFORM f_hitung_real.
        CLEAR wa_itab_real.
      ENDLOOP.
      IF wa_result_real-channel NE space.
        wa_result_real-collect = wa_result_real-outstanding.
        wa_result_real-total_r = wa_result_real-week1 +
                                 wa_result_real-week2 +
                                 wa_result_real-week3 +
                                 wa_result_real-week4 +
                                 wa_result_real-week5 +
                                 wa_result_real-sales1.
        APPEND wa_result_real TO i_result7_real.
        CLEAR wa_result_real.
      ENDIF.
    ENDIF.
    i_delete[] = i_result7_real[].
  ENDIF.

* cetak
  CLEAR: va_nou, wa_total, wa_subtotal, wa_sub_real, wa_total_real.
  v_current_page = 1.

  IF pa_real EQ 'X' AND
    pa_targe EQ space.
    SORT i_result7_real BY bukrs vkbur channel kdgrp.
    LOOP AT i_result7_real INTO wa_result.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-vkbur tvkbt-bezei
          INTO va_text SEPARATED BY '-'.
        WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
        c1 = c1 + 1. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        PERFORM f_write_kosong.
      ENDAT.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      CLEAR l6_text.
*      SELECT SINGLE brtxt
*        FROM t016t
*        INTO wa_result-name1
*        WHERE channel EQ wa_result-channel AND
*              spras EQ sy-langu.

      SELECT SINGLE *
        FROM t151t
        WHERE kdgrp EQ wa_result-kdgrp AND
            ( spras EQ 'EN' OR spras EQ 'E' ).

*      CONCATENATE 'Real : ' wa_result-channel ' - ' wa_result-kdgrp '.' t151t-ktext
*        INTO l6_text.
      CLEAR v_channelr.
      v_channelr-data0 = 'Real:'.
      v_channelr-data1 = wa_result-channel.
      v_channelr-data2 = ' '.
      v_channelr-data3 = wa_result-kdgrp.
      v_channelr-data4 = '.'.
      v_channelr-data5 = t151t-ktext.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
*      WRITE AT c1(w2) l6_text NO-GAP HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(w2) v_channelr NO-GAP HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail_real.

      AT END OF vkbur.
        CONCATENATE 'Sub Total'  va_text INTO l6_text
          SEPARATED BY space.
        PERFORM f_write_subtotal_real USING l6_text.
        CLEAR: wa_subtotal, va_nou.
      ENDAT.
      CLEAR wa_result.
    ENDLOOP.
  ELSE.
    SORT i_result7 BY bukrs vkbur channel kdgrp.
    SORT i_result7_real BY bukrs vkbur channel kdgrp.
    LOOP AT i_result7 INTO wa_result.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-vkbur tvkbt-bezei
          INTO va_text SEPARATED BY '-'.
        WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
        c1 = c1 + 1. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        PERFORM f_write_kosong.
      ENDAT.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      CLEAR l6_text.
*      CONCATENATE '000000' wa_result-channel INTO l_kunnr.

*      SELECT SINGLE brtxt
*        FROM t016t
*        INTO l_name1
*        WHERE channel EQ wa_result-channel AND
*              spras EQ sy-langu.

*      SELECT SINGLE name1
*        FROM kna1
*        INTO l_name1
*        WHERE kunnr EQ l_kunnr.
      SELECT SINGLE *
        FROM t151t
        WHERE kdgrp EQ wa_result-kdgrp AND
            ( spras EQ 'EN' OR spras EQ 'E' ).

*      CONCATENATE wa_result-channel ' - ' wa_result-kdgrp '.' t151t-ktext
*        INTO l6_text.
      CLEAR v_channel.
      v_channel-data1 = wa_result-channel.
      v_channel-data2 = ' '.
      v_channel-data3 = wa_result-kdgrp.
      v_channel-data4 = '.'.
      v_channel-data5 = t151t-ktext.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
*      WRITE AT c1(w2) l6_text NO-GAP HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(w2) v_channel NO-GAP HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail.

      IF pa_real EQ 'X'.
        READ TABLE i_result7_real INTO wa_result
          WITH KEY vkbur = wa_result-vkbur
                   channel = wa_result-channel
                   kdgrp = wa_result-kdgrp
          BINARY SEARCH.

        IF sy-subrc EQ 0.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
*          CONCATENATE ' Real : ' wa_result-channel ' - ' wa_result-kdgrp '.' t151t-ktext
*            INTO l6_text.
          CLEAR v_channelr.
          v_channelr-data0 = 'Real:'.
          v_channelr-data1 = wa_result-channel.
          v_channelr-data2 = ' '.
          v_channelr-data3 = wa_result-kdgrp.
          v_channelr-data4 = '.'.
          v_channelr-data5 = t151t-ktext.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
*          WRITE AT c1(w2) l6_text NO-GAP HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(w2) v_channelr NO-GAP HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_real.
          DELETE i_delete WHERE vkbur EQ wa_result-vkbur AND
                                channel EQ wa_result-channel AND
                                kdgrp EQ wa_result-kdgrp.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ELSE.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
*          CONCATENATE ' Real : ' wa_result-channel ' - ' wa_result-kdgrp '.' t151t-ktext
*            INTO l6_text.
          CLEAR v_channelr.
          v_channelr-data0 = 'Real:'.
          v_channelr-data1 = wa_result-channel.
          v_channelr-data2 = ' '.
          v_channelr-data3 = wa_result-kdgrp.
          v_channelr-data4 = '.'.
          v_channelr-data5 = t151t-ktext.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
*          WRITE AT c1(w2) l6_text NO-GAP HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(w2) v_channelr NO-GAP HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_kosong.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ENDIF.
      ENDIF.

      AT END OF channel.
        IF i_delete[] IS NOT INITIAL.
          PERFORM f_add_realization TABLES i_delete.
        ENDIF.
        CONCATENATE 'Sub Total'  wa_result-channel INTO l6_text
          SEPARATED BY space.
        CONCATENATE 'Sub Total Real' wa_result-channel INTO l6_text_real
          SEPARATED BY space.
        PERFORM f_write_subtotal1 USING l6_text.
        IF pa_real EQ 'X'.
          PERFORM f_write_subtotal_real1 USING l6_text_real.
        ENDIF.
        CLEAR: wa_subtotal1, wa_sub_real1, va_nou.
      ENDAT.

      AT END OF vkbur.
        IF i_delete[] IS NOT INITIAL.
          PERFORM f_add_realization TABLES i_delete.
        ENDIF.
        CONCATENATE 'Sub Total'  va_text INTO l6_text
          SEPARATED BY space.
        CONCATENATE 'Sub Total Real' va_text INTO l6_text_real
          SEPARATED BY space.
        PERFORM f_write_subtotal USING l6_text.
        IF pa_real EQ 'X'.
          PERFORM f_write_subtotal_real USING l6_text_real.
        ELSE.
          WRITE: / sy-uline.
        ENDIF.
        CLEAR: wa_subtotal, wa_sub_real, va_nou.
      ENDAT.
      CLEAR wa_result.
    ENDLOOP.
  ENDIF.
  PERFORM f_write_total.
  IF pa_real EQ 'X'.
    PERFORM f_write_total_real.
  ENDIF.
  PERFORM footer.
ENDFORM.                                                    "f_proses7

*&---------------------------------------------------------------------*
*&      Form  f_proses71
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses71.
  DATA: l_kunnr(10),
        l_name1 LIKE kna1-name1.

  CLEAR: i_delete. REFRESH: i_delete.
  CLEAR l7_text.

  IF va_flag IS INITIAL.

    IF i_result7[] IS INITIAL.
      SORT i_itab BY bukrs vkbur channel kdgrp.
      CLEAR: wa_itab, wa_result, i_result7.
      LOOP AT i_itab INTO wa_itab.
        ON CHANGE OF wa_itab-bukrs OR
                     wa_itab-vkbur OR
                     wa_itab-channel OR
                     wa_itab-kdgrp.
          IF wa_result-channel NE space.
            wa_result-collect = wa_result-outstanding.
            wa_result-total_r = wa_result-week1 + wa_result-week2 +
                                wa_result-week3 + wa_result-week4 +
                                wa_result-week5 + wa_result-sales1.
            APPEND wa_result TO i_result7.
            CLEAR wa_result.
          ENDIF.
        ENDON.
        MOVE wa_itab-vkbur TO wa_result-vkbur.
        MOVE wa_itab-bukrs TO wa_result-bukrs.
        MOVE wa_itab-kdgrp TO wa_result-kdgrp.
        MOVE wa_itab-kunnr TO wa_result-kunnr.
        MOVE wa_itab-channel TO wa_result-channel.
        PERFORM f_hitung.

        CLEAR: i_result72.
        i_result72-bukrs = wa_itab-bukrs.
        i_result72-vkbur = wa_itab-vkbur.
        i_result72-channel = wa_itab-channel.
        i_result72-kdgrp = wa_itab-kdgrp.
        i_result72-kunnr = wa_itab-kunnr.
        i_result72-target = wa_itab-dmbtr + wa_itab-value.
        COLLECT i_result72.
        CLEAR: i_result72.

        CLEAR wa_itab.
      ENDLOOP.
      IF wa_result-channel NE space.
        wa_result-collect = wa_result-outstanding.
        wa_result-total_r = wa_result-week1 + wa_result-week2 +
                            wa_result-week3 + wa_result-week4 +
                            wa_result-week5 + wa_result-sales1.
        APPEND wa_result TO i_result7.
        CLEAR wa_result.
      ENDIF.
    ENDIF.

*  IF pa_real EQ 'X'.
    IF i_result7_real[] IS INITIAL.
      SORT i_itab_real BY bukrs vkbur channel kdgrp.
      CLEAR: wa_itab_real, wa_result_real, i_result7_real.
      LOOP AT i_itab_real INTO wa_itab_real.
        ON CHANGE OF wa_itab_real-bukrs OR
                     wa_itab_real-vkbur OR
                     wa_itab_real-channel OR
                     wa_itab_real-kdgrp.
          IF wa_result_real-channel NE space.
            wa_result_real-collect = wa_result_real-outstanding.
            wa_result_real-total_r = wa_result_real-week1 +
                                     wa_result_real-week2 +
                                     wa_result_real-week3 +
                                     wa_result_real-week4 +
                                     wa_result_real-week5 +
                                     wa_result_real-sales1.
            APPEND wa_result_real TO i_result7_real.
            CLEAR wa_result_real.
          ENDIF.
        ENDON.
        MOVE wa_itab_real-vkbur TO wa_result_real-vkbur.
        MOVE wa_itab_real-bukrs TO wa_result_real-bukrs.
        MOVE wa_itab_real-channel TO wa_result_real-channel.
        MOVE wa_itab_real-kdgrp TO wa_result_real-kdgrp.
        MOVE wa_itab_real-kunnr TO wa_result_real-kunnr.
        PERFORM f_hitung_real.

        CLEAR: i_result72.
        i_result72-bukrs = wa_itab_real-bukrs.
        i_result72-vkbur = wa_itab_real-vkbur.
        i_result72-channel = wa_itab_real-channel.
        i_result72-kdgrp = wa_itab_real-kdgrp.
        i_result72-kunnr = wa_itab_real-kunnr.
        i_result72-actual = wa_itab_real-dmbtr.
        COLLECT i_result72.
        CLEAR: i_result72.

        CLEAR wa_itab_real.
      ENDLOOP.
      IF wa_result_real-channel NE space.
        wa_result_real-collect = wa_result_real-outstanding.
        wa_result_real-total_r = wa_result_real-week1 +
                                 wa_result_real-week2 +
                                 wa_result_real-week3 +
                                 wa_result_real-week4 +
                                 wa_result_real-week5 +
                                 wa_result_real-sales1.
        APPEND wa_result_real TO i_result7_real.
        CLEAR wa_result_real.
      ENDIF.
    ENDIF.
*    i_delete[] = i_result7_real[].
*  ENDIF.

    IF i_result71[] IS INITIAL.
      LOOP AT i_zfchanel.
        CLEAR: i_result71, i_result72.
        i_result71-bukrs = i_zfchanel-bukrs.
        i_result71-vkbur = i_zfchanel-vkbur.
        i_result71-channel = i_zfchanel-channel.
        i_result71-kdgrp = i_zfchanel-kdgrp.
        COLLECT i_result71.
      ENDLOOP.
      LOOP AT i_result71.
        LOOP AT i_result7 INTO wa_result WHERE bukrs = i_result71-bukrs AND
                                               vkbur = i_result71-vkbur  AND
                                               channel = i_result71-channel AND
                                               kdgrp = i_result71-kdgrp.
          CLEAR: i_result71-target.
          i_result71-target = wa_result-total_r.
          COLLECT i_result71.
          CLEAR: i_result71-target.
        ENDLOOP.
        LOOP AT i_result7_real INTO wa_result WHERE bukrs = i_result71-bukrs AND
                                                    vkbur = i_result71-vkbur AND
                                                    channel = i_result71-channel AND
                                                    kdgrp = i_result71-kdgrp.
          CLEAR: i_result71-actual.
          i_result71-actual = wa_result-total_r.
          COLLECT i_result71.
          CLEAR: i_result71-actual.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

* cetak

    SORT i_result71 BY bukrs vkbur channel kdgrp.
    LOOP AT i_result71.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ i_result71-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        CONCATENATE i_result71-vkbur tvkbt-bezei
          INTO va_text SEPARATED BY '-'.
        CONCATENATE 'Total' va_text
          INTO va_texttotal1 SEPARATED BY space.
      ENDAT.
      AT NEW channel.
        CONCATENATE 'Total' i_result71-channel
          INTO va_texttotal2 SEPARATED BY space.
      ENDAT.
      AT NEW kdgrp.
        SELECT SINGLE *
          FROM t151t
          WHERE kdgrp EQ i_result71-kdgrp AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        CONCATENATE i_result71-kdgrp t151t-ktext
          INTO l7_text SEPARATED BY '-'.
      ENDAT.

      IF i_result71-target EQ 0.
        i_result71-persen = 0.
      ELSE.
        i_result71-persen = i_result71-actual / i_result71-target * 100.
      ENDIF.
      WRITE:/ '|', va_text(30), '|',
              i_result71-channel(5), '|',
              l7_text(30) HOTSPOT, '|',
              i_result71-target ROUND va_round, '|',
              i_result71-actual ROUND va_round, '|',
              i_result71-persen DECIMALS 2, '|'.

      AT END OF channel.
        SUM.
        IF i_result71-target EQ 0.
          i_result71-persen = 0.
        ELSE.
          i_result71-persen = i_result71-actual / i_result71-target * 100.
        ENDIF.
        PERFORM f_write_kosong1.
        WRITE:/ '|',
             34 '|',
             42 '|', va_texttotal2,
             75 '|',
                i_result71-target ROUND va_round, '|',
                i_result71-actual ROUND va_round, '|',
                i_result71-persen DECIMALS 2, '|'.
        PERFORM f_write_kosong1.
      ENDAT.
      AT END OF vkbur.
        SUM.
        IF i_result71-target EQ 0.
          i_result71-persen = 0.
        ELSE.
          i_result71-persen = i_result71-actual / i_result71-target * 100.
        ENDIF.

        WRITE:/ '|',
             34 '|',
             42 '|', va_texttotal1,
             75 '|',
                i_result71-target ROUND va_round, '|',
                i_result71-actual ROUND va_round, '|',
                i_result71-persen DECIMALS 2, '|'.
        PERFORM f_write_kosong1.
      ENDAT.
    ENDLOOP.
    WRITE: / sy-uline(132).
    PERFORM footer.

  ELSE.

    IF i_result7[] IS INITIAL.
      SORT i_itab BY bukrs vkbur channel brsch.
      CLEAR: wa_itab, wa_result, i_result7.
      LOOP AT i_itab INTO wa_itab.
        ON CHANGE OF wa_itab-bukrs OR
                     wa_itab-vkbur OR
                     wa_itab-channel OR
                     wa_itab-brsch.
          IF wa_result-channel NE space.
            wa_result-collect = wa_result-outstanding.
            wa_result-total_r = wa_result-week1 + wa_result-week2 +
                                wa_result-week3 + wa_result-week4 +
                                wa_result-week5 + wa_result-sales1.
            APPEND wa_result TO i_result7.
            CLEAR wa_result.
          ENDIF.
        ENDON.
        MOVE wa_itab-bukrs TO wa_result-bukrs.
        MOVE wa_itab-vkbur TO wa_result-vkbur.
        MOVE wa_itab-channel TO wa_result-channel.
        MOVE wa_itab-brsch TO wa_result-brsch.
        MOVE wa_itab-kunnr TO wa_result-kunnr.
        PERFORM f_hitung.

        CLEAR: i_result72.
        i_result72-bukrs = wa_itab-bukrs.
        i_result72-vkbur = wa_itab-vkbur.
        i_result72-channel = wa_itab-channel.
        i_result72-brsch = wa_itab-brsch.
        i_result72-kunnr = wa_itab-kunnr.
        i_result72-actual = wa_itab-dmbtr.
        COLLECT i_result72.

        CLEAR wa_itab.
      ENDLOOP.
      IF wa_result-channel NE space.
        wa_result-collect = wa_result-outstanding.
        wa_result-total_r = wa_result-week1 + wa_result-week2 +
                            wa_result-week3 + wa_result-week4 +
                            wa_result-week5 + wa_result-sales1.
        APPEND wa_result TO i_result7.
        CLEAR wa_result.
      ENDIF.
    ENDIF.

*  IF pa_real EQ 'X'.
    IF i_result7_real[] IS INITIAL.
      SORT i_itab_real BY bukrs vkbur channel brsch.
      CLEAR: wa_itab_real, wa_result_real, i_result7_real.
      LOOP AT i_itab_real INTO wa_itab_real.
        ON CHANGE OF wa_itab_real-bukrs OR
                     wa_itab_real-vkbur OR
                     wa_itab_real-channel OR
                     wa_itab_real-brsch.
          IF wa_result_real-channel NE space.
            wa_result_real-collect = wa_result_real-outstanding.
            wa_result_real-total_r = wa_result_real-week1 +
                                     wa_result_real-week2 +
                                     wa_result_real-week3 +
                                     wa_result_real-week4 +
                                     wa_result_real-week5 +
                                     wa_result_real-sales1.
            APPEND wa_result_real TO i_result7_real.
            CLEAR wa_result_real.
          ENDIF.
        ENDON.
        MOVE wa_itab_real-vkbur TO wa_result_real-vkbur.
        MOVE wa_itab_real-bukrs TO wa_result_real-bukrs.
        MOVE wa_itab_real-channel TO wa_result_real-channel.
        MOVE wa_itab_real-brsch TO wa_result_real-brsch.
        MOVE wa_itab_real-kunnr TO wa_result_real-kunnr.
        PERFORM f_hitung_real.

        CLEAR: i_result72.
        i_result72-bukrs = wa_itab_real-bukrs.
        i_result72-vkbur = wa_itab_real-vkbur.
        i_result72-channel = wa_itab_real-channel.
        i_result72-brsch = wa_itab_real-brsch.
        i_result72-kunnr = wa_itab_real-kunnr.
        i_result72-target = wa_itab_real-dmbtr.
        COLLECT i_result72.

        CLEAR wa_itab_real.
      ENDLOOP.
      IF wa_result_real-channel NE space.
        wa_result_real-collect = wa_result_real-outstanding.
        wa_result_real-total_r = wa_result_real-week1 +
                                 wa_result_real-week2 +
                                 wa_result_real-week3 +
                                 wa_result_real-week4 +
                                 wa_result_real-week5 +
                                 wa_result_real-sales1.
        APPEND wa_result_real TO i_result7_real.
        CLEAR wa_result_real.
      ENDIF.
    ENDIF.
*    i_delete[] = i_result7_real[].
*  ENDIF.

    IF i_result71[] IS INITIAL.
      LOOP AT i_zfchanel.
        CLEAR: i_result71, i_result72.
        i_result71-bukrs = i_zfchanel-bukrs.
        i_result71-vkbur = i_zfchanel-vkbur.
        i_result71-channel = i_zfchanel-channel.
        i_result71-brsch = i_zfchanel-brsch.
        COLLECT i_result71.
      ENDLOOP.
      LOOP AT i_result71.
        LOOP AT i_result7 INTO wa_result WHERE bukrs = i_result71-bukrs AND
                                               vkbur = i_result71-vkbur  AND
                                               channel = i_result71-channel AND
                                               brsch = i_result71-brsch.
          CLEAR: i_result71-target.
          i_result71-target = wa_result-total_r.
          COLLECT i_result71.
          CLEAR: i_result71-target.
        ENDLOOP.
        LOOP AT i_result7_real INTO wa_result WHERE bukrs = i_result71-bukrs AND
                                                    vkbur = i_result71-vkbur AND
                                                    channel = i_result71-channel AND
                                                    brsch = i_result71-brsch.
          CLEAR: i_result71-actual.
          i_result71-actual = wa_result-total_r.
          COLLECT i_result71.
          CLEAR: i_result71-actual.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

* cetak

    SORT i_result71 BY bukrs vkbur channel brsch.
    LOOP AT i_result71.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ i_result71-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        CONCATENATE i_result71-vkbur tvkbt-bezei
          INTO va_text SEPARATED BY '-'.
        CONCATENATE 'Total' va_text
          INTO va_texttotal1 SEPARATED BY space.
      ENDAT.
      AT NEW channel.
        CONCATENATE 'Total' i_result71-channel
          INTO va_texttotal2 SEPARATED BY space.
      ENDAT.
      AT NEW brsch.
        SELECT SINGLE brtxt
          FROM t016t
          INTO wa_result-name1
          WHERE brsch EQ i_result71-brsch AND
                spras EQ sy-langu.
        CONCATENATE i_result71-brsch wa_result-name1
          INTO l7_text SEPARATED BY '-'.
      ENDAT.

      IF i_result71-target EQ 0.
        i_result71-persen = 0.
      ELSE.
        i_result71-persen = i_result71-actual / i_result71-target * 100.
      ENDIF.

      WRITE:/ '|', va_text(30), '|',
              i_result71-channel(5), '|',
              l7_text(30) HOTSPOT, '|',
              i_result71-target ROUND va_round, '|',
              i_result71-actual ROUND va_round, '|',
              i_result71-persen DECIMALS 2, '|'.

      AT END OF channel.
        SUM.
        IF i_result71-target EQ 0.
          i_result71-persen = 0.
        ELSE.
          i_result71-persen = i_result71-actual / i_result71-target * 100.
        ENDIF.

        PERFORM f_write_kosong1.
        WRITE:/ '|',
             34 '|',
             42 '|', va_texttotal2,
             75 '|',
                i_result71-target ROUND va_round, '|',
                i_result71-actual ROUND va_round, '|',
                i_result71-persen DECIMALS 2, '|'.
        PERFORM f_write_kosong1.
      ENDAT.
      AT END OF vkbur.
        SUM.
        IF i_result71-target EQ 0.
          i_result71-persen = 0.
        ELSE.
          i_result71-persen = i_result71-actual / i_result71-target * 100.
        ENDIF.

        WRITE:/ '|',
             34 '|',
             42 '|', va_texttotal1,
             75 '|',
                i_result71-target ROUND va_round, '|',
                i_result71-actual ROUND va_round, '|',
                i_result71-persen DECIMALS 2, '|'.
        PERFORM f_write_kosong1.
      ENDAT.
    ENDLOOP.
    WRITE: / sy-uline(132).
    PERFORM footer.

  ENDIF.

ENDFORM.                                                    "f_proses71

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
FORM f_get_data.
  DATA: l_blart LIKE wa_itab-blart.
  REFRESH: t_bsid_add, t_bsad_add, i_target, i_itab_sap, i_itab_leg, i_itab.

*  PERFORM f_tambah_kunnr_sap.
*  REFRESH: t_bsid_add, t_bsad_add, i_target.
*  PERFORM f_tambah_kunnr_leg.

  IF r_vksap IS NOT INITIAL.
    REFRESH: i_itab_bsid, i_itab_bsad, i_target.
    CLEAR: i_itab_bsid, i_itab_bsad, i_target.
    IF x_opdr IS INITIAL.
      PERFORM f_get_data_sap.
    ELSE.
      PERFORM f_get_data_sap_opdr.
    ENDIF.
    APPEND LINES OF i_itab_bsid TO i_itab_sap.
    APPEND LINES OF i_itab_bsad TO i_itab_sap.
  ENDIF.
  IF r_vkleg IS NOT INITIAL.
    REFRESH: i_itab_bsid, i_itab_bsad, i_target.
    CLEAR: i_itab_bsid, i_itab_bsad, i_target.
    IF x_opdr IS INITIAL.
      PERFORM f_get_data_leg.
    ELSE.
      PERFORM f_get_data_leg_opdr.
    ENDIF.
    APPEND LINES OF i_itab_bsid TO i_itab_leg.
    APPEND LINES OF i_itab_bsad TO i_itab_leg.
  ENDIF.

  REFRESH: t_bsid_add, t_bsad_add, i_target.
  REFRESH: i_itab_bsid, i_itab_bsad.
  CLEAR: i_itab_bsid, i_itab_bsad, i_target.

  PERFORM f_hapus_kunnr.

  PERFORM f_tambah_kunnr_sap.
  REFRESH: t_bsid_add, t_bsad_add, i_target.
  PERFORM f_tambah_kunnr_leg.

*  PERFORM f_target_sales.
  PERFORM f_gabung.

  PERFORM f_modify_itab_sap.
  PERFORM f_modify_itab_leg.

  APPEND LINES OF i_itab_sap TO i_itab.
  APPEND LINES OF i_itab_leg TO i_itab.
  REFRESH: i_itab_sap, i_itab_leg.
  CLEAR: i_itab_leg, i_itab_sap.

ENDFORM.                    " f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_get_data_real
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data_real.
  REFRESH: i_itab_sap, i_itab_leg, t_bsid_add_real, t_bsad_add_real.
  CLEAR: i_itab_sap, i_itab_leg, t_bsid_add_real, t_bsad_add_real.

*  PERFORM f_tambah_kunnr_real_sap.
*  REFRESH: t_bsid_add_real, t_bsad_add_real.
*  CLEAR: t_bsid_add_real, t_bsad_add_real.
*  PERFORM f_tambah_kunnr_real_leg.

  IF r_vksap IS NOT INITIAL.
    REFRESH: i_itab_bsid_real, i_itab_bsad_real.
    CLEAR: i_itab_bsid_real, i_itab_bsad_real.
    IF x_opdr IS INITIAL.
      PERFORM f_get_real_sap.
    ELSE.
      PERFORM f_get_real_sap_opdr.
    ENDIF.
    APPEND LINES OF i_itab_bsid_real TO i_itab_sap.
    APPEND LINES OF i_itab_bsad_real TO i_itab_sap.
*      Perform f_gabung_real_sap.
  ENDIF.
  IF r_vkleg IS NOT INITIAL.
*     Write: / 'LEG'.
    REFRESH: i_itab_bsid_real, i_itab_bsad_real.
    CLEAR: i_itab_bsid_real, i_itab_bsad_real.
    IF x_opdr IS INITIAL.
      PERFORM f_get_real_leg.
    ELSE.
      PERFORM f_get_real_leg_opdr.
    ENDIF.
    APPEND LINES OF i_itab_bsid_real TO i_itab_leg.
    APPEND LINES OF i_itab_bsad_real TO i_itab_leg.
*      Perform f_gabung_real_leg.
  ENDIF.
  REFRESH: i_itab_bsid_real, i_itab_bsad_real.
  CLEAR: i_itab_bsid_real, i_itab_bsad_real.

  PERFORM f_hapus_kunnr_real.

  PERFORM f_tambah_kunnr_real_sap.
  REFRESH: t_bsid_add_real, t_bsad_add_real.
  CLEAR: t_bsid_add_real, t_bsad_add_real.
  PERFORM f_tambah_kunnr_real_leg.

  PERFORM f_gabung_real.
* sales office mapping process

  APPEND LINES OF i_itab_sap TO i_itab_real.
  APPEND LINES OF i_itab_leg TO i_itab_real.
  REFRESH: i_itab_sap, i_itab_bsad.
  CLEAR: i_itab_leg, i_itab_bsad.



*
** sales office mapping process
*  PERFORM f_hapus_kunnr_real.
*  PERFORM f_tambah_kunnr_real.
*
*  APPEND LINES OF i_itab_bsid_real TO i_itab_real.
*  APPEND LINES OF i_itab_bsad_real TO i_itab_real.
*
*  CLEAR: i_itab_bsid_real, i_itab_bsad_real, va_dmbtr.
*  LOOP AT i_itab_real INTO wa_itab_real.
*    IF wa_itab_real-vwerk NE space.
*      wa_itab_real-gsber = wa_itab_real-vwerk.
*    ENDIF.
*
**    wa_itab_real-pernr = wa_itab_real-xref2.
*     wa_itab_real-xref1 = wa_itab_real-kunn2.
*     select single pernr into  wa_itab_real-pernr from knvp
*            where kunnr = wa_itab_real-kunn2 and
*                  parvw = 'ZP' and
*                  vkorg = pa_bukrs.
*    MODIFY i_itab_real FROM wa_itab_real TRANSPORTING gsber pernr xref1.
*  ENDLOOP.
ENDFORM.                    " f_get_data_real

*&---------------------------------------------------------------------*
*&      Form  f_write_header_column
*&---------------------------------------------------------------------*
FORM f_write_header_column USING ptext LIKE kna1-name1.
  DATA: ld_week1(25),
        ld_week2(25),
        ld_week3(25),
        ld_week4(25),
        ld_week5(25).

  CONCATENATE ra_headw1-high+6(2) '/' ra_headw1-high+4(2) INTO ld_week1.
  CONCATENATE  '<=' ld_week1 INTO ld_week1
  SEPARATED BY space.

  CONCATENATE ra_headw2-low+6(2) '-' ra_headw2-high+6(2) '/' ra_headw2-low+4(2) INTO ld_week2.
  CONCATENATE ra_headw3-low+6(2) '-' ra_headw3-high+6(2) '/' ra_headw3-low+4(2) INTO ld_week3.
  CONCATENATE ra_headw4-low+6(2) '-' ra_headw4-high+6(2) '/' ra_headw4-low+4(2) INTO ld_week4.
  CONCATENATE ra_headw5-low+6(2) '-' ra_headw5-high+6(2) '/' ra_headw5-low+4(2) INTO ld_week5.
  IF ra_headw5[] IS NOT INITIAL.
    CONCATENATE  'Week5' ld_week5 INTO ld_week5
    SEPARATED BY space.
  ELSE.
    ld_week5  = 'Week5'.
  ENDIF.

  IF radio10 EQ 'X'.
  ELSEIF radio11 EQ 'X'.
    WRITE: / '( x 0 )'.
  ELSEIF radio12 EQ 'X'.
    WRITE: / '( x 00 )'.
  ELSEIF radio13 EQ 'X'.
    WRITE: / '( x 000 )'.
  ELSEIF radio14 EQ 'X'.
    WRITE: / '( x 0000 )'.
  ELSEIF radio15 EQ 'X'.
    WRITE: / '( x 00000 )'.
  ENDIF.

  IF radio10 EQ 'X'.
    WRITE: / sy-uline.
  ELSE.
    WRITE: / sy-uline(u2).
  ENDIF.

  c1 = 1.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  WRITE AT c1(w1) 'No.' NO-GAP. c1 = c1 + w1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w2) ptext NO-GAP. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  IF radio19 = 'X'.
    WRITE AT c1(w5) 'DN principal' NO-GAP. c1 = c1 + w5.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  ENDIF.
  WRITE AT c1(w3) 'Outstanding' NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'Current' NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(u1) 'Overdue' CENTERED. c1 = c1 + u1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'Total' NO-GAP CENTERED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'Week1' NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'Week2' NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'Week3' NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'Week4' NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  w4 = w3 * 3 + 2.
  WRITE AT c1(w4) ld_week5 NO-GAP CENTERED. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'Not Due' NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'C/N' NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  c1 = 1.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  c1 = c1 + w1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  IF radio19 = 'X'.
    c1 = c1 + w5.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  ENDIF.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(u1) sy-uline. c1 = c1 + u1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'Target' NO-GAP CENTERED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) ld_week1 NO-GAP. c1 = c1 + w3.
*  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
*  c1 = c1 + w3.
  WRITE AT c1(w3) ld_week2 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
*  c1 = c1 + w3.
  WRITE AT c1(w3) ld_week3 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
*  c1 = c1 + w3.
  WRITE AT c1(w3) ld_week4 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  w4 = w3 * 3 + 2.
  WRITE AT c1(w4) sy-uline. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
*  c1 = c1 + w3.
  WRITE AT c1(w3) 'Lbh Bayar' NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  c1 = 1.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  c1 = c1 + w1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  IF radio19 = 'X'.
    c1 = c1 + w5.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  ENDIF.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.


  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'DO' NO-GAP CENTERED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'CN/Lbh Byr' NO-GAP CENTERED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'Remittance' NO-GAP CENTERED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.

  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'Week5' NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  IF va_project = 'X'.
    WRITE AT c1(w3) 'Target Sales' NO-GAP. c1 = c1 + w3.
  ELSE.
    WRITE AT c1(w3) 'Sales Week 1' NO-GAP. c1 = c1 + w3.
  ENDIF.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'Total' NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 1.

  IF radio10 EQ 'X'.
    WRITE: / sy-uline.
  ELSE.
    WRITE: / sy-uline(u2).
  ENDIF.
ENDFORM.                    " f_write_header_column

*&---------------------------------------------------------------------*
*&      Form  f_write_detail
*&---------------------------------------------------------------------*
FORM f_write_detail.


  WRITE AT c1(w3) wa_result-outstanding ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-current ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-overduedo ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-overduecn ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-total_r ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week2 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week3 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week4 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week5 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-sales1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  wa_result-total = wa_result-week5 + wa_result-sales1.
  WRITE AT c1(w3) wa_result-total ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-notdue ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-cn ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.
  ADD wa_result-outstanding TO wa_total-outstanding.
  ADD wa_result-overduedo TO wa_total-overduedo.
  ADD wa_result-overduecn TO wa_total-overduecn.
  ADD wa_result-current TO wa_total-current.
  ADD wa_result-week1 TO wa_total-week1.
  ADD wa_result-week2 TO wa_total-week2.
  ADD wa_result-week3 TO wa_total-week3.
  ADD wa_result-week4 TO wa_total-week4.
  ADD wa_result-week5 TO wa_total-week5.
  ADD wa_result-total_r TO wa_total-total_r.
  ADD wa_result-notdue TO wa_total-notdue.
  ADD wa_result-sales1 TO wa_total-sales1.
  ADD wa_result-total TO wa_total-total.
  ADD wa_result-cn TO wa_total-cn.

  ADD wa_result-outstanding TO wa_subtotal-outstanding.
  ADD wa_result-overduedo TO wa_subtotal-overduedo.
  ADD wa_result-overduecn TO wa_subtotal-overduecn.
  ADD wa_result-current TO wa_subtotal-current.
  ADD wa_result-week1 TO wa_subtotal-week1.
  ADD wa_result-week2 TO wa_subtotal-week2.
  ADD wa_result-week3 TO wa_subtotal-week3.
  ADD wa_result-week4 TO wa_subtotal-week4.
  ADD wa_result-week5 TO wa_subtotal-week5.
  ADD wa_result-total_r TO wa_subtotal-total_r.
  ADD wa_result-notdue TO wa_subtotal-notdue.
  ADD wa_result-sales1 TO wa_subtotal-sales1.
  ADD wa_result-total TO wa_subtotal-total.
  ADD wa_result-cn TO wa_subtotal-cn.
ENDFORM.                    " f_write_detail
*&---------------------------------------------------------------------*
*&      Form  f_write_detail71
*&---------------------------------------------------------------------*
FORM f_write_detail71.

  WRITE AT c1(w3) wa_result-outstanding ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-current ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-overduedo ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-overduecn ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-total_r ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week2 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week3 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week4 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week5 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-sales1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  wa_result-total = wa_result-week5 + wa_result-sales1.
  WRITE AT c1(w3) wa_result-total ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-notdue ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-cn ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.
  ADD wa_result-outstanding TO wa_total-outstanding.
  ADD wa_result-overduedo TO wa_total-overduedo.
  ADD wa_result-overduecn TO wa_total-overduecn.
  ADD wa_result-current TO wa_total-current.
  ADD wa_result-week1 TO wa_total-week1.
  ADD wa_result-week2 TO wa_total-week2.
  ADD wa_result-week3 TO wa_total-week3.
  ADD wa_result-week4 TO wa_total-week4.
  ADD wa_result-week5 TO wa_total-week5.
  ADD wa_result-total_r TO wa_total-total_r.
  ADD wa_result-notdue TO wa_total-notdue.
  ADD wa_result-sales1 TO wa_total-sales1.
  ADD wa_result-total TO wa_total-total.
  ADD wa_result-cn TO wa_total-cn.

  ADD wa_result-outstanding TO wa_subtotal-outstanding.
  ADD wa_result-overduedo TO wa_subtotal-overduedo.
  ADD wa_result-overduecn TO wa_subtotal-overduecn.
  ADD wa_result-current TO wa_subtotal-current.
  ADD wa_result-week1 TO wa_subtotal-week1.
  ADD wa_result-week2 TO wa_subtotal-week2.
  ADD wa_result-week3 TO wa_subtotal-week3.
  ADD wa_result-week4 TO wa_subtotal-week4.
  ADD wa_result-week5 TO wa_subtotal-week5.
  ADD wa_result-total_r TO wa_subtotal-total_r.
  ADD wa_result-notdue TO wa_subtotal-notdue.
  ADD wa_result-sales1 TO wa_subtotal-sales1.
  ADD wa_result-total TO wa_subtotal-total.
  ADD wa_result-cn TO wa_subtotal-cn.

  ADD wa_result-outstanding TO wa_subtotal1-outstanding.
  ADD wa_result-overduedo TO wa_subtotal1-overduedo.
  ADD wa_result-overduecn TO wa_subtotal1-overduecn.
  ADD wa_result-current TO wa_subtotal1-current.
  ADD wa_result-week1 TO wa_subtotal1-week1.
  ADD wa_result-week2 TO wa_subtotal1-week2.
  ADD wa_result-week3 TO wa_subtotal1-week3.
  ADD wa_result-week4 TO wa_subtotal1-week4.
  ADD wa_result-week5 TO wa_subtotal1-week5.
  ADD wa_result-total_r TO wa_subtotal1-total_r.
  ADD wa_result-notdue TO wa_subtotal1-notdue.
  ADD wa_result-sales1 TO wa_subtotal1-sales1.
  ADD wa_result-total TO wa_subtotal1-total.
  ADD wa_result-cn TO wa_subtotal1-cn.
ENDFORM.                    " f_write_detail71
*&---------------------------------------------------------------------*
*&      Form  f_write_kosong
*&---------------------------------------------------------------------*
FORM f_write_kosong.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.
ENDFORM.                    " f_write_kosong

*&---------------------------------------------------------------------*
*&      Form  f_write_kosong71
*&---------------------------------------------------------------------*
FORM f_write_kosong71.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.
ENDFORM.                    " f_write_kosong71

*&---------------------------------------------------------------------*
*&      Form  f_hitung
*&---------------------------------------------------------------------*
FORM f_hitung.
  DATA: l_date LIKE sy-datum,
        l_date1 LIKE sy-datum,
        l_date2 LIKE sy-datum,
        l_ztag1 LIKE t052-ztag1,
        l_selisih TYPE i,
        l_budat  LIKE sy-datum,
        l_budat1 LIKE sy-datum.

** Revise by budi 26/06/2006
  IF pa_date LT va_cutdate.
    READ TABLE i_knvv WITH KEY vkorg = wa_itab-bukrs
                               vkbur = wa_itab-vkbur
                               kunnr = wa_itab-kunnr.
    IF sy-subrc = 0.
      wa_itab-zterm = i_knvv-zterm.
    ENDIF.
  ENDIF.
** End Revise by budi 26/06/2006

*diganti
  IF wa_itab-zbd1t EQ 0.
    CONCATENATE va_tanggal(6) '01' INTO l_budat.
    IF wa_itab-budat >= l_budat  AND
       wa_itab-budat <= va_tanggal1.
      IF wa_itab-shkzg = 'H'.
        wa_itab-dmbtr = wa_itab-dmbtr * -100.
      ELSE.
        wa_itab-dmbtr = wa_itab-dmbtr * 100.
      ENDIF.
      ADD wa_itab-dmbtr TO wa_result-sales1.
      EXIT.
    ENDIF.
  ELSE.
    IF wa_itab-budat > pa_date  AND
       wa_itab-budat <= va_tanggal.
      IF wa_itab-shkzg = 'H'.
        wa_itab-dmbtr = wa_itab-dmbtr * -100.
      ELSE.
        wa_itab-dmbtr = wa_itab-dmbtr * 100.
      ENDIF.
      ADD wa_itab-dmbtr TO wa_result-sales1.
      EXIT.
    ENDIF.
  ENDIF.

  wa_itab-value = wa_itab-value * 100.
  PERFORM f_get_week.

  IF wa_itab-shkzg = 'H'.
    wa_itab-dmbtr = wa_itab-dmbtr * -100.
** Koreksi by budi 07/09/2006 Req. by SJT
*    IF wa_itab-blart = 'DZ'.
    IF wa_itab-blart = 'DZ' OR wa_itab-blart = 'DA'.
** End koreksi by budi 07/09/2006 Req. by SJT
      wa_itab-zfbdt = wa_itab-budat.
    ENDIF.
  ELSE.
    wa_itab-dmbtr = wa_itab-dmbtr * 100.
    IF rad2 = 'X'.
      CLEAR: l_date1, l_date2, l_selisih.
      SELECT SINGLE b~mahdt b~audat INTO (l_date1, l_date2)
             FROM vbfa AS a JOIN vbak AS b ON  a~vbelv EQ b~vbeln
             WHERE a~vbeln = wa_itab-belnr AND
                   a~vbtyp_n = 'M' AND
                   a~vbtyp_v = 'C'.
      IF sy-subrc EQ 0 .
        l_selisih = l_date1 - l_date2.
        wa_itab-zfbdt = l_date1.
      ELSE.
        CASE pa_bukrs.
          WHEN '8020'.
            SELECT SINGLE fkdat txdat INTO (l_date1, l_date2)
                   FROM zsl_hsales
                   WHERE  vbeln EQ wa_itab-zuonr AND
                          vkbur EQ wa_itab-gsber AND
                          vkorg EQ pa_bukrs.
          WHEN '8070'.
            SELECT SINGLE fkdat txdat INTO (l_date1, l_date2)
                   FROM zssutdt005
                   WHERE  vbeln EQ wa_itab-zuonr AND
                          vkbur EQ wa_itab-gsber AND
                          vkorg EQ pa_bukrs.
          WHEN OTHERS.
        ENDCASE.
        IF sy-subrc EQ 0.
          l_selisih = l_date1 - l_date2.
          wa_itab-zfbdt = l_date2.
        ELSE.
          wa_itab-zfbdt = wa_itab-zfbdt.
        ENDIF.
      ENDIF.
    ELSE.
      SELECT SINGLE ztag1 INTO l_ztag1 FROM t052
                     WHERE zterm = wa_itab-zterm.
      wa_itab-zfbdt = wa_itab-zfbdt + l_ztag1. "wa_itab-ZBD1T.
      "Kondisi AR potongan
      IF wa_itab-umskz = 'V'.
        wa_itab-zfbdt = wa_itab-budat.
      ENDIF.
    ENDIF.
  ENDIF.

  IF wa_itab-budat <= va_tanggal.
    ADD wa_itab-dmbtr TO wa_result-outstanding.
  ENDIF.

  IF wa_itab-budat <= va_tanggal.
    IF wa_itab-zfbdt <= pa_date.
      IF wa_itab-shkzg EQ 'H'.
        ADD wa_itab-dmbtr TO wa_result-overduecn.
      ELSE.
        ADD wa_itab-dmbtr TO wa_result-overduedo.
      ENDIF.
    ELSE.
      IF wa_itab-shkzg EQ 'H'.
        ADD wa_itab-dmbtr TO wa_result-overduecn.
*      ADD wa_itab-dmbtr TO wa_result-cn.
      ENDIF.
    ENDIF.
  ENDIF.

  IF wa_itab-zfbdt > pa_date  AND wa_itab-zfbdt <= va_date1.
    IF wa_itab-shkzg EQ 'H'.
    ELSE.
      IF wa_itab-budat <= va_tanggal.
        ADD wa_itab-dmbtr TO wa_result-current.
      ENDIF.
    ENDIF.
  ENDIF.

  l_date = va_sunday.
  ADD wa_itab-value TO wa_result-sales1.

  IF wa_itab-budat <= va_tanggal.
    IF wa_itab-zfbdt >= '00000000' AND wa_itab-zfbdt <= va_sunday .
      ADD wa_itab-dmbtr TO wa_result-week1.
    ENDIF.
    l_date1 = l_date + 7.
    IF wa_itab-zfbdt > l_date AND wa_itab-zfbdt <= l_date1.
      ADD wa_itab-dmbtr TO wa_result-week2.
    ENDIF.
    l_date = l_date1.
    l_date1 = l_date + 7.
    IF wa_itab-zfbdt > l_date AND wa_itab-zfbdt <= l_date1.
      ADD wa_itab-dmbtr TO wa_result-week3.
    ENDIF.
    l_date = l_date1.
    l_date1 = l_date + 7.
    IF l_date1(6) NE l_date(6).
      l_date1 = va_date1.
    ENDIF.
    IF wa_itab-zfbdt > l_date AND wa_itab-zfbdt <= l_date1.
      ADD wa_itab-dmbtr TO wa_result-week4.
    ENDIF.
    l_date = l_date1.
    l_date1 = va_date1.
    IF wa_itab-zfbdt > l_date AND wa_itab-zfbdt <= l_date1.
      ADD wa_itab-dmbtr TO wa_result-week5.
    ENDIF.
    IF wa_itab-zfbdt > l_date1.
      ADD wa_itab-dmbtr TO wa_result-notdue.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_hitung
*&---------------------------------------------------------------------*
*&      Form  f_write_total
*&---------------------------------------------------------------------*
FORM f_write_total.
  IF radio10 EQ 'X'.
    WRITE: / sy-uline.
  ELSE.
    WRITE: / sy-uline(u2).
  ENDIF.
  c1 = 1.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  WRITE AT c1(w2) 'Grand Total ' NO-GAP. c1 = c1 + w2.
  c1 = c1 + w1.
  c1 = c1 + 1.
  IF radio19 = 'X'.
    c1 = c1 + w5 + 1.
  ENDIF.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w3) wa_total-outstanding ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total-current ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total-overduedo ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total-overduecn ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total-total_r ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total-week1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total-week2 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total-week3 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total-week4 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total-week5 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total-sales1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total-total ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total-notdue ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total-cn ROUND va_round. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.
  IF pa_real EQ space.
    IF radio10 EQ 'X'.
      WRITE: / sy-uline.
    ELSE.
      WRITE: / sy-uline(u2).
    ENDIF.
  ENDIF.
ENDFORM.                    " f_write_total

*&---------------------------------------------------------------------*
*&      Form  f_write_subtotal
*&---------------------------------------------------------------------*
FORM f_write_subtotal USING ptext TYPE text50.
  IF radio10 EQ 'X'.
    WRITE: / sy-uline.
  ELSE.
    WRITE: / sy-uline(u2).
  ENDIF.
  c1 = 1.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  IF radio19 = 'X'.
    WRITE AT c1(50) ptext NO-GAP. c1 = c1 + w2.
  ELSE.
    WRITE AT c1(w2) ptext NO-GAP. c1 = c1 + w2.
  ENDIF.
  c1 = c1 + w1.
  c1 = c1 + 1.
  IF radio19 = 'X'.
    c1 = c1 + w5 + 1.
  ENDIF.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w3) wa_subtotal-outstanding ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-current ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-overduedo ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-overduecn ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-total_r ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-week1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-week2 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-week3 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-week4 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-week5 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-sales1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-total ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-notdue ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-cn ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.
ENDFORM.                    " f_write_subtotal
*&---------------------------------------------------------------------*
*&      Form  f_write_subtotal1
*&---------------------------------------------------------------------*
FORM f_write_subtotal1 USING ptext TYPE text50.
  IF radio10 EQ 'X'.
    WRITE: / sy-uline.
  ELSE.
    WRITE: / sy-uline(u2).
  ENDIF.
  c1 = 1.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  WRITE AT c1(w2) ptext NO-GAP. c1 = c1 + w2.
  c1 = c1 + w1.
  c1 = c1 + 1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w3) wa_subtotal-outstanding ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-current ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-overduedo ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-overduecn ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-total_r ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-week1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-week2 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-week3 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-week4 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-week5 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-sales1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-total ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-notdue ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal-cn ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.
ENDFORM.                    " f_write_subtotal1
*&---------------------------------------------------------------------*
*&      Form  Cek
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek.
  DATA l_gsber LIKE bsid-gsber.

  l_gsber = so_gsber-low.

  IF l_gsber EQ space AND so_gsber-high EQ space.
    l_gsber = '*'.
  ELSEIF l_gsber NE space AND so_gsber-high NE space.
    l_gsber = '*'.
  ENDIF.
  AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
      ID 'GSBER' FIELD l_gsber
      ID 'ACTVT' FIELD '01'.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH
    'You have no authorization for Sales Office' l_gsber.
  ENDIF.

  SELECT a~vstel b~live a~werks a~lgort INTO TABLE i_tvkol FROM tvkol AS a
           JOIN zplbc AS b ON b~werks EQ a~werks AND
                              b~lgort EQ a~lgort.
*      WHERE vstel IN so_gsber.

  IF pa_bukrs EQ '8070'.
    DELETE i_tvkol WHERE  vstel(2) NE '07'.
  ELSEIF pa_bukrs EQ '8380'.
    DELETE i_tvkol WHERE  vstel(2) NE '38'.
    DELETE i_tvkol WHERE  live EQ space.
  ELSE.
    DELETE i_tvkol WHERE  vstel(2) NE '02'.
    DELETE i_tvkol WHERE  vstel    EQ '0200'.
  ENDIF.

  REFRESH: r_vksap, r_vkleg.
  CLEAR: r_vksap, r_vkleg.
  LOOP AT i_tvkol.
    IF i_tvkol-vstel IN so_gsber.
      IF i_tvkol-live = 'X'.
        r_vksap-low = i_tvkol-vstel.
        r_vksap-sign = 'I'.
        r_vksap-option = 'EQ'.
        APPEND r_vksap.
      ELSE.
        r_vkleg-low = i_tvkol-vstel.
        r_vkleg-sign = 'I'.
        r_vkleg-option = 'EQ'.
        APPEND r_vkleg.
      ENDIF.
      AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
          ID 'GSBER' FIELD i_tvkol-werks
          ID 'ACTVT' FIELD '01'.
      IF sy-subrc NE 0.
        MESSAGE e002(zz) WITH
        'You have no authorization for Sales Office' i_tvkol-werks.
        LEAVE PROGRAM.
      ENDIF.
    ENDIF.
  ENDLOOP.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE i_zfchanel
    FROM zfchanel
    WHERE bukrs = pa_bukrs AND
          vkbur IN so_gsber.

  READ TABLE i_zfchanel WITH KEY flag = 'X'.
  IF sy-subrc = 0.
    va_flag = i_zfchanel-flag.
  ENDIF.

  va_tanggal  = pa_date + pa_day.
  CLEAR: va_project.

  CONCATENATE va_tanggal(6) '01' INTO va_tanggal1.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = va_tanggal1
    IMPORTING
      last_day_of_month = va_tanggal1.
ENDFORM.                    " Cek

*&---------------------------------------------------------------------*
*&      Form  f_get_week
*&---------------------------------------------------------------------*
FORM f_get_week.
  DATA : l_month(2) TYPE n,
         l_year(4),
         l_day TYPE p,
         l_day1(2) TYPE n,
         l_date LIKE sy-datum.

  IF pa_date+4(2) EQ '12'.
    l_month = '01'.
    l_year = pa_date(4) + 1.
    CONCATENATE l_year l_month '01' INTO va_date.
  ELSE.
    l_month = pa_date+4(2) + 1.
    CONCATENATE pa_date(4) l_month '01' INTO va_date.
  ENDIF.

  PERFORM get_week USING va_date.

  CALL FUNCTION 'HR_E_NUM_OF_DAYS_OF_MONTH'
    EXPORTING
      p_fecha        = l_date
    IMPORTING
      number_of_days = l_day.

  l_day1 = l_day.
  CONCATENATE va_date(6) l_day1 INTO va_date1.
ENDFORM.                    " f_get_week

*&---------------------------------------------------------------------*
*&      Form  get_week
*&---------------------------------------------------------------------*
FORM get_week USING    p_l_date.
  CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
    EXPORTING
      date   = p_l_date
    IMPORTING
      sunday = va_sunday.

  IF p_l_date = va_sunday.
    ADD 1 TO p_l_date.
    CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
      EXPORTING
        date   = p_l_date
      IMPORTING
        sunday = va_sunday.
  ENDIF.

ENDFORM.                    " get_week

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
         chr TYPE i.

  REFRESH: i_itabtc, i_itabtc_real.
  CLEAR: ffield, fvalue.
*  READ CURRENT LINE FIELD VALUE: wa_result-vkbur, wa_result-kunnr.
  GET CURSOR FIELD ffield VALUE fvalue.

  CASE ffield.
    WHEN 'VA_TEXT'.
      APPEND LINES OF i_itab TO i_itabtc.
      APPEND LINES OF i_itab_real TO i_itabtc_real.
      DELETE i_itabtc WHERE vkbur NE fvalue(4).
      DELETE i_itabtc_real WHERE vkbur NE fvalue(4).
    WHEN 'L1_TEXT'.
      SEARCH fvalue FOR 'Real :'.
      IF sy-subrc = 0.
        SEARCH fvalue FOR '-'.
        va_pos = fvalue(sy-fdpos).
        IF pa_targe = 'X'.
          APPEND LINES OF i_itab TO i_itabtc.
          APPEND LINES OF i_itab_real TO i_itabtc_real.
          DELETE i_itabtc_real WHERE kunnr NE va_pos+12(10).
        ELSE.
          APPEND LINES OF i_itab_real TO i_itabtc.
        ENDIF.
        DELETE i_itabtc WHERE kunnr NE va_pos+12(10).
      ELSE.
        SEARCH fvalue FOR '-'.
        APPEND LINES OF i_itab TO i_itabtc.
        DELETE i_itabtc WHERE kunnr NE fvalue(sy-fdpos).
        IF pa_real = 'X'.
          APPEND LINES OF i_itab_real TO i_itabtc_real.
          DELETE i_itabtc_real WHERE kunnr NE va_pos+12(10).
        ENDIF.
      ENDIF.

*      CASE va_hotspot.
*        WHEN 2.
*          DELETE i_itabtc WHERE pernr NE va_pernr1.
*        WHEN 3.
*          DELETE i_itabtc WHERE kdgrp NE va_kdgrp.
*        WHEN 4.
*          DELETE i_itabtc WHERE xref1 NE va_xref1.
*        WHEN 5.
*          DELETE i_itabtc WHERE brsch NE va_brsch.
*        WHEN 6.
*        WHEN 7.
*      ENDCASE.

    WHEN 'L2_TEXT'.
      va_hotspot = 2.
      SEARCH fvalue FOR 'Real :'.
      IF sy-subrc = 0.
        va_pernr1 = fvalue+12(8).
        IF pa_targe = 'X'.
          APPEND LINES OF i_itab TO i_itabtc.
          APPEND LINES OF i_itab_real TO i_itabtc_real.
          DELETE i_itabtc_real WHERE pernr NE fvalue+12(8).
        ELSE.
          APPEND LINES OF i_itab_real TO i_itabtc.
        ENDIF.

*        APPEND LINES OF i_itab_real TO i_itabtc.
        DELETE i_itabtc WHERE pernr NE fvalue+12(8).
      ELSE.
        va_pernr1 = fvalue(8).
        APPEND LINES OF i_itab TO i_itabtc.
        DELETE i_itabtc WHERE pernr NE fvalue(8).
        IF pa_real = 'X'.
          APPEND LINES OF i_itab_real TO i_itabtc_real.
          DELETE i_itabtc_real WHERE pernr NE fvalue(8).
        ENDIF.
      ENDIF.

    WHEN 'L3_TEXT'.
      va_hotspot = 3.
      SEARCH fvalue FOR 'Real :'.
      IF sy-subrc = 0.
        va_kdgrp = fvalue+12(2).
        IF pa_targe = 'X'.
          APPEND LINES OF i_itab TO i_itabtc.
          APPEND LINES OF i_itab_real TO i_itabtc_real.
          DELETE i_itabtc_real WHERE kdgrp NE fvalue+12(2).
        ELSE.
          APPEND LINES OF i_itab_real TO i_itabtc.
        ENDIF.
*        APPEND LINES OF i_itab_real TO i_itabtc.
        DELETE i_itabtc WHERE kdgrp NE fvalue+12(2).
      ELSE.
        va_kdgrp = fvalue(2).
        APPEND LINES OF i_itab TO i_itabtc.
        DELETE i_itabtc WHERE kdgrp NE fvalue(2).
        IF pa_real = 'X'.
          APPEND LINES OF i_itab_real TO i_itabtc_real.
          DELETE i_itabtc_real WHERE kdgrp NE fvalue(2).
        ENDIF.
      ENDIF.

    WHEN 'L4_TEXT'.
      va_hotspot = 4.
      SEARCH fvalue FOR 'Real :'.
      IF sy-subrc = 0.
        va_xref1 = fvalue+12(10).
        IF pa_targe = 'X'.
          APPEND LINES OF i_itab TO i_itabtc.
          APPEND LINES OF i_itab_real TO i_itabtc_real.
          DELETE i_itabtc_real WHERE xref1 NE fvalue+12(10).
        ELSE.
          APPEND LINES OF i_itab_real TO i_itabtc.
        ENDIF.
*       APPEND LINES OF i_itab_real TO i_itabtc.
        DELETE i_itabtc WHERE xref1 NE fvalue+12(10).
      ELSE.
        va_xref1 = fvalue(10).
        APPEND LINES OF i_itab TO i_itabtc.
        DELETE i_itabtc WHERE xref1 NE fvalue(10).
        IF pa_real = 'X'.
          APPEND LINES OF i_itab_real TO i_itabtc_real.
          DELETE i_itabtc_real WHERE xref1 NE fvalue(10).
        ENDIF.
      ENDIF.

    WHEN 'L5_TEXT'.
      va_hotspot = 5.
      SEARCH fvalue FOR 'Real :'.
      IF sy-subrc = 0.
        va_brsch = fvalue+12(4).
        IF pa_targe = 'X'.
          APPEND LINES OF i_itab TO i_itabtc.
          APPEND LINES OF i_itab_real TO i_itabtc_real.
          DELETE i_itabtc_real WHERE brsch NE fvalue+12(4).
        ELSE.
          APPEND LINES OF i_itab_real TO i_itabtc.
        ENDIF.
*        APPEND LINES OF i_itab_real TO i_itabtc.
        DELETE i_itabtc WHERE brsch NE fvalue+12(4).
      ELSE.
        va_brsch = fvalue(4).
        APPEND LINES OF i_itab TO i_itabtc.
        DELETE i_itabtc WHERE brsch NE fvalue(4).
        IF pa_real = 'X'.
          APPEND LINES OF i_itab_real TO i_itabtc_real.
          DELETE i_itabtc_real WHERE brsch NE fvalue(4).
        ENDIF.
      ENDIF.

    WHEN 'L6_TEXT'.
      SEARCH fvalue FOR 'Real :'.
      IF sy-subrc = 0.
        IF pa_targe = 'X'.
          APPEND LINES OF i_itab TO i_itabtc.
          APPEND LINES OF i_itab_real TO i_itabtc_real.
          DELETE i_itabtc_real WHERE kdgrp NE fvalue+11(2).
        ELSE.
          APPEND LINES OF i_itab_real TO i_itabtc.
        ENDIF.
*        APPEND LINES OF i_itab_real TO i_itabtc.
        DELETE i_itabtc WHERE kdgrp NE fvalue+11(2).
      ELSE.
        APPEND LINES OF i_itab TO i_itabtc.
        DELETE i_itabtc WHERE kdgrp NE fvalue+4(2).
        IF pa_real = 'X'.
          APPEND LINES OF i_itab_real TO i_itabtc_real.
          DELETE i_itabtc_real WHERE kdgrp NE fvalue+11(2).
        ENDIF.
      ENDIF.

    WHEN 'L7_TEXT'.
      i_result72tc[] = i_result72[].
      IF va_flag IS INITIAL.
        DELETE i_result72tc WHERE kdgrp NE fvalue(2).
      ELSE.
        DELETE i_result72tc WHERE brsch NE fvalue(4).
      ENDIF.

    WHEN 'L8_TEXT'.
      va_hotspot = 8.
      SEARCH fvalue FOR 'Real :'.
      IF sy-subrc = 0.
        va_kvgr3 = fvalue+12(3).
        IF pa_targe = 'X'.
          APPEND LINES OF i_itab TO i_itabtc.
          APPEND LINES OF i_itab_real TO i_itabtc_real.
          DELETE i_itabtc_real WHERE kvgr3 NE fvalue+12(3).
        ELSE.
          APPEND LINES OF i_itab_real TO i_itabtc.
        ENDIF.
        DELETE i_itabtc WHERE kvgr3 NE fvalue+12(3).
      ELSE.
        va_kvgr3 = fvalue(3).
        APPEND LINES OF i_itab TO i_itabtc.
        DELETE i_itabtc WHERE kvgr3 NE fvalue(3).
        IF pa_real = 'X'.
          APPEND LINES OF i_itab_real TO i_itabtc_real.
          DELETE i_itabtc_real WHERE kvgr3 NE fvalue(3).
        ENDIF.
      ENDIF.

  ENDCASE.

*  SEARCH fvalue FOR 'Total'.
*  IF sy-subrc NE 0.
*    LOOP AT i_itabtc.
*      i_itabtc-dmbtr = i_itabtc-dmbtr * 100.
*      IF i_itabtc-shkzg = 'H'.
*        i_itabtc-dmbtr = i_itabtc-dmbtr * -1.
*      ENDIF.
*      MODIFY TABLE i_itabtc TRANSPORTING dmbtr.
*    ENDLOOP.
  IF ffield = 'L7_TEXT'.
    PERFORM cetak_customer.
  ELSE.
    PERFORM cetak_sales.
  ENDIF.
*    PERFORM print_alvlist.
*  ENDIF.
ENDFORM.                    " f_choose

*&---------------------------------------------------------------------*
*&      Form  PRINT_ALVLIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_alvlist.

  repid = sy-repid.
  lo_itabname = 'I_ITABTC'.        "NB: ONLY USE CAPITALS HERE!

* Fill the variables of the ALV-grid.
  PERFORM set_layout USING lo_layout. "Change layout-settings
  PERFORM set_events USING gt_xevents."Set the events (top-page etc)
  PERFORM fill_structure.             "Read the structure of the itab
  PERFORM modify_structure.           "Modify itab's field-properties

* Sort the table
*   SORT I_ITABTC BY VKBUR.

* Present the table using the ALV-grid.
*   CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = repid
      it_fieldcat        = zta_print[]
      is_layout          = lo_layout
      it_events          = gt_xevents
      i_save             = 'A'
      is_variant         = ls_variant
    TABLES
      t_outtab           = i_itabtc.

ENDFORM.                    " PRINT_ALVLIST

*&---------------------------------------------------------------------*

*&      Form  SET_LAYOUT
*&---------------------------------------------------------------------*

FORM set_layout USING pa_layout TYPE slis_layout_alv.

* Minimize the columnwidth
  pa_layout-colwidth_optimize = 'X'.
* Give the table a striped pattern
  pa_layout-zebra             = 'X'.
* Set the text of the line with totals
  pa_layout-totals_text       = 'Total:'.
* Set the text of the line with subtotals
  pa_layout-subtotals_text    = 'Subtotal:'.

* Set the variant, as requested via the checkbox
*  IF PA_VAR = 'X'.
*    LS_VARIANT-VARIANT = '/ZLAYOUT'.
*  ELSE.
  CLEAR ls_variant-variant.
*  ENDIF.

ENDFORM.                              " SET_LAYOUT

*&--------------------------------------------------------------------
*&     Form Set_events
*&--------------------------------------------------------------------
*      Appends the values of the events to the events-variable that is
*      used by REUSE_ALV_LIST_DISPLAY
*&--------------------------------------------------------------------
FORM set_events USING pa_events TYPE slis_t_event.

*   XS_EVENT-NAME = SLIS_EV_TOP_OF_LIST.
*   XS_EVENT-FORM = 'XTOP_OF_LIST'.
*   APPEND XS_EVENT TO PA_EVENTS.

*   XS_EVENT-NAME = SLIS_EV_END_OF_LIST.
*   XS_EVENT-FORM = 'XEND_OF_LIST'.
*   APPEND XS_EVENT TO PA_EVENTS.

*   XS_EVENT-NAME = SLIS_EV_TOP_OF_PAGE.
*   XS_EVENT-FORM = 'XTOP_OF_PAGE'.
*   APPEND XS_EVENT TO PA_EVENTS.

*   XS_EVENT-NAME = SLIS_EV_END_OF_PAGE.
*   XS_EVENT-FORM = 'XEND_OF_PAGE'.
*   APPEND XS_EVENT TO PA_EVENTS.

ENDFORM.                    "set_events

*&--------------------------------------------------------------------*
*&      Form  XTOP_OF_LIST
*&--------------------------------------------------------------------*
FORM xtop_of_list.
  DATA lo_date(8).
  CONCATENATE sy-datum+6(2) '.'
              sy-datum+4(2) '.'
              sy-datum+2(2)
         INTO lo_date.

  WRITE: AT  1 'Report:'(t01), 20 'Reportname'(t02).
  WRITE: AT 50 'Date:'(t03), lo_date.
  NEW-LINE.
  WRITE: AT  1 'Abap-name report: '(t04), sy-repid.
  WRITE: AT 50 'Page:'(t05), sy-cpage.
ENDFORM.                              "xtop_of_list

*&--------------------------------------------------------------------*
*&      Form  XEND_OF_LIST
*&--------------------------------------------------------------------*
FORM xend_of_list.
  WRITE: 'Footer of the list'(002).
ENDFORM.                              "xend_of_list

*&---------------------------------------------------------------------*

*&      Form  XTOP_OF_PAGE
*&---------------------------------------------------------------------*

FORM xtop_of_page.
  ihead_ln-typ = 'S'.
  ihead_ln-key = 'Date Process'.   WRITE sy-datum TO ihead_ln-info.
  APPEND ihead_ln TO ihead.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = ihead.
  REFRESH ihead.
*   WRITE:/ 'Top of the page.'(003).
*()*Here your selection-criteria can be printed
ENDFORM.                              "xtop-of-page

*&---------------------------------------------------------------------*

*&      Form  XEND_OF_PAGE
*&---------------------------------------------------------------------*

FORM xend_of_page.
  WRITE:/ 'End of the page.'(004).
ENDFORM.                              "xtop-of-page

*&---------------------------------------------------------------------*

*&      Form  FILL_STRUCTURE
*&---------------------------------------------------------------------*
FORM fill_structure.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name     = repid
      i_internal_tabname = lo_itabname
      i_inclname         = 'ZF_TARGET_REMITTANCE_NEW'
    CHANGING
      ct_fieldcat        = zta_print[].

*   Delete zta_print where fieldname ne 'VKBUR' and
*                          fieldname ne 'KUNNR' and
*                          fieldname ne 'NAME1' and
*                          fieldname ne 'ZUONR' and
*                          fieldname ne 'SHKZG' and
*                          fieldname ne 'DMBTR'.

ENDFORM.                              " FILL_STRUCTURE

*&--------------------------------------------------------------------*
*&      Form  MODIFY_STRUCTURE
*&--------------------------------------------------------------------*
*       Set the fieldproperties to your wishes
*&--------------------------------------------------------------------*
FORM modify_structure.
  LOOP AT zta_print.
    CLEAR: zta_print-key,
           zta_print-seltext_s,
           zta_print-seltext_m,
           zta_print-seltext_l.
    zta_print-seltext_s = zta_print-fieldname.
    zta_print-seltext_m = zta_print-fieldname.
    zta_print-seltext_l = zta_print-fieldname.
    CASE zta_print-fieldname.
      WHEN 'BUKRS'.
        zta_print-col_pos = 0.
        zta_print-no_out  = 'X'.
      WHEN 'VKBUR'.
        zta_print-col_pos = 1.
      WHEN 'GSBER'.
        zta_print-col_pos = 2.
        zta_print-no_out  = 'X'.
      WHEN 'BUDAT'.
        zta_print-col_pos = 3.
        zta_print-no_out  = 'X'.
      WHEN 'BLDAT'.
        zta_print-col_pos = 4.
        zta_print-no_out  = 'X'.
      WHEN 'GJAHR'.
        zta_print-col_pos = 5.
        zta_print-no_out  = 'X'.
      WHEN 'BELNR'.
        zta_print-col_pos = 6.
        zta_print-no_out  = 'X'.
      WHEN 'KDGRP'.
        zta_print-col_pos = 7.
        zta_print-no_out  = 'X'.
      WHEN 'KUNNR'.
        zta_print-col_pos = 8.
      WHEN 'BLART'.
        zta_print-col_pos = 9.
        zta_print-no_out  = 'X'.
      WHEN 'XREF1'.
        zta_print-col_pos = 10.
        zta_print-no_out  = 'X'.
      WHEN 'XREF2'.
        zta_print-col_pos = 11.
        zta_print-no_out  = 'X'.
      WHEN 'SHKZG'.
*        zta_print-col_pos = 12.
        zta_print-col_pos = 10.
      WHEN 'ZBD1T'.
        zta_print-col_pos = 13.
        zta_print-no_out  = 'X'.
      WHEN 'ZFBDT'.
        zta_print-col_pos = 14.
        zta_print-no_out  = 'X'.
      WHEN 'ZTERM'.
        zta_print-col_pos = 15.
        zta_print-no_out  = 'X'.
      WHEN 'ZUONR'.
*        zta_print-col_pos = 16.
        zta_print-col_pos = 11.
      WHEN 'DMBTR'.
        zta_print-col_pos = 17.
        zta_print-do_sum  = 'X'.
      WHEN 'VWERK'.
        zta_print-col_pos = 18.
        zta_print-no_out  = 'X'.
      WHEN 'NAME1'.
*        zta_print-col_pos = 19.
        zta_print-col_pos = 9.
      WHEN 'ROUTEL'.
        zta_print-col_pos = 20.
        zta_print-no_out  = 'X'.
      WHEN 'PERNR'.
        zta_print-col_pos = 21.
        zta_print-no_out  = 'X'.
      WHEN 'KUNDE'.
        zta_print-col_pos = 22.
        zta_print-no_out  = 'X'.
      WHEN 'PARNR'.
        zta_print-col_pos = 23.
        zta_print-no_out  = 'X'.
      WHEN 'VRTNR'.
        zta_print-col_pos = 24.
        zta_print-no_out  = 'X'.
      WHEN 'SNAME'.
        zta_print-col_pos = 25.
        zta_print-no_out  = 'X'.
      WHEN 'ENAME'.
        zta_print-col_pos = 26.
        zta_print-no_out  = 'X'.
    ENDCASE.
    MODIFY zta_print.
  ENDLOOP.
ENDFORM.                              " modify_structure

*&---------------------------------------------------------------------*
*&      Form  f_cek_itab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cek_itab.

  DATA : l_dmbtr LIKE bsid-dmbtr.

  SORT i_itab BY bukrs vkbur zuonr.
  LOOP AT i_itab INTO wa_itab.
    IF wa_itab-shkzg = 'H'.
      wa_itab-dmbtr = wa_itab-dmbtr * -1.
    ENDIF.
    ADD wa_itab-dmbtr TO l_dmbtr.
    AT END OF zuonr.
      IF l_dmbtr = 0.
        DELETE i_itab WHERE zuonr = wa_itab-zuonr.
      ENDIF.
      CLEAR l_dmbtr.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " f_cek_itab

*&---------------------------------------------------------------------*
*&      Form  f_hitung_real
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hitung_real.
  DATA: l_date LIKE sy-datum,
        l_date1 LIKE sy-datum,
        l_date2 LIKE sy-datum,
        l_ztag1 LIKE t052-ztag1,
        l_selisih TYPE i.

  PERFORM f_get_week.

  IF wa_itab_real-shkzg = 'H'.
    wa_itab_real-dmbtr = wa_itab_real-dmbtr * -100.
  ELSE.
    wa_itab_real-dmbtr = wa_itab_real-dmbtr * 100.
  ENDIF.

  l_date = va_sunday.
  IF wa_itab_real-budat >= '00000000' AND
    wa_itab_real-budat <= va_sunday .
    ADD wa_itab_real-dmbtr TO wa_result_real-week1.
  ENDIF.
  l_date1 = l_date + 7.
  IF wa_itab_real-budat > l_date AND
    wa_itab_real-budat <= l_date1.
    ADD wa_itab_real-dmbtr TO wa_result_real-week2.
  ENDIF.
  l_date = l_date1.
  l_date1 = l_date + 7.
  IF wa_itab_real-budat > l_date AND
    wa_itab_real-budat <= l_date1.
    ADD wa_itab_real-dmbtr TO wa_result_real-week3.
  ENDIF.
  l_date = l_date1.
  l_date1 = l_date + 7.
  IF wa_itab_real-budat > l_date AND
    wa_itab_real-budat <= l_date1.
    ADD wa_itab_real-dmbtr TO wa_result_real-week4.
  ENDIF.
  l_date = l_date1.
  l_date1 = va_date1.
  IF wa_itab_real-budat > l_date AND
    wa_itab_real-budat <= l_date1.
    ADD wa_itab_real-dmbtr TO wa_result_real-week5.
  ENDIF.
ENDFORM.                    " f_hitung_real

*&---------------------------------------------------------------------*
*&      Form  f_write_detail_kosong
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_detail_kosong.
  WRITE AT c1(w3) space NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.
ENDFORM.                    " f_write_detail_kosong

*&---------------------------------------------------------------------*
*&      Form  f_write_detail_kosong71
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_detail_kosong71.
  WRITE AT c1(w3) space NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.
ENDFORM.                    " f_write_detail_kosong71

*&---------------------------------------------------------------------*
*&      Form  round
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM round.
  IF radio10 EQ 'X'.
    va_round = 0.
  ELSEIF radio11 EQ 'X'.
    va_round = 1.
  ELSEIF radio12 EQ 'X'.
    va_round = 2.
  ELSEIF radio13 EQ 'X'.
    va_round = 3.
  ELSEIF radio14 EQ 'X'.
    va_round = 4.
  ELSEIF radio15 EQ 'X'.
    va_round = 5.
  ENDIF.
ENDFORM.                    " round

*&---------------------------------------------------------------------*
*&      Form  f_write_header1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_header1.
  DATA: l_cli(25).

  c1 = 0.
  WRITE AT c1(h1) 'Report  :' INTENSIFIED OFF. c1 = c1 + h1.
  WRITE AT c1(h2) v_repid. c1 = c1 + h2.
  WRITE AT c1(ls) v_title1 CENTERED. c1 = c1 + ls.
  WRITE: 220 'Date    :' INTENSIFIED OFF,
             sy-datum DD/MM/YYYY.

  c1 = 0.
  CONCATENATE sy-mandt sy-sysid INTO l_cli
    SEPARATED BY '/'.
  WRITE AT /c1(h1) 'Cli/Sys :' INTENSIFIED OFF. c1 = c1 + h1.
  WRITE AT c1(h2) l_cli. c1 = c1 + h2.
  WRITE AT c1(ls) v_title2 CENTERED. c1 = c1 + ls.
  WRITE: 220 'Time    :' INTENSIFIED OFF,
             sy-uzeit.

  c1 = 0.
  WRITE AT /c1(h1) 'UserID  :' INTENSIFIED OFF. c1 = c1 + h1.
*  WRITE AT c1(h2) sy-uname. c1 = c1 + h2.
  WRITE AT c1(h1) sy-uname. c1 = c1 + h1.
  WRITE AT c1(3) ' / '. c1 = c1 + 3.
  WRITE AT c1(h1) sy-tcode. c1 = c1 + h1.
  WRITE AT c1(ls) v_title3 CENTERED. c1 = c1 + ls.
  WRITE: 220 'Page    :' INTENSIFIED OFF,
             sy-pagno.
ENDFORM.                    " f_write_header1

*&---------------------------------------------------------------------*
*&      Form  f_write_detail_real
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_detail_real.


  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-total_r ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week2 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week3 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week4 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week5 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-sales1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  wa_result-total = wa_result-week5 + wa_result-sales1.
  WRITE AT c1(w3) wa_result-total ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.

  ADD wa_result-week1 TO wa_total_real-week1.
  ADD wa_result-week2 TO wa_total_real-week2.
  ADD wa_result-week3 TO wa_total_real-week3.
  ADD wa_result-week4 TO wa_total_real-week4.
  ADD wa_result-week5 TO wa_total_real-week5.
  ADD wa_result-total_r TO wa_total_real-total_r.
  ADD wa_result-sales1 TO wa_total_real-sales1.
  ADD wa_result-total TO wa_total_real-total.

  ADD wa_result-week1 TO wa_sub_real-week1.
  ADD wa_result-week2 TO wa_sub_real-week2.
  ADD wa_result-week3 TO wa_sub_real-week3.
  ADD wa_result-week4 TO wa_sub_real-week4.
  ADD wa_result-week5 TO wa_sub_real-week5.
  ADD wa_result-total_r TO wa_sub_real-total_r.
  ADD wa_result-sales1 TO wa_sub_real-sales1.
  ADD wa_result-total TO wa_sub_real-total.
ENDFORM.                    " f_write_detail_real

*&---------------------------------------------------------------------*
*&      Form  f_write_detail_real71
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_detail_real71.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-total_r ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week2 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week3 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week4 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-week5 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_result-sales1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  wa_result-total = wa_result-week5 + wa_result-sales1.
  WRITE AT c1(w3) wa_result-total ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.

  ADD wa_result-week1 TO wa_total_real-week1.
  ADD wa_result-week2 TO wa_total_real-week2.
  ADD wa_result-week3 TO wa_total_real-week3.
  ADD wa_result-week4 TO wa_total_real-week4.
  ADD wa_result-week5 TO wa_total_real-week5.
  ADD wa_result-total_r TO wa_total_real-total_r.
  ADD wa_result-sales1 TO wa_total_real-sales1.
  ADD wa_result-total TO wa_total_real-total.

  ADD wa_result-week1 TO wa_sub_real-week1.
  ADD wa_result-week2 TO wa_sub_real-week2.
  ADD wa_result-week3 TO wa_sub_real-week3.
  ADD wa_result-week4 TO wa_sub_real-week4.
  ADD wa_result-week5 TO wa_sub_real-week5.
  ADD wa_result-total_r TO wa_sub_real-total_r.
  ADD wa_result-sales1 TO wa_sub_real-sales1.
  ADD wa_result-total TO wa_sub_real-total.

  ADD wa_result-week1 TO wa_sub_real1-week1.
  ADD wa_result-week2 TO wa_sub_real1-week2.
  ADD wa_result-week3 TO wa_sub_real1-week3.
  ADD wa_result-week4 TO wa_sub_real1-week4.
  ADD wa_result-week5 TO wa_sub_real1-week5.
  ADD wa_result-total_r TO wa_sub_real1-total_r.
  ADD wa_result-sales1 TO wa_sub_real1-sales1.
  ADD wa_result-total TO wa_sub_real1-total.
ENDFORM.                    " f_write_detail_real71

*&---------------------------------------------------------------------*
*&      Form  f_write_subtotal_real
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L1_TEXT_REAL  text
*----------------------------------------------------------------------*
FORM f_write_subtotal_real  USING ptext TYPE text50.
  FORMAT COLOR 1.
  FORMAT INTENSIFIED OFF.
  c1 = 1.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  IF radio19 = 'X'.
    WRITE AT c1(50) ptext NO-GAP. c1 = c1 + w2.
  ELSE.
    WRITE AT c1(w2) ptext NO-GAP. c1 = c1 + w2.
  ENDIF.
  c1 = c1 + w1.
  c1 = c1 + 1.
  IF radio19 = 'X'.
    c1 = c1 + w5 + 1.
  ENDIF.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_sub_real-total_r ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_sub_real-week1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_sub_real-week2 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_sub_real-week3 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_sub_real-week4 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_sub_real-week5 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_sub_real-sales1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_sub_real-total ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.

  IF radio10 EQ 'X'.
    WRITE: / sy-uline.
  ELSE.
    WRITE: / sy-uline(u2).
  ENDIF.
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED ON.
ENDFORM.                    " f_write_subtotal_real

*&---------------------------------------------------------------------*
*&      Form  f_write_subtotal_real1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L1_TEXT_REAL  text
*----------------------------------------------------------------------*
FORM f_write_subtotal_real1  USING ptext TYPE text50.
  FORMAT COLOR 1.
  FORMAT INTENSIFIED OFF.
  c1 = 1.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  WRITE AT c1(w2) ptext NO-GAP. c1 = c1 + w2.
  c1 = c1 + w1.
  c1 = c1 + 1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_sub_real-total_r ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_sub_real-week1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_sub_real-week2 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_sub_real-week3 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_sub_real-week4 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_sub_real-week5 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_sub_real-sales1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_sub_real-total ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.

  IF radio10 EQ 'X'.
    WRITE: / sy-uline.
  ELSE.
    WRITE: / sy-uline(u2).
  ENDIF.
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED ON.
ENDFORM.                    " f_write_subtotal_real1

*&---------------------------------------------------------------------*
*&      Form  f_write_total_real
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_total_real.
  FORMAT COLOR 1.
  FORMAT INTENSIFIED OFF.

  c1 = 1.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  WRITE AT c1(w2) 'Grand Total Real' NO-GAP. c1 = c1 + w2.
  c1 = c1 + w1.
  c1 = c1 + 1.
  IF radio19 = 'X'.
    c1 = c1 + w5 + 1.
  ENDIF.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total_real-total_r ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total_real-week1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total_real-week2 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total_real-week3 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total_real-week4 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total_real-week5 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total_real-sales1 ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total_real-total ROUND va_round NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space NO-GAP.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) space. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.

  IF radio10 EQ 'X'.
    WRITE: / sy-uline.
  ELSE.
    WRITE: / sy-uline(u2).
  ENDIF.
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED ON.
ENDFORM.                    " f_write_total_real

*&---------------------------------------------------------------------*
*&      Form  footer
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM footer.
  DATA: l_check1(1),
        l_check2(1),
        ld_sw  TYPE i,
        ld_bschl(50).

  SKIP 1.
  IF so_kdgrp-low EQ space AND
    so_kdgrp-high EQ space.
    WRITE: / 'Customer group     :' INTENSIFIED OFF,
             'All Customer group'.
  ELSE.
    IF so_kdgrp-high EQ space.
      WRITE: / 'Customer group     :' INTENSIFIED OFF, so_kdgrp-low.
      LOOP AT so_kdgrp FROM 2.
        WRITE: /22 so_kdgrp-low.
      ENDLOOP.
    ELSE.
      WRITE: / 'Customer group     :' INTENSIFIED OFF,
                so_kdgrp-low, 'to', so_kdgrp-high.
    ENDIF.
  ENDIF.

  WRITE: / 'PROCESS SELECTION' INTENSIFIED OFF.
  IF x_norm EQ 'X'.
    l_check1 = 'x'.
  ENDIF.
  IF x_shbv EQ 'X'.
    l_check2 = 'x'.
  ELSE.
    CLEAR: s_bschl.
  ENDIF.

  LOOP AT s_bschl.
    IF ld_sw EQ 0.
      ld_sw = 1.
      ld_bschl = s_bschl-low.
    ELSE.
      CONCATENATE ld_bschl ',' s_bschl-low INTO ld_bschl
      SEPARATED BY space.
    ENDIF.
  ENDLOOP.

  WRITE: /4 l_check1, 'Normal items' INTENSIFIED OFF,
         /4 l_check2, 'Special G/L transactions :' INTENSIFIED OFF.
  IF x_shbv EQ 'X'.
    WRITE: ld_bschl.
  ENDIF.
ENDFORM.                    " footer

*&---------------------------------------------------------------------*
*&      Form  f_proses_route_real
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_route_real.
  DATA : l_kunnr LIKE vbpa-kunnr,
         l_pernr LIKE vbpa-pernr,
         l_str TYPE i,
         l_count TYPE i,
         l_tmp(6) TYPE n,
         l_tmp1(4) TYPE n.

  LOOP AT i_itab_real INTO wa_itab_real.
*    IF wa_itab_real-blart EQ 'RV'.
*      SELECT SINGLE kunnr INTO l_kunnr FROM vbpa
*                WHERE vbeln EQ wa_itab_real-belnr AND
*                      parvw EQ 'ZC'.
*      IF sy-subrc EQ 0.
**        wa_itab_real-xref1 = l_kunnr+6(4).
*        wa_itab_real-xref1 = l_kunnr.
*      ENDIF.
*      SELECT SINGLE pernr INTO l_pernr FROM vbpa
*               WHERE vbeln EQ wa_itab_real-belnr AND
*                     parvw EQ 'ZP'.
*      IF sy-subrc EQ 0.
*        wa_itab_real-xref2 = l_pernr+2(6).
*      ENDIF.
*    ELSE.
*      l_str = STRLEN( wa_itab_real-xref2 ).
*      IF l_str <= 6.
*        l_tmp = wa_itab_real-xref2.
*        wa_itab_real-xref2 = l_tmp.
*      ELSE.
*        l_count = l_str - 6.
*        wa_itab_real-xref2 = wa_itab_real-xref2+l_count(6).
*      ENDIF.
*      l_str = STRLEN( wa_itab_real-xref1 ).
*      IF l_str <= 4.
*        l_tmp1 = wa_itab_real-xref1.
*        wa_itab_real-xref1 = l_tmp1.
*      ELSE.
*        l_count = l_str - 4.
*        wa_itab_real-xref1 = wa_itab_real-xref1+l_count(4).
*      ENDIF.
*    ENDIF.

    CLEAR i_zfchanel.
    IF va_flag IS INITIAL.
      READ TABLE i_zfchanel WITH KEY bukrs = wa_itab_real-bukrs
                                     vkbur = wa_itab_real-vkbur
                                     kdgrp = wa_itab_real-kdgrp.
      wa_itab_real-channel = i_zfchanel-channel.
    ELSE.
      READ TABLE i_zfchanel WITH KEY bukrs = wa_itab_real-bukrs
                                     vkbur = wa_itab_real-vkbur
                                     brsch = wa_itab_real-brsch.
      wa_itab_real-channel = i_zfchanel-channel.
    ENDIF.

    MODIFY i_itab_real FROM wa_itab_real.
  ENDLOOP.
ENDFORM.                    " f_proses_route_real

*&---------------------------------------------------------------------*
*&      Form  check_sales_routlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_sales_routlist.

  IF NOT p_slcode[] IS INITIAL.
    LOOP AT i_itab INTO wa_itab.
      IF NOT wa_itab-pernr IN p_slcode.
        DELETE i_itab.
      ENDIF.
    ENDLOOP.
    LOOP AT i_itab_real INTO wa_itab.
      IF NOT wa_itab-pernr IN p_slcode.
        DELETE i_itab_real.
      ENDIF.
    ENDLOOP.
  ELSEIF NOT  p_route[] IS INITIAL.
    LOOP AT i_itab INTO wa_itab.
      IF NOT wa_itab-xref1 IN p_route.
        DELETE i_itab.
      ENDIF.
    ENDLOOP.
    LOOP AT i_itab_real INTO wa_itab.
      IF NOT wa_itab-xref1 IN p_route.
        DELETE i_itab_real.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " check_sales_routlist
*&---------------------------------------------------------------------*
*&      Form  cetak_sales
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_sales.

  PERFORM f_write_header1.
  PERFORM f_write_header_column USING 'Customer'.
  PERFORM f_detail_salesman.

ENDFORM.                    " cetak_sales
*&---------------------------------------------------------------------*
*&      Form  f_detail_salesman
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_detail_salesman.
  CLEAR: l1_text, i_result_salesman, i_result_real_salesman.
  REFRESH: i_result_salesman, i_result_real_salesman, i_delete.
  IF i_result_salesman IS INITIAL.
    SORT i_itabtc BY bukrs vkbur kdgrp kunnr.
    CLEAR: wa_itab, wa_result, i_result_salesman.
    LOOP AT i_itabtc INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-kdgrp OR
                   wa_itab-kunnr.
        IF wa_result-kunnr NE space.
          wa_result-collect = wa_result-outstanding.
          wa_result-total_r = wa_result-week1 + wa_result-week2 +
                              wa_result-week3 + wa_result-week4 +
                              wa_result-week5 + wa_result-sales1.
          APPEND wa_result TO i_result_salesman.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.

    IF wa_result-kunnr NE space.
      wa_result-collect = wa_result-outstanding.
      wa_result-total_r = wa_result-week1 + wa_result-week2 +
                          wa_result-week3 + wa_result-week4 +
                          wa_result-week5 + wa_result-sales1.
      APPEND wa_result TO i_result_salesman.
      CLEAR wa_result.
    ENDIF.

  ENDIF.

  IF pa_real EQ 'X'.
    IF i_result_real_salesman IS INITIAL.
*      SORT i_itab_real BY bukrs vkbur kdgrp kunnr.
      SORT i_itabtc_real BY bukrs vkbur kdgrp kunnr.
      CLEAR: wa_itab_real, wa_result_real, i_result_real_salesman.
*      LOOP AT i_itab_real INTO wa_itab_real.
      LOOP AT i_itabtc_real INTO wa_itab_real.
        ON CHANGE OF wa_itab_real-bukrs OR
                     wa_itab_real-kdgrp OR
                     wa_itab_real-kunnr.
          IF wa_result_real-kunnr NE space.
            wa_result_real-collect = wa_result_real-outstanding.
            wa_result_real-total_r = wa_result_real-week1 +
                                     wa_result_real-week2 +
                                     wa_result_real-week3 +
                                     wa_result_real-week4 +
                                     wa_result_real-week5 +
                                     wa_result_real-sales1.
            APPEND wa_result_real TO i_result_real_salesman.
            CLEAR wa_result_real.
          ENDIF.
        ENDON.
        MOVE wa_itab_real-bukrs TO wa_result_real-bukrs.
        MOVE wa_itab_real-vkbur TO wa_result_real-vkbur.
        MOVE wa_itab_real-kunnr TO wa_result_real-kunnr.
        MOVE wa_itab_real-name1 TO wa_result_real-name1.
        PERFORM f_hitung_real.
        CLEAR wa_itab_real.
      ENDLOOP.

      IF wa_result_real-kunnr NE space.
        wa_result_real-collect = wa_result_real-outstanding.
        wa_result_real-total_r = wa_result_real-week1 +
                                 wa_result_real-week2 +
                                 wa_result_real-week3 +
                                 wa_result_real-week4 +
                                 wa_result_real-week5 +
                                 wa_result_real-sales1.
        APPEND wa_result_real TO i_result_real_salesman.
        CLEAR wa_result_real.
        i_delete[] = i_result_real_salesman[].
      ENDIF.
    ENDIF.
  ENDIF.

* cetak
  CLEAR: va_nou, wa_total, wa_subtotal, wa_sub_real, wa_total_real.
  v_current_page = 1.

  IF pa_real EQ 'X' AND
    pa_targe EQ space.
    SORT i_result_real_salesman BY bukrs vkbur kunnr.
    LOOP AT i_result_real_salesman INTO wa_result.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-vkbur tvkbt-bezei
          INTO va_text SEPARATED BY '-'.
        WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
        c1 = c1 + 1. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        PERFORM f_write_kosong.
      ENDAT.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      CONCATENATE wa_result-kunnr wa_result-name1 INTO l1_text
        SEPARATED BY '-'.
      CONCATENATE '     Real :' l1_text
            INTO l1_text SEPARATED BY space.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) l1_text NO-GAP. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail_real.

      AT END OF vkbur.
        CONCATENATE 'Sub Total' va_text INTO l1_text
          SEPARATED BY space.
        PERFORM f_write_subtotal_real USING l1_text.
        CLEAR: wa_subtotal, va_nou.
      ENDAT.
      CLEAR wa_result.
    ENDLOOP.
  ELSE.
    SORT i_result_salesman BY bukrs vkbur kunnr.
    SORT i_result_real_salesman BY bukrs vkbur kunnr.
    LOOP AT i_result_salesman INTO wa_result.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-vkbur tvkbt-bezei
          INTO va_text SEPARATED BY '-'.
        WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
        c1 = c1 + 1. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        PERFORM f_write_kosong.
      ENDAT.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      CONCATENATE wa_result-kunnr wa_result-name1
            INTO l1_text SEPARATED BY '-'.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) l1_text NO-GAP. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail.

      IF pa_real EQ 'X'.
        READ TABLE i_result_real_salesman INTO wa_result
          WITH KEY vkbur = wa_result-vkbur
                   kunnr = wa_result-kunnr
          BINARY SEARCH.

        IF sy-subrc EQ 0.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
          CONCATENATE wa_result-kunnr wa_result-name1 INTO l1_text
            SEPARATED BY '-'.
          CONCATENATE '     Real :' l1_text
                INTO l1_text SEPARATED BY space.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) l1_text NO-GAP. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_real.
          DELETE i_delete WHERE vkbur EQ wa_result-vkbur AND
                                kunnr EQ wa_result-kunnr.

          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ELSE.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
          CONCATENATE wa_result-kunnr wa_result-name1 INTO l1_text
            SEPARATED BY '-'.
          CONCATENATE '     Real :' l1_text
            INTO l1_text SEPARATED BY space.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) l1_text NO-GAP. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_kosong.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ENDIF.
      ENDIF.

      AT END OF vkbur.
        IF i_delete[] IS NOT INITIAL.
          PERFORM f_add_realization TABLES i_delete.
        ENDIF.

        CONCATENATE 'Sub Total' va_text INTO l1_text
          SEPARATED BY space.
        CONCATENATE 'Sub Total Real' va_text INTO l1_text_real
          SEPARATED BY space.
        PERFORM f_write_subtotal USING l1_text.
        PERFORM f_write_subtotal_real USING l1_text_real.
        CLEAR: wa_subtotal, wa_sub_real, va_nou.
      ENDAT.
      CLEAR wa_result.
    ENDLOOP.
  ENDIF.
  PERFORM f_write_total.
  IF pa_real EQ 'X'.
    PERFORM f_write_total_real.
  ENDIF.
  PERFORM footer.

ENDFORM.                    " f_detail_salesman

*&---------------------------------------------------------------------*
*&      Form  f_add_realization
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_RESULT_REAL  text
*----------------------------------------------------------------------*
FORM f_add_realization TABLES ft_result_real.
  DATA: l_sname LIKE pa0001-sname,
        l_ename LIKE pa0001-ename,
        l_kunnr(10),
        l_name1 LIKE kna1-name1,
        ld_text(100),
        ld_case TYPE i.

  CLEAR: ld_case.
  IF radio1 EQ 'X' OR sy-ucomm EQ 'BRANCH'.
    ld_case = 1.
  ENDIF.
  IF radio2 EQ 'X' OR sy-ucomm EQ 'CUSTOMER'.
    ld_case = 2.
  ENDIF.
  IF radio3 EQ 'X' OR sy-ucomm EQ 'SALESMAN'.
    ld_case = 3.
  ENDIF.
  IF radio4 EQ 'X' OR sy-ucomm EQ 'CUSTGROUP'.
    ld_case = 4.
  ENDIF.
  IF radio5 EQ 'X' OR sy-ucomm EQ 'ROUTE'.
    ld_case = 5.
  ENDIF.
  IF radio16 EQ 'X' OR sy-ucomm EQ 'INDUSTRY'.
    ld_case = 6.
  ENDIF.
  IF radio17 EQ 'X' OR sy-ucomm EQ 'CHANNEL'.
    ld_case = 7.
  ENDIF.

  LOOP AT ft_result_real INTO wa_result.
    CASE ld_case.
      WHEN 1.
        CLEAR ld_text.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        CONCATENATE wa_result-vkbur tvkbt-bezei
             INTO ld_text SEPARATED BY '-'.
        PERFORM f_write_detail_kosong_target USING ld_text.

      WHEN 2.
        CLEAR ld_text.
        CONCATENATE wa_result-kunnr wa_result-name1
          INTO ld_text SEPARATED BY '-'.
        PERFORM f_write_detail_kosong_target USING ld_text.

      WHEN 3.
        CLEAR ld_text.
        SELECT SINGLE sname ename
          INTO (l_sname, l_ename)
          FROM pa0001
          WHERE pernr EQ wa_result-pernr.
        IF sy-subrc NE 0.
          l_sname = 'Others'.
          l_ename = 'Others'.
        ENDIF.
        CONCATENATE wa_result-pernr l_sname l_ename
          INTO ld_text SEPARATED BY space.
        PERFORM f_write_detail_kosong_target USING ld_text.

      WHEN 4.
        CLEAR ld_text.
        SELECT SINGLE *
          FROM t151t
          WHERE kdgrp EQ wa_result-kdgrp AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        CONCATENATE wa_result-kdgrp t151t-ktext
            INTO ld_text SEPARATED BY '-'.
        PERFORM f_write_detail_kosong_target USING ld_text.

      WHEN 5.
        CLEAR ld_text.
        CONCATENATE '000000' wa_result-xref1 INTO l_kunnr.
        SELECT SINGLE name1
          FROM kna1
          INTO l_name1
          WHERE kunnr EQ l_kunnr.
        IF sy-subrc NE 0.
          CLEAR: l_name1.
        ENDIF.
        CONCATENATE wa_result-xref1 l_name1 INTO ld_text
          SEPARATED BY space.
        PERFORM f_write_detail_kosong_target USING ld_text.

      WHEN 6.
        CLEAR ld_text.
        CONCATENATE '000000' wa_result-brsch INTO l_kunnr.
        SELECT SINGLE brtxt
          FROM t016t
          INTO l_name1
          WHERE brsch EQ wa_result-brsch AND
                spras EQ sy-langu.
        CONCATENATE wa_result-brsch l_name1 INTO ld_text
          SEPARATED BY space.
        PERFORM f_write_detail_kosong_target USING ld_text.

      WHEN 7.
        CLEAR ld_text.
*        CONCATENATE '000000' wa_result-brsch INTO l_kunnr.
*        SELECT SINGLE brtxt
*          FROM t016t
*          INTO l_name1
*          WHERE brsch EQ wa_result-brsch AND
*                spras EQ sy-langu.
*        CONCATENATE wa_result-brsch l_name1 INTO ld_text
*          SEPARATED BY space.
        ld_text = wa_result-channel.
        PERFORM f_write_detail_kosong_target USING ld_text.
    ENDCASE.

    FORMAT COLOR 1.
    FORMAT INTENSIFIED OFF.
    CONCATENATE '     Real :' ld_text
      INTO ld_text SEPARATED BY space.
    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w2) ld_text NO-GAP HOTSPOT. c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    SET LEFT SCROLL-BOUNDARY.
    PERFORM f_write_detail_real.
    FORMAT COLOR OFF.
    FORMAT INTENSIFIED ON.
  ENDLOOP.
ENDFORM.                    " f_add_realization

*&---------------------------------------------------------------------*
*&      Form  f_write_detail_kosong_target
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FD_TEXT  text
*----------------------------------------------------------------------*
FORM f_write_detail_kosong_target USING fd_text.
  ADD 1 TO va_nou.
  c1 = 1.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w2) fd_text NO-GAP HOTSPOT. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 0 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.
ENDFORM.                    " f_write_detail_kosong_target

*&---------------------------------------------------------------------*
*&      Form  f_write_kosong1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_kosong1 .
  WRITE:/ '|',
       34 '|',
       42 '|',
       75 '|',
       94 '|',
      113 '|',
      132 '|'.
ENDFORM.                    " f_write_kosong1

*&---------------------------------------------------------------------*
*&      Form  f_write_header_column1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_header_column1 .
  WRITE: / sy-uline(132).
  WRITE:/ '|', (30) 'Branch' CENTERED,
          '|',  (5) 'Chanl' CENTERED,
          '|', (30) 'Customer Group' CENTERED,
          '|', (16) 'Target' CENTERED,
          '|', (16) 'Actual' CENTERED,
          '|', (16) 'Percen' CENTERED,
          '|'.
  WRITE: / sy-uline(132).
*      WRITE:/ '|',
*           34 '|',
*           42 '|',
*           75 '|',
*              i_result71-target ROUND va_round, '|',
*              i_result71-actual ROUND va_round, '|',
*              i_result71-persen DECIMALS 2, '|'.
ENDFORM.                    " f_write_header_column1

*&---------------------------------------------------------------------*
*&      Form  f_write_header11
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_header11 .
  DATA: l_cli(25).

  c1 = 0.
  WRITE AT c1(h1) 'Report  :' INTENSIFIED OFF. c1 = c1 + h1.
  WRITE AT c1(h2) v_repid. c1 = c1 + h2.
  WRITE (70) v_title1 CENTERED. c1 = c1 + ls.
  WRITE: 110 'Date    :' INTENSIFIED OFF,
             sy-datum DD/MM/YYYY.

  c1 = 0.
  CONCATENATE sy-mandt sy-sysid INTO l_cli
    SEPARATED BY '/'.
  WRITE AT /c1(h1) 'Cli/Sys :' INTENSIFIED OFF. c1 = c1 + h1.
  WRITE AT c1(h2) l_cli. c1 = c1 + h2.
  WRITE (70) v_title2 CENTERED. c1 = c1 + ls.
  WRITE: 110 'Time    :' INTENSIFIED OFF,
             sy-uzeit.

  c1 = 0.
  WRITE AT /c1(h1) 'UserID  :' INTENSIFIED OFF. c1 = c1 + h1.
*  WRITE AT c1(h2) sy-uname. c1 = c1 + h2.
  WRITE AT c1(h1) sy-uname. c1 = c1 + h1.
  WRITE AT c1(3) ' / '. c1 = c1 + 3.
  WRITE AT c1(h1) sy-tcode. c1 = c1 + h1.
  WRITE (70) v_title3 CENTERED. c1 = c1 + ls.
  WRITE: 110 'Page    :' INTENSIFIED OFF,
             sy-pagno.
ENDFORM.                    " f_write_header11

*&---------------------------------------------------------------------*
*&      Form  cetak_customer
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_customer .
  DATA: l_kunnr LIKE kna1-kunnr.

  v_title2 = 'A/R Target Remittance Per Branch and Channel'.
  PERFORM f_write_header11.
  PERFORM f_write_header_column1.

  IF va_flag IS INITIAL.

    SORT i_result72tc BY bukrs vkbur channel kdgrp kunnr.
    LOOP AT i_result72tc.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ i_result72tc-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        CONCATENATE i_result72tc-vkbur tvkbt-bezei
          INTO va_text SEPARATED BY '-'.
        CONCATENATE 'Total' va_text
          INTO va_texttotal1 SEPARATED BY space.
      ENDAT.
      AT NEW channel.
        CONCATENATE 'Total' i_result72tc-channel
          INTO va_texttotal2 SEPARATED BY space.
      ENDAT.
      AT NEW kdgrp.
        SELECT SINGLE *
          FROM t151t
          WHERE kdgrp EQ i_result72tc-kdgrp AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        CONCATENATE i_result72tc-kdgrp t151t-ktext
          INTO l7_text SEPARATED BY '-'.
      ENDAT.
      AT NEW kunnr.
        SELECT SINGLE name1 INTO l_kunnr
          FROM kna1
          WHERE kunnr EQ i_result72tc-kunnr.
        CONCATENATE i_result72tc-kunnr l_kunnr
          INTO l7_text SEPARATED BY '-'.
      ENDAT.

      IF i_result72tc-target NE 0.
        i_result72tc-persen = i_result72tc-actual / i_result72tc-target * 100.
      ENDIF.
      WRITE:/ '|', va_text(30), '|',
              i_result72tc-channel(5), '|',
              l7_text(30), '|',
              i_result72tc-target ROUND va_round, '|',
              i_result72tc-actual ROUND va_round, '|',
              i_result72tc-persen DECIMALS 2, '|'.

      AT END OF channel.
        SUM.
        IF i_result72tc-target NE 0.
          i_result72tc-persen = i_result72tc-actual / i_result72tc-target * 100.
        ENDIF.
        PERFORM f_write_kosong1.
        WRITE:/ '|',
             34 '|',
             42 '|', va_texttotal2,
             75 '|',
                i_result72tc-target ROUND va_round, '|',
                i_result72tc-actual ROUND va_round, '|',
                i_result72tc-persen DECIMALS 2, '|'.
        PERFORM f_write_kosong1.
      ENDAT.
      AT END OF vkbur.
        SUM.
        IF i_result72tc-target NE 0.
          i_result72tc-persen = i_result72tc-actual / i_result72tc-target * 100.
        ENDIF.
        WRITE:/ '|',
             34 '|',
             42 '|', va_texttotal1,
             75 '|',
                i_result72tc-target ROUND va_round, '|',
                i_result72tc-actual ROUND va_round, '|',
                i_result72tc-persen DECIMALS 2, '|'.
        PERFORM f_write_kosong1.
      ENDAT.
    ENDLOOP.
    WRITE: / sy-uline(132).

  ELSE.

    SORT i_result72tc BY bukrs vkbur channel brsch kunnr.
    LOOP AT i_result72tc.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ i_result72tc-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        CONCATENATE i_result72tc-vkbur tvkbt-bezei
          INTO va_text SEPARATED BY '-'.
        CONCATENATE 'Total' va_text
          INTO va_texttotal1 SEPARATED BY space.
      ENDAT.
      AT NEW channel.
        CONCATENATE 'Total' i_result72tc-channel
          INTO va_texttotal2 SEPARATED BY space.
      ENDAT.
      AT NEW brsch.
        SELECT SINGLE brtxt
          FROM t016t
          INTO wa_result-name1
          WHERE brsch EQ i_result72tc-brsch AND
                spras EQ sy-langu.
        CONCATENATE i_result72tc-brsch wa_result-name1
          INTO l7_text SEPARATED BY '-'.
      ENDAT.
      AT NEW kunnr.
        SELECT SINGLE name1 INTO l_kunnr
          FROM kna1
          WHERE kunnr EQ i_result72tc-kunnr.
        CONCATENATE i_result72tc-kunnr l_kunnr
          INTO l7_text SEPARATED BY '-'.
      ENDAT.

      IF i_result72tc-target NE 0.
        i_result72tc-persen = i_result72tc-actual / i_result72tc-target * 100.
      ENDIF.
      WRITE:/ '|', va_text(30), '|',
              i_result72tc-channel(5), '|',
              l7_text(30), '|',
              i_result72tc-target ROUND va_round, '|',
              i_result72tc-actual ROUND va_round, '|',
              i_result72tc-persen DECIMALS 2, '|'.

      AT END OF channel.
        SUM.
        IF i_result72tc-target NE 0.
          i_result72tc-persen = i_result72tc-actual / i_result72tc-target * 100.
        ENDIF.
        PERFORM f_write_kosong1.
        WRITE:/ '|',
             34 '|',
             42 '|', va_texttotal2,
             75 '|',
                i_result72tc-target ROUND va_round, '|',
                i_result72tc-actual ROUND va_round, '|',
                i_result72tc-persen DECIMALS 2, '|'.
        PERFORM f_write_kosong1.
      ENDAT.
      AT END OF vkbur.
        SUM.
        IF i_result72tc-target NE 0.
          i_result72tc-persen = i_result72tc-actual / i_result72tc-target * 100.
        ENDIF.
        WRITE:/ '|',
             34 '|',
             42 '|', va_texttotal1,
             75 '|',
                i_result72tc-target ROUND va_round, '|',
                i_result72tc-actual ROUND va_round, '|',
                i_result72tc-persen DECIMALS 2, '|'.
        PERFORM f_write_kosong1.
      ENDAT.
    ENDLOOP.
    WRITE: / sy-uline(132).

  ENDIF.

ENDFORM.                    " cetak_customer

*&---------------------------------------------------------------------*
*&      Form  f_mapping_soff
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_mapping_soff .

  SELECT bukrs kvgr3 actual
    FROM zftop
    INTO CORRESPONDING FIELDS OF TABLE t_zftop
    WHERE bukrs EQ pa_bukrs.

  IF so_kunnr IS NOT INITIAL.
    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_dele
      WHERE kunnr    IN so_kunnr AND
            zvkbur1  IN so_gsber AND
            budat    GE pa_date.
    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_add
      WHERE kunnr  IN so_kunnr AND
            budat  GE pa_date.
  ELSE.
    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_dele
      WHERE zvkbur1  IN so_gsber AND
            budat    GE pa_date.

    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_add
      WHERE budat  GE pa_date.
  ENDIF.

  SORT t_zfarsoff_add BY zvkbur.
  LOOP AT t_zfarsoff_add INTO wa_zfarsoff.
    LOOP AT i_tvkol WHERE vstel = wa_zfarsoff-zvkbur.
      IF i_tvkol-live = 'X'.
        i_zfarsoff_add_sap-bukrs = pa_bukrs.
        i_zfarsoff_add_sap-zvkbur = wa_zfarsoff-zvkbur1.
        i_zfarsoff_add_sap-kunnr = wa_zfarsoff-kunnr.
*               i_zfarsoff_add_sap-zvkbur1 = wa_zfarsoff-zvkbur1.
        APPEND i_zfarsoff_add_sap.
      ELSE.
        i_zfarsoff_add_leg-bukrs = pa_bukrs.
        i_zfarsoff_add_leg-zvkbur = wa_zfarsoff-zvkbur1.
        i_zfarsoff_add_leg-kunnr = wa_zfarsoff-kunnr.
        APPEND i_zfarsoff_add_leg.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " f_mapping_soff

*&---------------------------------------------------------------------*
*&      Form  f_hapus_kunnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hapus_kunnr .
  IF t_zfarsoff_dele[] IS NOT INITIAL.
    SORT i_itab_sap BY kunnr pkunwe.
    SORT i_itab_leg BY kunnr pkunwe.
    SORT t_zfarsoff_dele BY kunnr.
    LOOP AT i_itab_sap INTO wa_itab.
      READ TABLE t_zfarsoff_dele WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        DELETE i_itab_sap.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.

    LOOP AT i_itab_leg INTO wa_itab.
      READ TABLE t_zfarsoff_dele WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        DELETE i_itab_leg.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_hapus_kunnr

*&---------------------------------------------------------------------*
*&      Form  f_tambah_kunnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_tambah_kunnr_sap .
  DATA: l_top TYPE i,
        lv_budat  TYPE bsid-budat.

  IF i_zfarsoff_add_sap[] IS NOT INITIAL.
    va_tanggal  = pa_date + pa_day.

    DATA: l_date1(8),
          l_date2(8),
          l_spmon LIKE ztgtsls-spmon,
          l_monat1(2) TYPE n,
          l_monat2(2) TYPE n.

    l_monat1 = pa_date+4(2).
    l_monat2 = pa_date+4(2) + 1.
    l_spmon = va_tanggal(6).

    CONCATENATE pa_date(4) l_monat1 '01' INTO l_date1.
    CONCATENATE pa_date(4) l_monat2 '01' INTO l_date2.
    REFRESH: i_target.
    CLEAR: i_target.

    REFRESH: i_target.
    CLEAR: wa_itab, i_itab.
    SORT i_zfarsoff_add_sap BY bukrs zvkbur kunnr.
    IF va_project = 'X'.
*      SELECT a~spmon  a~pkunwe a~kvgr2 b~kdgrp a~vkbur a~waerk a~value a~ztop
*                   c~name1 c~brsch                          "d~kunn2
*                   APPENDING CORRESPONDING FIELDS OF TABLE i_target
*                   FROM ztgtsls AS a
*                        JOIN kna1 AS c ON c~kunnr EQ a~pkunwe
*                        JOIN knvv AS b ON a~pkunwe EQ b~kunnr AND
*                                           b~vkorg EQ pa_bukrs
*                                              AND b~vkorg EQ pa_bukrs
**                            LEFT JOIN knvp AS d ON d~kunnr EQ a~pkunwe AND
**                                              d~parvw EQ 'ZC'
**                                              AND d~vkorg EQ pa_bukrs
*                  FOR ALL ENTRIES IN i_zfarsoff_add_sap "t_zfarsoff_add
*                   WHERE a~spmon EQ l_spmon AND
**                       a~bukrs eq i_zfarsoff_add_sap-bukrs and
*                         a~vkbur EQ i_zfarsoff_add_sap-zvkbur AND
*                         a~pkunwe EQ i_zfarsoff_add_sap-kunnr AND
*                         c~brsch IN so_brsch  AND
*                         b~kdgrp IN so_kdgrp AND
*                         c~kunnr EQ t_zfarsoff_add-kunnr.
    ENDIF.

    IF x_norm EQ 'X' AND x_shbv EQ 'X'.
* Select BSID for UMSKZ EQ SPACE
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                   a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                   a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                   c~name1
                   b~kdgrp b~vwerk b~vkbur b~kvgr3
*                   d~kunn2 "d~pernr
                   FROM bsid AS a
                             JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                               b~vkorg EQ a~bukrs
                             JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                           LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                     d~parvw EQ 'ZP'
                   INTO CORRESPONDING FIELDS OF TABLE t_bsid_add
                   FOR ALL ENTRIES IN i_zfarsoff_add_sap
                   WHERE a~bukrs EQ pa_bukrs AND
                         a~hkont IN ( SELECT saknr FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' ) AND
                         a~gjahr <= pa_date(4) AND
                         a~blart IN s_blart  AND
                         a~budat <= pa_date AND
                         a~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                         a~umskz EQ space   AND
                         c~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                         b~vkorg EQ pa_bukrs AND
                         b~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                         b~kdgrp IN so_kdgrp AND
                         b~kvgr3 IN so_kvgr3 AND
                         b~vtweg EQ '10' AND
                         b~vkbur EQ i_zfarsoff_add_sap-zvkbur AND
                         b~spart EQ '00' AND
                         c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
      IF va_project NE 'X'.
        SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                     a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                     a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                     c~name1
                     b~kdgrp b~vwerk b~vkbur b~kvgr3
*                     d~kunn2 "d~pernr
                     FROM bsid AS a
                               JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                     b~vkorg EQ a~bukrs
                               JOIN kna1 AS c ON c~kunnr EQ a~kunnr

*                            LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                              d~parvw EQ 'ZC'
*                                              AND d~vkorg EQ pa_bukrs
*                           LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                     d~parvw EQ 'ZP'
                     APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add
                     FOR ALL ENTRIES IN i_zfarsoff_add_sap
                     WHERE a~bukrs EQ pa_bukrs AND
                           a~hkont IN ( SELECT saknr FROM skat
                               WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' ) AND
                           ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                           a~budat >  pa_date AND
                           a~budat <= va_tanggal1 AND
                           a~zbd1t >=   0       AND
                           a~zbd1t <  30       AND
                           a~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                           a~umskz EQ space   AND
                           c~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                           b~vkorg EQ pa_bukrs AND
                           b~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                           b~kdgrp IN so_kdgrp AND
                           b~kvgr3 IN so_kvgr3 AND
                           b~vtweg EQ '10' AND
                           b~vkbur EQ i_zfarsoff_add_sap-zvkbur AND
                           b~spart EQ '00' AND
                           c~brsch IN so_brsch.
      ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ EQ SPACE
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
*             d~kunn2 "d~pernr
             FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                              b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                               d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_bsad_add
             FOR ALL ENTRIES IN i_zfarsoff_add_sap
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat <= pa_date AND
                   a~augdt >= l_date1 AND
                   a~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                   a~umskz EQ space   AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   b~vkbur EQ i_zfarsoff_add_sap-zvkbur AND
                   a~blart IN s_blart  AND
                   c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
      IF va_project NE 'X'.
        SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
               a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
               a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
               c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
*               d~kunn2 "d~pernr
               FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                               b~vkorg EQ pa_bukrs
                         JOIN kna1 AS c ON c~kunnr EQ a~kunnr

*                            LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                              d~parvw EQ 'ZC'
*                                              AND d~vkorg EQ pa_bukrs
*                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                               d~parvw EQ 'ZP'
               APPENDING CORRESPONDING FIELDS OF TABLE t_bsad_add
               FOR ALL ENTRIES IN i_zfarsoff_add_sap
               WHERE a~bukrs EQ pa_bukrs AND
                     a~hkont IN ( SELECT saknr FROM skat
                         WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                               ktopl EQ 'TSPC' ) AND
                     a~budat >  pa_date AND
                     a~budat <= va_tanggal1 AND
                     a~zbd1t >=   0       AND
                     a~zbd1t < 30        AND
                     a~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                     a~umskz EQ space   AND
                     b~vkorg EQ pa_bukrs AND
                     b~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                     b~vtweg EQ '10' AND
                     b~spart EQ '00' AND
                     b~vkbur EQ i_zfarsoff_add_sap-zvkbur AND
                     a~blart IN ('RV','ZA') AND
                     c~brsch IN so_brsch.
      ENDIF.
* Select BSID for UMSKZ in Selection screen
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                   a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                   a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                   c~name1
                   b~kdgrp b~vwerk b~vkbur b~kvgr3
*                   d~kunn2 "d~pernr
                   FROM bsid AS a
                             JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                   b~vkorg EQ a~bukrs
                             JOIN kna1 AS c ON c~kunnr EQ a~kunnr

*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                           LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                     d~parvw EQ 'ZP'
                   APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add
                   FOR ALL ENTRIES IN i_zfarsoff_add_sap
                   WHERE a~bukrs EQ pa_bukrs AND
                         a~hkont IN ( SELECT saknr FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' ) AND

                         a~gjahr <= pa_date(4) AND
                         a~blart IN s_blart  AND
                         a~budat <= pa_date AND
                         a~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                         a~umskz IN s_bschl  AND
                         c~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                         b~vkorg EQ pa_bukrs AND
                         b~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                         b~kdgrp IN so_kdgrp AND
                         b~kvgr3 IN so_kvgr3 AND
                         b~vtweg EQ '10' AND
                         b~vkbur EQ i_zfarsoff_add_sap-zvkbur AND
                         b~spart EQ '00' AND
                         c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
      IF va_project NE 'X'.
        SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                     a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                     a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                     c~name1
                     b~kdgrp b~vwerk b~vkbur b~kvgr3
*                     d~kunn2 "d~pernr
                     FROM bsid AS a
                               JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                     b~vkorg EQ a~bukrs
                               JOIN kna1 AS c ON c~kunnr EQ a~kunnr

*                            LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                              d~parvw EQ 'ZC'
*                                              AND d~vkorg EQ pa_bukrs
*                           LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                     d~parvw EQ 'ZP'
                     APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add
                     FOR ALL ENTRIES IN i_zfarsoff_add_sap
                     WHERE a~bukrs EQ pa_bukrs AND
                           a~hkont IN ( SELECT saknr FROM skat
                               WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' ) AND
                           ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                           a~budat >  pa_date AND
                           a~budat <= va_tanggal1 AND
                           a~zbd1t >=   0       AND
                           a~zbd1t <  30       AND
                           a~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                           a~umskz IN s_bschl  AND
                           c~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                           b~vkorg EQ pa_bukrs AND
                           b~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                           b~kdgrp IN so_kdgrp AND
                           b~kvgr3 IN so_kvgr3 AND
                           b~vtweg EQ '10' AND
                           b~vkbur EQ i_zfarsoff_add_sap-zvkbur AND
                           b~spart EQ '00' AND
                           c~brsch IN so_brsch.
      ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ in Selection screen
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
*             d~kunn2 "d~pernr
             FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                              b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                               d~parvw EQ 'ZP'
             APPENDING CORRESPONDING FIELDS OF TABLE t_bsad_add
             FOR ALL ENTRIES IN i_zfarsoff_add_sap
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat <= pa_date AND
                   a~augdt >= l_date1 AND
                   a~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                   a~umskz IN s_bschl  AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   b~vkbur EQ i_zfarsoff_add_sap-zvkbur AND
                   a~blart IN s_blart  AND
                   c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
      IF va_project NE 'X'.
        SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
               a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
               a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
               c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
*               d~kunn2 "d~pernr
               FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                               b~vkorg EQ pa_bukrs
                         JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                            LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                              d~parvw EQ 'ZC'
*                                              AND d~vkorg EQ pa_bukrs
*                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                               d~parvw EQ 'ZP'
               APPENDING CORRESPONDING FIELDS OF TABLE t_bsad_add
               FOR ALL ENTRIES IN i_zfarsoff_add_sap
               WHERE a~bukrs EQ pa_bukrs AND
                     a~hkont IN ( SELECT saknr FROM skat
                         WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                               ktopl EQ 'TSPC' ) AND
                     a~budat >  pa_date AND
                     a~budat <= va_tanggal1 AND
                     a~zbd1t >=   0       AND
                     a~zbd1t < 30        AND
                     a~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                     a~umskz IN s_bschl  AND
                     b~vkorg EQ pa_bukrs AND
                     b~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                     b~vtweg EQ '10' AND
                     b~spart EQ '00' AND
                     b~vkbur EQ i_zfarsoff_add_sap-zvkbur AND
                     a~blart IN ('RV','ZA') AND
                     c~brsch IN so_brsch.
      ENDIF.
    ENDIF.

    IF x_norm EQ 'X' AND x_shbv EQ space.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                   a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                   a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                   c~name1
                   b~kdgrp b~vwerk b~vkbur b~kvgr3
*                   d~kunn2 "d~pernr
                   FROM bsid AS a
                             JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                   b~vkorg EQ a~bukrs
                             JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                           LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                     d~parvw EQ 'ZP'
                   INTO CORRESPONDING FIELDS OF TABLE t_bsid_add
                   FOR ALL ENTRIES IN i_zfarsoff_add_sap
                   WHERE a~bukrs EQ pa_bukrs AND
                         a~hkont IN ( SELECT saknr FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' ) AND
                         a~gjahr <= pa_date(4) AND
                         a~blart IN s_blart  AND
                         a~budat <= pa_date AND
                         a~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                         a~umskz EQ space   AND
                         c~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                         b~vkorg EQ pa_bukrs AND
                         b~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                         b~kdgrp IN so_kdgrp AND
                         b~kvgr3 IN so_kvgr3 AND
                         b~vtweg EQ '10' AND
                         b~vkbur EQ i_zfarsoff_add_sap-zvkbur AND
                         b~spart EQ '00' AND
                         c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
      IF va_project NE 'X'.
        SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                     a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                     a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                     c~name1
                     b~kdgrp b~vwerk b~vkbur b~kvgr3
*                     d~kunn2 "d~pernr
                     FROM bsid AS a
                               JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                     b~vkorg EQ a~bukrs
                               JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                            LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                              d~parvw EQ 'ZC'
*                                              AND d~vkorg EQ pa_bukrs
*                           LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                     d~parvw EQ 'ZP'
                     APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add
                     FOR ALL ENTRIES IN i_zfarsoff_add_sap
                     WHERE a~bukrs EQ pa_bukrs AND
                           a~hkont IN ( SELECT saknr FROM skat
                               WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' ) AND
                           ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                           a~budat >  pa_date AND
                           a~budat <= va_tanggal1 AND
                           a~zbd1t >=   0       AND
                           a~zbd1t <  30       AND
                           a~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                           a~umskz EQ space   AND
                           c~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                           b~vkorg EQ pa_bukrs AND
                           b~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                           b~kdgrp IN so_kdgrp AND
                           b~kvgr3 IN so_kvgr3 AND
                           b~vtweg EQ '10' AND
                           b~vkbur EQ i_zfarsoff_add_sap-zvkbur AND
                           b~spart EQ '00' AND
                           c~brsch IN so_brsch.
      ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ EQ SPACE
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
*             d~kunn2 " d~pernr
             FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                              b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                               d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_bsad_add
             FOR ALL ENTRIES IN i_zfarsoff_add_sap
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat <= pa_date AND
                   a~augdt >= l_date1 AND
                   a~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                   a~umskz EQ space   AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   b~vkbur EQ i_zfarsoff_add_sap-zvkbur AND
                   a~blart IN s_blart  AND
                   c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
      IF va_project NE 'X'.
        SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
               a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
               a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
               c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
*               d~kunn2 "d~pernr
               FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                               b~vkorg EQ pa_bukrs
                         JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                            LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                              d~parvw EQ 'ZC'
*                                              AND d~vkorg EQ pa_bukrs
*                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                               d~parvw EQ 'ZP'
               APPENDING CORRESPONDING FIELDS OF TABLE t_bsad_add
               FOR ALL ENTRIES IN i_zfarsoff_add_sap
               WHERE a~bukrs EQ pa_bukrs AND
                     a~hkont IN ( SELECT saknr FROM skat
                         WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                               ktopl EQ 'TSPC' ) AND
                     a~budat >  pa_date AND
                     a~budat <= va_tanggal1 AND
                     a~zbd1t >=   0       AND
                     a~zbd1t < 30        AND
                     a~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                     a~umskz EQ space   AND
                     b~vkorg EQ pa_bukrs AND
                     b~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                     b~vtweg EQ '10' AND
                     b~spart EQ '00' AND
                     b~vkbur EQ i_zfarsoff_add_sap-zvkbur AND
                     a~blart IN ('RV','ZA') AND
                     c~brsch IN so_brsch.
      ENDIF.
    ENDIF.

    IF x_norm EQ space AND x_shbv EQ 'X'.
* Select BSID for UMSKZ in Selection screen
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                   a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                   a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                   c~name1
                   b~kdgrp b~vwerk b~vkbur b~kvgr3
*                   d~kunn2 "d~pernr
                   FROM bsid AS a
                             JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                   b~vkorg EQ a~bukrs
                             JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                           LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                     d~parvw EQ 'ZP'
                   INTO CORRESPONDING FIELDS OF TABLE t_bsid_add
                   FOR ALL ENTRIES IN i_zfarsoff_add_sap
                   WHERE a~bukrs EQ pa_bukrs AND
                         a~hkont IN ( SELECT saknr FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' ) AND
                         a~gjahr <= pa_date(4) AND
                         a~blart IN s_blart  AND
                         a~budat <= pa_date AND
                         a~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                         a~umskz IN s_bschl  AND
                         c~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                         b~vkorg EQ pa_bukrs AND
                         b~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                         b~kdgrp IN so_kdgrp AND
                         b~kvgr3 IN so_kvgr3 AND
                         b~vtweg EQ '10' AND
                         b~vkbur EQ i_zfarsoff_add_sap-zvkbur AND
                         b~spart EQ '00' AND
                         c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
      IF va_project NE 'X'.
        SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                     a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                     a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                     c~name1
                     b~kdgrp b~vwerk b~vkbur b~kvgr3
*                     d~kunn2 "d~pernr
                     FROM bsid AS a
                               JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                     b~vkorg EQ a~bukrs
                               JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                            LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                              d~parvw EQ 'ZC'
*                                              AND d~vkorg EQ pa_bukrs
*                           LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                     d~parvw EQ 'ZP'
                     APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add
                     FOR ALL ENTRIES IN i_zfarsoff_add_sap
                     WHERE a~bukrs EQ pa_bukrs AND
                           a~hkont IN ( SELECT saknr FROM skat
                               WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' ) AND
                           ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                           a~budat >  pa_date AND
                           a~budat <= va_tanggal1 AND
                           a~zbd1t >=   0       AND
                           a~zbd1t <  30       AND
                           a~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                           a~umskz IN s_bschl  AND
                           c~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                           b~vkorg EQ pa_bukrs AND
                           b~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                           b~kdgrp IN so_kdgrp AND
                           b~kvgr3 IN so_kvgr3 AND
                           b~vtweg EQ '10' AND
                           b~vkbur EQ i_zfarsoff_add_sap-zvkbur AND
                           b~spart EQ '00' AND
                           c~brsch IN so_brsch.
      ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ in Selection screen
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
*             d~kunn2 "d~pernr
             FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                              b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                               d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_bsad_add
             FOR ALL ENTRIES IN i_zfarsoff_add_sap
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat <= pa_date AND
                   a~augdt >= l_date1 AND
                   a~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                   a~umskz IN s_bschl  AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   b~vkbur EQ i_zfarsoff_add_sap-zvkbur AND
                   a~blart IN s_blart  AND
                   c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
      IF va_project NE 'X'.
        SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
               a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
               a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
               c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
*               d~kunn2 "d~pernr
               FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                               b~vkorg EQ pa_bukrs
                         JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                            LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                              d~parvw EQ 'ZC'
*                                              AND d~vkorg EQ pa_bukrs
*                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                               d~parvw EQ 'ZP'
               APPENDING CORRESPONDING FIELDS OF TABLE t_bsad_add
               FOR ALL ENTRIES IN i_zfarsoff_add_sap
               WHERE a~bukrs EQ pa_bukrs AND
                     a~hkont IN ( SELECT saknr FROM skat
                         WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                               ktopl EQ 'TSPC' ) AND
                     a~budat >  pa_date AND
                     a~budat <= va_tanggal1 AND
                     a~zbd1t >=   0       AND
                     a~zbd1t < 30        AND
                     a~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                     a~umskz IN s_bschl  AND
                     b~vkorg EQ pa_bukrs AND
                     b~kunnr EQ i_zfarsoff_add_sap-kunnr AND
                     b~vtweg EQ '10' AND
                     b~spart EQ '00' AND
                     b~vkbur EQ i_zfarsoff_add_sap-zvkbur AND
                     a~blart IN ('RV','ZA') AND
                     c~brsch IN so_brsch.
      ENDIF.
    ENDIF.

*    LOOP AT i_target WHERE vkbur IN r_vksap.
*      wa_itab-bukrs = '8020'.
*      wa_itab-vkbur = i_target-vkbur.
*      wa_itab-kdgrp = i_target-kdgrp.
*      wa_itab-kunnr = i_target-pkunwe.
*
*      wa_itab-brsch = i_target-brsch.
*      wa_itab-shkzg = 'S'.
*      wa_itab-zterm = i_target-ztop.
*      l_top = 30 - i_target-ztop.
*      IF l_top > 0.
*        wa_itab-value =  ( ( l_top / 30 ) * i_target-value ) * ( p_act / 100 ).
*      ELSE.
*        wa_itab-value =  0.
*      ENDIF.
*      wa_itab-vwerk = i_target-vkbur.
*      wa_itab-name1 = i_target-name1.
**     select single pernr into wa_itab-pernr from knvp
**            where kunnr = i_target-kunn2 and
**                  parvw = 'ZP'.
*
*      APPEND wa_itab TO  t_bsad_add.
*    ENDLOOP.

    REFRESH: i_target.
    CLEAR: i_target.
    SORT t_bsid_add BY kunnr pkunwe.
    SORT t_bsad_add BY kunnr.
    SORT t_zfarsoff_add BY kunnr.
    LOOP AT t_bsid_add INTO wa_itab.
      READ TABLE t_zfarsoff_add WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_budat  = t_zfarsoff_add-budat - 1.
        IF pa_date LT lv_budat.
          IF t_zfarsoff_add-zvkbur IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur.
            APPEND wa_itab TO i_itab_sap.
          ENDIF.
        ELSE.
          IF t_zfarsoff_add-zvkbur1 IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur1.
            APPEND wa_itab TO i_itab_sap.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.

***** Add delete BSAD jika tidak sesuai dengan kdgrp.
    DELETE t_bsad_add WHERE NOT ( kdgrp IN so_kdgrp ).
    DELETE t_bsad_add WHERE NOT ( kvgr3 IN so_kvgr3 ).
*****
    LOOP AT t_bsad_add INTO wa_itab.
      READ TABLE t_zfarsoff_add WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_budat  = t_zfarsoff_add-budat - 1.
        IF pa_date LT lv_budat.
          IF t_zfarsoff_add-zvkbur IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur.
            APPEND wa_itab TO i_itab_sap.
          ENDIF.
        ELSE.
          IF t_zfarsoff_add-zvkbur1 IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur1.
            APPEND wa_itab TO i_itab_sap.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_tambah_kunnr

*&---------------------------------------------------------------------*
*&      Form  f_hapus_kunnr_real
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hapus_kunnr_real .
  IF t_zfarsoff_dele[] IS NOT INITIAL.
    SORT i_itab_sap BY kunnr.
    SORT i_itab_leg BY kunnr.
    SORT t_zfarsoff_dele BY kunnr.
    LOOP AT i_itab_sap INTO wa_itab.
      READ TABLE t_zfarsoff_dele WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
*        IF t_zfarsoff_dele-zvkbur1 NOT IN so_gsber.
        DELETE i_itab_sap.
*        ENDIF.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.

    LOOP AT i_itab_leg INTO wa_itab.
      READ TABLE t_zfarsoff_dele WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
*        IF t_zfarsoff_dele-zvkbur1 NOT IN so_gsber.
        DELETE i_itab_leg.
*        ENDIF.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_hapus_kunnr_real

*&---------------------------------------------------------------------*
*&      Form  f_tambah_kunnr_real
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_tambah_kunnr_real .
  DATA: l_date  TYPE sy-datum,
        l_date1 TYPE sy-datum.

  IF t_zfarsoff_add[] IS NOT INITIAL.
    CONCATENATE pa_date(6) '01' INTO l_date1.

    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = pa_date
      IMPORTING
        last_day_of_month = l_date.

    l_date = l_date + 1.

    ra_date-sign   = 'I'.
    ra_date-option = 'BT'.
    ra_date-low    = l_date.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = ra_date-low
      IMPORTING
        last_day_of_month = ra_date-high.
    APPEND ra_date.

    IF x_norm EQ 'X' AND x_shbv EQ 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur
             d~kunn2
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
                          JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
                                            d~parvw EQ 'ZC'
                                            AND d~vkorg EQ pa_bukrs
*                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                         d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsid_add_real
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~blart IN ('DZ','DA','DR')                             AND
              a~budat IN ra_date                                      AND
              a~kunnr EQ t_zfarsoff_add-kunnr                         AND
              a~umskz EQ space                                        AND
              c~kunnr EQ t_zfarsoff_add-kunnr                         AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ t_zfarsoff_add-kunnr                         AND
              b~kdgrp IN so_kdgrp                                     AND
              b~kvgr3 IN so_kvgr3                                     AND
              b~vtweg EQ '10'                                         AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1                       AND
              b~spart EQ '00'                                         AND
              c~brsch IN so_brsch.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur
             d~kunn2 "pernr
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
                          JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
                                            d~parvw EQ 'ZC'
                                            AND d~vkorg EQ pa_bukrs
*                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                         d~parvw EQ 'ZP'
        APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add_real
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~blart IN ('DZ','DA','DR')                             AND
              a~budat IN ra_date                                      AND
              a~kunnr EQ t_zfarsoff_add-kunnr                         AND
              a~umskz IN s_bschl                                      AND
              c~kunnr EQ t_zfarsoff_add-kunnr                         AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ t_zfarsoff_add-kunnr                         AND
              b~kdgrp IN so_kdgrp                                     AND
              b~kvgr3 IN so_kvgr3                                     AND
              b~vtweg EQ '10'                                         AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1                       AND
              b~spart EQ '00'                                         AND
              c~brsch IN so_brsch.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur
             d~kunn2 "pernr
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
                          JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
                                            d~parvw EQ 'ZC'
                                            AND d~vkorg EQ pa_bukrs
*                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                         d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsad_add_real
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~budat IN ra_date                                      AND
              a~augdt >= l_date1                                      AND
              a~kunnr EQ t_zfarsoff_add-kunnr                         AND
              a~umskz EQ space                                        AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ t_zfarsoff_add-kunnr                         AND
              b~vtweg EQ '10'                                         AND
              b~spart EQ '00'                                         AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1                       AND
              a~blart IN ('DZ','DA','DR')                             AND
              c~brsch IN so_brsch.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur
             d~kunn2 "pernr
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
                          JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
                                            d~parvw EQ 'ZC'
                                            AND d~vkorg EQ pa_bukrs
*                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                         d~parvw EQ 'ZP'
        APPENDING CORRESPONDING FIELDS OF TABLE t_bsad_add_real
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~budat IN ra_date                                      AND
              a~augdt >= l_date1                                      AND
              a~kunnr EQ t_zfarsoff_add-kunnr                         AND
              a~umskz IN s_bschl                                      AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ t_zfarsoff_add-kunnr                         AND
              b~vtweg EQ '10'                                         AND
              b~spart EQ '00'                                         AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1                       AND
              a~blart IN ('DZ','DA','DR')                             AND
              c~brsch IN so_brsch.
    ENDIF.

    IF x_norm EQ 'X' AND x_shbv EQ space.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur
             d~kunn2 "pernr
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
                          JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
                                            d~parvw EQ 'ZC'
                                            AND d~vkorg EQ pa_bukrs
*                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                         d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsid_add_real
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~blart IN ('DZ','DA','DR')                             AND
              a~budat IN ra_date                                      AND
              a~kunnr EQ t_zfarsoff_add-kunnr                         AND
              a~umskz EQ space                                        AND
              c~kunnr EQ t_zfarsoff_add-kunnr                         AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ t_zfarsoff_add-kunnr                         AND
              b~kdgrp IN so_kdgrp                                     AND
              b~kvgr3 IN so_kvgr3                                     AND
              b~vtweg EQ '10'                                         AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1                       AND
              b~spart EQ '00'                                         AND
              c~brsch IN so_brsch.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur
             d~kunn2 "pernr
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
                          JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
                                            d~parvw EQ 'ZC'
                                            AND d~vkorg EQ pa_bukrs
*                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                         d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsad_add_real
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~budat IN ra_date                                      AND
              a~augdt >= l_date1                                      AND
              a~kunnr EQ t_zfarsoff_add-kunnr                         AND
              a~umskz EQ space                                        AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ t_zfarsoff_add-kunnr                         AND
              b~vtweg EQ '10'                                         AND
              b~spart EQ '00'                                         AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1                       AND
              a~blart IN ('DZ','DA','DR')                             AND
              c~brsch IN so_brsch.
    ENDIF.

    IF x_norm EQ space AND x_shbv EQ 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur
             d~kunn2 "pernr
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
                          JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
                                            d~parvw EQ 'ZC'
                                            AND d~vkorg EQ pa_bukrs
*                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                         d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsid_add_real
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~blart IN ('DZ','DA','DR')                             AND
              a~budat IN ra_date                                      AND
              a~kunnr EQ t_zfarsoff_add-kunnr                         AND
              a~umskz IN s_bschl                                      AND
              c~kunnr EQ t_zfarsoff_add-kunnr                         AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ t_zfarsoff_add-kunnr                         AND
              b~kdgrp IN so_kdgrp                                     AND
              b~kvgr3 IN so_kvgr3                                     AND
              b~vtweg EQ '10'                                         AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1                       AND
              b~spart EQ '00'                                         AND
              c~brsch IN so_brsch.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur
             d~kunn2 "pernr
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
                          JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
                                            d~parvw EQ 'ZC'
                                            AND d~vkorg EQ pa_bukrs
*                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                       d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsad_add_real
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~budat IN ra_date                                      AND
              a~augdt >= l_date1                                      AND
              a~kunnr EQ t_zfarsoff_add-kunnr                         AND
              a~umskz IN s_bschl                                      AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ t_zfarsoff_add-kunnr                         AND
              b~vtweg EQ '10'                                         AND
              b~spart EQ '00'                                         AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1                       AND
              a~blart IN ('DZ','DA','DR')                             AND
              c~brsch IN so_brsch.
    ENDIF.

    SORT t_bsid_add_real BY kunnr.
    SORT t_bsad_add_real BY kunnr.
    SORT t_zfarsoff_add BY kunnr.
    LOOP AT t_bsid_add_real INTO wa_itab.
      READ TABLE t_zfarsoff_add WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF pa_date LT t_zfarsoff_add-budat.
          IF t_zfarsoff_add-zvkbur IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur.
            APPEND wa_itab TO i_itab_bsid_real.
          ENDIF.
        ELSE.
          IF t_zfarsoff_add-zvkbur1 IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur1.
            APPEND wa_itab TO i_itab_bsid_real.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.

    LOOP AT t_bsad_add_real INTO wa_itab.
      READ TABLE t_zfarsoff_add WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF pa_date LT t_zfarsoff_add-budat.
          IF t_zfarsoff_add-zvkbur IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur.
            APPEND wa_itab TO i_itab_bsad_real.
          ENDIF.
        ELSE.
          IF t_zfarsoff_add-zvkbur1 IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur1.
            APPEND wa_itab TO i_itab_bsad_real.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_tambah_kunnr_real
*&---------------------------------------------------------------------*
*&      Form  f_get_data_SAP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data_sap .
  DATA: l_pernr LIKE pa0001-pernr,
        l_spmon LIKE ztgtsls-spmon,
        l_top   TYPE i.
  DATA: l_date1(8),
        l_date2(8),
        l_monat1(2) TYPE n,
        l_monat2(2) TYPE n.

  va_tanggal  = pa_date + pa_day.
  l_spmon = va_tanggal(6).
  l_monat1 = pa_date+4(2).
  l_monat2 = pa_date+4(2) + 1.
  CONCATENATE pa_date(4) l_monat1 '01' INTO l_date1.
  CONCATENATE pa_date(4) l_monat2 '01' INTO l_date2.

  CLEAR: wa_itab, i_itab, va_data.
  IF va_project = 'X'.
*    SELECT a~spmon  a~pkunwe a~kvgr2 d~kdgrp a~vkbur a~waerk a~value a~ztop
*                 c~name1 c~brsch                            "b~kunn2
*                 APPENDING CORRESPONDING FIELDS OF TABLE i_target
*                 FROM ztgtsls AS a
*                      JOIN kna1 AS c ON c~kunnr EQ a~pkunwe
**                      LEFT JOIN knvp AS b ON b~kunnr EQ a~pkunwe AND
**                                        b~parvw EQ 'ZC' AND
**                                        b~vkorg EQ pa_bukrs
*                      JOIN knvv AS d ON a~pkunwe EQ d~kunnr AND
*                                         d~vkorg EQ pa_bukrs
*                 WHERE a~spmon EQ l_spmon AND
*                       a~vkbur IN r_vksap AND
*                       a~pkunwe IN so_kunnr AND
*                         d~kdgrp IN so_kdgrp AND
*                       c~brsch IN so_brsch  AND
*                       c~kunnr IN so_kunnr.
*    IF sy-subrc NE 0.
*      va_data = 'X'.
*    ENDIF.
  ENDIF.
  IF x_norm EQ 'X' AND x_shbv EQ 'X'.
* Select BSID for UMSKZ EQ SPACE
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                 a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                 a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                 c~name1
                 b~kdgrp b~vwerk b~vkbur b~kvgr3
*                 d~kunn2
                 INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid
                 FROM bsid AS a
                           JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ a~bukrs
                           JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                   d~parvw EQ 'ZP'
                 WHERE a~bukrs EQ pa_bukrs AND
                       a~hkont IN ( SELECT saknr FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                 ktopl EQ 'TSPC' ) AND
                       a~gjahr <= pa_date(4) AND
                       a~blart IN s_blart  AND
*                       ( a~blart EQ 'RV' OR a~blart EQ 'ZA' OR
*                       a~blart EQ 'DR' OR a~blart EQ 'DA' OR
*                       a~blart EQ 'DZ' ) AND
                       a~budat <= pa_date AND
                       a~kunnr IN so_kunnr AND
                       a~umskz EQ space   AND
                       c~kunnr IN so_kunnr AND
                       b~vkorg EQ pa_bukrs AND
                       b~kunnr IN so_kunnr AND
                       b~kdgrp IN so_kdgrp AND
                       b~kvgr3 IN so_kvgr3 AND
                       b~vtweg EQ '10' AND
                       b~vkbur IN r_vksap AND
                       b~spart EQ '00' AND
                       c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur b~kvgr3
*             d~kunn2
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
             FROM bsid AS a
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                   d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=  0       AND
                   a~zbd1t <  30       AND
                   a~kunnr IN so_kunnr AND
                   a~umskz EQ space   AND
                   c~kunnr IN so_kunnr AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~kdgrp IN so_kdgrp AND
                   b~kvgr3 IN so_kvgr3 AND
                   b~vtweg EQ '10' AND
                   b~vkbur IN r_vksap AND
                   b~spart EQ '00' AND
                   c~brsch IN so_brsch.
    ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ EQ SPACE
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
           c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
*           d~kunn2 "d~pernr
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                            b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~budat <= pa_date AND
                 a~augdt >= l_date1 AND
                 a~kunnr IN so_kunnr AND
                 a~umskz EQ space   AND
                 b~vkorg EQ pa_bukrs AND
                 b~kunnr IN so_kunnr AND
                 b~vtweg EQ '10' AND
                 b~spart EQ '00' AND
                 b~vkbur IN r_vksap AND
                 a~blart IN s_blart  AND
*                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
*             d~kunn2 "d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
             FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                             d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t < 30        AND
                   a~kunnr IN so_kunnr AND
                   a~umskz EQ space   AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   b~vkbur IN r_vksap AND
                   a~blart IN ('RV','ZA') AND
                   c~brsch IN so_brsch.
    ENDIF.
* Select BSID for UMSKZ in Selection screen
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                 a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                 a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                 c~name1
                 b~kdgrp b~vwerk b~vkbur b~kvgr3
*                 d~kunn2 "d~pernr
                 APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
                 FROM bsid AS a
                           JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                 b~vkorg EQ a~bukrs
                           JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                   d~parvw EQ 'ZP'
                 WHERE a~bukrs EQ pa_bukrs AND
                       a~hkont IN ( SELECT saknr FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                 ktopl EQ 'TSPC' ) AND

                       a~gjahr <= pa_date(4) AND
                       a~blart IN s_blart  AND
*                       ( a~blart EQ 'RV' OR a~blart EQ 'ZA' OR
*                       a~blart EQ 'DR' OR a~blart EQ 'DA' OR
*                       a~blart EQ 'DZ' ) AND
                       a~budat <= pa_date AND
                       a~kunnr IN so_kunnr AND
                       a~umskz IN s_bschl  AND
                       c~kunnr IN so_kunnr AND
                       b~vkorg EQ pa_bukrs AND
                       b~kunnr IN so_kunnr AND
                       b~kdgrp IN so_kdgrp AND
                       b~kvgr3 IN so_kvgr3 AND
                       b~vtweg EQ '10' AND
                       b~vkbur IN r_vksap AND
                       b~spart EQ '00' AND
                       c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur b~kvgr3
*             d~kunn2 "d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
             FROM bsid AS a
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                   d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t <  30       AND
                   a~kunnr IN so_kunnr AND
                   a~umskz IN s_bschl  AND
                   c~kunnr IN so_kunnr AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~kdgrp IN so_kdgrp AND
                   b~kvgr3 IN so_kvgr3 AND
                   b~vtweg EQ '10' AND
                   b~vkbur IN r_vksap AND
                   b~spart EQ '00' AND
                   c~brsch IN so_brsch.
    ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ in Selection screen
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
           c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
*           d~kunn2 "d~pernr
           APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                            b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~budat <= pa_date AND
                 a~augdt >= l_date1 AND
                 a~kunnr IN so_kunnr AND
                 a~umskz IN s_bschl  AND
                 b~vkorg EQ pa_bukrs AND
                 b~kunnr IN so_kunnr AND
                 b~vtweg EQ '10' AND
                 b~spart EQ '00' AND
                 b~vkbur IN r_vksap AND
                 a~blart IN s_blart  AND
*                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
*             d~kunn2 "d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
             FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
* *                    LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                             d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t < 30        AND
                   a~kunnr IN so_kunnr AND
                   a~umskz IN s_bschl  AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   b~vkbur IN r_vksap AND
                   a~blart IN ('RV','ZA') AND
                   c~brsch IN so_brsch.
    ENDIF.
  ENDIF.

  IF x_norm EQ 'X' AND x_shbv EQ space.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                 a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                 a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                 c~name1
                 b~kdgrp b~vwerk b~vkbur b~kvgr3
*                 d~kunn2 "d~pernr
                 INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid
                 FROM bsid AS a
                           JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                 b~vkorg EQ a~bukrs
                           JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                   d~parvw EQ 'ZP'
                 WHERE a~bukrs EQ pa_bukrs AND
                       a~hkont IN ( SELECT saknr FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                 ktopl EQ 'TSPC' ) AND
                       a~gjahr <= pa_date(4) AND
                       a~blart IN s_blart  AND
*                       ( a~blart EQ 'RV' OR a~blart EQ 'ZA' OR
*                       a~blart EQ 'DR' OR a~blart EQ 'DA' OR
*                       a~blart EQ 'DZ' ) AND
                       a~budat <= pa_date AND
                       a~kunnr IN so_kunnr AND
                       a~umskz EQ space   AND
                       c~kunnr IN so_kunnr AND
                       b~vkorg EQ pa_bukrs AND
                       b~kunnr IN so_kunnr AND
                       b~kdgrp IN so_kdgrp AND
                       b~kvgr3 IN so_kvgr3 AND
                       b~vtweg EQ '10' AND
                       b~vkbur IN r_vksap AND
                       b~spart EQ '00' AND
                       c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur b~kvgr3
*             d~kunn2 "d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
             FROM bsid AS a
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                   d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t <  30       AND
                   a~kunnr IN so_kunnr AND
                   a~umskz EQ space   AND
                   c~kunnr IN so_kunnr AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~kdgrp IN so_kdgrp AND
                   b~kvgr3 IN so_kvgr3 AND
                   b~vtweg EQ '10' AND
                   b~vkbur IN r_vksap AND
                   b~spart EQ '00' AND
                   c~brsch IN so_brsch.
    ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ EQ SPACE
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
           c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
*           d~kunn2 "d~pernr
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                            b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~budat <= pa_date AND
                 a~augdt >= l_date1 AND
                 a~kunnr IN so_kunnr AND
                 a~umskz EQ space   AND
                 b~vkorg EQ pa_bukrs AND
                 b~kunnr IN so_kunnr AND
                 b~vtweg EQ '10' AND
                 b~spart EQ '00' AND
                 b~vkbur IN r_vksap AND
                 a~blart IN s_blart  AND
*                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
    IF va_project NE 'X'.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
*             d~kunn2 "d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
             FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                             d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t < 30        AND
                   a~kunnr IN so_kunnr AND
                   a~umskz EQ space   AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   b~vkbur IN r_vksap AND
                   a~blart IN ('RV','ZA') AND
                   c~brsch IN so_brsch.
    ENDIF.
  ENDIF.

  IF x_norm EQ space AND x_shbv EQ 'X'.
* Select BSID for UMSKZ in Selection screen
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                 a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                 a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                 c~name1
                 b~kdgrp b~vwerk b~vkbur b~kvgr3
*                 d~kunn2 "d~pernr
                 INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid
                 FROM bsid AS a
                           JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                 b~vkorg EQ a~bukrs
                           JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                   d~parvw EQ 'ZP'
                 WHERE a~bukrs EQ pa_bukrs AND
                       a~hkont IN ( SELECT saknr FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                 ktopl EQ 'TSPC' ) AND
                       a~gjahr <= pa_date(4) AND
                       a~blart IN s_blart  AND
*                       ( a~blart EQ 'RV' OR a~blart EQ 'ZA' OR
*                       a~blart EQ 'DR' OR a~blart EQ 'DA' OR
*                       a~blart EQ 'DZ' ) AND
                       a~budat <= pa_date AND
                       a~kunnr IN so_kunnr AND
                       a~umskz IN s_bschl  AND
                       c~kunnr IN so_kunnr AND
                       b~vkorg EQ pa_bukrs AND
                       b~kunnr IN so_kunnr AND
                       b~kdgrp IN so_kdgrp AND
                       b~kvgr3 IN so_kvgr3 AND
                       b~vtweg EQ '10' AND
                       b~vkbur IN r_vksap AND
                       b~spart EQ '00' AND
                       c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                   a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                   a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                   c~name1
                   b~kdgrp b~vwerk b~vkbur b~kvgr3
*                   d~kunn2 "d~pernr
                   APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
                   FROM bsid AS a
                             JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                   b~vkorg EQ a~bukrs
                             JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                   d~parvw EQ 'ZP'
                   WHERE a~bukrs EQ pa_bukrs AND
                         a~hkont IN ( SELECT saknr FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' ) AND
                         ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                         a~budat >  pa_date AND
                         a~budat <= va_tanggal1 AND
                         a~zbd1t >=   0       AND
                         a~zbd1t <  30       AND
                         a~kunnr IN so_kunnr AND
                         a~umskz IN s_bschl  AND
                         c~kunnr IN so_kunnr AND
                         b~vkorg EQ pa_bukrs AND
                         b~kunnr IN so_kunnr AND
                         b~kdgrp IN so_kdgrp AND
                         b~kvgr3 IN so_kvgr3 AND
                         b~vtweg EQ '10' AND
                         b~vkbur IN r_vksap AND
                         b~spart EQ '00' AND
                         c~brsch IN so_brsch.
    ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ in Selection screen
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
           c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
*           d~kunn2 "d~pernr
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                            b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~budat <= pa_date AND
                 a~augdt >= l_date1 AND
                 a~kunnr IN so_kunnr AND
                 a~umskz IN s_bschl  AND
                 b~vkorg EQ pa_bukrs AND
                 b~kunnr IN so_kunnr AND
                 b~vtweg EQ '10' AND
                 b~spart EQ '00' AND
                 b~vkbur IN r_vksap AND
                 a~blart IN s_blart  AND
*                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
*             d~kunn2 "d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
             FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                             d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t < 30        AND
                   a~kunnr IN so_kunnr AND
                   a~umskz IN s_bschl  AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   b~vkbur IN r_vksap AND
                   a~blart IN ('RV','ZA') AND
                   c~brsch IN so_brsch.
    ENDIF.
  ENDIF.


  DELETE i_itab_bsad WHERE NOT ( kdgrp IN so_kdgrp ).
  DELETE i_itab_bsid WHERE NOT ( kdgrp IN so_kdgrp ).

  DELETE i_itab_bsad WHERE NOT ( kvgr3 IN so_kvgr3 ).
  DELETE i_itab_bsid WHERE NOT ( kvgr3 IN so_kvgr3 ).

  DELETE i_itab_bsad WHERE  vwerk EQ '0200'.
  DELETE i_itab_bsid WHERE  vwerk EQ '0200'.

  DELETE i_itab_bsad WHERE  vwerk EQ space.
  DELETE i_itab_bsid WHERE  vwerk EQ space.

*  LOOP AT i_target WHERE vkbur IN r_vksap.
*    wa_itab-bukrs = '8020'.
*    wa_itab-vkbur = i_target-vkbur.
*    wa_itab-kdgrp = i_target-kdgrp.
*    wa_itab-kunnr = i_target-pkunwe.
*    wa_itab-brsch = i_target-brsch.
*
*    wa_itab-shkzg = 'S'.
*    wa_itab-zfbdt = '00000000'.
*    wa_itab-zterm = i_target-ztop.
*    l_top = 30 - i_target-ztop.
*    IF l_top > 0.
*      wa_itab-value =  ( ( l_top / 30 ) * i_target-value ) * ( p_act / 100 ).
*    ELSE.
*      wa_itab-value =  0.
*    ENDIF.
*    wa_itab-vwerk = i_target-vkbur.
*    wa_itab-name1 = i_target-name1.
*    wa_itab-kunn2 = i_target-kunn2.
*    APPEND wa_itab TO  i_itab_bsad.
*  ENDLOOP.

ENDFORM.                    " f_get_data_SAP
*&---------------------------------------------------------------------*
*&      Form  f_get_data_SAP_OPDR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data_sap_opdr .
  DATA: l_pernr LIKE pa0001-pernr,
        l_spmon LIKE ztgtsls-spmon,
        l_top   TYPE i.
  DATA: l_date1(8),
        l_date2(8),
        l_monat1(2) TYPE n,
        l_monat2(2) TYPE n.

  va_tanggal  = pa_date + pa_day.
  l_spmon = va_tanggal(6).
  l_monat1 = pa_date+4(2).
  l_monat2 = pa_date+4(2) + 1.
  CONCATENATE pa_date(4) l_monat1 '01' INTO l_date1.
  CONCATENATE pa_date(4) l_monat2 '01' INTO l_date2.

  CLEAR: wa_itab, i_itab, va_data.
  IF va_project = 'X'.
*    SELECT a~spmon  a~pkunwe a~kvgr2 d~kdgrp a~vkbur a~waerk a~value a~ztop
*                 c~name1 c~brsch                            "b~kunn2
*                 APPENDING CORRESPONDING FIELDS OF TABLE i_target
*                 FROM ztgtsls AS a
*                      JOIN kna1 AS c ON c~kunnr EQ a~pkunwe
**                      LEFT JOIN knvp AS b ON b~kunnr EQ a~pkunwe AND
**                                        b~parvw EQ 'ZC' AND
**                                        b~vkorg EQ pa_bukrs
*                      JOIN knvv AS d ON a~pkunwe EQ d~kunnr AND
*                                         d~vkorg EQ pa_bukrs
*                 WHERE a~spmon EQ l_spmon AND
*                       a~vkbur IN r_vksap AND
*                       a~pkunwe IN so_kunnr AND
*                         d~kdgrp IN so_kdgrp AND
*                       c~brsch IN so_brsch  AND
*                       c~kunnr IN so_kunnr.
*    IF sy-subrc NE 0.
*      va_data = 'X'.
*    ENDIF.
  ENDIF.
  IF x_norm EQ 'X' AND x_shbv EQ 'X'.
* Select BSID for UMSKZ EQ SPACE
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                 a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                 a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                 c~name1
                 b~kdgrp b~vwerk b~kvgr3
                 p~vkbur
*                 d~kunn2
                 INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid
                 FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                                  p~posnr = '000010'
                           JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ a~bukrs
                           JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                   d~parvw EQ 'ZP'
                 WHERE a~bukrs EQ pa_bukrs AND
                       a~hkont IN ( SELECT saknr FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                 ktopl EQ 'TSPC' ) AND
                       a~gjahr <= pa_date(4) AND
                       a~blart IN s_blart  AND
*                       ( a~blart EQ 'RV' OR a~blart EQ 'ZA' OR
*                       a~blart EQ 'DR' OR a~blart EQ 'DA' OR
*                       a~blart EQ 'DZ' ) AND
                       a~budat <= pa_date AND
                       a~kunnr IN so_kunnr AND
                       a~umskz EQ space   AND
                       c~kunnr IN so_kunnr AND
                       b~vkorg EQ pa_bukrs AND
                       b~kunnr IN so_kunnr AND
                       b~kdgrp IN so_kdgrp AND
                       b~kvgr3 IN so_kvgr3 AND
                       b~vtweg EQ '10' AND
                       p~vkbur IN r_vksap AND
                       b~spart EQ '00' AND
                       c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1
             b~kdgrp b~vwerk b~kvgr3
             p~vkbur
*             d~kunn2
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
             FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                              p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                   d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=  0       AND
                   a~zbd1t <  30       AND
                   a~kunnr IN so_kunnr AND
                   a~umskz EQ space   AND
                   c~kunnr IN so_kunnr AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~kdgrp IN so_kdgrp AND
                   b~kvgr3 IN so_kvgr3 AND
                   b~vtweg EQ '10' AND
                   p~vkbur IN r_vksap AND
                   b~spart EQ '00' AND
                   c~brsch IN so_brsch.
    ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ EQ SPACE
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
           c~name1 b~kdgrp b~vwerk b~kvgr3
           p~vkbur
*           d~kunn2 "d~pernr
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                            p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~budat <= pa_date AND
                 a~augdt >= l_date1 AND
                 a~kunnr IN so_kunnr AND
                 a~umskz EQ space   AND
                 b~vkorg EQ pa_bukrs AND
                 b~kunnr IN so_kunnr AND
                 b~vtweg EQ '10' AND
                 b~spart EQ '00' AND
                 p~vkbur IN r_vksap AND
                 a~blart IN s_blart  AND
*                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~kvgr3
             p~vkbur
*             d~kunn2 "d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
             FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                              p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                             d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t < 30        AND
                   a~kunnr IN so_kunnr AND
                   a~umskz EQ space   AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   p~vkbur IN r_vksap AND
                   a~blart IN ('RV','ZA') AND
                   c~brsch IN so_brsch.
    ENDIF.
* Select BSID for UMSKZ in Selection screen
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                 a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                 a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                 c~name1
                 b~kdgrp b~vwerk b~kvgr3
                 p~vkbur
*                 d~kunn2 "d~pernr
                 APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
                 FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                                  p~posnr = '000010'
                           JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ a~bukrs
                           JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                   d~parvw EQ 'ZP'
                 WHERE a~bukrs EQ pa_bukrs AND
                       a~hkont IN ( SELECT saknr FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                 ktopl EQ 'TSPC' ) AND

                       a~gjahr <= pa_date(4) AND
                       a~blart IN s_blart  AND
*                       ( a~blart EQ 'RV' OR a~blart EQ 'ZA' OR
*                       a~blart EQ 'DR' OR a~blart EQ 'DA' OR
*                       a~blart EQ 'DZ' ) AND
                       a~budat <= pa_date AND
                       a~kunnr IN so_kunnr AND
                       a~umskz IN s_bschl  AND
                       c~kunnr IN so_kunnr AND
                       b~vkorg EQ pa_bukrs AND
                       b~kunnr IN so_kunnr AND
                       b~kdgrp IN so_kdgrp AND
                       b~kvgr3 IN so_kvgr3 AND
                       b~vtweg EQ '10' AND
                       p~vkbur IN r_vksap AND
                       b~spart EQ '00' AND
                       c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1
             b~kdgrp b~vwerk b~kvgr3
             p~vkbur
*             d~kunn2 "d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
             FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                              p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                   d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t <  30       AND
                   a~kunnr IN so_kunnr AND
                   a~umskz IN s_bschl  AND
                   c~kunnr IN so_kunnr AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~kdgrp IN so_kdgrp AND
                   b~kvgr3 IN so_kvgr3 AND
                   b~vtweg EQ '10' AND
                   p~vkbur IN r_vksap AND
                   b~spart EQ '00' AND
                   c~brsch IN so_brsch.
    ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ in Selection screen
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
           c~name1 b~kdgrp b~vwerk b~kvgr3
           p~vkbur
*           d~kunn2 "d~pernr
           APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                            p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~budat <= pa_date AND
                 a~augdt >= l_date1 AND
                 a~kunnr IN so_kunnr AND
                 a~umskz IN s_bschl  AND
                 b~vkorg EQ pa_bukrs AND
                 b~kunnr IN so_kunnr AND
                 b~vtweg EQ '10' AND
                 b~spart EQ '00' AND
                 p~vkbur IN r_vksap AND
                 a~blart IN s_blart  AND
*                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~kvgr3
             p~vkbur
*             d~kunn2 "d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
             FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                              p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
* *                    LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                             d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t < 30        AND
                   a~kunnr IN so_kunnr AND
                   a~umskz IN s_bschl  AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   p~vkbur IN r_vksap AND
                   a~blart IN ('RV','ZA') AND
                   c~brsch IN so_brsch.
    ENDIF.
  ENDIF.

  IF x_norm EQ 'X' AND x_shbv EQ space.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                 a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                 a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                 c~name1
                 b~kdgrp b~vwerk b~kvgr3
                 p~vkbur
*                 d~kunn2 "d~pernr
                 INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid
                 FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                                  p~posnr = '000010'
                           JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ a~bukrs
                           JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                   d~parvw EQ 'ZP'
                 WHERE a~bukrs EQ pa_bukrs AND
                       a~hkont IN ( SELECT saknr FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                 ktopl EQ 'TSPC' ) AND
                       a~gjahr <= pa_date(4) AND
                       a~blart IN s_blart  AND
*                       ( a~blart EQ 'RV' OR a~blart EQ 'ZA' OR
*                       a~blart EQ 'DR' OR a~blart EQ 'DA' OR
*                       a~blart EQ 'DZ' ) AND
                       a~budat <= pa_date AND
                       a~kunnr IN so_kunnr AND
                       a~umskz EQ space   AND
                       c~kunnr IN so_kunnr AND
                       b~vkorg EQ pa_bukrs AND
                       b~kunnr IN so_kunnr AND
                       b~kdgrp IN so_kdgrp AND
                       b~kvgr3 IN so_kvgr3 AND
                       b~vtweg EQ '10' AND
                       p~vkbur IN r_vksap AND
                       b~spart EQ '00' AND
                       c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1
             b~kdgrp b~vwerk b~kvgr3
             p~vkbur
*             d~kunn2 "d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
             FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                              p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                   d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t <  30       AND
                   a~kunnr IN so_kunnr AND
                   a~umskz EQ space   AND
                   c~kunnr IN so_kunnr AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~kdgrp IN so_kdgrp AND
                   b~kvgr3 IN so_kvgr3 AND
                   b~vtweg EQ '10' AND
                   p~vkbur IN r_vksap AND
                   b~spart EQ '00' AND
                   c~brsch IN so_brsch.
    ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ EQ SPACE
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
           c~name1 b~kdgrp b~vwerk b~kvgr3
           p~vkbur
*           d~kunn2 "d~pernr
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                            p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~budat <= pa_date AND
                 a~augdt >= l_date1 AND
                 a~kunnr IN so_kunnr AND
                 a~umskz EQ space   AND
                 b~vkorg EQ pa_bukrs AND
                 b~kunnr IN so_kunnr AND
                 b~vtweg EQ '10' AND
                 b~spart EQ '00' AND
                 p~vkbur IN r_vksap AND
                 a~blart IN s_blart  AND
*                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
    IF va_project NE 'X'.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~kvgr3
             p~vkbur
*             d~kunn2 "d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
             FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                              p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                             d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t < 30        AND
                   a~kunnr IN so_kunnr AND
                   a~umskz EQ space   AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   p~vkbur IN r_vksap AND
                   a~blart IN ('RV','ZA') AND
                   c~brsch IN so_brsch.
    ENDIF.
  ENDIF.

  IF x_norm EQ space AND x_shbv EQ 'X'.
* Select BSID for UMSKZ in Selection screen
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                 a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                 a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                 c~name1
                 b~kdgrp b~vwerk b~kvgr3
                 p~vkbur
*                 d~kunn2 "d~pernr
                 INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid
                 FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                                  p~posnr = '000010'
                           JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ a~bukrs
                           JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                   d~parvw EQ 'ZP'
                 WHERE a~bukrs EQ pa_bukrs AND
                       a~hkont IN ( SELECT saknr FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                 ktopl EQ 'TSPC' ) AND
                       a~gjahr <= pa_date(4) AND
                       a~blart IN s_blart  AND
*                       ( a~blart EQ 'RV' OR a~blart EQ 'ZA' OR
*                       a~blart EQ 'DR' OR a~blart EQ 'DA' OR
*                       a~blart EQ 'DZ' ) AND
                       a~budat <= pa_date AND
                       a~kunnr IN so_kunnr AND
                       a~umskz IN s_bschl  AND
                       c~kunnr IN so_kunnr AND
                       b~vkorg EQ pa_bukrs AND
                       b~kunnr IN so_kunnr AND
                       b~kdgrp IN so_kdgrp AND
                       b~kvgr3 IN so_kvgr3 AND
                       b~vtweg EQ '10' AND
                       p~vkbur IN r_vksap AND
                       b~spart EQ '00' AND
                       c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                   a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                   a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                   c~name1
                   b~kdgrp b~vwerk b~vkbur b~kvgr3
                   p~vkbur
*                   d~kunn2 "d~pernr
                   APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
                   FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                               p~posnr = '000010'
                             JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                               b~vkorg EQ a~bukrs
                             JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                                   d~parvw EQ 'ZP'
                   WHERE a~bukrs EQ pa_bukrs AND
                         a~hkont IN ( SELECT saknr FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' ) AND
                         ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                         a~budat >  pa_date AND
                         a~budat <= va_tanggal1 AND
                         a~zbd1t >=   0       AND
                         a~zbd1t <  30       AND
                         a~kunnr IN so_kunnr AND
                         a~umskz IN s_bschl  AND
                         c~kunnr IN so_kunnr AND
                         b~vkorg EQ pa_bukrs AND
                         b~kunnr IN so_kunnr AND
                         b~kdgrp IN so_kdgrp AND
                         b~kvgr3 IN so_kvgr3 AND
                         b~vtweg EQ '10' AND
                         p~vkbur IN r_vksap AND
                         b~spart EQ '00' AND
                         c~brsch IN so_brsch.
    ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ in Selection screen
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
           c~name1 b~kdgrp b~vwerk b~kvgr3
           p~vkbur
*           d~kunn2 "d~pernr
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                            p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~budat <= pa_date AND
                 a~augdt >= l_date1 AND
                 a~kunnr IN so_kunnr AND
                 a~umskz IN s_bschl  AND
                 b~vkorg EQ pa_bukrs AND
                 b~kunnr IN so_kunnr AND
                 b~vtweg EQ '10' AND
                 b~spart EQ '00' AND
                 p~vkbur IN r_vksap AND
                 a~blart IN s_blart  AND
*                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
             p~vkbur
*             d~kunn2 "d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
             FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                              p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
*                                             d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t < 30        AND
                   a~kunnr IN so_kunnr AND
                   a~umskz IN s_bschl  AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   p~vkbur IN r_vksap AND
                   a~blart IN ('RV','ZA') AND
                   c~brsch IN so_brsch.
    ENDIF.
  ENDIF.


  DELETE i_itab_bsad WHERE NOT ( kdgrp IN so_kdgrp ).
  DELETE i_itab_bsid WHERE NOT ( kdgrp IN so_kdgrp ).

  DELETE i_itab_bsad WHERE NOT ( kvgr3 IN so_kvgr3 ).
  DELETE i_itab_bsid WHERE NOT ( kvgr3 IN so_kvgr3 ).

  DELETE i_itab_bsad WHERE  vwerk EQ '0200'.
  DELETE i_itab_bsid WHERE  vwerk EQ '0200'.

  DELETE i_itab_bsad WHERE  vwerk EQ space.
  DELETE i_itab_bsid WHERE  vwerk EQ space.

*  LOOP AT i_target WHERE vkbur IN r_vksap.
*    wa_itab-bukrs = '8020'.
*    wa_itab-vkbur = i_target-vkbur.
*    wa_itab-kdgrp = i_target-kdgrp.
*    wa_itab-kunnr = i_target-pkunwe.
*    wa_itab-brsch = i_target-brsch.
*
*    wa_itab-shkzg = 'S'.
*    wa_itab-zfbdt = '00000000'.
*    wa_itab-zterm = i_target-ztop.
*    l_top = 30 - i_target-ztop.
*    IF l_top > 0.
*      wa_itab-value =  ( ( l_top / 30 ) * i_target-value ) * ( p_act / 100 ).
*    ELSE.
*      wa_itab-value =  0.
*    ENDIF.
*    wa_itab-vwerk = i_target-vkbur.
*    wa_itab-name1 = i_target-name1.
*    wa_itab-kunn2 = i_target-kunn2.
*    APPEND wa_itab TO  i_itab_bsad.
*  ENDLOOP.

ENDFORM.                    " f_get_data_SAP_OPDR
*&---------------------------------------------------------------------*
*&      Form  f_get_data_Leg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data_leg .

  DATA: l_pernr LIKE pa0001-pernr,
        l_spmon LIKE ztgtsls-spmon,
        l_top   TYPE i.
  DATA: l_date1(8),
        l_date2(8),
        l_monat1(2) TYPE n,
        l_monat2(2) TYPE n.

  va_tanggal  = pa_date + pa_day.
  l_spmon = va_tanggal(6).
  l_monat1 = pa_date+4(2).
  l_monat2 = pa_date+4(2) + 1.
  CONCATENATE pa_date(4) l_monat1 '01' INTO l_date1.
  CONCATENATE pa_date(4) l_monat2 '01' INTO l_date2.

  CLEAR: wa_itab, i_itab, va_data.
  IF va_project = 'X'.
*    SELECT a~spmon  a~pkunwe a~kvgr2 d~kdgrp a~vkbur a~waerk a~value a~ztop
*                 c~name1 c~brsch                            "b~kunn2
*                 APPENDING CORRESPONDING FIELDS OF TABLE i_target
*                 FROM ztgtsls AS a
*                      JOIN kna1 AS c ON c~kunnr EQ a~pkunwe
**                      left join knvp as b on b~kunnr eq a~pkunwe and
**                                        b~parvw eq 'ZC' and
**                                        b~vkorg eq pa_bukrs
*                      JOIN knvv AS d ON a~pkunwe EQ d~kunnr AND
*                                         d~vkorg EQ pa_bukrs
*                 WHERE a~spmon EQ l_spmon AND
*                       a~vkbur IN r_vkleg AND
*                       d~kdgrp IN so_kdgrp AND
*                       a~pkunwe IN so_kunnr AND
*                       c~brsch IN so_brsch  AND
*                       c~kunnr IN so_kunnr.
*    IF sy-subrc NE 0.
*      va_data = 'X'.
*    ENDIF.
  ENDIF.
  IF x_norm EQ 'X' AND x_shbv EQ 'X'.
* Select BSID for UMSKZ EQ SPACE
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                 a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                 a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                 c~name1
                 b~kdgrp b~vwerk b~vkbur b~kvgr3
                 d~pernr                                    "d~kunn2
                 INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid
                 FROM bsid AS a
                           JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ a~bukrs
                           JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                   d~parvw EQ 'ZP'
                 WHERE a~bukrs EQ pa_bukrs AND
                       a~hkont IN ( SELECT saknr FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                 ktopl EQ 'TSPC' ) AND
                       a~gjahr <= pa_date(4) AND
                       a~blart IN s_blart  AND
*                       ( a~blart EQ 'RV' OR a~blart EQ 'ZA' OR
*                       a~blart EQ 'DR' OR a~blart EQ 'DA' OR
*                       a~blart EQ 'DZ' ) AND
                       a~budat <= pa_date AND
                       a~kunnr IN so_kunnr AND
                       a~umskz EQ space   AND
                       c~kunnr IN so_kunnr AND
                       b~vkorg EQ pa_bukrs AND
                       b~kunnr IN so_kunnr AND
                       b~kdgrp IN so_kdgrp AND
                       b~kvgr3 IN so_kvgr3 AND
                       b~vtweg EQ '10' AND
                       b~vkbur IN r_vkleg AND
                       b~spart EQ '00' AND
                       c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr                                        "d~kunn2
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
             FROM bsid AS a
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr

*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t <  30       AND
                   a~kunnr IN so_kunnr AND
                   a~umskz EQ space   AND
                   c~kunnr IN so_kunnr AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~kdgrp IN so_kdgrp AND
                   b~kvgr3 IN so_kvgr3 AND
                   b~vtweg EQ '10' AND
                   b~vkbur IN r_vkleg AND
                   b~spart EQ '00' AND
                   c~brsch IN so_brsch.
    ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ EQ SPACE
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
           c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
           d~pernr
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                            b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~budat <= pa_date AND
                 a~augdt >= l_date1 AND
                 a~kunnr IN so_kunnr AND
                 a~umskz EQ space   AND
                 b~vkorg EQ pa_bukrs AND
                 b~kunnr IN so_kunnr AND
                 b~vtweg EQ '10' AND
                 b~spart EQ '00' AND
                 b~vkbur IN r_vkleg AND
                 a~blart IN s_blart  AND
*                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
             FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t < 30        AND
                   a~kunnr IN so_kunnr AND
                   a~umskz EQ space   AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   b~vkbur IN r_vkleg AND
                   a~blart IN ('RV','ZA') AND
                   c~brsch IN so_brsch.
    ENDIF.
* Select BSID for UMSKZ in Selection screen
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                 a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                 a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                 c~name1
                 b~kdgrp b~vwerk b~vkbur b~kvgr3
                 d~pernr
                 APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
                 FROM bsid AS a
                           JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                 b~vkorg EQ a~bukrs
                           JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                   d~parvw EQ 'ZP'
                 WHERE a~bukrs EQ pa_bukrs AND
                       a~hkont IN ( SELECT saknr FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                 ktopl EQ 'TSPC' ) AND

                       a~gjahr <= pa_date(4) AND
                       a~blart IN s_blart  AND
*                       ( a~blart EQ 'RV' OR a~blart EQ 'ZA' OR
*                       a~blart EQ 'DR' OR a~blart EQ 'DA' OR
*                       a~blart EQ 'DZ' ) AND
                       a~budat <= pa_date AND
                       a~kunnr IN so_kunnr AND
                       a~umskz IN s_bschl  AND
                       c~kunnr IN so_kunnr AND
                       b~vkorg EQ pa_bukrs AND
                       b~kunnr IN so_kunnr AND
                       b~kdgrp IN so_kdgrp AND
                       b~kvgr3 IN so_kvgr3 AND
                       b~vtweg EQ '10' AND
                       b~vkbur IN r_vkleg AND
                       b~spart EQ '00' AND
                       c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
             FROM bsid AS a
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t <  30       AND
                   a~kunnr IN so_kunnr AND
                   a~umskz IN s_bschl  AND
                   c~kunnr IN so_kunnr AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~kdgrp IN so_kdgrp AND
                   b~kvgr3 IN so_kvgr3 AND
                   b~vtweg EQ '10' AND
                   b~vkbur IN r_vkleg AND
                   b~spart EQ '00' AND
                   c~brsch IN so_brsch.
    ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ in Selection screen
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
           c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
           d~pernr
           APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                            b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~budat <= pa_date AND
                 a~augdt >= l_date1 AND
                 a~kunnr IN so_kunnr AND
                 a~umskz IN s_bschl  AND
                 b~vkorg EQ pa_bukrs AND
                 b~kunnr IN so_kunnr AND
                 b~vtweg EQ '10' AND
                 b~spart EQ '00' AND
                 b~vkbur IN r_vkleg AND
                 a~blart IN s_blart  AND
*                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
             FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t < 30        AND
                   a~kunnr IN so_kunnr AND
                   a~umskz IN s_bschl  AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   b~vkbur IN r_vkleg AND
                   a~blart IN ('RV','ZA') AND
                   c~brsch IN so_brsch.
    ENDIF.
  ENDIF.

  IF x_norm EQ 'X' AND x_shbv EQ space.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                 a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                 a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                 c~name1
                 b~kdgrp b~vwerk b~vkbur b~kvgr3
                 d~pernr
                 INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid
                 FROM bsid AS a
                           JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                 b~vkorg EQ a~bukrs
                           JOIN kna1 AS c ON c~kunnr EQ a~kunnr

*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                   d~parvw EQ 'ZP'
                 WHERE a~bukrs EQ pa_bukrs AND
                       a~hkont IN ( SELECT saknr FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                 ktopl EQ 'TSPC' ) AND
                       a~gjahr <= pa_date(4) AND
                       a~blart IN s_blart  AND
*                       ( a~blart EQ 'RV' OR a~blart EQ 'ZA' OR
*                       a~blart EQ 'DR' OR a~blart EQ 'DA' OR
*                       a~blart EQ 'DZ' ) AND
                       a~budat <= pa_date AND
                       a~kunnr IN so_kunnr AND
                       a~umskz EQ space   AND
                       c~kunnr IN so_kunnr AND
                       b~vkorg EQ pa_bukrs AND
                       b~kunnr IN so_kunnr AND
                       b~kdgrp IN so_kdgrp AND
                       b~kvgr3 IN so_kvgr3 AND
                       b~vtweg EQ '10' AND
                       b~vkbur IN r_vkleg AND
                       b~spart EQ '00' AND
                       c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
             FROM bsid AS a
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t <  30       AND
                   a~kunnr IN so_kunnr AND
                   a~umskz EQ space   AND
                   c~kunnr IN so_kunnr AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~kdgrp IN so_kdgrp AND
                   b~kvgr3 IN so_kvgr3 AND
                   b~vtweg EQ '10' AND
                   b~vkbur IN r_vkleg AND
                   b~spart EQ '00' AND
                   c~brsch IN so_brsch.
    ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ EQ SPACE
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
           c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
           d~pernr
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                            b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~budat <= pa_date AND
                 a~augdt >= l_date1 AND
                 a~kunnr IN so_kunnr AND
                 a~umskz EQ space   AND
                 b~vkorg EQ pa_bukrs AND
                 b~kunnr IN so_kunnr AND
                 b~vtweg EQ '10' AND
                 b~spart EQ '00' AND
                 b~vkbur IN r_vkleg AND
                 a~blart IN s_blart  AND
*                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
    IF va_project NE 'X'.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
             FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t < 30        AND
                   a~kunnr IN so_kunnr AND
                   a~umskz EQ space   AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   b~vkbur IN r_vkleg AND
                   a~blart IN ('RV','ZA') AND
                   c~brsch IN so_brsch.
    ENDIF.
  ENDIF.

  IF x_norm EQ space AND x_shbv EQ 'X'.
* Select BSID for UMSKZ in Selection screen
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                 a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                 a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                 c~name1
                 b~kdgrp b~vwerk b~vkbur b~kvgr3
                 d~pernr
                 INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid
                 FROM bsid AS a
                           JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                 b~vkorg EQ a~bukrs
                           JOIN kna1 AS c ON c~kunnr EQ a~kunnr

*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                   d~parvw EQ 'ZP'
                 WHERE a~bukrs EQ pa_bukrs AND
                       a~hkont IN ( SELECT saknr FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                 ktopl EQ 'TSPC' ) AND
                       a~gjahr <= pa_date(4) AND
                       a~blart IN s_blart  AND
*                       ( a~blart EQ 'RV' OR a~blart EQ 'ZA' OR
*                       a~blart EQ 'DR' OR a~blart EQ 'DA' OR
*                       a~blart EQ 'DZ' ) AND
                       a~budat <= pa_date AND
                       a~kunnr IN so_kunnr AND
                       a~umskz IN s_bschl  AND
                       c~kunnr IN so_kunnr AND
                       b~vkorg EQ pa_bukrs AND
                       b~kunnr IN so_kunnr AND
                       b~kdgrp IN so_kdgrp AND
                       b~kvgr3 IN so_kvgr3 AND
                       b~vtweg EQ '10' AND
                       b~vkbur IN r_vkleg AND
                       b~spart EQ '00' AND
                       c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                   a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                   a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                   c~name1
                   b~kdgrp b~vwerk b~vkbur b~kvgr3
                   d~pernr
                   APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
                   FROM bsid AS a
                             JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                   b~vkorg EQ a~bukrs
                             JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                           LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                     d~parvw EQ 'ZP'
                   WHERE a~bukrs EQ pa_bukrs AND
                         a~hkont IN ( SELECT saknr FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' ) AND
                         ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                         a~budat >  pa_date AND
                         a~budat <= va_tanggal1 AND
                         a~zbd1t >=   0       AND
                         a~zbd1t <  30       AND
                         a~kunnr IN so_kunnr AND
                         a~umskz IN s_bschl  AND
                         c~kunnr IN so_kunnr AND
                         b~vkorg EQ pa_bukrs AND
                         b~kunnr IN so_kunnr AND
                         b~kdgrp IN so_kdgrp AND
                         b~kvgr3 IN so_kvgr3 AND
                         b~vtweg EQ '10' AND
                         b~vkbur IN r_vkleg AND
                         b~spart EQ '00' AND
                         c~brsch IN so_brsch.
    ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ in Selection screen
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
           c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
           d~pernr
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                            b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~budat <= pa_date AND
                 a~augdt >= l_date1 AND
                 a~kunnr IN so_kunnr AND
                 a~umskz IN s_bschl  AND
                 b~vkorg EQ pa_bukrs AND
                 b~kunnr IN so_kunnr AND
                 b~vtweg EQ '10' AND
                 b~spart EQ '00' AND
                 b~vkbur IN r_vkleg AND
                 a~blart IN s_blart  AND
*                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
             FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t < 30        AND
                   a~kunnr IN so_kunnr AND
                   a~umskz IN s_bschl  AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   b~vkbur IN r_vkleg AND
                   a~blart IN ('RV','ZA') AND
                   c~brsch IN so_brsch.
    ENDIF.
  ENDIF.


  DELETE i_itab_bsad WHERE NOT ( kdgrp IN so_kdgrp ).
  DELETE i_itab_bsid WHERE NOT ( kdgrp IN so_kdgrp ).

  DELETE i_itab_bsad WHERE NOT ( kvgr3 IN so_kvgr3 ).
  DELETE i_itab_bsid WHERE NOT ( kvgr3 IN so_kvgr3 ).

  DELETE i_itab_bsad WHERE  vwerk EQ '0200'.
  DELETE i_itab_bsid WHERE  vwerk EQ '0200'.

  DELETE i_itab_bsad WHERE  vwerk EQ space.
  DELETE i_itab_bsid WHERE  vwerk EQ space.

*  LOOP AT i_target WHERE vkbur IN r_vkleg.
*    wa_itab-bukrs = '8020'.
*    wa_itab-vkbur = i_target-vkbur.
*    wa_itab-kdgrp = i_target-kdgrp.
*    wa_itab-kunnr = i_target-pkunwe.
*    wa_itab-brsch = i_target-brsch.
**     select single CHANNEL into wa_itab-channel
**          from zfchanel
**          where bukrs = '8020' and
**                vkbur = i_target-vkbur and
**                KDGRP = i_target-kdgrp and
**                BRSCH = i_target-BRSCH.
**
*    wa_itab-shkzg = 'S'.
*    wa_itab-zfbdt = '00000000'.
*    wa_itab-zterm = i_target-ztop.
*    l_top = 30 - i_target-ztop.
*    IF l_top > 0.
*      wa_itab-value =  ( ( l_top / 30 ) * i_target-value ) * ( p_act / 100 ).
*    ELSE.
*      wa_itab-value =  0.
*    ENDIF.
*    wa_itab-vwerk = i_target-vkbur.
*    wa_itab-name1 = i_target-name1.
*    wa_itab-kunn2 = i_target-kunn2.
*    APPEND wa_itab TO  i_itab_bsad.
*  ENDLOOP.

ENDFORM.                    " f_get_data_Leg
*&---------------------------------------------------------------------*
*&      Form  f_get_data_Leg_OPDR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data_leg_opdr .

  DATA: l_pernr LIKE pa0001-pernr,
        l_spmon LIKE ztgtsls-spmon,
        l_top   TYPE i.
  DATA: l_date1(8),
        l_date2(8),
        l_monat1(2) TYPE n,
        l_monat2(2) TYPE n.

  va_tanggal  = pa_date + pa_day.
  l_spmon = va_tanggal(6).
  l_monat1 = pa_date+4(2).
  l_monat2 = pa_date+4(2) + 1.
  CONCATENATE pa_date(4) l_monat1 '01' INTO l_date1.
  CONCATENATE pa_date(4) l_monat2 '01' INTO l_date2.

  CLEAR: wa_itab, i_itab, va_data.
  IF va_project = 'X'.
*    SELECT a~spmon  a~pkunwe a~kvgr2 d~kdgrp a~vkbur a~waerk a~value a~ztop
*                 c~name1 c~brsch                            "b~kunn2
*                 APPENDING CORRESPONDING FIELDS OF TABLE i_target
*                 FROM ztgtsls AS a
*                      JOIN kna1 AS c ON c~kunnr EQ a~pkunwe
**                      left join knvp as b on b~kunnr eq a~pkunwe and
**                                        b~parvw eq 'ZC' and
**                                        b~vkorg eq pa_bukrs
*                      JOIN knvv AS d ON a~pkunwe EQ d~kunnr AND
*                                         d~vkorg EQ pa_bukrs
*                 WHERE a~spmon EQ l_spmon AND
*                       a~vkbur IN r_vkleg AND
*                       d~kdgrp IN so_kdgrp AND
*                       a~pkunwe IN so_kunnr AND
*                       c~brsch IN so_brsch  AND
*                       c~kunnr IN so_kunnr.
*    IF sy-subrc NE 0.
*      va_data = 'X'.
*    ENDIF.
  ENDIF.
  IF x_norm EQ 'X' AND x_shbv EQ 'X'.
* Select BSID for UMSKZ EQ SPACE
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                 a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                 a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                 c~name1
                 b~kdgrp b~vwerk b~kvgr3
                 d~pernr                                    "d~kunn2
                 p~vkbur
                 INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid
                 FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                                  p~posnr = '000010'
                           JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ a~bukrs
                           JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                   d~parvw EQ 'ZP'
                 WHERE a~bukrs EQ pa_bukrs AND
                       a~hkont IN ( SELECT saknr FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                 ktopl EQ 'TSPC' ) AND
                       a~gjahr <= pa_date(4) AND
                       a~blart IN s_blart  AND
*                       ( a~blart EQ 'RV' OR a~blart EQ 'ZA' OR
*                       a~blart EQ 'DR' OR a~blart EQ 'DA' OR
*                       a~blart EQ 'DZ' ) AND
                       a~budat <= pa_date AND
                       a~kunnr IN so_kunnr AND
                       a~umskz EQ space   AND
                       c~kunnr IN so_kunnr AND
                       b~vkorg EQ pa_bukrs AND
                       b~kunnr IN so_kunnr AND
                       b~kdgrp IN so_kdgrp AND
                       b~kvgr3 IN so_kvgr3 AND
                       b~vtweg EQ '10' AND
                       p~vkbur IN r_vkleg AND
                       b~spart EQ '00' AND
                       c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1
             b~kdgrp b~vwerk b~kvgr3
             d~pernr                                        "d~kunn2
             p~vkbur
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
             FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                              p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr

*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t <  30       AND
                   a~kunnr IN so_kunnr AND
                   a~umskz EQ space   AND
                   c~kunnr IN so_kunnr AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~kdgrp IN so_kdgrp AND
                   b~kvgr3 IN so_kvgr3 AND
                   b~vtweg EQ '10' AND
                   p~vkbur IN r_vkleg AND
                   b~spart EQ '00' AND
                   c~brsch IN so_brsch.
    ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ EQ SPACE
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
           c~name1 b~kdgrp b~vwerk b~kvgr3
           d~pernr
           p~vkbur
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                            p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~budat <= pa_date AND
                 a~augdt >= l_date1 AND
                 a~kunnr IN so_kunnr AND
                 a~umskz EQ space   AND
                 b~vkorg EQ pa_bukrs AND
                 b~kunnr IN so_kunnr AND
                 b~vtweg EQ '10' AND
                 b~spart EQ '00' AND
                 p~vkbur IN r_vkleg AND
                 a~blart IN s_blart  AND
*                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~kvgr3
             d~pernr
             p~vkbur
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
             FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                              p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t < 30        AND
                   a~kunnr IN so_kunnr AND
                   a~umskz EQ space   AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   p~vkbur IN r_vkleg AND
                   a~blart IN ('RV','ZA') AND
                   c~brsch IN so_brsch.
    ENDIF.
* Select BSID for UMSKZ in Selection screen
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                 a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                 a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                 c~name1
                 b~kdgrp b~vwerk b~kvgr3
                 d~pernr
                 p~vkbur
                 APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
                 FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                                  p~posnr = '000010'
                           JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ a~bukrs
                           JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                   d~parvw EQ 'ZP'
                 WHERE a~bukrs EQ pa_bukrs AND
                       a~hkont IN ( SELECT saknr FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                 ktopl EQ 'TSPC' ) AND

                       a~gjahr <= pa_date(4) AND
                       a~blart IN s_blart  AND
*                       ( a~blart EQ 'RV' OR a~blart EQ 'ZA' OR
*                       a~blart EQ 'DR' OR a~blart EQ 'DA' OR
*                       a~blart EQ 'DZ' ) AND
                       a~budat <= pa_date AND
                       a~kunnr IN so_kunnr AND
                       a~umskz IN s_bschl  AND
                       c~kunnr IN so_kunnr AND
                       b~vkorg EQ pa_bukrs AND
                       b~kunnr IN so_kunnr AND
                       b~kdgrp IN so_kdgrp AND
                       b~kvgr3 IN so_kvgr3 AND
                       b~vtweg EQ '10' AND
                       p~vkbur IN r_vkleg AND
                       b~spart EQ '00' AND
                       c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1
             b~kdgrp b~vwerk b~kvgr3
             d~pernr
             p~vkbur
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
             FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                              p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t <  30       AND
                   a~kunnr IN so_kunnr AND
                   a~umskz IN s_bschl  AND
                   c~kunnr IN so_kunnr AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~kdgrp IN so_kdgrp AND
                   b~kvgr3 IN so_kvgr3 AND
                   b~vtweg EQ '10' AND
                   p~vkbur IN r_vkleg AND
                   b~spart EQ '00' AND
                   c~brsch IN so_brsch.
    ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ in Selection screen
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
           c~name1 b~kdgrp b~vwerk b~kvgr3
           d~pernr
           p~vkbur
           APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                            p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~budat <= pa_date AND
                 a~augdt >= l_date1 AND
                 a~kunnr IN so_kunnr AND
                 a~umskz IN s_bschl  AND
                 b~vkorg EQ pa_bukrs AND
                 b~kunnr IN so_kunnr AND
                 b~vtweg EQ '10' AND
                 b~spart EQ '00' AND
                 p~vkbur IN r_vkleg AND
                 a~blart IN s_blart  AND
*                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~kvgr3
             d~pernr
             p~vkbur
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
             FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                              p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t < 30        AND
                   a~kunnr IN so_kunnr AND
                   a~umskz IN s_bschl  AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   p~vkbur IN r_vkleg AND
                   a~blart IN ('RV','ZA') AND
                   c~brsch IN so_brsch.
    ENDIF.
  ENDIF.

  IF x_norm EQ 'X' AND x_shbv EQ space.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                 a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                 a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                 c~name1
                 b~kdgrp b~vwerk b~kvgr3
                 d~pernr
                 p~vkbur
                 INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid
                 FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                                  p~posnr = '000010'
                           JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ a~bukrs
                           JOIN kna1 AS c ON c~kunnr EQ a~kunnr

*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                   d~parvw EQ 'ZP'
                 WHERE a~bukrs EQ pa_bukrs AND
                       a~hkont IN ( SELECT saknr FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                 ktopl EQ 'TSPC' ) AND
                       a~gjahr <= pa_date(4) AND
                       a~blart IN s_blart  AND
*                       ( a~blart EQ 'RV' OR a~blart EQ 'ZA' OR
*                       a~blart EQ 'DR' OR a~blart EQ 'DA' OR
*                       a~blart EQ 'DZ' ) AND
                       a~budat <= pa_date AND
                       a~kunnr IN so_kunnr AND
                       a~umskz EQ space   AND
                       c~kunnr IN so_kunnr AND
                       b~vkorg EQ pa_bukrs AND
                       b~kunnr IN so_kunnr AND
                       b~kdgrp IN so_kdgrp AND
                       b~kvgr3 IN so_kvgr3 AND
                       b~vtweg EQ '10' AND
                       p~vkbur IN r_vkleg AND
                       b~spart EQ '00' AND
                       c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1
             b~kdgrp b~vwerk b~kvgr3
             d~pernr
             p~vkbur
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
             FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                              p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t <  30       AND
                   a~kunnr IN so_kunnr AND
                   a~umskz EQ space   AND
                   c~kunnr IN so_kunnr AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~kdgrp IN so_kdgrp AND
                   b~kvgr3 IN so_kvgr3 AND
                   b~vtweg EQ '10' AND
                   p~vkbur IN r_vkleg AND
                   b~spart EQ '00' AND
                   c~brsch IN so_brsch.
    ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ EQ SPACE
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
           c~name1 b~kdgrp b~vwerk b~kvgr3
           d~pernr
           p~vkbur
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                            p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~budat <= pa_date AND
                 a~augdt >= l_date1 AND
                 a~kunnr IN so_kunnr AND
                 a~umskz EQ space   AND
                 b~vkorg EQ pa_bukrs AND
                 b~kunnr IN so_kunnr AND
                 b~vtweg EQ '10' AND
                 b~spart EQ '00' AND
                 p~vkbur IN r_vkleg AND
                 a~blart IN s_blart  AND
*                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
    IF va_project NE 'X'.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~kvgr3
             d~pernr
             p~vkbur
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
             FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                              p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t < 30        AND
                   a~kunnr IN so_kunnr AND
                   a~umskz EQ space   AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   p~vkbur IN r_vkleg AND
                   a~blart IN ('RV','ZA') AND
                   c~brsch IN so_brsch.
    ENDIF.
  ENDIF.

  IF x_norm EQ space AND x_shbv EQ 'X'.
* Select BSID for UMSKZ in Selection screen
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                 a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                 a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                 c~name1
                 b~kdgrp b~vwerk b~kvgr3
                 d~pernr
                 p~vkbur
                 INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid
                 FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                                  p~posnr = '000010'
                           JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                             b~vkorg EQ a~bukrs
                           JOIN kna1 AS c ON c~kunnr EQ a~kunnr

*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                   d~parvw EQ 'ZP'
                 WHERE a~bukrs EQ pa_bukrs AND
                       a~hkont IN ( SELECT saknr FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                 ktopl EQ 'TSPC' ) AND
                       a~gjahr <= pa_date(4) AND
                       a~blart IN s_blart  AND
*                       ( a~blart EQ 'RV' OR a~blart EQ 'ZA' OR
*                       a~blart EQ 'DR' OR a~blart EQ 'DA' OR
*                       a~blart EQ 'DZ' ) AND
                       a~budat <= pa_date AND
                       a~kunnr IN so_kunnr AND
                       a~umskz IN s_bschl  AND
                       c~kunnr IN so_kunnr AND
                       b~vkorg EQ pa_bukrs AND
                       b~kunnr IN so_kunnr AND
                       b~kdgrp IN so_kdgrp AND
                       b~kvgr3 IN so_kvgr3 AND
                       b~vtweg EQ '10' AND
                       p~vkbur IN r_vkleg AND
                       b~spart EQ '00' AND
                       c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                   a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                   a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                   c~name1
                   b~kdgrp b~vwerk b~kvgr3
                   d~pernr
                   p~vkbur
                   APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
                   FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                                    p~posnr = '000010'
                             JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                               b~vkorg EQ a~bukrs
                             JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                           LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                     d~parvw EQ 'ZP'
                   WHERE a~bukrs EQ pa_bukrs AND
                         a~hkont IN ( SELECT saknr FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' ) AND
                         ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                         a~budat >  pa_date AND
                         a~budat <= va_tanggal1 AND
                         a~zbd1t >=   0       AND
                         a~zbd1t <  30       AND
                         a~kunnr IN so_kunnr AND
                         a~umskz IN s_bschl  AND
                         c~kunnr IN so_kunnr AND
                         b~vkorg EQ pa_bukrs AND
                         b~kunnr IN so_kunnr AND
                         b~kdgrp IN so_kdgrp AND
                         b~kvgr3 IN so_kvgr3 AND
                         b~vtweg EQ '10' AND
                         p~vkbur IN r_vkleg AND
                         b~spart EQ '00' AND
                         c~brsch IN so_brsch.
    ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ in Selection screen
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
           c~name1 b~kdgrp b~vwerk b~kvgr3
           d~pernr
           p~vkbur
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                            p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~budat <= pa_date AND
                 a~augdt >= l_date1 AND
                 a~kunnr IN so_kunnr AND
                 a~umskz IN s_bschl  AND
                 b~vkorg EQ pa_bukrs AND
                 b~kunnr IN so_kunnr AND
                 b~vtweg EQ '10' AND
                 b~spart EQ '00' AND
                 p~vkbur IN r_vkleg AND
                 a~blart IN s_blart  AND
*                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
    IF va_project NE 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~kvgr3
             d~pernr
             p~vkbur
             APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
             FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                              p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat >  pa_date AND
                   a~budat <= va_tanggal1 AND
                   a~zbd1t >=   0       AND
                   a~zbd1t < 30        AND
                   a~kunnr IN so_kunnr AND
                   a~umskz IN s_bschl  AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr IN so_kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   p~vkbur IN r_vkleg AND
                   a~blart IN ('RV','ZA') AND
                   c~brsch IN so_brsch.
    ENDIF.
  ENDIF.


  DELETE i_itab_bsad WHERE NOT ( kdgrp IN so_kdgrp ).
  DELETE i_itab_bsid WHERE NOT ( kdgrp IN so_kdgrp ).

  DELETE i_itab_bsad WHERE NOT ( kvgr3 IN so_kvgr3 ).
  DELETE i_itab_bsid WHERE NOT ( kvgr3 IN so_kvgr3 ).

  DELETE i_itab_bsad WHERE  vwerk EQ '0200'.
  DELETE i_itab_bsid WHERE  vwerk EQ '0200'.

  DELETE i_itab_bsad WHERE  vwerk EQ space.
  DELETE i_itab_bsid WHERE  vwerk EQ space.

*  LOOP AT i_target WHERE vkbur IN r_vkleg.
*    wa_itab-bukrs = '8020'.
*    wa_itab-vkbur = i_target-vkbur.
*    wa_itab-kdgrp = i_target-kdgrp.
*    wa_itab-kunnr = i_target-pkunwe.
*    wa_itab-brsch = i_target-brsch.
**     select single CHANNEL into wa_itab-channel
**          from zfchanel
**          where bukrs = '8020' and
**                vkbur = i_target-vkbur and
**                KDGRP = i_target-kdgrp and
**                BRSCH = i_target-BRSCH.
**
*    wa_itab-shkzg = 'S'.
*    wa_itab-zfbdt = '00000000'.
*    wa_itab-zterm = i_target-ztop.
*    l_top = 30 - i_target-ztop.
*    IF l_top > 0.
*      wa_itab-value =  ( ( l_top / 30 ) * i_target-value ) * ( p_act / 100 ).
*    ELSE.
*      wa_itab-value =  0.
*    ENDIF.
*    wa_itab-vwerk = i_target-vkbur.
*    wa_itab-name1 = i_target-name1.
*    wa_itab-kunn2 = i_target-kunn2.
*    APPEND wa_itab TO  i_itab_bsad.
*  ENDLOOP.

ENDFORM.                    " f_get_data_Leg_OPDR
*&---------------------------------------------------------------------*
*&      Form  f_tambah_kunnr_leg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_tambah_kunnr_leg .
  DATA: l_top TYPE i,
        lv_budat  TYPE bsid-budat.

  IF i_zfarsoff_add_leg[] IS NOT INITIAL.
    va_tanggal  = pa_date + pa_day.

    DATA: l_date1(8),
          l_date2(8),
          l_spmon LIKE ztgtsls-spmon,
          l_monat1(2) TYPE n,
          l_monat2(2) TYPE n.

    l_monat1 = pa_date+4(2).
    l_monat2 = pa_date+4(2) + 1.
    l_spmon = va_tanggal(6).

    CONCATENATE pa_date(4) l_monat1 '01' INTO l_date1.
    CONCATENATE pa_date(4) l_monat2 '01' INTO l_date2.
    REFRESH: i_target.
    CLEAR: i_target.

    REFRESH: i_target.
    CLEAR: wa_itab, i_itab.
    SORT i_zfarsoff_add_leg BY bukrs zvkbur kunnr.
    IF va_project = 'X'.
*      SELECT a~spmon  a~pkunwe a~kvgr2 b~kdgrp a~vkbur a~waerk a~value a~ztop
*                   c~name1 c~brsch                          "d~kunn2
*                   APPENDING CORRESPONDING FIELDS OF TABLE i_target
*                   FROM ztgtsls AS a
*                        JOIN kna1 AS c ON c~kunnr EQ a~pkunwe
*                        JOIN knvv AS b ON a~pkunwe EQ b~kunnr AND
*                                           b~vkorg EQ pa_bukrs
*                                              AND b~vkorg EQ pa_bukrs
**                            LEFT JOIN knvp AS d ON d~kunnr EQ a~pkunwe AND
**                                              d~parvw EQ 'ZC'
**                                              AND d~vkorg EQ pa_bukrs
*                  FOR ALL ENTRIES IN i_zfarsoff_add_leg "t_zfarsoff_add
*                   WHERE a~spmon EQ l_spmon AND
**                       a~bukrs eq i_zfarsoff_add_leg-bukrs and
*                         a~vkbur EQ i_zfarsoff_add_leg-zvkbur AND
*                         a~pkunwe EQ i_zfarsoff_add_leg-kunnr AND
*                         b~kdgrp IN so_kdgrp AND
*                         c~brsch IN so_brsch  AND
*                         c~kunnr EQ t_zfarsoff_add-kunnr.
    ENDIF.

    IF x_norm EQ 'X' AND x_shbv EQ 'X'.
* Select BSID for UMSKZ EQ SPACE
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                   a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                   a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                   c~name1
                   b~kdgrp b~vwerk b~vkbur b~kvgr3
                   d~pernr
                   FROM bsid AS a
                             JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                               b~vkorg EQ a~bukrs
                             JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                           LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                     d~parvw EQ 'ZP'
                   INTO CORRESPONDING FIELDS OF TABLE t_bsid_add
                   FOR ALL ENTRIES IN i_zfarsoff_add_leg
                   WHERE a~bukrs EQ pa_bukrs AND
                         a~hkont IN ( SELECT saknr FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' ) AND
                         a~gjahr <= pa_date(4) AND
                         a~blart IN s_blart  AND
                         a~budat <= pa_date AND
                         a~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                         a~umskz EQ space   AND
                         c~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                         b~vkorg EQ pa_bukrs AND
                         b~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                         b~kdgrp IN so_kdgrp AND
                         b~kvgr3 IN so_kvgr3 AND
                         b~vtweg EQ '10' AND
                         b~vkbur EQ i_zfarsoff_add_leg-zvkbur AND
                         b~spart EQ '00' AND
                         c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
      IF va_project NE 'X'.
        SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                     a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                     a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                     c~name1
                     b~kdgrp b~vwerk b~vkbur b~kvgr3
                     d~pernr
                     FROM bsid AS a
                               JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                     b~vkorg EQ a~bukrs
                               JOIN kna1 AS c ON c~kunnr EQ a~kunnr

*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                             LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                       d~parvw EQ 'ZP'
                     APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add
                     FOR ALL ENTRIES IN i_zfarsoff_add_leg
                     WHERE a~bukrs EQ pa_bukrs AND
                           a~hkont IN ( SELECT saknr FROM skat
                               WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' ) AND
                           ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                           a~budat >  pa_date AND
                           a~budat <= va_tanggal1 AND
                           a~zbd1t >=   0       AND
                           a~zbd1t <  30       AND
                           a~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                           a~umskz EQ space   AND
                           c~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                           b~vkorg EQ pa_bukrs AND
                           b~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                           b~kdgrp IN so_kdgrp AND
                           b~kvgr3 IN so_kvgr3 AND
                           b~vtweg EQ '10' AND
                           b~vkbur EQ i_zfarsoff_add_leg-zvkbur AND
                           b~spart EQ '00' AND
                           c~brsch IN so_brsch.
      ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ EQ SPACE
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
             FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                              b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_bsad_add
             FOR ALL ENTRIES IN i_zfarsoff_add_leg
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat <= pa_date AND
                   a~augdt >= l_date1 AND
                   a~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                   a~umskz EQ space   AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   b~vkbur EQ i_zfarsoff_add_leg-zvkbur AND
                   a~blart IN s_blart  AND
                   c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
      IF va_project NE 'X'.
        SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
               a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
               a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
               c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
               d~pernr
               FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                               b~vkorg EQ pa_bukrs
                         JOIN kna1 AS c ON c~kunnr EQ a~kunnr

*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                         LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                 d~parvw EQ 'ZP'
               APPENDING CORRESPONDING FIELDS OF TABLE t_bsad_add
               FOR ALL ENTRIES IN i_zfarsoff_add_leg
               WHERE a~bukrs EQ pa_bukrs AND
                     a~hkont IN ( SELECT saknr FROM skat
                         WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                               ktopl EQ 'TSPC' ) AND
                     a~budat >  pa_date AND
                     a~budat <= va_tanggal1 AND
                     a~zbd1t >=   0       AND
                     a~zbd1t < 30        AND
                     a~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                     a~umskz EQ space   AND
                     b~vkorg EQ pa_bukrs AND
                     b~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                     b~vtweg EQ '10' AND
                     b~spart EQ '00' AND
                     b~vkbur EQ i_zfarsoff_add_leg-zvkbur AND
                     a~blart IN ('RV','ZA') AND
                     c~brsch IN so_brsch.
      ENDIF.
* Select BSID for UMSKZ in Selection screen
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                   a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                   a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                   c~name1
                   b~kdgrp b~vwerk b~vkbur b~kvgr3
                   d~pernr
                   FROM bsid AS a
                             JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                   b~vkorg EQ a~bukrs
                             JOIN kna1 AS c ON c~kunnr EQ a~kunnr

*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                           LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                     d~parvw EQ 'ZP'
                   APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add
                   FOR ALL ENTRIES IN i_zfarsoff_add_leg
                   WHERE a~bukrs EQ pa_bukrs AND
                         a~hkont IN ( SELECT saknr FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' ) AND

                         a~gjahr <= pa_date(4) AND
                         a~blart IN s_blart  AND
                         a~budat <= pa_date AND
                         a~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                         a~umskz IN s_bschl  AND
                         c~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                         b~vkorg EQ pa_bukrs AND
                         b~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                         b~kdgrp IN so_kdgrp AND
                         b~kvgr3 IN so_kvgr3 AND
                         b~vtweg EQ '10' AND
                         b~vkbur EQ i_zfarsoff_add_leg-zvkbur AND
                         b~spart EQ '00' AND
                         c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
      IF va_project NE 'X'.
        SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                     a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                     a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                     c~name1
                     b~kdgrp b~vwerk b~vkbur b~kvgr3
                     d~pernr
                     FROM bsid AS a
                               JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                     b~vkorg EQ a~bukrs
                               JOIN kna1 AS c ON c~kunnr EQ a~kunnr

*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                             LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                       d~parvw EQ 'ZP'
                     APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add
                     FOR ALL ENTRIES IN i_zfarsoff_add_leg
                     WHERE a~bukrs EQ pa_bukrs AND
                           a~hkont IN ( SELECT saknr FROM skat
                               WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' ) AND
                           ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                           a~budat >  pa_date AND
                           a~budat <= va_tanggal1 AND
                           a~zbd1t >=   0       AND
                           a~zbd1t <  30       AND
                           a~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                           a~umskz IN s_bschl  AND
                           c~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                           b~vkorg EQ pa_bukrs AND
                           b~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                           b~kdgrp IN so_kdgrp AND
                           b~kvgr3 IN so_kvgr3 AND
                           b~vtweg EQ '10' AND
                           b~vkbur EQ i_zfarsoff_add_leg-zvkbur AND
                           b~spart EQ '00' AND
                           c~brsch IN so_brsch.
      ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ in Selection screen
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
             FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                              b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                           LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                     d~parvw EQ 'ZP'
             APPENDING CORRESPONDING FIELDS OF TABLE t_bsad_add
             FOR ALL ENTRIES IN i_zfarsoff_add_leg
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat <= pa_date AND
                   a~augdt >= l_date1 AND
                   a~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                   a~umskz IN s_bschl  AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   b~vkbur EQ i_zfarsoff_add_leg-zvkbur AND
                   a~blart IN s_blart  AND
                   c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
      IF va_project NE 'X'.
        SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
               a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
               a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
               c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
               d~pernr
               FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                               b~vkorg EQ pa_bukrs
                         JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                             LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                       d~parvw EQ 'ZP'
               APPENDING CORRESPONDING FIELDS OF TABLE t_bsad_add
               FOR ALL ENTRIES IN i_zfarsoff_add_leg
               WHERE a~bukrs EQ pa_bukrs AND
                     a~hkont IN ( SELECT saknr FROM skat
                         WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                               ktopl EQ 'TSPC' ) AND
                     a~budat >  pa_date AND
                     a~budat <= va_tanggal1 AND
                     a~zbd1t >=   0       AND
                     a~zbd1t < 30        AND
                     a~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                     a~umskz IN s_bschl  AND
                     b~vkorg EQ pa_bukrs AND
                     b~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                     b~vtweg EQ '10' AND
                     b~spart EQ '00' AND
                     b~vkbur EQ i_zfarsoff_add_leg-zvkbur AND
                     a~blart IN ('RV','ZA') AND
                     c~brsch IN so_brsch.
      ENDIF.
    ENDIF.

    IF x_norm EQ 'X' AND x_shbv EQ space.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                   a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                   a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                   c~name1
                   b~kdgrp b~vwerk b~vkbur b~kvgr3
                   d~pernr
                   FROM bsid AS a
                             JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                   b~vkorg EQ a~bukrs
                             JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                           LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                     d~parvw EQ 'ZP'
                   INTO CORRESPONDING FIELDS OF TABLE t_bsid_add
                   FOR ALL ENTRIES IN i_zfarsoff_add_leg
                   WHERE a~bukrs EQ pa_bukrs AND
                         a~hkont IN ( SELECT saknr FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' ) AND
                         a~gjahr <= pa_date(4) AND
                         a~blart IN s_blart  AND
                         a~budat <= pa_date AND
                         a~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                         a~umskz EQ space   AND
                         c~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                         b~vkorg EQ pa_bukrs AND
                         b~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                         b~kdgrp IN so_kdgrp AND
                         b~kvgr3 IN so_kvgr3 AND
                         b~vtweg EQ '10' AND
                         b~vkbur EQ i_zfarsoff_add_leg-zvkbur AND
                         b~spart EQ '00' AND
                         c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
      IF va_project NE 'X'.
        SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                     a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                     a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                     c~name1
                     b~kdgrp b~vwerk b~vkbur b~kvgr3
                     d~pernr
                     FROM bsid AS a
                               JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                     b~vkorg EQ a~bukrs
                               JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                             LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                       d~parvw EQ 'ZP'
                     APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add
                     FOR ALL ENTRIES IN i_zfarsoff_add_leg
                     WHERE a~bukrs EQ pa_bukrs AND
                           a~hkont IN ( SELECT saknr FROM skat
                               WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' ) AND
                           ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                           a~budat >  pa_date AND
                           a~budat <= va_tanggal1 AND
                           a~zbd1t >=   0       AND
                           a~zbd1t <  30       AND
                           a~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                           a~umskz EQ space   AND
                           c~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                           b~vkorg EQ pa_bukrs AND
                           b~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                           b~kdgrp IN so_kdgrp AND
                           b~kvgr3 IN so_kvgr3 AND
                           b~vtweg EQ '10' AND
                           b~vkbur EQ i_zfarsoff_add_leg-zvkbur AND
                           b~spart EQ '00' AND
                           c~brsch IN so_brsch.
      ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ EQ SPACE
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
             FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                              b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                           LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                     d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_bsad_add
             FOR ALL ENTRIES IN i_zfarsoff_add_leg
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat <= pa_date AND
                   a~augdt >= l_date1 AND
                   a~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                   a~umskz EQ space   AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   b~vkbur EQ i_zfarsoff_add_leg-zvkbur AND
                   a~blart IN s_blart  AND
                   c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
      IF va_project NE 'X'.
        SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
               a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
               a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
               c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
               d~pernr
               FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                               b~vkorg EQ pa_bukrs
                         JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                             LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                       d~parvw EQ 'ZP'
               APPENDING CORRESPONDING FIELDS OF TABLE t_bsad_add
               FOR ALL ENTRIES IN i_zfarsoff_add_leg
               WHERE a~bukrs EQ pa_bukrs AND
                     a~hkont IN ( SELECT saknr FROM skat
                         WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                               ktopl EQ 'TSPC' ) AND
                     a~budat >  pa_date AND
                     a~budat <= va_tanggal1 AND
                     a~zbd1t >=   0       AND
                     a~zbd1t < 30        AND
                     a~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                     a~umskz EQ space   AND
                     b~vkorg EQ pa_bukrs AND
                     b~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                     b~vtweg EQ '10' AND
                     b~spart EQ '00' AND
                     b~vkbur EQ i_zfarsoff_add_leg-zvkbur AND
                     a~blart IN ('RV','ZA') AND
                     c~brsch IN so_brsch.
      ENDIF.
    ENDIF.

    IF x_norm EQ space AND x_shbv EQ 'X'.
* Select BSID for UMSKZ in Selection screen
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                   a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                   a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                   c~name1
                   b~kdgrp b~vwerk b~vkbur b~kvgr3
                   d~pernr
                   FROM bsid AS a
                             JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                   b~vkorg EQ a~bukrs
                             JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                           LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                     d~parvw EQ 'ZP'
                   INTO CORRESPONDING FIELDS OF TABLE t_bsid_add
                   FOR ALL ENTRIES IN i_zfarsoff_add_leg
                   WHERE a~bukrs EQ pa_bukrs AND
                         a~hkont IN ( SELECT saknr FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' ) AND
                         a~gjahr <= pa_date(4) AND
                         a~blart IN s_blart  AND
                         a~budat <= pa_date AND
                         a~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                         a~umskz IN s_bschl  AND
                         c~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                         b~vkorg EQ pa_bukrs AND
                         b~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                         b~kdgrp IN so_kdgrp AND
                         b~kvgr3 IN so_kvgr3 AND
                         b~vtweg EQ '10' AND
                         b~vkbur EQ i_zfarsoff_add_leg-zvkbur AND
                         b~spart EQ '00' AND
                         c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSID ).
      IF va_project NE 'X'.
        SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
                     a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
                     a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
                     c~name1
                     b~kdgrp b~vwerk b~vkbur b~kvgr3
                      d~pernr
                     FROM bsid AS a
                               JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                                     b~vkorg EQ a~bukrs
                               JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                             LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                       d~parvw EQ 'ZP'
                     APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add
                     FOR ALL ENTRIES IN i_zfarsoff_add_leg
                     WHERE a~bukrs EQ pa_bukrs AND
                           a~hkont IN ( SELECT saknr FROM skat
                               WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' ) AND
                           ( a~blart EQ 'RV' OR a~blart EQ 'ZA' ) AND
                           a~budat >  pa_date AND
                           a~budat <= va_tanggal1 AND
                           a~zbd1t >=   0       AND
                           a~zbd1t <  30       AND
                           a~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                           a~umskz IN s_bschl  AND
                           c~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                           b~vkorg EQ pa_bukrs AND
                           b~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                           b~kdgrp IN so_kdgrp AND
                           b~kvgr3 IN so_kvgr3 AND
                           b~vtweg EQ '10' AND
                           b~vkbur EQ i_zfarsoff_add_leg-zvkbur AND
                           b~spart EQ '00' AND
                           c~brsch IN so_brsch.
      ENDIF.
*-----
* new selection for bsad
* Select BSAD for UMSKZ in Selection screen
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
             FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                              b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                           LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                     d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_bsad_add
             FOR ALL ENTRIES IN i_zfarsoff_add_leg
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~budat <= pa_date AND
                   a~augdt >= l_date1 AND
                   a~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                   a~umskz IN s_bschl  AND
                   b~vkorg EQ pa_bukrs AND
                   b~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                   b~vtweg EQ '10' AND
                   b~spart EQ '00' AND
                   b~vkbur EQ i_zfarsoff_add_leg-zvkbur AND
                   a~blart IN s_blart  AND
                   c~brsch IN so_brsch.

* Get data untuk Sales week 1 ( BSAD ).
      IF va_project NE 'X'.
        SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
               a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
               a~xref1 a~xref2 a~blart a~zterm a~umskz a~anln1
               c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
               d~pernr
               FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                               b~vkorg EQ pa_bukrs
                         JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                             LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                                       d~parvw EQ 'ZP'
               APPENDING CORRESPONDING FIELDS OF TABLE t_bsad_add
               FOR ALL ENTRIES IN i_zfarsoff_add_leg
               WHERE a~bukrs EQ pa_bukrs AND
                     a~hkont IN ( SELECT saknr FROM skat
                         WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                               ktopl EQ 'TSPC' ) AND
                     a~budat >  pa_date AND
                     a~budat <= va_tanggal1 AND
                     a~zbd1t >=   0       AND
                     a~zbd1t < 30        AND
                     a~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                     a~umskz IN s_bschl  AND
                     b~vkorg EQ pa_bukrs AND
                     b~kunnr EQ i_zfarsoff_add_leg-kunnr AND
                     b~vtweg EQ '10' AND
                     b~spart EQ '00' AND
                     b~vkbur EQ i_zfarsoff_add_leg-zvkbur AND
                     a~blart IN ('RV','ZA') AND
                     c~brsch IN so_brsch.
      ENDIF.
    ENDIF.

*    LOOP AT i_target WHERE vkbur IN r_vkleg.
*      wa_itab-bukrs = '8020'.
*      wa_itab-vkbur = i_target-vkbur.
*      wa_itab-kdgrp = i_target-kdgrp.
*      wa_itab-kunnr = i_target-pkunwe.
*      wa_itab-xref1 = i_target-kunn2.
*      wa_itab-brsch = i_target-brsch.
*      wa_itab-shkzg = 'S'.
*      wa_itab-zterm = i_target-ztop.
*      l_top = 30 - i_target-ztop.
*      IF l_top > 0.
*        wa_itab-value =  ( ( l_top / 30 ) * i_target-value ) * ( p_act / 100 ).
*      ELSE.
*        wa_itab-value =  0.
*      ENDIF.
*      wa_itab-vwerk = i_target-vkbur.
*      wa_itab-name1 = i_target-name1.
*
*      APPEND wa_itab TO  t_bsad_add.
*    ENDLOOP.
    REFRESH: i_target.
    CLEAR: i_target.
    SORT t_bsid_add BY kunnr pkunwe.
    SORT t_bsad_add BY kunnr.
    SORT t_zfarsoff_add BY kunnr.
    LOOP AT t_bsid_add INTO wa_itab.
      READ TABLE t_zfarsoff_add WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_budat = t_zfarsoff_add-budat - 1.
        IF pa_date LT lv_budat.
          IF t_zfarsoff_add-zvkbur IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur.
            APPEND wa_itab TO i_itab_leg.
          ENDIF.
        ELSE.
          IF t_zfarsoff_add-zvkbur1 IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur1.
            APPEND wa_itab TO i_itab_leg.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.

***** Add delete BSAD jika tidak sesuai dengan kdgrp.
    DELETE t_bsad_add WHERE NOT ( kdgrp IN so_kdgrp ).
    DELETE t_bsad_add WHERE NOT ( kvgr3 IN so_kvgr3 ).
*****
    LOOP AT t_bsad_add INTO wa_itab.
      READ TABLE t_zfarsoff_add WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_budat = t_zfarsoff_add-budat - 1.
        IF pa_date LT lv_budat.
          IF t_zfarsoff_add-zvkbur IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur.
            APPEND wa_itab TO i_itab_leg.
          ENDIF.
        ELSE.
          IF t_zfarsoff_add-zvkbur1 IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur1.
            APPEND wa_itab TO i_itab_leg.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " f_tambah_kunnr_leg
*&---------------------------------------------------------------------*
*&      Form  f_gabung_sap
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_gabung .
  DATA: BEGIN OF lt_cust OCCURS 0,
          bukrs LIKE bsid-bukrs,
          vkbur LIKE tvbur-vkbur,
          kunnr LIKE bsid-kunnr,
        END OF lt_cust.
  CLEAR: va_dmbtr, va_value.
  SORT i_itab_sap BY bukrs vkbur zuonr.
  LOOP AT i_itab_sap INTO wa_itab.
    IF wa_itab-kunnr IS INITIAL.
      IF wa_itab-pkunwe IS INITIAL.
      ELSE.
        wa_itab-kunnr = wa_itab-pkunwe.
      ENDIF.
    ENDIF.
    IF wa_itab-vkbur NE space.
      IF wa_itab-vwerk IS INITIAL.
        wa_itab-vwerk = wa_itab-vkbur.
      ENDIF.
    ENDIF.

    IF wa_itab-vwerk NE space.
      wa_itab-gsber = wa_itab-vwerk.
    ENDIF.
*    IF wa_itab-blart NE 'RV'.
*      wa_itab-pernr = wa_itab-xref2.
*    ENDIF.

** Koreksi 13/11/2014
*    SELECT SINGLE kunn2 INTO wa_itab-kunn2
*           FROM knvp
*           WHERE kunnr = wa_itab-kunnr AND
*                 parvw EQ 'ZC'  AND
*                 vkorg EQ pa_bukrs.
*    IF sy-subrc EQ 0.
*      wa_itab-xref1 = wa_itab-kunn2.
*      SELECT SINGLE pernr INTO  wa_itab-pernr FROM knvp
*             WHERE kunnr = wa_itab-kunn2 AND
*                   parvw = 'ZP' AND
*                   vkorg = pa_bukrs.
*    ELSE.
*      CLEAR: wa_itab-xref1, wa_itab-pernr.
*    ENDIF.
    IF wa_itab-xref1 IS INITIAL.
      SELECT SINGLE kunn2 INTO wa_itab-kunn2
             FROM knvp
             WHERE kunnr = wa_itab-kunnr AND
                   parvw EQ 'ZC'  AND
                   vkorg EQ pa_bukrs.
      IF sy-subrc EQ 0.
        wa_itab-xref1 = wa_itab-kunn2.
      ENDIF.
    ENDIF.

    SELECT SINGLE pernr INTO  wa_itab-pernr FROM knvp
            WHERE kunnr = wa_itab-xref1 AND
                  parvw = 'ZP' AND
                  vkorg = pa_bukrs.
** End Koreksi 13/11/2014

*    wa_itab-xref1 = wa_itab-kunn2.

    MODIFY i_itab_sap FROM wa_itab TRANSPORTING gsber pernr vwerk kunnr xref1 kunn2.

    IF wa_itab-shkzg = 'H'.
      wa_itab-dmbtr = wa_itab-dmbtr * -1.
    ENDIF.
    ADD wa_itab-value TO va_value.
    ADD wa_itab-dmbtr TO va_dmbtr.

** Revise by budi 26/06/2006
    IF pa_date LT va_cutdate.
      lt_cust-bukrs = wa_itab-bukrs.
      lt_cust-vkbur = wa_itab-vkbur.
      lt_cust-kunnr = wa_itab-kunnr.
      COLLECT lt_cust. CLEAR lt_cust.
    ENDIF.
** End Revise by budi 26/06/2006

    AT END OF zuonr.
      IF va_dmbtr = 0 AND va_value = 0.
        DELETE i_itab_sap WHERE bukrs = wa_itab-bukrs AND
                            vkbur = wa_itab-vkbur AND
                            zuonr = wa_itab-zuonr.
      ENDIF.
      CLEAR: va_dmbtr, va_value.
    ENDAT.
  ENDLOOP.

  CLEAR: va_dmbtr, va_value.
  SORT i_itab_leg BY bukrs vkbur zuonr.
  LOOP AT i_itab_leg INTO wa_itab.
    IF wa_itab-kunnr IS INITIAL.
      IF wa_itab-pkunwe IS INITIAL.
      ELSE.
        wa_itab-kunnr = wa_itab-pkunwe.
      ENDIF.
    ENDIF.
    IF wa_itab-vkbur NE space.
      IF wa_itab-vwerk IS INITIAL.
        wa_itab-vwerk = wa_itab-vkbur.
      ENDIF.
    ENDIF.

    IF wa_itab-vwerk NE space.
      wa_itab-gsber = wa_itab-vwerk.
    ENDIF.
    IF wa_itab-blart NE 'RV'.
      wa_itab-pernr = wa_itab-xref2.
    ENDIF.


    MODIFY i_itab_leg FROM wa_itab TRANSPORTING gsber pernr vwerk kunnr.

    IF wa_itab-shkzg = 'H'.
      wa_itab-dmbtr = wa_itab-dmbtr * -1.
    ENDIF.
    ADD wa_itab-value TO va_value.
    ADD wa_itab-dmbtr TO va_dmbtr.

** Revise by budi 26/06/2006
    IF pa_date LT va_cutdate.
      lt_cust-bukrs = wa_itab-bukrs.
      lt_cust-vkbur = wa_itab-vkbur.
      lt_cust-kunnr = wa_itab-kunnr.
      COLLECT lt_cust. CLEAR lt_cust.
    ENDIF.
** End Revise by budi 26/06/2006

    AT END OF zuonr.
      IF va_dmbtr = 0 AND va_value = 0.
        DELETE i_itab_leg WHERE bukrs = wa_itab-bukrs AND
                            vkbur = wa_itab-vkbur AND
                            zuonr = wa_itab-zuonr.
      ENDIF.
      CLEAR: va_dmbtr, va_value.
    ENDAT.
  ENDLOOP.

** Revise by budi 26/06/2006
  IF pa_date LT va_cutdate.
    SELECT vkorg vkbur kunnr zterm
      INTO CORRESPONDING FIELDS OF TABLE i_knvv
      FROM knvv
      FOR ALL ENTRIES IN lt_cust
      WHERE kunnr = lt_cust-kunnr AND
            vkorg = lt_cust-bukrs AND
            vtweg = '10'          AND
            spart = '00'          AND
            vkbur = lt_cust-vkbur.
    SORT i_knvv BY vkorg vkbur kunnr.
  ENDIF.
** End Revise by budi 26/06/2006

ENDFORM.                    " f_gabung_sap
*&---------------------------------------------------------------------*
*&      Form  f_gabung_leg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_gabung_leg .
  DATA: BEGIN OF lt_cust OCCURS 0,
          bukrs LIKE bsid-bukrs,
          vkbur LIKE tvbur-vkbur,
          kunnr LIKE bsid-kunnr,
        END OF lt_cust.

ENDFORM.                    " f_gabung_leg
*&---------------------------------------------------------------------*
*&      Form  f_get_real_SAP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_real_sap .
  DATA: l_date  TYPE sy-datum,
        l_date1 TYPE sy-datum.

  CONCATENATE pa_date(6) '01' INTO l_date1.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = pa_date
    IMPORTING
      last_day_of_month = l_date.

  l_date = l_date + 1.

  ra_date-sign   = 'I'.
  ra_date-option = 'BT'.
  ra_date-low    = l_date.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ra_date-low
    IMPORTING
      last_day_of_month = ra_date-high.
  APPEND ra_date.

  IF x_norm EQ 'X' AND x_shbv EQ 'X'.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1
           b~kdgrp b~vwerk b~vkbur b~kvgr3
           "d~kunn2 "d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid_real
      FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ a~bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            a~budat IN ra_date                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz EQ space                                        AND
            c~kunnr IN so_kunnr                                     AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~kdgrp IN so_kdgrp                                     AND
            b~kvgr3 IN so_kvgr3                                     AND
            b~vtweg EQ '10'                                         AND
            b~vkbur IN r_vksap                                     AND
            b~spart EQ '00'                                         AND
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1
           b~kdgrp b~vwerk b~vkbur b~kvgr3
           "d~kunn2 "d~pernr
      APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid_real
      FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ a~bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            a~budat IN ra_date                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz IN s_bschl                                      AND
            c~kunnr IN so_kunnr                                     AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~kdgrp IN so_kdgrp                                     AND
            b~kvgr3 IN so_kvgr3                                     AND
            b~vtweg EQ '10'                                         AND
            b~vkbur IN r_vksap                                     AND
            b~spart EQ '00'                                         AND
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
           "d~kunn2 "d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad_real
      FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
            a~budat IN ra_date                                      AND
            a~augdt >= l_date1                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz EQ space                                        AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~vtweg EQ '10'                                         AND
            b~spart EQ '00'                                         AND
            b~vkbur IN r_vksap                                     AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
           "d~kunn2 "d~pernr
      APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad_real
      FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
            a~budat IN ra_date                                      AND
            a~augdt >= l_date1                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz IN s_bschl                                      AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~vtweg EQ '10'                                         AND
            b~spart EQ '00'                                         AND
            b~vkbur IN r_vksap                                     AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            c~brsch IN so_brsch.
  ENDIF.

  IF x_norm EQ 'X' AND x_shbv EQ space.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1
           b~kdgrp b~vwerk b~vkbur b~kvgr3
           "d~kunn2 "d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid_real
      FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ a~bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            a~budat IN ra_date                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz EQ space                                        AND
            c~kunnr IN so_kunnr                                     AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~kdgrp IN so_kdgrp                                     AND
            b~kvgr3 IN so_kvgr3                                     AND
            b~vtweg EQ '10'                                         AND
            b~vkbur IN r_vksap                                     AND
            b~spart EQ '00'                                         AND
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
           "d~kunn2 "d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad_real
      FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
            a~budat IN ra_date                                      AND
            a~augdt >= l_date1                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz EQ space                                        AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~vtweg EQ '10'                                         AND
            b~spart EQ '00'                                         AND
            b~vkbur IN r_vksap                                     AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            c~brsch IN so_brsch.
  ENDIF.

  IF x_norm EQ space AND x_shbv EQ 'X'.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1
           b~kdgrp b~vwerk b~vkbur b~kvgr3
           "d~kunn2 "d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid_real
      FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ a~bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            a~budat IN ra_date                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz IN s_bschl                                      AND
            c~kunnr IN so_kunnr                                     AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~kdgrp IN so_kdgrp                                     AND
            b~kvgr3 IN so_kvgr3                                     AND
            b~vtweg EQ '10'                                         AND
            b~vkbur IN r_vksap                                     AND
            b~spart EQ '00'                                         AND
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
           "d~kunn2 "d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad_real
      FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                     b~vkorg EQ pa_bukrs
                   JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*              LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                     d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
            a~budat IN ra_date                                      AND
            a~augdt >= l_date1                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz IN s_bschl                                      AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~vtweg EQ '10'                                         AND
            b~spart EQ '00'                                         AND
            b~vkbur IN r_vksap                                     AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            c~brsch IN so_brsch.
  ENDIF.

  DELETE i_itab_bsid_real WHERE NOT ( kdgrp IN so_kdgrp ).
  DELETE i_itab_bsad_real WHERE NOT ( kdgrp IN so_kdgrp ).

  DELETE i_itab_bsid_real WHERE NOT ( kvgr3 IN so_kvgr3 ).
  DELETE i_itab_bsad_real WHERE NOT ( kvgr3 IN so_kvgr3 ).

ENDFORM.                    " f_get_real_SAP
*&---------------------------------------------------------------------*
*&      Form  f_get_real_SAP_OPDR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_real_sap_opdr .
  DATA: l_date  TYPE sy-datum,
        l_date1 TYPE sy-datum.

  CONCATENATE pa_date(6) '01' INTO l_date1.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = pa_date
    IMPORTING
      last_day_of_month = l_date.

  l_date = l_date + 1.

  ra_date-sign   = 'I'.
  ra_date-option = 'BT'.
  ra_date-low    = l_date.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ra_date-low
    IMPORTING
      last_day_of_month = ra_date-high.
  APPEND ra_date.

  IF x_norm EQ 'X' AND x_shbv EQ 'X'.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1
           b~kdgrp b~vwerk b~kvgr3
           p~vkbur
           "d~kunn2 "d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid_real
      FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                       p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ a~bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            a~budat IN ra_date                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz EQ space                                        AND
            c~kunnr IN so_kunnr                                     AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~kdgrp IN so_kdgrp                                     AND
            b~kvgr3 IN so_kvgr3                                     AND
            b~vtweg EQ '10'                                         AND
            p~vkbur IN r_vksap                                     AND
            b~spart EQ '00'                                         AND
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1
           b~kdgrp b~vwerk b~kvgr3
           p~vkbur
           "d~kunn2 "d~pernr
      APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid_real
      FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                       p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ a~bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            a~budat IN ra_date                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz IN s_bschl                                      AND
            c~kunnr IN so_kunnr                                     AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~kdgrp IN so_kdgrp                                     AND
            b~kvgr3 IN so_kvgr3                                     AND
            b~vtweg EQ '10'                                         AND
            p~vkbur IN r_vksap                                     AND
            b~spart EQ '00'                                         AND
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1 b~kdgrp b~vwerk b~kvgr3
           p~vkbur
           "d~kunn2 "d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad_real
      FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                       p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
            a~budat IN ra_date                                      AND
            a~augdt >= l_date1                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz EQ space                                        AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~vtweg EQ '10'                                         AND
            b~spart EQ '00'                                         AND
            p~vkbur IN r_vksap                                     AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1 b~kdgrp b~vwerk b~kvgr3
           p~vkbur
           "d~kunn2 "d~pernr
      APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad_real
      FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                       p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
            a~budat IN ra_date                                      AND
            a~augdt >= l_date1                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz IN s_bschl                                      AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~vtweg EQ '10'                                         AND
            b~spart EQ '00'                                         AND
            p~vkbur IN r_vksap                                     AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            c~brsch IN so_brsch.
  ENDIF.

  IF x_norm EQ 'X' AND x_shbv EQ space.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1
           b~kdgrp b~vwerk b~kvgr3
           p~vkbur
           "d~kunn2 "d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid_real
      FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                       p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ a~bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            a~budat IN ra_date                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz EQ space                                        AND
            c~kunnr IN so_kunnr                                     AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~kdgrp IN so_kdgrp                                     AND
            b~kvgr3 IN so_kvgr3                                     AND
            b~vtweg EQ '10'                                         AND
            p~vkbur IN r_vksap                                     AND
            b~spart EQ '00'                                         AND
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1 b~kdgrp b~vwerk b~kvgr3
           p~vkbur
           "d~kunn2 "d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad_real
      FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                       p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
            a~budat IN ra_date                                      AND
            a~augdt >= l_date1                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz EQ space                                        AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~vtweg EQ '10'                                         AND
            b~spart EQ '00'                                         AND
            p~vkbur IN r_vksap                                     AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            c~brsch IN so_brsch.
  ENDIF.

  IF x_norm EQ space AND x_shbv EQ 'X'.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1
           b~kdgrp b~vwerk b~kvgr3
           p~vkbur
           "d~kunn2 "d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid_real
      FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                       p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ a~bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            a~budat IN ra_date                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz IN s_bschl                                      AND
            c~kunnr IN so_kunnr                                     AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~kdgrp IN so_kdgrp                                     AND
            b~kvgr3 IN so_kvgr3                                     AND
            b~vtweg EQ '10'                                         AND
            p~vkbur IN r_vksap                                     AND
            b~spart EQ '00'                                         AND
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1 b~kdgrp b~vwerk b~kvgr3
           p~vkbur
           "d~kunn2 "d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad_real
      FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                       p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*              LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                     d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
            a~budat IN ra_date                                      AND
            a~augdt >= l_date1                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz IN s_bschl                                      AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~vtweg EQ '10'                                         AND
            b~spart EQ '00'                                         AND
            p~vkbur IN r_vksap                                     AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            c~brsch IN so_brsch.
  ENDIF.

  DELETE i_itab_bsid_real WHERE NOT ( kdgrp IN so_kdgrp ).
  DELETE i_itab_bsad_real WHERE NOT ( kdgrp IN so_kdgrp ).

  DELETE i_itab_bsid_real WHERE NOT ( kvgr3 IN so_kvgr3 ).
  DELETE i_itab_bsad_real WHERE NOT ( kvgr3 IN so_kvgr3 ).

ENDFORM.                    " f_get_real_SAP_OPDR
*&---------------------------------------------------------------------*
*&      Form  f_get_real_Leg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_real_leg .

  DATA: l_date  TYPE sy-datum,
        l_date1 TYPE sy-datum.

  CONCATENATE pa_date(6) '01' INTO l_date1.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = pa_date
    IMPORTING
      last_day_of_month = l_date.

  l_date = l_date + 1.

  ra_date-sign   = 'I'.
  ra_date-option = 'BT'.
  ra_date-low    = l_date.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ra_date-low
    IMPORTING
      last_day_of_month = ra_date-high.
  APPEND ra_date.

  IF x_norm EQ 'X' AND x_shbv EQ 'X'.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1
           b~kdgrp b~vwerk b~vkbur b~kvgr3
           d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid_real
      FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ a~bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            a~budat IN ra_date                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz EQ space                                        AND
            c~kunnr IN so_kunnr                                     AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~kdgrp IN so_kdgrp                                     AND
            b~kvgr3 IN so_kvgr3                                     AND
            b~vtweg EQ '10'                                         AND
            b~vkbur IN r_vkleg                                     AND
            b~spart EQ '00'                                         AND
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1
           b~kdgrp b~vwerk b~vkbur b~kvgr3
           d~pernr
      APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid_real
      FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ a~bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            a~budat IN ra_date                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz IN s_bschl                                      AND
            c~kunnr IN so_kunnr                                     AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~kdgrp IN so_kdgrp                                     AND
            b~kvgr3 IN so_kvgr3                                     AND
            b~vtweg EQ '10'                                         AND
            b~vkbur IN r_vkleg                                     AND
            b~spart EQ '00'                                         AND
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
           d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad_real
      FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
            a~budat IN ra_date                                      AND
            a~augdt >= l_date1                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz EQ space                                        AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~vtweg EQ '10'                                         AND
            b~spart EQ '00'                                         AND
            b~vkbur IN r_vkleg                                     AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
           d~pernr
      APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad_real
      FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
            a~budat IN ra_date                                      AND
            a~augdt >= l_date1                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz IN s_bschl                                      AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~vtweg EQ '10'                                         AND
            b~spart EQ '00'                                         AND
            b~vkbur IN r_vkleg                                     AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            c~brsch IN so_brsch.
  ENDIF.

  IF x_norm EQ 'X' AND x_shbv EQ space.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1
           b~kdgrp b~vwerk b~vkbur b~kvgr3
           d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid_real
      FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ a~bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            a~budat IN ra_date                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz EQ space                                        AND
            c~kunnr IN so_kunnr                                     AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~kdgrp IN so_kdgrp                                     AND
            b~kvgr3 IN so_kvgr3                                     AND
            b~vtweg EQ '10'                                         AND
            b~vkbur IN r_vkleg                                     AND
            b~spart EQ '00'                                         AND
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
           d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad_real
      FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
            a~budat IN ra_date                                      AND
            a~augdt >= l_date1                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz EQ space                                        AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~vtweg EQ '10'                                         AND
            b~spart EQ '00'                                         AND
            b~vkbur IN r_vkleg                                     AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            c~brsch IN so_brsch.
  ENDIF.

  IF x_norm EQ space AND x_shbv EQ 'X'.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1
           b~kdgrp b~vwerk b~vkbur b~kvgr3
           d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid_real
      FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ a~bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            a~budat IN ra_date                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz IN s_bschl                                      AND
            c~kunnr IN so_kunnr                                     AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~kdgrp IN so_kdgrp                                     AND
            b~kvgr3 IN so_kvgr3                                     AND
            b~vtweg EQ '10'                                         AND
            b~vkbur IN r_vkleg                                     AND
            b~spart EQ '00'                                         AND
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
           d~pernr
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad_real
      FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                     b~vkorg EQ pa_bukrs
                   JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
            a~budat IN ra_date                                      AND
            a~augdt >= l_date1                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz IN s_bschl                                      AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~vtweg EQ '10'                                         AND
            b~spart EQ '00'                                         AND
            b~vkbur IN r_vkleg                                     AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            c~brsch IN so_brsch.
  ENDIF.

  DELETE i_itab_bsid_real WHERE NOT ( kdgrp IN so_kdgrp ).
  DELETE i_itab_bsad_real WHERE NOT ( kdgrp IN so_kdgrp ).

  DELETE i_itab_bsid_real WHERE NOT ( kvgr3 IN so_kvgr3 ).
  DELETE i_itab_bsad_real WHERE NOT ( kvgr3 IN so_kvgr3 ).

ENDFORM.                    " f_get_real_Leg
*&---------------------------------------------------------------------*
*&      Form  f_get_real_Leg_OPDR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_real_leg_opdr .

  DATA: l_date  TYPE sy-datum,
        l_date1 TYPE sy-datum.

  CONCATENATE pa_date(6) '01' INTO l_date1.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = pa_date
    IMPORTING
      last_day_of_month = l_date.

  l_date = l_date + 1.

  ra_date-sign   = 'I'.
  ra_date-option = 'BT'.
  ra_date-low    = l_date.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ra_date-low
    IMPORTING
      last_day_of_month = ra_date-high.
  APPEND ra_date.

  IF x_norm EQ 'X' AND x_shbv EQ 'X'.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1
           b~kdgrp b~vwerk b~kvgr3
           d~pernr
           p~vkbur
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid_real
      FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                       p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ a~bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            a~budat IN ra_date                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz EQ space                                        AND
            c~kunnr IN so_kunnr                                     AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~kdgrp IN so_kdgrp                                     AND
            b~kvgr3 IN so_kvgr3                                     AND
            b~vtweg EQ '10'                                         AND
            p~vkbur IN r_vkleg                                     AND
            b~spart EQ '00'                                         AND
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1
           b~kdgrp b~vwerk b~kvgr3
           d~pernr
           p~vkbur
      APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid_real
      FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                       p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ a~bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            a~budat IN ra_date                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz IN s_bschl                                      AND
            c~kunnr IN so_kunnr                                     AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~kdgrp IN so_kdgrp                                     AND
            b~kvgr3 IN so_kvgr3                                     AND
            b~vtweg EQ '10'                                         AND
            p~vkbur IN r_vkleg                                     AND
            b~spart EQ '00'                                         AND
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1 b~kdgrp b~vwerk b~kvgr3
           d~pernr
           p~vkbur
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad_real
      FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                       p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
            a~budat IN ra_date                                      AND
            a~augdt >= l_date1                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz EQ space                                        AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~vtweg EQ '10'                                         AND
            b~spart EQ '00'                                         AND
            p~vkbur IN r_vkleg                                     AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1 b~kdgrp b~vwerk b~kvgr3
           d~pernr
           p~vkbur
      APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad_real
      FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                       p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
            a~budat IN ra_date                                      AND
            a~augdt >= l_date1                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz IN s_bschl                                      AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~vtweg EQ '10'                                         AND
            b~spart EQ '00'                                         AND
            p~vkbur IN r_vkleg                                     AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            c~brsch IN so_brsch.
  ENDIF.

  IF x_norm EQ 'X' AND x_shbv EQ space.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1
           b~kdgrp b~vwerk b~kvgr3
           d~pernr
           p~vkbur
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid_real
      FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                       p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ a~bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            a~budat IN ra_date                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz EQ space                                        AND
            c~kunnr IN so_kunnr                                     AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~kdgrp IN so_kdgrp                                     AND
            b~kvgr3 IN so_kvgr3                                     AND
            b~vtweg EQ '10'                                         AND
            p~vkbur IN r_vkleg                                     AND
            b~spart EQ '00'                                         AND
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1 b~kdgrp b~vwerk b~kvgr3
           d~pernr
           p~vkbur
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad_real
      FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                       p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
            a~budat IN ra_date                                      AND
            a~augdt >= l_date1                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz EQ space                                        AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~vtweg EQ '10'                                         AND
            b~spart EQ '00'                                         AND
            p~vkbur IN r_vkleg                                     AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            c~brsch IN so_brsch.
  ENDIF.

  IF x_norm EQ space AND x_shbv EQ 'X'.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1
           b~kdgrp b~vwerk b~kvgr3
           d~pernr
           p~vkbur
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid_real
      FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                       p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ a~bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            a~budat IN ra_date                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz IN s_bschl                                      AND
            c~kunnr IN so_kunnr                                     AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~kdgrp IN so_kdgrp                                     AND
            b~kvgr3 IN so_kvgr3                                     AND
            b~vtweg EQ '10'                                         AND
            p~vkbur IN r_vkleg                                     AND
            b~spart EQ '00'                                         AND
            c~brsch IN so_brsch.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
           a~xref1 a~xref2 a~blart a~zterm a~anln1
           c~name1 b~kdgrp b~vwerk b~kvgr3
           d~pernr
           p~vkbur
      INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad_real
      FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                       p~posnr = '000010'
                     JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                       d~parvw EQ 'ZP'
      WHERE a~bukrs EQ pa_bukrs                                     AND
            a~hkont IN ( SELECT saknr
                           FROM skat
                           WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                   ktopl EQ 'TSPC' )                AND
            a~budat IN ra_date                                      AND
            a~augdt >= l_date1                                      AND
            a~kunnr IN so_kunnr                                     AND
            a~umskz IN s_bschl                                      AND
            b~vkorg EQ pa_bukrs                                     AND
            b~kunnr IN so_kunnr                                     AND
            b~vtweg EQ '10'                                         AND
            b~spart EQ '00'                                         AND
            p~vkbur IN r_vkleg                                     AND
** Koreksi by budi 07/09/2006 Req. by SJT
*            a~blart EQ 'DZ'                                         AND
** Koreksi by budi 02/12/2008 Req. by SJT
*            a~blart IN ('DZ','DA')                                  AND
            a~blart IN ('DZ','DA','DR')                             AND
** End koreksi by budi 02/12/2008 Req. by SJT
** End koreksi by budi 07/09/2006 Req. by SJT
            c~brsch IN so_brsch.
  ENDIF.

  DELETE i_itab_bsid_real WHERE NOT ( kdgrp IN so_kdgrp ).
  DELETE i_itab_bsad_real WHERE NOT ( kdgrp IN so_kdgrp ).

  DELETE i_itab_bsid_real WHERE NOT ( kvgr3 IN so_kvgr3 ).
  DELETE i_itab_bsad_real WHERE NOT ( kvgr3 IN so_kvgr3 ).

ENDFORM.                    " f_get_real_Leg_OPDR
*&---------------------------------------------------------------------*
*&      Form  f_tambah_kunnr_real_sap
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_tambah_kunnr_real_sap .
  DATA: l_date  TYPE sy-datum,
        l_date1 TYPE sy-datum.

  DATA : lv_budat TYPE bsid-budat.

  IF i_zfarsoff_add_sap[] IS NOT INITIAL.
    CONCATENATE pa_date(6) '01' INTO l_date1.

    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = pa_date
      IMPORTING
        last_day_of_month = l_date.

    l_date = l_date + 1.

    ra_date-sign   = 'I'.
    ra_date-option = 'BT'.
    ra_date-low    = l_date.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = ra_date-low
      IMPORTING
        last_day_of_month = ra_date-high.
    APPEND ra_date.

    IF x_norm EQ 'X' AND x_shbv EQ 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur b~kvgr3
*             "d~kunn2
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                         d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsid_add_real
        FOR ALL ENTRIES IN i_zfarsoff_add_sap
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~blart IN ('DZ','DA','DR')                             AND
              a~budat IN ra_date                                      AND
              a~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              a~umskz EQ space                                        AND
              c~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              b~kdgrp IN so_kdgrp                                     AND
              b~kvgr3 IN so_kvgr3                                     AND
              b~vtweg EQ '10'                                         AND
              b~vkbur EQ i_zfarsoff_add_sap-zvkbur                       AND
              b~spart EQ '00'                                         AND
              c~brsch IN so_brsch.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur b~kvgr3
             "d~kunn2 "pernr
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                         d~parvw EQ 'ZP'
        APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add_real
        FOR ALL ENTRIES IN i_zfarsoff_add_sap
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~blart IN ('DZ','DA','DR')                             AND
              a~budat IN ra_date                                      AND
              a~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              a~umskz IN s_bschl                                      AND
              c~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              b~kdgrp IN so_kdgrp                                     AND
              b~kvgr3 IN so_kvgr3                                     AND
              b~vtweg EQ '10'                                         AND
              b~vkbur EQ i_zfarsoff_add_sap-zvkbur                       AND
              b~spart EQ '00'                                         AND
              c~brsch IN so_brsch.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
             "d~kunn2 "pernr
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                         d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsad_add_real
        FOR ALL ENTRIES IN i_zfarsoff_add_sap
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~budat IN ra_date                                      AND
              a~augdt >= l_date1                                      AND
              a~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              a~umskz EQ space                                        AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              b~vtweg EQ '10'                                         AND
              b~spart EQ '00'                                         AND
              b~vkbur EQ i_zfarsoff_add_sap-zvkbur                       AND
              a~blart IN ('DZ','DA','DR')                             AND
              c~brsch IN so_brsch.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
             "d~kunn2 "pernr
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                         d~parvw EQ 'ZP'
        APPENDING CORRESPONDING FIELDS OF TABLE t_bsad_add_real
        FOR ALL ENTRIES IN i_zfarsoff_add_sap
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~budat IN ra_date                                      AND
              a~augdt >= l_date1                                      AND
              a~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              a~umskz IN s_bschl                                      AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              b~vtweg EQ '10'                                         AND
              b~spart EQ '00'                                         AND
              b~vkbur EQ i_zfarsoff_add_sap-zvkbur                       AND
              a~blart IN ('DZ','DA','DR')                             AND
              c~brsch IN so_brsch.
    ENDIF.

    IF x_norm EQ 'X' AND x_shbv EQ space.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur b~kvgr3
             "d~kunn2 "pernr
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                         d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsid_add_real
        FOR ALL ENTRIES IN i_zfarsoff_add_sap
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~blart IN ('DZ','DA','DR')                             AND
              a~budat IN ra_date                                      AND
              a~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              a~umskz EQ space                                        AND
              c~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              b~kdgrp IN so_kdgrp                                     AND
              b~kvgr3 IN so_kvgr3                                     AND
              b~vtweg EQ '10'                                         AND
              b~vkbur EQ i_zfarsoff_add_sap-zvkbur                       AND
              b~spart EQ '00'                                         AND
              c~brsch IN so_brsch.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
             "d~kunn2 "pernr
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                         d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsad_add_real
        FOR ALL ENTRIES IN i_zfarsoff_add_sap
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~budat IN ra_date                                      AND
              a~augdt >= l_date1                                      AND
              a~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              a~umskz EQ space                                        AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              b~vtweg EQ '10'                                         AND
              b~spart EQ '00'                                         AND
              b~vkbur EQ i_zfarsoff_add_sap-zvkbur                       AND
              a~blart IN ('DZ','DA','DR')                             AND
              c~brsch IN so_brsch.
    ENDIF.

    IF x_norm EQ space AND x_shbv EQ 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur b~kvgr3
             "d~kunn2 "pernr
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                         d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsid_add_real
        FOR ALL ENTRIES IN i_zfarsoff_add_sap
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~blart IN ('DZ','DA','DR')                             AND
              a~budat IN ra_date                                      AND
              a~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              a~umskz IN s_bschl                                      AND
              c~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              b~kdgrp IN so_kdgrp                                     AND
              b~kvgr3 IN so_kvgr3                                     AND
              b~vtweg EQ '10'                                         AND
              b~vkbur EQ i_zfarsoff_add_sap-zvkbur                       AND
              b~spart EQ '00'                                         AND
              c~brsch IN so_brsch.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
             "d~kunn2 "pernr
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          LEFT JOIN knvp AS d ON d~kunnr EQ a~kunnr AND
*                                            d~parvw EQ 'ZC'
*                                            AND d~vkorg EQ pa_bukrs
*                LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
*                                       d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsad_add_real
        FOR ALL ENTRIES IN i_zfarsoff_add_sap
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~budat IN ra_date                                      AND
              a~augdt >= l_date1                                      AND
              a~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              a~umskz IN s_bschl                                      AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ i_zfarsoff_add_sap-kunnr                         AND
              b~vtweg EQ '10'                                         AND
              b~spart EQ '00'                                         AND
              b~vkbur EQ i_zfarsoff_add_sap-zvkbur                       AND
              a~blart IN ('DZ','DA','DR')                             AND
              c~brsch IN so_brsch.
    ENDIF.

***** Add delete BSAD jika tidak sesuai dengan kdgrp.
    DELETE t_bsad_add_real WHERE NOT ( kdgrp IN so_kdgrp ).
    DELETE t_bsad_add_real WHERE NOT ( kvgr3 IN so_kvgr3 ).
*****

    SORT t_bsid_add_real BY kunnr.
    SORT t_bsad_add_real BY kunnr.
    SORT t_zfarsoff_add BY kunnr.
    LOOP AT t_bsid_add_real INTO wa_itab.
      READ TABLE t_zfarsoff_add WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_budat  = t_zfarsoff_add-budat - 1.
        IF pa_date LT lv_budat.
          IF t_zfarsoff_add-zvkbur IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur.
            APPEND wa_itab TO i_itab_sap.
          ENDIF.
        ELSE.
          IF t_zfarsoff_add-zvkbur1 IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur1.
            APPEND wa_itab TO i_itab_sap.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.

    LOOP AT t_bsad_add_real INTO wa_itab.
      READ TABLE t_zfarsoff_add WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_budat  = t_zfarsoff_add-budat - 1.
        IF pa_date LT lv_budat.
          IF t_zfarsoff_add-zvkbur IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur.
            APPEND wa_itab TO i_itab_sap.
          ENDIF.
        ELSE.
          IF t_zfarsoff_add-zvkbur1 IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur1.
            APPEND wa_itab TO i_itab_sap.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " f_tambah_kunnr_real_sap
*&---------------------------------------------------------------------*
*&      Form  f_tambah_kunnr_real_leg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_tambah_kunnr_real_leg .

  DATA: l_date  TYPE sy-datum,
        l_date1 TYPE sy-datum.

  DATA : lv_budat TYPE bsid-budat.

  IF i_zfarsoff_add_leg[] IS NOT INITIAL.
    CONCATENATE pa_date(6) '01' INTO l_date1.

    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = pa_date
      IMPORTING
        last_day_of_month = l_date.

    l_date = l_date + 1.

    ra_date-sign   = 'I'.
    ra_date-option = 'BT'.
    ra_date-low    = l_date.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = ra_date-low
      IMPORTING
        last_day_of_month = ra_date-high.
    APPEND ra_date.

    IF x_norm EQ 'X' AND x_shbv EQ 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                         d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsid_add_real
        FOR ALL ENTRIES IN i_zfarsoff_add_leg
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~blart IN ('DZ','DA','DR')                             AND
              a~budat IN ra_date                                      AND
              a~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              a~umskz EQ space                                        AND
              c~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              b~kdgrp IN so_kdgrp                                     AND
              b~kvgr3 IN so_kvgr3                                     AND
              b~vtweg EQ '10'                                         AND
              b~vkbur EQ i_zfarsoff_add_leg-zvkbur                       AND
              b~spart EQ '00'                                         AND
              c~brsch IN so_brsch.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                         d~parvw EQ 'ZP'
        APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add_real
        FOR ALL ENTRIES IN i_zfarsoff_add_leg
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~blart IN ('DZ','DA','DR')                             AND
              a~budat IN ra_date                                      AND
              a~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              a~umskz IN s_bschl                                      AND
              c~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              b~kdgrp IN so_kdgrp                                     AND
              b~kvgr3 IN so_kvgr3                                     AND
              b~vtweg EQ '10'                                         AND
              b~vkbur EQ i_zfarsoff_add_leg-zvkbur                       AND
              b~spart EQ '00'                                         AND
              c~brsch IN so_brsch.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                         d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsad_add_real
        FOR ALL ENTRIES IN i_zfarsoff_add_leg
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~budat IN ra_date                                      AND
              a~augdt >= l_date1                                      AND
              a~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              a~umskz EQ space                                        AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              b~vtweg EQ '10'                                         AND
              b~spart EQ '00'                                         AND
              b~vkbur EQ i_zfarsoff_add_leg-zvkbur                       AND
              a~blart IN ('DZ','DA','DR')                             AND
              c~brsch IN so_brsch.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                         d~parvw EQ 'ZP'
        APPENDING CORRESPONDING FIELDS OF TABLE t_bsad_add_real
        FOR ALL ENTRIES IN i_zfarsoff_add_leg
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~budat IN ra_date                                      AND
              a~augdt >= l_date1                                      AND
              a~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              a~umskz IN s_bschl                                      AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              b~vtweg EQ '10'                                         AND
              b~spart EQ '00'                                         AND
              b~vkbur EQ i_zfarsoff_add_leg-zvkbur                       AND
              a~blart IN ('DZ','DA','DR')                             AND
              c~brsch IN so_brsch.
    ENDIF.

    IF x_norm EQ 'X' AND x_shbv EQ space.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                         d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsid_add_real
        FOR ALL ENTRIES IN i_zfarsoff_add_leg
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~blart IN ('DZ','DA','DR')                             AND
              a~budat IN ra_date                                      AND
              a~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              a~umskz EQ space                                        AND
              c~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              b~kdgrp IN so_kdgrp                                     AND
              b~kvgr3 IN so_kvgr3                                     AND
              b~vtweg EQ '10'                                         AND
              b~vkbur EQ i_zfarsoff_add_leg-zvkbur                       AND
              b~spart EQ '00'                                         AND
              c~brsch IN so_brsch.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ pa_bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                         d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsad_add_real
        FOR ALL ENTRIES IN i_zfarsoff_add_leg
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~budat IN ra_date                                      AND
              a~augdt >= l_date1                                      AND
              a~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              a~umskz EQ space                                        AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              b~vtweg EQ '10'                                         AND
              b~spart EQ '00'                                         AND
              b~vkbur EQ i_zfarsoff_add_leg-zvkbur                       AND
              a~blart IN ('DZ','DA','DR')                             AND
              c~brsch IN so_brsch.
    ENDIF.

    IF x_norm EQ space AND x_shbv EQ 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1
             b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ a~bukrs
                       JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                         d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsid_add_real
        FOR ALL ENTRIES IN i_zfarsoff_add_leg
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~blart IN ('DZ','DA','DR')                             AND
              a~budat IN ra_date                                      AND
              a~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              a~umskz IN s_bschl                                      AND
              c~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              b~kdgrp IN so_kdgrp                                     AND
              b~kvgr3 IN so_kvgr3                                     AND
              b~vtweg EQ '10'                                         AND
              b~vkbur EQ i_zfarsoff_add_leg-zvkbur                       AND
              b~spart EQ '00'                                         AND
              c~brsch IN so_brsch.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg c~brsch
             a~xref1 a~xref2 a~blart a~zterm a~anln1
             c~name1 b~kdgrp b~vwerk b~vkbur b~kvgr3
             d~pernr
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ pa_bukrs
                     JOIN kna1 AS c ON c~kunnr EQ a~kunnr
*                          left join knvp as d on d~kunnr eq a~kunnr and
*                                            d~parvw eq 'ZC'
*                                            and d~vkorg eq pa_bukrs
                  LEFT JOIN vbpa AS d ON a~belnr EQ d~vbeln AND
                                         d~parvw EQ 'ZP'
        INTO CORRESPONDING FIELDS OF TABLE t_bsad_add_real
        FOR ALL ENTRIES IN i_zfarsoff_add_leg
        WHERE a~bukrs EQ pa_bukrs                                     AND
              a~hkont IN ( SELECT saknr
                             FROM skat
                             WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                                     ktopl EQ 'TSPC' )                AND
              a~budat IN ra_date                                      AND
              a~augdt >= l_date1                                      AND
              a~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              a~umskz IN s_bschl                                      AND
              b~vkorg EQ pa_bukrs                                     AND
              b~kunnr EQ i_zfarsoff_add_leg-kunnr                         AND
              b~vtweg EQ '10'                                         AND
              b~spart EQ '00'                                         AND
              b~vkbur EQ i_zfarsoff_add_leg-zvkbur                       AND
              a~blart IN ('DZ','DA','DR')                             AND
              c~brsch IN so_brsch.
    ENDIF.

***** Add delete BSAD jika tidak sesuai dengan kdgrp.
    DELETE t_bsad_add_real WHERE NOT ( kdgrp IN so_kdgrp ).
    DELETE t_bsad_add_real WHERE NOT ( kvgr3 IN so_kvgr3 ).
*****

    SORT t_bsid_add_real BY kunnr.
    SORT t_bsad_add_real BY kunnr.
    SORT t_zfarsoff_add BY kunnr.
    LOOP AT t_bsid_add_real INTO wa_itab.
      READ TABLE t_zfarsoff_add WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_budat = t_zfarsoff_add-budat - 1.
        IF pa_date LT lv_budat.
          IF t_zfarsoff_add-zvkbur IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur.
            APPEND wa_itab TO i_itab_leg.
          ENDIF.
        ELSE.
          IF t_zfarsoff_add-zvkbur1 IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur.
            APPEND wa_itab TO i_itab_leg.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.

    LOOP AT t_bsad_add_real INTO wa_itab.
      READ TABLE t_zfarsoff_add WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_budat = t_zfarsoff_add-budat - 1.
        IF pa_date LT lv_budat.
          IF t_zfarsoff_add-zvkbur IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur.
            APPEND wa_itab TO i_itab_leg.
          ENDIF.
        ELSE.
          IF t_zfarsoff_add-zvkbur1 IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur1.
            APPEND wa_itab TO i_itab_leg.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.


ENDFORM.                    " f_tambah_kunnr_real_leg
*&---------------------------------------------------------------------*
*&      Form  f_gabung_real_sap
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_gabung_real_sap .

ENDFORM.                    " f_gabung_real_sap
*&---------------------------------------------------------------------*
*&      Form  f_gabung_real_leg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_gabung_real_leg .

ENDFORM.                    " f_gabung_real_leg
*&---------------------------------------------------------------------*
*&      Form  f_gabung_real
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_gabung_real .
  CLEAR: va_dmbtr.
  LOOP AT i_itab_sap INTO wa_itab_real.
    IF wa_itab_real-vwerk NE space.
      wa_itab_real-gsber = wa_itab_real-vwerk.
    ENDIF.
** Koreksi 13/11/2014
*    SELECT SINGLE kunn2 INTO wa_itab_real-kunn2
*           FROM knvp
*           WHERE kunnr = wa_itab_real-kunnr AND
*                 parvw EQ 'ZC'  AND
*                 vkorg EQ pa_bukrs.
*    IF sy-subrc EQ 0.
*      wa_itab_real-xref1 = wa_itab_real-kunn2.
*      SELECT SINGLE pernr INTO  wa_itab_real-pernr FROM knvp
*             WHERE kunnr = wa_itab_real-kunn2 AND
*                   parvw = 'ZP' AND
*                   vkorg = pa_bukrs.
*    ELSE.
*      CLEAR: wa_itab_real-xref1, wa_itab_real-pernr.
*    ENDIF.
    IF wa_itab_real-xref1 IS INITIAL.
      SELECT SINGLE kunn2 INTO wa_itab_real-kunn2
             FROM knvp
             WHERE kunnr = wa_itab_real-kunnr AND
                   parvw EQ 'ZC'  AND
                   vkorg EQ pa_bukrs.
      IF sy-subrc EQ 0.
        wa_itab_real-xref1 = wa_itab_real-kunn2.
      ENDIF.
    ENDIF.
    SELECT SINGLE pernr INTO  wa_itab_real-pernr FROM knvp
            WHERE kunnr = wa_itab_real-xref1 AND
                  parvw = 'ZP' AND
                  vkorg = pa_bukrs.
** End Koreksi 13/11/2014

    MODIFY i_itab_sap FROM wa_itab_real TRANSPORTING gsber pernr xref1 kunn2.
  ENDLOOP.

  CLEAR: va_dmbtr.
  LOOP AT i_itab_leg INTO wa_itab_real.
    IF wa_itab_real-vwerk NE space.
      wa_itab_real-gsber = wa_itab_real-vwerk.
    ENDIF.

    IF wa_itab_real-blart NE 'RV'.
      wa_itab_real-pernr = wa_itab_real-xref2.
    ENDIF.
    MODIFY i_itab_leg FROM wa_itab_real TRANSPORTING gsber pernr.
  ENDLOOP.

ENDFORM.                    " f_gabung_real

*&---------------------------------------------------------------------*
*&      Form  f_modify_itab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_itab_sap.
  DATA: lw_itab   TYPE t_itab,
        ld_tabix  LIKE sy-tabix,
        ld_zuonr  LIKE bsid-zuonr.

  i_itab_temp[] = i_itab_sap[].
  CLEAR: i_itab_sap.
  REFRESH: i_itab_sap.

* Target Remmitance
  IF i_itab_temp[] IS NOT INITIAL.

    SORT i_itab_temp BY bukrs vkbur zuonr zfbdt blart.
    LOOP AT i_itab_temp INTO wa_itab.
      IF wa_itab-shkzg EQ 'H'.
        wa_itab-dmbtr  = wa_itab-dmbtr * -1.
      ENDIF.
      IF wa_itab-blart NE 'RV'.
        ld_zuonr  = wa_itab-zuonr(10).
        READ TABLE i_itab_temp INTO lw_itab WITH KEY zuonr = ld_zuonr
                                                     blart = 'RV'.
        IF sy-subrc EQ 0.
          wa_itab-budat  = lw_itab-budat.
          wa_itab-bldat  = lw_itab-bldat.
          wa_itab-gjahr  = lw_itab-gjahr.
          wa_itab-xref2  = lw_itab-xref2.
          wa_itab-zbd1t  = lw_itab-zbd1t.
          wa_itab-zfbdt  = lw_itab-zfbdt.
          wa_itab-zterm  = lw_itab-zterm.
          wa_itab-xref1  = lw_itab-xref1.
          wa_itab-pernr  = lw_itab-pernr.
          wa_itab-kunn2  = lw_itab-kunn2.
        ENDIF.
      ENDIF.
      CLEAR: wa_itab-shkzg, wa_itab-blart, wa_itab-belnr.
      COLLECT wa_itab INTO i_itab_sap.
      CLEAR: wa_itab, lw_itab.
    ENDLOOP.

    CLEAR: wa_itab, lw_itab.
    LOOP AT i_itab_sap INTO wa_itab.
      IF wa_itab-dmbtr LT 0.
        wa_itab-dmbtr = wa_itab-dmbtr * -1.
        wa_itab-shkzg = 'H'.
      ELSE.
        wa_itab-shkzg  = 'S'.
      ENDIF.
      MODIFY i_itab_sap FROM wa_itab.
    ENDLOOP.
  ENDIF.

* Realization
*  if i_itab_real_temp[] is not initial.
*    sort i_itab_real_temp by bukrs vkbur zuonr zfbdt blart.
*    loop at i_itab_real_temp into wa_itab.
*      clear: wa_itab, lw_itab.
*    endloop.
*
*    clear: wa_itab, lw_itab.
*    loop at i_itab_real into wa_itab.
*      if wa_itab-dmbtr lt 0.
*        wa_itab-dmbtr = wa_itab-dmbtr * -1.
*        wa_itab-shkzg = 'H'.
*      else.
*        wa_itab-shkzg  = 'S'.
*      endif.
*      modify i_itab_real from wa_itab.
*    endloop.
*  endif.
  CLEAR: i_itab_temp, i_itab_real_temp. REFRESH: i_itab_temp, i_itab_real_temp.
ENDFORM.                    " f_modify_itab
*&---------------------------------------------------------------------*
*&      Form  f_modify_itab_leg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_itab_leg .
  DATA: lw_itab   TYPE t_itab,
        lw_itab1   TYPE t_itab,
        ld_tabix  LIKE sy-tabix,
        ld_zuonr  LIKE bsid-zuonr,
        l_sw(1), l_blart(1),
        l_dmbtr LIKE wa_itab-dmbtr,
        l_itab_temp TYPE t_itab OCCURS 0,

        l_value LIKE wa_itab-value..

  i_itab_temp[] = i_itab_leg[].
  l_itab_temp[] = i_itab_leg[].
  DELETE i_itab_temp WHERE zuonr EQ space.
  DELETE l_itab_temp WHERE zuonr NE space.

  CLEAR: i_itab_leg.
  REFRESH: i_itab_leg.

* Target Remmitance
  IF i_itab_temp[] IS NOT INITIAL.

    SORT i_itab_temp BY bukrs vkbur zuonr zfbdt blart.
    l_sw = '0'.
    CLEAR: l_blart, l_dmbtr, l_value.
    LOOP AT i_itab_temp INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-vkbur OR
                   wa_itab-zuonr.
        IF l_sw = '1'.
          IF l_blart = '1'.
            lw_itab1-dmbtr = l_dmbtr.
            lw_itab1-value = l_value.
            CLEAR: lw_itab1-shkzg, lw_itab1-blart, lw_itab1-belnr.
            APPEND lw_itab1 TO i_itab_leg.
          ELSE.
            lw_itab-dmbtr = l_dmbtr.
            lw_itab-value = l_value.
            CLEAR: lw_itab-shkzg, lw_itab-blart, lw_itab-belnr.
            APPEND lw_itab TO i_itab_leg .
          ENDIF.
          CLEAR: lw_itab1, lw_itab, l_blart, l_dmbtr, l_value.
        ENDIF.
      ENDON.
      l_sw = '1'.
      IF wa_itab-blart = 'ZA'.
        MOVE-CORRESPONDING wa_itab TO lw_itab1.
        l_blart = '1'.
      ELSE.
        MOVE-CORRESPONDING wa_itab TO lw_itab.
      ENDIF.
      IF wa_itab-shkzg EQ 'H'.
        wa_itab-dmbtr  = wa_itab-dmbtr * -1.
      ENDIF.
      ADD wa_itab-dmbtr TO l_dmbtr.
      ADD wa_itab-value TO l_value.
      CLEAR: wa_itab.
*      IF wa_itab-blart NE 'ZA'.
*        ld_zuonr  = wa_itab-zuonr(10).
*        READ TABLE i_itab_temp INTO lw_itab WITH KEY zuonr = ld_zuonr
*                                                     blart = 'ZA'.
*        IF sy-subrc EQ 0.
*          wa_itab-budat  = lw_itab-budat.
*          wa_itab-bldat  = lw_itab-bldat.
*          wa_itab-gjahr  = lw_itab-gjahr.
*          wa_itab-xref2  = lw_itab-xref2.
*          wa_itab-zbd1t  = lw_itab-zbd1t.
*          wa_itab-zfbdt  = lw_itab-zfbdt.
*          wa_itab-zterm  = lw_itab-zterm.
*          wa_itab-xref1  = lw_itab-xref1.
*          wa_itab-pernr  = lw_itab-pernr.
*          wa_itab-kunn2  = lw_itab-kunn2.
*        ENDIF.
*      ENDIF.
*      CLEAR: wa_itab-shkzg, wa_itab-blart, wa_itab-belnr.
*      COLLECT wa_itab INTO i_itab_leg.
    ENDLOOP.
    IF l_sw = '1'.
      IF l_blart = '1'.
        lw_itab1-dmbtr = l_dmbtr.
        lw_itab1-value = l_value.
        CLEAR: lw_itab1-shkzg, lw_itab1-blart, lw_itab1-belnr.
        APPEND lw_itab1 TO i_itab_leg.
      ELSE.
        lw_itab-dmbtr = l_dmbtr.
        lw_itab-value = l_value.
        CLEAR: lw_itab-shkzg, lw_itab-blart, lw_itab-belnr.
        APPEND lw_itab TO i_itab_leg .
      ENDIF.
      CLEAR: lw_itab1, lw_itab.
    ENDIF.
    APPEND LINES OF l_itab_temp TO i_itab_leg.
    CLEAR: wa_itab, lw_itab.
    LOOP AT i_itab_leg INTO wa_itab.
      IF wa_itab-dmbtr LT 0.
        wa_itab-dmbtr = wa_itab-dmbtr * -1.
        wa_itab-shkzg = 'H'.
      ELSE.
        wa_itab-shkzg  = 'S'.
      ENDIF.
      MODIFY i_itab_leg FROM wa_itab.
    ENDLOOP.
  ENDIF.
  CLEAR: i_itab_temp.
  REFRESH: i_itab_temp.

ENDFORM.                    " f_modify_itab_leg
*&---------------------------------------------------------------------*
*&      Form  f_proses81
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses81 .
*DATA: l_itab TYPE t_itab OCCURS 0 with header line,
*      l_itab_real TYPE t_itab OCCURS 0 with header line.
*
*   refresh: l_itab, l_itab_real.
*    append lines of i_itab to l_itab.
*    append lines of i_itab_real to l_itab_real.
*
*CALL FUNCTION 'WS_DOWNLOAD'
*   EXPORTING
*        FILENAME        = p_file
*        FILETYPE        = 'ASC'
*   IMPORTING
*        FILELENGTH      = FILESIZE
*   TABLES
*        DATA_TAB        = l_itab
*   EXCEPTIONS
*        FILE_OPEN_ERROR = 1
*        OTHERS          = 2.
*
*CALL FUNCTION 'WS_DOWNLOAD'
*   EXPORTING
*        FILENAME        = p_file1
*        FILETYPE        = 'ASC'
*   IMPORTING
*        FILELENGTH      = FILESIZE
*   TABLES
*        DATA_TAB        = l_itab_real
*   EXCEPTIONS
*        FILE_OPEN_ERROR = 1
*        OTHERS          = 2.

ENDFORM.                    " f_proses81

*&---------------------------------------------------------------------*
*&      Form  F_GET_HEADER_WEEK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_header_week .
  DATA: ld_date   TYPE sy-datum,
        ld_date1  TYPE sy-datum,
        ld_date2  TYPE sy-datum.

  PERFORM f_get_week.
  ld_date1  = va_sunday + 1.
  ra_headw1-low     = '00000000'.
  ra_headw1-high    = va_sunday.
  ra_headw1-sign    = 'I'.
  ra_headw1-option  = 'BT'.
  APPEND ra_headw1.

  ld_date2 = ld_date1 + 6.
  ra_headw2-low     = ld_date1.
  ra_headw2-high    = ld_date2.
  ra_headw2-sign    = 'I'.
  ra_headw2-option  = 'BT'.
  APPEND ra_headw2.

  ld_date1  = ld_date2 + 1.
  ld_date2  = ld_date1 + 6.
  ra_headw3-low     = ld_date1.
  ra_headw3-high    = ld_date2.
  ra_headw3-sign    = 'I'.
  ra_headw3-option  = 'BT'.
  APPEND ra_headw3.

  IF ld_date2(6) NE ld_date1(6).
    ld_date2 = va_date1.
  ENDIF.

  ld_date1  = ld_date2 + 1.
  ld_date2  = ld_date1 + 6.
  ra_headw4-low     = ld_date1.
  ra_headw4-high    = ld_date2.
  ra_headw4-sign    = 'I'.
  ra_headw4-option  = 'BT'.
  APPEND ra_headw4.

  ld_date1  = ld_date2 + 1.
  ld_date2  = va_date1.
  IF ld_date2(6) EQ ld_date1(6).
    ra_headw5-low     = ld_date1.
    ra_headw5-high    = ld_date2.
    ra_headw5-sign    = 'I'.
    ra_headw5-option  = 'BT'.
    APPEND ra_headw5.
  ENDIF.
ENDFORM.                    " F_GET_HEADER_WEEK

*&---------------------------------------------------------------------*
*&      Form  F_TARGET_SALES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_target_sales .
  DATA:  l_spmon LIKE ztgtsls-spmon,
         l_top   TYPE i.

  l_spmon = va_tanggal(6).

  IF r_vksap[] IS NOT INITIAL.
    SELECT a~spmon  a~pkunwe a~kvgr2 d~kdgrp a~vkbur a~waerk a~value a~ztop
                 c~name1 c~brsch                            "b~kunn2
                 INTO CORRESPONDING FIELDS OF TABLE i_target
                 FROM ztgtsls AS a
                      JOIN kna1 AS c ON c~kunnr EQ a~pkunwe
                      JOIN knvv AS d ON a~pkunwe EQ d~kunnr AND
                                         d~vkorg EQ pa_bukrs
                 WHERE a~spmon EQ l_spmon AND
                       a~vkbur IN r_vksap AND
                       a~pkunwe IN so_kunnr AND
                       d~kdgrp IN so_kdgrp AND
                       c~brsch IN so_brsch  AND
                       c~kunnr IN so_kunnr.
    IF sy-subrc NE 0.
      va_data = 'X'.
    ENDIF.

    CLEAR: wa_itab.
    LOOP AT i_target WHERE vkbur IN r_vksap.
*      wa_itab-bukrs = '8020'.
      wa_itab-bukrs = pa_bukrs.
      wa_itab-vkbur = i_target-vkbur.
      wa_itab-kdgrp = i_target-kdgrp.
      wa_itab-kunnr = i_target-pkunwe.
      wa_itab-brsch = i_target-brsch.
      wa_itab-shkzg = 'S'.
      wa_itab-zfbdt = '00000000'.
      wa_itab-zterm = i_target-ztop.
      l_top = 30 - i_target-ztop.
      READ TABLE t_zftop WITH KEY bukrs = wa_itab-bukrs
                                  kvgr3 = wa_itab-kvgr3.
      IF sy-subrc EQ 0.
        va_act  = t_zftop-actual.
      ELSE.
        CLEAR: va_act.
      ENDIF.

      IF l_top > 0.
        wa_itab-value =  ( ( l_top / 30 ) * i_target-value ) * ( va_act / 100 ).
      ELSE.
        wa_itab-value =  0.
      ENDIF.
      wa_itab-vwerk = i_target-vkbur.
      wa_itab-name1 = i_target-name1.
      APPEND wa_itab TO i_itab_sap.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.

  IF r_vkleg[] IS NOT INITIAL.
    SELECT a~spmon  a~pkunwe a~kvgr2 d~kdgrp a~vkbur a~waerk a~value a~ztop
                 c~name1 c~brsch                            "b~kunn2
                 APPENDING CORRESPONDING FIELDS OF TABLE i_target
                 FROM ztgtsls AS a
                      JOIN kna1 AS c ON c~kunnr EQ a~pkunwe
                      JOIN knvv AS d ON a~pkunwe EQ d~kunnr AND
                                         d~vkorg EQ pa_bukrs
                 WHERE a~spmon EQ l_spmon AND
                       a~vkbur IN r_vkleg AND
                       d~kdgrp IN so_kdgrp AND
                       a~pkunwe IN so_kunnr AND
                       c~brsch IN so_brsch  AND
                       c~kunnr IN so_kunnr.
    IF sy-subrc NE 0.
      va_data = 'X'.
    ENDIF.

    CLEAR: wa_itab.
    LOOP AT i_target WHERE vkbur IN r_vkleg.
*      wa_itab-bukrs = '8020'.
      wa_itab-bukrs = pa_bukrs.
      wa_itab-vkbur = i_target-vkbur.
      wa_itab-kdgrp = i_target-kdgrp.
      wa_itab-kunnr = i_target-pkunwe.
      wa_itab-xref1 = i_target-kunn2.
      wa_itab-brsch = i_target-brsch.
      wa_itab-shkzg = 'S'.
      wa_itab-zfbdt = '00000000'.
      wa_itab-zterm = i_target-ztop.
      l_top = 30 - i_target-ztop.

      READ TABLE t_zftop WITH KEY bukrs = wa_itab-bukrs
                                  kvgr3 = wa_itab-kvgr3.
      IF sy-subrc EQ 0.
        va_act  = t_zftop-actual.
      ELSE.
        CLEAR: va_act.
      ENDIF.

      IF l_top > 0.
        wa_itab-value =  ( ( l_top / 30 ) * i_target-value ) * ( va_act / 100 ).
      ELSE.
        wa_itab-value =  0.
      ENDIF.
      wa_itab-vwerk = i_target-vkbur.
      wa_itab-name1 = i_target-name1.
      APPEND wa_itab TO i_itab_leg.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_TARGET_SALES

*&---------------------------------------------------------------------*
*&      Form  F_PROSES8
*&---------------------------------------------------------------------*
FORM f_proses8 .
  DATA: l_vkbur LIKE i_delete-vkbur,
        bezei   LIKE tvv3t-bezei.

  CLEAR: i_delete. REFRESH: i_delete.
  CLEAR l3_text.
  IF i_result8 IS INITIAL.
    SORT i_itab BY bukrs vkbur kvgr3 kunnr.
    CLEAR: wa_itab, wa_result, i_result8.
    LOOP AT i_itab INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-vkbur OR
                   wa_itab-kvgr3.
        IF wa_result-kvgr3 NE space.
          wa_result-collect = wa_result-outstanding.
          wa_result-total_r = wa_result-week1 + wa_result-week2 +
                              wa_result-week3 + wa_result-week4 +
                              wa_result-week5 + wa_result-sales1.
          APPEND wa_result TO i_result8.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-kvgr3 TO wa_result-kvgr3.
      MOVE wa_itab-name1 TO wa_result-name1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.
    IF wa_result-kvgr3 NE space.
      wa_result-collect = wa_result-outstanding.
      wa_result-total_r = wa_result-week1 + wa_result-week2 +
                          wa_result-week3 + wa_result-week4 +
                          wa_result-week5 + wa_result-sales1.
      APPEND wa_result TO i_result8.
      CLEAR wa_result.
    ENDIF.
  ENDIF.

  IF pa_real EQ 'X'.
    IF i_result8_real IS INITIAL.
      SORT i_itab_real BY bukrs vkbur kvgr3 kunnr.
      CLEAR: wa_itab_real, wa_result_real, i_result8_real.
      LOOP AT i_itab_real INTO wa_itab_real.
        ON CHANGE OF wa_itab_real-bukrs OR
                     wa_itab_real-vkbur OR
                     wa_itab_real-kvgr3.
          IF wa_result_real-kvgr3 NE space.
            wa_result_real-collect = wa_result_real-outstanding.
            wa_result_real-total_r = wa_result_real-week1 +
                                     wa_result_real-week2 +
                                     wa_result_real-week3 +
                                     wa_result_real-week4 +
                                     wa_result_real-week5 +
                                     wa_result_real-sales1.
            APPEND wa_result_real TO i_result8_real.
            CLEAR wa_result_real.
          ENDIF.
        ENDON.
        MOVE wa_itab_real-bukrs TO wa_result_real-bukrs.
        MOVE wa_itab_real-vkbur TO wa_result_real-vkbur.
        MOVE wa_itab_real-kunnr TO wa_result_real-kunnr.
        MOVE wa_itab_real-kvgr3 TO wa_result_real-kvgr3.
        MOVE wa_itab_real-name1 TO wa_result_real-name1.
        PERFORM f_hitung_real.
        CLEAR wa_itab_real.
      ENDLOOP.
      IF wa_result_real-kdgrp NE space.
        wa_result_real-collect = wa_result_real-outstanding.
        wa_result_real-total_r = wa_result_real-week1 +
                                 wa_result_real-week2 +
                                 wa_result_real-week3 +
                                 wa_result_real-week4 +
                                 wa_result_real-week5 +
                                 wa_result_real-sales1.
        APPEND wa_result_real TO i_result8_real.
        CLEAR wa_result_real.
      ENDIF.
    ENDIF.
    i_delete[] = i_result8_real[].
  ENDIF.

* cetak
  CLEAR: va_nou, wa_total, wa_subtotal, wa_sub_real, wa_total_real.
  v_current_page = 1.

  IF pa_real EQ 'X' AND
    pa_targe EQ space.
    SORT i_result8_real BY bukrs vkbur kvgr3.
    LOOP AT i_result8_real INTO wa_result.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-vkbur tvkbt-bezei
            INTO va_text SEPARATED BY '-'.
        WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
        c1 = c1 + 1. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        PERFORM f_write_kosong.
      ENDAT.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      SELECT SINGLE bezei
        FROM tvv3t
        INTO bezei
        WHERE kvgr3 EQ wa_result-kvgr3 AND
            ( spras EQ 'EN' OR spras EQ 'E' ).
      CONCATENATE wa_result-kvgr3 bezei
          INTO l8_text SEPARATED BY '-'.
      CONCATENATE 'Real :' l8_text
          INTO l8_text SEPARATED BY space.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) l8_text NO-GAP HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail_real.

      AT END OF vkbur.
        CONCATENATE 'Sub Total' va_text INTO l3_text
          SEPARATED BY space.
        PERFORM f_write_subtotal_real USING l3_text.
        CLEAR: wa_subtotal, va_nou.
      ENDAT.
      CLEAR wa_result.
    ENDLOOP.
  ELSE.
    SORT i_result8 BY bukrs vkbur kvgr3.
    SORT i_result8_real BY bukrs vkbur kvgr3.
    SORT i_delete BY bukrs vkbur kvgr3.
    LOOP AT i_result8 INTO wa_result.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur AND
              ( spras EQ 'EN' OR spras EQ 'E' ).
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-vkbur tvkbt-bezei
            INTO va_text SEPARATED BY '-'.
        WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
        c1 = c1 + 1. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        PERFORM f_write_kosong.
        l_vkbur = wa_result-vkbur.
      ENDAT.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      SELECT SINGLE bezei
        FROM tvv3t
        INTO bezei
        WHERE kvgr3 EQ wa_result-kvgr3 AND
            ( spras EQ 'EN' OR spras EQ 'E' ).
      CONCATENATE wa_result-kvgr3 bezei
          INTO l8_text SEPARATED BY '-'.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) l8_text NO-GAP HOTSPOT. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      SET LEFT SCROLL-BOUNDARY.
      PERFORM f_write_detail.

      IF pa_real EQ 'X'.
        READ TABLE i_result8_real INTO wa_result
          WITH KEY vkbur = wa_result-vkbur
                   kvgr3 = wa_result-kvgr3
          BINARY SEARCH.

        IF sy-subrc EQ 0.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
          CONCATENATE wa_result-kvgr3 bezei
            INTO l8_text SEPARATED BY '-'.
          CONCATENATE '     Real :' l8_text
            INTO l8_text SEPARATED BY space.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) l8_text NO-GAP HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_real.
          DELETE i_delete WHERE vkbur EQ wa_result-vkbur AND
                                kvgr3 EQ wa_result-kvgr3.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ELSE.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
          CONCATENATE wa_result-kvgr3 bezei
            INTO l8_text SEPARATED BY '-'.
          CONCATENATE '     Real :' l8_text
            INTO l8_text SEPARATED BY space.
          c1 = 1.
          WRITE: /  sy-vline.
          c1 = c1 + 1.
          WRITE AT c1(w1) space NO-GAP. c1 = c1 + w1.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          WRITE AT c1(w2) l8_text NO-GAP HOTSPOT. c1 = c1 + w2.
          WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
          SET LEFT SCROLL-BOUNDARY.
          PERFORM f_write_detail_kosong.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED ON.
        ENDIF.
      ENDIF.

      AT END OF vkbur.
        IF i_delete[] IS NOT INITIAL.
*          PERFORM f_add_realization TABLES i_delete.
          READ TABLE i_delete WITH KEY vkbur = wa_result-vkbur
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            PERFORM f_add_realization TABLES i_delete.
          ENDIF.
        ENDIF.
        CONCATENATE 'Sub Total' va_text INTO l3_text
          SEPARATED BY space.
        CONCATENATE 'Sub Total Real' va_text INTO l3_text_real
          SEPARATED BY space.
        PERFORM f_write_subtotal USING l3_text.
        IF pa_real EQ 'X'.
          PERFORM f_write_subtotal_real USING l3_text_real.
        ELSE.
          WRITE: / sy-uline.
        ENDIF.
        CLEAR: wa_subtotal, wa_sub_real, va_nou.
      ENDAT.
      CLEAR wa_result.
    ENDLOOP.
  ENDIF.
  PERFORM f_write_total.
  IF pa_real EQ 'X'.
    PERFORM f_write_total_real.
  ENDIF.
  PERFORM footer.
ENDFORM.                                                    " F_PROSES8

*&---------------------------------------------------------------------*
*&      Form  F_INIT_KVGR3
*&---------------------------------------------------------------------*
FORM f_init_kvgr3 .
  CLEAR so_kvgr3.
  so_kvgr3-sign = 'I'.
  so_kvgr3-option = 'EQ'.
  so_kvgr3-low = '05T'.
  APPEND so_kvgr3. CLEAR so_kvgr3.
ENDFORM.                    " F_INIT_KVGR3
