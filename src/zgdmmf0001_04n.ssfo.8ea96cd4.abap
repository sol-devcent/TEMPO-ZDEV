DATA : lv_id     TYPE thead-tdid,
       lv_name   TYPE thead-tdname,
       lv_object TYPE thead-tdobject.

IF wa_hd-bsart = 'ZIMP'.
  SELECT SINGLE text1
    FROM zmmt052u
    INTO va_zterm
    WHERE zterm EQ wa_hd-zterm.
  IF sy-subrc <> 0.
    SELECT SINGLE text1
      FROM t052u
      INTO va_zterm
      WHERE spras = sy-langu
        AND zterm = wa_hd-zterm.
  ENDIF.
ELSE.
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
