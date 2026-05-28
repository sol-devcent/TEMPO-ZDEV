*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP
*
*----------------------------------------------------------------------*
INCLUDE <icon>.

TABLES: s940,  mard, mara, marc, s603, knvv, t001w, tvbur, sscrfields.

CLASS lcl_application DEFINITION DEFERRED.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
CONSTANTS : co_vrsio  LIKE s940-vrsio VALUE '000',
            co_sptag  LIKE s940-sptag VALUE '00000000',
            co_spwoc  LIKE s940-spwoc VALUE '000000',
            co_spbup  LIKE s940-spbup VALUE '000000',
            co_konob  LIKE s940-konob VALUE 'PER_MAT',
            co_vtweg  LIKE s940-vtweg VALUE '10',
            co_kvgr5  LIKE s940-kvgr5 VALUE 'KA'.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
TYPES: BEGIN OF t_kunnr,
           vkbur LIKE knvv-vkbur,
           kunnr LIKE knvv-kunnr,
           kvgr5 LIKE knvv-kvgr5,
       END OF t_kunnr,
       BEGIN OF t_vkbur,
           vkbur LIKE tvbur-vkbur,
       END OF t_vkbur,
       BEGIN OF t_mard,
           matnr LIKE mard-matnr,
           werks LIKE mard-werks,
           lgort LIKE mard-lgort,
           labst LIKE mard-labst,
           vkbur LIKE knvv-vkbur,
       END OF t_mard,
       BEGIN OF t_s603,
           spmon LIKE s603-spmon,
           pkunwe LIKE s603-pkunwe,
           vkbur  LIKE s603-vkbur,
           matnr  LIKE s603-matnr,
           ummenge LIKE s603-ummenge,  "Qty Sales
           gumenge LIKE s603-gumenge,  "Qty CN
           basme   LIKE s603-basme,
       END OF t_s603,
       BEGIN OF t_average,
           vkbur LIKE s603-vkbur,
           matnr LIKE s603-matnr,
           netqty LIKE s603-ummenge,
           basme LIKE s603-basme,
           perio  TYPE i,
       END OF t_average,
       BEGIN OF t_s940e,
           matnr LIKE s940e-matnr,
       END OF t_s940e,
       BEGIN OF t_s940.
        INCLUDE STRUCTURE s940.
TYPES: END OF t_s940.

RANGES: r_vkbur FOR knvv-vkbur.
RANGES: r_kunnr FOR knvv-kunnr.
RANGES: r_spmon FOR s940-spmon.

DATA: bobot(3) TYPE n,
      i_kunnr TYPE t_kunnr OCCURS 0,
      wa_kunnr TYPE t_kunnr,
      i_mard TYPE t_mard OCCURS 0,
      wa_mard TYPE t_mard,
      i_s603 TYPE t_s603 OCCURS 0,
      wa_s603 TYPE t_s603,
      i_vkbur TYPE t_vkbur OCCURS 0,
      wa_vkbur TYPE t_vkbur,
      i_average TYPE t_average OCCURS 0,
      wa_average TYPE t_average,
      i_s940 TYPE t_s940 OCCURS 0,
      wa_s940 TYPE t_s940,
      i_s940e TYPE t_s940e OCCURS 0,
      wa_s940e TYPE t_s940e.
DATA: v_konob LIKE s940-konob VALUE 'PER_MAT',
      v_spmon   LIKE s940-spmon.
***** Define For ALV
DATA: ta_sort TYPE slis_t_sortinfo_alv.

DATA: "GT_OUTTAB type i_itab occurs 0,
      gs_layout TYPE slis_layout_alv,
      g_exit_caused_by_caller,
      gs_exit_caused_by_user TYPE slis_exit_by_user,
      g_repid LIKE sy-repid.

DATA:
    gt_events      TYPE slis_t_event,
    gt_list_top_of_page TYPE slis_t_listheader,
    xit_fieldcat   TYPE slis_t_fieldcat_alv,
    xis_print      TYPE slis_print_alv.
*"Variants
DATA: gs_variant LIKE disvariant,
      g_save.

DATA : BEGIN OF gt_excel OCCURS 0,
         row   TYPE kcd_ex_row_n,
         col   TYPE kcd_ex_col_n,
         value TYPE char50,
       END OF gt_excel.

DATA : BEGIN OF gt_upld OCCURS 0,
          spmon   LIKE s940-spmon,
          vkorg   LIKE s940-vkorg,
          werks   LIKE t001w-werks,
          lgort   LIKE t001l-lgort,
          matnr   LIKE s940-matnr,
          kcqty   LIKE s940-kcqty,
          basme   LIKE s940-basme,
          vkbur   LIKE s940-vkbur,
        END OF gt_upld.

DATA : BEGIN OF gt_out OCCURS 0.
         INCLUDE STRUCTURE s940.
DATA :   labst TYPE mard-labst,
       END OF gt_out.

DATA : gt_s940  TYPE STANDARD TABLE OF s940,
       gt_mard  TYPE STANDARD TABLE OF mard,
       gt_vbbe  TYPE STANDARD TABLE OF vbbe,
*       gt_out   TYPE STANDARD TABLE OF s940,
       wa_vbbe  TYPE vbbe.

DATA : gv_repid              TYPE sy-repid,
       ok_code               TYPE sy-ucomm,
       g_outcont             TYPE REF TO cl_gui_custom_container,
       g_splitter            TYPE REF TO cl_gui_splitter_container,
       g_container           TYPE REF TO cl_gui_container,
       g_outgrid             TYPE REF TO cl_gui_alv_grid,
       gs_exclude            TYPE ui_functions,
       event_receiver        TYPE REF TO lcl_application,
       selected              VALUE 'X',
       gs_layout_alv         TYPE lvc_s_layo,
       gt_sort_grid          TYPE lvc_t_sort WITH HEADER LINE,
       gt_fieldcat           TYPE lvc_t_fcat,
       gs_stable             TYPE lvc_s_stbl,
       gs_toolbar            TYPE stb_button.

DATA : gv_subrc   TYPE sy-subrc.
DATA : gv_message TYPE char100.
