*&---------------------------------------------------------------------*
*& Program Name     : xxxxxxxxxxx                                      *
*& Module Name      : FI                                               *
*& Author           : Budi.P                                           *
*& Functional       : SJT                                              *
*& Create Date      : 30/11/2012                                       *
*& Program Type     : Report/Enhancement                               *
*& Transaction      :                                                  *
*& Description      : 1. Input & Posting Penyelasaian A/R Potongan     *
*&                    2. Reverse Penyelasaian A/R Potongan             *
*&                    3. Laporan Penyelasaian A/R Potongan             *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#          DATE         AUTHOR         DESCRIPTION              *
*& DEVK935912     19.08.2013                  Modifikasi untuk SUT     *
*&                                            Project                  *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zf_input_payment_ar_potongan NO STANDARD PAGE HEADING
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
INCLUDE zf_inputpayment_arpotongantop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_bukrs LIKE zfarpoth-bukrs DEFAULT '8020' OBLIGATORY
                                        MODIF ID gry,
            p_gsber LIKE zfarpoth-gsber DEFAULT '0200' OBLIGATORY
                                         MODIF ID gry,
            p_vkbur LIKE zfarpoth-vkbur MEMORY ID vkb OBLIGATORY,
            p_mjahr LIKE zfarpoth-mjahr DEFAULT sy-datum(4) OBLIGATORY,
*            p_hkont LIKE zfacct-saknr   MEMORY ID hkn OBLIGATORY
*                                        MODIF ID inp.
            p_noarp LIKE zfarpoth-noarp MEMORY ID arp OBLIGATORY
                                        MODIF ID inp,
            p_belnr LIKE zfarpotd2-belnr MODIF ID xxx OBLIGATORY.
SELECT-OPTIONS: s_noarp FOR zfarpoth-noarp MODIF ID rep,
                s_budat FOR zfarpoth-budat MODIF ID rev,
                s_nortv FOR zfarpotd-rtvnr MODIF ID yyy NO INTERVALS.
SELECTION-SCREEN SKIP.
PARAMETERS: pa_cek AS CHECKBOX MODIF ID pck.
PARAMETERS: p_vari  LIKE disvariant-variant MODIF ID gen. " ALV Variant
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-002.
PARAMETERS: p_input RADIOBUTTON GROUP grp1 USER-COMMAND usr1,
            p_revrs RADIOBUTTON GROUP grp1,
            p_lapor RADIOBUTTON GROUP grp1,
            p_grept RADIOBUTTON GROUP grp1 DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK block2.

PARAMETERS: pa_grid AS CHECKBOX MODIF ID grd.

SELECTION-SCREEN BEGIN OF SCREEN 500 TITLE TEXT-500.
PARAMETERS: ps_bukrs LIKE zfarpoth-bukrs DEFAULT '8020' OBLIGATORY
                                        MODIF ID gry,
            ps_gsber LIKE zfarpoth-gsber DEFAULT '0200' OBLIGATORY
                                         MODIF ID gry,
            ps_vkbur LIKE zfarpoth-vkbur MEMORY ID vkb OBLIGATORY,
            ps_mjahr LIKE zfarpoth-mjahr DEFAULT sy-datum(4) OBLIGATORY,
            ps_noarp LIKE zfarpoth-noarp MEMORY ID arp OBLIGATORY
                                         MODIF ID inp.
SELECT-OPTIONS: ss_nortv FOR zfarpotd-rtvnr MODIF ID inp NO INTERVALS.
SELECTION-SCREEN END OF SCREEN 500.


*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  DATA: lv_parva(40).

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
    p_gsber  = lv_parva.
  ENDIF.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_bukrs.
  IF p_bukrs NE '8020' AND
     p_bukrs NE '8070'.
    MESSAGE e000(zf) WITH 'CoCd must be entry 8020 or 8070'.
  ENDIF.

AT SELECTION-SCREEN ON p_gsber.
  IF p_bukrs EQ '8020'.
    IF p_gsber NE '0200'.
      MESSAGE e000(zf) WITH 'Business area must be entry 0200'.
    ENDIF.
  ENDIF.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'GRD'.
      screen-active  = 0.
    ENDIF.
*    IF screen-group1 = 'GRY'.
*      screen-input  = 0.
*    ENDIF.
    CASE 'X'.
      WHEN p_input.
        IF screen-group1 = 'REP' OR
           screen-group1 = 'REV' OR
           screen-group1 = 'XXX' OR
           screen-group1 = 'GEN'.
          screen-active = 0.
        ENDIF.
      WHEN p_revrs.
        IF screen-group1 = 'REP' OR
           screen-group1 = 'REV' OR
           screen-group1 = 'YYY' OR
           screen-group1 = 'GEN' OR
           screen-group1 = 'PCK'.
          screen-active = 0.
        ENDIF.
      WHEN p_lapor.
        IF screen-group1 = 'INP' OR
           screen-group1 = 'XXX' OR
           screen-group1 = 'YYY' OR
           screen-group1 = 'GEN' OR
           screen-group1 = 'PCK'.
          screen-active = 0.
        ENDIF.
      WHEN p_grept.
        IF screen-group1 = 'INP' OR
           screen-group1 = 'YYY' OR
           screen-group1 = 'XXX' OR
           screen-group1 = 'PCK'.
          screen-active = 0.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

*&---------------------------------------------------------------------*
*& AT SELECTION SCREEN ON VALUE REQUEST
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f_f4_for_variant_alv USING p_vari.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_get_data.
  PERFORM f_process_data.

  CASE 'X'.
    WHEN p_input.
      IF gt_zfarpotd[] IS INITIAL.
        MESSAGE 'No Data' TYPE 'I'.
        STOP.
      ENDIF.
      PERFORM f_init_screen_100.
      CALL SCREEN 100.

    WHEN p_revrs.
      AUTHORITY-CHECK OBJECT 'ZARPOTONG'
                ID 'ACTVT' FIELD '85'.
      IF sy-subrc <> 0.
        MESSAGE 'You are not authorized to reverse document' TYPE 'I'.
        STOP.
      ENDIF.
      PERFORM f_init_screen_200.
      CALL SCREEN 200.
*      PERFORM f_init_data.
*      PERFORM f_print_data.
*      PERFORM f_free_memory.

    WHEN p_lapor OR p_grept.
      PERFORM f_init_data.
      PERFORM f_print_data.
      PERFORM f_free_memory.
  ENDCASE.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zf_inputpayment_arpotonganf01.

*------------------common module for the screen---------------------*
