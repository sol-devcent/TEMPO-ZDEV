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
























