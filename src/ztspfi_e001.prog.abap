*&---------------------------------------------------------------------*
*& Program Name     : ZTSPFI_E001                                      *
*& Module Name      : FI                                               *
*& Author           : Budi                                             *
*& Functional       : FAM                                              *
*& Create Date      : 23.01.2024                                       *
*& Program Type     : Enhancement                                      *
*& Transaction      : ZKMMFIE02                                        *
*& SAP Release      :                                                  *
*& Description      : Depresiasi Asset                                 *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT ztspfi_e001 NO STANDARD PAGE HEADING
                   LINE-SIZE 255.
*              ZFU.                 "Message class for Finish Unit
*              ZSP.                 "Spare Parts
*              ZPE.                 "Production and Engineering
*              ZFA.                 "Finance
*              ZAB.                 "ABAP and Tools

*------------------standard common includes----------------------------*
* Authorization checking macros
*INCLUDE zabp_atz.

* common report header and other functions
*INCLUDE zabp_header.

* other common functions
*INCLUDE zabp_frm.

* BDC Include
INCLUDE zabp_bdc.

*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE ztspfi_e001top.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
* coding here for your selection data
PARAMETER:      p_bukrs TYPE bukrs OBLIGATORY DEFAULT '8010',
                p_spmon TYPE spmon OBLIGATORY DEFAULT sy-datum(6),
                p_gsber TYPE gsber MODIF ID gsb.
SELECT-OPTIONS: "s_gsber FOR mseg-werks,
                s_anln1 FOR anlc-anln1,
                s_anln2 FOR anlc-anln2,
                s_fevor FOR ztspfidt02-fevor MODIF ID nds.
PARAMETER:      p_bwasl TYPE bwasl OBLIGATORY DEFAULT '600'.
PARAMETERS:     p_flnme LIKE rlgrap-filename MODIF ID fln.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK proses WITH FRAME TITLE text-002.
PARAMETER:      p_but1 RADIOBUTTON GROUP grp1 USER-COMMAND us1
                                              MODIF ID but,
                p_but2 RADIOBUTTON GROUP grp1 MODIF ID but,
                p_but3 RADIOBUTTON GROUP grp1 DEFAULT 'X'
                                              MODIF ID but,
                p_but4 RADIOBUTTON GROUP grp1 MODIF ID but.
SELECTION-SCREEN END OF BLOCK proses.

SELECTION-SCREEN BEGIN OF BLOCK variant WITH FRAME TITLE text-003.
PARAMETERS: pa_vari  LIKE disvariant-variant MODIF ID nds.
SELECTION-SCREEN END OF BLOCK variant.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  p_spmon = sy-datum(6).

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen_1000.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen_1000.
    WHEN space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

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

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_vari.
  PERFORM f_f4_for_variant_alv CHANGING pa_vari.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_flnme.
  PERFORM f_filename_f4 CHANGING p_flnme.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_init_data.

  CASE 'X'.
    WHEN p_but1.
      PERFORM f_upload_from_excel.
      PERFORM f_print_data.

    WHEN p_but2.
      PERFORM f_maintain_ztspfidt02.

    WHEN p_but3.
      PERFORM f_get_data.
      PERFORM f_process_data.
      PERFORM f_print_data.

    WHEN p_but4.
      PERFORM f_get_data4.
      PERFORM f_print_data.
  ENDCASE.

  PERFORM f_free_memory.

END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE ztspfi_e001f01.

*------------------common includes for the program---------------------*
*&---------------------------------------------------------------------*
*&      Form  F_ERROR_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_error_log .
  DATA : ls_bdcmsg    LIKE LINE OF t_bdcmsg,
         ls_error     LIKE LINE OF gt_error.

  LOOP AT t_bdcmsg INTO ls_bdcmsg.
    IF ls_bdcmsg-msgtyp = 'S'.
      CONTINUE.
    ENDIF.
    ls_error-type          = ls_bdcmsg-msgtyp.
    ls_error-id            = ls_bdcmsg-msgid.
    ls_error-number        = ls_bdcmsg-msgnr.
    ls_error-message_v1    = ls_bdcmsg-msgv1.
    ls_error-message_v2    = ls_bdcmsg-msgv2.
    ls_error-message_v3    = ls_bdcmsg-msgv3.
    ls_error-message_v4    = ls_bdcmsg-msgv4.
    APPEND ls_error TO gt_error.
    CLEAR ls_error.
  ENDLOOP.
ENDFORM.                    " F_ERROR_LOG
