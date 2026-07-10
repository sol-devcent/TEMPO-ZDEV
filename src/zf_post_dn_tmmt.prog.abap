*&----------------------------------------------------------------------
*&  TMMT Post Jurnal
*&  17.06.2024
*&---------------------------------------------------------------------*
REPORT  zf_post_dn_tmmt NO STANDARD PAGE HEADING.

* common report header and other functions
INCLUDE zabp_header.

* ALV common functions
INCLUDE zabp_alv_common.

* BDC Include
INCLUDE zabp_bdc.

*------------------common TOP includes for the program----------------*
INCLUDE zf_post_dn_tmmttop.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
PARAMETERS     p_bukrs  TYPE bukrs.
PARAMETERS     p_gjahr  TYPE gjahr DEFAULT sy-datum(4) MODIF ID r03.
SELECT-OPTIONS s_subty  FOR  zfgstype-zsubtype NO INTERVALS MODIF ID r01.
SELECT-OPTIONS s_budat  FOR  zfgscab-tglpost NO-EXTENSION MODIF ID r01.
SELECT-OPTIONS s_xref2  FOR  zfgscab-xref2 MODIF ID r05.
SELECT-OPTIONS s_esg FOR zfgscab_map1-exp_sub_grp MODIF ID r04.
SELECT-OPTIONS s_hkont FOR zfgscab_map1-hkont MODIF ID r04.
SELECT-OPTIONS s_wwsec FOR zfgscab_map1-wwsec MODIF ID r04.
SELECT-OPTIONS s_wwtrz FOR zfgscab_map1-wwtrz MODIF ID r04.
SELECTION-SCREEN SKIP.
PARAMETERS p_susacc AS CHECKBOX MODIF ID chk.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-b04.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio1a RADIOBUTTON GROUP grp1.
*PARAMETERS radio2 RADIOBUTTON GROUP grp1.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
PARAMETERS radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.

SELECTION-SCREEN BEGIN OF SCREEN 1001 AS WINDOW.
PARAMETERS p_hkont TYPE zfgstype-hkont OBLIGATORY DEFAULT '0315100040'.
SELECTION-SCREEN END OF SCREEN 1001.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  p_bukrs = '8020'.
  PERFORM f_init_budat.
  PERFORM f_init_subtype.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen_1000.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  IF sscrfields-ucomm IS INITIAL OR
     sscrfields-ucomm EQ 'ONLI'.
    PERFORM f_validate_screen_1000.
  ENDIF.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN ON VALUE-REQUEST
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_hkont.
  PERFORM f_get_acc_pph CHANGING p_hkont.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  DATA : selections TYPE TABLE OF vimsellist,
         selection TYPE vimsellist.

  CASE 'X'.
    WHEN radio1 OR radio1a.
      PERFORM f_init_data.
      PERFORM f_get_data.
      CASE 'X'.
        WHEN radio1.
          PERFORM f_process_data.
        WHEN radio1a.
          PERFORM f_process_data_sku.
      ENDCASE.
      PERFORM f_print_data.
      PERFORM f_free_memory.
*    WHEN radio2.
*      CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
*        EXPORTING
*          action                       = 'U'
*          view_name                    = 'ZFGSCAB_MAP'
*          complex_selconds_used        = 'X'
*        TABLES
*          dba_sellist                  = selections
*        EXCEPTIONS
*          client_reference             = 1
*          foreign_lock                 = 2
*          invalid_action               = 3
*          no_clientindependent_auth    = 4
*          no_database_function         = 5
*          no_editor_function           = 6
*          no_show_auth                 = 7
*          no_tvdir_entry               = 8
*          no_upd_auth                  = 9
*          only_show_allowed            = 10
*          system_failure               = 11
*          unknown_field_in_dba_sellist = 12
*          view_not_found               = 13
*          maintenance_prohibited       = 14
*          OTHERS                       = 15.
    WHEN radio3.
      PERFORM f_process_3.
    WHEN radio4.
      PERFORM f_get_data_new.
      PERFORM f_print_data_new.
*      PERFORM f_selection_filter TABLES selections.
*      CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
*        EXPORTING
*          action                       = 'U'
*          view_name                    = 'ZFGSCAB_MAP1'
*          complex_selconds_used        = 'X'
*        TABLES
*          dba_sellist                  = selections
*        EXCEPTIONS
*          client_reference             = 1
*          foreign_lock                 = 2
*          invalid_action               = 3
*          no_clientindependent_auth    = 4
*          no_database_function         = 5
*          no_editor_function           = 6
*          no_show_auth                 = 7
*          no_tvdir_entry               = 8
*          no_upd_auth                  = 9
*          only_show_allowed            = 10
*          system_failure               = 11
*          unknown_field_in_dba_sellist = 12
*          view_not_found               = 13
*          maintenance_prohibited       = 14
*          OTHERS                       = 15.


  ENDCASE.

END-OF-SELECTION.

*------------------common Routine includes for the program----------------*
  INCLUDE zf_post_dn_tmmtf01.
