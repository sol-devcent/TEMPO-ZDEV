*&----------------------------------------------------------------------
*& D R A G O N   G L O R Y  2  P R O J E C T
*&----------------------------------------------------------------------
*& RICEF ID             : XXXXXXXXXX
*& Program Name         : ZDGCO_R006
*& Functional Designer  : Fahmi
*& ABAP Developer       : Sukardi
*& Creation Date        : 11.10.2018
*& SAP Release          : ECC6.0
*& Description          : Report MASTER RECIPE LISTING
*&
*&---------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&---------------------------------------------------------------------*
*& Log  TR          FUNCTIONAL  ABAPER    DESCRIPTION
*&---------------------------------------------------------------------*
*& 001  DEVK947396  Popo        Budi      Initial
*&
*&---------------------------------------------------------------------*
REPORT  zdgco_r006 NO STANDARD PAGE HEADING
                     LINE-SIZE 255.

*------------------common TOP includes for the program----------------*
INCLUDE zdgco_r006top.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS:     p_werks LIKE mkal-werks OBLIGATORY.
SELECT-OPTIONS: s_matnr for mkal-matnr,
                s_mtart FOR mara-mtart,
                s_plnnr FOR mkal-plnnr,
                s_mksp  FOR mkal-mksp NO INTERVALS.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*  LOOP AT SCREEN.
*    IF screen-name = 'P_VKORG'.
*      screen-input = '0'.
*    ENDIF.
*    MODIFY SCREEN.
*  ENDLOOP.

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
  INCLUDE zdgco_r006f01.
