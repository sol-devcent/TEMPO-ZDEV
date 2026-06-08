************************************************************************
*                  INCLUDE ZVX_INTERFACE_INCL                          *
*----------------------------------------------------------------------*
* ABAP Name   :  ZVX_INTERFACE_INCL*
* Created by  :                                                        *
* Created on  :                                                        *
* Version     :                                                        *
* Called From :                                                        *
*----------------------------------------------------------------------*
* Description :                                                        *
*  Include program for bdc upload. Consists of routines below:         *
*  1. f_get_file_name                                                  *
*  2. f_move_file                                                      *
*  3. f_read_file                                                      *
*  4. f_record_error.                                                  *
*  5. f_split_file                                                     *
*  6. f_log_error                                                      *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
* Date    Programmer  Correction  Description
*
*----------------------------------------------------------------------*

***************************************************
*        internal tables and structures           *
***************************************************

* structure of error description
TYPES : BEGIN OF terror_desc,
          filename(125)  TYPE c,       "file name where error happens
          file_index     TYPE i,
          error_id(8)    TYPE c,
          error_txt(255) TYPE c,
          error_date     LIKE sy-datum,
        END OF terror_desc.
TYPES : tierror_desc TYPE terror_desc OCCURS 10.

* structure of error
TYPES : BEGIN OF tterror,
          filename(125) TYPE c,       "file name where error happens
          start_index   TYPE i,      "start of index in error description
          end_index     TYPE i,
*           all(1) type c,              "all lines in a file are error ?
        END OF tterror.
TYPES : ti_terror TYPE tterror OCCURS 10.

* internal table and working area definition
DATA : i_itaberror       TYPE ti_terror,
       wa_itaberror      TYPE tterror,
       i_itaberror_desc  TYPE tierror_desc,
       wa_itaberror_desc TYPE terror_desc.

* sample of internal table for the content of file
TYPES : BEGIN OF t_line,
          v_text(1500) TYPE c,
        END OF t_line.
TYPES : t_iline TYPE t_line OCCURS 10.

***************************************************
*                  variables                      *
***************************************************

DATA: BEGIN OF searchpoints OCCURS 10,
        dirname(75) TYPE c,            " name of directory.
        sp_name(75) TYPE c,            " name of entry. (may end with *)
        sp_cs(10)   TYPE c, " ContainsString pattern for name.
      END OF searchpoints.

DATA: BEGIN OF i_file_list OCCURS 100,
        dirname(75)      TYPE c, " name of directory. (possibly truncated.)
        name(75)         TYPE c, " name of entry. (possibly truncated.)
        type(10)         TYPE c,            " type of entry.
        len(8)           TYPE p,            " length in bytes.
        owner(8)         TYPE c,            " owner of the entry.
        mtime(6)         TYPE p, " last modification date, seconds since 1970
        mode(9)          TYPE c, " like "rwx-r-x--x": protection mode.
        useable(1)       TYPE c,
        subrc(4)         TYPE c,
        errno(3)         TYPE c,
        errmsg(40)       TYPE c,
        mod_date         TYPE d,
        mod_time(8)      TYPE c,            " hh:mm:ss
        seen(1)          TYPE c,
        changed(1)       TYPE c,
        num_record       TYPE i VALUE 0,  "number of customer record in file
        num_valid_record TYPE i VALUE 0, " number of valid record
      END OF i_file_list.

DATA: BEGIN OF file,
        dirname(75) TYPE c, " name of directory. (possibly truncated.)
        name(75)    TYPE c, " name of entry. (possibly truncated.)
        type(10)    TYPE c,            " type of entry.
        len(8)      TYPE p,            " length in bytes.
        owner(8)    TYPE c,            " owner of the entry.
        mtime(6)    TYPE p, " last modification date, seconds since 1970
        mode(9)     TYPE c, " like "rwx-r-x--x": protection mode.
        useable(1)  TYPE c,
        subrc(4)    TYPE c,
        errno(3)    TYPE c,
        errmsg(40)  TYPE c,
        mod_date    TYPE d,
        mod_time(8) TYPE c,            " hh:mm:ss
        seen(1)     TYPE c,
        changed(1)  TYPE c,
      END OF file.

DATA: BEGIN OF file_key,
        dirname(75) TYPE c, " name of directory. (possibly truncated.)
        name(75)    TYPE c, " name of entry. (possibly truncated.)
      END OF file_key.

* data for getting file operation
DATA: sap_yes(1)  VALUE 'X'
    , sap_no(1)   VALUE ' '
    , srt(1)      VALUE 'T'
    , no_cs       VALUE ' '            " no MUST_ContainString
    , all_gen     VALUE '*'    " generic filename shall select all
    , strlen      LIKE sy-fdpos
    .

DATA: h_list_index   TYPE p  " hided with each data line; otherwise 0
    , fcode(4)       TYPE c
    .

DATA : itabline    TYPE t_iline,
       wa_itabline TYPE t_line.



*---------------------------------------------------------------------*
*       FORM f_move_file                                              *
*---------------------------------------------------------------------*
* Routine for moving one file from one directory to another directory
*---------------------------------------------------------------------*
* INPUT :
*  - pfilename : name of file to move
*  - pdirfrom : source directory
*  - pdirto : destination directory
*  PROCESS :
*  - read file from source directory
*  - write file to destination directory
*  - delete file in source directory
*---------------------------------------------------------------------*

FORM f_move_file USING pfilename TYPE c pfiledest TYPE c pdirfrom TYPE c
 pdirto TYPE c.
  DATA : l_filesrc(125)         TYPE c,
         l_filedestination(125) TYPE c,
         l_text(1500).

  CONCATENATE pdirfrom '/' pfilename INTO l_filesrc.
  CONCATENATE pdirto '/' pfiledest INTO l_filedestination.

  OPEN DATASET l_filesrc FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  OPEN DATASET l_filedestination FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
  DO.
    READ DATASET l_filesrc INTO l_text.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    TRANSFER l_text TO l_filedestination.
  ENDDO.
  CLOSE DATASET l_filedestination.
  CLOSE DATASET l_filesrc.

  DELETE DATASET l_filesrc.

ENDFORM.                    "f_move_file

*---------------------------------------------------------------------*
*       FORM f_get_file_name                                          *
*---------------------------------------------------------------------*
* Routine for getting contents of one directory with particular pattern
*---------------------------------------------------------------------*
* INPUT :
*   -p_dir_name : directory name
*   -p_generic_name : generic filename (e.g : *)
*   -p_must_cs : pattern for legal filenames. Valid value : NO_CS (no *
*pattern ) , %, etc.
* OUTPUT :
*    - list of file with the specified pattern, kept in FILE_LIST table.
*---------------------------------------------------------------------*

FORM f_get_file_name USING p_dir_name TYPE c
                           p_generic_name TYPE c
                           p_must_cs TYPE c.
  DATA: l_errcnt(2)   TYPE p VALUE 0,
        l_must_cs(20) TYPE c.

  IF p_dir_name IS INITIAL.
*     MESSAGE E220.     " 'Place cursor on valid line !'.
  ENDIF.

  CALL 'C_DIR_READ_FINISH'             " just to be sure
      ID 'ERRNO'  FIELD i_file_list-errno
      ID 'ERRMSG' FIELD i_file_list-errmsg.

  CALL 'C_DIR_READ_START' ID 'DIR'    FIELD p_dir_name
                          ID 'FILE'   FIELD p_generic_name
                          ID 'ERRNO'  FIELD file-errno
                          ID 'ERRMSG' FIELD file-errmsg.
  IF sy-subrc <> 0.
*    MESSAGE E204 WITH FILE_LIST-ERRMSG FILE-ERRMSG.
  ENDIF.

  DO.
    CLEAR file.
    CALL 'C_DIR_READ_NEXT'
      ID 'TYPE'   FIELD file-type
      ID 'NAME'   FIELD file-name
      ID 'LEN'    FIELD file-len
      ID 'OWNER'  FIELD file-owner
      ID 'MTIME'  FIELD file-mtime
      ID 'MODE'   FIELD file-mode
      ID 'ERRNO'  FIELD file-errno
      ID 'ERRMSG' FIELD file-errmsg.
    file-dirname = p_dir_name.
    MOVE sy-subrc TO file-subrc.
    CASE sy-subrc.
      WHEN 0.
        CLEAR: file-errno, file-errmsg.
        CASE file-type(1).
          WHEN 'F'.                    " normal file.
            PERFORM filename_useable USING file-name file-useable.
          WHEN 'f'.                    " normal file.
            PERFORM filename_useable USING file-name file-useable.
          WHEN OTHERS. " directory, device, fifo, socket,...
            MOVE sap_no  TO file-useable.
        ENDCASE.
        IF file-len = 0.
          MOVE sap_no TO file-useable.
        ENDIF.
      WHEN 1.
        EXIT.
      WHEN OTHERS.                     " SY-SUBRC >= 2
        ADD 1 TO l_errcnt.
        IF l_errcnt > 10.
          EXIT.
        ENDIF.
        IF sy-subrc = 5.
          MOVE: '???' TO file-type,
                '???' TO file-owner,
                '???' TO file-mode.
        ELSE.
*         ULINE.
*         WRITE: / 'C_DIR_READ_NEXT', 'SUBRC', SY-SUBRC.
        ENDIF.
        MOVE sap_no TO file-useable.
    ENDCASE.
    PERFORM p6_to_date_time_tz(rstr0400) USING file-mtime
                                               file-mod_time
                                               file-mod_date.
*   * Does the filename contains the requested pattern?
*   * Then store it, else forget it.
    IF p_must_cs = no_cs.
      MOVE-CORRESPONDING file TO i_file_list.
      APPEND i_file_list.
    ELSE.
      CONCATENATE p_must_cs '*' INTO l_must_cs.
      IF file-name CP l_must_cs.
        MOVE-CORRESPONDING file TO i_file_list.
        APPEND i_file_list.
      ENDIF.
    ENDIF.
  ENDDO.

  CALL 'C_DIR_READ_FINISH'
      ID 'ERRNO'  FIELD i_file_list-errno
      ID 'ERRMSG' FIELD i_file_list-errmsg.
  IF sy-subrc <> 0.
    WRITE: / 'C_DIR_READ_FINISH', 'SUBRC', sy-subrc.
  ENDIF.
  IF srt = 'T'.
    SORT i_file_list BY mtime DESCENDING name ASCENDING.
  ELSE.
    SORT i_file_list BY name ASCENDING mtime DESCENDING.
  ENDIF.

ENDFORM.                    "f_get_file_name


*---------------------------------------------------------------------*
*       FORM f_split_file                                             *
*---------------------------------------------------------------------*
* Routine for splitting files in file list. Files which contain no    *
* errors are moved to archive directory. Files which all lines are error
* are moved to error directory. Whereas, files which contain error are
* splitted into two different directories
*---------------------------------------------------------------------*
* INPUT :
*  - pdir_src : source directory
*  - pdir_failed : failed directory, where error files are kept
*  - pdir_ok : success directory, where successful files are kept
* PROCESS :
*  - if file contains no error, move directly to pdir_ok
*  - if all lines in file are error, move directly to pdir_failed
*  - otherwise, read each line of file. If there is no error in the
*    line, write it to file in pdir_ok. Otherwise, write it to file
*    in pdir_failed.
*  - delete file in source directory
*---------------------------------------------------------------------*

FORM f_split_file USING p_filename TYPE c pdir_src TYPE c pdir_failed
TYPE c pdir_ok TYPE
c.

  DATA : l_errorfilename(125) TYPE c,
         l_okfilename(125)    TYPE c,
         l_filename(125)      TYPE c,
         l_filename_dest(125) TYPE c,
         l_filename_src(125)  TYPE c,
         l_text(1500)         TYPE c,
         l_iserror            TYPE c VALUE 'F',
         l_index              TYPE i,
         l_extension(5)       TYPE c,
         l_error_record       TYPE i.

  CLEAR wa_itaberror.
  READ TABLE i_itaberror INTO wa_itaberror WITH KEY filename =
p_filename.
  IF sy-subrc NE 0.                    "not exist
    SPLIT p_filename AT '.' INTO l_filename l_extension.
    CONCATENATE l_filename '_OK' '.' l_extension INTO l_filename_dest.
    PERFORM f_move_file
           USING
              p_filename
              l_filename_dest
              pdir_src
              pdir_ok.

*{   REPLACE        P01K910854                                        1
*\    IF sy-opsys EQ 'AIX'.
    IF sy-opsys EQ 'AIX' OR sy-opsys EQ 'Linux' OR sy-opsys EQ 'LINUX'.     "original: only for AIX Start "SOH: Shell Remediation Adjustment 20240522 KRS.
*}   REPLACE
      CONCATENATE pdir_ok '/' l_filename_dest INTO l_filename_dest.
    ELSE.
      CONCATENATE pdir_ok '\' l_filename_dest INTO l_filename_dest.
    ENDIF.
    PERFORM f_changefilemode USING l_filename_dest.

  ELSE.                                "exist, split!
    l_error_record = i_file_list-num_record -
        i_file_list-num_valid_record .
    IF i_file_list-num_record =  l_error_record.
*    if wa_itaberror-all eq 'T' .       "all records are false
      SPLIT p_filename AT '.' INTO l_filename l_extension.
      CONCATENATE l_filename '_ER' '.' l_extension INTO
l_filename_dest.
      PERFORM f_move_file
           USING
              p_filename
              l_filename_dest
              pdir_src
              pdir_failed.
      wa_itaberror-filename = l_filename_dest.
      MODIFY i_itaberror FROM wa_itaberror TRANSPORTING filename WHERE
       filename = p_filename.
*{   REPLACE        P01K910854                                        1
*\    IF sy-opsys EQ 'AIX'.
      IF sy-opsys EQ 'AIX' OR sy-opsys EQ 'Linux' OR sy-opsys EQ 'LINUX'.     "original: only for AIX Start "SOH: Shell Remediation Adjustment 20240522 KRS.
*}   REPLACE
        CONCATENATE pdir_failed '/' l_filename_dest INTO l_filename_dest.
      ELSE.
        CONCATENATE pdir_failed '\' l_filename_dest INTO l_filename_dest.
      ENDIF.
      PERFORM f_changefilemode USING l_filename_dest.
    ELSE.

      SPLIT p_filename AT '.' INTO l_filename l_extension.
*{   REPLACE        P01K910854                                        1
*\    IF sy-opsys EQ 'AIX'.
      IF sy-opsys EQ 'AIX' OR sy-opsys EQ 'Linux' OR sy-opsys EQ 'LINUX'.     "original: only for AIX Start "SOH: Shell Remediation Adjustment 20240522 KRS.
*}   REPLACE
        CONCATENATE pdir_failed '/' l_filename '_ER' '.'
              l_extension INTO l_errorfilename.
        CONCATENATE pdir_ok '/' l_filename '_OK' '.'
              l_extension INTO l_okfilename.
        CONCATENATE pdir_src '/'
             wa_itaberror-filename INTO l_filename_src.
      ELSE.
        CONCATENATE pdir_failed '\' l_filename '_ER' '.'
              l_extension INTO l_errorfilename.
        CONCATENATE pdir_ok '\' l_filename '_OK' '.'
              l_extension INTO l_okfilename.
        CONCATENATE pdir_src '\'
             wa_itaberror-filename INTO l_filename_src.
      ENDIF.
      OPEN DATASET l_filename_src FOR INPUT IN TEXT MODE ENCODING DEFAULT.
      OPEN DATASET l_errorfilename FOR APPENDING IN TEXT MODE ENCODING DEFAULT.

      OPEN DATASET l_okfilename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

      l_index = 1.

      DO.
        READ DATASET l_filename_src INTO l_text.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

        PERFORM f_check_index
                   USING
                      l_index
                   CHANGING
                      l_iserror.

        IF l_text NE ''.
          IF l_iserror = 'T'.
            TRANSFER l_text TO l_errorfilename.
          ELSE.
            TRANSFER l_text TO l_okfilename.
          ENDIF.
        ENDIF.
        l_index = l_index + 1.
      ENDDO.
      CLOSE DATASET l_okfilename.
      CLOSE DATASET l_errorfilename.
      CLOSE DATASET l_filename_src.
      DELETE DATASET l_filename_src.

*     chmod 777
      PERFORM f_changefilemode USING l_okfilename.
      PERFORM f_changefilemode USING l_errorfilename.

      CONCATENATE l_filename '_ER' '.' l_extension INTO
        wa_itaberror-filename.

      MODIFY i_itaberror FROM wa_itaberror TRANSPORTING filename WHERE
       filename = p_filename.

    ENDIF.

  ENDIF.

ENDFORM.                    "f_split_file


*---------------------------------------------------------------------*
*       FORM f_check_index                                            *
*---------------------------------------------------------------------*
* INPUT :
*  - p_index : index of file to be checked
* OUTPUT :
*  - p_iserror : index exists in error table or not
*---------------------------------------------------------------------*
FORM f_check_index USING p_index TYPE i
                    CHANGING p_iserror TYPE c.

  p_iserror = 'F'.
  CLEAR wa_itaberror_desc.
  LOOP AT i_itaberror_desc FROM wa_itaberror-start_index TO
  wa_itaberror-end_index INTO wa_itaberror_desc.
    IF p_index = wa_itaberror_desc-file_index.
      p_iserror = 'T'.
    ENDIF.
    CLEAR wa_itaberror_desc.
  ENDLOOP.

ENDFORM.                    "f_check_index

*---------------------------------------------------------------------*
*       FORM f_record_error                                           *
*---------------------------------------------------------------------*
* Routine for recording error
*---------------------------------------------------------------------*
* INPUT :
*    - p_filename : itaberror-filename
*    - p_fileidx : itaberror_desc-file_index
*    - p_err_id : itaberror_desc-error_id
*    - p_err_txt : itaberror_desc-error_text
* OUTPUT :
*    - record is kept in itaberror and itaberror_desc
*---------------------------------------------------------------------*

FORM f_record_error USING p_filename TYPE c p_file_idx TYPE i p_err_id
TYPE c p_err_txt TYPE c.

  DATA : l_current_line LIKE sy-tabix.

  CLEAR wa_itaberror.
  READ TABLE i_itaberror INTO wa_itaberror WITH KEY filename =
  p_filename.

*  if not found, create new record in itaberror
  IF sy-subrc <> 0.
    wa_itaberror-filename =  p_filename.
    wa_itaberror-start_index = -1.
    APPEND wa_itaberror TO i_itaberror.
  ENDIF.

  wa_itaberror_desc-filename =  p_filename.
  wa_itaberror_desc-file_index = p_file_idx.
  wa_itaberror_desc-error_id = p_err_id.
  wa_itaberror_desc-error_txt = p_err_txt.
  wa_itaberror_desc-error_date = sy-datum.
  APPEND wa_itaberror_desc TO i_itaberror_desc.
  l_current_line = sy-tabix.
  IF wa_itaberror-start_index = -1.
    wa_itaberror-start_index = l_current_line.
  ENDIF.
  wa_itaberror-end_index  = l_current_line.
  MODIFY i_itaberror FROM wa_itaberror TRANSPORTING start_index
end_index
WHERE filename = p_filename.
ENDFORM.                    "f_record_error

*---------------------------------------------------------------------*
*       FORM f_log_error                                              *
*---------------------------------------------------------------------*
* Routine for logging errors
*---------------------------------------------------------------------*
* PROCESS :
*  - if itaberror is not initial, get the date when the file is created.
*  - append error listed in itaberror to log file specified for that
*    date.
*---------------------------------------------------------------------*

FORM f_log USING p_err_msg TYPE c
                 p_log_file TYPE c.
  DATA : l_file_out(125)        TYPE c,
         l_file_pre(80)         TYPE c,
         l_date(8)              TYPE c,
         l_error_date(10)       TYPE c,
         l_rest(80)             TYPE c,
         l_err_id(10)           TYPE c,
         l_file_index(6)        TYPE c VALUE '',
         l_text(400)            TYPE c,
         l_curdate(10)          TYPE c,
         l_curtime(8)           TYPE c,
         ls_rec_idx(5)          TYPE c,
         l_rec_idx              TYPE i,
         l_star(100)            TYPE c,
         l_dash(100)            TYPE c,
         l_header1(255)         TYPE c,
         l_sum_header(255)      TYPE c,
         l_det_header(255)      TYPE c,
         l_num_record(5)        TYPE c,
         l_num_valid_record(5)  TYPE c,
         l_num_failed_record(5) TYPE c,
         off                    TYPE i,
         len                    TYPE i.


  WRITE sy-datum TO l_curdate MM/DD/YYYY.
  WRITE sy-uzeit TO l_curtime USING EDIT MASK '__:__:__'.

  l_star = '*******************************************************'.
  l_dash = '-----------------------------------------------------------'
.

  off = 1.  len = 10.
  WRITE 'Date : ' TO l_header1+off(len).
  len = strlen( l_curdate ).  off = off + len + 2.
  WRITE l_curdate TO l_header1+off(len).
  off = off + len + 2. len = 10.
  WRITE 'Time : ' TO l_header1+off(len).
  off = off + len + 2. len = strlen( l_curtime ).
  WRITE l_curtime TO l_header1+off(len).

  off = 1. len = 30.
  WRITE 'File Name ' TO l_sum_header+off(len).
  off = off + len + 2. len = 8.
  WRITE 'Record ' TO l_sum_header+off(len).
  off = off + len + 2. len = 8.
  WRITE 'OK ' TO l_sum_header+off(len).
  off = off + len + 2. len = 8.
  WRITE 'Failed ' TO l_sum_header+off(len).

  off = 1. len = 6.
  WRITE 'No ' TO l_det_header+off(len).
  off = off + len + 2. len = 7.
  WRITE 'Index ' TO l_det_header+off(len).
  off = off + len + 2. len = 10.
  WRITE 'Error ID ' TO l_det_header+off(len).
  off = off + len + 2. len = 200.
  WRITE 'Error Description' TO l_det_header+off(len).
  off = off + len + 2. len = 11.
  WRITE 'Error Date' TO l_det_header+off(len).

  CONCATENATE p_log_file '_' sy-datum '.log' INTO l_file_out.
  OPEN DATASET l_file_out FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
  TRANSFER l_star TO l_file_out.
  TRANSFER l_header1 TO l_file_out.
  TRANSFER l_star TO l_file_out.
  TRANSFER '' TO l_file_out.
  TRANSFER l_dash TO l_file_out.
  TRANSFER l_sum_header TO l_file_out.
  TRANSFER l_dash TO l_file_out.

  LOOP AT i_file_list.
    l_num_record = i_file_list-num_record.
    l_num_valid_record = i_file_list-num_valid_record.
    l_num_failed_record = i_file_list-num_record -
      i_file_list-num_valid_record.
    off = 1. len = 30.
    WRITE i_file_list-name TO l_text+off(len).
    off = off + len + 2. len = 8.
    WRITE l_num_record TO l_text+off(len).
    off = off + len + 2. len = 8.
    WRITE l_num_valid_record TO l_text+off(len).
    off = off + len + 2. len = 8.
    WRITE l_num_failed_record TO l_text+off(len).

    TRANSFER l_text TO l_file_out.
  ENDLOOP.

  IF i_itaberror IS INITIAL.
    IF NOT p_err_msg IS INITIAL.
      TRANSFER l_dash TO l_file_out.
      TRANSFER l_header1 TO l_file_out.
      TRANSFER l_dash TO l_file_out.
      TRANSFER p_err_msg TO l_file_out.
    ENDIF.
  ENDIF.

  SORT i_itaberror BY filename ASCENDING.

  TRANSFER '' TO l_file_out.
  TRANSFER 'Detail ' TO l_file_out.
  LOOP AT i_itaberror INTO wa_itaberror.
*    split filename
    SPLIT wa_itaberror-filename AT '_' INTO l_file_pre l_date l_rest.

    TRANSFER wa_itaberror-filename TO l_file_out.
    TRANSFER l_dash TO l_file_out.
    TRANSFER l_det_header TO l_file_out.
    TRANSFER l_dash TO l_file_out.
    l_rec_idx = 1.
    CLEAR wa_itaberror_desc.
    LOOP AT i_itaberror_desc INTO wa_itaberror_desc FROM
      wa_itaberror-start_index TO wa_itaberror-end_index.
      l_text = ''.
      l_err_id = wa_itaberror_desc-error_id.
      l_file_index = wa_itaberror_desc-file_index.
      WRITE wa_itaberror_desc-error_date TO l_error_date DD/MM/YY.
      off = 1. len = 6.
      ls_rec_idx = l_rec_idx.
      WRITE ls_rec_idx TO l_text+off(len).
      off = off + len + 2. len = 7.
      WRITE l_file_index TO l_text+off(len).
      off = off + len + 2. len = 10.
      WRITE l_err_id TO l_text+off(len).
      off = off + len + 2. len = 200.
      WRITE wa_itaberror_desc-error_txt TO l_text+off(len).
      off = off + len + 2. len = 11.
      WRITE l_error_date TO l_text+off(len).

      TRANSFER l_text TO l_file_out.
      l_rec_idx = l_rec_idx + 1.
      CLEAR wa_itaberror_desc.
    ENDLOOP.
  ENDLOOP.
  CLOSE DATASET l_file_out.

  PERFORM f_changefilemode USING l_file_out.

ENDFORM.                    "f_log


*---------------------------------------------------------------------*
*       FORM f_read_file                                              *
*---------------------------------------------------------------------*
* Routine for reading file and transfered to internal table           *
*---------------------------------------------------------------------*
* INPUT :
*  - p_filedir : file directory
*  - p_filename : file name
* OUTPUT :
*  - lines are kept in itabline
*---------------------------------------------------------------------*


FORM f_read_file USING p_filedir TYPE c p_filename TYPE c.
  DATA : l_filename(125) TYPE c.

  CLEAR itabline. REFRESH itabline.
  CONCATENATE p_filedir '/' p_filename INTO l_filename.
  OPEN DATASET l_filename FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  DO.
    READ DATASET l_filename INTO wa_itabline.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    APPEND wa_itabline TO itabline.
  ENDDO.
  CLOSE DATASET l_filename.
ENDFORM.                    "f_read_file

*---------------------------------------------------------------------*
*       FORM filename_usable                                          *
*---------------------------------------------------------------------*
* Utility Routines, needed for f_get_file_name
***********************************************************************

FORM filename_useable USING p_name TYPE c p_useable TYPE c.
*----================------------------------
  DATA l_name(75).

  l_name = p_name.
  IF l_name(4) = 'core'.
    p_useable = sap_no.
  ELSE.
    p_useable = sap_yes.
  ENDIF.
ENDFORM.                    "filename_useable

*---------------------------------------------------------------------*
*       FORM f_changefilemode                                         *
*---------------------------------------------------------------------*
* Function to change file mode to 777
***********************************************************************


FORM f_changefilemode USING p_file TYPE c.
  DATA : BEGIN OF tabl OCCURS 10,
           line(200),
         END OF tabl,
         l_command(125) TYPE c.

*   change file mod to 777
  CONCATENATE 'chmod 777' p_file INTO l_command SEPARATED BY ' '.
  CALL 'SYSTEM' ID 'COMMAND' FIELD l_command
                ID 'TAB' FIELD tabl-*sys*.


ENDFORM.                    "f_changefilemode
