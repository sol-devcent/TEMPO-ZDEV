*&---------------------------------------------------------------------*
*& Program Name     : xxxxxxxxxxx                                      *
*& Module Name      : FI                                               *
*& Author           : Budi.P                                           *
*& Functional       : SJT                                              *
*& Create Date      : 30/11/2012                                       *
*& Program Type     : Report/Enhancement                               *
*& Transaction      :                                                  *
*& Description      : 1. Input & Posting A/R Potongan                  *
*&                    2. Reverse A/R Potongan                          *
*&                    3. Laporan A/R Potongan                          *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#          DATE         AUTHOR         DESCRIPTION              *
*& DEVK935906     19.08.2013                  Modifikasi untuk SUT     *
*&                                            Project                  *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zf_input_ar_potongan NO STANDARD PAGE HEADING
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
INCLUDE zf_input_ar_potongantop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS: p_bukrs LIKE zfarpoth-bukrs DEFAULT '8020' OBLIGATORY
                                        MODIF ID gry,
            p_gsber LIKE zfarpoth-gsber DEFAULT '0200' OBLIGATORY
                                         MODIF ID gry,
            p_vkbur LIKE zfarpoth-vkbur MEMORY ID vkb OBLIGATORY,
            p_mjahr LIKE zfarpoth-mjahr DEFAULT sy-datum(4) OBLIGATORY.
*            p_hkont LIKE zfacct-saknr   MEMORY ID hkn
*                                        OBLIGATORY MODIF ID inp.
SELECT-OPTIONS: s_noarp FOR zfarpoth-noarp MODIF ID rev,
                s_belnr FOR zfarpoth-belnr MODIF ID rev,
                s_budat FOR zfarpoth-budat MODIF ID rev.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE text-002.
PARAMETERS: p_input RADIOBUTTON GROUP grp1 USER-COMMAND usr1,
            p_revrs RADIOBUTTON GROUP grp1,
            p_lapor RADIOBUTTON GROUP grp1 DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK block2.
PARAMETERS: pa_grid AS CHECKBOX MODIF ID grd.

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
        IF screen-group1 = 'REV'.
          screen-active = 0.
        ENDIF.
      WHEN p_revrs OR p_lapor.
        IF screen-group1 = 'INP'.
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

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  CASE 'X'.
    WHEN p_input.
      PERFORM f_get_zterm.
      PERFORM f_init_screen_100.
      CALL SCREEN 100.

    WHEN p_revrs.
      AUTHORITY-CHECK OBJECT 'ZARPOTONG'
                ID 'ACTVT' FIELD '85'.
      IF sy-subrc <> 0.
        MESSAGE 'You are not authorized to reverse document' TYPE 'I'.
        STOP.
      ENDIF.
      PERFORM f_init_data.
      PERFORM f_get_data.
      PERFORM f_process_data.
      PERFORM f_print_data.
      PERFORM f_free_memory.

    WHEN p_lapor.
      PERFORM f_init_data.
      PERFORM f_get_data.
      PERFORM f_process_data.
      PERFORM f_print_data.
      PERFORM f_free_memory.
  ENDCASE.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zf_input_ar_potonganf01.

*------------------common module for the screen---------------------*
