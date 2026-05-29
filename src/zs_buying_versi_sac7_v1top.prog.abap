*----------------------------------------------------------------------*
***INCLUDE ZS_BUYING_VERSI_SAC7_TOP .
*----------------------------------------------------------------------*
DATA : BEGIN OF ta_detailrch OCCURS 0,
         vbeln(10),
         material_code(18),
         mat_descrp(40),
         qty(20),
         charg(10),
         expdt(10),
         dnref(10),
         billno(10),
         fkart(4),
         augru_auft(3),
       END OF ta_detailrch.

DATA : BEGIN OF ta_detailbnb OCCURS 0,
         vbeln(10),
         fkart(4),
         vbtyp(1),
         vkorg(4),
         fkdat             LIKE sy-datum,
         program(2),
         extwg(18),
         prdha(18),
         sal_off(4),
         industri(4),
         search(10),
         customer(10),
         cust_name(40),
         address(120),
         material_code(18),
         mat_descrp(40),
         do_date           LIKE sy-datum,
         do_number(10),
         gross(25),
         qty(20),
         dis_a(25),
         dis_b(25),
         dis_c(25),
         dis_d(25),
         dis_e(25),
         dis_f(25),
         final(1),
         lifnr(10),
         cgrp(2),
         dis_f3(25),
         dis_vol(25),
         dnqty(20),
         dnval(25),
         city1(40),
         grprinc(10),
         post_code1(10),
         augru_auft(3),
       END OF ta_detailbnb.

DATA  BEGIN OF t_s619 OCCURS 1.
INCLUDE STRUCTURE s619.
DATA: extwg      LIKE mara-extwg,
      prdha      LIKE mara-prdha,
      maktx      LIKE makt-maktx,
      kdgrp      TYPE kna1vv-kdgrp,
      brsch      LIKE kna1vv-brsch,
      sortl      LIKE kna1vv-sortl,
      name1      LIKE adrc-name1,
      name2      LIKE adrc-name2,
      name3      LIKE adrc-name3,
      name4      LIKE adrc-name4,
      city1      LIKE adrc-city1,
      post_code1 LIKE adrc-post_code1.

DATA  END   OF t_s619.

***DATA  BEGIN OF t_mara OCCURS 1.
***DATA: matnr LIKE mara-matnr,
***      prdha LIKE mara-prdha,
***      maktx LIKE makt-maktx.
***DATA  END   OF t_mara.

**DATA : t_kna1  LIKE zkna1 OCCURS 0.
**DATA : gt_kna1 LIKE zkna1 OCCURS 0.
**DATA : wa_kna1  LIKE zkna1.

DATA  BEGIN OF t_likp OCCURS 1.
DATA: vbeln     LIKE likp-vbeln,
      vbtyp     LIKE likp-vbtyp,
      wadat_ist LIKE likp-wadat_ist.
DATA  END   OF t_likp.

DATA: t_lips TYPE TABLE OF lips WITH HEADER LINE,
      t_vbak TYPE TABLE OF vbak WITH HEADER LINE.

DATA : gt_mvke LIKE zmvke1 OCCURS 0.

DATA : gv_sent   TYPE i,
       gv_comp   TYPE i,
       gv_result TYPE flag.

DATA : BEGIN OF gt_vbrprch OCCURS 0,
         vbeln         LIKE vbrp-vbeln,
         posnr         LIKE vbrp-posnr,
         vgbel         LIKE vbrp-vgbel,
         vgpos         LIKE vbrp-vgpos,
         matnr         LIKE vbrp-matnr,
         dnref(10),
         program(2),
         fkart(4),
         augru_auft(3),
       END OF gt_vbrprch.

DATA : BEGIN OF gt_lipsrch OCCURS 0,
         vbeln LIKE lips-vbeln,
         posnr LIKE lips-posnr,
         uecha LIKE lips-uecha,
         matnr LIKE lips-matnr,
         charg LIKE lips-charg,
         vfdat LIKE lips-vfdat,
         lfimg LIKE lips-lfimg,
         lgmng LIKE lips-lgmng,
         maktx LIKE makt-maktx,
       END OF gt_lipsrch,
       gt_lipsrch2 LIKE gt_lipsrch OCCURS 0 WITH HEADER LINE.

DATA: gt_kna1a TYPE TABLE OF zkna1 WITH HEADER LINE.
