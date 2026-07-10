*&---------------------------------------------------------------------*
*& Program Name     : ZGDCO_R011                                       *
*& Module Name      : CO                                               *
*& Author           : Budi                                             *
*& Functional       : FAM                                              *
*& Create Date      : 30.10.2023                                       *
*& Program Type     : Report                                           *
*& Description      : Report Fix & Variable Cost per Process Order     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zgdco_r011 NO STANDARD PAGE HEADING
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

*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE zgdco_r011top.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETER:      p_bukrs LIKE coep-bukrs OBLIGATORY DEFAULT '8010',
                p_gsber LIKE coep-gsber OBLIGATORY DEFAULT '0101',
                p_perio LIKE coep-perio OBLIGATORY DEFAULT sy-datum+4(2),
                p_gjahr LIKE coep-gjahr OBLIGATORY DEFAULT sy-datum(4).
SELECT-OPTIONS: s_types FOR zcodt007-types "DEFAULT '2'
                                          NO INTERVALS
                                          "NO-EXTENSION
                                          MODIF ID typ.
SELECT-OPTIONS: s_setnmm FOR setleaf-setname NO-DISPLAY,
                s_setnmp FOR setleaf-setname NO-DISPLAY,
                s_setnme FOR setleaf-setname NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK type WITH FRAME TITLE text-002.
PARAMETER: butt1 RADIOBUTTON GROUP grp USER-COMMAND usr,
           butt2 RADIOBUTTON GROUP grp,
           butt3 RADIOBUTTON GROUP grp.
SELECTION-SCREEN END OF BLOCK type.

SELECTION-SCREEN BEGIN OF BLOCK variant WITH FRAME TITLE text-003.
PARAMETERS: pa_vari  LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK variant.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
*  PERFORM f_init_khinr USING p_bukrs p_gsber.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF sy-uname = 'TDS_DEV01' OR sy-uname = 'ABSUK' OR sy-uname = 'COFAM'.
    ELSE.
      IF screen-group1 = 'TYP'.
        screen-active  = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

    IF screen-group1 = 'NDS'.
      screen-input  = 0.
      MODIFY SCREEN.
    ENDIF.
*    IF screen-group1 = 'PDA'.
*      IF p_radio3 IS INITIAL.
*        screen-active  = 0.
*      ENDIF.
*      MODIFY SCREEN.
*    ENDIF.
  ENDLOOP.

*&---------------------------------------------------------------------*
*& selection-screen ON
*&---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON p_gsber.
*  PERFORM f_init_setleaf USING p_bukrs p_gsber.

*AT SELECTION-SCREEN ON RADIOBUTTON GROUP grp1.
*  CASE 'X'.
*    WHEN p_radio1 OR p_radio2.
*      p_tdform = 'ZTSPPPSF002'.
*    WHEN p_radio3.
*      p_tdform = 'ZTSPPPSF003'.
*    WHEN OTHERS.
*  ENDCASE.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_vari.
  PERFORM f_f4_for_variant_alv CHANGING pa_vari.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_init_data.
  IF gt_zcodt007[] IS INITIAL.
    MESSAGE 'Please maintain ZCODT007' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.

END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zgdco_r011f01.

*------------------common includes for the program---------------------*
