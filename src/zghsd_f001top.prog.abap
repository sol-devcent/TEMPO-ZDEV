*&---------------------------------------------------------------------*
*&  Include           ZTSPFI_F001TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   INCLUDE ZIBMFMMATDOCPRINTTEMPTOP                                   *
*----------------------------------------------------------------------*
  TABLES: *nast,nast,tnapr,likp,lips.

  DATA: BEGIN OF t_nast_key,
          vbeln LIKE likp-vbeln,
        END OF t_nast_key.

  DATA: xscreen(1) TYPE c.

  DATA: gs_header LIKE zghsdf001,
        gt_detail TYPE TABLE OF zghsdf001 WITH HEADER LINE,
        gt_lips   TYPE TABLE OF lips WITH HEADER LINE,
        gt_makt   TYPE TABLE OF makt WITH HEADER LINE,
        gt_konv   TYPE TABLE OF konv WITH HEADER LINE,
        gv_knumv  LIKE ekko-knumv,
        gv_ihrez  LIKE ekko-ihrez.
