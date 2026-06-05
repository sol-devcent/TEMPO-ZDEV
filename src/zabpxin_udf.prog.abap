* after upload this variable will be filled with total records, that
* succesed uploaded to SAP
DATA: d_udf_totalrecords TYPE i,
      d_udf_tab TYPE x VALUE '09',
      d_udf_subrc LIKE sy-subrc,
      d_udf_fsize(12) TYPE n,
      d_udf_memid LIKE sy-cprog,
      d_udf_chkfl VALUE 'X',           " Need to check file ?
      d_udf_fname LIKE rlgrap-filename,
      d_udf_drcty LIKE pcfile-path,
      d_udf_drive LIKE pcfile-drive,
      d_udf_filnm LIKE rlgrap-filename,
      d_udf_extns(8),
      d_udf_dspms VALUE 'X',           "Flags to display error message
      d_udf_dsn_msg(50).

DATA: d_udf_lngth TYPE i,
      d_udf_count TYPE i,
      d_udf_start TYPE i,
      d_udf_nchar,
      d_udf_xchar TYPE x.


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
DEFINE macro_udf_fname_parameters.
  parameters: &1 like rlgrap-filename default &2 obligatory."I-BAK010299
END-OF-DEFINITION.

*-----------------------------------------------------------------------
* @form        MACRO_UDF_CHECK_UPLOAD
* @description macro to check upload file
* @param       &1
* @par-desc    parameter name to check
*-----------------------------------------------------------------------
DEFINE macro_udf_check_upload.

at selection-screen on &1.
  perform f_udf_check_directory using &1.                 "I-BAK010299
  perform f_udf_check_file_exist using &1 'U'.            "I-BAK010299
  perform f_udf_check_file_length using &1.               "I-BAK010299
  clear d_udf_memid.
  concatenate sy-cprog '&1' into d_udf_memid.
  export &1 to memory id d_udf_memid.
END-OF-DEFINITION.

*-----------------------------------------------------------------------
* @form        MACRO_UDF_CHECK_DOWNLOAD
* @description macro to check upload file
* @param       &1
* @par-desc    parameter name to check
*-----------------------------------------------------------------------
DEFINE macro_udf_check_download.

at selection-screen on &1.
  perform f_udf_check_directory using &1.                 "I-BAK010299
  perform f_udf_check_file_exist using &1 'D'.            "I-BAK010299
  clear d_udf_memid.
  concatenate sy-cprog '&1' into d_udf_memid.
  export &1 to memory id d_udf_memid.
END-OF-DEFINITION.

*-----------------------------------------------------------------------
* @form        MACRO_UDF_INIT_FNAME
* @description macro to set parameter value
* @param       &1
* @par-desc    parameter name to set value
*-----------------------------------------------------------------------
DEFINE macro_udf_init_fname.
  if &1 is initial.
    loop at screen.
      check screen-name eq '&1'.
      clear d_udf_memid.
      concatenate sy-cprog '&1' into d_udf_memid.
      import &1 from memory id d_udf_memid.
      exit.
    endloop.
  endif.
END-OF-DEFINITION.

*-----------------------------------------------------------------------
* @form        MACRO_UDF_F4_FNAME
* @description macro to handle F4 on P_FNAME
* @param       &1
* @par-desc    parameter name to check
*-----------------------------------------------------------------------
DEFINE macro_udf_f4_fname.

at selection-screen on value-request for &1.
  perform f_udf_get_field_value
        using '&1' changing &1.
  perform f_udf_get_filename
        using 'F'
        changing &1.
END-OF-DEFINITION.

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
FORM f_udf_get_filename USING fu_type
                        CHANGING fc_fname.
  DATA: ld_filename LIKE rlgrap-filename,
        ld_title(20),
        ld_length TYPE i,
        ld_path(80).
  FIELD-SYMBOLS: <lf_symbol>.
  ld_path = fc_fname.
  IF ld_path NE space.                 "I-BAK010299

    ld_length = strlen( ld_path ) - 1.
    ASSIGN ld_path+ld_length(1) TO <lf_symbol>.
    IF <lf_symbol> EQ '/' OR <lf_symbol> EQ '\'.
      ld_path = ld_path(ld_length).
    ENDIF.
  ENDIF.

  IF fu_type EQ 'O'.
    ld_title = 'Open file'.
  ELSEIF fu_type EQ 'F'.
    ld_title = 'Select file'.
  ELSE.
    ld_title = 'Save as'.
  ENDIF.

* Build Filter for Fileselektor
  CALL FUNCTION 'WS_FILENAME_GET'
       EXPORTING
            def_filename     = ld_filename
            def_path         = ld_path
            mask             = ',*.*,*.*.'
            mode             = 'S'
            title            = ld_title
       IMPORTING
            filename         = ld_filename
       EXCEPTIONS
            inv_winsys       = 01
            no_batch         = 02
            selection_cancel = 03
            selection_error  = 04.
  d_udf_subrc = sy-subrc.
  CHECK d_udf_subrc = 0.
  fc_fname = ld_filename.
  CHECK d_udf_chkfl IS INITIAL.
  PERFORM f_udf_get_path_name USING fc_fname.
  CONCATENATE d_udf_drive ':' d_udf_drcty INTO fc_fname.
ENDFORM.

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
DEFINE macro_udf_upload.
  if &1 is initial.
    perform f_udf_get_filename using 'O' &1.
  endif.
  if &1 ne space.
*    perform f_execute(zabpxop_exec).
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
    d_udf_subrc = sy-subrc.
    describe table &3 lines d_udf_totalrecords.
    if d_udf_subrc ne 0 and d_udf_dspms ne space.
      case d_udf_subrc.
        when 1.
          message i000(zz)
             with 'Conversion Error in Input File'.
        when 2. message i000(zz) with 'Error when Opening Input File'.
        when 3. message i000(zz) with 'Read Error in Input File'.
        when others. message i000(zz) with 'Error in Input File'.
      endcase.
    endif.
  endif.
END-OF-DEFINITION.

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
DEFINE macro_udf_write_server.
  concatenate &2 &1 into d_udf_dsn_msg.
  open dataset d_udf_dsn_msg for output in binary mode.
  loop at &3.
    transfer &3 to d_udf_dsn_msg.
  endloop.
  close dataset d_udf_dsn_msg.
END-OF-DEFINITION.

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
DEFINE macro_udf_download.
  if &1 eq space.
    perform f_udf_get_filename using 'S' &1.
  endif.
  if &1 ne space.
*    perform f_execute(zabpxop_exec).
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
        when 1. message i000(zz) with 'File open error !'.
        when 2. message i000(zz) with 'File write error !'.
        when 3. message i000(zz) with 'Invalid file size !'.
        when 4. message i000(zz) with 'Invalid table width !'.
        when 5. message i000(zz) with 'Invalid type !'.
        when 6. message i000(zz) with 'No batch !'.
        when 7. message i000(zz) with 'Unknown error !'.
        when 8. message i000(zz) with 'Unknown error !'.
      endcase.
    endif.
  endif.
END-OF-DEFINITION.

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
DEFINE macro_udf_read_server.
  clear &3. refresh &3.
  do.
    read dataset d_udf_dsn_msg into &3.
    if sy-subrc <> 0.
      exit.
    endif.
    append &3.
    clear &3.
  enddo.

END-OF-DEFINITION.

*-----------------------------------------------------------------------
* @form        F_UDF_CHECK_FILE_UPLOAD
* @description check file for upload
*              Error condition: if file not found or
*                               if file have length 0
* @param       FU_FNAME
* @par-desc    filename to check
*-----------------------------------------------------------------------
FORM f_udf_check_file_upload USING fu_fname.
  TRANSLATE fu_fname TO UPPER CASE.
  CALL FUNCTION 'WS_QUERY'
       EXPORTING
            query    = 'FE'
            filename = fu_fname
       IMPORTING
            return   = d_udf_subrc.
  IF d_udf_subrc IS INITIAL.
    IF d_udf_dspms NE space.
      MESSAGE ID '57' TYPE 'E' NUMBER 173 WITH fu_fname.
    ENDIF.
    EXIT.
  ENDIF.

  CALL FUNCTION 'WS_QUERY'
       EXPORTING
            query    = 'FL'
            filename = fu_fname
       IMPORTING
            return   = d_udf_subrc.
  CHECK d_udf_subrc IS INITIAL AND d_udf_dspms NE space.
  MESSAGE ID '6P' TYPE 'E' NUMBER 603 WITH fu_fname.
ENDFORM.

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
FORM f_udf_check_file_download USING fu_fname fu_exist.
  DATA: ld_char(2),
        ld_length TYPE i,
        ld_position TYPE i,
        ld_count TYPE i,
        ld_directory LIKE rlgrap-filename.

  ld_directory = fu_fname.
  ld_count = strlen( fu_fname ).
  DO ld_count TIMES.
    ld_position = sy-index - 1.
    ld_char = ld_directory+ld_position(1).
    CASE ld_char(1).
      WHEN ':' OR '\'. ld_length = ld_position.
    ENDCASE.
  ENDDO.
  ld_directory = ld_directory(ld_length).

  CALL FUNCTION 'WS_QUERY'
       EXPORTING
            query    = 'DE'
            filename = ld_directory
       IMPORTING
            return   = d_udf_subrc.
  IF d_udf_subrc EQ 0.
    IF d_udf_dspms NE space.
      MESSAGE ID 'AT' TYPE 'E' NUMBER 300 WITH ld_directory.
    ENDIF.
    EXIT.
  ENDIF.

  CHECK NOT fu_exist IS INITIAL.
  TRANSLATE fu_fname TO UPPER CASE.
  CALL FUNCTION 'WS_QUERY'
       EXPORTING
            query    = 'FE'
            filename = fu_fname
       IMPORTING
            return   = d_udf_subrc.
  IF d_udf_subrc NE 0 AND d_udf_dspms NE space.
    MESSAGE ID '26' TYPE 'E' NUMBER 179 WITH fu_fname.
  ENDIF.
ENDFORM.

*-----------------------------------------------------------------------
* @form        f_udf_check_directory
* @description check existence directory
*              Error condition: if directory not found
* @param       FU_FNAME
* @par-desc    filename to check
*-----------------------------------------------------------------------
FORM f_udf_check_directory USING fu_fname.
  DATA: ld_char,
        ld_length TYPE i,
        ld_position TYPE i,
        ld_count TYPE i,
        ld_directory LIKE rlgrap-filename.

  ld_directory = fu_fname.
  IF ld_directory NE space.
    ld_count = strlen( fu_fname ).
    DO ld_count TIMES.
      ld_position = sy-index - 1.
      ld_char = ld_directory+ld_position(1).
      CASE ld_char.
        WHEN ':' OR '\'. ld_length = ld_position.
      ENDCASE.
    ENDDO.
    IF ld_length GT 0.
      ld_directory = ld_directory(ld_length).
    ENDIF.
  ENDIF.
  CALL FUNCTION 'WS_QUERY'
       EXPORTING
            query    = 'DE'
            filename = ld_directory
       IMPORTING
            return   = d_udf_subrc.
  IF d_udf_subrc EQ 0 AND d_udf_dspms NE space.
    MESSAGE e000(zz) WITH 'Directory' ld_directory 'does not exist !'.
  ENDIF.
  IF d_udf_chkfl = space.
    CONCATENATE ld_directory '\' INTO fu_fname.
  ENDIF.
ENDFORM.                               " F_UDF_CHECK_DIRECTORY

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
FORM f_udf_check_file_exist USING fu_fname fu_types.
  CHECK d_udf_chkfl = 'X'.
  TRANSLATE fu_fname TO UPPER CASE.
  CALL FUNCTION 'WS_QUERY'
       EXPORTING
            query    = 'FE'
            filename = fu_fname
       IMPORTING
            return   = d_udf_subrc.
  CHECK d_udf_dspms NE space.
* Display error message
  IF d_udf_subrc EQ 0 AND fu_types EQ 'U'.
    MESSAGE e000(zz) WITH 'File' fu_fname 'does not exist !'.
  ELSEIF d_udf_subrc NE 0 AND fu_types EQ 'D'.
    MESSAGE e000(zz) WITH 'File' fu_fname 'already exist !'.
  ENDIF.
ENDFORM.                               " F_UDF_CHECK_FILE_EXIST

*-----------------------------------------------------------------------
* @form        F_UDF_CHECK_FILE_LENGTH
* @description Check, if a file already open with another program
*              Error condition: if file already open by another program
* @param       FU_FNAME
* @par-desc    filename to check
*-----------------------------------------------------------------------
FORM f_udf_check_file_length USING fu_fname.
  CALL FUNCTION 'WS_QUERY'
       EXPORTING
            query    = 'FL'
            filename = fu_fname
       IMPORTING
            return   = d_udf_subrc.
  CHECK d_udf_subrc IS INITIAL AND d_udf_dspms NE space.
  MESSAGE e000(zz) WITH 'Error opening file' fu_fname.
ENDFORM.                               " F_UDF_CHECK_FILE_LENGTH

*-----------------------------------------------------------------------
* @form        F_UDF_GET_FIELD_VALUE
* @description Get field value, use in reporting for
*              AT SELECTION-SCREEN ON VALUE-REQUEST events.
* @param       FU_FNAME
* @par-desc    field name
* @param       FU_FVALUE
* @par-desc    field value
*-----------------------------------------------------------------------
FORM f_udf_get_field_value USING fu_fname CHANGING fc_fvalue.
  DATA: BEGIN OF lt_dynpfields OCCURS 0.
          INCLUDE STRUCTURE dynpread.
  DATA: END OF lt_dynpfields.
  CLEAR lt_dynpfields. REFRESH lt_dynpfields.
  lt_dynpfields-fieldname  = fu_fname.
  APPEND lt_dynpfields.
  CALL FUNCTION 'DYNP_VALUES_READ'
       EXPORTING
            dyname     = sy-cprog
            dynumb     = sy-dynnr
       TABLES
            dynpfields = lt_dynpfields
       EXCEPTIONS
            OTHERS.
  CLEAR fc_fvalue.
  READ TABLE lt_dynpfields INDEX 1.
  CHECK sy-subrc = 0.
  fc_fvalue = lt_dynpfields-fieldvalue.
ENDFORM.

DEFINE macro_udf_tab_delimited.
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
END-OF-DEFINITION.

*$*$--------------------------------------------------------------------
*$*$ Lib internal use Subroutines
*$*$--------------------------------------------------------------------
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
