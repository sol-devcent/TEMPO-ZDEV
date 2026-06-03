*&---------------------------------------------------------------------*
*& Program Name     : ZSSUT_R006                                       *
*& Module Name      : MM                                               *
*& Author           : Aji (SAP_DEV02)                                  *
*& Functional       : Gunawan                                          *
*& Create Date      : 01/11/2013                                       *
*& Program Type     : Dialog                                           *
*& Transaction      : N/A                                              *
*& SAP Release      : ECC6                                             *
*& Description      : Report Realisasi Daily Call Plan
*&---------------------------------------------------------------------*
*& REVISION LOG                                                        *
*&---------------------------------------------------------------------*
*& 1   DEVK936589   Aji  22/10/2013   Initial Creation                 *
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT  zssut_r006.

INCLUDE zabpx_alv_common.
INCLUDE zssut_r006_top .
INCLUDE zssut_r006_pbo .
INCLUDE zssut_r006_pai .
INCLUDE zssut_r006_f01 .

START-OF-SELECTION.
  p_uname = sy-uname.
  p_udate = sy-datum.
  PERFORM f_get_data.
  IF gt_itab[] IS INITIAL.
    MESSAGE 'No data found' TYPE 'I'.
  ELSE.
    PERFORM f_display_alv.
  ENDIF.
*  perform f_display_data.
