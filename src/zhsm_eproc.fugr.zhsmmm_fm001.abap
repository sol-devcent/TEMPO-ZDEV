FUNCTION zhsmmm_fm001.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(OBJECTCLASS) TYPE  CDHDR-OBJECTCLAS
*"     VALUE(OBJECTID) TYPE  CDHDR-OBJECTID
*"     VALUE(TCODE) TYPE  CDHDR-TCODE
*"     VALUE(UTIME) TYPE  CDHDR-UTIME
*"     VALUE(UDATE) TYPE  CDHDR-UDATE
*"     VALUE(USERNAME) TYPE  CDHDR-USERNAME
*"     VALUE(WORKAREA_NEW) TYPE  ZGDMMST004Z
*"     VALUE(WORKAREA_OLD) TYPE  ZGDMMST004Z
*"     VALUE(CHANGE_INDICATOR) TYPE  CDPOS-CHNGIND DEFAULT SPACE
*"  TABLES
*"      TEXTTABLE STRUCTURE  CDTXT
*"----------------------------------------------------------------------

  CALL FUNCTION 'CHANGEDOCUMENT_OPEN'
    EXPORTING
      objectclass      = objectclass
      objectid         = objectid
    EXCEPTIONS
      sequence_invalid = 1
      OTHERS           = 2.

  IF change_indicator IS NOT INITIAL.
    CALL FUNCTION 'CHANGEDOCUMENT_SINGLE_CASE'
      EXPORTING
        tablename              = 'ZGDMMST004Z'
        workarea_old           = workarea_old
        workarea_new           = workarea_new
        change_indicator       = change_indicator
      EXCEPTIONS
        nametab_error          = 1
        open_missing           = 2
        position_insert_failed = 3
        OTHERS                 = 4.
  ENDIF.

*  IF texttable[] IS NOT INITIAL.
*    CALL FUNCTION 'CHANGEDOCUMENT_TEXT_CASE'
*      TABLES
*        texttable              = texttable
*      EXCEPTIONS
*        open_missing           = 1
*        position_insert_failed = 2
*        OTHERS                 = 3.
*  ENDIF.

  CALL FUNCTION 'CHANGEDOCUMENT_CLOSE'
    EXPORTING
      objectclass          = objectclass
      objectid             = objectid
      date_of_change       = udate
      time_of_change       = utime
      tcode                = tcode
      username             = username
    EXCEPTIONS
      header_insert_failed = 1
      object_invalid       = 2
      open_missing         = 3
      no_position_inserted = 4
      OTHERS               = 5.

ENDFUNCTION.
