*&---------------------------------------------------------------------*
*&  Include           ZSFASD_I0001T01
*&---------------------------------------------------------------------*
  TYPE-POOLS: truxs.

  TABLES: ztkmsddt001, ztkmsddt002, ztkmsddt004, vttk, tvrot, ztkmsddt006..

  DATA: gs_ztkmsddt001 TYPE ztkmsddt001.
  DATA: gs_ztkmsddt006 TYPE ztkmsddt006.
  DATA: gs_ztkmsddt004 TYPE ztkmsddt004.
  DATA: gs_ztkmsddt002 TYPE ztkmsddt002.
  DATA: gv_message(200).
  DATA: gt_idcard TYPE ztkmsddt002 OCCURS 0.
  DATA: gv_retfield  TYPE dfies-fieldname,
        gv_dynprofld TYPE help_info-dynprofld.
  DATA: gv_nortm LIKE ztkmsddt002-nortm.
  DATA: gv_date(10), gv_time(10), gv_error(1).
  DATA: BEGIN OF gt_tknum OCCURS 0,
          tknum LIKE ztkmsddt006-tknum,
          nortm LIKE ztkmsddt006-nortm,
          route LIKE ztkmsddt006-route,
        END OF gt_tknum.
  DATA: gv_vkbur TYPE vkbur.
  DATA: gv_kunnr LIKE likp-kunnr.
