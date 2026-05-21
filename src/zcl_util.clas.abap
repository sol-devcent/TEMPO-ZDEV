class ZCL_UTIL definition
  public
  final
  create public .

*"* public components of class ZCL_UTIL
*"* do not include other source files here!!!
public section.

  class-methods M_GET_TVARV
    importing
      !PARAM_NAME type RVARI_VNAM
      !PARAM_TYPE type RSSCR_KIND optional
    exporting
      !T_RETURN type ZDG2CATT0001
      !MESSAGE type STRING .
  class-methods M_SEND_EMAIL
    importing
      !SUBJECT type SO_OBJ_DES
      !MESSAGE_BODY type BCSY_TEXT
      !ATTACHMENTS type RMPS_T_POST_CONTENT optional
      !SENDER_UID type SYUNAME optional
      !RECIPIENT_UID type SYUNAME optional
      !SENDER_MAIL type ADR6-SMTP_ADDR optional
      !RECIPIENT_MAIL type ADR6-SMTP_ADDR optional
      !RECIPIENTS type ZTUIYS_IUSR optional
    exporting
      !RESULT type BOOLEAN .
  class-methods M_OPEN_DATASET
    importing
      !PARAM_NAME type RLGRAP-FILENAME
    exporting
      !T_RETURN type ZDG2CATT0002 .
  class-methods M_CONCAT_TEXT
    importing
      !I_TEXT type STRING
    changing
      !C_TEXT type STRING .
  class-methods M_READ_EXCEL
    importing
      !PI_FILENAME type STRING
      !PI_IS_HEADER type CHAR1 optional
    exporting
      !PTO_DATA type STANDARD TABLE .
  class-methods M_READ_TXT
    importing
      !PI_IS_HEADER type CHAR1 optional
      !PI_FILENAME type STRING
    exporting
      !PTO_DATA type STANDARD TABLE .
  class-methods M_CONCATE_TEXT_JDE
    importing
      !PTI_DATA type STANDARD TABLE
    exporting
      !PTO_DATA type TRUXS_T_TEXT_DATA .
  class-methods M_DOWNLOAD_DATASET
    importing
      !PARAM_NAME type RLGRAP-FILENAME
      !PTI_DATA type TRUXS_T_TEXT_DATA .
  class-methods M_DELETE_FILE
    importing
      !PARAM_NAME type RLGRAP-FILENAME
    exporting
      !SUBRC type SY-SUBRC
      !MESSAGE type BAPI_MSG .
  class-methods M_GET_LINK
    importing
      !I_TYPE type ZDG2CADE0055
      !I_FOLDER type CHAR6
    exporting
      !E_PATH type LOCALFILE .
  class-methods M_UPLOAD_EXCEL_TO_ITAB
    importing
      !PVI_TABLE type CHAR30
      !PV_FILENM type RLGRAP-FILENAME
      !PVI_BCOL type INT4
      !PVI_ECOL type INT4
      !PVI_BROW type INT4
      !PVI_EROW type INT4
    exporting
      !PTO_DATA type STANDARD TABLE .
  class-methods M_UPLOAD_CSV_TO_ITAB
    importing
      !PVI_TABLE type CHAR30
      !PV_FILENM type RLGRAP-FILENAME
      !PVI_SEPARATOR type CHAR1
      !PVI_BROW type INT4 optional
    exporting
      !PTO_DATA type STANDARD TABLE .
  class-methods M_DOWNLOAD_DATASET_LINEFEED
    importing
      !PARAM_NAME type RLGRAP-FILENAME
      !PTI_DATA type TRUXS_T_TEXT_DATA .
  class-methods M_CONCATE_TEXT_SEPARATOR
    importing
      value(PTI_DATA) type STANDARD TABLE
      value(PVI_SEPARATOR) type CHAR1
    exporting
      !PTO_DATA type TRUXS_T_TEXT_DATA .
  class-methods M_CONCATE_TEXT_SEPARATOR2
    importing
      !PTI_DATA type STANDARD TABLE
      !PTI_STRUCTURE type STANDARD TABLE
      !PVI_SEPARATOR type CHAR1
    exporting
      !PTO_DATA type TRUXS_T_TEXT_DATA .
  class-methods M_REPLACE_EOL_FLAG
    importing
      !PVI_CHAR type ZCHAR1500
    exporting
      !PVO_CHAR type ZCHAR1500 .
  class-methods M_REPLACE_CHAR_TO_SPACE
    importing
      !PVI_TEXT type ZCHAR1500
      !PVI_CHAR type CHAR1
    exporting
      !PVO_TEXT type ZCHAR1500 .
  class-methods M_ASCII_TO_CHAR
    importing
      !PVI_ASCII type INT1
    exporting
      !PVO_CHAR type CHAR1 .
  class-methods M_DEBUG
    exporting
      !PVO_SUBRC type SYSUBRC .
  class-methods M_ACC_SPLIT_SN
    importing
      !PVI_SENUM type CHAR100
      !PVI_BPOM type XFELD optional
    exporting
      !PVO_SENUM type ZACCDTM-SENUM
      !PVO_MATNR type MARA-MATNR
      !PVO_CHARG type MCHA-CHARG .
  class-methods M_ACC_CREATE_SN
    importing
      !PVI_COUNT type INT4
      !PVI_SPLIT type INT4
    exporting
      !PTO_DATA type ZACCTTM .
  class-methods M_UPLOAD_EXCEL_TO_ITAB_NEW
    importing
      !PVI_TABLE type CHAR30
      !PV_FILENM type RLGRAP-FILENAME
      !PVI_BCOL type INT4
      !PVI_ECOL type INT4
      !PVI_BROW type INT4
      !PVI_EROW type INT4
    exporting
      !PTO_DATA type STANDARD TABLE .
  class-methods M_UPLOAD_EXCEL_TO_ITAB_V2
    importing
      !PVI_TABLE type CHAR30
      !PV_FILENM type RLGRAP-FILENAME
      !PVI_BCOL type INT4
      !PVI_ECOL type INT4
      !PVI_BROW type INT4
      !PVI_EROW type INT4
    exporting
      !PTO_DATA type STANDARD TABLE .
  class-methods M_UPLOAD_EXCEL_TO_ITAB_V3
    importing
      !PVI_TABLE type CHAR30
      !PV_FILENM type RLGRAP-FILENAME
      !PVI_BCOL type INT4
      !PVI_ECOL type INT4
      !PVI_BROW type INT4
      !PVI_EROW type INT4
    exporting
      !PTO_DATA type STANDARD TABLE
      !PVO_MESSAGE type CHAR100
    exceptions
      CONVT_NO_NUMBER .
protected section.
*"* protected components of class ZCL_UTIL
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_UTIL
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_UTIL IMPLEMENTATION.


METHOD m_acc_create_sn.
  DATA : ls_data        LIKE LINE OF pto_data,
         lv_time_utc    TYPE i,
         lv_min         TYPE bbseg-wrbtr VALUE 1000000000,
         lv_max         TYPE bbseg-wrbtr VALUE 9999999999,
         lv_curr        TYPE tcurx-currkey VALUE 'IDR',
         lv_amount      TYPE bbseg-wrbtr,
         lv_str1        TYPE string,
         lv_str2        TYPE string,
         lv_char1(20),
         lv_char2(20),
         lv_subrc       TYPE sy-subrc,
         lt_out1        TYPE STANDARD TABLE OF swastrtab,
         lt_out2        TYPE STANDARD TABLE OF swastrtab,
         ls_out1        LIKE LINE OF lt_out1,
         ls_out2        LIKE LINE OF lt_out2,
         lv_count       TYPE int4,
         lv_tabix       TYPE sy-tabix,
         lv_percen      TYPE p DECIMALS 0,
         lv_index       TYPE int4.

  DATA : lv_div         TYPE p DECIMALS 0,
         lv_mod         TYPE p DECIMALS 0.

  lv_subrc  = 4.
  CLEAR : lv_index, lv_percen, pto_data[], pto_data.
  lv_count  = pvi_count.

  lv_div    = pvi_count DIV 1000.
  lv_mod    = pvi_count MOD 1000.

  WHILE lv_subrc <> 0.
    DO lv_div TIMES.
      DO 1000 TIMES.
*        ADD 1 TO lv_index.
*        lv_percen = ( lv_count - ( lv_count - lv_index ) ) / 100.
*        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*          EXPORTING
*            percentage = lv_percen
*            text       = 'Data is being process...'.

        CALL FUNCTION 'RANDOM_AMOUNT'
          EXPORTING
            rnd_min    = lv_min
            rnd_max    = lv_max
            valcurr    = lv_curr
          IMPORTING
            rnd_amount = lv_amount.

        CLEAR : lv_char1, lt_out1[], lt_out1.
        lv_char1 = lv_amount.
        TRANSLATE lv_char1 USING '. '.
        TRANSLATE lv_char1 USING ',.'.
        CONDENSE lv_char1 NO-GAPS.

        lv_str1 = lv_char1.

        CALL FUNCTION 'SWA_STRING_SPLIT'
          EXPORTING
            input_string                 = lv_str1
            max_component_length         = pvi_split
          TABLES
            string_components            = lt_out1
          EXCEPTIONS
            max_component_length_invalid = 1
            OTHERS                       = 2.

        CALL 'ALERTS' ID 'ADMODE' FIELD 20
        ID 'OPCODE' FIELD 30
        ID 'ACT_TIME' FIELD lv_time_utc.

        CLEAR : lv_char2, lt_out2[], lt_out2.
        lv_char2 = lv_time_utc.
        CONDENSE lv_char2 NO-GAPS.

        lv_str2 = lv_char2.

        CALL FUNCTION 'SWA_STRING_SPLIT'
          EXPORTING
            input_string                 = lv_str2
            max_component_length         = pvi_split
          TABLES
            string_components            = lt_out2
          EXCEPTIONS
            max_component_length_invalid = 1
            OTHERS                       = 2.

        DESCRIBE TABLE lt_out1 LINES lv_tabix.

        LOOP AT lt_out1 INTO ls_out1.
          READ TABLE lt_out2 INTO ls_out2 INDEX sy-tabix.
          IF sy-tabix = lv_tabix.
            CONCATENATE ls_data-senum ls_out2-str ls_out1-str INTO ls_data-senum.
          ELSE.
            CONCATENATE ls_data-senum ls_out1-str ls_out2-str INTO ls_data-senum.
          ENDIF.
        ENDLOOP.

        CONDENSE ls_data-senum NO-GAPS.
        APPEND ls_data TO pto_data.
        CLEAR ls_data.
      ENDDO.
    ENDDO.

    DO lv_mod TIMES.
*      ADD 1 TO lv_index.
*      lv_percen = ( lv_count - ( lv_count - lv_index ) ) / 100.
*      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*        EXPORTING
*          percentage = lv_percen
*          text       = 'Data is being process...'.

      CALL FUNCTION 'RANDOM_AMOUNT'
        EXPORTING
          rnd_min    = lv_min
          rnd_max    = lv_max
          valcurr    = lv_curr
        IMPORTING
          rnd_amount = lv_amount.

      CLEAR : lv_char1, lt_out1[], lt_out1.
      lv_char1 = lv_amount.
      TRANSLATE lv_char1 USING '. '.
      TRANSLATE lv_char1 USING ',.'.
      CONDENSE lv_char1 NO-GAPS.

      lv_str1 = lv_char1.

      CALL FUNCTION 'SWA_STRING_SPLIT'
        EXPORTING
          input_string                 = lv_str1
          max_component_length         = pvi_split
        TABLES
          string_components            = lt_out1
        EXCEPTIONS
          max_component_length_invalid = 1
          OTHERS                       = 2.

      CALL 'ALERTS' ID 'ADMODE' FIELD 20
      ID 'OPCODE' FIELD 30
      ID 'ACT_TIME' FIELD lv_time_utc.

      CLEAR : lv_char2, lt_out2[], lt_out2.
      lv_char2 = lv_time_utc.
      CONDENSE lv_char2 NO-GAPS.

      lv_str2 = lv_char2.

      CALL FUNCTION 'SWA_STRING_SPLIT'
        EXPORTING
          input_string                 = lv_str2
          max_component_length         = pvi_split
        TABLES
          string_components            = lt_out2
        EXCEPTIONS
          max_component_length_invalid = 1
          OTHERS                       = 2.

      DESCRIBE TABLE lt_out1 LINES lv_tabix.

      LOOP AT lt_out1 INTO ls_out1.
        READ TABLE lt_out2 INTO ls_out2 INDEX sy-tabix.
        IF sy-tabix = lv_tabix.
          CONCATENATE ls_data-senum ls_out2-str ls_out1-str INTO ls_data-senum.
        ELSE.
          CONCATENATE ls_data-senum ls_out1-str ls_out2-str INTO ls_data-senum.
        ENDIF.
      ENDLOOP.

      CONDENSE ls_data-senum NO-GAPS.
      APPEND ls_data TO pto_data.
      CLEAR ls_data.
    ENDDO.

    SORT pto_data.
    DELETE ADJACENT DUPLICATES FROM pto_data COMPARING ALL FIELDS.
    DESCRIBE TABLE pto_data LINES lv_count.
    IF pvi_count = lv_count.
      CLEAR lv_subrc.
    ELSE.
      lv_count = pvi_count - lv_count.
      lv_subrc  = 4.
    ENDIF.
  ENDWHILE.
ENDMETHOD.


METHOD m_acc_split_sn.
  DATA : lv_length    TYPE i,
         lv_senum     TYPE i,
         lv_charg     TYPE i,
         lv_str1      TYPE string,
         lv_str2      TYPE string,
         lv_ean11     TYPE mean-ean11,
         lv_gtin(14).

  DATA : lt_tab       TYPE TABLE OF string,
         tab,
         ls_tab       LIKE LINE OF lt_tab.

  tab = cl_abap_char_utilities=>horizontal_tab.

  IF pvi_bpom IS NOT INITIAL.
    lv_length = STRLEN( pvi_senum ).
    lv_length = lv_length - 20.
    IF lv_length > 0.
      pvo_senum    = pvi_senum+lv_length(20).
    ENDIF.
  ELSE.
    SPLIT pvi_senum AT ';' INTO TABLE lt_tab.
    READ TABLE lt_tab INTO ls_tab INDEX 2.
    IF ls_tab IS INITIAL.
      SPLIT pvi_senum AT tab INTO TABLE lt_tab.
      READ TABLE lt_tab INTO ls_tab INDEX 2.
      IF ls_tab IS INITIAL.
        SPLIT pvi_senum AT space INTO TABLE lt_tab.
      ENDIF.
    ENDIF.

    READ TABLE lt_tab INTO ls_tab INDEX 2.
    IF sy-subrc = 0.
      CLEAR lv_length.
      lv_length    = STRLEN( ls_tab ).
      lv_charg     = lv_length - 2.
      pvo_charg    = ls_tab+2(lv_charg).
*      CONDENSE pvo_charg NO-GAPS.
      SHIFT pvo_charg LEFT DELETING LEADING space.
    ENDIF.

    READ TABLE lt_tab INTO ls_tab INDEX 3.
    IF sy-subrc = 0.
      CLEAR lv_length.
      lv_length    = STRLEN( ls_tab ).
      lv_senum     = lv_length - 10.
      pvo_senum    = ls_tab+10(lv_senum).
*      CONDENSE pvo_senum NO-GAPS.
      SHIFT pvo_senum LEFT DELETING LEADING space.
    ELSE.
      pvo_senum   = pvi_senum.
    ENDIF.

    IF pvo_charg IS INITIAL.
      SELECT SINGLE matnr charg
        FROM zaccdta
        INTO (pvo_matnr, pvo_charg)
        WHERE aggr2 = pvo_senum
          AND zact2 ='X'.
      IF sy-subrc NE 0.
        SELECT SINGLE matnr charg
          FROM zaccdta
          INTO (pvo_matnr, pvo_charg)
          WHERE aggr1 = pvo_senum
            AND zact1 ='X'.
        IF sy-subrc NE 0.
          SELECT SINGLE matnr charg
            FROM zaccdtm
            INTO (pvo_matnr, pvo_charg)
            WHERE senum = pvo_senum.
        ENDIF.
      ENDIF.
    ELSE.
      SELECT SINGLE matnr
        FROM zaccdta
        INTO pvo_matnr
        WHERE aggr2 = pvo_senum
          AND zact2 ='X'.
      IF sy-subrc NE 0.
        SELECT SINGLE matnr
          FROM zaccdta
          INTO pvo_matnr
          WHERE aggr1 = pvo_senum
            AND zact1 ='X'.
        IF sy-subrc NE 0.
          SELECT SINGLE matnr
            FROM zaccdtm
            INTO pvo_matnr
            WHERE senum = pvo_senum.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pvo_matnr IS INITIAL AND
    pvo_charg IS INITIAL.
    lv_gtin     = pvi_senum+2(14).

    CALL FUNCTION 'CONVERSION_EXIT_EAN11_INPUT'
      EXPORTING
        input  = lv_gtin
      IMPORTING
        output = lv_ean11.

    SELECT SINGLE matnr
      FROM mean
      INTO pvo_matnr
      WHERE ean11 = lv_ean11
        AND eantp = 'Z3'.

    pvo_senum   = pvi_senum+18(14).
    pvo_charg   = pvi_senum+44.
  ENDIF.
ENDMETHOD.


METHOD m_ascii_to_char.
  DATA: lv_sep   TYPE c.

  FIELD-SYMBOLS : <xfs> TYPE x.

  ASSIGN lv_sep TO <xfs> CASTING.

  <xfs> = pvi_ascii.
  pvo_char = lv_sep.
ENDMETHOD.


METHOD m_concate_text_jde.

  DATA: lv_field_index TYPE syindex,
        ls_string      TYPE string.

  DATA:  t_newtable TYPE REF TO data,
         t_newline  TYPE REF TO data.

  FIELD-SYMBOLS: <t_dyntable>  TYPE STANDARD TABLE,  " Dynamic internal table name
                 <fs_dyntable> TYPE ANY,             " Field symbol to create work area
                 <fs_fldval>   TYPE ANY.             " Field symbol to assign values

* Creating Dynamic internal table
  CREATE DATA t_newtable LIKE pti_data.
  ASSIGN t_newtable->* TO <t_dyntable>.

* Create dynamic work area and assign to FS
  CREATE DATA t_newline LIKE LINE OF <t_dyntable>.
  ASSIGN t_newline->* TO <fs_dyntable>.

  LOOP AT pti_data ASSIGNING <fs_dyntable>.
    CLEAR ls_string.
    DO.
      lv_field_index = sy-index.
      ASSIGN COMPONENT lv_field_index OF STRUCTURE <fs_dyntable> TO <fs_fldval>.
      IF sy-subrc <> 0.
        CONCATENATE ls_string '"' INTO ls_string.
        EXIT.
      ELSE.
        IF ls_string IS INITIAL.
          CONCATENATE '"' <fs_fldval> INTO ls_string RESPECTING BLANKS.
        ELSE.
          CONCATENATE ls_string <fs_fldval> INTO ls_string
            SEPARATED BY '","' RESPECTING BLANKS.
        ENDIF.
      ENDIF.
    ENDDO.
    APPEND ls_string TO pto_data.
  ENDLOOP.

ENDMETHOD.


METHOD m_concate_text_separator.
  DATA: lv_field_index TYPE syindex,
        ls_string      TYPE string.

  DATA:  t_newtable TYPE REF TO data,
         t_newline  TYPE REF TO data.

  FIELD-SYMBOLS: <t_dyntable>  TYPE STANDARD TABLE,  " Dynamic internal table name
                 <fs_dyntable> TYPE ANY,             " Field symbol to create work area
                 <fs_fldval>   TYPE ANY.             " Field symbol to assign values

* Creating Dynamic internal table
  CREATE DATA t_newtable LIKE pti_data.
  ASSIGN t_newtable->* TO <t_dyntable>.

* Create dynamic work area and assign to FS
  CREATE DATA t_newline LIKE LINE OF <t_dyntable>.
  ASSIGN t_newline->* TO <fs_dyntable>.

  LOOP AT pti_data ASSIGNING <fs_dyntable>.
    CLEAR ls_string.
    DO.
      lv_field_index = sy-index.
      ASSIGN COMPONENT lv_field_index OF STRUCTURE <fs_dyntable> TO <fs_fldval>.
      IF sy-subrc <> 0.
        EXIT.
      ELSE.
        IF ls_string IS INITIAL.
          ls_string = <fs_fldval>.
        ELSE.
          CONCATENATE ls_string <fs_fldval> INTO ls_string
            SEPARATED BY pvi_separator RESPECTING BLANKS.
        ENDIF.
      ENDIF.
    ENDDO.
    APPEND ls_string TO pto_data.
  ENDLOOP.
ENDMETHOD.


METHOD m_concate_text_separator2.
  TYPE-POOLS: abap.

  DATA: lv_field_index TYPE syindex,
        ls_string      TYPE string,
        lv_len         TYPE i,
        gs_structure   TYPE abap_compdescr.

  DATA:  t_newtable    TYPE REF TO data,
         t_newline     TYPE REF TO data,
         t_cdata       TYPE REF TO data.

  FIELD-SYMBOLS: <t_dyntable>  TYPE STANDARD TABLE,  " Dynamic internal table name
                 <fs_dyntable> TYPE ANY,             " Field symbol to create work area
                 <fs_fldval>   TYPE ANY,             " Field symbol to assign values
                 <fs_cdata>    TYPE ANY.             " Field symbol char data

* Creating Dynamic internal table
  CREATE DATA t_newtable LIKE pti_data.
  ASSIGN t_newtable->* TO <t_dyntable>.

* Create dynamic work area and assign to FS
  CREATE DATA t_newline LIKE LINE OF <t_dyntable>.
  ASSIGN t_newline->* TO <fs_dyntable>.

  LOOP AT pti_data ASSIGNING <fs_dyntable>.
    CLEAR ls_string.
    DO.
      lv_field_index = sy-index.
      ASSIGN COMPONENT lv_field_index OF STRUCTURE <fs_dyntable> TO <fs_fldval>.

      IF sy-subrc <> 0.
        IF ls_string IS NOT INITIAL.
          CONCATENATE ls_string pvi_separator INTO ls_string
            RESPECTING BLANKS.
        ENDIF.
        EXIT.

      ELSE.
        CLEAR: gs_structure,lv_len.
        READ TABLE pti_structure INTO gs_structure INDEX lv_field_index.

        IF gs_structure-name = 'MANDT'.
          CONTINUE.
        ENDIF.

        lv_len = gs_structure-length + gs_structure-decimals.
        CREATE DATA t_cdata TYPE c LENGTH lv_len.
        ASSIGN t_cdata->* TO <fs_cdata>.

        IF gs_structure-type_kind = 'P'.
          WRITE <fs_fldval> TO <fs_cdata> DECIMALS gs_structure-decimals.
        ELSE.
          <fs_cdata> = <fs_fldval>.
        ENDIF.

        IF ls_string IS INITIAL.
*          ls_string = <fs_cdata>.     "<fs_fldval>.
          CONCATENATE pvi_separator <fs_cdata> INTO ls_string
            RESPECTING BLANKS.
        ELSE.
*          CONCATENATE ls_string <fs_cdata> INTO ls_string
*            SEPARATED BY pvi_separator RESPECTING BLANKS.
          CONCATENATE ls_string pvi_separator <fs_cdata> INTO ls_string
            RESPECTING BLANKS.
        ENDIF.
      ENDIF.
    ENDDO.
    APPEND ls_string TO pto_data.
  ENDLOOP.
ENDMETHOD.


METHOD m_concat_text.

  CHECK i_text IS NOT INITIAL.

  IF c_text IS INITIAL.
    c_text = i_text.
  ELSE.
    CONCATENATE i_text `, ` c_text INTO c_text.
  ENDIF.

ENDMETHOD.


METHOD m_debug.
  DATA : return     TYPE STANDARD TABLE OF bapiret2,
         groups     TYPE STANDARD TABLE OF bapigroups,
         ls_groups  LIKE LINE OF groups.

  pvo_subrc = 4.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    TABLES
      return   = return
      groups   = groups.

  LOOP AT groups INTO ls_groups.
    IF ls_groups-usergroup = 'DEBUG'.
      pvo_subrc = 0.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDMETHOD.


METHOD m_delete_file.
  DELETE DATASET param_name.

  IF sy-subrc NE 0.
    subrc = 0.
    CONCATENATE 'Invalid file name' param_name INTO message SEPARATED BY space.
  ELSE.
    CLOSE DATASET param_name.
    CONCATENATE param_name 'DELETED' INTO message SEPARATED BY space.
  ENDIF.

ENDMETHOD.


METHOD m_download_dataset.
  DATA: lw_data LIKE LINE OF pti_data,
        lv_lenght TYPE i.

* Open Dataset
*  OPEN DATASET param_name FOR INPUT IN TEXT MODE ENCODING DEFAULT.
*  IF sy-subrc EQ 0.
*    DELETE DATASET param_name.
*    OPEN DATASET param_name FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
*  ELSE.
  OPEN DATASET param_name FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
*  ENDIF.

* Write Dataset
  LOOP AT pti_data INTO lw_data.
*    IF lv_lenght IS INITIAL.
    lv_lenght = STRLEN( lw_data ).
*    ENDIF.
    TRANSFER lw_data TO param_name LENGTH lv_lenght.
  ENDLOOP.

* Close Dataset
  CLOSE DATASET param_name.
ENDMETHOD.


METHOD m_download_dataset_linefeed.
  DATA: lw_data   LIKE LINE OF pti_data,
        lv_lenght TYPE i,
        lv_text   TYPE string.

  OPEN DATASET param_name FOR OUTPUT IN TEXT MODE
                          ENCODING DEFAULT
                          WITH WINDOWS LINEFEED.

* Write Dataset
  LOOP AT pti_data INTO lw_data.
*    lv_lenght = STRLEN( lw_data ).
*    TRANSFER lw_data TO param_name LENGTH lv_lenght.
    TRANSFER lw_data TO param_name.
    SET DATASET param_name POSITION 0.
    READ DATASET param_name INTO lv_text.
    SET DATASET param_name POSITION END OF FILE.
  ENDLOOP.

* Close Dataset
  CLOSE DATASET param_name.
ENDMETHOD.


METHOD m_get_link.
  DATA : ls_folder TYPE zdg2cact0001,
         ld_field(50).
  FIELD-SYMBOLS : <fs_path> TYPE ANY,
                  <fs_folder> TYPE ANY.

  SELECT SINGLE * FROM zdg2cact0001 INTO ls_folder
    WHERE type = i_type.

  ASSIGN ls_folder TO <fs_folder>.
  ASSIGN e_path to <fs_path>.
  ASSIGN COMPONENT i_folder OF STRUCTURE <fs_folder> TO <fs_path>.
  e_path = <fs_path>.

ENDMETHOD.


METHOD m_get_tvarv.
  DATA lt_tvarvc TYPE TABLE OF tvarvc.
  DATA ls_tvarvc TYPE tvarvc.
  IF param_type IS NOT INITIAL.
    SELECT * FROM tvarvc INTO TABLE lt_tvarvc
      WHERE name = param_name
      AND   type = param_type.
  ELSE.
    SELECT * FROM tvarvc INTO TABLE lt_tvarvc
      WHERE name = param_name.
  ENDIF.
  IF lt_tvarvc[] IS INITIAL.
    CONCATENATE 'No data with parameter name' param_name INTO message SEPARATED BY space.
    RETURN.
  ENDIF.
  REFRESH t_return.
  DATA s_return LIKE LINE OF t_return.
  LOOP AT lt_tvarvc INTO ls_tvarvc.
    if ls_tvarvc-sign is INITIAL.
      ls_tvarvc-sign = 'I'.
    endif.
    IF ls_tvarvc-opti is INITIAL.
      ls_tvarvc-opti = 'EQ'.
    ENDIF.
    MOVE-CORRESPONDING ls_tvarvc TO s_return.
    APPEND s_return TO t_return.
  ENDLOOP.
ENDMETHOD.


METHOD m_open_dataset.
  DATA: sstring TYPE string,
        s_return LIKE LINE OF t_return.

  OPEN DATASET param_name FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc EQ 0.
    DO.
      READ DATASET param_name INTO sstring.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      MOVE sstring TO s_return-string.
      APPEND s_return TO t_return.
    ENDDO.
  ENDIF.
  CLOSE DATASET param_name.
ENDMETHOD.


METHOD m_read_excel.

  TYPE-POOLS: truxs.

  DATA: it_raw TYPE truxs_t_text_data.

  DATA work_tab_ref             TYPE REF TO data.
  FIELD-SYMBOLS <work_tab>      TYPE STANDARD TABLE.

  CREATE DATA work_tab_ref LIKE pto_data.
  ASSIGN work_tab_ref->* TO <work_tab>.

  DATA lv_fname TYPE rlgrap-filename.
  MOVE pi_filename TO lv_fname.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_line_header        = pi_is_header
      i_tab_raw_data       = it_raw
      i_filename           = lv_fname
    TABLES
      i_tab_converted_data = <work_tab>
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
  ELSE.
    pto_data = <work_tab>.
  ENDIF.


ENDMETHOD.


method M_READ_TXT.

  DATA work_tab_ref             TYPE REF TO data.
  FIELD-SYMBOLS <work_tab>      TYPE STANDARD TABLE.

  CREATE DATA work_tab_ref LIKE pto_data.
  ASSIGN work_tab_ref->* TO <work_tab>.

*  data lv_fname type rlgrap-filename.
*  move pi_filename to lv_fname.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                      = pi_filename
      FILETYPE                      = 'ASC'
      HAS_FIELD_SEPARATOR           = 'X'
*     HEADER_LENGTH                 = 0
*     READ_BY_LINE                  = 'X'
*     DAT_MODE                      = ' '
*     CODEPAGE                      = ' '
*     IGNORE_CERR                   = ABAP_TRUE
*     REPLACEMENT                   = '#'
*     CHECK_BOM                     = ' '
*     VIRUS_SCAN_PROFILE            =
*     NO_AUTH_CHECK                 = ' '
*   IMPORTING
*     FILELENGTH                    =
*     HEADER                        =
    tables
      data_tab                      = <work_tab>
    EXCEPTIONS
      FILE_OPEN_ERROR               = 1
      FILE_READ_ERROR               = 2
      NO_BATCH                      = 3
      GUI_REFUSE_FILETRANSFER       = 4
      INVALID_TYPE                  = 5
      NO_AUTHORITY                  = 6
      UNKNOWN_ERROR                 = 7
      BAD_DATA_FORMAT               = 8
      HEADER_NOT_ALLOWED            = 9
      SEPARATOR_NOT_ALLOWED         = 10
      HEADER_TOO_LONG               = 11
      UNKNOWN_DP_ERROR              = 12
      ACCESS_DENIED                 = 13
      DP_OUT_OF_MEMORY              = 14
      DISK_FULL                     = 15
      DP_TIMEOUT                    = 16
      OTHERS                        = 17
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    pto_data = <work_tab>.
  ENDIF.

endmethod.


METHOD m_replace_char_to_space.
  pvo_text = pvi_text.

  WHILE pvo_text CS pvi_char.
    pvo_text+sy-fdpos(1) = space.
  ENDWHILE.
ENDMETHOD.


METHOD m_replace_eol_flag.
  DATA: cr(1)  TYPE c,
        tab(1) TYPE c.

  cr = cl_abap_char_utilities=>cr_lf.
  tab = cl_abap_char_utilities=>horizontal_tab.

  pvo_char = pvi_char.
  REPLACE cr IN pvo_char WITH space.
  REPLACE tab IN pvo_char WITH space.

ENDMETHOD.


METHOD m_send_email.

* Global data declarations

  "Data Declaration
  DATA: lo_sender TYPE REF TO if_sender_bcs VALUE IS INITIAL,
        l_send    TYPE adr6-smtp_addr ,
        l_rec     TYPE  adr6-smtp_addr,
        itab      TYPE TABLE OF sval,
        ls_itab   TYPE sval,
        i_return,

        lo_send_request     TYPE REF TO cl_bcs VALUE IS INITIAL,
        lx_document_bcs     TYPE REF TO cx_document_bcs VALUE IS INITIAL,
        attachment_subject  TYPE so_obj_des,

        lo_recipient      TYPE REF TO if_recipient_bcs VALUE IS INITIAL,
        ls_recipient      LIKE LINE OF recipients,
        ls_attachment     LIKE LINE OF attachments,
        lv_recipient_uid  TYPE uname,
        lv_recipient_mail TYPE adr6-smtp_addr.


  "Prepare Mail Object
  CLASS cl_bcs DEFINITION LOAD.
*  lo_send_request = cl_bcs=>create_persistent( ).

  TRY.
      CALL METHOD cl_bcs=>create_persistent
        RECEIVING
          result = lo_send_request.
    CATCH cx_send_req_bcs .
      RETURN.
  ENDTRY.


  "Message body and subject
  DATA: lo_document TYPE REF TO cl_document_bcs VALUE IS INITIAL.

*  lo_document = cl_document_bcs=>create_document(
*                i_type    = 'RAW'
*                i_text    =  message_body
*                i_subject = subject
*                ).

  TRY.
      CALL METHOD cl_document_bcs=>create_document
        EXPORTING
          i_type    = 'RAW'
          i_subject = subject
          i_text    = message_body
        RECEIVING
          result    = lo_document.
    CATCH cx_document_bcs .
  ENDTRY.




  "Send  attachment
  LOOP AT attachments INTO ls_attachment.
    attachment_subject = ls_attachment-subject.
    TRY.
        lo_document->add_attachment(
        EXPORTING
          i_attachment_type     = ls_attachment-objtp
          i_attachment_subject  = attachment_subject
          i_att_content_hex     = ls_attachment-cont_hex
        ).
      CATCH cx_document_bcs INTO lx_document_bcs.
    ENDTRY.
  ENDLOOP.

  "Pass the document to send request
*  lo_send_request->set_document( lo_document ).
  TRY.
      CALL METHOD lo_send_request->set_document
        EXPORTING
          i_document = lo_document.
    CATCH cx_send_req_bcs .
  ENDTRY.

  TRY.
      IF sender_mail IS NOT INITIAL.
        lo_sender = cl_cam_address_bcs=>create_internet_address( sender_mail ).
      ELSEIF sender_uid IS NOT INITIAL.
        lo_sender = cl_sapuser_bcs=>create( sender_uid ).
      ELSE.
        lo_sender = cl_sapuser_bcs=>create( sy-uname ).
      ENDIF.

      "Set sender
*      lo_send_request->set_sender(
*      EXPORTING
*      i_sender = lo_sender ).
      TRY.
          CALL METHOD lo_send_request->set_sender
            EXPORTING
              i_sender = lo_sender.
        CATCH cx_send_req_bcs .
      ENDTRY.


    CATCH cx_address_bcs.
      RETURN.
  ENDTRY.

  "Set  recipients
  IF recipients[] IS INITIAL.

    IF recipient_mail IS NOT INITIAL.
*      lo_recipient = cl_cam_address_bcs=>create_internet_address( recipient_mail ).
      TRY.
          CALL METHOD cl_cam_address_bcs=>create_internet_address
            EXPORTING
              i_address_string = recipient_mail
            RECEIVING
              result           = lo_recipient.
        CATCH cx_address_bcs .
      ENDTRY.

    ELSEIF recipient_uid IS NOT INITIAL.
*      lo_recipient = cl_sapuser_bcs=>create( recipient_uid ).
      TRY.
          CALL METHOD cl_sapuser_bcs=>create
            EXPORTING
              i_user = recipient_uid
            RECEIVING
              result = lo_recipient.
        CATCH cx_address_bcs .
      ENDTRY.

    ELSE.
*      lo_recipient = cl_sapuser_bcs=>create( sy-uname ).
      TRY.
          CALL METHOD cl_sapuser_bcs=>create
            EXPORTING
              i_user = sy-uname
            RECEIVING
              result = lo_recipient.
        CATCH cx_address_bcs .
      ENDTRY.

    ENDIF.

*    lo_send_request->add_recipient(
*    EXPORTING
*      i_recipient = lo_recipient
*      i_express = 'X'
*    ).

    TRY.
        CALL METHOD lo_send_request->add_recipient
          EXPORTING
            i_recipient = lo_recipient
            i_express   = 'X'.
      CATCH cx_send_req_bcs .
    ENDTRY.


  ELSE.

    LOOP AT recipients INTO ls_recipient.
      IF ls_recipient-iusrid IS NOT INITIAL.
        lv_recipient_uid = ls_recipient-iusrid.
*        lo_recipient = cl_sapuser_bcs=>create( lv_recipient_uid ).
        TRY.
            CALL METHOD cl_sapuser_bcs=>create
              EXPORTING
                i_user = lv_recipient_uid
              RECEIVING
                result = lo_recipient.
          CATCH cx_address_bcs .
        ENDTRY.


      ELSEIF ls_recipient-email IS NOT INITIAL.
        lv_recipient_mail = ls_recipient-email .
*        lo_recipient = cl_cam_address_bcs=>create_internet_address( lv_recipient_mail ).
        TRY.
            CALL METHOD cl_cam_address_bcs=>create_internet_address
              EXPORTING
                i_address_string = lv_recipient_mail
              RECEIVING
                result           = lo_recipient.
          CATCH cx_address_bcs .
        ENDTRY.

      ENDIF.

*      lo_send_request->add_recipient(
*      EXPORTING
*        i_recipient = lo_recipient
*        i_express = 'X'
*      ).

      TRY.
          CALL METHOD lo_send_request->add_recipient
            EXPORTING
              i_recipient = lo_recipient
              i_express   = 'X'.
        CATCH cx_send_req_bcs .
      ENDTRY.

    ENDLOOP.
  ENDIF.


  TRY.
      "Send email
      lo_send_request->send(
      EXPORTING
        i_with_error_screen = 'X'
      RECEIVING
        result = result ).
      COMMIT WORK.
      WAIT UP TO 1 SECONDS.
    CATCH cx_send_req_bcs.
      result = ''.
  ENDTRY.

ENDMETHOD.


METHOD m_upload_csv_to_itab.

  TYPE-POOLS: rmdi, kcde.

  DATA: lt_tabfields TYPE rmdi_tabfld_t,
        lw_tabfields TYPE rmdi_tabfld,
        lt_excel     TYPE  TABLE OF  kcde_cells, "kcde_intern, "  WITH HEADER LINE,
        lw_excel     LIKE LINE OF lt_excel,
        v_field(50).

  DATA:  t_newtable TYPE REF TO data,
         t_newline  TYPE REF TO data.

  DATA: BEGIN OF lv_date,
          date1 TYPE char2,
          date2 TYPE char2,
          date3 TYPE char4,
        END OF lv_date.

  DATA: lv_char10 TYPE char10.

  FIELD-SYMBOLS: <t_dyntable>  TYPE STANDARD TABLE,  " Dynamic internal table name
                 <fs_dyntable> TYPE ANY,             " Field symbol to create work area
                 <fs_fldval>   TYPE ANY.             " Field symbol to assign values

* Creating Dynamic internal table
  CREATE DATA t_newtable TYPE TABLE OF (pvi_table).
  ASSIGN t_newtable->* TO <t_dyntable>.

* Create dynamic work area and assign to FS
  CREATE DATA t_newline LIKE LINE OF <t_dyntable>.
  ASSIGN t_newline->* TO <fs_dyntable>.

* Get fields in table
  CALL FUNCTION 'KL_TABLE_INFO_GET'
    EXPORTING
      i_tabname      = pvi_table
    IMPORTING
      e_it_tabfields = lt_tabfields
    EXCEPTIONS
      not_found      = 1
      ddic_error     = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Upload Excel data to itab
  CALL FUNCTION 'KCD_CSV_FILE_TO_INTERN_CONVERT'
    EXPORTING
      i_filename      = pv_filenm
      i_separator     = pvi_separator
    TABLES
      e_intern        = lt_excel
    EXCEPTIONS
      upload_csv      = 1
      upload_filetype = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SORT lt_tabfields BY position.
  SORT lt_excel BY row col.
  CASE pvi_brow.
    WHEN 1.
    WHEN OTHERS.
      DELETE lt_excel WHERE row = '0001'.
  ENDCASE.

  LOOP AT lt_excel INTO lw_excel.
    CLEAR lw_tabfields.
    READ TABLE lt_tabfields INTO lw_tabfields WITH KEY position = lw_excel-col.

    IF lw_tabfields-datatype = 'DEC' OR
       lw_tabfields-datatype = 'QUAN' OR
       lw_tabfields-datatype = 'CURR'.
      TRANSLATE lw_excel-value USING '. '.
      TRANSLATE lw_excel-value USING ',.'.
      CONDENSE lw_excel-value NO-GAPS.
    ENDIF.

    IF lw_tabfields-datatype = 'DATS'.
      TRANSLATE lw_excel-value USING '. '.
      TRANSLATE lw_excel-value USING '/ '.
      CONDENSE lw_excel-value NO-GAPS.

      CLEAR: lv_date.
      lv_date = lw_excel-value.

      IF lv_date-date3 GE '2000'.
        CLEAR lw_excel-value.
        IF lv_date-date2 LE '12'.
          CONCATENATE lv_date-date3 lv_date-date2 lv_date-date1
              INTO lw_excel-value.
        ELSE.
          CONCATENATE lv_date-date3 lv_date-date1 lv_date-date2
              INTO lw_excel-value.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lw_tabfields-datatype = 'TIMS'.
      TRANSLATE lw_excel-value USING ': '.
      CONDENSE lw_excel-value NO-GAPS.
    ENDIF.

    v_field = lw_tabfields-fieldname.
    ASSIGN COMPONENT v_field OF STRUCTURE <fs_dyntable> TO <fs_fldval>.
    <fs_fldval> = lw_excel-value.

    AT END OF row.
      APPEND <fs_dyntable> TO pto_data.
      CLEAR <fs_dyntable>.
    ENDAT.
  ENDLOOP.

ENDMETHOD.


METHOD m_upload_excel_to_itab.

  TYPE-POOLS rmdi.

  DATA: lt_tabfields TYPE rmdi_tabfld_t,
        lw_tabfields TYPE rmdi_tabfld,
        lt_excel     TYPE TABLE OF alsmex_tabline,
        lw_excel     LIKE LINE OF lt_excel,
        v_field(50).

  DATA:  t_newtable TYPE REF TO data,
         t_newline  TYPE REF TO data.

  DATA: BEGIN OF lv_date,
          date1 TYPE char2,
          date2 TYPE char2,
          date3 TYPE char4,
        END OF lv_date.

  DATA: lv_char10 TYPE char10.

  FIELD-SYMBOLS: <t_dyntable>  TYPE STANDARD TABLE,  " Dynamic internal table name
                 <fs_dyntable> TYPE ANY,             " Field symbol to create work area
                 <fs_fldval>   TYPE ANY.             " Field symbol to assign values

* Creating Dynamic internal table
  CREATE DATA t_newtable TYPE TABLE OF (pvi_table).
  ASSIGN t_newtable->* TO <t_dyntable>.

* Create dynamic work area and assign to FS
  CREATE DATA t_newline LIKE LINE OF <t_dyntable>.
  ASSIGN t_newline->* TO <fs_dyntable>.

* Get fields in table
  CALL FUNCTION 'KL_TABLE_INFO_GET'
    EXPORTING
      i_tabname      = pvi_table
    IMPORTING
      e_it_tabfields = lt_tabfields
    EXCEPTIONS
      not_found      = 1
      ddic_error     = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Upload Excel data to itab
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = pv_filenm
      i_begin_col             = pvi_bcol
      i_begin_row             = pvi_brow
      i_end_col               = pvi_ecol
      i_end_row               = pvi_erow
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SORT lt_tabfields BY position.
  SORT lt_excel BY row col.

  LOOP AT lt_excel INTO lw_excel.
    CLEAR lw_tabfields.
    READ TABLE lt_tabfields INTO lw_tabfields WITH KEY position = lw_excel-col.

    IF lw_tabfields-datatype = 'DEC' OR
       lw_tabfields-datatype = 'QUAN' OR
       lw_tabfields-datatype = 'CURR'.
      TRANSLATE lw_excel-value USING '. '.
      TRANSLATE lw_excel-value USING ',.'.
      CONDENSE lw_excel-value NO-GAPS.
    ENDIF.

    IF lw_tabfields-datatype = 'DATS'.
      TRANSLATE lw_excel-value USING '. '.
      TRANSLATE lw_excel-value USING '/ '.
      CONDENSE lw_excel-value NO-GAPS.

      CLEAR: lv_date.
      lv_date = lw_excel-value.

      IF lv_date-date3 GE '2000'.
        CLEAR lw_excel-value.
        IF lv_date-date2 LE '12'.
          CONCATENATE lv_date-date3 lv_date-date2 lv_date-date1
              INTO lw_excel-value.
        ELSE.
          CONCATENATE lv_date-date3 lv_date-date1 lv_date-date2
              INTO lw_excel-value.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lw_tabfields-datatype = 'TIMS'.
      TRANSLATE lw_excel-value USING ': '.
      CONDENSE lw_excel-value NO-GAPS.
    ENDIF.

    v_field = lw_tabfields-fieldname.
    ASSIGN COMPONENT v_field OF STRUCTURE <fs_dyntable> TO <fs_fldval>.
    <fs_fldval> = lw_excel-value.

    AT END OF row.
      APPEND <fs_dyntable> TO pto_data.
      CLEAR <fs_dyntable>.
    ENDAT.
  ENDLOOP.

ENDMETHOD.


METHOD M_UPLOAD_EXCEL_TO_ITAB_NEW.

  TYPE-POOLS rmdi.

  DATA: lt_tabfields TYPE rmdi_tabfld_t,
        lw_tabfields TYPE rmdi_tabfld,
        lt_excel     TYPE TABLE OF zalsmex_tabline,
        lw_excel     LIKE LINE OF lt_excel,
        v_field(50).

  DATA:  t_newtable TYPE REF TO data,
         t_newline  TYPE REF TO data.

  DATA: BEGIN OF lv_date,
          date1 TYPE char2,
          date2 TYPE char2,
          date3 TYPE char4,
        END OF lv_date.

  DATA: lv_char10 TYPE char10.

  FIELD-SYMBOLS: <t_dyntable>  TYPE STANDARD TABLE,  " Dynamic internal table name
                 <fs_dyntable> TYPE ANY,             " Field symbol to create work area
                 <fs_fldval>   TYPE ANY.             " Field symbol to assign values

* Creating Dynamic internal table
  CREATE DATA t_newtable TYPE TABLE OF (pvi_table).
  ASSIGN t_newtable->* TO <t_dyntable>.

* Create dynamic work area and assign to FS
  CREATE DATA t_newline LIKE LINE OF <t_dyntable>.
  ASSIGN t_newline->* TO <fs_dyntable>.

* Get fields in table
  CALL FUNCTION 'KL_TABLE_INFO_GET'
    EXPORTING
      i_tabname      = pvi_table
    IMPORTING
      e_it_tabfields = lt_tabfields
    EXCEPTIONS
      not_found      = 1
      ddic_error     = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Upload Excel data to itab
  CALL FUNCTION 'Z_ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = pv_filenm
      i_begin_col             = pvi_bcol
      i_begin_row             = pvi_brow
      i_end_col               = pvi_ecol
      i_end_row               = pvi_erow
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SORT lt_tabfields BY position.
  SORT lt_excel BY row col.

  LOOP AT lt_excel INTO lw_excel.
    CLEAR lw_tabfields.
    READ TABLE lt_tabfields INTO lw_tabfields WITH KEY position = lw_excel-col.

    IF lw_tabfields-datatype = 'DEC' OR
       lw_tabfields-datatype = 'QUAN' OR
       lw_tabfields-datatype = 'CURR'.
      TRANSLATE lw_excel-value USING '. '.
      TRANSLATE lw_excel-value USING ',.'.
      CONDENSE lw_excel-value NO-GAPS.
    ENDIF.

    IF lw_tabfields-datatype = 'DATS'.
      TRANSLATE lw_excel-value USING '. '.
      TRANSLATE lw_excel-value USING '/ '.
      CONDENSE lw_excel-value NO-GAPS.

      CLEAR: lv_date.
      lv_date = lw_excel-value.

      IF lv_date-date3 GE '2000'.
        CLEAR lw_excel-value.
        IF lv_date-date2 LE '12'.
          CONCATENATE lv_date-date3 lv_date-date2 lv_date-date1
              INTO lw_excel-value.
        ELSE.
          CONCATENATE lv_date-date3 lv_date-date1 lv_date-date2
              INTO lw_excel-value.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lw_tabfields-datatype = 'TIMS'.
      TRANSLATE lw_excel-value USING ': '.
      CONDENSE lw_excel-value NO-GAPS.
    ENDIF.

    v_field = lw_tabfields-fieldname.
    ASSIGN COMPONENT v_field OF STRUCTURE <fs_dyntable> TO <fs_fldval>.
    <fs_fldval> = lw_excel-value.

    AT END OF row.
      APPEND <fs_dyntable> TO pto_data.
      CLEAR <fs_dyntable>.
    ENDAT.
  ENDLOOP.

ENDMETHOD.


METHOD m_upload_excel_to_itab_v2.

  TYPE-POOLS rmdi.

  DATA: lt_tabfields TYPE rmdi_tabfld_t,
        lw_tabfields TYPE rmdi_tabfld,
        lt_excel     TYPE TABLE OF zalsmex_tabline_v2,
        lw_excel     LIKE LINE OF lt_excel,
        v_field(50).

  DATA:  t_newtable TYPE REF TO data,
         t_newline  TYPE REF TO data.

  DATA: BEGIN OF lv_date,
          date1 TYPE char2,
          date2 TYPE char2,
          date3 TYPE char4,
        END OF lv_date.

  DATA: lv_char10 TYPE char10.

  FIELD-SYMBOLS: <t_dyntable>  TYPE STANDARD TABLE,  " Dynamic internal table name
                 <fs_dyntable> TYPE ANY,             " Field symbol to create work area
                 <fs_fldval>   TYPE ANY.             " Field symbol to assign values

* Creating Dynamic internal table
  CREATE DATA t_newtable TYPE TABLE OF (pvi_table).
  ASSIGN t_newtable->* TO <t_dyntable>.

* Create dynamic work area and assign to FS
  CREATE DATA t_newline LIKE LINE OF <t_dyntable>.
  ASSIGN t_newline->* TO <fs_dyntable>.

* Get fields in table
  CALL FUNCTION 'KL_TABLE_INFO_GET'
    EXPORTING
      i_tabname      = pvi_table
    IMPORTING
      e_it_tabfields = lt_tabfields
    EXCEPTIONS
      not_found      = 1
      ddic_error     = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Upload Excel data to itab
  CALL FUNCTION 'Z_ALSM_EXCEL_TO_ITAB_V2'
    EXPORTING
      filename                = pv_filenm
      i_begin_col             = pvi_bcol
      i_begin_row             = pvi_brow
      i_end_col               = pvi_ecol
      i_end_row               = pvi_erow
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SORT lt_tabfields BY position.
  SORT lt_excel BY row col.

  LOOP AT lt_excel INTO lw_excel.
    CLEAR lw_tabfields.
    READ TABLE lt_tabfields INTO lw_tabfields WITH KEY position = lw_excel-col.

    IF lw_tabfields-datatype = 'DEC' OR
       lw_tabfields-datatype = 'QUAN' OR
       lw_tabfields-datatype = 'CURR'.
      TRANSLATE lw_excel-value USING '. '.
      TRANSLATE lw_excel-value USING ',.'.
      CONDENSE lw_excel-value NO-GAPS.
    ENDIF.

    IF lw_tabfields-datatype = 'DATS'.
      TRANSLATE lw_excel-value USING '. '.
      TRANSLATE lw_excel-value USING '/ '.
      CONDENSE lw_excel-value NO-GAPS.

      CLEAR: lv_date.
      lv_date = lw_excel-value.

      IF lv_date-date3 GE '2000'.
        CLEAR lw_excel-value.
        IF lv_date-date2 LE '12'.
          CONCATENATE lv_date-date3 lv_date-date2 lv_date-date1
              INTO lw_excel-value.
        ELSE.
          CONCATENATE lv_date-date3 lv_date-date1 lv_date-date2
              INTO lw_excel-value.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lw_tabfields-datatype = 'TIMS'.
      TRANSLATE lw_excel-value USING ': '.
      CONDENSE lw_excel-value NO-GAPS.
    ENDIF.

    v_field = lw_tabfields-fieldname.
    ASSIGN COMPONENT v_field OF STRUCTURE <fs_dyntable> TO <fs_fldval>.
    <fs_fldval> = lw_excel-value.

    AT END OF row.
      APPEND <fs_dyntable> TO pto_data.
      CLEAR <fs_dyntable>.
    ENDAT.
  ENDLOOP.

ENDMETHOD.


METHOD m_upload_excel_to_itab_v3.

  TYPE-POOLS rmdi.

  DATA: lt_tabfields TYPE rmdi_tabfld_t,
        lw_tabfields TYPE rmdi_tabfld,
        lt_excel     TYPE TABLE OF zalsmex_tabline_v2,
        lw_excel     LIKE LINE OF lt_excel,
        v_field(50).

  DATA: t_newtable TYPE REF TO data,
        t_newline  TYPE REF TO data.

  DATA: BEGIN OF lv_date,
          date1 TYPE char2,
          date2 TYPE char2,
          date3 TYPE char4,
        END OF lv_date.

  DATA: lv_char10 TYPE char10.

  FIELD-SYMBOLS: <t_dyntable>  TYPE STANDARD TABLE,  " Dynamic internal table name
                 <fs_dyntable> TYPE any,             " Field symbol to create work area
                 <fs_fldval>   TYPE any.             " Field symbol to assign values

* Creating Dynamic internal table
  CREATE DATA t_newtable TYPE TABLE OF (pvi_table).
  ASSIGN t_newtable->* TO <t_dyntable>.

* Create dynamic work area and assign to FS
  CREATE DATA t_newline LIKE LINE OF <t_dyntable>.
  ASSIGN t_newline->* TO <fs_dyntable>.

* Get fields in table
  CALL FUNCTION 'KL_TABLE_INFO_GET'
    EXPORTING
      i_tabname      = pvi_table
    IMPORTING
      e_it_tabfields = lt_tabfields
    EXCEPTIONS
      not_found      = 1
      ddic_error     = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Upload Excel data to itab
  CALL FUNCTION 'Z_ALSM_EXCEL_TO_ITAB_V2'
    EXPORTING
      filename                = pv_filenm
      i_begin_col             = pvi_bcol
      i_begin_row             = pvi_brow
      i_end_col               = pvi_ecol
      i_end_row               = pvi_erow
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SORT lt_tabfields BY position.
  SORT lt_excel BY row col.

  LOOP AT lt_excel INTO lw_excel.
    CLEAR lw_tabfields.
    READ TABLE lt_tabfields INTO lw_tabfields WITH KEY position = lw_excel-col.

    IF lw_tabfields-datatype = 'DEC' OR
       lw_tabfields-datatype = 'QUAN' OR
       lw_tabfields-datatype = 'CURR'.
      TRANSLATE lw_excel-value USING '. '.
      TRANSLATE lw_excel-value USING ',.'.
      CONDENSE lw_excel-value NO-GAPS.

      v_field = lw_tabfields-fieldname.
      ASSIGN COMPONENT v_field OF STRUCTURE <fs_dyntable> TO <fs_fldval>.
      TRY .
          <fs_fldval> = lw_excel-value.
        CATCH cx_sy_conversion_no_number INTO DATA(oref).
          pvo_message = | Error during conversion: | & | | & |{ oref->get_text( ) }|.
      ENDTRY.

      IF pvo_message IS NOT INITIAL.
        RAISE convt_no_number.
      ENDIF.
    ENDIF.

    IF lw_tabfields-datatype = 'DATS'.
      TRANSLATE lw_excel-value USING '. '.
      TRANSLATE lw_excel-value USING '/ '.
      TRANSLATE lw_excel-value USING ': '.
      CONDENSE lw_excel-value NO-GAPS.

      CLEAR: lv_date.
      lv_date = lw_excel-value.

      IF lv_date-date3 GE '2000'.
        CLEAR lw_excel-value.
        IF lv_date-date2 LE '12'.
          CONCATENATE lv_date-date3 lv_date-date2 lv_date-date1
              INTO lw_excel-value.
        ELSE.
          CONCATENATE lv_date-date3 lv_date-date1 lv_date-date2
              INTO lw_excel-value.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lw_tabfields-datatype = 'TIMS'.
      TRANSLATE lw_excel-value USING ': '.
      CONDENSE lw_excel-value NO-GAPS.
    ENDIF.

    v_field = lw_tabfields-fieldname.
    ASSIGN COMPONENT v_field OF STRUCTURE <fs_dyntable> TO <fs_fldval>.
    <fs_fldval> = lw_excel-value.

    AT END OF row.
      APPEND <fs_dyntable> TO pto_data.
      CLEAR <fs_dyntable>.
    ENDAT.
  ENDLOOP.

ENDMETHOD.
ENDCLASS.
