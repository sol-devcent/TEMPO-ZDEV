*&----------------------------------------------------------------------
*& D R A G O N   G L O R Y  2  P R O J E C T
*&----------------------------------------------------------------------
*& RICEF ID             : XXXXXXXXXX
*& Program Name         : ZCO_PRODUCTION_RESOURCE
*& Functional Designer  : FAM
*& ABAP Developer       : Budi
*& Creation Date        : 13.01.2019
*& SAP Release          : ECC6.0
*& Description          : Menampilkan detail Production Resource
*&
*&---------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&---------------------------------------------------------------------*
*& Log  TR          FUNCTIONAL  ABAPER    DESCRIPTION
*&---------------------------------------------------------------------*
*& 001  DEVK965067  XXXXXXXXXX  XXXXXXXXXX Initial
*&
*&---------------------------------------------------------------------*
REPORT  zco_production_resource NO STANDARD PAGE HEADING
                                LINE-SIZE 255.

*------------------common TOP includes for the program----------------*
INCLUDE zco_production_resourcetop.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_werks FOR mkal-werks OBLIGATORY,
                s_matnr FOR mkal-matnr OBLIGATORY,
                s_mtart FOR mara-mtart,
                s_mksp  FOR mkal-mksp,
                s_plnnr FOR mkal-plnnr,
                s_arbpl FOR crhd-arbpl.
SELECTION-SCREEN SKIP.
PARAMETERS: butt1 RADIOBUTTON GROUP grp1 DEFAULT 'X',
            butt2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK b1.

*SELECTION-SCREEN BEGIN OF BLOCK variant WITH FRAME TITLE text-002.
SELECTION-SCREEN SKIP.
PARAMETERS: pa_vari  LIKE disvariant-variant.
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
  INCLUDE zco_production_resourcef01.
