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
*& DEVK935916     19.08.2013                  Modifikasi untuk SUT     *
*&                                            Project                  *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zf_posting_kr1a_v1 NO STANDARD PAGE HEADING
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
INCLUDE zf_posting_kr1a_v1top.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS:
  pa_bukrs LIKE bsid-bukrs OBLIGATORY DEFAULT '8020'.
SELECT-OPTIONS:
  so_vkbur FOR knvv-vkbur MODIF ID vkb,
  so_kunnr FOR bsid-kunnr,
  so_zuonr FOR bsid-zuonr,
  so_dform FOR zfh_kr1at-dtform MODIF ID dfo,
  so_nform FOR zfh_kr1at-noform.
PARAMETERS:
  pa_lewat LIKE bsid-zbd1t DEFAULT '60' MODIF ID lew.
SELECT-OPTIONS:
  so_stat FOR zfh_kr1at-status NO INTERVALS MODIF ID sta.
SELECTION-SCREEN SKIP 1.
PARAMETERS:
  pa_budat LIKE bsid-budat MODIF ID dat.
SELECTION-SCREEN SKIP 1.
PARAMETERS:
  pa_backg AS CHECKBOX MODIF ID bac USER-COMMAND chk.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-002.
PARAMETERS: radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
*PARAMETERS: radio2 RADIOBUTTON GROUP grp1.
PARAMETERS: radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(50) text-003 FOR FIELD radio5.
SELECTION-SCREEN END OF LINE.
PARAMETERS: radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK data1.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  SELECT status
    FROM zfhstatus
    INTO CORRESPONDING FIELDS OF TABLE t_zfhstatus
    WHERE zflag EQ space  AND
          bukrs EQ gv_bukrs.

  LOOP AT t_zfhstatus.
    so_stat-low    = t_zfhstatus-status.
    so_stat-sign   = 'I'.
    so_stat-option = 'EQ'.
    APPEND so_stat.
  ENDLOOP.

  CLEAR: t_zfhstatus.
  REFRESH: t_zfhstatus.

  DATA: lv_parva(40).

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'BUK'.

  IF sy-subrc EQ 0.
    pa_bukrs  = lv_parva.
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

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_table_locking.
  PERFORM f_process_data.

  IF pa_backg IS INITIAL.
    PERFORM f_print_data.
  ELSE.
    CASE 'X'.
      WHEN radio1.
        LOOP AT t_out.
          t_out-check = 'X'.
          MODIFY t_out TRANSPORTING check.
        ENDLOOP.

        PERFORM f_validate_data.

      WHEN radio5.
        LOOP AT t_zfh_kr1at.
          t_zfh_kr1at-check = 'X'.
          MODIFY t_zfh_kr1at TRANSPORTING check.
        ENDLOOP.
    ENDCASE.

    PERFORM f_post_entries.
    PERFORM f_table_unlocking.
  ENDIF.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zf_posting_kr1a_v1f01.

*------------------common includes for the program---------------------*
