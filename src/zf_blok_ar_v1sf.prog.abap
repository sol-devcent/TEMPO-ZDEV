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
*& CRNO#          DATE         AUTHOR         DESCRIPTION              *
*& DEVK935906     19.08.2013                  Modifikasi untuk SUT     *
*&                                            Project                  *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zf_blok_ar_v1sf NO STANDARD PAGE HEADING
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
INCLUDE zf_blok_ar_v1sf_top.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS:
  pa_bukrs LIKE bsid-bukrs OBLIGATORY DEFAULT '8020',
  pa_vkbur LIKE knvv-vkbur MODIF ID vkb.
SELECT-OPTIONS:
  so_dform FOR zfh_kr1at-dtform MODIF ID dtf,
  so_kunnr FOR bsid-kunnr MODIF ID kun,
  so_zuonr FOR bsid-zuonr MODIF ID zuo,
  so_nform FOR zfh_kr1at-noform MODIF ID nfr.
PARAMETERS:
  pa_nform LIKE zfh_kr1at-noform MODIF ID nfo.
SELECTION-SCREEN SKIP 1.
PARAMETERS:
  p_dest  LIKE tsp03l-lname MODIF ID dst.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-002.
PARAMETERS:
  radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X',
  radio2 RADIOBUTTON GROUP grp1,
  radio4 RADIOBUTTON GROUP grp1,
  radio5 RADIOBUTTON GROUP grp1,
  radio3 RADIOBUTTON GROUP grp1,
  radio6 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK data1.

INCLUDE zabp_smartform.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  SELECT SINGLE a~spld b~lname
    FROM usr01 AS a JOIN tsp03l AS b ON a~spld EQ b~padest
    INTO (va_spld, p_dest)
    WHERE a~bname EQ sy-uname.

  DATA: lv_parva(40).

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'BUK'.

  IF sy-subrc EQ 0.
    pa_bukrs  = lv_parva.
  ENDIF.

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'VKB'.

  IF sy-subrc EQ 0.
    pa_vkbur  = lv_parva.
  ENDIF.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen_1000.

*&---------------------------------------------------------------------*
*& selection-screen.
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

TOP-OF-PAGE.
  IF radio6 EQ 'X'.
    sy-title = 'PENYELESAIAN BLOCK A/R'.
    PERFORM f_top_of_page.
  ENDIF.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  DATA: answer.

  IF pa_bukrs EQ '8070'.
    p_tdform    = 'ZF_BLOK_AR_V3_SUT'.
  ENDIF.

  IF va_error IS INITIAL.
    PERFORM f_init_data.
    PERFORM f_get_data.
    PERFORM f_table_locking.
    PERFORM f_process_data.
    PERFORM f_le_zero.
    IF radio5 EQ 'X'.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar      = 'Print'
          text_question = space
          text_button_1 = 'Preview'
          icon_button_1 = 'ICON_LAYOUT_CONTROL'
          text_button_2 = 'Print'
          icon_button_2 = 'ICON_SYSTEM_PRINT'
        IMPORTING
          answer        = answer.

      CASE answer.
        WHEN '1'.
          PERFORM f_reprint_form.

        WHEN '2'.
          va_print = 1.
          PERFORM f_reprint_form.
      ENDCASE.
    ELSE.
      IF radio6 EQ 'X'.
        PERFORM f_print_data_radio6.
      ELSE.
        PERFORM f_print_data.
      ENDIF.
    ENDIF.

    PERFORM f_free_memory.
  ENDIF.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zf_blok_ar_v1sf_f01.

*------------------common includes for the program---------------------*
