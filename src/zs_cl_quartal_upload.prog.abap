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
REPORT zs_cl_quartal_upload NO STANDARD PAGE HEADING
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
INCLUDE zs_cl_quartal_uploadtop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
SELECT-OPTIONS: so_kkber FOR knkk-kkber OBLIGATORY NO INTERVALS NO-EXTENSION.
PARAMETERS    : pa_vkorg LIKE vbak-vkorg OBLIGATORY,
                pa_zsmst LIKE zscl_sm-zsmst OBLIGATORY,
                pa_gjahr LIKE zscl_sm-gjahr OBLIGATORY DEFAULT sy-datum(4),
*                pa_spmon LIKE s603-spmon OBLIGATORY DEFAULT sy-datum(6),
                pa_vtweg LIKE knvv-vtweg DEFAULT '10' NO-DISPLAY,
                pa_spart LIKE knvv-spart DEFAULT '00' NO-DISPLAY,
                pa_vkbur LIKE s603-vkbur OBLIGATORY.
*                so_spmon FOR s603-spmon,
*                so_kdgrp FOR knvv-kdgrp,
*                so_kvgr3 FOR knvv-kvgr3,
SELECT-OPTIONS: so_knkli FOR knkk-knkli.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK sub1 WITH FRAME.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_down RADIOBUTTON GROUP grp1 USER-COMMAND usr1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(20) text-011 FOR FIELD p_down.
SELECTION-SCREEN : END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_uplod RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(20) text-012 FOR FIELD p_uplod.
SELECTION-SCREEN POSITION 55.
PARAMETERS: work_di1 LIKE rlgrap-filename OBLIGATORY MEMORY ID di1 MODIF ID 002.
SELECTION-SCREEN : END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_uplkp RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(20) text-014 FOR FIELD p_uplkp.
SELECTION-SCREEN POSITION 55.
PARAMETERS: work_di2 LIKE rlgrap-filename OBLIGATORY MEMORY ID di2 MODIF ID 003.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN END OF BLOCK sub1.

SELECTION-SCREEN BEGIN OF BLOCK ketr WITH FRAME TITLE text-015.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(75) text-021 MODIF ID 010.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(75) text-023 MODIF ID 010.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK ketr.

SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON pa_vkbur.
  PERFORM f_cek_vkbur.
*  macro_atz_single_vkbur so_vkbur c_atz_display.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'SUB'.
      screen-input = '0'.
    ENDIF.
    IF p_uplod = 'X'.
      IF screen-group1 = '001'.
        screen-active = '0'.
      ENDIF.
      IF screen-group1 = '003'.
        screen-active = '0'.
      ENDIF.
      IF screen-group1 = '010'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF p_down = 'X'.
      IF screen-group1 = '002'.
        screen-active = '0'.
      ENDIF.
      IF screen-group1 = '003'.
        screen-active = '0'.
      ENDIF.
      IF screen-group1 = '010'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF p_uplkp = 'X'.
      IF screen-group1 = '001'.
        screen-active = '0'.
      ENDIF.
      IF screen-group1 = '002'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON so_spmon.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR work_di1.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = ' '
      def_path         = 'C:\    .xls'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = text-011
    IMPORTING
      filename         = work_di1
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR work_di2.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = ' '
      def_path         = 'C:\    .xls'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = text-011
    IMPORTING
      filename         = work_di2
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

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
  INCLUDE zs_cl_quartal_uploadf01.

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

  CLEAR t_itab_conf.
  REFRESH t_itab_conf.

  CASE 'X'.
    WHEN p_uplod.
      LOOP AT t_itab WHERE check = 'X' AND
                           klimk_usl NE 0.
        t_itab_conf = t_itab.
        CLEAR t_itab_conf-check.
        SELECT SINGLE usergroup INTO t_itab_conf-usergroup
          FROM usgrp_user
          WHERE bname  = sy-uname.
        t_itab_conf-udate = sy-datum.
        t_itab_conf-utime = sy-uzeit.
        t_itab_conf-username = sy-uname.
*        IF t_itab-klimk_usl% LE 0.
        IF t_itab-klimk_usl EQ t_itab-klimk_hit.
          t_itab_conf-status = 'U'.
        ELSE.
          t_itab_conf-status = 'P'.
        ENDIF.
        APPEND t_itab_conf. CLEAR t_itab_conf.
      ENDLOOP.

    WHEN p_uplkp.
      LOOP AT t_itab WHERE check = 'X' AND
                           klimk_kp NE 0.
        t_itab_conf = t_itab.
        CLEAR t_itab_conf-check.
        SELECT SINGLE usergroup INTO t_itab_conf-usergroup
          FROM usgrp_user
          WHERE bname  = sy-uname.
        t_itab_conf-udate = sy-datum.
        t_itab_conf-utime = sy-uzeit.
        t_itab_conf-username = sy-uname.
        IF t_itab-klimk_kp% LE 0.
          t_itab_conf-status = 'U'.
        ELSE.
          t_itab_conf-status = 'P'.
        ENDIF.
        APPEND t_itab_conf. CLEAR t_itab_conf.
      ENDLOOP.
  ENDCASE.

  IF t_itab_conf[] IS NOT INITIAL.
    PERFORM f_print_data.
    PERFORM f_free_memory.
    LEAVE TO SCREEN 0.
  ENDIF.

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

  IF t_itab_conf[] IS NOT INITIAL.
    MODIFY zscl_sm FROM TABLE t_itab_conf.
    IF sy-subrc = 0.
      IF t_itab_err[] IS NOT INITIAL.
        PERFORM f_download_err.
      ENDIF.
      PERFORM f_free_memory.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.

ENDFORM.                    " f_post_entries
