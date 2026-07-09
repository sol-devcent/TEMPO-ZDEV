*----------------------------------------------------------------------*
***INCLUDE LZTDS_APIF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_TIMWAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZPROSES  text
*      <--P_GV_EVENT  text
*      <--P_STATUS  text
*----------------------------------------------------------------------*
FORM f_proses_timwas  CHANGING p_proses
                               p_event
                               p_status.
  RANGES: gs_vbeln FOR lips-vbeln.
  CLEAR: gs_vbeln[], gs_vbeln.

  p_status = 'S'.
  CASE p_event.
    WHEN 'TWS_SHPLOADEND'.
      SUBMIT ztwssd_e002 WITH p_tknum = ' ' AND RETURN.
    WHEN 'TWS_PICK'.
      SUBMIT ztwssd_e001 WITH so_vbeln IN gs_vbeln AND RETURN.
    WHEN 'TWS_GMVT'.
      SUBMIT ztwsmm_e001 WITH so_vbeln IN gs_vbeln
                         WITH pa_01 = 'X'
                         WITH pa_04 = 'X'
                         WITH pa_03 = 'X'  AND RETURN.
    WHEN 'TWS_SETTLEMENT'.
      SUBMIT ztwsmm_e001 WITH so_vbeln IN gs_vbeln
                         WITH pa_01 = 'X'
                         WITH pa_04 = 'X'
                         WITH pa_03 = 'X'  AND RETURN.
    WHEN OTHERS.
      p_status = 'E'.
  ENDCASE.
ENDFORM.                    " F_PROSES_TIMWAS
*&---------------------------------------------------------------------*
*&      Form  F_TWS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZPROSES  text
*      <--P_GV_EVENT  text
*      <--P_ZDATA  text
*      <--P_STATUS  text
*----------------------------------------------------------------------*
FORM f_tws_data  CHANGING p_zproses
                          p_event
                          p_zdata
                          p_status.
  RANGES: gs_vbeln FOR lips-vbeln.
  DATA: lv_tknum LIKE vttk-tknum.
  CLEAR: gs_vbeln[], gs_vbeln.
  DATA: lv_ebeln(12), lv_banfn(10).
  DATA: lv_iblnr  LIKE ikpf-iblnr.
  DATA: lv_vkbur     TYPE vstel,
        lv_status(1),
        ld_mess      TYPE char100,
        lv_event     TYPE char15.
  DATA: lt_ztdsitdt006 TYPE STANDARD TABLE OF ztdsitdt006 WITH HEADER LINE.
  DATA: ls_ztdsitdt006 TYPE ztdsitdt006.
  p_status = 'S'.
  CONDENSE p_zdata.
  ls_ztdsitdt006-zproses = 'TIMWAS'.
  ls_ztdsitdt006-zevent = p_event.
  ls_ztdsitdt006-zdata = p_zdata.
  ls_ztdsitdt006-erdat = sy-datum.
  ls_ztdsitdt006-ernam = sy-uname.
  ls_ztdsitdt006-erzet = sy-uzeit.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.
**  CALL FUNCTION 'ZBP_EVENT_RAISE'
**    EXPORTING
**      eventid                = 'TIMWAS'
**    EXCEPTIONS
**      bad_eventid            = 1" eventparm = gv_EVENTPARM
**      eventid_does_not_exist = 2
**      eventid_missing        = 3
**      raise_failed           = 4.


  CASE p_event.
    WHEN 'TWS_CN'.
      CONDENSE p_zdata.
      gs_vbeln-low = p_zdata.
      CONDENSE gs_vbeln-low.
      APPEND gs_vbeln.
      SUBMIT ztwssd_e001 WITH so_vbeln IN gs_vbeln
                         WITH p_check = 'X'
                         WITH p_branch = ' '
                         WITH p_gito = ' '
                         WITH p_cn = 'X' AND RETURN.
    WHEN 'TWS_PID'.
      CONDENSE p_zdata.
      lv_iblnr = p_zdata.
      CONDENSE lv_iblnr.
      SUBMIT ztwsmm_e007 WITH p_iblnr = lv_iblnr AND RETURN.
    WHEN 'TWS_SCRAP'.
      CONDENSE p_zdata.
      lv_ebeln = p_zdata.
      CONDENSE lv_ebeln.
      SUBMIT ztwsmm_e005 WITH p_ebeln = lv_ebeln
                         WITH p_check = 'X' AND RETURN.
    WHEN 'TWS_STO'.
      CONDENSE p_zdata.
      lv_banfn = p_zdata.
      CONDENSE lv_banfn.
      SUBMIT ztwsmm_e004 WITH p_banfn = lv_banfn
                         WITH p_check = 'X' AND RETURN.
    WHEN 'TWS_CCNT'.
      CONDENSE p_zdata.
      lv_iblnr = p_zdata.
      CONDENSE lv_iblnr.
      SUBMIT ztwsmm_e003 WITH p_iblnr = lv_iblnr
                         WITH p_check = 'X' AND RETURN.
    WHEN 'TWS_POSTINGPID'.
      CONDENSE p_zdata.
      lv_iblnr = p_zdata.
      CONDENSE lv_iblnr.
      SUBMIT ztwsmm_e008 WITH p_iblnr = lv_iblnr
                         WITH p_check = 'X' AND RETURN.
    WHEN 'TWS_GRPRC'.
      CONDENSE p_zdata.
      lv_ebeln = p_zdata.
      CONDENSE lv_ebeln.
      SUBMIT ztwsmm_e002 WITH p_ebeln = lv_ebeln
                         WITH p_check = 'X'
                         WITH p_po = 'X'
                         WITH p_ship = ' ' AND RETURN.
    WHEN 'TWS_DIRECT'.
      CONDENSE p_zdata.
      lv_ebeln = p_zdata.
      CONDENSE lv_ebeln.
      SUBMIT ztwsmm_e002 WITH p_ebeln = lv_ebeln
                         WITH p_check = 'X'
                         WITH p_po = ' '
                         WITH p_ship = 'X' AND RETURN.
    WHEN 'TWS_SHPLOADEND'.
      CONDENSE p_zdata.
      lv_tknum = p_zdata.
      CONDENSE lv_tknum.
      SUBMIT ztwssd_e002 WITH p_tknum = lv_tknum
                         WITH p_check = 'X' AND RETURN.
    WHEN 'TWS_GITOBRANCH'.
      CONDENSE p_zdata.
      gs_vbeln-low = p_zdata.
      CONDENSE gs_vbeln-low.
      APPEND gs_vbeln.
      SUBMIT ztwssd_e001 WITH so_vbeln IN gs_vbeln
                         WITH p_check = 'X'
                         WITH p_branch = ' '
                         WITH p_cn = ' '
                         WITH p_gito = 'X' AND RETURN.
    WHEN 'TWS_PICK'.
      CONDENSE p_zdata.
      gs_vbeln-low = p_zdata.
      CONDENSE gs_vbeln-low.
      APPEND gs_vbeln.
      SUBMIT ztwssd_e001 WITH so_vbeln IN gs_vbeln
                         WITH p_check = 'X'
                         WITH p_branch = 'X'
                         WITH p_cn = ' '
                         WITH p_gito = ' ' AND RETURN.
    WHEN 'TWS_GMVT'.
      CONDENSE p_zdata.
      gs_vbeln-low = p_zdata.
      CONDENSE gs_vbeln-low.
      APPEND gs_vbeln.
      SUBMIT ztwsmm_e001 WITH so_vbeln IN gs_vbeln
                         WITH p_prc01 = 'X'
                         WITH pa_01 = 'X'
                         WITH pa_04 = 'X'
                         WITH pa_03 = 'X'
                         WITH p_check = 'X' AND RETURN.
    WHEN 'TWS_SETTLEMENT'.
      CONDENSE p_zdata.
      gs_vbeln-low = p_zdata.
      CONDENSE gs_vbeln-low.
      APPEND gs_vbeln.
      SUBMIT ztwsmm_e001 WITH so_vbeln IN gs_vbeln
                         WITH p_prc02 = 'X'
                         WITH pa_01 = 'X'
                         WITH pa_04 = 'X'
                         WITH pa_03 = 'X'
                         WITH p_check = 'X' AND RETURN.
    WHEN 'TWS_TRFSTOCK'.
      CONDENSE p_zdata.
      lv_ebeln = p_zdata.
      CONDENSE lv_ebeln.
      SUBMIT ztwsmm_e010 WITH p_ebeln = lv_ebeln AND RETURN.
    WHEN 'TWS_MATLP'.
      CONDENSE p_zdata.
      lv_vkbur = p_zdata.
      lv_event = p_event.
      CALL FUNCTION 'ZTWSIT_F0002'
        EXPORTING
          proses  = lv_event
          vkbur   = lv_vkbur
        IMPORTING
          status  = lv_status
          message = ld_mess.
      ls_ztdsitdt006-status = lv_status.
      ls_ztdsitdt006-message = ld_mess.
      MODIFY ztdsitdt006 FROM ls_ztdsitdt006.

    WHEN OTHERS.
      p_status = 'E'.
  ENDCASE.

ENDFORM.                    " F_TWS_DATA
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DISKON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZPROSES  text
*      <--P_GV_EVENT  text
*      <--P_ZDATA  text
*      <--P_STATUS  text
*----------------------------------------------------------------------*
FORM f_proses_diskon  CHANGING p_zproses
                          p_event
                          p_zdata
                          p_status..
  DATA: ld_disno(20).
  DATA: lt_ztdsitdt006 TYPE STANDARD TABLE OF ztdsitdt006 WITH HEADER LINE.
  DATA: ls_ztdsitdt006 TYPE ztdsitdt006.
  p_status = 'S'.
  CONDENSE p_zdata.
  ls_ztdsitdt006-zproses = 'DISKON'.
  ls_ztdsitdt006-zevent = p_event.
  ls_ztdsitdt006-zdata = p_zdata.
  ls_ztdsitdt006-erdat = sy-datum.
  ls_ztdsitdt006-ernam = sy-uname.
  ls_ztdsitdt006-erzet = sy-uzeit.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.

  CASE p_event.
    WHEN 'UPLOAD'.
      ld_disno = p_zdata.
      SUBMIT zedisc_e002 WITH p_disno = ld_disno
                          AND RETURN.
      p_status = 'S'.
    WHEN 'DISKON'.
      SUBMIT zedisc_e001 WITH p_rad1 = 'X'
                         WITH p_rad2 = ' '
                         AND RETURN.
      p_status = 'S'.
    WHEN 'DISKON_GEM'.
      SUBMIT zedisc_e001 WITH p_rad3 = 'X'
                         WITH p_rad2 = ' '
                         WITH p_rad1 = ' '
                         AND RETURN.
      p_status = 'S'.
    WHEN 'KOTN'.
      SUBMIT zedisc_e001 WITH p_rad2 = 'X'
                         WITH p_rad1 = ' '
                         AND RETURN.
      p_status = 'S'.
    WHEN OTHERS.
      p_status = 'E'.
  ENDCASE.
ENDFORM.                    " F_PROSES_DISKON
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_TIVEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZPROSES  text
*      <--P_ZEVENT  text
*      <--P_ZDATA  text
*      <--P_STATUS  text
*----------------------------------------------------------------------*
FORM f_proses_tivem  CHANGING p_zproses
                              p_event
                              p_zdata
                              p_status.
  DATA: lv_sortl  TYPE sortl.
  DATA: lt_ztdsitdt006 TYPE STANDARD TABLE OF ztdsitdt006 WITH HEADER LINE.
  DATA: ls_ztdsitdt006 TYPE ztdsitdt006.
  p_status = 'S'.
  CONDENSE p_zdata.
  ls_ztdsitdt006-zproses = 'TIVEM'.
  ls_ztdsitdt006-zevent = p_event.
  ls_ztdsitdt006-zdata = p_zdata.
  ls_ztdsitdt006-erdat = sy-datum.
  ls_ztdsitdt006-ernam = sy-uname.
  ls_ztdsitdt006-erzet = sy-uzeit.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.
  p_status = 'S'.
  CLEAR: lv_sortl.
  CASE p_event.
    WHEN 'TKM_LFA1'.
      lv_sortl = p_zdata.
      SUBMIT ztkmmm_i002 WITH  p_sortl = lv_sortl
                      AND RETURN.
    WHEN 'TKM_COST'.
      SUBMIT ztkmsd_e014 WITH  r1 = 'X'
                      AND RETURN.
    WHEN OTHERS.
      p_status = 'E'.
  ENDCASE.
ENDFORM.                    " F_PROSES_TIVEM
