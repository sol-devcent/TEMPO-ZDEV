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
REPORT zs_cl_quartal_hitung NO STANDARD PAGE HEADING
                             LINE-SIZE 255
                             LINE-COUNT 60.
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
*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE zs_cl_quartal_hitungtop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
SELECT-OPTIONS: so_kkber FOR knkk-kkber OBLIGATORY NO INTERVALS NO-EXTENSION.
PARAMETERS    : pa_vrsio LIKE s603-vrsio OBLIGATORY,
                pa_vkorg LIKE vbak-vkorg OBLIGATORY,
                pa_vtweg LIKE knvv-vtweg DEFAULT '10' NO-DISPLAY,
                pa_spart LIKE knvv-spart DEFAULT '00' NO-DISPLAY.
*                pa_zsmst like zscl_sm-zsmst obligatory.
SELECT-OPTIONS: so_vkbur FOR s603-vkbur OBLIGATORY,
                so_spmon FOR s603-spmon OBLIGATORY.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) text-010 FOR FIELD pa_zsmst.
PARAMETERS    : pa_zsmst LIKE zscl_sm-zsmst OBLIGATORY.
SELECTION-SCREEN COMMENT 41(5) text-011 FOR FIELD pa_gjahr.
PARAMETERS    : pa_gjahr LIKE zscl_sm-gjahr OBLIGATORY.
SELECTION-SCREEN END OF LINE.

*                so_kdgrp FOR knvv-kdgrp,
*                so_kvgr3 FOR knvv-kvgr3,
SELECT-OPTIONS: so_knkli FOR knkk-knkli.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK sub1 WITH FRAME.
PARAMETERS    : pa_6bl TYPE int4 OBLIGATORY MEMORY ID 6bl,
                pa_3bl TYPE int4 OBLIGATORY MEMORY ID 3bl,
                pa_max TYPE int4 OBLIGATORY MEMORY ID max.
SELECTION-SCREEN END OF BLOCK sub1.
SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
*  IF so_spmon-high+4(2) >= '06'.
**    pa_zsmst = '2'.
*    pa_zsmst = '1'.
*  ELSE.
**    pa_zsmst = '1'.
*    pa_zsmst = '2'.
*  ENDIF.
  PERFORM init_screen.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON so_vkbur.
*  macro_atz_single_vkbur so_vkbur c_atz_display.

AT SELECTION-SCREEN ON pa_zsmst.
  IF pa_zsmst BETWEEN '1' AND '4'.
  ELSE.
    MESSAGE 'Quartal Salah' TYPE 'E'.
  ENDIF.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'SUB'.
      screen-input = '0'.
    ENDIF.
*    IF so_spmon-high+4(2) >= '06'.
**     pa_zsmst = '2'.
*      pa_zsmst = '1'.
*    ELSE.
**     pa_zsmst = '1'.
*      pa_zsmst = '2'.
*    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON so_spmon.
*  DATA: l_date1 LIKE sy-datum,
*        l_date2 LIKE sy-datum.
*  CONCATENATE so_spmon-low '01' INTO l_date1.
*  CALL FUNCTION 'Z_CALC_DATE'
*    EXPORTING
*      date      = l_date1
*      days      = '0'
*      months    = '5'
*      sign      = '+'
*      years     = '0'
*    IMPORTING
*      calc_date = l_date2.
*  CLEAR so_spmon. REFRESH so_spmon.
*  so_spmon-low   = l_date1(6).
*  so_spmon-high   = l_date2(6).
*  so_spmon-sign   = 'I'.
*  so_spmon-option = 'BT'.
*  APPEND so_spmon.

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
*  PERFORM f_print_data.
  PERFORM f_update_table.
  PERFORM f_write_error.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*----------------------------------------------------------------------*
* TOP-OF-PAGE.
*----------------------------------------------------------------------*
TOP-OF-PAGE.
  PERFORM f_write_header.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zs_cl_quartal_hitungf01.

*------------------common includes for the program---------------------*

*&---------------------------------------------------------------------*
*&      Form  f_Usulan
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_usulan USING fu_selfield TYPE slis_selfield.

ENDFORM.                    " f_Usulan

*&---------------------------------------------------------------------*
*&      Form  f_validasi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validasi.

ENDFORM.                    " f_validasi

*&---------------------------------------------------------------------*
*&      Form  f_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_confirm .

ENDFORM.                    " f_confirm

*&---------------------------------------------------------------------*
*&      Form  f_post_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_entries.

ENDFORM.                    " f_post_entries

*&---------------------------------------------------------------------*
*&      At selection screen
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
