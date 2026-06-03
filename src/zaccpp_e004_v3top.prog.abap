*&---------------------------------------------------------------------*
*&  Include           ZACCPP_E004_V3TOP
*&---------------------------------------------------------------------*
TABLES : s501, zaccdtm, sscrfields.

CONSTANTS co_lines      TYPE i VALUE 1500.

CLASS : lcl_application DEFINITION DEFERRED.

TYPES : BEGIN OF ty_response,
          status          TYPE string,
          statuscode      TYPE string,
          message         TYPE string,
          data            TYPE string,
        END OF ty_response.

TYPES : BEGIN OF ty_sarana1,
          id              TYPE string,
          nama_sarana     TYPE string,
          alamat          TYPE string,
        END OF ty_sarana1.

TYPES : BEGIN OF ty_sarana2,
          id              TYPE string,
          alamat_rekanan  TYPE string,
          no_telp         TYPE string,
          fax             TYPE string,
          latitude        TYPE string,
          longitude       TYPE string,
          is_default      TYPE string,
        END OF ty_sarana2.

TYPES : BEGIN OF ty_addlokasi,
          alamat          TYPE string,
          no_telp         TYPE string,
          fax             TYPE string,
          latitude        TYPE string,
          longitude       TYPE string,
        END OF ty_addlokasi.

TYPES : BEGIN OF ty_tujuan,
          status          TYPE string,
          statuscode      TYPE string,
          message         TYPE string,
          total           TYPE string,
          offset          TYPE string,
          limit           TYPE string,
          items           TYPE STANDARD TABLE OF ty_sarana1 WITH NON-UNIQUE DEFAULT KEY,
        END OF ty_tujuan.

TYPES : BEGIN OF ty_lokasi,
          status          TYPE string,
          statuscode      TYPE string,
          message         TYPE string,
          total           TYPE string,
          offset          TYPE string,
          limit           TYPE string,
          items           TYPE STANDARD TABLE OF ty_sarana2 WITH NON-UNIQUE DEFAULT KEY,
        END OF ty_lokasi.

TYPES : BEGIN OF ty_role,
          status          TYPE string,
          statuscode      TYPE string,
          message         TYPE string,
          role            TYPE string,
          id_u            TYPE string,
          id_rekanan      TYPE string,
          name            TYPE string,
          phone           TYPE string,
          email           TYPE string,
          token           TYPE string,
          remember_token  TYPE string,
          created_at_u    TYPE string,
          updated_at_u    TYPE string,
          deleted_u       TYPE string,
          status_u        TYPE string,
          verified        TYPE string,
          master          TYPE string,
          subaccount      TYPE string,
          id_s            TYPE string,
          id_group        TYPE string,
          nama_rekanan    TYPE string,
          alamat_rekanan  TYPE string,
          no_telp         TYPE string,
          fax             TYPE string,
          provinsi        TYPE string,
          kota            TYPE string,
          latitude        TYPE string,
          longitude       TYPE string,
          status_s        TYPE string,
          logo_rekanan    TYPE string,
          created_at_s    TYPE string,
          updated_at_s    TYPE string,
          deleted_s       TYPE string,
          file_dokumen    TYPE string,
          badan_usaha     TYPE string,
          npwp            TYPE string,
        END OF ty_role.

TYPES : BEGIN OF ty_zaccdta.
        INCLUDE STRUCTURE zaccdta.
TYPES :   check,
        END OF ty_zaccdta.

TYPES : BEGIN OF ty_zaccdtm.
        INCLUDE STRUCTURE zaccdtm.
TYPES :   aggr1   TYPE zaccdta-aggr1,
          check,
        END OF ty_zaccdtm.

TYPES : BEGIN OF ty_error,
          description(20),
          process(30),
          response  TYPE sbcheader-header,
        END OF ty_error.

DATA : status_code(5),
       status_text(300),
       len TYPE i.

DATA : gt_request_header   TYPE TABLE OF sbcheader WITH HEADER LINE,
       gt_request_body     TYPE TABLE OF sbcbody WITH HEADER LINE,
       gt_response_header  TYPE TABLE OF sbcheader WITH HEADER LINE,
       gt_response_body    TYPE TABLE OF sbcbody WITH HEADER LINE.

DATA : gt_zaccdtu          TYPE STANDARD TABLE OF zaccdtu,
       gt_s501             TYPE STANDARD TABLE OF s501,
       gt_zaccdta          TYPE STANDARD TABLE OF zaccdta,
       gt_zaccdtd          TYPE STANDARD TABLE OF zaccdtd,
       gt_zaccdtm          TYPE STANDARD TABLE OF zaccdtm,
       gt_ztspmmdt002      TYPE STANDARD TABLE OF ztspmmdt002,
       gt_mch1             TYPE STANDARD TABLE OF mch1,
       gt_error            TYPE STANDARD TABLE OF ty_error,
       gt_tujuan           TYPE STANDARD TABLE OF ty_sarana1,
       gt_lokasi           TYPE STANDARD TABLE OF ty_sarana2.

DATA : gt_primer           TYPE STANDARD TABLE OF zaccdta,
       gt_sekunder         TYPE STANDARD TABLE OF zaccdta,
       gt_tersier          TYPE STANDARD TABLE OF zaccdta.

DATA : gs_tujuan           TYPE ty_tujuan,
       gs_lokasi           TYPE ty_lokasi,
       gs_zaccdtl          TYPE zaccdtl.

DATA : gv_token            TYPE string,
       gv_idsarana         TYPE string,
       gv_error            TYPE sy-subrc,
       gv_concat,
       gv_default.

DATA : gt_sarana1          TYPE STANDARD TABLE OF ty_sarana1,
       gt_sarana2          TYPE STANDARD TABLE OF ty_sarana2.

DATA : ok_code             TYPE sy-ucomm,
       dynlog              TYPE smp_dyntxt,
       gs_exclude          TYPE ui_functions,
       g_customcont        TYPE REF TO cl_gui_custom_container,
       g_splitter          TYPE REF TO cl_gui_splitter_container,
       g_splitter1         TYPE REF TO cl_gui_splitter_container,
       g_contain01         TYPE REF TO cl_gui_container,
       g_contain02         TYPE REF TO cl_gui_container,
       g_contain03         TYPE REF TO cl_gui_container,
       g_contain04         TYPE REF TO cl_gui_container,
       g_tabgrid           TYPE REF TO cl_gui_alv_grid,
       event_receiver      TYPE REF TO lcl_application,
       selected            VALUE 'X',
       gv_repid            LIKE sy-repid,
       gs_variant          LIKE disvariant,
       gs_layout_alv       TYPE lvc_s_layo,
       gt_main_sort        TYPE lvc_t_sort WITH HEADER LINE,
       gt_main_fieldcat    TYPE lvc_t_fcat,
       gs_stable           TYPE lvc_s_stbl,
       gs_toolbar          TYPE stb_button,
       gr_hierseq          TYPE REF TO cl_salv_hierseq_table,
       gr_table            TYPE REF TO cl_salv_table,
       g_handle_alv        TYPE i,
       gt_bapiret2         TYPE STANDARD TABLE OF bapiret2.

FIELD-SYMBOLS : <fs_tout>   TYPE STANDARD TABLE,
                <fs_sout>   TYPE ANY.
