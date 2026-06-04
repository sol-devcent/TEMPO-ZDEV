*&----------------------------------------------------------------------
*& D R A G O N   G L O R Y  2  P R O J E C T
*&----------------------------------------------------------------------
*& RICEF ID             : FPP-001
*& Program Name         : ZTSPPP_F001
*& Functional Designer  : MRA
*& ABAP Developer       : Budi P.
*& Creation Date        : 22.03.2018
*& SAP Release          : ECC6.0
*& Description          : Form Reconsiliasi
*&
*&---------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&---------------------------------------------------------------------*
*& Log  TR          FUNCTIONAL  ABAPER    DESCRIPTION
*&---------------------------------------------------------------------*
*& 001  DEVK944591    MRA       Budi      Initial
*&
*&---------------------------------------------------------------------*
REPORT  ztsppp_f001 NO STANDARD PAGE HEADING
                    LINE-SIZE 255.

* Smartforms
SELECTION-SCREEN BEGIN OF SCREEN 101.
PARAMETERS: p_tdform    LIKE ssfscreen-fname MODIF ID gry,
            p_dest      LIKE tsp03-padest DEFAULT 'BM1*',
            p_disp      LIKE ssfctrlop-preview  AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN SKIP.
PARAMETERS: p_phseq     LIKE afvc-phseq MODIF ID phs.
SELECTION-SCREEN END OF SCREEN 101.

INCLUDE zabp_frm.
INCLUDE zabp_smartform.

*------------------common TOP includes for the program----------------*
INCLUDE ztsppp_f001top.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-b01.
PARAMETERS:     p_aufnr LIKE afpo-aufnr MODIF ID pau.
SELECT-OPTIONS: s_werks FOR afpo-dwerk,
                s_matnr FOR afpo-matnr.
SELECTION-SCREEN SKIP.
PARAMETERS:     p_new AS CHECKBOX DEFAULT 'X' MODIF ID new.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
*  p_tdform = 'ZTSPPPSF001'.
  p_tdform = 'ZTSPPPSF001_01'.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_phseq.
  PERFORM f_f4_for_phseq CHANGING p_phseq.

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
  INCLUDE ztsppp_f001f01.
