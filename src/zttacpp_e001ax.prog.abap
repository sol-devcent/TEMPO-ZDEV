*&---------------------------------------------------------------------*
*& Report  ZTTACPP_E001A
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zttacpp_e001a NO STANDARD PAGE HEADING
                      LINE-SIZE 255.

INCLUDE zttacpp_e001axtop.

PARAMETERS pa_werks   TYPE t001w-werks.
PARAMETERS pa_split   TYPE i OBLIGATORY.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_1lvl    AS CHECKBOX DEFAULT 'X' MODIF ID hid.
PARAMETERS pa_2lvl    AS CHECKBOX MODIF ID hid.
PARAMETERS pa_fr      TYPE i MODIF ID hid.
PARAMETERS pa_to      TYPE i MODIF ID hid.
PARAMETERS pa_docat   TYPE s501-docat MODIF ID hid.
SELECT-OPTIONS so_docno  FOR s501-docno MODIF ID hid.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'HID'.
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

START-OF-SELECTION.
  PERFORM f_init_data.
  IF gv_subrc = 0.
    PERFORM f_get_data USING 'PRO' '1'.
    IF gv_subrc = 0.
      PERFORM f_ttac_login.
      PERFORM f_registerparent_process.
    ENDIF.
  ENDIF.

  CASE gv_subrc.
    WHEN 1.
      WRITE : / 'User & Email not yet maintain'.
    WHEN 2.
      WRITE : / 'No Data processed'.
    WHEN 3.
      WRITE : / 'Token not found'.
    WHEN OTHERS.
      PERFORM f_write_report.
  ENDCASE.

  INCLUDE zttacpp_e001axf01.
