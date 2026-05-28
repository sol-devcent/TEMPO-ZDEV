*&---------------------------------------------------------------------*
*&  Include           ZDG2FI_R0007TOP
*&---------------------------------------------------------------------*
CLASS : lcl_handle_events DEFINITION DEFERRED.

TABLES : anla, anlp, sscrfields.

TYPES : BEGIN OF ty_key,
          bukrs TYPE anla-bukrs,
          anln1 TYPE anla-anln1,
          anln2 TYPE anla-anln2,
          gjahr TYPE anlc-gjahr,
        END OF ty_key.

TYPES : BEGIN OF ty_dpost,
          anln1 TYPE anla-anln1,
          anln2 TYPE anla-anln2.
          INCLUDE STRUCTURE fiaa_dpost.
        TYPES : END OF ty_dpost.

TYPES : BEGIN OF ty_data,
          anln1   TYPE anla-anln1,
          anln2   TYPE anla-anln2,
          txt50   TYPE anla-txt50,
          kostl   TYPE anlz-kostl,
          raumn   TYPE anlz-raumn,
          kfzkz   TYPE anlz-kfzkz,
          gsber   TYPE anlz-gsber,
          typbz   TYPE anla-typbz,
          eaufn   TYPE anla-eaufn,
          sernr   TYPE anla-sernr,
          prctr   TYPE anlz-prctr,
          zugdt   TYPE anla-zugdt,
          answl   TYPE anlc-answl,
          lifnr   TYPE lfa1-lifnr,
          name1   TYPE lfa1-name1,
          xblnr   TYPE bsik-xblnr,
          budat   TYPE bsis-budat,
          belnr   TYPE bsis-belnr,
          afasl   TYPE anlb-afasl,
          ndjar   TYPE anlb-ndjar,
          afabg   TYPE anlb-afabg,
          depmo   TYPE anlp-nafaz,
          adely   TYPE anlp-nafap,
          adecu   TYPE anlp-safag,
          dep001  TYPE anlp-nafag,
          dep002  TYPE anlp-nafag,
          dep003  TYPE anlp-nafag,
          dep004  TYPE anlp-nafag,
          dep005  TYPE anlp-nafag,
          dep006  TYPE anlp-nafag,
          dep007  TYPE anlp-nafag,
          dep008  TYPE anlp-nafag,
          dep009  TYPE anlp-nafag,
          dep010  TYPE anlp-nafag,
          dep011  TYPE anlp-nafag,
          dep012  TYPE anlp-nafag,
          nbval   TYPE anlcv-bchwrt_gje,
          waers   TYPE t093b-waers,
          icon(4),
        END OF ty_data.

DATA : dynpfields     TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0.

DATA : gt_key    TYPE STANDARD TABLE OF ty_key,
       gt_anla   TYPE STANDARD TABLE OF anla,
       gt_anlb   TYPE STANDARD TABLE OF anlb,
       gt_anlbza TYPE STANDARD TABLE OF anlbza,
       gt_anlc   TYPE STANDARD TABLE OF anlc,
       gt_xanlc  TYPE STANDARD TABLE OF anlc,
       gt_anlz   TYPE STANDARD TABLE OF anlz,
       gt_anea   TYPE STANDARD TABLE OF anea,
       gt_anek   TYPE STANDARD TABLE OF anek,
       gt_bseg   TYPE STANDARD TABLE OF bseg,
       gt_xanek  TYPE STANDARD TABLE OF anek,
       gt_anep   TYPE STANDARD TABLE OF anep,
       gt_lfa1   TYPE STANDARD TABLE OF lfa1,
       gt_ekbe   TYPE STANDARD TABLE OF ekbe,
       gt_xekbe  TYPE STANDARD TABLE OF ekbe,
       gt_mseg   TYPE STANDARD TABLE OF mseg,
       gt_bsas1  TYPE STANDARD TABLE OF bsas,
       gt_bsas2  TYPE STANDARD TABLE OF bsas,
       gt_bsik   TYPE STANDARD TABLE OF bsik,
       gt_bkpf   TYPE STANDARD TABLE OF bkpf,
       gt_dpost  TYPE STANDARD TABLE OF ty_dpost,
       gt_data   TYPE STANDARD TABLE OF ty_data,
       gs_t001   TYPE t001,
       gs_t093b  TYPE t093b,
       gs_t093t  TYPE t093t,
       gs_ankt   TYPE ankt,
       itab_data TYPE STANDARD TABLE OF fiaa_salvtab_ragafa.

DATA : gr_table    TYPE REF TO cl_salv_table,
       gr_events   TYPE REF TO lcl_handle_events,
       gt_fieldcat TYPE lvc_t_fcat.

DATA : gv_repid   TYPE sy-repid.

FIELD-SYMBOLS : <fs_tab>  TYPE STANDARD TABLE.
