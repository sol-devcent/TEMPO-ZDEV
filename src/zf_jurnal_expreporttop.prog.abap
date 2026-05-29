*&---------------------------------------------------------------------*
*&  Include           ZF_JURNAL_EXPREPORTTOP
*&---------------------------------------------------------------------*
TABLES : sscrfields, tvbur, zf63gtype, zf63masterperson,
         zf63masterkend, zf63trnvch, zf63trnhdr2.

CLASS : lcl_application DEFINITION DEFERRED.

TYPES : BEGIN OF ty_column,
          col       TYPE i,
          length    TYPE i,
          fieldname(30),
          datatype  TYPE dfies-datatype,
          header1   TYPE string,
          header2   TYPE string,
          header3   TYPE string,
          header4   TYPE string,
          header5   TYPE string,
          header6   TYPE string,
          total1,
          total2,
          noout,
        END OF ty_column.

TYPES : BEGIN OF ty_gtype,
          gtype         TYPE zf63gtype-gtype,
          description   TYPE zf63gtype-description,
        END OF ty_gtype.

TYPES : BEGIN OF ty_selec,
          gtype   TYPE zf63gtype-gtype,
          vkbur   TYPE tvbur-vkbur,
        END OF ty_selec.

TYPES : BEGIN OF ty_lines,
          objnr1     TYPE string,
          objnr2     TYPE string,
          gtype      TYPE zf63trnhdr2-gtype,
          vkbur      TYPE zf63trnhdr2-vkbur,
          budatpexp  TYPE zf63trnhdr2-budatpexp,
          zidno      TYPE zf63trnhdr2-zidno,
          zidvc      TYPE zf63trnhdr2-zidvc,
          znopol     TYPE zf63trndtl2-znopol,
          kostl      TYPE zf63trndtl2-kostl,
          wwsfr      TYPE zf63trndtl2-wwsfr,
          wwpos      TYPE zf63trndtl2-wwpos,
          tknum      TYPE zf63trnshp2-tknum,
          erdat      TYPE zf63trnshp2-erdat,
        END OF ty_lines.

TYPES : BEGIN OF ty_head.
        INCLUDE STRUCTURE zfstexphdr2.
TYPES :  expand.
TYPES : END OF ty_head.

TYPES : BEGIN OF ty_detl.
        INCLUDE STRUCTURE zfstexpdtl2.
TYPES : END OF ty_detl.

DATA : gt_lines     TYPE STANDARD TABLE OF ty_lines.

DATA : dynpfields     TYPE STANDARD TABLE OF dynpread,
       gt_tab         TYPE STANDARD TABLE OF dfies,
       gt_column      TYPE STANDARD TABLE OF ty_column,
       gt_tvkbt       TYPE STANDARD TABLE OF tvkbt,
       gt_allgtype    TYPE STANDARD TABLE OF zf63gtype,
       gt_zf63gtype   TYPE STANDARD TABLE OF zf63gtype,
       gt_gtype       TYPE STANDARD TABLE OF ty_gtype,
       gt_trnhdr      TYPE STANDARD TABLE OF zf63trnhdr2,
       gt_trndtl      TYPE STANDARD TABLE OF zf63trndtl2,
       gt_trnshp      TYPE STANDARD TABLE OF zf63trnshp2,
       gt_atrnhdr     TYPE STANDARD TABLE OF zf63trnhdr2,
       gt_selec       TYPE STANDARD TABLE OF ty_selec,
       gt_selecpadv   TYPE STANDARD TABLE OF ty_selec,
       gt_selecpexp   TYPE STANDARD TABLE OF ty_selec,
       gt_out         TYPE STANDARD TABLE OF zfexpst01,
       gt_out1        TYPE STANDARD TABLE OF zfexpst02,
       gt_vttp        TYPE STANDARD TABLE OF vttp,
       gt_svttp       TYPE STANDARD TABLE OF vttp,
       gt_zmshphist   TYPE STANDARD TABLE OF zmshphist,
       gt_likp        TYPE STANDARD TABLE OF likp,
       gt_lips        TYPE STANDARD TABLE OF lips,
       gt_vbap        TYPE STANDARD TABLE OF vbap,
       gt_005         TYPE STANDARD TABLE OF zmsutdt005,
       gt_typedesc    TYPE STANDARD TABLE OF zf63tytpeexpdesc,
       gt_total1      TYPE STANDARD TABLE OF zfexpst01x,
       gt_total2      TYPE STANDARD TABLE OF zfexpst01x,
       gt_total3      TYPE STANDARD TABLE OF zfexpst01x,
       gt_total4      TYPE STANDARD TABLE OF zfexpst02x,
       gt_total5      TYPE STANDARD TABLE OF zfexpst02x,
       gt_total6      TYPE STANDARD TABLE OF zfexpst02x.

DATA : gt_mstper      TYPE STANDARD TABLE OF zf63masterperson,
       gt_mstken      TYPE STANDARD TABLE OF zf63masterkend.

DATA : gv_repid       TYPE sy-repid,
       r1             TYPE i,
       gs_out         LIKE LINE OF gt_out,
       gs_out1        LIKE LINE OF gt_out1,
       gr_reason      TYPE RANGE OF zreason2,
       gr_zidno       TYPE RANGE OF zidno,
       gr_nopol       TYPE RANGE OF znopolisi.

DATA : dfies_tab      TYPE STANDARD TABLE OF dfies,
       gt_error       TYPE STANDARD TABLE OF bapiret2.

FIELD-SYMBOLS : <fs_tab>    TYPE STANDARD TABLE,
                <fs_gt>     TYPE STANDARD TABLE,
                <fs_gs>     TYPE ANY,
                <fs>        TYPE ANY.

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

DATA : gt_head              TYPE STANDARD TABLE OF ty_head,
       gt_detl              TYPE STANDARD TABLE OF ty_detl,
       gr_hierseq           TYPE REF TO cl_salv_hierseq_table.
