*&---------------------------------------------------------------------*
*& Program Name     : ZSFAFI_MENU                                      *
*& Module Name      : FI-SFA                                           *
*& Author           : Suk                                              *
*&---------------------------------------------------------------------*
*& REVISION LOG                                                        *
*&---------------------------------------------------------------------*
*&                                                                     *
*&---------------------------------------------------------------------*


REPORT  zsfafi_menu.
TABLES: tvkbz, t001.
DATA: p_start(15).
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME. " TITLE text-001.
PARAMETERS: p_vkorg LIKE t001-bukrs OBLIGATORY.
PARAMETERS: p_vkbur LIKE tvbur-vkbur OBLIGATORY.
SELECTION-SCREEN SKIP 1.
PARAMETERS: c01 AS CHECKBOX.
SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-001.
PARAMETERS: r01 RADIOBUTTON GROUP r1 USER-COMMAND us1.
SELECTION-SCREEN BEGIN OF LINE.

PARAMETERS: r02 RADIOBUTTON GROUP r1.
SELECTION-SCREEN COMMENT 3(30) text-004 FOR FIELD r02.
*PARAMETERS: c01 AS CHECKBOX.
*SELECTION-SCREEN COMMENT 36(30) text-005.
SELECTION-SCREEN END OF LINE.

PARAMETERS: r03 RADIOBUTTON GROUP r1,
            r04 RADIOBUTTON GROUP r1,
            r05 RADIOBUTTON GROUP r1,
            r06 RADIOBUTTON GROUP r1,
            r08 RADIOBUTTON GROUP r1,
            r09 RADIOBUTTON GROUP r1,
            r10 RADIOBUTTON GROUP r1.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: r11 RADIOBUTTON GROUP r1.
SELECTION-SCREEN COMMENT 3(31) text-007 FOR FIELD r11.
SELECTION-SCREEN END OF LINE.

PARAMETERS: r12 RADIOBUTTON GROUP r1,
            r13 RADIOBUTTON GROUP r1,
            r07 RADIOBUTTON GROUP r1.

"r10 RADIOBUTTON GROUP r1.
SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON RADIOBUTTON GROUP r1.
  IF c01 IS INITIAL.
    CASE 'X'.
      WHEN r10 OR r11.
        c01 = 'X'.
      WHEN OTHERS.
        c01 = ' '.
    ENDCASE.
  ENDIF.

**ZSFAFI_E003
AT SELECTION-SCREEN ON p_vkbur.
  SELECT SINGLE * FROM tvkbz
         WHERE vkbur EQ p_vkbur.
  IF sy-subrc NE 0.
    MESSAGE e000(zs) WITH 'Sales Office Not Found'.
  ENDIF.
  IF p_vkorg EQ '8020'.
    IF p_vkbur EQ 0 OR p_vkbur EQ space OR p_vkbur+0(2) NE '02'.
      MESSAGE e000(zs) WITH 'Sales Office must be entry 02xx'.
    ENDIF.
  ELSEIF p_vkorg EQ '8070'.
    IF p_vkbur EQ 0 OR p_vkbur EQ space OR p_vkbur+0(2) NE '07'.
      MESSAGE e000(zs) WITH 'Sales Office must be entry 07xx'.
    ENDIF.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'V_VBKA_VKO'
      ID 'VKBUR' FIELD p_vkbur.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH 'You are not authorized with Sales Office'
     p_vkbur.
  ENDIF.


START-OF-SELECTION.
  CLEAR: p_start.
  CASE 'X'.
    WHEN r01.
      SUBMIT zsfafi_e001 VIA SELECTION-SCREEN AND RETURN.
    WHEN r02.
      CONCATENATE 'WEB' p_vkorg p_vkbur INTO p_start SEPARATED BY '_'.
      CONDENSE p_start.
      IF c01 = 'X'.
        SUBMIT zsfafi_i002 WITH p_path = '/inbound/sfa/bi/posting/'
                           WITH p_start = p_start
                           WITH p_back = 'X'
                           WITH p_part = ' '
                           WITH p_part2 = 'X'
                           AND RETURN.
      ELSE.
        SUBMIT zsfafi_i002 WITH p_path = '/inbound/sfa/bi/posting/'
                           WITH p_start = p_start
                           WITH p_back = 'X'
                           WITH p_part = ' '
                           WITH p_part2 = ' '
                           AND RETURN.
      ENDIF.
    WHEN r03.
      SUBMIT zsfafi_e002 VIA SELECTION-SCREEN AND RETURN
                         WITH p_vkorg = p_vkorg
                         WITH p_vkbur = p_vkbur.

    WHEN r04.
      CONCATENATE 'CR' p_vkbur INTO p_start SEPARATED BY '_'.
      CONDENSE p_start.
      SUBMIT zsfafi_i003 WITH p_path = '/inbound/sfa/bi/cair/'
                         WITH p_start = p_start "'CR'
                         WITH p_vkbur = p_vkbur
                         WITH p_rad1 = 'X'
                         WITH p_rad2 = ' '
                         WITH p_back = 'X'
                         AND RETURN.

    WHEN r05.
      CONCATENATE 'PG' p_vkbur INTO p_start SEPARATED BY '_'.
      CONDENSE p_start.
      SUBMIT zsfafi_i003 WITH p_path = '/inbound/sfa/bi/batal/'
                         WITH p_start = 'PG'
                         WITH p_vkbur = p_vkbur
                         WITH p_rad1 = ' '
                         WITH p_rad2 = 'X'
                         WITH p_back = 'X'
                         AND RETURN.
    WHEN r06.
      SUBMIT zsfafi_e003 VIA SELECTION-SCREEN AND RETURN
                         WITH p_bukrs = p_vkorg
                         WITH p_vkbur = p_vkbur.

    WHEN r07.
      CONCATENATE 'BI' p_vkbur INTO p_start. " SEPARATED BY space.
      CONDENSE p_start.
      SUBMIT zsfafi_i001 WITH p_path = '/inbound/sfa/bi/stsrel/'
                         WITH p_start = p_start. "'BI'.

    WHEN r08.
      CONCATENATE 'KVS' p_vkorg p_vkbur INTO p_start SEPARATED BY '_'.
      CONDENSE p_start.
      SUBMIT zsfafi_i002_kanvas WITH p_start = p_start
                                WITH p_back = 'X'
                                WITH p_part = c01
                                AND RETURN.

    WHEN r09.
      SUBMIT zsfafi_e002_kanvas VIA SELECTION-SCREEN AND RETURN
                                WITH p_vkorg = p_vkorg
                                WITH p_vkbur = p_vkbur.

    WHEN r10.
      CONCATENATE 'WEB' p_vkorg p_vkbur INTO p_start SEPARATED BY '_'.
      CONDENSE p_start.
      SUBMIT zsfafi_i002_paycust WITH p_start = p_start
                                 WITH p_back = 'X'
                                 WITH p_part = c01
                                 AND RETURN.

    WHEN r11.
      SUBMIT zsfafi_e002_paycust VIA SELECTION-SCREEN AND RETURN
                                 WITH p_vkorg = p_vkorg
                                 WITH p_vkbur = p_vkbur.

**    WHEN r10.
**      CONCATENATE 'DCP' sy-datum(4) p_vkbur  '6' INTO p_dcp.
**      SUBMIT zsfasd_i0004  WITH  p_path = '/inbound/sfa/dcp/'
**                           WITH  p_start = p_dcp.
  ENDCASE.
