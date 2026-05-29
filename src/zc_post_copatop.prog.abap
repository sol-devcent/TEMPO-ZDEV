*----------------------------------------------------------------------*
*   INCLUDE ZC_POST_COPATOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: sscrfields.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
CONSTANTS gc_hkont  TYPE hkont VALUE '0720100000'.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF gt_out OCCURS 0,
        belnr   TYPE belnr_d,
        budat   TYPE budat,
        perio   TYPE jahrper,
        vrgar   TYPE rke_vrgar,
        kndnr	  TYPE kunde_pa,
        bukrs	  TYPE bukrs,
        artnr	  TYPE artnr,
        werks	  TYPE werks_d,
        prctr	  TYPE prctr,
        gsber	  TYPE gsber,
        spart	  TYPE spart,
        matkl	  TYPE matkl,
        extwg	  TYPE extwg,
        wwprc	  TYPE rkeg_wwprc,
        wwprr	  TYPE rkeg_wwprr,
        wwprd	  TYPE rkeg_wwprd,
        pswsl   TYPE pswsl,
        vv852   TYPE rke2_vv852,
        check(1),
      END OF gt_out.

DATA : BEGIN OF gt_bsis OCCURS 0,
         bukrs  TYPE bukrs,
         hkont  TYPE hkont,
         augdt  TYPE augdt,
         augbl  TYPE augbl,
         zuonr  TYPE dzuonr,
         gjahr  TYPE gjahr,
         belnr  TYPE belnr_d,
         buzei  TYPE buzei,
         budat  TYPE budat.
DATA   END   OF gt_bsis.

DATA : BEGIN OF gt_bseg OCCURS 0,
         bukrs    TYPE bukrs,
         belnr    TYPE belnr_d,
         gjahr    TYPE gjahr,
         buzei    TYPE buzei,
         shkzg    TYPE shkzg,
         pswbt    TYPE pswbt,
         pswsl    TYPE pswsl,
         paobjnr  TYPE rkeobjnr.
DATA   END   OF gt_bseg.

DATA : BEGIN OF gt_ce48010_acct OCCURS 0,
         aktbo    TYPE aktbo,
         paobjnr  TYPE rkeobjnr,
         pasubnr  TYPE rkesubnr,
         kndnr    TYPE kunde_pa,
         artnr    TYPE artnr,
         bukrs    TYPE bukrs,
         werks    TYPE werks_d,
         gsber    TYPE gsber,
         spart    TYPE spart,
         prctr    TYPE prctr,
         ce4key   TYPE copa_ce4key,
         matkl    TYPE matkl,
         extwg    TYPE extwg,
         wwprc    TYPE rkeg_wwprc,
         wwprr    TYPE rkeg_wwprr,
         wwprd    TYPE rkeg_wwprd.
DATA   END   OF gt_ce48010_acct.

DATA : BEGIN OF gt_ce18010 OCCURS 0,
         paledger	TYPE ledbo,
         vrgar    TYPE rke_vrgar,
         versi    TYPE rkeversi,
         perio    TYPE jahrper,
         paobjnr  TYPE rkeobjnr,
         pasubnr  TYPE rkesubnr,
         belnr    TYPE rke_belnr,
         posnr    TYPE rke_posnr,
         rbeln    TYPE rkerfbelnr.
data   END   OF gt_ce18010.

DATA : BEGIN OF gt_bkpf OCCURS 0,
         bukrs    TYPE bukrs,
         belnr    TYPE belnr_d,
         gjahr    TYPE gjahr,
         budat    TYPE budat.
DATA  END   OF gt_bkpf.

DATA : BEGIN OF gt_status OCCURS 0,
         belnr    TYPE belnr_d,
         matnr    TYPE matnr,
         message  TYPE bapi_msg,
       END OF gt_status.

DATA : gt_zccopa LIKE zccopa OCCURS 0 WITH HEADER LINE.
