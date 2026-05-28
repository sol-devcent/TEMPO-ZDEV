*&----------------------------------------------------------------------
*& D R A G O N   G L O R Y  2  P R O J E C T
*&----------------------------------------------------------------------
*& RICEF ID             : XXXXXXXXXX
*& Program Name         : ZSFAFI_R001
*& Functional Designer  : Sisca
*& ABAP Developer       : Budi P.
*& Creation Date        : 20.09.2018
*& SAP Release          : ECC6.0
*& Description          : BI Report
*&
*&---------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&---------------------------------------------------------------------*
*& Log  TR          FUNCTIONAL  ABAPER    DESCRIPTION
*&---------------------------------------------------------------------*
*& 001  XXXXXXXXXX  XXXXXXXXXX  XXXXXXXXXX Initial
*&
*&---------------------------------------------------------------------*
REPORT  zsfafi_r001 NO STANDARD PAGE HEADING
                    LINE-SIZE 255.

*------------------common TOP includes for the program----------------*
INCLUDE zsfafi_r001top.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: p_bukrs LIKE zfbid_sfa-bukrs DEFAULT '8020',
            p_vkbur LIKE zfbid_sfa-vkbur.

SELECT-OPTIONS: s_gjahr FOR zfbid_sfa-gjahr MODIF ID cek NO INTERVALS,
                s_zfbdt FOR zfbid_sfa-zfbdt MODIF ID cek.

SELECT-OPTIONS: s_bidat FOR zfbih_sfa-bidat,
                s_bbeln FOR zfbih_sfa-bbeln,
                s_zuonr FOR zfbid_sfa-zuonr,
                s_kunnr FOR zfbid_sfa-kunnr.

SELECT-OPTIONS: s_bname FOR zfbic_sfa-bank_name MODIF ID cek,
                s_cekno FOR zfbic_sfa-bank_check MODIF ID cek,
                s_duedt FOR zfbic_sfa-bank_dudat MODIF ID cek,
                s_pcair FOR zfbic_sfa-pcair MODIF ID cek NO INTERVALS.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS: p_rad1 RADIOBUTTON GROUP grp1 DEFAULT 'X' USER-COMMAND usr,
            p_rad2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK variant WITH FRAME TITLE text-003.
PARAMETERS: pa_vari  LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK variant.

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
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_vari.
  PERFORM f_f4_for_variant_alv CHANGING pa_vari.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.

END-OF-SELECTION.

*------------------common Routine includes for the program----------------*
  INCLUDE zsfafi_r001f01.
