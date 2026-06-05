*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNR0001F01                                           *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  RANGES : lr_tgl FOR zgdtxdt0012-fakdat.
  DATA   : ld_tgl LIKE sy-datum,
           ld_no  LIKE sy-tabix.
  DATA lw_espt LIKE zgdtxst0014.

  d_index = sy-tabix.

  DATA : BEGIN OF lt_zgdtxdt0012 OCCURS 0,
           brnch    LIKE zgdtxdt0012-brnch,  "added for Tempo
           name     LIKE zgdtxdt0012-name,
           npwp     LIKE zgdtxdt0012-npwp,
           fakturno LIKE zgdtxdt0012-fakturno,
           fakdat   LIKE zgdtxdt0012-fakdat,
           masatx   LIKE zgdtxdt0012-masatx,  "added for MKM
           item     LIKE zgdtxdt0012-item,
           itqty    LIKE zgdtxdt0012-itqty,
           itamt    LIKE zgdtxdt0012-itamt, "TYPE p DECIMALS 2,
           ppnbm    LIKE zgdtxdt0012-ppnbm, "added for Tempo
           belnr    LIKE zgdtxdt0012-belnr,
           budat    LIKE zgdtxdt0012-budat,
           credit   LIKE zgdtxdt0012-credit,
           fakppn   LIKE zgdtxdt0012-fakppn, "TYPE p DECIMALS 2,
           buzei    LIKE zgdtxdt0012-buzei,
           gjahr    LIKE zgdtxdt0012-gjahr,
           waers    LIKE zgdtxdt0012-waers,
           form     LIKE zgdtxdt0012-form,   "added for MKM
           hkont    LIKE zgdtxdt0012-hkont,  "added for Tempo
         END OF lt_zgdtxdt0012.

  DATA: lt_zgdtxdt0012_1 LIKE lt_zgdtxdt0012 OCCURS 0,
        lw_zgdtxdt0012   LIKE lt_zgdtxdt0012.

  DATA : lv_length    TYPE i.

  SELECT brnch name npwp fakturno fakdat masatx item itqty
         itamt ppnbm belnr budat credit fakppn buzei gjahr waers form
         hkont
         INTO CORRESPONDING FIELDS OF TABLE lt_zgdtxdt0012
         FROM zgdtxdt0012
         WHERE bukrs  EQ p_bukrs    AND
               brnch  EQ p_brnch    AND
*               busln  IN s_busln    AND
               masatx EQ p_mtxin    AND
               form   IN s_form.            "added for MKM

  SORT lt_zgdtxdt0012 BY fakturno belnr buzei gjahr.

  IF NOT p_espt IS INITIAL.
    LOOP AT lt_zgdtxdt0012.
      lw_zgdtxdt0012 = lt_zgdtxdt0012.
      COLLECT lw_zgdtxdt0012 INTO lt_zgdtxdt0012_1.
    ENDLOOP.

    REFRESH: lt_zgdtxdt0012.
    CLEAR: lt_zgdtxdt0012.

    lt_zgdtxdt0012[] = lt_zgdtxdt0012_1[].
  ENDIF.

  LOOP AT lt_zgdtxdt0012.
***added by Rahmadi
    CLEAR t_zgdtxdt0012.
***end of addition
*    add 1 to ld_no.
*    t_zGDTXdt0012-no       = ld_no.
    t_zgdtxdt0012-name     = lt_zgdtxdt0012-name.
    t_zgdtxdt0012-npwp     = lt_zgdtxdt0012-npwp.

    lv_length = strlen( lt_zgdtxdt0012-fakturno ).
    IF lv_length  = 17.
      WRITE lt_zgdtxdt0012-fakturno TO t_zgdtxdt0012-fakturno2
      USING EDIT MASK '__.__.__-___.________'.
    ELSE.
      IF p_mtxin(4) GT 2006.
        CONCATENATE lt_zgdtxdt0012-fakturno(3) '.'
                    lt_zgdtxdt0012-fakturno+3(3) '-'
                    lt_zgdtxdt0012-fakturno+6(2) '.'
                    lt_zgdtxdt0012-fakturno+8(8)
        INTO t_zgdtxdt0012-fakturno1.
      ELSE.
        t_zgdtxdt0012-fakturno1 = lt_zgdtxdt0012-fakturno.
      ENDIF.
      t_zgdtxdt0012-fakturno2 = t_zgdtxdt0012-fakturno1.
    ENDIF.

    t_zgdtxdt0012-fakturno = lt_zgdtxdt0012-fakturno.
    t_zgdtxdt0012-fakdat   = lt_zgdtxdt0012-fakdat.
    t_zgdtxdt0012-item     = lt_zgdtxdt0012-item.
    t_zgdtxdt0012-itqty    = lt_zgdtxdt0012-itqty.
*    t_zGDTXdt0012-itamt    = lt_zGDTXdt0012-itamt * 100.
    t_zgdtxdt0012-itamt    = lt_zgdtxdt0012-itamt .
    t_zgdtxdt0012-fakppn    = lt_zgdtxdt0012-fakppn .
    t_zgdtxdt0012-ppnbm    = lt_zgdtxdt0012-ppnbm .
    t_zgdtxdt0012-belnr    = lt_zgdtxdt0012-belnr.
    t_zgdtxdt0012-budat    = lt_zgdtxdt0012-budat.
    t_zgdtxdt0012-form     = lt_zgdtxdt0012-form.
    t_zgdtxdt0012-credit   = lt_zgdtxdt0012-credit.
    t_zgdtxdt0012-masatx   = lt_zgdtxdt0012-masatx.

****added by Rahmadi
    t_zgdtxdt0012-waers = lt_zgdtxdt0012-waers.
****end of addition

*    CLEAR lt_zGDTXdt0012.
    READ TABLE lt_zgdtxdt0012
               WITH KEY fakturno = lt_zgdtxdt0012-fakturno
                        belnr    = lt_zgdtxdt0012-belnr  "by rahmadi
                        buzei    = lt_zgdtxdt0012-buzei  "by rahmadi
                        gjahr    = lt_zgdtxdt0012-gjahr  "by rahmadi
               BINARY SEARCH.

    IF sy-subrc = 0 AND
     ( lt_zgdtxdt0012-credit = 'C' OR lt_zgdtxdt0012-credit = 'R' ).
*      t_zGDTXdt0012-fakppnc = lt_zGDTXdt0012-fakppn * 100.
      t_zgdtxdt0012-fakppnc = lt_zgdtxdt0012-fakppn .
      CLEAR t_zgdtxdt0012-fakppnd. "by rahmadi
    ELSEIF sy-subrc = 0 AND lt_zgdtxdt0012-credit = 'D' .
*      t_zGDTXdt0012-fakppnd = lt_zGDTXdt0012-fakppn * 100.
      t_zgdtxdt0012-fakppnd = lt_zgdtxdt0012-fakppn.
      CLEAR t_zgdtxdt0012-fakppnc. "by rahmadi
    ELSEIF sy-subrc = 0 AND lt_zgdtxdt0012-credit = 'B'.
*      t_zGDTXdt0012-fakppnd = lt_zGDTXdt0012-fakppn * 100.
      t_zgdtxdt0012-fakppnd = lt_zgdtxdt0012-fakppn .
      CLEAR t_zgdtxdt0012-fakppnc. "by rahmadi
    ENDIF.

***added for Tempo -- for eSPT download
    t_zgdtxdt0012-brnch   = lt_zgdtxdt0012-brnch.
    t_zgdtxdt0012-hkont   = lt_zgdtxdt0012-hkont.

*---Koreksi for Tempo
    t_zgdtxdt0012-corrno  = p_korek.

    IF NOT p_espt IS INITIAL.
      CLEAR lw_espt.
      IF p_mtxin(4) GT 2006.
        CALL FUNCTION 'Z_GDTXFC_FORMAT_TO_ESPT1'
          EXPORTING
            fi_vat_type                   = 'I'
            fi_zgdtxst0012                = t_zgdtxdt0012
*           FI_ZGDTXST0013                =
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
            fi_vat_type                   = 'I'
            fi_zgdtxst0012                = t_zgdtxdt0012
*           FI_ZGDTXST0013                =
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
        CASE sy-subrc.
          WHEN 1.
            MESSAGE i000(zab) WITH 'Failed to get Kode Lampiran'.
            STOP.
          WHEN 2.
            MESSAGE i000(zab) WITH 'Failed to get Kode Status'.
            STOP.
          WHEN 3.
            MESSAGE i000(zab) WITH 'Failed to get Kode Dokumen'.
            STOP.
          WHEN 4.
            MESSAGE i000(zab) WITH 'NPWP is blank'.
            STOP.
          WHEN 5.
            MESSAGE i000(zab) WITH 'Name field is blank'.
            STOP.
          WHEN 7.
            MESSAGE i000(zab) WITH 'VAT-in structure is blank'.
            STOP.
        ENDCASE.
      ELSE.
        MOVE-CORRESPONDING lw_espt TO t_zgdtxdt0012.
      ENDIF.
    ENDIF.
***end of Tempo addition

    APPEND t_zgdtxdt0012.
  ENDLOOP.

*-----Tempo: Add logic to insert manually input data (B4) to ESPT
  IF NOT p_espt IS INITIAL.
    SELECT * INTO TABLE t_zgdtxdt0024
             FROM zgdtxdt0024
             WHERE bukrs = p_bukrs AND
                   brnch = p_brnch AND
                   masatx = p_mtxin.
    IF sy-subrc = 0.
      CLEAR lw_espt.
      LOOP AT t_zgdtxdt0024.
        PERFORM f_fill_manual_to_espt USING t_zgdtxdt0024
                                      CHANGING lw_espt.
        MOVE-CORRESPONDING lw_espt TO t_zgdtxdt0012.
        APPEND t_zgdtxdt0012.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----end of Tempo insertion


  CLEAR d_index.

ENDFORM.                                                   "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM f_write_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_write_data.

  PERFORM f_build_fieldcat_har   USING   t_fieldcat[].
  PERFORM f_build_layout_har     USING   d_layout.
  PERFORM f_build_sortfield_har  USING   t_sort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_event_har      TABLES  t_events[].
  PERFORM f_build_print          USING   d_print.
  IF p_espt IS INITIAL.
    PERFORM f_alv_variant_exist USING   p_vari
                                        d_variant.
  ENDIF.

  d_repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS '
      i_callback_user_command  = 'F_USER_COMMAND'
*     I_STRUCTURE_NAME         =
      is_layout                = d_layout
      it_fieldcat              = t_fieldcat[]
      it_sort                  = t_sort[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_variant
      it_events                = t_events[]
      it_event_exit            = t_event_exit[]
      is_print                 = d_print
      i_screen_start_column    = 0
      i_screen_start_line      = 0
      i_screen_end_column      = 0
      i_screen_end_line        = 0
    TABLES
      t_outtab                 = t_zgdtxdt0012
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

ENDFORM.                                                 "F_WRITE_DATA

*---------------------------------------------------------------------*
*       FORM f_build_fieldcat_har                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  fu_fieldcat                                                   *
*---------------------------------------------------------------------*
FORM f_build_fieldcat_har USING fu_fieldcat TYPE slis_t_fieldcat_alv.

  IF p_espt IS INITIAL.
    PERFORM f_fieldcat USING  fu_fieldcat :
***added by Rahmadi for MKM 03/03/2004
     'FORM'     '' '' 4 'X' 'Form' 'Form' 'Form'
                'Form' '' '' 'L' '' '' '' '' '',
     'CREDIT'   '' '' 6 'X' 'Credit' 'Credit' 'Crd'
                'Credit' '' '' 'L' '' '' '' '' '',
     'MASATX'   '' '' 12 'X' 'Tax Period' 'Tax Period' 'Tax Per'
                'Tax Period' '' '' 'L' '' '' '' '' '',
***end of addition
     'NO'       '' '' 05 'X' 'No.' 'No.' 'No.'
                'No.'   ''   ''   'L' 'X' '' '' '' '',
     'NAME'     '' '' 25 'X' 'Nama Penjual' 'Penjual' 'NPenj'
                'Nama Penjual'   ' '   ' '   'L' 'X' '' '' '' '',
     'NPWP'     '' '' 16 'X' 'NPWP' 'NPWP' 'NPWP' 'NPWP'   ' '
                ' '  'L' 'X' '' '' '' '',
     'FAKTURNO2' '' '' 22 'X' 'Np. Seri FP' 'Np. FP' 'FP'
                'No. FP'   '' ''  'L' 'X' '' '' '' '',
     'FAKDAT'   '' '' 10 ' ' 'Tanggal FP' 'Tgl. FP' 'Tgl. FP'
                'Tgl. FP'  ' '  ' '  'L' '' '' '' '' '',
     'ITEM'     '' '' 12 'X' 'Nama Barang' 'Nama Brg' 'Brg'
                'Nama Barang' '' '' 'L' '' '' '' '' '',
     'ITQTY'    '' '' 10 '' 'Quantity' 'Quantity' 'Qty'
                'Qty'  'QUANT'  'X'  'R' '' '' '' '' '',
     'ITAMT'    'ITAMT' 'ZGDTXdt0012' 22 '' 'DPP' 'DPP' 'DPP'
                'DPP'  ''  'X'  'R' '' '' '' 'WAERS' '',
     'FAKPPNC'  'ITAMT' 'ZGDTXdt0012' 22 '' 'PPN Dikreditkan'
               'PPN Dikredit' 'PPN Kredit' 'PPN Kredit' ''
               'X' 'R' '' '' '' 'WAERS' '',
     'FAKPPND'  'ITAMT' 'ZGDTXdt0012' 22 '' 'PPN Tidak Dikreditkan'
               'PPN Tdk Dikredit' 'PPN Tdk Kre' 'PPN Tdk Dikreditkan'
               '' 'X' 'R' '' '' '' 'WAERS' '',
     'WAERS'    'WAERS' 'ZGDTXDT0012' 10 '' 'Currency' 'Crncy' 'Cur.'
                'Cur'  ''  ''  'L'  '' 'X' '' '' '',
     'BELNR'    '' '' 10 'X' 'Nomor SAP' 'No. SAP' 'SAP'
                'No. SAP'  ''  ''  'L'  '' 'X' '' '' '',
     'BUDAT'    '' '' 14 'X' 'Keterangan' 'Ketr.'  'Ket.'
                'Keterangan'  ''  ''  'L' '' '' '' '' ''.
  ELSE.
****added for Tempo --- eSPT download
    IF p_mtxin(4) GT 2006.
      PERFORM f_fieldcat USING  fu_fieldcat :
      'KODEPAJAK' 'ZGDTXST0014' 'KODEPAJAK' 11 'X' 'Kode Pajak' 'Kd Pjk'
              'Kdp.' 'Kode Pajak'  ''  ''  'L' '' '' '' '' '',
      'KODELAMP' 'ZGDTXST0014' 'KODELAMP' 14 'X' 'Kode Lampiran'
      'Kd Lmp' 'Kdl.' 'Kode Lamp.'  ''  ''  'L' '' '' '' '' '',
      'KODESTAT' 'ZGDTXST0014' 'KODESTAT' 11 'X' 'Kode Status' 'Kd Sts'
              'Kds.' 'Kode Stat.'  ''  ''  'L' '' '' '' '' '',
      'KODEDOK'  'ZGDTXST0014' 'KODEDOK' 14 'X' 'Kode Dokumen' 'Kd Dok'
              'Kdd.' 'Kode Doku.'  ''  ''  'L' '' '' '' '' '',
      'KODENPWP' 'ZGDTXST0014' 'KODENPWP' 16 'X' 'NPWP' 'NPWP'  'NPWP'
              'NPWP'  ''  ''  'L' '' '' '' '' '',
      'KODENAMA' 'ZGDTXST0014' 'KODENAMA' 50 'X' 'Nama' 'Nama'  'Nama'
              'Nama'  ''  ''  'L' '' '' '' '' '',
      'KODECABANG' 'ZGDTXST0014' 'KODECABANG' 12 'X' 'Kode Cabang'
      'Kd Cbg' 'Kdc.' 'Kode Cabang'  ''  ''  'L' '' '' '' '' '',
      'KODESERI' 'ZGDTXST0014' 'KODESERI' 14 'X' 'No Seri Faktur'
            'No Seri' 'No Seri' 'No Seri'  ''  ''  'L' '' '' '' '' '',
      'KODETGL'  'ZGDTXST0014' 'KODETGL' 11 'X' 'Tgl Faktur' 'Tgl FP'
              'Tgl FP' 'Tgl FP'  ''  ''  'L' '' '' '' '' '',
      'TGLSSP'  'ZGDTXST0014' 'TGLSSP' 11 'X' 'Tgl SSP' 'Tgl SSP'
              'Tgl SSP' 'Tgl SSP'  ''  ''  'L' '' '' '' '' '',
      'KODEMSTX' 'ZGDTXST0014' 'KODEMSTX' 10 'X' 'Ms Pjk Bln' 'Ms Pj Bl'
              'Ms Pj Bl' 'Ms Pj Bl'  ''  ''  'L' '' '' '' '' '',
      'KODETHN'  'ZGDTXST0014' 'KODETHN' 10 'X' 'Ms Pjk Thn' 'Ms Pj Th'
              'Ms Pj Th' 'Ms Pj Th'  ''  ''  'L' '' '' '' '' '',
      'KOREKSI'  'ZGDTXST0014' 'KOREKSI' 10 'X' 'Pembetulan' 'Pbtln'
              'Pbtln' 'Pbtln'  ''  ''  'L' '' '' '' '' '',
      'NILBILL'  'ZGDTXST0014' 'NILBILL' 15 'X' 'DPP PPN'
           'DPP PPN' 'DPP PPN' 'DPP PPN'  ''  ''  'L' '' '' '' '' '',
      'NILPPN' 'ZGDTXST0012' 'NILPPN' 15 'X' 'PPN' 'PPN'
              'PPN' 'PPN'  ''  ''  'L' '' '' '' '' '',
      'NILPPNBM' 'ZGDTXST0014' 'NILPPNBM' 15 'X' 'Tarif PPnBM'
        'Tr PPnBM' 'Tr PPnBM' 'Tr PPnBM'  ''  ''  'L' '' '' '' '' ''.
    ELSE.
      PERFORM f_fieldcat USING  fu_fieldcat :
        'KODELAMP' 'ZGDTXST0014' 'KODELAMP' 14 'X' 'Kode Lampiran'
        'Kd Lmp' 'Kdl.' 'Kode Lamp.'  ''  ''  'L' '' '' '' '' '',
        'KODESTAT' 'ZGDTXST0014' 'KODESTAT' 11 'X' 'Kode Status'
        'Kd Sts' 'Kds.' 'Kode Stat.'  ''  ''  'L' '' '' '' '' '',
        'KODEDOK' 'ZGDTXST0014' 'KODEDOK' 14 'X' 'Kode Dokumen'
        'Kd Dok' 'Kdd.' 'Kode Doku.'  ''  ''  'L' '' '' '' '' '',
        'KODENPWP' 'ZGDTXST0014' 'KODENPWP' 14 'X' 'NPWP' 'NPWP'  'NPWP'
                   'NPWP'  ''  ''  'L' '' '' '' '' '',
        'KODENAMA' 'ZGDTXST0014' 'KODENAMA' 50 'X' 'Nama' 'Nama'  'Nama'
                   'Nama'  ''  ''  'L' '' '' '' '' '',
        'KODEPRFP' 'ZGDTXST0014' 'KODEPRFP' 11 'X' 'Kode Faktur' 'Kd FP'
                   'Kd FP' 'Kode FP'  ''  ''  'L' '' '' '' '' '',
        'KODENORET' 'ZGDTXST0014' 'KODENORET' 14 'X' 'No Ref Faktur'
                 'No Ref' 'No Ref' 'No Ref'  ''  ''  'L' '' '' '' '' '',
        'KODENOFP' 'ZGDTXST0014' 'KODENOFP' 14 'X' 'No Seri Faktur'
              'No Seri' 'No Seri' 'No Seri'  ''  ''  'L' '' '' '' '' '',
        'KODETGL'  'ZGDTXST0014' 'KODETGL' 11 'X' 'Tgl Faktur' 'Tgl FP'
                  'Tgl FP' 'Tgl FP'  ''  ''  'L' '' '' '' '' '',
        'KODEMSTX' 'ZGDTXST0014' 'KODEMSTX' 10 'X' 'Ms Pjk Bln'
          'Ms Pj Bl' 'Ms Pj Bl' 'Ms Pj Bl'  ''  ''  'L' '' '' '' '' '',
        'KODETHN'  'ZGDTXST0014' 'KODETHN' 10 'X' 'Ms Pjk Thn'
        'Ms Pj Th' 'Ms Pj Th' 'Ms Pj Th'  ''  ''  'L' '' '' '' '' '',
        'KOREKSI'  'ZGDTXST0014' 'KOREKSI' 10 'X' 'Pembetulan' 'Pbtln'
                   'Pbtln' 'Pbtln'  ''  ''  'L' '' '' '' '' '',
        'PPNTARIF' 'ZGDTXST0014' 'PPNTARIF' 15 'X' 'Tarif PPN' 'Tr PPN'
                   'Tr PPN' 'Tr PPN'  ''  ''  'L' '' '' '' '' '',
        'NILBILL'  'ZGDTXST0014' 'NILBILL' 15 'X' 'Nilai Perolehan'
             'Nil Prl' 'Nil Prl' 'Nil Prl'  ''  ''  'L' '' '' '' '' '',
        'NILPPNBM' 'ZGDTXST0014' 'NILPPNBM' 15 'X' 'Tarif PPnBM'
           'Tr PPnBM' 'Tr PPnBM' 'Tr PPnBM'  ''  ''  'L' '' '' '' '' ''.
****end of Tempo addition
    ENDIF.
  ENDIF.

ENDFORM.                                           "F_BUILD_FIELDCAT_HAR

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT_HAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_D_LAYOUT  text
*----------------------------------------------------------------------*
FORM f_build_layout_har USING fu_layout TYPE slis_layout_alv.

  fu_layout-f2code             = 'F2'.
  fu_layout-zebra              = 'X'.
  fu_layout-no_subtotals       = ''.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-totals_text        = 'Sum'.
  fu_layout-key_hotspot        = 'X'.
*  fu_layout-no_totalline       = ''.
*  fu_layout-subtotals_text     = 'Sub Total'.

ENDFORM.                                            " F_BUILD_LAYOUT_HAR

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTFIELD_HAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_SORT[]  text
*----------------------------------------------------------------------*
FORM f_build_sortfield_har USING fu_sort TYPE slis_t_sortinfo_alv.

  DATA: ld_sort TYPE slis_sortinfo_alv.

  IF p_espt IS INITIAL.
    CLEAR ld_sort.
    ld_sort-fieldname = 'NAME'.
*  ld_sort-spos      = 1.
    ld_sort-up        = 'X'.
    ld_sort-subtot    = 'X'.
    ld_sort-group     = 'UL'.


    APPEND ld_sort TO fu_sort.
  ENDIF.

ENDFORM.                                        " F_BUILD_SORTFIELD_HAR

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT_HAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_EVENTS[]  text
*----------------------------------------------------------------------*
FORM f_build_event_har TABLES ft_events LIKE t_events.

  IF p_espt IS INITIAL.
    CLEAR ft_events.
    ft_events-name = slis_ev_top_of_page.
    ft_events-form = 'F_HEADER_ITAB'.
    APPEND ft_events.

    CLEAR ft_events.
    ft_events-name = slis_ev_subtotal_text .
    ft_events-form = 'F_SUBTOT'.
    APPEND ft_events.
  ENDIF.

ENDFORM.                                           " F_BUILD_EVENT_HAR

*---------------------------------------------------------------------*
*       FORM f_header_itab                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_header_itab.

  DATA : BEGIN OF lt_zgdtxdt0101 OCCURS 0,
           bdesc LIKE zgdtxdt0101-bdesc,
         END OF lt_zgdtxdt0101.

  DATA : ld_office(8) TYPE c,
         ld_no        LIKE sy-tabix.

  SELECT bdesc
         FROM zgdtxdt0101
         INTO TABLE lt_zgdtxdt0101
         WHERE brnch = p_brnch.

  READ TABLE lt_zgdtxdt0101.

  LOOP AT t_zgdtxdt0012.
    ADD 1 TO ld_no.
    t_zgdtxdt0012-no = ld_no.
    MODIFY t_zgdtxdt0012 INDEX sy-tabix TRANSPORTING no.
  ENDLOOP.

  WRITE : 'Nama Cabang   : ', lt_zgdtxdt0101-bdesc.
*        / 'Business line : ', s_busln.
  SKIP 1.
  WRITE : / 'Buku Pembelian / Import',
          / '* Masa Pajak : ',
             p_mtxin+0(4) NO-GAP,
             '.' NO-GAP,
             p_mtxin+4(2) NO-GAP.
  SKIP 1.

ENDFORM.                                                " F_HEADER_ITAB

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  fu_print                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos = ''.
ENDFORM.                                                " F_BUILD_PRINT

*---------------------------------------------------------------------*
*       FORM F_SUBTOT                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_subtot USING fu_text
                    fu_subtot TYPE slis_subtot_text.

  fu_subtot-display_text_for_subtotal = 'Total'.

ENDFORM.                    "f_subtot


*&---------------------------------------------------------------------*
*&      Form  F_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fieldcat USING fu_fieldcat TYPE slis_t_fieldcat_alv
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
                      fu_input.

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
  APPEND lt_fieldcat TO fu_fieldcat.

ENDFORM.                                                  " F_FIELDCAT


*---------------------------------------------------------------------*
*       FORM f_User_Command                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  fu_ucomm                                                      *
*  -->  fu_selfield                                                   *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm    LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  CASE fu_ucomm.
    WHEN 'F2'.
      IF fu_selfield-fieldname = 'BELNR'.
        SET PARAMETER ID 'BLN' FIELD fu_selfield-value.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.
*    WHEN '&RNT'.
*      PERFORM f_config_printer.

  ENDCASE.

ENDFORM.                    "f_user_command


*---------------------------------------------------------------------*
*       FORM f_select_period                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_select_period.

*  LOOP AT SCREEN.
*    IF screen-name CS 'S_MDATIN'.
*      screen-active = 0.
*    ELSE.
*      screen-active = 1.
*    ENDIF.
*
*    IF p_masatx = 'X'.
*      IF screen-name CS 'S_MDATIN'.
*        screen-active = 0.
*      ELSE.
*        screen-active = 1.
*      ENDIF.
*    ELSEIF p_budat = 'X'.
*      IF screen-name CS 'P_MTXIN'.
*        screen-active = 0.
*      ELSE.
*        screen-active = 1.
*      ENDIF.
*    ENDIF.
*
*    MODIFY SCREEN.
*  ENDLOOP.

ENDFORM.                    "f_select_period

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_event_exit.
  t_event_exit-ucomm = '&RNT'. "print
  t_event_exit-after = 'X'.
  APPEND t_event_exit.
  CLEAR t_event_exit.
ENDFORM.                    " F_BUILD_EVENT_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_SET_PF_STATUS
*&---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD' .
ENDFORM.                                               " F_SET_PF_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_alv_variant_exist USING     fu_vari
                         CHANGING  fc_alv_variant STRUCTURE disvariant.

  IF NOT fu_vari IS INITIAL.
    MOVE fu_vari TO fc_alv_variant-variant.
    fc_alv_variant-report = sy-repid.
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
*&      Form  f_fill_manual_to_espt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_fill_manual_to_espt USING fu_zgdtxdt0024 STRUCTURE zgdtxdt0024
                           CHANGING fc_espt STRUCTURE zgdtxst0014.

  DATA ld_fakdpp LIKE zgdtxdt0024-fakdpp.

*-----Column 1
  CASE fu_zgdtxdt0024-zstatus(1).
    WHEN '6'.
      fc_espt-kodelamp = '7'.   "B4

*-------Column 2
*-------Masa pajak sama
      IF fu_zgdtxdt0024-masatx = fu_zgdtxdt0024-fakdat+(6).
        fc_espt-kodestat = '1'.
*-------Masa pajak beda
      ELSE.
        fc_espt-kodestat = '2'.
      ENDIF.

*-------------Column 3
      IF fu_zgdtxdt0024-fakturno IS INITIAL.
        fc_espt-kodedok = '1'.
      ELSE.
        fc_espt-kodedok = '2'.
*-------------Column 6
        fc_espt-kodeprfp = fu_zgdtxdt0024-fakturno+(9).
*-------------Column 8
        fc_espt-kodenofp = fu_zgdtxdt0024-fakturno+10(7).
      ENDIF.

*-----Column 4
      IF fu_zgdtxdt0024-stceg IS INITIAL.
        fc_espt-kodenpwp = '000000000000000'.
      ELSE.
        CALL FUNCTION 'ZF_NPWP_MODIFICATION'
          EXPORTING
            npwp_in  = fu_zgdtxdt0024-stceg
          IMPORTING
            npwp_out = fc_espt-kodenpwp.
      ENDIF.

*-----Column 5
      fc_espt-kodenama = fu_zgdtxdt0024-name.

**-----Column 7
*  IF fi_zgdtxst0012-credit = 'R'.   "nota retur
*    fe_espt-kodenoret = fi_zgdtxst0012-belnr.
*  ELSE.
*    CLEAR fe_espt-kodenoret.
*  ENDIF.

*-----Column 9
      CONCATENATE fu_zgdtxdt0024-fakdat+6(2)
                  fu_zgdtxdt0024-fakdat+4(2)
                  fu_zgdtxdt0024-fakdat+(4)
                  INTO fc_espt-kodetgl
                  SEPARATED BY '/'.

*-----Column 10
      fc_espt-kodemstx = fu_zgdtxdt0024-masatx+4(2).

*-----Column 11
      fc_espt-kodethn = fu_zgdtxdt0024-masatx+(4).

*-----Column 12
      fc_espt-koreksi = p_korek.

*-----Column 13
      CALL FUNCTION 'Z_PPN11'
        EXPORTING
          pi_calty = 'TEXT'
          pi_mastx = p_mtxin
        IMPORTING
          po_ppntx = fc_espt-ppntarif.

*      fc_espt-ppntarif = '10/100'.

*-----Column 14
      IF fu_zgdtxdt0024-shkzg = 'C'.
        ld_fakdpp = ( -1 ) * fu_zgdtxdt0024-fakdpp.
      ELSE.
        ld_fakdpp = fu_zgdtxdt0024-fakdpp.
      ENDIF.
      WRITE ld_fakdpp CURRENCY fu_zgdtxdt0024-waers
            TO fc_espt-nilbill NO-GROUPING.

* Add by Budi 22/02/2011
      fc_espt-flagvat = '0'.
      fc_espt-npwp255 = fc_espt-kodenpwp.
      fc_espt-nodok = fu_zgdtxdt0024-fakturno.
      fc_espt-jenisdok = '1'.
*    fc_espt-fakturganti = ' '.
*    fc_espt-jenisganti = ' '.
      CONCATENATE fc_espt-kodemstx fc_espt-kodemstx INTO fc_espt-masapjk.
      fc_espt-pembetulan = fc_espt-koreksi.
* End Add by Budi 22/02/2011

  ENDCASE.

ENDFORM.                    " f_fill_manual_to_espt

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
  IF p_mtxin(4) GT 2006.
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

  LOOP AT t_zgdtxdt0012.
    IF ld_count EQ 0.
      ld_count = 1.
      t_download-data = space.
      APPEND t_download.
    ENDIF.

    CONCATENATE t_zgdtxdt0012-kodepajak t_zgdtxdt0012-kodelamp
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-kodestat
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-kodedok
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-kodenpwp
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-kodenama
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-kodecabang
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-kodethn+2(2)
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-kodeseri
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-kodetgl
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-tglssp
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-kodemstx
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-kodethn
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-koreksi
    INTO t_download-data
    SEPARATED BY ';'.
    SHIFT t_zgdtxdt0012-nilbill LEFT DELETING LEADING space.
    CONCATENATE t_download-data t_zgdtxdt0012-nilbill
    INTO t_download-data
    SEPARATED BY ';'.
    SHIFT t_zgdtxdt0012-nilppn LEFT DELETING LEADING space.
    CONCATENATE t_download-data t_zgdtxdt0012-nilppn
    INTO t_download-data
    SEPARATED BY ';'.
    SHIFT t_zgdtxdt0012-nilppnbm LEFT DELETING LEADING space.
    CONCATENATE t_download-data t_zgdtxdt0012-nilppnbm
    INTO t_download-data
    SEPARATED BY ';'.
    APPEND t_download.

*    t_download-kodepajak  = t_zgdtxdt0012-kodepajak.
*    t_download-kodelamp   = t_zgdtxdt0012-kodelamp.
*    t_download-kodestat   = t_zgdtxdt0012-kodestat.
*    t_download-kodedok    = t_zgdtxdt0012-kodedok.
*    t_download-kodenpwp   = t_zgdtxdt0012-kodenpwp.
*    t_download-kodenama   = t_zgdtxdt0012-kodenama.
*    t_download-kodecabang = t_zgdtxdt0012-kodecabang.
*    t_download-kodeseri   = t_zgdtxdt0012-kodeseri.
*    t_download-kodetgl    = t_zgdtxdt0012-kodetgl.
*    t_download-tglssp     = t_zgdtxdt0012-tglssp.
*    t_download-kodemstx   = t_zgdtxdt0012-kodemstx.
*    t_download-kodethn    = t_zgdtxdt0012-kodethn.
*    t_download-koreksi    = t_zgdtxdt0012-koreksi.
*    t_download-nilbill    = t_zgdtxdt0012-nilbill.
*    t_download-nilppn     = t_zgdtxdt0012-nilppn.
*    t_download-nilppnbm   = t_zgdtxdt0012-nilppnbm.
*    COLLECT t_download.
  ENDLOOP.

*  CONCATENATE 'C:\eSPT_B' p_mtxin '.TXT'
  CONCATENATE 'C:\ZGDTXR0001\eSPT_B' p_mtxin '.CSV'
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

  LOOP AT t_zgdtxdt0012.
    IF ld_count EQ 0.
      ld_count = 1.
      t_download-data = space.
      APPEND t_download.
    ENDIF.

    CONCATENATE t_zgdtxdt0012-kodepajak t_zgdtxdt0012-kodelamp
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-kodestat
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-kodedok
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-flagvat
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-npwp255
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-kodenama
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-nodok
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-jenisdok
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-fakturganti
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-jenisganti
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-kodetgl
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-tglssp
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-masapjk
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-kodethn
    INTO t_download-data
    SEPARATED BY ';'.
    CONCATENATE t_download-data t_zgdtxdt0012-pembetulan
    INTO t_download-data
    SEPARATED BY ';'.
    SHIFT t_zgdtxdt0012-nilbill LEFT DELETING LEADING space.
    CONCATENATE t_download-data t_zgdtxdt0012-nilbill
    INTO t_download-data
    SEPARATED BY ';'.
    SHIFT t_zgdtxdt0012-nilppn LEFT DELETING LEADING space.
    CONCATENATE t_download-data t_zgdtxdt0012-nilppn
    INTO t_download-data
    SEPARATED BY ';'.
    SHIFT t_zgdtxdt0012-nilppnbm LEFT DELETING LEADING space.
    CONCATENATE t_download-data t_zgdtxdt0012-nilppnbm
    INTO t_download-data
    SEPARATED BY ';'.
    APPEND t_download.

  ENDLOOP.

*  CONCATENATE 'C:\eSPT_B' p_mtxin '.TXT'
  CONCATENATE 'C:\ZGDTXR0001\eSPT_B' p_mtxin '.CSV'
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
ENDFORM.                    " f_download11
