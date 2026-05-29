*&----------------------------------------------------------------------
*& D R A G O N   G L O R Y  2  P R O J E C T
*&----------------------------------------------------------------------
*& RICEF ID             : XXXXXXXXXX
*& Program Name         : ZS_SHIPMENT_REPORT
*& Functional Designer  : Dicky
*& ABAP Developer       : Budi
*& Creation Date        : 26.08.2019
*& SAP Release          : ECC6.0
*& Description          : Shipment Report
*&
*&---------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&---------------------------------------------------------------------*
*& Log  TR          FUNCTIONAL  ABAPER    DESCRIPTION
*&---------------------------------------------------------------------*
*& 001  DEVK963107  XXXXXXXXXX  XXXXXXXXXX Initial
*&
*&---------------------------------------------------------------------*
REPORT zs_shipment_report NO STANDARD PAGE HEADING
                          LINE-SIZE 255.

*------------------common TOP includes for the program----------------*
INCLUDE zs_shipment_reporttop.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-b01.
PARAMETERS    : p_tplst LIKE vttk-tplst OBLIGATORY.
SELECT-OPTIONS: s_shtyp FOR vttk-shtyp OBLIGATORY,
                s_erdat FOR vttk-erdat OBLIGATORY DEFAULT sy-datum,
                s_erzet FOR vttk-erzet,
                s_sttrg FOR vttk-sttrg OBLIGATORY,
                s_tdlnr FOR vttk-tdlnr,
                s_tknum FOR vttk-tknum,
                s_exti2 FOR vttk-exti2,
                s_route FOR vttk-route.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK variant WITH FRAME TITLE text-002.
PARAMETERS: pa_vari  LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK variant.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM f_init_erzet.

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
  INCLUDE zs_shipment_reportf01.
