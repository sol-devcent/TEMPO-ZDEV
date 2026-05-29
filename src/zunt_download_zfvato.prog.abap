*&----------------------------------------------------------------------
*& D R A G O N   G L O R Y  2  P R O J E C T
*&----------------------------------------------------------------------
*& RICEF ID             : XXXXXXXXXX
*& Program Name         : ZUNT_DOWNLOAD_ZFVATO
*& Functional Designer  : ETP
*& ABAP Developer       : Budi
*& Creation Date        : 11.09.2015
*& SAP Release          : ECC6.0
*& Description          : Download data faktur
*&
*&---------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&---------------------------------------------------------------------*
*& Log  TR          FUNCTIONAL  ABAPER    DESCRIPTION
*&---------------------------------------------------------------------*
*& 001  EVK946541   ETP         Budi      Initial
*&
*&---------------------------------------------------------------------*
REPORT zunt_download_zfvato NO STANDARD PAGE HEADING
                         LINE-SIZE 255.

*------------------common TOP includes for the program----------------*
INCLUDE zunt_download_zfvatotop.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-b01.
PARAMETERS: p_vkorg LIKE zfvato-vkorg DEFAULT '8020' OBLIGATORY.
SELECT-OPTIONS: s_vkbur FOR zfvato-vkbur,
                s_kunrg FOR kna1-kunnr,
                s_vatno FOR zfvato-vatno,
                s_vbeln FOR zfvato-vbeln,
                s_zuonr FOR zfvato-zuonr,
                s_dueyr FOR zfvato-dueyr DEFAULT sy-datum(4),
                s_fkdat FOR zfvato-fkdat DEFAULT sy-datum.
SELECTION-SCREEN SKIP 1.
PARAMETERS folder   LIKE rlgrap-filename OBLIGATORY.
PARAMETERS filename LIKE rlgrap-filename OBLIGATORY.
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

AT SELECTION-SCREEN ON VALUE-REQUEST FOR folder.
  PERFORM f_folder_f4 CHANGING folder.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_crt_dwnfield.
  PERFORM f_print_data.
  PERFORM f_free_memory.

END-OF-SELECTION.

*------------------common Routine includes for the program----------------*
  INCLUDE zunt_download_zfvatof01.
