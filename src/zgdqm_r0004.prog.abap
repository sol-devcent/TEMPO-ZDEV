

************************************************************************
* Report ZGDQM_R0004                                                   *
* Copied from REPORT RM07MMHD   (Transaktionscode MB5M)                *
* by IBM                                                               *
* adding MCHA-HSDAT/MCH1-HSDAT to ALV view                             *
************************************************************************

* March 5th, 2002 MM
* MB5M: Branching to the material/batch display             "n500980

************************************************************************
*     Mindesthaltbarkeitsliste                                         *
************************************************************************
*  relevante Felder:  MARA-MHDHB - Gesamthaltbarkeit in Tagen
*                     MARA-MHDRZ - Mindestrestlaufzeit
*                     MARA-MHDLP - Lagerprozentsatz
*                     MARA-IPRKZ - internes Periodenkennzeichen für MHD
*                     MARA-RDMHD - Rundungsregel für Berechnung MHD
*                     MCHA-VFDAT - Verfallsdatum oder
*                                  Mindesthaltbarkeitsdatum
*                     MCH1-VFDAT - Verfallsdatum oder
*                                  Mindesthaltbarkeitsdatum
************************************************************************

INCLUDE : zgdqmr0004top,   "copied from RM07MMHT
*          rm07mmht,               " reportspezifische Datendefinitionen
          mm07mabc,                    " Variablen zum Zeichensatz
          rm07musr,               " Tastenbelegungen und Transkationen
          rm07mend,               " Anforderungsbild und Enderoutine
          rm07msql,                    " allg. Datendefinitionen
          rm07mmhp.                    " reporteigene Parameter


************************ HAUPTPROGRAMM *********************************

*---------------- F4-Hilfe für Reportvariante -------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f4_for_variant.

*----------- Prüfung der eingegebenen Selektionsparameter, ------------*
*---------------------- Berechtigungsprüfung --------------------------*
AT SELECTION-SCREEN.
  PERFORM eingaben_pruefen.
  PERFORM organisation.
  PERFORM berechtigung_pruefen.
*------------------------ Initialisierung -----------------------------*
INITIALIZATION.
  PERFORM initialisierung.

*------------------------- Datenselektion -----------------------------*
START-OF-SELECTION.
  PERFORM datenselektion.

*-------------------------- Datenausgabe-------------------------------*
END-OF-SELECTION.
  PERFORM daten_filtern.
  DESCRIBE TABLE bestand LINES index_z.
  IF NOT index_z IS INITIAL.
    PERFORM feldkatalog_aufbauen USING fieldcat[].
    PERFORM listausgabe.
  ELSE.
    IF NOT restzeit IS INITIAL.
      MESSAGE s222 WITH restzeit.
* Es existiert kein Material, dessen MHD in den nächsten & Tagen abläuft
    ELSE.
      MESSAGE s224.
*     Es existieren keine Materialien mit abgelaufenen MHD
    ENDIF.
  ENDIF.

*********************** Ende HAUPTPROGRAMM *****************************


************************** FORMROUTINEN ********************************

*&---------------------------------------------------------------------*
*&      Form  EINGABEN_PRUEFEN
*&---------------------------------------------------------------------*
*       Prüfung der Eingaben auf dem Selektionsbild                    *
*----------------------------------------------------------------------*
FORM eingaben_pruefen.

*----- Werk vorhanden ? -----------------------------------------------*
  SELECT * FROM t001w UP TO 1 ROWS WHERE werks IN werks. ENDSELECT.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e102(m3) WITH werks.
*   Das Werk & ist nicht vorhanden
  ENDIF.

*----- Lagerort vorhanden ? -------------------------------------------*
  IF NOT lgort-low IS INITIAL OR NOT lgort-high IS INITIAL.
    SELECT * FROM t001l UP TO 1 ROWS WHERE lgort IN lgort. ENDSELECT.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e103(m3) WITH lgort werks.
*     Der Lagerort & ist im Werk & nicht vorhanden
    ENDIF.
  ENDIF.

  IF NOT p_vari IS INITIAL.
    MOVE variante TO def_variante.
    MOVE p_vari TO def_variante-variant.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
         EXPORTING
              i_save     = variant_save
         CHANGING
              cs_variant = def_variante.
    variante = def_variante.
  ELSE.
    CLEAR variante.
    variante-report = repid.
  ENDIF.

ENDFORM.                               " EINGABEN_PRUEFEN

*&---------------------------------------------------------------------*
*&      Form  ORGANISATION
*&---------------------------------------------------------------------*
*       Abbildung der Organisationsstruktur:                           *
*       Werk, Lagerort                                                 *
*----------------------------------------------------------------------*
FORM organisation.

  SELECT DISTINCT t001w~werks t001w~name1 t001l~lgort t001l~lgobe
                  INTO CORRESPONDING FIELDS OF TABLE organ
                  FROM t001w INNER JOIN t001l
                  ON t001w~werks = t001l~werks
                  WHERE t001w~werks IN werks
                  AND   t001l~lgort IN lgort.

ENDFORM.                               " ORGANISATION

*&---------------------------------------------------------------------*
*&      Form  BERECHTIGUNG_PRUEFEN
*&---------------------------------------------------------------------*
*       Prüfung der Berechtigung für die ausgewählten Werke            *
*----------------------------------------------------------------------*
FORM berechtigung_pruefen.

  LOOP AT organ.
    AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
                   ID 'ACTVT' FIELD actvt03
                   ID 'WERKS' FIELD organ-werks.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e120 WITH organ-werks.
*------ Sie haben keine Berechtigung für dieses Werk ------------------*
    ENDIF.
  ENDLOOP.

ENDFORM.                               " BERECHTIGUNG_PRUEFEN

*&---------------------------------------------------------------------*
*&      Form  INITIALISIERUNG
*&---------------------------------------------------------------------*
*       Initialisierung des Selektionsbildes                           *
*----------------------------------------------------------------------*
FORM initialisierung.

  repid = sy-repid.

  variant_save = 'A'.
  CLEAR variante.
  variante-report = repid.
* Default-Variante holen:
  def_variante = variante.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
       EXPORTING
            i_save     = variant_save
       CHANGING
            cs_variant = def_variante
       EXCEPTIONS
            not_found  = 2.
  IF sy-subrc = 0.
    p_vari = def_variante-variant.
  ENDIF.

  print-no_print_listinfos = 'X'.
ENDFORM.                               " INITIALISIERUNG

*&---------------------------------------------------------------------*
*&      Form  DATENSELEKTION
*&---------------------------------------------------------------------*
*       Selektion der Chargendaten
*----------------------------------------------------------------------*
FORM datenselektion.

* Verfallsdatum/Mindesthaltbarkeitsdatum aus MCHA (Chargen):
  SELECT * FROM v_mmim_lc INTO CORRESPONDING FIELDS OF TABLE itab
                          WHERE matnr IN matnr
                          AND   werks IN werks
                          AND   lgort IN lgort
                          AND   charg IN charg
                          AND   xchpf = x
                          AND   vfdat NE '00000000'.
* Verfallsdatum/Mindesthaltbarkeitsdatum aus MCH1 (Chargen)
* (falls Chargenverwaltung werksübergreifend):
  SELECT * FROM v_mmim_lc INTO CORRESPONDING FIELDS OF itab
                          WHERE matnr IN matnr
                          AND   werks IN werks
                          AND   lgort IN lgort
                          AND   charg IN charg
                          AND   xchpf = x
                          AND   vfdat_1 NE '00000000'.
    APPEND itab.
  ENDSELECT.
***added for Tempo --- getting MCHA-HSDAT
  IF NOT itab[] IS INITIAL.
    SELECT mch1~matnr mcha~werks mch1~charg mch1~hsdat
           INTO CORRESPONDING FIELDS OF TABLE t_mcha
           FROM mcha JOIN mch1
           ON mcha~matnr = mch1~matnr AND
              mcha~charg = mch1~charg
           FOR ALL entries IN itab
           WHERE mch1~matnr = itab-matnr AND
*                 mcha~werks = itab-werks AND
                 mch1~charg = itab-charg.
    SORT t_mcha BY matnr charg.
  ENDIF.
***end of Tempo addition

  READ TABLE itab INDEX 1.
  CHECK sy-subrc IS INITIAL.
  SELECT * FROM mchb INTO CORRESPONDING FIELDS OF TABLE imchb
           FOR ALL ENTRIES IN itab WHERE matnr EQ itab-matnr
                                   AND   werks EQ itab-werks
                                   AND   lgort EQ itab-lgort
                                   AND   charg EQ itab-charg.

ENDFORM.                               " DATENSELEKTION

*&---------------------------------------------------------------------*
*&      Form  FELDKATALOG_AUFBAUEN
*&---------------------------------------------------------------------*
*       Aufbau des Feldkatalogs zur Listausgabe
*----------------------------------------------------------------------*
*      -->P_FIELDCAT[]  text                                           *
*----------------------------------------------------------------------*
FORM feldkatalog_aufbauen USING p_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: fieldcat TYPE slis_fieldcat_alv.

* Kopffelder:
  CLEAR fieldcat.
  fieldcat-fieldname     = 'MATNR'.    " Materialnummer
  fieldcat-tabname       = 'HEADER'.
  fieldcat-ref_tabname   = 'MCHA'.
  fieldcat-key           = 'X'.
  fieldcat-col_pos       = '1'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'MAKTX'.    " Materialkurztext
  fieldcat-tabname       = 'HEADER'.
  fieldcat-ref_tabname   = 'MAKT'.
  fieldcat-key           = 'X'.
  fieldcat-col_pos       = '2'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'MAKTG'.    " Materialkurztext
  fieldcat-tabname       = 'HEADER'.   " in Großschreibung
  fieldcat-ref_tabname   = 'MAKT'.     " für Matchcodes
  fieldcat-no_out        = 'X'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'WERKS'.    " Werk
  fieldcat-tabname       = 'HEADER'.
  fieldcat-ref_tabname   = 'MCHA'.
  fieldcat-key           = 'X'.
  fieldcat-col_pos       = '3'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'NAME1'.    " Name (des Werkes)
  fieldcat-tabname       = 'HEADER'.
  fieldcat-ref_tabname   = 'T001W'.
  fieldcat-no_out        = 'X'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'LGORT'.    " Lagerort
  fieldcat-tabname       = 'HEADER'.
  fieldcat-ref_tabname   = 'MARD'.
  fieldcat-key           = 'X'.
  fieldcat-col_pos       = '4'.
  APPEND fieldcat TO p_fieldcat.

* Positionsfelder:
  CLEAR fieldcat.
  fieldcat-fieldname     = 'AMPEL'.                         "
  fieldcat-tabname       = 'BESTAND'.
  fieldcat-col_pos       = '1'.
  APPEND fieldcat TO  p_fieldcat.
  IF lagrlz = x.
    CLEAR fieldcat.
    fieldcat-fieldname     = 'MHDRZ_VZ'.   " Restlaufzeit VZ
    fieldcat-tabname       = 'BESTAND'.
    fieldcat-ref_fieldname = 'MHDRZ'.
    fieldcat-ref_tabname   = 'MARA'.
    fieldcat-col_pos       = '2'.
    fieldcat-outputlen     = '6'.
    APPEND fieldcat TO  p_fieldcat.
    CLEAR fieldcat.
    fieldcat-fieldname     = 'EINDA_VZ'.         " Einheit 'Tage' VZ
    fieldcat-tabname       = 'BESTAND'.
    fieldcat-seltext_s     = text-014.
    fieldcat-seltext_m     = text-015.
    fieldcat-seltext_l     = text-016.
    fieldcat-col_pos       = '3'.
    fieldcat-outputlen     = '6'.
    APPEND fieldcat TO  p_fieldcat.
    CLEAR fieldcat.
    fieldcat-fieldname     = 'MHDAT'.  " Haltbarkeit Vert.zentrum
    fieldcat-tabname       = 'BESTAND'.
    fieldcat-ref_fieldname = 'VFDAT'.
    fieldcat-ref_tabname   = 'MCHA'.
    fieldcat-seltext_s     = text-017.
    fieldcat-seltext_m     = text-018.
    fieldcat-seltext_l     = text-019.
    fieldcat-outputlen     = '14'.
    fieldcat-col_pos       = '4'.
    APPEND fieldcat TO  p_fieldcat.
  ENDIF.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'MHDRZ'.    " Restlaufzeit
  fieldcat-tabname       = 'BESTAND'.
  fieldcat-ref_tabname   = 'MARA'.
  fieldcat-col_pos       = '5'.
  fieldcat-outputlen     = '6'.
  APPEND fieldcat TO  p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'EINDA'.    " Einheit 'Tage'
  fieldcat-tabname       = 'BESTAND'.
  fieldcat-col_pos       = '6'.
  fieldcat-outputlen     = '6'.
  APPEND fieldcat TO  p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'VFDAT'.    " Verfallsdatum oder
  fieldcat-tabname       = 'BESTAND'.  " Mindesthaltbarkeitsdatum
  fieldcat-ref_tabname   = 'MCHA'.
  fieldcat-col_pos       = '7'.
  fieldcat-outputlen     = '11'.
  APPEND fieldcat TO  p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'MHDHB'.    " Haltbarkeit
  fieldcat-tabname       = 'BESTAND'.
  fieldcat-ref_tabname   = 'MARA'.
  fieldcat-no_out        = 'X'.
  APPEND fieldcat TO  p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'MHDLP'.    " Lagerprozentsatz
  fieldcat-tabname       = 'BESTAND'.
  fieldcat-ref_tabname   = 'MARA'.
  fieldcat-no_out        = 'X'.
  APPEND fieldcat TO  p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'CHARG'.    " Chargennummer
  fieldcat-tabname       = 'BESTAND'.
  fieldcat-ref_tabname   = 'MCHA'.
  fieldcat-col_pos       = '8'.
  APPEND fieldcat TO  p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'MENGE'.    " Menge
  fieldcat-tabname       = 'BESTAND'.
  fieldcat-ref_fieldname = 'CLABS'.
  fieldcat-ref_tabname   = 'MCHB'.
  fieldcat-qfieldname    = 'MEINS'.
  fieldcat-col_pos       = '9'.
  fieldcat-do_sum        = 'X'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'MEINS'.    " Basismengeneinheit
  fieldcat-tabname       = 'BESTAND'.
  fieldcat-ref_tabname   = 'MARA'.
  fieldcat-col_pos       = '10'.
  APPEND fieldcat TO p_fieldcat.
***added for Tempo - HSDAT
  CLEAR fieldcat.
  fieldcat-fieldname     = 'HSDAT'.
  fieldcat-tabname       = 'BESTAND'.
*  fieldcat-ref_tabname   = 'MCHA'.
  fieldcat-seltext_s     = 'Mfg.date'.
  fieldcat-seltext_m     = 'Mfg.date'.
  fieldcat-seltext_l     = 'Manufacturing date'.
  fieldcat-col_pos       = '11'.
  fieldcat-outputlen     = '11'.
  APPEND fieldcat TO  p_fieldcat.
***end of Tempo addition

ENDFORM.                               " FELDKATALOG_AUFBAUEN

*&---------------------------------------------------------------------*
*&      Form  LISTAUSGABE
*&---------------------------------------------------------------------*
*       Ausgabe der Liste
*----------------------------------------------------------------------*
FORM listausgabe.

  keyinfo-header01 = 'MATNR'.
  keyinfo-header02 = 'WERKS'.
  keyinfo-header03 = 'LGORT'.

  SORT bestand BY matnr werks lgort.
  LOOP AT bestand.
    ON CHANGE OF bestand-matnr OR bestand-werks OR bestand-lgort.
      MOVE bestand-matnr TO header-matnr.
      MOVE bestand-werks TO header-werks.
      MOVE bestand-lgort TO header-lgort.
      SELECT SINGLE * FROM makt WHERE matnr = bestand-matnr
                                AND   spras = sy-langu.
      IF sy-subrc EQ 0.
        MOVE makt-maktx TO header-maktx.
        MOVE makt-maktg TO header-maktg.
      ENDIF.
      READ TABLE organ WITH KEY werks = bestand-werks
                                lgort = bestand-lgort.
      IF sy-subrc EQ 0.
        MOVE organ-name1 TO header-name1.
        MOVE organ-lgobe TO header-lgobe.
      ENDIF.
      APPEND header.
    ENDON.
  ENDLOOP.

  layout-coltab_fieldname = 'FARBE'.
  layout-lights_fieldname = 'AMPEL'.
  layout-lights_tabname   = 'BESTAND'.
  layout-lights_condense  = 'X'.
  layout-f2code = '9CHG'.
  layout-group_change_edit = 'X'.

  sumsort-fieldname = 'MATNR'.
  sumsort-tabname   = 'HEADER'.
  sumsort-up        = 'X'.
  sumsort-subtot    = 'X'.
  APPEND sumsort.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
       EXPORTING
            i_callback_program       = repid
            i_callback_pf_status_set = 'STATUS'
            i_callback_user_command  = 'USER_COMMAND'
            is_layout                = layout
            it_fieldcat              = fieldcat[]
*           IT_EXCLUDING             =
*           it_special_groups        = gruppen[]
            it_sort                  = sumsort[]
*           IT_FILTER                =
*           IS_SEL_HIDE              =
*           I_SCREEN_START_COLUMN    = 0
*           I_SCREEN_START_LINE      = 0
*           I_SCREEN_END_COLUMN      = 0
*           I_SCREEN_END_LINE        = 0
            i_default                = 'X'
            i_save                   = 'A'
            is_variant               = variante
*           IT_EVENTS                =
*           IT_EVENT_EXIT            =
            i_tabname_header         = 'HEADER'
            i_tabname_item           = 'BESTAND'
            is_keyinfo               = keyinfo
            is_print                 = print
*      IMPORTING
*           E_EXIT_CAUSED_BY_CALLER  =
       TABLES
            t_outtab_header          = header
            t_outtab_item            = bestand.
*      exceptions
*           program_error            = 1
*           others                   = 2.

ENDFORM.                               " LISTAUSGABE

*&---------------------------------------------------------------------*
*&      Form  DATEN_FILTERN
*&---------------------------------------------------------------------*
*       Nur Daten mit MHD und Chargen werden beruecksichtigt           *
*----------------------------------------------------------------------*
FORM daten_filtern.
  DATA: mhdrz_temp TYPE p,
        mhdrz_vz_temp TYPE p.
  DESCRIBE TABLE itab LINES index_z.
  IF index_z IS INITIAL.
    MESSAGE s224.
*   Es existieren keine Materialien mit abgelaufenen MHD
    PERFORM anforderungsbild.
  ENDIF.
  SORT itab BY matnr charg werks lgort.
  DELETE ADJACENT DUPLICATES FROM itab.
  LOOP AT itab.
    IF itab-vfdat IS INITIAL.
      itab-vfdat = itab-vfdat_1.
    ENDIF.
    CLEAR: bestand-mhdrz.
    READ TABLE imchb WITH KEY matnr = itab-matnr
                              werks = itab-werks
                              lgort = itab-lgort
                              charg = itab-charg.
    CHECK sy-subrc IS INITIAL.
    MOVE itab-vfdat TO bestand-vfdat.  "MHD Charge
    MOVE itab-mhdlp TO bestand-mhdlp.  "Lagerprozentsatz
    MOVE itab-mhdhb TO bestand-mhdhb.  "Gesamthaltbarkeit
    MOVE-CORRESPONDING imchb TO bestand.
    MOVE imchb-clabs TO bestand-menge.
    MOVE itab-meins  TO bestand-meins.
    IF nullb = ' '.
      CHECK bestand-menge GT null.
    ENDIF.

***added for Tempo -- adding HSDAT
    CLEAR bestand-hsdat.
    READ TABLE t_mcha WITH KEY matnr = itab-matnr
                               charg = itab-charg
                               BINARY SEARCH.
    IF sy-subrc = 0.
      bestand-hsdat = t_mcha-hsdat.
    ENDIF.
***end of Tempo addition

* Aktuelle (Gesamt)Restlaufzeit = Verfallsdatum - aktuelles Datum:
    mhdrz_temp = itab-vfdat - sy-datlo.
    IF mhdrz_temp > 99999. mhdrz_temp = 99999. ENDIF.
    IF mhdrz_temp < -99999. mhdrz_temp = -99999. ENDIF.
    bestand-mhdrz = mhdrz_temp.
* Restlaufzeit für Filiale und Verteilungszentrum:
    IF lagrlz = x.
      CHECK NOT itab-mhdlp IS INITIAL. " Prozentsatz vorhanden ?
* itab-mhdrz: Mindestrestlaufzeit bei Wareneingang.
* itab-mhdlp: Prozentsatz, der angibt, wieviel Prozent der
* Restlaufzeit des Materials noch gelten muß, wenn das Material von
* einem zentralen Werk (z.B. Verteilzentrum) an ein anderes Werk
* (z.B. Filiale) geschickt wird.
*     MHD Verteilungszentrum:
      DATA: factor TYPE i.
      CASE itab-iprkz.
        WHEN 1. factor = 7.
        WHEN 2. factor = 30.
        WHEN 3. factor = 365.
        WHEN OTHERS. factor = 1.
      ENDCASE.
      mhdat = itab-vfdat - ( itab-mhdrz * factor * itab-mhdlp / 100 ).
      mhdrz_vz_temp = mhdat - sy-datlo.
      IF mhdrz_vz_temp > 99999. mhdrz_vz_temp = 99999. ENDIF.
      IF mhdrz_vz_temp < -99999. mhdrz_vz_temp = -99999. ENDIF.
      bestand-mhdrz_vz = mhdrz_vz_temp.
      bestand-mhdat = mhdat.
      mhda1 = sy-datlo + restzeit.
      CHECK mhdat LE mhda1.
    ELSEIF gesrlz = x.
      mhda1 = sy-datlo + restzeit.
      CHECK mhda1 GE itab-vfdat.
    ENDIF.
    IF NOT tagfo IS INITIAL.
      MOVE text-010 TO bestand-einda.
      MOVE text-010 TO bestand-einda_vz.
    ELSEIF NOT perfo IS INITIAL.
      PERFORM runden CHANGING itab-iprkz itab-rdmhd bestand-mhdrz.
      PERFORM runden CHANGING itab-iprkz itab-rdmhd bestand-mhdrz_vz.
      CASE itab-iprkz.
        WHEN  1.
          MOVE text-011 TO bestand-einda.
          MOVE text-011 TO bestand-einda_vz.
        WHEN 2.
          MOVE text-012 TO bestand-einda.
          MOVE text-012 TO bestand-einda_vz.
        WHEN 3.
          MOVE text-013 TO bestand-einda.
          MOVE text-013 TO bestand-einda_vz.
        WHEN OTHERS.
          MOVE text-010 TO bestand-einda.
          MOVE text-010 TO bestand-einda_vz.
      ENDCASE.
    ENDIF.
* Farbinformation:
    CLEAR color.
    REFRESH color.
    IF lagrlz = x.
      IF bestand-mhdrz_vz >= 0.
        color-fieldname = 'MHDRZ_VZ'.  " Verteilungszentrum
        color-color-col = '5'.
        color-color-int = '0'.
        APPEND color.
        color-fieldname = 'EINDA_VZ'.
        color-color-col = '5'.
        color-color-int = '0'.
        APPEND color.
      ELSEIF bestand-mhdrz_vz < 0.
        color-fieldname = 'MHDRZ_VZ'.
        color-color-col = '6'.
        color-color-int = '0'.
        APPEND color.
        color-fieldname = 'EINDA_VZ'.
        color-color-col = '6'.
        color-color-int = '0'.
        APPEND color.
      ENDIF.
    ENDIF.
    IF bestand-mhdrz >= 0.
      color-fieldname = 'MHDRZ'.
      color-color-col = '5'.
      color-color-int = '0'.
      APPEND color.
      color-fieldname = 'EINDA'.
      color-color-col = '5'.
      color-color-int = '0'.
      APPEND color.
    ELSEIF bestand-mhdrz < 0.
      color-fieldname = 'MHDRZ'.
      color-color-col = '6'.
      color-color-int = '0'.
      APPEND color.
      color-fieldname = 'EINDA'.
      color-color-col = '6'.
      color-color-int = '0'.
      APPEND color.
    ENDIF.
    bestand-farbe = color[].
    IF bestand-mhdrz < 0.
      bestand-ampel = '1'.
    ELSEIF bestand-mhdrz = 0.
      bestand-ampel = '2'.
    ELSEIF bestand-mhdrz > 0.
      bestand-ampel = '3'.
    ENDIF.
    APPEND bestand.
  ENDLOOP.

ENDFORM.                               " DATEN_FILTERN

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND                                             *
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

* The branch functions overwrite the current values in the  "n500980
* user's parameters area. The current values will be saved  "n500980
  DATA : BEGIN OF l_save_params,                            "n500980
           matnr             LIKE      mcha-matnr,          "n500980
           werks             LIKE      mcha-werks,          "n500980
           charg             LIKE      mcha-charg,          "n500980
         END OF l_save_params.                              "n500980
                                                            "n500980
  GET PARAMETER ID 'MAT'     FIELD  l_save_params-matnr.    "n500980
  GET PARAMETER ID 'WRK'     FIELD  l_save_params-werks.    "n500980
  GET PARAMETER ID 'CHA'     FIELD  l_save_params-charg.    "n500980
                                                            "n500980
* MB5M: Branching to the material/batch display             "n500980

  CASE r_ucomm.
    WHEN '9MAT'.
*     the function "show material master" is possible for   "n500980
*     all availabe lines of the list                        "n500980
      CASE     rs_selfield-tabname.  "what kind of line ?   "n500980
        WHEN  'HEADER'.                                     "n500980
          READ TABLE header INDEX rs_selfield-tabindex.     "n500980
                                                            "n500980
          IF sy-subrc IS INITIAL.                           "n500980
            SET PARAMETER ID 'MAT' FIELD header-matnr.      "n500980
            SET PARAMETER ID 'WRK' FIELD header-werks.      "n500980
            CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.  "n500980
          ELSE.                                             "n500980
            MESSAGE e847 WITH text-023.                     "n500980
*           Bitte den Cursor auf & positionieren            "n500980
*           Text-023: ein Material                          "n500980
          ENDIF.                                            "n500980
                                                            "n500980
        WHEN  'BESTAND'.                                    "n500980
          READ TABLE bestand INDEX rs_selfield-tabindex.    "n500980
                                                            "n500980
          IF sy-subrc IS INITIAL.                           "n500980
            SET PARAMETER ID 'MAT' FIELD bestand-matnr.     "n500980
            SET PARAMETER ID 'WRK' FIELD bestand-werks.     "n500980
            CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.  "n500980
          ELSE.                                             "n500980
            MESSAGE e847 WITH text-023.                     "n500980
*           Bitte den Cursor auf & positionieren            "n500980
*           Text-023: ein Material                          "n500980
          ENDIF.                                            "n500980
                                                            "n500980
      ENDCASE.                                              "n500980

    WHEN '9CHG'.
      READ TABLE bestand INDEX rs_selfield-tabindex.

      IF sy-subrc             IS INITIAL AND                "n500980
         rs_selfield-tabname  =  'BESTAND'.                 "n500980
        SET PARAMETER ID 'MAT' FIELD bestand-matnr.
        SET PARAMETER ID 'WRK' FIELD bestand-werks.
        SET PARAMETER ID 'CHA' FIELD bestand-charg.
        CALL TRANSACTION 'MSC3N' AND SKIP FIRST SCREEN.
      ELSE.
        MESSAGE e847 WITH text-022.
*       Bitte den Cursor auf & positionieren
*       Text-022: eine Charge
      ENDIF.
  ENDCASE.

* restore the old values into the user's parameters area    "n500980
  SET PARAMETER ID 'MAT'     FIELD  l_save_params-matnr.    "n500980
  SET PARAMETER ID 'WRK'     FIELD  l_save_params-werks.    "n500980
  SET PARAMETER ID 'CHA'     FIELD  l_save_params-charg.    "n500980

ENDFORM.                               " USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*       F4-Hilfe für Reportvariante                                    *
*----------------------------------------------------------------------*
FORM f4_for_variant.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
       EXPORTING
            is_variant          = variante
            i_save              = variant_save
*           it_default_fieldcat =
       IMPORTING
            e_exit              = variant_exit
            es_variant          = def_variante
       EXCEPTIONS
            not_found = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF variant_exit = space.
      p_vari = def_variante-variant.
    ENDIF.
  ENDIF.

ENDFORM.                               " F4_FOR_VARIANT

*&---------------------------------------------------------------------*
*&      Form  STATUS
*&---------------------------------------------------------------------*
FORM status USING extab TYPE slis_t_extab.

  SET PF-STATUS 'STANDARD' EXCLUDING extab.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  RUNDEN
*&---------------------------------------------------------------------*
*       Runden eines Wertes in Tagen (MHDRZ) gemäß Periodenkennzeichen
*       (IPRKZ) und Rundungsregel (RDMHD)
*----------------------------------------------------------------------*
*      <--P_ITAB_IPRKZ  text
*      <--P_ITAB_RDMHD  text
*      <--P_BESTAND_MHDRZ  text
*----------------------------------------------------------------------*
FORM runden CHANGING iprkz rdmhd mhdrz.
  DATA: temp TYPE p DECIMALS 4.
  temp = mhdrz.
  CASE iprkz.
    WHEN 1. DIVIDE temp BY 7.
    WHEN 2. DIVIDE temp BY 30.
    WHEN 3. DIVIDE temp BY 365.
  ENDCASE.
  mhdrz = floor( temp ).
ENDFORM.                    " RUNDEN
