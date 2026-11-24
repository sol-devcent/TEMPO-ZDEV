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
REPORT zf_fk NO STANDARD PAGE HEADING LINE-SIZE 255.
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
INCLUDE zf_fktop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_bukrs   TYPE bukrs MODIF ID buk.
SELECT-OPTIONS so_vkbur   FOR tvbur-vkbur MODIF ID vkb.
SELECT-OPTIONS so_kunnr   FOR kna1-kunnr MODIF ID kun.
SELECT-OPTIONS so_fkdat   FOR vbrk-fkdat MODIF ID fkd.
SELECT-OPTIONS so_vbeln   FOR vbrk-vbeln MODIF ID vbe.
SELECT-OPTIONS so_zuonr   FOR vbrk-zuonr MODIF ID zuo.
PARAMETERS pa_vbeln   TYPE vbeln_va MODIF ID vb1.
PARAMETERS pa_zuonr   TYPE ordnr_v MODIF ID zu1.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK download WITH FRAME TITLE text-002.
PARAMETERS pa_delim   TYPE zdelim DEFAULT ',' MODIF ID del.
PARAMETERS pa_flnm1   TYPE localfile MODIF ID fn1.
SELECTION-SCREEN END OF BLOCK download.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_displ AS CHECKBOX DEFAULT 'X' MODIF ID dis.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK process WITH FRAME TITLE text-003.
PARAMETERS ra_fk RADIOBUTTON GROUP grp1 DEFAULT 'X'
                 USER-COMMAND grp1.
PARAMETERS ra_rfk RADIOBUTTON GROUP grp1.
PARAMETERS ra_del RADIOBUTTON GROUP grp1.
PARAMETERS ra_rpt RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK process.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
*  PERFORM f_get_parameters USING ''
*                           CHANGING pa_value.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON ( PARAMETERS )
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
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

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data.
  CASE 'X'.
    WHEN ra_del.
      PERFORM f_delete_data.
      IF gv_subrc IS INITIAL.
        COMMIT WORK AND WAIT.
        MESSAGE 'Data already deleted' TYPE 'S'.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
    WHEN OTHERS.
      IF ra_rpt IS INITIAL.
        PERFORM f_process_data.
        PERFORM f_compare_head_detail.
      ENDIF.
      IF pa_displ IS NOT INITIAL.
        PERFORM f_print_data.
      ELSE.
        PERFORM f_post_entries.
      ENDIF.
  ENDCASE.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zf_fkf01.

*------------------common includes for the program---------------------*
