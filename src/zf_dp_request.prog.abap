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
REPORT zf_dp_request NO STANDARD PAGE HEADING
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
INCLUDE zf_dp_requesttop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : so_belnr FOR bkpf-belnr MODIF ID bel.
PARAMETERS : pa_bukrs  LIKE t001-bukrs MODIF ID buk.
PARAMETERS : pa_gjahr  LIKE bkpf-gjahr MODIF ID gja DEFAULT sy-datum(4).
SELECTION-SCREEN END OF BLOCK b1.

*SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
*PARAMETERS: ra_kr RADIOBUTTON GROUP radi USER-COMMAND rad DEFAULT 'X',
*            ra_re RADIOBUTTON GROUP radi,
*            ra_sa RADIOBUTTON GROUP radi.
*SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF SCREEN 500 AS WINDOW TITLE TEXT-003.
PARAMETERS pa_xblnr TYPE xblnr.
PARAMETERS pa_belnr TYPE belnr_d.
PARAMETERS pa_budat TYPE budat.
PARAMETERS pa_name  TYPE name1 MODIF ID kmm.
PARAMETERS pa_text  TYPE zfbank MODIF ID pli.
SELECTION-SCREEN SKIP.
PARAMETERS pa_autho TYPE char12 MODIF ID kmm.
PARAMETERS pa_verif TYPE char12 MODIF ID kmm.
PARAMETERS pa_appro TYPE char12 MODIF ID kmm.
PARAMETERS pa_input TYPE char12 MODIF ID kmm.
PARAMETERS pa_recei TYPE char12 MODIF ID kmm.
PARAMETERS pa_banka TYPE banka  MODIF ID tu1.
PARAMETERS pa_koinh TYPE koinh_fi MODIF ID tu2.
PARAMETERS pa_bankn TYPE bankn  MODIF ID tu3.
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
    IF screen-name EQ '%_PA_BUDAT_%_APP_%-TEXT'.
      %_pa_budat_%_app_%-text = 'Due Date'.
      MODIFY SCREEN.
    ENDIF.

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

    IF ( screen-group1 EQ 'TU1' OR screen-group1 EQ 'TU2' OR screen-group1 EQ 'TU3' )
       AND pa_bukrs NE '8190'.
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
    WHEN OTHERS.
      IF pa_bukrs = '8190' AND sy-dynnr  = '0500'.
        DATA(lv_waers) = VALUE #( gt_out[ check =	'X'
                                          waers =	'IDR' ]-waers OPTIONAL ).
        IF lv_waers = 'IDR'.
          IF pa_banka IS INITIAL.
            PERFORM f_error_selection_screen USING 'TU1' '0'.
          ENDIF.
          IF pa_koinh IS INITIAL.
            PERFORM f_error_selection_screen USING 'TU2' '0'.
          ENDIF.
          IF pa_bankn IS INITIAL.
            PERFORM f_error_selection_screen USING 'TU3' '0'.
          ENDIF.
        ENDIF.
        CLEAR lv_waers.
      ENDIF.
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
  INCLUDE zf_dp_requestf01.

*------------------common includes for the program---------------------*
