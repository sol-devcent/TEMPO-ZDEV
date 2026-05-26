*&---------------------------------------------------------------------*
*& Report  ZWM_F001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zwm_f001 NO STANDARD PAGE HEADING.

INCLUDE zwm_f001top.

SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_werks   TYPE t001w-werks MODIF ID pwe.
PARAMETERS pa_lgnum   TYPE zwmdt007-lgnum MODIF ID plg.
SELECT-OPTIONS so_tknum   FOR zwmdt004-tknum MODIF ID stk.
SELECT-OPTIONS so_ebel1   FOR zwmdt006-ebeln MODIF ID se1.
SELECT-OPTIONS so_ebel2   FOR gv_vbeln MODIF ID se2.
SELECT-OPTIONS so_vbeln   FOR gv_vbeln MODIF ID svn.
SELECT-OPTIONS so_inbdn   FOR gv_vbeln MODIF ID sin.
SELECT-OPTIONS so_mblnr   FOR gv_vbeln MODIF ID smn.
PARAMETERS pa_mjahr   TYPE mkpf-mjahr MODIF ID pmj.
SELECT-OPTIONS so_bastn   FOR zwmdt007-bastno MODIF ID sba.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_lfsnr   TYPE mkpf-xblnr MODIF ID plf.
PARAMETERS pa_proc(50) NO-DISPLAY.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_prev AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1
                  USER-COMMAND rad DEFAULT 'X'
                  MODIF ID ptt.
PARAMETERS radio2 RADIOBUTTON GROUP grp1
                  MODIF ID ptt.
PARAMETERS radio3 RADIOBUTTON GROUP grp1
                  MODIF ID tl.
PARAMETERS radio4 RADIOBUTTON GROUP grp1
                  MODIF ID tl.
PARAMETERS radio5 RADIOBUTTON GROUP grp1
                  MODIF ID tl.
PARAMETERS radio6 RADIOBUTTON GROUP grp1
                  MODIF ID tl.
PARAMETERS radio7 RADIOBUTTON GROUP grp1
                  MODIF ID tl.
SELECTION-SCREEN END OF BLOCK option.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  IF sy-uname(3) = 'PTT'.
    radio1 = 'X'.
    radio3 = space.
  ELSEIF sy-uname(3) = 'BKS'.
    radio3 = 'X'.
    radio1 = space.
  ENDIF.

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
      PERFORM f_selection_screen.
    WHEN space.
      PERFORM f_selection_screen.
  ENDCASE.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN ON
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_ebel2-low.
  PERFORM f_validate_screen USING 'NUMBER' 'SO_EBEL2-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_ebel2-high.
  PERFORM f_validate_screen USING 'NUMBER' 'SO_EBEL2-HIGH'.

START-OF-SELECTION.
  PERFORM f_init_data.

  CASE 'X'.
    WHEN radio1 OR radio2.
      PERFORM f_get_data.
      PERFORM f_process_data.
      PERFORM f_print_form.
    WHEN OTHERS.
      PERFORM f_get_data_tl.
      PERFORM f_process_data_tl.
*      PERFORM f_process_data_tlx.
      PERFORM f_print_form_tl.
  ENDCASE.

  INCLUDE zwm_f001f01.
