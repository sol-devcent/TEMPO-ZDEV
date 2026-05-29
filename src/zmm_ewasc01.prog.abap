*&---------------------------------------------------------------------*
*&  Include           ZMM_EWASC01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS lcl_output DEFINITION CREATE PRIVATE
*----------------------------------------------------------------------*
CLASS lcl_output DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS :
      output         IMPORTING cl_excel            TYPE REF TO zcl_excel
                               iv_writerclass_name TYPE clike OPTIONAL.

    DATA : xdata      TYPE xstring,
           t_rawdata  TYPE solix_tab,
           bytecount  TYPE i.

  PRIVATE SECTION.
    METHODS :
      display_online.

ENDCLASS.                    "lcl_output DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_output IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_output IMPLEMENTATION.
  METHOD output.
    DATA: cl_output TYPE REF TO lcl_output,
          cl_writer TYPE REF TO zif_excel_writer.

    IF iv_writerclass_name IS INITIAL.
      CREATE OBJECT cl_output.
      CREATE OBJECT cl_writer TYPE zcl_excel_writer_2007.
    ELSE.
      CREATE OBJECT cl_output.
      CREATE OBJECT cl_writer TYPE (iv_writerclass_name).
    ENDIF.
    cl_output->xdata = cl_writer->write_file( cl_excel ).

    cl_output->t_rawdata = zcl_bcs_convert=>xstring_to_solix( iv_xstring  = cl_output->xdata ).
    cl_output->bytecount = XSTRLEN( cl_output->xdata ).

    IF sy-batch IS INITIAL.
      cl_output->display_online( ).
    ELSE.
      MESSAGE e001(00) WITH 'Online display absurd in background processing'.
    ENDIF.
  ENDMETHOD.                    "output

  METHOD display_online.
    DATA : error       TYPE REF TO i_oi_error,
           t_errors    TYPE STANDARD TABLE OF REF TO i_oi_error WITH NON-UNIQUE DEFAULT KEY,
           cl_control  TYPE REF TO i_oi_container_control,
           cl_document TYPE REF TO i_oi_document_proxy.

    c_oi_container_control_creator=>get_container_control( IMPORTING control = cl_control
                                                                     error   = error ).
    APPEND error TO t_errors.

    cl_control->init_control( EXPORTING  inplace_enabled     = 'X'
                                         no_flush            = 'X'
                                         r3_application_name = 'Demo Document Container'
                                         parent              = cl_gui_container=>screen0
                              IMPORTING  error               = error
                              EXCEPTIONS OTHERS              = 2 ).
    APPEND error TO t_errors.

    cl_control->get_document_proxy( EXPORTING document_type  = 'Excel.Sheet'                " EXCEL
                                              no_flush       = ' '
                                    IMPORTING document_proxy = cl_document
                                              error          = error ).
    APPEND error TO t_errors.

    cl_document->open_document_from_table( EXPORTING document_size    = bytecount
                                                     document_table   = t_rawdata
                                                     open_inplace     = 'X' ).

    WRITE : '.'.
  ENDMETHOD.                    "display_online
ENDCLASS.                    "lcl_output IMPLEMENTATION
