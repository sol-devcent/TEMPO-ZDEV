*&---------------------------------------------------------------------*
*&  Include           ZACCMM_E002TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF ty_input,
          tanum   TYPE ltak-tanum,
          mblnr   TYPE mkpf-mblnr,
          vbeln   TYPE likp-vbeln,
          ebeln   TYPE ekko-ebeln,
          lifnr   TYPE ekko-lifnr,
          name1   TYPE lfa1-name1,
          gtin    TYPE zaccdtm-vbeln,
        END OF ty_input.

TYPES : BEGIN OF ty_valsn,
          senum(20),
          aggr1   TYPE zaccdta-aggr1,
          zact1   TYPE xfeld,
          aggr2   TYPE zaccdta-aggr2,
          zact2   TYPE xfeld,
        END OF ty_valsn.

TYPES : BEGIN OF ty_sn,
          check(1),
          tanum(10),
          vbeln(10),
          posnr   TYPE lips-posnr,
          senum   TYPE zaccdtm-senum,
          matnr   TYPE lips-matnr,
          charg   TYPE lips-charg,
          werks   TYPE lips-werks,
          lgort   TYPE lips-lgort,
          count(10),
          maktx   TYPE makt-maktx,
          meins   TYPE lips-meins,
          aggr1   TYPE zaccdta-aggr1,
          zact1   TYPE xfeld,
          aggr2   TYPE zaccdta-aggr2,
          zact2   TYPE xfeld,
          savwe   TYPE lips-werks,
        END OF ty_sn.

TYPES : BEGIN OF ty_mara,
          matnr   TYPE mara-matnr,
          meins   TYPE mara-meins,
          maktx   TYPE makt-maktx,
        END OF ty_mara.

DATA : ok_code    TYPE sy-ucomm,
       gv_index   TYPE i,
       gv_lines   TYPE i,
       gv_guname  TYPE seqg3-guname,
       gv_subrc   TYPE sy-subrc.

DATA : gv_lgnum     TYPE lrf_wkqu-lgnum,
       gv_mblnr     TYPE ltak-mblnr,
       gt_002       TYPE STANDARD TABLE OF ztspmmdt002,
       gt_zaccdtd   TYPE STANDARD TABLE OF zaccdtd,
       gt_sn        TYPE STANDARD TABLE OF ty_sn,
       gs_sn        LIKE LINE OF gt_sn,
       gt_zaccdtm   TYPE STANDARD TABLE OF zaccdtm,
       gt_zaccdta   TYPE STANDARD TABLE OF zaccdta,
       gt_valsn     TYPE STANDARD TABLE OF ty_valsn,
       gt_mara      TYPE STANDARD TABLE OF ty_mara.

DATA : gs_input   TYPE ty_input,
       gv_senum(100),
       gr_snsta   TYPE RANGE OF zsnsta.

DATA : message1(20),
       message2(20),
       message3(20),
       message4(20),
       message5(20),
       message6(20),
       message7(20).
