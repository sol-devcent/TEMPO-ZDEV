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
REPORT zbpcwm_e0005 NO STANDARD PAGE HEADING
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
INCLUDE zbpcwm_e0005top.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF BLOCK option1 WITH FRAME.
SELECT-OPTIONS so_lgnum   FOR lagp-lgnum MODIF ID lgn
                                         NO INTERVALS
                                         NO-EXTENSION.
SELECT-OPTIONS so_lgtyp   FOR lqua-lgtyp MODIF ID lgt.
SELECTION-SCREEN END OF BLOCK option1.
SELECTION-SCREEN BEGIN OF BLOCK option2 WITH FRAME.
SELECT-OPTIONS so_whse    FOR zbpc0006-gudang MODIF ID whs.
SELECTION-SCREEN END OF BLOCK option2.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 DEFAULT 'X'
           USER-COMMAND rad.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
SELECT-OPTIONS so_lgpla   FOR lqua-lgpla.
SELECT-OPTIONS so_ivnum   FOR zbpc0005-ivnum.
SELECT-OPTIONS so_erdat   FOR zbpc0005-erdat.
SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
*  PERFORM f_get_parameters USING ''
*                           CHANGING pa_value.

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
* AT SELECTION-SCREEN ON VALUE-REQUEST
*------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_whse-low.
  PERFORM f_get_gudang CHANGING so_whse-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_whse-high.
  PERFORM f_get_gudang CHANGING so_whse-high.

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
  INCLUDE zbpcwm_e0005f01.


*------------------common includes for the program---------------------*
