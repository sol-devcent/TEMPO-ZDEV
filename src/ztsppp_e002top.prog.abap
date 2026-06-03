*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E002TOP
*&---------------------------------------------------------------------*
TABLES sscrfields.

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
          squan     TYPE resb-bdmng,
          spack     TYPE resb-bdmng,
          meanval   TYPE qmean_val,
          message(125),
          title01(50),
          operator(30),
          pengawas(30),
          wb(50),
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
          erfme     TYPE resb-erfme,
          posnr     TYPE resb-posnr,
          vmeng     TYPE resb-vmeng,
          meanval   TYPE qmean_val,
*{   INSERT         P01K910834                                        1
*
          baugr     TYPE resb-baugr,      "SOH: Shell Remediation Adjustment 20240417 KRS
*}   INSERT
        END OF ty_operation.

TYPES : BEGIN OF ty_scan,
          matnr   TYPE resb-matnr,
          charg   TYPE resb-charg,
          bdmng   TYPE resb-bdmng,
          meins   TYPE resb-meins,
          count(10),
        END OF ty_scan.

DATA : idx   TYPE i,
       line  TYPE i,
       lines TYPE i,
       limit TYPE i,
       c1    TYPE i,
       c2    TYPE i,
       n1    TYPE i VALUE 1,
       n2    TYPE i,
       n3    TYPE i VALUE 1,
       n4    TYPE i.

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
       gt_scan        TYPE STANDARD TABLE OF ty_scan.

DATA : gt_resb_insert TYPE STANDARD TABLE OF resb,
       gt_resb_update TYPE STANDARD TABLE OF resb,
       gt_onr00       TYPE STANDARD TABLE OF onr00,
       gt_jest        TYPE STANDARD TABLE OF jest,
       gt_jsto        TYPE STANDARD TABLE OF jsto,
       gt_add         TYPE STANDARD TABLE OF zppresb_add.

DATA : ok_code    TYPE sy-ucomm,
       gv_post,
       gv_stock,
       gv_authorization,
       gv_fullp,
       gv_nfull   TYPE i,
       gr_lgort   TYPE RANGE OF lgort_d,
       default    TYPE bapidefaul,
       return     TYPE STANDARD TABLE OF bapiret2,
       gv_mblnr   TYPE mseg-mblnr,
       gv_meins   TYPE mara-meins.

DATA : gr_sttxt   TYPE RANGE OF sttxt.

DATA : gv_operator(100),
       gv_ouser(100),
       gv_oname(30),
       gv_onrp(30),
       gv_opass(6),
       gv_pengawas(100),
       gv_wuser(100),
       gv_wname(30),
       gv_wnrp(30),
       gv_wpass(6),
       gv_ocheck,
       gv_wcheck,
       gv_message(100),
       gv_subrc     TYPE sy-subrc,
       gv_pass,
       gv_261       TYPE resb-bwart VALUE '261'.
