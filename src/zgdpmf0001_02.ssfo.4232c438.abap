SELECT SINGLE eqktx
  FROM eqkt
  INTO va_eqktx
  WHERE equnr EQ caufvd-equnr AND
        spras EQ sy-langu.

SELECT SINGLE pltxt
  FROM iflotx
  INTO va_pltxt
  WHERE tplnr EQ caufvd-tplnr AND
        spras EQ sy-langu.



























