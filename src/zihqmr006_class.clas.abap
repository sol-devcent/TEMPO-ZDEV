CLASS zihqmr006_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tt_budat TYPE RANGE OF budat,
           tt_werks TYPE RANGE OF werks_d,
           tt_matnr TYPE RANGE OF matnr,
           tt_lifnr TYPE RANGE OF lifnr.
    METHODS: validate_screen_1000
        IMPORTING matnr TYPE tt_matnr
                  lifnr TYPE tt_lifnr
        RETURNING VALUE(va_error) TYPE i.
    METHODS: run
    IMPORTING so_budat TYPE tt_budat
              so_werks TYPE tt_werks
              so_matnr TYPE tt_matnr
              so_lifnr TYPE tt_lifnr
              lv_program TYPE sy-cprog
              title_name TYPE sy-title
              id         TYPE sy-sysid
              mandt      TYPE sy-mandt
              datum      TYPE sy-datum
              username   TYPE sy-uname
              uzeit      TYPE sy-uzeit.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zihqmr006_class IMPLEMENTATION.
    METHOD run.
    DATA(lo_obj) = NEW lcl_zihqmr006( so_budat = so_budat[] so_werks = so_werks[] so_matnr = so_matnr[] so_lifnr = so_lifnr[] ).
    lo_obj->run( lv_program = lv_program title_name = title_name datum = datum id = id mandt = mandt username = username uzeit = uzeit ).
    ENDMETHOD.
    METHOD validate_screen_1000.
      IF matnr[] IS INITIAL AND
     lifnr[] IS INITIAL.
        va_error  = 1.
        MESSAGE 'Material atau Vendor harus diisi' TYPE 'E'.
      ELSE.
        CLEAR: va_error.
      ENDIF.
    ENDMETHOD.
ENDCLASS.
