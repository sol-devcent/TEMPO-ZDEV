*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
INCLUDE <symbol>.

TABLES: mseg.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA t_user LIKE usdef OCCURS 10000 WITH HEADER LINE.

DATA: BEGIN OF t_data OCCURS 0,
        number LIKE vbrp-posnr,
        matnr LIKE mara-matnr,
        ktext LIKE aufk-ktext,
        basme LIKE s933-basme,
        sawal LIKE s933-menge,
        smasuk LIKE s933-menge,
        sjumlah LIKE s933-menge,
        sguna LIKE s933-menge,
        sakhir LIKE s933-menge,
        sprod LIKE s933-menge,
        basme1 LIKE s933-basme,
        sprod2 LIKE s933-menge,
        basme2 LIKE s933-basme,
*        gamng LIKE caufv-gamng,
*        gmein LIKE caufv-gmein,
        ketr(50),
      END OF t_data.

DATA t_header LIKE t_data OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: va_name1  LIKE t001w-name1,
      va_name2  LIKE t001w-name2,
      va_stras  LIKE t001w-stras,
      va_ort01  LIKE t001w-ort01,
      va_adrnr  LIKE t001w-adrnr,
      va_street  LIKE adrc-street.

ranges: r_bwart for mseg-bwart,
        r_bwart_masuk for mseg-bwart,
        r_bwart_guna for mseg-bwart,
        r_lgort for mardh-lgort.
