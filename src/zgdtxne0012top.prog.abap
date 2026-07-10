*----------------------------------------------------------------------*
*  INCLUDE ZGDTXNE0012TOP                                           *
*----------------------------------------------------------------------*
TABLES : zgdtxdt0004, zgdtxdt0009, vbrk, zgdtxdt0106.

**Tax related config tables Billing type, branch, bus line etc
DATA t_fkart09   LIKE zgdtxdt0009 OCCURS 1 WITH HEADER LINE.
DATA t_txdt00101 LIKE zgdtxdt0101 OCCURS 1 WITH HEADER LINE.
DATA t_txdt00102 LIKE zgdtxdt0102 OCCURS 1 WITH HEADER LINE.
DATA t_txdt00103 LIKE zgdtxdt0103 OCCURS 1 WITH HEADER LINE.
DATA t_txdt00105 LIKE zgdtxdt0105 OCCURS 1 WITH HEADER LINE.

RANGES r_fkart FOR zgdtxdt0009-fkart.

DATA : BEGIN OF t_tx12 OCCURS 0,
          bukrs    LIKE zgdtxdt0012-bukrs,
          gsber    LIKE zgdtxdt0012-gsber,
          brnch    LIKE zgdtxdt0012-brnch, "added by rahmadi
          spart    LIKE zgdtxdt0012-spart,
          busln    LIKE zgdtxdt0012-busln, "added by rahmadi
          belnr    LIKE zgdtxdt0012-belnr,
          budat    LIKE zgdtxdt0012-budat,
          buzei    LIKE zgdtxdt0012-buzei,
          gjahr    LIKE zgdtxdt0012-gjahr,
          fakturno LIKE zgdtxdt0012-fakturno,
          fakdat   LIKE zgdtxdt0012-fakdat,
          masatx   LIKE zgdtxdt0012-masatx,
          credit   LIKE zgdtxdt0012-credit,
***modified by Rahmadi   05/03/2004
*          itamt    LIKE zGDTXdt0012-itamt,
          fakppn   LIKE zgdtxdt0012-fakppn,
***end of modification
          waers    LIKE zgdtxdt0012-waers,
       END OF t_tx12.

DATA : BEGIN OF t_tx03 OCCURS 0,
          vkorg      LIKE zgdtxdt0003-vkorg,
          bukrs      LIKE zgdtxdt0003-bukrs,
          gsber      LIKE zgdtxdt0003-gsber,
          brnch      LIKE zgdtxdt0003-brnch,
          spart      LIKE zgdtxdt0003-spart,
          busln      LIKE zgdtxdt0003-busln,
          fakturno   LIKE zgdtxdt0003-fakturno,
          masatx     LIKE zgdtxdt0003-masatx,
          batal      LIKE zgdtxdt0003-batal,
          returcount LIKE zgdtxdt0003-returcount,
          fakppn     LIKE zgdtxdt0003-fakppn,
          fakppnbm   LIKE zgdtxdt0003-fakppnbm,
          wapu       LIKE zgdtxdt0003-wapu,
          form       LIKE zgdtxdt0003-form,
          flaga2     LIKE zgdtxdt0003-flaga2,
          waerk      LIKE zgdtxdt0003-waerk,
       END OF t_tx03.

DATA : BEGIN OF t_tx02 OCCURS 0,
          vkorg      LIKE zgdtxdt0002-vkorg,
          bukrs      LIKE zgdtxdt0002-bukrs,
          gsber      LIKE zgdtxdt0002-gsber,
          brnch      LIKE zgdtxdt0002-brnch,
          spart      LIKE zgdtxdt0002-spart,
          busln      LIKE zgdtxdt0002-busln,
          vbeln      LIKE zgdtxdt0002-vbeln,
          posnr      LIKE zgdtxdt0002-posnr,
          gjahr      LIKE zgdtxdt0002-gjahr,
          fakturno   LIKE zgdtxdt0002-fakturno,
          fkart      LIKE zgdtxdt0002-fkart,
          masatx     LIKE zgdtxdt0002-masatx,
          ppnlast    LIKE zgdtxdt0002-ppnlast,
          ppnbmlast  LIKE zgdtxdt0002-ppnbmlast,
          pstyv      LIKE zgdtxdt0002-pstyv,
          wapu       LIKE zgdtxdt0002-wapu,
          ptype      LIKE zgdtxdt0009-ptype,
          waers      LIKE zgdtxdt0002-waers,
          noretur    LIKE zgdtxdt0002-noretur,
       END OF t_tx02.

DATA  tn_tx04       LIKE zgdtxdt0004.
DATA  t_tx04        LIKE zgdtxdt0004 OCCURS 0 WITH HEADER LINE.
DATA  t_tx04_p      LIKE zgdtxdt0004 OCCURS 0 WITH HEADER LINE.
DATA  t_tx04_br     LIKE zgdtxdt0004 OCCURS 0 WITH HEADER LINE.
DATA  t_tx04_px     LIKE zgdtxdt0004 OCCURS 0 WITH HEADER LINE.
DATA  t_tx04_upd    LIKE zgdtxdt0004 OCCURS 0 WITH HEADER LINE.
DATA  t_tx04_pst    LIKE zgdtxdt0004 OCCURS 0 WITH HEADER LINE.
DATA  t_tx04_gsbers LIKE zgdtxdt0004 OCCURS 0 WITH HEADER LINE.
DATA  t_tx04_upd_brnch LIKE t_tx04_upd OCCURS 0 WITH HEADER LINE.

DATA ts_tx04_masat(30).

DATA : BEGIN OF ts_tx04.
        INCLUDE STRUCTURE zgdtxdt0004.
DATA :    vkorgt  LIKE tvkot-vtext,
          gsbert  LIKE tgsbt-gtext,
          butxt   LIKE t001-butxt,
          bdesc   LIKE zgdtxdt0101-bdesc,
       END OF ts_tx04.

*DATA  t_tx04s LIKE ts_tx04 OCCURS 0 WITH HEADER LINE.
*DATA  t_tx04b LIKE ts_tx04 OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF t_tx04s OCCURS 0.
        INCLUDE STRUCTURE ts_tx04.
DATA : sel(1),
       END OF t_tx04s.

DATA  t_tx04b LIKE t_tx04s OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF t_gsber OCCURS 0,
        bukrs LIKE zgdtxdt0101-bukrs,
        brnch LIKE zgdtxdt0101-brnch,
        bdesc LIKE zgdtxdt0101-bdesc,
        hcompany LIKE zgdtxdt0101-hcompany,
        ho_ind LIKE zgdtxdt0101-ho_ind,
        gsber LIKE vbrp-gsber,
      END OF t_gsber.

CONTROLS : sp_dt7022s  TYPE TABLEVIEW USING SCREEN 7022,
           sp_dt7022b  TYPE TABLEVIEW USING SCREEN 7022.

DATA: okcode(4),
      save_ok_code(4),
      current_line                 LIKE sy-stepl,  " being processed,
      maximum_line                 LIKE sy-loopc,  " per screen,
      minimum_line                 LIKE sy-linct.  " on current screen.
DATA  t_vkorgt LIKE tvkot OCCURS 0 WITH HEADER LINE.
DATA  t_gsbert LIKE tgsbt OCCURS 0 WITH HEADER LINE.
DATA  d_7022_answer.
DATA  d_subrc.
DATA  d_simu.
DATA : BEGIN OF t_tgsbt OCCURS 0,
***modified by Rahmadi
*          gsber LIKE tgsbt-gsber,
*          gtext LIKE tgsbt-gtext,
          brnch LIKE zgdtxdt0101-brnch,
          bdesc LIKE zgdtxdt0101-bdesc,
***end of modification
       END OF t_tgsbt.

DATA : BEGIN OF t_cab_tx05 OCCURS 0,
            vkorg    LIKE zgdtxdt0005-vkorg,
            bukrs    LIKE zgdtxdt0005-bukrs,
            gsber    LIKE zgdtxdt0005-gsber,
            brnch    LIKE zgdtxdt0005-brnch,
            masafrom LIKE zgdtxdt0005-masafrom,
            fptwo    LIKE zgdtxdt0005-fptwo,
       END OF t_cab_tx05.
DATA  d_clocing_succeeded.

DATA t_pusat_tx05  LIKE t_cab_tx05 OCCURS 0 WITH HEADER LINE.
DATA t_nasio_tx05  LIKE t_cab_tx05 OCCURS 0 WITH HEADER LINE.
DATA d_masatx LIKE t_tx04-masatx.
DATA d_ho.
DATA d_hold LIKE zgdtxdt0105-hcompany.

CONSTANTS :
             c_waerk_idr   LIKE vbap-waerk VALUE 'IDR',
             c_credit_c    LIKE zgdtxdt0012-credit VALUE 'C',
             c_credit_i    LIKE zgdtxdt0012-credit VALUE 'I',
             c_credit_r    LIKE zgdtxdt0012-credit VALUE 'R',
             c_type_n      LIKE zgdtxdt0009-ptype  VALUE 'N',
             c_type_r      LIKE zgdtxdt0009-ptype  VALUE 'R',
             c_type_p      LIKE zgdtxdt0009-ptype  VALUE 'P',
*             c_pstyv_zrin  LIKE zGDTXdt0002-pstyv  VALUE 'ZRIN',
*             c_pstyv_zrra  LIKE zGDTXdt0002-pstyv  VALUE 'ZRRA',
             c_gsber_pusat LIKE tgsbt-gsber          VALUE '%000',
*             c_gsber_pusatl LIKE tgsbt-gsber          VALUE '%000',
             c_vkorg_nasio LIKE tvko-vkorg           VALUE '0001',
             c_gsber_nasio LIKE tvko-vkorg           VALUE 'A000',

             c_pusat_xxx LIKE tgsbt-gsber          VALUE '%XXX',
             c_nasio_xxx LIKE tgsbt-gsber          VALUE 'AXXX',

             c_status_close(15) VALUE 'has been closed',
             c_status_open(15) VALUE 'is still open',
             c_spart_03 LIKE vbrp-spart VALUE '03',

             c_tcode_n(15) VALUE 'ZGDTXE0012_01',
             c_tcode_p(15) VALUE 'ZGDTXE0012_02',
             c_tcode_c(15) VALUE 'ZGDTXE0012_03',
             c_tcode_se38(4) VALUE 'SE38',
             c_tcode_se80(7) VALUE 'SEU_INT',

             c_form_a2  LIKE zgdtxdt0003-form VALUE 'A2',
             c_flaga2_a LIKE zgdtxdt0003-flaga2 VALUE 'A',
             c_flaga2_d LIKE zgdtxdt0003-flaga2 VALUE 'D',
             c_wapu_w   LIKE zgdtxdt0003-wapu VALUE 'W',

             c_batal_x(1) VALUE 'X',

             c_live_date99 LIKE vbrk-fkdat VALUE '99991231'.

DATA  d_ho_brnch LIKE zgdtxdt0101-brnch.
DATA  d_hold_brnch LIKE zgdtxdt0101-brnch.
DATA  d_butxt LIKE t001-butxt.
DATA  d_bdesc LIKE zgdtxdt0101-bdesc.
DATA  d_busds LIKE zgdtxdt0102-busds.

DATA t_national LIKE t_gsber OCCURS 1 WITH HEADER LINE.
DATA t_ho LIKE t_national OCCURS 1 WITH HEADER LINE.
DATA t_branch LIKE t_national OCCURS 1 WITH HEADER LINE.
DATA  d_branch_num TYPE i.
DATA  d_vari LIKE disvariant-variant.
