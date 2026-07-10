*&----------------------------------------------------------------------------*
*& D R A G O N   G L O R Y   P R O J E C T
*&----------------------------------------------------------------------------*
*& RICEF ID              : EQM-02
*& Title                 : Cancel Material Document from UD
*& Functional Designer   : Yustin Kusnidar
*& ABAP Developer        : Samanta Limbrada
*& Initial Creation Date : 24.05.2012
*&
*& Overview: (paste business requirement from FuncSpec here)
*& Enhancement ini dibutuhkan untuk memungkinkan super user untuk melakukan
*& reverse terhadap posting material document yang diposting dari transaksi UD
*&
*& Program ini di-copy dari existing program ZRQEVAC50 dan di-modify sesuai
*& dengan requirement, yaitu:
*& 1.	Change Source Code untuk mengganti Posting date dari kondisi saat ini
*& Posting Date = entry date, diganti posting date dicopy dari original
*& Material document posting date.
*& 2.	Tambahan authorization check, dengan authorization object Q_INSP_FIN
*& dimana didalamnya terdapat checking terhadap WERKS (Plant).
*& 3.	Tambahan untuk user confirmation, dengan keterangan #Are you sure you
*& want to Reverse Material Document from UD for Inspection Lot No ###
*& Jika #Yes#, maka lanjutkan process Reverse Material Document,
*& Jika #No# Reverse Material Document  tidak jadi dilakukan dan kembali
*& ke screen sebelumnya.
*&
*& Assumption : N/A
*&
*&----------------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&----------------------------------------------------------------------------*
*& Date        By        TR#          Version  Description
*&----------------------------------------------------------------------------*
*& 24.05.2012  SAPDEV02   EVK922382   01       Initial creation
*&
*&----------------------------------------------------------------------------*
REPORT  zdgqm_e001  MESSAGE-ID qa.

TYPES:
  t_mkpf_tab  LIKE mkpf  OCCURS 0,
  t_mseg_tab  LIKE mseg  OCCURS 0.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS:
  prueflos LIKE qals-prueflos OBLIGATORY MEMORY ID qls.
SELECTION-SCREEN END OF BLOCK b1.

DATA:
  g_msgv1       LIKE sy-msgv1,
  g_qals        LIKE qals,
  g_qals_leiste LIKE qals,
  g_qamb_tab    TYPE qambtab,
  g_qamb_vb_tab TYPE qambtab,
  g_mkpf_tab    TYPE t_mkpf_tab,
  g_mkpf        TYPE mkpf,
  g_mseg_tab    TYPE t_mseg_tab,
  g_subrc       LIKE sy-subrc,
  g_answer      TYPE c,
  g_message1     TYPE char80,
  g_message2     TYPE char80.


START-OF-SELECTION.

  PERFORM enqueue_qals USING prueflos
                             g_subrc.
  IF NOT g_subrc IS INITIAL.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    SUBMIT (sy-repid) VIA SELECTION-SCREEN.
  ENDIF.

  PERFORM read_qals USING prueflos
                          g_qals
                          g_qals_leiste
                          g_subrc.
  IF NOT g_subrc IS INITIAL.
    MESSAGE ID 'QA' TYPE 'S' NUMBER '102'
            WITH prueflos.
    SUBMIT (sy-repid) VIA SELECTION-SCREEN.
  ENDIF.

* Authorization Check
  AUTHORITY-CHECK OBJECT 'Z_CANCELUD'
           ID 'ZWERKS' FIELD g_qals-werk
           ID 'ZINSTYPE' FIELD g_qals-art.
  IF sy-subrc NE 0.
*   No authorization to reverse material document from UD in plant &
    MESSAGE s003(zqm) WITH g_qals-werk DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

* Create message
  MESSAGE s004(zqm) INTO g_message1.
  MESSAGE s006(zqm) WITH prueflos INTO g_message2.

* Pop up confirmation
  CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
    EXPORTING
      defaultoption = 'N'
      textline1     = g_message1
      textline2     = g_message2
      titel         = 'Reverse material document'
      start_column  = 10
      start_row     = 6
    IMPORTING
      answer        = g_answer.

  IF g_answer = 'N'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  PERFORM check_lot USING g_qals
                          g_subrc.
  IF NOT g_subrc IS INITIAL.
    CASE g_subrc.
      WHEN 256.
        g_msgv1 = 'Lot & does not refer to a material doc'.
      WHEN 128.
        g_msgv1 = 'Material & is serialized'.
        REPLACE '&' WITH g_qals-matnr INTO g_msgv1.
      WHEN  64.
        g_msgv1 = 'Lot & is not stock relevant'.
      WHEN  32.
        g_msgv1 = 'Lot &: No stock transferred'.
      WHEN  16.
        g_msgv1 = 'Lot & is cancelled'.
      WHEN   8.
        g_msgv1 = 'Lot & is archived'.
      WHEN   4.
        g_msgv1 = 'Lot & is blocked'.
      WHEN   2.
        g_msgv1 = 'Lot & is HU managed'.
    ENDCASE.
    REPLACE '&' WITH prueflos INTO g_msgv1.
    MESSAGE ID '00' TYPE 'S' NUMBER '208'
            WITH g_msgv1.
    SUBMIT (sy-repid) VIA SELECTION-SCREEN.
  ENDIF.

  PERFORM read_qamb USING g_qals
                          g_qamb_tab
                          g_subrc.
  IF NOT g_subrc IS INITIAL.
    MESSAGE ID 'QA' TYPE 'S' NUMBER '068'
            WITH prueflos.
    SUBMIT (sy-repid) VIA SELECTION-SCREEN.
  ENDIF.

  PERFORM read_mkpf USING g_qamb_tab
                          g_mkpf_tab
                          g_subrc.
  IF NOT g_subrc IS INITIAL.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    SUBMIT (sy-repid) VIA SELECTION-SCREEN.
  ENDIF.

  PERFORM check_mkpf USING g_mkpf_tab
                           g_subrc.
  IF NOT g_subrc IS INITIAL.
    MESSAGE ID 'QA' TYPE 'S' NUMBER '068'
            WITH prueflos.
    SUBMIT (sy-repid) VIA SELECTION-SCREEN.
  ENDIF.

  PERFORM read_mseg USING g_mkpf_tab
                          g_mseg_tab
                          g_subrc.
  IF NOT g_subrc IS INITIAL.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    SUBMIT (sy-repid) VIA SELECTION-SCREEN.
  ENDIF.

  PERFORM check_mseg USING g_mseg_tab
                           g_qamb_tab
                           g_subrc.
  IF NOT g_subrc IS INITIAL.
    MESSAGE ID 'QA' TYPE 'S' NUMBER '068'
            WITH prueflos.
    SUBMIT (sy-repid) VIA SELECTION-SCREEN.
  ENDIF.

  LOOP AT g_mkpf_tab INTO g_mkpf.

    PERFORM create_goods_movement USING g_qals
                                        g_mseg_tab
                                        g_subrc
                                        g_mkpf.

    IF NOT g_subrc IS INITIAL.
*      MESSAGE ID 'QA' TYPE 'S' NUMBER '068'
*              WITH prueflos.
*      SUBMIT (sy-repid) VIA SELECTION-SCREEN.
    ENDIF.

    PERFORM post_goods_movement.

    COMMIT WORK AND WAIT.

  ENDLOOP.

  PERFORM post_data USING g_qals
                          g_qals_leiste
                          g_qamb_tab
                          g_qamb_vb_tab
                          g_subrc.

  IF NOT g_subrc IS INITIAL.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    SUBMIT (sy-repid) VIA SELECTION-SCREEN.
  ELSE.
    COMMIT WORK AND WAIT.
    g_msgv1 = 'inspection lot &'.
    REPLACE '&' WITH prueflos INTO g_msgv1.
    MESSAGE ID '00' TYPE 'S' NUMBER '368'
            WITH 'Stock posting reversed for ' g_msgv1.
    SUBMIT (sy-repid) VIA SELECTION-SCREEN.
  ENDIF.

*----------------------------------------------------------------------*
*       Form  ENQUEUE_QALS                                             *
*----------------------------------------------------------------------*
*       Los sperren                                                    *
*----------------------------------------------------------------------*
FORM enqueue_qals USING p_prueflos LIKE qals-prueflos
                        p_subrc    LIKE sy-subrc.
  CLEAR: p_subrc.

  CALL FUNCTION 'ENQUEUE_EQQALS1'
    EXPORTING
      prueflos       = p_prueflos
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

  p_subrc = sy-subrc.

ENDFORM.                               " ENQUEUE_QALS

*----------------------------------------------------------------------*
*       Form  READ_QALS                                                *
*----------------------------------------------------------------------*
*       Prüflos lesen                                                  *
*----------------------------------------------------------------------*
FORM read_qals USING p_prueflos    LIKE qals-prueflos
                     p_qals        LIKE qals
                     p_qals_leiste LIKE qals
                     p_subrc       LIKE sy-subrc.

  CLEAR: p_subrc.

  CALL FUNCTION 'QPSE_LOT_READ'
    EXPORTING
      i_prueflos  = p_prueflos
      i_reset_lot = 'X'
    IMPORTING
      e_qals      = p_qals
    EXCEPTIONS
      no_lot      = 1.

  p_subrc = sy-subrc.
  IF p_subrc IS INITIAL.
    p_qals_leiste = p_qals.
  ELSE.
    CLEAR: p_qals,
           p_qals_leiste.
  ENDIF.

ENDFORM.                               " READ_QALS

*----------------------------------------------------------------------*
*       Form  CHECK_LOT                                                *
*----------------------------------------------------------------------*
*       Prüflos prüfen                                                 *
*----------------------------------------------------------------------*
FORM check_lot USING p_qals  LIKE qals
                     p_subrc LIKE sy-subrc.

  DATA:
    l_stat      LIKE jstat,
    l_stat_tab  LIKE jstat OCCURS 0 WITH HEADER LINE.

  p_subrc = 256.

*/No reference to material document
  IF p_qals-zeile IS INITIAL.
    EXIT.
  ELSE.
    p_subrc = 128.
  ENDIF.

*/Serialized Material
  IF NOT p_qals-sernp IS INITIAL.
    EXIT.
  ELSE.
    p_subrc = 64.
  ENDIF.

*/BERF
  CALL FUNCTION 'STATUS_CHECK'
    EXPORTING
      objnr             = p_qals-objnr
      status            = 'I0203'
    EXCEPTIONS
      status_not_active = 2.

  IF NOT sy-subrc IS INITIAL.
    EXIT.
  ELSE.
    p_subrc = 32.
  ENDIF.

*/BTEI & BEND
  CLEAR l_stat. CLEAR l_stat_tab. REFRESH l_stat_tab.
  l_stat-stat = 'I0219'. APPEND l_stat TO l_stat_tab. "BTEI
  l_stat-stat = 'I0220'. APPEND l_stat TO l_stat_tab. "BEND

  CALL FUNCTION 'STATUS_OBJECT_CHECK_MULTI'
    EXPORTING
      objnr        = p_qals-objnr
    TABLES
      status_check = l_stat_tab.

  IF l_stat_tab[] IS INITIAL.
    EXIT.
  ELSE.
    p_subrc = 16.
  ENDIF.


*/LSTO & LSTV
  CLEAR l_stat. CLEAR l_stat_tab. REFRESH l_stat_tab.
  l_stat-stat = 'I0224'. APPEND l_stat TO l_stat_tab. "LSTO
  l_stat-stat = 'I0232'. APPEND l_stat TO l_stat_tab. "LSTV

  CALL FUNCTION 'STATUS_OBJECT_CHECK_MULTI'
    EXPORTING
      objnr        = p_qals-objnr
    TABLES
      status_check = l_stat_tab.

  IF NOT l_stat_tab[] IS INITIAL.
    EXIT.
  ELSE.
    p_subrc = 8.
  ENDIF.

*/ARSP & ARCH & REO1 & REO2 & REO3
  CLEAR l_stat. CLEAR l_stat_tab. REFRESH l_stat_tab.
  l_stat-stat = 'I0225'. APPEND l_stat TO l_stat_tab. "ARSP
  l_stat-stat = 'I0226'. APPEND l_stat TO l_stat_tab. "ARCH
  l_stat-stat = 'I0227'. APPEND l_stat TO l_stat_tab.       "REO3
  l_stat-stat = 'I0228'. APPEND l_stat TO l_stat_tab.       "REO2
  l_stat-stat = 'I0229'. APPEND l_stat TO l_stat_tab.       "REO1

  CALL FUNCTION 'STATUS_OBJECT_CHECK_MULTI'
    EXPORTING
      objnr        = p_qals-objnr
    TABLES
      status_check = l_stat_tab.

  IF NOT l_stat_tab[] IS INITIAL.
    EXIT.
  ELSE.
    p_subrc = 4.
  ENDIF.

*/SPER
  CALL FUNCTION 'STATUS_CHECK'
    EXPORTING
      objnr             = p_qals-objnr
      status            = 'I0043'
    EXCEPTIONS
      status_not_active = 2.

  IF sy-subrc IS INITIAL.
    EXIT.
  ELSE.
    p_subrc = 2.
  ENDIF.

*/HUM
  CALL FUNCTION 'STATUS_CHECK'
    EXPORTING
      objnr             = p_qals-objnr
      status            = 'I0443'
    EXCEPTIONS
      status_not_active = 2.

  IF sy-subrc IS INITIAL.
    EXIT.
  ELSE.
    p_subrc = 0.
  ENDIF.


ENDFORM.                               " CHECK_LOT

*----------------------------------------------------------------------*
*       Form  READ_QAMB                                                *
*----------------------------------------------------------------------*
*       QAMBs lesen                                                    *
*----------------------------------------------------------------------*
FORM read_qamb USING p_qals     LIKE qals
                     p_qamb_tab TYPE qambtab
                     p_subrc    LIKE sy-subrc.

  CLEAR: p_subrc.

  SELECT * FROM qamb INTO TABLE p_qamb_tab
    WHERE prueflos =  p_qals-prueflos
      AND typ   = '3'.

  p_subrc = sy-subrc.

ENDFORM.                               " READ_QAMB

*----------------------------------------------------------------------*
*       Form  READ_MKPF                                                *
*----------------------------------------------------------------------*
*       Read material document header                                  *
*----------------------------------------------------------------------*
FORM read_mkpf USING p_qamb_tab TYPE qambtab
                     p_mkpf_tab TYPE t_mkpf_tab
                     p_subrc    LIKE sy-subrc.

  DATA:
    BEGIN OF l_mkpf_key_tab OCCURS 0,
      mblnr LIKE mkpf-mblnr,
      mjahr LIKE mkpf-mjahr,
    END   OF l_mkpf_key_tab.
  DATA:
    l_qamb   LIKE qamb,
    l_mkpf   LIKE mkpf,
    l_trtyp  LIKE t158-trtyp VALUE 'A',
    l_vgart  LIKE t158-vgart VALUE 'WQ',
    l_xexit  LIKE qm00-qkz.

  p_subrc = 4.

  LOOP AT p_qamb_tab INTO l_qamb.
    l_mkpf_key_tab-mblnr = l_qamb-mblnr.
    l_mkpf_key_tab-mjahr = l_qamb-mjahr.
    COLLECT l_mkpf_key_tab.
  ENDLOOP.

  LOOP AT l_mkpf_key_tab.
    CALL FUNCTION 'ENQUEUE_EMMKPF'
      EXPORTING
        mblnr          = l_mkpf_key_tab-mblnr
        mjahr          = l_mkpf_key_tab-mjahr
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF NOT sy-subrc IS INITIAL.
      l_xexit = 'X'.
      EXIT.
    ENDIF.

    CLEAR: l_mkpf.
    CALL FUNCTION 'MB_READ_MATERIAL_HEADER'
      EXPORTING
        mblnr         = l_mkpf_key_tab-mblnr
        mjahr         = l_mkpf_key_tab-mjahr
        trtyp         = l_trtyp
        vgart         = l_vgart
      IMPORTING
        kopf          = l_mkpf
      EXCEPTIONS
        error_message = 1.

    IF NOT sy-subrc IS INITIAL.
      l_xexit = 'X'.
      EXIT.
    ELSE.
      APPEND l_mkpf TO p_mkpf_tab.
    ENDIF.

  ENDLOOP.

  IF NOT l_xexit IS INITIAL.
    EXIT.
  ELSE.
    p_subrc = 0.
  ENDIF.

ENDFORM.                               " READ_MKPF

*----------------------------------------------------------------------*
*       Form  READ_MSEG                                                *
*----------------------------------------------------------------------*
*       MSEGs lesen                                                    *
*----------------------------------------------------------------------*
FORM read_mseg USING p_mkpf_tab TYPE t_mkpf_tab
                     p_mseg_tab TYPE t_mseg_tab
                     p_subrc    LIKE sy-subrc.

  DATA:
    l_mkpf     LIKE mkpf,
    l_mseg_tab LIKE mseg OCCURS 0 WITH HEADER LINE,
    l_trtyp    LIKE t158-trtyp VALUE 'A',
    l_xexit    LIKE qm00-qkz.

  p_subrc = 4.

  LOOP AT p_mkpf_tab INTO l_mkpf.

    CLEAR: l_mseg_tab. REFRESH: l_mseg_tab.
    CALL FUNCTION 'MB_READ_MATERIAL_POSITION'
         EXPORTING
              mblnr  = l_mkpf-mblnr
              mjahr  = l_mkpf-mjahr
              trtyp  = l_trtyp
*/            ZEILB  = P_ZEILE
*/            ZEILE  = P_ZEILE
         TABLES
            seqtab = l_mseg_tab
       EXCEPTIONS
            error_message = 1.

    IF NOT sy-subrc IS INITIAL.
      l_xexit = 'X'.
      EXIT.
    ELSE.
      APPEND LINES OF l_mseg_tab TO p_mseg_tab.
    ENDIF.

  ENDLOOP.

  IF NOT l_xexit IS INITIAL.
    EXIT.
  ELSE.
*/  XAuto-Zeilen und Chargenzustandsänderung werden gelöscht
    DELETE p_mseg_tab WHERE xauto NE space
                         OR bwart EQ '341'
                         OR bwart EQ '342'.

    p_subrc = 0.
  ENDIF.

ENDFORM.                               " READ_MSEG

*----------------------------------------------------------------------*
*       Form  CREATE_GOODS_MOVEMENT                                    *
*----------------------------------------------------------------------*
*       Warenbewegung anlegen                                          *
*----------------------------------------------------------------------*
FORM create_goods_movement USING p_qals     LIKE qals
                                 p_mseg_tab TYPE t_mseg_tab
                                 p_subrc    LIKE sy-subrc
                                 p_mkpf     TYPE mkpf.

  DATA:
    l_lmengezub LIKE qals-lmengezub,
    l_lmengegeb LIKE qals-lmengezub,
    l_mbqss     LIKE mbqss,
    l_imkpf     LIKE imkpf,
    l_imseg     LIKE imseg,
    l_imseg_tab LIKE imseg OCCURS 1,
    l_emkpf     LIKE emkpf,
    l_emseg     LIKE emseg,
    l_emseg_tab LIKE emseg OCCURS 1,
    l_mseg      LIKE mseg,
    l_mseg_tab  LIKE mseg  OCCURS 1,
    l_tcode     LIKE sy-tcode VALUE 'QA11',
    l_tabix     LIKE sy-tabix VALUE 1,
    l_xstbw     LIKE t156-xstbw.

  CLEAR: p_subrc.

*/QAMB initialisieren
  CALL FUNCTION 'QAMB_REFRESH_DATA'.

*/Kopf füllen
  l_imkpf-bldat = p_mkpf-bldat.
  l_imkpf-budat = p_mkpf-budat.
  l_imkpf-bktxt = 'Cancellation of QM UD postings'.

*/Ursprüngliche zu buchende Menge merken + inkrementieren
  l_lmengezub = p_qals-lmengezub.
  l_lmengegeb =   p_qals-lmenge01
                + p_qals-lmenge02
                + p_qals-lmenge03
                + p_qals-lmenge04
                + p_qals-lmenge05
                + p_qals-lmenge06
                + p_qals-lmenge07
                + p_qals-lmenge08
                + p_qals-lmenge09.


*/Zeilen aufbauen
  l_mseg_tab[] = p_mseg_tab[].

  LOOP AT l_mseg_tab INTO l_mseg WHERE mblnr = p_mkpf-mblnr
                                   AND mjahr = p_mkpf-mjahr.
    MOVE-CORRESPONDING l_mseg  TO l_mbqss.
    MOVE-CORRESPONDING l_mbqss TO l_imseg.
*/  Referenzbeleg übergeben, falls Bestellnummer gefüllt
    IF NOT l_mseg-ebeln IS INITIAL.
      MOVE: l_mseg-lfbnr TO l_imseg-lfbnr,
            l_mseg-lfbja TO l_imseg-lfbja,
            l_mseg-lfpos TO l_imseg-lfpos.
    ENDIF.
    MOVE l_mseg-kdauf          TO l_imseg-kdauf.
    MOVE l_mseg-kdpos          TO l_imseg-kdpos.
    MOVE l_mseg-ps_psp_pnr     TO l_imseg-ps_psp_pnr.

*/  Umlagerungsfelder setzen
    MOVE:
        l_mseg-ummat  TO l_imseg-ummat,
        l_mseg-umwrk  TO l_imseg-umwrk,
        l_mseg-umlgo  TO l_imseg-umlgo,
        l_mseg-umcha  TO l_imseg-umcha.

*/  Storno-Beleg setzen
    MOVE: l_mseg-mjahr  TO l_imseg-sjahr,
          l_mseg-mblnr  TO l_imseg-smbln,
          l_mseg-zeile  TO l_imseg-smblp.

*/  Falsch gefüllte Felder initialisieren
    CLEAR: l_imseg-mblnr,
           l_imseg-menge,
           l_imseg-meins.

*/  Bewegungsart lesen
    SELECT SINGLE xstbw FROM t156 INTO l_xstbw
      WHERE bwart = l_imseg-bwart.
    IF NOT sy-subrc IS INITIAL.
      p_subrc = 4.
      EXIT.
    ENDIF.

*/  Werk/Lagerort füllen
    IF p_qals-stat11 IS INITIAL.

      IF l_xstbw IS INITIAL.
        MOVE p_qals-lagortvorg TO l_imseg-lgort.
      ELSE.
        MOVE p_qals-lagortvorg TO l_imseg-umlgo.
      ENDIF.
    ENDIF.
    IF l_xstbw IS INITIAL.
      MOVE p_qals-werkvorg TO l_imseg-werks.
    ELSE.
      MOVE p_qals-werkvorg TO l_imseg-umwrk.
    ENDIF.

*/  Zusätzliche Felder
    MOVE p_qals-mengeneinh TO l_imseg-erfme.
    "MOVE P_GRUND           TO L_IMSEG-GRUND.
    "MOVE P_ELIKZ           TO L_IMSEG-ELIKZ.
*/  Kennzeichen Storno-Buchung setzen
    MOVE 'X'               TO l_imseg-xstob.
    MOVE p_qals-prueflos   TO l_imseg-qplos.

    APPEND l_imseg TO l_imseg_tab.
    IF p_qals-stat11 IS INITIAL.
      ADD      l_imseg-erfmg TO   l_lmengezub.
      SUBTRACT l_imseg-erfmg FROM l_lmengegeb.
    ELSE.
      IF     l_imseg-kzbew EQ space
         AND l_imseg-werks NE space
         AND l_imseg-lgort NE space
         AND l_imseg-umwrk NE space
         AND l_imseg-umlgo NE space
         AND l_imseg-werks EQ l_imseg-umwrk
         AND l_imseg-umlgo EQ l_imseg-umlgo.
*/      Dummy Buchung bei WE-Sperrbestand & Stichprobe
      ELSE.
        ADD      l_imseg-erfmg TO   l_lmengezub.
        SUBTRACT l_imseg-erfmg FROM l_lmengegeb.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF NOT p_qals-stat11 IS INITIAL.
*/  Bei WE-Sperrbestand und Stichprobenbuchung Zeilen tauschen
    DO.
      READ TABLE l_imseg_tab INDEX sy-index INTO l_imseg.
      IF     sy-subrc      IS INITIAL
         AND l_imseg-kzbew EQ space
         AND l_imseg-werks NE space
         AND l_imseg-lgort NE space
         AND l_imseg-umwrk NE space
         AND l_imseg-umlgo NE space
         AND l_imseg-werks EQ l_imseg-umwrk
         AND l_imseg-umlgo EQ l_imseg-umlgo.

        IF sy-tabix NE l_tabix.
          DELETE l_imseg_tab INDEX sy-tabix.
          INSERT l_imseg     INTO  l_imseg_tab INDEX l_tabix.
          l_tabix = l_tabix + 1.
        ELSE.
          l_tabix = l_tabix + 1.
          CONTINUE.
        ENDIF.
      ELSEIF sy-subrc IS INITIAL.
        CONTINUE.
      ELSE.
        EXIT.                          "from do
      ENDIF.
    ENDDO.
  ENDIF.

*/QM deaktivieren
  CALL FUNCTION 'QAAT_QM_ACTIVE_INACTIVE'
    EXPORTING
      aktiv = space.
*/Buchen
  CALL FUNCTION 'MB_CREATE_GOODS_MOVEMENT'
    EXPORTING
      imkpf = l_imkpf
      xallp = 'X'
      xallr = 'X'
      ctcod = l_tcode
      xqmcl = ' '
    IMPORTING
      emkpf = l_emkpf
    TABLES
      imseg = l_imseg_tab
      emseg = l_emseg_tab.
*/QM wieder aktivieren
  CALL FUNCTION 'QAAT_QM_ACTIVE_INACTIVE'
    EXPORTING
      aktiv = 'X'.

*/Buchung auswerten
  IF l_emkpf-subrc GT 1.
    IF l_emkpf-msgid NE space.
*/    Fehler auf Kopfebene
      MESSAGE ID l_emkpf-msgid TYPE 'S'
              NUMBER l_emkpf-msgno
              WITH l_emkpf-msgv1 l_emkpf-msgv2
                   l_emkpf-msgv3 l_emkpf-msgv4.
      SUBMIT (sy-repid) VIA SELECTION-SCREEN.
    ELSE.
*/    Fehler auf Zeilenebene (Ausgabe des ersten Fehlers)
      LOOP AT l_emseg_tab INTO l_emseg.
        IF l_emseg-msgid NE space.
          MESSAGE ID l_emseg-msgid TYPE 'S'
                NUMBER l_emseg-msgno
                WITH l_emseg-msgv1 l_emseg-msgv2
                     l_emseg-msgv3 l_emseg-msgv4.
          SUBMIT (sy-repid) VIA SELECTION-SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  LOOP AT l_emseg_tab INTO l_emseg.
    CALL FUNCTION 'QAMB_COLLECT_RECORD'
      EXPORTING
        lotnumber   = p_qals-prueflos
        docyear     = l_emkpf-mjahr
        docnumber   = l_emkpf-mblnr
        docposition = l_emseg-mblpo
        type        = '7'.
  ENDLOOP.

*/Sonderkorrektur für Frei-An-Frei & WE-Sperr-An-We-Sperr
  IF NOT p_qals-stat11 IS INITIAL.
    IF p_qals-lmenge04 EQ l_lmengegeb.
      ADD      p_qals-lmenge04 TO   l_lmengezub.
      SUBTRACT p_qals-lmenge04 FROM l_lmengegeb.
    ENDIF.
  ELSEIF p_qals-insmk IS INITIAL.
    IF         p_qals-lmenge01 GE l_lmengegeb
       AND NOT p_qals-lmenge01 IS INITIAL.
      ADD      l_lmengegeb     TO   l_lmengezub.
      SUBTRACT l_lmengegeb     FROM l_lmengegeb.
    ENDIF.
  ENDIF.

  CLEAR: p_qals-stat34,
         p_qals-matnrneu,
         p_qals-chargneu,
         p_qals-lmenge01,
         p_qals-lmenge02,
         p_qals-lmenge03,
         p_qals-lmenge04,
         p_qals-lmenge05,
         p_qals-lmenge06,
         p_qals-lmenge07,
         p_qals-lmenge08,
         p_qals-lmenge09.

  p_qals-lmengezub = l_lmengezub.
  IF NOT l_lmengegeb IS INITIAL.
    p_subrc = 4.
  ENDIF.

ENDFORM.                               " CREATE_GOODS_MOVEMENT

*----------------------------------------------------------------------*
*       Form  POST_GOODS_MOVEMENT                                      *
*----------------------------------------------------------------------*
*       Warenbewegung buchen                                           *
*----------------------------------------------------------------------*
FORM post_goods_movement.

  CALL FUNCTION 'MB_POST_GOODS_MOVEMENT'.

ENDFORM.                               " POST_GOODS_MOVEMENT

*----------------------------------------------------------------------*
*       Form  POST_DATA                                                *
*----------------------------------------------------------------------*
*       QM-Daten verbuchen                                             *
*----------------------------------------------------------------------*
FORM post_data USING p_qals        LIKE qals
                     p_qals_leiste LIKE qals
                     p_qamb_tab    TYPE qambtab
                     p_qamb_vb_tab TYPE qambtab
                     p_subrc       LIKE sy-subrc.

  DATA:
    l_stat        LIKE jstat,
    l_stat_tab    LIKE jstat OCCURS 0,
    l_qamb        LIKE qamb,
    l_updkz       LIKE qalsvb-upsl VALUE 'U'.

*/QAMBs umsetzen (7 = VE-Buchung storniert)
  LOOP AT p_qamb_tab INTO l_qamb.
    l_qamb-typ = '7'.
    APPEND l_qamb TO p_qamb_vb_tab.
  ENDLOOP.

*/BERF & BTEI zurücknehmen
  CLEAR l_stat. CLEAR l_stat_tab.
  l_stat-inact = 'X'.
  l_stat-stat = 'I0219'. APPEND l_stat TO l_stat_tab. "BTEI
  l_stat-stat = 'I0220'. APPEND l_stat TO l_stat_tab. "BEND

  CALL FUNCTION 'STATUS_CHANGE_INTERN'
    EXPORTING
      objnr         = p_qals-objnr
    TABLES
      status        = l_stat_tab
    EXCEPTIONS
      error_message = 1.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    SUBMIT (sy-repid) VIA SELECTION-SCREEN.
  ENDIF.

*/Prüflos aktualisieren
  CALL FUNCTION 'QPL1_UPDATE_MEMORY'
    EXPORTING
      i_qals  = p_qals
      i_updkz = l_updkz.

  CALL FUNCTION 'QPL1_INSPECTION_LOTS_POSTING'
    EXPORTING
      i_mode = '1'.

  CALL FUNCTION 'STATUS_UPDATE_ON_COMMIT'.

*/QAMB initialisieren
  CALL FUNCTION 'QAMB_REFRESH_DATA'.

  PERFORM update_qamb ON COMMIT.

  p_subrc = 0.

ENDFORM.                               " POST_DATA

*----------------------------------------------------------------------*
*       Form  UPDATE_QAMB                                              *
*----------------------------------------------------------------------*
*       Update auf QAMB                                                *
*----------------------------------------------------------------------*
FORM update_qamb.

  CALL FUNCTION 'QEVA_QAMB_CANCEL' IN UPDATE TASK
    EXPORTING
      t_qamb_tab = g_qamb_vb_tab.

ENDFORM.                               " UPDATE_QAMB

*----------------------------------------------------------------------*
*       Form  CHECK_MSEG                                               *
*----------------------------------------------------------------------*
*       MSEGs prüfen                                                   *
*----------------------------------------------------------------------*
FORM check_mseg USING p_mseg_tab TYPE t_mseg_tab
                      p_qamb_tab TYPE qambtab
                      p_subrc    LIKE sy-subrc.

  DATA:
    l_mseg_stor_tab LIKE mseg OCCURS 0 WITH HEADER LINE.

  CLEAR: p_subrc.

*/Zeilen bereits storniert?
  SELECT mblnr mjahr zeile smbln sjahr smblp
    FROM mseg INTO CORRESPONDING FIELDS OF TABLE l_mseg_stor_tab
    FOR ALL ENTRIES IN p_mseg_tab
    WHERE smbln EQ p_mseg_tab-mblnr
      AND sjahr EQ p_mseg_tab-mjahr
      AND smblp EQ p_mseg_tab-zeile.

  IF sy-subrc IS INITIAL.
    LOOP AT l_mseg_stor_tab.
      DELETE p_mseg_tab WHERE     mblnr = l_mseg_stor_tab-smbln
                              AND mjahr = l_mseg_stor_tab-sjahr
                              AND zeile = l_mseg_stor_tab-smblp.
      DELETE p_qamb_tab WHERE     mblnr = l_mseg_stor_tab-smbln
                              AND mjahr = l_mseg_stor_tab-sjahr
                              AND zeile = l_mseg_stor_tab-smblp.
    ENDLOOP.
    IF p_mseg_tab[] IS INITIAL.
      p_subrc = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                               " CHECK_MSEG
*----------------------------------------------------------------------*
*       Form  CHECK_MKPF                                               *
*----------------------------------------------------------------------*
*       Materialbelege prüfen (Wurde durch VE-Buchung Prüfllos erzeugt?*
*----------------------------------------------------------------------*
FORM check_mkpf USING p_mkpf_tab TYPE t_mkpf_tab
                      p_subrc    LIKE sy-subrc.

  DATA:
    l_mkpf_tab TYPE t_mkpf_tab.

  CLEAR: p_subrc.

  SELECT mblnr FROM qamb INTO CORRESPONDING FIELDS OF TABLE l_mkpf_tab
    FOR ALL ENTRIES IN p_mkpf_tab
    WHERE mblnr EQ p_mkpf_tab-mblnr
      AND mjahr EQ p_mkpf_tab-mjahr
      AND typ   = '1'.

  IF sy-subrc IS INITIAL.
    p_subrc = 4.
  ENDIF.

ENDFORM.                               " CHECK_MKPF
