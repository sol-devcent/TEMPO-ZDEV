***INCLUDE ZSTDXIN_UDF .

TABLES: rlgrap.

TYPE-POOLS sscr.
CONSTANTS: c_udf_yes VALUE 'X',
           c_udf_no VALUE space.

DATA: d_udf_restr TYPE sscr_restrict,
      d_udf_optls TYPE sscr_opt_list,
      d_udf_scras TYPE sscr_ass.

DATA: d_udf_memid(32),
      d_udf_error,
      d_udf_subrc LIKE sy-subrc,
      d_udf_ovwrt, " Flags for Overwrite
      d_udf_uname VALUE 'X', "Flag for specific memory id
      d_udf_tabix LIKE sy-tabix,
      d_udf_fsize(12) TYPE n,
      d_udf_bmode VALUE 'F'.  "Browse mode: [F]ile, [D]irectory
*      class_udf TYPE REF TO zabpxcl_udf.

DATA: d_udf_fname LIKE rlgrap-filename,
      d_udf_drcty LIKE pcfile-path,
      d_udf_drive LIKE pcfile-drive,
      d_udf_filnm LIKE rlgrap-filename,
      d_udf_extns(8).

*-----------------------------------------------------------------------
*@form        macro_udf_fname_parameters
*@description macro to define filename parameter
*@param       &1
*@par-desc    parameter name to define
*@param       &2
*@par-desc    default directory name
*@param       &3
*@par-desc    [D]irectory or [F]ile browsing ?
*@param       &4
*@par-desc    [R]ead or [W]rite ?
*-----------------------------------------------------------------------
DEFINE macro_udf_fname_parameters.
  parameters &1 like rlgrap-filename memory id &1
             obligatory.
  constants c_&1(60) value &2.
  data: d_chk_&1 value '&3',
        d_typ_&1 value '&4'.
END-OF-DEFINITION.

*-----------------------------------------------------------------------
*@form        macro_udf_fname_parameters
*@description macro to define filename select-option
*@param       &1
*@par-desc    select-option name to define
*@param       &2
*@par-desc    default directory name
*-----------------------------------------------------------------------
DEFINE macro_udf_fname_select_options.
  select-options &1 for rlgrap-filename default &2 obligatory
                                      no intervals.
  constants c_&1-low(128) value &2.
  data: d_chk_&1 value '&3',
        d_typ_&1 value '&4'.
END-OF-DEFINITION.

*-----------------------------------------------------------------------
*@form        macro_udf_selopt_restrict
*@description macro to restric SELECT-OPTIONS from intervals
*@param       &1
*@par-desc    SELECT-OPTIONS name to define
*@param       &2
*@par-desc    [X] Start restrict, [ ] Append restrict to ITAB
*-----------------------------------------------------------------------
DEFINE macro_udf_selopt_restrict.
  clear: d_udf_scras, d_udf_optls.
  d_udf_optls-name    = '&1'.
  d_udf_optls-options-eq = 'X'.
  append d_udf_optls to d_udf_restr-opt_list_tab.
  d_udf_scras-kind    = 'S'.
  d_udf_scras-name    = '&1'.
  d_udf_scras-sg_main = 'I'.
  d_udf_scras-op_main = '&1'.
  append d_udf_scras to d_udf_restr-ass_tab.
  if &2 = 'X'.
    call function 'SELECT_OPTIONS_RESTRICT'
         exporting
              restriction = d_udf_restr
         exceptions
              others      = 1.
  endif.
END-OF-DEFINITION.

*-----------------------------------------------------------------------
*@form        macro_udf_check_parameters
*@description macro to check upload file
*@param       &1
*@par-desc    PARAMETERS name to check
*-----------------------------------------------------------------------
DEFINE macro_udf_check_parameters.

at selection-screen on &1.
  if d_chk_&1 eq 'F'.
    macro_udf_check_file_exist &1 d_typ_&1.
  else.
    perform f_udf_check_directory_exist using &1.
  endif.
  clear d_udf_memid.
  if d_udf_uname ne space.
    concatenate sy-cprog sy-uname '&1' into d_udf_memid.
  else.
    concatenate sy-cprog '&1' into d_udf_memid.
  endif.
  if &1 ne c_&1.
    export &1 to memory id d_udf_memid.
  endif.
END-OF-DEFINITION.

*-----------------------------------------------------------------------
*@form        macro_udf_check_select_options
*@description macro to check upload file
*@param       &1
*@par-desc    PARAMETERS name to check
*-----------------------------------------------------------------------
DEFINE macro_udf_check_select_options.

at selection-screen on &1.
  loop at &1.
    d_udf_tabix = sy-tabix.
    if d_chk_&1 eq 'F'.
      macro_udf_check_file_exist &1-low d_typ_&1.
    else.
      perform f_udf_check_directory_exist using &1-low.
    endif.
    if ( d_udf_tabix eq 1 ) and
       ( d_udf_error eq c_udf_no ) and
       ( &1-low ne space ).
      clear d_udf_memid.
      if d_udf_uname ne space.
        concatenate sy-cprog sy-uname '&1-LOW' into d_udf_memid.
      else.
        concatenate sy-cprog '&1-LOW' into d_udf_memid.
      endif.
      export &1-low to memory id d_udf_memid.
    endif.
  endloop.
END-OF-DEFINITION.

*-----------------------------------------------------------------------
*@form        macro_udf_init_parameters
*@description macro to set parameter value
*@param       &1
*@par-desc    PARAMETERS name to set value
*-----------------------------------------------------------------------
DEFINE macro_udf_init_parameters.
  if &1 eq c_&1.
*    loop at screen.
*      check screen-name eq '&1'.
*      clear d_udf_memid.
*      if d_udf_uname ne space.
*        concatenate sy-cprog sy-uname '&1' into d_udf_memid.
*      else.
*        concatenate sy-cprog '&1' into d_udf_memid.
*      endif.
*
*      import &1 from memory id d_udf_memid.
*      exit.
*    endloop.
  endif.
END-OF-DEFINITION.

*-----------------------------------------------------------------------
*@form        macro_udf_init_select_options
*@description macro to set parameter value
*@param       &1
*@par-desc    SELECT-OPTIONS name to set value
*-----------------------------------------------------------------------
DEFINE macro_udf_init_select_options.
  if &1-low eq c_&1-low.
    loop at screen.
      check screen-name eq '&1-LOW'.
      clear d_udf_memid.
      if d_udf_uname ne space.
        concatenate sy-cprog sy-uname '&1-LOW' into d_udf_memid.
      else.
        concatenate sy-cprog '&1-LOW' into d_udf_memid.
      endif.
      import &1-low from memory id d_udf_memid.
      exit.
    endloop.
  endif.
END-OF-DEFINITION.

*-----------------------------------------------------------------------
*@form        macro_udf_f4_parameters
*@description macro to handle f4 on p_fname
*@param       &1
*@par-desc    PARAMETERS name to check
*@param       &2
*@par-desc    [D]irectory or [F]ile browsing
*-----------------------------------------------------------------------
DEFINE macro_udf_f4_parameters.

at selection-screen on value-request for &1.
  if d_typ_&1 eq 'R'.
    macro_udf_get_fname &1 'O' d_chk_&1.
  else.
    macro_udf_get_fname &1 'S' d_chk_&1.
  endif.
END-OF-DEFINITION.

*-----------------------------------------------------------------------
*@form        macro_udf_f4_select_options
*@description macro to handle f4 on p_fname
*@param       &1
*@par-desc    SELECT-OPTIONS name to check
*@param       &2
*@par-desc    [D]irectory or [F]ile browsing
*-----------------------------------------------------------------------
DEFINE macro_udf_f4_select_options.

at selection-screen on value-request for &1-low.
  if d_typ_&1 eq 'R'.
    macro_udf_get_fname &1-low 'O' d_chk_&1.
  else.
    macro_udf_get_fname &1-low 'S' d_chk_&1.
  endif.
END-OF-DEFINITION.

*-----------------------------------------------------------------------
*@form        macro_udf_f4_fname
*@description macro to handle f4 on p_fname
*@param       &1
*@par-desc    parameter name to check
*@param       &2
*@par-desc    [O]pen, [S]ave
*@param       &3
*@par-desc    [D]irectory or [F]ile browsing
*-----------------------------------------------------------------------
DEFINE macro_udf_get_fname.
  if class_udf is initial.
    create object class_udf.
  endif.
  d_udf_error = c_udf_no.
  message s000(zab) with &1.
  call method class_udf->clmt_setget_file
    exporting
      clmti_type              = &2
      clmti_mode              = &3
      clmtc_fild              = '&1'
    changing
      clmtc_file              = &1
    exceptions
      clmtx_invalid_file      = 1
      clmtx_invalid_directory = 2
      clmtx_file_cotrol_error = 3
      clmtx_unknown_error     = 4
      clmtx_invalid_winsys    = 5
      clmtx_selection_cancel  = 6
      clmtx_selection_error   = 7
      clmtx_no_batch          = 8
      others                  = 9.
  if sy-subrc <> 0 and sy-subrc ne 6.
    d_udf_error = c_udf_yes.
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
END-OF-DEFINITION.

*-----------------------------------------------------------------------
*@form        MACRO_UDF_DOWNLOAD
*@description download data from SAP
*@param       &1
*@par-desc    filename used, if no file given then call save as file
*              dialog selected
*@param       &2
*@par-desc    download data type
*@par-val     'ASC' for ascii file
*             'DAT' for dat file
*             'BIN' for binary file
*@param       &3
*@par-desc    itab to download
*-----------------------------------------------------------------------
DEFINE macro_udf_download.
  if &1 is initial.
    macro_udf_get_fname &1 'F' d_udf_bmode.
    if d_udf_bmode eq 'F'.
      macro_udf_check_file_exist &1 'W'.
    else.
      perform f_udf_check_directory_exist using &1.
    endif.
  endif.

  if &1 ne space.
    d_udf_error = c_udf_yes.
    call function 'WS_DOWNLOAD'
         exporting
              bin_filesize        = d_udf_fsize
              filename            = &1
              filetype            = &2
         importing
              filelength          = d_udf_fsize
         tables
              data_tab            = &3
*              filed_names         = clmte_fild
         exceptions
              file_open_error     = 1
              file_write_error    = 2
              invalid_filesize    = 3
              invalid_table_width = 4
              invalid_type        = 5
              no_batch            = 6
              unknown_error       = 7
              others              = 8.
    case sy-subrc.
      when 0. d_udf_error = c_udf_no.
      when 1. message s000(zab) with 'File open error'.
      when 2. message s000(zab) with 'File write error'.
      when 3. message s000(zab) with 'Invalid file size'.
      when 4. message s000(zab) with 'Invalid table width'.
      when 5. message s000(zab) with 'Invalid type'.
      when others. message s000(zab) with 'Unknown Error'.
    endcase.
  endif.
END-OF-DEFINITION.

*-----------------------------------------------------------------------
*@form        MACRO_UDF_UPLOAD
*@description upload data to SAP
*@param       &1
*@par-desc    filename used, if no file given then call open file
*             dialog selected
*@param       &2
*@par-desc    upload data type
*@par-val     'ASC' for ascii file
*             'DAT' for dat file
*@param       &3
*@par-desc    itab with uploaded data
*-----------------------------------------------------------------------
DEFINE macro_udf_upload.
  if &1 is initial.
    macro_udf_get_fname &1 'F' d_udf_bmode.
    if d_udf_bmode eq 'F'.
      macro_udf_check_file_exist &1 'R'.
    else.
      perform f_udf_check_directory_exist using &1.
    endif.
  endif.
  if not &1 is initial.
    call function 'WS_UPLOAD'
         exporting
              filename            = &1
              filetype            = &2
         importing
              filelength          = d_udf_fsize
         tables
              data_tab            = &3
         exceptions
              conversion_error    = 1
              file_open_error     = 2
              file_read_error     = 3
              invalid_table_width = 4
              invalid_type        = 5
              no_batch            = 6
              unknown_error       = 7
              others              = 8.
    case sy-subrc.
      when 0.
      when 1. message s000(zab) with 'File conversion Error'.
      when 2. message s000(zab) with 'File opening error'.
      when 3. message s000(zab) with 'File Read Error'.
      when 4. message s000(zab) with 'Invalid table width'.
      when 5. message s000(zab) with 'Invalid type'.
      when others. message s000(zab) with 'Unknow Error'.
    endcase.
  endif.
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*@form        MACRO_UDF_DOWNLOAD
*@description download data from SAP
*@param       &1
*@par-desc    filename used
*@param       &2
*@par-desc    file type
*@par-val     'R' Read
*             'W' Write
*&---------------------------------------------------------------------*
*DEFINE macro_udf_check_file_exist.
*  if class_udf is initial.
*    create object class_udf.
*  endif.
*  d_udf_error = c_udf_no.
*  call method class_udf->clmt_check_file_exist
*    exporting
*      clmti_file              = &1
*      clmti_type              = &2
*    exceptions
*      clmtx_file_not_found    = 1
*      clmtx_file_is_open      = 2
*      clmtx_invalid_file_name = 3
*      clmtx_file_is_exist     = 4
*      others                  = 5.
*  if sy-subrc <> 0.
*    if ( sy-subrc eq 4 and d_udf_ovwrt eq space ) or sy-subrc ne 4.
*      d_udf_error = c_udf_yes.
*      message id sy-msgid type sy-msgty number sy-msgno
*                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    else.
*      message w000(zab) with 'Warning ! File' &1
*                            'already exist !'.
*    endif.
*  endif.
*END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Form  F_UDF_CHECK_DIRECTORY_EXIST
*&---------------------------------------------------------------------*
*FORM f_udf_check_directory_exist USING fu_fname.
*  DATA: ld_fname LIKE  rlgrap-filename.
*  ld_fname = fu_fname.
*  IF class_udf IS INITIAL.
*    CREATE OBJECT class_udf.
*  ENDIF.
*  d_udf_error = c_udf_no.
*  CALL METHOD class_udf->clmt_check_directory
*    EXPORTING
*      clmti_path      = ld_fname
*    EXCEPTIONS
*      clmtx_not_found = 1
*      OTHERS          = 2.
*  IF sy-subrc <> 0.
*    d_udf_error = c_udf_yes.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*ENDFORM.                    " F_UDF_CHECK_DIRECTORY_EXIST

*&---------------------------------------------------------------------*
*&      Form  F_UDF_GET_PATH_NAME
*&---------------------------------------------------------------------*
FORM f_udf_get_path_name USING fu_fname.
  DATA: ld_char,
        ld_length TYPE i,
        ld_position TYPE i,
        ld_count TYPE i,
        ld_directory LIKE pcfile-path.

  ld_directory = fu_fname.
  CALL FUNCTION 'PC_SPLIT_COMPLETE_FILENAME'
       EXPORTING
            complete_filename = ld_directory
*           CHECK_DOS_FORMAT  =
       IMPORTING
            drive             = d_udf_drive
            extension         = d_udf_extns
            name              = d_udf_filnm
            name_with_ext     = d_udf_fname
            path              = d_udf_drcty
       EXCEPTIONS
            invalid_drive     = 1
            invalid_extension = 2
            invalid_name      = 3
            invalid_path      = 4
            OTHERS            = 5.
  d_udf_subrc = sy-subrc.
ENDFORM.                               " F_UDF_GET_PATH_NAME
