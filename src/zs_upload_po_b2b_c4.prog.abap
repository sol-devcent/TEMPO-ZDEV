*&---------------------------------------------------------------------*
*& Report  ZS_UPLOAD_PO_B2B_C4
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zs_upload_po_b2b_c4 NO STANDARD PAGE HEADING.

INCLUDE zvx_interface_incl.

INCLUDE zs_upload_po_b2b_c4top.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE text-001.
PARAMETERS p_path(125) DEFAULT '\\tdsdev01\interface2\b2b\carrefour' LOWER CASE.
PARAMETERS p_kvgr4 LIKE zsmat_b2b-kvgr4 DEFAULT '05' OBLIGATORY.
PARAMETERS p_flname LIKE zsb2b_errlog-filename NO-DISPLAY.
PARAMETERS p_delete(1) NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK general.

INITIALIZATION.
*{   REPLACE        P01K910797                                        1
*\  IF sy-opsys EQ 'AIX'.
  IF sy-opsys EQ 'AIX' OR sy-opsys EQ 'Linux' OR sy-opsys EQ 'LINUX'.     "original: only for AIX "SOH: Shell Remediation Adjustment 20240403 KRS
*}   REPLACE
    p_path = '/interface2/b2b/carrefour'.
  ENDIF.

START-OF-SELECTION.
*{   REPLACE        P01K910797                                        1
*\  IF sy-opsys EQ 'AIX'.
  IF sy-opsys EQ 'AIX' OR sy-opsys EQ 'Linux' OR sy-opsys EQ 'LINUX'.     "original: only for AIX "SOH: Shell Remediation Adjustment 20240403 KRS
*}   REPLACE
    PERFORM f_path_format USING '/' '/carrefour'.
  ELSE.
    PERFORM f_path_format USING '\' '\carrefour'.
  ENDIF.

  PERFORM f_get_file_name USING v_interfacein all_gen p_flname.
  DELETE i_file_list WHERE name = '.'.
  DELETE i_file_list WHERE name = '..'.
  DELETE i_file_list WHERE type = 'directory'.

  SORT i_file_list BY name ASCENDING.
  LOOP AT i_file_list.
    PERFORM f_move_file
            USING i_file_list-name
                  i_file_list-name
                  v_interfacein
                  v_interfaceprocess.

    i_file_list-dirname = v_interfaceprocess.
    MODIFY i_file_list.
  ENDLOOP.

  IF sy-subrc <> 0.
    v_error_msg = '*********No files in IN directory**********'.
    PERFORM f_log USING v_error_msg v_logfile.
    EXIT.
  ENDIF.

  LOOP AT i_file_list.
    CLEAR : itabline, gt_xml[], l_err.
    PERFORM f_read_data USING i_file_list-dirname
                              i_file_list-name.

    PERFORM f_xml_transformation.

    IF gs_var_text IS INITIAL.
      PERFORM f_proses_data TABLES gt_po_header
                                   gt_po_detail
                                   gt_po_footer.
    ENDIF.

    MODIFY i_file_list.

    IF v_delete IS INITIAL.
      PERFORM f_split_file1 USING i_file_list-name
                                  v_interfaceprocess
                                  v_interfaceerror
                                  v_interfacesuccess.
      IF p_delete = 'X'.
        PERFORM f_delete_errlog.
      ENDIF.
    ELSE.
      ADD 1 TO va_totdelete.
      PERFORM f_file_delete USING i_file_list-name
                                  v_interfaceprocess
                                  v_interfacedelete.
      PERFORM f_delete_errlog.
    ENDIF.
  ENDLOOP.

  CONCATENATE va_totdelete 'Files Deleted' INTO v_error_msg
      SEPARATED BY space.

  IF i_file_list IS INITIAL.
    v_error_msg = '*********No files in IN directory**********'.
    PERFORM f_log USING v_error_msg v_logfile.
  ELSE.
    PERFORM f_log USING v_error_msg v_logfile.
  ENDIF.

  INCLUDE zs_upload_po_b2b_c4f01.
