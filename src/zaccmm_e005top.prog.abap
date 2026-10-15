*----------------------------------------------------------------------*
*   INCLUDE ZGDMMF0005TOP                                              *
*----------------------------------------------------------------------*
  TABLES: zaccmmdt001,zplbc.

  TYPE-POOLS: slis.

  DATA: gr_alv      TYPE REF TO cl_salv_table,
        gr_function TYPE REF TO cl_salv_functions,
        gr_column   TYPE REF TO cl_salv_column_table,
        gr_columns  TYPE REF TO cl_salv_columns_table.

  DATA: gt_out         TYPE TABLE OF zaccmmst05,
        gt_key         TYPE TABLE OF zaccmmdt001 WITH HEADER LINE,
        gt_zaccmmdt001 TYPE TABLE OF zaccmmst05  WITH HEADER LINE,
        gt_inventory   TYPE TABLE OF zivh_inventory WITH HEADER LINE,
        gt_inventoryd  TYPE TABLE OF zivd_inventory WITH HEADER LINE,
        gt_zaccdtm     TYPE TABLE OF zaccdtm WITH HEADER LINE,
        gt_zaccmmdt001er TYPE TABLE OF zaccmmdt001er,
        gt_zaccdtd     TYPE TABLE OF zaccdtd,
        gt_s501        TYPE TABLE OF s501 WITH HEADER LINE,
        gt_zaccdtm_upd TYPE TABLE OF zaccdtm,
        gt_zaccdta     TYPE TABLE OF zaccdta WITH HEADER LINE,
        gt_zaccdta_upd TYPE TABLE OF zaccdta WITH HEADER LINE,
        gt_zplbc       TYPE TABLE OF zplbc WITH HEADER LINE.

  FIELD-SYMBOLS: <fs_zaccmmdt001er> TYPE zaccmmdt001er,
                 <fs_zaccdtd>       TYPE zaccdtd,
                 <fs_s501>          TYPE s501,
                 <fs_zaccdtm>       TYPE zaccdtm,
                 <fs_zaccdta>       TYPE zaccdta.
