*----------------------------------------------------------------------*
*   INCLUDE ZF_GSPOSTTOP
*----------------------------------------------------------------------*
INCLUDE <icon>.
TYPE-POOLS: truxs.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: zfgscab, sscrfields, kna1, zfgskunnr, zfgstype, bsis,
        zfgscab_add, zfgsnomor.

TYPES : BEGIN OF ty_add.
          INCLUDE STRUCTURE zfgsdntmmt_add.
          TYPES : waers  TYPE t001-waers,
          kacgrp TYPE zfgstmmt3-kacgrp,
        END OF ty_add.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: gv_status    TYPE i,
      gv_bktxt     TYPE bktxt,
      gv_zsubtype  TYPE zsubtype,
      gv_zinputppn TYPE zinputppn.

DATA: gt_zfgstt    TYPE STANDARD TABLE OF zfgstt.
DATA: gv_fname    TYPE tdsfname,
      gv_petugas1 TYPE zgdtxde_name1,
      gv_jabat1   TYPE zgdtxde_d3titel1a,
      gv_petugas2 TYPE zgdtxde_name2,
      gv_jabat2   TYPE zgdtxde_d3titel2a,
      gv_graph    TYPE char20.

DATA: fill    TYPE i,
      lines   TYPE i,
      ok_code TYPE sy-ucomm,
      save_ok TYPE sy-ucomm.

DATA: gv_bschl      TYPE bschl,
      gv_hkont      TYPE hkont,
      gv_txt20      TYPE txt20_skat,
      gv_waers      TYPE waers VALUE 'IDR',
      gv_wrbtr(15),
      gv_wrbtr1(15),
      gv_wrbtrt     TYPE bseg-wrbtr,
      gv_zfbdt      TYPE dzfbdt,
      gv_zuonr      TYPE dzuonr.

DATA: gv_gsber1 TYPE gsber,
      gv_gsber2 TYPE gsber.

CONTROLS: mantax  TYPE TABLEVIEW USING SCREEN 9002,
          manba   TYPE TABLEVIEW USING SCREEN 9003,
          manhk   TYPE TABLEVIEW USING SCREEN 9004,
          mantext TYPE TABLEVIEW USING SCREEN 9005.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: gt_zfgstmmt LIKE zfgstmmt OCCURS 0 WITH HEADER LINE.
DATA: gt_zfgsstm LIKE zfgsstm OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_subtype OCCURS 0,
        zsubtype TYPE zsubtype,
        zstext   TYPE zstext,
        loekz    TYPE loekz,
      END OF gt_subtype.

DATA: BEGIN OF gt_tbsl OCCURS 0,
        bschl TYPE bschl,
        shkzg TYPE shkzg,
        koart TYPE koart,
      END OF gt_tbsl.

DATA: BEGIN OF gt_zfgscab OCCURS 0,
        bukrs      TYPE bukrs,
        gsber      TYPE gsber,
        belnr      TYPE belnr_d,
        gjahr      TYPE gjahr,
        buzei      TYPE buzei,
        budat      TYPE budat,
        bldat      TYPE bldat,
        xblnr      TYPE xblnr1,
        xref2      TYPE xref2,
        xref3      TYPE xref3,
        zuonr      TYPE dzuonr,
        sgtxt      TYPE sgtxt,
        zgsno      TYPE zgsno,
        ztype      TYPE ztype_gs,
        zsubtype   TYPE zsubtype,
        vbund      TYPE rassc,
        kunnr      TYPE kunnr,
        waers      TYPE waers,
        shkzg      TYPE shkzg,
        wrbtr      TYPE wrbtr,
        hkont      TYPE hkont,
        txt1       TYPE ztxt100,
        txt2       TYPE ztxt100,
        txt3       TYPE ztxt100,
        txt4       TYPE ztxt100,
        belnrgs    TYPE belnr_d,
        usergs     TYPE zupos,
        tglgs      TYPE zdpos,
        belnrrevgs TYPE belnr_d,
        userrevgs  TYPE zupos,
        tglrevgs   TYPE zdpos,
        belnrpost  TYPE belnr_d,
        belnrdn    TYPE belnr_d,
        gjahrpost  TYPE gjahr,
        userpost   TYPE zupos,
        postdt     TYPE budat,
        tglpost    TYPE zdpos,
        jampost    TYPE zzpos,
        belnrrev   TYPE belnr_d,
        belnrrevdn TYPE belnr_d,
        userrev    TYPE zurev,
        tglrev     TYPE zdrev,
        kuntm      TYPE kunnr,
        perfr      TYPE budat,
        perto      TYPE budat,
        vbundx     TYPE vbund,
        kunnrx     TYPE kunnr,
        zdesc      TYPE txt50,
      END OF gt_zfgscab.

DATA: BEGIN OF gt_zfgsacc OCCURS 0,
        ztype       TYPE ztype_gs,
        zsubtype    TYPE zsubtype,
        gsber       TYPE gsber,
        blart       TYPE blart,
        bschl1      TYPE bschl,
        hkont1      TYPE hkont,
        mwskz1      TYPE mwskz,
        ztax1       TYPE ztax1,
        bschl2      TYPE bschl,
        hkont2      TYPE hkont,
        mwskz2      TYPE mwskz,
        ztax2       TYPE ztax1,
        bschl3      TYPE bschl,
        hkont3      TYPE hkont,
        mwskz3      TYPE mwskz,
        ztax3       TYPE ztax1,
        bschl4      TYPE bschl,
        hkont4      TYPE hkont,
        mwskz4      TYPE mwskz,
        ztax4       TYPE ztax1,
        bschl5      TYPE bschl,
        hkont5      TYPE hkont,
        mwskz5      TYPE mwskz,
        ztax5       TYPE ztax1,
        bschl6      TYPE bschl,
        hkont6      TYPE hkont,
        mwskz6      TYPE mwskz,
        ztax6       TYPE ztax1,
        bschl7      TYPE bschl,
        hkont7      TYPE hkont,
        mwskz7      TYPE mwskz,
        ztax7       TYPE ztax1,
        bschl8      TYPE bschl,
        hkont8      TYPE hkont,
        mwskz8      TYPE mwskz,
        ztax8       TYPE ztax1,
        zpostdn     TYPE zpostdn,
        zprntdn     TYPE zprntdn,
        zinputppn   TYPE zinputppn,
        zinputgsber TYPE zinputgsber,
        zinputhkont TYPE zinputhkont,
        kostl	      TYPE kostl,
        vbund	      TYPE vbund,
        vkorg	      TYPE vkorg,
        werks	      TYPE werks_d,
        kmvkbu      TYPE vkbur,
        wwsfr	      TYPE rkeg_wwsfr,
        wwpfn	      TYPE rkeg_wwpfn,
        wwpos	      TYPE rkeg_wwpos,
      END OF gt_zfgsacc.
DATA: gt_zfgsaccdn  LIKE gt_zfgsacc OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_post OCCURS 0,
        buzeipost       TYPE buzei,
        bldat           TYPE bldat,
        blart           TYPE blart,
        bukrs           TYPE bukrs,
        budat           TYPE budat,
        waers           TYPE waers,
        gsber           TYPE gsber,
        belnr           TYPE belnr_d,
        buzei           TYPE buzei,
        gjahr           TYPE gjahr,
        xblnr           TYPE xblnr1,
        sgtxt           TYPE sgtxt,
        ogtxt           TYPE sgtxt,
        bktxt           TYPE bktxt,
        bschl           TYPE bschl,
        vbund           TYPE vbund,
        kostl           TYPE kostl,
        account(10),
        description(40),
        wrbtr           TYPE wrbtr,
        koart           TYPE koart,
        mwskz           TYPE mwskz,
        zfbdt           TYPE dzfbdt,
        zuonr           TYPE dzuonr,
        ztype           TYPE ztype_gs,
        zsubtype        TYPE zsubtype,
        vkorg	          TYPE vkorg,
        werks	          TYPE werks_d,
        kmvkbu          TYPE vkbur,
        wwsfr	          TYPE rkeg_wwsfr,
        wwpfn	          TYPE rkeg_wwpfn,
        wwpos	          TYPE rkeg_wwpos,
        kuntm           TYPE kunnr,
        icon(4),
      END OF gt_post.
DATA: gt_postacc LIKE gt_post OCCURS 0 WITH HEADER LINE,
      gt_postdn  LIKE gt_post OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_kna1 OCCURS 0,
        kunnr      TYPE kunnr,
        name1      TYPE ad_name1,
        street     TYPE ad_street,
        post_code1 TYPE ad_pstcd1,
        city1      TYPE ad_city1,
      END OF gt_kna1.

DATA: BEGIN OF gt_skat OCCURS 0,
        saknr TYPE saknr,
        txt20 TYPE txt20_skat,
      END OF gt_skat.

DATA: BEGIN OF gt_out OCCURS 0.
        INCLUDE STRUCTURE gt_zfgscab.
        DATA:   blart    TYPE blart,
        xref1    TYPE xref1,
        actdes   TYPE zactdesc,
*        kunnrx   TYPE kunnr,
*        vbundx   TYPE vbund,
        check(1),
      END OF gt_out.

DATA: BEGIN OF gt_out8 OCCURS 0,
        bukrs     TYPE bukrs,
        gsber     TYPE gsber,
        belnr     TYPE belnr_d,
        gjahr     TYPE gjahr,
        budat     TYPE budat,
        belnrgs   TYPE belnr_d,
        belnrdn   TYPE belnr_d,
        gjahrpost TYPE gjahr,
        budat_dn  TYPE budat,
        zgsno     TYPE zgsno,
        xref2     TYPE xref2,
        clnr      TYPE zclnr,
      END OF gt_out8.

DATA: BEGIN OF gt_error OCCURS 0,
        bktxt        TYPE bktxt,
        message(220),
      END OF gt_error.

DATA: BEGIN OF gt_mantax OCCURS 0,
        bschl   TYPE bschl,
        hkont   TYPE hkont,
        txt20   TYPE txt20_skat,
        wrbtr   TYPE wrbtr,
        flag(1),
      END OF gt_mantax.
DATA: wa_mantax   LIKE gt_mantax.

DATA: BEGIN OF gt_manba OCCURS 0,
        bschl   TYPE bschl,
        sgtxt   TYPE sgtxt,
        wrbtr   TYPE wrbtr,
        gsber   TYPE gsber,
        flag(1),
      END OF gt_manba.
DATA: wa_manba   LIKE gt_manba.

DATA: BEGIN OF gt_manhk OCCURS 0,
        blart   TYPE blart,
        bschl   TYPE bschl,
        sgtxt   TYPE sgtxt,
        wrbtr   TYPE wrbtr,
        hkont   TYPE hkont,
        zfbdt   TYPE dzfbdt,
        zuonr   TYPE dzuonr,
        vbund   TYPE vbund,
        kostl   TYPE kostl,
        flag(1),
      END OF gt_manhk.
DATA: wa_manhk   LIKE gt_manhk.

DATA: BEGIN OF gt_mantext OCCURS 0,
        hkont   TYPE hkont,
        ltext   TYPE tdline,
        wrbtr   TYPE wrbtr,
        flag(1),
      END OF gt_mantext.
DATA: wa_mantext   LIKE gt_mantext.

DATA: BEGIN OF gt_zfgsgsber OCCURS 0,
        gsber TYPE gsber,
        hkont TYPE hkont,
      END OF gt_zfgsgsber.

DATA: BEGIN OF gt_zfgsnomor OCCURS 0,
        gsber   TYPE gsber,
        spmon   TYPE spmon,
        ztype   TYPE ztype,
        prefix1 TYPE zprefix1,
        prefix2 TYPE zprefix2,
        nomor   TYPE znomor2,
      END OF gt_zfgsnomor.

DATA: gt_header LIKE bapiache09 OCCURS 0 WITH HEADER LINE,
      obj_type  LIKE bapiache09-obj_type.

* Acc
DATA: glacc   LIKE TABLE OF bapiacgl09 WITH HEADER LINE,
      apacc   LIKE TABLE OF bapiacap09 WITH HEADER LINE,
      aracc   LIKE TABLE OF bapiacar09 WITH HEADER LINE,
      extacc  LIKE TABLE OF bapiacextc WITH HEADER LINE,
      curracc LIKE TABLE OF bapiaccr09 WITH HEADER LINE,
      retacc  LIKE TABLE OF bapiret2 WITH HEADER LINE,
      headacc LIKE bapiache09.

* DN
DATA: gldn     LIKE TABLE OF bapiacgl09 WITH HEADER LINE,
      apdn     LIKE TABLE OF bapiacap09 WITH HEADER LINE,
      ardn     LIKE TABLE OF bapiacar09 WITH HEADER LINE,
      extdn    LIKE TABLE OF bapiacextc WITH HEADER LINE,
      currdn   LIKE TABLE OF bapiaccr09 WITH HEADER LINE,
      criteria LIKE TABLE OF bapiackec9 WITH HEADER LINE,
      retdn    LIKE TABLE OF bapiret2 WITH HEADER LINE,
      headdn   LIKE bapiache09.

DATA: gt_head    LIKE zfstgsdn OCCURS 0 WITH HEADER LINE,
      gv_t001    LIKE zfstgsdn,
      gt_detail  LIKE zfstgsdn OCCURS 0 WITH HEADER LINE,
      gv_tmmt(1),
      gv_stm(1).

DATA : gt_flag  TYPE STANDARD TABLE OF zfgsflagtype INITIAL SIZE 0.

DATA: gv_gsnomor    LIKE zfgsnomor-nomor,
      gv_gsber      TYPE gsber,
      gv_gtext      TYPE gtext,
      gv_sgtxt(100).

DATA : gv_flag.
DATA : gv_filepusat LIKE zfgscab_add-filepusat.

DATA: gt_url          TYPE char255,
      gt_excela       TYPE TABLE OF zfgsst_download WITH HEADER LINE,
      gt_zfgscab_add  TYPE TABLE OF zfgscab_add WITH HEADER LINE,
      t_alv_excluding TYPE slis_t_extab,
      s_alv_excluding TYPE slis_extab.

FIELD-SYMBOLS: <fs_postdn> LIKE gt_post.

CONSTANTS: gc_path TYPE zfilecabang VALUE '/interface3/NIS/KP/'.

DATA : gs_add         TYPE ty_add.

FIELD-SYMBOLS : <fs_tab>  TYPE STANDARD TABLE.

DATA : gt_zfgstmmt2 TYPE STANDARD TABLE OF zfgstmmt2,
       gt_zfgstmmt3 TYPE STANDARD TABLE OF zfgstmmt3.

DATA : gt_cust     TYPE STANDARD TABLE OF zfgstmmt_cust,
       gv_subrc    TYPE sy-subrc,
       gt_customer TYPE STANDARD TABLE OF zfgskunnr.
