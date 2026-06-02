REPORT zgdtx_e0006 NO STANDARD PAGE HEADING.

*&---------------------------------------------------------------------*
*& Common Include section
*&---------------------------------------------------------------------*

INCLUDE zgdtxne0006top.
***Standard include -------------
INCLUDE zabp_udf.
INCLUDE zabp_header.
INCLUDE zabp_bdc.

* Includes for light
INCLUDE <icon>.
INCLUDE <symbol>.

***Standard include For Production--------
INCLUDE zabp_atz.

*&---------------------------------------------------------------------*
*& SELECT-OPTIONS / PARAMTERS / CheckBox ..etc....
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS:    p_bukrs LIKE zgdtxdt0012-bukrs
                                  OBLIGATORY MEMORY ID buk,
               p_brnch LIKE zgdtxdt0012-brnch
                                  OBLIGATORY MEMORY ID zbr.
SELECT-OPTIONS: s_busln FOR zgdtxdt0012-busln NO-DISPLAY.

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN : BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS: p_masatx LIKE zgdtxdt0012-masatx.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF SCREEN 9009 . "as window.
SELECT-OPTIONS: s_beln FOR zgdtxdt0012-belnr ,
                s_budat FOR sy-datum.
PARAMETERS: d_gjahr2 LIKE bkpf-gjahr DEFAULT sy-datum(4) OBLIGATORY.
***added for Tempo
*SELECT-OPTIONS: s_bktxt FOR bkpf-bktxt.
***end of addition
SELECTION-SCREEN END OF SCREEN 9009.

INCLUDE zgdtxne0006f01.
INCLUDE zgdtxne0006o01.
INCLUDE zgdtxne0006i01.

INITIALIZATION.
  PERFORM f_initialization.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION.
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_process_report.

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_REPORT
*&---------------------------------------------------------------------*
FORM f_process_report.

  PERFORM f_init_data.

***added by Rahmadi
*-Get Organization structure config
  CALL FUNCTION 'Z_GDTXFC_TAX_CFG_ORG_DETMN'
       EXPORTING
            fi_brnch                      = p_brnch
       IMPORTING
            fe_bukrs                      = p_bukrs
       TABLES
            ft_tx00101                    = t_tx00101
            ft_tx00102                    = t_tx00102
            ft_tx00103                    = t_tx00103
       EXCEPTIONS
            company_code_not_assigned     = 1
            business_line_not_maintained  = 2
            branch_config_not_maintained  = 3
            busline_config_not_maintained = 4
            taxconsol_config_not_maintain = 5
            OTHERS                        = 6.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        MESSAGE e000(zab) WITH 'No company code assigned to branch'.
      WHEN 2 OR 4.
        MESSAGE e000(zab) WITH 'No business line maintained'.
      WHEN 3.
        MESSAGE e000(zab) WITH 'No branch maintained'.
      WHEN 5.
        MESSAGE e000(zab) WITH 'Tax Consolidation config table'
                               'is not maintained'.
      WHEN OTHERS.
        MESSAGE e000(zab) WITH 'Fatal Error!'.
    ENDCASE.
  ENDIF.
***end of addition.

  PERFORM f_get_data.
  CASE d_error.
    WHEN 0.
      PERFORM f_write_data.
    WHEN 1.
      MESSAGE i000(zab) WITH d_posting.
    WHEN 2.
      MESSAGE ID 'AQ' TYPE 'I' NUMBER '260'.
    WHEN 3.
      MESSAGE i000(zab) WITH 'VAT-In table(ZGDTXdt0012) is locked by '
              d_posting.
  ENDCASE.
ENDFORM.                    " F_PROCESS_REPORT


*&---------------------------------------------------------------------*
*& TOP-OF-PAGE
*&---------------------------------------------------------------------*
TOP-OF-PAGE.
  PERFORM f_top_of_page.

*&---------------------------------------------------------------------*
*& AT LINE-SELECTION
*&---------------------------------------------------------------------*
*AT LINE-SELECTION.

*-----------------------------------------------------------------------
* Events on selection screens
*-----------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
*  PERFORM f_select_period.

*----------------------------------------------------------------*
* Events on selection screens
*----------------------------------------------------------------*
AT SELECTION-SCREEN ON p_bukrs.
  macro_atz_single_bukrs p_bukrs c_atz_display.

***added by Rahmadi
AT SELECTION-SCREEN.

***added by Rahmadi
*-Check whether Tax period program is still running
  CLEAR d_tx04_lock_subrc.
  PERFORM f_check_tax_period CHANGING d_tx04_lock_subrc.
  IF d_tx04_lock_subrc <> 0.
    STOP.
  ENDIF.
***end of addition

  PERFORM f_check_branch USING p_bukrs
                               p_brnch.
***end of addition



*Text elements
*-------------
* I002     Period Data



*Selection texts
*---------------
*SD_GJAHR2D       Fiscal year
*SP_BRNCH         Branch
*SP_BUKRS         Company code
*SP_MASATX        Tax Period
*SS_BUDAT         Posting date


*Messages
*-------------
* Message class: ZAB
* 000 & & & &
