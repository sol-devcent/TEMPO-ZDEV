*----------------------------------------------------------------------*
*   INCLUDE ZF_JURNAL_EXPV1TOP
*----------------------------------------------------------------------*

INCLUDE <icon>.

CONTROLS : tc_nopol        TYPE TABLEVIEW USING SCREEN 801,
           tc_shipment     TYPE TABLEVIEW USING SCREEN 803,
           tc_expense      TYPE TABLEVIEW USING SCREEN 804,
           tc_final        TYPE TABLEVIEW USING SCREEN 805,
           tc_advance      TYPE TABLEVIEW USING SCREEN 806,
           tc_transaction  TYPE TABLEVIEW USING SCREEN 811,
           tc_shipnew      TYPE TABLEVIEW USING SCREEN 812,
           tc_simtran      TYPE TABLEVIEW USING SCREEN 813,
           tc_simship      TYPE TABLEVIEW USING SCREEN 813.

FIELD-SYMBOLS <fs_tab> TYPE STANDARD TABLE.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES : sscrfields, tvbur, t093b, zf63masterkend, zfmstken,
         zf63masterperson, zfmstper, zf63trnhdr, zf63typeexp,
         zf63kmhexp, zf63master, knvv, csks, t25a7, t25a5,
         t25a8, t880, zfexpense, zf63accexp, zf63trndtl,
         zf63trnvch, ska1, t041ct, uf05a, zf63reverse, bsis,
         zf63trnshp, lfa1, zf63pddklk, zf63kostlexp, zf63plat,
         zf63nomor, zftransaction, zfshipment, zf63trnhdr2.

CLASS : lcl_application DEFINITION DEFERRED.

*----------------------------------------------------------*
* Types
*----------------------------------------------------------*

TYPES : BEGIN OF ty_mstk.
        INCLUDE STRUCTURE zfmstken.
TYPES :   butxt         TYPE t001-butxt,
          bezei         TYPE tvkbt-bezei,
          gtext         TYPE tgsbt-gtext,
          description   TYPE zf63gtype-description.
TYPES :   salesman      TYPE zf63gtype-salesman,
          vendor        TYPE zf63gtype-vendor,
          customer      TYPE zf63gtype-customer,
          shipment      TYPE zf63gtype-shipment,
          lfa1          TYPE zf63gtype-lfa1.
TYPES : END OF ty_mstk.

TYPES : BEGIN OF ty_mstp.
        INCLUDE STRUCTURE zfmstper.
TYPES :   butxt         TYPE t001-butxt,
          bezei         TYPE tvkbt-bezei,
          gtext         TYPE tgsbt-gtext,
          description   TYPE zf63gtype-description.
TYPES :   salesman      TYPE zf63gtype-salesman,
          vendor        TYPE zf63gtype-vendor,
          customer      TYPE zf63gtype-customer,
          shipment      TYPE zf63gtype-shipment,
          lfa1          TYPE zf63gtype-lfa1.
TYPES :   ktext         TYPE cskt-ktext,
          bezekpfn      TYPE t25a7-bezek,
          bezeksfr      TYPE t25a5-bezek,
          bezekpos      TYPE t25a8-bezek,
          name1tp       TYPE t880-name1.
TYPES : END OF ty_mstp.

TYPES : BEGIN OF ty_expe.
        INCLUDE STRUCTURE zfexpense.
TYPES :   butxt         TYPE t001-butxt,
          bezei         TYPE tvkbt-bezei,
          gtext         TYPE tgsbt-gtext,
          typedesc      TYPE zf63typeexp-description.
TYPES :   salesman      TYPE zf63gtype-salesman,
          vendor        TYPE zf63gtype-vendor,
          customer      TYPE zf63gtype-customer,
          shipment      TYPE zf63gtype-shipment,
          lfa1          TYPE zf63gtype-lfa1.
TYPES : END OF ty_expe.

TYPES : BEGIN OF ty_tran.
        INCLUDE STRUCTURE zf63trndtl.
TYPES : END OF ty_tran.

TYPES : BEGIN OF ty_out.
        INCLUDE STRUCTURE zf63out.
TYPES : END OF ty_out.

TYPES : BEGIN OF ty_advance.
        INCLUDE STRUCTURE zf63adv.
TYPES : END OF ty_advance.

TYPES : BEGIN OF ty_reverse.
        INCLUDE STRUCTURE zf63reverse.
TYPES : END OF ty_reverse.

TYPES : BEGIN OF ty_reprint.
        INCLUDE STRUCTURE zf63reprint.
TYPES : END OF ty_reprint.

TYPES : BEGIN OF ty_trnhdr.
        INCLUDE STRUCTURE zfstexphdr.
TYPES :  expand.
TYPES : END OF ty_trnhdr.

TYPES : BEGIN OF ty_trndtl.
        INCLUDE STRUCTURE zfstexpdtl.
TYPES : END OF ty_trndtl.

TYPES : BEGIN OF ty_headl,
          znopol        TYPE zf63trnhdr-znopol,
          jnskend       TYPE zf63masterkend-jnskend,
          description   TYPE zf63jnskendexp-description,
          postingdate(100),
          days(5),
        END OF ty_headl.

TYPES : BEGIN OF ty_dp,
          vbeln   TYPE likp-vbeln,
          kunnr   TYPE likp-kunnr.
TYPES : END OF ty_dp.

TYPES : BEGIN OF ty_biaya,
          jarak      TYPE p DECIMALS 0,
          bbm        TYPE zf63trndtl-wrbtr,
          menge      TYPE zf63trndtl-menge,
          meins      TYPE zf63trndtl-meins,
          pddk       TYPE zf63trndtl-wrbtr,
          pdlk       TYPE zf63trndtl-wrbtr,
          kuli       TYPE zf63trndtl-wrbtr,
          lodging    TYPE zf63trndtl-wrbtr,
          parkir     TYPE zf63trndtl-wrbtr,
          tol        TYPE zf63trndtl-wrbtr,
          retribusi  TYPE zf63trndtl-wrbtr,
          rm         TYPE zf63trndtl-wrbtr,
          tl         TYPE zf63trndtl-wrbtr,
          total      TYPE zf63trndtl-wrbtr,
        END OF ty_biaya.

TYPES : BEGIN OF ty_total,
          expnr      TYPE zf63trnhdr-expnr,
          netwr      TYPE vbap-netwr,
        END OF ty_total.

TYPES : BEGIN OF ty_k001,
          gtype     TYPE zf63trndtl-gtype,
          znopol    TYPE zf63trnhdr-znopol,
          name1     TYPE zf63masterperson-name1,
          jabat     TYPE zf63masterperson-jabatpd,
          kostl     TYPE zf63masterperson-kostl,
          wwsfr     TYPE zf63masterperson-wwsfr,
          wwpos     TYPE zf63masterperson-wwpos,
          jnskend   TYPE zf63masterkend-jnskend,
          zujhr     TYPE zf63masterkend-zujhr,
          jarak     TYPE p DECIMALS 0,
          meins     TYPE zf63trndtl-meins,
          liter     TYPE zf63trndtl-menge,
          ratio     TYPE p DECIMALS 2,
          waers     TYPE zf63trndtl-waers,
          bensin    TYPE zf63trndtl-wrbtr,
          solar     TYPE zf63trndtl-wrbtr,
          t0001     TYPE zf63trndtl-wrbtr,
          ogkm      TYPE zf63trndtl-kmend,
          ogrp      TYPE zf63trndtl-wrbtr,
          otkm      TYPE zf63trndtl-kmend,
          otrp      TYPE zf63trndtl-wrbtr,
          gbkm      TYPE zf63trndtl-kmend,
          gbqt      TYPE zf63trndtl-menge,
          gbrp      TYPE zf63trndtl-wrbtr,
          akikm     TYPE zf63trndtl-kmend,
          akirp     TYPE zf63trndtl-wrbtr,
          tbrp      TYPE zf63trndtl-wrbtr,
          gmrp      TYPE zf63trndtl-wrbtr,
          sprp      TYPE zf63trndtl-wrbtr,
          sbrp      TYPE zf63trndtl-wrbtr,
          skrp      TYPE zf63trndtl-wrbtr,
          t0002     TYPE zf63trndtl-wrbtr,
          rmfee     TYPE zf63trndtl-wrbtr,
          stnk      TYPE zf63trndtl-wrbtr,
          gprp      TYPE zf63trndtl-wrbtr,
          bpkb      TYPE zf63trndtl-wrbtr,
          kir       TYPE zf63trndtl-wrbtr,
          t0003     TYPE zf63trndtl-wrbtr,
          grand     TYPE zf63trndtl-wrbtr,
        END OF ty_k001.

TYPES : BEGIN OF ty_k002,
          gtype     TYPE zf63trndtl-gtype,
          name1     TYPE zf63masterperson-name1,
          znopol    TYPE zf63trnhdr-znopol,
          jabat     TYPE zf63masterperson-jabatpd,
          kostl     TYPE zf63masterperson-kostl,
          wwsfr     TYPE zf63masterperson-wwsfr,
          wwpos     TYPE zf63masterperson-wwpos,
          jnskend   TYPE zf63masterkend-jnskend,
          zujhr     TYPE zf63masterkend-zujhr,
          jarak     TYPE p DECIMALS 0,
          meins     TYPE zf63trndtl-meins,
          liter     TYPE zf63trndtl-menge,
          ratio     TYPE p DECIMALS 2,
          waers     TYPE zf63trndtl-waers,
          bensin    TYPE zf63trndtl-wrbtr,
          solar     TYPE zf63trndtl-wrbtr,
          t0001     TYPE zf63trndtl-wrbtr,
          parkir    TYPE zf63trndtl-wrbtr,
          tol       TYPE zf63trndtl-wrbtr,
          pkrp      TYPE zf63trndtl-wrbtr,
          ptrp      TYPE zf63trndtl-wrbtr,
          turp      TYPE zf63trndtl-wrbtr,
          ojek      TYPE zf63trndtl-wrbtr,
          hotel     TYPE zf63trndtl-wrbtr,
          kost      TYPE zf63trndtl-wrbtr,
          pddk      TYPE zf63trndtl-wrbtr,
          pdlk      TYPE zf63trndtl-wrbtr,
          ogrp      TYPE zf63trndtl-wrbtr,
          otrp      TYPE zf63trndtl-wrbtr,
          omrp      TYPE zf63trndtl-wrbtr,
          gbrp      TYPE zf63trndtl-wrbtr,
          akirp     TYPE zf63trndtl-wrbtr,
          tbrp      TYPE zf63trndtl-wrbtr,
          gmrp      TYPE zf63trndtl-wrbtr,
          sprp      TYPE zf63trndtl-wrbtr,
          sbrp      TYPE zf63trndtl-wrbtr,
          skrp      TYPE zf63trndtl-wrbtr,
          rmfee     TYPE zf63trndtl-wrbtr,
          stnk      TYPE zf63trndtl-wrbtr,
          gprp      TYPE zf63trndtl-wrbtr,
          bpkb      TYPE zf63trndtl-wrbtr,
          kir       TYPE zf63trndtl-wrbtr,
          izin      TYPE zf63trndtl-wrbtr,
          muat      TYPE zf63trndtl-wrbtr,
          pasar     TYPE zf63trndtl-wrbtr,
          timb      TYPE zf63trndtl-wrbtr,
          hand      TYPE zf63trndtl-wrbtr,
          materai   TYPE zf63trndtl-wrbtr,
          ongkir    TYPE zf63trndtl-wrbtr,
          pulsa     TYPE zf63trndtl-wrbtr,
          warnet    TYPE zf63trndtl-wrbtr,
          scan      TYPE zf63trndtl-wrbtr,
          buku      TYPE zf63trndtl-wrbtr,
          fotocopy  TYPE zf63trndtl-wrbtr,
          total     TYPE zf63trndtl-wrbtr,
        END OF ty_k002.

TYPES : BEGIN OF ty_trpar,
          vbund  TYPE zfgskunnr-vbund,
          name1  TYPE t880-name1,
        END OF ty_trpar.

TYPES : BEGIN OF ty_gdelv,
          value      TYPE vbap-netwr,
          carton     TYPE vbap-kwmeng,
          brgew      TYPE lips-brgew,
          volum      TYPE lips-volum,
          menge      TYPE zf63trndtl-menge,
          bbm        TYPE zf63trndtl-wrbtr,
          pddk       TYPE zf63trndtl-wrbtr,
          pdlk       TYPE zf63trndtl-wrbtr,
          kuli       TYPE zf63trndtl-wrbtr,
          lodging    TYPE zf63trndtl-wrbtr,
          parkir     TYPE zf63trndtl-wrbtr,
          tol        TYPE zf63trndtl-wrbtr,
          retribusi  TYPE zf63trndtl-wrbtr,
          rm         TYPE zf63trndtl-wrbtr,
          tl         TYPE zf63trndtl-wrbtr,
          total      TYPE zf63trndtl-wrbtr,
        END OF ty_gdelv.

TYPES : BEGIN OF ty_voucher,
          kdvch   TYPE zf63nomor-kdvch,
          nmvch   TYPE zf63nomor-nmvch,
        END OF ty_voucher.

TYPES : BEGIN OF ty_ltext,
          type    TYPE zf63tytpeexpdesc-type,
          ltext   TYPE zf63tytpeexpdesc-ltext,
        END OF ty_ltext.

TYPES : BEGIN OF ty_proseq,
          departemen   TYPE zf63proseqctrl-departemen,
        END OF ty_proseq.

TYPES : BEGIN OF ty_payment,
          ktext   TYPE zf63acckasexp-ktext,
          hkont   TYPE zf63acckasexp-hkont,
        END OF ty_payment.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA : ok_code      TYPE sy-ucomm,
       lines        TYPE i,
       fill         TYPE i.

DATA : gv_subrc     TYPE sy-subrc,
       gv_error(1),
       gv_input(1),
       gv_reverse(1),
       gv_execute(1),
       gv_znopol    TYPE zf63masterkend-znopol,
       gv_bukrs     TYPE anla-bukrs,
       gv_anln1     TYPE anla-anln1,
       gv_anln2     TYPE anla-anln2,
       gv_buzei     TYPE bseg-buzei,
       gv_azsal     TYPE zfexpense-azsal,
       gv_belnr     TYPE bseg-belnr,
       gv_gjahr     TYPE bseg-gjahr,
       gv_bktxt     TYPE bkpf-bktxt,
       gv_dmbtr     TYPE bseg-dmbtr,
       gv_hkont     TYPE bseg-hkont,
       gv_description(50),
       gv_nmvch     TYPE zf63acckasexp-nmvoucher.

DATA : gs_exclude        TYPE ui_functions,
       g_cont01          TYPE REF TO cl_gui_custom_container,
       g_splitter        TYPE REF TO cl_gui_splitter_container,
       g_container       TYPE REF TO cl_gui_container,
       g_maingrid        TYPE REF TO cl_gui_alv_grid,
       event_receiver    TYPE REF TO lcl_application,
       selected          VALUE 'X',
       gv_repid          LIKE sy-repid,
       gs_variant        LIKE disvariant,
       gs_layout_alv     TYPE lvc_s_layo,
       gt_main_sort      TYPE lvc_t_sort WITH HEADER LINE,
       gt_main_fieldcat  TYPE lvc_t_fcat,
       gs_stable         TYPE lvc_s_stbl,
       gs_toolbar        TYPE stb_button,
       gr_hierseq        TYPE REF TO cl_salv_hierseq_table,
       gr_table          TYPE REF TO cl_salv_table.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA : dynpfields     TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0.

DATA : gt_mstk      TYPE STANDARD TABLE OF ty_mstk
                    INITIAL SIZE 0,
       gt_mstp      TYPE STANDARD TABLE OF ty_mstp
                    INITIAL SIZE 0,
       gt_anla      TYPE STANDARD TABLE OF anla
                    INITIAL SIZE 0,
       gt_anlc      TYPE STANDARD TABLE OF anlc
                    INITIAL SIZE 0,
       gt_anlz      TYPE STANDARD TABLE OF anlz
                    INITIAL SIZE 0,
       gt_plat      TYPE STANDARD TABLE OF zf63plat
                    INITIAL SIZE 0,
       gt_asset     TYPE STANDARD TABLE OF zf63asset
                    INITIAL SIZE 0,
       gt_ship      TYPE STANDARD TABLE OF ty_expe
                    INITIAL SIZE 0,
       gt_expe      TYPE STANDARD TABLE OF ty_expe
                    INITIAL SIZE 0,
       gt_typeexp   TYPE STANDARD TABLE OF zf63typeexp
                    INITIAL SIZE 0,
       gt_tyexpdtl  TYPE STANDARD TABLE OF zf63tytpeexpdesc
                    INITIAL SIZE 0,
       gt_final     TYPE STANDARD TABLE OF ty_expe
                    INITIAL SIZE 0,
       gt_save      TYPE STANDARD TABLE OF ty_expe
                    INITIAL SIZE 0,
       gt_accexp    TYPE STANDARD TABLE OF zf63accexp
                    INITIAL SIZE 0,
       gt_kostlexp  TYPE STANDARD TABLE OF zf63kostlexp
                    INITIAL SIZE 0,
       gt_trndtl    TYPE STANDARD TABLE OF zf63trndtl
                    INITIAL SIZE 0,
       gt_trnhdr    TYPE STANDARD TABLE OF zf63trnhdr
                    INITIAL SIZE 0,
       gt_trndtl2   TYPE STANDARD TABLE OF zf63trndtl2
                    INITIAL SIZE 0,
       gt_trnhdr2   TYPE STANDARD TABLE OF zf63trnhdr2
                    INITIAL SIZE 0,
       gt_trnvch    TYPE STANDARD TABLE OF zf63trnvch
                    INITIAL SIZE 0,
       gt_trnvch1   TYPE STANDARD TABLE OF zf63trnvch
                    INITIAL SIZE 0,
       gt_trnshp    TYPE STANDARD TABLE OF zf63trnshp
                    INITIAL SIZE 0,
       gt_trnshp2   TYPE STANDARD TABLE OF zf63trnshp2
                    INITIAL SIZE 0,
       gt_out       TYPE STANDARD TABLE OF ty_out
                    INITIAL SIZE 0,
       gt_cancel    TYPE STANDARD TABLE OF ty_out
                    INITIAL SIZE 0,
       gt_advance   TYPE STANDARD TABLE OF ty_advance
                    INITIAL SIZE 0,
       gt_reverse   TYPE STANDARD TABLE OF ty_reverse
                    INITIAL SIZE 0,
       gt_reprint   TYPE STANDARD TABLE OF ty_reprint
                    INITIAL SIZE 0,
       gt_head      TYPE STANDARD TABLE OF ty_trnhdr
                    INITIAL SIZE 0,
       gt_detl      TYPE STANDARD TABLE OF ty_trndtl
                    INITIAL SIZE 0,
       gt_zf63acc   TYPE STANDARD TABLE OF zf63acckasexp
                    INITIAL SIZE 0,
       gt_bsik      TYPE STANDARD TABLE OF bsik
                    INITIAL SIZE 0,
       gt_pddklk    TYPE STANDARD TABLE OF zf63pddklk
                    INITIAL SIZE 0,
       gt_tbsl      TYPE STANDARD TABLE OF tbsl
                    INITIAL SIZE 0,
       gt_ska1      TYPE STANDARD TABLE OF ska1
                    INITIAL SIZE 0,
       gt_bkpf      TYPE STANDARD TABLE OF bkpf
                    INITIAL SIZE 0,
       gt_bseg      TYPE STANDARD TABLE OF bseg
                    INITIAL SIZE 0,
       gt_kmh       TYPE STANDARD TABLE OF zf63kmhexph
                    INITIAL SIZE 0,
       gt_jnskend   TYPE STANDARD TABLE OF zf63jnskendexp
                    INITIAL SIZE 0,
       gt_headl     TYPE STANDARD TABLE OF ty_headl
                    INITIAL SIZE 0,
       gt_vttp      TYPE STANDARD TABLE OF vttp
                    INITIAL SIZE 0,
       gt_vttk      TYPE STANDARD TABLE OF vttk
                    INITIAL SIZE 0,
       gt_zmshphist TYPE STANDARD TABLE OF zmshphist
                    INITIAL SIZE 0,
       gt_likp      TYPE STANDARD TABLE OF likp
                    INITIAL SIZE 0,
       gt_lips      TYPE STANDARD TABLE OF lips
                    INITIAL SIZE 0,
       gt_vbap      TYPE STANDARD TABLE OF vbap
                    INITIAL SIZE 0,
       gt_005       TYPE STANDARD TABLE OF zmsutdt005
                    INITIAL SIZE 0,
       gt_tvro      TYPE STANDARD TABLE OF tvro
                    INITIAL SIZE 0,
       gt_total     TYPE STANDARD TABLE OF ty_total
                    INITIAL SIZE 0,
       gt_gtype     TYPE STANDARD TABLE OF zf63gtype
                    INITIAL SIZE 0,
       gt_k001      TYPE STANDARD TABLE OF ty_k001
                    INITIAL SIZE 0,
       gt_k002      TYPE STANDARD TABLE OF ty_k002
                    INITIAL SIZE 0,
       gt_trpar     TYPE STANDARD TABLE OF ty_trpar
                    INITIAL SIZE 0,
       gt_voucher   TYPE STANDARD TABLE OF ty_voucher
                    INITIAL SIZE 0,
       gt_proseq    TYPE STANDARD TABLE OF zf63proseqctrl
                    INITIAL SIZE 0,
       gt_slarea    TYPE STANDARD TABLE OF zf63salesarea
                    INITIAL SIZE 0,
       gt_biaya     TYPE STANDARD TABLE OF zf63persenbiaya
                    INITIAL SIZE 0.

DATA : gt_error TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0.

DATA : gs_mstk     LIKE LINE OF gt_mstk,
       gs_mstp     LIKE LINE OF gt_mstp,
       gs_ship     LIKE LINE OF gt_ship,
       gs_expe     LIKE LINE OF gt_expe,
       gs_final    LIKE LINE OF gt_final,
       gs_trndtl   LIKE LINE OF gt_trndtl,
       gs_trndtl2  LIKE LINE OF gt_trndtl2,
       gs_gtype    TYPE zf63gtype,
       gs_gdelv    TYPE ty_gdelv,
       gv_lines    TYPE i.

DATA : obj_type            LIKE bapiache09-obj_type,
       obj_key             LIKE bapiache09-obj_key,
       return              TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0.

DATA : dh   LIKE bapiache09,
       gl   TYPE STANDARD TABLE OF bapiacgl09 INITIAL SIZE 0,
       ap   TYPE STANDARD TABLE OF bapiacap09 INITIAL SIZE 0,
       ar   TYPE STANDARD TABLE OF bapiacar09 INITIAL SIZE 0,
       ex   TYPE STANDARD TABLE OF bapiacextc INITIAL SIZE 0,
       ca   TYPE STANDARD TABLE OF bapiaccr09 INITIAL SIZE 0,
       cr   TYPE STANDARD TABLE OF bapiackec9 INITIAL SIZE 0.

DATA : advdh   LIKE bapiache09,
       advgl   TYPE STANDARD TABLE OF bapiacgl09 INITIAL SIZE 0,
       advap   TYPE STANDARD TABLE OF bapiacap09 INITIAL SIZE 0,
       advar   TYPE STANDARD TABLE OF bapiacar09 INITIAL SIZE 0,
       advex   TYPE STANDARD TABLE OF bapiacextc INITIAL SIZE 0,
       advca   TYPE STANDARD TABLE OF bapiaccr09 INITIAL SIZE 0,
       advcr   TYPE STANDARD TABLE OF bapiackec9 INITIAL SIZE 0.

DATA : gt_header  TYPE STANDARD TABLE OF zfexpstprnt INITIAL SIZE 0,
       gs_header  LIKE zfexpstprnt,
       gt_detail  TYPE STANDARD TABLE OF zfexpstprnt INITIAL SIZE 0,
       gt_window3 TYPE STANDARD TABLE OF zfexpstprnt INITIAL SIZE 0.

DATA : gr_zidno   TYPE RANGE OF zidno,
       gs_zidno   LIKE LINE OF gr_zidno,
       gv_accba(1),
       gv_expnr   TYPE zf63trndtl-expnr,
       gv_nomor   TYPE zf63nomor-nomor,
       gv_kdvch   TYPE zf63nomor-kdvch,
       gv_lock.

DATA : pa_xbln1   TYPE zfexpense-xblnr,
       pa_xbln2   TYPE zfexpense-xblnr,
       pa_budat   TYPE zfexpense-budat.

DATA : c  TYPE i.

DATA : gr_route     TYPE RANGE OF route,
       gs_route     LIKE LINE OF gr_route,
       gv_zebra,
       gv_xbkt,
       gv_spmon     TYPE spmon,
       gv_tabix     TYPE sy-tabix,
       fcode        TYPE TABLE OF sy-ucomm,
       gv_depar,
       gv_payhkont  TYPE zf63acckasexp-hkont.

DATA : gt_ctrladv    TYPE STANDARD TABLE OF zf63ctrladv INITIAL SIZE 0,
       gs_ctrladv    LIKE LINE OF gt_ctrladv.

DATA : gt_xexp   TYPE STANDARD TABLE OF zfexpense,
       gt_xtra   TYPE STANDARD TABLE OF zftransaction,
       gt_xshp   TYPE STANDARD TABLE OF zfshipment.

DATA : gt_yexp   TYPE STANDARD TABLE OF zfexpense,
       gt_ytra   TYPE STANDARD TABLE OF zftransaction,
       gt_yshp   TYPE STANDARD TABLE OF zfshipment.

DATA : gv_zidvc     TYPE zf63trnhdr2-zidvc,
       gv_zidvc2    TYPE zf63trnhdr2-zidvc.

DATA : gt_kostl     TYPE STANDARD TABLE OF zfexpstprnt.

DATA : gv_ktext     TYPE zf63acckasexp-ktext.
