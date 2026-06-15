*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.

ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: l_kvgr3 LIKE t_s603key OCCURS 0 WITH HEADER LINE,
        lt_uplkp LIKE t_uplkp OCCURS 0 WITH HEADER LINE,
        l_knkli LIKE zscl_sm-knkli,
        l_value TYPE p,
        ld_length TYPE i,
*        ld_filename(12),
        ld_filename TYPE string,
        ld_extension TYPE string,
        ld_filename1(8),
        ld_filename2(3),
        ld_strlen TYPE int4.

  CASE 'X'.
    WHEN p_down.
* Get Detail
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE t_itab
        FROM zscl_sm
        WHERE gjahr = pa_gjahr   AND
              zsmst = pa_zsmst   AND
              vkorg = pa_vkorg   AND
              vkbur = pa_vkbur  AND
              knkli IN so_knkli  AND
              status = space.

      IF t_itab[] IS NOT INITIAL.
* Get Customer
        SELECT kunnr sortl name1 aufsd vtext
        INTO CORRESPONDING FIELDS OF TABLE t_kna1
        FROM kna1 AS a LEFT OUTER JOIN tvast AS b ON b~spras = sy-langu AND
                                                b~aufsp = a~aufsd
*      FOR ALL ENTRIES IN t_s603key
*      WHERE kunnr = t_s603key-pkunwe.
        FOR ALL ENTRIES IN t_itab
        WHERE kunnr = t_itab-knkli.

* get Bank Garansi
        IF t_itab[] IS NOT INITIAL.
          t_kdgrp[] = t_itab[].
          t_knkli[] = t_itab[].
          SORT t_kdgrp BY kdgrp.
          SORT t_knkli BY knkli.
          DELETE ADJACENT DUPLICATES FROM t_kdgrp COMPARING kdgrp.
          DELETE t_kdgrp WHERE kdgrp EQ space.
          DELETE ADJACENT DUPLICATES FROM t_knkli COMPARING knkli.

          IF t_knkli[] IS NOT INITIAL.
            SELECT *
              FROM zsbankgrs
              INTO CORRESPONDING FIELDS OF TABLE t_zsbankgrs_kdgrp
              FOR ALL ENTRIES IN t_kdgrp
              WHERE kdgrp EQ t_kdgrp-kdgrp.
            SELECT *
              FROM zsbankgrs
              INTO CORRESPONDING FIELDS OF TABLE t_zsbankgrs_knkli
              FOR ALL ENTRIES IN t_knkli
              WHERE kunnr EQ t_knkli-knkli.
          ENDIF.
        ENDIF.
      ENDIF.

      SORT t_itab BY knkli.
      SORT t_kna1 BY kunnr.

    WHEN p_uplod.
* Check nama file
*    ld_length = STRLEN( work_di1 ).
*    WRITE work_di1 TO ld_filename RIGHT-JUSTIFIED.
*    SPLIT ld_filename AT '.' INTO: ld_filename1 ld_filename2.
      CALL FUNCTION 'CRM_IC_WZ_SPLIT_FILE_EXTENSION'
        EXPORTING
          iv_filename_with_ext = work_di1
        IMPORTING
          ev_filename          = ld_filename
          ev_extension         = ld_extension.
      IF sy-subrc = 0.
        WRITE ld_filename TO ld_filename1 RIGHT-JUSTIFIED.
        WRITE ld_extension TO ld_filename2.
      ENDIF.

* Upload from excel
      REFRESH t_excel.
      CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
        EXPORTING
          filename                = work_di1 "INPUT FROM SELECTION SCREEN
          i_begin_col             = 1
          i_begin_row             = 2
          i_end_col               = 21
          i_end_row               = 60000
        TABLES
          intern                  = t_excel
        EXCEPTIONS
          inconsistent_parameters = 1
          upload_ole              = 2
          OTHERS                  = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      SORT t_excel BY row col value.
      LOOP AT t_excel.
        IF t_excel-col = '0011' OR t_excel-col = '0012' OR
           t_excel-col = '0013' OR t_excel-col = '0014' OR
           t_excel-col = '0015' OR t_excel-col = '0016' OR
           t_excel-col = '0017' OR t_excel-col = '0018' OR
           t_excel-col = '0019' OR t_excel-col = '0020'.
          CLEAR l_value.
          REPLACE '.' WITH ' ' INTO t_excel-value.
          REPLACE '.' WITH ' ' INTO t_excel-value.
          REPLACE '.' WITH ' ' INTO t_excel-value.
          REPLACE '.' WITH ' ' INTO t_excel-value.
          CONDENSE t_excel-value NO-GAPS.
          CALL FUNCTION 'ISM_CONVERT_CHAR_TO_DEC'
            EXPORTING
              i_char = t_excel-value
            IMPORTING
              e_dec  = l_value
            EXCEPTIONS
              error  = 1
              OTHERS = 2.
        ENDIF.

        CASE t_excel-col.
          WHEN '0001'.
            MOVE t_excel-value TO t_upload-gjahr.
          WHEN '0002'.
            MOVE t_excel-value TO t_upload-zsmst.
          WHEN '0003'.
            MOVE t_excel-value TO t_upload-vkorg.
          WHEN '0004'.
            MOVE t_excel-value TO t_upload-vkbur.
          WHEN '0005'.
            MOVE t_excel-value TO t_upload-kkber.
          WHEN '0006'.
            MOVE t_excel-value TO t_upload-kdgrp.
          WHEN '0007'.
            MOVE t_excel-value TO t_upload-kvgr3.
          WHEN '0008'.
            CONCATENATE '0' t_excel-value INTO t_upload-knkli.
          WHEN '0009'.
            MOVE t_excel-value TO t_upload-sortl.
          WHEN '0010'.
            MOVE t_excel-value TO t_upload-name1.
          WHEN '0011'.
            t_upload-slsm1 = l_value / 100.
          WHEN '0012'.
            t_upload-slsm2 = l_value / 100.
          WHEN '0013'.
            t_upload-slsm3 = l_value / 100.
          WHEN '0014'.
            t_upload-slsm4 = l_value / 100.
          WHEN '0015'.
            t_upload-slsm5 = l_value / 100.
          WHEN '0016'.
            t_upload-slsm6 = l_value / 100.
          WHEN '0017'.
            t_upload-hist = l_value / 100.
          WHEN '0018'.
            t_upload-klimk = l_value / 100.
          WHEN '0019'.
            t_upload-klimk_hit = l_value / 100.
          WHEN '0020'.
            t_upload-klimk_usl = l_value / 100.
          WHEN '0021'.
            MOVE t_excel-value TO t_upload-message.
        ENDCASE.
        AT END OF row.
          APPEND t_upload. CLEAR t_upload.
        ENDAT.
      ENDLOOP.

* Get Detail
      IF t_upload[] IS NOT INITIAL.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE t_itab
          FROM zscl_sm
          FOR ALL ENTRIES IN t_upload
          WHERE gjahr = t_upload-gjahr  AND
                zsmst = t_upload-zsmst  AND
                vkorg = t_upload-vkorg  AND
                vkbur = t_upload-vkbur  AND
                kkber = t_upload-kkber  AND
                kdgrp = t_upload-kdgrp  AND
                kvgr3 = t_upload-kvgr3  AND
                knkli = t_upload-knkli  AND
                status = 'D'            AND
                filename = ld_filename1.
        IF sy-subrc NE 0.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE t_itab
            FROM zscl_sm
            FOR ALL ENTRIES IN t_upload
            WHERE gjahr = t_upload-gjahr  AND
                  zsmst = t_upload-zsmst  AND
                  vkorg = t_upload-vkorg  AND
                  vkbur = t_upload-vkbur  AND
                  kkber = t_upload-kkber  AND
                  kdgrp = t_upload-kdgrp  AND
                  kvgr3 = t_upload-kvgr3  AND
                  knkli = t_upload-knkli  AND
                  status = 'D'            AND
                  fileerror = ld_filename1.
        ENDIF.
      ENDIF.

* get Bank Garansi
      IF t_itab[] IS NOT INITIAL.
        t_kdgrp[] = t_itab[].
        t_knkli[] = t_itab[].
        SORT t_kdgrp BY kdgrp.
        SORT t_knkli BY knkli.
        DELETE ADJACENT DUPLICATES FROM t_kdgrp COMPARING kdgrp.
        DELETE t_kdgrp WHERE kdgrp EQ space.
        DELETE ADJACENT DUPLICATES FROM t_knkli COMPARING knkli.

        IF t_knkli[] IS NOT INITIAL.
          SELECT *
            FROM zsbankgrs
            INTO CORRESPONDING FIELDS OF TABLE t_zsbankgrs_kdgrp
            FOR ALL ENTRIES IN t_kdgrp
            WHERE kdgrp EQ t_kdgrp-kdgrp.
          SELECT *
            FROM zsbankgrs
            INTO CORRESPONDING FIELDS OF TABLE t_zsbankgrs_knkli
            FOR ALL ENTRIES IN t_knkli
            WHERE kunnr EQ t_knkli-knkli.
        ENDIF.
      ENDIF.

      SORT t_itab BY knkli.
      SORT t_upload BY knkli.

    WHEN p_uplkp.
* Check nama file
      CALL FUNCTION 'CRM_IC_WZ_SPLIT_FILE_EXTENSION'
        EXPORTING
          iv_filename_with_ext = work_di2
        IMPORTING
          ev_filename          = ld_filename
          ev_extension         = ld_extension.
      IF sy-subrc = 0.
        WRITE ld_filename TO ld_filename1 RIGHT-JUSTIFIED.
        WRITE ld_extension TO ld_filename2.
      ENDIF.

      CASE ld_extension.
        WHEN 'XLS' OR 'xls' OR 'XLSX' OR 'xlsx'.
          PERFORM f_upload_xls TABLES t_uplkp
                               USING  work_di2.

        WHEN 'CSV' OR 'csv' OR 'TXT' OR 'txt'.
          PERFORM f_upload_csv TABLES t_uplkp
                               USING  work_di2.
      ENDCASE.

* Upload from excel

* Get Detail
      IF t_uplkp[] IS NOT INITIAL.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE t_itab
          FROM zscl_sm
          FOR ALL ENTRIES IN t_uplkp
          WHERE gjahr = t_uplkp-gjahr  AND
                zsmst = t_uplkp-zsmst  AND
                vkorg = pa_vkorg       AND
                vkbur = pa_vkbur       AND
                kkber IN so_kkber      AND
*                kdgrp = t_uplkp-kdgrp  AND
*                kvgr3 = t_uplkp-kvgr3  AND
                knkli = t_uplkp-knkli  AND
                status IN (' ','D', 'U', 'H', 'P').
      ENDIF.

      IF t_uplkp[] IS NOT INITIAL.
        lt_uplkp[] = t_uplkp[].
        SORT lt_uplkp BY knkli.
        DELETE ADJACENT DUPLICATES FROM lt_uplkp COMPARING knkli.

* Get Customer
        SELECT kunnr sortl name1 aufsd vtext
        INTO CORRESPONDING FIELDS OF TABLE t_kna1
        FROM kna1 AS a LEFT OUTER JOIN tvast AS b ON b~spras = sy-langu AND
                                                b~aufsp = a~aufsd
        FOR ALL ENTRIES IN lt_uplkp
        WHERE kunnr = lt_uplkp-knkli.

* Get Bank Garansi
        SELECT *
          FROM zsbankgrs
          INTO CORRESPONDING FIELDS OF TABLE t_zsbankgrs_knkli
          FOR ALL ENTRIES IN lt_uplkp
          WHERE kunnr EQ lt_uplkp-knkli.
      ENDIF.

      SORT t_kna1 BY kunnr.
      SORT t_zsbankgrs_knkli BY kunnr.
      SORT t_uplkp BY knkli.

  ENDCASE.

ENDFORM.                    "f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.

  DATA: l_date TYPE i,
        l_sw1(1),l_sw2(1),l_sw3(1),l_sw4(1),l_sw5(1),l_sw6(1),
        l_klimk_maks LIKE knkk-klimk.

  DATA: ld_klimk_hit  LIKE zscl_sm-klimk_hit,
        ld_klimk      LIKE zscl_sm-klimk_hit,
        ld_found      TYPE i,
        ld_tklimk_hit LIKE zscl_sm-klimk_hit.

  CASE 'X'.
*-- Download
    WHEN p_down.
      LOOP AT t_itab.
        CLEAR: t_kna1.
* Baca Cust Name
        READ TABLE t_kna1 WITH KEY kunnr = t_itab-knkli BINARY SEARCH.
        t_itab-name1 = t_kna1-name1.
        IF t_kna1-aufsd IS NOT INITIAL.
          t_itab-vtext = t_kna1-vtext.
        ENDIF.

*----------- Validasi untuk bank garansi.
        LOOP AT t_zsbankgrs_knkli WHERE kunnr EQ t_itab-knkli.
          IF t_zsbankgrs_knkli-valid_to GE sy-datum AND t_zsbankgrs_knkli-valid_fr LE sy-datum.
            ld_found  = 1.
            ADD t_zsbankgrs_knkli-wrbtr TO ld_klimk_hit.
          ENDIF.
        ENDLOOP.

        IF ld_found EQ 1.
          IF ld_klimk_hit IS INITIAL.
            sy-subrc  = 4.
          ELSE.
            sy-subrc  = 0.
          ENDIF.
        ELSE.
          sy-subrc  = 4.
        ENDIF.

        IF sy-subrc EQ 0.
          IF t_itab-klimk_hit GT ld_klimk_hit.
            t_itab-klimk_hit = ld_klimk_hit.
            t_itab-klimk_usl = ld_klimk_hit.
          ENDIF.
        ELSE.
          LOOP AT t_zsbankgrs_kdgrp WHERE kdgrp EQ t_itab-kdgrp.
            IF t_zsbankgrs_kdgrp-valid_to GE sy-datum AND t_zsbankgrs_kdgrp-valid_fr LE sy-datum.
              ld_found  = 1.
              ADD t_zsbankgrs_kdgrp-wrbtr TO ld_klimk_hit.
            ENDIF.
          ENDLOOP.

          IF ld_found EQ 1.
            IF ld_klimk_hit IS INITIAL.
              sy-subrc  = 4.
            ELSE.
              sy-subrc  = 0.
            ENDIF.
          ELSE.
            sy-subrc  = 4.
          ENDIF.

          IF sy-subrc EQ 0.
            IF t_itab-klimk_hit GT ld_klimk_hit.
              t_itab-klimk_hit = ld_klimk_hit.
              t_itab-klimk_usl = ld_klimk_hit.
            ENDIF.
          ENDIF.
        ENDIF.
*-----------

        MODIFY t_itab TRANSPORTING name1 vtext klimk_hit klimk_usl. CLEAR t_itab.
        CLEAR: ld_found, ld_klimk_hit, ld_tklimk_hit.
      ENDLOOP.

*-- Upload
    WHEN p_uplod.
      IF i_zscl_kredit[] IS INITIAL.
        SELECT * INTO TABLE i_zscl_kredit FROM zscl_kredit.
      ENDIF.
      LOOP AT t_itab.
        CLEAR: t_upload.
* Baca Cust Name
        READ TABLE t_upload WITH KEY knkli = t_itab-knkli BINARY SEARCH.
        t_itab-name1 = t_upload-name1.

        t_itab-reason = t_upload-message.
        t_itab-klimk_usl = t_upload-klimk_usl.

*----------- Validasi untuk bank garansi.
        LOOP AT t_zsbankgrs_knkli WHERE kunnr EQ t_itab-knkli.
          IF t_zsbankgrs_knkli-valid_to GE sy-datum AND t_zsbankgrs_knkli-valid_fr LE sy-datum.
            ld_found  = 1.
            ADD t_zsbankgrs_knkli-wrbtr TO ld_klimk_hit.
          ENDIF.
        ENDLOOP.

        IF ld_found EQ 1.
          IF ld_klimk_hit IS INITIAL.
            sy-subrc  = 4.
          ELSE.
            sy-subrc  = 0.
          ENDIF.
        ELSE.
          sy-subrc  = 4.
        ENDIF.

        IF sy-subrc EQ 0.
          IF t_upload-klimk_usl GT ld_klimk_hit.
            t_itab-klimk_usl = ld_klimk_hit.
          ELSE.
            t_itab-klimk_usl = t_upload-klimk_usl.
          ENDIF.
        ELSE.
          LOOP AT t_zsbankgrs_kdgrp WHERE kdgrp EQ t_itab-kdgrp.
            IF t_zsbankgrs_kdgrp-valid_to GE sy-datum AND t_zsbankgrs_kdgrp-valid_fr LE sy-datum.
              ld_found  = 1.
              ADD t_zsbankgrs_kdgrp-wrbtr TO ld_klimk_hit.
            ENDIF.
          ENDLOOP.

          IF ld_found EQ 1.
            IF ld_klimk_hit IS INITIAL.
              sy-subrc  = 4.
            ELSE.
              sy-subrc  = 0.
            ENDIF.
          ELSE.
            sy-subrc  = 4.
          ENDIF.

          IF sy-subrc EQ 0.
            IF t_upload-klimk_usl GT ld_klimk_hit.
              t_itab-klimk_usl = ld_klimk_hit.
            ELSE.
              t_itab-klimk_usl = t_upload-klimk_usl.
            ENDIF.
          ENDIF.
        ENDIF.
*-----------

        IF t_itab-klimk_usl IS NOT INITIAL.
          t_itab-klimk_usl% = ( t_itab-klimk_usl - t_itab-klimk_hit ) / t_itab-klimk_hit * 100.
        ENDIF.

        CLEAR ld_klimk.
        ld_klimk = t_itab-klimk_usl - t_itab-klimk_hit.

        IF ld_klimk GT 0.
          PERFORM f_hitung_otorisasi_user IN PROGRAM zs_cl_quartal_usulan
*                                        USING t_itab-klimk_usl
                                          USING ld_klimk
                                                t_itab-klimk_usl%
                                                t_itab-vkbur
                                          CHANGING t_itab-zgol
                                                   t_itab-usergroup1
                                                   t_itab-usergroup2
                                                   t_itab-usergroup3.
        ELSE.
*        CLEAR t_itab-status.
          SORT i_zscl_kredit BY zrange.
          CLEAR i_zscl_kredit.
          READ TABLE i_zscl_kredit INDEX 1.
          IF i_zscl_kredit-usrgroup2 IS INITIAL.
            t_itab-zgol = t_itab-usergroup1 = i_zscl_kredit-usrgroup.
            CLEAR: t_itab-usergroup2,t_itab-usergroup3.
          ELSEIF i_zscl_kredit-usrgroup3 IS NOT INITIAL.
            CONCATENATE i_zscl_kredit-usrgroup i_zscl_kredit-usrgroup2
              i_zscl_kredit-usrgroup3 INTO t_itab-zgol SEPARATED BY '&'.
            t_itab-usergroup1 = i_zscl_kredit-usrgroup.
            t_itab-usergroup2 = i_zscl_kredit-usrgroup2.
            t_itab-usergroup3 = i_zscl_kredit-usrgroup3.
          ELSE.
            CONCATENATE i_zscl_kredit-usrgroup i_zscl_kredit-usrgroup2
                   INTO t_itab-zgol SEPARATED BY '&'.
            t_itab-usergroup1 = i_zscl_kredit-usrgroup.
            t_itab-usergroup2 = i_zscl_kredit-usrgroup2.
            CLEAR: t_itab-usergroup3.
          ENDIF.
        ENDIF.

        IF t_itab-klimk_hit = t_itab-klimk_usl AND
           t_itab-klimk_hit = t_itab-klimk_kp.
          CLEAR t_itab-zgol.
        ENDIF.

        MODIFY t_itab TRANSPORTING name1 klimk_hit klimk_usl klimk_usl% reason status
                                   usergroup username zgol usergroup1 usergroup2 zgol.
        CLEAR t_itab.
        CLEAR: ld_found, ld_klimk_hit, ld_tklimk_hit.
      ENDLOOP.

*-- Upload KP
    WHEN p_uplkp.
      IF i_zscl_kredit[] IS INITIAL.
        SELECT * INTO TABLE i_zscl_kredit FROM zscl_kredit.
      ENDIF.
      LOOP AT t_itab.
        CLEAR: t_kna1,t_uplkp.

        READ TABLE t_kna1 WITH KEY kunnr = t_itab-knkli BINARY SEARCH.
        READ TABLE t_uplkp WITH KEY knkli = t_itab-knkli BINARY SEARCH.

        t_itab-name1 = t_kna1-name1.
        t_itab-klimk_kp = t_uplkp-klimk_usl.

*----------- Validasi untuk bank garansi.
        LOOP AT t_zsbankgrs_knkli WHERE kunnr EQ t_itab-knkli.
          IF t_zsbankgrs_knkli-valid_to GE sy-datum AND t_zsbankgrs_knkli-valid_fr LE sy-datum.
            ld_found  = 1.
            ADD t_zsbankgrs_knkli-wrbtr TO ld_klimk_hit.
          ENDIF.
        ENDLOOP.

        IF ld_found EQ 1.
          IF ld_klimk_hit IS INITIAL.
            sy-subrc  = 4.
          ELSE.
            sy-subrc  = 0.
          ENDIF.
        ELSE.
          sy-subrc  = 4.
        ENDIF.

        IF sy-subrc EQ 0.
          IF t_itab-klimk_kp GT ld_klimk_hit.
            t_itab-klimk_hit = ld_klimk_hit.
            t_itab-klimk_kp = ld_klimk_hit.
          ENDIF.
        ENDIF.
*-----------

        IF t_itab-klimk_usl IS NOT INITIAL.
          t_itab-klimk_usl% = ( t_itab-klimk_usl - t_itab-klimk_hit ) / t_itab-klimk_hit * 100.
        ENDIF.

        IF t_itab-klimk_kp IS NOT INITIAL.
          t_itab-klimk_kp% = ( t_itab-klimk_kp - t_itab-klimk_hit ) / t_itab-klimk_hit * 100.
        ENDIF.

        CLEAR ld_klimk.
        ld_klimk = t_itab-klimk_kp - t_itab-klimk_hit.

        IF ld_klimk GT 0.
          PERFORM f_hitung_otorisasi_user IN PROGRAM zs_cl_quartal_usulan
*                                        USING t_itab-klimk_kp
                                          USING ld_klimk
                                                t_itab-klimk_kp%
                                                t_itab-vkbur
                                          CHANGING t_itab-zgol
                                                   t_itab-usergroup1
                                                   t_itab-usergroup2
                                                   t_itab-usergroup3.
        ELSE.
*        CLEAR t_itab-status.
          SORT i_zscl_kredit BY zrange.
          CLEAR i_zscl_kredit.
          READ TABLE i_zscl_kredit INDEX 1.
          IF i_zscl_kredit-usrgroup2 IS INITIAL.
            t_itab-zgol = t_itab-usergroup1 = i_zscl_kredit-usrgroup.
            CLEAR: t_itab-usergroup2,t_itab-usergroup3.
          ELSEIF i_zscl_kredit-usrgroup3 IS NOT INITIAL.
            CONCATENATE i_zscl_kredit-usrgroup i_zscl_kredit-usrgroup2
              i_zscl_kredit-usrgroup3 INTO t_itab-zgol SEPARATED BY '&'.
            t_itab-usergroup1 = i_zscl_kredit-usrgroup.
            t_itab-usergroup2 = i_zscl_kredit-usrgroup2.
            t_itab-usergroup3 = i_zscl_kredit-usrgroup3.
          ELSE.
            CONCATENATE i_zscl_kredit-usrgroup i_zscl_kredit-usrgroup2
                   INTO t_itab-zgol SEPARATED BY '&'.
            t_itab-usergroup1 = i_zscl_kredit-usrgroup.
            t_itab-usergroup2 = i_zscl_kredit-usrgroup2.
            CLEAR: t_itab-usergroup3.
          ENDIF.
        ENDIF.

*        IF t_itab-klimk_hit = t_itab-klimk_usl AND
*           t_itab-klimk_hit = t_itab-klimk_kp.
        IF t_itab-klimk_hit GE t_itab-klimk_kp.
          CLEAR t_itab-zgol.
        ENDIF.

        MODIFY t_itab TRANSPORTING name1 klimk_hit klimk_usl% klimk_kp klimk_kp% reason
                                   usergroup username zgol usergroup1 usergroup2 zgol.
        CLEAR t_itab.
        CLEAR: ld_found, ld_klimk_hit, ld_tklimk_hit.
      ENDLOOP.
  ENDCASE.

ENDFORM.                    " f_process_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  IF p_down = 'X'.
    PERFORM f_download .
  ELSE.
    IF ok_code = '&CONF'.
      PERFORM f_alv TABLES t_itab_conf.
    ELSE.
      PERFORM f_alv TABLES t_itab.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_print_data

*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
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
      is_print                 = d_print
    TABLES
      t_outtab                 = ft_report
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    "f_alv

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
*    'VKBUR' 'S603' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' 'X',
    'KNKLI' 'ZSCL_SM' 'KNKLI' '' '' '' '' '' '' '' '' '' '' '' '' 'X',
    'SORTL' 'KNA1' 'SORTL' '' '' '' '' '' '' '' '' '' '' '' '' 'X',
    'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' 'X',
    'KDGRP' 'S603' 'KDGRP' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KVGR3' 'S603' 'KVGR3' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SLSM1' '' '' 'X' '17' 'SLSM M1' '' '' '' '' '' 'WAERS' '' '' '' '',
    'SLSM2' '' '' 'X' '17' 'SLSM M2' '' '' '' '' '' 'WAERS' '' '' '' '',
    'SLSM3' '' '' 'X' '17' 'SLSM M3' '' '' '' '' '' 'WAERS' '' '' '' '',
    'SLSM4' '' '' 'X' '17' 'SLSM M4' '' '' '' '' '' 'WAERS' '' '' '' '',
    'SLSM5' '' '' 'X' '17' 'SLSM M5' '' '' '' '' '' 'WAERS' '' '' '' '',
    'SLSM6' '' '' 'X' '17' 'SLSM M6' '' '' '' '' '' 'WAERS' '' '' '' '',
    'TOTAL6' '' '' 'X' '17' 'Total 6bl' '' '' '' '' '' 'WAERS' '' '' '' '',
    'TOTAL3' '' '' 'X' '17' 'Total 3bl' '' '' '' '' '' 'WAERS' '' '' '' '',
    'COUNT6' '' '' 'X' '6' 'Count6bl' '' '' '' '' '' '' '' '' '' '',
    'COUNT3' '' '' 'X' '6' 'Count3bl' '' '' '' '' '' '' '' '' '' '',
    'AVRG6' '' '' 'X' '17' 'Average 6bl' '' '' '' '' '' 'WAERS' '' '' '' '',
    'AVRG3' '' '' 'X' '17' 'Average 3bl' '' '' '' '' '' 'WAERS' '' '' '' '',
    'MAXVAL' '' '' 'X' '17' 'Max Value' '' '' '' '' '' 'WAERS' '' '' '' '',
    'HIST' '' '' 'X' '17' 'History' '' '' '' '' '' 'WAERS' '' '' '' '',
    'KLIMK' '' '' '' '17' 'Current CL' '' '' '' '' '' 'WAERS' '' '' '' '',
    'GRO' '' '' 'X' '7' 'Growth' '' '' '' '' '' '' '' '' '' '',
    'TOP' '' '' 'X' '7' 'TOP' '' '' '' '' '' '' '' '' '' '',
    'KLIMK_HIT' '' '' '' '17' 'New CL' '' '' '' '' '' 'WAERS' '' '' '' '',
    'KLIMK_USL' '' '' '' '17' 'Usul CL' '' '' '' '' '' 'WAERS' '' '' '' '',
    'KLIMK_USL%' '' '' '' '10' 'Usul CL %' '' '' '' '' '' '' '' '' '' ''.

  IF p_uplkp IS NOT INITIAL.
    PERFORM f_fieldcatg USING ft_report:
      'KLIMK_KP' '' '' '' '17' 'Usul KP' '' '' '' '' '' 'WAERS' '' '' '' '',
      'KLIMK_KP%' '' '' '' '10' 'Usul KP %' '' '' '' '' '' '' '' '' '' ''.
  ENDIF.

  PERFORM f_fieldcatg USING ft_report:
    'ZGOL' '' '' '' '10' 'Golongan' '' '' '' '' '' '' '' '' '' '',
    'USERGROUP' '' '' '' '10' 'User Group' '' '' '' '' '' '' '' '' '' '',
    'USERNAME' '' '' '' '20' 'User Name' '' '' '' '' '' '' '' '' '' '',
    'REASON' '' '' '' '30' 'Reason' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM f_fieldcats                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_FNAME                                                      *
*  -->  FU_OUTLEN                                                     *
*  -->  FU_NOSIGN                                                     *
*  -->  FU_NOOUT                                                      *
*  -->  FU_TEXT                                                       *
*  -->  FU_REFTB                                                      *
*  -->  FU_REFFNAME                                                   *
*  -->  FU_DECIMALS                                                   *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    value(fu_types)
                          value(fu_fname)
                          value(fu_reftb)
                          value(fu_refld)
                          value(fu_noout)
                          value(fu_outln)
                          value(fu_fltxt)
                          value(fu_dosum)
                          value(fu_hotsp)
                          value(fu_dec)
                          value(fu_waers)
                          value(fu_meins)
                          value(fu_waers_f)
                          value(fu_meins_f)
                          value(fu_checkbox)
                          value(fu_input)
                          value(fu_key).

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
  ld_fieldcat-key               = fu_key.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM f_build_event                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_EVENTS                                                     *
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.                    "f_build_event

*---------------------------------------------------------------------*
*       FORM f_build_event_exit                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
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
ENDFORM.                    "f_build_event_exit

*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
  IF ( p_uplod = 'X' OR p_uplkp = 'X' ) AND ok_code NE '&CONF'.
    fu_layout-box_fieldname      = 'CHECK'.
  ENDIF.
ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "f_build_print

*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'VKBUR'.
  ld_sort-up        = 'X'.
  ld_sort-group     = '*'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'KNKLI'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

  DATA: l_period(40),
        l_spmon1(7),
        l_vkbur(40).

  CONCATENATE 'Period:' pa_gjahr '/' pa_zsmst INTO l_period SEPARATED BY space.

  SELECT SINGLE bezei INTO l_vkbur FROM tvkbt
    WHERE spras = sy-langu     AND
          vkbur = t_itab-vkbur.
  CONCATENATE 'SlOff:' t_itab-vkbur l_vkbur INTO l_vkbur SEPARATED BY space.

  PERFORM f_hdr_uline.
  IF p_down = 'X'.
    PERFORM f_hdr_line1 USING 'Download CL Semester'.
  ELSE.
    IF ok_code = '&CONF'.
      PERFORM f_hdr_line1 USING 'Confirm Upload Usulan CL Semester'.
    ELSE.
      PERFORM f_hdr_line1 USING 'Upload CL Semester'.
    ENDIF.
  ENDIF.
  PERFORM f_hdr_line2 USING l_period.
  PERFORM f_hdr_line3 USING l_vkbur.
  PERFORM f_hdr_uline.

ENDFORM.                    "f_top_of_page

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.
* here free all the internal table used in the program.
  REFRESH: t_itab,t_kna1.
  CLEAR: t_itab,t_kna1.
ENDFORM.                    " F_FREE_MEMORY
*&---------------------------------------------------------------------*
*&      Form  f_clear_alv_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
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
ENDFORM.                    " f_clear_alv_data

*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  IF p_down = 'X'.
    SET PF-STATUS 'DOWNLOAD'.
  ELSE.
    SET PF-STATUS 'STANDARD'.
  ENDIF.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_gui_message                                            *
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "f_gui_message

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.
  CLEAR ok_code.
  ok_code = fu_ucomm.

  CASE fu_ucomm.
    WHEN '&IC1'.
      PERFORM f_usulan USING fu_selfield.
    WHEN '&SAV'.
      PERFORM f_post_entries.
    WHEN '&CONF'.
      PERFORM f_confirm.
    WHEN '&DOWN'.
      PERFORM f_download.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDFORM.                    "f_user_command

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
*&      Form  f_download
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download .

  DATA: ld_window_title TYPE string,
        ld_default_exte TYPE string,
        ld_filefilter   TYPE string,
        ld_fullpath     TYPE string,
        ld_filename     TYPE string,
        ld_filetype(10),
        ld_user_action  TYPE i,
        ld_filename1(100),
        ld_filename2(10),
        count TYPE i,
        ld_clno LIKE zscl_ctr-clno,
        ld_filenameu LIKE zscl_file-filename,
        lw_zscl_ctr LIKE zscl_ctr,
        lw_zscl_file LIKE zscl_file.

  DATA: lwa_dwn_field LIKE t_dwn_field.
  DATA: BEGIN OF lt_dd03l OCCURS 0,
          tabname     TYPE tabname,
          fieldname   TYPE fieldname,
          as4local    TYPE as4local,
          as4vers     TYPE as4vers,
          position    TYPE tabfdpos,
        END OF lt_dd03l.

  CHECK t_itab[] IS NOT INITIAL.

  SELECT MAX( clno ) INTO ld_clno
    FROM zscl_ctr
    WHERE vkbur = pa_vkbur.

  lw_zscl_ctr-vkbur = pa_vkbur.
  lw_zscl_ctr-clno = ld_clno + 1.
  lw_zscl_ctr-udate = sy-datum.
  lw_zscl_ctr-utime = sy-uzeit.

  CONCATENATE pa_vkbur lw_zscl_ctr-clno INTO ld_filenameu SEPARATED BY '_'.
  ld_filename = ld_filenameu.

  lw_zscl_file-filename = ld_filenameu.
  lw_zscl_file-username = sy-uname.
  lw_zscl_file-udate = sy-datum.
  lw_zscl_file-utime = sy-uzeit.

* Append itab download
  CLEAR t_download.
  REFRESH t_download.
  LOOP AT t_itab.
* Header line
*    AT FIRST.
*      t_download-gjahr = 'Year'.
*      t_download-zsmst = 'Smt'.
*      t_download-vkorg = 'SlOrg'.
*      t_download-vkbur = 'SlOff'.
*      t_download-kkber = 'CrCont'.
*      t_download-kdgrp = 'CustGrp'.
*      t_download-kvgr3 = 'CustSGrp'.
*      t_download-knkli = 'CustSAP'.
*      t_download-sortl = 'CustLGC'.
*      t_download-name1 = 'CustName'.
*      t_download-vtext = 'Cust N/A'.
*      WRITE: 'Sales M1' TO t_download-slsm1 RIGHT-JUSTIFIED,
*             'Sales M2' TO t_download-slsm2 RIGHT-JUSTIFIED,
*             'Sales M3' TO t_download-slsm3 RIGHT-JUSTIFIED,
*             'Sales M4' TO t_download-slsm4 RIGHT-JUSTIFIED,
*             'Sales M5' TO t_download-slsm5 RIGHT-JUSTIFIED,
*             'Sales M6' TO t_download-slsm6 RIGHT-JUSTIFIED,
*             'History' TO t_download-hist RIGHT-JUSTIFIED,
*             'CLCurrent' TO t_download-klimk RIGHT-JUSTIFIED,
*             'CRHitung' TO t_download-klimk_hit RIGHT-JUSTIFIED,
*             'CLUsulan' TO t_download-klimk_usl RIGHT-JUSTIFIED.
*      APPEND t_download. CLEAR t_download.
*    ENDAT.

* Detail line
    WRITE: t_itab-gjahr TO t_download-gjahr,
           t_itab-zsmst TO t_download-zsmst,
           t_itab-vkorg TO t_download-vkorg,
           t_itab-vkbur TO t_download-vkbur,
           t_itab-kkber TO t_download-kkber,
           t_itab-kdgrp TO t_download-kdgrp,
           t_itab-kvgr3 TO t_download-kvgr3,
           t_itab-knkli TO t_download-knkli,
           t_itab-sortl TO t_download-sortl,
           t_itab-name1 TO t_download-name1,
           t_itab-vtext TO t_download-vtext,
           t_itab-slsm1 TO t_download-slsm1 CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab-slsm2 TO t_download-slsm2 CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab-slsm3 TO t_download-slsm3 CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab-slsm4 TO t_download-slsm4 CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab-slsm5 TO t_download-slsm5 CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab-slsm6 TO t_download-slsm6 CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab-hist TO t_download-hist CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab-klimk TO t_download-klimk CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab-klimk_hit TO t_download-klimk_hit CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab-klimk_usl TO t_download-klimk_usl CURRENCY 'IDR' RIGHT-JUSTIFIED.
    APPEND t_download. CLEAR t_download.

* Update flag status
    t_itab-udate = sy-datum.
    t_itab-utime = sy-uzeit.
    t_itab-status = 'D'.
    t_itab-filename = ld_filenameu.
    MODIFY t_itab TRANSPORTING udate utime status filename.
  ENDLOOP.

* POPUP download dialog
  ld_window_title = 'Download CL semester'.
*  ld_default_exte = 'XLS'.
  ld_default_exte = 'XLS'.
  CALL FUNCTION 'GUI_FILE_SAVE_DIALOG'
    EXPORTING
      window_title      = ld_window_title
      default_file_name = ld_filename
      default_extension = ld_default_exte
      file_filter       = ld_filefilter
    IMPORTING
      fullpath          = ld_fullpath
      user_action       = ld_user_action
      filename          = ld_filename.

*  SPLIT ld_filename AT '.' INTO: ld_filename1 ld_filename2.
*  CASE ld_filename2.
*    WHEN 'XLS' OR 'xls'.
*      ld_filetype = 'WK1'.
*    WHEN 'TXT' OR 'txt'.
*      ld_filetype = 'ASC'.
*    WHEN 'DAT' OR 'dat'.
*      ld_filetype = 'DAT'.
*    WHEN 'DBF' OR 'dbf'.
*      ld_filetype = 'DBF'.
*  ENDCASE.

*  IF ld_filetype = 'DBF'.
*    DELETE t_download INDEX 1.
* Append itab download
  CLEAR t_dwn_field.
  REFRESH t_dwn_field.
*  DO 22 TIMES.
*    ADD 1 TO count.
*    CASE count.
*      WHEN '1'.
*        t_dwn_field-txt_field = 'Year'.
*      WHEN '2'.
*        t_dwn_field-txt_field = 'Smt'.
*      WHEN '3'.
*        t_dwn_field-txt_field = 'SlOrg'.
*      WHEN '4'.
*        t_dwn_field-txt_field = 'SlOff'.
*      WHEN '5'.
*        t_dwn_field-txt_field = 'CrCont'.
*      WHEN '6'.
*        t_dwn_field-txt_field = 'CustGrp'.
*      WHEN '7'.
*        t_dwn_field-txt_field = 'CustSGrp'.
*      WHEN '8'.
*        t_dwn_field-txt_field = 'CustSAP'.
*      WHEN '9'.
*        t_dwn_field-txt_field = 'CustLGC'.
*      WHEN '10'.
*        t_dwn_field-txt_field = 'CustName'.
*      WHEN '11'.
*        t_dwn_field-txt_field = 'Sales M1'.
*      WHEN '12'.
*        t_dwn_field-txt_field = 'Sales M2'.
*      WHEN '13'.
*        t_dwn_field-txt_field = 'Sales M3'.
*      WHEN '14'.
*        t_dwn_field-txt_field = 'Sales M4'.
*      WHEN '15'.
*        t_dwn_field-txt_field = 'Sales M5'.
*      WHEN '16'.
*        t_dwn_field-txt_field = 'Sales M6'.
*      WHEN '17'.
*        t_dwn_field-txt_field = 'History'.
*      WHEN '18'.
*        t_dwn_field-txt_field = 'CLCurrent'.
*      WHEN '19'.
*        t_dwn_field-txt_field = 'CLHitung'.
*      WHEN '20'.
*        t_dwn_field-txt_field = 'CLUsulan'.
*      WHEN '21'.
*        t_dwn_field-txt_field = 'Message'.
*      WHEN '22'.
*        t_dwn_field-txt_field = 'Cust N/A'.
*    ENDCASE.
*    APPEND t_dwn_field. CLEAR t_dwn_field.
*  ENDDO.
*  ENDIF.

*-- Create download field name
  SELECT tabname fieldname as4local as4vers position
    FROM dd03l
    INTO TABLE lt_dd03l
    WHERE tabname   EQ c_struc_down.

  SORT lt_dd03l BY position.
  LOOP AT lt_dd03l.
    lwa_dwn_field-txt_field = lt_dd03l-fieldname.
    APPEND lwa_dwn_field TO t_dwn_field.
  ENDLOOP.

* Download to local
*  ld_filetype = 'WK1'.
  ld_filetype = 'DBF'.
  IF ld_user_action = 1 OR ld_user_action = 0.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename              = ld_fullpath
        filetype              = ld_filetype
        write_field_separator = 'X'
      TABLES
        data_tab              = t_download
        fieldnames            = t_dwn_field
      EXCEPTIONS
        file_write_error      = 01
        no_batch              = 04
        unknown_error         = 05
        OTHERS                = 99.

    CASE sy-subrc.
      WHEN 0.
* Update table
        MODIFY zscl_sm FROM TABLE t_itab.
        MODIFY zscl_ctr FROM lw_zscl_ctr.
        MODIFY zscl_file FROM lw_zscl_file.
        CLEAR t_itab_err. REFRESH t_itab_err.

      WHEN OTHERS.
        MESSAGE 'Download error' TYPE 'I'.
    ENDCASE.
*    REFRESH t_itab.
  ELSEIF ld_user_action = 2.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        append                = 'X'
        filename              = ld_fullpath
        filetype              = ld_filetype
        trunc_trailing_blanks = 'X'
      TABLES
        data_tab              = t_download
        fieldnames            = t_dwn_field
      EXCEPTIONS
        invalid_type          = 03
        no_batch              = 04
        unknown_error         = 05
        OTHERS                = 99.
    CASE sy-subrc.
      WHEN 0.
* Update table
        MODIFY zscl_sm FROM TABLE t_itab.
        MODIFY zscl_ctr FROM lw_zscl_ctr.
        MODIFY zscl_file FROM lw_zscl_file.
        CLEAR t_itab_err. REFRESH t_itab_err.

      WHEN OTHERS.
        MESSAGE 'Download error' TYPE 'I'.
    ENDCASE.
  ENDIF.

ENDFORM.                    " f_download

*&---------------------------------------------------------------------*
*&      Form  f_cek_vkbur
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cek_vkbur .
  DATA: ld_live  LIKE zplbc-live,
        ld_werks LIKE tvkol-werks,
        ld_lgort LIKE tvkol-lgort.

  SELECT SINGLE werks lgort
    INTO (ld_werks, ld_lgort)
    FROM tvkol
    WHERE vstel = pa_vkbur.
  IF sy-subrc = 0.
    IF p_uplkp IS INITIAL.
      SELECT SINGLE live
        INTO ld_live
        FROM zplbc
        WHERE bukrs = pa_vkorg AND
              werks = ld_werks AND
              lgort = ld_lgort AND
              live  = space.
      IF sy-subrc NE 0.
        MESSAGE 'Bukan cabang legacy' TYPE 'E'.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE 'Cabang belum ada' TYPE 'E'.
  ENDIF.
ENDFORM.                    " f_cek_vkbur

*&---------------------------------------------------------------------*
*&      Form  f_download_err
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download_err.

  DATA: ld_window_title TYPE string,
        ld_default_exte TYPE string,
        ld_filefilter   TYPE string,
        ld_fullpath     TYPE string,
        ld_filename     TYPE string,
        ld_filetype(10),
        ld_user_action  TYPE i,
        ld_filename1(100),
        ld_filename2(10),
        count TYPE i,
        ld_clno LIKE zscl_ctr-clno,
        ld_filenameu LIKE zscl_file-filename,
        lw_zscl_ctr LIKE zscl_ctr,
        lw_zscl_file LIKE zscl_file.

  CHECK t_itab_err[] IS NOT INITIAL.

  SELECT MAX( clno ) INTO ld_clno
    FROM zscl_ctr
    WHERE vkbur = pa_vkbur.

  lw_zscl_ctr-vkbur = pa_vkbur.
  lw_zscl_ctr-clno = ld_clno + 1.
  lw_zscl_ctr-udate = sy-datum.
  lw_zscl_ctr-utime = sy-uzeit.

  CONCATENATE pa_vkbur lw_zscl_ctr-clno INTO ld_filenameu SEPARATED BY '_'.
  ld_filename = ld_filenameu.

  lw_zscl_file-filename = ld_filenameu.
  lw_zscl_file-username = sy-uname.
  lw_zscl_file-udate = sy-datum.
  lw_zscl_file-utime = sy-uzeit.

* Append itab download
  CLEAR t_download.
  REFRESH t_download.
  LOOP AT t_itab_err.
* Header line
    AT FIRST.
      t_download-gjahr = 'Year'.
      t_download-zsmst = 'Qwt'.
      t_download-vkorg = 'SlOrg'.
      t_download-vkbur = 'SlOff'.
      t_download-kkber = 'CrCont'.
      t_download-kdgrp = 'CustGrp'.
      t_download-kvgr3 = 'CustSGrp'.
      t_download-knkli = 'CustSAP'.
      t_download-sortl = 'CustLGC'.
      t_download-name1 = 'CustName'.
      WRITE: 'Sales M1' TO t_download-slsm1 RIGHT-JUSTIFIED,
             'Sales M2' TO t_download-slsm2 RIGHT-JUSTIFIED,
             'Sales M3' TO t_download-slsm3 RIGHT-JUSTIFIED,
             'Sales M4' TO t_download-slsm4 RIGHT-JUSTIFIED,
             'Sales M5' TO t_download-slsm5 RIGHT-JUSTIFIED,
             'Sales M6' TO t_download-slsm6 RIGHT-JUSTIFIED,
             'History' TO t_download-hist RIGHT-JUSTIFIED,
             'CLCurrent' TO t_download-klimk RIGHT-JUSTIFIED,
             'CRHitung' TO t_download-klimk_hit RIGHT-JUSTIFIED,
             'CLUsulan' TO t_download-klimk_usl RIGHT-JUSTIFIED.
      t_download-message = 'message'.
      APPEND t_download. CLEAR t_download.
    ENDAT.

* Detail line
    WRITE: t_itab_err-gjahr TO t_download-gjahr,
           t_itab_err-zsmst TO t_download-zsmst,
           t_itab_err-vkorg TO t_download-vkorg,
           t_itab_err-vkbur TO t_download-vkbur,
           t_itab_err-kkber TO t_download-kkber,
           t_itab_err-kdgrp TO t_download-kdgrp,
           t_itab_err-kvgr3 TO t_download-kvgr3,
           t_itab_err-knkli TO t_download-knkli,
           t_itab_err-sortl TO t_download-sortl,
           t_itab_err-name1 TO t_download-name1,
           t_itab_err-slsm1 TO t_download-slsm1 CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab_err-slsm2 TO t_download-slsm2 CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab_err-slsm3 TO t_download-slsm3 CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab_err-slsm4 TO t_download-slsm4 CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab_err-slsm5 TO t_download-slsm5 CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab_err-slsm6 TO t_download-slsm6 CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab_err-hist TO t_download-hist CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab_err-klimk TO t_download-klimk CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab_err-klimk_hit TO t_download-klimk_hit CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab_err-klimk_usl TO t_download-klimk_usl CURRENCY 'IDR' RIGHT-JUSTIFIED,
           t_itab_err-message TO t_download-message.
    APPEND t_download. CLEAR t_download.

* Update flag status
    t_itab_err-udate = sy-datum.
    t_itab_err-utime = sy-uzeit.
    t_itab_err-status = 'D'.
    t_itab_err-fileerror = ld_filenameu.
    MODIFY t_itab_err TRANSPORTING udate utime status fileerror.
  ENDLOOP.

* POPUP download dialog
  ld_window_title = 'Download CL semester ERROR'.
  ld_default_exte = 'XLS'.
  CALL FUNCTION 'GUI_FILE_SAVE_DIALOG'
    EXPORTING
      window_title      = ld_window_title
      default_file_name = ld_filename
      default_extension = ld_default_exte
      file_filter       = ld_filefilter
    IMPORTING
      fullpath          = ld_fullpath
      user_action       = ld_user_action
      filename          = ld_filename.

*  SPLIT ld_filename AT '.' INTO: ld_filename1 ld_filename2.
*  CASE ld_filename2.
*    WHEN 'XLS' OR 'xls'.
*      ld_filetype = 'WK1'.
*    WHEN 'TXT' OR 'txt'.
*      ld_filetype = 'ASC'.
*    WHEN 'DAT' OR 'dat'.
*      ld_filetype = 'DAT'.
*    WHEN 'DBF' OR 'dbf'.
*      ld_filetype = 'DBF'.
*  ENDCASE.

*  IF ld_filetype = 'DBF'.
*    DELETE t_download INDEX 1.
** Append itab download
*    CLEAR t_dwn_field.
*    REFRESH t_dwn_field.
*    DO 20 TIMES.
*      ADD 1 TO count.
*      CASE count.
*        WHEN '1'.
*          t_dwn_field-txt_field = 'Year'.
*        WHEN '2'.
*          t_dwn_field-txt_field = 'Smt'.
*        WHEN '3'.
*          t_dwn_field-txt_field = 'SlOrg'.
*        WHEN '4'.
*          t_dwn_field-txt_field = 'SlOff'.
*        WHEN '5'.
*          t_dwn_field-txt_field = 'CrCont'.
*        WHEN '6'.
*          t_dwn_field-txt_field = 'CustGrp'.
*        WHEN '7'.
*          t_dwn_field-txt_field = 'CustSGrp'.
*        WHEN '8'.
*          t_dwn_field-txt_field = 'CustSAP'.
*        WHEN '9'.
*          t_dwn_field-txt_field = 'CustLGC'.
*        WHEN '10'.
*          t_dwn_field-txt_field = 'CustName'.
*        WHEN '11'.
*          t_dwn_field-txt_field = 'Sales M1'.
*        WHEN '12'.
*          t_dwn_field-txt_field = 'Sales M2'.
*        WHEN '13'.
*          t_dwn_field-txt_field = 'Sales M3'.
*        WHEN '14'.
*          t_dwn_field-txt_field = 'Sales M4'.
*        WHEN '15'.
*          t_dwn_field-txt_field = 'Sales M5'.
*        WHEN '16'.
*          t_dwn_field-txt_field = 'Sales M6'.
*        WHEN '17'.
*          t_dwn_field-txt_field = 'History'.
*        WHEN '18'.
*          t_dwn_field-txt_field = 'CLCurrent'.
*        WHEN '19'.
*          t_dwn_field-txt_field = 'CLHitung'.
*        WHEN '20'.
*          t_dwn_field-txt_field = 'CLUsulan'.
*      ENDCASE.
*      APPEND t_dwn_field. CLEAR t_dwn_field.
*    ENDDO.
*  ENDIF.

* Download to local
  ld_filetype = 'WK1'.
  IF ld_user_action = 1 OR ld_user_action = 0.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename         = ld_fullpath
        filetype         = ld_filetype
      TABLES
        data_tab         = t_download
        fieldnames       = t_dwn_field
      EXCEPTIONS
        file_write_error = 01
        no_batch         = 04
        unknown_error    = 05
        OTHERS           = 99.

    CASE sy-subrc.
      WHEN 0.
* Update table
        LOOP AT t_itab_err.
          t_itab_err-klimk_usl = t_itab_err-klimk_hit.
          MODIFY t_itab_err TRANSPORTING klimk_usl.
        ENDLOOP.
        MODIFY zscl_sm FROM TABLE t_itab_err.
        MODIFY zscl_ctr FROM lw_zscl_ctr.
        MODIFY zscl_file FROM lw_zscl_file.
        CLEAR t_itab_err. REFRESH t_itab_err.

      WHEN OTHERS.
        MESSAGE 'Download error' TYPE 'I'.
    ENDCASE.
*    REFRESH t_itab.
  ELSEIF ld_user_action = 2.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        append                = 'X'
        filename              = ld_fullpath
        filetype              = ld_filetype
        trunc_trailing_blanks = 'X'
      TABLES
        data_tab              = t_download
        fieldnames            = t_dwn_field
      EXCEPTIONS
        invalid_type          = 03
        no_batch              = 04
        unknown_error         = 05
        OTHERS                = 99.
    CASE sy-subrc.
      WHEN 0.
* Update table
        LOOP AT t_itab_err.
          t_itab_err-klimk_usl = t_itab_err-klimk_hit.
          MODIFY t_itab_err TRANSPORTING klimk_usl.
        ENDLOOP.
        MODIFY zscl_sm FROM TABLE t_itab_err.
        MODIFY zscl_ctr FROM lw_zscl_ctr.
        MODIFY zscl_file FROM lw_zscl_file.
        CLEAR t_itab_err. REFRESH t_itab_err.

      WHEN OTHERS.
        MESSAGE 'Download error' TYPE 'I'.
    ENDCASE.
  ENDIF.

ENDFORM.                    " f_download_err

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_XLS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_UPLKP  text
*      -->P_WORK_DI2  text
*----------------------------------------------------------------------*
FORM f_upload_xls  TABLES   p_t_uplkp STRUCTURE t_uplkp
                   USING    p_work_di2.
  DATA: l_value TYPE p.

  REFRESH t_excel.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_work_di2 "INPUT FROM SELECTION SCREEN
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 4
      i_end_row               = 60000
    TABLES
      intern                  = t_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SORT t_excel BY row col value.
  LOOP AT t_excel.
    IF t_excel-col = '0004'.
      CLEAR l_value.
      REPLACE ALL OCCURRENCES OF '.' IN t_excel-value WITH space.
      CONDENSE t_excel-value NO-GAPS.
      CALL FUNCTION 'ISM_CONVERT_CHAR_TO_DEC'
        EXPORTING
          i_char = t_excel-value
        IMPORTING
          e_dec  = l_value
        EXCEPTIONS
          error  = 1
          OTHERS = 2.
    ENDIF.

    CASE t_excel-col.
      WHEN '0001'.
        MOVE t_excel-value TO p_t_uplkp-gjahr.
      WHEN '0002'.
        MOVE t_excel-value TO p_t_uplkp-zsmst.
      WHEN '0003'.
        CONCATENATE '0' t_excel-value INTO p_t_uplkp-knkli.
      WHEN '0004'.
        t_uplkp-klimk_usl = l_value / 100.
    ENDCASE.
    AT END OF row.
      APPEND p_t_uplkp. CLEAR p_t_uplkp.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " F_UPLOAD_XLS

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_CSV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_UPLKP  text
*      -->P_WORK_DI2  text
*----------------------------------------------------------------------*
FORM f_upload_csv  TABLES   p_t_uplkp STRUCTURE t_uplkp
                   USING    p_work_di2.
  DATA: ld_filelength TYPE i,
        ld_filename TYPE string.

  ld_filename = p_work_di2.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = ld_filename
      filetype                = 'ASC'
*      has_field_separator     = 'X'
    IMPORTING
      filelength              = ld_filelength
    TABLES
      data_tab                = p_t_uplkp
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
ENDFORM.                    " F_UPLOAD_CSV
