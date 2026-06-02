REPORT zf_recon_tax MESSAGE-ID zs NO STANDARD PAGE HEADING
                                  LINE-COUNT 63(3)
                                  LINE-SIZE  255.
************************************************************************
*                  REPORT                                              *
*----------------------------------------------------------------------*
* ABAP Name   :                                                        *
* Created by  : Sukardi                                                *
* Created on  :                                                        *
* Version     : 0.0                                                    *
*----------------------------------------------------------------------*
* Description :                                                        *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
* Date    Programmer  Correction  Description
*
*----------------------------------------------------------------------*
* DEVK908719
*& CRNO#          DATE         AUTHOR         DESCRIPTION              *
*& DEVK935908     19.08.2013                  Modifikasi untuk SUT     *
*&                                            Project                  *

************************************************************************
* INCLUDES                                                             *
************************************************************************
INCLUDE yf_include_zfvatin.
DATA: va_monat(2),
      va_year(4),
      va_strlen TYPE i,
      va_count TYPE i.

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
        kodethn(9),
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
PARAMETERS : pa_bukrs LIKE bsis-bukrs, " default '8020',
             pa_gsber LIKE bsis-gsber. " DEFAULT '0200'.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(31) text-012.
PARAMETERS : pa_monat LIKE ical_info-month_no DEFAULT sy-datum+4(2).
SELECTION-SCREEN POSITION 42.
PARAMETERS : pa_check AS CHECKBOX.
SELECTION-SCREEN : COMMENT 45(20) text-011.
PARAMETERS : pa_betul(1)  DEFAULT 0.
SELECTION-SCREEN END OF LINE.
PARAMETERS : pa_gjahr LIKE bsis-gjahr DEFAULT sy-datum+0(4),
             pa_date  LIKE sy-datum DEFAULT sy-datum OBLIGATORY,
             pa_post  LIKE sy-datum DEFAULT sy-datum OBLIGATORY.
SELECTION-SCREEN SKIP 1.
PARAMETERS : pa_sign(24) OBLIGATORY DEFAULT sy-uname.
SELECTION-SCREEN END OF BLOCK block1.
*SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF SCREEN 100 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio1 RADIOBUTTON GROUP grp1 DEFAULT 'X'
             USER-COMMAND rad.
SELECTION-SCREEN : COMMENT 5(35) text-003.
SELECTION-SCREEN END OF LINE.
SELECT-OPTIONS:
  so_belnr FOR bsis-belnr MODIF ID bel.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) text-004.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) text-005.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) text-006.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) text-007.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio6 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) text-008.
SELECTION-SCREEN END OF LINE.
*  SELECTION-SCREEN SKIP 1.
PARAMETERS: pa_test DEFAULT 'X' AS CHECKBOX .
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
PARAMETERS : radio10 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(35) text-014 FOR FIELD radio10.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : b1espt11 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(35) text-098 FOR FIELD b1espt11.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : b4espt11 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(35) text-099 FOR FIELD b4espt11.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN END OF SCREEN 200.

SELECTION-SCREEN BEGIN OF SCREEN 300 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio11 RADIOBUTTON GROUP grp3.
SELECTION-SCREEN : COMMENT 5(35) text-015.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio12 RADIOBUTTON GROUP grp3.
SELECTION-SCREEN : COMMENT 5(35) text-016.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b3.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_filenm LIKE rlgrap-filename. "OBLIGATORY.
SELECTION-SCREEN END OF SCREEN 300.

* STANDARD SELECTION SCREEN
SELECTION-SCREEN: BEGIN OF TABBED BLOCK mytab FOR 10 LINES,
                  TAB (20) button1 USER-COMMAND push1,
                  TAB (20) button2 USER-COMMAND push2,
                  TAB (20) button3 USER-COMMAND push3,
                  END OF BLOCK mytab.

*****************************************************
*  Radio1   ---> VAT in Reconciliation
*  Radio2   ---> Print Report B1
*  Radio3   ---> Post to GL Report B1
*  Radio4   ---> Input and Correct Report B4 / B1
*  Radio5   ---> Print Report B4
*  Radio6   ---> Download B1 for TSP
*  Radio7   ---> Download B4 for TSP
*  Radio8   ---> Download B1 for PTT & EC
*  Radio9   ---> Download B4 for PTT & EC
*
*****************************************************

************************************************************************
* PROGRAM                                                              *
************************************************************************
************************************************************************
* AT SELECTION-SCREEN
************************************************************************
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

AT SELECTION-SCREEN ON pa_bukrs.
*  IF pa_bukrs EQ '8020' OR pa_bukrs EQ '8010' OR
*     pa_bukrs EQ '8030' OR pa_bukrs EQ '8070'.
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
*    MESSAGE e000(zs)
*      WITH 'CoCd must be entry 8010, 8020, 8030, 8070'.
*  ENDIF.

AT SELECTION-SCREEN ON pa_gsber.
  SELECT SINGLE * FROM tgsb
         WHERE gsber EQ pa_gsber.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Business Area Not Found'.
  ENDIF.

  IF pa_bukrs EQ '8020'.
    IF pa_gsber NE '0200' AND
      pa_gsber NE '02A1' AND
      pa_gsber NE '02A2' AND
      pa_gsber NE '02B1' AND
      pa_gsber NE 'T220'.
      MESSAGE e000(zs) WITH 'Business Area must be entry 0200'.
    ENDIF.
  ELSEIF pa_bukrs EQ '8030'.
    IF pa_gsber EQ 0 OR pa_gsber EQ space OR pa_gsber+0(2) NE '03'.
      MESSAGE e000(zs) WITH 'Business Area must be entry 03xx'.
    ENDIF.
  ELSEIF pa_bukrs EQ '8010'.
    IF pa_gsber EQ 0 OR pa_gsber EQ space OR pa_gsber+0(2) NE '01'.
      MESSAGE e000(zs) WITH 'Business Area must be entry 01xx'.
    ENDIF.
  ELSEIF pa_bukrs EQ '8070'.
    IF pa_gsber(2) NE '07'.
      MESSAGE e000(zs) WITH 'Business Area must be entry 0700'.
    ENDIF.
  ENDIF.
*AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
*        ID 'GSBER' FIELD pa_gsber
*        ID 'ACTVT' FIELD '01'.
*        IF SY-SUBRC NE 0.
*            MESSAGE E000(zf) WITH
*           'No Authorization For Bussiness Area'
*           pa_gsber.
*        ENDIF.

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

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen.

*---------------------------------------------------------------------*
*       MODULE init_0100 OUTPUT                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
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

*---------------------------------------------------------------------*
*       MODULE user_command_0100 INPUT                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
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
* INITIALIZATION
************************************************************************
INITIALIZATION.
  PERFORM initialize_all.
  button1 = text-100.
  button2 = text-200.
  button3 = text-300.
  mytab-prog = sy-repid.
  mytab-dynnr = 100.
  mytab-activetab = 'BUTTON1'.

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

*  G_REPID = SY-REPID.
*  PERFORM BUILD_FIELDCAT.
*  PERFORM LAYOUT_INIT USING GS_LAYOUT.
*  PERFORM EVENTTAB_BUILD USING GT_EVENTS[].
*  GS_VARIANT-REPORT = G_REPID.
*  G_SAVE            = 'A'.
*  XIS_PRINT-NO_PRINT_SELINFOS  = 'X'.
*  XIS_PRINT-NO_PRINT_LISTINFOS = 'X'.

************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.

  PERFORM cek.
  CLEAR va_xref3.
  IF pa_test = 'X'.
    va_mode = 'N'.
  ELSE.
    va_mode = 'A'.
  ENDIF.

  IF option = 0.
    IF radio1 = 'X'.
      radio9 = space.
      radio10 = space.
      PERFORM f_post_gl.
      DESCRIBE TABLE i_log_error LINES va_ctr.
      IF va_ctr > 0.
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
      CALL SCREEN 900.

**     Call transaction 'SM30'.
*      write pa_monat to va_monat.
*      write pa_gjahr to va_year.
*      Clear i_bdc.
*      PERFORM F_DYNPRO USING:
*         'X'  'SAPMSVMA'     '0100',
*         ' '  'BDC_OKCODE'    '=UPD',
*         ' '  'VIEWNAME'      'ZFVATB1',
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
    ENDIF.

    IF radio3 = 'X'.
      radio9 = space.
      radio10 = space.
      CALL SCREEN 910.

**     Call transaction 'SM30'.
*      write pa_monat to va_monat.
*      write pa_gjahr to va_year.
*      Clear i_bdc.
*      PERFORM F_DYNPRO USING:
*         'X'  'SAPMSVMA'     '0100',
*         ' '  'BDC_OKCODE'    '=UPD',
*         ' '  'VIEWNAME'      'ZFVATB4',
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

    ENDIF.

    IF radio4 = 'X'.
      radio9 = space.
      radio10 = space.
      PERFORM print_b1.
    ENDIF.
    IF radio5 = 'X'.
      radio9 = space.
      radio10 = space.
      PERFORM print_b2.
    ENDIF.
    IF radio6 = 'X'.
      radio9 = space.
      radio10 = space.
      PERFORM print_b4.
    ENDIF.
  ENDIF.

  IF option = 1.
    IF radio7 = 'X'.
      radio9 = space.
      radio10 = space.
      b1espt11 = space.
      b4espt11 = space.
      PERFORM  f_download_b1.
    ENDIF.
    IF radio8 = 'X'.
      radio9 = space.
      radio10 = space.
      b1espt11 = space.
      b4espt11 = space.
      PERFORM f_download_b4.
    ENDIF.

    IF radio9 = 'X'.
      radio7 = space.
      radio8 = space.
      b1espt11 = space.
      b4espt11 = space.
      IF pa_gjahr LT 2004.
* old perform untuk radio9
        PERFORM get_data_b1.
        PERFORM write_data_b1.
      ELSE.
* new perform untuk radio9
        PERFORM f_download_b1.
      ENDIF.
    ENDIF.

    IF radio10 = 'X'.
      radio7 = space.
      radio8 = space.
      b1espt11 = space.
      b4espt11 = space.
      IF pa_gjahr LT 2004.
* old perform untuk radio9
        PERFORM get_data_b4.
        PERFORM write_data_b4.
      ELSE.
* new perform untuk radio9
        PERFORM f_download_b4.
      ENDIF.
    ENDIF.

    IF b1espt11 = 'X'.
      radio7 = space.
      radio8 = space.
      radio9 = space.
      radio10 = space.
      b4espt11 = space.
      PERFORM get_data_b1.
      PERFORM f_download_espt_b1.
    ENDIF.

    IF b4espt11 = 'X'.
      radio7 = space.
      radio8 = space.
      radio9 = space.
      radio10 = space.
      b1espt11 = space.
      PERFORM get_data_b4.
      PERFORM f_download_espt_b4.
    ENDIF.
  ENDIF.


  IF option = 2.
    IF radio11 = 'X'.
      radio9 = space.
      radio10 = space.
      PERFORM get_upload_b1.
    ENDIF.

    IF radio12 = 'X'.
      radio9 = space.
      radio10 = space.
      PERFORM get_upload_b4.
    ENDIF.
  ENDIF.

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

  INCLUDE zfprntb1.
  INCLUDE zfprntb2.
  INCLUDE zfprntb4.

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
      WHEN 'WA_ITAB3-BELNR'.
        SET PARAMETER ID  'BLN' FIELD va_value.
        SET PARAMETER ID  'BUK' FIELD pa_bukrs.
*             set parameter id  'GJR' field pa_gjahr.
        SET PARAMETER ID  'GJR' FIELD wa_itab3-gjahr.
        CALL TRANSACTION 'FB02' AND SKIP FIRST SCREEN.
      WHEN 'WA_ITAB3-LIFNR'.
        SET PARAMETER ID  'LIF' FIELD va_value.
        SET PARAMETER ID  'BUK' FIELD pa_bukrs.
        CALL TRANSACTION 'FK02' AND SKIP FIRST SCREEN.
*        when 'WA_ITAB1-KUNNR'.
*             Set parameter id  'KUN' field va_value.
*             set parameter id  'BUK' field pa_bukrs.
*             call transaction 'XD02' and skip first screen.
*        when 'WA_ZFVATO-KUNRG'.
*             Set parameter id  'KUN' field va_value.
*             set parameter id  'BUK' field pa_bukrs.
*             call transaction 'XD02' and skip first screen.
    ENDCASE.
  ENDIF.

END-OF-SELECTION.

  IF pa_gjahr EQ 2003.
    IF radio9 EQ 'X' OR
       radio10 EQ 'X'.
*  "List Header for Top-Of-Page
      PERFORM comment_build USING gt_list_top_of_page[].
*  "Display List
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
*  "List Header for Top-Of-Page
      PERFORM comment_build USING gt_list_top_of_page[].
*  "Display List
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
  CLEAR: i_itab1, i_itab2, wa_itab1, wa_itab2,
         i_itab3, wa_itab3, i_itab4, wa_itab4,
         i_itab5, wa_itab5.

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
*&      Form  f_post_gl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_gl.
  DATA:
        va_answer,
        BEGIN OF it_message OCCURS 5.
          INCLUDE STRUCTURE popuptext.
  DATA: END OF it_message.
  DATA: l_title(80), i TYPE i, sw(1),
        l_itab LIKE wa_itab3, l_text(20).

  DATA: l_nilai LIKE bsis-dmbtr,
        l_zuonr LIKE bsis-zuonr.

  DATA: tanggal(6).

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
  CLEAR: wa_itab3, sw.
  CONCATENATE pa_gjahr pa_monat INTO tanggal.
  SELECT bukrs gjahr belnr budat bldat xblnr blart monat
           bschl shkzg mwskz dmbtr sgtxt zfbdt zuonr gsber xref3
           INTO CORRESPONDING FIELDS OF wa_itab3
           FROM bsis
           WHERE hkont EQ c_hkont_210  AND
                 bukrs EQ pa_bukrs AND
                 gsber EQ pa_gsber AND
                ( monat EQ pa_monat OR bldat < ta_date-high ) AND
                 gjahr <= pa_gjahr                            AND
                 belnr IN so_belnr.

*            if wa_itab3-bldat+4(2) <= PA_MONAT and
*Koreksi selection untuk pengambilan data dari BSIS, ditambah dengan
*BUDAT
*                wa_itab3-bldat(4)   <= pa_gjahr.
*               wa_itab3-bldat(4)   <= pa_gjahr and
* 12 01 2004
    IF wa_itab3-bldat+0(6) <= tanggal AND
       wa_itab3-budat      < ta_date-high.
      APPEND wa_itab3 TO i_itab3.
      sw = 1.
    ENDIF.
  ENDSELECT.

  IF sw NE 1.
    WRITE: / 'Data not found'.
    EXIT.
  ENDIF.
  SORT i_itab3 BY bukrs gsber gjahr zfbdt zuonr.
  CLEAR: wa_itab3, tot_dmbtr, va_ctr, sw, i.
  LOOP AT i_itab3 INTO wa_itab3.

* ----- validasi untuk clearing document -----
*FI_CLEARED_ACCOUNTS_READ
    CALL FUNCTION 'FI_CLEARED_ACCOUNTS_READ'
      EXPORTING
        i_bukrs         = wa_itab3-bukrs
        i_belnr         = wa_itab3-belnr
        i_gjahr         = wa_itab3-gjahr
        i_cross_company = 'X'
      TABLES
        t_agko          = tab_agko
      EXCEPTIONS
        OTHERS          = 4.

    IF sy-subrc NE 0.
      DELETE i_itab3.
    ELSE.

      sw = 0.
      wa_itab3-zfbdt = wa_itab3-bldat.
      IF wa_itab3-zuonr EQ 'D15'.
*               concatenate wa_itab3-zuonr wa_itab3-XBLNR
        CONCATENATE wa_itab3-zuonr wa_itab3-belnr
   INTO wa_itab3-zuonr SEPARATED BY space.
      ENDIF.
      SELECT SINGLE bktxt INTO wa_itab3-bktxt FROM bkpf
             WHERE bukrs EQ wa_itab3-bukrs AND
                   belnr EQ wa_itab3-belnr AND
                   gjahr EQ wa_itab3-gjahr.

* ---- validasi untuk vendor gabungan dengan ZUONR sama ----
      SELECT SINGLE *
        FROM zfvatb1_temp
        WHERE belnr EQ wa_itab3-belnr AND
              bukrs EQ wa_itab3-bukrs AND
              gjahr EQ wa_itab3-gjahr.

      IF sy-subrc EQ 0.
        ADD wa_itab3-dmbtr TO tot_dmbtr.
        MODIFY i_itab3 FROM wa_itab3.
        APPEND wa_itab3 TO i_itab3a.
* ----- bypass validasi untuk vendor gabungan dengan ZUONR sama
        CONTINUE.
      ELSE.
        IF l_itab-bukrs EQ wa_itab3-bukrs AND
           l_itab-gsber EQ wa_itab3-gsber AND
           l_itab-gjahr EQ wa_itab3-gjahr AND
           l_itab-zfbdt EQ wa_itab3-zfbdt AND
           l_itab-zuonr EQ wa_itab3-zuonr AND
           l_itab-bktxt EQ wa_itab3-bktxt.
          sw = 1.
          ADD 1 TO va_ctr.
          wa_itab3-error = 'Data Double'.
          APPEND wa_itab3 TO i_itab3_err.
          l_itab-error = 'Data Double'.
          APPEND l_itab   TO i_itab3_err.
          CLEAR l_itab.
          CLEAR wa_itab3.
          CONTINUE.
        ENDIF.

        SELECT SINGLE * FROM  zfvatb1
               WHERE bukrs EQ wa_itab3-bukrs AND
                     gsber EQ wa_itab3-gsber AND
                     gjahr EQ wa_itab3-gjahr AND
*                        MONAT eq pa_monat       and
                     txdat EQ wa_itab3-zfbdt AND
                     tbeln EQ wa_itab3-zuonr AND
                     stceg EQ wa_itab3-bktxt.
        IF sy-subrc EQ 0.
          sw = 1.
        ENDIF.
        IF sw = 1.
          ADD 1 TO va_ctr.
          wa_itab3-error = 'Data Double dengan database'.
          APPEND wa_itab3 TO i_itab3_err.
        ENDIF.
        MODIFY i_itab3 FROM wa_itab3.
        APPEND wa_itab3 TO i_itab3b.
        IF wa_itab3-shkzg = 'H'.
          wa_itab3-dmbtr = wa_itab3-dmbtr * -1.
        ENDIF.
        ADD wa_itab3-dmbtr TO tot_dmbtr.
        MOVE-CORRESPONDING wa_itab3 TO l_itab.
        CLEAR wa_itab3.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF va_ctr > 0.
    CLEAR it_message.
    it_message-text = 'Masih ada data yang Double'.
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
    PERFORM f_init_column.
    FORMAT COLOR 5.
    c1 =  w1 + w2 + w3 + w4 + w5 + w6 + w7 + w9 + w10 + 8.
    NEW-PAGE.
    l_title = 'List Document VAT-IN Masih ada kesalahan'.
    WRITE: AT 2(c1) l_title CENTERED.
    PERFORM f_print_column_header.

    SORT i_itab3b BY bukrs gsber gjahr zfbdt zuonr.
    CLEAR: wa_itab3, tot_dmbtr, va_ctr, sw.
    LOOP AT i_itab3_err INTO wa_itab3.
      ADD 1 TO va_ctr.
      sw = va_ctr MOD 2.
      IF sw = 0.
        FORMAT COLOR 2.
        FORMAT INTENSIFIED OFF.
      ELSE.
        FORMAT COLOR 1.
        FORMAT INTENSIFIED OFF.
      ENDIF.
      IF wa_itab3-shkzg = 'H'.
        wa_itab3-dmbtr = wa_itab3-dmbtr * -1.
      ENDIF.
      PERFORM f_print_detail.
      c1 = 1.
      tot_dmbtr = tot_dmbtr + wa_itab3-dmbtr.
      CLEAR wa_itab3.
    ENDLOOP.
    PERFORM f_print_footer.

  ELSE.

* ------------ FB09 Posting & Insert to ZFVATB1

    CLEAR it_message.
    it_message-text = 'Data Siap untuk Post to GL'.
    APPEND it_message.
    it_message-text = 'Pilih Cancel untuk Kembali Menu awal'.
    APPEND it_message.
    it_message-text = 'Pilih Continue untuk Post to GL'.
    APPEND it_message.
    WRITE tot_dmbtr TO l_text DECIMALS 0 CURRENCY 'IDR'.
    CONCATENATE 'Value untuk Post to GL : ' l_text INTO
    it_message-text SEPARATED BY space.
    APPEND it_message.

    CALL FUNCTION 'DD_POPUP_WITH_INFOTEXT'
      EXPORTING
        titel        = 'Post to GL'
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
    PERFORM f_init_column.
    FORMAT COLOR 5.
    c1 =  w1 + w2 + w3 + w4 + w5 + w6 + w7 + w9 + w10 + 8.
    NEW-PAGE.
    l_title = 'List Document VAT-IN Yang Sudah di Posting'.
    WRITE: AT 2(c1) l_title CENTERED.
    PERFORM f_print_column_header.

    va_ctr = 0.
    tot_dmbtr = 0.
    grand_dmbtr = 0.

    CLEAR wa_itab3.
    LOOP AT i_itab3 INTO wa_itab3.
      ADD 1 TO va_ctr.
      sw = va_ctr MOD 2.
      IF sw = 0.
        FORMAT COLOR 2.
        FORMAT INTENSIFIED OFF.
      ELSE.
        FORMAT COLOR 1.
        FORMAT INTENSIFIED OFF.
      ENDIF.

      CASE wa_itab3-xref3+0(2).
        WHEN '41'.
          CONCATENATE wa_itab3-xref3+0(2) 'B1' pa_monat
              INTO va_xref341 SEPARATED BY '|'.
        WHEN '42'.
          CONCATENATE wa_itab3-xref3+0(2) 'B1' pa_monat
              INTO va_xref342 SEPARATED BY '|'.
        WHEN '43'.
          CONCATENATE wa_itab3-xref3+0(2) 'B1' pa_monat
              INTO va_xref343 SEPARATED BY '|'.
        WHEN '44'.
          CONCATENATE wa_itab3-xref3+0(2) 'B1' pa_monat
              INTO va_xref344 SEPARATED BY '|'.
        WHEN '45'.
          CONCATENATE wa_itab3-xref3+0(2) 'B1' pa_monat
              INTO va_xref345 SEPARATED BY '|'.
        WHEN '46'.
          CONCATENATE wa_itab3-xref3+0(2) 'B1' pa_monat
              INTO va_xref346 SEPARATED BY '|'.
        WHEN '47'.
          CONCATENATE wa_itab3-xref3+0(2) 'B1' pa_monat
              INTO va_xref347 SEPARATED BY '|'.
        WHEN '48'.
          CONCATENATE wa_itab3-xref3+0(2) 'B1' pa_monat
              INTO va_xref348 SEPARATED BY '|'.
        WHEN '49'.
          CONCATENATE wa_itab3-xref3+0(2) 'B1' pa_monat
              INTO va_xref349 SEPARATED BY '|'.
        WHEN OTHERS.
          wa_itab3-xref3+0(2) = '47'.
          CONCATENATE wa_itab3-xref3+0(2) 'B1' pa_monat
             INTO va_xref347 SEPARATED BY '|'.
      ENDCASE.

      DELETE FROM zfvatb1_temp WHERE bukrs EQ wa_itab3-bukrs AND
                                     gsber EQ wa_itab3-gsber AND
                                     gjahr EQ pa_gjahr       AND
                                     monat EQ pa_monat       AND
                                     belnr EQ wa_itab3-belnr.

      MOVE wa_itab3-bukrs TO zfvatb1-bukrs.
*           move WA_ITAB3-gjahr to zfvatb1-gjahr.
      MOVE pa_gjahr       TO zfvatb1-gjahr.
      MOVE wa_itab3-gsber TO zfvatb1-gsber.
      MOVE 'IDR'          TO zfvatb1-waers.
*           move WA_ITAB3-dmbtr to zfvatb1-MWSBK.
      MOVE wa_itab3-zuonr TO zfvatb1-tbeln.
      MOVE wa_itab3-bldat TO zfvatb1-txdat.
      MOVE wa_itab3-sgtxt TO zfvatb1-name1.
      MOVE wa_itab3-bktxt TO zfvatb1-stceg.
      MOVE wa_itab3-shkzg TO zfvatb1-shkzg.
      MOVE wa_itab3-xref3+0(2) TO zfvatb1-zstatus.
      MOVE pa_monat       TO zfvatb1-monat.

      IF l_zuonr NE wa_itab3-zuonr.
        MOVE wa_itab3-dmbtr TO zfvatb1-mwsbk.
        MOVE wa_itab3-zuonr TO l_zuonr.
        INSERT zfvatb1.
      ELSE.
        ADD wa_itab3-dmbtr TO zfvatb1-mwsbk.
        MOVE wa_itab3-zuonr TO l_zuonr.
        MODIFY zfvatb1.
      ENDIF.

      IF wa_itab3-shkzg = 'H'.
        wa_itab3-dmbtr = wa_itab3-dmbtr * -1.
      ENDIF.

      PERFORM f_print_detail.
      ADD wa_itab3-dmbtr TO tot_dmbtr.
      CONCATENATE wa_itab3-xref3+0(2)
                  'B1'
                  pa_monat
                  INTO wa_itab3-xref3 SEPARATED BY '|'.
      PERFORM f_post_fb09.

      IF va_ctr = 900.
        grand_dmbtr = grand_dmbtr +  tot_dmbtr.
        IF tot_dmbtr < 0.
          tot_dmbtr  = tot_dmbtr  * -1.
          va_bschl = '50'.
        ELSE.
          va_bschl = '40'.
        ENDIF.
        break tds_dev01.
        PERFORM f_prosess_itab3.
        tot_dmbtr = 0.
        va_ctr = 0.
      ENDIF.
      CLEAR wa_itab3.
    ENDLOOP.

    grand_dmbtr = grand_dmbtr +  tot_dmbtr.
    c1 = 1.
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
*          write at c1(w7) 'Total Value : ' no-gap.
    c1 = c1 + w7.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE: / sy-uline.

*       Perform f_print_footer.
    WRITE: / 'Total Line item : ', va_ctr.
    IF va_ctr = 0.
      EXIT.
    ENDIF.
    IF tot_dmbtr < 0.
      tot_dmbtr  = tot_dmbtr  * -1.
      va_bschl = '50'.
    ELSE.
      va_bschl = '40'.
    ENDIF.
*       break-point.
    break tds_dev01.
    PERFORM f_prosess_itab3.
  ENDIF.
ENDFORM.                    " f_post_gl

*&---------------------------------------------------------------------*
*&      Form  f_prosess_itab3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prosess_itab3.
  DATA: l_ctr TYPE i.
  l_ctr = 0.
  DESCRIBE TABLE i_itab3 LINES l_ctr.
  IF l_ctr > 0.
    PERFORM f_post_f04.
  ENDIF.

ENDFORM.                    " f_prosess_itab3

*&---------------------------------------------------------------------*
*&      Form  f_post_f04
*&---------------------------------------------------------------------*
FORM f_post_f04.
  DATA:  l_value(15),
        l_date(10),
        l_date1(10),
        l_mess(50),
        l_monat(2),
        l_year(4),
        l_answer,
        l_text(20),
        text LIKE spop-varvalue1. " sy-datum.

  l_answer = 'N'.
  va_hkont1 = c_hkont_220.
  va_hkont2 = c_hkont_210.
  WRITE pa_monat TO l_monat.
  IF l_monat EQ 0.
    WRITE sy-datum+4(2) TO l_monat.
  ENDIF.

  WRITE pa_gjahr TO l_year.
  IF l_year EQ 0.
    WRITE sy-datum+0(4) TO l_year.
  ENDIF.

  WRITE pa_post TO l_date.
  WRITE tot_dmbtr TO l_value DECIMALS 0 CURRENCY 'IDR'.
  CONCATENATE 'FORM B1' l_monat l_year INTO l_mess
       SEPARATED BY space.

  CLEAR i_bdc.
  PERFORM f_dynpro USING:
        'X'  'SAPMF05A'     '0122',
        ' '  'BDC_OKCODE'    '=SL',
        ' '  'BKPF-BLDAT'   l_date,
        ' '  'BKPF-BUDAT'   l_date,
        ' '  'BKPF-XBLNR'   wa_itab1-belnr,
        ' '  'BKPF-BLART'   'SA',
        ' '  'BKPF-MONAT'    l_monat,
        ' '  'BKPF-BUKRS'   pa_bukrs,
        ' '  'BKPF-WAERS'   'IDR',
        ' '  'BKPF-XBLNR'   l_mess,
        ' '  'RF05A-AUGTX'   'VAT - input Post to GL',
        ' '  'RF05A-NEWBS'  va_bschl,
        ' '  'RF05A-NEWKO'  va_hkont1,
        'X'  'SAPMF05A'     '0300',
        ' '  'BDC_OKCODE'    '=SL',
        ' '  'BSEG-WRBTR'   l_value,
        ' '  'BSEG-ZUONR'   l_mess,
        ' '  'BSEG-SGTXT'   l_mess,
        ' '  'BDC_OKCODE'   '=ZK',
        'X'  'SAPLKACB'     '0002',
        ' '  'BDC_OKCODE'   '=ENTE',
        ' '  'COBL-GSBER'   pa_gsber,
        'X'  'SAPMF05A'     '0330',
        ' '  'BDC_OKCODE'   '/00',
        ' '  'BSEG-XREF3'   va_xref3,
        ' '  'BDC_OKCODE'   '=PA',
        'X'  'SAPMF05A'     '0710',
        ' '  'BDC_OKCODE'   '=PA',
        ' '  'RF05A-AGBUK'  pa_bukrs,
        ' '  'RF05A-AGKON'  va_hkont2,  "'0142200200',
        ' '  'RF05A-AGKOA'     'S',
        ' '  'RF05A-XAUTS'     'X',
        ' '  'RF05A-XPOS1(01)'  ' ',
        ' '  'RF05A-XPOS1(12)'  'X',
        'X'  'SAPMF05A'       '0731',
        ' '  'BDC_OKCODE'     '=PA',
        ' '  'RF05A-SEL01(01)'  va_xref341,
        ' '  'RF05A-SEL01(02)'  va_xref342,
        ' '  'RF05A-SEL01(03)'  va_xref343,
        ' '  'RF05A-SEL01(04)'  va_xref344,
        ' '  'RF05A-SEL01(05)'  va_xref345,
        ' '  'RF05A-SEL01(06)'  va_xref346,
        ' '  'RF05A-SEL01(07)'  va_xref347,
        ' '  'RF05A-SEL01(08)'  va_xref348,
        ' '  'RF05A-SEL01(09)'  va_xref349,
        'X'  'SAPDF05X'         '3100',
        ' '  'BDC_OKCODE'       '=BU'.
  CALL TRANSACTION 'F-04' USING i_bdc MODE va_mode UPDATE 'S'
                     MESSAGES INTO i_messtab.

  IF sy-subrc NE 0.
    CLEAR wa_itab3.
    LOOP AT i_itab3b INTO wa_itab3.
*           BREAK TDS_DEV01.
      DELETE FROM zfvatb1 WHERE bukrs EQ wa_itab3-bukrs AND
                           gsber EQ wa_itab3-gsber AND
                           gjahr EQ wa_itab3-gjahr AND
                           tbeln EQ wa_itab3-zuonr AND
                           txdat EQ wa_itab3-bldat AND
                           monat EQ pa_monat.
      wa_itab3-xref3 = wa_itab3-xref3+0(2).
      PERFORM f_post_fb09.
      CLEAR wa_itab3.
    ENDLOOP.

    CLEAR wa_itab3.
    LOOP AT i_itab3a INTO wa_itab3.
*           BREAK TDS_DEV01.
      DELETE FROM zfvatb1 WHERE bukrs EQ wa_itab3-bukrs AND
                           gsber EQ wa_itab3-gsber AND
                           gjahr EQ wa_itab3-gjahr AND
                           tbeln EQ wa_itab3-zuonr AND
                           txdat EQ wa_itab3-bldat AND
                           monat EQ pa_monat.
      wa_itab3-xref3 = wa_itab3-xref3+0(2).
      PERFORM f_post_fb09.
      CLEAR wa_itab3.
    ENDLOOP.

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
  ENDIF.

ENDFORM.                    " f_post_clearing_vatin

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
*&      Form  f_download_b1
*&---------------------------------------------------------------------*
FORM f_download_b1.
  PERFORM get_data_b1.
*    MOVE '4' TO VA_KDLAMP.
  IF pa_bukrs EQ '8010'.
    PERFORM download_b1_8010.
  ELSE.
    IF pa_gjahr GT 2006.
      PERFORM download_b1_new.
    ELSE.
      PERFORM download_b1.
    ENDIF.
  ENDIF.

ENDFORM.                    " f_download_b1
*&---------------------------------------------------------------------*
*&      Form  f_download_b4
*&---------------------------------------------------------------------*
FORM f_download_b4.
  PERFORM get_data_b4.
*    MOVE '7' TO VA_KDLAMP.
  IF pa_bukrs EQ '8010'.
    PERFORM download_b4_8010.
  ELSE.
    IF pa_gjahr GT 2006.
      PERFORM download_b4_new.
    ELSE.
      PERFORM download_b4.
    ENDIF.
  ENDIF.

ENDFORM.                    " f_download_b4

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_B1
*&---------------------------------------------------------------------*
FORM get_data_b1.
  SELECT * FROM zfvatb1
    INTO CORRESPONDING FIELDS OF TABLE i_itabb1
    WHERE bukrs EQ pa_bukrs AND
          gsber EQ pa_gsber AND
          gjahr EQ pa_gjahr AND
          monat EQ pa_monat.
ENDFORM.                    " GET_DATA_B1

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_B4
*&---------------------------------------------------------------------*
FORM get_data_b4.
  SELECT * FROM zfvatb4
    INTO CORRESPONDING FIELDS OF TABLE i_itabb4
    WHERE bukrs EQ pa_bukrs AND
          gsber EQ pa_gsber AND
          gjahr EQ pa_gjahr AND
          monat EQ pa_monat.

ENDFORM.                    " GET_DATA_B4
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_B1
*&---------------------------------------------------------------------*
FORM download_b1.
  DATA: l_text(7),
        l_stat(2),
        l_stat1(2).
  DATA: l_npwp LIKE zfvatb1-stceg,
        l_nofak(10).

  ta_date-sign   = 'I'.
  ta_date-option = 'BT'.
  CONCATENATE pa_gjahr pa_monat '01' INTO ta_date-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ta_date-low
    IMPORTING
      last_day_of_month = ta_date-high.
  APPEND ta_date.

  CLEAR: wa_itabb1, i_itab.
  LOOP AT i_itabb1 INTO wa_itabb1.

    MOVE wa_itabb1-zstatus TO l_stat.
    MOVE l_stat(1) TO va_kdlamp.
    MOVE l_stat+1(1) TO va_kdstat.

    SELECT SINGLE zstatus1
      FROM zfpajak
      INTO l_stat1
      WHERE bukrs EQ pa_bukrs AND
            zstatus EQ wa_itabb1-zstatus.
    MOVE l_stat1+1(1) TO va_kddocu.

    IF wa_itabb1-txdat > ta_date-high.
      CONTINUE.
    ENDIF.

    CASE wa_itabb1-zstatus.
      WHEN '41'.
*        MOVE '1' TO VA_KDSTAT.
        MOVE  wa_itabb1-stceg TO l_npwp.

      WHEN '42'.
*        MOVE '2' TO VA_KDSTAT.
        MOVE  wa_itabb1-stceg TO l_npwp.

      WHEN '43'.
*        MOVE '3' TO VA_KDSTAT.
        MOVE  wa_itabb1-stceg TO l_npwp.

      WHEN '44'.
*        MOVE '4' TO VA_KDSTAT.
        MOVE  wa_itabb1-stceg TO l_npwp.

      WHEN '45'.
*        MOVE '5' TO VA_KDSTAT.
        MOVE  wa_itabb1-stceg TO l_npwp.

      WHEN '46'.
*        MOVE '6' TO VA_KDSTAT.
        MOVE  wa_itabb1-stceg TO l_npwp.

      WHEN '47'.
*        MOVE '7' TO VA_KDSTAT.
        MOVE  wa_itabb1-stceg TO l_npwp.

      WHEN '48'.
*        MOVE '8' TO VA_KDSTAT.
        MOVE  wa_itabb1-stceg TO l_npwp.

      WHEN '49'.
*        MOVE '9' TO VA_KDSTAT.
        MOVE  wa_itabb1-stceg TO l_npwp.

      WHEN '50'.
*        MOVE '9' TO VA_KDSTAT.
        MOVE  wa_itabb1-stceg TO l_npwp.

      WHEN '51'.
*        MOVE '9' TO VA_KDSTAT.
        MOVE  wa_itabb1-stceg TO l_npwp.
    ENDCASE.

    MOVE  wa_itabb1-name1 TO va_nmwp.
*    MOVE '1' TO VA_KDDOCU.

*   VALIDASI FOR STATUS '41' '42' '50' '51'
    IF wa_itabb1-zstatus EQ '41' OR
       wa_itabb1-zstatus EQ '42' OR
       wa_itabb1-zstatus EQ '50' OR
       wa_itabb1-zstatus EQ '51'.
      va_kdfktr = space.
    ELSE.
      MOVE wa_itabb1-tbeln+0(5) TO va_kdfktr.
    ENDIF.

    IF va_kdfktr EQ 'PIBNO'.
      WRITE wa_itabb1-tbeln+7(7) TO l_text. "VA_NOFKTR RIGHT-JUSTIFIED.
    ELSE.
      WRITE wa_itabb1-tbeln+10(8) TO l_text. "VA_NOFKTR RIGHT-JUSTIFIED.
    ENDIF.

    v_len = STRLEN( l_text ).
    v_space = 7 - v_len.
    DO v_space TIMES.
      CONCATENATE '0' l_text INTO l_text.
    ENDDO.
*     write l_text  to VA_NOFKTR RIGHT-JUSTIFIED.
    CONCATENATE wa_itabb1-txdat+6(2)
                 wa_itabb1-txdat+4(2)
                 wa_itabb1-txdat+0(4)
           INTO  va_tglfkt SEPARATED BY '-'.
    wa_itabb1-mwsbk = wa_itabb1-mwsbk * 100.

    IF wa_itabb1-shkzg EQ 'H'.
      IF wa_itabb1-zstatus EQ '43' OR
         wa_itabb1-zstatus EQ '44'.
        MOVE '4' TO va_kddocu.
      ENDIF.
      IF wa_itabb1-mwsbk < 0.
        wa_itabb1-mwsbk = wa_itabb1-mwsbk * -1.
      ENDIF.
      WRITE wa_itabb1-mwsbk TO va_nilppn DECIMALS 0 NO-GROUPING.
      SHIFT va_nilppn LEFT DELETING LEADING space.
      CONCATENATE '-' va_nilppn INTO va_nilppn.
      IF pa_bukrs EQ '8010'.
        WRITE  va_nilppn       TO wa_itab-nilppn RIGHT-JUSTIFIED.
      ELSE.
        WRITE  va_nilppn       TO wa_itabt-nilppn RIGHT-JUSTIFIED.
      ENDIF.
    ELSE.
      WRITE wa_itabb1-mwsbk TO va_nilppn RIGHT-JUSTIFIED
      DECIMALS 0 NO-GROUPING.
      IF pa_bukrs EQ '8010'.
        WRITE  va_nilppn       TO wa_itab-nilppn RIGHT-JUSTIFIED.
      ELSE.
        WRITE  va_nilppn       TO wa_itabt-nilppn RIGHT-JUSTIFIED.
      ENDIF.
    ENDIF.

*    WRITE WA_ITABB1-MWSBK TO VA_NILPPN RIGHT-JUSTIFIED.
    WRITE space TO va_nilppnbm RIGHT-JUSTIFIED.
    WRITE pa_betul TO va_betul LEFT-JUSTIFIED.

    IF pa_bukrs EQ '8010'.
      MOVE  wa_itabb1-gjahr TO wa_itab-thnpjk.
      MOVE  wa_itabb1-monat TO wa_itab-blnpjk.
      MOVE  va_betul        TO wa_itab-pembtl.
      MOVE  va_kdlamp       TO wa_itab-kdlamp.
      MOVE  va_kdstat       TO wa_itab-kdstat.
    ELSE.
      MOVE  wa_itabb1-gjahr TO wa_itabt-thnpjk.
      MOVE  wa_itabb1-monat TO wa_itabt-blnpjk.
      MOVE  va_betul        TO wa_itabt-pembtl.
      MOVE  va_kdlamp       TO wa_itabt-kdlamp.
      MOVE  va_kdstat       TO wa_itabt-kdstat.
    ENDIF.

    IF va_npwp EQ space.
      MOVE '000000000000000' TO  va_npwp.
    ENDIF.

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

    IF wa_itabb1-zstatus EQ '41' OR
       wa_itabb1-zstatus EQ '42' OR
       wa_itabb1-zstatus EQ '50' OR
       wa_itabb1-zstatus EQ '51'.
      WRITE wa_itabb1-tbeln TO va_nofktr RIGHT-JUSTIFIED.
    ELSE.
      CONCATENATE l_npwp+13(3) l_text INTO l_nofak.
      WRITE l_nofak  TO va_nofktr RIGHT-JUSTIFIED.
    ENDIF.

    IF pa_bukrs EQ '8010'.
      MOVE  va_npwp         TO wa_itab-npwp.
      MOVE  va_nmwp         TO wa_itab-nmwp.
      MOVE  va_kddocu       TO wa_itab-kddocu.
      MOVE  va_kdfktr       TO wa_itab-kdfktr.
      MOVE  va_nofktr       TO wa_itab-nofktr.
      WRITE va_tglfkt       TO wa_itab-tglfkt.
      MOVE  va_nilppnbm     TO wa_itab-nilppnbm.

      IF wa_itabb1-zstatus EQ '41' OR
         wa_itabb1-zstatus EQ '42' OR
         wa_itabb1-zstatus EQ '43' OR
         wa_itabb1-zstatus EQ '44' OR
         wa_itabb1-zstatus EQ '45' OR
         wa_itabb1-zstatus EQ '46' OR
         wa_itabb1-zstatus EQ '47' OR
         wa_itabb1-zstatus EQ '48' OR
         wa_itabb1-zstatus EQ '49' OR
         wa_itabb1-zstatus EQ '50' OR
         wa_itabb1-zstatus EQ '51'.
        APPEND wa_itab TO i_itab.
      ENDIF.
    ELSE.
      IF va_npwp EQ space.
        wa_itabt-npwp = '000000000000000'.
      ELSE.
        MOVE  va_npwp         TO wa_itabt-npwp.
      ENDIF.
      MOVE  va_nmwp         TO wa_itabt-nmwp.
      MOVE  va_kddocu       TO wa_itabt-kddocu.
      MOVE  va_kdfktr       TO wa_itabt-kdfktr.
      MOVE  wa_itabb1-tbeln+6(3) TO wa_itabt-kdkpp.
      IF wa_itabt-kdkpp EQ space.
        wa_itabt-kdkpp = '000'.
      ENDIF.
      IF wa_itabb1-shkzg EQ 'H'.
        MOVE space TO wa_itabt-kdfktr.
        MOVE space TO wa_itabt-kdkpp.
        MOVE wa_itabb1-tbeln TO wa_itabt-nofktr.
      ELSE.
        MOVE  va_nofktr+23(7) TO wa_itabt-nofktr.
      ENDIF.
      WRITE va_tglfkt       TO wa_itabt-tglfkt.
      MOVE  va_nilppnbm     TO wa_itabt-nilppnbm.

      IF wa_itabb1-zstatus EQ '41' OR
         wa_itabb1-zstatus EQ '42' OR
         wa_itabb1-zstatus EQ '43' OR
         wa_itabb1-zstatus EQ '44' OR
         wa_itabb1-zstatus EQ '45' OR
         wa_itabb1-zstatus EQ '46' OR
         wa_itabb1-zstatus EQ '47' OR
         wa_itabb1-zstatus EQ '48' OR
         wa_itabb1-zstatus EQ '49' OR
         wa_itabb1-zstatus EQ '50' OR
         wa_itabb1-zstatus EQ '51'.
        APPEND wa_itabt TO i_itabt.
      ENDIF.
    ENDIF.

    CLEAR: l_stat, l_stat1.

    CLEAR: wa_itabb1, va_kdstat, va_npwp, va_nmwp,
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
      PERFORM f_download_pc_b1.
    ENDIF.
  ELSE.
    MESSAGE i000(zm) WITH 'Data not found'.
  ENDIF.
  CLEAR: cntr.

ENDFORM.                    " DOWNLOAD_B1

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_B1_NEW
*&---------------------------------------------------------------------*
FORM download_b1_new.

  DATA: ld_vatpr LIKE zfvato-vatpr,
        ld_vatno LIKE zfvato-vatno,
        ld_dudat LIKE zfvato-dudat,
        ld_dueyr LIKE zfvato-dueyr,
        ld_duemm LIKE zfvato-duemm,
        ld_sspdt LIKE zfvato-sspdt,
        ld_netwr LIKE zfvato-netwr,
        fname(128).

  ta_date-sign   = 'I'.
  ta_date-option = 'BT'.
  CONCATENATE pa_gjahr pa_monat '01' INTO ta_date-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ta_date-low
    IMPORTING
      last_day_of_month = ta_date-high.
  APPEND ta_date.

  CLEAR: wa_itabb1,i_espt,i_itab.
  LOOP AT i_itabb1 INTO wa_itabb1.

    CLEAR: ld_vatpr,ld_dudat,ld_dueyr,ld_duemm,ld_sspdt,ld_netwr,
           ld_vatno.

    CLEAR: wa_espt-kodepjk,wa_espt-kodelam,wa_espt-kodests,
           wa_espt-kodedok,wa_espt-npwp,wa_espt-nama,wa_espt-kodecab,
           wa_espt-kodethn,wa_espt-nofkt,wa_espt-tglfkt,wa_espt-tglssp,
           wa_espt-masapjk,wa_espt-thnpjk,wa_espt-betul,wa_espt-dpp,
           wa_espt-ppn,wa_espt-ppnbm.

    IF wa_itabb1-zstatus EQ '41' OR
       wa_itabb1-zstatus EQ '42' OR
       wa_itabb1-zstatus EQ '43' OR
       wa_itabb1-zstatus EQ '44' OR
       wa_itabb1-zstatus EQ '45' OR
       wa_itabb1-zstatus EQ '46' OR
       wa_itabb1-zstatus EQ '47' OR
       wa_itabb1-zstatus EQ '48' OR
       wa_itabb1-zstatus EQ '49' OR
       wa_itabb1-zstatus EQ '50' OR
       wa_itabb1-zstatus EQ '51'.
    ELSE.
      CONTINUE.
    ENDIF.

    IF wa_itabb1-txdat > ta_date-high.
      CONTINUE.
    ENDIF.

    IF wa_itabb1-stceg IS INITIAL.
      CONTINUE.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = wa_itabb1-stceg
        IMPORTING
          npwp_out = wa_itabb1-stceg.
    ENDIF.

    wa_espt-kodepjk = 'B'.
    wa_espt-npwp    = wa_itabb1-stceg.
    wa_espt-nama    = wa_itabb1-name1.

    IF wa_itabb1-txdat(4) GT 2006.
      IF wa_itabb1-shkzg EQ 'H'.
        wa_espt-kodelam = '2'.
        wa_espt-kodests = '1'.
        wa_espt-kodecab = '000'.
        wa_espt-kodedok = '1'.
        wa_espt-nofkt   = wa_itabb1-tbeln+2(8).
      ELSE.
        IF wa_itabb1-zstatus EQ '42'.
          wa_espt-kodelam = '2'.
          wa_espt-kodests = '1'.
          wa_espt-kodedok = '2'.
          wa_espt-kodecab = '000'.
          wa_espt-nofkt   = wa_itabb1-tbeln+2(8).
        ELSE.
          wa_espt-kodelam = '2'.
          wa_espt-kodests = wa_itabb1-tbeln+1(1).
          wa_espt-kodedok = '1'.
          wa_espt-kodecab = wa_itabb1-tbeln+3(3).
          wa_espt-nofkt   = wa_itabb1-tbeln+8(8).
        ENDIF.
      ENDIF.
      wa_espt-kodethn = wa_itabb1-gjahr+2(2).
    ELSE.
      wa_espt-kodelam = '2'.
      wa_espt-kodests = '1'.
      wa_espt-kodedok = '1'.
      wa_espt-kodecab = space.
      wa_espt-nofkt   = wa_itabb1-tbeln+10(8).
      wa_espt-kodethn = wa_itabb1-tbeln(9).
    ENDIF.
    wa_espt-masapjk = wa_itabb1-monat.
    wa_espt-thnpjk  = wa_itabb1-gjahr.
    wa_espt-betul   = '0'.
*    wa_espt-betul   = Wd_ITABA1-tbeln+2(1).
    wa_espt-dpp = '0'.
    wa_espt-ppnbm   = '0'.

    IF wa_itabb1-shkzg EQ 'H'.
      IF wa_itabb1-mwsbk < 0.
        wa_itabb1-mwsbk = wa_itabb1-mwsbk * -1.
        wa_itabb1-zdpp = wa_itabb1-zdpp * -1.
      ENDIF.
      IF wa_itabb1-mwsbk IS INITIAL.
        wa_espt-ppn = '0'.
        wa_espt-dpp = '0'.
      ELSE.
        wa_itabb1-mwsbk = wa_itabb1-mwsbk * 100.
        WRITE wa_itabb1-mwsbk TO wa_espt-ppn
                              USING EDIT MASK '- _____________'
                              DECIMALS 0.
        wa_itabb1-zdpp = wa_itabb1-zdpp * 100.
        WRITE wa_itabb1-zdpp TO wa_espt-dpp
                              USING EDIT MASK '- _____________'
                              DECIMALS 0.
      ENDIF.
    ELSE.
      IF wa_itabb1-mwsbk IS INITIAL.
        wa_espt-ppn = '0'.
        wa_espt-dpp = '0'.
      ELSE.
        wa_itabb1-mwsbk = wa_itabb1-mwsbk * 100.
        WRITE wa_itabb1-mwsbk TO wa_espt-ppn
*                              using edit mask '- _____________'
                              DECIMALS 0.
        wa_itabb1-zdpp = wa_itabb1-zdpp * 100.
        WRITE wa_itabb1-zdpp TO wa_espt-dpp
*                              using edit mask '- _____________'
                              DECIMALS 0.
      ENDIF.
    ENDIF.

    DO 3 TIMES.
      REPLACE '.' WITH space INTO wa_espt-ppn.
      CONDENSE wa_espt-ppn NO-GAPS.
      REPLACE '.' WITH space INTO wa_espt-dpp.
      CONDENSE wa_espt-dpp NO-GAPS.
    ENDDO.

    IF NOT wa_itabb1-txdat IS INITIAL.
      WRITE wa_itabb1-txdat TO wa_espt-tglfkt
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
    CONCATENATE 'C:\FILEB1_' pa_bukrs '_' pa_monat '.TXT' INTO fname.

*Begin remark Unicode conversion - DEVK965581
*06.03.2020 - SOL_FELIX
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
*End remark Unicode conversion - DEVK965581
*Begin insert Unicode conversion - DEVK965581
*06.03.2020 - SOL_FELIX

    DATA: lv_filename TYPE string.
    CLEAR lv_filename.
    lv_filename = fname.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_filename
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

    IF sy-subrc EQ 0.
      MESSAGE i000(zf) WITH 'Download Success'.
    ENDIF.
*End insert Unicode conversion - DEVK965581
  ENDIF.

ENDFORM.                    " DOWNLOAD_B1_NEW

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_B4
*&---------------------------------------------------------------------*
FORM download_b4.
  DATA: l_text(7),
        l_stat(2),
        l_stat1(2).
  DATA: l_npwp LIKE zfvatb1-stceg,
        l_nofak(10).

  CLEAR: wa_itabb4, i_itab.
  LOOP AT i_itabb4 INTO wa_itabb4.

    MOVE wa_itabb4-zstatus TO l_stat.
    MOVE '7' TO va_kdlamp.
    MOVE l_stat+1(1) TO va_kdstat.

    SELECT SINGLE zstatus1
      FROM zfpajak
      INTO l_stat1
      WHERE bukrs EQ pa_bukrs AND
            zstatus EQ wa_itabb4-zstatus.
    MOVE l_stat1+1(1) TO va_kddocu.

    CASE wa_itabb4-zstatus.
      WHEN '60'.
*        MOVE '0' TO VA_KDSTAT.
        MOVE  wa_itabb4-stceg TO l_npwp.

      WHEN '61'.
*        MOVE '1' TO VA_KDSTAT.
        MOVE  wa_itabb4-stceg TO l_npwp.

      WHEN '62'.
*        MOVE '2' TO VA_KDSTAT.
        MOVE  wa_itabb4-stceg TO l_npwp.

      WHEN '63'.
*        MOVE '3' TO VA_KDSTAT.
        MOVE  wa_itabb4-stceg TO l_npwp.

      WHEN '64'.
*        MOVE '4' TO VA_KDSTAT.
        MOVE  wa_itabb4-stceg TO l_npwp.

      WHEN '65'.
*        MOVE '5' TO VA_KDSTAT.
        MOVE  wa_itabb4-stceg TO l_npwp.

      WHEN '66'.
*        MOVE '6' TO VA_KDSTAT.
        MOVE  wa_itabb4-stceg TO l_npwp.
    ENDCASE.

    MOVE  wa_itabb4-name1 TO va_nmwp.
*    MOVE '1' TO VA_KDDOCU.
    MOVE wa_itabb4-tbeln+0(5) TO va_kdfktr.
*    write WA_ITABB4-TBELN+10(8) TO VA_NOFKTR RIGHT-JUSTIFIED.
*    v_len = STRLEN( VA_NOFKTR ).
*    v_space = 30 - v_len.
*    DO v_space TIMES.
*      CONCATENATE '0' VA_NOFKTR INTO VA_NOFKTR.
*    ENDDO.
    CONCATENATE wa_itabb4-txdat+6(2)
                 wa_itabb4-txdat+4(2)
                 wa_itabb4-txdat+0(4)
           INTO  va_tglfkt SEPARATED BY '-'.
*    WRITE WA_ITABB4-TXDAT TO VA_TGLFKT DD-MM-YYYY.
    wa_itabb4-mwsbk = wa_itabb4-mwsbk * 100.

    IF wa_itabb4-shkzg EQ 'H'.
      IF wa_itabb4-mwsbk < 0.
        wa_itabb4-mwsbk = wa_itabb4-mwsbk * -1.
      ENDIF.
      WRITE wa_itabb4-mwsbk TO va_nilppn DECIMALS 0 NO-GROUPING.
      SHIFT va_nilppn LEFT DELETING LEADING space.
      CONCATENATE '-' va_nilppn INTO va_nilppn.
      IF pa_bukrs EQ '8010'.
        WRITE  va_nilppn       TO wa_itab-nilppn RIGHT-JUSTIFIED.
      ELSE.
        WRITE  va_nilppn       TO wa_itabt-nilppn RIGHT-JUSTIFIED.
      ENDIF.
    ELSE.
      WRITE wa_itabb4-mwsbk TO va_nilppn RIGHT-JUSTIFIED
      DECIMALS 0 NO-GROUPING.
      IF pa_bukrs EQ '8010'.
        WRITE  va_nilppn       TO wa_itab-nilppn RIGHT-JUSTIFIED.
      ELSE.
        WRITE  va_nilppn       TO wa_itabt-nilppn RIGHT-JUSTIFIED.
      ENDIF.
    ENDIF.

    WRITE space TO va_nilppnbm RIGHT-JUSTIFIED.
    WRITE pa_betul TO va_betul LEFT-JUSTIFIED.

* PERUBAHAN NPWP U/ TSP
    IF pa_bukrs EQ '8010'.
      CONCATENATE l_npwp+0(2) l_npwp+3(3) l_npwp+7(3) l_npwp+11(1)
                  l_npwp+13(3) l_npwp+17(3)
      INTO va_npwp.
      CONCATENATE l_npwp+13(3) wa_itabb4-tbeln+10(8) INTO l_nofak.
      WRITE l_nofak  TO va_nofktr RIGHT-JUSTIFIED.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = l_npwp
        IMPORTING
          npwp_out = va_npwp.
    ENDIF.

    IF pa_bukrs EQ '8010'.
      MOVE  wa_itabb4-gjahr TO wa_itab-thnpjk.
      MOVE  wa_itabb4-monat TO wa_itab-blnpjk.
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

      IF wa_itabb4-zstatus EQ '60' OR
         wa_itabb4-zstatus EQ '61' OR
         wa_itabb4-zstatus EQ '62' OR
         wa_itabb4-zstatus EQ '63' OR
         wa_itabb4-zstatus EQ '64' OR
         wa_itabb4-zstatus EQ '65' OR
         wa_itabb4-zstatus EQ '66'.
        APPEND wa_itab TO i_itab.
      ENDIF.
    ELSE.
      MOVE  wa_itabb4-gjahr TO wa_itabt-thnpjk.
      MOVE  wa_itabb4-monat TO wa_itabt-blnpjk.
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
      MOVE  wa_itabb4-tbeln+6(3) TO wa_itabt-kdkpp.
      IF wa_itabt-kdkpp EQ space.
        wa_itabt-kdkpp = '000'.
      ENDIF.
      MOVE  wa_itabb4-tbeln+10(7) TO wa_itabt-nofktr.
      WRITE va_tglfkt       TO wa_itabt-tglfkt.
      MOVE  va_nilppnbm     TO wa_itabt-nilppnbm.

      IF wa_itabb4-zstatus EQ '60' OR
         wa_itabb4-zstatus EQ '61' OR
         wa_itabb4-zstatus EQ '62' OR
         wa_itabb4-zstatus EQ '63' OR
         wa_itabb4-zstatus EQ '64' OR
         wa_itabb4-zstatus EQ '65' OR
         wa_itabb4-zstatus EQ '66'.
        APPEND wa_itabt TO i_itabt.
      ENDIF.
    ENDIF.

    CLEAR: l_stat, l_stat1.

    CLEAR: wa_itabb4, va_kdstat, va_npwp, va_nmwp,
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
      PERFORM f_download_pc_b4.
    ENDIF.
  ELSE.
    MESSAGE i000(zm) WITH 'Data not found'.
  ENDIF.
  CLEAR: cntr.

ENDFORM.                    " DOWNLOAD_B4

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_B4_NEW
*&---------------------------------------------------------------------*
FORM download_b4_new.

  DATA: ld_vatpr LIKE zfvato-vatpr,
        ld_vatno LIKE zfvato-vatno,
        ld_dudat LIKE zfvato-dudat,
        ld_dueyr LIKE zfvato-dueyr,
        ld_duemm LIKE zfvato-duemm,
        ld_sspdt LIKE zfvato-sspdt,
        ld_netwr LIKE zfvato-netwr,
        fname(128).

  DATA: l_text(7),
        l_stat(2),
        l_stat1(2).
  DATA: l_npwp LIKE zfvatb1-stceg,
        l_nofak(10).

  CLEAR: wa_itabb4,i_espt,i_itab.
  LOOP AT i_itabb4 INTO wa_itabb4.

    CLEAR: ld_vatpr,ld_dudat,ld_dueyr,ld_duemm,ld_sspdt,ld_netwr,
           ld_vatno.

    CLEAR: wa_espt-kodepjk,wa_espt-kodelam,wa_espt-kodests,
           wa_espt-kodedok,wa_espt-npwp,wa_espt-nama,wa_espt-kodecab,
           wa_espt-kodethn,wa_espt-nofkt,wa_espt-tglfkt,wa_espt-tglssp,
           wa_espt-masapjk,wa_espt-thnpjk,wa_espt-betul,wa_espt-dpp,
           wa_espt-ppn,wa_espt-ppnbm.

    IF wa_itabb4-zstatus EQ '60' OR
       wa_itabb4-zstatus EQ '61' OR
       wa_itabb4-zstatus EQ '62' OR
       wa_itabb4-zstatus EQ '63' OR
       wa_itabb4-zstatus EQ '64' OR
       wa_itabb4-zstatus EQ '65' OR
       wa_itabb4-zstatus EQ '66'.
    ELSE.
      CONTINUE.
    ENDIF.

    IF wa_itabb4-stceg IS INITIAL.
      CONTINUE.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = wa_itabb4-stceg
        IMPORTING
          npwp_out = wa_itabb4-stceg.
    ENDIF.

    wa_espt-kodepjk = 'B'.
    wa_espt-kodelam = '3'.
    IF wa_itabb4-txdat(4) GT 2006.
      IF wa_itabb4-shkzg EQ 'H'.
        wa_espt-kodests = '1'..
      ELSE.
        wa_espt-kodests = wa_itabb4-tbeln+1(1).
      ENDIF.
      wa_espt-kodecab = wa_itabb4-tbeln+3(3).
      wa_espt-nofkt   = wa_itabb4-tbeln+8(8).
      wa_espt-kodethn = wa_itabb4-gjahr+2(2).
    ELSE.
      wa_espt-kodests = '1'.
      wa_espt-kodecab = space.
      wa_espt-nofkt   = wa_itabb4-tbeln+10(7).
      wa_espt-kodethn = wa_itabb4-tbeln(9).
    ENDIF.
    wa_espt-kodedok = '1'.
    wa_espt-npwp    = wa_itabb4-stceg.
    wa_espt-nama    = wa_itabb4-name1.
    wa_espt-masapjk = wa_itabb4-monat.
    wa_espt-thnpjk  = wa_itabb4-gjahr.
    wa_espt-betul   = '0'.
*    wa_espt-betul   = Wd_ITABB4-tbeln+2(1).
    wa_espt-dpp = '0'.
    wa_espt-ppnbm   = '0'.

    IF wa_itabb4-shkzg EQ 'H'.
      IF wa_itabb4-mwsbk < 0.
        wa_itabb4-mwsbk = wa_itabb4-mwsbk * -1.
        wa_itabb4-zdpp = wa_itabb4-zdpp * -1.
      ENDIF.
      IF wa_itabb4-mwsbk IS INITIAL.
        wa_espt-ppn = '0'.
        wa_espt-dpp = '0'.
      ELSE.
        wa_itabb4-mwsbk = wa_itabb4-mwsbk * 100.
        WRITE wa_itabb4-mwsbk TO wa_espt-ppn
                              USING EDIT MASK '- _____________'
                              DECIMALS 0.
        wa_itabb4-zdpp = wa_itabb4-zdpp * 100.
        WRITE wa_itabb4-zdpp TO wa_espt-dpp
                              USING EDIT MASK '- _____________'
                              DECIMALS 0.
      ENDIF.
    ELSE.
      IF wa_itabb4-mwsbk IS INITIAL.
        wa_espt-ppn = '0'.
        wa_espt-dpp = '0'.
      ELSE.
        wa_itabb4-mwsbk = wa_itabb4-mwsbk * 100.
        WRITE wa_itabb4-mwsbk TO wa_espt-ppn
*                              using edit mask '- _____________'
                              DECIMALS 0.
        wa_itabb4-zdpp = wa_itabb4-zdpp * 100.
        WRITE wa_itabb4-zdpp TO wa_espt-dpp
*                              using edit mask '- _____________'
                              DECIMALS 0.
      ENDIF.
    ENDIF.

    DO 3 TIMES.
      REPLACE '.' WITH space INTO wa_espt-ppn.
      CONDENSE wa_espt-ppn NO-GAPS.
      REPLACE '.' WITH space INTO wa_espt-dpp.
      CONDENSE wa_espt-dpp NO-GAPS.
    ENDDO.

    IF NOT wa_itabb4-txdat IS INITIAL.
      WRITE wa_itabb4-txdat TO wa_espt-tglfkt
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
    CONCATENATE 'C:\FILEB4_' pa_bukrs '_' pa_monat '.TXT' INTO fname.

*Begin remark Unicode conversion - DEVK965581
*06.03.2020 - SOL_FELIX
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
*End remark Unicode conversion - DEVK965581
*Begin insert Unicode conversion - DEVK965581
*06.03.2020 - SOL_FELIX

    DATA: lv_filename TYPE string.
    CLEAR lv_filename.
    lv_filename = fname.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_filename
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

    IF sy-subrc EQ 0.
      MESSAGE i000(zf) WITH 'Download Success'.
    ENDIF.
*End insert Unicode conversion - DEVK965581
  ENDIF.

ENDFORM.                    " DOWNLOAD_B4_NEW

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_PC_B1
*&---------------------------------------------------------------------*
FORM f_download_pc_b1.
  DATA: fname(128).

  IF pa_bukrs EQ '8010'.
* PROSES SPT TSP OLD
*    CALL FUNCTION 'DOWNLOAD'
*       EXPORTING
*            FILENAME = 'C:\FILEB1.DAT'
*       IMPORTING
*            CANCEL = CANC
*            FILESIZE = SIZE
*       TABLES
*            DATA_TAB = I_ITAB
*       EXCEPTIONS
*            FILE_OPEN_ERROR  = 1
*            FILE_WRITE_ERROR = 2.

* PROSES SPT TSP NEW
    PERFORM getfieleds.
    CONCATENATE 'C:\FILEB1_' pa_bukrs '_' pa_monat
      INTO va_name.
    PERFORM show.
  ELSE.
    CONCATENATE 'C:\FILEB1_' pa_bukrs '_' pa_monat '.DAT'
      INTO fname.
*Begin remark Unicode conversion - DEVK965581
*06.03.2020 - SOL_FELIX
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
*End remark Unicode conversion - DEVK965581
*Begin insert Unicode conversion - DEVK965581
*06.03.2020 - SOL_FELIX
    DATA: lv_filename TYPE string.
    CLEAR lv_filename.
    lv_filename = fname.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_filename
*      FIELDNAMES              = dwn_field
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
*End insert Unicode conversion - DEVK965581
  ENDIF.

*Begin remark Unicode conversion - DEVK965581
*06.03.2020 - SOL_FELIX
*  IF canc = 'x'.
*    MESSAGE i000(zm) WITH 'Download Cancel by User'.
*  ENDIF.
*
*  IF size NE '0'.
*    MESSAGE i000(zm) WITH 'Download Success'.
*  ENDIF.
*End remark Unicode conversion - DEVK965581
*Begin insert Unicode conversion - DEVK965581
*06.03.2020 - SOL_FELIX
  IF sy-subrc EQ 0.
    MESSAGE i000(zf) WITH 'Download Success'.
  ENDIF.
*End insert Unicode conversion - DEVK965581

ENDFORM.                    " F_DOWNLOAD_PC_B1

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_PC_B4
*&---------------------------------------------------------------------*
FORM f_download_pc_b4.
  DATA: fname(128).

  IF pa_bukrs EQ '8010'.
* PROSES SPT TSP OLD
*    CALL FUNCTION 'DOWNLOAD'
*       EXPORTING
*            FILENAME = 'C:\FILEB4.DAT'
*       IMPORTING
*            CANCEL = CANC
*            FILESIZE = SIZE
*       TABLES
*            DATA_TAB = I_ITAB
*       EXCEPTIONS
*            FILE_OPEN_ERROR  = 1
*            FILE_WRITE_ERROR = 2.

* PROSES SPT TSP NEW
    PERFORM getfieleds.
    CONCATENATE 'C:\FILEB4_' pa_bukrs '_' pa_monat
      INTO va_name.
    PERFORM show.

  ELSE.
    CONCATENATE 'C:\FILEB4_' pa_bukrs '_' pa_monat '.DAT'
      INTO fname.
*Begin remark Unicode conversion - DEVK965581
*06.03.2020 - SOL_FELIX
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
*End remark Unicode conversion - DEVK965581
*Begin insert Unicode conversion - DEVK965581
*06.03.2020 - SOL_FELIX
    DATA: lv_filename TYPE string.
    CLEAR lv_filename.
    lv_filename = fname.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_filename
*      FIELDNAMES              = dwn_field
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
*End insert Unicode conversion - DEVK965581
  ENDIF.
*Begin remark Unicode conversion - DEVK965581
*06.03.2020 - SOL_FELIX
*  IF canc = 'x'.
*    MESSAGE i000(zm) WITH 'Download Cancel by User'.
*  ENDIF.
*
*  IF size NE '0'.
*    MESSAGE i000(zm) WITH 'Download Success'.
*  ENDIF.
*End remark Unicode conversion - DEVK965581
*Begin insert Unicode conversion - DEVK965581
*06.03.2020 - SOL_FELIX
  IF sy-subrc EQ 0.
    MESSAGE i000(zf) WITH 'Download Success'.
  ENDIF.
*End insert Unicode conversion - DEVK965581

ENDFORM.                    " F_DOWNLOAD_PC_B4

*&---------------------------------------------------------------------*
*&      Form  f_post_fb09
*&---------------------------------------------------------------------*
FORM f_post_fb09.
  CLEAR i_bdc.
  PERFORM f_dynpro USING:
        'X'  'SAPMF05L'     '0102',
*         ' '  'BDC_CURSOR'
        ' '  'BDC_OKCODE'   '/00',
        ' '  'RF05L-BELNR'  wa_itab3-belnr,
        ' '  'RF05L-BUKRS'  pa_bukrs,
*         ' '  'RF05L-GJAHR'  pa_gjahr,
        ' '  'RF05L-GJAHR'  wa_itab3-gjahr,
        ' '  'RF05L-BUZEI'  '001',
        ' '  'RF05L-XKSAK'  'X',
        'X'  'SAPMF05L'     '0300',
        ' '  'BDC_OKCODE'   '=ZK',
        ' '  'DKACB-FMORE'  'X',
        'X'  'SAPLKACB'     '0002',
        ' '  'BDC_OKCODE'   '=ENTE',
        'X'  'SAPMF05L'     '1300',
        ' '  'BDC_OKCODE'   '=ENTR',
        ' '  'BSEG-XREF3'   wa_itab3-xref3,
        'X'  'SAPMF05L'     '0300',
        ' '  'BDC_OKCODE'   '=AE',
        'X'  'SAPLKACB'     '0002',
        ' '  'BDC_OKCODE'   '=ENTE'.
  CALL TRANSACTION 'FB09' USING i_bdc MODE va_mode UPDATE 'S'
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
  ENDIF.
ENDFORM.                    " f_post_fb09
*&---------------------------------------------------------------------*
*&      Form  f_print_column_header
*&---------------------------------------------------------------------*
FORM f_print_column_header.
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
  WRITE AT c1(w6) 'Nama Vendor' NO-GAP. c1 = c1 + w6.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w7) 'NPWP Vendor' NO-GAP. c1 = c1 + w7.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 1.
  WRITE: / sy-uline.

ENDFORM.                    " f_print_column_header
*&---------------------------------------------------------------------*
*&      Form  f_print_detail
*&---------------------------------------------------------------------*
FORM f_print_detail.
  c1 = 1.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  WRITE AT c1(w1) wa_itab3-bukrs NO-GAP. c1 = c1 + w1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w2) wa_itab3-gsber NO-GAP. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_itab3-gjahr NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w4) wa_itab3-zfbdt NO-GAP. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w5) wa_itab3-zuonr NO-GAP. c1 = c1 + w5.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w10) wa_itab3-belnr NO-GAP. c1 = c1 + w10.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w9) wa_itab3-dmbtr DECIMALS 0 CURRENCY 'IDR' NO-GAP.
  c1 = c1 + w9.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w6) wa_itab3-sgtxt NO-GAP. c1 = c1 + w6.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w7) wa_itab3-bktxt NO-GAP. c1 = c1 + w7.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE: wa_itab3-error, sy-vline.
  HIDE: wa_itab3-belnr.

ENDFORM.                    " f_print_detail
*&---------------------------------------------------------------------*
*&      Form  f_print_footer
*&---------------------------------------------------------------------*
FORM f_print_footer.
  c1 = 1.
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
  WRITE AT c1(w9) tot_dmbtr DECIMALS 0 CURRENCY 'IDR' NO-GAP.
  c1 = c1 + w9.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w6.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
*          write at c1(w7) 'Total Value : ' no-gap.
  c1 = c1 + w7.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE: / sy-uline.

ENDFORM.                    " f_print_footer

*&---------------------------------------------------------------------*
*&      Form  CEK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek.
  AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
          ID 'GSBER' FIELD pa_gsber
          ID 'ACTVT' FIELD '01'.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH
    'You have no authorization for Sales Office' pa_gsber.
  ENDIF.

ENDFORM.                    " CEK

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

ENDFORM.                    "layout_init

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
  xfieldcat-reptext_ddic = 'PKP Penjual'.
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

ENDFORM.                    " BUILD_FIELDCAT

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
ENDFORM.                    "eventtab_build

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

ENDFORM.                    "top_of_page

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
*&      Form  WRITE_DATA_B1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_data_b1.
  DATA: l_text(7),
        l_npwp(20).

  nourut = 0.
  MOVE '4' TO v_kdlamp.

  CLEAR: wa_itabb1, i_itab.
  SORT i_itabb1 BY name1.
  LOOP AT i_itabb1 INTO wa_itabb1.
    CASE wa_itabb1-zstatus.
      WHEN '41'.
        MOVE '1' TO v_kdstat.
        MOVE  wa_itabb1-stceg TO v_npwp_in.

      WHEN '42'.
        MOVE '2' TO v_kdstat.
        MOVE  wa_itabb1-stceg TO v_npwp_in.

      WHEN '43'.
        MOVE '3' TO v_kdstat.
        MOVE  wa_itabb1-stceg TO v_npwp_in.

      WHEN '44'.
        MOVE '4' TO v_kdstat.
        MOVE  wa_itabb1-stceg TO v_npwp_in.

      WHEN '45'.
        MOVE '5' TO v_kdstat.
        MOVE  wa_itabb1-stceg TO v_npwp_in.

      WHEN '46'.
        MOVE '6' TO v_kdstat.
        MOVE  wa_itabb1-stceg TO v_npwp_in.

      WHEN '47'.
        MOVE '7' TO v_kdstat.
        MOVE  wa_itabb1-stceg TO v_npwp_in.

      WHEN '48'.
        MOVE '8' TO v_kdstat.
        MOVE  wa_itabb1-stceg TO v_npwp_in.

      WHEN '49'.
        MOVE '9' TO v_kdstat.
        MOVE  wa_itabb1-stceg TO v_npwp_in.
    ENDCASE.

    CALL FUNCTION 'ZF_NPWP_MODIFICATION'
      EXPORTING
        npwp_in  = v_npwp_in
      IMPORTING
        npwp_out = v_npwp_out.

    MOVE  wa_itabb1-name1 TO v_nmwp.
    MOVE '1' TO v_kddocu.

    IF wa_itabb1-tbeln(2) EQ 'KG' OR
       wa_itabb1-tbeln(2) EQ 'RE' OR
       wa_itabb1-shkzg    EQ 'H'.
      v_kdfktr = space.
      va_strlen = STRLEN( wa_itabb1-tbeln ).
      va_count = va_strlen - 7.
      l_text = wa_itabb1-tbeln+va_count(7).
*       CONCATENATE WA_ITABB1-TBELN+0(1) WA_ITABB1-TBELN+2(6)
*         INTO L_TEXT.
      MOVE space TO v_kdkpp.
    ELSE.
      MOVE wa_itabb1-tbeln+6(3) TO v_kdkpp.
      MOVE wa_itabb1-tbeln+0(5) TO v_kdfktr.
      IF va_kdfktr EQ 'PIBNO'.
        WRITE wa_itabb1-tbeln+7(7) TO l_text."V_NOFKTR RIGHT-JUSTIFIED.
      ELSE.
        WRITE wa_itabb1-tbeln+10(8) TO l_text."V_NOFKTR RIGHT-JUSTIFIED.
      ENDIF.

      v_len = STRLEN( l_text ).
      v_space = 7 - v_len.
      DO v_space TIMES.
        CONCATENATE '0' l_text INTO l_text.
      ENDDO.
    ENDIF.

    WRITE l_text  TO v_nofktr RIGHT-JUSTIFIED.
    CONCATENATE wa_itabb1-txdat+6(2)
                 wa_itabb1-txdat+4(2)
                 wa_itabb1-txdat+0(4)
           INTO  v_tglfkt SEPARATED BY '-'.
    wa_itabb1-mwsbk = wa_itabb1-mwsbk * 100.
    MOVE wa_itabb1-mwsbk TO v_nilppn.
*    WRITE WA_ITABB1-MWSBK TO VA_NILPPN RIGHT-JUSTIFIED.
    WRITE space TO v_nilppnbm RIGHT-JUSTIFIED.
    WRITE pa_betul TO v_betul LEFT-JUSTIFIED.

    MOVE  wa_itabb1-gjahr TO wa_itab-thnpjk.
    MOVE  wa_itabb1-monat TO wa_itab-blnpjk.
    MOVE  v_betul        TO wa_itab-pembtl.
    MOVE  v_kdlamp       TO wa_itab-kdlamp.
    MOVE  v_kdstat       TO wa_itab-kdstat.

    IF v_npwp_in EQ space.
      MOVE '000000000000000' TO  v_npwp_out.
    ENDIF.

*    CONCATENATE L_NPWP+0(2) L_NPWP+3(3) L_NPWP+7(3) L_NPWP+11(1)
*                L_NPWP+13(3) L_NPWP+17(3)
*    INTO V_NPWP.

    ADD 1 TO nourut.

    IF wa_itabb1-shkzg EQ 'H'.
      v_nilppn = v_nilppn * -1.
    ENDIF.

    MOVE  nourut          TO ta_excel-nourut.
    MOVE  wa_itabb1-gjahr TO ta_excel-thnpjk.
    MOVE  wa_itabb1-monat TO ta_excel-blnpjk.
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

    IF wa_itabb1-zstatus EQ '41' OR
       wa_itabb1-zstatus EQ '42' OR
       wa_itabb1-zstatus EQ '43' OR
       wa_itabb1-zstatus EQ '44' OR
       wa_itabb1-zstatus EQ '45' OR
       wa_itabb1-zstatus EQ '46' OR
       wa_itabb1-zstatus EQ '47' OR
       wa_itabb1-zstatus EQ '48' OR
       wa_itabb1-zstatus EQ '49'.
      APPEND ta_excel.
    ENDIF.

    CLEAR: wa_itabb1, v_kdstat, v_npwp, v_nmwp,
           v_nofktr, v_tglfkt, v_nilppn.
  ENDLOOP.

ENDFORM.                    " WRITE_DATA_B1

*&---------------------------------------------------------------------*
*&      Form  WRITE_DATA_B4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_data_b4.
  DATA: l_text(7),
        l_npwp(20).

  nourut = 0.
  MOVE '7' TO v_kdlamp.

  CLEAR: wa_itabb4, i_itab.
  LOOP AT i_itabb4 INTO wa_itabb4.
    CASE wa_itabb4-zstatus.
      WHEN '60'.
        MOVE '0' TO v_kdstat.
        MOVE  wa_itabb4-stceg TO v_npwp_in.

      WHEN '61'.
        MOVE '1' TO v_kdstat.
        MOVE  wa_itabb4-stceg TO v_npwp_in.

      WHEN '62'.
        MOVE '2' TO v_kdstat.
        MOVE  wa_itabb4-stceg TO v_npwp_in.

      WHEN '63'.
        MOVE '3' TO v_kdstat.
        MOVE  wa_itabb4-stceg TO v_npwp_in.

      WHEN '64'.
        MOVE '4' TO v_kdstat.
        MOVE  wa_itabb4-stceg TO v_npwp_in.

      WHEN '65'.
        MOVE '5' TO v_kdstat.
        MOVE  wa_itabb4-stceg TO v_npwp_in.

      WHEN '66'.
        MOVE '6' TO v_kdstat.
        MOVE  wa_itabb4-stceg TO v_npwp_in.
    ENDCASE.

    CALL FUNCTION 'ZF_NPWP_MODIFICATION'
      EXPORTING
        npwp_in  = v_npwp_in
      IMPORTING
        npwp_out = v_npwp_out.

    MOVE wa_itabb4-tbeln+6(3) TO v_kdkpp.
    MOVE  wa_itabb4-name1 TO v_nmwp.
    MOVE '1' TO v_kddocu.
    MOVE wa_itabb4-tbeln+0(5) TO v_kdfktr.
    WRITE wa_itabb4-tbeln+10(8) TO v_nofktr RIGHT-JUSTIFIED.
*    v_len = STRLEN( VA_NOFKTR ).
*    v_space = 30 - v_len.
*    DO v_space TIMES.
*      CONCATENATE '0' VA_NOFKTR INTO VA_NOFKTR.
*    ENDDO.
    CONCATENATE wa_itabb4-txdat+6(2)
                 wa_itabb4-txdat+4(2)
                 wa_itabb4-txdat+0(4)
           INTO  v_tglfkt SEPARATED BY '-'.
*    WRITE WA_ITABB4-TXDAT TO VA_TGLFKT DD-MM-YYYY.
    wa_itabb4-mwsbk = wa_itabb4-mwsbk * 100.
    MOVE  wa_itabb4-mwsbk TO v_nilppn.
    WRITE space TO v_nilppnbm RIGHT-JUSTIFIED.
    WRITE pa_betul TO v_betul LEFT-JUSTIFIED.

*    CONCATENATE L_NPWP+0(2) L_NPWP+3(3) L_NPWP+7(3) L_NPWP+11(1)
*                L_NPWP+13(3) L_NPWP+17(3)
*    INTO V_NPWP.

    ADD 1 TO nourut.

    IF wa_itabb4-shkzg EQ 'H'.
      v_nilppn = v_nilppn * -1.
    ENDIF.

    MOVE  nourut          TO ta_excel-nourut.
    MOVE  wa_itabb4-gjahr TO ta_excel-thnpjk.
    MOVE  wa_itabb4-monat TO ta_excel-blnpjk.
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

    IF wa_itabb4-zstatus EQ '60' OR
       wa_itabb4-zstatus EQ '61' OR
       wa_itabb4-zstatus EQ '62' OR
       wa_itabb4-zstatus EQ '63' OR
       wa_itabb4-zstatus EQ '64' OR
       wa_itabb4-zstatus EQ '65' OR
       wa_itabb4-zstatus EQ '66'.
      APPEND ta_excel.
    ENDIF.

    CLEAR: wa_itabb4, v_kdstat, v_npwp, v_nmwp,
           v_nofktr, v_tglfkt, v_nilppn.
  ENDLOOP.

ENDFORM.                    " WRITE_DATA_B4

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
*&      Form  GET_UPLOAD_B1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_upload_b1.
  DATA: v_flag_mater(1) TYPE c,
        l_count(5),
        l_message(30),
        nomor(3),
        error_count TYPE i.

  counter = 0.
  nomor   = 0.

  REFRESH i_excel.
* GET MATERIAL NUMBER FROM EXCEL FILE.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_filenm "INPUT FROM SELECTION SCREEN
      i_begin_col             = 1
      i_begin_row             = 1
      i_end_col               = 15
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

  CLEAR i_itabb1.
  CLEAR wa_excel.
* Material Number is at col 3
  v_flag_mater = 'N'.
  LOOP AT i_excel INTO wa_excel.
    ON CHANGE OF wa_excel-row.
      IF v_flag_mater = 'Y'.
        APPEND wa_itabb1 TO i_itabb1.
        CLEAR  wa_itabb1.
      ENDIF.
      v_flag_mater = 'Y'.
    ENDON.
    v_flag_mater = 'Y'.
    IF wa_excel-col = '0001'.
      MOVE wa_excel-value TO wa_itabb1-bukrs.
    ENDIF.
    IF wa_excel-col = '0002'.
      MOVE wa_excel-value TO wa_itabb1-gsber.
    ENDIF.
    IF wa_excel-col = '0003'.
      MOVE wa_excel-value TO wa_itabb1-gjahr.
    ENDIF.
    IF wa_excel-col = '0004'.
      MOVE wa_excel-value TO wa_itabb1-monat.
    ENDIF.
    IF wa_excel-col = '0005'.
      MOVE wa_excel-value TO wa_itabb1-txdat.
    ENDIF.
    IF wa_excel-col = '0006'.
      MOVE wa_excel-value TO wa_itabb1-tbeln.
    ENDIF.
    IF wa_excel-col = '0007'.
      MOVE wa_excel-value TO wa_itabb1-name1.
    ENDIF.
    IF wa_excel-col = '0008'.
      MOVE wa_excel-value TO wa_itabb1-stceg.
    ENDIF.
    IF wa_excel-col = '0009'.
      MOVE wa_excel-value TO wa_itabb1-shkzg.
    ENDIF.
    IF wa_excel-col = '0010'.
      MOVE wa_excel-value TO wa_itabb1-waers.
    ENDIF.
    IF wa_excel-col = '0011'.
      MOVE wa_excel-value TO wa_itabb1-mwsbk.
      wa_itabb1-mwsbk = wa_itabb1-mwsbk / 100.
    ENDIF.
    IF wa_excel-col = '0012'.
      MOVE wa_excel-value TO wa_itabb1-remark.
    ENDIF.
    IF wa_excel-col = '0013'.
      MOVE wa_excel-value TO wa_itabb1-zstatus.
    ENDIF.
    IF wa_excel-col = '0014'.
      MOVE wa_excel-value TO wa_itabb1-zdpp.
      wa_itabb1-zdpp = wa_itabb1-zdpp / 100.
    ENDIF.
    IF wa_excel-col = '0015'.
      MOVE wa_excel-value TO wa_itabb1-stceg1.
    ENDIF.
    CLEAR wa_excel.
  ENDLOOP.
  IF v_flag_mater = 'Y'.
    APPEND wa_itabb1 TO i_itabb1.
    CLEAR  wa_itabb1.
  ENDIF.
  v_flag_mater = 'Y'.

  CLEAR: wa_itabb1.
  LOOP AT i_itabb1 INTO wa_itabb1.
    IF wa_itabb1-tbeln EQ space.
      ADD 1 TO error_count.
      APPEND wa_itabb1 TO i_error.
    ENDIF.

    IF wa_itabb1-zstatus EQ '41' AND
       wa_itabb1-zstatus EQ '43'.
      IF wa_itabb1-txdat(4) NE pa_gjahr.
        ADD 1 TO error_count.
        APPEND wa_itabb1 TO i_error.
      ENDIF.
    ENDIF.

    IF wa_itabb1-zstatus NE '41' AND
       wa_itabb1-zstatus NE '42' AND
       wa_itabb1-zstatus NE '43' AND
       wa_itabb1-zstatus NE '44' AND
       wa_itabb1-zstatus NE '45' AND
       wa_itabb1-zstatus NE '46' AND
       wa_itabb1-zstatus NE '47' AND
       wa_itabb1-zstatus NE '48' AND
       wa_itabb1-zstatus NE '49'.
      ADD 1 TO error_count.
      APPEND wa_itabb1 TO i_error.
    ENDIF.
    ADD 1 TO counter.
    CLEAR: wa_itabb1.
  ENDLOOP.

  IF error_count EQ 0.
    MOVE counter TO l_count.
    CONCATENATE 'UPLOAD' l_count 'RECORD' INTO l_message
      SEPARATED BY space.
    INSERT zfvatb1 FROM TABLE i_itabb1 ACCEPTING DUPLICATE KEYS.
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
            64 sy-vline NO-GAP, 'VAT In Number' NO-GAP,
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

ENDFORM.                    " GET_UPLOAD_B1

*&---------------------------------------------------------------------*
*&      Form  GET_UPLOAD_B4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_upload_b4.
  DATA: v_flag_mater(1) TYPE c,
        error_count TYPE i,
        l_count(5),
        l_message(30),
        nomor(3).

  counter = 0.
  nomor   = 0.

  REFRESH i_excel.
* GET MATERIAL NUMBER FROM EXCEL FILE.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_filenm "INPUT FROM SELECTION SCREEN
      i_begin_col             = 1
      i_begin_row             = 1
      i_end_col               = 15
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

  CLEAR i_itabb4.
  CLEAR wa_excel.
* Material Number is at col 3
  v_flag_mater = 'N'.
  LOOP AT i_excel INTO wa_excel.
    ON CHANGE OF wa_excel-row.
      IF v_flag_mater = 'Y'.
        APPEND wa_itabb4 TO i_itabb4.
        CLEAR  wa_itabb4.
      ENDIF.
      v_flag_mater = 'Y'.
    ENDON.
    v_flag_mater = 'Y'.
    IF wa_excel-col = '0001'.
      MOVE wa_excel-value TO wa_itabb4-bukrs.
    ENDIF.
    IF wa_excel-col = '0002'.
      MOVE wa_excel-value TO wa_itabb4-gsber.
    ENDIF.
    IF wa_excel-col = '0003'.
      MOVE wa_excel-value TO wa_itabb4-gjahr.
    ENDIF.
    IF wa_excel-col = '0004'.
      MOVE wa_excel-value TO wa_itabb4-monat.
    ENDIF.
    IF wa_excel-col = '0005'.
      MOVE wa_excel-value TO wa_itabb4-txdat.
    ENDIF.
    IF wa_excel-col = '0006'.
      MOVE wa_excel-value TO wa_itabb4-tbeln.
    ENDIF.
    IF wa_excel-col = '0007'.
      MOVE wa_excel-value TO wa_itabb4-name1.
    ENDIF.
    IF wa_excel-col = '0008'.
      MOVE wa_excel-value TO wa_itabb4-stceg.
    ENDIF.
    IF wa_excel-col = '0009'.
      MOVE wa_excel-value TO wa_itabb4-shkzg.
    ENDIF.
    IF wa_excel-col = '0010'.
      MOVE wa_excel-value TO wa_itabb4-waers.
    ENDIF.
    IF wa_excel-col = '0011'.
      MOVE wa_excel-value TO wa_itabb4-mwsbk.
      wa_itabb4-mwsbk = wa_itabb4-mwsbk / 100.
    ENDIF.
    IF wa_excel-col = '0012'.
      MOVE wa_excel-value TO wa_itabb4-remark.
    ENDIF.
    IF wa_excel-col = '0013'.
      MOVE wa_excel-value TO wa_itabb4-zstatus.
    ENDIF.
    IF wa_excel-col = '0014'.
      MOVE wa_excel-value TO wa_itabb4-zdpp.
      wa_itabb4-zdpp = wa_itabb4-zdpp / 100.
    ENDIF.
    IF wa_excel-col = '0015'.
      MOVE wa_excel-value TO wa_itabb4-stceg1.
    ENDIF.
    CLEAR wa_excel.
  ENDLOOP.
  IF v_flag_mater = 'Y'.
    APPEND wa_itabb4 TO i_itabb4.
    CLEAR  wa_itabb4.
  ENDIF.
  v_flag_mater = 'Y'.

  CLEAR: wa_itabb4.
  LOOP AT i_itabb4 INTO wa_itabb4.
    IF wa_itabb4-tbeln EQ space.
      ADD 1 TO error_count.
      APPEND wa_itabb4 TO i_error.
    ENDIF.

*    IF WA_ITABB4-TXDAT(4) NE PA_GJAHR.
*       ADD 1 TO ERROR_COUNT.
*       APPEND WA_ITABB4 TO I_ERROR.
*    ENDIF.

    IF wa_itabb4-zstatus NE '60' AND
       wa_itabb4-zstatus NE '61' AND
       wa_itabb4-zstatus NE '62' AND
       wa_itabb4-zstatus NE '63' AND
       wa_itabb4-zstatus NE '64' AND
       wa_itabb4-zstatus NE '65' AND
       wa_itabb4-zstatus NE '66'.
      ADD 1 TO error_count.
      APPEND wa_itabb4 TO i_error.
    ENDIF.
    ADD 1 TO counter.
    CLEAR: wa_itabb4.
  ENDLOOP.

  IF error_count EQ 0.
    MOVE counter TO l_count.
    CONCATENATE 'UPLOAD' l_count 'RECORD' INTO l_message
      SEPARATED BY space.
    INSERT zfvatb4 FROM TABLE i_itabb4 ACCEPTING DUPLICATE KEYS.
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
            64 sy-vline NO-GAP, 'VAT In Number' NO-GAP,
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

ENDFORM.                    " GET_UPLOAD_B4

* MODULE FOR SCREEN 900
*&---------------------------------------------------------------------*
* OUTPUT MODULE FOR TABLECONTROL 'TA_TABLE':
* COPY DDIC-TABLE TO ITAB
*&---------------------------------------------------------------------*
MODULE ta_table_init OUTPUT.
  IF g_ta_table_copied IS INITIAL.
* COPY DDIC-TABLE 'ZFVATB1'
* INTO INTERNAL TABLE 'g_TA_TABLE_itab'
    SELECT * FROM zfvatb1
       INTO CORRESPONDING FIELDS
       OF TABLE g_ta_table_itab
       WHERE gsber EQ pa_gsber AND
             bukrs EQ pa_bukrs AND
             gjahr EQ pa_gjahr AND
             monat EQ pa_monat.
    IF sy-subrc NE 0.
      MESSAGE i000(zf) WITH 'Data not found'.
      LEAVE TO SCREEN 0.
    ENDIF.
    g_ta_table_copied = 'X'.
    REFRESH CONTROL 'TA_TABLE' FROM SCREEN '0900'.
  ENDIF.
ENDMODULE.                    "ta_table_init OUTPUT

*&---------------------------------------------------------------------*
* OUTPUT MODULE FOR TABLECONTROL 'TA_TABLE':
* MOVE ITAB TO DYNPRO
*&---------------------------------------------------------------------*
MODULE ta_table_move OUTPUT.
  MOVE-CORRESPONDING g_ta_table_wa TO zfvatb1.
ENDMODULE.                    "ta_table_move OUTPUT

*&---------------------------------------------------------------------*
* OUTPUT MODULE FOR TABLECONTROL 'TA_TABLE':
* GET LINES OF TABLECONTROL
*&---------------------------------------------------------------------*
MODULE ta_table_get_lines OUTPUT.
  g_ta_table_lines = sy-loopc.
ENDMODULE.                    "ta_table_get_lines OUTPUT

*&---------------------------------------------------------------------*
* INPUT MODULE FOR TABLECONTROL 'TA_TABLE': MODIFY TABLE
*&---------------------------------------------------------------------*
MODULE ta_table_modify INPUT.
  MOVE-CORRESPONDING zfvatb1 TO g_ta_table_wa.
  MODIFY g_ta_table_itab
  FROM g_ta_table_wa
  INDEX ta_table-current_line.
ENDMODULE.                    "ta_table_modify INPUT

* INPUT MODULE FOR TABLECONTROL 'TA_TABLE': PROCESS USER COMMAND
MODULE ta_table_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TA_TABLE'
                              'G_TA_TABLE_ITAB'
                              'CHECK'
                     CHANGING ok_code.
  IF sy-ucomm EQ 'TA_TABLE_INSR'.
    CLEAR: ok_code, sy-ucomm.
  ENDIF.

ENDMODULE.                    "ta_table_user_command INPUT

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
                       p_mark_name   .

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

* delete marked lines                                                  *
  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    IF <mark_field> = 'X'.
      DELETE <table> INDEX syst-tabix.
      IF sy-subrc = 0.
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

*&---------------------------------------------------------------------*
*&      Module  STATUS_0900  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0900 OUTPUT.
  SET PF-STATUS 'STATUS_900'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0900  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0900  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0900 INPUT.
  DATA: l_switch TYPE i.

  l_switch = 0.

  PERFORM get_data_b1.
  save_ok = sy-ucomm.
  CASE save_ok.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

    WHEN 'SAVE'.
      CLEAR g_ta_table_wa.
      LOOP AT g_ta_table_itab INTO g_ta_table_wa.
        zfvatb1-name1   = g_ta_table_wa-name1.
        zfvatb1-stceg   = g_ta_table_wa-stceg.
        zfvatb1-shkzg   = g_ta_table_wa-shkzg.
        zfvatb1-waers   = g_ta_table_wa-waers.
        zfvatb1-mwsbk   = g_ta_table_wa-mwsbk.
        zfvatb1-remark  = g_ta_table_wa-remark.
        zfvatb1-zstatus = g_ta_table_wa-zstatus.
        zfvatb1-bukrs   = g_ta_table_wa-bukrs.
        zfvatb1-gsber   = g_ta_table_wa-gsber.
        zfvatb1-gjahr   = g_ta_table_wa-gjahr.
        zfvatb1-monat   = g_ta_table_wa-monat.
        zfvatb1-txdat   = g_ta_table_wa-txdat.
        zfvatb1-tbeln   = g_ta_table_wa-tbeln.
        MODIFY zfvatb1.
        CLEAR g_ta_table_wa.
      ENDLOOP.

      CLEAR wa_itabb1.
      LOOP AT i_itabb1 INTO wa_itabb1.
        CLEAR g_ta_table_wa.
        SORT g_ta_table_itab BY txdat tbeln.
        LOOP AT g_ta_table_itab INTO g_ta_table_wa
          WHERE bukrs EQ wa_itabb1-bukrs AND
                gsber EQ wa_itabb1-gsber AND
                gjahr EQ wa_itabb1-gjahr AND
                monat EQ wa_itabb1-monat AND
                txdat EQ wa_itabb1-txdat AND
                tbeln EQ wa_itabb1-tbeln.
          l_switch = 1.
          CLEAR g_ta_table_wa.
        ENDLOOP.

        IF l_switch = 1.
          l_switch = 0.
        ELSE.
          wa_dele-name1   = wa_itabb1-name1.
          wa_dele-stceg   = wa_itabb1-stceg.
          wa_dele-shkzg   = wa_itabb1-shkzg.
          wa_dele-waers   = wa_itabb1-waers.
          wa_dele-mwsbk   = wa_itabb1-mwsbk.
          wa_dele-remark  = wa_itabb1-remark.
          wa_dele-zstatus = wa_itabb1-zstatus.
          wa_dele-bukrs   = wa_itabb1-bukrs.
          wa_dele-gsber   = wa_itabb1-gsber.
          wa_dele-gjahr   = wa_itabb1-gjahr.
          wa_dele-monat   = wa_itabb1-monat.
          wa_dele-txdat   = wa_itabb1-txdat.
          wa_dele-tbeln   = wa_itabb1-tbeln.
          APPEND wa_dele TO i_dele.
        ENDIF.
        CLEAR wa_itabb1.
      ENDLOOP.

      CLEAR wa_dele.
      LOOP AT i_dele INTO wa_dele.
        SELECT *
          FROM zfvatb1
          WHERE bukrs EQ wa_dele-bukrs AND
                gsber EQ wa_dele-gsber AND
                gjahr EQ wa_dele-gjahr AND
                monat EQ wa_dele-monat AND
                txdat EQ wa_dele-txdat AND
                tbeln EQ wa_dele-tbeln.
          IF sy-subrc = 0.
            DELETE zfvatb1.
          ENDIF.
        ENDSELECT.
        CLEAR wa_dele.
      ENDLOOP.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0900  INPUT

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
* COPY DDIC-TABLE 'ZFVATB4'
* INTO INTERNAL TABLE 'g_TA_TABLE1_itab'
    SELECT * FROM zfvatb4
       INTO CORRESPONDING FIELDS
       OF TABLE g_ta_table1_itab
       WHERE gsber EQ pa_gsber AND
             bukrs EQ pa_bukrs AND
             gjahr EQ pa_gjahr AND
             monat EQ pa_monat.

    IF sy-subrc NE 0.
    ENDIF.
    g_ta_table1_copied = 'X'.
    REFRESH CONTROL 'TA_TABLE1' FROM SCREEN '0910'.
  ENDIF.
ENDMODULE.                    "ta_table1_init OUTPUT

*----------------------------------------------------------------------*
* OUTPUT MODULE FOR TABLECONTROL 'TA_TABLE1':
* MOVE ITAB TO DYNPRO
*----------------------------------------------------------------------*
MODULE ta_table1_move OUTPUT.
  MOVE-CORRESPONDING g_ta_table1_wa TO zfvatb4.
ENDMODULE.                    "ta_table1_move OUTPUT

*----------------------------------------------------------------------*
* OUTPUT MODULE FOR TABLECONTROL 'TA_TABLE1':
* GET LINES OF TABLECONTROL
*----------------------------------------------------------------------*
MODULE ta_table1_get_lines OUTPUT.
  g_ta_table1_lines = sy-loopc.
ENDMODULE.                    "ta_table1_get_lines OUTPUT

*----------------------------------------------------------------------*
* INPUT MODULE FOR TABLECONTROL 'TA_TABLE1': MODIFY TABLE
*----------------------------------------------------------------------*
MODULE ta_table1_modify INPUT.
  MOVE-CORRESPONDING zfvatb4 TO g_ta_table1_wa.
  MODIFY g_ta_table1_itab
    FROM g_ta_table1_wa
    INDEX ta_table1-current_line.
ENDMODULE.                    "ta_table1_modify INPUT

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
ENDMODULE.                    "ta_table1_user_command INPUT

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

  PERFORM get_data_b4.

  save_ok = sy-ucomm.
  CASE save_ok.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

    WHEN 'SAVE'.
      CLEAR g_ta_table1_wa.
      LOOP AT g_ta_table1_itab INTO g_ta_table1_wa.
        zfvatb4-name1   = g_ta_table1_wa-name1.
        zfvatb4-stceg   = g_ta_table1_wa-stceg.
        zfvatb4-shkzg   = g_ta_table1_wa-shkzg.
        zfvatb4-waers   = g_ta_table1_wa-waers.
        zfvatb4-mwsbk   = g_ta_table1_wa-mwsbk.
        zfvatb4-remark  = g_ta_table1_wa-remark.
        zfvatb4-zstatus = g_ta_table1_wa-zstatus.
        zfvatb4-bukrs   = g_ta_table1_wa-bukrs.
        zfvatb4-gsber   = g_ta_table1_wa-gsber.
        zfvatb4-gjahr   = g_ta_table1_wa-gjahr.
        zfvatb4-monat   = g_ta_table1_wa-monat.
        zfvatb4-txdat   = g_ta_table1_wa-txdat.
        zfvatb4-tbeln   = g_ta_table1_wa-tbeln.
        MODIFY zfvatb4.
        CLEAR g_ta_table1_wa.
      ENDLOOP.

      CLEAR wa_itabb4.
      LOOP AT i_itabb4 INTO wa_itabb4.
        CLEAR g_ta_table1_wa.
        SORT g_ta_table1_itab BY txdat tbeln.
        LOOP AT g_ta_table1_itab INTO g_ta_table1_wa
          WHERE bukrs EQ wa_itabb4-bukrs AND
                gsber EQ wa_itabb4-gsber AND
                gjahr EQ wa_itabb4-gjahr AND
                monat EQ wa_itabb4-monat AND
                txdat EQ wa_itabb4-txdat AND
                tbeln EQ wa_itabb4-tbeln.
          l_switch = 1.
          CLEAR g_ta_table1_wa.
        ENDLOOP.

        IF l_switch = 1.
          l_switch = 0.
        ELSE.
          wa_dele-name1   = wa_itabb4-name1.
          wa_dele-stceg   = wa_itabb4-stceg.
          wa_dele-shkzg   = wa_itabb4-shkzg.
          wa_dele-waers   = wa_itabb4-waers.
          wa_dele-mwsbk   = wa_itabb4-mwsbk.
          wa_dele-remark  = wa_itabb4-remark.
          wa_dele-zstatus = wa_itabb4-zstatus.
          wa_dele-bukrs   = wa_itabb4-bukrs.
          wa_dele-gsber   = wa_itabb4-gsber.
          wa_dele-gjahr   = wa_itabb4-gjahr.
          wa_dele-monat   = wa_itabb4-monat.
          wa_dele-txdat   = wa_itabb4-txdat.
          wa_dele-tbeln   = wa_itabb4-tbeln.
          APPEND wa_dele TO i_dele.
        ENDIF.
        CLEAR wa_itabb4.
      ENDLOOP.

      CLEAR wa_dele.
      LOOP AT i_dele INTO wa_dele.
        SELECT *
          FROM zfvatb4
          WHERE bukrs EQ wa_dele-bukrs AND
                gsber EQ wa_dele-gsber AND
                gjahr EQ wa_dele-gjahr AND
                monat EQ wa_dele-monat AND
                txdat EQ wa_dele-txdat AND
                tbeln EQ wa_dele-tbeln.
          IF sy-subrc = 0.
            DELETE zfvatb4.
          ENDIF.
        ENDSELECT.
        CLEAR wa_dele.
      ENDLOOP.
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
*&      Form  GETFIELEDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM getfieleds.
  DATA count TYPE i.

  CLEAR count.
  DO 15 TIMES.
    CLEAR wa_dwn_field.
    ADD 1 TO count.
    CASE count.
      WHEN '1'.
        wa_dwn_field-txt_field = 'Kode Lampiran'.
      WHEN '2'.
        wa_dwn_field-txt_field = 'Kode Status'.
      WHEN '3'.
        wa_dwn_field-txt_field = 'Kode Dokumen'.
      WHEN '4'.
        wa_dwn_field-txt_field = 'NPWP'.
      WHEN '5'.
        wa_dwn_field-txt_field = 'Nama WP'.
      WHEN '6'.
        wa_dwn_field-txt_field = 'Kode Faktur'.
      WHEN '7'.
        wa_dwn_field-txt_field = 'No. Ref. Faktur'.
      WHEN '8'.
        wa_dwn_field-txt_field = 'Nomor Faktur'.
      WHEN '9'.
        wa_dwn_field-txt_field = 'Tanggal Faktur'.
      WHEN '10'.
        wa_dwn_field-txt_field = 'Masa Pajak'.
      WHEN '11'.
        wa_dwn_field-txt_field = 'Tahun Pajak'.
      WHEN '12'.
        wa_dwn_field-txt_field = 'Pembetulan ke'.
      WHEN '13'.
        wa_dwn_field-txt_field = 'Tarif PPN (Tarif PPN / Tarif Efektif)'.
      WHEN '14'.
        wa_dwn_field-txt_field = 'Nilai Perolehan'.
      WHEN '15'.
        wa_dwn_field-txt_field = 'Tarif PPN BM'.
    ENDCASE.
    APPEND wa_dwn_field TO dwn_field.
  ENDDO.
ENDFORM.                    " GETFIELEDS

*&---------------------------------------------------------------------*
*&      Form  SHOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show.
  CALL FUNCTION 'EXCEL_OLE_STANDARD_DAT'
    EXPORTING
      file_name                 = va_name
      data_sheet_name           = 'USER'
    TABLES
      data_tab                  = i_itab
      fieldnames                = dwn_field
    EXCEPTIONS
      file_not_exist            = 1
      filename_expected         = 2
      communication_error       = 3
      ole_object_method_error   = 4
      ole_object_property_error = 5
      invalid_filename          = 6
      invalid_pivot_fields      = 7
      download_problem          = 8
      OTHERS                    = 9.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " SHOW

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_B1_8010
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM download_b1_8010.
  DATA: l_sgtxt LIKE bsas-sgtxt,
        l_txdat(6),
        l_txdat1(6).

  CLEAR: cntr.

  REFRESH: i_itab.
  CLEAR: wa_itabb1.
  LOOP AT i_itabb1 INTO wa_itabb1.

* KODE LAMPIRAN
    MOVE wa_itabb1-zstatus(1)  TO wa_itab-kdlamp.

* KODE STATUS.
    CASE wa_itabb1-zstatus.
      WHEN '41'.
        MOVE '3' TO wa_itab-kdstat.
      WHEN '42'.
        MOVE '1' TO wa_itab-kdstat.
      WHEN '43'.
        MOVE '4' TO wa_itab-kdstat.
      WHEN '44'.
        MOVE '2' TO wa_itab-kdstat.
      WHEN '47'.
        CONCATENATE pa_gjahr pa_monat INTO l_txdat.
        l_txdat1 = wa_itabb1-txdat(6).
        IF l_txdat1 = l_txdat.
          wa_itab-kdstat = '2'.
        ELSE.
          wa_itab-kdstat = '4'.
        ENDIF.
    ENDCASE.

* KODE DOKUMEN, NILAI PEROLEHAN
    wa_itabb1-mwsbk = wa_itabb1-mwsbk * 10.
    IF wa_itabb1-shkzg EQ 'H'.
      wa_itab-kddocu = '5'.
      WRITE wa_itabb1-mwsbk TO va_nilppn CURRENCY 'IDR' NO-GROUPING.
      SHIFT va_nilppn LEFT DELETING LEADING space.
      CONCATENATE '-' va_nilppn INTO wa_itab-nilppn.
    ELSE.
      IF wa_itabb1-zstatus EQ '41' OR
         wa_itabb1-zstatus EQ '42'.
        wa_itab-kddocu = '3'.
      ELSEIF wa_itabb1-zstatus EQ '47'.
        wa_itab-kddocu = '7'.
      ELSE.
        wa_itab-kddocu = '2'.
      ENDIF.

      WRITE wa_itabb1-mwsbk TO va_nilppn CURRENCY 'IDR' NO-GROUPING.
      MOVE  va_nilppn       TO wa_itab-nilppn.
    ENDIF.

* NPWP
    IF wa_itab-kddocu EQ '1' OR
      wa_itab-kddocu EQ '4'.
      MOVE space TO wa_itab-npwp.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = wa_itabb1-stceg
        IMPORTING
          npwp_out = wa_itab-npwp.
    ENDIF.

* NAMA WAJIB PAJAK
    IF wa_itab-kddocu EQ '1' OR
      wa_itab-kddocu EQ '4'.
      MOVE space TO wa_itab-nmwp.
    ELSE.
      MOVE wa_itabb1-name1 TO wa_itab-nmwp.
    ENDIF.

* KODE FAKTUR
    IF wa_itab-kddocu EQ '2'.
      wa_itab-kdfktr = wa_itabb1-tbeln(9).
    ELSEIF wa_itab-kddocu EQ '5'.
      SELECT SINGLE sgtxt
        FROM bsas
        INTO l_sgtxt
        WHERE bukrs EQ pa_bukrs        AND
              hkont EQ '0142200200'    AND
              zuonr EQ wa_itabb1-tbeln.
      wa_itab-kdfktr = l_sgtxt(9).
    ELSE.
      MOVE space TO wa_itab-kdfktr.
    ENDIF.

* NO. REF. FAKTUR
    IF wa_itab-kddocu EQ '5'.
      wa_itab-noref = l_sgtxt+10(7).
    ELSE.
      MOVE space TO wa_itab-noref.
    ENDIF.

* NO. FAKTUR
    IF wa_itab-kddocu EQ '2'.
      wa_itab-nofktr = wa_itabb1-tbeln+10(7).
    ELSEIF wa_itab-kddocu EQ '3' OR
           wa_itab-kddocu EQ '5' OR
           wa_itab-kddocu EQ '7'.
      wa_itab-nofktr = wa_itabb1-tbeln.
    ENDIF.

* TANGGAL FAKTUR
    CONCATENATE wa_itabb1-txdat+6(2)
                wa_itabb1-txdat+4(2)
                wa_itabb1-txdat+0(4)
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

    IF wa_itabb1-zstatus EQ '41' OR
       wa_itabb1-zstatus EQ '42' OR
       wa_itabb1-zstatus EQ '43' OR
       wa_itabb1-zstatus EQ '44' OR
       wa_itabb1-zstatus EQ '45' OR
       wa_itabb1-zstatus EQ '46' OR
       wa_itabb1-zstatus EQ '47' OR
       wa_itabb1-zstatus EQ '48' OR
       wa_itabb1-zstatus EQ '49' OR
       wa_itabb1-zstatus EQ '50' OR
       wa_itabb1-zstatus EQ '51'.
      APPEND wa_itab TO i_itab.
    ENDIF.
    CLEAR: wa_itabb1.
  ENDLOOP.

  DESCRIBE TABLE i_itab LINES cntr.

  IF cntr NE 0.
    PERFORM validasi.
    IF error <> 0.
      PERFORM cetak_error.
    ELSE.
      PERFORM move_to_alv.
*      PERFORM F_DOWNLOAD_PC_B1.
    ENDIF.
  ELSE.
    MESSAGE i000(zm) WITH 'Data not found'.
  ENDIF.
ENDFORM.                    " DOWNLOAD_B1_8010

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_B4_8010
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM download_b4_8010.
  DATA: l_txdat(6),
        l_txdat1(6),
        v_len1 TYPE i.

  CLEAR: cntr.

  REFRESH: i_itab.
  CLEAR: wa_itabb4.
  LOOP AT i_itabb4 INTO wa_itabb4.

* KODE LAMPIRAN
    wa_itab-kdlamp = '7'.

* KODE STATUS.
    CONCATENATE pa_gjahr pa_monat INTO l_txdat.
    l_txdat1 = wa_itabb4-txdat(6).
    IF l_txdat1 = l_txdat.
      wa_itab-kdstat = '1'.
    ELSE.
      wa_itab-kdstat = '2'.
    ENDIF.

* KODE DOKUMEN, NILAI PEROLEHAN
    v_len1 = STRLEN( wa_itabb4-tbeln ).
    IF v_len1 EQ 17.
      wa_itab-kddocu = '2'.
    ELSE.
      wa_itab-kddocu = '7'.
    ENDIF.
    wa_itabb4-mwsbk = wa_itabb4-mwsbk * 10.
    IF wa_itabb4-shkzg EQ 'H'.
      WRITE wa_itabb4-mwsbk TO va_nilppn CURRENCY 'IDR' NO-GROUPING.
      SHIFT va_nilppn LEFT DELETING LEADING space.
      CONCATENATE '-' va_nilppn INTO wa_itab-nilppn.
    ELSE.
      WRITE wa_itabb4-mwsbk TO va_nilppn CURRENCY 'IDR' NO-GROUPING.
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
          npwp_in  = wa_itabb4-stceg
        IMPORTING
          npwp_out = wa_itab-npwp.
    ENDIF.

* NAMA WAJIB PAJAK
    IF wa_itab-kddocu EQ '1' OR
      wa_itab-kddocu EQ '3' OR
      wa_itab-kddocu EQ '4'.
      MOVE space TO wa_itab-nmwp.
    ELSE.
      MOVE wa_itabb4-name1 TO wa_itab-nmwp.
    ENDIF.

* KODE FAKTUR
    IF wa_itab-kddocu EQ '2'.
      wa_itab-kdfktr = wa_itabb4-tbeln(9).
    ELSE.
      MOVE space TO wa_itab-kdfktr.
    ENDIF.

* NO. REF. FAKTUR
    IF wa_itab-kddocu EQ '5'.
    ELSE.
      MOVE space TO wa_itab-noref.
    ENDIF.

* NO. FAKTUR
    IF wa_itab-kddocu EQ '2'.
      wa_itab-nofktr = wa_itabb4-tbeln+10(7).
    ELSEIF wa_itab-kddocu EQ '7'.
      wa_itab-kdfktr = wa_itabb4-tbeln.
    ENDIF.

* TANGGAL FAKTUR
    CONCATENATE wa_itabb4-txdat+6(2)
                wa_itabb4-txdat+4(2)
                wa_itabb4-txdat+0(4)
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

    IF wa_itabb4-zstatus EQ '60' OR
       wa_itabb4-zstatus EQ '61' OR
       wa_itabb4-zstatus EQ '62' OR
       wa_itabb4-zstatus EQ '63' OR
       wa_itabb4-zstatus EQ '64' OR
       wa_itabb4-zstatus EQ '65' OR
       wa_itabb4-zstatus EQ '66'.
      APPEND wa_itab TO i_itab.
    ENDIF.
    CLEAR: wa_itabb4.
  ENDLOOP.

  DESCRIBE TABLE i_itab LINES cntr.

  IF cntr NE 0.
    PERFORM validasi.
    IF error <> 0.
      PERFORM cetak_error.
    ELSE.
      PERFORM move_to_alv.
*      PERFORM F_DOWNLOAD_PC_B4.
    ENDIF.
  ELSE.
    MESSAGE i000(zm) WITH 'Data not found'.
  ENDIF.
ENDFORM.                    " DOWNLOAD_B4_8010

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
*&      Form  F_DOWNLOAD_ESPT_B1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download_espt_b1.
  DATA: ld_vatpr LIKE zfvato-vatpr,
        ld_vatno LIKE zfvato-vatno,
        ld_dudat LIKE zfvato-dudat,
        ld_dueyr LIKE zfvato-dueyr,
        ld_duemm LIKE zfvato-duemm,
        ld_sspdt LIKE zfvato-sspdt,
        ld_netwr LIKE zfvato-netwr,
        fname(128).

  ta_date-sign   = 'I'.
  ta_date-option = 'BT'.
  CONCATENATE pa_gjahr pa_monat '01' INTO ta_date-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ta_date-low
    IMPORTING
      last_day_of_month = ta_date-high.
  APPEND ta_date.

  CLEAR: wa_itabb1,i_espt,i_itab.
  LOOP AT i_itabb1 INTO wa_itabb1.
    CLEAR: ld_vatpr,ld_dudat,ld_dueyr,ld_duemm,ld_sspdt,ld_netwr,
           ld_vatno.
    CLEAR: wa_espt11-kodepjk,wa_espt11-kodelam,wa_espt11-kodests,
           wa_espt11-kodedok,wa_espt11-npwp,wa_espt11-nama,
           wa_espt11-tglfkt,wa_espt11-tglssp,wa_espt11-nodok,wa_espt11-jnsdok,
           wa_espt11-nodok1,wa_espt11-jnsdok1,wa_espt11-masapjk,wa_espt11-thnpjk,
           wa_espt11-betul,wa_espt11-dpp,
           wa_espt11-ppn,wa_espt11-ppnbm.

    wa_espt11-flagvat  = '0'.

    IF wa_itabb1-zstatus EQ '41' OR
       wa_itabb1-zstatus EQ '42' OR
       wa_itabb1-zstatus EQ '43' OR
       wa_itabb1-zstatus EQ '44' OR
       wa_itabb1-zstatus EQ '45' OR
       wa_itabb1-zstatus EQ '46' OR
       wa_itabb1-zstatus EQ '47' OR
       wa_itabb1-zstatus EQ '48' OR
       wa_itabb1-zstatus EQ '49' OR
       wa_itabb1-zstatus EQ '50' OR
       wa_itabb1-zstatus EQ '51'.
    ELSE.
      CONTINUE.
    ENDIF.

    IF wa_itabb1-txdat > ta_date-high.
      CONTINUE.
    ENDIF.

    IF wa_itabb1-tbeln IS INITIAL.
      CONTINUE.
    ELSE.
      WRITE wa_itabb1-tbeln USING EDIT MASK '___.___-__.________' TO wa_espt11-nodok.
    ENDIF.
    wa_espt11-jnsdok   = '0'.

    IF wa_itabb1-stceg1 IS INITIAL.
      CLEAR: wa_espt11-nodok1.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = wa_itabb1-stceg1
        IMPORTING
          npwp_out = wa_itabb1-stceg1.
      WRITE wa_itabb1-stceg1 USING EDIT MASK '__.___.___._-___.___' TO wa_espt11-nodok1.
    ENDIF.
    wa_espt11-jnsdok1  = '0'.

    wa_espt11-kodepjk = 'B'.
    IF wa_itabb1-stceg IS INITIAL.
      wa_espt11-npwp  = '000000000000000'.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = wa_itabb1-stceg
        IMPORTING
          npwp_out = wa_espt11-npwp.
    ENDIF.
    wa_espt11-nama    = wa_itabb1-name1.

    IF wa_itabb1-txdat(4) GT 2006.
      IF wa_itabb1-shkzg EQ 'H'.
        wa_espt11-kodelam = '2'.
        wa_espt11-kodests = '1'.
        wa_espt11-kodedok = '1'.
      ELSE.
        IF wa_itabb1-zstatus EQ '42'.
          wa_espt11-kodelam = '2'.
          wa_espt11-kodests = '1'.
          wa_espt11-kodedok = '2'.
        ELSE.
          wa_espt11-kodelam = '2'.
          wa_espt11-kodests = wa_itabb1-tbeln+1(1).
          wa_espt11-kodedok = '1'.
        ENDIF.
      ENDIF.
    ELSE.
      wa_espt11-kodelam = '2'.
      wa_espt11-kodests = '1'.
      wa_espt11-kodedok = '1'.
    ENDIF.
    CONCATENATE wa_itabb1-monat wa_itabb1-monat INTO wa_espt11-masapjk.
    wa_espt11-thnpjk  = wa_itabb1-gjahr.
    wa_espt11-betul   = '0'.
    wa_espt11-dpp = '0'.
    wa_espt11-ppnbm   = '0'.

    IF wa_itabb1-shkzg EQ 'H'.
      IF wa_itabb1-mwsbk < 0.
        wa_itabb1-mwsbk = wa_itabb1-mwsbk * -1.
        wa_itabb1-zdpp = wa_itabb1-zdpp * -1.
      ENDIF.
      IF wa_itabb1-mwsbk IS INITIAL.
        wa_espt11-ppn = '0'.
        wa_espt11-dpp = '0'.
      ELSE.
        wa_itabb1-mwsbk = wa_itabb1-mwsbk * 100.
        WRITE wa_itabb1-mwsbk TO wa_espt11-ppn
                              USING EDIT MASK '- _____________'
                              DECIMALS 0.
        wa_itabb1-zdpp = wa_itabb1-zdpp * 100.
        WRITE wa_itabb1-zdpp TO wa_espt11-dpp
                              USING EDIT MASK '- _____________'
                              DECIMALS 0.
      ENDIF.
    ELSE.
      IF wa_itabb1-mwsbk IS INITIAL.
        wa_espt11-ppn = '0'.
        wa_espt11-dpp = '0'.
      ELSE.
        wa_itabb1-mwsbk = wa_itabb1-mwsbk * 100.
        WRITE wa_itabb1-mwsbk TO wa_espt11-ppn
                              DECIMALS 0.
        wa_itabb1-zdpp = wa_itabb1-zdpp * 100.
        WRITE wa_itabb1-zdpp TO wa_espt11-dpp
                              DECIMALS 0.
      ENDIF.
    ENDIF.

    DO 3 TIMES.
      REPLACE '.' WITH space INTO wa_espt11-ppn.
      CONDENSE wa_espt11-ppn NO-GAPS.
      REPLACE '.' WITH space INTO wa_espt11-dpp.
      CONDENSE wa_espt11-dpp NO-GAPS.
    ENDDO.

    IF NOT wa_itabb1-txdat IS INITIAL.
      WRITE wa_itabb1-txdat TO wa_espt11-tglfkt
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
    CONCATENATE 'C:\FILEB1_' pa_bukrs '_' pa_monat '.CSV' INTO fname.

*Begin remark Unicode conversion - DEVK965581
*06.03.2020 - SOL_FELIX
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
*End remark Unicode conversion - DEVK965581
*Begin insert Unicode conversion - DEVK965581
*06.03.2020 - SOL_FELIX

    DATA: lv_filename TYPE string.
    CLEAR lv_filename.
    lv_filename = fname.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_filename
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

    IF sy-subrc EQ 0.
      MESSAGE i000(zf) WITH 'Download Success'.
    ENDIF.
*End insert Unicode conversion - DEVK965581
  ENDIF.
ENDFORM.                    " F_DOWNLOAD_ESPT_B1

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_ESPT_B4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download_espt_b4 .
  DATA: ld_vatpr LIKE zfvato-vatpr,
        ld_vatno LIKE zfvato-vatno,
        ld_dudat LIKE zfvato-dudat,
        ld_dueyr LIKE zfvato-dueyr,
        ld_duemm LIKE zfvato-duemm,
        ld_sspdt LIKE zfvato-sspdt,
        ld_netwr LIKE zfvato-netwr,
        fname(128).

  DATA: l_text(7),
        l_stat(2),
        l_stat1(2).
  DATA: l_npwp LIKE zfvatb1-stceg,
        l_nofak(10).

  CLEAR: wa_itabb4,i_espt,i_itab.
  LOOP AT i_itabb4 INTO wa_itabb4.
    CLEAR: ld_vatpr,ld_dudat,ld_dueyr,ld_duemm,ld_sspdt,ld_netwr,
           ld_vatno.
    CLEAR: wa_espt11-kodepjk,wa_espt11-kodelam,wa_espt11-kodests,
           wa_espt11-kodedok,wa_espt11-npwp,wa_espt11-nama,
           wa_espt11-tglfkt,wa_espt11-tglssp,wa_espt11-nodok,wa_espt11-jnsdok,
           wa_espt11-nodok1,wa_espt11-jnsdok1,wa_espt11-masapjk,wa_espt11-thnpjk,
           wa_espt11-betul,wa_espt11-dpp,
           wa_espt11-ppn,wa_espt11-ppnbm.

    wa_espt11-flagvat  = '0'.

    IF wa_itabb4-zstatus EQ '60' OR
       wa_itabb4-zstatus EQ '61' OR
       wa_itabb4-zstatus EQ '62' OR
       wa_itabb4-zstatus EQ '63' OR
       wa_itabb4-zstatus EQ '64' OR
       wa_itabb4-zstatus EQ '65' OR
       wa_itabb4-zstatus EQ '66'.
    ELSE.
      CONTINUE.
    ENDIF.

    IF wa_itabb4-tbeln IS INITIAL.
      CONTINUE.
    ELSE.
      WRITE wa_itabb4-tbeln USING EDIT MASK '___.___-__.________' TO wa_espt11-nodok.
    ENDIF.
    wa_espt11-jnsdok   = '0'.

    IF wa_itabb4-stceg1 IS INITIAL.
      CLEAR: wa_espt11-nodok1.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = wa_itabb4-stceg1
        IMPORTING
          npwp_out = wa_itabb4-stceg1.
      WRITE wa_itabb4-stceg1 USING EDIT MASK '__.___.___._-___.___' TO wa_espt11-nodok1.
    ENDIF.
    wa_espt11-jnsdok1  = '0'.

    wa_espt11-kodepjk = 'B'.
    wa_espt11-kodelam = '3'.
    IF wa_itabb4-txdat(4) GT 2006.
      IF wa_itabb4-shkzg EQ 'H'.
        wa_espt11-kodests = '1'..
      ELSE.
        wa_espt11-kodests = wa_itabb4-tbeln+1(1).
      ENDIF.
    ELSE.
      wa_espt11-kodests = '1'.
    ENDIF.
    wa_espt11-kodedok = '1'.

    IF wa_itabb4-stceg IS INITIAL.
      wa_espt11-npwp  = '000000000000000'.
    ELSE.
      CALL FUNCTION 'ZF_NPWP_MODIFICATION'
        EXPORTING
          npwp_in  = wa_itabb4-stceg
        IMPORTING
          npwp_out = wa_espt11-npwp.
    ENDIF.
    wa_espt11-nama    = wa_itabb4-name1.
    CONCATENATE wa_itabb4-monat wa_itabb4-monat INTO wa_espt11-masapjk.
    wa_espt11-thnpjk  = wa_itabb4-gjahr.
    wa_espt11-betul   = '0'.
    wa_espt11-dpp = '0'.
    wa_espt11-ppnbm   = '0'.

    IF wa_itabb4-shkzg EQ 'H'.
      IF wa_itabb4-mwsbk < 0.
        wa_itabb4-mwsbk = wa_itabb4-mwsbk * -1.
        wa_itabb4-zdpp = wa_itabb4-zdpp * -1.
      ENDIF.
      IF wa_itabb4-mwsbk IS INITIAL.
        wa_espt11-ppn = '0'.
        wa_espt11-dpp = '0'.
      ELSE.
        wa_itabb4-mwsbk = wa_itabb4-mwsbk * 100.
        WRITE wa_itabb4-mwsbk TO wa_espt11-ppn
                              USING EDIT MASK '- _____________'
                              DECIMALS 0.
        wa_itabb4-zdpp = wa_itabb4-zdpp * 100.
        WRITE wa_itabb4-zdpp TO wa_espt11-dpp
                              USING EDIT MASK '- _____________'
                              DECIMALS 0.
      ENDIF.
    ELSE.
      IF wa_itabb4-mwsbk IS INITIAL.
        wa_espt11-ppn = '0'.
        wa_espt11-dpp = '0'.
      ELSE.
        wa_itabb4-mwsbk = wa_itabb4-mwsbk * 100.
        WRITE wa_itabb4-mwsbk TO wa_espt11-ppn
                              DECIMALS 0.
        wa_itabb4-zdpp = wa_itabb4-zdpp * 100.
        WRITE wa_itabb4-zdpp TO wa_espt11-dpp
                              DECIMALS 0.
      ENDIF.
    ENDIF.

    DO 3 TIMES.
      REPLACE '.' WITH space INTO wa_espt11-ppn.
      CONDENSE wa_espt11-ppn NO-GAPS.
      REPLACE '.' WITH space INTO wa_espt11-dpp.
      CONDENSE wa_espt11-dpp NO-GAPS.
    ENDDO.

    IF NOT wa_itabb4-txdat IS INITIAL.
      WRITE wa_itabb4-txdat TO wa_espt11-tglfkt
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
    CONCATENATE 'C:\FILEB4_' pa_bukrs '_' pa_monat '.CSV' INTO fname.

*Begin remark Unicode conversion - DEVK965581
*06.03.2020 - SOL_FELIX
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
*End remark Unicode conversion - DEVK965581
*Begin insert Unicode conversion - DEVK965581
*06.03.2020 - SOL_FELIX

    DATA: lv_filename TYPE string.
    CLEAR lv_filename.
    lv_filename = fname.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_filename
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

    IF sy-subrc EQ 0.
      MESSAGE i000(zf) WITH 'Download Success'.
    ENDIF.
*End insert Unicode conversion - DEVK965581

  ENDIF.
ENDFORM.                    " F_DOWNLOAD_ESPT_B4
