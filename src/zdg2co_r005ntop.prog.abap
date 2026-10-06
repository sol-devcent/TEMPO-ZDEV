*----------------------------------------------------------------------*
*   INCLUDE ZDG2CO_R005TOP                                        *
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: aufk,setnode,setleaf.

TYPE-POOLS: truxs.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
CONSTANTS: c_wrttp LIKE bpja-wrttp VALUE '41',
           c_versn LIKE bpja-versn VALUE '000',
           c_setclass LIKE setnode-setclass VALUE '0103',
           c_kurst LIKE tcurr-kurst VALUE 'M',
           c_kolom TYPE int4 VALUE 1.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA  BEGIN OF t_aufk OCCURS 1.
DATA:   aufnr LIKE aufk-aufnr,
        auart LIKE aufk-auart,
        autyp LIKE aufk-autyp,
        bukrs LIKE aufk-bukrs,
        werks LIKE aufk-werks,
        gsber LIKE aufk-gsber,
        kokrs LIKE aufk-kokrs,
        ktext LIKE aufk-ktext,
        objnr LIKE aufk-objnr,
        akstl LIKE aufk-akstl,
        aufex LIKE aufk-aufex,
        kostv LIKE aufk-kostv.
DATA  END   OF t_aufk.

DATA  BEGIN OF t_bpja OCCURS 1.
DATA:   objnr LIKE bpja-objnr,
        gjahr LIKE bpja-gjahr,
        versn LIKE bpja-versn,
        wrttp LIKE bpja-wrttp,
        wtjhr LIKE bpja-wtjhr,
        wljhr LIKE bpja-wljhr,
        twaer LIKE bpja-twaer.
DATA  END   OF t_bpja.

DATA  BEGIN OF t_anla OCCURS 1.
DATA:   eaufn LIKE anla-eaufn,
        bukrs LIKE anla-bukrs,
        anln1 LIKE anla-anln1,
        anln2 LIKE anla-anln2,
        meins LIKE anla-meins,
        menge LIKE anla-menge,
        txt50 LIKE anla-txt50.
DATA  END   OF t_anla.

DATA  BEGIN OF t_ebkn OCCURS 1.
DATA:   banfn LIKE ebkn-banfn,
        bnfpo LIKE ebkn-bnfpo,
        anln1 LIKE ebkn-anln1,
        anln2 LIKE ebkn-anln2,
        gsber LIKE ebkn-gsber,
*        preis LIKE eban-preis,
        preis TYPE zxx,
        waers LIKE eban-waers,
        peinh LIKE eban-peinh,
        frgdt LIKE eban-frgdt,
        menge LIKE eban-menge,
        meins LIKE eban-meins,
        erdat LIKE eban-erdat.
DATA  END   OF t_ebkn.

DATA t_anlz TYPE TABLE OF anlz WITH HEADER LINE.

DATA  BEGIN OF t_tcurr OCCURS 1.
        INCLUDE STRUCTURE tcurr.
DATA  END   OF t_tcurr.

DATA  BEGIN OF t_t001 OCCURS 1.
        INCLUDE STRUCTURE t001.
DATA  END   OF t_t001.

DATA  BEGIN OF t_ekkn OCCURS 1.
DATA:   anln1 LIKE ekkn-anln1,
        anln2 LIKE ekkn-anln2,
        gsber LIKE ekkn-gsber,
        ebeln LIKE ekkn-ebeln,
        ebelp LIKE ekkn-ebelp,
        netpr LIKE ekpo-netpr,
        netwr LIKE ekpo-netwr,
        peinh LIKE ekpo-peinh,
        waers LIKE ekko-waers,
        aedat LIKE ekko-aedat,
        menge LIKE ekpo-menge,
        meins LIKE ekpo-meins.
DATA  END   OF t_ekkn.

DATA  BEGIN OF t_hdr OCCURS 1.
DATA:   setname LIKE setnode-setname,
        subsetname LIKE setnode-subsetname,
        descript   TYPE settext,
        expand.
DATA  END   OF t_hdr.

DATA  BEGIN OF t_out OCCURS 1.
DATA:   subsetname LIKE setleaf-setname,
        descript   TYPE settext,
        aufnr LIKE aufk-aufnr,
        ktext LIKE aufk-ktext,
        akstl LIKE aufk-akstl,
        kostv LIKE aufk-kostv,
        aufex LIKE aufk-aufex,
        proft LIKE cskt-ktext,
        kostl LIKE anlz-kostl,
        kostx LIKE cskt-ktext,
        gjahr LIKE bpja-gjahr,
        wtjhr LIKE bpja-wtjhr,
        twaer LIKE bpja-twaer,
        wljhr LIKE bpja-wljhr,
        waers LIKE t001-waers,
        menge LIKE anla-menge,
        meins LIKE anla-meins,
        preis LIKE bpja-wtjhr,
        rfatc LIKE eban-waers,
        rfalc LIKE bpja-wtjhr,
        rfaloc LIKE eban-waers,
        rfaqt LIKE eban-menge,
        rfaum LIKE eban-meins,
        netpr LIKE bpja-wtjhr,
        netwr LIKE bpja-wtjhr,
        acttc LIKE ekko-waers,
        actlc LIKE bpja-wtjhr,
        actloc LIKE eban-waers,
        actqt LIKE ekpo-menge,
        actum LIKE ekpo-meins,
        grtc  LIKE ekbe-wrbtr,
        grtcc LIKE ekbe-waers,
        grlc  LIKE ekbe-dmbtr,
        grlcc LIKE ekbe-waers,
        grqty LIKE ekbe-menge,
        gruom LIKE ekpo-meins,
        ppn   LIKE bseg-dmbtr,
        pph   LIKE bseg-dmbtr,
        dpp   LIKE bseg-dmbtr,
        budrfatc LIKE bpja-wtjhr,
        budrfalc LIKE bpja-wtjhr,
        budacttc LIKE bpja-wtjhr,
        budactlc LIKE bpja-wtjhr,
        invwaer1  TYPE waers,
        invdmbtr  TYPE wert8,
        invwaer2  TYPE waers,
        invwrbtr  TYPE wert8,
        invmenge  LIKE anla-menge,
        invmeins  LIKE anla-meins,
        paywaer1  TYPE waers,
        paydmbtr  TYPE wert8,
        paywaer2  TYPE waers,
        paywrbtr  TYPE wert8,
        bi        TYPE wert8,
        waebi     TYPE waers,
        bp        TYPE wert8,
        waebp     TYPE waers,
        ip        TYPE wert8,
        waeip     TYPE waers,
        banfn     TYPE banfn,
        erdat     TYPE aedat,
        ebeln     TYPE ebeln,
        aedat     TYPE erdat,
        budat_ekbe TYPE budat,   "EKBE
        belnr     TYPE mblnr,   "EKBE
        budat_rbkp TYPE budat,   "RBKP
        belnr_bsak TYPE belnr_d,   "BSAK
        budat_bsak TYPE budat,   "BSAK
        name1     TYPE name1_gp,
        grno      TYPE mblnr,
        grdat     TYPE budat,
        anln1     TYPE anla-anln1,
        txt50     TYPE anla-txt50,
        expand,
        line  TYPE int4.
DATA  END   OF t_out.

DATA  BEGIN OF t_subtotal OCCURS 1.
DATA:   hierlevel(2),
        subsetname LIKE setleaf-setname,
        wtjhr LIKE bpja-wtjhr,
        twaer LIKE bpja-twaer,
        wljhr LIKE bpja-wljhr,
        waers LIKE t001-waers,
        menge LIKE anla-menge,
        meins LIKE anla-meins,
        preis LIKE bpja-wtjhr,
        rfatc LIKE eban-waers,
        rfalc LIKE bpja-wtjhr,
        rfaloc LIKE eban-waers,
        rfaqt LIKE eban-menge,
        rfaum LIKE eban-meins,
        netpr LIKE bpja-wtjhr,
        netwr LIKE bpja-wtjhr,
        acttc LIKE ekko-waers,
        actlc LIKE bpja-wtjhr,
        actloc LIKE eban-waers,
        actqt LIKE ekpo-menge,
        actum LIKE ekpo-meins,
        grtc  LIKE ekbe-wrbtr,
        grtcc LIKE ekbe-waers,
        grlc  LIKE ekbe-dmbtr,
        grlcc LIKE ekbe-waers,
        grqty LIKE ekbe-menge,
        gruom LIKE ekpo-meins,
        budrfatc LIKE bpja-wtjhr,
        budrfalc LIKE bpja-wtjhr,
        budacttc LIKE bpja-wtjhr,
        budactlc LIKE bpja-wtjhr,
        invwaer1  TYPE waers,
        invdmbtr  TYPE wert8,
        invwaer2  TYPE waers,
        invwrbtr  TYPE wert8,
        invmenge  LIKE anla-menge,
        invmeins  LIKE anla-meins,
        ppn       TYPE wert8,
        pph       TYPE wert8,
        paywaer1  TYPE waers,
        paydmbtr  TYPE wert8,
        paywaer2  TYPE waers,
        paywrbtr  TYPE wert8,
        bi        TYPE wert8,
        waebi     TYPE waers,
        bp        TYPE wert8,
        waebp     TYPE waers,
        ip        TYPE wert8,
        waeip     TYPE waers,
        line  TYPE int4.
DATA  END   OF t_subtotal.

DATA  BEGIN OF t_sethier_co OCCURS 1.
        INCLUDE STRUCTURE sethier_co.
DATA:   setname LIKE setheadert-setname,
      END   OF t_sethier_co.

DATA  BEGIN OF t_cskt OCCURS 1.
DATA:   kokrs LIKE cskt-kokrs,
        kostl LIKE cskt-kostl,
        ktext LIKE cskt-ktext,
        ltext LIKE cskt-ltext,
        mctxt LIKE cskt-mctxt.
DATA  END   OF t_cskt.
DATA t_cskta LIKE t_cskt OCCURS 0 WITH HEADER LINE.

DATA: va_tabix LIKE sy-tabix,
      t_setnode LIKE setnode OCCURS 0 WITH HEADER LINE,
      t_setleaf LIKE setleaf OCCURS 0 WITH HEADER LINE,
      t_setheadert LIKE setheadert OCCURS 0 WITH HEADER LINE,
      t_setval_co LIKE setval_co OCCURS 0 WITH HEADER LINE,
      t_out1 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out2 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out3 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out4 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out5 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out6 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out7 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out8 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out9 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out10 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out11 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out12 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out13 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out14 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out15 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out16 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out17 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out18 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out19 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out20 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_out21 LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_outkey LIKE t_out OCCURS 0 WITH HEADER LINE,
      t_subtotalkey LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal1 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal2 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal3 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal4 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal5 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal6 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal7 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal8 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal9 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal10 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal11 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal12 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal13 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal14 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal15 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal16 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal17 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal18 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal19 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal20 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_subtotal21 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal1 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal2 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal3 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal4 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal5 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal6 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal7 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal8 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal9 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal10 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal11 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal12 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal13 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal14 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal15 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal16 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal17 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal18 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal19 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal20 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal21 LIKE t_subtotal OCCURS 0 WITH HEADER LINE,
      t_grandtotal LIKE t_subtotal OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF gt_ekbe OCCURS 0,
         ebeln  TYPE ebeln,
         ebelp  TYPE ebelp,
         zekkn  TYPE dzekkn,
         vgabe  TYPE vgabe,
         gjahr  TYPE mjahr,
         belnr  TYPE mblnr,
         buzei  TYPE mblpo,
         budat  TYPE budat,
         menge  TYPE menge_d,
         dmbtr  TYPE dmbtr,
         wrbtr  TYPE wrbtr,
         waers  TYPE waers,
         shkzg  TYPE shkzg,
       END OF gt_ekbe.
DATA : gt_ekbe_gr LIKE gt_ekbe OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF gt_rbkp OCCURS 0,
         belnr TYPE re_belnr,
         gjahr TYPE gjahr,
         budat TYPE budat,
         lifnr TYPE lifre,
       END OF gt_rbkp.

DATA : BEGIN OF gt_lfa1 OCCURS 0,
         lifnr TYPE lifnr,
         name1 TYPE name1_gp,
       END OF gt_lfa1.

DATA : BEGIN OF gt_bsak OCCURS 0,
         bukrs  TYPE bukrs,
         lifnr  TYPE lifnr,
         umsks  TYPE umsks,
         umskz  TYPE umskz,
         augdt  TYPE augdt,
         augbl  TYPE augbl,
         zuonr  TYPE dzuonr,
         gjahr  TYPE gjahr,
         belnr  TYPE belnr_d,
         buzei  TYPE buzei,
         budat  TYPE budat,
         bldat  TYPE bldat,
         waers  TYPE waers,
         shkzg  TYPE shkzg,
         dmbtr  TYPE dmbtr,
         wrbtr  TYPE wrbtr,
       END OF gt_bsak.

DATA: BEGIN OF gt_popup OCCURS 0.
        INCLUDE STRUCTURE zdg2cost005d.
*         aufnr(12),   " LIKE aufk-aufnr,
*         aufex(20),   " LIKE aufk-aufex,
*         prno(10),    "  LIKE eban-banfn,
*         prdat(10),   " LIKE eban-erdat,
*         prqty(10),   " LIKE eban-menge,
*         prval(15),   " LIKE eban-preis,
*         prcur(5),    " LIKE eban-waers,
*         pono(10),    "  LIKE ekpo-ebeln,
*         podat(10),   " LIKE ekpo-aedat,
*         poqty(10),   " LIKE ekpo-menge,
*         poval(15),   " LIKE ekpo-netwr,
*         pocur(5),    " LIKE eban-waers,
*         name1(35),   " LIKE lfa1-name1,
*         grno(10),    "  LIKE ekbe-belnr,
*         grdat(10),   " LIKE ekbe-budat,
*         grqty(10),   " LIKE ekbe-menge,
*         grval(15),   " LIKE ekbe-dmbtr,
*         grcur(5),    " LIKE ekbe-vgabe,
*         ivno(10),    "  LIKE ekbe-belnr,
*         ivdat(10),   " LIKE ekbe-budat,
*         ivqty(10),   " LIKE ekbe-menge,
*         ivval(15),   " LIKE ekbe-dmbtr,
*         ivcur(5),    " LIKE ekbe-waers,
DATA: END OF gt_popup.
DATA: gt_popup2 LIKE gt_popup OCCURS 0 WITH HEADER LINE.

DATA : gt_bsak_nkz  LIKE gt_bsak OCCURS 0 WITH HEADER LINE,
       gt_bsak_kz   LIKE gt_bsak OCCURS 0 WITH HEADER LINE,
       gt_bseg      TYPE TABLE OF bseg WITH HEADER LINE.

DATA : gt_zdg2cost005 TYPE TABLE OF zdg2cost005 WITH HEADER LINE,
       gv_option      TYPE sy-tabix,
       fname(20),fvalue(20).

FIELD-SYMBOLS: <fs_out> LIKE t_out,
               <fs_hdr> LIKE t_hdr,
               <fs_popup> LIKE gt_popup.
