*----------------------------------------------------------------------*
***INCLUDE ZRVCFPR00F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEND_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_EBELN  text
*      <--P_RETURN_CODE  text
*----------------------------------------------------------------------*
FORM send_data. " type char1.
  DATA: lt_pgmi TYPE STANDARD TABLE OF pgmi WITH HEADER LINE.
  DATA: lt_pgmi1 TYPE STANDARD TABLE OF pgmi WITH HEADER LINE.
  DATA: lt_mara TYPE STANDARD TABLE OF mara WITH HEADER LINE.
  TYPES: BEGIN OF ty_material,
           material_code        TYPE string,
           material_description TYPE string,
           material_uom         TYPE string,
         END OF ty_material.
  TYPES: BEGIN OF mst_material,
           mst_material TYPE STANDARD TABLE OF ty_material WITH DEFAULT KEY,
         END OF mst_material.
  DATA: BEGIN OF t_material OCCURS 0,
          matnr LIKE mara-matnr,
          meins LIKE mara-meins,
          maktx LIKE makt-maktx,
        END OF t_material.
  DATA: lt_material TYPE mst_material,
        ls_material TYPE ty_material.

  TYPES: BEGIN OF ty_lfa1,
           lifnr      LIKE lfa1-lifnr,
           name1      LIKE lfa1-name1,
           name2      LIKE lfa1-name2,
           name3      LIKE lfa1-name3,
           name4      LIKE lfa1-name4,
           land1      LIKE lfa1-land1,
           ort01      LIKE lfa1-ort01,
           ort02      LIKE lfa1-ort02,
           pstlz      LIKE lfa1-pstlz,
           stras      LIKE lfa1-stras,
           adrnr      LIKE lfa1-adrnr,
           mcod1      LIKE lfa1-mcod1,
           mcod2      LIKE lfa1-mcod2,
           mcod3      LIKE lfa1-mcod3,
           telf1      LIKE lfa1-telf1,
           city1      LIKE adrc-city1,
           city2      LIKE adrc-city2,
           post_code1 LIKE adrc-post_code1,
           street     LIKE adrc-street,
           str_suppl3 LIKE adrc-str_suppl3,
           location   LIKE adrc-location,
           tel_number LIKE adrc-tel_number,
           time_zone  LIKE adrc-time_zone,
           waers      LIKE lfm1-waers,
           zterm      LIKE lfm1-zterm,
           inco1      LIKE lfm1-inco1,
           inco2      LIKE lfm1-inco2,
           smtp_addr  LIKE adr6-smtp_addr,
         END OF ty_lfa1.

  TYPES: BEGIN OF ty_vendor,
           vendor_code    TYPE string,
           vendor_name    TYPE string,
           vendor_address TYPE string,
           land           TYPE string,
           vendor_phone   TYPE string,
           vendor_email   TYPE string,
           contact_person TYPE string,
           currency       TYPE string,
           "waers          type string,
           payment_term   TYPE string,
           incoterm1      TYPE string,
           incoterm2      TYPE string,
           email          TYPE string,
         END OF ty_vendor.
  TYPES: BEGIN OF mst_vendor,
           mst_vendor TYPE STANDARD TABLE OF ty_vendor WITH DEFAULT KEY,
         END OF mst_vendor.
  TYPES: BEGIN OF ty_pir,
           material_vendor    LIKE mara-matnr,
           material           LIKE mara-matnr,
           vendor_code        LIKE lfa1-lifnr,
           description_vendor LIKE makt-maktx,
           description        LIKE makt-maktx,
           purchasing_group   LIKE eine-ekgrp,
           uom_vendor         LIKE eina-meins,
           konversi_from      LIKE eina-umren,
           konversi_to        LIKE eina-umrez,
           uom                LIKE eina-lmein,
           qir_date(20), "    like qinf-frei_dat,
         END OF ty_pir.
  TYPES: BEGIN OF mst_inforecord,
           mst_inforecord TYPE STANDARD TABLE OF ty_pir WITH DEFAULT KEY,
         END OF mst_inforecord.
  DATA: lt_lfa1 TYPE STANDARD TABLE OF ty_lfa1 WITH HEADER LINE.
  DATA: lt_adr6 TYPE STANDARD TABLE OF adr6 WITH HEADER LINE.
  DATA: lt_lfa1_temp TYPE STANDARD TABLE OF ty_lfa1 WITH HEADER LINE.
  DATA: ls_mst_pir TYPE  mst_inforecord.
  DATA: ls_pir TYPE ty_pir.
  DATA: lt_vendor TYPE mst_vendor,
        ls_vendor TYPE ty_vendor.
  DATA: BEGIN OF lt_pir OCCURS 0,
          matnr    LIKE mara-matnr,
          bmatn    LIKE mara-matnr,
          lifnr    LIKE /sapsll/v_einr3-lifnr,
          idnlf    LIKE /sapsll/v_einr3-idnlf,
          maktx    LIKE makt-maktx,
          ekgrp    LIKE eine-ekgrp,
          meins    LIKE eina-meins,
          umren    LIKE eina-umren,
          umrez    LIKE eina-umrez,
          lmein    LIKE eina-lmein,
          frei_dat LIKE qinf-frei_dat,
          infnr    LIKE eine-infnr,
        END OF lt_pir.
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json      TYPE string.
  DATA: lv_nama(15).
  DATA: lv_str TYPE string.
  "  DATA: c_alfanumeric(70) TYPE c VALUE '1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM '.
  DATA: lv_text1024 TYPE text1024.

  SELECT * INTO TABLE lt_pgmi FROM pgmi
    WHERE pgtyp = space
      AND prgrp IN s_prgrp
      AND werks IN s_werks
      AND nrmit IN s_matnr.
  IF sy-subrc NE 0.
    IF s_matnr IS NOT INITIAL.
      SELECT * INTO TABLE lt_pgmi FROM pgmi
        WHERE pgtyp = space
    "      AND prgrp IN s_prgrp
          AND werks IN s_werks
          AND nrmit IN s_matnr.
    ENDIF.
  ENDIF.
  IF lt_pgmi[] IS NOT INITIAL.
    lt_pgmi1[] = lt_pgmi[].
    SORT lt_pgmi1 BY nrmit.
    DELETE ADJACENT DUPLICATES FROM lt_pgmi1 COMPARING nrmit.
    SELECT * APPENDING TABLE lt_pgmi FROM pgmi
      FOR ALL ENTRIES IN lt_pgmi1
      WHERE pgtyp = space
        AND prgrp = lt_pgmi1-nrmit
        AND werks IN s_werks
        AND nrmit IN s_matnr.
  ENDIF.
  IF lt_pgmi[] IS NOT INITIAL..
    SELECT * INTO CORRESPONDING FIELDS OF TABLE t_material FROM mara AS a JOIN makt AS b ON a~matnr = b~matnr
      FOR ALL ENTRIES IN lt_pgmi
      WHERE a~matnr = lt_pgmi-nrmit
        AND lvorm = space
        AND spras = 'EN'
       AND ( mtart = 'ZPM' OR mtart = 'ZRM')..
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_mara FROM mara FOR ALL ENTRIES IN lt_pgmi
      WHERE matnr = lt_pgmi-nrmit
         AND lvorm = space
         AND ( mtart = 'ZPM' OR mtart = 'ZRM').
    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE lt_mara FROM mara FOR ALL ENTRIES IN lt_pgmi
      WHERE bmatn = lt_pgmi-nrmit
         AND lvorm = space
         AND ( mtart = 'HERS').
  ENDIF.

  IF t_material[] IS NOT INITIAL.
    WRITE: / 'Send Material master to WEB eProc'.
    LOOP AT t_material.
      ls_material-material_code = t_material-matnr.

      lv_text1024 = t_material-maktx.
      CALL FUNCTION 'ZTDSIT_F0002'
        EXPORTING
          ztextin  = lv_text1024
        IMPORTING
          ztextout = lv_text1024.
      ls_material-material_description = lv_text1024.

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input          = t_material-meins
        IMPORTING
          output         = ls_material-material_uom
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.
      WRITE: / ls_material-material_code,
               12 sy-vline,
               15 ls_material-material_description,
               57 sy-vline,
               60 ls_material-material_uom, sy-vline.

      APPEND ls_material TO lt_material-mst_material.
    ENDLOOP.
    IF lt_material-mst_material[] IS NOT INITIAL.
      lv_nama = 'mst_material'.
      CREATE OBJECT cl_json_data
        EXPORTING
          data = lt_material.
      cl_json_data->serialize( ).
      gv_json = cl_json_data->get_data( ).
      PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_MSTMATERIAL' sy-subrc lv_str. "ztiam_i0001
      WRITE: / 'Message Send Master Material : ', lv_str.
      PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_MSTMATERIAL'.
    ENDIF.
  ENDIF.

**    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE lt_mara FROM mara FOR ALL ENTRIES IN lt_pgmi
**      WHERE bmatn = lt_pgmi-nrmit
**         AND lvorm = space
**         AND ( mtart = 'ZPM' OR mtart = 'ZRM' ).
**  if lt_mara[] is not INITIAL.
**  endif.
  SORT lt_mara BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING matnr.
  IF lt_mara[] IS NOT INITIAL.
    SELECT a~matnr b~matnr a~lifnr a~idnlf maktx ekgrp c~meins c~umren c~umrez c~lmein frei_dat a~infnr
      INTO TABLE lt_pir
      FROM /sapsll/v_einr3 AS a JOIN mara AS b  ON a~matnr = b~matnr
           JOIN eina AS c ON a~infnr = c~infnr  AND a~matnr = c~matnr
           JOIN eine AS d ON a~infnr = d~infnr
           JOIN makt AS e ON a~matnr = e~matnr
           JOIN qinf AS f ON a~matnr = f~matnr AND a~lifnr = f~lieferant "AND a~werks = f~werk
      FOR ALL ENTRIES IN lt_mara
      WHERE a~matnr = lt_mara-matnr
        AND a~loekz EQ space
        AND frei_dat > sy-datum.
  ENDIF.
  SORT lt_pir BY matnr.
  IF lt_pir[] IS NOT INITIAL.
    WRITE: / 'PIR'.
    WRITE: / sy-uline.
    WRITE: / 'Material  ', sy-vline,
             'Material  ', sy-vline,
             'Description Material Vendor        ', sy-vline,
             'Description Material                    ', sy-vline,
             '   ', sy-vline,
             'Uom', sy-vline,
             'KodeVendor', sy-vline.
    "lt_pir-umren, sy-vline,
    "lt_pir-umrez, sy-vline,
    "lt_pir-lmein, sy-vline,
    "lt_pir-frei_dat, sy-vline.


    LOOP AT lt_pir.
      READ TABLE lt_mara WITH KEY matnr = lt_pir BINARY SEARCH.
      IF sy-subrc EQ 0.
        "      write: / lt_mara-matnr, lt_mara-bmatn.
        IF lt_mara-bmatn IS NOT INITIAL.
          lt_pir-bmatn = lt_mara-bmatn.
        ENDIF.
      ENDIF.
      ls_pir-material_vendor = lt_pir-matnr.
      ls_pir-material = lt_pir-bmatn.
      ls_pir-vendor_code = lt_pir-lifnr.

      IF lt_pir-idnlf IS NOT INITIAL.
        ls_pir-description_vendor = lt_pir-idnlf.
      ELSE.
        ls_pir-description_vendor = lt_pir-maktx.
        lt_pir-idnlf = lt_pir-maktx.
      ENDIF.
      ls_pir-description = lt_pir-maktx.

      lv_text1024 = ls_pir-description_vendor.
      CALL FUNCTION 'ZTDSIT_F0002'
        EXPORTING
          ztextin  = lv_text1024
        IMPORTING
          ztextout = lv_text1024.
      ls_pir-description_vendor = lv_text1024.

      lv_text1024 = ls_pir-description.
      CALL FUNCTION 'ZTDSIT_F0002'
        EXPORTING
          ztextin  = lv_text1024
        IMPORTING
          ztextout = lv_text1024.
      ls_pir-description = lv_text1024.

      ls_pir-purchasing_group = lt_pir-ekgrp.
      ls_pir-uom_vendor = lt_pir-meins.
      ls_pir-konversi_from = lt_pir-umren.
      ls_pir-konversi_to = lt_pir-umrez.
      ls_pir-uom = lt_pir-lmein.
      ls_pir-qir_date = lt_pir-frei_dat.
      APPEND ls_pir TO ls_mst_pir-mst_inforecord.
      WRITE: / lt_pir-matnr(10), sy-vline,
               lt_pir-bmatn(10), sy-vline,
               lt_pir-idnlf, sy-vline,
               lt_pir-maktx, sy-vline,
               lt_pir-ekgrp, sy-vline,
               lt_pir-meins, sy-vline,
               lt_pir-lifnr, sy-vline.
**               lt_pir-umren, sy-vline,
**               lt_pir-umrez, sy-vline,
**               lt_pir-lmein, sy-vline,
**               lt_pir-frei_dat, sy-vline.
    ENDLOOP.
    WRITE: / sy-uline.
    lv_nama = 'mst_inforecord'.
    CREATE OBJECT cl_json_data
      EXPORTING
        data = ls_mst_pir.
    cl_json_data->serialize( ).
    gv_json = cl_json_data->get_data( ).
    PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_MSTPIR' sy-subrc lv_str. "ztiam_i0001
    WRITE: / 'Mesage Send PIR : ', lv_str.
    PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_MSTPIR'.
    SORT lt_pir BY lifnr.
    DELETE ADJACENT DUPLICATES FROM lt_pir COMPARING lifnr.
    IF lt_pir[] IS NOT INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_lfa1
        FROM lfa1 AS a JOIN lfm1 AS b ON a~lifnr = b~lifnr
                       JOIN adrc AS c ON a~adrnr = c~addrnumber
                       "join adr6 as d on a~adrnr = d~addrnumber
        FOR ALL ENTRIES IN lt_pir
        WHERE a~lifnr = lt_pir-lifnr
          AND ekorg = 'TNT'.
      IF sy-subrc EQ 0.
        IF lt_lfa1[] IS NOT INITIAL.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_adr6 FROM adr6 FOR ALL ENTRIES IN lt_lfa1
            WHERE addrnumber = lt_lfa1-adrnr.
        ENDIF.
        SKIP 1.
        WRITE: / 'Vendor'.
        WRITE: / sy-uline.
        WRITE: /  'KodeVendor', sy-vline,
                 '   '  , sy-vline,
                 'Nama Vendor                        ' , sy-vline,
                 'Telp number                   '  , sy-vline,
                " 'Inc' , sy-vline,
                 'Incoterm                          ' , sy-vline,
                 '     ', sy-vline,
                 'Term', sy-vline.
        WRITE: / sy-uline.


        LOOP AT lt_lfa1.
          ls_vendor-vendor_code    = lt_lfa1-lifnr.
          ls_vendor-vendor_name    = lt_lfa1-name1.
          "VALUE
          lv_text1024 = ls_vendor-vendor_name.
          CALL FUNCTION 'ZTDSIT_F0002'
            EXPORTING
              ztextin  = lv_text1024
            IMPORTING
              ztextout = lv_text1024.
          ls_vendor-vendor_name = lv_text1024.

          CONCATENATE lt_lfa1-stras lt_lfa1-ort01 lt_lfa1-ort02 INTO ls_vendor-vendor_address.
          "            ls_vendor-vendor_address = lt_lfa1-

          lv_text1024 = ls_vendor-vendor_address.
          CALL FUNCTION 'ZTDSIT_F0002'
            EXPORTING
              ztextin  = lv_text1024
            IMPORTING
              ztextout = lv_text1024.
          ls_vendor-vendor_address = lv_text1024.


          ls_vendor-land           = lt_lfa1-land1.
          ls_vendor-vendor_phone   = lt_lfa1-tel_number. "telf1.
          ls_vendor-currency = lt_lfa1-waers.
          ls_vendor-payment_term = lt_lfa1-zterm.

          ls_vendor-payment_term   = lt_lfa1-zterm.
          ls_vendor-incoterm1      = lt_lfa1-inco1.
          ls_vendor-incoterm2      = lt_lfa1-inco2. "TYPE string,
          ls_vendor-vendor_email      = lt_lfa1-smtp_addr.
          CLEAR: ls_vendor-vendor_email, ls_vendor-email.
          SORT lt_adr6 BY addrnumber consnumber.
          LOOP AT lt_adr6 WHERE addrnumber = lt_lfa1-adrnr.
            IF lt_adr6-smtp_addr IS NOT INITIAL.
              IF lt_adr6-flgdefault = 'X'.
                ls_vendor-vendor_email = lt_adr6-smtp_addr.
              ELSE.
                IF ls_vendor-email IS NOT INITIAL.
                  ls_vendor-email = lt_adr6-smtp_addr.
                ELSE.
                  CONCATENATE ls_vendor-email lt_adr6-smtp_addr INTO ls_vendor-email SEPARATED BY ';'.
                ENDIF.
              ENDIF.
            ENDIF.
            CLEAR: lt_adr6.
          ENDLOOP.
          "          ls_vendor-email      = ls_vendor-vendor_email.
          APPEND ls_vendor TO lt_vendor-mst_vendor.
          WRITE: / lt_lfa1-lifnr, sy-vline,
                   lt_lfa1-land1, sy-vline,
                   lt_lfa1-name1, sy-vline,
                   lt_lfa1-tel_number, sy-vline,
                   lt_lfa1-inco1, '-',
                   lt_lfa1-inco2, sy-vline,
                   lt_lfa1-waers, sy-vline,
                   lt_lfa1-zterm, sy-vline,
                   ls_vendor-email, sy-vline,
                   ls_vendor-vendor_email, sy-vline.
          CLEAR: ls_vendor.

        ENDLOOP.
        WRITE: / sy-uline.
        "WRITE: / 'Send data Vendor'.
        lv_nama = 'mst_vendor'.
        CREATE OBJECT cl_json_data
          EXPORTING
            data = lt_vendor.
        cl_json_data->serialize( ).
        gv_json = cl_json_data->get_data( ).
        PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_MSTVENDOR' sy-subrc lv_str. "ztiam_i0001
        WRITE: / 'Mesage Send Vendor : ', lv_str.
        PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_MSTVENDOR'.

      ENDIF.
    ENDIF.
  ENDIF.

  TYPES: BEGIN OF ty_currency,
           currency TYPE string,
           text     TYPE string,
         END OF ty_currency.
  TYPES: BEGIN OF mst_currency,
           mst_currency TYPE STANDARD TABLE OF ty_currency WITH DEFAULT KEY,
         END OF mst_currency.
  TYPES: BEGIN OF ty_zterm,
           payment_terms TYPE string,
           days          TYPE string,
           description   TYPE string,
         END OF ty_zterm.
  TYPES: BEGIN OF mst_payment,
           mst_payment_terms TYPE STANDARD TABLE OF ty_zterm WITH DEFAULT KEY,
         END OF mst_payment.
  DATA: lt_currency TYPE mst_currency,
        ls_currency TYPE ty_currency.
  DATA: lt_zterm TYPE mst_payment,
        ls_zterm TYPE ty_zterm.
  DATA: lt_tcurt TYPE STANDARD TABLE OF tcurt WITH HEADER LINE.
  DATA: BEGIN OF lt_t052 OCCURS 0,
          zterm LIKE t052-zterm,
          ztag1 LIKE t052-ztag1,
          text1 LIKE t052u-text1,
        END OF lt_t052.
  DATA: lt_t052u TYPE STANDARD TABLE OF t052u WITH HEADER LINE.

  lt_lfa1_temp[] = lt_lfa1[].
  SORT lt_lfa1_temp BY waers.
  DELETE ADJACENT DUPLICATES FROM lt_lfa1_temp COMPARING waers.
  IF lt_lfa1_temp[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_tcurt FROM tcurt FOR ALL ENTRIES IN lt_lfa1_temp
      WHERE waers = lt_lfa1_temp-waers
        AND spras = 'EN'.
  ENDIF.

  lt_lfa1_temp[] = lt_lfa1[].
  SORT lt_lfa1_temp BY zterm.
  DELETE ADJACENT DUPLICATES FROM lt_lfa1_temp COMPARING zterm.
  IF lt_lfa1_temp[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_t052
      FROM t052 AS a JOIN t052u AS b ON a~zterm = b~zterm
      FOR ALL ENTRIES IN lt_lfa1_temp
      WHERE a~zterm = lt_lfa1_temp-zterm
        AND spras = 'EN'.
  ENDIF.
  LOOP AT lt_tcurt.
    ls_currency-currency = lt_tcurt-waers.
    ls_currency-text = lt_tcurt-ktext.
    APPEND ls_currency TO lt_currency-mst_currency.
  ENDLOOP.

  LOOP AT lt_t052.
    ls_zterm-payment_terms = lt_t052-zterm.
    ls_zterm-days = lt_t052-ztag1.
    ls_currency-text = lt_t052-text1.

    lv_text1024 = ls_currency-text.
    CALL FUNCTION 'ZTDSIT_F0002'
      EXPORTING
        ztextin  = lv_text1024
      IMPORTING
        ztextout = lv_text1024.
    ls_currency-text = lv_text1024.

    APPEND ls_zterm TO lt_zterm-mst_payment_terms.
  ENDLOOP.

  lv_nama = 'mst_payment'.
  CREATE OBJECT cl_json_data
    EXPORTING
      data = lt_zterm.
  cl_json_data->serialize( ).
  gv_json = cl_json_data->get_data( ).
  PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_MSTPAYMENT' sy-subrc lv_str. "ztiam_i0001
  "  WRITE: / 'Mesage Send Mst_Payment Term : ', lv_str.

  PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_MSTPAYMENT'.

  lv_nama = 'mst_currency'.
  CREATE OBJECT cl_json_data
    EXPORTING
      data = lt_currency.
  cl_json_data->serialize( ).
  gv_json = cl_json_data->get_data( ).
  PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_MSTCURRENCY' sy-subrc lv_str. "ztiam_i0001
  PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_MSTCURRENCY'.
  "DATA: gt_tcurr TYPE STANDARD TABLE OF tcurr WITH HEADER LINE.
  "DATA: gt_tcurf TYPE STANDARD TABLE OF tcurf WITH HEADER LINE.
  DATA: BEGIN OF gt_tcurr OCCURS 0,
          kurst LIKE tcurr-kurst,
          fcurr LIKE tcurr-fcurr,
          tcurr LIKE tcurr-tcurr,
          gdatu LIKE tcurr-gdatu,
          ukurs LIKE tcurr-ukurs,
        END OF gt_tcurr. "TYPE STANDARD TABLE OF tcurr WITH HEADER LINE.
  DATA: BEGIN OF gt_tcurf OCCURS 0,
          kurst LIKE tcurr-kurst,
          fcurr LIKE tcurr-fcurr,
          tcurr LIKE tcurr-tcurr,
          gdatu LIKE tcurr-gdatu,
          "           ukurs like tcurr-ukurs,
          ffact LIKE tcurf-ffact,
          tfact LIKE tcurf-tfact,
        END OF gt_tcurf. "TYPE STANDARD TABLE OF tcurf WITH HEADER LINE.

  TYPES: BEGIN OF ty_rate,
           currency_from(10),
           currency_to(10),
           curr_date(10),
           curr_value(20),
         END OF ty_rate.
  TYPES: BEGIN OF mst_currency_rate,
           mst_currency_rate TYPE STANDARD TABLE OF ty_rate WITH DEFAULT KEY,
         END OF mst_currency_rate.
  DATA: lt_currency_rate TYPE mst_currency_rate,
        ls_currency_rate TYPE ty_rate.

  SELECT kurst fcurr tcurr MAX( gdatu ) ukurs  INTO TABLE gt_tcurr FROM tcurr
      WHERE kurst = 'M' AND
            tcurr = 'IDR'
    GROUP BY kurst fcurr tcurr gdatu ukurs.

  SELECT  kurst fcurr tcurr  MAX( gdatu ) ffact tfact
     INTO TABLE gt_tcurf FROM tcurf
    WHERE kurst = 'M' AND
          tcurr = 'IDR'
    GROUP BY kurst fcurr tcurr gdatu ffact tfact.

  SORT gt_tcurr BY fcurr tcurr gdatu.
  DELETE ADJACENT DUPLICATES FROM gt_tcurr COMPARING fcurr tcurr.
  IF gt_tcurr[] IS NOT INITIAL.
    lv_nama = 'mst_curr_rate'.
    LOOP AT gt_tcurr.
      "      MOVE-CORRESPONDING gt_tcurr TO ls_currency_rate.
      "      CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
      ls_currency_rate-currency_from = gt_tcurr-fcurr.
      ls_currency_rate-currency_to = gt_tcurr-tcurr.

      CALL FUNCTION 'CONVERSION_EXIT_INVDT_OUTPUT'
        EXPORTING
          input  = gt_tcurr-gdatu
        IMPORTING
          output = ls_currency_rate-curr_date.
      READ TABLE gt_tcurf WITH KEY kurst = gt_tcurr-kurst
                                   fcurr = gt_tcurr-fcurr
                                   tcurr = gt_tcurr-tcurr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF gt_tcurf-ffact IS NOT INITIAL OR gt_tcurf-ffact NE 0.
          ls_currency_rate-curr_value = ( gt_tcurr-ukurs * gt_tcurf-tfact ) / gt_tcurf-ffact.
        ELSE.
          ls_currency_rate-curr_value = ( gt_tcurr-ukurs * gt_tcurf-tfact ) / 1.
        ENDIF.
      ELSE.
        ls_currency_rate-curr_value = gt_tcurr-ukurs * 1000.
      ENDIF.
      APPEND ls_currency_rate TO lt_currency_rate-mst_currency_rate.
    ENDLOOP.
    CREATE OBJECT cl_json_data
      EXPORTING
        data = lt_currency_rate.
    cl_json_data->serialize( ).
    gv_json = cl_json_data->get_data( ).
    PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_SENDCURR' sy-subrc lv_str. "ztiam_i0001
    PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_SENDCURR'.
  ENDIF.



ENDFORM.                    " SEND_DATA
*&---------------------------------------------------------------------*
*&      Form  SEND_DATA_MATERIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_data_material .
  DATA: lt_pgmi TYPE STANDARD TABLE OF pgmi WITH HEADER LINE.
  DATA: lt_pgmi1 TYPE STANDARD TABLE OF pgmi WITH HEADER LINE.
  DATA: lt_mara TYPE STANDARD TABLE OF mara WITH HEADER LINE.
  TYPES: BEGIN OF ty_material,
           material_code        TYPE string,
           material_description TYPE string,
           material_uom         TYPE string,
         END OF ty_material.
  TYPES: BEGIN OF mst_material,
           mst_material TYPE STANDARD TABLE OF ty_material WITH DEFAULT KEY,
         END OF mst_material.
  TYPES: BEGIN OF ty_lfa1,
           lifnr      LIKE lfa1-lifnr,
           name1      LIKE lfa1-name1,
           name2      LIKE lfa1-name2,
           name3      LIKE lfa1-name3,
           name4      LIKE lfa1-name4,
           land1      LIKE lfa1-land1,
           ort01      LIKE lfa1-ort01,
           ort02      LIKE lfa1-ort02,
           pstlz      LIKE lfa1-pstlz,
           stras      LIKE lfa1-stras,
           adrnr      LIKE lfa1-adrnr,
           mcod1      LIKE lfa1-mcod1,
           mcod2      LIKE lfa1-mcod2,
           mcod3      LIKE lfa1-mcod3,
           telf1      LIKE lfa1-telf1,
           city1      LIKE adrc-city1,
           city2      LIKE adrc-city2,
           post_code1 LIKE adrc-post_code1,
           street     LIKE adrc-street,
           str_suppl3 LIKE adrc-str_suppl3,
           location   LIKE adrc-location,
           tel_number LIKE adrc-tel_number,
           time_zone  LIKE adrc-time_zone,
           waers      LIKE lfm1-waers,
           zterm      LIKE lfm1-zterm,
           inco1      LIKE lfm1-inco1,
           inco2      LIKE lfm1-inco2,
           smtp_addr  LIKE adr6-smtp_addr,
         END OF ty_lfa1.

  TYPES: BEGIN OF ty_vendor,
           vendor_code    TYPE string,
           vendor_name    TYPE string,
           vendor_address TYPE string,
           land           TYPE string,
           vendor_phone   TYPE string,
           vendor_email   TYPE string,
           contact_person TYPE string,
           currency       TYPE string,
           "waers          type string,
           payment_term   TYPE string,
           incoterm1      TYPE string,
           incoterm2      TYPE string,
           email          TYPE string,
         END OF ty_vendor.
  TYPES: BEGIN OF mst_vendor,
           mst_vendor TYPE STANDARD TABLE OF ty_vendor WITH DEFAULT KEY,
         END OF mst_vendor.
  TYPES: BEGIN OF ty_pir,
           material_vendor    LIKE mara-matnr,
           material           LIKE mara-matnr,
           vendor_code        LIKE lfa1-lifnr,
           description_vendor LIKE makt-maktx,
           description        LIKE makt-maktx,
           purchasing_group   LIKE eine-ekgrp,
           uom_vendor         LIKE eina-meins,
           konversi_from      LIKE eina-umren,
           konversi_to        LIKE eina-umrez,
           uom                LIKE eina-lmein,
           qir_date(20), "    like qinf-frei_dat,
         END OF ty_pir.
  TYPES: BEGIN OF mst_inforecord,
           mst_inforecord TYPE STANDARD TABLE OF ty_pir WITH DEFAULT KEY,
         END OF mst_inforecord.

  DATA: lt_lfa1 TYPE STANDARD TABLE OF ty_lfa1 WITH HEADER LINE.
  DATA: lt_adr6 TYPE STANDARD TABLE OF adr6 WITH HEADER LINE.
  DATA: lt_lfa1_temp TYPE STANDARD TABLE OF ty_lfa1 WITH HEADER LINE.
  DATA: ls_mst_pir TYPE  mst_inforecord.
  DATA: ls_pir TYPE ty_pir.
  DATA: lt_vendor TYPE mst_vendor,
        ls_vendor TYPE ty_vendor.
  DATA: lt_material TYPE mst_material,
        ls_material TYPE ty_material.
  DATA: BEGIN OF t_material OCCURS 0,
          matnr LIKE mara-matnr,
          meins LIKE mara-meins,
          maktx LIKE makt-maktx,
        END OF t_material.
  DATA: BEGIN OF lt_pir OCCURS 0,
          matnr    LIKE mara-matnr,
          bmatn    LIKE mara-matnr,
          lifnr    LIKE /sapsll/v_einr3-lifnr,
          idnlf    LIKE /sapsll/v_einr3-idnlf,
          maktx    LIKE makt-maktx,
          ekgrp    LIKE eine-ekgrp,
          meins    LIKE eina-meins,
          umren    LIKE eina-umren,
          umrez    LIKE eina-umrez,
          lmein    LIKE eina-lmein,
          frei_dat LIKE qinf-frei_dat,
          infnr    LIKE eine-infnr,
        END OF lt_pir.
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json      TYPE string.
  DATA: lv_nama(15).
  DATA: lv_str TYPE string.
  "  DATA: c_alfanumeric(70) TYPE c VALUE '1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM '.
  DATA: lv_text1024 TYPE text1024.
  DATA: lv_ctr TYPE i.

  SELECT * INTO TABLE lt_pgmi FROM pgmi
    WHERE pgtyp = space
      AND prgrp IN s_prgrp
      AND werks IN s_werks
      AND nrmit IN s_matnr.
  IF sy-subrc NE 0.
    IF s_matnr IS NOT INITIAL.
      SELECT * INTO TABLE lt_pgmi FROM pgmi
        WHERE pgtyp = space
    "      AND prgrp IN s_prgrp
          AND werks IN s_werks
          AND nrmit IN s_matnr.
    ENDIF.
  ENDIF.
  IF lt_pgmi[] IS NOT INITIAL.
    lt_pgmi1[] = lt_pgmi[].
    SORT lt_pgmi1 BY nrmit.
    DELETE ADJACENT DUPLICATES FROM lt_pgmi1 COMPARING nrmit.
    SELECT * APPENDING TABLE lt_pgmi FROM pgmi
      FOR ALL ENTRIES IN lt_pgmi1
      WHERE pgtyp = space
        AND prgrp = lt_pgmi1-nrmit
        AND werks IN s_werks
        AND nrmit IN s_matnr.
  ENDIF.
  IF lt_pgmi[] IS NOT INITIAL..
    SELECT * INTO CORRESPONDING FIELDS OF TABLE t_material FROM mara AS a JOIN makt AS b ON a~matnr = b~matnr
      FOR ALL ENTRIES IN lt_pgmi
      WHERE a~matnr = lt_pgmi-nrmit
        AND lvorm = space
        AND spras = 'EN'
       AND ( mtart = 'ZPM' OR mtart = 'ZRM' OR mtart = 'ZPCC' ).

    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_mara FROM mara FOR ALL ENTRIES IN lt_pgmi
      WHERE matnr = lt_pgmi-nrmit
         AND lvorm = space
         AND ( mtart = 'ZPM' OR mtart = 'ZRM' OR mtart = 'ZPCC' ).
    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE lt_mara FROM mara FOR ALL ENTRIES IN lt_pgmi
      WHERE bmatn = lt_pgmi-nrmit
         AND lvorm = space
         AND ( mtart = 'HERS').
  ENDIF.
  IF t_material[] IS NOT INITIAL.
    WRITE: / 'Send Material master to WEB eProc'.
    CLEAR: lv_ctr.
    LOOP AT t_material.
      ls_material-material_code = t_material-matnr.
      lv_text1024 = t_material-maktx.
      CALL FUNCTION 'ZTDSIT_F0002'
        EXPORTING
          ztextin  = lv_text1024
        IMPORTING
          ztextout = lv_text1024.
      ls_material-material_description = lv_text1024.

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = t_material-meins
        IMPORTING
          output         = ls_material-material_uom
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.
      WRITE: / ls_material-material_code,
               12 sy-vline,
               15 ls_material-material_description,
               57 sy-vline,
               60 ls_material-material_uom, sy-vline.
      APPEND ls_material TO lt_material-mst_material.
**      ADD 1 TO lv_ctr.
**      IF lv_ctr = 5.
**        IF lt_material-mst_material[] IS NOT INITIAL.
**          lv_nama = 'mst_material'.
**          CREATE OBJECT cl_json_data
**            EXPORTING
**              DATA = lt_material.
**          cl_json_data->serialize( ).
**          gv_json = cl_json_data->get_data( ).
**          PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_MSTMATERIAL' sy-subrc lv_str. "ztiam_i0001
**          WRITE: / 'Message Send Master Material : ', lv_str.
**          PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_MSTMATERIAL'.
**          CLEAR: lt_material-mst_material[], lv_ctr.
**        ENDIF.
**      ENDIF.
    ENDLOOP.
    IF lt_material-mst_material[] IS NOT INITIAL.
      lv_nama = 'mst_material'.
      CREATE OBJECT cl_json_data
        EXPORTING
          data = lt_material.
      cl_json_data->serialize( ).
      gv_json = cl_json_data->get_data( ).
      PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_MSTMATERIAL' sy-subrc lv_str. "ztiam_i0001
      WRITE: / 'Message Send Master Material : ', lv_str.
      PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_MSTMATERIAL'.
    ENDIF.
  ENDIF.
**    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE lt_mara FROM mara FOR ALL ENTRIES IN lt_pgmi
**      WHERE bmatn = lt_pgmi-nrmit
**         AND lvorm = space
**         AND ( mtart = 'ZPM' OR mtart = 'ZRM' ).
**  if lt_mara[] is not INITIAL.
**  endif.
  SORT lt_mara BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING matnr.
  IF lt_mara[] IS NOT INITIAL.
    SELECT a~matnr b~matnr a~lifnr a~idnlf maktx ekgrp c~meins c~umren c~umrez c~lmein frei_dat a~infnr
      INTO TABLE lt_pir
      FROM /sapsll/v_einr3 AS a JOIN mara AS b  ON a~matnr = b~matnr
           JOIN eina AS c ON a~infnr = c~infnr  AND a~matnr = c~matnr
           JOIN eine AS d ON a~infnr = d~infnr
           JOIN makt AS e ON a~matnr = e~matnr
           JOIN qinf AS f ON a~matnr = f~matnr AND a~lifnr = f~lieferant "AND a~werks = f~werk
      FOR ALL ENTRIES IN lt_mara
      WHERE a~matnr = lt_mara-matnr
        AND a~loekz EQ space
        AND frei_dat > sy-datum.
  ENDIF.
  SORT lt_pir BY matnr.
  IF lt_pir[] IS NOT INITIAL.
    WRITE: / 'PIR'.
    WRITE: / sy-uline.
    WRITE: / 'Material  ', sy-vline,
             'Material  ', sy-vline,
             'Description Material Vendor        ', sy-vline,
             'Description Material                    ', sy-vline,
             '   ', sy-vline,
             'Uom', sy-vline,
             'KodeVendor', sy-vline.
    "lt_pir-umren, sy-vline,
    "lt_pir-umrez, sy-vline,
    "lt_pir-lmein, sy-vline,
    "lt_pir-frei_dat, sy-vline.


    LOOP AT lt_pir.
      READ TABLE lt_mara WITH KEY matnr = lt_pir BINARY SEARCH.
      IF sy-subrc EQ 0.
        "      write: / lt_mara-matnr, lt_mara-bmatn.
        IF lt_mara-bmatn IS NOT INITIAL.
          lt_pir-bmatn = lt_mara-bmatn.
        ENDIF.
      ENDIF.
      ls_pir-material_vendor = lt_pir-matnr.
      ls_pir-material = lt_pir-bmatn.
      ls_pir-vendor_code = lt_pir-lifnr.

      lv_text1024 = lt_pir-idnlf.
      CALL FUNCTION 'ZTDSIT_F0002'
        EXPORTING
          ztextin  = lv_text1024
        IMPORTING
          ztextout = lv_text1024.
      ls_pir-description_vendor = lv_text1024.

      lv_text1024 = lt_pir-maktx.
      CALL FUNCTION 'ZTDSIT_F0002'
        EXPORTING
          ztextin  = lv_text1024
        IMPORTING
          ztextout = lv_text1024.

      IF lt_pir-idnlf IS NOT INITIAL.
      ELSE.
        ls_pir-description_vendor = lv_text1024.
        lt_pir-idnlf = lv_text1024.
      ENDIF.
      lt_pir-maktx = lv_text1024.
      ls_pir-description = lv_text1024.
      ls_pir-purchasing_group = lt_pir-ekgrp.
      ls_pir-uom_vendor = lt_pir-meins.
      ls_pir-konversi_from = lt_pir-umren.
      ls_pir-konversi_to = lt_pir-umrez.
      ls_pir-uom = lt_pir-lmein.
      ls_pir-qir_date = lt_pir-frei_dat.
      APPEND ls_pir TO ls_mst_pir-mst_inforecord.
      WRITE: / lt_pir-matnr(10), sy-vline,
               lt_pir-bmatn(10), sy-vline,
               lt_pir-idnlf, sy-vline,
               lt_pir-maktx, sy-vline,
               lt_pir-ekgrp, sy-vline,
               lt_pir-meins, sy-vline,
               lt_pir-lifnr, sy-vline.
**               lt_pir-umren, sy-vline,
**               lt_pir-umrez, sy-vline,
**               lt_pir-lmein, sy-vline,
**               lt_pir-frei_dat, sy-vline.
    ENDLOOP.
    WRITE: / sy-uline.
    lv_nama = 'mst_inforecord'.
    CREATE OBJECT cl_json_data
      EXPORTING
        data = ls_mst_pir.
    cl_json_data->serialize( ).
    gv_json = cl_json_data->get_data( ).
    PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_MSTPIR' sy-subrc lv_str. "ztiam_i0001
    WRITE: / 'Mesage Send PIR : ', lv_str.
    PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_MSTPIR'.
  ENDIF.
ENDFORM.                    " SEND_DATA_MATERIAL
*&---------------------------------------------------------------------*
*&      Form  SEND_DATA_VENDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_data_vendor .
  TYPES: BEGIN OF ty_lfa1,
           lifnr      LIKE lfa1-lifnr,
           name1      LIKE lfa1-name1,
           name2      LIKE lfa1-name2,
           name3      LIKE lfa1-name3,
           name4      LIKE lfa1-name4,
           land1      LIKE lfa1-land1,
           ort01      LIKE lfa1-ort01,
           ort02      LIKE lfa1-ort02,
           pstlz      LIKE lfa1-pstlz,
           stras      LIKE lfa1-stras,
           adrnr      LIKE lfa1-adrnr,
           mcod1      LIKE lfa1-mcod1,
           mcod2      LIKE lfa1-mcod2,
           mcod3      LIKE lfa1-mcod3,
           telf1      LIKE lfa1-telf1,
           city1      LIKE adrc-city1,
           city2      LIKE adrc-city2,
           post_code1 LIKE adrc-post_code1,
           street     LIKE adrc-street,
           str_suppl3 LIKE adrc-str_suppl3,
           location   LIKE adrc-location,
           tel_number LIKE adrc-tel_number,
           time_zone  LIKE adrc-time_zone,
           waers      LIKE lfm1-waers,
           zterm      LIKE lfm1-zterm,
           inco1      LIKE lfm1-inco1,
           inco2      LIKE lfm1-inco2,
           smtp_addr  LIKE adr6-smtp_addr,
         END OF ty_lfa1.

  TYPES: BEGIN OF ty_vendor,
           vendor_code    TYPE string,
           vendor_name    TYPE string,
           vendor_address TYPE string,
           land           TYPE string,
           vendor_phone   TYPE string,
           vendor_email   TYPE string,
           contact_person TYPE string,
           currency       TYPE string,
           "waers          type string,
           payment_term   TYPE string,
           incoterm1      TYPE string,
           incoterm2      TYPE string,
           email          TYPE string,
         END OF ty_vendor.
  TYPES: BEGIN OF mst_vendor,
           mst_vendor TYPE STANDARD TABLE OF ty_vendor WITH DEFAULT KEY,
         END OF mst_vendor.
  DATA: lt_lfa1 TYPE STANDARD TABLE OF ty_lfa1 WITH HEADER LINE.
  DATA: lt_adr6 TYPE STANDARD TABLE OF adr6 WITH HEADER LINE.
  DATA: lt_lfa1_temp TYPE STANDARD TABLE OF ty_lfa1 WITH HEADER LINE.
  DATA: lt_vendor TYPE mst_vendor,
        ls_vendor TYPE ty_vendor.
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json      TYPE string.
  DATA: lv_nama(15).
  DATA: lv_str TYPE string.
  DATA: lv_text1024 TYPE text1024.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_lfa1
    FROM lfa1 AS a JOIN lfm1 AS b ON a~lifnr = b~lifnr
                   JOIN adrc AS c ON a~adrnr = c~addrnumber
    WHERE a~lifnr IN s_lifnr
      AND ekorg = 'TNT'.
  IF sy-subrc EQ 0.
    IF lt_lfa1[] IS NOT INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_adr6 FROM adr6 FOR ALL ENTRIES IN lt_lfa1
        WHERE addrnumber = lt_lfa1-adrnr.
    ENDIF.
    SKIP 1.
    WRITE: / 'Vendor'.
    WRITE: / sy-uline.
    WRITE: /  'KodeVendor', sy-vline,
             '   '  , sy-vline,
             'Nama Vendor                        ' , sy-vline,
             'Telp number                   '  , sy-vline,
            " 'Inc' , sy-vline,
             'Incoterm                          ' , sy-vline,
             '     ', sy-vline,
             'Term', sy-vline.
    WRITE: / sy-uline.


    LOOP AT lt_lfa1.
      ls_vendor-vendor_code    = lt_lfa1-lifnr.
      ls_vendor-vendor_name    = lt_lfa1-name1.
      "VALUE
      lv_text1024 = ls_vendor-vendor_name.
      CALL FUNCTION 'ZTDSIT_F0002'
        EXPORTING
          ztextin  = lv_text1024
        IMPORTING
          ztextout = lv_text1024.
      ls_vendor-vendor_name = lv_text1024.

      CONCATENATE lt_lfa1-stras lt_lfa1-ort01 lt_lfa1-ort02 INTO ls_vendor-vendor_address.
      "            ls_vendor-vendor_address = lt_lfa1-
      lv_text1024 = ls_vendor-vendor_address.
      CALL FUNCTION 'ZTDSIT_F0002'
        EXPORTING
          ztextin  = lv_text1024
        IMPORTING
          ztextout = lv_text1024.
      ls_vendor-vendor_address = lv_text1024.

      ls_vendor-land           = lt_lfa1-land1.
      ls_vendor-vendor_phone   = lt_lfa1-tel_number. "telf1.
      ls_vendor-currency = lt_lfa1-waers.
      ls_vendor-payment_term = lt_lfa1-zterm.

      ls_vendor-payment_term   = lt_lfa1-zterm.
      ls_vendor-incoterm1      = lt_lfa1-inco1.
      ls_vendor-incoterm2      = lt_lfa1-inco2. "TYPE string,
      ls_vendor-vendor_email      = lt_lfa1-smtp_addr.
      CLEAR: ls_vendor-vendor_email, ls_vendor-email.
      SORT lt_adr6 BY addrnumber consnumber.
      LOOP AT lt_adr6 WHERE addrnumber = lt_lfa1-adrnr.
        IF lt_adr6-smtp_addr IS NOT INITIAL.
          IF lt_adr6-flgdefault = 'X'.
            ls_vendor-vendor_email = lt_adr6-smtp_addr.
          ELSE.
            IF ls_vendor-email IS NOT INITIAL.
              ls_vendor-email = lt_adr6-smtp_addr.
            ELSE.
              CONCATENATE ls_vendor-email lt_adr6-smtp_addr INTO ls_vendor-email SEPARATED BY ';'.
            ENDIF.
          ENDIF.
        ENDIF.
        CLEAR: lt_adr6.
      ENDLOOP.
      "          ls_vendor-email      = ls_vendor-vendor_email.
      APPEND ls_vendor TO lt_vendor-mst_vendor.
      WRITE: / lt_lfa1-lifnr, sy-vline,
               lt_lfa1-land1, sy-vline,
               lt_lfa1-name1, sy-vline,
               lt_lfa1-tel_number, sy-vline,
               lt_lfa1-inco1, '-',
               lt_lfa1-inco2, sy-vline,
               lt_lfa1-waers, sy-vline,
               lt_lfa1-zterm, sy-vline,
               ls_vendor-email, sy-vline,
               ls_vendor-vendor_email, sy-vline.
      CLEAR: ls_vendor.

    ENDLOOP.
    WRITE: / sy-uline.
    "WRITE: / 'Send data Vendor'.
    lv_nama = 'mst_vendor'.
    CREATE OBJECT cl_json_data
      EXPORTING
        data = lt_vendor.
    cl_json_data->serialize( ).
    gv_json = cl_json_data->get_data( ).
    PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_MSTVENDOR' sy-subrc lv_str. "ztiam_i0001
    WRITE: / 'Mesage Send Vendor : ', lv_str.
    PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_MSTVENDOR'.
  ENDIF.

  TYPES: BEGIN OF ty_currency,
           currency TYPE string,
           text     TYPE string,
         END OF ty_currency.
  TYPES: BEGIN OF mst_currency,
           mst_currency TYPE STANDARD TABLE OF ty_currency WITH DEFAULT KEY,
         END OF mst_currency.
  TYPES: BEGIN OF ty_zterm,
           payment_terms TYPE string,
           days          TYPE string,
           description   TYPE string,
         END OF ty_zterm.
  TYPES: BEGIN OF mst_payment,
           mst_payment_terms TYPE STANDARD TABLE OF ty_zterm WITH DEFAULT KEY,
         END OF mst_payment.
  DATA: lt_currency TYPE mst_currency,
        ls_currency TYPE ty_currency.
  DATA: lt_zterm TYPE mst_payment,
        ls_zterm TYPE ty_zterm.
  DATA: lt_tcurt TYPE STANDARD TABLE OF tcurt WITH HEADER LINE.
  DATA: BEGIN OF lt_t052 OCCURS 0,
          zterm LIKE t052-zterm,
          ztag1 LIKE t052-ztag1,
          text1 LIKE t052u-text1,
        END OF lt_t052.

  DATA: lt_t052u TYPE STANDARD TABLE OF t052u WITH HEADER LINE.
  lt_lfa1_temp[] = lt_lfa1[].
  SORT lt_lfa1_temp BY waers.
  DELETE ADJACENT DUPLICATES FROM lt_lfa1_temp COMPARING waers.
  IF lt_lfa1_temp[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_tcurt FROM tcurt FOR ALL ENTRIES IN lt_lfa1_temp
      WHERE waers = lt_lfa1_temp-waers
        AND spras = 'EN'.
  ENDIF.

  lt_lfa1_temp[] = lt_lfa1[].
  SORT lt_lfa1_temp BY zterm.
  DELETE ADJACENT DUPLICATES FROM lt_lfa1_temp COMPARING zterm.
  IF lt_lfa1_temp[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_t052
      FROM t052 AS a JOIN t052u AS b ON a~zterm = b~zterm
      FOR ALL ENTRIES IN lt_lfa1_temp
      WHERE a~zterm = lt_lfa1_temp-zterm
        AND spras = 'EN'.
  ENDIF.
  LOOP AT lt_tcurt.
    ls_currency-currency = lt_tcurt-waers.
    ls_currency-text = lt_tcurt-ktext.
    APPEND ls_currency TO lt_currency-mst_currency.
  ENDLOOP.

  LOOP AT lt_t052.
    ls_zterm-payment_terms = lt_t052-zterm.
    ls_zterm-days = lt_t052-ztag1.
    ls_zterm-description = lt_t052-text1.

    lv_text1024 = ls_zterm-description.
    CALL FUNCTION 'ZTDSIT_F0002'
      EXPORTING
        ztextin  = lv_text1024
      IMPORTING
        ztextout = lv_text1024.
    ls_zterm-description = lv_text1024.
    APPEND ls_zterm TO lt_zterm-mst_payment_terms.
  ENDLOOP.

  lv_nama = 'mst_payment'.
  CREATE OBJECT cl_json_data
    EXPORTING
      data = lt_zterm.
  cl_json_data->serialize( ).
  gv_json = cl_json_data->get_data( ).
  PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_MSTPAYMENT' sy-subrc lv_str. "ztiam_i0001
  "  WRITE: / 'Mesage Send Mst_Payment Term : ', lv_str.

  PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_MSTPAYMENT'.

  lv_nama = 'mst_currency'.
  CREATE OBJECT cl_json_data
    EXPORTING
      data = lt_currency.
  cl_json_data->serialize( ).
  gv_json = cl_json_data->get_data( ).
  PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_MSTCURRENCY' sy-subrc lv_str. "ztiam_i0001
  PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_MSTCURRENCY'.

ENDFORM.                    " SEND_DATA_VENDOR
*&---------------------------------------------------------------------*
*&      Form  SEND_CURRENCY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_currency .
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json      TYPE string.
  DATA: lv_nama(15).
  DATA: lv_str TYPE string.
  "  DATA: c_alfanumeric(70) TYPE c VALUE '1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM '.
  DATA: BEGIN OF gt_tcurr OCCURS 0,
          kurst LIKE tcurr-kurst,
          fcurr LIKE tcurr-fcurr,
          tcurr LIKE tcurr-tcurr,
          gdatu LIKE tcurr-gdatu,
          ukurs LIKE tcurr-ukurs,
        END OF gt_tcurr. "TYPE STANDARD TABLE OF tcurr WITH HEADER LINE.
  DATA: BEGIN OF gt_tcurf OCCURS 0,
          kurst LIKE tcurr-kurst,
          fcurr LIKE tcurr-fcurr,
          tcurr LIKE tcurr-tcurr,
          gdatu LIKE tcurr-gdatu,
          "           ukurs like tcurr-ukurs,
          ffact LIKE tcurf-ffact,
          tfact LIKE tcurf-tfact,
        END OF gt_tcurf. "TYPE STANDARD TABLE OF tcurf WITH HEADER LINE.

  TYPES: BEGIN OF ty_rate,
           currency_from(10),
           currency_to(10),
           curr_date(10),
           curr_value(20),
         END OF ty_rate.
  TYPES: BEGIN OF mst_currency_rate,
           mst_currency_rate TYPE STANDARD TABLE OF ty_rate WITH DEFAULT KEY,
         END OF mst_currency_rate.
  DATA: lt_currency_rate TYPE mst_currency_rate,
        ls_currency_rate TYPE ty_rate.

  SELECT kurst fcurr tcurr MAX( gdatu ) ukurs  INTO TABLE gt_tcurr FROM tcurr
      WHERE kurst = 'M' AND
            tcurr = 'IDR'
    GROUP BY kurst fcurr tcurr gdatu ukurs.

  SELECT  kurst fcurr tcurr  MAX( gdatu ) ffact tfact
     INTO TABLE gt_tcurf FROM tcurf
    WHERE kurst = 'M' AND
          tcurr = 'IDR'
    GROUP BY kurst fcurr tcurr gdatu ffact tfact.

  SORT gt_tcurr BY fcurr tcurr gdatu.
  DELETE ADJACENT DUPLICATES FROM gt_tcurr COMPARING fcurr tcurr.
  IF gt_tcurr[] IS NOT INITIAL.
    lv_nama = 'mst_curr_rate'.
    LOOP AT gt_tcurr.
      "      MOVE-CORRESPONDING gt_tcurr TO ls_currency_rate.
      "      CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
      ls_currency_rate-currency_from = gt_tcurr-fcurr.
      ls_currency_rate-currency_to = gt_tcurr-tcurr.

      CALL FUNCTION 'CONVERSION_EXIT_INVDT_OUTPUT'
        EXPORTING
          input  = gt_tcurr-gdatu
        IMPORTING
          output = ls_currency_rate-curr_date.
      READ TABLE gt_tcurf WITH KEY kurst = gt_tcurr-kurst
                                   fcurr = gt_tcurr-fcurr
                                   tcurr = gt_tcurr-tcurr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF gt_tcurf-ffact IS NOT INITIAL OR gt_tcurf-ffact NE 0.
          ls_currency_rate-curr_value = ( gt_tcurr-ukurs * gt_tcurf-tfact ) / gt_tcurf-ffact.
        ELSE.
          ls_currency_rate-curr_value = ( gt_tcurr-ukurs * gt_tcurf-tfact ) / 1.
        ENDIF.
      ELSE.
        ls_currency_rate-curr_value = gt_tcurr-ukurs * 1000.
      ENDIF.
      APPEND ls_currency_rate TO lt_currency_rate-mst_currency_rate.
    ENDLOOP.
    LOOP AT lt_currency_rate-mst_currency_rate INTO ls_currency_rate.
      WRITE: /  ls_currency_rate-currency_from, sy-vline,
                ls_currency_rate-currency_to, sy-vline,
                ls_currency_rate-curr_date, sy-vline,
                ls_currency_rate-curr_value, sy-vline.

    ENDLOOP.
    CREATE OBJECT cl_json_data
      EXPORTING
        data = lt_currency_rate.
    cl_json_data->serialize( ).
    gv_json = cl_json_data->get_data( ).
    PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_SENDCURR' sy-subrc lv_str. "ztiam_i0001
    PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_SENDCURR'.
  ENDIF.

ENDFORM.                    " SEND_CURRENCY
*&---------------------------------------------------------------------*
*&      Form  SEND_DATA_TERM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_data_term .
  TYPES: BEGIN OF ty_currency,
           currency TYPE string,
           text     TYPE string,
         END OF ty_currency.
  TYPES: BEGIN OF mst_currency,
           mst_currency TYPE STANDARD TABLE OF ty_currency WITH DEFAULT KEY,
         END OF mst_currency.
  TYPES: BEGIN OF ty_zterm,
           payment_terms TYPE string,
           days          TYPE string,
           description   TYPE string,
         END OF ty_zterm.
  TYPES: BEGIN OF mst_payment,
           mst_payment_terms TYPE STANDARD TABLE OF ty_zterm WITH DEFAULT KEY,
         END OF mst_payment.
  DATA: lt_currency TYPE mst_currency,
        ls_currency TYPE ty_currency.
  DATA: lt_zterm TYPE mst_payment,
        ls_zterm TYPE ty_zterm.
  DATA: lt_tcurt TYPE STANDARD TABLE OF tcurt WITH HEADER LINE.
  DATA: BEGIN OF lt_t052 OCCURS 0,
          zterm LIKE t052-zterm,
          ztag1 LIKE t052-ztag1,
          text1 LIKE t052u-text1,
        END OF lt_t052.
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json      TYPE string.
  DATA: lv_nama(15).
  DATA: lv_str TYPE string.
  DATA: lv_text1024 TYPE text1024.

  DATA: lt_t052u TYPE STANDARD TABLE OF t052u WITH HEADER LINE.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_t052
    FROM t052 AS a JOIN t052u AS b ON a~zterm = b~zterm
    WHERE a~zterm IN s_zterm
      AND spras = 'E'.
  WRITE: / 'Send Payment Term'.
  LOOP AT lt_t052.
    ls_zterm-payment_terms = lt_t052-zterm.
    ls_zterm-days = lt_t052-ztag1.
    ls_zterm-description = lt_t052-text1.

    lv_text1024 = ls_zterm-description.
    CALL FUNCTION 'ZTDSIT_F0002'
      EXPORTING
        ztextin  = lv_text1024
      IMPORTING
        ztextout = lv_text1024.
    ls_zterm-description = lv_text1024.

    WRITE: / ls_zterm-payment_terms, sy-vline,
             ls_zterm-days, sy-vline,
             ls_zterm-description, sy-vline.
    APPEND ls_zterm TO lt_zterm-mst_payment_terms.
  ENDLOOP.
  lv_nama = 'mst_payment'.
  CREATE OBJECT cl_json_data
    EXPORTING
      data = lt_zterm.
  cl_json_data->serialize( ).
  gv_json = cl_json_data->get_data( ).
  PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_MSTPAYMENT' sy-subrc lv_str. "ztiam_i0001
  WRITE: / 'Mesage Send Mst_Payment Term : ', lv_str.

  PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_MSTPAYMENT'.


ENDFORM.                    " SEND_DATA_TERM
*&---------------------------------------------------------------------*
*&      Form  SEND_DATA_CURR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_data_curr .
  TYPES: BEGIN OF ty_currency,
           currency TYPE string,
           text     TYPE string,
         END OF ty_currency.
  TYPES: BEGIN OF mst_currency,
           mst_currency TYPE STANDARD TABLE OF ty_currency WITH DEFAULT KEY,
         END OF mst_currency.
  TYPES: BEGIN OF ty_zterm,
           payment_terms TYPE string,
           days          TYPE string,
           description   TYPE string,
         END OF ty_zterm.
  TYPES: BEGIN OF mst_payment,
           mst_payment_terms TYPE STANDARD TABLE OF ty_zterm WITH DEFAULT KEY,
         END OF mst_payment.
  DATA: lt_currency TYPE mst_currency,
        ls_currency TYPE ty_currency.
  DATA: lt_zterm TYPE mst_payment,
        ls_zterm TYPE ty_zterm.
  DATA: lt_tcurt TYPE STANDARD TABLE OF tcurt WITH HEADER LINE.
  DATA: BEGIN OF lt_t052 OCCURS 0,
          zterm LIKE t052-zterm,
          ztag1 LIKE t052-ztag1,
          text1 LIKE t052u-text1,
        END OF lt_t052.
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json      TYPE string.
  DATA: lv_nama(15).
  DATA: lv_str TYPE string.
  DATA: c_alfanumeric(70) TYPE c VALUE '1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM '.

  DATA: lt_t052u TYPE STANDARD TABLE OF t052u WITH HEADER LINE.
  DATA: lv_text1024 TYPE text1024.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_tcurt FROM tcurt
     WHERE waers IN s_waers
      AND spras = 'E'.
  WRITE: / 'Send Payment Term'.
  LOOP AT lt_tcurt.
    ls_currency-currency = lt_tcurt-waers.
    ls_currency-text = lt_tcurt-ktext.

    lv_text1024 = ls_currency-text.
    CALL FUNCTION 'ZTDSIT_F0002'
      EXPORTING
        ztextin  = lv_text1024
      IMPORTING
        ztextout = lv_text1024.
    ls_currency-text = lv_text1024.

    WRITE: / ls_currency-currency, sy-vline,
             ls_currency-text, sy-vline.
    APPEND ls_currency TO lt_currency-mst_currency.
  ENDLOOP.

  lv_nama = 'mst_currency'.
  CREATE OBJECT cl_json_data
    EXPORTING
      data = lt_currency.
  cl_json_data->serialize( ).
  gv_json = cl_json_data->get_data( ).
  PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_MSTCURRENCY' sy-subrc lv_str. "ztiam_i0001
  WRITE: / 'Mesage Send Mst_currency : ', lv_str.
  PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_MSTCURRENCY'.

ENDFORM.                    " SEND_DATA_CURR
*&---------------------------------------------------------------------*
*&      Form  SEND_DATA_FPKH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_data_fpkh .
  DATA: BEGIN OF lt_a049 OCCURS 0,
          kschl TYPE a049-kschl,
          ekorg TYPE a049-ekorg,
          matnr TYPE a049-matnr,
          datbi TYPE a049-datbi,
          datab TYPE a049-datab,
          knumh TYPE a049-knumh,
          kbetr TYPE konp-kbetr,
          konwa TYPE konp-konwa,
          kmein TYPE konp-kmein,
          kpein TYPE konp-kpein,
          prgrp TYPE pgmi-prgrp,
        END OF lt_a049.
  DATA: BEGIN OF lt_a501 OCCURS 0,
          kschl TYPE a501-kschl,
          ekorg TYPE a501-ekorg,
          matnr TYPE a501-matnr,
          inco1 TYPE a501-inco1,
          datbi TYPE a501-datbi,
          datab TYPE a501-datab,
          knumh TYPE a501-knumh,
          kbetr TYPE konp-kbetr,
          konwa TYPE konp-konwa,
          kmein TYPE konp-kmein,
          kpein TYPE konp-kpein,
          prgrp TYPE pgmi-prgrp,
        END OF lt_a501.
  DATA: lt_pgmi TYPE STANDARD TABLE OF pgmi WITH HEADER LINE.
  DATA: lt_pgmi1 TYPE STANDARD TABLE OF pgmi WITH HEADER LINE.
  DATA: lt_mara TYPE STANDARD TABLE OF mara WITH HEADER LINE.

  DATA: lt_marc TYPE STANDARD TABLE OF marc WITH HEADER LINE.
  DATA: lt_ekko TYPE STANDARD TABLE OF ekko WITH HEADER LINE.
  DATA: lt_ekpo TYPE STANDARD TABLE OF ekpo WITH HEADER LINE.
  DATA: lt_eipa TYPE STANDARD TABLE OF eipa WITH HEADER LINE.
  TYPES: BEGIN OF ty_class,
           material TYPE matnr,
           plant    TYPE werks_d,
           class    TYPE string,
         END OF ty_class.
  TYPES: BEGIN OF t_class,
           result TYPE STANDARD TABLE OF ty_class WITH DEFAULT KEY,
         END OF t_class.
  DATA: lt_class TYPE t_class.
  DATA: ls_class TYPE ty_class.
  TYPES: BEGIN OF ty_inco,
           material       TYPE string,
           incoterm       TYPE string,
           price_incoterm TYPE string,
           per_price_inco TYPE string,
           currency_inco  TYPE string,
         END OF ty_inco.

  TYPES: BEGIN OF ty_budget, " OCCURS 0,
           tahun             TYPE gjahr,                    ": "2024",
           material          TYPE matnr, ": "P02240573",
           product_group     TYPE prgrp,
           "            class_rmpm type string, "MARC-MAABC
           last_po           TYPE ebeln, ": "99001289123",
           date_po           TYPE  string, "sy-datum, ": "20240510",
           kode_vendor_po    LIKE ekko-lifnr, ": "800000001",
           nama_vendor_po    LIKE lfa1-name1, ": "PT.ABC",
           last_item_po      LIKE ekpo-ebeln, ": "T001"
           qty_po            TYPE string, "p DECIMALS 0, ": 50,
           uom_po            TYPE string, ": "KG",
           price_po          TYPE string,                   ": 234000,
           per_po            TYPE string,
           currency_po       TYPE string, ": "IDR",

           po_conversi       TYPE string,
           per_conversi      TYPE string,
           currency_conversi TYPE string,

           price_budget      TYPE string,                   ": 234000,
           currency_budget   TYPE string, ": "IDR",
           per_budget        TYPE string,
           uom_budget        TYPE string,

           incoterm          TYPE string,
           price_incoterm    TYPE string,
           currency_incoterm TYPE string,
           per_incoterm      TYPE string,
           uom_incoterm      TYPE string,

         END OF ty_budget.
  TYPES: BEGIN OF ty_data,
           result TYPE STANDARD TABLE OF ty_budget WITH DEFAULT KEY,
         END OF ty_data.
  DATA: ls_respon TYPE ty_data.
  DATA: ls_budget TYPE ty_budget.
**  DATA: BEGIN OF t_material OCCURS 0,
**          matnr LIKE mara-matnr,
**          meins LIKE mara-meins,
**          maktx LIKE makt-maktx,
**        END OF t_material.
  DATA: BEGIN OF lt_po OCCURS 0,
          ebeln LIKE ekko-ebeln,
          lifnr LIKE ekko-lifnr,
          knumv LIKE ekko-knumv,
          name1 LIKE lfa1-name1,
          ebelp LIKE ekpo-ebelp,
          matnr LIKE ekpo-matnr,
          aedat LIKE ekko-aedat,
          ematn LIKE ekpo-ematn,
          werks LIKE ekpo-werks,
          preis LIKE eipa-preis,
          peinh LIKE eipa-peinh,
          bprme LIKE eipa-bprme,
          bwaer LIKE eipa-bwaer,
          menge LIKE ekpo-menge,
          meins LIKE ekpo-meins,
          bedat LIKE eipa-bedat,
          lprei LIKE eipa-lprei, "Kurs ke IDR
          lpein LIKE eipa-lpein, "unit kurs
          lwaer LIKE eipa-lwaer,
        END OF lt_po.
  DATA: lv_text(15).
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json      TYPE string,
         lv_str       TYPE string.
  DATA: lv_nama(15).
  DATA: lv_text1024 TYPE text1024.
  DATA: lv_ebeln TYPE ekko-ebeln,
        lv_lifnr TYPE ekko-lifnr,
        lv_bedat TYPE ekko-bedat,
        lv_meins TYPE ekpo-meins,
        lv_menge TYPE ekpo-menge.
  DATA: BEGIN OF lt_kurspo OCCURS 0,
          ebeln TYPE ekko-ebeln,
          kposn TYPE konv-kposn,
          knumv TYPE konv-knumv,
          kschl TYPE konv-kschl,
          kkurs TYPE konv-kkurs,
          kbetr TYPE konv-kbetr,
          kpein TYPE konv-kpein,
          waers TYPE konv-waers,
        END OF lt_kurspo.
  DATA: lv_kposn TYPE konv-kposn.
  SELECT * INTO TABLE lt_pgmi FROM pgmi
    WHERE pgtyp = space
      AND prgrp IN s_prgrp
      AND werks IN s_werks
      AND nrmit IN s_matnr.
  IF sy-subrc NE 0.
    IF s_matnr IS NOT INITIAL.
      SELECT * INTO TABLE lt_pgmi FROM pgmi
        WHERE pgtyp = space
    "      AND prgrp IN s_prgrp
          AND werks IN s_werks
          AND nrmit IN s_matnr.
    ENDIF.
  ENDIF.
  IF lt_pgmi[] IS NOT INITIAL.
    lt_pgmi1[] = lt_pgmi[].
    SORT lt_pgmi1 BY nrmit.
    DELETE ADJACENT DUPLICATES FROM lt_pgmi1 COMPARING nrmit.
    SELECT * APPENDING TABLE lt_pgmi FROM pgmi
      FOR ALL ENTRIES IN lt_pgmi1
      WHERE pgtyp = space
        AND prgrp = lt_pgmi1-nrmit
        AND werks IN s_werks
        AND nrmit IN s_matnr.
  ENDIF.
  IF lt_pgmi[] IS NOT INITIAL..
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_mara
      FROM mara FOR ALL ENTRIES IN lt_pgmi
      WHERE matnr = lt_pgmi-nrmit
         AND lvorm = space
         AND ( mtart = 'ZPM' OR mtart = 'ZRM' OR mtart = 'ZPCC').
    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE lt_mara
      FROM mara FOR ALL ENTRIES IN lt_pgmi
      WHERE bmatn = lt_pgmi-nrmit
         AND lvorm = space
         AND ( mtart = 'HERS').
  ENDIF.
  DATA: ld_awal  LIKE sy-datum, ld_akhir LIKE sy-datum.
  RANGES: lr_date  FOR  sy-datum.
  SORT lt_mara BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING ALL FIELDS.
  IF lt_mara[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_marc FROM marc FOR ALL ENTRIES IN lt_mara
      WHERE matnr = lt_mara-matnr AND maabc NE space.
    SORT lt_marc BY werks matnr maabc.
    DELETE ADJACENT DUPLICATES FROM lt_marc COMPARING werks matnr.
    LOOP AT lt_marc.
      ls_class-material = lt_marc-matnr.
      ls_class-plant = lt_marc-werks.
      ls_class-class = lt_marc-maabc.
      APPEND ls_class TO lt_class-result.
    ENDLOOP.
    lr_date-sign = 'I'.
    lr_date-option = 'BT'.
    CONCATENATE sy-datum(4) '0101' INTO lr_date-low.
    "    lr_date-low = '20240101'.
    lr_date-high = sy-datum.
    APPEND lr_date.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_a049
      FROM a049 AS a JOIN konp AS b ON a~knumh = b~knumh
                     JOIN pgmi AS c ON a~matnr = c~nrmit
      FOR ALL ENTRIES IN lt_mara
      WHERE matnr = lt_mara-matnr
        AND a~kschl = 'ZBGT'
        AND ekorg = 'TNT'
        AND loevm_ko EQ space
        AND datbi >= sy-datum AND datab IN lr_date."<= sy-datum.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_a501
      FROM a501 AS a JOIN konp AS b ON a~knumh = b~knumh
                     JOIN pgmi AS c ON a~matnr = c~nrmit
      FOR ALL ENTRIES IN lt_mara
      WHERE matnr = lt_mara-matnr
        AND a~kschl = 'ZBGT'
        AND loevm_ko EQ space
        AND ekorg = 'TNT'
        AND datbi >= sy-datum AND datab IN  lr_date. "( datab <= sy-datum AND datab >= ld_awal ).

    ld_awal = sy-datum.                                     " - 1000.
    ld_akhir = sy-datum.
    CONCATENATE sy-datum(4) '0101' INTO ld_awal.
    ld_awal(4) = ld_awal(4) - 1.
    CONCATENATE sy-datum(4) '1231' INTO ld_akhir.

    SELECT c~ebeln b~lifnr b~knumv name1 c~ebelp matnr a~aedat ematn c~werks preis c~peinh c~bprme bwaer
           a~menge meins b~bedat lprei lpein lwaer
      INTO CORRESPONDING FIELDS OF TABLE lt_po
      FROM ekpo AS a JOIN ekko AS b ON a~ebeln = b~ebeln
                     JOIN eipa AS c ON a~ebeln = c~ebeln AND
                                       a~infnr = c~infnr
                     JOIN lfa1 AS d ON b~lifnr = d~lifnr
      FOR ALL ENTRIES IN lt_mara
      WHERE matnr = lt_mara-matnr
        AND b~bedat >= ld_awal AND b~bedat <= ld_akhir
        AND a~loekz EQ space
        AND b~loekz EQ space .
    SORT lt_po BY knumv.
    IF lt_po[] IS NOT INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_kurspo
        FROM ekko AS a JOIN konv AS b ON a~knumv = b~knumv
        FOR ALL ENTRIES IN lt_po
        WHERE ebeln = lt_po-ebeln
"          and kposn = lt_po-ebelp
          AND kschl = 'ZPB0'
          AND a~loekz EQ space.
    ENDIF.
    "GROUP BY ebeln lifnr name1 ebelp matnr aedat ematn werks.
    SORT lt_po BY matnr ASCENDING bedat DESCENDING ebeln DESCENDING.
    SORT lt_a049 BY matnr knumh.
    DELETE ADJACENT DUPLICATES FROM lt_a049 COMPARING ALL FIELDS.
    SORT lt_a501 BY matnr knumh.
    DELETE ADJACENT DUPLICATES FROM lt_a501 COMPARING ALL FIELDS.
    LOOP AT lt_a049.
      ls_budget-tahun  = sy-datum(4). " TYPE gjahr,                             ": "2024",
      ls_budget-material = lt_a049-matnr. "TYPE matnr, ": "P02240573",
      ls_budget-currency_budget = lt_a049-konwa.
      ls_budget-product_group = lt_a049-prgrp.
      IF lt_a049-konwa = 'IDR'.
        WRITE lt_a049-kbetr TO lv_text NO-GAP NO-GROUPING DECIMALS 0 CURRENCY lt_a049-konwa.
      ELSE.
        WRITE lt_a049-kbetr TO lv_text NO-GAP NO-GROUPING DECIMALS 2 CURRENCY lt_a049-konwa.
      ENDIF.
      ls_budget-price_budget = lv_text. "lt_konp-kbetr. "lv_text. "TYPE string,                       ": 234000,
      ls_budget-per_budget = lt_a049-kpein. " Per
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = lt_a049-kmein "lt_po-bprme
        IMPORTING
          output         = ls_budget-uom_budget
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.
      SORT lt_a501 BY matnr.
      READ TABLE lt_a501 WITH KEY matnr = lt_a049-matnr BINARY SEARCH.
      IF sy-subrc EQ 0.
        ls_budget-incoterm = lt_a501-inco1.
        "ls_budget-currency_incoterm = lt_a501-konwa.
        ls_budget-currency_budget = lt_a501-konwa.
        IF lt_a501-konwa = 'IDR'.
          WRITE lt_a501-kbetr TO lv_text NO-GAP NO-GROUPING DECIMALS 0 CURRENCY lt_a501-konwa.
        ELSE.
          WRITE lt_a501-kbetr TO lv_text NO-GAP NO-GROUPING DECIMALS 2 CURRENCY lt_a501-konwa.
        ENDIF.
        "ls_budget-price_incoterm = lv_text. "lt_konp-kbetr. "lv_text. "TYPE string,                       ": 234000,
        ls_budget-price_budget = lv_text.
        "ls_budget-per_incoterm = lt_a501-kpein. " Per
        ls_budget-per_budget = lt_a501-kpein.
        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
          EXPORTING
            input          = lt_a501-kmein "lt_po-bprme
          IMPORTING
            output         = ls_budget-uom_incoterm
          EXCEPTIONS
            unit_not_found = 1
            OTHERS         = 2.
        DELETE lt_a501[] WHERE matnr = lt_a049-matnr.
      ENDIF.
      "      SORT lt_po BY matnr.
      SORT lt_po BY matnr ASCENDING bedat DESCENDING ebeln DESCENDING.
      READ TABLE lt_po WITH KEY matnr = lt_a049-matnr BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_kposn = lt_po-ebelp.
        SORT lt_kurspo  BY knumv kposn.
        READ TABLE lt_kurspo WITH KEY knumv = lt_po-knumv
                                      kposn = lv_kposn
                                      BINARY SEARCH.
        IF sy-subrc EQ 0.
          IF lt_kurspo-waers = lt_po-bwaer.
          ELSE.
            lt_po-preis = lt_kurspo-kbetr.
            lt_po-bwaer = lt_kurspo-waers.
            lt_po-peinh = lt_kurspo-kpein.
          ENDIF.
        ENDIF.

        ls_budget-last_po = lt_po-ebeln. ": "99001289123",
        ls_budget-date_po = lt_po-bedat. "datum, ": "20240510",
        ls_budget-kode_vendor_po = lt_po-lifnr. ": "800000001",
        lv_text1024 = lt_po-name1.
        CALL FUNCTION 'ZTDSIT_F0002'
          EXPORTING
            ztextin  = lv_text1024
          IMPORTING
            ztextout = lv_text1024.
        ls_budget-nama_vendor_po =  lv_text1024.": "PT.ABC",
        WRITE lt_po-menge TO lv_text NO-GAP NO-GROUPING DECIMALS 0.
        ls_budget-qty_po = lv_text. " TYPE string, ": 50,
        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
          EXPORTING
            input          = lt_po-meins
          IMPORTING
            output         = ls_budget-uom_po
          EXCEPTIONS
            unit_not_found = 1
            OTHERS         = 2.
        IF lt_po-bwaer = 'IDR'.
          "lt_po-preis = lt_po-preis * 100.
          WRITE lt_po-preis TO lv_text NO-GAP NO-GROUPING DECIMALS 0 CURRENCY lt_po-bwaer.
        ELSE.
          WRITE lt_po-preis TO lv_text NO-GAP NO-GROUPING DECIMALS 2 CURRENCY lt_po-bwaer.
        ENDIF.
        ls_budget-price_po = lv_text. "lt_po-preis. "lv_text. "lt_po-preis. "harga po TYPE string,                           ": 234000,
        WRITE lt_po-peinh TO lv_text NO-GAP NO-GROUPING DECIMALS 0.
        ls_budget-per_po = lv_text .
        ls_budget-currency_po = lt_po-bwaer. "TYPE string, ": "IDR",
        WRITE lt_po-lprei TO lv_text NO-GAP NO-GROUPING DECIMALS 0.
        ls_budget-po_conversi = lv_text.
        ls_budget-per_conversi = lt_po-lpein.
        ls_budget-currency_conversi = lt_po-lwaer.
        ls_budget-last_item_po = lt_po-ebelp. ", ": "T001"
        lv_ebeln = lt_po-ebeln.
        lv_lifnr = lt_po-lifnr.
        lv_bedat = lt_po-bedat.
        lv_meins = lt_po-meins.
**        CLEAR: lv_menge.
**        LOOP AT lt_po WHERE matnr = lt_a049-matnr
**                        AND ebeln = lv_ebeln
**                        AND lifnr = lv_lifnr
**                        AND bedat = lv_bedat
**                        AND meins = lv_meins.
**          lv_menge = lv_menge + lt_po-menge.
**        ENDLOOP.
**        IF lv_menge IS NOT INITIAL.
**          WRITE lv_menge TO lv_text NO-GAP NO-GROUPING DECIMALS 0.
**          ls_budget-qty_po = lv_text. " TYPE string, ": 50,
**        ENDIF.
      ENDIF.
      "      IF ls_budget-last_po IS NOT INITIAL.
      CONDENSE: ls_budget-price_incoterm, ls_budget-per_incoterm,
                ls_budget-price_budget, ls_budget-per_budget, ls_budget-qty_po,
                ls_budget-price_po, ls_budget-per_po, ls_budget-po_conversi, ls_budget-per_conversi.
      APPEND ls_budget TO ls_respon-result.
      CLEAR: ls_budget, lv_text, lt_a049, lt_a501, lt_po.
      "      ENDIF.
    ENDLOOP.
    IF lt_a501[] IS NOT INITIAL.
      SORT lt_a501 BY matnr.
      LOOP AT lt_a501.
        ls_budget-tahun  = sy-datum(4). " TYPE gjahr,                             ": "2024",
        ls_budget-material = lt_a501-matnr. "TYPE matnr, ": "P02240573",
        ls_budget-product_group = lt_a501-prgrp.
        ls_budget-currency_budget = lt_a501-konwa.
        IF lt_a501-konwa = 'IDR'.
          WRITE lt_a501-kbetr TO lv_text NO-GAP NO-GROUPING DECIMALS 0 CURRENCY lt_a501-konwa.
        ELSE.
          WRITE lt_a501-kbetr TO lv_text NO-GAP NO-GROUPING DECIMALS 2 CURRENCY lt_a501-konwa.
        ENDIF.
        ls_budget-price_budget = lv_text. "lt_konp-kbetr. "lv_text. "TYPE string,                       ": 234000,
        ls_budget-per_budget = lt_a501-kpein. " Per
        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
          EXPORTING
            input          = lt_a501-kmein "lt_po-bprme
          IMPORTING
            output         = ls_budget-uom_budget
          EXCEPTIONS
            unit_not_found = 1
            OTHERS         = 2.
        ls_budget-incoterm = lt_a501-inco1.
**        ls_budget-currency_incoterm = lt_a501-konwa.
**        IF lt_a501-konwa = 'IDR'.
**          WRITE lt_a501-kbetr TO lv_text NO-GAP NO-GROUPING DECIMALS 0 CURRENCY lt_a501-konwa.
**        ELSE.
**          WRITE lt_a501-kbetr TO lv_text NO-GAP NO-GROUPING DECIMALS 2 CURRENCY lt_a501-konwa.
**        ENDIF.
**        ls_budget-price_incoterm = lv_text. "lt_konp-kbetr. "lv_text. "TYPE string,                       ": 234000,
**        ls_budget-per_incoterm = lt_a501-kpein. " Per
**        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
**          EXPORTING
**            input          = lt_a501-kmein "lt_po-bprme
**          IMPORTING
**            output         = ls_budget-uom_incoterm
**          EXCEPTIONS
**            unit_not_found = 1
**            OTHERS         = 2.
        SORT lt_po BY matnr ASCENDING bedat DESCENDING ebeln DESCENDING.
        READ TABLE lt_po WITH KEY matnr = lt_a501-matnr BINARY SEARCH.
        IF sy-subrc EQ 0.
          lv_kposn = lt_po-ebelp.
          SORT lt_kurspo  BY knumv kposn.
          READ TABLE lt_kurspo WITH KEY knumv = lt_po-knumv
                                        kposn = lv_kposn
                                        BINARY SEARCH.
          IF sy-subrc EQ 0.
            IF lt_kurspo-waers = lt_po-bwaer.
            ELSE.
              lt_po-preis = lt_kurspo-kbetr.
              lt_po-bwaer = lt_kurspo-waers.
              lt_po-peinh = lt_kurspo-kpein.
            ENDIF.
          ENDIF.
          ls_budget-last_po = lt_po-ebeln. ": "99001289123",
          ls_budget-date_po = lt_po-bedat. "datum, ": "20240510",
          ls_budget-kode_vendor_po = lt_po-lifnr. ": "800000001",
          lv_text1024 = lt_po-name1.
          CALL FUNCTION 'ZTDSIT_F0002'
            EXPORTING
              ztextin  = lv_text1024
            IMPORTING
              ztextout = lv_text1024.
          ls_budget-nama_vendor_po =  lv_text1024.": "PT.ABC",
          WRITE lt_po-menge TO lv_text NO-GAP NO-GROUPING DECIMALS 0.
          ls_budget-qty_po = lv_text. " TYPE string, ": 50,
          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
            EXPORTING
              input          = lt_po-bprme
            IMPORTING
              output         = ls_budget-uom_po
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.
          IF lt_po-bwaer = 'IDR'.
            "lt_po-preis = lt_po-preis * 100.
            WRITE lt_po-preis TO lv_text NO-GAP NO-GROUPING DECIMALS 0 CURRENCY lt_po-bwaer.
          ELSE.
            WRITE lt_po-preis TO lv_text NO-GAP NO-GROUPING DECIMALS 2 CURRENCY lt_po-bwaer.
          ENDIF.
          ls_budget-price_po = lv_text. "lt_po-preis. "lv_text. "lt_po-preis. "harga po TYPE string,                           ": 234000,
          WRITE lt_po-peinh TO lv_text NO-GAP NO-GROUPING DECIMALS 0.
          ls_budget-per_po = lv_text .
          ls_budget-currency_po = lt_po-bwaer. "TYPE string, ": "IDR",
          WRITE lt_po-lprei TO lv_text NO-GAP NO-GROUPING DECIMALS 0.
          ls_budget-po_conversi = lv_text.
          ls_budget-per_conversi = lt_po-lpein.
          ls_budget-currency_conversi = lt_po-lwaer.
          ls_budget-last_item_po = lt_po-ebelp. ", ": "T001"
        ENDIF.
        CONDENSE: ls_budget-price_incoterm, ls_budget-per_incoterm,
                  ls_budget-price_budget, ls_budget-per_budget, ls_budget-qty_po,
                  ls_budget-price_po, ls_budget-per_po, ls_budget-po_conversi, ls_budget-per_conversi.
        APPEND ls_budget TO ls_respon-result.
        CLEAR: ls_budget, lv_text, lt_a049, lt_a501, lt_po.
      ENDLOOP.
    ENDIF.
  ENDIF.
  SORT ls_respon-result BY material.
  DELETE ADJACENT DUPLICATES FROM ls_respon-result COMPARING ALL FIELDS.
  LOOP AT ls_respon-result INTO ls_budget.
    WRITE: / ls_budget-tahun, sy-vline,
             ls_budget-material, sy-vline,
             ls_budget-price_budget, sy-vline,
             ls_budget-currency_budget, sy-vline,
             ls_budget-per_budget, sy-vline,
             ls_budget-uom_budget, sy-vline,
             ls_budget-last_po, sy-vline,
             ls_budget-date_po, sy-vline,
             ls_budget-kode_vendor_po, sy-vline,
             ls_budget-qty_po, sy-vline,
             ls_budget-uom_po, sy-vline,
             ls_budget-price_po, sy-vline,
             ls_budget-currency_po, sy-vline,
             ls_budget-last_item_po.
  ENDLOOP.
  lv_nama = sy-datum.
  CONCATENATE 'FPKH_' lv_nama INTO lv_nama.
  CREATE OBJECT cl_json_data
    EXPORTING
      data = ls_respon.
  cl_json_data->serialize( ).
  gv_json = cl_json_data->get_data( ).
  PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_FPKH' sy-subrc lv_str. "ztiam_i0001
  WRITE: / 'Mesage Send Budjet & Last PO : ', lv_str.
  PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_FPKH'.

  lv_nama = sy-datum.
  CONCATENATE 'CLASS_' lv_nama INTO lv_nama.
  CREATE OBJECT cl_json_data
    EXPORTING
      data = lt_class.
  cl_json_data->serialize( ).
  gv_json = cl_json_data->get_data( ).
  PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_CLASS' sy-subrc lv_str. "ztiam_i0001
  WRITE: / 'Mesage Class : ', lv_str.
  PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_CLASS'.

ENDFORM.                    " SEND_DATA_FPKH
*&---------------------------------------------------------------------*
*&      Form  F_SEND_MATERIAL_NON_TENDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_send_material_non_tender .
  TYPES: BEGIN OF ty_mara, " OCCURS 0,
           material_code        TYPE string,
           material_description TYPE string,
           material_uom         TYPE string,
         END OF ty_mara.

  TYPES: BEGIN OF mst_material,
           mst_material TYPE STANDARD TABLE OF ty_mara WITH DEFAULT KEY,
         END OF mst_material.
  DATA: lt_material TYPE mst_material,
        ls_material TYPE ty_mara.

  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json      TYPE string,
         lv_str       TYPE string.
  DATA: lv_nama(15).
  DATA: lv_text1024 TYPE text1024.

  SELECT a~matnr AS material_code maktx AS material_description meins AS material_uom
     INTO CORRESPONDING FIELDS OF TABLE lt_material-mst_material " lt_mara
     FROM mara AS a
          JOIN makt AS b ON a~matnr = b~matnr
     WHERE ( a~matnr IN s_matnr OR a~bmatn IN s_matnr )
        AND b~spras = sy-langu.
  LOOP AT lt_material-mst_material INTO ls_material.
    lv_text1024 = ls_material-material_description.
    CALL FUNCTION 'ZTDSIT_F0002'
      EXPORTING
        ztextin  = lv_text1024
      IMPORTING
        ztextout = lv_text1024.
    ls_material-material_description = lv_text1024.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input          = ls_material-material_uom
      IMPORTING
        output         = ls_material-material_uom
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
    MODIFY lt_material-mst_material FROM ls_material TRANSPORTING material_description material_uom.
  ENDLOOP.
  SORT lt_material-mst_material BY material_code.
  DELETE ADJACENT DUPLICATES FROM lt_material-mst_material COMPARING ALL FIELDS.
  IF lt_material-mst_material[] IS NOT INITIAL.
    lv_nama = 'mst_material'.
    CREATE OBJECT cl_json_data
      EXPORTING
        data = lt_material.
    cl_json_data->serialize( ).
    gv_json = cl_json_data->get_data( ).
    PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_MSTMATERIAL' sy-subrc lv_str. "ztiam_i0001
    WRITE: / 'Message Send Master Material : ', lv_str.
    PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_MSTMATERIAL'.
  ENDIF.
ENDFORM.
