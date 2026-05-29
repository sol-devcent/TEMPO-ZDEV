*----------------------------------------------------------------------*
*   INCLUDE ZKMMMM_R002F01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.

ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA : lt_makt  LIKE gt_s076 OCCURS 0 WITH HEADER LINE,
         lt_po    LIKE gt_s076 OCCURS 0 WITH HEADER LINE,
         t_mcinf  LIKE pbim-mcinf,
         t_vkorg  LIKE vapma-vkorg OCCURS 0 WITH HEADER LINE,
         t_trvog  LIKE vapma-trvog,
         lv_tname TYPE dd02d-dbtabname.

  DATA : BEGIN OF gt_marc OCCURS 0,
           werks TYPE werks_d,
           matnr TYPE matnr.
  DATA : END OF gt_marc.

  DATA : BEGIN OF ld_ebeln OCCURS 0,
           ebeln TYPE ebeln,
           ebelp TYPE ebelp.
  DATA : END OF ld_ebeln.

  DATA : lr_ekorg  TYPE RANGE OF ekorg WITH HEADER LINE,
         lr_bsart  TYPE RANGE OF bsart WITH HEADER LINE,
         lr_bedat  TYPE RANGE OF bedat,
         lr_bedat2 TYPE RANGE OF bedat,
         lr_line   LIKE LINE OF lr_bedat,
         ld_spmon  TYPE spmon,
         lr_ebeln  TYPE RANGE OF ebeln,
         wa_ebeln  LIKE LINE OF lr_ebeln,

         BEGIN OF t_pgmi OCCURS 0,
           prgrp TYPE pgmi-prgrp,
           nrmit TYPE pgmi-nrmit,
           werks TYPE pgmi-werks,
         END OF t_pgmi,

         t_pgmi2  LIKE t_pgmi OCCURS 0 WITH HEADER LINE,
         t_pgmi3  LIKE t_pgmi OCCURS 0,
         t_pgmi4  LIKE t_pgmi OCCURS 0,
         ld_subrc LIKE sy-subrc.

  SELECT prgrp nrmit werks
  FROM pgmi
  INTO TABLE t_pgmi
  WHERE pgtyp = ''        AND
        werks IN so_wenux AND
        wemit IN so_wenux AND
        prgrp IN so_pmnux.

  SORT t_pgmi BY prgrp.
  IF t_pgmi[] IS NOT INITIAL.
    LOOP AT t_pgmi.
      SELECT prgrp nrmit werks
        FROM pgmi AS a JOIN mara AS b ON a~nrmit = b~matnr
                                     AND b~mtart = 'ZPHA'
        APPENDING TABLE t_pgmi2
        WHERE pgtyp = ''        AND
              werks IN so_wenux AND
              wemit IN so_wenux AND
              prgrp = t_pgmi-prgrp AND
              nrmit = t_pgmi-nrmit.
      IF sy-subrc = 0.
        APPEND LINES OF t_pgmi2 TO t_pgmi4.
* Jika tidak ada berarti, bukan level produk
      ELSEIF sy-subrc <> 0.
        ld_subrc = 4.
        SELECT prgrp nrmit werks
        FROM pgmi
        APPENDING TABLE t_pgmi2
        WHERE pgtyp = ''        AND
              werks IN so_wenux AND
              wemit IN so_wenux AND
              prgrp = t_pgmi-nrmit.
        WHILE ld_subrc = 4.
          IF t_pgmi2[] IS NOT INITIAL.
            SELECT prgrp nrmit werks
            FROM pgmi
            INTO TABLE t_pgmi3
            FOR ALL ENTRIES IN t_pgmi2
            WHERE pgtyp = ''        AND
                  werks = t_pgmi2-werks AND
                  prgrp = t_pgmi2-nrmit.
          ENDIF.
          IF t_pgmi3[] IS NOT INITIAL.
            REFRESH t_pgmi2.
            SELECT prgrp nrmit werks
            FROM pgmi
            INTO TABLE t_pgmi2
            FOR ALL ENTRIES IN t_pgmi3
            WHERE pgtyp = ''        AND
                  werks = t_pgmi3-werks AND
                  prgrp = t_pgmi3-prgrp.
            IF sy-subrc = 0.
              t_pgmi2-prgrp = t_pgmi-prgrp.
              MODIFY t_pgmi2 FROM t_pgmi TRANSPORTING prgrp
              WHERE prgrp <> t_pgmi-prgrp.
              APPEND LINES OF t_pgmi2 TO t_pgmi4.
              ld_subrc = sy-subrc.
            ELSE.
              t_pgmi2[] = t_pgmi3[].
            ENDIF.
          ELSE.
            t_pgmi2-prgrp = t_pgmi-prgrp.
            MODIFY t_pgmi2 FROM t_pgmi TRANSPORTING prgrp
            WHERE prgrp <> t_pgmi-prgrp.
            APPEND LINES OF t_pgmi2 TO t_pgmi4.
            ld_subrc = 0.
          ENDIF.
        ENDWHILE.
      ENDIF.
    ENDLOOP.
  ENDIF.

*-------------------------------------------------------------*
  IF so_wenux-low NE '3603'.
    SELECT werks marc~matnr
      FROM marc JOIN mara ON marc~matnr EQ mara~matnr
      INTO TABLE gt_marc
      WHERE mtart EQ 'ZPHA'
        AND marc~matnr IN so_pmnux
        AND werks IN so_wenux.

    SELECT werks marc~matnr
      FROM marc JOIN mara ON marc~matnr EQ mara~matnr
      APPENDING TABLE gt_marc
      WHERE mtart EQ 'ZCGB'
        AND marc~matnr IN so_pmnux
        AND werks IN so_wenux.
  ELSE.
    SELECT werks marc~matnr
      FROM marc JOIN mara ON marc~matnr EQ mara~matnr
      INTO TABLE gt_marc
      WHERE mtart EQ 'ZSFG'
        AND marc~matnr IN so_pmnux
        AND werks IN so_wenux.
  ENDIF.

  IF t_pgmi4[] IS INITIAL.
    LOOP AT t_pgmi.
      gt_marc-werks = t_pgmi-werks.
      gt_marc-matnr = t_pgmi-nrmit.
      APPEND gt_marc.
    ENDLOOP.
  ELSE.
    LOOP AT t_pgmi4 INTO t_pgmi.
      gt_marc-werks = t_pgmi-werks.
      gt_marc-matnr = t_pgmi-nrmit.
      APPEND gt_marc.
    ENDLOOP.
  ENDIF.

  SORT gt_marc BY werks matnr.
  DELETE ADJACENT DUPLICATES FROM gt_marc COMPARING werks matnr.

  ld_spmon = pa_spmon.
  CHECK gt_marc[] IS NOT INITIAL.

  IF '2300' IN so_wenux.
    t_mcinf = 'S808'.
  ELSEIF '3302'IN so_wenux.
    t_mcinf = 'S803'.
  ELSE.
    t_mcinf = 'S076'.
    IF '3600' IN so_wenux OR
       '3603' IN so_wenux.
      lv_tname  = 'S933'.
    ENDIF.
  ENDIF.

*  SELECT vrsio spmon pmnux wenux absat produ
  SELECT vrsio spmon pmnux wenux absat produ
    FROM (t_mcinf)
    INTO TABLE gt_s076
    FOR ALL ENTRIES IN gt_marc
    WHERE ssour EQ space
      AND vrsio EQ ld_spmon+3(3)
      AND spmon EQ ld_spmon
      AND sptag EQ '00000000'
      AND spwoc EQ '000000'
      AND spbup EQ '000000'
      AND pmnux = gt_marc-matnr
      AND wenux = gt_marc-werks.

* Kalau versi untuk bulan tsb tidak ada, maka ambil versi bulan sebelumnya
  IF sy-subrc <> 0.
    ld_spmon = ld_spmon - 1.
    IF ld_spmon+4(2) = '00'.
      ld_spmon(4) = ld_spmon(4) - 1.
      ld_spmon+4(2) = 12.
    ENDIF.
    SELECT vrsio spmon pmnux wenux absat produ
      FROM (t_mcinf)
      INTO TABLE gt_s076
      FOR ALL ENTRIES IN gt_marc
      WHERE ssour EQ space
        AND vrsio EQ ld_spmon+3(3)
        AND spmon EQ pa_spmon
        AND sptag EQ '00000000'
        AND spwoc EQ '000000'
        AND spbup EQ '000000'
        AND pmnux = gt_marc-matnr
        AND wenux = gt_marc-werks.
  ENDIF.

* Compare to MARC, if there are missing records
  SORT gt_s076 BY vrsio spmon pmnux wenux.
  LOOP AT gt_marc.
    READ TABLE gt_s076 WITH KEY vrsio = ld_spmon+3(3)
                                spmon = pa_spmon
                                pmnux = gt_marc-matnr
                                wenux = gt_marc-werks
    BINARY SEARCH.
    IF sy-subrc <> 0.
      gt_rofo-vrsio = ld_spmon+3(3).
      gt_rofo-spmon = pa_spmon.
      gt_rofo-pmnux = gt_marc-matnr.
      gt_rofo-wenux = gt_marc-werks.
      APPEND gt_rofo.
    ENDIF.
  ENDLOOP.

  APPEND LINES OF gt_rofo TO gt_s076.
  REFRESH gt_rofo[].

  DO 6 TIMES.
    ld_spmon = ld_spmon - 1.
    IF ld_spmon+4(2) = '00'.
      ld_spmon(4) = ld_spmon(4) - 1.
      ld_spmon+4(2) = 12.
    ENDIF.
    SELECT vrsio spmon pmnux wenux absat produ
      FROM (t_mcinf)
      APPENDING TABLE gt_rofo
      FOR ALL ENTRIES IN gt_marc
      WHERE ssour EQ space
        AND vrsio EQ ld_spmon+3(3)
        AND spmon EQ pa_spmon
        AND sptag EQ '00000000'
        AND spwoc EQ '000000'
        AND spbup EQ '000000'
        AND pmnux = gt_marc-matnr
        AND wenux = gt_marc-werks.
  ENDDO.

  IF gt_s076[] IS INITIAL.
    LOOP AT gt_marc.
      gt_s076-vrsio = pa_spmon+3(3).
      gt_s076-spmon = pa_spmon.
      gt_s076-pmnux = gt_marc-matnr.
      gt_s076-wenux = gt_marc-werks.
      APPEND gt_s076.
    ENDLOOP.
  ENDIF.

  CHECK gt_s076[] IS NOT INITIAL.

  lt_makt[] = gt_s076[].
  SORT lt_makt BY pmnux.
  DELETE ADJACENT DUPLICATES FROM lt_makt COMPARING pmnux.

  SELECT makt~matnr maktx meins
    FROM makt JOIN mara ON makt~matnr EQ mara~matnr
    INTO TABLE gt_makt
    FOR ALL ENTRIES IN lt_makt
    WHERE makt~matnr EQ lt_makt-pmnux
      AND spras EQ sy-langu.

  lt_po[] = gt_s076[].
  SORT lt_po BY pmnux wenux.
  DELETE ADJACENT DUPLICATES FROM lt_po COMPARING pmnux wenux.

  CONCATENATE pa_spmon '01' INTO lr_line-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lr_line-low
    IMPORTING
      last_day_of_month = lr_line-high
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  lr_line-sign    = 'I'.
  lr_line-option  = 'BT'.

* Ambil data PO yang dibuat 2 bulan ke belakang
  ld_spmon = pa_spmon - 1.
  IF ld_spmon+4(2) = '00'.
    ld_spmon(4) = ld_spmon(4) - 1.
    ld_spmon+4(2) = 12.
  ENDIF.

  CONCATENATE ld_spmon '01' INTO lr_line-low.
  APPEND lr_line TO lr_bedat.

  "Get Ramges lr_ekorg
  lr_ekorg-sign = 'I'.
  lr_ekorg-option = 'EQ'.
  lr_ekorg-low = 'FAC'.
  APPEND lr_ekorg.
  lr_ekorg-low = 'SOM'.
  APPEND lr_ekorg.
  lr_ekorg-low = 'RXF'.
  APPEND lr_ekorg.
  lr_ekorg-low = 'BCL'.
  APPEND lr_ekorg.
  lr_ekorg-low = 'TDN'.
  APPEND lr_ekorg.

  "Get Ranges BSART.
  lr_bsart-sign = 'I'.
  lr_bsart-option = 'EQ'.
  lr_bsart-low = 'ZB'.
  APPEND lr_bsart.
  lr_bsart-low = 'ZSUB'.
  APPEND lr_bsart.
  lr_bsart-low = 'ZICO'.
  APPEND lr_bsart.
  lr_bsart-low = 'ZRF'.
  APPEND lr_bsart.
  IF '3603' IN so_wenux.
    lr_bsart-low = 'ZUB'.
    APPEND lr_bsart.
  ENDIF.

  SELECT ebeln
    FROM ekko
    INTO TABLE ld_ebeln
    WHERE reswk IN so_wenux
*      AND ekorg IN ('FAC','SOM','RXF','BCL','TDN')
      AND ekorg IN lr_ekorg
      AND ekko~bstyp EQ 'F'
*      AND bsart IN ('ZB','ZSUB','ZICO','ZRF')
      AND bsart IN lr_bsart
      AND bedat IN lr_bedat.

  LOOP AT ld_ebeln.
    wa_ebeln-sign    = 'I'.
    wa_ebeln-option  = 'EQ'.
    wa_ebeln-low   = ld_ebeln-ebeln.
    APPEND wa_ebeln TO lr_ebeln.
  ENDLOOP.

* Cek Delivery date
  REFRESH lr_bedat.
  CONCATENATE pa_spmon '01' INTO lr_line-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lr_line-low
    IMPORTING
      last_day_of_month = lr_line-high
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  lr_line-sign    = 'I'.
  lr_line-option  = 'BT'.
  APPEND lr_line TO lr_bedat.

  IF lr_ebeln IS NOT INITIAL.

*replace SOH Adj 20240807
**    SELECT ebeln ebelp
**      FROM eket
**      INTO TABLE ld_ebeln
**      WHERE ebeln IN lr_ebeln
**        AND eindt IN lr_bedat.
    IF ld_ebeln[] IS NOT INITIAL.
      SORT ld_ebeln BY ebeln.
      SELECT ebeln, ebelp
        FROM eket
        INTO TABLE @DATA(lt_ebeln)
        FOR ALL ENTRIES IN @ld_ebeln
        WHERE ebeln EQ @ld_ebeln-ebeln
          AND eindt IN @lr_bedat.
      IF lt_ebeln[] IS NOT INITIAL.
        ld_ebeln[] = lt_ebeln[].
      ENDIF.
    ENDIF.
*end replaceSOH Adj 20240807

    REFRESH lr_ebeln.
    SORT ld_ebeln BY ebeln.
*  DELETE ADJACENT DUPLICATES FROM ld_ebeln COMPARING ebeln.
    LOOP AT ld_ebeln.
      wa_ebeln-sign    = 'I'.
      wa_ebeln-option  = 'EQ'.
      wa_ebeln-low   = ld_ebeln-ebeln.
      APPEND wa_ebeln TO lr_ebeln.
    ENDLOOP.
    SORT lr_ebeln BY low.
    DELETE ADJACENT DUPLICATES FROM lr_ebeln COMPARING low.

*  IF so_pmnux IS INITIAL.
    IF lr_ebeln[] IS NOT INITIAL.
      SELECT ekpo~ebeln ekpo~ebelp matnr reswk eket~menge
        FROM ekpo JOIN ekko ON ekpo~ebeln EQ ekko~ebeln
                  JOIN eket ON eket~ebeln EQ ekko~ebeln AND
                               eket~ebelp EQ ekpo~ebelp
        INTO CORRESPONDING FIELDS OF TABLE gt_po
        FOR ALL ENTRIES IN ld_ebeln
        WHERE ekpo~ebeln = ld_ebeln-ebeln
          AND ekpo~ebelp = ld_ebeln-ebelp
          AND ekpo~loekz EQ space.
    ENDIF.
*  ELSE.
*  SELECT ekpo~ebeln matnr reswk eket~menge
*    FROM ekpo JOIN ekko ON ekpo~ebeln EQ ekko~ebeln
*              JOIN eket ON eket~ebeln EQ ekko~ebeln and
*                           eket~ebelp EQ ekpo~ebelp
*    INTO TABLE gt_po
*    FOR ALL ENTRIES IN lt_po
*    WHERE matnr EQ lt_po-pmnux
**      AND werks NE space
*      AND ekpo~loekz EQ space
**      AND reswk EQ lt_po-wenux
**      AND ekorg IN ('FAC','SOM')
**      AND ekpo~bstyp EQ 'F'
**      AND bsart IN ('ZB','ZSUB')
**      AND eindt IN lr_bedat.
*      AND ekpo~ebeln IN lr_ebeln.
*  ENDIF.
  ENDIF.

  IF '0101' IN so_wenux OR '0102' IN so_wenux.
    t_vkorg = '8010'. APPEND t_vkorg.
  ENDIF.

  IF '0901' IN so_wenux.
    t_vkorg = '8090'. APPEND t_vkorg.
  ENDIF.

  IF '2300' IN so_wenux.
    t_vkorg = '8230'. APPEND t_vkorg.
  ENDIF.

  LOOP AT t_vkorg.
    t_trvog = '0'.
    SELECT vbap~vbeln vbap~matnr vbap~werks vbap~kwmeng
      FROM vapma JOIN vbap ON vapma~vbeln EQ vbap~vbeln AND
                              vapma~posnr EQ vbap~posnr
      APPENDING TABLE gt_po
      FOR ALL ENTRIES IN lt_po
      WHERE vapma~matnr EQ lt_po-pmnux
        AND vapma~vkorg EQ t_vkorg
        AND vapma~trvog EQ t_trvog
        AND vapma~audat IN lr_bedat
        AND vapma~werks IN so_wenux.
* additional for ER product using SA
    IF t_vkorg ='8230'.
      t_trvog = '3'.
      REFRESH lr_bedat.
      CONCATENATE pa_spmon '01' INTO lr_line-low.
      CALL FUNCTION 'LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = lr_line-low
        IMPORTING
          last_day_of_month = lr_line-high
        EXCEPTIONS
          day_in_no_date    = 1
          OTHERS            = 2.
      lr_line-sign    = 'I'.
      lr_line-option  = 'BT'.
      ld_spmon = pa_spmon.

      DO 2 TIMES.
*       Ambil data SO yang dibuat 2 bulan ke belakang
        ld_spmon = ld_spmon - 1.
        IF ld_spmon+4(2) = '00'.
          ld_spmon(4) = ld_spmon(4) - 1.
          ld_spmon+4(2) = 12.
        ENDIF.
      ENDDO.
      CONCATENATE ld_spmon '01' INTO lr_line-low.
      APPEND lr_line TO lr_bedat2.
      SELECT vbap~vbeln vbap~matnr vbap~werks vbap~zmeng
        FROM vapma JOIN vbap ON vapma~vbeln EQ vbap~vbeln AND
                                vapma~posnr EQ vbap~posnr
        APPENDING CORRESPONDING FIELDS OF TABLE gt_po
        FOR ALL ENTRIES IN lt_po
        WHERE vapma~matnr EQ lt_po-pmnux
          AND vapma~vkorg EQ t_vkorg
          AND vapma~trvog EQ t_trvog
          AND vapma~audat IN lr_bedat2
          AND vapma~werks IN so_wenux.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_po.
    gt_931-werks  = lt_po-wenux.
    gt_931-matnr  = lt_po-pmnux.
    gt_931-spmon  = pa_spmon.
    gt_039-werks  = lt_po-wenux.
    gt_039-matnr  = lt_po-pmnux.
    gt_039-spmon  = pa_spmon.
    PERFORM f_add_data USING : '3000' '321' 'S931',
                               '3000' '322' 'S931',
                               '3001' '321' 'S931',
                               '3001' '322' 'S931',
                               '3002' '321' 'S931',
                               '3002' '322' 'S931',
                               '2000' '321' 'S931',
                               '2000' '322' 'S931',
                               '2001' '321' 'S931',
                               '2001' '322' 'S931',
                               '2002' '321' 'S931',
                               '2002' '322' 'S931',
                               '2004' '321' 'S931',
                               '2004' '322' 'S931',
                               '2010' '321' 'S931',
                               '2010' '322' 'S931',
                               '2020' '321' 'S931',
                               '2020' '322' 'S931',

                               '3000' '341' 'S931',
                               '3000' '342' 'S931',
                               '3001' '341' 'S931',
                               '3001' '342' 'S931',
                               '3002' '341' 'S931',
                               '3002' '342' 'S931',
                               '2000' '341' 'S931',
                               '2000' '342' 'S931',
                               '2001' '341' 'S931',
                               '2001' '342' 'S931',
                               '2002' '341' 'S931',
                               '2002' '342' 'S931',
                               '2004' '341' 'S931',
                               '2004' '342' 'S931',
                               '2010' '341' 'S931',
                               '2010' '342' 'S931',
                               '2020' '341' 'S931',
                               '2020' '342' 'S931',

                               '3000' '645' 'S931',
                               '3001' '645' 'S931',
                               '3002' '645' 'S931',
                               '3003' '645' 'S931',
                               '3004' '645' 'S931',
                               '3005' '645' 'S931',
                               '3006' '645' 'S931',
                               '3007' '645' 'S931',
                               '3008' '645' 'S931',
                               '3009' '645' 'S931', '3010' '645' 'S931',
                               '3000' '646' 'S931',
                               '3001' '646' 'S931',
                               '3002' '646' 'S931',
                               '3003' '646' 'S931',
                               '3004' '646' 'S931',
                               '3005' '646' 'S931',
                               '3006' '646' 'S931',
                               '3007' '646' 'S931',
                               '3008' '646' 'S931',
                               '3009' '646' 'S931', '3010' '646' 'S931',
                               '3000' '907' 'S931',
                               '3001' '907' 'S931',
                               '3002' '907' 'S931',
                               '3003' '907' 'S931',
                               '3004' '907' 'S931', '3010' '907' 'S931',
                               '3000' '908' 'S931',
                               '3001' '908' 'S931',
                               '3002' '908' 'S931',
                               '3003' '908' 'S931',
                               '3004' '908' 'S931', '3010' '908' 'S931',
                               '3000' 'Z15' 'S931',
                               '3001' 'Z15' 'S931',
                               '3002' 'Z15' 'S931',
                               '3003' 'Z15' 'S931',
                               '3004' 'Z15' 'S931',
                               '3000' 'Z16' 'S931',
                               '3001' 'Z16' 'S931',
                               '3002' 'Z16' 'S931',
                               '3003' 'Z16' 'S931',
                               '3004' 'Z16' 'S931',
                               '3000' '928' 'S931',
                               '3001' '928' 'S931',
                               '3002' '928' 'S931',
                               '3000' '929' 'S931',
                               '3001' '929' 'S931',
                               '3002' '929' 'S931',
                               '3099' '949' 'S931',
                               '3099' '950' 'S931',
                               '2000' '101' 'S931',
                               '2000' '102' 'S931',
                               '2001' '101' 'S931',
                               '2001' '102' 'S931',
                               '2002' '101' 'S931',
                               '2002' '102' 'S931',
                               '2004' '101' 'S931',
                               '2004' '102' 'S931',
                               '2010' '101' 'S931',
                               '2010' '101' 'S931',
                               '2020' '102' 'S931',
                               '2020' '102' 'S931',

                               '2010' '102' 'S931',
                               '2020' '101' 'S931',
                               '3020' '321' 'S931',

                               '2300' '102' 'S931',
                               '2300' '101' 'S931',
                               '2300' '321' 'S931',
                               '2300' '322' 'S931',
                               '2300' '641' 'S931',
                               '2300' '642' 'S931',
                               '2300' '645' 'S931',
                               '2300' '646' 'S931',
                               '2300' '907' 'S931',
                               '2300' '908' 'S931',
                               '2300' 'Z15' 'S931',
                               '2300' 'Z16' 'S931',
                               '2300' '928' 'S931',
                               '2300' '929' 'S931',
                               '2300' '949' 'S931',
                               '2300' '950' 'S931',

                               '2310' '102' 'S931',
                               '2310' '101' 'S931',
                               '2310' '321' 'S931',
                               '2310' '322' 'S931',
                               '2310' '641' 'S931',
                               '2310' '642' 'S931',
                               '2310' '645' 'S931',
                               '2310' '646' 'S931',
                               '2310' '907' 'S931',
                               '2310' '908' 'S931',
                               '2310' 'Z15' 'S931',
                               '2310' 'Z16' 'S931',
                               '2310' '928' 'S931',
                               '2310' '929' 'S931',
                               '2310' '949' 'S931',
                               '2310' '950' 'S931',

                               '3006' '101' 'S931',
                               '3006' '102' 'S931',

                               '3000' '' 'S039',
                               '3001' '' 'S039',
                               '3002' '' 'S039',
                               '3003' '' 'S039',
                               '3004' '' 'S039',
                               '3010' '' 'S039',
                               '3020' '' 'S039',
                               '2000' '' 'S039',
                               '2001' '' 'S039',
                               '2002' '' 'S039',
                               '2003' '' 'S039',
                               '2010' '' 'S039',
                               '2020' '' 'S039',
                               '2300' '' 'S039',
                               '2310' '' 'S039'.

    PERFORM f_s933_key USING : pa_spmon lt_po-wenux lt_po-pmnux '101',
*                               pa_spmon lt_po-wenux lt_po-pmnux '342',
                               pa_spmon lt_po-wenux lt_po-pmnux '321',
                               pa_spmon lt_po-wenux lt_po-pmnux '322'.
  ENDLOOP.

  PERFORM f_s931 TABLES gt_931.

  PERFORM f_mardh  TABLES gt_039 gt_mardh gt_mardh_qi_uu
                   USING pa_spmon.

  IF lv_tname IS NOT INITIAL.
    PERFORM f_s933 USING lv_tname.
  ENDIF.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  PERFORM f_alv TABLES gt_out.
ENDFORM.                    "F_PRINT_DATA

*---------------------------------------------------------------------*
*       FORM F_ALV
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

*  IF pa_grid IS NOT INITIAL.
  lv_func    = 'REUSE_ALV_GRID_DISPLAY'.
  lv_title   = sy-title.
*  ELSE.
*    PERFORM f_build_event       TABLES  t_alv_event[].
*    lv_func    = 'REUSE_ALV_LIST_DISPLAY'.
*  ENDIF.

  CALL FUNCTION lv_func
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      i_grid_title             = lv_title
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
      it_sort                  = t_alv_isort[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      is_print                 = d_print
    TABLES
      t_outtab                 = ft_report
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    "F_ALV

*---------------------------------------------------------------------*
*       FORM F_FIELDCAT
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.

  CASE 'X'.
    WHEN butt2.
      PERFORM f_fieldcatg USING ft_report:
        'WENUX' 'S076' 'WENUX' '' '' 'Plant' '' '' '' '' '' '' '' '' ''
        'C410' '' 'X',
        'PMNUX' 'S076' 'PMNUX' '' '' 'Product' '' '' '' '' '' '' '' '' ''
        'C410' '' 'X',
        'MAKTX' 'MAKT' 'MAKTX' '' '' 'Product Description' '' '' '' '' ''
        '' '' '' '' 'C410' '' 'X',
        'SPMON' 'S076' 'SPMON' '' '' 'Bulan' '' '' '' '' '' '' '' '' '' 'C410'
        '' 'X',
        'MENGE' '' '' '' '15' 'PO' '' '' '' '' '' '' 'MEINS' '' '' '' '' '',
        'TOTAL' '' '' '' '15' 'Production (Sloc 2300/2310) ' '' '' '' '' '' '' 'MEINS'
        '' '' '' '' '',
        'PRODU' '' '' '' '25' 'Production (QC Passed)' '' '' '' '' '' ''
        'MEINS' '' '' '' '' '',
        'DELIV' '' '' '' '15' 'Delivery' '' '' '' '' '' '' 'MEINS' '' '' ''
        '' '',
        'END2300' '' '' '' '24' 'End Stock (SLoc 2300)' '' '' '' '' '' ''
        'MEINS' '' '' '' '' '',
        'END2310' '' '' '' '24' 'End Stock (SLoc 2310)' '' '' '' '' '' ''
        'MEINS' '' '' '' '' '',
        'OUTST' '' '' '' '15' 'Outstanding PO' '' '' '' '' '' '' 'MEINS' ''
        '' '' '' '',
        'MEINS' 'MARA' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.

    WHEN butt1.
      PERFORM f_fieldcatg USING ft_report:
        'WENUX' 'S076' 'WENUX' '' '' 'Plant' '' '' '' '' '' '' '' '' ''
        'C410' '' 'X',
        'PMNUX' 'S076' 'PMNUX' '' '' 'Product' '' '' '' '' '' '' '' '' ''
        'C410' '' 'X',
        'MAKTX' 'MAKT' 'MAKTX' '' '' 'Product Description' '' '' '' '' ''
        '' '' '' '' 'C410' '' 'X',
        'SPMON' 'S076' 'SPMON' '' '' 'Bulan' '' '' '' '' '' '' '' '' '' 'C410'
        '' 'X',
        'ROFO6' '' '' '' '15' 'ROFO N-6' '' '' '' '' '' '' 'MEINS' '' '' '' '' '',
        'ROFO5' '' '' '' '15' 'ROFO N-5' '' '' '' '' '' '' 'MEINS' '' '' '' '' '',
        'ROFO4' '' '' '' '15' 'ROFO N-4' '' '' '' '' '' '' 'MEINS' '' '' '' '' '',
        'ROFO3' '' '' '' '15' 'ROFO N-3' '' '' '' '' '' '' 'MEINS' '' '' '' '' '',
        'ROFO2' '' '' '' '15' 'ROFO N-2' '' '' '' '' '' '' 'MEINS' '' '' '' '' '',
        'ROFO1' '' '' '' '15' 'ROFO N-1' '' '' '' '' '' '' 'MEINS' '' '' '' '' '',
        'ABSAT' '' '' '' '15' 'ROFO' '' '' '' '' '' '' 'MEINS' '' '' '' '' '',
        'MENGE' '' '' '' '15' 'PO' '' '' '' '' '' '' 'MEINS' '' '' '' '' '',
        'TOTAL' '' '' '' '15' 'Production (Sloc 2000) ' '' '' '' '' '' '' 'MEINS'
        '' '' '' '' '',
        'SUBCON' '' '' '' '15' 'GR Sub.Cont.' '' '' '' '' '' '' 'MEINS'
        '' '' '' '' '',
        'PRODU' '' '' '' '25' 'Production (QC Passed)' '' '' '' '' '' ''
        'MEINS' '' '' '' '' '',
        'DELIV' '' '' '' '15' 'Delivery' '' '' '' '' '' '' 'MEINS' '' '' ''
        '' '',
        'END20' '' '' '' '24'
        'End Stock (SLoc 2000/2001/2002)' '' '' '' '' '' ''
        'MEINS' '' '' '' '' '',
        'LABST' '' '' '' '24' 'End Stock UU (Sloc 2000/2001/2002)' '' '' '' '' '' ''
        'MEINS' '' '' '' '' '',
        'INSME' '' '' '' '24' 'End Stock QI (Sloc 2000/2001/2002)' '' '' '' '' '' ''
        'MEINS' '' '' '' '' '',
        'END30' '' '' '' '24'
        'End Stock (SLoc 3000/3001/3002/3003/3004/3099)' '' '' '' '' '' ''
        'MEINS' '' '' '' '' '',

        'END20X' '' '' '' '24'
        'End Stock (SLoc 2020)' '' '' '' '' '' ''
        'MEINS' '' '' '' '' '',
        'END30X' '' '' '' '24'
        'End Stock (SLoc 3020)' '' '' '' '' '' ''
        'MEINS' '' '' '' '' '',

        'END2010' '' '' '' '24' 'End Stock (SLoc 2010)' '' '' '' '' '' ''
        'MEINS' '' '' '' '' '',
        'END3010' '' '' '' '24' 'End Stock (SLoc 3010)' '' '' '' '' '' ''
        'MEINS' '' '' '' '' '',

        'GR3006' '' '' '' '24' 'GR (SLoc 3006)' '' '' '' '' '' ''
        'MEINS' '' '' '' '' '',

        'OUTST' '' '' '' '15' 'Outstanding PO' '' '' '' '' '' '' 'MEINS' ''
        '' '' '' '',
        'MEINS' 'MARA' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*&  Emphasize
*&  - 1st char = C (color property)
*&  - 2nd char = color code (from 0 to 7)
*&    0 = background color
*&    1 = blue
*&    2 = gray
*&    3 = yellow
*&    4 = blue/gray
*&    5 = green
*&    6 = red
*&    7 = orange
*&  - 3rd char = intensified (0=off, 1=on)
*&  - 4th char = inverse display (0=off, 1=on)
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    VALUE(fu_types)
                          VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_fltxt)
                          VALUE(fu_dosum)
                          VALUE(fu_hotsp)
                          VALUE(fu_dec)
                          VALUE(fu_waers)
                          VALUE(fu_meins)
                          VALUE(fu_waers_f)
                          VALUE(fu_meins_f)
                          VALUE(fu_checkbox)
                          VALUE(fu_input)
                          VALUE(fu_emphasize)
                          VALUE(fu_just)
                          VALUE(fu_fix).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_tabname       = fu_reftb.
  ld_fieldcat-ref_fieldname     = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-seltext_l         = fu_fltxt.
  ld_fieldcat-seltext_m         = fu_fltxt.
  ld_fieldcat-seltext_s         = fu_fltxt.
  ld_fieldcat-reptext_ddic      = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_out      = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-input             = fu_input.
  ld_fieldcat-emphasize         = fu_emphasize.
  ld_fieldcat-just              = fu_just.
  ld_fieldcat-fix_column        = fu_fix.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.                    "F_BUILD_EVENT

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT_EXIT
*---------------------------------------------------------------------*
FORM f_build_event_exit.
  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.
ENDFORM.                    "F_BUILD_EVENT_EXIT

*---------------------------------------------------------------------*
*       FORM F_BUILD_LAYOUT
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
*  fu_layout-box_fieldname      = 'CHECK'.
ENDFORM.                    "F_BUILD_LAYOUT

*---------------------------------------------------------------------*
*       FORM F_BUILD_PRINT
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "F_BUILD_PRINT

*---------------------------------------------------------------------*
*       FORM F_BUILD_SORTFIELD
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'PMNUX'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.                    "F_BUILD_SORTFIELD

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM f_top_of_page.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.
ENDFORM.                    "F_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory.
* here free all the internal table used in the program.
  CLEAR: gt_out, gt_out[].
ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ALV_DATA
*&---------------------------------------------------------------------*
FORM f_clear_alv_data.
  CLEAR:t_alv_fieldcat,
        t_alv_event,
        t_events,
        t_alv_isort,
        t_alv_filter,
        t_event_exit,
        d_alv_isort,
        d_alv_variant,
        d_alv_list_scroll,
        d_alv_sort_postn,
        d_alv_keyinfo,
        d_alv_fieldcat,
        d_alv_formname,
        d_alv_ucomm,
        d_alv_print,
        d_alv_repid,
        d_alv_tabix,
        d_alv_subrc,
        d_alv_screen_start_column,
        d_alv_screen_start_line,
        d_alv_screen_end_column,
        d_alv_screen_end_line,
        d_alv_layout,
        d_layout,
        d_repid,
        d_print.

  REFRESH: t_alv_fieldcat,
           t_alv_event,
           t_events,
           t_alv_isort,
           t_alv_filter,
           t_event_exit.

  d_repid = sy-repid.
ENDFORM.                    " F_CLEAR_ALV_DATA

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM F_GUI_MESSAGE
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "F_GUI_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
FORM f_alv_variant_exist USING     fu_vari
                         CHANGING  fc_alv_variant STRUCTURE disvariant.
  IF NOT fu_vari IS INITIAL.
    MOVE fu_vari TO fc_alv_variant-variant.
    fc_alv_variant-report = d_repid.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save        = 'A'
      CHANGING
        cs_variant    = fc_alv_variant
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      IF NOT sy-msgid IS INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR fc_alv_variant.
    fc_alv_variant-report = sy-repid.
  ENDIF.
ENDFORM.                    " F_ALV_VARIANT_EXIST

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data.
  DATA : lr_produ      TYPE RANGE OF bwart,
         lr_deliv      TYPE RANGE OF bwart,
         lr_total      TYPE RANGE OF bwart,
         ld_spmon      TYPE spmon,
         lv_absatc(20),
         lv_menge      TYPE mc_meng,
         lt_s933       TYPE STANDARD TABLE OF s933,
         ls_s933       LIKE LINE OF gt_s933,
         lv_charg      TYPE s933-charg.

  PERFORM f_bwart USING '321' '322'
                  CHANGING lr_produ[].
  PERFORM f_bwart USING '341' '342'
                  CHANGING lr_produ[].

  PERFORM f_bwart USING '645' '646'
                  CHANGING lr_deliv[].
  PERFORM f_bwart USING '907' '908'
                  CHANGING lr_deliv[].
  PERFORM f_bwart USING 'Z15' 'Z16'
                  CHANGING lr_deliv[].
  PERFORM f_bwart USING '928' '929'
                  CHANGING lr_deliv[].
  PERFORM f_bwart USING '949' '950'
                  CHANGING lr_deliv[].
  IF '3603' IN so_wenux.
    PERFORM f_bwart USING '641' '642'
                    CHANGING lr_deliv[].
  ENDIF.

  PERFORM f_bwart USING '101' '102'
                  CHANGING lr_total[].

  PERFORM f_resum_s076.

  SORT gt_s076 BY wenux pmnux.
  SORT gt_rofo BY pmnux wenux spmon vrsio.
  SORT gt_makt BY matnr.
  SORT gt_po BY matnr reswk.

  lt_s933[] = gt_s933[].
  SORT lt_s933 BY werks matnr bwart charg.
  DELETE ADJACENT DUPLICATES FROM lt_s933 COMPARING werks matnr bwart charg.

  LOOP AT gt_s076.
    gt_out-wenux  = gt_s076-wenux.
    gt_out-pmnux  = gt_s076-pmnux.
    ld_spmon = gt_s076-spmon.
* Jika ROFO bulan bersangkutan belum ada, ambil versi bulan sebelumnya
    IF gt_s076-vrsio <> gt_s076-spmon+3(3).
      ld_spmon = ld_spmon - 1.
      IF ld_spmon+4(2) = '00'.
        ld_spmon(4) = ld_spmon(4) - 1.
        ld_spmon+4(2) = '12'.
      ENDIF.
    ENDIF.

    ld_spmon = ld_spmon - 1.

    IF ld_spmon+4(2) = '00'.
      ld_spmon(4) = ld_spmon(4) - 1.
      ld_spmon+4(2) = '12'.
    ENDIF.
    READ TABLE gt_rofo WITH KEY pmnux = gt_s076-pmnux
                                wenux = gt_s076-wenux
                                spmon = gt_s076-spmon
                                vrsio = ld_spmon+3(3)
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      gt_out-rofo1 = gt_rofo-absat.
* If Revlon & Mahoni Product
      IF gt_s076-pmnux(2) = '80'.
        gt_out-rofo1 = gt_rofo-produ.
      ENDIF.
    ENDIF.

    ld_spmon = ld_spmon - 1.
    IF ld_spmon+4(2) = '00'.
      ld_spmon(4) = ld_spmon(4) - 1.
      ld_spmon+4(2) = '12'.
    ENDIF.
    READ TABLE gt_rofo WITH KEY pmnux = gt_s076-pmnux
                                wenux = gt_s076-wenux
                                spmon = gt_s076-spmon
                                vrsio = ld_spmon+3(3)
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      gt_out-rofo2 = gt_rofo-absat.
* If Revlon & Mahoni Product
      IF gt_s076-pmnux(2) = '80'.
        gt_out-rofo2 = gt_rofo-produ.
      ENDIF.
    ENDIF.

    ld_spmon = ld_spmon - 1.
    IF ld_spmon+4(2) = '00'.
      ld_spmon(4) = ld_spmon(4) - 1.
      ld_spmon+4(2) = '12'.
    ENDIF.
    READ TABLE gt_rofo WITH KEY pmnux = gt_s076-pmnux
                                wenux = gt_s076-wenux
                                spmon = gt_s076-spmon
                                vrsio = ld_spmon+3(3)
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      gt_out-rofo3 = gt_rofo-absat.
* If Revlon & Mahoni Product
      IF gt_s076-pmnux(2) = '80'.
        gt_out-rofo3 = gt_rofo-produ.
      ENDIF.
    ENDIF.

    ld_spmon = ld_spmon - 1.
    IF ld_spmon+4(2) = '00'.
      ld_spmon(4) = ld_spmon(4) - 1.
      ld_spmon+4(2) = '12'.
    ENDIF.
    READ TABLE gt_rofo WITH KEY pmnux = gt_s076-pmnux
                                wenux = gt_s076-wenux
                                spmon = gt_s076-spmon
                                vrsio = ld_spmon+3(3)
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      gt_out-rofo4 = gt_rofo-absat.
* If Revlon & Mahoni Product
      IF gt_s076-pmnux(2) = '80'.
        gt_out-rofo4 = gt_rofo-produ.
      ENDIF.
    ENDIF.

    ld_spmon = ld_spmon - 1.
    IF ld_spmon+4(2) = '00'.
      ld_spmon(4) = ld_spmon(4) - 1.
      ld_spmon+4(2) = '12'.
    ENDIF.
    READ TABLE gt_rofo WITH KEY pmnux = gt_s076-pmnux
                                wenux = gt_s076-wenux
                                spmon = gt_s076-spmon
                                vrsio = ld_spmon+3(3)
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      gt_out-rofo5 = gt_rofo-absat.
* If Revlon & Mahoni Product
      IF gt_s076-pmnux(2) = '80'.
        gt_out-rofo5 = gt_rofo-produ.
      ENDIF.
    ENDIF.

    ld_spmon = ld_spmon - 1.
    IF ld_spmon+4(2) = '00'.
      ld_spmon(4) = ld_spmon(4) - 1.
      ld_spmon+4(2) = '12'.
    ENDIF.
    READ TABLE gt_rofo WITH KEY pmnux = gt_s076-pmnux
                                wenux = gt_s076-wenux
                                spmon = gt_s076-spmon
                                vrsio = ld_spmon+3(3)
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      gt_out-rofo6 = gt_rofo-absat.
* If Revlon & Mahoni Product
      IF gt_s076-pmnux(2) = '80'.
        gt_out-rofo6 = gt_rofo-produ.
      ENDIF.
    ENDIF.

    READ TABLE gt_makt WITH KEY matnr = gt_s076-pmnux
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      gt_out-maktx  = gt_makt-maktx.
      gt_out-meins  = gt_makt-meins.
    ENDIF.

    gt_out-spmon  = pa_spmon.

    CLEAR lv_absatc.

* If Revlon & Mahoni Product
    IF gt_s076-pmnux(2) = '80'.
      CALL FUNCTION 'FLTP_CHAR_CONVERSION'
        EXPORTING
          decim = 0
          input = gt_s076-produ
        IMPORTING
          flstr = lv_absatc.
    ELSE.
      CALL FUNCTION 'FLTP_CHAR_CONVERSION'
        EXPORTING
          decim = 0
          input = gt_s076-absat
        IMPORTING
          flstr = lv_absatc.
    ENDIF.

    gt_out-absat = lv_absatc.


    LOOP AT gt_po WHERE matnr EQ gt_s076-pmnux
                    AND reswk EQ gt_s076-wenux.
      ADD gt_po-menge TO gt_out-menge.
    ENDLOOP.

    LOOP AT gt_s931 WHERE werks EQ gt_s076-wenux
                      AND matnr EQ gt_s076-pmnux.
      CLEAR lv_menge.

      IF gt_s931-bwart = '321' OR gt_s931-bwart = '322' OR
        gt_s931-bwart = '341' OR gt_s931-bwart = '342'.
        lv_menge = gt_s931-mzubb.
      ELSE.
        lv_menge = gt_s931-menge.
      ENDIF.

*      IF gt_s931-shkzg EQ 'H'.
*        lv_menge  = lv_menge * -1.
*      ENDIF.

      CASE gt_s931-lgort.
        WHEN '2001'.
          IF gt_s931-bwart IN lr_total.
            ADD lv_menge TO gt_out-subcon.
          ENDIF.

        WHEN '2000' OR '2002' OR '2004' OR '2010' OR '2020' OR
             '2300' OR '2310'.
          IF gt_s931-bwart IN lr_total.
            ADD lv_menge TO gt_out-total.
          ELSEIF gt_s931-bwart IN lr_produ.
            ADD lv_menge TO gt_out-produ.
          ELSEIF gt_s931-bwart IN lr_deliv.
            lv_menge = lv_menge * -1.
            ADD lv_menge TO gt_out-deliv.
          ENDIF.

*          IF gt_s931-lgort = '2020' AND
*            gt_s931-bwart = '101'.
*            ADD lv_menge TO gt_out-end20x.
*          ENDIF.

        WHEN '3000' OR '3001' OR '3002' OR '3003' OR '3004' OR
             '3005' OR '3006' OR '3007' OR '3008' OR '3009' OR
             '3099' OR '3010' OR '2300' OR '2310'.
          IF gt_s931-bwart IN lr_produ.
            ADD lv_menge TO gt_out-produ.
          ELSEIF gt_s931-bwart IN lr_deliv.
            lv_menge = lv_menge * -1.
            ADD lv_menge TO gt_out-deliv.
*            gt_out-deliv = gt_out-deliv * -1.
          ENDIF.

          CASE gt_s931-bwart.
            WHEN '101'.
              ADD lv_menge TO gt_out-gr3006.
            WHEN '102'.
              SUBTRACT lv_menge FROM gt_out-gr3006.
          ENDCASE.

*        WHEN '3020'.
*          IF gt_s931-bwart = '321'.
*            ADD lv_menge TO gt_out-end30x.
*          ENDIF.

      ENDCASE.
    ENDLOOP.

*    LOOP AT gt_s039 WHERE werks EQ gt_s076-wenux
*                      AND matnr EQ gt_s076-pmnux.
*      CASE gt_s039-lgort.
*        WHEN '2000'.
*          ADD gt_s039-gsbest TO gt_out-end20.
*        WHEN '3000'.
*          ADD gt_s039-gsbest TO gt_out-end30.
*      ENDCASE.
*    ENDLOOP.

    IF gt_out-wenux = '3600' OR gt_out-wenux = '3603'.
      CLEAR gt_out-produ.
      LOOP AT lt_s933 INTO ls_s933 WHERE werks = gt_out-wenux
                                     AND matnr = gt_out-pmnux
                                     AND bwart = '101'.
        lv_charg  = ls_s933-charg.
        LOOP AT gt_s933 INTO ls_s933 WHERE werks = gt_out-wenux
                                       AND matnr = gt_out-pmnux
*                                       AND bwart = '342'
                                       AND ( bwart = '321' OR bwart = '322' )
                                       AND charg = lv_charg.
*          ADD ls_s933-menge TO gt_out-produ.
          gt_out-produ = gt_out-produ + ( ls_s933-menge * -1 ).
        ENDLOOP.
        CLEAR lv_charg.
      ENDLOOP.
    ENDIF.

    LOOP AT gt_mardh WHERE werks EQ gt_s076-wenux
                       AND matnr EQ gt_s076-pmnux.
      CASE gt_mardh-lgort.
        WHEN '2000' OR '2001' OR '2002' OR '2003'.          "OR '2010'.
          ADD gt_mardh-insme TO gt_out-end20.
          ADD gt_mardh-einme TO gt_out-end20.
          ADD gt_mardh-labst TO gt_out-end20.
          ADD gt_mardh-labst TO gt_out-labst.
          ADD gt_mardh-insme TO gt_out-insme.
        WHEN '2020'.
          ADD gt_mardh-insme TO gt_out-end20x.
          ADD gt_mardh-einme TO gt_out-end20x.
          ADD gt_mardh-labst TO gt_out-end20x.
        WHEN '3000' OR '3001' OR '3002' OR '3003' OR '3004' OR '3099'.
          ADD gt_mardh-labst TO gt_out-end30.
          IF gt_mardh-werks = '3600'.
            ADD gt_mardh-insme TO gt_out-end30.
          ENDIF.
        WHEN '3020'.
          ADD gt_mardh-labst TO gt_out-end30x.
        WHEN '2010'.
          ADD gt_mardh-insme TO gt_out-end2010.
          ADD gt_mardh-labst TO gt_out-end2010.
        WHEN '2300'.
          ADD gt_mardh-insme TO gt_out-end2300.
          ADD gt_mardh-labst TO gt_out-end2300.
        WHEN '2310'.
          ADD gt_mardh-insme TO gt_out-end2310.
          ADD gt_mardh-labst TO gt_out-end2310.
        WHEN '3010'.
          ADD gt_mardh-insme TO gt_out-end3010.
          ADD gt_mardh-labst TO gt_out-end3010.
      ENDCASE.
    ENDLOOP.

    gt_out-outst  = gt_out-menge - gt_out-deliv.

*    LOOP AT gt_mardh_qi_uu WHERE werks EQ gt_s076-wenux
*                        AND matnr EQ gt_s076-pmnux
*                        AND lfgja = gt_s076-spmon(4)
*                        AND lfmon = gt_s076-spmon+4(2).
*      IF gt_mardh_qi_uu-lgort = '2000' OR gt_mardh_qi_uu-lgort = '2001' OR gt_mardh_qi_uu-lgort = '2002'.
*        ADD gt_mardh_qi_uu-labst TO  gt_out-labst.
*        ADD gt_mardh_qi_uu-insme TO gt_out-insme.
*      ENDIF.
*    ENDLOOP.


    APPEND gt_out.
    CLEAR gt_out.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries.

ENDFORM.                    " F_POST_ENTRIES

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
FORM f_f4_for_variant_alv CHANGING fc_variant.
  DATA: ld_variant LIKE disvariant.
  DATA: ld_repid   LIKE sy-repid.

  ld_repid = sy-repid.
  ld_variant-report   = ld_repid.
  ld_variant-username = sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = ld_variant
      i_save     = 'A'
    IMPORTING
      es_variant = ld_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    fc_variant = ld_variant-variant.
  ENDIF.
ENDFORM.                    " F_F4_FOR_VARIANT_ALV

*&---------------------------------------------------------------------*
*&      Form  F_GET_PARAMETERS
*&---------------------------------------------------------------------*
FORM f_get_parameters  USING    fu_value
                       CHANGING fc_value.
  CALL FUNCTION 'ACC_USER_PARAMETER_GET'
    EXPORTING
      i_param_id    = fu_value
    IMPORTING
      e_param_value = fc_value.
ENDFORM.                    " F_GET_PARAMETERS

*&---------------------------------------------------------------------*
*&      Form  F_ADD_DATA
*&---------------------------------------------------------------------*
FORM f_add_data  USING    fu_lgort fu_bwart fu_table.
  CASE fu_table.
    WHEN 'S931'.
      gt_931-lgort  = fu_lgort.
      gt_931-bwart  = fu_bwart.
      APPEND gt_931.
    WHEN 'S039'.
      gt_039-lgort  = fu_lgort.
      APPEND gt_039.
  ENDCASE.
ENDFORM.                    " F_ADD_DATA

*&---------------------------------------------------------------------*
*&      Form  F_S931
*&---------------------------------------------------------------------*
FORM f_s931  TABLES   ft_931 STRUCTURE gt_931.
  SELECT werks matnr shkzg spmon lgort bwart basme mzubb magbb menge
    FROM s931
    INTO TABLE gt_s931
    FOR ALL ENTRIES IN ft_931
    WHERE werks EQ ft_931-werks
      AND matnr EQ ft_931-matnr
      AND spmon EQ ft_931-spmon
      AND lgort EQ ft_931-lgort
      AND bwart EQ ft_931-bwart.
ENDFORM.                                                    " F_S931

*&---------------------------------------------------------------------*
*&      Form  F_mardh
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_039  text
*----------------------------------------------------------------------*
FORM f_mardh  TABLES   ft_039
                       ft_mardh
                       ft_mardh_qi_uu
                 USING p_spmon  LIKE s039-spmon.

  DATA : BEGIN OF lt_039 OCCURS 0,
           werks TYPE werks_d,
           matnr TYPE matnr,
           spmon TYPE spmon,
           lgort TYPE lgort_d.
  DATA : END OF lt_039.

  DATA : BEGIN OF lt_mardh OCCURS 0,
           werks TYPE werks_d,
           matnr TYPE matnr,
           lgort TYPE lgort_d,
           labst TYPE labst,
           insme TYPE insme,
           einme TYPE einme,
           lfgja TYPE lfgja,
           lfmon TYPE lfmon.
  DATA : END OF lt_mardh.
  DATA : wa_mardh LIKE lt_mardh.

  lt_039[] = ft_039[].
  IF p_spmon = sy-datum(6).
    SELECT werks matnr lgort labst insme einme
      FROM mard
      INTO TABLE lt_mardh
      FOR ALL ENTRIES IN lt_039
      WHERE werks EQ lt_039-werks
        AND matnr EQ lt_039-matnr
        AND lgort EQ lt_039-lgort.
  ELSE.
    SELECT werks matnr lgort labst insme einme lfgja lfmon
      FROM mardh
      INTO TABLE lt_mardh
      FOR ALL ENTRIES IN lt_039
      WHERE werks EQ lt_039-werks
        AND matnr EQ lt_039-matnr
        AND lgort EQ lt_039-lgort
        AND ( lfgja > p_spmon(4)
         OR lfgja = p_spmon(4) AND lfmon => p_spmon+4(2) ).
*        AND lfgja EQ ft_039-spmon(4)
*        AND lfmon EQ ft_039-spmon+4(2).

    SELECT werks matnr lgort labst insme einme lfgja lfmon
      FROM mard
      APPENDING TABLE lt_mardh
      FOR ALL ENTRIES IN lt_039
      WHERE werks EQ lt_039-werks
        AND matnr EQ lt_039-matnr
        AND lgort EQ lt_039-lgort
        AND ( lfgja < p_spmon(4)
         OR lfgja = p_spmon(4) AND lfmon <= p_spmon+4(2) ).
*        AND lfgja NE sy-datum(4)
*        AND lfmon NE sy-datum+4(2).

** For current selection year, delete older month data
*    Delete gt_mardh where lfgja = pa_spmon(4)
*                      and lfmon > pa_spmon+4(2).
** For other, delete older year data
*    Delete gt_mardh where lfgja > pa_spmon(4).

    SORT lt_mardh BY matnr werks lgort lfgja lfmon.
    CLEAR wa_mardh.
    LOOP AT lt_mardh.
      IF wa_mardh-matnr <> lt_mardh-matnr OR
         wa_mardh-werks <> lt_mardh-werks OR
         wa_mardh-lgort <> lt_mardh-lgort.
        wa_mardh-matnr = lt_mardh-matnr.
        wa_mardh-werks = lt_mardh-werks.
        wa_mardh-lgort = lt_mardh-lgort.
      ELSE.
        DELETE lt_mardh.
      ENDIF.
    ENDLOOP.
  ENDIF.
  ft_mardh[] = lt_mardh[].

  SELECT * INTO CORRESPONDING FIELDS OF TABLE ft_mardh_qi_uu
    FROM mardh FOR ALL ENTRIES IN lt_039
    WHERE matnr = lt_039-matnr
    AND werks = lt_039-werks
    AND lfgja = p_spmon(4)
    AND lfmon = p_spmon+4(2)
    AND lgort = lt_039-lgort.

ENDFORM.                                                    " F_mardh

*&---------------------------------------------------------------------*
*&      Form  F_BWART
*&---------------------------------------------------------------------*
FORM f_bwart  USING    fu_bwartl fu_bwarth
              CHANGING lr_ranges TYPE STANDARD TABLE.

  DATA : lr_bwart TYPE RANGE OF bwart,
         lr_lines LIKE LINE OF lr_bwart.

  CLEAR lr_lines.

  IF fu_bwarth IS INITIAL.
    lr_lines-low  = fu_bwartl.
    lr_lines-sign = 'I'.
    lr_lines-option = 'EQ'.
    APPEND lr_lines TO lr_ranges.
  ELSE.
    lr_lines-low  = fu_bwartl.
    lr_lines-high = fu_bwarth.
    lr_lines-sign = 'I'.
    lr_lines-option = 'BT'.
    APPEND lr_lines TO lr_ranges.
  ENDIF.
ENDFORM.                    " F_BWART

*&---------------------------------------------------------------------*
*&      Form  F_RESUM_S076
*&---------------------------------------------------------------------*
FORM f_resum_s076 .
  DATA: lt_s076 LIKE gt_s076 OCCURS 0 WITH HEADER LINE.

  LOOP AT gt_s076.
    MOVE-CORRESPONDING gt_s076 TO lt_s076.
    COLLECT lt_s076.
  ENDLOOP.

  IF lt_s076[] IS NOT INITIAL.
    CLEAR gt_s076[].
    gt_s076[] = lt_s076[].
  ENDIF.
ENDFORM.                    " F_RESUM_S076

*&---------------------------------------------------------------------*
*&      Form  F_S933
*&---------------------------------------------------------------------*
FORM f_s933  USING    fu_tname.
  IF gt_933[] IS NOT INITIAL.
    SELECT *
      FROM (fu_tname)
      INTO CORRESPONDING FIELDS OF TABLE gt_s933
      FOR ALL ENTRIES IN gt_933
      WHERE spmon = gt_933-spmon
        AND werks = gt_933-werks
        AND matnr = gt_933-matnr
        AND bwart = gt_933-bwart.
  ENDIF.
ENDFORM.                    " F_S933

*&---------------------------------------------------------------------*
*&      Form  F_S933_KEY
*&---------------------------------------------------------------------*
FORM f_s933_key  USING    fu_spmon fu_wenux fu_pmnux fu_bwart.
  DATA : ls_933   LIKE LINE OF gt_933,
         lv_datum TYPE sy-datum.

  CONCATENATE fu_spmon '01' INTO lv_datum.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_datum
    IMPORTING
      last_day_of_month = lv_datum
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  lv_datum = lv_datum + 1.

  CASE fu_bwart.
    WHEN '101'.
      ls_933-spmon = fu_spmon.
      ls_933-werks = fu_wenux.
      ls_933-matnr = fu_pmnux.
      ls_933-bwart = fu_bwart.
      APPEND ls_933 TO gt_933.
*    WHEN '342'.
    WHEN '321' OR '322'.
      DO 2 TIMES.
        ls_933-spmon = fu_spmon.
        ls_933-werks = fu_wenux.
        ls_933-matnr = fu_pmnux.
        ls_933-bwart = fu_bwart.
        APPEND ls_933 TO gt_933.

        ls_933-spmon = lv_datum(6).
        APPEND ls_933 TO gt_933.
      ENDDO.
  ENDCASE.
ENDFORM.                    " F_S933_KEY
