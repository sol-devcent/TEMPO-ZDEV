*&---------------------------------------------------------------------*
*& Program Name     : xxxxxxxxxxx                                      *
*& Module Name      : FI,CO,MM,SD,PM,QM,PP                             *
*& Author           : xxxxxx xxx , xxxxx xxxxx                         *
*& Functional       :                                                  *
*& Create Date      : dd/mm/yyyy                                       *
*& Program Type     : Report/Enhancement                               *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*& Description      : xxxxxxxxxx xx xxxxxx xxxxxxx xxxx xxxx xxxxx     *
*&                    xxxx xx xxxxxxx xxxx xx xx xx xxxxxxxxx          *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zm_vendor_evaluation_newv2 NO STANDARD PAGE HEADING
                                  LINE-SIZE 255.
*              ZFU.                 "Message class for Finish Unit
*              ZSP.                 "Spare Parts
*              ZPE.                 "Production and Engineering
*              ZFA.                 "Finance
*              ZAB.                 "ABAP and Tools

*------------------standard common includes----------------------------*
* Authorization checking macros
INCLUDE zabp_atz.

* Upload and download flat file macors
INCLUDE zabp_udf.

* common report header and other functions
INCLUDE zabp_header.

* other common functions
INCLUDE zabp_frm.

* ALV common functions
INCLUDE zabp_alv_common.

* BDC Include
INCLUDE zabp_bdc.
*------------------standard common includes---ends---------------------*

*------------------common TOP includes for the program----------------*
INCLUDE zm_vendor_evaluation_newv2top.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
SELECT-OPTIONS:
so_bukrs  FOR ekko-bukrs MODIF ID buk,
so_werks  FOR ekpo-werks,
so_ekgrp  FOR ekko-ekgrp OBLIGATORY,
so_matnr  FOR ekpo-matnr OBLIGATORY,
*so_pohid  FOR ekko-bedat, "OBLIGATORY,
so_ponum  FOR ekko-ebeln,
*so_pored  FOR ekko-bedat, "OBLIGATORY,
so_eindt  FOR eket-eindt NO-DISPLAY,
so_lifnr  FOR ekko-lifnr.
PARAMETERS p_assdt LIKE eket-eindt DEFAULT sy-datum OBLIGATORY.
SELECT-OPTIONS:
so_loekz  FOR ekpo-loekz NO-EXTENSION NO INTERVALS.
PARAMETERS p_nodisp NO-DISPLAY.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_get6 AS CHECKBOX.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 31(16) text-100.
SELECTION-SCREEN : COMMENT 53(16) text-101.
SELECTION-SCREEN : COMMENT 75(16) text-102.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(20) text-103.
SELECTION-SCREEN POSITION 31.
PARAMETERS:
pa_hrgb LIKE zvend_eval-bobot.
SELECTION-SCREEN POSITION 75.
PARAMETERS:
pa_hrgn LIKE zvend_eval-nilai.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(20) text-104.
SELECTION-SCREEN POSITION 31.
PARAMETERS:
pa_qualb LIKE zvend_eval-bobot.
SELECTION-SCREEN : COMMENT 50(2) text-200.
SELECTION-SCREEN POSITION 53.
PARAMETERS:
pa_quala LIKE zvend_eval-acuan.
SELECTION-SCREEN POSITION 75.
PARAMETERS:
pa_qualn LIKE zvend_eval-nilai MODIF ID out.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(20) text-105.
SELECTION-SCREEN POSITION 31.
PARAMETERS:
pa_quanb LIKE zvend_eval-bobot.
SELECTION-SCREEN : COMMENT 50(2) text-201.
SELECTION-SCREEN POSITION 53.
PARAMETERS:
pa_quana LIKE zvend_eval-acuan.
SELECTION-SCREEN POSITION 75.
PARAMETERS:
pa_quann LIKE zvend_eval-nilai MODIF ID out.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(20) text-106.
SELECTION-SCREEN POSITION 31.
PARAMETERS:
pa_term LIKE zvend_eval-bobot.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(20) text-107.
SELECTION-SCREEN POSITION 75.
PARAMETERS:
pa_top1 LIKE zvend_eval-nilai.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(20) text-108.
SELECTION-SCREEN POSITION 75.
PARAMETERS:
pa_top2 LIKE zvend_eval-nilai.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(20) text-109.
SELECTION-SCREEN POSITION 75.
PARAMETERS:
pa_top3 LIKE zvend_eval-nilai.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(20) text-110.
SELECTION-SCREEN POSITION 75.
PARAMETERS:
pa_top4 LIKE zvend_eval-nilai.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(20) text-111.
SELECTION-SCREEN POSITION 75.
PARAMETERS:
pa_top5 LIKE zvend_eval-nilai.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(20) text-112.
SELECTION-SCREEN POSITION 31.
PARAMETERS:
pa_inter LIKE zvend_eval-inter_low OBLIGATORY MODIF ID int.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK data1.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF SCREEN 200 AS WINDOW TITLE text-113.
SELECTION-SCREEN BEGIN OF BLOCK interval WITH FRAME TITLE text-113.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 33(16) text-100.
SELECTION-SCREEN : COMMENT 55(16) text-101.
SELECTION-SCREEN : COMMENT 77(16) text-102.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(20) text-114.
SELECTION-SCREEN POSITION 33.
PARAMETERS:
pa_deliv LIKE zvend_eval-bobot.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(20) text-115.
SELECTION-SCREEN : COMMENT 52(2) text-200.
SELECTION-SCREEN POSITION 55.
PARAMETERS:
pa_intl1 LIKE zvend_eval-inter_low MODIF ID il1.
SELECTION-SCREEN POSITION 77.
PARAMETERS:
pa_intn1 LIKE zvend_eval-nilai.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(20) text-116 MODIF ID il2.
SELECTION-SCREEN : COMMENT 52(2) text-201 MODIF ID ge1.
SELECTION-SCREEN POSITION 55.
PARAMETERS:
pa_intl2 LIKE zvend_eval-inter_low MODIF ID il2.
SELECTION-SCREEN : COMMENT 62(2) text-202 MODIF ID ih2.
SELECTION-SCREEN POSITION 66.
PARAMETERS:
pa_inth2 LIKE zvend_eval-inter_high MODIF ID ih2.
SELECTION-SCREEN POSITION 77.
PARAMETERS:
pa_intn2 LIKE zvend_eval-nilai MODIF ID il2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(20) text-117 MODIF ID il3.
SELECTION-SCREEN : COMMENT 52(2) text-201 MODIF ID ge2.
SELECTION-SCREEN POSITION 55.
PARAMETERS:
pa_intl3 LIKE zvend_eval-inter_low MODIF ID il3.
SELECTION-SCREEN : COMMENT 62(2) text-202 MODIF ID ih3.
SELECTION-SCREEN POSITION 66.
PARAMETERS:
pa_inth3 LIKE zvend_eval-inter_high MODIF ID ih3.
SELECTION-SCREEN POSITION 77.
PARAMETERS:
pa_intn3 LIKE zvend_eval-nilai MODIF ID il3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(20) text-118 MODIF ID il4.
SELECTION-SCREEN : COMMENT 52(2) text-201 MODIF ID ge3.
SELECTION-SCREEN POSITION 55.
PARAMETERS:
pa_intl4 LIKE zvend_eval-inter_low MODIF ID il4.
SELECTION-SCREEN : COMMENT 62(2) text-202 MODIF ID ih4.
SELECTION-SCREEN POSITION 66.
PARAMETERS:
pa_inth4 LIKE zvend_eval-inter_high MODIF ID ih4.
SELECTION-SCREEN POSITION 77.
PARAMETERS:
pa_intn4 LIKE zvend_eval-nilai MODIF ID il4.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(20) text-119 MODIF ID il5.
SELECTION-SCREEN : COMMENT 52(2) text-201 MODIF ID ge4.
SELECTION-SCREEN POSITION 55.
PARAMETERS:
pa_intl5 LIKE zvend_eval-inter_low MODIF ID il5.
SELECTION-SCREEN POSITION 77.
PARAMETERS:
pa_intn5 LIKE zvend_eval-nilai MODIF ID il5.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK interval.

SELECTION-SCREEN BEGIN OF BLOCK incoterm WITH FRAME TITLE text-204.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(30) tx_inco1.
SELECTION-SCREEN : COMMENT 50(1) text-203.
SELECTION-SCREEN POSITION 33.
PARAMETERS: pa_inco1 LIKE zvend_eval-nilai.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(30) tx_inco2.
SELECTION-SCREEN : COMMENT 50(1) text-203.
SELECTION-SCREEN POSITION 33.
PARAMETERS: pa_inco2 LIKE zvend_eval-nilai.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(30) tx_inco3.
SELECTION-SCREEN : COMMENT 50(1) text-203.
SELECTION-SCREEN POSITION 33.
PARAMETERS: pa_inco3 LIKE zvend_eval-nilai.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(30) tx_inco4.
SELECTION-SCREEN : COMMENT 50(1) text-203.
SELECTION-SCREEN POSITION 33.
PARAMETERS: pa_inco4 LIKE zvend_eval-nilai.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(30) tx_inco5.
SELECTION-SCREEN : COMMENT 50(1) text-203.
SELECTION-SCREEN POSITION 33.
PARAMETERS: pa_inco5 LIKE zvend_eval-nilai.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(30) tx_inco6.
SELECTION-SCREEN : COMMENT 50(1) text-203.
SELECTION-SCREEN POSITION 33.
PARAMETERS: pa_inco6 LIKE zvend_eval-nilai.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK incoterm.
SELECTION-SCREEN END OF SCREEN 200.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  SELECT zline description bobot acuan nilai
         inter_low inter_high
    FROM zvend_eval
    INTO CORRESPONDING FIELDS OF TABLE t_zvend_eval.

  LOOP AT t_zvend_eval.
    CASE t_zvend_eval-zline.
      WHEN 1.
        pa_hrgb  = t_zvend_eval-bobot.
        pa_hrgn  = t_zvend_eval-nilai.
      WHEN 2.
        pa_qualb  = t_zvend_eval-bobot.
        pa_quala  = t_zvend_eval-acuan.
        pa_qualn  = t_zvend_eval-nilai.
      WHEN 3.
        pa_quanb  = t_zvend_eval-bobot.
        pa_quana  = t_zvend_eval-acuan.
        pa_quann  = t_zvend_eval-nilai.
      WHEN 4.
        pa_term   = t_zvend_eval-bobot.
      WHEN 5.
        pa_top1   = t_zvend_eval-nilai.
      WHEN 6.
        pa_top2   = t_zvend_eval-nilai.
      WHEN 7.
        pa_top3   = t_zvend_eval-nilai.
      WHEN 8.
        pa_top4   = t_zvend_eval-nilai.
      WHEN 9.
        pa_top5   = t_zvend_eval-nilai.
      WHEN 10.
        pa_inter  = t_zvend_eval-inter_low.
      WHEN OTHERS.
*        EXIT.
        IF t_zvend_eval-zline(2) = '02'.
          CASE t_zvend_eval-zline+2(1).
            WHEN '1'.
              tx_inco1 = t_zvend_eval-description.
              pa_inco1 = t_zvend_eval-nilai.
            WHEN '2'.
              tx_inco2 = t_zvend_eval-description.
              pa_inco2 = t_zvend_eval-nilai.
            WHEN '3'.
              tx_inco3 = t_zvend_eval-description.
              pa_inco3 = t_zvend_eval-nilai.
            WHEN '4'.
              tx_inco4 = t_zvend_eval-description.
              pa_inco4 = t_zvend_eval-nilai.
            WHEN '5'.
              tx_inco5 = t_zvend_eval-description.
              pa_inco5 = t_zvend_eval-nilai.
            WHEN '6'.
              tx_inco6 = t_zvend_eval-description.
              pa_inco6 = t_zvend_eval-nilai.
          ENDCASE.
        ENDIF.
    ENDCASE.
  ENDLOOP.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen_1000.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen_1000.
    WHEN space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  IF p_nodisp IS INITIAL.
    CALL SELECTION-SCREEN 200 STARTING AT 0 0.
  ENDIF.
  IF sy-subrc EQ 0.
    PERFORM f_get_data.
    PERFORM f_process_data.
    PERFORM f_print_data.
  ENDIF.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*----------------------------------------------------------------------*
* TOP-OF-PAGE
*----------------------------------------------------------------------*
TOP-OF-PAGE.
  CASE gv_fieldname.
    WHEN 'SCORQUAL' OR 'SCORQTY'.
      ULINE AT /(45).
      WRITE:/ sy-vline NO-GAP, (10) 'Nomor PO' NO-GAP,
              sy-vline NO-GAP,  (5) 'Item' NO-GAP,
              sy-vline NO-GAP, (10) 'Delv. Date' NO-GAP,
*          sy-vline NO-GAP, (10) 'Material' NO-GAP,
*          sy-vline NO-GAP, (40) 'Material Desc.' NO-GAP,
*          sy-vline NO-GAP, (10) 'Vendor' NO-GAP,
*          sy-vline NO-GAP, (40) 'Vendor Name' NO-GAP,
              sy-vline NO-GAP, (15) 'Quantity' NO-GAP RIGHT-JUSTIFIED,
              sy-vline NO-GAP.
      ULINE AT /(45).

    WHEN 'SCORD'.
      ULINE AT /(72).
      WRITE:/ sy-vline NO-GAP, (10) 'Nomor PO' NO-GAP,
              sy-vline NO-GAP,  (5) 'Item' NO-GAP,
              sy-vline NO-GAP, (10) 'Delv. Date' NO-GAP,
              sy-vline NO-GAP, (10) 'Post. Date' NO-GAP,
*              sy-vline NO-GAP, (10) 'Material' NO-GAP,
*              sy-vline NO-GAP, (40) 'Material Desc.' NO-GAP,
*              sy-vline NO-GAP, (10) 'Vendor' NO-GAP,
*              sy-vline NO-GAP, (40) 'Vendor Name' NO-GAP,
              sy-vline NO-GAP, (15) 'GR Qty' NO-GAP RIGHT-JUSTIFIED,
              sy-vline NO-GAP, (15) 'Quantity' NO-GAP RIGHT-JUSTIFIED,
              sy-vline NO-GAP.
      ULINE AT /(72).
  ENDCASE.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zm_vendor_evaluation_newv2f01.
