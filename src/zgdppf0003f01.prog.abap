*----------------------------------------------------------------------*
*   INCLUDE ZIBMFMMATDOCPRINTTEMPF01                                   *
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
* Get header
  SELECT SINGLE mblnr mjahr budat cpudt cputm usnam
    FROM mkpf
    INTO CORRESPONDING FIELDS OF wa_hd
    WHERE mblnr EQ p_mblnr AND
          mjahr EQ p_mjahr.

* Get detail
  IF sy-subrc EQ 0.
    SELECT mblnr mjahr zeile aufnr charg matnr menge meins werks lgort
      FROM mseg
      INTO CORRESPONDING FIELDS OF TABLE i_dt
      WHERE mblnr EQ p_mblnr AND
            mjahr EQ p_mjahr AND
            bwart EQ '101'.

    IF sy-subrc EQ 0.
      READ TABLE i_dt INTO wa_dt INDEX 1.
      wa_hd-aufnr = wa_dt-aufnr.
      wa_hd-charg = wa_dt-charg.
      wa_hd-matnr = wa_dt-matnr.
      wa_hd-werks = wa_dt-werks.

* Get Schedule no.
      SELECT SINGLE schednr
        FROM zgdppdt0008
        INTO wa_hd-schednr
        WHERE aufnr EQ wa_hd-aufnr.

* Get Prod. Scheduler
      SELECT SINGLE fevor
        FROM marc
        INTO wa_hd-fevor
        WHERE matnr EQ wa_hd-matnr AND
              werks EQ wa_hd-werks.
    ENDIF.
  ENDIF.
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
  CLEAR: wa_dt.
  LOOP AT i_dt INTO wa_dt.

* Material Description
    SELECT SINGLE maktg
      FROM makt
      INTO wa_dt-maktg
      WHERE spras EQ sy-langu AND
            matnr EQ wa_dt-matnr.

* Exp. Date
    SELECT SINGLE vfdat
      FROM mch1
      INTO wa_dt-vfdat
      WHERE matnr EQ wa_dt-matnr AND
            charg EQ wa_dt-charg.

* Unit Convertion
    SELECT SINGLE meinh umrez umren
      FROM marm
      INTO (wa_dt-meinh, wa_dt-umrez, wa_dt-umren)
      WHERE matnr EQ wa_dt-matnr AND
            meinh EQ 'KAR'.

    IF sy-subrc NE 0.
      SELECT SINGLE meinh umrez
        FROM marm
        INTO (wa_dt-meinh, wa_dt-umrez)
        WHERE matnr EQ wa_dt-matnr.
* Div Unit Conversion
      wa_dt-divme = wa_dt-menge DIV wa_dt-umrez.
* Mod Unit Conversion
      wa_dt-modme = wa_dt-menge MOD wa_dt-umrez.
    ELSE.
      wa_dt-modme = wa_dt-umrez.
      wa_dt-divme = wa_dt-umren.
    ENDIF.

    SHIFT wa_dt-divme LEFT DELETING LEADING space.
    SHIFT wa_dt-modme LEFT DELETING LEADING space.

    IF wa_dt-werks = '0101' OR wa_dt-werks = '0102'.
      PERFORM f_konversi USING wa_dt-matnr
                               wa_dt-menge
                               wa_dt-meinh
                               wa_dt-umrez
                               wa_dt-umren
                         CHANGING wa_dt-konversi.
      IF wa_dt-konversi IS NOT INITIAL.
        wa_hd-konversi = wa_dt-konversi.
      ENDIF.
    ENDIF.

    MODIFY i_dt FROM wa_dt TRANSPORTING maktg vfdat meinh umrez
                                        divme modme konversi.
    CLEAR: wa_dt.
  ENDLOOP.

* Get notes
  SELECT SINGLE ltxa1
    FROM afru
    INTO wa_hd-ltxa1
    WHERE aufnr EQ wa_hd-aufnr AND
          ltxa1 NE space.
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
  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.
  IF d_frm_subrc IS INITIAL.
*      call the generated function module of the form
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        wa_hd              = wa_hd
      TABLES
        i_dt               = i_dt.
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

ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  F_KONVERSI
*&---------------------------------------------------------------------*
FORM f_konversi  USING    fu_matnr
                          fu_menge
                          fu_meinh
                          fu_umrez
                          fu_umren
                 CHANGING fc_konversi.
  DATA: ls_marm_kar TYPE marm,
        ls_marm_fbx TYPE marm,
        ls_marm_sw  TYPE marm,
        lv_mod  TYPE mseg-menge,
        lv_div  TYPE mseg-menge,
        lv_modt TYPE char10,
        lv_divt TYPE char10,
        lv_uom(2), lv_uom2(2).

  SELECT SINGLE matnr meinh umrez
    INTO CORRESPONDING FIELDS OF ls_marm_kar
    FROM marm WHERE matnr = fu_matnr
                AND meinh = 'KAR'.

  SELECT SINGLE matnr meinh umrez
    INTO CORRESPONDING FIELDS OF ls_marm_fbx
    FROM marm WHERE matnr = fu_matnr
                AND meinh = 'FBX'.

  SELECT SINGLE matnr meinh umrez
    INTO CORRESPONDING FIELDS OF ls_marm_sw
    FROM marm WHERE matnr = fu_matnr
                AND meinh = 'SW'.

  IF ls_marm_kar IS NOT INITIAL.
    lv_div = fu_menge DIV ls_marm_kar-umrez.
    lv_mod = fu_menge MOD ls_marm_kar-umrez.
    lv_uom = 'OB'.
  ELSE.
    CLEAR lv_div.
    lv_mod = fu_menge.
  ENDIF.

  IF ls_marm_sw IS NOT INITIAL.
    DIVIDE lv_mod BY ls_marm_sw-umrez.
    lv_uom2 = 'SW'.
  ELSEIF ls_marm_fbx IS NOT INITIAL.
    DIVIDE lv_mod BY ls_marm_fbx-umrez.
    lv_uom2 = 'FB'.
  ENDIF.

  IF lv_div IS NOT INITIAL.
    WRITE lv_div TO lv_divt DECIMALS 0.
    CONDENSE lv_divt.
  ENDIF.

  IF lv_mod IS NOT INITIAL.
    WRITE lv_mod TO lv_modt DECIMALS 0.
    CONDENSE lv_modt.
  ENDIF.

  IF lv_modt IS INITIAL AND lv_divt IS NOT INITIAL.
*    CONCATENATE 'Convertion Quantity:' lv_divt 'OB'
    CONCATENATE 'Convertion Quantity:' lv_divt lv_uom
      INTO fc_konversi SEPARATED BY space.
  ELSEIF lv_divt IS INITIAL AND lv_modt IS NOT INITIAL.
*    CONCATENATE 'Convertion Quantity:' lv_modt 'FB'
    CONCATENATE 'Convertion Quantity:' lv_modt lv_uom2
      INTO fc_konversi SEPARATED BY space.
  ELSEIF lv_divt IS NOT INITIAL AND lv_modt IS NOT INITIAL.
*    CONCATENATE 'Convertion Quantity:' lv_divt 'OB' '+' lv_modt 'FB'
    CONCATENATE 'Convertion Quantity:' lv_divt lv_uom '+' lv_modt lv_uom2
      INTO fc_konversi SEPARATED BY space.
  ELSE.
    CLEAR fc_konversi.
  ENDIF.
ENDFORM.                    " F_KONVERSI
