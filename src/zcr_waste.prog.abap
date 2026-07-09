*&----------------------------------------------------------------------
*& D R A G O N   G L O R Y  2  P R O J E C T
*&----------------------------------------------------------------------
*& RICEF ID             : XXXXXXXXXX
*& Program Name         : ZCR_WASTE
*& Functional Designer  : XXXXXXXXXX
*& ABAP Developer       : XXXXXXXXXX
*& Creation Date        : 09.06.2015
*& SAP Release          : ECC6.0
*& Description          : XXXXXXXXXX
*&
*&---------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&---------------------------------------------------------------------*
*& Log  TR          FUNCTIONAL  ABAPER    DESCRIPTION
*&---------------------------------------------------------------------*
*& 001  DEVK943483  XXXXXXXXXX  XXXXXXXXXX Initial
*&
*&---------------------------------------------------------------------*
REPORT  zcr_waste NO STANDARD PAGE HEADING
                  LINE-SIZE 255.

*------------------common TOP includes for the program----------------*
INCLUDE zcr_wastetop.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
s_werks FOR caufv-werks  MODIF ID wer,
s_matnr FOR caufv-plnbez MODIF ID mat,
s_aufnr FOR caufv-aufnr  MODIF ID auf,
s_gstri FOR caufv-gstri  MODIF ID gst,
s_gltri FOR caufv-gltri  MODIF ID glt.
SELECTION-SCREEN END OF BLOCK b1.

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
  INCLUDE zcr_wastef01.
