*----------------------------------------------------------------------*
*   INCLUDE ZGDMMF0005F01                                              *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS lcl_event_handler DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
*CLASS lcl_event_handler DEFINITION.
*  PUBLIC SECTION.
*    METHODS:
*      handle_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
*        IMPORTING
*          er_data_changed.
*ENDCLASS.                    "lcl_main DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_main IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
*CLASS lcl_event_handler IMPLEMENTATION.
*  METHOD handle_data_changed.
*    DATA: ls_good   TYPE lvc_s_modi,
*          lv_berat  TYPE char10,
*          lv_cntr   TYPE numc3.
*
*    FIELD-SYMBOLS: <fs_detail> TYPE zfist001.
*
*    LOOP AT er_data_changed->mt_good_cells INTO ls_good.
*      CLEAR: lv_berat,lv_cntr.
*      CALL METHOD er_data_changed->get_cell_value
*        EXPORTING
*          i_row_id    = ls_good-row_id
*          i_fieldname = 'BERAT'
*        IMPORTING
*          e_value     = lv_berat.
*      CALL METHOD er_data_changed->get_cell_value
*        EXPORTING
*          i_row_id    = ls_good-row_id
*          i_fieldname = 'CNTR'
*        IMPORTING
*          e_value     = lv_cntr.
*
**      READ TABLE gt_fg ASSIGNING <fs_fg>
**                           INDEX ls_good-row_id.
**
**      <fs_fg>-berat = lv_berat.
**      <fs_fg>-cntr  = lv_cntr.
*    ENDLOOP.
*
**    CALL METHOD g_grid->refresh_table_display( ).
*
*  ENDMETHOD.                    "on_data_changed
*ENDCLASS.                    "lcl_main IMPLEMENTATION

*DATA: g_event_handler TYPE REF TO lcl_event_handler.

*&---------------------------------------------------------------------*
*&      Form  f_init_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data.
  gv_repid = sy-repid.
  gs_variant-report = gv_repid.
  gs_variant-variant = pa_vari.

  gr_budat-sign = 'I'.
  gr_budat-option = 'BT'.
  CONCATENATE p_spmon '01' INTO gr_budat-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = gr_budat-low
    IMPORTING
      last_day_of_month = gr_budat-high.
  APPEND gr_budat.
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
  DATA: lr_matnr TYPE RANGE OF matnr,
        ls_matnr LIKE LINE OF lr_matnr.

  DATA: lv_gjahr  TYPE anlc-gjahr,
        lv_afblpe TYPE anlc-afblpe,
        lr_bzdat  TYPE RANGE OF bzdat.

  SELECT * INTO TABLE gt_ztspfidt01
    FROM ztspfidt01 WHERE gjahr = p_spmon(4).

  IF gt_ztspfidt01[] IS INITIAL.
    MESSAGE 'Harap maintain table Kapasitas' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  SELECT * INTO TABLE gt_ztspfidt02
    FROM ztspfidt02 WHERE werks = p_gsber.

  PERFORM f_get_mseg.

  IF gt_produce[] IS INITIAL.
    SELECT bukrs anln1 anln2 bdatu kostl gsber
      INTO CORRESPONDING FIELDS OF TABLE gt_anlz
      FROM anlz FOR ALL ENTRIES IN gt_ztspfidt01
      WHERE gsber = p_gsber
        AND bukrs = p_bukrs
        AND anln1 IN s_anln1
        AND anln2 IN s_anln2
        AND kostl = gt_ztspfidt01-kostl.
  ELSE.
    SELECT bukrs anln1 anln2 bdatu kostl gsber
      INTO CORRESPONDING FIELDS OF TABLE gt_anlz
      FROM anlz FOR ALL ENTRIES IN gt_produce
      WHERE gsber = p_gsber
        AND bukrs = p_bukrs
        AND anln1 IN s_anln1
        AND anln2 IN s_anln2
        AND kostl = gt_produce-kostl.
  ENDIF.

  IF gt_anlz[] IS NOT INITIAL.
    SELECT * INTO TABLE gt_ztspfidt04
      FROM ztspfidt04 FOR ALL ENTRIES IN gt_anlz
      WHERE bukrs = gt_anlz-bukrs
        AND gsber = gt_anlz-gsber
        AND spmon = p_spmon
        AND anln1 = gt_anlz-anln1
        AND anln2 = gt_anlz-anln2.

    SELECT bukrs anln1 anln2 aktiv
      INTO CORRESPONDING FIELDS OF TABLE gt_anla
      FROM anla FOR ALL ENTRIES IN gt_anlz
      WHERE bukrs = gt_anlz-bukrs
        AND anln1 = gt_anlz-anln1
        AND anln2 = gt_anlz-anln2.

    SELECT bukrs anln1 anln2 afabe bdatu ndjar ndper
      INTO CORRESPONDING FIELDS OF TABLE gt_anlb
      FROM anlb FOR ALL ENTRIES IN gt_anlz
      WHERE bukrs = gt_anlz-bukrs
        AND anln1 = gt_anlz-anln1
        AND anln2 = gt_anlz-anln2
        AND afabe = '01'
        AND afasl = '00000'.    "'Z100'.

    "Get Last Year
    IF p_spmon+4(2) = '01'.
      lv_gjahr    = p_spmon(4) - 1.
      lv_afblpe   = 12.
      SELECT bukrs anln1 anln2 gjahr afabe zujhr zucod kansw answl
             nafag knafa aafag kaafa
        INTO CORRESPONDING FIELDS OF TABLE gt_anlc
        FROM anlc FOR ALL ENTRIES IN gt_anlz
        WHERE bukrs  = gt_anlz-bukrs
          AND anln1  = gt_anlz-anln1
          AND anln2  = gt_anlz-anln2
          AND gjahr  = lv_gjahr
          AND afblpe = lv_afblpe
          AND afabe  = '01'.
    ELSE.
      lv_gjahr    = p_spmon(4).
    ENDIF.

    "Get Current Year
    SELECT bukrs anln1 anln2 gjahr afabe zujhr zucod kansw answl
           nafag knafa aafag kaafa
      INTO CORRESPONDING FIELDS OF TABLE gt_anlc2
      FROM anlc FOR ALL ENTRIES IN gt_anlz
      WHERE bukrs  = gt_anlz-bukrs
        AND anln1  = gt_anlz-anln1
        AND anln2  = gt_anlz-anln2
        AND gjahr  = lv_gjahr        " p_spmon(4)
        AND afabe  = '01'.

    " 2023
    SELECT bukrs anln1 anln2 gjahr afabe zujhr zucod kansw answl
           nafag knafa aafag kaafa
      INTO CORRESPONDING FIELDS OF TABLE gt_anlc3
      FROM anlc FOR ALL ENTRIES IN gt_anlz
      WHERE bukrs  = gt_anlz-bukrs
        AND anln1  = gt_anlz-anln1
        AND anln2  = gt_anlz-anln2
        AND gjahr  = '2023'
        AND afabe  = '01'.

    PERFORM f_get_parameter TABLES    lr_bzdat
                            USING     p_spmon
                            CHANGING  lv_gjahr.
    PERFORM f_get_anep TABLES lr_bzdat
                       USING  lv_gjahr.
  ENDIF.
ENDFORM.                    " f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  DATA: lv_ndjar    TYPE ndjar,
        lv_gjahr    TYPE gjahr,
        lv_aktiv    TYPE aktivd,
        lv_retire   TYPE datum,
        lv_sisaumur TYPE menge_d,
        lv_bookval  TYPE kansw,
        lv_prevnbv  TYPE kansw.

  SORT: gt_anlz BY bukrs anln1 anln2,
        gt_anla BY bukrs anln1 anln2,
        gt_anlb BY bukrs anln1 anln2,
        gt_anlc BY bukrs anln1 anln2,
        gt_anlc2 BY bukrs anln1 anln2,
        gt_anlc3 BY bukrs anln1 anln2,
        gt_anep BY bukrs anln1 anln2.

  DATA : lv_anlc.

  LOOP AT gt_anlz.
    CLEAR: gt_anla,gt_anlb,gt_anlc,gt_anep,gt_ztspfidt01,
           gt_produce,lv_bookval,lv_gjahr,lv_aktiv,lv_prevnbv,lv_anlc.

* New Condition
    IF p_spmon+4(2) = '01'.
      READ TABLE gt_anlc WITH KEY bukrs = gt_anlz-bukrs
                                  anln1 = gt_anlz-anln1
                                  anln2 = gt_anlz-anln2
                                  BINARY SEARCH.
      IF sy-subrc = 0.
        lv_bookval = gt_anlc-kansw + gt_anlc-answl.
        lv_prevnbv = gt_anlc-answl + gt_anlc-kansw + gt_anlc-knafa +
                     gt_anlc-nafag + gt_anlc-aafag + gt_anlc-kaafa.
        lv_gjahr   = p_spmon(4) - 1.
        CONCATENATE lv_gjahr '1231' INTO lv_aktiv.

        "Added 06.02.2026
        READ TABLE gt_anep WITH KEY bukrs = gt_anlz-bukrs
                                    anln1 = gt_anlz-anln1
                                    anln2 = gt_anlz-anln2
                                    BINARY SEARCH.
        IF sy-subrc = 0.
          lv_bookval = lv_bookval + gt_anep-anbtr.
        ENDIF.
        "End Added 06.02.2026

      ELSE.
        READ TABLE gt_anep WITH KEY bukrs = gt_anlz-bukrs
                                    anln1 = gt_anlz-anln1
                                    anln2 = gt_anlz-anln2
                                    BINARY SEARCH.
        IF sy-subrc = 0.
          lv_bookval = gt_anep-anbtr.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDIF.
    ELSE.
      READ TABLE gt_anlc2 WITH KEY bukrs = gt_anlz-bukrs
                                   anln1 = gt_anlz-anln1
                                   anln2 = gt_anlz-anln2
                                   BINARY SEARCH.
      IF sy-subrc = 0.
        lv_bookval = gt_anlc2-kansw + gt_anlc2-answl.
        lv_prevnbv = gt_anlc2-answl + gt_anlc2-kansw + gt_anlc2-knafa +
                     gt_anlc2-nafag + gt_anlc2-aafag + gt_anlc2-kaafa.
      ENDIF.
    ENDIF.

    IF lv_prevnbv LE 0.
*      lv_prevnbv = lv_bookval.
      READ TABLE gt_anep WITH KEY bukrs = gt_anlz-bukrs
                                  anln1 = gt_anlz-anln1
                                  anln2 = gt_anlz-anln2
                                  BINARY SEARCH.
      IF sy-subrc = 0.
        lv_prevnbv = gt_anep-anbtr.
      ENDIF.
    ENDIF.

    IF lv_bookval LE 0 OR lv_prevnbv LE 0.
      CONTINUE.
    ENDIF.

    READ TABLE gt_anlb WITH KEY bukrs = gt_anlz-bukrs
                                anln1 = gt_anlz-anln1
                                anln2 = gt_anlz-anln2
                                BINARY SEARCH.

    READ TABLE gt_anla WITH KEY bukrs = gt_anlz-bukrs
                                anln1 = gt_anlz-anln1
                                anln2 = gt_anlz-anln2
                                BINARY SEARCH.

    IF gt_anla-aktiv(6) GT p_spmon.
      CONTINUE.
    ENDIF.

    READ TABLE gt_ztspfidt01 WITH KEY kostl = gt_anlz-kostl.
    READ TABLE gt_produce WITH KEY kostl = gt_anlz-kostl.

    CLEAR: lv_ndjar,lv_retire,lv_sisaumur.
    lv_ndjar = gt_anlb-ndjar * 12 + gt_anlb-ndper.
    PERFORM f_get_retire USING    lv_ndjar
                                  gt_anla-aktiv
                         CHANGING lv_retire.

*    IF lv_aktiv IS INITIAL.
*      lv_aktiv = gt_anla-aktiv.
*    ENDIF.
    lv_aktiv = gt_anla-aktiv.

    DATA(lv_date1) = lv_aktiv.
    lv_date1 = '20231231'.
*    IF lv_aktiv LE lv_date1.
*      lv_sisaumur = gt_anlb-ndjar.
*      PERFORM f_get_sisaumur2 USING    lv_date1
*                                       lv_retire
*                                       lv_aktiv
*                              CHANGING lv_sisaumur.
*    ELSE.
*      PERFORM f_get_sisaumur USING    p_spmon
*                                      lv_retire
*                                      lv_aktiv
*                             CHANGING lv_sisaumur.
*    ENDIF.
    lv_sisaumur = gt_anlb-ndjar.
*    IF lv_sisaumur LT 1.
*      lv_sisaumur = gt_anlb-ndjar.
*    ENDIF.

*    IF lv_sisaumur LE 0.
*    IF lv_bookval LE 0.    "Pindah ke-line 221.
*      CONTINUE.
*    ENDIF.

    APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.

    <fs_out>-spmon        = p_spmon.
    <fs_out>-bukrs        = gt_anlz-bukrs.
    <fs_out>-anln1        = gt_anlz-anln1.
    <fs_out>-anln2        = gt_anlz-anln2.
    <fs_out>-bdatu        = gt_anlz-bdatu.
    <fs_out>-adatu        = gt_anlz-adatu.
    <fs_out>-kostl        = gt_anlz-kostl.
    <fs_out>-gsber        = gt_anlz-gsber.
    <fs_out>-ndjar        = gt_anlb-ndjar * 12.
    <fs_out>-aktiv        = gt_anla-aktiv.
    <fs_out>-zugdt        = gt_anla-zugdt.
    <fs_out>-retire       = lv_retire.
    <fs_out>-sisaumur     = lv_sisaumur.

    IF gt_anla-aktiv < '20240101'.
      READ TABLE gt_anlc3 WITH KEY bukrs = gt_anlz-bukrs
                                   anln1 = gt_anlz-anln1
                                   anln2 = gt_anlz-anln2
                                   BINARY SEARCH.
      IF sy-subrc = 0.
        lv_bookval = gt_anlc3-answl + gt_anlc3-knafa + gt_anlc3-nafag +
                     gt_anlc3-kansw.
      ENDIF.
    ENDIF.

    <fs_out>-bookval      = lv_bookval.

    <fs_out>-prevnbv      = lv_prevnbv.
    <fs_out>-kapasitas    = gt_ztspfidt01-kapasitas.
    <fs_out>-totkapasitas = <fs_out>-sisaumur  * <fs_out>-kapasitas.
*    <fs_out>-bookval      = gt_anlc-kansw + gt_anlc-knafa + gt_anlc-nafag.
*    IF gt_anlc-kansw IS INITIAL.
*      <fs_out>-bookval      = gt_anlc-answl + gt_anlc-knafa + gt_anlc-nafag.
*    ELSE.
*      <fs_out>-bookval      = gt_anlc-answl + gt_anlc-knafa + gt_anlc-nafag +
*                              gt_anlc-kansw.
*    ENDIF.
*    <fs_out>-qtyprod      = gt_produce-qty.
    <fs_out>-qtyprod      = round( val = gt_produce-qty dec = 0 ).
    IF <fs_out>-totkapasitas IS NOT INITIAL.
      <fs_out>-depre      = <fs_out>-bookval / <fs_out>-totkapasitas.
      <fs_out>-depreval   = <fs_out>-qtyprod * <fs_out>-bookval / <fs_out>-totkapasitas.
      IF <fs_out>-depreval GT lv_prevnbv.
        <fs_out>-depreval   = lv_prevnbv.
      ENDIF.
    ELSE.
*      <fs_out>-depreval   = lv_prevnbv.
      <fs_out>-depreval   = 0.
    ENDIF.

    READ TABLE gt_ztspfidt04 WITH KEY bukrs = <fs_out>-bukrs
                                      gsber = <fs_out>-gsber
                                      spmon = <fs_out>-spmon
                                      anln1 = <fs_out>-anln1
                                      anln2 = <fs_out>-anln2
                                      TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      PERFORM f_style_cell USING '' 'CHKBOX' ''
                           CHANGING <fs_out>-style.
    ELSE.
      PERFORM f_style_cell USING 'X' 'CHKBOX' ''
                           CHANGING <fs_out>-style.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " f_process_data

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CALL SCREEN 100.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  f_free_memory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.
  CLEAR: gt_ztspfidt01,gt_ztspfidt02.
  REFRESH: gt_ztspfidt01,gt_ztspfidt02.
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Module  PBO100  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo100 OUTPUT.
  DATA: lt_fcode TYPE TABLE OF sy-ucomm,
        ls_fcode TYPE sy-ucomm.

  CASE 'X'.
    WHEN p_but1.
      ls_fcode = '&POS'. APPEND ls_fcode TO lt_fcode.
      ls_fcode = '&SAL'. APPEND ls_fcode TO lt_fcode.
      ls_fcode = '&ALL'. APPEND ls_fcode TO lt_fcode.
    WHEN p_but2.
      ls_fcode = '&SAL'. APPEND ls_fcode TO lt_fcode.
      ls_fcode = '&ALL'. APPEND ls_fcode TO lt_fcode.
    WHEN p_but3.
      ls_fcode = '&SAV'. APPEND ls_fcode TO lt_fcode.
    WHEN p_but4.
      ls_fcode = '&SAV'. APPEND ls_fcode TO lt_fcode.
      ls_fcode = '&POS'. APPEND ls_fcode TO lt_fcode.
      ls_fcode = '&SAL'. APPEND ls_fcode TO lt_fcode.
      ls_fcode = '&ALL'. APPEND ls_fcode TO lt_fcode.
  ENDCASE.

  SET PF-STATUS 'STATUS_0100' EXCLUDING lt_fcode.
  SET TITLEBAR 'TITLE_0100'.

  IF g_custom_container IS INITIAL.
    CLEAR: g_custom_container,g_grid,gs_layout,gt_fieldcat.

    PERFORM f_build_fieldcat.
    PERFORM f_build_layout.
    PERFORM f_build_sortfield.
    PERFORM f_toolbar_excluding.

* Create_object_container
    CREATE OBJECT g_custom_container
      EXPORTING
        container_name = g_container.

* Create_object_grid
    CREATE OBJECT g_grid
      EXPORTING
        i_parent = g_custom_container.

* Create_display_ALV
    CASE 'X'.
      WHEN p_but1.
        CALL METHOD g_grid->set_table_for_first_display
          EXPORTING
            is_layout            = gs_layout
            it_toolbar_excluding = gt_exclude
            i_default            = 'X'
            i_save               = 'A'
            is_variant           = gs_variant
          CHANGING
            it_fieldcatalog      = gt_fieldcat[]
            it_outtab            = gt_upload[]
            it_sort              = gt_sort[].
      WHEN p_but2.
      WHEN p_but3.
        CALL METHOD g_grid->set_table_for_first_display
          EXPORTING
            is_layout            = gs_layout
            it_toolbar_excluding = gt_exclude
            i_default            = 'X'
            i_save               = 'A'
            is_variant           = gs_variant
          CHANGING
            it_fieldcatalog      = gt_fieldcat[]
            it_outtab            = gt_out[]
            it_sort              = gt_sort[].
      WHEN p_but4.
        CALL METHOD g_grid->set_table_for_first_display
          EXPORTING
            is_layout            = gs_layout
            it_toolbar_excluding = gt_exclude
            i_default            = 'X'
            i_save               = 'A'
            is_variant           = gs_variant
          CHANGING
            it_fieldcatalog      = gt_fieldcat[]
            it_outtab            = gt_produce2[]
            it_sort              = gt_sort[].
    ENDCASE.

* When edit display
    CALL METHOD g_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

* Data Change Handler
*    CREATE OBJECT g_event_handler.
*    SET HANDLER g_event_handler->handle_data_changed FOR g_grid.

  ELSE.
    CALL METHOD g_grid->refresh_table_display( ).
  ENDIF.
ENDMODULE.                 " PBO100  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_build_fieldcat .
  CLEAR gt_fieldcat[].

  CASE 'X'.
    WHEN p_but1.
      PERFORM f_fieldcatg USING 'GT_UPLOAD':
        'GJAHR' 'ZTSPFIDT01' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KOSTL' 'ZTSPFIDT01' 'KOSTL' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KTEXT' 'CSKT' 'KTEXT' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KAPASITAS' 'ZTSPFIDT01' 'KAPASITAS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MEINS'  '' '' '' '' 'UoM' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    WHEN p_but2.
    WHEN p_but3.
      PERFORM f_fieldcatg USING 'GT_OUT':
        'CHKBOX' '' '' '' '3' 'Chk' '' '' '' '' '' '' '' 'X' '' '' '' 'X' '' '',
        'SPMON' 'S933' 'SPMON' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BUKRS' 'ANLZ' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GSBER' 'ANLZ' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ANLN1' 'ANLZ' 'ANLN1' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ANLN2' 'ANLZ' 'ANLN2' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KOSTL' 'ANLZ' 'KOSTL' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'NDJAR' 'ANLB' 'NDJAR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'AKTIV' 'ANLA' 'AKTIV' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZUGDT' 'ANLA' 'ZUGDT' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'RETIRE' '' '' '' '' 'Retire date' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'SISAUMUR' '' '' '' '' 'SISAUMUR' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KAPASITAS' '' '' '' '' 'Kapasitas' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'TOTKAPASITAS' '' '' '' '' 'Total Kapasitas' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BOOKVAL' '' '' '' '' 'Book Value' '' '' '' 'IDR' '' '' '' '' '' '' '' '' '' '',
        'DEPRE' '' '' '' '' 'Depre/unit' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'QTYPROD' '' '' '' '' 'Qty Produce' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'DEPREVAL' '' '' '' '' 'Depre. Value' '' '' '' 'IDR' '' '' '' '' '' '' '' '' '' '',
        'PREVNBV' '' '' '' '' 'Prev.NBV' '' '' '' 'IDR' '' '' '' '' '' '' '' '' '' ''.
    WHEN p_but4.
      PERFORM f_fieldcatg USING 'GT_PRODUCE2':
        'WERKS' 'MSEG' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MATNR' 'MSEG' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'SPMON' 'S933' 'SPMON' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'FEVOR' 'MARC' 'FEVOR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KOSTL' 'ANLZ' 'KOSTL' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MEINS' 'MSEG' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'QTY' 'MSEG' 'MENGE' '' '' '' '' '' '' '' '' '' 'MEINS' '' '' '' '' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_fieldcatg USING   VALUE(fu_types)
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
                          VALUE(fu_hotspot)
                          VALUE(fu_edit)
                          VALUE(fu_no_zero)
                          VALUE(fu_just).

  DATA: ld_fieldcat  TYPE  lvc_t_fcat WITH HEADER LINE.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_table         = fu_reftb.
  ld_fieldcat-ref_field         = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-reptext           = fu_fltxt.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_o        = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-emphasize         = fu_emphasize.
  ld_fieldcat-hotspot           = fu_hotspot.
  ld_fieldcat-edit              = fu_edit.
  ld_fieldcat-no_zero           = fu_no_zero.
  ld_fieldcat-just              = fu_just.
  APPEND ld_fieldcat TO gt_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout-zebra       = 'X'.
  gs_layout-cwidth_opt  = 'X'.
  gs_layout-col_opt     = 'X'.
  gs_layout-no_headers  = space.
  gs_layout-no_rowmark  = 'X'.
  gs_layout-stylefname  = 'STYLE'.
*  gs_layout-box_fname   = 'CHKBOX'.
*  gs_layout-sel_mode    = 'A'.
*  gs_layout-no_toolbar  = 'X'.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTFIELD
*&---------------------------------------------------------------------*
FORM f_build_sortfield .
  CLEAR gt_sort[].

  CASE 'X'.
    WHEN p_but1.
      gt_sort-spos      = '1'.
      gt_sort-fieldname = 'GJAHR'.
      APPEND gt_sort. CLEAR gt_sort.
      gt_sort-spos      = '2'.
      gt_sort-fieldname = 'KOSTL'.
      APPEND gt_sort. CLEAR gt_sort.

    WHEN p_but2.

    WHEN p_but3.
      gt_sort-spos      = '1'.
      gt_sort-fieldname = 'SPMON'.
      APPEND gt_sort.CLEAR gt_sort.
      gt_sort-spos      = '2'.
      gt_sort-fieldname = 'BUKRS'.
      APPEND gt_sort.CLEAR gt_sort.
      gt_sort-spos      = '3'.
      gt_sort-fieldname = 'GSBER'.
      APPEND gt_sort.CLEAR gt_sort.
      gt_sort-spos      = '4'.
      gt_sort-fieldname = 'ANLN1'.
      APPEND gt_sort.CLEAR gt_sort.
      gt_sort-spos      = '5'.
      gt_sort-fieldname = 'ANLN2'.
      APPEND gt_sort.CLEAR gt_sort.
      gt_sort-spos      = '6'.
      gt_sort-fieldname = 'KOSTL'.
      APPEND gt_sort.CLEAR gt_sort.

    WHEN p_but4.
      gt_sort-spos      = '1'.
      gt_sort-fieldname = 'WERKS'.
      APPEND gt_sort.CLEAR gt_sort.
      gt_sort-spos      = '2'.
      gt_sort-fieldname = 'MATNR'.
      APPEND gt_sort.CLEAR gt_sort.
  ENDCASE.
ENDFORM.                    " F_BUILD_SORTFIELD

*&---------------------------------------------------------------------*
*&      Module  PAI100  INPUT
*&---------------------------------------------------------------------*
MODULE pai100 INPUT.
  DATA : lv_valid       TYPE c.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'ESC' OR 'CANC'.
      CALL METHOD g_grid->free.
      CALL METHOD g_custom_container->free.
      LEAVE TO SCREEN 0.

    WHEN '&POS'.
      PERFORM f_execute_abma.

    WHEN '&SAV'.
      PERFORM f_save_table.

    WHEN '&SAL'.
      CALL METHOD g_grid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING ''.
      ENDIF.

    WHEN '&ALL'.
      CALL METHOD g_grid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING 'X'.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " PAI100  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_TOOLBAR_EXCLUDING
*&---------------------------------------------------------------------*
FORM f_toolbar_excluding .
  DATA ls_exclude TYPE ui_func.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_print .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row .
  APPEND ls_exclude TO gt_exclude.
ENDFORM.                    " F_TOOLBAR_EXCLUDING

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
FORM f_f4_for_variant_alv  CHANGING fc_variant.
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
*&      Form  F_EXECUTE_ABMA
*&---------------------------------------------------------------------*
FORM f_execute_abma .
  DATA: lv_bldat(10),
        lv_budat(10),
        lv_adjust(15),
        lv_adjust2 TYPE kansw.

  READ TABLE gr_budat INDEX 1.
  WRITE: gr_budat-high TO lv_bldat,
         gr_budat-high TO lv_budat.

  LOOP AT gt_out WHERE chkbox = 'X'.
    IF gt_out-depreval GT gt_out-prevnbv.
      WRITE gt_out-prevnbv TO lv_adjust CURRENCY 'IDR'.
      lv_adjust2 = gt_out-prevnbv.
    ELSE.
      WRITE gt_out-depreval TO lv_adjust CURRENCY 'IDR'.
      lv_adjust2 = gt_out-depreval.
    ENDIF.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X'   'SAPMA01B'       '0100',
      ' '   'BDC_CURSOR'     'ANBZ-ANLN1',
      ' '   'BDC_OKCODE'     '/00',
      ' '   'ANBZ-BUKRS'     gt_out-bukrs,
      ' '   'ANBZ-ANLN1'     gt_out-anln1,
      ' '   'ANBZ-ANLN2'     gt_out-anln2,
      ' '   'ANEK-BLDAT'     lv_bldat,
      ' '   'ANEK-BUDAT'     lv_budat,
      ' '   'ANBZ-PERID'     p_spmon+4(2),
      ' '   'ANBZ-BWASL'     p_bwasl.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X' 'SAPMA01B'         '0110',
      ' ' 'BDC_CURSOR'       'ANBZ-DMBTR',
      ' ' 'BDC_OKCODE'       '/00',
      ' ' 'ANBZ-DMBTR'       lv_adjust,
      ' ' 'ANEK-SGTXT'       sy-datum,
      ' ' 'ANEK-XBLNR'       sy-datum,
      ' ' 'ANBZ-BZDAT'       lv_budat.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X' 'SAPMA01B'         '0285',
      ' ' 'BDC_OKCODE'       '=AUSF'.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X' 'SAPMA01B'         '0110',
      ' ' 'BDC_OKCODE'       '=UPDA'.

    d_bdc_batch = 'N'.  "'A'.
    PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                            t_bdcmsg
                                     USING 'ABMA' d_bdc_tctxt.

    READ TABLE t_bdcmsg WITH KEY msgtyp = 'E'
                        TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      PERFORM f_error_log.
    ELSE.
      PERFORM f_collect_itab USING lv_adjust2.
    ENDIF.

    CLEAR : t_bdcdata[], t_bdcmsg[], t_bdcdata, t_bdcmsg, d_bdc_error.
  ENDLOOP.

  IF gt_ztspfidt04upd[] IS NOT INITIAL.
    MODIFY ztspfidt04 FROM TABLE gt_ztspfidt04upd.
    CLEAR gt_ztspfidt04upd[].
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " F_EXECUTE_ABMA

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_ITAB
*&---------------------------------------------------------------------*
FORM f_collect_itab USING fu_adjust2.
  MOVE-CORRESPONDING gt_out TO gt_ztspfidt04upd.
  gt_ztspfidt04upd-gsber = p_gsber.
  gt_ztspfidt04upd-spmon = p_spmon.
  gt_ztspfidt04upd-depval = fu_adjust2.   "gt_out-depreval.
  gt_ztspfidt04upd-waers = 'IDR'.
  APPEND gt_ztspfidt04upd. CLEAR gt_ztspfidt04upd.
ENDFORM.                    " F_COLLECT_ITAB

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'NDS'.
        screen-active  = 0.
        MODIFY SCREEN.
      WHEN 'FLN'.
        CASE 'X'.
          WHEN p_but2 OR p_but3 OR p_but4.
            screen-active  = 0.
            MODIFY SCREEN.
          WHEN OTHERS.
        ENDCASE.
      WHEN 'GSB'.
        CASE 'X'.
          WHEN p_but1.
            screen-active  = 0.
            MODIFY SCREEN.
          WHEN OTHERS.
        ENDCASE.
      WHEN 'BUT'.
      WHEN OTHERS.
        IF p_but1 = 'X' OR p_but2 = 'X'.
          screen-active  = 0.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.
*    IF screen-group1 = 'FRM'.
*      screen-input  = 0.
*      MODIFY SCREEN.
*    ENDIF.
    IF screen-group1 = 'NDS'.
      screen-active  = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  CASE 'X'.
    WHEN p_but1.
      IF p_flnme IS INITIAL.
        PERFORM f_error_selection_screen USING 'FLN' '0'.
      ENDIF.
    WHEN p_but2 OR p_but3 OR p_but3.
      IF p_gsber IS INITIAL.
        PERFORM f_error_selection_screen USING 'GSB' '0'.
      ENDIF.
    WHEN p_but3.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group fu_error.
  DATA: lv_mess(100).

  CASE fu_error.
    WHEN '0'.
      lv_mess = 'Fill in all required entry fields'.
    WHEN '1'.
      lv_mess = 'Error in Posting date'.
  ENDCASE.
  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input  = 1.
    ELSE.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_FILENAME_F4
*&---------------------------------------------------------------------*
FORM f_filename_f4  CHANGING fc_filename.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = sy-cprog
      dynpro_number = '1000'
    IMPORTING
      file_name     = fc_filename.
ENDFORM.                    " F_FILENAME_F4

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_FROM_EXCEL
*&---------------------------------------------------------------------*
FORM f_upload_from_excel .
  CALL METHOD zcl_util=>m_upload_excel_to_itab_v2
    EXPORTING
      pvi_table = 'ZTSPFIST01'
      pvi_bcol  = 1
      pvi_ecol  = 4
      pvi_brow  = 2
      pvi_erow  = 60000
      pv_filenm = p_flnme
    IMPORTING
      pto_data  = gt_upload[].

  IF gt_upload[] IS INITIAL.
    MESSAGE 'No data upload' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ELSE.
    LOOP AT gt_upload ASSIGNING <fs_upload>.
      CONDENSE <fs_upload>-kostl.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_upload>-kostl
        IMPORTING
          output = <fs_upload>-kostl.
    ENDLOOP.
  ENDIF.

  SELECT * INTO TABLE gt_cskt
    FROM cskt FOR ALL ENTRIES IN gt_upload
    WHERE spras = sy-langu
      AND kokrs = gc_kokrs
      AND kostl = gt_upload-kostl.

  SORT gt_cskt BY kostl.
  SORT gt_upload BY kostl gjahr.
  LOOP AT gt_upload ASSIGNING <fs_upload>.
    CLEAR gt_cskt.
    READ TABLE gt_cskt WITH KEY kostl = <fs_upload>-kostl
                       BINARY SEARCH.
    <fs_upload>-ktext = gt_cskt-ktext.
  ENDLOOP.
ENDFORM.                    " F_UPLOAD_FROM_EXCEL

*&---------------------------------------------------------------------*
*&      Form  F_MAINTAIN_ZTSPFIDT02
*&---------------------------------------------------------------------*
FORM f_maintain_ztspfidt02 .
  DATA: ls_selection TYPE vimsellist,
        lv_fieldname TYPE vimsellist-viewfield,
        lt_seltab    TYPE STANDARD TABLE OF vimsellist.

  CONSTANTS: lc_and   TYPE   char3   VALUE 'AND'.

  lv_fieldname = 'FEVOR'.
  CALL FUNCTION 'VIEW_RANGETAB_TO_SELLIST'
    EXPORTING
      fieldname          = lv_fieldname
      append_conjunction = lc_and
    TABLES
      sellist            = lt_seltab
      rangetab           = s_fevor.

  ls_selection-viewfield = 'WERKS'.
  ls_selection-value = p_gsber.
  ls_selection-and_or = 'AND'.
  ls_selection-operator = 'EQ'.
  APPEND ls_selection TO lt_seltab.

  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action      = 'U' "for Update
      view_name   = 'ZTSPFIDT02'
*     complex_selconds_used = 'X'
    TABLES
      dba_sellist = lt_seltab
    EXCEPTIONS
      OTHERS      = 1.
ENDFORM.                    " F_MAINTAIN_ZTSPFIDT02

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TABLE
*&---------------------------------------------------------------------*
FORM f_save_table .
  LOOP AT gt_upload.
    MOVE-CORRESPONDING gt_upload TO gt_ztspfidt01.
    APPEND gt_ztspfidt01.
  ENDLOOP.

  IF gt_ztspfidt01[] IS NOT INITIAL.
    MODIFY ztspfidt01 FROM TABLE gt_ztspfidt01.
  ENDIF.
ENDFORM.                    " F_SAVE_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_SUMMARIES_GR
*&---------------------------------------------------------------------*
FORM f_summaries_gr .
  DATA: lt_marm       TYPE TABLE OF marm WITH HEADER LINE,
        lt_marm1      TYPE TABLE OF marm WITH HEADER LINE,
        lt_marm2      TYPE TABLE OF marm WITH HEADER LINE,
        lt_marc       TYPE TABLE OF marc WITH HEADER LINE,
        lt_makt       TYPE TABLE OF makt WITH HEADER LINE,
        lt_gr         TYPE TABLE OF ty_gr WITH HEADER LINE,
        lt_ztspfidt03 TYPE TABLE OF ztspfidt03 WITH HEADER LINE.

  LOOP AT gt_mseg.
    IF gt_mseg-aufnr(4) = '0008'.
      DELETE gt_mseg.
      CONTINUE.
    ENDIF.
    IF gt_mseg-shkzg = 'H'.
      gt_mseg-menge = gt_mseg-menge * -1.
    ENDIF.
    gt_gr-werks = gt_mseg-werks.
    gt_gr-matnr = gt_mseg-matnr.
    gt_gr-menge = gt_mseg-menge.
    gt_gr-meins = gt_mseg-meins.
    COLLECT gt_gr.
  ENDLOOP.

  IF gt_gr[] IS NOT INITIAL.
    IF p_but4 = 'X'.
      SELECT matnr maktx
        INTO CORRESPONDING FIELDS OF TABLE lt_makt
        FROM makt FOR ALL ENTRIES IN gt_gr
        WHERE matnr = gt_gr-matnr
          AND spras = sy-langu.
    ENDIF.

    SELECT matnr werks fevor
      INTO CORRESPONDING FIELDS OF TABLE lt_marc
      FROM marc FOR ALL ENTRIES IN gt_gr
      WHERE matnr = gt_gr-matnr
        AND werks = gt_gr-werks
        AND beskz IN ('E','X').

    lt_gr[] = gt_gr[].
    SORT lt_gr BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_gr COMPARING matnr.
    SELECT matnr meinh umrez umren
      INTO CORRESPONDING FIELDS OF TABLE lt_marm
      FROM marm FOR ALL ENTRIES IN lt_gr
      WHERE matnr = lt_gr-matnr.

    LOOP AT lt_marm.
      CASE lt_marm-meinh.
        WHEN 'TAB' OR 'KAP' OR 'CAP' OR 'SAC'. "OR 'BOT' OR 'BT'.
          MOVE-CORRESPONDING lt_marm TO lt_marm1.
          APPEND lt_marm1.
        WHEN 'MG' OR 'G' OR 'ML' OR 'KG'.
          MOVE-CORRESPONDING lt_marm TO lt_marm2.
          APPEND lt_marm2.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

    SELECT matnr meinh umren
      INTO CORRESPONDING FIELDS OF TABLE lt_ztspfidt03
      FROM ztspfidt03 FOR ALL ENTRIES IN lt_gr
      WHERE matnr = lt_gr-matnr.

    LOOP AT lt_ztspfidt03.
      READ TABLE lt_marm WITH KEY matnr = lt_ztspfidt03-matnr
                                  meinh = lt_ztspfidt03-meinh
                                  TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      CASE lt_ztspfidt03-meinh.
        WHEN 'TAB' OR 'KAP' OR 'CAP' OR 'SAC'. "OR 'BOT' OR 'BT'.
          MOVE-CORRESPONDING lt_ztspfidt03 TO lt_marm1.
          APPEND lt_marm1.
        WHEN 'MG' OR 'G' OR 'ML' OR 'KG'.
          MOVE-CORRESPONDING lt_ztspfidt03 TO lt_marm2.
          APPEND lt_marm2.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

    SORT: gt_gr    BY matnr werks,
          lt_marc  BY matnr werks,
          lt_makt  BY matnr,
          lt_marm1 BY matnr,
          lt_marm2 BY matnr.

    LOOP AT gt_gr ASSIGNING <fs_gr>.
      CLEAR: lt_makt,lt_marc,lt_marm1,lt_marm2.
      READ TABLE lt_makt WITH KEY matnr = <fs_gr>-matnr.
      READ TABLE lt_marc WITH KEY matnr = <fs_gr>-matnr.
      READ TABLE lt_marm1 WITH KEY matnr = <fs_gr>-matnr.
      READ TABLE lt_marm2 WITH KEY matnr = <fs_gr>-matnr.

      <fs_gr>-fevor   = lt_marc-fevor.
      <fs_gr>-konve   = lt_marm1-umren.
      IF <fs_gr>-konve IS INITIAL .
        <fs_gr>-konve = 1.
      ENDIF.
      <fs_gr>-qtykonv = <fs_gr>-menge * <fs_gr>-konve.
      <fs_gr>-bobot   = lt_marm2-umren.
      <fs_gr>-uombob  = lt_marm2-meinh.

      CASE <fs_gr>-uombob.
        WHEN 'MG'.
          <fs_gr>-qtybob  = <fs_gr>-bobot / 1000000.
        WHEN 'G'.
          <fs_gr>-qtybob  = <fs_gr>-bobot / 1000.
        WHEN 'ML'.
          <fs_gr>-qtybob  = <fs_gr>-bobot / 1000.
        WHEN 'KG'.
          <fs_gr>-qtybob  = <fs_gr>-bobot / 1.
      ENDCASE.

      PERFORM f_collect_produce USING p_spmon
                                      <fs_gr>-fevor
                                      <fs_gr>-matnr
                                      <fs_gr>-werks
                                      <fs_gr>-menge
                                      <fs_gr>-qtykonv
                                      <fs_gr>-qtybob
                                      lt_makt-maktx.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_SUMMARIES_GR

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_PRODUCE
*&---------------------------------------------------------------------*
FORM f_collect_produce  USING    fu_spmon
                                 fu_fevor
                                 fu_matnr
                                 fu_werks
                                 fu_menge
                                 fu_qtykonv
                                 fu_qtybob
                                 fu_maktx.
  DATA: lv_year TYPE numc4.

  lv_year = fu_spmon(4).

  LOOP AT gt_ztspfidt02 WHERE fevor = fu_fevor
                          AND werks = fu_werks.
    READ TABLE gt_ztspfidt01 WITH KEY gjahr = lv_year
                                      kostl = gt_ztspfidt02-kostl.
    IF sy-subrc = 0.
      gt_produce-fevor = gt_ztspfidt02-fevor.
      gt_produce-kostl = gt_ztspfidt02-kostl.
      gt_produce-meins = gt_ztspfidt01-meins.
      CASE gt_produce-meins.
        WHEN 'KG'.
          gt_produce-qty = fu_qtybob.
        WHEN 'BT'.
          gt_produce-qty = fu_menge.
        WHEN OTHERS.
          gt_produce-qty = fu_qtykonv.
      ENDCASE.
      COLLECT gt_produce. "CLEAR gt_produce.
    ENDIF.

    IF p_but4 = 'X'.
      gt_produce2-werks = fu_werks.
      gt_produce2-matnr = fu_matnr.
      gt_produce2-maktx = fu_maktx.
      gt_produce2-spmon = fu_spmon.
      gt_produce2-fevor = fu_fevor.
      gt_produce2-kostl = gt_produce-kostl.
      gt_produce2-meins = gt_produce-meins.
*      gt_produce2-qty   = gt_produce-qty.
      gt_produce2-qty   = round( val = gt_produce-qty dec = 0 ).
      COLLECT gt_produce2. CLEAR gt_produce2.
    ENDIF.

    CLEAR gt_produce.
  ENDLOOP.
ENDFORM.                    " F_COLLECT_PRODUCE

*&---------------------------------------------------------------------*
*&      Form  F_GET_RETIRE
*&---------------------------------------------------------------------*
FORM f_get_retire  USING    fu_ndjar
                            fu_aktiv
                   CHANGING fc_retire.
  CALL FUNCTION 'MONTH_PLUS_DETERMINE'
    EXPORTING
      months  = fu_ndjar
      olddate = fu_aktiv
    IMPORTING
      newdate = fc_retire.
ENDFORM.                    " F_GET_RETIRE

*&---------------------------------------------------------------------*
*&      Form  F_GET_SISAUMUR
*&---------------------------------------------------------------------*
FORM f_get_sisaumur  USING    fu_spmon
                              fu_retire
                              fu_aktiv
                     CHANGING fc_sisaumur.
  DATA: lv_datef  TYPE datum,
        lv_datet  TYPE datum,
        lv_days	  LIKE vtbbewe-atage,
        lv_months	LIKE vtbbewe-atage,
        lv_years  LIKE vtbbewe-atage.

  CONCATENATE fu_spmon '01' INTO lv_datef.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_datef
    IMPORTING
      last_day_of_month = lv_datet.

  CALL FUNCTION 'FIMA_DAYS_AND_MONTHS_AND_YEARS'
    EXPORTING
      i_date_from = fu_aktiv    "lv_datet
      i_date_to   = fu_retire
    IMPORTING
      e_days      = lv_days.

  fc_sisaumur = lv_days / 365.
ENDFORM.                    " F_GET_SISAUMUR

*&---------------------------------------------------------------------*
*&      Form  F_GET_SISAUMUR2
*&---------------------------------------------------------------------*
FORM f_get_sisaumur2  USING   fu_date1
                              fu_retire
                              fu_aktiv
                     CHANGING fc_sisaumur.
  DATA: lv_sisa    TYPE dec_16_05_s,
        lv_days1   LIKE vtbbewe-atage,
        lv_months1 LIKE vtbbewe-atage,
        lv_years1  LIKE vtbbewe-atage,
        lv_days2   LIKE vtbbewe-atage,
        lv_months2 LIKE vtbbewe-atage,
        lv_years2  LIKE vtbbewe-atage.

  CALL FUNCTION 'FIMA_DAYS_AND_MONTHS_AND_YEARS'
    EXPORTING
      i_date_from = fu_aktiv
      i_date_to   = fu_retire
    IMPORTING
      e_days      = lv_days1
      e_months    = lv_months1
      e_years     = lv_years1.

  CALL FUNCTION 'FIMA_DAYS_AND_MONTHS_AND_YEARS'
    EXPORTING
      i_date_from = fu_aktiv
      i_date_to   = fu_date1
    IMPORTING
      e_days      = lv_days2
      e_months    = lv_months2
      e_years     = lv_years2.

  lv_sisa = ( lv_days1 / 365 ) - ( lv_days2 / 365 ).
  fc_sisaumur = round( val = lv_sisa dec = 2 ).
ENDFORM.                    " F_GET_SISAUMUR2

*&---------------------------------------------------------------------*
*&      Form  F_STYLE_CELL
*&---------------------------------------------------------------------*
FORM f_style_cell  USING    fu_flag fu_fieldname fu_fieldname1
                   CHANGING fc_celltab  TYPE lvc_t_styl.
  DATA : lt_celltab   TYPE lvc_t_styl WITH HEADER LINE.

  CLEAR : lt_celltab[], lt_celltab.

  IF fu_flag IS NOT INITIAL.
    lt_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
  ELSE.
    lt_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  ENDIF.

  CLEAR fc_celltab[].

  IF fu_fieldname1 IS NOT INITIAL.
    lt_celltab-fieldname = fu_fieldname1.
    APPEND lt_celltab.
  ENDIF.
  lt_celltab-fieldname = fu_fieldname.
  APPEND lt_celltab.

  INSERT LINES OF lt_celltab INTO TABLE fc_celltab.
ENDFORM.                    " F_STYLE_CELL

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1664   text
*----------------------------------------------------------------------*
FORM f_select  USING    fu_check.
  DATA : ls_fieldcatalog    TYPE lvc_t_fcat WITH HEADER LINE.
  DATA : lv_style    TYPE lvc_s_styl-style,
         lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl,
         lv_tabix    TYPE sy-tabix.

  DATA : ls_out             LIKE LINE OF gt_out.

  CALL METHOD g_grid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = ls_fieldcatalog[].

  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'CHKBOX'.
  IF sy-subrc = 0.
    IF ls_fieldcatalog-edit IS NOT INITIAL.
      LOOP AT gt_out INTO ls_out.
        lv_tabix = sy-tabix.

        READ TABLE ls_out-style INTO ls_stylerow
                                WITH KEY fieldname = 'CHKBOX'.
        IF sy-subrc = 0 AND
            ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          CONTINUE.
        ENDIF.

        ls_out-chkbox = fu_check.
        MODIFY gt_out FROM ls_out.
        CLEAR ls_out.
      ENDLOOP.
    ENDIF.
    CALL METHOD g_grid->refresh_table_display( ).
  ENDIF.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_GET_MSEG
*&---------------------------------------------------------------------*
FORM f_get_mseg .
  SELECT a~mblnr a~mjahr zeile bwart matnr werks lgort pprctr
         menge meins shkzg aufnr
    INTO CORRESPONDING FIELDS OF TABLE gt_mseg
    FROM mkpf AS a JOIN mseg AS b ON a~mblnr = b~mblnr AND
                                     a~mjahr = b~mjahr
    WHERE a~budat IN gr_budat
      AND a~mjahr = p_spmon(4)
*      AND a~vgart = 'WF'
*      AND a~blart = 'WE'
*      AND a~blaum = 'PR'
*      AND a~tcode2 = 'MIGO_GO'
      AND b~bwart IN ('101','102')
      AND b~werks = p_gsber
      AND b~lifnr = space.
*      AND b~prctr = 'SFG'
*      AND b~matnr IN lr_matnr.

  PERFORM f_summaries_gr.

*  IF gt_produce[] IS INITIAL.
*    MESSAGE 'No Data' TYPE 'I' DISPLAY LIKE 'E'.
*    STOP.
*  ENDIF.
ENDFORM.                    " F_GET_MSEG

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA4
*&---------------------------------------------------------------------*
FORM f_get_data4 .
  SELECT * INTO TABLE gt_ztspfidt01
    FROM ztspfidt01 WHERE gjahr = p_spmon(4).

  SELECT * INTO TABLE gt_ztspfidt02
    FROM ztspfidt02 WHERE werks = p_gsber.

  PERFORM f_get_mseg.
ENDFORM.                    " F_GET_DATA4

*&---------------------------------------------------------------------*
*&      Form  F_GET_PARAMETER
*&---------------------------------------------------------------------*
FORM f_get_parameter  TABLES   ft_bzdat STRUCTURE range_date
                      USING    fu_spmon
                      CHANGING fc_gjahr.
  DATA: ls_bzdat  TYPE range_date.

  fc_gjahr = fu_spmon(4).
  ls_bzdat-sign   = 'I'.
  ls_bzdat-option = 'BT'.
  CONCATENATE fu_spmon(4) '0101' INTO ls_bzdat-low.
  CONCATENATE fu_spmon '01' INTO ls_bzdat-high.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ls_bzdat-high
    IMPORTING
      last_day_of_month = ls_bzdat-high.
  APPEND ls_bzdat TO ft_bzdat.
ENDFORM.                    " F_GET_PARAMETER

*&---------------------------------------------------------------------*
*&      Form  F_GET_ANEP
*&---------------------------------------------------------------------*
FORM f_get_anep  TABLES   ft_bzdat STRUCTURE range_date
                 USING    fu_gjahr.
  DATA: lt_anep TYPE TABLE OF anep WITH HEADER LINE,
        lt_bkpf TYPE TABLE OF bkpf WITH HEADER LINE.

  DATA: lr_budat TYPE RANGE OF budat,
        ls_budat LIKE LINE OF lr_budat.

  CONCATENATE p_spmon '01' INTO ls_budat-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ls_budat-low
    IMPORTING
      last_day_of_month = ls_budat-high
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  SELECT bukrs anln1 anln2 gjahr lnran afabe zujhr zucod
         belnr bzdat bwasl anbtr
    INTO CORRESPONDING FIELDS OF TABLE lt_anep
    FROM anep FOR ALL ENTRIES IN gt_anlz
      WHERE bukrs  = gt_anlz-bukrs
        AND anln1  = gt_anlz-anln1
        AND anln2  = gt_anlz-anln2
        AND gjahr  = fu_gjahr
        AND afabe  = '01'
        AND bzdat IN ft_bzdat.

  IF lt_anep[] IS NOT INITIAL.
    SELECT *
      FROM bkpf
      INTO CORRESPONDING FIELDS OF TABLE lt_bkpf
      FOR ALL ENTRIES IN lt_anep
      WHERE bukrs = lt_anep-bukrs
        AND belnr = lt_anep-belnr
        AND gjahr = lt_anep-gjahr.
  ENDIF.

  SORT: lt_anep BY bukrs belnr gjahr,
        lt_bkpf BY bukrs belnr gjahr.
  "Summaries ANEP
  LOOP AT lt_anep.
    IF lt_anep-bwasl(1) = '1' OR
      lt_anep-bwasl(1) = '2' OR
      lt_anep-bwasl(1) = '3'.
      READ TABLE lt_bkpf WITH KEY bukrs = lt_anep-bukrs
                                  belnr = lt_anep-belnr
                                  gjahr = lt_anep-gjahr
                         BINARY SEARCH.
      IF sy-subrc = 0.
        IF lt_anep-anln1 = '131900003693'.
          IF lt_bkpf-budat GT ls_budat-high.
            CONTINUE.
          ENDIF.
        ELSE.
          IF lt_bkpf-budat GE ls_budat-high.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDIF.

      MOVE-CORRESPONDING lt_anep TO gt_anep.
      CLEAR: gt_anep-lnran,gt_anep-afabe,gt_anep-zujhr,
             gt_anep-zucod,gt_anep-bzdat,gt_anep-belnr,
             gt_anep-bwasl.
      COLLECT gt_anep.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_ANEP
