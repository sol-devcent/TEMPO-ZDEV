***INCLUDE ZABP_ALV .
TYPE-POOLS: SLIS.

DATA: TA_SORT TYPE SLIS_T_SORTINFO_ALV.

DATA: GS_LAYOUT TYPE SLIS_LAYOUT_ALV,
      G_EXIT_CAUSED_BY_CALLER,
      GS_EXIT_CAUSED_BY_USER TYPE SLIS_EXIT_BY_USER,
      G_REPID LIKE SY-REPID.

DATA:
    GT_EVENTS      TYPE SLIS_T_EVENT,
    GT_LIST_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER,
    G_TOP_OF_PAGE  TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE',
    XIT_FIELDCAT   TYPE SLIS_T_FIELDCAT_ALV,
    XIS_PRINT      TYPE SLIS_PRINT_ALV.

DATA:  E_SAVE(1) TYPE C Value 'A',
       ER_SP_GROUP TYPE SLIS_T_SP_GROUP_ALV,
       E_EXIT(1) TYPE C,
       ER_VARIANT LIKE DISVARIANT,
       E_VARIANT  LIKE DISVARIANT,
       E_USER_COMMAND TYPE SLIS_FORMNAME VALUE 'USER_COMMAND'.

* E_USER_COMMAND adalah Nama form untuk user command
* E_SAVE adalah control untuk maintain layout variant

* Tentukan nama form untuk user command dengan mengisi variabel
* E_USER_COMMAND di program utama, bila tidak diisi default valuenya
* adalah 'USER_COMMAND'

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
*       Ereigniss TOP_OF_PAGE                                       *
*       event     TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM TOP_OF_PAGE.
     CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
          EXPORTING
             I_LOGO             = 'ENJOYSAP_LOGO'
             IT_LIST_COMMENTARY = GT_LIST_TOP_OF_PAGE.
ENDFORM.


*----------------------------------------------------------------------
*    FORM PF_STATUS_SET
*----------------------------------------------------------------------
*     Statussetzen
*     Status set
*----------------------------------------------------------------------
*    --> EXTAB
*----------------------------------------------------------------------
FORM STANDARD_ER01 USING  EXTAB TYPE SLIS_T_EXTAB.

* DELETE EXTAB WHERE FCODE = '&UMC'.
  DELETE EXTAB WHERE FCODE = '&RNT_PREV'.
  DELETE EXTAB WHERE FCODE = '&LFO'.
  DELETE EXTAB WHERE FCODE = '&NFO'.
*  SET PF-STATUS 'ALVLIST' EXCLUDING EXTAB.

ENDFORM.                    "STANDARD_ER01

*&---------------------------------------------------------------------*
*&      Form  BUILD_CAT
*&---------------------------------------------------------------------*
FORM BUILD_CAT Using FIELDNAME type SLIS_FIELDCAT_ALV-FIELDNAME
                          OUTPUTLEN type SLIS_FIELDCAT_ALV-OUTPUTLEN
                       REPTEXT_DDIC type SLIS_FIELDCAT_ALV-REPTEXT_DDIC
                          DATATYPE  type SLIS_FIELDCAT_ALV-DATATYPE
                          EMPHASIZE type SLIS_FIELDCAT_ALV-EMPHASIZE
                          ROLLNAME  type SLIS_FIELDCAT_ALV-ROLLNAME
                      REF_FIELDNAME type SLIS_FIELDCAT_ALV-REF_FIELDNAME
                        REF_TABNAME type SLIS_FIELDCAT_ALV-REF_TABNAME
                          DO_SUM    type SLIS_FIELDCAT_ALV-DO_SUM
                          hotspot   type SLIS_FIELDCAT_ALV-hotspot
                         FIX_COLUMN type SLIS_FIELDCAT_ALV-FIX_COLUMN
                          KEY       type SLIS_FIELDCAT_ALV-KEY
                          REPREP    type SLIS_FIELDCAT_ALV-REPREP
                          just      type SLIS_FIELDCAT_ALV-just
                          COL_POS   type SLIS_FIELDCAT_ALV-COL_POS.
  DATA: XFIELDCAT TYPE SLIS_FIELDCAT_ALV.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME     = FIELDNAME.
  XFIELDCAT-OUTPUTLEN     = OUTPUTLEN.
  XFIELDCAT-REPTEXT_DDIC  = REPTEXT_DDIC.
  XFIELDCAT-DATATYPE      = DATATYPE.
  XFIELDCAT-EMPHASIZE     = EMPHASIZE.         "Color
  XFIELDCAT-ROLLNAME      = ROLLNAME.
  XFIELDCAT-REF_FIELDNAME = REF_FIELDNAME.
  XFIELDCAT-REF_TABNAME   = REF_TABNAME.
  XFIELDCAT-DO_SUM        = DO_SUM.
  XFIELDCAT-hotspot       = hotspot.
  XFIELDCAT-FIX_COLUMN    = FIX_COLUMN.            "Key
  XFIELDCAT-KEY           = KEY.
  XFIELDCAT-REPREP        = REPREP.
  XFIELDCAT-just          = just.
  XFIELDCAT-COL_POS       = COL_POS.
  APPEND XFIELDCAT TO XIT_FIELDCAT.
ENDFORM.                    " BUILD_CAT

*&---------------------------------------------------------------------*
*&      Form  BUILD_CAT
*&---------------------------------------------------------------------*
FORM BUILDCAT_STRUC Using STRNAME Type C.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
     EXPORTING
          I_PROGRAM_NAME         = G_REPID
          I_INTERNAL_TABNAME     = STRNAME
          I_INCLNAME             = G_REPID
     CHANGING
          CT_FIELDCAT            = XIT_FIELDCAT
     EXCEPTIONS
          INCONSISTENT_INTERFACE = 1
          PROGRAM_ERROR          = 2
          OTHERS                 = 3.
ENDFORM.                    " BUILD_CAT

*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
* Untuk menampilkan judul pada title bar
FORM LAYOUT_INIT USING RS_LAYOUT TYPE SLIS_LAYOUT_ALV
                           TITLE TYPE C
                           ZEBRA TYPE FLAG.
  RS_LAYOUT-DETAIL_POPUP      = 'X'.
  RS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  RS_LAYOUT-ZEBRA             = ZEBRA.
  RS_layout-window_titlebar   = TITLE.
  RS_layout-reprep            = 'X'.
*  RS_layout-f2code            = '&EB9'.
  RS_layout-group_change_edit = 'X'.

ENDFORM.                    " LAYOUT_INIT
*&---------------------------------------------------------------------*
*&      Form  EVENTTAB_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
FORM EVENTTAB_BUILD USING RT_EVENTS TYPE SLIS_T_EVENT.
*"Registration of events to happen during list display
  DATA: LS_EVENT TYPE SLIS_ALV_EVENT.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
      EXPORTING
           I_LIST_TYPE = 0
      IMPORTING
           ET_EVENTS   = RT_EVENTS.

  READ TABLE RT_EVENTS WITH KEY NAME = SLIS_EV_TOP_OF_PAGE
                           INTO LS_EVENT.
  IF SY-SUBRC = 0.
    MOVE G_TOP_OF_PAGE TO LS_EVENT-FORM.
    APPEND LS_EVENT TO RT_EVENTS.
  ENDIF.

  READ TABLE RT_EVENTS WITH KEY NAME = SLIS_EV_USER_COMMAND
                           INTO LS_EVENT.
  IF SY-SUBRC = 0.
    MOVE E_USER_COMMAND TO LS_EVENT-FORM.
    APPEND LS_EVENT TO RT_EVENTS.
  ENDIF.

ENDFORM.                    " EVENTTAB_BUILD

*&---------------------------------------------------------------------*
*&      Form  COMMENT_BUILD
*&---------------------------------------------------------------------*
FORM COMMENT_BUILD USING LT_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER.
  DATA: LS_LINE TYPE SLIS_LISTHEADER.
  DATA: U_DATE(15) TYPE C.
****** Buat Header Line

  WRITE SY-DATUM to u_date.
* LIST HEADING LINE: TYPE H
  CLEAR LS_LINE.
  LS_LINE-TYP  = 'H'.
  LS_LINE-INFO = TEXT-100.
  APPEND LS_LINE TO LT_TOP_OF_PAGE.

  CLEAR LS_LINE.
  LS_LINE-TYP  = 'H'.
  LS_LINE-INFO = u_date.
  APPEND LS_LINE TO LT_TOP_OF_PAGE.

  CLEAR LS_LINE.
  LS_LINE-TYP  = 'H'.
  LS_LINE-INFO = SY-UNAME .
  APPEND LS_LINE TO LT_TOP_OF_PAGE.
ENDFORM.                    " COMMENT_BUILD
*&---------------------------------------------------------------------*
*&      Form  SP_GROUP_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_SP_GROUP[]  text
*----------------------------------------------------------------------*
FORM SP_GROUP_BUILD USING U_ER_SP_GROUP TYPE SLIS_T_SP_GROUP_ALV.

  DATA: LS_SP_GROUP TYPE SLIS_SP_GROUP_ALV.
  CLEAR  LS_SP_GROUP.
  LS_SP_GROUP-SP_GROUP = 'A'.
  LS_SP_GROUP-TEXT     = 'Standart'.
  APPEND LS_SP_GROUP TO U_ER_SP_GROUP.

ENDFORM.                               " SP_GROUP_BUILD
*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VARIANT_INIT.
  CLEAR E_VARIANT.
  E_VARIANT-REPORT = G_REPID.
ENDFORM.                    " VARIANT_INIT
*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*&---------------------------------------------------------------------*
FORM F4_FOR_VARIANT.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
       EXPORTING
            IS_VARIANT          = E_VARIANT
            I_SAVE              = E_SAVE
*           it_default_fieldcat =
       IMPORTING
            E_EXIT              = E_EXIT
            ES_VARIANT          = ER_VARIANT
       EXCEPTIONS
            NOT_FOUND = 2.
  IF SY-SUBRC = 2.
    MESSAGE ID SY-MSGID TYPE 'S'      NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    IF E_EXIT = SPACE.
      P_VARI = ER_VARIANT-VARIANT.
    ENDIF.
  ENDIF.

ENDFORM.                    " F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*&      Form  PAI_OF_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PAI_OF_SELECTION_SCREEN.
  IF NOT P_VARI IS INITIAL.
    MOVE E_VARIANT TO ER_VARIANT.
    MOVE G_REPID   TO ER_VARIANT-REPORT.
    MOVE P_VARI    TO ER_VARIANT-VARIANT.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE' " Überpr. des Ex. einer
         EXPORTING                     " Vari. auf der DB.
              I_SAVE     = E_SAVE
         CHANGING
              CS_VARIANT = ER_VARIANT.
    E_VARIANT = ER_VARIANT.
  ELSE.
    PERFORM VARIANT_INIT.
  ENDIF.
ENDFORM.                    " PAI_OF_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  SHOWLIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  LISTNAME     = Nama internal tabel output
*  -->  TITLE        = Judul report
*  -->  USER_COMMAND = Nama form utk user command (Default USER_COMMAND)
*----------------------------------------------------------------------*
Form SHOWLIST Using LISTNAME type C
                       TITLE type C
                USER_COMMAND TYPE  SLIS_FORMNAME.

FIELD-SYMBOLS: <itabname>  type TABLE.

  Assign (LISTNAME) to <itabname>.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
*  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
        I_BACKGROUND_ID    = 'ALV_BACKGROUND'
        I_CALLBACK_PROGRAM = G_REPID
        i_grid_title       = TITLE
        I_CALLBACK_USER_COMMAND  = USER_COMMAND
        IS_LAYOUT          = GS_LAYOUT
        IT_FIELDCAT        = XIT_FIELDCAT[]
        IT_SPECIAL_GROUPS  = ER_SP_GROUP
        IT_SORT            = TA_SORT[]
        I_SAVE             = E_SAVE      "Untuk setting maintain variant
        IS_VARIANT         = ER_VARIANT
*        IT_EVENTS          = GT_EVENTS[] "Untuk menampilkan logo ALV
*        IS_PRINT           = XIS_PRINT
    IMPORTING
        E_EXIT_CAUSED_BY_CALLER = G_EXIT_CAUSED_BY_CALLER
        ES_EXIT_CAUSED_BY_USER  = GS_EXIT_CAUSED_BY_USER
    TABLES
        T_OUTTAB = <itabname>
    EXCEPTIONS
        PROGRAM_ERROR = 1
        OTHERS        = 2.
Endform.                    " SHOWLIST
