*&----------------------------------------------------------------------
*&
*&----------------------------------------------------------------------
*& RICEF ID             : EACC-05
*& Program Name         : ZACCMM_E005
*& Functional Designer  : Guritno
*& ABAP Developer       : Budi P.
*& Creation Date        : 06.01.2021
*& SAP Release          : ECC6.0
*& Description          : Proses SN
*&
*&---------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&---------------------------------------------------------------------*
*& Log  TR          FUNCTIONAL  ABAPER    DESCRIPTION
*&---------------------------------------------------------------------*
*& 001
*&
*&---------------------------------------------------------------------*
REPORT zaccmm_e005 NO STANDARD PAGE HEADING
                   LINE-SIZE 255.

*------------------common TOP includes for the program----------------*
INCLUDE zaccmm_e005top.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
*PARAMETER:      p_brcod  LIKE zaccmmdt001-brcod OBLIGATORY.
SELECT-OPTIONS: s_ivnr   FOR zaccmmdt001-ivnr,
                s_upldat FOR zaccmmdt001-upldat,
                s_werks  FOR zplbc-werks.

SELECTION-SCREEN SKIP.
PARAMETER: p_butt1 RADIOBUTTON GROUP but1 USER-COMMAND usr1,
           p_butt2 RADIOBUTTON GROUP but1,
           p_butt3 RADIOBUTTON GROUP but1.
SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

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

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zaccmm_e005f01.

*------------------common includes for the program---------------------*
