*&---------------------------------------------------------------------*
*&  Include           ZTDS_RTMPTOP
*&---------------------------------------------------------------------*
TABLES : vbak, bsid, sscrfields, zfidt011.

TYPES : BEGIN OF ty_filter,
          index TYPE sy-tabix,
        END OF ty_filter.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4),
          bukrs   TYPE zfidt010-bukrs,
          vkbur   TYPE zfidt010-vkbur,
          vbeva   TYPE zfidt010-vbeva,
          vbevl   TYPE likp-vbeln,
          belnr   TYPE bsid-belnr,
          kunnr   TYPE zfidt010-kunnr,
          name1   TYPE kna1-name1,
          waers   TYPE bsid-waers,
          dnbtr   TYPE bsid-dmbtr,
          umbtr   TYPE zfidt010-dmbtr,
          titipan TYPE bsid-dmbtr,
          selisih TYPE bsid-dmbtr,
          clrnr   TYPE bsid-belnr,
          ttpnr   TYPE bsid-belnr,
          selnr   TYPE bsid-belnr,
          gjahr   TYPE bsid-gjahr,
          webno   TYPE zfidt011-webno,
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_out.

TYPES : BEGIN OF ty_post,
          buzei TYPE bseg-buzei,
          bschl TYPE bseg-bschl,
          umskz TYPE bseg-umskz,
          konto TYPE rfpsd-konto,
          ktext TYPE rfpsd-ktext,
          wrbtr TYPE bseg-wrbtr,
          kostl TYPE bseg-kostl,
          gsber TYPE bseg-gsber,
          zuonr TYPE bseg-zuonr,
          sgtxt TYPE bseg-sgtxt,
        END OF ty_post.

TYPES : BEGIN OF ty_report,
          bukrs TYPE zfidt012-bukrs,
          vkbur TYPE zfidt012-vkbur,
          webno TYPE zfidt012-webno,
          gjahr TYPE zfidt012-gjahr,
          kunnr TYPE zfidt012-kunnr,
          name1 TYPE kna1-name1,
          vbevl TYPE zfidt012-vbevl,
          vbeva TYPE zfidt012-vbeva,
          vbevf TYPE zfidt012-vbevf,
          dnbtr TYPE zfidt012-dnbtr,
          umbtr TYPE zfidt012-umbtr,
          tpbtr TYPE zfidt012-tpbtr,
          slbtr TYPE zfidt012-slbtr,
          waers TYPE zfidt012-waers,
          clrnr TYPE zfidt011-belnr,
          ttpnr TYPE zfidt011-belnr,
          selnr TYPE zfidt011-belnr,
          budat TYPE zfidt011-budat,
          usnam TYPE zfidt011-usnam,
          cpudt TYPE zfidt011-cpudt,
          cputm TYPE zfidt011-cputm,
        END OF ty_report.

TYPES : BEGIN OF ty_reverse,
          bukrs TYPE zfidt011-bukrs,
          vkbur TYPE zfidt011-vkbur,
          webno TYPE zfidt011-webno,
          belnr TYPE zfidt011-belnr,
          gjahr TYPE zfidt011-gjahr,
          clrst TYPE zfidt011-clrst,
          hkont TYPE zfidt011-hkont,
          dmbtr TYPE zfidt011-dmbtr,
          waers TYPE zfidt011-waers,
          xblnr TYPE zfidt011-xblnr,
          budat TYPE zfidt011-budat,
        END OF ty_reverse.

TYPES : BEGIN OF ty_bkpf,
          bukrs TYPE bkpf-bukrs,
          belnr TYPE bkpf-belnr,
          gjahr TYPE bkpf-gjahr,
          budat TYPE bkpf-budat,
        END OF ty_bkpf.

TYPES : BEGIN OF ty_bseg,
          bukrs TYPE bseg-bukrs,
          belnr TYPE bseg-belnr,
          gjahr TYPE bseg-gjahr,
          buzei TYPE bseg-buzei,
          shkzg TYPE bseg-shkzg,
          dmbtr TYPE bseg-dmbtr,
          wrbtr TYPE bseg-wrbtr,
          zuonr TYPE bseg-zuonr,
          kunnr TYPE bseg-kunnr,
        END OF ty_bseg.

TYPES : BEGIN OF ty_header,
          expand.
          INCLUDE STRUCTURE zfidt011.
          TYPES : keterangan(50).
TYPES : END OF ty_header.

TYPES : BEGIN OF ty_detail,
          expand,
          belnr  TYPE bseg-belnr.
          INCLUDE STRUCTURE zfidt012.
          TYPES : dmbtr  TYPE bseg-dmbtr.
TYPES : END OF ty_detail.

TYPES : BEGIN OF ty_error.
          INCLUDE STRUCTURE bapiret2.
          TYPES : vbeln TYPE likp-vbeln,
        END OF ty_error.

TYPES : BEGIN OF ty_soff,
          auart TYPE vbak-auart,
          vkorg TYPE vbak-vkorg,
          vkbur TYPE tvbur-vkbur,
        END OF ty_soff.

CLASS : lcl_application DEFINITION DEFERRED.

DATA : ok_code          TYPE sy-ucomm,
       dynlog           TYPE smp_dyntxt,
       gs_exclude       TYPE ui_functions,
       g_customcont     TYPE REF TO cl_gui_custom_container,
       g_splitter       TYPE REF TO cl_gui_splitter_container,
       g_splitter1      TYPE REF TO cl_gui_splitter_container,
       g_contain01      TYPE REF TO cl_gui_container,
       g_contain02      TYPE REF TO cl_gui_container,
       g_contain03      TYPE REF TO cl_gui_container,
       g_contain04      TYPE REF TO cl_gui_container,
       g_tabgrid        TYPE REF TO cl_gui_alv_grid,
       event_receiver   TYPE REF TO lcl_application,
       selected         VALUE 'X',
       gv_repid         LIKE sy-repid,
       gs_variant       LIKE disvariant,
       gs_layout_alv    TYPE lvc_s_layo,
       gt_main_sort     TYPE lvc_t_sort WITH HEADER LINE,
       gt_main_fieldcat TYPE lvc_t_fcat,
       gs_stable        TYPE lvc_s_stbl,
       gs_toolbar       TYPE stb_button,
       gr_hierseq       TYPE REF TO cl_salv_hierseq_table,
       gr_table         TYPE REF TO cl_salv_table,
       g_handle_alv     TYPE i,
       gt_bapiret2      TYPE STANDARD TABLE OF bapiret2,
       gt_filter        TYPE STANDARD TABLE OF ty_filter.

DATA : gt_tbsl     TYPE STANDARD TABLE OF tbsl,
       gt_bsid     TYPE STANDARD TABLE OF bsid,
       gt_lips     TYPE STANDARD TABLE OF lips,
       gt_010      TYPE STANDARD TABLE OF zfidt010,
       gt_011      TYPE STANDARD TABLE OF zfidt011,
       gt_012      TYPE STANDARD TABLE OF zfidt012,
       gt_x012     TYPE STANDARD TABLE OF zfidt012,
       gt_015      TYPE STANDARD TABLE OF zfidt015,
       gt_kna1     TYPE STANDARD TABLE OF kna1,
       gt_skat     TYPE STANDARD TABLE OF skat,
       gt_out      TYPE STANDARD TABLE OF ty_out,
       gt_xout     TYPE STANDARD TABLE OF ty_out,
       gt_error    TYPE STANDARD TABLE OF ty_error,
       gt_clearing TYPE STANDARD TABLE OF ty_post,
       gt_titipan  TYPE STANDARD TABLE OF ty_post,
       gt_selisih  TYPE STANDARD TABLE OF ty_post,
       gt_temp     TYPE STANDARD TABLE OF ty_out,
       gt_report   TYPE STANDARD TABLE OF ty_report,
       gt_reverse  TYPE STANDARD TABLE OF ty_reverse,
       gt_bkpf     TYPE STANDARD TABLE OF ty_bkpf,
       gt_bseg     TYPE STANDARD TABLE OF ty_bseg,
       gt_knvv     TYPE STANDARD TABLE OF knvv,
       gt_soff     TYPE STANDARD TABLE OF ty_soff,
       gt_header   TYPE STANDARD TABLE OF ty_header,
       gt_detail   TYPE STANDARD TABLE OF ty_detail.

DATA : gv_clearing TYPE bsid-hkont,
       gv_dmbtr    TYPE bsid-dmbtr,
       gv_waers    TYPE bsid-waers,
       gv_titipan  TYPE bsid-hkont,
       gv_ttbtr    TYPE bsid-dmbtr,
       gv_selisih  TYPE bsid-hkont,
       gv_slbtr    TYPE bsid-dmbtr,
       gv_budat    TYPE bsid-budat,
       gv_bldat    TYPE bkpf-bldat,
       gv_xblnr    TYPE bsid-xblnr,
       gv_clear    TYPE skat-txt50,
       gv_titip    TYPE skat-txt50,
       gv_selis    TYPE skat-txt50,
       gv_continue,
       gv_post.

DATA : documentheader TYPE bapiache09,
       obj_type       TYPE bapiache09-obj_type.

DATA : accountgl1         TYPE STANDARD TABLE OF bapiacgl09,
       accountgl2         TYPE STANDARD TABLE OF bapiacgl09,
       accountgl3         TYPE STANDARD TABLE OF bapiacgl09,
       accountreceivable1 TYPE STANDARD TABLE OF bapiacar09,
       accountreceivable2 TYPE STANDARD TABLE OF bapiacar09,
       accountreceivable3 TYPE STANDARD TABLE OF bapiacar09,
       accountpayable1    TYPE STANDARD TABLE OF bapiacap09,
       accountpayable2    TYPE STANDARD TABLE OF bapiacap09,
       accountpayable3    TYPE STANDARD TABLE OF bapiacap09,
       currencyamount1    TYPE STANDARD TABLE OF bapiaccr09,
       currencyamount2    TYPE STANDARD TABLE OF bapiaccr09,
       currencyamount3    TYPE STANDARD TABLE OF bapiaccr09,
       criteria1          TYPE STANDARD TABLE OF bapiackec9,
       criteria2          TYPE STANDARD TABLE OF bapiackec9,
       criteria3          TYPE STANDARD TABLE OF bapiackec9,
       extension11        TYPE STANDARD TABLE OF bapiacextc,
       extension12        TYPE STANDARD TABLE OF bapiacextc,
       extension13        TYPE STANDARD TABLE OF bapiacextc,
       extension21        TYPE STANDARD TABLE OF bapiparex,
       extension22        TYPE STANDARD TABLE OF bapiparex,
       extension23        TYPE STANDARD TABLE OF bapiparex.

FIELD-SYMBOLS :   <fs_out>    TYPE STANDARD TABLE.

DATA: t_alv_fieldcat            TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      t_alv_event               TYPE slis_t_event WITH HEADER LINE,
      t_events                  TYPE slis_t_event,
      t_alv_isort               TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      t_alv_filter              TYPE slis_t_filter_alv WITH HEADER LINE,
      t_event_exit              TYPE slis_t_event_exit WITH HEADER LINE,
      d_alv_isort               TYPE slis_sortinfo_alv,
      d_alv_variant             TYPE disvariant,
      d_alv_list_scroll         TYPE  slis_list_scroll,
      d_alv_sort_postn          TYPE i,
      d_alv_keyinfo             TYPE slis_keyinfo_alv,
      d_alv_fieldcat            TYPE slis_fieldcat_alv,
      d_alv_formname            TYPE slis_formname,
      d_alv_ucomm               TYPE slis_formname,
      d_alv_print               TYPE slis_print_alv,
      d_alv_repid               LIKE sy-repid,
      d_alv_tabix               LIKE sy-tabix,
      d_alv_subrc               LIKE sy-subrc,
      d_alv_screen_start_column TYPE i,
      d_alv_screen_start_line   TYPE i,
      d_alv_screen_end_column   TYPE i,
      d_alv_screen_end_line     TYPE i,
      d_alv_layout              TYPE slis_layout_alv.

DATA: d_layout TYPE slis_layout_alv,
      d_repid  LIKE sy-repid,
      d_print  TYPE slis_print_alv.
