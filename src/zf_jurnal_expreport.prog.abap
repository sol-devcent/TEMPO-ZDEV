*&---------------------------------------------------------------------*
*& Report  ZF_JURNAL_EXPREPORT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  zf_jurnal_expreport NO STANDARD PAGE HEADING
                            LINE-SIZE 1023.

INCLUDE zf_jurnal_expreporttop.

INCLUDE zf_jurnal_expreportcl1.

SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_bukrs   LIKE zf63typeexp-bukrs MODIF ID pbu.
SELECT-OPTIONS so_vkbur   FOR tvbur-vkbur MODIF ID svk.
SELECT-OPTIONS so_gtype   FOR zf63gtype-gtype MODIF ID sgt.
SELECT-OPTIONS so_name1   FOR zf63masterperson-name1 MODIF ID sna.
SELECT-OPTIONS so_nopol   FOR zf63masterkend-znopol MODIF ID sno.
SELECT-OPTIONS so_lifnr   FOR zf63masterperson-lifnr MODIF ID sli.
SELECT-OPTIONS so_budat   FOR zf63trnvch-budat MODIF ID sbd NO-EXTENSION.
SELECT-OPTIONS so_erdat   FOR zf63trnhdr2-erdat MODIF ID ser NO-EXTENSION.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS radio4 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio1 RADIOBUTTON GROUP grp1.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
PARAMETERS radio5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  gv_repid    = sy-repid.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON ( PARAMETERS )
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
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
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_gtype-low.
  PERFORM f_value_gtype USING 'SO_GTYPE-LOW' 'GTYPE'
                        CHANGING so_gtype-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_gtype-high.
  PERFORM f_value_gtype USING 'SO_GTYPE-HIGH' 'GTYPE'
                        CHANGING so_gtype-high.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_name1-low.
  PERFORM f_value_name1 USING 'SO_NAME1-LOW' 'NAME1'
                        CHANGING so_name1-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_name1-high.
  PERFORM f_value_name1 USING 'SO_NAME1-HIGH' 'NAME1'
                        CHANGING so_name1-high.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_nopol-low.
  PERFORM f_value_nopol USING 'SO_NOPOL-LOW' 'ZNOPOL'
                        CHANGING so_nopol-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_nopol-high.
  PERFORM f_value_nopol USING 'SO_NOPOL-HIGH' 'ZNOPOL'
                        CHANGING so_nopol-high.

START-OF-SELECTION.
  CASE 'X'.
    WHEN radio1 OR radio2.
      PERFORM f_init_data.
      PERFORM f_get_data.
      PERFORM f_process_data.
      PERFORM f_print_data.
    WHEN radio4.
      PERFORM f_init_data.
      PERFORM f_get_data_r4.
      PERFORM f_process_data_r4.
      IF gt_head[] IS NOT INITIAL.
        PERFORM f_print_alv_hierarchy.
      ENDIF.
    WHEN OTHERS.
      PERFORM f_init_data.
      PERFORM f_crt_dyn_int_table.
      PERFORM f_get_data_alv.
      PERFORM f_process_data_alv.
      PERFORM f_print_data_alv.
  ENDCASE.

  INCLUDE zf_jurnal_expreportf01.
