*&---------------------------------------------------------------------*
*&  Include           ZTSPMM_E002TOP
*&---------------------------------------------------------------------*
TABLES resb.

INCLUDE <icon>.

CONTROLS : tc_items   TYPE TABLEVIEW USING SCREEN 100.

TYPES : BEGIN OF ty_btn,
          delete(4),
          werks(4),
          bwart(4),
          umlgo(4),
          lgort(4),
        END OF ty_btn.

TYPES : BEGIN OF ty_sloc,
          werks   TYPE t001l-werks,
          lgort   TYPE t001l-lgort,
          lgobe   TYPE t001l-lgobe,
        END OF ty_sloc.

TYPES : BEGIN OF ty_mchb,
          matnr   TYPE mchb-matnr,
          werks   TYPE mchb-werks,
          lgort   TYPE mchb-lgort,
          charg   TYPE mchb-charg,
        END OF ty_mchb.

TYPES : BEGIN OF ty_head,
          werks   TYPE t001w-werks,
          name1   TYPE t001w-name1,
          name2   TYPE t001w-name2,
          lgort   TYPE resb-lgort,
          lgofr   TYPE t001l-lgobe,
          umlgo   TYPE resb-umlgo,
          lgoto   TYPE t001l-lgobe,
          bwart   TYPE mseg-bwart,
          btext   TYPE t156t-btext,
          rsnum   TYPE resb-rsnum,
          status(10),
        END OF ty_head.

TYPES : BEGIN OF ty_items,
          rspos   TYPE resb-rspos,
          matnr   TYPE resb-matnr,
          maktx   TYPE makt-maktx,
          erfmg   TYPE resb-erfmg,
          meins   TYPE mara-meins,
          charg   TYPE resb-charg,
          manufacture(50),
          icon(4),
          text(50),
          mark,
        END OF ty_items.

DATA : BEGIN OF ty_tline,
          rspos   TYPE resb-rspos,
          tdline(132),
        END OF ty_tline.

DATA : gt_head    TYPE STANDARD TABLE OF ty_head,
       gs_head    LIKE LINE OF gt_head,
       gt_items   TYPE STANDARD TABLE OF ty_items,
       gs_items   LIKE LINE OF gt_items,
       gt_tline   TYPE STANDARD TABLE OF ty_tline.

DATA : dynpfields     TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0.

DATA : gt_sloc    TYPE STANDARD TABLE OF ty_sloc,
       gt_mchb    TYPE STANDARD TABLE OF ty_mchb,
       gt_t001w   TYPE STANDARD TABLE OF t001w,
       gt_t001l   TYPE STANDARD TABLE OF t001l,
       gt_t156t   TYPE STANDARD TABLE OF t156t,
       gt_error   TYPE STANDARD TABLE OF bapiret2,
       gt_resb    TYPE STANDARD TABLE OF resb.

DATA : gs_btn     TYPE ty_btn,
       ok_code    TYPE sy-ucomm,
       fitems     TYPE i,
       gv_isi.

DATA : reservation_header   TYPE bapirkpfc,
       reservation          TYPE bapirkpfc-res_no,
       reservation_items    TYPE STANDARD TABLE OF bapiresbc,
       return               TYPE STANDARD TABLE OF bapireturn.

DATA : gs_prth              TYPE zmmst05,
       gt_prtd              TYPE STANDARD TABLE OF zmmst05.

FIELD-SYMBOLS <fs_tab> TYPE STANDARD TABLE.
