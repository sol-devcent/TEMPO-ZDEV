*&---------------------------------------------------------------------*
*& Program Name     : ZGDFI_E0001                                      *
*& Module Name      : FI                                               *
*& Author           : xxxxxx xxx , xxxxx xxxxx                         *
*& Functional       :                                                  *
*& Create Date      : dd/mm/yyyy                                       *
*& Program Type     : Enhancement;Forms;Report                         *
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
*&                                                                      *
*&---------------------------------------------------------------------*
REPORT zgdfi_e0001
               NO STANDARD PAGE HEADING
               LINE-SIZE 255.
*              ZFU.                 "Message class for Finish Unit
*              ZSP.                 "Spare Parts
*              ZPE.                 "Production and Engineering
*              ZFA.                 "Finance
*              ZAB.                 "ABAP and Tools

*------------------standard common includes----------------------------*
* Authorization checking macros
INCLUDE zabp_atz.

* common report header and other functions
INCLUDE zabp_header.

* other common functions
INCLUDE zabp_frm.

* BDC Include
INCLUDE zabp_bdc.

* ALV common functions
INCLUDE zabp_alv_common.

*------------------common TOP includes for the program----------------*
INCLUDE zgdfie0001top.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
*Main screen
SELECTION-SCREEN : BEGIN OF BLOCK main WITH FRAME TITLE TEXT-d00.
PARAMETERS: p_crb RADIOBUTTON GROUP radi DEFAULT 'X',
            p_pos RADIOBUTTON GROUP radi MODIF ID pos,
            p_prt RADIOBUTTON GROUP radi,
            p_poc RADIOBUTTON GROUP radi,
            p_rep RADIOBUTTON GROUP radi,
            p_rev RADIOBUTTON GROUP radi,
            p_fp  RADIOBUTTON GROUP radi,
            p_pse RADIOBUTTON GROUP radi,
            p_rcr RADIOBUTTON GROUP radi.
SELECTION-SCREEN END OF BLOCK main.
PARAMETERS: p_upd
*                  AS CHECKBOX
                  NO-DISPLAY.

*Create Billing & Report
SELECTION-SCREEN BEGIN OF SCREEN 9000.
SELECTION-SCREEN : BEGIN OF BLOCK crb WITH FRAME. "TITLE text-d01.
*PARAMETERS: p_bukrs LIKE t001-bukrs,
*            p_werks LIKE t001w-werks.
SELECT-OPTIONS: s_bukrs FOR s911-bukrs,
                s_werks FOR ekpo-werks,
                s_bedat FOR s911-bedat,
                s_ebeln FOR s911-ebeln,
                s_ekgrp FOR s911-ekgrp,
                s_bsart FOR s911-bsart,
                s_netwr FOR s911-netwr,
                s_belnr FOR s911-belnr,
                s_budat FOR s911-budat.
*                s_kode  FOR zs911kor-kode.
PARAMETERS: p_dest1 LIKE tsp03-padest OBLIGATORY,
            p_vari  LIKE disvariant-variant. " ALV Variant
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_cinvo AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK crb.
SELECTION-SCREEN END OF SCREEN 9000.

*PO Correction
SELECTION-SCREEN BEGIN OF SCREEN 9001.
SELECTION-SCREEN : BEGIN OF BLOCK poc WITH FRAME. "TITLE text-d02.
PARAMETERS: p_ebeln LIKE s911-ebeln OBLIGATORY,
            p_vrsio LIKE s911-vrsio DEFAULT '000' OBLIGATORY,
            p_text1 LIKE zs911kor-ztext1,
            p_text2 LIKE zs911kor-ztext2,
            p_text3 LIKE zs911kor-ztext3.
*            p_kode  LIKE zs911kor-kode OBLIGATORY.
SELECTION-SCREEN END OF BLOCK poc.
SELECTION-SCREEN END OF SCREEN 9001.

* Smartforms & Reverse
SELECTION-SCREEN BEGIN OF SCREEN 9002.
SELECTION-SCREEN BEGIN OF BLOCK prt WITH FRAME. "TITLE text-d03.
PARAMETERS: p_belnr     LIKE bkpf-belnr MEMORY ID bln OBLIGATORY.
PARAMETERS: p_stjah  LIKE s911-stjah DEFAULT sy-datum(4) OBLIGATORY,
*            p_bukrs     LIKE s911-bukrs OBLIGATORY,
            p_tdform LIKE ssfscreen-fname DEFAULT 'ZGDFIE0001_01'
                        OBLIGATORY MODIF ID r00,
            p_dest   LIKE tsp03-padest DEFAULT 'BM1*' OBLIGATORY
                                       MODIF ID r00,
            p_disp   LIKE ssfctrlop-preview AS CHECKBOX DEFAULT 'X'
                                            MODIF ID r00,
            p_ztext1 LIKE zs911kor-ztext1 MODIF ID r00,
            p_ztext2 LIKE zs911kor-ztext2 MODIF ID r00,
            p_ztext3 LIKE zs911kor-ztext3 MODIF ID r00.
*            p_zkode     LIKE zs911kor-kode OBLIGATORY.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_rinvo RADIOBUTTON GROUP grp1 DEFAULT 'X' USER-COMMAND invo MODIF ID inv,
            p_faktu RADIOBUTTON GROUP grp1 MODIF ID inv.
SELECTION-SCREEN END OF BLOCK prt.
SELECTION-SCREEN END OF SCREEN 9002.

*INCLUDE zabp_pparameter.
INCLUDE zabp_smartform.

*------------------standard common includes---ends---------------------*


*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM f_get_printer_def USING sy-uname
                            CHANGING p_dest.
  p_dest1 = p_dest.
  PERFORM f_get_signature.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON p_kode.
*  SELECT SINGLE * FROM zftntreason WHERE kode = p_kode.
*  IF sy-subrc NE 0.
*    MESSAGE 'Reason Code Not Valid' TYPE 'E'.
*  ENDIF.

*AT SELECTION-SCREEN ON p_zkode.
*  SELECT SINGLE * FROM zftntreason WHERE kode = p_zkode.
*  IF sy-subrc NE 0.
*    MESSAGE 'Reason Code Not Valid' TYPE 'E'.
*  ENDIF.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
* for alv variant
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f_f4_for_variant_alv USING p_vari
                               CHANGING d_alv_desc.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
* for alv variant
*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  CLEAR d_screen.
  SELECT SINGLE datab
  FROM zproject
  INTO va_datab
  WHERE name EQ 'ZGDTAX_TNT'.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
           ID 'BUKRS' FIELD d_tnt_bukrs
           ID 'ACTVT' FIELD c_atz_display.
  IF sy-subrc <> 0.
    MESSAGE i000(zab)
            WITH 'You are not authorized for company code'
                 d_tnt_bukrs.
    STOP.
  ENDIF.

  SELECT SINGLE *
      FROM zproject
      INTO CORRESPONDING FIELDS OF gs_dpp
      WHERE name = 'DPP12'.

  CASE 'X'.
    WHEN p_crb.
      d_screen = '9000'.
      CALL SELECTION-SCREEN 9000.
    WHEN p_pos.
      d_screen = '9008'.
      p_tdform = 'ZTNTSDF0001_WOFP'.
      CALL SELECTION-SCREEN 9002.
    WHEN p_poc.
      REFRESH: t_s911kor. CLEAR: t_s911kor.
      AUTHORITY-CHECK OBJECT 'ZGDTNTREV'
                ID 'ACTVT' FIELD '02'.
      IF sy-subrc <> 0.
        MESSAGE i000(zab)
                WITH 'You are not authorized to correct PO'.
        STOP.
      ENDIF.
      d_screen = '9001'.
      CALL SELECTION-SCREEN 9001.
    WHEN p_rep.
      d_screen = '9002'.
      CALL SELECTION-SCREEN 9000.
    WHEN p_prt.
      d_screen = '9003'.
*      p_tdform = 'ZGDFIE0001_01'.
*      p_tdform = 'ZGDFIE0001_01N'.
      p_tdform = 'ZTNTSDF0001_WOFP'.
      CALL SELECTION-SCREEN 9002.
    WHEN p_rev.
      REFRESH: t_s911kor. CLEAR: t_s911kor.
      AUTHORITY-CHECK OBJECT 'ZGDTNTREV'
                ID 'ACTVT' FIELD '85'.
      IF sy-subrc <> 0.
        MESSAGE i000(zab)
                WITH 'You are not authorized to reverse document'.
        STOP.
      ENDIF.
      d_screen = '9004'.
      CALL SELECTION-SCREEN 9002.
    WHEN p_fp.
      d_screen = '9005'.
      p_tdform = 'ZGDFIE0001_02'.
      CALL SELECTION-SCREEN 9002.
    WHEN p_pse.
      AUTHORITY-CHECK OBJECT 'ZGDTNTREV'
                ID 'ACTVT' FIELD '01'.
      IF sy-subrc <> 0.
        MESSAGE i000(zab)
                WITH 'You are not authorized to create PO special'.
        STOP.
      ENDIF.
*-----Default currency to IDR
      d_hwaer1 = s911-hwaer = 'IDR'.
      CALL SCREEN 9040.
      PERFORM f_free_memory.
    WHEN p_rcr.
      d_screen = '9007'.
      CALL SELECTION-SCREEN 9000.

  ENDCASE.

  IF sy-subrc NE 0.
    EXIT.
  ELSE.
    IF p_crb = 'X'.
*-------Check parameters
      IF s_bukrs-low IS INITIAL.
        MESSAGE i000(zab) WITH 'Company code must be entered'.
        STOP.
      ELSE.
*        macro_atz_single_bukrs s_bukrs-low c_atz_display.
      ENDIF.

      IF s_werks-low IS INITIAL.
*----02/08/2005: Since PO special entry (X****) should not be selected
*----Plant is mandatory
        MESSAGE i000(zab) WITH 'Plant must be entered'.
        STOP.
      ENDIF.

*-------Check link between company code & plant
      PERFORM f_check_link_cc_plant.
    ENDIF.
  ENDIF.
  IF p_pse IS INITIAL.
    PERFORM f_process_report.
  ENDIF.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zgdfie0001f01.
  INCLUDE zgdfie0001i01.
  INCLUDE zgdfie0001o01.
*------------------common includes for the program---------------------*
