*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE0014TOP                                           *
*----------------------------------------------------------------------*
TABLES zgdtx_0014.
*----------------------------------------------------------*
* Types
*----------------------------------------------------------*
TYPES: typep15(15) TYPE p.

TYPES:  BEGIN OF type_data_screen.
        INCLUDE STRUCTURE t_vbrk.
TYPES:   item       LIKE zgdtxst0003-item,

         fak1        LIKE zgdtxst0003-fakturno,
         fak2        LIKE zgdtxst0003-fakturno,
         fak3        LIKE zgdtxst0003-fakturno,

         examtlast_c(20),     "Display Amount   Exclude PPN on Screen
         itdiscex_c(20),      "Display Discount Exclude PPN on Screen

         qty1       LIKE t_vbrk-itqtylast, "for Split by Qty
         qty2       LIKE t_vbrk-itqtylast,
         qty3       LIKE t_vbrk-itqtylast,

         nqty1       LIKE t_vbrk-itqtylast, "for New Split by Qty
         nqty2       LIKE t_vbrk-itqtylast,
         nqty3       LIKE t_vbrk-itqtylast,

         s_9100_io_amtlast1 LIKE zgdtxdt0002-itamtlast, "By Amount
         s_9100_io_amtlast2 LIKE zgdtxdt0002-itamtlast,
         s_9100_io_amtlast3 LIKE zgdtxdt0002-itamtlast,

         s_9100_io_disc1 LIKE zgdtxdt0002-itdisclast,
         s_9100_io_disc2 LIKE zgdtxdt0002-itdisclast,
         s_9100_io_disc3 LIKE zgdtxdt0002-itdisclast,

         kode(1),      "for Split by item
        END OF type_data_screen.

TYPES: BEGIN OF type_data_screen_header,
        billing(10),
        customer LIKE kna1-name1,
        npwp(20),
        addr1    LIKE kna1-stras,
        addr2    LIKE kna1-stras,
       END OF type_data_screen_header.

TYPES: type_packed(16) TYPE p DECIMALS 14.


*----------------------------------------------------------*
* Control tables
*----------------------------------------------------------*
CONTROLS: s_9000_tc TYPE TABLEVIEW USING SCREEN 9000,
          s_9100_tc TYPE TABLEVIEW USING SCREEN 9100,
          s_9200_tc TYPE TABLEVIEW USING SCREEN 9200.

CONTROLS: ctrl_2200 TYPE TABLEVIEW USING SCREEN 2200.
CONTROLS: ctrl_1300 TYPE TABLEVIEW USING SCREEN 1300.
CONTROLS: ctrl_1500 TYPE TABLEVIEW USING SCREEN 1500.
CONTROLS tabstrip TYPE TABSTRIP.

*----------------------------------------------------------*
* Internal Tables
*----------------------------------------------------------*
DATA: s_9000_table       TYPE STANDARD TABLE OF type_data_screen
                         WITH HEADER LINE.

DATA: s_9100_table           TYPE STANDARD TABLE OF type_data_screen
                             WITH HEADER LINE,
      s_9100_io_amtlasttotal LIKE vbrk-netwr,
      s_9100_io_amtlast1     TYPE typep15,
      s_9100_io_amtlast2     TYPE typep15,
      s_9100_io_amtlast3     TYPE typep15,
      s_9100_io_totaldisc    LIKE vbrk-netwr,
      s_9100_io_disc1        TYPE typep15,
      s_9100_io_disc2        TYPE typep15,
      s_9100_io_disc3        TYPE typep15,

      s_9100_io_namtlasttotal LIKE vbrk-netwr,
      s_9100_io_namtlast1     TYPE typep15,
      s_9100_io_namtlast2     TYPE typep15,
      s_9100_io_namtlast3     TYPE typep15,
      s_9100_io_ntotaldisc    LIKE vbrk-netwr,
      s_9100_io_ndisc1        TYPE typep15,
      s_9100_io_ndisc2        TYPE typep15,
      s_9100_io_ndisc3        TYPE typep15.

DATA: s_9200_table       TYPE STANDARD TABLE OF type_data_screen
                         WITH HEADER LINE.

DATA: s_9300_header TYPE type_data_screen_header,
      s_9300_cb_incl_tax(1).

DATA: s_9400_io_petugas1 LIKE d_petugas,
      s_9400_io_petugas2 LIKE d_petugas,
      s_9400_rb_petugas1(1),
      s_9400_rb_petugas2(1).

DATA: d_9100_amtlasttotal TYPE typep15,
      d_9100_totaldisc    TYPE typep15,
      d_9100_disclast1 TYPE typep15,
      d_9100_disclast2 TYPE typep15,
      d_9100_disclast3 TYPE typep15,
      d_9100_amtlast1 TYPE typep15,
      d_9100_amtlast2 TYPE typep15,
      d_9100_amtlast3 TYPE typep15,
      d_9100_waerk        LIKE vbrk-waerk,
      d_leave_to_screen_0,
      d_flag_canc_fullyreturn.  "Flag : is this billing fully return

DATA: t_vbrk_scr    LIKE t_vbrk OCCURS 0 WITH HEADER LINE.

DATA: p_sp_qty(1) TYPE c,
      p_sp_amo(1) TYPE c,
      p_sp_ite(1) TYPE c.

DATA: BEGIN OF t_vbelns OCCURS 1.
DATA: vbeln LIKE zgdtxdt0002-vbeln,
      fakturno LIKE zgdtxdt0002-fakturno.
DATA END OF t_vbelns.

DATA: BEGIN OF d_kna1,
        kunnr LIKE kna1-kunnr,
        name1 LIKE kna1-name1,
        ort01 LIKE kna1-ort01,  "city
        pstlz LIKE kna1-pstlz,  "postal code
        stras LIKE kna1-stras,  "addr
        stceg LIKE kna1-stceg,  "VAT no
      END OF d_kna1.

DATA  BEGIN OF t_vbfa OCCURS 1.
DATA: vbeln LIKE vbfa-vbeln,
      vbelv LIKE vbfa-vbelv,
      posnv LIKE vbfa-posnv,
      vbtyp_n LIKE vbfa-vbtyp_n,
      vbtyp_v LIKE vbfa-vbtyp_v,
      flag(1) TYPE c.
DATA  END   OF t_vbfa.

DATA t_vbrkn LIKE t_vbrk OCCURS 1 WITH HEADER LINE.
DATA t_vbfacr LIKE vbfa OCCURS 1 WITH HEADER LINE.
DATA t_vbfacc LIKE vbfa OCCURS 1 WITH HEADER LINE.
DATA t_vbfaca LIKE vbfa OCCURS 1 WITH HEADER LINE.
DATA t_vbrk2 LIKE t_vbrk OCCURS 1 WITH HEADER LINE.
DATA t_memory LIKE t_vbrk OCCURS 1 WITH HEADER LINE.
DATA: t_notaretur       LIKE t_vbrk OCCURS 1 WITH HEADER LINE,
      t_notaretur_sat   LIKE t_notaretur OCCURS 1 WITH HEADER LINE,
      t_notaretur_gab   LIKE t_notaretur OCCURS 1 WITH HEADER LINE,
      t_notaretur_split LIKE t_notaretur OCCURS 1 WITH HEADER LINE,
      t_notareturs      LIKE t_vbrk OCCURS 1 WITH HEADER LINE,
      t_notareturdummy  LIKE t_vbrk OCCURS 1 WITH HEADER LINE,
      t_notareturdums   LIKE t_vbrk OCCURS 1 WITH HEADER LINE.

DATA: BEGIN OF t_crtfakturpajak OCCURS 0.
        INCLUDE STRUCTURE t_vbrk.
DATA: END OF t_crtfakturpajak.

DATA:
  t_crtfakturpajak_sat   LIKE t_crtfakturpajak
                         OCCURS 0 WITH HEADER LINE,
  t_crtfakturpajak_gab   LIKE t_crtfakturpajak
                         OCCURS 0 WITH HEADER LINE,
  t_crtfakturpajak_split LIKE t_crtfakturpajak
                         OCCURS 0 WITH HEADER LINE.

DATA:
  t_vbrkscritm    LIKE t_vbrkscr OCCURS 1 WITH HEADER LINE,
  t_vbrkscr_sat   LIKE t_vbrkscr OCCURS 1 WITH HEADER LINE,
  t_vbrkscr_gab   LIKE t_vbrkscr OCCURS 1 WITH HEADER LINE,
  t_vbrkscr_split LIKE t_vbrkscr OCCURS 1 WITH HEADER LINE.

DATA:
  t_zgdtxdt0006 TYPE STANDARD TABLE OF zgdtxdt0006 WITH HEADER LINE,
  t_delete00003 TYPE STANDARD TABLE OF zgdtxdt0003 WITH HEADER LINE.


DATA  BEGIN OF t_vbrk3 OCCURS 1.
DATA:   vbeln      LIKE vbrk-vbeln,
        posnr      LIKE vbrp-posnr,
        fakturno   LIKE zgdtxdt0002-fakturno,
        itqtylast  LIKE zgdtxdt0002-itqtylast,
        itamtlast  LIKE konv-kwert,
        itdisclast LIKE konv-kwert,
        itothlast  LIKE konv-kwert,
        dpplast    LIKE konv-kwert,
        ppnlast    LIKE konv-kwert,
        ppnbmlast  LIKE konv-kwert,
        xppnbmlast LIKE konv-kwert.
DATA  END   OF t_vbrk3.

DATA: BEGIN OF t_status OCCURS 0,
        tcode(5),
      END OF t_status.

***added for Tempo -- for create without reference
DATA t_noref LIKE t_vbrk OCCURS 0 WITH HEADER LINE.
DATA d_nofp(7) TYPE c.
DATA: d_nofp1(3),
      d_nofp2(3),
      d_nofp3(2),
      d_nofp4(8).
DATA d_fakno_screen LIKE zgdtxdt0003-fakturno.
***end of Tempo addition

*----------------------------------------------------------*
* Ranges
*----------------------------------------------------------*
RANGES: r_fkart FOR vbrk-fkart,
        r_fakturno FOR zgdtxdt0003-fakturno.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: d_save_okcode      LIKE sy-ucomm,
      ok_code            LIKE sy-ucomm.

*----- Faktur Number
DATA:   d_faks1 LIKE zgdtxdt0002-fakturno,
        d_faks2 LIKE zgdtxdt0002-fakturno,
        d_faks3 LIKE zgdtxdt0002-fakturno.

DATA  d_split(1) TYPE c.
DATA: ok-code(8)     TYPE c.
DATA  d_pstyvs LIKE t_vbrk-pstyv.
DATA  p_group(1) TYPE c.

*----------------------------------------------------------*
* SCREEN DATA
*----------------------------------------------------------*
DATA: s_9600_io_petugas1 LIKE d_petugas,
      s_9600_io_petugas2 LIKE d_petugas,
      s_9600_io_petugas3 LIKE d_petugas,
      s_9600_io_petugas4 LIKE d_petugas,
      s_9600_rb_petugas1(1),
      s_9600_rb_petugas2(1),
      s_9600_rb_petugas3(1),
      s_9600_rb_petugas4(1).
DATA  d_display.
DATA  d_save.
DATA  d_cancel.

*----------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------*
CONSTANTS: c_satuan    LIKE sy-ucomm VALUE 'SATUAN',
           c_gabungan  LIKE sy-ucomm VALUE 'GABUNGAN',
           c_split     LIKE sy-ucomm VALUE 'SPLIT',
           c_sat(1)    VALUE 'S',
           c_gab(1)    VALUE 'G',
           c_sp1(1)    VALUE 'A',
           c_sp2(1)    VALUE 'I',
           c_sp3(1)    VALUE 'Q'.

*----------------------------------------------------------*
* Selection screens
*----------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS:    p_vkorg LIKE vbrk-vkorg NO-DISPLAY,
                                " OBLIGATORY MEMORY ID vko,
               p_gsber LIKE vbrp-gsber NO-DISPLAY,
                                " OBLIGATORY MEMORY ID gsb,
               p_spart LIKE vbrk-spart NO-DISPLAY.
*                       OBLIGATORY
*                       MEMORY ID spa.
* Added by rama and above changed to no display
PARAMETERS:    p_bukrs LIKE vbrk-bukrs NO-DISPLAY,
*                                  OBLIGATORY MEMORY ID BUK,
               p_brnch LIKE zgdtxdt0101-brnch
                                  OBLIGATORY MEMORY ID zbr,
               p_busln LIKE zgdtxdt0102-busln DEFAULT '01'
                                  OBLIGATORY MEMORY ID zbu.

PARAMETERS:    p_flag TYPE c OBLIGATORY DEFAULT '2'.
SELECTION-SCREEN END OF BLOCK b1.
* end of addition rama

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
SELECT-OPTIONS: s_fkdat FOR zgdtxdt0002-fkdat NO-EXTENSION
                        OBLIGATORY MEMORY ID fkd,
                s_stceg FOR vbrk-stceg NO INTERVALS MEMORY ID stc,
                s_vbeln FOR vbrk-vbeln MEMORY ID vf
                        OBLIGATORY                  "added for Tempo
                        NO INTERVALS NO-EXTENSION.  "added for Tempo
PARAMETERS:     p_noret LIKE zgdtxdt0002-noretur,   "added for Tempo
                p_curr LIKE vbrk-waerk
*                       NO-DISPLAY
                       DEFAULT c_local_curr
                       OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b2.

*** Added by Rahmadi -- Multiple pages
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
PARAMETERS:
****changed for Tempo -- remove option to avoid confusion
*            p_mpage RADIOBUTTON GROUP page DEFAULT 'X',
*            p_spage RADIOBUTTON GROUP page,
            p_mpage DEFAULT 'X' NO-DISPLAY,
            p_spage NO-DISPLAY,
            p_cust RADIOBUTTON GROUP form DEFAULT 'X',
            p_stan RADIOBUTTON GROUP form,
****end of Tempo changes
            p_dest LIKE tsp03-padest OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b3.
*** End of addition

SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-not.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio1 RADIOBUTTON GROUP grp1
            USER-COMMAND rad.
SELECTION-SCREEN COMMENT 5(22) text-nt1 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio2 RADIOBUTTON GROUP grp1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(22) text-nt2 FOR FIELD radio2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b4.

SELECTION-SCREEN BEGIN OF SCREEN 2000.
PARAMETERS: p_serv    RADIOBUTTON GROUP rdiv DEFAULT 'X',
            p_sparts  RADIOBUTTON GROUP rdiv,
            p_both    RADIOBUTTON GROUP rdiv.
SELECTION-SCREEN END OF SCREEN 2000.
