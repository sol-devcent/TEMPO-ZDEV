*----------------------------------------------------------------------*
*   INCLUDE ZWM_PRINT_TOF01
*----------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS handle_onf4 FOR EVENT onf4 OF cl_gui_alv_grid
      IMPORTING e_fieldname es_row_no e_fieldvalue er_event_data.
ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.
  METHOD handle_onf4.
    DATA: lt_values TYPE STANDARD TABLE OF ddshretval,
          ls_value  TYPE ddshretval.

    BREAK-POINT.
    IF e_fieldname = 'LPRIO'.
      MESSAGE 'TESSSSS' TYPE 'I'.
*      * Implement your custom F4 logic here
*      * Populate lt_values with your desired F4 entries
*      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*        EXPORTING
*          retfield        = 'FIELDNAME_IN_LT_VALUES'
*          window_title    = 'Custom F4 Help'
*          value_org       = 'S'
*        TABLES
*          value_tab       = lt_values[]
*          return_tab      = lt_values[]
*        EXCEPTIONS
*          OTHERS          = 1.
*
*      IF sy-subrc = 0.
*        READ TABLE lt_values INTO ls_value INDEX 1.
*        IF sy-subrc = 0.
*          * Update the ALV field with the selected value
*          * You'll need to get the internal table data and update the specific cell
*          * Then refresh the ALV grid display
*        ENDIF.
*      ENDIF.
*
*      er_event_data->m_event_handled = 'X'. " Crucial for custom F4
    ENDIF.
  ENDMETHOD.
ENDCLASS.

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  DATA : return  TYPE STANDARD TABLE OF bapiret2,
         ls_pall LIKE LINE OF gt_pall.

  DATA : lv_id1(30),
         lv_id2(30),
         lv_id3(30),
         lv_zeugn   TYPE p DECIMALS 0.

  SELECT *
    FROM t329d
    INTO CORRESPONDING FIELDS OF TABLE gt_t329d
    WHERE lgnum = pa_lgnum.

  SELECT *
    FROM zwmdt013
    INTO CORRESPONDING FIELDS OF TABLE gt_013
    WHERE lgnum   = pa_lgnum
      AND process = 'PRINT_TO'.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      defaults = default
    TABLES
      return   = return.

  SELECT SINGLE *
    FROM t329p
    INTO CORRESPONDING FIELDS OF gs_t329p
    WHERE lgnum = pa_lgnum
      AND spool = '03'.

  CONCATENATE sy-uname 'XRLDRI' INTO lv_id1.
  IMPORT xrldri TO gt_xrldri FROM MEMORY ID lv_id1.
  CONCATENATE sy-uname 'XRLDRH' INTO lv_id2.
  IMPORT xrldrh TO gt_xrldrh FROM MEMORY ID lv_id2.
  CONCATENATE sy-uname 'LIKP' INTO lv_id3.
  IMPORT gt_xlikp TO gt_xlikp FROM MEMORY ID lv_id3.

  FREE MEMORY ID : lv_id1, lv_id2, lv_id3.

  SELECT *
    FROM ztdnsddt012
    INTO CORRESPONDING FIELDS OF TABLE gt_012.

  SELECT *
    FROM tprit
    INTO CORRESPONDING FIELDS OF TABLE gt_tprit
    WHERE spras = sy-langu.

  IF pa_lgnum = '190'.
    DO 1000 TIMES.
      ADD 1 TO lv_zeugn.
      ls_pall-pallet  = lv_zeugn.
      APPEND ls_pall TO gt_pall.
      CLEAR ls_pall.
    ENDDO.
  ENDIF.

  IF sy-uname = 'TDS_DEV01'.
    gv_testrun = 'X'.
  ENDIF.

ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA : ls_ltak   LIKE LINE OF gt_ltak,
         ls_ltap   LIKE LINE OF gt_ltap,
         ls_xrldri TYPE rldri,
         ls_xrldrh TYPE rldrh.

  DATA : lt_xlikp TYPE STANDARD TABLE OF ty_xlikp,
         lt_xlips TYPE STANDARD TABLE OF lips.

  DATA : lr_vltyp TYPE RANGE OF ltap_vltyp,
         ls_vltyp LIKE LINE OF lr_vltyp.

  DATA: lv_tknum    TYPE vttp-tknum,
        ls_stylerow TYPE lvc_s_styl.


  IF pa_lprio = 'X' AND pa_lgnum = 'C40'.
    SELECT a~tknum a~tpnum a~vbeln c~lgnum c~tanum c~tapri AS lprio c~lznum
      INTO CORRESPONDING FIELDS OF TABLE gt_lprio
      FROM vttp AS a "JOIN likp AS b ON a~vbeln = b~vbeln
                     JOIN ltak AS c ON a~vbeln = c~vbeln
      WHERE a~tknum IN so_tknum
        AND c~lgnum = pa_lgnum.

    SORT gt_lprio BY lgnum tknum lznum tanum vbeln.
    LOOP AT gt_lprio INTO DATA(ls_lprio).
      IF lv_tknum = ls_lprio-tknum.
        lv_tknum = ls_lprio-tknum.
        CLEAR ls_stylerow.
        ls_stylerow-fieldname = 'CHECK'.
        ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
        APPEND ls_stylerow TO ls_lprio-style.
        CLEAR ls_stylerow.
        ls_stylerow-fieldname = 'LPRIO'.
        ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
        APPEND ls_stylerow TO ls_lprio-style.
        MODIFY gt_lprio FROM ls_lprio TRANSPORTING style.
      ELSE.
        lv_tknum = ls_lprio-tknum.
      ENDIF.
    ENDLOOP.

  ELSE.
    IF pa_lgnum(1) = 'C'.
      CASE pa_drukz.
        WHEN '48'.
          IF so_tknum[] IS INITIAL.
            IF pa_akhir IS INITIAL.
              SELECT lgnum tanum bdatu bzeit mblnr mjahr benum drukz druck lznum
                vbeln tapri queue lgtor refnr bwlvs tbnum
                FROM ltak
                INTO TABLE gt_ltak
                WHERE lgnum = pa_lgnum
                  AND tanum IN so_tanum
                  AND mblnr IN so_mblnr
                  AND kquit = space
                  AND lznum = space.
            ELSE.
              SELECT lgnum tanum bdatu bzeit mblnr mjahr benum drukz druck lznum
                vbeln tapri queue lgtor refnr bwlvs tbnum
                FROM ltak
                INTO TABLE gt_ltak
                WHERE lgnum = pa_lgnum
                  AND tanum IN so_tanum
                  AND mblnr IN so_mblnr
                  AND kquit = 'X'
                  AND lznum = space.
            ENDIF.
          ELSE.
            PERFORM f_get_data_48_shipment.
          ENDIF.
        WHEN OTHERS.
          IF pa_form IS INITIAL.
            SELECT lgnum tanum bdatu bzeit mblnr mjahr benum drukz druck lznum
              vbeln tapri queue lgtor refnr bwlvs tbnum
              FROM ltak
              INTO TABLE gt_ltak
              WHERE lgnum = pa_lgnum
                AND tanum IN so_tanum
                AND mblnr IN so_mblnr
                AND druck = pa_druck.
          ELSE.
            SELECT lgnum tanum bdatu bzeit mblnr mjahr benum drukz druck lznum
              vbeln tapri queue lgtor refnr bwlvs tbnum
              FROM ltak
              INTO TABLE gt_ltak
              WHERE lgnum = pa_lgnum
                AND tanum IN so_tanum
                AND mblnr IN so_mblnr.
          ENDIF.
      ENDCASE.
    ELSE.
      IF pa_form IS INITIAL.
        SELECT lgnum tanum bdatu bzeit mblnr mjahr benum drukz druck lznum
          vbeln tapri queue lgtor refnr bwlvs tbnum
          FROM ltak
          INTO TABLE gt_ltak
          WHERE lgnum = pa_lgnum
            AND tanum IN so_tanum
            AND bdatu IN so_bdatu
            AND mblnr IN so_mblnr
            AND druck = pa_druck.
      ELSE.
        IF pa_lgnum(2) = '38'.
          IF gt_xlikp[] IS INITIAL.
            READ TABLE gt_xrldrh INTO ls_xrldrh INDEX 1.
            IF sy-subrc = 0.
              SELECT lgnum tanum bdatu bzeit mblnr mjahr benum drukz druck lznum
                vbeln tapri queue lgtor refnr bwlvs tbnum
                FROM ltak
                INTO TABLE gt_ltak
                WHERE lgnum = ls_xrldrh-lgnum
                  AND tanum = ls_xrldrh-tanum.
              IF sy-subrc <> 0.
                LOOP AT gt_xrldrh INTO ls_xrldrh.
                  MOVE-CORRESPONDING ls_xrldrh TO ls_ltak.
                  APPEND ls_ltak TO gt_ltak.
                  CLEAR ls_ltak.
                ENDLOOP.
              ENDIF.
              IF gt_ltak[] IS NOT INITIAL.
                SELECT *
                  FROM likp
                  INTO CORRESPONDING FIELDS OF TABLE gt_xlikp
                  FOR ALL ENTRIES IN gt_ltak
                  WHERE vbeln = gt_ltak-vbeln.
              ENDIF.
            ENDIF.
          ELSE.
            DELETE gt_xlikp WHERE check IS INITIAL.
            lt_xlikp[] = gt_xlikp[].
            SORT lt_xlikp BY tanum.
            DELETE ADJACENT DUPLICATES FROM lt_xlikp COMPARING tanum.
            IF lt_xlikp[] IS NOT INITIAL.
              SELECT lgnum tanum bdatu bzeit mblnr mjahr benum drukz druck lznum
                vbeln tapri queue lgtor refnr bwlvs tbnum
                FROM ltak
                INTO TABLE gt_ltak
                FOR ALL ENTRIES IN lt_xlikp
                WHERE lgnum = pa_lgnum
                  AND tanum = lt_xlikp-tanum.
            ENDIF.
          ENDIF.

          IF gt_ltak[] IS NOT INITIAL.
            SELECT *
              FROM lips
              INTO CORRESPONDING FIELDS OF TABLE gt_lips
              FOR ALL ENTRIES IN gt_xlikp
              WHERE vbeln = gt_xlikp-vbeln.

            lt_xlips[] = gt_lips[].
            SORT lt_xlips BY vgbel.
            DELETE ADJACENT DUPLICATES FROM lt_xlips COMPARING vgbel.
            IF lt_xlips[] IS NOT INITIAL.
              SELECT *
                FROM vbak
                INTO CORRESPONDING FIELDS OF TABLE gt_vbak
                FOR ALL ENTRIES IN lt_xlips
                WHERE vbeln = lt_xlips-vgbel.
            ENDIF.
          ENDIF.
        ELSE.
          SELECT lgnum tanum bdatu bzeit mblnr mjahr benum drukz druck lznum
            vbeln tapri queue lgtor refnr bwlvs tbnum
            FROM ltak
            INTO TABLE gt_ltak
            WHERE lgnum = pa_lgnum
              AND tanum IN so_tanum
              AND bdatu IN so_bdatu
              AND mblnr IN so_mblnr.
        ENDIF.
      ENDIF.
    ENDIF.
    IF pa_lgnum = '021'.
      CASE pa_drukz.
        WHEN '46'.
          SELECT a~tknum a~tpnum a~vbeln c~lgnum c~tanum c~tapri AS lprio c~lznum
     INTO CORRESPONDING FIELDS OF TABLE gt_lprio
     FROM vttp AS a "JOIN likp AS b ON a~vbeln = b~vbeln
                    JOIN ltak AS c ON a~vbeln = c~vbeln
     WHERE a~tknum IN so_tknum
       AND c~lgnum = pa_lgnum.

          IF gt_lprio IS NOT INITIAL.

            SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_route FROM vttk JOIN m_vmtra ON vttk~route = m_vmtra~route AND spras = 'E'
                         FOR ALL ENTRIES IN gt_lprio WHERE vttk~tknum = gt_lprio-tknum.

            SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_likp FROM likp FOR ALL ENTRIES IN gt_lprio
              WHERE vbeln = gt_lprio-vbeln.



            SORT gt_lprio BY lgnum tknum lznum tanum vbeln.
            LOOP AT gt_lprio INTO ls_lprio.
              IF lv_tknum = ls_lprio-tknum.
                lv_tknum = ls_lprio-tknum.
                CLEAR ls_stylerow.
                ls_stylerow-fieldname = 'CHECK'.
                ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
                APPEND ls_stylerow TO ls_lprio-style.
                CLEAR ls_stylerow.
                ls_stylerow-fieldname = 'LPRIO'.
                ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
                APPEND ls_stylerow TO ls_lprio-style.
                MODIFY gt_lprio FROM ls_lprio TRANSPORTING style.
              ELSE.
                lv_tknum = ls_lprio-tknum.
              ENDIF.
            ENDLOOP.
            IF pa_d2 = 'X'.
              SELECT *
*                lgnum tanum bdatu bzeit mblnr mjahr benum drukz druck lznum
*               vbeln tapri queue lgtor refnr bwlvs tbnum lgbzo
               FROM ltak
               INTO CORRESPONDING FIELDS OF TABLE gt_ltak
               FOR ALL ENTRIES IN gt_lprio
               WHERE lgnum = gt_lprio-lgnum
                 AND tanum = gt_lprio-tanum
                 AND mblnr IN so_mblnr
                 AND kquit = space.
            ELSE.
              SELECT *
*                lgnum tanum bdatu bzeit mblnr mjahr benum drukz druck lznum
*                  vbeln tapri queue lgtor refnr bwlvs tbnum lgbzo
                  FROM ltak
                  INTO CORRESPONDING FIELDS OF TABLE gt_ltak
                  FOR ALL ENTRIES IN gt_lprio
                  WHERE lgnum = gt_lprio-lgnum
                    AND tanum = gt_lprio-tanum
                    AND mblnr IN so_mblnr
                    AND kquit = space
                    AND lznum = space.

            ENDIF.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDIF.
  IF gt_ltak[] IS NOT INITIAL.
    IF pa_lgnum(2) = '38'.
      IF pa_drukz <> '45'.
        ls_vltyp-low    = 'T*'.
        ls_vltyp-sign   = 'I'.
        ls_vltyp-option = 'CP'.
        APPEND ls_vltyp TO lr_vltyp.
        CLEAR ls_vltyp.
      ENDIF.

      SELECT lgnum tanum tapos matnr werks charg bestq altme wdatu
        vltyp vlber vlpla vsola vsolm
        nltyp nlber nlpla nsola nista nistm maktx
        vfdat lgort pquit qplos ablad
        FROM ltap
        INTO CORRESPONDING FIELDS OF TABLE gt_ltap
        FOR ALL ENTRIES IN gt_ltak
        WHERE lgnum = gt_ltak-lgnum
          AND tanum = gt_ltak-tanum
          AND nltyp IN so_lgtyp
          AND vltyp IN lr_vltyp.
      IF sy-subrc <> 0.
        LOOP AT gt_xrldri INTO ls_xrldri.
          MOVE-CORRESPONDING ls_xrldri TO ls_ltap.
          APPEND ls_ltap TO gt_ltap.
          CLEAR ls_ltap.
        ENDLOOP.
      ENDIF.
    ELSE.
      SELECT ename ezeit edatu meins lgnum tanum tapos matnr werks charg bestq altme wdatu
        vltyp vlber vlpla vsola vsolm
        nltyp nlber nlpla nsola nista nistm maktx
        vfdat lgort pquit qplos ablad
        FROM ltap
        INTO CORRESPONDING FIELDS OF TABLE gt_ltap
        FOR ALL ENTRIES IN gt_ltak
        WHERE lgnum = gt_ltak-lgnum
          AND tanum = gt_ltak-tanum
          AND nltyp IN so_lgtyp.
    ENDIF.
  ENDIF.

  IF pa_drukz = '48' OR pa_drukz = '46'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE it_mat_gr FROM zprint_to_view FOR ALL ENTRIES IN gt_ltap
      WHERE matnr = gt_ltap-matnr AND
      lgnum = gt_ltap-lgnum AND
      lgtyp = gt_ltap-vltyp AND
      lgpla = gt_ltap-vlpla.

    PERFORM f_get_shipment.
  ENDIF.

  IF pa_lgnum(2) = '36' OR
    pa_lgnum(2) = '19'.
    IF gt_ltak[] IS INITIAL.
      LOOP AT gt_xrldrh INTO ls_xrldrh.
        ls_ltak-lgnum   = ls_xrldrh-lgnum.
        ls_ltak-tanum   = ls_xrldrh-tanum.
        ls_ltak-bdatu   = ls_xrldrh-bdatu.
        ls_ltak-bzeit   = ls_xrldrh-bzeit.
        ls_ltak-mblnr   = ls_xrldrh-mblnr.
        ls_ltak-mjahr   = ls_xrldrh-mjahr.
        ls_ltak-benum   = ls_xrldrh-benum.
        ls_ltak-drukz   = ls_xrldrh-drukz.
        ls_ltak-druck   = ls_xrldrh-druck.
        ls_ltak-lznum   = ls_xrldrh-lznum.
        ls_ltak-vbeln   = ls_xrldrh-vbeln.
        ls_ltak-tapri   = ls_xrldrh-tapri.
        ls_ltak-queue   = ls_xrldrh-queue.
        ls_ltak-lgtor   = ls_xrldrh-lgtor.
        ls_ltak-refnr   = ls_xrldrh-refnr.
        APPEND ls_ltak TO gt_ltak.
        CLEAR ls_ltak.
      ENDLOOP.
    ENDIF.
    IF gt_ltap[] IS INITIAL.
      LOOP AT gt_xrldri INTO ls_xrldri.
        ls_ltap-lgnum   = ls_xrldri-lgnum.
        ls_ltap-tanum   = ls_xrldri-tanum.
        ls_ltap-tapos   = ls_xrldri-tapos.
        ls_ltap-matnr   = ls_xrldri-matnr.
        ls_ltap-werks   = ls_xrldri-werks.
        ls_ltap-charg   = ls_xrldri-charg.
        ls_ltap-altme   = ls_xrldri-altme.
        ls_ltap-wdatu   = ls_xrldri-wdatu.
        ls_ltap-vltyp   = ls_xrldri-vltyp.
        ls_ltap-vlber   = ls_xrldri-vlber.
        ls_ltap-vlpla   = ls_xrldri-vlpla.
        ls_ltap-vsola   = ls_xrldri-vsola.
        ls_ltap-vsolm   = ls_xrldri-vsolm.
        ls_ltap-nltyp   = ls_xrldri-nltyp.
        ls_ltap-nlber   = ls_xrldri-nlber.
        ls_ltap-nlpla   = ls_xrldri-nlpla.
        ls_ltap-nsola   = ls_xrldri-nsola.
        ls_ltap-nista   = ls_xrldri-nista.
        ls_ltap-nistm   = ls_xrldri-nistm.
        ls_ltap-maktx   = ls_xrldri-maktx.
        ls_ltap-vfdat   = ls_xrldri-vfdat.
        ls_ltap-lgort   = ls_xrldri-lgort.
        ls_ltap-pquit   = ls_xrldri-pquit.
        ls_ltap-qplos   = ls_xrldri-qplos.
        ls_ltap-vorga   = ls_xrldri-vorga.
        ls_ltap-wenum   = ls_xrldri-wenum.
        APPEND ls_ltap TO gt_ltap.
        CLEAR ls_ltap.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF pa_lgnum = '190'.
    PERFORM f_get_to_new.
  ELSE.
    PERFORM f_get_to.
  ENDIF.
  IF pa_lgnum = '021'.
    CASE pa_drukz.
      WHEN '46'.
* ADDED vttp table
        SELECT vbeln, tknum INTO CORRESPONDING FIELDS OF TABLE @gt_vttp FROM vttp
          WHERE tknum IN @so_tknum.

        SELECT vfdat, matnr, charg INTO CORRESPONDING FIELDS OF TABLE @gt_mch1 FROM mch1 FOR ALL ENTRIES IN @gt_ltap
          WHERE matnr = @gt_ltap-matnr
          AND charg = @gt_ltap-charg.
    ENDCASE.
  ENDIF.

*
*  DATA: lv_vlpla    TYPE ltap_vlpla.
*  IF pa_drukz = '46'.
*    SORT gt_ltap BY vlpla.
*    LOOP AT gt_ltap INTO DATA(wa_ltap).
*      IF lv_vlpla = wa_ltap-vlpla.
*        lv_vlpla = wa_ltap-vlpla.
*        CLEAR ls_stylerow.
*        ls_stylerow-fieldname = 'CHECK'.
*        ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
*        APPEND ls_stylerow TO wa_ltap-style.
*        CLEAR ls_stylerow.
*        ls_stylerow-fieldname = 'LPRIO'.
*        ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
*        APPEND ls_stylerow TO wa_ltap-style.
*        MODIFY gt_ltap FROM wa_ltap TRANSPORTING style.
*      ELSE.
*        lv_vlpla = wa_ltap-vlpla.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.


  IF pa_drukz = '50'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_temp_sf4
      FROM mseg JOIN makt ON mseg~matnr = makt~matnr
      WHERE mblnr IN so_mblnr
      AND spras = 'E'.

    IF gt_temp_sf4[] IS NOT INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_mkpf FROM mkpf
        FOR ALL ENTRIES IN gt_temp_sf4
        WHERE mblnr = gt_temp_sf4-mblnr.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_mlgn FROM mlgn
        FOR ALL ENTRIES IN gt_temp_sf4
        WHERE matnr = gt_temp_sf4-matnr
        AND lgnum = pa_lgnum.
    ENDIF.
  ENDIF.


ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  IF pa_lprio = 'X'.
    PERFORM f_alv TABLES gt_lprio.
  ELSE.
    IF pa_drukz = '50'.
      PERFORM f_alv TABLES gt_04.
    ELSE.
      PERFORM f_alv TABLES gt_out.
    ENDIF.
  ENDIF.

ENDFORM.                    "F_PRINT_DATA

*---------------------------------------------------------------------*
*       FORM F_ALV
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  DATA: event_handler TYPE REF TO lcl_event_handler.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.

  IF pa_lprio = 'X'.
    PERFORM f_build_fieldcat_lprio TABLES  ft_report.
  ELSE.
    PERFORM f_build_fieldcat  TABLES  ft_report.
  ENDIF.

  PERFORM f_build_layout      USING   d_layout.

  IF pa_lprio = 'X'.
    PERFORM f_build_sortfield_lprio   USING   t_alv_isort[].
  ELSE.
    PERFORM f_build_sortfield   USING   t_alv_isort[].
  ENDIF.

  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  lv_func    = 'REUSE_ALV_GRID_DISPLAY'.
  lv_title   = sy-title.

  PERFORM f_build_event       TABLES  t_alv_event[].

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
  DATA : colhead(50).

  WRITE icon_select_all AS ICON TO colhead.
  IF pa_drukz = '50'.
    PERFORM f_fieldcatg USING 'GT_04' :
          'CHECK' '' '' '' '4' '' '' '' '' '' '' '' '' 'X' 'X' '' 'X',
          'PALLET' '' '' '' '' 'Pallet' '' '' '' '' '' '' '' '' '' '' '',
          'MATNR' 'MSEG' 'MATNR' '' '' 'Kode Material' '' '' '' '' '' '' '' '' '' '' '',
          'MAKTX' 'MAKT' 'MAKTX' '' '' 'Deskripsi Material' '' '' '' '' '' '' '' '' '' '' '',
          'EBELN' 'MSEG' 'EBELN' '' '' 'Nomor Purchase Order' '' '' '' '' '' '' '' '' '' '' '',
          'VFDAT' 'MSEG' 'VFDAT' '' '' 'Expired Date' '' '' '' '' '' '' '' '' '' '' '',
          'CHARG' 'MSEG' 'CHARG' '' '' 'Batch' '' '' '' '' '' '' '' '' '' '' '',
          'BUDAT' 'MKPF' 'BUDAT' '' '' 'GR Date' '' '' '' '' '' '' '' '' '' '' '',
          'HSDAT' 'MSEG' 'HSDAT' '' '' 'Prod Date' '' '' '' '' '' '' '' '' '' '' '',
          'QTY' '' '' '' '' 'Quantity' '' '' '' '' '' '' '' '' '' '' '',
          'CARTON' '' '' '' '' 'Carton' '' '' '' '' '' '' '' '' '' '' '',
          'ECER' '' '' '' '' 'Ecer' '' '' '' '' '' '' '' '' '' '' '',
          'MEINS' '' '' '' '' 'UOM' '' '' '' '' '' '' '' '' '' '' '',
          'MBLNR' 'MSEG' 'MBLNR' '' '' 'Material Document' '' '' '' '' '' '' '' '' '' '' '',
          'LIFNR' 'MSEG' 'LIFNR' '' '' 'Vendor' '' '' '' '' '' '' '' '' '' '' ''.
  ELSE.
    PERFORM f_fieldcatg USING 'GT_OUT' :
      'CHECK' '' '' '' '4' '' '' '' '' '' '' '' '' 'X' 'X' '' 'X',  "colhead
      'LGNUM' 'LTAP' 'LGNUM' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'VLTYP' 'LTAP' 'VLTYP' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'VLPLA' 'LTAP' 'VLPLA' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'NLTYP' 'LTAP' 'NLTYP' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'NLPLA' 'LTAP' 'NLPLA' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    IF pa_drukz = '48' OR pa_drukz = '46'.
      PERFORM f_fieldcatg USING 'GT_OUT' :
        'KUNNR' 'LIKP' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'LZNUM' 'LTAK' 'LZNUM' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MATKL' 'MARA' 'MATKL' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'QUEUE' 'LTAK' 'QUEUE' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KOBER' 'LAGP' 'KOBER' '' '' 'Pick Area' '' '' '' '' '' '' '' '' '' '' '',
        'TKNUM' 'VTTP' 'TKNUM' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'LGBZO' 'LTAK' 'LGBZO' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    ENDIF.
    PERFORM f_fieldcatg USING 'GT_OUT' :
      'MBLNR' 'LTAK' 'MBLNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'TANUM' 'LTAP' 'TANUM' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'MATNR' 'LTAP' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'MAKTX' 'LTAP' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    IF pa_drukz = '45'.
      PERFORM f_fieldcatg USING 'GT_OUT' :
        'CHARG' 'LTAP' 'CHARG' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'LZNUM' 'LTAK' 'LZNUM' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    ENDIF.
    PERFORM f_fieldcatg USING 'GT_OUT' :
    'VSOLA' 'LTAP' 'VSOLA' '' '' '' '' '' '' '' '' '' 'ALTME' '' '' '' '',
    'NISTA' 'LTAP' 'NISTA' '' '' '' '' '' '' '' '' '' 'ALTME' '' '' '' '',
    'ALTME' 'LTAP' 'ALTME' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'TAPRI' 'LTAK' 'TAPRI' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    IF pa_drukz <> '48' AND pa_drukz <> '46'.
      PERFORM f_fieldcatg USING 'GT_OUT' :
      'QUEUE' 'LTAK' 'QUEUE' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    ENDIF.
    PERFORM f_fieldcatg USING 'GT_OUT' :
    'LGTOR' 'LTAK' 'LGTOR' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'DRUCK' 'LTAK' 'DRUCK' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.



  ENDIF.
ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM F_FIELDCAT_LPRIO
*---------------------------------------------------------------------*
FORM f_build_fieldcat_lprio TABLES ft_report.
  REFRESH: t_alv_fieldcat.
  DATA : colhead(50).

  WRITE icon_select_all AS ICON TO colhead.
*  IF pa_drukz = '50'.
*    PERFORM f_fieldcatg USING 'GT_LPRIO' :
*   'CHECK' '' '' '' '4' '' '' '' '' '' '' '' '' 'X' 'X' '' 'X'.  "colhead
*  ELSE.
  PERFORM f_fieldcatg USING 'GT_LPRIO' :
    'CHECK' '' '' '' '4' '' '' '' '' '' '' '' '' 'X' 'X' '' 'X',  "colhead
    'LGNUM' 'LTAK' 'LGNUM' '' '10' '' '' '' '' '' '' '' '' '' '' '' '',
    'LZNUM' 'LTAK' 'LZNUM' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'TANUM' 'LTAK' 'TANUM' '' '10' '' '' '' '' '' '' '' '' '' '' '' '',
    'TKNUM' 'VTTP' 'TKNUM' '' '12' '' '' '' '' '' '' '' '' '' '' '' '',
    'VBELN' 'VTTP' 'VBELN' '' '12' '' '' '' '' '' '' '' '' '' '' '' '',
    'LPRIO' 'LIKP' 'LPRIO' '' '10' 'TO priority' '' '' '' '' '' '' '' '' 'X' '' 'X'.
*  ENDIF.
ENDFORM.                    " F_FIELDCAT_LPRIO

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
                          VALUE(fu_edit).

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
  ld_fieldcat-edit              = fu_edit.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
*  REFRESH: ft_events.
*  CLEAR ft_events.
*  ft_events-name = slis_ev_top_of_page.
*  ft_events-form = 'F_TOP_OF_PAGE'.
*  APPEND ft_events.
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


  IF pa_drukz = '46' AND pa_d2 = 'X'.
    ld_sort-fieldname = 'TKNUM'.
    ld_sort-up        = 'X'.
    ld_sort-group     = 'UL'.
    APPEND ld_sort TO fu_sort.
    CLEAR ld_sort.
    ld_sort-fieldname = 'LZNUM'.
    ld_sort-up        = 'X'.
    APPEND ld_sort TO fu_sort.
    CLEAR ld_sort.
  ENDIF.
  IF pa_drukz = '48'.
    IF pa_lgnum = 'C40'.
      CLEAR ld_sort.
      ld_sort-fieldname = 'NLPLA'.
      ld_sort-up        = 'X'.
      ld_sort-group     = 'UL'.
      APPEND ld_sort TO fu_sort.
    ELSE.
      IF so_tknum[] IS INITIAL.
        CLEAR ld_sort.
        ld_sort-fieldname = 'KUNNR'.
        ld_sort-up        = 'X'.
        ld_sort-group     = 'UL'.
        APPEND ld_sort TO fu_sort.
        CLEAR ld_sort.
        ld_sort-fieldname = 'TANUM'.
        ld_sort-up        = 'X'.
        APPEND ld_sort TO fu_sort.
        CLEAR ld_sort.
        ld_sort-fieldname = 'MATNR'.
        ld_sort-up        = 'X'.
        APPEND ld_sort TO fu_sort.
        CLEAR ld_sort.
      ELSE.
        CLEAR ld_sort.
        ld_sort-fieldname = 'KUNNR'.
        ld_sort-up        = 'X'.
        ld_sort-group     = 'UL'.
        APPEND ld_sort TO fu_sort.
        CLEAR ld_sort.
        ld_sort-fieldname = 'TKNUM'.
        ld_sort-up        = 'X'.
        APPEND ld_sort TO fu_sort.
        CLEAR ld_sort.
        ld_sort-fieldname = 'KOBER'.
        ld_sort-up        = 'X'.
        APPEND ld_sort TO fu_sort.
        CLEAR ld_sort.
        ld_sort-fieldname = 'TANUM'.
        ld_sort-up        = 'X'.
        APPEND ld_sort TO fu_sort.
        CLEAR ld_sort.
        ld_sort-fieldname = 'MATNR'.
        ld_sort-up        = 'X'.
        APPEND ld_sort TO fu_sort.
        CLEAR ld_sort.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "F_BUILD_SORTFIELD

*---------------------------------------------------------------------*
*       FORM F_BUILD_SORTFIELD_LPRIO
*---------------------------------------------------------------------*
FORM f_build_sortfield_lprio USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'LGNUM'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
  CLEAR ld_sort.
  ld_sort-fieldname = 'LZNUM'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
  CLEAR ld_sort.
  ld_sort-fieldname = 'TANUM'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
  CLEAR ld_sort.
  ld_sort-fieldname = 'TKNUM'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
  CLEAR ld_sort.
  ld_sort-fieldname = 'VBELN'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
  CLEAR ld_sort.
ENDFORM.                    "F_BUILD_SORTFIELD_LPRIO

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
  DATA: is_layout TYPE lvc_s_layo,
        fcode     TYPE TABLE OF sy-ucomm.

  DATA: event_handler TYPE REF TO lcl_event_handler.

  sy-lsind = 0.

  IF pa_lprio = 'X'.
    APPEND '&PREV' TO fcode.
    APPEND '&GRP' TO fcode.
  ELSE.
    IF pa_drukz = '48'.
      IF pa_druck IS NOT INITIAL.
        APPEND '&POS' TO fcode.
        APPEND '&GRP' TO fcode.
        APPEND '&PRE' TO fcode.
      ENDIF.
    ELSEIF pa_drukz = '46'.
      APPEND '&PREV' TO fcode.
      APPEND '&GRP' TO fcode.
    ELSE.
      APPEND '&PREV' TO fcode.
      APPEND '&GRP' TO fcode.
      APPEND '&PRE' TO fcode.
    ENDIF.
  ENDIF.

  SET PF-STATUS 'TOEXECUTE' EXCLUDING fcode.

  CLEAR ref_grid.
  IF ref_grid IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref_grid.
  ENDIF.

  IF ref_grid IS NOT INITIAL.
    is_layout-zebra       = 'X'.
    is_layout-no_rowmark  = 'X'.
    is_layout-no_toolbar  = 'X'.
    is_layout-stylefname  = 'STYLE'.

    CALL METHOD ref_grid->set_frontend_layout
      EXPORTING
        is_layout = is_layout.

    IF pa_lprio = 'X'.
      IF sy-ucomm IS INITIAL.
        CALL METHOD ref_grid->refresh_table_display.
      ENDIF.
    ELSE.
      CALL METHOD ref_grid->refresh_table_display.
    ENDIF.
  ENDIF.
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
  DATA : lt_ltap LIKE gt_ltap OCCURS 0 WITH HEADER LINE,
         lt_ltak LIKE gt_ltak OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_twlad OCCURS 0,
           werks TYPE werks_d,
           lgort TYPE lgort_d,
           name1 TYPE ad_name1,
         END   OF lt_twlad.
  DATA : BEGIN OF lt_t001k OCCURS 0,
           bwkey TYPE bwkey,
           butxt TYPE butxt,
         END   OF lt_t001k.
  DATA : BEGIN OF lt_mkpf OCCURS 0,
           mblnr TYPE mblnr,
           mjahr TYPE mjahr,
           budat TYPE budat,
         END   OF lt_mkpf.
  DATA : BEGIN OF lt_mseg OCCURS 0,
           mblnr TYPE mblnr,
           mjahr TYPE mjahr,
           lifnr TYPE lifnr,
           hsdat TYPE hsdat,
           menge TYPE menge_d,
           meins TYPE meins,
         END   OF lt_mseg.
  DATA : lt_xmseg TYPE STANDARD TABLE OF mseg,
         ls_xmseg LIKE LINE OF lt_xmseg.
  DATA : lt_mseglfa1 LIKE lt_mseg OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_lfa1 OCCURS 0,
           lifnr TYPE lifnr,
           name1 TYPE name1_gp,
         END   OF lt_lfa1.
  DATA : BEGIN OF lt_mch1 OCCURS 0,
           matnr TYPE matnr,
           charg TYPE charg_d,
           licha TYPE lichn,
         END   OF lt_mch1.
  DATA : lv_carton  TYPE i.
  DATA: BEGIN OF lt_marm OCCURS 0,
          matnr TYPE matnr,
          meinh TYPE lrmei,
          umrez TYPE umrez,
          umren TYPE umren,
        END OF lt_marm.
  DATA : lv_sisa(20),
         lv_altme    TYPE meins,
         lv_lifnr    TYPE mseg-lifnr.

  lt_ltap[] = gt_ltap[].
  SORT lt_ltap BY werks lgort.
  DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING werks lgort.
  IF lt_ltap[] IS NOT INITIAL.
    SELECT werks lgort name1
      FROM twlad AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
      INTO TABLE lt_twlad
      FOR ALL ENTRIES IN lt_ltap
      WHERE werks EQ lt_ltap-werks AND
            lgort EQ lt_ltap-lgort.
  ENDIF.

  SORT lt_ltap BY werks.
  DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING werks.
  IF lt_ltap[] IS NOT INITIAL.
    SELECT bwkey butxt
      FROM t001k AS a JOIN t001 AS b ON a~bukrs EQ b~bukrs
      INTO TABLE lt_t001k
      FOR ALL ENTRIES IN lt_ltap
      WHERE bwkey EQ lt_ltap-werks.
  ENDIF.

  lt_ltak[] = gt_ltak[].
  SORT lt_ltak BY mblnr mjahr.
  DELETE ADJACENT DUPLICATES FROM lt_ltak COMPARING mblnr mjahr.

  IF lt_ltak[] IS NOT INITIAL.
    SELECT mblnr mjahr budat
      FROM mkpf
      INTO TABLE lt_mkpf
      FOR ALL ENTRIES IN lt_ltak
      WHERE mblnr = lt_ltak-mblnr
        AND mjahr = lt_ltak-mjahr.

    IF pa_drukz = '45' AND
      ( pa_lgnum(2) = '36' OR
        pa_lgnum(2) = '19' ).
      SELECT *
        FROM mseg
        INTO CORRESPONDING FIELDS OF TABLE lt_xmseg
        FOR ALL ENTRIES IN lt_ltak
        WHERE mblnr = lt_ltak-mblnr
          AND mjahr = lt_ltak-mjahr
          AND shkzg = 'S'.
    ELSE.
      SELECT mblnr mjahr lifnr hsdat menge meins
        FROM mseg
        INTO TABLE lt_mseg
        FOR ALL ENTRIES IN lt_ltak
        WHERE mblnr = lt_ltak-mblnr
          AND mjahr = lt_ltak-mjahr.
    ENDIF.

    lt_mseglfa1[] = lt_mseg[].
    SORT lt_mseglfa1 BY lifnr.
    DELETE ADJACENT DUPLICATES FROM lt_mseglfa1 COMPARING lifnr.

    IF lt_mseglfa1[] IS NOT INITIAL.
      SELECT lifnr name1
        FROM lfa1
        INTO TABLE lt_lfa1
        FOR ALL ENTRIES IN lt_mseglfa1
        WHERE lifnr = lt_mseglfa1-lifnr.
    ENDIF.
  ENDIF.

  CLEAR : lt_ltap[], lt_ltap.
  lt_ltap[] = gt_ltap[].
  SORT lt_ltap BY matnr charg.
  DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING matnr charg.

  IF lt_ltap[] IS NOT INITIAL.
    SELECT matnr charg licha
      FROM mch1
      INTO TABLE lt_mch1
      FOR ALL ENTRIES IN lt_ltap
      WHERE matnr = lt_ltap-matnr
        AND charg = lt_ltap-charg
        AND lvorm = space.
  ENDIF.

  SORT lt_ltap BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING matnr.

  CLEAR : lt_marm[], lt_marm.

  SELECT matnr meinh umrez umren
    FROM marm
    INTO TABLE lt_marm
    FOR ALL ENTRIES IN lt_ltap
    WHERE matnr = lt_ltap-matnr
      AND meinh = 'KAR'.

  SORT gt_ltak BY lgnum tanum.
  SORT gt_ltap BY lgnum tanum tapos.

  IF pa_drukz = '46' AND pa_lgnum = '021'.
    SORT gt_ltak BY tknum vbeln.
    LOOP AT gt_ltap.
      gt_out-meins  = gt_ltap-meins.
      gt_out-ename  = gt_ltap-ename.
      gt_out-ezeit  = gt_ltap-ezeit.
      gt_out-edatu  = gt_ltap-edatu.
      gt_out-lgnum  = gt_ltap-lgnum.
      gt_out-nltyp  = gt_ltap-nltyp.
      gt_out-bestq  = gt_ltap-bestq.
      gt_out-drukz = pa_drukz.
      gt_out-druck = pa_druck.

      gt_out-tanum  = gt_ltap-tanum.
      gt_out-matnr  = gt_ltap-matnr.
      gt_out-maktx  = gt_ltap-maktx.
      gt_out-vltyp  = gt_ltap-vltyp.
      gt_out-vlpla  = gt_ltap-vlpla.
      gt_out-vsola  = gt_ltap-vsola.
      gt_out-vsolm  = gt_ltap-vsolm.
      gt_out-nista  = gt_ltap-nista.
      gt_out-altme  = gt_ltap-altme.
      gt_out-tapos  = gt_ltap-tapos.
      gt_out-werks  = gt_ltap-werks.
      gt_out-charg  = gt_ltap-charg.
      gt_out-wdatu  = gt_ltap-wdatu.
      gt_out-nlpla  = gt_ltap-nlpla.
      gt_out-vfdat  = gt_ltap-vfdat.
      gt_out-lgort  = gt_ltap-lgort.
      gt_out-qplos  = gt_ltap-qplos.
      gt_out-nistm  = gt_ltap-nistm.

      READ TABLE gt_mch1 INTO DATA(ls_mch1) WITH KEY matnr = gt_ltap-matnr charg = gt_ltap-charg.
      IF sy-subrc = 0.
        gt_out-vfdat = ls_mch1-vfdat.
      ENDIF.


      READ TABLE it_mat_gr INTO DATA(ls_mat_gr) WITH KEY matnr = gt_ltap-matnr lgnum = gt_ltap-lgnum lgtyp = gt_ltap-vltyp lgpla = gt_ltap-vlpla.
      IF sy-subrc = 0.
        gt_out-matkl = ls_mat_gr-matkl.
        gt_out-kober = ls_mat_gr-kober.
      ENDIF.
      IF gt_ltap-werks = '0501'.
        READ TABLE lt_twlad WITH KEY werks = gt_ltap-werks
                                     lgort = gt_ltap-lgort.
        IF sy-subrc = 0.
          gt_out-name1w = lt_twlad-name1.
        ENDIF.
      ELSE.
        READ TABLE lt_t001k WITH KEY bwkey = gt_ltap-werks.
        IF sy-subrc = 0.
          gt_out-name1w = lt_t001k-butxt.
        ENDIF.
      ENDIF.

      READ TABLE lt_mch1 WITH KEY matnr = gt_ltap-matnr
                                  charg = gt_ltap-charg.
      IF sy-subrc = 0.
        gt_out-licha  = lt_mch1-licha.
      ELSE.
        gt_out-licha = 'N/A'.
      ENDIF.

      gt_out-prueflos  = 'N/A'.

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = gt_ltap-altme
          language       = sy-langu
        IMPORTING
          output         = lv_altme
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.

      IF gt_ltap-nista IS INITIAL.
        WRITE gt_ltap-vsola TO gt_out-vsolat UNIT gt_ltap-altme.
        PERFORM f_modify_unit CHANGING gt_out-vsolat.
        CONDENSE gt_out-vsolat NO-GAPS.
        CONCATENATE gt_out-vsolat lv_altme
        INTO gt_out-totalt
        SEPARATED BY space.

        READ TABLE lt_marm WITH KEY matnr = gt_ltap-matnr.
        IF sy-subrc = 0.
          lv_sisa  = gt_out-vsolat MOD lt_marm-umrez.
          PERFORM f_modify_unit CHANGING lv_sisa.
          CONDENSE lv_sisa NO-GAPS.
        ENDIF.

        CONCATENATE lv_sisa lv_altme
        INTO gt_out-vsolat
        SEPARATED BY space.

        PERFORM f_convert_material USING gt_ltap-matnr gt_ltap-altme
                                   CHANGING gt_ltap-vsola.

        lv_carton  = floor( gt_ltap-vsola ).
      ELSE.
        WRITE gt_ltap-nista TO gt_out-vsolat UNIT gt_ltap-altme.
        PERFORM f_modify_unit CHANGING gt_out-vsolat.
        CONDENSE gt_out-vsolat NO-GAPS.
        CONCATENATE gt_out-vsolat lv_altme
        INTO gt_out-totalt
        SEPARATED BY space.

        READ TABLE lt_marm WITH KEY matnr = gt_ltap-matnr.
        IF sy-subrc = 0.
          lv_sisa  = gt_out-vsolat MOD lt_marm-umrez.
          PERFORM f_modify_unit CHANGING lv_sisa.
          CONDENSE lv_sisa NO-GAPS.
        ENDIF.

        CONCATENATE lv_sisa lv_altme
        INTO gt_out-vsolat
        SEPARATED BY space.

        PERFORM f_convert_material USING gt_ltap-matnr gt_ltap-altme
                                   CHANGING gt_ltap-nista.

        lv_carton  = floor( gt_ltap-nista ).
      ENDIF.

      WRITE lv_carton TO gt_out-cartont UNIT 'KAR'.
      CONDENSE gt_out-cartont NO-GAPS.
      CONCATENATE gt_out-cartont 'CAR'
      INTO gt_out-cartont
      SEPARATED BY space.

      IF gt_ltap-vltyp(1) = 'L'.
        gt_out-loose = 'X'.
      ENDIF.
      IF gt_ltak-drukz = pa_drukz.
        IF gt_ltak-druck = 'X'.
          gt_out-reprint  = 'REPRINT'.
        ENDIF.
      ENDIF.

      READ TABLE lt_mkpf WITH KEY mblnr = gt_ltak-mblnr
                                  mjahr = gt_ltak-mjahr.
      IF sy-subrc = 0.
        gt_out-budat  = lt_mkpf-budat.
      ENDIF.

      CLEAR lv_lifnr.
      IF lt_xmseg[] IS NOT INITIAL.
        READ TABLE lt_xmseg INTO ls_xmseg
                            WITH KEY mblnr = gt_ltak-mblnr
                                     mjahr = gt_ltak-mjahr
                                     charg = gt_ltap-charg.
        IF sy-subrc = 0.
          gt_out-hsdat  = ls_xmseg-hsdat.
          gt_out-menge  = ls_xmseg-menge.
          gt_out-meins  = ls_xmseg-meins.
          lv_lifnr      = ls_xmseg-lifnr.
        ENDIF.
      ELSE.
        READ TABLE lt_mseg WITH KEY mblnr = gt_ltak-mblnr
                                    mjahr = gt_ltak-mjahr.
        IF sy-subrc = 0.
          gt_out-hsdat  = lt_mseg-hsdat.
          gt_out-menge  = lt_mseg-menge.
          gt_out-meins  = lt_mseg-meins.
          lv_lifnr      = lt_mseg-lifnr.
        ENDIF.
      ENDIF.

      IF lv_lifnr IS NOT INITIAL.
        READ TABLE lt_lfa1 WITH KEY lifnr = lv_lifnr.
        IF sy-subrc = 0.
          gt_out-name1  = lt_lfa1-name1.
        ENDIF.
      ENDIF.


      LOOP AT gt_ltak INTO DATA(ls_ltak) WHERE lgnum = gt_ltap-lgnum AND tanum = gt_ltap-tanum GROUP BY ls_ltak-tknum.
        READ TABLE gt_route INTO DATA(ls_route) WITH KEY tknum = ls_ltak-tknum.
        IF sy-subrc = 0.
          gt_out-route = ls_route-route.
          gt_out-bezei = ls_route-bezei.
        ENDIF.

        READ TABLE gt_likp INTO DATA(ls_likp) WITH KEY vbeln = ls_ltak-vbeln.
        IF sy-subrc = 0.
          gt_out-kunnr = ls_likp-kunnr.
        ENDIF.
        gt_out-mblnr  = ls_ltak-mblnr.
        gt_out-bdatu  = ls_ltak-bdatu.
        gt_out-bzeit  = ls_ltak-bzeit.
        gt_out-mjahr  = ls_ltak-mjahr.
        gt_out-benum  = ls_ltak-benum.
        gt_out-drukz  = ls_ltak-drukz.
        gt_out-druck  = ls_ltak-druck.
        gt_out-lznum  = ls_ltak-lznum.
        gt_out-tapri  = ls_ltak-tapri.
        gt_out-queue  = ls_ltak-queue.
        gt_out-lgtor  = ls_ltak-lgtor.
        gt_out-vbeln  = ls_ltak-vbeln.
        gt_out-refnr  = ls_ltak-refnr.
        gt_out-bwlvs  = ls_ltak-bwlvs.
        gt_out-tbnum  = ls_ltak-tbnum.
        gt_out-tknum  = ls_ltak-tknum.
        gt_out-lgbzo  = ls_ltak-lgbzo.
        READ TABLE gt_lprio INTO DATA(ls_lprio) WITH KEY vbeln = ls_ltak-vbeln.
        IF sy-subrc = 0.
          gt_out-tknum  = ls_lprio-tknum.
        ENDIF.
        APPEND gt_out.
        CLEAR gt_out.
      ENDLOOP.

    ENDLOOP.

  ELSE.

    LOOP AT gt_ltap.
      IF gt_ltap-pquit = 'X' AND
        gt_ltap-nista IS INITIAL.
        CONTINUE.
      ENDIF.
      gt_out-lgnum  = gt_ltap-lgnum.
      gt_out-nltyp  = gt_ltap-nltyp.
      gt_out-bestq  = gt_ltap-bestq.

      READ TABLE it_mat_gr INTO ls_mat_gr WITH KEY matnr = gt_ltap-matnr lgnum = gt_ltap-lgnum lgtyp = gt_ltap-vltyp lgpla = gt_ltap-vlpla.
      IF sy-subrc = 0.
        gt_out-matkl = ls_mat_gr-matkl.
        gt_out-kober = ls_mat_gr-kober.
      ENDIF.


      READ TABLE gt_ltak WITH KEY lgnum = gt_ltap-lgnum
                                  tanum = gt_ltap-tanum
                                  BINARY SEARCH.
      IF sy-subrc = 0.
        gt_out-mblnr  = gt_ltak-mblnr.
        gt_out-bdatu  = gt_ltak-bdatu.
        gt_out-bzeit  = gt_ltak-bzeit.
        gt_out-mjahr  = gt_ltak-mjahr.
        gt_out-benum  = gt_ltak-benum.
        gt_out-drukz  = gt_ltak-drukz.
        gt_out-druck  = gt_ltak-druck.
        gt_out-lznum  = gt_ltak-lznum.
        gt_out-tapri  = gt_ltak-tapri.
        gt_out-queue  = gt_ltak-queue.
        gt_out-lgtor  = gt_ltak-lgtor.
        gt_out-vbeln  = gt_ltak-vbeln.
        gt_out-refnr  = gt_ltak-refnr.
        gt_out-bwlvs  = gt_ltak-bwlvs.
        gt_out-tbnum  = gt_ltak-tbnum.
        gt_out-tknum  = gt_ltak-tknum.
        gt_out-lgbzo  = gt_ltak-lgbzo.
      ENDIF.
      IF gt_ltap-lgnum = 'C40'.
        gt_out-nltyp  = gt_ltap-nltyp.
        gt_out-nlber  = gt_ltap-nlber.
        gt_out-nlpla  = gt_ltap-nlpla.
      ENDIF.

      CASE pa_drukz.
        WHEN '47'.
          CONCATENATE gt_ltap-tanum ';' gt_ltak-vbeln
          INTO gt_out-qrcode.

        WHEN '48'.
          gt_out-drukz = pa_drukz.
          gt_out-druck = pa_druck.
        WHEN '49'.
          CONCATENATE gt_ltap-tanum ';' gt_ltak-vbeln
          INTO gt_out-qrcode.
        WHEN OTHERS.
          IF gt_ltak-lznum IS NOT INITIAL.
            IF gt_ltak-lgnum = '053' OR
              gt_ltak-lgnum = '380'.
              CONCATENATE gt_ltap-matnr ';' gt_ltap-charg
              INTO gt_out-qrcode.
            ELSEIF gt_ltak-lgnum = 'C05'.
**            IF gt_ltap-ablad IS NOT INITIAL.
**              CONCATENATE gt_ltap-ablad ';' gt_ltap-tanum
**              INTO gt_out-qrcode.
**            ELSE.
              CONCATENATE gt_out-lznum  gt_ltap-tanum
              INTO gt_out-qrcode SEPARATED BY ';'.
**            ENDIF.
            ELSE.
              CONCATENATE gt_out-lznum ';' gt_ltap-tanum
              INTO gt_out-qrcode.
            ENDIF.
          ELSE.
            CONCATENATE '0' ';' gt_ltak-mblnr ';' gt_ltap-tanum
            INTO gt_out-qrcode.
          ENDIF.
      ENDCASE.

      IF gt_ltak-drukz = pa_drukz.
        IF gt_ltak-druck = 'X'.
          gt_out-reprint  = 'REPRINT'.
        ENDIF.
      ENDIF.

      READ TABLE lt_mkpf WITH KEY mblnr = gt_ltak-mblnr
                                  mjahr = gt_ltak-mjahr.
      IF sy-subrc = 0.
        gt_out-budat  = lt_mkpf-budat.
      ENDIF.

      CLEAR lv_lifnr.
      IF lt_xmseg[] IS NOT INITIAL.
        READ TABLE lt_xmseg INTO ls_xmseg
                            WITH KEY mblnr = gt_ltak-mblnr
                                     mjahr = gt_ltak-mjahr
                                     charg = gt_ltap-charg.
        IF sy-subrc = 0.
          gt_out-hsdat  = ls_xmseg-hsdat.
          gt_out-menge  = ls_xmseg-menge.
          gt_out-meins  = ls_xmseg-meins.
          lv_lifnr      = ls_xmseg-lifnr.
        ENDIF.
      ELSE.
        READ TABLE lt_mseg WITH KEY mblnr = gt_ltak-mblnr
                                    mjahr = gt_ltak-mjahr.
        IF sy-subrc = 0.
          gt_out-hsdat  = lt_mseg-hsdat.
          gt_out-menge  = lt_mseg-menge.
          gt_out-meins  = lt_mseg-meins.
          lv_lifnr      = lt_mseg-lifnr.
        ENDIF.
      ENDIF.

      IF lv_lifnr IS NOT INITIAL.
        READ TABLE lt_lfa1 WITH KEY lifnr = lv_lifnr.
        IF sy-subrc = 0.
          gt_out-name1  = lt_lfa1-name1.
        ENDIF.
      ENDIF.


      gt_out-tanum  = gt_ltap-tanum.
      gt_out-matnr  = gt_ltap-matnr.
      gt_out-maktx  = gt_ltap-maktx.
      gt_out-vltyp  = gt_ltap-vltyp.
      gt_out-vlpla  = gt_ltap-vlpla.
      gt_out-vsola  = gt_ltap-vsola.
      gt_out-vsolm  = gt_ltap-vsolm.
      gt_out-nista  = gt_ltap-nista.
      gt_out-altme  = gt_ltap-altme.
      gt_out-tapos  = gt_ltap-tapos.
      gt_out-werks  = gt_ltap-werks.
      gt_out-charg  = gt_ltap-charg.
      gt_out-wdatu  = gt_ltap-wdatu.
      gt_out-nlpla  = gt_ltap-nlpla.
      gt_out-vfdat  = gt_ltap-vfdat.
      gt_out-lgort  = gt_ltap-lgort.
      gt_out-qplos  = gt_ltap-qplos.
      gt_out-nistm  = gt_ltap-nistm.

      IF gt_ltap-werks = '0501'.
        READ TABLE lt_twlad WITH KEY werks = gt_ltap-werks
                                     lgort = gt_ltap-lgort.
        IF sy-subrc = 0.
          gt_out-name1w = lt_twlad-name1.
        ENDIF.
      ELSE.
        READ TABLE lt_t001k WITH KEY bwkey = gt_ltap-werks.
        IF sy-subrc = 0.
          gt_out-name1w = lt_t001k-butxt.
        ENDIF.
      ENDIF.

      READ TABLE lt_mch1 WITH KEY matnr = gt_ltap-matnr
                                  charg = gt_ltap-charg.
      IF sy-subrc = 0.
        gt_out-licha  = lt_mch1-licha.
      ELSE.
        gt_out-licha = 'N/A'.
      ENDIF.

      gt_out-prueflos  = 'N/A'.

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = gt_ltap-altme
          language       = sy-langu
        IMPORTING
          output         = lv_altme
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.

      IF gt_ltap-nista IS INITIAL.
        WRITE gt_ltap-vsola TO gt_out-vsolat UNIT gt_ltap-altme.
        PERFORM f_modify_unit CHANGING gt_out-vsolat.
        CONDENSE gt_out-vsolat NO-GAPS.
        CONCATENATE gt_out-vsolat lv_altme
        INTO gt_out-totalt
        SEPARATED BY space.

        READ TABLE lt_marm WITH KEY matnr = gt_ltap-matnr.
        IF sy-subrc = 0.
          lv_sisa  = gt_out-vsolat MOD lt_marm-umrez.
          PERFORM f_modify_unit CHANGING lv_sisa.
          CONDENSE lv_sisa NO-GAPS.
        ENDIF.

        CONCATENATE lv_sisa lv_altme
        INTO gt_out-vsolat
        SEPARATED BY space.

        PERFORM f_convert_material USING gt_ltap-matnr gt_ltap-altme
                                   CHANGING gt_ltap-vsola.

        lv_carton  = floor( gt_ltap-vsola ).
      ELSE.
        WRITE gt_ltap-nista TO gt_out-vsolat UNIT gt_ltap-altme.
        PERFORM f_modify_unit CHANGING gt_out-vsolat.
        CONDENSE gt_out-vsolat NO-GAPS.
        CONCATENATE gt_out-vsolat lv_altme
        INTO gt_out-totalt
        SEPARATED BY space.

        READ TABLE lt_marm WITH KEY matnr = gt_ltap-matnr.
        IF sy-subrc = 0.
          lv_sisa  = gt_out-vsolat MOD lt_marm-umrez.
          PERFORM f_modify_unit CHANGING lv_sisa.
          CONDENSE lv_sisa NO-GAPS.
        ENDIF.

        CONCATENATE lv_sisa lv_altme
        INTO gt_out-vsolat
        SEPARATED BY space.

        PERFORM f_convert_material USING gt_ltap-matnr gt_ltap-altme
                                   CHANGING gt_ltap-nista.

        lv_carton  = floor( gt_ltap-nista ).
      ENDIF.

      WRITE lv_carton TO gt_out-cartont UNIT 'KAR'.
      CONDENSE gt_out-cartont NO-GAPS.
      CONCATENATE gt_out-cartont 'CAR'
      INTO gt_out-cartont
      SEPARATED BY space.

      IF gt_ltap-vltyp(1) = 'L'.
        gt_out-loose = 'X'.
      ENDIF.

      APPEND gt_out.
      CLEAR gt_out.
    ENDLOOP.
  ENDIF.


* ADDED
  LOOP AT gt_ltap INTO DATA(ls_ltap).
    READ TABLE gt_out ASSIGNING FIELD-SYMBOL(<fs_out>) WITH KEY lgnum = ls_ltap-lgnum tanum = ls_ltap-tanum.
    IF sy-subrc = 0 AND ls_ltap-lgnum(2) = '19' AND ls_ltap-vltyp = '902'.
      <fs_out>-nlpla = ls_ltap-nlpla.
    ENDIF.
  ENDLOOP.

  IF pa_drukz = '47' OR
    pa_drukz = '41' OR
    pa_drukz = '49'.
    PERFORM f_modify_layout.
  ELSEIF pa_drukz = '48'.
    PERFORM f_modify_48.
    IF so_tknum[] IS INITIAL.
      IF pa_lgnum = 'C40'.
        PERFORM f_modify_layout_shipment5.
      ELSE.
        PERFORM f_modify_layout.
      ENDIF.
    ELSE.
      IF pa_lgnum = 'C40'.
        IF ( pa_druck IS INITIAL AND pa_akhir IS INITIAL ) OR ( pa_druck IS INITIAL AND pa_akhir IS NOT INITIAL ).
          PERFORM f_modify_layout_shipment3.
        ELSEIF pa_druck IS NOT INITIAL AND pa_akhir IS NOT INITIAL.
          PERFORM f_modify_layout_shipment4.
*        ELSE.
*          PERFORM f_modify_layout_shipment2.
        ENDIF.
      ELSE.
        PERFORM f_modify_layout_shipment.
      ENDIF.
    ENDIF.
  ENDIF.





  CASE pa_lgnum.
    WHEN '021'.
      IF pa_d2 = 'X' AND pa_drukz = '46'.
        PERFORM f_modify_layout_shipment2.
      ELSEIF pa_d2 = space AND pa_drukz = '46'.
        PERFORM f_modify_layout_shipment.
      ENDIF.
  ENDCASE.

  IF pa_lgnum = 'C40' AND pa_drukz = '47'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vttp
      FROM vttp FOR ALL ENTRIES IN gt_ltak
      WHERE vbeln = gt_ltak-vbeln.
    LOOP AT gt_out INTO DATA(gs_out).
      READ TABLE gt_vttp INTO DATA(gs_vttp) WITH KEY vbeln = gs_out-vbeln.
      IF sy-subrc = 0.
        gs_out-tknum = gs_vttp-tknum.
      ENDIF.
      MODIFY gt_out FROM gs_out TRANSPORTING tknum.
    ENDLOOP.
  ENDIF.
*  DATA: lv_vlpla    TYPE ltap_vlpla,
*        ls_stylerow TYPE lvc_s_styl.
*  IF pa_drukz = '46'.
*    SORT gt_out BY tknum vlpla.
*    LOOP AT gt_out INTO DATA(wa_out).
*      IF lv_vlpla = wa_out-vlpla.
*        lv_vlpla = wa_out-vlpla.
*        CLEAR ls_stylerow.
*        ls_stylerow-fieldname = 'CHECK'.
*        ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
*        APPEND ls_stylerow TO wa_out-style.
*        CLEAR ls_stylerow.
*        ls_stylerow-fieldname = 'LPRIO'.
*        ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
*        APPEND ls_stylerow TO wa_out-style.
*        MODIFY gt_out FROM wa_out TRANSPORTING style.
*      ELSE.
*        lv_vlpla = wa_out-vlpla.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.


*      SORT gt_ltak BY vbeln.
*      LOOP AT gt_out INTO DATA(ls_out).
*        READ TABLE gt_vttp INTO DATA(ls_vttp) WITH KEY vbeln = ls_out-vbeln.
*        IF sy-subrc = 0.
*          ls_out-tknum = ls_vttp-tknum.
*          MODIFY gt_out FROM ls_out TRANSPORTING tknum WHERE vbeln = ls_out-vbeln.
*        ENDIF.
*      ENDLOOP.

*      LOOP AT gt_out ASSIGNING FIELD-SYMBOL(<fs_out2>). "GROUP BY <fs_out2>-queue.
*        IF <fs_out2>-vltyp IS NOT INITIAL AND <fs_out2>-vlpla IS NOT INITIAL.
**        READ TABLE gt_ltak INTO DATA(ls_ltak3) WITH KEY vbeln = <fs_out2>-vbeln.
**        IF sy-subrc = 0.
*          IF temp_vltyp NE <fs_out2>-vltyp AND temp_vlpla NE <fs_out2>-vlpla.
*            temp_vltyp = <fs_out2>-vltyp.
*            temp_vlpla = <fs_out2>-vlpla.
*            PERFORM f_get_num CHANGING number.
*            <fs_out2>-lznum = number.
*          ELSE.
*            <fs_out2>-lznum = number.
*          ENDIF.
**      ENDIF.
*        ENDIF.
*      ENDLOOP.

  IF pa_drukz = '50'.
    LOOP AT gt_temp_sf4 INTO gs_temp_sf4.
      READ TABLE gt_mlgn INTO gs_mlgn WITH KEY matnr = gs_temp_sf4-matnr.
      IF sy-subrc = 0.
        gs_count_pallet-matnr = gs_temp_sf4-matnr.
        gs_count_pallet-pallet = gs_temp_sf4-menge / gs_mlgn-lhmg1.
        IF gs_count_pallet-pallet < 1.
          gs_count_pallet-pallet = 1.
        ENDIF.
        DATA: round_pallet     TYPE p DECIMALS 2,
              calc_pallet      TYPE p DECIMALS 2,
              initial          TYPE p DECIMALS 2 VALUE '0.00',
              int_round_pallet TYPE i,
              count_pallet     TYPE i.
        CLEAR: count_pallet.
        round_pallet = trunc( gs_count_pallet-pallet ).
        int_round_pallet = round_pallet.
        calc_pallet = gs_count_pallet-pallet - round_pallet.
        DO int_round_pallet TIMES.
          ADD 1 TO count_pallet.
          gs_calc-pallet = count_pallet.
          gs_calc-matnr = gs_temp_sf4-matnr.
          IF int_round_pallet = 1.
            IF calc_pallet > initial.
              gs_calc-lhmg1 = gs_mlgn-lhmg1.
            ELSE.
              gs_calc-lhmg1 = gs_temp_sf4-menge.
            ENDIF.
          ELSE.
            gs_calc-lhmg1 = gs_mlgn-lhmg1.
          ENDIF.
          DATA: lv_mod TYPE i,
                lv_div TYPE i.
          DATA : lv_umrez  TYPE marm-umrez.
          CLEAR : lv_umrez.
          SELECT SINGLE umrez
            FROM marm
            INTO lv_umrez
            WHERE matnr = gs_temp_sf4-matnr
              AND meinh = 'KAR'.
          IF sy-subrc = 0.
            CLEAR : lv_mod, lv_div.
            lv_mod    = gs_calc-lhmg1 MOD lv_umrez.
            lv_div    = gs_calc-lhmg1 DIV lv_umrez.
            gs_calc-carton = lv_div.
            gs_calc-ecer = lv_mod.
          ENDIF.
          IF int_round_pallet > 2.
            gs_calc-total_pallet = int_round_pallet + 1.
          ELSEIF int_round_pallet = 1.
            gs_calc-total_pallet = int_round_pallet.
          ENDIF.
          IF calc_pallet > initial.
            gs_calc-total_pallet = gs_calc-total_pallet + 1.
          ENDIF.
          APPEND gs_calc TO gt_calc.
        ENDDO.
        IF calc_pallet > initial.
          ADD 1 TO count_pallet.
          gs_calc-pallet = count_pallet.
          gs_calc-matnr = gs_temp_sf4-matnr.
          gs_calc-lhmg1 = gs_temp_sf4-menge - ( int_round_pallet *  gs_mlgn-lhmg1 ).
          CLEAR : lv_umrez.
          SELECT SINGLE umrez
            FROM marm
            INTO lv_umrez
            WHERE matnr = gs_temp_sf4-matnr
              AND meinh = 'KAR'.
          IF sy-subrc = 0.
            CLEAR : lv_mod, lv_div.
            lv_mod    = gs_calc-lhmg1 MOD lv_umrez.
            lv_div    = gs_calc-lhmg1 DIV lv_umrez.
            gs_calc-carton = lv_div.
            gs_calc-ecer = lv_mod.
          ENDIF.
*          gs_calc-total_pallet = gs_calc-total_pallet + 1.
          APPEND gs_calc TO gt_calc.
        ENDIF.
        APPEND gs_count_pallet TO gt_count_pallet.
      ENDIF.
      CLEAR: gs_calc.
    ENDLOOP.

    LOOP AT gt_calc INTO gs_calc.
      READ TABLE  gt_temp_sf4 INTO gs_temp_sf4 WITH KEY matnr = gs_calc-matnr.
      IF sy-subrc = 0.
        gs_04-matnr = gs_temp_sf4-matnr.
        gs_04-maktx = gs_temp_sf4-maktx.
        gs_04-ebeln = gs_temp_sf4-ebeln.
        gs_04-vfdat = gs_temp_sf4-vfdat.
        gs_04-charg = gs_temp_sf4-charg.
        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
          EXPORTING
            input  = gs_temp_sf4-meins
          IMPORTING
            output = gs_temp_sf4-meins.
        gs_04-meins = gs_temp_sf4-meins.
        gs_04-mblnr = gs_temp_sf4-mblnr.
        gs_04-lifnr = gs_temp_sf4-lifnr.
        gs_04-hsdat = gs_temp_sf4-hsdat.
        READ TABLE gt_mkpf INTO gs_mkpf WITH KEY mblnr = gs_temp_sf4-mblnr.
        IF sy-subrc = 0.
          gs_04-budat = gs_mkpf-budat.
        ENDIF.
        gs_04-pallet = gs_calc-pallet.
        gs_04-qty = gs_calc-lhmg1.
        gs_04-carton = gs_calc-carton.
        gs_04-ecer = gs_calc-ecer.
        gs_04-qty_car_ecer = |{ gs_04-qty } { gs_04-meins } = { gs_04-carton } CAR + { gs_04-ecer } { gs_04-meins }|.
        gs_04-total_pallet = gs_calc-total_pallet.
        DATA: pallet_string       TYPE char10,
              total_pallet_string TYPE char10.
        pallet_string = gs_04-pallet.
        CONDENSE pallet_string NO-GAPS.
        total_pallet_string = gs_04-total_pallet.
        CONDENSE total_pallet_string NO-GAPS.
        CONCATENATE pallet_string '/' total_pallet_string INTO gs_04-pallet_per_total.
        APPEND gs_04 TO gt_04.
      ENDIF.
    ENDLOOP.
*    LOOP AT gt_temp_sf4 INTO gs_temp_sf4.
*      gs_04-matnr = gs_temp_sf4-matnr.
*      gs_04-maktx = gs_temp_sf4-maktx.
*      gs_04-ebeln = gs_temp_sf4-ebeln.
*      gs_04-vfdat = gs_temp_sf4-vfdat.
*      gs_04-charg = gs_temp_sf4-charg.
*      gs_04-meins = gs_temp_sf4-meins.
*      gs_04-mblnr = gs_temp_sf4-mblnr.
*      READ TABLE gt_mkpf INTO gs_mkpf WITH KEY mblnr = gs_temp_sf4-mblnr.
*      IF sy-subrc = 0.
*        gs_04-budat = gs_temp_sf4-budat.
*      ENDIF.
*      READ TABLE gt_mlgn INTO gs_mlgn WITH KEY matnr = gs_temp_sf4-matnr.
*      IF sy-subrc = 0.
*
*      ENDIF.
*      APPEND gs_04 TO gt_04.
*    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA : lt_dynpread LIKE dynpread OCCURS 0 WITH HEADER LINE,
         ls_out      LIKE LINE OF gt_out.

  REFRESH: lt_dynpread.

  IF ref_grid IS NOT INITIAL.
    CALL METHOD ref_grid->check_changed_data( ).
  ENDIF.

  CASE fu_ucomm.
    WHEN '&IC1'.
      IF pa_drukz = '48'.
        READ TABLE gt_out INTO ls_out INDEX 1.
        IF ls_out-lgbzo IS INITIAL.
          PERFORM f_get_staging.
        ENDIF.
      ENDIF.

    WHEN '&SALL'.
      PERFORM f_select USING 'X'.
      CALL METHOD ref_grid->refresh_table_display.
*      LOOP AT gt_out.
*        gt_out-check = 'X'.
*        MODIFY gt_out TRANSPORTING check.
*      ENDLOOP.

    WHEN '&DSAL'.
      PERFORM f_select USING ''.
      CALL METHOD ref_grid->refresh_table_display.
*      LOOP AT gt_out.
*        gt_out-check = space.
*        MODIFY gt_out TRANSPORTING check.
*      ENDLOOP.
    WHEN '&PRE'.
      IF pa_drukz = '46'.
        PERFORM f_print_form TABLES gt_out USING fu_ucomm.
      ENDIF.
    WHEN '&POS' OR '&PREV' OR '&GRP'.
      IF pa_lprio = 'X'.
        LOOP AT gt_lprio INTO DATA(ls_lprio) WHERE check = 'X'.
          PERFORM f_update_ltak USING ls_lprio-lgnum ls_lprio-tknum ls_lprio-lprio.
        ENDLOOP.
        CALL METHOD ref_grid->refresh_table_display.
      ELSE.
        IF pa_drukz = '50'.
          PERFORM f_print_form_50 TABLES gt_04.
        ENDIF.
        IF pa_drukz = '48'.
          CASE pa_lgnum.
            WHEN 'C40'.
*              READ TABLE gt_out INTO ls_out INDEX 1.
*              IF ls_out-lgbzo IS NOT INITIAL.
              PERFORM f_print_form_48 USING fu_ucomm.
*              ELSE.
*                MESSAGE s000(zab) WITH 'Staging Area harus diisi' DISPLAY LIKE 'E'.
*              ENDIF.
            WHEN OTHERS.
              PERFORM f_print_form_48 USING fu_ucomm.
          ENDCASE.
        ELSEIF pa_drukz = '46'.
          IF pa_d2 = space.
*          SORT gt_out BY vlpla.
*          DATA: temp_vlpla TYPE ltap-vlpla.
*          LOOP AT gt_out ASSIGNING FIELD-SYMBOL(<ft_out>).
*            IF <ft_out>-vlpla(3) = 'FLC'.
*              CONTINUE.
*            ELSE.
*              IF temp_vlpla NE <ft_out>-vlpla.
*                temp_vlpla = <ft_out>-vlpla.
*                PERFORM f_get_num CHANGING number.
*                <ft_out>-lznum = number.
*                PERFORM update_additional_number USING <ft_out>-lznum <ft_out>-lgnum <ft_out>-vlpla.
*              ELSE.
*                <ft_out>-lznum = number.
*              PERFORM update_additional_number USING <ft_out>-lznum <ft_out>-lgnum <ft_out>-vlpla.
*              ENDIF.
*            ENDIF.
*          ENDLOOP.
            DATA: temp_vltyp TYPE ltap-vltyp,
                  temp_vlpla TYPE ltap-vlpla.
            SORT gt_out BY vltyp vlpla.
            LOOP AT gt_out ASSIGNING FIELD-SYMBOL(<fs_out2>). "GROUP BY <fs_out2>-queue.
              IF <fs_out2>-vltyp IS NOT INITIAL AND <fs_out2>-vlpla IS NOT INITIAL.
                IF <fs_out2>-vlpla(3) = 'FLC'.
                  CONTINUE.
                ELSE.
                  IF temp_vltyp NE <fs_out2>-vltyp OR temp_vlpla NE <fs_out2>-vlpla.
                    temp_vltyp = <fs_out2>-vltyp.
                    temp_vlpla = <fs_out2>-vlpla.
                    PERFORM f_get_num CHANGING number.
                    <fs_out2>-lznum = number.
                    TRY.
                        UPDATE ltak SET lznum = <fs_out2>-lznum WHERE lgnum = <fs_out2>-lgnum AND tanum = <fs_out2>-tanum.
                      CATCH cx_sy_open_sql_db.
                        sy-subrc = 4.
                    ENDTRY.
                    IF sy-subrc = 0.
                      COMMIT WORK AND WAIT.
                    ENDIF.
                  ELSEIF temp_vltyp = <fs_out2>-vltyp AND temp_vlpla = <fs_out2>-vlpla.
                    <fs_out2>-lznum = number.
                    TRY.
                        UPDATE ltak SET lznum = <fs_out2>-lznum WHERE lgnum = <fs_out2>-lgnum AND tanum = <fs_out2>-tanum.
                      CATCH cx_sy_open_sql_db.
                        sy-subrc = 4.
                    ENDTRY.
                    IF sy-subrc = 0.
                      COMMIT WORK AND WAIT.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDLOOP.

*            DATA: temp_vltyp TYPE ltap-vltyp,
*                  temp_vlpla TYPE ltap-vlpla,
*                  temp_tknum TYPE vttp-tknum.
*
*            DATA(gt_out2) = gt_out[].
*            DELETE gt_out2 WHERE check = space.
*
*            SORT gt_out BY tknum vltyp vlpla.
*            LOOP AT gt_out ASSIGNING FIELD-SYMBOL(<fs_out2>). "GROUP BY <fs_out2>-queue.
*              READ TABLE gt_out2 INTO DATA(ls_out2) WITH KEY tknum = <fs_out2>-tknum.
*              IF sy-subrc = 0.
*                IF <fs_out2>-vltyp IS NOT INITIAL AND <fs_out2>-vlpla IS NOT INITIAL AND <fs_out2>-tknum IS NOT INITIAL.
*                  IF <fs_out2>-vlpla(3) = 'FLC'.
*                    CONTINUE.
*                  ELSE.
*                    IF temp_vltyp NE <fs_out2>-vltyp OR temp_vlpla NE <fs_out2>-vlpla OR temp_tknum NE <fs_out2>-tknum.
*                      temp_vltyp = <fs_out2>-vltyp.
*                      temp_vlpla = <fs_out2>-vlpla.
*                      temp_tknum = <fs_out2>-tknum.
*                      PERFORM f_get_num CHANGING number.
*                      <fs_out2>-lznum = number.
*                      TRY.
*                          UPDATE ltak SET lznum = <fs_out2>-lznum WHERE lgnum = <fs_out2>-lgnum AND tanum = <fs_out2>-tanum.
*                        CATCH cx_sy_open_sql_db.
*                          sy-subrc = 4.
*                      ENDTRY.
*                      IF sy-subrc = 0.
*                        COMMIT WORK AND WAIT.
*                      ENDIF.
*                    ELSEIF temp_vltyp = <fs_out2>-vltyp AND temp_vlpla = <fs_out2>-vlpla AND temp_tknum = <fs_out2>-tknum.
*                      <fs_out2>-lznum = number.
*                      TRY.
*                          UPDATE ltak SET lznum = <fs_out2>-lznum WHERE lgnum = <fs_out2>-lgnum AND tanum = <fs_out2>-tanum.
*                        CATCH cx_sy_open_sql_db.
*                          sy-subrc = 4.
*                      ENDTRY.
*                      IF sy-subrc = 0.
*                        COMMIT WORK AND WAIT.
*                      ENDIF.
*                    ENDIF.
*                  ENDIF.
*                ENDIF.
*              ENDIF.
*            ENDLOOP.
*            PERFORM f_print_form TABLES gt_out USING fu_ucomm.
*          ELSE.
*            PERFORM f_print_form TABLES gt_out USING fu_ucomm.
          ENDIF.
        ELSE.
          PERFORM f_post_entries USING fu_ucomm.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries USING fu_ucomm.
  DATA : lt_out       LIKE gt_out OCCURS 0 WITH HEADER LINE.
  DATA : lv_lines     TYPE i.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check IS INITIAL.

  PERFORM f_print_form TABLES lt_out
                       USING fu_ucomm.

  IF gv_subrc <> 0.
    MESSAGE s000(zab) WITH 'Print code error' DISPLAY LIKE 'E'.
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
  LOOP AT SCREEN.
    IF screen-group1 = 'PFR'.
      screen-active  = '0'.
      MODIFY SCREEN.
      EXIT.
    ENDIF.
  ENDLOOP.


  IF pa_lgnum(1) = 'C' AND
    pa_drukz = '48'.
    IF so_tknum[] IS INITIAL.
      LOOP AT SCREEN.
        IF screen-group1 = 'PTO'.
          screen-active  = '0'.
          MODIFY SCREEN.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    CASE pa_lgnum.
      WHEN 'C40'.
        LOOP AT SCREEN.
          IF screen-name = 'SO_TKNUM-HIGH' OR
            screen-name = '%_SO_TKNUM_%_APP_%-VALU_PUSH'.
            screen-active  = '0'.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      WHEN OTHERS.
        LOOP AT SCREEN.
          IF screen-group1 = 'LPR'.
            screen-active  = '0'.
            MODIFY SCREEN.
            EXIT.
          ENDIF.
        ENDLOOP.
    ENDCASE.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'PAK'.
        screen-active  = '0'.
        MODIFY SCREEN.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

*  IF pa_drukz <> '48'.
*    PERFORM f_modify_screen USING : 'STK' '0' '' '' '',
*                                    'SKU' '0' '' '' ''.
*  ENDIF.

  IF pa_drukz <> '46'.
    PERFORM f_modify_screen USING : 'PT2' '0' '' '' '' ''.
  ENDIF.

  IF pa_drukz = '46'.
    PERFORM f_modify_screen USING : 'SKU' '0' '' '' '' ''.
  ELSEIF pa_drukz <> '48'.
    PERFORM f_modify_screen USING : 'STK' '0' '' '' '' '',
                                    'SKU' '0' '' '' '' ''.
  ENDIF.

  IF pa_drukz = '50'.
    LOOP AT SCREEN.
      IF screen-name = 'SO_MBLNR-LOW'.
        screen-required  = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
*    PERFORM f_modify_screen USING : 'MBL' '' '' '' '' '1'.

  ENDIF.

*  IF pa_lgnum = 'C40' AND pa_drukz = '48'.
*     LOOP AT SCREEN.
*      IF screen-group1 = 'STK'.
*        screen-required  = '0'.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA : lv_subrc   TYPE sy-subrc.

  IF so_mblnr[] IS INITIAL AND
    so_tanum[] IS INITIAL.
*    PERFORM f_error_message USING 'MBL' 'TAN'
*                                   'Material Doc. or TO Number required entry fields'.
  ENDIF.

  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      CASE pa_lgnum.
        WHEN 'C40'.
          IF pa_lprio = 'X'.
            IF so_tknum[] IS INITIAL.
              PERFORM f_error_message USING 'STK' '' ''.
            ENDIF.
          ELSE.
            IF pa_drukz = '48' AND
             pa_akhir IS INITIAL.
              IF so_tknum[] IS INITIAL.
*                PERFORM f_error_message USING 'STK' '' ''.
              ELSE.
                PERFORM f_shipment_count CHANGING lv_subrc.
                IF lv_subrc = 0.
                  PERFORM f_shipment_start CHANGING lv_subrc.
                ENDIF.
              ENDIF.
            ENDIF.
*            IF pa_drukz = '48' AND
*              pa_akhir IS INITIAL.
*              IF so_tknum[] IS INITIAL.
*                PERFORM f_error_message USING 'STK' '' ''.
*              ELSE.
*                PERFORM f_shipment_count CHANGING lv_subrc.
*                IF lv_subrc = 0.
*                  PERFORM f_shipment_start CHANGING lv_subrc.
*                ENDIF.
*              ENDIF.
*            ENDIF.
          ENDIF.
        WHEN OTHERS.
          CLEAR pa_lprio.
          IF pa_lprio = 'X'.
            MESSAGE 'Update DO priority hanya utk C40' TYPE 'E'.
          ENDIF.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form  TABLES   ft_out STRUCTURE gt_out
                   USING    fu_ucomm.

  DATA : lv_fname  TYPE tdsfname,
         lv_number TYPE numc15,
         lv_lznum  TYPE ltak-lznum,
         lv_subrc  TYPE sy-subrc.

  CASE pa_drukz.
    WHEN '41'.
      IF pa_lgnum = 'C40'.
        lv_fname = 'ZMF_IND_PICKLIST_2'.
      ELSE.
        lv_fname  = 'ZMF_IND_PICKLIST'.
      ENDIF.
      PERFORM f_41 TABLES ft_out
                   USING lv_fname.

      LOOP AT ft_out.
        UPDATE ltak SET drukz = pa_drukz
                        druck = 'X'
                    WHERE lgnum EQ ft_out-lgnum
                      AND tanum EQ ft_out-tanum.
      ENDLOOP.
    WHEN '45'.
      lv_fname  = 'ZDGWM_003'.
      IF pa_lgnum = '051' OR
        pa_lgnum = '053' OR
        pa_lgnum = '380'.
        lv_fname  = 'ZDGWM_003_A6'.

        PERFORM f_45 TABLES ft_out
                     USING lv_fname ''.
      ELSEIF pa_lgnum(1) = 'C'.
        lv_fname  = 'ZDGWM_003_LBL'.

        PERFORM f_45 TABLES ft_out
                     USING lv_fname 'X'.
      ELSEIF pa_lgnum(2) = '36'.
        lv_fname  = 'ZKMMWM_SF001_A4'.

        PERFORM f_45x TABLES ft_out
                      USING lv_fname 'X'.
      ELSEIF pa_lgnum(2) = '19'.
        lv_fname  = 'ZKMMWM_SF001_A4'.

        PERFORM f_45x TABLES ft_out
                      USING lv_fname 'X'.
      ELSE.
        PERFORM f_45 TABLES ft_out
                     USING lv_fname ''.
      ENDIF.


    WHEN '46'.
      lv_fname = 'ZMPICK_TICKET2'.
      PERFORM f_46 TABLES ft_out USING lv_fname.
    WHEN '47'.
      IF pa_lgnum(2) = '38'.
        lv_fname  = 'ZTDNMMSF002'.
        PERFORM f_47_tdn TABLES ft_out
                         USING lv_fname pa_spld.
      ELSEIF pa_lgnum(1) = 'C'.
        PERFORM f_modify_lprio TABLES ft_out.
        lv_fname  = 'ZPICK_LABEL'.
        PERFORM f_47 TABLES ft_out
                     USING lv_fname.
      ELSE.
        lv_fname  = 'ZPICK_LABEL'.
        PERFORM f_47 TABLES ft_out
                     USING lv_fname.
      ENDIF.

    WHEN '49'.
      lv_fname  = 'ZPICK_LABEL'.
      PERFORM f_47 TABLES ft_out
                   USING lv_fname.

    WHEN '48'.
      lv_fname  = 'ZMF_IND_PICKLIST'.
      IF so_tknum[] IS INITIAL.
        PERFORM f_48 TABLES ft_out
                     USING lv_fname fu_ucomm
                     CHANGING lv_number.
      ELSE.
        PERFORM f_48_shipment TABLES ft_out
                              USING lv_fname fu_ucomm.
      ENDIF.

      CASE fu_ucomm.
        WHEN '&POS'.
          IF so_tknum[] IS INITIAL.
            lv_lznum  = lv_number.
            CONDENSE lv_lznum NO-GAPS.
            LOOP AT ft_out.
              UPDATE ltak SET drukz = pa_drukz
                              druck = 'X'
                              lznum = lv_lznum
                          WHERE lgnum EQ ft_out-lgnum
                            AND tanum EQ ft_out-tanum.
            ENDLOOP.
          ELSE.
          ENDIF.

        WHEN '&GRP'.
          IF so_tknum[] IS INITIAL.
            lv_lznum  = lv_number.
            CONDENSE lv_lznum NO-GAPS.
            LOOP AT ft_out.
              PERFORM f_check_grouping USING ft_out-lgnum ft_out-tanum
                                       CHANGING lv_subrc.
              IF lv_subrc = 0.
                ft_out-lznum  = lv_lznum.
                MODIFY gt_out FROM ft_out
                              TRANSPORTING lznum
                              WHERE lgnum EQ ft_out-lgnum
                                AND tanum EQ ft_out-tanum.

                UPDATE ltak SET lznum = lv_lznum
                            WHERE lgnum EQ ft_out-lgnum
                              AND tanum EQ ft_out-tanum.
              ELSE.
                ft_out-check  = space.
                MODIFY gt_out FROM ft_out
                              TRANSPORTING check
                              WHERE lgnum EQ ft_out-lgnum
                                AND tanum EQ ft_out-tanum.
              ENDIF.
            ENDLOOP.
          ELSE.
            PERFORM f_grouping.
          ENDIF.
      ENDCASE.
  ENDCASE.

  IF fu_ucomm <> '&GRP'.
    IF pa_form IS NOT INITIAL.
      LOOP AT ft_out.
        UPDATE ltak SET drukz = pa_drukz
                        druck = 'X'
                    WHERE lgnum EQ ft_out-lgnum
                      AND tanum EQ ft_out-tanum.
      ENDLOOP.
    ELSE.
      IF pa_drukz = '47' OR
        pa_drukz = '49'.
        LOOP AT ft_out.
          UPDATE ltak SET druck = 'X'
                      WHERE lgnum EQ ft_out-lgnum
                        AND tanum EQ ft_out-tanum.
        ENDLOOP.
      ENDIF.
    ENDIF.

    CASE sy-ucomm.
      WHEN 'PRNT' OR 'SPRI'.
        CASE pa_drukz.
          WHEN '48'.
            IF so_tknum[] IS INITIAL.
              LOOP AT ft_out.
                UPDATE ltak SET drukz = pa_drukz
                                druck = 'X'
                            WHERE lgnum EQ ft_out-lgnum
                              AND tanum EQ ft_out-tanum.
              ENDLOOP.
            ELSE.
              LOOP AT ft_out.
*****                UPDATE ltak SET drukz = pa_drukz
*****                                druck = 'X'
*****                            WHERE lgnum EQ ft_out-lgnum
*****                              AND tanum EQ ft_out-tanum.
              ENDLOOP.
            ENDIF.
          WHEN OTHERS.
            LOOP AT ft_out.
              UPDATE ltak SET drukz = pa_drukz
                              druck = 'X'
                          WHERE lgnum EQ ft_out-lgnum
                            AND tanum EQ ft_out-tanum.
            ENDLOOP.
        ENDCASE.
        LEAVE TO SCREEN 0.
    ENDCASE.
  ENDIF.

*  IF pa_lgnum = '190'.
*    IF pa_form IS INITIAL.
*      MESSAGE s000(zab) WITH 'Data already print'.
*      LEAVE TO SCREEN 0.
*    ENDIF.
*  ENDIF.
ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_grp01 fu_grp02 fu_text.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_text IS NOT INITIAL.
    lv_mess  = fu_text.
  ENDIF.

  IF fu_grp01 IS INITIAL AND
    fu_grp02 IS INITIAL.
    MESSAGE s000(zab) WITH lv_mess DISPLAY LIKE 'E'.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = fu_grp01 OR
         screen-group1 = fu_grp02.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_MATERIAL
*&---------------------------------------------------------------------*
FORM f_convert_material  USING    fu_matnr fu_altme
                         CHANGING fc_amount.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      i_matnr              = fu_matnr
      i_in_me              = fu_altme
      i_out_me             = 'KAR'
      i_menge              = fc_amount
    IMPORTING
      e_menge              = fc_amount
    EXCEPTIONS
      error_in_application = 1
      error                = 2
      OTHERS               = 3.
ENDFORM.                    " F_CONVERT_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_UNIT
*&---------------------------------------------------------------------*
FORM f_modify_unit  CHANGING fu_value.
  DATA : lv_subrc   TYPE sy-subrc.

  WHILE lv_subrc = 0.
    REPLACE '.' IN fu_value WITH space.
    lv_subrc = sy-subrc.
    CHECK lv_subrc IS NOT INITIAL.
    REPLACE ',' IN fu_value WITH space.
    lv_subrc = sy-subrc.
  ENDWHILE.
ENDFORM.                    " F_MODIFY_UNIT

*&---------------------------------------------------------------------*
*&      Form  F_45
*&---------------------------------------------------------------------*
FORM f_45  TABLES   ft_out STRUCTURE gt_out
           USING    fu_fname fu_dest.

  DATA : l_funcname          TYPE tdsfname.

  DATA : lwa_control_option TYPE ssfctrlop,
         lwa_output_option  TYPE ssfcompop,
         ls_header          TYPE zwmprntto,
         ls_out             LIKE gt_out,
         ls_t329d           LIKE LINE OF gt_t329d,
         lv_ldest           TYPE t329d-ldest,
         ls_013             TYPE zwmdt013,
         lv_tanum           TYPE ltak-tanum,
         lv_benum           TYPE ltak-benum,
         lv_pallet(10).

  CHECK fu_fname IS NOT INITIAL.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = fu_fname
    IMPORTING
      fm_name            = l_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  CLEAR ls_out.

  LOOP AT ft_out INTO ls_out.
    MOVE-CORRESPONDING ls_out TO ls_header.

    AT FIRST.
      lwa_control_option-no_close = 'X'.
    ENDAT.

    AT LAST.
      lwa_control_option-no_close = space.
    ENDAT.

    CLEAR : ls_t329d, ls_013, lv_ldest.

    IF fu_dest IS NOT INITIAL.
      READ TABLE gt_013 INTO ls_013
                        WITH KEY lgnum = ls_header-lgnum.
      IF sy-subrc = 0.
        lv_ldest    = ls_013-padest.
      ELSE.
        READ TABLE gt_t329d INTO ls_t329d
                            WITH KEY nltyp = ls_header-nltyp.
        IF sy-subrc = 0.
          lv_ldest    = ls_t329d-ldest.
        ELSE.
          lv_ldest    = default-spld.
        ENDIF.
      ENDIF.
    ELSE.
      READ TABLE gt_t329d INTO ls_t329d
                          WITH KEY nltyp = ls_header-nltyp.
      IF sy-subrc = 0.
        lv_ldest    = ls_t329d-ldest.
      ELSE.
        lv_ldest    = default-spld.
      ENDIF.
    ENDIF.

    IF fu_fname IS NOT INITIAL.
      IF pa_form IS NOT INITIAL.
        lwa_control_option-no_dialog = 'X'.
      ELSE.
        lwa_control_option-no_dialog = ''.
      ENDIF.

      lwa_output_option-tdnewid    = 'X'.
      lwa_output_option-tdimmed    = 'X'.
      lwa_output_option-tddelete   = ''.
      lwa_output_option-tddest     = lv_ldest.
    ENDIF.

    IF pa_lgnum = '051' OR
      pa_lgnum(1) = 'C'.
      ls_header-judul = 'GOODS RECEIPT LABEL'.
      IF pa_lgnum(1) <> 'C'.
        CLEAR ls_header-qrcode.
      ELSE.
        lv_tanum  = ls_header-tanum.
        SELECT SINGLE zdtsul
          FROM zwmdt004
          INTO ( ls_header-wdatu )
          WHERE lgnum = ls_header-lgnum
            AND tanum = lv_tanum.
        IF sy-subrc <> 0.
          SHIFT lv_tanum LEFT DELETING LEADING '0'.
          CONDENSE ls_header-tanum NO-GAPS.
          SELECT SINGLE zdtsul
            FROM zwmdt004
            INTO ls_header-wdatu
            WHERE lgnum = ls_header-lgnum
              AND tanum = lv_tanum.
        ENDIF.

        lv_tanum  = ls_header-tanum.
        SELECT SINGLE benum
          FROM ltak
          INTO lv_benum
          WHERE lgnum = ls_header-lgnum
            AND tanum = lv_tanum.
        IF lv_benum IS NOT INITIAL.
          SELECT SINGLE vbeln
            FROM vbfa
            INTO ls_header-tknum
            WHERE vbelv   = lv_benum
              AND vbtyp_n = '8'.
        ENDIF.

        CONCATENATE ls_header-matnr ls_header-charg
        INTO ls_header-material
        SEPARATED BY ';'.
      ENDIF.
    ENDIF.

    CALL FUNCTION l_funcname
      EXPORTING
        control_parameters = lwa_control_option
        output_options     = lwa_output_option
        user_settings      = space
        gs_header          = ls_header
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    lwa_control_option-no_open = 'X'.
  ENDLOOP.
ENDFORM.                    " F_45

*&---------------------------------------------------------------------*
*&      Form  F_46
*&---------------------------------------------------------------------*
FORM f_46 TABLES   ft_out STRUCTURE gt_out
           USING    fu_fname.
  DATA : l_funcname TYPE tdsfname.
  DATA : lwa_control_option TYPE ssfctrlop,
         lwa_output_option  TYPE ssfcompop,
*               ls_header          TYPE zwmprntto,
         ls_out             LIKE gt_out,
         it_out             TYPE TABLE OF ty_out,
         lt_detl            TYPE TABLE OF zwmprntto,
         lt_detl2           TYPE TABLE OF zwmprntto,
         lt_detl3           TYPE TABLE OF zwmprntto,
         lt_detl4           TYPE TABLE OF zwmprntto,
         ls_header          TYPE zwmprntto.
*               ls_t329d           LIKE LINE OF gt_t329d,
*               lv_ldest           TYPE t329d-ldest,
*               ls_013             TYPE zwmdt013,
*               lv_tanum           TYPE ltak-tanum,
*               lv_benum           TYPE ltak-benum,
*               lv_pallet(10).

  CHECK fu_fname IS NOT INITIAL.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = fu_fname
    IMPORTING
      fm_name            = l_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

*  IF pa_form IS NOT INITIAL.
**    lwa_control_option-no_dialog = 'X'.
*
*    lwa_output_option-tdnewid    = 'X'.
*    lwa_output_option-tdimmed    = 'X'.
*    lwa_output_option-tddelete   = ''.
*    lwa_output_option-tddest     = default-spld.
*  ENDIF.

  CLEAR: it_out, lt_detl, ls_out.
  it_out[] = ft_out[].
  DELETE it_out WHERE check = space.
  SORT it_out BY lznum matnr.
  SORT ft_out BY lznum matnr.
  DATA: temp_nistm TYPE ltap-nistm.
  DATA: temp_lznum TYPE ltak-lznum.
  DATA: temp_vlpla TYPE ltap-vlpla.
  LOOP AT it_out INTO DATA(ls_out2). "WHERE lznum = it_out[ 1 ]-lznum.
    LOOP AT ft_out INTO DATA(ls_out3) WHERE lznum = ls_out2-lznum AND matnr = ls_out2-matnr AND charg = ls_out2-charg AND vlpla = ls_out2-vlpla.
*    IF sy-subrc = 0.
      IF temp_lznum IS INITIAL AND temp_vlpla IS INITIAL.
        temp_lznum = ls_out3-lznum.
        temp_vlpla = ls_out3-vlpla.
        ADD ls_out3-nistm TO temp_nistm.

      ELSE.
        IF temp_lznum NE ls_out3-lznum.
*          APPEND INITIAL LINE TO lt_detl ASSIGNING FIELD-SYMBOL(<fs_detl>).
*          MOVE-CORRESPONDING ls_out2 TO <fs_detl>.
*          <fs_detl>-nistm = temp_nistm.

*          gs_head = lt_detl[ 1 ].
*          AT FIRST.
*            lwa_control_option-no_close = 'X'.
*          ENDAT.

*          CALL FUNCTION l_funcname
*            EXPORTING
*              control_parameters = lwa_control_option
*              output_options     = lwa_output_option
*              user_settings      = space
*              gs_head            = gs_head
*            TABLES
*              gt_detl            = lt_detl
*            EXCEPTIONS
*              formatting_error   = 1
*              internal_error     = 2
*              send_error         = 3
*              user_canceled      = 4
*              OTHERS             = 5.
*
*          CLEAR: lt_detl.
          CLEAR: temp_nistm.
          temp_lznum = ls_out3-lznum.
          ADD ls_out3-nistm TO temp_nistm.

        ELSE.
          ADD ls_out3-nistm TO temp_nistm.
        ENDIF.
      ENDIF.
*    ELSE.
*      APPEND INITIAL LINE TO lt_detl ASSIGNING FIELD-SYMBOL(<fs_detl2>).
*      MOVE-CORRESPONDING ls_out TO <fs_detl2>.
*      <fs_detl2>-nistm = temp_nistm.
*      EXIT.
*      gs_head = lt_detl[ 1 ].

*      CALL FUNCTION l_funcname
*        EXPORTING
*          control_parameters = lwa_control_option
*          output_options     = lwa_output_option
*          user_settings      = space
*          gs_head            = gs_head
*        TABLES
*          gt_detl            = lt_detl
*        EXCEPTIONS
*          formatting_error   = 1
*          internal_error     = 2
*          send_error         = 3
*          user_canceled      = 4
*          OTHERS             = 5.
*
*      CLEAR: lt_detl.
*      AT LAST.
*        lwa_control_option-no_close = space.
*      ENDAT.
      APPEND INITIAL LINE TO lt_detl ASSIGNING FIELD-SYMBOL(<fs_detl2>).
      MOVE-CORRESPONDING ls_out3 TO <fs_detl2>.
      <fs_detl2>-nistm = temp_nistm.
    ENDLOOP.
*    APPEND INITIAL LINE TO lt_detl ASSIGNING FIELD-SYMBOL(<fs_detl2>).
*    MOVE-CORRESPONDING ls_out3 TO <fs_detl2>.
*    <fs_detl2>-nistm = temp_nistm.
*    EXIT.
  ENDLOOP.

  DATA: no_rec  TYPE i.
  DATA: flag           TYPE c.
  DATA: temp_lznum2 TYPE ltak-lznum.
  SORT lt_detl BY lznum.
  LOOP AT lt_detl INTO DATA(ls_detl).
    PERFORM f_prepare_46 TABLES lt_detl2 USING ls_detl-lznum ls_detl-vlpla ls_detl-nistm CHANGING ls_header-totalt.
    APPEND LINES OF lt_detl2 TO lt_detl3.
  ENDLOOP.
  DELETE ADJACENT DUPLICATES FROM lt_detl3 COMPARING lznum.
  DESCRIBE TABLE lt_detl3 LINES no_rec.
  LOOP AT lt_detl3 INTO DATA(ls_detl3).
    IF no_rec = 1.
      MOVE-CORRESPONDING ls_detl3 TO ls_header.
      CLEAR: lt_detl4.
      PERFORM f_prepare_46_2 TABLES lt_detl4 USING ls_detl3-matnr ls_detl3-charg ls_detl3-vlpla ls_detl3-maktx ls_detl3-nistm_quan ls_detl3-totalt ls_detl3-vfdat.

      CALL FUNCTION l_funcname
        EXPORTING
          control_parameters = lwa_control_option
          output_options     = lwa_output_option
          gs_head            = ls_header
        TABLES
          gt_detl            = lt_detl4
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.

      IF sy-subrc = 0.

      ENDIF.
    ELSE.
      IF sy-tabix = no_rec.
        flag = '2'.
      ENDIF.

      AT END OF lznum.
        IF flag = space.
          lwa_control_option-no_close = 'X'.
          lwa_control_option-no_open = space.
          flag = '1'.
        ELSEIF flag = '1'.
          lwa_control_option-no_close = 'X'.
          lwa_control_option-no_open = 'X'.
        ELSEIF flag = '2'.
          lwa_control_option-no_close = space.
          lwa_control_option-no_open = 'X'.
        ENDIF.
      ENDAT.
*  AT FIRST.
*    lwa_control_option-no_close = 'X'.
*    lwa_control_option-no_open = space.
*  ENDAT.
*
*  AT LAST.
*    lwa_control_option-no_close = space.
*    lwa_control_option-no_open = 'X'.
*  ENDAT.


      MOVE-CORRESPONDING ls_detl3 TO ls_header.
      CLEAR: lt_detl4.
      PERFORM f_prepare_46_2 TABLES lt_detl4 USING ls_detl3-matnr ls_detl3-charg ls_detl3-vlpla ls_detl3-maktx ls_detl3-nistm_quan ls_detl3-totalt ls_detl3-vfdat.


      CALL FUNCTION l_funcname
        EXPORTING
          control_parameters = lwa_control_option
          output_options     = lwa_output_option
          gs_head            = ls_header
        TABLES
          gt_detl            = lt_detl4
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.

      IF sy-subrc = 0.

      ENDIF.
    ENDIF.
  ENDLOOP.

**
**  LOOP AT ft_out INTO ls_out WHERE check = 'X'.
**    IF ls_out-lznum IS NOT INITIAL.
**      APPEND INITIAL LINE TO lt_detl ASSIGNING FIELD-SYMBOL(<fs_detl>).
**      MOVE-CORRESPONDING ls_out TO <fs_detl>.
**    ENDIF.
**    AT FIRST.
**      lwa_control_option-no_close = 'X'.
**    ENDAT.
**
**    AT LAST.
**      lwa_control_option-no_close = space.
**    ENDAT.
**
**  ENDLOOP.


*  LOOP AT ft_out INTO DATA(ls_out3) GROUP BY ls_out3-lznum.
**    AT FIRST.
**      lwa_control_option-no_close = 'X'.
**    ENDAT.
*    APPEND INITIAL LINE TO lt_detl ASSIGNING FIELD-SYMBOL(<fs_detl2>).
*    MOVE-CORRESPONDING ls_out TO <fs_detl2>.
*    <fs_detl2>-nistm = temp_nistm.
*    CALL FUNCTION l_funcname
*      EXPORTING
*        control_parameters = lwa_control_option
*        output_options     = lwa_output_option
*        user_settings      = space
*      TABLES
*        gt_detl            = lt_detl
*      EXCEPTIONS
*        formatting_error   = 1
*        internal_error     = 2
*        send_error         = 3
*        user_canceled      = 4
*        OTHERS             = 5.
**    AT LAST.
**      lwa_control_option-no_close = space.
**    ENDAT.
*  ENDLOOP.

*LOOP AT lt_detl INTO DATA(ls_detl) GROUP BY ls_detl-lznum.
*    CALL FUNCTION l_funcname
*      EXPORTING
*        control_parameters = lwa_control_option
*        output_options     = lwa_output_option
*        user_settings      = space
*      TABLES
*        gt_detl            = lt_detl
*      EXCEPTIONS
*        formatting_error   = 1
*        internal_error     = 2
*        send_error         = 3
*        user_canceled      = 4
*        OTHERS             = 5.
*ENDLOOP.

*  CALL FUNCTION l_funcname
*    EXPORTING
*      control_parameters = lwa_control_option
*      output_options     = lwa_output_option
*      user_settings      = space
*    TABLES
*      gt_detl            = lt_detl
*    EXCEPTIONS
*      formatting_error   = 1
*      internal_error     = 2
*      send_error         = 3
*      user_canceled      = 4
*      OTHERS             = 5.
*  lwa_control_option-no_open = 'X'.
ENDFORM.



*&---------------------------------------------------------------------*
*&      Form  F_47
*&---------------------------------------------------------------------*
FORM f_47  TABLES   ft_out STRUCTURE gt_out
           USING    fu_fname.

  TYPES : BEGIN OF ty_vbfa,
            vbelv   TYPE vbfa-vbelv,
            posnv   TYPE vbfa-posnv,
            vbeln   TYPE vbfa-vbeln,
            posnn   TYPE vbfa-posnn,
            vbtyp_n TYPE vbfa-vbtyp_n,
          END OF ty_vbfa.

  TYPES : BEGIN OF ty_vbak,
            vbeln TYPE vbak-vbeln,
            bnddt TYPE vbak-bnddt,
          END OF ty_vbak.

  TYPES : BEGIN OF ty_mseg,
            mblnr TYPE mseg-mblnr,
            mjahr TYPE mseg-mjahr,
            zeile TYPE mseg-zeile,
            matnr TYPE mseg-matnr,
            menge TYPE mseg-menge,
          END OF ty_mseg.

  TYPES : BEGIN OF ty_mara,
            matnr TYPE mara-matnr,
            brgew TYPE mara-brgew,
            gewei TYPE mara-gewei,
            volum TYPE mara-volum,
            voleh TYPE mara-voleh,
          END OF ty_mara.

  DATA : l_funcname          TYPE tdsfname.

  DATA : lwa_control_option TYPE ssfctrlop,
         lwa_output_option  TYPE ssfcompop,
         ls_header          TYPE zwmprntto,
         ls_out             LIKE gt_out,
         ls_t329d           LIKE LINE OF gt_t329d,
         lt_ltap            TYPE STANDARD TABLE OF ltap,
         ls_ltap            LIKE LINE OF gt_ltap,
         lv_ldest           TYPE t329d-ldest.

  DATA : lv_vgbel TYPE lips-vgbel,
         lv_bednr TYPE ekpo-bednr,
         lv_jbeln TYPE vbfa-vbeln,
         lv_route TYPE likp-route.

  DATA : lv_btgew       TYPE likp-btgew,
         lv_wgt         TYPE likp-btgew,
         lv_gewei       TYPE likp-gewei,
         lv_volum       TYPE likp-volum,
         lv_vol         TYPE likp-volum,
         lv_voleh       TYPE likp-voleh,
         lv_lfart       TYPE likp-lfart,
         lv_volume(100),
         lv_weight(100),
         lv_count       TYPE p DECIMALS 0,
         lv_mblnr       TYPE ltak-mblnr,
         lv_mjahr       TYPE ltak-mjahr,
         lv_menge       TYPE mseg-menge.

  DATA : lt_vbfa TYPE STANDARD TABLE OF ty_vbfa,
         lt_vbak TYPE STANDARD TABLE OF ty_vbak,
         ls_vbak LIKE LINE OF lt_vbak.

  DATA : lt_xltap TYPE STANDARD TABLE OF ltap,
         ls_xltap LIKE LINE OF lt_xltap.

  DATA : lt_mseg TYPE STANDARD TABLE OF ty_mseg,
         lt_mara TYPE STANDARD TABLE OF ty_mara,
         ls_mseg LIKE LINE OF lt_mseg,
         ls_mara LIKE LINE OF lt_mara.

  CHECK fu_fname IS NOT INITIAL.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = fu_fname
    IMPORTING
      fm_name            = l_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  CLEAR ls_out.

  IF ft_out[] IS NOT INITIAL.
    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE lt_xltap
      FOR ALL ENTRIES IN ft_out
      WHERE lgnum = ft_out-lgnum
        AND tanum = ft_out-tanum.

    SORT lt_xltap BY lgnum tanum matnr.
    DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING lgnum tanum matnr.
  ENDIF.
  IF pa_form IS INITIAL.
    CALL SCREEN 100 STARTING AT 1 1.
  ENDIF.
DATA: temp_vbeln TYPE ltak-vbeln,
      lv_item TYPE i.
  IF sy-ucomm <> 'CANC'.
      LOOP AT ft_out INTO ls_out.
      READ TABLE gt_ltak INTO DATA(ls_ltak2) WITH KEY tanum = ls_out-tanum.
      IF sy-subrc = 0.
        IF temp_vbeln <> ls_ltak2-vbeln.
          CLEAR: lv_item.
          temp_vbeln = ls_ltak2-vbeln.
        ENDIF.
        LOOP AT gt_ltap INTO DATA(ls_ltap2) WHERE tanum = ls_out-tanum.
          ADD 1 TO lv_item.
        ENDLOOP.
        ls_out-no_item = lv_item.
        CONDENSE ls_out-no_item NO-GAPS.
        MODIFY ft_out FROM ls_out TRANSPORTING no_item.
      ENDIF.
    ENDLOOP.
    LOOP AT ft_out INTO ls_out.
      MOVE-CORRESPONDING ls_out TO ls_header.


*    AT FIRST.
*      lwa_control_option-no_close = 'X'.
*    ENDAT.

*    AT LAST.
*      lwa_control_option-no_close = space.
*    ENDAT.

      CLEAR : ls_t329d, lv_ldest.
      READ TABLE gt_t329d INTO ls_t329d
                          WITH KEY nltyp = ls_header-nltyp.
      IF sy-subrc = 0.
        lv_ldest    = ls_t329d-ldest.
      ELSE.
        lv_ldest    = default-spld.
      ENDIF.

      lwa_control_option-no_dialog = 'X'.
      lwa_output_option-tdnewid    = 'X'.
      lwa_output_option-tdimmed    = 'X'.
      lwa_output_option-tddelete   = ''.

      IF pa_form IS NOT INITIAL.
        lwa_output_option-tddest     = lv_ldest.
      ELSE.
        lwa_output_option-tddest     = ssfpp-tddest.
        IF ok_code  = '&PREV'.
          lwa_control_option-preview   = 'X'.
        ENDIF.
      ENDIF.

      ls_header-judul = 'PICKING LABEL'.

      SELECT SINGLE kunnr kdgrp lgtor vkorg route btgew gewei volum voleh lfart
        FROM likp
        INTO (ls_header-kunnr, ls_header-kdgrp, ls_header-lgtor, ls_header-vkorg,
        ls_header-route, lv_btgew, lv_gewei, lv_volum, lv_voleh, lv_lfart)
        WHERE vbeln = ls_header-vbeln.

      IF ls_header-lgnum = 'C05'.
        IF ls_header-vbeln IS INITIAL.
          SELECT mblnr mjahr zeile matnr menge
            FROM mseg
            INTO TABLE lt_mseg
            WHERE mblnr = lv_mblnr
              AND mjahr = lv_mjahr
              AND xauto = space.

          IF lt_mseg[] IS NOT INITIAL.
            SELECT matnr brgew gewei volum voleh
              FROM mara
              INTO TABLE lt_mara
              FOR ALL ENTRIES IN lt_mseg
              WHERE matnr = lt_mseg-matnr.

            LOOP AT lt_mseg INTO ls_mseg.
              CLEAR ls_mara.
              READ TABLE lt_mara INTO ls_mara
                                 WITH KEY matnr = ls_mseg-matnr.
              IF ls_mara-brgew = 0.
                ls_mara-brgew = 1.
              ENDIF.
              IF ls_mara-volum = 0.
                ls_mara-volum = 1.
              ENDIF.
              lv_wgt = ls_mseg-menge * ls_mara-brgew.
              PERFORM f_xunit_conversion USING ls_mara-gewei 'KG'
                                         CHANGING lv_wgt.
              lv_vol = ls_mseg-menge * ls_mara-volum.
              PERFORM f_xunit_conversion USING ls_mara-voleh 'M3'
                                         CHANGING lv_vol.
              ADD lv_wgt TO lv_btgew.
              ADD lv_vol TO lv_volum.
            ENDLOOP.
          ENDIF.
        ELSE.
          PERFORM f_xunit_conversion USING lv_gewei 'KG'
                                     CHANGING lv_btgew.
          PERFORM f_xunit_conversion USING lv_voleh 'M3'
                                     CHANGING lv_volum.
        ENDIF.

        lv_gewei = 'KG'.
        lv_voleh = 'M3'.
        CLEAR lv_count.
        LOOP AT lt_xltap INTO ls_xltap WHERE lgnum = ls_out-lgnum
                                         AND tanum = ls_out-tanum.
          ADD 1 TO lv_count.
        ENDLOOP.
        ls_header-zitem = lv_count.
        CONDENSE ls_header-zitem NO-GAPS.
        CONCATENATE 'Itm:' ls_header-zitem INTO ls_header-zitem.
      ENDIF.

      PERFORM f_unit_conversion USING lv_btgew lv_gewei
                                CHANGING ls_header-weight.
      PERFORM f_unit_conversion USING lv_volum lv_voleh
                                CHANGING ls_header-volume.

      PERFORM f_get_max_time_picking USING ls_header-vbeln ls_header-lgtor
                                           ls_header-kdgrp ls_header-vkorg
                                     CHANGING ls_header-kodat ls_header-kouhr.

      PERFORM f_calculate_carton USING ls_header-lgnum ls_header-tanum
                                 CHANGING ls_header-carton ls_header-receh.

      SELECT vbelv posnv vbeln posnn vbtyp_n
        FROM vbfa
        INTO TABLE lt_vbfa
        WHERE vbeln   = ls_header-vbeln
          AND vbtyp_n = 'J'.

      SORT lt_vbfa BY vbelv.
      DELETE ADJACENT DUPLICATES FROM lt_vbfa COMPARING vbelv.
      IF lt_vbfa[] IS NOT INITIAL.
        SELECT vbeln bnddt
          FROM vbak
          INTO TABLE lt_vbak
          FOR ALL ENTRIES IN lt_vbfa
          WHERE vbeln = lt_vbfa-vbelv.
      ENDIF.

      LOOP AT lt_vbak INTO ls_vbak.
        ls_header-bnddt = ls_vbak-bnddt.
        IF ls_header-bnddt IS NOT INITIAL.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_lfart = 'NLCC'.
        SELECT SINGLE vgbel
          FROM lips
          INTO lv_vgbel
          WHERE vbeln = ls_header-vbeln.

        SELECT SINGLE bednr
          FROM ekpo
          INTO lv_bednr
          WHERE ebeln = lv_vgbel.

        SELECT SINGLE vbeln
          FROM vbfa
          INTO lv_jbeln
          WHERE vbelv   = lv_bednr
            AND vbtyp_n = 'J'.

        SELECT SINGLE route
          FROM likp
          INTO lv_route
          WHERE vbeln = lv_jbeln.

        SELECT SINGLE kunnr
          FROM vbak
          INTO ls_header-kunnr
          WHERE vbeln = lv_bednr.
      ENDIF.

      SELECT SINGLE name1 lzone ort01
        FROM kna1
        INTO (ls_header-name1p, ls_header-lzone, ls_header-ort01)
        WHERE kunnr = ls_header-kunnr.

      IF lv_route IS NOT INITIAL.
        ls_header-lzone = lv_route.
      ENDIF.

      SELECT SINGLE bezei
        FROM tvrot
        INTO ls_header-bezei
        WHERE route = ls_header-route.

      SELECT SINGLE vtext
        FROM tzont
        INTO ls_header-vtext
        WHERE spras = sy-langu
          AND zone1 = ls_header-lzone.

      CALL FUNCTION l_funcname
        EXPORTING
          control_parameters = lwa_control_option
          output_options     = lwa_output_option
          user_settings      = space
          gs_header          = ls_header
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.

*    lwa_control_option-no_open = 'X'.

      CLEAR : lv_route.
    ENDLOOP.


    MESSAGE s000(zab) WITH 'Print complete'.
  ENDIF.
ENDFORM.                    " F_47

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_LAYOUT
*&---------------------------------------------------------------------*
FORM f_modify_layout .
  DATA : lt_out  TYPE STANDARD TABLE OF ty_out WITH HEADER LINE.

  DATA : lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.

  DATA : lv_flag.

  lt_out[] = gt_out[].
  DELETE ADJACENT DUPLICATES FROM lt_out COMPARING tanum.

  LOOP AT lt_out.
    CLEAR lv_flag.
    LOOP AT gt_out WHERE tanum = lt_out-tanum.
      IF lv_flag IS NOT INITIAL.
        ls_stylerow-fieldname = 'CHECK'.
        ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.

        APPEND ls_stylerow TO gt_out-style.
        MODIFY gt_out.
      ELSE.
*        IF pa_drukz = '48'.
*          IF gt_out-lznum IS NOT INITIAL.
*            ls_stylerow-fieldname = 'CHECK'.
*            ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
*
*            APPEND ls_stylerow TO gt_out-style.
*            MODIFY gt_out.
*          ENDIF.
*        ENDIF.
      ENDIF.
      lv_flag = 'X'.
      CLEAR : gt_out-style[], ls_stylerow.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_LAYOUT


*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_LAYOUT_SHIPMENT
*&---------------------------------------------------------------------*
FORM f_modify_layout_shipment2 .
  DATA : lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout,
         ls_out  LIKE LINE OF gt_out.

  DATA : lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.

  DATA : lv_flag.

  SORT gt_out BY tknum vlpla."kober tanum.

  lt_xout[] = gt_out[].
  SORT lt_xout BY tknum vlpla."lznum .
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING tknum vlpla."lznum.
  IF lt_xout[] IS NOT INITIAL.
    LOOP AT lt_xout INTO ls_xout.
      CLEAR lv_flag.
      LOOP AT gt_out INTO ls_out WHERE tknum = ls_xout-tknum AND vlpla = ls_xout-vlpla."lznum = ls_xout-lznum.
        IF lv_flag IS NOT INITIAL.
          ls_stylerow-fieldname = 'CHECK'.
          ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
          APPEND ls_stylerow TO ls_out-style.
          MODIFY gt_out FROM ls_out TRANSPORTING style.
        ENDIF.
        lv_flag = 'X'.
        CLEAR : ls_out-style[], ls_stylerow.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_LAYOUT_SHIPMENT
*&---------------------------------------------------------------------*
FORM f_modify_layout_shipment3 .
  DATA : lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout,
         ls_out  LIKE LINE OF gt_out.

  DATA : lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.

  DATA : lv_flag.

  IF pa_lgnum = 'C40' AND pa_drukz = '48'.
    SORT gt_out BY nlpla."tknum."kober tanum.

    lt_xout[] = gt_out[].
    SORT lt_xout BY nlpla."tknum."lznum .
    DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING nlpla."tknum."lznum.
    IF lt_xout[] IS NOT INITIAL.
      LOOP AT lt_xout INTO ls_xout.
        CLEAR lv_flag.
        LOOP AT gt_out INTO ls_out WHERE nlpla = ls_xout-nlpla."tknum = ls_xout-tknum."lznum = ls_xout-lznum.
          IF lv_flag IS NOT INITIAL.
            ls_stylerow-fieldname = 'CHECK'.
            ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
            APPEND ls_stylerow TO ls_out-style.
            MODIFY gt_out FROM ls_out TRANSPORTING style.
          ENDIF.
          lv_flag = 'X'.
          CLEAR : ls_out-style[], ls_stylerow.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ELSE.
    SORT gt_out BY tknum."kober tanum.

    lt_xout[] = gt_out[].
    SORT lt_xout BY tknum."lznum .
    DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING tknum."lznum.
    IF lt_xout[] IS NOT INITIAL.
      LOOP AT lt_xout INTO ls_xout.
        CLEAR lv_flag.
        LOOP AT gt_out INTO ls_out WHERE tknum = ls_xout-tknum."lznum = ls_xout-lznum.
          IF lv_flag IS NOT INITIAL.
            ls_stylerow-fieldname = 'CHECK'.
            ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
            APPEND ls_stylerow TO ls_out-style.
            MODIFY gt_out FROM ls_out TRANSPORTING style.
          ENDIF.
          lv_flag = 'X'.
          CLEAR : ls_out-style[], ls_stylerow.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_LAYOUT_SHIPMENT
*&---------------------------------------------------------------------*
FORM f_modify_layout_shipment4 .
  DATA : lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout,
         ls_out  LIKE LINE OF gt_out.

  DATA : lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.

  DATA : lv_flag.

  SORT gt_out BY tknum."kober tanum.

  lt_xout[] = gt_out[].
  SORT lt_xout BY lznum."lznum .
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING lznum."lznum.
  IF lt_xout[] IS NOT INITIAL.
    LOOP AT lt_xout INTO ls_xout.
      CLEAR lv_flag.
      LOOP AT gt_out INTO ls_out WHERE lznum = ls_xout-lznum."lznum = ls_xout-lznum.
        IF lv_flag IS NOT INITIAL.
          ls_stylerow-fieldname = 'CHECK'.
          ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
          APPEND ls_stylerow TO ls_out-style.
          MODIFY gt_out FROM ls_out TRANSPORTING style.
        ENDIF.
        lv_flag = 'X'.
        CLEAR : ls_out-style[], ls_stylerow.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check.
  DATA : ls_fieldcatalog    TYPE lvc_t_fcat WITH HEADER LINE.
  DATA : lv_style    TYPE lvc_s_styl-style,
         lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.

  DATA : ls_out             LIKE LINE OF gt_out.

  CALL METHOD ref_grid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = ls_fieldcatalog[].

  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'CHECK'.
  IF sy-subrc = 0.
    IF ls_fieldcatalog-edit IS NOT INITIAL.
      IF pa_lprio = 'X'.
        LOOP AT gt_lprio INTO DATA(ls_lprio).
          READ TABLE ls_lprio-style INTO ls_stylerow
                                    WITH KEY fieldname = 'CHECK'.
          IF sy-subrc = 0 AND
              ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
            CONTINUE.
          ENDIF.
          ls_lprio-check = fu_check.
          MODIFY gt_lprio FROM ls_lprio.
          CLEAR ls_lprio.
        ENDLOOP.
      ELSE.
        LOOP AT gt_out INTO ls_out.
          READ TABLE ls_out-style INTO ls_stylerow
                                  WITH KEY fieldname = 'CHECK'.
          IF sy-subrc = 0 AND
              ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
            CONTINUE.
          ENDIF.
          ls_out-check = fu_check.
          MODIFY gt_out FROM ls_out.
          CLEAR ls_out.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
  IF pa_drukz = '50'.
    LOOP AT gt_04 INTO gs_04.
      gs_04-check = fu_check.
      MODIFY gt_04 FROM gs_04.
      CLEAR gs_04.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_GET_MAX_TIME_PICKING
*&---------------------------------------------------------------------*
FORM f_get_max_time_picking  USING    fu_vbeln fu_lgtor fu_kdgrp fu_vkorg
                             CHANGING fc_kodat fc_kouhr.

  DATA : vblkk  TYPE vblkk,
         tvblkp TYPE STANDARD TABLE OF vblkp.

  DATA : lt_a511    LIKE a511 OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_tvst OCCURS 0,
           vstel TYPE vstel,
           city1 TYPE ad_city1.
  DATA : END  OF lt_tvst.
  DATA : wa_tvst    LIKE lt_tvst.
  DATA : lv_subrc TYPE sy-subrc,
         lv_ort01 TYPE name4_gp,
         lv_katr1 TYPE katr1,
         i1       TYPE i.

  CALL FUNCTION 'RV_DELIVERY_PICK_VIEW'
    EXPORTING
      vbeln     = fu_vbeln
      zweck     = 'D'
      spras     = sy-langu
    IMPORTING
      vblkk_wa  = vblkk
    TABLES
      vblkp_tab = tvblkp
    EXCEPTIONS
      OTHERS    = 1.

  IF sy-subrc = 0.
    SELECT kappl kschl vkorg katr1 vkbur kdgrp kunwe
      zday1 zday2 zday3 zday4 zday5 zday6
      FROM a511
      INTO CORRESPONDING FIELDS OF TABLE lt_a511
      WHERE kappl = 'V'
        AND kschl = 'ZDLV'
        AND vkorg = fu_vkorg
        AND datbi >= sy-datum
        AND datab <= sy-datum.

    SELECT SINGLE vstel city1
      FROM tvst
      INNER JOIN adrc ON tvst~adrnr = adrc~addrnumber
      INTO wa_tvst
      WHERE vstel = vblkk-vstel.

    IF ( fu_kdgrp = 'BR' AND vblkk-vstel NE 'A200' ) OR
       ( fu_kdgrp = 'BR' AND vblkk-vstel NE 'B102' ).
      lv_subrc = 4.
    ENDIF.

    IF lv_subrc IS INITIAL.
      lv_ort01 = vblkk-ort01.

      CONDENSE lv_ort01 NO-GAPS.
      TRANSLATE lv_ort01 TO UPPER CASE.
      TRANSLATE wa_tvst-city1 TO UPPER CASE.

      IF fu_lgtor IS NOT INITIAL.
        IF fu_lgtor(1) = 'D'.
          lv_katr1  = 'DK'.
        ELSE.
          lv_katr1  = 'LK'.
        ENDIF.
      ELSE.
        i1 = strlen( wa_tvst-city1 ).
        IF lv_ort01(i1) = wa_tvst-city1.
          lv_katr1 = 'DK'.
        ELSE.
          CASE vblkk-vstel.
            WHEN '0201' OR '0202' OR '0203'.
              IF lv_ort01(7) = 'JAKARTA'.
                lv_katr1 = 'DK'.
              ENDIF.
            WHEN '0240'.
              IF lv_ort01(6) = 'MORAWA'.
                lv_katr1 = 'DK'.
              ENDIF.
            WHEN '0223'.
              IF lv_ort01(5) = 'YOGYA' OR
               lv_ort01(8) = 'KOTAGEDE' OR
               lv_ort01(6) = 'SLEMAN' OR
               lv_ort01(6) = 'GODEAN'.
                lv_katr1 = 'DK'.
              ENDIF.
            WHEN OTHERS.
              lv_katr1 = 'LK'.
          ENDCASE.
        ENDIF.
      ENDIF.

      CASE fu_kdgrp.
        WHEN '08' OR '09'.
          IF lv_katr1 = 'DK'.
            PERFORM f_dk_apar CHANGING fc_kodat fc_kouhr.
          ELSEIF lv_katr1 = 'LK'.
            PERFORM f_fr_a511 TABLES   lt_a511
                              USING    lv_katr1 fu_kdgrp
                              CHANGING fc_kodat fc_kouhr.
          ENDIF.

        WHEN OTHERS.
          PERFORM f_fr_a511 TABLES   lt_a511
                            USING    lv_katr1 fu_kdgrp
                            CHANGING fc_kodat fc_kouhr.
      ENDCASE.

      PERFORM f_calendar_t1 CHANGING fc_kodat.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_MAX_TIME_PICKING

*&---------------------------------------------------------------------*
*&      Form  F_CALENDAR_T1
*&---------------------------------------------------------------------*
FORM f_calendar_t1  CHANGING fc_kodat.
  CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
    EXPORTING
      date                         = fc_kodat
      factory_calendar_id          = 'T1'
    IMPORTING
      date                         = fc_kodat
    EXCEPTIONS
      calendar_buffer_not_loadable = 1
      correct_option_invalid       = 2
      date_after_range             = 3
      date_before_range            = 4
      date_invalid                 = 5
      factory_calendar_not_found   = 6
      OTHERS                       = 7.
ENDFORM.                    " F_CALENDAR_T1

*&---------------------------------------------------------------------*
*&      Form  F_DK_APAR
*&---------------------------------------------------------------------*
FORM f_dk_apar  CHANGING fc_kodat fc_kouhr.
  DATA : lv_uzeit   TYPE uzeit VALUE '1400'.

  IF sy-uzeit <= lv_uzeit.
    fc_kouhr  = '2359'.
    fc_kodat  = sy-datum.
  ELSE.
    fc_kouhr = '1400'.
    fc_kodat  = sy-datum + 1.
  ENDIF.
ENDFORM.                    " F_DK_APAR

*&---------------------------------------------------------------------*
*&      Form  F_FR_A511
*&---------------------------------------------------------------------*
FORM f_fr_a511  TABLES   ft_a511 STRUCTURE a511
                USING    fu_katr1 fu_kdgrp
                CHANGING fc_kodat fc_kouhr.

  READ TABLE ft_a511 WITH KEY katr1 = fu_katr1
                              kdgrp = fu_kdgrp.
  IF sy-subrc = 0.
    fc_kodat = sy-datum + ft_a511-zday4.
  ENDIF.
  fc_kouhr  = sy-uzeit.
ENDFORM.                    " F_FR_A511

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_CARTON
*&---------------------------------------------------------------------*
FORM f_calculate_carton  USING    fu_lgnum fu_tanum
                         CHANGING fc_carton fc_receh.
  TYPES : BEGIN OF ty_sum,
            matnr TYPE ltap-matnr,
            charg TYPE ltap-charg,
            vsolm TYPE ltap-vsolm,
          END OF ty_sum.

  DATA : lt_ltap   TYPE STANDARD TABLE OF ltap,
         ls_ltap   LIKE LINE OF lt_ltap,
         lt_sum    TYPE STANDARD TABLE OF ty_sum,
         ls_sum    LIKE LINE OF lt_sum,
         lv_umrez  TYPE marm-umrez,
         lv_volum  TYPE mara-volum,
         lv_mod    TYPE p DECIMALS 0,
         lv_div    TYPE p DECIMALS 0,
         lv_receh  TYPE p DECIMALS 0,
         lv_carton TYPE p DECIMALS 0,
         lv_bagi   TYPE p DECIMALS 4.

  SELECT *
    FROM ltap
    INTO CORRESPONDING FIELDS OF TABLE lt_ltap
    WHERE lgnum = fu_lgnum
      AND tanum = fu_tanum.

  SORT lt_ltap BY matnr charg.
  LOOP AT lt_ltap INTO ls_ltap.
    ls_sum-matnr  = ls_ltap-matnr.
    ls_sum-charg  = ls_ltap-charg.
    ls_sum-vsolm  = ls_ltap-vsolm.
    COLLECT ls_sum INTO lt_sum.
    CLEAR ls_sum.
  ENDLOOP.

  CLEAR ls_sum.
  LOOP AT lt_sum INTO ls_sum.
    SELECT SINGLE volum
      FROM mara
      INTO lv_volum
      WHERE matnr = ls_sum-matnr.

    SELECT SINGLE umrez
      FROM marm
      INTO lv_umrez
      WHERE matnr = ls_sum-matnr
        AND meinh = 'KAR'.
    IF sy-subrc = 0.
      lv_mod    = ls_sum-vsolm MOD lv_umrez.
      lv_receh  = lv_receh + ( lv_mod * lv_volum ).
      lv_div    = ls_sum-vsolm DIV lv_umrez.
      ADD lv_div TO lv_carton.
    ENDIF.
    CLEAR : lv_mod, lv_div.
  ENDLOOP.

  lv_bagi = lv_receh / 25000.

  CALL FUNCTION 'ROUND'
    EXPORTING
      input         = lv_bagi
      sign          = '+'
    IMPORTING
      output        = lv_receh
    EXCEPTIONS
      input_invalid = 1
      overflow      = 2
      type_invalid  = 3
      OTHERS        = 4.

  fc_carton = lv_carton.
  CONDENSE fc_carton NO-GAPS.
  fc_receh  = lv_receh.
  CONDENSE fc_receh NO-GAPS.
ENDFORM.                    " F_CALCULATE_CARTON

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERSION
*&---------------------------------------------------------------------*
FORM f_unit_conversion  USING    fu_value
                                 fu_unit
                        CHANGING fc_value.

  DATA : lv_value(100),
         lv_unit    TYPE mara-meins.

  WRITE fu_value TO lv_value UNIT fu_unit.
  CONDENSE lv_value NO-GAPS.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fu_unit
    IMPORTING
      output         = lv_unit
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.

  CONCATENATE lv_value lv_unit INTO fc_value
  SEPARATED BY space.
ENDFORM.                    " F_UNIT_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_41
*&---------------------------------------------------------------------*
FORM f_41  TABLES   ft_out STRUCTURE gt_out
           USING    fu_fname.

  DATA : l_funcname TYPE tdsfname,
         ls_t329d   LIKE LINE OF gt_t329d,
         lv_ldest   TYPE t329d-ldest.

  DATA : lwa_control_option TYPE ssfctrlop,
         lwa_output_option  TYPE ssfcompop,
         ls_header          TYPE zmfindpick,
         lt_detail          TYPE STANDARD TABLE OF zmfindpick,
         ls_detail          LIKE LINE OF lt_detail,
         ls_out             LIKE gt_out.

  CHECK fu_fname IS NOT INITIAL.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = fu_fname
    IMPORTING
      fm_name            = l_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF pa_form IS NOT INITIAL.
*    lwa_control_option-no_dialog = 'X'.

    lwa_output_option-tdnewid    = 'X'.
    lwa_output_option-tdimmed    = 'X'.
    lwa_output_option-tddelete   = ''.
    lwa_output_option-tddest     = default-spld.
  ENDIF.

  CLEAR ls_out.
  LOOP AT ft_out INTO ls_out.
    MOVE-CORRESPONDING ls_out TO ls_header.

    AT FIRST.
      lwa_control_option-no_close = 'X'.
    ENDAT.

    AT LAST.
      lwa_control_option-no_close = space.
    ENDAT.

    PERFORM f_get_detail_41 TABLES lt_detail
                            USING ls_out
                            CHANGING ls_header.

    CLEAR : ls_t329d.
    READ TABLE gt_t329d INTO ls_t329d
                        WITH KEY nltyp = ls_out-nltyp.
    IF sy-subrc = 0.
      lwa_output_option-tddest    = ls_t329d-ldest.
    ELSE.
      lwa_output_option-tddest    = default-spld.
    ENDIF.

    PERFORM f_add_header CHANGING ls_header.

    IF pa_lgnum = 'C40'.
      ls_header-vltyp = ls_out-vltyp.
      IF ls_header-vltyp(1) = 'L'.
        CONCATENATE 'L/' ls_header-reprint INTO ls_header-reprint.
      ELSE.
        ls_header-reprint = 'REPRINT'.
      ENDIF.
    ENDIF.

    CALL FUNCTION l_funcname
      EXPORTING
        control_parameters = lwa_control_option
        output_options     = lwa_output_option
        user_settings      = space
        gs_head            = ls_header
      TABLES
        gt_detl            = lt_detail
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    lwa_control_option-no_open = 'X'.
  ENDLOOP.
ENDFORM.                    " F_41

*&---------------------------------------------------------------------*
*&      Form  F_GET_DETAIL_41
*&---------------------------------------------------------------------*
FORM f_get_detail_41  TABLES   ft_detail STRUCTURE zmfindpick
                      USING    fs_out TYPE ty_out
                      CHANGING fs_header  TYPE zmfindpick.

  DATA : lv_adrnr  TYPE kna1-adrnr,
         lv_tragr  TYPE likp-tragr,
         lv_lfart  TYPE likp-lfart,
         ls_ltap   LIKE LINE OF gt_ltap,
         ls_detail TYPE zmfindpick,
         lt_xltap  LIKE gt_ltap OCCURS 0,
         ls_xltap  LIKE LINE OF gt_ltap,
         lv_vgbel  TYPE lips-vgbel,
         lv_vbelv  TYPE vbfa-vbelv,
         lv_bednr  TYPE ekpo-bednr,
         lv_kunnr  TYPE vbak-kunnr,
         lv_tvsola TYPE ltap-vsola,
         lv_umrez  TYPE marm-umrez,
         lv_mod    TYPE p DECIMALS 0,
         lv_div    TYPE p DECIMALS 0.

  CLEAR : fs_header, ft_detail[].

  SELECT SINGLE lnumt
    FROM t300t
    INTO fs_header-company
    WHERE spras EQ sy-langu
      AND lgnum EQ fs_out-lgnum.

  TRANSLATE fs_header-company TO UPPER CASE.
  fs_header-drukz   = pa_drukz.
  fs_header-vbeln   = fs_out-vbeln.
  fs_header-tanum   = fs_out-tanum.
  fs_header-bdatu   = fs_out-bdatu.
  fs_header-bzeit   = fs_out-bzeit.
  fs_header-refnr   = fs_out-refnr.
  fs_header-lgnum   = fs_out-lgnum.
  fs_header-bwlvs   = fs_out-bwlvs.
  fs_header-tbnum   = fs_out-tbnum.

  IF fs_out-refnr IS NOT INITIAL.
    SELECT SINGLE vbeln
      FROM vbss
      INTO fs_out-vbeln
      WHERE sammg = fs_out-refnr.
  ENDIF.

  SELECT SINGLE likp~kunnr kna1~name1 tragr route lfart
    FROM likp JOIN kna1 ON likp~kunnr = kna1~kunnr
              JOIN adrc ON kna1~adrnr = adrc~addrnumber
    INTO (fs_header-kunnr, fs_header-name1, lv_tragr, fs_header-route, lv_lfart)
    WHERE vbeln = fs_out-vbeln.

  IF sy-subrc = 0.
    IF lv_lfart = 'NLCC'.
      SELECT SINGLE vgbel
        FROM lips
        INTO lv_vgbel
        WHERE vbeln = fs_out-vbeln.
      IF sy-subrc = 0.
        SELECT SINGLE bednr
          FROM ekpo
          INTO lv_bednr
          WHERE ebeln = lv_vgbel.
        IF sy-subrc = 0.
          SELECT SINGLE route
            FROM vbap
            INTO fs_header-route
            WHERE vbeln = lv_bednr.

          SELECT SINGLE kunnr bnddt
            FROM vbak
            INTO (fs_header-kunnr, fs_header-bnddt)
            WHERE vbeln = lv_bednr.
          IF sy-subrc = 0.
            SELECT SINGLE name1
              FROM kna1
              INTO fs_header-name1
              WHERE kunnr = fs_header-kunnr.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      SELECT SINGLE vbelv
        FROM vbfa
        INTO lv_vbelv
        WHERE vbeln = fs_header-vbeln.

      SELECT SINGLE bnddt
        FROM vbak
        INTO fs_header-bnddt
        WHERE vbeln = lv_vbelv.
    ENDIF.

    SELECT SINGLE vtext
      FROM ttgrt
      INTO fs_header-vtext
      WHERE spras EQ sy-langu AND
            tragr EQ lv_tragr.

    SELECT SINGLE bezei
      FROM tvrot
      INTO fs_header-bezei
      WHERE spras EQ sy-langu AND
            route EQ fs_header-route.
  ENDIF.

  IF pa_druck IS NOT INITIAL.
    fs_header-reprint = 'REPRINT'.
  ENDIF.

  READ TABLE gt_ltap INDEX 1.
  IF sy-subrc = 0.
    fs_header-werks = gt_ltap-werks.
    fs_header-lgort = gt_ltap-lgort.
  ENDIF.

  SORT gt_ltap BY tanum matnr charg vlpla.
  lt_xltap[] = gt_ltap[].
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING tanum matnr charg vlpla.
  LOOP AT lt_xltap INTO ls_xltap WHERE tanum = fs_header-tanum.
    ls_detail-matnr = ls_xltap-matnr.
    ls_detail-charg = ls_xltap-charg.
    ls_detail-vfdat = ls_xltap-vfdat.
    ls_detail-maktx = ls_xltap-maktx.
    ls_detail-tapos = ls_xltap-tapos.
    ls_detail-vltyp = ls_xltap-vltyp.
    ls_detail-vlber = ls_xltap-vlber.
    ls_detail-vlpla = ls_xltap-vlpla.
    ls_detail-altme = ls_xltap-altme.
    ls_detail-nltyp = ls_xltap-nltyp.
    ls_detail-nlber = ls_xltap-nlber.
    ls_detail-nlpla = ls_xltap-nlpla.
    CLEAR : ls_ltap, lv_tvsola.
    LOOP AT gt_ltap INTO ls_ltap WHERE tanum = fs_header-tanum
                                   AND matnr = ls_xltap-matnr
                                   AND charg = ls_xltap-charg
                                   AND vlpla = ls_xltap-vlpla.
      ADD ls_ltap-vsola TO lv_tvsola.
    ENDLOOP.

    WRITE lv_tvsola TO ls_detail-tvsola UNIT ls_xltap-altme.

    SELECT SINGLE umrez
      FROM marm
      INTO lv_umrez
      WHERE matnr = ls_xltap-matnr
        AND meinh = 'KAR'.

    IF sy-subrc = 0.
      CLEAR : lv_mod, lv_div.
      WRITE lv_umrez TO ls_detail-satuan DECIMALS 0.
      lv_mod    = lv_tvsola MOD lv_umrez.
      lv_div    = lv_tvsola DIV lv_umrez.
      ls_detail-carton  = lv_div.
      CONDENSE ls_detail-carton NO-GAPS.
      ls_detail-receh   = lv_mod.
    ENDIF.

    APPEND ls_detail TO ft_detail.
    CLEAR ls_detail.
  ENDLOOP.

  SORT ft_detail BY vlpla.
ENDFORM.                    " F_GET_DETAIL_41

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_41_FR_LT31
*&---------------------------------------------------------------------*
FORM f_print_41_fr_lt31 TABLES ft_out STRUCTURE gt_out.
  DATA : ls_out    LIKE LINE OF gt_out.

  ssfpp-tddest = default-spld.

  CALL SCREEN 100 STARTING AT 1 1.

  IF gv_subrc IS INITIAL.
    LOOP AT ft_out INTO ls_out.
      SUBMIT rlvsdr40 WITH t4_lgnum EQ pa_lgnum
                      WITH t4_tanum EQ ls_out-tanum SIGN 'I'
                      WITH druckkz  EQ '41'
                      WITH edrucker EQ ssfpp-tddest
                      WITH spoolpar EQ '01'
                      WITH drucken  EQ 'X'
                      WITH explizit EQ ' '
                      WITH tasch    EQ 'X'
                      WITH lesch    EQ ' '
                      WITH letasch  EQ ' '
                      WITH leinh    EQ ' '
                      WITH humla    EQ ' '
                      WITH etikett  EQ ' '
                      AND RETURN.

      CALL FUNCTION 'ZFMWAIT'.

      UPDATE ltak SET druck = 'X'
                WHERE lgnum EQ pa_lgnum
                  AND tanum EQ ls_out-tanum.
    ENDLOOP.
  ENDIF.
  CLEAR gv_subrc.
ENDFORM.                    " F_PRINT_41_FR_LT31

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status OUTPUT.
  DATA fcode    TYPE TABLE OF sy-ucomm.

  IF pa_drukz <> '47' AND
    pa_drukz <> '49'.
    APPEND '&PREV' TO fcode.
  ENDIF.

  IF sy-dynnr = '0101'.
    APPEND '&PREV' TO fcode.
    APPEND '&PRNT' TO fcode.

    CLEAR gv_lgbzo.
  ELSE.
    APPEND 'CONT' TO fcode.
  ENDIF.

  SET PF-STATUS 'PFSTATUS' EXCLUDING fcode.

  SELECT SINGLE pamsg
    FROM tsp03
    INTO tsp03-pamsg
    WHERE padest = ssfpp-tddest.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : is_layout TYPE lvc_s_layo,
         ls_out    LIKE LINE OF gt_out.

  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN '&PRNT' OR '&PREV'.
      CLEAR gv_subrc.
      LEAVE TO SCREEN 0.
    WHEN 'CONT'.
      IF gv_lgbzo IS NOT INITIAL.
        SELECT SINGLE lbzot
          FROM t30ct
          INTO gv_lbzot
          WHERE spras = sy-langu
            AND lgnum = pa_lgnum
            AND lgbzo = gv_lgbzo.
        IF sy-subrc <> 0.
          CLEAR gv_lgbzo.
          DATA(lv_text) = |{ 'Staging Area' } { gv_lgbzo } { 'tidak terdaftar di WH' } { pa_lgnum }|.
          PERFORM f_error_message USING '' '' lv_text.
        ELSE.
          LOOP AT gt_out INTO ls_out.
            ls_out-lgbzo  = gv_lgbzo.
            MODIFY gt_out FROM ls_out TRANSPORTING lgbzo.
            CLEAR ls_out.
          ENDLOOP.

          CALL METHOD ref_grid->set_frontend_layout
            EXPORTING
              is_layout = is_layout.
          CALL METHOD ref_grid->refresh_table_display.
        ENDIF.
      ENDIF.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  gv_subrc = 4.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_48
*&---------------------------------------------------------------------*
FORM f_48  TABLES   ft_out STRUCTURE gt_out
           USING    fu_fname fu_ucomm
           CHANGING fc_lznum.

  DATA : l_funcname TYPE tdsfname,
         ls_t329d   LIKE LINE OF gt_t329d,
         lv_ldest   TYPE t329d-ldest.

  DATA : lwa_control_option TYPE ssfctrlop,
         lwa_output_option  TYPE ssfcompop,
         ls_header          TYPE zmfindpick,
         lt_detail          TYPE STANDARD TABLE OF zmfindpick,
         ls_detail          LIKE LINE OF lt_detail,
         ls_out             LIKE gt_out,
         lt_out             TYPE STANDARD TABLE OF ty_out,
         lv_lines           TYPE i,
         lv_number          TYPE numc15,
         lv_umrez           TYPE marm-umrez,
         lv_mod             TYPE p DECIMALS 0,
         lv_div             TYPE p DECIMALS 0.

  CHECK fu_fname IS NOT INITIAL.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = fu_fname
    IMPORTING
      fm_name            = l_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF pa_form IS NOT INITIAL.
*    lwa_control_option-no_dialog = 'X'.

    lwa_output_option-tdnewid    = 'X'.
    lwa_output_option-tdimmed    = 'X'.
    lwa_output_option-tddelete   = ''.
    lwa_output_option-tddest     = default-spld.
  ENDIF.

  lt_out[] = ft_out[].
  SORT lt_out BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_out COMPARING kunnr.
  DELETE lt_out WHERE kunnr = space.
  DESCRIBE TABLE lt_out LINES lv_lines.

  SELECT SINGLE lnumt
    FROM t300t
    INTO ls_header-company
    WHERE spras EQ sy-langu
      AND lgnum EQ pa_lgnum.

  TRANSLATE ls_header-company TO UPPER CASE.
  ls_header-drukz = pa_drukz.

  IF pa_druck IS NOT INITIAL.
    ls_header-reprint = 'REPRINT'.
  ENDIF.

  READ TABLE ft_out INTO ls_out INDEX 1.
  IF sy-subrc = 0.
    IF lv_lines = 1.
      ls_header-kunnr = ls_out-kunnr.
      ls_header-name1 = ls_out-name1.
      ls_header-route = ls_out-route.
      SELECT SINGLE bezei
        FROM tvrot
        INTO ls_header-bezei
        WHERE spras EQ sy-langu AND
              route EQ ls_out-route.
    ENDIF.
  ENDIF.

  IF fu_ucomm = '&POS' OR
    fu_ucomm = '&GRP'.
    IF ls_out-lznum IS INITIAL.
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr             = '01'
          object                  = 'ZCOLPRNTTO'
        IMPORTING
          number                  = lv_number
        EXCEPTIONS
          interval_not_found      = 1
          number_range_not_intern = 2
          object_not_found        = 3
          quantity_is_0           = 4
          quantity_is_not_1       = 5
          interval_overflow       = 6
          buffer_overflow         = 7
          OTHERS                  = 8.
      ls_header-lznum = lv_number.
    ELSE.
      ls_header-lznum = ls_out-lznum.
    ENDIF.
  ELSEIF fu_ucomm = '&PREV'.
    ls_header-lznum = ls_out-lznum.
  ENDIF.

  CONDENSE ls_header-lznum NO-GAPS.
  fc_lznum = ls_header-lznum.

*  IF pa_lgnum = 'C40'.
*    ls_header-vltyp = ls_out-vltyp.
*    IF ls_header-vltyp(1) = 'L'.
*      CONCATENATE 'L/' ls_header-reprint INTO ls_header-reprint.
*    ELSE.
*      ls_header-reprint = 'REPRINT'.
*    ENDIF.
*  ENDIF.


  LOOP AT ft_out INTO ls_out.
    PERFORM f_get_detail_48 TABLES lt_detail
                            USING ls_out.
  ENDLOOP.

  LOOP AT lt_detail INTO ls_detail.
    SELECT SINGLE umrez
      FROM marm
      INTO lv_umrez
      WHERE matnr = ls_detail-matnr
        AND meinh = 'KAR'.

    IF sy-subrc = 0.
      CLEAR : lv_mod, lv_div.
      WRITE ls_detail-vsola TO ls_detail-tvsola UNIT ls_detail-altme.
      WRITE lv_umrez TO ls_detail-satuan DECIMALS 0.
      lv_mod    = ls_detail-vsola MOD lv_umrez.
      lv_div    = ls_detail-vsola DIV lv_umrez.
      ls_detail-carton  = lv_div.
      CONDENSE ls_detail-carton NO-GAPS.
      ls_detail-receh   = lv_mod.
      MODIFY lt_detail FROM ls_detail TRANSPORTING tvsola satuan carton receh.
    ENDIF.
  ENDLOOP.

*    AT FIRST.
*      lwa_control_option-no_close = 'X'.
*    ENDAT.
*
*    AT LAST.
*      lwa_control_option-no_close = space.
*    ENDAT.

  CLEAR : ls_t329d.
  READ TABLE gt_t329d INTO ls_t329d
                      WITH KEY nltyp = ls_out-nltyp.
  IF sy-subrc = 0.
    lwa_output_option-tddest    = ls_t329d-ldest.
  ELSE.
    lwa_output_option-tddest    = default-spld.
  ENDIF.

  IF fu_ucomm = '&PREV'.
    lwa_output_option-tdnoprint = 'X'.
  ELSE.
    IF pa_form IS INITIAL.
      IF fu_ucomm = '&POS'.
        lwa_output_option-tdnoprev = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF fu_ucomm <> '&GRP'.
    CALL FUNCTION l_funcname
      EXPORTING
        control_parameters = lwa_control_option
        output_options     = lwa_output_option
        user_settings      = space
        gs_head            = ls_header
      TABLES
        gt_detl            = lt_detail
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
  ENDIF.

*    lwa_control_option-no_open = 'X'.
ENDFORM.                    " F_48

*&---------------------------------------------------------------------*
*&      Form  F_GET_DETAIL_48
*&---------------------------------------------------------------------*
FORM f_get_detail_48  TABLES   ft_detail STRUCTURE zmfindpick
                      USING    fs_out TYPE ty_out.

  DATA : lv_adrnr  TYPE kna1-adrnr,
         lv_tragr  TYPE likp-tragr,
         lv_lfart  TYPE likp-lfart,
         ls_ltap   LIKE LINE OF gt_ltap,
         ls_detail TYPE zmfindpick,
         lt_xltap  LIKE gt_ltap OCCURS 0,
         ls_xltap  LIKE LINE OF gt_ltap,
         lv_vgbel  TYPE lips-vgbel,
         lv_vbelv  TYPE vbfa-vbelv,
         lv_bednr  TYPE ekpo-bednr,
         lv_kunnr  TYPE vbak-kunnr,
         lv_tvsola TYPE ltap-vsola,
         lv_umrez  TYPE marm-umrez,
         lv_mod    TYPE p DECIMALS 0,
         lv_div    TYPE p DECIMALS 0.

  SORT gt_ltap BY tanum matnr charg vlpla.
  lt_xltap[] = gt_ltap[].
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING tanum matnr charg vlpla.
  LOOP AT lt_xltap INTO ls_xltap WHERE tanum = fs_out-tanum.
    ls_detail-matnr = ls_xltap-matnr.
    ls_detail-charg = ls_xltap-charg.
    ls_detail-vfdat = ls_xltap-vfdat.
    ls_detail-maktx = ls_xltap-maktx.
*    ls_detail-tapos = ls_xltap-tapos.
    ls_detail-vltyp = ls_xltap-vltyp.
    ls_detail-vlber = ls_xltap-vlber.
    ls_detail-vlpla = ls_xltap-vlpla.
    ls_detail-altme = ls_xltap-altme.
    ls_detail-nltyp = ls_xltap-nltyp.
    ls_detail-nlber = ls_xltap-nlber.
    ls_detail-nlpla = ls_xltap-nlpla.
    CLEAR : ls_ltap, lv_tvsola.
    LOOP AT gt_ltap INTO ls_ltap WHERE tanum = fs_out-tanum
                                   AND matnr = ls_xltap-matnr
                                   AND charg = ls_xltap-charg
                                   AND vlpla = ls_xltap-vlpla.
      ADD ls_ltap-vsola TO lv_tvsola.
    ENDLOOP.

    ls_detail-vsola = lv_tvsola.
*    WRITE lv_tvsola TO ls_detail-tvsola UNIT ls_xltap-altme.
    COLLECT ls_detail INTO ft_detail.
    CLEAR ls_detail.
  ENDLOOP.

  SORT ft_detail BY vlpla.
ENDFORM.                    " F_GET_DETAIL_48

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_48
*&---------------------------------------------------------------------*
FORM f_modify_48 .
  DATA : lt_out  TYPE STANDARD TABLE OF ty_out,
         lt_likp TYPE STANDARD TABLE OF ty_likp,
         lt_lips TYPE STANDARD TABLE OF lips,
         lt_ekpo TYPE STANDARD TABLE OF ekpo,
         lt_kna1 TYPE STANDARD TABLE OF kna1,
         ls_kna1 LIKE LINE OF lt_kna1,
         ls_likp LIKE LINE OF lt_likp,
         ls_lips LIKE LINE OF lt_lips,
         ls_ekpo LIKE LINE OF lt_ekpo,
         lt_vbap TYPE STANDARD TABLE OF vbap,
         ls_vbap LIKE LINE OF lt_vbap,
         lt_vbak TYPE STANDARD TABLE OF vbak,
         ls_vbak LIKE LINE OF lt_vbak,
         ls_out  LIKE LINE OF gt_out.

  DATA : lv_tabix   TYPE sy-tabix.

  lt_out[] = gt_out[].
  SORT lt_out BY vbeln.
  IF lt_out[] IS NOT INITIAL.
    SELECT vbeln likp~kunnr adrc~name1 likp~tragr likp~route likp~lfart likp~lifex
      FROM likp JOIN kna1 ON likp~kunnr = kna1~kunnr
                JOIN adrc ON kna1~adrnr = adrc~addrnumber
      INTO CORRESPONDING FIELDS OF TABLE gt_likp
      FOR ALL ENTRIES IN lt_out
      WHERE vbeln = lt_out-vbeln.
  ENDIF.

  lt_likp[] = gt_likp[].
  DELETE lt_likp WHERE lfart <> 'NLCC'.
  IF lt_likp[] IS NOT INITIAL.
    SELECT *
      FROM lips
      INTO CORRESPONDING FIELDS OF TABLE lt_lips
      FOR ALL ENTRIES IN lt_likp
      WHERE vbeln = lt_likp-vbeln.
  ENDIF.

  IF lt_lips[] IS NOT INITIAL.
    SELECT *
      FROM ekpo
      INTO CORRESPONDING FIELDS OF TABLE lt_ekpo
      FOR ALL ENTRIES IN lt_lips
      WHERE ebeln = lt_lips-vgbel.
  ENDIF.

  IF lt_ekpo[] IS NOT INITIAL.
    SELECT *
      FROM vbap
      INTO CORRESPONDING FIELDS OF TABLE lt_vbap
      FOR ALL ENTRIES IN lt_ekpo
      WHERE vbeln = lt_ekpo-bednr.

    SELECT *
      FROM vbak
      INTO CORRESPONDING FIELDS OF TABLE lt_vbak
      FOR ALL ENTRIES IN lt_ekpo
      WHERE vbeln = lt_ekpo-bednr.

    IF sy-subrc = 0.
      SELECT *
        FROM kna1
        INTO CORRESPONDING FIELDS OF TABLE lt_kna1
        FOR ALL ENTRIES IN lt_kna1
        WHERE kunnr = lt_kna1-kunnr.
    ENDIF.
  ENDIF.

  LOOP AT gt_likp INTO ls_likp.
    IF ls_likp-lfart = 'NLCC'.
      READ TABLE lt_lips INTO ls_lips
                         WITH KEY vbeln = ls_likp-vbeln.
      IF sy-subrc = 0.
        READ TABLE lt_ekpo INTO ls_ekpo
                           WITH KEY ebeln = ls_lips-vgbel.
        IF sy-subrc = 0.
          READ TABLE lt_vbap INTO ls_vbap
                             WITH KEY vbeln = ls_ekpo-bednr.
          IF sy-subrc = 0.
            ls_likp-route = ls_vbap-route.
          ENDIF.
          READ TABLE lt_vbak INTO ls_vbak
                             WITH KEY vbeln = ls_ekpo-bednr.
          IF sy-subrc = 0.
            ls_likp-kunnr = ls_vbak-kunnr.

            READ TABLE lt_kna1 INTO ls_kna1
                               WITH KEY kunnr = ls_vbak-kunnr.
            IF sy-subrc = 0.
              ls_likp-name1 = ls_kna1-name1.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      MODIFY gt_likp FROM ls_likp TRANSPORTING kunnr name1 route.
    ENDIF.
  ENDLOOP.

  LOOP AT gt_out INTO ls_out.
    lv_tabix = sy-tabix.
    READ TABLE gt_likp INTO ls_likp
                       WITH KEY vbeln = ls_out-vbeln.
    IF sy-subrc = 0.
      ls_out-kunnr  = ls_likp-kunnr.
      ls_out-name1  = ls_likp-name1.
      ls_out-route  = ls_likp-route.
      IF ls_out-tknum IS INITIAL.
        ls_out-tknum = ls_likp-lifex.
      ENDIF.
      IF ls_out-tknum IN so_tknum.
        MODIFY gt_out FROM ls_out TRANSPORTING kunnr name1 route tknum.
      ELSE.
        DELETE gt_out INDEX lv_tabix.
      ENDIF.
    ENDIF.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_48

*&---------------------------------------------------------------------*
*&      Form  F_45X
*&---------------------------------------------------------------------*
FORM f_45x  TABLES   ft_out STRUCTURE gt_out
            USING    fu_fname fu_nodialog.

  DATA : l_funcname          TYPE tdsfname.

  DATA : lwa_control_option TYPE ssfctrlop,
         lwa_output_option  TYPE ssfcompop,
         ls_header          TYPE zkmmwm_st001,
         ls_out             LIKE gt_out,
         ls_t329d           LIKE LINE OF gt_t329d,
         lv_ldest           TYPE t329d-ldest,
         lv_pallet(50).

  DATA : lt_out  TYPE STANDARD TABLE OF ty_out,
         lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout,
         lv_flag.

  CHECK fu_fname IS NOT INITIAL.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = fu_fname
    IMPORTING
      fm_name            = l_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  CLEAR ls_out.
  LOOP AT ft_out INTO ls_out.
    DO gs_t329p-tdcopies TIMES.
      APPEND ls_out TO lt_out.
    ENDDO.
    CLEAR ls_out.
  ENDLOOP.

  lt_xout[] = ft_out[].
  SORT lt_xout BY lgnum mblnr.
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING mblnr.
  LOOP AT lt_xout INTO ls_xout.
    CLEAR lv_flag.
    LOOP AT lt_out INTO ls_out WHERE mblnr = ls_xout-mblnr.
      IF lv_flag IS INITIAL.
        lv_flag     = 'X'.
        ls_out-new  = lv_flag.
        MODIFY lt_out FROM ls_out TRANSPORTING new.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  LOOP AT lt_out INTO ls_out.
    AT FIRST.
      lwa_control_option-no_close = 'X'.
    ENDAT.

    AT LAST.
      lwa_control_option-no_close = space.
    ENDAT.

    MOVE-CORRESPONDING ls_out TO ls_header.

    IF ls_header-lgnum = '190'.
      PERFORM f_additional_data_tus TABLES lt_out
                                    USING ls_out
                                    CHANGING ls_header.
    ELSE.
      PERFORM f_additional_data_kmm USING ls_out
                                    CHANGING ls_header.
    ENDIF.

    CLEAR : ls_t329d, lv_ldest.
    READ TABLE gt_t329d INTO ls_t329d
                        WITH KEY nltyp = ls_header-nltyp.
    IF sy-subrc = 0.
      lv_ldest    = ls_t329d-ldest.
    ELSE.
      lv_ldest    = default-spld.
    ENDIF.

    IF pa_form IS NOT INITIAL.
      lwa_control_option-no_dialog = fu_nodialog.

      lwa_output_option-tdnewid    = 'X'.
      lwa_output_option-tdimmed    = 'X'.
      lwa_output_option-tddelete   = ''.
      lwa_output_option-tddest     = lv_ldest.
    ENDIF.

    IF ls_out-bestq = 'S'.
      IF ls_out-nltyp = 'FLR'.
        ls_header-reject = 'REJECT'.
        ls_header-reject1 = 'FLOOR'.
      ELSE.
        ls_header-reject = 'REJECT'.
      ENDIF.
    ENDIF.

    IF ls_header-reject IS INITIAL.
      CASE ls_out-nltyp.
        WHEN 'FLR'.
          ls_header-reject = 'FLOOR'.
        WHEN 'RJR'.
          ls_header-reject = 'REJECT'.
      ENDCASE.
    ENDIF.

    CALL FUNCTION l_funcname
      EXPORTING
        control_parameters = lwa_control_option
        output_options     = lwa_output_option
        user_settings      = space
        wa_itab            = ls_header
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    lwa_control_option-no_open = 'X'.

    IF ls_header-lgnum <> '190'.
      CONDENSE ls_header-pallet NO-GAPS.
      TRY .
          UPDATE ltap SET zeugn = ls_header-pallet
                          WHERE lgnum = ls_header-lgnum
                            AND tanum = ls_header-tanum.
        CATCH cx_sy_open_sql_db.
      ENDTRY.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_45X

*&---------------------------------------------------------------------*
*&      Form  F_ADDITIONAL_DATA_KMM
*&---------------------------------------------------------------------*
FORM f_additional_data_kmm  USING    fs_out      TYPE ty_out
                            CHANGING fs_header   TYPE zkmmwm_st001.

  DATA : ymcha     TYPE mcha,
         classname TYPE klah-class,
         cob       TYPE STANDARD TABLE OF clbatch,
         ls_cob    LIKE LINE OF cob,
         ls_xltap  LIKE LINE OF gt_xltap.

  DATA : lt_xltap      LIKE gt_xltap OCCURS 0,
         lv_pallet(50).

  IF fs_out-lgort = '1010' OR
   fs_out-lgort = '1011' OR
   fs_out-lgort = '2010' OR
   fs_out-lgort = '20U1' OR
   fs_out-lgort = '2110' OR
   fs_out-lgort = '2210' OR
   fs_out-lgort = '2310' OR
   fs_out-lgort = '3010' OR
   fs_out-lgort = '30U1' OR
   fs_out-lgort = '5010'.
    fs_header-kmm = 'KMM - Plant 2'.
  ELSE.
    fs_header-kmm = 'KMM - Plant 1'.
  ENDIF.

  IF fs_out-werks = '3603'.
    fs_header-kmm = 'KMM - Cikarang'.
  ELSEIF fs_out-werks = '1900'.
    fs_header-kmm = 'TUS - Mojokerto'.
  ENDIF.

  SELECT SINGLE name1
    FROM ekko JOIN lfa1 ON ekko~lifnr = lfa1~lifnr
    INTO fs_header-name1
    WHERE ebeln = fs_out-benum.

  fs_header-vgart     = 'WE'.
  fs_header-order     = fs_out-benum.
  fs_header-prueflos  = fs_out-qplos.
  fs_header-erfme     = fs_out-meins.
  fs_header-erfmg     = fs_out-menge.
  fs_header-quantity  = fs_out-vsolm.
  fs_header-charg1    = fs_out-charg.
  fs_header-altme     = fs_out-altme.

*  ADDED
  fs_header-nlpla = fs_out-nlpla.
*  IF fs_header-erfme <> fs_header-altme.
*    PERFORM f_qty_conversion USING fs_out-matnr fs_header-altme fs_header-erfme
*
*                             CHANGING fs_out-vsolm.
*    fs_header-erfme = fs_header-altme.
*  ENDIF.
  WRITE fs_out-vsola TO fs_header-qtyt UNIT fs_out-altme.
  CONDENSE fs_header-qtyt NO-GAPS.
  SHIFT fs_header-charg1 LEFT DELETING LEADING '0'.

  fs_header-lgnum     = fs_out-lgnum.
  fs_header-tanum     = fs_out-tanum.

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      matnr              = fs_out-matnr
      charg              = fs_out-charg
      werks              = fs_out-werks
      get_classification = 'X'
    IMPORTING
      ymcha              = ymcha
      classname          = classname
    TABLES
      char_of_batch      = cob
    EXCEPTIONS
      no_material        = 1
      no_batch           = 2
      no_plant           = 3
      material_not_found = 4
      plant_not_found    = 5
      no_authority       = 6
      batch_not_exist    = 7
      lock_on_batch      = 8
      OTHERS             = 9.

  LOOP AT cob INTO ls_cob.
    CASE ls_cob-atnam.
      WHEN 'ZMF'.
        fs_header-mfrpn  = ls_cob-atwtb.
    ENDCASE.
  ENDLOOP.

  lt_xltap[] = gt_xltap[].
  SORT lt_xltap BY wenum.
  DELETE lt_xltap WHERE wenum <> fs_out-mblnr.

  SORT lt_xltap BY lgnum wenum tanum.
  CLEAR ls_xltap.
  READ TABLE lt_xltap INTO ls_xltap
                      WITH KEY tanum = fs_out-tanum.
  IF sy-subrc = 0.
    fs_header-pallet = sy-tabix.
  ENDIF.

  lv_pallet = fs_header-pallet.
  CONDENSE lv_pallet NO-GAPS.
  CONCATENATE fs_out-matnr fs_out-charg fs_out-tanum
              fs_header-qtyt lv_pallet
  INTO fs_header-qrcode
  SEPARATED BY ';'.
ENDFORM.                    " F_ADDITIONAL_DATA_KMM

*&---------------------------------------------------------------------*
*&      Form  F_QTY_CONVERSION
*&---------------------------------------------------------------------*
FORM f_qty_conversion  USING    fu_matnr fu_meins fu_meinh
                       CHANGING fc_value.
  CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
    EXPORTING
      input                = fc_value
      matnr                = fu_matnr
      meinh                = fu_meinh
      meins                = fu_meins
    IMPORTING
      output               = fc_value
    EXCEPTIONS
      conversion_not_found = 1
      input_invalid        = 2
      material_not_found   = 3
      meinh_not_found      = 4
      meins_missing        = 5
      no_meinh             = 6
      output_invalid       = 7
      overflow             = 8
      OTHERS               = 9.

ENDFORM.                    " F_QTY_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_47_TDN
*&---------------------------------------------------------------------*
FORM f_47_tdn  TABLES   ft_out STRUCTURE gt_out
               USING    fu_fname fu_spld.

  DATA : l_funcname         TYPE tdsfname,
         lwa_control_option TYPE ssfctrlop,
         lwa_output_option  TYPE ssfcompop,
         ls_header          TYPE zwmprntto,
         ls_out             LIKE gt_out,
         lv_ldest           TYPE t329d-ldest.

  CHECK fu_fname IS NOT INITIAL.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = fu_fname
    IMPORTING
      fm_name            = l_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  LOOP AT ft_out INTO ls_out.
    MOVE-CORRESPONDING ls_out TO ls_header.
*    AT FIRST.
*      lwa_control_option-no_close = 'X'.
*    ENDAT.

*    AT LAST.
*      lwa_control_option-no_close = space.
*    ENDAT.
    IF fu_spld IS INITIAL.
      lv_ldest    = default-spld.
    ELSE.
      lv_ldest    = fu_spld.
    ENDIF.

    lwa_control_option-no_dialog = 'X'.
    lwa_output_option-tdnewid    = 'X'.
    lwa_output_option-tdimmed    = 'X'.
    lwa_output_option-tddelete   = ''.

    IF pa_form IS NOT INITIAL.
      lwa_output_option-tddest     = lv_ldest.
    ELSE.
      lwa_output_option-tddest     = ssfpp-tddest.
      IF ok_code  = '&PREV'.
        lwa_control_option-preview   = 'X'.
      ENDIF.
    ENDIF.

    CALL FUNCTION l_funcname
      EXPORTING
        control_parameters = lwa_control_option
        output_options     = lwa_output_option
        user_settings      = space
        gs_header          = ls_header
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

*    lwa_control_option-no_open = 'X'.
  ENDLOOP.
ENDFORM.                    " F_47_TDN

*&---------------------------------------------------------------------*
*&      Form  F_TDN_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_tdn_process_data .
  DATA : ls_ltak  LIKE LINE OF gt_ltak,
         ls_ltap  LIKE LINE OF gt_ltap,
         ls_out   LIKE LINE OF gt_out,
         ls_lips  LIKE LINE OF gt_lips,
         ls_vbak  LIKE LINE OF gt_vbak,
         ls_xlikp LIKE LINE OF gt_xlikp,
         ls_012   LIKE LINE OF gt_012,
         ls_tprit LIKE LINE OF gt_tprit,
         lt_xltap TYPE STANDARD TABLE OF ltap,
         ls_xltap LIKE LINE OF lt_xltap.

  DATA : lv_lines  TYPE i,
         lv_length TYPE i,
         lv_store  TYPE ztdnsddt012-store.

  DATA : lv_vsola TYPE ltap-vsola,
         lv_nista TYPE ltap-nista.
  DATA: lv_item TYPE i.
  LOOP AT gt_ltak INTO ls_ltak.
    MOVE-CORRESPONDING ls_ltak TO ls_out.
    ls_out-tanum  = ls_ltak-tanum.
    ls_out-vbeln  = ls_ltak-vbeln.
    ls_out-drukz  = ls_ltak-drukz.
    ls_out-druck  = ls_ltak-druck.
    IF ls_ltak-drukz = '47' AND
      ls_ltak-druck = 'X'.
      ls_out-reprint = 'R'.
    ENDIF.

    CLEAR ls_lips.
    READ TABLE gt_lips INTO ls_lips
                       WITH KEY vbeln = ls_ltak-vbeln.
    IF sy-subrc = 0.
**** tamabahan informasi "nama kurir" by SUK Req by IRG - 24 okt 2024
      ls_out-empst = ls_lips-empst.

**** end tambahan --> tambahan akan dimunculkan di cetak picklist
      CLEAR ls_vbak.
      READ TABLE gt_vbak INTO ls_vbak
                         WITH KEY vbeln = ls_lips-vgbel.
      IF sy-subrc = 0.
        ls_out-audat  = ls_vbak-audat.
        ls_out-bstnk  = ls_vbak-bstnk.
      ENDIF.
    ENDIF.
    CLEAR ls_xlikp.
    READ TABLE gt_xlikp INTO ls_xlikp
                       WITH KEY vbeln = ls_ltak-vbeln.
    IF sy-subrc = 0.
      ls_out-bldat  = ls_xlikp-bldat.
      ls_out-tddat  = ls_xlikp-tddat.
      ls_out-tduhr  = ls_xlikp-tduhr.
      IF ls_xlikp-lfart = 'ZTS7'.
        ls_out-kdacct = 'TSHD JAKARTA'.
      ELSEIF ls_xlikp-lifex IS NOT INITIAL.
        lv_length = strlen( ls_xlikp-lifex ).
        IF lv_length > 3.
          lv_length = lv_length - 3.
          lv_store  = ls_xlikp-lifex+lv_length(3).
        ELSE.
          lv_store  = ls_xlikp-lifex.
        ENDIF.
        CLEAR ls_012.
        READ TABLE gt_012 INTO ls_012
                          WITH KEY store = lv_store.
        IF sy-subrc = 0.
          ls_out-kdacct   = ls_012-kdacct.
          ls_out-namestr  = ls_012-namestr.
        ENDIF.
      ELSE.
        ls_out-kdacct = 'OUTHER'.
      ENDIF.

      IF ls_out-kdacct IS INITIAL.
        SELECT SINGLE name1
          FROM kna1
          INTO ls_out-kdacct
          WHERE kunnr = ls_xlikp-kunnr.
      ENDIF.

      CASE ls_xlikp-lprio.
        WHEN '07' OR '08' OR '09'.
          CLEAR ls_tprit.
          READ TABLE gt_tprit INTO ls_tprit
                              WITH KEY lprio = ls_xlikp-lprio.
          IF sy-subrc = 0.
            ls_out-bezei = ls_tprit-bezei.
          ENDIF.
      ENDCASE.
    ENDIF.

    CLEAR : lt_xltap[].

    LOOP AT gt_ltap INTO ls_ltap WHERE tanum = ls_ltak-tanum.
      ls_xltap-matnr  = ls_ltap-matnr.
      ls_xltap-charg  = ls_ltap-charg.
      ls_xltap-vsolm  = ls_ltap-vsolm.
      APPEND ls_xltap TO lt_xltap.

      ls_out-vltyp    = ls_ltap-vltyp.
      ls_out-vlpla    = ls_ltap-vlpla.
      ls_out-nltyp    = ls_ltap-nltyp.
      ls_out-nlpla    = ls_ltap-nlpla.
      ls_out-matnr    = ls_ltap-matnr.
      ls_out-maktx    = ls_ltap-maktx.
      ls_out-altme    = ls_ltap-altme.

      ADD ls_ltap-vsola TO lv_vsola.
      ADD ls_ltap-nista TO lv_nista.
    ENDLOOP.

    PERFORM f_tdn_calculate_carton TABLES lt_xltap
                                   CHANGING ls_out-carton ls_out-receh.
    SORT lt_xltap BY vbeln matnr.
    DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING vbeln matnr.
    DESCRIBE TABLE lt_xltap LINES lv_lines.
    ls_out-totalt = lv_lines.
    CONDENSE ls_out-totalt NO-GAPS.

    ls_out-vsola    = lv_vsola.
    ls_out-nista    = lv_nista.

    SELECT SINGLE name1
      FROM vbpa JOIN adrc ON vbpa~adrnr = adrc~addrnumber
      INTO ls_out-name1
      WHERE vbeln = ls_ltak-vbeln
        AND parvw = 'WE'.

    ls_out-meins  = 'KAR'.

    APPEND ls_out TO gt_out.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_TDN_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_TDN_CALCULATE_CARTON
*&---------------------------------------------------------------------*
FORM f_tdn_calculate_carton  TABLES   ft_ltap   STRUCTURE ltap
                             CHANGING fc_carton fc_receh.
  TYPES : BEGIN OF ty_sum,
            matnr TYPE ltap-matnr,
            charg TYPE ltap-charg,
            vsolm TYPE ltap-vsolm,
          END OF ty_sum.

  DATA : ls_ltap   TYPE ltap,
         lt_sum    TYPE STANDARD TABLE OF ty_sum,
         ls_sum    LIKE LINE OF lt_sum,
         lv_umrez  TYPE marm-umrez,
         lv_volum  TYPE mara-volum,
         lv_mod    TYPE p DECIMALS 0,
         lv_div    TYPE p DECIMALS 0,
         lv_receh  TYPE p DECIMALS 0,
         lv_carton TYPE p DECIMALS 0,
         lv_bagi   TYPE p DECIMALS 4.

  SORT ft_ltap BY matnr charg.
  LOOP AT ft_ltap INTO ls_ltap.
    ls_sum-matnr  = ls_ltap-matnr.
    ls_sum-charg  = ls_ltap-charg.
    ls_sum-vsolm  = ls_ltap-vsolm.
    COLLECT ls_sum INTO lt_sum.
    CLEAR ls_sum.
  ENDLOOP.

  CLEAR ls_sum.
  LOOP AT lt_sum INTO ls_sum.
    SELECT SINGLE volum
      FROM mara
      INTO lv_volum
      WHERE matnr = ls_sum-matnr.

    SELECT SINGLE umrez
      FROM marm
      INTO lv_umrez
      WHERE matnr = ls_sum-matnr
        AND meinh = 'KAR'.
    IF sy-subrc = 0.
      lv_mod    = ls_sum-vsolm MOD lv_umrez.
      lv_receh  = lv_receh + lv_mod.
      lv_div    = ls_sum-vsolm DIV lv_umrez.
      ADD lv_div TO lv_carton.
    ELSE.
      lv_receh  = lv_receh + ls_sum-vsolm.
    ENDIF.
    CLEAR : lv_mod, lv_div.
  ENDLOOP.

  fc_carton = lv_carton.
  CONDENSE fc_carton NO-GAPS.
  fc_receh  = lv_receh.
  CONDENSE fc_receh NO-GAPS.
ENDFORM.                    " F_TDN_CALCULATE_CARTON

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_GROUPING
*&---------------------------------------------------------------------*
FORM f_check_grouping  USING    fu_lgnum fu_tanum
                       CHANGING fc_subrc.
  DATA : lv_lznum   TYPE ltak-lznum.

  CLEAR fc_subrc.

  SELECT SINGLE lznum
    FROM ltak
    INTO lv_lznum
    WHERE lgnum EQ fu_lgnum
      AND tanum EQ fu_tanum.

  IF lv_lznum IS NOT INITIAL.
    fc_subrc = 4.
  ENDIF.
ENDFORM.                    " F_CHECK_GROUPING

*&---------------------------------------------------------------------*
*&      Form  F_XUNIT_CONVERSION
*&---------------------------------------------------------------------*
FORM f_xunit_conversion  USING    fu_meins fu_meinh
                        CHANGING fc_quant.

  CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
    EXPORTING
      input                = fc_quant
      unit_in              = fu_meins
      unit_out             = fu_meinh
    IMPORTING
      output               = fc_quant
    EXCEPTIONS
      conversion_not_found = 1
      division_by_zero     = 2
      input_invalid        = 3
      output_invalid       = 4
      overflow             = 5
      type_invalid         = 6
      units_missing        = 7
      unit_in_not_found    = 8
      unit_out_not_found   = 9
      OTHERS               = 10.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_LPRIO
*&---------------------------------------------------------------------*
FORM f_modify_lprio  TABLES   ft_out STRUCTURE gt_out.
  DATA : lt_likp TYPE STANDARD TABLE OF likp,
         ls_likp LIKE LINE OF lt_likp,
         lt_out  TYPE STANDARD TABLE OF ty_out,
         ls_out  LIKE LINE OF lt_out.

  lt_out[] = ft_out[].
  DELETE ADJACENT DUPLICATES FROM lt_out COMPARING vbeln.
  IF lt_out[] IS NOT INITIAL.
    SELECT *
      FROM likp
      INTO CORRESPONDING FIELDS OF TABLE lt_likp
      FOR ALL ENTRIES IN lt_out
      WHERE vbeln = lt_out-vbeln.
  ENDIF.

  LOOP AT ft_out INTO ls_out.
    CLEAR ls_likp.
    READ TABLE lt_likp INTO ls_likp
                        WITH KEY vbeln = ls_out-vbeln.
    IF sy-subrc = 0.
      CASE ls_likp-lprio.
        WHEN '20'.
          ls_out-lprio  = 'CBD'.
        WHEN '21'.
          ls_out-lprio  = 'COD'.
      ENDCASE.
    ENDIF.
    MODIFY ft_out FROM ls_out TRANSPORTING lprio.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ADD_HEADER
*&---------------------------------------------------------------------*
FORM f_add_header  CHANGING fs_header   TYPE zmfindpick.
  DATA : lv_tbktx TYPE ltbk-tbktx,
         lv_rsnum TYPE resb-rsnum,
         lv_wempf TYPE resb-wempf,
         lv_ktext TYPE aufk-ktext,
         lv_matnr TYPE afpo-matnr,
         lv_charg TYPE afpo-charg.

  IF fs_header-lgnum = '190' AND
    fs_header-bwlvs = '601'.
    fs_header-line1 = fs_header-vbeln.
    CONCATENATE fs_header-kunnr '-' fs_header-name1 INTO fs_header-line2
    SEPARATED BY space.
    CONCATENATE fs_header-route fs_header-vtext fs_header-bezei
    INTO fs_header-line3
    SEPARATED BY space.
  ELSEIF fs_header-lgnum = '190' AND
    fs_header-bwlvs <> '601'.
    SELECT SINGLE tbktx
      FROM ltbk
      INTO lv_tbktx
      WHERE lgnum = fs_header-lgnum
        AND tbnum = fs_header-tbnum.

    CONCATENATE lv_tbktx '/' fs_header-tbnum INTO fs_header-line1.

    lv_rsnum = lv_tbktx(10).
    SELECT SINGLE wempf
      FROM resb
      INTO lv_wempf
      WHERE rsnum = lv_rsnum
        AND werks = fs_header-werks
        AND lgort = fs_header-lgort.

    SELECT SINGLE ktext
      FROM aufk
      INTO lv_ktext
      WHERE aufnr = lv_wempf.

    CONCATENATE lv_wempf lv_ktext INTO fs_header-line2
    SEPARATED BY space.

    SELECT SINGLE matnr charg
      FROM afpo
      INTO (lv_matnr, lv_charg)
      WHERE aufnr = lv_wempf.

    CONCATENATE lv_matnr '/' lv_charg INTO fs_header-line3.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_TO
*&---------------------------------------------------------------------*
FORM f_get_to .
  DATA : lt_ltak  LIKE gt_ltak OCCURS 0,
         ls_ltap  LIKE LINE OF gt_ltap,
         ls_xltap LIKE LINE OF gt_xltap.

  lt_ltak[] = gt_ltak[].
  SORT lt_ltak BY lgnum tanum mblnr.
  DELETE ADJACENT DUPLICATES FROM lt_ltak COMPARING lgnum tanum mblnr.
  IF lt_ltak[] IS NOT INITIAL.
    SELECT lgnum tanum tapos wenum zeugn vorga nlpla
      FROM ltap
      INTO TABLE gt_xltap
      FOR ALL ENTRIES IN lt_ltak
      WHERE lgnum = lt_ltak-lgnum
        AND tanum = lt_ltak-tanum
        AND wenum = lt_ltak-mblnr
        AND vorga <> 'ST'
        AND nltyp IN so_lgtyp.
    IF gt_xltap[] IS INITIAL.
      LOOP AT gt_ltap INTO ls_ltap.
        IF ls_ltap-vorga <> 'ST'.
          ls_xltap-lgnum = ls_ltap-lgnum.
          ls_xltap-tanum = ls_ltap-tanum.
          ls_xltap-tapos = ls_ltap-tapos.
          ls_xltap-wenum = ls_ltap-wenum.
          ls_xltap-zeugn = ls_ltap-zeugn.
          ls_xltap-vorga = ls_ltap-vorga.
          ls_xltap-nltyp = ls_ltap-nltyp.
          APPEND ls_xltap TO gt_xltap.
        ENDIF.
        CLEAR ls_xltap.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_TO_NEW
*&---------------------------------------------------------------------*
FORM f_get_to_new .
  DATA : lt_ltak  LIKE gt_ltak OCCURS 0,
         ls_ltap  LIKE LINE OF gt_ltap,
         ls_xltap LIKE LINE OF gt_xltap.

  lt_ltak[] = gt_ltak[].
  SORT lt_ltak BY lgnum tanum mblnr.
  DELETE ADJACENT DUPLICATES FROM lt_ltak COMPARING lgnum tanum mblnr.
  IF lt_ltak[] IS NOT INITIAL.
    SELECT lgnum tanum tapos wenum zeugn vorga nltyp
      FROM ltap
      INTO TABLE gt_xltap
      FOR ALL ENTRIES IN lt_ltak
      WHERE lgnum = lt_ltak-lgnum
        AND tanum = lt_ltak-tanum
        AND wenum = lt_ltak-mblnr
        AND nltyp IN so_lgtyp.
    IF gt_xltap[] IS INITIAL.
      LOOP AT gt_ltap INTO ls_ltap.
        ls_xltap-lgnum = ls_ltap-lgnum.
        ls_xltap-tanum = ls_ltap-tanum.
        ls_xltap-tapos = ls_ltap-tapos.
        ls_xltap-wenum = ls_ltap-wenum.
        ls_xltap-zeugn = ls_ltap-zeugn.
        ls_xltap-vorga = ls_ltap-vorga.
        ls_xltap-nltyp = ls_ltap-nltyp.
        APPEND ls_xltap TO gt_xltap.
        CLEAR ls_xltap.
      ENDLOOP.
    ENDIF.
  ENDIF.
  SORT gt_xltap BY lgnum wenum tanum.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PALLET_COUNT
*&---------------------------------------------------------------------*
FORM f_pallet_count  USING fu_tanum fu_mblnr
                     CHANGING fc_pallet.
  DATA : lt_xltap LIKE gt_xltap OCCURS 0,
         ls_xltap LIKE LINE OF gt_xltap,
         lt_yltap LIKE gt_xltap OCCURS 0,
         ls_yltap LIKE LINE OF gt_xltap,
         lt_cltap LIKE gt_xltap OCCURS 0,
         ls_cltap LIKE LINE OF gt_xltap.

  DATA : lv_count TYPE i.

  lt_xltap[] = gt_xltap[].
  SORT lt_xltap BY wenum.
  DELETE lt_xltap WHERE wenum <> fu_mblnr.
  lt_cltap[] = lt_yltap[] = lt_xltap[].
  DELETE lt_cltap WHERE vorga <> 'ST'.
  DELETE lt_yltap WHERE vorga = 'ST'
                     OR zeugn = space.
  DESCRIBE TABLE lt_yltap LINES lv_count.
  LOOP AT lt_cltap INTO ls_cltap.
    CLEAR ls_yltap.
    READ TABLE lt_yltap INTO ls_yltap
                        WITH KEY zeugn = ls_cltap-zeugn.
    IF sy-subrc = 0.
      DELETE TABLE lt_cltap FROM ls_cltap.
    ENDIF.
  ENDLOOP.

  IF lv_count = 0.
    fc_pallet = 1.
  ELSE.
    SORT lt_xltap BY lgnum wenum tanum.
    SORT lt_yltap BY zeugn DESCENDING.
    SORT lt_cltap BY zeugn.
    CLEAR ls_xltap.
    READ TABLE lt_xltap INTO ls_xltap
                        WITH KEY tanum = fu_tanum.
    IF sy-subrc = 0.
      IF ls_xltap-zeugn IS NOT INITIAL.
        fc_pallet = ls_xltap-zeugn.
      ELSEIF ls_xltap-zeugn IS INITIAL.
        IF lt_cltap[] IS NOT INITIAL.
          CLEAR ls_cltap.
          READ TABLE lt_cltap INTO ls_cltap INDEX 1.
          IF sy-subrc = 0.
            fc_pallet = ls_yltap-zeugn.
          ENDIF.
        ELSE.
          CLEAR ls_yltap.
          READ TABLE lt_yltap INTO ls_yltap INDEX 1.
          IF sy-subrc = 0.
            fc_pallet = ls_yltap-zeugn + 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ADDITIONAL_DATA_TUS
*&---------------------------------------------------------------------*
FORM f_additional_data_tus  TABLES   ft_out STRUCTURE gt_out
                            USING    fs_out      TYPE ty_out
                            CHANGING fs_header   TYPE zkmmwm_st001.

  DATA : ymcha     TYPE mcha,
         classname TYPE klah-class,
         cob       TYPE STANDARD TABLE OF clbatch,
         ls_cob    LIKE LINE OF cob.

  DATA : lt_xltap LIKE gt_xltap OCCURS 0,
         ls_xltap LIKE LINE OF gt_xltap,
         lt_yltap LIKE gt_xltap OCCURS 0,
         ls_yltap LIKE LINE OF gt_xltap,
         lt_zltap LIKE gt_xltap OCCURS 0.

  DATA : lv_pallet(50).

  IF fs_out-lgort = '1010' OR
   fs_out-lgort = '1011' OR
   fs_out-lgort = '2010' OR
   fs_out-lgort = '20U1' OR
   fs_out-lgort = '2110' OR
   fs_out-lgort = '2210' OR
   fs_out-lgort = '2310' OR
   fs_out-lgort = '3010' OR
   fs_out-lgort = '30U1' OR
   fs_out-lgort = '5010'.
    fs_header-kmm = 'KMM - Plant 2'.
  ELSE.
    fs_header-kmm = 'KMM - Plant 1'.
  ENDIF.

  IF fs_out-werks = '3603'.
    fs_header-kmm = 'KMM - Cikarang'.
  ELSEIF fs_out-werks = '1900'.
    fs_header-kmm = 'TUS - Mojokerto'.
  ENDIF.

  SELECT SINGLE name1
    FROM ekko JOIN lfa1 ON ekko~lifnr = lfa1~lifnr
    INTO fs_header-name1
    WHERE ebeln = fs_out-benum.

  fs_header-vgart     = 'WE'.
  fs_header-order     = fs_out-benum.
  fs_header-prueflos  = fs_out-qplos.
  fs_header-erfme     = fs_out-meins.
  fs_header-erfmg     = fs_out-menge.
  fs_header-quantity  = fs_out-vsolm.
  fs_header-charg1    = fs_out-charg.
  fs_header-altme     = fs_out-altme.
*  IF fs_header-erfme <> fs_header-altme.
*    PERFORM f_qty_conversion USING fs_out-matnr fs_header-altme fs_header-erfme
*
*                             CHANGING fs_out-vsolm.
*    fs_header-erfme = fs_header-altme.
*  ENDIF.
  WRITE fs_out-vsola TO fs_header-qtyt UNIT fs_out-altme.
  CONDENSE fs_header-qtyt NO-GAPS.
  SHIFT fs_header-charg1 LEFT DELETING LEADING '0'.

  fs_header-lgnum     = fs_out-lgnum.
  fs_header-tanum     = fs_out-tanum.

*  ADDED
  fs_header-nlpla = fs_out-nlpla.

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      matnr              = fs_out-matnr
      charg              = fs_out-charg
      werks              = fs_out-werks
      get_classification = 'X'
    IMPORTING
      ymcha              = ymcha
      classname          = classname
    TABLES
      char_of_batch      = cob
    EXCEPTIONS
      no_material        = 1
      no_batch           = 2
      no_plant           = 3
      material_not_found = 4
      plant_not_found    = 5
      no_authority       = 6
      batch_not_exist    = 7
      lock_on_batch      = 8
      OTHERS             = 9.

  LOOP AT cob INTO ls_cob.
    CASE ls_cob-atnam.
      WHEN 'ZMF'.
        fs_header-mfrpn  = ls_cob-atwtb.
    ENDCASE.
  ENDLOOP.

  PERFORM f_new_pallet_count TABLES ft_out
                             USING fs_out-mblnr fs_out-tanum fs_out-new
                             CHANGING fs_header-pallet.

*  IF gv_single IS INITIAL.
*    lt_xltap[] = gt_xltap[].
*    SORT lt_xltap BY wenum.
*    DELETE lt_xltap WHERE wenum <> fs_out-mblnr.
*
*    SORT lt_xltap BY lgnum wenum tanum.
*    lt_zltap[] = lt_yltap[] = lt_xltap[].
*    DELETE lt_zltap WHERE zeugn = space.
*    SORT lt_yltap BY zeugn DESCENDING.
*    CLEAR ls_xltap.
*    READ TABLE lt_xltap INTO ls_xltap
*                        WITH KEY tanum = fs_out-tanum.
*    IF sy-subrc = 0.
*      IF ls_xltap-zeugn IS NOT INITIAL.
*        fs_header-pallet = ls_xltap-zeugn.
*      ELSE.
*        fs_header-pallet = sy-tabix.
*        CONDENSE fs_header-pallet.
**        IF fs_header-pallet <> 1.
**          IF lt_zltap[] IS INITIAL.
**            fs_header-pallet = 1.
**          ENDIF.
**        ENDIF.
*        CLEAR ls_yltap.
*        READ TABLE lt_yltap INTO ls_yltap
*                            WITH KEY zeugn = fs_header-pallet
*                            TRANSPORTING NO FIELDS.
*        IF sy-subrc = 0.
*          CLEAR ls_yltap.
*          READ TABLE lt_yltap INTO ls_yltap INDEX 1.
*          IF sy-subrc = 0.
*            fs_header-pallet = ls_yltap-zeugn + 1.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ELSE.
*    PERFORM f_pallet_count USING fs_out-tanum fs_out-mblnr
*                           CHANGING fs_header-pallet.
*  ENDIF.

  lv_pallet = fs_header-pallet.
  CONDENSE lv_pallet NO-GAPS.
  CONCATENATE fs_out-matnr fs_out-charg fs_out-tanum
              fs_header-qtyt lv_pallet
  INTO fs_header-qrcode
  SEPARATED BY ';'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_NEW_PALLET_COUNT
*&---------------------------------------------------------------------*
FORM f_new_pallet_count  TABLES   ft_out STRUCTURE gt_out
                         USING    fu_mblnr fu_tanum fu_new
                         CHANGING fc_pallet.
  DATA : lt_xout  LIKE gt_out OCCURS 0,
         ls_xout  LIKE LINE OF gt_out,
         lt_xltap LIKE gt_xltap OCCURS 0,
         ls_xltap LIKE LINE OF lt_xltap,
         lt_xpall TYPE STANDARD TABLE OF ty_pall,
         ls_xpall LIKE LINE OF lt_xpall.

  DATA : lv_zeugn TYPE ltap-zeugn,
         lv_count TYPE i,
         lv_lines TYPE i.

  lt_xltap[] = gt_xltap[].
  lt_xpall[] = gt_pall[].
  DELETE lt_xltap WHERE wenum <> fu_mblnr
                     OR vorga = 'ST'.
  DESCRIBE TABLE lt_xltap LINES lv_lines.

  LOOP AT lt_xpall INTO ls_xpall.
    ADD 1 TO lv_count.
    IF lv_count > lv_lines.
      EXIT.
    ENDIF.
    lv_zeugn  = ls_xpall-pallet.
    CONDENSE lv_zeugn NO-GAPS.
    READ TABLE lt_xltap INTO ls_xltap
                        WITH KEY zeugn = lv_zeugn.
    IF sy-subrc = 0.
      DELETE lt_xpall WHERE pallet = ls_xpall-pallet.
    ENDIF.
  ENDLOOP.

  SORT lt_xpall BY pallet.
  LOOP AT lt_xltap INTO ls_xltap.
    IF ls_xltap-zeugn IS INITIAL.
      READ TABLE lt_xpall INTO ls_xpall INDEX 1.
      IF sy-subrc = 0.
        ls_xltap-zeugn = ls_xpall-pallet.
        CONDENSE ls_xltap-zeugn NO-GAPS.
        fc_pallet      = ls_xpall-pallet.
        CONDENSE fc_pallet NO-GAPS.
        MODIFY lt_xltap FROM ls_xltap TRANSPORTING zeugn.
        DELETE TABLE lt_xpall FROM ls_xpall.
      ENDIF.
      TRY .
          UPDATE ltap SET zeugn = ls_xltap-zeugn
                          WHERE lgnum = ls_xltap-lgnum
                            AND tanum = ls_xltap-tanum
                            AND wenum = ls_xltap-wenum
                            AND nltyp = ls_xltap-nltyp.
        CATCH cx_sy_open_sql_db.
      ENDTRY.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDLOOP.

  CLEAR : ls_xltap.
  READ TABLE lt_xltap INTO ls_xltap
                      WITH KEY tanum = fu_tanum.
  IF sy-subrc = 0.
    CONDENSE ls_xltap-zeugn.
    fc_pallet = ls_xltap-zeugn.
  ENDIF.

*  lt_xout[] = ft_out[].
*  lt_xltap[] = gt_xltap[].
*  SORT lt_xout BY mblnr.
*  DELETE lt_xout WHERE mblnr <> fu_mblnr.
*  DELETE lt_xout WHERE new IS INITIAL.
*  SORT lt_xout BY lgnum mblnr tanum.
*  SORT lt_xltap BY lgnum wenum tanum.
*  LOOP AT lt_xout INTO ls_xout.
*    LOOP AT lt_xltap INTO ls_xltap WHERE wenum = fu_mblnr.
*      lv_zeugn  = sy-tabix.
*      IF ls_xltap-tanum = fu_tanum.
*        fc_pallet = lv_zeugn.
*      ENDIF.
*      IF fu_new IS NOT INITIAL.
*        CONDENSE lv_zeugn NO-GAPS.
*        TRY .
*            UPDATE ltap SET zeugn = lv_zeugn
*                            WHERE lgnum = ls_xltap-lgnum
*                              AND tanum = ls_xltap-tanum
*                              AND wenum = ls_xltap-wenum.
*          CATCH cx_sy_open_sql_db.
*        ENDTRY.
*      ENDIF.
*    ENDLOOP.
*  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_DRUKZ
*&---------------------------------------------------------------------*
FORM f_value_drukz  USING    fu_field.
  TYPES : BEGIN OF ty_t329t,
            lgnum TYPE t329t-lgnum,
            drukz TYPE t329t-drukz,
            ttext TYPE t329t-ttext,
          END OF ty_t329t.

  DATA : lt_t329t   TYPE STANDARD TABLE OF ty_t329t,
         ls_t329t   LIKE LINE OF lt_t329t,
         return_tab TYPE STANDARD TABLE OF ddshretval.

  DATA : lv_lgnum TYPE ltak-lgnum,
         lv_subrc TYPE sy-subrc.

  PERFORM f_dynp_value_read USING 'PA_LGNUM'
                            CHANGING lv_lgnum.

  SELECT lgnum drukz ttext
    FROM t329t
    INTO CORRESPONDING FIELDS OF TABLE lt_t329t
      WHERE spras = sy-langu
        AND lgnum = lv_lgnum.

  ASSIGN lt_t329t[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'DRUKZ' fu_field
                          CHANGING lv_subrc.



ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DYNP_VALUE_READ
*&---------------------------------------------------------------------*
FORM f_dynp_value_read  USING    fieldname
                        CHANGING fc_value.

  DATA : lt_dynpfields TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0,
         ls_dynpfields LIKE LINE OF lt_dynpfields.

  ls_dynpfields-fieldname   = fieldname.
  APPEND ls_dynpfields TO lt_dynpfields.
  CLEAR ls_dynpfields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
      request              = 'A'
    TABLES
      dynpfields           = lt_dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.

  LOOP AT lt_dynpfields INTO ls_dynpfields.
    CASE ls_dynpfields-fieldname.
      WHEN fieldname.
        fc_value  = ls_dynpfields-fieldvalue.
    ENDCASE.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM f_value_request  TABLES   return_tab STRUCTURE ddshretval
                      USING    fu_retfield fu_dynprofield
                      CHANGING fc_subrc.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield         = fu_retfield
      dynpprog         = sy-repid
      dynpnr           = sy-dynnr
      dynprofield      = fu_dynprofield
      value_org        = 'S'
      callback_program = sy-repid
      callback_form    = 'F4CALLBACK'
    TABLES
      value_tab        = <fs_tab>
      return_tab       = return_tab.

  fc_subrc  = sy-subrc.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f4callback
*&---------------------------------------------------------------------*
FORM f4callback TABLES   record_tab STRUCTURE seahlpres
                CHANGING shlp TYPE shlp_descr
                         callcontrol LIKE ddshf4ctrl.

  shlp-intdescr-dialogtype = 'D'.
  callcontrol-no_maxdisp = ''.
  callcontrol-maxrecords = 500.
ENDFORM.                                                    "f4callback

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_48_SHIPMENT
*&---------------------------------------------------------------------*
FORM f_get_data_48_shipment .
  DATA : ls_vttp LIKE LINE OF gt_vttp,
         ls_ltak LIKE LINE OF gt_ltak.

  IF pa_akhir IS INITIAL.
    SELECT lgnum tanum bdatu bzeit mblnr mjahr benum drukz druck lznum
      ltak~vbeln tapri queue lgtor refnr bwlvs tbnum tknum
      INTO CORRESPONDING FIELDS OF TABLE gt_ltak
      FROM ltak
      INNER JOIN vttp ON ltak~vbeln = vttp~vbeln
      WHERE lgnum = pa_lgnum
        AND tanum IN so_tanum
        AND mblnr IN so_mblnr
        AND kquit = space
        AND lznum = space
        AND tknum IN so_tknum.
  ELSE.
    IF pa_druck IS INITIAL.
      SELECT lgnum tanum bdatu bzeit mblnr mjahr benum drukz druck lznum
        ltak~vbeln tapri queue lgtor refnr bwlvs tbnum tknum
        INTO CORRESPONDING FIELDS OF TABLE gt_ltak
        FROM ltak
        INNER JOIN vttp ON ltak~vbeln = vttp~vbeln
        WHERE lgnum = pa_lgnum
          AND tanum IN so_tanum
          AND mblnr IN so_mblnr
          AND kquit = 'X'
          AND lznum = space
          AND tknum IN so_tknum.
    ELSE.
      SELECT lgnum tanum bdatu bzeit mblnr mjahr benum drukz druck lznum
        ltak~vbeln tapri queue lgtor refnr bwlvs tbnum tknum lgbzo
        INTO CORRESPONDING FIELDS OF TABLE gt_ltak
        FROM ltak
        INNER JOIN vttp ON ltak~vbeln = vttp~vbeln
        WHERE lgnum = pa_lgnum
          AND tanum IN so_tanum
          AND mblnr IN so_mblnr
          AND lznum <> space
          AND tknum IN so_tknum.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_LAYOUT_SHIPMENT
*&---------------------------------------------------------------------*
FORM f_modify_layout_shipment .
  DATA : lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout,
         ls_out  LIKE LINE OF gt_out.

  DATA : lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.

  DATA : lv_flag.

  SORT gt_out BY tknum kober tanum.

  lt_xout[] = gt_out[].
  SORT lt_xout BY tknum.
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING tknum.
  IF lt_xout[] IS NOT INITIAL.
    LOOP AT lt_xout INTO ls_xout.
      CLEAR lv_flag.
      LOOP AT gt_out INTO ls_out WHERE tknum = ls_xout-tknum.
        IF lv_flag IS NOT INITIAL.
          ls_stylerow-fieldname = 'CHECK'.
          ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
          APPEND ls_stylerow TO ls_out-style.
          MODIFY gt_out FROM ls_out TRANSPORTING style.
        ENDIF.
        lv_flag = 'X'.
        CLEAR : ls_out-style[], ls_stylerow.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_48_SHIPMENT
*&---------------------------------------------------------------------*
FORM f_48_shipment  TABLES   ft_out STRUCTURE gt_out
                    USING    fu_fname fu_ucomm.

  DATA : lwa_control_option TYPE ssfctrlop,
         lwa_output_option  TYPE ssfcompop,
         lt_out             TYPE STANDARD TABLE OF ty_out,
         lt_xout            TYPE STANDARD TABLE OF ty_out,
         ls_header          TYPE zmfindpick,
         ls_out             LIKE gt_out,
         ls_xout            LIKE gt_out,
         ls_t329d           LIKE LINE OF gt_t329d,
         lt_detail          TYPE STANDARD TABLE OF zmfindpick,
         ls_detail          LIKE LINE OF lt_detail,
         lt_to              TYPE STANDARD TABLE OF zwmst008.

  DATA : l_funcname TYPE tdsfname,
         lv_lines   TYPE i,
         lv_umrez   TYPE marm-umrez,
         lv_mod     TYPE p DECIMALS 0,
         lv_div     TYPE p DECIMALS 0.

  CHECK fu_fname IS NOT INITIAL.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = fu_fname
    IMPORTING
      fm_name            = l_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF pa_form IS NOT INITIAL.
*    lwa_control_option-no_dialog = 'X'.

    lwa_output_option-tdnewid    = 'X'.
    lwa_output_option-tdimmed    = 'X'.
    lwa_output_option-tddelete   = ''.
    lwa_output_option-tddest     = default-spld.
  ENDIF.

  lt_out[] = ft_out[].
  SORT lt_out BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_out COMPARING kunnr.
  DELETE lt_out WHERE kunnr = space.
  DESCRIBE TABLE lt_out LINES lv_lines.

  SELECT SINGLE lnumt
    FROM t300t
    INTO ls_header-company
    WHERE spras EQ sy-langu
      AND lgnum EQ pa_lgnum.

  TRANSLATE ls_header-company TO UPPER CASE.
  ls_header-drukz = pa_drukz.

  IF pa_druck IS NOT INITIAL.
    ls_header-reprint = 'REPRINT'.
  ENDIF.

  ls_header-group = 'X'.

  lt_xout[] = gt_out[].
  SORT lt_xout BY tknum kober.
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING tknum kober.
  LOOP AT lt_xout INTO ls_xout.
    CLEAR ls_out.
    READ TABLE ft_out INTO ls_out
                      WITH KEY tknum = ls_xout-tknum.
    IF sy-subrc <> 0.
      TRY.
          DELETE TABLE lt_xout FROM ls_xout.
        CATCH cx_sy_open_sql_db.
      ENDTRY.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_xout INTO ls_out.
    AT FIRST.
      lwa_control_option-no_close = 'X'.
    ENDAT.

    AT LAST.
*      lwa_control_option-no_close = space.
    ENDAT.

    CLEAR : ls_t329d.
    READ TABLE gt_t329d INTO ls_t329d
                        WITH KEY nltyp = ls_out-nltyp.
    IF sy-subrc = 0.
      lwa_output_option-tddest    = ls_t329d-ldest.
    ELSE.
      lwa_output_option-tddest    = default-spld.
    ENDIF.

    IF fu_ucomm = '&PREV'.
      lwa_output_option-tdnoprint = 'X'.
    ELSE.
      IF pa_form IS INITIAL.
        IF fu_ucomm = '&POS'.
          lwa_output_option-tdnoprev = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.

    ls_header-kunnr = ls_out-kunnr.
    ls_header-name1 = ls_out-name1.
    ls_header-route = ls_out-route.
    SELECT SINGLE bezei
      FROM tvrot
      INTO ls_header-bezei
      WHERE spras EQ sy-langu AND
            route EQ ls_out-route.

    IF fu_ucomm = '&POS'.
      PERFORM f_grouping.
    ENDIF.

    PERFORM f_prepare_detail TABLES lt_detail
                             USING ls_out-tknum ls_out-kober.

    LOOP AT lt_detail INTO ls_detail.
      SELECT SINGLE umrez
        FROM marm
        INTO lv_umrez
        WHERE matnr = ls_detail-matnr
          AND meinh = 'KAR'.

      IF sy-subrc = 0.
        CLEAR : lv_mod, lv_div.
        WRITE ls_detail-vsola TO ls_detail-tvsola UNIT ls_detail-altme.
        WRITE lv_umrez TO ls_detail-satuan DECIMALS 0.
        lv_mod    = ls_detail-vsola MOD lv_umrez.
        lv_div    = ls_detail-vsola DIV lv_umrez.
        ls_detail-carton  = lv_div.
        CONDENSE ls_detail-carton NO-GAPS.
        ls_detail-receh   = lv_mod.
        MODIFY lt_detail FROM ls_detail TRANSPORTING tvsola satuan carton receh.
      ENDIF.
    ENDLOOP.

    ls_header-lznum = ls_out-lznum.

*    IF pa_lgnum = 'C40'.
*      ls_header-vltyp = ls_out-vltyp.
*      IF ls_header-vltyp(1) = 'L'.
*        CONCATENATE 'L/' ls_header-reprint INTO ls_header-reprint.
*      ELSE.
*        ls_header-reprint = 'REPRINT'.
*      ENDIF.
*    ENDIF.



    PERFORM f_prepare_footer USING ls_out-tknum
                             CHANGING ls_header-shipno ls_header-zona
                                      ls_header-pickgrp ls_header-delvno.

    IF fu_ucomm <> '&GRP'.
      CALL FUNCTION l_funcname
        EXPORTING
          control_parameters = lwa_control_option
          output_options     = lwa_output_option
          user_settings      = space
          gs_head            = ls_header
        TABLES
          gt_detl            = lt_detail
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
    ENDIF.
    lwa_control_option-no_open = 'X'.
  ENDLOOP.

  IF fu_ucomm <> '&GRP'.
    PERFORM f_prepare_lampiran TABLES lt_to.
    PERFORM f_lampiran_to_number TABLES lt_to
                                 USING 'ZMF_IND_PICKLIST_LAMPIRAN'
                                       lwa_control_option
                                       lwa_output_option
                                       ls_header.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_FOOTER
*&---------------------------------------------------------------------*
FORM f_prepare_footer  USING    fu_tknum
                       CHANGING fc_shipno fc_zona fc_pickgrp fc_delvno.
  DATA : lt_out   TYPE STANDARD TABLE OF ty_out,
         ls_out   LIKE LINE OF lt_out,
         lt_foot  TYPE STANDARD TABLE OF ty_footer,
         lt_xfoot TYPE STANDARD TABLE OF ty_footer,
         ls_foot  TYPE ty_footer.

  CLEAR : fc_shipno, fc_zona, fc_pickgrp, fc_delvno.

  fc_shipno = fu_tknum.
  lt_out[] = gt_out[].
  DELETE lt_out WHERE check = space.
  DELETE lt_out WHERE tknum <> fu_tknum.
  LOOP AT lt_out INTO ls_out.
    ls_foot-kober = ls_out-kober.
    ls_foot-lznum = ls_out-lznum.
    ls_foot-vbeln = ls_out-nlpla.
    APPEND ls_foot TO lt_foot.
    CLEAR ls_foot.
  ENDLOOP.

  lt_xfoot[] = lt_foot[].
  SORT lt_xfoot BY kober.
  DELETE ADJACENT DUPLICATES FROM lt_xfoot COMPARING kober.
  LOOP AT lt_xfoot INTO ls_foot.
    fc_zona = |{ fc_zona },{ ls_foot-kober }|.
  ENDLOOP.
  SHIFT fc_zona LEFT DELETING LEADING ','.

  lt_xfoot[] = lt_foot[].
  SORT lt_xfoot BY lznum.
  DELETE ADJACENT DUPLICATES FROM lt_xfoot COMPARING lznum.
  LOOP AT lt_xfoot INTO ls_foot.
    fc_pickgrp = |{ fc_pickgrp },{ ls_foot-lznum+10(5) }|.
  ENDLOOP.
  SHIFT fc_pickgrp LEFT DELETING LEADING ','.

  lt_xfoot[] = lt_foot[].
  SORT lt_xfoot BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_xfoot COMPARING vbeln.
  LOOP AT lt_xfoot INTO ls_foot.
    fc_delvno = |{ fc_delvno },{ ls_foot-vbeln }|.
  ENDLOOP.
  SHIFT fc_delvno LEFT DELETING LEADING ','.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DETAIL
*&---------------------------------------------------------------------*
FORM f_prepare_detail  TABLES   ft_detail STRUCTURE zmfindpick
                       USING    fu_tknum fu_kober.
  CLEAR : ft_detail[].

  DATA : lt_xout   TYPE STANDARD TABLE OF ty_out,
         ls_xout   LIKE LINE OF lt_xout,
         lt_xltap  LIKE gt_ltap OCCURS 0,
         ls_xltap  LIKE LINE OF gt_ltap,
         ls_detail TYPE zmfindpick,
         ls_ltap   LIKE LINE OF gt_ltap.

  DATA : lv_tvsola TYPE ltap-vsola.

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE tknum <> fu_tknum.
  DELETE lt_xout WHERE kober <> fu_kober.

  SORT lt_xout BY tanum.
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING tanum.
  SORT gt_ltap BY tanum matnr charg vlpla.
  lt_xltap[] = gt_ltap[].
  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING tanum matnr charg vlpla.

  LOOP AT lt_xout INTO ls_xout.
    LOOP AT lt_xltap INTO ls_xltap WHERE tanum = ls_xout-tanum.
      ls_detail-matnr = ls_xltap-matnr.
      ls_detail-charg = ls_xltap-charg.
      ls_detail-vfdat = ls_xltap-vfdat.
      ls_detail-maktx = ls_xltap-maktx.
      ls_detail-vltyp = ls_xltap-vltyp.
      ls_detail-vlber = ls_xltap-vlber.
      ls_detail-vlpla = ls_xltap-vlpla.
      ls_detail-altme = ls_xltap-altme.
      CLEAR : ls_ltap, lv_tvsola.
      LOOP AT gt_ltap INTO ls_ltap WHERE tanum = ls_xout-tanum
                                     AND matnr = ls_xltap-matnr
                                     AND charg = ls_xltap-charg
                                     AND vlpla = ls_xltap-vlpla.
        ADD ls_ltap-vsola TO lv_tvsola.
      ENDLOOP.

      ls_detail-vsola = lv_tvsola.
      COLLECT ls_detail INTO ft_detail.
      CLEAR ls_detail.
    ENDLOOP.
  ENDLOOP.

  SORT ft_detail BY vlpla.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GROUPING
*&---------------------------------------------------------------------*
FORM f_grouping .
  DATA : lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout,
         lt_yout TYPE STANDARD TABLE OF ty_out,
         ls_yout LIKE LINE OF lt_xout,
         ls_out  LIKE LINE OF gt_out.

  DATA : lv_number TYPE numc15,
         lv_subrc  TYPE sy-subrc.

  lt_yout[] = lt_xout[] = gt_out[].
  DELETE lt_xout WHERE check IS INITIAL.
  SORT lt_xout BY tknum.
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING tknum.
  SORT lt_yout BY tknum kober.
  DELETE ADJACENT DUPLICATES FROM lt_yout COMPARING tknum kober.
  LOOP AT lt_xout INTO ls_xout.
    LOOP AT lt_yout INTO ls_yout WHERE tknum = ls_xout-tknum.
      PERFORM f_get_next_number CHANGING lv_number lv_subrc.
      LOOP AT gt_out INTO ls_out WHERE tknum = ls_yout-tknum
                                   AND kober = ls_yout-kober.
        PERFORM f_check_grouping USING ls_out-lgnum ls_out-tanum
                                 CHANGING lv_subrc.
        IF lv_subrc = 0.
          ls_out-lznum = lv_number.
          MODIFY gt_out FROM ls_out
                        TRANSPORTING lznum
                        WHERE lgnum = ls_out-lgnum
                          AND tanum = ls_out-tanum.
          TRY.
              UPDATE ltak SET lznum = ls_out-lznum
                          WHERE lgnum = ls_out-lgnum
                            AND tanum = ls_out-tanum.
            CATCH cx_sy_open_sql_db.
          ENDTRY.
        ELSE.
          ls_out-check  = space.
          MODIFY gt_out FROM ls_out
                        TRANSPORTING check.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_NEXT_NUMBER
*&---------------------------------------------------------------------*
FORM f_get_next_number  CHANGING fc_number fc_subrc.
  CLEAR : fc_subrc, fc_number.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZCOLPRNTTO'
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

  fc_subrc = sy-subrc.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_SHIPMENT
*&---------------------------------------------------------------------*
FORM f_get_shipment .
  DATA : ls_ltak LIKE LINE OF gt_ltak,
         ls_vttp LIKE LINE OF gt_vttp.

  IF gt_ltak[] IS NOT INITIAL.
    SELECT tknum tpnum vbeln
      FROM vttp
      INTO CORRESPONDING FIELDS OF TABLE gt_vttp
      FOR ALL ENTRIES IN gt_ltak
      WHERE vbeln = gt_ltak-vbeln.

    LOOP AT gt_ltak INTO ls_ltak.
      CLEAR ls_vttp.
      READ TABLE gt_vttp INTO ls_vttp
                         WITH KEY vbeln = ls_ltak-vbeln.
      IF sy-subrc = 0.
        ls_ltak-tknum = ls_vttp-tknum.
        MODIFY gt_ltak FROM ls_ltak TRANSPORTING tknum.
      ENDIF.
      CLEAR ls_ltak.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_LAMPIRAN_TO_NUMBER
*&---------------------------------------------------------------------*
FORM f_lampiran_to_number TABLES  ft_to   STRUCTURE zwmst008
                          USING   fu_fname
                                  lwa_control_option TYPE ssfctrlop
                                  lwa_output_option TYPE ssfcompop
                                  ls_header TYPE zmfindpick.
  DATA : l_funcname TYPE tdsfname,
         ls_detail  TYPE zwmst008.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = fu_fname
    IMPORTING
      fm_name            = l_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF l_funcname IS NOT INITIAL.
    lwa_control_option-no_open = 'X'.

    LOOP AT ft_to INTO ls_detail.
      AT LAST.
        lwa_control_option-no_close = space.
      ENDAT.

      SEARCH ls_detail-01lzn FOR '&' AND MARK.
      IF sy-subrc <> 0.
        ls_header-lznum = ls_detail-01lzn.
      ENDIF.

      CALL FUNCTION l_funcname
        EXPORTING
          control_parameters = lwa_control_option
          output_options     = lwa_output_option
          user_settings      = space
          gs_head            = ls_header
          gs_detl            = ls_detail
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_LAMPIRAN
*&---------------------------------------------------------------------*
FORM f_prepare_lampiran  TABLES   ft_to STRUCTURE zwmst008.
  TYPES : BEGIN OF ty_to,
            lznum TYPE ltak-lznum,
            tknum TYPE vttk-tknum,
            kober TYPE lagp-kober,
            tanum TYPE ltak-tanum,
            vbeln TYPE ltak-vbeln,
          END OF ty_to.

  DATA : ls_out   LIKE LINE OF gt_out,
         lt_xto   TYPE STANDARD TABLE OF ty_to,
         ls_xto   LIKE LINE OF lt_xto,
         lt_yto   TYPE STANDARD TABLE OF ty_to,
         ls_yto   LIKE LINE OF lt_yto,
         dyn_tab  TYPE REF TO data,
         dyn_line TYPE REF TO data.

  DATA : lv_count(2)      TYPE n,
         lv_fieldname(30),
         lv_lznum         TYPE ltak-lznum.

  FIELD-SYMBOLS : <ft_tab> TYPE STANDARD TABLE,
                  <fs_tab> TYPE any,
                  <fs>     TYPE any.

  CREATE DATA dyn_tab TYPE STANDARD TABLE OF zwmst008.
  ASSIGN dyn_tab->* TO <ft_tab>.
  CREATE DATA dyn_line LIKE LINE OF <ft_tab>.
  ASSIGN dyn_line->* TO <fs_tab>.

  LOOP AT gt_out INTO ls_out.
    IF ls_out-lznum IS INITIAL.
      CONTINUE.
    ENDIF.
    ls_xto-lznum  = ls_out-lznum.
    ls_xto-tknum  = ls_out-tknum.
    ls_xto-kober  = ls_out-kober.
    ls_xto-tanum  = ls_out-tanum.
    ls_xto-vbeln  = ls_out-vbeln.
    APPEND ls_xto TO lt_xto.
    CLEAR ls_xto.
  ENDLOOP.

  lt_yto[] = lt_xto[].
  SORT lt_yto BY tknum kober.
  DELETE ADJACENT DUPLICATES FROM lt_yto COMPARING tknum kober.
  LOOP AT lt_yto INTO ls_yto.
    ADD 1 TO lv_lznum.
    LOOP AT lt_xto INTO ls_xto WHERE tknum = ls_yto-tknum
                                 AND kober = ls_yto-kober.
      IF ls_xto-lznum IS INITIAL.
        ls_xto-lznum = lv_lznum.
        CONDENSE ls_xto-lznum NO-GAPS.
        ls_xto-lznum = |{ '&' } { ls_xto-lznum }|.
        MODIFY lt_xto FROM ls_xto TRANSPORTING lznum.
      ENDIF.
      CLEAR ls_xto.
    ENDLOOP.
  ENDLOOP.

  SORT lt_xto BY tanum.
  DELETE ADJACENT DUPLICATES FROM lt_xto COMPARING tanum.
  lt_yto[] = lt_xto[].
  SORT lt_yto BY lznum.
  DELETE ADJACENT DUPLICATES FROM lt_yto COMPARING lznum.

  LOOP AT lt_yto INTO ls_yto.
    LOOP AT lt_xto INTO ls_xto WHERE lznum = ls_yto-lznum.
      ADD 1 TO lv_count.
      IF lv_count = '01'.
        APPEND INITIAL LINE TO <ft_tab> ASSIGNING <fs_tab>.
      ENDIF.
      IF ls_xto-tanum IS NOT INITIAL.
        lv_fieldname = |{ lv_count }{ 'LZN'}|.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_tab> TO <fs>.
        <fs> = ls_xto-lznum.
        lv_fieldname = |{ lv_count }{ 'TKN'}|.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_tab> TO <fs>.
        <fs> = ls_xto-tknum.
        lv_fieldname = |{ lv_count }{ 'KOB'}|.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_tab> TO <fs>.
        <fs> = ls_xto-kober.
        lv_fieldname = |{ lv_count }{ 'TAN'}|.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_tab> TO <fs>.
        <fs> = ls_xto-tanum.
        lv_fieldname = |{ lv_count }{ 'VVL'}|.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_tab> TO <fs>.
        <fs> = ls_xto-vbeln.
        lv_fieldname = |{ lv_count }{ 'CQR'}|.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_tab> TO <fs>.
        <fs> = |{ ls_xto-tanum },{ ls_xto-vbeln }|.
      ENDIF.
      IF lv_count = '12'.
        CLEAR lv_count.
      ENDIF.
    ENDLOOP.
    CLEAR lv_count.
  ENDLOOP.
  ft_to[] = <ft_tab>[].
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_length fu_required.
  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_length IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-length  = fu_length.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_required IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-required  = fu_required.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_LTAK
*&---------------------------------------------------------------------*
FORM f_update_ltak  USING    fu_lgnum
                             fu_tknum
                             fu_lprio.
  DATA: ls_stylerow TYPE lvc_s_styl.

  LOOP AT gt_lprio INTO DATA(ls_lprio) WHERE lgnum = fu_lgnum
                                         AND tknum = fu_tknum.
    UPDATE ltak SET tapri = fu_lprio
                WHERE lgnum	= ls_lprio-lgnum
                  AND tanum	= ls_lprio-tanum.
    IF sy-subrc = 0.
      IF ls_lprio-check = 'X'.
        CLEAR: ls_lprio-check,ls_stylerow.
        ls_stylerow-fieldname = 'CHECK'.
        ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
        APPEND ls_stylerow TO ls_lprio-style.
        CLEAR ls_stylerow.
        ls_stylerow-fieldname = 'LPRIO'.
        ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
        APPEND ls_stylerow TO ls_lprio-style.
        MODIFY gt_lprio FROM ls_lprio TRANSPORTING check style.
      ELSE.
        ls_lprio-lprio = fu_lprio.
        MODIFY gt_lprio FROM ls_lprio TRANSPORTING lprio.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.

FORM f_get_num CHANGING number.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZCOLPRNTTO'
    IMPORTING
      number                  = number
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      OTHERS                  = 7.
ENDFORM.


FORM f_prepare_46 TABLES ft_detail STRUCTURE zwmprntto USING fu_lznum fu_vlpla fu_nistm CHANGING fc_total.
  DATA : lt_xout   TYPE STANDARD TABLE OF ty_out,
         ls_xout   LIKE LINE OF lt_xout,
         ls_detail TYPE zwmprntto,
         ls_ltap   LIKE LINE OF gt_ltap,
         ls_out    LIKE LINE OF gt_out,
         lt_xltap  LIKE gt_ltap OCCURS 0,
         ls_xltap  LIKE LINE OF gt_ltap.

  DATA : lv_tvsola         TYPE ltap-vsola,
         lv_umrez          TYPE marm-umrez,
         lv_mod            TYPE p DECIMALS 0,
         lv_div            TYPE p DECIMALS 0,
         lv_carton         TYPE p DECIMALS 0,
         lv_receh          TYPE p DECIMALS 0,
         lv_t1(20),
         lv_t2(20),
         lv_nistm_char(20),
         lv_nistm1(20),
         lv_nistm2(20),
         final_nistm(20).
  DATA: lv_nistm TYPE p DECIMALS 0.
  CLEAR : ft_detail[], lv_carton, lv_receh, lv_nistm, lv_tvsola, lv_nistm1, lv_nistm2, final_nistm.

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE lznum <> fu_lznum AND vlpla <> fu_vlpla.
  SORT lt_xout BY lznum matnr charg vlpla.
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING lznum matnr charg vlpla.
*  SORT lt_xout BY tanum.
*  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING tanum.
*  SORT gt_ltap BY tanum matnr charg vlpla.
*  lt_xltap[] = gt_ltap[].
*  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING tanum matnr charg vlpla.

  LOOP AT lt_xout INTO ls_xout WHERE lznum = fu_lznum AND vlpla = fu_vlpla.
    ls_detail-tanum = ls_xout-tanum.
    ls_detail-lznum = ls_xout-lznum.
    ls_detail-ename = ls_xout-ename.
    ls_detail-edatu = ls_xout-edatu.
    ls_detail-ezeit = ls_xout-ezeit.
    ls_detail-kunnr = ls_xout-kunnr.
    ls_detail-vbeln = ls_xout-vbeln.
    ls_detail-queue = ls_xout-queue.
    ls_detail-route = ls_xout-route.
    ls_detail-bezei = ls_xout-bezei.
    ls_detail-lgbzo = ls_xout-lgbzo.
    ls_detail-lgtor = ls_xout-lgtor.
    ls_detail-matnr = ls_xout-matnr.
    ls_detail-charg = ls_xout-charg.
    ls_detail-vlpla = ls_xout-vlpla.
    ls_detail-nistm = fu_nistm.
    ls_detail-maktx = ls_xout-maktx.
    ls_detail-queue = ls_xout-queue.
    ls_detail-lgbzo = ls_xout-lgbzo.
    ls_detail-lgtor = ls_xout-lgtor.
    ls_detail-tknum = ls_xout-tknum.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input  = ls_xout-meins
      IMPORTING
        output = ls_xout-meins.
    TRANSLATE ls_xout-meins TO UPPER CASE.
    ls_detail-meins = ls_xout-meins.
    ls_detail-altme = ls_xout-altme.
    ls_detail-lznum = ls_xout-lznum.
    ls_detail-vfdat = ls_xout-vfdat.
*    WRITE fu_nistm TO lv_nistm_char.
*    SPLIT lv_nistm_char AT ',' INTO lv_nistm1 lv_nistm2.
*    CONDENSE lv_nistm1 NO-GAPS.
*    CONCATENATE lv_nistm1 ls_detail-meins INTO final_nistm SEPARATED BY space.
*    ls_detail-nistm_quan = final_nistm.

*    LOOP AT lt_xltap INTO ls_xltap WHERE tanum = ls_xout-tanum.
*      ls_detail-matnr = ls_xltap-matnr.
*      ls_detail-charg = ls_xltap-charg.
*      ls_detail-vfdat = ls_xltap-vfdat.
*      ls_detail-maktx = ls_xltap-maktx.
*      ls_detail-vltyp = ls_xltap-vltyp.
**      ls_detail-vlber = ls_xltap-vlber.
*      ls_detail-vlpla = ls_xltap-vlpla.
*      ls_detail-altme = ls_xltap-altme.
*
*      ls_detail-lgnum = ls_xltap-lgnum.
*
*      IF ls_detail-lgnum = 'C40'.
*        ls_detail-nltyp = ls_xltap-nltyp.
*        ls_detail-nlber = ls_xltap-nlber.
*        ls_detail-nlpla = ls_xltap-nlpla.
*      ENDIF.
*
*      CLEAR : ls_ltap, lv_tvsola.
*      LOOP AT gt_ltap INTO ls_ltap WHERE tanum = ls_xltap-tanum
*                                     AND matnr = ls_xltap-matnr
*                                     AND charg = ls_xltap-charg
*                                     AND vlpla = ls_xltap-vlpla.
*        ADD ls_ltap-vsola TO lv_tvsola.
*      ENDLOOP.
*
*      ls_detail-vsola = lv_tvsola.
    LOOP AT gt_ltap INTO ls_ltap WHERE "lznum = ls_xout-lznum
                               matnr = ls_xout-matnr
                               AND charg = ls_xout-charg
                               AND vlpla = ls_xout-vlpla.
      ADD ls_ltap-vsola TO lv_tvsola.
      ADD ls_ltap-nistm TO lv_nistm.

      CLEAR : lv_umrez.
      SELECT SINGLE umrez
        FROM marm
        INTO lv_umrez
        WHERE matnr = ls_ltap-matnr
          AND meinh = 'KAR'.

      IF sy-subrc = 0.
        CLEAR : lv_mod, lv_div, lv_carton, lv_receh.
*      WRITE ls_detail-vsola TO ls_detail-tvsola UNIT ls_detail-altme.
*      WRITE lv_umrez TO ls_detail-satuan DECIMALS 0.
        lv_mod    = lv_nistm MOD lv_umrez.
        lv_div    = lv_nistm DIV lv_umrez.
        ls_detail-carton  = lv_div.
        CONDENSE ls_detail-carton NO-GAPS.
        ls_detail-receh   = lv_mod.
*        MODIFY ft_detail FROM ls_detail TRANSPORTING carton receh. "tvsola satuan
        ADD lv_div TO lv_carton.
        ADD lv_mod TO lv_receh.
      ENDIF.


    ENDLOOP.
    lv_t1 = lv_carton.
    CONDENSE lv_t1 NO-GAPS.
    lv_t2 = lv_receh.
    CONDENSE lv_t2 NO-GAPS.
    fc_total = |{ lv_t1 } { 'CAR' } + { lv_t2 } { ls_xout-meins }|."{ 'PC' }|.
    ls_detail-totalt = fc_total.


    ls_detail-vsola = lv_tvsola.
    ls_detail-nistm = lv_nistm.
    WRITE ls_detail-nistm TO lv_nistm_char.
    SPLIT lv_nistm_char AT ',' INTO lv_nistm1 lv_nistm2.
    CONDENSE lv_nistm1 NO-GAPS.
    CONCATENATE lv_nistm1 ls_detail-meins INTO final_nistm SEPARATED BY space.
    ls_detail-nistm_quan = final_nistm.
    COLLECT ls_detail INTO ft_detail.
    CLEAR ls_detail.
  ENDLOOP.


*  SORT ft_detail BY vlpla.
*  LOOP AT ft_detail INTO ls_detail.
*    CLEAR : lv_umrez.
*    SELECT SINGLE umrez
*      FROM marm
*      INTO lv_umrez
*      WHERE matnr = ls_detail-matnr
*        AND meinh = 'KAR'.
*
*    IF sy-subrc = 0.
*      CLEAR : lv_mod, lv_div.
**      WRITE ls_detail-vsola TO ls_detail-tvsola UNIT ls_detail-altme.
**      WRITE lv_umrez TO ls_detail-satuan DECIMALS 0.
*      lv_mod    = ls_detail-nistm MOD lv_umrez.
*      lv_div    = ls_detail-nistm DIV lv_umrez.
*      ls_detail-carton  = lv_div.
*      CONDENSE ls_detail-carton NO-GAPS.
*      ls_detail-receh   = lv_mod.
*      MODIFY ft_detail FROM ls_detail TRANSPORTING carton receh. "tvsola satuan
*      ADD lv_div TO lv_carton.
*      ADD lv_mod TO lv_receh.
*    ENDIF.
*  ENDLOOP.

*  lv_t1 = lv_carton.
*  CONDENSE lv_t1 NO-GAPS.
*  lv_t2 = lv_receh.
*  CONDENSE lv_t2 NO-GAPS.
*  fc_total = |{ lv_t1 } { 'CAR' } + { lv_t2 } { 'PC' }|.
ENDFORM.

FORM update_additional_number USING fu_add_num fu_lgnum fu_vlpla.
  TRY.
      UPDATE ltak SET lznum = fu_add_num WHERE lgnum = fu_lgnum AND tanum = fu_vlpla.
    CATCH cx_sy_open_sql_db.
      sy-subrc = 4.
  ENDTRY.
  IF sy-subrc = 0.
    COMMIT WORK AND WAIT.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_46_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_DETL4  text
*      -->P_LS_DETL3_MATNR  text
*      -->P_LS_DETL3_CHARG  text
*      -->P_LS_DETL3_VLPLA  text
*      -->P_LS_DETL3_MAKTX  text
*      -->P_LS_DETL3_NISTM_QUAN  text
*      -->P_LS_DETL3_TOTALT  text
*      -->P_LS_DETL3_VFDAT  text
*----------------------------------------------------------------------*
FORM f_prepare_46_2  TABLES   p_lt_detl4 STRUCTURE zwmprntto
                     USING    p_ls_detl3_matnr
                              p_ls_detl3_charg
                              p_ls_detl3_vlpla
                              p_ls_detl3_maktx
                              p_ls_detl3_nistm_quan
                              p_ls_detl3_totalt
                              p_ls_detl3_vfdat.

  DATA: ls_detl4 TYPE zwmprntto.
  CLEAR: ls_detl4, p_lt_detl4.
  ls_detl4-matnr =  p_ls_detl3_matnr.
  ls_detl4-charg = p_ls_detl3_charg.
  ls_detl4-vlpla = p_ls_detl3_vlpla.
  ls_detl4-maktx = p_ls_detl3_maktx.
  ls_detl4-nistm_quan =  p_ls_detl3_nistm_quan.
  ls_detl4-totalt = p_ls_detl3_totalt.
  ls_detl4-vfdat = p_ls_detl3_vfdat.
  APPEND ls_detl4 TO p_lt_detl4.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM_50
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_04  text
*----------------------------------------------------------------------*
FORM f_print_form_50  TABLES   lt_04 STRUCTURE zwm_sf004.
  DATA: xlt_04 TYPE TABLE OF zwm_sf004,
        xls_04 TYPE zwm_sf004.
  DATA : lv_fname  TYPE tdsfname.
  DATA : l_funcname TYPE tdsfname.
  DATA : lwa_control_option TYPE ssfctrlop,
         lwa_output_option  TYPE ssfcompop.
  DATA: flag TYPE i.
  CLEAR: flag.

  xlt_04[] = lt_04[].
  DELETE xlt_04[] WHERE check = space.

  lv_fname = 'ZWM_SF004'.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_fname
    IMPORTING
      fm_name            = l_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  DESCRIBE TABLE xlt_04 LINES DATA(no_rec).
  LOOP AT xlt_04 INTO xls_04.
    IF no_rec = 1.
      CALL FUNCTION l_funcname
        EXPORTING
          control_parameters = lwa_control_option
          output_options     = lwa_output_option
          user_settings      = space
          gs_04              = xls_04
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
    ELSE.
      IF sy-tabix = no_rec.
        flag = '2'.
      ENDIF.

      AT END OF check.
        IF flag = space.
          lwa_control_option-no_close = 'X'.
          lwa_control_option-no_open = space.
          flag = '1'.
        ELSEIF flag = '1'.
          lwa_control_option-no_close = 'X'.
          lwa_control_option-no_open = 'X'.
        ELSEIF flag = '2'.
          lwa_control_option-no_close = space.
          lwa_control_option-no_open = 'X'.
        ENDIF.
      ENDAT.
      CALL FUNCTION l_funcname
        EXPORTING
          control_parameters = lwa_control_option
          output_options     = lwa_output_option
          user_settings      = space
          gs_04              = xls_04
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_LAYOUT_SHIPMENT5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_layout_shipment5 .
  DATA : lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout,
         ls_out  LIKE LINE OF gt_out.

  DATA : lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.

  DATA : lv_flag.
  SORT gt_out BY nlpla."tknum."kober tanum.

  lt_xout[] = gt_out[].
  SORT lt_xout BY nlpla."tknum."lznum .
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING nlpla."tknum."lznum.
  IF lt_xout[] IS NOT INITIAL.
    LOOP AT lt_xout INTO ls_xout.
      CLEAR lv_flag.
      LOOP AT gt_out INTO ls_out WHERE nlpla = ls_xout-nlpla."tknum = ls_xout-tknum."lznum = ls_xout-lznum.
        IF lv_flag IS NOT INITIAL.
          ls_stylerow-fieldname = 'CHECK'.
          ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
          APPEND ls_stylerow TO ls_out-style.
          MODIFY gt_out FROM ls_out TRANSPORTING style.
        ENDIF.
        lv_flag = 'X'.
        CLEAR : ls_out-style[], ls_stylerow.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.
