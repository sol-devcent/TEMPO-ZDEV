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
          rkpf,
          vbrk.

  DATA: BEGIN OF t_nast_key,
          vbeln LIKE vbrk-vbeln,
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

  DATA: BEGIN OF t_zgdsdkomer OCCURS 0.
          INCLUDE STRUCTURE zgdsdkomer.
        DATA: END OF t_zgdsdkomer.
  DATA: BEGIN OF t_header OCCURS 0.
          INCLUDE STRUCTURE vbrk.
        DATA: END OF t_header.
  DATA: BEGIN OF t_company OCCURS 0.
          INCLUDE STRUCTURE zgdfaktur001.
        DATA: END OF t_company.

  DATA: wa_header LIKE vbrk.
  DATA: BEGIN OF t_vbrp OCCURS 0.
          INCLUDE STRUCTURE vbrp.
        DATA: END OF t_vbrp.
  DATA: BEGIN OF t_vbrp1 OCCURS 0.
          INCLUDE STRUCTURE vbrp.
          DATA: prcpiece(15).
  DATA: END OF t_vbrp1.
  DATA: BEGIN OF t_detail OCCURS 0.
          INCLUDE STRUCTURE zgdkomerx.
        DATA: END OF t_detail.

  DATA: BEGIN OF t_total OCCURS 0.
          INCLUDE STRUCTURE zgdtxst0004x.
        DATA: END OF t_total.

  DATA: BEGIN OF t_line OCCURS 50.
          INCLUDE STRUCTURE tline.
        DATA: END OF t_line.

  DATA: BEGIN OF t_line_mark OCCURS 50.
          INCLUDE STRUCTURE tline.
        DATA: END OF t_line_mark.

  DATA: va_pay          LIKE rf05a-aktiv,
        va_pay_f        LIKE rf05a-aktiv,
        va_stamp        TYPE char20,
        va_stamp_f      TYPE char20,
        va_words        TYPE char255,
        va_petugas      LIKE zgdtxdt0005-petugas,
        va_jabat        LIKE zgdtxdt0005-jabat,
        va_city         LIKE zgdtxdt0005-pkpcity,
        va_nofktr(16),
        va_fakturno(17),
        va_datab        LIKE zproject-datab,
        va_desc         TYPE zdesc1.

  DATA: BEGIN OF t_rsparams OCCURS 0.
          INCLUDE STRUCTURE rsparams.
        DATA: END OF t_rsparams.

  DATA : gs_dpp   TYPE zproject.
