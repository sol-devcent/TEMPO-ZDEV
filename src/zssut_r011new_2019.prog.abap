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
REPORT zssut_r011new_2019 NO STANDARD PAGE HEADING
                          LINE-SIZE 240.
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
INCLUDE zssut_r011new_2019top.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_vkorg  LIKE knvv-vkorg OBLIGATORY.
*PARAMETERS pa_mvgr2  LIKE s619-mvgr2 OBLIGATORY MODIF ID out.
PARAMETERS pa_mvgr2  LIKE s619-mvgr2 NO-DISPLAY.
PARAMETERS pa_vkbur  LIKE knvv-vkbur OBLIGATORY.
PARAMETERS pa_konda  LIKE knvv-konda OBLIGATORY MODIF ID kon.
SELECT-OPTIONS so_mvgr2   FOR tvm2-mvgr2 OBLIGATORY MODIF ID out.
SELECT-OPTIONS so_kunnr   FOR knvv-kunnr.
SELECT-OPTIONS so_route   FOR knvp-kunn2.
PARAMETERS pa_spmon  LIKE s619-spmon OBLIGATORY.
SELECT-OPTIONS so_gidat FOR likp-wadat_ist.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_stat AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp2 USER-COMMAND rad MODIF ID ra1.
PARAMETERS radio2 RADIOBUTTON GROUP grp2 MODIF ID ra2.
PARAMETERS radio3 RADIOBUTTON GROUP grp2 MODIF ID ra3 DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK option.

SELECTION-SCREEN BEGIN OF BLOCK out WITH FRAME TITLE text-003.
PARAMETERS r_out1 RADIOBUTTON GROUP grp3 USER-COMMAND out DEFAULT 'X' MODIF ID out.
PARAMETERS r_out2 RADIOBUTTON GROUP grp3 MODIF ID out.
SELECTION-SCREEN END OF BLOCK out.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON ( PARAMETERS )
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF radio1 IS INITIAL.
      IF screen-group1 = 'OUT'.
        screen-active  = 0.
      ENDIF.
    ENDIF.
    IF screen-group1 = 'RA2'.
      screen-active  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

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

*------------------------------------------------------
* TOP-OF-PAGE
*------------------------------------------------------
TOP-OF-PAGE.
  PERFORM f_write_header1 USING pa_mvgr2.
  SKIP 1.
  PERFORM f_write_header2.
  SKIP 1.
  PERFORM f_write_header3.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_get_paket_opp.
  PERFORM f_get_date.

  CASE 'X'.
    WHEN radio1.
      LOOP AT gt_tvm2.
        pa_mvgr2 = gt_tvm2-mvgr2.
        PERFORM f_clear_itab.
        PERFORM f_init_data.
        PERFORM f_get_data.
        PERFORM f_process_data USING gt_tvm2-mvgr2.
        CASE 'X'.
          WHEN r_out1.
*            IF pa_vkorg = '8020'.
*              PERFORM f_print_data.
*            ELSEIF pa_vkorg = '8070'.
            PERFORM f_print_data_sut.
*            ENDIF.
          WHEN r_out2.
*            IF pa_vkorg = '8020'.
*              PERFORM f_process_data_alv.
*            ELSEIF pa_vkorg = '8070'.
            PERFORM f_process_data_alv_sut.
*            ENDIF.
            PERFORM f_alv TABLES gt_out.
        ENDCASE.
        PERFORM f_free_memory.
      ENDLOOP.

    WHEN radio2.
      SUBMIT zssut_r003_2019 WITH pa_vkorg = pa_vkorg
                             WITH pa_mvgr2 = pa_mvgr2
                             WITH pa_vkbur = pa_vkbur
                             WITH pa_spmon = pa_spmon
                              VIA SELECTION-SCREEN
                              AND RETURN.

    WHEN radio3.
*      LOOP AT gt_tvm2.
*        pa_mvgr2 = gt_tvm2-mvgr2.
      PERFORM f_clear_itab.
      PERFORM f_init_data.
      PERFORM f_crt_dyn_int_table.
      PERFORM f_get_data.
*        PERFORM f_process_data3.
      PERFORM f_dyn_process.
      PERFORM f_alv TABLES <fs_gt>. "gt_out.
      PERFORM f_free_memory.
*      ENDLOOP.
  ENDCASE.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zssut_r011new_2019f01.

*------------------common includes for the program---------------------*
