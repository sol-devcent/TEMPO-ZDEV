*&---------------------------------------------------------------------*
*&  Include           ZMM_EWASTOP
*&---------------------------------------------------------------------*
TYPE-POOLS : p99sg.

TABLES : marc, mkpf, mseg.

TYPES : BEGIN OF ty_marm,
          matnr       TYPE marm-matnr,
          meinh       TYPE marm-meinh,
          umren       TYPE marm-umren,
          msehl       TYPE t006a-msehl,
        END OF ty_marm.

TYPES : BEGIN OF ty_mchbmch1,
          spmon       TYPE s933-spmon,
          werks       TYPE s933-werks,
          matnr       TYPE mchb-matnr,
          charg       TYPE mchb-charg,
        END OF ty_mchbmch1.

*TYPES : BEGIN OF ty_lfa1,
*          werks       TYPE s933-werks,
*          matnr       TYPE s933-matnr,
*          charg       TYPE s933-charg,
*          lgort       TYPE s933-lgort,
*          lifnr       TYPE s933-lifnr,
*          name1       TYPE lfa1-name1,
*          ebeln       TYPE s933-ebeln,
*          budat       TYPE s933-budat,
*          werkslfa1   TYPE lfa1-werks,
*        END OF ty_lfa1.

TYPES : BEGIN OF ty_lfa1,
          spmon       TYPE s933-spmon,
          werks       TYPE s933-werks,
          matnr       TYPE s933-matnr,
          bwart       TYPE s933-bwart,
          charg       TYPE s933-charg,
          mblnr       TYPE s933-mblnr,
          budat       TYPE s933-budat,
          lgort       TYPE s933-lgort,
          vrsio       TYPE s933-vrsio,
          sptag       TYPE s933-sptag,
          spwoc       TYPE s933-spwoc,
          spbup       TYPE s933-spbup,
          ssour       TYPE s933-ssour,
          ebeln       TYPE s933-ebeln,
          lifnr       TYPE s933-lifnr,
          name1       TYPE lfa1-name1,
          werkslfa1   TYPE lfa1-werks,
        END OF ty_lfa1.

TYPES : BEGIN OF ty_price,
          kappl   TYPE a005-kappl,
          kschl   TYPE a005-kschl,
          vkorg   TYPE a005-vkorg,
          vtweg   TYPE a005-vtweg,
          kunnr   TYPE a005-kunnr,
          lifnr   TYPE a017-lifnr,
          matnr   TYPE a005-matnr,
          ekorg   TYPE a017-ekorg,
          werks   TYPE a017-werks,
          esokz   TYPE a017-esokz,
          datbi   TYPE a005-datbi,
          datab   TYPE a005-datab,
          knumh   TYPE a005-knumh,
        END OF ty_price.

DATA : lo_excel             TYPE REF TO zcl_excel,
       lo_worksheet         TYPE REF TO zcl_excel_worksheet,
       lo_style_right       TYPE REF TO zcl_excel_style,
       ls_table_settings    TYPE zexcel_s_table_settings,
       lv_style_right_guid  TYPE zexcel_cell_style,
       column_dimension     TYPE REF TO zcl_excel_worksheet_columndime.

DATA : gt_zmmst01   TYPE TABLE OF zmmst01,
       gt_zmmst01a  TYPE TABLE OF zmmst01a,
       gt_zmmst01b  TYPE TABLE OF zmmst01b,
       gt_zmmst02   TYPE TABLE OF zmmst02,
       gt_zmmst02a  TYPE TABLE OF zmmst02a,
       gt_zmmst03   TYPE TABLE OF zmmst03,
       gt_zmmst03a  TYPE TABLE OF zmmst03a,
       gt_zmmst04   TYPE TABLE OF zmmst04,
       gt_zmmst04a  TYPE TABLE OF zmmst04a,
       gt_zmmst04b  TYPE TABLE OF zmmst04b,
       gt_opnstk    TYPE zmmtt_opnstk,
       gt_mch1      TYPE TABLE OF mch1,
       gt_mara      TYPE TABLE OF mara,
       gt_002       TYPE TABLE OF ztspmmdt002,
       gt_marm      TYPE TABLE OF ty_marm,
       gt_t023t     TYPE TABLE OF t023t,
       gt_makt      TYPE TABLE OF makt,
       gt_kna1      TYPE TABLE OF kna1,
       gt_msegsum   TYPE TABLE OF mseg,
       gt_msegtrn   TYPE TABLE OF mseg,
       gt_msegopn   TYPE TABLE OF mseg,
       gt_s933      TYPE TABLE OF s933,
       gt_mkpf      TYPE TABLE OF mkpf,
       gt_t157e     TYPE TABLE OF t157e,
       gt_mbew      TYPE TABLE OF mbew,
       gt_mbewh     TYPE TABLE OF mbewh,
       gt_nilai     TYPE TABLE OF mbew,
       gt_t005t     TYPE TABLE OF t005t,
       gt_zmmewas   TYPE TABLE OF zmmewas,
       gt_vbfa      TYPE TABLE OF vbfa,
       gt_vbap      TYPE TABLE OF vbap,
       gt_konp      TYPE TABLE OF konp,
       gt_mchbmch1  TYPE TABLE OF ty_mchbmch1,
       gt_lfa1      TYPE TABLE OF ty_lfa1,
       gt_price     TYPE TABLE OF ty_price.

DATA : gr_bwart01   TYPE RANGE OF bwart,
       gr_bwart02   TYPE RANGE OF bwart,
       gr_bwart03   TYPE RANGE OF bwart.

DATA : gr_lgort00   TYPE RANGE OF lgort_d,
       gr_lgort01   TYPE RANGE OF lgort_d,
       gr_lgort02   TYPE RANGE OF lgort_d,
       gr_lgort03   TYPE RANGE OF lgort_d.

DATA : gt_m01       TYPE TABLE OF mseg,
       gt_m02       TYPE TABLE OF mseg,
       gt_m03       TYPE TABLE OF mseg.
