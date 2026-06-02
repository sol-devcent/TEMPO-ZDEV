*$*$--------------------------------------------------------------------
*$*$ @description
*$*$ Cetak Nota Retur PPN from Table Tax 02 dan 03
*$*$ @Businnes Requirement
*$*$
*$*$--------------------------------------------------------------------
REPORT zgdtx_e0010 NO STANDARD PAGE HEADING.
*&---------------------------------------------------------------------*
*& Common Include section
*&---------------------------------------------------------------------*
* include seperti di standard sap order print sap script
INCLUDE rvdirekt.
INCLUDE vedadata.
* data for access to central address maintenance
INCLUDE sdzavdat.

*include zabpxin_var.
INCLUDE zabpxin_script."zstdxin_lyt.

INCLUDE zgdtxne0010top.
***Standard include -------------
INCLUDE zabpxin_udf.
INCLUDE zabpxin_hdr.
INCLUDE zabp_bdc. "zabpxin_bdc.

***Standard include For Production--------
INCLUDE zstdxin_atz.

*&---------------------------------------------------------------------*
*& SELECT-OPTIONS / PARAMTERS / CheckBox ..etc....
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-da1.
* Start of change by sutoyo
*PARAMETERS: p_vkorg  LIKE ZGDTXdt0002-vkorg  OBLIGATORY,
*            p_gsber  LIKE ZGDTXdt0002-gsber  OBLIGATORY,
*            p_spart  LIKE ZGDTXdt0002-spart  OBLIGATORY,
PARAMETERS: p_bukrs  LIKE zgdtxdt0012-bukrs  OBLIGATORY,
            p_brnch  LIKE zgdtxdt0012-brnch  OBLIGATORY,
*            p_busln  LIKE zgdtxdt0002-busln  OBLIGATORY,
* End of change
            p_masatx LIKE zgdtxdt0012-masatx OBLIGATORY.
SELECT-OPTIONS: s_belnr FOR zgdtxdt0012-belnr NO INTERVALS.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK print WITH FRAME TITLE text-pr1.
PARAMETERS: p_sign(40) OBLIGATORY,
            p_dest LIKE tsp03-padest OBLIGATORY.
SELECTION-SCREEN END OF BLOCK print.

*$*$-using SAPDev standard include--------------------------------------
*INCLUDE zabpxin_pr2.
*$*$- DO NOT CHANGE THE SAPDEV STANDARD INCLUDE !
INCLUDE zabp_frm. "zabpxin_frm.
*INCLUDE zabpxin_rpt.
*INCLUDE zabpxin_lay.


INCLUDE zgdtxne0010f01.
*INCLUDE zgdtxne0009f01.

INITIALIZATION.
  PERFORM f_initialization.
*$*$ change below name program !!!
*  PERFORM f_rpt_init_program_name USING 'ZGDTX_E00009'.
*$*$


*&---------------------------------------------------------------------*
*& START-OF-SELECTION.
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  xscreen = p_disp.
* set layout form to ZGDTXF0004
  if p_bukrs eq '8030'.
    p_tdform = 'ZGDTXF0004_01RFX'.
  elseif p_bukrs eq '8050'.
    p_tdform = 'ZDGTXF0004_01BKP'.
  elseif p_bukrs eq '8800'.
    p_tdform = 'ZDGTXF0004_01BKP'.
  elseif  p_bukrs eq '8230'.
    p_tdform = 'ZDGTXF0004_01BKP'.
* DG2
  elseif  p_bukrs eq '8180'.
    p_tdform = 'ZDGTXF0004_01BKP'.
  elseif  p_bukrs eq '8220' or
    p_bukrs eq '8210' or
    p_bukrs eq '8040'.
    p_tdform = 'ZDGTXF0004_01BKP'.
* DG2
  else.
    p_tdform = 'ZGDTXF0004_01'.
  endif.
  PERFORM f_process_report.

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_REPORT
*&---------------------------------------------------------------------*
FORM f_process_report.

***added by Rahmadi
*-Get Organization structure config
  CALL FUNCTION 'Z_GDTXFC_TAX_CFG_ORG_DETMN'
       EXPORTING
            fi_brnch                      = p_brnch
*            fi_busln                      = p_busln
       IMPORTING
            fe_bukrs                      = p_bukrs
*            fe_busds                      = d_busds
*            fe_bdesc                      = d_bdesc
*            fe_ho_ind                     = d_hoind
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
* end of addition.

***Check NR printing status - continue only if PRTNRVI is checked
  READ TABLE t_tx00101 WITH KEY brnch = p_brnch.
  IF t_tx00101-prtnrvi IS INITIAL.
    MESSAGE i000(zab) WITH 'You cannot print NR for VAT-in'.
    STOP.
  ENDIF.

  PERFORM f_init_data.
  PERFORM f_get_data.
  CASE d_frm_subrc.
    WHEN 0.
      PERFORM f_write_data.
    WHEN 1.
      MESSAGE ID 'AQ' TYPE 'I' NUMBER '260'.
  ENDCASE.
ENDFORM.                    " F_PROCESS_REPORT


*&---------------------------------------------------------------------*
*& TOP-OF-PAGE
*&---------------------------------------------------------------------*
*TOP-OF-PAGE.
*  PERFORM f_top_of_page.

*----------------------------------------------------------------*
* Events on selection screens
*----------------------------------------------------------------*
*$*$- Cek for Production Mechine
* Commented by sutoyo
*AT SELECTION-SCREEN ON p_vkorg.
*  macro_atz_single_vkorg p_vkorg c_atz_display.
*
*AT SELECTION-SCREEN ON p_gsber.
*  macro_atz_single_gsber p_gsber c_atz_display.
* End of comment

AT SELECTION-SCREEN OUTPUT.
*  PERFORM f_rpt_init_block.

AT SELECTION-SCREEN ON p_bukrs.
  macro_atz_single_bukrs p_bukrs c_atz_display.


*Text elements
*-------------
* IPR1     Printing Selection



*Selection texts
*---------------
*SP_BRNCH         Branch
*SP_BUKRS         Company Code
*SP_BUSLN         Business Line
*SP_DEST          Printer name
*SP_GSBER         Branch
*SP_SPART         Business line
*SS_NORET         No. Retur


*Messages
*-------------
* Message class: ZAB
* 000 & & & &
