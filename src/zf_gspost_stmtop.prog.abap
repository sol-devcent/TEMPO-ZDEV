*----------------------------------------------------------------------*
*   INCLUDE ZF_GSPOST_STMTOP
*----------------------------------------------------------------------*
INCLUDE <icon>.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: zfgscab, sscrfields, kna1, zfgskunnr, zfgstype, bsis,
        zfgsdnstm, bkpf.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: gv_status    TYPE i,
      gv_bktxt     TYPE bktxt,
      gv_zsubtype  TYPE zsubtype,
      gv_zinputppn TYPE zinputppn.

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
      gv_zfbdt      TYPE dzfbdt,
      gv_zuonr      TYPE dzuonr.

DATA: gv_gsber1 TYPE gsber,
      gv_gsber2 TYPE gsber.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
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
        txt1       TYPE ztxt,
        txt2       TYPE ztxt,
        txt3       TYPE ztxt,
        txt4       TYPE ztxt,
        belnrgs    TYPE belnr_d,
        belnrpost  TYPE belnr_d,
        belnrdn    TYPE belnr_d,
        gjahrpost  TYPE gjahr,
        userpost   TYPE zupos,
        tglpost    TYPE zdpos,
        jampost    TYPE zzpos,
        belnrrev   TYPE belnr_d,
        belnrrevdn TYPE belnr_d,
        userrev    TYPE zurev,
        tglrev     TYPE zdrev,
      END OF gt_zfgscab.

DATA : gt_zfgsdnstm LIKE zfgsdnstm OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF gt_bkpf OCCURS 0,
         bukrs TYPE bukrs,
         belnr TYPE belnr_d,
         gjahr TYPE gjahr,
         budat TYPE budat,
         xblnr TYPE xblnr1,
         bktxt TYPE bktxt,
       END OF gt_bkpf.

DATA : BEGIN OF gt_bseg OCCURS 0,
         bukrs TYPE bukrs,
         belnr TYPE belnr_d,
         gjahr TYPE gjahr,
         buzei TYPE buzei,
         bschl TYPE bschl,
         koart TYPE koart,
         shkzg TYPE shkzg,
         dmbtr TYPE dmbtr,
         zuonr TYPE dzuonr,
         hkont TYPE hkont,
         wrbtr TYPE wrbtr,
         vbund TYPE rassc,
         xref1 TYPE xref1,
         xref2 TYPE xref2,
         xref3 TYPE xref3,
       END OF gt_bseg.

DATA: BEGIN OF gt_t880 OCCURS 0,
        rcomp TYPE rcomp_d,
        name2 TYPE name_2,
      END OF gt_t880.

DATA: BEGIN OF gt_zfgskunnr OCCURS 0,
        vbund TYPE vbund,
        kunnr TYPE kunnr,
        zterm TYPE dzterm,
      END OF gt_zfgskunnr.

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
        bktxt           TYPE bktxt,
        bschl           TYPE bschl,
        vbund           TYPE vbund,
        kostl           TYPE kostl,
        account(10),
        description(50),
        wrbtr           TYPE wrbtr,
        koart           TYPE koart,
        mwskz           TYPE mwskz,
        zfbdt           TYPE dzfbdt,
        zuonr           TYPE dzuonr,
        zsubtype        TYPE zsubtype,
        xref2           TYPE xref2,
        xref3           TYPE xref3,
        maktx           TYPE zmaktx1,
        nopaaf          TYPE znopaaf,
        nomordn         TYPE zdnno,
        zterm           TYPE dzterm,
        icon(4),
      END OF gt_post.

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
        txt50 TYPE txt50_skat,
      END OF gt_skat.

DATA: BEGIN OF gt_out OCCURS 0.
        INCLUDE STRUCTURE gt_zfgscab.
        DATA:   blart         TYPE blart,
        xref1         TYPE xref1,
        bktxt         TYPE bktxt,
        nomordn       TYPE zdnno,
        nopaaf(50),
        maktx         TYPE maktx,
        zterm         TYPE dzterm,
        cabang(70),
        principal(70),
        budatdn       TYPE budat,
        wrbtrdn       TYPE wrbtr,
        belnrdnrev    TYPE belnr_d,
        kunnrx        TYPE kunnr,
        vbundx        TYPE vbund,
        check(1),
      END OF gt_out.
DATA: gt_out1   LIKE gt_out OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_error OCCURS 0,
        bktxt        TYPE bktxt,
        message(220),
      END OF gt_error.

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
DATA: gt_nomor_temp  LIKE gt_zfgsnomor OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_nomor OCCURS 0,
        belnr TYPE belnr_d,
        gjahr TYPE gjahr,
        nomor TYPE znomor2,
      END OF gt_nomor.

DATA: gt_header LIKE bapiache09 OCCURS 0 WITH HEADER LINE,
      obj_type  LIKE bapiache09-obj_type.

DATA: gl       LIKE TABLE OF bapiacgl09 WITH HEADER LINE,
      ap       LIKE TABLE OF bapiacap09 WITH HEADER LINE,
      ar       LIKE TABLE OF bapiacar09 WITH HEADER LINE,
      ext      LIKE TABLE OF bapiacextc WITH HEADER LINE,
      curr     LIKE TABLE OF bapiaccr09 WITH HEADER LINE,
      criteria LIKE TABLE OF bapiackec9 WITH HEADER LINE,
      ret      LIKE TABLE OF bapiret2 WITH HEADER LINE,
      head     LIKE bapiache09.

DATA: gt_head     LIKE zfstgsdn OCCURS 0 WITH HEADER LINE,
      gv_t001     LIKE zfstgsdn,
      gt_detail   LIKE zfstgsdn OCCURS 0 WITH HEADER LINE,
      gt_add      LIKE zfgsdntmmt_add OCCURS 0 WITH HEADER LINE,
      gt_customer TYPE STANDARD TABLE OF zfgskunnr.

CONSTANTS : gc_hkont TYPE hkont VALUE '0122310700',
            gc_bschl TYPE bschl VALUE '50',
            gc_koart TYPE koart VALUE 'S'.

DATA: gv_gsnomor LIKE zfgsnomor-nomor.

FIELD-SYMBOLS: <fs_postdn> LIKE gt_post,
               <fs_tab>    TYPE STANDARD TABLE.
