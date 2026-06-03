*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E006TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF ty_order,
          check,
          werks     TYPE aufk-werks,
          plnbez    TYPE afko-plnbez,
          fcharg    TYPE resb-charg,
          gstrp     TYPE afko-gstrp,
          aufnr     TYPE afko-aufnr,
          objnr     TYPE aufk-objnr,
          posnr     TYPE afpo-posnr,
          cmatnr(100),
          matnr     TYPE resb-matnr,
          charg     TYPE resb-charg,
          count(20),
          qty(20),
          maktx     TYPE makt-maktx,
          rmein     TYPE mara-meins,
          packq     TYPE resb-bdmng,
          clabs     TYPE mchb-clabs,
          sisa      TYPE mchb-clabs,
          total     TYPE mchb-clabs,
          bdmng     TYPE resb-bdmng,
          vornr     TYPE resb-vornr,
          message(125),
          title01(50),
        END OF ty_order.

TYPES : BEGIN OF ty_operation,
          aufnr     TYPE afko-aufnr,
          rsnum     TYPE resb-rsnum,
          rspos     TYPE resb-rspos,
          matnr     TYPE resb-matnr,
          charg     TYPE resb-charg,
          lgort     TYPE resb-lgort,
          vornr     TYPE resb-vornr,
          ltxa1     TYPE afvc-ltxa1,
          usr00     TYPE afvu-usr00,
          clabs     TYPE mchb-clabs,
          meins     TYPE resb-meins,
          bdmng     TYPE resb-bdmng,
          erfmg     TYPE resb-erfmg,
          posnr     TYPE resb-posnr,
          vmeng     TYPE resb-vmeng,
        END OF ty_operation.

DATA : idx   TYPE i,
       line  TYPE i,
       lines TYPE i,
       limit TYPE i,
       c     TYPE i,
       n1    TYPE i VALUE 1,
       n2    TYPE i.

DATA : phase          TYPE STANDARD TABLE OF afvc,
       component      TYPE STANDARD TABLE OF resb.

DATA : goodsmvt_header     TYPE bapi2017_gm_head_01,
       goodsmvt_code       TYPE bapi2017_gm_code,
       goodsmvt_headret    TYPE bapi2017_gm_head_ret,
       goodsmvt_item       TYPE STANDARD TABLE OF bapi2017_gm_item_create.

DATA : gt_order       TYPE STANDARD TABLE OF ty_order,
       gs_order       LIKE LINE OF gt_order,
       gt_afpo        TYPE STANDARD TABLE OF afpo,
       gs_head        TYPE ty_order,
       gt_operation   TYPE STANDARD TABLE OF ty_operation,
       gs_operation   LIKE LINE OF gt_operation,
       gt_label       TYPE STANDARD TABLE OF ztspppst004,
       gt_component   TYPE STANDARD TABLE OF resb,    "bapi_order_component,
       gt_resb        TYPE STANDARD TABLE OF resb,
       gt_xresb       TYPE STANDARD TABLE OF resb,
       gt_afvc        TYPE STANDARD TABLE OF afvc,
       gt_afvu        TYPE STANDARD TABLE OF afvu,
       gt_temp        TYPE STANDARD TABLE OF ty_operation,
       gt_mara        TYPE STANDARD TABLE OF mara.

DATA : message1(20),
       message2(20),
       message3(20),
       message4(20),
       message5(20),
       message6(20),
       message7(20).

DATA : ok_code    TYPE sy-ucomm,
       gv_subrc   TYPE sy-subrc,
       gv_post,
       gv_stock,
       gv_total   TYPE resb-bdmng,
       gv_authorization,
       gv_duplicate,
       gv_nfull   TYPE i,
       gr_lgort   TYPE RANGE OF lgort_d,
       default    TYPE bapidefaul,
       return     TYPE STANDARD TABLE OF bapiret2,
       gv_bdmng   TYPE resb-bdmng,
       gv_werks   TYPE resb-werks,
       gv_lgort   TYPE resb-lgort.

DATA : gr_sttxt   TYPE RANGE OF sttxt.
