REPORT zfvatout_without_fb09 MESSAGE-ID zf NO STANDARD PAGE HEADING
*                                  line-count 63(3)
                                  LINE-SIZE  255.

************************************************************************
*                  REPORT                                              *
*----------------------------------------------------------------------*
* ABAP Name   :                                                        *
* Created by  : Sukardi                                                *
* Created on  :                                                        *
*----------------------------------------------------------------------*
* Description :                                                        *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
* Date    Programmer  Correction  Description
*
*----------------------------------------------------------------------*
************************************************************************
* INCLUDES                                                             *
************************************************************************
INCLUDE yf_include_zfvatout.

DATA: p_bukrs(4) VALUE '8020'.

DATA: BEGIN OF t_vata1 OCCURS 0.
        INCLUDE STRUCTURE zfvata1.
DATA: END OF t_vata1.

DATA: BEGIN OF t_download OCCURS 0.
DATA:   thnpjk(4),
        blnpjk(2),
        pembtl(2),
        kdlamp(1),
        kdstat(1),
        npwp(15),
        nmwp(30),
        kddocu(1),
        kdfktr(5),
        kdkpp(3),
        nofktr(27),
        tglfkt(10),
        nilppn(15),
        nilppnbm(15).
DATA: END OF t_download.

DATA: BEGIN OF wa_espt,
        kodepjk(1),
        txt1(1)  VALUE ';',
        kodelam(1),
        txt2(1)  VALUE ';',
        kodests(1),
        txt3(1)  VALUE ';',
        kodedok(1),
        txt4(1)  VALUE ';',
        npwp(20),
        txt5(1)  VALUE ';',
        nama(35),
        txt6(1)  VALUE ';',
        kodecab(3),
        txt7(1)  VALUE ';',
        kodethn(2),
        txt8(1)  VALUE ';',
        nofkt(30),
        txt9(1)  VALUE ';',
        tglfkt(10),
        txt10(1)  VALUE ';',
        tglssp(10),
        txt11(1)  VALUE ';',
        masapjk(2),
        txt12(1)  VALUE ';',
        thnpjk(4),
        txt13(1)  VALUE ';',
        betul(1),
        txt14(1)  VALUE ';',
        dpp(15),
        txt15(1)  VALUE ';',
        ppn(15),
        txt16(1)  VALUE ';',
        ppnbm(15),
      END OF wa_espt,

      BEGIN OF wa_espt11,
        kodepjk(1),
        txt1(1)  VALUE ';',
        kodelam(1),
        txt2(1)  VALUE ';',
        kodests(1),
        txt3(1)  VALUE ';',
        kodedok(1),
        txt4(1)  VALUE ';',
        flagvat(1),
        txt5(1)  VALUE ';',
        npwp(20),
        txt6(1)  VALUE ';',
        nama(35),
        txt7(1)  VALUE ';',
        nodok(50),
        txt8(1)  VALUE ';',
        jnsdok(1),
        txt9(1)  VALUE ';',
        nodok1(50),
        txt10(1)  VALUE ';',
        jnsdok1(1),
        txt11(1)  VALUE ';',
        tglfkt(10),
        txt12(1)  VALUE ';',
        tglssp(10),
        txt13(1)  VALUE ';',
        masapjk(4),
        txt14(1)  VALUE ';',
        thnpjk(4),
        txt15(1)  VALUE ';',
        betul(1),
        txt16(1)  VALUE ';',
        dpp(15),
        txt17(1)  VALUE ';',
        ppn(15),
        txt18(1)  VALUE ';',
        ppnbm(15),
      END OF wa_espt11,

      BEGIN OF i_espt OCCURS 0,
        data(255),
      END OF i_espt.

****************************************************
*        Parameters                                *
****************************************************
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS : pa_bukrs LIKE t001-bukrs,
             pa_gsber LIKE tgsb-gsber. " DEFAULT '0200'.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(31) text-011.
PARAMETERS : pa_monat LIKE ical_info-month_no
                  DEFAULT sy-datum+4(2).
SELECTION-SCREEN POSITION 42.
PARAMETERS : pa_check AS CHECKBOX.
SELECTION-SCREEN : COMMENT 45(20) text-012.
PARAMETERS : pa_betul(1)  DEFAULT 0.
SELECTION-SCREEN END OF LINE.
PARAMETERS : pa_gjahr LIKE bsis-gjahr DEFAULT sy-datum+0(4),
             pa_date  LIKE sy-datum DEFAULT sy-datum OBLIGATORY,
             pa_post  LIKE sy-datum DEFAULT sy-datum OBLIGATORY.
SELECTION-SCREEN SKIP 1.
PARAMETERS : pa_sign(24).
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF SCREEN 100 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME .
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio1 RADIOBUTTON GROUP grp1
             USER-COMMAND rad DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(35) text-003 FOR FIELD radio1.
SELECTION-SCREEN POSITION 50.
PARAMETERS: pa_test DEFAULT 'X' AS CHECKBOX .
SELECTION-SCREEN : COMMENT 52(20) text-020 FOR FIELD pa_test.
SELECTION-SCREEN END OF LINE.
SELECT-OPTIONS:
  so_belnr FOR bsis-belnr MODIF ID bel.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) text-004 FOR FIELD radio2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) text-005 FOR FIELD radio3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) text-006 FOR FIELD radio4.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(27) text-007 FOR FIELD radio5.
SELECTION-SCREEN POSITION 30.
SELECTION-SCREEN : COMMENT 35(10) text-022.
SELECT-OPTIONS : so_tbel1 FOR zfvata1-tbeln MODIF ID tb1
                 NO INTERVALS.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio13 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(27) text-017 FOR FIELD radio13.
SELECTION-SCREEN POSITION 30.
SELECTION-SCREEN : COMMENT 35(10) text-022.
SELECT-OPTIONS : so_tbel3 FOR zfvata1-tbeln MODIF ID tb3
                 NO INTERVALS.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio6 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(27) text-008 FOR FIELD radio6.
SELECTION-SCREEN POSITION 30.
SELECTION-SCREEN : COMMENT 35(10) text-022.
SELECT-OPTIONS : so_tbel2 FOR zfvata1-tbeln MODIF ID tb2
                 NO INTERVALS.
SELECTION-SCREEN END OF LINE.
*  SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN END OF SCREEN 100.

SELECTION-SCREEN BEGIN OF SCREEN 200 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio7 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(35) text-009 FOR FIELD radio7.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio8 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(35) text-010 FOR FIELD radio8.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio9 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(35) text-013 FOR FIELD radio9.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio14 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(35) text-018 FOR FIELD radio14.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio10 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(35) text-014 FOR FIELD radio10.
SELECTION-SCREEN END OF LINE.

* New selection untuk download
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio99 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(35) text-099 FOR FIELD radio99.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : a1espt11 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(35) text-098 FOR FIELD a1espt11.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : a3espt11 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(35) text-097 FOR FIELD a3espt11.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN END OF SCREEN 200.

SELECTION-SCREEN BEGIN OF SCREEN 300 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio11 RADIOBUTTON GROUP grp3.
SELECTION-SCREEN : COMMENT 5(35) text-015 FOR FIELD radio11.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio15 RADIOBUTTON GROUP grp3.
SELECTION-SCREEN : COMMENT 5(35) text-019 FOR FIELD radio15.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio12 RADIOBUTTON GROUP grp3.
SELECTION-SCREEN : COMMENT 5(35) text-016 FOR FIELD radio12.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_filenm LIKE rlgrap-filename. "OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b3.
SELECTION-SCREEN END OF SCREEN 300.

* STANDARD SELECTION SCREEN
SELECTION-SCREEN: BEGIN OF TABBED BLOCK mytab FOR 10 LINES,
                  TAB (20) button1 USER-COMMAND push1,
                  TAB (20) button2 USER-COMMAND push2,
                  TAB (20) button3 USER-COMMAND push3,
                  END OF BLOCK mytab.


************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.
  pa_bukrs = '8020'.
  pa_gsber = '0200'.

  CASE sy-uname(3).
    WHEN 'PTT'.
      pa_bukrs = '8020'.
      pa_gsber = '0200'.
    WHEN 'TSP'.
      pa_bukrs = '8010'.
      pa_gsber = '0101'.
    WHEN OTHERS.
      DATA: lv_parva(40).

      SELECT SINGLE parva
        FROM usr05
        INTO lv_parva
        WHERE bname EQ sy-uname AND
              parid EQ 'BUK'.

      IF sy-subrc EQ 0.
        pa_bukrs  = lv_parva.
      ENDIF.

      CLEAR lv_parva.

      SELECT SINGLE parva
        FROM usr05
        INTO lv_parva
        WHERE bname EQ sy-uname AND
              parid EQ 'GSB'.

      IF sy-subrc EQ 0.
        pa_gsber  = lv_parva.
      ENDIF.
  ENDCASE.

*  IF sy-uname(3) = 'PTT'.
*    pa_bukrs = '8020'.
*    pa_gsber = '0200'.
*  ENDIF.
*  IF sy-uname(3) = 'TSP'.
*    pa_bukrs = '8010'.
*    pa_gsber = '0101'.
*  ENDIF.

  PERFORM initialize_all.
  button1 = text-100.
  button2 = text-200.
  button3 = text-300.
  mytab-prog = sy-repid.
  mytab-dynnr = 100.
  mytab-activetab = 'BUTTON1'.

** BEGIN ALV
*    G_REPID = SY-REPID.
*    PERFORM BUILD_FIELDCAT.
*    PERFORM LAYOUT_INIT USING GS_LAYOUT.
*    PERFORM EVENTTAB_BUILD USING GT_EVENTS[].
*    GS_VARIANT-REPORT = G_REPID.
*    G_SAVE            = 'A'.
*    XIS_PRINT-NO_PRINT_SELINFOS  = 'X'.
*    XIS_PRINT-NO_PRINT_LISTINFOS = 'X'.
** END ALV

*****************************************************
*  Radio1   ---> Input Data Form A3
*  Radio2   ---> Print Report A1
*  RADIO3   ---> PRINT REPORT A2
*  Radio4   ---> Print Report A3
*  Radio5   ---> Post to GL Report A1
*  Radio6   ---> Post to GL Report A3
*  Radio7   ---> Download A1 for TSP
*  Radio8   ---> Download A3 for TSP
*  Radio9   ---> Download A1 for PTT & EC
*  Radio10  ---> Download A3 for PTT & EC
*  Radio11  ---> Upload A1
*  Radio12  ---> Upload A3
*****************************************************

************************************************************************
* PROGRAM                                                              *
************************************************************************
************************************************************************
* AT SELECTION-SCREEN
************************************************************************

AT SELECTION-SCREEN OUTPUT.
  p_bukrs = '8010'.

  PERFORM f_modify_screen.

  IF radio1 = 'X' OR
    radio2 = 'X' OR
    radio3 = 'X' OR
    radio4 = 'X'.
    LOOP AT SCREEN.
      IF ( screen-group1 = 'TB1' OR
           screen-group1 = 'TB2' OR
           screen-group1 = 'TB3' ).
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    CLEAR so_tbel1. REFRESH so_tbel1.
    CLEAR so_tbel2. REFRESH so_tbel2.
    CLEAR so_tbel3. REFRESH so_tbel3.
  ELSEIF radio5 = 'X'.
    LOOP AT SCREEN.
      IF ( screen-group1 = 'TB2' OR
           screen-group1 = 'TB3' ).
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    CLEAR so_tbel2. REFRESH so_tbel2.
    CLEAR so_tbel3. REFRESH so_tbel3.
  ELSEIF radio6 = 'X'.
    LOOP AT SCREEN.
      IF ( screen-group1 = 'TB1' OR
           screen-group1 = 'TB3' ).
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    CLEAR so_tbel1. REFRESH so_tbel1.
    CLEAR so_tbel3. REFRESH so_tbel3.
  ELSEIF radio13 = 'X'.
    LOOP AT SCREEN.
      IF ( screen-group1 = 'TB1' OR
           screen-group1 = 'TB2' ).
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    CLEAR so_tbel1. REFRESH so_tbel1.
    CLEAR so_tbel2. REFRESH so_tbel2.
  ENDIF.

AT SELECTION-SCREEN.
  CASE sy-dynnr.
    WHEN 1000.
      CASE sy-ucomm.
        WHEN 'PUSH1'.
          mytab-dynnr = 100.
          mytab-activetab = 'BUTTON1'.
          option = 0.
        WHEN 'PUSH2'.
          mytab-dynnr = 200.
          mytab-activetab = 'BUTTON2'.
          option = 1.
        WHEN 'PUSH3'.
          mytab-dynnr = 300.
          mytab-activetab = 'BUTTON3'.
          option = 2.
      ENDCASE.
  ENDCASE.

*AT SELECTION-SCREEN ON RADIOBUTTON GROUP GRP2.
*  IF PA_BUKRS EQ '8010'.
*    IF RADIO9 EQ 'X' OR
*       RADIO10 EQ 'X'.
*      message e000(ZF) with ' '.
*    ENDIF.
*  ELSEIF PA_BUKRS NE '8010'.
*    IF RADIO7 EQ 'X' OR
*       RADIO8 EQ 'X'.
*       message e000(ZF) with ' '.
*    ENDIF.
*  ENDIF.

AT SELECTION-SCREEN ON pa_bukrs.
  p_bukrs = '8010'.
*  IF pa_bukrs EQ '8020' OR pa_bukrs EQ '8010' OR
*    pa_bukrs EQ '8030' OR pa_bukrs EQ '8070'.
*  ELSE.
*    CASE sy-dynnr.
*      WHEN 1000.
*        CASE sy-ucomm.
*          WHEN 'PUSH1'.
*            mytab-dynnr = 100.
*            mytab-activetab = 'BUTTON1'.
*            option = 0.
*          WHEN 'PUSH2'.
*            mytab-dynnr = 200.
*            mytab-activetab = 'BUTTON2'.
*            option = 1.
*          WHEN 'PUSH3'.
*            mytab-dynnr = 300.
*            mytab-activetab = 'BUTTON3'.
*            option = 2.
*        ENDCASE.
*    ENDCASE.
*    MESSAGE e000(zf)
*      WITH 'CoCd must be entry (8010, 8020, 8030, 8070)'.
*  ENDIF.

AT SELECTION-SCREEN ON pa_gsber.
  SELECT SINGLE * FROM tgsb
         WHERE gsber EQ pa_gsber.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Business Area Not Found'.
  ENDIF.
  IF pa_bukrs EQ '8020'.
    IF pa_gsber NE '0200'.
      MESSAGE e000(zf) WITH 'Business Area must be entry 0200'.
    ENDIF.
  ELSEIF pa_bukrs EQ '8030'.
    IF pa_gsber EQ 0 OR pa_gsber EQ space OR pa_gsber+0(2) NE '03'.
      MESSAGE e000(zf) WITH 'Business Area must be entry 03xx'.
    ENDIF.
  ELSEIF pa_bukrs EQ '8010'.
    IF pa_gsber EQ 0 OR pa_gsber EQ space OR pa_gsber+0(2) NE '01'.
      MESSAGE e000(zf) WITH 'Business Area must be entry 01xx'.
    ENDIF.
  ELSEIF pa_bukrs EQ '8070'.
    IF pa_gsber EQ 0 OR pa_gsber EQ space OR pa_gsber+0(2) NE '07'.
      MESSAGE e000(zf) WITH 'Business Area must be entry 07xx'.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON pa_monat.
  IF pa_monat > 12.
    MESSAGE e000(k#) WITH 'Invalid Periode (01..12) '.
  ENDIF.
  IF pa_monat < 1.
    MESSAGE e000(k#) WITH 'Invalid Periode (01..12) '.
  ENDIF.

AT SELECTION-SCREEN ON pa_betul.
  IF pa_check = 'X'.
    IF pa_betul EQ '0' OR pa_betul CN '123456789'.
      MESSAGE e000(k#) WITH 'Must be entry (1..9)'.
    ELSE.
      PERFORM fsay.
    ENDIF.
  ENDIF.

*AT SELECTION-SCREEN ON PA_POST.
*  IF RADIO1 = 'X' AND PA_POST IS INITIAL.
*      RADIO1 = SPACE.
*      message e000(ZF) with 'Input Posting Date'.
*  ELSE.
*
*  ENDIF.

*at selection-screen ON RADIOBUTTON GROUP GRP1.
*IF OPTION = 0.
*   IF radio1 = 'X' AND pa_post is initial.
*       message e000(ZF) with 'Input Posting Date'.
*   endif.
*ELSE.
*
*Endif.

MODULE init_0100 OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'MOD'.
      CASE flag.
        WHEN 'X'.
          screen-input = '1'.
        WHEN ' '.
          screen-input = '0'.
      ENDCASE.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.                    "init_0100 OUTPUT

*----------------------------------------------------------------------*
*  MODULE user_command_0100 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  MESSAGE s888(sabapdocu) WITH text-050 sy-dynnr.
  CASE sy-ucomm.
    WHEN 'TOGGLE'.
      IF flag = ' '.
        flag = 'X'.
      ELSEIF flag = 'X'.
        flag = ' '.
      ENDIF.
  ENDCASE.
ENDMODULE.                    "user_command_0100 INPUT

* GET POSSIBLE ENTRIES OF FILE NAME
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_filenm.
  PERFORM f_get_filename.


************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.

  CLEAR va_xref3.
  IF pa_test = 'X'.
    va_mode = 'N'.
  ELSE.
    va_mode = 'A'.
  ENDIF.

*IF PA_BUKRS EQ '8010'.
*   IF RADIO9 EQ 'X' OR
*      RADIO10 EQ 'X'.
*      message I000(ZF) with 'Error'.
*      SWITCH = '1'.
*   ENDIF.
*ELSEIF PA_BUKRS NE '8010'.
*   IF RADIO7 EQ 'X' OR
*      RADIO8 EQ 'X'.
*      message I000(ZF) with 'Error'.
*      SWITCH = '1'.
*   ENDIF.
*ENDIF.

  CHECK switch = '0'.

  IF option = 0.
    IF radio1 = 'X'.
      radio9 = space.
      radio10 = space.
      PERFORM f_get_nota_retur.
      PERFORM f_post_to_gl.
      DESCRIBE TABLE i_log_error LINES c1.
      IF c1 > 0.
        SKIP 5.
        FORMAT COLOR 6.
        WRITE: / 'Log Error Posting'.
        LOOP AT i_log_error INTO wa_log_error.
          WRITE: / sy-vline, wa_log_error-bukrs,
                   sy-vline, wa_log_error-msg.
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF radio2 = 'X'.
      radio9 = space.
      radio10 = space.
      PERFORM fsay_month.
      PERFORM f_cetak_a1.
    ENDIF.

    IF radio3 = 'X'.
      radio9 = space.
      radio10 = space.
      PERFORM fsay_month.
      PERFORM f_cetak_a2.
    ENDIF.

    IF radio4 = 'X'.
      radio9 = space.
      radio10 = space.
      PERFORM fsay_month.
      PERFORM f_cetak_a3.
    ENDIF.

    IF radio5 = 'X'.
      radio9 = space.
      radio10 = space.

      CALL SCREEN 900.

*      write pa_monat to va_monat.
*      write pa_gjahr to va_year.
*      Clear i_bdc.
*      PERFORM F_DYNPRO USING:
*         'X'  'SAPMSVMA'     '0100',
*         ' '  'BDC_OKCODE'    '=UPD',
*         ' '  'VIEWNAME'      'ZFVATA1',
*         ' '  'VIMDYNFLDS-LTD_DTA_NO'   ' ',
*         ' '  'VIMDYNFLDS-LTD_DTA_AR'   'X',
*
*         'X'  'SAPLSVIX'     '0210',
*         ' '  'BDC_OKCODE'    '=OKAY',
*         ' '  'MARK_CHECKBOX(01)'   'X',
*         ' '  'MARK_CHECKBOX(02)'   'X',
*         ' '  'MARK_CHECKBOX(03)'   'X',
*         ' '  'MARK_CHECKBOX(04)'   'X',
*
*         'X'  'SAPLSVIX'     '0100',
*         ' '  'BDC_OKCODE'   '=OKAY',
*         ' '  'D0100_FIELD_TAB-LOWER_LIMIT(01)' Pa_bukrs,
*         ' '  'D0100_FIELD_TAB-LOWER_LIMIT(02)' Pa_gsber,
*         ' '  'D0100_FIELD_TAB-LOWER_LIMIT(03)' va_year,
*         ' '  'D0100_FIELD_TAB-LOWER_LIMIT(04)' va_monat.
*
*      CALL TRANSACTION 'YF01' USING i_BDC
*                           MODE 'E'
*                           UPDATE 'S'
*                           MESSAGES INTO i_MESSTAB.
*   call transaction 'SM30'.
    ENDIF.

    IF radio13 = 'X'.
      radio9 = space.
      radio10 = space.

      CALL SCREEN 920.
    ENDIF.

    IF radio6 = 'X'.
      radio9 = space.
      radio10 = space.

      CALL SCREEN 910.
*      write pa_monat to va_monat.
*      write pa_gjahr to va_year.
*      Clear i_bdc.
*      PERFORM F_DYNPRO USING:
*         'X'  'SAPMSVMA'     '0100',
*         ' '  'BDC_OKCODE'    '=UPD',
*         ' '  'VIEWNAME'      'ZFVATA3',
*         ' '  'VIMDYNFLDS-LTD_DTA_NO'   ' ',
*         ' '  'VIMDYNFLDS-LTD_DTA_AR'   'X',
*
*         'X'  'SAPLSVIX'     '0210',
*         ' '  'BDC_OKCODE'    '=OKAY',
*         ' '  'MARK_CHECKBOX(01)'   'X',
*         ' '  'MARK_CHECKBOX(02)'   'X',
*         ' '  'MARK_CHECKBOX(03)'   'X',
*         ' '  'MARK_CHECKBOX(04)'   'X',
*
*         'X'  'SAPLSVIX'     '0100',
*         ' '  'BDC_OKCODE'   '=OKAY',
*         ' '  'D0100_FIELD_TAB-LOWER_LIMIT(01)' Pa_bukrs,
*         ' '  'D0100_FIELD_TAB-LOWER_LIMIT(02)' Pa_gsber,
*         ' '  'D0100_FIELD_TAB-LOWER_LIMIT(03)' va_year,
*         ' '  'D0100_FIELD_TAB-LOWER_LIMIT(04)' va_monat.
*
*      CALL TRANSACTION 'YF01' USING i_BDC
*                           MODE 'E'
*                           UPDATE 'S'
*                           MESSAGES INTO i_MESSTAB.
*   call transaction 'SM30'.
    ENDIF.
  ENDIF.

  IF option = 1.
    IF radio7 = 'X'.
      radio9 = space.
      radio10 = space.
      radio99 = space.
      a1espt11  = space.
      a3espt11  = space.
      PERFORM f_download_a1.
    ENDIF.

    IF radio8 = 'X'.
      radio9 = space.
      radio10 = space.
      radio99 = space.
      a1espt11  = space.
      a3espt11  = space.
      PERFORM f_download_a3.
    ENDIF.

    IF radio9 = 'X'.
      radio7 = space.
      radio8 = space.
      radio99 = space.
      a1espt11  = space.
      a3espt11  = space.
      IF pa_gjahr GT 2003.
        PERFORM f_download_a1.
      ELSE.
        PERFORM get_data_a1.
        PERFORM write_data_a1.
      ENDIF.
    ENDIF.

    IF radio14 = 'X'.
      radio7 = space.
      radio8 = space.
      radio99 = space.
      a1espt11  = space.
      a3espt11  = space.
      PERFORM f_download_a2.
    ENDIF.

    IF radio10 = 'X'.
      radio7 = space.
      radio8 = space.
      radio99 = space.
      a1espt11  = space.
      a3espt11  = space.
      IF pa_gjahr GT 2003.
        PERFORM f_download_a3.
      ELSE.
        PERFORM get_data_a3.
        PERFORM write_data_a3.
      ENDIF.
    ENDIF.

* New selection untuk download
    IF radio99 EQ 'X'.
      radio7 = space.
      radio8 = space.
      radio9 = space.
      radio10 = space.
      radio14 = space.
      a1espt11  = space.
      a3espt11  = space.
      PERFORM f_download_a1_new.
      PERFORM download_a1.
    ENDIF.

    IF a1espt11 EQ 'X'.
      radio7 = space.
      radio8 = space.
      radio9 = space.
      radio10 = space.
      radio14 = space.
      radio99  = space.
      a3espt11  = space.
      PERFORM get_data_a1.
      PERFORM f_download_espt_a1.
    ENDIF.

    IF a3espt11 EQ 'X'.
      radio7 = space.
      radio8 = space.
      radio9 = space.
      radio10 = space.
      radio14 = space.
      radio99  = space.
      a1espt11  = space.
      PERFORM get_data_a3.
      PERFORM f_download_espt_a3.
    ENDIF.
  ENDIF.

  IF option = 2.
    IF radio11 = 'X'.
      radio9 = space.
      radio10 = space.
      PERFORM get_upload_a1.
    ENDIF.

    IF radio15 = 'X'.
      radio9 = space.
      radio10 = space.
      PERFORM get_upload_a2.
    ENDIF.

    IF radio12 = 'X'.
      radio9 = space.
      radio10 = space.
      PERFORM get_upload_a3.
    ENDIF.
  ENDIF.

* BEGIN ALV
  IF pa_bukrs EQ '8010'.
    g_repid = sy-repid.
    PERFORM build_fieldcat1.
    PERFORM layout_init1 USING gs_layout.
    PERFORM eventtab_build1 USING gt_events[].
    gs_variant-report = g_repid.
    g_save            = 'A'.
    xis_print-no_print_selinfos  = 'X'.
    xis_print-no_print_listinfos = 'X'.
  ELSE.
    g_repid = sy-repid.
    PERFORM build_fieldcat.
    PERFORM layout_init USING gs_layout.
    PERFORM eventtab_build USING gt_events[].
    gs_variant-report = g_repid.
    g_save            = 'A'.
    xis_print-no_print_selinfos  = 'X'.
    xis_print-no_print_listinfos = 'X'.
  ENDIF.
* END ALV

  INCLUDE zf_form_a1.
  INCLUDE zf_form_a2.
  INCLUDE zf_form_a3.

************************************************************************
* AT LINE-SELECTION.
************************************************************************
AT LINE-SELECTION.
  DATA: va_value LIKE bsis-belnr,
        va_value1 LIKE lfa1-lifnr,
        va_fieldname(30).

  IF sy-lsind = 1.
    GET CURSOR FIELD va_fieldname VALUE va_value.
    CASE va_fieldname.
      WHEN 'WA_ITAB1-BELNR'.
        SET PARAMETER ID  'BLN' FIELD va_value.
        SET PARAMETER ID  'BUK' FIELD pa_bukrs.
*             set parameter id  'GJR' field pa_gjahr.
        SET PARAMETER ID  'GJR' FIELD wa_itab1-gjahr.
        CALL TRANSACTION 'FB02' AND SKIP FIRST SCREEN.
    ENDCASE.
  ENDIF.

END-OF-SELECTION.

  IF pa_gjahr EQ 2003.
    IF radio9 EQ 'X' OR
       radio10 EQ 'X'.
*"List Header for Top-Of-Page
      PERFORM comment_build USING gt_list_top_of_page[].
*"Display List
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_background_id         = 'ALV_BACKGROUND'
          i_callback_program      = g_repid
          is_layout               = gs_layout
          is_print                = xis_print
          i_save                  = g_save
          is_variant              = gs_variant
          it_events               = gt_events[]
          it_fieldcat             = xit_fieldcat[]
        IMPORTING
          e_exit_caused_by_caller = g_exit_caused_by_caller
          es_exit_caused_by_user  = gs_exit_caused_by_user
        TABLES
          t_outtab                = ta_excel
        EXCEPTIONS
          program_error           = 1
          OTHERS                  = 2.
    ENDIF.
  ENDIF.

  IF pa_bukrs EQ '8010'.
    IF radio7 EQ 'X' OR
      radio8 EQ 'X'.
*"List Header for Top-Of-Page
      PERFORM comment_build USING gt_list_top_of_page[].
*"Display List
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_background_id         = 'ALV_BACKGROUND'
          i_callback_program      = g_repid
          is_layout               = gs_layout
          is_print                = xis_print
          i_save                  = g_save
          is_variant              = gs_variant
          it_events               = gt_events[]
          it_fieldcat             = xit_fieldcat[]
        IMPORTING
          e_exit_caused_by_caller = g_exit_caused_by_caller
          es_exit_caused_by_user  = gs_exit_caused_by_user
        TABLES
          t_outtab                = ta_excel1
        EXCEPTIONS
          program_error           = 1
          OTHERS                  = 2.
    ENDIF.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  initialize_all
*&---------------------------------------------------------------------*
*       Routine for initializing all variables
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initialize_all.
  CLEAR: i_itab1, va_post.
  switch = '0'.
ENDFORM.                               " initialize_all
*&---------------------------------------------------------------------*
*&      Form  fsay
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fsay.
  CASE pa_betul.
    WHEN '1'.
      va_ke = 'Satu'.
    WHEN '2'.
      va_ke = 'Dua'.
    WHEN '3'.
      va_ke = 'Tiga'.
    WHEN '4'.
      va_ke = 'Empat'.
    WHEN '5'.
      va_ke = 'Lima'.
    WHEN '6'.
      va_ke = 'Enam'.
    WHEN '7'.
      va_ke = 'Tujuh'.
    WHEN '8'.
      va_ke = 'Delapan'.
    WHEN '9'.
      va_ke = 'Sembilan'.
  ENDCASE.

ENDFORM.                    " fsay

*&---------------------------------------------------------------------*
*&      Form  fsay_month
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fsay_month.
  va_thn = pa_gjahr.
  CASE pa_monat.
    WHEN '01' OR '1 ' OR ' 1'.
      va_prd = 'Januari'.
    WHEN '02' OR '2 ' OR ' 2'.
      va_prd = 'Pebruari'.
    WHEN '03' OR '3 ' OR ' 3'.
      va_prd = 'Maret'.
    WHEN '04' OR '4 ' OR ' 4'.
      va_prd = 'April'.
    WHEN '05' OR '5 ' OR ' 5'.
      va_prd = 'Mei'.
    WHEN '06' OR '6 ' OR ' 6'.
      va_prd = 'Juni'.
    WHEN '07' OR '7 ' OR ' 7'.
      va_prd = 'Juli'.
    WHEN '08' OR '8 ' OR ' 8'.
      va_prd = 'Agustus'.
    WHEN '09' OR '9 ' OR ' 9'.
      va_prd = 'September'.
    WHEN '10'.
      va_prd = 'Oktober'.
    WHEN '11'.
      va_prd = 'Nopember'.
    WHEN '12'.
      va_prd = 'Desember'.
  ENDCASE.
ENDFORM.                    "fsay_month
*&---------------------------------------------------------------------*
*&      Form  f_post_to_gl.
*&---------------------------------------------------------------------*
FORM f_post_to_gl.
  DATA: l_form(2), l_tax(2).
  DATA:
        va_answer,
        BEGIN OF it_message OCCURS 5.
          INCLUDE STRUCTURE popuptext.
  DATA: END OF it_message.
  DATA: va_ctr TYPE i, i TYPE i, sw(1),
        l_itab LIKE wa_itab1, l_text(20),
        e_itab LIKE wa_itab1.

  DATA: va_bldat(6).
  DATA: ld_error TYPE i.

  ta_date-sign   = 'I'.
  ta_date-option = 'BT'.
  CONCATENATE pa_gjahr pa_monat '01' INTO ta_date-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ta_date-low
    IMPORTING
      last_day_of_month = ta_date-high.
  ta_date-high = ta_date-high + 1.
  APPEND ta_date.
  CONCATENATE pa_gjahr pa_monat INTO va_bldat.

*************** Collect Data For A1 & A3
*DELETE SELECTION
*     select a~bukrs a~hkont a~gjahr a~belnr a~BUDAT
*            a~WAERS a~XBLNR a~BLART a~MONAT a~BSCHL a~SHKZG
*            a~MWSKZ a~DMBTR a~SGTXT a~ZFBDT a~zuonr a~xref3
*            a~belnr a~gsber a~shkzg
*            b~BKTXT b~BLDAT
*            into CORRESPONDING FIELDS OF wa_itab1
*            from  bsis as a join BKPF as b on  a~bukrs eq b~bukrs and
*                                               a~belnr eq b~belnr and
*                                               a~gjahr eq b~gjahr
*            where a~hkont eq '0315300200'  and
*                  a~bukrs eq pa_bukrs      and
*                  ( a~monat eq pa_monat or a~zfbdt <= ta_date-high )
*and
*                  a~gjahr <= pa_gjahr      and
*                  a~gsber eq pa_gsber.
*            if wa_itab1-bldat+4(2) <= PA_MONAT and
*               wa_itab1-bldat(4)   <= pa_gjahr.
*                 append wa_itab1 to i_itab1.
*            endif.
*     endselect.
*END DELETE SELECTION

*INSERT SELECTION
  SELECT a~bukrs a~hkont a~gjahr a~belnr a~budat
         a~waers a~xblnr a~blart a~monat a~bschl a~shkzg
         a~mwskz a~dmbtr a~sgtxt a~zfbdt a~zuonr a~xref3
         a~belnr a~gsber a~shkzg
         b~bktxt b~bldat
    INTO CORRESPONDING FIELDS OF wa_itab1
    FROM  bsis AS a JOIN bkpf AS b ON  a~bukrs EQ b~bukrs AND
                                       a~belnr EQ b~belnr AND
                                       a~gjahr EQ b~gjahr
    WHERE a~bukrs EQ pa_bukrs      AND
          a~hkont EQ '0315300200'  AND
          a~budat LE pa_post       AND
*             a~MONAT <= PA_MONAT      AND
*             a~gjahr <= pa_gjahr      and
          a~gsber EQ pa_gsber      AND
          a~blart   EQ 'TR'        AND
          a~belnr   IN so_belnr.
    IF wa_itab1-bldat+0(6) = va_bldat.
      APPEND wa_itab1 TO i_itab1.
    ENDIF.
  ENDSELECT.
*END INSERT SELECTION

  CLEAR: wa_itab1.
  LOOP AT i_itab1 INTO wa_itab1.
* ----- validasi untuk clearing document -----
*FI_CLEARED_ACCOUNTS_READ
    CALL FUNCTION 'FI_CLEARED_ACCOUNTS_READ'
      EXPORTING
        i_bukrs              = wa_itab1-bukrs
        i_belnr              = wa_itab1-belnr
        i_gjahr              = wa_itab1-gjahr
        i_cross_company      = 'X'
      TABLES
        t_agko               = tab_agko
      EXCEPTIONS
        document_not_found   = 1
        no_clearing_document = 2
        missing_data         = 3
        data_not_consistent  = 4
        OTHERS               = 5.

    IF sy-subrc NE 2 AND sy-subrc NE 0.
*         MOVE WA_ITAB1-XREF3+0(5) TO WA_ITAB1-XREF3.
*           Perform f_post_fb09.
      DELETE i_itab1.
    ENDIF.
    IF pa_bukrs EQ '8070'.
    ELSE.
      IF wa_itab1-xref3(2) = 'XX'.
        DELETE i_itab1.
      ENDIF.
    ENDIF.
    CLEAR: wa_itab1.
  ENDLOOP.

  DESCRIBE TABLE i_itab1 LINES va_ctr.
  IF va_ctr <= 0.
    WRITE: / 'Data not found'.
    EXIT.
  ENDIF.

  CLEAR: wa_itab1, va_ctr, i_itab1a1, i_itab1a3, i_itab1err.
  PERFORM f_init_column.
*     Sort i_itab1 by zfbdt zuonr.
  LOOP AT i_itab1 INTO wa_itab1.

    CONCATENATE wa_itab1-blart '-' wa_itab1-belnr
               INTO wa_itab1-xblnr.
    MOVE wa_itab1-bldat TO wa_itab1-zfbdt.
*         wa_itab1-dmbtr = wa_itab1-dmbtr * 100.
    l_form = wa_itab1-xref3+3(2).
    l_tax  = wa_itab1-xref3+0(2).

    IF wa_itab1-zfbdt EQ 0 OR  wa_itab1-zfbdt EQ space.
      l_form = 'EE'.
    ENDIF.
    IF e_itab-bukrs EQ wa_itab1-bukrs AND
       e_itab-gsber EQ wa_itab1-gsber AND
       e_itab-gjahr EQ wa_itab1-gjahr AND
       e_itab-zfbdt EQ wa_itab1-zfbdt AND
       e_itab-zuonr EQ wa_itab1-zuonr.
      sw = 1.
      wa_itab1-error = 'Data Double'.
      APPEND wa_itab1 TO i_itab1err.
      ADD 1 TO va_ctr.
      CLEAR e_itab.
      tot_dmbtr = tot_dmbtr +  wa_itab1-dmbtr.
      MOVE-CORRESPONDING wa_itab1 TO e_itab.
      CONTINUE.
    ENDIF.

    IF l_form = 'A1'.
      SELECT SINGLE * FROM  zfvata1
             WHERE bukrs EQ wa_itab1-bukrs AND
                   gsber EQ wa_itab1-gsber AND
                   gjahr EQ wa_itab1-gjahr AND
                   monat EQ pa_monat       AND
                   txdat EQ wa_itab1-zfbdt AND
                   tbeln EQ wa_itab1-zuonr.
      IF sy-subrc NE 0.
*               concatenate l_tax l_form pa_monat
*                   into wa_itab1-xref3 separated by '|'.
        IF ld_error IS INITIAL.
          APPEND wa_itab1 TO i_itab1a1.
        ENDIF.
      ELSE.
        wa_itab1-error = 'Data Double dengan database'.
        APPEND wa_itab1 TO i_itab1err.
        ADD 1 TO va_ctr.
      ENDIF.
* tambahan A2.
    ELSEIF l_form = 'A2'.
      SELECT SINGLE * FROM  zfvata2
             WHERE bukrs EQ wa_itab1-bukrs AND
                   gsber EQ wa_itab1-gsber AND
                   gjahr EQ wa_itab1-gjahr AND
                   monat EQ pa_monat       AND
                   txdat EQ wa_itab1-zfbdt AND
                   tbeln EQ wa_itab1-zuonr.
      IF sy-subrc NE 0.
*               concatenate l_tax l_form pa_monat
*                   into wa_itab1-xref3 separated by '|'.
        IF ld_error IS INITIAL.
          APPEND wa_itab1 TO i_itab1a2.
        ENDIF.
      ELSE.
        wa_itab1-error = 'Data Double dengan database'.
        APPEND wa_itab1 TO i_itab1err.
        ADD 1 TO va_ctr.
      ENDIF.
    ELSEIF l_form = 'A3' OR l_form = 'A4'.
      SELECT SINGLE * FROM  zfvata3
             WHERE bukrs EQ wa_itab1-bukrs AND
                   gsber EQ wa_itab1-gsber AND
                   gjahr EQ wa_itab1-gjahr AND
                   monat EQ pa_monat       AND
                   txdat EQ wa_itab1-zfbdt AND
                   tbeln EQ wa_itab1-zuonr.
      IF sy-subrc NE 0.
*               concatenate l_tax l_form pa_monat
*                   into wa_itab1-xref3 separated by '|'.
        IF ld_error IS INITIAL.
          APPEND wa_itab1 TO i_itab1a3.
        ENDIF.
      ELSE.
        wa_itab1-error = 'Data Double dengan database'.
        APPEND wa_itab1 TO i_itab1err.
        ADD 1 TO va_ctr.
      ENDIF.
    ELSE.
      IF pa_bukrs EQ '8070'.
        SELECT SINGLE * FROM  zfvatxx
               WHERE bukrs EQ wa_itab1-bukrs AND
                     gsber EQ wa_itab1-gsber AND
                     gjahr EQ wa_itab1-gjahr AND
                     monat EQ pa_monat       AND
                     txdat EQ wa_itab1-zfbdt AND
                     tbeln EQ wa_itab1-zuonr.
        IF sy-subrc NE 0.
          IF ld_error IS INITIAL.
            APPEND wa_itab1 TO i_itab1xx.
          ENDIF.
        ELSE.
          wa_itab1-error = 'Data Double dengan database'.
          APPEND wa_itab1 TO i_itab1err.
          ADD 1 TO va_ctr.
        ENDIF.
      ELSE.
        wa_itab1-error = 'Data ada yang salah'.
        APPEND wa_itab1 TO i_itab1err.
        ADD 1 TO va_ctr.
      ENDIF.
    ENDIF.

* tambahan checking dmbtr +/-
    IF wa_itab1-shkzg EQ 'H'.
      wa_itab1-dmbtr = wa_itab1-dmbtr * -1.
    ENDIF.

    tot_dmbtr = tot_dmbtr +  wa_itab1-dmbtr.

    MOVE-CORRESPONDING wa_itab1 TO e_itab.
    CLEAR wa_itab1.
  ENDLOOP.


******************** Cetak Error *******************
  DESCRIBE TABLE i_itab1err LINES va_ctr.
  IF va_ctr > 0.
    CLEAR it_message.
    it_message-text = 'Masih ada data salah dan Double'.
    APPEND it_message.
    it_message-text = 'Pilih Cancel untuk Kembali Menu awal'.
    APPEND it_message.
    it_message-text = 'Pilih Continue untuk Koreksi'.
    APPEND it_message.
    CALL FUNCTION 'DD_POPUP_WITH_INFOTEXT'
      EXPORTING
        titel        = 'Koreksi Data'
        start_column = 1
        start_row    = 1
        end_row      = 5
      IMPORTING
        answer       = va_answer
      TABLES
        lines        = it_message
      EXCEPTIONS
        OTHERS       = 1.
    IF va_answer NE 'Y'.
      EXIT.
    ENDIF.
    FORMAT COLOR 5.
    c1 =  w1 + w2 + w3 + w4 + w5 + w6 + w7 + w9 + w10 + 8.
    va_title = 'List Document VAT-Out Yang Harus dikoreksi'.
    PERFORM f_write_header.
    SORT i_itab1err BY bukrs gsber gjahr zfbdt zuonr.
    CLEAR: wa_itab1, tot_dmbtr, va_ctr, sw.
    LOOP AT i_itab1err INTO wa_itab1.
      ADD 1 TO va_ctr.
      sw = va_ctr MOD 2.
      IF sw = 0.
        FORMAT COLOR 2.
        FORMAT INTENSIFIED OFF.
      ELSE.
        FORMAT COLOR 1.
        FORMAT INTENSIFIED OFF.
      ENDIF.
      PERFORM f_write_detail.
      WRITE: wa_itab1-error NO-GAP.
      HIDE: wa_itab1-belnr.
      c1 = 1.
      grand_dmbtr = grand_dmbtr + wa_itab1-dmbtr.
      CLEAR wa_itab1.
    ENDLOOP.
    PERFORM f_write_total.
  ELSE.
******************** Cetak Form A1 *******************
    DESCRIBE TABLE i_itab1a1 LINES va_ctr.
    IF va_ctr > 0.
      FORMAT COLOR 5.
      c1 =  w1 + w2 + w3 + w4 + w5 + w6 + w7 + w9 + w10 + 8.
      va_title =
         'List Document VAT-Out (A1)'.
      PERFORM f_write_header.
      SORT i_itab1a1 BY bukrs gsber gjahr zfbdt zuonr.
      CLEAR: wa_itab1, tot_dmbtr, va_ctr, sw, grand_dmbtr.
      LOOP AT i_itab1a1 INTO wa_itab1.
        ADD 1 TO va_ctr.
        sw = va_ctr MOD 2.
        IF sw = 0.
          FORMAT COLOR 2.
          FORMAT INTENSIFIED OFF.
        ELSE.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
        ENDIF.
        l_form = wa_itab1-xref3+3(2).
        l_tax  = wa_itab1-xref3+0(2).
        MOVE pa_bukrs TO zfvata1-bukrs.
        MOVE pa_gsber TO zfvata1-gsber.
        MOVE pa_gjahr TO zfvata1-gjahr.
        MOVE pa_monat TO zfvata1-monat.
        MOVE wa_itab1-zfbdt TO zfvata1-txdat.
        MOVE wa_itab1-zuonr TO zfvata1-tbeln.
        MOVE wa_itab1-sgtxt TO zfvata1-name1.
        MOVE wa_itab1-bktxt TO zfvata1-stceg.
        MOVE wa_itab1-shkzg TO zfvata1-shkzg.
        MOVE 'IDR'    TO zfvata1-waers.
        MOVE wa_itab1-dmbtr TO zfvata1-dmbtr.
        IF l_tax = 'T0' OR l_tax = 'T3'.
          zfvata1-zstatus = '11'.
          MOVE wa_itab1-xref3 TO va_xref3t0.
*                  concatenate l_tax l_form pa_monat
*                     into va_xref3t0 separated by '|'.
        ELSEIF l_tax = 'T1'.
          zfvata1-zstatus = '13'.
          MOVE wa_itab1-xref3 TO va_xref3t1.
*                  concatenate l_tax l_form pa_monat
*                     into va_xref3t1 separated by '|'.
        ELSEIF l_tax = 'T2'.
          zfvata1-zstatus = '17'.
          MOVE wa_itab1-xref3 TO va_xref3t2.
*                  concatenate l_tax l_form pa_monat
*                     into va_xref3t2 separated by '|'.
        ENDIF.

        PERFORM f_insert_a1 ON COMMIT.

        IF wa_itab1-shkzg = 'H'.
          wa_itab1-dmbtr = wa_itab1-dmbtr * -1.
        ENDIF.
        tot_dmbtr = tot_dmbtr + wa_itab1-dmbtr.
        va_xref3 = wa_itab1-xref3.

        PERFORM f_write_detail.
        HIDE: wa_itab1-belnr.
        c1 = 1.
*******           Perform f_post_fb09.

*             if va_ctr = 900.
*                 va_post = 'A1'.
*                 grand_dmbtr = grand_dmbtr + tot_dmbtr.
*                 if tot_dmbtr < 0.
*                    tot_dmbtr  = tot_dmbtr  * -1.
*                    va_BSCHL = '50'.
*                 Else.
*                    va_BSCHL = '40'.
*                 Endif.
*                 perform f_post_f04.
*                 tot_dmbtr = 0.
*                 va_ctr = 1.
*             Endif.
        CLEAR wa_itab1.
      ENDLOOP.

      grand_dmbtr = grand_dmbtr + tot_dmbtr.
      va_hkont1 =  c_hkont_210.
      va_hkont2 =  c_hkont_200.
      PERFORM f_write_total.
      va_post = 'A1'.
      IF tot_dmbtr < 0.
        tot_dmbtr  = tot_dmbtr  * -1.
        va_bschl = '50'.
      ELSE.
        va_bschl = '40'.
      ENDIF.
*          if va_ctr ne 900.
      PERFORM f_post_f04.
*          endif.
      CLEAR va_post.
    ENDIF.

******************** Cetak Form A2 *******************
    DESCRIBE TABLE i_itab1a2 LINES va_ctr.
    IF va_ctr > 0.
      FORMAT COLOR 5.
      c1 =  w1 + w2 + w3 + w4 + w5 + w6 + w7 + w9 + w10 + 8.
      va_title =
         'List Document VAT-Out (A2)'.
      PERFORM f_write_header.
      SORT i_itab1a2 BY bukrs gsber gjahr zfbdt zuonr.
      CLEAR: wa_itab1, tot_dmbtr, tot_dmbtr1,
             va_ctr, sw, grand_dmbtr.
      LOOP AT i_itab1a2 INTO wa_itab1.
        ADD 1 TO va_ctr.
        sw = va_ctr MOD 2.
        IF sw = 0.
          FORMAT COLOR 2.
          FORMAT INTENSIFIED OFF.
        ELSE.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
        ENDIF.
        l_form = wa_itab1-xref3+3(2).
        l_tax  = wa_itab1-xref3+0(2).
        MOVE pa_bukrs TO zfvata2-bukrs.
        MOVE pa_gsber TO zfvata2-gsber.
        MOVE pa_gjahr TO zfvata2-gjahr.
        MOVE pa_monat TO zfvata2-monat.
        MOVE wa_itab1-zfbdt TO zfvata2-txdat.
        MOVE wa_itab1-zuonr TO zfvata2-tbeln.
        MOVE wa_itab1-sgtxt TO zfvata2-name1.
        MOVE wa_itab1-bktxt TO zfvata2-stceg.
        MOVE wa_itab1-shkzg TO zfvata2-shkzg.
        MOVE 'IDR'    TO zfvata2-waers.
        MOVE wa_itab1-dmbtr TO zfvata2-dmbtr.
        IF l_tax = 'T0' OR l_tax = 'T3'.
          zfvata2-zstatus = '21'.
          MOVE wa_itab1-xref3 TO va_xref3t0.
*                  concatenate l_tax l_form pa_monat
*                     into va_xref3t0 separated by '|'.
        ELSEIF l_tax = 'T1' OR l_tax = 'T2'.
          zfvata2-zstatus = '23'.
          MOVE wa_itab1-xref3 TO va_xref3t1.
*                  concatenate l_tax l_form pa_monat
*                     into va_xref3t1 separated by '|'.
        ENDIF.
        PERFORM f_insert_a2 ON COMMIT.
        IF wa_itab1-shkzg = 'H'.
          wa_itab1-dmbtr = wa_itab1-dmbtr * -1.
        ENDIF.
        tot_dmbtr1 = tot_dmbtr1 + wa_itab1-dmbtr.
        va_xref3 = wa_itab1-xref3.

        PERFORM f_write_detail.
        HIDE: wa_itab1-belnr.
        c1 = 1.
        va_hkont1 =  c_hkont_211.
        va_hkont2 =  c_hkont_200.
        va_post = 'A2'.
        tot_dmbtr = wa_itab1-dmbtr.
        IF tot_dmbtr < 0.
          tot_dmbtr  = tot_dmbtr  * -1.
          va_bschl = '50'.
        ELSE.
          va_bschl = '40'.
        ENDIF.
        PERFORM f_post_f04.
        CLEAR wa_itab1.
      ENDLOOP.
      grand_dmbtr = grand_dmbtr + tot_dmbtr1.
      PERFORM f_write_total.
      CLEAR va_post.
    ENDIF.

******************** Cetak Form A3 *******************
    DESCRIBE TABLE i_itab1a3 LINES va_ctr.
    IF va_ctr > 0.
      FORMAT COLOR 5.
      c1 =  w1 + w2 + w3 + w4 + w5 + w6 + w7 + w9 + w10 + 8.
      va_title =
        'List Document VAT-Out (A3)'.
      PERFORM f_write_header.
      SORT i_itab1a3 BY bukrs gsber gjahr zfbdt zuonr.
      CLEAR: wa_itab1, tot_dmbtr, va_ctr, sw, grand_dmbtr.
      LOOP AT i_itab1a3 INTO wa_itab1.
        ADD 1 TO va_ctr.
        sw = va_ctr MOD 2.
        IF sw = 0.
          FORMAT COLOR 2.
          FORMAT INTENSIFIED OFF.
        ELSE.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
        ENDIF.
        PERFORM f_write_detail.
        l_form = wa_itab1-xref3+3(2).
        l_tax  = wa_itab1-xref3+0(2).
        MOVE pa_bukrs TO zfvata3-bukrs.
        MOVE pa_gsber TO zfvata3-gsber.
        MOVE pa_gjahr TO zfvata3-gjahr.
        MOVE pa_monat TO zfvata3-monat.
        MOVE wa_itab1-zfbdt TO zfvata3-txdat.
        MOVE wa_itab1-zuonr TO zfvata3-tbeln.
        MOVE wa_itab1-sgtxt TO zfvata3-name1.
        MOVE wa_itab1-bktxt TO zfvata3-stceg.
        MOVE wa_itab1-shkzg TO zfvata3-shkzg.
        MOVE 'IDR'          TO zfvata3-waers.
        MOVE wa_itab1-dmbtr TO zfvata3-dmbtr.
        IF pa_bukrs EQ '8030'.
          zfvata3-zstatus = '32'.
        ELSEIF pa_bukrs NE '8030'.
          zfvata3-zstatus = '30'.
        ENDIF.
        PERFORM f_insert_a3 ON COMMIT.
        HIDE: wa_itab1-belnr.
*******          Perform f_post_fb09.
        IF l_form EQ 'A3'.
          va_xref3 = wa_itab1-xref3.
          CONCATENATE wa_itab1-xref3(3) 'A4' wa_itab1-xref3+5(3)
          INTO va_xref4.
        ELSEIF l_form EQ 'A4'.
          va_xref4 = wa_itab1-xref3.
          CONCATENATE wa_itab1-xref3(3) 'A3' wa_itab1-xref3+5(3)
          INTO va_xref3.
        ENDIF.
        c1 = 1.
        IF wa_itab1-shkzg = 'H'.
          wa_itab1-dmbtr = wa_itab1-dmbtr * -1.
        ENDIF.
        tot_dmbtr = tot_dmbtr + wa_itab1-dmbtr.
*             if va_ctr = 900.
*                 va_post = 'A3'.
*                 if tot_dmbtr < 0.
*                    tot_dmbtr  = tot_dmbtr  * -1.
*                    va_BSCHL = '50'.
*                 Else.
*                    va_BSCHL = '40'.
*                 Endif.
*                 perform f_post_f04.
*                 tot_dmbtr = 0.
*                 va_ctr = 1.
*             Endif.
        CLEAR wa_itab1.
      ENDLOOP.
      grand_dmbtr = grand_dmbtr + tot_dmbtr.
      PERFORM f_write_total.
      va_post = 'A3'.
      va_hkont1 =  c_hkont_220.
      va_hkont2 =  c_hkont_200.
      IF tot_dmbtr < 0.
        tot_dmbtr  = tot_dmbtr  * -1.
        va_bschl = '50'.
      ELSE.
        va_bschl = '40'.
      ENDIF.
*          if va_ctr = 900.
*             exit.
*          endif.
      PERFORM f_post_f04.
      CLEAR va_post.
    ENDIF.

******************** Cetak Form XX *******************
    DESCRIBE TABLE i_itab1xx LINES va_ctr.
    IF va_ctr > 0.
      FORMAT COLOR 5.
      c1 =  w1 + w2 + w3 + w4 + w5 + w6 + w7 + w9 + w10 + 8.
      va_title =
         'List Document VAT-Out (XX)'.
      PERFORM f_write_header.
      SORT i_itab1xx BY bukrs gsber gjahr zfbdt zuonr.
      CLEAR: wa_itab1, tot_dmbtr, va_ctr, sw, grand_dmbtr.
      LOOP AT i_itab1xx INTO wa_itab1.
        ADD 1 TO va_ctr.
        sw = va_ctr MOD 2.
        IF sw = 0.
          FORMAT COLOR 2.
          FORMAT INTENSIFIED OFF.
        ELSE.
          FORMAT COLOR 1.
          FORMAT INTENSIFIED OFF.
        ENDIF.
        l_form = wa_itab1-xref3+3(2).
        l_tax  = wa_itab1-xref3+0(2).
        MOVE pa_bukrs TO zfvatxx-bukrs.
        MOVE pa_gsber TO zfvatxx-gsber.
        MOVE pa_gjahr TO zfvatxx-gjahr.
        MOVE pa_monat TO zfvatxx-monat.
        MOVE wa_itab1-zfbdt TO zfvatxx-txdat.
        MOVE wa_itab1-zuonr TO zfvatxx-tbeln.
        MOVE wa_itab1-sgtxt TO zfvatxx-name1.
        MOVE wa_itab1-bktxt TO zfvatxx-stceg.
        MOVE wa_itab1-shkzg TO zfvatxx-shkzg.
        MOVE 'IDR'    TO zfvatxx-waers.
        MOVE wa_itab1-dmbtr TO zfvatxx-dmbtr.
        IF l_tax = 'T0' OR l_tax = 'T3'.
          zfvatxx-zstatus = '11'.
          MOVE wa_itab1-xref3 TO va_xref3t0.
*                  concatenate l_tax l_form pa_monat
*                     into va_xref3t0 separated by '|'.
        ELSEIF l_tax = 'T1'.
          zfvatxx-zstatus = '13'.
          MOVE wa_itab1-xref3 TO va_xref3t1.
*                  concatenate l_tax l_form pa_monat
*                     into va_xref3t1 separated by '|'.
        ELSEIF l_tax = 'T2'.
          zfvatxx-zstatus = '17'.
          MOVE wa_itab1-xref3 TO va_xref3t2.
*                  concatenate l_tax l_form pa_monat
*                     into va_xref3t2 separated by '|'.
        ELSEIF l_tax = 'XX'.
          IF pa_bukrs EQ '8070'.
            zfvatxx-zstatus = '13'.
            MOVE wa_itab1-xref3 TO va_xref3xx.
          ENDIF.
        ENDIF.

        PERFORM f_insert_xx ON COMMIT.

        IF wa_itab1-shkzg = 'H'.
          wa_itab1-dmbtr = wa_itab1-dmbtr * -1.
        ENDIF.
        tot_dmbtr = tot_dmbtr + wa_itab1-dmbtr.
        va_xref3 = wa_itab1-xref3.

        PERFORM f_write_detail.
        HIDE: wa_itab1-belnr.
        c1 = 1.
        CLEAR wa_itab1.
      ENDLOOP.

      grand_dmbtr = grand_dmbtr + tot_dmbtr.
      va_hkont1 =  c_hkont_210.
      va_hkont2 =  c_hkont_200.
      PERFORM f_write_total.
      va_post = 'XX'.
      IF tot_dmbtr < 0.
        tot_dmbtr  = tot_dmbtr  * -1.
        va_bschl = '50'.
      ELSE.
        va_bschl = '40'.
      ENDIF.
      PERFORM f_post_f04.
      CLEAR va_post.
    ENDIF.
  ENDIF.
*      perform f_post_to_gl_a1.
******************* End collect
*    call transaction 'SM30'.

ENDFORM.                    " f_input_Data_A3



*************************************************************
FORM f_dynpro USING dynbegin name value.
*************************************************************
  IF dynbegin =  'X'.
    CLEAR:  wa_bdc.
    MOVE: name  TO wa_bdc-program,
          value TO wa_bdc-dynpro ,
          'X'   TO wa_bdc-dynbegin.
    APPEND wa_bdc TO i_bdc.
  ELSE.
    CLEAR:  wa_bdc.
    MOVE: name    TO wa_bdc-fnam,
          value   TO wa_bdc-fval.
    APPEND wa_bdc TO i_bdc.
  ENDIF.
ENDFORM.                               " F_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  f_post_to_gl_a1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_to_gl_a1.
  DATA:  l_value(15),
        l_date(10),
        l_mess(50),
        l_monat(2),
        l_year(4),
        l_answer,
        l_text LIKE sy-datum,
        text LIKE spop-varvalue1.
  l_answer = 'N'.
  WHILE l_answer NE 'J'.
    CALL FUNCTION 'POPUP_TO_GET_ONE_VALUE'
      EXPORTING
        textline1   = 'Entry Posting Date ?'
        textline2   = 'Entry YYYYMMDD'
        titel       = 'Posting Date'
        valuelength = 10
      IMPORTING
        answer      = l_answer
        value1      = text
      EXCEPTIONS
        OTHERS      = 1.
    IF l_answer = 'J'.
      WRITE text TO l_text.
    ENDIF.
    CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
      EXPORTING
        date = l_text.
    IF sy-subrc NE 0.
      l_answer = 'A'.
    ENDIF.
  ENDWHILE.
  WRITE pa_monat TO l_monat.
  IF l_monat EQ 0.
    WRITE sy-datum+4(2) TO l_monat.
  ENDIF.
  WRITE pa_gjahr TO l_year.
  IF l_year EQ 0.
    WRITE sy-datum+0(4) TO l_year.
  ENDIF.
  tot_dmbtr = 1000.
  CONCATENATE 'FORM A1/A3' l_monat l_year INTO l_mess
         SEPARATED BY space.
  l_value = tot_dmbtr.
  WRITE l_text TO l_date.
  CLEAR i_bdc.
  PERFORM f_dynpro USING:
        'X'  'SAPMF05A'     '0122',
        ' '  'BDC_OKCODE'    '=SL',
        ' '  'BKPF-BLDAT'   l_date,
        ' '  'BKPF-BUDAT'   l_date,
        ' '  'BKPF-XBLNR'   l_mess,
        ' '  'BKPF-BLART'   'SA',
        ' '  'BKPF-BUKRS'   pa_bukrs,
        ' '  'BKPF-WAERS'   'IDR',
        ' '  'BKPF-BKTXT'   ' ',
        ' '  'RF05A-AUGTX'  l_mess,
        ' '  'RF05A-NEWBS'  '50',
        ' '  'RF05A-NEWKO'  '0315300210',

        'X'  'SAPMF05A'     '0300',
        ' '  'BDC_OKCODE'    '=SL',
        ' '  'BSEG-WRBTR'   l_value,
        ' '  'BSEG-ZFBDT'   l_date,
*         ' '  'BSEG-ZUONR'   '1234567',
        ' '  'BSEG-SGTXT'   l_mess,
       ' '  'BDC_OKCODE'   '/6',

        ' '  'SAPLKACB'     '0002',
        ' '  'BDC_OKCODE'   '=ENTE',
        ' '  'COBL-GSBER'   pa_gsber,

        'X'  'SAPMF05A'     '0710',
        ' '  'BDC_OKCODE'   '/5',
        ' '  'RFO5A-AGBUK'  pa_bukrs,
        ' '  'RF05A-AGKON'  '0315300200',
        ' '  'RF05A-AGKOA'     'S',
        ' '  'RF05A-XAUTS'     'X',
*         ' '  'RF05A-XNOPS'  'X',
        ' '  'RF05A-XPOS1(01)'  ' ',
        ' '  'RF05A-XPOS1(04)'  'X'.

  ta_date-sign   = 'I'.
  ta_date-option = 'BT'.
  CONCATENATE pa_gjahr pa_monat '01' INTO ta_date-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ta_date-low
    IMPORTING
      last_day_of_month = ta_date-high.
  APPEND ta_date.
  WRITE ta_date-low TO l_date.
  PERFORM f_dynpro USING:
        'X'  'SAPMF05A'         '0732',
        ' '  'BDC_OKCODE'       '=SLK',
        ' '  'RF05A-FELDN(1)'   'Posting Date',
        ' '  'RF05A-VONDT(1)'   l_date.

  WRITE ta_date-high TO l_date.
  PERFORM f_dynpro USING:
        ' '  'RF05A-VONDT(1)'   l_date,
        ' '  'BDC_OKCODE'       '/11',
        'X'  'SAPMF05A'         '0710',
        ' '  'BDC_OKCODE'       '=BU'.

****** Put BDC in here

  CALL TRANSACTION 'F-04' USING i_bdc MODE 'A' UPDATE 'S'
                     MESSAGES INTO i_messtab.
* MODE       = 'N'.    "Running BackGroud
* MODE       = 'A'.    "Running Fore Groud
  IF sy-subrc NE 0.
    READ TABLE i_messtab INTO wa_messtab INDEX 1.
    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        id   = wa_messtab-msgid
        lang = wa_messtab-msgspra
        no   = wa_messtab-msgnr
        v1   = wa_messtab-msgv1
        v2   = wa_messtab-msgv2
        v3   = wa_messtab-msgv3
        v4   = wa_messtab-msgv4
      IMPORTING
        msg  = msg.
    WRITE: / 'Message Error : ', msg.
    MESSAGE e001(zs) WITH msg.
  ENDIF.
ENDFORM.                    " f_post_to_gl_a1


*&---------------------------------------------------------------------*
*&      Form  f_post_f04
*&---------------------------------------------------------------------*
FORM f_post_f04.
  DATA: l_value(15),
        l_date(10),
        l_date1(10),
        l_mess(50),
        l_mess1(50),
        l_monat(2),
        l_year(4),
        l_answer,
        l_text(20),
        va_ctr(2),
        text LIKE spop-varvalue1. " sy-datum.
  l_answer = 'N'.
  break tds_dev01.
*   va_hkont1 = c_hkont_220.
*   va_hkont2 = c_hkont_210.
  WRITE pa_monat TO l_monat.
  IF l_monat EQ 0.
    WRITE sy-datum+4(2) TO l_monat.
  ENDIF.

  WRITE pa_gjahr TO l_year.
  IF l_year EQ 0.
    WRITE sy-datum+0(4) TO l_year.
  ENDIF.

  WRITE pa_post TO l_date.
  WRITE tot_dmbtr TO l_value DECIMALS 0 CURRENCY 'IDR' NO-GAP.

  IF va_post = 'A1' OR va_post = 'A3'.
    CONCATENATE 'FORM A1/A3' l_monat l_year INTO l_mess
         SEPARATED BY space.
    l_mess1 = l_mess.
  ELSE.
    CONCATENATE 'FORM A2' l_monat l_year INTO l_mess
         SEPARATED BY space.
    CONCATENATE wa_itab1-zuonr l_mess INTO l_mess1
         SEPARATED BY space.
  ENDIF.

  IF pa_bukrs EQ '8070'.
    IF va_post = 'XX'.
      CONCATENATE 'FORM XX' l_monat l_year INTO l_mess
           SEPARATED BY space.
      l_mess1 = l_mess.
    ENDIF.
  ENDIF.

  CLEAR i_bdc.
  REFRESH i_bdc.
  PERFORM f_dynpro USING:
        'X'  'SAPMF05A'     '0122',
        ' '  'BDC_OKCODE'    '=SL',
        ' '  'BKPF-BLDAT'   l_date,
        ' '  'BKPF-BUDAT'   l_date,
        ' '  'BKPF-XBLNR'   wa_itab1-belnr,
        ' '  'BKPF-BLART'   'SA',
        ' '  'BKPF-MONAT'   l_monat,
        ' '  'BKPF-BUKRS'   pa_bukrs,
        ' '  'BKPF-WAERS'   'IDR',
*         ' '  'BKPF-XBLNR'   l_mess,
        ' '  'RF05A-AUGTX'  'VAT - Output Post to GL',
        ' '  'RF05A-NEWBS'  va_bschl,
        ' '  'RF05A-NEWKO'  va_hkont1,

        'X'  'SAPMF05A'     '0300',
        ' '  'BDC_OKCODE'    '=SL',
        ' '  'BSEG-WRBTR'   l_value,
        ' '  'BSEG-ZUONR'   l_mess,
        ' '  'BSEG-SGTXT'   l_mess1,
        ' '  'BDC_OKCODE'   '=ZK',

        'X'  'SAPLKACB'     '0002',
        ' '  'BDC_OKCODE'   '=ENTE',
        ' '  'COBL-GSBER'   pa_gsber,

        'X'  'SAPMF05A'     '0330',
        ' '  'BDC_OKCODE'   '/00',
        ' '  'BSEG-XREF3'   va_xref3,
        ' '  'BDC_OKCODE'   '=PA'.

  IF va_post = 'A1' OR va_post = 'A3'.
    PERFORM f_dynpro USING:
      'X'  'SAPMF05A'     '0710',
      ' '  'BDC_OKCODE'   '=PA',
      ' '  'RF05A-AGBUK'  pa_bukrs,
      ' '  'RF05A-AGKON'  va_hkont2,  "'0142200200',
      ' '  'RF05A-AGKOA'     'S',
*         ' '  'RF05A-XAUTS'     'X',
      ' '  'RF05A-XPOS1(01)'  ' ',
      ' '  'RF05A-XPOS1(12)'  'X',
      'X'  'SAPMF05A'         '0731',
      ' '  'BDC_OKCODE'       '=PA'.
  ELSEIF va_post = 'XX'.
    IF pa_bukrs EQ '8070'.
      PERFORM f_dynpro USING:
        'X'  'SAPMF05A'     '0710',
        ' '  'BDC_OKCODE'   '=PA',
        ' '  'RF05A-AGBUK'  pa_bukrs,
        ' '  'RF05A-AGKON'  va_hkont2,  "'0142200200',
        ' '  'RF05A-AGKOA'     'S',
*         ' '  'RF05A-XAUTS'     'X',
        ' '  'RF05A-XPOS1(01)'  ' ',
        ' '  'RF05A-XPOS1(12)'  'X',
        'X'  'SAPMF05A'         '0731',
        ' '  'BDC_OKCODE'       '=PA'.
    ENDIF.
  ENDIF.

  IF va_post = 'A1'.
    PERFORM f_dynpro USING:
        ' '  'RF05A-SEL01(01)'  va_xref3t0,
        ' '  'RF05A-SEL01(02)'  va_xref3t1,
        ' '  'RF05A-SEL01(03)'  va_xref3t2,
        'X'  'SAPDF05X'         '3100',
        ' '  'BDC_OKCODE'       '=BU'.
  ELSEIF va_post = 'A2'.
    PERFORM f_dynpro USING:
          'X'  'SAPMF05A'     '0710',
          ' '  'BDC_OKCODE'   '/5',
          ' '  'RF05A-AGBUK'  pa_bukrs,
          ' '  'RF05A-AGKON'  va_hkont2,
          ' '  'RF05A-AGKOA'     'S',
          ' '  'RF05A-XAUTS'     'X',
          ' '  'RF05A-XPOS1(01)'  ' ',
          ' '  'RF05A-XPOS1(02)'  'X',

          'X'  'SAPMF05A'       '0733',
          ' '  'RF05A-FELDN(1)' 'BELNR',
          ' '  'RF05A-SEL01(1)' wa_itab1-belnr,
          ' '  'BDC_OKCODE'     '=BU'.

*           ' '  'RF05A-SEL01(01)'  va_xref3t0,
*           ' '  'RF05A-SEL01(02)'  va_xref3t1,
*           'X'  'SAPDF05X'         '3100',
*           ' '  'BDC_OKCODE'       '=BU'.
  ELSEIF va_post = 'A3'.
    PERFORM f_dynpro USING:
        ' '  'RF05A-SEL01(01)'  va_xref3,
        ' '  'RF05A-SEL01(02)'  va_xref4,
        'X'  'SAPDF05X'         '3100',
        ' '  'BDC_OKCODE'       '=BU'.
  ELSEIF va_post = 'XX'.
    IF pa_bukrs EQ '8070'.
      PERFORM f_dynpro USING:
          ' '  'RF05A-SEL01(01)'  va_xref3xx,
          'X'  'SAPDF05X'         '3100',
          ' '  'BDC_OKCODE'       '=BU'.
    ENDIF.
  ENDIF.

  CALL TRANSACTION 'F-04' USING i_bdc MODE va_mode UPDATE 'S'
                     MESSAGES INTO i_messtab.
  IF sy-subrc NE 0.
    READ TABLE i_messtab INTO wa_messtab INDEX 1.
    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        id   = wa_messtab-msgid
        lang = wa_messtab-msgspra
        no   = wa_messtab-msgnr
        v1   = wa_messtab-msgv1
        v2   = wa_messtab-msgv2
        v3   = wa_messtab-msgv3
        v4   = wa_messtab-msgv4
      IMPORTING
        msg  = wa_log_error-msg.

    wa_log_error-hkont =   va_hkont2.
    wa_log_error-bukrs = pa_bukrs.
    wa_log_error-gjahr = wa_itab1-gjahr.
    wa_log_error-belnr = wa_itab1-belnr.
    APPEND wa_log_error TO i_log_error.

    IF va_post = 'A1'.
      CLEAR wa_itab1.
      LOOP AT i_itab1a1 INTO wa_itab1.
        DELETE  FROM  zfvata1
               WHERE bukrs EQ wa_itab1-bukrs AND
                     gsber EQ wa_itab1-gsber AND
                     gjahr EQ wa_itab1-gjahr AND
                     monat EQ pa_monat       AND
                     txdat EQ wa_itab1-zfbdt AND
                     tbeln EQ wa_itab1-zuonr.
        CLEAR wa_itab1.
      ENDLOOP.
    ELSEIF va_post = 'A2'.
*         Clear wa_itab1.
*         Loop at i_itab1a2 into wa_itab1.
      DELETE  FROM  zfvata2
             WHERE bukrs EQ wa_itab1-bukrs AND
                   gsber EQ wa_itab1-gsber AND
                   gjahr EQ wa_itab1-gjahr AND
                   monat EQ pa_monat       AND
                   txdat EQ wa_itab1-zfbdt AND
                   tbeln EQ wa_itab1-zuonr.
      CLEAR wa_itab1.
*          Endloop.
    ELSEIF va_post = 'A3'.
      CLEAR wa_itab1.
      LOOP AT i_itab1a3 INTO wa_itab1.
        DELETE  FROM  zfvata3
               WHERE bukrs EQ wa_itab1-bukrs AND
                     gsber EQ wa_itab1-gsber AND
                     gjahr EQ wa_itab1-gjahr AND
                     monat EQ pa_monat       AND
                     txdat EQ wa_itab1-zfbdt AND
                     tbeln EQ wa_itab1-zuonr.
        CLEAR wa_itab.
      ENDLOOP.
    ENDIF.
    ROLLBACK WORK.
  ELSE.
    COMMIT WORK AND WAIT.
  ENDIF.
ENDFORM.                    " f_post_f04

*&---------------------------------------------------------------------*
*&      Form  f_init_column
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_column.
  w1   =   5.      w11 = 15.      w21 = 12.      w31 = 10.
  w2   =  10.      w12 = 15.      w22 = 10.      w32 = 12.
  w3   =   5.      w13 = 12.      w23 = 10.      w33 = 12.
  w4   =  12.      w14 = 10.      w24 = 12.      w34 = 10.
  w5   =  20.      w15 = 10.      w25 = 12.      w35 = 10.
  w6   =  30.      w16 = 12.      w26 = 10.
  w7   =  20.      w17 = 12.      w27 = 10.      w19a = 12.
  w8   =  16.      w18 = 10.      w28 = 12.
  w9   =  25.      w19 = 10.      w29 = 12.
  w10  =  15.      w20 = 12.      w30 = 10.
  c1 = 0.

ENDFORM.                    " f_init_column
*&---------------------------------------------------------------------*
*&      Form  f_write_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_detail.
  c1 = 1.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  WRITE AT c1(w1) wa_itab1-bukrs NO-GAP. c1 = c1 + w1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w2) wa_itab1-gsber NO-GAP. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_itab1-gjahr NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w4) wa_itab1-zfbdt NO-GAP. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w5) wa_itab1-zuonr NO-GAP. c1 = c1 + w5.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w10) wa_itab1-belnr NO-GAP. c1 = c1 + w10.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w9) wa_itab1-dmbtr CURRENCY 'IDR'
                   DECIMALS 0 NO-GAP.
  c1 = c1 + w9.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w6) wa_itab1-sgtxt NO-GAP. c1 = c1 + w6.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w7) wa_itab1-bktxt NO-GAP. c1 = c1 + w7.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

ENDFORM.                    " f_write_detail
*&---------------------------------------------------------------------*
*&      Form  f_write_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_header.
*          new-page.
  SKIP 1.
  WRITE: AT 2(c1) va_title CENTERED.
  WRITE: / sy-uline.
  c1 = 1.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  WRITE AT c1(w1) 'Company' NO-GAP CENTERED. c1 = c1 + w1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w2) 'Buss. Area' NO-GAP CENTERED. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'Fiscal Year' NO-GAP CENTERED. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w4) 'Due Date' NO-GAP CENTERED. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w5) 'Tax Id' CENTERED NO-GAP. c1 = c1 + w5.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w10)  'Document No.' NO-GAP. c1 = c1 + w10.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w9) 'Nilai Pajak' NO-GAP. c1 = c1 + w9.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w6) 'Nama Customer' NO-GAP. c1 = c1 + w6.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w7) 'NPWP Customer' NO-GAP. c1 = c1 + w7.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 1.
  WRITE: / sy-uline.

ENDFORM.                    " f_write_header
*&---------------------------------------------------------------------*
*&      Form  f_write_total
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_total.
  WRITE: / sy-uline.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  c1 = c1 + w1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w4.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w5.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w10.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w9) grand_dmbtr DECIMALS 0 CURRENCY 'IDR' NO-GAP.
  c1 = c1 + w9.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w6.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w7.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE: / sy-uline.
  SKIP 3.
ENDFORM.                    " f_write_total
*&---------------------------------------------------------------------*
*&      Form  f_download_a1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download_a1.
  PERFORM get_data_a1.
*    MOVE '1' TO VA_KDLAMP.
  IF pa_bukrs EQ '8010'.
    PERFORM download_a1_8010.
  ELSE.
    IF pa_gjahr GT 2006.
      PERFORM download_a1_new.
    ELSE.
      PERFORM download_a1.
    ENDIF.
  ENDIF.

ENDFORM.                    " f_download_a1

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_A1
*&---------------------------------------------------------------------*
FORM get_data_a1.
  SELECT * FROM zfvata1
    INTO CORRESPONDING FIELDS OF TABLE id_itaba1
    WHERE bukrs EQ pa_bukrs AND
          gsber EQ pa_gsber AND
          gjahr EQ pa_gjahr AND
          monat EQ pa_monat.
ENDFORM.                    " GET_DATA_A1

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_A1
*&---------------------------------------------------------------------*
FORM download_a1.
  DATA: l_text(7),
        l_text1(7),
        l_stat(2),
        l_stat1(2).

  DATA: l_npwp LIKE zfvatb1-stceg,
        l_nofak(10).

  CLEAR: wd_itaba1, i_itab.
  LOOP AT id_itaba1 INTO wd_itaba1.
    MOVE wd_itaba1-zstatus TO l_stat.
    MOVE l_stat(1) TO va_kdlamp.

    SELECT SINGLE zstatus1
      FROM zfpajak
      INTO l_stat1
      WHERE bukrs EQ pa_bukrs AND
            zstatus EQ wd_itaba1-zstatus.

    MOVE l_stat1+1(1) TO va_kddocu.

    CASE wd_itaba1-zstatus.
      WHEN '11'.
*        MOVE '1' TO VA_KDSTAT.
        MOVE l_stat+1(1) TO va_kdstat.
        WRITE '00.000.000.0.000.000' TO l_npwp LEFT-JUSTIFIED.
      WHEN '12'.
*        MOVE '2' TO VA_KDSTAT.
        MOVE l_stat+1(1) TO va_kdstat.
        MOVE  wd_itaba1-stceg TO l_npwp.
      WHEN '13'.
*        MOVE '3' TO VA_KDSTAT.
        MOVE l_stat+1(1) TO va_kdstat.
        MOVE  wd_itaba1-stceg TO l_npwp.
      WHEN '17'.
*        MOVE '3' TO VA_KDSTAT.
        MOVE '3' TO va_kdstat.
        MOVE  wd_itaba1-stceg TO l_npwp.
    ENDCASE.

    MOVE  wd_itaba1-name1 TO va_nmwp.
*    MOVE '1' TO VA_KDDOCU.
    CLEAR l_text.
    WRITE wd_itaba1-tbeln+10(8) TO l_text.
    v_len = STRLEN( l_text ).
    v_space = 7 - v_len.
    DO v_space TIMES.
      CONCATENATE '0' l_text INTO l_text.
    ENDDO.
*    write l_text to VA_NOFKTR RIGHT-JUSTIFIED.
    CONCATENATE wd_itaba1-txdat+6(2)
                wd_itaba1-txdat+4(2)
                wd_itaba1-txdat+0(4)
          INTO va_tglfkt SEPARATED BY '/'.
*    WRITE WD_ITABA1-TXDAT TO VA_TGLFKT DD/MM/YYYY.
    wd_itaba1-dmbtr = wd_itaba1-dmbtr * 100.
    WRITE space TO va_nilppnbm RIGHT-JUSTIFIED.
    WRITE pa_betul TO va_betul LEFT-JUSTIFIED.

* PERUBAHAN NPWP U/ TSP
    IF pa_bukrs EQ '8010'.
      CONCATENATE l_npwp+0(2) l_npwp+3(3) l_npwp+7(3) l_npwp+11(1)
                  l_npwp+13(3) l_npwp+17(3)
      INTO va_npwp.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = l_npwp
        IMPORTING
          npwp_out = va_npwp.
    ENDIF.

* KONDISI U/ CN
    IF wd_itaba1-dmbtr < 0.
      v_len = STRLEN( wd_itaba1-tbeln ) - 7.
      WRITE wd_itaba1-tbeln+v_len(7) TO l_text1 RIGHT-JUSTIFIED.
    ELSE.
      CONCATENATE l_npwp+13(3) l_text INTO l_nofak.
      WRITE l_nofak  TO va_nofktr RIGHT-JUSTIFIED.
    ENDIF.

    IF wd_itaba1-shkzg EQ 'S'.
      MOVE '4' TO va_kddocu.
      IF pa_bukrs EQ '8010'.
        WRITE wd_itaba1-tbeln TO l_nofak.
        WRITE l_nofak TO va_nofktr RIGHT-JUSTIFIED.
        va_kdfktr = space.
      ELSE.
        wa_itabt-kdfktr = space.
        wa_itabt-kdkpp  = space.
        wa_itabt-nofktr = wd_itaba1-tbeln.
      ENDIF.
      WRITE wd_itaba1-dmbtr TO va_nilppn DECIMALS 0 NO-GROUPING.
      SHIFT va_nilppn LEFT DELETING LEADING space.
      CONCATENATE '-' va_nilppn INTO va_nilppn.
      IF pa_bukrs EQ '8010'.
        WRITE  va_nilppn       TO wa_itab-nilppn RIGHT-JUSTIFIED.
      ELSE.
        WRITE  va_nilppn       TO wa_itabt-nilppn RIGHT-JUSTIFIED.
      ENDIF.
    ELSE.
      IF pa_bukrs EQ '8010'.
        MOVE wd_itaba1-tbeln+0(5) TO va_kdfktr.
      ELSE.
        MOVE  wd_itaba1-tbeln(5) TO wa_itabt-kdfktr.
        MOVE  wd_itaba1-tbeln+6(3) TO wa_itabt-kdkpp.
        MOVE  wd_itaba1-tbeln+10(7) TO wa_itabt-nofktr.
      ENDIF.
      WRITE wd_itaba1-dmbtr TO va_nilppn RIGHT-JUSTIFIED
      DECIMALS 0 NO-GROUPING.
      IF pa_bukrs EQ '8010'.
        WRITE va_nilppn       TO wa_itab-nilppn RIGHT-JUSTIFIED.
      ELSE.
        WRITE va_nilppn       TO wa_itabt-nilppn RIGHT-JUSTIFIED.
      ENDIF.
    ENDIF.

* KODE FAKTUR & NO FAKTUR UNTUK FAKTUR PAJAK SEDERHANA
    IF wd_itaba1-zstatus EQ '11'.
      IF pa_bukrs EQ '8010'.
        WRITE '00000' TO va_kdfktr.
        WRITE '   0000000' TO va_nofktr RIGHT-JUSTIFIED.
      ELSE.
        MOVE space TO wa_itabt-kdfktr.
        MOVE space TO wa_itabt-kdkpp.
        WRITE wd_itaba1-tbeln TO wa_itabt-nofktr.
      ENDIF.
    ENDIF.

    IF pa_bukrs EQ '8010'.
      MOVE  wd_itaba1-gjahr TO wa_itab-thnpjk.
      MOVE  wd_itaba1-monat TO wa_itab-blnpjk.
      MOVE  va_betul        TO wa_itab-pembtl.
      MOVE  va_kdlamp       TO wa_itab-kdlamp.
      MOVE  va_kdstat       TO wa_itab-kdstat.
      MOVE  va_nmwp         TO wa_itab-nmwp.
      MOVE  va_kddocu       TO wa_itab-kddocu.
      MOVE  va_kdfktr       TO wa_itab-kdfktr.
      MOVE  space           TO wa_itab-noref.
      MOVE  va_nofktr       TO wa_itab-nofktr.
      WRITE va_tglfkt       TO wa_itab-tglfkt.
      MOVE  '10/100'        TO wa_itab-tarif.
      MOVE  va_nilppnbm     TO wa_itab-nilppnbm.

      IF wd_itaba1-zstatus EQ '11' OR
         wd_itaba1-zstatus EQ '12' OR
         wd_itaba1-zstatus EQ '13' OR
         wd_itaba1-zstatus EQ '17'.
        APPEND wa_itab TO i_itab.
      ENDIF.
    ELSE.
      MOVE  wd_itaba1-gjahr TO wa_itabt-thnpjk.
      MOVE  wd_itaba1-monat TO wa_itabt-blnpjk.
      MOVE  va_betul        TO wa_itabt-pembtl.
      MOVE  va_kdlamp       TO wa_itabt-kdlamp.
      MOVE  va_kdstat       TO wa_itabt-kdstat.
      MOVE  va_npwp         TO wa_itabt-npwp.
      MOVE  va_nmwp         TO wa_itabt-nmwp.
      MOVE  va_kddocu       TO wa_itabt-kddocu.
      WRITE va_tglfkt       TO wa_itabt-tglfkt.
      MOVE  va_nilppnbm     TO wa_itabt-nilppnbm.

      IF wd_itaba1-zstatus EQ '11' OR
         wd_itaba1-zstatus EQ '12' OR
         wd_itaba1-zstatus EQ '13' OR
         wd_itaba1-zstatus EQ '17'.
        APPEND wa_itabt TO i_itabt.
      ENDIF.
    ENDIF.

    CLEAR: l_stat, l_stat1.
    CLEAR: wd_itaba1, va_kdstat, va_npwp, va_nmwp,
           va_nofktr, va_tglfkt, va_nilppn.
  ENDLOOP.

  IF pa_bukrs EQ '8010'.
    DESCRIBE TABLE i_itab LINES cntr.
  ELSE.
    DESCRIBE TABLE i_itabt LINES cntr.
  ENDIF.

  IF cntr NE 0.
    PERFORM validasi.
    IF error <> 0.
      PERFORM cetak_error.
    ELSE.
      PERFORM f_download_pc_a1.
    ENDIF.
  ELSE.
    MESSAGE i000(zf) WITH 'Data Not Found'.
  ENDIF.
  CLEAR: cntr.
ENDFORM.                    " DOWNLOAD_A1

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_A1_NEW
*&---------------------------------------------------------------------*
FORM download_a1_new.

  DATA: ld_vatpr LIKE zfvato-vatpr,
        ld_vatno LIKE zfvato-vatno,
        ld_dudat LIKE zfvato-dudat,
        ld_dueyr LIKE zfvato-dueyr,
        ld_duemm LIKE zfvato-duemm,
        ld_sspdt LIKE zfvato-sspdt,
        ld_netwr LIKE zfvato-netwr,
        ld_nonr  LIKE zfppnnrd-nonr,
        fname(128).

  DELETE id_itaba1 WHERE zstatus NE '13'.

  CLEAR: wd_itaba1,i_espt.
  LOOP AT id_itaba1 INTO wd_itaba1.

    CLEAR: ld_vatpr,ld_dudat,ld_dueyr,ld_duemm,ld_sspdt,ld_netwr,
           ld_vatno.

    CLEAR: wa_espt-kodepjk,wa_espt-kodelam,wa_espt-kodests,
           wa_espt-kodedok,wa_espt-npwp,wa_espt-nama,wa_espt-kodecab,
           wa_espt-kodethn,wa_espt-nofkt,wa_espt-tglfkt,wa_espt-tglssp,
           wa_espt-masapjk,wa_espt-thnpjk,wa_espt-betul,wa_espt-dpp,
           wa_espt-ppn,wa_espt-ppnbm.

    IF wd_itaba1-stceg IS INITIAL.
      CONTINUE.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = wd_itaba1-stceg
        IMPORTING
          npwp_out = wd_itaba1-stceg.
    ENDIF.

    wa_espt-kodedok = '1'.
    wa_espt-kodecab = wd_itaba1-tbeln+3(3).
    wa_espt-kodethn = wd_itaba1-gjahr+2(2).
    wa_espt-nofkt   = wd_itaba1-tbeln+8(8).

*    SELECT single vatpr dudat dueyr duemm sspdt netwr
*      INTO (ld_vatpr,ld_dudat,ld_dueyr,ld_duemm,ld_sspdt,ld_netwr)
*      FROM ZFVATO
*      WHERE vkorg = Wd_ITABA1-bukrs and
*            vkbur between '0201' and '0299' and
*            vatno = ld_vatno        and
*            dueyr = Wd_ITABA1-gjahr and
*            duemm = Wd_ITABA1-monat and
*            gsber = Wd_ITABA1-gsber and
*            vtart = 'SD'            and
*            flag1 ne 'K'.
*    IF sy-subrc NE 0.
    IF wd_itaba1-shkzg EQ 'S'.
      SELECT SINGLE nonr nrdt gjahr monat dppcn
        INTO (ld_nonr, ld_dudat,ld_dueyr,ld_duemm,ld_netwr)
        FROM zfppnnrd
        WHERE bukrs = wd_itaba1-bukrs AND
              vkbur BETWEEN '0201' AND '0299' AND
              belnr = wd_itaba1-tbeln.
      IF sy-subrc NE 0.
        CONTINUE.
      ELSE.
        wa_espt-kodedok = '2'.
        wa_espt-kodecab = space.
        wa_espt-kodethn = space.
        wa_espt-nofkt   = ld_nonr.
        wd_itaba1-dmbtr = wd_itaba1-dmbtr * -1.
      ENDIF.
    ENDIF.
*    ENDIF.

*    ld_vatno = Wd_ITABA1-TBELN+8(8).

    wa_espt-kodepjk = 'A'.
    wa_espt-kodelam = '2'.
    wa_espt-kodests = wd_itaba1-tbeln+1(1).
    IF wa_espt-kodests EQ '0'.
      wa_espt-kodests = '1'.
    ENDIF.
    wa_espt-npwp    = wd_itaba1-stceg.
    wa_espt-nama    = wd_itaba1-name1.
    REPLACE ';' WITH space INTO wa_espt-nama.
    wa_espt-masapjk = wd_itaba1-monat.
    wa_espt-thnpjk  = wd_itaba1-gjahr.
    wa_espt-betul   = '0'.
*    wa_espt-betul   = Wd_ITABA1-tbeln+2(1).

*    if ld_netwr is initial.
*      wa_espt-dpp = '0'.
*    else.
*      ld_netwr = ld_netwr * 100.
*      write ld_netwr to wa_espt-dpp
**                     using edit mask '- _____________'
*                     decimals 0.
*    endif.

    IF wd_itaba1-dmbtr LT 0.
      ld_netwr = wd_itaba1-dmbtr * 1000.
      WRITE ld_netwr TO wa_espt-dpp
                     USING EDIT MASK '- _____________'
                     DECIMALS 0.

      IF wd_itaba1-dmbtr IS INITIAL.
        wa_espt-ppn = '0'.
      ELSE.
        wd_itaba1-dmbtr = wd_itaba1-dmbtr * 100.
        WRITE wd_itaba1-dmbtr TO wa_espt-ppn
                            USING EDIT MASK '- _____________'
                            DECIMALS 0.
      ENDIF.
    ELSE.
      ld_netwr = wd_itaba1-dmbtr * 1000.
      WRITE ld_netwr TO wa_espt-dpp
                     DECIMALS 0.

      IF wd_itaba1-dmbtr IS INITIAL.
        wa_espt-ppn = '0'.
      ELSE.
        wd_itaba1-dmbtr = wd_itaba1-dmbtr * 100.
        WRITE wd_itaba1-dmbtr TO wa_espt-ppn
                            DECIMALS 0.
      ENDIF.
    ENDIF.

    DO 3 TIMES.
      REPLACE '.' WITH space INTO wa_espt-ppn.
      CONDENSE wa_espt-ppn NO-GAPS.
      REPLACE '.' WITH space INTO wa_espt-dpp.
      CONDENSE wa_espt-dpp NO-GAPS.
    ENDDO.

    wa_espt-ppnbm   = '0'.

    IF NOT wd_itaba1-txdat IS INITIAL.
      WRITE wd_itaba1-txdat TO wa_espt-tglfkt
                            USING EDIT MASK '__/__/____'.
    ENDIF.

    IF NOT ld_sspdt IS INITIAL.
      WRITE ld_sspdt TO wa_espt-tglssp
                     USING EDIT MASK '__/__/____'.
    ENDIF.

    i_espt-data = wa_espt.
    CONDENSE i_espt-data NO-GAPS.

    APPEND i_espt. CLEAR: i_espt.

  ENDLOOP.

  CLEAR i_espt.
  INSERT i_espt INDEX 1.

  DESCRIBE TABLE i_espt LINES cntr.
  IF cntr = 0.
    MESSAGE i000(zf) WITH 'Data Not Found'.
    STOP.
  ENDIF.

  IF error <> 0.
    PERFORM cetak_error.
  ELSE.
    CONCATENATE 'C:\FILEA1_' pa_bukrs '_' pa_monat '.TXT' INTO fname.

*Begin remark Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
*    CALL FUNCTION 'DOWNLOAD'
*      EXPORTING
*        filename         = fname
*      IMPORTING
*        cancel           = canc
*        filesize         = size
*      TABLES
*        data_tab         = i_espt
*      EXCEPTIONS
*        file_open_error  = 1
*        file_write_error = 2.
*
*    IF canc = 'x'.
*      MESSAGE i000(zf) WITH 'Download Cancel by User'.
*    ENDIF.
*
*    IF size NE '0'.
*      MESSAGE i000(zf) WITH 'Download Success'.
*    ENDIF.
*End remark Unicode conversion - DEVK965554

*Begin insert Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
    DATA: lv_filename TYPE string.
    CLEAR lv_filename.
    lv_filename = fname.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_filename
*      FILETYPE                = 'DBF'
*      FIELDNAMES              = dwn_field
      CHANGING
        data_tab                = i_espt[]
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
*End insert Unicode conversion - DEVK965554

  ENDIF.

ENDFORM.                    " DOWNLOAD_A1_NEW

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_PC_A1
*&---------------------------------------------------------------------*
FORM f_download_pc_a1.
  DATA: fname(128).

*Begin remark Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
*  IF pa_bukrs EQ '8010'.
*    CALL FUNCTION 'DOWNLOAD'
*      EXPORTING
*        filename         = 'C:\FILEA1.DAT'
*      IMPORTING
*        cancel           = canc
*        filesize         = size
*      TABLES
*        data_tab         = i_itab
*      EXCEPTIONS
*        file_open_error  = 1
*        file_write_error = 2.
*  ELSE.
*    CONCATENATE 'C:\FILEA1_' pa_bukrs '_' pa_monat '.DAT'
*      INTO fname.
*    CALL FUNCTION 'DOWNLOAD'
*      EXPORTING
*        filename         = fname
*      IMPORTING
*        cancel           = canc
*        filesize         = size
*      TABLES
*        data_tab         = i_itabt
*      EXCEPTIONS
*        file_open_error  = 1
*        file_write_error = 2.
*  ENDIF.
*
*  IF canc = 'x'.
*    MESSAGE i000(zf) WITH 'Download Cancel by User'.
*  ENDIF.
*
*  IF size NE '0'.
*    MESSAGE i000(zf) WITH 'Download Success'.
*  ENDIF.
*End remark Unicode conversion - DEVK965554

*Begin insert Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
  DATA: lv_filename TYPE string.
  IF pa_bukrs EQ '8010'.
    CLEAR lv_filename.
    lv_filename = 'C:\FILEA1.DAT'.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_filename
        filetype                = 'DAT'
*        FIELDNAMES              = dwn_field
      CHANGING
        data_tab                = i_itab[]
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.
  ELSE.
    CLEAR lv_filename.
    CONCATENATE 'C:\FILEA1_' pa_bukrs '_' pa_monat '.DAT'
          INTO lv_filename.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_filename
        filetype                = 'DAT'
*        FIELDNAMES              = dwn_field
      CHANGING
        data_tab                = i_itabt[]
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.
  ENDIF.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*End insert Unicode conversion - DEVK965554

ENDFORM.                    " F_DOWNLOAD_PC_A1
*&---------------------------------------------------------------------*
*&      Form  f_download_a3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download_a3.
  PERFORM get_data_a3.
*      MOVE '3' TO VA_KDLAMP.
  IF pa_bukrs EQ '8010'.
    PERFORM download_a3_8010.
  ELSE.
    IF pa_gjahr GT 2006.
      PERFORM download_a3_new.
    ELSE.
      PERFORM download_a3.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_download_a3

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_A3
*&---------------------------------------------------------------------*
FORM get_data_a3.
  SELECT * FROM zfvata3
    INTO CORRESPONDING FIELDS OF TABLE id_itaba3
    WHERE bukrs EQ pa_bukrs AND
          gsber EQ pa_gsber AND
          gjahr EQ pa_gjahr AND
          monat EQ pa_monat.
ENDFORM.                    " GET_DATA_A3

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_A3
*&---------------------------------------------------------------------*
FORM download_a3.
  DATA: l_text(7),
        l_stat(2),
        l_stat1(2).
  DATA: l_npwp LIKE zfvatb1-stceg,
        l_nofak(10).

  CLEAR: wd_itaba3, i_itab.
  LOOP AT id_itaba3 INTO wd_itaba3.

    MOVE wd_itaba3-zstatus TO l_stat.
    MOVE l_stat(1) TO va_kdlamp.
    MOVE l_stat+1(1) TO va_kdstat.

    SELECT SINGLE zstatus1
      FROM zfpajak
      INTO l_stat1
      WHERE bukrs EQ pa_bukrs AND
            zstatus EQ wd_itaba3-zstatus.
    MOVE l_stat1+1(1) TO va_kddocu.

    CASE wd_itaba3-zstatus.
      WHEN '30'.
*        MOVE '0' TO VA_KDSTAT.
        MOVE  wd_itaba3-stceg TO l_npwp.
      WHEN '31'.
*        MOVE '1' TO VA_KDSTAT.
        MOVE  wd_itaba3-stceg TO l_npwp.
      WHEN '32'.
*        MOVE '2' TO VA_KDSTAT.
        MOVE  wd_itaba3-stceg TO l_npwp.
    ENDCASE.

    MOVE wd_itaba3-name1 TO va_nmwp.
*    MOVE '1' TO VA_KDDOCU.
    MOVE wd_itaba3-tbeln+0(5) TO va_kdfktr.

    WRITE wd_itaba3-tbeln+10(8) TO l_text.
    v_len = STRLEN( l_text ).
    v_space = 7 - v_len.
    DO v_space TIMES.
      CONCATENATE '0' l_text INTO l_text.
    ENDDO.
*    write l_text to  VA_NOFKTR RIGHT-JUSTIFIED.
    CONCATENATE wd_itaba3-txdat+6(2)
                wd_itaba3-txdat+4(2)
                wd_itaba3-txdat+0(4)
          INTO va_tglfkt SEPARATED BY '-'.
*    WRITE WD_ITABA1-TXDAT TO VA_TGLFKT DD/MM/YYYY.
    wd_itaba3-dmbtr = wd_itaba3-dmbtr * 100.

    IF wd_itaba3-shkzg EQ 'S'.
      WRITE wd_itaba3-dmbtr TO va_nilppn DECIMALS 0 NO-GROUPING.
      SHIFT va_nilppn LEFT DELETING LEADING space.
      CONCATENATE '-' va_nilppn INTO va_nilppn.
      IF pa_bukrs EQ '8010'.
        WRITE  va_nilppn       TO wa_itab-nilppn RIGHT-JUSTIFIED.
      ELSE.
        WRITE  va_nilppn       TO wa_itabt-nilppn RIGHT-JUSTIFIED.
      ENDIF.
    ELSE.
      WRITE wd_itaba3-dmbtr TO va_nilppn RIGHT-JUSTIFIED
      DECIMALS 0 NO-GROUPING.
      IF pa_bukrs EQ '8010'.
        WRITE va_nilppn       TO wa_itab-nilppn RIGHT-JUSTIFIED.
      ELSE.
        WRITE va_nilppn       TO wa_itabt-nilppn RIGHT-JUSTIFIED.
      ENDIF.
    ENDIF.

    WRITE space TO va_nilppnbm RIGHT-JUSTIFIED.
    WRITE pa_betul TO va_betul LEFT-JUSTIFIED.

* PERUBAHAN NPWP U/ TSP
    IF pa_bukrs EQ '8010'.
      CONCATENATE l_npwp+0(2) l_npwp+3(3) l_npwp+7(3) l_npwp+11(1)
                  l_npwp+13(3) l_npwp+17(3)
      INTO va_npwp.
      CONCATENATE l_npwp+13(3) l_text INTO l_nofak.
      WRITE l_nofak  TO va_nofktr RIGHT-JUSTIFIED.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = l_npwp
        IMPORTING
          npwp_out = va_npwp.
    ENDIF.

    IF pa_bukrs EQ '8010'.
      MOVE  wd_itaba3-gjahr TO wa_itab-thnpjk.
      MOVE  wd_itaba3-monat TO wa_itab-blnpjk.
      MOVE  va_betul        TO wa_itab-pembtl.
      MOVE  va_kdlamp       TO wa_itab-kdlamp.
      MOVE  va_kdstat       TO wa_itab-kdstat.
      MOVE  va_npwp         TO wa_itab-npwp.
      MOVE  va_nmwp         TO wa_itab-nmwp.
      MOVE  va_kddocu       TO wa_itab-kddocu.
      MOVE  va_kdfktr       TO wa_itab-kdfktr.
      MOVE  va_nofktr       TO wa_itab-nofktr.
      WRITE va_tglfkt       TO wa_itab-tglfkt.
      MOVE  va_nilppnbm     TO wa_itab-nilppnbm.

      IF wd_itaba3-zstatus EQ '30' OR
         wd_itaba3-zstatus EQ '31' OR
         wd_itaba3-zstatus EQ '32'.
        APPEND wa_itab TO i_itab.
      ENDIF.
    ELSE.
      MOVE  wd_itaba3-gjahr TO wa_itabt-thnpjk.
      MOVE  wd_itaba3-monat TO wa_itabt-blnpjk.
      MOVE  va_betul        TO wa_itabt-pembtl.
      MOVE  va_kdlamp       TO wa_itabt-kdlamp.
      MOVE  va_kdstat       TO wa_itabt-kdstat.
      IF va_npwp EQ space.
        wa_itabt-npwp = '000000000000000'.
      ELSE.
        MOVE  va_npwp         TO wa_itabt-npwp.
      ENDIF.
      MOVE  va_nmwp         TO wa_itabt-nmwp.
      MOVE  va_kddocu       TO wa_itabt-kddocu.
      MOVE  va_kdfktr       TO wa_itabt-kdfktr.
      MOVE  wd_itaba3-tbeln+6(3) TO wa_itabt-kdkpp.
      IF wa_itabt-kdkpp EQ space.
        wa_itabt-kdkpp = '000'.
      ENDIF.
      IF wd_itaba3-shkzg EQ 'H'.
        MOVE space TO wa_itabt-kdkpp.
        MOVE wd_itaba3-tbeln TO wa_itabt-nofktr.
      ELSE.
        MOVE wd_itaba3-tbeln+10(7) TO wa_itabt-nofktr.
      ENDIF.
      WRITE va_tglfkt       TO wa_itabt-tglfkt.
      MOVE  va_nilppnbm     TO wa_itabt-nilppnbm.

      IF wd_itaba3-zstatus EQ '30' OR
         wd_itaba3-zstatus EQ '31' OR
         wd_itaba3-zstatus EQ '32'.
        APPEND wa_itabt TO i_itabt.
      ENDIF.
    ENDIF.

    CLEAR: l_stat, l_stat1.

    CLEAR: wd_itaba3, va_kdstat, va_npwp, va_nmwp,
           va_nofktr, va_tglfkt, va_nilppn.
  ENDLOOP.

  IF pa_bukrs EQ '8010'.
    DESCRIBE TABLE i_itab LINES cntr.
  ELSE.
    DESCRIBE TABLE i_itabt LINES cntr.
  ENDIF.

  IF cntr NE 0.
    PERFORM validasi.
    IF error <> 0.
      PERFORM cetak_error.
    ELSE.
      PERFORM f_download_pc_a3.
    ENDIF.
  ELSE.
    MESSAGE i000(zf) WITH 'Data Not Found'.
  ENDIF.
  CLEAR: cntr.
ENDFORM.                    " DOWNLOAD_A3

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_A3_NEW
*&---------------------------------------------------------------------*
FORM download_a3_new.

  DATA: ld_vatpr LIKE zfvato-vatpr,
        ld_vatno LIKE zfvato-vatno,
        ld_dudat LIKE zfvato-dudat,
        ld_dueyr LIKE zfvato-dueyr,
        ld_duemm LIKE zfvato-duemm,
        ld_sspdt LIKE zfvato-sspdt,
        ld_netwr LIKE zfvato-netwr,
        ld_nonr  LIKE zfppnnrd-nonr,
        fname(128).

  CLEAR: wd_itaba3,i_espt.
  LOOP AT id_itaba3 INTO wd_itaba3.

    CLEAR: ld_vatpr,ld_dudat,ld_dueyr,ld_duemm,ld_sspdt,ld_netwr,
           ld_vatno.

    CLEAR: wa_espt-kodepjk,wa_espt-kodelam,wa_espt-kodests,
           wa_espt-kodedok,wa_espt-npwp,wa_espt-nama,wa_espt-kodecab,
           wa_espt-kodethn,wa_espt-nofkt,wa_espt-tglfkt,wa_espt-tglssp,
           wa_espt-masapjk,wa_espt-thnpjk,wa_espt-betul,wa_espt-dpp,
           wa_espt-ppn,wa_espt-ppnbm.


    IF wd_itaba3-stceg IS INITIAL.
      CONTINUE.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = wd_itaba3-stceg
        IMPORTING
          npwp_out = wd_itaba3-stceg.
    ENDIF.

    wa_espt-kodedok = '1'.
    wa_espt-kodecab = wd_itaba3-tbeln+3(3).
    wa_espt-kodethn = wd_itaba3-gjahr+2(2).
    wa_espt-nofkt   = wd_itaba3-tbeln+8(8).

*    ld_vatno = Wd_ITABA3-TBELN+8(8).

*    SELECT single vatpr dudat dueyr duemm sspdt netwr
*      INTO (ld_vatpr,ld_dudat,ld_dueyr,ld_duemm,ld_sspdt,ld_netwr)
*      FROM ZFVATO
*      WHERE vkorg = Wd_ITABA3-bukrs and
*            vkbur between '0201' and '0299' and
*            vatno = ld_vatno        and
*            dueyr = Wd_ITABA3-gjahr and
*            duemm = Wd_ITABA3-monat and
*            gsber = Wd_ITABA3-gsber and
*            vtart = 'SD'            and
*            flag1 ne 'K'.
*    IF sy-subrc NE 0.
    IF wd_itaba3-shkzg EQ 'S'.
      SELECT SINGLE nrdt gjahr monat dppcn
        INTO (ld_dudat,ld_dueyr,ld_duemm,ld_netwr)
        FROM zfppnnrd
        WHERE bukrs = wd_itaba3-bukrs AND
              vkbur BETWEEN '0201' AND '0299' AND
              belnr = wd_itaba3-tbeln.
      IF sy-subrc NE 0.
        CONTINUE.
      ELSE.
        wa_espt-kodedok = '2'.
        wa_espt-kodecab = space.
        wa_espt-kodethn = space.
        wa_espt-nofkt   = ld_nonr.
        wd_itaba3-dmbtr = wd_itaba3-dmbtr * -1.
      ENDIF.
    ENDIF.
*    ENDIF.

    wa_espt-kodepjk = 'A'.
    wa_espt-kodelam = '2'.
    wa_espt-kodests = wd_itaba3-tbeln+1(1).
    wa_espt-npwp    = wd_itaba3-stceg.
    wa_espt-nama    = wd_itaba3-name1.
    REPLACE ';' WITH space INTO wa_espt-nama.
    wa_espt-masapjk = wd_itaba3-monat.
    wa_espt-thnpjk  = wd_itaba3-gjahr.
    wa_espt-betul   = '0'.
*    wa_espt-betul   = Wd_ITABA3-tbeln+2(1).

*    if ld_netwr is initial.
*      wa_espt-dpp = '0'.
*    else.
*      ld_netwr = ld_netwr * 100.
*      write ld_netwr to wa_espt-dpp
*                     using edit mask '- _____________'
*                     decimals 0.
*    endif.

    IF wd_itaba3-dmbtr LT 0.
      ld_netwr = wd_itaba3-dmbtr * 1000.
      WRITE ld_netwr TO wa_espt-dpp
                              USING EDIT MASK '- _____________'
                     DECIMALS 0.

      IF wd_itaba3-dmbtr IS INITIAL.
        wa_espt-ppn = '0'.
      ELSE.
        wd_itaba3-dmbtr = wd_itaba3-dmbtr * 100.
        WRITE wd_itaba3-dmbtr TO wa_espt-ppn
                              USING EDIT MASK '- _____________'
                              DECIMALS 0.
      ENDIF.
    ELSE.
      ld_netwr = wd_itaba3-dmbtr * 1000.
      WRITE ld_netwr TO wa_espt-dpp
                     DECIMALS 0.

      IF wd_itaba3-dmbtr IS INITIAL.
        wa_espt-ppn = '0'.
      ELSE.
        wd_itaba3-dmbtr = wd_itaba3-dmbtr * 100.
        WRITE wd_itaba3-dmbtr TO wa_espt-ppn
                              DECIMALS 0.
      ENDIF.
    ENDIF.

    wa_espt-ppnbm   = '0'.

    DO 3 TIMES.
      REPLACE '.' WITH space INTO wa_espt-ppn.
      CONDENSE wa_espt-ppn NO-GAPS.
      REPLACE '.' WITH space INTO wa_espt-dpp.
      CONDENSE wa_espt-dpp NO-GAPS.
    ENDDO.

    IF NOT wd_itaba3-txdat IS INITIAL.
      WRITE wd_itaba3-txdat TO wa_espt-tglfkt
                            USING EDIT MASK '__/__/____'.
    ENDIF.

    IF NOT ld_sspdt IS INITIAL.
      WRITE ld_sspdt TO wa_espt-tglssp
                     USING EDIT MASK '__/__/____'.
    ENDIF.

    i_espt-data = wa_espt.
    CONDENSE i_espt-data NO-GAPS.

    APPEND i_espt. CLEAR: i_espt.

  ENDLOOP.

  CLEAR i_espt.
  INSERT i_espt INDEX 1.

  DESCRIBE TABLE i_espt LINES cntr.
  IF cntr = 0.
    MESSAGE i000(zf) WITH 'Data Not Found'.
    STOP.
  ENDIF.

  IF error <> 0.
    PERFORM cetak_error.
  ELSE.
    CONCATENATE 'C:\FILEA3_' pa_bukrs '_' pa_monat '.TXT' INTO fname.

*Begin remark Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
*    CALL FUNCTION 'DOWNLOAD'
*      EXPORTING
*        filename         = fname
*      IMPORTING
*        cancel           = canc
*        filesize         = size
*      TABLES
*        data_tab         = i_espt
*      EXCEPTIONS
*        file_open_error  = 1
*        file_write_error = 2.
*
*    IF canc = 'x'.
*      MESSAGE i000(zf) WITH 'Download Cancel by User'.
*    ENDIF.
*
*    IF size NE '0'.
*      MESSAGE i000(zf) WITH 'Download Success'.
*    ENDIF.
*End remark Unicode conversion - DEVK965554

*Begin insert Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
    DATA: lv_filename TYPE string.
    CLEAR lv_filename.
    lv_filename = fname.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_filename
        filetype                = 'TXT'
*      FIELDNAMES              = dwn_field
      CHANGING
        data_tab                = i_espt[]
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
*End insert Unicode conversion - DEVK965554

  ENDIF.

ENDFORM.                    " DOWNLOAD_A3_NEW

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_PC_A3
*&---------------------------------------------------------------------*
FORM f_download_pc_a3.
  DATA: fname(128).

*Begin remark Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
*  IF pa_bukrs EQ '8010'.
*    CALL FUNCTION 'DOWNLOAD'
*      EXPORTING
*        filename         = 'C:\FILEA3.DAT'
*      IMPORTING
*        cancel           = canc
*        filesize         = size
*      TABLES
*        data_tab         = i_itab
*      EXCEPTIONS
*        file_open_error  = 1
*        file_write_error = 2.
*  ELSE.
*    CONCATENATE 'C:\FILEA3_' pa_bukrs '_' pa_monat '.DAT'
*      INTO fname.
*    CALL FUNCTION 'DOWNLOAD'
*      EXPORTING
*        filename         = fname
*      IMPORTING
*        cancel           = canc
*        filesize         = size
*      TABLES
*        data_tab         = i_itabt
*      EXCEPTIONS
*        file_open_error  = 1
*        file_write_error = 2.
*  ENDIF.
*
*  IF canc = 'x'.
*    MESSAGE i000(zm) WITH 'Download Cancel by User'.
*  ENDIF.
*
*  IF size NE '0'.
*    MESSAGE i000(zf) WITH 'Download Success'.
*  ENDIF.
*End remark Unicode conversion - DEVK965554

*Begin insert Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
  DATA: lv_filename TYPE string.
  IF pa_bukrs EQ '8010'.
    CLEAR lv_filename.
    lv_filename = 'C:\FILEA3.DAT'.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_filename
        filetype                = 'DAT'
*        FIELDNAMES              = dwn_field
      CHANGING
        data_tab                = i_itab[]
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.
  ELSE.
    CLEAR lv_filename.
    CONCATENATE 'C:\FILEA3_' pa_bukrs '_' pa_monat '.DAT'
          INTO lv_filename.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_filename
        filetype                = 'DAT'
*        FIELDNAMES              = dwn_field
      CHANGING
        data_tab                = i_itabt[]
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.
  ENDIF.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*End insert Unicode conversion - DEVK965554

ENDFORM.                    " F_DOWNLOAD_PC_A3
*&---------------------------------------------------------------------*
*&      Form  f_post_fb09
*&---------------------------------------------------------------------*
FORM f_post_fb09.
  CLEAR i_bdc.
  PERFORM f_dynpro USING:
        'X'  'SAPMF05L'     '0102',
*         ' '  'BDC_CURSOR'
        ' '  'BDC_OKCODE'   '/00',
        ' '  'RF05L-BELNR'  wa_itab1-belnr,
        ' '  'RF05L-BUKRS'  pa_bukrs,
*         ' '  'RF05L-GJAHR'  pa_gjahr,
        ' '  'RF05L-GJAHR'  wa_itab1-gjahr,
        ' '  'RF05L-BUZEI'  '001',
        ' '  'RF05L-XKSAK'  'X',
        'X'  'SAPMF05L'     '0300',
        ' '  'BDC_OKCODE'   '=ZK',
        ' '  'DKACB-FMORE'  'X',
        'X'  'SAPLKACB'     '0002',
        ' '  'BDC_OKCODE'   '=ENTE',
        'X'  'SAPMF05L'     '1300',
        ' '  'BDC_OKCODE'   '=ENTR',
        ' '  'BSEG-XREF3'   wa_itab1-xref3,
        'X'  'SAPMF05L'     '0300',
        ' '  'BDC_OKCODE'   '=AE',
        'X'  'SAPLKACB'     '0002',
        ' '  'BDC_OKCODE'   '=ENTE'.
  CALL TRANSACTION 'FB09' USING i_bdc MODE va_mode UPDATE 'S'
                     MESSAGES INTO i_messtab.
  IF sy-subrc NE 0.
*      read table i_messtab into wa_messtab index 1.
    LOOP AT i_messtab INTO wa_messtab WHERE msgtyp = 'E'.
      CALL FUNCTION 'FORMAT_MESSAGE'
        EXPORTING
          id   = wa_messtab-msgid
          lang = wa_messtab-msgspra
          no   = wa_messtab-msgnr
          v1   = wa_messtab-msgv1
          v2   = wa_messtab-msgv2
          v3   = wa_messtab-msgv3
          v4   = wa_messtab-msgv4
        IMPORTING
          msg  = wa_log_error-msg.

      wa_log_error-hkont =   va_hkont2.
      wa_log_error-bukrs = pa_bukrs.
      wa_log_error-gjahr = wa_itab1-gjahr.
      wa_log_error-belnr = wa_itab1-belnr.
      APPEND wa_log_error TO i_log_error.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_post_fb09

*&---------------------------------------------------------------------*
*&      Form  WRITE_DATA_A1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_data_a1.
  DATA: l_text(7),
        l_npwp(20),
        v_nofktrx TYPE i,
        l_total LIKE wd_itaba1-dmbtr,
        v_total TYPE p DECIMALS 0,
        l_status LIKE wd_itaba1-zstatus.

  nourut = 0.

  MOVE '1' TO v_kdlamp.

* FAKTUR PAJAK SEDERHANA
  CLEAR: wd_itaba1, ta_excel, l_total.
  SORT id_itaba1 BY name1.
  LOOP AT id_itaba1 INTO wd_itaba1
    WHERE zstatus EQ '11'.
    MOVE '1' TO v_kdstat.
    nourut = 1.
    MOVE '000000000000000' TO v_npwp.
    MOVE  'Faktur Pajak Sederhana' TO v_nmwp.
    MOVE '1' TO v_kddocu.
    MOVE '0' TO v_kdfktr.
    MOVE '0' TO v_kdkpp.
    MOVE '0' TO v_nofktr.
    CONCATENATE wd_itaba1-txdat+6(2)
                wd_itaba1-txdat+4(2)
                wd_itaba1-txdat+0(4)
          INTO v_tglfkt SEPARATED BY '-'.
    ADD wd_itaba1-dmbtr TO l_total.
    MOVE wd_itaba1-zstatus TO l_status.
  ENDLOOP.

  l_total = l_total * 100.
  MOVE l_total TO v_total.

  MOVE  nourut          TO ta_excel-nourut.
  MOVE  wd_itaba1-gjahr TO ta_excel-thnpjk.
  MOVE  wd_itaba1-monat TO ta_excel-blnpjk.
  MOVE  v_betul         TO ta_excel-pembtl.
  MOVE  v_kdlamp        TO ta_excel-kdlamp.
  MOVE  v_kdstat        TO ta_excel-kdstat.
  MOVE  v_npwp          TO ta_excel-npwp.
  MOVE  v_nmwp          TO ta_excel-nmwp.
  MOVE  v_kddocu        TO ta_excel-kddocu.
  MOVE  v_kdfktr        TO ta_excel-kdfktr.
  MOVE  v_kdkpp         TO ta_excel-kdkpp.
  MOVE  v_nofktr        TO ta_excel-nofktr.
  MOVE  v_tglfkt        TO ta_excel-tglfkt.
  MOVE  v_total         TO ta_excel-nilppn.
  MOVE  v_nilppnbm      TO ta_excel-nilppnbm.

  IF l_status EQ '11'.
    APPEND ta_excel.
  ENDIF.

* PEMUNGUT PPN
  CLEAR: wd_itaba1, ta_excel, l_total.
  SORT id_itaba1 BY name1.
  LOOP AT id_itaba1 INTO wd_itaba1
    WHERE zstatus EQ '12'.
    nourut = 2.
    MOVE '1' TO v_kdstat.
    MOVE '000000000000000' TO v_npwp.
    MOVE  'Pemungut PPN' TO v_nmwp.
    MOVE '1' TO v_kddocu.
    MOVE '0' TO v_kdfktr.
    MOVE '0' TO v_kdkpp.
    MOVE '0' TO v_nofktr.
    CONCATENATE wd_itaba1-txdat+6(2)
                wd_itaba1-txdat+4(2)
                wd_itaba1-txdat+0(4)
          INTO v_tglfkt SEPARATED BY '-'.
    ADD wd_itaba1-dmbtr TO l_total.
    MOVE wd_itaba1-zstatus TO status.
  ENDLOOP.

  l_total = l_total * 100.
  MOVE l_total TO v_total.

  MOVE  nourut          TO ta_excel-nourut.
  MOVE  wd_itaba1-gjahr TO ta_excel-thnpjk.
  MOVE  wd_itaba1-monat TO ta_excel-blnpjk.
  MOVE  v_betul         TO ta_excel-pembtl.
  MOVE  v_kdlamp        TO ta_excel-kdlamp.
  MOVE  v_kdstat        TO ta_excel-kdstat.
  MOVE  v_npwp          TO ta_excel-npwp.
  MOVE  v_nmwp          TO ta_excel-nmwp.
  MOVE  v_kddocu        TO ta_excel-kddocu.
  MOVE  v_kdfktr        TO ta_excel-kdfktr.
  MOVE  v_kdkpp         TO ta_excel-kdkpp.
  MOVE  v_nofktr        TO ta_excel-nofktr.
  MOVE  v_tglfkt        TO ta_excel-tglfkt.
  MOVE  v_total         TO ta_excel-nilppn.
  MOVE  v_nilppnbm      TO ta_excel-nilppnbm.

  IF l_status EQ '12'.
    APPEND ta_excel.
  ENDIF.

*FAKTUR PAJAK STANDART
  MOVE '1' TO v_kdlamp.

  CLEAR: wd_itaba1, ta_excel.
  SORT id_itaba1 BY name1.
  LOOP AT id_itaba1 INTO wd_itaba1
    WHERE zstatus EQ '13'.

    MOVE '1' TO v_kdstat.
    MOVE  wd_itaba1-stceg TO v_npwp_in.

    CALL FUNCTION 'ZF_NPWP_MODIFICATION'
      EXPORTING
        npwp_in  = v_npwp_in
      IMPORTING
        npwp_out = v_npwp_out.

    MOVE  wd_itaba1-name1 TO v_nmwp.
    MOVE '1' TO v_kddocu.
    MOVE wd_itaba1-tbeln+0(5) TO v_kdfktr.
    MOVE wd_itaba1-tbeln+6(3) TO v_kdkpp.
    CLEAR l_text.
    WRITE wd_itaba1-tbeln+10(8) TO l_text.
    v_len = STRLEN( l_text ).
    v_space = 7 - v_len.
    DO v_space TIMES.
      CONCATENATE '0' l_text INTO l_text.
    ENDDO.
    WRITE l_text TO v_nofktr RIGHT-JUSTIFIED.
    CONCATENATE wd_itaba1-txdat+6(2)
                wd_itaba1-txdat+4(2)
                wd_itaba1-txdat+0(4)
          INTO v_tglfkt SEPARATED BY '-'.
    wd_itaba1-dmbtr = wd_itaba1-dmbtr * 100.
    MOVE wd_itaba1-dmbtr TO v_nilppn.
    WRITE pa_betul TO v_betul LEFT-JUSTIFIED.

*    CONCATENATE L_NPWP+0(2) L_NPWP+3(3) L_NPWP+7(3) L_NPWP+11(1)
*                L_NPWP+13(3) L_NPWP+17(3)
*    INTO V_NPWP.

    ADD 1 TO nourut.

    IF wd_itaba1-shkzg EQ 'S'.
      v_nilppn = v_nilppn * -1.
      MOVE '0' TO v_kdfktr.
      MOVE '0' TO v_kdkpp.
      IF wd_itaba1-tbeln(2) EQ '10'.
        CONCATENATE wd_itaba1-tbeln+2(1) wd_itaba1-tbeln+4(6)
          INTO v_nofktr.
      ELSE.
        v_nofktrx = STRLEN( wd_itaba1-tbeln ).
        v_nofktrx = v_nofktrx - 7.
        v_nofktr = wd_itaba1-tbeln+v_nofktrx(7).
      ENDIF.
    ENDIF.

    MOVE  nourut          TO ta_excel-nourut.
    MOVE  wd_itaba1-gjahr TO ta_excel-thnpjk.
    MOVE  wd_itaba1-monat TO ta_excel-blnpjk.
    MOVE  v_betul         TO ta_excel-pembtl.
    MOVE  v_kdlamp        TO ta_excel-kdlamp.
    MOVE  v_kdstat        TO ta_excel-kdstat.
    MOVE  v_npwp_out      TO ta_excel-npwp.
    MOVE  v_nmwp          TO ta_excel-nmwp.
    MOVE  v_kddocu        TO ta_excel-kddocu.
    MOVE  v_kdfktr        TO ta_excel-kdfktr.
    MOVE  v_kdkpp         TO ta_excel-kdkpp.
    MOVE  v_nofktr        TO ta_excel-nofktr.
    MOVE  v_tglfkt        TO ta_excel-tglfkt.
    MOVE  v_nilppn        TO ta_excel-nilppn.
    MOVE  v_nilppnbm      TO ta_excel-nilppnbm.

    IF wd_itaba1-zstatus EQ '13'.
      APPEND ta_excel.
    ENDIF.

    CLEAR: wd_itaba1, v_kdstat, v_npwp, v_nmwp,
           v_nofktr, v_tglfkt, v_nilppn.
  ENDLOOP.


  CLEAR: wd_itaba1, v_kdstat, v_npwp, v_nmwp,
         v_nofktr, v_tglfkt, v_nilppn.
*  ENDLOOP.

ENDFORM.                    " WRITE_DATA_A1

*&---------------------------------------------------------------------*
*&      Form  WRITE_DATA_A3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_data_a3.
  DATA: l_text(7),
        l_npwp(20).

  nourut = 0.

  MOVE '1' TO v_kdlamp.

  CLEAR: wd_itaba3, ta_excel.
  SORT id_itaba3 BY name1.
  LOOP AT id_itaba3 INTO wd_itaba3.
    CASE wd_itaba3-zstatus.
      WHEN '30'.
        MOVE '0' TO v_kdstat.
        MOVE  wd_itaba3-stceg TO v_npwp_in.
      WHEN '31'.
        MOVE '1' TO v_kdstat.
        MOVE  wd_itaba3-stceg TO v_npwp_in.
      WHEN '32'.
        MOVE '2' TO v_kdstat.
        MOVE  wd_itaba3-stceg TO v_npwp_in.
    ENDCASE.

    CALL FUNCTION 'ZF_NPWP_MODIFICATION'
      EXPORTING
        npwp_in  = v_npwp_in
      IMPORTING
        npwp_out = v_npwp_out.

    MOVE  wd_itaba3-name1 TO v_nmwp.
    MOVE '1' TO v_kddocu.
    MOVE wd_itaba3-tbeln+0(5) TO v_kdfktr.
    MOVE wd_itaba3-tbeln+6(3) TO v_kdkpp.
    CLEAR l_text.
    WRITE wd_itaba3-tbeln+10(8) TO l_text.
    v_len = STRLEN( l_text ).
    v_space = 7 - v_len.
    DO v_space TIMES.
      CONCATENATE '0' l_text INTO l_text.
    ENDDO.
    WRITE l_text TO v_nofktr RIGHT-JUSTIFIED.
    CONCATENATE wd_itaba3-txdat+6(2)
                wd_itaba3-txdat+4(2)
                wd_itaba3-txdat+0(4)
          INTO v_tglfkt SEPARATED BY '-'.
    wd_itaba3-dmbtr = wd_itaba3-dmbtr * 100.
    MOVE wd_itaba3-dmbtr TO v_nilppn.
    WRITE pa_betul TO v_betul LEFT-JUSTIFIED.

*    CONCATENATE L_NPWP+0(2) L_NPWP+3(3) L_NPWP+7(3) L_NPWP+11(1)
*                L_NPWP+13(3) L_NPWP+17(3)
*    INTO V_NPWP.

    ADD 1 TO nourut.

    IF wd_itaba3-shkzg EQ 'S'.
      v_nilppn = v_nilppn * -1.
    ENDIF.

    MOVE  nourut          TO ta_excel-nourut.
    MOVE  wd_itaba3-gjahr TO ta_excel-thnpjk.
    MOVE  wd_itaba3-monat TO ta_excel-blnpjk.
    MOVE  v_betul        TO ta_excel-pembtl.
    MOVE  v_kdlamp       TO ta_excel-kdlamp.
    MOVE  v_kdstat       TO ta_excel-kdstat.
    MOVE  v_npwp_out     TO ta_excel-npwp.
    MOVE  v_nmwp         TO ta_excel-nmwp.
    MOVE  v_kddocu       TO ta_excel-kddocu.
    MOVE  v_kdfktr       TO ta_excel-kdfktr.
    MOVE  v_kdkpp        TO ta_excel-kdkpp.
    MOVE  v_nofktr       TO ta_excel-nofktr.
    MOVE  v_tglfkt       TO ta_excel-tglfkt.
    MOVE  v_nilppn       TO ta_excel-nilppn.
    MOVE  v_nilppnbm     TO ta_excel-nilppnbm.

    IF wd_itaba3-zstatus EQ '30' OR
       wd_itaba3-zstatus EQ '31' OR
       wd_itaba3-zstatus EQ '32'.
      APPEND ta_excel.
    ENDIF.

    CLEAR: wd_itaba3, v_kdstat, v_npwp, v_nmwp,
           v_nofktr, v_tglfkt, v_nilppn.
  ENDLOOP.

ENDFORM.                    " WRITE_DATA_A3

*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_fieldcat.
  DATA: xfieldcat TYPE slis_fieldcat_alv.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'NOURUT'.
  xfieldcat-tabname      = 'TA_EXCEL'.
  xfieldcat-col_pos      = 1.
  xfieldcat-outputlen    = 8.
  xfieldcat-reptext_ddic = 'No. Urut'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'NMWP'.
  xfieldcat-tabname      = 'TA_EXCEL'.
  xfieldcat-col_pos      = 2.
  xfieldcat-outputlen    = 30.
  xfieldcat-reptext_ddic = 'Nama Pembeli'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'NPWP'.
  xfieldcat-tabname      = 'TA_EXCEL'.
  xfieldcat-col_pos      = 3.
  xfieldcat-outputlen    = 15.
  xfieldcat-reptext_ddic = 'NPWP'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'KDFKTR'.
  xfieldcat-tabname      = 'TA_EXCEL'.
  xfieldcat-col_pos      = 4.
  xfieldcat-outputlen    = 5.
  xfieldcat-reptext_ddic = 'KODE FAKTUR'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'KDKPP'.
  xfieldcat-tabname      = 'TA_EXCEL'.
  xfieldcat-col_pos      = 5.
  xfieldcat-outputlen    = 3.
  xfieldcat-reptext_ddic = 'KODE KPP'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'NOFKTR'.
  xfieldcat-tabname      = 'TA_EXCEL'.
  xfieldcat-col_pos      = 6.
  xfieldcat-outputlen    = 7.
  xfieldcat-reptext_ddic = 'NO.FAKTUR'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'TGLFKT'.
  xfieldcat-tabname      = 'TA_EXCEL'.
  xfieldcat-col_pos      = 7.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'TGL FAKTUR'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'NILPPN'.
  xfieldcat-tabname      = 'TA_EXCEL'.
  xfieldcat-col_pos      = 8.
  xfieldcat-outputlen    = 20.
  xfieldcat-decimals_out = '0'.
  xfieldcat-reptext_ddic = 'PPN'.
  APPEND xfieldcat TO xit_fieldcat.

ENDFORM.   "BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  COMMENT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIST_TOP_OF_PAGE[]  text
*----------------------------------------------------------------------*
FORM comment_build USING lt_top_of_page TYPE slis_t_listheader.
  DATA: ls_line TYPE slis_listheader.
  DATA: l_name       LIKE t001-butxt,
        l_npwp       LIKE zftax-npwp,
        bulan(10),
        report1(19),
        report2(19),
        report3(19),
        header1(50),
        header2(50),
        header3(50).

  SELECT SINGLE butxt
    FROM t001
    INTO l_name
    WHERE bukrs EQ pa_bukrs.

  SELECT SINGLE npwp
    FROM zftax
    INTO l_npwp
    WHERE bukrs EQ pa_bukrs AND
          gsber EQ pa_gsber.

  CASE pa_monat.
    WHEN '01'.
      MOVE 'JANUARI' TO bulan.
    WHEN '02'.
      MOVE 'FEBRUARI' TO bulan.
    WHEN '03'.
      MOVE 'MARET' TO bulan.
    WHEN '04'.
      MOVE 'APRIL' TO bulan.
    WHEN '05'.
      MOVE 'MEI' TO bulan.
    WHEN '06'.
      MOVE 'JUNI' TO bulan.
    WHEN '07'.
      MOVE 'JULI' TO bulan.
    WHEN '08'.
      MOVE 'AGUSTUS' TO bulan.
    WHEN '09'.
      MOVE 'SEPTEMBER' TO bulan.
    WHEN '10'.
      MOVE 'OKTOBER' TO bulan.
    WHEN '11'.
      MOVE 'NOVEMBER' TO bulan.
    WHEN '12'.
      MOVE 'DESEMBER' TO bulan.
  ENDCASE.

  MOVE 'Nama PKP Pelapor  :' TO report1.
  MOVE 'NPWP              :' TO report2.
  MOVE 'Masa Pajak        :' TO report3.

  CONCATENATE report1 l_name INTO header1
    SEPARATED BY space.

  CONCATENATE report2 l_npwp INTO header2
    SEPARATED BY space.

  CONCATENATE report3 bulan pa_gjahr INTO header3
    SEPARATED BY space.

  CLEAR ls_line.
  ls_line-typ  = 'H'.
  ls_line-info = header1.
  APPEND ls_line TO lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'H'.
  ls_line-info = header2.
  APPEND ls_line TO lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'H'.
  ls_line-info = header3.
  APPEND ls_line TO lt_top_of_page.

ENDFORM.    "COMMENT_BUILD

*&---------------------------------------------------------------------*
*&      Form  EVENTTAB_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
FORM eventtab_build USING rt_events TYPE slis_t_event.
*"Registration of events to happen during list display
  DATA: ls_event TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = rt_events.
  READ TABLE rt_events WITH KEY name = slis_ev_top_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE g_top_of_page TO ls_event-form.
    APPEND ls_event TO rt_events.
  ENDIF.
ENDFORM.                    "EVENTTAB_BUILD

*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOUT  text
*----------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE slis_layout_alv.
*"Build layout for list display
  rs_layout-detail_popup      = 'X'.
  rs_layout-zebra             = 'X'.

ENDFORM.                    "LAYOUT_INIT

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
*       Ereigniss TOP_OF_PAGE                                       *
*       event     TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM top_of_page.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
       EXPORTING
*             I_LOGO             = 'ENJOYSAP_LOGO'
          it_list_commentary = gt_list_top_of_page.
ENDFORM.                    "TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  f_get_filename
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_filename.
  DATA: v_repid LIKE sy-repid.
  v_repid = sy-repid.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = v_repid
      dynpro_number = sy-dynnr
      field_name    = 'P_FILENM'
    IMPORTING
      file_name     = p_filenm
    EXCEPTIONS
      OTHERS        = 1.

  IF sy-subrc <> 0.
    CLEAR p_filenm.
  ENDIF.

ENDFORM.                    " f_get_filename

*&---------------------------------------------------------------------*
*&      Form  GET_UPLOAD_A1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_upload_a1.
  DATA: v_flag_mater(1) TYPE c,
        l_count(5),
        l_count1(5),
        error_count TYPE i,
        l_message(30),
        nomor(5).

  error_count = 0.
  counter = 0.
  counter1 = 0.
  nomor = 0.

  REFRESH i_excel.
* GET MATERIAL NUMBER FROM EXCEL FILE.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_filenm                "INPUT FROM SELECTION SCREEN
      i_begin_col             = 1
      i_begin_row             = 1
      i_end_col               = 14
      i_end_row               = 60000
    TABLES
      intern                  = i_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ELSE.
*     MESSAGE i000(ZF) WITH 'Upload Success'.
  ENDIF.

  SORT i_excel BY row col value.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 30
      text       = text-021
    EXCEPTIONS
      OTHERS     = 1.

  CLEAR id_itaba1.
  CLEAR wa_excel.
* Material Number is at col 3
  v_flag_mater = 'N'.
  LOOP AT i_excel INTO wa_excel.

    ON CHANGE OF wa_excel-row.
      IF v_flag_mater = 'Y'.
        APPEND wd_itaba1 TO id_itaba1.
        CLEAR  wd_itaba1.
      ENDIF.
      v_flag_mater = 'Y'.
    ENDON.

    v_flag_mater = 'Y'.
    IF wa_excel-col = '0001'.
      MOVE wa_excel-value TO wd_itaba1-bukrs.
    ENDIF.
    IF wa_excel-col = '0002'.
      MOVE wa_excel-value TO wd_itaba1-gsber.
    ENDIF.
    IF wa_excel-col = '0003'.
      MOVE wa_excel-value TO wd_itaba1-gjahr.
    ENDIF.
    IF wa_excel-col = '0004'.
      MOVE wa_excel-value TO wd_itaba1-monat.
    ENDIF.
    IF wa_excel-col = '0005'.
      MOVE wa_excel-value TO wd_itaba1-txdat.
    ENDIF.
    IF wa_excel-col = '0006'.
      MOVE wa_excel-value TO wd_itaba1-tbeln.
    ENDIF.
    IF wa_excel-col = '0007'.
      MOVE wa_excel-value TO wd_itaba1-name1.
    ENDIF.
    IF wa_excel-col = '0008'.
      MOVE wa_excel-value TO wd_itaba1-stceg.
    ENDIF.
    IF wa_excel-col = '0009'.
      MOVE wa_excel-value TO wd_itaba1-shkzg.
    ENDIF.
    IF wa_excel-col = '0010'.
      MOVE wa_excel-value TO wd_itaba1-waers.
    ENDIF.
    IF wa_excel-col = '0011'.
      MOVE wa_excel-value TO wd_itaba1-dmbtr.
      wd_itaba1-dmbtr = wd_itaba1-dmbtr / 100.
    ENDIF.
    IF wa_excel-col = '0012'.
      MOVE wa_excel-value TO wd_itaba1-remark.
    ENDIF.
    IF wa_excel-col = '0013'.
      MOVE wa_excel-value TO wd_itaba1-zstatus.
    ENDIF.
    IF wa_excel-col = '0014'.
      MOVE wa_excel-value TO wd_itaba1-stceg1.
    ENDIF.
    CLEAR wa_excel.
  ENDLOOP.

  IF v_flag_mater = 'Y'.
    APPEND wd_itaba1 TO id_itaba1.
    CLEAR  wd_itaba1.
  ENDIF.

  v_flag_mater = 'Y'.

  CLEAR: wd_itaba1.
  LOOP AT id_itaba1 INTO wd_itaba1.
    IF wd_itaba1-tbeln EQ space.
      ADD 1 TO error_count.
      APPEND wd_itaba1 TO i_error.
    ENDIF.

*    IF WD_ITABA1-TXDAT(4) NE PA_GJAHR.
*       ADD 1 TO ERROR_COUNT.
*       APPEND WD_ITABA1 TO I_ERROR.
*    ENDIF.

    IF wd_itaba1-zstatus NE '11' AND
       wd_itaba1-zstatus NE '12' AND
       wd_itaba1-zstatus NE '13' AND
       wd_itaba1-zstatus NE '17'.
      ADD 1 TO error_count.
    ENDIF.
    ADD 1 TO counter.
    CLEAR: wd_itaba1.
  ENDLOOP.

  IF error_count EQ 0.
    MOVE counter TO l_count.
    CONCATENATE 'UPLOAD' l_count 'RECORD' INTO l_message
      SEPARATED BY space.
    INSERT zfvata1 FROM TABLE id_itaba1 ACCEPTING DUPLICATE KEYS.
    MESSAGE i000(zf) WITH l_message.
  ELSE.
    MESSAGE i000(zf) WITH 'Upload Error'.
    CLEAR wa_error.
    WRITE: / sy-uline(90),
           /   sy-vline NO-GAP, 'Nomor' NO-GAP,
               sy-vline NO-GAP, 'Company Code' NO-GAP,
               sy-vline NO-GAP, 'Business Area' NO-GAP,
               sy-vline NO-GAP, 'Fiscal Year' NO-GAP,
               sy-vline NO-GAP, 'Period' NO-GAP,
               sy-vline NO-GAP, 'Tax Date' NO-GAP,
            64 sy-vline NO-GAP, 'VAT Out Number' NO-GAP,
            83 sy-vline NO-GAP, 'Status' NO-GAP,
               sy-vline.
    LOOP AT i_error INTO wa_error.
      ADD 1 TO nomor.
      WRITE: / sy-uline(90).
      WRITE: /   sy-vline NO-GAP, nomor NO-GAP,
              7  sy-vline NO-GAP, wa_error-bukrs NO-GAP,
              20 sy-vline NO-GAP, wa_error-gsber NO-GAP,
              34 sy-vline NO-GAP, wa_error-gjahr NO-GAP,
              46 sy-vline NO-GAP, wa_error-monat NO-GAP,
              53 sy-vline NO-GAP, wa_error-txdat NO-GAP,
                 sy-vline NO-GAP, wa_error-tbeln NO-GAP,
                 sy-vline NO-GAP, wa_error-zstatus NO-GAP,
              90 sy-vline NO-GAP.
      CLEAR wa_error.
    ENDLOOP.
    WRITE: / sy-uline(90).
  ENDIF.

ENDFORM.                    " GET_UPLOAD_A1

*&---------------------------------------------------------------------*
*&      Form  GET_UPLOAD_A3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_upload_a3.
  DATA: v_flag_mater1(1) TYPE c,
        l_count(5),
        l_message(30),
        nomor(5),
        error_count TYPE i.

  counter = 0.
  error_count = 0.
  nomor = 0.

  REFRESH i_excel.
* GET MATERIAL NUMBER FROM EXCEL FILE.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_filenm                "INPUT FROM SELECTION SCREEN
      i_begin_col             = 1
      i_begin_row             = 1
      i_end_col               = 14
      i_end_row               = 60000
    TABLES
      intern                  = i_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  SORT i_excel BY row col value.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 30
      text       = text-021
    EXCEPTIONS
      OTHERS     = 1.

  CLEAR id_itaba3.
  CLEAR wa_excel.
* Material Number is at col 3
  v_flag_mater1 = 'N'.
  LOOP AT i_excel INTO wa_excel.
    ON CHANGE OF wa_excel-row.
      IF v_flag_mater1 = 'Y'.
        APPEND wd_itaba3 TO id_itaba3.
        CLEAR  wd_itaba3.
      ENDIF.
      v_flag_mater1 = 'Y'.
    ENDON.
    v_flag_mater1 = 'Y'.
    IF wa_excel-col = '0001'.
      MOVE wa_excel-value TO wd_itaba3-bukrs.
    ENDIF.
    IF wa_excel-col = '0002'.
      MOVE wa_excel-value TO wd_itaba3-gsber.
    ENDIF.
    IF wa_excel-col = '0003'.
      MOVE wa_excel-value TO wd_itaba3-gjahr.
    ENDIF.
    IF wa_excel-col = '0004'.
      MOVE wa_excel-value TO wd_itaba3-monat.
    ENDIF.
    IF wa_excel-col = '0005'.
      MOVE wa_excel-value TO wd_itaba3-txdat.
    ENDIF.
    IF wa_excel-col = '0006'.
      MOVE wa_excel-value TO wd_itaba3-tbeln.
    ENDIF.
    IF wa_excel-col = '0007'.
      MOVE wa_excel-value TO wd_itaba3-name1.
    ENDIF.
    IF wa_excel-col = '0008'.
      MOVE wa_excel-value TO wd_itaba3-stceg.
    ENDIF.
    IF wa_excel-col = '0009'.
      MOVE wa_excel-value TO wd_itaba3-shkzg.
    ENDIF.
    IF wa_excel-col = '0010'.
      MOVE wa_excel-value TO wd_itaba3-waers.
    ENDIF.
    IF wa_excel-col = '0011'.
      MOVE wa_excel-value TO wd_itaba3-dmbtr.
      wd_itaba3-dmbtr = wd_itaba3-dmbtr / 100.
    ENDIF.
    IF wa_excel-col = '0012'.
      MOVE wa_excel-value TO wd_itaba3-remark.
    ENDIF.
    IF wa_excel-col = '0013'.
      MOVE wa_excel-value TO wd_itaba3-zstatus.
    ENDIF.
    IF wa_excel-col = '0014'.
      MOVE wa_excel-value TO wd_itaba3-stceg1.
    ENDIF.
    CLEAR wa_excel.
  ENDLOOP.
  IF v_flag_mater1 = 'Y'.
    APPEND wd_itaba3 TO id_itaba3.
    CLEAR  wd_itaba3.
  ENDIF.
  v_flag_mater1 = 'Y'.

  CLEAR: wd_itaba3.
  CLEAR: wd_itaba1.

  LOOP AT id_itaba3 INTO wd_itaba3.
    IF wd_itaba3-tbeln EQ space.
      ADD 1 TO error_count.
      APPEND wd_itaba3 TO i_error.
    ENDIF.

    IF wd_itaba3-txdat GT pa_post.
      ADD 1 TO error_count.
      APPEND wd_itaba3 TO i_error.
    ENDIF.

    IF wd_itaba3-zstatus NE '30' AND
       wd_itaba3-zstatus NE '31' AND
       wd_itaba3-zstatus NE '32'.
      ADD 1 TO error_count.
      APPEND wd_itaba3 TO i_error.
    ENDIF.
    ADD 1 TO counter.
    CLEAR: wd_itaba3.
  ENDLOOP.

  IF error_count EQ 0.
    MOVE counter TO l_count.
    CONCATENATE 'UPLOAD' l_count 'RECORD' INTO l_message
      SEPARATED BY space.
    INSERT zfvata3 FROM TABLE id_itaba3 ACCEPTING DUPLICATE KEYS.
    MESSAGE i000(zf) WITH l_message.
  ELSE.
    MESSAGE i000(zf) WITH 'Upload Error'.
    CLEAR wa_error.
    WRITE: / sy-uline(90),
           /   sy-vline NO-GAP, 'Nomor' NO-GAP,
               sy-vline NO-GAP, 'Company Code' NO-GAP,
               sy-vline NO-GAP, 'Business Area' NO-GAP,
               sy-vline NO-GAP, 'Fiscal Year' NO-GAP,
               sy-vline NO-GAP, 'Period' NO-GAP,
               sy-vline NO-GAP, 'Tax Date' NO-GAP,
            64 sy-vline NO-GAP, 'VAT Out Number' NO-GAP,
            83 sy-vline NO-GAP, 'Status' NO-GAP,
               sy-vline.
    LOOP AT i_error INTO wa_error.
      ADD 1 TO nomor.
      WRITE: / sy-uline(90).
      WRITE: /   sy-vline NO-GAP, nomor NO-GAP,
              7  sy-vline NO-GAP, wa_error-bukrs NO-GAP,
              20 sy-vline NO-GAP, wa_error-gsber NO-GAP,
              34 sy-vline NO-GAP, wa_error-gjahr NO-GAP,
              46 sy-vline NO-GAP, wa_error-monat NO-GAP,
              53 sy-vline NO-GAP, wa_error-txdat NO-GAP,
                 sy-vline NO-GAP, wa_error-tbeln NO-GAP,
                 sy-vline NO-GAP, wa_error-zstatus NO-GAP,
              90 sy-vline NO-GAP.
      CLEAR wa_error.
    ENDLOOP.
    WRITE: / sy-uline(90).
  ENDIF.

ENDFORM.                    " GET_UPLOAD_A3

** TYPE FOR THE DATA OF TABLECONTROL 'TA_TABLE'
*TYPES: BEGIN OF T_TA_TABLE,
*         CHECK(1),
*         BUKRS LIKE ZFVATA1-BUKRS,
*         GSBER LIKE ZFVATA1-GSBER,
*         GJAHR LIKE ZFVATA1-GJAHR,
*         MONAT LIKE ZFVATA1-MONAT,
*         TXDAT LIKE ZFVATA1-TXDAT,
*         TBELN LIKE ZFVATA1-TBELN,
*         NAME1 LIKE ZFVATA1-NAME1,
*         STCEG LIKE ZFVATA1-STCEG,
*         SHKZG LIKE ZFVATA1-SHKZG,
*         WAERS LIKE ZFVATA1-WAERS,
*         DMBTR LIKE ZFVATA1-DMBTR,
*         REMARK LIKE ZFVATA1-REMARK,
*         ZSTATUS LIKE ZFVATA1-ZSTATUS,
*       END OF T_TA_TABLE.
*
** INTERNAL TABLE FOR TABLECONTROL 'TA_TABLE'
*DATA:     G_TA_TABLE_ITAB   TYPE T_TA_TABLE OCCURS 0,
*          G_TA_TABLE_DELE   TYPE T_TA_TABLE OCCURS 0,
*          G_TA_TABLE_WA     TYPE T_TA_TABLE, "work area
*          G_TA_TABLE_COPIED.           "copy flag

* DECLARATION OF TABLECONTROL 'TA_TABLE' ITSELF
*CONTROLS: TA_TABLE TYPE TABLEVIEW USING SCREEN 0900.

* LINES OF TABLECONTROL 'TA_TABLE'
*DATA:     G_TA_TABLE_LINES  LIKE SY-LOOPC.

* OUTPUT MODULE FOR TABLECONTROL 'TA_TABLE':
* COPY DDIC-TABLE TO ITAB
MODULE ta_table_init OUTPUT.
  IF g_ta_table_copied IS INITIAL.
* COPY DDIC-TABLE 'ZFVATA1'
* INTO INTERNAL TABLE 'g_TA_TABLE_itab'
    CLEAR: g_ta_table_itab.
    REFRESH: g_ta_table_itab.
    SELECT * FROM zfvata1
       INTO CORRESPONDING FIELDS
       OF TABLE g_ta_table_itab
       WHERE gsber EQ pa_gsber AND
             bukrs EQ pa_bukrs AND
             gjahr EQ pa_gjahr AND
             monat EQ pa_monat AND
             tbeln IN so_tbel1.
    IF sy-subrc NE 0.
      MESSAGE i000(zf) WITH 'Data not found'.
      LEAVE TO SCREEN 0.
    ELSE.
      APPEND LINES OF g_ta_table_itab TO g_ta_table_dele.
    ENDIF.
    g_ta_table_copied = 'X'.
    REFRESH CONTROL 'TA_TABLE' FROM SCREEN '0900'.
  ENDIF.
ENDMODULE.                    "TA_TABLE_INIT OUTPUT

* OUTPUT MODULE FOR TABLECONTROL 'TA_TABLE':
* MOVE ITAB TO DYNPRO
MODULE ta_table_move OUTPUT.
  MOVE-CORRESPONDING g_ta_table_wa TO zfvata1.
ENDMODULE.                    "TA_TABLE_MOVE OUTPUT

* OUTPUT MODULE FOR TABLECONTROL 'TA_TABLE':
* GET LINES OF TABLECONTROL
MODULE ta_table_get_lines OUTPUT.
  g_ta_table_lines = sy-loopc.
ENDMODULE.                    "TA_TABLE_GET_LINES OUTPUT

* INPUT MODULE FOR TABLECONTROL 'TA_TABLE': MODIFY TABLE
MODULE ta_table_modify INPUT.
  MOVE-CORRESPONDING zfvata1 TO g_ta_table_wa.
  MODIFY g_ta_table_itab
    FROM g_ta_table_wa
    INDEX ta_table-current_line.
ENDMODULE.                    "TA_TABLE_MODIFY INPUT

* INPUT MODULE FOR TABLECONTROL 'TA_TABLE': PROCESS USER COMMAND
MODULE ta_table_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TA_TABLE'
                              'G_TA_TABLE_ITAB'
                              'CHECK'
                     CHANGING  ok_code.
  IF sy-ucomm EQ 'TA_TABLE_INSR'.
    CLEAR: ok_code, sy-ucomm.
  ENDIF.
ENDMODULE.                    "TA_TABLE_USER_COMMAND INPUT

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                         p_table_name
                         p_mark_name
                CHANGING p_ok      LIKE sy-ucomm.

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA: l_ok              TYPE sy-ucomm,
        l_offset          TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

* Table control specific operations                                    *
*   evaluate TC name and operations                                    *
  SEARCH p_ok FOR p_tc_name.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  l_offset = STRLEN( p_tc_name ) + 1.
  l_ok = p_ok+l_offset.

* execute general and TC specific operations                           *
  CASE l_ok.

    WHEN 'INSR'.                      "insert row
      PERFORM fcode_insert_row USING    p_tc_name
                                        p_table_name.
      CLEAR p_ok.

    WHEN 'DELE'.                      "delete row
      PERFORM fcode_delete_row USING    p_tc_name
                                        p_table_name
                                        p_mark_name.

      CLEAR p_ok.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM compute_scrolling_in_tc USING p_tc_name
                                            l_ok.
      CLEAR p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM fcode_tc_mark_lines USING p_tc_name
                                        p_table_name
                                        p_mark_name   .
      CLEAR p_ok.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM fcode_tc_demark_lines USING p_tc_name
                                          p_table_name
                                          p_mark_name .
      CLEAR p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

  ENDCASE.

ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_insert_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name             .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_lines_name       LIKE feld-name.
  DATA l_selline          LIKE sy-stepl.
  DATA l_lastline         TYPE i.
  DATA l_line             TYPE i.
  DATA l_table_name       LIKE feld-name.
  FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
  FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <lines>              TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* get looplines of TableControl
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
  ASSIGN (l_lines_name) TO <lines>.

* get current line
  GET CURSOR LINE l_selline.
  IF sy-subrc <> 0.                   " append line to table
    l_selline = <tc>-lines + 1.
*   set top line and new cursor line                                   *
    IF l_selline > <lines>.
      <tc>-top_line = l_selline - <lines> + 1 .
      l_line = 1.
    ELSE.
      <tc>-top_line = 1.
      l_line = l_selline.
    ENDIF.
  ELSE.                               " insert line into table
    l_selline = <tc>-top_line + l_selline - 1.
*   set top line and new cursor line                                   *
    l_lastline = l_selline + <lines> - 1.
    IF l_lastline <= <tc>-lines.
      <tc>-top_line = l_selline.
      l_line = 1.
    ELSEIF <lines> > <tc>-lines.
      <tc>-top_line = 1.
      l_line = l_selline.
    ELSE.
      <tc>-top_line = <tc>-lines - <lines> + 2 .
      l_line = l_selline - <tc>-top_line + 1.
    ENDIF.
  ENDIF.
* insert initial line
  INSERT INITIAL LINE INTO <table> INDEX l_selline.
  <tc>-lines = <tc>-lines + 1.
* set cursor
  SET CURSOR LINE l_line.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_delete_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name
                       p_mark_name.

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_table_name       LIKE feld-name.
  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

  CLEAR l_table_name.
* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* delete marked lines                                                  *
  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    IF <mark_field> = 'X'.
      DELETE <table> INDEX syst-tabix.
      IF sy-subrc = 0.
*          ASSIGN COMPONENT P_MARK_NAME
*         APPEND G_TA_TABLE_WA TO G_TA_TABLE_DELE.
        <tc>-lines = <tc>-lines - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM compute_scrolling_in_tc USING    p_tc_name
                                      p_ok.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_tc_new_top_line     TYPE i.
  DATA l_tc_name             LIKE feld-name.
  DATA l_tc_lines_name       LIKE feld-name.
  DATA l_tc_field_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <lines>      TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.
* get looplines of TableControl
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
  ASSIGN (l_tc_lines_name) TO <lines>.


* is no line filled?                                                   *
  IF <tc>-lines = 0.
*   yes, ...                                                           *
    l_tc_new_top_line = 1.
  ELSE.
*   no, ...                                                            *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
         EXPORTING
              entry_act             = <tc>-top_line
              entry_from            = 1
              entry_to              = <tc>-lines
              last_page_full        = 'X'
              loops                 = <lines>
              ok_code               = p_ok
              overlapping           = 'X'
         IMPORTING
              entry_new             = l_tc_new_top_line
         EXCEPTIONS
*              NO_ENTRY_OR_PAGE_ACT  = 01
*              NO_ENTRY_TO           = 02
*              NO_OK_CODE_OR_PAGE_GO = 03
              OTHERS                = 0.
  ENDIF.

* get actual tc and column                                             *
  GET CURSOR FIELD l_tc_field_name
             AREA  l_tc_name.

  IF syst-subrc = 0.
    IF l_tc_name = p_tc_name.
*     set actual column                                                *
      SET CURSOR FIELD l_tc_field_name LINE 1.
    ENDIF.
  ENDIF.

* set the new top line                                                 *
  <tc>-top_line = l_tc_new_top_line.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_mark_lines USING p_tc_name
                               p_table_name
                               p_mark_name.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* mark all filled lines                                                *
  LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_demark_lines USING p_tc_name
                                 p_table_name
                                 p_mark_name .
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* demark all filled lines                                              *
  LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = space.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------

*&      Module  USER_COMMAND_0900  INPUT
*&---------------------------------------------------------------------

*       text
*----------------------------------------------------------------------

MODULE user_command_0900 INPUT.
  DATA: l_switch TYPE i.

  l_switch = 0.

  PERFORM get_data_a1.
  save_ok = sy-ucomm.
  CASE save_ok.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

    WHEN 'SAVE'.
      CLEAR g_ta_table_wa.
      LOOP AT g_ta_table_itab INTO g_ta_table_wa.
        zfvata1-name1   = g_ta_table_wa-name1.
        zfvata1-stceg   = g_ta_table_wa-stceg.
        zfvata1-shkzg   = g_ta_table_wa-shkzg.
        zfvata1-waers   = g_ta_table_wa-waers.
        zfvata1-dmbtr   = g_ta_table_wa-dmbtr.
        zfvata1-remark  = g_ta_table_wa-remark.
        zfvata1-zstatus = g_ta_table_wa-zstatus.
        zfvata1-bukrs   = g_ta_table_wa-bukrs.
        zfvata1-gsber   = g_ta_table_wa-gsber.
        zfvata1-gjahr   = g_ta_table_wa-gjahr.
        zfvata1-monat   = g_ta_table_wa-monat.
        zfvata1-txdat   = g_ta_table_wa-txdat.
        zfvata1-tbeln   = g_ta_table_wa-tbeln.
        MODIFY zfvata1.
        CLEAR g_ta_table_wa.
      ENDLOOP.

      IF so_tbel1 EQ space.
        CLEAR wd_itaba1.
        LOOP AT id_itaba1 INTO wd_itaba1.
          CLEAR g_ta_table_wa.
          SORT g_ta_table_itab BY txdat tbeln.
          LOOP AT g_ta_table_itab INTO g_ta_table_wa
            WHERE bukrs EQ wd_itaba1-bukrs AND
                  gsber EQ wd_itaba1-gsber AND
                  gjahr EQ wd_itaba1-gjahr AND
                  monat EQ wd_itaba1-monat AND
                  txdat EQ wd_itaba1-txdat AND
                  tbeln EQ wd_itaba1-tbeln.
            l_switch = 1.
            CLEAR g_ta_table_wa.
          ENDLOOP.

          IF l_switch = 1.
            l_switch = 0.
          ELSE.
            wa_dele-name1   = wd_itaba1-name1.
            wa_dele-stceg   = wd_itaba1-stceg.
            wa_dele-shkzg   = wd_itaba1-shkzg.
            wa_dele-waers   = wd_itaba1-waers.
            wa_dele-dmbtr   = wd_itaba1-dmbtr.
            wa_dele-remark  = wd_itaba1-remark.
            wa_dele-zstatus = wd_itaba1-zstatus.
            wa_dele-bukrs   = wd_itaba1-bukrs.
            wa_dele-gsber   = wd_itaba1-gsber.
            wa_dele-gjahr   = wd_itaba1-gjahr.
            wa_dele-monat   = wd_itaba1-monat.
            wa_dele-txdat   = wd_itaba1-txdat.
            wa_dele-tbeln   = wd_itaba1-tbeln.
            APPEND wa_dele TO i_dele.
          ENDIF.
          CLEAR wd_itaba1.
        ENDLOOP.

        CLEAR wa_dele.
        LOOP AT i_dele INTO wa_dele.
          SELECT *
            FROM zfvata1
            WHERE bukrs EQ wa_dele-bukrs AND
                  gsber EQ wa_dele-gsber AND
                  gjahr EQ wa_dele-gjahr AND
                  monat EQ wa_dele-monat AND
                  txdat EQ wa_dele-txdat AND
                  tbeln EQ wa_dele-tbeln.
            IF sy-subrc = 0.
              DELETE zfvata1.
            ENDIF.
          ENDSELECT.
          CLEAR wa_dele.
        ENDLOOP.
      ENDIF.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0900  INPUT

*&---------------------------------------------------------------------

*&      Module  STATUS_0900  OUTPUT
*&---------------------------------------------------------------------

*       text
*----------------------------------------------------------------------

MODULE status_0900 OUTPUT.
  SET PF-STATUS 'STATUS_900'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0900  OUTPUT.

*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen OUTPUT.
  IF g_ta_table_wa-bukrs EQ space.
    LOOP AT SCREEN.
      screen-input = 1.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " MODIFY_SCREEN  OUTPUT

*----------------------------------------------------------------------*
* OUTPUT MODULE FOR TABLECONTROL 'TA_TABLE1':
* COPY DDIC-TABLE TO ITAB
*----------------------------------------------------------------------*
MODULE ta_table1_init OUTPUT.
  IF g_ta_table1_copied IS INITIAL.
* COPY DDIC-TABLE 'ZFVATA3'
* INTO INTERNAL TABLE 'g_TA_TABLE1_itab'
    SELECT * FROM zfvata3
       INTO CORRESPONDING FIELDS
       OF TABLE g_ta_table1_itab
       WHERE gsber EQ pa_gsber AND
             bukrs EQ pa_bukrs AND
             gjahr EQ pa_gjahr AND
             monat EQ pa_monat AND
             tbeln IN so_tbel2.
    IF sy-subrc NE 0.
*          MESSAGE I000(ZF) WITH 'Data not found'.
*          LEAVE TO SCREEN 0.
    ELSE.
      APPEND LINES OF g_ta_table_itab TO g_ta_table_dele.
    ENDIF.
    g_ta_table1_copied = 'X'.
    REFRESH CONTROL 'TA_TABLE1' FROM SCREEN '0910'.
  ENDIF.
ENDMODULE.                    "TA_TABLE1_INIT OUTPUT

*----------------------------------------------------------------------*
* OUTPUT MODULE FOR TABLECONTROL 'TA_TABLE1':
* MOVE ITAB TO DYNPRO
*----------------------------------------------------------------------*
MODULE ta_table1_move OUTPUT.
  MOVE-CORRESPONDING g_ta_table1_wa TO zfvata3.
ENDMODULE.                    "TA_TABLE1_MOVE OUTPUT

*----------------------------------------------------------------------*
* OUTPUT MODULE FOR TABLECONTROL 'TA_TABLE1':
* GET LINES OF TABLECONTROL
*----------------------------------------------------------------------*
MODULE ta_table1_get_lines OUTPUT.
  g_ta_table1_lines = sy-loopc.
ENDMODULE.                    "TA_TABLE1_GET_LINES OUTPUT

*----------------------------------------------------------------------*
* INPUT MODULE FOR TABLECONTROL 'TA_TABLE1': MODIFY TABLE
*----------------------------------------------------------------------*
MODULE ta_table1_modify INPUT.
  MOVE-CORRESPONDING zfvata3 TO g_ta_table1_wa.
  MODIFY g_ta_table1_itab
    FROM g_ta_table1_wa
    INDEX ta_table1-current_line.
ENDMODULE.                    "TA_TABLE1_MODIFY INPUT

*----------------------------------------------------------------------*
* INPUT MODULE FOR TABLECONTROL 'TA_TABLE1': PROCESS USER COMMAND
*----------------------------------------------------------------------*
MODULE ta_table1_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TA_TABLE1'
                              'G_TA_TABLE1_ITAB'
                              'CHECK'
                     CHANGING ok_code.
  IF sy-ucomm EQ 'TA_TABLE1_INSR'.
    CLEAR: ok_code, sy-ucomm.
  ENDIF.
ENDMODULE.                    "TA_TABLE1_USER_COMMAND INPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0910  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0910 OUTPUT.
  SET PF-STATUS 'STATUS_910'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0910  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0910  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0910 INPUT.
  l_switch = 0.

  PERFORM get_data_a3.

  save_ok = sy-ucomm.
  CASE save_ok.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

    WHEN 'SAVE'.
      CLEAR g_ta_table1_wa.
      LOOP AT g_ta_table1_itab INTO g_ta_table1_wa.
        zfvata3-name1   = g_ta_table1_wa-name1.
        zfvata3-stceg   = g_ta_table1_wa-stceg.
        zfvata3-shkzg   = g_ta_table1_wa-shkzg.
        zfvata3-waers   = g_ta_table1_wa-waers.
        zfvata3-dmbtr   = g_ta_table1_wa-dmbtr.
        zfvata3-remark  = g_ta_table1_wa-remark.
        zfvata3-zstatus = g_ta_table1_wa-zstatus.
        zfvata3-bukrs   = g_ta_table1_wa-bukrs.
        zfvata3-gsber   = g_ta_table1_wa-gsber.
        zfvata3-gjahr   = g_ta_table1_wa-gjahr.
        zfvata3-monat   = g_ta_table1_wa-monat.
        zfvata3-txdat   = g_ta_table1_wa-txdat.
        zfvata3-tbeln   = g_ta_table1_wa-tbeln.
        MODIFY zfvata3.
        CLEAR g_ta_table1_wa.
      ENDLOOP.

      IF so_tbel2 EQ space.
        CLEAR wa_itaba3.
        LOOP AT id_itaba3 INTO wd_itaba3.
          CLEAR g_ta_table1_wa.
          SORT g_ta_table1_itab BY txdat tbeln.
          LOOP AT g_ta_table1_itab INTO g_ta_table1_wa
            WHERE bukrs EQ wd_itaba3-bukrs AND
                  gsber EQ wd_itaba3-gsber AND
                  gjahr EQ wd_itaba3-gjahr AND
                  monat EQ wd_itaba3-monat AND
                  txdat EQ wd_itaba3-txdat AND
                  tbeln EQ wd_itaba3-tbeln.
            l_switch = 1.
            CLEAR g_ta_table1_wa.
          ENDLOOP.

          IF l_switch = 1.
            l_switch = 0.
          ELSE.
            wa_dele-name1   = wd_itaba3-name1.
            wa_dele-stceg   = wd_itaba3-stceg.
            wa_dele-shkzg   = wd_itaba3-shkzg.
            wa_dele-waers   = wd_itaba3-waers.
            wa_dele-dmbtr   = wd_itaba3-dmbtr.
            wa_dele-remark  = wd_itaba3-remark.
            wa_dele-zstatus = wd_itaba3-zstatus.
            wa_dele-bukrs   = wd_itaba3-bukrs.
            wa_dele-gsber   = wd_itaba3-gsber.
            wa_dele-gjahr   = wd_itaba3-gjahr.
            wa_dele-monat   = wd_itaba3-monat.
            wa_dele-txdat   = wd_itaba3-txdat.
            wa_dele-tbeln   = wd_itaba3-tbeln.
            APPEND wa_dele TO i_dele.
          ENDIF.
          CLEAR wa_itaba3.
        ENDLOOP.

        CLEAR wa_dele.
        LOOP AT i_dele INTO wa_dele.
          SELECT *
            FROM zfvata3
            WHERE bukrs EQ wa_dele-bukrs AND
                  gsber EQ wa_dele-gsber AND
                  gjahr EQ wa_dele-gjahr AND
                  monat EQ wa_dele-monat AND
                  txdat EQ wa_dele-txdat AND
                  tbeln EQ wa_dele-tbeln.
            IF sy-subrc = 0.
              DELETE zfvata3.
            ENDIF.
          ENDSELECT.
          CLEAR wa_dele.
        ENDLOOP.
      ENDIF.
      LEAVE TO SCREEN 0.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0910  INPUT

*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen1 OUTPUT.
  IF g_ta_table1_wa-bukrs EQ space.
    LOOP AT SCREEN.
      screen-input = 1.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " MODIFY_SCREEN1  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  VALIDASI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validasi.
  LOOP AT i_itabt INTO wa_itabt.
    IF wa_itabt-npwp CA
'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.
      wa_error1-nmwp   = wa_itabt-nmwp.
      wa_error1-kdfktr = wa_itabt-kdfktr.
      wa_error1-kdkpp  = wa_itabt-kdkpp.
      wa_error1-nofktr = wa_itabt-nofktr.
      wa_error1-npwp   = wa_itabt-npwp.
      APPEND wa_error1 TO i_error1.
      ADD 1 TO error.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " VALIDASI

*&---------------------------------------------------------------------*
*&      Form  CETAK_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_error.
  DATA: l_nofktr(20).

  LOOP AT i_error1 INTO wa_error1.
    CONCATENATE wa_error1-kdfktr wa_error1-kdkpp wa_error1-nofktr
      INTO l_nofktr
      SEPARATED BY '-'.
    WRITE: / wa_error1-nmwp,
             l_nofktr,
             wa_error1-npwp.
  ENDLOOP.
ENDFORM.                    " CETAK_ERROR

*&---------------------------------------------------------------------*
*&      Module  TA_TABLE2_INIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ta_table2_init OUTPUT.
  IF g_ta_table2_copied IS INITIAL.
* COPY DDIC-TABLE 'ZFVATA3'
* INTO INTERNAL TABLE 'g_TA_TABLE1_itab'
    SELECT * FROM zfvata2
       INTO CORRESPONDING FIELDS
       OF TABLE g_ta_table2_itab
       WHERE gsber EQ pa_gsber AND
             bukrs EQ pa_bukrs AND
             gjahr EQ pa_gjahr AND
             monat EQ pa_monat AND
             tbeln IN so_tbel3.
    IF sy-subrc NE 0.
*          MESSAGE I000(ZF) WITH 'Data not found'.
*          LEAVE TO SCREEN 0.
    ELSE.
      APPEND LINES OF g_ta_table_itab TO g_ta_table_dele.
    ENDIF.
    g_ta_table2_copied = 'X'.
    REFRESH CONTROL 'TA_TABLE2' FROM SCREEN '0920'.
  ENDIF.

ENDMODULE.                 " TA_TABLE2_INIT  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN2  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen2 OUTPUT.
  IF g_ta_table2_wa-bukrs EQ space.
    LOOP AT SCREEN.
      screen-input = 1.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " MODIFY_SCREEN2  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TA_TABLE2_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ta_table2_move OUTPUT.
  MOVE-CORRESPONDING g_ta_table2_wa TO zfvata2.
ENDMODULE.                 " TA_TABLE2_MOVE  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TA_TABLE2_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ta_table2_get_lines OUTPUT.
  g_ta_table2_lines = sy-loopc.
ENDMODULE.                 " TA_TABLE2_GET_LINES  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0920  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0920 OUTPUT.
  SET PF-STATUS 'STATUS_920'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0920  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TA_TABLE2_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ta_table2_modify INPUT.
  MOVE-CORRESPONDING zfvata2 TO g_ta_table2_wa.
  MODIFY g_ta_table2_itab
    FROM g_ta_table2_wa
    INDEX ta_table2-current_line.
ENDMODULE.                 " TA_TABLE2_MODIFY  INPUT

*&---------------------------------------------------------------------*
*&      Module  TA_TABLE2_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ta_table2_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TA_TABLE2'
                              'G_TA_TABLE2_ITAB'
                              'CHECK'
                     CHANGING ok_code.
  IF sy-ucomm EQ 'TA_TABLE2_INSR'.
    CLEAR: ok_code, sy-ucomm.
  ENDIF.
ENDMODULE.                 " TA_TABLE2_USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0920  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0920 INPUT.
  l_switch = 0.

  PERFORM get_data_a2.

  save_ok = sy-ucomm.
  CASE save_ok.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

    WHEN 'SAVE'.
      CLEAR g_ta_table2_wa.
      LOOP AT g_ta_table2_itab INTO g_ta_table2_wa.
        zfvata2-name1   = g_ta_table2_wa-name1.
        zfvata2-stceg   = g_ta_table2_wa-stceg.
        zfvata2-shkzg   = g_ta_table2_wa-shkzg.
        zfvata2-waers   = g_ta_table2_wa-waers.
        zfvata2-dmbtr   = g_ta_table2_wa-dmbtr.
        zfvata2-remark  = g_ta_table2_wa-remark.
        zfvata2-zstatus = g_ta_table2_wa-zstatus.
        zfvata2-bukrs   = g_ta_table2_wa-bukrs.
        zfvata2-gsber   = g_ta_table2_wa-gsber.
        zfvata2-gjahr   = g_ta_table2_wa-gjahr.
        zfvata2-monat   = g_ta_table2_wa-monat.
        zfvata2-txdat   = g_ta_table2_wa-txdat.
        zfvata2-tbeln   = g_ta_table2_wa-tbeln.
        MODIFY zfvata2.
        CLEAR g_ta_table2_wa.
      ENDLOOP.

      IF so_tbel3 EQ space.
        CLEAR wa_itaba2.
        LOOP AT id_itaba2 INTO wd_itaba2.
          CLEAR g_ta_table2_wa.
          SORT g_ta_table2_itab BY txdat tbeln.
          LOOP AT g_ta_table2_itab INTO g_ta_table2_wa
            WHERE bukrs EQ wd_itaba2-bukrs AND
                  gsber EQ wd_itaba2-gsber AND
                  gjahr EQ wd_itaba2-gjahr AND
                  monat EQ wd_itaba2-monat AND
                  txdat EQ wd_itaba2-txdat AND
                  tbeln EQ wd_itaba2-tbeln.
            l_switch = 1.
            CLEAR g_ta_table2_wa.
          ENDLOOP.

          IF l_switch = 1.
            l_switch = 0.
          ELSE.
            wa_dele-name1   = wd_itaba2-name1.
            wa_dele-stceg   = wd_itaba2-stceg.
            wa_dele-shkzg   = wd_itaba2-shkzg.
            wa_dele-waers   = wd_itaba2-waers.
            wa_dele-dmbtr   = wd_itaba2-dmbtr.
            wa_dele-remark  = wd_itaba2-remark.
            wa_dele-zstatus = wd_itaba2-zstatus.
            wa_dele-bukrs   = wd_itaba2-bukrs.
            wa_dele-gsber   = wd_itaba2-gsber.
            wa_dele-gjahr   = wd_itaba2-gjahr.
            wa_dele-monat   = wd_itaba2-monat.
            wa_dele-txdat   = wd_itaba2-txdat.
            wa_dele-tbeln   = wd_itaba2-tbeln.
            APPEND wa_dele TO i_dele.
          ENDIF.
          CLEAR wa_itaba2.
        ENDLOOP.

        CLEAR wa_dele.
        LOOP AT i_dele INTO wa_dele.
          SELECT *
            FROM zfvata2
            WHERE bukrs EQ wa_dele-bukrs AND
                  gsber EQ wa_dele-gsber AND
                  gjahr EQ wa_dele-gjahr AND
                  monat EQ wa_dele-monat AND
                  txdat EQ wa_dele-txdat AND
                  tbeln EQ wa_dele-tbeln.
            IF sy-subrc = 0.
              DELETE zfvata2.
            ENDIF.
          ENDSELECT.
          CLEAR wa_dele.
        ENDLOOP.
      ENDIF.
      LEAVE TO SCREEN 0.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0920  INPUT

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_A2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_a2.
  SELECT * FROM zfvata2
    INTO CORRESPONDING FIELDS OF TABLE id_itaba2
    WHERE bukrs EQ pa_bukrs AND
          gsber EQ pa_gsber AND
          gjahr EQ pa_gjahr AND
          monat EQ pa_monat.
ENDFORM.                    " GET_DATA_A2

*&---------------------------------------------------------------------*
*&      Form  f_download_a2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download_a2.
  PERFORM get_data_a2.
  IF pa_gjahr GT 2006.
    PERFORM download_a2_new.
  ELSE.
    PERFORM download_a2.
  ENDIF.
ENDFORM.                    " f_download_a2

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_A2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM download_a2.
  DATA: l_text(7),
        l_text1(7),
        l_stat(2),
        l_stat1(2).

  DATA: l_npwp LIKE zfvatb1-stceg,
        l_nofak(10).

  CLEAR: wd_itaba2, i_itab.
  LOOP AT id_itaba2 INTO wd_itaba2.
    MOVE wd_itaba2-zstatus TO l_stat.
    MOVE l_stat(1) TO va_kdlamp.

    SELECT SINGLE zstatus1
      FROM zfpajak
      INTO l_stat1
      WHERE bukrs EQ pa_bukrs AND
            zstatus EQ wd_itaba2-zstatus.

    MOVE l_stat1+1(1) TO va_kddocu.

    CASE wd_itaba2-zstatus.
      WHEN '21'.
        MOVE l_stat+1(1) TO va_kdstat.
        WRITE '00.000.000.0.000.000' TO l_npwp LEFT-JUSTIFIED.
      WHEN '23'.
        MOVE l_stat+1(1) TO va_kdstat.
        MOVE  wd_itaba2-stceg TO l_npwp.
    ENDCASE.

    MOVE  wd_itaba2-name1 TO va_nmwp.
    CLEAR l_text.
    WRITE wd_itaba2-tbeln+10(8) TO l_text.
    v_len = STRLEN( l_text ).
    v_space = 7 - v_len.
    DO v_space TIMES.
      CONCATENATE '0' l_text INTO l_text.
    ENDDO.
    CONCATENATE wd_itaba2-txdat+6(2)
                wd_itaba2-txdat+4(2)
                wd_itaba2-txdat+0(4)
          INTO va_tglfkt SEPARATED BY '/'.
    wd_itaba2-dmbtr = wd_itaba2-dmbtr * 100.
    WRITE space TO va_nilppnbm RIGHT-JUSTIFIED.
    WRITE pa_betul TO va_betul LEFT-JUSTIFIED.

* PERUBAHAN NPWP U/ TSP
    IF pa_bukrs EQ '8010'.
      CONCATENATE l_npwp+0(2) l_npwp+3(3) l_npwp+7(3) l_npwp+11(1)
                  l_npwp+13(3) l_npwp+17(3)
      INTO va_npwp.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = l_npwp
        IMPORTING
          npwp_out = va_npwp.
    ENDIF.

* KONDISI U/ CN
    IF wd_itaba2-dmbtr < 0.
      v_len = STRLEN( wd_itaba2-tbeln ) - 7.
      WRITE wd_itaba2-tbeln+v_len(7) TO l_text1 RIGHT-JUSTIFIED.
    ELSE.
      CONCATENATE l_npwp+13(3) l_text INTO l_nofak.
      WRITE l_nofak  TO va_nofktr RIGHT-JUSTIFIED.
    ENDIF.

    IF wd_itaba2-shkzg EQ 'S'.
      MOVE '4' TO va_kddocu.
      IF pa_bukrs EQ '8010'.
        WRITE wd_itaba2-tbeln TO l_nofak.
        WRITE l_nofak TO va_nofktr RIGHT-JUSTIFIED.
        va_kdfktr = space.
      ELSE.
        wa_itabt-kdfktr = space.
        wa_itabt-kdkpp  = space.
        wa_itabt-nofktr = wd_itaba2-tbeln.
      ENDIF.
      WRITE wd_itaba2-dmbtr TO va_nilppn DECIMALS 0 NO-GROUPING.
      SHIFT va_nilppn LEFT DELETING LEADING space.
      CONCATENATE '-' va_nilppn INTO va_nilppn.
      IF pa_bukrs EQ '8010'.
        WRITE  va_nilppn       TO wa_itab-nilppn RIGHT-JUSTIFIED.
      ELSE.
        WRITE  va_nilppn       TO wa_itabt-nilppn RIGHT-JUSTIFIED.
      ENDIF.
    ELSE.
      IF pa_bukrs EQ '8010'.
        MOVE wd_itaba2-tbeln+0(5) TO va_kdfktr.
      ELSE.
        MOVE  wd_itaba2-tbeln(5) TO wa_itabt-kdfktr.
        MOVE  wd_itaba2-tbeln+6(3) TO wa_itabt-kdkpp.
        MOVE  wd_itaba2-tbeln+10(7) TO wa_itabt-nofktr.
      ENDIF.
      WRITE wd_itaba2-dmbtr TO va_nilppn RIGHT-JUSTIFIED
      DECIMALS 0 NO-GROUPING.
      IF pa_bukrs EQ '8010'.
        WRITE va_nilppn       TO wa_itab-nilppn RIGHT-JUSTIFIED.
      ELSE.
        WRITE va_nilppn       TO wa_itabt-nilppn RIGHT-JUSTIFIED.
      ENDIF.
    ENDIF.

* KODE FAKTUR & NO FAKTUR UNTUK FAKTUR PAJAK SEDERHANA
    IF wd_itaba2-zstatus EQ '21'.
      IF pa_bukrs EQ '8010'.
        WRITE '00000' TO va_kdfktr.
        WRITE '   0000000' TO va_nofktr RIGHT-JUSTIFIED.
      ELSE.
        MOVE space TO wa_itabt-kdfktr.
        MOVE space TO wa_itabt-kdkpp.
        WRITE wd_itaba2-tbeln TO wa_itabt-nofktr.
      ENDIF.
    ENDIF.

    IF pa_bukrs EQ '8010'.
      MOVE  wd_itaba2-gjahr TO wa_itab-thnpjk.
      MOVE  wd_itaba2-monat TO wa_itab-blnpjk.
      MOVE  va_betul        TO wa_itab-pembtl.
      MOVE  va_kdlamp       TO wa_itab-kdlamp.
      MOVE  va_kdstat       TO wa_itab-kdstat.
      MOVE  va_npwp         TO wa_itab-npwp.
      MOVE  va_nmwp         TO wa_itab-nmwp.
      MOVE  va_kddocu       TO wa_itab-kddocu.
      MOVE  va_kdfktr       TO wa_itab-kdfktr.
      MOVE  va_nofktr       TO wa_itab-nofktr.
      WRITE va_tglfkt       TO wa_itab-tglfkt.
      MOVE  va_nilppnbm     TO wa_itab-nilppnbm.

      IF wd_itaba2-zstatus EQ '21' OR
         wd_itaba2-zstatus EQ '23'.
        APPEND wa_itab TO i_itab.
      ENDIF.
    ELSE.
      MOVE  wd_itaba2-gjahr TO wa_itabt-thnpjk.
      MOVE  wd_itaba2-monat TO wa_itabt-blnpjk.
      MOVE  va_betul        TO wa_itabt-pembtl.
      MOVE  va_kdlamp       TO wa_itabt-kdlamp.
      MOVE  va_kdstat       TO wa_itabt-kdstat.
      MOVE  va_npwp         TO wa_itabt-npwp.
      MOVE  va_nmwp         TO wa_itabt-nmwp.
      MOVE  va_kddocu       TO wa_itabt-kddocu.
      WRITE va_tglfkt       TO wa_itabt-tglfkt.
      MOVE  va_nilppnbm     TO wa_itabt-nilppnbm.

      IF wd_itaba2-zstatus EQ '21' OR
         wd_itaba2-zstatus EQ '23'.
        APPEND wa_itabt TO i_itabt.
      ENDIF.
    ENDIF.

    CLEAR: l_stat, l_stat1.
    CLEAR: wd_itaba2, va_kdstat, va_npwp, va_nmwp,
           va_nofktr, va_tglfkt, va_nilppn.
  ENDLOOP.

  IF pa_bukrs EQ '8010'.
    DESCRIBE TABLE i_itab LINES cntr.
  ELSE.
    DESCRIBE TABLE i_itabt LINES cntr.
  ENDIF.

  IF cntr NE 0.
    PERFORM validasi.
    IF error <> 0.
      PERFORM cetak_error.
    ELSE.
      PERFORM f_download_pc_a2.
    ENDIF.
  ELSE.
    MESSAGE i000(zf) WITH 'Data Not Found'.
  ENDIF.
  CLEAR: cntr.
ENDFORM.                    " DOWNLOAD_A2

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_A2_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM download_a2_new.

  DATA: ld_vatpr LIKE zfvato-vatpr,
        ld_vatno LIKE zfvato-vatno,
        ld_dudat LIKE zfvato-dudat,
        ld_dueyr LIKE zfvato-dueyr,
        ld_duemm LIKE zfvato-duemm,
        ld_sspdt LIKE zfvato-sspdt,
        ld_netwr LIKE zfvato-netwr,
        ld_nonr  LIKE zfppnnrd-nonr,
        fname(128).

  DELETE id_itaba2 WHERE zstatus NE '23'.

  CLEAR: wd_itaba2, i_espt.
  LOOP AT id_itaba2 INTO wd_itaba2.

    CLEAR: ld_vatpr,ld_dudat,ld_dueyr,ld_duemm,ld_sspdt,ld_netwr,
           ld_vatno.

    CLEAR: wa_espt-kodepjk,wa_espt-kodelam,wa_espt-kodests,
           wa_espt-kodedok,wa_espt-npwp,wa_espt-nama,wa_espt-kodecab,
           wa_espt-kodethn,wa_espt-nofkt,wa_espt-tglfkt,wa_espt-tglssp,
           wa_espt-masapjk,wa_espt-thnpjk,wa_espt-betul,wa_espt-dpp,
           wa_espt-ppn,wa_espt-ppnbm.

    IF wd_itaba2-stceg IS INITIAL.
      CONTINUE.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = wd_itaba2-stceg
        IMPORTING
          npwp_out = wd_itaba2-stceg.
    ENDIF.

    wa_espt-kodedok = '1'.
    wa_espt-kodecab = wd_itaba2-tbeln+3(3).
    wa_espt-kodethn = wd_itaba2-gjahr+2(2).
    wa_espt-nofkt   = wd_itaba2-tbeln+8(8).

*    ld_vatno = Wd_ITABA2-TBELN+8(8).

*    SELECT single vatpr dudat dueyr duemm sspdt netwr
*      INTO (ld_vatpr,ld_dudat,ld_dueyr,ld_duemm,ld_sspdt,ld_netwr)
*      FROM ZFVATO
*      WHERE vkorg = Wd_ITABA2-bukrs and
*            vkbur between '0201' and '0299' and
*            vatno = ld_vatno        and
*            dueyr = Wd_ITABA2-gjahr and
*            duemm = Wd_ITABA2-monat and
*            gsber = Wd_ITABA2-gsber and
*            vtart = 'SD'            and
*            flag1 ne 'K'.
*    IF sy-subrc NE 0.
    IF wd_itaba2-shkzg EQ 'S'.
      SELECT SINGLE nrdt gjahr monat dppcn
        INTO (ld_dudat,ld_dueyr,ld_duemm,ld_netwr)
        FROM zfppnnrd
        WHERE bukrs = wd_itaba2-bukrs AND
              vkbur BETWEEN '0201' AND '0299' AND
              belnr = wd_itaba2-tbeln.
      IF sy-subrc NE 0.
        CONTINUE.
      ELSE.
        wa_espt-kodedok = '2'.
        wa_espt-kodecab = space.
        wa_espt-kodethn = space.
        wa_espt-nofkt   = ld_nonr.
        wd_itaba2-dmbtr = wd_itaba2-dmbtr * -1.
      ENDIF.
    ENDIF.
*    ENDIF.

    wa_espt-kodepjk = 'A'.
    wa_espt-kodelam = '2'.
    wa_espt-kodests = wd_itaba2-tbeln+1(1).
    IF wa_espt-kodests EQ '0'.
      wa_espt-kodests = '7'.
    ENDIF.
    wa_espt-npwp    = wd_itaba2-stceg.
    wa_espt-nama    = wd_itaba2-name1.
    REPLACE ';' WITH space INTO wa_espt-nama.
    wa_espt-masapjk = wd_itaba2-monat.
    wa_espt-thnpjk  = wd_itaba2-gjahr.
    wa_espt-betul   = '0'.
*    wa_espt-betul   = Wd_ITABA2-tbeln+2(1).

*    if ld_netwr is initial.
*      wa_espt-dpp = '0'.
*    else.
*      ld_netwr        = ld_netwr * 100.
*      write ld_netwr to wa_espt-dpp
**                     using edit mask '- _____________'
*                     decimals 0.
*    endif.

    IF wd_itaba2-dmbtr LT 0.
      ld_netwr = wd_itaba2-dmbtr * 1000.
      WRITE ld_netwr TO wa_espt-dpp
                     USING EDIT MASK '- _____________'
                     DECIMALS 0.

      IF wd_itaba2-dmbtr IS INITIAL.
        wa_espt-ppn = '0'.
      ELSE.
        wd_itaba2-dmbtr = wd_itaba2-dmbtr * 100.
        WRITE wd_itaba2-dmbtr TO wa_espt-ppn
                              USING EDIT MASK '- _____________'
                              DECIMALS 0.
      ENDIF.
    ELSE.
      ld_netwr = wd_itaba2-dmbtr * 1000.
      WRITE ld_netwr TO wa_espt-dpp
                     DECIMALS 0.

      IF wd_itaba2-dmbtr IS INITIAL.
        wa_espt-ppn = '0'.
      ELSE.
        wd_itaba2-dmbtr = wd_itaba2-dmbtr * 100.
        WRITE wd_itaba2-dmbtr TO wa_espt-ppn
                              DECIMALS 0.
      ENDIF.
    ENDIF.

    wa_espt-ppnbm   = '0'.

    DO 3 TIMES.
      REPLACE '.' WITH space INTO wa_espt-ppn.
      CONDENSE wa_espt-ppn NO-GAPS.
      REPLACE '.' WITH space INTO wa_espt-dpp.
      CONDENSE wa_espt-dpp NO-GAPS.
    ENDDO.

    IF NOT wd_itaba2-txdat IS INITIAL.
      WRITE wd_itaba2-txdat TO wa_espt-tglfkt
                            USING EDIT MASK '__/__/____'.
    ENDIF.

    IF NOT ld_sspdt IS INITIAL.
      WRITE ld_sspdt TO wa_espt-tglssp
                     USING EDIT MASK '__/__/____'.
    ENDIF.

    i_espt-data = wa_espt.
    CONDENSE i_espt-data NO-GAPS.

    APPEND i_espt. CLEAR: i_espt.

  ENDLOOP.

  CLEAR i_espt.
  INSERT i_espt INDEX 1.

  DESCRIBE TABLE i_espt LINES cntr.
  IF cntr = 0.
    MESSAGE i000(zf) WITH 'Data Not Found'.
    STOP.
  ENDIF.

  IF error <> 0.
    PERFORM cetak_error.
  ELSE.
    CONCATENATE 'C:\FILEA2_' pa_bukrs '_' pa_monat '.TXT' INTO fname.
*Begin remark Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
*    CALL FUNCTION 'DOWNLOAD'
*      EXPORTING
*        filename         = fname
*      IMPORTING
*        cancel           = canc
*        filesize         = size
*      TABLES
*        data_tab         = i_espt
*      EXCEPTIONS
*        file_open_error  = 1
*        file_write_error = 2.
*
*    IF canc = 'x'.
*      MESSAGE i000(zf) WITH 'Download Cancel by User'.
*    ENDIF.
*
*    IF size NE '0'.
*      MESSAGE i000(zf) WITH 'Download Success'.
*    ENDIF.
*End remark Unicode conversion - DEVK965554

*Begin insert Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
    DATA: lv_filename TYPE string.
    CLEAR lv_filename.
    lv_filename = fname.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_filename
        filetype                = 'TXT'
*      FIELDNAMES              = dwn_field
      CHANGING
        data_tab                = i_espt[]
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
*End insert Unicode conversion - DEVK965554

  ENDIF.

ENDFORM.                    " DOWNLOAD_A2_NEW

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_PC_A2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download_pc_a2.
  DATA: fname(128).

*  IF pa_bukrs EQ '8010'.
*    CALL FUNCTION 'DOWNLOAD'
*      EXPORTING
*        filename         = 'C:\FILEA2.DAT'
*      IMPORTING
*        cancel           = canc
*        filesize         = size
*      TABLES
*        data_tab         = i_itab
*      EXCEPTIONS
*        file_open_error  = 1
*        file_write_error = 2.
*  ELSE.
*    CONCATENATE 'C:\FILEA2_' pa_bukrs '_' pa_monat '.DAT'
*      INTO fname.
*    CALL FUNCTION 'DOWNLOAD'
*      EXPORTING
*        filename         = fname
*      IMPORTING
*        cancel           = canc
*        filesize         = size
*      TABLES
*        data_tab         = i_itabt
*      EXCEPTIONS
*        file_open_error  = 1
*        file_write_error = 2.
*  ENDIF.
*
*  IF canc = 'x'.
*    MESSAGE i000(zf) WITH 'Download Cancel by User'.
*  ENDIF.
*
*  IF size NE '0'.
*    MESSAGE i000(zf) WITH 'Download Success'.
*  ENDIF.

*Begin insert Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
  DATA: lv_filename TYPE string.
  IF pa_bukrs EQ '8010'.
    CLEAR lv_filename.
    lv_filename = 'C:\FILEA2.DAT'.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_filename
        filetype                = 'DAT'
*        FIELDNAMES              = dwn_field
      CHANGING
        data_tab                = i_itab[]
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.
  ELSE.
    CLEAR lv_filename.
    CONCATENATE 'C:\FILEA2_' pa_bukrs '_' pa_monat '.DAT'
          INTO lv_filename.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_filename
        filetype                = 'DAT'
*        FIELDNAMES              = dwn_field
      CHANGING
        data_tab                = i_itabt[]
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.
  ENDIF.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*End insert Unicode conversion - DEVK965554
ENDFORM.                    " F_DOWNLOAD_PC_A2

*&---------------------------------------------------------------------*
*&      Form  GET_UPLOAD_A2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_upload_a2.
  DATA: v_flag_mater(1) TYPE c,
        l_count(5),
        l_count1(5),
        error_count TYPE i,
        l_message(30),
        nomor(5).

  error_count = 0.
  counter = 0.
  counter1 = 0.
  nomor = 0.

  REFRESH i_excel.
* GET MATERIAL NUMBER FROM EXCEL FILE.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_filenm                "INPUT FROM SELECTION SCREEN
      i_begin_col             = 1
      i_begin_row             = 1
      i_end_col               = 14
      i_end_row               = 60000
    TABLES
      intern                  = i_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ELSE.
*     MESSAGE i000(ZF) WITH 'Upload Success'.
  ENDIF.

  SORT i_excel BY row col value.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 30
      text       = text-021
    EXCEPTIONS
      OTHERS     = 1.

  CLEAR id_itaba2.
  CLEAR wa_excel.
* Material Number is at col 3
  v_flag_mater = 'N'.
  LOOP AT i_excel INTO wa_excel.

    ON CHANGE OF wa_excel-row.
      IF v_flag_mater = 'Y'.
        APPEND wd_itaba2 TO id_itaba2.
        CLEAR  wd_itaba2.
      ENDIF.
      v_flag_mater = 'Y'.
    ENDON.

    v_flag_mater = 'Y'.
    IF wa_excel-col = '0001'.
      MOVE wa_excel-value TO wd_itaba2-bukrs.
    ENDIF.
    IF wa_excel-col = '0002'.
      MOVE wa_excel-value TO wd_itaba2-gsber.
    ENDIF.
    IF wa_excel-col = '0003'.
      MOVE wa_excel-value TO wd_itaba2-gjahr.
    ENDIF.
    IF wa_excel-col = '0004'.
      MOVE wa_excel-value TO wd_itaba2-monat.
    ENDIF.
    IF wa_excel-col = '0005'.
      MOVE wa_excel-value TO wd_itaba2-txdat.
    ENDIF.
    IF wa_excel-col = '0006'.
      MOVE wa_excel-value TO wd_itaba2-tbeln.
    ENDIF.
    IF wa_excel-col = '0007'.
      MOVE wa_excel-value TO wd_itaba2-name1.
    ENDIF.
    IF wa_excel-col = '0008'.
      MOVE wa_excel-value TO wd_itaba2-stceg.
    ENDIF.
    IF wa_excel-col = '0009'.
      MOVE wa_excel-value TO wd_itaba2-shkzg.
    ENDIF.
    IF wa_excel-col = '0010'.
      MOVE wa_excel-value TO wd_itaba2-waers.
    ENDIF.
    IF wa_excel-col = '0011'.
      MOVE wa_excel-value TO wd_itaba2-dmbtr.
      wd_itaba2-dmbtr = wd_itaba2-dmbtr / 100.
    ENDIF.
    IF wa_excel-col = '0012'.
      MOVE wa_excel-value TO wd_itaba2-remark.
    ENDIF.
    IF wa_excel-col = '0013'.
      MOVE wa_excel-value TO wd_itaba2-zstatus.
    ENDIF.
    IF wa_excel-col = '0014'.
      MOVE wa_excel-value TO wd_itaba2-stceg1.
    ENDIF.
    CLEAR wa_excel.
  ENDLOOP.

  IF v_flag_mater = 'Y'.
    APPEND wd_itaba2 TO id_itaba2.
    CLEAR  wd_itaba2.
  ENDIF.

  v_flag_mater = 'Y'.

  CLEAR: wd_itaba2.
  LOOP AT id_itaba2 INTO wd_itaba2.
    IF wd_itaba2-tbeln EQ space.
      ADD 1 TO error_count.
      APPEND wd_itaba2 TO i_error.
    ENDIF.

    IF wd_itaba2-zstatus NE '21' AND
       wd_itaba2-zstatus NE '23'.
      ADD 1 TO error_count.
    ENDIF.
    ADD 1 TO counter.
    CLEAR: wd_itaba2.
  ENDLOOP.

  IF error_count EQ 0.
    MOVE counter TO l_count.
    CONCATENATE 'UPLOAD' l_count 'RECORD' INTO l_message
      SEPARATED BY space.
    INSERT zfvata2 FROM TABLE id_itaba2 ACCEPTING DUPLICATE KEYS.
    MESSAGE i000(zf) WITH l_message.
  ELSE.
    MESSAGE i000(zf) WITH 'Upload Error'.
    CLEAR wa_error.
    WRITE: / sy-uline(90),
           /   sy-vline NO-GAP, 'Nomor' NO-GAP,
               sy-vline NO-GAP, 'Company Code' NO-GAP,
               sy-vline NO-GAP, 'Business Area' NO-GAP,
               sy-vline NO-GAP, 'Fiscal Year' NO-GAP,
               sy-vline NO-GAP, 'Period' NO-GAP,
               sy-vline NO-GAP, 'Tax Date' NO-GAP,
            64 sy-vline NO-GAP, 'VAT Out Number' NO-GAP,
            83 sy-vline NO-GAP, 'Status' NO-GAP,
               sy-vline.
    LOOP AT i_error INTO wa_error.
      ADD 1 TO nomor.
      WRITE: / sy-uline(90).
      WRITE: /   sy-vline NO-GAP, nomor NO-GAP,
              7  sy-vline NO-GAP, wa_error-bukrs NO-GAP,
              20 sy-vline NO-GAP, wa_error-gsber NO-GAP,
              34 sy-vline NO-GAP, wa_error-gjahr NO-GAP,
              46 sy-vline NO-GAP, wa_error-monat NO-GAP,
              53 sy-vline NO-GAP, wa_error-txdat NO-GAP,
                 sy-vline NO-GAP, wa_error-tbeln NO-GAP,
                 sy-vline NO-GAP, wa_error-zstatus NO-GAP,
              90 sy-vline NO-GAP.
      CLEAR wa_error.
    ENDLOOP.
    WRITE: / sy-uline(90).
  ENDIF.
ENDFORM.                    " GET_UPLOAD_A2

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_A1_8010
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM download_a1_8010.
  DATA: l_sgtxt LIKE bsas-sgtxt.

  CLEAR: cntr, va_nilppn.

  REFRESH: i_itab.
  CLEAR: wd_itaba1.
  LOOP AT id_itaba1 INTO wd_itaba1.

* KODE LAMPIRAN
    MOVE wd_itaba1-zstatus(1)  TO wa_itab-kdlamp.

* KODE STATUS.
    IF wd_itaba1-zstatus EQ '17'.
      MOVE '1' TO wa_itab-kdstat.
    ELSE.
      MOVE space TO wa_itab-kdstat.
    ENDIF.

* KODE DOKUMEN, NILAI PEROLEHAN
    wd_itaba1-dmbtr = wd_itaba1-dmbtr * 10.
    IF wd_itaba1-shkzg EQ 'S'.
      MOVE '5' TO wa_itab-kddocu.
      WRITE wd_itaba1-dmbtr TO va_nilppn CURRENCY 'IDR' NO-GROUPING.
      SHIFT va_nilppn LEFT DELETING LEADING space.
      CONCATENATE '-' va_nilppn INTO wa_itab-nilppn.
    ELSE.
      MOVE '2' TO wa_itab-kddocu.
      WRITE wd_itaba1-dmbtr TO va_nilppn CURRENCY 'IDR' NO-GROUPING.
      MOVE  va_nilppn       TO wa_itab-nilppn.
    ENDIF.

* NPWP
    IF wa_itab-kddocu EQ '1' OR
      wa_itab-kddocu EQ '3' OR
      wa_itab-kddocu EQ '4'.
      MOVE space TO wa_itab-npwp.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = wd_itaba1-stceg
        IMPORTING
          npwp_out = wa_itab-npwp.
    ENDIF.

* NAMA WAJIB PAJAK
    IF wa_itab-kddocu EQ '1' OR
      wa_itab-kddocu EQ '3' OR
      wa_itab-kddocu EQ '4'.
      MOVE space TO wa_itab-nmwp.
    ELSE.
      MOVE wd_itaba1-name1 TO wa_itab-nmwp.
    ENDIF.

* KODE FAKTUR
    IF wa_itab-kddocu EQ '2' OR
      wa_itab-kddocu EQ '5' OR
      wa_itab-kddocu EQ '6'.
      IF wd_itaba1-shkzg EQ 'H'.
        wa_itab-kdfktr = wd_itaba1-tbeln(9).
      ELSE.
      ENDIF.
    ELSE.
      MOVE space TO wa_itab-kdfktr.
    ENDIF.

* NO. REF. FAKTUR
    IF wa_itab-kddocu EQ '5'.
      IF wd_itaba1-shkzg EQ 'H'.
        MOVE space TO wa_itab-noref.
      ELSE.
        SELECT SINGLE sgtxt
          FROM bsas
          INTO l_sgtxt
          WHERE bukrs EQ pa_bukrs AND
                hkont EQ '0315300100' AND
                zuonr EQ wd_itaba1-tbeln AND
                gjahr EQ pa_gjahr.
        wa_itab-noref = l_sgtxt+10(7).
      ENDIF.
    ELSE.
      MOVE space TO wa_itab-noref.
    ENDIF.

* NO. FAKTUR
    IF wa_itab-kddocu EQ '1' OR
      wa_itab-kddocu EQ '2' OR
      wa_itab-kddocu EQ '3'.
      wa_itab-nofktr = wd_itaba1-tbeln+10(7).
    ELSEIF wa_itab-kddocu EQ '4'.
    ELSEIF wa_itab-kddocu EQ '5'.
      wa_itab-nofktr = wd_itaba1-tbeln.
    ENDIF.

* TANGGAL FAKTUR
    CONCATENATE wd_itaba1-txdat+6(2)
                wd_itaba1-txdat+4(2)
                wd_itaba1-txdat+0(4)
      INTO wa_itab-tglfkt
      SEPARATED BY '/'.

* MASA PAJAK
    MOVE pa_monat TO wa_itab-blnpjk.

* TAHUN PAJAK
    MOVE pa_gjahr TO wa_itab-thnpjk.

* PEMBETULAN
    MOVE pa_betul TO wa_itab-pembtl.

* TARIF PPN
    MOVE '10/100' TO wa_itab-tarif.

* TARIF PPN BM
    MOVE '0' TO wa_itab-nilppnbm.

    IF wd_itaba1-zstatus EQ '11' OR
       wd_itaba1-zstatus EQ '12' OR
       wd_itaba1-zstatus EQ '13' OR
       wd_itaba1-zstatus EQ '17'.
      APPEND wa_itab TO i_itab.
    ENDIF.
    CLEAR: wd_itaba1.
  ENDLOOP.

  DESCRIBE TABLE i_itab LINES cntr.

  IF cntr NE 0.
    PERFORM validasi.
    IF error <> 0.
      PERFORM cetak_error.
    ELSE.
      PERFORM move_to_alv.
*      PERFORM F_DOWNLOAD_PC_A1.
    ENDIF.
  ELSE.
    MESSAGE i000(zf) WITH 'Data Not Found'.
  ENDIF.
ENDFORM.                    " DOWNLOAD_A1_8010

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_A3_8010
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM download_a3_8010.
  CLEAR: cntr, va_nilppn.

  REFRESH: i_itab.
  CLEAR: wd_itaba3.
  LOOP AT id_itaba3 INTO wd_itaba3.

* KODE LAMPIRAN
    MOVE wd_itaba3-zstatus(1)  TO wa_itab-kdlamp.

* KODE STATUS.
    MOVE wd_itaba3-zstatus+1(1) TO wa_itab-kdstat.

* KODE DOKUMEN, NILAI PEROLEHAN
    wd_itaba3-dmbtr = wd_itaba3-dmbtr * 10.
    IF wd_itaba3-shkzg EQ 'S'.
      WRITE wd_itaba3-dmbtr TO va_nilppn CURRENCY 'IDR'.
      SHIFT va_nilppn LEFT DELETING LEADING space.
      CONCATENATE '-' va_nilppn INTO wa_itab-nilppn.
    ELSE.
      WRITE wd_itaba3-dmbtr TO va_nilppn CURRENCY 'IDR'.
      MOVE  va_nilppn       TO wa_itab-nilppn.
    ENDIF.

* NPWP
    IF wa_itab-kddocu EQ '1' OR
      wa_itab-kddocu EQ '3' OR
      wa_itab-kddocu EQ '4'.
      MOVE space TO wa_itab-npwp.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = wd_itaba3-stceg
        IMPORTING
          npwp_out = wa_itab-npwp.
    ENDIF.

* NAMA WAJIB PAJAK
    IF wa_itab-kddocu EQ '1' OR
      wa_itab-kddocu EQ '3' OR
      wa_itab-kddocu EQ '4'.
      MOVE space TO wa_itab-nmwp.
    ELSE.
      MOVE wd_itaba3-name1 TO wa_itab-nmwp.
    ENDIF.

* KODE FAKTUR
    IF wa_itab-kddocu EQ '2' OR
      wa_itab-kddocu EQ '5' OR
      wa_itab-kddocu EQ '6'.
    ELSE.
      MOVE space TO wa_itab-kdfktr.
    ENDIF.

* NO. REF. FAKTUR
    IF wa_itab-kddocu EQ '5'.
    ELSE.
      MOVE space TO wa_itab-noref.
    ENDIF.

* NO. FAKTUR
    IF wa_itab-kddocu EQ '1' OR
      wa_itab-kddocu EQ '2' OR
      wa_itab-kddocu EQ '3'.
    ELSEIF wa_itab-kddocu EQ '4'.
    ENDIF.

* TANGGAL FAKTUR
    CONCATENATE wd_itaba3-txdat+6(2)
                wd_itaba3-txdat+4(2)
                wd_itaba3-txdat+0(4)
      INTO wa_itab-tglfkt
      SEPARATED BY '/'.

* MASA PAJAK
    MOVE pa_monat TO wa_itab-blnpjk.

* TAHUN PAJAK
    MOVE pa_gjahr TO wa_itab-thnpjk.

* PEMBETULAN
    MOVE pa_betul TO wa_itab-pembtl.

* TARIF PPN
    MOVE '10/100' TO wa_itab-tarif.

    IF wd_itaba3-zstatus EQ '30' OR
       wd_itaba3-zstatus EQ '31' OR
       wd_itaba3-zstatus EQ '32'.
      APPEND wa_itab TO i_itab.
    ENDIF.
    CLEAR: wd_itaba3.
  ENDLOOP.

  DESCRIBE TABLE i_itab LINES cntr.

  IF cntr NE 0.
    PERFORM validasi.
    IF error <> 0.
      PERFORM cetak_error.
    ELSE.
      PERFORM f_download_pc_a3.
    ENDIF.
  ELSE.
    MESSAGE i000(zf) WITH 'Data Not Found'.
  ENDIF.
ENDFORM.                    " DOWNLOAD_A3_8010

*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_fieldcat1.
  DATA: xfieldcat TYPE slis_fieldcat_alv.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'KDLAMP'.
  xfieldcat-tabname      = 'TA_EXCEL1'.
  xfieldcat-col_pos      = 1.
  xfieldcat-outputlen    = 8.
  xfieldcat-reptext_ddic = 'Kode Lampiran'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'KDSTAT'.
  xfieldcat-tabname      = 'TA_EXCEL1'.
  xfieldcat-col_pos      = 2.
  xfieldcat-outputlen    = 8.
  xfieldcat-reptext_ddic = 'Kode Status'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'KDDOCU'.
  xfieldcat-tabname      = 'TA_EXCEL1'.
  xfieldcat-col_pos      = 3.
  xfieldcat-outputlen    = 8.
  xfieldcat-reptext_ddic = 'Kode Dokumen'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'NPWP'.
  xfieldcat-tabname      = 'TA_EXCEL1'.
  xfieldcat-col_pos      = 4.
  xfieldcat-outputlen    = 20.
  xfieldcat-reptext_ddic = 'NPWP'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'NMWP'.
  xfieldcat-tabname      = 'TA_EXCEL1'.
  xfieldcat-col_pos      = 5.
  xfieldcat-outputlen    = 30.
  xfieldcat-reptext_ddic = 'Nama WP'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'KDFKTR'.
  xfieldcat-tabname      = 'TA_EXCEL1'.
  xfieldcat-col_pos      = 6.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'Kode Faktur'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'NOREF'.
  xfieldcat-tabname      = 'TA_EXCEL1'.
  xfieldcat-col_pos      = 7.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'No. Ref. Faktur'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'NOFKTR'.
  xfieldcat-tabname      = 'TA_EXCEL1'.
  xfieldcat-col_pos      = 8.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'Nomor Faktur'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'TGLFKT'.
  xfieldcat-tabname      = 'TA_EXCEL1'.
  xfieldcat-col_pos      = 9.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'Tanggal Faktur'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'BLNPJK'.
  xfieldcat-tabname      = 'TA_EXCEL1'.
  xfieldcat-col_pos      = 10.
  xfieldcat-outputlen    = 8.
  xfieldcat-reptext_ddic = 'Masa Pajak'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'THNPJK'.
  xfieldcat-tabname      = 'TA_EXCEL1'.
  xfieldcat-col_pos      = 11.
  xfieldcat-outputlen    = 8.
  xfieldcat-reptext_ddic = 'Tahun Pajak'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'PEMBTL'.
  xfieldcat-tabname      = 'TA_EXCEL1'.
  xfieldcat-col_pos      = 12.
  xfieldcat-outputlen    = 8.
  xfieldcat-reptext_ddic = 'Pembetulan ke'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'TARIF'.
  xfieldcat-tabname      = 'TA_EXCEL1'.
  xfieldcat-col_pos      = 13.
  xfieldcat-outputlen    = 8.
  xfieldcat-reptext_ddic = 'Tarif PPN (Tarif PPN / Tarif Efektif)'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'NILPPN'.
  xfieldcat-tabname      = 'TA_EXCEL1'.
  xfieldcat-col_pos      = 14.
  xfieldcat-outputlen    = 20.
  xfieldcat-decimals_out = '0'.
  xfieldcat-reptext_ddic = 'Nilai Perolehan'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'NILPPNBM'.
  xfieldcat-tabname      = 'TA_EXCEL1'.
  xfieldcat-col_pos      = 15.
  xfieldcat-outputlen    = 20.
  xfieldcat-decimals_out = '0'.
  xfieldcat-reptext_ddic = 'Tarif PPN BM'.
  APPEND xfieldcat TO xit_fieldcat.
ENDFORM.                    " BUILD_FIELDCAT1

*&---------------------------------------------------------------------*
*&      Form  EVENTTAB_BUILD1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
FORM eventtab_build1 USING rt_events TYPE slis_t_event.
*"Registration of events to happen during list display
  DATA: ls_event TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = rt_events.
  READ TABLE rt_events WITH KEY name = slis_ev_top_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE g_top_of_page TO ls_event-form.
    APPEND ls_event TO rt_events.
  ENDIF.
ENDFORM.                    " EVENTTAB_BUILD1

*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOUT  text
*----------------------------------------------------------------------*
FORM layout_init1 USING rs_layout TYPE slis_layout_alv.
*"Build layout for list display
  rs_layout-detail_popup      = 'X'.
  rs_layout-zebra             = 'X'.
ENDFORM.                    " LAYOUT_INIT1

*&---------------------------------------------------------------------*
*&      Form  MOVE_TO_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move_to_alv.
  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab.
    APPEND wa_itab TO ta_excel1.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " MOVE_TO_ALV

*&---------------------------------------------------------------------*
*&      Form  f_download_a1_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download_a1_new.
  DATA: ld_txdat LIKE zfvata1-txdat.

  CONCATENATE pa_gjahr pa_monat '01' INTO ld_txdat.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ld_txdat
    IMPORTING
      last_day_of_month = ld_txdat.

  SELECT *
    FROM zfvata1
    INTO CORRESPONDING FIELDS OF TABLE t_vata1
    WHERE bukrs EQ pa_bukrs AND
          gsber EQ pa_gsber AND
          gjahr EQ pa_gjahr AND
          monat EQ pa_monat.

  SORT t_vata1 BY zstatus.
  LOOP AT t_vata1.
    CASE t_vata1-zstatus.
      WHEN '11'.
        wd_itaba1 = t_vata1.
        IF wd_itaba1-shkzg EQ 'S'.
          wd_itaba1-dmbtr = wd_itaba1-dmbtr * -1.
        ENDIF.

        wd_itaba1-tbeln = space.
        wd_itaba1-txdat = ld_txdat.
        wd_itaba1-shkzg = space.
        wd_itaba1-stceg = space.
        wd_itaba1-name1 = 'Faktur Pajak Sederhana'.
        COLLECT wd_itaba1 INTO id_itaba1.

      WHEN OTHERS.
        wd_itaba1 = t_vata1.
        APPEND wd_itaba1 TO id_itaba1.
    ENDCASE.
  ENDLOOP.

  LOOP AT id_itaba1 INTO wd_itaba1 WHERE zstatus EQ '11'.
    IF wd_itaba1-dmbtr GT 0.
      wd_itaba1-shkzg = 'H'.
    ELSE.
      wd_itaba1-shkzg = 'S'.
    ENDIF.
    MODIFY id_itaba1 FROM wd_itaba1 TRANSPORTING shkzg.
  ENDLOOP.
ENDFORM.                    " f_download_a1_new

*&---------------------------------------------------------------------*
*&      Form  f_get_nota_retur
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_nota_retur.
*  select *
*    from zfppnnrh as a join zfppnnrd as b on a~bukrs eq b~bukrs and
*                                             a~kunnr eq b~kunnr and
*                                             a~monat eq b~monat and
*                                             a~gjahr eq b~gjahr and
*                                             a~nonr  eq b~nonr
*    into corresponding fields of table t_zfppnnrd
*    where a~monat   eq pa_monat and
*          a~gjahr   eq pa_gjahr.
ENDFORM.                    " f_get_nota_retur

*&---------------------------------------------------------------------*
*&      Form  f_insert_a1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_insert_a1.
  INSERT zfvata1.
ENDFORM.                    " f_insert_a1

*&---------------------------------------------------------------------*
*&      Form  f_insert_a2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_insert_a2.
  INSERT zfvata2.
ENDFORM.                    " f_insert_a2

*&---------------------------------------------------------------------*
*&      Form  f_insert_a3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_insert_a3.
  INSERT zfvata3.
ENDFORM.                    " f_insert_a3

*&---------------------------------------------------------------------*
*&      Form  f_modify_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_screen.
  CASE 'X'.
    WHEN radio1.
      LOOP AT SCREEN.
        IF screen-group1 = 'BEL'.
          screen-active  = 1.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN OTHERS.
      LOOP AT SCREEN.
        IF screen-group1 = 'BEL'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_modify_screen

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_ESPT_A1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download_espt_a1 .
  DATA: ld_vatpr LIKE zfvato-vatpr,
        ld_vatno LIKE zfvato-vatno,
        ld_dudat LIKE zfvato-dudat,
        ld_dueyr LIKE zfvato-dueyr,
        ld_duemm LIKE zfvato-duemm,
        ld_sspdt LIKE zfvato-sspdt,
        ld_netwr LIKE zfvato-netwr,
        ld_nonr  LIKE zfppnnrd-nonr,
        fname(128).

  DELETE id_itaba1 WHERE zstatus NE '13'.

  CLEAR: wd_itaba1,i_espt.
  LOOP AT id_itaba1 INTO wd_itaba1.
    CLEAR: ld_vatpr,ld_dudat,ld_dueyr,ld_duemm,ld_sspdt,ld_netwr,
           ld_vatno.
    CLEAR: wa_espt11-kodepjk,wa_espt11-kodelam,wa_espt11-kodests,
           wa_espt11-kodedok,wa_espt11-npwp,wa_espt11-nama,
           wa_espt11-tglfkt,wa_espt11-tglssp,wa_espt11-nodok,wa_espt11-jnsdok,
           wa_espt11-nodok1,wa_espt11-jnsdok1,wa_espt11-masapjk,wa_espt11-thnpjk,
           wa_espt11-betul,wa_espt11-dpp,wa_espt11-ppn,wa_espt11-ppnbm.

    wa_espt11-flagvat  = '0'.

    IF wd_itaba1-tbeln IS INITIAL.
      CONTINUE.
    ELSE.
      WRITE wd_itaba1-tbeln USING EDIT MASK '___.___-__.________' TO wa_espt11-nodok.
    ENDIF.
    wa_espt11-jnsdok   = '0'.

    IF wd_itaba1-stceg1 IS INITIAL.
      CLEAR: wa_espt11-nodok1.
    ELSE.
      WRITE wd_itaba1-stceg1 USING EDIT MASK '___.___-__.________' TO wa_espt11-nodok1.
    ENDIF.
    wa_espt11-jnsdok1  = '0'.

    wa_espt11-kodedok = '1'.

    IF wd_itaba1-shkzg EQ 'S'.
      SELECT SINGLE nonr nrdt gjahr monat dppcn
        INTO (ld_nonr, ld_dudat,ld_dueyr,ld_duemm,ld_netwr)
        FROM zfppnnrd
        WHERE bukrs = wd_itaba1-bukrs AND
              vkbur BETWEEN '0201' AND '0299' AND
              belnr = wd_itaba1-tbeln.
      IF sy-subrc NE 0.
        CONTINUE.
      ELSE.
        wa_espt11-kodedok = '2'.
        wd_itaba1-dmbtr = wd_itaba1-dmbtr * -1.
      ENDIF.
    ENDIF.

    wa_espt11-kodepjk = 'A'.
    wa_espt11-kodelam = '2'.
    wa_espt11-kodests = wd_itaba1-tbeln+1(1).
    IF wa_espt11-kodests EQ '0'.
      wa_espt11-kodests = '1'.
    ENDIF.

    IF wd_itaba1-stceg IS INITIAL.
      wa_espt11-npwp  = '000000000000000'.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = wd_itaba1-stceg
        IMPORTING
          npwp_out = wa_espt11-npwp.
    ENDIF.
    wa_espt11-nama    = wd_itaba1-name1.
    REPLACE ';' WITH space INTO wa_espt11-nama.
    CONCATENATE wd_itaba1-monat wd_itaba1-monat INTO wa_espt11-masapjk.
    wa_espt11-thnpjk  = wd_itaba1-gjahr.
    wa_espt11-betul   = '0'.
    IF wd_itaba1-dmbtr LT 0.
      ld_netwr = wd_itaba1-dmbtr * 1000.
      WRITE ld_netwr TO wa_espt11-dpp
                     USING EDIT MASK '- _____________'
                     DECIMALS 0.

      IF wd_itaba1-dmbtr IS INITIAL.
        wa_espt11-ppn = '0'.
      ELSE.
        wd_itaba1-dmbtr = wd_itaba1-dmbtr * 100.
        WRITE wd_itaba1-dmbtr TO wa_espt11-ppn
                            USING EDIT MASK '- _____________'
                            DECIMALS 0.
      ENDIF.
    ELSE.
      ld_netwr = wd_itaba1-dmbtr * 1000.
      WRITE ld_netwr TO wa_espt11-dpp
                     DECIMALS 0.

      IF wd_itaba1-dmbtr IS INITIAL.
        wa_espt11-ppn = '0'.
      ELSE.
        wd_itaba1-dmbtr = wd_itaba1-dmbtr * 100.
        WRITE wd_itaba1-dmbtr TO wa_espt11-ppn
                            DECIMALS 0.
      ENDIF.
    ENDIF.

    DO 3 TIMES.
      REPLACE '.' WITH space INTO wa_espt11-ppn.
      CONDENSE wa_espt11-ppn NO-GAPS.
      REPLACE '.' WITH space INTO wa_espt11-dpp.
      CONDENSE wa_espt11-dpp NO-GAPS.
    ENDDO.

    wa_espt11-ppnbm   = '0'.

    IF NOT wd_itaba1-txdat IS INITIAL.
      WRITE wd_itaba1-txdat TO wa_espt11-tglfkt
                            USING EDIT MASK '__/__/____'.
    ENDIF.

    IF NOT ld_sspdt IS INITIAL.
      WRITE ld_sspdt TO wa_espt11-tglssp
                     USING EDIT MASK '__/__/____'.
    ENDIF.

    i_espt-data = wa_espt11.
    CONDENSE i_espt-data NO-GAPS.
    APPEND i_espt. CLEAR: i_espt.
  ENDLOOP.

  CLEAR i_espt.
  INSERT i_espt INDEX 1.

  DESCRIBE TABLE i_espt LINES cntr.
  IF cntr = 0.
    MESSAGE i000(zf) WITH 'Data Not Found'.
    STOP.
  ENDIF.

  IF error <> 0.
    PERFORM cetak_error.
  ELSE.
    CONCATENATE 'C:\FILEA1_' pa_bukrs '_' pa_monat '.CSV' INTO fname.
*Begin remark Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
*    CALL FUNCTION 'DOWNLOAD'
*      EXPORTING
*        filename         = fname
*      IMPORTING
*        cancel           = canc
*        filesize         = size
*      TABLES
*        data_tab         = i_espt
*      EXCEPTIONS
*        file_open_error  = 1
*        file_write_error = 2.
*
*    IF canc = 'x'.
*      MESSAGE i000(zf) WITH 'Download Cancel by User'.
*    ENDIF.
*
*    IF size NE '0'.
*      MESSAGE i000(zf) WITH 'Download Success'.
*    ENDIF.
*End remark Unicode conversion - DEVK965554

*Begin insert Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
    DATA: lv_filename TYPE string.
    CLEAR lv_filename.
    lv_filename = fname.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_filename
        filetype                = 'TXT'
*      FIELDNAMES              = dwn_field
      CHANGING
        data_tab                = i_espt[]
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
*End insert Unicode conversion - DEVK965554

  ENDIF.
ENDFORM.                    " F_DOWNLOAD_ESPT_A1

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_ESPT_A3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download_espt_a3 .
  DATA: ld_vatpr LIKE zfvato-vatpr,
        ld_vatno LIKE zfvato-vatno,
        ld_dudat LIKE zfvato-dudat,
        ld_dueyr LIKE zfvato-dueyr,
        ld_duemm LIKE zfvato-duemm,
        ld_sspdt LIKE zfvato-sspdt,
        ld_netwr LIKE zfvato-netwr,
        ld_nonr  LIKE zfppnnrd-nonr,
        fname(128).

  CLEAR: wd_itaba3,i_espt.
  LOOP AT id_itaba3 INTO wd_itaba3.
    CLEAR: ld_vatpr,ld_dudat,ld_dueyr,ld_duemm,ld_sspdt,ld_netwr,
           ld_vatno.
    CLEAR: wa_espt11-kodepjk,wa_espt11-kodelam,wa_espt11-kodests,
           wa_espt11-kodedok,wa_espt11-npwp,wa_espt11-nama,
           wa_espt11-tglfkt,wa_espt11-tglssp,wa_espt11-nodok,wa_espt11-jnsdok,
           wa_espt11-nodok1,wa_espt11-jnsdok1,wa_espt11-masapjk,wa_espt11-thnpjk,
           wa_espt11-betul,wa_espt11-dpp,wa_espt11-ppn,wa_espt11-ppnbm.

    wa_espt11-flagvat  = '0'.

    IF wd_itaba3-tbeln IS INITIAL.
      CONTINUE.
    ELSE.
      WRITE wd_itaba3-tbeln USING EDIT MASK '___.___-__.________' TO wa_espt11-nodok.
    ENDIF.
    wa_espt11-jnsdok   = '0'.

    IF wd_itaba3-stceg1 IS INITIAL.
      CLEAR: wa_espt11-nodok1.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = wd_itaba3-stceg1
        IMPORTING
          npwp_out = wd_itaba3-stceg1.
      WRITE wd_itaba3-stceg1 USING EDIT MASK '__.___.___._-___.___' TO wa_espt11-nodok1.
    ENDIF.
    wa_espt11-jnsdok1  = '0'.

    wa_espt11-kodedok = '1'.

    IF wd_itaba3-shkzg EQ 'S'.
      SELECT SINGLE nrdt gjahr monat dppcn
        INTO (ld_dudat,ld_dueyr,ld_duemm,ld_netwr)
        FROM zfppnnrd
        WHERE bukrs = wd_itaba3-bukrs AND
              vkbur BETWEEN '0201' AND '0299' AND
              belnr = wd_itaba3-tbeln.
      IF sy-subrc NE 0.
        CONTINUE.
      ELSE.
        wa_espt11-kodedok = '2'.
        wd_itaba3-dmbtr = wd_itaba3-dmbtr * -1.
      ENDIF.
    ENDIF.

    wa_espt11-kodepjk = 'A'.
    wa_espt11-kodelam = '2'.
    wa_espt11-kodests = wd_itaba3-tbeln+1(1).
    IF wd_itaba3-stceg IS INITIAL.
      wa_espt11-npwp  = '000000000000000'.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = wd_itaba3-stceg
        IMPORTING
          npwp_out = wa_espt11-npwp.
    ENDIF.
    wa_espt11-nama    = wd_itaba3-name1.
    REPLACE ';' WITH space INTO wa_espt11-nama.
    CONCATENATE wd_itaba3-monat wd_itaba3-monat INTO wa_espt11-masapjk.
    wa_espt11-thnpjk  = wd_itaba3-gjahr.
    wa_espt11-betul   = '0'.

    IF wd_itaba3-dmbtr LT 0.
      ld_netwr = wd_itaba3-dmbtr * 1000.
      WRITE ld_netwr TO wa_espt11-dpp
                              USING EDIT MASK '- _____________'
                     DECIMALS 0.

      IF wd_itaba3-dmbtr IS INITIAL.
        wa_espt11-ppn = '0'.
      ELSE.
        wd_itaba3-dmbtr = wd_itaba3-dmbtr * 100.
        WRITE wd_itaba3-dmbtr TO wa_espt11-ppn
                              USING EDIT MASK '- _____________'
                              DECIMALS 0.
      ENDIF.
    ELSE.
      ld_netwr = wd_itaba3-dmbtr * 1000.
      WRITE ld_netwr TO wa_espt11-dpp
                     DECIMALS 0.

      IF wd_itaba3-dmbtr IS INITIAL.
        wa_espt11-ppn = '0'.
      ELSE.
        wd_itaba3-dmbtr = wd_itaba3-dmbtr * 100.
        WRITE wd_itaba3-dmbtr TO wa_espt11-ppn
                              DECIMALS 0.
      ENDIF.
    ENDIF.

    wa_espt11-ppnbm   = '0'.

    DO 3 TIMES.
      REPLACE '.' WITH space INTO wa_espt11-ppn.
      CONDENSE wa_espt11-ppn NO-GAPS.
      REPLACE '.' WITH space INTO wa_espt11-dpp.
      CONDENSE wa_espt11-dpp NO-GAPS.
    ENDDO.

    IF NOT wd_itaba3-txdat IS INITIAL.
      WRITE wd_itaba3-txdat TO wa_espt11-tglfkt
                            USING EDIT MASK '__/__/____'.
    ENDIF.

    IF NOT ld_sspdt IS INITIAL.
      WRITE ld_sspdt TO wa_espt11-tglssp
                     USING EDIT MASK '__/__/____'.
    ENDIF.

    i_espt-data = wa_espt11.
    CONDENSE i_espt-data NO-GAPS.
    APPEND i_espt. CLEAR: i_espt.
  ENDLOOP.

  CLEAR i_espt.
  INSERT i_espt INDEX 1.

  DESCRIBE TABLE i_espt LINES cntr.
  IF cntr = 0.
    MESSAGE i000(zf) WITH 'Data Not Found'.
    STOP.
  ENDIF.

  IF error <> 0.
    PERFORM cetak_error.
  ELSE.
    CONCATENATE 'C:\FILEA3_' pa_bukrs '_' pa_monat '.CSV' INTO fname.
*Begin remark Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
*    CALL FUNCTION 'DOWNLOAD'
*      EXPORTING
*        filename         = fname
*      IMPORTING
*        cancel           = canc
*        filesize         = size
*      TABLES
*        data_tab         = i_espt
*      EXCEPTIONS
*        file_open_error  = 1
*        file_write_error = 2.
*
*    IF canc = 'x'.
*      MESSAGE i000(zf) WITH 'Download Cancel by User'.
*    ENDIF.
*
*    IF size NE '0'.
*      MESSAGE i000(zf) WITH 'Download Success'.
*    ENDIF.
*End remark Unicode conversion - DEVK965554

*Begin insert Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
    DATA: lv_filename TYPE string.
    CLEAR lv_filename.
    lv_filename = fname.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_filename
        filetype                = 'TXT'
*      FIELDNAMES              = dwn_field
      CHANGING
        data_tab                = i_espt[]
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
*End insert Unicode conversion - DEVK965554

  ENDIF.
ENDFORM.                    " F_DOWNLOAD_ESPT_A3

*&---------------------------------------------------------------------*
*&      Form  F_INSERT_XX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_insert_xx .
  INSERT zfvatxx.
ENDFORM.                    " F_INSERT_XX
