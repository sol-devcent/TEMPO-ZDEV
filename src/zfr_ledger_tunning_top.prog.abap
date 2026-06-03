*----------------------------------------------------------------------*
*   INCLUDE ZFR_LEDGER_TUNNING_TOP                                     *
*----------------------------------------------------------------------*
  TABLES: bsis, bsas, bsid, bsad, bsik, bsak, bsim, knvv, kna1, lfa1,
          skat, tgsbt, t880, bkpf, cskt, cepc, cepct, glt0, skb1, sscrfields.

  TYPES:  BEGIN OF ta_glt0,
            bukrs  LIKE glt0-bukrs,
            ryear  LIKE glt0-ryear,
            racct  LIKE glt0-racct,
            rbusa  LIKE glt0-rbusa,
            rtcur  LIKE glt0-rtcur,
            drcrk  LIKE glt0-drcrk,
* IDR
            tslvt  LIKE glt0-tslvt,
            tsl01  LIKE glt0-tsl01,
            tsl02  LIKE glt0-tsl02,
            tsl03  LIKE glt0-tsl03,
            tsl04  LIKE glt0-tsl04,
            tsl05  LIKE glt0-tsl05,
            tsl06  LIKE glt0-tsl06,
            tsl07  LIKE glt0-tsl07,
            tsl08  LIKE glt0-tsl08,
            tsl09  LIKE glt0-tsl09,
            tsl10  LIKE glt0-tsl10,
            tsl11  LIKE glt0-tsl11,
            tsl12  LIKE glt0-tsl12,
            tsl13  LIKE glt0-tsl13,
            tsl14  LIKE glt0-tsl14,
            tsl15  LIKE glt0-tsl15,
            tsl16  LIKE glt0-tsl16,
* NON 'IDR'
            hslvt  LIKE glt0-hslvt,
            hsl01  LIKE glt0-hsl01,
            hsl02  LIKE glt0-hsl02,
            hsl03  LIKE glt0-hsl03,
            hsl04  LIKE glt0-hsl04,
            hsl05  LIKE glt0-hsl05,
            hsl06  LIKE glt0-hsl06,
            hsl07  LIKE glt0-hsl07,
            hsl08  LIKE glt0-hsl08,
            hsl09  LIKE glt0-hsl09,
            hsl10  LIKE glt0-hsl10,
            hsl11  LIKE glt0-hsl11,
            hsl12  LIKE glt0-hsl12,
            hsl13  LIKE glt0-hsl13,
            hsl14  LIKE glt0-hsl14,
            hsl15  LIKE glt0-hsl15,
            hsl16  LIKE glt0-hsl16,
          END OF ta_glt0.

  TYPES:  BEGIN OF ta_bsis,
            belnr  LIKE bsis-belnr,
            bukrs  LIKE bsis-bukrs,
            hkont(10),
            werks  LIKE bsis-werks,
            gsber  LIKE bsis-gsber,
            vbund  LIKE bsis-vbund,
            kostl  LIKE bsis-kostl,
            prctr  LIKE bsis-prctr,
            fipos  LIKE skb1-fipos,
            name1  LIKE t880-name1,
            ltext  LIKE cskt-ltext,
            budat  LIKE bkpf-budat,
            gjahr  LIKE bsis-gjahr,
            monat  LIKE bsis-monat,
            blart  LIKE bsis-blart,
            zuonr  LIKE bsis-zuonr,
            sgtxt  LIKE bsis-sgtxt,
            xblnr  LIKE bsis-xblnr,
            waers  LIKE bsis-waers,
            shkzg  LIKE bsis-shkzg,
            dmbtr  LIKE bsis-dmbtr,
            wrbtr  LIKE bsis-wrbtr,
            debet  LIKE bsis-dmbtr,  " Debet
            credit LIKE bsis-dmbtr,  " Credit
            buzei  like bsis-buzei,  "SOH Adj 2-24-807
          END OF ta_bsis.

  TYPES:  BEGIN OF ta_kunnr,
            belnr  LIKE bsid-belnr,
            bukrs  LIKE bsid-bukrs,
            hkont(10),
            vwerk  LIKE knvv-vwerk,
            vbund  LIKE bsid-vbund,
            kunnr  LIKE bsid-kunnr,
            kostl  LIKE bsis-kostl,
            prctr  LIKE bsis-prctr,
            fipos  LIKE skb1-fipos,
            name1  LIKE kna1-name1,
            ltext  LIKE cskt-ltext,
            budat  LIKE bkpf-budat,
            gjahr  LIKE bsid-gjahr,
            monat  LIKE bsid-monat,
            blart  LIKE bsid-blart,
            zuonr  LIKE bsid-zuonr,
            sgtxt  LIKE bsid-sgtxt,
            xblnr  LIKE bsid-xblnr,
            waers  LIKE bsid-waers,
            shkzg  LIKE bsid-shkzg,
            dmbtr  LIKE bsid-dmbtr,
            wrbtr  LIKE bsid-wrbtr,
            debet  LIKE bsid-dmbtr,  " Debet
            credit LIKE bsid-dmbtr,  " Credit
            buzei  like bsid-buzei,  "SOH Adj 2-24-807
          END OF ta_kunnr.

  TYPES:  BEGIN OF ta_lifnr,
            belnr  LIKE bsik-belnr,
            bukrs  LIKE bsik-bukrs,
            hkont(10),
            gsber  LIKE bsik-gsber,
            vbund  LIKE bsik-vbund,
            lifnr  LIKE bsik-lifnr,
            kostl  LIKE bsis-kostl,
            prctr  LIKE bsis-prctr,
            fipos  LIKE skb1-fipos,
            name1  LIKE lfa1-name1,
            ltext  LIKE cskt-ltext,
            budat  LIKE bkpf-budat,
            gjahr  LIKE bsik-gjahr,
            monat  LIKE bsik-monat,
            blart  LIKE bsik-blart,
            zuonr  LIKE bsik-zuonr,
            sgtxt  LIKE bsik-sgtxt,
            xblnr  LIKE bsik-xblnr,
            waers  LIKE bsik-waers,
            shkzg  LIKE bsik-shkzg,
            dmbtr  LIKE bsik-dmbtr,
            wrbtr  LIKE bsik-wrbtr,
            debet  LIKE bsik-dmbtr,  " Debet
            credit LIKE bsik-dmbtr,  " Credit
            buzei  like bsik-buzei,  "SOH Adj 2-24-807
          END OF ta_lifnr.

  TYPES:  BEGIN OF ta_hkont,
            bukrs   LIKE bsid-bukrs,
            hkont(10),
            belnr   LIKE bsid-belnr,
            gsber   LIKE bsik-gsber,
            vwerk   LIKE knvv-vwerk,
            budat   LIKE bkpf-budat,
            kunnr   LIKE bsid-kunnr,
            lifnr   LIKE bsik-lifnr,
            name1   LIKE kna1-name1,
            kostl   LIKE bsid-kostl,
            gjahr   LIKE bsid-gjahr,
            monat   LIKE bsid-monat,
            blart   LIKE bsid-blart,
            zuonr   LIKE bsid-zuonr,
            sgtxt   LIKE bsid-sgtxt,
            xblnr   LIKE bsid-xblnr,
            waers   LIKE bsid-waers,
            shkzg   LIKE bsid-shkzg,
            dmbtr   LIKE bsid-dmbtr,
            wrbtr   LIKE bsid-wrbtr,
            debet   LIKE bsid-dmbtr,  " Debet
            credit  LIKE bsid-dmbtr,  " Credit
            debet1  LIKE bsid-dmbtr,  " Debet
            credit1 LIKE bsid-dmbtr,  " Credit
          END OF ta_hkont.

  TYPES:  BEGIN OF ta_hkont2,
            bukrs   LIKE bsid-bukrs,
            hkont(10),
            gsber   LIKE bsik-gsber,
            vwerk   LIKE knvv-vwerk,
            budat   LIKE bkpf-budat,
            belnr   LIKE bsid-belnr,
            kunnr   LIKE bsid-kunnr,
            lifnr   LIKE bsik-lifnr,
            name1   LIKE kna1-name1,
            kostl   LIKE bsid-kostl,
            gjahr   LIKE bsid-gjahr,
            monat   LIKE bsid-monat,
            blart   LIKE bsid-blart,
            zuonr   LIKE bsid-zuonr,
            sgtxt   LIKE bsid-sgtxt,
            xblnr   LIKE bsid-xblnr,
            waers   LIKE bsid-waers,
            shkzg   LIKE bsid-shkzg,
            dmbtr   LIKE bsid-dmbtr,
            wrbtr   LIKE bsid-wrbtr,
            debet   LIKE bsid-dmbtr,  " Debet
            credit  LIKE bsid-dmbtr,  " Credit
            debet1  LIKE bsid-dmbtr,  " Debet
            credit1 LIKE bsid-dmbtr,  " Credit
          END OF ta_hkont2.

  TYPES:  BEGIN OF ta_budat,
            bukrs   LIKE bsid-bukrs,
            hkont(10),
            budat   LIKE bkpf-budat,
            gsber   LIKE bsik-gsber,
            vwerk   LIKE knvv-vwerk,
            kunnr   LIKE bsid-kunnr,
            lifnr   LIKE bsik-lifnr,
            name1   LIKE kna1-name1,
            belnr   LIKE bsid-belnr,
            gjahr   LIKE bsid-gjahr,
            monat   LIKE bsid-monat,
            blart   LIKE bsid-blart,
            zuonr   LIKE bsid-zuonr,
            sgtxt   LIKE bsid-sgtxt,
            xblnr   LIKE bsid-xblnr,
            waers   LIKE bsid-waers,
            shkzg   LIKE bsid-shkzg,
            dmbtr   LIKE bsid-dmbtr,
            wrbtr   LIKE bsid-wrbtr,
            debet   LIKE bsid-dmbtr,  " Debet
            credit  LIKE bsid-dmbtr,  " Credit
            debet1  LIKE bsid-dmbtr,  " Debet
            credit1 LIKE bsid-dmbtr,  " Credit
          END OF ta_budat.

  TYPES:  BEGIN OF ta_vbund,
            bukrs   LIKE bsid-bukrs,
            hkont(10),
            vbund   LIKE bsid-vbund,
            name1   LIKE t880-name1,
            belnr   LIKE bsid-belnr,
            budat   LIKE bkpf-budat,
            gjahr   LIKE bsid-gjahr,
            monat   LIKE bsid-monat,
            blart   LIKE bsid-blart,
            zuonr   LIKE bsid-zuonr,
            sgtxt   LIKE bsid-sgtxt,
            xblnr   LIKE bsid-xblnr,
            waers   LIKE bsid-waers,
            shkzg   LIKE bsid-shkzg,
            dmbtr   LIKE bsid-dmbtr,
            wrbtr   LIKE bsid-wrbtr,
            debet   LIKE bsid-dmbtr,  " Debet
            credit  LIKE bsid-dmbtr,  " Credit
            debet1  LIKE bsid-dmbtr,  " Debet
            credit1 LIKE bsid-dmbtr,  " Credit
          END OF ta_vbund.

  TYPES:  BEGIN OF ta_vbund1,
            bukrs   LIKE bsid-bukrs,
            hkont(10),
            belnr   LIKE bsid-belnr,
            vbund   LIKE bsid-vbund,
            name1   LIKE t880-name1,
            budat   LIKE bkpf-budat,
            gjahr   LIKE bsid-gjahr,
            monat   LIKE bsid-monat,
            blart   LIKE bsid-blart,
            zuonr   LIKE bsid-zuonr,
            sgtxt   LIKE bsid-sgtxt,
            xblnr   LIKE bsid-xblnr,
            waers   LIKE bsid-waers,
            shkzg   LIKE bsid-shkzg,
            dmbtr   LIKE bsid-dmbtr,
            wrbtr   LIKE bsid-wrbtr,
            debet   LIKE bsid-dmbtr,  " Debet
            credit  LIKE bsid-dmbtr,  " Credit
            debet1  LIKE bsid-dmbtr,  " Debet
            credit1 LIKE bsid-dmbtr,  " Credit
          END OF ta_vbund1.

  TYPES:  BEGIN OF ta_kostl,
            bukrs   LIKE bsid-bukrs,
            hkont(10),
            kostl   LIKE bsid-kostl,
            ltext   LIKE cskt-ltext,
            belnr   LIKE bsid-belnr,
            budat   LIKE bkpf-budat,
            gjahr   LIKE bsid-gjahr,
            monat   LIKE bsid-monat,
            blart   LIKE bsid-blart,
            zuonr   LIKE bsid-zuonr,
            sgtxt   LIKE bsid-sgtxt,
            xblnr   LIKE bsid-xblnr,
            waers   LIKE bsid-waers,
            shkzg   LIKE bsid-shkzg,
            dmbtr   LIKE bsid-dmbtr,
            wrbtr   LIKE bsid-wrbtr,
            debet   LIKE bsid-dmbtr,  " Debet
            credit  LIKE bsid-dmbtr,  " Credit
            debet1  LIKE bsid-dmbtr,  " Debet
            credit1 LIKE bsid-dmbtr,  " Credit
          END OF ta_kostl.

  TYPES:  BEGIN OF ta_kostl1,
            bukrs   LIKE bsid-bukrs,
            hkont(10),
            belnr   LIKE bsid-belnr,
            kostl   LIKE bsid-kostl,
            ltext   LIKE cskt-ltext,
            budat   LIKE bkpf-budat,
            gjahr   LIKE bsid-gjahr,
            monat   LIKE bsid-monat,
            blart   LIKE bsid-blart,
            zuonr   LIKE bsid-zuonr,
            sgtxt   LIKE bsid-sgtxt,
            xblnr   LIKE bsid-xblnr,
            waers   LIKE bsid-waers,
            shkzg   LIKE bsid-shkzg,
            dmbtr   LIKE bsid-dmbtr,
            wrbtr   LIKE bsid-wrbtr,
            debet   LIKE bsid-dmbtr,  " Debet
            credit  LIKE bsid-dmbtr,  " Credit
            debet1  LIKE bsid-dmbtr,  " Debet
            credit1 LIKE bsid-dmbtr,  " Credit
          END OF ta_kostl1.

  TYPES:  BEGIN OF ta_prctr,
          bukrs   LIKE bsid-bukrs,
          hkont(10),
          prctr   LIKE bsid-prctr,
          ltext   LIKE cepct-ltext,
          belnr   LIKE bsid-belnr,
          budat   LIKE bkpf-budat,
          gjahr   LIKE bsid-gjahr,
          monat   LIKE bsid-monat,
          blart   LIKE bsid-blart,
          zuonr   LIKE bsid-zuonr,
          sgtxt   LIKE bsid-sgtxt,
          xblnr   LIKE bsid-xblnr,
          waers   LIKE bsid-waers,
          shkzg   LIKE bsid-shkzg,
          dmbtr   LIKE bsid-dmbtr,
          wrbtr   LIKE bsid-wrbtr,
          debet   LIKE bsid-dmbtr,  " Debet
          credit  LIKE bsid-dmbtr,  " Credit
          debet1  LIKE bsid-dmbtr,  " Debet
          credit1 LIKE bsid-dmbtr,  " Credit
        END OF ta_prctr.

  TYPES:  BEGIN OF ta_prctr1,
          bukrs   LIKE bsid-bukrs,
          hkont(10),
          belnr   LIKE bsid-belnr,
          prctr   LIKE bsid-prctr,
          ltext   LIKE cepct-ltext,
          budat   LIKE bkpf-budat,
          gjahr   LIKE bsid-gjahr,
          monat   LIKE bsid-monat,
          blart   LIKE bsid-blart,
          zuonr   LIKE bsid-zuonr,
          sgtxt   LIKE bsid-sgtxt,
          xblnr   LIKE bsid-xblnr,
          waers   LIKE bsid-waers,
          shkzg   LIKE bsid-shkzg,
          dmbtr   LIKE bsid-dmbtr,
          wrbtr   LIKE bsid-wrbtr,
          debet   LIKE bsid-dmbtr,  " Debet
          credit  LIKE bsid-dmbtr,  " Credit
          debet1  LIKE bsid-dmbtr,  " Debet
          credit1 LIKE bsid-dmbtr,  " Credit
        END OF ta_prctr1.

  TYPES:  BEGIN OF t_dwn_field,
            txt_field(20),
          END OF t_dwn_field.

  DATA:   BEGIN OF i_outpl OCCURS 0,
            bukrs   LIKE bsid-bukrs,
            blart   LIKE bsid-blart,
            belnr   LIKE bsid-belnr,
            gsber   LIKE bsik-gsber,
            budat   LIKE bkpf-budat,
            bldat   LIKE bkpf-bldat,
            hkont(10),
            waers   LIKE bsid-waers,
            debet   LIKE s603-umkzwi1,  " Debet
            credit  LIKE s603-umkzwi1,  " Credit
            zuonr   LIKE bsid-zuonr,
            sgtxt(50).
  DATA :    bktxt  TYPE bktxt,
            vbund  TYPE rassc,
            xref3  TYPE xref3,
            zeile  TYPE sgtxt,
            rstgr  TYPE rstgr,
            aufnr  TYPE aufnr,
            prctr  TYPE prctr,
            kostl  TYPE kostl,
            fipex  TYPE fipos,
            augdt  TYPE augdt,
            statu(11).
  DATA:   END OF i_outpl,
          wa_outpl LIKE i_outpl.
  DATA:   BEGIN OF i_local OCCURS 0,
            bukrs(4),
            blart(2),
            belnr(10),
            gsber(4),
            budat   LIKE bkpf-budat,
            bldat   LIKE bkpf-bldat,
            hkont(10),
            waers(5),
            debet TYPE p DECIMALS 0,
            credit TYPE p DECIMALS 0,
            zuonr(18),
            sgtxt(50).
  DATA :    bktxt  TYPE bktxt,
            vbund  TYPE rassc,
            xref3  TYPE xref3,
            longt  TYPE sgtxt,
            rstgr  TYPE rstgr,
            aufnr  TYPE aufnr,
            prctr  TYPE prctr,
            kostl  TYPE kostl,
            fipex  TYPE fipos,
            augdt  TYPE augdt,
            statu(11).
  DATA:   END OF i_local.

  DATA: BEGIN OF i_outpl_rad1 OCCURS 0,
          budat       LIKE bkpf-budat,
          belnr       LIKE bsid-belnr,
          blart       LIKE bsid-blart,
          xblnr       LIKE bsid-xblnr,
          sgtxt(50),
          lwaers      LIKE bsid-waers,
          debet       LIKE s603-umkzwi1,
          credit      LIKE s603-umkzwi1,
          waers       LIKE bsid-waers,
          debet1      LIKE s603-umkzwi1,
          credit1     LIKE s603-umkzwi1.
  DATA: END OF i_outpl_rad1,
          wa_outpl_rad1 LIKE i_outpl_rad1.
  DATA: BEGIN OF i_local_rad1 OCCURS 0,
          budat    LIKE bkpf-budat,
          belnr(10),
          blart(2),
          xblnr(16),
          sgtxt(50),
          lwaers(5),
          debet    TYPE p DECIMALS 0,
          credit   TYPE p DECIMALS 0,
          waers(5),
          debet1   TYPE p DECIMALS 0,
          credit1  TYPE p DECIMALS 0.
  DATA: END OF i_local_rad1.

  DATA: BEGIN OF i_outpl_rad2 OCCURS 0,
          budat       LIKE bkpf-budat,
          waers       LIKE bsid-waers,
          debet       LIKE s603-umkzwi1,
          credit      LIKE s603-umkzwi1.
  DATA: END OF i_outpl_rad2,
          wa_outpl_rad2 LIKE i_outpl_rad2.
  DATA: BEGIN OF i_local_rad2 OCCURS 0,
          budat    LIKE bkpf-budat,
          waers(5),
          debet    TYPE p DECIMALS 0,
          credit   TYPE p DECIMALS 0.
  DATA: END OF i_local_rad2.

  DATA: BEGIN OF i_outpl_rad3 OCCURS 0,
          gtext       LIKE tgsbt-gtext,
          waers       LIKE bsid-waers,
          begbal      LIKE rfposxext-dmshb,
          debet       LIKE s603-umkzwi1,
          credit      LIKE s603-umkzwi1,
          endbal      LIKE rfposxext-dmshb.
  DATA: END OF i_outpl_rad3,
          wa_outpl_rad3 LIKE i_outpl_rad3.
  DATA: BEGIN OF i_local_rad3 OCCURS 0,
          gtext(30),
          waers(5),
          begbal   TYPE p DECIMALS 0,
          debet    TYPE p DECIMALS 0,
          credit   TYPE p DECIMALS 0,
          endbal   TYPE p DECIMALS 0.
  DATA: END OF i_local_rad3.

  DATA: BEGIN OF i_outpl_rad4 OCCURS 0,
          name1       LIKE t880-name1,
          waers       LIKE bsid-waers,
          debet       LIKE s603-umkzwi1,
          credit      LIKE s603-umkzwi1.
  DATA: END OF i_outpl_rad4,
          wa_outpl_rad4 LIKE i_outpl_rad4.
  DATA: BEGIN OF i_local_rad4 OCCURS 0,
          name1(30),
          waers(5),
          debet    TYPE p DECIMALS 0,
          credit   TYPE p DECIMALS 0.
  DATA: END OF i_local_rad4.

  DATA: BEGIN OF i_outpl_rad5 OCCURS 0,
          ltext(30),
          waers       LIKE bsid-waers,
          debet       LIKE s603-umkzwi1,
          credit      LIKE s603-umkzwi1.
  DATA: END OF i_outpl_rad5,
          wa_outpl_rad5 LIKE i_outpl_rad5.
  DATA: BEGIN OF i_local_rad5 OCCURS 0,
          ltext(30),
          waers(5),
          debet    TYPE p DECIMALS 0,
          credit   TYPE p DECIMALS 0.
  DATA: END OF i_local_rad5.

  DATA: BEGIN OF i_outpl_rad6 OCCURS 0,
          ltext(30),
          waers       LIKE bsid-waers,
          debet       LIKE s603-umkzwi1,
          credit      LIKE s603-umkzwi1.
  DATA: END OF i_outpl_rad6,
          wa_outpl_rad6 LIKE i_outpl_rad6.
  DATA: BEGIN OF i_local_rad6 OCCURS 0,
          ltext(30),
          waers(5),
          debet    TYPE p DECIMALS 0,
          credit   TYPE p DECIMALS 0.
  DATA: END OF i_local_rad6.

  DATA:   BEGIN OF i_dataset OCCURS 0,
            bukrs(4),
            blart(2),
            belnr(10),
            gsber(4),
            budat   LIKE bkpf-budat,
            hkont(10),
            waers(5),
            debet(15),
            credit(15),
            zuonr(18),
            sgtxt(50).
  DATA :    bktxt  TYPE bktxt,
            vbund  TYPE rassc,
            xref3  TYPE xref3,
            zeile  TYPE sgtxt,
            rstgr  TYPE rstgr,
            aufnr  TYPE aufnr,
            prctr  TYPE prctr,
            kostl  TYPE kostl,
            fipex  TYPE fipos.
  DATA:   END OF i_dataset.


  DATA:   i_skat     TYPE skat OCCURS 0,
          wa_skat    TYPE skat,
          i_bsis     TYPE ta_bsis  OCCURS 0,
          wa_bsis    TYPE ta_bsis,
          i_kunnr    TYPE ta_kunnr OCCURS 0,
          wa_kunnr   TYPE ta_kunnr,
          i_lifnr    TYPE ta_lifnr OCCURS 0,
          wa_lifnr   TYPE ta_lifnr,
          wa_dwn_field TYPE t_dwn_field,
          dwn_field TYPE  t_dwn_field OCCURS 0,

          i_bsis1    TYPE ta_bsis  OCCURS 0,
          wa_bsis1   TYPE ta_bsis,
          i_kunnr1   TYPE ta_kunnr OCCURS 0,
          wa_kunnr1  TYPE ta_kunnr,
          i_lifnr1   TYPE ta_lifnr OCCURS 0,
          wa_lifnr1  TYPE ta_lifnr,

          i_hkont    TYPE ta_hkont OCCURS 0,
          wa_hkont   TYPE ta_hkont,
          i_hkont1   TYPE ta_hkont OCCURS 0,
          wa_hkont1  TYPE ta_hkont,
          i_hkont2   TYPE ta_hkont2 OCCURS 0,
          wa_hkont2  TYPE ta_hkont2,
          i_budat    TYPE ta_budat OCCURS 0,
          wa_budat   TYPE ta_budat,
          i_budat1   TYPE ta_budat OCCURS 0,
          wa_budat1  TYPE ta_budat,
          i_vbund    TYPE ta_vbund OCCURS 0,
          wa_vbund   TYPE ta_vbund,
          i_vbund1   TYPE ta_vbund1 OCCURS 0,
          wa_vbund1  TYPE ta_vbund1,
          i_kostl    TYPE ta_kostl OCCURS 0,
          wa_kostl   TYPE ta_kostl,
          i_kostl1   TYPE ta_kostl1 OCCURS 0,
          wa_kostl1  TYPE ta_kostl1,
          i_prctr    TYPE ta_prctr OCCURS 0,
          wa_prctr   TYPE ta_prctr,
          i_prctr1   TYPE ta_prctr1 OCCURS 0,
          wa_prctr1  TYPE ta_prctr1,
          i_glt0     TYPE ta_glt0 OCCURS 0,
          wa_glt0    TYPE ta_glt0.

  DATA:   va_gsber  LIKE bsid-gsber,
          va_monat  LIKE bsid-monat,
          va_budat  LIKE bsid-budat.

  DATA:   va_budat1(8),
          va_budat2(8),
          va_budat3 LIKE bsis-budat,
          va_monat1(2) TYPE n,
          va_monat2(2) TYPE n.

  DATA:   va_gtext  LIKE tgsbt-gtext,
          va_txt20  LIKE skat-txt20,
          va_txt50  LIKE skat-txt50,
          va_kunnr  LIKE bsid-kunnr,
          va_namek  LIKE kna1-name1,
          va_lifnr  LIKE bsik-lifnr,
          va_namel  LIKE lfa1-name1,
          va_name1  LIKE t880-name1,
          va_blart  LIKE bsis-blart,
          va_xblnr  LIKE bsis-xblnr,
          va_header(22),
          va_hkont(10),
          va_belnr(10),
          va_gsber1(4),
          va_vbund(6),
          va_kostl(10),
          va_prctr(10),
          va_ltext(30),
          va_sgtxt(50),
          va_fipos(14).

  DATA:   va_begbal  LIKE rfposxext-dmshb,
          va_begbal1 LIKE rfposxext-dmshb,
          va_debet   LIKE bsis-dmbtr,
          va_credit  LIKE bsis-dmbtr,
          va_debet1  LIKE bsis-dmbtr,
          va_credit1 LIKE bsis-dmbtr,
          va_endbal  LIKE rfposxext-dmshb,
          va_waers(3),
          va_gjahr   LIKE bsid-gjahr.

  DATA:   total_begbal LIKE rfposxext-dmshb,
          total_debet  LIKE rfposxext-dmshb,
          total_credit LIKE rfposxext-dmshb,
          total_endbal LIKE rfposxext-dmshb.

  DATA:   zebra1      TYPE i,
          zebra2      TYPE i.

  DATA:   sw          TYPE i,
          counter(20),
          va_line     TYPE i,
          mess(128),
          va_period(14),
          va_period1(14),
          bulan(2),
          bulan1(2),
          va_desc(50),
          l_filename(125).

  DATA:   canc(1),
          size        TYPE i.

  DATA:   c1    TYPE i,
          w0    TYPE i,
          w1    TYPE i,  w1a   TYPE i,  w1b   TYPE i,  w1c   TYPE i,
          w1d   TYPE i,  w1e   TYPE i,  w1f   TYPE i,  w1g   TYPE i,
          w1h   TYPE i,  w1i   TYPE i,  w2    TYPE i,  w3    TYPE i,
          w4    TYPE i,  w4a   TYPE i,  w5    TYPE i,  w5a   TYPE i,
          w6    TYPE i,  w7    TYPE i,  w8    TYPE i,  w9    TYPE i,
          w10   TYPE i,  w11   TYPE i,  w12   TYPE i,  w13   TYPE i,
          w1j   TYPE i,  w1k   TYPE i,  w1l   TYPE i,  w1m   TYPE i,
          w1n   TYPE i,  w1o   TYPE i,  w1p   TYPE i,  w1q   TYPE i.

  DATA: va_dmbtr LIKE bsis-dmbtr.

  RANGES: ra_budat FOR bsis-budat.

  DATA: BEGIN OF t_dmbtr OCCURS 0,
          hkont LIKE bsis-hkont,
          dmbtr LIKE bsis-dmbtr.
  DATA: END OF t_dmbtr.

  DATA : BEGIN OF gt_bkpf OCCURS 0,
           bukrs    TYPE bukrs,
           belnr    TYPE belnr_d,
           gjahr    TYPE gjahr,
           budat    TYPE budat,
           bldat    TYPE bldat,
           monat    TYPE monat,
           bktxt    TYPE bktxt,
         END OF gt_bkpf.

  DATA : BEGIN OF gt_bseg OCCURS 0,
           bukrs  TYPE bukrs,
           belnr  TYPE belnr_d,
           gjahr  TYPE gjahr,
           buzei  TYPE buzei,
           vbund  TYPE rassc,
           zuonr  TYPE dzuonr,
           xref3  TYPE xref3,
           rstgr  TYPE rstgr,
           hkont  TYPE hkont,
           sgtxt  TYPE sgtxt,
           aufnr  TYPE aufnr,
           prctr  TYPE prctr,
           kostl  TYPE kostl,
           fipos  TYPE fipos,
           xopvw  TYPE xopvw,
           augdt  TYPE augdt,
          END OF gt_bseg.
