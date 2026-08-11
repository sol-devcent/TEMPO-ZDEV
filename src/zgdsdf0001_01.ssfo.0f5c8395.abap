DATA: lv_adrnr LIKE tvst-adrnr.

SELECT SINGLE vtext
  FROM tvkot
  INTO va_vtext1
  WHERE spras EQ sy-langu AND
        vkorg EQ wa_hd-vkorg.

SELECT SINGLE vtext
  FROM tvstt
  INTO va_vtext2
  WHERE spras EQ sy-langu AND
        vstel EQ wa_hd-vstel.

IF wa_hd-vkorg = '8360'.
  SELECT SINGLE adrnr INTO lv_adrnr
    FROM tvst WHERE vstel EQ wa_hd-vstel.
  IF sy-subrc = 0.
    SELECT SINGLE city1 INTO va_vtext2
      FROM adrc WHERE addrnumber = lv_adrnr.
  ENDIF.
ENDIF.
























