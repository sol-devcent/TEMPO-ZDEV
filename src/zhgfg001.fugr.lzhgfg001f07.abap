*----------------------------------------------------------------------*
***INCLUDE LZHGFG001F07.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_PID_DATA
*&---------------------------------------------------------------------*
FORM f_get_pid_data  USING    fu_username fu_lgnum fu_werks
                     CHANGING fs_piddata    TYPE zhgwmst007
                              fc_type fc_message.

  fs_piddata-username         = fu_username.
  fs_piddata-warehouse_number = fu_lgnum.
  fs_piddata-plant            = fu_werks.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_SLOC
*&---------------------------------------------------------------------*
FORM f_get_sloc  TABLES   ft_sloc	STRUCTURE	zhgwmst008
                 USING    fu_werks
                 CHANGING fc_type fc_message.
  DATA : lt_t001l TYPE STANDARD TABLE OF t001l,
         ls_t001l LIKE LINE OF lt_t001l,
         lr_lgort TYPE RANGE OF lgort_d,
         ls_lgort LIKE LINE OF lr_lgort.

  DATA : ls_sloc    TYPE zhgwmst008,
         ls_stcat   TYPE zhgwmst009,
         ls_printer TYPE zhgwmst010,
         ls_reason  TYPE  zhgwmst011,
         ls_scan    TYPE  zhgwmst012.

  ls_lgort-low    = '2*'.
  ls_lgort-sign   = 'I'.
  ls_lgort-option = 'CP'.
  APPEND ls_lgort TO lr_lgort.

  SELECT *
    FROM t001l
    INTO CORRESPONDING FIELDS OF TABLE lt_t001l
    WHERE werks = fu_werks
      AND lgort IN lr_lgort.

  LOOP AT lt_t001l INTO ls_t001l.
    ls_sloc-storage_location = ls_t001l-lgort.
    APPEND ls_sloc TO ft_sloc.
    CLEAR ls_sloc.
  ENDLOOP.
  DELETE ADJACENT DUPLICATES FROM ft_sloc COMPARING storage_location.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_STCAT
*&---------------------------------------------------------------------*
FORM f_get_stcat  TABLES   ft_stcat  STRUCTURE zhgwmst009
                  CHANGING fc_type fc_message.
  DATA : values_tab TYPE STANDARD TABLE OF dd07v,
         ls_values  LIKE LINE OF values_tab,
         ls_stcat   TYPE zhgwmst009.

  DATA : domname    TYPE dd07l-domname.

  domname = 'ZTSPDM001'.

  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      domname         = domname
    TABLES
      values_tab      = values_tab
    EXCEPTIONS
      no_values_found = 1
      OTHERS          = 2.

  LOOP AT values_tab INTO ls_values.
    ls_stcat-stock_category = ls_values-ddtext.
    ls_stcat-code_stcat = ls_values-domvalue_l.
    APPEND ls_stcat TO ft_stcat.
    CLEAR ls_stcat.
  ENDLOOP.
  DELETE ADJACENT DUPLICATES FROM ft_stcat COMPARING code_stcat.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_PRINTER
*&---------------------------------------------------------------------*
FORM f_get_printer  TABLES   ft_printer  STRUCTURE zhgwmst010
                    USING    fu_username
                    CHANGING fc_type fc_message.

  DATA : username   TYPE bapibname-bapibname,
         defaults   TYPE bapidefaul,
         return     TYPE STANDARD TABLE OF bapiret2,
         lr_lname   TYPE RANGE OF rspolname,
         ls_lname   LIKE LINE OF lr_lname,
         lv_lname   TYPE rspolname,
         lt_tsp03l  TYPE STANDARD TABLE OF tsp03l,
         ls_tsp03l  LIKE LINE OF lt_tsp03l,
         ls_printer TYPE zhgwmst010.

  username  = fu_username.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = username
    IMPORTING
      defaults = defaults
    TABLES
      return   = return.

  CALL FUNCTION 'CONVERSION_EXIT_SPDEV_OUTPUT'
    EXPORTING
      input  = defaults-spld
    IMPORTING
      output = lv_lname.

  CONCATENATE lv_lname(8) '*' INTO ls_lname-low.
  ls_lname-sign   = 'I'.
  ls_lname-option = 'CP'.
  APPEND ls_lname TO lr_lname.

  SELECT *
    FROM tsp03l
    INTO CORRESPONDING FIELDS OF TABLE lt_tsp03l
    WHERE lname IN lr_lname.

  LOOP AT lt_tsp03l INTO ls_tsp03l.
    ls_printer-printer  = ls_tsp03l-lname.
    APPEND ls_printer TO ft_printer.
    CLEAR ls_printer.
  ENDLOOP.
  DELETE ADJACENT DUPLICATES FROM ft_printer COMPARING printer.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_REASON
*&---------------------------------------------------------------------*
FORM f_get_reason  TABLES   ft_reason	STRUCTURE	zhgwmst011
                   USING    fu_werks
                   CHANGING fc_type fc_message.
  DATA : lt_007    TYPE STANDARD TABLE OF ztspmmdt007,
         ls_007    LIKE LINE OF lt_007,
         ls_reason TYPE zhgwmst011.

  SELECT *
    FROM ztspmmdt007
    INTO CORRESPONDING FIELDS OF TABLE lt_007
    WHERE werks = fu_werks.

  LOOP AT lt_007 INTO ls_007.
    ls_reason-reason  = ls_007-pidres.
    ls_reason-text    = ls_007-pidtxt.
    APPEND ls_reason TO ft_reason.
    CLEAR ls_reason.
  ENDLOOP.
  DELETE ADJACENT DUPLICATES FROM ft_reason COMPARING reason.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_SCAN
*&---------------------------------------------------------------------*
FORM f_get_scan  TABLES   ft_scan	STRUCTURE	zhgwmst012
                 USING    fu_lgnum
                 CHANGING fc_type fc_message.
  DATA : values_tab TYPE STANDARD TABLE OF dd07v,
         ls_values  LIKE LINE OF values_tab,
         ls_scan    TYPE zhgwmst012.

  DATA : domname  TYPE dd07l-domname,
         lv_profi TYPE t313b-profi.

  lv_profi  = 'ZSW'.

  SELECT SINGLE vsmat
    FROM t313b
    INTO ls_scan-scan_indicator
    WHERE lgnum = fu_lgnum
      AND profi = lv_profi.

  APPEND ls_scan TO ft_scan.
ENDFORM.
