*&---------------------------------------------------------------------*
*&  Include           ZF_JURNAL_EXPREPORTF01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_modify_screen USING : 'SLI' '0' '' '' '',
                                      'SER' '0' '' '' ''.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'SLI' '0' '' '' '',
                                      'SER' '0' '' '' ''.
    WHEN radio3.
      PERFORM f_modify_screen USING : 'SNA' '0' '' '' '',
                                      'SNO' '0' '' '' '',
                                      'SBD' '0' '' '' ''.
    WHEN radio4.
      PERFORM f_modify_screen USING : 'SNA' '0' '' '' '',
                                      'SNO' '0' '' '' '',
                                      'SLI' '0' '' '' '',
                                      'SER' '0' '' '' ''.
    WHEN radio5.
      PERFORM f_modify_screen USING : 'SNA' '0' '' '' '',
                                      'SNO' '0' '' '' '',
                                      'SLI' '0' '' '' '',
                                      'SER' '0' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA : lv_subrc       TYPE sy-subrc,
         lt_zf63gtype   TYPE STANDARD TABLE OF zf63gtype,
         ls_zf63gtype   LIKE LINE OF lt_zf63gtype,
         ls_gtype       LIKE LINE OF gt_gtype,
         lv_mess        TYPE string.

  DATA : lr_gtype       TYPE RANGE OF zgtype,
         ls_lines       LIKE LINE OF lr_gtype.

  IF pa_bukrs IS INITIAL.
    PERFORM f_error_message USING 'PBU' lv_mess.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      ls_lines-low    = '22'.
      ls_lines-option = 'EQ'.
      ls_lines-sign   = 'I'.
      APPEND ls_lines TO lr_gtype.
      CLEAR ls_lines.
      ls_lines-low    = '24'.
      ls_lines-option = 'EQ'.
      ls_lines-sign   = 'I'.
      APPEND ls_lines TO lr_gtype.
      CLEAR ls_lines.

    WHEN radio2.
      ls_lines-low    = '22'.
      ls_lines-option = 'EQ'.
      ls_lines-sign   = 'E'.
      APPEND ls_lines TO lr_gtype.
      CLEAR ls_lines.
      ls_lines-low    = '24'.
      ls_lines-option = 'EQ'.
      ls_lines-sign   = 'E'.
      APPEND ls_lines TO lr_gtype.
      CLEAR ls_lines.

    WHEN radio3.
      SELECT *
        FROM zf63gtype
        INTO CORRESPONDING FIELDS OF TABLE lt_zf63gtype
        WHERE bukrs = pa_bukrs
          AND gtype IN so_gtype
          AND advance <> space.
      LOOP AT lt_zf63gtype INTO ls_zf63gtype.
        ls_lines-low    = ls_zf63gtype-gtype.
        ls_lines-sign   = 'I'.
        ls_lines-option = 'EQ'.
        APPEND ls_lines TO lr_gtype.
        CLEAR ls_lines.
      ENDLOOP.
  ENDCASE.

  IF lr_gtype[] IS NOT INITIAL.
    SELECT gtype description
      FROM zf63gtype
      INTO CORRESPONDING FIELDS OF TABLE gt_gtype
      WHERE bukrs = pa_bukrs
        AND gtype IN lr_gtype.
  ENDIF.

  IF so_gtype[] IS NOT INITIAL.
    SELECT *
      FROM zf63gtype
      INTO CORRESPONDING FIELDS OF TABLE lt_zf63gtype
      WHERE bukrs = pa_bukrs
        AND gtype IN so_gtype.

    LOOP AT lt_zf63gtype INTO ls_zf63gtype.
      READ TABLE gt_gtype INTO ls_gtype
                          WITH KEY gtype = ls_zf63gtype-gtype.
      IF sy-subrc <> 0.
        IF so_gtype[] IS INITIAL.
          CASE 'X'.
            WHEN radio1.
              lv_mess = 'This report only for Type 22 & 24'.
            WHEN radio2.
              lv_mess = 'This report not for Type 22 & 24'.
          ENDCASE.
        ELSE.
          CASE 'X'.
            WHEN radio1 OR radio2.
              CONCATENATE 'You are not authorized for Type' ls_zf63gtype-gtype
              INTO lv_mess
              SEPARATED BY space.
            WHEN radio3.
              IF ls_zf63gtype-advance IS INITIAL.
                CONCATENATE 'You are not authorized for Type' ls_zf63gtype-gtype
                INTO lv_mess
                SEPARATED BY space.
              ENDIF.
            WHEN radio4 OR radio5.
              CONTINUE.
          ENDCASE.
        ENDIF.
        PERFORM f_error_message USING 'SGT' lv_mess.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_required.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
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

  IF fu_required IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-required  = fu_required.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_zf63gtype   LIKE LINE OF gt_zf63gtype,
         ls_tvkbt       LIKE LINE OF gt_tvkbt,
         ls_selec       LIKE LINE OF gt_selec,
         ls_reason      LIKE LINE OF gr_reason.

  DATA : ls_gtype       LIKE LINE OF gt_gtype.

  DATA : lt_mstper      TYPE STANDARD TABLE OF zf63masterperson,
         lt_mstken      TYPE STANDARD TABLE OF zf63masterkend,
         ls_mstper      LIKE LINE OF lt_mstper,
         ls_mstken      LIKE LINE OF lt_mstken,
         ls_zidno       LIKE LINE OF gr_zidno,
         ls_nopol       LIKE LINE OF gr_nopol.

  DATA : lv_lines       TYPE i.

  SELECT *
    FROM zf63gtype
    INTO CORRESPONDING FIELDS OF TABLE gt_allgtype
    WHERE bukrs = pa_bukrs.

  SELECT *
    FROM tvkbt
    INTO CORRESPONDING FIELDS OF TABLE gt_tvkbt
    WHERE spras = sy-langu
      AND vkbur IN so_vkbur.

  SELECT *
    FROM zf63gtype
    INTO CORRESPONDING FIELDS OF TABLE gt_zf63gtype
    WHERE gtype IN so_gtype
      AND bukrs = pa_bukrs.

  SELECT *
    FROM zf63tytpeexpdesc
    INTO CORRESPONDING FIELDS OF TABLE gt_typedesc
    WHERE gtype IN so_gtype.

  CASE 'X'.
    WHEN radio1.
      LOOP AT gt_zf63gtype INTO ls_zf63gtype.
        READ TABLE gt_gtype INTO ls_gtype
                            WITH KEY gtype = ls_zf63gtype-gtype.
        IF sy-subrc = 0.
          ls_selec-gtype  = ls_zf63gtype-gtype.
          LOOP AT gt_tvkbt INTO ls_tvkbt.
            ls_selec-vkbur  = ls_tvkbt-vkbur.
            APPEND ls_selec TO gt_selec.
          ENDLOOP.
        ELSE.
          DELETE TABLE gt_zf63gtype FROM ls_zf63gtype.
        ENDIF.
      ENDLOOP.

      PERFORM f_get_fieldinfo USING 'ZFEXPST01'.

      ls_reason-low     = '51'.
      ls_reason-high    = '53'.
      ls_reason-sign    = 'I'.
      ls_reason-option  = 'BT'.
      APPEND ls_reason TO gr_reason.
      CLEAR ls_reason.
      ls_reason-low     = '58'.
      ls_reason-sign    = 'I'.
      ls_reason-option  = 'EQ'.
      APPEND ls_reason TO gr_reason.
      CLEAR ls_reason.

      SELECT *
        FROM zf63masterperson
        INTO CORRESPONDING FIELDS OF TABLE lt_mstper
        WHERE bukrs = pa_bukrs
          AND vkbur IN so_vkbur
          AND name1 IN so_name1.

      LOOP AT lt_mstper INTO ls_mstper.
        ls_zidno-low    = ls_mstper-zidno.
        ls_zidno-sign   = 'I'.
        ls_zidno-option = 'EQ'.
        APPEND ls_zidno TO gr_zidno.
      ENDLOOP.

      SELECT *
        FROM zf63masterkend
        INTO CORRESPONDING FIELDS OF TABLE lt_mstken
        WHERE bukrs  = pa_bukrs
          AND vkbur  IN so_vkbur
          AND znopol IN so_nopol.

      LOOP AT lt_mstken INTO ls_mstken.
        ls_nopol-low    = ls_mstken-znopol.
        ls_nopol-sign   = 'I'.
        ls_nopol-option = 'EQ'.
        APPEND ls_nopol TO gr_nopol.
      ENDLOOP.

      IF so_nopol[] IS INITIAL.
        ls_nopol-low    = space.
        ls_nopol-sign   = 'I'.
        ls_nopol-option = 'EQ'.
        APPEND ls_nopol TO gr_nopol.
      ELSE.
        DESCRIBE TABLE so_nopol LINES lv_lines.
        IF lv_lines = 1.
          READ TABLE so_nopol INDEX 1.
          IF so_nopol-low IS INITIAL.
            ls_nopol-low    = space.
            ls_nopol-sign   = so_nopol-sign.
            ls_nopol-option = so_nopol-option.
            APPEND ls_nopol TO gr_nopol.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN radio2.
      LOOP AT gt_zf63gtype INTO ls_zf63gtype.
        READ TABLE gt_gtype INTO ls_gtype
                            WITH KEY gtype = ls_zf63gtype-gtype.
        IF sy-subrc = 0.
          ls_selec-gtype  = ls_zf63gtype-gtype.
          LOOP AT gt_tvkbt INTO ls_tvkbt.
            ls_selec-vkbur  = ls_tvkbt-vkbur.
            APPEND ls_selec TO gt_selec.
          ENDLOOP.
        ELSE.
          DELETE TABLE gt_zf63gtype FROM ls_zf63gtype.
        ENDIF.
      ENDLOOP.

      PERFORM f_get_fieldinfo USING 'ZFEXPST02'.

      ls_reason-low     = '51'.
      ls_reason-high    = '53'.
      ls_reason-sign    = 'I'.
      ls_reason-option  = 'BT'.
      APPEND ls_reason TO gr_reason.
      CLEAR ls_reason.
      ls_reason-low     = '58'.
      ls_reason-sign    = 'I'.
      ls_reason-option  = 'EQ'.
      APPEND ls_reason TO gr_reason.
      CLEAR ls_reason.

      SELECT *
        FROM zf63masterperson
        INTO CORRESPONDING FIELDS OF TABLE lt_mstper
        WHERE bukrs = pa_bukrs
          AND vkbur IN so_vkbur
          AND name1 IN so_name1.

      LOOP AT lt_mstper INTO ls_mstper.
        ls_zidno-low    = ls_mstper-zidno.
        ls_zidno-sign   = 'I'.
        ls_zidno-option = 'EQ'.
        APPEND ls_zidno TO gr_zidno.
      ENDLOOP.

      SELECT *
        FROM zf63masterkend
        INTO CORRESPONDING FIELDS OF TABLE lt_mstken
        WHERE bukrs  = pa_bukrs
          AND vkbur  IN so_vkbur
          AND znopol IN so_nopol.

      LOOP AT lt_mstken INTO ls_mstken.
        ls_nopol-low    = ls_mstken-znopol.
        ls_nopol-sign   = 'I'.
        ls_nopol-option = 'EQ'.
        APPEND ls_nopol TO gr_nopol.
      ENDLOOP.

      IF so_nopol[] IS INITIAL.
        ls_nopol-low    = space.
        ls_nopol-sign   = 'I'.
        ls_nopol-option = 'EQ'.
        APPEND ls_nopol TO gr_nopol.
      ELSE.
        DESCRIBE TABLE so_nopol LINES lv_lines.
        IF lv_lines = 1.
          READ TABLE so_nopol INDEX 1.
          IF so_nopol-low IS INITIAL.
            ls_nopol-low    = space.
            ls_nopol-sign   = so_nopol-sign.
            ls_nopol-option = so_nopol-option.
            APPEND ls_nopol TO gr_nopol.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN radio3.
      LOOP AT gt_zf63gtype INTO ls_zf63gtype.
        READ TABLE gt_gtype INTO ls_gtype
                            WITH KEY gtype = ls_zf63gtype-gtype.
        IF sy-subrc = 0.
          ls_selec-gtype  = ls_zf63gtype-gtype.
          LOOP AT gt_tvkbt INTO ls_tvkbt.
            ls_selec-vkbur  = ls_tvkbt-vkbur.
            APPEND ls_selec TO gt_selec.
          ENDLOOP.
        ELSE.
          DELETE TABLE gt_zf63gtype FROM ls_zf63gtype.
        ENDIF.
      ENDLOOP.

    WHEN radio4.
      LOOP AT gt_zf63gtype INTO ls_zf63gtype.
        ls_selec-gtype  = ls_zf63gtype-gtype.
        LOOP AT gt_tvkbt INTO ls_tvkbt.
          ls_selec-vkbur  = ls_tvkbt-vkbur.
          IF ls_zf63gtype-advance IS INITIAL.
            APPEND ls_selec TO gt_selecpexp.
          ELSE.
            APPEND ls_selec TO gt_selecpadv.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

    WHEN radio5.
      LOOP AT gt_zf63gtype INTO ls_zf63gtype.
        ls_selec-gtype  = ls_zf63gtype-gtype.
        LOOP AT gt_tvkbt INTO ls_tvkbt.
          ls_selec-vkbur  = ls_tvkbt-vkbur.
          APPEND ls_selec TO gt_selec.
        ENDLOOP.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CASE 'X'.
    WHEN radio1.
      sy-title  = 'Delivery & Canvas Report'.
      NEW-PAGE LINE-SIZE 1050.
      PERFORM f_print_radio1.
    WHEN radio2.
      sy-title  = 'Non Delivery & Canvas Report'.
      NEW-PAGE LINE-SIZE 887.
      PERFORM f_print_radio2.
  ENDCASE.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM f_top_of_page USING fu_times fu_gtype fu_vkbur.
  DATA : lv_text    TYPE string.

  CASE 'X'.
    WHEN radio1.
      WRITE : / 'Report Delivery & Canvas'.
      PERFORM f_report_text USING '1' 'Departemen     :' fu_gtype ''
                            CHANGING lv_text.
      WRITE : / lv_text.
      PERFORM f_report_text USING '2' 'Sales Office   :' '' fu_vkbur
                            CHANGING lv_text.
      WRITE : / lv_text.
      PERFORM f_report_text USING '3' 'Periode Report :' '' ''
                            CHANGING lv_text.
      WRITE : / lv_text.
      PERFORM f_report_text USING '4' 'Hari Kerja     :' '' ''
                            CHANGING lv_text.
      WRITE : / lv_text.

      SKIP 1.
      WRITE : sy-uline.
*--------------------------------------------------------------------*
      PERFORM f_head_line1_r1 USING '1'.
      PERFORM f_head_line2_r1 USING '2'.
      PERFORM f_head_line3_r1 USING '3'.
      PERFORM f_head_line4_r1 USING '4'.
      PERFORM f_head_line5_r1 USING '5' fu_times.
      PERFORM f_head_line6_r1 USING '6' fu_times.
*--------------------------------------------------------------------*
      WRITE : / sy-uline.

    WHEN radio2.
      WRITE : / 'Report Non Delivery & Canvas'.
      PERFORM f_report_text USING '1' 'Departemen     :' fu_gtype ''
                            CHANGING lv_text.
      WRITE : / lv_text.
      PERFORM f_report_text USING '2' 'Sales Office   :' '' fu_vkbur
                            CHANGING lv_text.
      WRITE : / lv_text.
      PERFORM f_report_text USING '3' 'Periode Report :' '' ''
                            CHANGING lv_text.
      WRITE : / lv_text.
      PERFORM f_report_text USING '4' 'Hari Kerja     :' '' ''
                            CHANGING lv_text.
      WRITE : / lv_text.

      SKIP 1.
      WRITE : sy-uline.
*--------------------------------------------------------------------*
      PERFORM f_head_line1_r2 USING '1'.
      PERFORM f_head_line2_r2 USING '2'.
      PERFORM f_head_line3_r2 USING '3'.
      PERFORM f_head_line4_r2 USING '4'.
      PERFORM f_head_line5_r2 USING '5' fu_times.
      PERFORM f_head_line6_r2 USING '6' fu_times.
*--------------------------------------------------------------------*
      WRITE : / sy-uline.
  ENDCASE.
ENDFORM.                    " F_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_DATA
*&---------------------------------------------------------------------*
FORM f_write_data  USING    fu_row fu_col1 fu_col2 fu_value fu_just
                            fu_nogap fu_start fu_end
                            fu_gtype fu_vkbur fu_budatpexp fu_field.
  DATA : ls_column    LIKE LINE OF gt_column,
         lv_length    TYPE i,
         lv_gap       TYPE i,
         lv_value     TYPE string,
         lv_col       TYPE i,
         lv_field(30),
         lv_dats(10),
         lv_just.

  FIELD-SYMBOLS <fs>  TYPE ANY.

  lv_just = fu_just.

  IF fu_row IS NOT INITIAL.
    IF fu_col2 IS INITIAL.
      READ TABLE gt_column INTO ls_column
                           WITH KEY col  = fu_col1.
      IF sy-subrc = 0.
        lv_length = ls_column-length.
        IF fu_value IS NOT INITIAL.
          CASE fu_row.
            WHEN 1.
              lv_value = ls_column-header1.
            WHEN 2.
              lv_value = ls_column-header2.
            WHEN 3.
              lv_value = ls_column-header3.
            WHEN 4.
              lv_value = ls_column-header4.
            WHEN 5.
              lv_value = ls_column-header5.
            WHEN 6.
              lv_value = ls_column-header6.
          ENDCASE.
        ENDIF.
      ENDIF.
    ELSE.
      lv_col  = fu_col2 - 1.
      lv_gap  = fu_col1 + lv_col.
      LOOP AT gt_column INTO ls_column.
        IF ls_column-col BETWEEN fu_col1 AND lv_gap.
          ADD ls_column-length TO lv_length.
          IF fu_value IS NOT INITIAL.
            IF lv_value IS INITIAL.
              CASE fu_row.
                WHEN 1.
                  lv_value = ls_column-header1.
                WHEN 2.
                  lv_value = ls_column-header2.
                WHEN 3.
                  lv_value = ls_column-header3.
                WHEN 4.
                  lv_value = ls_column-header4.
                WHEN 5.
                  lv_value = ls_column-header5.
                WHEN 6.
                  lv_value = ls_column-header6.
              ENDCASE.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
      lv_length = lv_length + lv_col.
    ENDIF.
  ELSE.
    READ TABLE gt_column INTO ls_column
                         WITH KEY col  = fu_col1.
    IF sy-subrc = 0.
      IF ls_column-noout IS INITIAL.
        CONCATENATE fu_field ls_column-fieldname INTO lv_field.
        ASSIGN (lv_field) TO <fs>.
        lv_length = ls_column-length.
        IF fu_value IS NOT INITIAL.
          CASE ls_column-datatype.
            WHEN 'DATS'.
              WRITE <fs> TO lv_dats DD/MM/YYYY.
              IF lv_dats <> '00.00.0000'.
                lv_value = lv_dats.
              ENDIF.
            WHEN OTHERS.
              lv_value = <fs>.
          ENDCASE.
          UNASSIGN <fs>.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF fu_start IS NOT INITIAL.
    r1  = 1.
    WRITE : / sy-vline. r1 = r1 + 1.
  ELSE.
    WRITE AT r1(1) sy-vline. r1 = r1 + 1.
  ENDIF.

  CASE lv_just.
    WHEN 'C'.
      WRITE AT r1(lv_length) lv_value CENTERED. r1 = r1 + lv_length.
    WHEN OTHERS.
      WRITE AT r1(lv_length) lv_value. r1 = r1 + lv_length.
  ENDCASE.

  IF fu_end IS NOT INITIAL.
    IF fu_nogap IS INITIAL.
      WRITE AT r1(1) sy-vline. r1 = r1 + 1.
    ELSE.
      WRITE AT r1(1) sy-vline NO-GAP.
    ENDIF.
  ENDIF.

  IF fu_gtype IS NOT INITIAL.
    PERFORM f_calc_total USING fu_gtype fu_vkbur fu_budatpexp
                               lv_value fu_col1.
  ENDIF.
ENDFORM.                    " F_WRITE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_INIT_LENGTH
*&---------------------------------------------------------------------*
FORM f_init_length  USING    fu_col fu_fieldname fu_value.

ENDFORM.                    " F_INIT_LENGTH

*&---------------------------------------------------------------------*
*&      Form  F_GET_FIELDINFO
*&---------------------------------------------------------------------*
FORM f_get_fieldinfo  USING    fu_tabname.
  DATA : lt_lines1    TYPE STANDARD TABLE OF tline,
         ls_lines1    LIKE LINE OF lt_lines1,
         lt_lines2    TYPE STANDARD TABLE OF tline,
         ls_lines2    LIKE LINE OF lt_lines2,
         lt_lines3    TYPE STANDARD TABLE OF tline,
         ls_lines3    LIKE LINE OF lt_lines3,
         lt_lines4    TYPE STANDARD TABLE OF tline,
         ls_lines4    LIKE LINE OF lt_lines4,
         lt_lines5    TYPE STANDARD TABLE OF tline,
         ls_lines5    LIKE LINE OF lt_lines5,
         lt_lines6    TYPE STANDARD TABLE OF tline,
         ls_lines6    LIKE LINE OF lt_lines6.

  DATA : lt_text1     TYPE STANDARD TABLE OF tline,
         ls_text1     LIKE LINE OF lt_text1,
         lt_text2     TYPE STANDARD TABLE OF tline,
         ls_text2     LIKE LINE OF lt_text2,
         lt_text3     TYPE STANDARD TABLE OF tline,
         ls_text3     LIKE LINE OF lt_text3,
         lt_text4     TYPE STANDARD TABLE OF tline,
         ls_text4     LIKE LINE OF lt_text4,
         lt_text5     TYPE STANDARD TABLE OF tline,
         ls_text5     LIKE LINE OF lt_text5,
         lt_text6     TYPE STANDARD TABLE OF tline,
         ls_text6     LIKE LINE OF lt_text6.

  DATA : ls_tab       LIKE LINE OF gt_tab,
         ls_column    LIKE LINE OF gt_column,
         lv_leng1     TYPE i,
         lv_leng2     TYPE i,
         lv_col       TYPE i,
         lv_cnt1      TYPE i,
         lv_cnt2      TYPE i,
         lv_cnt3      TYPE i,
         lv_cnt4      TYPE i,
         lv_cnt5      TYPE i,
         lv_cnt6      TYPE i.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_read_text TABLES lt_lines1
                          USING 'ZEXPJUDUL15'.
      PERFORM f_read_text TABLES lt_lines2
                          USING 'ZEXPJUDUL14'.
      PERFORM f_read_text TABLES lt_lines3
                          USING 'ZEXPJUDUL13'.
      PERFORM f_read_text TABLES lt_lines4
                          USING 'ZEXPJUDUL12'.
      PERFORM f_read_text TABLES lt_lines5
                          USING 'ZEXPJUDUL11'.
      PERFORM f_read_text TABLES lt_lines6
                          USING 'ZEXPJUDUL1'.
    WHEN radio2.
      PERFORM f_read_text TABLES lt_lines1
                          USING 'ZEXPJUDUL25'.
      PERFORM f_read_text TABLES lt_lines2
                          USING 'ZEXPJUDUL24'.
      PERFORM f_read_text TABLES lt_lines3
                          USING 'ZEXPJUDUL23'.
      PERFORM f_read_text TABLES lt_lines4
                          USING 'ZEXPJUDUL22'.
      PERFORM f_read_text TABLES lt_lines5
                          USING 'ZEXPJUDUL21'.
      PERFORM f_read_text TABLES lt_lines6
                          USING 'ZEXPJUDUL2'.
  ENDCASE.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = fu_tabname
    TABLES
      dfies_tab      = gt_tab
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.

  LOOP AT gt_tab INTO ls_tab.
    ADD 1 TO lv_col.
    ls_column-col       = lv_col.
    ls_column-fieldname = ls_tab-fieldname.
    ls_column-datatype  = ls_tab-datatype.
    lv_leng1 = ls_tab-leng + 2.

    PERFORM f_isi_header TABLES lt_text1 lt_lines1
                         CHANGING lv_cnt1 ls_column-header1.

    PERFORM f_isi_header TABLES lt_text2 lt_lines2
                         CHANGING lv_cnt2 ls_column-header2.

    PERFORM f_isi_header TABLES lt_text3 lt_lines3
                         CHANGING lv_cnt3 ls_column-header3.

    PERFORM f_isi_header TABLES lt_text4 lt_lines4
                         CHANGING lv_cnt4 ls_column-header4.

    PERFORM f_isi_header TABLES lt_text5 lt_lines5
                         CHANGING lv_cnt5 ls_column-header5.

    PERFORM f_isi_header TABLES lt_text6 lt_lines6
                         CHANGING lv_cnt6 ls_column-header6.

    lv_leng2 = STRLEN( ls_column-header6 ).
    lv_leng2 = lv_leng2 + 2.

    IF lv_leng2 > lv_leng1.
      ls_column-length = lv_leng2.
    ELSE.
      ls_column-length = lv_leng1.
    ENDIF.

    CASE ls_tab-fieldname.
      WHEN 'PARKIR' OR 'TOL' OR 'TIKET' OR 'TTRAVEL' OR
           'HOTEL' OR 'HOTELX' OR 'KOST' OR 'PDDK' OR 'PDLK' OR
           'PDLK' OR 'TLODG' OR 'OGVAL' OR 'OTVAL' OR 'OMVAL' OR
           'GBVAL' OR 'AKIVAL' OR 'TAMBAL' OR 'GEMBOK' OR 'SPAREPART' OR
           'SBESAR' OR 'SKECIL' OR 'STNK' OR 'KIR' OR 'PLAT' OR 'BPKB' OR
           'TVEHI' OR 'IMK' OR 'IBM' OR 'RETRI' OR 'TIMBANG' OR 'TRR'.
        ls_column-total1 = 'X'.
      WHEN 'BBM' OR 'TTVLLOD' OR 'TRM' OR 'FEERM' OR 'TTAXLIC' OR
           'PULSA' OR 'WARNET' OR 'SCAN' OR 'INTMDS' OR 'SERVMDS' OR
           'HANDLING' OR 'BANK' OR 'PRINT' OR 'FOTOCOPY' OR 'PROFFEE' OR
           'GRAND'.
        ls_column-total1 = 'X'.
        ls_column-total2 = 'X'.
      WHEN 'PPN' OR 'PPH21' OR 'PPH23' OR 'MATERAI' OR 'KIRIM' OR
           'MISCEXP'.
        ls_column-total1 = 'X'.
        ls_column-total2 = 'X'.
      WHEN 'GTYPE' OR 'VKBUR' OR 'LINE'.
        ls_column-noout  = 'X'.
    ENDCASE.

    APPEND ls_column TO gt_column.
    CLEAR ls_column.
  ENDLOOP.
ENDFORM.                    " F_GET_FIELDINFO

*&---------------------------------------------------------------------*
*&      Form  F_READ_TEXT
*&---------------------------------------------------------------------*
FORM f_read_text  TABLES   ft_lines STRUCTURE tline
                  USING    fu_name.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'ST'
      language                = sy-langu
      name                    = fu_name
      object                  = 'TEXT'
    TABLES
      lines                   = ft_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
ENDFORM.                    " F_READ_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_ISI_HEADER
*&---------------------------------------------------------------------*
FORM f_isi_header  TABLES   ft_text STRUCTURE tline
                            ft_lines  STRUCTURE tline
                     CHANGING fc_count fc_header.

  DATA : ls_lines   TYPE tline,
         ls_text    TYPE tline.

  IF ft_text[] IS INITIAL.
    ADD 1 TO fc_count.
    READ TABLE ft_lines INTO ls_lines INDEX fc_count.
    IF sy-subrc = 0.
      SPLIT ls_lines-tdline AT '|' INTO TABLE ft_text.
    ENDIF.
  ENDIF.

  READ TABLE ft_text INTO ls_text INDEX 1.
  IF sy-subrc = 0.
    fc_header  = ls_text.
    DELETE ft_text INDEX 1.
  ENDIF.
ENDFORM.                    " F_ISI_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_GTYPE
*&---------------------------------------------------------------------*
FORM f_value_gtype  USING    fu_field fu_fieldname
                    CHANGING fc_value.
  DATA : return_tab  TYPE STANDARD TABLE OF ddshretval,
         lt_gtype    TYPE STANDARD TABLE OF ty_gtype,
         ls_return   LIKE LINE OF return_tab,
         ls_gtype    LIKE LINE OF gt_gtype.

  DATA : lv_bukrs    TYPE zf63gtype-bukrs,
         lv_subrc    TYPE sy-subrc.

  DATA : lr_gtype       TYPE RANGE OF zgtype,
         ls_lines       LIKE LINE OF lr_gtype.

  IF pa_bukrs IS NOT INITIAL.
    lv_bukrs = pa_bukrs.
  ELSE.
    PERFORM f_dynp_value_read USING 'PA_BUKRS'
                              CHANGING lv_bukrs.
  ENDIF.

  ls_lines-low    = '22'.
  ls_lines-option = 'EQ'.
  CASE 'X'.
    WHEN radio1.
      ls_lines-sign   = 'I'.
    WHEN radio2.
      ls_lines-sign   = 'E'.
  ENDCASE.
  APPEND ls_lines TO lr_gtype.
  CLEAR ls_lines.
  ls_lines-low    = '24'.
  ls_lines-option = 'EQ'.
  CASE 'X'.
    WHEN radio1.
      ls_lines-sign   = 'I'.
    WHEN radio2.
      ls_lines-sign   = 'E'.
  ENDCASE.
  APPEND ls_lines TO lr_gtype.
  CLEAR ls_lines.

  CASE 'X'.
    WHEN radio1 OR radio2.
      SELECT gtype description
        FROM zf63gtype
        INTO CORRESPONDING FIELDS OF TABLE lt_gtype
        WHERE bukrs = lv_bukrs
          AND gtype IN lr_gtype.
    WHEN radio3.
      SELECT gtype description
        FROM zf63gtype
        INTO CORRESPONDING FIELDS OF TABLE lt_gtype
        WHERE bukrs = lv_bukrs
          AND advance <> space.
    WHEN radio4 OR radio5.
      SELECT gtype description
        FROM zf63gtype
        INTO CORRESPONDING FIELDS OF TABLE lt_gtype
        WHERE bukrs = lv_bukrs.
  ENDCASE.

  ASSIGN lt_gtype[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING fu_fieldname fu_field
                          CHANGING lv_subrc.
  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      fc_value  = ls_return-fieldval.
      READ TABLE lt_gtype INTO ls_gtype
                 WITH KEY gtype = fc_value.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING fu_field ls_gtype-gtype ''.
      ENDIF.
    ELSE.
      PERFORM f_dynpfield TABLES dynpfields
                          USING fu_field fc_value ''.

    ENDIF.
    PERFORM f_dyn_values_update.
  ENDIF.
ENDFORM.                    " F_VALUE_GTYPE

*&---------------------------------------------------------------------*
*&      Form  F_DYNP_VALUE_READ
*&---------------------------------------------------------------------*
FORM f_dynp_value_read  USING    fieldname
                        CHANGING fc_value.

  DATA : lt_dynpfields  TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0,
         ls_dynpfields  LIKE LINE OF lt_dynpfields.

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

  READ TABLE lt_dynpfields INTO ls_dynpfields
                           WITH KEY fieldname =  fieldname.
  IF sy-subrc = 0.
    fc_value  = ls_dynpfields-fieldvalue.
  ENDIF.
ENDFORM.                    " F_DYNP_VALUE_READ

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
ENDFORM.                    " F_VALUE_REQUEST

*&---------------------------------------------------------------------*
*&      Form  F_DYNPFIELD
*&---------------------------------------------------------------------*
FORM f_dynpfield  TABLES   dynpfields STRUCTURE dynpread
                  USING    fieldname fieldvalue fu_waers.

  DATA : ls_dynpfields  LIKE LINE OF dynpfields.

  ls_dynpfields-fieldname  = fieldname.
  IF fu_waers IS NOT INITIAL.
    ls_dynpfields-fieldvalue = fieldvalue.
    TRANSLATE ls_dynpfields-fieldvalue USING '. '.
    CONDENSE ls_dynpfields-fieldvalue NO-GAPS.
  ELSE.
    ls_dynpfields-fieldvalue = fieldvalue.
  ENDIF.
  APPEND ls_dynpfields TO dynpfields.
ENDFORM.                    " F_DYNPFIELD

*&---------------------------------------------------------------------*
*&      Form  F_DYN_VALUES_UPDATE
*&---------------------------------------------------------------------*
FORM f_dyn_values_update .
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.
ENDFORM.                    " F_DYN_VALUES_UPDATE

*&---------------------------------------------------------------------*
*&      Form  F4CALLBACK
*&---------------------------------------------------------------------*
FORM f4callback TABLES   record_tab STRUCTURE seahlpres
                CHANGING shlp TYPE shlp_descr
                         callcontrol LIKE ddshf4ctrl.

  shlp-intdescr-dialogtype = 'D'.
  callcontrol-no_maxdisp = ''.
*  callcontrol-maxrecords = 500.
ENDFORM.                    " F4CALLBACK

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

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
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_NAME1
*&---------------------------------------------------------------------*
FORM f_value_name1  USING    fu_field fu_fieldname
                    CHANGING fc_value.
  DATA : lt_tvbur TYPE STANDARD TABLE OF tvbur,
         ls_tvbur LIKE LINE OF lt_tvbur.

  DATA : BEGIN OF lt_person OCCURS 0,
           zidno  TYPE zf63masterperson-zidno,
           name1  TYPE zf63masterperson-name1,
         END OF lt_person.

  DATA : return_tab     TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return      LIKE LINE OF return_tab.

  DATA : ls_person   LIKE LINE OF lt_person,
         lv_subrc    TYPE sy-subrc,
         lv_bukrs    TYPE zf63masterperson-bukrs,
         lv_gtype    TYPE zf63masterperson-gtype.

  IF pa_bukrs IS NOT INITIAL.
    lv_bukrs = pa_bukrs.
  ELSE.
    PERFORM f_dynp_value_read USING 'PA_BUKRS'
                              CHANGING lv_bukrs.
  ENDIF.

  IF so_vkbur[] IS NOT INITIAL.
    SELECT vkbur
      FROM tvbur
      INTO CORRESPONDING FIELDS OF TABLE lt_tvbur
      WHERE vkbur IN so_vkbur.
  ELSE.
    PERFORM f_dynp_value_read USING 'SO_VKBUR-LOW'
                              CHANGING ls_tvbur-vkbur.
    APPEND ls_tvbur TO lt_tvbur.
  ENDIF.

  CLEAR : lt_person[], lt_person, dynpfields[], dynpfields.
  IF lt_tvbur[] IS NOT INITIAL.
    SELECT zidno name1
      FROM zf63masterperson
      INTO CORRESPONDING FIELDS OF TABLE lt_person
      FOR ALL ENTRIES IN lt_tvbur
      WHERE bukrs = lv_bukrs
        AND vkbur = lt_tvbur-vkbur.
  ENDIF.

  ASSIGN lt_person[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING fu_fieldname fu_field
                          CHANGING lv_subrc.
  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      fc_value  = ls_return-fieldval.
      READ TABLE lt_person INTO ls_person WITH KEY name1 = fc_value.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING fu_field ls_person-name1 ''.
      ENDIF.
    ELSE.
      PERFORM f_dynpfield TABLES dynpfields
                          USING fu_field '' ''.

    ENDIF.
    PERFORM f_dyn_values_update.
  ENDIF.
ENDFORM.                    " F_VALUE_NAME1

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_NOPOL
*&---------------------------------------------------------------------*
FORM f_value_nopol  USING    fu_field fu_fieldname
                    CHANGING fc_value.
  DATA : lt_tvbur TYPE STANDARD TABLE OF tvbur,
         ls_tvbur LIKE LINE OF lt_tvbur.

  DATA : BEGIN OF lt_kend OCCURS 0,
           zidke   TYPE zf63masterkend-zidke,
           znopol  TYPE zf63masterkend-znopol,
         END OF lt_kend.

  DATA : return_tab     TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return      LIKE LINE OF return_tab.

  DATA : ls_kend     LIKE LINE OF lt_kend,
         lv_subrc    TYPE sy-subrc,
         lv_bukrs    TYPE zf63masterkend-bukrs,
         lv_znopol   TYPE zf63masterkend-znopol.

  IF pa_bukrs IS NOT INITIAL.
    lv_bukrs = pa_bukrs.
  ELSE.
    PERFORM f_dynp_value_read USING 'PA_BUKRS'
                              CHANGING lv_bukrs.
  ENDIF.

  IF so_vkbur[] IS NOT INITIAL.
    SELECT vkbur
      FROM tvbur
      INTO CORRESPONDING FIELDS OF TABLE lt_tvbur
      WHERE vkbur IN so_vkbur.
  ELSE.
    PERFORM f_dynp_value_read USING 'SO_VKBUR-LOW'
                              CHANGING ls_tvbur-vkbur.
    APPEND ls_tvbur TO lt_tvbur.
  ENDIF.

  CLEAR : lt_kend[], lt_kend, dynpfields[], dynpfields.
  IF lt_tvbur[] IS NOT INITIAL.
    SELECT zidke znopol
      FROM zf63masterkend
      INTO CORRESPONDING FIELDS OF TABLE lt_kend
      FOR ALL ENTRIES IN lt_tvbur
        WHERE bukrs = lv_bukrs
          AND vkbur = lt_tvbur-vkbur
          AND loevm = space.
  ENDIF.

  ASSIGN lt_kend[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING fu_fieldname fu_field
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      fc_value  = ls_return-fieldval.
      READ TABLE lt_kend INTO ls_kend WITH KEY znopol = fc_value.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING fu_field ls_kend-znopol ''.
      ENDIF.
    ELSE.
      PERFORM f_dynpfield TABLES dynpfields
                          USING fu_field '' ''.

    ENDIF.
    PERFORM f_dyn_values_update.
  ENDIF.
ENDFORM.                    " F_VALUE_NOPOL

*&---------------------------------------------------------------------*
*&      Form  F_REPORT_TEXT
*&---------------------------------------------------------------------*
FORM f_report_text  USING    fu_flag fu_text fu_gtype fu_vkbur
                    CHANGING fc_text.
  DATA : lv_text        TYPE string,
         lv_lines       TYPE string,
         lv_low(10),
         lv_high(10),
         holidays       TYPE STANDARD TABLE OF iscal_day,
         lv_days        TYPE string,
         ls_tvkbt       LIKE LINE OF gt_tvkbt,
         ls_zf63gtype   LIKE LINE OF gt_zf63gtype.

  CLEAR fc_text.

  CASE fu_flag.
    WHEN '1'.
      READ TABLE gt_zf63gtype INTO ls_zf63gtype
                              WITH KEY gtype = fu_gtype.
      CONCATENATE fu_text fu_gtype '-' ls_zf63gtype-description
      INTO fc_text
      SEPARATED BY space.
    WHEN '2'.
      READ TABLE gt_tvkbt INTO ls_tvkbt
                          WITH KEY vkbur = fu_vkbur.
      CONCATENATE fu_text fu_vkbur '-' ls_tvkbt-bezei
      INTO fc_text
      SEPARATED BY space.
    WHEN '3'.
      WRITE so_budat-low TO lv_low DD/MM/YYYY.
      WRITE so_budat-high TO lv_high DD/MM/YYYY.
      IF so_budat-high IS INITIAL.
        CONCATENATE fu_text lv_low
        INTO fc_text
        SEPARATED BY space.
      ELSE.
        CONCATENATE fu_text lv_low '-' lv_high
        INTO fc_text
        SEPARATED BY space.
      ENDIF.
    WHEN '4'.
      IF so_budat-high IS INITIAL.
        so_budat-high = so_budat-low.
      ENDIF.

      CALL FUNCTION 'HOLIDAY_GET'
        EXPORTING
          holiday_calendar           = 'T1'
          factory_calendar           = 'T1'
          date_from                  = so_budat-low
          date_to                    = so_budat-high
        TABLES
          holidays                   = holidays
        EXCEPTIONS
          factory_calendar_not_found = 1
          holiday_calendar_not_found = 2
          date_has_invalid_format    = 3
          date_inconsistency         = 4
          OTHERS                     = 5.

      DESCRIBE TABLE holidays LINES lv_lines.
      lv_days = ( so_budat-high - so_budat-low ) - lv_lines + 1.
      CONCATENATE fu_text lv_days 'hari'
      INTO fc_text
      SEPARATED BY space.
  ENDCASE.
ENDFORM.                    " F_REPORT_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_trnhdr      TYPE STANDARD TABLE OF zf63trnhdr2,
         lt_trndtl      TYPE STANDARD TABLE OF zf63trndtl2,
         lt_trnshp      TYPE STANDARD TABLE OF zf63trnshp2,
         lt_vttp        TYPE STANDARD TABLE OF vttp,
         ls_zf63gtype   LIKE LINE OF gt_zf63gtype,
         lt_lips        TYPE STANDARD TABLE OF lips.

  IF gt_selec[] IS NOT INITIAL.
    SELECT *
      FROM zf63trnhdr2
      INTO CORRESPONDING FIELDS OF TABLE gt_trnhdr
      FOR ALL ENTRIES IN gt_selec
      WHERE bukrs     = pa_bukrs
        AND vkbur     = gt_selec-vkbur
        AND gtype     = gt_selec-gtype
        AND budatpexp IN so_budat
        AND userrev   = space
        AND zidno     IN gr_zidno.

    IF gt_trnhdr[] IS NOT INITIAL.
      SELECT *
        FROM zf63trndtl2
        INTO CORRESPONDING FIELDS OF TABLE gt_trndtl
        FOR ALL ENTRIES IN gt_trnhdr
        WHERE bukrs   = gt_trnhdr-bukrs
          AND gsber   = gt_trnhdr-gsber
          AND vkbur   = gt_trnhdr-vkbur
          AND gtype   = gt_trnhdr-gtype
          AND zidvc   = gt_trnhdr-zidvc
          AND znopol  IN gr_nopol.

      SELECT *
        FROM zf63trnshp2
        INTO CORRESPONDING FIELDS OF TABLE gt_trnshp
        FOR ALL ENTRIES IN gt_trnhdr
        WHERE bukrs = gt_trnhdr-bukrs
          AND gsber = gt_trnhdr-gsber
          AND vkbur = gt_trnhdr-vkbur
          AND gtype = gt_trnhdr-gtype
          AND zidvc = gt_trnhdr-zidvc.
    ENDIF.

    lt_trnhdr[] = gt_trnhdr[].
    SORT lt_trnhdr BY zidno.
    DELETE ADJACENT DUPLICATES FROM lt_trnhdr COMPARING zidno.
    IF lt_trnhdr[] IS NOT INITIAL.
      SELECT *
        FROM zf63masterperson
        INTO CORRESPONDING FIELDS OF TABLE gt_mstper
        FOR ALL ENTRIES IN lt_trnhdr
        WHERE bukrs = pa_bukrs
          AND zidno = lt_trnhdr-zidno.
    ENDIF.
  ENDIF.

  lt_trndtl[] = gt_trndtl[].
  SORT lt_trndtl BY znopol.
  DELETE ADJACENT DUPLICATES FROM lt_trndtl COMPARING znopol.
  IF lt_trndtl[] IS NOT INITIAL.
    SELECT *
      FROM zf63masterkend
      INTO CORRESPONDING FIELDS OF TABLE gt_mstken
      FOR ALL ENTRIES IN lt_trndtl
      WHERE bukrs  = pa_bukrs
        AND znopol = lt_trndtl-znopol.
  ENDIF.

  CLEAR ls_zf63gtype.
  READ TABLE gt_zf63gtype INTO ls_zf63gtype
                      WITH KEY gtype = '24'
                      TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    lt_trnshp[] = gt_trnshp[].
    SORT lt_trnshp BY tknum.
    DELETE ADJACENT DUPLICATES FROM lt_trnshp COMPARING tknum.
    IF lt_trnshp[] IS NOT INITIAL.
      SELECT *
        FROM vttp
        INTO CORRESPONDING FIELDS OF TABLE gt_vttp
        FOR ALL ENTRIES IN lt_trnshp
        WHERE tknum = lt_trnshp-tknum.

      lt_vttp[] = gt_vttp[].
      SORT lt_vttp BY vbeln.
      DELETE ADJACENT DUPLICATES FROM lt_vttp COMPARING vbeln.
      IF lt_vttp[] IS NOT INITIAL.
        SELECT *
          FROM likp
          INTO CORRESPONDING FIELDS OF TABLE gt_likp
          FOR ALL ENTRIES IN lt_vttp
          WHERE vbeln = lt_vttp-vbeln.

        SELECT *
          FROM lips
          INTO CORRESPONDING FIELDS OF TABLE gt_lips
          FOR ALL ENTRIES IN lt_vttp
          WHERE vbeln = lt_vttp-vbeln.

        lt_lips[] = gt_lips[].
        SORT lt_lips BY vgbel.
        DELETE ADJACENT DUPLICATES FROM lt_lips COMPARING vgbel.
        IF lt_lips[] IS NOT INITIAL.
          SELECT *
            FROM vbap
            INTO CORRESPONDING FIELDS OF TABLE gt_vbap
            FOR ALL ENTRIES IN lt_lips
            WHERE vbeln = lt_lips-vgbel.
        ENDIF.

        lt_lips[] = gt_lips[].
        SORT lt_lips BY matnr.
        DELETE ADJACENT DUPLICATES FROM lt_lips COMPARING matnr.
        IF lt_lips[] IS NOT INITIAL.
          SELECT *
            FROM zmsutdt005
            INTO CORRESPONDING FIELDS OF TABLE gt_005
            FOR ALL ENTRIES IN lt_lips
            WHERE bukrs = pa_bukrs
              AND matnr = lt_lips-matnr
              AND zaun  = 'KAR'.
        ENDIF.
      ENDIF.

      gt_svttp[]  = gt_vttp[].
      SORT gt_svttp BY tknum vbeln.
      DELETE ADJACENT DUPLICATES FROM gt_svttp COMPARING tknum vbeln.
      IF gt_svttp[] IS NOT INITIAL.
        SELECT *
          FROM zmshphist
          INTO CORRESPONDING FIELDS OF TABLE gt_zmshphist
          FOR ALL ENTRIES IN gt_svttp
          WHERE tknum   = gt_svttp-tknum
            AND vbeln   = gt_svttp-vbeln
            AND zreason IN gr_reason.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  TYPES : BEGIN OF ty_dp,
            tknum   TYPE vttp-tknum,
            vbeln   TYPE likp-vbeln,
            kunnr   TYPE likp-kunnr,
          END OF ty_dp.

  DATA : lt_dp        TYPE STANDARD TABLE OF ty_dp,
         lt_kirim     TYPE STANDARD TABLE OF ty_dp,
         lt_lines     TYPE STANDARD TABLE OF ty_lines.

  DATA : ls_likp      LIKE LINE OF gt_likp,
         ls_vttp      LIKE LINE OF gt_vttp,
         ls_dp        LIKE LINE OF lt_dp,
         ls_zmshphist LIKE LINE OF gt_zmshphist,
         ls_kirim     LIKE LINE OF lt_kirim,
         ls_trnhdr    LIKE LINE OF gt_trnhdr,
         ls_trndtl    LIKE LINE OF gt_trndtl,
         ls_lines     LIKE LINE OF lt_lines,
         ls_trnshp    LIKE LINE OF gt_trnshp.

  DATA : lv_header    TYPE string,
         lv_detail    TYPE string.

  LOOP AT gt_likp INTO ls_likp.
    CLEAR ls_vttp.
    READ TABLE gt_vttp INTO ls_vttp
                       WITH KEY vbeln = ls_likp-vbeln.
    IF sy-subrc = 0.
      ls_dp-tknum = ls_vttp-tknum.
      ls_dp-vbeln = ls_vttp-vbeln.
      ls_dp-kunnr = ls_likp-kunnr.
      APPEND ls_dp TO lt_dp.
      CLEAR ls_dp.
    ENDIF.

    CLEAR ls_zmshphist.
    READ TABLE gt_zmshphist INTO ls_zmshphist
                            WITH KEY vbeln = ls_likp-vbeln.
    IF sy-subrc = 0.
      ls_kirim-tknum = ls_zmshphist-tknum.
      ls_kirim-vbeln = ls_zmshphist-vbeln.
      ls_kirim-kunnr = ls_likp-kunnr.
      APPEND ls_kirim TO lt_kirim.
      CLEAR ls_kirim.
    ENDIF.
  ENDLOOP.

  SORT lt_dp BY tknum kunnr.
  SORT lt_kirim BY tknum kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_dp COMPARING tknum kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_kirim COMPARING tknum kunnr.

  LOOP AT gt_trnhdr INTO ls_trnhdr.
    CLEAR lv_header.
    CONCATENATE ls_trnhdr-gtype ls_trnhdr-vkbur
                ls_trnhdr-budatpexp ls_trnhdr-zidno
           INTO lv_header.
    LOOP AT gt_trndtl INTO ls_trndtl WHERE gtype = ls_trnhdr-gtype
                                       AND vkbur = ls_trnhdr-vkbur
                                       AND zidvc = ls_trnhdr-zidvc.
      CLEAR lv_detail.
      CONCATENATE lv_header ls_trndtl-znopol ls_trndtl-kostl
                  ls_trndtl-wwsfr ls_trndtl-wwpos
             INTO lv_detail.

      ls_lines-objnr2 = lv_detail.
      CONDENSE ls_lines-objnr2 NO-GAPS.

      CASE ls_trnhdr-gtype.
        WHEN '22'.
          ls_lines-objnr1 = lv_detail.
          CONDENSE ls_lines-objnr1 NO-GAPS.
          PERFORM f_isi_table USING ls_trnhdr ls_trndtl '' ''
                                    ls_lines-objnr1 ls_lines-objnr2.
        WHEN '24'.
          CLEAR ls_trnshp.
          READ TABLE gt_trnshp INTO ls_trnshp
                               WITH KEY gtype  = ls_trndtl-gtype
                                        vkbur  = ls_trndtl-vkbur
                                        zidvc  = ls_trndtl-zidvc
                                        znopol = ls_trndtl-znopol
                               TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            LOOP AT gt_trnshp INTO ls_trnshp WHERE gtype  = ls_trndtl-gtype
                                               AND vkbur  = ls_trndtl-vkbur
                                               AND zidvc  = ls_trndtl-zidvc
                                               AND znopol = ls_trndtl-znopol.
              CONCATENATE lv_detail ls_trnshp-tknum
                     INTO ls_lines-objnr1.
              CONDENSE ls_lines-objnr1 NO-GAPS.
              PERFORM f_isi_table USING ls_trnhdr ls_trndtl
                                        ls_trnshp-tknum ls_trnshp-erdat
                                        ls_lines-objnr1 ls_lines-objnr2.
            ENDLOOP.
          ELSE.
            ls_lines-objnr1 = lv_detail.
            CONDENSE ls_lines-objnr1 NO-GAPS.
            PERFORM f_isi_table USING ls_trnhdr ls_trndtl '' ''
                                      ls_lines-objnr1 ls_lines-objnr2.
          ENDIF.
        WHEN OTHERS.
          ls_lines-objnr1 = lv_detail.
          CONDENSE ls_lines-objnr1 NO-GAPS.
          PERFORM f_isi_table USING ls_trnhdr ls_trndtl '' ''
                                    ls_lines-objnr1 ls_lines-objnr2.
      ENDCASE.
    ENDLOOP.
  ENDLOOP.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_delivery_canvas.
    WHEN radio2.
      PERFORM f_non_delivery_canvas.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERSION
*&---------------------------------------------------------------------*
FORM f_unit_conversion  USING    fu_value fu_meins fu_meinh
                        CHANGING fc_value.
  DATA : lv_value   TYPE p DECIMALS 2.

  CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
    EXPORTING
      input                = fu_value
      unit_in              = fu_meins
      unit_out             = fu_meinh
    IMPORTING
      output               = lv_value
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

  WRITE lv_value TO fc_value UNIT fu_meinh.

ENDFORM.                    " F_UNIT_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_DETAIL_TRANSACTION
*&---------------------------------------------------------------------*
FORM f_detail_transaction  USING    fu_gtype fu_vkbur
                                    fs_lines  TYPE ty_lines
                           CHANGING fs_out    TYPE zfexpst01.

  DATA : ls_trnhdr    LIKE LINE OF gt_trnhdr,
         ls_trndtl    LIKE LINE OF gt_trndtl,
         ls_typedesc  LIKE LINE OF gt_typedesc,
         lv_item      TYPE zf63tytpeexpdesc-item,
         ls_tl        TYPE zfexpst01x.

  DATA : lt_xtrndtl   TYPE STANDARD TABLE OF zf63trndtl2,
         ls_xtrndtl   LIKE LINE OF lt_xtrndtl.

  DATA : lv_ratio     TYPE p DECIMALS 2.

  lt_xtrndtl[] = gt_trndtl[].
  DELETE lt_xtrndtl WHERE kmstr IS INITIAL
                      AND kmend IS INITIAL.

  LOOP AT gt_trnhdr INTO ls_trnhdr WHERE gtype     = fu_gtype
                                     AND vkbur     = fu_vkbur
                                     AND zidno     = fs_lines-zidno
                                     AND budatpexp = fs_lines-budatpexp.
    LOOP AT gt_trndtl INTO ls_trndtl WHERE gtype  = fu_gtype
                                       AND vkbur  = fu_vkbur
                                       AND zidvc  = ls_trnhdr-zidvc
                                       AND znopol = fs_lines-znopol
                                       AND kostl  = fs_lines-kostl
                                       AND wwsfr  = fs_lines-wwsfr
                                       AND wwpos  = fs_lines-wwpos.
      READ TABLE gt_typedesc INTO ls_typedesc
                             WITH KEY gtype       = fu_gtype
                                      type        = ls_trndtl-type
                                      description = ls_trndtl-description.
      IF sy-subrc = 0.
        lv_item = ls_typedesc-item.
      ELSE.
        READ TABLE gt_typedesc INTO ls_typedesc
                               WITH KEY gtype = fu_gtype
                                        type  = ls_trndtl-type
                                        ltext = ls_trndtl-description.
        IF sy-subrc = 0.
          lv_item = ls_typedesc-item.
        ELSE.
          CLEAR lv_item.
        ENDIF.
      ENDIF.

      CASE ls_trndtl-type.
        WHEN '101'.
          CASE lv_item.
            WHEN '001' OR '003'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-pddk.
            WHEN '002' OR '004' OR '005' OR '006' OR '007'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-pdlk.
          ENDCASE.
        WHEN '102'.
          IF ls_trndtl-kmstr IS NOT INITIAL.
            IF fs_out-kmaw IS INITIAL.
              fs_out-kmaw    = ls_trndtl-kmstr.
            ENDIF.
          ENDIF.
          IF ls_trndtl-kmend IS NOT INITIAL.
            fs_out-kmak    = ls_trndtl-kmend.
          ENDIF.
          IF lv_item = '001'.
            PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                CHANGING ls_tl-bbm.
            PERFORM f_calculate USING '' ls_trndtl-menge
                                CHANGING ls_tl-tltr.
          ENDIF.
        WHEN '103'.
          IF ls_trndtl-kmstr IS NOT INITIAL.
            IF fs_out-kmaw IS INITIAL.
              fs_out-kmaw    = ls_trndtl-kmstr.
            ENDIF.
          ENDIF.
          IF ls_trndtl-kmend IS NOT INITIAL.
            fs_out-kmak    = ls_trndtl-kmend.
          ENDIF.
          IF lv_item = '001'.
            PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                CHANGING ls_tl-bbm.
            PERFORM f_calculate USING '' ls_trndtl-menge
                                CHANGING ls_tl-tltr.
          ENDIF.
        WHEN '104'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-parkir.
            WHEN '002'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-tol.
            WHEN '003'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-tiket.
          ENDCASE.
        WHEN '105'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-hotel.
            WHEN '002'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-kost.
            WHEN '003'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-hotelx.
          ENDCASE.
        WHEN '106'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-warnet.
            WHEN '002'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-scan.
          ENDCASE.
        WHEN '107'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-fotocopy.
          ENDCASE.
        WHEN '109'.
          CASE lv_item.
            WHEN '002'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-print.
            WHEN '003'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-print.
          ENDCASE.
        WHEN '110'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-handling.
          ENDCASE.
        WHEN '111'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-retri.
            WHEN '002'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-timbang.
          ENDCASE.
        WHEN '112'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-tambal.
          ENDCASE.
        WHEN '113'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-bank.
          ENDCASE.
        WHEN '141'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-proffee.
          ENDCASE.
        WHEN '200'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-intmds.
            WHEN '002'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-servmds.
          ENDCASE.
        WHEN '202'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-pulsa.
          ENDCASE.
        WHEN '204'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-stnk.
            WHEN '002'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-plat.
            WHEN '003'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-bpkb.
            WHEN '004'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-kir.
          ENDCASE.
        WHEN '205'.
          CASE lv_item.
            WHEN '001'.
              IF ls_trndtl-kmend IS NOT INITIAL.
                fs_out-gbkm    = ls_trndtl-kmend.
              ENDIF.
              PERFORM f_calculate USING '' ls_trndtl-menge
                                  CHANGING ls_tl-gbqty.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-gbval.
            WHEN '002'.
              IF ls_trndtl-kmend IS NOT INITIAL.
                fs_out-akikm    = ls_trndtl-kmend.
              ENDIF.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-akival.
            WHEN '003'.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-sparepart.
            WHEN '004'.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-sbesar.
            WHEN '005'.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-skecil.
            WHEN '006'.
              IF ls_trndtl-kmend IS NOT INITIAL.
                fs_out-omkm    = ls_trndtl-kmend.
              ENDIF.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-omval.
            WHEN '007'.
              IF ls_trndtl-kmend IS NOT INITIAL.
                fs_out-ogkm    = ls_trndtl-kmend.
              ENDIF.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-ogval.
            WHEN '008'.
              IF ls_trndtl-kmend IS NOT INITIAL.
                fs_out-otkm    = ls_trndtl-kmend.
              ENDIF.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-otval.
            WHEN '009'.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-gembok.
          ENDCASE.
        WHEN '206'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-feerm.
          ENDCASE.
        WHEN '210'.
          CASE lv_item.
            WHEN '012'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-ppn.
          ENDCASE.
        WHEN '211'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-imk.
            WHEN '002'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-ibm.
          ENDCASE.
        WHEN '301'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-pph21.
          ENDCASE.
        WHEN '302'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-pph23.
          ENDCASE.
      ENDCASE.
    ENDLOOP.
    fs_out-kmrange = fs_out-kmak - fs_out-kmaw.
    TRY .
        lv_ratio       = fs_out-kmrange / ls_tl-tltr.
      CATCH cx_sy_zerodivide.
    ENDTRY.
    IF lv_ratio = 0.
      fs_out-ratio = '0'.
    ELSE.
      fs_out-ratio   = lv_ratio.
      CONDENSE fs_out-ratio NO-GAPS.
      CONCATENATE '1:' fs_out-ratio INTO fs_out-ratio.
    ENDIF.
  ENDLOOP.

  ls_tl-ttravel = ls_tl-parkir + ls_tl-tol + ls_tl-tiket.
  ls_tl-tlodg   = ls_tl-hotel + ls_tl-kost + ls_tl-hotelx +
                  ls_tl-pddk + ls_tl-pdlk.
  ls_tl-ttvllod = ls_tl-ttravel + ls_tl-tlodg.
  ls_tl-trm     = ls_tl-ogval + ls_tl-otval + ls_tl-omval +
                  ls_tl-gbval + ls_tl-akival + ls_tl-tambal +
                  ls_tl-gembok + ls_tl-sparepart + ls_tl-sbesar +
                  ls_tl-skecil.
  ls_tl-tvehi   = ls_tl-stnk + ls_tl-kir + ls_tl-plat + ls_tl-bpkb.
  ls_tl-trr     = ls_tl-imk + ls_tl-ibm + ls_tl-retri + ls_tl-timbang.
  ls_tl-ttaxlic = ls_tl-tvehi + ls_tl-trr.
  ls_tl-grand   = ls_tl-bbm + ls_tl-feerm + ls_tl-pulsa + ls_tl-warnet +
                  ls_tl-scan + ls_tl-intmds + ls_tl-servmds + ls_tl-handling +
                  ls_tl-bank + ls_tl-print + ls_tl-fotocopy + ls_tl-proffee +
                  ls_tl-ttvllod + ls_tl-trm + ls_tl-ttaxlic + ls_tl-ppn -
                  ( ls_tl-pph21 + ls_tl-pph23 ).

  WRITE ls_tl-bbm TO fs_out-bbm CURRENCY 'IDR'.
  WRITE ls_tl-tltr TO fs_out-tltr UNIT 'L'.
  WRITE ls_tl-parkir TO fs_out-parkir CURRENCY 'IDR'.
  WRITE ls_tl-tol TO fs_out-tol CURRENCY 'IDR'.
  WRITE ls_tl-tiket TO fs_out-tiket CURRENCY 'IDR'.
  WRITE ls_tl-ttravel TO fs_out-ttravel CURRENCY 'IDR'.
  WRITE ls_tl-hotel TO fs_out-hotel CURRENCY 'IDR'.
  WRITE ls_tl-kost TO fs_out-kost CURRENCY 'IDR'.
  WRITE ls_tl-hotelx TO fs_out-hotelx CURRENCY 'IDR'.
  WRITE ls_tl-pddk TO fs_out-pddk CURRENCY 'IDR'.
  WRITE ls_tl-pdlk TO fs_out-pdlk CURRENCY 'IDR'.
  WRITE ls_tl-tlodg TO fs_out-tlodg CURRENCY 'IDR'.
  WRITE ls_tl-ttvllod TO fs_out-ttvllod CURRENCY 'IDR'.
  WRITE ls_tl-ogval TO fs_out-ogval CURRENCY 'IDR'.
  WRITE ls_tl-otval TO fs_out-otval CURRENCY 'IDR'.
  WRITE ls_tl-omval TO fs_out-omval CURRENCY 'IDR'.
  WRITE ls_tl-gbval TO fs_out-gbval CURRENCY 'IDR'.
  WRITE ls_tl-gbqty TO fs_out-gbqty UNIT 'ST'.
  WRITE ls_tl-akival TO fs_out-akival CURRENCY 'IDR'.
  WRITE ls_tl-tambal TO fs_out-tambal CURRENCY 'IDR'.
  WRITE ls_tl-gembok TO fs_out-gembok CURRENCY 'IDR'.
  WRITE ls_tl-sparepart TO fs_out-sparepart CURRENCY 'IDR'.
  WRITE ls_tl-sbesar TO fs_out-sbesar CURRENCY 'IDR'.
  WRITE ls_tl-skecil TO fs_out-skecil CURRENCY 'IDR'.
  WRITE ls_tl-feerm TO fs_out-feerm CURRENCY 'IDR'.
  WRITE ls_tl-stnk TO fs_out-stnk CURRENCY 'IDR'.
  WRITE ls_tl-plat TO fs_out-plat CURRENCY 'IDR'.
  WRITE ls_tl-bpkb TO fs_out-bpkb CURRENCY 'IDR'.
  WRITE ls_tl-kir TO fs_out-kir CURRENCY 'IDR'.
  WRITE ls_tl-retri TO fs_out-retri CURRENCY 'IDR'.
  WRITE ls_tl-timbang TO fs_out-timbang CURRENCY 'IDR'.
  WRITE ls_tl-imk TO fs_out-imk CURRENCY 'IDR'.
  WRITE ls_tl-ibm TO fs_out-ibm CURRENCY 'IDR'.
  WRITE ls_tl-pulsa TO fs_out-pulsa CURRENCY 'IDR'.
  WRITE ls_tl-warnet TO fs_out-warnet CURRENCY 'IDR'.
  WRITE ls_tl-scan TO fs_out-scan CURRENCY 'IDR'.
  WRITE ls_tl-intmds TO fs_out-intmds CURRENCY 'IDR'.
  WRITE ls_tl-servmds TO fs_out-servmds CURRENCY 'IDR'.
  WRITE ls_tl-handling TO fs_out-handling CURRENCY 'IDR'.
  WRITE ls_tl-bank TO fs_out-bank CURRENCY 'IDR'.
  WRITE ls_tl-print TO fs_out-print CURRENCY 'IDR'.
  WRITE ls_tl-fotocopy TO fs_out-fotocopy CURRENCY 'IDR'.
  WRITE ls_tl-proffee TO fs_out-proffee CURRENCY 'IDR'.
  WRITE ls_tl-trm TO fs_out-trm CURRENCY 'IDR'.
  WRITE ls_tl-tvehi TO fs_out-tvehi CURRENCY 'IDR'.
  WRITE ls_tl-trr TO fs_out-trr CURRENCY 'IDR'.
  WRITE ls_tl-ttaxlic TO fs_out-ttaxlic CURRENCY 'IDR'.
  WRITE ls_tl-ppn TO fs_out-ppn CURRENCY 'IDR'.
  PERFORM f_minus USING ls_tl-pph21
                  CHANGING fs_out-pph21.
  PERFORM f_minus USING ls_tl-pph23
                  CHANGING fs_out-pph23.

  WRITE ls_tl-grand TO fs_out-grand CURRENCY 'IDR'.
ENDFORM.                    " F_DETAIL_TRANSACTION

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR
*&---------------------------------------------------------------------*
FORM f_clear  USING    fu_gtype
                       fs_out   TYPE zfexpst01.
  CLEAR : fs_out-kmaw, fs_out-kmak, fs_out-kmrange, fs_out-bbm,
          fs_out-tltr, fs_out-parkir, fs_out-tol, fs_out-tiket,
          fs_out-ttravel, fs_out-hotel, fs_out-kost, fs_out-hotelx,
          fs_out-pddk, fs_out-pdlk, fs_out-tlodg, fs_out-ttvllod.
  CLEAR : fs_out-ogkm, fs_out-ogval, fs_out-otkm, fs_out-otval,
          fs_out-omkm, fs_out-omval, fs_out-gbkm, fs_out-gbqty,
          fs_out-gbval, fs_out-akikm, fs_out-akival, fs_out-tambal,
          fs_out-gembok, fs_out-sparepart, fs_out-sbesar, fs_out-skecil,
          fs_out-trm, fs_out-feerm.
  CLEAR : fs_out-stnk, fs_out-kir, fs_out-plat, fs_out-bpkb, fs_out-tvehi,
          fs_out-imk, fs_out-ibm, fs_out-retri, fs_out-timbang, fs_out-trr,
          fs_out-ttaxlic.
  CLEAR : fs_out-pulsa, fs_out-warnet, fs_out-scan, fs_out-intmds,
          fs_out-servmds, fs_out-handling, fs_out-bank, fs_out-print,
          fs_out-fotocopy, fs_out-proffee.
  CLEAR : fs_out-grand.
ENDFORM.                    " F_CLEAR

*&---------------------------------------------------------------------*
*&      Form  F_ISI_TABLE
*&---------------------------------------------------------------------*
FORM f_isi_table  USING    fs_trnhdr  TYPE zf63trnhdr2
                           fs_trndtl  TYPE zf63trndtl2
                           fu_tknum fu_erdat fu_objnr1 fu_objnr2.
  DATA : ls_lines     LIKE LINE OF gt_lines.

  ls_lines-objnr1     = fu_objnr1.
  ls_lines-objnr2     = fu_objnr2.
  ls_lines-gtype      = fs_trnhdr-gtype.
  ls_lines-vkbur      = fs_trnhdr-vkbur.
  ls_lines-budatpexp  = fs_trnhdr-budatpexp.
  ls_lines-zidno      = fs_trnhdr-zidno.
  ls_lines-zidvc      = fs_trnhdr-zidvc.
  ls_lines-znopol     = fs_trndtl-znopol.
  ls_lines-kostl      = fs_trndtl-kostl.
  ls_lines-wwsfr      = fs_trndtl-wwsfr.
  ls_lines-wwpos      = fs_trndtl-wwpos.
  ls_lines-tknum      = fu_tknum.
  ls_lines-erdat      = fu_erdat.
  APPEND ls_lines TO gt_lines.
  CLEAR ls_lines.
ENDFORM.                    " F_ISI_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_TOTAL
*&---------------------------------------------------------------------*
FORM f_total  USING    fu_value fu_gtype fu_vkbur fu_budatpexp.
  DATA : ls_column    LIKE LINE OF gt_column,
         lv_length    TYPE i,
         lv_col       TYPE i,
         lv_value(11).

  lv_col  = 10.

  LOOP AT gt_column INTO ls_column.
    IF ls_column-col <= lv_col.
      ADD ls_column-length TO lv_length.
    ENDIF.
  ENDLOOP.
  lv_length = lv_length + 9.
  r1 = 1.
  WRITE : / sy-vline. r1 = r1 + 1.
  WRITE AT r1(lv_length) fu_value. r1 = r1 + lv_length.
  WRITE AT r1(1) sy-vline. r1 = r1 + 1.
  DO 70 TIMES.
    ADD 1 TO lv_col.
    READ TABLE gt_column INTO ls_column
                         WITH KEY col = lv_col.
    PERFORM f_isi_total USING lv_col fu_gtype fu_vkbur fu_budatpexp
                        CHANGING lv_value.
    WRITE AT r1(ls_column-length) lv_value. r1 = r1 + ls_column-length.
    WRITE AT r1(1) sy-vline. r1 = r1 + 1.
  ENDDO.
ENDFORM.                    " F_TOTAL

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE
*&---------------------------------------------------------------------*
FORM f_calculate  USING    fu_wrbtr fu_menge
                  CHANGING fu_value.
  IF fu_wrbtr IS NOT INITIAL.
    ADD fu_wrbtr TO fu_value.
  ELSEIF fu_menge IS NOT INITIAL.
    ADD fu_menge TO fu_value.
  ENDIF.
ENDFORM.                    " F_CALCULATE

*&---------------------------------------------------------------------*
*&      Form  F_ISI_TOTAL
*&---------------------------------------------------------------------*
FORM f_isi_total  USING    fu_col fu_gtype fu_vkbur fu_budatpexp
                  CHANGING fc_value.
  DATA : ls_total     LIKE LINE OF gt_total1,
         lv_budat     TYPE sy-datum,
         ls_column    LIKE LINE OF gt_column,
         lv_field(30) VALUE 'LS_TOTAL-'.

  FIELD-SYMBOLS <fs>   TYPE ANY.

  CLEAR : ls_total, fc_value.

  IF fu_budatpexp IS NOT INITIAL.
    CONCATENATE fu_budatpexp+6(4) fu_budatpexp+3(2) fu_budatpexp(2)
           INTO lv_budat.
    READ TABLE gt_total1 INTO ls_total
                         WITH KEY gtype     = fu_gtype
                                  vkbur     = fu_vkbur
                                  budatpexp = lv_budat.
    IF sy-subrc = 0.
      READ TABLE gt_column INTO ls_column
                           WITH KEY col = fu_col.
      IF ls_column-total1 IS NOT INITIAL.
        CONCATENATE lv_field ls_column-fieldname INTO lv_field.
        ASSIGN (lv_field) TO <fs>.
        WRITE <fs> TO fc_value CURRENCY 'IDR'.
      ENDIF.
    ENDIF.
  ELSEIF fu_gtype IS NOT INITIAL.
    READ TABLE gt_total2 INTO ls_total
                         WITH KEY gtype     = fu_gtype
                                  vkbur     = fu_vkbur.
    IF sy-subrc = 0.
      READ TABLE gt_column INTO ls_column
                           WITH KEY col = fu_col.
      IF ls_column-total2 IS NOT INITIAL.
        CONCATENATE lv_field ls_column-fieldname INTO lv_field.
        ASSIGN (lv_field) TO <fs>.
        WRITE <fs> TO fc_value CURRENCY 'IDR'.
      ENDIF.
    ENDIF.
  ELSE.
    READ TABLE gt_total3 INTO ls_total
                         WITH KEY vkbur     = fu_vkbur.
    IF sy-subrc = 0.
      READ TABLE gt_column INTO ls_column
                           WITH KEY col = fu_col.
      IF ls_column-total2 IS NOT INITIAL.
        CONCATENATE lv_field ls_column-fieldname INTO lv_field.
        ASSIGN (lv_field) TO <fs>.
        WRITE <fs> TO fc_value CURRENCY 'IDR'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_ISI_TOTAL

*&---------------------------------------------------------------------*
*&      Form  F_CALC_TOTAL
*&---------------------------------------------------------------------*
FORM f_calc_total  USING    fu_gtype fu_vkbur fu_budatpexp fu_value fu_col.
  DATA : ls_total1   LIKE LINE OF gt_total1,
         ls_column   LIKE LINE OF gt_column,
         lv_budat    TYPE sy-datum,
         lv_field(30),
         lv_value    TYPE string.

  FIELD-SYMBOLS <fs>   TYPE ANY.

  CONCATENATE fu_budatpexp+6(4) fu_budatpexp+3(2) fu_budatpexp(2)
         INTO lv_budat.

  READ TABLE gt_column INTO ls_column
                       WITH KEY col  = fu_col.
  IF sy-subrc = 0.
    IF ls_column-total1 IS NOT INITIAL.
      lv_value  = fu_value.
      TRANSLATE lv_value USING '. '.
      TRANSLATE lv_value USING ',.'.
      CONDENSE lv_value NO-GAPS.
      lv_value = lv_value / 100.

      CONCATENATE 'LS_TOTAL1-' ls_column-fieldname INTO lv_field.
      ASSIGN (lv_field) TO <fs>.

      <fs> = lv_value.

      ls_total1-budatpexp   = lv_budat.
      ls_total1-gtype       = fu_gtype.
      ls_total1-vkbur       = fu_vkbur.
      COLLECT ls_total1 INTO gt_total1.
      CLEAR ls_total1-budatpexp.
      COLLECT ls_total1 INTO gt_total2.
      CLEAR ls_total1-gtype.
      COLLECT ls_total1 INTO gt_total3.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CALC_TOTAL

*&---------------------------------------------------------------------*
*&      Form  F_DELIVERY_CANVAS
*&---------------------------------------------------------------------*
FORM f_delivery_canvas .
  TYPES : BEGIN OF ty_dp,
            tknum   TYPE vttp-tknum,
            vbeln   TYPE likp-vbeln,
            kunnr   TYPE likp-kunnr,
          END OF ty_dp.

  DATA : lt_lin1      TYPE STANDARD TABLE OF ty_lines,
         lt_lin2      TYPE STANDARD TABLE OF ty_lines,
         lt_lin3      TYPE STANDARD TABLE OF ty_lines,
         lt_dp        TYPE STANDARD TABLE OF ty_dp,
         lt_kirim     TYPE STANDARD TABLE OF ty_dp.

  DATA : ls_lin1      LIKE LINE OF lt_lin1,
         ls_lin2      LIKE LINE OF lt_lin2,
         ls_lin3      LIKE LINE OF lt_lin3,
         ls_zf63gtype LIKE LINE OF gt_zf63gtype,
         ls_out       LIKE LINE OF gt_out,
         ls_tvkbt     LIKE LINE OF gt_tvkbt,
         ls_mstper    LIKE LINE OF gt_mstper,
         ls_mstken    LIKE LINE OF gt_mstken,
         ls_svttp     LIKE LINE OF gt_svttp,
         ls_dp        LIKE LINE OF lt_dp,
         ls_kirim     LIKE LINE OF lt_kirim,
         ls_vttp      LIKE LINE OF gt_vttp,
         ls_likp      LIKE LINE OF gt_likp,
         ls_lips      LIKE LINE OF gt_lips,
         ls_vbap      LIKE LINE OF gt_vbap,
         ls_005       LIKE LINE OF gt_005.

  DATA : lv_line      TYPE zfexpst01-line,
         lv_dn        TYPE i,
         lv_dp        TYPE i,
         lv_kirim     TYPE i,
         lv_btgew     TYPE likp-btgew,
         lv_gewei     TYPE likp-gewei,
         lv_volum     TYPE likp-volum,
         lv_voleh     TYPE likp-voleh,
         lv_netwr     TYPE vbap-netwr,
         lv_mwsbp     TYPE vbap-mwsbp,
         lv_car       TYPE lips-lfimg,
         lv_tcar      TYPE lips-lfimg,
         lv_valdn     TYPE vbap-netwr.

  lt_lin1[] = gt_lines[].
  SORT lt_lin1 BY objnr1.
  DELETE ADJACENT DUPLICATES FROM lt_lin1 COMPARING objnr1.
  lt_lin2[] = gt_lines[].
  SORT lt_lin2 BY objnr2.
  DELETE ADJACENT DUPLICATES FROM lt_lin2 COMPARING objnr2.

  SORT gt_zf63gtype BY gtype.
  LOOP AT gt_zf63gtype INTO ls_zf63gtype.
    ls_out-gtype  = ls_zf63gtype-gtype.
    LOOP AT gt_tvkbt INTO ls_tvkbt.
      ls_out-vkbur  = ls_tvkbt-vkbur.
      LOOP AT lt_lin1 INTO ls_lin1 WHERE gtype = ls_out-gtype
                                     AND vkbur = ls_out-vkbur.
        WRITE ls_lin1-budatpexp TO ls_out-budatpexp DD/MM/YYYY.

        CLEAR : ls_mstper.
        READ TABLE gt_mstper INTO ls_mstper
                             WITH KEY zidno = ls_lin1-zidno.
        IF sy-subrc = 0.
          ls_out-name1    = ls_mstper-name1.
          ls_out-jabatpd  = ls_mstper-jabatpd.
        ELSE.
          CLEAR : ls_out-name1, ls_out-jabatpd.
        ENDIF.

        CLEAR ls_mstken.
        READ TABLE gt_mstken INTO ls_mstken
                             WITH KEY znopol = ls_lin1-znopol.
        IF sy-subrc = 0.
          ls_out-znopol   = ls_lin1-znopol.
          ls_out-jnskend  = ls_mstken-jnskend.
          IF ls_mstken-zujhr IS NOT INITIAL.
            ls_out-zujhr    = ls_mstken-zujhr.
          ELSE.
            CLEAR ls_out-zujhr.
          ENDIF.
        ELSE.
          CLEAR : ls_out-znopol, ls_out-jnskend, ls_out-zujhr.
        ENDIF.

        ls_out-kostl     = ls_lin1-kostl.
        ls_out-wwsfr     = ls_lin1-wwsfr.
        ls_out-wwpos     = ls_lin1-wwpos.
        ls_out-tknum     = ls_lin1-tknum.

        IF ls_zf63gtype-gtype = '24'.
          IF ls_lin1-erdat IS NOT INITIAL.
            WRITE ls_lin1-erdat TO ls_out-erdat DD/MM/YYYY.
          ENDIF.
          LOOP AT gt_svttp INTO ls_svttp WHERE tknum = ls_lin1-tknum.
            ADD 1 TO lv_dn.
          ENDLOOP.

          LOOP AT lt_dp INTO ls_dp WHERE tknum = ls_lin1-tknum.
            ADD 1 TO lv_dp.
          ENDLOOP.

          LOOP AT lt_kirim INTO ls_kirim WHERE tknum = ls_lin1-tknum.
            ADD 1 TO lv_kirim.
          ENDLOOP.

          LOOP AT gt_vttp INTO ls_vttp WHERE tknum = ls_lin1-tknum.
            CLEAR ls_likp.
            LOOP AT gt_likp INTO ls_likp WHERE vbeln = ls_vttp-vbeln.
              ADD ls_likp-btgew TO lv_btgew.
              lv_gewei  = ls_likp-gewei.
              ADD ls_likp-volum TO lv_volum.
              lv_voleh  = ls_likp-voleh.
            ENDLOOP.

            CLEAR ls_lips.
            LOOP AT gt_lips INTO ls_lips WHERE vbeln = ls_vttp-vbeln.
              IF ls_lips-uecha IS INITIAL.
                READ TABLE gt_vbap INTO ls_vbap
                                   WITH KEY vbeln = ls_lips-vgbel
                                            posnr = ls_lips-vgpos.
                IF sy-subrc = 0.
                  ADD ls_vbap-netwr TO lv_netwr.
                  ADD ls_vbap-mwsbp TO lv_mwsbp.
                ENDIF.
                READ TABLE gt_005 INTO ls_005
                                  WITH KEY matnr = ls_lips-matnr.
                IF sy-subrc = 0.
                  IF ls_lips-lfimg IS NOT INITIAL.
                    lv_car  = ls_lips-lfimg / ls_005-umrez.
                  ELSEIF ls_lips-kcmeng IS NOT INITIAL.
                    lv_car  = ls_lips-kcmeng / ls_005-umrez.
                  ENDIF.
                  ADD lv_car TO lv_tcar.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDLOOP.

          ls_out-dn     = lv_dn.
          ls_out-dp     = lv_dp.
          ls_out-dpkir  = lv_kirim.
          lv_valdn      = lv_netwr + lv_mwsbp.

          PERFORM f_unit_conversion USING lv_btgew lv_gewei 'KG'
                                    CHANGING ls_out-tkg.
          PERFORM f_unit_conversion USING lv_volum lv_voleh 'M3'
                                    CHANGING ls_out-tm3.

          WRITE lv_valdn TO ls_out-valdn CURRENCY 'IDR'.
          WRITE lv_tcar TO ls_out-tcar UNIT 'KAR'.
        ENDIF.

        PERFORM f_detail_transaction USING ls_zf63gtype-gtype ls_tvkbt-vkbur
                                           ls_lin1
                                     CHANGING ls_out.
        ADD 1 TO lv_line.
        ls_out-line = lv_line.

        READ TABLE lt_lin2 INTO ls_lin2
                           WITH KEY objnr2 = ls_lin1-objnr2.
        IF sy-subrc = 0.
          DELETE TABLE lt_lin2 FROM ls_lin2.
        ELSE.
          PERFORM f_clear USING ls_zf63gtype-gtype
                          CHANGING ls_out.
        ENDIF.

        APPEND ls_out TO gt_out.

        CLEAR : lv_dn, lv_dp, lv_kirim, lv_valdn, lv_netwr, lv_mwsbp,
                lv_tcar, lv_car, lv_btgew, lv_volum.

        PERFORM f_clear USING ls_zf63gtype-gtype
                        CHANGING ls_out.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_DELIVERY_CANVAS

*&---------------------------------------------------------------------*
*&      Form  F_NON_DELIVERY_CANVAS
*&---------------------------------------------------------------------*
FORM f_non_delivery_canvas .
  TYPES : BEGIN OF ty_dp,
            tknum   TYPE vttp-tknum,
            vbeln   TYPE likp-vbeln,
            kunnr   TYPE likp-kunnr,
          END OF ty_dp.

  DATA : lt_lin1      TYPE STANDARD TABLE OF ty_lines,
         lt_lin2      TYPE STANDARD TABLE OF ty_lines,
         lt_lin3      TYPE STANDARD TABLE OF ty_lines,
         lt_dp        TYPE STANDARD TABLE OF ty_dp,
         lt_kirim     TYPE STANDARD TABLE OF ty_dp.

  DATA : ls_lin1      LIKE LINE OF lt_lin1,
         ls_lin2      LIKE LINE OF lt_lin2,
         ls_lin3      LIKE LINE OF lt_lin3,
         ls_zf63gtype LIKE LINE OF gt_zf63gtype,
         ls_out1      LIKE LINE OF gt_out1,
         ls_tvkbt     LIKE LINE OF gt_tvkbt,
         ls_mstper    LIKE LINE OF gt_mstper,
         ls_mstken    LIKE LINE OF gt_mstken,
         ls_svttp     LIKE LINE OF gt_svttp,
         ls_dp        LIKE LINE OF lt_dp,
         ls_kirim     LIKE LINE OF lt_kirim,
         ls_vttp      LIKE LINE OF gt_vttp,
         ls_likp      LIKE LINE OF gt_likp,
         ls_lips      LIKE LINE OF gt_lips,
         ls_vbap      LIKE LINE OF gt_vbap,
         ls_005       LIKE LINE OF gt_005.

  DATA : lv_line      TYPE zfexpst01-line,
         lv_dn        TYPE i,
         lv_dp        TYPE i,
         lv_kirim     TYPE i,
         lv_btgew     TYPE likp-btgew,
         lv_gewei     TYPE likp-gewei,
         lv_volum     TYPE likp-volum,
         lv_voleh     TYPE likp-voleh,
         lv_netwr     TYPE vbap-netwr,
         lv_mwsbp     TYPE vbap-mwsbp,
         lv_car       TYPE lips-lfimg,
         lv_tcar      TYPE lips-lfimg,
         lv_valdn     TYPE vbap-netwr.

  lt_lin1[] = gt_lines[].
  SORT lt_lin1 BY objnr1.
  DELETE ADJACENT DUPLICATES FROM lt_lin1 COMPARING objnr1.
  lt_lin2[] = gt_lines[].
  SORT lt_lin2 BY objnr2.
  DELETE ADJACENT DUPLICATES FROM lt_lin2 COMPARING objnr2.

  SORT gt_zf63gtype BY gtype.
  LOOP AT gt_zf63gtype INTO ls_zf63gtype.
    ls_out1-gtype  = ls_zf63gtype-gtype.
    LOOP AT gt_tvkbt INTO ls_tvkbt.
      ls_out1-vkbur  = ls_tvkbt-vkbur.
      LOOP AT lt_lin1 INTO ls_lin1 WHERE gtype = ls_out1-gtype
                                     AND vkbur = ls_out1-vkbur.
        WRITE ls_lin1-budatpexp TO ls_out1-budatpexp DD/MM/YYYY.

        CLEAR : ls_mstper.
        READ TABLE gt_mstper INTO ls_mstper
                             WITH KEY zidno = ls_lin1-zidno.
        IF sy-subrc = 0.
          ls_out1-name1    = ls_mstper-name1.
          ls_out1-jabatpd  = ls_mstper-jabatpd.
        ELSE.
          CLEAR : ls_out1-name1, ls_out1-jabatpd.
        ENDIF.

        CLEAR ls_mstken.
        READ TABLE gt_mstken INTO ls_mstken
                             WITH KEY znopol = ls_lin1-znopol.
        IF sy-subrc = 0.
          ls_out1-znopol   = ls_lin1-znopol.
          ls_out1-jnskend  = ls_mstken-jnskend.
          IF ls_mstken-zujhr IS NOT INITIAL.
            ls_out1-zujhr    = ls_mstken-zujhr.
          ELSE.
            CLEAR ls_out1-zujhr.
          ENDIF.
        ELSE.
          CLEAR : ls_out1-znopol, ls_out1-jnskend, ls_out1-zujhr.
        ENDIF.

        ls_out1-kostl     = ls_lin1-kostl.
        ls_out1-wwsfr     = ls_lin1-wwsfr.
        ls_out1-wwpos     = ls_lin1-wwpos.

        PERFORM f_detail_transaction1 USING ls_zf63gtype-gtype ls_tvkbt-vkbur
                                            ls_lin1
                                      CHANGING ls_out1.
        ADD 1 TO lv_line.
        ls_out1-line = lv_line.

        READ TABLE lt_lin2 INTO ls_lin2
                           WITH KEY objnr2 = ls_lin1-objnr2.
        IF sy-subrc = 0.
          DELETE TABLE lt_lin2 FROM ls_lin2.
        ELSE.
          PERFORM f_clear1 USING ls_zf63gtype-gtype
                           CHANGING ls_out1.
        ENDIF.

        APPEND ls_out1 TO gt_out1.

        CLEAR : lv_dn, lv_dp, lv_kirim, lv_valdn, lv_netwr, lv_mwsbp,
                lv_tcar, lv_car, lv_btgew, lv_volum.

        PERFORM f_clear1 USING ls_zf63gtype-gtype
                         CHANGING ls_out1.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_NON_DELIVERY_CANVAS

*&---------------------------------------------------------------------*
*&      Form  F_DETAIL_TRANSACTION1
*&---------------------------------------------------------------------*
FORM f_detail_transaction1  USING   fu_gtype fu_vkbur
                                    fs_lines  TYPE ty_lines
                           CHANGING fs_out1   TYPE zfexpst02.

  DATA : ls_trnhdr    LIKE LINE OF gt_trnhdr,
         ls_trndtl    LIKE LINE OF gt_trndtl,
         ls_typedesc  LIKE LINE OF gt_typedesc,
         lv_item      TYPE zf63tytpeexpdesc-item,
         ls_tl        TYPE zfexpst02x.

  DATA : lt_xtrndtl   TYPE STANDARD TABLE OF zf63trndtl2,
         ls_xtrndtl   LIKE LINE OF lt_xtrndtl,
         lv_ratio     TYPE p DECIMALS 2.

  lt_xtrndtl[] = gt_trndtl[].
  DELETE lt_xtrndtl WHERE kmstr IS INITIAL
                      AND kmend IS INITIAL.

  LOOP AT gt_trnhdr INTO ls_trnhdr WHERE gtype     = fu_gtype
                                     AND vkbur     = fu_vkbur
                                     AND zidno     = fs_lines-zidno
                                     AND budatpexp = fs_lines-budatpexp.
    LOOP AT gt_trndtl INTO ls_trndtl WHERE gtype  = fu_gtype
                                       AND vkbur  = fu_vkbur
                                       AND zidvc  = ls_trnhdr-zidvc
                                       AND znopol = fs_lines-znopol
                                       AND kostl  = fs_lines-kostl
                                       AND wwsfr  = fs_lines-wwsfr
                                       AND wwpos  = fs_lines-wwpos.
      READ TABLE gt_typedesc INTO ls_typedesc
                             WITH KEY gtype       = fu_gtype
                                      type        = ls_trndtl-type
                                      description = ls_trndtl-description.
      IF sy-subrc = 0.
        lv_item = ls_typedesc-item.
      ELSE.
        READ TABLE gt_typedesc INTO ls_typedesc
                               WITH KEY gtype  = fu_gtype
                                        type   = ls_trndtl-type
                                        ltext  = ls_trndtl-description.
        IF sy-subrc = 0.
          lv_item = ls_typedesc-item.
        ELSE.
          CLEAR lv_item.
        ENDIF.
      ENDIF.

      CASE ls_trndtl-type.
        WHEN '101'.
          CASE lv_item.
            WHEN '001' OR '003'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-pddk.
            WHEN '002' OR '004' OR '005' OR '006' OR '007'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-pdlk.
          ENDCASE.
        WHEN '102'.
          IF ls_trndtl-kmstr IS NOT INITIAL.
            IF fs_out1-kmaw IS INITIAL.
              fs_out1-kmaw    = ls_trndtl-kmstr.
            ENDIF.
          ENDIF.
          IF ls_trndtl-kmend IS NOT INITIAL.
            fs_out1-kmak    = ls_trndtl-kmend.
          ENDIF.
          IF lv_item = '001'.
            PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                CHANGING ls_tl-bbm.
            PERFORM f_calculate USING '' ls_trndtl-menge
                                CHANGING ls_tl-tltr.
          ENDIF.
        WHEN '103'.
          IF ls_trndtl-kmstr IS NOT INITIAL.
            IF fs_out1-kmaw IS INITIAL.
              fs_out1-kmaw    = ls_trndtl-kmstr.
            ENDIF.
          ENDIF.
          IF ls_trndtl-kmend IS NOT INITIAL.
            fs_out1-kmak    = ls_trndtl-kmend.
          ENDIF.
          IF lv_item = '001'.
            PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                CHANGING ls_tl-bbm.
            PERFORM f_calculate USING '' ls_trndtl-menge
                                CHANGING ls_tl-tltr.
          ENDIF.
        WHEN '104'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-parkir.
            WHEN '002'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-tol.
            WHEN '003'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-tiket.
            WHEN '004'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-umum.
            WHEN '005'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-ojek.
          ENDCASE.
        WHEN '105'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-hotel.
            WHEN '003'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-hotelx.
          ENDCASE.
        WHEN '106'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-warnet.
            WHEN '002'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-scan.
          ENDCASE.
        WHEN '107'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-fotocopy.
          ENDCASE.
        WHEN '108'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-materai.
            WHEN '002'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-kirim.
          ENDCASE.
        WHEN '109'.
          CASE lv_item.
            WHEN '002'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-print.
            WHEN '003'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-print.
          ENDCASE.
        WHEN '112'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-tambal.
          ENDCASE.
        WHEN '113'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-bank.
          ENDCASE.
        WHEN '141'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-proffee.
          ENDCASE.
        WHEN '201'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-sewa.
          ENDCASE.
        WHEN '202'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-pulsa.
          ENDCASE.
        WHEN '203'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-hotelx.
          ENDCASE.
        WHEN '204'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-stnk.
            WHEN '002'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-plat.
            WHEN '003'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-bpkb.
          ENDCASE.
        WHEN '205'.
          CASE lv_item.
            WHEN '001'.
              IF ls_trndtl-kmend IS NOT INITIAL.
                fs_out1-gbkm    = ls_trndtl-kmend.
              ENDIF.
              PERFORM f_calculate USING '' ls_trndtl-menge
                                  CHANGING ls_tl-gbqty.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-gbval.
            WHEN '002'.
              IF ls_trndtl-kmend IS NOT INITIAL.
                fs_out1-akikm    = ls_trndtl-kmend.
              ENDIF.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-akival.
            WHEN '003'.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-sparepart.
            WHEN '004'.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-sbesar.
            WHEN '005'.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-skecil.
            WHEN '006'.
              IF ls_trndtl-kmend IS NOT INITIAL.
                fs_out1-omkm    = ls_trndtl-kmend.
              ENDIF.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-omval.
            WHEN '007'.
              IF ls_trndtl-kmend IS NOT INITIAL.
                fs_out1-ogkm    = ls_trndtl-kmend.
              ENDIF.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-ogval.
            WHEN '008'.
              IF ls_trndtl-kmend IS NOT INITIAL.
                fs_out1-otkm    = ls_trndtl-kmend.
              ENDIF.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-otval.
            WHEN '009'.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-gembok.
            WHEN '010'.
              PERFORM f_calculate USING '' ls_trndtl-wrbtr
                                  CHANGING ls_tl-tambal.
          ENDCASE.
        WHEN '206'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-feerm.
          ENDCASE.
        WHEN '208'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-miscexp.
          ENDCASE.
        WHEN '210'.
          CASE lv_item.
            WHEN '012'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-ppn.
          ENDCASE.
        WHEN '233'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-pulsa.
          ENDCASE.
        WHEN '301'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-pph21.
          ENDCASE.
        WHEN '302'.
          CASE lv_item.
            WHEN '001'.
              PERFORM f_calculate USING ls_trndtl-wrbtr ''
                                  CHANGING ls_tl-pph23.
          ENDCASE.
      ENDCASE.
    ENDLOOP.
    fs_out1-kmrange = fs_out1-kmak - fs_out1-kmaw.
    TRY .
        lv_ratio       = fs_out1-kmrange / ls_tl-tltr.
      CATCH cx_sy_zerodivide.
    ENDTRY.
    IF lv_ratio = 0.
      fs_out1-ratio = '0'.
    ELSE.
      fs_out1-ratio   = lv_ratio.
      CONDENSE fs_out1-ratio NO-GAPS.
      CONCATENATE '1:' fs_out1-ratio INTO fs_out1-ratio.
    ENDIF.
  ENDLOOP.

  ls_tl-ttravel = ls_tl-parkir + ls_tl-tol + ls_tl-tiket +
                  ls_tl-umum + ls_tl-ojek + ls_tl-sewa.
  ls_tl-tlodg   = ls_tl-hotel + ls_tl-hotelx.
  ls_tl-ttrvoth = ls_tl-pddk + ls_tl-pdlk.
  ls_tl-ttvllod = ls_tl-ttravel + ls_tl-tlodg + ls_tl-ttrvoth.
  ls_tl-trm     = ls_tl-ogval + ls_tl-otval + ls_tl-omval +
                  ls_tl-gbval + ls_tl-akival + ls_tl-tambal +
                  ls_tl-gembok + ls_tl-sparepart + ls_tl-sbesar +
                  ls_tl-skecil.
  ls_tl-ttaxlic = ls_tl-stnk + ls_tl-plat + ls_tl-bpkb.
  ls_tl-grand   = ls_tl-bbm + ls_tl-feerm + ls_tl-materai + ls_tl-kirim +
                  ls_tl-pulsa + ls_tl-warnet + ls_tl-scan + ls_tl-bank +
                  ls_tl-print + ls_tl-fotocopy + ls_tl-miscexp + ls_tl-proffee +
                  ls_tl-ttvllod + ls_tl-trm + ls_tl-ttaxlic + ls_tl-ppn -
                  ( ls_tl-pph21 + ls_tl-pph23 ).

  WRITE ls_tl-bbm TO fs_out1-bbm CURRENCY 'IDR'.
  WRITE ls_tl-tltr TO fs_out1-tltr UNIT 'L'.
  WRITE ls_tl-parkir TO fs_out1-parkir CURRENCY 'IDR'.
  WRITE ls_tl-tol TO fs_out1-tol CURRENCY 'IDR'.
  WRITE ls_tl-tiket TO fs_out1-tiket CURRENCY 'IDR'.
  WRITE ls_tl-ttravel TO fs_out1-ttravel CURRENCY 'IDR'.
  WRITE ls_tl-hotel TO fs_out1-hotel CURRENCY 'IDR'.
  WRITE ls_tl-hotelx TO fs_out1-hotelx CURRENCY 'IDR'.
  WRITE ls_tl-pddk TO fs_out1-pddk CURRENCY 'IDR'.
  WRITE ls_tl-pdlk TO fs_out1-pdlk CURRENCY 'IDR'.
  WRITE ls_tl-tlodg TO fs_out1-tlodg CURRENCY 'IDR'.
  WRITE ls_tl-ttrvoth TO fs_out1-ttrvoth CURRENCY 'IDR'.
  WRITE ls_tl-ttvllod TO fs_out1-ttvllod CURRENCY 'IDR'.
  WRITE ls_tl-ogval TO fs_out1-ogval CURRENCY 'IDR'.
  WRITE ls_tl-otval TO fs_out1-otval CURRENCY 'IDR'.
  WRITE ls_tl-omval TO fs_out1-omval CURRENCY 'IDR'.
  WRITE ls_tl-gbval TO fs_out1-gbval CURRENCY 'IDR'.
  WRITE ls_tl-gbqty TO fs_out1-gbqty UNIT 'ST'.
  WRITE ls_tl-akival TO fs_out1-akival CURRENCY 'IDR'.
  WRITE ls_tl-tambal TO fs_out1-tambal CURRENCY 'IDR'.
  WRITE ls_tl-gembok TO fs_out1-gembok CURRENCY 'IDR'.
  WRITE ls_tl-sparepart TO fs_out1-sparepart CURRENCY 'IDR'.
  WRITE ls_tl-sbesar TO fs_out1-sbesar CURRENCY 'IDR'.
  WRITE ls_tl-skecil TO fs_out1-skecil CURRENCY 'IDR'.
  WRITE ls_tl-feerm TO fs_out1-feerm CURRENCY 'IDR'.
  WRITE ls_tl-stnk TO fs_out1-stnk CURRENCY 'IDR'.
  WRITE ls_tl-plat TO fs_out1-plat CURRENCY 'IDR'.
  WRITE ls_tl-bpkb TO fs_out1-bpkb CURRENCY 'IDR'.
  WRITE ls_tl-pulsa TO fs_out1-pulsa CURRENCY 'IDR'.
  WRITE ls_tl-warnet TO fs_out1-warnet CURRENCY 'IDR'.
  WRITE ls_tl-scan TO fs_out1-scan CURRENCY 'IDR'.
  WRITE ls_tl-bank TO fs_out1-bank CURRENCY 'IDR'.
  WRITE ls_tl-print TO fs_out1-print CURRENCY 'IDR'.
  WRITE ls_tl-fotocopy TO fs_out1-fotocopy CURRENCY 'IDR'.
  WRITE ls_tl-miscexp TO fs_out1-miscexp CURRENCY 'IDR'.
  WRITE ls_tl-materai TO fs_out1-materai CURRENCY 'IDR'.
  WRITE ls_tl-kirim TO fs_out1-kirim CURRENCY 'IDR'.
  WRITE ls_tl-umum TO fs_out1-umum CURRENCY 'IDR'.
  WRITE ls_tl-ojek TO fs_out1-ojek CURRENCY 'IDR'.
  WRITE ls_tl-sewa TO fs_out1-sewa CURRENCY 'IDR'.
  WRITE ls_tl-proffee TO fs_out1-proffee CURRENCY 'IDR'.
  WRITE ls_tl-trm TO fs_out1-trm CURRENCY 'IDR'.
  WRITE ls_tl-ttaxlic TO fs_out1-ttaxlic CURRENCY 'IDR'.
  WRITE ls_tl-ppn TO fs_out1-ppn CURRENCY 'IDR'.

  PERFORM f_minus USING ls_tl-pph21
                  CHANGING fs_out1-pph21.
  PERFORM f_minus USING ls_tl-pph23
                  CHANGING fs_out1-pph23.

  WRITE ls_tl-grand TO fs_out1-grand CURRENCY 'IDR'.
ENDFORM.                    " F_DETAIL_TRANSACTION1

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR1
*&---------------------------------------------------------------------*
FORM f_clear1  USING    fu_gtype
                        fs_out1   TYPE zfexpst02.
  CLEAR : fs_out1-kmaw, fs_out1-kmak, fs_out1-kmrange, fs_out1-bbm,
          fs_out1-tltr, fs_out1-parkir, fs_out1-tol, fs_out1-tiket,
          fs_out1-ttravel, fs_out1-hotel, fs_out1-hotelx,
          fs_out1-pddk, fs_out1-pdlk, fs_out1-tlodg, fs_out1-ttvllod,
          fs_out1-umum, fs_out1-ojek, fs_out1-sewa, fs_out1-ttrvoth.
  CLEAR : fs_out1-ogkm, fs_out1-ogval, fs_out1-otkm, fs_out1-otval,
          fs_out1-omkm, fs_out1-omval, fs_out1-gbkm, fs_out1-gbqty,
          fs_out1-gbval, fs_out1-akikm, fs_out1-akival, fs_out1-tambal,
          fs_out1-gembok, fs_out1-sparepart, fs_out1-sbesar, fs_out1-skecil,
          fs_out1-trm, fs_out1-feerm.
  CLEAR : fs_out1-stnk, fs_out1-plat, fs_out1-bpkb,
          fs_out1-ttaxlic.
  CLEAR : fs_out1-pulsa, fs_out1-warnet, fs_out1-scan, fs_out1-bank,
          fs_out1-print, fs_out1-fotocopy, fs_out1-miscexp, fs_out1-materai,
          fs_out1-kirim, fs_out1-proffee.
  CLEAR : fs_out1-ppn, fs_out1-pph21, fs_out1-pph23, fs_out1-grand.
ENDFORM.                    " F_CLEAR1

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_RADIO1
*&---------------------------------------------------------------------*
FORM f_print_radio1 .
  DATA : lt_out         TYPE STANDARD TABLE OF zfexpst01,
         ls_out         LIKE LINE OF lt_out,
         lt_out1        TYPE STANDARD TABLE OF zfexpst01,
         ls_out1        LIKE LINE OF lt_out,
         lv_times       TYPE i,
         lv_count       TYPE i,
         lv_title(50),
         ls_zf63gtype   LIKE LINE OF gt_zf63gtype,
         ls_tvkbt       LIKE LINE OF gt_tvkbt.

  DATA : lv_end     TYPE i,
         lv_str     TYPE i.

  DESCRIBE TABLE gt_tab LINES lv_times.
  lv_times  = lv_times - 4.

  SORT gt_out BY line gtype vkbur budatpexp.
  lt_out[] = gt_out[].
  SORT lt_out BY gtype vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_out COMPARING gtype vkbur.
  lt_out1[] = gt_out[].
  SORT lt_out1 BY gtype vkbur budatpexp.
  DELETE ADJACENT DUPLICATES FROM lt_out1 COMPARING gtype vkbur budatpexp.

  DESCRIBE TABLE lt_out LINES lv_end.

  LOOP AT lt_out INTO ls_out.
    ADD 1 TO lv_str.
    PERFORM f_top_of_page USING lv_times ls_out-gtype ls_out-vkbur.

    CLEAR ls_out1.
    LOOP AT lt_out1 INTO ls_out1 WHERE gtype = ls_out-gtype
                                   AND vkbur = ls_out-vkbur.

      CLEAR gs_out.
      LOOP AT gt_out INTO gs_out WHERE gtype      = ls_out1-gtype
                                   AND vkbur      = ls_out1-vkbur
                                   AND budatpexp  = ls_out1-budatpexp.
        PERFORM f_write_data USING : '' '1' '' 'X' '' '' 'X' ''
                                     ls_out1-gtype ls_out1-vkbur ls_out1-budatpexp
                                     'GS_OUT-'.
        lv_count = 1.
        DO lv_times TIMES.
          ADD 1 TO lv_count.
          PERFORM f_write_data USING : '' lv_count '' 'X' '' '' '' ''
                                       ls_out1-gtype ls_out1-vkbur ls_out1-budatpexp
                                       'GS_OUT-'.
          IF lv_count = 5.
            SET LEFT SCROLL-BOUNDARY.
          ENDIF.
        ENDDO.
        ADD 1 TO lv_count.
        PERFORM f_write_data USING : '' lv_count '' 'X' '' 'X' '' 'X'
                                     ls_out1-gtype ls_out1-vkbur ls_out1-budatpexp
                                     'GS_OUT-'.
        CLEAR gs_out.
      ENDLOOP.
      WRITE : / sy-uline.
      CONCATENATE 'TOTAL' ls_out1-budatpexp INTO lv_title
      SEPARATED BY space.
      PERFORM f_total USING lv_title ls_out1-gtype ls_out1-vkbur ls_out1-budatpexp.
      WRITE : / sy-uline.
    ENDLOOP.
    READ TABLE gt_zf63gtype INTO ls_zf63gtype
                            WITH KEY gtype = ls_out1-gtype.
    CONCATENATE 'TOTAL' ls_out1-gtype '-' ls_zf63gtype-description INTO lv_title
    SEPARATED BY space.
    PERFORM f_total USING lv_title ls_out-gtype ls_out-vkbur ''.
    WRITE : / sy-uline.
    IF lv_str <> lv_end.
      SKIP 1.
    ENDIF.
  ENDLOOP.

  READ TABLE gt_tvkbt INTO ls_tvkbt
                      WITH KEY vkbur = ls_out-vkbur.
  CONCATENATE 'GRAND TOTAL' ls_out-vkbur '-' ls_tvkbt-bezei INTO lv_title
  SEPARATED BY space.
  PERFORM f_total USING lv_title '' ls_out-vkbur ''.
  WRITE : / sy-uline.
ENDFORM.                    " F_PRINT_RADIO1

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_RADIO2
*&---------------------------------------------------------------------*
FORM f_print_radio2 .
  DATA : lt_out         TYPE STANDARD TABLE OF zfexpst02,
         ls_out         LIKE LINE OF lt_out,
         lt_out1        TYPE STANDARD TABLE OF zfexpst02,
         ls_out1        LIKE LINE OF lt_out,
         lv_times       TYPE i,
         lv_count       TYPE i,
         lv_title(50),
         ls_zf63gtype   LIKE LINE OF gt_zf63gtype,
         ls_tvkbt       LIKE LINE OF gt_tvkbt.

  DATA : lv_end     TYPE i,
         lv_str     TYPE i.

  DESCRIBE TABLE gt_tab LINES lv_times.
  lv_times  = lv_times - 5.

  SORT gt_out1 BY line gtype vkbur budatpexp.
  lt_out[] = gt_out1[].
  SORT lt_out BY gtype vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_out COMPARING gtype vkbur.
  lt_out1[] = gt_out1[].
  SORT lt_out1 BY gtype vkbur budatpexp.
  DELETE ADJACENT DUPLICATES FROM lt_out1 COMPARING gtype vkbur budatpexp.

  DESCRIBE TABLE lt_out LINES lv_end.

  LOOP AT lt_out INTO ls_out.
    ADD 1 TO lv_str.
    PERFORM f_top_of_page USING lv_times ls_out-gtype ls_out-vkbur.

    CLEAR ls_out1.
    LOOP AT lt_out1 INTO ls_out1 WHERE gtype = ls_out-gtype
                                   AND vkbur = ls_out-vkbur.

      CLEAR gs_out1.
      LOOP AT gt_out1 INTO gs_out1 WHERE gtype      = ls_out1-gtype
                                     AND vkbur      = ls_out1-vkbur
                                     AND budatpexp  = ls_out1-budatpexp.
        PERFORM f_write_data USING : '' '1' '' 'X' '' '' 'X' ''
                                     ls_out1-gtype ls_out1-vkbur ls_out1-budatpexp
                                     'GS_OUT1-'.
        lv_count = 1.
        DO lv_times TIMES.
          ADD 1 TO lv_count.
          PERFORM f_write_data USING : '' lv_count '' 'X' '' '' '' ''
                                       ls_out1-gtype ls_out1-vkbur ls_out1-budatpexp
                                       'GS_OUT1-'.
          IF lv_count = 5.
            SET LEFT SCROLL-BOUNDARY.
          ENDIF.
        ENDDO.
        ADD 1 TO lv_count.
        PERFORM f_write_data USING : '' lv_count '' 'X' '' 'X' '' 'X'
                                     ls_out1-gtype ls_out1-vkbur ls_out1-budatpexp
                                     'GS_OUT1-'.
        CLEAR gs_out1.
      ENDLOOP.
      WRITE : / sy-uline.
      CONCATENATE 'TOTAL' ls_out1-budatpexp INTO lv_title
      SEPARATED BY space.
      PERFORM f_total USING lv_title ls_out1-gtype ls_out1-vkbur ls_out1-budatpexp.
      WRITE : / sy-uline.
    ENDLOOP.
    READ TABLE gt_zf63gtype INTO ls_zf63gtype
                            WITH KEY gtype = ls_out1-gtype.
    CONCATENATE 'TOTAL' ls_out1-gtype '-' ls_zf63gtype-description INTO lv_title
    SEPARATED BY space.
    PERFORM f_total USING lv_title ls_out-gtype ls_out-vkbur ''.
    WRITE : / sy-uline.
    IF lv_str <> lv_end.
      SKIP 1.
    ENDIF.
  ENDLOOP.

  READ TABLE gt_tvkbt INTO ls_tvkbt
                      WITH KEY vkbur = ls_out-vkbur.
  CONCATENATE 'GRAND TOTAL' ls_out-vkbur '-' ls_tvkbt-bezei INTO lv_title
  SEPARATED BY space.
  PERFORM f_total USING lv_title '' ls_out-vkbur ''.
  WRITE : / sy-uline.
ENDFORM.                    " F_PRINT_RADIO2

*&---------------------------------------------------------------------*
*&      Form  F_HEAD_LINE1_R1
*&---------------------------------------------------------------------*
FORM f_head_line1_r1 USING fu_line.
  DATA : lv_count   TYPE i.

  PERFORM f_write_data USING : fu_line '1' '' 'X' 'C' '' 'X' '' '' '' '' ''.
  lv_count = 1.
  DO 9 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                                 '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '8' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 8 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '16' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 16 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '16' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 16 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '10' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '5' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  DO 9 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                               '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
ENDFORM.                    " F_HEAD_LINE1_R1

*&---------------------------------------------------------------------*
*&      Form  F_HEAD_LINE2_R1
*&---------------------------------------------------------------------*
FORM f_head_line2_r1  USING    fu_line.
  DATA : lv_count   TYPE i.

  PERFORM f_write_data USING : fu_line '1' '' 'X' 'C' '' 'X' ''
                               '' '' '' ''.
  lv_count = 1.
  DO 9 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                                 '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '8' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 8 TO lv_count.
  WRITE : sy-uline(209) NO-GAP, sy-vline NO-GAP. r1 = r1 + 210.
  ADD 16 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  WRITE : sy-uline(193) NO-GAP, sy-vline NO-GAP. r1 = r1 + 194.
  ADD 18 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  WRITE : sy-uline(139) NO-GAP, sy-vline NO-GAP. r1 = r1 + 140.
  ADD 8 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '5' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  DO 9 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                                 '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
ENDFORM.                    " F_HEAD_LINE2_R1

*&---------------------------------------------------------------------*
*&      Form  F_HEAD_LINE3_R1
*&---------------------------------------------------------------------*
FORM f_head_line3_r1  USING    fu_line.
  DATA : lv_count   TYPE i.

  PERFORM f_write_data USING : fu_line '1' '' 'X' 'C' '' 'X' ''
                               '' '' '' ''.
  lv_count = 1.
  DO 9 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                                 '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '8' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 8 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '6' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 6 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '3' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 3 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '3' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 3 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '2' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 2 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '2' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 2 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '2' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 2 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '2' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 2 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '3' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 3 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '2' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 2 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                               '' '' '' ''.
  DO 5 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                                 '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '4' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 4 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '4' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 4 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '5' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 5 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                               '' '' '' ''.
  DO 9 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                                 '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
ENDFORM.                    " F_HEAD_LINE3_R1

*&---------------------------------------------------------------------*
*&      Form  F_HEAD_LINE4_R1
*&---------------------------------------------------------------------*
FORM f_head_line4_r1  USING    fu_line.
  DATA : lv_count   TYPE i.

  PERFORM f_write_data USING : fu_line '1' '' 'X' 'C' '' 'X' ''
                               '' '' '' ''.
  lv_count = 1.
  DO 8 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                                 '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 8 TO lv_count.
  WRITE : sy-uline(98) NO-GAP, sy-vline NO-GAP. r1 = r1 + 99.
  ADD 6 TO lv_count.
  WRITE : sy-uline(68) NO-GAP, sy-vline NO-GAP. r1 = r1 + 69.
  ADD 3 TO lv_count.
  WRITE : sy-uline(41) NO-GAP, sy-vline NO-GAP. r1 = r1 + 42.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 3 TO lv_count.
  WRITE : sy-uline(42) NO-GAP, sy-vline NO-GAP. r1 = r1 + 43.
  ADD 2 TO lv_count.
  WRITE : sy-uline(27) NO-GAP, sy-vline NO-GAP. r1 = r1 + 28.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 2 TO lv_count.
  WRITE : sy-uline(21) NO-GAP, sy-vline NO-GAP. r1 = r1 + 22.
  ADD 2 TO lv_count.
  WRITE : sy-uline(21) NO-GAP, sy-vline NO-GAP. r1 = r1 + 22.
  ADD 2 TO lv_count.
  WRITE : sy-uline(21) NO-GAP, sy-vline NO-GAP. r1 = r1 + 22.
  ADD 3 TO lv_count.
  WRITE : sy-uline(35) NO-GAP, sy-vline NO-GAP. r1 = r1 + 36.
  ADD 2 TO lv_count.
  WRITE : sy-uline(21) NO-GAP, sy-vline NO-GAP. r1 = r1 + 22.
  DO 6 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                               '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 4 TO lv_count.
  WRITE : sy-uline(55) NO-GAP, sy-vline NO-GAP. r1 = r1 + 56.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 4 TO lv_count.
  WRITE : sy-uline(55) NO-GAP, sy-vline NO-GAP. r1 = r1 + 56.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 5 TO lv_count.
  WRITE : sy-uline(69) NO-GAP, sy-vline NO-GAP. r1 = r1 + 70.
  DO 9 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                               '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
ENDFORM.                    " F_HEAD_LINE4_R1

*&---------------------------------------------------------------------*
*&      Form  F_HEAD_LINE5_R1
*&---------------------------------------------------------------------*
FORM f_head_line5_r1  USING    fu_line fu_times.
  DATA : lv_count   TYPE i.

  PERFORM f_write_data USING : fu_line '1' '' 'X' 'C' '' 'X' ''
                               '' '' '' ''.
  lv_count = 1.
  DO fu_times TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                                 '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
ENDFORM.                    " F_HEAD_LINE5_R1

*&---------------------------------------------------------------------*
*&      Form  F_HEAD_LINE6_R1
*&---------------------------------------------------------------------*
FORM f_head_line6_r1  USING    fu_line fu_times.
  DATA : lv_count   TYPE i.

  PERFORM f_write_data USING : fu_line '1' '' 'X' 'C' '' 'X' ''
                               '' '' '' ''.
  lv_count = 1.
  DO fu_times TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                               '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
ENDFORM.                    " F_HEAD_LINE6_R1

*&---------------------------------------------------------------------*
*&      Form  F_HEAD_LINE1_R2
*&---------------------------------------------------------------------*
FORM f_head_line1_r2  USING    fu_line.
  DATA  : lv_count    TYPE i.

  PERFORM f_write_data USING : fu_line '1' '' 'X' 'C' '' 'X' ''
                               '' '' '' ''.
  lv_count = 1.
  DO 8 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                                 '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '19' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 19 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '16' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 16 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '3' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 3 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '2' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 2 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '3' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 3 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  DO 8 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                                 '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '19' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
ENDFORM.                    " F_HEAD_LINE1_R2

*&---------------------------------------------------------------------*
*&      Form  F_HEAD_LINE2_R2
*&---------------------------------------------------------------------*
FORM f_head_line2_r2  USING    fu_line.
  DATA  : lv_count    TYPE i.

  PERFORM f_write_data USING : fu_line '1' '' 'X' 'C' '' 'X' ''
                               '' '' '' ''.
  lv_count = 1.
  DO 7 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                                 '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.

  ADD 19 TO lv_count.
  WRITE : sy-uline(251) NO-GAP, sy-vline NO-GAP. r1 = r1 + 252.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 16 TO lv_count.
  WRITE : sy-uline(193) NO-GAP, sy-vline NO-GAP. r1 = r1 + 194.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 3 TO lv_count.
  WRITE : sy-uline(41) NO-GAP, sy-vline NO-GAP. r1 = r1 + 42.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 5 TO lv_count.
  WRITE : sy-uline(69) NO-GAP, sy-vline NO-GAP. r1 = r1 + 70.
  DO 8 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                                 '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
ENDFORM.                    " F_HEAD_LINE2_R2

*&---------------------------------------------------------------------*
*&      Form  F_HEAD_LINE3_R2
*&---------------------------------------------------------------------*
FORM f_head_line3_r2  USING    fu_line.
  DATA  : lv_count    TYPE i.

  PERFORM f_write_data USING : fu_line '1' '' 'X' 'C' '' 'X' ''
                               '' '' '' ''.
  lv_count = 1.
  DO 8 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                                 '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '6' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 6 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '6' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 6 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '2' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 2 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '2' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 2 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '2' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 2 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '2' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 2 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '2' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 2 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '3' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 3 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '2' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  DO 6 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                                 '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '3' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 3 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  DO 15 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                                 '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
ENDFORM.                    " F_HEAD_LINE3_R2

*&---------------------------------------------------------------------*
*&      Form  F_HEAD_LINE4_R2
*&---------------------------------------------------------------------*
FORM f_head_line4_r2  USING    fu_line.
  DATA  : lv_count    TYPE i.

  PERFORM f_write_data USING : fu_line '1' '' 'X' 'C' '' 'X' ''
                               '' '' '' ''.
  lv_count = 1.
  DO 7 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                                 '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 12 TO lv_count.
  WRITE : sy-uline(152) NO-GAP, sy-vline NO-GAP. r1 = r1 + 153.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.

  ADD 2 TO lv_count.
  WRITE : sy-uline(28) NO-GAP, sy-vline NO-GAP. r1 = r1 + 29.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.

  ADD 2 TO lv_count.
  WRITE : sy-uline(27) NO-GAP, sy-vline NO-GAP. r1 = r1 + 28.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.

  ADD 10 TO lv_count.
  WRITE : sy-uline(123) NO-GAP, sy-vline NO-GAP. r1 = r1 + 124.
  DO 6 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                               '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.

  ADD 3 TO lv_count.
  WRITE : sy-uline(41) NO-GAP, sy-vline NO-GAP. r1 = r1 + 42.
  DO 15 TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                               '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
ENDFORM.                    " F_HEAD_LINE4_R2

*&---------------------------------------------------------------------*
*&      Form  F_HEAD_LINE5_R2
*&---------------------------------------------------------------------*
FORM f_head_line5_r2  USING    fu_line fu_times.
  DATA  : lv_count    TYPE i.

  PERFORM f_write_data USING : fu_line '1' '' 'X' 'C' '' 'X' ''
                               '' '' '' ''.
  lv_count = 1.
  DO fu_times TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                                 '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
ENDFORM.                    " F_HEAD_LINE5_R2

*&---------------------------------------------------------------------*
*&      Form  F_HEAD_LINE6_R2
*&---------------------------------------------------------------------*
FORM f_head_line6_r2  USING    fu_line fu_times.
  DATA  : lv_count    TYPE i.

  PERFORM f_write_data USING : fu_line '1' '' 'X' 'C' '' 'X' ''
                               '' '' '' ''.
  lv_count = 1.
  DO fu_times TIMES.
    ADD 1 TO lv_count.
    PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' '' '' ''
                               '' '' '' ''.
  ENDDO.
  ADD 1 TO lv_count.
  PERFORM f_write_data USING : fu_line lv_count '' 'X' 'C' 'X' '' 'X'
                               '' '' '' ''.
ENDFORM.                    " F_HEAD_LINE6_R2

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA_ALV
*&---------------------------------------------------------------------*
FORM f_init_data_alv .

ENDFORM.                    " F_INIT_DATA_ALV

*&---------------------------------------------------------------------*
*&      Form  F_CRT_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_crt_dyn_int_table .
  DATA : lt_dyn_table  TYPE REF TO data,
         ls_line       TYPE REF TO data.

  CASE 'X'.
    WHEN radio3.
      PERFORM f_get_field USING 'ZF63TRNHDR2'.
      PERFORM f_get_fieldcat USING :
            'ZIDNO' '' '' '1' '' 'Vendor' '',
*           'BUKRS' '' '' '' '' '' '',
*           'GSBER' '' '' '' '' '' '',
*           'VKBUR' '' '' '' '' '' '',
*           'ZGTYPE' '' '' '' '' '' '',
*           'GJAHR' '' '' '' '' '' '',
            'BELNRPADV' '' '' '8' '' 'Document No.' '',
            'BKTXT' '' '' '7' '' 'Doc.Header Text' '',
            'BUDATPADV' '' '' '10' '' 'PstngDate' '',
            'WAERS' '' '' '12' '' 'Curr' '',
            'XBLNRADV' '' '' '9' '' 'No.Reference' '',
            'ZIDVC' '' '' '6' '' 'No.Voucher' '',
            'ERDAT' '' '' '5' '' 'Periode Adv' '',
            'WRBTR' 'WAERS' '' '11' '' 'Amount' '',
            'ZIDVC' '' '' '13' 'AZIDVC' 'No.Voucher' '',
            'BKTXT' '' '' '14' 'ABKTXT' 'Doc.Header Text' '',
            'BELNRPADV' '' '' '15' 'ABELNRPADV' 'DocNo.Peny.Adv' '',
            'XBLNRADV' '' '' '16' 'AXBLNRADV' 'NoRef.Peny.Adv' '',
            'BELNRPEXP' '' '' '17' '' 'DocNo.Biaya' '',
            'XBLNREXP' '' '' '18' '' 'NoRef.Biaya' '',
            'BUDATPEXP' '' '' '19' '' 'PstngDate' '',
            'WRBTR' 'AWAERS' '' '20' 'AWRBTR' 'Amount' '',
            'WAERS' '' '' '21' 'AWAERS' 'Curr' '',
            'STATUS' '' '' '22' '' 'Status' '',
            'LEAD' '' '' '23' '' 'Lead Time' 'R'.

      PERFORM f_get_field USING 'ZF63GTYPE'.
      PERFORM f_get_fieldcat USING :
            'DESCRIPTION' '' '' '4' '' 'Adv Type' ''.

      PERFORM f_get_field USING 'ZF63MASTERPERSON'.
      PERFORM f_get_fieldcat USING :
            'ZIDNO' '' '' '2' 'PZIDNO' 'ID Personal' '',
            'NAME1' '' '' '3' '' '' ''.

    WHEN radio5.
      PERFORM f_get_field USING 'ZF63TRNHDR2'.
      PERFORM f_get_fieldcat USING :
            'ZIDNO' '' '' '1' '' 'Vendor/ID Personel' '',
            'BKTXT' '' '' '5' '' 'Doc.Header Text' '',
            'BELNRPADV' '' '' '6' '' 'Document No.' '',
            'BELNRPEXP' '' '' '7' '' 'DocNo.Biaya' '',
            'ZIDVC' '' '' '8' '' 'No.Voucher 1' '',
            'ZIDVC2' '' '' '9' '' 'No.Voucher 2' '',
            'XBLNRADV' '' '' '10' '' 'NoRef.Adv' '',
            'XBLNREXP' '' '' '11' '' 'NoRef.Biaya' '',
            'ERDAT' '' '' '12' '' 'Periode Adv' '',
            'WAERS' '' '' '13' '' 'Curr' '',
            'WRBTR' 'WAERS' '' '14' '' 'Amount' '',
            'STATUS' '' '' '15' '' 'Status' '',
            'TGLPOST' '' '' '16' '' 'PstngDate' ''.

      PERFORM f_get_field USING 'ZF63GTYPE'.
      PERFORM f_get_fieldcat USING :
            'DESCRIPTION' '' '' '3' '' 'Type Transaksi' '',
            'JEADVT' '' '' '4' '' 'Adv Type' ''.

      PERFORM f_get_field USING 'ZF63MASTERPERSON'.
      PERFORM f_get_fieldcat USING :
            'NAME1' '' '' '2' '' '' ''.

  ENDCASE.

  SORT gt_main_fieldcat BY col_pos.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog           = gt_main_fieldcat
      i_length_in_byte          = 'X'
      i_style_table             = 'X'
    IMPORTING
      ep_table                  = lt_dyn_table
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.
  IF sy-subrc EQ 0.
    ASSIGN lt_dyn_table->* TO <fs_gt>.
    CREATE DATA ls_line LIKE LINE OF <fs_gt>.
    ASSIGN ls_line->* TO <fs_gs>.
  ENDIF.
ENDFORM.                    " F_CRT_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_GET_FIELD
*&---------------------------------------------------------------------*
FORM f_get_field  USING    fu_tabname.
  CLEAR : dfies_tab[], dfies_tab.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = fu_tabname
    TABLES
      dfies_tab      = dfies_tab
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.
ENDFORM.                    " F_GET_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_GET_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_get_fieldcat  USING    fu_field fu_waers fu_meins fu_pos
                              fu_xfieldname fu_coltext fu_just.
  DATA : ls_tab        TYPE dfies,
         ls_dyn_fcat   TYPE lvc_s_fcat.

  CLEAR ls_tab.
  READ TABLE dfies_tab INTO ls_tab
                       WITH KEY fieldname = fu_field.
  IF sy-subrc = 0.
    MOVE-CORRESPONDING ls_tab TO ls_dyn_fcat.
  ELSE.
    ls_dyn_fcat-fieldname   = fu_field.
  ENDIF.

  ls_dyn_fcat-col_pos     = fu_pos.

  IF fu_xfieldname IS NOT INITIAL.
    ls_dyn_fcat-fieldname = fu_xfieldname.
  ENDIF.
  IF fu_coltext IS NOT INITIAL.
    ls_dyn_fcat-coltext = fu_coltext.
  ENDIF.
  IF fu_waers IS NOT INITIAL.
    ls_dyn_fcat-cfieldname  = fu_waers.
  ENDIF.
  IF fu_meins IS NOT INITIAL.
    ls_dyn_fcat-qfieldname  = fu_meins.
  ENDIF.
  IF fu_just IS NOT INITIAL.
    ls_dyn_fcat-just        = fu_just.
  ENDIF.
  APPEND ls_dyn_fcat TO gt_main_fieldcat.
  CLEAR ls_dyn_fcat.
ENDFORM.                    " F_GET_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_ALV
*&---------------------------------------------------------------------*
FORM f_get_data_alv .
  DATA : lt_trnhdr    TYPE STANDARD TABLE OF zf63trnhdr2,
         lt_lfa1      TYPE STANDARD TABLE OF lfa1,
         ls_trnhdr    LIKE LINE OF lt_trnhdr,
         ls_lfa1      LIKE LINE OF lt_lfa1.

  CASE 'X'.
    WHEN radio3.
      IF gt_selec[] IS NOT INITIAL.
        SELECT *
          FROM zf63trnhdr2
          INTO CORRESPONDING FIELDS OF TABLE gt_trnhdr
          FOR ALL ENTRIES IN gt_selec
          WHERE bukrs      = pa_bukrs
            AND vkbur      = gt_selec-vkbur
            AND gtype      = gt_selec-gtype
            AND erdat     IN so_erdat
            AND userrev    = space.

        lt_trnhdr[] = gt_trnhdr[].
        SORT lt_trnhdr BY zidno.
        DELETE ADJACENT DUPLICATES FROM lt_trnhdr COMPARING zidno.
        LOOP AT lt_trnhdr INTO ls_trnhdr.
          ls_lfa1-lifnr = ls_trnhdr-zidno.
          APPEND ls_lfa1 TO lt_lfa1.
          CLEAR ls_lfa1.
        ENDLOOP.
        IF lt_lfa1[] IS NOT INITIAL.
          SELECT *
            FROM zf63masterperson
            INTO CORRESPONDING FIELDS OF TABLE gt_mstper
            FOR ALL ENTRIES IN lt_lfa1
            WHERE lifnr = lt_lfa1-lifnr.
        ENDIF.

        lt_trnhdr[] = gt_trnhdr[].
        SORT lt_trnhdr BY gjahrpadv belnrpadv.
        DELETE ADJACENT DUPLICATES FROM lt_trnhdr COMPARING gjahrpadv belnrpadv.
        IF lt_trnhdr[] IS NOT INITIAL.
          SELECT *
            FROM zf63trnhdr2
            INTO CORRESPONDING FIELDS OF TABLE gt_atrnhdr
            FOR ALL ENTRIES IN lt_trnhdr
            WHERE bukrs      = lt_trnhdr-bukrs
              AND vkbur      = lt_trnhdr-vkbur
              AND adv_belnr  = lt_trnhdr-belnrpadv
              AND adv_gjahr  = lt_trnhdr-gjahrpadv
              AND userrev    = space.
        ENDIF.
      ENDIF.

    WHEN radio5.
      IF gt_selec[] IS NOT INITIAL.
        SELECT *
          FROM zf63trnhdr2
          INTO CORRESPONDING FIELDS OF TABLE gt_trnhdr
          FOR ALL ENTRIES IN gt_selec
          WHERE bukrs      = pa_bukrs
            AND vkbur      = gt_selec-vkbur
            AND gtype      = gt_selec-gtype
            AND erdat     IN so_budat.
      ENDIF.

      lt_trnhdr[] = gt_trnhdr[].
      SORT lt_trnhdr BY bukrs gsber vkbur.
      DELETE ADJACENT DUPLICATES FROM lt_trnhdr COMPARING bukrs gsber vkbur.
      IF lt_trnhdr[] IS NOT INITIAL.
        SELECT *
          FROM zf63masterperson
          INTO CORRESPONDING FIELDS OF TABLE gt_mstper
          FOR ALL ENTRIES IN lt_trnhdr
          WHERE bukrs   = lt_trnhdr-bukrs
            AND gsber   = lt_trnhdr-gsber
            AND vkbur   = lt_trnhdr-vkbur.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_DATA_ALV

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_ALV
*&---------------------------------------------------------------------*
FORM f_process_data_alv .
  DATA : ls_trnhdr      LIKE LINE OF gt_trnhdr,
         ls_mstper      LIKE LINE OF gt_mstper,
         ls_atrnhdr     LIKE LINE OF gt_atrnhdr,
         ls_zf63gtype   LIKE LINE OF gt_zf63gtype,
         ls_allgtype    LIKE LINE OF gt_allgtype.

  DATA : lv_lifnr     TYPE lfa1-lifnr,
         lv_status(10),
         lv_lead      TYPE i,
         lv_leadt(22),
         lv_datum     TYPE sy-datum VALUE '19000101',
         lv_jeadvt(55).

  CASE 'X'.
    WHEN radio3.
      SORT gt_trnhdr BY zidno zidvc.
      LOOP AT gt_trnhdr INTO ls_trnhdr.
        ASSIGN COMPONENT 'ZIDNO' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-zidno.
        CLEAR ls_mstper.
        READ TABLE gt_mstper INTO ls_mstper
                             WITH KEY lifnr = ls_trnhdr-zidno.
        IF sy-subrc = 0.
          ASSIGN COMPONENT 'PZIDNO' OF STRUCTURE <fs_gs> TO <fs>.
          <fs> = ls_mstper-zidno.
          ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_gs> TO <fs>.
          <fs> = ls_mstper-name1.
        ENDIF.
        CLEAR ls_zf63gtype.
        READ TABLE gt_zf63gtype INTO ls_zf63gtype
                                WITH KEY gtype = ls_trnhdr-gtype.
        IF sy-subrc = 0.
          ASSIGN COMPONENT 'DESCRIPTION' OF STRUCTURE <fs_gs> TO <fs>.
          <fs> = ls_zf63gtype-description.
        ENDIF.
        ASSIGN COMPONENT 'ERDAT' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-erdat.
        ASSIGN COMPONENT 'ZIDVC' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-zidvc.
        ASSIGN COMPONENT 'BKTXT' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-bktxt.
        ASSIGN COMPONENT 'BELNRPADV' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-belnrpadv.
        ASSIGN COMPONENT 'XBLNRADV' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-xblnradv.
        ASSIGN COMPONENT 'BUDATPADV' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-budatpadv.
        ASSIGN COMPONENT 'WRBTR' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-wrbtr.
        ASSIGN COMPONENT 'WAERS' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-waers.

* Aktual Biaya
        CLEAR ls_atrnhdr.
        READ TABLE gt_atrnhdr INTO ls_atrnhdr
                              WITH KEY adv_belnr = ls_trnhdr-belnrpadv
                                       adv_gjahr = ls_trnhdr-gjahrpadv.
        IF sy-subrc = 0.
          CLEAR ls_allgtype.
          READ TABLE gt_allgtype INTO ls_allgtype
                                 WITH KEY gtype = ls_atrnhdr-gtype.
          IF sy-subrc = 0.
            IF ls_allgtype-advance IS INITIAL.
              ASSIGN COMPONENT 'AZIDVC' OF STRUCTURE <fs_gs> TO <fs>.
              <fs> = ls_atrnhdr-zidvc.
              ASSIGN COMPONENT 'ABKTXT' OF STRUCTURE <fs_gs> TO <fs>.
              <fs> = ls_atrnhdr-bktxt.
              ASSIGN COMPONENT 'ABELNRPADV' OF STRUCTURE <fs_gs> TO <fs>.
              <fs> = ls_atrnhdr-belnrpadv.
              ASSIGN COMPONENT 'AXBLNRADV' OF STRUCTURE <fs_gs> TO <fs>.
              <fs> = ls_atrnhdr-xblnradv.
              ASSIGN COMPONENT 'BELNRPEXP' OF STRUCTURE <fs_gs> TO <fs>.
              <fs> = ls_atrnhdr-belnrpexp.
              ASSIGN COMPONENT 'XBLNREXP' OF STRUCTURE <fs_gs> TO <fs>.
              <fs> = ls_atrnhdr-xblnrexp.
              ASSIGN COMPONENT 'BUDATPEXP' OF STRUCTURE <fs_gs> TO <fs>.
              <fs> = ls_atrnhdr-budatpexp.
              ASSIGN COMPONENT 'AWRBTR' OF STRUCTURE <fs_gs> TO <fs>.
              <fs> = ls_atrnhdr-wrbtr.
              ASSIGN COMPONENT 'AWAERS' OF STRUCTURE <fs_gs> TO <fs>.
              <fs> = ls_atrnhdr-waers.
              IF ls_atrnhdr-belnrpexp IS INITIAL.
                lv_status   = 'Not Done'.
              ELSE.
                lv_status   = 'Done'.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          lv_status   = 'Not Done'.
        ENDIF.

        ASSIGN COMPONENT 'STATUS' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = lv_status.

        IF lv_status IS NOT INITIAL.
          IF ls_atrnhdr-budatpexp IS INITIAL.
            lv_lead  = ( lv_datum - ls_trnhdr-budatpadv ) - 2.
          ELSE.
            lv_lead  = ls_atrnhdr-budatpexp - ls_trnhdr-budatpadv.
          ENDIF.
          lv_leadt = lv_lead.
        ELSE.
          CLEAR lv_leadt.
        ENDIF.

        CONDENSE lv_leadt NO-GAPS.
        ASSIGN COMPONENT 'LEAD' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = lv_leadt.

        APPEND <fs_gs> TO <fs_gt>.
        CLEAR : <fs_gs>, lv_status, lv_lead.
      ENDLOOP.

    WHEN radio5.
      SORT gt_trnhdr BY zidno zidvc.
      LOOP AT gt_trnhdr INTO ls_trnhdr.
        ASSIGN COMPONENT 'ZIDNO' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-zidno.

        CLEAR ls_zf63gtype.
        READ TABLE gt_zf63gtype INTO ls_zf63gtype
                                WITH KEY gtype = ls_trnhdr-gtype
                                         bukrs = ls_trnhdr-bukrs.
        IF sy-subrc = 0.
          ASSIGN COMPONENT 'DESCRIPTION' OF STRUCTURE <fs_gs> TO <fs>.
          <fs> = ls_zf63gtype-description.

          IF ls_zf63gtype-advance IS INITIAL.
            CLEAR ls_mstper.
            ASSIGN COMPONENT 'TGLPOST' OF STRUCTURE <fs_gs> TO <fs>.
            <fs> = ls_trnhdr-budatpexp.
            READ TABLE gt_mstper INTO ls_mstper
                                 WITH KEY bukrs = ls_trnhdr-bukrs
                                          gsber = ls_trnhdr-gsber
                                          vkbur = ls_trnhdr-vkbur
                                          zidno = ls_trnhdr-zidno.
            IF sy-subrc = 0.
              ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_gs> TO <fs>.
              <fs> = ls_mstper-name1.
            ENDIF.
          ELSE.
            ASSIGN COMPONENT 'TGLPOST' OF STRUCTURE <fs_gs> TO <fs>.
            <fs> = ls_trnhdr-budatpadv.
            lv_lifnr         = ls_trnhdr-zidno.
            READ TABLE gt_mstper INTO ls_mstper
                                 WITH KEY bukrs = ls_trnhdr-bukrs
                                          gsber = ls_trnhdr-gsber
                                          vkbur = ls_trnhdr-vkbur
                                          lifnr = lv_lifnr.
            IF sy-subrc = 0.
              ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_gs> TO <fs>.
              <fs> = ls_mstper-name1.
            ENDIF.
          ENDIF.

          lv_jeadvt = ls_zf63gtype-jeadv.
          CLEAR ls_zf63gtype-jeadv.
          READ TABLE gt_zf63gtype INTO ls_zf63gtype
                                  WITH KEY gtype = lv_jeadvt
                                           bukrs = ls_trnhdr-bukrs.
          IF sy-subrc = 0.
            CONCATENATE lv_jeadvt '-' ls_zf63gtype-description
            INTO lv_jeadvt
            SEPARATED BY space.
            ASSIGN COMPONENT 'JEADVT' OF STRUCTURE <fs_gs> TO <fs>.
            <fs> = lv_jeadvt.
          ENDIF.
        ENDIF.

        ASSIGN COMPONENT 'BKTXT' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-bktxt.
        ASSIGN COMPONENT 'BELNRPADV' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-belnrpadv.
        ASSIGN COMPONENT 'BELNRPEXP' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-belnrpexp.
        ASSIGN COMPONENT 'ZIDVC' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-zidvc.
        ASSIGN COMPONENT 'ZIDVC2' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-zidvc2.
        ASSIGN COMPONENT 'XBLNRADV' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-xblnradv.
        ASSIGN COMPONENT 'XBLNREXP' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-xblnrexp.
        ASSIGN COMPONENT 'ERDAT' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-erdat.
        ASSIGN COMPONENT 'WRBTR' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-wrbtr.
        ASSIGN COMPONENT 'WAERS' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = ls_trnhdr-waers.

        IF ls_trnhdr-belnrpadv IS INITIAL AND
          ls_trnhdr-belnrpexp IS INITIAL.
          lv_status = 'Not Done'.
        ELSE.
          lv_status = 'Done'.
        ENDIF.
        ASSIGN COMPONENT 'STATUS' OF STRUCTURE <fs_gs> TO <fs>.
        <fs> = lv_status.

        APPEND <fs_gs> TO <fs_gt>.
        CLEAR : <fs_gs>, lv_status, lv_jeadvt.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA_ALV

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA_ALV
*&---------------------------------------------------------------------*
FORM f_print_data_alv .
  CALL SCREEN 100.
ENDFORM.                    " F_PRINT_DATA_ALV

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  CLEAR : fcode, fcode[].

  APPEND '&POS' TO fcode.

  CASE 'X'.
    WHEN radio3.
      SET TITLEBAR 'TITLE_RAD3'.
    WHEN radio5.
      SET TITLEBAR 'TITLE_RAD5'.
  ENDCASE.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  DOCKING_AND_SPLIT_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE docking_and_split_container OUTPUT.
  DATA : lv_contname(20).

  lv_contname   = 'CC_MAIN'.

  IF g_customcont IS INITIAL.
    CREATE OBJECT g_customcont
      EXPORTING
        container_name              = lv_contname
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_splitter
      EXPORTING
        parent  = g_customcont
        rows    = 1
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_contain.

*    CALL METHOD g_splitter->get_container
*      EXPORTING
*        row       = 1
*        column    = 2
*      RECEIVING
*        container = g_contain02.
  ENDIF.
ENDMODULE.                 " DOCKING_AND_SPLIT_CONTAINER  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MAIN_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE main_alv OUTPUT.
  IF g_tabgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_tabgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain.

    PERFORM f_build_layout.
    PERFORM f_build_sort.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command FOR g_tabgrid.

    CALL METHOD g_tabgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_main_sort[]
        it_outtab            = <fs_gt>[]
        it_fieldcatalog      = gt_main_fieldcat[].
*  ELSE.
*    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
ENDMODULE.                 " MAIN_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout_alv-box_fname            = 'CHECK'.
  gs_layout_alv-zebra                = selected.
  gs_layout_alv-cwidth_opt           = selected.
  gs_layout_alv-s_dragdrop-row_ddid  = g_handle_alv.
  gs_layout_alv-no_toolbar           = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
  CLEAR gt_main_sort.

ENDFORM.                    " F_BUILD_SORT

*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : lv_ucomm   TYPE sy-ucomm.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

    WHEN '&LOG'.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_error.

    WHEN '&POS'.
*      PERFORM f_save_data.
      CALL METHOD g_tabgrid->refresh_table_display.
*      gv_pos  = selected.
      MESSAGE s000(zab) WITH 'Data already processed'.

    WHEN OTHERS.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_R4
*&---------------------------------------------------------------------*
FORM f_get_data_r4 .
  DATA : lt_trnhdr    TYPE STANDARD TABLE OF zf63trnhdr2.

  IF gt_selecpexp[] IS NOT INITIAL.
    SELECT *
      FROM zf63trnhdr2
      INTO CORRESPONDING FIELDS OF TABLE gt_trnhdr
      FOR ALL ENTRIES IN gt_selecpexp
      WHERE bukrs      = pa_bukrs
        AND vkbur      = gt_selecpexp-vkbur
        AND gtype      = gt_selecpexp-gtype
        AND budatpexp  IN so_budat.
  ENDIF.

  IF gt_selecpadv[] IS NOT INITIAL.
    SELECT *
      FROM zf63trnhdr2
      APPENDING CORRESPONDING FIELDS OF TABLE gt_trnhdr
      FOR ALL ENTRIES IN gt_selecpadv
      WHERE bukrs      = pa_bukrs
        AND vkbur      = gt_selecpadv-vkbur
        AND gtype      = gt_selecpadv-gtype
        AND budatpadv  IN so_budat.
  ENDIF.

  IF gt_trnhdr[] IS NOT INITIAL.
    SELECT *
      FROM zf63trndtl2
      INTO CORRESPONDING FIELDS OF TABLE gt_trndtl
      FOR ALL ENTRIES IN gt_trnhdr
      WHERE bukrs = gt_trnhdr-bukrs
        AND gsber = gt_trnhdr-gsber
        AND vkbur = gt_trnhdr-vkbur
        AND gtype = gt_trnhdr-gtype
        AND zidvc = gt_trnhdr-zidvc.
  ENDIF.

  lt_trnhdr[] = gt_trnhdr[].
  SORT lt_trnhdr BY bukrs gsber vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_trnhdr COMPARING bukrs gsber vkbur.
  IF lt_trnhdr[] IS NOT INITIAL.
    SELECT *
      FROM zf63masterperson
      INTO CORRESPONDING FIELDS OF TABLE gt_mstper
      FOR ALL ENTRIES IN lt_trnhdr
      WHERE bukrs   = lt_trnhdr-bukrs
        AND gsber   = lt_trnhdr-gsber
        AND vkbur   = lt_trnhdr-vkbur.
  ENDIF.
ENDFORM.                    " F_GET_DATA_R4

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_R4
*&---------------------------------------------------------------------*
FORM f_process_data_r4 .
  DATA : ls_trnhdr      LIKE LINE OF gt_trnhdr,
         ls_trndtl      LIKE LINE OF gt_trndtl,
         ls_head        LIKE LINE OF gt_head,
         ls_detl        LIKE LINE OF gt_detl,
         ls_zf63gtype   LIKE LINE OF gt_zf63gtype,
         ls_mstper      LIKE LINE OF gt_mstper.

  DATA : lv_lifnr       TYPE lfa1-lifnr.

  LOOP AT gt_trnhdr INTO ls_trnhdr.
    ls_head-bukrs    = ls_trnhdr-bukrs.
    ls_head-gsber    = ls_trnhdr-gsber.
    ls_head-gtype    = ls_trnhdr-gtype.
    ls_head-zidvc    = ls_trnhdr-zidvc.
    ls_head-gjahr    = ls_trnhdr-gjahr.
    ls_head-zidno    = ls_trnhdr-zidno.

    CLEAR ls_zf63gtype.
    READ TABLE gt_zf63gtype INTO ls_zf63gtype
                            WITH KEY gtype = ls_trnhdr-gtype
                                     bukrs = ls_trnhdr-bukrs.
    IF sy-subrc = 0.
      IF ls_zf63gtype-advance IS INITIAL.
        ls_head-budat    = ls_trnhdr-budatpexp.
        CLEAR ls_mstper.
        READ TABLE gt_mstper INTO ls_mstper
                             WITH KEY bukrs = ls_trnhdr-bukrs
                                      gsber = ls_trnhdr-gsber
                                      vkbur = ls_trnhdr-vkbur
                                      zidno = ls_trnhdr-zidno.
        IF sy-subrc = 0.
          ls_head-name1   = ls_mstper-name1.
        ENDIF.
      ELSE.
        ls_head-budat    = ls_trnhdr-budatpadv.
        lv_lifnr         = ls_trnhdr-zidno.
        READ TABLE gt_mstper INTO ls_mstper
                             WITH KEY bukrs = ls_trnhdr-bukrs
                                      gsber = ls_trnhdr-gsber
                                      vkbur = ls_trnhdr-vkbur
                                      lifnr = lv_lifnr.
        IF sy-subrc = 0.
          ls_head-name1   = ls_mstper-name1.
        ENDIF.
      ENDIF.
    ENDIF.

    ls_head-bktxt         = ls_trnhdr-bktxt.
    ls_head-waers         = ls_trnhdr-waers.
    ls_head-wrbtr         = ls_trnhdr-wrbtr.
    ls_head-ernam         = ls_trnhdr-ernam.
    ls_head-erdat         = ls_trnhdr-erdat.
    ls_head-erzet         = ls_trnhdr-erzet.
    ls_head-belnrpadv     = ls_trnhdr-belnrpadv.
    ls_head-xblnradv      = ls_trnhdr-xblnradv.
    ls_head-belnrpexp     = ls_trnhdr-belnrpexp.
    ls_head-xblnrexp      = ls_trnhdr-xblnrexp.
    ls_head-adv_belnr     = ls_trnhdr-adv_belnr.
    ls_head-userpost      = ls_trnhdr-userpost.
    ls_head-belnrpadvrev  = ls_trnhdr-belnrpadvrev.
    ls_head-belnrpexprev  = ls_trnhdr-belnrpexprev.
    ls_head-userrev       = ls_trnhdr-userrev.
    ls_head-tglrev        = ls_trnhdr-tglrev.

    APPEND ls_head TO gt_head.
    CLEAR ls_head.
  ENDLOOP.

  LOOP AT gt_trndtl INTO ls_trndtl.
    ls_detl-bukrs       = ls_trndtl-bukrs.
    ls_detl-gsber       = ls_trndtl-gsber.
    ls_detl-gtype       = ls_trndtl-gtype.
    ls_detl-zidvc       = ls_trndtl-zidvc.
    ls_detl-gjahr       = ls_trndtl-gjahr.
    ls_detl-type        = ls_trndtl-type.
    ls_detl-description = ls_trndtl-description.
    ls_detl-meins       = ls_trndtl-meins.
    ls_detl-menge       = ls_trndtl-menge.
    ls_detl-speed       = ls_trndtl-speed.
    ls_detl-kmstr       = ls_trndtl-kmstr.
    ls_detl-kmend       = ls_trndtl-kmend.
    ls_detl-waers       = ls_trndtl-waers.
    IF ls_trndtl-shkzg = 'H'.
      ls_detl-wrbtrv      = ls_trndtl-wrbtr * -1.
    ELSE.
      ls_detl-wrbtrv      = ls_trndtl-wrbtr.
    ENDIF.
    ls_detl-znopol      = ls_trndtl-znopol.

    ls_detl-tarif       = ls_trndtl-tarif.
    ls_detl-persentase  = ls_trndtl-persentase.
    ls_detl-kostl       = ls_trndtl-kostl.
    ls_detl-wwsfr       = ls_trndtl-wwsfr.
    ls_detl-wwpos       = ls_trndtl-wwpos.
    ls_detl-vbund       = ls_trndtl-vbund.
    ls_detl-text        = ls_trndtl-text.

    APPEND ls_detl TO gt_detl.
    CLEAR ls_detl.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA_R4

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_ALV_HIERARCHY
*&---------------------------------------------------------------------*
FORM f_print_alv_hierarchy .
  DATA : lt_binding       TYPE salv_t_hierseq_binding,
         ls_binding       TYPE salv_s_hierseq_binding,
         lr_functions     TYPE REF TO cl_salv_functions_list,
         lr_columns       TYPE REF TO cl_salv_columns_hierseq,
         lr_column        TYPE REF TO cl_salv_column_hierseq,
         lr_display       TYPE REF TO cl_salv_display_settings,
         lr_sorts         TYPE REF TO cl_salv_sorts,
         lr_events        TYPE REF TO cl_salv_events_hierseq,
         lr_aggregations  TYPE REF TO cl_salv_aggregations.

  DATA : lt_extab    TYPE TABLE OF sy-ucomm.

  ls_binding-master = 'BUKRS'.
  ls_binding-slave  = 'BUKRS'.
  APPEND ls_binding TO lt_binding.
  ls_binding-master = 'GSBER'.
  ls_binding-slave  = 'GSBER'.
  APPEND ls_binding TO lt_binding.
  ls_binding-master = 'GTYPE'.
  ls_binding-slave  = 'GTYPE'.
  APPEND ls_binding TO lt_binding.
  ls_binding-master = 'ZIDVC'.
  ls_binding-slave  = 'ZIDVC'.
  APPEND ls_binding TO lt_binding.
  ls_binding-master = 'GJAHR'.
  ls_binding-slave  = 'GJAHR'.
  APPEND ls_binding TO lt_binding.

  TRY.
      cl_salv_hierseq_table=>factory(
        EXPORTING
          t_binding_level1_level2  = lt_binding
        IMPORTING
          r_hierseq                = gr_hierseq
        CHANGING
          t_table_level1           = gt_head
          t_table_level2           = gt_detl ).
    CATCH cx_salv_data_error cx_salv_not_found.
  ENDTRY.

  gr_hierseq->set_screen_status(
    pfstatus   = 'STANDARD1'
    report     = gv_repid ).

  TRY .
      lr_functions = gr_hierseq->get_functions( ).
    CATCH cx_salv_not_found.
  ENDTRY.
  lr_functions->set_all( abap_true ).

  TRY.
      lr_columns = gr_hierseq->get_columns( 1 ).
    CATCH cx_salv_not_found.
  ENDTRY.

  TRY.
      lr_columns->set_expand_column( 'EXPAND' ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_column ?= lr_columns->get_column( 'ICON' ).
  lr_column->set_icon( if_salv_c_bool_sap=>true ).

*  lr_column ?= lr_columns->get_column( 'EXPNR' ).
*  lr_column->set_visible( abap_false ).
*
*  lr_column ?= lr_columns->get_column( 'SHKZG' ).
*  lr_column->set_visible( abap_false ).

  TRY .
      lr_display = gr_hierseq->get_display_settings( ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_display->set_striped_pattern( cl_salv_display_settings=>true ).

  TRY .
      lr_sorts = gr_hierseq->get_sorts( 1 ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_sorts->set_group_active( ).

*  TRY.
*      lr_sorts->add_sort(
*        columnname = 'NAME1'
*        position   = 1
*        sequence   = if_salv_c_sort=>sort_up ).
*    CATCH cx_salv_not_found cx_salv_existing cx_salv_data_error.
*  ENDTRY.
*  TRY.
*      lr_sorts->add_sort(
*        columnname = 'ZNOPOL'
*        position   = 2
*        sequence   = if_salv_c_sort=>sort_up ).
*    CATCH cx_salv_not_found cx_salv_existing cx_salv_data_error.
*  ENDTRY.

  lr_events = gr_hierseq->get_event( ).

  CREATE OBJECT event_receiver.

  SET HANDLER event_receiver->on_user_command FOR lr_events.

  TRY.
      lr_aggregations = gr_hierseq->get_aggregations( 2 ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lr_aggregations->add_aggregation( 'WRBTRV' ).

  gr_hierseq->display( ).

ENDFORM.                    " F_PRINT_ALV_HIERARCHY

*&---------------------------------------------------------------------*
*&      Form  F_MINUS
*&---------------------------------------------------------------------*
FORM f_minus  USING    fu_value
              CHANGING fc_value.
  WRITE fu_value TO fc_value CURRENCY 'IDR'.
*  CONDENSE fc_value NO-GAPS.
  IF fu_value <> 0.
    CONCATENATE fc_value '-' INTO fc_value.
  ELSE.
    fc_value = 0.
  ENDIF.
ENDFORM.                    " F_MINUS
