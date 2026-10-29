*&---------------------------------------------------------------------*
*&  Include           ZACCPP_E004_V3XTOP
*&---------------------------------------------------------------------*
TABLES : s501, zaccdtm, sscrfields, t001w.

TYPE-POOLS : swww.

CLASS : lcl_application DEFINITION DEFERRED.

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

TYPES : BEGIN OF ty_items,
            id              TYPE string,
            alamat_rekanan  TYPE string,
            no_telp         TYPE string,
            fax             TYPE string,
            latitude        TYPE string,
            longitude       TYPE string,
            is_default      TYPE string,
          END OF ty_items.

TYPES : BEGIN OF ty_ittujuan,
            id              TYPE string,
            nama_sarana     TYPE string,
            alamat          TYPE string,
            status          TYPE string,
          END OF ty_ittujuan.

TYPES : BEGIN OF ty_sarana,
          status          TYPE string,
          statuscode      TYPE string,
          message         TYPE string,
          total           TYPE string,
          offset          TYPE string,
          limit           TYPE string,
          items           TYPE STANDARD TABLE OF ty_items WITH NON-UNIQUE DEFAULT KEY,
        END OF ty_sarana.

TYPES : BEGIN OF ty_itproduct,
            primer          TYPE string,
            nie             TYPE string,
            batch_no        TYPE string,
            skunder         TYPE string,
            tersier         TYPE string,
          END OF ty_itproduct.

TYPES : BEGIN OF ty_tujuan,
          status          TYPE string,
          statuscode      TYPE string,
          message         TYPE string,
          total           TYPE string,
          offset          TYPE string,
          limit           TYPE string,
          items           TYPE STANDARD TABLE OF ty_ittujuan WITH NON-UNIQUE DEFAULT KEY,
        END OF ty_tujuan.

TYPES : BEGIN OF ty_product,
          status          TYPE string,
          statuscode      TYPE string,
          message         TYPE string,
          total           TYPE string,
          offset          TYPE string,
          limit           TYPE string,
          items           TYPE STANDARD TABLE OF ty_itproduct WITH NON-UNIQUE DEFAULT KEY,
        END OF ty_product.

TYPES : BEGIN OF ty_error,
          process(30),
          statuscode(10),
          message       TYPE sbcheader-header,
        END OF ty_error.

TYPES : BEGIN OF ty_response,
          status           TYPE string,
          statuscode       TYPE string,
          message          TYPE string,
          data             TYPE string,
        END OF ty_response.

TYPES : BEGIN OF ty_barcode,
          barcode   TYPE string,
        END OF ty_barcode.

CONSTANTS co_lines         TYPE i VALUE 1500.

DATA : gt_zaccdtu          TYPE STANDARD TABLE OF zaccdtu,
       gt_items            TYPE STANDARD TABLE OF ty_items,
       gt_tujuan           TYPE STANDARD TABLE OF ty_ittujuan,
       gt_product          TYPE STANDARD TABLE OF ty_itproduct,
       gs_sarana           TYPE ty_sarana,
       gs_tujuan           TYPE ty_tujuan,
       gs_product          TYPE ty_product,
       dfies_tab           TYPE STANDARD TABLE OF dfies.

DATA : gt_request_header   TYPE TABLE OF sbcheader WITH HEADER LINE,
       gt_request_body     TYPE TABLE OF sbcbody WITH HEADER LINE,
       gt_response_header  TYPE TABLE OF sbcheader WITH HEADER LINE,
       gt_response_body    TYPE TABLE OF sbcbody WITH HEADER LINE.

DATA : gt_merge            TYPE swww_t_merge_table,
       xml                 TYPE xstring.

DATA : status_code(5),
       status_text(300),
       len TYPE i.

DATA : gv_token             TYPE string,
       gv_idsarana          TYPE string,
       gv_error             TYPE sy-subrc,
       gv_autho.

DATA : gt_s501              TYPE STANDARD TABLE OF s501,
       gt_zaccdta           TYPE STANDARD TABLE OF zaccdta,
       gt_zaccdtd           TYPE STANDARD TABLE OF zaccdtd,
       gt_zaccdtm           TYPE STANDARD TABLE OF zaccdtm,
       gt_tersier           TYPE STANDARD TABLE OF zaccdta,
       gt_sekunder          TYPE STANDARD TABLE OF zaccdta,
       gt_ztspmmdt002       TYPE STANDARD TABLE OF ztspmmdt002,
       gt_mch1              TYPE STANDARD TABLE OF mch1,
       gt_error             TYPE STANDARD TABLE OF ty_error,
       gt_barcode           TYPE STANDARD TABLE OF ty_barcode.

DATA : gr_docat             TYPE RANGE OF s501-docat,
       gr_stbpom            TYPE RANGE OF s501-stbpom.

DATA : gv_repid             TYPE sy-repid.

DATA : ok_code              TYPE sy-ucomm,
       gs_exclude           TYPE ui_functions,
       g_content            TYPE REF TO cl_salv_form_element,
       g_customcont         TYPE REF TO cl_gui_custom_container,
       g_splitter           TYPE REF TO cl_gui_splitter_container,
       g_contain            TYPE REF TO cl_gui_container,
       g_tabgrid            TYPE REF TO cl_gui_alv_grid,
       g_updgrid            TYPE REF TO cl_gui_alv_grid,
       event_receiver       TYPE REF TO lcl_application,
       selected             VALUE 'X',
       gs_stable            TYPE lvc_s_stbl,
       gt_main_fieldcat     TYPE lvc_t_fcat,
       gs_layout_alv        TYPE lvc_s_layo,
       g_handle_alv         TYPE i,
       gt_main_sort         TYPE lvc_t_sort WITH HEADER LINE,
       gs_variant           LIKE disvariant,
       gs_toolbar           TYPE stb_button.

FIELD-SYMBOLS : <fs_tab>      TYPE STANDARD TABLE,
                <fs_gs>       TYPE ANY.
