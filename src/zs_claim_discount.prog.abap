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
REPORT zs_claim_discount NO STANDARD PAGE HEADING
                         LINE-COUNT 65
*                         LINE-SIZE 255.
                         LINE-SIZE 301.
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
INCLUDE zs_claim_discounttop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS:
  pa_spmon  LIKE s626-spmon OBLIGATORY DEFAULT sy-datum(6).
SELECT-OPTIONS:
  so_vkbur  FOR s626-vkbur,
  so_prodh  FOR s626-prodh1,
  so_matkl  FOR s626-matkl.
SELECTION-SCREEN SKIP 1.
PARAMETERS:
  pa_text AS CHECKBOX USER-COMMAND txt,
  pa_all AS CHECKBOX USER-COMMAND txt DEFAULT 'X',
  pa_disc AS CHECKBOX USER-COMMAND txt,
  pa_path(52) LOWER CASE MODIF ID pat OBLIGATORY.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-002.
PARAMETERS: radio1 RADIOBUTTON GROUP grp DEFAULT 'X' MODIF ID rpt.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio2 RADIOBUTTON GROUP grp MODIF ID rpt.
SELECTION-SCREEN : COMMENT 5(65) text-003 FOR FIELD radio2 MODIF ID rpt.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio3 RADIOBUTTON GROUP grp MODIF ID rpt.
SELECTION-SCREEN : COMMENT 5(65) text-004 FOR FIELD radio3 MODIF ID rpt.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio4 RADIOBUTTON GROUP grp MODIF ID rpt.
SELECTION-SCREEN : COMMENT 5(65) text-005 FOR FIELD radio4 MODIF ID rpt.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK data1.

TOP-OF-PAGE.
  PERFORM f_hdrline_standard USING sy-title.
  PERFORM f_hdr_uline1.
  PERFORM f_top_header.
  PERFORM f_hdr_uline1.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  IF sy-opsys = 'AIX'.
    pa_path = '/interface/'.
  ELSE.
    pa_path = '\\tdsdev01\interface\'.
  ENDIF.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  IF pa_text EQ 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'PAT'.
        screen-active  = 1.
      ENDIF.
      IF screen-group1 = 'RPT'.
        screen-active  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'PAT'.
        screen-active  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

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
  PERFORM f_process_data.
  PERFORM f_free_memory.
  IF pa_text IS INITIAL.
    CASE 'X'.
      WHEN radio1.
        PERFORM f_print_data.
      WHEN radio2.
        SORT t_out1 BY prodh1 matkl matnr vkbur.
        PERFORM f_standard_list1.
      WHEN radio3.
        SORT t_out2 BY prodh1 vkbur pkunwe vbeln matnr.
        PERFORM f_standard_list2.
      WHEN radio4.
        SORT t_out3 BY prodh1 matkl vkbur pkunwe matnr.
        PERFORM f_standard_list3.
    ENDCASE.
  ELSE.
    PERFORM f_download_text.
  ENDIF.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zs_claim_discountf01.

*------------------common includes for the program---------------------*
