*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE0009TOP                                           *
*----------------------------------------------------------------------*
**For ALV
TYPE-POOLS: slis.

CONSTANTS:
 c_formname_top_of_page TYPE slis_formname VALUE 'F_TOP_OF_PAGE'.

*--Table
TABLES : zgdtxdt0012.
*** Add by sukardi untuk form yg menggunakan smart form
TABLES nast.
data: d_ctrl_param     like    ssfctrlop,
*{   REPLACE        P01K900160                                        1
*\      d_output_opt     like    ssfcompop,
      d_output_opt    type    ssfcompop,  "By SAP_DEV06 26-03-2007.
*}   REPLACE
      d_smrt_funcmod   type    rs38l_fnam,
      d_ssfscreen      like    ssfscreen.

data: t_lines    like tline occurs  0 with header line,
      d_tdnam    like rssce-tdname,
      p_smartform    LIKE ssfscreen-fname. " DEFAULT 'ZDG2SDF001'.
  DATA gt_detail  TYPE TABLE OF ZDG2FISTF002D WITH HEADER LINE.
  DATA: gv_header TYPE ZDG2FISTF002h.
**** End Add by sukardi
*--Global Data
DATA : xscreen,
       p_tdform           LIKE stxh-tdform,
*       p_dest             LIKE nast-ldest,
       p_disp(1)          TYPE c,
       d_suffix(1)        TYPE c,
       d_tanggal(20)      TYPE c,
       d_fakdat(20)       TYPE c,
       d_hal              TYPE i,
       d_pages            TYPE i,
       d_atab             TYPE i,
       d_firstone_main    TYPE i,
       d_firsttwo_main    TYPE i,
       d_no               TYPE i,
       d_itqtyc(7)        TYPE c,
       d_meins            TYPE mara-meins,
       d_satuanc(13)      TYPE c,
       d_itamtc(17)       TYPE c,
       d_totline          TYPE i,
       d_dppc(17)         TYPE c,
       d_ppnc(17)         TYPE c,
       d_ppnbmc(17)       TYPE c,
       d_discc(17)        TYPE c,
       t_fieldcat         TYPE slis_t_fieldcat_alv,
       t_sort             TYPE slis_t_sortinfo_alv,
       t_events           TYPE slis_t_event,
       t_list_top_of_page TYPE slis_t_listheader,
       tab_events         TYPE slis_t_event,
       comm_event         TYPE slis_alv_event,
       d_layout           TYPE slis_layout_alv,
       d_f2code           LIKE sy-ucomm VALUE  '&ETA',
       d_repid            LIKE sy-repid,
       d_variant          LIKE disvariant,
       d_print            TYPE slis_print_alv.

*--Internal Table
DATA BEGIN OF t_itab OCCURS 0.
        INCLUDE STRUCTURE zgdtxdt0012.
DATA    cek   TYPE c.
DATA    harga LIKE zgdtxdt0012-itamt.
DATA    stenr LIKE lfa1-stenr.   "tgl pengukuhan
DATA    adrnr1 LIKE lfa1-adrnr.
DATA    street LIKE adrc-street.
DATA    str_suppl3 LIKE adrc-str_suppl3.
DATA    location LIKE adrc-location.
DATA    city1 LIKE adrc-city1.
DATA    fakturnot(20).
DATA END OF t_itab.

DATA : t_display LIKE t_itab OCCURS 0 WITH HEADER LINE,
       t_alv     LIKE t_itab OCCURS 0 WITH HEADER LINE.

DATA:   d_npwp        LIKE kna1-stceg,
        d_alamat LIKE tline-tdline,
        d_alamat2 LIKE tline-tdline.


****added by Rahmadi
DATA  BEGIN OF t_pkp OCCURS 1.
DATA: masafrom LIKE zgdtxdt0005-masafrom,
      pkpnpwp LIKE zgdtxdt0005-pkpnpwp,
      pkpkuh LIKE zgdtxdt0005-pkpkuh,
      pkpname LIKE zgdtxdt0005-pkpname,
      pkpaddrs1 LIKE zgdtxdt0005-pkpaddrs1,
      pkpaddrs2 LIKE zgdtxdt0005-pkpaddrs2,
      pkpcity LIKE zgdtxdt0005-pkpcity.
DATA  END   OF t_pkp.

**Tax related config tables Billing type, branch, bus line etc
DATA t_tx00101 LIKE zgdtxdt0101 OCCURS 1 WITH HEADER LINE.
DATA t_tx00102 LIKE zgdtxdt0102 OCCURS 1 WITH HEADER LINE.
DATA t_tx00103 LIKE zgdtxdt0103 OCCURS 1 WITH HEADER LINE.

DATA d_ho_brnch LIKE zgdtxdt0101-brnch.
DATA d_kuh LIKE zgdtxdt0005-pkpkuh.
DATA d_name LIKE zgdtxdt0005-pkpname.
DATA d_city LIKE zgdtxdt0005-pkpcity.
****end of addition

RANGES: ra_bkp  FOR bseg-hkont,
        ra_jkp  FOR bseg-hkont.

DATA: BEGIN OF t_bseg OCCURS 0,
        bukrs   TYPE bseg-bukrs,
        belnr   TYPE bseg-belnr,
        gjahr   TYPE bseg-gjahr,
        matnr   type bseg-matnr,
        buzei   TYPE bseg-buzei,
        BUZID   type bseg-BUZID,
        shkzg   TYPE bseg-shkzg,
        mwskz   TYPE bseg-mwskz,
        wrbtr   TYPE bseg-wrbtr,
        hkont   TYPE bseg-hkont,
        sgtxt   TYPE bseg-sgtxt,
        MENGE   type bseg-menge,
        MEINS   type bseg-meins,
        dmbtr   type bseg-dmbtr,
        maktx   type makt-maktx,
      END OF t_bseg.
data: begin of t_makt occurs 0,
        matnr   type makt-matnr,
        maktx   type makt-maktx,
      END OF t_makt.
