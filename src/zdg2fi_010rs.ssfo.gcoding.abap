DATA s_regup LIKE LINE OF t_regup.
DATA s_bkpf LIKE LINE OF t_bkpf.
DATA s_lfa1 LIKE LINE OF t_lfa1.
DATA s_reguh LIKE LINE OF t_reguh.
DATA s_printed LIKE LINE OF t_printed1.
DATA s_t001 LIKE LINE OF t_t001.
DATA s_bsik LIKE LINE OF t_bsik.

DATA ls_printed LIKE LINE OF t_printed1.
"Break 2
break dg2_co01.

LOOP AT t_regup INTO s_regup.
  CLEAR s_printed.

  s_printed-zbukr = s_regup-bukrs.
  s_printed-belnr = s_regup-belnr.
  s_printed-zfbdt = s_regup-zfbdt + s_regup-zbd1t.
  s_printed-pswsl = s_regup-pswsl.
  s_printed-pswbt = s_regup-pswbt.
  s_printed-gjahr = s_regup-gjahr.
  s_printed-shkzg = s_regup-shkzg.

  CLEAR s_bsik.
  READ TABLE t_bsik into s_bsik WITH KEY bukrs = s_regup-zbukr
                              lifnr = s_regup-lifnr
                              belnr = s_regup-belnr
                              buzei = s_regup-buzei.
  s_printed-sgtxt = s_bsik-sgtxt.

  CLEAR s_bkpf.
  READ TABLE t_bkpf INTO s_bkpf WITH KEY belnr = s_regup-belnr.
  s_printed-xblnr = s_bkpf-xblnr.

  CLEAR s_reguh.
  READ TABLE t_reguh INTO s_reguh WITH KEY laufd = s_regup-laufd
                               laufi = s_regup-laufi
                               zbukr = s_regup-zbukr
                               vblnr = s_regup-vblnr.

  IF sy-subrc EQ 0.
    s_printed-laufd = s_reguh-laufd.
    s_printed-laufi = s_reguh-laufi.
    s_printed-lifnr = s_reguh-lifnr.
    s_printed-name1 = s_reguh-name1.
    s_printed-pyord = s_reguh-pyord.

    READ TABLE t_t001 INTO s_t001 WITH KEY bukrs = s_reguh-zbukr.
    s_printed-butxt = s_t001-butxt.
  ENDIF.

  APPEND s_printed TO t_printed1.
ENDLOOP.

READ TABLE t_reguh into s_reguh INDEX 1.
"break 3
break dg2_co01.

CLEAR t_printed[].
IF D_MULTIPLE EQ 'X'.
  READ TABLE t_printed1 INTO s_printed WITH KEY laufd = s_reguh-laufd
                               laufi = s_reguh-laufi
                               zbukr = s_reguh-zbukr.
  t_printed[] = t_printed1[].
ELSE.
  READ TABLE t_printed1 INTO s_printed WITH KEY laufd = s_reguh-laufd
                               laufi = s_reguh-laufi
                               zbukr = s_reguh-zbukr
                               lifnr = s_reguh-lifnr.
  t_printed[] = t_printed1[].
  DELETE t_printed WHERE lifnr ne s_reguh-lifnr.

ENDIF.
