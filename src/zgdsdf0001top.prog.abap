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
          vbeln LIKE likp-vbeln,
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
          INCLUDE STRUCTURE zgdsdst0011.
  TYPES: END OF ta_hd.

  TYPES: BEGIN OF ta_dt.
          INCLUDE STRUCTURE zgdsdst0010.
  TYPES: END OF ta_dt.

  TYPES: BEGIN OF ta_vbfa,
           vbeln LIKE vbfa-vbeln,
           erdat LIKE vbfa-erdat,
           erzet LIKE vbfa-erzet,
         END OF ta_vbfa.

  DATA: wa_hd   TYPE ta_hd,
        i_dt    TYPE ta_dt OCCURS 0,
        wa_dt   TYPE ta_dt,
        i_vbfa  TYPE ta_vbfa OCCURS 0,
        wa_vbfa TYPE ta_vbfa.

  DATA: va_reprint(3).
  DATA: t_mch1 LIKE mch1 OCCURS 0 WITH HEADER LINE.
  DATA: t_t005t LIKE t005t OCCURS 0 WITH HEADER LINE.
