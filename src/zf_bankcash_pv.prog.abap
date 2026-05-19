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
REPORT zf_bankcash_pv NO STANDARD PAGE HEADING
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
INCLUDE zf_bankcash_pvtop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS : so_belnr FOR bkpf-belnr MODIF ID bel.
PARAMETERS : pa_bukrs  LIKE t001-bukrs MODIF ID buk.
PARAMETERS : pa_gjahr  LIKE bkpf-gjahr MODIF ID gja DEFAULT sy-datum(4).
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS: ra_kr RADIOBUTTON GROUP radi USER-COMMAND rad DEFAULT 'X',
            ra_re RADIOBUTTON GROUP radi,
            ra_sa RADIOBUTTON GROUP radi,
            ra_krre RADIOBUTTON GROUP radi.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF SCREEN 500 AS WINDOW TITLE text-003.
PARAMETERS pa_xblnr TYPE xblnr.
PARAMETERS pa_belnr TYPE belnr_d.
PARAMETERS pa_budat TYPE budat MODIF ID pbu.
PARAMETERS pa_name  TYPE name1 MODIF ID kmm.
PARAMETERS pa_text  TYPE zfbank MODIF ID pli.
SELECTION-SCREEN SKIP.
PARAMETERS pa_autho TYPE char08 MODIF ID kmm.
PARAMETERS pa_verif TYPE char08 MODIF ID kmm.
PARAMETERS pa_auth1 TYPE char08 MODIF ID kmm.
PARAMETERS pa_appro TYPE char08 MODIF ID kmm.
PARAMETERS pa_input TYPE char08 MODIF ID kmm.
PARAMETERS pa_veri1 TYPE char08 MODIF ID kmm.
PARAMETERS pa_rele1 TYPE char08 MODIF ID kmm.
PARAMETERS pa_rele2 TYPE char08 MODIF ID kmm.
PARAMETERS pa_recv1 TYPE char08 MODIF ID kmm.
*PARAMETERS pa_recei TYPE char12 MODIF ID kmm.
SELECTION-SCREEN END OF SCREEN 500.


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
  LOOP AT SCREEN.
    CASE pa_bukrs.
      WHEN '8330'.
        IF screen-name EQ '%_PA_BUDAT_%_APP_%-TEXT'.
          %_pa_budat_%_app_%-text = 'Posting Date'.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 EQ 'PBU'.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      WHEN OTHERS.
        IF screen-name EQ '%_PA_BUDAT_%_APP_%-TEXT'.
          %_pa_budat_%_app_%-text = 'Due Date'.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.

    IF ( screen-name EQ '%_PA_TEXT_%_APP_%-TEXT' OR
       screen-name EQ 'PA_TEXT' ) AND
*       ( pa_bukrs NE '8330' OR pa_bukrs NE '8040' ).
      ( pa_bukrs NE '8330' AND pa_bukrs NE '8360' ).
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.

    IF screen-group1 EQ 'KMM'
       AND pa_bukrs NE '8360'.
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.
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
  INCLUDE zf_bankcash_pvf01.

*------------------common includes for the program---------------------*
