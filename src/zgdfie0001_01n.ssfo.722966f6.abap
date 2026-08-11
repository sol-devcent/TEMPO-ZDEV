break bcdik.

DATA: ld_vattrn  LIKE zfvattrn-vattrn,
      ld_vatbr   LIKE zfvattrn-vatbr,
      ld_vatno   LIKE zfvatnr-vatno,
      ld_fakno(17),
      ld_vatcd   LIKE zfvatnr-vatcd.

break bcdik.

SELECT SINGLE fakturno
  FROM zgdtxdt0011
  INTO ld_fakno
  WHERE brnch    EQ header-bukrs  AND
        objrange EQ 'ZGDTXNR001'.

IF sy-subrc EQ 0.
  CONCATENATE ld_fakno(3) '.' ld_fakno+3(3) '-' INTO va_fakno.
  CONCATENATE va_fakno ld_fakno+6(2) '.' ld_fakno+8(8) INTO va_fakno.
ELSE.
  SELECT SINGLE vattrn vatbr
     FROM zfvattrn
       INTO (ld_vattrn, ld_vatbr)
     WHERE vkorg EQ header-bukrs AND
           gform EQ 'A1'.


*  SELECT SINGLE vattrn vatbr
*    FROM zfvattrn
*    INTO (ld_vattrn, ld_vatbr)
*    WHERE vkorg EQ header-bukrs AND
*          gform EQ 'A1'.

  IF sy-subrc EQ 0.
    SELECT SINGLE vatno vatcd
           FROM zfvatnr
           INTO (ld_vatno, ld_vatcd)
         WHERE vkorg EQ header-bukrs AND
               vkbur EQ '000'        AND
               gjahr EQ header-budat(4).

    ld_vatno = ld_vatno + 1.
    CONCATENATE ld_vattrn '0' ld_vatcd header-budat+2(2) ld_vatno
    INTO ld_fakno.

    CONCATENATE ld_fakno(3) '.' ld_fakno+3(3) '-' INTO va_fakno.
    CONCATENATE va_fakno ld_fakno+6(2) '.' ld_fakno+8(8) INTO va_fakno.






*    SELECT SINGLE vatno
*      FROM zfvatnr
*      INTO ld_vatno
*      WHERE vkorg EQ header-bukrs AND
*            vkbur EQ '000'        AND
*            gjahr EQ header-budat(4).
*
*    ld_vatno = ld_vatno + 1.
*    CONCATENATE ld_vattrn '0' ld_vatbr header-budat+2(2) ld_vatno
*    INTO ld_fakno.
*
*    CONCATENATE ld_fakno(3) '.' ld_fakno+3(3) '-' INTO va_fakno.
*    CONCATENATE va_fakno ld_fakno+6(2) '.' ld_fakno+8(8) INTO va_fakno.
  ENDIF.
ENDIF.





















