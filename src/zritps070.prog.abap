*Analyse und Aufbau der Infostruktur S070
REPORT zritps070 MESSAGE-ID im.

*----------------------------------------------------------------------*
*  Output changed to ALV in report factory by Soujanya Deepa.K C5053266
*  Implements in standard by Sebastian Allmann on 16.06.2004
*  (changed Output for RIEQS070 and RITPS070 to one include)
*----------------------------------------------------------------------*

TYPE-POOLS: mcit.

TABLES: viqmel.
TABLES: iflo.
TABLES: iflos.
TABLES: s070.

SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  otplnr FOR viqmel-tplnr MATCHCODE OBJECT iflm NO-DISPLAY,
  ostrno FOR iflos-strno  MATCHCODE OBJECT iflm.
SELECT-OPTIONS: so_spmon  FOR s070-spmon.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.

*---- Variablen ------------------------------------------------------*
DATA: xindex TYPE i.
DATA: xeff   TYPE i.
DATA: 1ausvn LIKE viqmel-ausvn.
DATA: 1auztv LIKE viqmel-auztv.
DATA: nausvn LIKE viqmel-ausvn.
DATA: nauztv LIKE viqmel-auztv.
DATA: xtbr   LIKE s070-seqtbr.
DATA: xttr   LIKE s070-seqtbr.
DATA: xmtbr  LIKE s070-seqtbr.
DATA: xmttr  LIKE s070-seqtbr.
DATA: xaus   LIKE s070-sauszt.
DATA: ok_memory LIKE sy-ucomm.
DATA: ypm(2) VALUE 'PM'.
DATA: x_answer.
DATA: yj VALUE 'J'.

DATA:
  lt_so_equnr     TYPE mcit_t_so_equnr,
  lt_so_tplnr     TYPE mcit_t_so_tplnr,
  lt_startup_iflo TYPE mcit_t_startup_iflo,
  ls_startup_iflo TYPE mcit_startup_iflo,
  ls_rep          TYPE mcit_brkdwn_rep,
  lt_brkdwn_rep   TYPE mcit_t_brkdwn_rep,
  ls_eff          TYPE mcit_brkdwn_eff,
  lt_brkdwn_eff   TYPE mcit_t_brkdwn_eff,
  ls_result       TYPE mcit_result,
  lt_result       TYPE mcit_t_result,
  lt_mciqmadd     TYPE mcit_t_mciqmadd.

*---Includes
INCLUDE zieqtps070alv.

AT SELECTION-SCREEN.

  DESCRIBE TABLE otplnr LINES sy-tfill.
  IF sy-tfill = 0.
    DESCRIBE TABLE ostrno LINES sy-tfill.
    IF sy-tfill = 0.
      MESSAGE e131(il).
    ENDIF.
  ENDIF.

START-OF-SELECTION.

  DATA: ls_object_head TYPE gtype_object_head,
        ls_object_item TYPE gtype_object_item.

*--- Berechnung der MTBR für TP -------------------------------------*
  IF otplnr[] IS INITIAL.
    CALL FUNCTION 'IREP1_LOCATION_CONVERSION'
      TABLES
        i_strno_tab = ostrno[]
        e_tplnr_tab = otplnr[].
  ENDIF.

  lt_so_tplnr[] = otplnr[].

  CALL FUNCTION 'PM_OBJECT_MTBR'
    EXPORTING
      i_obknz         = mcit_c_obknz_iflo
      so_equnr        = lt_so_equnr
      so_tplnr        = lt_so_tplnr
    IMPORTING
      et_startup_iflo = lt_startup_iflo
      et_brkdwn_rep   = lt_brkdwn_rep
      et_brkdwn_eff   = lt_brkdwn_eff
      et_result       = lt_result
      et_mciqmadd     = lt_mciqmadd.

  xindex = 0.

  LOOP AT lt_result INTO ls_result.
    IF ls_result-spmon IN so_spmon.
    ELSE.
      DELETE lt_result.
    ENDIF.
  ENDLOOP.

*--- Fill output tables
  LOOP AT lt_result INTO ls_result.

    xtbr   = ls_result-stbrhrs + xtbr.
    xaus   = ls_result-sttrhrs + xaus.
    xindex = xindex + ls_result-nbdeff.
    xmttr  = ls_result-sttrhrs / ls_result-nbdeff.
    xmtbr  = ls_result-stbrhrs / ls_result-nbdeff.

    AT NEW tplnr.
      ls_object_head-tplnr = ls_result-tplnr.
      PERFORM tplnr_text USING ls_result-tplnr ls_object_head-ktext.
    ENDAT.

    ls_object_item-tplnr   = ls_result-tplnr.
    ls_object_item-spmon   = ls_result-spmon.
    ls_object_item-nbdeff  = ls_result-nbdeff.
    ls_object_item-sttrhrs = ls_result-sttrhrs.
    ls_object_item-xmttr   = xmttr.
    ls_object_item-xmtbr   = xmtbr.
    APPEND ls_object_item TO gt_object_item.

    AT END OF tplnr.
      ls_object_head-xaus  = xaus / xindex.
      ls_object_head-xtbr  = xtbr.             "TBR
      ls_object_head-xmtbr = xtbr / xindex.    "MTBR
      APPEND ls_object_head TO gt_object_head.

      xtbr = 0.
      xaus = 0.
      xindex = 0.
    ENDAT.
  ENDLOOP.

  CLEAR ls_result.
  CLEAR ls_eff.
  CLEAR ls_rep.

END-OF-SELECTION.

  CASE 'X'.
    WHEN radio1.
      PERFORM alv_main_output.
    WHEN radio2.
      PERFORM alv_output.
  ENDCASE.

*&---------------------------------------------------------------------*
* P30K032119 Condense auf Quantity-Felder ist nicht sinnvoll           *
*&      Form  EINZEL_MELDUNG
*&---------------------------------------------------------------------*
FORM einzel_meldung.

  DATA: ls_qmnum    TYPE gtype_qmnum,
        ls_stat     TYPE gtype_stat,
        l_text1(10) TYPE c,
        l_text2(10) TYPE c.

  REFRESH gt_qmnum.
  REFRESH gt_stat.

*--- Object daten ----------------------------------------------------*
  PERFORM tplnr_text USING ls_result-tplnr g_ktext.

*    startup date
  READ TABLE lt_startup_iflo INTO ls_startup_iflo
                             WITH KEY tplnr = ls_result-tplnr.

  IF ls_startup_iflo-source = mcit_c_source_master.
    g_date = ls_startup_iflo-startup.
  ELSE.
    CLEAR g_date.
  ENDIF.

*--- Letzte Meldung vormonat -----------------------------------------*

  CLEAR ls_rep.

  LOOP AT lt_brkdwn_eff INTO ls_eff
    WHERE tplnr = ls_result-tplnr
      AND spmon < ls_result-spmon.
  ENDLOOP.

  IF sy-subrc <> 0.
    LOOP AT lt_brkdwn_rep INTO ls_rep
      WHERE tplnr = ls_result-tplnr
        AND ebdnr IS INITIAL.
    ENDLOOP.

  ELSE.
    LOOP AT lt_brkdwn_rep INTO ls_rep
      WHERE tplnr = ls_eff-tplnr
      AND ebdnr = ls_eff-ebdnr.
    ENDLOOP.
  ENDIF.

  IF NOT ls_rep IS INITIAL.
    ls_qmnum-qmnum   = ls_rep-qmnum.
    ls_qmnum-ausvn   = ls_rep-ausvn.
    ls_qmnum-auztv   = ls_rep-auztv.
    ls_qmnum-ausbs   = ls_rep-ausbs.
    ls_qmnum-auztb   = ls_rep-auztb.
    ls_qmnum-sgauszt = ls_rep-hauszt.
    ls_qmnum-color   = 'C710'.
    APPEND ls_qmnum TO gt_qmnum.
  ENDIF.

  xindex = 0.

*--- Ausgabe ---------------------------------------------------------*
  LOOP AT lt_brkdwn_eff INTO ls_eff
    WHERE tplnr = ls_result-tplnr
      AND spmon = ls_result-spmon.

    xeff = 0.

    LOOP AT lt_brkdwn_rep INTO ls_rep
      WHERE tplnr = ls_result-tplnr
        AND ebdnr = ls_eff-ebdnr.

      xindex = xindex + 1.
      xeff = xeff + 1.

      IF xindex = 1.
        1ausvn = ls_rep-ausvn.
        1auztv = ls_rep-auztv.
      ENDIF.
      nausvn = ls_rep-ausvn.
      nauztv = ls_rep-auztv.

      CLEAR ls_qmnum.

* verdeckter Ausfall
      IF ls_rep-hidden = 'X'.
        ls_qmnum-color = 'C510'.
      ENDIF.

* neuer effektiver Ausfall
      IF xeff = 1.
        ls_qmnum-color = 'C310'.
      ENDIF.

      ls_qmnum-qmnum   = ls_rep-qmnum.
      ls_qmnum-ausvn   = ls_rep-ausvn.
      ls_qmnum-auztv   = ls_rep-auztv.
      ls_qmnum-ausbs   = ls_rep-ausbs.
      ls_qmnum-auztb   = ls_rep-auztb.
      ls_qmnum-sgauszt = ls_rep-hauszt.
      APPEND ls_qmnum TO gt_qmnum.
    ENDLOOP.
  ENDLOOP.

  CLEAR ls_rep.

  xtbr  = ls_result-stbrhrs.
  xmtbr = ls_result-stbrhrs / ls_result-nbdeff.
  xttr  = ls_result-sttrhrs.
  xmttr = ls_result-sttrhrs / ls_result-nbdeff.

  WRITE 1ausvn TO l_text1.
  WRITE 1auztv TO l_text2.
  ls_stat-field = text-044.
  CONCATENATE l_text1 l_text2 INTO ls_stat-value SEPARATED BY space.
  APPEND ls_stat TO gt_stat.

  WRITE nausvn TO l_text1.
  WRITE nauztv TO l_text2.
  ls_stat-field = text-046.
  CONCATENATE l_text1 l_text2 INTO ls_stat-value SEPARATED BY space.
  APPEND ls_stat TO gt_stat.

  ls_stat-field = text-048.
  ls_stat-value = ls_result-snbdrep.
  APPEND ls_stat TO gt_stat.

  WRITE xtbr DECIMALS 2 TO l_text1.                     "#EC UOM_IN_MES
  WRITE text-090 TO l_text2.
  ls_stat-field = text-050.
  CONCATENATE l_text1 l_text2 INTO ls_stat-value SEPARATED BY space.
  APPEND ls_stat TO gt_stat.

  ls_stat-field = text-052.
  ls_stat-value = ls_result-nbdeff.
  APPEND ls_stat TO gt_stat.

  WRITE xmtbr DECIMALS 2 TO l_text1.                    "#EC UOM_IN_MES
  WRITE text-090 TO l_text2.
  ls_stat-field = text-054.
  CONCATENATE l_text1 l_text2 INTO ls_stat-value SEPARATED BY space.
  APPEND ls_stat TO gt_stat.

  WRITE xttr DECIMALS 2 TO l_text1.                     "#EC UOM_IN_MES
  WRITE text-090 TO l_text2.
  ls_stat-field = text-056.
  CONCATENATE l_text1 l_text2 INTO ls_stat-value SEPARATED BY space.
  APPEND ls_stat TO gt_stat.

  WRITE xmttr DECIMALS 2 TO l_text1.                    "#EC UOM_IN_MES
  WRITE text-090 TO l_text2.
  ls_stat-field = text-058.
  CONCATENATE l_text1 l_text2 INTO ls_stat-value SEPARATED BY space.
  APPEND ls_stat TO gt_stat.

  xindex = 0.

  PERFORM alv_noti_output.

ENDFORM.                    "EINZEL_MELDUNG

*---------------------------------------------------------------------*
*       FORM TPLNR_TEXT                                               *
*---------------------------------------------------------------------*
*       Get text for functional location
*----------------------------------------------------------------------*
*      -->I_TPLNR  func. loc.
*      <--E_PLTXT  Text
*----------------------------------------------------------------------*
FORM tplnr_text USING i_tplnr TYPE tplnr
                      e_pltxt TYPE pltxt.

  CALL FUNCTION 'FUNC_LOCATION_READ'
    EXPORTING
      spras   = sy-langu
      tplnr   = i_tplnr
    IMPORTING
      pltxt   = e_pltxt
      iflo_wa = iflo.

ENDFORM.                    "TPLNR_TEXT

*---------------------------------------------------------------------*
*       FORM S070_PUT                                                 *
*---------------------------------------------------------------------*
*Update S070                                                          *
*---------------------------------------------------------------------*
FORM s070_put USING p_equnr    TYPE equnr
                    p_tplnr    TYPE tplnr
                    p_result TYPE mcit_t_result
                    p_mciqmadd TYPE mcit_t_mciqmadd.
  CONSTANTS:
    c_vrsio_act TYPE vrsio VALUE '000',
    c_iflot LIKE tclt-obtab VALUE 'IFLOT',
    c_sign_inclusive TYPE sign VALUE 'I',
    c_option_equal TYPE option VALUE 'EQ'.

  DATA:
    ls_mciqmadd TYPE mciqmadd,
    ls_s070 LIKE s070,
    lt_s070 LIKE TABLE OF s070,
    ls_so_tplnr TYPE mcit_so_tplnr,
    lt_so_tplnr TYPE mcit_t_so_tplnr,
    l_object LIKE rmclf-objek,
    l_class LIKE klah-class,
    l_no_stdclass LIKE kssk-stdcl.

  IF NOT ( p_mciqmadd IS INITIAL ).
* ermitteln standardklasse zum Equipment
    l_object = p_tplnr.

    CALL FUNCTION 'CLFM_GET_STANDARD_CLASS'
      EXPORTING
        object            = l_object
        table             = c_iflot
      IMPORTING
        class             = l_class
        e_no_std_class    = l_no_stdclass
      EXCEPTIONS
        no_classification = 1
        OTHERS            = 2.

    IF NOT sy-subrc IS INITIAL OR
      NOT l_no_stdclass IS INITIAL.
      CLEAR l_class.
    ENDIF.

    ls_s070-ssour = mcit_c_ssour_space.
    ls_s070-vrsio = c_vrsio_act.
    ls_s070-sklsob = l_class.
    ls_s070-equnr = space.
    ls_s070-tplnr = p_tplnr.

    ls_so_tplnr-sign = c_sign_inclusive.
    ls_so_tplnr-option = c_option_equal.
    ls_so_tplnr-low = p_tplnr.
    APPEND ls_so_tplnr TO lt_so_tplnr.

*----- add the calculated key figure values
    LOOP AT p_result TRANSPORTING NO FIELDS WHERE tplnr EQ p_tplnr.
      READ TABLE p_mciqmadd INDEX sy-tabix INTO ls_mciqmadd.
      MOVE-CORRESPONDING ls_mciqmadd TO ls_s070.            "#EC ENHOK
      APPEND ls_s070 TO lt_s070.
    ENDLOOP.

  ENDIF.

  CALL FUNCTION 'MCI1_S070_UPDATE'
    EXPORTING
      i_vrsio  = c_vrsio_act
      i_s070   = lt_s070
      so_tplnr = lt_so_tplnr.

  COMMIT WORK.
  MESSAGE i814 WITH p_tplnr.

ENDFORM.                                                    "s070_put

*---------------------------------------------------------------------*
*       FORM CONFIRM_STEP                                             *
*---------------------------------------------------------------------*
* Update S070 abfrage                                                 *
*---------------------------------------------------------------------*
FORM confirm_step USING i_object TYPE c
                        e_answer TYPE c.

  DATA: l_tplnr TYPE tplnr.

  l_tplnr = i_object.

  CLEAR e_answer.
  DATA: BEGIN OF ltext,
         text(28) ,
         tpl TYPE ilom_strno,
        END OF ltext.
  WRITE l_tplnr TO ltext-tpl.
  ltext-text = text-070.
  CONDENSE ltext.

*--- Sicherheitsabfrage -----------------------------------------------*
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption = 'N'
      textline1     = ltext
      textline2     = text-072
      titel         = text-074
    IMPORTING
      answer        = e_answer.

ENDFORM.                    "confirm_step
