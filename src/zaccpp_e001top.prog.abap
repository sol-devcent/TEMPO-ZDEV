*&---------------------------------------------------------------------*
*&  Include           ZACCPP_E001TOP
*&---------------------------------------------------------------------*
TYPE-POOLS truxs.

TABLES : sscrfields, afpo, afko.

CLASS : lcl_application DEFINITION DEFERRED.

TYPES : BEGIN OF ty_afpo,
          aufnr   TYPE afpo-aufnr,
          posnr   TYPE afpo-posnr,
          matnr   TYPE afpo-matnr,
          dwerk   TYPE afpo-dwerk,
          charg   TYPE afpo-charg,
          lgort   TYPE afpo-lgort,
          gstrp   TYPE afko-gstrp,
          psmng   TYPE afpo-psmng,
          amein   TYPE afpo-amein,
          rsnum   TYPE afko-rsnum,
        END OF ty_afpo.

TYPES : BEGIN OF ty_aufk,
          aufnr   TYPE aufk-aufnr,
          objnr   TYPE aufk-objnr,
        END OF ty_aufk.

TYPES : BEGIN OF ty_a989_key,
          vkorg   TYPE a989-vkorg,
          matnr   TYPE a989-matnr,
          gstrp   TYPE afko-gstrp,
        END OF ty_a989_key.

DATA : gv_repid             LIKE sy-repid,
       ok_code              TYPE sy-ucomm,
       dynlog               TYPE smp_dyntxt,
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

DATA : gt_afpo          TYPE STANDARD TABLE OF ty_afpo,
       gt_aufk          TYPE STANDARD TABLE OF ty_aufk,
       gt_jest          TYPE STANDARD TABLE OF jest,
       gt_tj02t         TYPE STANDARD TABLE OF tj02t,
       gt_mcha          TYPE STANDARD TABLE OF mcha,
       gt_mch1          TYPE STANDARD TABLE OF mch1,
       gt_ztspmmdt002   TYPE STANDARD TABLE OF ztspmmdt002,
       gt_zaccdtm       TYPE STANDARD TABLE OF zaccdtm,
       gt_xaccdtm       TYPE STANDARD TABLE OF zaccdtm,
       gt_zaccdtu       TYPE STANDARD TABLE OF zaccdtu,
       gt_t001k         TYPE STANDARD TABLE OF t001k,
       gt_a989          TYPE STANDARD TABLE OF a989,
       gt_konp          TYPE STANDARD TABLE OF konp,
       gt_makt          TYPE STANDARD TABLE OF makt,
       gt_marm          TYPE STANDARD TABLE OF marm,
       gt_auom          TYPE STANDARD TABLE OF zaccdtuom,
       gt_post          TYPE STANDARD TABLE OF zaccstp.

DATA : gt_resb          TYPE STANDARD TABLE OF resb.

DATA : status_code(5),
       status_text(300),
       len TYPE i.

DATA : gt_reqbody       TYPE STANDARD TABLE OF sbcbody,
       gt_resbody       TYPE STANDARD TABLE OF sbcbody,
       gt_reqhead       TYPE STANDARD TABLE OF sbcheader,
       gt_reshead       TYPE STANDARD TABLE OF sbcheader.

DATA : gv_token(100),
       gv_login   TYPE zaccdtu-uri,
       gv_uri     TYPE zaccdtu-uri,
       gv_subrc   TYPE sy-subrc.

DATA : gt_ackno         TYPE STANDARD TABLE OF zaccstp.

DATA : gt_message       TYPE STANDARD TABLE OF zaccppst001.
