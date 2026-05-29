*&---------------------------------------------------------------------*
*& Program Name     : ZGDPP_R0012                                      *
*& Module Name      : PP                                               *
*& Author           : xxxxxx xxx , xxxxx xxxxx                         *
*& Functional       :                                                  *
*& Create Date      : dd/mm/yyyy                                       *
*& Program Type     : Report                                           *
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
REPORT zgdpp_r0012
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
INCLUDE zgdppr0012top.
*INCLUDE zibm_report_temptop.
*------------------common TOP includes for the program----------------*


*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-011.
PARAMETER: p_werks LIKE mseg-werks OBLIGATORY.
SELECTION-SCREEN END OF BLOCK data1.

* Begin subscreen 1
SELECTION-SCREEN BEGIN OF SCREEN 100 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-011.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(10) text-001.
SELECTION-SCREEN POSITION 33.
PARAMETERS: radio1 RADIOBUTTON GROUP grp1
USER-COMMAND dik DEFAULT 'X'.
SELECTION-SCREEN POSITION 35.
SELECTION-SCREEN : COMMENT 40(20) text-002 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 33.
PARAMETERS: radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN POSITION 35.
SELECTION-SCREEN : COMMENT 40(20) text-003 FOR FIELD radio2.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 33.
PARAMETERS: radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN POSITION 35.
SELECTION-SCREEN : COMMENT 40(20) text-004 FOR FIELD radio3.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 33.
PARAMETERS: radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN POSITION 35.
SELECTION-SCREEN : COMMENT 40(20) text-005 FOR FIELD radio4.
SELECTION-SCREEN END OF LINE.

PARAMETERS: p_year(4) DEFAULT sy-datum(4) MODIF ID yea.
SELECTION-SCREEN END OF BLOCK data.
SELECTION-SCREEN END OF SCREEN 100.
* End subscreen 1

* Begin subscreen 2
SELECTION-SCREEN BEGIN OF SCREEN 200 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK data2 WITH FRAME TITLE text-011.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(10) text-001.
SELECTION-SCREEN POSITION 33.
PARAMETERS: radio5 RADIOBUTTON GROUP grp2 DEFAULT 'X'.
SELECTION-SCREEN POSITION 35.
SELECTION-SCREEN : COMMENT 40(20) text-006 FOR FIELD radio5.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 33.
PARAMETERS: radio6 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN POSITION 35.
SELECTION-SCREEN : COMMENT 40(20) text-007 FOR FIELD radio6.
SELECTION-SCREEN END OF LINE.

PARAMETERS: p_year1(4) DEFAULT sy-datum(4) MODIF ID yea.
SELECTION-SCREEN END OF BLOCK data2.
SELECTION-SCREEN END OF SCREEN 200.
* End subscreen 2

* STANDARD SELECTION SCREEN
SELECTION-SCREEN: BEGIN OF TABBED BLOCK mytab FOR 10 LINES,
                  TAB (20) button1 USER-COMMAND push1,
                  TAB (20) button2 USER-COMMAND push2,
                  END OF BLOCK mytab.

*SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK sign WITH FRAME TITLE text-999.
PARAMETERS: p_sign(24),
            p_sik(24).
SELECTION-SCREEN END OF BLOCK sign.
*SELECTION-SCREEN SKIP 1.
PARAMETERS: p_vari  LIKE disvariant-variant. " ALV Variant

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  button1 = text-100.
  button2 = text-200.
  mytab-prog = sy-repid.
  mytab-dynnr = 100.
  mytab-activetab = 'BUTTON1'.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_werks.
*-Authorization
  macro_atz_single_werks p_werks c_atz_display.


*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
***modified by Rahmadi --- no need to block for input
*      LOOP AT SCREEN.
*        IF SCREEN-GROUP1 = 'YEA'.
*          SCREEN-INPUT = 0.
*          MODIFY SCREEN.
*        ENDIF.
*      ENDLOOP.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sy-dynnr.
    WHEN 1000.
      CASE sy-ucomm.
        WHEN 'PUSH1'.
          mytab-dynnr     = 100.
          mytab-activetab = 'BUTTON1'.
          option = 0.
        WHEN 'PUSH2'.
          mytab-dynnr     = 200.
          mytab-activetab = 'BUTTON2'.
          option = 1.
      ENDCASE.
  ENDCASE.

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
  INCLUDE zgdppr0012f01.
  INCLUDE zgdppr0012f011.  " Include for produksi Obat jadi
  INCLUDE zgdppr0012f012.  " Include for produksi Obat tradisional
*  INCLUDE zibm_report_tempf01.
*------------------common includes for the program---------------------*

*Selection texts
*---------------
*SP_CHK1          CBU Delivery
*SP_CHK2          Trimming Off
*SP_CHK4          Welding Off
*SP_DATE          Month
*SS_WERKS         Plant
