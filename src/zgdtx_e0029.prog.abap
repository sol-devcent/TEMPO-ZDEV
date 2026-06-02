REPORT zgdtx_e0029 .

INCLUDE zabpxin_macro_sel_scr.
*INCLUDE : zGDTX_alv_common.
INCLUDE zabpxin_hdr.
INCLUDE zgdtxformsf01.

INCLUDE <icon>.
INCLUDE <symbol>.

INCLUDE zgdtxne0029top.
INCLUDE zgdtx_alv_common.
INCLUDE zgdtxne0029f01.

INITIALIZATION.
  PERFORM f_initialization.

AT SELECTION-SCREEN.
***added by Rahmadi
*-Check whether Tax period program is still running
  CLEAR d_tx04_lock_subrc.
  PERFORM f_check_tax_period CHANGING d_tx04_lock_subrc.
  IF d_tx04_lock_subrc <> 0.
    STOP.
  ENDIF.
***end of addition

***removed for Tempo
*  PERFORM f_select_period.
***end of Tempo removal

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_select_output.

AT SELECTION-SCREEN ON p_gjahr.
  PERFORM f_check_gjahr.

AT SELECTION-SCREEN ON p_monat.
  PERFORM f_check_monat.

*AT SELECTION-SCREEN ON p_blart.
*  PERFORM f_check_blart.

* Added by pendi on 9/6/2003
AT SELECTION-SCREEN ON p_bukrs.
  macro_atz_single_bukrs p_bukrs c_atz_display.
  PERFORM f_check_bukrs.

AT SELECTION-SCREEN ON p_brnch.
  PERFORM f_check_brnch.

START-OF-SELECTION.
  PERFORM f_init_data.

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

**Get Consolidation option
  SORT t_tx00103 BY brnch busln.
  CLEAR d_fakgr.
  READ TABLE t_tx00103 WITH KEY brnch = p_brnch
                                busln = p_busln
                                BINARY SEARCH.
  IF sy-subrc <> 0.
    MESSAGE e000(zab) WITH 'Consolidation option is not maintained'.
  ENDIF.
  d_fakgr = t_tx00103-satgr.
* end of addition.

* will be activate again when the lock object is created
* PERFORM f_check_program_lock USING d_lock.

*--added by pendi on 11/6/2003
**modified by Rahmadi
*  check not t_zGDTXdt0104[] is initial.
  CHECK NOT r_hkont[] IS INITIAL AND
        NOT r_blart[] IS INITIAL.
**end of modification
*--end
  PERFORM f_get_custom_data.
  PERFORM f_get_sap_data.
  PERFORM f_check_data.
  PERFORM f_write_data.
*--added by Pendi on 11/6/2003
  PERFORM f_free_memory.
*--end
END-OF-SELECTION.

AT USER-COMMAND.
* perform f_tambah.
* perform f_save.
* perform f_hapus.



*Text elements
*-------------
* I005     Faktur No.
* I009     Exclude Tax



*Selection texts
*---------------
*SP_BRNCH D       Branch
*SP_BUKRS D       Company code
*SP_EXCLD
*SP_GJAHR D       Fiscal year
*SP_MASATXD       Settlmnt period
*SP_MONAT D       Posting period
*SS_BELNR D       Document number


*Messages
*-------------
* Message class: ZAB
* 000 & & & &
