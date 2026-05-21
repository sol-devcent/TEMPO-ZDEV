*----------------------------------------------------------------------*
*   INCLUDE ZABP_UDF                                                   *
*----------------------------------------------------------------------*

data: d_udf_totalrecords type i,
      d_udf_tab type x value '09',
      d_udf_subrc like sy-subrc,
      d_udf_fsize(12) type n,
      d_udf_memid like sy-cprog,
      d_udf_chkfl value 'X',           " Need to check file ?
      d_udf_fname like rlgrap-filename,
      d_udf_drcty like pcfile-path,
      d_udf_drive like pcfile-drive,
      d_udf_filnm like rlgrap-filename,
      d_udf_extns(8),
      d_udf_dspms value 'X',           "Flags to display error message
      d_udf_dsn_msg(50).

data: d_udf_lngth type i,
      d_udf_count type i,
      d_udf_start type i,
      d_udf_nchar,
      d_udf_xchar type x.


*$*$ @enddata

*$*$--------------------------------------------------------------------
*$*$ Lib global Subroutines
*$*$--------------------------------------------------------------------

*-----------------------------------------------------------------------
* @form        MACRO_UDF_FNAME_PARAMETERS
* @description macro to define filename parameter
* @param       &1
* @par-desc    parameter name to define
* @param       &2
* @par-desc    default directory name
*-----------------------------------------------------------------------
define macro_udf_fname_parameters.
  parameters: &1 like rlgrap-filename default &2 obligatory.
end-of-definition.

*-----------------------------------------------------------------------
* @form        MACRO_UDF_CHECK_UPLOAD
* @description macro to check upload file
* @param       &1
* @par-desc    parameter name to check
*-----------------------------------------------------------------------
define macro_udf_check_upload.

at selection-screen on &1.
  perform f_udf_check_directory using &1.
  perform f_udf_check_file_exist using &1 'U'.
  perform f_udf_check_file_length using &1.
  clear d_udf_memid.
  concatenate sy-cprog '&1' into d_udf_memid.
  export &1 to memory id d_udf_memid.
end-of-definition.

*-----------------------------------------------------------------------
* @form        MACRO_UDF_CHECK_DOWNLOAD
* @description macro to check upload file
* @param       &1
* @par-desc    parameter name to check
*-----------------------------------------------------------------------
define macro_udf_check_download.

at selection-screen on &1.
  perform f_udf_check_directory using &1.
  perform f_udf_check_file_exist using &1 'D'.
  clear d_udf_memid.
  concatenate sy-cprog '&1' into d_udf_memid.
  export &1 to memory id d_udf_memid.
end-of-definition.

*-----------------------------------------------------------------------
* @form        MACRO_UDF_INIT_FNAME
* @description macro to set parameter value
* @param       &1
* @par-desc    parameter name to set value
*-----------------------------------------------------------------------
define macro_udf_init_fname.
  if &1 is initial.
    loop at screen.
      check screen-name eq '&1'.
      clear d_udf_memid.
      concatenate sy-cprog '&1' into d_udf_memid.
      import &1 from memory id d_udf_memid.
      exit.
    endloop.
  endif.
end-of-definition.

*-----------------------------------------------------------------------
* @form        MACRO_UDF_F4_FNAME
* @description macro to handle F4 on P_FNAME
* @param       &1
* @par-desc    parameter name to check
*-----------------------------------------------------------------------
define macro_udf_f4_fname.

at selection-screen on value-request for &1.
  perform f_udf_get_field_value
        using '&1' changing &1.
  perform f_udf_get_filename
        using 'F'
        changing &1.
end-of-definition.

*-----------------------------------------------------------------------
* @form        F_UDF_GET_FILENAME
* @description query to window system and show file dialog to choose
*              a file
* @param       FU_TYPE
* @par-desc    type for dialog file
* @par-val     'O' for 'open' file dialog
*              'S' for 'save as' file dialog
* @param       FC_FNAME
* @par-desc    filename selected
*-----------------------------------------------------------------------
form f_udf_get_filename using fu_type
                        changing fc_fname.
  data: ld_filename like rlgrap-filename,
        ld_title(20),
        ld_length type i,
        ld_path(80).
  field-symbols: <lf_symbol>.
  ld_path = fc_fname.
  if ld_path ne space.

    ld_length = strlen( ld_path ) - 1.
    assign ld_path+ld_length(1) to <lf_symbol>.
    if <lf_symbol> eq '/' or <lf_symbol> eq '\'.
      ld_path = ld_path(ld_length).
    endif.
  endif.

  if fu_type eq 'O'.
    ld_title = 'Open file'.
  elseif fu_type eq 'F'.
    ld_title = 'Select file'.
  else.
    ld_title = 'Save as'.
  endif.

* Build Filter for Fileselektor
  call function 'WS_FILENAME_GET'
       exporting
            def_filename     = ld_filename
            def_path         = ld_path
            mask             = ',*.*,*.*.'
            mode             = 'S'
            title            = ld_title
       importing
            filename         = ld_filename
       exceptions
            inv_winsys       = 01
            no_batch         = 02
            selection_cancel = 03
            selection_error  = 04.
  d_udf_subrc = sy-subrc.
  check d_udf_subrc = 0.
  fc_fname = ld_filename.
  check d_udf_chkfl is initial.
  perform f_udf_get_path_name using fc_fname.
  concatenate d_udf_drive ':' d_udf_drcty into fc_fname.
endform.

*-----------------------------------------------------------------------
* @form        MACRO_UDF_UPLOAD
* @description upload data to SAP
* @param       &1
* @par-desc    filename used, if no file given then call open file
*              dialog selected
* @param       &2
* @par-desc    upload data type
* @par-val     'ASC' for ascii file
*              'DAT' for dat file
*              see WS_UPLOAD documentation for filetype
* @param       &3
* @par-desc    itab with uploaded data
*-----------------------------------------------------------------------
define macro_udf_upload.
  if &1 is initial.
    perform f_udf_get_filename using 'O' &1.
  endif.
  if &1 ne space.

*Begin remark Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
*    call function 'WS_UPLOAD'
*         exporting
*              filename            = &1
*              filetype            = &2
*         importing
*              filelength          = d_udf_fsize
*         tables
*              data_tab            = &3
*         exceptions
*              conversion_error    = 1
*              file_open_error     = 2
*              file_read_error     = 3
*              invalid_table_width = 4
*              invalid_type        = 5
*              no_batch            = 6
*              unknown_error       = 7
*              others              = 8.
*End remark Unicode conversion - DEVK965554

*Begin insert Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
*  data: lv_filename TYPE string.
*  clear lv_filename.
*  lv_filename = fu_filename.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD
    EXPORTING
      FILENAME                = &1
      FILETYPE                = &2
    CHANGING
      DATA_TAB                = &3
    EXCEPTIONS
      FILE_OPEN_ERROR         = 1
      FILE_READ_ERROR         = 2
      NO_BATCH                = 3
      GUI_REFUSE_FILETRANSFER = 4
      INVALID_TYPE            = 5
      NO_AUTHORITY            = 6
      UNKNOWN_ERROR           = 7
      BAD_DATA_FORMAT         = 8
      HEADER_NOT_ALLOWED      = 9
      SEPARATOR_NOT_ALLOWED   = 10
      HEADER_TOO_LONG         = 11
      UNKNOWN_DP_ERROR        = 12
      ACCESS_DENIED           = 13
      DP_OUT_OF_MEMORY        = 14
      DISK_FULL               = 15
      DP_TIMEOUT              = 16
      NOT_SUPPORTED_BY_GUI    = 17
      ERROR_NO_GUI            = 18
      others                  = 19.
*End insert Unicode conversion - DEVK965554

    d_udf_subrc = sy-subrc.
    describe table &3 lines d_udf_totalrecords.
    if d_udf_subrc ne 0 and d_udf_dspms ne space.
      case d_udf_subrc.
        when 1.
          message i000(zab)
             with 'Conversion Error in Input File'.
        when 2. message i000(zab) with 'Error when Opening Input File'.
        when 3. message i000(zab) with 'Read Error in Input File'.
        when others. message i000(zab) with 'Error in Input File'.
      endcase.
    endif.
  endif.
end-of-definition.

*-----------------------------------------------------------------------
* @form        MACRO_UDF_WRITE_SERVER
* @description write data to SAP Server
* @param       &1
* @par-desc    filename used, if no file given then call open file
*              dialog selected
* @param       &2
* @par-desc    destination path in server
* @par-val     '/sapdev/doc/'
* @param       &3
* @par-desc    itab with data to write in server
*-----------------------------------------------------------------------
define macro_udf_write_server.
  concatenate &2 &1 into d_udf_dsn_msg.
  open dataset d_udf_dsn_msg for output in binary mode.
  loop at &3.
    transfer &3 to d_udf_dsn_msg.
  endloop.
  close dataset d_udf_dsn_msg.
end-of-definition.

*-----------------------------------------------------------------------
* @form        MACRO_UDF_DOWNLOAD
* @description download data from SAP
* @param       &1
* @par-desc    filename used, if no file given then call save as file
*              dialog selected
* @param       &2
* @par-desc    download data type
* @par-val     'ASC' for ascii file
*              'DAT' for dat file
*              see WS_DOWNLOAD documentation for filetype
* @param       &3
* @par-desc    itab to download
*-----------------------------------------------------------------------
define macro_udf_download.
  if &1 eq space.
    perform f_udf_get_filename using 'S' &1.
  endif.
  if &1 ne space.
    call function 'WS_DOWNLOAD'
         exporting
              bin_filesize        = d_udf_fsize
              filename            = &1
              filetype            = &2
         tables
              data_tab            = &3
         exceptions
              file_open_error     = 1
              file_write_error    = 2
              invalid_filesize    = 3
              invalid_table_width = 4
              invalid_type        = 5
              no_batch            = 6
              unknown_error       = 7
              others              = 8.
    d_udf_subrc = sy-subrc.
    if d_udf_subrc ne 0 and d_udf_dspms ne space.
      case sy-subrc.
        when 1. message i000(zab) with 'File open error !'.
        when 2. message i000(zab) with 'File write error !'.
        when 3. message i000(zab) with 'Invalid file size !'.
        when 4. message i000(zab) with 'Invalid table width !'.
        when 5. message i000(zab) with 'Invalid type !'.
        when 6. message i000(zab) with 'No batch !'.
        when 7. message i000(zab) with 'Unknown error !'.
        when 8. message i000(zab) with 'Unknown error !'.
      endcase.
    endif.
  endif.
end-of-definition.

*-----------------------------------------------------------------------
* @form        MACRO_UDF_READ_SERVER
* @description read data from SAP Server
* @param       &1
* @par-desc    filename used, if no file given then call save as file
*              dialog selected
* @param       &2
* @par-desc    path to read
* @par-val     '/sapdev/doc/'
* @param       &3
* @par-desc    itab to download
*-----------------------------------------------------------------------
define macro_udf_read_server.
  clear &3. refresh &3.
  do.
    read dataset d_udf_dsn_msg into &3.
    if sy-subrc <> 0.
      exit.
    endif.
    append &3.
    clear &3.
  enddo.

end-of-definition.

*-----------------------------------------------------------------------
* @form        F_UDF_CHECK_FILE_UPLOAD
* @description check file for upload
*              Error condition: if file not found or
*                               if file have length 0
* @param       FU_FNAME
* @par-desc    filename to check
*-----------------------------------------------------------------------
form f_udf_check_file_upload using fu_fname.
  translate fu_fname to upper case.
  call function 'WS_QUERY'
       exporting
            query    = 'FE'
            filename = fu_fname
       importing
            return   = d_udf_subrc.
  if d_udf_subrc is initial.
    if d_udf_dspms ne space.
      message id '57' type 'E' number 173 with fu_fname.
    endif.
    exit.
  endif.

  call function 'WS_QUERY'
       exporting
            query    = 'FL'
            filename = fu_fname
       importing
            return   = d_udf_subrc.
  check d_udf_subrc is initial and d_udf_dspms ne space.
  message id '6P' type 'E' number 603 with fu_fname.
endform.

*-----------------------------------------------------------------------
* @form        F_UDF_CHECK_FILE_DOWNLOAD
* @description check file for download
*              Error condition: if directory not found
*                               if file already exist
*                               (only if FU_EXIST = 'X')
* @param       FU_FNAME
* @par-desc    filename to check
* @param       FU_EXIST
* @par-desc    check filename already exist
*-----------------------------------------------------------------------
form f_udf_check_file_download using fu_fname fu_exist.
  data: ld_char(2),
        ld_length type i,
        ld_position type i,
        ld_count type i,
        ld_directory like rlgrap-filename.

  ld_directory = fu_fname.
  ld_count = strlen( fu_fname ).
  do ld_count times.
    ld_position = sy-index - 1.
    ld_char = ld_directory+ld_position(1).
    case ld_char(1).
      when ':' or '\'. ld_length = ld_position.
    endcase.
  enddo.
  ld_directory = ld_directory(ld_length).

  call function 'WS_QUERY'
       exporting
            query    = 'DE'
            filename = ld_directory
       importing
            return   = d_udf_subrc.
  if d_udf_subrc eq 0.
    if d_udf_dspms ne space.
      message id 'ZAB' type 'E' number 000 with ld_directory.
    endif.
    exit.
  endif.

  check not fu_exist is initial.
  translate fu_fname to upper case.
  call function 'WS_QUERY'
       exporting
            query    = 'FE'
            filename = fu_fname
       importing
            return   = d_udf_subrc.
  if d_udf_subrc ne 0 and d_udf_dspms ne space.
    message id '26' type 'E' number 179 with fu_fname.
  endif.
endform.

*-----------------------------------------------------------------------
* @form        f_udf_check_directory
* @description check existence directory
*              Error condition: if directory not found
* @param       FU_FNAME
* @par-desc    filename to check
*-----------------------------------------------------------------------
form f_udf_check_directory using fu_fname.
  data: ld_char,
        ld_length type i,
        ld_position type i,
        ld_count type i,
        ld_directory like rlgrap-filename.

  ld_directory = fu_fname.
  if ld_directory ne space.
    ld_count = strlen( fu_fname ).
    do ld_count times.
      ld_position = sy-index - 1.
      ld_char = ld_directory+ld_position(1).
      case ld_char.
        when ':' or '\'. ld_length = ld_position.
      endcase.
    enddo.
    if ld_length gt 0.
      ld_directory = ld_directory(ld_length).
    endif.
  endif.
  call function 'WS_QUERY'
       exporting
            query    = 'DE'
            filename = ld_directory
       importing
            return   = d_udf_subrc.
  if d_udf_subrc eq 0 and d_udf_dspms ne space.
    message e000(zab) with 'Directory' ld_directory 'does not exist !'.
  endif.
  if d_udf_chkfl = space.
    concatenate ld_directory '\' into fu_fname.
  endif.
endform.                               " F_UDF_CHECK_DIRECTORY

*-----------------------------------------------------------------------
* @form        F_UDF_CHECK_FILE_EXIST
* @description check existence file
*              Error condition: if file not found with FU_TYPES = 'U'
*                               if file was found with FU_TYPES = 'D'
* @param       FU_FNAME
* @par-desc    filename to check
* @param       FU_TYPES
* @par-desc    'U' = Upload, 'D'= Download
*-----------------------------------------------------------------------
form f_udf_check_file_exist using fu_fname fu_types.
  check d_udf_chkfl = 'X'.
  translate fu_fname to upper case.
  call function 'WS_QUERY'
       exporting
            query    = 'FE'
            filename = fu_fname
       importing
            return   = d_udf_subrc.
  check d_udf_dspms ne space.
* Display error message
  if d_udf_subrc eq 0 and fu_types eq 'U'.
    message e000(zab) with 'File' fu_fname 'does not exist !'.
  elseif d_udf_subrc ne 0 and fu_types eq 'D'.
    message e000(zab) with 'File' fu_fname 'already exist !'.
  endif.
endform.                               " F_UDF_CHECK_FILE_EXIST

*-----------------------------------------------------------------------
* @form        F_UDF_CHECK_FILE_LENGTH
* @description Check, if a file already open with another program
*              Error condition: if file already open by another program
* @param       FU_FNAME
* @par-desc    filename to check
*-----------------------------------------------------------------------
form f_udf_check_file_length using fu_fname.
  call function 'WS_QUERY'
       exporting
            query    = 'FL'
            filename = fu_fname
       importing
            return   = d_udf_subrc.
  check d_udf_subrc is initial and d_udf_dspms ne space.
  message e000(zab) with 'Error opening file' fu_fname.
endform.                               " F_UDF_CHECK_FILE_LENGTH

*-----------------------------------------------------------------------
* @form        F_UDF_GET_FIELD_VALUE
* @description Get field value, use in reporting for
*              AT SELECTION-SCREEN ON VALUE-REQUEST events.
* @param       FU_FNAME
* @par-desc    field name
* @param       FU_FVALUE
* @par-desc    field value
*-----------------------------------------------------------------------
form f_udf_get_field_value using fu_fname changing fc_fvalue.
  data: begin of lt_dynpfields occurs 0.
          include structure dynpread.
  data: end of lt_dynpfields.
  clear lt_dynpfields. refresh lt_dynpfields.
  lt_dynpfields-fieldname  = fu_fname.
  append lt_dynpfields.
  call function 'DYNP_VALUES_READ'
       exporting
            dyname     = sy-cprog
            dynumb     = sy-dynnr
       tables
            dynpfields = lt_dynpfields
       exceptions
            others.
  clear fc_fvalue.
  read table lt_dynpfields index 1.
  check sy-subrc = 0.
  fc_fvalue = lt_dynpfields-fieldvalue.
endform.

define macro_udf_tab_delimited.
  d_udf_lngth = strlen( &1 ).
  refresh &2. clear &2.
  clear d_udf_count.
  do d_udf_lngth times.
    d_udf_start = sy-index - 1.
    d_udf_nchar = &1+d_udf_start(1).
    write d_udf_nchar to d_udf_xchar.
    if d_udf_xchar eq '09'.
      append &2. clear &2.
      clear d_udf_count.
    else.
      &2+d_udf_count(1) = d_udf_nchar(1).
      add 1 to d_udf_count.
    endif.
  enddo.
  if d_udf_lngth gt 0.
    append &2. clear &2.
  endif.
end-of-definition.

*$*$--------------------------------------------------------------------
*$*$ Lib internal use Subroutines
*$*$--------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  F_UDF_GET_PATH_NAME
*&---------------------------------------------------------------------*
form f_udf_get_path_name using fu_fname.
  data: ld_char,
        ld_length type i,
        ld_position type i,
        ld_count type i,
        ld_directory like pcfile-path.

  ld_directory = fu_fname.
  call function 'PC_SPLIT_COMPLETE_FILENAME'
       exporting
            complete_filename = ld_directory
*           CHECK_DOS_FORMAT  =
       importing
            drive             = d_udf_drive
            extension         = d_udf_extns
            name              = d_udf_filnm
            name_with_ext     = d_udf_fname
            path              = d_udf_drcty
       exceptions
            invalid_drive     = 1
            invalid_extension = 2
            invalid_name      = 3
            invalid_path      = 4
            others            = 5.
  d_udf_subrc = sy-subrc.
endform.                               " F_UDF_GET_PATH_NAME
