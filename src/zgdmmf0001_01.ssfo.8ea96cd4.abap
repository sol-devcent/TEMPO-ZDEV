DATA: l_name(70),
      l_lines  LIKE tline OCCURS 0,
      wa_lines LIKE tline.

SELECT SINGLE text1
  FROM t052u
  INTO va_zterm
  WHERE spras EQ sy-langu AND
        zterm EQ wa_hd-zterm.
