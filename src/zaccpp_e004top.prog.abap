*&---------------------------------------------------------------------*
*&  Include           ZACCPP_E004TOP
*&---------------------------------------------------------------------*
TABLES : sscrfields, zaccdtm, s501.

CLASS : lcl_application DEFINITION DEFERRED.

TYPES : BEGIN OF ty_sarana,
          id              TYPE string,
          id_group        TYPE string,
          nama_rekanan    TYPE string,
          alamat_rekanan  TYPE string,
          no_telp         TYPE string,
          fax             TYPE string,
          provinsi        TYPE string,
          kota            TYPE string,
          latitude        TYPE string,
          longitude       TYPE string,
          status          TYPE string,
          logo_rekanan    TYPE string,
          created_at      TYPE string,
          updated_at      TYPE string,
          deleted         TYPE string,
          file_dokumen    TYPE string,
          badan_usaha     TYPE string,
          npwp            TYPE string,
          id_parent       TYPE string,
        END OF ty_sarana.

TYPES : BEGIN OF ty_user,
          id              TYPE string,
          id_rekanan      TYPE string,
          name            TYPE string,
          phone           TYPE string,
          email           TYPE string,
          token           TYPE string,
          remember_token  TYPE string,
          created_at      TYPE string,
          updated_at      TYPE string,
          deleted         TYPE string,
          status          TYPE string,
          verified        TYPE string,
          sarana          TYPE STANDARD TABLE OF ty_sarana WITH NON-UNIQUE DEFAULT KEY,
        END OF ty_user.

TYPES : BEGIN OF ty_role,
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

TYPES : BEGIN OF ty_zaccdtm.
        INCLUDE STRUCTURE zv_accdtm.
TYPES : check,
        END OF ty_zaccdtm.

TYPES : BEGIN OF ty_zaccdtd.
        INCLUDE STRUCTURE zaccdtd.
TYPES : check,
        END OF ty_zaccdtd.

TYPES : BEGIN OF ty_zaccdta.
        INCLUDE STRUCTURE zaccdta.
TYPES : check,
        END OF ty_zaccdta.

DATA : gv_repid             LIKE sy-repid,
       ok_code              TYPE sy-ucomm,
       gs_exclude_t         TYPE ui_functions,
       gs_exclude_b         TYPE ui_functions,
       g_content            TYPE REF TO cl_salv_form_element,
       g_maincont           TYPE REF TO cl_gui_custom_container,
       g_splitter           TYPE REF TO cl_gui_splitter_container,
       g_top                TYPE REF TO cl_gui_container,
       g_bottom             TYPE REF TO cl_gui_container,
       g_tgrid              TYPE REF TO cl_gui_alv_grid,
       g_bgrid              TYPE REF TO cl_gui_alv_grid,
       event_receiver       TYPE REF TO lcl_application,
       selected             VALUE 'X',
       gs_stable            TYPE lvc_s_stbl,
       gt_fieldcat_t        TYPE lvc_t_fcat,
       gt_fieldcat_b        TYPE lvc_t_fcat,
       gs_layout_alv        TYPE lvc_s_layo,
       g_handle_alv         TYPE i,
       gt_main_sort         TYPE lvc_t_sort WITH HEADER LINE,
       gs_variant           LIKE disvariant,
       gs_toolbar           TYPE stb_button.

FIELD-SYMBOLS : <fs_top>        TYPE STANDARD TABLE,
                <fs_bottom>     TYPE STANDARD TABLE,
                <fs_ltop>       TYPE ANY,
                <fs_lbottom>    TYPE ANY.

DATA : status_code(5),
       status_text(300),
       len TYPE i.

DATA : gt_request_header   TYPE TABLE OF sbcheader WITH HEADER LINE,
       gt_request_body     TYPE TABLE OF sbcbody WITH HEADER LINE,
       gt_response_header  TYPE TABLE OF sbcheader WITH HEADER LINE,
       gt_response_body    TYPE TABLE OF sbcbody WITH HEADER LINE.

DATA : gv_token(100),
       gv_login      TYPE zaccdtu-uri,
       gv_uri        TYPE zaccdtu-uri,
       gv_proxy      TYPE zaccdtu-proxy,
       gv_logproxy   TYPE zaccdtu-proxy,
       gv_error      TYPE sy-subrc.

DATA : gs_role          TYPE ty_role,
       gt_sarana        TYPE STANDARD TABLE OF ty_sarana.

DATA : gt_s501          TYPE STANDARD TABLE OF s501,
       gt_zaccdtd       TYPE STANDARD TABLE OF ty_zaccdtd,
       gt_zaccdtm       TYPE STANDARD TABLE OF ty_zaccdtm,
       gt_zaccdta       TYPE STANDARD TABLE OF ty_zaccdta,
       gt_zaccdtu       TYPE STANDARD TABLE OF zaccdtu,
       gt_ztspmmdt002   TYPE STANDARD TABLE OF ztspmmdt002,
       gt_likp          TYPE STANDARD TABLE OF likp,
       gt_kna1          TYPE STANDARD TABLE OF kna1,
       gt_mch1          TYPE STANDARD TABLE OF mch1.

CONSTANTS co_lines      TYPE i VALUE 1500.
