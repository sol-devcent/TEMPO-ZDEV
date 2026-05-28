DATA: ls_stxh TYPE stxh.

va_imported2 = va_imported.
TRANSLATE va_imported2 TO UPPER CASE.

SELECT SINGLE * INTO ls_stxh
  FROM stxh WHERE tdobject = 'EKKO'
              AND tdname   = wa_hd-ebeln
              AND tdid     = 'F02'
              AND tdspras  = sy-langu.
IF sy-subrc = 0.
  va_hdrtxt = 'X'.
ENDIF.





















