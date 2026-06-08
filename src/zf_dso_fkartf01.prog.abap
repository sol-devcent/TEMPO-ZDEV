*----------------------------------------------------------------------*
***INCLUDE ZF_DSO_FKARTF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  cek
*&---------------------------------------------------------------------*
FORM cek.
  DATA l_gsber LIKE bsid-gsber.

  l_gsber = so_gsber-low.

  IF l_gsber EQ space AND so_gsber-high EQ space.
    l_gsber = '*'.
  ELSEIF l_gsber NE space AND so_gsber-high NE space.
    l_gsber = '*'.
  ENDIF.

  AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
      ID 'GSBER' FIELD l_gsber
      ID 'ACTVT' FIELD '01'.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH
    'You have no authorization for Sales Office' l_gsber.
  ENDIF.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE i_zfchanel
    FROM zfchanel
    WHERE bukrs = pa_bukrs AND
          vkbur IN so_gsber.

  READ TABLE i_zfchanel WITH KEY flag = 'X'.
  IF sy-subrc = 0.
    va_channel = i_zfchanel-flag.
  ENDIF.

ENDFORM.                    " cek

*&---------------------------------------------------------------------*
*&      Form  F_INIT_COLUMN
*&---------------------------------------------------------------------*
FORM f_init_column .
  w1   =   5.
  w2   =  50.
  w3   =  20.
  w4   =  35.
  w5   =  86.
  w6   =  30.
  w7   =  15.
  c1 = 0.
ENDFORM.                    " F_INIT_COLUMN

*&---------------------------------------------------------------------*
*&      Form  f_mapping_soff
*&---------------------------------------------------------------------*
FORM f_mapping_soff .
  IF so_kunnr IS NOT INITIAL.
    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_dele
      WHERE kunnr    IN so_kunnr AND
            zvkbur1  IN so_gsber AND
            budat    GE pa_date.

    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_add
      WHERE kunnr  IN so_kunnr AND
            budat  GE pa_date.
  ELSE.
    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_dele
      WHERE zvkbur1  IN so_gsber AND
            budat    GE pa_date.

    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_add
      WHERE budat  GE pa_date.
  ENDIF.

  SELECT *
    FROM tvfkt
    INTO CORRESPONDING FIELDS OF TABLE gt_tvfkt
    WHERE spras = sy-langu
      AND fkart IN so_fkart.

ENDFORM.                    " f_mapping_soff

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
FORM f_get_data.
  DATA: month LIKE bsid-monat, year LIKE bsid-gjahr.

  CLEAR: wa_itab, i_itab, i_itab1, i_itab2.
  IF pa_date IS INITIAL.
    ra_budat-high = sy-datum.
  ELSE.
    ra_budat-high = pa_date.
  ENDIF.
  IF ra_budat-high+4(2) < pa_dso.
    month = ra_budat-high+4(2) + 12 - pa_dso + 1.
    year = ra_budat-high(4) - 1.
  ELSE.
    month = ra_budat-high+4(2) - pa_dso + 1.
    year =  ra_budat-high(4).
  ENDIF.
  IF month > ra_budat-high+4(2).
  ELSE.
  ENDIF.
  CONCATENATE year month '01' INTO ra_budat-low.
  ra_budat-sign = 'I'.
  ra_budat-option = 'BT'.
  APPEND ra_budat.

  jml_hari = ra_budat-high - ra_budat-low + 1.

  IF x_norm EQ 'X' AND x_shbv EQ 'X'.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
           a~xref1 a~xref2 a~blart a~anln1
           b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid
           FROM bsid AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                          JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                            c~vkorg EQ a~bukrs AND
                                            c~vtweg EQ '10' AND
                                            c~spart EQ '00'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~umsks EQ space AND
                 a~gjahr <= pa_date(4) AND
                 a~budat <= pa_date AND
                 a~kunnr IN so_kunnr AND
                 a~umskz EQ space    AND
                 c~vkorg EQ pa_bukrs AND
                 c~vkbur IN so_gsber AND
                 c~vtweg EQ '10' AND
                 c~spart EQ '00'.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
           a~xref1 a~xref2 a~blart a~anln1
           b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                      JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                            c~vkorg EQ a~bukrs AND
                                            c~vtweg EQ '10' AND
                                            c~spart EQ '00'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~umsks EQ space AND
                 a~gjahr <= pa_date(4) AND
                 a~augdt > pa_date AND
                 a~budat <= pa_date AND
                 a~kunnr IN so_kunnr AND
                 a~umskz EQ space    AND
                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~vkorg EQ pa_bukrs AND
                 c~vtweg EQ '10' AND
                 c~vkbur IN so_gsber AND
                 c~spart EQ '00'.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
           a~xref1 a~xref2 a~blart a~anln1
           b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3
           APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsid
           FROM bsid AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                          JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                            c~vkorg EQ a~bukrs AND
                                            c~vtweg EQ '10' AND
                                            c~spart EQ '00'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
*                   a~umsks eq space and
                 a~gjahr <= pa_date(4) AND
                 a~budat <= pa_date AND
                 a~kunnr IN so_kunnr AND
                 a~umskz IN so_umskz AND
                 c~vkorg EQ pa_bukrs AND
                 c~vkbur IN so_gsber AND
                 c~vtweg EQ '10' AND
                 c~spart EQ '00'.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
           a~xref1 a~xref2 a~blart a~anln1
           b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3
           APPENDING CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                      JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                            c~vkorg EQ a~bukrs AND
                                            c~vtweg EQ '10' AND
                                            c~spart EQ '00'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
*                   a~umsks eq space and
                 a~gjahr <= pa_date(4) AND
                 a~augdt > pa_date AND
                 a~budat <= pa_date AND
                 a~kunnr IN so_kunnr AND
                 a~umskz IN so_umskz AND
                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~vkorg EQ pa_bukrs AND
                 c~vtweg EQ '10' AND
                 c~vkbur IN so_gsber AND
                 c~spart EQ '00'.
  ENDIF.

  IF x_norm EQ 'X' AND x_shbv EQ space.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
           a~xref1 a~xref2 a~blart a~anln1
           b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid
           FROM bsid AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                          JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                            c~vkorg EQ a~bukrs AND
                                            c~vtweg EQ '10' AND
                                            c~spart EQ '00'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~umsks EQ space AND
                 a~gjahr <= pa_date(4) AND
                 a~budat <= pa_date AND
                 a~kunnr IN so_kunnr AND
                 a~umskz EQ space    AND
                 c~vkorg EQ pa_bukrs AND
                 c~vkbur IN so_gsber AND
                 c~vtweg EQ '10' AND
                 c~spart EQ '00'.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
           a~xref1 a~xref2 a~blart a~anln1
           b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                      JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                            c~vkorg EQ a~bukrs AND
                                            c~vtweg EQ '10' AND
                                            c~spart EQ '00'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~umsks EQ space AND
                 a~gjahr <= pa_date(4) AND
                 a~augdt > pa_date AND
                 a~budat <= pa_date AND
                 a~kunnr IN so_kunnr AND
                 a~umskz EQ space    AND
                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~vkorg EQ pa_bukrs AND
                 c~vtweg EQ '10' AND
                 c~vkbur IN so_gsber AND
                 c~spart EQ '00'.
  ENDIF.

  IF x_norm EQ space AND x_shbv EQ 'X'.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
           a~xref1 a~xref2 a~blart a~anln1
           b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsid
           FROM bsid AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                          JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                            c~vkorg EQ a~bukrs AND
                                            c~vtweg EQ '10' AND
                                            c~spart EQ '00'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
*                   a~umsks eq space and
                 a~gjahr <= pa_date(4) AND
                 a~budat <= pa_date AND
                 a~kunnr IN so_kunnr AND
                 a~umskz IN so_umskz AND
                 c~vkorg EQ pa_bukrs AND
                 c~vkbur IN so_gsber AND
                 c~vtweg EQ '10' AND
                 c~spart EQ '00'.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
           a~xref1 a~xref2 a~blart a~anln1
           b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3
           INTO CORRESPONDING FIELDS OF TABLE i_itab_bsad
           FROM bsad AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                      JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                            c~vkorg EQ a~bukrs AND
                                            c~vtweg EQ '10' AND
                                            c~spart EQ '00'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
*                   a~umsks eq space and
                 a~gjahr <= pa_date(4) AND
                 a~augdt > pa_date AND
                 a~budat <= pa_date AND
                 a~kunnr IN so_kunnr AND
                 a~umskz IN so_umskz AND
                 a~blart IN ('RV','ZA','DR','DA','DZ') AND
                 c~vkorg EQ pa_bukrs AND
                 c~vtweg EQ '10' AND
                 c~vkbur IN so_gsber AND
                 c~spart EQ '00'.
  ENDIF.

* sales office mapping process
  PERFORM f_hapus_kunnr_itab3.
  PERFORM f_tambah_kunnr_itab3.

  APPEND LINES OF i_itab_bsid TO i_itab3.
  APPEND LINES OF i_itab_bsad TO i_itab3.

  CLEAR: i_itab_bsid, i_itab_bsad.
  REFRESH: i_itab_bsid, i_itab_bsad.
  DELETE i_itab3 WHERE NOT ( kdgrp IN so_kdgrp ).
  DELETE i_itab3 WHERE NOT ( kvgr3 IN so_kvgr3 ).

  CLEAR: va_dmbtr.
  IF pa_bukrs EQ '8020'.
    IF NOT ( '0200' IN so_gsber ).
      DELETE i_itab3 WHERE NOT ( vkbur IN so_gsber ).
    ENDIF.
  ENDIF.

  SORT i_itab3 BY bukrs vkbur kdgrp brsch kunnr xref2.
  CLEAR: wa_itab.
  LOOP AT i_itab3 INTO wa_itab.
    IF wa_itab-vkbur NE space.
      wa_itab-gsber = wa_itab-vkbur.
    ENDIF.
    IF wa_itab-blart NE 'RV'.
      wa_itab-xref2 = wa_itab-xref2.
    ENDIF.

    CLEAR i_zfchanel.
    IF va_channel IS INITIAL.
      READ TABLE i_zfchanel WITH KEY bukrs = wa_itab-bukrs
                                     vkbur = wa_itab-vkbur
                                     kdgrp = wa_itab-kdgrp.
      wa_itab-channel = i_zfchanel-channel.
    ELSE.
      READ TABLE i_zfchanel WITH KEY bukrs = wa_itab-bukrs
                                     vkbur = wa_itab-vkbur
                                     brsch = wa_itab-brsch.
      wa_itab-channel = i_zfchanel-channel.
    ENDIF.

    MODIFY i_itab3 FROM wa_itab.
  ENDLOOP.

  DELETE i_itab3 WHERE NOT ( gsber IN so_gsber ).
  IF pa_bukrs EQ '8020'.
    DELETE i_itab3 WHERE gsber EQ '0200'.
  ENDIF.

  PERFORM f_reclas TABLES i_itab3.

  IF x_norm EQ 'X' AND x_shbv EQ 'X'.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
           a~xref1 a~xref2 a~blart a~anln1
           b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
           INTO CORRESPONDING FIELDS OF TABLE i_itab1
           FROM bsid AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                          JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                            c~vkorg EQ a~bukrs AND
                                            c~vtweg EQ '10' AND
                                            c~spart EQ '00'
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~umsks EQ space AND
                 a~gjahr <= pa_date(4) AND
                 a~budat IN ra_budat AND
                 a~kunnr IN so_kunnr AND
                 a~umskz EQ space    AND
** Koreksi by budi 08/09/2005 req. by SJT
*                   a~blart in ('RV','ZA','DR','DA') and
                 a~blart IN ('RV','ZA','DR') AND
** End Koreksi by budi 08/09/2005 req. by SJT
                 c~vkorg EQ pa_bukrs AND
                 c~vkbur IN so_gsber AND
                 c~vtweg EQ '10' AND
                 c~spart EQ '00'.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
           a~xref1 a~xref2 a~blart a~anln1
           b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
           INTO CORRESPONDING FIELDS OF TABLE i_itab2
           FROM bsad AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                          JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                            c~vkorg EQ a~bukrs AND
                                            c~vtweg EQ '10' AND
                                            c~spart EQ '00'
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~umsks EQ space AND
                 a~gjahr <= pa_date(4) AND
                 a~budat IN ra_budat AND
                 a~kunnr IN so_kunnr AND
                 a~umskz EQ space    AND
** Koreksi by budi 08/09/2005 req. by SJT
*                   a~blart in ('RV','ZA','DR','DA') and
                 a~blart IN ('RV','ZA','DR') AND
** End Koreksi by budi 08/09/2005 req. by SJT
                 c~vkorg EQ pa_bukrs AND
                 c~vtweg EQ '10' AND
                 c~vkbur IN so_gsber AND
                 c~spart EQ '00'.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
           a~xref1 a~xref2 a~blart a~anln1
           b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
           APPENDING CORRESPONDING FIELDS OF TABLE i_itab1
           FROM bsid AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                          JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                            c~vkorg EQ a~bukrs AND
                                            c~vtweg EQ '10' AND
                                            c~spart EQ '00'
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
*                   a~umsks eq space and
                 a~gjahr <= pa_date(4) AND
                 a~budat IN ra_budat AND
                 a~kunnr IN so_kunnr AND
                 a~umskz IN so_umskz AND
** Koreksi by budi 08/09/2005 req. by SJT
*                   a~blart in ('RV','ZA','DR','DA') and
                 a~blart IN ('RV','ZA','DR') AND
** End Koreksi by budi 08/09/2005 req. by SJT
                 c~vkorg EQ pa_bukrs AND
                 c~vkbur IN so_gsber AND
                 c~vtweg EQ '10' AND
                 c~spart EQ '00'.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
           a~xref1 a~xref2 a~blart a~anln1
           b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
           APPENDING CORRESPONDING FIELDS OF TABLE i_itab2
           FROM bsad AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                          JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                            c~vkorg EQ a~bukrs AND
                                            c~vtweg EQ '10' AND
                                            c~spart EQ '00'
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
*                   a~umsks eq space and
                 a~gjahr <= pa_date(4) AND
                 a~budat IN ra_budat AND
                 a~kunnr IN so_kunnr AND
                 a~umskz IN so_umskz AND
** Koreksi by budi 08/09/2005 req. by SJT
*                   a~blart in ('RV','ZA','DR','DA') and
                 a~blart IN ('RV','ZA','DR') AND
** End Koreksi by budi 08/09/2005 req. by SJT
                 c~vkorg EQ pa_bukrs AND
                 c~vtweg EQ '10' AND
                 c~vkbur IN so_gsber AND
                 c~spart EQ '00'.
  ENDIF.

  IF x_norm EQ 'X' AND x_shbv EQ space.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
           a~xref1 a~xref2 a~blart a~anln1
           b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
           INTO CORRESPONDING FIELDS OF TABLE i_itab1
           FROM bsid AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                          JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                            c~vkorg EQ a~bukrs AND
                                            c~vtweg EQ '10' AND
                                            c~spart EQ '00'
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~umsks EQ space AND
                 a~gjahr <= pa_date(4) AND
                 a~budat IN ra_budat AND
                 a~kunnr IN so_kunnr AND
                 a~umskz EQ space    AND
** Koreksi by budi 08/09/2005 req. by SJT
*                   a~blart in ('RV','ZA','DR','DA') and
                 a~blart IN ('RV','ZA','DR') AND
** End Koreksi by budi 08/09/2005 req. by SJT
                 c~vkorg EQ pa_bukrs AND
                 c~vkbur IN so_gsber AND
                 c~vtweg EQ '10' AND
                 c~spart EQ '00'.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
           a~xref1 a~xref2 a~blart a~anln1
           b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
           INTO CORRESPONDING FIELDS OF TABLE i_itab2
           FROM bsad AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                          JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                            c~vkorg EQ a~bukrs AND
                                            c~vtweg EQ '10' AND
                                            c~spart EQ '00'
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
                 a~umsks EQ space AND
                 a~gjahr <= pa_date(4) AND
                 a~budat IN ra_budat AND
                 a~kunnr IN so_kunnr AND
                 a~umskz EQ space    AND
** Koreksi by budi 08/09/2005 req. by SJT
*                   a~blart in ('RV','ZA','DR','DA') and
                 a~blart IN ('RV','ZA','DR') AND
** End Koreksi by budi 08/09/2005 req. by SJT
                 c~vkorg EQ pa_bukrs AND
                 c~vtweg EQ '10' AND
                 c~vkbur IN so_gsber AND
                 c~spart EQ '00'.
  ENDIF.

  IF x_norm EQ space AND x_shbv EQ 'X'.
    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
           a~xref1 a~xref2 a~blart a~anln1
           b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
           INTO CORRESPONDING FIELDS OF TABLE i_itab1
           FROM bsid AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                          JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                            c~vkorg EQ a~bukrs AND
                                            c~vtweg EQ '10' AND
                                            c~spart EQ '00'
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
*                   a~umsks eq space and
                 a~gjahr <= pa_date(4) AND
                 a~budat IN ra_budat AND
                 a~kunnr IN so_kunnr AND
                 a~umskz IN so_umskz AND
** Koreksi by budi 08/09/2005 req. by SJT
*                   a~blart in ('RV','ZA','DR','DA') and
                 a~blart IN ('RV','ZA','DR') AND
** End Koreksi by budi 08/09/2005 req. by SJT
                 c~vkorg EQ pa_bukrs AND
                 c~vkbur IN so_gsber AND
                 c~vtweg EQ '10' AND
                 c~spart EQ '00'.

    SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
           a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
           a~xref1 a~xref2 a~blart a~anln1
           b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
           INTO CORRESPONDING FIELDS OF TABLE i_itab2
           FROM bsad AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                          JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                            c~vkorg EQ a~bukrs AND
                                            c~vtweg EQ '10' AND
                                            c~spart EQ '00'
                     LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                             d~parvw EQ 'ZP'
           WHERE a~bukrs EQ pa_bukrs AND
                 a~hkont IN ( SELECT saknr FROM skat
                     WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                           ktopl EQ 'TSPC' ) AND
*                   a~umsks eq space and
                 a~gjahr <= pa_date(4) AND
                 a~budat IN ra_budat AND
                 a~kunnr IN so_kunnr AND
                 a~umskz IN so_umskz AND
** Koreksi by budi 08/09/2005 req. by SJT
*                   a~blart in ('RV','ZA','DR','DA') and
                 a~blart IN ('RV','ZA','DR') AND
** End Koreksi by budi 08/09/2005 req. by SJT
                 c~vkorg EQ pa_bukrs AND
                 c~vtweg EQ '10' AND
                 c~vkbur IN so_gsber AND
                 c~spart EQ '00'.
  ENDIF.

* sales office mapping process
  PERFORM f_hapus_kunnr_itab.
  PERFORM f_tambah_kunnr_itab.

  APPEND LINES OF i_itab1 TO i_itab.
  APPEND LINES OF i_itab2 TO i_itab.

  CLEAR: i_itab1, i_itab2.
  REFRESH: i_itab1, i_itab2.

  DELETE ADJACENT DUPLICATES FROM i_itab
       COMPARING bukrs gjahr budat belnr kunnr dmbtr shkzg.

  DELETE i_itab WHERE NOT ( kdgrp IN so_kdgrp ).
  DELETE i_itab WHERE NOT ( kvgr3 IN so_kvgr3 ).
  IF pa_bukrs EQ '8020'.
    IF NOT ( '0200' IN so_gsber ).
      DELETE i_itab WHERE NOT ( vkbur IN so_gsber ).
    ENDIF.
  ENDIF.
  CLEAR: va_dmbtr.
  SORT i_itab BY bukrs vkbur kdgrp brsch kunnr xref2.
  CLEAR: wa_itab.

  LOOP AT i_itab INTO wa_itab.
    IF wa_itab-vkbur NE space.
      wa_itab-gsber = wa_itab-vkbur.
    ENDIF.
    IF wa_itab-blart NE 'RV'.
      wa_itab-xref2 = wa_itab-xref2.
    ENDIF.
    IF wa_itab-kdgrp EQ space.
      wa_itab-kdgrp = 'OT'.
    ENDIF.
    CLEAR i_zfchanel.
    IF va_channel IS INITIAL.
      READ TABLE i_zfchanel WITH KEY bukrs = wa_itab-bukrs
                                     vkbur = wa_itab-vkbur
                                     kdgrp = wa_itab-kdgrp.
      wa_itab-channel = i_zfchanel-channel.
    ELSE.
      READ TABLE i_zfchanel WITH KEY bukrs = wa_itab-bukrs
                                     vkbur = wa_itab-vkbur
                                     brsch = wa_itab-brsch.
      wa_itab-channel = i_zfchanel-channel.
    ENDIF.
    MODIFY i_itab FROM wa_itab.
  ENDLOOP.
  DELETE i_itab WHERE NOT ( gsber IN so_gsber ).
  IF pa_bukrs EQ '8020'.
    DELETE i_itab WHERE gsber EQ '0200'.
  ENDIF.

  PERFORM f_reclas TABLES i_itab.
ENDFORM.                    " f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_proses1
*&---------------------------------------------------------------------*
FORM f_proses1.
  DATA : lt_result    TYPE ty_result OCCURS 0,
         ls_result    TYPE ty_result,
         i_result11   TYPE ty_result OCCURS 0,
         i_result12   TYPE ty_result OCCURS 0,
         tmp_result12 TYPE ty_result OCCURS 0,
         tmp_result11 TYPE ty_result OCCURS 0,
         ls_11        TYPE ty_result,
         ls_12        TYPE ty_result.

  DATA : BEGIN OF lt_tvbur OCCURS 0,
           vkbur LIKE tvbur-vkbur.
  DATA : END OF lt_tvbur.

  DATA : ltext(50).
  DATA : lv_vtext(30).
  DATA : lv_flag(1).

  SORT i_zfchanel BY vkbur.
  IF so_gsber[] IS INITIAL AND
    so_kdgrp[] IS INITIAL AND
    so_kvgr3[] IS INITIAL AND
    so_brsch[] IS INITIAL AND
    so_kunnr[] IS INITIAL.
    LOOP AT i_zfchanel.
      lt_tvbur-vkbur  = i_zfchanel-vkbur.
      COLLECT lt_tvbur.
    ENDLOOP.
  ENDIF.

  CLEAR : i_result11[], i_result11, i_result12[], i_result12.

* gsber -> vkbur
  IF i_result11[] IS INITIAL.
    SORT i_itab BY bukrs vkbur fkart.
    CLEAR: wa_itab, wa_result, i_result11.
    LOOP AT i_itab INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-vkbur OR
                   wa_itab-fkart.
        IF wa_result-vkbur NE space.
          wa_result-avrsales = wa_result-avrsales / jml_hari.
          APPEND wa_result TO i_result11.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-fkart TO wa_result-fkart.
      MOVE wa_itab-kdgrp TO wa_result-kdgrp.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.

    IF wa_result-vkbur NE space.
      wa_result-avrsales = wa_result-avrsales / jml_hari.
      APPEND wa_result TO i_result11.
      CLEAR wa_result.
    ENDIF.

    SORT i_itab3 BY bukrs vkbur fkart.
    CLEAR: wa_itab, wa_result, i_result12.
    LOOP AT i_itab3 INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-vkbur OR
                   wa_itab-fkart.
        IF wa_result-vkbur NE space.
          wa_result-avrsales = wa_result-avrsales / jml_hari.
          APPEND wa_result TO i_result12.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-fkart TO wa_result-fkart.
      MOVE wa_itab-kdgrp TO wa_result-kdgrp.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.

    IF wa_result-vkbur NE space.
      wa_result-avrsales = wa_result-avrsales / jml_hari.
      APPEND wa_result TO i_result12.
      CLEAR wa_result.
    ENDIF.
  ENDIF.

  v_title2 = 'Day Sales Outstanding Per Branch'.
  PERFORM f_write_header.
  PERFORM f_write_header_column USING 'Billing Type'.
  CLEAR: va_nou, wa_total, wa_subtotal.
  v_current_page = 1.

  CLEAR: va_lines, va_lines1, tmp_result11, tmp_result12.
  REFRESH: tmp_result11, tmp_result12.
  DESCRIBE TABLE i_result11 LINES va_lines.
  DESCRIBE TABLE i_result12 LINES va_lines1.

  IF va_lines < va_lines1.
    APPEND LINES OF i_result11 TO tmp_result11.
    APPEND LINES OF i_result12 TO tmp_result12.
    REFRESH : i_result11, i_result12.
    APPEND LINES OF tmp_result11 TO i_result12.
    APPEND LINES OF tmp_result12 TO i_result11.
    REFRESH : tmp_result11, tmp_result12.
    lv_flag = 'X'.
  ENDIF.

  tmp_result11[] = i_result11[].
  tmp_result12[] = i_result12[].
  SORT tmp_result11 BY vkbur fkart.
  DELETE ADJACENT DUPLICATES FROM tmp_result11 COMPARING vkbur fkart.
  SORT tmp_result12 BY vkbur fkart.
  DELETE ADJACENT DUPLICATES FROM tmp_result12 COMPARING vkbur fkart.
  LOOP AT tmp_result12 INTO ls_12.
    READ TABLE tmp_result11 INTO ls_11
                            WITH KEY vkbur = ls_12-vkbur
                                     fkart = ls_12-fkart
                            TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      ls_11 = ls_12.
      CLEAR : ls_11-avrsales, ls_11-outstanding.
      APPEND ls_11 TO i_result11.
      CLEAR ls_11.
    ENDIF.
  ENDLOOP.

  SORT i_result11 BY vkbur fkart.
  SORT i_result12 BY vkbur fkart.

  SORT lt_tvbur BY vkbur.
  IF lt_tvbur[] IS NOT INITIAL.
    LOOP AT lt_tvbur.
      READ TABLE i_result11 INTO wa_result WITH KEY vkbur = lt_tvbur-vkbur
      BINARY SEARCH.
      IF sy-subrc NE 0.
        CLEAR: wa_result.
        wa_result-vkbur = lt_tvbur-vkbur.
        APPEND wa_result TO i_result11.
      ENDIF.
    ENDLOOP.
  ENDIF.

  lt_result[] = i_result11[].
  SORT lt_result BY vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_result COMPARING vkbur.

  CLEAR: wa_result, wa_result1.
  SORT i_result11 BY vkbur fkart.
  SORT i_result12 BY vkbur fkart.

  LOOP AT lt_result INTO ls_result.
    SELECT SINGLE *
      FROM tvkbt
      WHERE vkbur EQ ls_result-vkbur
        AND spras EQ sy-langu.

    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    CONCATENATE ls_result-vkbur tvkbt-bezei
            INTO va_text SEPARATED BY ' - '.
    WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    PERFORM f_write_kosong.

    LOOP AT i_result11 INTO wa_result WHERE vkbur = ls_result-vkbur.
      CLEAR lv_vtext.
      READ TABLE gt_tvfkt WITH KEY fkart = wa_result-fkart.
      IF sy-subrc = 0.
        CONCATENATE wa_result-fkart gt_tvfkt-vtext
                INTO lv_vtext SEPARATED BY ' - '.
      ENDIF.

      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) lv_vtext NO-GAP. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      IF va_lines >= va_lines1 AND lv_flag EQ space.
        PERFORM f_write_detail.
        CLEAR wa_result1.
        LOOP AT i_result12 INTO wa_result1
             WHERE vkbur EQ wa_result-vkbur
               AND bukrs EQ wa_result-bukrs
               AND fkart EQ wa_result-fkart.
        ENDLOOP.
        PERFORM f_write_detail1.
      ELSE.
        CLEAR wa_result1.
        LOOP AT i_result12 INTO wa_result1
             WHERE vkbur EQ wa_result-vkbur
               AND bukrs EQ wa_result-bukrs
               AND fkart EQ wa_result-fkart.
        ENDLOOP.
        wa_result1-outstanding = wa_result-outstanding.
        wa_result-avrsales = wa_result1-avrsales.
        PERFORM f_write_detail.
        PERFORM f_write_detail1.
      ENDIF.
    ENDLOOP.
    CONCATENATE 'Sub Total' va_text INTO ltext SEPARATED BY space.
    PERFORM f_write_subtotal USING ltext 'Billing Type' 'X' 'X' wa_subtotal.
    CLEAR: wa_subtotal, va_nou.
  ENDLOOP.

  PERFORM f_write_total USING 'Billing Type'.
ENDFORM.                                                    " f_proses1

*&---------------------------------------------------------------------*
*&      Form  f_proses2
*&---------------------------------------------------------------------*
FORM f_proses2.
  DATA : i_result21   TYPE ty_result OCCURS 0,
         i_result22   TYPE ty_result OCCURS 0,
         tmp_result22 TYPE ty_result OCCURS 0,
         tmp_result21 TYPE ty_result OCCURS 0,
         lt_break1    TYPE ty_result OCCURS 0,
         ls_break1    TYPE ty_result,
         lt_break2    TYPE ty_result OCCURS 0,
         ls_break2    TYPE ty_result,
         ls_21        TYPE ty_result,
         ls_22        TYPE ty_result.

  DATA : ltext(50).
  DATA : lv_vtext(30).
  DATA : lv_flag(1).

  CLEAR : i_result21[], i_result21, i_result22[], i_result22.

  IF i_result21[] IS INITIAL.
    SORT i_itab BY bukrs vkbur kdgrp fkart.
    CLEAR : wa_itab, wa_result, i_result21.
    LOOP AT i_itab INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-vkbur OR
                   wa_itab-fkart OR
                   wa_itab-kdgrp.
        IF wa_result-kdgrp NE space.
          wa_result-avrsales = wa_result-avrsales / jml_hari.
          APPEND wa_result TO i_result21.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-fkart TO wa_result-fkart.
      MOVE wa_itab-kdgrp TO wa_result-kdgrp.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.

    IF wa_result-kdgrp NE space.
      wa_result-avrsales = wa_result-avrsales / jml_hari.
      APPEND wa_result TO i_result21.
      CLEAR wa_result.
    ENDIF.

    SORT i_itab3 BY bukrs vkbur kdgrp fkart.
    CLEAR: wa_itab, wa_result, i_result22.
    LOOP AT i_itab3 INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-vkbur OR
                   wa_itab-fkart OR
                   wa_itab-kdgrp.
        IF wa_result-kdgrp NE space.
          wa_result-avrsales = wa_result-avrsales / jml_hari.
          APPEND wa_result TO i_result22.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-fkart TO wa_result-fkart.
      MOVE wa_itab-kdgrp TO wa_result-kdgrp.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.

    IF wa_result-kdgrp NE space.
      wa_result-avrsales = wa_result-avrsales / jml_hari.
      APPEND wa_result TO i_result22.
      CLEAR wa_result.
    ENDIF.
  ENDIF.

  v_title2 = 'Day Sales Outstanding Per Customer Group'.
  PERFORM f_write_header.
  PERFORM f_write_header_column USING 'Customer Group'.
  CLEAR: va_nou, wa_total, wa_subtotal, wa_subtotal1.
  v_current_page = 1.

  CLEAR: va_lines, va_lines1, tmp_result21, tmp_result22.
  REFRESH: tmp_result21, tmp_result22.
  DESCRIBE TABLE i_result21 LINES va_lines.
  DESCRIBE TABLE i_result22 LINES va_lines1.

  IF va_lines < va_lines1.
    APPEND LINES OF i_result21 TO tmp_result21.
    APPEND LINES OF i_result22 TO tmp_result22.
    REFRESH : i_result21, i_result22.
    APPEND LINES OF tmp_result21 TO i_result22.
    APPEND LINES OF tmp_result22 TO i_result21.
    REFRESH : tmp_result21, tmp_result22.
    lv_flag = 'X'.
  ENDIF.

  tmp_result21[] = i_result21[].
  tmp_result22[] = i_result22[].
  SORT tmp_result21 BY vkbur kdgrp fkart.
  DELETE ADJACENT DUPLICATES FROM tmp_result21 COMPARING vkbur kdgrp fkart.
  SORT tmp_result22 BY vkbur kdgrp fkart.
  DELETE ADJACENT DUPLICATES FROM tmp_result22 COMPARING vkbur kdgrp fkart.
  LOOP AT tmp_result22 INTO ls_22.
    READ TABLE tmp_result21 INTO ls_21
                            WITH KEY vkbur = ls_22-vkbur
                                     kdgrp = ls_22-kdgrp
                                     fkart = ls_22-fkart
                            TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      ls_21 = ls_22.
      CLEAR : ls_21-avrsales, ls_21-outstanding.
      APPEND ls_21 TO i_result21.
      CLEAR ls_21.
    ENDIF.
  ENDLOOP.

  SORT i_result21 BY vkbur kunnr fkart kdgrp.
  SORT i_result22 BY vkbur kunnr fkart kdgrp.

  lt_break2[] = i_result21[].
  SORT lt_break2 BY vkbur kdgrp.
  DELETE ADJACENT DUPLICATES FROM lt_break2 COMPARING vkbur kdgrp.

  lt_break1[] = i_result21[].
  SORT lt_break1 BY vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_break1 COMPARING vkbur.

  CLEAR: wa_result, wa_result1.
  LOOP AT lt_break1 INTO ls_break1.
    SELECT SINGLE *
      FROM tvkbt
      WHERE vkbur EQ ls_break1-vkbur
        AND spras EQ sy-langu.
    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    CONCATENATE ls_break1-vkbur tvkbt-bezei
            INTO va_text SEPARATED BY ' - '.
    WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + w6.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    PERFORM f_write_kosong.

    LOOP AT lt_break2 INTO ls_break2 WHERE vkbur = ls_break1-vkbur.
      CLEAR va_nou.
      LOOP AT i_result21 INTO wa_result WHERE vkbur = ls_break1-vkbur
                                          AND kdgrp = ls_break2-kdgrp.
        ADD 1 TO va_nou.
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        SELECT SINGLE *
          FROM t151t
          WHERE kdgrp EQ wa_result-kdgrp
            AND spras EQ sy-langu.
        IF sy-subrc NE 0.
          t151t-ktext = 'Others'.
        ENDIF.
        CONCATENATE wa_result-kdgrp t151t-ktext
            INTO ltext SEPARATED BY '-'.

        CLEAR lv_vtext.
        READ TABLE gt_tvfkt WITH KEY fkart = wa_result-fkart.
        IF sy-subrc = 0.
          CONCATENATE wa_result-fkart gt_tvfkt-vtext
                  INTO lv_vtext SEPARATED BY ' - '.
        ENDIF.

        WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w2) ltext NO-GAP. c1 = c1 + w2.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w4) lv_vtext NO-GAP. c1 = c1 + w4.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

        IF va_lines >= va_lines1 AND lv_flag EQ space.
          PERFORM f_write_detail.
          CLEAR wa_result1.
          LOOP AT i_result22 INTO wa_result1
               WHERE vkbur EQ wa_result-vkbur
                 AND bukrs EQ wa_result-bukrs
                 AND fkart EQ wa_result-fkart
                 AND kdgrp EQ wa_result-kdgrp.
          ENDLOOP.
          PERFORM f_write_detail1.
        ELSE.
          CLEAR wa_result1.
          LOOP AT i_result22 INTO wa_result1
               WHERE vkbur EQ wa_result-vkbur
                 AND bukrs EQ wa_result-bukrs
                 AND fkart EQ wa_result-fkart
                 AND kdgrp EQ wa_result-kdgrp.
          ENDLOOP.
          wa_result1-outstanding = wa_result-outstanding.
          wa_result-avrsales = wa_result1-avrsales.
          PERFORM f_write_detail.
          PERFORM f_write_detail1.
        ENDIF.
        CLEAR wa_result.
      ENDLOOP.
      PERFORM f_write_subtotal USING '      Sub Total' '' 'X' 'X' wa_subtotal1.
      CLEAR : wa_subtotal1.
    ENDLOOP.
    CONCATENATE 'Sub Total' va_text INTO ltext SEPARATED BY space.
    PERFORM f_write_subtotal USING ltext '' 'X' 'X' wa_subtotal.
    CLEAR: wa_subtotal, va_nou.
  ENDLOOP.

  PERFORM f_write_total USING ''.
ENDFORM.                                                    " f_proses2

*&---------------------------------------------------------------------*
*&      Form  f_proses3
*&---------------------------------------------------------------------*
FORM f_proses3.
  DATA : i_result31   TYPE ty_result OCCURS 0,
         i_result32   TYPE ty_result OCCURS 0,
         tmp_result32 TYPE ty_result OCCURS 0,
         tmp_result31 TYPE ty_result OCCURS 0,
         lt_break1    TYPE ty_result OCCURS 0,
         ls_break1    TYPE ty_result,
         lt_break2    TYPE ty_result OCCURS 0,
         ls_break2    TYPE ty_result,
         ls_31        TYPE ty_result,
         ls_32        TYPE ty_result.

  DATA : ltext TYPE text50.
  DATA : lv_vtext(30).
  DATA : lv_flag(1).

  CLEAR : i_result31[], i_result31, i_result32[], i_result32.

  IF i_result31[] IS INITIAL.
    SORT i_itab BY bukrs vkbur xref2 fkart.
    CLEAR: wa_itab, wa_result, i_result31.
    LOOP AT i_itab INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-vkbur OR
                   wa_itab-fkart OR
                   wa_itab-xref2.
        IF wa_result IS NOT INITIAL.
          wa_result-avrsales = wa_result-avrsales / jml_hari.
          APPEND wa_result TO i_result31.
        ENDIF.
        CLEAR wa_result.
      ENDON.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-fkart TO wa_result-fkart.
      MOVE wa_itab-kdgrp TO wa_result-kdgrp.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      MOVE wa_itab-xref1 TO wa_result-xref1.
      MOVE wa_itab-xref2 TO wa_result-xref2.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.

    wa_result-avrsales = wa_result-avrsales / jml_hari.
    APPEND wa_result TO i_result31.
    CLEAR wa_result.

    SORT i_itab3 BY bukrs vkbur xref2 fkart.
    CLEAR: wa_itab, wa_result, i_result32.
    LOOP AT i_itab3 INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-vkbur OR
                   wa_itab-fkart OR
                   wa_itab-xref2.
        IF wa_result IS NOT INITIAL.
          wa_result-avrsales = wa_result-avrsales / jml_hari.
          APPEND wa_result TO i_result32.
        ENDIF.
        CLEAR wa_result.
      ENDON.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-fkart TO wa_result-fkart.
      MOVE wa_itab-kdgrp TO wa_result-kdgrp.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      MOVE wa_itab-xref1 TO wa_result-xref1.
      MOVE wa_itab-xref2 TO wa_result-xref2.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.
    wa_result-avrsales = wa_result-avrsales / jml_hari.
    APPEND wa_result TO i_result32.
    CLEAR wa_result.
  ENDIF.

  v_title2 = 'Day Sales Outstanding Per Salesman'.
  PERFORM f_write_header.
  PERFORM f_write_header_column USING 'Salesman'.
  CLEAR: va_nou, wa_total, wa_subtotal, wa_subtotal1.
  v_current_page = 1.

  DESCRIBE TABLE i_result31 LINES va_lines.
  DESCRIBE TABLE i_result32 LINES va_lines1.

  IF va_lines < va_lines1.
    APPEND LINES OF i_result31 TO tmp_result31.
    APPEND LINES OF i_result32 TO tmp_result32.
    REFRESH : i_result31,i_result32.
    APPEND LINES OF tmp_result31 TO i_result32.
    APPEND LINES OF tmp_result32 TO i_result31.
    REFRESH : tmp_result31,tmp_result32.
    lv_flag = 'X'.
  ENDIF.

  tmp_result31[] = i_result31[].
  tmp_result32[] = i_result32[].
  SORT tmp_result31 BY vkbur xref2 fkart.
  DELETE ADJACENT DUPLICATES FROM tmp_result31 COMPARING vkbur xref2 fkart.
  SORT tmp_result32 BY vkbur xref2 fkart.
  DELETE ADJACENT DUPLICATES FROM tmp_result32 COMPARING vkbur xref2 fkart.
  LOOP AT tmp_result32 INTO ls_32.
    READ TABLE tmp_result31 INTO ls_31
                            WITH KEY vkbur = ls_32-vkbur
                                     xref2 = ls_32-xref2
                                     fkart = ls_32-fkart
                            TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      ls_31 = ls_32.
      CLEAR : ls_31-avrsales, ls_31-outstanding.
      APPEND ls_31 TO i_result31.
      CLEAR ls_31.
    ENDIF.
  ENDLOOP.

  SORT i_result31 BY vkbur xref2 fkart.
  SORT i_result32 BY vkbur xref2 fkart.

  lt_break2[] = i_result31[].
  SORT lt_break2 BY vkbur xref2.
  DELETE ADJACENT DUPLICATES FROM lt_break2 COMPARING vkbur xref2.

  lt_break1[] = i_result31[].
  SORT lt_break1 BY vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_break1 COMPARING vkbur.

  CLEAR: wa_result, wa_result1.
  LOOP AT lt_break1 INTO ls_break1.
    SELECT SINGLE *
      FROM tvkbt
      WHERE vkbur EQ ls_break1-vkbur
        AND spras EQ sy-langu.
    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    CONCATENATE ls_break1-vkbur tvkbt-bezei
            INTO va_text SEPARATED BY ' - '.
    WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + w6.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    PERFORM f_write_kosong.

    LOOP AT lt_break2 INTO ls_break2 WHERE vkbur = ls_break1-vkbur.
      CLEAR va_nou.
      LOOP AT i_result31 INTO wa_result WHERE vkbur = ls_break1-vkbur
                                          AND xref2 = ls_break2-xref2.
        ADD 1 TO va_nou.
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        SELECT SINGLE sname ename
          FROM pa0001
          INTO (wa_result-sname, wa_result-ename)
          WHERE pernr EQ wa_result-xref2.
        IF sy-subrc NE 0.
          wa_result-sname = 'Others'.
          wa_result-ename = 'Others'.
        ENDIF.
        CLEAR ltext.
        CONCATENATE wa_result-xref2 wa_result-sname wa_result-ename
           INTO ltext SEPARATED BY space.

        CLEAR lv_vtext.
        READ TABLE gt_tvfkt WITH KEY fkart = wa_result-fkart.
        IF sy-subrc = 0.
          CONCATENATE wa_result-fkart gt_tvfkt-vtext
                  INTO lv_vtext SEPARATED BY ' - '.
        ENDIF.

        WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w2) ltext NO-GAP. c1 = c1 + w2.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w4) lv_vtext NO-GAP. c1 = c1 + w4.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

        IF va_lines >= va_lines1 AND lv_flag EQ space.
          PERFORM f_write_detail.
          CLEAR wa_result1.
          LOOP AT i_result32 INTO wa_result1
               WHERE vkbur EQ wa_result-vkbur
                 AND bukrs EQ wa_result-bukrs
                 AND fkart EQ wa_result-fkart
                 AND xref2 EQ wa_result-xref2.
          ENDLOOP.
          PERFORM f_write_detail1.
        ELSE.
          CLEAR wa_result1.
          LOOP AT i_result32 INTO wa_result1
               WHERE vkbur EQ wa_result-vkbur
                 AND bukrs EQ wa_result-bukrs
                 AND fkart EQ wa_result-fkart
                 AND xref2 EQ wa_result-xref2.
          ENDLOOP.
          wa_result1-outstanding = wa_result-outstanding.
          wa_result-avrsales = wa_result1-avrsales.
          PERFORM f_write_detail.
          PERFORM f_write_detail1.
        ENDIF.
        CLEAR wa_result.
      ENDLOOP.
      PERFORM f_write_subtotal USING '      Sub Total' '' 'X' 'X' wa_subtotal1.
      CLEAR : wa_subtotal1.
    ENDLOOP.
    CONCATENATE 'Sub Total' va_text INTO ltext SEPARATED BY space.
    PERFORM f_write_subtotal USING ltext '' 'X' 'X' wa_subtotal.
    CLEAR: wa_subtotal, va_nou.
  ENDLOOP.

  PERFORM f_write_total USING ''.
ENDFORM.                                                    " f_proses3

*&---------------------------------------------------------------------*
*&      Form  f_proses4
*&---------------------------------------------------------------------*
FORM f_proses4.
  DATA : i_result41   TYPE ty_result OCCURS 0,
         i_result42   TYPE ty_result OCCURS 0,
         tmp_result42 TYPE ty_result OCCURS 0,
         tmp_result41 TYPE ty_result OCCURS 0,
         lt_break1    TYPE ty_result OCCURS 0,
         ls_break1    TYPE ty_result,
         lt_break2    TYPE ty_result OCCURS 0,
         ls_break2    TYPE ty_result,
         ls_41        TYPE ty_result,
         ls_42        TYPE ty_result.

  DATA : ltext(50).
  DATA : lv_vtext(30).
  DATA : lv_flag(1).

  CLEAR : i_result41[], i_result41, i_result42[], i_result42.

  IF i_result41[] IS INITIAL.
    SORT i_itab BY bukrs vkbur kunnr fkart anln1.
    CLEAR: wa_itab, wa_result, i_result41.

    LOOP AT i_itab INTO wa_itab.
      CASE 'X'.
        WHEN radio10.
          ON CHANGE OF wa_itab-bukrs OR
                       wa_itab-vkbur OR
                       wa_itab-fkart OR
                       wa_itab-kunnr OR
                       wa_itab-anln1.
            IF wa_result-kunnr NE space.
              wa_result-avrsales = wa_result-avrsales / jml_hari.
              APPEND wa_result TO i_result41.
              CLEAR wa_result.
            ENDIF.
          ENDON.

        WHEN OTHERS.
          ON CHANGE OF wa_itab-bukrs OR
                       wa_itab-vkbur OR
                       wa_itab-fkart OR
                       wa_itab-kunnr.
            IF wa_result-kunnr NE space.
              wa_result-avrsales = wa_result-avrsales / jml_hari.
              APPEND wa_result TO i_result41.
              CLEAR wa_result.
            ENDIF.
          ENDON.
      ENDCASE.

      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-fkart TO wa_result-fkart.
      MOVE wa_itab-kdgrp TO wa_result-kdgrp.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      MOVE wa_itab-anln1 TO wa_result-anln1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.

    IF wa_result-kunnr NE space.
      wa_result-avrsales = wa_result-avrsales / jml_hari.
      APPEND wa_result TO i_result41.
      CLEAR wa_result.
    ENDIF.

    SORT i_itab3 BY bukrs vkbur kunnr fkart anln1.
    CLEAR: wa_itab, wa_result, i_result42.

    LOOP AT i_itab3 INTO wa_itab.
      CASE 'X'.
        WHEN radio10.
          ON CHANGE OF wa_itab-bukrs OR
                       wa_itab-vkbur OR
                       wa_itab-fkart OR
                       wa_itab-kunnr OR
                       wa_itab-anln1.
            IF wa_result-kunnr NE space.
              wa_result-avrsales = wa_result-avrsales / jml_hari.
              APPEND wa_result TO i_result42.
              CLEAR wa_result.
            ENDIF.
          ENDON.

        WHEN OTHERS.
          ON CHANGE OF wa_itab-bukrs OR
                       wa_itab-vkbur OR
                       wa_itab-fkart OR
                       wa_itab-kunnr.
            IF wa_result-kunnr NE space.
              wa_result-avrsales = wa_result-avrsales / jml_hari.
              APPEND wa_result TO i_result42.
              CLEAR wa_result.
            ENDIF.
          ENDON.
      ENDCASE.

      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-fkart TO wa_result-fkart.
      MOVE wa_itab-kdgrp TO wa_result-kdgrp.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      MOVE wa_itab-anln1 TO wa_result-anln1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.

    IF wa_result-kunnr NE space.
      wa_result-avrsales = wa_result-avrsales / jml_hari.
      APPEND wa_result TO i_result42.
      CLEAR wa_result.
    ENDIF.
  ENDIF.

  CASE 'X'.
    WHEN radio10.
      v_title2 = 'Day Sales Outstanding Per Customer - Tempo Trading'.
    WHEN OTHERS.
      v_title2 = 'Day Sales Outstanding Per Customer'.
  ENDCASE.

  PERFORM f_write_header.
  PERFORM f_write_header_column USING 'Customer'.
  CLEAR: va_nou, wa_total, wa_subtotal, wa_subtotal1.
  v_current_page = 1.

  CLEAR: va_lines, va_lines1, tmp_result41, tmp_result42.
  REFRESH: tmp_result41, tmp_result42.
  DESCRIBE TABLE i_result41 LINES va_lines.
  DESCRIBE TABLE i_result42 LINES va_lines1.

  IF va_lines < va_lines1.
    APPEND LINES OF i_result41 TO tmp_result41.
    APPEND LINES OF i_result42 TO tmp_result42.
    REFRESH : i_result41,i_result42.
    APPEND LINES OF tmp_result41 TO i_result42.
    APPEND LINES OF tmp_result42 TO i_result41.
    REFRESH : tmp_result41,tmp_result42.
    lv_flag = 'X'.
  ENDIF.

  tmp_result41[] = i_result41[].
  tmp_result42[] = i_result42[].
  SORT tmp_result41 BY vkbur kunnr fkart anln1.
  SORT tmp_result42 BY vkbur kunnr fkart anln1.
  CASE 'X'.
    WHEN radio10.
      DELETE ADJACENT DUPLICATES FROM tmp_result41 COMPARING vkbur kunnr fkart anln1.
      DELETE ADJACENT DUPLICATES FROM tmp_result42 COMPARING vkbur kunnr fkart anln1.
    WHEN OTHERS.
      DELETE ADJACENT DUPLICATES FROM tmp_result41 COMPARING vkbur kunnr fkart.
      DELETE ADJACENT DUPLICATES FROM tmp_result42 COMPARING vkbur kunnr fkart.
  ENDCASE.

  CASE 'X'.
    WHEN radio10.
      LOOP AT tmp_result42 INTO ls_42.
        READ TABLE tmp_result41 INTO ls_41
                                WITH KEY vkbur = ls_42-vkbur
                                         kunnr = ls_42-kunnr
                                         fkart = ls_42-fkart
                                         anln1 = ls_42-anln1
                                TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          ls_41 = ls_42.
          CLEAR : ls_41-avrsales, ls_41-outstanding.
          APPEND ls_41 TO i_result41.
          CLEAR ls_41.
        ENDIF.
      ENDLOOP.
    WHEN OTHERS.
      LOOP AT tmp_result42 INTO ls_42.
        READ TABLE tmp_result41 INTO ls_41
                                WITH KEY vkbur = ls_42-vkbur
                                         kunnr = ls_42-kunnr
                                         fkart = ls_42-fkart
                                TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          ls_41 = ls_42.
          CLEAR : ls_41-avrsales, ls_41-outstanding.
          APPEND ls_41 TO i_result41.
          CLEAR ls_41.
        ENDIF.
      ENDLOOP.
  ENDCASE.

  SORT i_result41 BY vkbur kunnr fkart anln1.
  SORT i_result42 BY vkbur kunnr fkart anln1.

  lt_break2[] = i_result41[].
  SORT lt_break2 BY vkbur kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_break2 COMPARING vkbur kunnr.

  lt_break1[] = i_result41[].
  SORT lt_break1 BY vkbur anln1.
  DELETE ADJACENT DUPLICATES FROM lt_break1 COMPARING vkbur.

  CLEAR: wa_result, wa_result1.
  LOOP AT lt_break1 INTO ls_break1.
    SELECT SINGLE *
      FROM tvkbt
      WHERE vkbur EQ ls_break1-vkbur
        AND spras EQ sy-langu.
    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    CONCATENATE ls_break1-vkbur tvkbt-bezei
            INTO va_text SEPARATED BY ' - '.
    WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + w6.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

    IF radio10 = 'X'.
      WRITE AT c1(w7)' '  NO-GAP. c1 = c1 + w7.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    ENDIF.

    PERFORM f_write_kosong.

    LOOP AT lt_break2 INTO ls_break2 WHERE vkbur = ls_break1-vkbur.
      CLEAR va_nou.
      CASE 'X'.
        WHEN radio10.
          LOOP AT i_result41 INTO wa_result WHERE vkbur = ls_break1-vkbur
                                              AND kunnr = ls_break2-kunnr.
            ADD 1 TO va_nou.
            c1 = 1.
            WRITE: /  sy-vline.
            c1 = c1 + 1.
            CONCATENATE wa_result-kunnr wa_result-name1
                  INTO wa_result-name1 SEPARATED BY '-'.

            CLEAR lv_vtext.
            READ TABLE gt_tvfkt WITH KEY fkart = wa_result-fkart.
            IF sy-subrc = 0.
              CONCATENATE wa_result-fkart gt_tvfkt-vtext
                      INTO lv_vtext SEPARATED BY ' - '.
            ENDIF.

            WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
            WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
            WRITE AT c1(w2) wa_result-name1 NO-GAP. c1 = c1 + w2.
            WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
            WRITE AT c1(w4) lv_vtext NO-GAP. c1 = c1 + w4.
            WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

            IF radio10 = 'X'.
              WRITE AT c1(w7) wa_result-anln1 NO-GAP. c1 = c1 + w7.
              WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
            ENDIF.

            IF va_lines >= va_lines1 AND lv_flag EQ space.
              PERFORM f_write_detail.
              CLEAR wa_result1.
              LOOP AT i_result42 INTO wa_result1
                   WHERE vkbur EQ wa_result-vkbur
                     AND bukrs EQ wa_result-bukrs
                     AND fkart EQ wa_result-fkart
                     AND kunnr EQ wa_result-kunnr
                     AND anln1 EQ wa_result-anln1.
              ENDLOOP.
              PERFORM f_write_detail1.
            ELSE.
              CLEAR wa_result1.
              LOOP AT i_result42 INTO wa_result1
                   WHERE vkbur EQ wa_result-vkbur
                     AND bukrs EQ wa_result-bukrs
                     AND fkart EQ wa_result-fkart
                     AND kunnr EQ wa_result-kunnr
                     AND anln1 EQ wa_result-anln1.
              ENDLOOP.
              wa_result1-outstanding = wa_result-outstanding.
              wa_result-avrsales = wa_result1-avrsales.
              PERFORM f_write_detail.
              PERFORM f_write_detail1.
            ENDIF.
            CLEAR wa_result.
          ENDLOOP.

        WHEN OTHERS.
          LOOP AT i_result41 INTO wa_result WHERE vkbur = ls_break1-vkbur
                                              AND kunnr = ls_break2-kunnr.
            ADD 1 TO va_nou.
            c1 = 1.
            WRITE: /  sy-vline.
            c1 = c1 + 1.
            CONCATENATE wa_result-kunnr wa_result-name1
                  INTO wa_result-name1 SEPARATED BY '-'.

            CLEAR lv_vtext.
            READ TABLE gt_tvfkt WITH KEY fkart = wa_result-fkart.
            IF sy-subrc = 0.
              CONCATENATE wa_result-fkart gt_tvfkt-vtext
                      INTO lv_vtext SEPARATED BY ' - '.
            ENDIF.

            WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
            WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
            WRITE AT c1(w2) wa_result-name1 NO-GAP. c1 = c1 + w2.
            WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
            WRITE AT c1(w4) lv_vtext NO-GAP. c1 = c1 + w4.
            WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

            IF radio10 = 'X'.
              WRITE AT c1(w7) wa_result-anln1 NO-GAP. c1 = c1 + w7.
              WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
            ENDIF.

            IF va_lines >= va_lines1 AND lv_flag EQ space.
              PERFORM f_write_detail.
              CLEAR wa_result1.
              LOOP AT i_result42 INTO wa_result1
                   WHERE vkbur EQ wa_result-vkbur
                     AND bukrs EQ wa_result-bukrs
                     AND fkart EQ wa_result-fkart
                     AND kunnr EQ wa_result-kunnr.
              ENDLOOP.
              PERFORM f_write_detail1.
            ELSE.
              CLEAR wa_result1.
              LOOP AT i_result42 INTO wa_result1
                   WHERE vkbur EQ wa_result-vkbur
                     AND bukrs EQ wa_result-bukrs
                     AND fkart EQ wa_result-fkart
                     AND kunnr EQ wa_result-kunnr.
              ENDLOOP.
              wa_result1-outstanding = wa_result-outstanding.
              wa_result-avrsales = wa_result1-avrsales.
              PERFORM f_write_detail.
              PERFORM f_write_detail1.
            ENDIF.
            CLEAR wa_result.
          ENDLOOP.
      ENDCASE.
      PERFORM f_write_subtotal USING '      Sub Total' '' 'X' 'X' wa_subtotal1.
      CLEAR : wa_subtotal1.
    ENDLOOP.
    CONCATENATE 'Sub Total' va_text INTO ltext SEPARATED BY space.
    PERFORM f_write_subtotal USING ltext '' 'X' 'X' wa_subtotal.
    CLEAR: wa_subtotal, va_nou.
  ENDLOOP.

  PERFORM f_write_total USING ''.
ENDFORM.                                                    " f_proses4

*&---------------------------------------------------------------------*
*&      Form  f_proses5
*&---------------------------------------------------------------------*
FORM f_proses5.
  DATA : i_result51   TYPE ty_result OCCURS 0,
         i_result52   TYPE ty_result OCCURS 0,
         tmp_result52 TYPE ty_result OCCURS 0,
         tmp_result51 TYPE ty_result OCCURS 0,
         lt_break1    TYPE ty_result OCCURS 0,
         ls_break1    TYPE ty_result,
         lt_break2    TYPE ty_result OCCURS 0,
         ls_break2    TYPE ty_result,
         ls_51        TYPE ty_result,
         ls_52        TYPE ty_result.

  DATA : ltext(50).
  DATA : lv_vtext(30).
  DATA : lv_flag(1).

  CLEAR : i_result51[], i_result51, i_result52[], i_result52.

  IF i_result51[] IS INITIAL.
    SORT i_itab BY bukrs vkbur brsch fkart.
    CLEAR: wa_itab, wa_result, i_result51.
    LOOP AT i_itab INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-vkbur OR
                   wa_itab-fkart OR
                   wa_itab-brsch.
        IF wa_result-brsch NE space.
          wa_result-avrsales = wa_result-avrsales / jml_hari.
          APPEND wa_result TO i_result51.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-fkart TO wa_result-fkart.
      MOVE wa_itab-kdgrp TO wa_result-kdgrp.
      MOVE wa_itab-brsch TO wa_result-brsch.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.

    IF wa_result-brsch NE space.
      wa_result-avrsales = wa_result-avrsales / jml_hari.
      APPEND wa_result TO i_result51.
      CLEAR wa_result.
    ENDIF.

    SORT i_itab3 BY bukrs vkbur brsch fkart.
    CLEAR: wa_itab, wa_result, i_result52.
    LOOP AT i_itab3 INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-vkbur OR
                   wa_itab-fkart OR
                   wa_itab-brsch.
        IF wa_result-brsch NE space.
          wa_result-avrsales = wa_result-avrsales / jml_hari.
          APPEND wa_result TO i_result52.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-fkart TO wa_result-fkart.
      MOVE wa_itab-kdgrp TO wa_result-kdgrp.
      MOVE wa_itab-brsch TO wa_result-brsch.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.

    IF wa_result-brsch NE space.
      wa_result-avrsales = wa_result-avrsales / jml_hari.
      APPEND wa_result TO i_result52.
      CLEAR wa_result.
    ENDIF.
  ENDIF.
  v_title2 = 'Day Sales Outstanding Per Industry Code'.
  PERFORM f_write_header.
  PERFORM f_write_header_column USING 'Industry Code'.
  CLEAR: va_nou, wa_total, wa_subtotal, wa_subtotal1.
  v_current_page = 1.

  DESCRIBE TABLE i_result51 LINES va_lines.
  DESCRIBE TABLE i_result52 LINES va_lines1.

  IF va_lines < va_lines1.
    APPEND LINES OF i_result51 TO tmp_result51.
    APPEND LINES OF i_result52 TO tmp_result52.
    REFRESH : i_result51,i_result52.
    APPEND LINES OF tmp_result51 TO i_result52.
    APPEND LINES OF tmp_result52 TO i_result51.
    REFRESH :tmp_result51,tmp_result52.
    lv_flag = 'X'.
  ENDIF.

  tmp_result51[] = i_result51[].
  tmp_result52[] = i_result52[].
  SORT tmp_result51 BY vkbur brsch fkart.
  DELETE ADJACENT DUPLICATES FROM tmp_result51 COMPARING vkbur brsch fkart.
  SORT tmp_result52 BY vkbur brsch fkart.
  DELETE ADJACENT DUPLICATES FROM tmp_result52 COMPARING vkbur brsch fkart.
  LOOP AT tmp_result52 INTO ls_52.
    READ TABLE tmp_result51 INTO ls_51
                            WITH KEY vkbur = ls_52-vkbur
                                     brsch = ls_52-brsch
                                     fkart = ls_52-fkart
                            TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      ls_51 = ls_52.
      CLEAR : ls_51-avrsales, ls_51-outstanding.
      APPEND ls_51 TO i_result51.
      CLEAR ls_51.
    ENDIF.
  ENDLOOP.

  SORT i_result51 BY vkbur brsch fkart.
  SORT i_result52 BY vkbur brsch fkart.

  lt_break2[] = i_result51[].
  SORT lt_break2 BY vkbur kdgrp.
  DELETE ADJACENT DUPLICATES FROM lt_break2 COMPARING vkbur brsch.

  lt_break1[] = i_result51[].
  SORT lt_break1 BY vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_break1 COMPARING vkbur.

  CLEAR: wa_result, wa_result1.
  LOOP AT lt_break1 INTO ls_break1.
    SELECT SINGLE *
      FROM tvkbt
      WHERE vkbur EQ ls_break1-vkbur
        AND spras EQ sy-langu.
    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    CONCATENATE ls_break1-vkbur tvkbt-bezei
            INTO va_text SEPARATED BY ' - '.
    WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + w6.
    c1 = c1 + 1. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    PERFORM f_write_kosong.


    LOOP AT lt_break2 INTO ls_break2 WHERE vkbur = ls_break1-vkbur.
      CLEAR va_nou.
      LOOP AT i_result51 INTO wa_result WHERE vkbur = ls_break1-vkbur
                                          AND brsch = ls_break2-brsch.
        ADD 1 TO va_nou.
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        SELECT SINGLE *
          FROM t016t
          WHERE brsch EQ wa_result-brsch
            AND spras EQ sy-langu.
        IF sy-subrc NE 0.
          t016t-brtxt = 'Others'.
        ENDIF.
        CONCATENATE wa_result-brsch t016t-brtxt
            INTO ltext SEPARATED BY '-'.

        CLEAR lv_vtext.
        READ TABLE gt_tvfkt WITH KEY fkart = wa_result-fkart.
        IF sy-subrc = 0.
          CONCATENATE wa_result-fkart gt_tvfkt-vtext
                  INTO lv_vtext SEPARATED BY ' - '.
        ENDIF.

        WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w2) ltext NO-GAP. c1 = c1 + w2.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        WRITE AT c1(w4) lv_vtext NO-GAP. c1 = c1 + w4.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

        IF va_lines >= va_lines1 AND lv_flag EQ space.
          PERFORM f_write_detail.
          CLEAR wa_result1.
          LOOP AT i_result52 INTO wa_result1
               WHERE vkbur EQ wa_result-vkbur
                 AND bukrs EQ wa_result-bukrs
                 AND fkart EQ wa_result-fkart
                 AND brsch EQ wa_result-brsch.
          ENDLOOP.
          PERFORM f_write_detail1.
        ELSE.
          CLEAR wa_result1.
          LOOP AT i_result52 INTO wa_result1
               WHERE vkbur EQ wa_result-vkbur
                 AND bukrs EQ wa_result-bukrs
                 AND fkart EQ wa_result-fkart
                 AND brsch EQ wa_result-brsch.
          ENDLOOP.
          wa_result1-outstanding = wa_result-outstanding.
          wa_result-avrsales = wa_result1-avrsales.
          PERFORM f_write_detail.
          PERFORM f_write_detail1.
        ENDIF.
        CLEAR wa_result.
      ENDLOOP.
      PERFORM f_write_subtotal USING '      Sub Total' '' 'X' 'X' wa_subtotal1.
      CLEAR : wa_subtotal1.
    ENDLOOP.
    CONCATENATE 'Sub Total' va_text INTO ltext SEPARATED BY space.
    PERFORM f_write_subtotal USING ltext '' 'X' 'X' wa_subtotal.
    CLEAR: wa_subtotal, va_nou.
  ENDLOOP.

  PERFORM f_write_total USING ''.
ENDFORM.                                                    " f_proses5

*&---------------------------------------------------------------------*
*&      Form  f_proses6
*&---------------------------------------------------------------------*
FORM f_proses6.
  DATA : i_result61   TYPE ty_result OCCURS 0,
         i_result62   TYPE ty_result OCCURS 0,
         tmp_result62 TYPE ty_result OCCURS 0,
         tmp_result61 TYPE ty_result OCCURS 0,
         lt_break1    TYPE ty_result OCCURS 0,
         ls_break1    TYPE ty_result,
         ls_61        TYPE ty_result,
         ls_62        TYPE ty_result.

  DATA : ltext(50).
  DATA : lv_vtext(30).
  DATA : lv_flag(1).

  CLEAR : i_result61[], i_result61, i_result62[], i_result62.

  IF i_result61[] IS INITIAL.
    SORT i_itab BY bukrs kdgrp fkart.
    CLEAR: wa_itab, wa_result, i_result61.
    LOOP AT i_itab INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-fkart OR
                   wa_itab-kdgrp.
        IF wa_result-kdgrp NE space.
          wa_result-avrsales = wa_result-avrsales / jml_hari.
          APPEND wa_result TO i_result61.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-fkart TO wa_result-fkart.
      MOVE wa_itab-kdgrp TO wa_result-kdgrp.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.
    IF wa_result-kdgrp NE space.
      wa_result-avrsales = wa_result-avrsales / jml_hari.
      APPEND wa_result TO i_result61.
      CLEAR wa_result.
    ENDIF.

    SORT i_itab3 BY bukrs kdgrp fkart.
    CLEAR: wa_itab, wa_result, i_result62.
    LOOP AT i_itab3 INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-fkart OR
                   wa_itab-kdgrp.
        IF wa_result-kdgrp NE space.
          wa_result-avrsales = wa_result-avrsales / jml_hari.
          APPEND wa_result TO i_result62.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-fkart TO wa_result-fkart.
      MOVE wa_itab-kdgrp TO wa_result-kdgrp.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.

    IF wa_result-kdgrp NE space.
      wa_result-avrsales = wa_result-avrsales / jml_hari.
      APPEND wa_result TO i_result62.
      CLEAR wa_result.
    ENDIF.
  ENDIF.

  v_title2 = 'Day Sales Outstanding Per Customer Group Nasional'.
  PERFORM f_write_header.
  PERFORM f_write_header_column USING 'Customer Group'.
  CLEAR: va_nou, wa_total, wa_subtotal, wa_subtotal1.
  v_current_page = 1.

  DESCRIBE TABLE i_result61 LINES va_lines.
  DESCRIBE TABLE i_result62 LINES va_lines1.

  IF va_lines < va_lines1.
    APPEND LINES OF i_result61 TO tmp_result61.
    APPEND LINES OF i_result62 TO tmp_result62.
    REFRESH : i_result61,i_result62.
    APPEND LINES OF tmp_result61 TO i_result62.
    APPEND LINES OF tmp_result62 TO i_result61.
    REFRESH : tmp_result61,tmp_result62.
    lv_flag = 'X'.
  ENDIF.

  tmp_result61[] = i_result61[].
  tmp_result62[] = i_result62[].
  SORT tmp_result61 BY vkbur kdgrp fkart.
  DELETE ADJACENT DUPLICATES FROM tmp_result61 COMPARING vkbur kdgrp fkart.
  SORT tmp_result62 BY vkbur kdgrp fkart.
  DELETE ADJACENT DUPLICATES FROM tmp_result62 COMPARING vkbur kdgrp fkart.
  LOOP AT tmp_result62 INTO ls_62.
    READ TABLE tmp_result61 INTO ls_61
                            WITH KEY vkbur = ls_62-vkbur
                                     kdgrp = ls_62-kdgrp
                                     fkart = ls_62-fkart
                            TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      ls_61 = ls_62.
      CLEAR : ls_61-avrsales, ls_61-outstanding.
      APPEND ls_61 TO i_result61.
      CLEAR ls_61.
    ENDIF.
  ENDLOOP.

  SORT i_result61 BY bukrs kdgrp fkart.
  SORT i_result62 BY bukrs kdgrp fkart.
  CLEAR: wa_result, wa_result1.

  lt_break1[] = i_result61[].
  SORT lt_break1 BY kdgrp.
  DELETE ADJACENT DUPLICATES FROM lt_break1 COMPARING kdgrp.

  LOOP AT lt_break1 INTO ls_break1.
    CLEAR va_nou.
    LOOP AT i_result61 INTO wa_result WHERE kdgrp = ls_break1-kdgrp.
      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      SELECT SINGLE *
        FROM t151t
        WHERE kdgrp EQ wa_result-kdgrp
          AND spras EQ sy-langu.
      IF sy-subrc NE 0.
        t151t-ktext = 'Others'.
      ENDIF.
      CONCATENATE wa_result-kdgrp t151t-ktext
          INTO ltext SEPARATED BY '-'.

      CLEAR lv_vtext.
      READ TABLE gt_tvfkt WITH KEY fkart = wa_result-fkart.
      IF sy-subrc = 0.
        CONCATENATE wa_result-fkart gt_tvfkt-vtext
                INTO lv_vtext SEPARATED BY ' - '.
      ENDIF.

      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) ltext NO-GAP. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w4) lv_vtext NO-GAP. c1 = c1 + w4.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

      IF va_lines >= va_lines1 AND lv_flag EQ space.
        PERFORM f_write_detail.
        CLEAR wa_result1.
        LOOP AT i_result62 INTO wa_result1
             WHERE kdgrp EQ wa_result-kdgrp
               AND fkart EQ wa_result-fkart
               AND bukrs EQ wa_result-bukrs.
        ENDLOOP.
        PERFORM f_write_detail1.
      ELSE.
        CLEAR wa_result1.
        LOOP AT i_result62 INTO wa_result1
              WHERE kdgrp EQ wa_result-kdgrp
                AND fkart EQ wa_result-fkart
                AND bukrs EQ wa_result-bukrs.
        ENDLOOP.
        wa_result1-outstanding = wa_result-outstanding.
        wa_result-avrsales = wa_result1-avrsales.
        PERFORM f_write_detail.
        PERFORM f_write_detail1.
      ENDIF.
      CLEAR wa_result.
    ENDLOOP.
    CONCATENATE 'Sub Total' ltext INTO ltext SEPARATED BY space.
    PERFORM f_write_subtotal USING ltext '' 'X' 'X' wa_subtotal.
    CLEAR: wa_subtotal, va_nou.
  ENDLOOP.

  PERFORM f_write_total USING ''.
ENDFORM.                                                    " f_proses6

*&---------------------------------------------------------------------*
*&      Form  f_proses7
*&---------------------------------------------------------------------*
FORM f_proses7.
  DATA : i_result71   TYPE ty_result OCCURS 0 WITH HEADER LINE,
         i_result72   TYPE ty_result OCCURS 0,
         tmp_result72 TYPE ty_result OCCURS 0,
         tmp_result71 TYPE ty_result OCCURS 0,
         lt_break1    TYPE ty_result OCCURS 0,
         ls_break1    TYPE ty_result,
         lt_break2    TYPE ty_result OCCURS 0,
         ls_break2    TYPE ty_result,
         lt_break3    TYPE ty_result OCCURS 0,
         ls_break3    TYPE ty_result,
         ls_71        TYPE ty_result,
         ls_72        TYPE ty_result.

  DATA : BEGIN OF lt_vkbur OCCURS 0,
           vkbur LIKE knvv-vkbur.
  DATA : END OF lt_vkbur.

  DATA : ltext(50).
  DATA : lv_vtext(30).
  DATA : lv_flag(1).

  DATA : BEGIN OF ltext1,
           l_data1(5),
           l_data2,
           l_data3(2),
           l_data4,
           l_data5(40),
         END OF ltext1.
  DATA : BEGIN OF ltext2,
           l_data1(5),
           l_data2,
           l_data3(4),
           l_data4,
           l_data5(40),
         END OF ltext2.

  CLEAR : i_result71[], i_result71, i_result72[], i_result72,
          wa_subtotal2-avrsales, wa_subtotal2-outstanding.

  IF va_channel IS INITIAL.
    IF i_result71[] IS INITIAL.
      SORT i_itab BY bukrs vkbur channel kdgrp fkart.
      CLEAR: wa_itab, wa_result, i_result71.
      LOOP AT i_itab INTO wa_itab.
        ON CHANGE OF wa_itab-bukrs OR
                     wa_itab-vkbur OR
                     wa_itab-fkart OR
                     wa_itab-channel OR
                     wa_itab-kdgrp.
          IF wa_result-channel NE space.
            wa_result-avrsales = wa_result-avrsales / jml_hari.
            APPEND wa_result TO i_result71.
            CLEAR wa_result.
          ENDIF.
        ENDON.
        MOVE wa_itab-bukrs TO wa_result-bukrs.
        MOVE wa_itab-vkbur TO wa_result-vkbur.
        MOVE wa_itab-fkart TO wa_result-fkart.
        MOVE wa_itab-kdgrp TO wa_result-kdgrp.
        MOVE wa_itab-brsch TO wa_result-brsch.
        MOVE wa_itab-channel TO wa_result-channel.
        MOVE wa_itab-kunnr TO wa_result-kunnr.
        MOVE wa_itab-name1 TO wa_result-name1.
        PERFORM f_hitung.
        CLEAR wa_itab.
        lt_vkbur-vkbur  = wa_itab-vkbur.
        COLLECT lt_vkbur.
      ENDLOOP.

      IF wa_result-channel NE space.
        wa_result-avrsales = wa_result-avrsales / jml_hari.
        APPEND wa_result TO i_result71.
        CLEAR wa_result.
      ENDIF.

      SORT i_itab3 BY bukrs vkbur channel kdgrp fkart.
      CLEAR: wa_itab, wa_result, i_result72.

      LOOP AT i_itab3 INTO wa_itab.
        ON CHANGE OF wa_itab-bukrs OR
                     wa_itab-vkbur OR
                     wa_itab-fkart OR
                     wa_itab-channel OR
                     wa_itab-kdgrp.
          IF wa_result-channel NE space.
            wa_result-avrsales = wa_result-avrsales / jml_hari.
            APPEND wa_result TO i_result72.
            CLEAR wa_result.
          ENDIF.
        ENDON.
        MOVE wa_itab-bukrs TO wa_result-bukrs.
        MOVE wa_itab-vkbur TO wa_result-vkbur.
        MOVE wa_itab-fkart TO wa_result-fkart.
        MOVE wa_itab-kdgrp TO wa_result-kdgrp.
        MOVE wa_itab-brsch TO wa_result-brsch.
        MOVE wa_itab-channel TO wa_result-channel.
        MOVE wa_itab-kunnr TO wa_result-kunnr.
        MOVE wa_itab-name1 TO wa_result-name1.
        PERFORM f_hitung.
        lt_vkbur-vkbur  = wa_itab-vkbur.
        COLLECT lt_vkbur.
        CLEAR wa_itab.
      ENDLOOP.

      IF wa_result-channel NE space.
        wa_result-avrsales = wa_result-avrsales / jml_hari.
        APPEND wa_result TO i_result72.
        CLEAR wa_result.
      ENDIF.
    ENDIF.
    v_title2 = 'Day Sales Outstanding Per Channel'.
    PERFORM f_write_header.
    PERFORM f_write_header_column USING 'Channel'.
    CLEAR: va_nou, wa_total, wa_subtotal, wa_subtotal1.
    v_current_page = 1.

    DESCRIBE TABLE i_result71 LINES va_lines.
    DESCRIBE TABLE i_result72 LINES va_lines1.

    IF va_lines < va_lines1.
      APPEND LINES OF i_result71 TO tmp_result71.
      APPEND LINES OF i_result72 TO tmp_result72.
      REFRESH : i_result71,i_result72.
      APPEND LINES OF tmp_result71 TO i_result72.
      APPEND LINES OF tmp_result72 TO i_result71.
      REFRESH : tmp_result71,tmp_result72.
      lv_flag = 'X'.
    ENDIF.

    tmp_result71[] = i_result71[].
    tmp_result72[] = i_result72[].
    SORT tmp_result71 BY vkbur channel kdgrp fkart.
    DELETE ADJACENT DUPLICATES FROM tmp_result71 COMPARING vkbur channel kdgrp fkart.
    SORT tmp_result72 BY vkbur kunnr fkart.
    DELETE ADJACENT DUPLICATES FROM tmp_result72 COMPARING vkbur channel kdgrp fkart.
    LOOP AT tmp_result72 INTO ls_72.
      READ TABLE tmp_result71 INTO ls_71
                              WITH KEY vkbur   = ls_72-vkbur
                                       channel = ls_72-channel
                                       kdgrp   = ls_72-kdgrp
                                       fkart   = ls_72-fkart
                              TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        ls_71 = ls_72.
        CLEAR : ls_71-avrsales, ls_71-outstanding.
        APPEND ls_71 TO i_result71.
        CLEAR ls_71.
      ENDIF.
    ENDLOOP.

    SORT i_zfchanel BY bukrs vkbur channel kdgrp.
    SORT i_result71 BY bukrs vkbur channel kdgrp.
    LOOP AT i_zfchanel.
      IF so_gsber[] IS NOT INITIAL OR
        so_kdgrp[] IS NOT INITIAL OR
        so_kvgr3[] IS NOT INITIAL OR
        so_brsch[] IS NOT INITIAL OR
        so_kunnr[] IS NOT INITIAL.
        READ TABLE lt_vkbur WITH KEY vkbur = i_zfchanel-vkbur.
        IF sy-subrc EQ 0.
          READ TABLE i_result71 INTO wa_result WITH KEY bukrs   = i_zfchanel-bukrs
                                                        vkbur   = i_zfchanel-vkbur
                                                        channel = i_zfchanel-channel
                                                        kdgrp   = i_zfchanel-kdgrp.
          IF sy-subrc NE 0.
            i_result71-bukrs   = i_zfchanel-bukrs.
            i_result71-vkbur   = i_zfchanel-vkbur.
            i_result71-channel = i_zfchanel-channel.
            i_result71-kdgrp   = i_zfchanel-kdgrp.
            APPEND i_result71.
          ENDIF.
        ENDIF.
      ELSE.
        READ TABLE i_result71 INTO wa_result WITH KEY bukrs   = i_zfchanel-bukrs
                                                      vkbur   = i_zfchanel-vkbur
                                                      channel = i_zfchanel-channel
                                                      kdgrp   = i_zfchanel-kdgrp.
        IF sy-subrc NE 0.
          i_result71-bukrs   = i_zfchanel-bukrs.
          i_result71-vkbur   = i_zfchanel-vkbur.
          i_result71-channel = i_zfchanel-channel.
          i_result71-kdgrp   = i_zfchanel-kdgrp.
          APPEND i_result71.
        ENDIF.
      ENDIF.
    ENDLOOP.

    lt_break1[] = i_result71[].
    SORT lt_break1 BY vkbur.
    DELETE ADJACENT DUPLICATES FROM lt_break1 COMPARING vkbur.

    lt_break2[] = i_result71[].
    SORT lt_break2 BY vkbur channel.
    DELETE ADJACENT DUPLICATES FROM lt_break2 COMPARING vkbur channel.

    lt_break3[] = i_result71[].
    SORT lt_break3 BY vkbur channel kdgrp.
    DELETE ADJACENT DUPLICATES FROM lt_break3 COMPARING vkbur channel kdgrp.

    CLEAR: wa_result, wa_result1.
    SORT i_result71 BY bukrs vkbur channel kdgrp fkart.

    LOOP AT lt_break1 INTO ls_break1.
      SELECT SINGLE *
        FROM tvkbt
        WHERE vkbur EQ ls_break1-vkbur
          AND spras EQ sy-langu.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      CONCATENATE ls_break1-vkbur tvkbt-bezei
              INTO va_text SEPARATED BY ' - '.
      WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
      c1 = c1 + 1. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + w6.
      c1 = c1 + 1. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      PERFORM f_write_kosong.

      LOOP AT lt_break2 INTO ls_break2 WHERE vkbur = ls_break1-vkbur.
        LOOP AT lt_break3 INTO ls_break3 WHERE vkbur = ls_break1-vkbur
                                           AND channel = ls_break2-channel.
          LOOP AT i_result71 INTO wa_result WHERE vkbur   = ls_break1-vkbur
                                              AND channel = ls_break2-channel
                                              AND kdgrp   = ls_break3-kdgrp.
            SELECT SINGLE *
              FROM t151t
              WHERE kdgrp EQ wa_result-kdgrp
                AND spras EQ sy-langu.
            IF sy-subrc NE 0.
              t151t-ktext = 'Others'.
            ENDIF.
            ltext1-l_data1 = wa_result-channel.
            ltext1-l_data2 = space.
            ltext1-l_data3 = wa_result-kdgrp.
            ltext1-l_data4 = '.'.
            ltext1-l_data5 = t151t-ktext.

            ADD 1 TO va_nou.
            c1 = 1.
            WRITE: /  sy-vline.
            c1 = c1 + 1.

            CLEAR lv_vtext.
            READ TABLE gt_tvfkt WITH KEY fkart = wa_result-fkart.
            IF sy-subrc = 0.
              CONCATENATE wa_result-fkart gt_tvfkt-vtext
                      INTO lv_vtext SEPARATED BY ' - '.
            ENDIF.

            WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
            WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
            WRITE AT c1(w2) ltext1 NO-GAP. c1 = c1 + w2.
            WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
            WRITE AT c1(w4) lv_vtext NO-GAP. c1 = c1 + w4.
            WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

            IF va_lines >= va_lines1 AND lv_flag EQ space.
              PERFORM f_write_detail.
              CLEAR wa_result1.
              LOOP AT i_result72 INTO wa_result1
                   WHERE vkbur   EQ wa_result-vkbur
                     AND bukrs   EQ wa_result-bukrs
                     AND fkart   EQ wa_result-fkart
                     AND channel EQ wa_result-channel
                     AND kdgrp   EQ wa_result-kdgrp.
              ENDLOOP.
              PERFORM f_write_detail1.
            ELSE.
              CLEAR wa_result1.
              LOOP AT i_result72 INTO wa_result1
                   WHERE vkbur   EQ wa_result-vkbur
                     AND bukrs   EQ wa_result-bukrs
                     AND fkart   EQ wa_result-fkart
                     AND channel EQ wa_result-channel
                     AND kdgrp   EQ wa_result-kdgrp.
              ENDLOOP.
              wa_result1-outstanding = wa_result-outstanding.
              wa_result-avrsales = wa_result1-avrsales.
              PERFORM f_write_detail.
              PERFORM f_write_detail1.
            ENDIF.
            CLEAR wa_result.
          ENDLOOP.
          CONCATENATE 'Sub Total' ltext1
          INTO ltext
          SEPARATED BY space.
          PERFORM f_write_subtotal2 USING ltext.
          CLEAR: wa_subtotal2, va_nou.
        ENDLOOP.
        CONCATENATE 'Sub Total' ls_break2-channel
        INTO ltext
        SEPARATED BY space.
        PERFORM f_write_subtotal1 USING ltext.
        CLEAR: wa_subtotal1, va_nou.
      ENDLOOP.
      CONCATENATE 'Sub Total' va_text
      INTO ltext
      SEPARATED BY space.
      PERFORM f_write_subtotal USING ltext '' 'X' 'X' wa_subtotal.
      CLEAR: wa_subtotal, wa_subtotal1, va_nou.
    ENDLOOP.
    PERFORM f_write_total USING ''.
  ELSE.
    IF i_result71 IS INITIAL.
      SORT i_itab BY bukrs vkbur channel brsch.
      CLEAR: wa_itab, wa_result, i_result71.
      LOOP AT i_itab INTO wa_itab.
        ON CHANGE OF wa_itab-bukrs OR
                     wa_itab-vkbur OR
                     wa_itab-channel OR
                     wa_itab-brsch.
          IF wa_result-channel NE space.
            wa_result-avrsales = wa_result-avrsales / jml_hari.
            APPEND wa_result TO i_result71.
            CLEAR wa_result.
          ENDIF.
        ENDON.
        MOVE wa_itab-bukrs TO wa_result-bukrs.
        MOVE wa_itab-vkbur TO wa_result-vkbur.
        MOVE wa_itab-kdgrp TO wa_result-kdgrp.
        MOVE wa_itab-brsch TO wa_result-brsch.
        MOVE wa_itab-channel TO wa_result-channel.
        MOVE wa_itab-kunnr TO wa_result-kunnr.
        MOVE wa_itab-name1 TO wa_result-name1.
        PERFORM f_hitung.
        lt_vkbur-vkbur  = wa_itab-vkbur.
        COLLECT lt_vkbur.
        CLEAR wa_itab.
      ENDLOOP.
      IF wa_result-channel NE space.
        wa_result-avrsales = wa_result-avrsales / jml_hari.
        APPEND wa_result TO i_result71.
        CLEAR wa_result.
      ENDIF.

      SORT i_itab3 BY bukrs vkbur channel brsch.
      CLEAR: wa_itab, wa_result, i_result72.

      LOOP AT i_itab3 INTO wa_itab.
        ON CHANGE OF wa_itab-bukrs OR
                     wa_itab-vkbur OR
                     wa_itab-channel OR
                     wa_itab-brsch.
          IF wa_result-channel NE space.
            wa_result-avrsales = wa_result-avrsales / jml_hari.
            APPEND wa_result TO i_result72.
            CLEAR wa_result.
          ENDIF.
        ENDON.
        MOVE wa_itab-bukrs TO wa_result-bukrs.
        MOVE wa_itab-vkbur TO wa_result-vkbur.
        MOVE wa_itab-kdgrp TO wa_result-kdgrp.
        MOVE wa_itab-brsch TO wa_result-brsch.
        MOVE wa_itab-channel TO wa_result-channel.
        MOVE wa_itab-kunnr TO wa_result-kunnr.
        MOVE wa_itab-name1 TO wa_result-name1.
        PERFORM f_hitung.
        lt_vkbur-vkbur  = wa_itab-vkbur.
        COLLECT lt_vkbur.
        CLEAR wa_itab.
      ENDLOOP.
      IF wa_result-channel NE space.
        wa_result-avrsales = wa_result-avrsales / jml_hari.
        APPEND wa_result TO i_result72.
        CLEAR wa_result.
      ENDIF.
    ENDIF.
    v_title2 = 'Day Sales Outstanding Per Channel'.
    PERFORM f_write_header.
    PERFORM f_write_header_column USING 'Channel'.
    CLEAR: va_nou, wa_total, wa_subtotal, wa_subtotal1.
    v_current_page = 1.

    DESCRIBE TABLE i_result71 LINES va_lines.
    DESCRIBE TABLE i_result72 LINES va_lines1.

    IF va_lines < va_lines1.
      APPEND LINES OF i_result71 TO tmp_result71.
      APPEND LINES OF i_result72 TO tmp_result72.
      REFRESH : i_result71,i_result72.
      APPEND LINES OF tmp_result71 TO i_result72.
      APPEND LINES OF tmp_result72 TO i_result71.
      REFRESH :tmp_result71,tmp_result72.
      lv_flag = 'X'.
    ENDIF.

    SORT i_zfchanel BY bukrs vkbur channel brsch.
    SORT i_result71 BY bukrs vkbur channel brsch.
    LOOP AT i_zfchanel.
      READ TABLE lt_vkbur WITH KEY vkbur = i_zfchanel-vkbur.
      IF sy-subrc EQ 0.
        READ TABLE i_result71 INTO wa_result WITH KEY bukrs = i_zfchanel-bukrs
                                                      vkbur = i_zfchanel-vkbur
                                                      channel = i_zfchanel-channel
                                                      brsch = i_zfchanel-brsch.
        IF sy-subrc NE 0.
          i_result71-bukrs = i_zfchanel-bukrs.
          i_result71-vkbur = i_zfchanel-vkbur.
          i_result71-channel = i_zfchanel-channel.
          i_result71-brsch = i_zfchanel-brsch.
          APPEND i_result71.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CLEAR: wa_result, wa_result1.
    SORT i_result71 BY bukrs vkbur channel brsch.
    LOOP AT i_result71 INTO wa_result.
      AT NEW vkbur.
        SELECT SINGLE *
          FROM tvkbt
          WHERE vkbur EQ wa_result-vkbur
            AND spras EQ sy-langu.
        c1 = 1.
        WRITE: /  sy-vline.
        c1 = c1 + 1.
        CONCATENATE wa_result-vkbur tvkbt-bezei
                INTO va_text SEPARATED BY ' - '.
        WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
        c1 = c1 + 1. c1 = c1 + w1.
        WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
        PERFORM f_write_kosong.
      ENDAT.
      AT NEW brsch.
        SELECT SINGLE brtxt
          FROM t016t
          INTO wa_result-name1
          WHERE brsch EQ wa_result-brsch AND
                spras EQ sy-langu.
        IF sy-subrc NE 0.
          wa_result-name1 = 'Othes'.
        ENDIF.
        ltext2-l_data1 = wa_result-channel.
        ltext2-l_data2 = space.
        ltext2-l_data3 = wa_result-brsch.
        ltext2-l_data4 = '.'.
        ltext2-l_data5 = wa_result-name1.
      ENDAT.
      ADD 1 TO va_nou.
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.

      WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      WRITE AT c1(w2) ltext2 NO-GAP. c1 = c1 + w2.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

      IF va_lines >= va_lines1 AND lv_flag EQ space.
        PERFORM f_write_detail.
        CLEAR wa_result1.
        LOOP AT i_result72 INTO wa_result1
             WHERE vkbur EQ wa_result-vkbur AND
                   bukrs EQ wa_result-bukrs AND
                   channel EQ wa_result-channel AND
                   brsch EQ wa_result-brsch.
        ENDLOOP.
        PERFORM f_write_detail1.
      ELSE.
        CLEAR wa_result1.
        LOOP AT i_result72 INTO wa_result1
             WHERE vkbur EQ wa_result-vkbur AND
                   bukrs EQ wa_result-bukrs AND
                   channel EQ wa_result-channel AND
                   brsch EQ wa_result-brsch.
        ENDLOOP.
        wa_result1-outstanding = wa_result-outstanding.
        wa_result-avrsales = wa_result1-avrsales.
        PERFORM f_write_detail.
        PERFORM f_write_detail1.
      ENDIF.
      AT END OF channel.
        CONCATENATE 'Sub Total' wa_result-channel INTO ltext SEPARATED BY space.
        PERFORM f_write_subtotal1 USING ltext.
        CLEAR: wa_subtotal1, va_nou.
      ENDAT.
      AT END OF vkbur.
        CONCATENATE 'Sub Total' va_text INTO ltext SEPARATED BY space.
        PERFORM f_write_subtotal USING ltext '' 'X' 'X' wa_subtotal.
        CLEAR: wa_subtotal, wa_subtotal1, va_nou.
      ENDAT.
      CLEAR wa_result.
    ENDLOOP.
    PERFORM f_write_total USING ''.
  ENDIF.
ENDFORM.                                                    " f_proses7

*&---------------------------------------------------------------------*
*&      Form  F_PROSES8
*&---------------------------------------------------------------------*
FORM f_proses8 .
  DATA : i_result81   TYPE ty_result OCCURS 0,
         i_result82   TYPE ty_result OCCURS 0,
         tmp_result82 TYPE ty_result OCCURS 0,
         tmp_result81 TYPE ty_result OCCURS 0.

  DATA : ltext(50),
         bezei   TYPE bezei20.

  DATA : lv_flag(1).

  CLEAR : i_result81[], i_result81, i_result82[], i_result82.

  IF i_result81[] IS INITIAL.
    SORT i_itab BY bukrs vkbur kvgr3.
    CLEAR: wa_itab, wa_result, i_result81.
    LOOP AT i_itab INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-vkbur OR
                   wa_itab-kvgr3.
        IF wa_result-kvgr3 NE space.
          wa_result-avrsales = wa_result-avrsales / jml_hari.
          APPEND wa_result TO i_result81.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-kvgr3 TO wa_result-kvgr3.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.
    IF wa_result-kvgr3 NE space.
      wa_result-avrsales = wa_result-avrsales / jml_hari.
      APPEND wa_result TO i_result81.
      CLEAR wa_result.
    ENDIF.
    SORT i_itab3 BY bukrs vkbur kvgr3.
    CLEAR: wa_itab, wa_result, i_result82.

    LOOP AT i_itab3 INTO wa_itab.
      ON CHANGE OF wa_itab-bukrs OR
                   wa_itab-vkbur OR
                   wa_itab-kvgr3.
        IF wa_result-kvgr3 NE space.
          wa_result-avrsales = wa_result-avrsales / jml_hari.
          APPEND wa_result TO i_result82.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-kvgr3 TO wa_result-kvgr3.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.
    IF wa_result-kvgr3 NE space.
      wa_result-avrsales = wa_result-avrsales / jml_hari.
      APPEND wa_result TO i_result82.
      CLEAR wa_result.
    ENDIF.
  ENDIF.
  v_title2 = 'Day Sales Outstanding Per Sub Customer Group'.
  PERFORM f_write_header.
  PERFORM f_write_header_column USING 'Sub Customer Group'.
  CLEAR: va_nou, wa_total, wa_subtotal.
  v_current_page = 1.

**** Add 23-01-2003 by ars
  CLEAR: va_lines, va_lines1, tmp_result81, tmp_result82.
  REFRESH: tmp_result81, tmp_result82.
  DESCRIBE TABLE i_result81 LINES va_lines.
  DESCRIBE TABLE i_result82 LINES va_lines1.

  IF va_lines < va_lines1.
    APPEND LINES OF i_result81 TO tmp_result81.
    APPEND LINES OF i_result82 TO tmp_result82.
    REFRESH : i_result81,i_result82.
    APPEND LINES OF tmp_result81 TO i_result82.
    APPEND LINES OF tmp_result82 TO i_result81.
    REFRESH :tmp_result81,tmp_result82.
    lv_flag = 'X'.
  ENDIF.
**** End

  CLEAR: wa_result, wa_result1.
  LOOP AT i_result81 INTO wa_result.
    AT NEW vkbur.
      SELECT SINGLE * FROM tvkbt WHERE vkbur EQ wa_result-vkbur AND
                                  ( spras EQ 'E' OR spras EQ 'EN' ).
      c1 = 1.
      WRITE: /  sy-vline.
      c1 = c1 + 1.
      CONCATENATE wa_result-vkbur tvkbt-bezei
              INTO va_text SEPARATED BY ' - '.
      WRITE AT c1(w2) va_text NO-GAP. c1 = c1 + w2.
      c1 = c1 + 1. c1 = c1 + w1.
      WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
      PERFORM f_write_kosong.
    ENDAT.

    ADD 1 TO va_nou.
    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.

    SELECT SINGLE bezei INTO bezei FROM tvv3t WHERE spras EQ sy-langu
         AND kvgr3 EQ wa_result-kvgr3.

    SELECT SINGLE * FROM t151t WHERE kdgrp EQ wa_result-kdgrp AND
                            ( spras EQ 'EN' OR spras EQ 'E' ).
    IF sy-subrc NE 0.
      t151t-ktext = 'Others'.
    ENDIF.

    CONCATENATE wa_result-kvgr3 bezei
        INTO ltext SEPARATED BY '-'.

    WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w2) ltext NO-GAP. c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

    IF va_lines >= va_lines1 AND lv_flag EQ space.
      PERFORM f_write_detail.
      CLEAR wa_result1.
      LOOP AT i_result82 INTO wa_result1
           WHERE vkbur EQ wa_result-vkbur AND
                 bukrs EQ wa_result-bukrs AND
                 kvgr3 EQ wa_result-kvgr3.
      ENDLOOP.
      PERFORM f_write_detail1.
    ELSE.
      CLEAR wa_result1.
      LOOP AT i_result82 INTO wa_result1
           WHERE vkbur EQ wa_result-vkbur AND
                 bukrs EQ wa_result-bukrs AND
                 kvgr3 EQ wa_result-kvgr3.
      ENDLOOP.
      wa_result1-outstanding = wa_result-outstanding.
      wa_result-avrsales = wa_result1-avrsales.
      PERFORM f_write_detail.
      PERFORM f_write_detail1.

    ENDIF.
    AT END OF vkbur.
      CONCATENATE 'Sub Total' va_text INTO ltext SEPARATED BY space.
      PERFORM f_write_subtotal USING ltext '' 'X' 'X' wa_subtotal.
      CLEAR: wa_subtotal, va_nou.
    ENDAT.
    CLEAR wa_result.
  ENDLOOP.
  PERFORM f_write_total USING ''.
ENDFORM.                                                    " F_PROSES8

*&---------------------------------------------------------------------*
*&      Form  F_PROSES9
*&---------------------------------------------------------------------*
FORM f_proses9 .
  DATA : i_result91   TYPE ty_result OCCURS 0,
         i_result92   TYPE ty_result OCCURS 0,
         tmp_result92 TYPE ty_result OCCURS 0,
         tmp_result91 TYPE ty_result OCCURS 0,
         ls_91        TYPE ty_result,
         ls_92        TYPE ty_result.

  DATA : BEGIN OF lt_tvbur OCCURS 0,
           vkbur LIKE tvbur-vkbur.
  DATA : END OF lt_tvbur.

  DATA : lv_flag(1).
  DATA : lv_vtext(30).

  SORT i_zfchanel BY vkbur.
  IF so_gsber[] IS INITIAL AND
    so_kdgrp[] IS INITIAL AND
    so_kvgr3[] IS INITIAL AND
    so_brsch[] IS INITIAL AND
    so_kunnr[] IS INITIAL.
    LOOP AT i_zfchanel.
      lt_tvbur-vkbur  = i_zfchanel-vkbur.
      COLLECT lt_tvbur.
    ENDLOOP.
  ENDIF.

  CLEAR : i_result91[], i_result91, i_result92[], i_result92.

* gsber -> vkbur
  IF i_result91[] IS INITIAL.
    SORT i_itab BY fkart.
    CLEAR: wa_itab, wa_result, i_result91.
    LOOP AT i_itab INTO wa_itab.
      ON CHANGE OF wa_itab-fkart.
        IF wa_result-vkbur NE space.
          wa_result-avrsales = wa_result-avrsales / jml_hari.
          APPEND wa_result TO i_result91.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-kdgrp TO wa_result-kdgrp.
      MOVE wa_itab-fkart TO wa_result-fkart.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.

    IF wa_result-vkbur NE space.
      wa_result-avrsales = wa_result-avrsales / jml_hari.
      APPEND wa_result TO i_result91.
      CLEAR wa_result.
    ENDIF.

    SORT i_itab3 BY fkart.
    CLEAR: wa_itab, wa_result, i_result92.
    LOOP AT i_itab3 INTO wa_itab.
      ON CHANGE OF wa_itab-fkart.
        IF wa_result-vkbur NE space.
          wa_result-avrsales = wa_result-avrsales / jml_hari.
          APPEND wa_result TO i_result92.
          CLEAR wa_result.
        ENDIF.
      ENDON.
      MOVE wa_itab-bukrs TO wa_result-bukrs.
      MOVE wa_itab-vkbur TO wa_result-vkbur.
      MOVE wa_itab-kdgrp TO wa_result-kdgrp.
      MOVE wa_itab-fkart TO wa_result-fkart.
      MOVE wa_itab-kunnr TO wa_result-kunnr.
      MOVE wa_itab-name1 TO wa_result-name1.
      PERFORM f_hitung.
      CLEAR wa_itab.
    ENDLOOP.

    IF wa_result-vkbur NE space.
      wa_result-avrsales = wa_result-avrsales / jml_hari.
      APPEND wa_result TO i_result92.
      CLEAR wa_result.
    ENDIF.
  ENDIF.

  v_title2 = 'Day Sales Outstanding Per Branch'.
  PERFORM f_write_header.
  PERFORM f_write_header_column USING 'Branch'.
  CLEAR: va_nou, wa_total, wa_subtotal.
  v_current_page = 1.
  CLEAR: va_lines, va_lines1, tmp_result91, tmp_result92.
  REFRESH: tmp_result91, tmp_result92.
  DESCRIBE TABLE i_result91 LINES va_lines.
  DESCRIBE TABLE i_result92 LINES va_lines1.

  IF va_lines < va_lines1.
    APPEND LINES OF i_result91 TO tmp_result91.
    APPEND LINES OF i_result92 TO tmp_result92.
    REFRESH : i_result91,i_result92.
    APPEND LINES OF tmp_result91 TO i_result92.
    APPEND LINES OF tmp_result92 TO i_result91.
    REFRESH :tmp_result91,tmp_result92.
    lv_flag = 'X'.
  ENDIF.

  tmp_result91[] = i_result91[].
  tmp_result92[] = i_result92[].
  SORT tmp_result91 BY fkart.
  DELETE ADJACENT DUPLICATES FROM tmp_result91 COMPARING fkart.
  SORT tmp_result92 BY fkart.
  DELETE ADJACENT DUPLICATES FROM tmp_result92 COMPARING fkart.
  LOOP AT tmp_result92 INTO ls_92.
    READ TABLE tmp_result91 INTO ls_91
                            WITH KEY fkart = ls_92-fkart
                            TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      ls_91 = ls_92.
      CLEAR : ls_91-avrsales, ls_91-outstanding.
      APPEND ls_91 TO i_result91.
      CLEAR ls_91.
    ENDIF.
  ENDLOOP.

  SORT lt_tvbur BY vkbur.
  IF lt_tvbur[] IS NOT INITIAL.
    LOOP AT lt_tvbur.
      READ TABLE i_result91 INTO wa_result WITH KEY vkbur = lt_tvbur-vkbur
      BINARY SEARCH.
      IF sy-subrc NE 0.
        CLEAR: wa_result.
        wa_result-vkbur = lt_tvbur.
        APPEND wa_result TO i_result91.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CLEAR: wa_result, wa_result1.
  SORT i_result91 BY fkart.
  LOOP AT i_result91 INTO wa_result.
    CLEAR lv_vtext.
    READ TABLE gt_tvfkt WITH KEY fkart = wa_result-fkart.
    IF sy-subrc = 0.
      CONCATENATE wa_result-fkart gt_tvfkt-vtext
              INTO lv_vtext SEPARATED BY ' - '.
    ENDIF.
    ADD 1 TO va_nou.
    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w2) lv_vtext NO-GAP. c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    IF va_lines >= va_lines1 AND lv_flag EQ space.
      PERFORM f_write_detail.
      CLEAR wa_result1.
      LOOP AT i_result92 INTO wa_result1
           WHERE fkart EQ wa_result-fkart.
      ENDLOOP.
      PERFORM f_write_detail1.
    ELSE.
      CLEAR wa_result1.
      LOOP AT i_result92 INTO wa_result1
           WHERE fkart EQ wa_result-fkart.
      ENDLOOP.
      wa_result1-outstanding = wa_result-outstanding.
      wa_result-avrsales = wa_result1-avrsales.
      PERFORM f_write_detail.
      PERFORM f_write_detail1.
    ENDIF.
  ENDLOOP.
  PERFORM f_write_total USING 'Branch'.
ENDFORM.                                                    " F_PROSES9

*&---------------------------------------------------------------------*
*&      Form  f_write_header_column
*&---------------------------------------------------------------------*
FORM f_write_header_column USING ptext LIKE kna1-name1.
  DATA: l_text(20), l_text1(5).
  WRITE: jml_hari TO l_text1.
  CONDENSE l_text1.
  CONCATENATE 'Average Sales (' l_text1 ')'
      INTO l_text SEPARATED BY space.

  IF ptext <> 'Branch' AND
    ptext <> 'Billing Type'.
    WRITE: / sy-uline.
  ELSE.
    WRITE: / sy-uline(121).
  ENDIF.

  c1 = 1.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  WRITE AT c1(w1) 'Nou' NO-GAP. c1 = c1 + w1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w2) ptext NO-GAP. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  IF ptext <> 'Branch' AND
    ptext <> 'Billing Type'.
    WRITE AT c1(w4) 'Bill.Type' CENTERED NO-GAP. c1 = c1 + w4.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  ENDIF.

  IF radio10 = 'X'.
    WRITE AT c1(w7)'DN principal'  NO-GAP. c1 = c1 + w7.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  ENDIF.

  WRITE AT c1(w3) l_text CENTERED NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'Outstanding' CENTERED NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) 'DSO' CENTERED NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.

  IF ptext <> 'Branch' AND
    ptext <> 'Billing Type'.
    WRITE: / sy-uline.
  ELSE.
    WRITE: / sy-uline(121).
  ENDIF.
ENDFORM.                    " f_write_header_column

*&---------------------------------------------------------------------*
*&      Form  f_write_detail
*&---------------------------------------------------------------------*
FORM f_write_detail.
  WRITE AT c1(w3) wa_result-avrsales NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  ADD wa_result-avrsales TO wa_total-avrsales.
  ADD wa_result-avrsales TO wa_subtotal-avrsales.
  ADD wa_result-avrsales TO wa_subtotal1-avrsales.
  ADD wa_result-avrsales TO wa_subtotal2-avrsales.
ENDFORM.                    " f_write_detail

*&---------------------------------------------------------------------*
*&      Form  f_write_detail1
*&---------------------------------------------------------------------*
FORM f_write_detail1.
  DATA: l_dso LIKE bsid-dmbtr.
  WRITE AT c1(w3) wa_result1-outstanding NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  CLEAR l_dso.
  IF wa_result-avrsales NE 0.
    l_dso = wa_result1-outstanding / wa_result-avrsales.
  ENDIF.
  WRITE AT c1(w3) l_dso DECIMALS 2 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  ADD wa_result1-outstanding TO wa_total-outstanding.
  ADD wa_result1-outstanding TO wa_subtotal-outstanding.
  ADD wa_result1-outstanding TO wa_subtotal1-outstanding.
  ADD wa_result1-outstanding TO wa_subtotal2-outstanding.
ENDFORM.                    " f_write_detail

*&---------------------------------------------------------------------*
*&      Form  f_write_kosong
*&---------------------------------------------------------------------*
FORM f_write_kosong.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.
ENDFORM.                    " f_write_kosong

*&---------------------------------------------------------------------*
*&      Form  f_hitung
*&---------------------------------------------------------------------*
FORM f_hitung.
  DATA: l_date  LIKE sy-datum,
        l_date1 LIKE sy-datum,
        l_date2 LIKE sy-datum.

  IF wa_itab-shkzg = 'H'.
    wa_itab-dmbtr = wa_itab-dmbtr * -100.
  ELSE.
    wa_itab-dmbtr = wa_itab-dmbtr * 100.
  ENDIF.

  ADD wa_itab-dmbtr TO wa_result-avrsales.
  ADD wa_itab-dmbtr TO wa_result-outstanding.
ENDFORM.                    " f_hitung

*&---------------------------------------------------------------------*
*&      Form  f_write_total
*&---------------------------------------------------------------------*
FORM f_write_total USING ptext.
  DATA: l_dso LIKE bsid-dmbtr.
  IF ptext IS INITIAL.
    WRITE: / sy-uline.
  ELSE.
    WRITE: / sy-uline(121).
  ENDIF.
  c1 = 1.
  WRITE: /  sy-vline.
  c1 = c1 + 1.
  IF ptext IS INITIAL.
    WRITE AT c1(w5) 'Grand Total ' NO-GAP. c1 = c1 + w5.
  ELSE.
    WRITE AT c1(w2) 'Grand Total ' NO-GAP. c1 = c1 + w2.
  ENDIF.
  c1 = c1 + w1.
  c1 = c1 + 1.

  IF radio10 = 'X'.
    c1 = c1 + w7.
    c1 = c1 + 1.
  ENDIF.

  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  CLEAR l_dso.
*  if wa_result1-outstanding ne 0.
  IF wa_total-avrsales NE 0.
    l_dso = wa_total-outstanding / wa_total-avrsales.
  ENDIF.
  WRITE AT c1(w3) wa_total-avrsales NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_total-outstanding NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) l_dso DECIMALS 2 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.
  IF ptext IS INITIAL.
    WRITE: / sy-uline.
  ELSE.
    WRITE: / sy-uline(121).
  ENDIF.

  CLEAR : wa_subtotal, wa_subtotal1, wa_subtotal2, wa_total.
ENDFORM.                    " f_write_total

*&---------------------------------------------------------------------*
*&      Form  f_write_subtotal
*&---------------------------------------------------------------------*
FORM f_write_subtotal USING ptext TYPE text50
                            fu_flag fu_line1 fu_line2
                            lwa_subtotal STRUCTURE i_result.

  DATA : l_dso LIKE bsid-dmbtr.

  IF fu_line2 IS NOT INITIAL.
    IF fu_line1 IS NOT INITIAL.
      IF fu_flag IS INITIAL.
        WRITE : / sy-uline.
      ELSE.
        WRITE : / sy-uline(121).
      ENDIF.
    ENDIF.
  ENDIF.

  c1 = 1.
  WRITE : /  sy-vline.
  c1 = c1 + 1.

  IF fu_line1 IS NOT INITIAL.
    IF fu_flag IS INITIAL.
      WRITE AT c1(w5) ptext NO-GAP. c1 = c1 + w5.
    ELSE.
      WRITE AT c1(w2) ptext NO-GAP. c1 = c1 + w2.
    ENDIF.
  ELSE.
    c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w2) ptext NO-GAP. c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + w6.
  ENDIF.

  c1 = c1 + w1.
  c1 = c1 + 1.

  IF radio10 = 'X'.
    c1 = c1 + w7.
    c1 = c1 + 1.
  ENDIF.

  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  CLEAR l_dso.
  IF lwa_subtotal-avrsales NE 0.
    l_dso = lwa_subtotal-outstanding / lwa_subtotal-avrsales.
  ENDIF.
  WRITE AT c1(w3) lwa_subtotal-avrsales NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) lwa_subtotal-outstanding NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) l_dso DECIMALS 2 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 0.
  c1 = 0.

  IF fu_line1 IS NOT INITIAL.
    IF fu_flag IS INITIAL.
      WRITE : / sy-uline.
    ELSE.
      WRITE : / sy-uline(121).
    ENDIF.
  ENDIF.
ENDFORM.                    " f_write_subtotal

*&---------------------------------------------------------------------*
*&      Form  f_write_subtotal1
*&---------------------------------------------------------------------*
FORM f_write_subtotal1 USING ptext TYPE text50.
  DATA: l_dso LIKE bsid-dmbtr.
  PERFORM f_write_kosong1.
  c1 = 1.
  WRITE: /  sy-vline. c1 = c1 + w1.
  c1 = c1 + 1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w2) ptext NO-GAP. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w4) space NO-GAP. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  CLEAR l_dso.
  IF wa_subtotal1-avrsales NE 0.
    l_dso = wa_subtotal1-outstanding / wa_subtotal1-avrsales.
  ENDIF.
  WRITE AT c1(w3) wa_subtotal1-avrsales NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal1-outstanding NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) l_dso DECIMALS 2 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  PERFORM f_write_kosong1.
  c1 = 0.
  c1 = 0.
ENDFORM.                    " f_write_subtotal1

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_SUBTOTAL2
*&---------------------------------------------------------------------*
FORM f_write_subtotal2  USING    ptext TYPE text50.
  DATA: l_dso LIKE bsid-dmbtr.
  PERFORM f_write_kosong1.
  c1 = 1.
  WRITE: /  sy-vline. c1 = c1 + w1.
  c1 = c1 + 1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w2) ptext NO-GAP. c1 = c1 + w2.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w4) space NO-GAP. c1 = c1 + w4.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  CLEAR l_dso.
  IF wa_subtotal2-avrsales NE 0.
    l_dso = wa_subtotal2-outstanding / wa_subtotal2-avrsales.
  ENDIF.
  WRITE AT c1(w3) wa_subtotal2-avrsales NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) wa_subtotal2-outstanding NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w3) l_dso DECIMALS 2 NO-GAP. c1 = c1 + w3.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  PERFORM f_write_kosong1.
  c1 = 0.
  c1 = 0.
ENDFORM.                    " F_WRITE_SUBTOTAL2

*&---------------------------------------------------------------------*
*&      Form  f_write_kosong1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_kosong1 .
  c1 = 1.
  WRITE: /  sy-vline. c1 = c1 + w1. c1 = c1 + 1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + w2. c1 = c1 + 1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + w4. c1 = c1 + 1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + w3. c1 = c1 + 1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + w3. c1 = c1 + 1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + w3. c1 = c1 + 1.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
ENDFORM.                    " f_write_kosong1

*&---------------------------------------------------------------------*
*&      Form  f_hapus_kunnr_itab3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hapus_kunnr_itab3 .
  IF t_zfarsoff_dele[] IS NOT INITIAL.
    SORT i_itab_bsid BY kunnr.
    SORT i_itab_bsad BY kunnr.
    SORT t_zfarsoff_dele BY kunnr.
    LOOP AT i_itab_bsid INTO wa_itab.
      READ TABLE t_zfarsoff_dele WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        DELETE i_itab_bsid.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.

    LOOP AT i_itab_bsad INTO wa_itab.
      READ TABLE t_zfarsoff_dele WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        DELETE i_itab_bsad.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_hapus_kunnr_itab3

*&---------------------------------------------------------------------*
*&      Form  f_tambah_kunnr_itab3
*&---------------------------------------------------------------------*
FORM f_tambah_kunnr_itab3 .
  IF t_zfarsoff_add[] IS NOT INITIAL.
    DATA: month LIKE bsid-monat, year LIKE bsid-gjahr.
    CLEAR: wa_itab, i_itab, i_itab1, i_itab2.
    IF pa_date IS INITIAL.
      ra_budat-high = sy-datum.
    ELSE.
      ra_budat-high = pa_date.
    ENDIF.
    IF ra_budat-high+4(2) < pa_dso.
      month = ra_budat-high+4(2) + 12 - pa_dso + 1.
      year = ra_budat-high(4) - 1.
    ELSE.
      month = ra_budat-high+4(2) - pa_dso + 1.
      year =  ra_budat-high(4).
    ENDIF.
    IF month > ra_budat-high+4(2).
    ELSE.
    ENDIF.
    CONCATENATE year month '01' INTO ra_budat-low.
    ra_budat-sign = 'I'.
    ra_budat-option = 'BT'.
    APPEND ra_budat.

    jml_hari = ra_budat-high - ra_budat-low + 1.

    IF x_norm EQ 'X' AND x_shbv EQ 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart a~anln1
             b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
             FROM bsid AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                            JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                              c~vkorg EQ a~bukrs AND
                                              c~vtweg EQ '10' AND
                                              c~spart EQ '00'
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_bsid_add
             FOR ALL ENTRIES IN t_zfarsoff_add
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~umsks EQ space AND
                   a~gjahr <= pa_date(4) AND
                   a~budat <= pa_date AND
                   a~kunnr EQ t_zfarsoff_add-kunnr AND
                   a~umskz EQ space    AND
                   c~vkorg EQ pa_bukrs AND
                   c~vkbur EQ t_zfarsoff_add-zvkbur1 AND
                   c~vtweg EQ '10' AND
                   c~spart EQ '00'.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart a~anln1
             b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
             FROM bsad AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                        JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                              c~vkorg EQ a~bukrs AND
                                              c~vtweg EQ '10' AND
                                              c~spart EQ '00'
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_bsad_add
             FOR ALL ENTRIES IN t_zfarsoff_add
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~umsks EQ space AND
                   a~gjahr <= pa_date(4) AND
                   a~augdt > pa_date AND
                   a~budat <= pa_date AND
                   a~kunnr EQ t_zfarsoff_add-kunnr AND
                   a~umskz EQ space    AND
                   a~blart IN ('RV','ZA','DR','DA','DZ') AND
                   c~vkorg EQ pa_bukrs AND
                   c~vtweg EQ '10' AND
                   c~vkbur EQ t_zfarsoff_add-zvkbur1 AND
                   c~spart EQ '00'.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart a~anln1
             b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
             FROM bsid AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                            JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                              c~vkorg EQ a~bukrs AND
                                              c~vtweg EQ '10' AND
                                              c~spart EQ '00'
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add
             FOR ALL ENTRIES IN t_zfarsoff_add
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~gjahr <= pa_date(4) AND
                   a~budat <= pa_date AND
                   a~kunnr EQ t_zfarsoff_add-kunnr AND
                   a~umskz IN so_umskz AND
                   c~vkorg EQ pa_bukrs AND
                   c~vkbur EQ t_zfarsoff_add-zvkbur1 AND
                   c~vtweg EQ '10' AND
                   c~spart EQ '00'.


      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart a~anln1
             b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
             FROM bsad AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                        JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                              c~vkorg EQ a~bukrs AND
                                              c~vtweg EQ '10' AND
                                              c~spart EQ '00'
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             APPENDING CORRESPONDING FIELDS OF TABLE t_bsad_add
             FOR ALL ENTRIES IN t_zfarsoff_add
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~gjahr <= pa_date(4) AND
                   a~augdt > pa_date AND
                   a~budat <= pa_date AND
                   a~kunnr EQ t_zfarsoff_add-kunnr AND
                   a~umskz IN so_umskz AND
                   a~blart IN ('RV','ZA','DR','DA','DZ') AND
                   c~vkorg EQ pa_bukrs AND
                   c~vtweg EQ '10' AND
                   c~vkbur EQ t_zfarsoff_add-zvkbur1 AND
                   c~spart EQ '00'.
    ENDIF.

    IF x_norm EQ 'X' AND x_shbv EQ space.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart a~anln1
             b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
             FROM bsid AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                            JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                              c~vkorg EQ a~bukrs AND
                                              c~vtweg EQ '10' AND
                                              c~spart EQ '00'
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_bsid_add
             FOR ALL ENTRIES IN t_zfarsoff_add
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~umsks EQ space AND
                   a~gjahr <= pa_date(4) AND
                   a~budat <= pa_date AND
                   a~kunnr EQ t_zfarsoff_add-kunnr AND
                   a~umskz EQ space    AND
                   c~vkorg EQ pa_bukrs AND
                   c~vkbur EQ t_zfarsoff_add-zvkbur1 AND
                   c~vtweg EQ '10' AND
                   c~spart EQ '00'.


      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart a~anln1
             b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
             FROM bsad AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                        JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                              c~vkorg EQ a~bukrs AND
                                              c~vtweg EQ '10' AND
                                              c~spart EQ '00'
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_bsad_add
             FOR ALL ENTRIES IN t_zfarsoff_add
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~umsks EQ space AND
                   a~gjahr <= pa_date(4) AND
                   a~augdt > pa_date AND
                   a~budat <= pa_date AND
                   a~kunnr EQ t_zfarsoff_add-kunnr AND
                   a~umskz EQ space    AND
                   a~blart IN ('RV','ZA','DR','DA','DZ') AND
                   c~vkorg EQ pa_bukrs AND
                   c~vtweg EQ '10' AND
                   c~vkbur EQ t_zfarsoff_add-zvkbur1 AND
                   c~spart EQ '00'.
    ENDIF.

    IF x_norm EQ space AND x_shbv EQ 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart a~anln1
             b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
             FROM bsid AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                            JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                              c~vkorg EQ a~bukrs AND
                                              c~vtweg EQ '10' AND
                                              c~spart EQ '00'
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_bsid_add
             FOR ALL ENTRIES IN t_zfarsoff_add
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~gjahr <= pa_date(4) AND
                   a~budat <= pa_date AND
                   a~kunnr EQ t_zfarsoff_add-kunnr AND
                   a~umskz IN so_umskz AND
                   c~vkorg EQ pa_bukrs AND
                   c~vkbur EQ t_zfarsoff_add-zvkbur1 AND
                   c~vtweg EQ '10' AND
                   c~spart EQ '00'.


      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart a~anln1
             b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
             FROM bsad AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                        JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                              c~vkorg EQ a~bukrs AND
                                              c~vtweg EQ '10' AND
                                              c~spart EQ '00'
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_bsad_add
             FOR ALL ENTRIES IN t_zfarsoff_add
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~gjahr <= pa_date(4) AND
                   a~augdt > pa_date AND
                   a~budat <= pa_date AND
                   a~kunnr EQ t_zfarsoff_add-kunnr AND
                   a~umskz IN so_umskz AND
                   a~blart IN ('RV','ZA','DR','DA','DZ') AND
                   c~vkorg EQ pa_bukrs AND
                   c~vtweg EQ '10' AND
                   c~vkbur EQ t_zfarsoff_add-zvkbur1 AND
                   c~spart EQ '00'.

    ENDIF.

    SORT t_bsid_add BY kunnr.
    SORT t_bsad_add BY kunnr.
    SORT t_zfarsoff_add BY kunnr.
    LOOP AT t_bsid_add INTO wa_itab.
      READ TABLE t_zfarsoff_add WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF pa_date LT t_zfarsoff_add-budat.
          IF t_zfarsoff_add-zvkbur IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur.
            APPEND wa_itab TO i_itab_bsid.
          ENDIF.
        ELSE.
          IF t_zfarsoff_add-zvkbur1 IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur1.
            APPEND wa_itab TO i_itab_bsid.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.

    LOOP AT t_bsad_add INTO wa_itab.
      READ TABLE t_zfarsoff_add WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF pa_date LT t_zfarsoff_add-budat.
          IF t_zfarsoff_add-zvkbur IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur.
            APPEND wa_itab TO i_itab_bsad.
          ENDIF.
        ELSE.
          IF t_zfarsoff_add-zvkbur1 IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur1.
            APPEND wa_itab TO i_itab_bsad.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_tambah_kunnr_itab3

*&---------------------------------------------------------------------*
*&      Form  f_hapus_kunnr_itab
*&---------------------------------------------------------------------*
FORM f_hapus_kunnr_itab .
  IF t_zfarsoff_dele[] IS NOT INITIAL.
    SORT i_itab1 BY kunnr.
    SORT i_itab2 BY kunnr.
    SORT t_zfarsoff_dele BY kunnr.
    LOOP AT i_itab1 INTO wa_itab.
      READ TABLE t_zfarsoff_dele WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        DELETE i_itab1.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.

    LOOP AT i_itab2 INTO wa_itab.
      READ TABLE t_zfarsoff_dele WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        DELETE i_itab2.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_hapus_kunnr_itab

*&---------------------------------------------------------------------*
*&      Form  f_tambah_kunnr_itab
*&---------------------------------------------------------------------*
FORM f_tambah_kunnr_itab .
  IF t_zfarsoff_add[] IS NOT INITIAL.
    IF x_norm EQ 'X' AND x_shbv EQ 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart a~anln1
             b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
             FROM bsid AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                            JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                              c~vkorg EQ a~bukrs AND
                                              c~vtweg EQ '10' AND
                                              c~spart EQ '00'
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_itab1_add
             FOR ALL ENTRIES IN t_zfarsoff_add
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~umsks EQ space AND
                   a~gjahr <= pa_date(4) AND
                   a~budat IN ra_budat AND
                   a~kunnr EQ t_zfarsoff_add-kunnr AND
                   a~umskz EQ space    AND
                   a~blart IN ('RV','ZA','DR') AND
                   c~vkorg EQ pa_bukrs AND
                   c~vkbur EQ t_zfarsoff_add-zvkbur1 AND
                   c~vtweg EQ '10' AND
                   c~spart EQ '00'.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart a~anln1
             b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
             FROM bsad AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                            JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                              c~vkorg EQ a~bukrs AND
                                              c~vtweg EQ '10' AND
                                              c~spart EQ '00'
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_itab2_add
             FOR ALL ENTRIES IN t_zfarsoff_add
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~umsks EQ space AND
                   a~gjahr <= pa_date(4) AND
                   a~budat IN ra_budat AND
                   a~kunnr EQ t_zfarsoff_add-kunnr AND
                   a~umskz EQ space    AND
                   a~blart IN ('RV','ZA','DR') AND
                   c~vkorg EQ pa_bukrs AND
                   c~vtweg EQ '10' AND
                   c~vkbur EQ t_zfarsoff_add-zvkbur1 AND
                   c~spart EQ '00'.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart a~anln1
             b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
             FROM bsid AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                            JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                              c~vkorg EQ a~bukrs AND
                                              c~vtweg EQ '10' AND
                                              c~spart EQ '00'
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             APPENDING CORRESPONDING FIELDS OF TABLE t_itab1_add
             FOR ALL ENTRIES IN t_zfarsoff_add
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~gjahr <= pa_date(4) AND
                   a~budat IN ra_budat AND
                   a~kunnr EQ t_zfarsoff_add-kunnr AND
                   a~umskz IN so_umskz AND
                   a~blart IN ('RV','ZA','DR') AND
                   c~vkorg EQ pa_bukrs AND
                   c~vkbur EQ t_zfarsoff_add-zvkbur1 AND
                   c~vtweg EQ '10' AND
                   c~spart EQ '00'.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart a~anln1
             b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
             FROM bsad AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                            JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                              c~vkorg EQ a~bukrs AND
                                              c~vtweg EQ '10' AND
                                              c~spart EQ '00'
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             APPENDING CORRESPONDING FIELDS OF TABLE t_itab2_add
             FOR ALL ENTRIES IN t_zfarsoff_add
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~gjahr <= pa_date(4) AND
                   a~budat IN ra_budat AND
                   a~kunnr EQ t_zfarsoff_add-kunnr AND
                   a~umskz IN so_umskz AND
                   a~blart IN ('RV','ZA','DR') AND
                   c~vkorg EQ pa_bukrs AND
                   c~vtweg EQ '10' AND
                   c~vkbur EQ t_zfarsoff_add-zvkbur1 AND
                   c~spart EQ '00'.
    ENDIF.

    IF x_norm EQ 'X' AND x_shbv EQ space.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart a~anln1
             b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
             FROM bsid AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                            JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                              c~vkorg EQ a~bukrs AND
                                              c~vtweg EQ '10' AND
                                              c~spart EQ '00'
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_itab1_add
             FOR ALL ENTRIES IN t_zfarsoff_add
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~umsks EQ space AND
                   a~gjahr <= pa_date(4) AND
                   a~budat IN ra_budat AND
                   a~kunnr EQ t_zfarsoff_add-kunnr AND
                   a~umskz EQ space    AND
                   a~blart IN ('RV','ZA','DR') AND
                   c~vkorg EQ pa_bukrs AND
                   c~vkbur EQ t_zfarsoff_add-zvkbur1 AND
                   c~vtweg EQ '10' AND
                   c~spart EQ '00'.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart a~anln1
             b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
             FROM bsad AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                            JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                              c~vkorg EQ a~bukrs AND
                                              c~vtweg EQ '10' AND
                                              c~spart EQ '00'
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_itab2_add
             FOR ALL ENTRIES IN t_zfarsoff_add
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~umsks EQ space AND
                   a~gjahr <= pa_date(4) AND
                   a~budat IN ra_budat AND
                   a~kunnr EQ t_zfarsoff_add-kunnr AND
                   a~umskz EQ space    AND
                   a~blart IN ('RV','ZA','DR') AND
                   c~vkorg EQ pa_bukrs AND
                   c~vtweg EQ '10' AND
                   c~vkbur EQ t_zfarsoff_add-zvkbur1 AND
                   c~spart EQ '00'.
    ENDIF.

    IF x_norm EQ space AND x_shbv EQ 'X'.
      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart a~anln1
             b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
             FROM bsid AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                            JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                              c~vkorg EQ a~bukrs AND
                                              c~vtweg EQ '10' AND
                                              c~spart EQ '00'
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_itab1_add
             FOR ALL ENTRIES IN t_zfarsoff_add
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~gjahr <= pa_date(4) AND
                   a~budat IN ra_budat AND
                   a~kunnr EQ t_zfarsoff_add-kunnr AND
                   a~umskz IN so_umskz AND
                   a~blart IN ('RV','ZA','DR') AND
                   c~vkorg EQ pa_bukrs AND
                   c~vkbur EQ t_zfarsoff_add-zvkbur1 AND
                   c~vtweg EQ '10' AND
                   c~spart EQ '00'.

      SELECT a~bukrs a~gsber a~budat a~bldat a~gjahr a~belnr a~kunnr
             a~blart a~zbd1t a~zfbdt a~zuonr a~dmbtr a~shkzg
             a~xref1 a~xref2 a~blart a~anln1
             b~name1 b~brsch c~kdgrp c~vkbur c~kvgr3 d~pernr
             FROM bsad AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
                            JOIN knvv AS c ON c~kunnr EQ a~kunnr AND
                                              c~vkorg EQ a~bukrs AND
                                              c~vtweg EQ '10' AND
                                              c~spart EQ '00'
                       LEFT JOIN vbpa AS d ON  a~belnr EQ d~vbeln AND
                                               d~parvw EQ 'ZP'
             INTO CORRESPONDING FIELDS OF TABLE t_itab2_add
             FOR ALL ENTRIES IN t_zfarsoff_add
             WHERE a~bukrs EQ pa_bukrs AND
                   a~hkont IN ( SELECT saknr FROM skat
                       WHERE ( spras EQ 'EN' OR spras EQ 'E'  ) AND
                             ktopl EQ 'TSPC' ) AND
                   a~gjahr <= pa_date(4) AND
                   a~budat IN ra_budat AND
                   a~kunnr EQ t_zfarsoff_add-kunnr AND
                   a~umskz IN so_umskz AND
                   a~blart IN ('RV','ZA','DR') AND
                   c~vkorg EQ pa_bukrs AND
                   c~vtweg EQ '10' AND
                   c~vkbur EQ t_zfarsoff_add-zvkbur1 AND
                   c~spart EQ '00'.
    ENDIF.

    SORT t_itab1_add BY kunnr.
    SORT t_itab2_add BY kunnr.
    SORT t_zfarsoff_add BY kunnr.
    LOOP AT t_itab1_add INTO wa_itab.
      READ TABLE t_zfarsoff_add WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF pa_date LT t_zfarsoff_add-budat.
          IF t_zfarsoff_add-zvkbur IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur.
            APPEND wa_itab TO i_itab1.
          ENDIF.
        ELSE.
          IF t_zfarsoff_add-zvkbur1 IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur1.
            APPEND wa_itab TO i_itab1.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.

    LOOP AT t_itab2_add INTO wa_itab.
      READ TABLE t_zfarsoff_add WITH KEY kunnr = wa_itab-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF pa_date LT t_zfarsoff_add-budat.
          IF t_zfarsoff_add-zvkbur IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur.
            APPEND wa_itab TO i_itab2.
          ENDIF.
        ELSE.
          IF t_zfarsoff_add-zvkbur1 IN so_gsber.
            wa_itab-vkbur = t_zfarsoff_add-zvkbur1.
            APPEND wa_itab TO i_itab2.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_tambah_kunnr_itab

*&---------------------------------------------------------------------*
*&      Form  f_reclas
*&---------------------------------------------------------------------*
FORM f_reclas  TABLES lt_itab STRUCTURE zf25b.
  DATA: BEGIN OF lt_kunnr OCCURS 0,
          kunnr LIKE bsid-kunnr.
  DATA: END OF lt_kunnr.
  DATA: ld_char(12)  VALUE '0000000000',
        ld_char1(50),
        ld_len       TYPE i,
        ld_subrc     LIKE sy-subrc,
        ld_ztag1     LIKE t052-ztag1.

  LOOP AT lt_itab.
    lt_kunnr-kunnr  = lt_itab-kunnr.
    APPEND lt_kunnr.
  ENDLOOP.

  SORT lt_kunnr BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_kunnr COMPARING kunnr.

  IF lt_kunnr[] IS NOT INITIAL.
    SELECT kunnr vkorg vtweg spart parvw kunn2 pernr
    FROM knvp
    INTO CORRESPONDING FIELDS OF TABLE t_routelist
    FOR ALL ENTRIES IN lt_kunnr
    WHERE kunnr EQ lt_kunnr-kunnr AND
          parvw EQ 'ZC'.
    IF sy-subrc EQ 0.
      SELECT kunnr vkorg vtweg spart parvw kunn2 pernr
      FROM knvp
      INTO CORRESPONDING FIELDS OF TABLE t_salesman
      FOR ALL ENTRIES IN t_routelist
      WHERE kunnr EQ t_routelist-kunn2 AND
            parvw EQ 'ZP'.
    ENDIF.
  ENDIF.

  LOOP AT lt_itab.
    READ TABLE t_routelist WITH KEY kunnr = lt_itab-kunnr
                                    parvw = 'ZC'.
    IF sy-subrc EQ 0.
      CONCATENATE ld_char t_routelist-kunn2 INTO ld_char1.
      ld_len = strlen( ld_char1 ).
      ld_len = ld_len - 10.
      lt_itab-xref1  = ld_char1+ld_len(10).
      READ TABLE t_salesman WITH KEY kunnr = t_routelist-kunn2
                                     parvw = 'ZP'.
      IF sy-subrc EQ 0.
        CONCATENATE ld_char t_salesman-pernr INTO ld_char1.
        ld_len = strlen( ld_char1 ).
        ld_len = ld_len - 6.
        lt_itab-xref2  = ld_char1+ld_len(6).
      ELSE.
        CLEAR: lt_itab-xref2.
      ENDIF.
    ELSE.
      CLEAR: lt_itab-xref1, lt_itab-xref2.
    ENDIF.
    MODIFY lt_itab TRANSPORTING xref1 xref2.
  ENDLOOP.
ENDFORM.                    " f_reclas

*&---------------------------------------------------------------------*
*&      Form  F_DSO_BILLING_TYPE
*&---------------------------------------------------------------------*
FORM f_dso_billing_type TABLES    ft_itab STRUCTURE zf25b.
  DATA : lv_vbeln TYPE zsl_hsales-vbeln,
         lv_zuonr TYPE bsid-zuonr.

  DATA : BEGIN OF lt_key OCCURS 0,
           vbeln TYPE zsl_hsales-vbeln,
           kunnr TYPE zsl_hsales-kunnr,
         END OF lt_key.

  DATA : lt_itab       TYPE STANDARD TABLE OF ty_itab INITIAL SIZE 0
                        WITH HEADER LINE,
         ls_itab       TYPE ty_itab,
         lt_temp       TYPE STANDARD TABLE OF ty_itab INITIAL SIZE 0
                        WITH HEADER LINE,
         ls_temp       TYPE ty_itab,
         lt_vbrk       TYPE STANDARD TABLE OF vbrk INITIAL SIZE 0
                        WITH HEADER LINE,
         ls_vbrk       TYPE vbrk,
         lt_bsad       TYPE STANDARD TABLE OF bsad INITIAL SIZE 0
                        WITH HEADER LINE,
         ls_bsad       TYPE bsad,
         lt_zsl_hsales TYPE STANDARD TABLE OF zsl_hsales INITIAL SIZE 0
                        WITH HEADER LINE,
         lt_zssutdt005 TYPE STANDARD TABLE OF zssutdt005 INITIAL SIZE 0
                        WITH HEADER LINE.

  lt_temp[] = lt_itab[] = ft_itab[].
  SORT lt_itab BY belnr.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING belnr.

  IF lt_itab[] IS NOT INITIAL.
    SELECT vbeln fkart
      FROM vbrk
      INTO CORRESPONDING FIELDS OF TABLE lt_vbrk
      FOR ALL ENTRIES IN lt_itab
      WHERE vbeln = lt_itab-belnr
        AND fkart IN so_fkart.
  ENDIF.

  CLEAR : lt_itab[], lt_itab.

  SORT ft_itab BY belnr.
  SORT lt_vbrk BY vbeln.
  LOOP AT ft_itab INTO ls_itab.
    CLEAR ls_vbrk.
    READ TABLE lt_vbrk INTO ls_vbrk WITH KEY vbeln = ls_itab-belnr
                                    BINARY SEARCH.
    IF sy-subrc = 0.
      ls_itab-fkart = ls_vbrk-fkart.
      MODIFY ft_itab FROM ls_itab TRANSPORTING fkart.
    ELSE.
      CLEAR : ls_temp, lv_zuonr.
      IF ls_itab-zuonr+10(1) = 'R'.
        lv_zuonr = ls_itab-zuonr(10).
      ELSE.
        lv_zuonr = ls_itab-zuonr.
      ENDIF.
      READ TABLE lt_temp INTO ls_temp WITH KEY zuonr = lv_zuonr
                                               blart = 'RV'.
      IF sy-subrc = 0.
        CLEAR ls_vbrk.
        READ TABLE lt_vbrk INTO ls_vbrk WITH KEY vbeln = ls_temp-belnr.
        IF sy-subrc = 0.
          ls_itab-fkart = ls_vbrk-fkart.
          MODIFY ft_itab FROM ls_itab TRANSPORTING fkart.
        ELSE.
        ENDIF.
      ELSE.
        APPEND ls_itab TO lt_itab.
      ENDIF.
    ENDIF.
    CLEAR ls_itab.
  ENDLOOP.

  IF lt_itab[] IS NOT INITIAL.
    SELECT belnr zuonr
      FROM bsad
      INTO CORRESPONDING FIELDS OF TABLE lt_bsad
      FOR ALL ENTRIES IN lt_itab
      WHERE bukrs = pa_bukrs
        AND kunnr = lt_itab-kunnr
        AND zuonr = lt_itab-zuonr
        AND blart = 'RV'.

    IF lt_bsad[] IS NOT INITIAL.
      CLEAR : lt_vbrk[], lt_vbrk.
      SELECT vbeln fkart
        FROM vbrk
        INTO CORRESPONDING FIELDS OF TABLE lt_vbrk
        FOR ALL ENTRIES IN lt_bsad
        WHERE vbeln = lt_bsad-belnr
          AND fkart IN so_fkart.

      LOOP AT ft_itab INTO ls_itab.
        IF ls_itab-fkart IS INITIAL.
          CLEAR ls_bsad.
          READ TABLE lt_bsad INTO ls_bsad WITH KEY zuonr = ls_itab-zuonr.
          IF sy-subrc = 0.
            CLEAR ls_vbrk.
            READ TABLE lt_vbrk INTO ls_vbrk WITH KEY vbeln = ls_bsad-belnr.
            IF sy-subrc = 0.
              ls_itab-fkart = ls_vbrk-fkart.
              MODIFY ft_itab FROM ls_itab TRANSPORTING fkart.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  CLEAR : ls_itab, lt_key[], lt_key.

  LOOP AT ft_itab INTO ls_itab.
    IF ft_itab-fkart IS INITIAL.
      lt_key-vbeln = ls_itab-zuonr.
      lt_key-kunnr = ls_itab-kunnr.
      APPEND lt_key.
    ENDIF.
  ENDLOOP.

  IF lt_key[] IS NOT INITIAL.
    IF pa_bukrs = '8020'.
      SELECT vbeln kunnr fkart
        FROM zsl_hsales
        INTO CORRESPONDING FIELDS OF TABLE lt_zsl_hsales
        FOR ALL ENTRIES IN lt_key
        WHERE vbeln = lt_key-vbeln
          AND kunnr = lt_key-kunnr.
    ELSEIF pa_bukrs = '8070'.
      SELECT vbeln kunnr fkart
        FROM zssutdt005
        INTO CORRESPONDING FIELDS OF TABLE lt_zssutdt005
        FOR ALL ENTRIES IN lt_key
        WHERE vbeln = lt_key-vbeln
          AND kunnr = lt_key-kunnr.
    ENDIF.
  ENDIF.

  CLEAR : ls_itab, lt_key[], lt_key.

  SORT ft_itab BY zuonr kunnr.
  SORT lt_zsl_hsales BY vbeln kunnr.
  SORT lt_zssutdt005 BY vbeln kunnr.

  LOOP AT ft_itab INTO ls_itab.
    IF ls_itab-fkart IS INITIAL.
      lv_vbeln  = ls_itab-zuonr.
      IF pa_bukrs = '8020'.
        CLEAR lt_zsl_hsales.
        READ TABLE lt_zsl_hsales WITH KEY vbeln = lv_vbeln
                                          kunnr = ls_itab-kunnr
                                 BINARY SEARCH.
        IF sy-subrc = 0.
          ls_itab-fkart = lt_zsl_hsales-fkart.
        ENDIF.
      ELSEIF pa_bukrs = '8070'.
        CLEAR lt_zssutdt005.
        READ TABLE lt_zssutdt005 WITH KEY vbeln = lv_vbeln
                                          kunnr = ls_itab-kunnr
                                 BINARY SEARCH.
        IF sy-subrc = 0.
          ls_itab-fkart = lt_zssutdt005-fkart.
        ENDIF.
      ENDIF.
      MODIFY ft_itab FROM ls_itab TRANSPORTING fkart.
    ENDIF.
  ENDLOOP.

  SORT ft_itab BY belnr.

  IF so_fkart[] IS NOT INITIAL.
    LOOP AT ft_itab.
      IF ft_itab-fkart IN so_fkart.
        CONTINUE.
      ELSE.
        DELETE ft_itab.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_DSO_BILLING_TYPE

*&---------------------------------------------------------------------*
*&      Form  F_INIT_KVGR3
*&---------------------------------------------------------------------*
FORM f_init_kvgr3 .
  CLEAR so_kvgr3.
  so_kvgr3-sign = 'I'.
  so_kvgr3-option = 'EQ'.
  so_kvgr3-low = '05T'.
  APPEND so_kvgr3. CLEAR so_kvgr3.
ENDFORM.                    " F_INIT_KVGR3
