class ZCL_EXCEL_AUTOFILTER definition
  public
  final
  create public .

*"* public components of class ZCL_EXCEL_AUTOFILTER
*"* do not include other source files here!!!
public section.

  data FILTER_AREA type ZEXCEL_S_AUTOFILTER_AREA .

  methods CONSTRUCTOR
    importing
      !IO_SHEET type ref to ZCL_EXCEL_WORKSHEET .
  methods SET_FILTER_AREA
    importing
      !IS_AREA type ZEXCEL_S_AUTOFILTER_AREA .
  methods SET_VALUE
    importing
      !I_COLUMN type ZEXCEL_CELL_COLUMN
      !I_VALUE type ZEXCEL_CELL_VALUE .
  methods SET_VALUES
    importing
      !IT_VALUES type ZEXCEL_T_AUTOFILTER_VALUES .
  methods GET_VALUES
    returning
      value(RT_FILTER) type ZEXCEL_T_AUTOFILTER_VALUES .
  methods GET_FILTER_REFERENCE
    returning
      value(R_REF) type ZEXCEL_RANGE_VALUE .
  methods GET_FILTER_AREA
    returning
      value(RS_AREA) type ZEXCEL_S_AUTOFILTER_AREA .
  methods GET_FILTER_RANGE
    returning
      value(R_RANGE) type ZEXCEL_CELL_VALUE .
protected section.
*"* protected components of class ZCL_EXCEL_AUTOFILTER
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_EXCEL_AUTOFILTER
*"* do not include other source files here!!!

  data WORKSHEET type ref to ZCL_EXCEL_WORKSHEET .
  data VALUES type ZEXCEL_T_AUTOFILTER_VALUES .

  methods VALIDATE_AREA .
ENDCLASS.



CLASS ZCL_EXCEL_AUTOFILTER IMPLEMENTATION.


method CONSTRUCTOR.
  worksheet = io_sheet.
  endmethod.


method GET_FILTER_AREA.

  validate_area( ).

  rs_area = filter_area.

  endmethod.


method GET_FILTER_RANGE.
  DATA: l_row_start_c  TYPE string,
        l_row_end_c    TYPE string,
        l_col_start_c  TYPE string,
        l_col_end_c    TYPE string,
        l_value        TYPE string.

  validate_area( ).

  l_row_end_c = filter_area-row_end.
  CONDENSE l_row_end_c NO-GAPS.

  l_row_start_c = filter_area-row_start.
  CONDENSE l_row_start_c NO-GAPS.

  l_col_start_c = zcl_excel_common=>convert_column2alpha( ip_column = filter_area-col_start ) .
  l_col_end_c   = zcl_excel_common=>convert_column2alpha( ip_column = filter_area-col_end ) .

  CONCATENATE l_col_start_c l_row_start_c ':' l_col_end_c l_row_end_c INTO r_range.

  endmethod.


method GET_FILTER_REFERENCE.
  DATA: l_row_start_c  TYPE string,
        l_row_end_c    TYPE string,
        l_col_start_c  TYPE string,
        l_col_end_c    TYPE string,
        l_value        TYPE string.

  validate_area( ).

  l_row_end_c = filter_area-row_end.
  CONDENSE l_row_end_c NO-GAPS.

  l_row_start_c = filter_area-row_start.
  CONDENSE l_row_start_c NO-GAPS.

  l_col_start_c = zcl_excel_common=>convert_column2alpha( ip_column = filter_area-col_start ) .
  l_col_end_c   = zcl_excel_common=>convert_column2alpha( ip_column = filter_area-col_end ) .
  l_value = worksheet->get_title( ) .

  r_ref = zcl_excel_common=>escape_string( ip_value = l_value ).

  CONCATENATE r_ref '!$' l_col_start_c '$' l_row_start_c ':$' l_col_end_c '$' l_row_end_c INTO r_ref.

  endmethod.


method GET_VALUES.

  rt_filter = values.

  endmethod.


method SET_FILTER_AREA.

  filter_area = is_area.

  endmethod.


method SET_VALUE.
  DATA: ls_values TYPE zexcel_s_autofilter_values.

* Checks a re missing.
  ls_values-column = i_column.
  ls_values-value = i_value.

  INSERT ls_values INTO TABLE values.
* Now we need to be sure we don't get the same value again.
  DELETE ADJACENT DUPLICATES FROM values COMPARING column value.

  endmethod.


method SET_VALUES.

* Checks are missing.
  values = it_values.
  DELETE ADJACENT DUPLICATES FROM values COMPARING column value.

  endmethod.


method VALIDATE_AREA.
  DATA: l_col TYPE zexcel_cell_column,
        l_row TYPE zexcel_cell_row.

  l_row = worksheet->get_highest_row( ) .
  l_col = worksheet->get_highest_column( ) .

  IF filter_area IS INITIAL.
    filter_area-row_start = 1.
    filter_area-col_start = 1.
    filter_area-row_end   = l_row .
    filter_area-col_end   = l_col .
  ENDIF.

  IF filter_area-row_start < 1.
    filter_area-row_start = 1.
  ENDIF.
  IF filter_area-col_start < 1.
    filter_area-col_start = 1.
  ENDIF.
  IF filter_area-row_end > l_row OR
     filter_area-row_end < 1.
    filter_area-row_end = l_row.
  ENDIF.
  IF filter_area-col_end > l_col OR
     filter_area-col_end < 1.
    filter_area-col_end = l_col.
  ENDIF.
  IF filter_area-row_start >= filter_area-row_end.
    filter_area-row_start = filter_area-row_end - 1.
    IF filter_area-row_start < 1.
      filter_area-row_start = 1.
      filter_area-row_end = 2.
    ENDIF.
  ENDIF.
  IF filter_area-col_start > filter_area-col_end.
    filter_area-col_start = filter_area-col_end.
  ENDIF.
  endmethod.
ENDCLASS.
