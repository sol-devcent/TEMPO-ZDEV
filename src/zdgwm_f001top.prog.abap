*----------------------------------------------------------------------*
*   INCLUDE ZDGWM_F001TOP                                              *
*----------------------------------------------------------------------*
  TABLES: nast,
          tnapr.

  DATA: BEGIN OF t_nast_key,
          mblnr LIKE mkpf-mblnr,
          mjahr LIKE mkpf-mjahr,
          zeile LIKE mseg-zeile,
        END OF t_nast_key.

  DATA: xscreen(1) TYPE c.

  DATA: BEGIN OF t_mseg OCCURS 0,
          mblnr   TYPE mseg-mblnr,
          mjahr   TYPE mseg-mjahr,
          zeile   TYPE mseg-zeile,
          matnr   TYPE mseg-matnr,
          werks   TYPE mseg-werks,
          lgort   TYPE mseg-lgort,
          charg   TYPE mseg-charg,
          lifnr   TYPE mseg-lifnr,
          menge   TYPE mseg-menge,
          meins   TYPE mseg-meins,
          ebeln   TYPE mseg-ebeln,
          aufnr   TYPE mseg-aufnr,
          bukrs   TYPE mseg-bukrs,
          lgnum   TYPE mseg-lgnum,
        END OF t_mseg.

  TYPES: BEGIN OF t_header.
          INCLUDE STRUCTURE zdgstwm_pl_header.
  TYPES: END OF t_header.

  DATA: wa_header TYPE t_header,
        BEGIN OF t_detail OCCURS 0.
          INCLUDE STRUCTURE zdgstwm_pl_detail.
  DATA: END OF t_detail,
        BEGIN OF t_mara OCCURS 0,
          matnr   TYPE mara-matnr,
          mtart   TYPE mara-mtart,
          maktx   TYPE makt-maktx,
        END OF t_mara,
        BEGIN OF t_lfa1 OCCURS 0,
          lifnr   TYPE lfa1-lifnr,
          name1   TYPE lfa1-name1,
        END OF t_lfa1,
        BEGIN OF t_mch1 OCCURS 0,
          matnr   TYPE mch1-matnr,
          charg   TYPE mch1-charg,
          vfdat   TYPE mch1-vfdat,
          licha   TYPE mch1-licha,
          lwedt   TYPE mch1-lwedt,
          hsdat   TYPE mch1-hsdat,
        END OF t_mch1,
        BEGIN OF t_qamb OCCURS 0,
          mblnr     TYPE qamb-mblnr,
          mjahr     TYPE qamb-mjahr,
          zeile     TYPE qamb-zeile,
          prueflos  TYPE qamb-prueflos,
        END OF t_qamb,
        BEGIN OF t_marm OCCURS 0,
          matnr   TYPE marm-matnr,
          meinh   TYPE marm-meinh,
          umrez   TYPE marm-umrez,
        END OF t_marm,

        BEGIN OF t_mlgn OCCURS 0,
          matnr   TYPE mlgn-matnr,
          lgnum   TYPE mlgn-lgnum,
          lhmg1   TYPE mlgn-lhmg1,
        END OF t_mlgn.
