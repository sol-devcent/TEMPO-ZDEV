*&---------------------------------------------------------------------*
*&  Include           ZFTKM_E001TOP
*&---------------------------------------------------------------------*
INCLUDE <icon>.

TABLES : sscrfields, zgdtxdt0003, vbrp, bsid.

CLASS : lcl_application DEFINITION DEFERRED.

TYPES : BEGIN OF ty_out,
          bukrs     TYPE bsid-bukrs,
          kunnr     TYPE bsid-kunnr,
          fakturno  TYPE zgdtxdt0003-fakturno,
          fakdat    TYPE zgdtxdt0003-fakdat,
          vbeln     TYPE zgdtxdt0003-vbeln,
          posnr     TYPE vbrp-posnr,
          matnr     TYPE zgdtxdt0002-matnr,
          maktx     TYPE makt-maktx,
          waerk     TYPE zgdtxdt0003-waerk,
          fakdpp    TYPE zgdtxdt0003-fakdpp,
          fakppn    TYPE zgdtxdt0003-fakppn,
          arktx     TYPE vbrp-arktx,
          route     TYPE vttk-route,
          add04     TYPE vttk-add04,
          tknum     TYPE vttk-tknum,
          vkbur     TYPE zfroute_apar-vkbur,
          xref3     TYPE bseg-xref3,
          bukrsx    TYPE bsid-bukrs,
          belnr     TYPE bseg-belnr,
          gjahr     TYPE bseg-gjahr,
          wrbtr     TYPE bseg-wrbtr,
          belnrrev  TYPE bseg-belnr,
          gsber     TYPE bseg-gsber,
          lifnr     TYPE lfa1-lifnr,
          name1     TYPE lfa1-name1,
          masatx    TYPE zgdtxdt0003-masatx,
          yeartx    TYPE zgdtxdt0003-yeartx,
          budat     TYPE zfapar_trn-budat,
          daterev   TYPE zfapar_trn-daterev,
          waers     TYPE bkpf-waers,
          amount    TYPE bseg-dmbtr,
          dpp       TYPE bseg-dmbtr,
          ppn       TYPE bseg-dmbtr,
          pph23     TYPE bseg-dmbtr,
          ket1(40),
          ket2(40),
          check,
          icon(4),
          style    TYPE lvc_t_styl,
        END OF ty_out.

TYPES : BEGIN OF ty_post,
          bukrs     TYPE bseg-bukrs,
          blart     TYPE bkpf-blart,
          koart     TYPE tbsl-koart,
          newbs     TYPE rf05a-newbs,
          newko     TYPE rf05a-newko,
          newum     TYPE rf05a-newum,
          gsber     TYPE bseg-gsber,
          vbund     TYPE bseg-vbund,
          vkbur     TYPE ce18010-kmvkbu,
          xref3     TYPE bseg-xref3,
          zuonr     TYPE bseg-zuonr,
          kostl     TYPE ce18010-copa_kostl,
          wwpfn     TYPE ce18010-wwpfn,
          wwpos     TYPE ce18010-wwpos,
          ket(40),
          shkzg     TYPE bseg-shkzg,
          wrbtr     TYPE bseg-wrbtr,
          route     TYPE vttk-route,
          add04     TYPE vttk-add04,
        END OF ty_post.

DATA : gv_repid             LIKE sy-repid,
       ok_code              TYPE sy-ucomm,
       gs_exclude           TYPE ui_functions,
       g_content            TYPE REF TO cl_salv_form_element,
       g_customcont         TYPE REF TO cl_gui_custom_container,
       g_splitter           TYPE REF TO cl_gui_splitter_container,
       g_container          TYPE REF TO cl_gui_container,
       g_maingrid           TYPE REF TO cl_gui_alv_grid,
       event_receiver       TYPE REF TO lcl_application,
       selected             VALUE 'X',
       gs_stable            TYPE lvc_s_stbl,
       gt_main_fieldcat     TYPE lvc_t_fcat,
       gs_layout_alv        TYPE lvc_s_layo,
       g_handle_alv         TYPE i,
       gt_main_sort         TYPE lvc_t_sort WITH HEADER LINE,
       gs_variant           LIKE disvariant,
       gs_toolbar           TYPE stb_button.

DATA : gt_out    TYPE STANDARD TABLE OF ty_out INITIAL SIZE 0,
       gt_post   TYPE STANDARD TABLE OF ty_post INITIAL SIZE 0,
       gt_002    TYPE STANDARD TABLE OF zgdtxdt0002 INITIAL SIZE 0,
       gt_003    TYPE STANDARD TABLE OF zgdtxdt0003 INITIAL SIZE 0,
       gt_apart  TYPE STANDARD TABLE OF zfapar_trn INITIAL SIZE 0,
       gt_vbrp   TYPE STANDARD TABLE OF vbrp INITIAL SIZE 0,
       gt_bseg   TYPE STANDARD TABLE OF bseg INITIAL SIZE 0,
       gt_lfa1   TYPE STANDARD TABLE OF lfa1 INITIAL SIZE 0,
       gt_006    TYPE STANDARD TABLE OF zdgsddt006 INITIAL SIZE 0,
       gt_vttk   TYPE STANDARD TABLE OF vttk INITIAL SIZE 0,
       gt_vttp   TYPE STANDARD TABLE OF vttp INITIAL SIZE 0,
       gt_likp   TYPE STANDARD TABLE OF likp INITIAL SIZE 0,
       gt_tbsl   TYPE STANDARD TABLE OF tbsl INITIAL SIZE 0,
       gt_makt   TYPE STANDARD TABLE OF makt,
       gt_aparb  TYPE STANDARD TABLE OF zfapar_bukrs
                 INITIAL SIZE 0,
       gt_aparr  TYPE STANDARD TABLE OF zfroute_apar
                 INITIAL SIZE 0,
       gt_apard  TYPE STANDARD TABLE OF zfapar_round
                 INITIAL SIZE 0,
       gs_post   LIKE LINE OF gt_post.

DATA : gt_error TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0.

DATA : documentheader      LIKE bapiache09,
       accountgl           TYPE STANDARD TABLE OF bapiacgl09 INITIAL SIZE 0,
       accountpayable      TYPE STANDARD TABLE OF bapiacap09 INITIAL SIZE 0,
       accountreceivable   TYPE STANDARD TABLE OF bapiacar09 INITIAL SIZE 0,
       extension1          TYPE STANDARD TABLE OF bapiacextc INITIAL SIZE 0,
       currencyamount      TYPE STANDARD TABLE OF bapiaccr09 INITIAL SIZE 0,
       criteria            TYPE STANDARD TABLE OF bapiackec9 INITIAL SIZE 0,
       return              TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0,
       obj_type            LIKE bapiache09-obj_type,
       obj_key             LIKE bapiache09-obj_key.

DATA : gt_enabled        TYPE lvc_t_styl,
       gt_disabled       TYPE lvc_t_styl.
