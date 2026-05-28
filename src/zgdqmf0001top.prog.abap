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

  TABLES: qals.

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

  TYPES: BEGIN OF ta_mara,
           matnr LIKE mara-matnr,
           mtart LIKE mara-mtart,
         END OF ta_mara.

  TYPES: BEGIN OF ta_hd.
          INCLUDE STRUCTURE zgdqmst0010.
  TYPES: END OF ta_hd.

  DATA: i_hd      TYPE ta_hd OCCURS 0,
        wa_itab   TYPE ta_hd,
        i_hd1     TYPE ta_hd OCCURS 0,
        wa_hd1    TYPE ta_hd,
        i_dt      TYPE ta_hd OCCURS 0,
        wa_dt     TYPE ta_hd,
        i_dtout   TYPE ta_hd OCCURS 0,
        i_link    TYPE ta_hd OCCURS 0,
        i_result  TYPE ta_hd OCCURS 0,
        wa_result TYPE ta_hd.

  DATA: va_error TYPE i,
        va_mtart LIKE mara-mtart.

  DATA : charreq  TYPE STANDARD TABLE OF bapi2045d1 INITIAL SIZE 0.
