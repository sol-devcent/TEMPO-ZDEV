DATA : lv_id     TYPE thead-tdid,
       lv_name   TYPE thead-tdname,
       lv_object TYPE thead-tdobject.

DATA : lines    TYPE STANDARD TABLE OF tline.

lv_id = 'F07'.
lv_object = 'EKKO'.
lv_name = wa_hd-ebeln.

CALL FUNCTION 'READ_TEXT'
  EXPORTING
    id                      = lv_id
    language                = sy-langu
    name                    = lv_name
    object                  = lv_object
  TABLES
    lines                   = lines
  EXCEPTIONS
    id                      = 1
    language                = 2
    name                    = 3
    not_found               = 4
    object                  = 5
    reference_check         = 6
    wrong_access_to_archive = 7
    OTHERS                  = 8.
IF lines[] IS INITIAL.
  SELECT SINGLE text1
    FROM zmmt052u
    INTO va_zterm
    WHERE zterm EQ wa_hd-zterm.
  IF sy-subrc <> 0.
    SELECT SINGLE text1
    FROM t052u
    INTO va_zterm
    WHERE spras = 'i'
      AND zterm = wa_hd-zterm.
    IF sy-subrc <> 0.
      SELECT SINGLE text1
        FROM t052u
        INTO va_zterm
        WHERE spras = sy-langu
          AND zterm = wa_hd-zterm.
    ENDIF.
  ENDIF.
ENDIF.

















