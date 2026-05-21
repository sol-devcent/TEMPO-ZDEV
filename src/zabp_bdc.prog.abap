*$*$--------------------------------------------------------------------
*$*$ History
*$*$ Date         Programmer Ref.Document/Description
*$*$--------------------------------------------------------------------
TABLES: apqi,
        apqd,
        t100.

TYPE-POOLS: sydes.

CONSTANTS: c_bdc_yes VALUE '1',
           c_bdc_no  VALUE '0'.

DATA: BEGIN OF t_bdc_group OCCURS 0,
        grptx(20),                    "IBM_humayun
        atext(20),
      END OF t_bdc_group.

DATA: BEGIN OF t_bdcdata OCCURS 10.    " Internal table that stores
        INCLUDE STRUCTURE bdcdata.     " the BDC table data for the
DATA: END OF t_bdcdata.                " Call Transaction

DATA: BEGIN OF t_bdcmsg OCCURS 10.     " Internal table that stores
        INCLUDE STRUCTURE bdcmsgcoll.  " the BDC table data for the
DATA: END OF t_bdcmsg.                 " Call Transaction

DATA: d_bdc_sydes TYPE sydes_desc,
      d_bdc_rbexc VALUE 'X',
      d_bdc_logal,
      d_bdc_rbbdc,
      d_bdc_intlz,
      d_bdc_jobnm LIKE apqi-groupid,
      d_bdc_screen VALUE 'E',
      d_bdc_batch VALUE 'E',
      d_bdc_cbbdc VALUE ' ',
      d_cbdwn VALUE 'X',
      d_cbkeep,
      d_bdc_mode VALUE 'N',
      d_bdc_param,
      d_bdc_error                LIKE sy-subrc,   "IBM
      d_bdc_apqid LIKE apqi-qid,
      d_bdc_update VALUE 'S',
      d_bdc_grptx(2),
      d_bdc_session(12),
      d_bdc_cbonc,
      d_bdc_lngth TYPE i,
      d_bdc_memvl(12),
      d_bdc_subrc LIKE sy-subrc,
      d_bdc_cprog LIKE sy-cprog,
      d_bdc_uzeit LIKE sy-uzeit,
      d_bdc_imdte LIKE btch0000-char1,
      d_bdc_strdate LIKE tbtcjob-sdlstrtdt,
      d_bdc_strtime LIKE tbtcjob-sdlstrttm,
      d_bdc_nobinpt VALUE space,
      d_bdc_indic(80),
      d_bdc_tcode LIKE sy-tcode,
      d_bdc_options LIKE ctu_params,
      d_bdc_defsize    VALUE 'X',
      d_bdc_sm35,
      d_bdc_tabix LIKE sy-tabix,
      d_bdc_title(70),
      d_bdc_dpmsg,
      d_bdc_count(6) TYPE n,
      d_bdc_maxcn(6) TYPE n,
      d_bdc_ermsg(255),
      d_bdc_intsf,
      d_bdc_jobcount LIKE tbtcjob-jobcount,
      d_bdc_jobname LIKE tbtcjob-jobname,
      d_bdc_tctxt(80) VALUE 'Run TCODE &1 (&2/&3)',
      d_bdc_sessn(80) VALUE 'Run BDC session &1 (&2/&3)',
      d_dwnld LIKE rlgrap-filename.

DATA: BEGIN OF r_message OCCURS 0,
        sign,
        option(2),
        low(5),
        high(5),
      END OF r_message.

RANGES: r_bdc_datum FOR sy-datum,
        r_bdc_uzeit FOR sy-uzeit,
        r_bdc_cprog FOR sy-cprog,
        r_bdc_uname FOR sy-uname.
DATA: sp_bdc_begda LIKE sy-datum,
      sp_bdc_endda LIKE sy-datum.

DATA: d_bdc_datum(10),
      d_bdc_aetim(8).

*-----------------------------------------------------------------------
* @form        MACRO_BDC_PARAMETERS
* @description Macro to display selection-screens to use with
*              F_BDC_CALL_TCODE_SESSION
*-----------------------------------------------------------------------
DEFINE macro_bdc_parameters.
  selection-screen skip.
  selection-screen begin of block b_block1 with frame title c_title.
  selection-screen begin of line.
  selection-screen position 1.
  parameters p_rbexc radiobutton group rb1 default 'X'.
  selection-screen comment 03(26) c_rbexc.
  selection-screen position 33.
  parameters p_batch like rfpdo-allgazmd obligatory default 'E'.
  selection-screen end of line.

  selection-screen begin of line.
  selection-screen position 04.
  parameters p_cbbdc as checkbox default 'X'.
  selection-screen comment 06(42) c_cbbdc.
  selection-screen end of line.
  selection-screen skip.

  selection-screen begin of line.
  selection-screen position 1.
  parameters p_rbbdc radiobutton group rb1.
  selection-screen comment 03(24) c_rbbdc.
  selection-screen position 33.
  parameters p_bdcnm(12).
  selection-screen end of line.

  selection-screen begin of line.
  selection-screen position 04.
  parameters: p_rbtim radiobutton group rb2.
  selection-screen comment 06(20) c_rbdat.
  selection-screen position 33.
  parameters p_datum like sy-datum.
  selection-screen comment 50(2) c_rbtim.
  selection-screen position 53.
  parameters p_uzeit like sy-uzeit.
  selection-screen end of line.

  selection-screen begin of line.
  selection-screen position 04.
  parameters: p_rbimd radiobutton group rb2.
  selection-screen comment 06(20) c_rbimd.
  selection-screen end of line.

  selection-screen begin of line.
  selection-screen position 04.
  parameters: p_rbpol radiobutton group rb2.
  selection-screen comment 06(40) c_rbpol.
  selection-screen end of line.
  selection-screen end of block b_block1.

at selection-screen on p_batch.
  if 'AEN' na p_batch.
    message id '1A' type 'E' number 001.
  endif.
END-OF-DEFINITION.

*-----------------------------------------------------------------------
* @form        MACRO_BDC_SCREEN_INIT
* @description Macro to init selection-screen in MACRO_BDC_PARAMETERS
*              to use with F_BDC_CALL_TCODE_SESSION
*-----------------------------------------------------------------------
DEFINE macro_bdc_screen_init.
  c_title = 'Execute type'.
  c_rbexc = 'Batch Input'.
  c_cbbdc = 'Create BDC session when error'.
  c_rbbdc = 'BDC session'.
  c_rbdat = 'Start date'.
  c_rbtim = 'at'.
  c_rbimd = 'Start immediately'.
  c_rbpol = 'Pooled (Executed later with SM35)'.
*  C_CBONC = 'Create BDC session for each data'.
END-OF-DEFINITION.

DEFINE macro_bdc_initialization.

initialization.
  p_datum = sy-datum.
  p_uzeit = sy-uzeit.
  d_bdc_error = 0.
END-OF-DEFINITION.

*-----------------------------------------------------------------------
* @form        MACRO_BDC_PASS_VALUE
* @description Macro to passing selection-screens value to global data
*              to use with F_BDC_CALL_TCODE_SESSION
*-----------------------------------------------------------------------
DEFINE macro_bdc_pass_value.
  d_bdc_rbexc = p_rbexc.
  if p_rbexc ne space.
    d_bdc_batch = p_batch.
    d_bdc_cbbdc = p_cbbdc.
  else.
    d_bdc_rbbdc = p_rbbdc.
    clear: d_bdc_batch, d_bdc_cbbdc.
  endif.
  d_bdc_imdte = p_rbimd.
  d_bdc_jobname = p_bdcnm.
  d_bdc_strdate = p_datum.
  d_bdc_strtime = p_uzeit.
  d_bdc_sm35 = p_rbpol.
END-OF-DEFINITION.

*-----------------------------------------------------------------------
* @form        F_BDC_DATA
* @description Mapping bdc data for screen also for field.
* @param       Ft_bdcdata
* @par-desc    collect bdc data
* @param       FU_TYPES
* @par-desc    type of mapped data
* @par-value   'X' screen mapping, ' ' field mapping
* @param       FU_FIELD
* @par-desc    for screen mapping - program name
*              for field mapping - field name
* @param       FU_VALUE
* @par-desc    for screen mapping - screen number
*              for field mapping - field value
*-----------------------------------------------------------------------
FORM f_bdc_data TABLES ft_bdcdata STRUCTURE bdcdata
                USING  fu_types fu_field fu_value.
  FIELD-SYMBOLS: <lf_value>.
  CHECK d_bdc_error EQ 0.
  CLEAR ft_bdcdata.
  MOVE fu_types TO ft_bdcdata-dynbegin.
  IF fu_types EQ 'X'.
    MOVE fu_field TO ft_bdcdata-program.
    MOVE fu_value TO ft_bdcdata-dynpro.
  ELSE.
    ASSIGN fu_value TO <lf_value>.
    MOVE fu_field TO ft_bdcdata-fnam.
    MOVE <lf_value> TO ft_bdcdata-fval.
  ENDIF.
  APPEND ft_bdcdata.
ENDFORM.                    "f_bdc_data

*-----------------------------------------------------------------------
* @form        F_BDC_SCREEN
* @description Mapping screen data for bdc
* @param       Ft_bdcdata
* @par-desc    collect bdc data
* @param       FU_PROGRAM
* @par-desc    program name
* @param       FU_SCREEN
* @par-desc    screen number
*-----------------------------------------------------------------------
FORM f_bdc_screen TABLES ft_bdcdata STRUCTURE bdcdata
                  USING  fu_program fu_screen.
  CLEAR ft_bdcdata.
  ft_bdcdata-program  = fu_program.
  ft_bdcdata-dynpro   = fu_screen.
  ft_bdcdata-dynbegin = 'X'.
  APPEND ft_bdcdata.
ENDFORM.                    "f_bdc_screen

*-----------------------------------------------------------------------
* @form        F_BDC_FIELD
* @description Mapping field value for bdc
* @param       Ft_bdcdata
* @par-desc    collect bdc data
* @param       FU_FIELD
* @par-desc    field name
* @param       FU_VALUE
* @par-desc    field value
*-----------------------------------------------------------------------
FORM f_bdc_field TABLES ft_bdcdata STRUCTURE bdcdata
                 USING  fu_field fu_value.
  CASE fu_value.
    WHEN ''.
    WHEN OTHERS.
      CLEAR ft_bdcdata.
      ft_bdcdata-fnam = fu_field.
      ft_bdcdata-fval = fu_value.
      APPEND ft_bdcdata.
  ENDCASE.
ENDFORM.                    "f_bdc_field

*-----------------------------------------------------------------------
* @form        F_BDC_FIELD_STEPLOOP
* @description Mapping steploop field value for bdc
* @param       Ft_bdcdata
* @par-desc    collect bdc data
* @param       FU_FIELD
* @par-desc    field name
* @param       FU_STEPLOOP
* @par-desc    step loop index to fill
* @param       FU_VALUE
* @par-desc    field value
*-----------------------------------------------------------------------
FORM f_bdc_field_steploop TABLES ft_bdcdata STRUCTURE bdcdata
                          USING  fu_field fu_steploop fu_value.
  DATA: ld_field(25).
  CONCATENATE fu_field '(' fu_steploop ')' INTO ld_field.
  PERFORM f_bdc_field TABLES ft_bdcdata
                      USING  ld_field fu_value.
ENDFORM.                    "f_bdc_field_steploop

*-----------------------------------------------------------------------
* @form        F_BDC_CALL_TCODE
* @description Call SAP transaction
*              Ft_bdcdata will be reseted after this function call.
*              SY-SUBRC = 0 Processing was succesful
*              SY-SUBRC NE 0 Transaction ended with an error
*              check T_BDCMSG for error msg
*              or use F_BDC_GETMSG / F_BDC_SHOWMSG
* @param       Ft_bdcdata
* @par-desc    collect bdc data
* @param       FT_BDCMSG
* @par-desc    collect bdc msg
* @param       FU_TCODE
* @par-desc    SAP transaction name
* @param       FU_MODE
* @par-desc    batch input session mode
* @par-val     'A' - Display screen
*              'E' - Display screen only if an error occurs
*              'N' - C_BDC_no display
* @param       FU_TEXT
* @par-desc    text indicator and show it while calling this form
* @par-val     SPACE - not showing text indicator
*-----------------------------------------------------------------------
FORM f_bdc_call_tcode TABLES ft_bdcdata STRUCTURE bdcdata
                             ft_bdcmsg STRUCTURE bdcmsgcoll
                      USING fu_tcode fu_mode fu_text.
  CLEAR ft_bdcmsg. REFRESH ft_bdcmsg.
  IF fu_text <> space.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text = fu_text.
  ENDIF.
*{   REPLACE        P01K910487                                        1
*\  CALL TRANSACTION fu_tcode USING ft_bdcdata
  CALL TRANSACTION fu_tcode USING ft_bdcdata       "#EC CI_CALLTA     "Start SOH: Shell SCI Adjustment 20240226 KRS
*}   REPLACE
                            MODE  fu_mode
                            MESSAGES INTO ft_bdcmsg.
  CLEAR ft_bdcdata. REFRESH ft_bdcdata.
ENDFORM.                    "f_bdc_call_tcode

*-----------------------------------------------------------------------
* @form        F_BDC_GETMSG
* @description Get msg from itab
* @param       FT_BDCMSG
* @par-desc    bdc msg collector
* @param       FU_MSGTYP
* @par-desc    last msg typ to show
* @par-val     SPACE - search last msg
* @param       FC_TEXT
* @par-desc    msg get from itab, char(80)
*-----------------------------------------------------------------------
FORM f_bdc_getmsg TABLES ft_bdcmsg STRUCTURE bdcmsgcoll
                  USING fu_msgtyp
                  CHANGING fc_text.
  FIELD-SYMBOLS <lf_msg>.
  DATA: ld_field(15) VALUE 'LT_BDCMSG-MSGV0'.
  DATA: BEGIN OF lt_bdcmsg OCCURS 0.
          INCLUDE STRUCTURE bdcmsgcoll.
  DATA: END OF lt_bdcmsg.
  fc_text = space.
  lt_bdcmsg[] = ft_bdcmsg[].
  IF fu_msgtyp <> space.
    DELETE lt_bdcmsg WHERE msgtyp <> fu_msgtyp.
  ENDIF.
* Get the last message in ITAB
  LOOP AT lt_bdcmsg.
  ENDLOOP.
  CHECK sy-subrc = 0.

  SELECT SINGLE * FROM t100 WHERE sprsl = lt_bdcmsg-msgspra
                              AND arbgb = lt_bdcmsg-msgid
                              AND msgnr = lt_bdcmsg-msgnr.
  CHECK sy-subrc = 0.
  fc_text = t100-text.
* Format the message by replacing &/$ with sy-msgv1,..sy-msgv4
  DO 4 TIMES.
    ld_field+14(1) = sy-index.
    ASSIGN (ld_field) TO <lf_msg>.
    IF fc_text CA '&'.
      REPLACE '&' WITH <lf_msg> INTO fc_text.
    ELSE.
      REPLACE '$' WITH <lf_msg> INTO fc_text.
    ENDIF.
    CONDENSE fc_text.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
  ENDDO.
ENDFORM.                    "f_bdc_getmsg

*-----------------------------------------------------------------------
* @form        F_BDC_SHOWMSG
* @description Get msg from itab and show as indicator
* @param       FT_BDCMSG
* @par-desc    bdc msg collector
* @param       FU_MSGTYP
* @par-desc    last msg typ to show
* @par-val     SPACE - search last msg
*-----------------------------------------------------------------------
FORM f_bdc_showmsg TABLES ft_bdcmsg STRUCTURE bdcmsgcoll
                   USING fu_msgtyp.
  DATA: ld_txt(80).
  PERFORM f_bdc_getmsg TABLES ft_bdcmsg USING fu_msgtyp CHANGING ld_txt.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text = ld_txt.
ENDFORM.                    "f_bdc_showmsg

*-----------------------------------------------------------------------
* @form        F_BDC_CALL_TCODE_SESSION
* @description Call SAP transaction, if transaction ended with an
*              error, another bdc session will be created, so
*              users can check it via SM35 using Session name
*             'STDBDC*'
*              Ft_bdcdata will be reseted after this function call.
*              SY-SUBRC = 0 Processing was succesful
*              SY-SUBRC NE 0 Transaction ended with an error
*              check T_BDCMSG for error msg
*              or use F_BDC_GETMSG / F_BDC_SHOWMSG
* @param       Ft_bdcdata
* @par-desc    collect bdc data
* @param       FT_BDCMSG
* @par-desc    collect bdc msg
* @param       FU_TCODE
* @par-desc    SAP transaction name
* @param       FU_TEXT
* @par-desc    text indicator and show it while calling this form
* @par-val     SPACE - not showing text indicator
*-----------------------------------------------------------------------
FORM f_bdc_call_tcode_session TABLES ft_bdcdata STRUCTURE bdcdata
                                     ft_bdcmsg STRUCTURE bdcmsgcoll
                              USING fu_tcode fu_text.
  DATA: ld_subrc LIKE sy-subrc,
        ld_uzeit LIKE sy-uzeit,
        ld_result(5),
        ld_tabix LIKE sy-tabix,
        ld_sname(12).
  CHECK d_bdc_error EQ 0.
  d_bdc_tcode = fu_tcode.
  CLEAR ft_bdcmsg. REFRESH ft_bdcmsg.
  IF fu_text <> space.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text = fu_text.
    CLEAR d_bdc_indic.
  ENDIF.
  IF d_bdc_rbexc = 'X'.
    d_bdc_options-dismode = d_bdc_batch.
    d_bdc_options-updmode = d_bdc_update.
    d_bdc_options-nobinpt = d_bdc_nobinpt.
    d_bdc_options-defsize = d_bdc_defsize.
*{   REPLACE        P01K910487                                        1
*\    CALL TRANSACTION fu_tcode USING ft_bdcdata
    CALL TRANSACTION fu_tcode USING ft_bdcdata              "#EC CI_CALLTA     "Start SOH: Shell SCI Adjustment 20240226 KRS
*}   REPLACE
                              OPTIONS FROM d_bdc_options
                              MESSAGES INTO ft_bdcmsg.
    d_bdc_error = ld_subrc = sy-subrc.
    CONCATENATE sy-msgid sy-msgno INTO ld_result.
*   Determine the success of the transaction by checking msg_no&msg_id
    CLEAR r_message.
    IF NOT r_message[] IS INITIAL.
      IF NOT ld_result IN r_message.
        d_bdc_error = ld_subrc = c_bdc_yes.
      ELSE.
        d_bdc_error = ld_subrc = c_bdc_no.
      ENDIF.
    ENDIF.

    CLEAR ld_sname.

    IF ld_subrc <> 0 AND d_bdc_cbbdc = 'X'.
*     Create a BDC session for this transaction
      PERFORM f_bdc_create_session TABLES ft_bdcdata
                                   USING fu_tcode 'X'.
    ENDIF.
  ELSE.
    CHECK d_bdc_cbonc NE space.
*-- Choose BDC session and saved for each data in one session, then
*-- create a BDC session for this transaction
    PERFORM f_bdc_create_session TABLES ft_bdcdata
                                 USING fu_tcode ' '.
  ENDIF.

  CLEAR ft_bdcdata. REFRESH ft_bdcdata.
  CLEAR r_message. REFRESH r_message.
* Read last message
  DESCRIBE TABLE t_bdcmsg LINES ld_tabix.
  IF ld_tabix > 0.
    READ TABLE t_bdcmsg INDEX ld_tabix.
  ENDIF.
ENDFORM.                    "f_bdc_call_tcode_session

*$*$--------------------------------------------------------------------
*$*$ Lib internal use Subroutines
*$*$--------------------------------------------------------------------

*-----------------------------------------------------------------------
* form        F_BDC_CREATE_SESSION
* description create SAP bdc session
* param       Ft_bdcdata
* par-desc    collect bdc data
* param       FU_TCODE
* par-desc    SAP transaction name
* param       FU_ERROR
* par-desc    Calling this form in error condition
*-----------------------------------------------------------------------
FORM f_bdc_create_session TABLES ft_bdcdata STRUCTURE bdcdata
                          USING fu_tcode fu_error.
  DATA: ld_answer,
        ld_sname(12).
* Open a new batch session.
  IF d_bdc_session IS INITIAL.
    CONCATENATE 'ERR_' sy-uzeit
          INTO d_bdc_session.
  ENDIF.
  PERFORM f_bdc_open_session USING d_bdc_session.
* Insert BDC data.
  PERFORM f_bdc_insert_session TABLES ft_bdcdata
                               USING fu_tcode.
* Close batch session
  PERFORM f_bdc_close_session USING d_bdc_session.

  CHECK d_bdc_dpmsg NE space.
  SET PARAMETER ID 'MPN' FIELD ld_sname.
*{   REPLACE        P01K910487                                        1
*\  CALL TRANSACTION 'SM35' AND SKIP FIRST SCREEN.
  CALL TRANSACTION 'SM35' AND SKIP FIRST SCREEN.     "#EC CI_CALLTA     "Start SOH: Shell SCI Adjustment 20240226 KRS
*}   REPLACE
ENDFORM.                    "f_bdc_create_session

*-----------------------------------------------------------------------
* form         F_BDC_OPEN_SESSION
* description  open a bdc session
* param        FU_SNAME
* par-desc     session name
*-----------------------------------------------------------------------
FORM f_bdc_open_session USING fu_sname.
  DATA: ld_group LIKE apqi-groupid.
  ld_group = fu_sname.
  CALL FUNCTION 'BDC_OPEN_GROUP'       "open SBDC session
       EXPORTING
            client              = sy-mandt
            group               = ld_group
            keep                = 'Y'
            user                = sy-uname
       IMPORTING
            qid                 = d_bdc_apqid
       EXCEPTIONS
            client_invalid      = 1
            destination_invalid = 2
            group_invalid       = 3
            group_is_locked     = 4
            holddate_invalid    = 5
            internal_error      = 6
            queue_error         = 7
            running             = 8
            system_lock_error   = 9
            user_invalid        = 10
            OTHERS              = 11.
  IF sy-subrc <> 0.
    WRITE:/ '**** BDC session open errors.',
         50 'Errors occured when opening BDC session:', fu_sname,
          / '**** Processing terminated.',
         50 'Processing terminated due to BDC open errors.'.
    STOP.
  ENDIF.
ENDFORM.                    "f_bdc_open_session

*-----------------------------------------------------------------------
* form         F_BDC_INSERT_SESSION
* description  insert bdc session
* param        Ft_bdcdata
* par-desc     collect bdc data
* param        FU_TCODE
* par-desc     SAP transaction name
*-----------------------------------------------------------------------
FORM f_bdc_insert_session TABLES ft_bdcdata STRUCTURE bdcdata
                          USING fu_tcode.
  DATA: ld_tcode LIKE tstc-tcode.
  ld_tcode = fu_tcode.
  CALL FUNCTION 'BDC_INSERT'           "insert trans into SBDC
       EXPORTING
            tcode          = ld_tcode
       TABLES
            dynprotab      = ft_bdcdata
       EXCEPTIONS
            internal_error = 1
            not_open       = 2
            queue_error    = 3
            tcode_invalid  = 4
            OTHERS         = 5.
  CASE sy-subrc.
    WHEN 1. WRITE:/ 'Internal error in BDC insert !'. STOP.
    WHEN 2. WRITE:/ 'BDC session is not open !'. STOP.
    WHEN 3. WRITE:/ 'Queue error has occured in BDC Insert !'. STOP.
    WHEN 4. WRITE:/ 'Incorrect transaction code !'. STOP.
    WHEN 5. WRITE:/ 'Printing invalid in BDC insert !'. STOP.
    WHEN 6. WRITE:/ 'Posting invalid in BDC insert !'. STOP.
    WHEN 7. WRITE:/ 'Unknown error in BDC insert !'. STOP.
  ENDCASE.
  REFRESH ft_bdcdata. CLEAR ft_bdcdata.
ENDFORM.                    "f_bdc_insert_session

*-----------------------------------------------------------------------
* form         F_BDC_CLOSE_SESSION
* description  close bdc session
* param        FU_SNAME
* par-desc     session name
*-----------------------------------------------------------------------
FORM f_bdc_close_session USING fu_sname.
  CHECK fu_sname NE space.             "close open sessions only
  CALL FUNCTION 'BDC_CLOSE_GROUP'      "close SBDC session
       EXCEPTIONS
            not_open    = 1
            queue_error = 2
            OTHERS      = 3.

  IF sy-subrc <> 0.
    WRITE:/ '**** BDC session close errors.',
         50 'Errors occured when closing BDC session:', fu_sname.
  ENDIF.
ENDFORM.                    "f_bdc_close_session

*&---------------------------------------------------------------------*
*&      Form  F_BDC_CHECK_SCREEN
*&---------------------------------------------------------------------*
FORM f_bdc_check_screen.
  IF NOT ( sy-srows EQ 15 OR sy-srows EQ 20 OR sy-srows EQ 28 ).
    MESSAGE e000(zab) WITH 'Maximize your windows screen'.
  ENDIF.
ENDFORM.                               " F_BDC_CHECK_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_BDC_MAPPING_INIT
*&---------------------------------------------------------------------*
FORM f_bdc_mapping_init USING fu_batch fu_grptx fu_tcode.
  GET TIME.
  d_bdc_batch = fu_batch.
  d_bdc_uzeit = sy-uzeit.
  d_bdc_error = c_bdc_no.
  d_bdc_grptx = fu_grptx.
  d_bdc_tcode = fu_tcode.
ENDFORM.                               " F_BDC_MAPPING_INIT

*&---------------------------------------------------------------------*
*&      Form  F_BDC_SHOW_POSTING_REPORT
*&---------------------------------------------------------------------*
FORM f_bdc_show_posting_report.
* Display the posting report popup report
  IF sy-binpt IS INITIAL.
    r_bdc_datum-sign = r_bdc_cprog-sign = r_bdc_uname = 'I'.
    r_bdc_datum-option = r_bdc_cprog-option = r_bdc_uname-option = 'EQ'.
    r_bdc_datum-low = sy-datum.
    r_bdc_cprog-low = sy-cprog.
    r_bdc_uname-low = sy-uname.
    APPEND r_bdc_datum.
    APPEND r_bdc_cprog.
    APPEND r_bdc_uname.
    CALL SCREEN 9999 STARTING AT 1 1 ENDING AT 76 20.
    CLEAR r_bdc_datum. REFRESH r_bdc_datum.
    CLEAR r_bdc_cprog. REFRESH r_bdc_cprog.
    CLEAR r_bdc_uname. REFRESH r_bdc_uname.
  ELSE.
    LEAVE PROGRAM.
  ENDIF.
ENDFORM.                               " F_BDC_SHOW_POSTING_REPORT

*&---------------------------------------------------------------------*
*&      Form  F_BDC_CHECK_ROWS
*&---------------------------------------------------------------------*
FORM f_bdc_check_rows USING fu_screen.
  DATA: ld_msgv1(40) VALUE 'Please set your screen to',
        ld_msgv2(40) VALUE 'and maximized this window to avoid',
        ld_msgv3(40) VALUE 'wrong processing !',
        ld_error.

  CLEAR ld_error.
  CASE fu_screen.
    WHEN '640*480'.
      IF sy-srows NE 15.
        ld_error = 'X'.
      ENDIF.
    WHEN '800*600'.
      IF sy-srows NE 20.
        ld_error = 'X'.
      ENDIF.
    WHEN '1024*800'.
      IF sy-srows NE 28.
        ld_error = 'X'.
      ENDIF.
  ENDCASE.
  CHECK ld_error NE space.
  MESSAGE ID 'ZAB' TYPE d_bdc_screen NUMBER '000'
          WITH ld_msgv1(40) fu_screen
               ld_msgv2(40) ld_msgv3(40).
ENDFORM.                               " F_BDC_CHECK_ROWS

*&---------------------------------------------------------------------*
*&      Form  F_BDC_MODE
*&---------------------------------------------------------------------*
FORM f_bdc_mode USING fu_mode.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANC'. LEAVE TO SCREEN 0.
    WHEN 'EXIT'. LEAVE PROGRAM.
    WHEN 'PHID'. d_bdc_param = space.
    WHEN 'PSHW'. d_bdc_param = 'X'.
    WHEN 'MODA' OR 'MODE' OR 'MODN'.
      IF sy-subrc EQ 0.
        fu_mode = sy-ucomm+3.
        MESSAGE s000(zab) WITH 'Change BDC mode to' sy-ucomm+3.
      ELSE.
        MESSAGE e000(zab)
                WITH 'This function code is not supported for user'
                     sy-uname.
      ENDIF.
  ENDCASE.
ENDFORM.                               " F_BDC_MODE

*&---------------------------------------------------------------------*
*&      Form  F_BDC_BACKGROUND
*&---------------------------------------------------------------------*
*****FORM f_bdc_background.
******{   REPLACE        P01K910487                                        1
******\  CALL 'BDC_START_GROUP'
*****  CALL 'BDC_START_GROUP'                    "#EC CI_CCALL "Start SOH: Shell SCI Adjustment 20240226 KRS
******}   REPLACE
*****       ID 'GROUP'    FIELD d_bdc_jobnm
*****       ID 'QUID'     FIELD d_bdc_apqid
*****       ID 'DISPLAY'  FIELD d_bdc_batch
*****       ID 'LOG'      FIELD ' '.
*****  DELETE FROM apqi WHERE datatyp EQ 'BDC'
*****                     AND mandant EQ sy-mandt
*****                     AND groupid EQ d_bdc_jobnm
*****                     AND qid EQ d_bdc_apqid.
*****  DELETE FROM apqd WHERE qid EQ d_bdc_apqid.
*****  COMMIT WORK AND WAIT.
*****ENDFORM.                               " F_BDC_BACKGROUND

*&---------------------------------------------------------------------*
*&      Form  F_BDC_HELP_POPUP
*&---------------------------------------------------------------------*
FORM f_bdc_help_popup USING fu_cprog fu_dynnr fu_msgid fu_atext.
  DATA: lt_info LIKE help_info OCCURS 0 WITH HEADER LINE,
        lt_dselc LIKE dselc OCCURS 0 WITH HEADER LINE,
        lt_dval LIKE dval OCCURS 0 WITH HEADER LINE,
        ld_select_value LIKE help_info-fldvalue,
        ld_selection,
        ld_rsmdy LIKE rsmdy.

  lt_info-call = 'D'.
  lt_info-object = 'N'.
  lt_info-program = fu_cprog.
  lt_info-dynpro = fu_dynnr.
  lt_info-spras = sy-langu.
  lt_info-message = fu_atext.
  lt_info-docuid = 'NA'.
  lt_info-title = 'Display_Batch_Input_Error-message'.
  lt_info-messageid = fu_msgid.

  CALL FUNCTION 'HELP_START'
    EXPORTING
      help_infos   = lt_info
    IMPORTING
      selection    = ld_selection
      select_value = ld_select_value
      rsmdy_ret    = ld_rsmdy
    TABLES
      dynpselect   = lt_dselc
      dynpvaluetab = lt_dval
    EXCEPTIONS
      OTHERS       = 1.
ENDFORM.                               " F_BDC_HELP_POPUP

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_JOB
*&---------------------------------------------------------------------*
FORM f_bdc_create_job.
  DATA: ld_apqi LIKE apqi,
        ld_jobrele LIKE btch0000-char1,
        ld_strdate LIKE tbtcjob-sdlstrtdt,
        ld_strtime LIKE tbtcjob-sdlstrttm.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobgroup         = 'SAPMZBDC'
      jobname          = d_bdc_jobname
    IMPORTING
      jobcount         = d_bdc_jobcount
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.

  SUBMIT rsbdcbtc USER sy-uname
         VIA JOB d_bdc_jobname
         NUMBER  d_bdc_jobcount
         WITH queue-id  EQ d_bdc_jobname
         WITH queue-id  EQ d_bdc_apqid
         WITH mappe     EQ d_bdc_jobname
         WITH modus     EQ 'N'
         WITH logall    EQ d_bdc_logal
         AND RETURN.

  IF d_bdc_imdte NE space.
    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount             = d_bdc_jobcount
        jobname              = d_bdc_jobname
        strtimmed            = d_bdc_imdte
      IMPORTING
        job_was_released     = ld_jobrele
      EXCEPTIONS
        cant_start_immediate = 1
        invalid_startdate    = 2
        jobname_missing      = 3
        job_close_failed     = 4
        job_nosteps          = 5
        job_notex            = 6
        lock_failed          = 7
        OTHERS               = 8.
  ELSE.
    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount             = d_bdc_jobcount
        jobname              = d_bdc_jobname
        sdlstrtdt            = ld_strdate
        sdlstrttm            = ld_strtime
      IMPORTING
        job_was_released     = ld_jobrele
      EXCEPTIONS
        cant_start_immediate = 1
        invalid_startdate    = 2
        jobname_missing      = 3
        job_close_failed     = 4
        job_nosteps          = 5
        job_notex            = 6
        lock_failed          = 7
        OTHERS               = 8.
  ENDIF.
ENDFORM.                               " F_BDC_CREATE_JOB

*&---------------------------------------------------------------------*
*&     Form  F_BDC_EXECUTE
*&---------------------------------------------------------------------*
FORM f_bdc_execute.
  IF d_bdc_rbexc NE space.
    PERFORM f_mapping IN PROGRAM (sy-cprog).
  ELSE.
    PERFORM f_bdc_open_session USING d_bdc_jobname.
    PERFORM f_mapping IN PROGRAM (sy-cprog).
    PERFORM f_bdc_close_session USING d_bdc_jobname.
    IF d_bdc_sm35 NE space.
      SET PARAMETER ID 'MPN' FIELD d_bdc_jobname.
*{   REPLACE        P01K910487                                        1
*\      CALL TRANSACTION 'SM35' AND SKIP FIRST SCREEN.
      CALL TRANSACTION 'SM35' AND SKIP FIRST SCREEN.              "#EC CI_CALLTA     "Start SOH: Shell SCI Adjustment 20240226 KRS
*}   REPLACE
    ELSE.
      PERFORM f_bdc_create_job.
    ENDIF.
  ENDIF.
ENDFORM.                               " F_BDC_EXECUTE

*&---------------------------------------------------------------------*
*&      Form  F_BDC_TCODE
*&---------------------------------------------------------------------*
FORM f_bdc_tcode USING fu_indic.
  IF d_bdc_rbexc EQ space.
*-- Choose BDC session and saved for each data in one session
    PERFORM f_bdc_insert_session TABLES t_bdcdata
                                 USING d_bdc_tcode.
    d_bdc_indic = d_bdc_sessn.
  ELSE.
    d_bdc_indic = d_bdc_tctxt.
  ENDIF.
  IF fu_indic IS INITIAL.
    REPLACE '&1' WITH d_bdc_tcode INTO d_bdc_indic.
    CONDENSE d_bdc_indic.
    REPLACE '&2' WITH d_bdc_count INTO d_bdc_indic.
    REPLACE '&3' WITH d_bdc_maxcn INTO d_bdc_indic.
  ELSE.
    d_bdc_indic = fu_indic.
  ENDIF.

  d_bdc_session = d_bdc_jobname.
  IF d_bdc_rbexc NE space.
    PERFORM f_bdc_call_tcode_session TABLES t_bdcdata t_bdcmsg
                                    USING d_bdc_tcode d_bdc_indic.
  ENDIF.
  REFRESH: t_bdcdata.
ENDFORM.                               " F_BDC_TCODE

*---------------------------------------------------------------------*
*       FORM f_bdc_intsf                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_bdc_intsf.
  IF d_bdc_intsf IS INITIAL.
    FORMAT INTENSIFIED ON.
    d_bdc_intsf = 'X'.
  ELSE.
    CLEAR d_bdc_intsf.
    FORMAT INTENSIFIED OFF.
  ENDIF.
ENDFORM.                    "f_bdc_intsf

*&---------------------------------------------------------------------*
*&      Form  f_get_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BDCMSG  text
*      <--P_T_BOMEXPL_MSGTX  text
*----------------------------------------------------------------------*
FORM f_get_message USING    fu_bdcmsg LIKE t_bdcmsg
                   CHANGING fc_msgtx.

  DATA : ld_error LIKE msg_log,
         ld_msgtxt LIKE msg_text.

  MOVE-CORRESPONDING fu_bdcmsg TO ld_error.
  MOVE: fu_bdcmsg-msgnr TO ld_error-msgno,
        fu_bdcmsg-msgtyp TO ld_error-msgty.

  CALL FUNCTION 'MESSAGE_TEXTS_READ'
    EXPORTING
      msg_log_imp  = ld_error
    IMPORTING
      msg_text_exp = ld_msgtxt.

  fc_msgtx = ld_msgtxt-msgtx.

ENDFORM.                    " f_get_message



DEFINE macro_bdc_selection_screen.
  loop at screen.
    if 'C_RBEXC C_TITLE C_CBBDC C_RBBDC P_RBEXC P_CPROG' cs screen-name
     or 'P_BATCH P_CBBDC P_RBBDC P_BATCH P_ONCE P_BDCNM' cs screen-name
     or 'P_DATUM P_UZEIT P_RBTIM C_RBTIM P_RBIMD P_RBPOL' cs screen-name
     or '%_C_RBIMD_%_APP_%-TEXT %_C_RBTIM_%_APP_%-TEXT' cs screen-name
     or '%_C_RBPOL_%_APP_%-TEXT %_C_RBDAT_%_APP_%-TEXT' cs screen-name
     or '%_P_CPROG_%_APP_%-TEXT %_P_ONCE_%_APP_%-TEXT' cs screen-name.
      if d_bdc_param is initial.
        screen-input = 0.
        screen-invisible = 1.
        modify screen.
      endif.
    endif.
  endloop.
END-OF-DEFINITION.

DEFINE macro_error.
  format color 6 inverse on.
  write:/5(2) '@AG@' as icon.
END-OF-DEFINITION.

DEFINE macro_success.
  format color 5 inverse on.
  write:/5(2) '@01@' as icon.
END-OF-DEFINITION.

DEFINE macro_write.
  d_bdc_lngth = strlen( &1 ).
  describe field &1 into d_bdc_sydes.
  describe table d_bdc_sydes-names lines d_bdc_tabix.
  if d_bdc_tabix gt 2.
    write at (d_bdc_lngth) &1 color col_background inverse off.
  else.
    write at (d_bdc_lngth) &1.
  endif.
END-OF-DEFINITION.
