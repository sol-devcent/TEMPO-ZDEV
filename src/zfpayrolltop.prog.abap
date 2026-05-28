*&---------------------------------------------------------------------*
*&  Include           ZFPAYROLLTOP
*&---------------------------------------------------------------------*

TABLES : sscrfields, zfgaji_period, zfgaji_proses, tvbur, bkpf, bseg.

CLASS lcl_application DEFINITION DEFERRED.

CONTROLS : tc_appr     TYPE TABLEVIEW USING SCREEN 900.

TYPES : BEGIN OF ty_data,
          bukrs     TYPE t001-bukrs,
          zcocd     TYPE zfgaji_company-zcocd,
          vkbur     TYPE tvbur-vkbur,
          gsber     TYPE tgsb-gsber,
          zloct     TYPE zfgaji_lokasi-zloct,
          col       TYPE alsmex_tabline-col,
          row       TYPE alsmex_tabline-row,
          itemgaji  TYPE zfgaji_hkont-itemgaji,
          text1     TYPE zfgaji_hkont-text1,
          blart     TYPE zfgaji_lokasi-blart,
          newbs     TYPE zfgaji_lokasi-newbs,
          hkont     TYPE zfgaji_lokasi-hkont,
          kostl     TYPE zfgaji_lokasi-kostl,
          desc      TYPE zfgaji_lokasi-description,
          xblnr     TYPE bkpf-xblnr,
          subrc     TYPE sy-subrc,
          count     TYPE int4,
        END OF ty_data.

TYPES : BEGIN OF ty_thp,
          bukrs     TYPE t001-bukrs,
          vkbur     TYPE tvbur-vkbur,
          gsber     TYPE tgsb-gsber,
          row       TYPE alsmex_tabline-row,
          tthp      TYPE bseg-wrbtr,
          value     TYPE bseg-wrbtr,
        END OF ty_thp.

TYPES : BEGIN OF ty_reverse,
          bukrs       TYPE zfgaji_proses-bukrs,
          vkbur       TYPE zfgaji_proses-vkbur,
          zloct       TYPE zfgaji_proses-zloct,
          monat       TYPE zfgaji_proses-monat,
          gjahr       TYPE zfgaji_proses-gjahr,
          post_user   TYPE zfgaji_proses-post_user,
          post_date   TYPE zfgaji_proses-post_date,
          post_belnr  TYPE zfgaji_proses-post_belnr,
          post_gjahr  TYPE zfgaji_proses-post_gjahr,
          post_files  TYPE zfgaji_proses-post_files,
          post_budat  TYPE zfgaji_proses-post_budat,
          rev_belnr   TYPE zfgaji_proses-post_belnr,
        END OF ty_reverse.

TYPES : BEGIN OF ty_appr,
          icon(4),
          vkbur       TYPE zfgaji_proses-vkbur,
          zloct       TYPE zfgaji_lokasi-zloct,
          apv_user    TYPE zfgaji_proses-apv_user,
          apv_date    TYPE zfgaji_proses-apv_date,
          post_user   TYPE zfgaji_proses-post_user,
          post_date   TYPE zfgaji_proses-post_date,
          rev_user    TYPE zfgaji_proses-rev_user,
          rev_date    TYPE zfgaji_proses-rev_budat,
        END OF ty_appr.

TYPES : BEGIN OF ty_report,
          bukrs         TYPE t001-bukrs,
          zcocd         TYPE zfgaji_company-zcocd,
          vkbur         TYPE tvbur-vkbur,
          zloct         TYPE zfgaji_lokasi-zloct,
          apv_user      TYPE zfgaji_proses-apv_user,
          apv_date      TYPE zfgaji_proses-apv_date,
          post_belnr    TYPE zfgaji_proses-post_belnr,
          post_budat    TYPE zfgaji_proses-post_budat,
          post_user     TYPE zfgaji_proses-post_user,
          post_files    TYPE zfgaji_proses-post_files,
          post_date     TYPE zfgaji_proses-post_date,
          rev_belnr     TYPE zfgaji_proses-rev_belnr,
          rev_user      TYPE zfgaji_proses-rev_user,
          rev_budat     TYPE zfgaji_proses-rev_budat,
        END OF ty_report.

DATA : event_receiver    TYPE REF TO lcl_application.

DATA : gv_repid   TYPE sy-repid.

DATA : gt_mara      TYPE STANDARD TABLE OF mara INITIAL SIZE 0,
       gt_makt      TYPE STANDARD TABLE OF makt INITIAL SIZE 0,
       gt_mard      TYPE STANDARD TABLE OF mard INITIAL SIZE 0,
       gr_table     TYPE REF TO cl_salv_table,
       gt_head      TYPE STANDARD TABLE OF ty_data INITIAL SIZE 0,
       gt_detl      TYPE STANDARD TABLE OF ty_data INITIAL SIZE 0,
       gt_thp       TYPE STANDARD TABLE OF ty_thp INITIAL SIZE 0,
       gt_item      TYPE STANDARD TABLE OF ty_data INITIAL SIZE 0,
       gt_company   TYPE STANDARD TABLE OF zfgaji_company INITIAL SIZE 0,
       gt_control   TYPE STANDARD TABLE OF zfgaji_control INITIAL SIZE 0,
       gt_lokasi    TYPE STANDARD TABLE OF zfgaji_lokasi INITIAL SIZE 0,
       gt_proses    TYPE STANDARD TABLE OF zfgaji_proses INITIAL SIZE 0,
       gt_reverse   TYPE STANDARD TABLE OF ty_reverse INITIAL SIZE 0,
       gt_report    TYPE STANDARD TABLE OF ty_report INITIAL SIZE 0,
       gt_ghkont    TYPE STANDARD TABLE OF zfgaji_hkont INITIAL SIZE 0,
       gt_gkostl    TYPE STANDARD TABLE OF zfgaji_kostl INITIAL SIZE 0,
       gt_post      TYPE STANDARD TABLE OF zfgajipost INITIAL SIZE 0,
       gt_excel     TYPE STANDARD TABLE OF alsmex_tabline INITIAL SIZE 0,
       gt_skat      TYPE STANDARD TABLE OF skat INITIAL SIZE 0,
       gt_ska1      TYPE STANDARD TABLE OF ska1 INITIAL SIZE 0,
       gt_tbsl      TYPE STANDARD TABLE OF tbsl INITIAL SIZE 0,
       gt_appr      TYPE STANDARD TABLE OF ty_appr INITIAL SIZE 0,
       gs_appr      LIKE LINE OF gt_appr,
       gt_zplbc     TYPE STANDARD TABLE OF zplbc INITIAL SIZE 0.

DATA : gt_error     TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0.

DATA : gt_dyn_table  TYPE REF TO data,
       gs_dyn_table  TYPE REF TO data.

DATA : ref_grid      TYPE REF TO cl_gui_alv_grid.

FIELD-SYMBOLS : <fs_gt>   TYPE STANDARD TABLE,
                <fs_gs>   TYPE ANY,
                <fs>      TYPE ANY.

DATA : gv_subrc      TYPE sy-subrc,
       ok_code       TYPE sy-ucomm,
       gv_zcocd      TYPE zfgaji_company-zcocd,
       gv_text(20),
       fill          TYPE i.

DATA : obj_type      LIKE bapiache09-obj_type,
       obj_key       LIKE bapiache09-obj_key,
       return        TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0.
