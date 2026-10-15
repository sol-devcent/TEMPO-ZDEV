*----------------------------------------------------------------------*
*   INCLUDE ZF_FKF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  DATA : ls_vkbur   LIKE LINE OF gr_vkburi.

  SELECT SINGLE *
    FROM zproject
    INTO CORRESPONDING FIELDS OF gs_dpp
    WHERE name = 'DPP12'.

  SELECT *
    FROM zplbc
    INTO CORRESPONDING FIELDS OF TABLE gt_zplbc
    WHERE bukrs = pa_bukrs
      AND werks = pa_vkbur.

  SELECT *
    FROM zfvat_decimal
    INTO CORRESPONDING FIELDS OF TABLE gt_vatdec
    WHERE vkorg = pa_bukrs.

  ls_vkbur-low    = 'T2*'.
  ls_vkbur-sign   = 'I'.
  ls_vkbur-option = 'CP'.
  APPEND ls_vkbur TO gr_vkburi.
  CLEAR ls_vkbur.

  ls_vkbur-low    = 'T2*'.
  ls_vkbur-sign   = 'E'.
  ls_vkbur-option = 'CP'.
  APPEND ls_vkbur TO gr_vkbure.
  CLEAR ls_vkbur.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  TYPES : BEGIN OF ty_file,
            zfile TYPE zfile,
          END OF ty_file.

  DATA : lt_mseg  LIKE gt_mseg OCCURS 0 WITH HEADER LINE.
  DATA : lt_kna1  LIKE zfvato OCCURS 0 WITH HEADER LINE.
  DATA : lt_makt  LIKE gt_zsl_dsales OCCURS 0 WITH HEADER LINE.
  DATA : lt_knvv  LIKE gt_zsl_dsales OCCURS 0 WITH HEADER LINE.
  DATA : lt_makt1 LIKE gt_mseg OCCURS 0 WITH HEADER LINE.
  DATA : lv_zfile  TYPE zfile.

  DATA : lt_file TYPE STANDARD TABLE OF ty_file,
         ls_file LIKE LINE OF lt_file.

  DATA : BEGIN OF lt_zfvato OCCURS 0.
           INCLUDE STRUCTURE zfvato.
           DATA :   vbel1 TYPE vbeln,
         END OF lt_zfvato.
  DATA: BEGIN OF lt_kunnr OCCURS 0,
          kunnr          LIKE kna1-kunnr,
          nama_text(135),
        END OF lt_kunnr.
  DATA lv_header       LIKE thead.
  DATA lt_lines        LIKE tline OCCURS 0 WITH HEADER LINE.

  DATA : lr_fkdat TYPE RANGE OF fkdat,
         lv_fkdat LIKE LINE OF lr_fkdat.

  CONCATENATE so_fkdat-low(6) '01' INTO lv_fkdat-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_fkdat-low
    IMPORTING
      last_day_of_month = lv_fkdat-high
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  lv_fkdat-sign   = 'I'.
  lv_fkdat-option = 'BT'.
  APPEND lv_fkdat TO lr_fkdat.

  lv_zfile  = pa_flnm1.

  IF gv_tds IS NOT INITIAL.
    LOOP AT so_flnm1.
      ls_file-zfile = so_flnm1-low.
      APPEND ls_file TO lt_file.
    ENDLOOP.
  ENDIF.

* FK
  CASE 'X'.
    WHEN ra_fk.
      PERFORM f_cek_lock.
* Get Download Numbering
      SELECT *
        FROM zfnoefaktur
        INTO CORRESPONDING FIELDS OF TABLE gt_zfnoefaktur
        WHERE bukrs EQ pa_bukrs
          AND zfakty EQ gc_zfakty.

      IF gt_zfnoefaktur[] IS INITIAL.
        PERFORM f_release_lock.
        MESSAGE i000(zab) WITH 'Please maintenance download numbering'.
        STOP.
      ENDIF.

      SELECT *
      FROM zfvato
      INTO CORRESPONDING FIELDS OF TABLE gt_zfvato
      WHERE vkorg EQ pa_bukrs
        AND vkbur EQ pa_vkbur
        AND fkdat IN so_fkdat
        AND vbeln IN so_vbeln
        AND zuonr IN so_zuonr
        AND files EQ space.

    WHEN ra_rfk.
* Get Download Numbering
      SELECT *
        FROM zfnoefaktur
        INTO CORRESPONDING FIELDS OF TABLE gt_zfnoefaktur
        WHERE bukrs EQ pa_bukrs
          AND zfakty EQ gc_zfakty.

      IF gv_tds IS INITIAL.
        SELECT *
          FROM zfvato
          INTO CORRESPONDING FIELDS OF TABLE gt_zfvato
          WHERE vkorg EQ pa_bukrs
            AND vbeln IN so_vbeln
            AND zuonr IN so_zuonr
            AND files EQ lv_zfile.
      ELSE.
        IF lt_file[] IS NOT INITIAL.
          SELECT *
            FROM zfvato
            INTO CORRESPONDING FIELDS OF TABLE gt_zfvato
            FOR ALL ENTRIES IN lt_file
            WHERE vkorg EQ pa_bukrs
              AND vbeln IN so_vbeln
              AND zuonr IN so_zuonr
              AND files EQ lt_file-zfile.
        ENDIF.
      ENDIF.

    WHEN ra_del.
      IF pa_vbeln IS NOT INITIAL.
        SELECT *
          FROM zfvato
          INTO CORRESPONDING FIELDS OF TABLE gt_zfvato
          WHERE vkorg EQ pa_bukrs
            AND vbeln EQ pa_vbeln
            AND files EQ lv_zfile.
      ELSEIF pa_zuonr IS NOT INITIAL.
        SELECT *
          FROM zfvato
          INTO CORRESPONDING FIELDS OF TABLE gt_zfvato
          WHERE vkorg EQ pa_bukrs
            AND zuonr EQ pa_zuonr
            AND files EQ lv_zfile.
      ENDIF.

    WHEN ra_rpt.
      SELECT *
        FROM zfvato
        INTO CORRESPONDING FIELDS OF TABLE gt_zfvato
        WHERE vkorg EQ pa_bukrs
          AND vkbur EQ pa_vkbur
          AND fkdat IN so_fkdat
          AND vbeln IN so_vbeln
          AND zuonr IN so_zuonr.
  ENDCASE.
*** Req By Abun 2018 10 03 --- Nama customer yg di ZFVATO-NAMA_CO diganti ambil ke addition text file customer
**  IF ra_rfk = 'X' OR ra_rpt = 'X'.

  IF pa_vkbur IN gr_vkburi.
    LOOP AT gt_zfvato.
      IF pa_bahan IS INITIAL.
        IF gt_zfvato-vatpr(2) EQ '08'.
          DELETE gt_zfvato.
        ENDIF.
      ELSE.
        IF gt_zfvato-vatpr(2) NE '08'.
          DELETE gt_zfvato.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF gt_zfvato[] IS NOT INITIAL.
    LOOP AT gt_zfvato INTO wa_zfvato.
      lt_kunnr-kunnr = wa_zfvato-kunrg.
      APPEND lt_kunnr.
      wa_zfvato-nama_text = wa_zfvato-name_co.
      MODIFY gt_zfvato FROM wa_zfvato TRANSPORTING nama_text.
      CLEAR: wa_zfvato.
    ENDLOOP.
  ENDIF.
  DELETE ADJACENT DUPLICATES FROM lt_kunnr COMPARING ALL FIELDS.

  DATA: ld_tdname LIKE thead-tdname.

  SORT gt_zfvato BY kunrg.
  SORT lt_kunnr BY kunnr.
  LOOP AT lt_kunnr.
    REFRESH: lt_lines.
    CLEAR: lv_header, ld_tdname.
    ld_tdname = lt_kunnr-kunnr.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = '0017'
        language                = sy-langu
        name                    = ld_tdname
        object                  = 'KNA1'
      IMPORTING
        header                  = lv_header
      TABLES
        lines                   = lt_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc EQ 0.
      CLEAR: lt_kunnr-nama_text.
      LOOP AT lt_lines.
        CONCATENATE lt_kunnr-nama_text lt_lines-tdline INTO lt_kunnr-nama_text SEPARATED BY space.
        "lt_kunnr-nama_text = lt_lines-tdline.
      ENDLOOP.
      MODIFY lt_kunnr TRANSPORTING nama_text.
      LOOP AT gt_zfvato INTO wa_zfvato WHERE kunrg = lt_kunnr-kunnr.
        wa_zfvato-nama_text = lt_kunnr-nama_text.
        wa_zfvato-name_co = lt_kunnr-nama_text.
        MODIFY gt_zfvato FROM wa_zfvato TRANSPORTING nama_text name_co.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
**  ENDIF.

* OF
  IF ra_rpt IS INITIAL.
    IF gt_zfvato[] IS NOT INITIAL.
      READ TABLE gt_zplbc INTO wa_zplbc INDEX 1.

      IF pa_bukrs = '8220'.
        wa_zplbc-live = 'X'.
      ENDIF.

      IF wa_zplbc-live IS INITIAL.
        IF pa_bukrs EQ '8020'.
          SELECT zsl_hsales~vbeln posnr matnr fkimg nsp ppn disa disb disc
                 disd disdc dise disf zsl_dsales~disvol zsl_dsales~cod kunnr
                 account_no taxcode
            FROM zsl_hsales JOIN zsl_dsales
                            ON   zsl_hsales~vbeln = zsl_dsales~vbeln
                            AND  zsl_hsales~gjahr = zsl_dsales~gjahr
            INTO CORRESPONDING FIELDS OF TABLE gt_zsl_dsales
            FOR ALL ENTRIES IN gt_zfvato
            WHERE vkbur             = gt_zfvato-vkbur
              AND zsl_hsales~vbtyp  = gt_zfvato-vbtyp
              AND stafjk            = 'X'
              AND vkorg             = gt_zfvato-vkorg
              AND fkdat             = gt_zfvato-erdat
              AND account_no        = gt_zfvato-vbeln
              AND kunnr             = gt_zfvato-kunrg
              AND fkimg             <> 0
              AND nsp               <> 0.
        ELSEIF pa_bukrs EQ '8070'.
          LOOP AT gt_zfvato INTO wa_zfvato.
            lt_zfvato = wa_zfvato.
            lt_zfvato-vbel1  = wa_zfvato-zuonr(10).
            APPEND lt_zfvato.
          ENDLOOP.

          SELECT zssutdt005~vbeln posnr matnr fkimg nsp ppn disa disb disc
                 disd disdc dise disf zssutdt006~disvol zssutdt006~cod kunnr
                 account_no taxcode
            FROM zssutdt005 JOIN zssutdt006
                            ON   zssutdt005~vbeln = zssutdt006~vbeln
                            AND  zssutdt005~gjahr = zssutdt006~gjahr
            INTO CORRESPONDING FIELDS OF TABLE gt_zsl_dsales
            FOR ALL ENTRIES IN lt_zfvato
            WHERE zssutdt005~vbeln  = lt_zfvato-vbel1
              AND vkbur             = lt_zfvato-vkbur
              AND vkorg             = lt_zfvato-vkorg
              AND zssutdt005~vbtyp  = lt_zfvato-vbtyp
              AND kunnr             = lt_zfvato-kunrg.
        ENDIF.
        lt_makt[] = gt_zsl_dsales[].
        SORT lt_makt BY matnr.
        DELETE ADJACENT DUPLICATES FROM lt_makt COMPARING matnr.
        CHECK lt_makt[] IS NOT INITIAL.
        SELECT makt~matnr maktx
          FROM makt
          INTO TABLE gt_makt
          FOR ALL ENTRIES IN lt_makt
          WHERE matnr = lt_makt-matnr
            AND spras = sy-langu.
      ELSE.
        PERFORM f_select_fr_shipment.

*        IF pa_vkbur = 'T220' OR pa_vkbur = 'T203'.
        IF pa_vkbur IN gr_vkburi.
          SELECT vbrk~vbeln vkorg posnr uepos fkimg vrkme matnr
                 arktx vbrp~netwr kvgr3 mwsbp upmat ktgrm
            FROM vbrk JOIN vbrp ON vbrk~vbeln = vbrp~vbeln
            INTO CORRESPONDING FIELDS OF TABLE gt_vbrp
            FOR ALL ENTRIES IN gt_zfvato
            WHERE vbrk~vbeln = gt_zfvato-vbeln
              AND fkimg NE 0
              AND ( pstyv NE 'ZT9O'
              AND pstyv NE 'ZR9O' )
              AND taxm1 NE '0'.

          LOOP AT gt_vbrp.
            IF pa_bahan IS INITIAL.
              IF gt_vbrp-ktgrm NE '01' AND gt_vbrp-ktgrm NE '10'.
                DELETE gt_vbrp.
              ENDIF.
            ELSE.
              IF gt_vbrp-ktgrm NE '08'.
                DELETE gt_vbrp.
              ENDIF.
            ENDIF.
          ENDLOOP.

        ELSE.
          SELECT vbrk~vbeln vkorg posnr uepos fkimg vrkme matnr
                 arktx vbrp~netwr kvgr3 mwsbp upmat ktgrm
            FROM vbrk JOIN vbrp ON vbrk~vbeln = vbrp~vbeln
            INTO CORRESPONDING FIELDS OF TABLE gt_vbrp
            FOR ALL ENTRIES IN gt_zfvato
            WHERE vbrk~vbeln = gt_zfvato-vbeln
              AND fkimg NE 0
              AND ( pstyv NE 'ZT9O'
              AND pstyv NE 'ZR9O' ).
        ENDIF.

        SELECT knumv kposn koaid kschl kwert kbetr kinak
          INTO TABLE gt_konv
          FROM konv
          FOR ALL ENTRIES IN gt_zfvato
          WHERE knumv = gt_zfvato-knumv
            AND kntyp IN (' ','F').

        SELECT *
          FROM konv
          INTO CORRESPONDING FIELDS OF TABLE gt_tax
          FOR ALL ENTRIES IN gt_zfvato
          WHERE knumv = gt_zfvato-knumv
            AND kschl = 'ZVAT'.
      ENDIF.

      SELECT *
        FROM vbkd
        INTO CORRESPONDING FIELDS OF TABLE gt_vbkd
        FOR ALL ENTRIES IN gt_zfvato
        WHERE vbeln = gt_zfvato-vbelv.

      SELECT mblnr mjahr zeile matnr menge meins dmbtr waers bukrs umwrk
        FROM mseg
        INTO TABLE lt_mseg
        FOR ALL ENTRIES IN gt_zfvato
        WHERE bukrs = gt_zfvato-vkorg
          AND bwart = '641'
          AND umwrk = gt_zfvato-vkbur
          AND mjahr = gt_zfvato-dueyr
          AND mblnr = gt_zfvato-vbeln.

      SORT lt_mseg BY mblnr matnr.
      LOOP AT lt_mseg.
        gt_mseg = lt_mseg.
        CLEAR gt_mseg-zeile.
        COLLECT gt_mseg.
      ENDLOOP.

      lt_makt1[] = gt_mseg[].
      SORT lt_makt1 BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_makt1 COMPARING matnr.
      IF lt_makt1[] IS NOT INITIAL.
        SELECT makt~matnr maktx
          FROM makt
          INTO TABLE gt_makt
          FOR ALL ENTRIES IN lt_makt1
          WHERE matnr = lt_makt1-matnr
            AND spras = sy-langu.
      ENDIF.

      lt_kna1[] = gt_zfvato[].
      SORT lt_kna1 BY kunrg.
      DELETE ADJACENT DUPLICATES FROM lt_kna1 COMPARING kunrg.
      SELECT kunnr city2 stcd1 cityc stceg
        FROM kna1 JOIN adrc ON kna1~adrnr = adrc~addrnumber
        INTO TABLE gt_kna1
        FOR ALL ENTRIES IN lt_kna1
        WHERE kunnr = lt_kna1-kunrg.
    ENDIF.
  ENDIF.

  lt_makt[] = gt_zsl_dsales[].
  SORT lt_makt BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_makt COMPARING matnr.
  IF lt_makt[] IS NOT INITIAL.
    SELECT matnr meins
      FROM mara
      INTO TABLE gt_mara
      FOR ALL ENTRIES IN lt_makt
      WHERE matnr = lt_makt-matnr.
  ENDIF.

  lt_knvv[] = gt_zsl_dsales[].
  SORT lt_knvv BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_knvv COMPARING kunnr.
  IF lt_knvv[] IS NOT INITIAL.
    SELECT kunnr kvgr3
      FROM knvv
      INTO TABLE gt_knvv
      FOR ALL ENTRIES IN lt_knvv
      WHERE kunnr = lt_knvv-kunnr.
  ENDIF.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  CASE 'X'.
    WHEN ra_rpt.
      PERFORM f_alv1 TABLES gt_zfvato.
    WHEN OTHERS.
      SORT gt_out BY zuonr.
      PERFORM f_alv TABLES gt_out gt_of.
  ENDCASE.
ENDFORM.                    "F_PRINT_DATA

*---------------------------------------------------------------------*
*       FORM F_ALV
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report ft_report1.
  DATA: lv_func(30),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report ft_report1.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_keyinfo     USING   d_alv_keyinfo.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  PERFORM f_build_event       TABLES  t_alv_event[].
  lv_func    = 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'.

  CALL FUNCTION lv_func
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
      it_sort                  = t_alv_isort[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      i_tabname_header         = 'GT_OUT'
      i_tabname_item           = 'GT_OF'
      is_keyinfo               = d_alv_keyinfo
      is_print                 = d_print
    TABLES
      t_outtab_header          = ft_report
      t_outtab_item            = ft_report1
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    "F_ALV

*&---------------------------------------------------------------------*
*&      Form  F_ALV1
*&---------------------------------------------------------------------*
FORM f_alv1 TABLES ft_report.
  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat1   TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  PERFORM f_build_event       TABLES  t_alv_event[].
  lv_func    = 'REUSE_ALV_LIST_DISPLAY'.

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
ENDFORM.                                                    " F_ALV1

*---------------------------------------------------------------------*
*       FORM F_FIELDCAT
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report ft_report1.
  REFRESH: t_alv_fieldcat.
  PERFORM f_fieldcatg USING 'GT_OUT':
    'FK' '' '' '' '4' 'FK' '' '' '' '' '' '' '' '' '' '',
    'KD_JENIS_TRANSAKSI' '' '' '' '10' 'KdJnsTran.' '' '' '' '' '' '' '' '' '' '',
    'FG_PENGGANTI' '' '' '' '15' 'FG_PENGGANTI' '' '' '' '' '' '' '' '' '' '',
    'NOMOR_FAKTUR' '' '' '' '15' 'NOMOR_FAKTUR' '' '' '' '' '' '' '' '' '' '',
    'MASA_PAJAK' '' '' '' '7' 'MsPajak' '' '' '' '' '' '' '' '' '' '',
    'TAHUN_PAJAK' '' '' '' '5' 'Tahun' '' '' '' '' '' '' '' '' '' '',
    'TANGGAL_FAKTUR' '' '' '' '10' 'TglFktr' '' '' '' '' '' '' '' '' '' '',
    'NPWP' '' '' '' '20' 'NPWP' '' '' '' '' '' '' '' '' '' '',
    'NAMA' '' '' '' '60' 'NAMA' '' '' '' '' '' '' '' '' '' '',
"    'NAMA' '' '' '' '30' 'NAMA' '' '' '' '' '' '' '' '' '' '',
    'ALAMAT_LENGKAP' '' '' '' '255' 'Alamat' '' '' '' '' '' '' '' '' '' '',
    'JUMLAH_DPP' '' '' '' '20' 'DPP' '' '' '' '' '' '' '' '' '' '',
    'JUMLAH_PPN' '' '' '' '20' 'PPN' '' '' '' '' '' '' '' '' '' '',
    'JUMLAH_PPNBM' '' '' '' '20' 'PPN BM' '' '' '' '' '' '' '' '' '' '',
    'ID_KETERANGAN_TAMBAHAN' '' '' '' '4' 'ID' '' '' '' '' '' '' '' '' '' ''.
  IF pa_bukrs = '8220'.
    PERFORM f_fieldcatg USING 'GT_OUT':
      'UANG_MUKA' '' '' '' '20' 'FG_UANG_MUKA' '' '' '' '' '' '' '' '' '' ''.
  ELSE.
    PERFORM f_fieldcatg USING 'GT_OUT':
      'UANG_MUKA' '' '' '' '20' 'UANG MUKA' '' '' '' '' '' '' '' '' '' ''.
  ENDIF.
  PERFORM f_fieldcatg USING 'GT_OUT':
    'UANG_MUKA_DPP' '' '' '' '20' 'UANG_MUKA_DPP' '' '' '' '' '' '' '' '' '' '',
    'UANG_MUKA_PPN' '' '' '' '20' 'UANG_MUKA_PPN' '' '' '' '' '' '' '' '' '' '',
    'UANG_MUKA_PPNBM' '' '' '' '20' 'UANG_MUKA_PPNBM' '' '' '' '' '' '' '' '' '' '',
    'REFERENSI' '' '' '' '110' 'REFERENSI' '' '' '' '' '' '' '' '' '' '',
    'KODE_DOKUMEN_PENDUKUNG' '' '' '' '50' 'KODE_DOKUMEN_PENDUKUNG' '' '' '' '' '' '' '' '' '' ''.

  PERFORM f_fieldcatg USING 'GT_OF':
    'OF' '' '' '' '4' 'OF' '' '' '' '' '' '' '' '' '' '',
    'KODE_OBJEK' '' '' '' '20' 'KODE_OBJEK' '' '' '' '' '' '' '' '' '' '',
*    'NAMA' '' '' '' '50' 'NAMA' '' '' '' '' '' '' '' '' '' '',
    'NAMA' '' '' '' '60' 'NAMA' '' '' '' '' '' '' '' '' '' '',
    'HARGA_SATUAN' '' '' '' '20' 'HARGA_SATUAN' '' '' '' '' '' '' '' '' '' '',
    'JUMLAH_BARANG' '' '' '' '20' 'JUMLAH_BARANG' '' '' '' '' '' '' '' '' '' '',
    'HARGA_TOTAL' '' '' '' '20' 'HARGA_TOTAL' '' '' '' '' '' '' '' '' '' '',
    'DISKON' '' '' '' '20' 'DISKON' '' '' '' '' '' '' '' '' '' '',
    'DPP' '' '' '' '20' 'DPP' '' '' '' '' '' '' '' '' '' '',
    'PPN' '' '' '' '20' 'PPN' '' '' '' '' '' '' '' '' '' '',
    'TARIF_PPNBM' '' '' '' '20' 'TARIF_PPNBM' '' '' '' '' '' '' '' '' '' '',
    'PPNBM' '' '' '' '20' 'PPNBM' '' '' '' '' '' '' '' '' '' ''.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'GT_OUT'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'GT_OF'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM F_FIELDCAT1
*---------------------------------------------------------------------*
FORM f_build_fieldcat1 TABLES ft_report.
  REFRESH: t_alv_fieldcat.
  PERFORM f_fieldcatg USING ft_report:
    'VKORG' 'ZFVATO' 'VKORG' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VKBUR' 'ZFVATO' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VATNO' 'ZFVATO' 'VATNO' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VBELN' 'ZFVATO' 'VBELN' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZUONR' 'ZFVATO' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'DUEYR' 'ZFVATO' 'DUEYR' ''   '' 'Tahun' '' '' '' '' '' '' '' '' '' '',
    'NAMA_TEXT'   ''      '' '' '80' 'Nama' '' '' '' '' '' '' '' '' '' '',
    'DUDAT' 'ZFVATO' 'DUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'STCEG' 'ZFVATO' 'STCEG' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NETWR' 'ZFVATO' 'NETWR' '' '' '' '' '' '' 'IDR' '' '' '' '' '' '',
    'MWSBK' 'ZFVATO' 'MWSBK' '' '' '' '' '' '' 'IDR' '' '' '' '' '' '',
    'FILES' 'ZFVATO' 'FILES' '' '' '' '' '' '' '' '' '' '' '' '' ''.
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
                          VALUE(fu_emphasize).

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

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_KEYINFO
*&---------------------------------------------------------------------*
FORM f_build_keyinfo  USING    fu_keyinfo TYPE slis_keyinfo_alv.
  fu_keyinfo-header01 = 'VBELN'.
  fu_keyinfo-item01   = 'VBELN'.
ENDFORM.                    " F_BUILD_KEYINFO

*---------------------------------------------------------------------*
*       FORM F_BUILD_SORTFIELD
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'VBELN'.
*  ld_sort-up        = 'X'.
**  ld_sort-group     = 'UL'.
**  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.
ENDFORM.                    "F_BUILD_SORTFIELD

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM f_top_of_page.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING gv_filename.
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
  CASE 'X'.
    WHEN ra_rpt.
      SET PF-STATUS 'STANDARD'.
    WHEN OTHERS.
      SET PF-STATUS 'TOEXECUTE'.
  ENDCASE.
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
  DATA : lv_vatpr    TYPE zvapr,
         lv_hargasat TYPE mc_umkzwi1,
         lv_hargattl TYPE mc_umkzwi1,
         lv_dpp      TYPE mc_umkzwi1,
         lv_ppn      TYPE mc_umkzwi1,
         lv_diskon   TYPE mc_umkzwi1,
         lv_ttldis   TYPE mc_umkzwi1,
         lv_netwr    TYPE mc_umkzwi1,
         lv_vbeln    TYPE vbeln,
         lv_ummenge	 TYPE mc_ummenge,
         lv_basme    TYPE meins,
         lv_wrbtr    TYPE wrbtr,
         lv_mwsbk    TYPE mwsbp,
         lv_lines    TYPE int4,
         lv_subrc    TYPE sy-subrc.

  DATA : name   TYPE tdobname.

  DATA : lt_itab  TYPE STANDARD TABLE OF tline,
         lt_lines TYPE STANDARD TABLE OF tline,
         wa_lines LIKE tline.

  DATA : BEGIN OF lt_marc OCCURS 0,
           matnr TYPE matnr,
           werks TYPE werks_d,
           vkbur TYPE vkbur,
           stawn TYPE stawn,
         END OF lt_marc,
         lt_msegtmp LIKE TABLE OF gt_mseg WITH HEADER LINE.

  DATA : ls_vbkd    LIKE LINE OF gt_vbkd.

  PERFORM f_header CHANGING gv_filename gv_files gv_nomor.

  READ TABLE gt_zplbc INTO wa_zplbc INDEX 1.

  LOOP AT gt_zfvato INTO wa_zfvato.
    wa_zfvato-files = gv_files.
    MODIFY gt_zfvato FROM wa_zfvato TRANSPORTING files.

    gt_out-fk                   = 'FK'.
    gt_out-vkbur                = wa_zfvato-vkbur.
    gt_out-vbeln                = wa_zfvato-vbeln.
    gt_out-zuonr                = wa_zfvato-zuonr.

    PERFORM f_modify_npwp USING wa_zfvato-vatpr
                        CHANGING lv_vatpr.

    gt_out-kd_jenis_transaksi   = lv_vatpr(2).
    gt_out-fg_pengganti         = '0'.
    gt_out-nomor_faktur         = lv_vatpr+3(13).

    IF wa_zfvato-flkor IS INITIAL.
      gt_out-fg_pengganti   = '0'.
    ELSE.
      gt_out-fg_pengganti   = '1'.
    ENDIF.

    gt_out-masa_pajak    = wa_zfvato-dudat+4(2).
    gt_out-tahun_pajak   = wa_zfvato-dudat(4).

    PERFORM f_modify_date USING wa_zfvato-dudat
                          CHANGING gt_out-tanggal_faktur.

    IF wa_zfvato-stceg IS INITIAL.
      wa_zfvato-stceg = '000000000000000'.
    ENDIF.

    PERFORM f_modify_npwp USING wa_zfvato-stceg
                          CHANGING gt_out-npwp.

    PERFORM f_remove_special_char USING wa_zfvato-name_co
                                  CHANGING wa_zfvato-name_co.
    PERFORM f_remove_special_char USING wa_zfvato-nama_text
                                  CHANGING wa_zfvato-nama_text.
*    gt_out-nama   = wa_zfvato-name_co.
    gt_out-nama   = wa_zfvato-nama_text.
    PERFORM f_remove_special_char USING wa_zfvato-str_suppl1
                                  CHANGING wa_zfvato-str_suppl1.
    PERFORM f_remove_special_char USING wa_zfvato-str_suppl2
                                  CHANGING wa_zfvato-str_suppl2.
    PERFORM f_remove_special_char USING wa_zfvato-ort01
                                  CHANGING wa_zfvato-ort01.
    PERFORM f_remove_special_char USING wa_zfvato-stras
                                  CHANGING wa_zfvato-stras.

    READ TABLE gt_kna1 WITH KEY kunnr = wa_zfvato-kunrg.
    IF sy-subrc = 0.
      PERFORM f_remove_special_char USING gt_kna1-city2
                                    CHANGING gt_kna1-city2.
      IF wa_zfvato-cityc = 'T0'.
        IF gt_kna1-stcd1 IS INITIAL.
          gt_out-npwp = '0000000000000000'.
        ELSE.
          gt_out-npwp = gt_kna1-stcd1.
        ENDIF.
      ENDIF.
    ELSE.
      CLEAR gt_kna1-city2.
    ENDIF.

    IF ra_rfk = 'X' AND pa_rdm = 'X'.
      IF gt_kna1-cityc = 'T0'.
        IF gt_kna1-stcd1 IS INITIAL.
          gt_out-npwp = '0000000000000000'.
        ELSE.
          gt_out-npwp = gt_kna1-stcd1.
        ENDIF.
      ELSE.
        gt_out-npwp = gt_kna1-stceg.
      ENDIF.
    ENDIF.

    CASE wa_zfvato-vkorg.
      WHEN '8020' OR '8070'.
        IF wa_zfvato-cityc = 'T0' AND gt_kna1-stcd1 NE space.
          CLEAR gt_out-nama.
*          CONCATENATE gt_kna1-stcd1 '#NIK#NAMA#' wa_zfvato-name_co
*          INTO gt_out-nama.
          gt_out-nama = wa_zfvato-name_co.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.

    CASE wa_zfvato-vtart.
      WHEN 'FI'.
        CONCATENATE wa_zfvato-fstreet gt_kna1-city2
                    wa_zfvato-fcity1 wa_zfvato-fpost_code1
                    wa_zfvato-location
               INTO gt_out-alamat_lengkap
        SEPARATED BY space.
      WHEN 'SD'.
        CONCATENATE wa_zfvato-str_suppl1 wa_zfvato-str_suppl2
                    wa_zfvato-stras wa_zfvato-location
               INTO gt_out-alamat_lengkap
        SEPARATED BY space.
      WHEN 'DN'.
        CONCATENATE wa_zfvato-str_suppl1 wa_zfvato-str_suppl2
                    wa_zfvato-stras wa_zfvato-location
               INTO gt_out-alamat_lengkap
        SEPARATED BY space.
    ENDCASE.

    DATA: BEGIN OF lt_kunnr OCCURS 0,
            kunnr          LIKE kna1-kunnr,
            nama_text(135),
          END OF lt_kunnr.
    DATA lv_header       LIKE thead.
    DATA: ld_tdname LIKE thead-tdname.
    ld_tdname = wa_zfvato-kunrg.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = '0018'
        language                = sy-langu
        name                    = ld_tdname
        object                  = 'KNA1'
      IMPORTING
        header                  = lv_header
      TABLES
        lines                   = lt_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc EQ 0.
      DATA: temp_lines TYPE char255.
      CLEAR: temp_lines.
      DESCRIBE TABLE lt_lines LINES DATA(lv_line).
      LOOP AT lt_lines INTO DATA(ls_lines).
        IF lv_line > 1.
          IF sy-tabix = 1.
            temp_lines = ls_lines-tdline.
          ELSE.
            CONCATENATE temp_lines ls_lines-tdline INTO temp_lines SEPARATED BY space.
          ENDIF.
          gt_out-alamat_lengkap = temp_lines.
        ELSE.
          gt_out-alamat_lengkap = ls_lines-tdline.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF pa_bukrs = '8220'.
      wa_zplbc-live = 'X'.
    ENDIF.

    IF wa_zplbc-live IS INITIAL.
      wa_zfvato-netwr = wa_zfvato-netwr - wa_zfvato-mwsbk.
    ENDIF.
    IF wa_zfvato-vtart = 'FI'.
      wa_zfvato-netwr = wa_zfvato-netwr * 12 / 11.
    ENDIF.
    PERFORM f_modify_value USING wa_zfvato-netwr '' ''
                           CHANGING gt_out-jumlah_dpp.
    PERFORM f_modify_value USING wa_zfvato-mwsbk '' ''
                           CHANGING gt_out-jumlah_ppn.
    PERFORM f_modify_value USING '0' '' ''
                           CHANGING gt_out-jumlah_ppnbm.

    CASE lv_vatpr(2).
      WHEN '07'.
        IF wa_zfvato-vtart = 'SD'.
          CASE pa_vkbur.
            WHEN '8020'.
              READ TABLE gt_zsl_dsales WITH KEY account_no = wa_zfvato-vbeln.
            WHEN '8070'.
              READ TABLE gt_zsl_dsales WITH KEY vbeln = wa_zfvato-zuonr(10).
          ENDCASE.
          CLEAR ls_vbkd.
          READ TABLE gt_vbkd INTO ls_vbkd WITH KEY vbeln = wa_zfvato-vbelv.

          IF gt_zsl_dsales-taxcode = 'A2' OR
            ls_vbkd-inco1 = 'A2'.
            gt_out-id_keterangan_tambahan = '5'.
          ELSE.
            gt_out-id_keterangan_tambahan = '1'.
          ENDIF.
        ELSE.
          gt_out-id_keterangan_tambahan = '18'.
        ENDIF.
      WHEN '08'.
        gt_out-id_keterangan_tambahan = '4'.
    ENDCASE.

    PERFORM f_modify_value USING '0' '' ''
                           CHANGING gt_out-uang_muka.
    PERFORM f_modify_value USING '0' '' ''
                           CHANGING gt_out-uang_muka_dpp.
    PERFORM f_modify_value USING '0' '' ''
                           CHANGING gt_out-uang_muka_ppn.
    PERFORM f_modify_value USING '0' '' ''
                           CHANGING gt_out-uang_muka_ppnbm.

    CASE wa_zfvato-vtart.
      WHEN 'DN'.
        READ TABLE gt_zfvatshipbtm WITH KEY tknum  = wa_zfvato-vbeln
                                   TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          CONCATENATE wa_zfvato-vkbur wa_zfvato-kunrg wa_zfvato-vbeln
                      gv_files
          INTO gt_out-referensi
          SEPARATED BY space.
        ELSE.
          CONCATENATE wa_zfvato-vkbur wa_zfvato-kunrg wa_zfvato-vbeln
                      wa_zfvato-zuonr gv_files
          INTO gt_out-referensi
          SEPARATED BY space.
        ENDIF.
      WHEN OTHERS.
        CONCATENATE wa_zfvato-vkbur wa_zfvato-kunrg wa_zfvato-vbeln
                    wa_zfvato-zuonr gv_files
        INTO gt_out-referensi
        SEPARATED BY space.
        IF wa_zfvato-vtart = 'SD'.
          IF lv_vatpr+1(1) = '7' AND
            gt_out-id_keterangan_tambahan = '5'.
            CONCATENATE gt_out-referensi
            'PPN DITANGGUNG PEMERINTAH EKSEKUSI PMK NOMOR 226/PMK.03/2021'
*            'PPN DITANGGUNG PEMERINTAH EKS PMK NOMOR 143/PMK.03/2020'
            INTO gt_out-referensi
            SEPARATED BY space.
          ENDIF.
          IF lv_vatpr+1(1) = '8'.
            CONCATENATE gt_out-referensi
            'PPN DIBEBASKAN ATAS BARANG KEBUTUHAN POKOK (UU HPP NO 7 TAHUN 2021)'
            INTO gt_out-referensi
            SEPARATED BY space.
          ENDIF.
        ENDIF.
    ENDCASE.

    gt_out-vkorg  = wa_zfvato-vkorg.
    READ TABLE gt_vbrp WITH KEY vbeln = wa_zfvato-vbeln.
    IF sy-subrc = 0.
      gt_out-kvgr3  = gt_vbrp-kvgr3.
    ENDIF.

    gt_out-vtart = wa_zfvato-vtart.

    APPEND gt_out.
    CLEAR gt_out.

    CASE wa_zfvato-vtart.
      WHEN 'DN'.
        READ TABLE gt_zfvatshipbtm WITH KEY tknum  = wa_zfvato-vbeln
                                   TRANSPORTING NO FIELDS.
        IF sy-subrc IS INITIAL.
          PERFORM f_dn_with_shipment.
        ELSE.

          lt_msegtmp[] = gt_mseg[].
          SORT lt_msegtmp BY matnr.
          DELETE ADJACENT DUPLICATES FROM lt_msegtmp COMPARING matnr.
          IF lt_msegtmp[] IS NOT INITIAL.
            SELECT a~matnr a~werks b~vstel a~stawn
              INTO TABLE lt_marc
              FROM marc AS a JOIN tvkol AS b ON a~werks = b~werks
              FOR ALL ENTRIES IN lt_msegtmp
              WHERE a~matnr EQ lt_msegtmp-matnr
                AND b~vstel EQ '0246'.          "Jika 'DN' pasti '0246'
          ENDIF.

          LOOP AT gt_mseg WHERE bukrs = wa_zfvato-vkorg
                            AND umwrk = wa_zfvato-vkbur
                            AND mjahr = wa_zfvato-dueyr
                            AND mblnr = wa_zfvato-vbeln.

            CLEAR : lv_hargasat.
            gt_of-vkbur  = wa_zfvato-vkbur.
            gt_of-vbeln  = wa_zfvato-vbeln.
            gt_of-of     = 'OF'.
            gt_of-kode_objek  = gt_mseg-matnr.
            READ TABLE gt_makt WITH KEY matnr = gt_mseg-matnr.
            IF sy-subrc EQ 0.
              gt_of-nama  = gt_makt-maktx.
            ENDIF.

            CLEAR lt_marc.
            READ TABLE lt_marc WITH KEY matnr = gt_mseg-matnr.
            IF sy-subrc = 0 AND lt_marc-stawn IS NOT INITIAL.
              CONCATENATE lt_marc-stawn gt_of-nama
                INTO gt_of-nama SEPARATED BY ' - '.
            ELSE.
              MESSAGE 'Belum Maintain HS Code' TYPE 'I' DISPLAY LIKE 'E'.
              STOP.
            ENDIF.

            lv_hargasat = gt_mseg-dmbtr / gt_mseg-menge.
            lv_ppn  = gt_mseg-dmbtr * ( 11 / 100 ).

            PERFORM f_add_value USING gt_mseg-menge gt_mseg-meins lv_hargasat
                                      gt_mseg-dmbtr 0 gt_mseg-dmbtr lv_ppn.

            APPEND gt_of.
            CLEAR gt_of.
          ENDLOOP.
        ENDIF.

      WHEN 'FI'.
        gt_of-vkbur  = wa_zfvato-vkbur.
        gt_of-vbeln  = wa_zfvato-vbeln.
        gt_of-of     = 'OF'.

        CONCATENATE wa_zfvato-vkorg wa_zfvato-vbeln wa_zfvato-dueyr
        INTO name.

        CALL FUNCTION 'READ_TEXT_INLINE'
          EXPORTING
            id             = '0004'
            inline_count   = 15
            language       = 'E'
            name           = name
            object         = 'BELEG'
          TABLES
            inlines        = lt_itab
            lines          = lt_lines
          EXCEPTIONS
            id             = 1
            language       = 2
            name           = 3
            not_found      = 4
            object         = 5
            refrence_check = 6
            OTHERS         = 7.

        DESCRIBE TABLE lt_itab LINES lv_lines.

        IF lv_lines = 1.
          READ TABLE lt_lines INTO wa_lines INDEX 1.

          gt_of-nama = wa_lines-tdline(40).
          lv_ummenge = wa_lines-tdline+50(13).
          lv_ummenge = lv_ummenge / 100.
          IF lv_ummenge IS INITIAL.
            lv_ummenge = 1.
          ENDIF.

          lv_basme   = wa_lines-tdline+94(4).
          IF lv_basme IS INITIAL.
            lv_basme = 'UNT'.
          ENDIF.

          TRY .
              lv_hargasat = wa_zfvato-netwr / lv_ummenge.
            CATCH cx_sy_zerodivide.
          ENDTRY.

          PERFORM f_add_value USING lv_ummenge lv_basme lv_hargasat
                                    wa_zfvato-netwr 0 wa_zfvato-netwr wa_zfvato-mwsbk.

          APPEND gt_of.
          CLEAR : gt_of, lv_ummenge, lv_basme.
        ELSE.
          LOOP AT lt_lines INTO wa_lines.
            gt_of-nama = wa_lines-tdline(40).
            lv_ummenge = wa_lines-tdline+50(13).
            lv_ummenge = lv_ummenge / 100.

            IF lv_ummenge IS INITIAL.
              lv_ummenge = 1.
            ENDIF.
            lv_basme   = wa_lines-tdline+94(4).
            IF lv_basme IS INITIAL.
              lv_basme = 'UNT'.
            ENDIF.

            lv_netwr    = wa_lines-tdline+78(13).
            lv_netwr    = lv_netwr / 100.

            PERFORM f_tax_calc USING so_fkdat-low lv_netwr 'F'
                               CHANGING lv_mwsbk.

*            lv_mwsbk    = lv_netwr * ( 10 / 100 ).
            lv_wrbtr    = lv_netwr.
            lv_hargasat = lv_wrbtr / lv_ummenge.

            PERFORM f_add_value USING lv_ummenge lv_basme lv_hargasat
                                      lv_wrbtr 0 lv_netwr lv_mwsbk.

            APPEND gt_of.
            CLEAR : lv_ummenge, lv_basme.
          ENDLOOP.
          CLEAR : gt_of.
        ENDIF.

      WHEN 'SD'.
        IF wa_zplbc-live IS INITIAL.
          IF pa_bukrs EQ '8020'.
            PERFORM f_legacy_8020.
          ELSEIF pa_bukrs EQ '8070'.
            PERFORM f_legacy_8070.
          ENDIF.
        ELSE.
          PERFORM f_cabang_sap.
        ENDIF.
    ENDCASE.
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
    WHEN '&LOG'.
      CALL SCREEN 1400 STARTING AT 10 10 ENDING AT 130 22.

    WHEN '&POS'.
      PERFORM f_post_entries.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries.
  DATA : lv_subrc TYPE sy-subrc,
         filename TYPE string.

  PERFORM f_validasi_data.

  IF gt_error[] IS INITIAL.
    filename  = gv_filename.

    CALL FUNCTION 'ZF_EFAKTUR'
      EXPORTING
        pi_bukrs     = pa_bukrs
        filename     = filename
        delimiter    = pa_delim
        fk           = 'X'
        of           = 'X'
      IMPORTING
        zresult      = lv_subrc
      TABLES
        zfstefktr_fk = gt_out
        zfstefktr_of = gt_of.

    IF lv_subrc IS INITIAL.
      CASE 'X'.
        WHEN ra_fk.
          UPDATE zfnoefaktur SET znomor = gv_nomor
                           WHERE bukrs EQ pa_bukrs
                             AND zfakty EQ gc_zfakty.

          MODIFY zfvato FROM TABLE gt_zfvato.
          PERFORM f_write_zfvatdtbuyer.
        WHEN ra_rfk.
          PERFORM f_delete_zfvatdtbuyer.
          PERFORM f_write_zfvatdtbuyer.
      ENDCASE.
      LEAVE TO SCREEN 0.
    ENDIF.
  ELSE.
    MESSAGE e000(zab) WITH 'Format error, please check in error log'.
  ENDIF.
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
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  DATA : return    TYPE STANDARD TABLE OF bapiret2,
         groups    TYPE STANDARD TABLE OF bapigroups,
         ls_groups LIKE LINE OF groups.

  CASE 'X'.
    WHEN ra_fk.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'FN1' OR 'VB1' OR 'ZU1' OR 'FNM'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN ra_rfk.
      CALL FUNCTION 'BAPI_USER_GET_DETAIL'
        EXPORTING
          username = sy-uname
        TABLES
          return   = return
          groups   = groups.

      LOOP AT groups INTO ls_groups.
        IF ls_groups-usergroup(3) = 'TDS'.
          gv_tds  = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.

      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'KUN' OR 'FKD' OR 'VB1' OR 'ZU1'.
            screen-active  = 0.
          WHEN 'FN1'.
            IF gv_tds IS NOT INITIAL.
              screen-active  = 0.
            ENDIF.
          WHEN 'FNM'.
            IF gv_tds IS INITIAL.
              screen-active  = 0.
            ENDIF.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN ra_del.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'KUN' OR 'FKD' OR 'VBE' OR 'ZUO' OR 'BPJ' OR 'DEC' OR 'FNM'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN ra_rpt.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'FN1' OR 'VB1' OR 'DIS' OR 'DEL' OR 'ZU1' OR 'BPJ' OR 'DEC' OR 'FNM'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA : lt_zfnoefaktur  LIKE zfnoefaktur OCCURS 0 WITH HEADER LINE.

  IF pa_bukrs IS INITIAL.
    PERFORM f_error_selection_screen USING 'BUK' '0'.
  ENDIF.

  SELECT *
    FROM zfnoefaktur
    INTO CORRESPONDING FIELDS OF TABLE lt_zfnoefaktur
    WHERE bukrs  = pa_bukrs
      AND zfakty = gc_zfakty.

  READ TABLE lt_zfnoefaktur INDEX 1.

  CASE 'X'.
    WHEN ra_fk.
      IF pa_vkbur IS INITIAL.
        PERFORM f_error_selection_screen USING 'VKB' '0'.
      ENDIF.
      IF lt_zfnoefaktur-masatx = space.
        PERFORM f_error_selection_screen USING 'FKD' '2'.
      ELSE.
        IF so_fkdat-low(6) < lt_zfnoefaktur-masatx.
          PERFORM f_error_selection_screen USING 'FKD' '1'.
        ENDIF.
      ENDIF.
    WHEN ra_rfk.
      IF pa_vkbur IS INITIAL.
        PERFORM f_error_selection_screen USING 'VKB' '0'.
      ENDIF.
      IF gv_tds IS INITIAL.
        IF pa_flnm1 IS INITIAL.
          PERFORM f_error_selection_screen USING 'FN1' '0'.
        ENDIF.
      ELSE.
        IF so_flnm1[] IS INITIAL.
          PERFORM f_error_selection_screen USING 'FNM' '0'.
        ENDIF.
      ENDIF.
    WHEN ra_del.
      IF pa_vkbur IS INITIAL.
        PERFORM f_error_selection_screen USING 'VKB' '0'.
      ENDIF.
    WHEN ra_rpt.
      IF pa_vkbur IS INITIAL.
        PERFORM f_error_selection_screen USING 'VKB' '0'.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_HEADER
*&---------------------------------------------------------------------*
FORM f_header  CHANGING fc_filename fc_files fc_nomor.

  READ TABLE gt_zfnoefaktur INDEX 1.
  IF sy-subrc EQ 0.
    IF ra_rfk IS NOT INITIAL.
      gt_zfnoefaktur-znomor = pa_flnm1+2(6).
    ENDIF.
    pa_flnm1  = gt_zfnoefaktur-folder.

    IF ra_rfk IS NOT INITIAL.
      CONCATENATE pa_flnm1 '\' gc_zfakty gt_zfnoefaktur-znomor 'R.CSV'
             INTO fc_filename.
      CONCATENATE gc_zfakty gt_zfnoefaktur-znomor 'R.CSV'
             INTO fc_files.
    ELSE.
      CONCATENATE pa_flnm1 '\' gc_zfakty gt_zfnoefaktur-znomor '.CSV'
             INTO fc_filename.
      CONCATENATE gc_zfakty gt_zfnoefaktur-znomor '.CSV'
             INTO fc_files.
    ENDIF.
    fc_nomor  = gt_zfnoefaktur-znomor + 1.
  ENDIF.
ENDFORM.                    " F_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_CEK_LOCK
*&---------------------------------------------------------------------*
FORM f_cek_lock .
  CALL FUNCTION 'ENQUEUE_EZFNOEFAKTUR'
    EXPORTING
      bukrs          = pa_bukrs
      zfakty         = gc_zfakty
    EXCEPTIONS
      foreign_lock   = 4
      system_failure = 8.
  IF sy-subrc EQ 4.
    MESSAGE a000(zf) WITH 'Transaction current process by another W-S'.
  ENDIF.
ENDFORM.                    " F_CEK_LOCK

*&---------------------------------------------------------------------*
*&      Form  F_RELEASE_LOCK
*&---------------------------------------------------------------------*
FORM f_release_lock .
  CALL FUNCTION 'DEQUEUE_EZFNOEFAKTUR'
    EXPORTING
      bukrs  = pa_bukrs
      zfakty = gc_zfakty.
ENDFORM.                    " F_RELEASE_LOCK

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_NPWP
*&---------------------------------------------------------------------*
FORM f_modify_npwp  USING    fu_stceg
                    CHANGING fc_npwp.

  DATA : lv_subrc   TYPE sy-subrc.

  IF fu_stceg IS NOT INITIAL.
    fc_npwp = fu_stceg.
    WHILE lv_subrc EQ 0.
      REPLACE '.' WITH space INTO fc_npwp.
      lv_subrc = sy-subrc.
    ENDWHILE.
    CLEAR lv_subrc.
    WHILE lv_subrc EQ 0.
      REPLACE '-' WITH space INTO fc_npwp.
      lv_subrc = sy-subrc.
    ENDWHILE.
    CONDENSE fc_npwp NO-GAPS.
  ENDIF.
ENDFORM.                    " F_MODIFY_NPWP

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DATE
*&---------------------------------------------------------------------*
FORM f_modify_date  USING    fu_datum
                    CHANGING fc_datum.

  CONCATENATE fu_datum+6(2) fu_datum+4(2) fu_datum(4)
  INTO fc_datum
  SEPARATED BY '/'.
ENDFORM.                    " F_MODIFY_DATE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_VALUE
*&---------------------------------------------------------------------*
FORM f_modify_value  USING    fu_value fu_basme fu_flag
                     CHANGING fc_value.
  DATA : lv_subrc  TYPE sy-subrc,
         lv_length TYPE i,
         lv_value  TYPE p DECIMALS 0.

*  IF pa_decim IS INITIAL.
  CASE fu_flag.
    WHEN 'X'.
      lv_value  = fu_value.
      fc_value  = lv_value.

    WHEN OTHERS.
      IF fu_value IS NOT INITIAL.
        IF fu_basme IS NOT INITIAL.
          WRITE fu_value TO fc_value UNIT fu_basme.
        ELSE.
          fc_value = fu_value.
        ENDIF.

        WHILE lv_subrc EQ 0.
          REPLACE '.' WITH space INTO fc_value.
          lv_subrc = sy-subrc.
        ENDWHILE.
        CONDENSE fc_value NO-GAPS.

        lv_length = strlen( fc_value ).
        IF lv_length GT 1.
          SEARCH fc_value FOR ','.
          IF sy-subrc = 0.
            REPLACE ',' WITH '.' INTO fc_value.
          ELSE.
            SHIFT fc_value LEFT DELETING LEADING '0'.
          ENDIF.
        ENDIF.
      ENDIF.

      IF fc_value IS INITIAL.
        fc_value = '0'.
      ENDIF.
  ENDCASE.
*  ELSE.
*  ENDIF.
ENDFORM.                    " F_MODIFY_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group fu_error.
  DATA: lv_mess(100).

  CASE fu_error.
    WHEN '0'.
      lv_mess = 'Fill in all required entry fields'.
    WHEN '1'.
      lv_mess = 'Periode Pajak belum berlaku untuk eFaktur'.
    WHEN '2'.
      lv_mess = 'Periode Pajak belum di maintain untuk eFaktur'.
  ENDCASE.

  IF fu_group IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_DATA
*&---------------------------------------------------------------------*
FORM f_validasi_data .
  DATA : lv_baris   TYPE int4.
  DATA : lt_kdjnstr TYPE STANDARD TABLE OF zfe_kdjnstr.

  CLEAR lv_baris.
  SELECT *
    FROM zfe_kdjnstr
    INTO CORRESPONDING FIELDS OF TABLE lt_kdjnstr.

  LOOP AT gt_out.
    ADD 1 TO lv_baris.
    PERFORM f_validasi_efaktur TABLES lt_kdjnstr
                               USING  gt_out-kd_jenis_transaksi
                                      lv_baris '1'.
    PERFORM f_validasi_efaktur TABLES lt_kdjnstr
                               USING  gt_out-nomor_faktur
                                      lv_baris '2'.
    PERFORM f_validasi_efaktur TABLES lt_kdjnstr
                               USING  gt_out-npwp
                                      lv_baris '3'.
  ENDLOOP.
ENDFORM.                    " F_VALIDASI_DATA

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_EFAKTUR
*&---------------------------------------------------------------------*
FORM f_validasi_efaktur  TABLES   ft_kdjnstr STRUCTURE zfe_kdjnstr
                         USING    fu_value fu_baris fu_flag.
  DATA : lv_length TYPE i,
         lv_subrc  TYPE sy-subrc.

  CLEAR : lv_length, lv_subrc.

  gt_error-baris  = fu_baris.
  CASE fu_flag.
    WHEN '1'.
      READ TABLE ft_kdjnstr WITH KEY kdjnstr = fu_value.
      IF sy-subrc <> 0.
        lv_subrc  = fu_flag.
        gt_error-msg  = 'Kode Jenis Transaksi salah'.
      ENDIF.

    WHEN '2'.
      lv_length = strlen( fu_value ).
      IF lv_length <> 13.
        lv_subrc  = fu_flag.
      ELSE.
        IF fu_value CA '.-,'.
          lv_subrc  = fu_flag.
        ENDIF.
      ENDIF.

      CHECK lv_subrc IS NOT INITIAL.

      gt_error-msg  = 'Nomor Seri Faktur Pajak harus diisi 13 digit,'.
      CONCATENATE gt_error-msg 'tanpa tanda baca' INTO gt_error-msg
      SEPARATED BY space.

    WHEN '3'.
      lv_length = strlen( fu_value ).
      IF lv_length <> 15 AND lv_length <> 16.
        lv_subrc  = fu_flag.
      ELSE.
        IF fu_value CA '.-,'.
          lv_subrc  = fu_flag.
        ENDIF.
      ENDIF.

      CHECK lv_subrc IS NOT INITIAL.

      gt_error-msg  = 'NPWP harus diisi 15 / 16 digit,'.
      CONCATENATE gt_error-msg 'tanpa tanda baca' INTO gt_error-msg
      SEPARATED BY space.
  ENDCASE.

  CHECK lv_subrc IS NOT INITIAL.

  APPEND gt_error.
ENDFORM.                    " F_VALIDASI_EFAKTUR

*&---------------------------------------------------------------------*
*&      Module  STATUS_1400  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_1400 OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " STATUS_1400  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING_1400  OUTPUT
*&---------------------------------------------------------------------*
MODULE list_processing_1400 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_error_list.
ENDMODULE.                 " LIST_PROCESSING_1400  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_LIST
*&---------------------------------------------------------------------*
FORM f_error_list .
  SORT gt_error BY baris msg.
  DELETE ADJACENT DUPLICATES FROM gt_error COMPARING baris msg.

  IF gt_error[] IS INITIAL.
    SKIP 1.
    WRITE: /13 'No error occurs'.
  ELSE.
    ULINE AT /(90).
    WRITE: /  sy-vline NO-GAP, 'Baris' NO-GAP,
           13 sy-vline NO-GAP, 'Error message' NO-GAP,
           90 sy-vline.
    ULINE AT /(90).
    LOOP AT gt_error.
      WRITE: /  sy-vline NO-GAP, gt_error-baris NO-GAP,
             13 sy-vline NO-GAP, gt_error-msg(60) NO-GAP,
             90 sy-vline NO-GAP.
    ENDLOOP.
    ULINE AT /(90).
  ENDIF.
ENDFORM.                    " F_ERROR_LIST

*&---------------------------------------------------------------------*
*&      Form  F_DISCOUNT_ADJUSTMENT
*&---------------------------------------------------------------------*
FORM f_discount_adjustment .
  DATA : lv_dpp     LIKE gt_of-dpp,
         lv_ppn     LIKE gt_of-ppn,
         lwa_of     LIKE gt_of,
         lv_diskon  LIKE gt_of-diskon,
         lv_selisih LIKE gt_of-dpp,
         lv_selppn  LIKE gt_of-ppn,
         lv_seldis  LIKE gt_of-diskon,
         lv_datum   LIKE sy-datum.

  LOOP AT gt_out.
    CLEAR : lv_dpp, lwa_of, lv_ppn, lv_diskon.

    LOOP AT gt_of WHERE vkbur = gt_out-vkbur
                    AND vbeln = gt_out-vbeln.
      ADD gt_of-dpp     TO lv_dpp.
      ADD gt_of-ppn     TO lv_ppn.
      ADD gt_of-diskon  TO lv_diskon.
    ENDLOOP.

    lv_selisih  = gt_out-jumlah_dpp - lv_dpp.
    lv_selppn   = gt_out-jumlah_ppn - lv_ppn.

    CLEAR gt_diskon.
    READ TABLE gt_diskon WITH KEY vbeln = gt_out-vbeln.
    IF sy-subrc = 0.
      CONCATENATE gt_out-tanggal_faktur+6(4) gt_out-tanggal_faktur+3(2) gt_out-tanggal_faktur(2)
      INTO lv_datum.
      PERFORM f_tax_calc USING gt_out-tanggal_faktur gt_diskon-ttldis 'A'
                         CHANGING gt_diskon-ttldis.

*      gt_diskon-ttldis = gt_diskon-ttldis / ( 11 / 10 ).
      gt_diskon-ttldis = abs( gt_diskon-ttldis ).
    ENDIF.

    LOOP AT gt_of WHERE vbeln = gt_out-vbeln.
      IF lv_diskon <> 0.
        gt_of-diskon = gt_of-diskon +
                      ( ( gt_of-diskon / lv_diskon ) * gt_diskon-ttldis ).
      ENDIF.

      gt_of-dpp = gt_of-harga_total - gt_of-diskon. " ) / ( 11 / 10 ).

      CONCATENATE gt_out-tanggal_faktur+6(4) gt_out-tanggal_faktur+3(2) gt_out-tanggal_faktur(2)
      INTO lv_datum.
      PERFORM f_tax_calc USING lv_datum gt_of-dpp 'E'
                         CHANGING gt_of-ppn.

*      gt_of-ppn = gt_of-dpp * ( 10 / 100 ).

      PERFORM f_modify_value USING gt_of-diskon '' 'X'
                             CHANGING gt_of-diskon.
      PERFORM f_modify_value USING gt_of-diskon '' ''
                             CHANGING gt_of-diskon.
      PERFORM f_modify_value USING gt_of-dpp '' 'X'
                             CHANGING gt_of-dpp.
      PERFORM f_modify_value USING gt_of-dpp '' ''
                             CHANGING gt_of-dpp.
      PERFORM f_modify_value USING gt_of-ppn '' 'X'
                             CHANGING gt_of-ppn.
      PERFORM f_modify_value USING gt_of-ppn '' ''
                             CHANGING gt_of-ppn.

      gt_of-diskonv = gt_of-diskon.
      gt_of-dppv    = gt_of-dpp.
      MODIFY gt_of TRANSPORTING diskon dpp ppn diskonv dppv.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_DISCOUNT_ADJUSTMENT

*&---------------------------------------------------------------------*
*&      Form  F_REMOVE_SPECIAL_CHAR
*&---------------------------------------------------------------------*
FORM f_remove_special_char  USING    fu_value
                            CHANGING fc_value.
  DATA : specharsear(50) VALUE '"',
         lv_flag(1),
         itab            TYPE TABLE OF string,
         wa              LIKE LINE OF itab.

  fc_value = fu_value.
  SPLIT fc_value AT space INTO TABLE itab.

  LOOP AT itab INTO wa.
    TRANSLATE wa USING specharsear.
    CONDENSE wa NO-GAPS.
    IF lv_flag IS INITIAL.
      lv_flag = 'X'.
      fc_value  = wa.
    ELSE.
      CONCATENATE fc_value wa INTO fc_value SEPARATED BY space.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_REMOVE_SPECIAL_CHAR

*&---------------------------------------------------------------------*
*&      Form  F_ADD_VALUE
*&---------------------------------------------------------------------*
FORM f_add_value USING fu_ummenge fu_basme fu_hargasat
                       fu_hargattl fu_diskon fu_dpp fu_ppn.

  PERFORM f_modify_value USING fu_ummenge fu_basme ''
                         CHANGING gt_of-jumlah_barang.

  PERFORM f_modify_value USING fu_hargasat '' ''
                         CHANGING gt_of-harga_satuan.

  PERFORM f_modify_value USING fu_hargattl '' ''
                         CHANGING gt_of-harga_total.

  PERFORM f_modify_value USING fu_diskon '' ''
                         CHANGING gt_of-diskon.

  PERFORM f_modify_value USING fu_dpp '' ''
                         CHANGING gt_of-dpp.

  PERFORM f_modify_value USING fu_ppn '' ''
                         CHANGING gt_of-ppn.

  PERFORM f_modify_value USING '0' '' ''
                         CHANGING gt_of-tarif_ppnbm.

  PERFORM f_modify_value USING '0' '' ''
                         CHANGING gt_of-ppnbm.

ENDFORM.                    " F_ADD_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_DATA
*&---------------------------------------------------------------------*
FORM f_delete_data .
  DATA : answer(1),
         button1   TYPE iconname VALUE 'ICON_DELETE',
         button2   TYPE iconname VALUE 'ICON_CANCEL'.

  IF gt_zfvato[] IS NOT INITIAL.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        text_question         = 'Delete Data'
        text_button_1         = 'Yes'
        icon_button_1         = button1
        text_button_2         = 'No'
        icon_button_2         = button2
        display_cancel_button = ''
      IMPORTING
        answer                = answer
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.

    IF answer = '1'.
      LOOP AT gt_zfvato INTO wa_zfvato.
        CLEAR wa_zfvato-files.
        MODIFY gt_zfvato FROM wa_zfvato TRANSPORTING files.
      ENDLOOP.

      UPDATE zfvato FROM TABLE gt_zfvato.

      gv_subrc = sy-subrc.
    ELSE.
      gv_subrc = 4.
    ENDIF.
  ELSE.
    gv_subrc = 4.
  ENDIF.
ENDFORM.                    " F_DELETE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CABANG_SAP
*&---------------------------------------------------------------------*
FORM f_cabang_sap .
  DATA : lv_diskon  TYPE mc_umkzwi1,
         lv_diskon2 TYPE mc_umkzwi1,
         lv_kbetr   TYPE p DECIMALS 4,
         ls_tax     TYPE konv.

  DATA : BEGIN OF lt_vbrp OCCURS 0,
           vbeln TYPE vbeln_vf,
           zuonr TYPE ordnr_v,
           posnr TYPE posnr_vf,
           matnr TYPE matnr,
           arktx TYPE arktx,
           vrkme TYPE vrkme,
           fkimg TYPE fkimg,
           netwr TYPE netwr_fp,
           mwsbp TYPE mwsbp,
           kbetr TYPE kbetr,
           kwert TYPE kwert,
           sdisc TYPE kwert,
           vdisc TYPE kwert,
           cdisc TYPE kwert,
           zn0c  TYPE kwert,
         END OF lt_vbrp.
  DATA : lwa_vbrp LIKE lt_vbrp.

  DATA : lv_kwert   TYPE kwert.

  CLEAR : lt_vbrp[], lt_vbrp, gt_vbrp2.

  SORT gt_vbrp BY vbeln matnr.
  LOOP AT gt_vbrp WHERE vbeln = wa_zfvato-vbeln.
    LOOP AT gt_konv WHERE knumv = wa_zfvato-knumv
                      AND kposn = gt_vbrp-posnr.
      IF gt_konv-kinak IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      IF gt_konv-koaid = 'B'.
        PERFORM f_tax_calc USING so_fkdat-low gt_konv-kbetr 'A'
                           CHANGING lt_vbrp-kbetr.

*        lt_vbrp-kbetr = gt_konv-kbetr / ( 11 / 10 ).
*        lt_vbrp-kwert = gt_konv-kwert.
        CASE gt_konv-kschl.
          WHEN 'ZN01'.
*            IF pa_vkbur <> 'T220' AND pa_vkbur <> 'T203'.
            IF pa_vkbur IN gr_vkbure.
              lt_vbrp-kwert = gt_konv-kwert.
            ENDIF.
          WHEN 'ZNOL'.
*            IF pa_vkbur = 'T220' OR pa_vkbur = 'T203'.
            IF pa_vkbur IN gr_vkburi.
              lt_vbrp-kwert = gt_konv-kwert.
            ENDIF.
          WHEN 'ZN0C'.
*            IF pa_vkbur <> 'T220' AND pa_vkbur <> 'T203'.
            IF pa_vkbur IN gr_vkbure.
              lt_vbrp-zn0c = gt_konv-kwert.
            ENDIF.
        ENDCASE.
      ELSEIF gt_konv-koaid = 'A'.
        IF gt_konv-kschl CP 'ZA*'.
          ADD gt_konv-kwert TO lt_vbrp-sdisc.
        ELSEIF gt_konv-kschl CP 'ZB*'.
          ADD gt_konv-kwert TO lt_vbrp-sdisc.
        ELSEIF gt_konv-kschl CP 'ZC*'.
          ADD gt_konv-kwert TO lt_vbrp-sdisc.
        ELSEIF gt_konv-kschl CP 'ZD*'.
          IF gt_konv-kschl = 'ZD02'.
            ADD gt_konv-kwert TO lt_vbrp-cdisc.
          ELSE.
            ADD gt_konv-kwert TO lt_vbrp-sdisc.
          ENDIF.
        ELSEIF gt_konv-kschl CP 'ZE*'.
          ADD gt_konv-kwert TO lt_vbrp-sdisc.
        ELSEIF gt_konv-kschl CP 'ZF*'.
          ADD gt_konv-kwert TO lt_vbrp-sdisc.
        ELSEIF gt_konv-kschl CP 'ZV*'.
          ADD gt_konv-kwert TO lt_vbrp-vdisc.
        ENDIF.
      ENDIF.
    ENDLOOP.

    lt_vbrp-vbeln = wa_zfvato-vbeln.
    lt_vbrp-zuonr = wa_zfvato-zuonr.
    lt_vbrp-matnr = gt_vbrp-matnr.
    lt_vbrp-arktx = gt_vbrp-arktx.
    lt_vbrp-vrkme = gt_vbrp-vrkme.
    lt_vbrp-fkimg = gt_vbrp-fkimg.
    IF pa_bahan IS NOT INITIAL.
      lt_vbrp-netwr = gt_vbrp-netwr + gt_vbrp-mwsbp.
    ELSE.
      lt_vbrp-netwr = gt_vbrp-netwr.
    ENDIF.
    lt_vbrp-mwsbp = gt_vbrp-mwsbp.
*    lt_vbrp-kwert = lt_vbrp-kwert / ( 11 / 10 ).

*    lt_vbrp-sdisc = lt_vbrp-sdisc / ( 11 / 10 ).
*    lt_vbrp-vdisc = lt_vbrp-vdisc / ( 11 / 10 ).
*    lt_vbrp-cdisc = lt_vbrp-cdisc / ( 11 / 10 ).

    IF pa_hscod = 'X'.
    ELSE.
      READ TABLE gt_tax INTO ls_tax
                        WITH KEY knumv = wa_zfvato-knumv
                                 kposn = gt_vbrp-posnr.
      CASE ls_tax-mwsk1.
        WHEN 'A1'.
          lt_vbrp-kwert = lt_vbrp-kwert / ( 11 / 10 ).
          lt_vbrp-sdisc = lt_vbrp-sdisc / ( 11 / 10 ).
          lt_vbrp-vdisc = lt_vbrp-vdisc / ( 11 / 10 ).
          lt_vbrp-cdisc = lt_vbrp-cdisc / ( 11 / 10 ).
        WHEN 'A3'.
          IF pa_bahan IS INITIAL.
            lt_vbrp-kwert = lt_vbrp-kwert / ( 111 / 100 ).
            lt_vbrp-sdisc = lt_vbrp-sdisc / ( 111 / 100 ).
            lt_vbrp-vdisc = lt_vbrp-vdisc / ( 111 / 100 ).
            lt_vbrp-cdisc = lt_vbrp-cdisc / ( 111 / 100 ).
          ELSE.
            lt_vbrp-kwert = lt_vbrp-kwert.
            lt_vbrp-sdisc = lt_vbrp-sdisc.
            lt_vbrp-vdisc = lt_vbrp-vdisc.
            lt_vbrp-cdisc = lt_vbrp-cdisc.
          ENDIF.
      ENDCASE.
    ENDIF.

    lv_kwert = gt_vbrp-netwr - lt_vbrp-sdisc - lt_vbrp-vdisc - lt_vbrp-cdisc.
    IF lv_kwert <> lt_vbrp-kwert.
      lt_vbrp-kwert = lv_kwert.
    ENDIF.

    CLEAR lwa_vbrp.
    READ TABLE lt_vbrp INTO lwa_vbrp
                       WITH KEY vbeln = wa_zfvato-vbeln
                                zuonr = wa_zfvato-zuonr
                                matnr = gt_vbrp-matnr.
    IF sy-subrc = 0.
      CLEAR lt_vbrp-kbetr.
    ENDIF.

    COLLECT lt_vbrp. CLEAR lt_vbrp.
    CLEAR lv_kwert.
  ENDLOOP.

  LOOP AT lt_vbrp WHERE vbeln = wa_zfvato-vbeln.
    gt_of-vkbur       = wa_zfvato-vkbur.
    gt_of-vbeln       = wa_zfvato-vbeln.
    gt_of-of          = 'OF'.
    gt_of-kode_objek  = lt_vbrp-matnr.
    gt_of-nama        = lt_vbrp-arktx.

    PERFORM f_get_hscode USING gt_of-vkbur gt_of-kode_objek
                         CHANGING gt_of-nama.

*    lv_diskon = lt_vbrp-sdisc + lt_vbrp-vdisc + lt_vbrp-cdisc.
*    lv_diskon = ABS( lv_diskon ).
    IF lt_vbrp-zn0c IS INITIAL.
      lv_diskon = lt_vbrp-sdisc + lt_vbrp-vdisc + lt_vbrp-cdisc.
      lv_diskon = abs( lv_diskon ).
    ELSE.
      lv_diskon2 = lt_vbrp-sdisc + lt_vbrp-vdisc + lt_vbrp-cdisc.
      lv_diskon2 = abs( lv_diskon2 ).
*      lv_diskon = ( lt_vbrp-zn0c * 10 / 11 ) + lv_diskon2 - lt_vbrp-kwert.
*      lv_diskon = ABS( lv_diskon ).
*      lt_vbrp-kwert = lt_vbrp-zn0c * 10 / 11.
      IF pa_hscod = 'X'.
        lv_diskon = lt_vbrp-zn0c + lv_diskon2 - lt_vbrp-kwert.
        lv_diskon = abs( lv_diskon ).
        lt_vbrp-kwert = lt_vbrp-zn0c.
      ELSE.
        lv_diskon = ( lt_vbrp-zn0c * 100 / 111 ) + lv_diskon2 - lt_vbrp-kwert.
        lv_diskon = abs( lv_diskon ).
        lt_vbrp-kwert = lt_vbrp-zn0c * 100 / 111.
      ENDIF.
    ENDIF.

    PERFORM f_add_value USING lt_vbrp-fkimg lt_vbrp-vrkme lt_vbrp-kbetr
                              lt_vbrp-kwert lv_diskon lt_vbrp-netwr lt_vbrp-mwsbp.

    APPEND gt_of.
    CLEAR: gt_of,lv_diskon,lv_diskon2.
  ENDLOOP.
ENDFORM.                    " F_CABANG_SAP

*&---------------------------------------------------------------------*
*&      Form  F_LEGACY_8020
*&---------------------------------------------------------------------*
FORM f_legacy_8020 .
  DATA : lv_diskon TYPE mc_umkzwi1,
         lv_kbetr  TYPE p DECIMALS 4.

  DATA : BEGIN OF lt_vbrp OCCURS 0,
           vbeln TYPE vbeln_vf,
           zuonr TYPE ordnr_v,
           posnr TYPE posnr_vf,
           matnr TYPE matnr,
           arktx TYPE arktx,
           vrkme TYPE vrkme,
           fkimg TYPE fkimg,
           netwr TYPE netwr_fp,
           mwsbp TYPE mwsbp,
           kbetr TYPE kbetr,
           kwert TYPE kwert,
           sdisc TYPE kwert,
           vdisc TYPE kwert,
           cdisc TYPE kwert,
         END OF lt_vbrp.
  DATA : lwa_vbrp LIKE lt_vbrp.

  SORT gt_zsl_dsales BY vbeln matnr.
  LOOP AT gt_zsl_dsales WHERE vbeln = wa_zfvato-zuonr.
    CLEAR : lv_kbetr.
    READ TABLE gt_makt WITH KEY matnr = gt_zsl_dsales-matnr.
    IF sy-subrc = 0.
      lt_vbrp-arktx = gt_makt-maktx.
    ENDIF.

    READ TABLE gt_mara WITH KEY matnr = gt_zsl_dsales-matnr.
    IF sy-subrc = 0.
      lt_vbrp-vrkme = gt_mara-meins.
    ENDIF.

    lt_vbrp-vbeln = wa_zfvato-vbeln.
    lt_vbrp-zuonr = wa_zfvato-zuonr.
    lt_vbrp-matnr = gt_zsl_dsales-matnr.
    lt_vbrp-fkimg = gt_zsl_dsales-fkimg.
*    lt_vbrp-kwert = gt_zsl_dsales-nsp / ( 11 / 10 ).

    lt_vbrp-kbetr = lt_vbrp-kwert / lt_vbrp-fkimg.

*    lt_vbrp-sdisc = ( gt_zsl_dsales-disa + gt_zsl_dsales-disb +
*                    gt_zsl_dsales-disc + gt_zsl_dsales-disd +
*                    gt_zsl_dsales-disdc + gt_zsl_dsales-dise +
*                    gt_zsl_dsales-disf ) / ( 11 / 10 ).
*    lt_vbrp-vdisc = gt_zsl_dsales-disvol / ( 11 / 10 ).
*    lt_vbrp-cdisc = gt_zsl_dsales-cod / ( 11 / 10 ).

    IF pa_hscod = 'X'.
      lt_vbrp-kwert = gt_zsl_dsales-nsp.
      lt_vbrp-sdisc = ( gt_zsl_dsales-disa + gt_zsl_dsales-disb +
                      gt_zsl_dsales-disc + gt_zsl_dsales-disd +
                      gt_zsl_dsales-disdc + gt_zsl_dsales-dise +
                      gt_zsl_dsales-disf ).
      lt_vbrp-vdisc = gt_zsl_dsales-disvol.
      lt_vbrp-cdisc = gt_zsl_dsales-cod.
    ELSE.
      lt_vbrp-kwert = gt_zsl_dsales-nsp / ( 111 / 100 ).
      lt_vbrp-sdisc = ( gt_zsl_dsales-disa + gt_zsl_dsales-disb +
                      gt_zsl_dsales-disc + gt_zsl_dsales-disd +
                      gt_zsl_dsales-disdc + gt_zsl_dsales-dise +
                      gt_zsl_dsales-disf ) / ( 111 / 100 ).
      lt_vbrp-vdisc = gt_zsl_dsales-disvol / ( 111 / 100 ).
      lt_vbrp-cdisc = gt_zsl_dsales-cod / ( 111 / 100 ).
    ENDIF.

    lv_diskon = ( lt_vbrp-sdisc + lt_vbrp-vdisc + lt_vbrp-cdisc ).
    lt_vbrp-netwr = lt_vbrp-kwert + lv_diskon.
    lt_vbrp-mwsbp = gt_zsl_dsales-ppn.

    CLEAR lwa_vbrp.
    READ TABLE lt_vbrp WITH KEY vbeln = gt_zsl_dsales-vbeln
                                zuonr = wa_zfvato-zuonr
                                matnr = gt_zsl_dsales-matnr
                       INTO lwa_vbrp.
    IF sy-subrc = 0.
      CLEAR lt_vbrp-kbetr.
    ENDIF.

    COLLECT lt_vbrp. CLEAR lt_vbrp.
  ENDLOOP.

  LOOP AT lt_vbrp WHERE vbeln = wa_zfvato-vbeln.
    gt_of-vkbur       = wa_zfvato-vkbur.
    gt_of-vbeln       = wa_zfvato-vbeln.
    gt_of-of          = 'OF'.
    gt_of-kode_objek  = lt_vbrp-matnr.
    gt_of-nama        = lt_vbrp-arktx.

    PERFORM f_get_hscode USING gt_of-vkbur gt_of-kode_objek
                         CHANGING gt_of-nama.

    lv_diskon = lt_vbrp-sdisc + lt_vbrp-vdisc + lt_vbrp-cdisc.
    lv_diskon = abs( lv_diskon ).

    PERFORM f_add_value USING lt_vbrp-fkimg lt_vbrp-vrkme lt_vbrp-kbetr
                              lt_vbrp-kwert lv_diskon lt_vbrp-netwr lt_vbrp-mwsbp.

    APPEND gt_of.
    CLEAR gt_of.
  ENDLOOP.
ENDFORM.                    " F_LEGACY_8020

*&---------------------------------------------------------------------*
*&      Form  F_LEGACY_8070
*&---------------------------------------------------------------------*
FORM f_legacy_8070 .
  DATA : lv_diskon TYPE mc_umkzwi1,
         lv_kbetr  TYPE p DECIMALS 4.
  DATA : lv_ttldis(19).

  DATA : BEGIN OF lt_vbrp OCCURS 0,
           vbeln TYPE vbeln_vf,
           zuonr TYPE ordnr_v,
           posnr TYPE posnr_vf,
           matnr TYPE matnr,
           arktx TYPE arktx,
           vrkme TYPE vrkme,
           fkimg TYPE fkimg,
           netwr TYPE netwr_fp,
           mwsbp TYPE mwsbp,
           kbetr TYPE kbetr,
           kwert TYPE kwert,
           sdisc TYPE kwert,
           vdisc TYPE kwert,
           cdisc TYPE kwert,
         END OF lt_vbrp.
  DATA : lwa_vbrp LIKE lt_vbrp.

  SORT gt_zsl_dsales BY vbeln matnr.
  LOOP AT gt_zsl_dsales WHERE vbeln = wa_zfvato-zuonr.
    READ TABLE gt_makt WITH KEY matnr = gt_zsl_dsales-matnr.
    IF sy-subrc = 0.
      lt_vbrp-arktx = gt_makt-maktx.
    ENDIF.

    READ TABLE gt_mara WITH KEY matnr = gt_zsl_dsales-matnr.
    IF sy-subrc = 0.
      lt_vbrp-vrkme = gt_mara-meins.
    ENDIF.

    lt_vbrp-vbeln = gt_zsl_dsales-vbeln.
    lt_vbrp-zuonr = wa_zfvato-zuonr.
    lt_vbrp-matnr = gt_zsl_dsales-matnr.
    lt_vbrp-fkimg = gt_zsl_dsales-fkimg.
*    lt_vbrp-kwert = gt_zsl_dsales-nsp / ( 11 / 10 ).

    lt_vbrp-kbetr = lt_vbrp-kwert / lt_vbrp-fkimg.

*    lt_vbrp-sdisc = ( gt_zsl_dsales-disa + gt_zsl_dsales-disb +
*                    gt_zsl_dsales-disc + gt_zsl_dsales-disd +
*                    gt_zsl_dsales-disdc + gt_zsl_dsales-dise +
*                    gt_zsl_dsales-disf ) / ( 11 / 10 ).
*    lt_vbrp-vdisc = gt_zsl_dsales-disvol / ( 11 / 10 ).
*    lt_vbrp-cdisc = gt_zsl_dsales-cod / ( 11 / 10 ).

    IF pa_hscod = 'X'.
      lt_vbrp-kwert = gt_zsl_dsales-nsp.
      lt_vbrp-sdisc = ( gt_zsl_dsales-disa + gt_zsl_dsales-disb +
                      gt_zsl_dsales-disc + gt_zsl_dsales-disd +
                      gt_zsl_dsales-disdc + gt_zsl_dsales-dise +
                      gt_zsl_dsales-disf ).
      lt_vbrp-vdisc = gt_zsl_dsales-disvol.
      lt_vbrp-cdisc = gt_zsl_dsales-cod.
    ELSE.
      lt_vbrp-kwert = gt_zsl_dsales-nsp / ( 111 / 100 ).
      lt_vbrp-sdisc = ( gt_zsl_dsales-disa + gt_zsl_dsales-disb +
                      gt_zsl_dsales-disc + gt_zsl_dsales-disd +
                      gt_zsl_dsales-disdc + gt_zsl_dsales-dise +
                      gt_zsl_dsales-disf ) / ( 111 / 100 ).
      lt_vbrp-vdisc = gt_zsl_dsales-disvol / ( 111 / 100 ).
      lt_vbrp-cdisc = gt_zsl_dsales-cod / ( 111 / 100 ).
    ENDIF.

    lv_diskon = ( lt_vbrp-sdisc + lt_vbrp-vdisc + lt_vbrp-cdisc ).
    lt_vbrp-netwr = lt_vbrp-kwert + lv_diskon.
    lt_vbrp-mwsbp = gt_zsl_dsales-ppn.

    CLEAR lwa_vbrp.
    IF gt_zsl_dsales-nsp IS INITIAL.
      ADD lv_diskon TO lv_ttldis.
      CONTINUE.
    ENDIF.
    READ TABLE lt_vbrp WITH KEY vbeln = gt_zsl_dsales-vbeln
                                zuonr = wa_zfvato-zuonr
                                matnr = gt_zsl_dsales-matnr
                       INTO lwa_vbrp.
    IF sy-subrc = 0.
      CLEAR lt_vbrp-kbetr.
    ENDIF.

    COLLECT lt_vbrp. CLEAR lt_vbrp.
  ENDLOOP.

  PERFORM f_modify_value USING lv_ttldis '' ''
                      CHANGING lv_ttldis.
  gt_diskon-vbeln   = wa_zfvato-vbeln.
  gt_diskon-ttldis  = lv_ttldis.
  APPEND gt_diskon.
  CLEAR gt_diskon.

  CLEAR lv_diskon.
  LOOP AT lt_vbrp WHERE vbeln = wa_zfvato-zuonr.
    gt_of-vkbur       = wa_zfvato-vkbur.
    gt_of-vbeln       = wa_zfvato-vbeln.
    gt_of-of          = 'OF'.
    gt_of-kode_objek  = lt_vbrp-matnr.
    gt_of-nama        = lt_vbrp-arktx.

    PERFORM f_get_hscode USING gt_of-vkbur gt_of-kode_objek
                         CHANGING gt_of-nama.

    lv_diskon = lt_vbrp-sdisc + lt_vbrp-vdisc + lt_vbrp-cdisc.
    lv_diskon = abs( lv_diskon ).

    PERFORM f_add_value USING lt_vbrp-fkimg lt_vbrp-vrkme lt_vbrp-kbetr
                              lt_vbrp-kwert lv_diskon lt_vbrp-netwr lt_vbrp-mwsbp.
    APPEND gt_of.
    CLEAR gt_of.
  ENDLOOP.
ENDFORM.                    " F_LEGACY_8070

*&---------------------------------------------------------------------*
*&      Form  F_COMPARE_HEAD_DETAIL
*&---------------------------------------------------------------------*
FORM f_compare_head_detail .
  DATA : lv_dpp      LIKE gt_of-dpp,
         "         lv_dpp_round TYPE p DECIMALS 2,
         lv_ppn      LIKE gt_of-ppn,
         lv_hargattl LIKE gt_of-harga_total,
         lwa_of      LIKE gt_of,
         lwa_temp    LIKE gt_of,
         lv_selisih  LIKE gt_of-diskon,
         lv_diskon   LIKE gt_of-diskon,
         lv_hargasat TYPE p DECIMALS 2,
         lv_kbetr    TYPE wertv8,
         lv_tabix    TYPE sy-tabix,
         lv_bpjs     TYPE char1,
         lv_ref1     TYPE char10,
         lv_ref2     TYPE char10,
         lv_ref3     TYPE char10,
         lv_ref4     TYPE char10,
         lv_ref5     TYPE char20.

  LOOP AT gt_out.
    CLEAR : lv_dpp, lv_ppn, lwa_of.

    SORT gt_of BY vkbur vbeln diskonv DESCENDING.
    LOOP AT gt_of WHERE vkbur = gt_out-vkbur
                    AND vbeln = gt_out-vbeln.
**      IF gt_out-vtart = 'FI'.
**        "        gt_of-dpp = gt_of-HARGA_TOTAL - gt_of-ppn.
**
**        lv_dpp_round = gt_of-dpp * 11 / 12.
**        gt_of-dpp = gt_of-dpp * 11 / 12.
**        CALL FUNCTION 'ROUND'
**          EXPORTING
**            decimals      = 0
**            input         = lv_dpp_round
**            sign          = '-'
**          IMPORTING
**            output        = lv_dpp_round
**          EXCEPTIONS
**            input_invalid = 1
**            overflow      = 2
**            type_invalid  = 3
**            OTHERS        = 4.
**
**        ADD lv_dpp_round TO lv_dpp.
**      ELSE.
**        ADD gt_of-dpp TO lv_dpp.
**      ENDIF.
      ADD gt_of-dpp TO lv_dpp.
      ADD gt_of-ppn TO lv_ppn.
      IF lwa_of IS INITIAL.
        IF gt_of-diskon <> 0.
          lwa_of  = gt_of.
          DELETE gt_of.
        ENDIF.
      ENDIF.
    ENDLOOP.

    lv_dpp  = gt_out-jumlah_dpp - lv_dpp.
    lv_ppn  = gt_out-jumlah_ppn - lv_ppn.

    IF lwa_of IS INITIAL.
      lwa_of  = gt_of.
      DELETE TABLE gt_of FROM lwa_of.
    ENDIF.

    IF lv_dpp < 0.
      APPEND lwa_of TO gt_of.
      CLEAR lv_tabix.
      SORT gt_of BY vkbur vbeln dppv DESCENDING.
      READ TABLE gt_of INTO lwa_of
                       WITH KEY vkbur = gt_out-vkbur
                                vbeln = gt_out-vbeln.
      IF sy-subrc = 0.
        lv_tabix  = sy-tabix.
      ENDIF.
      DELETE gt_of INDEX lv_tabix.
    ENDIF.

    lwa_of-diskon = lwa_of-diskon - lv_dpp.
    lwa_of-diskon = abs( lwa_of-diskon ).
    lwa_of-dpp    = lwa_of-dpp + lv_dpp.
    lwa_of-ppn    = lwa_of-ppn + lv_ppn.

    SHIFT lwa_of-diskon LEFT DELETING LEADING space.
    SHIFT lwa_of-dpp LEFT DELETING LEADING space.
    SHIFT lwa_of-ppn LEFT DELETING LEADING space.

    lwa_of-vbeln = gt_out-vbeln.
*    lwa_of-zuonr = gt_out-referensi+27(10).
    CLEAR : lv_ref1, lv_ref2, lv_ref3, lv_ref4, lv_ref5.
    SPLIT gt_out-referensi AT space
      INTO lv_ref1 lv_ref2 lv_ref3 lv_ref4 lv_ref5.
    lwa_of-zuonr = lv_ref4.
    lwa_of-zdueyr = gt_out-tahun_pajak.

    APPEND lwa_of TO gt_of.
    CLEAR lwa_of.
  ENDLOOP.

  PERFORM f_koreksi_ppn_hscode.

  "Get data billing & Sales
  PERFORM f_get_billing_sales.

  LOOP AT gt_of.

    "Cek BPJS
    CLEAR: gt_zfvat,gt_vbak,lv_bpjs.
    READ TABLE gt_zfvat WITH KEY vbeln = gt_of-vbeln.
    READ TABLE gt_vbak WITH KEY vbeln = gt_zfvat-vbelv.
    READ TABLE gt_zplbc INTO wa_zplbc INDEX 1.

    IF wa_zplbc-live IS INITIAL.    "Cabang Legacy
      READ TABLE gt_zftypebpjs WITH KEY vkorg = gt_zfvat-vkorg
                                        vkbur = gt_zfvat-vkbur
                                        fkart = gt_zfvat-fkart.
      IF sy-subrc = 0.
        lv_bpjs = 'X'.
      ENDIF.
    ELSE.
      READ TABLE gt_zftypebpjs WITH KEY vkorg = gt_zfvat-vkorg
                                        vkbur = gt_zfvat-vkbur
                                        auart = gt_vbak-auart.
      IF sy-subrc = 0.
        lv_bpjs = 'X'.
      ENDIF.
    ENDIF.

    CLEAR : lv_hargasat, lv_kbetr.
    IF pa_bpjs IS NOT INITIAL OR
       lv_bpjs IS NOT INITIAL.
      gt_of-harga_total = gt_of-dpp.
      CLEAR gt_of-diskon.
    ENDIF.

    lv_hargasat        = gt_of-harga_total / gt_of-jumlah_barang.
*
*    IF pa_bpjs IS INITIAL.
*      CALL FUNCTION 'ROUND'
*        EXPORTING
*          decimals      = 0
*          input         = lv_hargasat
*          sign          = '+'
*        IMPORTING
*          output        = lv_kbetr
*        EXCEPTIONS
*          input_invalid = 1
*          overflow      = 2
*          type_invalid  = 3
*          OTHERS        = 4.
*    ELSE.
    lv_kbetr = lv_hargasat.
*    ENDIF.
*
    PERFORM f_modify_value USING lv_kbetr '' 'X'
                           CHANGING gt_of-harga_satuan.
    SHIFT gt_of-harga_satuan LEFT DELETING LEADING space.

*    lv_hargattl        = gt_of-harga_satuan * gt_of-jumlah_barang.
*    lv_selisih         = lv_hargattl - gt_of-harga_total.
*    gt_of-diskon       = gt_of-diskon + lv_selisih.

    IF pa_bpjs IS NOT INITIAL OR
       lv_bpjs IS NOT INITIAL.
      gt_of-diskon  = 0.
    ENDIF.
    SHIFT gt_of-diskon LEFT DELETING LEADING space.
*    gt_of-harga_total  = lv_hargattl.
    SHIFT gt_of-harga_total LEFT DELETING LEADING space.
    MODIFY gt_of TRANSPORTING harga_satuan diskon harga_total.
    CLEAR : lv_hargattl, lv_selisih.
  ENDLOOP.
ENDFORM.                    " F_COMPARE_HEAD_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_DIFFERENCE_FG
*&---------------------------------------------------------------------*
FORM f_difference_fg .
  DATA : lv_tabix      TYPE sy-tabix,
         lv_diskon     TYPE p DECIMALS 0,
         lv_netwr      TYPE p DECIMALS 0,
         lv_matnr      TYPE matnr,
         lv_upmat(255).

  DATA : lt_vbrp  LIKE gt_vbrp OCCURS 0 WITH HEADER LINE.

  lt_vbrp[] = gt_vbrp[].

  SORT gt_vbrp BY vbeln matnr.   "posnr.
  SORT lt_vbrp BY vbeln matnr.   "posnr.
  LOOP AT gt_out.
    LOOP AT gt_of WHERE vbeln = gt_out-vbeln.
      CLEAR : lv_upmat, lv_matnr, lv_diskon, lv_netwr, lv_tabix.
      lv_matnr  = gt_of-kode_objek.
      LOOP AT gt_vbrp WHERE vbeln = gt_out-vbeln
                        AND matnr = lv_matnr.
        IF gt_vbrp-upmat IS NOT INITIAL.
          IF lv_diskon IS INITIAL.
            lv_diskon = gt_of-diskon / 2.
          ENDIF.
          READ TABLE lt_vbrp WITH KEY vbeln = gt_out-vbeln
                                      matnr = gt_vbrp-upmat.
          IF sy-subrc = 0.
            lv_netwr = lt_vbrp-netwr * 100.
            IF lv_netwr > lv_diskon.
              lv_upmat  = gt_vbrp-upmat.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF lv_upmat IS NOT INITIAL.
        gt_of-diskon = lv_diskon.
        gt_of-dpp    = gt_of-harga_total - gt_of-diskon.
        gt_of-ppn    = gt_of-dpp * ( 11 / 100 ).

        SHIFT gt_of-dpp LEFT DELETING LEADING space.
        SHIFT gt_of-ppn LEFT DELETING LEADING space.
        SHIFT gt_of-diskon LEFT DELETING LEADING space.

        MODIFY gt_of TRANSPORTING dpp ppn diskon.

        READ TABLE gt_of WITH KEY vbeln = gt_out-vbeln
                                  kode_objek = lv_upmat.
        IF sy-subrc = 0.
          lv_tabix     = sy-tabix.
          lv_diskon    = gt_of-diskon + lv_diskon.
          gt_of-diskon = lv_diskon.
          gt_of-dpp    = gt_of-harga_total - gt_of-diskon.
          gt_of-ppn    = gt_of-dpp * ( 11 / 100 ).

          SHIFT gt_of-dpp LEFT DELETING LEADING space.
          SHIFT gt_of-ppn LEFT DELETING LEADING space.
          SHIFT gt_of-diskon LEFT DELETING LEADING space.

          MODIFY gt_of INDEX lv_tabix TRANSPORTING dpp ppn diskon.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

*  LOOP AT gt_out.
*    CLEAR : lv_subrc, lv_tabix, lv_totalfg.
*    LOOP AT gt_of WHERE vbeln = gt_out-vbeln.
*      IF gt_of-dpp = 0.
*        lv_subrc  = 1.
*        ADD gt_of-diskon  TO lv_totalfg.
*      ENDIF.
*      ADD 1 TO lv_tabix.
*    ENDLOOP.
*
*    IF lv_subrc IS NOT INITIAL.
*      LOOP AT gt_of WHERE vbeln = gt_out-vbeln.
*        IF gt_of-dpp = 0.
*          lv_diskon  = lv_totalfg / lv_tabix.
*        ELSE.
*          lv_diskon  = gt_of-diskon + ( lv_totalfg / lv_tabix ).
*        ENDIF.
*
*        IF gt_of-harga_total <= lv_diskon.
*
*        ENDIF.
*
*        gt_of-diskon = lv_diskon.
*        gt_of-dpp    = gt_of-harga_total - gt_of-diskon.
*        gt_of-ppn    = gt_of-dpp * ( 10 / 100 ).
*
*        SHIFT gt_of-dpp LEFT DELETING LEADING space.
*        SHIFT gt_of-ppn LEFT DELETING LEADING space.
*        SHIFT gt_of-diskon LEFT DELETING LEADING space.
*
*        MODIFY gt_of TRANSPORTING dpp ppn diskon.
*      ENDLOOP.
*    ENDIF.
*  ENDLOOP.
ENDFORM.                    " F_DIFFERENCE_FG

*&---------------------------------------------------------------------*
*&      Form  F_GET_BILLING_SALES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_billing_sales .
  IF gt_zftypebpjs[] IS INITIAL.
    SELECT * INTO TABLE gt_zftypebpjs
      FROM zftypebpjs WHERE vkorg EQ pa_bukrs
                        AND vkbur EQ pa_vkbur.

  ENDIF.

*  SELECT a~vbeln fkart vkorg posnr vbelv posnv vgbel vgpos
*         aubel aupos vkbur
*    INTO TABLE gt_vbrk
*    FROM vbrk AS a JOIN vbrp AS b ON b~vbeln EQ a~vbeln
*    FOR ALL ENTRIES IN gt_of
*    WHERE a~vbeln EQ gt_of-vbeln.

  IF gt_of[] IS NOT INITIAL.
    SELECT vkorg vkbur vatno vbeln zuonr dueyr fkart vbelv
      INTO TABLE gt_zfvat FROM zfvato
      FOR ALL ENTRIES IN gt_of
      WHERE vkorg EQ pa_bukrs
        AND vkbur EQ pa_vkbur
        AND vbeln EQ gt_of-vbeln
        AND zuonr EQ gt_of-zuonr
        AND dueyr EQ gt_of-zdueyr.
  ENDIF.

  IF sy-subrc = 0.
*    SORT gt_vbrk BY vbeln.
*    DELETE ADJACENT DUPLICATES FROM gt_vbrk COMPARING vbeln.
    IF gt_zfvat[] IS NOT INITIAL.
      SELECT vbeln auart INTO TABLE gt_vbak
        FROM vbak FOR ALL ENTRIES IN gt_zfvat
        WHERE vbeln EQ gt_zfvat-vbelv.
    ENDIF.

    SORT gt_zfvat BY vbeln.
    SORT gt_vbak BY vbeln.
  ENDIF.
ENDFORM.                    " F_GET_BILLING_SALES

*&---------------------------------------------------------------------*
*&      Form  F_SELECT_FR_SHIPMENT
*&---------------------------------------------------------------------*
FORM f_select_fr_shipment .
  DATA : lt_zfvatshipbtm TYPE STANDARD TABLE OF zfvatshipbtm.

  SELECT *
    FROM zfvatshipbtm
    INTO CORRESPONDING FIELDS OF TABLE gt_zfvatshipbtm
    FOR ALL ENTRIES IN gt_zfvato
    WHERE tknum = gt_zfvato-vbeln.

  lt_zfvatshipbtm[] = gt_zfvatshipbtm[].
  SORT lt_zfvatshipbtm BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_zfvatshipbtm COMPARING matnr.

  IF lt_zfvatshipbtm[] IS NOT INITIAL.
    SELECT makt~matnr maktx
      FROM makt
      INTO TABLE gt_maktship
      FOR ALL ENTRIES IN lt_zfvatshipbtm
      WHERE matnr = lt_zfvatshipbtm-matnr
        AND spras = sy-langu.
  ENDIF.
ENDFORM.                    " F_SELECT_FR_SHIPMENT

*&---------------------------------------------------------------------*
*&      Form  F_DN_WITH_SHIPMENT
*&---------------------------------------------------------------------*
FORM f_dn_with_shipment .
  DATA : lv_hargasat TYPE mc_umkzwi1,
         lv_ppn      TYPE mc_umkzwi1.

  DATA : lt_zfvatshipbtm TYPE STANDARD TABLE OF zfvatshipbtm,
         ls_zfvatshipbtm TYPE zfvatshipbtm.

  DATA : lt_a934 TYPE STANDARD TABLE OF a934 INITIAL SIZE 0,
         lt_konp TYPE STANDARD TABLE OF konp INITIAL SIZE 0.
  DATA : ls_a934 LIKE LINE OF lt_a934,
         ls_konp LIKE LINE OF lt_konp.

  DATA : BEGIN OF lt_marc OCCURS 0,
           matnr TYPE matnr,
           werks TYPE werks_d,
           vkbur TYPE vkbur,
           stawn TYPE stawn,
         END OF lt_marc,

         BEGIN OF lt_mvke OCCURS 0,
           matnr TYPE matnr,
           mvgr5 TYPE mvgr5,
         END OF lt_mvke,

         lt_tmp  TYPE STANDARD TABLE OF zfvatshipbtm,
         ls_mvke LIKE LINE OF lt_mvke.

  CLEAR : lt_zfvatshipbtm[], lt_zfvatshipbtm.

  SORT gt_zfvatshipbtm BY tknum matnr.

  LOOP AT gt_zfvatshipbtm INTO wa_zfvatshipbtm
                          WHERE tknum = wa_zfvato-vbeln.
    ls_zfvatshipbtm-matnr = wa_zfvatshipbtm-matnr.
    ls_zfvatshipbtm-dmbtr = wa_zfvatshipbtm-dmbtr.
    ls_zfvatshipbtm-lfimg = wa_zfvatshipbtm-lfimg.
    ls_zfvatshipbtm-meins = wa_zfvatshipbtm-meins.
    COLLECT ls_zfvatshipbtm INTO lt_zfvatshipbtm.
    CLEAR ls_zfvatshipbtm.
  ENDLOOP.

  lt_tmp[] = lt_zfvatshipbtm[].
  SORT lt_tmp BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_tmp COMPARING matnr.
  IF lt_tmp[] IS NOT INITIAL.
    IF pa_bukrs = '8220'.
      SELECT matnr mvgr5
        INTO TABLE lt_mvke
        FROM mvke
        FOR ALL ENTRIES IN lt_tmp
         WHERE matnr EQ lt_tmp-matnr
         AND vkorg = pa_bukrs
         AND vtweg = '00'
         AND mvgr5 IN ('S01', 'Z99').

      SELECT *
        FROM a934
        INTO CORRESPONDING FIELDS OF TABLE lt_a934
        FOR ALL ENTRIES IN lt_tmp
        WHERE kappl = 'V'
          AND kschl = 'ZHET'
          AND matnr = lt_tmp-matnr.

      IF lt_a934[] IS NOT INITIAL.
        SELECT *
          FROM konp
          INTO CORRESPONDING FIELDS OF TABLE lt_konp
          FOR ALL ENTRIES IN lt_a934
          WHERE knumh = lt_a934-knumh.
      ENDIF.
    ELSE.
      SELECT a~matnr a~werks b~vstel a~stawn
        INTO TABLE lt_marc
        FROM marc AS a JOIN tvkol AS b ON a~werks = b~werks
        FOR ALL ENTRIES IN lt_tmp
        WHERE a~matnr EQ lt_tmp-matnr
          AND b~vstel EQ '0246'.      "Jika 'DN' pasti '0246'
    ENDIF.
  ENDIF.

  LOOP AT lt_zfvatshipbtm INTO ls_zfvatshipbtm.
    gt_of-vkbur  = pa_vkbur.
    gt_of-vbeln  = wa_zfvato-vbeln.
    gt_of-of     = 'OF'.
    gt_of-kode_objek  = ls_zfvatshipbtm-matnr.
    READ TABLE gt_maktship WITH KEY matnr = ls_zfvatshipbtm-matnr.
    IF sy-subrc EQ 0.
      gt_of-nama  = gt_maktship-maktx.
    ENDIF.

    IF pa_bukrs = '8220'.
      READ TABLE lt_mvke INTO ls_mvke
      WITH KEY matnr = ls_zfvatshipbtm-matnr.
      IF sy-subrc = 0.
        CONCATENATE '3305.10.90' gt_of-nama
          INTO gt_of-nama SEPARATED BY ' - '.
      ELSE.
        CONCATENATE '3304.99.90' gt_of-nama
          INTO gt_of-nama SEPARATED BY ' - '.
      ENDIF.

      LOOP AT lt_a934 INTO ls_a934 WHERE matnr = ls_zfvatshipbtm-matnr.
        IF ls_a934-datab <= wa_zfvato-bldat AND
          ls_a934-datbi >= wa_zfvato-bldat.
          READ TABLE lt_konp INTO ls_konp
                             WITH KEY knumh = ls_a934-knumh.
          IF sy-subrc = 0.
            lv_hargasat = ls_zfvatshipbtm-dmbtr / ls_zfvatshipbtm-lfimg.
            lv_ppn      = ( ( ls_konp-kbetr / ls_konp-kpein ) * ls_zfvatshipbtm-lfimg ) - ls_zfvatshipbtm-dmbtr.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSE.
      CLEAR lt_marc.
      READ TABLE lt_marc WITH KEY matnr = ls_zfvatshipbtm-matnr.
*    IF sy-subrc = 0.
      IF lt_marc-stawn IS NOT INITIAL.
        CONCATENATE lt_marc-stawn gt_of-nama
          INTO gt_of-nama SEPARATED BY ' - '.
      ELSE.
        MESSAGE 'Belum Maintain HS Code' TYPE 'I' DISPLAY LIKE 'E'.
        STOP.
      ENDIF.

      lv_hargasat = ls_zfvatshipbtm-dmbtr / ls_zfvatshipbtm-lfimg.
      lv_ppn  = ls_zfvatshipbtm-dmbtr * ( 11 / 100 ).
    ENDIF.

    PERFORM f_add_value USING ls_zfvatshipbtm-lfimg ls_zfvatshipbtm-meins
                              lv_hargasat ls_zfvatshipbtm-dmbtr 0
                              ls_zfvatshipbtm-dmbtr lv_ppn.
    APPEND gt_of.
    CLEAR gt_of.
  ENDLOOP.
ENDFORM.                    " F_DN_WITH_SHIPMENT

*&---------------------------------------------------------------------*
*&      Form  F_DECIMAL_PROCESS
*&---------------------------------------------------------------------*
FORM f_decimal_process .
  DATA : ls_vatdec LIKE LINE OF gt_vatdec.

  DATA: lv_harga_total   TYPE mwsbp,
        lv_jumlah_barang TYPE mwsbp,
        lv_harga_satuan  TYPE dec31_14.

  LOOP AT gt_out.
    CLEAR ls_vatdec.
    READ TABLE gt_vatdec INTO ls_vatdec WITH KEY vkorg = gt_out-vkorg
                                                 kvgr3 = gt_out-kvgr3.
*    IF ls_vatdec-decim IS INITIAL.
*      ls_vatdec-decim = '0'.
*    ENDIF.

    IF gt_out-vtart = 'SD'.
      LOOP AT gt_of WHERE vbeln = gt_out-vbeln.
        CLEAR: lv_harga_total,lv_jumlah_barang,lv_harga_satuan.
        lv_harga_total = gt_of-harga_total.
        lv_jumlah_barang = gt_of-jumlah_barang.
        lv_harga_satuan = lv_harga_total / lv_jumlah_barang.
        WRITE lv_harga_satuan TO gt_of-harga_satuan DECIMALS ls_vatdec-decim.
        REPLACE ALL OCCURRENCES OF '.' IN gt_of-harga_satuan WITH space.
        REPLACE ALL OCCURRENCES OF ',' IN gt_of-harga_satuan WITH '.'.
        CONDENSE gt_of-harga_satuan.
        MODIFY gt_of TRANSPORTING harga_satuan.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_DECIMAL_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_GET_HSCODE
*&---------------------------------------------------------------------*
FORM f_get_hscode  USING    fu_vkbur
                            fu_matnr
                   CHANGING fu_nama.
  DATA: lv_stawn LIKE marc-stawn.

  IF pa_hscod = 'X'.
    SELECT SINGLE stawn INTO lv_stawn
      FROM marc WHERE matnr = fu_matnr
                  AND werks = fu_vkbur.
    IF sy-subrc = 0 AND lv_stawn IS NOT INITIAL.
      CONCATENATE lv_stawn fu_nama
        INTO fu_nama SEPARATED BY ' - '.
    ELSE.
      MESSAGE 'Belum Maintain HS Code' TYPE 'I' DISPLAY LIKE 'E'.
      STOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_HSCODE

*&---------------------------------------------------------------------*
*&      Form  F_KOREKSI_PPN_HSCODE
*&---------------------------------------------------------------------*
FORM f_koreksi_ppn_hscode .
  DATA: lv_ppn     LIKE gt_of-ppn,
        lv_selisih LIKE gt_of-ppn.

  FIELD-SYMBOLS: <fs_of> LIKE gt_of.

  IF pa_hscod = 'X'.
    SORT gt_of BY vkbur vbeln.
    LOOP AT gt_of ASSIGNING <fs_of>.
      AT NEW vbeln.
        CLEAR lv_ppn.
      ENDAT.

*      IF <fs_of>-dpp = '0'.
*        IF <fs_of>-diskon NE '0'.
*          <fs_of>-dpp = <fs_of>-diskon / 2.
*          PERFORM f_modify_value USING <fs_of>-dpp '' 'X'
*                                 CHANGING <fs_of>-dpp.
*          SUBTRACT <fs_of>-dpp FROM <fs_of>-diskon.
*          CONDENSE: <fs_of>-dpp,<fs_of>-diskon.
*        ENDIF.
*      ENDIF.

      <fs_of>-ppn = <fs_of>-dpp * 11 / 100.
      PERFORM f_modify_value USING <fs_of>-ppn '' 'X'
                             CHANGING <fs_of>-ppn.
      CONDENSE <fs_of>-ppn.
      ADD <fs_of>-ppn TO lv_ppn.

      AT END OF vbeln.
        CLEAR: gt_out,lv_selisih.
        READ TABLE gt_out WITH KEY vkbur = <fs_of>-vkbur
                                   vbeln = <fs_of>-vbeln.
        lv_selisih = gt_out-jumlah_ppn - lv_ppn.
        IF lv_selisih IS NOT INITIAL.
          ADD lv_selisih TO <fs_of>-ppn.
          CONDENSE <fs_of>-ppn.
        ENDIF.
      ENDAT.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_KOREKSI_PPN_HSCODE

*&---------------------------------------------------------------------*
*&      Form  F_TAX_CALC
*&---------------------------------------------------------------------*
FORM f_tax_calc  USING    fu_datum fu_wrbtr fu_calty
                 CHANGING fc_wrbtr.
  DATA : lv_wrbtr TYPE  netwr_ak,
         lv_datum TYPE sy-datum.

  lv_wrbtr = fu_wrbtr.
  lv_datum = fu_datum.

  CALL FUNCTION 'Z_PPN11'
    EXPORTING
      pi_wrbtr = lv_wrbtr
      pi_calty = fu_calty
      pi_datum = fu_datum
    IMPORTING
      po_wrbtr = lv_wrbtr.

  fc_wrbtr = lv_wrbtr.
ENDFORM.                    " F_TAX_CALC

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DPP
*&---------------------------------------------------------------------*
FORM f_modify_dpp .
  DATA : lv_dpp      TYPE p DECIMALS 0,
         lv_dppt     TYPE p DECIMALS 0,
         lv_hargasat TYPE p DECIMALS 0,
         lv_hargatot TYPE p DECIMALS 0,
         lv_fkdat    TYPE sy-datum.

  LOOP AT gt_out.
    CONCATENATE gt_out-tanggal_faktur+6(4) gt_out-tanggal_faktur+3(2) gt_out-tanggal_faktur(2)
    INTO lv_fkdat.
    IF lv_fkdat > gs_dpp-datab.
      CASE gt_out-vtart.
        WHEN 'SD'.
          LOOP AT gt_of WHERE vbeln = gt_out-vbeln.
            lv_dpp = gt_of-dpp * 11 / 12.
            ADD lv_dpp TO lv_dppt.
            gt_of-dpp = lv_dpp.
            CONDENSE gt_of-dpp NO-GAPS.
            MODIFY gt_of TRANSPORTING dpp.
          ENDLOOP.

          gt_out-jumlah_dpp = lv_dppt.
          CONDENSE gt_out-jumlah_dpp NO-GAPS.
          MODIFY gt_out TRANSPORTING jumlah_dpp.
          CLEAR lv_dppt.
        WHEN 'FI'.
          LOOP AT gt_of WHERE vbeln = gt_out-vbeln.
            lv_dpp = gt_of-dpp * 11 / 12.
            ADD lv_dpp TO lv_dppt.
            gt_of-dpp = lv_dpp.
            CONDENSE gt_of-dpp NO-GAPS.
            MODIFY gt_of TRANSPORTING dpp.
**            lv_hargasat = gt_of-harga_satuan. " * 12 / 11.
**            lv_hargatot = gt_of-harga_total. " * 12 / 11.
**            gt_of-harga_satuan = lv_hargasat.
**            CONDENSE gt_of-harga_satuan NO-GAPS.
**            gt_of-harga_total  = lv_hargatot.
**            CONDENSE gt_of-harga_total NO-GAPS.
**            MODIFY gt_of TRANSPORTING harga_satuan harga_total dpp.
          ENDLOOP.
          gt_out-jumlah_dpp = lv_dppt.
          CONDENSE gt_out-jumlah_dpp NO-GAPS.
          MODIFY gt_out TRANSPORTING jumlah_dpp.
          CLEAR lv_dppt.
      ENDCASE.
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_ZFVATDTBUYER
*&---------------------------------------------------------------------*
FORM f_write_zfvatdtbuyer .
  DATA: lt_zfvatdtbuyer TYPE STANDARD TABLE OF zfvatdtbuyer.

  IF gt_zfvato[] IS NOT INITIAL.
    DATA(lt_zfvato) = gt_zfvato[].
    SORT lt_zfvato BY kunrg.
    DELETE ADJACENT DUPLICATES FROM lt_zfvato COMPARING kunrg.
    SELECT kunnr, stceg, stcd1, stcd3, stcd5, stcd6, counc, cityc
      FROM kna1 FOR ALL ENTRIES IN @lt_zfvato
      WHERE kunnr = @lt_zfvato-kunrg
      INTO TABLE @DATA(lt_customer).

    LOOP AT gt_zfvato INTO DATA(ls_zfvato).
      APPEND INITIAL LINE TO lt_zfvatdtbuyer ASSIGNING FIELD-SYMBOL(<lt_zfvatdtbuyer>).
      <lt_zfvatdtbuyer>-vkorg   = ls_zfvato-vkorg.
      <lt_zfvatdtbuyer>-vkbur   = ls_zfvato-vkbur.
      <lt_zfvatdtbuyer>-vbeln   = ls_zfvato-vbeln.
      <lt_zfvatdtbuyer>-zuonr   = ls_zfvato-zuonr.
      <lt_zfvatdtbuyer>-dueyr   = ls_zfvato-dueyr.
      <lt_zfvatdtbuyer>-kunrg   = ls_zfvato-kunrg.
      <lt_zfvatdtbuyer>-name_co = ls_zfvato-name_co.
      <lt_zfvatdtbuyer>-stceg   = VALUE #( lt_customer[ kunnr = ls_zfvato-kunrg ]-stceg OPTIONAL ).
      <lt_zfvatdtbuyer>-stcd1   = VALUE #( lt_customer[ kunnr = ls_zfvato-kunrg ]-stcd1 OPTIONAL ).
      <lt_zfvatdtbuyer>-stcd3   = VALUE #( lt_customer[ kunnr = ls_zfvato-kunrg ]-stcd3 OPTIONAL ).
      <lt_zfvatdtbuyer>-stcd5   = VALUE #( lt_customer[ kunnr = ls_zfvato-kunrg ]-stcd5 OPTIONAL ).
      <lt_zfvatdtbuyer>-stcd6   = VALUE #( lt_customer[ kunnr = ls_zfvato-kunrg ]-stcd6 OPTIONAL ).
      <lt_zfvatdtbuyer>-counc   = VALUE #( lt_customer[ kunnr = ls_zfvato-kunrg ]-counc OPTIONAL ).
      <lt_zfvatdtbuyer>-cityc   = VALUE #( lt_customer[ kunnr = ls_zfvato-kunrg ]-cityc OPTIONAL ).
    ENDLOOP.

    IF lt_zfvatdtbuyer IS NOT INITIAL.
      MODIFY zfvatdtbuyer FROM TABLE lt_zfvatdtbuyer.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_ZFVATDTBUYER
*&---------------------------------------------------------------------*
FORM f_delete_zfvatdtbuyer .
  DATA: lt_zfvatdtbuyer_del TYPE STANDARD TABLE OF zfvatdtbuyer.

  IF gt_zfvato[] IS NOT INITIAL.
    DATA(lt_zfvato) = gt_zfvato[].
    SORT lt_zfvato BY vkorg vkbur vbeln zuonr dueyr kunrg.
    DELETE ADJACENT DUPLICATES FROM lt_zfvato COMPARING vkorg vkbur vbeln zuonr dueyr kunrg.
    SELECT *
      FROM zfvatdtbuyer FOR ALL ENTRIES IN @lt_zfvato
      WHERE vkorg = @lt_zfvato-vkorg
        AND vkbur = @lt_zfvato-vkbur
        AND vbeln = @lt_zfvato-vbeln
        AND zuonr = @lt_zfvato-zuonr
        AND dueyr = @lt_zfvato-dueyr
        AND kunrg = @lt_zfvato-kunrg
      INTO TABLE @DATA(lt_zfvatdtbuyer).

    LOOP AT lt_zfvatdtbuyer INTO DATA(ls_zfvatdtbuyer).
      APPEND INITIAL LINE TO lt_zfvatdtbuyer_del ASSIGNING FIELD-SYMBOL(<fs_zfvatdtbuyer_del>).
      MOVE-CORRESPONDING ls_zfvatdtbuyer TO <fs_zfvatdtbuyer_del>.
    ENDLOOP.

    IF lt_zfvatdtbuyer IS NOT INITIAL.
      DELETE zfvatdtbuyer FROM TABLE lt_zfvatdtbuyer_del.
    ENDIF.
  ENDIF.
ENDFORM.
