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
REPORT zf_jurnal_expv1 NO STANDARD PAGE HEADING.
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
INCLUDE zf_jurnal_expv1top.

INCLUDE zf_jurnal_expv1c01.
*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_bukrs   LIKE zf63typeexp-bukrs MODIF ID pbu.
PARAMETERS pa_vkbur   LIKE tvbur-vkbur MODIF ID pvk.
SELECT-OPTIONS so_vkbur   FOR tvbur-vkbur MODIF ID svk.
PARAMETERS pa_gsber   LIKE zf63pddklk-gsber MODIF ID pgs NO-DISPLAY.
SELECT-OPTIONS so_gsber   FOR zf63pddklk-gsber MODIF ID sgs NO-DISPLAY.
PARAMETERS pa_ctype   LIKE zf63ctrltype-type_ctrl MODIF ID pct.
PARAMETERS pa_gtype   LIKE zf63typeexp-gtype MODIF ID pgt.
SELECT-OPTIONS so_gtype   FOR zf63typeexp-gtype MODIF ID sgt.
PARAMETERS pa_zidno   LIKE zf63masterperson-zidno MODIF ID pid.
SELECT-OPTIONS so_zidno   FOR zf63masterperson-zidno MODIF ID sid.
PARAMETERS pa_zidke   LIKE zf63masterkend-zidke MODIF ID pke.
SELECT-OPTIONS so_expnr   FOR zf63trndtl-expnr MODIF ID sen.
SELECT-OPTIONS so_name1   FOR zf63masterperson-name1 MODIF ID sna.
SELECT-OPTIONS so_nopol   FOR zf63masterkend-znopol MODIF ID sno.
PARAMETERS pa_zidvc   LIKE zf63trnvch-zidvc MODIF ID pvc.
PARAMETERS pa_zidv2   LIKE zf63trnhdr2-zidvc MODIF ID pv2.
SELECT-OPTIONS so_zidvc   FOR zf63trnvch-zidvc MODIF ID svc.
SELECT-OPTIONS so_zidv2   FOR zf63trnhdr2-zidvc MODIF ID sv2.
PARAMETERS pa_belnr   LIKE zf63trnhdr2-belnrpadv MODIF ID pbe.
PARAMETERS pa_vjahr   LIKE zf63trnvch-vjahr MODIF ID pvj DEFAULT sy-datum(4).
SELECT-OPTIONS so_budat   FOR zf63trnvch-budat MODIF ID sbd
                                               NO-EXTENSION.
PARAMETERS pa_stida   LIKE rfpdo-allgstid MODIF ID pst DEFAULT sy-datum.
SELECTION-SCREEN BEGIN OF BLOCK reference WITH FRAME TITLE TEXT-004.
SELECTION-SCREEN END OF BLOCK reference.
SELECTION-SCREEN BEGIN OF BLOCK type WITH FRAME TITLE TEXT-005.
PARAMETERS pa_chk1  AS CHECKBOX MODIF ID chk USER-COMMAND chk.
PARAMETERS pa_chk2  AS CHECKBOX MODIF ID chk USER-COMMAND chk.
PARAMETERS pa_chk3  AS CHECKBOX MODIF ID chk USER-COMMAND chk.
SELECTION-SCREEN END OF BLOCK type.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
PARAMETERS radio14 RADIOBUTTON GROUP grp1 MODIF ID r14.
PARAMETERS radio4 RADIOBUTTON GROUP grp1 MODIF ID r04.
PARAMETERS radio15 RADIOBUTTON GROUP grp1 MODIF ID r15.
PARAMETERS radio5 RADIOBUTTON GROUP grp1 MODIF ID r05.
PARAMETERS radio8 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio6 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(20) TEXT-061 FOR FIELD radio6.
SELECTION-SCREEN POSITION 25.
PARAMETERS : p_timde6 AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN COMMENT 30(20) TEXT-062 FOR FIELD p_timde6.
SELECTION-SCREEN : END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio17 RADIOBUTTON GROUP grp1 MODIF ID r17.
SELECTION-SCREEN COMMENT 5(20) TEXT-171 FOR FIELD radio17.
SELECTION-SCREEN POSITION 25.
PARAMETERS : p_timde7 AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN COMMENT 30(20) TEXT-062 FOR FIELD p_timde7.
SELECTION-SCREEN : END OF LINE.
PARAMETERS radio7 RADIOBUTTON GROUP grp1.
PARAMETERS radio9 RADIOBUTTON GROUP grp1 MODIF ID r09.
PARAMETERS radio10 RADIOBUTTON GROUP grp1 MODIF ID r10.
PARAMETERS radio11 RADIOBUTTON GROUP grp1 MODIF ID r11.
PARAMETERS radio12 RADIOBUTTON GROUP grp1 MODIF ID r12.
PARAMETERS radio13 RADIOBUTTON GROUP grp1 MODIF ID r13.
*PARAMETERS radio16 RADIOBUTTON GROUP grp1 MODIF ID r16.

*** data ini untuk proses cancel advance yg ditrigger dari timdes

PARAMETERS : p_timdes(1) NO-DISPLAY. " AS CHECKBOX DEFAULT 'X'.

PARAMETERS c_refer TYPE char40 DEFAULT 'Test char40' NO-DISPLAY.
PARAMETERS c_date TYPE sy-datum DEFAULT sy-datum NO-DISPLAY.
PARAMETERS c_hkont TYPE zf63trnhdr2-hkont DEFAULT '0112100020' NO-DISPLAY.

SELECTION-SCREEN END OF BLOCK option.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  gv_repid    = sy-repid.

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
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_zidke.
  PERFORM f_value_zidke USING 'PA_ZIDKE'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_zidno.
  PERFORM f_value_zidno USING 'PA_ZIDNO'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_zidvc.
  PERFORM f_value_zidvc USING 'PA_ZIDVC'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_zidv2.
  PERFORM f_value_zidvc USING 'PA_ZIDV2'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_ctype.
  PERFORM f_value_ctype USING 'PA_CTYPE'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_gtype.
  PERFORM f_value_gtype USING 'PA_GTYPE'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_gtype-low.
  PERFORM f_value_gtype USING 'SO_GTYPE-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_gtype-high.
  PERFORM f_value_gtype USING 'SO_GTYPE-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_name1-low.
  PERFORM f_value_name1 USING 'SO_NAME1-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_name1-high.
  PERFORM f_value_name1 USING 'SO_NAME1-HIGH'.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

*  CASE 'X'.
*    WHEN radio16.
*      CALL TRANSACTION 'ZF63R'.
*    WHEN OTHERS.
  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_process_data.
  "  PERFORM f_print_data.
  IF p_timdes = 'X' AND sy-tcode NE 'ZF63N'.
    IF  radio6 = 'X'.
      IF gt_out[] IS NOT INITIAL.
        PERFORM handle_user_command USING '&POS'.
      ENDIF.
    ELSEIF radio17 = 'X'.
      PERFORM handle_user_command USING '&POS'.
    ENDIF.
  ELSE.
    PERFORM f_print_data.
  ENDIF.


  PERFORM f_free_memory.
*  ENDCASE.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

TOP-OF-PAGE.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zf_jurnal_expv1f01.

  INCLUDE zf_jurnal_expv1m01.
*------------------common includes for the program---------------------*
