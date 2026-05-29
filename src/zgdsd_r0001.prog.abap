*&---------------------------------------------------------------------*
*& Program Name     : ZGDSD_R0001                                      *
*& Module Name      : SD                                               *
*& Author           : Budi Pramono                                     *
*& Functional       :                                                  *
*& Create Date      : 17/03/2005                                       *
*& Program Type     : Report/Enhancement                               *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*& Description      : Order Monitoring Report                          *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zgdsd_r0001 MESSAGE-ID zgdsd
               NO STANDARD PAGE HEADING
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
INCLUDE zgdsdr0001top.
*INCLUDE zibm_report_temptop.
*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.

*SELECT-OPTIONS: p_vkorg FOR vbak-vkorg OBLIGATORY,
PARAMETERS: p_vkorg LIKE vbak-vkorg OBLIGATORY.
SELECT-OPTIONS: s_vkbur FOR vbak-vkbur,
                s_auart FOR vbak-auart OBLIGATORY MODIF ID aaa,
                s_bsart FOR ekko-bsart OBLIGATORY MODIF ID bbb,
                s_mtart FOR mara-mtart,
                s_vbeln FOR vbak-vbeln MODIF ID aaa,
                s_ebeln FOR ekko-ebeln MODIF ID bbb,
                s_kunnr FOR vbak-kunnr,
                s_matnr FOR vbap-matnr,
*                s_bstnk FOR vbak-bstnk MODIF ID aaa,
                s_bstkd FOR vbkd-bstkd MODIF ID aaa,
                s_date  FOR vbak-bstdk NO-DISPLAY.

SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-008.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_bstdk RADIOBUTTON GROUP grp2 DEFAULT 'X'
                    USER-COMMAND group2.
SELECTION-SCREEN COMMENT 5(23) text-006 FOR FIELD p_bstdk.
SELECTION-SCREEN POSITION 30.
SELECT-OPTIONS s_bstdk FOR vbak-bstdk MODIF ID 001.
SELECTION-SCREEN : END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_erdat RADIOBUTTON GROUP grp2.
SELECTION-SCREEN COMMENT 5(23) text-007 FOR FIELD p_erdat.
SELECTION-SCREEN POSITION 30.
SELECT-OPTIONS s_erdat FOR vbak-erdat MODIF ID 002.
SELECTION-SCREEN : END OF LINE.

SELECTION-SCREEN END OF BLOCK data1.

SELECTION-SCREEN BEGIN OF BLOCK data2 WITH FRAME TITLE text-003.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_so RADIOBUTTON GROUP grp1 DEFAULT 'X' USER-COMMAND group1.
SELECTION-SCREEN COMMENT 5(40) text-004 FOR FIELD p_so.
SELECTION-SCREEN : END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_po RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(40) text-005 FOR FIELD p_po.
SELECTION-SCREEN : END OF LINE.

SELECTION-SCREEN END OF BLOCK data2.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE text-002.
PARAMETERS: p_vari  LIKE disvariant-variant. " ALV Variant
SELECTION-SCREEN END OF BLOCK block2.


*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

  DATA: l_date(10),
        l_todate LIKE sy-datum.

  s_date-sign   = 'I'.
  s_date-option = 'BT'.
  CONCATENATE sy-datum(6) '01' INTO s_date-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
       EXPORTING
            day_in            = s_date-low
       IMPORTING
            last_day_of_month = s_date-high
       EXCEPTIONS
            day_in_no_date    = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  APPEND s_date.

  s_bstdk[] = s_date[].

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_vkorg.
  macro_atz_single_vkorg p_vkorg c_atz_display.

AT SELECTION-SCREEN ON s_vkbur.
* DATA : ld_vkbur LIKE tvbur-vkbur.
* SELECT vkbur INTO ld_vkbur
*   FROM tvbur WHERE vkbur IN s_vkbur.
*   macro_atz_single_vkbur ld_vkbur c_atz_display.
*   CLEAR ld_vkbur.
* ENDSELECT.

AT SELECTION-SCREEN ON RADIOBUTTON GROUP grp2.
*  IF p_bstdk = 'X' AND s_bstdk[] IS INITIAL.
*    MESSAGE i000(zgdsd) WITH 'Period Must Entry'.
*  ELSEIF p_erdat = 'X' AND s_erdat[] IS INITIAL.
*    MESSAGE i000(zgdsd) WITH 'Period Must Entry'.
*  ENDIF.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF p_so = 'X' AND p_po = 'X'.
    ELSE.
      IF p_so IS INITIAL AND p_po IS INITIAL.
        IF screen-group1 = 'AAA'.
          screen-active = '0'.
        ENDIF.
        IF screen-group1 = 'BBB'.
          screen-active = '0'.
        ENDIF.
      ELSE.
        IF p_so = 'X'.
          IF screen-group1 = 'BBB'.
            screen-active = '0'.
          ENDIF.
        ENDIF.
        IF p_po = 'X'.
          IF screen-group1 = 'AAA'.
            screen-active = '0'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    IF p_bstdk = 'X'.
      CLEAR s_erdat. REFRESH s_erdat.
      IF s_bstdk[] IS INITIAL.
        s_bstdk[] = s_date[].
      ENDIF.
      IF screen-group1 = '002'.
        screen-input = '0'.
      ENDIF.
    ELSE.
      CLEAR s_bstdk. REFRESH s_bstdk.
      IF s_erdat[] IS INITIAL.
        s_erdat[] = s_date[].
      ENDIF.
      IF screen-group1 = '001'.
        screen-input = '0'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
* for alv variant
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f_f4_for_variant_alv USING p_vari.
*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  CHECK NOT s_bsart[] IS INITIAL OR NOT s_auart[] IS INITIAL.
  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_validate_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.
*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zgdsdr0001f01.
*  INCLUDE zibm_report_tempf01.
*------------------common includes for the program---------------------*



*Selection texts
*---------------
*SP_CHK1          CBU Delivery
*SP_CHK2          Trimming Off
*SP_CHK4          Welding Off
*SP_DATE          Month
*SS_WERKS         Plant
