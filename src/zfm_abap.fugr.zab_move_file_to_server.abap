FUNCTION zab_move_file_to_server.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(LOCAL_FILE) TYPE  LOCALFILE
*"     VALUE(SERVER_PATH) TYPE  LOCALFILE
*"  EXPORTING
*"     VALUE(SERVER_FILE) TYPE  LOCALFILE
*"----------------------------------------------------------------------

  DATA: BEGIN OF lt_itab OCCURS 0,
          field(256),
        END OF lt_itab.

  DATA: lv_file       TYPE string,
        lv_length     LIKE sy-tabix,
        lv_path       TYPE zfilecabang,
"start adj SOH 20240819
"replace
*        lv_docid      TYPE dsvasdocid,
*        lv_directory  TYPE dsvasdocid,
*        lv_filename   TYPE dsvasdocid,
*        lv_extension  TYPE dsvasdocid.
        lv_docid      TYPE text255,
        lv_directory  TYPE text255,
        lv_filename   TYPE text255,
        lv_extension  TYPE text255.
"end adj SOH 20240819

  "Upload PDF
  lv_file = local_file.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename   = lv_file
      filetype   = 'BIN'
    IMPORTING
      filelength = lv_length
    TABLES
      data_tab   = lt_itab.

  "Split filename
  lv_docid = local_file.
  CALL FUNCTION 'Z_DSVAS_DOC_FILENAME_SPLIT'
    EXPORTING
      pf_docid     = lv_docid
    IMPORTING
      pf_directory = lv_directory
      pf_filename  = lv_filename
      pf_extension = lv_extension.

  "Define Server Path
  CONCATENATE server_path lv_filename INTO lv_path.

  OPEN DATASET lv_path FOR OUTPUT IN BINARY MODE.

  "Write PDF to Server
  LOOP AT lt_itab.
    TRANSFER lt_itab-field TO lv_path.
  ENDLOOP.

  CLOSE DATASET lv_path.

  "Write path to table
  server_file = lv_path.

ENDFUNCTION.
