*&---------------------------------------------------------------------*
*&  Include           ZGHFI_E001_TOP
*&---------------------------------------------------------------------*
TABLES: zcoretax0001, zcoretax0002, vbrk, vbrp, vttk, vttp, zmm_cust_rec, bseg, zfnoefaktur, zdg2fidt0008,
        zdg2fidt0009, bkpf, zcoretax0007.
TYPE-POOLS: rmdi, kcde.

TYPES: BEGIN OF ty_header,
         chkbx,
         bukrs      TYPE vbrk-bukrs,
         fkdat      TYPE vbrk-fkdat,
         kunrg      TYPE vbrk-kunrg,
         vbeln      TYPE vbrk-vbeln,
         fkart      TYPE vbrk-fkart,
         zuonr      TYPE vbrk-zuonr,
         netwr      TYPE vbrk-netwr,
         cityc      TYPE kna1-cityc,
         stcd1      TYPE kna1-stcd1,
         stcd3      TYPE kna1-stcd3,
         stcd5      TYPE kna1-stcd5,
         stcd6      TYPE kna1-stcd6,
         stceg      TYPE kna1-stceg,
         gform      TYPE kna1-gform,
         vattrn     TYPE zfvattrn-vattrn,
         name_co    TYPE adrc-name_co,
         str_suppl1 TYPE adrc-str_suppl1,
         str_suppl2 TYPE adrc-str_suppl2,
         str_suppl3 TYPE adrc-str_suppl3,
         location   TYPE adrc-location,
         vkbur      TYPE vbrp-vkbur,
         vgbel      TYPE vbrp-vgbel,
         txdat      TYPE zmm_cust_rec-txdat,
         vbtyp      TYPE vbrk-vbtyp,
         werks      TYPE vbrp-werks,
         knumv      TYPE vbrk-knumv,
         fksto      TYPE vbrk-fksto,
       END OF ty_header.
TYPES: BEGIN OF ty_8220h,
         bukrs      TYPE zdg2fidt0008-bukrs,
         bbill      TYPE zdg2fidt0008-bbill,
         bidat      TYPE zdg2fidt0008-bidat,
         zzkdctr    TYPE zdg2fidt0008-zzkdctr,
         zzkunn2    TYPE zdg2fidt0008-zzkunn2,
         name1      TYPE adrc-name1,
         cityc      TYPE kna1-cityc,
         stcd1      TYPE kna1-stcd1,
         stcd3      TYPE kna1-stcd3,
         stcd5      TYPE kna1-stcd5,
         stcd6      TYPE kna1-stcd6,
         stceg      TYPE kna1-stceg,
         gform      TYPE kna1-gform,
         vattrn     TYPE zfvattrn-vattrn,
         street     TYPE adrc-street,
         str_suppl1 TYPE adrc-str_suppl1,
         str_suppl2 TYPE adrc-str_suppl2,
         str_suppl3 TYPE adrc-str_suppl3,
         city1      TYPE adrc-city1,
       END OF ty_8220h.
TYPES: BEGIN OF ty_8220d,
         bbill       TYPE zdg2fidt0009-bbill,
         bidat       TYPE zdg2fidt0009-bidat,
         matnr       TYPE zdg2fidt0009-matnr,
         zzbrand     TYPE zdg2fidt0009-zzbrand,
         maktx       TYPE zdg2fidt0009-maktx,
         hargasatuan TYPE zdg2fidt0009-hargasatuan, "price
         zzqty       TYPE zdg2fidt0009-zzqty,   "QTY
         discount    TYPE zdg2fidt0009-discount, "Total discount
         zzppn       TYPE zdg2fidt0009-zzppn, "TAX
         jumlah      TYPE zdg2fidt0009-jumlah, "NETWR
       END OF ty_8220d.
TYPES: BEGIN OF ty_header_xml,
         chkbx,
         bukrs                   TYPE vbrk-bukrs,
         fkdat                   TYPE vbrk-fkdat,
         kunrg                   TYPE vbrk-kunrg,
         vbeln                   TYPE char10,
         vkbur                   TYPE vbrp-vkbur,
         zuonr                   TYPE vbrk-zuonr,
         total_taxbase           TYPE netwr,
         total_vat               TYPE netwr,
         total_diskon            TYPE netwr,

         taxinvoicedate(10), "      TYPE string,
         taxinvoiceopt(10), "       TYPE string,
         trxcode(3), "             TYPE string,
         addinfo                 TYPE string,
         customdoc               TYPE string,
         customdocmonthyear      TYPE string,
         refdesc(60), "             TYPE string,
         facilitystamp           TYPE string,
         selleridtku(50), "         TYPE string,
         buyertin(50), "            TYPE string,
         buyerdocument(20), "       TYPE string,
         buyercountry(3), "        TYPE string,
         buyerdocumentnumber(16), " TYPE string,
         buyername(40), "           TYPE string,
         buyeradress(250), "         TYPE string,
         buyeremail              TYPE string,
         buyeridtku(50), "          TYPE string,
         error(1),
         nourut                  TYPE i,
         icon                    TYPE icon_d,  "icon_red_light
         mess_error(200),
       END OF ty_header_xml.
TYPES: BEGIN OF  ty_detail_xml,
         vbeln              TYPE vbrk-vbeln,
         matnr              TYPE vbrp-matnr,
         maktx              TYPE makt-maktx,
         netwr              TYPE vbrp-netwr,
         opt(2),
         code(10),
         name(250),
         unit(10),
         price(15),
         qty(15),
         totaldiscount(15),
         taxbase(15),
         othertaxbase(15),
         vatrate(3),
         vat(15),
         stlgrate(10),
         stlg(15),

         vprice             TYPE netwr,
         vqty               TYPE lips-lfimg,
         vtotaldiscount     TYPE netwr,
         vtaxbase           TYPE netwr,
         vothertaxbase      TYPE netwr,
         vvat               TYPE netwr,
         message_error(150),
         icon               TYPE icon_d,  "icon_red_light
       END OF ty_detail_xml.
TYPES: BEGIN OF ty_vbrk,
         vkbur             TYPE vbrp-vkbur,
         vbeln             TYPE vbrk-vbeln,
         posnr             TYPE vbrp-posnr,
         "         fkart             type vbrk-fkart,
         matnr             TYPE vbrp-matnr,
         maktx             TYPE makt-maktx,
         arktx             TYPE vbrp-arktx,
         meins             TYPE vbrp-meins,
         netwr             TYPE vbrp-netwr,
         fkimg             TYPE vbrp-fkimg,
         kzwi6             TYPE vbrp-kzwi6,
         kzwi2             TYPE vbrp-kzwi2,
         kzwi3             TYPE vbrp-kzwi3,
         kzwi4             TYPE vbrp-kzwi4,
         kzwi1             TYPE vbrp-kzwi1,
         name(120),
         unit(10),
         price(15),
         qty(15),
         totaldiscount(15),
         taxbase(15),
         othertaxbase(15),
         vatrate(3),
         vat(15),
         stlgrate(10),
         stlg(15),
         vprice            TYPE netwr,
         vqty              TYPE lips-lfimg,
         vtotaldiscount    TYPE netwr,
         vtaxbase          TYPE netwr,
         vothertaxbase     TYPE netwr,
         vvat              TYPE netwr,


       END OF ty_vbrk.
TYPES: BEGIN OF ty_bseg,
         bukrs TYPE bseg-bukrs,
         belnr TYPE bseg-belnr,
         matnr TYPE bseg-matnr,
         dmbtr TYPE bseg-dmbtr,
         "         hkont type
       END OF ty_bseg.
TYPES: BEGIN OF ty_vttk,
         tknum      TYPE vttk-tknum,
         erdat      TYPE vttk-erdat,
         tpnum      TYPE vttp-tpnum,
         vbeln      TYPE vttp-vbeln,
         kunnr      TYPE likp-kunnr,
         cityc      TYPE kna1-cityc,
         stcd1      TYPE kna1-stcd1,
         stcd3      TYPE kna1-stcd3,
         stcd5      TYPE kna1-stcd5,
         stcd6      TYPE kna1-stcd6,
         stceg      TYPE kna1-stceg,
         name_co    TYPE adrc-name_co,
         str_suppl1 TYPE adrc-str_suppl1,
         str_suppl2 TYPE adrc-str_suppl2,
         str_suppl3 TYPE adrc-str_suppl3,
         location   TYPE adrc-location,
         vkbur      TYPE vbrp-vkbur,
         gform      TYPE kna1-gform,
         vattrn     TYPE zfvattrn-vattrn,
       END OF ty_vttk.

TYPES: BEGIN OF ty_lips,
         tknum TYPE vttk-tknum,
         erdat TYPE vttk-erdat,
         vbeln TYPE lips-vbeln,
         posnr TYPE lips-posnr,
         matnr TYPE lips-matnr,
         lfimg TYPE lips-lfimg,
         maktx TYPE makt-maktx,
         kbetr TYPE konp-kbetr,
         kpein TYPE konp-kpein,
         stawn TYPE marc-stawn,
         werks TYPE lips-werks,
         mvgr5 TYPE mvke-mvgr5,
       END OF ty_lips.
TYPES: BEGIN OF ty_a017,
         matnr TYPE a017-matnr,
         lifnr TYPE a017-lifnr,
         knumh TYPE a017-knumh,
         kbetr TYPE konp-kbetr,
         kpein TYPE konp-kpein,
         datab TYPE a017-datab,
         datbi TYPE a017-datbi,
       END OF ty_a017.

TYPES: BEGIN OF ty_a934,
         matnr TYPE a934-matnr,
         "         lifnr type a017-lifnr,
         knumh TYPE a934-knumh,
         kbetr TYPE konp-kbetr,
         kpein TYPE konp-kpein,
         datab TYPE a934-datab,
         datbi TYPE a934-datbi,
       END OF ty_a934.


TYPES: BEGIN OF ty_nontrade,
         bukrs      TYPE bkpf-bukrs,
         belnr      TYPE bkpf-belnr,
         gjahr      TYPE bkpf-gjahr,
         blart      TYPE bkpf-blart,
         bldat      TYPE bkpf-bldat,
         budat      TYPE bkpf-budat,
         monat      TYPE bkpf-monat,
         gsber      TYPE bseg-gsber,
         bschl      TYPE bseg-bschl,
         kunnr      TYPE bseg-kunnr,
         cityc      TYPE kna1-cityc,
         stcd1      TYPE kna1-stcd1,
         stcd3      TYPE kna1-stcd3,
         stcd5      TYPE kna1-stcd5,
         stcd6      TYPE kna1-stcd6,
         stceg      TYPE kna1-stceg,
         gform      TYPE kna1-gform,
         name_co    TYPE adrc-name_co,
         str_suppl1 TYPE adrc-str_suppl1,
         str_suppl2 TYPE adrc-str_suppl2,
         str_suppl3 TYPE adrc-str_suppl3,
         location   TYPE adrc-location,
       END OF ty_nontrade.

TYPES: BEGIN OF ty_detail_nontrade,
         bukrs   TYPE bseg-bukrs,
         belnr   TYPE bseg-belnr,
         gjahr   TYPE bseg-gjahr,
         buzei   TYPE bseg-buzei,
         kunnr   TYPE bseg-kunnr,
         koart   TYPE bseg-koart,
         bschl   TYPE bseg-bschl,
         gsber   TYPE bsid-gsber,
         sgtxt   TYPE bseg-sgtxt,
         dmbtr   TYPE bseg-dmbtr,
         wrbtr   TYPE bseg-wrbtr,
         kzbtr   TYPE bseg-kzbtr,
         pswbt   TYPE bseg-pswbt,
         pswsl   TYPE bseg-pswsl,
         hkont   TYPE bseg-hkont,
         shkzg   TYPE bseg-shkzg,
         taxbase TYPE bseg-dmbtr,
         vat     TYPE bseg-dmbtr,
         zuonr   TYPE bseg-zuonr,
         name    TYPE string,

       END OF ty_detail_nontrade.
DATA: gt_nontrade TYPE STANDARD TABLE OF ty_nontrade.
DATA: gt_detail_nontrade TYPE STANDARD TABLE OF ty_detail_nontrade.
DATA: gt_detail_nontrade1 TYPE STANDARD TABLE OF ty_detail_nontrade.
DATA: gt_detail_nontrade2 TYPE STANDARD TABLE OF ty_detail_nontrade.
DATA: gt_detail_nontrade3 TYPE STANDARD TABLE OF ty_detail_nontrade.
DATA: gt_detail_nontrade4 TYPE STANDARD TABLE OF ty_detail_nontrade.
DATA: gt_detail_nontrade5 TYPE STANDARD TABLE OF ty_detail_nontrade. " khusus no trade yg split
DATA: gt_vttk TYPE STANDARD TABLE OF ty_vttk.
DATA: gs_vttk TYPE ty_vttk.
DATA: gt_lips TYPE STANDARD TABLE OF ty_lips.
DATA: gs_lips TYPE ty_lips.
DATA: gt_a017 TYPE STANDARD TABLE OF ty_a017.
DATA: gt_a934 TYPE STANDARD TABLE OF ty_a934.


**DATA: gs_taxinvoicebulk TYPE ty_taxinvoicebulk.
**DATA: gs_taxinvoice TYPE ty_taxinvoice.
**DATA: gs_goodservice TYPE ty_goodservice.
DATA: gt_8220h TYPE STANDARD TABLE OF ty_8220h.
DATA: gt_8220d TYPE STANDARD TABLE OF ty_8220d.
DATA: gs_8220h TYPE  ty_8220h.
DATA: gs_8220d TYPE  ty_8220d.
DATA: gt_header_xml TYPE STANDARD TABLE OF ty_header_xml.
DATA: gt_detail_xml TYPE STANDARD TABLE OF ty_detail_xml.
DATA: gs_header_xml TYPE ty_header_xml.
DATA: gs_detail_xml TYPE ty_detail_xml.
DATA: gt_zcoretax0001 TYPE STANDARD TABLE OF zcoretax0001.
DATA: gt_zcoretax0002 TYPE STANDARD TABLE OF zcoretax0002.
DATA: gt_header TYPE STANDARD TABLE OF ty_header.
DATA: gt_item TYPE STANDARD TABLE OF ty_vbrk WITH HEADER LINE.
DATA: gs_zfnoefaktur TYPE zfnoefaktur.
"DATA: gs_header TYPE ty_header.
DATA: gs_item TYPE ty_vbrk.
DATA: gt_bseg TYPE STANDARD TABLE OF ty_bseg.
DATA: gt_bseg1 TYPE STANDARD TABLE OF ty_bseg. "--> untuk nilai DPP(TaxBase) untuk penjualan Jasa maklon .
DATA: gs_bseg TYPE ty_bseg.
DATA: gs_zgdtxdt0005 TYPE zgdtxdt0005.
DATA: gs_zcoretax0001 TYPE zcoretax0001.
DATA: gs_zcoretax0002 TYPE zcoretax0002.
DATA: gs_zcoretax0003 TYPE zcoretax0003.
DATA: gv_namafile TYPE zcoretax0003-namafile.
DATA: gv_namafileptt TYPE zcoretax0003-namafile.
DATA: gt_zcoretax0003 TYPE STANDARD TABLE OF zcoretax0003.
DATA: gs_zcoretax0004 TYPE zcoretax0004.
DATA: gt_zcoretax0004 TYPE STANDARD TABLE OF zcoretax0004.
DATA: gs_zcoretax0005 TYPE zcoretax0005.
DATA: gt_zcoretax0005 TYPE STANDARD TABLE OF zcoretax0005.
DATA: gt_zcoretax0005_done TYPE STANDARD TABLE OF zcoretax0005.
DATA: g_string       TYPE string,
      g_string_table TYPE TABLE OF string.
DATA: out_string TYPE string,
      out_len    TYPE i.
DATA: gv_line TYPE i, gv_ctr TYPE i.
DATA: gt_zgdtxdt0104 TYPE STANDARD TABLE OF zgdtxdt0104.
DATA: gs_zgdtxdt0104 TYPE zgdtxdt0104.
DATA: gt_zcoretax0007 TYPE STANDARD TABLE OF zcoretax0007.
DATA: gt_zcoretax0010 TYPE STANDARD TABLE OF zcoretax0010.
DATA: gs_zcoretax0007 TYPE zcoretax0007.
FIELD-SYMBOLS: <fs_tab1>  TYPE STANDARD TABLE,
               <fs_tab2>  TYPE STANDARD TABLE,
               <fs_tab3>  TYPE STANDARD TABLE,
               <fs_tab4>  TYPE STANDARD TABLE,
               <fs_tab5>  TYPE STANDARD TABLE,
               <fs_line1> TYPE any,
               <fs_line2> TYPE any,
               <fs_line3> TYPE any,
               <fs_line4> TYPE any,
               <fs_line5> TYPE any.
DATA: gt_lvc_fieldcat TYPE lvc_t_fcat,
      wa_lvc_fieldcat TYPE lvc_s_fcat,
      wa_dyn_tab      TYPE REF TO data,
      gs_line         TYPE REF TO data,
      gt_dyn_table    TYPE REF TO data.
DATA: gt_listoftaxinvoice TYPE REF TO data.
DATA: gt_taxinvoice  TYPE REF TO data.
DATA: gt_listofgoodservice TYPE REF TO data.
DATA: gt_goodservice TYPE REF TO data.
DATA: gt_zdg2fidt0008 TYPE STANDARD TABLE OF zdg2fidt0008.
DATA: gs_zdg2fidt0008 TYPE zdg2fidt0008.
DATA: gt_zdg2fidt0009 TYPE STANDARD TABLE OF zdg2fidt0009.
DATA: gs_zdg2fidt0009 TYPE zdg2fidt0009.
DATA: gt_vbrk TYPE STANDARD TABLE OF ty_vbrk.
DATA: gs_vbrk TYPE ty_vbrk.
DATA: gv_error(1).
DATA: gv_message(200).
