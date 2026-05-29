*&----------------------------------------------------------------------
*& T I A M   P R O J E C T
*&----------------------------------------------------------------------
*& RICEF ID             : EFI-02
*& Functional Designer  : Sisca
*& ABAP Developer       : Budi P.
*& Creation Date        : 09.08.2023
*& Description          : Upload, Create & Download Master Asset
*&---------------------------------------------------------------------*
REPORT  zdg2fi_e0012 NO STANDARD PAGE HEADING.

* BDC Include
INCLUDE zabp_bdc.

*------------------common TOP includes for the program----------------*
INCLUDE zdg2fi_e0012top.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-005.
PARAMETERS: p_bukrs LIKE anla-bukrs OBLIGATORY DEFAULT '8180',
            p_anlkl LIKE anla-anlkl MODIF ID pan.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) TEXT-011 FOR FIELD so_asse1
                                        MODIF ID sas.
SELECTION-SCREEN POSITION 30.
SELECT-OPTIONS so_asse1   FOR bkpf-xblnr MODIF ID sas
                                         NO INTERVALS.
SELECTION-SCREEN COMMENT 60(5) TEXT-012 MODIF ID sas.
SELECTION-SCREEN POSITION 65.
SELECT-OPTIONS so_asse2   FOR bkpf-xblnr MODIF ID sas
                                         NO INTERVALS.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) TEXT-001 MODIF ID nds.
SELECTION-SCREEN COMMENT 29(5) TEXT-002 FOR FIELD p_rbegin MODIF ID nds.
PARAMETERS p_rbegin TYPE i DEFAULT 2 MODIF ID nds.
SELECTION-SCREEN COMMENT 60(5) TEXT-003 FOR FIELD p_rend MODIF ID nds.
PARAMETERS p_rend TYPE i DEFAULT 60000 MODIF ID nds.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) TEXT-004 MODIF ID nds.
SELECTION-SCREEN COMMENT 29(5) TEXT-002 FOR FIELD p_cbegin MODIF ID nds.
PARAMETERS p_cbegin TYPE i DEFAULT 1 MODIF ID nds.
SELECTION-SCREEN COMMENT 60(5) TEXT-003 FOR FIELD p_cend MODIF ID nds.
PARAMETERS p_cend TYPE i DEFAULT 4 MODIF ID nds.
SELECTION-SCREEN END OF LINE.
PARAMETERS pa_budat    TYPE bkpf-budat MODIF ID pbd
                                       OBLIGATORY
                                       DEFAULT sy-datum.
PARAMETERS pa_bldat    TYPE bkpf-bldat MODIF ID pbl
                                       OBLIGATORY
                                       DEFAULT sy-datum.
PARAMETERS pa_sgtxt    TYPE bseg-sgtxt MODIF ID psg.
SELECTION-SCREEN SKIP.

PARAMETERS p_filenm LIKE rlgrap-filename MODIF ID fln.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS pa_parti AS CHECKBOX USER-COMMAND chk
                                MODIF ID ppa.
SELECTION-SCREEN COMMENT 5(36) TEXT-010 FOR FIELD pa_parti
                                        MODIF ID ppa.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-006.
PARAMETERS: butt1 RADIOBUTTON GROUP rb1 USER-COMMAND uc1 DEFAULT 'X',
            butt2 RADIOBUTTON GROUP rb1.
SELECTION-SCREEN ULINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: butt3 RADIOBUTTON GROUP rb1.
SELECTION-SCREEN COMMENT 5(34) TEXT-007 FOR FIELD butt3.
SELECTION-SCREEN END OF LINE.
PARAMETERS: butt4 RADIOBUTTON GROUP rb1.
SELECTION-SCREEN ULINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: butt5 RADIOBUTTON GROUP rb1.
SELECTION-SCREEN COMMENT 5(44) TEXT-008 FOR FIELD butt5.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS butt6 RADIOBUTTON GROUP rb1.
SELECTION-SCREEN COMMENT 5(31) TEXT-009 FOR FIELD butt6.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block2.

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
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_filenm.
  PERFORM f_get_filename.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_init_data.

  CASE 'X'.
    WHEN butt1 OR butt3 OR butt5.
      PERFORM f_download_template.
    WHEN butt4.
      PERFORM f_create_dyn_int_table.
      PERFORM f_upload_data.
      PERFORM f_get_data.
      PERFORM f_process_data.
      PERFORM f_print_data.
    WHEN butt6.
      PERFORM f_create_dyn_int_table.
      IF pa_parti IS INITIAL.
        PERFORM f_split_asset.
      ELSE.
        PERFORM f_upload_data.
        PERFORM f_get_data.
        PERFORM f_get_asset.
      ENDIF.
      PERFORM f_print_data.
    WHEN OTHERS.
      PERFORM f_create_dyn_int_table.
      PERFORM f_get_data.
      PERFORM f_process_data.
      PERFORM f_print_data.
      PERFORM f_free_memory.
  ENDCASE.

END-OF-SELECTION.

*------------------common Routine includes for the program----------------*

  INCLUDE zdg2fi_e0012m01.

  INCLUDE zdg2fi_e0012f01.
