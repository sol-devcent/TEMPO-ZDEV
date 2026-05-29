*&---------------------------------------------------------------------*
*& Program Name     : xxxxxxxxxxx                                      *
*& Module Name      : SD                                               *
*& Author           : Budi Pramono                                     *
*& Functional       : Popo                                             *
*& Create Date      : 14/01/2011                                       *
*& Program Type     : Report & Form                                    *
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
REPORT zs_incentive_wnd_write_txt NO STANDARD PAGE HEADING
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
INCLUDE zs_incentive_wnd_write_txttop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS: pa_vkorg LIKE s629-vkorg OBLIGATORY DEFAULT '8020',
            pa_spmon LIKE s629-spmon OBLIGATORY DEFAULT sy-datum(6).
SELECT-OPTIONS: so_vkbur FOR s629-vkbur OBLIGATORY.

PARAMETERS united AS CHECKBOX MODIF ID uni DEFAULT 'X'.
PARAMETERS slk AS CHECKBOX MEMORY ID slk.
PARAMETERS act AS CHECKBOX MODIF ID act. "DEFAULT 'X'.

PARAMETER : dc LIKE knvv-vtweg  DEFAULT '10' NO-DISPLAY,
            div LIKE knvv-spart DEFAULT '00' NO-DISPLAY,
            pa_path(52) DEFAULT '\\tdsdev01\interface\DO-Monitor\' LOWER CASE NO-DISPLAY.
PARAMETERS pa_chwh1 AS CHECKBOX MODIF ID pc1.
*SELECTION-SCREEN SKIP.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK proses WITH FRAME TITLE text-002.
PARAMETERS: radio1 RADIOBUTTON GROUP grp1 DEFAULT 'X' USER-COMMAND rad,
            radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS  radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(36) text-005 FOR FIELD radio3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK proses.

SELECTION-SCREEN BEGIN OF BLOCK output WITH FRAME TITLE text-003.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: out1 RADIOBUTTON GROUP grp2 DEFAULT 'X' USER-COMMAND grp2.
SELECTION-SCREEN COMMENT 5(20) text-004 FOR FIELD out1.
SELECTION-SCREEN POSITION 25.
PARAMETERS: pa_path1(52) DEFAULT '\\tdsdev01\interface\incentive\' LOWER CASE MODIF ID 001.
SELECTION-SCREEN : END OF LINE.
PARAMETERS: out2 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN END OF BLOCK output.

PARAMETERS cr_date AS CHECKBOX MODIF ID crd.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  IF sy-opsys EQ 'AIX'.
    pa_path = '/interface/DO-Monitor/'.
    pa_path1 = '/interface/Incentive/'.
  ENDIF.

  DATA: lv_parva(40).

  SELECT SINGLE parva INTO lv_parva
    FROM usr05 WHERE bname EQ sy-uname AND
                     parid EQ 'VKO'.
  IF sy-subrc EQ 0.
    pa_vkorg  = lv_parva.
  ENDIF.

  SELECT SINGLE parva INTO lv_parva
    FROM usr05 WHERE bname EQ sy-uname AND
                     parid EQ 'VKB'.
  IF sy-subrc EQ 0.
    so_vkbur-sign = 'I'.
    so_vkbur-option = 'EQ'.
    so_vkbur-low = lv_parva.
    APPEND so_vkbur.
  ENDIF.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF out1 NE 'X'.
      IF screen-group1 = '001'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

    IF radio2 IS NOT INITIAL.
      IF screen-group1 = 'SLK'.
        screen-active = '0'.
        CLEAR slk.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT SCREEN.
    IF screen-group1 = 'PC1'.
      screen-active  = 0.
    ENDIF.
    IF screen-group1 = 'CRD'.
      screen-active  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
*  AUTHORITY-CHECK OBJECT 'V_VBKA_VKO'
*           ID 'VKBUR' FIELD pa_vkbur.
*  IF sy-subrc = 4.
*    MESSAGE e000(zab) WITH 'No authorization for Sales Office' pa_vkbur.
*  ELSEIF sy-subrc <> 0.
*    MESSAGE e000(zab) WITH 'Internal problem in authorization check'.
*  ENDIF.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
*AT SELECTION-SCREEN ON pa_list.
*  CLEAR values. REFRESH values.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  ra_lgorte-low    = '100*'.
  ra_lgorte-sign   = 'E'.
  ra_lgorte-option = 'CP'.
  APPEND ra_lgorte.
  ra_lgorti-low    = '100*'.
  ra_lgorti-sign   = 'I'.
  ra_lgorti-option = 'CP'.
  APPEND ra_lgorti.

  IF sy-uname <> 'TDS_DEV01' AND
    sy-uname <> 'SDRAI'.
    PERFORM f_change_spmon_background.
  ENDIF.

  PERFORM f_get_sloff.
  PERFORM f_init_ranges_ztype.

  LOOP AT gt_tvbur.
    PERFORM f_init_data.

* United condition
    IF united IS NOT INITIAL.
      CLEAR: ra_lfart,ra_lfart[].
      PERFORM f_united USING '' pa_vkorg.
    ELSE.
      CLEAR: sales_org,sales_org[].
      sales_org-low     = pa_vkorg.
      sales_org-sign    = 'I'.
      sales_org-option  = 'EQ'.
      APPEND sales_org.
    ENDIF.

    PERFORM f_get_data.
    PERFORM f_process_data.
    PERFORM f_summary_itab.
    PERFORM f_free_itab.
  ENDLOOP.

  CASE 'X'.
    WHEN out1.
      PERFORM f_write_text.
    WHEN out2.
      PERFORM f_print_data.
  ENDCASE.

  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zs_incentive_wnd_write_txtf01.

*  INCLUDE zm_incentif_united.
  INCLUDE zm_incentif_unitedx.

*------------------common includes for the program---------------------*
