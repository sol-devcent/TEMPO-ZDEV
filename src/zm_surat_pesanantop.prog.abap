*----------------------------------------------------------------------*
*   INCLUDE ZM_SURAT_PESANANTOP
*----------------------------------------------------------------------*
  TABLES: nast,
          tnapr.

  DATA: BEGIN OF t_nast_key,
          matnr LIKE mara-matnr,
        END OF t_nast_key.

  DATA: xscreen(1) TYPE c.

  DATA: BEGIN OF gt_detail OCCURS 0.
          INCLUDE STRUCTURE zmstsp.
  DATA: END OF gt_detail.

  TYPES: BEGIN OF ty_header.
          INCLUDE STRUCTURE zmstsp.
  TYPES: END OF ty_header.

  DATA: gs_header TYPE ty_header.

  DATA : gt_zmpsiko   TYPE STANDARD TABLE OF zmpsiko,
         wa_zmpsiko   LIKE zmpsiko,
         gt_zmpsiko1  TYPE STANDARD TABLE OF zmpsiko1,
         wa_zmpsiko1  LIKE zmpsiko1.

TYPES: BEGIN OF ty_bool,
  werks TYPE werks,
  bool TYPE char1,
  END OF ty_bool.

DATA: gt_bool TYPE TABLE OF ty_bool,
      gs_bool TYPE ty_bool.
