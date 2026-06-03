*&---------------------------------------------------------------------*
*& Report  ZACCPP_E003
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zaccpp_e003 NO STANDARD PAGE HEADING.

INCLUDE zaccpp_e003top.

INCLUDE zaccpp_e003cl1.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE TEXT-001.
PARAMETERS filenm  LIKE rlgrap-filename MODIF ID pfl.
SELECTION-SCREEN END OF BLOCK general.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(43) TEXT-003 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio2 RADIOBUTTON GROUP grp1 MODIF ID gry.
SELECTION-SCREEN COMMENT 5(33) TEXT-004 FOR FIELD radio2 MODIF ID gry.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN SKIP.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.

INITIALIZATION.
  gv_repid  = sy-repid.

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen_1000.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen_1000.
    WHEN space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR filenm.
  PERFORM f_filename_f4 CHANGING filenm.

START-OF-SELECTION.
  CASE 'X'.
    WHEN radio3.
      PERFORM f_download_template_1.
    WHEN OTHERS.
      PERFORM f_init_data.
      PERFORM f_upload_fr_excel.
      PERFORM f_crt_dyn_int_table USING 'T'.

      PERFORM f_get_data.
      PERFORM f_process_data.
      PERFORM f_print_data.
  ENDCASE.

  INCLUDE zaccpp_e003f01.
