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
REPORT zs_cl_quartal_report NO STANDARD PAGE HEADING
                             LINE-SIZE 220.
*              ZFU.                 "Message class for Finish Unit
*              ZSP.                  "Spare Parts
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

* BDC List
INCLUDE <%_list>.
*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE zs_cl_quartal_reporttop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS    : pa_gjahr LIKE zscl_sm-gjahr OBLIGATORY DEFAULT sy-datum(4),
                pa_zsmst LIKE zscl_sm-zsmst OBLIGATORY,
                pa_vkorg LIKE zscl_sm-vkorg OBLIGATORY,
                pa_kkber LIKE zscl_sm-kkber OBLIGATORY MODIF ID sub.
SELECT-OPTIONS: so_vkbur FOR zscl_sm-vkbur OBLIGATORY,
                so_kdgrp FOR zscl_sm-kdgrp,
                so_kvgr3 FOR zscl_sm-kvgr3,
                so_knkli FOR zscl_sm-knkli.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-002.
PARAMETERS: p_entry AS CHECKBOX DEFAULT 'X',
            p_downl AS CHECKBOX DEFAULT 'X',
            p_uplod AS CHECKBOX DEFAULT 'X',
            p_upld1 AS CHECKBOX DEFAULT 'X',
            p_usula AS CHECKBOX DEFAULT 'X',
            p_rele1 AS CHECKBOX DEFAULT 'X',
            p_relec AS CHECKBOX DEFAULT 'X',
            p_final AS CHECKBOX DEFAULT 'X',
            p_delet AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK data1.
SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM init_screen.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON so_vkbur.
*  macro_atz_single_vkbur pa_vkbur c_atz_display.
  SELECT * INTO TABLE t_tvkbt FROM tvkbt WHERE spras = sy-langu AND
                                               vkbur IN so_vkbur.
  LOOP AT t_tvkbt.
    AUTHORITY-CHECK OBJECT 'V_VBKA_VKO'
          ID 'VKBUR' FIELD t_tvkbt-vkbur.
    IF sy-subrc = 0.
      r_vkbur-sign = 'I'.
      r_vkbur-option = 'EQ'.
      r_vkbur-low = t_tvkbt-vkbur.
      APPEND r_vkbur.
    ENDIF.
  ENDLOOP.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*  LOOP AT SCREEN.
*    IF screen-group1 = 'SUB'.
*      screen-input = '0'.
*    ENDIF.
*    MODIFY SCREEN.
*  ENDLOOP.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON pa_spmon.

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
  PERFORM f_print_data.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zs_cl_quartal_reportf01.
