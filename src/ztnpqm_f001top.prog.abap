*----------------------------------------------------------------------*
*   INCLUDE ZTNPQM_F001TOP
*----------------------------------------------------------------------*
  TABLES: nast,tnapr,qals.

  DATA: BEGIN OF t_nast_key,
          matnr LIKE mara-matnr,
          mjahr LIKE mseg-mjahr,
        END OF t_nast_key.

  DATA: xscreen(1) TYPE c.

  DATA:  BEGIN OF t_qals OCCURS 0,
           prueflos    TYPE qals-prueflos,
           werk        TYPE qals-werk,
           art         TYPE qals-art,
           matnr       TYPE qals-matnr,
           mblnr       TYPE qals-mblnr,
           mjahr       TYPE qals-mjahr,
           zeile       TYPE qals-zeile,
           ebeln       TYPE qals-ebeln,
           aufnr       TYPE qals-aufnr,
           charg       TYPE qals-charg,
           lmenge01    TYPE qals-lmenge01,
           lmenge04    TYPE qals-lmenge04,
           offen_lzmk  TYPE qals-offen_lzmk,
           einhprobe   TYPE qals-einhprobe,
           sellifnr    TYPE qals-sellifnr,
           budat       TYPE qals-budat,
           losmenge    TYPE qals-losmenge,
           mengeneinh  TYPE qals-mengeneinh,
           anzgeb	     TYPE qanzgeb,
           gebeh       TYPE qgebeh,
           lifnr       TYPE lifnr,
         END OF t_qals,
         BEGIN OF t_t001w OCCURS 0,
           werks       TYPE t001w-werks,
           name1       TYPE t001w-name1,
         END OF t_t001w,
         BEGIN OF t_mara OCCURS 0,
           matnr       TYPE mara-matnr,
           mtart       TYPE mara-mtart,
           maktx       TYPE makt-maktx,
           tempb       TYPE mara-tempb,
         END OF t_mara,
         BEGIN OF t_qave OCCURS 0,
           prueflos    TYPE qave-prueflos,
           kzart       TYPE qave-kzart,
           zaehler     TYPE qave-zaehler,
           vcode       TYPE qave-vcode,
           vdatum      TYPE qave-vdatum,
           vaedatum    TYPE qave-vaedatum,
         END OF t_qave.

  DATA : t_mkpf TYPE TABLE OF mkpf, wa_mkpf TYPE mkpf.

  DATA: BEGIN OF t_qclabel OCCURS 0.
          INCLUDE STRUCTURE ztnpqmst001.
  DATA: END OF t_qclabel.

  DATA : gt_qals  TYPE STANDARD TABLE OF qals INITIAL SIZE 0,
         gt_ekko  TYPE STANDARD TABLE OF ekko.

  DATA: BEGIN OF t_out OCCURS 0.
          INCLUDE STRUCTURE ztnpqmst001.
  DATA: END OF t_out.

  DATA: t_lfa1 TYPE TABLE OF lfa1 WITH HEADER LINE.
  DATA: t_qals2 LIKE TABLE OF t_qals WITH HEADER LINE.
  DATA: t_aufm TYPE TABLE OF aufm WITH HEADER LINE.
  DATA: t_mseg TYPE TABLE OF mseg WITH HEADER LINE.

  DATA: wa_qclabel  LIKE LINE OF t_qclabel.
  DATA: gv_pallet   TYPE int4.
  DATA: gv_weanz    TYPE weanz.

  CONSTANTS : c_smartform_name1  TYPE tdsfname VALUE 'ZTNPQM_SF001',
              c_smartform_name2  TYPE tdsfname VALUE 'ZTNPQM_SF002'.

  DATA : gv_lblno TYPE numc10.

  DATA : t_marm         TYPE STANDARD TABLE OF marm INITIAL SIZE 0,
         t_mch1         TYPE STANDARD TABLE OF mch1 INITIAL SIZE 0,
         gt_zwmpalvnd   TYPE STANDARD TABLE OF zwmpalvnd INITIAL SIZE 0.

  DATA : gv_error   TYPE sy-subrc,
         gv_add     TYPE i.

  DATA gv_host   TYPE rfcdisplay-rfchost.
  DATA gs_001    TYPE ztnpqmdt001.
  DATA gv_flag.
  DATA gv_8.

  DATA t_qclabel8 TYPE STANDARD TABLE OF ztnpqmst001_8.
  DATA gt_ltak  TYPE TABLE OF ltak WITH HEADER LINE.
  DATA gt_ltap  TYPE TABLE OF ltap WITH HEADER LINE.
  DATA gt_ltapsv TYPE TABLE OF ltap WITH HEADER LINE.
  DATA gt_ztnpqmdt002 TYPE TABLE OF ztnpqmdt002 WITH HEADER LINE.

  FIELD-SYMBOLS: <fs_ltapsv> LIKE gt_ltapsv.
