*&---------------------------------------------------------------------*
*&  Include           ZDG2FI_E0007TOP
*&---------------------------------------------------------------------*
TYPE-POOLS : truxs, slis, icon.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE title.
PARAMETER : p_file TYPE rlgrap-filename.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE title1.
PARAMETERS: variant LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK block2.


TYPES : BEGIN OF ty_data_raw,
        doc_no(5) TYPE n,
        bldat TYPE bkpf-bldat,
        blart TYPE bkpf-blart,
        bukrs TYPE bkpf-bukrs,
        budat TYPE bkpf-budat,
        monat TYPE bkpf-monat,
        waers TYPE bkpf-waers,
        kursf TYPE bkpf-kursf,
        xblnr TYPE bkpf-xblnr,
        bktxt TYPE bkpf-bktxt,
        bschl TYPE bseg-bschl,
        hkont TYPE bseg-hkont,
        umskz TYPE bseg-umskz,
        dmbtr TYPE bseg-dmbtr,
        wrbtr TYPE bseg-wrbtr,
        kkber TYPE bseg-kkber,
        zuonr TYPE bseg-zuonr,
        sgtxt TYPE bseg-sgtxt,
        gsber TYPE bseg-gsber,
        kostl TYPE bseg-kostl,
        projk TYPE bseg-projk,
        fkber TYPE bseg-fkber,
        matnr TYPE bseg-matnr,
        zterm TYPE bseg-zterm,
        zlspr TYPE bseg-zlspr,
        zlsch TYPE bseg-zlsch,
        prctr TYPE bseg-prctr,
        rebzg TYPE bseg-rebzg,
        rebzj TYPE bseg-rebzj,
        rebzz TYPE bseg-rebzz,
        kidno TYPE bseg-kidno,
        valut TYPE bseg-valut,
        zfbdt TYPE bseg-zfbdt,
        aufnr TYPE bseg-aufnr,
        vbund TYPE bseg-vbund,
        xref1 TYPE bseg-xref1,
        xref2 TYPE bseg-xref2,
        xref3 TYPE bseg-xref3,
        mwskz TYPE bseg-mwskz,
        vkorg_copa TYPE vkorg,
        kndnr_copa TYPE kunnr,
        bukrs_copa TYPE bukrs,
        werks_copa TYPE werks,
        vkbur_copa TYPE vkbur,
        prctr_copa TYPE prctr,
        spart_copa TYPE spart,
        kunwe_copa TYPE kunwe,
        artnr_copa TYPE artnr,
        matkl_copa TYPE matkl,
        extwg_copa TYPE extwg,
       END OF ty_data_raw.
DATA : t_data_raw TYPE TABLE OF ty_data_raw WITH HEADER LINE.

TYPES : BEGIN OF ty_data,
          light(6) TYPE c,
          status(60) TYPE c.
          INCLUDE TYPE ty_data_raw.
TYPES : END OF ty_data.

DATA : t_data TYPE TABLE OF ty_data WITH HEADER LINE,
       x_data LIKE LINE OF t_data.

* variable for alv grid
DATA : t_fldcat TYPE slis_t_fieldcat_alv,
       x_fldcat     TYPE slis_fieldcat_alv,
       t_sort       TYPE slis_t_sortinfo_alv WITH HEADER LINE,
       t_events     TYPE slis_t_event WITH HEADER LINE,
       t_event_exit TYPE slis_t_event_exit WITH HEADER LINE,
       x_layout     TYPE slis_layout_alv,
       x_print      TYPE slis_print_alv,
       x_variant    TYPE disvariant,
       d_repid      TYPE sy-repid.

* declare variable for alv variant
DATA : g_variant TYPE disvariant,
       g_save, g_exit,
       gx_variant TYPE disvariant.
