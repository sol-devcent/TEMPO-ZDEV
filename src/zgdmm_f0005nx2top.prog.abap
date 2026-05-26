*----------------------------------------------------------------------*
*   INCLUDE ZGDMMF0005TOP                                              *
*----------------------------------------------------------------------*
TYPE-POOLS : vrm.

TYPES : BEGIN OF ty_004.
        INCLUDE STRUCTURE zgdmmt0004x.
TYPES : xeile   TYPE zgdmmt0004x-zeile,
        END OF ty_004.

TABLES: *nast,
        nast,
        tnapr,
        mkpf,
        mseg,
        lfa1,
        ekko,
        t001w,
        mara,
        usr21,
        adrp,
        mbew,
        rkpf,
        eban,
        sscrfields,
        zgdmmt004a.

DATA: BEGIN OF t_nast_key,
        matnr LIKE mara-matnr,
      END OF t_nast_key.

DATA: xscreen(1) TYPE c.

DATA: BEGIN OF t_header.
        INCLUDE STRUCTURE zgdmmst0051x.
DATA: END OF t_header.

DATA: BEGIN OF t_mara OCCURS 0,
        matnr  LIKE mara-matnr,
        mfrnr  LIKE mara-mfrnr,
        mfrpn  LIKE mara-mfrpn,
        name1  LIKE lfa1-name1,
        tdline LIKE tline-tdline,
        aplfz  LIKE eine-aplfz,
        umrez  LIKE eina-umrez.
DATA: END OF t_mara.

DATA: BEGIN OF t_eina OCCURS 0,
        matnr  LIKE eina-matnr,
        infnr  LIKE eina-infnr,
        lifnr  LIKE eina-lifnr,
        erdat  LIKE eina-erdat,
        name1  LIKE lfa1-name1,
        umrez  LIKE eina-umrez,
        tdline LIKE tline-tdline,
        aplfz  LIKE eine-aplfz.
DATA: END OF t_eina.
DATA: BEGIN OF t_eina1 OCCURS 0,
        matnr  LIKE eina-matnr,
        infnr  LIKE eina-infnr,
        lifnr  LIKE eina-lifnr,
        erdat  LIKE eina-erdat,
        name1  LIKE lfa1-name1,
        umrez  LIKE eina-umrez,
        tdline LIKE tline-tdline,
        aplfz  LIKE eine-aplfz.
DATA: END OF t_eina1.

DATA: BEGIN OF t_eine OCCURS 0,
        infnr  LIKE eine-infnr,
        ekorg  LIKE eine-ekorg,
        esokz  LIKE eine-esokz,
        werks  LIKE eine-werks,
        aplfz  LIKE eine-aplfz,
        datlb  LIKE eine-datlb,
        ebeln  LIKE eine-ebeln,
        ebelp  LIKE eine-ebelp.
DATA: END OF t_eine.

DATA: BEGIN OF t_lfa1 OCCURS 0,
        lifnr  LIKE lfa1-lifnr,
        name1  LIKE lfa1-name1.
DATA: END OF t_lfa1.

DATA: BEGIN OF t_ekko OCCURS 0,
        ebeln  LIKE ekko-ebeln,
        ebelp  LIKE ekpo-ebelp,
        lifnr  LIKE ekko-lifnr,
        bedat  LIKE ekko-bedat,
        knumv  LIKE ekko-knumv,
        ematn  LIKE ekpo-ematn,
        meins  LIKE ekpo-meins,
        infnr  LIKE ekpo-infnr,
        netpr  LIKE ekpo-netpr,
        menge  LIKE eket-menge,
        wemng  LIKE eket-wemng,
        elikz  LIKE ekpo-elikz.
DATA: END OF t_ekko.

DATA: BEGIN OF t_ekko1 OCCURS 0,
        ebeln  LIKE ekko-ebeln,
        ebelp  LIKE ekpo-ebelp,
        lifnr  LIKE ekko-lifnr,
        bedat  LIKE ekko-bedat,
        knumv  LIKE ekko-knumv,
        ematn  LIKE ekpo-ematn,
        meins  LIKE ekpo-meins,
        infnr  LIKE ekpo-infnr,
        netpr  LIKE ekpo-netpr,
        menge  LIKE eket-menge,
        wemng  LIKE eket-wemng,
        elikz  LIKE ekpo-elikz.
DATA: END OF t_ekko1.

DATA: BEGIN OF t_ekkosum OCCURS 0,
        ebeln  LIKE ekko-ebeln,
        ebelp  LIKE ekpo-ebelp,
        lifnr  LIKE ekko-lifnr,
        ematn  LIKE ekpo-ematn,
        meins  LIKE ekpo-meins,
        menge  LIKE eket-menge,
        wemng  LIKE eket-wemng.
DATA: END OF t_ekkosum.
DATA: BEGIN OF t_eket OCCURS 0,
      ebeln  LIKE eket-ebeln,
      ebelp  LIKE eket-ebelp,
      etenr  LIKE eket-etenr,
      menge  LIKE eket-menge,
      wemng  LIKE eket-wemng.
DATA: END OF t_eket.
DATA: BEGIN OF t_eketsum OCCURS 0.
        INCLUDE STRUCTURE t_eket.
DATA: END OF t_eketsum.

DATA: BEGIN OF t_a018 OCCURS 0,
        lifnr LIKE a018-lifnr,
        matnr LIKE a018-matnr,
        knumh LIKE a018-knumh,
        datab LIKE a018-datab,
        umrez LIKE eina-umrez.
DATA: END OF t_a018.

DATA: BEGIN OF t_supplier OCCURS 0.
        INCLUDE STRUCTURE zgdmmst0053.
DATA: END OF t_supplier.
DATA: wa_supplier LIKE t_supplier.

DATA: BEGIN OF t_detail OCCURS 0.
        INCLUDE STRUCTURE zgdmmst0052.
DATA: END OF t_detail.
DATA: BEGIN OF t_sub OCCURS 0.
        INCLUDE STRUCTURE zgdmmst0052.
DATA: END OF t_sub.

DATA: gt_nsupl    TYPE STANDARD TABLE OF zgdmmst0055.

RANGES: ra_matnr FOR mara-matnr,
        ra_mfrnr FOR mara-mfrnr,
        ra_bsart FOR ekko-bsart,
        ra_lifnr FOR ekko-lifnr.

DATA: va_menget  LIKE eket-menge,
      va_record  TYPE i,
      va_totpage TYPE i,
      va_lines   TYPE i.

DATA: BEGIN OF gt_zm73 OCCURS 0,
        lifnr TYPE elifn,
        bobot TYPE zbobottop,
        sdiff TYPE zbobottop,
        %aloc TYPE zbobottop,
      END OF gt_zm73.

DATA: gt_zm732 LIKE gt_zm73 OCCURS 0,
      gt_zm733 LIKE gt_zm73 OCCURS 0,
      gt_zm734 LIKE gt_zm73 OCCURS 0.

DATA: gt_zmtnt_scor_aloc TYPE TABLE OF zmtnt_scor_aloc WITH HEADER LINE.
DATA: gv_lines    TYPE numc2.
DATA: gv_bobottot TYPE zbobottop.

CONTROLS : tc_201        TYPE TABLEVIEW USING SCREEN 201,
           tc_202        TYPE TABLEVIEW USING SCREEN 202.

DATA : ok_code      TYPE sy-ucomm,
       gv_lifnr     TYPE lfa1-lifnr,
       gv_name1     TYPE lfa1-name1,
       gt_suppl     TYPE STANDARD TABLE OF zgdmmst002x,
       gs_suppl     TYPE zgdmmst002x,
       gt_xsuppl    TYPE STANDARD TABLE OF zgdmmst002x,
       gt_004       TYPE STANDARD TABLE OF ty_004, "zgdmmt0004x,
       dynpfields   TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0.

FIELD-SYMBOLS : <fs_tab> TYPE STANDARD TABLE.

DATA : gr_matnr     TYPE RANGE OF matnr.

TYPES : BEGIN OF ty_zm73,
          lifnr TYPE elifn,
          bobot TYPE zbobottop,
          sdiff TYPE zbobottop,
          %aloc TYPE zbobottop,
        END OF ty_zm73.

TYPES : BEGIN OF ty_aloc,
          lifnr TYPE a968-lifnr,
          datab TYPE a968-datab,
          kbetr TYPE konp-kbetr,
          konwa TYPE konp-konwa,
        END OF ty_aloc.

TYPES : BEGIN OF ty_ekko,
          ebeln   TYPE ekpo-ebeln,
          ebelp   TYPE ekpo-ebelp,
          bedat   TYPE ekko-bedat,
          lifnr   TYPE ekko-lifnr,
          matnr   TYPE ekpo-matnr,
          menge   TYPE ekpo-menge,
          meins   TYPE ekpo-meins,
        END OF ty_ekko.

DATA : gt_aloc    TYPE STANDARD TABLE OF ty_aloc,
       gt_lfm1    TYPE STANDARD TABLE OF lfm1,
       gt_t052u   TYPE STANDARD TABLE OF t052u.

DATA : t_eipa     TYPE STANDARD TABLE OF eipa,
       fill       TYPE i.

DATA : gt_04a     TYPE STANDARD TABLE OF zgdmmt004a,
       gt_04b     TYPE STANDARD TABLE OF zgdmmt004b,
       gt_04c     TYPE STANDARD TABLE OF zgdmmt004c,
       gt_04d     TYPE STANDARD TABLE OF zgdmmt004d.

DATA : gt_xekko   TYPE STANDARD TABLE OF ekko,
       gt_xekpo   TYPE STANDARD TABLE OF ekpo,
       gt_xeket   TYPE STANDARD TABLE OF eket,
       gr_datum   TYPE RANGE OF sy-datum.

DATA : gt_heads   TYPE STANDARD TABLE OF zgdmmst0056,
       gt_detls   TYPE STANDARD TABLE OF zgdmmst0056,
       gs_alloc   TYPE zgdmmst0056.

DATA : gt_yekko   TYPE STANDARD TABLE OF ekko,
       gt_yekpo   TYPE STANDARD TABLE OF ekpo.
