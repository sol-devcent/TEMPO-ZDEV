*&---------------------------------------------------------------------*
*& Program Name     : ZGDSD_R0002                                      *
*& Module Name      : SD                                               *
*& Author           : Budi Heru Santosa                                *
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
*&        01-06-2005                                                 *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zgdsd_r0002
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
INCLUDE zgdsdr0002top.
*INCLUDE zgdsdr0001top.
*INCLUDE zibm_report_temptop.
*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.

**SELECT-OPTIONS: s_werks FOR pbim-werks,
**                s_matnr FOR mara-matnr.
**
**PARAMETERS: p_date LIKE sy-datum OBLIGATORY.
**

PARAMETERS: p_vkorg LIKE vbak-vkorg OBLIGATORY.
** DEFAULT '8010'.

SELECT-OPTIONS: s_vkbur FOR vbak-vkbur NO INTERVALS OBLIGATORY,
                s_kunnr FOR kna1-kunnr,
                s_kunrg FOR vbrk-kunrg,
                s_vbeln FOR vbrk-vbeln,
                s_mtart FOR mara-mtart NO INTERVALS,
                s_matnr FOR mara-matnr,
                s_matkl FOR mara-matkl NO INTERVALS,
                s_bsart FOR ekko-bsart NO INTERVALS MODIF ID bbb,
                s_auart FOR vbak-auart NO INTERVALS MODIF ID aaa.

SELECTION-SCREEN END OF BLOCK data.


SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-002.


SELECT-OPTIONS: s_fkdat FOR vbrk-fkdat OBLIGATORY.
**PARAMETERS: p_chk1 AS CHECKBOX DEFAULT 'X',
**            p_chk2 AS CHECKBOX DEFAULT 'X',
**            p_chk3 AS CHECKBOX DEFAULT 'X',
**            p_chk4 AS CHECKBOX DEFAULT 'X',
**            p_chk5 AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK data1.


SELECTION-SCREEN BEGIN OF BLOCK data2 WITH FRAME TITLE text-003.

PARAMETERS: p_so AS CHECKBOX DEFAULT 'X' USER-COMMAND group1,
            p_po AS CHECKBOX DEFAULT 'X' USER-COMMAND group1.

SELECTION-SCREEN END OF BLOCK data2.


SELECTION-SCREEN BEGIN OF BLOCK data3 WITH FRAME TITLE text-004.

PARAMETERS: p_vari  LIKE disvariant-variant. " ALV Variant

SELECTION-SCREEN END OF BLOCK data3.


*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
*  s_bsart-sign = 'I'.
*  s_bsart-option = 'EQ'.
*  s_bsart-low = 'ZSUB'.
*  append s_bsart.
*  s_bsart-sign = 'I'.
*  s_bsart-option = 'EQ'.
*  s_bsart-low = 'ZB'.
*  append s_bsart.
*  s_bsart-sign = 'I'.
*  s_bsart-option = 'EQ'.
*  s_bsart-low = 'RZB'.
*  append s_bsart.

  s_fkdat-sign   = 'I'.
  s_fkdat-option = 'BT'.
  CONCATENATE sy-datum(6) '01' INTO s_fkdat-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
       EXPORTING
            day_in            = s_fkdat-low
       IMPORTING
            last_day_of_month = s_fkdat-high
       EXCEPTIONS
            day_in_no_date    = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  APPEND s_fkdat.



*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
**AT SELECTION-SCREEN ON p_date.


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
    MODIFY SCREEN.
  ENDLOOP.


AT SELECTION-SCREEN ON p_po.
  IF p_so NE 'X' AND p_po NE 'X'.
    MESSAGE e000(zab) WITH 'PO or SO must selected'.
  ENDIF.

AT SELECTION-SCREEN ON p_so.
  IF p_so NE 'X' AND p_po NE 'X'.
    MESSAGE e000(zab) WITH 'PO or SO must selected'.
  ENDIF.

AT SELECTION-SCREEN ON p_vkorg.
  IF p_vkorg NE '8010' AND p_vkorg NE '8090' AND
    p_vkorg NE '8030' AND p_vkorg NE '8040'.
*{   REPLACE        P01K900131                                        1
*\    MESSAGE e000(zab) WITH 'Not valid Sales Organization (only 8010 OR
*\8090)'.
    MESSAGE e000(zab) WITH
      'Not valid Sales Organization'.
*}   REPLACE
  ENDIF.

*AT SELECTION-SCREEN ON s_bsart.
*  LOOP AT s_bsart.
*    IF s_bsart-low EQ 'ZSUB' OR
*       s_bsart-low EQ 'ZB' OR
*       s_bsart-low EQ 'RZB'.
*    ELSE.
*      MESSAGE e000(zab) WITH 'Not valid PO Type'.
*      EXIT.
*    ENDIF.
*  ENDLOOP.

*AT SELECTION-SCREEN ON s_auart.
*  LOOP AT s_auart.
*    IF s_auart-low EQ 'ZO01' OR
*       s_auart-low EQ 'ZO02' OR
*       s_auart-low EQ 'ZO03' OR
*       s_auart-low EQ 'ZR01' OR
*       s_auart-low EQ 'ZR02' OR
*       s_auart-low EQ 'ZR03' OR
*       s_auart-low EQ 'ZA00' OR
*       s_auart-low EQ 'ZA01' OR
*       s_auart-low EQ 'ZA02' OR
*       s_auart-low EQ 'ZA03' OR
*       s_auart-low EQ 'ZA04' OR
*       s_auart-low EQ 'ZA05' OR
*       s_auart-low EQ 'ZA06'.
*    ELSE.
*      MESSAGE e000(zab) WITH 'Not valid SO Type'.
*      EXIT.
*    ENDIF.
*  ENDLOOP.

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
  INCLUDE zgdsdr0002f01.
*  INCLUDE zgdsdr0001f01.
*  INCLUDE zibm_report_tempf01.
*------------------common includes for the program---------------------*



*Selection texts
*---------------
*SP_CHK1          CBU Delivery
*SP_CHK2          Trimming Off
*SP_CHK4          Welding Off
*SP_DATE          Month
*SS_WERKS         Plant
