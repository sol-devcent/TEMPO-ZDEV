*----------------------------------------------------------------------*
*   INCLUDE ZM_VENDOR_EVALUATIONTOP                                    *
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: eket, ekko, ekpo, sscrfields.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
RANGES: ra_inter1 FOR ekbe-budat,
        ra_inter2 FOR ekbe-budat,
        ra_inter3 FOR ekbe-budat,
        ra_inter4 FOR ekbe-budat,
        ra_inter5 FOR ekbe-budat.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF t_zvend_eval OCCURS 0.
        INCLUDE STRUCTURE zvend_eval.
DATA: END OF t_zvend_eval.

DATA: BEGIN OF t_zt052 OCCURS 0.
        INCLUDE STRUCTURE zt052.
DATA: END OF t_zt052.

DATA: BEGIN OF t_history OCCURS 0.
        INCLUDE STRUCTURE zstvend_eval.
DATA:   bsart TYPE esart,
        eindt TYPE eindt,
        key   TYPE char30,
      END OF t_history.

DATA: BEGIN OF t_realisasi OCCURS 0.
        INCLUDE STRUCTURE zstvend_eval.
DATA: END OF t_realisasi.

DATA: BEGIN OF t_ekbeh OCCURS 0.
        INCLUDE STRUCTURE ekbe.
DATA:   sisa  LIKE ekbe-menge,
        read_flg(1),
      END OF t_ekbeh.
DATA t_ekbeh_101 LIKE t_ekbeh OCCURS 0 WITH HEADER LINE.
DATA t_ekbeh_rj LIKE t_ekbeh OCCURS 0 WITH HEADER LINE.


DATA: BEGIN OF t_ekbe1 OCCURS 0.
        INCLUDE STRUCTURE t_ekbeh.
DATA: END OF t_ekbe1.

DATA: BEGIN OF t_ekber OCCURS 0.
        INCLUDE STRUCTURE ekbe.
DATA: END OF t_ekber.

DATA: BEGIN OF t_ekbedata OCCURS 0,
        ebeln    LIKE ekbe-ebeln,
        ebelp    LIKE ekbe-ebelp,
        belnr    LIKE ekbe-belnr,
        buzei    LIKE ekbe-buzei,
        bwart    LIKE ekbe-bwart,
        budat    LIKE ekbe-budat,
        shkzg    LIKE ekbe-shkzg,
        menge    LIKE ekbe-menge,
        rjqty    LIKE ekbe-menge,
        matnr    LIKE ekbe-matnr,
        lifnr    LIKE ekko-lifnr,
        bldat    LIKE ekbe-bldat,
        lfbnr    LIKE ekbe-lfbnr,
        count    TYPE i,
        cancel   TYPE i.
DATA: END OF t_ekbedata.

DATA: BEGIN OF t_eketdata2 OCCURS 0,
        ebeln    TYPE ebeln,
        ebelp    TYPE ebelp,
        bsart    TYPE esart,
        etenr    LIKE eket-etenr,
        eindt    TYPE eindt,
        budat    TYPE budat,
        belnr    TYPE mblnr,
        menge    LIKE ekbe-menge,
        grqty    LIKE ekbe-menge,
        sisa     LIKE ekbe-menge,
        total    LIKE ekbe-menge,
        matnr    LIKE ekbe-matnr,
        lifnr    LIKE ekko-lifnr,
        key      TYPE char30.
DATA: END OF t_eketdata2.
DATA  t_eketdata3 LIKE t_eketdata2 OCCURS 0 WITH HEADER LINE.
DATA  t_eketdata3sum LIKE t_eketdata2 OCCURS 0 WITH HEADER LINE.
DATA  gs_eketdata3sum LIKE t_eketdata3sum.

DATA: BEGIN OF t_eketh OCCURS 0.
        INCLUDE STRUCTURE eket.
DATA:   matnr       LIKE ekpo-matnr,
        lifnr       LIKE ekko-lifnr,
        menge_ekbe  LIKE ekbe-menge,
        grqty       LIKE ekbe-menge,
        rjqty       LIKE ekbe-menge,
        sisa        LIKE ekbe-menge,
        sisa_rj     LIKE ekbe-menge,
        key         TYPE char30,
      END OF t_eketh.
DATA  gs_eketh  LIKE t_eketh.
DATA t_eketh_sv LIKE t_eketh OCCURS 0 WITH HEADER LINE.
DATA t_eketh1   LIKE t_eketh OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF t_eketr OCCURS 0.
        INCLUDE STRUCTURE eket.
DATA: END OF t_eketr.

DATA: BEGIN OF t_eketdata OCCURS 0,
        ebeln  LIKE eket-ebeln,
        ebelp  LIKE eket-ebelp,
        count  TYPE i,
        menge  TYPE i,
        wemng  TYPE i.
DATA: END OF t_eketdata.

DATA: BEGIN OF t_interval OCCURS 0.
        INCLUDE STRUCTURE t_history.
DATA:   etenr       LIKE eket-etenr,
*        eindt       LIKE eket-eindt,
        menge_eket  LIKE eket-menge,
        wemng       LIKE eket-wemng,
        budat       LIKE ekbe-budat,
        firstbudat  LIKE ekbe-budat,
        firstqtygr  LIKE eket-menge,
        qtylate01   LIKE eket-menge,
        qtylate02   LIKE eket-menge,
        qtylate03   LIKE eket-menge,
        qtylate04   LIKE eket-menge,
        qtyotim     LIKE eket-menge,
        grpo_first  TYPE p DECIMALS 0.
DATA: END OF t_interval.

DATA: BEGIN OF t_scord OCCURS 0,
        matnr  LIKE ekpo-matnr,
        lifnr  LIKE ekko-lifnr,
        nilai  LIKE zvend_eval-nilai,
        menge  LIKE eket-menge,
        count  TYPE i,
        scord  LIKE zstvend_eval-scord,
        bdelv  LIKE zstvend_eval-bdelv.
DATA: END OF t_scord.

DATA: BEGIN OF t_makt OCCURS 0,
        matnr  LIKE makt-matnr,
        maktx  LIKE makt-maktx.
DATA: END OF t_makt.

DATA: BEGIN OF t_adrc OCCURS 0,
        lifnr  LIKE lfa1-lifnr,
        name1  LIKE adrc-name1.
DATA: END OF t_adrc.

DATA: BEGIN OF t_zterm OCCURS 0.
        INCLUDE STRUCTURE lfm1.
DATA: END OF t_zterm.

DATA: BEGIN OF t_vdata OCCURS 0.
        INCLUDE STRUCTURE zstvend_eval.
DATA: END OF t_vdata.

DATA: BEGIN OF t_out OCCURS 0.
        INCLUDE STRUCTURE zstvend_eval.
DATA: END OF t_out.

DATA: BEGIN OF gt_eina OCCURS 0,
        infnr TYPE infnr,
        matnr TYPE matnr,
        matkl TYPE matkl,
        lifnr TYPE elifn,
        ekorg TYPE ekorg,
        esokz TYPE esokz,
        werks TYPE ewerk,
        inco1 TYPE inco1.
DATA: END OF gt_eina.

DATA: gr_eindt1m TYPE RANGE OF eindt WITH HEADER LINE.
DATA: gr_eindt2m TYPE RANGE OF eindt WITH HEADER LINE.
DATA: gr_eindt3m TYPE RANGE OF eindt WITH HEADER LINE.
DATA: gr_eindt6m TYPE RANGE OF eindt WITH HEADER LINE.
DATA: gr_eindt3y TYPE RANGE OF eindt WITH HEADER LINE.
DATA: gt_mseg  TYPE TABLE OF mseg  WITH HEADER LINE.
DATA: gt_mkpf  TYPE TABLE OF mkpf  WITH HEADER LINE.
DATA: gt_eipa  TYPE TABLE OF eipa  WITH HEADER LINE.
DATA: gt_a049  TYPE TABLE OF a049  WITH HEADER LINE.
DATA: gt_a501  TYPE TABLE OF a501  WITH HEADER LINE.
DATA: gt_konpb TYPE TABLE OF konp  WITH HEADER LINE.
DATA: gt_konpb2 TYPE TABLE OF konp  WITH HEADER LINE.
DATA: gt_a018  TYPE TABLE OF a018  WITH HEADER LINE.
DATA: gt_konph TYPE TABLE OF konp  WITH HEADER LINE.
DATA: gt_mara  TYPE TABLE OF mara  WITH HEADER LINE.
DATA: gr_matmpn TYPE RANGE OF matnr WITH HEADER LINE.
DATA: gv_index LIKE sy-tabix.
DATA: gv_fieldname  TYPE slis_fieldname.

CONSTANTS: gc_item_limit TYPE int3 VALUE 6.

FIELD-SYMBOLS: <fs_out> LIKE t_out.
