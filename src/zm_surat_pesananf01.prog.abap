*----------------------------------------------------------------------*
*   INCLUDE ZM_SURAT_PESANANF01
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_process_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_report.
  PERFORM f_init_data.
  PERFORM f_get_data.

  CHECK gs_header-repti IS NOT INITIAL.

  PERFORM f_validate_data.
  PERFORM f_process_data.
  PERFORM f_print_form.
  PERFORM f_free_memory.
ENDFORM.                    " f_process_report
*&---------------------------------------------------------------------*
*&      Form  f_init_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data.
  SELECT *
    FROM zmpsiko
    INTO CORRESPONDING FIELDS OF TABLE gt_zmpsiko.

  SELECT *
    FROM zmpsiko1
    INTO CORRESPONDING FIELDS OF TABLE gt_zmpsiko1.
ENDFORM.                    " f_init_data
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA : is_dlv_data_control TYPE bapidlvbuffercontrol,
         it_vbeln            TYPE STANDARD TABLE OF bapidlv_range_vbeln,
         et_delivery_header  TYPE STANDARD TABLE OF bapidlvhdr,
         et_delivery_item    TYPE STANDARD TABLE OF bapidlvitem,
         return              TYPE STANDARD TABLE OF bapiret2,
         month_names         TYPE STANDARD TABLE OF t247.

  DATA : lt_item    TYPE STANDARD TABLE OF bapidlvitem.
  DATA : BEGIN OF lt_mara OCCURS 0,
           matnr TYPE matnr,
           normt TYPE normt,
         END OF lt_mara.

  DATA : wa_vbeln  LIKE bapidlv_range_vbeln,
         wa_header LIKE bapidlvhdr,
         wa_item   LIKE bapidlvitem,
         wa_month  LIKE t247.

  DATA : lv_matnr   TYPE matnr,
         lv_langu   TYPE sy-langu VALUE 'id',
         lv_subrc   TYPE sy-subrc,
         lv_check   TYPE sy-subrc,
         lv_reswk   TYPE reswk,
         lv_nlcc(1),
         lv_werks   TYPE werks_d.

  DATA : in_words   LIKE spell.
  DATA : lv_kunnr   LIKE wa_header-kunnr.

  DATA : wa_zsp     LIKE zproject.

  DATA : lt_mvke    TYPE TABLE OF mvke WITH HEADER LINE.

  CALL FUNCTION 'MONTH_NAMES_GET'
    EXPORTING
      language              = lv_langu
    TABLES
      month_names           = month_names
    EXCEPTIONS
      month_names_not_found = 1
      OTHERS                = 2.

  READ TABLE month_names INTO wa_month WITH KEY mnr = sy-datum+4(2).
  IF sy-subrc = 0.
    CONCATENATE 'Tanggal' sy-datum+6(2) wa_month-ltx sy-datum(4) INTO gs_header-tanggal
    SEPARATED BY space.
  ENDIF.

  is_dlv_data_control-item  = 'X'.

  wa_vbeln-deliv_numb_low  = pa_vbeln.
  wa_vbeln-sign            = 'I'.
  wa_vbeln-option          = 'EQ'.
  APPEND wa_vbeln TO it_vbeln.

  CALL FUNCTION 'BAPI_DELIVERY_GETLIST'
    EXPORTING
      is_dlv_data_control = is_dlv_data_control
    TABLES
      it_vbeln            = it_vbeln
      et_delivery_header  = et_delivery_header
      et_delivery_item    = et_delivery_item
      return              = return.

  lt_item[] = et_delivery_item[].
  SORT lt_item BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_item COMPARING matnr.
  IF lt_item[] IS NOT INITIAL.
    SELECT matnr normt
      FROM mara
      INTO TABLE lt_mara
      FOR ALL ENTRIES IN lt_item
      WHERE matnr = lt_item-matnr.
  ENDIF.

  READ TABLE et_delivery_header INTO wa_header INDEX 1.

  PERFORM f_get_werks_fr_t001l USING wa_header-kunnr wa_header-werks
                               CHANGING lv_werks.

  SELECT matnr vkorg vtweg mvgr1
    INTO CORRESPONDING FIELDS OF TABLE lt_mvke
    FROM mvke FOR ALL ENTRIES IN lt_item
    WHERE matnr = lt_item-matnr
      AND vkorg = wa_header-vkorg
      AND vtweg = '10'
      AND mvgr1 = '04'.

  gs_header-werks     = lv_werks.

  IF gs_header-werks(2) = '38'.
    CLEAR: gs_bool.
    gs_bool-bool = '1'.
    gs_bool-werks = gs_header-werks.
    APPEND gs_bool TO gt_bool.
  ENDIF.
  gs_header-monat     = wa_header-erdat+4(2).
  gs_header-gjahr     = wa_header-erdat(4).
*  gs_header-wadat_ist = wa_header-wadat_ist.
*  gs_header-wadat_ist = wa_header-wadat.
  gs_header-wadat_ist = wa_header-erdat.

  SELECT SINGLE *
    FROM zproject
    INTO wa_zsp
    WHERE name = 'ZSP'
      AND flag = 'X'.

  IF sy-subrc = 0.
    gs_header-nomor1 = wa_header-abssc.
  ELSE.
    IF wa_header-abssc IS INITIAL.
      PERFORM f_get_number USING    sy-ucomm lv_werks gs_header-gjahr
                           CHANGING gs_header-nomor1.
    ELSE.
      gs_header-nomor1 = wa_header-abssc.
    ENDIF.
  ENDIF.

  gs_header-vbeln = pa_vbeln.

  READ TABLE et_delivery_item INTO wa_item INDEX 1.

  SELECT SINGLE street post_code1 city1 tel_number
    FROM twlad JOIN adrc ON twlad~adrnr = adrc~addrnumber
    INTO (gs_header-street, gs_header-post_code1, gs_header-city1,
    gs_header-tel_number)
    WHERE werks = wa_item-werks
      AND ( lgort = '1000' OR lgort = '3000' ). " ADDED lgort = 3000 in the condition

  CLEAR : lv_reswk.
  SELECT SINGLE reswk
    FROM zplbc
    INTO lv_reswk
    WHERE reswk = wa_header-vstel.

  READ TABLE gt_zmpsiko INTO wa_zmpsiko WITH KEY bukrs = wa_header-vkorg
                                                 matnr = wa_item-matnr.
  IF sy-subrc = 0.
    gs_header-repti  = 'SURAT PESANAN OBAT JADI PREKURSOR FARMASI'.
    gs_header-repti1 = 'Obat Jadi Prekursor Farmasi'.
    lv_check  = 1.
  ELSE.
    READ TABLE gt_zmpsiko1 INTO wa_zmpsiko1 WITH KEY bukrs = wa_header-vkorg
                                                     matnr = wa_item-matnr.
    IF sy-subrc = 0.
      gs_header-repti  = 'SURAT PESANAN PSIKOTROPIKA'.
      gs_header-repti1 = 'Psikotropika'.
      lv_check  = 2.
    ELSE.
      gs_header-repti  = 'SURAT PESANAN'.
      gs_header-repti1 = 'Produk'.
      lv_check  = 3.
    ENDIF.
  ENDIF.

  IF wa_header-lfart = 'NLCC' AND
    lv_reswk  = wa_header-vstel.
    lv_nlcc = 'X'.
    IF wa_header-werks(2) = '07'.
      gs_header-united = 'X'.
    ENDIF.
*    gs_header-repti  = 'SURAT PESANAN'.
*    gs_header-repti1 = 'Produk'.
  ELSE.
  ENDIF.

* Adding condition for customer TSB0721 ( Req.by. Sekar/Lanang 11.11.2022
  IF nast-kschl = 'ZST8' AND
     wa_header-lfart = 'ZD03' AND
     wa_header-kunnr = 'TSB0721'.
    gs_header-united = 'X'.
  ENDIF.

*  IF wa_header-werks(2) = '38'.
*    gs_header-united = space.
*  ENDIF.

  CLEAR gs_header-pbfno.
*  IF gs_header-united = 'X'.
*    SELECT SINGLE pbfno
*      FROM zpbf
*      INTO gs_header-pbfno
*      WHERE vkbur = '0700'.
*  ELSE.
  SELECT SINGLE pbfno pakno
    FROM zpbf
    INTO (gs_header-pbfno, gs_header-pakno)
    WHERE vkbur = lv_werks.
*  ENDIF.

  SELECT SINGLE str01 str02
    FROM zsd_sertifikasi
    INTO (gs_header-str01, gs_header-str02)
    WHERE vkbur = lv_werks.

  IF lt_mvke[] IS NOT INITIAL.
    IF gs_header-pakno IS NOT INITIAL.
      gs_header-pbfno = gs_header-pakno.
      gs_header-alkes = 'X'.
    ENDIF.
  ENDIF.

  IF lv_check  = 3 AND gs_header-alkes = 'X'.
    gs_header-repti  = 'SURAT PESANAN ALAT KESEHATAN'.
    gs_header-repti1 = 'Produk'.
  ENDIF.

  PERFORM f_item_validasi TABLES   et_delivery_item
                          USING    lv_check
                          CHANGING lv_subrc.

*  IF lv_subrc IS NOT INITIAL.
*    MESSAGE 'Jenis material tidak sama' TYPE 'E'.
*    EXIT.
*  ENDIF.

*  IF gs_header-united IS NOT INITIAL.
*    SELECT SINGLE user_name no_sk
*      FROM zsign
*      INTO (gs_header-user_name, gs_header-no_sk)
*      WHERE s_point = '0700'.
*  ELSE.
  IF wa_header-vkorg = '8190'.
    SELECT SINGLE user_name no_sk
  FROM zsign
  INTO (gs_header-user_name, gs_header-no_sk)
*      WHERE s_point = wa_header-werks.
  WHERE s_point = wa_header-vstel.
  ELSE.
    SELECT SINGLE user_name no_sk
      FROM zsign
      INTO (gs_header-user_name, gs_header-no_sk)
*      WHERE s_point = wa_header-werks.
      WHERE s_point = lv_werks.
  ENDIF.
*  ENDIF.

  "  if lv_werks

  IF gs_header-werks(2) = '38'.
    gs_header-jabatan = 'Penanggung Jawab Teknis Kefarmasian'.
    CONCATENATE 'SIKTTK:' gs_header-no_sk INTO gs_header-no_sk. " SEPARATED BY space..
  ELSE.
    gs_header-jabatan = 'Penanggung Jawab PBF'.
    CONCATENATE 'SIKA:' gs_header-no_sk INTO gs_header-no_sk." SEPARATED BY space..
  ENDIF.
  IF wa_header-vkorg = '8190'.
    gs_header-jabatan = 'Penanggung Jawab PB Kosmetik'.
  ENDIF.

  IF gs_header-alkes = 'X'.
    SELECT SINGLE user_name no_sk
      FROM zsign_pja
      INTO (gs_header-user_name, gs_header-no_sk)
      WHERE s_point = lv_werks.

    gs_header-jabatan = 'Penanggung Jawab Alkes'.
  ENDIF.

*    IF wa_header-kunnr(5) = 'TBA07'.
*      lv_kunnr = 'TBA0700'.
*    ELSE.
*  lv_kunnr = wa_header-kunnr.
*    ENDIF.


*  SELECT SINGLE kna1~name1 ort01 name_co str_suppl1 str_suppl2
  SELECT SINGLE kna1~name1 adrc~city1 name_co str_suppl1 str_suppl2
    adrc~name1 adrc~name2 kna1~name3 adrc~street mcod1 mcod2
    FROM kna1 JOIN adrc ON kna1~adrnr = adrc~addrnumber
    INTO (gs_header-name1, gs_header-ort01, gs_header-name_co,
    gs_header-str_suppl1, gs_header-str_suppl2, gs_header-name1_ad,
    gs_header-name2_ad, gs_header-name3, gs_header-street_ad,
    gs_header-mcod1, gs_header-mcod2)
    WHERE kunnr = wa_header-kunnr.

  IF gs_header-werks(2) = '38'.
    SELECT SINGLE adrc~name4 FROM kna1 JOIN adrc ON kna1~adrnr = adrc~addrnumber
      INTO gs_header-name4
      WHERE kunnr = wa_header-kunnr.
  ENDIF.

  IF wa_header-kunnr = 'TBA0201'.
    gs_header-name_co = 'Jakarta 1 Branch'.
  ENDIF.

  IF gs_header-united IS NOT INITIAL.
    gs_header-name_co     = gs_header-name1_ad.
*    gs_header-str_suppl1  = gs_header-mcod1.
*    gs_header-str_suppl2  = gs_header-mcod2.
    gs_header-str_suppl1  = gs_header-name2_ad.
    gs_header-str_suppl2  = gs_header-name3.
  ENDIF.

  IF wa_header-vstel(2) = '19'.
    gs_header-str_suppl1  = gs_header-name2_ad.
    gs_header-str_suppl2  = gs_header-name3.
    IF gs_header-werks(2) = '01'.
      gs_header-name_co = 'PB Kosmetik PT Tempo Scan Pacific'.
    ENDIF.
  ENDIF.

  CONCATENATE gs_header-name1 gs_header-ort01 INTO gs_header-cabang
  SEPARATED BY space.
  TRANSLATE gs_header-cabang TO UPPER CASE.

  SELECT SINGLE vtext
    FROM tvkot
    INTO gs_header-vtext
    WHERE spras = sy-langu
      AND vkorg = wa_header-vkorg.

  IF wa_header-vkorg = '8190'.
  ELSE.
    CONCATENATE 'PT' gs_header-vtext INTO gs_header-vtext
    SEPARATED BY space.
  ENDIF.
  PERFORM f_modify_hybrid USING gs_header-werks wa_header-lfart wa_header-vstel
                                gs_header-united
                          CHANGING gs_header-vtext gs_header-street
                                   gs_header-post_code1.

  TRANSLATE gs_header-vtext TO UPPER CASE.

  LOOP AT et_delivery_item INTO wa_item.
    IF wa_item-posnr(1) = '9'.
      CONTINUE.
    ENDIF.
*    ADD 1 TO gt_detail-znou.
    gt_detail-znou = wa_item-posnr / 10.
    gt_detail-matnr    = wa_item-matnr.
    READ TABLE lt_mara WITH KEY matnr = wa_item-matnr.
    IF sy-subrc = 0.
      gt_detail-normt = lt_mara-normt.
    ENDIF.
    gt_detail-maktx    = wa_item-arktx.
    IF wa_item-lfimg IS NOT INITIAL.
      gt_detail-kcmeng   = wa_item-lfimg.
    ELSE.
      gt_detail-kcmeng   = wa_item-kcmeng.
    ENDIF.
    gt_detail-meins    = wa_item-meins.
    WRITE gt_detail-kcmeng TO gt_detail-kcmengt UNIT gt_detail-meins.

    CALL FUNCTION 'SPELL_AMOUNT'
      EXPORTING
        amount    = gt_detail-kcmengt
        language  = lv_langu
      IMPORTING
        in_words  = in_words
      EXCEPTIONS
        not_found = 1
        too_large = 2
        OTHERS    = 3.

    IF sy-subrc = 0.
      gt_detail-qtytxt  = in_words-word.
    ENDIF.

    CASE lv_check.
      WHEN '1'.
        READ TABLE gt_zmpsiko INTO wa_zmpsiko WITH KEY matnr = wa_item-matnr.
        IF sy-subrc = 0.
          gt_detail-zaktif  = wa_zmpsiko-zaktif.
          gt_detail-zkuat   = wa_zmpsiko-zkuat.
        ENDIF.
      WHEN '2'.
        READ TABLE gt_zmpsiko1 INTO wa_zmpsiko1 WITH KEY matnr = wa_item-matnr.
        IF sy-subrc = 0.
          gt_detail-zaktif  = wa_zmpsiko1-zaktif.
          gt_detail-zkuat   = wa_zmpsiko1-zkuat.
        ENDIF.
      WHEN '3'.
    ENDCASE.

    APPEND gt_detail.
    CLEAR gt_detail.
  ENDLOOP.

ENDFORM.                    " f_get_data
*&---------------------------------------------------------------------*
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data.

ENDFORM.                    " f_validate_data
*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  SORT gt_detail BY znou.
ENDFORM.                    " f_process_data
*&---------------------------------------------------------------------*
*&      Form  f_print_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_form.
  DATA : lt_nast  TYPE STANDARD TABLE OF nast.

  SELECT *
    FROM nast
    INTO CORRESPONDING FIELDS OF TABLE lt_nast
    WHERE kappl   = nast-kappl
      AND objky   = nast-objky
      AND kschl   = nast-kschl
      AND vstat   = '1'.

  IF sy-subrc = 0.
    gs_header-vstat = '1'.
  ELSE.
    UPDATE likp   SET abssc = gs_header-nomor1
                WHERE vbeln = gs_header-vbeln.
  ENDIF.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  IF d_frm_subrc IS INITIAL.
    d_output_opt-tdimmed  = nast-dimme.
    d_output_opt-tddelete = nast-delet.
    d_output_opt-tdcopies = nast-anzal.

    IF gt_bool[] IS NOT INITIAL.
      LOOP AT gt_bool INTO gs_bool.
        CALL FUNCTION d_smrt_funcmod
          EXPORTING
            control_parameters = d_ctrl_param
            output_options     = d_output_opt
            user_settings      = space
            gs_header          = gs_header
            gs_bool            = gs_bool-bool
          TABLES
            gt_detail          = gt_detail.
      ENDLOOP.
    ELSE.
      CALL FUNCTION d_smrt_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = d_output_opt
          user_settings      = space
          gs_header          = gs_header
          gs_bool            = gs_bool-bool
        TABLES
          gt_detail          = gt_detail.
    ENDIF.
  ENDIF.


ENDFORM.                    " f_print_form
*&---------------------------------------------------------------------*
*&      Form  f_free_memory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.
  CLEAR:  gt_detail, gt_detail[], gs_header.
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  F_GET_NUMBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_UCOMM  text
*      -->P_GS_HEADER_WERKS  text
*      -->P_GS_HEADER_GJAHR  text
*----------------------------------------------------------------------*
FORM f_get_number  USING    fu_ucomm fu_werks fu_gjahr
                   CHANGING fc_number.

  DATA : lt_nast  TYPE STANDARD TABLE OF nast.

  IF fu_ucomm = 'VIEW'.
    SELECT SINGLE nrlevel
      FROM nriv
      INTO fc_number
      WHERE object     = 'ZGDSP1'
        AND subobject  = fu_werks
        AND nrrangenr  = '01'
        AND toyear     = fu_gjahr.
    fc_number = fc_number + 1.
  ELSE.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = 'ZGDSP1'
        subobject               = fu_werks
        toyear                  = fu_gjahr
      IMPORTING
        number                  = fc_number
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
  ENDIF.
ENDFORM.                    " F_GET_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_ITEM_VALIDASI
*&---------------------------------------------------------------------*
FORM f_item_validasi  TABLES   ft_item STRUCTURE bapidlvitem
                      USING    fu_check
                      CHANGING fc_subrc.

  DATA : BEGIN OF lt_mara OCCURS 0,
           matnr TYPE matnr,
           mtart TYPE mtart,
           normt TYPE normt,
           profl TYPE profl,
         END OF lt_mara.
  DATA : BEGIN OF lt_psiko OCCURS 0,
           matnr TYPE matnr,
         END OF lt_psiko.
  DATA : wa_item  LIKE bapidlvitem.

* Get data for material check
  SELECT matnr
    FROM zmpsiko
    INTO TABLE lt_psiko
    FOR ALL ENTRIES IN ft_item
    WHERE matnr = ft_item-matnr.

  CASE fu_check.
    WHEN 1.

    WHEN 2.
      SELECT matnr normt mtart profl
        FROM mara
        INTO TABLE lt_mara
        FOR ALL ENTRIES IN ft_item
        WHERE matnr = ft_item-matnr
          AND mtart = 'ZPHA'
          AND ( profl = 'OKT' OR
                profl = 'PSI' ).

    WHEN 3.
      SELECT matnr normt mtart profl
        FROM mara
        INTO TABLE lt_mara
        FOR ALL ENTRIES IN ft_item
        WHERE matnr = ft_item-matnr
          AND ( profl <> 'OKT' OR
                profl <> 'PSI' ).
  ENDCASE.

* Validate material process
  CASE fu_check.
    WHEN 1.
      SORT lt_psiko BY matnr.
      SORT ft_item BY matnr.
      LOOP AT ft_item INTO wa_item.
        READ TABLE lt_psiko WITH KEY matnr = wa_item-matnr
                            BINARY SEARCH.
        IF sy-subrc <> 0.
          fc_subrc = sy-subrc.
          EXIT.
        ENDIF.
      ENDLOOP.
    WHEN OTHERS.
      SORT lt_psiko BY matnr.
      SORT lt_mara BY matnr.
      SORT ft_item BY matnr.
      LOOP AT ft_item INTO wa_item.
        READ TABLE lt_psiko WITH KEY matnr = wa_item-matnr
                            BINARY SEARCH.
        IF sy-subrc = 0.
          fc_subrc = 4.
          EXIT.
        ENDIF.

        READ TABLE lt_mara WITH KEY matnr = wa_item-matnr
                           BINARY SEARCH.
        IF sy-subrc <> 0.
          fc_subrc = sy-subrc.
          EXIT.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_ITEM_VALIDASI

*&---------------------------------------------------------------------*
*&      Form  F_GET_WERKS_FR_T001L
*&---------------------------------------------------------------------*
FORM f_get_werks_fr_t001l  USING    fu_kunnr fu_werks
                           CHANGING fc_werks.
  CLEAR fc_werks.

  SELECT SINGLE vstel
    FROM t001l
    INTO fc_werks
    WHERE kunnr = fu_kunnr.

  IF sy-subrc <> 0.
    fc_werks  = fu_werks.
  ENDIF.
ENDFORM.                    " F_GET_WERKS_FR_T001L

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_HYBRID
*&---------------------------------------------------------------------*
FORM f_modify_hybrid  USING    fu_werks fu_lfart fu_vstel fu_united
                      CHANGING fc_vtext fc_street fc_postcode.
  DATA : ls_001   TYPE zssutct001,
         lv_adrnr TYPE t001w-adrnr.

  IF nast-kschl = 'ZST8' AND
     fu_lfart = 'ZD03'.
    SELECT SINGLE *
      FROM zssutct001
      INTO CORRESPONDING FIELDS OF ls_001
      WHERE werks = fu_werks.
    IF sy-subrc = 0.
      SELECT SINGLE name1 adrnr
        FROM t001w
        INTO (fc_vtext, lv_adrnr)
        WHERE werks = fu_vstel.

      SELECT SINGLE street post_code1
        FROM adrc
        INTO (fc_street, fc_postcode)
        WHERE addrnumber = lv_adrnr.
    ENDIF.
  ELSEIF fu_united IS NOT INITIAL.
    fc_vtext  = 'PT SUPRA USADHATAMA'.
    fc_street = 'Jl. Raya Sultan Agung Km 28 Pondok Ungu Medan Satria Kota Bekasi'.
    CLEAR fc_postcode.
  ENDIF.
ENDFORM.                    " F_MODIFY_HYBRID
