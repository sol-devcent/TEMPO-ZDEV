*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPTOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: reguh,regup.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*


*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF gt_out OCCURS 0,
        laufd LIKE reguh-laufd,
        laufi LIKE reguh-laufi,
        zbukr LIKE reguh-zbukr,
        lifnr LIKE reguh-lifnr,
        waers LIKE reguh-waers,
        name1 LIKE reguh-name1,
        pstlz LIKE reguh-pstlz,
        ort01 LIKE reguh-ort01,
        stras LIKE reguh-stras,
        zaldt LIKE reguh-zaldt,
        rbetr LIKE reguh-rbetr,
        rwbtr LIKE reguh-rwbtr,
        zort2 LIKE reguh-zort2,
        ztlfx LIKE reguh-ztlfx,
        ztelf LIKE reguh-ztelf,
        pyord LIKE reguh-pyord,
        vblnr LIKE regup-vblnr,
        bukrs LIKE regup-bukrs,
        belnr LIKE regup-belnr,
        gjahr LIKE regup-gjahr,
        xblnr LIKE regup-xblnr,
        blart LIKE regup-blart,
        budat LIKE regup-budat,
        bldat LIKE regup-bldat,
        dmbtr LIKE regup-dmbtr,
        wrbtr LIKE regup-wrbtr,
        zfbdt LIKE regup-zfbdt,
        zterm LIKE regup-zterm,
        vbund LIKE regup-vbund,
        zuonr LIKE regup-zuonr,
      END OF gt_out.
