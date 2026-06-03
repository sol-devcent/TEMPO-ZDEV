*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
INCLUDE <icon>.

TABLES: mara,
        marc,
        mbew,
        AFFHD,
        AFVGD,
        RESBD,
        RIPW0,
        RIPRT1,
        IHPAD,
        IHSG,
        IHGNS,
        KBEDP,
        CAUFVD,
        ILOA,
        RIWO1,
        VIAUFKS.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
Types: Begin of ta_affhd.
          Include structure AFFHD.
Types: End of ta_affhd,
       Begin of ta_AFVGD.
          Include structure AFVGD.
Types: End of ta_AFVGD,
       Begin of ta_RESBD.
          Include structure RESBD.
Types: End of ta_RESBD,
       Begin of ta_RIPW0.
          Include structure RIPW0.
Types: End of ta_RIPW0,
       Begin of ta_RIPRT1.
          Include structure RIPRT1.
Types: End of ta_RIPRT1,
       Begin of ta_IHPAD.
          Include structure IHPAD.
Types: End of ta_IHPAD,
       Begin of ta_IHSG.
          Include structure IHSG.
Types: End of ta_IHSG,
       Begin of ta_IHGNS.
          Include structure IHGNS.
Types: End of ta_IHGNS,
       Begin of ta_KBEDP.
          Include structure KBEDP.
Types: End of ta_KBEDP,
       Begin of ta_CAUFVD.
          Include structure CAUFVD.
Types: End of ta_CAUFVD,
       Begin of ta_ILOA.
          Include structure ILOA.
Types: End of ta_ILOA,
       Begin of ta_RIWO1.
          Include structure RIWO1.
Types: End of ta_RIWO1,
       Begin of ta_VIAUFKS.
          Include structure VIAUFKS.
Types: End of ta_VIAUFKS,
       Begin of ta_itab,
          werks like VIAUFKS-iwerk,
          aufnr like VIAUFKS-aufnr,
          auart like viaufks-auart,
          gstrp like viaufks-gstrp,
          tplnr like VIAUFKS-tplnr,
          pltxt like iflotx-pltxt,
          plnbez like VIAUFKS-plnbez,
          maktx like makt-maktx,
          KTEXT like VIAUFKS-KTEXT,
          matnr like resbd-matnr,
          charg like resbd-charg,
          ERFMG like resbd-erfmg,
          ERFME like resbd-erfme,
          denmng like resbd-denmng,
          GAMNG like VIAUFKS-GAMNG,
          Gmein like VIAUFKS-gmein,
          verpr like mbew-verpr,
          tot_verpr like mbew-verpr,
          waers like caufvd-waers,
       End of ta_itab,
       Begin of ta_matnr,
          Matnr like mara-matnr,
       End of ta_matnr,
       Begin of ta_material,
          werks like marc-werks,
          matnr like mara-matnr,
          mtart like mara-mtart,
          maktx like makt-maktx,
          verpr like mbew-verpr,
          peinh like mbew-peinh,  "add sap_dev02/eka - 9-Apr-2007
          bwtar like mbew-bwtar, "add sap_dev04/rizky - 30-Apr-2007
*          waers like t001-waers,
       end of ta_material.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
Data: i_VIAUFKS type ta_VIAUFKS occurs 0 with header line,
      i_itab type ta_itab occurs 0 with header line,
      i_material type ta_material occurs 0 with header line,
      i_matnr type ta_matnr occurs 0 with header line,

      i_AFFHD type ta_AFFHD occurs 0 with header line,
      i_AFVGD type ta_AFVGD occurs 0 with header line,
      i_RESBD type ta_RESBD occurs 0 with header line,
      i_RIPW0 type ta_RIPW0 occurs 0 with header line,
      i_RIPRT1 type ta_RIPRT1 occurs 0 with header line,
      i_IHPAD type ta_IHPAD occurs 0 with header line,
      i_IHSG type ta_IHSG occurs 0 with header line,
      i_IHGNS type ta_IHGNS occurs 0 with header line,
      i_KBEDP type ta_KBEDP occurs 0 with header line,

      wa_AFFHD type ta_AFFHD,
      wa_AFVGD type ta_AFVGD,
      wa_RESBD type ta_RESBD,
      wa_RIPW0 type ta_RIPW0,
      wa_RIPRT1 type ta_RIPRT1,
      wa_IHPAD type ta_IHPAD,
      wa_IHSG type ta_IHSG,
      wa_IHGNS type ta_IHGNS,
      wa_KBEDP type ta_KBEDP,

      wa_CAUFVD type ta_CAUFVD,
      wa_ILOA type ta_ILOA,
      wa_RIWO1 type ta_RIWO1,
      wa_matnr type ta_matnr,
      wa_material type ta_material,
      wa_itab type ta_itab,
      wa_VIAUFKS type ta_VIAUFKS.
