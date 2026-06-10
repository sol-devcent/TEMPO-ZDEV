*&---------------------------------------------------------------------*
*&  Include           ZSFASD_I0001T01
*&---------------------------------------------------------------------*
  TYPE-POOLS: truxs.

  TABLES: ztkmsddt001, ztkmsddt002, ztkmsddt004, vttk, tvrot, ztkmsddt006.

  DATA: gs_ztkmsddt001 TYPE ztkmsddt001.
  DATA: gs_ztkmsddt006 TYPE ztkmsddt006.
  DATA: gs_ztkmsddt004 TYPE ztkmsddt004.
  DATA: gs_ztkmsddt002 TYPE ztkmsddt002.
  data: gv_message(200).
  data: gt_idcard type ztkmsddt002 OCCURS 0.
  DATA: gv_retfield    TYPE dfies-fieldname,
        gv_dynprofld   TYPE help_info-dynprofld.
  data: gv_nortm like ztkmsddt002-nortm.
  data: gv_kunnr like likp-kunnr.
  data: gv_vkbur type vkbur.
"  data: "p_route like vttk-route,
"        p_bezei like TVROT-BEZEI.
  data: gv_time(10), gv_date(12), gv_error.
    data: begin of gt_tknum OCCURS 0,
          tknum like ZTKMSDDT001-tknum,
          NORTM like ZTKMSDDT001-NORTM,
          SCANID like ZTKMSDDT001-SCANID,
        end of gt_tknum.
