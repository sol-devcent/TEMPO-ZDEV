*&---------------------------------------------------------------------*
*& Program Name     : ZSSUT_R002                                       *
*& Module Name      : SD                                               *
*& Author           : Aji (SAP_DEV02)                                  *
*& Functional       : Gunawan                                          *
*& Create Date      : 22/10/2013                                       *
*& Program Type     : Dialog                                           *
*& Transaction      : N/A                                              *
*& SAP Release      : ECC6                                             *
*& Description      : Process Daily Call Plan: To setup initial plan for customer visitation
*&                    based on available visitation matrix on XD01/XD02 (ZSSUTDT022)
*&                    Should be planned (run) before the visitation date
*&                    Item can be deleted/inserted
*&---------------------------------------------------------------------*
*& REVISION LOG                                                        *
*&---------------------------------------------------------------------*
*& 1  DEVK936589   Aji  22/10/2013   Initial Creation                   *
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  zssut_r012.
INCLUDE zabp_alv_common.
INCLUDE zabp_header.

INCLUDE zssut_r012_top.
INCLUDE zssut_r012_pbo.
INCLUDE zssut_r012_pai.
INCLUDE zssut_r012_f01.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen_1000.
    WHEN space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen_1000.

AT SELECTION-SCREEN ON s_datum.
**  IF  s_datum-high < sy-datum.
**    MESSAGE e002(zz) WITH 'Mohon diperhatikan input tanggalnya !!!'.
**  ENDIF.
  gv_day1 = s_datum-low MOD 7.
  IF gv_day1 > 1.
    gv_day1 = gv_day1 - 1.
  ELSE.
    gv_day1 = gv_day1 + 6.
  ENDIF.
  gv_day2 = s_datum-high MOD 7.
  IF gv_day2 > 1.
    gv_day2 = gv_day2 - 1.
  ELSE.
    gv_day2 = gv_day2 + 6.
  ENDIF.
**  IF gv_day2 < gv_day1.
**    MESSAGE e002(zz) WITH 'Mohon diperhatikan input tanggalnya !!!'.
**  ENDIF.

**  IF p_pernr IS NOT INITIAL.
**    SELECT SINGLE * FROM zssutdt025
**          WHERE vkorg = p_vkorg AND
**                vkbur = p_vkbur AND
**                pernr = p_pernr AND
**                umjah = s_datum-low(4) AND
**                ( str_dcp_dat >= s_datum-low OR end_dcp_dat >= s_datum-low ) AND
**                ZRELEASE = 'X'.
**    IF sy-subrc EQ 0.
**      WRITE zssutdt025-end_dcp_dat TO gv_text.
**      CONCATENATE 'DCP sebelumnya tanggal'  gv_text INTO gv_message SEPARATED BY space.
**      MESSAGE e002(zz) WITH gv_message.
**    ENDIF.
**  ENDIF.

***   IF day_p > 1.
***     day_p = day_p - 1.
***   ELSE.
***     day_p = day_p + 6.
***   ENDIF.

***   day_p = date MOD 7.
**** DAY_P enthält 0 für Samstag, 1 für Sonntag, etc.. und muß
**** der Kalendernotation: 1 für Montag, 2 für Dienstag, etc.,
**** angepaßt werden.
***   IF day_p > 1.
***     day_p = day_p - 1.
***   ELSE.
***     day_p = day_p + 6.
***   ENDIF.
***
***   CASE day_p.
***     WHEN 1.
***       weekday = 'mon'.

*&------------------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&------------------------------------------------------------------------------*
START-OF-SELECTION.
  DATA: gv_answer(1).
  IF p_del = 'X'.
    "p_dcp
    "CONCATENATE 'Sales Office' p_vkbur 'DCP No'  p_dcp1 ' Akan dihapus' INTO gv_message SEPARATED BY space.
    CONCATENATE 'Sales Office' p_vkbur 'DCP No'  s_dcp-low ' Akan dihapus' INTO gv_message SEPARATED BY space.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'PERHATIAN'
        text_question         = gv_message
        text_button_1         = 'Yes'
        icon_button_1         = 'ICON_CHECKED'
        text_button_2         = 'No'
        icon_button_2         = 'ICON_CANCEL'
        display_cancel_button = ' '
      IMPORTING
        answer                = gv_answer
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.
    IF sy-subrc = 0.
      IF gv_answer = '1'.
        SELECT SINGLE * FROM zfbih_sfa
          WHERE bukrs = p_vkorg AND
                vkbur = p_vkbur AND
                daily_call_num IN  s_dcp.
        IF sy-subrc EQ 0.
          CONCATENATE 'DCP No'  s_dcp-low ' Tidak bisa dihapus (sudah ada no. BI'  zfbih_sfa-bbeln ')' INTO gv_message SEPARATED BY space.
          MESSAGE i002(zz) WITH gv_message.
        ELSE.
          UPDATE zssutdt025 SET  status = 'D'
                                 zrelease = space
                                 zprint = 'D'
             WHERE vkorg = p_vkorg AND
                   vkbur = p_vkbur AND
                   pernr = p_pernr AND
                   umjah = s_datum-low(4) AND
                   sdate = s_datum-low AND
                   daily_call_num IN  s_dcp.
          "daily_call_num =  p_dcp1.
          IF sy-subrc EQ 0.
            COMMIT WORK.
            CONCATENATE 'Sales Office' p_vkbur 'DCP No'  s_dcp-low ' Sudah dihapus' INTO gv_message SEPARATED BY space.
            MESSAGE i002(zz) WITH gv_message.
          ELSE.
            ROLLBACK WORK.
            CONCATENATE 'Sales Office' p_vkbur 'DCP No'  s_dcp-low ' Gagal dihapus Silahkan proses ulang' INTO gv_message SEPARATED BY space.
            MESSAGE i002(zz) WITH gv_message.
          ENDIF.
        ENDIF.

      ENDIF.
    ENDIF.
  ELSEIF p_crt = 'X' OR p_chg = 'X'.

  PERFORM f_get_data.
  IF gv_error IS INITIAL.
    PERFORM f_lock_object USING tvkot-vkorg tvkbt-vkbur knvp-pernr
                                zssutdt021-begda zssutdt025-daily_call_num.
    CALL SCREEN 0100.
    PERFORM f_unlock_object USING tvkot-vkorg tvkbt-vkbur knvp-pernr
                                  zssutdt021-begda zssutdt025-daily_call_num.
  ELSE.
    PERFORM f_process_msg.
  ENDIF.
  ELSEIF p_dsp = 'X'.
    PERFORM f_get_data_display.
    IF gt_out[] IS NOT INITIAL.
      PERFORM f_alv TABLES gt_out.
    ELSE.
      MESSAGE i002(zz) WITH 'No Data'.
    ENDIF.
  ENDIF.
