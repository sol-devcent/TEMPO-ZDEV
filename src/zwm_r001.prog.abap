*&---------------------------------------------------------------------*
*& Report  ZWM_R001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zwm_r001 NO STANDARD PAGE HEADING.

INCLUDE zwm_r001top.

INCLUDE zwm_r001cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_lgnum   TYPE ltak-lgnum MODIF ID plg.
PARAMETERS pa_vstel   TYPE likp-vstel MODIF ID pvs.
SELECT-OPTIONS so_tanum   FOR ltap-tanum MODIF ID sta.
SELECT-OPTIONS so_tknum   FOR vttk-tknum MODIF ID stk.
SELECT-OPTIONS so_vbeln  FOR likp-vbeln MODIF ID svb.
SELECT-OPTIONS so_datum   FOR sy-datum DEFAULT sy-datum
                          NO-EXTENSION
                          MODIF ID sda.
SELECT-OPTIONS so_uname   FOR sy-uname
                          MODIF ID sun.


SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad
                                         DEFAULT 'X'
                                         MODIF ID r01.
PARAMETERS radio2 RADIOBUTTON GROUP grp1 MODIF ID r02.
PARAMETERS radio3 RADIOBUTTON GROUP grp1 MODIF ID r03.
PARAMETERS radio4 RADIOBUTTON GROUP grp1 MODIF ID r04.
PARAMETERS radio5 RADIOBUTTON GROUP grp1 MODIF ID r05.
PARAMETERS radio6 RADIOBUTTON GROUP grp1 MODIF ID r06.
PARAMETERS radio7 RADIOBUTTON GROUP grp1 MODIF ID r07.
SELECTION-SCREEN END OF BLOCK option.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  gv_repid    = sy-repid.

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

  PERFORM f_init_data.
  PERFORM f_create_fieldcat USING : 'TREE',
                                    'UNAME',
                                    'KTEXT',
                                    'TIME',
                                    'TO',
                                    'DN',
                                    'SHIPMENT',
                                    'STATUS_DO',
                                    'MONITOR_PICKING',
                                    'DETL'.

  PERFORM f_create_dyn_int_table TABLES gt_tree_fieldcat
                                 USING 'TREE' ''.

  PERFORM f_create_dyn_int_table TABLES gt_usfcat
                                 USING 'UNAME' ''.
  PERFORM f_create_dyn_int_table TABLES gt_uslvcc
                                 USING 'UNAME_C' 'X'.

  PERFORM f_create_dyn_int_table TABLES gt_nmfcat
                                 USING 'KTEXT' ''.
  PERFORM f_create_dyn_int_table TABLES gt_nmlvcc
                                 USING 'KTEXT_C' 'X'.

  PERFORM f_create_dyn_int_table TABLES gt_tmfcat
                                 USING 'TIME' ''.
  PERFORM f_create_dyn_int_table TABLES gt_tmlvcc
                                 USING 'TIME_C' 'X'.

  PERFORM f_create_dyn_int_table TABLES gt_tofcat
                                 USING 'TO' ''.

  PERFORM f_create_dyn_int_table TABLES gt_dnfcat
                                 USING 'DN' ''.

  PERFORM f_create_dyn_int_table TABLES gt_shfcat
                                 USING 'SHIPMENT' ''.

  PERFORM f_create_dyn_int_table TABLES gt_sdfcat
                               USING 'STATUS_DO' ''.
  PERFORM f_create_dyn_int_table TABLES gt_sdfcat
                             USING 'STATUS_DO_C' 'X'.
  PERFORM f_create_dyn_int_table TABLES gt_mpfcat
                               USING 'MONITOR_PICKING' ''.
  PERFORM f_create_dyn_int_table TABLES gt_mpfcat
                             USING 'MONITOR_PICKING_C' 'X'.
  PERFORM f_create_dyn_int_table TABLES gt_dfcat
                               USING 'DETL' ''.
  CASE 'X'.
    WHEN radio1.
      PERFORM f_get_data_picking.
    WHEN radio2.
      PERFORM f_get_data_putaway.
    WHEN radio3.
      PERFORM f_get_data_transfer.
    WHEN radio4.
      PERFORM f_get_data_chkout.
    WHEN radio5.
      PERFORM f_get_data_chkin.
    WHEN radio6.
      PERFORM f_get_status_do.
    WHEN radio7.
      PERFORM f_get_monitoring_picking.
  ENDCASE.

  PERFORM f_get_full_name.

  PERFORM f_get_data_delivery.
  CASE 'X'.
    WHEN radio4.
      PERFORM f_process_shipment.
    WHEN radio6.
      PERFORM f_process_status_do.
    WHEN radio7.
      PERFORM f_process_monitor_picking.
    WHEN OTHERS.
      PERFORM f_process_to.
  ENDCASE.

  PERFORM f_print_data.

  INCLUDE zwm_r001m01.

  INCLUDE zwm_r001f01.
