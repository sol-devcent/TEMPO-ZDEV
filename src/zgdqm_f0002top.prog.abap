*----------------------------------------------------------------------*
*   INCLUDE ZTNPQMF002TOP
*----------------------------------------------------------------------*
  TABLES: *nast,
          nast,
          tnapr,
          mkpf,
          mseg,
          lfa1,
          ekko,
          t001w,
          mara,
          usr21,
          adrp,
          mbew,
          rkpf,
          qals,
          qave.

  DATA: BEGIN OF t_nast_key,
          mblnr LIKE mkpf-mblnr,
          mjahr LIKE mkpf-mjahr,
          zeile LIKE mseg-zeile,
        END OF t_nast_key.

  DATA  BEGIN OF t_mkpf OCCURS 1.
          INCLUDE STRUCTURE mkpf.
  DATA  END   OF t_mkpf.

  DATA: BEGIN OF t_ekpo OCCURS 0.
          INCLUDE STRUCTURE ekpo.
  DATA: END OF t_ekpo.

  DATA  BEGIN OF t_mseg OCCURS 1.
          INCLUDE STRUCTURE mseg.
  DATA  END   OF t_mseg.

  DATA  d_retcode LIKE sy-subrc.
  TABLES  komp.
  TABLES: komk    ,
          komvd   ,
          vbco3   ,
          vbdkr   ,
          vbdpr   ,
          vbdre   .

  DATA: BEGIN OF tkomv OCCURS 50.
          INCLUDE STRUCTURE komv.
  DATA: END OF tkomv.

  DATA: BEGIN OF t_konv OCCURS 50.
          INCLUDE STRUCTURE konv.
  DATA: END OF t_konv.

  DATA: BEGIN OF tvbdpr OCCURS 100.      "Internal table for items
          INCLUDE STRUCTURE vbdpr.
  DATA: END OF tvbdpr.

  DATA: BEGIN OF tkomvd OCCURS 50.
          INCLUDE STRUCTURE komvd.
  DATA: END OF tkomvd.

  DATA: BEGIN OF *tkomvd OCCURS 50.
          INCLUDE STRUCTURE komvd.
  DATA: END OF *tkomvd.

  DATA: BEGIN OF hkomv OCCURS 50.
          INCLUDE STRUCTURE komv.
  DATA: END OF hkomv.

  DATA: BEGIN OF hkomvd OCCURS 50.
          INCLUDE STRUCTURE komvd.
  DATA: END OF hkomvd.

  DATA: BEGIN OF tkomcon OCCURS 50.
          INCLUDE STRUCTURE conf_out.
  DATA: END   OF tkomcon.

  DATA: xscreen(1) TYPE c.

  DATA : va_lines TYPE i.

  DATA: BEGIN OF i_sf0030 OCCURS 0.
          INCLUDE STRUCTURE zgdqmst0030.
  DATA: plnnr     TYPE qals-plnnr,
        plnal     TYPE qals-plnal,
*        lmenge03  TYPE qals-lmenge03,
        prbnaverf TYPE qals-prbnaverf.
  DATA: END OF i_sf0030.

  DATA: t_plko  TYPE STANDARD TABLE OF plko.

  DATA: wa_sf0030 LIKE i_sf0030.

  DATA: BEGIN OF i_sf0031 OCCURS 0.
          INCLUDE STRUCTURE zgdqmst0030.
  DATA: END OF i_sf0031.

  DATA: wa_sf0031 LIKE i_sf0031.

  DATA gt_30  TYPE STANDARD TABLE OF zgdqmst0030.
  DATA t_marm TYPE STANDARD TABLE OF marm.
  DATA gv_mtart TYPE mara-mtart.
  DATA gv_tbtxt TYPE t143t-tbtxt.
  DATA gv_tempb TYPE mara-tempb.
  DATA t_ausp TYPE STANDARD TABLE OF ausp.
  DATA t_qprs TYPE STANDARD TABLE OF qprs.
  DATA t_qapp TYPE STANDARD TABLE OF qapp.

  DATA gv_error  TYPE sy-subrc.
  DATA gv_host   TYPE rfcdisplay-rfchost.
  DATA gs_001    TYPE ztnpqmdt001.
  DATA gv_flag.

  DATA gt_t320   TYPE STANDARD TABLE OF t320.
