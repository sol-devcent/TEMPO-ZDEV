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
REPORT zs_release_quotation NO STANDARD PAGE HEADING
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
INCLUDE zs_release_quotationtop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS:
pa_vkorg  LIKE vbak-vkorg OBLIGATORY.
SELECT-OPTIONS:
so_vtweg  FOR vbak-vtweg,
so_spart  FOR vbak-spart,
so_vkbur  FOR vbak-vkbur,
so_vbeln  FOR vbak-vbeln,
so_audat  FOR vbak-audat,
so_auart  FOR vbak-auart.
SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data.
  IF va_error IS INITIAL.
    PERFORM f_process_data.
    PERFORM f_print_data.
  ELSE.
    IF va_error EQ 4.
      IF t_vbak[] IS NOT INITIAL.
        PERFORM f_process_data.
        PERFORM f_print_data.
      ELSE.
        CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
          EXPORTING
            message_text = 'No authorization for Sales office'.
      ENDIF.
    ELSE.
      IF t_vbak[] IS NOT INITIAL.
        PERFORM f_process_data.
        PERFORM f_print_data.
      ELSE.
        CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
          EXPORTING
            message_text = 'Internal problem in authorization check'.
      ENDIF.
    ENDIF.
  ENDIF.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zs_release_quotationf01.

*------------------common includes for the program---------------------*
