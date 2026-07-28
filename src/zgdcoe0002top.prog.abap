*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
INCLUDE <icon>.

TABLES: mara,
        mseg,
        mkpf,
        makt,
        ckmlcr,
        zgdcodt0003,
        zgdcodt0002,
        t001w.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*


*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA t_user LIKE usdef OCCURS 10000 WITH HEADER LINE.

DATA: BEGIN OF t_main OCCURS 0.
        INCLUDE STRUCTURE zgdcodt0003.
DATA: END OF t_main.

DATA: t_main_tmp LIKE t_main OCCURS 0.
