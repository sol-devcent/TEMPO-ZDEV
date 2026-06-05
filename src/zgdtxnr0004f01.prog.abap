*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNR0004F01                                           *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA : ls_project TYPE zproject.

  CLEAR ls_project.
  SELECT SINGLE datab
      FROM zproject
      INTO gv_coretax
      WHERE name = 'ZGDCORETAX'.

  CLEAR r_fkart. REFRESH r_fkart.
  r_fkart-sign = 'I'.
  r_fkart-option = 'EQ'.

* -- Lampiran Faktur Pajak Gabungan
  IF p_lfpgb EQ 'X'.
    SELECT * FROM zgdtxdt0009.
      IF zgdtxdt0009-ptype = 'N'.
        r_fkart-low = zgdtxdt0009-fkart.
        APPEND r_fkart.
      ENDIF.
    ENDSELECT.
    PERFORM f_get_lfpgb.
* -- Lampiran Faktur Pajak Gabungan All
  ELSEIF p_lfpgg EQ 'X'.
    SELECT * FROM zgdtxdt0009.
      IF zgdtxdt0009-ptype = 'N'.
        r_fkart-low = zgdtxdt0009-fkart.
        APPEND r_fkart.
      ENDIF.
    ENDSELECT.
    PERFORM f_get_lfpgg.
* -- Laporan Faktur Pajak Standar
  ELSEIF p_lfpst EQ 'X' OR
* -- Laporan Nota Retur Standar
     p_lnrst EQ 'X'.
    PERFORM f_get_lfpst_lfpsd_lnrst.
* -- MD1
* -- Laporan Faktur Pajak Sederhana
  ELSEIF p_lfpsd EQ 'X'.
    PERFORM f_get_lfpsd.
* -- MD1
  ENDIF.

ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GENERATE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_generate_alv.

* -- Lampiran Faktur Pajak Gabungan
  IF p_lfpgb EQ 'X'.
    PERFORM f_generate_alv_lfpgb.
* -- Lampiran Faktur Pajak Gabungan All
  ELSEIF p_lfpgg EQ 'X'.
    PERFORM f_generate_alv_lfpgg.
* -- Laporan Faktur Pajak Standar
  ELSEIF p_lfpst EQ 'X'.
    PERFORM f_generate_alv_lfpst .
* -- Laporan Faktur Pajak Sederhana
  ELSEIF p_lfpsd EQ 'X'.
    PERFORM f_generate_alv_lfpsd .
* -- Laporan Nota Retur Standar
  ELSEIF p_lnrst EQ 'X'.
    PERFORM f_generate_alv_lnrst.
  ENDIF.

ENDFORM.                    " F_GENERATE_ALV

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_header_report.

* -- Lampiran Faktur Pajak Gabungan
  IF p_lfpgb EQ 'X'.
    PERFORM f_header_lfpgb.
* -- Lampiran Faktur Pajak Gabungan All
  ELSEIF p_lfpgg EQ 'X'.
    PERFORM f_header_lfpgg.
* -- Laporan Faktur Pajak Standar
  ELSEIF p_lfpst EQ 'X'.
    PERFORM f_header_lfpst .
* -- Laporan Faktur Pajak Sederhana
  ELSEIF p_lfpsd EQ 'X'.
    PERFORM f_header_lfpsd .
* -- Laporan Nota Retur Standar
  ELSEIF p_lnrst EQ 'X'.
    PERFORM f_header_lnrst.
  ENDIF.

ENDFORM.                    " F_HEADER_REPORT

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_MANIPULATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_screen_manipulation.

  LOOP AT SCREEN.
* -- Lampiran Faktur Pajak Gabungan
    IF p_lfpgb EQ 'X'.
      CLEAR p_varnt.
      CASE screen-group1.
        WHEN 'GLB'.
          screen-active = 0.
        WHEN 'LAM'.
          screen-active = 1.
        WHEN 'LAP'.
          screen-active = 0.
        WHEN 'BBB'.
          screen-active = 0.
        WHEN 'GAB'.
          screen-active = 0.
      ENDCASE.
* -- Lampiran Faktur Pajak Gabungan All
    ELSEIF p_lfpgg EQ 'X'.
      p_varnt = '/GABUNG'.
      CASE screen-group1.
        WHEN 'GLB'.
          screen-active = 1.
        WHEN 'LAM'.
          screen-active = 0.
        WHEN 'LAP'.
          screen-active = 1.
        WHEN 'BBB'.
          screen-active = 0.
        WHEN 'GAB'.
          screen-active = 1.
      ENDCASE.
* -- Others
    ELSE.
      CLEAR p_varnt.
      CASE screen-group1.
        WHEN 'GLB'.
          screen-active = 1.
        WHEN 'LAM'.
          screen-active = 0.
        WHEN 'LAP'.
          screen-active = 1.
        WHEN 'GAB'.
          screen-active = 0.
      ENDCASE.
* -- Laporan Faktur Pajak Standard and Nota Retur Standard
      IF p_lfpst EQ 'X' OR p_lnrst EQ 'X'.
        CASE screen-group1.
          WHEN 'BBB'.
            screen-active = 1.
        ENDCASE.
* -- Laporan Faktur Pajak Sederhana
      ELSEIF p_lfpsd EQ 'X'.
        CLEAR p_varnt.
        CASE screen-group1.
          WHEN 'BBB'.
            screen-active = 0.
        ENDCASE.
      ENDIF.
    ENDIF.

*--Hide Faktur pajak gabungan option for Tempo 19/01/2005
    IF screen-name = 'P_LFPGB' OR
       screen-name = 'P_LFPGG' OR
       screen-name = 'P_PSTFP' OR
       screen-name = 'P_CBNFP'.
      screen-active = 0.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " F_SCREEN_MANIPULATION

*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_initialization.

* -- MD4
* Set Options: save variants userspecific or general
  d_repid = sy-repid.
  d_save = 'A'.
  CLEAR d_variant.
  d_variant-report = d_repid.
  d_gx_variant = d_variant.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = d_save
    CHANGING
      cs_variant = d_gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    p_varnt = d_gx_variant-variant.
  ENDIF.
* -- MD4

  CLEAR s_brnch. REFRESH s_brnch.
  s_brnch-sign = 'I'.
  s_brnch-option = 'EQ'.
  GET PARAMETER ID 'ZBR' FIELD s_brnch-low.
  APPEND s_brnch.

* -- Define NPWP Pusat - MD3
  DATA : BEGIN OF t_zgdtxdt0005 OCCURS 10.
           INCLUDE STRUCTURE zgdtxdt0005.
         DATA : END OF t_zgdtxdt0005.
  DATA : ld_brnch LIKE zgdtxdt0005-brnch VALUE '%000'.

  CLEAR s_fptwo. REFRESH s_fptwo.
  CLEAR zgdtxdt0005.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE t_zgdtxdt0005
  FROM zgdtxdt0005 WHERE brnch LIKE ld_brnch.
  SORT t_zgdtxdt0005 BY brnch.
  DELETE ADJACENT DUPLICATES FROM t_zgdtxdt0005 COMPARING brnch.

  LOOP AT t_zgdtxdt0005.
    s_fptwo-sign = 'I'.
    s_fptwo-option = 'EQ'.
    s_fptwo-low = t_zgdtxdt0005-fptwo.
    APPEND s_fptwo.
  ENDLOOP.
* -- MD3

ENDFORM.                    " F_INITIALIZATION

*&---------------------------------------------------------------------*
*&      Form  F_GET_LFPGB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_lfpgb.

* -- Use Inner Join to Collect Data from T320 and LTAK
  CLEAR : zgdtxdt0002,zgdtxdt0003.
  SELECT a~bukrs a~brnch a~fakturno a~fakdat a~name a~addrs1 a~npwp
         a~masatx
         a~form       "added for MKM 03/03/2004
         b~vbeln b~posnr b~fkdat b~karoseri b~itamtlast b~item
         b~itqtylast b~fkart b~waers
         b~exclude b~itdisclast b~xppnbmlast b~dpplast b~ppnlast
         b~ppnbmlast b~itoth b~rangka b~mesin
         b~itothlast     "MD2
         b~pstyv b~pph22 b~pph23
*         FROM ( zGDTXdt0003 AS a INNER JOIN
*                zGDTXdt0002 AS b
*                ON a~fakturno EQ b~fakturno AND
*                   a~bukrs    EQ b~bukrs    AND
*                   a~brnch    EQ b~brnch )
*                                   INNER JOIN
*                zGDTXdt0009 AS c
*                ON b~fkart    EQ c~fkart    AND
*                   c~ptype    EQ 'N'       "Normal Only
         FROM   zgdtxdt0003 AS a INNER JOIN
                zgdtxdt0002 AS b
                ON a~fakturno EQ b~fakturno AND
                   a~bukrs    EQ b~bukrs    AND
                   a~brnch    EQ b~brnch    AND
                   a~masatx   EQ b~masatx
    INTO CORRESPONDING FIELDS OF TABLE t_pajak
    WHERE a~bukrs      EQ p_bukrs AND
          a~brnch      IN s_brnch AND
          a~fakturno   EQ p_faktur AND
          a~returcount EQ '000'    AND  "Only 1 line
          a~faktur_type EQ 'G'     AND  "added by Rahmadi
          a~form       IN s_form   AND  "added for MKM
          b~busln IN s_busln       AND
          b~fkart IN r_fkart.
  SORT t_pajak.
  CHECK NOT t_pajak[] IS INITIAL.

ENDFORM.                    " F_GET_LFPGB

*&---------------------------------------------------------------------*
*&      Form  F_GET_LFPST_LFPSD_LNRST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_lfpst_lfpsd_lnrst.

  DATA : ld_fkart LIKE zgdtxdt0009-ptype.

  DATA : lt_pajak TYPE STANDARD TABLE OF zgdtxst0013.
  DATA : lt_vbrk TYPE STANDARD TABLE OF vbrk.

  DATA : lr_hkont TYPE RANGE OF hkont,
         ls_hkont LIKE LINE OF lr_hkont.

* -- MD1
* -- Retur
  IF p_lnrst EQ 'X'.
    ld_fkart = 'R'.
    SELECT * FROM zgdtxdt0009.
      IF zgdtxdt0009-ptype = 'R' OR
         zgdtxdt0009-ptype = 'P' OR
**added for Tempo
         zgdtxdt0009-ptype = 'C'.
**end of addition
        r_fkart-low = zgdtxdt0009-fkart.
        APPEND r_fkart.
      ENDIF.
    ENDSELECT.
* -- Standard and Sederhana
  ELSE.
    ld_fkart = 'N'.
    SELECT * FROM zgdtxdt0009.
      IF zgdtxdt0009-ptype = 'N'.
        r_fkart-low = zgdtxdt0009-fkart.
        APPEND r_fkart.
      ENDIF.
    ENDSELECT.
  ENDIF.
* -- MD1

  CLEAR : zgdtxdt0002,zgdtxdt0003.
  BREAK bcrmd.
  IF p_lnrst EQ 'X'.
    SELECT a~bukrs a~brnch a~masatx a~fakturno a~fakdat a~name
           a~fakppn a~npwp
           a~form a~nocoretax        "added for MKM
           b~vbeln b~posnr b~fkdat b~karoseri b~itamtlast b~item
           b~itqtylast b~fkart b~waers
          b~exclude b~itdisc b~xppnbm b~dpp b~ppnbm b~noretur b~dtretur
           b~itoth
* -- MD2
           b~itdisclast b~xppnbmlast b~dpplast b~ppnlast b~ppnbmlast
           b~itothlast b~rangka b~mesin b~belnr
           b~pstyv b~pph22 b~pph23
* -- MD2
           FROM   zgdtxdt0003 AS a INNER JOIN
                  zgdtxdt0002 AS b
                  ON a~fakturno EQ b~fakturno AND
                     a~bukrs    EQ b~bukrs    AND
                     a~brnch    EQ b~brnch    AND
                     a~masatx   EQ b~masatx

*                                   INNER JOIN
*                zGDTXdt0009 AS c
*                ON b~fkart  EQ c~fkart AND
*                   c~ptype  EQ ld_fkart
           INTO CORRESPONDING FIELDS OF TABLE t_pajak
           WHERE a~bukrs      EQ p_bukrs AND
                 a~brnch      IN s_brnch AND
                 a~masatx     EQ p_masatx AND
                 a~returcount NE '000' AND
                 a~form       IN s_form   AND   "added for MKM
                 b~busln      IN s_busln AND
                 b~fkart      IN r_fkart.
  ELSE.
    SELECT a~bukrs a~brnch a~masatx a~fakturno a~fakdat a~name
           a~fakppn a~npwp
           a~form a~nocoretax        "added for MKM
           a~deliv a~ztag1 a~kunag a~kunnr
           b~vbeln b~posnr b~fkdat b~karoseri b~itamtlast b~item
           b~itqtylast b~fkart b~waers
           b~exclude b~itdisc b~xppnbm b~dpp b~ppnbm b~noretur b~dtretur
           b~itoth
* -- MD2
           b~itdisclast b~xppnbmlast b~dpplast b~ppnlast b~ppnbmlast
           b~itothlast b~rangka b~mesin b~belnr
           b~pstyv b~pph22 b~pph23 b~matnr
* -- MD2
           FROM   zgdtxdt0003 AS a INNER JOIN
                  zgdtxdt0002 AS b
                ON a~fakturno EQ b~fakturno AND
                   a~bukrs    EQ b~bukrs    AND
                   a~brnch    EQ b~brnch    AND
                   a~masatx   EQ b~masatx
*                                   INNER JOIN
*                zGDTXdt0009 AS c
*                ON b~fkart  EQ c~fkart AND
*                   c~ptype  EQ ld_fkart
           INTO CORRESPONDING FIELDS OF TABLE t_pajak
           WHERE a~bukrs      EQ p_bukrs AND
                 a~brnch      IN s_brnch AND
                 a~masatx     EQ p_masatx AND
                 a~returcount EQ '000' AND
                 a~form       IN s_form   AND   "added for MKM
                 b~busln      IN s_busln AND
                 b~fkart      IN r_fkart.
  ENDIF.

***added for Tempo -- to cater RETUR with NOREF
  IF p_lnrst EQ 'X'.
    SELECT bukrs brnch masatx name
           vbeln posnr
           fakturno                    "added for Tempo
           fkdat karoseri itamtlast item belnr
           itqtylast fkart waers
           exclude itdisc xppnbm dpp ppnbm noretur dtretur
           itoth
* -- MD2
           itdisclast xppnbmlast dpplast ppnlast ppnbmlast
           itothlast rangka mesin
           pstyv pph22 pph23
           form                        "added for MKM
           npwp                        "added for Tempo
* -- MD2
           FROM zgdtxdt0002
           APPENDING CORRESPONDING FIELDS OF TABLE t_pajak
           WHERE bukrs    EQ p_bukrs AND
                 brnch    IN s_brnch AND
                 masatx   EQ p_masatx AND
                 busln IN s_busln AND
                 fkart IN r_fkart AND
                 bilref = 'NOREF' AND
                 form  IN s_form.       "added for MKM
  ENDIF.

  SORT t_pajak.
  CHECK NOT t_pajak[] IS INITIAL.

* -- MD3
* -- Validate for NPWP Condition
  PERFORM f_validate_npwp.
  CHECK NOT t_pajak[] IS INITIAL.
* -- MD3

  ls_hkont-low    = '0841170012'.
  ls_hkont-sign   = 'I'.
  ls_hkont-option = 'EQ'.
  APPEND ls_hkont TO lr_hkont.

  ls_hkont-low    = '0142100020'.
  ls_hkont-sign   = 'I'.
  ls_hkont-option = 'EQ'.
  APPEND ls_hkont TO lr_hkont.

  IF p_bukrs = '8800' OR
    p_bukrs = '8160'.
    lt_pajak[]  = t_pajak[].
    SORT lt_pajak BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_pajak COMPARING vbeln.
    IF lt_pajak[] IS NOT INITIAL.
      SELECT *
        FROM vbrk
        INTO CORRESPONDING FIELDS OF TABLE gt_vbrk
        FOR ALL ENTRIES IN lt_pajak
        WHERE vbeln = lt_pajak-vbeln
          AND vkorg = p_bukrs.

      IF p_bukrs = '8160'.
        lt_vbrk[] = gt_vbrk[].
        SELECT *
          FROM bseg
          INTO CORRESPONDING FIELDS OF TABLE gt_bseg
          FOR ALL ENTRIES IN lt_pajak
          WHERE bukrs = p_bukrs
            AND belnr = lt_pajak-vbeln
            AND gjahr = lt_pajak-fkdat(4)
            AND hkont IN lr_hkont.

        IF lt_vbrk[] IS NOT INITIAL.
          SELECT *
            FROM konv
            INTO CORRESPONDING FIELDS OF TABLE gt_konv
            FOR ALL ENTRIES IN lt_vbrk
            WHERE knumv = lt_vbrk-knumv
              AND kschl = 'Z000'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_LFPST_LFPSD_LNRST

*&---------------------------------------------------------------------*
*&      Form  F_GENERATE_ALV_LFPGB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_generate_alv_lfpgb.

* -- ALV Processing
  CLEAR: comm_event, layout, keyinfo.
  REFRESH: fieldcat, tab_events, sort.
  PERFORM f_collect_alv_lfpgb.
  PERFORM f_build_event_lfpgb.
  PERFORM f_build_event_exit_lfpgb.
  PERFORM f_field_catalog_lfpgb.
  PERFORM f_layout_lfpgb.
  PERFORM f_field_sort_lfpgb.
  PERFORM f_list_detail_lfpgb.

ENDFORM.                    " F_GENERATE_ALV_LFPGB

*&---------------------------------------------------------------------*
*&      Form  F_GENERATE_ALV_LFPST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_generate_alv_lfpst.

* -- ALV Processing
  CLEAR: comm_event, layout, keyinfo.
  REFRESH: fieldcat, tab_events, sort.
  PERFORM f_collect_alv_lfpst.
  PERFORM f_build_event_lfpst.
  PERFORM f_build_event_exit_lfpst.
  PERFORM f_field_catalog_lfpst.
  PERFORM f_layout_lfpst.
  PERFORM f_field_sort_lfpst.
  PERFORM f_list_detail_lfpst.

ENDFORM.                    " F_GENERATE_ALV_LFPST

*&---------------------------------------------------------------------*
*&      Form  F_GENERATE_ALV_LFPSD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_generate_alv_lfpsd.

* -- ALV Processing
  CLEAR: comm_event, layout, keyinfo.
  REFRESH: fieldcat, tab_events, sort.
  PERFORM f_collect_alv_lfpsd.
  PERFORM f_build_event_lfpsd.
  PERFORM f_build_event_exit_lfpsd.
  PERFORM f_field_catalog_lfpsd.
  PERFORM f_layout_lfpsd.
  PERFORM f_field_sort_lfpsd.
  PERFORM f_list_detail_lfpsd.

ENDFORM.                    " F_GENERATE_ALV_LFPSD

*&---------------------------------------------------------------------*
*&      Form  F_GENERATE_ALV_LNRST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_generate_alv_lnrst.

* -- ALV Processing
  CLEAR: comm_event, layout, keyinfo.
  REFRESH: fieldcat, tab_events, sort.
  PERFORM f_collect_alv_lnrst.
  PERFORM f_build_event_lnrst.
  PERFORM f_build_event_exit_lnrst.
  PERFORM f_field_catalog_lnrst.
  PERFORM f_layout_lnrst.
  PERFORM f_field_sort_lnrst.
  PERFORM f_list_detail_lnrst.

ENDFORM.                    " F_GENERATE_ALV_LNRST

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_ALV_LFPGB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_alv_lfpgb.

  DATA : ld_item_text LIKE zgdtxdt0002-item,
         ld_vbeln     LIKE zgdtxdt0002-vbeln,
         ld_brnch     LIKE zgdtxdt0002-brnch.

  CLEAR : ld_item_text,ld_vbeln,ld_brnch.
  CLEAR : d_fakdat,d_masatx,d_name,d_addrs1,d_npwp.
  SORT t_pajak BY fakturno vbeln posnr fkdat karoseri DESCENDING.
  LOOP AT t_pajak.

* -- Branch Text
    CLEAR zgdtxdt0101.
    SELECT SINGLE * FROM zgdtxdt0101
     WHERE brnch EQ t_pajak-brnch.

    CONCATENATE t_pajak-brnch zgdtxdt0101-bdesc INTO t_alv-brnch_text
    SEPARATED BY space.
    ld_brnch = zgdtxdt0101-brnch.

* -- Document Date Faktur Pajak
    d_fakdat = t_pajak-fakdat.
* -- Settlement Pajak - Masa Pajak
    d_masatx = t_pajak-masatx.
* -- Customer Name
    d_name = t_pajak-name.
* -- Address
    d_addrs1 = t_pajak-addrs1.
* -- NPWP
    d_npwp = t_pajak-npwp.

* -- Lampiran Faktur Pajak Gabungan
* -- Key Fields
    t_alv-vbeln      = t_pajak-vbeln.
    t_alv-fkdat      = t_pajak-fkdat.
    t_alv-exclude    = t_pajak-exclude.
    t_alv-pstyv      = t_pajak-pstyv.

****added by Rahmadi
    t_alv-typex = t_pajak-item.
    t_alv-form  = t_pajak-form.   "for MKM 03/03/2004
****end of addition

* -- Sum Fields
* -- Type, Quantity, Harga Unit
    IF t_pajak-karoseri EQ 'U' OR t_pajak-karoseri EQ space.
      t_alv-qtyxx      = t_pajak-itqtylast.
      t_alv-hrunt      = t_pajak-itamtlast.
* -- Karoseri
    ELSEIF t_pajak-karoseri EQ 'K'.
      t_alv-karsr      = t_pajak-itamtlast.
* -- Optional
    ELSEIF t_pajak-karoseri EQ 'A'.
      t_alv-optnl      = t_pajak-itamtlast.
    ENDIF.

    t_alv-itdisclast = t_pajak-itdisclast.
    t_alv-eksbbm     = t_pajak-xppnbmlast.
    t_alv-dpplast    = t_pajak-dpplast.
    t_alv-ppnlast    = t_pajak-ppnlast.
    t_alv-ppnbmlast  = t_pajak-ppnbmlast.

***added by Rahmadi
    t_alv-pph22 = t_pajak-pph22.
    t_alv-pph23 = t_pajak-pph23.
    t_alv-waers = t_pajak-waers.
    t_alv-rangka = t_pajak-rangka.
    t_alv-mesin = t_pajak-mesin.
***end of addition

* -- Global
*   t_alv-itoth      = t_pajak-itoth.  "MD2
    t_alv-itoth      = t_pajak-itothlast.  "MD2
* -- Harga Unit + Karoseri + Optional - Discount + Others + PPNBM + PPN
    IF t_pajak-exclude EQ 'X'.
      t_alv-totfj      = t_alv-hrunt + t_alv-karsr + t_alv-optnl -
                         t_alv-itdisclast +
                         t_alv-itoth +
*                        t_alv-eksbbm +
                         t_alv-ppnbmlast + t_alv-ppnlast.
* -- Harga Unit + Karoseri + Optional - Discount + Others + PPNBM
    ELSE.
      t_alv-totfj      = t_alv-hrunt + t_alv-karsr + t_alv-optnl -
                         t_alv-itdisclast +
                         t_alv-itoth +
*                        t_alv-eksbbm +
                         t_alv-ppnbmlast.
    ENDIF.

    COLLECT t_alv.
    CLEAR : t_pajak,t_alv.

  ENDLOOP.

****Removed by Rahmadi
** -- Get Text ITEM Field
*  DATA : BEGIN OF lt_item OCCURS 10.
*          INCLUDE STRUCTURE zGDTXdt0002.
*  DATA : END OF lt_item.
*
*  LOOP AT t_alv.
*
** -- Find First ITEM Text if KAROSERI 'U'
*    CLEAR lt_item. REFRESH lt_item.
*    CLEAR zGDTXdt0002.
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_item
*    FROM zGDTXdt0002 WHERE bukrs EQ p_bukrs     AND
*                             brnch EQ ld_brnch    AND
*                             vbeln EQ t_alv-vbeln AND
*                             fakturno EQ p_faktur AND
*                             fkdat EQ t_alv-fkdat AND
*                             karoseri EQ 'U'.
*    IF sy-subrc EQ 0.
*      LOOP AT lt_item.
*        t_alv-typex = lt_item-item.
*        EXIT.
*      ENDLOOP.
*    ELSE.
** -- Second ITEM Text if KAROSERI first blank
*      CLEAR lt_item. REFRESH lt_item.
*      CLEAR zGDTXdt0002.
*      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_item
*      FROM zGDTXdt0002 WHERE bukrs EQ p_bukrs     AND
*                               brnch EQ ld_brnch    AND
*                               vbeln EQ t_alv-vbeln AND
*                               fakturno EQ p_faktur AND
*                               fkdat EQ t_alv-fkdat AND
*                               karoseri EQ space.
*      IF sy-subrc EQ 0.
*        SORT lt_item BY posnr.
*        LOOP AT lt_item.
*          t_alv-typex = lt_item-item.
*          EXIT.
*        ENDLOOP.
*      ENDIF.
*    ENDIF.
*
*    MODIFY t_alv.
*    CLEAR t_alv.
*
*  ENDLOOP.
* --
****end of removal

  CLEAR d_count.
  LOOP AT t_alv.
    ADD 1 TO d_count.
    t_alv-count = d_count.
    MODIFY t_alv TRANSPORTING count.
  ENDLOOP.

ENDFORM.                    " F_COLLECT_ALV_LFPGB

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT_LFPGB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_event_lfpgb.

  CLEAR comm_event.
  comm_event-name = slis_ev_top_of_page.
  comm_event-form = 'F_HEADER_REPORT'.
  APPEND comm_event TO tab_events.

ENDFORM.                    " F_BUILD_EVENT_LFPGB

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT_EXIT_LFPGB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_event_exit_lfpgb.

  CLEAR tab_events_exit.
  tab_events_exit-ucomm = '&OUP'.
  tab_events_exit-after = 'X'.
  APPEND tab_events_exit.

  CLEAR tab_events_exit.
  tab_events_exit-ucomm = '&ODN'.
  tab_events_exit-after = 'X'.
  APPEND tab_events_exit.

ENDFORM.                    " F_BUILD_EVENT_EXIT_LFPGB

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_LFPGB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_field_catalog_lfpgb.

  PERFORM f_fieldcatg_qty USING 'T_ALV' :
    'COUNT' 'AGDB' 'CLUSTR' '' '7' TEXT-005 '' '' space 'R'.

  PERFORM f_fieldcatg USING 'T_ALV' :
***added by Rahmadi for MKM 03/03/2004
    'FORM' 'ZGDTXDT0003' 'FORM' '' '4' 'Form' '' '' space 'C',
***end of addition
    'VBELN'        '' ''  ''  '12'   TEXT-006 '' '' space 'C',
    'FKDAT'        '' ''  ''  '12'   TEXT-007 '' '' space 'C',
    'TYPEX'        '' ''  ''  '35'   TEXT-008 '' '' space 'L'.

  PERFORM f_fieldcatg_qty USING 'T_ALV' :
    'QTYXX' 'ZGDTXdt0002' 'ITQTYLAST' '' '15'
            TEXT-009 'X' '' space 'R'.
  PERFORM f_fieldcatg USING 'T_ALV' :
    'EXCLUDE'     '' ''  ''     '6' TEXT-042 ''  '' space 'C'.

  PERFORM f_fieldcatg USING 'T_ALV' :
    'PSTYV'     '' ''  ''     '6' 'Category' ''  '' space 'C'.

***added by Rahmadi
  PERFORM f_fieldcatg USING 'T_ALV' :
   'RANGKA' 'ZGDTXDT0002' 'RANGKA' '' '18' 'No.Rangka' '' '' space 'C'.
  PERFORM f_fieldcatg USING 'T_ALV' :
    'MESIN'  'ZGDTXDT0002' 'MESIN' ''  '20' 'No.Mesin' ''  '' space 'C'.
***end of addition

  PERFORM f_fieldcatg USING 'T_ALV' :
    'WAERS'  'ZGDTXDT0002' 'WAERS'  '' '6' 'Curcy' ''  '' space 'C'.

  PERFORM f_fieldcatg_curr USING 'T_ALV' :
    'HRUNT' 'FEBKO' 'SUMSO' ''       '15' TEXT-010
    'X' '' space space 'WAERS' 'R',
    'KARSR' 'FEBKO' 'SUMSO' ''       '15' TEXT-011
    'X' '' space space 'WAERS' 'R',
    'OPTNL' 'FEBKO' 'SUMSO' ''       '15' TEXT-012
    'X' '' space space 'WAERS' 'R',
    'ITDISCLAST' 'FEBKO' 'SUMSO' ''  '15' TEXT-013
    'X' '' space space 'WAERS' 'R',
    'EKSBBM' 'FEBKO' 'SUMSO' ''      '15' TEXT-014
    'X' '' space space 'WAERS' 'R',
    'DPPLAST' 'FEBKO' 'SUMSO' ''     '15' TEXT-015
    'X' '' space space 'WAERS' 'R',
    'PPNLAST' 'FEBKO' 'SUMSO' ''     '15' TEXT-016
    'X' '' space space 'WAERS' 'R',
    'PPNBMLAST' 'FEBKO' 'SUMSO' ''   '15' TEXT-017
    'X' '' space space 'WAERS' 'R',
    'ITOTH' 'FEBKO' 'SUMSO' ''       '15' TEXT-018
    'X' '' space space 'WAERS' 'R',
    'TOTFJ' 'FEBKO' 'SUMSO' ''       '15' TEXT-019
    'X' '' space space 'WAERS' 'R',
    'PPH22' 'FEBKO' 'SUMSO' ''       '15' 'PPh 22'
    'X' '' space space 'WAERS' 'R',
    'PPH23' 'FEBKO' 'SUMSO' ''       '15' 'PPh 23'
    'X' '' space space 'WAERS' 'R'.

ENDFORM.                    " F_FIELD_CATALOG_LFPGB

*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT_LFPGB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_layout_lfpgb.

  CLEAR layout.
  layout-zebra = 'X'.
  layout-colwidth_optimize  = space.
  layout-no_colhead         = space.
  layout-group_change_edit  = 'X'.
  layout-cell_merge         = 'X'.
* layout-f2code             = '&IC1'.   "At Line Selection-Double Click
* layout-coltab_fieldname   = 'COLOR'.  "Assign Color Fields
* layout-totals_text        = text-027. "Text On First Column

ENDFORM.                    " F_LAYOUT_LFPGB

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_SORT_LFPGB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_field_sort_lfpgb.

ENDFORM.                    " F_FIELD_SORT_LFPGB

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL_LFPGB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_list_detail_lfpgb.

  repid = sy-repid.
  print-no_print_listinfos = 'X'.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program      = repid
*     i_callback_pf_status_set = 'F_ALV_STATUS'
      i_callback_user_command = 'F_USER_COMMAND'
      is_layout               = layout
      it_fieldcat             = fieldcat[]
      it_events               = tab_events[]
      it_event_exit           = tab_events_exit[]
      i_default               = 'X'
      i_save                  = d_save
      is_variant              = d_variant
*     is_keyinfo              = keyinfo
      is_print                = print
      it_sort                 = sort[]
      it_excluding            = excluding[]
      i_bypassing_buffer      = 'X'
    TABLES
      t_outtab                = t_alv
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

ENDFORM.                    " F_LIST_DETAIL_LFPGB

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_ALV_LFPST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_alv_lfpst.

  DATA : ld_item_text LIKE zgdtxdt0002-item,
         ld_vbeln     LIKE zgdtxdt0002-vbeln.

  DATA: ld_selisih  LIKE zgdtxst0004-fakppn.

  DATA : lv_faktur(20),
         lv_name       TYPE tdobname,
         lines         LIKE tline OCCURS 0 WITH HEADER LINE,
         lv_zdesc1(40),
         lv_value(15).

  DATA : lv_satuan TYPE p DECIMALS 4.

  DATA : ls_vbrk LIKE LINE OF gt_vbrk,
         ls_bseg LIKE LINE OF gt_bseg,
         ls_konv LIKE LINE OF gt_konv.

* -- Settlement Pajak - Masa Pajak
  d_masatx = p_masatx.

  CLEAR : ld_item_text,ld_vbeln.
  CLEAR : d_fakdat.
  SORT t_pajak BY brnch fakturno vbeln fkdat.
  LOOP AT t_pajak.

* -- Branch Text
    CLEAR zgdtxdt0101.
    SELECT SINGLE * FROM zgdtxdt0101
     WHERE brnch EQ t_pajak-brnch.

    CONCATENATE t_pajak-brnch zgdtxdt0101-bdesc INTO t_alv-brnch_text
    SEPARATED BY space.

    t_alv-dpp_02 = t_pajak-itamtlast - t_pajak-itdisclast.
* -- Lampiran Faktur Pajak Gabungan
* -- Key Fields
    t_alv-brnch      = t_pajak-brnch.

    t_alv-fakturno   = t_pajak-fakturno.
    PERFORM f_coretax_format USING t_pajak-fakturno
                             CHANGING t_alv-fakturno2.

    IF t_alv-fakturno2 IS INITIAL.
      IF t_pajak-masatx(4) GT 2006.
        CALL FUNCTION 'ZF_FAKTUR'
          EXPORTING
            bukrs     = t_pajak-bukrs
            fakdat    = t_pajak-fakdat
            masatx    = t_pajak-masatx
            fakturin  = t_pajak-fakturno
          IMPORTING
            fakturout = t_alv-fakturno1.
      ELSE.
        CONCATENATE t_pajak-fakturno(3) '.' t_pajak-fakturno+3(3)
                    '-' t_pajak-fakturno+6(2) '.' t_pajak-fakturno+8(8)
          INTO t_alv-fakturno1.
      ENDIF.

      IF t_pajak-fakdat > gv_coretax.
        t_alv-fakturno2 = t_pajak-nocoretax.
      ELSE.
        t_alv-fakturno2 = t_alv-fakturno1.
      ENDIF.
    ENDIF.

    t_alv-masatx     = t_pajak-masatx.
    t_alv-vbeln      = t_pajak-vbeln.

* Jasa Pembuatan Maklon
    IF p_bukrs = '8090'.
      CLEAR : lv_zdesc1, lv_name, lines[], lines.
      lv_name = t_pajak-vbeln.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = 'ZH05'
          language                = sy-langu
          name                    = lv_name
          object                  = 'VBBK'
        TABLES
          lines                   = lines
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.

      READ TABLE lines INDEX 1.
      IF sy-subrc = 0.
        lv_value = lines-tdline.
        SELECT SINGLE field_value1
          FROM zgdfakturkom
          INTO lv_zdesc1
          WHERE vkorg = p_bukrs
            AND field_value = lv_value.
      ENDIF.
    ENDIF.

    t_alv-fkdat      = t_pajak-fkdat.
    t_alv-name       = t_pajak-name.
    t_alv-npwp       = t_pajak-npwp.
    t_alv-exclude    = t_pajak-exclude.

****added by Rahmadi
    IF p_bukrs  = '8090'.
      IF lv_zdesc1 IS INITIAL.
        t_alv-typex = t_pajak-item.
      ELSE.
        CONCATENATE lv_zdesc1 t_pajak-item INTO t_alv-typex
        SEPARATED BY space.
      ENDIF.
    ELSE.
      t_alv-typex = t_pajak-item.
    ENDIF.
    t_alv-rangka = t_pajak-rangka.
    t_alv-mesin = t_pajak-mesin.
    t_alv-form  = t_pajak-form.   "for MKM 03/03/2004
    t_alv-belnr = t_pajak-belnr.  "for Tempo 28/06/2005
****end of addition

* -- Sum Fields
* -- Type, Quantity, Harga Unit
    IF t_pajak-karoseri EQ 'U' OR t_pajak-karoseri EQ space.
      t_alv-qtyxx      = t_pajak-itqtylast.
      IF t_pajak-brnch EQ '8160'.
        lv_satuan      = t_pajak-itamtlast / t_pajak-itqtylast.
        t_alv-hrunt    = lv_satuan * 100.
        IF t_pajak-vbeln(4) EQ '9903'.
          CLEAR ls_vbrk.
          READ TABLE gt_vbrk INTO ls_vbrk
                             WITH KEY vbeln = t_pajak-vbeln.
          IF sy-subrc = 0.
            CLEAR ls_konv.
            READ TABLE gt_konv INTO ls_konv
                             WITH KEY knumv = ls_vbrk-knumv
                                      kposn = t_pajak-posnr.
            IF sy-subrc = 0.
              lv_satuan   = ls_konv-kbetr / ls_konv-kpein.
              t_alv-hrunt = lv_satuan * 100.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        t_alv-hrunt      = t_pajak-itamtlast.
      ENDIF.
* -- Karoseri
    ELSEIF t_pajak-karoseri EQ 'K'.
      t_alv-karsr      = t_pajak-itamtlast.
* -- Optional
    ELSEIF t_pajak-karoseri EQ 'A'.
      t_alv-optnl      = t_pajak-itamtlast.
    ENDIF.

* -- MD2 Not Used
*   t_alv-itdisc = t_pajak-itdisc.
*   t_alv-eksbbm = t_pajak-xppnbm.
*   t_alv-dpp    = t_pajak-dpp.
*   t_alv-fakppn = t_pajak-fakppn.
*   t_alv-ppnbm  = t_pajak-ppnbm.
* -- MD2 Changes
    t_alv-itdisc = t_pajak-itdisclast.
    t_alv-eksbbm = t_pajak-xppnbmlast.

    t_alv-dpp    = t_pajak-dpplast.
    t_alv-fakppn = t_pajak-ppnlast.

    IF t_pajak-brnch EQ '8050' OR t_pajak-brnch = '8800'.
      IF p_espt IS INITIAL.
        CLEAR: ld_selisih.
        ld_selisih = t_alv-fakppn / t_alv-hrunt * 100.
        IF ld_selisih NE 10 AND
          ld_selisih NE 11.
          PERFORM f_tax_calc USING '' p_masatx t_alv-hrunt 'F'
                             CHANGING t_alv-dpp.

*          t_alv-dpp = t_alv-hrunt * 10 / 100.
        ENDIF.
      ENDIF.
    ENDIF.

    t_alv-ppnbm  = t_pajak-ppnbmlast.
    t_alv-pstyv  = t_pajak-pstyv.
* -- MD2

***added by Rahmadi
    t_alv-pph22 = t_pajak-pph22.
    t_alv-pph23 = t_pajak-pph23.
    t_alv-waers = t_pajak-waers.
***end of addition

* -- Global
*   t_alv-itoth      = t_pajak-itoth.  "MD2
    t_alv-itoth      = t_pajak-itothlast.   "MD2
* -- Harga Unit + Karoseri + Optional - Discount + Others + PPNBM + PPN
    IF t_pajak-exclude EQ 'X'.
      IF t_pajak-brnch EQ '8160'.
        t_alv-totfj      = t_alv-dpp + t_alv-karsr + t_alv-optnl -
*                        t_alv-itdisclast +  "MD2
           t_alv-itdisc     +      "MD2
           t_alv-itoth +
*                        t_alv-eksbbm +
*                        t_alv-ppnbmlast + t_alv-ppnlast.  "MD2
           t_alv-ppnbm + t_alv-fakppn + t_alv-pph22. "MD2
      ELSE.
        t_alv-totfj      = t_alv-hrunt + t_alv-karsr + t_alv-optnl -
*                        t_alv-itdisclast +  "MD2
                   t_alv-itdisc     +      "MD2
                   t_alv-itoth +
*                        t_alv-eksbbm +
*                        t_alv-ppnbmlast + t_alv-ppnlast.  "MD2
                   t_alv-ppnbm + t_alv-fakppn + t_alv-pph22. "MD2
      ENDIF.

* -- Harga Unit + Karoseri + Optional - Discount + Others + PPNBM
    ELSE.
      t_alv-totfj      = t_alv-hrunt + t_alv-karsr + t_alv-optnl -
*                        t_alv-itdisclast +   "MD2
                         t_alv-itdisc     +      "MD2
                         t_alv-itoth +
*                        t_alv-eksbbm +
*                        t_alv-ppnbmlast.  "MD2
                         t_alv-ppnbm + t_alv-pph22.  "MD2
    ENDIF.

    t_alv-deliv   = t_pajak-deliv.
    t_alv-ztag1   = t_pajak-ztag1.
    t_alv-duedt   = t_pajak-fakdat + t_pajak-ztag1.
    t_alv-kunag   = t_pajak-kunag.
    t_alv-kunnr   = t_pajak-kunnr.
    t_alv-matnr   = t_pajak-matnr.

    COLLECT t_alv.
    CLEAR : t_pajak,t_alv.
  ENDLOOP.

***added for Tempo --- e-SPT format
  IF NOT p_espt IS INITIAL.
    PERFORM collect_t_alv.
    PERFORM f_format_to_espt.
  ENDIF.
***end of Tempo addition

****Removed by Rahmadi
** -- Get Text ITEM Field
*  DATA : BEGIN OF lt_item OCCURS 10.
*          INCLUDE STRUCTURE zGDTXdt0002.
*  DATA : END OF lt_item.
*
*  LOOP AT t_alv.
** -- Find First ITEM Text if KAROSERI 'U'
*    CLEAR lt_item. REFRESH lt_item.
*    CLEAR zGDTXdt0002.
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_item
*    FROM zGDTXdt0002 WHERE bukrs EQ    p_bukrs        AND
*                             brnch EQ    t_alv-brnch    AND
*                             vbeln EQ    t_alv-vbeln    AND
*                             fakturno EQ t_alv-fakturno AND
*                             fkdat EQ    t_alv-fkdat    AND
*                             karoseri EQ 'U'.
*    IF sy-subrc EQ 0.
*      LOOP AT lt_item.
*        t_alv-typex = lt_item-item.
*        EXIT.
*      ENDLOOP.
*    ELSE.
** -- Second ITEM Text if KAROSERI first blank
*      CLEAR lt_item. REFRESH lt_item.
*      CLEAR zGDTXdt0002.
*      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_item
*      FROM zGDTXdt0002 WHERE bukrs EQ    p_bukrs        AND
*                               brnch EQ    t_alv-brnch    AND
*                               vbeln EQ    t_alv-vbeln    AND
*                               fakturno EQ t_alv-fakturno AND
*                               fkdat EQ    t_alv-fkdat    AND
*                               karoseri EQ space.
*      IF sy-subrc EQ 0.
*        SORT lt_item BY posnr.
*        LOOP AT lt_item.
*          t_alv-typex = lt_item-item.
*          EXIT.
*        ENDLOOP.
*      ENDIF.
*    ENDIF.
*
*    MODIFY t_alv.
*    CLEAR t_alv.
*
*  ENDLOOP.
* --
****End of removal

  CLEAR d_count.
  CLEAR d_brnch.
  LOOP AT t_alv.
    IF d_brnch NE t_alv-brnch.
      CLEAR d_count.
    ENDIF.
    d_brnch = t_alv-brnch.

    ADD 1 TO d_count.
    t_alv-count = d_count.
    IF p_bukrs  = '8800' OR
      p_bukrs = '8160'.
      CLEAR ls_vbrk.
      READ TABLE gt_vbrk INTO ls_vbrk
                         WITH KEY vbeln = t_alv-vbeln.
      IF sy-subrc = 0.
        t_alv-inco2 = ls_vbrk-inco2.
        t_alv-noinv = ls_vbrk-xblnr.
      ENDIF.

      IF p_bukrs = '8160'.
        CLEAR ls_bseg.
        READ TABLE gt_bseg INTO ls_bseg
                           WITH KEY belnr = t_alv-vbeln
                                    hkont = '0841170012'.
        IF sy-subrc = 0.
          t_alv-materai = ls_bseg-dmbtr.
          t_alv-noinv   = ls_vbrk-xblnr.
          t_alv-totfj   = t_alv-totfj + t_alv-materai.
*          t_alv-materai = t_alv-materai * 100.
        ENDIF.

        CLEAR ls_bseg.
        READ TABLE gt_bseg INTO ls_bseg
                           WITH KEY belnr = t_alv-vbeln
                                    hkont = '0142100020'.
        IF sy-subrc = 0.
          t_alv-prepaid = ls_bseg-dmbtr.
          t_alv-totfj   = t_alv-totfj - t_alv-prepaid.
        ENDIF.
      ENDIF.
    ENDIF.
    MODIFY t_alv TRANSPORTING count inco2 noinv materai prepaid totfj.
  ENDLOOP.

ENDFORM.                    " F_COLLECT_ALV_LFPST

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT_LFPST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_event_lfpst.

  IF p_espt IS INITIAL.
    CLEAR comm_event.
    comm_event-name = slis_ev_top_of_page.
    comm_event-form = 'F_HEADER_REPORT'.
    APPEND comm_event TO tab_events.

    CLEAR comm_event.
    comm_event-name = slis_ev_before_line_output.
    comm_event-form = 'F_BEFORE_LINE_OUTPUT'.
    APPEND comm_event TO tab_events.
  ENDIF.

ENDFORM.                    " F_BUILD_EVENT_LFPST

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT_EXIT_LFPST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_event_exit_lfpst.

  CLEAR tab_events_exit.
  tab_events_exit-ucomm = '&OUP'.
  tab_events_exit-after = 'X'.
  APPEND tab_events_exit.

  CLEAR tab_events_exit.
  tab_events_exit-ucomm = '&ODN'.
  tab_events_exit-after = 'X'.
  APPEND tab_events_exit.

ENDFORM.                    " F_BUILD_EVENT_EXIT_LFPST

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_LFPST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_field_catalog_lfpst.

  IF p_espt IS INITIAL.
    PERFORM f_fieldcatg_qty USING 'T_ALV' :
      'COUNT' 'AGDB' 'CLUSTR' '' '7' TEXT-005 '' '' space 'R'.

    PERFORM f_fieldcatg USING 'T_ALV' :
    'BRNCH_TEXT' 'BPIG' 'CO_OBJNR'  ''  '24'   TEXT-035 '' '' space 'L'.

    IF t_alv-masatx(4) GT 2006.
      PERFORM f_fieldcatg USING 'T_ALV' :
        'FAKTURNO2' '' ''  ''  '22'   TEXT-031 '' ''
        space 'L'.
    ELSE.
      PERFORM f_fieldcatg USING 'T_ALV' :
        'FAKTURNO' 'ZGDTXDT0003' 'FAKTURNO'  ''  '22'   TEXT-031 '' ''
        space 'C'.
    ENDIF.

***added by Rahmadi for MKM 03/03/2004
    PERFORM f_fieldcatg USING 'T_ALV' :
      'FORM' 'ZGDTXDT0003' 'FORM' '' '4' 'Form' '' '' space 'C',
***end of addition
    'VBELN'        'VBRK' 'VBELN'  ''  '12'   TEXT-006 '' '' space 'C',
    'FKDAT'        'VBRK' 'FKDAT'  ''  '12'   TEXT-007 '' '' space 'C',
    'NAME'         'RW01A' 'AKTST'  ''  '42'   TEXT-032 '' '' space 'L',
    'NPWP'         'KNA1' 'STCEG'  ''  '22'   TEXT-033 '' '' space 'C',
    'TYPEX'        'LIPS' 'ARKTX'  ''  '35'   TEXT-008 '' '' space 'L',
***added for Tempo 28/06/2005
    'BELNR'        'BSEG' 'BELNR'  ''  '12'   TEXT-044 '' '' space 'C'.
***end of Tempo addition

    PERFORM f_fieldcatg_qty USING 'T_ALV' :
      'QTYXX' 'ZGDTXdt0002' 'ITQTYLAST' '' '15'
       TEXT-009 'X' '' space 'R'.

    PERFORM f_fieldcatg USING 'T_ALV' :
      'EXCLUDE'     '' ''  ''     '6' TEXT-042 ''  '' space 'C'.

****removed for Tempo ---not relevant
*  PERFORM f_fieldcatg USING 'T_ALV' :
*    'PSTYV'     '' ''  ''     '6' 'Category' ''  '' space 'C'.
****added by Rahmadi
*  PERFORM f_fieldcatg USING 'T_ALV' :
*    'RANGKA' 'ZGDTXDT0002' 'RANGKA' '' '18' 'No.Rangka' '' '' space 'C'
*.
*  PERFORM f_fieldcatg USING 'T_ALV' :
*    'MESIN'  'ZGDTXDT0002' 'MESIN' ''  '20' 'No.Mesin' ''  '' space 'C'
*.
****end of addition
****end of removal

    PERFORM f_fieldcatg USING 'T_ALV' :
      'WAERS'  'ZGDTXDT0002' 'WAERS'  '' '6' 'Curcy' ''  '' space 'C'.

    IF t_alv-brnch EQ '8160'.
      PERFORM f_fieldcatg_curr USING 'T_ALV' :
        'HRUNT' 'FEBKO' 'SUMSO' ''       '15' TEXT-010
        'X' '' space space '' 'R'.
    ELSE.
      PERFORM f_fieldcatg_curr USING 'T_ALV' :
      'HRUNT' 'FEBKO' 'SUMSO' ''       '15' TEXT-010
      'X' '' space space 'WAERS' 'R'.
    ENDIF.

****removed for Tempo -- not relevant
*    'KARSR' 'FEBKO' 'SUMSO' ''       '15' text-011
*    'X' '' space space 'WAERS' 'R',
*    'OPTNL' 'FEBKO' 'SUMSO' ''       '15' text-012
*    'X' '' space space 'WAERS' 'R',
****end of Tempo removal
    PERFORM f_fieldcatg_curr USING 'T_ALV' :
    'ITDISC' 'FEBKO' 'SUMSO' ''  '15' TEXT-013
    'X' '' space space 'WAERS' 'R',
    'EKSBBM' 'FEBKO' 'SUMSO' ''      '15' TEXT-014
    'X' '' space space 'WAERS' 'R',
    'DPP_02' 'FEBKO' 'SUMSO' ''     '15' TEXT-015
    'X' '' space space 'WAERS' 'R',
    'DPP' 'FEBKO' 'SUMSO' ''     '15' TEXT-046
    'X' '' space space 'WAERS' 'R',
    'FAKPPN' 'FEBKO' 'SUMSO' ''     '15' TEXT-016
    'X' '' space space 'WAERS' 'R',
    'PPNBM' 'FEBKO' 'SUMSO' ''   '15' TEXT-017
    'X' '' space space 'WAERS' 'R',
    'PPH22' 'FEBKO' 'SUMSO' ''       '15' 'PPh 22'
    'X' '' space space 'WAERS' 'R',
    'ITOTH' 'FEBKO' 'SUMSO' ''       '15' TEXT-018
    'X' '' space space 'WAERS' 'R',
    'TOTFJ' 'FEBKO' 'SUMSO' ''       '15' TEXT-019
    'X' '' space space 'WAERS' 'R'.

    IF p_bukrs = '8800'.
      PERFORM f_fieldcatg USING 'T_ALV' :
        'INCO2' 'VBRK' 'INCO2' '' '' 'Incoterms' '' '' space 'C'.
    ENDIF.
****removed for Tempo -- not relevant
*    'PPH22' 'FEBKO' 'SUMSO' ''       '15' 'PPh 22'
*    'X' '' space space 'WAERS' 'R',
*    'PPH23' 'FEBKO' 'SUMSO' ''       '15' 'PPh 23'
*    'X' '' space space 'WAERS' 'R'.
****end of Tempo removal
***added for Tempo --- eSPT formatting

    IF p_lfpst IS NOT INITIAL.
      PERFORM f_fieldcatg USING  'T_ALV' :
       'DELIV'  'ZGDTXST0013' 'DELIV' 'X' '' 'DN Number'
               '' '' '' '',
       'NOINV'  'ZGDTXST0013' 'NOINV' 'X' '' 'Invoice No'
               '' '' '' '',
       'DUEDT'  'ZGDTXST0013' 'DUEDT' 'X' '' 'Due Date'
               '' '' '' '',
       'KUNAG'  'ZGDTXST0013' 'KUNAG' 'X' '' 'Sold To'
               '' '' '' '',
       'KUNNR'  'ZGDTXST0013' 'KUNNR' 'X' '' 'Customer'
               '' '' '' '',
        'MATNR'  'ZGDTXST0013' 'MATNR' 'X' '' 'Material'
               '' '' '' ''.
      PERFORM f_fieldcatg_curr USING 'T_ALV' :
         'MATERAI'  'ZGDTXST0013' 'MATERAI' 'X' '15' 'Materai'
                 '' '' '' '' 'WAERS' '',
         'PREPAID'  'ZGDTXST0013' 'PREPAID' 'X' '15' 'Prepaid'
                 '' '' '' '' 'WAERS' ''.
    ENDIF.
  ELSE.
    IF p_masatx(4) GT 2006.
      PERFORM f_list_espt1 USING fieldcat[].
    ELSE.
      PERFORM f_list_espt USING fieldcat[].
    ENDIF.
  ENDIF.
***end of Tempo addition

ENDFORM.                    " F_FIELD_CATALOG_LFPST

*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT_LFPST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_layout_lfpst.

  CLEAR layout.
  layout-zebra = 'X'.
  layout-colwidth_optimize  = space.
  layout-no_colhead         = space.
  layout-group_change_edit  = 'X'.
  layout-cell_merge         = 'X'.
* layout-f2code             = '&IC1'.   "At Line Selection-Double Click
* layout-coltab_fieldname   = 'COLOR'.  "Assign Color Fields
* layout-totals_text        = text-027. "Text On First Column

ENDFORM.                    " F_LAYOUT_LFPST

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_SORT_LFPST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_field_sort_lfpst.

  IF p_espt IS INITIAL.
    CLEAR sort.
    sort-tabname = 'T_ALV'.
    sort-up      = 'X'.
    sort-spos = 1.
    sort-fieldname = 'BRNCH_TEXT'.
    sort-up        = 'X'.
    sort-subtot    = 'X'.
    APPEND sort.

    CLEAR sort.
    sort-tabname = 'T_ALV'.
    sort-up      = 'X'.
    sort-spos = 1.
    sort-fieldname = 'FAKTURNO'.
    sort-up        = 'X'.
    APPEND sort.
  ENDIF.

ENDFORM.                    " F_FIELD_SORT_LFPST

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL_LFPST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_list_detail_lfpst.

  repid = sy-repid.
  print-no_print_listinfos = 'X'.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program      = repid
*     i_callback_pf_status_set = 'F_ALV_STATUS'
      i_callback_user_command = 'F_USER_COMMAND'
      is_layout               = layout
      it_fieldcat             = fieldcat[]
      it_events               = tab_events[]
      it_event_exit           = tab_events_exit[]
      i_default               = 'X'
      i_save                  = d_save
      is_variant              = d_variant
*     is_keyinfo              = keyinfo
      is_print                = print
      it_sort                 = sort[]
      it_excluding            = excluding[]
      i_bypassing_buffer      = 'X'
    TABLES
      t_outtab                = t_alv
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

ENDFORM.                    " F_LIST_DETAIL_LFPST

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_ALV_LFPSD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_alv_lfpsd.

  DATA : ld_item_text LIKE zgdtxdt0002-item,
         ld_vbeln     LIKE zgdtxdt0002-vbeln.

* -- Settlement Pajak - Masa Pajak
  d_masatx = p_masatx.

  CLEAR : ld_item_text,ld_vbeln.
  CLEAR : d_fakdat.
  SORT t_pajak BY brnch vbeln fkdat.
  LOOP AT t_pajak.

* -- Branch Text
    CLEAR zgdtxdt0101.
    SELECT SINGLE * FROM zgdtxdt0101
     WHERE brnch EQ t_pajak-brnch.

    CONCATENATE t_pajak-brnch zgdtxdt0101-bdesc INTO t_alv-brnch_text
    SEPARATED BY space.

* -- Lampiran Faktur Pajak Gabungan
* -- Key Fields
    t_alv-brnch      = t_pajak-brnch.
    t_alv-vbeln      = t_pajak-vbeln.
    t_alv-fkdat      = t_pajak-fkdat.
    t_alv-name       = t_pajak-name.
* -- MD1
*   t_alv-npwp       = t_pajak-npwp.
* -- MD1

****added by Rahmadi
    t_alv-typex = t_pajak-item.
    t_alv-rangka = t_pajak-rangka.
    t_alv-mesin = t_pajak-mesin.
    t_alv-form  = t_pajak-form.   "for MKM 03/03/2004
    t_alv-belnr = t_pajak-belnr.  "for Tempo 28/06/2005
****end of addition

* -- Sum Fields
* -- Type, Quantity, Harga Unit
    IF t_pajak-karoseri EQ 'U' OR t_pajak-karoseri EQ space.
      t_alv-qtyxx      = t_pajak-itqtylast.
      t_alv-hrunt      = t_pajak-itamtlast.
* -- Karoseri
    ELSEIF t_pajak-karoseri EQ 'K'.
      t_alv-karsr      = t_pajak-itamtlast.
* -- Optional
    ELSEIF t_pajak-karoseri EQ 'A'.
      t_alv-optnl      = t_pajak-itamtlast.
    ENDIF.

* -- MD2 Not Used
*   t_alv-itdisc = t_pajak-itdisc.
*   t_alv-eksbbm = t_pajak-xppnbm.
*   t_alv-dpp    = t_pajak-dpp.
*   t_alv-fakppn = t_pajak-fakppn.
*   t_alv-ppnbm  = t_pajak-ppnbm.
* -- MD2 Changes
    t_alv-itdisc = t_pajak-itdisclast.
    t_alv-eksbbm = t_pajak-xppnbmlast.
    t_alv-dpp    = t_pajak-dpplast.
    t_alv-fakppn = t_pajak-ppnlast.
    t_alv-ppnbm  = t_pajak-ppnbmlast.
    t_alv-pstyv  = t_pajak-pstyv.
* -- MD2

***added by Rahmadi
    t_alv-pph22 = t_pajak-pph22.
    t_alv-pph23 = t_pajak-pph23.
    t_alv-waers = t_pajak-waers.
***end of addition

* -- Global
*   t_alv-itoth      = t_pajak-itoth.  "MD2
    t_alv-itoth      = t_pajak-itothlast.  "MD2
* -- Harga Unit + Karoseri + Optional - Discount + Others + PPNBM + PPN
    IF t_pajak-exclude EQ 'X'.
      t_alv-totfj      = t_alv-hrunt + t_alv-karsr + t_alv-optnl -
*                        t_alv-itdisclast +  "MD2
                         t_alv-itdisc     +      "MD2
                         t_alv-itoth +
*                        t_alv-eksbbm +
*                        t_alv-ppnbmlast + t_alv-ppnlast.  "MD2
                         t_alv-ppnbm + t_alv-fakppn + t_alv-pph22.    "MD2
* -- Harga Unit + Karoseri + Optional - Discount + Others + PPNBM
    ELSE.
      t_alv-totfj      = t_alv-hrunt + t_alv-karsr + t_alv-optnl -
*                        t_alv-itdisclast +  "MD2
                         t_alv-itdisc     +      "MD2
                         t_alv-itoth +
*                        t_alv-eksbbm +
*                        t_alv-ppnbmlast.  "MD2
                         t_alv-ppnbm + t_alv-pph22. "MD2
    ENDIF.

    COLLECT t_alv.
    CLEAR : t_pajak,t_alv.

  ENDLOOP.

***added for Tempo --- e-SPT format
  IF NOT p_espt IS INITIAL.
    PERFORM collect_t_alv.
    PERFORM f_format_to_espt.
  ENDIF.
***end of Tempo addition

****Removed by Rahmadi
** -- Get Text ITEM Field
*  DATA : BEGIN OF lt_item OCCURS 10.
*          INCLUDE STRUCTURE zGDTXdt0002.
*  DATA : END OF lt_item.
*
*  LOOP AT t_alv.
*
** -- Find First ITEM Text if KAROSERI 'U'
*    CLEAR lt_item. REFRESH lt_item.
*    CLEAR zGDTXdt0002.
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_item
*    FROM zGDTXdt0002 WHERE bukrs EQ    p_bukrs        AND
*                             brnch EQ    t_alv-brnch    AND
*                             vbeln EQ    t_alv-vbeln    AND
*                             fkdat EQ    t_alv-fkdat    AND
*                             karoseri EQ 'U'.
*    IF sy-subrc EQ 0.
*      LOOP AT lt_item.
*        t_alv-typex = lt_item-item.
*        EXIT.
*      ENDLOOP.
*    ELSE.
** -- Second ITEM Text if KAROSERI first blank
*      CLEAR lt_item. REFRESH lt_item.
*      CLEAR zGDTXdt0002.
*      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_item
*      FROM zGDTXdt0002 WHERE bukrs EQ    p_bukrs        AND
*                               brnch EQ    t_alv-brnch    AND
*                               vbeln EQ    t_alv-vbeln    AND
*                               fkdat EQ    t_alv-fkdat    AND
*                               karoseri EQ space.
*      IF sy-subrc EQ 0.
*        SORT lt_item BY posnr.
*        LOOP AT lt_item.
*          t_alv-typex = lt_item-item.
*          EXIT.
*        ENDLOOP.
*      ENDIF.
*    ENDIF.
*
*    MODIFY t_alv.
*    CLEAR t_alv.
*
*  ENDLOOP.
** --
****end of removal

  CLEAR d_count.
  CLEAR d_brnch.
  LOOP AT t_alv.

    IF d_brnch NE t_alv-brnch.
      CLEAR d_count.
    ENDIF.
    d_brnch = t_alv-brnch.

    ADD 1 TO d_count.
    t_alv-count = d_count.
    MODIFY t_alv TRANSPORTING count.
  ENDLOOP.

ENDFORM.                    " F_COLLECT_ALV_LFPSD

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT_LFPSD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_event_lfpsd.

  IF p_espt IS INITIAL.
    CLEAR comm_event.
    comm_event-name = slis_ev_top_of_page.
    comm_event-form = 'F_HEADER_REPORT'.
    APPEND comm_event TO tab_events.

    CLEAR comm_event.
    comm_event-name = slis_ev_before_line_output.
    comm_event-form = 'F_BEFORE_LINE_OUTPUT'.
    APPEND comm_event TO tab_events.
  ENDIF.

ENDFORM.                    " F_BUILD_EVENT_LFPSD

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT_EXIT_LFPSD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_event_exit_lfpsd.

  CLEAR tab_events_exit.
  tab_events_exit-ucomm = '&OUP'.
  tab_events_exit-after = 'X'.
  APPEND tab_events_exit.

  CLEAR tab_events_exit.
  tab_events_exit-ucomm = '&ODN'.
  tab_events_exit-after = 'X'.
  APPEND tab_events_exit.

ENDFORM.                    " F_BUILD_EVENT_EXIT_LFPSD

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_LFPSD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_field_catalog_lfpsd.

  IF p_espt IS INITIAL.
    PERFORM f_fieldcatg_qty USING 'T_ALV' :
      'COUNT' 'AGDB' 'CLUSTR' '' '7' TEXT-005 '' '' space 'R'.

    PERFORM f_fieldcatg USING 'T_ALV' :
    'BRNCH_TEXT' 'BPIG' 'CO_OBJNR'  ''  '24'   TEXT-035 '' '' space 'L',
     'VBELN'        'VBRK' 'VBELN'  ''  '12'   TEXT-006 '' '' space 'C',
***added by Rahmadi for MKM 03/03/2004
      'FORM' 'ZGDTXDT0003' 'FORM' '' '4' 'Form' '' '' space 'C',
***end of addition
     'FKDAT'        'VBRK' 'FKDAT'  ''  '12'   TEXT-007 '' '' space 'C',
      'NAME'       'RW01A' 'AKTST'  ''  '42'   TEXT-032 '' '' space 'L',
* -- MD1
*   'NPWP'         '' ''  ''  '22'   text-033 '' '' space 'C',
* -- MD1
      'TYPEX'   'LIPS' 'ARKTX'  ''  '35'   TEXT-008 '' '' space 'L',
***added for Tempo 28/06/2005
    'BELNR'        'BSEG' 'BELNR'  ''  '12'   TEXT-044 '' '' space 'C'.
***end of Tempo addition

    PERFORM f_fieldcatg_qty USING 'T_ALV' :
*   'QTYXX' 'AGDB' 'CLUSTR' '' '7' text-009 'X' '' space 'R'.
      'QTYXX' 'ZGDTXdt0002' 'ITQTYLAST' '' '15'
              TEXT-009 'X' '' space 'R'.

    PERFORM f_fieldcatg USING 'T_ALV' :
      'PSTYV'     '' ''  ''     '6' 'Category' ''  '' space 'C'.

***removed for Tempo --- not relevant
****added by Rahmadi
*  PERFORM f_fieldcatg USING 'T_ALV' :
*    'RANGKA' 'ZGDTXDT0002' 'RANGKA' '' '18' 'No.Rangka' '' '' space 'C'
*.
*  PERFORM f_fieldcatg USING 'T_ALV' :
*    'MESIN'  'ZGDTXDT0002' 'MESIN' ''  '20' 'No.Mesin' ''  '' space 'C'
*.
****end of addition
***end of Tempo removal

    PERFORM f_fieldcatg USING 'T_ALV' :
      'WAERS'  'ZGDTXDT0002' 'WAERS'  '' '6' 'Curcy' ''  '' space 'C'.

    PERFORM f_fieldcatg_curr USING 'T_ALV' :
      'HRUNT' 'FEBKO' 'SUMSO' ''       '15' TEXT-010
      'X' '' space space 'WAERS' 'R',
      'KARSR' 'FEBKO' 'SUMSO' ''       '15' TEXT-011
      'X' '' space space 'WAERS' 'R',
      'OPTNL' 'FEBKO' 'SUMSO' ''       '15' TEXT-012
      'X' '' space space 'WAERS' 'R',
      'ITDISC' 'FEBKO' 'SUMSO' ''  '15' TEXT-013
      'X' '' space space 'WAERS' 'R',
      'EKSBBM' 'FEBKO' 'SUMSO' ''      '15' TEXT-014
      'X' '' space space 'WAERS' 'R',
      'DPP' 'FEBKO' 'SUMSO' ''     '15' TEXT-015
      'X' '' space space 'WAERS' 'R',
      'FAKPPN' 'FEBKO' 'SUMSO' ''     '15' TEXT-016
      'X' '' space space 'WAERS' 'R',
      'PPNBM' 'FEBKO' 'SUMSO' ''   '15' TEXT-017
      'X' '' space space 'WAERS' 'R',
      'PPH22' 'FEBKO' 'SUMSO' ''       '15' 'PPh 22'
      'X' '' space space 'WAERS' 'R',
      'ITOTH' 'FEBKO' 'SUMSO' ''       '15' TEXT-018
      'X' '' space space 'WAERS' 'R',
      'TOTFJ' 'FEBKO' 'SUMSO' ''       '15' TEXT-019
      'X' '' space space 'WAERS' 'R'.

****removed for Tempo
*    'PPH22' 'FEBKO' 'SUMSO' ''       '15' 'PPh 22'
*    'X' '' space space 'WAERS' 'R',
*    'PPH23' 'FEBKO' 'SUMSO' ''       '15' 'PPh 23'
*    'X' '' space space 'WAERS' 'R'.
****end of Tempo removal
***added for Tempo --- eSPT formatting
  ELSE.
    IF p_masatx(4) GT 2006.
      PERFORM f_list_espt1 USING fieldcat[].
    ELSE.
      PERFORM f_list_espt USING fieldcat[].
    ENDIF.
  ENDIF.
***end of Tempo addition

ENDFORM.                    " F_FIELD_CATALOG_LFPSD

*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT_LFPSD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_layout_lfpsd.

  CLEAR layout.
  layout-zebra = 'X'.
  layout-colwidth_optimize  = space.
  layout-no_colhead         = space.
  layout-group_change_edit  = 'X'.
  layout-cell_merge         = 'X'.
* layout-f2code             = '&IC1'.   "At Line Selection-Double Click
* layout-coltab_fieldname   = 'COLOR'.  "Assign Color Fields
* layout-totals_text        = text-027. "Text On First Column

ENDFORM.                    " F_LAYOUT_LFPSD

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL_LFPSD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_list_detail_lfpsd.

  repid = sy-repid.
  print-no_print_listinfos = 'X'.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program      = repid
*     i_callback_pf_status_set = 'F_ALV_STATUS'
      i_callback_user_command = 'F_USER_COMMAND'
      is_layout               = layout
      it_fieldcat             = fieldcat[]
      it_events               = tab_events[]
      it_event_exit           = tab_events_exit[]
      i_default               = 'X'
      i_save                  = d_save
      is_variant              = d_variant
*     is_keyinfo              = keyinfo
      is_print                = print
      it_sort                 = sort[]
      it_excluding            = excluding[]
      i_bypassing_buffer      = 'X'
    TABLES
      t_outtab                = t_alv
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

ENDFORM.                    " F_LIST_DETAIL_LFPSD

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_ALV_LNRST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_alv_lnrst.

  DATA : ld_item_text LIKE zgdtxdt0002-item,
         ld_vbeln     LIKE zgdtxdt0002-vbeln.

  DATA : lv_faktur(20),
         lv_length    TYPE i.

* -- Settlement Pajak - Masa Pajak
  d_masatx = p_masatx.

  CLEAR : ld_item_text,ld_vbeln.
  CLEAR : d_fakdat.
  SORT t_pajak BY brnch noretur dtretur fakturno fakdat.
  LOOP AT t_pajak WHERE noretur NE space AND   "MD1
                        dtretur NE '00000000'.  "MD1

* -- Branch Text
    CLEAR zgdtxdt0101.
    SELECT SINGLE * FROM zgdtxdt0101
     WHERE brnch EQ t_pajak-brnch.

    CONCATENATE t_pajak-brnch zgdtxdt0101-bdesc INTO t_alv-brnch_text
    SEPARATED BY space.

* -- Lampiran Faktur Pajak Gabungan
* -- Key Fields
    t_alv-brnch      = t_pajak-brnch.

    IF p_bukrs EQ '8050' OR p_bukrs EQ '8800' OR
      p_bukrs EQ '8230'.
      t_alv-vbeln      = t_pajak-vbeln.
    ENDIF.

    t_alv-noretur    = t_pajak-noretur.
    t_alv-dtretur    = t_pajak-dtretur.

    t_alv-fakturno   = t_pajak-fakturno.
    PERFORM f_coretax_format USING t_pajak-fakturno
                             CHANGING t_alv-fakturno2.

    IF t_alv-fakturno2 IS INITIAL.
****Change by Budi
*    IF t_pajak-fakdat(4) GT 2006.
      IF t_pajak-masatx(4) GT 2006.
****End of change
        IF t_pajak-fakdat IS INITIAL.
          t_pajak-fakdat = t_pajak-fkdat.
        ENDIF.
        CALL FUNCTION 'ZF_FAKTUR'
          EXPORTING
            bukrs     = t_pajak-bukrs
            fakdat    = t_pajak-fakdat
            masatx    = t_pajak-masatx
            fakturin  = t_pajak-fakturno
          IMPORTING
            fakturout = t_alv-fakturno1.
      ELSE.
        CONCATENATE t_pajak-fakturno(3) '.' t_pajak-fakturno+3(3)
                    '-' t_pajak-fakturno+6(2) '.' t_pajak-fakturno+8(8)
          INTO t_alv-fakturno1.
      ENDIF.
      t_alv-fakturno2 = t_alv-fakturno1.
    ENDIF.

    t_alv-masatx     = t_pajak-masatx.
    t_alv-fakdat     = t_pajak-fakdat.
    t_alv-name       = t_pajak-name.
    t_alv-npwp       = t_pajak-npwp.
    t_alv-exclude    = t_pajak-exclude.

****added by Rahmadi
    t_alv-typex = t_pajak-item.
    t_alv-rangka = t_pajak-rangka.
    t_alv-mesin = t_pajak-mesin.
    t_alv-form  = t_pajak-form.   "for MKM 03/03/2004
    t_alv-belnr = t_pajak-belnr.  "for Tempo 28/06/2005
****end of addition

* -- Sum Fields
* -- Type, Quantity, Harga Unit
    IF t_pajak-karoseri EQ 'U' OR t_pajak-karoseri EQ space.
      t_alv-qtyxx      = t_pajak-itqtylast.
      t_alv-hrunt      = t_pajak-itamtlast.
* -- Karoseri
    ELSEIF t_pajak-karoseri EQ 'K'.
      t_alv-karsr      = t_pajak-itamtlast.
* -- Optional
    ELSEIF t_pajak-karoseri EQ 'A'.
      t_alv-optnl      = t_pajak-itamtlast.
    ENDIF.

* -- MD2 Not Used
*   t_alv-itdisc = t_pajak-itdisc.
*   t_alv-eksbbm = t_pajak-xppnbm.
*   t_alv-dpp    = t_pajak-dpp.
*   t_alv-fakppn = t_pajak-fakppn.
*   t_alv-ppnbm  = t_pajak-ppnbm.
* -- MD2 Changes
    t_alv-itdisc = t_pajak-itdisclast.
    t_alv-eksbbm = t_pajak-xppnbmlast.
    t_alv-dpp    = t_pajak-dpplast.
    t_alv-fakppn = t_pajak-ppnlast.
    t_alv-ppnbm  = t_pajak-ppnbmlast.
    t_alv-pstyv  = t_pajak-pstyv.
* -- MD2

***added by Rahmadi
    t_alv-pph22 = t_pajak-pph22.
    t_alv-pph23 = t_pajak-pph23.
    t_alv-waers = t_pajak-waers.
***end of addition

* -- Global
*   t_alv-itoth      = t_pajak-itoth.  "MD2
    t_alv-itoth      = t_pajak-itothlast.  "MD2
* -- Harga Unit + Karoseri + Optional - Discount + Others + PPNBM + PPN

    t_alv-total      = t_pajak-dpplast + t_pajak-ppnlast.

    IF t_pajak-exclude EQ 'X'.
      t_alv-totfj      = t_alv-hrunt + t_alv-karsr + t_alv-optnl -
*                        t_alv-itdisclast +  "MD2
                         t_alv-itdisc +  "MD2
                         t_alv-itoth +
*                        t_alv-eksbbm +
*                        t_alv-ppnbmlast + t_alv-ppnlast.  "MD2
                         t_alv-ppnbm + t_alv-fakppn.  "MD2
* -- Harga Unit + Karoseri + Optional - Discount + Others + PPNBM
    ELSE.
      t_alv-totfj      = t_alv-hrunt + t_alv-karsr + t_alv-optnl -
*                        t_alv-itdisclast +  "MD2
                         t_alv-itdisc +  "MD2
                         t_alv-itoth +
*                        t_alv-eksbbm +
*                        t_alv-ppnbmlast.
                         t_alv-ppnbm.  "MD2
    ENDIF.

    COLLECT t_alv.
    CLEAR : t_pajak,t_alv.
  ENDLOOP.

  PERFORM f_kurs_non_idr.

***added for Tempo --- e-SPT format
  IF NOT p_espt IS INITIAL.
    PERFORM collect_t_alv.
    PERFORM f_format_to_espt.
  ENDIF.
***end of Tempo addition

****Removed by Rahmadi
** -- Get Text ITEM Field
*  DATA : BEGIN OF lt_item OCCURS 10.
*          INCLUDE STRUCTURE zGDTXdt0002.
*  DATA : END OF lt_item.
*
*  LOOP AT t_alv.
*
** -- Find First ITEM Text if KAROSERI 'U'
*    CLEAR lt_item. REFRESH lt_item.
*    CLEAR zGDTXdt0002.
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_item
*    FROM zGDTXdt0002 WHERE bukrs    EQ p_bukrs        AND
*                             brnch    EQ t_alv-brnch    AND
*                             noretur  EQ t_alv-noretur  AND
*                             dtretur  EQ t_alv-dtretur  AND
*                             fakturno EQ t_alv-fakturno AND
*                             karoseri EQ 'U'.
*    IF sy-subrc EQ 0.
*      LOOP AT lt_item.
*        t_alv-typex = lt_item-item.
*        EXIT.
*      ENDLOOP.
*    ELSE.
** -- Second ITEM Text if KAROSERI first blank
*      CLEAR lt_item. REFRESH lt_item.
*      CLEAR zGDTXdt0002.
*      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_item
*      FROM zGDTXdt0002 WHERE bukrs    EQ p_bukrs        AND
*                               brnch    EQ t_alv-brnch    AND
*                               noretur  EQ t_alv-noretur  AND
*                               dtretur  EQ t_alv-dtretur  AND
*                               fakturno EQ t_alv-fakturno AND
*                               karoseri EQ space.
*      IF sy-subrc EQ 0.
*        SORT lt_item BY posnr.
*        LOOP AT lt_item.
*          t_alv-typex = lt_item-item.
*          EXIT.
*        ENDLOOP.
*      ENDIF.
*    ENDIF.
*
*    MODIFY t_alv.
*    CLEAR t_alv.
*
*  ENDLOOP.
** --
****end of removal

  SELECT SINGLE * INTO @DATA(ls_zproject)
    FROM zproject WHERE name = 'DPP12'
                    AND flag = 'X'.

  CLEAR d_count.
  CLEAR d_brnch.
  LOOP AT t_alv.

    IF d_brnch NE t_alv-brnch.
      CLEAR d_count.
    ENDIF.
    d_brnch = t_alv-brnch.

    ADD 1 TO d_count.
    t_alv-count = d_count.
    MODIFY t_alv TRANSPORTING count.

    IF t_alv-noretur IS NOT INITIAL AND
       t_alv-dtretur >= ls_zproject-datab.
      t_alv-dpp = t_alv-dpp * 11 / 12.
      t_alv-total = t_alv-dpp + t_alv-fakppn.
      MODIFY t_alv TRANSPORTING dpp total.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " F_COLLECT_ALV_LNRST

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT_LNRST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_event_lnrst.

  IF p_espt IS INITIAL.
    CLEAR comm_event.
    comm_event-name = slis_ev_top_of_page.
    comm_event-form = 'F_HEADER_REPORT'.
    APPEND comm_event TO tab_events.

    CLEAR comm_event.
    comm_event-name = slis_ev_before_line_output.
    comm_event-form = 'F_BEFORE_LINE_OUTPUT'.
    APPEND comm_event TO tab_events.
  ENDIF.

ENDFORM.                    " F_BUILD_EVENT_LNRST

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT_EXIT_LNRST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_event_exit_lnrst.

  CLEAR tab_events_exit.
  tab_events_exit-ucomm = '&OUP'.
  tab_events_exit-after = 'X'.
  APPEND tab_events_exit.

  CLEAR tab_events_exit.
  tab_events_exit-ucomm = '&ODN'.
  tab_events_exit-after = 'X'.
  APPEND tab_events_exit.

ENDFORM.                    " F_BUILD_EVENT_EXIT_LNRST

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_LNRST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_field_catalog_lnrst.

  IF p_espt IS INITIAL.
    PERFORM f_fieldcatg_qty USING 'T_ALV' :
      'COUNT' 'AGDB' 'CLUSTR' '' '7' TEXT-005 '' '' space 'R'.

    PERFORM f_fieldcatg USING 'T_ALV' :
    'BRNCH_TEXT' 'BPIG' 'CO_OBJNR'  ''  '24'   TEXT-035 '' '' space 'L',
***added by Rahmadi for MKM 03/03/2004
      'FORM' 'ZGDTXDT0003' 'FORM' '' '4' 'Form' '' '' space 'C',
***end of addition
      'NORETUR' 'zGDTXdt0003' 'NORETUR'
                ''  '18'   TEXT-037 '' '' space 'L',
      'DTRETUR' 'zGDTXdt0003' 'DTRETUR'
                ''  '12'   TEXT-038 '' '' space 'C'.

    IF t_alv-masatx(4) GT 2006.
      PERFORM f_fieldcatg USING 'T_ALV' :
        'FAKTURNO2' '' '' '' '23' TEXT-025 '' '' space 'L'.
    ELSE.
      PERFORM f_fieldcatg USING 'T_ALV' :
        'FAKTURNO' 'zGDTXdt0003' 'FAKTURNO' ''  '23' TEXT-025 '' ''
        space 'L'.
    ENDIF.

    PERFORM f_fieldcatg USING 'T_ALV' :
  'FAKDAT' 'zGDTXdt0003' 'FAKDAT'
           ''  '12'   TEXT-039 '' '' space 'C',
  'NAME' 'zGDTXdt0003' 'NAME'  ''  '44'   TEXT-032 '' '' space 'L',
  'NPWP' 'zGDTXdt0003' 'NPWP'  ''  '22'   TEXT-033 '' '' space 'C',
 'TYPEX' 'zGDTXdt0003' 'TYPEX'  ''  '35'   TEXT-008 '' '' space 'L',
***added for Tempo 28/06/2005
'BELNR'        'BSEG' 'BELNR'  ''  '12'   TEXT-044 '' '' space 'C'.
***end of Tempo addition

    PERFORM f_fieldcatg_qty USING 'T_ALV' :
       'QTYXX' 'ZGDTXdt0002' 'ITQTYLAST' '' '15' TEXT-009
       'X' '' space 'R'.
    PERFORM f_fieldcatg USING 'T_ALV' :
      'EXCLUDE'     '' ''  ''     '6' TEXT-042 ''  '' space 'C'.

****removed for Tempo --- not relevant
*  PERFORM f_fieldcatg USING 'T_ALV' :
*    'PSTYV'     '' ''  ''     '6' 'Category' ''  '' space 'C'.
****added by Rahmadi
*  PERFORM f_fieldcatg USING 'T_ALV' :
*    'RANGKA' 'ZGDTXDT0002' 'RANGKA' '' '18' 'No.Rangka' '' '' space 'C'
*.
*  PERFORM f_fieldcatg USING 'T_ALV' :
*    'MESIN'  'ZGDTXDT0002' 'MESIN' ''  '20' 'No.Mesin' ''  '' space 'C'
*.
****end of addition
****end of Tempo removal

    PERFORM f_fieldcatg USING 'T_ALV' :
      'WAERS'  'ZGDTXDT0002' 'WAERS'  '' '6' 'Curcy' ''  '' space 'C'.

    PERFORM f_fieldcatg_curr USING 'T_ALV' :
      'HRUNT' 'FEBKO' 'SUMSO' ''       '15' TEXT-010
      'X' '' space space 'WAERS' 'R',

****removed for Tempo --- not relevant
*    'KARSR' 'FEBKO' 'SUMSO' ''       '15' text-011
*    'X' '' space space 'WAERS' 'R',
*    'OPTNL' 'FEBKO' 'SUMSO' ''       '15' text-012
*    'X' '' space space 'WAERS' 'R',
****end of Tempo removal

      'ITDISC' 'FEBKO' 'SUMSO' ''  '15' TEXT-013
      'X' '' space space 'WAERS' 'R',
      'EKSBBM' 'FEBKO' 'SUMSO' ''      '15' TEXT-014
      'X' '' space space 'WAERS' 'R',
      'DPP' 'FEBKO' 'SUMSO' ''     '15' TEXT-015
      'X' '' space space 'WAERS' 'R',
      'FAKPPN' 'FEBKO' 'SUMSO' ''     '15' TEXT-016
      'X' '' space space 'WAERS' 'R',
      'PPNBM' 'FEBKO' 'SUMSO' ''   '15' TEXT-017
      'X' '' space space 'WAERS' 'R'.

    IF p_bukrs = '8040'.
      PERFORM f_fieldcatg_curr USING 'T_ALV' :
        'TOTAL' 'FEBKO' 'SUMSO' ''   '15' TEXT-045
        'X' '' space space 'WAERS' 'R'.
    ELSE.
      PERFORM f_fieldcatg_curr USING 'T_ALV' :
        'TOTAL' 'FEBKO' 'SUMSO' 'X'   '15' TEXT-045
        'X' '' space space 'WAERS' 'R'.
    ENDIF.

***removed for Tempo -- not relevant
*    'PPH22' 'FEBKO' 'SUMSO' ''       '15' 'PPh 22'
*    'X' '' space space 'WAERS' 'R',
*    'PPH23' 'FEBKO' 'SUMSO' ''       '15' 'PPh 23'
*    'X' '' space space 'WAERS' 'R'.
***end of Tempo removal
***added for Tempo --- eSPT formatting
  ELSE.
    IF p_masatx(4) GT 2006.
      PERFORM f_list_espt1 USING fieldcat[].
    ELSE.
      PERFORM f_list_espt USING fieldcat[].
    ENDIF.
  ENDIF.
***end of Tempo addition

ENDFORM.                    " F_FIELD_CATALOG_LNRST

*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT_LNRST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_layout_lnrst.

  CLEAR layout.
  layout-zebra = 'X'.
  layout-colwidth_optimize  = space.
  layout-no_colhead         = space.
  layout-group_change_edit  = 'X'.
  layout-cell_merge         = 'X'.
* layout-f2code             = '&IC1'.   "At Line Selection-Double Click
* layout-coltab_fieldname   = 'COLOR'.  "Assign Color Fields
* layout-totals_text        = text-027. "Text On First Column

ENDFORM.                    " F_LAYOUT_LNRST

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_SORT_LNRST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_field_sort_lnrst.

  IF p_espt IS INITIAL.
    CLEAR sort.
    sort-tabname = 'T_ALV'.
    sort-up      = 'X'.
    sort-spos = 1.
    sort-fieldname = 'BRNCH_TEXT'.
    sort-up        = 'X'.
    sort-subtot    = 'X'.
    APPEND sort.

    CLEAR sort.
    sort-tabname = 'T_ALV'.
    sort-up      = 'X'.
    sort-spos = 1.
    sort-fieldname = 'NORETUR'.
    sort-up        = 'X'.
    APPEND sort.
  ENDIF.

ENDFORM.                    " F_FIELD_SORT_LNRST

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL_LNRST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_list_detail_lnrst.

  repid = sy-repid.
  print-no_print_listinfos = 'X'.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program      = repid
*     i_callback_pf_status_set = 'F_ALV_STATUS'
      i_callback_user_command = 'F_USER_COMMAND'
      is_layout               = layout
      it_fieldcat             = fieldcat[]
      it_events               = tab_events[]
      it_event_exit           = tab_events_exit[]
      i_default               = 'X'
      i_save                  = d_save
      is_variant              = d_variant
*     is_keyinfo              = keyinfo
      is_print                = print
      it_sort                 = sort[]
      it_excluding            = excluding[]
      i_bypassing_buffer      = 'X'
    TABLES
      t_outtab                = t_alv
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

ENDFORM.                    " F_LIST_DETAIL_LNRST

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG_QTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0510   text
*      -->P_0511   text
*      -->P_0512   text
*      -->P_0513   text
*      -->P_0514   text
*      -->P_0515   text
*      -->P_TEXT_028  text
*      -->P_0517   text
*      -->P_0518   text
*      -->P_SPACE  text
*      -->P_0520   text
*----------------------------------------------------------------------*
FORM f_fieldcatg_qty USING fu_types
                           fu_fname
                           fu_reftb
                           fu_refld
                           fu_noout
                           fu_outln
                           fu_fltxt
                           fu_dosum
                           fu_hotsp
                           fu_dec
                           fu_just.


  CLEAR: fieldcat.
  fieldcat-tabname       = fu_types.
  fieldcat-fieldname     = fu_fname.
  fieldcat-ref_tabname   = fu_reftb.
  fieldcat-ref_fieldname = fu_refld.
  fieldcat-no_out        = fu_noout.
  fieldcat-outputlen     = fu_outln.
  fieldcat-seltext_l     = fu_fltxt.
  fieldcat-seltext_m     = fu_fltxt.
  fieldcat-seltext_s     = fu_fltxt.
  fieldcat-reptext_ddic  = fu_fltxt.
  fieldcat-do_sum        = fu_dosum.
  fieldcat-hotspot       = fu_hotsp.
  fieldcat-decimals_out  = fu_dec.
  fieldcat-just          = fu_just.
  APPEND fieldcat.
  CLEAR fieldcat.

ENDFORM.                    " F_FIELDCATG_QTY

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0524   text
*      -->P_0525   text
*      -->P_0526   text
*      -->P_0527   text
*      -->P_0528   text
*      -->P_0529   text
*      -->P_TEXT_058  text
*      -->P_0531   text
*      -->P_0532   text
*      -->P_0533   text
*      -->P_0534   text
*----------------------------------------------------------------------*
FORM f_fieldcatg USING fu_types
                       fu_fname
                       fu_reftb
                       fu_refld
                       fu_noout
                       fu_outln
                       fu_fltxt
                       fu_dosum
                       fu_hotsp
                       fu_dec
                       fu_just.

  CLEAR: fieldcat.
  fieldcat-tabname       = fu_types.
  fieldcat-fieldname     = fu_fname.
  fieldcat-ref_tabname   = fu_reftb.
  fieldcat-ref_fieldname = fu_refld.
  fieldcat-no_out        = fu_noout.
  fieldcat-outputlen     = fu_outln.
  fieldcat-seltext_l     = fu_fltxt.
  fieldcat-seltext_m     = fu_fltxt.
  fieldcat-seltext_s     = fu_fltxt.
  fieldcat-reptext_ddic  = fu_fltxt.
  fieldcat-do_sum        = fu_dosum.
  fieldcat-hotspot       = fu_hotsp.
  fieldcat-decimals_out  = fu_dec.
  fieldcat-just          = fu_just.
  APPEND fieldcat.
  CLEAR fieldcat.

ENDFORM.                    " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG_CURR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0566   text
*      -->P_0567   text
*      -->P_0568   text
*      -->P_0569   text
*      -->P_0570   text
*      -->P_0571   text
*      -->P_TEXT_011  text
*      -->P_0573   text
*      -->P_0574   text
*      -->P_SPACE  text
*      -->P_0576   text
*      -->P_0577   text
*----------------------------------------------------------------------*
FORM f_fieldcatg_curr USING fu_types
                            fu_fname
                            fu_reftb
                            fu_refld
                            fu_noout
                            fu_outln
                            fu_fltxt
                            fu_dosum
                            fu_hotsp
                            fu_dec
                            fu_waers
                            fu_cfield
                            fu_just.

  CLEAR: fieldcat.
  fieldcat-tabname       = fu_types.
  fieldcat-fieldname     = fu_fname.
  fieldcat-ref_tabname   = fu_reftb.
  fieldcat-ref_fieldname = fu_refld.
  fieldcat-no_out        = fu_noout.
  fieldcat-outputlen     = fu_outln.
  fieldcat-seltext_l     = fu_fltxt.
  fieldcat-seltext_m     = fu_fltxt.
  fieldcat-seltext_s     = fu_fltxt.
  fieldcat-reptext_ddic  = fu_fltxt.
  fieldcat-do_sum        = fu_dosum.
  fieldcat-hotspot       = fu_hotsp.
  fieldcat-decimals_out  = fu_dec.
  fieldcat-datatype      = 'CURR'.
  fieldcat-cfieldname    = fu_cfield.
  fieldcat-currency      = fu_waers.
  fieldcat-just          = fu_just.
  APPEND fieldcat.
  CLEAR fieldcat.

ENDFORM.                    " F_FIELDCATG_CURR

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  fu_ucomm                                                      *
*  -->  fu_selfield                                                   *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm     LIKE sy-ucomm
                          fu_selfield  TYPE slis_selfield.

  IF ( fu_ucomm EQ '&ODN' OR fu_ucomm EQ '&OUP' ). "PgUp - PgDw
    PERFORM f_change_sequential_data.
  ENDIF.
  CLEAR t_alv.

ENDFORM.                    "f_user_command

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_SEQUENTIAL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_change_sequential_data.

  DATA : ld_count TYPE i.

* -- MD4
* -- Lampiran Faktur Pajak Gabungan All
*  if p_lfpgg eq 'X'.
*    CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_GET'
*         IMPORTING
*              et_sort = t_sort.
* -- Get Sort field
*    perform f_get_sort_field.

*    clear ld_count.
*    loop at t_alv.
*      if d_fpnum ne space.
*        on change of t_alv-fakturno.
*          clear ld_count.
*        endon.
*      endif.
*      add 1 to ld_count.
*      t_alv-count = ld_count.
*      MODIFY t_alv INDEX sy-tabix TRANSPORTING count.
*    endloop.

*  else.
* -- MD4
  LOOP AT t_alv.
    t_alv-count = sy-tabix.
    MODIFY t_alv INDEX sy-tabix TRANSPORTING count.
  ENDLOOP.
*  endif.

ENDFORM.                    " F_CHANGE_SEQUENTIAL_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_SORT_LFPSD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_field_sort_lfpsd.

  IF p_espt IS INITIAL.
    CLEAR sort.
    sort-tabname = 'T_ALV'.
    sort-up      = 'X'.
    sort-spos = 1.
    sort-fieldname = 'BRNCH_TEXT'.
    sort-up        = 'X'.
    sort-subtot    = 'X'.
    APPEND sort.

    CLEAR sort.
    sort-tabname = 'T_ALV'.
    sort-up      = 'X'.
    sort-spos = 1.
    sort-fieldname = 'VBELN'.
    sort-up        = 'X'.
    APPEND sort.
  ENDIF.

ENDFORM.                    " F_FIELD_SORT_LFPSD

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_LFPGB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_header_lfpgb.

* -- Header Constant Box
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING TEXT-020.

  CLEAR t001.
  SELECT SINGLE * FROM t001 WHERE spras EQ 'EN' AND
                                   bukrs EQ p_bukrs.
  PERFORM f_hdr_line2 USING ''. "t001-butxt.

* -- Branch Text
  CLEAR zgdtxdt0101.
  SELECT SINGLE * FROM zgdtxdt0101
   WHERE brnch EQ s_brnch-low.

  PERFORM f_hdr_line3 USING ''. "zGDTXdt0101-bdesc.

  PERFORM f_hdr_uline.
  SKIP.
* -- Header Constant Box

  PERFORM f_standard_header_lfpgb.

ENDFORM.                    " F_HEADER_LFPGB

*&---------------------------------------------------------------------*
*&      Form  F_STANDARD_HEADER_LFPGB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_standard_header_lfpgb.

  DATA : ld_text(100).

  CONCATENATE t001-butxt TEXT-022
  INTO ld_text SEPARATED BY space.
  WRITE : /3 ld_text.
*  WRITE : /3 text-023,s_brnch-low.
*  WRITE : /3 text-024,zGDTXdt0101-bdesc.
  SKIP.
  WRITE : /3 TEXT-020.
  WRITE : /3 TEXT-025,p_faktur,TEXT-026,d_fakdat.
*  WRITE : /3 text-027,d_masatx.
  WRITE : /3 TEXT-028,d_name.
  WRITE : /3 TEXT-029,d_addrs1.
  WRITE : /3 TEXT-030,d_npwp.

ENDFORM.                    " F_STANDARD_HEADER_LFPGB

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_LFPST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_header_lfpst.

* -- Header Constant Box
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING TEXT-034.

  CLEAR t001.
  SELECT SINGLE * FROM t001 WHERE spras EQ 'EN' AND
                                   bukrs EQ p_bukrs.
  PERFORM f_hdr_line2 USING ''. "t001-butxt.

* clear tgsbt.
* select single * from tgsbt where spras eq 'EN' and
*                                  brnch eq s_brnch-low.
  PERFORM f_hdr_line3 USING ' '.
  PERFORM f_hdr_uline.
  SKIP.
* -- Header Constant Box
  PERFORM f_standard_header_lfpst.

ENDFORM.                    " F_HEADER_LFPST

*---------------------------------------------------------------------*
*       FORM F_BEFORE_LINE_OUTPUT                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  fu_lineinfo                                                   *
*---------------------------------------------------------------------*
FORM f_before_line_output   USING fu_lineinfo TYPE slis_lineinfo.

*write : / 'Test ok'.



ENDFORM.                    "f_before_line_output
*&---------------------------------------------------------------------*
*&      Form  F_STANDARD_HEADER_LFPST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_standard_header_lfpst.

  DATA : ld_text(100).

  CONCATENATE t001-butxt TEXT-022
  INTO ld_text SEPARATED BY space.
  WRITE : /3 ld_text.
  SKIP.
  WRITE : /3 TEXT-034.
*  WRITE : /3 text-027,d_masatx.

ENDFORM.                    " F_STANDARD_HEADER_LFPST

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_LFPSD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_header_lfpsd.

* -- Header Constant Box
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING TEXT-036.

  CLEAR t001.
  SELECT SINGLE * FROM t001 WHERE spras EQ 'EN' AND
                                   bukrs EQ p_bukrs.
  PERFORM f_hdr_line2 USING ''. "t001-butxt.

* clear tgsbt.
* select single * from tgsbt where spras eq 'EN' and
*                                  brnch eq s_brnch-low.
  PERFORM f_hdr_line3 USING ' '.
  PERFORM f_hdr_uline.
  SKIP.
* -- Header Constant Box
  PERFORM f_standard_header_lfpsd.

ENDFORM.                    " F_HEADER_LFPSD

*&---------------------------------------------------------------------*
*&      Form  F_STANDARD_HEADER_LFPSD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_standard_header_lfpsd.

  DATA : ld_text(100).

  CONCATENATE t001-butxt TEXT-022
  INTO ld_text SEPARATED BY space.
  WRITE : /3 ld_text.
  SKIP.
  WRITE : /3 TEXT-036.
*  WRITE : /3 text-027,d_masatx.

ENDFORM.                    " F_STANDARD_HEADER_LFPSD

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_LNRST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_header_lnrst.

* -- Header Constant Box
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING TEXT-040.

  CLEAR t001.
  SELECT SINGLE * FROM t001 WHERE spras EQ 'EN' AND
                                   bukrs EQ p_bukrs.
  PERFORM f_hdr_line2 USING ''. "t001-butxt.

* clear tgsbt.
* select single * from tgsbt where spras eq 'EN' and
*                                  brnch eq s_brnch-low.
  PERFORM f_hdr_line3 USING ' '.
  PERFORM f_hdr_uline.
  SKIP.
* -- Header Constant Box
  PERFORM f_standard_header_lnrst.

ENDFORM.                    " F_HEADER_LNRST

*&---------------------------------------------------------------------*
*&      Form  F_STANDARD_HEADER_LNRST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_standard_header_lnrst.

  DATA : ld_text(100).

  CONCATENATE t001-butxt TEXT-022
  INTO ld_text SEPARATED BY space.
  WRITE : /3 ld_text.
  SKIP.
  WRITE : /3 TEXT-040.
*  WRITE : /3 text-027,d_masatx.

ENDFORM.                    " F_STANDARD_HEADER_LNRST

*&---------------------------------------------------------------------*
*&      Form  F_ENTRY_P_FAKTUR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_entry_p_faktur.

  IF p_faktur NE space AND p_lfpgb EQ 'X'.
    CLEAR zgdtxdt0003.
    SELECT * UP TO 1 ROWS FROM zgdtxdt0003 WHERE fakturno EQ p_faktur.
    ENDSELECT.
    IF sy-subrc EQ 0.
      p_bukrs = zgdtxdt0003-bukrs.
      CLEAR s_brnch. REFRESH s_brnch.
      s_brnch-sign = 'I'.
      s_brnch-option = 'EQ'.
      s_brnch-low = zgdtxdt0003-brnch.
      APPEND s_brnch.
    ELSE.
      CLEAR p_bukrs.
      CLEAR s_brnch. REFRESH s_brnch.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_ENTRY_P_FAKTUR

*&---------------------------------------------------------------------*
*&      Form  F_GET_LFPSD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_lfpsd.

  DATA : ld_fkart LIKE zgdtxdt0009-ptype.

* -- MD1
* -- Retur
  IF p_lnrst EQ 'X'.
    ld_fkart = 'R'.
    SELECT * FROM zgdtxdt0009.
      IF zgdtxdt0009-ptype = 'R' OR
         zgdtxdt0009-ptype = 'P'.
        r_fkart-low = zgdtxdt0009-fkart.
        APPEND r_fkart.
      ENDIF.
    ENDSELECT.
* -- Standard and Sederhana
  ELSE.
    ld_fkart = 'N'.
    SELECT * FROM zgdtxdt0009.
      IF zgdtxdt0009-ptype = 'N'.
        r_fkart-low = zgdtxdt0009-fkart.
        APPEND r_fkart.
      ENDIF.
    ENDSELECT.
  ENDIF.
* -- MD1

  CLEAR : zgdtxdt0002.
*  SELECT b~bukrs b~brnch b~masatx b~name
*         b~vbeln b~posnr b~fkdat b~karoseri b~itamtlast b~item
*         b~itqtylast b~fkart b~waers
*         b~exclude b~itdisc b~xppnbm b~dpp b~ppnbm b~noretur b~dtretur
*         b~itoth
** -- MD2
*         b~itdisclast b~xppnbmlast b~dpplast b~ppnlast b~ppnbmlast
*         b~itothlast b~rangka b~mesin
*         b~pstyv b~pph22 b~pph23
** -- MD2
*         FROM ( zGDTXdt0002 AS b INNER JOIN
*                zGDTXdt0009 AS c
*                ON b~fkart    EQ c~fkart    AND
*                   c~ptype    EQ ld_fkart )      "Normal and Retur
*         INTO CORRESPONDING FIELDS OF TABLE t_pajak
*         WHERE b~bukrs    EQ p_bukrs AND
*               b~brnch    IN s_brnch AND
*               b~masatx   EQ p_masatx AND
*               b~fakturno EQ space AND  "Must Blank
*               b~busln IN s_busln.
  SELECT bukrs brnch masatx name
         vbeln posnr fkdat karoseri itamtlast item
         itqtylast fkart waers
         exclude itdisc xppnbm dpp ppnbm noretur dtretur
         itoth
* -- MD2
         itdisclast xppnbmlast dpplast ppnlast ppnbmlast
         itothlast rangka mesin belnr
         pstyv pph22 pph23
         form                        "added for MKM
* -- MD2
         FROM zgdtxdt0002
         INTO CORRESPONDING FIELDS OF TABLE t_pajak
         WHERE bukrs    EQ p_bukrs AND
               brnch    IN s_brnch AND
               masatx   EQ p_masatx AND
               fakturno EQ space AND  "Must Blank
               busln IN s_busln AND
               fkart IN r_fkart AND
               form  IN s_form.       "added for MKM

  SORT t_pajak.
  CHECK NOT t_pajak[] IS INITIAL.

ENDFORM.                    " F_GET_LFPSD

*&---------------------------------------------------------------------*
*&      Form  F_GET_LFPGG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_lfpgg.

* -- Use Inner Join to Collect Data from T320 and LTAK
  CLEAR : zgdtxdt0002,zgdtxdt0003.
  SELECT a~bukrs a~brnch a~fakturno a~fakdat a~name a~addrs1 a~npwp
         a~masatx
         a~form         "added for MKM
         b~vbeln b~posnr b~fkdat b~karoseri b~itamtlast b~item
         b~itqtylast b~fkart b~waers
         b~exclude b~itdisclast b~xppnbmlast b~dpplast b~ppnlast
         b~ppnbmlast b~itoth b~rangka b~mesin
         b~itothlast     "MD2
         b~pstyv b~pph22 b~pph23
         FROM   zgdtxdt0003 AS a INNER JOIN
                zgdtxdt0002 AS b
                ON a~fakturno EQ b~fakturno AND
                   a~bukrs    EQ b~bukrs    AND
                   a~brnch    EQ b~brnch    AND
                   a~masatx   EQ b~masatx
*                                   INNER JOIN
*                zGDTXdt0009 AS c
*                ON b~fkart    EQ c~fkart    AND
*                   c~ptype    EQ 'N'       "Normal Only
    INTO CORRESPONDING FIELDS OF TABLE t_pajak
    WHERE a~bukrs       EQ p_bukrs  AND
          a~brnch       IN s_brnch  AND
          a~fakturno    IN s_faktur AND   "Faktur No - MD3
          a~masatx      EQ p_masatx AND   "Masa Pajak
          a~faktur_type EQ 'G'      AND   "Gabungan Only
          a~returcount  EQ '000'    AND   "Only 1 line
          a~form        IN s_form   AND   "added for MKM
          b~busln IN s_busln        AND
          b~fkart IN r_fkart.

  SORT t_pajak.
  CHECK NOT t_pajak[] IS INITIAL.

ENDFORM.                    " F_GET_LFPGG

*&---------------------------------------------------------------------*
*&      Form  F_GENERATE_ALV_LFPGG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_generate_alv_lfpgg.

* -- ALV Processing
  CLEAR: comm_event, layout, keyinfo.
  REFRESH: fieldcat, tab_events, sort.
  PERFORM f_collect_alv_lfpgg.
  PERFORM f_build_event_lfpgb.
  PERFORM f_build_event_exit_lfpgb.
  PERFORM f_field_catalog_lfpgg.
  PERFORM f_layout_lfpgb.
  PERFORM f_field_sort_lfpgg.
  PERFORM f_list_detail_lfpgb.

ENDFORM.                    " F_GENERATE_ALV_LFPGG

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_ALV_LFPGG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_alv_lfpgg.

  DATA : ld_item_text LIKE zgdtxdt0002-item,
         ld_vbeln     LIKE zgdtxdt0002-vbeln,
         ld_brnch     LIKE zgdtxdt0002-brnch.

  DATA : lv_faktur(20),
         lv_length    TYPE i.

  CLEAR : ld_item_text,ld_vbeln,ld_brnch.
  CLEAR : d_fakdat,d_masatx,d_name,d_addrs1,d_npwp.
  SORT t_pajak BY fakturno vbeln posnr fkdat karoseri DESCENDING.
  LOOP AT t_pajak.

* -- Branch Text
    CLEAR zgdtxdt0101.
    SELECT SINGLE * FROM zgdtxdt0101
     WHERE brnch EQ t_pajak-brnch.

    CONCATENATE t_pajak-brnch zgdtxdt0101-bdesc INTO t_alv-brnch_text
    SEPARATED BY space.
    ld_brnch = zgdtxdt0101-brnch.

* -- Document Date Faktur Pajak
    d_fakdat = t_pajak-fakdat.
* -- Settlement Pajak - Masa Pajak
    d_masatx = t_pajak-masatx.
* -- Customer Name
    d_name = t_pajak-name.
* -- Address
    d_addrs1 = t_pajak-addrs1.
* -- NPWP
    d_npwp = t_pajak-npwp.

* -- Lampiran Faktur Pajak Gabungan All
* -- Key Fields
    t_alv-fakturno   = t_pajak-fakturno.
    PERFORM f_coretax_format USING t_pajak-fakturno
                             CHANGING t_alv-fakturno2.

    IF t_alv-fakturno2 IS INITIAL.
      IF t_pajak-masatx(4) GT 2006.
        CALL FUNCTION 'ZF_FAKTUR'
          EXPORTING
            bukrs     = t_pajak-bukrs
            fakdat    = t_pajak-fakdat
            masatx    = t_pajak-fakdat
            fakturin  = t_pajak-fakturno
*Begin remarks Unicode conversion - DEVK966092
*19.03.2020 - SOL_FELIX
*        CHANGING
*End remarks Unicode conversion - DEVK966092
*Begin insert Unicode conversion - DEVK966092
*19.03.2020 - SOL_FELIX
          IMPORTING
*End insert Unicode conversion - DEVK966092
            fakturout = t_alv-fakturno1.
      ELSE.
        CONCATENATE t_pajak-fakturno(3) '.' t_pajak-fakturno+3(3)
                    '-' t_pajak-fakturno+6(2) '.' t_pajak-fakturno+8(8)
          INTO t_alv-fakturno1.
      ENDIF.
      t_alv-fakturno2 = t_alv-fakturno1.
    ENDIF.

    t_alv-masatx     = t_pajak-masatx.
    t_alv-name       = t_pajak-name.
    t_alv-npwp       = t_pajak-npwp.
    t_alv-vbeln      = t_pajak-vbeln.
    t_alv-fkdat      = t_pajak-fkdat.
    t_alv-exclude    = t_pajak-exclude.

****added by Rahmadi
    t_alv-typex = t_pajak-item.
    t_alv-rangka = t_pajak-rangka.
    t_alv-mesin = t_pajak-mesin.
    t_alv-form  = t_pajak-form.   "for MKM 03/03/2004
****end of addition

* -- Sum Fields
* -- Type, Quantity, Harga Unit
    IF t_pajak-karoseri EQ 'U' OR t_pajak-karoseri EQ space.
      t_alv-qtyxx      = t_pajak-itqtylast.
      t_alv-hrunt      = t_pajak-itamtlast.
* -- Karoseri
    ELSEIF t_pajak-karoseri EQ 'K'.
      t_alv-karsr      = t_pajak-itamtlast.
* -- Optional
    ELSEIF t_pajak-karoseri EQ 'A'.
      t_alv-optnl      = t_pajak-itamtlast.
    ENDIF.

    t_alv-itdisclast = t_pajak-itdisclast.
    t_alv-eksbbm     = t_pajak-xppnbmlast.
    t_alv-dpplast    = t_pajak-dpplast.
    t_alv-ppnlast    = t_pajak-ppnlast.
    t_alv-ppnbmlast  = t_pajak-ppnbmlast.
    t_alv-pstyv      = t_pajak-pstyv.

***added by Rahmadi
    t_alv-pph22 = t_pajak-pph22.
    t_alv-pph23 = t_pajak-pph23.
    t_alv-waers = t_pajak-waers.
***end of addition

* -- Global
*   t_alv-itoth      = t_pajak-itoth.  "MD2
    t_alv-itoth      = t_pajak-itothlast.  "MD2
* -- Harga Unit + Karoseri + Optional - Discount + Others + PPNBM + PPN
    IF t_pajak-exclude EQ 'X'.
      t_alv-totfj      = t_alv-hrunt + t_alv-karsr + t_alv-optnl -
                         t_alv-itdisclast +
                         t_alv-itoth +
*                        t_alv-eksbbm +
                         t_alv-ppnbmlast + t_alv-ppnlast.
* -- Harga Unit + Karoseri + Optional - Discount + Others + PPNBM
    ELSE.
      t_alv-totfj      = t_alv-hrunt + t_alv-karsr + t_alv-optnl -
                         t_alv-itdisclast +
                         t_alv-itoth +
*                        t_alv-eksbbm +
                         t_alv-ppnbmlast.
    ENDIF.

    COLLECT t_alv.
    CLEAR : t_pajak,t_alv.

  ENDLOOP.

****Removed by Rahmadi
** -- Get Text ITEM Field
*  DATA : BEGIN OF lt_item OCCURS 10.
*          INCLUDE STRUCTURE zGDTXdt0002.
*  DATA : END OF lt_item.
*
*  LOOP AT t_alv.
*
** -- Find First ITEM Text if KAROSERI 'U'
*    CLEAR lt_item. REFRESH lt_item.
*    CLEAR zGDTXdt0002.
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_item
*    FROM zGDTXdt0002 WHERE bukrs EQ p_bukrs     AND
*                             brnch EQ ld_brnch    AND
*                             vbeln EQ t_alv-vbeln AND
*                             fakturno EQ p_faktur AND
*                             fkdat EQ t_alv-fkdat AND
*                             karoseri EQ 'U'.
*    IF sy-subrc EQ 0.
*      LOOP AT lt_item.
*        t_alv-typex = lt_item-item.
*        EXIT.
*      ENDLOOP.
*    ELSE.
** -- Second ITEM Text if KAROSERI first blank
*      CLEAR lt_item. REFRESH lt_item.
*      CLEAR zGDTXdt0002.
*      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_item
*      FROM zGDTXdt0002 WHERE bukrs EQ p_bukrs     AND
*                               brnch EQ ld_brnch    AND
*                               vbeln EQ t_alv-vbeln AND
*                               fakturno EQ p_faktur AND
*                               fkdat EQ t_alv-fkdat AND
*                               karoseri EQ space.
*      IF sy-subrc EQ 0.
*        SORT lt_item BY posnr.
*        LOOP AT lt_item.
*          t_alv-typex = lt_item-item.
*          EXIT.
*        ENDLOOP.
*      ENDIF.
*    ENDIF.
*
*    MODIFY t_alv.
*    CLEAR t_alv.
*
*  ENDLOOP.
** --
****end of removal

  CLEAR d_count.
  LOOP AT t_alv.
    ADD 1 TO d_count.
    t_alv-count = d_count.
    MODIFY t_alv TRANSPORTING count.
  ENDLOOP.

ENDFORM.                    " F_COLLECT_ALV_LFPGG

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_LFPGG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_field_catalog_lfpgg.

  PERFORM f_fieldcatg_qty USING 'T_ALV' :
    'COUNT' 'AGDB' 'CLUSTR' '' '7' TEXT-005 '' '' space 'R'.

  IF t_alv-masatx(4) GT 2006.
    PERFORM f_fieldcatg USING 'T_ALV' :
      'FAKTURNO2'     '' ''  ''  '22'   TEXT-031 '' '' space 'L'.
  ELSE.
    PERFORM f_fieldcatg USING 'T_ALV' :
      'FAKTURNO'     '' ''  ''  '22'   TEXT-031 '' '' space 'C'.
  ENDIF.

  PERFORM f_fieldcatg USING 'T_ALV' :
    'MASATX'       '' ''  ''  '10'   TEXT-003 '' '' space 'C',
***added by Rahmadi for MKM 03/03/2004
    'FORM' 'ZGDTXDT0003' 'FORM' '' '4' 'Form' '' '' space 'C',
***end of addition
    'NAME'         '' ''  ''  '40'   TEXT-032 '' '' space 'L',
    'NPWP'         '' ''  ''  '22'   TEXT-033 '' '' space 'L',
    'VBELN'        '' ''  ''  '12'   TEXT-006 '' '' space 'C',
    'FKDAT'        '' ''  ''  '12'   TEXT-007 '' '' space 'C',
    'TYPEX'        '' ''  ''  '35'   TEXT-008 '' '' space 'L'.

  PERFORM f_fieldcatg_qty USING 'T_ALV' :
*   'QTYXX' 'AGDB' 'CLUSTR' '' '7' text-009 'X' '' space 'R'.
    'QTYXX' 'ZGDTXdt0002' 'ITQTYLAST' '' '15'
            TEXT-009 'X' '' space 'R'.

  PERFORM f_fieldcatg USING 'T_ALV' :
    'EXCLUDE'     '' ''  ''     '6' TEXT-042 ''  '' space 'C'.

  PERFORM f_fieldcatg USING 'T_ALV' :
    'PSTYV'     '' ''  ''     '6' 'Category' ''  '' space 'C'.

***added by Rahmadi
  PERFORM f_fieldcatg USING 'T_ALV' :
  'RANGKA' 'ZGDTXDT0002' 'RANGKA' '' '18' 'No.Rangka' '' '' space 'C'.
  PERFORM f_fieldcatg USING 'T_ALV' :
  'MESIN'  'ZGDTXDT0002' 'MESIN' ''  '20' 'No.Mesin' ''  '' space 'C'.
***end of addition

  PERFORM f_fieldcatg USING 'T_ALV' :
    'WAERS'  'ZGDTXDT0002' 'WAERS'  '' '6' 'Curcy' ''  '' space 'C'.

  PERFORM f_fieldcatg_curr USING 'T_ALV' :
    'HRUNT' 'FEBKO' 'SUMSO' ''       '15' TEXT-010
    'X' '' space space 'WAERS' 'R',
    'KARSR' 'FEBKO' 'SUMSO' ''       '15' TEXT-011
    'X' '' space space 'WAERS' 'R',
    'OPTNL' 'FEBKO' 'SUMSO' ''       '15' TEXT-012
    'X' '' space space 'WAERS' 'R',
    'ITDISCLAST' 'FEBKO' 'SUMSO' ''  '15' TEXT-013
    'X' '' space space 'WAERS' 'R',
    'EKSBBM' 'FEBKO' 'SUMSO' ''      '15' TEXT-014
    'X' '' space space 'WAERS' 'R',
    'DPPLAST' 'FEBKO' 'SUMSO' ''     '15' TEXT-015
    'X' '' space space 'WAERS' 'R',
    'PPNLAST' 'FEBKO' 'SUMSO' ''     '15' TEXT-016
    'X' '' space space 'WAERS' 'R',
    'PPNBMLAST' 'FEBKO' 'SUMSO' ''   '15' TEXT-017
    'X' '' space space 'WAERS' 'R',
    'ITOTH' 'FEBKO' 'SUMSO' ''       '15' TEXT-018
    'X' '' space space 'WAERS' 'R',
    'TOTFJ' 'FEBKO' 'SUMSO' ''       '15' TEXT-019
    'X' '' space space 'WAERS' 'R',
    'PPH22' 'FEBKO' 'SUMSO' ''       '15' 'PPh 22'
    'X' '' space space 'WAERS' 'R',
    'PPH23' 'FEBKO' 'SUMSO' ''       '15' 'PPh 23'
    'X' '' space space 'WAERS' 'R'.

ENDFORM.                    " F_FIELD_CATALOG_LFPGG

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_LFPGG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_header_lfpgg.

* -- Header Constant Box
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING TEXT-041.

  CLEAR t001.
  SELECT SINGLE * FROM t001 WHERE spras EQ 'EN' AND
                                   bukrs EQ p_bukrs.
  PERFORM f_hdr_line2 USING ''. "t001-butxt.

* -- Branch Text
  CLEAR zgdtxdt0101.
  SELECT SINGLE * FROM zgdtxdt0101
   WHERE brnch EQ s_brnch-low.

  PERFORM f_hdr_line3 USING ''. "zGDTXdt0101-bdesc.

  PERFORM f_hdr_uline.
  SKIP.
* -- Header Constant Box

  PERFORM f_standard_header_lfpgg.

ENDFORM.                    " F_HEADER_LFPGG

*&---------------------------------------------------------------------*
*&      Form  F_STANDARD_HEADER_LFPGG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_standard_header_lfpgg.

  DATA : ld_text(100).

  CONCATENATE t001-butxt TEXT-022
  INTO ld_text SEPARATED BY space.
  WRITE : /3 ld_text.
*  WRITE : /3 text-023,s_brnch-low.
*  WRITE : /3 text-024,zGDTXdt0101-bdesc.
  SKIP.
  WRITE : /3 TEXT-041.

ENDFORM.                    " F_STANDARD_HEADER_LFPGG

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_SORT_LFPGG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_field_sort_lfpgg.

  CLEAR sort.
  sort-tabname = 'T_ALV'.
  sort-up      = 'X'.
  sort-spos = 1.
  sort-fieldname = 'FAKTURNO'.
  sort-up        = 'X'.
  APPEND sort.

ENDFORM.                    " F_FIELD_SORT_LFPGG

*&---------------------------------------------------------------------*
*&      Form  F_ENTRY_P_MASATX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_entry_p_masatx.
  DATA : lt_004 TYPE STANDARD TABLE OF zgdtxdt0004,
         ls_004 LIKE LINE OF lt_004.

  IF p_masatx EQ '000000'.
    CLEAR zgdtxdt0004.
*    SELECT * FROM zgdtxdt0004 WHERE bukrs EQ p_bukrs AND
*                                      brnch IN s_brnch AND
*                                      closedat EQ '00000000'.
*    ENDSELECT.
    SELECT *
      FROM zgdtxdt0004
      INTO TABLE lt_004
      WHERE bukrs EQ p_bukrs AND
            brnch IN s_brnch AND
            closedat EQ '00000000'.
    IF sy-subrc EQ 0.
      SORT lt_004 BY masatx DESCENDING.
      READ TABLE lt_004 INTO ls_004 INDEX 1.
      IF sy-subrc = 0.
        p_masatx = ls_004-masatx.
      ENDIF.
*      p_masatx = zgdtxdt0004-masatx.
    ENDIF.
  ELSE.
    CLEAR zgdtxdt0004.
*    SELECT * FROM zgdtxdt0004 WHERE bukrs EQ p_bukrs AND
*                                      brnch IN s_brnch AND
*                                      closedat EQ '00000000'.
*    ENDSELECT.
    SELECT *
      FROM zgdtxdt0004
      INTO TABLE lt_004
      WHERE bukrs EQ p_bukrs AND
            brnch IN s_brnch AND
            closedat EQ '00000000'.
    IF sy-subrc EQ 0.
      SORT lt_004 BY masatx DESCENDING.
      READ TABLE lt_004 INTO ls_004 INDEX 1.
      IF sy-subrc = 0.
*      IF p_masatx > zgdtxdt0004-masatx.
        IF p_masatx > ls_004-masatx.
          MESSAGE e000 WITH
          'Masa Pajak must less or equal than open period...'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_ENTRY_P_MASATX

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_NPWP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_npwp.

  LOOP AT t_pajak.
* -- All Condition
    IF  p_allfp EQ 'X'.
* -- Pusat NPWP
    ELSEIF p_pstfp EQ 'X' AND NOT t_pajak-fakturno+6(3) IN s_fptwo.
      DELETE t_pajak.
      CLEAR t_pajak.
      CONTINUE.
* -- Cabang NPWP
    ELSEIF p_cbnfp EQ 'X' AND t_pajak-fakturno+6(3) IN s_fptwo.
      DELETE t_pajak.
      CLEAR t_pajak.
      CONTINUE.
    ENDIF.
    CLEAR t_pajak.
  ENDLOOP.

ENDFORM.                    " F_VALIDATE_NPWP

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_alv_variant.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = d_variant
      i_save     = d_save
    IMPORTING
      e_exit     = d_exit
      es_variant = d_gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF d_exit = space.
      p_varnt = d_gx_variant-variant.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_ALV_VARIANT

*&---------------------------------------------------------------------*
*&      Form  F_PAI_ALV_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pai_alv_variant.

  IF NOT p_varnt IS INITIAL.
    MOVE d_variant TO d_gx_variant.
    MOVE p_varnt TO d_gx_variant-variant.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save     = d_save
      CHANGING
        cs_variant = d_gx_variant.
    d_variant = d_gx_variant.
  ELSE.
    CLEAR d_variant.
    d_variant-report = d_repid.
  ENDIF.

ENDFORM.                    " F_PAI_ALV_VARIANT

*&---------------------------------------------------------------------*
*&      Form  F_GET_SORT_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_sort_field.

  DATA : lt_sort TYPE slis_sortinfo_alv.

  CLEAR : d_fpnum.
  LOOP AT t_sort INTO lt_sort WHERE group EQ '*'.

    IF lt_sort-fieldname EQ 'FAKTURNO'.
      CONCATENATE lt_sort-tabname '-' lt_sort-fieldname INTO d_fpnum.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " F_GET_SORT_FIELD

*&---------------------------------------------------------------------*
*&      Form  f_format_to_espt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_format_to_espt.

  DATA lw_espt LIKE zgdtxst0014.

  LOOP AT t_alv.
    READ TABLE t_pajak WITH KEY brnch = t_alv-brnch
                                fakturno = t_alv-fakturno
                                vbeln = t_alv-vbeln
                                BINARY SEARCH.
    t_alv-masatx = t_pajak-masatx.
    t_alv-fakdat = t_pajak-fakdat.
    IF p_masatx(4) GT 2006.
      CALL FUNCTION 'Z_GDTXFC_FORMAT_TO_ESPT1'
        EXPORTING
          fi_vat_type                   = 'O'
          fi_zgdtxst0013                = t_alv
        IMPORTING
          fe_espt                       = lw_espt
        EXCEPTIONS
          kodelamp_must_be_filled       = 1
          kodestat_must_be_filled       = 2
          kodedok_must_be_filled        = 3
          npwp_is_blank                 = 4
          npwp_name_is_blank            = 5
          vat_out_struct_must_be_filled = 6
          vat_in_struct_must_be_filled  = 7
          OTHERS                        = 8.
    ELSE.
      CALL FUNCTION 'Z_GDTXFC_FORMAT_TO_ESPT'
        EXPORTING
          fi_vat_type                   = 'O'
          fi_zgdtxst0013                = t_alv
        IMPORTING
          fe_espt                       = lw_espt
        EXCEPTIONS
          kodelamp_must_be_filled       = 1
          kodestat_must_be_filled       = 2
          kodedok_must_be_filled        = 3
          npwp_is_blank                 = 4
          npwp_name_is_blank            = 5
          vat_out_struct_must_be_filled = 6
          vat_in_struct_must_be_filled  = 7
          OTHERS                        = 8.
    ENDIF.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      CLEAR lw_espt.
      CONTINUE.
    ELSE.
      MOVE-CORRESPONDING lw_espt TO t_alv.
      MODIFY t_alv.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " f_format_to_espt

*&---------------------------------------------------------------------*
*&      Form  f_list_espt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_list_espt USING fu_fieldcat TYPE slis_t_fieldcat_alv.

  PERFORM f_fieldcat_espt USING  fu_fieldcat :
  'KODELAMP' 'ZGDTXST0014' 'KODELAMP' 14 'X' 'Kode Lampiran' 'Kd Lmp'
              'Kdl.' 'Kode Lamp.'  ''  ''  'L' '' '' '' '' '' '',
   'KODESTAT' 'ZGDTXST0014' 'KODESTAT' 11 'X' 'Kode Status' 'Kd Sts'
              'Kds.' 'Kode Stat.'  ''  ''  'L' '' '' '' '' '' '',
   'KODEDOK'  'ZGDTXST0014' 'KODEDOK' 14 'X' 'Kode Dokumen' 'Kd Dok'
              'Kdd.' 'Kode Doku.'  ''  ''  'L' '' '' '' '' '' '',
   'KODENPWP' 'ZGDTXST0014' 'KODENPWP' 14 'X' 'NPWP' 'NPWP'  'NPWP'
              'NPWP'  ''  ''  'L' '' '' '' '' '' '',
   'KODENAMA' 'ZGDTXST0014' 'KODENAMA' 50 'X' 'Nama' 'Nama'  'Nama'
              'Nama'  ''  ''  'L' '' '' '' '' '' '',
   'KODEPRFP' 'ZGDTXST0014' 'KODEPRFP' 11 'X' 'Kode Faktur' 'Kd FP'
              'Kd FP' 'Kode FP'  ''  ''  'L' '' '' '' '' '' '',
   'KODENORET' 'ZGDTXST0014' 'KODENORET' 14 'X' 'No Ref Faktur'
              'No Ref' 'No Ref' 'No Ref'  ''  ''  'L' '' '' '' '' '' '',
   'KODENOFP' 'ZGDTXST0014' 'KODENOFP' 14 'X' 'No Seri Faktur'
            'No Seri' 'No Seri' 'No Seri'  ''  ''  'L' '' '' '' '' '' '',
   'KODETGL'  'ZGDTXST0014' 'KODETGL' 11 'X' 'Tgl Faktur' 'Tgl FP'
              'Tgl FP' 'Tgl FP'  ''  ''  'L' '' '' '' '' '' '',
   'KODEMSTX' 'ZGDTXST0014' 'KODEMSTX' 10 'X' 'Ms Pjk Bln' 'Ms Pj Bl'
              'Ms Pj Bl' 'Ms Pj Bl'  ''  ''  'L' '' '' '' '' '' '',
   'KODETHN'  'ZGDTXST0014' 'KODETHN' 10 'X' 'Ms Pjk Thn' 'Ms Pj Th'
              'Ms Pj Th' 'Ms Pj Th'  ''  ''  'L' '' '' '' '' '' '',
   'KOREKSI'  'ZGDTXST0014' 'KOREKSI' 10 'X' 'Pembetulan' 'Pbtln'
              'Pbtln' 'Pbtln'  ''  ''  'L' '' '' '' '' '' '',
   'PPNTARIF' 'ZGDTXST0014' 'PPNTARIF' 15 'X' 'Tarif PPN' 'Tr PPN'
              'Tr PPN' 'Tr PPN'  ''  ''  'L' '' '' '' '' '' '',
   'NILBILL'  'ZGDTXST0014' 'NILBILL' 15 'X' 'Nilai Perolehan'
           'Nil Prl' 'Nil Prl' 'Nil Prl'  ''  ''  'L' '' '' '' '' '' '',
   'NILPPNBM' 'ZGDTXST0014' 'NILPPNBM' 15 'X' 'Tarif PPnBM'
        'Tr PPnBM' 'Tr PPnBM' 'Tr PPnBM'  ''  ''  'L' '' '' '' '' '' ''.

ENDFORM.                    " f_list_espt

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCAT_ESPT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fieldcat_espt USING fu_fieldcat TYPE slis_t_fieldcat_alv
                           fu_fieldname
                           fu_ref_field
                           fu_ref_table
                           fu_outputlen
                           fu_no_sign
                           fu_seltext_l
                           fu_seltext_m
                           fu_seltext_s
                           fu_reptext_ddic
                           fu_datatype
                           fu_do_sum
                           fu_just
                           fu_key
                           fu_hotspot
                           fu_currency
                           fu_cfieldname
                           fu_input
                           fu_noout.

  DATA: lt_fieldcat TYPE slis_fieldcat_alv.

  CLEAR lt_fieldcat.
  lt_fieldcat-fieldname      = fu_fieldname.
  lt_fieldcat-ref_fieldname  = fu_ref_field.
  lt_fieldcat-ref_tabname    = fu_ref_table.
  lt_fieldcat-outputlen      = fu_outputlen.
  lt_fieldcat-no_sign        = fu_no_sign.
  lt_fieldcat-seltext_l      = fu_seltext_l.
  lt_fieldcat-seltext_m      = fu_seltext_m.
  lt_fieldcat-seltext_s      = fu_seltext_s.
  lt_fieldcat-reptext_ddic   = fu_reptext_ddic.
  lt_fieldcat-datatype       = fu_datatype.
  lt_fieldcat-do_sum         = fu_do_sum.
  lt_fieldcat-just           = fu_just.
  lt_fieldcat-key            = fu_key.
  lt_fieldcat-hotspot        = fu_hotspot.
  lt_fieldcat-currency       = fu_currency.
  lt_fieldcat-cfieldname     = fu_cfieldname.
  lt_fieldcat-input          = fu_input.
  lt_fieldcat-no_out         = fu_noout.

  APPEND lt_fieldcat TO fu_fieldcat.

ENDFORM.                                            " F_FIELDCAT_ESPT

*&---------------------------------------------------------------------*
*&      Form  collect_t_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM collect_t_alv.
  DATA ld_selisih LIKE zgdtxst0004-fakppn.

  LOOP AT t_alv.
    wa_alv1 = t_alv.
    wa_alv1-typex  = space.
    wa_alv1-rangka = space.
    COLLECT wa_alv1 INTO t_alv1.
  ENDLOOP.

  LOOP AT t_alv1.
***** Modifikasi perhitungan DPP 18122012
    IF t_alv1-brnch EQ '8050' OR t_alv1-brnch EQ '8800'.
      ld_selisih = t_alv1-fakppn / t_alv1-hrunt * 100.
      IF ld_selisih NE 10 AND
        ld_selisih NE 11.
        t_alv1-dpp = t_alv1-hrunt * 10 / 100.
        MODIFY t_alv1 TRANSPORTING dpp.
      ENDIF.
    ENDIF.
  ENDLOOP.

  REFRESH: t_alv.
  CLEAR: t_alv.

  t_alv[] = t_alv1[].
ENDFORM.                    " collect_t_alv

*&---------------------------------------------------------------------*
*&      Form  f_download
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download.
  DATA: fname(128),
        canc(1),
        size       TYPE i,
        ld_count   TYPE i.

  LOOP AT t_alv.
    IF ld_count EQ 0.
      ld_count = 1.
      t_download-data = space.
      APPEND t_download.
    ENDIF.

    CONCATENATE t_alv-kodepajak t_alv-kodelamp INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-kodestat INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-kodedok INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-kodenpwp INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-kodenama INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-kodecabang INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-masatx+2(2) INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-kodeseri INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-kodetgl INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-tglssp INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-kodemstx INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-kodethn INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-koreksi INTO t_download-data
    SEPARATED BY ';'.
    SHIFT t_alv-nilbill LEFT DELETING LEADING space.
    CONCATENATE t_download-data t_alv-nilbill INTO t_download-data
    SEPARATED BY ';'.
    SHIFT t_alv-nilppn LEFT DELETING LEADING space.
    CONCATENATE t_download-data t_alv-nilppn INTO t_download-data
    SEPARATED BY ';'.
    SHIFT t_alv-nilppnbm LEFT DELETING LEADING space.
    CONCATENATE t_download-data t_alv-nilppnbm INTO t_download-data
    SEPARATED BY ';'.


*    t_download-kodepajak  = t_alv-kodepajak.
*    t_download-kodelamp   = t_alv-kodelamp.
*    t_download-kodestat   = t_alv-kodestat.
*    t_download-kodedok    = t_alv-kodedok.
*    t_download-kodenpwp   = t_alv-kodenpwp.
*    t_download-kodenama   = t_alv-kodenama.
*    t_download-kodecabang = t_alv-kodecabang.
**    t_download-kodedigit  = t_alv-kodethn+2(2).
*    t_download-kodeseri   = t_alv-kodeseri.
*    t_download-kodetgl    = t_alv-kodetgl.
*    t_download-tglssp     = t_alv-tglssp.
*    t_download-kodemstx   = t_alv-kodemstx.
*    t_download-kodethn    = t_alv-kodethn.
*    t_download-koreksi    = t_alv-koreksi.
*    t_download-nilbill    = t_alv-nilbill.
*    t_download-nilppn     = t_alv-nilppn.
*    t_download-nilppnbm   = t_alv-nilppnbm.
    APPEND t_download.
  ENDLOOP.

*  CONCATENATE 'C:\eSPT_A' p_masatx '.TXT'
  CONCATENATE 'C:\ZGDTXNR0004\eSPT_A' p_masatx '.CSV'
    INTO fname.

*Begin remark Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
*  CALL FUNCTION 'DOWNLOAD'
*       EXPORTING
*            filename              = fname
*       IMPORTING
*            cancel                = canc
*            filesize              = size
*       TABLES
*            data_tab              = t_download
*       EXCEPTIONS
*            file_open_error       = 1
*            file_write_error      = 2.
*
*  IF canc = 'x'.
*    MESSAGE i000(zf) WITH 'Download Cancel by User'.
*  ENDIF.
*
*  IF size NE '0'.
*    MESSAGE i000(zf) WITH 'Download Success'.
*  ENDIF.
*End remark Unicode conversion - DEVK965554

*Begin insert Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
  DATA: lv_filename TYPE string.
  CLEAR lv_filename.
  lv_filename = fname.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = lv_filename
      filetype                = 'ASC'
*     FIELDNAMES              = dwn_field
    CHANGING
      data_tab                = t_download[]
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*End insert Unicode conversion - DEVK965554

ENDFORM.                    " f_download

*&---------------------------------------------------------------------*
*&      Form  f_download11
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download11.
  DATA: fname(128),
        canc(1),
        size       TYPE i,
        ld_count   TYPE i.

  LOOP AT t_alv.
    IF ld_count EQ 0.
      ld_count = 1.
      t_download-data = space.
      APPEND t_download.
    ENDIF.

    CONCATENATE t_alv-kodepajak t_alv-kodelamp INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-kodestat INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-kodedok INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-flagvat INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-npwp255 INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-kodenama INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-nodok INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-jenisdok INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-fakturganti INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-jenisganti INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-kodetgl INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-tglssp INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-masapjk INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-kodethn INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_alv-pembetulan INTO t_download-data
    SEPARATED BY ';'.
    SHIFT t_alv-nilbill LEFT DELETING LEADING space.
    CONCATENATE t_download-data t_alv-nilbill INTO t_download-data
    SEPARATED BY ';'.
    SHIFT t_alv-nilppn LEFT DELETING LEADING space.
    CONCATENATE t_download-data t_alv-nilppn INTO t_download-data
    SEPARATED BY ';'.
    SHIFT t_alv-nilppnbm LEFT DELETING LEADING space.
    CONCATENATE t_download-data t_alv-nilppnbm INTO t_download-data
    SEPARATED BY ';'.

    APPEND t_download.
  ENDLOOP.

*  CONCATENATE 'C:\eSPT_A' p_masatx '.TXT'
  CONCATENATE 'C:\ZGDTXNR0004\eSPT_A' p_masatx '.CSV'
    INTO fname.

*Begin remark Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
*  CALL FUNCTION 'DOWNLOAD'
*       EXPORTING
*            filename              = fname
*       IMPORTING
*            cancel                = canc
*            filesize              = size
*       TABLES
*            data_tab              = t_download
*       EXCEPTIONS
*            file_open_error       = 1
*            file_write_error      = 2.
*
*  IF canc = 'x'.
*    MESSAGE i000(zf) WITH 'Download Cancel by User'.
*  ENDIF.
*
*  IF size NE '0'.
*    MESSAGE i000(zf) WITH 'Download Success'.
*  ENDIF.
*End remark Unicode conversion - DEVK965554

*Begin insert Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
  DATA: lv_filename TYPE string.
  CLEAR lv_filename.
  lv_filename = fname.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = lv_filename
      filetype                = 'ASC'
*     FIELDNAMES              = dwn_field
    CHANGING
      data_tab                = t_download[]
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    MESSAGE i000(zf) WITH 'Download Success'.
  ENDIF.
*End insert Unicode conversion - DEVK965554

ENDFORM.                    " f_download11

*&---------------------------------------------------------------------*
*&      Form  f_screen_download
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_screen_download.
  CLEAR: p_down.
  IF p_masatx(4) GT 2006.
    LOOP AT SCREEN.
      IF screen-group1 = 'DOW'.
        screen-input  = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

    IF NOT p_espt IS INITIAL.
      LOOP AT SCREEN.
        IF screen-group1 = 'DOW'.
          screen-input  = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'DOW'.
        screen-active  = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_screen_download

*&---------------------------------------------------------------------*
*&      Form  f_list_espt1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FIELDCAT[]  text
*----------------------------------------------------------------------*
FORM f_list_espt1 USING fu_fieldcat TYPE slis_t_fieldcat_alv.

  PERFORM f_fieldcat_espt USING  fu_fieldcat :
  'KODEPAJAK' 'ZGDTXST0014' 'KODEPAJAK' 11 'X' 'Kode Pajak' 'Kd Pjk'
              'Kdp.' 'Kode Pajak'  ''  ''  'L' '' '' '' '' '' '',
  'KODELAMP' 'ZGDTXST0014' 'KODELAMP' 14 'X' 'Kode Lampiran' 'Kd Lmp'
              'Kdl.' 'Kode Lamp.'  ''  ''  'L' '' '' '' '' '' '',
   'KODESTAT' 'ZGDTXST0014' 'KODESTAT' 11 'X' 'Kode Status' 'Kd Sts'
              'Kds.' 'Kode Stat.'  ''  ''  'L' '' '' '' '' '' '',
   'KODEDOK'  'ZGDTXST0014' 'KODEDOK' 14 'X' 'Kode Dokumen' 'Kd Dok'
              'Kdd.' 'Kode Doku.'  ''  ''  'L' '' '' '' '' '' '',
   'KODENPWP' 'ZGDTXST0014' 'KODENPWP' 14 'X' 'NPWP' 'NPWP'  'NPWP'
              'NPWP'  ''  ''  'L' '' '' '' '' '' '',
   'KODENAMA' 'ZGDTXST0014' 'KODENAMA' 50 'X' 'Nama' 'Nama'  'Nama'
              'Nama'  ''  ''  'L' '' '' '' '' '' '',
   'KODECABANG' 'ZGDTXST0014' 'KODECABANG' 12 'X' 'Kode Cabang' 'Kd Cbg'
              'Kdc.' 'Kode Cabang'  ''  ''  'L' '' '' '' '' '' '',
  'KODEDIGIT' 'ZGDTXST0014' 'KODEDIGIT' 11 'X' 'Digit Tahun' 'Digit Thn'
              'Dthn.' 'Digit Tahun'  ''  ''  'L' '' '' '' '' '' '',
   'KODESERI' 'ZGDTXST0014' 'KODESERI' 14 'X' 'No Seri Faktur'
            'No Seri' 'No Seri' 'No Seri'  ''  ''  'L' '' '' '' '' '' '',
   'KODETGL'  'ZGDTXST0014' 'KODETGL' 11 'X' 'Tgl Faktur' 'Tgl FP'
              'Tgl FP' 'Tgl FP'  ''  ''  'L' '' '' '' '' '' '',
   'TGLSSP'  'ZGDTXST0014' 'TGLSSP' 11 'X' 'Tgl SSP' 'Tgl SSP'
              'Tgl SSP' 'Tgl SSP'  ''  ''  'L' '' '' '' '' '' '',
   'KODEMSTX' 'ZGDTXST0014' 'KODEMSTX' 10 'X' 'Ms Pjk Bln' 'Ms Pj Bl'
              'Ms Pj Bl' 'Ms Pj Bl'  ''  ''  'L' '' '' '' '' '' '',
   'KODETHN'  'ZGDTXST0014' 'KODETHN' 10 'X' 'Ms Pjk Thn' 'Ms Pj Th'
              'Ms Pj Th' 'Ms Pj Th'  ''  ''  'L' '' '' '' '' '' '',
   'KOREKSI'  'ZGDTXST0014' 'KOREKSI' 10 'X' 'Pembetulan' 'Pbtln'
              'Pbtln' 'Pbtln'  ''  ''  'L' '' '' '' '' '' '',
   'NILBILL'  'ZGDTXST0014' 'NILBILL' 15 'X' 'DPP'
           'DPP' 'DPP' 'DPP'  ''  ''  'L' '' '' '' '' '' '',
   'NILPPN'  'ZGDTXST0014' 'NILPPN' 15 'X' 'PPN'
           'PPN' 'PPN' 'PPN'  ''  ''  'L' '' '' '' '' '' '',
   'NILPPNBM' 'ZGDTXST0014' 'NILPPNBM' 15 'X' 'Tarif PPnBM'
        'Tr PPnBM' 'Tr PPnBM' 'Tr PPnBM'  ''  ''  'L' '' '' '' '' '' ''.
ENDFORM.                    " f_list_espt1

*&---------------------------------------------------------------------*
*&      Form  F_KURS_NON_IDR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_kurs_non_idr .
  DATA: BEGIN OF lt_vbrk OCCURS 0.
          INCLUDE STRUCTURE vbrk.
        DATA: END OF lt_vbrk.

  IF t_alv[] IS NOT INITIAL.
    SORT t_alv BY belnr.
    SELECT vbeln cpkur kurrf
      FROM vbrk
      INTO CORRESPONDING FIELDS OF TABLE lt_vbrk
      FOR ALL ENTRIES IN t_alv
      WHERE vbeln EQ t_alv-belnr.
  ENDIF.

  LOOP AT t_alv.
    IF t_alv-waers NE c_local_curr.
      READ TABLE lt_vbrk WITH KEY vbeln = t_alv-belnr.
      IF sy-subrc EQ 0.
        PERFORM f_get_tax_rate USING lt_vbrk-kurrf
                                     lt_vbrk-cpkur
                                     t_alv-waers
                                     t_alv-dtretur
                                     c_local_curr.

        t_alv-fakppn = t_alv-fakppn * d_rate_tax / 100.
        t_alv-hrunt  = t_alv-hrunt * d_rate_tax / 100.
        t_alv-dpp    = t_alv-dpp * d_rate_tax / 100.
        t_alv-ppnbm  = t_alv-ppnbm * d_rate_tax / 100.
        t_alv-totfj  = t_alv-totfj * d_rate_tax / 100.
        t_alv-itdisc = t_alv-itdisc * d_rate_tax / 100.
        t_alv-eksbbm = t_alv-eksbbm * d_rate_tax / 100.
        t_alv-waers  = c_local_curr.
        MODIFY t_alv TRANSPORTING fakppn hrunt dpp ppnbm totfj itdisc eksbbm waers.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_KURS_NON_IDR

*&---------------------------------------------------------------------*
*&      Form  F_GET_TAX_RATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_ALV_WAERS  text
*      -->P_T_ALV_FKDAT  text
*      -->P_C_LOCAL_CURR  text
*----------------------------------------------------------------------*
FORM f_get_tax_rate USING fd_kurrf fd_cpkur
                          fd_fcurr  LIKE t_alv-waers
                          fd_fakdat LIKE t_alv-fakdat
                          fd_lcurr  LIKE t_alv-waers.

  DATA lw_return LIKE bapireturn1.
  DATA lw_rate LIKE bapi1093_0.

  CLEAR: d_rate_tax,
         d_ratefactor,
         d_tax_valid.

  CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
    EXPORTING
      rate_type  = 'ZTAX'
      from_curr  = fd_fcurr
      to_currncy = fd_lcurr
      date       = fd_fakdat
    IMPORTING
      exch_rate  = lw_rate
      return     = lw_return.
  IF NOT lw_return IS INITIAL.
    MESSAGE e000(zab) WITH lw_return-message.
  ELSE.
    IF fd_cpkur IS INITIAL.
      d_rate_tax = lw_rate-exch_rate * lw_rate-to_factor
                   / lw_rate-from_factor.
    ELSE.
      d_rate_tax = fd_kurrf * lw_rate-to_factor
                   / lw_rate-from_factor.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_TAX_RATE

*&---------------------------------------------------------------------*
*&      Form  F_TAX_CALC
*&---------------------------------------------------------------------*
FORM f_tax_calc  USING    fu_datum fu_mastx fu_wrbtr fu_calty
                 CHANGING fc_wrbtr.
  DATA : lv_wrbtr TYPE netwr_ak,
         lv_datum TYPE sy-datum,
         lv_mastx TYPE abper_rf.

  lv_wrbtr  = fu_wrbtr.
  lv_datum  = fu_datum.
  lv_mastx  = fu_mastx.

  CALL FUNCTION 'Z_PPN11'
    EXPORTING
      pi_wrbtr = lv_wrbtr
      pi_calty = fu_calty
      pi_datum = lv_datum
      pi_mastx = lv_mastx
    IMPORTING
      po_wrbtr = lv_wrbtr.

  fc_wrbtr = lv_wrbtr.
ENDFORM.                    " F_TAX_CALC

*&---------------------------------------------------------------------*
*&      Form  F_CORETAX_FORMAT
*&---------------------------------------------------------------------*
FORM f_coretax_format  USING    fu_fakturno
                       CHANGING fc_fakturno.
  DATA : lv_length    TYPE i.

  CLEAR fc_fakturno.
  lv_length = strlen( fu_fakturno ).
  IF lv_length = 17.
    WRITE fu_fakturno TO fc_fakturno USING EDIT MASK '__.__.__-___.________'.
  ENDIF.
ENDFORM.
