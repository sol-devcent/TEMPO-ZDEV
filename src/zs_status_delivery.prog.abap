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
REPORT zs_status_delivery NO STANDARD PAGE HEADING
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
INCLUDE zs_status_deliverytop.

INCLUDE zabp_tc.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS : pa_vstel TYPE vstel MODIF ID pvs.
SELECT-OPTIONS so_tknum   FOR vttk-tknum NO INTERVALS MODIF ID stk.
SELECT-OPTIONS so_vbeln   FOR likp-vbeln MODIF ID svb.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_mds AS CHECKBOX MODIF ID mds.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-003.
PARAMETERS pa_std  RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS pa_ext  RADIOBUTTON GROUP grp1.
PARAMETERS pa_conv RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.

SELECTION-SCREEN BEGIN OF SCREEN 900 AS WINDOW TITLE text-002.
PARAMETERS pa_zstat   LIKE zmshphist-zreason MODIF ID pzs.
PARAMETERS pa_preda   LIKE zmm_cust_rec-predat.
PARAMETERS pa_preti   LIKE zmm_cust_rec-pretim.
SELECTION-SCREEN END OF SCREEN 900.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
*  PERFORM f_get_parameters USING ''
*                           CHANGING pa_value.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON ( PARAMETERS )
*---------------------------------------------------------------------*
AT SELECTION-SCREEN on RADIOBUTTON GROUP grp1.
  IF pa_conv = 'X'.
      AUTHORITY-CHECK OBJECT 'ZCFCR2'
          ID 'ACTVT' FIELD '10'.
      IF sy-subrc NE 0.
        MESSAGE 'You are not authorize' TYPE 'E'.
      ENDIF.
  ENDIF.

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
    WHEN 'CRET'.
      IF gv_flag IS NOT INITIAL.
        IF pa_zstat IS NOT INITIAL.
          IF pa_zstat <> '99'.
            PERFORM f_screen_error USING 'PZS' 'Kode reason salah'.
          ENDIF.
        ENDIF.
      ELSE.
        IF pa_zstat IS NOT INITIAL.
          IF pa_zstat = '99'.
            PERFORM f_screen_error USING 'PZS' 'Reason 99 hanya untuk Ship. External'.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_zstat.
  PERFORM f_vr_zreason USING 'PA_ZSTAT' '' ''.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_process_data.
  CHECK gv_subrc IS INITIAL.
  PERFORM f_print_data.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zs_status_deliveryf01.

*------------------common includes for the program---------------------*
