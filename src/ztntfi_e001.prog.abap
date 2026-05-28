*&---------------------------------------------------------------------*
*& Report  ZTNTFI_E001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztntfi_e001 NO STANDARD PAGE HEADING.

INCLUDE zabp_bdc.

INCLUDE ztntfi_e001top.

SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_vkorg   TYPE vbrk-vkorg MODIF ID pbu DEFAULT '8160'.
SELECT-OPTIONS so_fkdat   FOR vbrk-fkdat MODIF ID sbu DEFAULT sy-datum.
SELECT-OPTIONS so_vbeln   FOR vbrk-vbeln MODIF ID sbe.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio5 RADIOBUTTON GROUP grp1 MODIF ID ra5.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
PARAMETERS radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_selection-screen_output.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_selection-screen.
    WHEN space.
      PERFORM f_selection-screen.
  ENDCASE.

START-OF-SELECTION.

  PERFORM f_process_data.

  INCLUDE ztntfi_e001f01.
