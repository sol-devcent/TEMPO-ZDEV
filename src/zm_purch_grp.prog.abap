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
REPORT zm_purch_grp NO STANDARD PAGE HEADING
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
INCLUDE zm_purch_grptop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS : pa_ekorg   TYPE ekorg MODIF ID eko.
PARAMETERS : pa_ekgrp   TYPE ekgrp MODIF ID ekg.
SELECT-OPTIONS : so_zhier   FOR zmmattnt-zhier MODIF ID hie.
SELECT-OPTIONS : so_zlvl    FOR zmmattnt-zlvl MODIF ID zlv.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF SCREEN 9000.
SELECTION-SCREEN BEGIN OF BLOCK copy WITH FRAME TITLE text-001.
PARAMETERS pa_freko  TYPE ekorg OBLIGATORY.
PARAMETERS pa_frekg  TYPE ekgrp OBLIGATORY.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_toeko  TYPE ekorg OBLIGATORY.
PARAMETERS pa_toekg  TYPE ekgrp OBLIGATORY.
SELECTION-SCREEN END OF BLOCK copy.
SELECTION-SCREEN END OF SCREEN 9000.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS pa_cret RADIOBUTTON GROUP rad USER-COMMAND rad DEFAULT 'X'.
PARAMETERS pa_copy RADIOBUTTON GROUP rad.
PARAMETERS pa_chng RADIOBUTTON GROUP rad.
PARAMETERS pa_disp RADIOBUTTON GROUP rad.
SELECTION-SCREEN END OF BLOCK option.

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
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_process_data.
  IF pa_disp IS NOT INITIAL.
    PERFORM f_print_data.
  ENDIF.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zm_purch_grpf01.

*------------------common includes for the program---------------------*
