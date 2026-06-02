*&----------------------------------------------------------------------
*& S F A   P R O J E C T
*&----------------------------------------------------------------------
*& RICEF ID             : EFI001
*& Program Name         : ZSFAFI_E001
*& Functional Designer  : SJT
*& ABAP Developer       : Budi P.
*& Creation Date        : 04.05.2018
*& SAP Release          : ECC6.0
*& Description          : BI for SFA
*&
*&---------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&---------------------------------------------------------------------*
*& Log  TR          FUNCTIONAL  ABAPER    DESCRIPTION
*&---------------------------------------------------------------------*
*& 001  DEVK943483  XXXXXXXXXX  XXXXXXXXXX Initial
*&
*&---------------------------------------------------------------------*
REPORT  zsfafi_e001 NO STANDARD PAGE HEADING
                    LINE-SIZE 255.

*------------------common TOP includes for the program----------------*
INCLUDE zsfafi_e001top.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-b01.
PARAMETERS: p_vkorg LIKE zssutdt025-vkorg MODIF ID pvo,
            p_vkbur LIKE zssutdt025-vkbur MODIF ID pvb.
SELECT-OPTIONS: s_pernr1 FOR zssutdt025-pernr MODIF ID pe1 NO INTERVALS NO-EXTENSION,
                s_sdate1 FOR zssutdt025-sdate MODIF ID sd1 NO INTERVALS NO-EXTENSION,
                s_daily1 FOR zssutdt025-daily_call_num MODIF ID da1 NO INTERVALS NO-EXTENSION.

SELECT-OPTIONS  s_kunnr  FOR zssutdt026-kunnr MODIF ID sku.
SELECT-OPTIONS  s_zuonr  FOR bsid-zuonr MODIF ID szu.

SELECT-OPTIONS: s_bbeln1 FOR zfbih_sfa-bbeln MODIF ID bb1 NO INTERVALS NO-EXTENSION,
                s_pernr2 FOR zssutdt025-pernr MODIF ID pe2,
                s_sdate2 FOR zssutdt025-sdate MODIF ID sd2,
                s_daily2 FOR zssutdt025-daily_call_num MODIF ID da2,
                s_bbeln2 FOR zfbih_sfa-bbeln MODIF ID bb2.

PARAMETERS: p_path TYPE char128 OBLIGATORY LOWER CASE DEFAULT '/outbound/sfa/bi_new/' MODIF ID pat.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-b02.
PARAMETERS: p_rad1 RADIOBUTTON GROUP grp1 DEFAULT 'X' USER-COMMAND usr1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETERS : p_inkas1 AS CHECKBOX USER-COMMAND ink1 MODIF ID pi1.
SELECTION-SCREEN : COMMENT 45(20) text-003 FOR FIELD p_inkas1 MODIF ID pi1.
SELECTION-SCREEN END OF LINE.
PARAMETERS: p_rad2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETERS : p_inkas2 AS CHECKBOX USER-COMMAND ink2 MODIF ID pi2.
SELECTION-SCREEN : COMMENT 45(20) text-003 FOR FIELD p_inkas2 MODIF ID pi2.
SELECTION-SCREEN END OF LINE.
PARAMETERS: p_rad3 RADIOBUTTON GROUP grp1,
            p_rad5 RADIOBUTTON GROUP grp1,
            p_rad4 RADIOBUTTON GROUP grp1,
            p_rad6 RADIOBUTTON GROUP grp1,
            p_rad7 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN END OF BLOCK b1.

*SELECTION-SCREEN BEGIN OF BLOCK variant WITH FRAME TITLE text-002.
*PARAMETERS: pa_vari  LIKE disvariant-variant.
*SELECTION-SCREEN END OF BLOCK variant.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*&---------------------------------------------------------------------*
*& selection-screen output
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
* AT SELECTION-SCREEN ON
*------------------------------------------------------
AT SELECTION-SCREEN ON p_vkbur.
  AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
          ID 'GSBER' FIELD p_vkbur
          ID 'ACTVT' FIELD '01'.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH
    'You have no authorization for Sales Office' p_vkbur.
  ENDIF.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_vari.
*  PERFORM f_f4_for_variant_alv CHANGING pa_vari.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  CASE 'X'.
    WHEN p_rad1 OR p_rad2.
      PERFORM f_lock_table_check USING 'E'.
    WHEN OTHERS.
  ENDCASE.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.

  CASE 'X'.
    WHEN p_rad1 OR p_rad2.
      PERFORM f_lock_table_check USING 'D'.
    WHEN OTHERS.
  ENDCASE.

END-OF-SELECTION.

*------------------common Routine includes for the program----------------*
  INCLUDE zsfafi_e001f01.
