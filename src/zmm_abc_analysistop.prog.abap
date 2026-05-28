*&---------------------------------------------------------------------*
*&  Include           ZMM_ABC_ANALYSISTOP
*&---------------------------------------------------------------------*
TABLES : t001w, marc, prodhs, sscrfields, tvbur.

CLASS : lcl_application DEFINITION DEFERRED.

DATA : gv_lines   TYPE i.

DATA : gt_string  TYPE zstrty,
       gs_string  TYPE zstrst.

DATA : gt_tvkol   TYPE STANDARD TABLE OF tvkol,
       gt_zplbc   TYPE STANDARD TABLE OF zplbc,
       gt_tvkbz   TYPE STANDARD TABLE OF tvkbz,
       gt_tvkbt   TYPE STANDARD TABLE OF tvkbt.

DATA : BEGIN OF gt_marc OCCURS 1,
         matnr    LIKE marc-matnr,
         werks    LIKE marc-werks,
         lvorm    LIKE marc-lvorm,
         maabc    LIKE marc-maabc,
         matkl    LIKE mara-matkl,
         meins    LIKE mara-meins,
         zeinr    LIKE mara-zeinr,
       END OF gt_marc.

DATA : BEGIN OF gt_makt OCCURS 1,
         matnr    LIKE makt-matnr,
         maktx    LIKE makt-maktx,
         matkl    LIKE mara-matkl,
       END OF gt_makt.

DATA :  BEGIN OF i_a890 OCCURS 0.
        INCLUDE STRUCTURE a890.
DATA :    werks TYPE werks_d,
        END OF i_a890.

DATA : BEGIN OF gt_sac7 OCCURS 1,
         bukrs    LIKE zplbc-bukrs,
         matnr    LIKE mara-matnr,
         vkbur    LIKE zmmtsar-vkbur,
         werks    LIKE zmmtsar-werks,
         reswk    LIKE zplbc-reswk,
         prodh1   TYPE zprodh1,
         prodh2   TYPE zprodh2,
         prodh3   TYPE zprodh3,
         x1	      TYPE mc_ummenge,
         x2	      TYPE mc_ummenge,
         x3	      TYPE mc_ummenge,
         x4	      TYPE mc_ummenge,
         x5	      TYPE mc_ummenge,
         x6	      TYPE mc_ummenge,
         zeinr    LIKE mara-zeinr,
         peran    LIKE prop-peran,
         avgsls   LIKE s912-zavg_sls,
         avqty(17),
         avamt(17),
         bretl(13).
DATA : END OF gt_sac7.

DATA : BEGIN OF gt_varavg OCCURS 0.
        INCLUDE STRUCTURE zssac7_vavgsls.
DATA :   prodh1(5),
         prodh2(5),
         prodh3(8),
       END OF gt_varavg.

DATA : BEGIN OF gt_out OCCURS 0,
         vkbur      LIKE tvbur-vkbur,
         bezei      LIKE tvkbt-bezei,
         werks      LIKE marc-werks,
         qtytl      TYPE p DECIMALS 2,
         amttl      TYPE p DECIMALS 2,
         matnr      LIKE mara-matnr,
         maktx      LIKE makt-maktx,
         matkl      LIKE mara-matkl,
         maabc      LIKE marc-maabc,
         maabc_new  LIKE marc-maabc,
         cumpro(22),
       END OF gt_out.
DATA : gt_out1  LIKE gt_out OCCURS 0 WITH HEADER LINE.

DATA : ok_code      TYPE sy-ucomm,
       gv_repid     TYPE sy-repid,
       gs_variant   LIKE disvariant,
       gv_dynnr     TYPE sy-dynnr,
       selected     VALUE 'X',
       gv_werks     LIKE marc-werks,
       gv_vkbur     LIKE tvbur-vkbur,
       gv_bezei     LIKE tvkbt-bezei,
       gv_matnr     LIKE marc-matnr,
       gv_match     TYPE mara-matnr,
       gv_maabc     LIKE marc-maabc,
       gv_plant(100),
       gv_date(100),
       gv_title(100),
       gv_subrc     TYPE sy-subrc.

DATA : event_receiver       TYPE REF TO lcl_application,
       gs_exclude           TYPE ui_functions,
       g_custom_container   TYPE REF TO cl_gui_custom_container,
       g_splitter           TYPE REF TO cl_gui_splitter_container,
       g_container          TYPE REF TO cl_gui_container,
       g_custom_container1  TYPE REF TO cl_gui_custom_container,
       g_splitter1          TYPE REF TO cl_gui_splitter_container,
       g_container1         TYPE REF TO cl_gui_container,
       gt_fieldcat          TYPE lvc_t_fcat,
       gs_layout_alv        TYPE lvc_s_layo,
       g_grid               TYPE REF TO cl_gui_alv_grid,
       g_grid1              TYPE REF TO cl_gui_alv_grid,
       gt_sort_grid         TYPE lvc_t_sort WITH HEADER LINE.

DATA : wertetab             TYPE STANDARD TABLE OF bco_werte.
