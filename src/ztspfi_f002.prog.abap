*&---------------------------------------------------------------------*
*& Program Name     : ZTSPFI_F002                                      *
*& Module Name      : PP                                               *
*& Author           : Budi                                             *
*& Functional       : FAM                                            *
*& Create Date      : 24.09.2020                                       *
*& Program Type     : Forms                                            *
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
REPORT ztspfi_f002 NO STANDARD PAGE HEADING
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

* Smartforms
*INCLUDE zabp_pparameter.
SELECTION-SCREEN BEGIN OF BLOCK blxx WITH FRAME TITLE text-dat.
PARAMETERS: p_tdform    LIKE ssfscreen-fname DEFAULT 'ZTSPFI_F002'
                        OBLIGATORY MODIF ID frm,
            p_dest      LIKE tsp03-padest, "NO-DISPLAY,
            p_disp      LIKE ssfctrlop-preview  AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK blxx.
INCLUDE zabp_smartform.

*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE ztspfi_f002top.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
* coding here for your selection data
PARAMETER: p_noref TYPE znoref,
           p_bukrs TYPE bukrs DEFAULT '8010',
           p_gsber LIKE zfibphd001-gsber DEFAULT '0101'.
SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  p_dest = 'BM3W'.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'FRM'.
      screen-input  = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

*&---------------------------------------------------------------------*
*& selection-screen ON
*&---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON RADIOBUTTON GROUP grp1.
*  CASE 'X'.
*    WHEN p_radio1 OR p_radio2.
*      p_tdform = 'ZTSPPPSF002'.
*    WHEN p_radio3.
*      p_tdform = 'ZTSPPPSF003'.
*    WHEN OTHERS.
*  ENDCASE.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.

END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE ztspfi_f002f01.

*------------------common includes for the program---------------------*
