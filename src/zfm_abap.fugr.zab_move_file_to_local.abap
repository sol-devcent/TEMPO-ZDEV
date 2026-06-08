FUNCTION ZAB_MOVE_FILE_TO_LOCAL.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_FILE_FRONT_END)
*"     VALUE(I_FILE_APPL) LIKE  RCGFILETR-FTAPPL
*"     VALUE(I_FILE_OVERWRITE) TYPE  ESP1_BOOLEAN DEFAULT ESP1_FALSE
*"  EXPORTING
*"     VALUE(E_FLG_OPEN_ERROR) TYPE  ESP1_BOOLEAN
*"     VALUE(E_OS_MESSAGE) TYPE  C
*"  EXCEPTIONS
*"      FE_FILE_OPEN_ERROR
*"      FE_FILE_EXISTS
*"      FE_FILE_WRITE_ERROR
*"      AP_NO_AUTHORITY
*"      AP_FILE_OPEN_ERROR
*"      AP_FILE_EMPTY
*"----------------------------------------------------------------------

* Local data ----------------------------------------------------------

  DATA: l_filelength    TYPE i.
  DATA: l_orln          LIKE drao-orln.
  DATA: l_data_tab      LIKE rcgrepfile OCCURS 10 WITH HEADER LINE.
  DATA: l_filename      TYPE string.
  DATA: l_auth_filename LIKE authb-filename.
  DATA: l_return        TYPE c.
  DATA: l_lines         TYPE i.

* Function body -------------------------------------------------------

* init
  e_flg_open_error = false.
  CLEAR e_os_message.

  l_filename   = i_file_front_end.

* check the authority to read the file from the application server
  l_auth_filename = i_file_appl.
  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
       EXPORTING
*           PROGRAM          =
            activity         = sabc_act_read
            filename         = l_auth_filename
       EXCEPTIONS
            no_authority     = 1
            activity_unknown = 2
            OTHERS           = 3.
  IF NOT sy-subrc IS INITIAL.
    CASE sy-subrc.
      WHEN 1.
*       no auhtority
        RAISE ap_no_authority.
      WHEN OTHERS.
        RAISE ap_file_open_error.
    ENDCASE.
  ENDIF.


* check if the file on the front-end exists
  CALL METHOD cl_gui_frontend_services=>file_exist
    EXPORTING
      file                 = l_filename
    RECEIVING
      result               = l_return
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      wrong_parameter      = 3
      not_supported_by_gui = 4
      OTHERS               = 5.

* if file exists continue only if parameter is specified
  IF sy-subrc = 0 AND l_return = 'X'.
    IF i_file_overwrite = false.
      RAISE fe_file_exists.
    ENDIF.
  ELSEIF sy-subrc <> 0.
    RAISE fe_file_open_error.
  ENDIF.                          " not sy-subrc is initial.

* open the file on the application server
  OPEN DATASET i_file_appl FOR INPUT MESSAGE e_os_message
               IN BINARY MODE.
  IF NOT sy-subrc IS INITIAL.
    e_flg_open_error = true.
    EXIT.
  ENDIF.                            " not sy-subrc is initial
  CLOSE DATASET i_file_appl.

* read data from application server
  CALL FUNCTION 'C13Z_RAWDATA_READ'
    EXPORTING
      i_file           = i_file_appl
    IMPORTING
      e_file_size      = l_orln
      e_lines          = l_lines
    TABLES
      e_rcgrepfile_tab = l_data_tab
    EXCEPTIONS
      no_permission    = 1
      open_failed      = 2
      read_error       = 3
      OTHERS           = 4.
  IF NOT sy-subrc IS INITIAL.
    CASE sy-subrc.
      WHEN 1.
*       no auhtority
        RAISE ap_no_authority.
      WHEN OTHERS.
        RAISE ap_file_open_error.
    ENDCASE.
  ENDIF.


*  check if data table is empty
  READ TABLE l_data_tab INDEX 1.
  IF sy-subrc IS INITIAL.
    l_filelength = l_orln.
    CALL FUNCTION 'C13Z_DOWNLOAD'
        EXPORTING
               bin_filesize        = l_filelength
*               CODEPAGE            = ' '
               filename            = l_filename
               filetype            = lc_fileformat_binary
*               mode                = ' '
*               WK1_N_FORMAT        = ' '
*               WK1_N_SIZE          = ' '
*               WK1_T_FORMAT        = ' '
*               WK1_T_SIZE          = ' '
*               COL_SELECT          = ' '
*               COL_SELECTMASK      = ' '
          IMPORTING
               filelength          = l_filelength
          TABLES
               data_tab            = l_data_tab
*               FIELDNAMES          =
          EXCEPTIONS
               file_open_error     = 1
               file_write_error    = 2
               invalid_filesize    = 3
               invalid_table_width = 4
               invalid_type        = 5
               no_batch            = 6
               unknown_error       = 7
               OTHERS              = 8.
    IF NOT sy-subrc IS INITIAL.
      CASE sy-subrc.
        WHEN 2 .
          RAISE fe_file_open_error.
        WHEN OTHERS.
          RAISE fe_file_write_error.
      ENDCASE.
    ENDIF.                          " not sy-subrc is initial

  ELSE.

*   file on application server has no contents
    RAISE ap_file_empty.

  ENDIF.                            " sy-subrc is initial

ENDFUNCTION.
