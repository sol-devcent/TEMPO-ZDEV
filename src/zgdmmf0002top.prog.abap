*----------------------------------------------------------------------*
*   INCLUDE ZIBMFMMATDOCPRINTTEMPTOP                                   *
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
          rkpf.

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

  TYPES: BEGIN OF ta_hd.
          INCLUDE STRUCTURE zgdmmst0020.
  TYPES: END OF ta_hd.

  TYPES: BEGIN OF ta_itab.
          INCLUDE STRUCTURE zgdmmst0050.
  TYPES: END OF ta_itab.

  DATA: wa_hd     TYPE ta_hd,
        i_dt      TYPE ta_hd OCCURS 0,
        wa_dt     TYPE ta_hd,
        i_lines   TYPE ta_hd OCCURS 0,
        wa_lines  TYPE ta_hd,
        i_itab    TYPE ta_itab OCCURS 0,
        wa_itab   TYPE ta_itab.

  DATA: gv_banfn  TYPE banfn,
        gv_aufnr  TYPE aufnr,
        gv_matnr  TYPE matnr,
        gv_charg  TYPE charg_d,
        gv_maktx  TYPE maktx,
        gv_knttp  TYPE knttp,
        gv_werks  TYPE ewerk.

  DATA: BEGIN OF t_t157e OCCURS 0,
          spras   TYPE t157e-spras,
          bwart   TYPE t157e-bwart,
          grund   TYPE t157e-grund,
          grtxt   TYPE t157e-grtxt,
        END OF t_t157e.


DATA: it_lfa1 TYPE TABLE OF lfa1.
DATA: count_rm TYPE i.
DATA: count_pm TYPE i.
