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
REPORT zwm_print_to NO STANDARD PAGE HEADING
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
INCLUDE zwm_print_totop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_lgnum       LIKE ltap-lgnum OBLIGATORY MODIF ID lgn.
SELECT-OPTIONS so_lgtyp   FOR ltap-nltyp OBLIGATORY MODIF ID lgt
                                         NO INTERVALS.
SELECT-OPTIONS so_mblnr   FOR ltak-mblnr MODIF ID mbl.
SELECT-OPTIONS so_tanum   FOR ltak-tanum MODIF ID tan.
SELECT-OPTIONS so_bdatu   FOR ltak-bdatu MODIF ID bdt.
SELECT-OPTIONS so_tknum   FOR vttp-tknum MODIF ID stk.
SELECT-OPTIONS so_kunnr   FOR likp-kunnr MODIF ID sku
                                         NO INTERVALS
                                         NO-EXTENSION.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_drukz   LIKE rldru-drukz OBLIGATORY DEFAULT '45'
                                       MODIF ID dru.
PARAMETERS pa_form AS CHECKBOX MODIF ID pfr USER-COMMAND pck.
PARAMETERS pa_druck AS CHECKBOX MODIF ID pto.
PARAMETERS pa_d2 AS CHECKBOX MODIF ID pt2.
PARAMETERS pa_akhir AS CHECKBOX MODIF ID pak.
PARAMETERS pa_lprio AS CHECKBOX MODIF ID lpr.
PARAMETERS pa_spld  TYPE usdefaults-spld NO-DISPLAY.
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
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_drukz.
  PERFORM f_value_drukz USING 'PA_DRUKZ'.

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
  DATA rspar_tab TYPE TABLE OF rsparams.

  PERFORM f_init_data.
  CASE pa_drukz.
*    WHEN '48'.
*      PERFORM f_get_data_48.
*      PERFORM f_process_data_48.
*      IF gt_out[] IS NOT INITIAL.
*        IF pa_form IS INITIAL.
*          PERFORM f_print_data.
*        ELSE.
*          PERFORM f_print_form_48 USING '&GRP'.
*        ENDIF.
*      ELSE.
*        CASE pa_lgnum.
*          WHEN 'C40'.
*            PERFORM f_submit_parameter TABLES rspar_tab
*                                       USING : 'PA_LGNUM' pa_lgnum 'P',
*                                               'PA_TKNUM' so_tknum-low 'P'.
*            SUBMIT zwm_print_to_group WITH SELECTION-TABLE rspar_tab AND RETURN.
*            CLEAR : rspar_tab[].
*        ENDCASE.
*      ENDIF.
    WHEN OTHERS.
      PERFORM f_get_data.
      IF pa_lprio = 'X'.
        PERFORM f_print_data.
      ELSE.
        IF pa_lgnum(2) = '38' AND
          pa_drukz = '47'.
          PERFORM f_tdn_process_data.
        ELSE.
          PERFORM f_process_data.
        ENDIF.
        IF pa_form IS INITIAL.
          PERFORM f_print_data.
        ELSE.
          PERFORM f_print_form TABLES gt_out
                               USING '&POS'.
        ENDIF.
      ENDIF.
  ENDCASE.

  PERFORM f_free_memory.


*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zwm_print_tof01.

  INCLUDE zwm_print_tof02.

*------------------common includes for the program---------------------*
